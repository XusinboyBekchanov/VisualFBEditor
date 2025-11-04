' TCamGrab.bi
' Copyright (c) 2025 CM.Wang
' Freeware. Use at your own risk.
' FreeBASIC Video Capture Class using DirectShow
' 使用DirectShow的FreeBASIC视频捕获类
' Main features: Video preview, FPS calculation, screenshot capture
' 主要功能：视频预览、帧率计算、截图捕获

' Include necessary headers 包含必要的头文件
#include once "vbcompat.bi"      ' For VB compatibility functions 用于VB兼容函数
#include once "windows.bi"       ' Windows API definitions Windows API定义
#include once "win/ocidl.bi"     ' OLE component interfaces OLE组件接口
#include once "win/objbase.bi"   ' COM object base COM对象基础
#include once "win/strmif.bi"    ' DirectShow stream interfaces DirectShow流接口
#include once "win/dshow.bi"     ' DirectShow main interfaces DirectShow主接口
#include once "crt.bi"           ' C runtime functions C运行时函数
#include once "win/commdlg.bi"   ' Common dialog boxes 通用对话框
#include once "win/ole2.bi"      ' OLE 2.0 support OLE 2.0支持
#include once "qedit.bi"         ' DirectShow editing services DirectShow编辑服务

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

' ===============================================================
' Main Video Capture Class
' 视频捕获主类
' ===============================================================
Type TCamGrab
	Private:
	' Constants 常量
	Const FPS_UPDATE_INTERVAL = 1000  ' FPS update interval in ms (1 second) FPS更新间隔（1秒）
	
	' DirectShow Component Pointers DirectShow组件指针
	pGraph As IGraphBuilder Ptr           ' Filter graph manager 过滤器图形管理器
	pBuild As ICaptureGraphBuilder2 Ptr   ' Capture graph builder 捕获图形构建器
	pControl As IMediaControl Ptr         ' Media control interface 媒体控制接口
	pCap As IBaseFilter Ptr               ' Capture filter 捕获过滤器
	pGrabF As IBaseFilter Ptr             ' Sample grabber filter 采样抓取过滤器
	pGrabber As ISampleGrabber Ptr        ' Sample grabber interface 采样抓取接口
	pNull As IBaseFilter Ptr              ' Null renderer filter 空渲染器过滤器
	pCallback As SampleGrabberCBImpl Ptr  ' Sample grabber callback 采样抓取回调
	
	' Frame Data 帧数据
	frameData(Any) As UByte    ' Frame buffer data 帧缓冲区数据
	frameWidth As Long         ' Frame width in pixels 帧宽度（像素）
	frameHeight As Long        ' Frame height in pixels 帧高度（像素）
	gotFrame As Long           ' Flag indicating frame availability 帧可用性标志
	flipVertical As Long       ' Flag for vertical flip 垂直翻转标志
	
	' Window Related 窗口相关
	mhwnd As HWND    ' Preview window handle 预览窗口句柄
	mhdc As HDC      ' Device context for drawing 绘图设备上下文
	
	' Capture Control 捕获控制
	captureRequested As Long  ' Flag for capture request 捕获请求标志
	captureCount As Long      ' Count of captures 捕获计数
	
	' FPS Calculation 帧率计算
	frameCounter As Long     ' Frame counter 帧计数器
	currentFPS As Double     ' Current FPS value 当前FPS值
	lastFPSTime As Long      ' Last FPS update time 上次FPS更新时间
	lastFrameTime As Long    ' Last frame time 上次帧时间
	
	' Status Flags 状态标志
	isInitialized As Long    ' Initialization status 初始化状态标志
	isCleaningUp As Long     ' Cleanup in progress flag 清理中标志
	
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
	
	' ===============================================================
	' Internal Helper Methods
	' 内部辅助方法
	' ===============================================================
	Declare Function CreateSampleGrabberCB() As SampleGrabberCBImpl Ptr
	Declare Sub DisconnectFilterPins(ByVal pFilter As IBaseFilter Ptr)
	Declare Sub DisconnectFilters(ByVal pGraph As IGraphBuilder Ptr)
	Declare Function SaveRGB24AsBMP(ByVal filename As String, ByVal pBits As UByte Ptr, ByVal sWidth As Long, ByVal sHeight As Long) As Long
	Declare Sub DrawOverlayInfo(ByVal x As Long, ByVal y As Long)
	'Declare Sub SafeRelease(ByRef ppUnk As Any Ptr)
	
