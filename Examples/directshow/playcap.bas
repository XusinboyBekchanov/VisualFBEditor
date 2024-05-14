#pragma once
'playcap摄像设备预览和截图
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "playcap.bi"

Private Function PreviewVideo(ghApp As OAHWND) As HRESULT
	Dim As HRESULT hr
	
	' Use the System device enumerator And Class enumerator To find
	' a video capture/preview device, such As a desktop USB video camera.
	hr = EnumDevice(@CLSID_VideoInputDeviceCategory, @pVCap, @pMVideo)
	DXTRACE_MSG("find capture device", hr)
	If hr <> S_OK Then Return hr
	
	' Get DirectShow interfaces
	hr = GetInterfaces(ghApp)
	DXTRACE_MSG("get video interfaces", hr)
	
	' Attach the filter graph To the capture graph
	hr = pCapture->lpVtbl->SetFiltergraph(pCapture, pGraph)
	DXTRACE_MSG("set capture filter graph", hr)
	
	' Add Capture filter To our graph.
	hr = pGraph->lpVtbl->AddFilter(pGraph, pVCap, @WStr("Video Capture"))
	DXTRACE_MSG("add capture filter to graph", hr)
	
	hr = pCapture->lpVtbl->RenderStream(pCapture, @PIN_CATEGORY_PREVIEW, @MEDIATYPE_Video, Cast(IUnknown Ptr, pVCap), NULL, NULL)
	DXTRACE_MSG("render capture stream", hr)
	
	' Now that the filter has been added To the graph And we have
	' rendered its stream, we can release This reference To the filter.
	hr = pVCap->lpVtbl->Release(pVCap)
	DXTRACE_MSG("Release", hr)
	
	' Set video Window style And position
	hr = SetupVideoWindow(ghApp)
	DXTRACE_MSG("initialize video window", hr)
	
	' Start previewing video data
	hr = pMC->lpVtbl->Run(pMC)
	DXTRACE_MSG("run the graph", hr)
	
	Return S_OK
End Function

Private Function EnumDevice(ByVal clsidDeviceClass As Const IID Const Ptr, ppIBaseFilter As IBaseFilter Ptr Ptr, ppIMoniker As IMoniker Ptr Ptr) As HRESULT
	Dim As HRESULT hr
	Dim As IBaseFilter Ptr pVCap = NULL
	Dim As IMoniker Ptr pMVideo = NULL
	Dim As ULong cFetched
	
	' Create the system device enumerator
	Dim As ICreateDevEnum Ptr pDevEnum = NULL
	
	hr = CoCreateInstance (@CLSID_SystemDeviceEnum, NULL, CLSCTX_INPROC, @IID_ICreateDevEnum, @pDevEnum)
	DXTRACE_MSG("create system enumerator", hr)
	
	' Create an enumerator for the video capture devices
	Dim As IEnumMoniker Ptr pClassEnum = NULL
	
	hr = pDevEnum->lpVtbl->CreateClassEnumerator (pDevEnum, clsidDeviceClass, @pClassEnum, 0)
	DXTRACE_MSG("create class enumerator", hr)
	
	' If there are no enumerators for the requested type, then
	' CreateClassEnumerator will succeed, but pClassEnum will be NULL.
	If (pClassEnum = NULL) Then
		Return E_FAIL
	End If
	
	' Use the first video capture device on the device list.
	' Note that if the Next() call succeeds but there are no monikers,
	' it will return S_FALSE (which is not a failure).  Therefore, we
	' check that the return code is S_OK instead of using SUCCEEDED() macro.
	hr = pClassEnum->lpVtbl->Next (pClassEnum, 1, @pMVideo, @cFetched)
	DXTRACE_MSG("bind moniker to filter object", hr)
	If (hr = S_OK) Then
		' Bind Moniker to a filter object
		hr = pMVideo->lpVtbl->BindToObject(pMVideo, 0, 0, @IID_IBaseFilter, @pVCap)
	Else
		DXTRACE_MSG("unable to access video capture device!", hr)
		Return E_FAIL
	End If
	
	' Copy the found filter pointer to the output parameter.
	' Do NOT Release() the reference, since it will still be used
	' by the calling function.
	*ppIBaseFilter = pVCap
	*ppIMoniker = pMVideo
	Return hr
End Function

