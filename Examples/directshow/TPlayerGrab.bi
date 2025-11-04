' Copyright (c) 2025 CM.Wang
' Freeware. Use at your own risk.
' ===============================================================
' TPlayerGrab.bi - DirectShow 视频播放与帧抓取类
' TPlayerGrab.bi - DirectShow Video Player and Frame Grabber Class
' ===============================================================

' 包含必要的头文件 / Include necessary headers
#include once "windows.bi"
#include once "win/objbase.bi"
#include once "win/strmif.bi"
#include once "win/dshow.bi"
#include once "qedit.bi"        ' 包含SampleGrabber接口定义 / For SampleGrabber interface
#include once "crt.bi"

' COM 对象安全释放宏 / COM Object Safe Release Macro
#define SAFE_RELEASE(ComPtr) If (ComPtr <> NULL) Then Cast(IUnknown Ptr, ComPtr)->lpVtbl->Release(Cast(IUnknown Ptr, ComPtr)) : ComPtr = NULL

' ===============================================================
' SampleGrabber 回调实现 / SampleGrabber Callback Implementation
' ===============================================================
Type SampleGrabberCBImpl
	lpVtbl As ISampleGrabberCBVTbl Ptr    ' 虚函数表指针 / Virtual function table pointer
	refCount As ULong                     ' 引用计数 / Reference count
	pPlayer As Any Ptr                    ' 指向拥有者对象 / Pointer to owner object
End Type

' ===============================================================
' TPlayerGrab 类 - DirectShow 视频播放与帧抓取
' TPlayerGrab Class - DirectShow Video Player and Frame Grabber
' ===============================================================
Type TPlayerGrab
	Private:
	' DirectShow COM 对象 / DirectShow COM Objects
	pGraph As IGraphBuilder Ptr           ' 过滤器图管理器 / Filter Graph Manager
	pControl As IMediaControl Ptr         ' 媒体控制接口 / Media Control Interface
	pGrabF As IBaseFilter Ptr             ' SampleGrabber基础过滤器 / SampleGrabber Base Filter
	pGrabber As ISampleGrabber Ptr        ' SampleGrabber接口 / SampleGrabber Interface
	pWindow As IVideoWindow Ptr           ' 视频窗口接口 / Video Window Interface
	pSrc As IBaseFilter Ptr               ' 源过滤器 / Source Filter
	pRenderer As IBaseFilter Ptr          ' 渲染器 / Renderer
	pBuilder As ICaptureGraphBuilder2 Ptr ' 捕获图构建器 / Capture Graph Builder
	
	' 帧数据与同步 / Frame Data and Synchronization
	frameData(Any) As UByte               ' 帧数据数组 / Frame data array
	frameLen As Long                      ' 帧数据长度 / Frame data length
	frameWidth As Long                    ' 帧宽度 / Frame width
	frameHeight As Long                   ' 帧高度 / Frame height
	csFrame As CRITICAL_SECTION           ' 帧数据访问临界区 / Critical section for frame data access
	
	' 回调相关 / Callback Related
	pCallback As Any Ptr                  ' 回调对象指针 / Callback object pointer
	sourceTopDown As Integer              ' 图像方向标志 (1=从上到下) / Image orientation flag (1=top-down)
	shotCount As Integer                  ' 截图计数器 / Screenshot counter
	isInitialized As Integer              ' 初始化标志 / Initialization flag
	
	' 私有方法 / Private Methods
	Declare Sub InitFrameCS()             ' 初始化帧临界区 / Initialize frame critical section
	Declare Sub DeleteFrameCS()           ' 删除帧临界区 / Delete frame critical section
	Declare Function SaveRGB24AsBMP(ByVal filename As String, ByVal pBits As UByte Ptr, ByVal srcStride As Long, ByVal sWidth As Long, ByVal sHeight As Long, ByVal topDownFlag As Integer) As Long
	Declare Sub MediaOwner(ByVal hwnd As HWND)  ' 设置媒体窗口所有者 / Set media window owner
	
	' Virtual function table for callback 回调虚函数表
	SGCB_Vtbl As ISampleGrabberCBVTbl
	
	' ===============================================================
	' Static Callback Methods (Required for COM interface)
	' 静态回调方法（COM接口必需）
	' ===============================================================
	Declare Static Function SGCB_QueryInterface(ByVal pThis As Any Ptr, ByVal riid As REFIID, ByVal ppv As Any Ptr Ptr) As HRESULT
	Declare Static Function SGCB_AddRef(ByVal pThis As Any Ptr) As ULong
	Declare Static Function SGCB_Release(ByVal pThis As Any Ptr) As ULong
	Declare Static Function SGCB_SampleCB(ByVal pThis As Any Ptr, ByVal SampleTime As Double, ByVal pSample As Any Ptr) As HRESULT
	Declare Static Function SGCB_BufferCB(ByVal pThis As Any Ptr, ByVal SampleTime As Double, ByVal pBuffer As UByte Ptr, ByVal BufferLen As Long) As HRESULT
	Declare Function CreateSampleGrabberCB() As SampleGrabberCBImpl Ptr  ' 创建回调对象 / Create callback object
	
