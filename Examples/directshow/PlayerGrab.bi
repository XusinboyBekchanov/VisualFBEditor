'PlayerGrab.bi
' Copyright (c) 2025 CM.Wang
' Freeware. Use at your own risk.

#include once "windows.bi"
#include once "win/objbase.bi"
#include once "win/strmif.bi"
#include once "win/dshow.bi"
#include once "qedit.bi"
#include once "crt.bi"

#define SAFE_RELEASE(ComPtr) If (ComPtr <> NULL) Then Cast(IUnknown Ptr, ComPtr)->lpVtbl->Release(Cast(IUnknown Ptr, ComPtr)) : ComPtr = NULL

' -------------------------
' 全局帧缓存与同步对象
' Global frame buffer and synchronization object
' -------------------------
Dim Shared g_frameData() As UByte
Dim Shared g_frameLen As Long = 0
Dim Shared g_frameWidth As Long = 0
Dim Shared g_frameHeight As Long = 0
' 使用 Windows CRITICAL_SECTION 实现快速互斥（轻量级）
' Use Windows CRITICAL_SECTION for fast mutual exclusion (lightweight)
Dim Shared g_csFrame As CRITICAL_SECTION

Dim Shared  As IGraphBuilder Ptr pGraph = 0
Dim Shared As IMediaControl Ptr pControl = 0
Dim Shared As IBaseFilter Ptr pGrabF = 0
Dim Shared As ISampleGrabber Ptr pGrabber = 0
Dim Shared As IVideoWindow Ptr pWindow = 0
Dim Shared As IBaseFilter Ptr pSrc = 0
Dim Shared As IBaseFilter Ptr pRenderer = 0
Dim Shared As ICaptureGraphBuilder2 Ptr pBuilder = 0

' -------------------------
' SampleGrabber 回调实现
' 结构与函数名尽量与 qedit.bi 中接口匹配
'
' Implementation of SampleGrabber callback
' The structure and function names try to match the qedit.bi interface
' -------------------------
Type SampleGrabberCBImpl
	lpVtbl As ISampleGrabberCBVTbl Ptr
	refCount As ULong
End Type

Dim Shared As SampleGrabberCBImpl Ptr pCallback
Dim Shared As Integer sourceTopDown = 0
Dim Shared As HRESULT hr
Dim Shared As Integer shotCount = 0

' 初始化/清理 CRITICAL_SECTION
' Initialize / delete CRITICAL_SECTION
Sub InitFrameCS() 
	InitializeCriticalSection(@g_csFrame)
End Sub

Sub DeleteFrameCS()
	DeleteCriticalSection(@g_csFrame)
End Sub

