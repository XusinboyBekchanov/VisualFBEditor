'AMCap摄像头捕捉
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "amcap.bi"

Private Function PreviewResize() As HRESULT
	If hPreviewhWnd = NULL Or pVW = NULL Then Return False
	Dim hr As HRESULT
	Dim As Rect rc
	'Use helper function to position video window in client rect
	'of main application window
	
	'Make the preview video fill our window
	GetClientRect(Cast(HWND, hPreviewhWnd), @rc)
	
	'Resize the video preview window to match owner window size
	hr = pVW->lpVtbl->SetWindowPosition(pVW, 0, 0, rc.Right, rc.Bottom)
	Return hr
End Function

Private Function EnumDev1(ByVal IidDev As Const IID Const Ptr, ByVal Idx As Integer = 0, Dev As IBaseFilter Ptr Ptr) As Integer
	Dim hr As HRESULT
	Dim pCreateDevEnum As ICreateDevEnum Ptr
	hr = CoCreateInstance(@CLSID_SystemDeviceEnum, NULL, CLSCTX_INPROC_SERVER, @IID_ICreateDevEnum, @pCreateDevEnum)
	If hr <> NOERROR Then Return -1
	
	Dim pEnumMoniker As IEnumMoniker Ptr
	Dim pMoniker As IMoniker Ptr
	
	hr = pCreateDevEnum->lpVtbl->CreateClassEnumerator(pCreateDevEnum, IidDev, @pEnumMoniker, 0)
	If hr <> S_OK Then Return -2
	
	Dim pBaseFilter As IBaseFilter Ptr
	Dim pPropertyBag As IPropertyBag Ptr
	Dim cFetched As ULong
	Dim pFName As VARIANT
	Dim pClsidStr As VARIANT
	
	Dim i As Integer = 0
	
	Do
		hr = pEnumMoniker->lpVtbl->Next(pEnumMoniker, 1, @pMoniker, @cFetched)
		If hr <> S_OK Then Exit Do
		If i = Idx Then
			hr = pMoniker->lpVtbl->BindToObject(pMoniker, 0, 0, @IID_IBaseFilter, @pBaseFilter)
			If hr <> S_OK Then Exit Do
			Dim dpname As WString Ptr
			pMoniker->lpVtbl->GetDisplayName(pMoniker, 0, 0, @dpname)
			If hr <> S_OK Then Exit Do
			hr = pMoniker->lpVtbl->BindToStorage(pMoniker, 0, 0, @IID_IPropertyBag, @pPropertyBag)
			If hr <> S_OK Then Exit Do
			hr = pPropertyBag->lpVtbl->Read(pPropertyBag, "FriendlyName", @pFName, 0)
			If hr <> S_OK Then Exit Do
			hr = pPropertyBag->lpVtbl->Read(pPropertyBag, "CLSID", @pClsidStr, 0)
			If hr <> S_OK Then Exit Do
			Dim pClsid As CLSID Ptr = New CLSID
			hr = CLSIDFromString(pClsidStr.bstrVal, pClsid)
			If hr <> S_OK Then Exit Do
			
			'Print "GetDisplayName: " & *dpname
			'Print "pMoniker      : " & pMoniker
			'Print "pBaseFilter   : " & pBaseFilter
			'Print "FriendlyName  : " & *Cast(WString Ptr, pFName.bstrVal)
			'Print "CLSID         : " & *Cast(WString Ptr, pClsidStr.bstrVal)
			'Print "Selected      : " & Idx
			
			*Dev = pBaseFilter
			SysFreeString(pFName.bstrVal)
			SysFreeString(pClsidStr.bstrVal)
			CoTaskMemFree(dpname)
			SAFE_RELEASE(pPropertyBag)
		End If
		'SAFE_RELEASE(pMoniker)
		i += 1
	Loop
	SAFE_RELEASE(pEnumMoniker)
	SAFE_RELEASE(pCreateDevEnum)
	Return i
End Function

Private Function CaptureBmp(filename As ZString Ptr) As HRESULT
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
	Dim As FILTER_STATE pfs
	Do
		hr = pMC->lpVtbl->GetState(pMC, NULL, @pfs)
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

