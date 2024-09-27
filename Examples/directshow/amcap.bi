'AMCap摄像头捕捉
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "win/amvideo.bi"
#include once "win/mmreg.bi"
#include once "win/mmsystem.bi"
#include once "crt/fcntl.bi"
#include once "win/dbt.bi"
#include once "win/msacm.bi"
#include once "win/mmsystem.bi"
#include once "win/d3d9types.bi"
#include once "win/dsound.bi"
#include once "win/dshow.bi"
#include once "win/winbase.bi"
#include once "win/winnt.bi"
#include once "win/strmif.bi"
#include once "win/control.bi"
#include once "win/windowsx.bi"

#define SAFE_RELEASE(p) If (p) Then (p)->lpVtbl->Release((p)) : (p) = NULL
#define SAFE_DELETE(p) If (p) Then Delete (p) : (p) = NULL

'wCapFileSize
'If (gcap.pCapture->AllocCapFile(T2W(gcap.szCaptureFile),
'    (DWORDLONG)gcap.wCapFileSize * 1024L * 1024L)

'fUseTimeLimit
'DWORD dwTimeLimit
'If ((timeGetTime() - gcap.lCapStartTime) / 1000 >=
'                    gcap.dwTimeLimit) {
'    StopCapture();

'fUseFrameRate
'Double FrameRate
'hr = gcap.fUseFrameRate ? E_FAIL : NOERROR;
'If (gcap.pVSC && gcap.fUseFrameRate) {
'hr = gcap.pVSC->GetFormat(&pmt);
'// DV capture does Not use a VIDEOINFOHEADER
'    If (hr == NOERROR) {
'    If (pmt->formattype == FORMAT_VideoInfo) {
'        VIDEOINFOHEADER *pvi = (VIDEOINFOHEADER *)pmt->pbFormat;
'        pvi->AvgTimePerFrame = (LONGLONG)(10000000 / gcap.FrameRate);
'        hr = gcap.pVSC->SetFormat(pmt);
'    }
'    DeleteMediaType(pmt);
'    }
'}

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
Dim Shared As IBasicVideo2 Ptr pBV2 = NULL
Dim Shared As IAMDroppedFrames Ptr pDF = NULL
Dim Shared As ISpecifyPropertyPages Ptr pSpec
Dim Shared As CAUUID pcauuid

'set master stream
Dim Shared As Long mStream
Dim Shared As WString Ptr pAviFile
Dim Shared lWidth As Long
Dim Shared lHeight As Long
Dim Shared hPreviewhWnd As HANDLE= 0
Dim Shared As Long lTime, lCapStartTime

#ifndef __USE_MAKE__
	#include once "amcap.bas"
#endif

