'CamGrab.bi
' Copyright (c) 2025 CM.Wang
' Freeware. Use at your own risk.
'这是一个使用DirectShow进行视频捕获的程序，主要功能包括视频预览、帧率计算和截图保存。

#include once "vbcompat.bi"
#include once "windows.bi"
#include once "win/ocidl.bi"
#include once "win/objbase.bi"
#include once "win/strmif.bi"
#include once "win/dshow.bi"
#include once "crt.bi"
#include once "win/commdlg.bi"
#include once "win/ole2.bi"
#include once "qedit.bi"

Const FPS_UPDATE_INTERVAL = 1000  ' 1秒更新一次FPS

#define SAFE_RELEASE(ComPtr) If (ComPtr <> NULL) Then Cast(IUnknown Ptr, ComPtr)->lpVtbl->Release(Cast(IUnknown Ptr, ComPtr)) : ComPtr = NULL

' ===============================================================
' SampleGrabber Callback Class Implementation
' SampleGrabber 回调类实现
' ===============================================================
Type SampleGrabberCBImpl
	' Virtual function table for ISampleGrabberCB interface ISampleGrabberCB接口的虚函数表
	lpVtbl As ISampleGrabberCBVTbl Ptr
	
	' Reference count for COM object COM对象的引用计数
	refCount As ULong
	
	' Pointer to TCamGrab instance 指向TCamGrab实例的指针
	pVideoCapture As Any Ptr
	
	' Validity flag to prevent callback during cleanup 有效性标志，防止在清理期间回调
	isValid As Long
End Type

' --------------------------
' 全局变量
' --------------------------
Dim Shared g_frameData() As UByte
Dim Shared g_frameWidth As Long = 0
Dim Shared g_frameHeight As Long = 0
Dim Shared g_gotFrame As Long = 0
Dim Shared g_hwnd As HWND = 0
Dim Shared g_hdc As HDC = 0

Dim Shared g_captureRequested As Long = 0
Dim Shared g_flipVertical As Long = 1
Dim Shared g_captureCount As Long = 0

' 帧率计算相关变量
Dim Shared g_frameCounter As Long = 0
Dim Shared g_currentFPS As Double = 0.0
Dim Shared g_lastFPSTime As Long = 0
Dim Shared g_lastFrameTime As Long = 0

' DirectShow 组件指针
Dim Shared g_pGraph As IGraphBuilder Ptr = 0
Dim Shared g_pBuild As ICaptureGraphBuilder2 Ptr = 0
Dim Shared g_pControl As IMediaControl Ptr = 0
Dim Shared g_pCap As IBaseFilter Ptr = 0
Dim Shared g_pGrabF As IBaseFilter Ptr = 0
Dim Shared g_pGrabber As ISampleGrabber Ptr = 0
Dim Shared g_pNull As IBaseFilter Ptr = 0
Dim Shared g_pCallback As Any Ptr = 0

' --------------------------
' 辅助函数声明
' --------------------------
Declare Function CreatePreviewWindow() As HWND
Declare Function CreateSampleGrabberCB() As Any Ptr
Declare Function FormatFPS(ByVal fps As Double) As String
Declare Function GetCurrentTimestamp() As String
Declare Function GetFirstCaptureDevice(ByRef ppMoniker As IMoniker Ptr Ptr) As HRESULT
Declare Function InitializeDirectShow(ByRef sMon As IMoniker Ptr = NULL) As HRESULT
Declare Function OnPainting() As LRESULT
Declare Function SaveRGB24AsBMP(ByVal filename As String, ByVal pBits As UByte Ptr, ByVal sWidth As Long, ByVal sHeight As Long) As Long
Declare Function WindowProc(ByVal HWND As HWND, ByVal uMsg As UINT, ByVal WPARAM As WPARAM, ByVal LPARAM As LPARAM) As LRESULT
Declare Sub CleanupDirectShow()
Declare Sub DisconnectFilterPins(ByVal PFILTER As IBaseFilter Ptr)
Declare Sub DisconnectFilters(ByVal pGraph As IGraphBuilder Ptr)
Declare Sub DrawOverlayInfo(ByVal x As Long, ByVal y As Long)
Declare Sub PreviewHandle(hwnd As HWND)
Declare Sub UpdateFPS()