Public:
	' 构造函数与析构函数 / Constructor and Destructor
	Declare Constructor()
	Declare Destructor()
	
	' 公共接口 / Public Interface
	Declare Function Open(ByVal hwnd As HWND, ByVal filepath As WString Ptr) As Integer  ' 打开媒体文件 / Open media file
	Declare Sub Close()                                                                  ' 关闭媒体 / Close media
	Declare Sub Run()                                                                    ' 开始播放 / Start playback
	Declare Sub Pause()                                                                  ' 暂停播放 / Pause playback
	Declare Sub Resize(ByVal hwnd As HWND)                                               ' 调整窗口大小 / Resize window
	Declare Function CaptureFrame(ByVal filename As String) As Integer                   ' 捕获帧 / Capture frame
	
	' 属性访问 / Property Access
	Declare Property GetWidth() As Long      ' 获取视频宽度 / Get video width
	Declare Property GetHeight() As Long     ' 获取视频高度 / Get video height
	Declare Property IsOpen() As Integer     ' 检查是否已打开 / Check if opened
End Type


' ===============================================================
' COM 回调接口实现 / COM Callback Interface Implementation
' ===============================================================

' QueryInterface 方法实现 / QueryInterface Method Implementation
Function TPlayerGrab.SGCB_QueryInterface(ByVal pThis As Any Ptr, ByVal riid As REFIID, ByVal ppv As Any Ptr Ptr) As HRESULT
	If ppv = 0 Then Return E_POINTER
	*ppv = 0
	
	' 检查请求的接口类型 / Check requested interface type
	If InlineIsEqualGUID(riid, @IID_IUnknown) OrElse InlineIsEqualGUID(riid, @IID_ISampleGrabberCB) Then
		*ppv = pThis
		Dim As SampleGrabberCBImpl Ptr self = Cast(SampleGrabberCBImpl Ptr, pThis)
		self->refCount += 1
		Return S_OK
	End If
	Return E_NOINTERFACE
End Function

' AddRef 方法实现 / AddRef Method Implementation
Function TPlayerGrab.SGCB_AddRef(ByVal pThis As Any Ptr) As ULong
	Dim As SampleGrabberCBImpl Ptr self = Cast(SampleGrabberCBImpl Ptr, pThis)
	self->refCount += 1
	Return self->refCount
End Function

' Release 方法实现 / Release Method Implementation
Function TPlayerGrab.SGCB_Release(ByVal pThis As Any Ptr) As ULong
	Dim As SampleGrabberCBImpl Ptr self = Cast(SampleGrabberCBImpl Ptr, pThis)
	self->refCount -= 1
	If self->refCount = 0 Then
		Deallocate(self)
		Return 0
	End If
	Return self->refCount
End Function

' SampleCB 方法实现 (未使用) / SampleCB Method Implementation (Not Used)
Function TPlayerGrab.SGCB_SampleCB(ByVal pThis As Any Ptr, ByVal SampleTime As Double, ByVal pSample As Any Ptr) As HRESULT
	Return S_OK
End Function