Private Function GetInterfaces(ghApp As OAHWND) As HRESULT
	Dim As HRESULT hr
	
	' Create the capture graph builder
	hr = CoCreateInstance (@CLSID_CaptureGraphBuilder2 , NULL, CLSCTX_INPROC, @IID_ICaptureGraphBuilder2, @pCapture)
	
	' Create the filter graph
	hr = CoCreateInstance (@CLSID_FilterGraph, NULL, CLSCTX_ALL, @IID_IGraphBuilder, @pGraph)
	
	' Obtain interfaces for media control and Video Window
	hr = pGraph->lpVtbl->QueryInterface(pGraph, @IID_IMediaControl, @pMC)
	hr = pGraph->lpVtbl->QueryInterface(pGraph, @IID_IVideoWindow, @pVW)
	hr = pGraph->lpVtbl->QueryInterface(pGraph, @IID_IBasicVideo2, @pBV2)
	
	Return hr
End Function

Function CaptureBmp(filename As ZString Ptr) As HRESULT
	'IBasicVideo::GetCurrentImage
	'Retrieves the current image waiting at the renderer.
	'This method fails If the renderer Is Using DirectDraw acceleration. Unfortunately,
	'This depends On the End-user's hardware configuration, so in practice this method is not reliable.
	'A better way to obtain a sample from a stream in the graph is to use the ISampleGrabber interface.
	'Todo: ISampleGrabber qedit.h not being imported on freebasic

	Dim As HRESULT hr
	
	'1, 检查pBV2是否存在
	Print "pBV2 = " & pBV2
	If pBV2 = NULL Then Return True
	
	'2, 检查视频是否在暂停状态
	'Retrieves the state of the filter graph—paused, running, or stopped.
	Dim As FILTER_STATE Ptr pfs
	Do
		hr = pMC->lpVtbl->GetState(pMC, NULL, Cast(Any Ptr, @pfs))
		Print "FILTER_STATE=" & pfs & ", " &  hr
		Select Case hr
		Case VFW_S_STATE_INTERMEDIATE
			Print "VFW_S_STATE_INTERMEDIATE"
		Case VFW_S_CANT_CUE
			Print "VFW_S_CANT_CUE"
		Case E_FAIL
			Print "E_FAIL"
			Return hr
		Case Else
		End Select
	Loop While pfs <> State_Paused
	
	'3, 获取视频宽高
	Dim As Long lHeight
	Dim As Long lWidth
	hr = pBV2->lpVtbl->GetVideoSize(pBV2, @lWidth, @lHeight)
	Print "pBV2->lpVtbl->GetVideoSize = " & hr
	If hr Then Return hr
	
	'4, 创建位图文件头
	Dim As BITMAPFILEHEADER mbitmapFileHeader
	mbitmapFileHeader.bfType = &h4D42
	mbitmapFileHeader.bfReserved1 = 0
	mbitmapFileHeader.bfReserved2 = 0
	mbitmapFileHeader.bfOffBits = SizeOf(BITMAPFILEHEADER) + SizeOf(BITMAPINFOHEADER)
	
	'5, 创建位图信息头
	Dim As BITMAPINFOHEADER mbitmapInfoHeader
	mbitmapInfoHeader.biSize = SizeOf(BITMAPINFOHEADER)
	mbitmapInfoHeader.biWidth = lWidth      ' 设置图像宽度
	mbitmapInfoHeader.biHeight = lHeight    ' 设置图像高度（可根据摄像头支持的分辨率进行调整）
	mbitmapInfoHeader.biPlanes = 1
	mbitmapInfoHeader.biBitCount = 32       ' 设置位图位数（24表示每个像素占用3字节,32表示每个像素占用4字节）
	mbitmapInfoHeader.biCompression = BI_RGB
	mbitmapInfoHeader.biSizeImage = 0
	mbitmapInfoHeader.biXPelsPerMeter = 0
	mbitmapInfoHeader.biYPelsPerMeter = 0
	mbitmapInfoHeader.biClrUsed = 0
	mbitmapInfoHeader.biClrImportant = 0
	
	Dim pBufferSize As Long ' = SizeOf(BITMAPFILEHEADER) + lHeight * lWidth * (mbitmapInfoHeader.biBitCount / 8)
	Dim pDIBImage As Long Ptr = NULL
	
	'6, 获取缓存大小和申请缓存
	hr = pBV2->lpVtbl->GetCurrentImage(pBV2, @pBufferSize, NULL)
	Print "pBV2->lpVtbl->GetCurrentImage = " & hr
	If hr Then Return hr
	pDIBImage = Cast(Long Ptr, Allocate(pBufferSize))
	
	'7, 更新位图文件头
	mbitmapFileHeader.bfSize = pBufferSize + SizeOf(BITMAPFILEHEADER)
	
	'8, Retrieves the current image waiting at the renderer.
	hr = pBV2->lpVtbl->GetCurrentImage(pBV2, @pBufferSize, pDIBImage)
	Print "pBV2->lpVtbl->GetCurrentImage = " & hr
	If hr = VFW_E_NOT_PAUSED Then
		Print "VFW_E_NOT_PAUSED"
	End If
	If hr = E_UNEXPECTED Then
		Print "E_UNEXPECTED"
	End If
	If hr Then Return hr
	
	'9, 检查文件存在和删除
	Dim As FILE Ptr fileHandle
	fileHandle = fopen(filename, @Str("rb"))
	If fileHandle Then
		fclose(fileHandle)
		remove(filename)
	End If

	'10, 写入文件
	fileHandle = fopen(filename, @Str("wb"))
	Print "fopen(filename, @Str(wb)): " & fileHandle
	If fileHandle Then
		Dim As DWORD bytesWritten = fwrite(@mbitmapFileHeader, 1, SizeOf(BITMAPFILEHEADER), fileHandle)
		bytesWritten = fwrite(@mbitmapInfoHeader, 1, SizeOf(BITMAPINFOHEADER), fileHandle)
		bytesWritten = fwrite(pDIBImage, 1, pBufferSize - SizeOf(BITMAPINFOHEADER), fileHandle)
		fclose(fileHandle)
	End If
	
	'11, 释放缓存
	Deallocate(pDIBImage)
	
	Print "CaptureBmp Success"
	
	Return 0