' -------------------------
' 格式化帧率显示
' -------------------------
Function FormatFPS(ByVal fps As Double) As String
	Return "FPS: " + Format(fps, "0.00")
End Function

' -------------------------
' 更新帧率计算
' -------------------------
Sub UpdateFPS()
	Dim currentTime As Long = GetTickCount()
	g_frameCounter += 1
	
	' 每秒更新一次FPS
	If currentTime - g_lastFPSTime >= FPS_UPDATE_INTERVAL Then
		Dim elapsedSeconds As Double = (currentTime - g_lastFPSTime) / FPS_UPDATE_INTERVAL
		If elapsedSeconds > 0 Then
			g_currentFPS = g_frameCounter / elapsedSeconds
		Else
			g_currentFPS = 0
		End If
		
		g_frameCounter = 0
		g_lastFPSTime = currentTime
	End If
End Sub

' -------------------------
' 保存 RGB24 到 BMP
' -------------------------
Function SaveRGB24AsBMP(ByVal filename As String, ByVal pBits As UByte Ptr, ByVal sWidth As Long, ByVal sHeight As Long) As Long
	Dim bpp As Integer = 24
	Dim stride As Integer = ((sWidth * bpp + 31) \ 32) * 4
	Dim imgSize As Integer = stride * sHeight
	
	Dim bfh As BITMAPFILEHEADER
	Dim bih As BITMAPINFOHEADER
	memset(@bfh, 0, SizeOf(bfh))
	memset(@bih, 0, SizeOf(bih))
	
	bfh.bfType = &H4D42
	bfh.bfOffBits = SizeOf(BITMAPFILEHEADER) + SizeOf(BITMAPINFOHEADER)
	bfh.bfSize = bfh.bfOffBits + imgSize
	
	bih.biSize = SizeOf(BITMAPINFOHEADER)
	bih.biWidth = sWidth
	bih.biHeight = sHeight
	bih.biPlanes = 1
	bih.biBitCount = 24
	bih.biCompression = BI_RGB
	bih.biSizeImage = imgSize
	
	Dim f As FILE Ptr = fopen(filename, "wb")
	If f = 0 Then Return 0
	
	fwrite(@bfh, SizeOf(bfh), 1, f)
	fwrite(@bih, SizeOf(bih), 1, f)
	
	Dim inStride As Integer = sWidth * 3
	Dim row() As UByte
	ReDim row(stride - 1)
	
	' 垂直翻转图像 (bottom-up for BMP)
	For y As Long = sHeight - 1 To 0 Step -1
		Dim src As UByte Ptr = pBits + y * inStride
		memset(@row(0), 0, stride)
		memcpy(@row(0), src, inStride)
		fwrite(@row(0), 1, stride, f)
	Next
	
	fclose(f)
	Return 1
End Function

' -------------------------
' 获取当前时间戳字符串
' -------------------------
Function GetCurrentTimestamp() As String
	Dim st As SYSTEMTIME
	GetLocalTime(@st)
	Return Format(st.wYear) + "-" + _
	Format(st.wMonth, "00") + "-" + _
	Format(st.wDay, "00") + " " + _
	Format(st.wHour, "00") + ":" + _
	Format(st.wMinute, "00") + ":" + _
	Format(st.wSecond, "00")
End Function

' -------------------------
' 绘制叠加信息（时间和帧率）
' -------------------------
Sub DrawOverlayInfo(ByVal x As Long, ByVal y As Long)
	' 绘制时间戳
	Dim timestamp As WString * 1024 = GetCurrentTimestamp()
	TextOut(g_hdc, x, y, StrPtr(timestamp), Len(timestamp))
	
	' 绘制帧率信息
	Dim fpsText As WString * 1024 = FormatFPS(g_currentFPS)
	TextOut(g_hdc, x, y + 20, StrPtr(fpsText), Len(fpsText))
	
	' 绘制分辨率信息（如果有）
	If g_frameWidth > 0 And g_frameHeight > 0 Then
		Dim resText As WString * 1024 = Format(g_frameWidth) + "x" + Format(g_frameHeight)
		TextOut(g_hdc, x, y + 40, StrPtr(resText), Len(resText))
	End If