Public:
	' ===============================================================
	' Constructor and Destructor
	' 构造函数和析构函数
	' ===============================================================
	Declare Constructor()
	Declare Destructor()
	
	' ===============================================================
	' Public Interface Methods
	' 公共接口方法
	' ===============================================================
	
	' Initialize video capture with specified device
	' 使用指定设备初始化视频捕获
	Declare Function Initialize(ByVal hParentWnd As HWND = 0, ByVal sMon As IMoniker Ptr = NULL) As HRESULT
	
	' Clean up resources
	' 清理资源
	Declare Sub Cleanup()
	
	' Request frame capture
	' 请求帧捕获
	Declare Sub RequestCapture()
	
	' Update FPS calculation
	' 更新FPS计算
	Declare Sub UpdateFPS()
	
	' Handle paint event for preview window
	' 处理预览窗口的绘制事件
	Declare Function OnPaint() As LRESULT
	
	' Set preview window handle
	' 设置预览窗口句柄
	Declare Sub SetPreviewWindow(ByVal hwnd As HWND)
	
	' ===============================================================
	' Property Access Methods
	' 属性访问方法
	' ===============================================================
	
	' Get frame width
	' 获取帧宽度
	Declare Property GetFrameWidth() As Long
	
	' Get frame height
	' 获取帧高度
	Declare Property GetFrameHeight() As Long
	
	' Get current FPS
	' 获取当前FPS
	Declare Property GetCurrentFPS() As Double
	
	' Get capture count
	' 获取捕获计数
	Declare Property GetCaptureCount() As Long
	
	' Get frame data pointer
	' 获取帧数据指针
	Declare Property GetFrameData() As UByte Ptr
	
	' Check if frame is available
	' 检查帧是否可用
	Declare Property HasFrame() As Long
	
	' ===============================================================
	' Static Helper Methods
	' 静态辅助方法
	' ===============================================================
	
	' Get first available capture device
	' 获取第一个可用的捕获设备
	Declare Static Function GetFirstCaptureDevice(ByRef ppMoniker As IMoniker Ptr) As HRESULT
End Type

' ===============================================================
' Constructor and Destructor Implementation
' 构造函数和析构函数实现
' ===============================================================
Constructor TCamGrab()
	' Initialize DirectShow pointers to NULL 初始化DirectShow指针为NULL
	pGraph = NULL
	pBuild = NULL
	pControl = NULL
	pCap = NULL
	pGrabF = NULL
	pGrabber = NULL
	pNull = NULL
	pCallback = NULL
	
	' Initialize frame data 初始化帧数据
	frameWidth = 0
	frameHeight = 0
	gotFrame = 0
	flipVertical = 1  ' Default to vertical flip 默认垂直翻转
	
	' Initialize window handles 初始化窗口句柄
	mhwnd = NULL
	mhdc = NULL
	
	' Initialize capture control 初始化捕获控制
	captureRequested = 0
	captureCount = 0
	
	' Initialize FPS calculation 初始化FPS计算
	frameCounter = 0
	currentFPS = 0.0
	lastFPSTime = 0
	lastFrameTime = 0
	
	' Initialize status flags 初始化状态标志
	isInitialized = 0
	isCleaningUp = 0
	
	' Setup virtual function table for callback 设置回调虚函数表
	With SGCB_Vtbl
		.QueryInterface = Cast(Any Ptr, @SGCB_QueryInterface)
		.AddRef = Cast(Any Ptr, @SGCB_AddRef)
		.Release = Cast(Any Ptr, @SGCB_Release)
		.SampleCB = Cast(Any Ptr, @SGCB_SampleCB)
		.BufferCB = Cast(Any Ptr, @SGCB_BufferCB)
	End With
End Constructor

Destructor TCamGrab()
	' Ensure proper cleanup 确保正确清理
	Cleanup()
End Destructor

' ===============================================================
' Callback Class Implementation (Static Methods)
' 回调类实现（静态方法）
' ===============================================================