' -------------------------
' 保存 RGB24 到 BMP（考虑 top-down / bottom-up）
' 输入：pBits - 指向连续 RGB24 数据（行打包，无 padding）
'        srcStride - 源每行字节数（通常 width*3）
'        width,height
'        topDownFlag - 如果为 1，表示源数据为 top-down（第一行是上边）
'
' Save RGB24 buffer to BMP (handle top-down / bottom-up)
' Params: pBits - pointer to contiguous RGB24 data (packed rows)
'         srcStride - source row bytes (usually width*3)
'         width, height
'         topDownFlag - 1 if source is top-down (first line is top)
' -------------------------
Function SaveRGB24AsBMP(ByVal filename As String, ByVal pBits As UByte Ptr, ByVal srcStride As Long, ByVal sWidth As Long, ByVal sHeight As Long, ByVal topDownFlag As Integer) As Long
	' 设置像素格式相关参数（24bpp）
	' Setup pixel format params (24bpp)
	Dim As Integer bpp = 24
	' BMP 要求每行按 4 字节对齐，计算行 stride（带 padding）
	' BMP requires row alignment to 4 bytes; calculate stride (with padding)
	Dim As Integer stride = ((sWidth * bpp + 31) \ 32) * 4
	Dim As Integer imgSize = stride * sHeight
	
	Dim As BITMAPFILEHEADER bfh
	Dim As BITMAPINFOHEADER bih
	memset(@bfh, 0, SizeOf(bfh))
	memset(@bih, 0, SizeOf(bih))
	
	bfh.bfType = &H4D42  ' "BM"
	bfh.bfOffBits = SizeOf(BITMAPFILEHEADER) + SizeOf(BITMAPINFOHEADER)
	bfh.bfSize = bfh.bfOffBits + imgSize
	
	bih.biSize = SizeOf(BITMAPINFOHEADER)
	bih.biWidth = sWidth
	' BMP 默认 bottom-up (positive height). 写出文件时把负高度转换为正（写入顺序由我们控制）
	' BMP default is bottom-up (positive height). We control writing order to handle top-down.
	bih.biHeight = sHeight
	bih.biPlanes = 1
	bih.biBitCount = 24
	bih.biCompression = BI_RGB
	bih.biSizeImage = imgSize
	
	Dim As FILE Ptr f = fopen(filename, "wb")
	If f = 0 Then Return 0
	
	fwrite(@bfh, SizeOf(bfh), 1, f)
	fwrite(@bih, SizeOf(bih), 1, f)
	
	' 临时行缓冲（含 padding）
	' temp row buffer (including padding)
	Dim As UByte Ptr row = Cast(UByte Ptr, CAllocate(stride))
	If row = 0 Then
		fclose(f)
		Return 0
	End If
	
	Dim As Long y, srcLine
	For y = 0 To sHeight - 1
		' BMP 的第 0 行是底行，所以当源是 bottom-up (topDownFlag=0) 时，
		' 源的第 0 行是底行，则 srcLine = y
		' 如果源是 top-down (topDownFlag=1)，源的第 0 行是顶行，写 BMP 时需反转：srcLine = height -1 - y
		' BMP row 0 is bottom. If source is bottom-up (topDownFlag=0), srcLine = y.
		' If source is top-down (topDownFlag=1), source row 0 is top and we must invert when writing: srcLine = height -1 - y
		If topDownFlag = 0 Then
			srcLine = y
		Else
			srcLine = sHeight - 1 - y
		End If
		
		memset(row, 0, stride)
		' 源行首地址
		' source row pointer
		memcpy(row, pBits + srcLine * srcStride, srcStride)
		fwrite(row, 1, stride, f)
	Next
	
	Deallocate(row)
	fclose(f)
	Return 1
End Function

' QueryInterface - 标准 COM 接口查询
' QueryInterface - standard COM interface query
Function SGCB_QueryInterface(ByVal pThis As Any Ptr, ByVal riid As REFIID, ByVal ppv As Any Ptr Ptr) As HRESULT
	If ppv = 0 Then Return E_POINTER
	*ppv = 0
	
	' 比较 GUID，支持 IUnknown 与 ISampleGrabberCB
	' Compare GUIDs, support IUnknown and ISampleGrabberCB
	If InlineIsEqualGUID(riid, @IID_IUnknown) OrElse InlineIsEqualGUID(riid, @IID_ISampleGrabberCB) Then
		'If IsEqualIID(@riid, @IID_IUnknown) Or IsEqualIID(@riid, @IID_ISampleGrabberCB) Then
		*ppv = pThis
		Dim As SampleGrabberCBImpl Ptr self = Cast(SampleGrabberCBImpl Ptr, pThis)
		self->refCount += 1
		Return S_OK
	End If
	Return E_NOINTERFACE
End Function

' AddRef - 增加引用计数
' AddRef - increment reference count
Function SGCB_AddRef(ByVal pThis As Any Ptr) As ULong
	Dim As SampleGrabberCBImpl Ptr self = Cast(SampleGrabberCBImpl Ptr, pThis)
	self->refCount += 1
	Return self->refCount
End Function

' Release - 释放对象（引用计数为 0 时释放内存）
' Release - free object when refcount hits 0
Function SGCB_Release(ByVal pThis As Any Ptr) As ULong
	Dim As SampleGrabberCBImpl Ptr self = Cast(SampleGrabberCBImpl Ptr, pThis)
	If self->refCount > 0 Then self->refCount -= 1
	If self->refCount = 0 Then
		Deallocate(self)
		Return 0
	End If
	Return self->refCount
End Function

' SampleCB — 不使用（实现空壳以满足接口）
' SampleCB - unused (empty implementation to satisfy interface)
Function SGCB_SampleCB(ByVal pThis As Any Ptr, ByVal SampleTime As Double, ByVal pSample As Any Ptr) As HRESULT
	Return S_OK
End Function