End Sub

Function SGCB_QueryInterface(ByVal pThis As Any Ptr, ByVal riid As REFIID, ByVal ppv As Any Ptr Ptr) As HRESULT
	Dim self As SampleGrabberCBImpl Ptr = Cast(SampleGrabberCBImpl Ptr, pThis)
	If ppv = 0 Then Return E_POINTER
	*ppv = 0
	If InlineIsEqualGUID(riid, @IID_IUnknown) Or InlineIsEqualGUID(riid, @IID_ISampleGrabberCB) Then
		*ppv = pThis
		self->refCount += 1
		Return S_OK
	End If
	Return E_NOINTERFACE
End Function

Function SGCB_AddRef(ByVal pThis As Any Ptr) As ULong
	Dim self As SampleGrabberCBImpl Ptr = Cast(SampleGrabberCBImpl Ptr, pThis)
	self->refCount += 1
	Return self->refCount
End Function

Function SGCB_Release(ByVal pThis As Any Ptr) As ULong
	Dim self As SampleGrabberCBImpl Ptr = Cast(SampleGrabberCBImpl Ptr, pThis)
	self->refCount -= 1
	If self->refCount = 0 Then
		Deallocate(self)
		Return 0
	End If
	Return self->refCount
End Function

Function SGCB_SampleCB(ByVal pThis As Any Ptr, ByVal SampleTime As Double, ByVal pSample As Any Ptr) As HRESULT
	Return S_OK
End Function

Function SGCB_BufferCB(ByVal pThis As Any Ptr, ByVal SampleTime As Double, ByVal pBuffer As UByte Ptr, ByVal BufferLen As Long) As HRESULT
	' 更新帧数据
	ReDim g_frameData(BufferLen - 1)
	
	' 处理画面翻转
	If g_flipVertical AndAlso g_frameWidth > 0 AndAlso g_frameHeight > 0 Then
		Dim stride As Long = g_frameWidth * 3
		For y As Long = 0 To g_frameHeight - 1
			Dim srcRow As Long = (g_frameHeight - 1 - y) * stride
			Dim dstRow As Long = y * stride
			memcpy(@g_frameData(dstRow), pBuffer + srcRow, stride)
		Next
	Else
		memcpy(@g_frameData(0), pBuffer, BufferLen)
	End If
	
	g_gotFrame = 1
	
	' 更新帧率统计
	UpdateFPS()
	
	' 处理捕获请求
	If g_captureRequested Then
		If g_frameWidth > 0 And g_frameHeight > 0 Then
			Dim expected As LongInt = CLngInt(g_frameWidth) * CLngInt(g_frameHeight) * 3
			If UBound(g_frameData) + 1 >= expected Then
				Dim timestamp As String = Format(Now)
				Dim filename As String = "capture_" + Format(g_captureCount) + "_" + _
				Format(GetTickCount()) + ".bmp"
				If SaveRGB24AsBMP(filename, @g_frameData(0), g_frameWidth, g_frameHeight) Then
					'Dim newTitle As String = *APP_TITLE + " - Saved: " + filename + " - " + FormatFPS(g_currentFPS)
					'SetWindowText(g_hwnd, StrPtr(newTitle))
					g_captureCount += 1
				End If
			End If
		End If
		g_captureRequested = 0
	End If
	
	OnPainting()
	
	Return S_OK
End Function

' 静态 vtable
Dim Shared SGCB_Vtbl As ISampleGrabberCBVTbl = ( _
Cast(Any Ptr, @SGCB_QueryInterface), _
Cast(Any Ptr, @SGCB_AddRef), _
Cast(Any Ptr, @SGCB_Release), _
Cast(Any Ptr, @SGCB_SampleCB), _
Cast(Any Ptr, @SGCB_BufferCB) _
)

Function CreateSampleGrabberCB() As Any Ptr
	Dim cb As SampleGrabberCBImpl Ptr = CAllocate(SizeOf(SampleGrabberCBImpl))
	cb->lpVtbl = @SGCB_Vtbl
	cb->refCount = 1
	Return cb