' BufferCB 方法实现 - 帧数据回调 / BufferCB Method Implementation - Frame Data Callback
Function TPlayerGrab.SGCB_BufferCB(ByVal pThis As Any Ptr, ByVal SampleTime As Double, ByVal pBuffer As UByte Ptr, ByVal BufferLen As Long) As HRESULT
	Dim As SampleGrabberCBImpl Ptr self = Cast(SampleGrabberCBImpl Ptr, pThis)
	If self = 0 OrElse self->pPlayer = 0 Then Return S_OK

	Dim pPlayer As TPlayerGrab Ptr = Cast(TPlayerGrab Ptr, self->pPlayer)

	' 通过玩家对象访问临界区 / Access critical section through player object
	If TryEnterCriticalSection(@pPlayer->csFrame) Then
	' 重新分配数组并拷贝数据 / Reallocate array and copy data
		ReDim pPlayer->frameData(BufferLen - 1)
		memcpy(@pPlayer->frameData(0), pBuffer, BufferLen)
		pPlayer->frameLen = BufferLen
		LeaveCriticalSection(@pPlayer->csFrame)
	End If
	Return S_OK
End Function

' 创建回调对象 / Create Callback Object
Function TPlayerGrab.CreateSampleGrabberCB() As SampleGrabberCBImpl Ptr
	Dim cb As SampleGrabberCBImpl Ptr = CAllocate(SizeOf(SampleGrabberCBImpl))
	If cb = NULL Then Return NULL
	cb->lpVtbl = @SGCB_Vtbl
	cb->refCount = 1
	cb->pPlayer = @This
	Return cb
End Function

' ===============================================================
' TPlayerGrab 类方法实现 / TPlayerGrab Class Method Implementation
' ===============================================================

' 构造函数 / Constructor
Constructor TPlayerGrab()
	' 初始化COM对象指针 / Initialize COM object pointers
	pGraph = 0
	pControl = 0
	pGrabF = 0
	pGrabber = 0
	pWindow = 0
	pSrc = 0
	pRenderer = 0
	pBuilder = 0
	pCallback = 0
	
	' 初始化帧数据相关变量 / Initialize frame data related variables
	frameLen = 0
	frameWidth = 0
	frameHeight = 0
	sourceTopDown = 0
	shotCount = 0
	isInitialized = 0

	' Setup virtual function table for callback 设置回调虚函数表
	With SGCB_Vtbl
		.QueryInterface = Cast(Any Ptr, @SGCB_QueryInterface)
		.AddRef = Cast(Any Ptr, @SGCB_AddRef)
		.Release = Cast(Any Ptr, @SGCB_Release)
		.SampleCB = Cast(Any Ptr, @SGCB_SampleCB)
		.BufferCB = Cast(Any Ptr, @SGCB_BufferCB)
	End With
End Constructor

' 析构函数 / Destructor
Destructor TPlayerGrab()
	Close()
End Destructor

' 初始化临界区 / Initialize Critical Section
Sub TPlayerGrab.InitFrameCS()
	Print "初始化帧数据临界区 / Initializing frame data critical section"
	InitializeCriticalSection(@csFrame)
End Sub

' 删除临界区 / Delete Critical Section
Sub TPlayerGrab.DeleteFrameCS()
	Print "删除帧数据临界区 / Deleting frame data critical section"
	DeleteCriticalSection(@csFrame)
End Sub