' BufferCB — 主抓帧点（回调线程中）
' BufferCB - main grab-frame point (called in callback thread)
Function SGCB_BufferCB(ByVal pThis As Any Ptr, ByVal SampleTime As Double, ByVal pBuffer As UByte Ptr, ByVal BufferLen As Long) As HRESULT
	' 使用 TryEnterCriticalSection 做非阻塞拷贝，避免阻塞回调线程太久
	' Use TryEnterCriticalSection for non-blocking copy to avoid blocking the callback thread too long
	If TryEnterCriticalSection(@g_csFrame) Then
		' 重新分配数组并拷贝数据（主线程会在读取时使用临界区保护）
		' Reallocate array and copy data (main thread will read under critical section)
		ReDim g_frameData(BufferLen - 1)
		memcpy(@g_frameData(0), pBuffer, BufferLen)
		g_frameLen = BufferLen
		LeaveCriticalSection(@g_csFrame)
	End If
	Return S_OK
End Function

' 将函数指针填入虚表（ISampleGrabberCBVTbl）
' Fill vtable with function pointers for ISampleGrabberCBVTbl
Dim Shared SGCB_Vtbl As ISampleGrabberCBVTbl = ( _
Cast(Any Ptr, @SGCB_QueryInterface), _
Cast(Any Ptr, @SGCB_AddRef), _
Cast(Any Ptr, @SGCB_Release), _
Cast(Any Ptr, @SGCB_SampleCB), _
Cast(Any Ptr, @SGCB_BufferCB) _
)

' 创建回调对象实例（分配并初始化）
' Create SampleGrabber callback object instance (allocate and init)
Function CreateSampleGrabberCB() As SampleGrabberCBImpl Ptr
	Dim As SampleGrabberCBImpl Ptr cb = CAllocate(SizeOf(SampleGrabberCBImpl))
	If cb = 0 Then Return 0
	cb->lpVtbl = @SGCB_Vtbl
	cb->refCount = 1
	Return cb
End Function

Sub MediaResize(hwnd As HWND)
	If pWindow = NULL Then Exit Sub
	Dim rct As Rect
	GetClientRect(hwnd, @rct)
	pWindow->lpVtbl->SetWindowPosition(pWindow, rct.Left, rct.Top, rct.Right, rct.Bottom)
End Sub

Sub MediaOwner(hwnd As HWND)
	If pWindow = NULL Then Exit Sub
	' 将视频显示到控制台窗口（示例），按需修改为 GUI 窗口句柄
	' Put video into the console window (example) — change to your GUI window handle if needed
	pWindow->lpVtbl->put_Owner(pWindow, Cast(OAHWND, hwnd))
	pWindow->lpVtbl->put_WindowStyle(pWindow, WS_CHILD Or WS_CLIPSIBLINGS)
	MediaResize(hwnd)
	pWindow->lpVtbl->put_Visible(pWindow, OATRUE)
End Sub

Sub MediaStop()
	' 停止并释放
	' Stop and release
	If pControl Then pControl->lpVtbl->Stop(pControl)
	SAFE_RELEASE(pControl)
	
	' 释放回调对象
	' Release callback object
	SAFE_RELEASE(pCallback)
	
	' 清理并释放所有 COM 对象
	' Clean up and release all COM objects
	SAFE_RELEASE(pGrabber)
	SAFE_RELEASE(pGrabF)
	SAFE_RELEASE(pRenderer)
	SAFE_RELEASE(pSrc)
	SAFE_RELEASE(pControl)
	SAFE_RELEASE(pWindow)
	SAFE_RELEASE(pBuilder)
	SAFE_RELEASE(pGraph)
	
	' 删除临界区
	' Delete critical section
	DeleteFrameCS()
End Sub