End Function

' ===============================================================
' 获取第一个可用的视频捕获设备
' ===============================================================
Function GetFirstCaptureDevice(ByRef ppMoniker As IMoniker Ptr Ptr) As HRESULT
	*ppMoniker = 0
	Dim pDevEnum As ICreateDevEnum Ptr
	Dim pEnum As IEnumMoniker Ptr
	Dim hr As HRESULT = CoCreateInstance(@CLSID_SystemDeviceEnum, 0, CLSCTX_INPROC_SERVER, @IID_ICreateDevEnum, @pDevEnum)
	If FAILED(hr) Then Return hr
	
	hr = pDevEnum->lpVtbl->CreateClassEnumerator(pDevEnum, @CLSID_VideoInputDeviceCategory, @pEnum, 0)
	If hr <> S_OK Then
		SAFE_RELEASE(pDevEnum)
		Return E_FAIL
	End If
	
	Dim pMon As IMoniker Ptr
	Dim fetched As ULong
	hr = pEnum->lpVtbl->Next(pEnum, 1, @pMon, @fetched)
	If hr = S_OK Then
		*ppMoniker = pMon
	Else
		*ppMoniker = 0
	End If
	
	SAFE_RELEASE(pEnum)
	SAFE_RELEASE(pDevEnum)
	Return hr
End Function

Sub PreviewHandle(hwnd As HWND)
	If g_hdc Then ReleaseDC(0, g_hdc)
	
	g_hwnd = hwnd
	g_hdc = GetDC(hwnd)
	
	SetBkMode(g_hdc, TRANSPARENT)
	SetStretchBltMode(g_hdc, COLORONCOLOR)
End Sub

Function OnPainting() As LRESULT
	If g_hwnd = NULL Or g_hdc = NULL Then Return 0
	
	Dim ps As PAINTSTRUCT
	
	' 绘制视频帧
	If g_gotFrame AndAlso g_frameWidth > 0 AndAlso g_frameHeight > 0 Then
		Dim bi As BITMAPINFOHEADER
		memset(@bi, 0, SizeOf(bi))
		bi.biSize = SizeOf(BITMAPINFOHEADER)
		bi.biWidth = g_frameWidth
		bi.biHeight = -g_frameHeight ' top-down
		bi.biPlanes = 1
		bi.biBitCount = 24
		bi.biCompression = BI_RGB
		
		Dim rc As Rect
		GetClientRect(g_hwnd, @rc)
		Dim windowWidth As Long = rc.Right - rc.Left
		Dim windowHeight As Long = rc.Bottom - rc.Top
		
		' 计算保持宽高比的显示区域
		Dim aspectRatio As Double = g_frameWidth / g_frameHeight
		Dim windowAspect As Double = windowWidth / windowHeight
		Dim destWidth As Long, destHeight As Long, destX As Long, destY As Long
		
		If aspectRatio > windowAspect Then
			destWidth = windowWidth
			destHeight = windowWidth / aspectRatio
			destY = (windowHeight - destHeight) \ 2
		Else
			destHeight = windowHeight
			destWidth = windowHeight * aspectRatio
			destX = (windowWidth - destWidth) \ 2
		End If
		
		StretchDIBits(g_hdc, destX, destY, destWidth, destHeight, 0, 0, g_frameWidth, g_frameHeight, @g_frameData(0), Cast(BITMAPINFO Ptr, @bi), DIB_RGB_COLORS, SRCCOPY)
		
		' 在视频画面上绘制叠加信息
		DrawOverlayInfo(destX + 10, destY + 10)
	Else
		' 无视频信号时显示提示和基本信息
		Dim wmsg As WString * 1024 = "No video signal"
		TextOut(g_hdc, 10, 10, @wmsg, Len(wmsg))
		
		DrawOverlayInfo(10, 30)
	End If
	
	Return 0
End Function