End Function

Private Sub CloseInterfaces()
	' Stop previewing data
	If (pMC) Then pMC->lpVtbl->StopWhenReady(pMC)
	
	' Stop receiving events
	'If (pME) Then pME->lpVtbl->SetNotifyWindow(pME, NULL, WM_GRAPHNOTIFY, 0)
	'SAFE_RELEASE(pME)
	
	' Relinquish ownership (IMPORTANT!) of the video window.
	' Failing to call put_Owner can lead to assert failures within
	' the video renderer, as it still assumes that it has a valid
	' parent window.
	If (pVW) Then
		pVW->lpVtbl->put_Visible(pVW, OAFALSE)
		pVW->lpVtbl->put_Owner(pVW, NULL)
	End If
	
	' Release DirectShow interfaces
	SAFE_RELEASE(pMVideo)
	SAFE_RELEASE(pVCap)
	SAFE_RELEASE(pMC)
	
	SAFE_RELEASE(pVW)
	SAFE_RELEASE(pBV2)
	SAFE_RELEASE(pGraph)
	SAFE_RELEASE(pCapture)
End Sub

Private Function SetupVideoWindow(ghApp As OAHWND) As HRESULT
	Dim As HRESULT hr
	
	' Set the video window to be a child of the main window
	hr = pVW->lpVtbl->put_Owner(pVW, ghApp)
	If (FAILED(hr)) Then Return hr
	
	' Set video window style
	hr = pVW->lpVtbl->put_WindowStyle(pVW, WS_CHILD Or WS_CLIPCHILDREN)
	If (FAILED(hr)) Then Return hr
	
	' Use helper function to position video window in client rect
	' of main application window
	ResizeVideoWindow(ghApp)
	
	' Make the video window visible, now that it is properly positioned
	hr = pVW->lpVtbl->put_Visible(pVW, OATRUE)
	If (FAILED(hr)) Then Return hr
	
	Return hr
End Function

Private Sub ResizeVideoWindow(ghApp As OAHWND)
	Dim As Rect rc
	
	' Make the preview video fill our window
	GetClientRect(Cast(HWND, ghApp), @rc)
	
	' Resize the video preview window to match owner window size
	If (pVW) Then pVW->lpVtbl->SetWindowPosition(pVW, 0, 0, rc.Right, rc.Bottom)
End Sub