' QueryInterface implementation for COM
' COM的QueryInterface实现
Function TCamGrab.SGCB_QueryInterface(ByVal pThis As Any Ptr, ByVal riid As REFIID, ByVal ppv As Any Ptr Ptr) As HRESULT
	
	Dim self As SampleGrabberCBImpl Ptr = Cast(SampleGrabberCBImpl Ptr, pThis)
	
	' Check for null pointer 检查空指针
	If ppv = 0 Then Return E_POINTER
	*ppv = 0
	
	' Support IUnknown and ISampleGrabberCB interfaces
	' 支持IUnknown和ISampleGrabberCB接口
	If InlineIsEqualGUID(riid, @IID_IUnknown) OrElse InlineIsEqualGUID(riid, @IID_ISampleGrabberCB) Then
		*ppv = pThis
		self->refCount += 1
		Return S_OK
	End If
	
	Return E_NOINTERFACE
End Function

' AddRef implementation for COM
' COM的AddRef实现
Function TCamGrab.SGCB_AddRef(ByVal pThis As Any Ptr) As ULong
	Dim self As SampleGrabberCBImpl Ptr = Cast(SampleGrabberCBImpl Ptr, pThis)
	self->refCount += 1
	Return self->refCount
End Function

' Release implementation for COM
' COM的Release实现
Function TCamGrab.SGCB_Release(ByVal pThis As Any Ptr) As ULong
	Dim self As SampleGrabberCBImpl Ptr = Cast(SampleGrabberCBImpl Ptr, pThis)
	self->refCount -= 1
	
	' Free memory when reference count reaches zero
	' 当引用计数为零时释放内存
	If self->refCount = 0 Then
		Deallocate(self)
		Return 0
	End If
	
	Return self->refCount
End Function

' Sample callback (not used in this implementation)
' 采样回调（此实现中未使用）
Function TCamGrab.SGCB_SampleCB(ByVal pThis As Any Ptr, ByVal SampleTime As Double, ByVal pSample As Any Ptr) As HRESULT
	Return S_OK
End Function

' Buffer callback - called when new frame data is available
' 缓冲区回调 - 当新帧数据可用时调用
Function TCamGrab.SGCB_BufferCB(ByVal pThis As Any Ptr, ByVal SampleTime As Double, ByVal pBuffer As UByte Ptr, ByVal BufferLen As Long) As HRESULT
	
	Dim self As SampleGrabberCBImpl Ptr = Cast(SampleGrabberCBImpl Ptr, pThis)
	Dim pCapture As TCamGrab Ptr = Cast(TCamGrab Ptr, self->pVideoCapture)
	
	' Critical safety checks 关键安全检查
	If pCapture = NULL Then Return S_OK
	If self->isValid = 0 Then Return S_OK
	If pCapture->isCleaningUp Then Return S_OK
	If pCapture->isInitialized = 0 Then Return S_OK
	
	' Resize frame buffer to accommodate new data
	' 调整帧缓冲区大小以适应新数据
	ReDim pCapture->frameData(BufferLen - 1)
	
	' Handle vertical flip if required
	' 如果需要，处理垂直翻转
	If pCapture->flipVertical AndAlso pCapture->frameWidth > 0 AndAlso pCapture->frameHeight > 0 Then
		
		Dim stride As Long = pCapture->frameWidth * 3  ' RGB24 has 3 bytes per pixel RGB24每个像素3字节
		
		' Flip image vertically by copying rows in reverse order
		' 通过反向复制行来垂直翻转图像
		For y As Long = 0 To pCapture->frameHeight - 1
			Dim srcRow As Long = (pCapture->frameHeight - 1 - y) * stride
			Dim dstRow As Long = y * stride
			memcpy(@pCapture->frameData(dstRow), pBuffer + srcRow, stride)
		Next
	Else
		' Copy buffer directly without flipping
		' 直接复制缓冲区而不翻转
		memcpy(@pCapture->frameData(0), pBuffer, BufferLen)
	End If
	
	' Mark frame as available 标记帧为可用
	pCapture->gotFrame = 1
	
	' Update FPS statistics 更新FPS统计
	pCapture->UpdateFPS()
	
	' Handle capture request if any 处理捕获请求（如果有）
	If pCapture->captureRequested Then
		If pCapture->frameWidth > 0 And pCapture->frameHeight > 0 Then
			' Calculate expected buffer size 计算预期的缓冲区大小
			Dim expected As LongInt = CLngInt(pCapture->frameWidth) * CLngInt(pCapture->frameHeight) * 3
			
			' Save frame as BMP if buffer size matches
			' 如果缓冲区大小匹配，将帧保存为BMP
			If UBound(pCapture->frameData) + 1 >= expected Then
				Dim timestamp As String = Format(Now)
				Dim filename As String = "capture_" + Format(pCapture->captureCount) + "_" + Format(GetTickCount()) + ".bmp"
				
				If pCapture->SaveRGB24AsBMP(filename, @pCapture->frameData(0), pCapture->frameWidth, pCapture->frameHeight) Then
					
					pCapture->captureCount += 1
				End If
			End If
		End If
		pCapture->captureRequested = 0
	End If
	
	' Trigger repaint 触发重绘
	pCapture->OnPaint()
	
	Return S_OK