' ===============================================================
' 清理 DirectShow 资源
' ===============================================================
Sub CleanupDirectShow()
	' 首先停止图形
	If g_pControl Then
		g_pControl->lpVtbl->Stop(g_pControl)
	End If
	
	' 移除回调并释放回调对象
	If g_pGrabber Then
		g_pGrabber->lpVtbl->SetCallback(g_pGrabber, NULL, 0)
	End If
	
	SAFE_RELEASE(g_pCallback)
	
	' 断开过滤器连接
	If g_pGraph Then
		' 断开所有过滤器连接
		DisconnectFilters(g_pGraph)
	End If
	
	' 按照创建的反顺序释放资源
	' 先释放控制接口
	SAFE_RELEASE(g_pControl)
	
	' 释放 SampleGrabber 相关接口
	SAFE_RELEASE(g_pGrabber)
	
	' 释放过滤器（按照添加的反顺序）
	SAFE_RELEASE(g_pNull)
	SAFE_RELEASE(g_pGrabF)
	SAFE_RELEASE(g_pCap)
	
	' 最后释放图形构建器和图形
	SAFE_RELEASE(g_pBuild)
	SAFE_RELEASE(g_pGraph)
	
	If g_hdc Then ReleaseDC(0, g_hdc)
	g_hdc = NULL
	g_hwnd = NULL
End Sub

' ===============================================================
' 断开过滤器连接
' ===============================================================
Sub DisconnectFilters(ByVal pGraph As IGraphBuilder Ptr)
	If pGraph = NULL Then Exit Sub
	
	Dim pEnum As IEnumFilters Ptr = NULL
	Dim hr As HRESULT = pGraph->lpVtbl->EnumFilters(pGraph, @pEnum)
	
	If pEnum Then
		Dim pFilter As IBaseFilter Ptr = NULL
		Dim cFetched As ULong
		
		While pEnum->lpVtbl->Next(pEnum, 1, @pFilter, @cFetched) = S_OK
			If pFilter Then
				DisconnectFilterPins(pFilter)
				SAFE_RELEASE(pFilter)
			End If
		Wend
		
		SAFE_RELEASE(pEnum)
	End If
End Sub

' ===============================================================
' 断开过滤器的所有引脚连接
' ===============================================================
Sub DisconnectFilterPins(ByVal pFilter As IBaseFilter Ptr)
	If pFilter = NULL Then Exit Sub
	
	Dim pEnum As IEnumPins Ptr = NULL
	Dim hr As HRESULT = pFilter->lpVtbl->EnumPins(pFilter, @pEnum)
	
	If pEnum Then
		Dim pPin As IPin Ptr = NULL
		Dim cFetched As ULong
		
		While pEnum->lpVtbl->Next(pEnum, 1, @pPin, @cFetched) = S_OK
			If pPin Then
				Dim pConnected As IPin Ptr = NULL
				hr = pPin->lpVtbl->ConnectedTo(pPin, @pConnected)
				
				If pConnected Then
					' 断开连接
					pPin->lpVtbl->Disconnect(pPin)
					pConnected->lpVtbl->Disconnect(pConnected)
					SAFE_RELEASE(pConnected)
				End If
				
				SAFE_RELEASE(pPin)
			End If
		Wend
		
		SAFE_RELEASE(pEnum)
	End If
End Sub