' 打开媒体文件 / Open Media File
Function TPlayerGrab.Open(ByVal hwnd As HWND, ByVal filepath As WString Ptr) As Integer
	Close()
	
	InitFrameCS()
	
	Dim As HRESULT hr
	
	' 创建 FilterGraph 与 CaptureGraphBuilder2 / Create FilterGraph and CaptureGraphBuilder2
	hr = CoCreateInstance(@CLSID_FilterGraph, NULL, CLSCTX_INPROC_SERVER, @IID_IGraphBuilder, @pGraph)
	Print "创建FilterGraph实例 / Creating FilterGraph instance: "; Hex(hr)
	If FAILED(hr) Then Return 0
	
	hr = CoCreateInstance(@CLSID_CaptureGraphBuilder2, NULL, CLSCTX_INPROC_SERVER, @IID_ICaptureGraphBuilder2, @pBuilder)
	Print "创建CaptureGraphBuilder2实例 / Creating CaptureGraphBuilder2 instance: "; Hex(hr)
	If FAILED(hr) Then Return 0
	
	hr = pBuilder->lpVtbl->SetFiltergraph(pBuilder, pGraph)
	Print "设置过滤器图 / Setting filter graph: "; Hex(hr)
	
	' 添加源过滤器 / Add Source Filter
	hr = pGraph->lpVtbl->AddSourceFilter(pGraph, filepath, WStr("Source"), @pSrc)
	Print "添加源过滤器 / Adding source filter: "; *filepath; "  返回值 / Return value: "; Hex(hr)
	If FAILED(hr) Then Return 0
	
	' 创建 SampleGrabber / Create SampleGrabber
	hr = CoCreateInstance(@CLSID_SampleGrabber, NULL, CLSCTX_INPROC_SERVER, @IID_IBaseFilter, @pGrabF)
	Print "创建SampleGrabber实例 / Creating SampleGrabber instance: "; Hex(hr)
	If FAILED(hr) Then Return 0
	
	hr = pGrabF->lpVtbl->QueryInterface(pGrabF, @IID_ISampleGrabber, @pGrabber)
	Print "查询ISampleGrabber接口 / Querying ISampleGrabber interface: "; Hex(hr)
	If FAILED(hr) Then Return 0
	
	hr = pGraph->lpVtbl->AddFilter(pGraph, pGrabF, WStr("SampleGrabber"))
	Print "添加SampleGrabber过滤器 / Adding SampleGrabber filter: "; Hex(hr)
	If FAILED(hr) Then Return 0
	
	' 设置媒体类型为 RGB24 / Set media type to RGB24
	Dim As AM_MEDIA_TYPE mt
	memset(@mt, 0, SizeOf(mt))
	mt.majortype = MEDIATYPE_Video
	mt.subtype = MEDIASUBTYPE_RGB24
	mt.formattype = FORMAT_VideoInfo
	hr = pGrabber->lpVtbl->SetMediaType(pGrabber, @mt)
	Print "设置媒体类型为RGB24 / Setting media type to RGB24: "; Hex(hr)
	If FAILED(hr) Then Return 0
	
	hr = pGrabber->lpVtbl->SetBufferSamples(pGrabber, False)
	Print "设置缓冲区采样 / Setting buffer samples: "; Hex(hr)
	If FAILED(hr) Then Return 0
	
	hr = pGrabber->lpVtbl->SetOneShot(pGrabber, False)
	Print "设置单次采样模式 / Setting one-shot mode: "; Hex(hr)
	If FAILED(hr) Then Return 0
	
	' 创建渲染器 / Create Renderer
	hr = CoCreateInstance(@CLSID_VideoRenderer, NULL, CLSCTX_INPROC_SERVER, @IID_IBaseFilter, @pRenderer)
	Print "创建视频渲染器实例 / Creating video renderer instance: "; Hex(hr)
	If FAILED(hr) Then Return 0
	
	hr = pGraph->lpVtbl->AddFilter(pGraph, pRenderer, WStr("Renderer"))
	Print "添加渲染器过滤器 / Adding renderer filter: "; Hex(hr)
	If FAILED(hr) Then Return 0
	
	' 渲染视频流 / Render Video Stream
	hr = pBuilder->lpVtbl->RenderStream(pBuilder, NULL, @MEDIATYPE_Video, Cast(IUnknown Ptr, pSrc), pGrabF, pRenderer)
	Print "渲染视频流 / Rendering video stream: "; Hex(hr)
	If FAILED(hr) Then Return 0
	
	' 渲染音频流 / Render Audio Stream
	hr = pBuilder->lpVtbl->RenderStream(pBuilder, NULL, @MEDIATYPE_Audio, Cast(IUnknown Ptr, pSrc), NULL, NULL)
	Print "渲染音频流 / Rendering audio stream: "; Hex(hr)
	If FAILED(hr) Then Return 0
	
	' 获取连接后的媒体类型信息 / Get connected media type information
	Dim As AM_MEDIA_TYPE mtOut
	memset(@mtOut, 0, SizeOf(mtOut))
	hr = pGrabber->lpVtbl->GetConnectedMediaType(pGrabber, @mtOut)
	Print "获取连接媒体类型 / Getting connected media type: "; Hex(hr)
	If SUCCEEDED(hr) Then
		Dim As VIDEOINFOHEADER Ptr vih = Cast(VIDEOINFOHEADER Ptr, mtOut.pbFormat)
		If vih <> 0 Then
			frameWidth = vih->bmiHeader.biWidth
			If vih->bmiHeader.biHeight < 0 Then
				frameHeight = Abs(vih->bmiHeader.biHeight)
				sourceTopDown = 1
			Else
				frameHeight = vih->bmiHeader.biHeight
				sourceTopDown = 0
			End If
			Print "视频分辨率 / Video resolution: "; frameWidth; " x "; frameHeight; " 方向 / Orientation: "; IIf(sourceTopDown, "从上到下/Top-down", "从下到上/Bottom-up")
		End If
		If mtOut.pbFormat <> 0 Then CoTaskMemFree(mtOut.pbFormat)
	Else
		Return 0
	End If
	
	' 设置回调 / Set Callback
	pCallback = CreateSampleGrabberCB()
	Print "创建SampleGrabber回调对象 / Creating SampleGrabber callback object: "; pCallback
	If pCallback = NULL Then Return 0
	
	hr = pGrabber->lpVtbl->SetCallback(pGrabber, Cast(ISampleGrabberCB_ Ptr, pCallback), 1)
	Print "设置回调函数 / Setting callback function: "; Hex(hr)
	If FAILED(hr) Then Return 0
	
	' 获取控制接口 / Get Control Interfaces
	hr = pGraph->lpVtbl->QueryInterface(pGraph, @IID_IMediaControl, @pControl)
	Print "查询IMediaControl接口 / Querying IMediaControl interface: "; Hex(hr)
	If FAILED(hr) Then Return 0
	
	hr = pGraph->lpVtbl->QueryInterface(pGraph, @IID_IVideoWindow, @pWindow)
	Print "查询IVideoWindow接口 / Querying IVideoWindow interface: "; Hex(hr)
	If FAILED(hr) Then Return 0
	
	' 设置窗口所有者 / Set Window Owner
	MediaOwner(hwnd)
	isInitialized = 1
	Print "媒体播放器初始化成功 / Media player initialized successfully"
	Return 1