Private Sub DialogAudioFormat(ByVal hwndOwner As HWND)
	Dim hr As HRESULT
	Dim As AM_MEDIA_TYPE Ptr pmt
	Dim As ACMFORMATCHOOSE cfmt
	Dim As DWORD dwSize
	Dim As LPWAVEFORMATEX lpwfx
	
	If pASC Then
		
		' What's the largest format size around?
		acmMetrics(NULL, ACM_METRIC_MAX_SIZE_FORMAT, @dwSize)
		hr = pASC->lpVtbl->GetFormat(pASC, @pmt)
		lpwfx = Cast(LPWAVEFORMATEX, pmt->pbFormat)
		dwSize = Max(dwSize, lpwfx->cbSize + SizeOf(WAVEFORMATEX))
		
		' !!! This doesn't really map to the supported formats of the filter.
		' We should be Using a Property page based On IAMStreamConfig
		' Put up a dialog box initialized With the current Format
		
		CopyMemory(lpwfx, pmt->pbFormat, pmt->cbFormat)
		memset(@cfmt, 0, SizeOf(ACMFORMATCHOOSE))
		cfmt.cbStruct = SizeOf(ACMFORMATCHOOSE)
		cfmt.fdwStyle = ACMFORMATCHOOSE_STYLEF_INITTOWFXSTRUCT
		' show only formats we can capture
		cfmt.fdwEnum = ACM_FORMATENUMF_HARDWARE Or ACM_FORMATENUMF_INPUT
		cfmt.hwndOwner = hwndOwner
		cfmt.pwfx = lpwfx
		cfmt.cbwfx = dwSize
		
		hr = ACMFORMATCHOOSE(@cfmt)
		Print "ACMFORMATCHOOSE", hr
		Select Case hr
		Case ACMERR_CANCELED
			Print "ACMERR_CANCELED", hr
		Case ACMERR_NOTPOSSIBLE
			Print "ACMERR_NOTPOSSIBLE", hr
		Case MMSYSERR_INVALFLAG
			Print "MMSYSERR_INVALFLAG", hr
		Case MMSYSERR_INVALHANDLE
			Print "MMSYSERR_INVALHANDLE", hr
		Case MMSYSERR_INVALPARAM
			Print "MMSYSERR_INVALPARAM", hr
		Case MMSYSERR_NODRIVER
			Print "MMSYSERR_NODRIVER", hr
		End Select
		
		If (hr = NULL) Then
			pASC->lpVtbl->SetFormat(pASC,pmt) ' filter will reconnect
		End If
		
		GlobalFreePtr(lpwfx)
	End If
End Sub

Private Sub DialogAudioFilter(ByVal hwndOwner As HWND)
	Dim hr As HRESULT
	If pACap Then
		SAFE_RELEASE(pSpec)
		hr = pACap->lpVtbl->QueryInterface(pACap, @IID_ISpecifyPropertyPages, @pSpec)
		hr = pSpec->lpVtbl->GetPages(pSpec, @pcauuid)
		If pcauuid.cElems > 0 Then
			Print "(3). Audio Capture Filter..."
			hr = OleCreatePropertyFrame(hwndOwner, 30, 30, NULL, 1, @Cast(IUnknown Ptr, pACap), pcauuid.cElems, Cast(GUID Ptr, pcauuid.pElems), 0, 0, NULL)
		End If
	End If
End Sub

Private Sub DialogVideoFilter(ByVal hwndOwner As HWND)
	Dim hr As HRESULT
	If pVCap Then
		SAFE_RELEASE(pSpec)
		hr = pVCap->lpVtbl->QueryInterface(pVCap, @IID_ISpecifyPropertyPages, @pSpec)
		hr = pSpec->lpVtbl->GetPages(pSpec, @pcauuid)
		If pcauuid.cElems > 0 Then
			Print "(1). Video Capture Filter..."
			hr = OleCreatePropertyFrame(hwndOwner, 30, 30, NULL, 1, @Cast(IUnknown Ptr, pVCap), pcauuid.cElems, Cast(GUID Ptr, pcauuid.pElems), 0, 0, NULL)
		End If
	End If
End Sub