' ===============================================================
' 初始化 DirectShow
' ===============================================================
Function InitializeDirectShow(ByRef sMon As IMoniker Ptr = NULL) As HRESULT
	Dim hr As HRESULT
	
	' 创建 FilterGraph 和 CaptureGraphBuilder2
	hr = CoCreateInstance(@CLSID_FilterGraph, NULL, CLSCTX_INPROC_SERVER, @IID_IGraphBuilder, @g_pGraph)
	If FAILED(hr) Then Return hr
	
	hr = CoCreateInstance(@CLSID_CaptureGraphBuilder2, NULL, CLSCTX_INPROC_SERVER, @IID_ICaptureGraphBuilder2, @g_pBuild)
	If FAILED(hr) Then Return hr
	
	hr = g_pBuild->lpVtbl->SetFiltergraph(g_pBuild, g_pGraph)
	If FAILED(hr) Then Return hr
	
	' 获取默认摄像头
	Dim pMon As IMoniker Ptr = sMon
	If pMon = NULL Then
		hr = GetFirstCaptureDevice(@pMon)
		If FAILED(hr) Or pMon = 0 Then Return E_FAIL
	End If
	
	hr = pMon->lpVtbl->BindToObject(pMon, NULL, NULL, @IID_IBaseFilter, @g_pCap)
	If FAILED(hr) Then Return hr

	If pMon <> sMon Then SAFE_RELEASE(pMon)
	
	hr = g_pGraph->lpVtbl->AddFilter(g_pGraph, g_pCap, WStr("Video Capture"))
	If FAILED(hr) Then Return hr
	
	' 创建 SampleGrabber filter
	hr = CoCreateInstance(@CLSID_SampleGrabber, NULL, CLSCTX_INPROC_SERVER, @IID_IBaseFilter, @g_pGrabF)
	If FAILED(hr) Then Return hr
	
	hr = g_pGrabF->lpVtbl->QueryInterface(g_pGrabF, @IID_ISampleGrabber, @g_pGrabber)
	If FAILED(hr) Then Return hr
	
	hr = g_pGraph->lpVtbl->AddFilter(g_pGraph, g_pGrabF, WStr("SampleGrabber"))
	If FAILED(hr) Then Return hr
	
	' 创建 Null Renderer
	hr = CoCreateInstance(@CLSID_NullRenderer, NULL, CLSCTX_INPROC_SERVER, @IID_IBaseFilter, @g_pNull)
	If FAILED(hr) Then Return hr
	
	hr = g_pGraph->lpVtbl->AddFilter(g_pGraph, g_pNull, WStr("Null Renderer"))
	If FAILED(hr) Then Return hr
	
	' 配置 SampleGrabber
	Dim mt As AM_MEDIA_TYPE
	memset(@mt, 0, SizeOf(mt))
	mt.majortype = MEDIATYPE_Video
	mt.subtype = MEDIASUBTYPE_RGB24
	mt.formattype = FORMAT_VideoInfo
	
	hr = g_pGrabber->lpVtbl->SetMediaType(g_pGrabber, @mt)
	If FAILED(hr) Then Return hr
	
	g_pGrabber->lpVtbl->SetBufferSamples(g_pGrabber, False)
	g_pGrabber->lpVtbl->SetOneShot(g_pGrabber, False)
	
	' 渲染捕获流
	hr = g_pBuild->lpVtbl->RenderStream(g_pBuild, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Video, Cast(IUnknown_ Ptr, g_pCap), g_pGrabF, g_pNull)
	If FAILED(hr) Then Return hr
	
	' 获取视频格式信息
	Dim connectedMT As AM_MEDIA_TYPE
	memset(@connectedMT, 0, SizeOf(connectedMT))
	
	hr = g_pGrabber->lpVtbl->GetConnectedMediaType(g_pGrabber, @connectedMT)
	If SUCCEEDED(hr) Then
		Dim pVih As VIDEOINFOHEADER Ptr = Cast(VIDEOINFOHEADER Ptr, connectedMT.pbFormat)
		If pVih <> 0 Then
			g_frameWidth = pVih->bmiHeader.biWidth
			g_frameHeight = Abs(pVih->bmiHeader.biHeight)
			g_flipVertical = IIf(pVih->bmiHeader.biHeight > 0, 1, 0)
		End If
		
		' 清理媒体类型
		If connectedMT.cbFormat <> 0 And connectedMT.pbFormat <> 0 Then
			CoTaskMemFree(connectedMT.pbFormat)
		End If
		SAFE_RELEASE(connectedMT.pUnk)
	End If
	
	' 设置回调
	g_pCallback = CreateSampleGrabberCB()
	hr = g_pGrabber->lpVtbl->SetCallback(g_pGrabber, Cast(ISampleGrabberCB_ Ptr, g_pCallback), 1)
	If FAILED(hr) Then Return hr
	
	' 获取媒体控制接口
	hr = g_pGraph->lpVtbl->QueryInterface(g_pGraph, @IID_IMediaControl, @g_pControl)
	If FAILED(hr) Then Return hr
	
	' 启动图形
	hr = g_pControl->lpVtbl->Run(g_pControl)
	
	Return hr
End Function