End Function

' ===============================================================
' Main Public Methods Implementation
' 主要公共方法实现
' ===============================================================

' Initialize video capture system
' 初始化视频捕获系统
Function TCamGrab.Initialize(ByVal hParentWnd As HWND = 0, ByVal sMon As IMoniker Ptr = NULL) As HRESULT
	
	Dim hr As HRESULT
	
	' Critical fix: Clean up if already initialized
	' 关键修复：如果已经初始化，先清理
	If isInitialized Then
		Cleanup()
	End If
	
	' Reset flags 重置标志
	isCleaningUp = 0
	isInitialized = 0
	
	' Create FilterGraph and CaptureGraphBuilder2
	' 创建FilterGraph和CaptureGraphBuilder2
	hr = CoCreateInstance(@CLSID_FilterGraph, NULL, CLSCTX_INPROC_SERVER, @IID_IGraphBuilder, @pGraph)
	
	If FAILED(hr) Then
		Cleanup()
		Return hr
	End If
	
	hr = CoCreateInstance(@CLSID_CaptureGraphBuilder2, NULL, CLSCTX_INPROC_SERVER, @IID_ICaptureGraphBuilder2, @pBuild)
	
	If FAILED(hr) Then
		Cleanup()
		Return hr
	End If
	
	hr = pBuild->lpVtbl->SetFiltergraph(pBuild, pGraph)
	If FAILED(hr) Then
		Cleanup()
		Return hr
	End If
	
	' Get default camera 获取默认摄像头
	Dim pMon As IMoniker Ptr = sMon
	If pMon = NULL Then
		hr = TCamGrab.GetFirstCaptureDevice(pMon)
		If FAILED(hr) Or pMon = 0 Then
			Cleanup()
			Return E_FAIL
		End If
	End If
	
	' Bind to capture device 绑定到捕获设备
	hr = pMon->lpVtbl->BindToObject(pMon, NULL, NULL, @IID_IBaseFilter, @pCap)
	
	' Release moniker if we created it 如果我们创建了moniker，则释放它
	If pMon <> sMon Then
		SAFE_RELEASE(pMon)
	End If
	
	If FAILED(hr) Then
		Cleanup()
		Return hr
	End If
	
	' Add capture filter to graph 将捕获过滤器添加到图形
	hr = pGraph->lpVtbl->AddFilter(pGraph, pCap, WStr("Video Capture"))
	If FAILED(hr) Then
		Cleanup()
		Return hr
	End If
	
	' Create SampleGrabber filter 创建SampleGrabber过滤器
	hr = CoCreateInstance(@CLSID_SampleGrabber, NULL, CLSCTX_INPROC_SERVER, @IID_IBaseFilter, @pGrabF)
	
	If FAILED(hr) Then
		Cleanup()
		Return hr
	End If
	
	hr = pGrabF->lpVtbl->QueryInterface(pGrabF, @IID_ISampleGrabber, @pGrabber)
	If FAILED(hr) Then
		Cleanup()
		Return hr
	End If
	
	hr = pGraph->lpVtbl->AddFilter(pGraph, pGrabF, WStr("SampleGrabber"))
	If FAILED(hr) Then
		Cleanup()
		Return hr
	End If
	
	' Create Null Renderer 创建空渲染器
	hr = CoCreateInstance(@CLSID_NullRenderer, NULL, CLSCTX_INPROC_SERVER, @IID_IBaseFilter, @pNull)
	
	If FAILED(hr) Then
		Cleanup()
		Return hr
	End If
	
	hr = pGraph->lpVtbl->AddFilter(pGraph, pNull, WStr("Null Renderer"))
	If FAILED(hr) Then
		Cleanup()
		Return hr
	End If
	
	' Configure SampleGrabber 配置SampleGrabber
	Dim mt As AM_MEDIA_TYPE
	memset(@mt, 0, SizeOf(mt))
	mt.majortype = MEDIATYPE_Video
	mt.subtype = MEDIASUBTYPE_RGB24
	mt.formattype = FORMAT_VideoInfo
	
	hr = pGrabber->lpVtbl->SetMediaType(pGrabber, @mt)
	If FAILED(hr) Then
		Cleanup()
		Return hr
	End If
	
	' Configure grabber settings 配置抓取器设置
	pGrabber->lpVtbl->SetBufferSamples(pGrabber, False)
	pGrabber->lpVtbl->SetOneShot(pGrabber, False)
	
	' Render capture stream 渲染捕获流
	hr = pBuild->lpVtbl->RenderStream(pBuild, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Video, Cast(IUnknown_ Ptr, pCap), pGrabF, pNull)
	
	If FAILED(hr) Then
		Cleanup()
		Return hr
	End If
	
	' Get video format information 获取视频格式信息
	Dim connectedMT As AM_MEDIA_TYPE
	memset(@connectedMT, 0, SizeOf(connectedMT))
	
	hr = pGrabber->lpVtbl->GetConnectedMediaType(pGrabber, @connectedMT)
	If SUCCEEDED(hr) Then
		Dim pVih As VIDEOINFOHEADER Ptr = Cast(VIDEOINFOHEADER Ptr, connectedMT.pbFormat)
		If pVih <> 0 Then
			frameWidth = pVih->bmiHeader.biWidth
			frameHeight = Abs(pVih->bmiHeader.biHeight)
			flipVertical = IIf(pVih->bmiHeader.biHeight > 0, 1, 0)
		End If
		
		' Clean up media type 清理媒体类型
		If connectedMT.cbFormat <> 0 And connectedMT.pbFormat <> 0 Then
			CoTaskMemFree(connectedMT.pbFormat)
		End If

		SAFE_RELEASE(connectedMT.pUnk)
		
	End If
	
	' Set up callback 设置回调
	pCallback = CreateSampleGrabberCB()
	If pCallback = NULL Then
		Cleanup()
		Return E_FAIL
	End If
	
	hr = pGrabber->lpVtbl->SetCallback(pGrabber, Cast(ISampleGrabberCB_ Ptr, pCallback), 1)
	
	If FAILED(hr) Then
		Cleanup()
		Return hr
	End If
	
	' Get media control interface 获取媒体控制接口
	hr = pGraph->lpVtbl->QueryInterface(pGraph, @IID_IMediaControl, @pControl)
	
	If FAILED(hr) Then
		Cleanup()
		Return hr
	End If
	
	' Set preview window 设置预览窗口
	If hParentWnd Then
		SetPreviewWindow(hParentWnd)
	End If
	
	' Start graph 启动图形
	hr = pControl->lpVtbl->Run(pControl)
	If FAILED(hr) Then
		Cleanup()
		Return hr
	End If
	
	' Mark as initialized 标记为已初始化
	isInitialized = 1
	Return hr