End Function

' 关闭媒体 / Close Media
Sub TPlayerGrab.Close()
	Print "关闭媒体播放器 / Closing media player"
	If pControl Then pControl->lpVtbl->Stop(pControl)
	If pGrabber Then pGrabber->lpVtbl->SetCallback(pGrabber, NULL, 0)
	
	' 释放COM对象 / Release COM Objects
	SAFE_RELEASE(pControl)
	SAFE_RELEASE(pGrabber)
	SAFE_RELEASE(pGrabF)
	SAFE_RELEASE(pRenderer)
	SAFE_RELEASE(pSrc)
	SAFE_RELEASE(pWindow)
	SAFE_RELEASE(pBuilder)
	SAFE_RELEASE(pGraph)
	
	' 释放回调 / Release Callback
	If pCallback Then
		Cast(IUnknown Ptr, pCallback)->lpVtbl->Release(Cast(IUnknown Ptr, pCallback))
		pCallback = 0
	End If
	
	' 清理帧数据 / Cleanup Frame Data
	frameLen = 0
	Erase frameData
	
	DeleteFrameCS()
	isInitialized = 0
	Print "媒体播放器已关闭 / Media player closed"
End Sub

' 运行播放 / Run Playback
Sub TPlayerGrab.Run()
	If pControl = 0 Then 
		Print "错误: 媒体控制接口未初始化 / Error: Media control interface not initialized"
		Exit Sub
	End If
	Dim hr As HRESULT = pControl->lpVtbl->Run(pControl)
	Print "开始播放 / Starting playback: "; IIf(SUCCEEDED(hr), "成功/Success", "失败/Failed: " & Hex(hr))
End Sub

' 暂停播放 / Pause Playback
Sub TPlayerGrab.Pause()
	If pControl = 0 Then 
		Print "错误: 媒体控制接口未初始化 / Error: Media control interface not initialized"
		Exit Sub
	End If
	Dim hr As HRESULT = pControl->lpVtbl->Pause(pControl)
	Print "暂停播放 / Pausing playback: "; IIf(SUCCEEDED(hr), "成功/Success", "失败/Failed: " & Hex(hr))
End Sub