Private Sub DialogVideoPin(ByVal hwndOwner As HWND)
	Dim hr As HRESULT
	
	If pVSC Then
		SAFE_RELEASE(pSpec)
		hr = pVSC->lpVtbl->QueryInterface(pVSC, @IID_ISpecifyPropertyPages, @pSpec)
		hr = pSpec->lpVtbl->GetPages(pSpec, @pcauuid)
		If pcauuid.cElems > 0 Then
			Print "(2). IID_IAMStreamConfig Video Capture Pin..."
			hr = OleCreatePropertyFrame(hwndOwner, 30, 30, NULL, 1, @Cast(IUnknown Ptr, pVSC), pcauuid.cElems, Cast(GUID Ptr, pcauuid.pElems), 0, 0, NULL)
		End If
	End If
End Sub

Private Sub Initial(ByVal bPreview As Boolean = True, ByVal bCapture As Boolean = True)
	Dim As AM_MEDIA_TYPE Ptr pmt
	Dim As HRESULT hr
	
	hr = CoCreateInstance(@CLSID_FilterGraph, NULL, CLSCTX_INPROC, @IID_IGraphBuilder, @pGraph)
	Print "2. create filter graph: " & hr
	
	hr = CoCreateInstance(@CLSID_CaptureGraphBuilder2, NULL, CLSCTX_INPROC, @IID_ICaptureGraphBuilder2, @pCapture)
	Print "3. create capture graph builder: " & hr
	
	hr = pCapture->lpVtbl->SetFiltergraph(pCapture, pGraph)
	Print "4. set filter graph: " & hr
	
	If pVCap Then
		hr = pGraph->lpVtbl->AddFilter(pGraph, pVCap, @WStr("Video Capture"))
		Print "6. add video input device filter: " & hr
		
		'we use this interface to set the frame rate and get the capture size
		hr = pCapture->lpVtbl->FindInterface(pCapture, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Interleaved, pVCap, @IID_IAMStreamConfig, @pVSC)
		Print "6.1. pCapture->lpVtbl->FindInterface(pCapture, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Interleaved, pVCap, @IID_IAMStreamConfig, @pVSC): " & hr
		If (FAILED(hr)) Then
			hr = pCapture->lpVtbl->FindInterface(pCapture, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Video, pVCap, @IID_IAMStreamConfig, @pVSC)
			Print "6.2. pCapture->lpVtbl->FindInterface(pCapture, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Video, pVCap, @IID_IAMStreamConfig, @pVSC): " & hr
		End If
		hr = pVSC->lpVtbl->GetFormat(pVSC, @pmt)
		Print "6.3. pASC->lpVtbl->GetFormat(pASC, @pmt): " & hr
		hr = pVSC->lpVtbl->SetFormat(pVSC, pmt)
		Print "6.4. pASC->lpVtbl->SetFormat(pASC, pmt): " & hr
		
		Dim As IAMCrossbar Ptr pX = NULL, pX2 = NULL
		Dim As IBaseFilter Ptr pXF = NULL
		hr = pCapture->lpVtbl->FindInterface(pCapture, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Interleaved, pVCap, @IID_IAMCrossbar, @pX)
		If (hr <> NOERROR) Then
			hr = pCapture->lpVtbl->FindInterface(pCapture, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Video, pVCap, @IID_IAMCrossbar, @pX)
		End If
		Print "(5). IID_IAMCrossbar" & hr, pX
		If hr = 0 Then
			hr = pX->lpVtbl->QueryInterface(pX, @IID_IBaseFilter, @pXF)
			SAFE_RELEASE(pSpec)
			hr = pX2->lpVtbl->QueryInterface(pX2, @IID_ISpecifyPropertyPages, @pSpec)
			Print "(5.1). pX2->lpVtbl->QueryInterface(pX2, @IID_ISpecifyPropertyPages, @pSpec): " & hr
			If pSpec Then
				hr = pSpec->lpVtbl->GetPages(pSpec, @pcauuid)
				If pcauuid.cElems > 0 Then
					hr = OleCreatePropertyFrame(NULL, 30, 30, NULL, 1, @Cast(IUnknown Ptr, pX2), pcauuid.cElems, Cast(GUID Ptr, pcauuid.pElems), 0, 0, NULL)
				End If
			Else
				Print "(5.1). Not work, Oops..."
			End If
			
			hr = pCapture->lpVtbl->FindInterface(pCapture, @LOOK_UPSTREAM_ONLY, NULL, pXF, @IID_IAMCrossbar, @pX2)
			
			SAFE_RELEASE(pSpec)
			hr = pX2->lpVtbl->QueryInterface(pX2, @IID_ISpecifyPropertyPages, @pSpec)
			Print "(5.2). pX2->lpVtbl->QueryInterface(pX2, @IID_ISpecifyPropertyPages, @pSpec): " & hr
			If pSpec Then
				hr = pSpec->lpVtbl->GetPages(pSpec, @pcauuid)
				If pcauuid.cElems > 0 Then
					hr = OleCreatePropertyFrame(NULL, 30, 30, NULL, 1, @Cast(IUnknown Ptr, pX2), pcauuid.cElems, Cast(GUID Ptr, pcauuid.pElems), 0, 0, NULL)
				End If
			Else
				Print "(5.2). Not work, Oops..."
			End If
		Else
			Print "(5). Not work, Oops..."
		End If
		
		Dim As IAMTVTuner Ptr pTV = NULL
		hr = pCapture->lpVtbl->FindInterface(pCapture, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Audio, pVCap, @IID_IAMTVTuner, @pTV)
		Print "(7). IID_IAMTVTuner" & hr, pTV
		If hr = 0 Then
			SAFE_RELEASE(pSpec)
			hr = pTV->lpVtbl->QueryInterface(pTV, @IID_ISpecifyPropertyPages, @pSpec)
			Print "(7). pTVA->lpVtbl->QueryInterface(pTV, @IID_ISpecifyPropertyPages, @pSpec): " & hr
			If pSpec Then
				hr = pSpec->lpVtbl->GetPages(pSpec, @pcauuid)
				If pcauuid.cElems > 0 Then
					hr = OleCreatePropertyFrame(NULL, 30, 30, NULL, 1, @Cast(IUnknown Ptr, pTV), pcauuid.cElems, Cast(GUID Ptr, pcauuid.pElems), 0, 0, NULL)
				End If
			Else
				Print "(7). Not work, Oops..."
			End If
		Else
			Print "(7). Not work, Oops..."
		End If
		
		'we use this interface to bring up the 3 dialogs
		hr = pCapture->lpVtbl->FindInterface(pCapture, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Video, pVCap, @IID_IAMVfwCaptureDialogs, @pDlg)
		Print "16.1. pCapture->lpVtbl->FindInterface(pCapture, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Video, pVCap, @IID_IAMVfwCaptureDialogs, @pDlg): " & hr
		Print "16.1. pDlg: " & pDlg
		If FAILED(hr) Then
			hr = pCapture->lpVtbl->FindInterface(pCapture, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Interleaved, pVCap, @IID_IAMVfwCaptureDialogs, @pDlg)
			Print "16.2. pCapture->lpVtbl->FindInterface(pCapture, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Interleaved, pVCap, @IID_IAMVfwCaptureDialogs, @pDlg): " & hr
			Print "16.2. pDlg: " & pDlg
		End If
	End If
	
	If pACap Then
		hr = pGraph->lpVtbl->AddFilter(pGraph, pACap, @WStr("Audio Capture"))
		Print "8. add audio input device filter: " & hr
		
		Dim As IAMTVAudio Ptr pTVA = NULL
		hr = pCapture->lpVtbl->FindInterface(pCapture, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Audio, pACap, @IID_IAMTVAudio, @pTVA)
		Print "(6). IID_IAMTVAudio" & hr, pTVA
		If hr = 0 Then
			SAFE_RELEASE(pSpec)
			hr = pTVA->lpVtbl->QueryInterface(pTVA, @IID_ISpecifyPropertyPages, @pSpec)
			Print "(5). pTVA->lpVtbl->QueryInterface(pTVA, @IID_ISpecifyPropertyPages, @pSpec): " & hr
			If pSpec Then
				hr = pSpec->lpVtbl->GetPages(pSpec, @pcauuid)
				If pcauuid.cElems > 0 Then
					hr = OleCreatePropertyFrame(NULL, 30, 30, NULL, 1, @Cast(IUnknown Ptr, pTVA), pcauuid.cElems, Cast(GUID Ptr, pcauuid.pElems), 0, 0, NULL)
				End If
			Else
				Print "(6). Not work, Oops..."
			End If
		Else
			Print "(6). Not work, Oops..."
		End If
		
		'choose an audio capture format using ACM
		hr = pCapture->lpVtbl->FindInterface(pCapture, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Audio, pACap, @IID_IAMStreamConfig, @pASC)
		Print "8.1. pCapture->lpVtbl->FindInterface(@PIN_CATEGORY_CAPTURE, @MEDIATYPE_Audio, pACap, @IID_IAMStreamConfig, @pASC): " & hr
		SAFE_RELEASE(pSpec)
		hr = pASC->lpVtbl->QueryInterface(pASC, @IID_ISpecifyPropertyPages, @pSpec)
		Print "pASC->lpVtbl->QueryInterface(pASC, @IID_ISpecifyPropertyPages, @pSpec): " & hr
		If pSpec Then
			hr = pSpec->lpVtbl->GetPages(pSpec, @pcauuid)
			If pcauuid.cElems > 0 Then
				Print "(4). Sound selection ..."
				hr = OleCreatePropertyFrame(NULL, 30, 30, NULL, 1, @Cast(IUnknown Ptr, pASC), pcauuid.cElems, Cast(GUID Ptr, pcauuid.pElems), 0, 0, NULL)
			End If
		Else
			Print "(4). Not work, Oops..."
		End If
		
		hr = pASC->lpVtbl->GetFormat(pASC, @pmt)
		Print "8.2. pASC->lpVtbl->GetFormat(pASC, @pmt): " & hr
		hr = pASC->lpVtbl->SetFormat(pASC, pmt)
		Print "8.3. pASC->lpVtbl->SetFormat(pASC, pmt): " & hr
		
	End If
	
	If bCapture Then
		
		hr = pCapture->lpVtbl->SetOutputFileName(pCapture, @MEDIASUBTYPE_Avi, pAviFile, @pRender, @pSink)
		Print "9. SetOutputFileName: " & hr
		
		hr = pRender->lpVtbl->QueryInterface(pRender, @IID_IConfigAviMux, @pConfigAviMux)
		Print "10. pRender->lpVtbl->QueryInterface(pRender, @IID_IConfigAviMux, @pConfigAviMux): " & pConfigAviMux & ", : " & hr
		
		hr = pConfigAviMux->lpVtbl->SetOutputCompatibilityIndex(pConfigAviMux, True)
		Print "11. pConfigAviMux->lpVtbl->SetOutputCompatibilityIndex(pConfigAviMux, True): " & hr
		
		'Set Master Stream
		If mStream < 0 Then
		Else
			hr = pConfigAviMux->lpVtbl->SetMasterStream(pConfigAviMux, mStream) '-1-NOMASTER,0-VIDEOMASTER,1-AUDIOMASTER
			Print "12. pConfigAviMux->lpVtbl->SetMasterStream(pConfigAviMux, 0): " & hr
		End If
		
		If pVCap Then
			hr = pCapture->lpVtbl->RenderStream(pCapture, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Interleaved, Cast(IUnknown Ptr, pVCap), NULL, pRender)
			Print "13.1. render video stream: " & hr
			If (FAILED(hr)) Then
				hr = pCapture->lpVtbl->RenderStream(pCapture, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Video, Cast(IUnknown Ptr, pVCap), NULL, pRender)
				Print "13.2. render video stream: " & hr
			End If
			
			hr = pCapture->lpVtbl->FindInterface(pCapture, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Interleaved, pVCap, @IID_IAMDroppedFrames, @pDF)
			Print "19.1. pCapture->lpVtbl->FindInterface(pCapture, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Interleaved, pVCap, @IID_IAMDroppedFrames, @pDF): " & hr
			If (hr <> NOERROR) Then
				hr = pCapture->lpVtbl->FindInterface(pCapture, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Video, pVCap, @IID_IAMDroppedFrames, @pDF)
				Print "19.1. pCapture->lpVtbl->FindInterface(pCapture, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Video, pVCap, @IID_IAMDroppedFrames, @pDF): " & hr
			End If
		End If
		
		If pACap Then
			hr = pCapture->lpVtbl->RenderStream(pCapture, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Interleaved, Cast(IUnknown Ptr, pACap), NULL, pRender)
			If (FAILED(hr)) Then
				hr = pCapture->lpVtbl->RenderStream(pCapture, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Audio, Cast(IUnknown Ptr, pACap), NULL, pRender)
			End If
			Print "14.1. render audio stream: " & hr
		End If
		
		hr = pSink->lpVtbl->SetFileName(pSink, pAviFile, NULL)
		Print "15. pSink->lpVtbl->SetFileName: " & hr
		
	End If
	
	If bPreview Then
		If pVCap Then
			hr = pCapture->lpVtbl->RenderStream(pCapture, @PIN_CATEGORY_PREVIEW, @MEDIATYPE_Video, Cast(IUnknown Ptr, pVCap), NULL, NULL)
			Print "14.2. render video preview stream: " & hr
			
			
			'Query VideoWindow interface
			hr = pGraph->lpVtbl->QueryInterface(pGraph, @IID_IVideoWindow, @pVW)
			Print "17.2. query videowindow: " & hr
			
			hr = pVW->lpVtbl->get_Width(pVW, @lWidth)
			Print "Cannot get video window width", hr
			
			hr = pVW->lpVtbl->get_Height(pVW, @lHeight)
			Print "Cannot get video window height", hr
			
			'Set the video window to be a child of the main window
			hr = pVW->lpVtbl->put_Owner(pVW, Cast(OAHWND, hPreviewhWnd)) 'We own the window now
			Print "Cannot own the video window", hr
			
			'Set video window style
			hr = pVW->lpVtbl->put_WindowStyle(pVW, WS_CHILD Or WS_CLIPCHILDREN) 'you are now a child
			Print "Cannot set video window as child", hr
			
			'Give the preview window all our space
			hr = PreviewResize()
			
			'Query BasicVideo2 interface
			hr = pGraph->lpVtbl->QueryInterface(pGraph, @IID_IBasicVideo2, @pBV2)
			Print "17.3. query basiccideo2: " & hr
		End If
	End If
	
	'Query MediaControl interface
	hr = pGraph->lpVtbl->QueryInterface(pGraph, @IID_IMediaControl, @pMC)
	Print "17.1. query mediacontrol: " & hr
