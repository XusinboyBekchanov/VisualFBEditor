#pragma once
'playcap摄像设备预览和截图
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "crt/stdio.bi"
#include once "win/dshow.bi"
#include once "vbcompat.bi"

Declare Function GetInterfaces(ghApp As OAHWND) As HRESULT
Declare Function CaptureVideo(ghApp As OAHWND) As HRESULT
Declare Function EnumDevice(ByVal clsidDeviceClass As Const IID Const Ptr, ppIBaseFilter As IBaseFilter Ptr Ptr, ppIMoniker As IMoniker Ptr Ptr) As HRESULT
Declare Function SetupVideoWindow(ghApp As OAHWND) As HRESULT
Declare Sub CloseInterfaces()
Declare Sub ResizeVideoWindow(ghApp As OAHWND)
Declare Function CaptureBmp(filename As ZString Ptr) As HRESULT

Dim Shared As IGraphBuilder Ptr pGraph = NULL
Dim Shared As ICaptureGraphBuilder2 Ptr pCapture = NULL
Dim Shared As IBaseFilter Ptr pVCap = NULL
Dim Shared As IBaseFilter Ptr pACap = NULL
Dim Shared As IBaseFilter Ptr pRender = NULL
Dim Shared As IFileSinkFilter Ptr pSink = NULL
Dim Shared As IMediaControl Ptr pMC = NULL
Dim Shared As IVideoWindow Ptr pVW = NULL
Dim Shared As IConfigAviMux Ptr pConfigAviMux = NULL
Dim Shared As IAMStreamConfig Ptr pASC = NULL 'For audio cap
Dim Shared As IAMStreamConfig Ptr pVSC = NULL 'For video cap
Dim Shared As IAMVfwCaptureDialogs Ptr pDlg = NULL
Dim Shared As IMoniker Ptr pMVideo = NULL
Dim Shared As IMoniker Ptr pMAudio = NULL
Dim Shared As IBasicVideo Ptr pBV = NULL
Dim Shared As IBasicVideo2 Ptr pBV2 = NULL

#define DXTRACE_ERR(Str, hr) Print "DXTRACE_ERR " & hr & ": " & Str : Return hr
#define DXTRACE_MSG(Str, hr) Print "DXTRACE_MSG " & hr & ": " & Str
#define SAFE_RELEASE(x) If (x) Then (x)->lpVtbl->Release((x)) : (x) = NULL

#ifndef __USE_MAKE__
	#include once "playcap.bas"
#endif