End Function

' Clean up all resources
' 清理所有资源
Sub TCamGrab.Cleanup()
	' Set cleanup flag 设置清理标志
	isCleaningUp = 1
	isInitialized = 0
	
	' First stop the graph 首先停止图形
	If pControl Then
		pControl->lpVtbl->Stop(pControl)
	End If
	
	' Critical fix: Remove callback first, mark callback object invalid
	' 关键修复：先移除回调，标记回调对象无效
	If pGrabber Then
		pGrabber->lpVtbl->SetCallback(pGrabber, NULL, 0)
	End If
	
	If pCallback Then
		pCallback->isValid = 0        ' Mark callback invalid 标记回调无效
		pCallback->pVideoCapture = NULL ' Disconnect 断开连接
		SAFE_RELEASE(pCallback)
	End If
	
	' Disconnect filter connections 断开过滤器连接
	If pGraph Then
		DisconnectFilters(pGraph)
	End If
	
	' Release resources in reverse order of creation
	' 按照创建的反顺序释放资源
	SAFE_RELEASE(pControl)
	SAFE_RELEASE(pGrabber)
	SAFE_RELEASE(pNull)
	SAFE_RELEASE(pGrabF)
	SAFE_RELEASE(pCap)
	SAFE_RELEASE(pBuild)
	SAFE_RELEASE(pGraph)
	
	' Release window resources 释放窗口资源
	If mhdc Then
		ReleaseDC(mhwnd, mhdc)
		mhdc = NULL
	End If
	mhwnd = NULL
	
	' Clean up frame data 清理帧数据
	Erase frameData
	frameWidth = 0
	frameHeight = 0
	gotFrame = 0
	
	' Reset cleanup flag 重置清理标志
	isCleaningUp = 0