Sub MediaOpen(hwnd As HWND, filepath As WString Ptr)
	MediaStop()
	
	InitFrameCS() ' 初始化临界区 / init critical section
	
	
	' 创建 FilterGraph 与 CaptureGraphBuilder2
	' Create FilterGraph and CaptureGraphBuilder2
	hr = CoCreateInstance(@CLSID_FilterGraph, NULL, CLSCTX_INPROC_SERVER, @IID_IGraphBuilder, @pGraph)
	If FAILED(hr) Then ? "CoCreateInstance FilterGraph 失败: "; Hex(hr) : End -1
	
	hr = CoCreateInstance(@CLSID_CaptureGraphBuilder2, NULL, CLSCTX_INPROC_SERVER, @IID_ICaptureGraphBuilder2, @pBuilder)
	If FAILED(hr) Then ? "CoCreateInstance CaptureGraphBuilder2 失败: "; Hex(hr) : End -1
	
	pBuilder->lpVtbl->SetFiltergraph(pBuilder, pGraph)
	
	' 输入文件（请按需修改文件路径）
	' Input file (modify path as needed)
	'Dim As WString * 512 filePath = "F:\OfficePC_Update\!Media\632734Y0314.mp4"
	
	' 将源文件添加为 Source Filter
	' Add source filter for the input file
	hr = pGraph->lpVtbl->AddSourceFilter(pGraph, filepath, WStr("Source"), @pSrc)
	If FAILED(hr) Then ? "无法加载文件: "; *filepath; "  hr="; Hex(hr) : End - 1
	
	' 创建 SampleGrabber Filter 并获取 ISampleGrabber 接口
	' Create SampleGrabber filter and get ISampleGrabber interface
	hr = CoCreateInstance(@CLSID_SampleGrabber, NULL, CLSCTX_INPROC_SERVER, @IID_IBaseFilter, @pGrabF)
	If FAILED(hr) Then ? "CoCreateInstance SampleGrabber 失败: "; Hex(hr) : End -1
	
	hr = pGrabF->lpVtbl->QueryInterface(pGrabF, @IID_ISampleGrabber, @pGrabber)
	If FAILED(hr) Then ? "QueryInterface ISampleGrabber 失败: "; Hex(hr) : End -1
	
	hr = pGraph->lpVtbl->AddFilter(pGraph, pGrabF, WStr("SampleGrabber"))
	If FAILED(hr) Then ? "AddFilter SampleGrabber 失败: "; Hex(hr) : End -1
	
	' 设置期望的媒体类型（RGB24）
	' Set desired media type (RGB24)
	Dim As AM_MEDIA_TYPE mt
	memset(@mt, 0, SizeOf(mt))
	mt.majortype = MEDIATYPE_Video
	mt.subtype = MEDIASUBTYPE_RGB24
	mt.formattype = FORMAT_VideoInfo
	hr = pGrabber->lpVtbl->SetMediaType(pGrabber, @mt)
	If FAILED(hr) Then ? "SetMediaType 失败: "; Hex(hr) ' 不直接退出，继续尝试
	
	pGrabber->lpVtbl->SetBufferSamples(pGrabber, False) ' 不使用内部缓冲（我们用回调）
	pGrabber->lpVtbl->SetOneShot(pGrabber, False) ' 非 one-shot 模式
	
	' 渲染器（视频）
	' Create video renderer
	hr = CoCreateInstance(@CLSID_VideoRenderer, NULL, CLSCTX_INPROC_SERVER, @IID_IBaseFilter, @pRenderer)
	If FAILED(hr) Then ? "CoCreateInstance VideoRenderer 失败: "; Hex(hr) : End -1
	hr = pGraph->lpVtbl->AddFilter(pGraph, pRenderer, WStr("Renderer"))
	If FAILED(hr) Then ? "AddFilter Renderer 失败: "; Hex(hr) : End -1
	
	' 使用 CaptureGraphBuilder2 显式渲染：Source -> SampleGrabber -> Renderer
	' Use CaptureGraphBuilder2 to render stream explicitly: Source -> SampleGrabber -> Renderer
	hr = pBuilder->lpVtbl->RenderStream(pBuilder, NULL, @MEDIATYPE_Video, Cast(IUnknown Ptr, pSrc), pGrabF, pRenderer)
	If FAILED(hr) Then ? "RenderStream (video) 失败: "; Hex(hr) : End -1
	
	' 渲染音频（单独让系统选择）
	' Render audio (let the system choose)
	hr = pBuilder->lpVtbl->RenderStream(pBuilder, NULL, @MEDIATYPE_Audio, Cast(IUnknown Ptr, pSrc), NULL, NULL)
	If FAILED(hr) Then ? "RenderStream (audio) 失败: "; Hex(hr) ' 不是致命错误
	
	' 设置回调
	' Set callback for sample grabber
	pCallback = CreateSampleGrabberCB()
	If pCallback = 0 Then ? "创建 SampleGrabber 回调对象失败": End - 1
	
	hr = pGrabber->lpVtbl->SetCallback(pGrabber, Cast(ISampleGrabberCB_ Ptr, pCallback), 1) ' 1 => BufferCB
	If FAILED(hr) Then ? "SetCallback 失败: "; Hex(hr) : ' 继续
	
	' 获取连接后的媒体类型，读取分辨率及 top-down 标志
	' Get connected media type to determine resolution and top-down flag
	Dim As AM_MEDIA_TYPE mtOut
	memset(@mtOut, 0, SizeOf(mtOut))
	hr = pGrabber->lpVtbl->GetConnectedMediaType(pGrabber, @mtOut)
	If SUCCEEDED(hr) Then
		Dim As VIDEOINFOHEADER Ptr vih = Cast(VIDEOINFOHEADER Ptr, mtOut.pbFormat)
		If vih <> 0 Then
			g_frameWidth = vih->bmiHeader.biWidth
			' biHeight < 0 => top-down
			' biHeight < 0 indicates top-down source
			If vih->bmiHeader.biHeight < 0 Then
				g_frameHeight = Abs(vih->bmiHeader.biHeight)
				sourceTopDown = 1
			Else
				g_frameHeight = vih->bmiHeader.biHeight
				sourceTopDown = 0
			End If
		Else
			? "无法从 mtOut.pbFormat 读取 VIDEOINFOHEADER"
		End If
	Else
		? "GetConnectedMediaType 失败: "; Hex(hr)
	End If
	
	' 释放 mtOut.pbFormat（由连接者分配的内存）
	' Free mtOut.pbFormat (allocated by connector)
	If mtOut.pbFormat <> 0 Then
		CoTaskMemFree(mtOut.pbFormat)
		mtOut.pbFormat = 0
	End If
	
	' 控制与显示（将视频窗口嵌入控制台窗口）
	' Control and display - embed video window into console window (example)
	hr = pGraph->lpVtbl->QueryInterface(pGraph, @IID_IMediaControl, @pControl)
	If FAILED(hr) Then ? "QueryInterface IMediaControl 失败: "; Hex(hr) : End -1
	
	hr = pGraph->lpVtbl->QueryInterface(pGraph, @IID_IVideoWindow, @pWindow)
	If FAILED(hr) Then ? "QueryInterface IVideoWindow 失败: "; Hex(hr) : End -1
	
	MediaOwner(hwnd)