End Sub

Private Sub Terminate()
	SAFE_RELEASE(pConfigAviMux)
	SAFE_RELEASE(pRender)
	SAFE_RELEASE(pSink)
	'SAFE_RELEASE(pACap)
	'SAFE_RELEASE(pVCap)
	SAFE_RELEASE(pCapture)
	SAFE_RELEASE(pVW)
	SAFE_RELEASE(pBV2)
	SAFE_RELEASE(pMC)
	SAFE_RELEASE(pGraph)
End Sub

Private Sub AVRun()
	'Start run
	Dim hr As HRESULT
	hr = pMC->lpVtbl->Run(pMC)
	lCapStartTime = timeGetTime()
End Sub

Private Sub AVStop()
	'Stop
	Dim hr As HRESULT
	hr = pMC->lpVtbl->Stop(pMC)
End Sub

Private Function GetSize(tach As LPCTSTR) As DWORDLONG
	Dim As HANDLE HFILE = CreateFile(tach, GENERIC_READ, FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0)
	
	If (HFILE = INVALID_HANDLE_VALUE) Then
		Return 0
	End If
	
	Dim As DWORD dwSizeHigh
	Dim As DWORD dwSizeLow = GetFileSize(HFILE, @dwSizeHigh)
	
	Dim As DWORDLONG dwlSize = dwSizeLow + Cast(DWORDLONG, dwSizeHigh) Shl 32
	
	If Not(CloseHandle(HFILE)) Then
		dwlSize = 0
	End If
	
	Return dwlSize
End Function

Private Function AVStatus() As String
	Dim As Long lDropped, lNot, lAvgFrameSize
	Dim hr As HRESULT
	If pDF Then
		hr = pDF->lpVtbl->GetNumDropped(pDF, @lDropped)
		hr = pDF->lpVtbl->GetNumNotDropped(pDF, @lNot)
		hr = pDF->lpVtbl->GetAverageFrameSize(pDF, @lAvgFrameSize)
		lTime = timeGetTime() - lCapStartTime
		Return "Captured " & lNot & " freams (" & lDropped & " dropped) " & Format(lTime/ 1000, "0.000") & "sec"
	Else
		Return Format(Now, "hh:mm:ss")
	End If
End Function