End Sub

' ===============================================================
' Public Interface Methods Implementation
' 公共接口方法实现
' ===============================================================

' Request frame capture
' 请求帧捕获
Sub TCamGrab.RequestCapture()
	captureRequested = 1
End Sub

' Update FPS calculation
' 更新FPS计算
Sub TCamGrab.UpdateFPS()
	Dim currentTime As Long = GetTickCount()
	frameCounter += 1
	
	' Update FPS every second 每秒更新一次FPS
	If currentTime - lastFPSTime >= FPS_UPDATE_INTERVAL Then
		Dim elapsedSeconds As Double = (currentTime - lastFPSTime) / FPS_UPDATE_INTERVAL
		If elapsedSeconds > 0 Then
			currentFPS = frameCounter / elapsedSeconds
		Else
			currentFPS = 0
		End If
		
		frameCounter = 0
		lastFPSTime = currentTime
	End If
End Sub

' Set preview window handle
' 设置预览窗口句柄
Sub TCamGrab.SetPreviewWindow(ByVal hwnd As HWND)
	' Release previous DC if any 释放之前的DC（如果有）
	If mhdc Then
		ReleaseDC(mhwnd, mhdc)
	End If
	
	mhwnd = hwnd
	mhdc = GetDC(hwnd)
	
	' Setup drawing mode 设置绘图模式
	SetBkMode(mhdc, TRANSPARENT)
	SetStretchBltMode(mhdc, COLORONCOLOR)
End Sub

' Handle paint event for preview window
' 处理预览窗口的绘制事件
Function TCamGrab.OnPaint() As LRESULT
	If mhwnd = NULL Or mhdc = NULL Then Return 0
	
	' Draw video frame if available 如果有视频帧则绘制
	If gotFrame AndAlso frameWidth > 0 AndAlso frameHeight > 0 Then
		Dim bi As BITMAPINFOHEADER
		memset(@bi, 0, SizeOf(bi))
		bi.biSize = SizeOf(BITMAPINFOHEADER)
		bi.biWidth = frameWidth
		bi.biHeight = -frameHeight ' Top-down bitmap 自上而下的位图
		bi.biPlanes = 1
		bi.biBitCount = 24
		bi.biCompression = BI_RGB
		
		' Get client area 获取客户端区域
		Dim rc As RECT
		GetClientRect(mhwnd, @rc)
		Dim windowWidth As Long = rc.right - rc.left
		Dim windowHeight As Long = rc.bottom - rc.top
		
		' Calculate display area maintaining aspect ratio
		' 计算保持宽高比的显示区域
		Dim aspectRatio As Double = frameWidth / frameHeight
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
		
		' Draw the frame 绘制帧
		StretchDIBits(mhdc, destX, destY, destWidth, destHeight, 0, 0, frameWidth, frameHeight, @frameData(0), Cast(BITMAPINFO Ptr, @bi), DIB_RGB_COLORS, SRCCOPY)
		
		' Draw overlay information on video 在视频上绘制叠加信息
		DrawOverlayInfo(destX + 10, destY + 10)
	Else
		' Show message when no video signal 无视频信号时显示消息
		Dim wmsg As WString * 1024 = "No video signal"
		TextOut(mhdc, 10, 10, @wmsg, Len(wmsg))
		
		' Still show basic info 仍然显示基本信息
		DrawOverlayInfo(10, 30)
	End If
	
	Return 0
End Function

' ===============================================================
' Property Access Methods Implementation
' 属性访问方法实现
' ===============================================================