' 调整视频窗口大小 / Resize Video Window
Sub TPlayerGrab.Resize(ByVal hwnd As HWND)
	If pWindow = 0 Then 
		Print "错误: 视频窗口接口未初始化 / Error: Video window interface not initialized"
		Exit Sub
	End If
	Dim rct As RECT
	GetClientRect(hwnd, @rct)
	Dim hr As HRESULT = pWindow->lpVtbl->SetWindowPosition(pWindow, rct.left, rct.top, rct.right, rct.bottom)
	Print "调整窗口大小 / Resizing window: "; IIf(SUCCEEDED(hr), "成功/Success", "失败/Failed: " & Hex(hr))
End Sub

' 设置窗口所有者 / Set Window Owner
Sub TPlayerGrab.MediaOwner(ByVal hwnd As HWND)
	If pWindow = 0 Then Exit Sub
	
	Dim hr1 As HRESULT = pWindow->lpVtbl->put_Owner(pWindow, Cast(OAHWND, hwnd))
	Dim hr2 As HRESULT = pWindow->lpVtbl->put_WindowStyle(pWindow, WS_CHILD Or WS_CLIPSIBLINGS)
	Resize(hwnd)
	Dim hr3 As HRESULT = pWindow->lpVtbl->put_Visible(pWindow, OATRUE)
	
	Print "设置窗口所有者 / Setting window owner:"
	Print "  - 设置所有者 / Set owner: "; IIf(SUCCEEDED(hr1), "成功/Success", "失败/Failed: " & Hex(hr1))
	Print "  - 设置窗口样式 / Set window style: "; IIf(SUCCEEDED(hr2), "成功/Success", "失败/Failed: " & Hex(hr2))
	Print "  - 设置可见性 / Set visibility: "; IIf(SUCCEEDED(hr3), "成功/Success", "失败/Failed: " & Hex(hr3))
End Sub

' 保存RGB24为BMP / Save RGB24 as BMP
Function TPlayerGrab.SaveRGB24AsBMP(ByVal filename As String, ByVal pBits As UByte Ptr, _
	ByVal srcStride As Long, ByVal sWidth As Long, _
	ByVal sHeight As Long, ByVal topDownFlag As Integer) As Long
	Dim As Integer bpp = 24  ' 位深度 / Bits per pixel
	Dim As Integer stride = ((sWidth * bpp + 31) \ 32) * 4  ' BMP行对齐 / BMP row alignment
	Dim As Integer imgSize = stride * sHeight  ' 图像数据大小 / Image data size
	
	' 初始化BMP文件头 / Initialize BMP file header
	Dim As BITMAPFILEHEADER bfh
	Dim As BITMAPINFOHEADER bih
	memset(@bfh, 0, SizeOf(bfh))
	memset(@bih, 0, SizeOf(bih))
	
	bfh.bfType = &H4D42        ' "BM" / BMP文件标识 / BMP file signature
	bfh.bfOffBits = SizeOf(BITMAPFILEHEADER) + SizeOf(BITMAPINFOHEADER)  ' 数据偏移 / Data offset
	bfh.bfSize = bfh.bfOffBits + imgSize  ' 文件总大小 / Total file size
	
	bih.biSize = SizeOf(BITMAPINFOHEADER)
	bih.biWidth = sWidth
	bih.biHeight = sHeight
	bih.biPlanes = 1
	bih.biBitCount = 24        ' 24位RGB / 24-bit RGB
	bih.biCompression = BI_RGB ' 无压缩 / No compression
	bih.biSizeImage = imgSize
	
	' 打开文件 / Open file
	Dim As FILE Ptr f = fopen(filename, "wb")
	If f = 0 Then 
		Print "错误: 无法创建文件 / Error: Cannot create file: "; filename
		Return 0
	End If
	
	' 写入文件头和信息头 / Write file header and info header
	fwrite(@bfh, SizeOf(bfh), 1, f)
	fwrite(@bih, SizeOf(bih), 1, f)
	
	' 分配行缓冲区 / Allocate row buffer
	Dim As UByte Ptr row = Cast(UByte Ptr, CAllocate(stride))
	If row = 0 Then
		fclose(f)
		Print "错误: 内存分配失败 / Error: Memory allocation failed"
		Return 0
	End If
	
	' 写入像素数据 / Write pixel data
	Dim As Long y, srcLine
	For y = 0 To sHeight - 1
		If topDownFlag = 0 Then
			srcLine = y          ' 从下到上 / Bottom-up
		Else
			srcLine = sHeight - 1 - y  ' 从上到下 / Top-down
		End If
		
		memset(row, 0, stride)  ' 清空行缓冲区 / Clear row buffer
		memcpy(row, pBits + srcLine * srcStride, srcStride)  ' 拷贝数据 / Copy data
		fwrite(row, 1, stride, f)  ' 写入文件 / Write to file
	Next
	
	' 清理资源 / Cleanup resources
	Deallocate(row)
	fclose(f)
	
	Print "BMP文件保存成功 / BMP file saved successfully: "; filename; " 大小/Size: "; sWidth; "x"; sHeight
	Return 1