End Sub

Sub MediaPause()
	If pControl = NULL Then Exit Sub
	hr = pControl->lpVtbl->Pause(pControl)
End Sub

Sub MediaRun()
	If pControl = NULL Then Exit Sub
	' 开始播放
	' Start playback
	hr = pControl->lpVtbl->Run(pControl)
	If FAILED(hr) Then ? "MediaControl Run 失败: "; Hex(hr) : End -1
	
	? "=== 播放中 ==="
	? "按 [SPACE] 截图"
	? "按 [ESC] 退出"
	? "分辨率: "; g_frameWidth; " x "; g_frameHeight; "  topDown="; sourceTopDown
End Sub

Sub MediaCap()
	If g_frameLen > 0 Then
		If TryEnterCriticalSection(@g_csFrame) Then
			' 确保有数据
			' Ensure there is valid data
			If g_frameLen > 0 And UBound(g_frameData) >= 0 Then
				shotCount += 1
				Dim As String fname = "snapshot_" & Right("000" & Str(shotCount), 3) & ".bmp"
				' 注意：源 stride 可能是 width*3（但连接者可能包含其他 padding）
				' Note: source stride usually width*3 but connector may include padding
				Dim As Long srcStride = g_frameWidth * 3
				' 这里假设回调提供的是紧凑的 RGB24 行（通常 SampleGrabber 在我们指定 RGB24 时是这样）
				' Assume callback provides packed RGB24 rows (typical when SampleGrabber set to RGB24)
				If SaveRGB24AsBMP(fname, @g_frameData(0), srcStride, g_frameWidth, g_frameHeight, sourceTopDown) Then
					? "已保存: "; fname
				Else
					? "保存失败"
				End If
			Else
				? "没有有效帧数据"
			End If
			LeaveCriticalSection(@g_csFrame)
		Else
			? "正在写入帧数据，稍后再试..."
		End If
	Else
		? "没有帧数据"
	End If
End Sub