' Get frame width property
' 获取帧宽度属性
Property TCamGrab.GetFrameWidth() As Long
	Return frameWidth
End Property

' Get frame height property
' 获取帧高度属性
Property TCamGrab.GetFrameHeight() As Long
	Return frameHeight
End Property

' Get current FPS property
' 获取当前FPS属性
Property TCamGrab.GetCurrentFPS() As Double
	Return currentFPS
End Property

' Get capture count property
' 获取捕获计数属性
Property TCamGrab.GetCaptureCount() As Long
	Return captureCount
End Property

' Get frame data pointer property
' 获取帧数据指针属性
Property TCamGrab.GetFrameData() As UByte Ptr
	If UBound(frameData) >= 0 Then
		Return @frameData(0)
	Else
		Return NULL
	End If
End Property

' Check if frame is available property
' 检查帧是否可用属性
Property TCamGrab.HasFrame() As Long
	Return gotFrame
End Property

' ===============================================================
' Internal Helper Methods Implementation
' 内部辅助方法实现
' ===============================================================

' Create SampleGrabber callback object
' 创建SampleGrabber回调对象
Function TCamGrab.CreateSampleGrabberCB() As SampleGrabberCBImpl Ptr
	Dim cb As SampleGrabberCBImpl Ptr = CAllocate(SizeOf(SampleGrabberCBImpl))
	If cb = NULL Then Return NULL
	
	' Initialize callback object 初始化回调对象
	cb->lpVtbl = @SGCB_Vtbl        ' Use static vtable from type 使用类型的静态vtable
	cb->refCount = 1
	cb->pVideoCapture = @This      ' Save pointer to current instance 保存指向当前实例的指针
	cb->isValid = 1                ' Mark as valid 标记为有效
	
	Return cb
End Function

' Disconnect all pins of a filter
' 断开过滤器的所有引脚
Sub TCamGrab.DisconnectFilterPins(ByVal pFilter As IBaseFilter Ptr)
	If pFilter = NULL Then Exit Sub
	
	Dim pEnum As IEnumPins Ptr = NULL
	Dim hr As HRESULT = pFilter->lpVtbl->EnumPins(pFilter, @pEnum)
	
	If pEnum Then
		Dim pPin As IPin Ptr = NULL
		Dim cFetched As ULong
		
		' Enumerate all pins 枚举所有引脚
		While pEnum->lpVtbl->Next(pEnum, 1, @pPin, @cFetched) = S_OK
			If pPin Then
				Dim pConnected As IPin Ptr = NULL
				hr = pPin->lpVtbl->ConnectedTo(pPin, @pConnected)
				
				' Disconnect if connected 如果已连接则断开
				If pConnected Then
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

' Disconnect all filters in graph
' 断开图形中所有过滤器
Sub TCamGrab.DisconnectFilters(ByVal pGraph As IGraphBuilder Ptr)
	If pGraph = NULL Then Exit Sub
	
	Dim pEnum As IEnumFilters Ptr = NULL
	Dim hr As HRESULT = pGraph->lpVtbl->EnumFilters(pGraph, @pEnum)
	
	If pEnum Then
		Dim pFilter As IBaseFilter Ptr = NULL
		Dim cFetched As ULong
		
		' Enumerate all filters 枚举所有过滤器
		While pEnum->lpVtbl->Next(pEnum, 1, @pFilter, @cFetched) = S_OK
			If pFilter Then
				DisconnectFilterPins(pFilter)
				SAFE_RELEASE(pFilter)
			End If
		Wend
		
		SAFE_RELEASE(pEnum)
	End If
End Sub