End Function

' 捕获当前帧到文件 / Capture Current Frame to File
Function TPlayerGrab.CaptureFrame(ByVal filename As String) As Integer
	If frameLen <= 0 Then 
		Print "错误: 无可用帧数据 / Error: No frame data available"
		Return 0
	End If
	
	If TryEnterCriticalSection(@csFrame) Then
		If frameLen > 0 And UBound(frameData) >= 0 Then
			shotCount += 1
			Dim As String fname = filename
			If fname = "" Then fname = "snapshot_" & Right("000" & Str(shotCount), 3) & ".bmp"
			
			Dim As Long srcStride = frameWidth * 3  ' RGB24每行字节数 / Bytes per row for RGB24
			If SaveRGB24AsBMP(fname, @frameData(0), srcStride, _
				frameWidth, frameHeight, sourceTopDown) Then
				LeaveCriticalSection(@csFrame)
				Return 1
			End If
		End If
		LeaveCriticalSection(@csFrame)
	End If
	Print "错误: 捕获帧失败 / Error: Failed to capture frame"
	Return 0
End Function

' 属性访问 / Property Access
Property TPlayerGrab.GetWidth() As Long
	Return frameWidth
End Property

Property TPlayerGrab.GetHeight() As Long
	Return frameHeight
End Property

Property TPlayerGrab.IsOpen() As Integer
	Return isInitialized
End Property

' ===============================================================
' 主程序 - 使用示例 / Main Program - Usage Example
' ===============================================================

' 测试程序 / Test Program
Sub TestVideoPlayer()
	Print "=== DirectShow 视频播放器测试 / DirectShow Video Player Test ==="
	
	' 初始化COM库 / Initialize COM library
	CoInitialize(NULL)
	
	Dim player As TPlayerGrab
	Dim As WString * 512 filePath = "F:\OfficePC_Update\!Media\632734Y0314.mp4"  ' 修改为你的视频文件路径 / Change to your video file path
	
	' 使用控制台窗口作为视频显示窗口 / Use console window as video display window
	Dim As HWND hwnd = GetConsoleWindow()
	
	If player.Open(hwnd, filePath) Then
		Print "*** 视频打开成功! / Video opened successfully! ***"
		Print "分辨率 / Resolution: "; player.GetWidth; " x "; player.GetHeight
		
		player.Run()
		Print "控制指令 / Controls:"
		Print "  [SPACE] - 截图 / Capture screenshot"
		Print "  [ESC]   - 退出 / Exit"
		Print "----------------------------------------"
		
		Do
			Dim key As String = Inkey
			If key = Chr(27) Then Exit Do  ' ESC键退出 / ESC key to exit
			If key = " " Then
				If player.CaptureFrame("") Then
					Print "*** 截图保存成功! / Screenshot saved successfully! ***"
				Else
					Print "*** 截图失败! / Screenshot failed! ***"
				End If
			End If
			Sleep(50)
		Loop
		
		player.Close()
		Print "*** 播放器已关闭 / Player closed ***"
	Else
		Print "*** 视频打开失败! / Video opening failed! ***"
		Print "请检查文件路径和DirectShow支持 / Please check file path and DirectShow support"
	End If
	
	' 反初始化COM库 / Uninitialize COM library
	CoUninitialize()
	Print "=== 测试结束 / Test Finished ==="
End Sub

' 取消注释以运行测试 / Uncomment to run test
'TestVideoPlayer()