' Save RGB24 frame as BMP file
' 将RGB24帧保存为BMP文件
Function TCamGrab.SaveRGB24AsBMP(ByVal filename As String, ByVal pBits As UByte Ptr, ByVal sWidth As Long, ByVal sHeight As Long) As Long
	
	Dim bpp As Integer = 24  ' 24 bits per pixel 每像素24位
	Dim stride As Integer = ((sWidth * bpp + 31) \ 32) * 4  ' BMP stride calculation BMP步长计算
	Dim imgSize As Integer = stride * sHeight
	
	Dim bfh As BITMAPFILEHEADER
	Dim bih As BITMAPINFOHEADER
	memset(@bfh, 0, SizeOf(bfh))
	memset(@bih, 0, SizeOf(bih))
	
	' Setup BMP file header 设置BMP文件头
	bfh.bfType = &H4D42        ' "BM" signature "BM"签名
	bfh.bfOffBits = SizeOf(BITMAPFILEHEADER) + SizeOf(BITMAPINFOHEADER)
	bfh.bfSize = bfh.bfOffBits + imgSize
	
	' Setup BMP info header 设置BMP信息头
	bih.biSize = SizeOf(BITMAPINFOHEADER)
	bih.biWidth = sWidth
	bih.biHeight = sHeight      ' Positive for bottom-up 正数表示自下而上
	bih.biPlanes = 1
	bih.biBitCount = 24
	bih.biCompression = BI_RGB
	bih.biSizeImage = imgSize
	
	' Open file for writing 打开文件进行写入
	Dim f As FILE Ptr = fopen(filename, "wb")
	If f = 0 Then Return 0
	
	' Write headers 写入头
	fwrite(@bfh, SizeOf(bfh), 1, f)
	fwrite(@bih, SizeOf(bih), 1, f)
	
	' Write pixel data with vertical flip for BMP format
	' 写入像素数据，为BMP格式进行垂直翻转
	Dim inStride As Integer = sWidth * 3
	Dim row() As UByte
	ReDim row(stride - 1)
	
	' Flip image vertically (BMP is bottom-up)
	' 垂直翻转图像（BMP是自下而上的）
	For y As Long = sHeight - 1 To 0 Step -1
		Dim src As UByte Ptr = pBits + y * inStride
		memset(@row(0), 0, stride)        ' Clear row buffer 清除行缓冲区
		memcpy(@row(0), src, inStride)    ' Copy pixel data 复制像素数据
		fwrite(@row(0), 1, stride, f)     ' Write row 写入行
	Next
	
	fclose(f)
	Return 1
End Function

' Draw overlay information on preview
' 在预览上绘制叠加信息
Sub TCamGrab.DrawOverlayInfo(ByVal x As Long, ByVal y As Long)
	' Draw timestamp 绘制时间戳
	Dim timestamp As WString * 1024 = Format(Now(), "yyyy-mm-dd hh:mm:ss")
	TextOut(mhdc, x, y, StrPtr(timestamp), Len(timestamp))
	
	' Draw FPS information 绘制FPS信息
	Dim fpsText As WString * 1024 = "FPS: " & Format(currentFPS, "0.00")
	TextOut(mhdc, x, y + 20, StrPtr(fpsText), Len(fpsText))
	
	' Draw resolution information if available
	' 如果有，绘制分辨率信息
	If frameWidth > 0 And frameHeight > 0 Then
		Dim resText As WString * 1024 = Format(frameWidth) + "x" + Format(frameHeight)
		TextOut(mhdc, x, y + 40, StrPtr(resText), Len(resText))
	End If
End Sub

' ===============================================================
' Static Helper Methods Implementation
' 静态辅助方法实现
' ===============================================================

' Get first available capture device
' 获取第一个可用的捕获设备
Function TCamGrab.GetFirstCaptureDevice(ByRef ppMoniker As IMoniker Ptr) As HRESULT
	Dim pDevEnum As ICreateDevEnum Ptr
	Dim pEnum As IEnumMoniker Ptr
	
	' Create device enumerator 创建设备枚举器
	Dim hr As HRESULT = CoCreateInstance(@CLSID_SystemDeviceEnum, 0, CLSCTX_INPROC_SERVER, @IID_ICreateDevEnum, @pDevEnum)
	
	If FAILED(hr) Then Return hr
	
	' Create class enumerator for video input devices
	' 为视频输入设备创建类枚举器
	hr = pDevEnum->lpVtbl->CreateClassEnumerator(pDevEnum, @CLSID_VideoInputDeviceCategory, @pEnum, 0)
	
	If hr <> S_OK Then
		SAFE_RELEASE(pDevEnum)
		Return E_FAIL
	End If
	
	' Get first device 获取第一个设备
	Dim fetched As ULong
	hr = pEnum->lpVtbl->Next(pEnum, 1, @ppMoniker, @fetched)
	
	' Clean up 清理
	
	SAFE_RELEASE(pEnum)
	SAFE_RELEASE(pDevEnum)
	
	Return hr
End Function

