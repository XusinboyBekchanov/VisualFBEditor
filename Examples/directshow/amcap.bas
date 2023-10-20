'AMCap摄像头捕捉
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

#include once "amcap.bi"

Const As LONGLONG MAX_TIME = &h7FFFFFFFFFFFFFFF   '/* Maximum LONGLONG value */

#define WM_FGNOTIFY        WM_USER + 1
#define SAFE_RELEASE(p) If (p) Then (p)->lpVtbl->Release((p)) : (p) = NULL
#define SAFE_DELETE(p) If (p) Then Delete (p) : (p) = NULL
#define HEADER(pVideoInfo) Cast(VIDEOINFOHEADER Ptr, pVideoInfo)->bmiHeader
#define DXTRACE_ERR(Str, hr) Debug.Print "DXTRACE_ERR " & hr & ": " & Str : Return hr
#define DXTRACE_RTN(Str, hr) Debug.Print "DXTRACE_RTN " & hr & ": " & Str : Return hr
#define DXTRACE_MSG(Str, hr) Debug.Print "DXTRACE_MSG " & hr & ": " & Str
#define ErrMsg(Str) Debug.Print "ErrMsg: " & Str

'Dialogs
#define IDD_ABOUT                   600
#define IDD_AllocCapFileSpace       601
#define IDD_FrameRateDialog         602
#define IDD_PressAKeyDialog         603
#define IDD_TimeLimitDialog         604

'defines For dialogs
#define IDD_SetCapFileFree          400
#define IDD_SetCapFileSize          401
#define IDC_FRAMERATE               402
#define IDC_CAPFILENAME             403
#define IDC_TIMELIMIT               404
#define IDC_USETIMELIMIT            405
#define IDC_USEFRAMERATE            406

'you can never have too many parentheses!
'#define Abs(x) (((x) > 0) ? (x) : -(x))
'
'------------------------------------------------------------------------------
'Global Data
'------------------------------------------------------------------------------
Dim Shared As HINSTANCE ghInstApp
Dim Shared As HACCEL ghAccel
Dim Shared As HFONT  ghfontApp
Dim Shared As TEXTMETRIC gtm
Dim Shared As WString Ptr gszAppName = @WStr("AMCAP")
Dim Shared As HWND ghwndStatus
Dim Shared As HWND ghwndApp
Dim Shared As HDEVNOTIFY ghDevNotify
Dim Shared gnRecurse As Integer = 0
'Dim As PUnregisterDeviceNotification gpUnregisterDeviceNotification
'Dim As PRegisterDeviceNotification gpRegisterDeviceNotification

'------------------------------------------------------------------------------
'Name: Class CClass
'Desc: This Class contains routing information For the capture Data
'------------------------------------------------------------------------------
Type CRouting
	Dim As CRouting Ptr         pLeftRouting
	Dim As CRouting Ptr         pRightRouting
	Dim As Long                 VideoInputIndex
	Dim As Long                 VideoOutputIndex
	Dim As Long                 AudioInputIndex
	Dim As Long                 AudioOutputIndex
	Dim As IAMCrossbar Ptr      pXbar
	Dim As Long                 InputPhysicalType
	Dim As Long                 OutputPhysicalType
	Dim As Long                 Depth
End Type

'------------------------------------------------------------------------------
'Name: Class CCrossbar
'Desc: The actual helper Class For Crossbars
'------------------------------------------------------------------------------
Type CCrossbar
Private:
	Dim As IPin Ptr                 m_pStartingPin
	Dim As CRouting                 m_RoutingRoot
	Dim As CRouting Ptr             m_RoutingList
	Dim As Integer                  m_CurrentRoutingIndex
	
	Declare Function BuildRoutingList(pStartingInputPin As IPin Ptr, pCRouting As CRouting Ptr, Depth As Integer) As HRESULT
	Declare Function SaveRouting (pRoutingNew As CRouting Ptr) As HRESULT
	Declare Function DestroyRoutingList() As HRESULT
	Declare Function StringFromPinType (pc As TCHAR Ptr, nSize As Integer, lType As Long) As BOOL
	Declare Function GetCrossbarIPinAtIndex(pXbar As IAMCrossbar Ptr, PinIndex As Long, IsInputPin As BOOL, ppPin As IPin Ptr Ptr) As HRESULT
	Declare Function GetCrossbarIndexFromIPin(pXbar As IAMCrossbar Ptr, PinIndex As Long Ptr, IsInputPin As BOOL, PPIN As IPin Ptr) As HRESULT
	
Public:
	Declare Constructor(ByVal PPIN As IPin Ptr)
	Declare Destructor
	Declare Function GetInputCount (pCount As Long Ptr) As HRESULT
	Declare Function GetInputType  (Index As Long, PhysicalType As Long Ptr) As HRESULT
	Declare Function GetInputName  (Index As Long, pName As TCHAR Ptr, NameSize As Long) As HRESULT
	Declare Function SetInputIndex (Index As Long) As HRESULT
	Declare Function GetInputIndex (Index As Long Ptr) As HRESULT
End Type

Type _capstuff
	Dim As WString Ptr szCaptureFile
	Dim As WORD wCapFileSize  'size in Meg
	Dim As ICaptureGraphBuilder2 Ptr pBuilder
	Dim As IVideoWindow Ptr pVW
	Dim As IMediaEventEx Ptr pME
	Dim As IAMDroppedFrames Ptr pDF
	Dim As IAMVideoCompression Ptr pVC
	Dim As IAMVfwCaptureDialogs Ptr pDlg
	Dim As IAMStreamConfig Ptr pASC      'For audio cap
	Dim As IAMStreamConfig Ptr pVSC      'For video cap
	Dim As IBaseFilter Ptr pRender
	Dim As IBaseFilter Ptr pVCap, pACap
	Dim As IGraphBuilder Ptr pFg
	Dim As IFileSinkFilter Ptr pSink
	Dim As IConfigAviMux Ptr pConfigAviMux
	Dim As Integer iMasterStream
	Dim As BOOL fCaptureGraphBuilt
	Dim As BOOL fPreviewGraphBuilt
	Dim As BOOL fCapturing
	Dim As BOOL fPreviewing
	Dim As BOOL fCapAudio
	Dim As BOOL fCapCC
	Dim As BOOL fCCAvail
	Dim As BOOL fCapAudioIsRelevant
	Dim As BOOL fDeviceMenuPopulated
	Dim As IMoniker Ptr rgpmVideoMenu(10)
	Dim As IMoniker Ptr rgpmAudioMenu(10)
	Dim As IMoniker Ptr pmVideo
	Dim As IMoniker Ptr pmAudio
	Dim As Double FrameRate
	Dim As BOOL fWantPreview
	Dim As Long lCapStartTime
	Dim As Long lCapStopTime
	Dim As WString Ptr wachFriendlyName = CAllocate(_MAX_PATH)
	Dim As BOOL fUseTimeLimit
	Dim As BOOL fUseFrameRate
	Dim As DWORD dwTimeLimit
	Dim As Integer iFormatDialogPos
	Dim As Integer iSourceDialogPos
	Dim As Integer iDisplayDialogPos
	Dim As Integer iVCapDialogPos
	Dim As Integer iVCrossbarDialogPos
	Dim As Integer iTVTunerDialogPos
	Dim As Integer iACapDialogPos
	Dim As Integer iACrossbarDialogPos
	Dim As Integer iTVAudioDialogPos
	Dim As Integer iVCapCapturePinDialogPos
	Dim As Integer iVCapPreviewPinDialogPos
	Dim As Integer iACapCapturePinDialogPos
	Dim As Long lDroppedBase
	Dim As Long lNotBase
	Dim As BOOL fPreviewFaked
	Dim As CCrossbar Ptr pCrossbar
	Dim As Integer iVideoInputMenuPos
	Dim As Long NumberOfVideoInputs
	Dim As HMENU hMenuPopup
	Dim As Integer iNumVCapDevices
End Type
Dim Shared gcap As _capstuff

'for preview
Dim Shared igb_pFg As IGraphBuilder Ptr = NULL
Dim Shared icgb2_pBuilder As ICaptureGraphBuilder2 Ptr = NULL
Dim Shared ivw_pVW As IVideoWindow Ptr = NULL
Dim Shared imc_pMC As IMediaControl Ptr = NULL

Dim Shared im_pmVideo As IMoniker Ptr
Dim Shared im_pmAudio As IMoniker Ptr

'Dim Shared pVCap() As IBaseFilter Ptr
'Dim Shared pACap() As IBaseFilter Ptr

Dim Shared pVCapCount As Integer = -1
Dim Shared pACapCount As Integer = -1

Dim Shared ibf_pVCap As IBaseFilter Ptr = NULL
Dim Shared ibf_pACap As IBaseFilter Ptr = NULL
Dim Shared ibf_pRender As IBaseFilter Ptr = NULL

'for capture
'Dim Shared icgb As ICaptureGraphBuilder Ptr = NULL
'Dim Shared ime As IMediaEvent Ptr = NULL
Dim Shared imee_pME As IMediaEventEx Ptr = NULL
Dim Shared icd_pDlg As IAMVfwCaptureDialogs Ptr = NULL
Dim Shared ivc_pVC As IAMVideoCompression Ptr = NULL
Dim Shared ifsf_pSink As IFileSinkFilter Ptr
Dim Shared icam_pConfigAviMux As IConfigAviMux Ptr
Dim Shared isc_pASC As IAMStreamConfig Ptr 'for audio cap
Dim Shared isc_pVSC As IAMStreamConfig Ptr 'for video cap
Dim Shared idf_pDF As IAMDroppedFrames Ptr

Dim Shared iMasterStream As Integer

#define WM_GRAPHNOTIFY  WM_APP + 1024

'
'------------------------------------------------------------------------------
' Funciton Prototypes
'------------------------------------------------------------------------------
'typedef Long (pascal *LPWNDPROC)(HWND, UINT, WPARAM, LPARAM) ' Pointer To a Window procedure
'Long WINAPI AppWndProc(HWND HWND, UINT uiMessage, WPARAM WPARAM, LPARAM LPARAM)
'Long pascal AppCommand(HWND HWND, Unsigned MSG, WPARAM WPARAM, LPARAM LPARAM)
'BOOL CALLBACK AboutDlgProc(HWND HWND, UINT MSG, WPARAM WPARAM, LPARAM LPARAM)
'Declare Function ErrMsg (sz As LPTSTR, ...) As Integer
Declare Function SetCaptureFile(HWND As HWND) As BOOL
Declare Function SaveCaptureFile(HWND As HWND) As BOOL
Declare Function AllocCaptureFile(HWND As HWND) As BOOL
Declare Function DoDialog(hwndParent As HWND, DialogID As Integer, fnDialog As DLGPROC, LPARAM As Long) As Integer
'Declare Function Int FAR pascal AllocCapFileProc(HWND hDlg, UINT Message, UINT WPARAM, Long LPARAM)
'Declare Function Int FAR pascal FrameRateProc(HWND hDlg, UINT Message, UINT WPARAM, Long LPARAM)
'Declare Function Int FAR pascal TimeLimitProc(HWND hDlg, UINT Message, UINT WPARAM, Long LPARAM)
'Declare Function Int FAR pascal PressAKeyProc(HWND hDlg, UINT Message, UINT WPARAM, Long LPARAM)

Declare Sub NukeDownStream(pf As IBaseFilter Ptr)
Declare Sub TearDownGraph()
Declare Function BuildCaptureGraph() As BOOL
Declare Function BuildPreviewGraph() As BOOL
Declare Sub UpdateStatus(fAllStats As BOOL)
Declare Sub AddDevicesToMenu()
'Declare Sub ChooseDevices Overload (szVideo As CHAR Ptr, szAudio As CHAR Ptr)
'Declare Sub ChooseDevices Overload (pmVideo As IMoniker Ptr, pmAudio As IMoniker Ptr)
Declare Sub ChooseFrameRate()
Declare Sub ChooseTimeLimit()
Declare Sub ChooseAudioFormat()
Declare Function InitCapFilters() As BOOL
Declare Sub FreeCapFilters()
Declare Function StopPreview() As BOOL
Declare Function StartPreview() As BOOL
Declare Function StartCapture() As BOOL
Declare Function StopCapture() As BOOL

Declare Function GetSize(tach As LPCTSTR) As DWORDLONG
Declare Sub MakeMenuOptions()


'destroy the graph downstream of our capture filters
Sub NukeDownStream2(pf As IBaseFilter Ptr)
	Dim As IPin Ptr pP, pTo
	Dim As ULong u
	Dim As IEnumPins Ptr pins = NULL
	Dim As PIN_INFO pininfo
	Dim As HRESULT hr = pf->lpVtbl->EnumPins(pf, @pins)
	pins->lpVtbl->Reset(pins)
	While (hr = NOERROR)
		hr = pins->lpVtbl->Next(pins, 1, @pP, @u)
		If (hr = S_OK And pP <> 0) Then
			pP->lpVtbl->ConnectedTo(pP, @pTo)
			If (pTo) Then
				hr = pTo->lpVtbl->QueryPinInfo(pTo, @pininfo)
				If (hr = NOERROR) Then
					If (pininfo.dir = PINDIR_INPUT) Then
						NukeDownStream(pininfo.pFilter)
						igb_pFg->lpVtbl->Disconnect(igb_pFg, pTo)
						igb_pFg->lpVtbl->Disconnect(igb_pFg, pP)
						igb_pFg->lpVtbl->RemoveFilter(igb_pFg, pininfo.pFilter)
					Else
						SAFE_RELEASE(pininfo.pFilter)
					End If
				End If
				SAFE_RELEASE(pTo)
			End If
			SAFE_RELEASE(pP)
		End If
	Wend
	SAFE_RELEASE(pins)
End Sub

'we already have another graph built... tear down the old one
Sub TearDownGraph2()
	SAFE_RELEASE(ifsf_pSink)
	SAFE_RELEASE(icam_pConfigAviMux)
	SAFE_RELEASE(ibf_pRender)
	SAFE_RELEASE(ivw_pVW)
	SAFE_RELEASE(imee_pME)
	SAFE_RELEASE(idf_pDF)
	
	'destroy the graph downstream of our capture filters
	If (ibf_pVCap) Then NukeDownStream2(ibf_pVCap)
	If (ibf_pACap) Then NukeDownStream2(ibf_pACap)
End Sub

Private Sub ChooseDevices2 Overload (pmVideo As IMoniker Ptr, pmAudio As IMoniker Ptr)
	pmVideo->lpVtbl->AddRef(pmVideo)
	pmAudio->lpVtbl->AddRef(pmAudio)
	
	SAFE_RELEASE(im_pmVideo)
	im_pmVideo = pmVideo
	SAFE_RELEASE(im_pmAudio)
	im_pmAudio = pmAudio
	
	Dim As WString Ptr displayname
	im_pmVideo->lpVtbl->GetDisplayName(im_pmVideo, 0, 0, @displayname)
	im_pmAudio->lpVtbl->GetDisplayName(im_pmAudio, 0, 0, @displayname)
	
	'StopPreview
	TearDownGraph2
	'BuildPreviewGraph
	'StartPreview
End Sub

Private Sub ChooseDevices2 Overload (wszVideo As WString Ptr, wszAudio As WString Ptr)
	Dim As IMoniker Ptr pmVideo = 0, pmAudio = 0
	Dim As IBindCtx Ptr lpBC
	Dim As HRESULT hr = CreateBindCtx(0, @lpBC)
	
	Dim As DWORD dwEaten
	hr = MkParseDisplayName(lpBC, wszVideo, @dwEaten, @pmVideo)
	hr = MkParseDisplayName(lpBC, wszAudio, @dwEaten, @pmAudio)
	
	SAFE_RELEASE(lpBC)
	
	pmVideo->lpVtbl->AddRef(pmVideo)
	pmAudio->lpVtbl->AddRef(pmAudio)
	
	SAFE_RELEASE(im_pmVideo)
	im_pmVideo = pmVideo
	SAFE_RELEASE(im_pmAudio)
	im_pmAudio = pmAudio
	
	Dim As WString Ptr displayname
	im_pmVideo->lpVtbl->GetDisplayName(im_pmVideo, 0, 0, @displayname)
	im_pmAudio->lpVtbl->GetDisplayName(im_pmAudio, 0, 0, @displayname)
	
	StopPreview
	TearDownGraph2
	'BuildPreviewGraph
	'StartPreview
End Sub


'Tear down everything downstream of a given filter
Sub StreamNukeDown(pf As IBaseFilter Ptr)
	Dim As IPin Ptr pP, pTo
	Dim As ULong u
	Dim As IEnumPins Ptr pins = NULL
	Dim As PIN_INFO pininfo
	Dim As HRESULT hr = pf->lpVtbl->EnumPins(pf, @pins)
	pins->lpVtbl->Reset(pins)
	While (hr = NOERROR)
		hr = pins->lpVtbl->Next(pins, 1, @pP, @u)
		If (hr = S_OK) And  (pP <> 0) Then
			pP->lpVtbl->ConnectedTo(pP, @pTo)
			If (pTo) Then
				hr = pTo->lpVtbl->QueryPinInfo(pTo, @pininfo)
				If (hr = NOERROR) Then
					If (pininfo.dir = PINDIR_INPUT) Then
						StreamNukeDown(pininfo.pFilter)
						igb_pFg->lpVtbl->Disconnect(igb_pFg, pTo)
						igb_pFg->lpVtbl->Disconnect(igb_pFg, pP)
						igb_pFg->lpVtbl->RemoveFilter(igb_pFg, pininfo.pFilter)
					End If
					pininfo.pFilter->lpVtbl->Release(pininfo.pFilter)
				End If
				pTo->lpVtbl->Release(pTo)
			End If
			pP->lpVtbl->Release(pP)
		End If
	Wend
	If (pins) Then pins->lpVtbl->Release(pins)
End Sub

'Tear down everything downstream of the capture filters, so we can build
'a different capture graph.  Notice that we never destroy the capture filters
'and WDM filters upstream of them, because then all the capture settings
'we've set would be lost.

Sub GraphTearDown()
	SAFE_RELEASE(ifsf_pSink)
	SAFE_RELEASE(icam_pConfigAviMux)
	SAFE_RELEASE(ibf_pRender)
	
	'stop drawing in our window, or we may get wierd repaint effects
	If ivw_pVW Then
		ivw_pVW->lpVtbl->put_Visible(ivw_pVW, OAFALSE)
		ivw_pVW->lpVtbl->put_Owner(ivw_pVW, NULL)
	End If
	SAFE_RELEASE(ivw_pVW)
	SAFE_RELEASE(imee_pME)
	SAFE_RELEASE(idf_pDF)
	
	'destroy the graph downstream of our capture filters
	If (ibf_pVCap) Then StreamNukeDown(ibf_pVCap)
	If (ibf_pACap) Then StreamNukeDown(ibf_pACap)
End Sub

Private Constructor CCrossbar(ByVal PPIN As IPin Ptr)
	': m_pStartingPin (pStartingInputPin)
	', m_CurrentRoutingIndex (0)
	', m_RoutingList (NULL)
	
	
	Dim As HRESULT hr
	
	'DbgLog((LOG_TRACE,3,TEXT("CCrossbar Constructor")));
	
	Assert(pStartingInputPin <> NULL)
	
	'Init everything To zero
	ZeroMemory (@m_RoutingRoot, SizeOf(m_RoutingRoot))
	
	If (m_RoutingList = New CRouting) Then
		'hr = BuildRoutingList(pStartingInputPin, @m_RoutingRoot, 0)
	End If
End Constructor

Private Destructor CCrossbar()
	Dim As HRESULT hr
	
	'DbgLog((LOG_TRACE, 3, TEXT("CCrossbar Destructor")))
	
	'hr = DestroyRoutingList()
	
	Delete m_RoutingList
End Destructor

''------------------------------------------------------------------------------
''Name: SetAppCaption()
''Desc: Set the caption to be the application name followed by the capture file
''------------------------------------------------------------------------------
'void SetAppCaption()
Sub SetAppCaption()
	Dim As TCHAR Ptr tach = Allocate(_MAX_PATH + 80)
	lstrcpy(tach, gszAppName)
	'    if (gcap.szCaptureFile[0] <> 0) {
	lstrcat(tach, " - ")
	lstrcat(tach, gcap.szCaptureFile)
	'    }
	SetWindowText(ghwndApp, tach)
End Sub

'/*----------------------------------------------------------------------------*\
'|   AppInit( hInst, hPrev)                                                     |
'|                                                                              |
'|   Description:                                                               |
'|       This Is called when the application Is first loaded into               |
'|       memory.  It performs all initialization that doesn't need to be done   |
'|       once per instance.                                                     |
'|                                                                              |
'|   Arguments:                                                                 |
'|       HINSTANCE       instance HANDLE of current instance                    |
'|       hPrev           instance HANDLE of previous instance                   |
'|                                                                              |
'|   Returns:                                                                   |
'|       True If successful, False If Not                                       |
'|                                                                              |
'\*----------------------------------------------------------------------------*/
'BOOL AppInit(HINSTANCE hInst, HINSTANCE hPrev, Int sw)
Function AppInit() As BOOL
	'{
	'    WNDCLASS    Cls
	'    HDC         HDC
	'
	'    Const DWORD  dwExStyle = 0
	'
	'    CoInitialize(NULL)
	'    DbgInitialise(hInst)
	'
	'    /* Save instance HANDLE For DialogBoxs */
	'    ghInstApp = hInst
	'
	'    ghAccel = LoadAccelerators(hInst, MAKEINTATOM(ID_APP))
	'
	'    If (!hPrev) {
	'	/*
	'	 *  Register a Class For the main application Window
	'	 */
	'	Cls.hCursor        = LoadCursor(NULL,IDC_ARROW)
	'	Cls.hIcon          = LoadIcon(hInst, TEXT("AMCapIcon"))
	'	Cls.lpszMenuName   = MAKEINTATOM(ID_APP)
	'	Cls.lpszClassName  = MAKEINTATOM(ID_APP)
	'	Cls.hbrBackground  = (HBRUSH)(COLOR_WINDOW + 1)
	'	cls.hInstance      = hInst
	'	cls.style          = CS_BYTEALIGNCLIENT | CS_VREDRAW | CS_HREDRAW | CS_DBLCLKS
	'	cls.lpfnWndProc    = (LPWNDPROC)AppWndProc
	'	cls.cbWndExtra     = 0
	'	cls.cbClsExtra     = 0
	'
	'	if (!RegisterClass(&cls))
	'	    return FALSE
	'    }
	'
	'    'Is this necessary?
	'    ghfontApp = (HFONT)GetStockObject(ANSI_VAR_FONT)
	'    hdc = GetDC(NULL)
	'    SelectObject(hdc, ghfontApp)
	'    GetTextMetrics(hdc, &gtm)
	'    ReleaseDC(NULL, hdc)
	'
	'    ghwndApp=CreateWindowEx(dwExStyle,
	'			    MAKEINTATOM(ID_APP),    'Class name
	'			    gszAppName,             'Caption
	'						    'Style bits
	'			    WS_OVERLAPPEDWINDOW | WS_CLIPCHILDREN,
	'			    CW_USEDEFAULT, 0,       'Position
	'			    320,300,                'Size
	'			    (HWND)NULL,             'Parent window (no parent)
	'			    (HMENU)NULL,            'use class menu
	'			    hInst,                  'handle to window instance
	'			    (LPSTR)NULL             'no params to pass on
	'			   )
	'
	'    'create the status bar
	'    statusInit(hInst, hPrev)
	'    ghwndStatus = CreateWindowEx(
	'		    0,
	'		    szStatusClass,
	'		    NULL,
	'		    WS_CHILD|WS_BORDER|WS_VISIBLE|WS_CLIPSIBLINGS,
	'		    0, 0,
	'		    0, 0,
	'		    ghwndApp,
	'		    NULL,
	'		    hInst,
	'		    NULL)
	'    if (ghwndStatus = NULL) {
	'	return(FALSE)
	'    }
	'    ShowWindow(ghwndApp,sw)
	'
	'    'Get the capture FILE Name from win.ini
	'    GetProfileString(TEXT("annie"), TEXT("CaptureFile"), TEXT(""),
	'                                        gcap.szCaptureFile,
	'					SizeOf(gcap.szCaptureFile))
	'
	'    'Get which devices To use from win.ini
	'    ZeroMemory(gcap.rgpmAudioMenu, SizeOf(gcap.rgpmAudioMenu))
	'    ZeroMemory(gcap.rgpmVideoMenu, SizeOf(gcap.rgpmVideoMenu))
	gcap.pmVideo = 0
	gcap.pmAudio = 0
	'
	'    TCHAR szVideoDisplayName[1024], szAudioDisplayName[1024]
	'    *szAudioDisplayName = *szVideoDisplayName = 0 'NULL terminate
	'
	'    GetProfileString(TEXT("annie"), TEXT("VideoDevice2"), TEXT(""),
	'                    szVideoDisplayName,
	'                    SizeOf(szVideoDisplayName))
	'    GetProfileString(TEXT("annie"), TEXT("AudioDevice2"), TEXT(""),
	'                    szAudioDisplayName,
	'                    SizeOf(szAudioDisplayName))
	'
	gcap.fDeviceMenuPopulated = False
	AddDevicesToMenu()
	'
	'    'Do we want audio?
	'    gcap.fCapAudio = GetProfileInt(TEXT("annie"), TEXT("CaptureAudio"), True)
	'    gcap.fCapCC = GetProfileInt(TEXT("annie"), TEXT("CaptureCC"), False)
	'
	'    'Do we want preview?
	'    gcap.fWantPreview = GetProfileInt(TEXT("annie"), TEXT("WantPreview"), False)
	'    'which stream should be the master? NONE(-1) means nothing special happens
	'    'AUDIO(1) means the video frame rate Is changed before written Out To keep
	'    'the movie in sync when the audio And video capture crystals are Not the
	'    'same (And therefore drift Out of sync after a few minutes).  VIDEO(0)
	'    'means the audio sample rate Is changed before written Out
	'    gcap.iMasterStream = GetProfileInt(TEXT("annie"), TEXT("MasterStream"), 1)
	'
	'
	'    'Get the frame rate from win.ini before making the graph
	'    gcap.fUseFrameRate = GetProfileInt(TEXT("annie"), TEXT("UseFrameRate"), 1)
	'    Int units_per_frame = GetProfileInt(TEXT("annie"), TEXT("FrameRate"), 666667)  '15fps
	'    gcap.FrameRate = 10000000. / units_per_frame
	'    gcap.FrameRate = (Int)(gcap.FrameRate * 100) / 100.
	'    'reasonable default
	'    If (gcap.FrameRate <= 0.)
	gcap.FrameRate = 15.0
	'
	'    gcap.fUseTimeLimit = GetProfileInt(TEXT("annie"), TEXT("UseTimeLimit"), 0)
	'    gcap.dwTimeLimit = GetProfileInt(TEXT("annie"), TEXT("TimeLimit"), 0)
	'
	'    'instantiate the capture filters we need To Do the menu items
	'    'This will mStart previewing, If wanted
	'    '
	'    'make these the official devices we're using
	'
	'    ChooseDevices(szVideoDisplayName, szAudioDisplayName)
	'    'And builds a partial filtergraph.
	'
	'	'Register For device Add/remove notifications.
	'	DEV_BROADCAST_DEVICEINTERFACE filterData
	'	ZeroMemory(&filterData, SizeOf(DEV_BROADCAST_DEVICEINTERFACE))
	'
	'	filterData.dbcc_size = SizeOf(DEV_BROADCAST_DEVICEINTERFACE)
	'	filterData.dbcc_devicetype = DBT_DEVTYP_DEVICEINTERFACE
	'	filterData.dbcc_classguid = AM_KSCATEGORY_CAPTURE
	'
	'    gpUnregisterDeviceNotification = NULL
	'    gpRegisterDeviceNotification = NULL
	'    'dynload device removal APIs
	'    {
	'        HMODULE hmodUser = GetModuleHandle(TEXT("user32.dll"))
	'        Assert(hmodUser)       'we link To user32
	'        gpUnregisterDeviceNotification = (PUnregisterDeviceNotification)
	'            GetProcAddress(hmodUser, "UnregisterDeviceNotification")
	'
	'        'm_pRegisterDeviceNotification Is prototyped differently in unicode
	'        gpRegisterDeviceNotification = (PRegisterDeviceNotification)
	'            GetProcAddress(hmodUser,
	'#ifdef UNICODE
	'                           "RegisterDeviceNotificationW"
	'#else
	'                           "RegisterDeviceNotificationA"
	'#endif
	'                           )
	'        'failures expected On older platforms.
	'        Assert(gpRegisterDeviceNotification and gpUnregisterDeviceNotification or
	'               !gpRegisterDeviceNotification and !gpUnregisterDeviceNotification)
	'    }
	'
	'    ghDevNotify = NULL
	'
	'	If (gpRegisterDeviceNotification)
	'    {
	'        ghDevNotify = gpRegisterDeviceNotification(ghwndApp, &filterData, DEVICE_NOTIFY_WINDOW_HANDLE)
	'		Assert(ghDevNotify <> NULL)
	'    }
	'
	SetAppCaption()
	Return True
End Function

Sub IMonRelease(pm As IMoniker Ptr)
	If (pm) Then
		pm->lpVtbl->Release(pm)
		pm = NULL
	End If
End Sub

'/*----------------------------------------------------------------------------*\
'|   WinMain( hInst, hPrev, lpszCmdLine, cmdShow )                              |
'|                                                                              |
'|   Description:                                                               |
'|       The main procedure For the App.  After initializing, it just goes      |
'|       into a message-processing Loop Until it gets a WM_QUIT message         |
'|       (meaning the app was closed).                                          |
'|                                                                              |
'|   Arguments:                                                                 |
'|       hInst           instance HANDLE of This instance of the app            |
'|       hPrev           instance HANDLE of previous instance, NULL If first    |
'|       szCmdLine       ->NULL-terminated Command Line                         |
'|       cmdShow         specifies how the Window Is initially displayed        |
'|                                                                              |
'|   Returns:                                                                   |
'|       The Exit code As specified in the WM_QUIT message.                     |
'|                                                                              |
'\*----------------------------------------------------------------------------*/
'Int pascal WinMain(HINSTANCE hInst, HINSTANCE hPrev, LPSTR szCmdLine, Int sw)
'{
'    MSG     MSG
'
'    /* Call initialization procedure */
'    If (!AppInit(hInst,hPrev,sw))
'	Return False
'
'    /*
'     * Polling messages from Event queue
'     */
'    For ()
'    {
'	While (PeekMessage(&MSG, NULL, 0, 0,PM_REMOVE))
'	{
'	    If (MSG.message = WM_QUIT)
'		Return MSG.wParam
'
'	    If (TranslateAccelerator(ghwndApp, ghAccel, &MSG))
'		Continue
'
'	    TranslateMessage(&MSG)
'	    DispatchMessage(&MSG)
'	}
'
'	WaitMessage()
'    }
'
'    'Not reached
'    Return MSG.wParam
'}
'
'
'/*----------------------------------------------------------------------------*\
'|   AppWndProc( HWND, uiMessage, WPARAM, LPARAM )                              |
'|                                                                              |
'|   Description:                                                               |
'|       The Window PROC For the app's main (tiled) window.  This processes all |
'|       of the parent Window's messages.                                       |
'|                                                                              |
'|   Arguments:                                                                 |
'|       HWND            Window HANDLE For the Window                           |
'|       MSG             message number                                         |
'|       WPARAM          message-dependent                                      |
'|       LPARAM          message-dependent                                      |
'|                                                                              |
'|   Returns:                                                                   |
'|       0 If processed, nonzero If ignored                                     |
'|                                                                              |
'\*----------------------------------------------------------------------------*/
'Long WINAPI  AppWndProc(HWND HWND, UINT MSG, WPARAM WPARAM, LPARAM LPARAM)
'{
'    PAINTSTRUCT ps
'    HDC HDC
'    RECT rc
'    Int cxBorder, cyBorder, CY
'
'    switch (MSG) {
'
'	'
'	'
'	Case WM_CREATE:
'	    break
'
'	Case WM_COMMAND:
'	    Return AppCommand(HWND,MSG,WPARAM,LPARAM)
'
'	Case WM_INITMENU:
'	    'we can mStart capture If Not capturing already
'	    EnableMenuItem((HMENU)WPARAM, MENU_mStart_CAP,
'			(!gcap.fCapturing) ? MF_ENABLED :
'			MF_GRAYED)
'	    'we can mStop capture If it's currently capturing
'	    EnableMenuItem((HMENU)WPARAM, MENU_STOP_CAP,
'			(gcap.fCapturing) ? MF_ENABLED : MF_GRAYED)
'
'	    'We can bring up a dialog If the graph Is stopped
'	    EnableMenuItem((HMENU)WPARAM, MENU_DIALOG0, !gcap.fCapturing ?
'		MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)WPARAM, MENU_DIALOG1, !gcap.fCapturing ?
'		MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)WPARAM, MENU_DIALOG2, !gcap.fCapturing ?
'		MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)WPARAM, MENU_DIALOG3, !gcap.fCapturing ?
'		MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)WPARAM, MENU_DIALOG4, !gcap.fCapturing ?
'		MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_DIALOG5, !gcap.fCapturing ?
'		MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_DIALOG6, !gcap.fCapturing ?
'		MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_DIALOG7, !gcap.fCapturing ?
'		MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_DIALOG8, !gcap.fCapturing ?
'		MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_DIALOG9, !gcap.fCapturing ?
'		MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_DIALOGA, !gcap.fCapturing ?
'		MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_DIALOGB, !gcap.fCapturing ?
'		MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_DIALOGC, !gcap.fCapturing ?
'		MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_DIALOGD, !gcap.fCapturing ?
'		MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_DIALOGE, !gcap.fCapturing ?
'		MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_DIALOGF, !gcap.fCapturing ?
'		MF_ENABLED : MF_GRAYED)
'
'	    'toggles capturing audio or not - can't be capturing right now
'	    'and we must have an audio capture device created
'	    EnableMenuItem((HMENU)wParam, MENU_CAP_AUDIO,
'		    (!gcap.fCapturing and gcap.pACap) ? MF_ENABLED : MF_GRAYED)
'	    'are we capturing audio?
'	    CheckMenuItem((HMENU)wParam, MENU_CAP_AUDIO,
'		    (gcap.fCapAudio) ? MF_CHECKED : MF_UNCHECKED)
'	    'are we doing closed captioning?
'	    CheckMenuItem((HMENU)wParam, MENU_CAP_CC,
'		    (gcap.fCapCC) ? MF_CHECKED : MF_UNCHECKED)
'	    EnableMenuItem((HMENU)wParam, MENU_CAP_CC,
'		    (gcap.fCCAvail) ? MF_ENABLED : MF_GRAYED)
'	    'change audio formats when not capturing
'	    EnableMenuItem((HMENU)wParam, MENU_AUDIOFORMAT, (gcap.fCapAudio and
'			!gcap.fCapturing) ? MF_ENABLED : MF_GRAYED)
'	    'change frame rate when not capturing, and only if the video
'	    'filter captures a VIDEOINFO type format
'	    EnableMenuItem((HMENU)wParam, MENU_FRAMERATE,
'			(!gcap.fCapturing and gcap.fCapAudioIsRelevant) ?
'			 MF_ENABLED : MF_GRAYED)
'	    'change time limit when not capturing
'	    EnableMenuItem((HMENU)WPARAM, MENU_TIMELIMIT,
'			!gcap.fCapturing ? MF_ENABLED : MF_GRAYED)
'	    'change capture FILE Name when Not capturing
'	    EnableMenuItem((HMENU)WPARAM, MENU_SET_CAP_FILE,
'			!gcap.fCapturing ? MF_ENABLED : MF_GRAYED)
'	    'pre-Allocate capture FILE when Not capturing
'	    EnableMenuItem((HMENU)WPARAM, MENU_ALLOC_CAP_FILE,
'			!gcap.fCapturing ? MF_ENABLED : MF_GRAYED)
'	    'can save capture FILE when Not capturing
'	    EnableMenuItem((HMENU)WPARAM, MENU_SAVE_CAP_FILE,
'			!gcap.fCapturing ? MF_ENABLED : MF_GRAYED)
'	    'Do we want preview?
'	    CheckMenuItem((HMENU)WPARAM, MENU_PREVIEW,
'			(gcap.fWantPreview) ? MF_CHECKED : MF_UNCHECKED)
'	    'can toggle preview If Not capturing
'	    EnableMenuItem((HMENU)WPARAM, MENU_PREVIEW,
'			!gcap.fCapturing ? MF_ENABLED : MF_GRAYED)
'
'	    'which Is the master stream? Not applicable unless we're also
'	    'capturing audio
'	    EnableMenuItem((HMENU)WPARAM, MENU_NOMASTER,
'		(!gcap.fCapturing and gcap.fCapAudio) ? MF_ENABLED : MF_GRAYED)
'	    CheckMenuItem((HMENU)WPARAM, MENU_NOMASTER,
'		    (gcap.iMasterStream = -1) ? MF_CHECKED : MF_UNCHECKED)
'	    EnableMenuItem((HMENU)WPARAM, MENU_AUDIOMASTER,
'		(!gcap.fCapturing and gcap.fCapAudio) ? MF_ENABLED : MF_GRAYED)
'	    CheckMenuItem((HMENU)WPARAM, MENU_AUDIOMASTER,
'		    (gcap.iMasterStream = 1) ? MF_CHECKED : MF_UNCHECKED)
'	    EnableMenuItem((HMENU)WPARAM, MENU_VIDEOMASTER,
'		(!gcap.fCapturing and gcap.fCapAudio) ? MF_ENABLED : MF_GRAYED)
'	    CheckMenuItem((HMENU)WPARAM, MENU_VIDEOMASTER,
'		    (gcap.iMasterStream = 0) ? MF_CHECKED : MF_UNCHECKED)
'
'	    'can't select a new capture device when capturing
'	    EnableMenuItem((HMENU)WPARAM, MENU_VDEVICE0,
'			!gcap.fCapturing ? MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)WPARAM, MENU_VDEVICE1,
'			!gcap.fCapturing ? MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_VDEVICE2,
'			!gcap.fCapturing ? MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_VDEVICE3,
'			!gcap.fCapturing ? MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_VDEVICE4,
'			!gcap.fCapturing ? MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_VDEVICE5,
'			!gcap.fCapturing ? MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_VDEVICE6,
'			!gcap.fCapturing ? MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_VDEVICE7,
'			!gcap.fCapturing ? MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_VDEVICE8,
'			!gcap.fCapturing ? MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_VDEVICE9,
'			!gcap.fCapturing ? MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_ADEVICE0,
'			!gcap.fCapturing ? MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_ADEVICE1,
'			!gcap.fCapturing ? MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_ADEVICE2,
'			!gcap.fCapturing ? MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_ADEVICE3,
'			!gcap.fCapturing ? MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_ADEVICE4,
'			!gcap.fCapturing ? MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_ADEVICE5,
'			!gcap.fCapturing ? MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_ADEVICE6,
'			!gcap.fCapturing ? MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_ADEVICE7,
'			!gcap.fCapturing ? MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_ADEVICE8,
'			!gcap.fCapturing ? MF_ENABLED : MF_GRAYED)
'	    EnableMenuItem((HMENU)wParam, MENU_ADEVICE9,
'			!gcap.fCapturing ? MF_ENABLED : MF_GRAYED)
'
'	    break
'
'
'      Case WM_INITMENUPOPUP:
'            If(GetSubMenu(GetMenu(ghwndApp), 1) = (HMENU)WPARAM) {
'                AddDevicesToMenu()
'            }
'
'            break
'	'
'	'We're out of here!
'	'
'	Case WM_DESTROY:
'	    DbgTerminate()
'
'        IMonRelease(gcap.pmVideo)
'        IMonRelease(gcap.pmAudio)
'        {
'            For(Int i = 0 i < NUMELMS(gcap.rgpmVideoMenu) i++) {
'                IMonRelease(gcap.rgpmVideoMenu[i])
'            }
'            For( i = 0 i < NUMELMS(gcap.rgpmAudioMenu) i++) {
'                IMonRelease(gcap.rgpmAudioMenu[i])
'            }
'        }
'
'		CoUninitialize()
'	    PostQuitMessage(0)
'	    break
'
'	'
'	'
'	Case WM_CLOSE:
'		'Unregister device notifications
'		If (ghDevNotify <> NULL)
'		{
'			Assert(gpUnregisterDeviceNotification)
'            gpUnregisterDeviceNotification(ghDevNotify)
'			ghDevNotify = NULL
'		}
'
'	    StopPreview()
'	    StopCapture()
'	    TearDownGraph()
'	    FreeCapFilters()
'
'	    'store current settings in win.ini for next time
'	    WriteProfileString(TEXT("annie"), TEXT("CaptureFile"),
'                                                gcap.szCaptureFile)
'
'        TCHAR tach[120]
'        WCHAR *szDisplayName
'        szDisplayName = 0
'	    wsprintf(tach, TEXT("%S"), L"")
'        if(gcap.pmVideo)
'        {
'            if (SUCCEEDED(gcap.pmVideo->GetDisplayName(0, 0, &szDisplayName)))
'            {
'                wsprintf(tach, TEXT("%S"), szDisplayName ? szDisplayName : L"")
'                CoTaskMemFree(szDisplayName)
'            }
'        }
'	    WriteProfileString(TEXT("annie"), TEXT("VideoDevice2"), tach)
'	    wsprintf(tach, TEXT("%S"), L"")
'        szDisplayName = 0
'        if(gcap.pmAudio)
'        {
'            if (SUCCEEDED(gcap.pmAudio->GetDisplayName(0, 0, &szDisplayName)))
'            {
'                wsprintf(tach, TEXT("%S"), szDisplayName ? szDisplayName : L"")
'                CoTaskMemFree(szDisplayName)
'            }
'        }
'	    WriteProfileString(TEXT("annie"), TEXT("AudioDevice2"), tach)
'
'	    wsprintf(tach, TEXT("%d"), (int)(10000000 / gcap.FrameRate))
'	    WriteProfileString(TEXT("annie"), TEXT("FrameRate"), tach)
'	    wsprintf(tach, TEXT("%d"), gcap.fUseFrameRate)
'	    WriteProfileString(TEXT("annie"), TEXT("UseFrameRate"), tach)
'	    wsprintf(tach, TEXT("%d"), gcap.fCapAudio)
'	    WriteProfileString(TEXT("annie"), TEXT("CaptureAudio"), tach)
'	    wsprintf(tach, TEXT("%d"), gcap.fCapCC)
'	    WriteProfileString(TEXT("annie"), TEXT("CaptureCC"), tach)
'	    wsprintf(tach, TEXT("%d"), gcap.fWantPreview)
'	    WriteProfileString(TEXT("annie"), TEXT("WantPreview"), tach)
'	    wsprintf(tach, TEXT("%d"), gcap.iMasterStream)
'	    WriteProfileString(TEXT("annie"), TEXT("MasterStream"), tach)
'	    wsprintf(tach, TEXT("%d"), gcap.fUseTimeLimit)
'	    WriteProfileString(TEXT("annie"), TEXT("UseTimeLimit"), tach)
'	    wsprintf(tach, TEXT("%d"), gcap.dwTimeLimit)
'	    WriteProfileString(TEXT("annie"), TEXT("TimeLimit"), tach)
'
'	    break
'
'	case WM_ERASEBKGND:
'	    break
'
'	'ESC will mStop capture
'	case WM_KEYDOWN:
'	    if ((GetAsyncKeyState(VK_ESCAPE) & 0x01) and gcap.fCapturing) {
'		StopCapture()
'		if (gcap.fWantPreview) {
'		    BuildPreviewGraph()
'		    mStartPreview()
'		}
'	    }
'	    break
'
'	case WM_PAINT:
'	    hdc = BeginPaint(hwnd,&ps)
'
'	    'nothing to do
'
'	    EndPaint(hwnd,&ps)
'	    break
'
'	case WM_TIMER:
'	    'update our status bar with #captured, #dropped
'	    'if we've stopped capturing, don't do it anymore.  Some WM_TIMER
'	    'messages may come late, after we've destroyed the graph and
'	    'we'll get invalid numbers.
'	    if (gcap.fCapturing)
'	        UpdateStatus(FALSE)
'
'	    'is our time limit up?
'	    if (gcap.fUseTimeLimit) {
'		if ((timeGetTime() - gcap.lCapmStartTime) / 1000 >=
'							gcap.dwTimeLimit) {
'		    StopCapture()
'		    if (gcap.fWantPreview) {
'			BuildPreviewGraph()
'			mStartPreview()
'		    }
'		}
'	    }
'	    break
'
'	case WM_SIZE:
'	    'make the preview window fit inside our window, taking up
'	    'all of our client area except for the status window at the
'	    'bottom
'	    GetClientRect(ghwndApp, &rc)
'	    cxBorder = GetSystemMetrics(SM_CXBORDER)
'	    cyBorder = GetSystemMetrics(SM_CYBORDER)
'	    cy = statusGetHeight() + cyBorder
'	    MoveWindow(ghwndStatus, -cxBorder, rc.bottom - cy,
'			rc.right + (2 * cxBorder), cy + cyBorder, TRUE)
'	    rc.bottom -= cy
'	    'this is the video renderer window showing the preview
'	    if (gcap.pVW)
'		gcap.pVW->SetWindowPosition(0, 0, rc.right, rc.bottom)
'	    break
'
'	case WM_FGNOTIFY:
'	    'uh-oh, something went wrong while capturing - the filtergraph
'	    'will send us events like EC_COMPLETE, EC_USERABORT and the one
'	    'we care about, EC_ERRORABORT.
'	    if (gcap.pME) {
'		    LONG event, l1, l2
'            BOOL bAbort = FALSE
'		    while (gcap.pME->GetEvent(&event, &l1, &l2, 0) = S_OK)
'            {
'			    gcap.pME->FreeEventParams(event, l1, l2)
'			    if (event = EC_ERRORABORT) {
'                    StopCapture()
'                    bAbort = TRUE
'			        continue
'			    }
'                else if (event = EC_DEVICE_LOST)
'                {
'				    'Check if we have lost a capture filter being used.
'				    'lParam2 of EC_DEVICE_LOST event = 1 indicates device added
'				    '								   = 0 indicates device removed
'				    if (l2 = 0)
'				    {
'					    IBaseFilter *pf
'					    IUnknown *punk = (IUnknown *) l1
'					    if (S_OK = punk->QueryInterface(IID_IBaseFilter, (void **) &pf))
'					    {
'						    if (::IsEqualObject(gcap.pVCap, pf))
'						    {
'								pf->Release()
'                                bAbort = FALSE
'                                StopCapture()
'							    char szError[1000]
'							    wsprintf(szError, "Stopping Capture (Device Lost). Select New Capture Device", l1)
'							    debug.print(szError)
'                                break
'						    }
'							pf->Release()
'					    }
'				    }
'                }
'            } 'end while
'            if (bAbort)
'            {
'			    if (gcap.fWantPreview) {
'				BuildPreviewGraph()
'				mStartPreview()
'			    }
'                char szError[1000]
'                wsprintf(szError, "ERROR during capture, error code=%08x", l1)
'			    debug.print(szError)
'            }
'	    }
'	    break
'
'	case WM_DEVICECHANGE:
'		'We are interested in only device arrival & removal events
'		if (DBT_DEVICEARRIVAL <> wParam and DBT_DEVICEREMOVECOMPLETE <> wParam)
'			break
'		PDEV_BROADCAST_HDR pdbh = (PDEV_BROADCAST_HDR) lParam
'		if (pdbh->dbch_devicetype <> DBT_DEVTYP_DEVICEINTERFACE)
'		{
'			break
'		}
'		PDEV_BROADCAST_DEVICEINTERFACE pdbi = (PDEV_BROADCAST_DEVICEINTERFACE) lParam
'		'Check for capture devices.
'		if (pdbi->dbcc_classguid <> AM_KSCATEGORY_CAPTURE)
'		{
'			break
'		}
'
'		'Check for device arrival/removal.
'		if (DBT_DEVICEARRIVAL = wParam or DBT_DEVICEREMOVECOMPLETE = wParam)
'        {
'			gcap.fDeviceMenuPopulated = false
'        }
'		break
'
'    }
'    return DefWindowProc(hwnd,msg,wParam,lParam)
'}

'Make a graph builder object we can use for capture graph building

Function MakeBuilder() As BOOL
	'we have one already
	If (gcap.pBuilder) Then Return True
	
	Dim As HRESULT hr = CoCreateInstance(@CLSID_CaptureGraphBuilder2, NULL, CLSCTX_INPROC, @IID_ICaptureGraphBuilder2, @gcap.pBuilder)
	Return IIf(hr = NOERROR, True , False)
End Function

'Make a graph object we can use for capture graph building

Function MakeGraph() As BOOL
	'we have one already
	If (gcap.pFg) Then Return True
	
	Dim As HRESULT hr = CoCreateInstance(@CLSID_FilterGraph, NULL, CLSCTX_INPROC, @IID_IGraphBuilder, @gcap.pFg)
	Return IIf(hr = NOERROR, True , False)
End Function

'make sure the preview window inside our window is as big as the
'dimensions of captured video, or some capture cards won't show a preview.
'(Also, it helps people tell what size video they're capturing)
'We will resize our app's window big enough so that once the status bar
'is positioned at the bottom there will be enough room for the preview
'window to be w x h

Sub ResizeWindow(w As Integer, h As Integer)
	Dim As RECT rcW, rcC
	Dim As Integer xExtra, yExtra
	Dim As Integer cyBorder = GetSystemMetrics(SM_CYBORDER)
	
	gnRecurse += 1
	
	GetWindowRect(ghwndApp, @rcW)
	GetClientRect(ghwndApp, @rcC)
	xExtra = rcW.Right - rcW.Left - rcC.Right
	yExtra = rcW.Bottom - rcW.Top - rcC.Bottom + cyBorder '+ statusGetHeight()
	
	rcC.Right = w
	rcC.Bottom = h
	SetWindowPos(ghwndApp, NULL, 0, 0, rcC.Right + xExtra, rcC.Bottom + yExtra, SWP_NOZORDER Or SWP_NOMOVE)
	
	'we may need To recurse once.  But more than that means the Window cannot
	'be made the SIZE we want, trying will just stack fault.
	
	If (gnRecurse = 1 And ((rcC.Right + xExtra <> rcW.Right - rcW.Left And w > GetSystemMetrics(SM_CXMIN)) Or (rcC.Bottom + yExtra <> rcW.Bottom - rcW.Top))) Then
		ResizeWindow(w, h)
	End If
	gnRecurse -= 1
End Sub

'Tear down everything downstream of a given filter
Sub NukeDownStream(pf As IBaseFilter Ptr)
	'DbgLog((LOG_TRACE,1,TEXT("Nuking...")))
	
	Dim As IPin Ptr pP = NULL, pTo = NULL
	Dim As ULong u
	Dim As IEnumPins Ptr pins = NULL
	Dim As PIN_INFO pininfo
	Dim As HRESULT hr = pf->lpVtbl->EnumPins(pf, @pins)
	pins->lpVtbl->Reset(pins)
	While (hr = NOERROR)
		hr = pins->lpVtbl->Next(pins, 1, @pP, @u)
		If hr = S_OK And pP <> NULL Then
			pP->lpVtbl->ConnectedTo(pP, @pTo)
			If (pTo) Then
				hr = pTo->lpVtbl->QueryPinInfo(pTo, @pininfo)
				If (hr = NOERROR) Then
					If (pininfo.dir = PINDIR_INPUT) Then
						NukeDownStream(pininfo.pFilter)
						gcap.pFg->lpVtbl->Disconnect(gcap.pFg, pTo)
						gcap.pFg->lpVtbl->Disconnect(gcap.pFg, pP)
						gcap.pFg->lpVtbl->RemoveFilter(gcap.pFg, pininfo.pFilter)
					End If
					pininfo.pFilter->lpVtbl->Release(pininfo.pFilter)
				End If
				pTo->lpVtbl->Release(pP)
			End If
			pP->lpVtbl->Release(pP)
			pP = NULL
		End If
	Wend
	If (pins) Then pins->lpVtbl->Release(pins)
End Sub

'Tear down everything downstream of the capture filters, so we can build
'a different capture graph.  Notice that we never destroy the capture filters
'and WDM filters upstream of them, because then all the capture settings
'we've set would be lost.

Sub TearDownGraph()
	SAFE_RELEASE(gcap.pSink)
	SAFE_RELEASE(gcap.pConfigAviMux)
	SAFE_RELEASE(gcap.pRender)
	
	'stop drawing in our window, or we may get wierd repaint effects
	gcap.pVW->lpVtbl->put_Owner(gcap.pVW, NULL)
	gcap.pVW->lpVtbl->put_Visible(gcap.pVW, OAFALSE)
	SAFE_RELEASE(gcap.pVW)
	SAFE_RELEASE(gcap.pME)
	SAFE_RELEASE(gcap.pDF)
	
	'destroy the graph downstream of our capture filters
	If (gcap.pVCap) Then NukeDownStream(gcap.pVCap)
	If (gcap.pACap) Then NukeDownStream(gcap.pACap)
	
	'potential Debug Output - what the graph looks like
	'if (gcap.pFg) DumpGraph(gcap.pFg, 1);
	
	gcap.fCaptureGraphBuilt = False
	gcap.fPreviewGraphBuilt = False
	gcap.fPreviewFaked = False
End Sub

'create the capture filters of the graph.  We need to keep them loaded from
'the beginning, so we can set parameters on them and have them remembered

Function InitCapFilters() As BOOL
	Dim As HRESULT hr
	Dim As BOOL f
	Dim As UINT uIndex = 0
	
	gcap.fCCAvail = False	'assume no closed captioning support
	
	f = MakeBuilder()
	DXTRACE_ERR("MakeBuilder", f)
	If (f = NULL) Then
		Debug.Print("Cannot instantiate graph builder")
		Return False
	End If
	
	'First, we need a Video Capture filter, and some interfaces
	
	gcap.pVCap = NULL
	If (gcap.pmVideo) Then
		Dim As IPropertyBag Ptr pBag
		gcap.wachFriendlyName[0] = 0
		hr = gcap.pmVideo->lpVtbl->BindToStorage(gcap.pmVideo, 0, 0, @IID_IPropertyBag, @pBag)
		If (SUCCEEDED(hr)) Then
			Dim As VARIANT tVar
			tVar.vt = VT_BSTR
			hr = pBag->lpVtbl->Read(pBag, "FriendlyName", @tVar, NULL)
			If (hr = NOERROR) Then
				lstrcpyW(gcap.wachFriendlyName, tVar.bstrVal)
				SysFreeString(tVar.bstrVal)
			End If
			pBag->lpVtbl->Release(pBag)
		End If
		hr = gcap.pmVideo->lpVtbl->BindToObject(gcap.pmVideo, 0, 0, @IID_IBaseFilter, @gcap.pVCap)
	End If
	
	If (gcap.pVCap = NULL) Then
		FreeCapFilters()
		DXTRACE_ERR("Error " & hr & ": Cannot create video capture filter", hr)
		'Goto InitCapFiltersFail
	End If
	
	'make a filtergraph, give it to the graph builder and put the video
	'capture filter in the graph
	
	f = MakeGraph()
	If (f = NULL) Then
		FreeCapFilters()
		DXTRACE_ERR("Cannot instantiate filtergraph", hr)
		'Goto InitCapFiltersFail
	End If
	hr = gcap.pBuilder->lpVtbl->SetFiltergraph(gcap.pBuilder, gcap.pFg)
	If (hr <> NOERROR) Then
		FreeCapFilters()
		DXTRACE_ERR("Cannot give graph to builder", hr)
		'Goto InitCapFiltersFail
	End If
	
	hr = gcap.pFg->lpVtbl->AddFilter(gcap.pFg, gcap.pVCap, NULL)
	If (hr <> NOERROR) Then
		FreeCapFilters()
		DXTRACE_ERR("Error " & hr & ": Cannot add vidcap to filtergraph", hr)
		'Goto InitCapFiltersFail
	End If
	
	'Calling FindInterface below will result in building the upstream
	'section of the capture graph (any WDM TVTuners or Crossbars we might
	'need).
	
	'we use this interface to get the name of the driver
	'Don't worry if it doesn't work:  This interface may not be available
	'until the pin is connected, or it may not be available at all.
	'(eg: interface may not be available for some DV capture)
	
	hr = gcap.pBuilder->lpVtbl->FindInterface(gcap.pBuilder, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Interleaved, gcap.pVCap, @IID_IAMVideoCompression, @gcap.pVC)
	If (hr <> S_OK) Then
		hr = gcap.pBuilder->lpVtbl->FindInterface(gcap.pBuilder, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Video, gcap.pVCap, @IID_IAMVideoCompression, @gcap.pVC)
	End If
	
	'!!! What if this interface isn't supported?
	'we use this interface to set the frame rate and get the capture size
	
	hr = gcap.pBuilder->lpVtbl->FindInterface(gcap.pBuilder, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Interleaved, gcap.pVCap, @IID_IAMStreamConfig, @gcap.pVSC)
	If (hr <> NOERROR) Then
		hr = gcap.pBuilder->lpVtbl->FindInterface(gcap.pBuilder, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Video, gcap.pVCap, @IID_IAMStreamConfig, @gcap.pVSC)
		If (hr <> NOERROR) Then
			'this means we can't set frame rate (non-DV only)
			Debug.Print("Error " & hr & ": Cannot find VCapture:IAMStreamConfig")
		End If
	End If
	
	gcap.fCapAudioIsRelevant = True
	
	Dim As AM_MEDIA_TYPE Ptr pmt
	
	'default capture format
	
	If gcap.pVSC <> NULL And gcap.pVSC->lpVtbl->GetFormat(gcap.pVSC, @pmt) = S_OK Then
		'DV capture does not use a VIDEOINFOHEADER
		'If pmt->formattype = @FORMAT_VideoInfo Then
		'resize our window to the default capture size
		'ResizeWindow(HEADER(pmt->pbFormat)->biWidth, Abs(HEADER(pmt->pbFormat)->biHeight))
		'ResizeWindow((Cast(VIDEOINFOHEADER Ptr, pmt->pbFormat)->bmiHeader)->biWidth, Abs((Cast(VIDEOINFOHEADER Ptr, pmt->pbFormat)->bmiHeader)->biWidth))
		'End If
		'If pmt->majortype <> @MEDIATYPE_Video Then
		
		'This capture filter captures something other that pure video.
		'Maybe it's DV or something?  Anyway, chances are we shouldn't
		'allow capturing audio separately, since our video capture
		'filter may have audio combined in it already!
		
		gcap.fCapAudioIsRelevant = False
		gcap.fCapAudio = False
		'End If
		'DeleteMediaType(pmt)
		Delete pmt
	End If
	
	'we use this interface to bring up the 3 dialogs
	'NOTE:  Only the VfW capture filter supports this.  This app only brings
	'up dialogs for legacy VfW capture drivers, since only those have dialogs
	
	hr = gcap.pBuilder->lpVtbl->FindInterface(gcap.pBuilder, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Video, gcap.pVCap, @IID_IAMVfwCaptureDialogs, @gcap.pDlg)
	
	'Use the crossbar class to help us sort out all the possible video inputs
	'The class needs to be given the capture filters ANALOGVIDEO input pin
	
	Dim As IPin Ptr pP = NULL
	Dim As IEnumPins Ptr pins
	Dim As ULong n
	Dim As PIN_INFO pinInfo
	Dim As BOOL Found = False
	Dim As IKsPropertySet Ptr pKs
	Dim As GUID GUID
	Dim As DWORD dw
	Dim As BOOL fMatch = False
	
	gcap.pCrossbar = NULL
	
	If (SUCCEEDED(gcap.pVCap->lpVtbl->EnumPins(gcap.pVCap, @pins))) Then
		While Found = False And S_OK = pins->lpVtbl->Next(pins, 1, @pP, @n)
			If (S_OK = pP->lpVtbl->QueryPinInfo(pP, @pinInfo)) Then
				If (pinInfo.dir = PINDIR_INPUT) Then
					
					'is this pin an ANALOGVIDEOIN input pin?
					If (pP->lpVtbl->QueryInterface(pP, @IID_IKsPropertySet, @pKs) = S_OK) Then
						'If (pKs->lpVtbl->Get(pKs, @AMPROPSETID_Pin, @AMPROPERTY_PIN_CATEGORY, NULL, 0, @GUID, SizeOf(GUID), @dw) = S_OK) Then
						'If (GUID = PIN_CATEGORY_ANALOGVIDEOIN) Then fMatch = True
						'End If
						pKs->lpVtbl->Release(pKs)
					End If
					
					If (fMatch) Then
						gcap.pCrossbar = New CCrossbar (pP)
						'hr = gcap.pCrossbar->GetInputCount(gcap.pCrossbar, @gcap.NumberOfVideoInputs)
						Found = True
					End If
				End If
				pinInfo.pFilter->lpVtbl->Release(pinInfo.pFilter)
			End If
			pP->lpVtbl->Release(pP)
		Wend
		pins->lpVtbl->Release(pins)
	End If
	
	'there's no point making an audio capture filter
	
	If (gcap.fCapAudioIsRelevant = False) Then Goto SkipAudio
	
	'create the audio capture filter, even if we are not capturing audio right
	'now, so we have all the filters around all the time.
	'We want an audio capture filter and some interfaces
	
	If (gcap.pmAudio = 0) Then
		'there are no audio capture devices. We'll only allow video capture
		gcap.fCapAudio = False
		Goto SkipAudio
	End If
	gcap.pACap = NULL
	
	hr = gcap.pmAudio->lpVtbl->BindToObject(gcap.pmAudio, 0, 0, @IID_IBaseFilter, @gcap.pACap)
	
	If (gcap.pACap = NULL) Then
		'there are no audio capture devices. We'll only allow video capture
		gcap.fCapAudio = False
		Debug.Print("Cannot create audio capture filter")
		Goto SkipAudio
	End If
	
	'put the audio capture filter in the graph
	'We'll need this in the graph to get audio property pages
	
	hr = gcap.pFg->lpVtbl->AddFilter(gcap.pFg, gcap.pACap, NULL)
	If (hr <> NOERROR) Then
		FreeCapFilters()
		DXTRACE_ERR("Cannot add audcap to filtergraph", hr)
		'Goto InitCapFiltersFail
	End If
	
	'Calling FindInterface below will result in building the upstream
	'section of the capture graph (any WDM TVAudio's or Crossbars we might
	'need).
	
	'!!! What if this interface isn't supported?
	'we use this interface to set the captured wave format
	hr = gcap.pBuilder->lpVtbl->FindInterface(gcap.pBuilder, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Audio, gcap.pACap, @IID_IAMStreamConfig, @gcap.pASC)
	If (hr <> NOERROR) Then
		Debug.Print("Cannot find ACapture:IAMStreamConfig")
	End If
	
	SkipAudio:
	
	'Can this filter do closed captioning?
	Dim As IPin Ptr PPIN
	hr = gcap.pBuilder->lpVtbl->FindPin(gcap.pBuilder, Cast(IUnknown Ptr, gcap.pVCap), PINDIR_OUTPUT, @PIN_CATEGORY_VBI, NULL, False, 0, @PPIN)
	If (hr <> S_OK) Then hr = gcap.pBuilder->lpVtbl->FindPin(gcap.pBuilder, Cast(IUnknown Ptr, gcap.pVCap), PINDIR_OUTPUT, @PIN_CATEGORY_CC, NULL, False, 0, @PPIN)
	If (hr = S_OK) Then
		PPIN->lpVtbl->Release(PPIN)
		gcap.fCCAvail = True
	Else
		gcap.fCapCC = False 'can't capture it, then
	End If
	
	'potential debug output - what the graph looks like
	'DumpGraph(gcap.pFg, 1)
	
	Return True
	
	'InitCapFiltersFail:
	'FreeCapFilters()
	'DXTRACE_ERR("Label: InitCapFiltersFail", True)
	'Return False
End Function

'all done with the capture filters and the graph builder
Sub FreeCapFilters()
	SAFE_RELEASE(gcap.pFg)
	SAFE_RELEASE(gcap.pBuilder)
	SAFE_RELEASE(gcap.pVCap)
	SAFE_RELEASE(gcap.pACap)
	SAFE_RELEASE(gcap.pASC)
	SAFE_RELEASE(gcap.pVSC)
	SAFE_RELEASE(gcap.pVC)
	SAFE_RELEASE(gcap.pDlg)
End Sub

'build the capture graph!
Function BuildCaptureGraph() As BOOL
	'USES_CONVERSION
	Dim As Integer CY, cyBorder
	Dim As HRESULT hr
	Dim As BOOL f
	Dim As AM_MEDIA_TYPE Ptr pmt
	
	'we have one already
	If (gcap.fCaptureGraphBuilt) Then Return True
	
	'No rebuilding While we're running
	If (gcap.fCapturing Or gcap.fPreviewing) Then Return False
	
	'We don't have the necessary capture filters
	If (gcap.pVCap = NULL) Then Return False
	If (gcap.pACap = NULL And gcap.fCapAudio) Then Return False
	
	'no capture FILE Name yet... we need one first
	If (*gcap.szCaptureFile = "") Then
		f = SetCaptureFile(ghwndApp)
		If (f = 0) Then Return f
	End If
	
	'we already have another graph built... tear down the old one
	If (gcap.fPreviewGraphBuilt) Then TearDownGraph()
	
	'We need a rendering section that will Write the capture FILE Out in AVI
	'FILE Format
	
	Dim As GUID GUID = MEDIASUBTYPE_Avi
	hr = gcap.pBuilder->lpVtbl->SetOutputFileName(gcap.pBuilder, @GUID, gcap.szCaptureFile, @gcap.pRender, @gcap.pSink)
	If (hr <> NOERROR) Then
		TearDownGraph()
		DXTRACE_ERR("Cannot set output file", hr)
		'Goto SetupCaptureFail
	End If
	
	'Now tell the AVIMUX to write out AVI files that old apps can read properly.
	'If we don't, most apps won't be able to tell where the keyframes are,
	'slowing down editing considerably
	'Doing this will cause one seek (over the area the index will go) when
	'you capture past 1 Gig, but that's no big deal.
	'NOTE: This is on by default, so it's not necessary to turn it on
	
	'Also, set the proper MASTER STREAM
	
	hr = gcap.pRender->lpVtbl->QueryInterface(gcap.pRender, @IID_IConfigAviMux, @gcap.pConfigAviMux)
	If (hr = NOERROR) And (gcap.pConfigAviMux <> 0) Then
		gcap.pConfigAviMux->lpVtbl->SetOutputCompatibilityIndex(gcap.pConfigAviMux, True)
		If (gcap.fCapAudio) Then
			hr = gcap.pConfigAviMux->lpVtbl->SetMasterStream(gcap.pConfigAviMux, gcap.iMasterStream)
			If (hr <> NOERROR) Then
				Debug.Print("SetMasterStream failed!")
			End If
		End If
	End If
	
	'Render the video capture and preview pins - even if the capture filter only
	'has a capture pin (and no preview pin) this should work... because the
	'capture graph builder will use a smart tee filter to provide both capture
	'and preview.  We don't have to worry.  It will just work.
	
	'NOTE that we try to render the interleaved pin before the video pin, because
	'if BOTH exist, it's a DV filter and the only way to get the audio is to use
	'the interleaved pin.  Using the Video pin on a DV filter is only useful if
	'you don't want the audio.
	
	hr = gcap.pBuilder->lpVtbl->RenderStream(gcap.pBuilder, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Interleaved, Cast(IUnknown Ptr, gcap.pVCap), NULL, gcap.pRender)
	If (hr <> NOERROR) Then
		hr = gcap.pBuilder->lpVtbl->RenderStream(gcap.pBuilder, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Video, Cast(IUnknown Ptr, gcap.pVCap), NULL, gcap.pRender)
		If (hr <> NOERROR) Then
			TearDownGraph()
			DXTRACE_ERR("Cannot render video capture stream", hr)
			'Goto SetupCaptureFail
		End If
	End If
	
	If (gcap.fWantPreview) Then
		hr = gcap.pBuilder->lpVtbl->RenderStream(gcap.pBuilder, @PIN_CATEGORY_PREVIEW, @MEDIATYPE_Interleaved, Cast(IUnknown Ptr, gcap.pVCap), NULL, NULL)
		If (hr = VFW_S_NOPREVIEWPIN) Then
			'preview was faked up for us using the (only) capture pin
			gcap.fPreviewFaked = True
		ElseIf (hr <> S_OK) Then
			hr = gcap.pBuilder->lpVtbl->RenderStream(gcap.pBuilder, @PIN_CATEGORY_PREVIEW, @MEDIATYPE_Video, Cast(IUnknown Ptr, gcap.pVCap), NULL, NULL)
			If (hr = VFW_S_NOPREVIEWPIN) Then
				'preview was faked up for us using the (only) capture pin
				gcap.fPreviewFaked = True
			ElseIf (hr <> S_OK) Then
				TearDownGraph()
				DXTRACE_ERR("Cannot render video preview stream", hr)
				'Goto SetupCaptureFail
			End If
		End If
	End If
	
	'Render the audio capture pin?
	
	If (gcap.fCapAudio) Then
		hr = gcap.pBuilder->lpVtbl->RenderStream(gcap.pBuilder, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Audio, Cast(IUnknown Ptr, gcap.pACap), NULL, gcap.pRender)
		If (hr <> NOERROR) Then
			TearDownGraph()
			DXTRACE_ERR("Cannot render audio capture stream", hr)
			'Goto SetupCaptureFail
		End If
	End If
	
	'Render the closed captioning pin? It could be a CC Or a VBI category pin,
	'depending On the capture driver
	
	If (gcap.fCapCC) Then
		hr = gcap.pBuilder->lpVtbl->RenderStream(gcap.pBuilder, @PIN_CATEGORY_CC, NULL, Cast(IUnknown Ptr, gcap.pVCap), NULL, gcap.pRender)
		If (hr <> NOERROR) Then
			hr = gcap.pBuilder->lpVtbl->RenderStream(gcap.pBuilder, @PIN_CATEGORY_VBI, NULL, Cast(IUnknown Ptr, gcap.pVCap), NULL, gcap.pRender)
			If (hr <> NOERROR) Then
				Debug.Print("Cannot render closed captioning")
				'so what? goto SetupCaptureFail
			End If
		End If
		'To preview and capture VBI at the same time, we can call this twice
		If (gcap.fWantPreview) Then
			hr = gcap.pBuilder->lpVtbl->RenderStream(gcap.pBuilder, @PIN_CATEGORY_VBI, NULL, Cast(IUnknown Ptr, gcap.pVCap), NULL, NULL)
		End If
	End If
	
	'Get the preview window to be a child of our app's window
	
	'This will find the IVideoWindow interface on the renderer.  It is
	'important to ask the filtergraph for this interface... do NOT use
	'ICaptureGraphBuilder2::FindInterface, because the filtergraph needs to
	'know we own the window so it can give us display changed messages, etc.
	
	'NOTE: We do this even if we didn't ask for a preview, because rendering
	'the capture pin may have rendered the preview pin too (WDM overlay
	'devices) because they must have a preview going.  So we better always
	'put the preview window in our app, or we may get a top level window
	'appearing out of nowhere!
	
	hr = gcap.pFg->lpVtbl->QueryInterface(gcap.pFg, @IID_IVideoWindow, @gcap.pVW)
	If hr <> NOERROR And gcap.fWantPreview Then
		Debug.Print("This graph cannot preview")
	ElseIf (hr = NOERROR) Then
		Dim As Rect rc
		gcap.pVW->lpVtbl->put_Owner(gcap.pVW, Cast(OAHWND, ghwndApp))    'We own the window now
		gcap.pVW->lpVtbl->put_WindowStyle(gcap.pVW, WS_CHILD Or WS_CLIPCHILDREN)    'you are now a child
		'give the preview window all our space but where the status bar is
		GetClientRect(ghwndApp, @rc)
		cyBorder = GetSystemMetrics(SM_CYBORDER)
		CY = cyBorder
		rc.Bottom -= CY
		gcap.pVW->lpVtbl->SetWindowPosition(gcap.pVW, 0, 0, rc.Right, rc.Bottom) 'be this big
		gcap.pVW->lpVtbl->put_Visible(gcap.pVW, OATRUE)
	End If
	
	'now tell it what frame rate to capture at.  Just find the format it
	'is capturing with, and leave everything alone but change the frame rate
	
	hr = gcap.fUseFrameRate ' ? E_FAIL : NOERROR
	If (gcap.pVSC <> NULL) And (gcap.fUseFrameRate<> 0) Then
		hr = gcap.pVSC->lpVtbl->GetFormat(gcap.pVSC, @pmt)
		'DV capture does not use a VIDEOINFOHEADER
		If hr = NOERROR Then
			'If pmt->formattype = FORMAT_VideoInfo Then
			Dim As VIDEOINFOHEADER Ptr pvi = Cast(VIDEOINFOHEADER Ptr, pmt->pbFormat)
			pvi->AvgTimePerFrame = Cast(LONGLONG, (10000000 / gcap.FrameRate))
			hr = gcap.pVSC->lpVtbl->SetFormat(gcap.pVSC, pmt)
			'End If
			SAFE_DELETE(pmt)
			'DeleteMediaType(pmt)
		End If
	End If
	''If (hr <> NOERROR) debug.print("Cannot set frame rate for capture")
	
	'now ask the filtergraph to tell us when something is completed or aborted
	'(EC_COMPLETE, EC_USERABORT, EC_ERRORABORT).  This is how we will find out
	'if the disk gets full while capturing
	hr = gcap.pFg->lpVtbl->QueryInterface(gcap.pFg, @IID_IMediaEventEx, @gcap.pME)
	If (hr = NOERROR) Then
		gcap.pME->lpVtbl->SetNotifyWindow(gcap.pME, Cast(OAHWND, ghwndApp), WM_FGNOTIFY, 0)
	End If
	
	'All done.
	'potential Debug Output - what the graph looks like
	'DumpGraph(gcap.pFg, 1);
	
	gcap.fCaptureGraphBuilt = True
	Return True
	
	'SetupCaptureFail:
	'TearDownGraph()
	'Return False
End Function

'build the preview graph!
'!!! PLEASE NOTE !!!  Some new WDM devices have totally separate capture
'and preview settings.  An application that wishes to preview and then
'capture may have to set the preview pin format using IAMStreamConfig on the
'preview pin, and then again on the capture pin to capture with that format.
'In this sample app, there is a separate page to set the settings on the
'capture pin and one for the preview pin.  To avoid the user
'having to enter the same settings in 2 dialog boxes, an app can have its own
'UI for choosing a format (the possible formats can be enumerated using
'IAMStreamConfig) and then the app can programmatically call IAMStreamConfig
'to set the format on both pins.

Function BuildPreviewGraph() As BOOL
	Dim As Integer CY, cyBorder
	Dim As HRESULT hr
	Dim As AM_MEDIA_TYPE Ptr pmt
	Dim As BOOL fPreviewUsingCapturePin = False
	
	'we have one already
	If (gcap.fPreviewGraphBuilt) Then DXTRACE_ERR("gcap.fPreviewGraphBuilt", True)
	
	'No rebuilding while we're running
	If (gcap.fCapturing Or gcap.fPreviewing) Then DXTRACE_ERR("gcap.fCapturing Or gcap.fPreviewing", False)
	
	'We don't have the necessary capture filters
	If (gcap.pVCap = NULL) Then DXTRACE_ERR("gcap.pVCap = NULL", False)
	If (gcap.pACap = NULL And gcap.fCapAudio) Then DXTRACE_ERR("gcap.pACap = NULL And gcap.fCapAudio", False)
	
	'we already have another graph built... tear down the old one
	If (gcap.fCaptureGraphBuilt) Then TearDownGraph()
	
	'Render the preview pin - even if there is not preview pin, the capture
	'graph builder will use a smart tee filter and provide a preview.
	'!!! what about latency/buffer issues?
	
	'NOTE that we try to render the interleaved pin before the video pin, because
	'if BOTH exist, it's a DV filter and the only way to get the audio is to use
	'the interleaved pin.  Using the Video pin on a DV filter is only useful if
	'you don't want the audio.
	
	hr = gcap.pBuilder->lpVtbl->RenderStream(gcap.pBuilder, @PIN_CATEGORY_PREVIEW, @MEDIATYPE_Interleaved, Cast(IUnknown Ptr, gcap.pVCap), NULL, NULL)
	If (hr = VFW_S_NOPREVIEWPIN) Then
		'preview was faked up for us using the (only) capture pin
		gcap.fPreviewFaked = True
	ElseIf (hr <> S_OK) Then
		'maybe it's DV?
		hr = gcap.pBuilder->lpVtbl->RenderStream(gcap.pBuilder, @PIN_CATEGORY_PREVIEW, @MEDIATYPE_Video, Cast(IUnknown Ptr, gcap.pVCap), NULL, NULL)
		If (hr = VFW_S_NOPREVIEWPIN) Then
			'preview was faked up for us using the (only) capture pin
			gcap.fPreviewFaked = True
		ElseIf (hr <> S_OK) Then
			Debug.Print("This graph cannot preview!")
		End If
	End If
	
	'Render the closed captioning pin? It could be a CC or a VBI category pin,
	'depending on the capture driver
	
	If (gcap.fCapCC) Then
		hr = gcap.pBuilder->lpVtbl->RenderStream(gcap.pBuilder, @PIN_CATEGORY_CC, NULL, Cast(IUnknown Ptr, gcap.pVCap), NULL, NULL)
		If (hr <> NOERROR) Then
			hr = gcap.pBuilder->lpVtbl->RenderStream(gcap.pBuilder, @PIN_CATEGORY_VBI, NULL, Cast(IUnknown Ptr, gcap.pVCap), NULL, NULL)
			If (hr <> NOERROR) Then
				Debug.Print("Cannot render closed captioning")
				'so what? goto SetupCaptureFail
			End If
		End If
	End If
	
	'Get the preview window to be a child of our app's window
	
	'This will find the IVideoWindow interface on the renderer.  It is
	'important to ask the filtergraph for this interface... do NOT use
	'ICaptureGraphBuilder2::FindInterface, because the filtergraph needs to
	'know we own the window so it can give us display changed messages, etc.
	
	hr = gcap.pFg->lpVtbl->QueryInterface(gcap.pFg, @IID_IVideoWindow, @gcap.pVW)
	If (hr <> NOERROR) Then
		Debug.Print("This graph cannot preview properly")
	Else
		Dim As Rect rc
		gcap.pVW->lpVtbl->put_Owner(gcap.pVW, Cast(OAHWND, ghwndApp))    'We own the window now
		gcap.pVW->lpVtbl->put_WindowStyle(gcap.pVW, WS_CHILD)    'you are now a child
		'give the preview window all our space but where the status bar is
		GetClientRect(ghwndApp, @rc)
		cyBorder = GetSystemMetrics(SM_CYBORDER)
		CY = cyBorder '+statusGetHeight()
		rc.Bottom -= CY
		gcap.pVW->lpVtbl->SetWindowPosition(gcap.pVW, 0, 0, rc.Right, rc.Bottom) 'be this big
		gcap.pVW->lpVtbl->put_Visible(gcap.pVW, OATRUE)
	End If
	
	'now tell it what frame rate to capture at.  Just find the format it
	'is capturing with, and leave everything alone but change the frame rate
	'No big deal if it fails.  It's just for preview
	'!!! Should we then talk to the preview pin?
	If gcap.pVSC <> NULL And gcap.fUseFrameRate<> NULL Then
		hr = gcap.pVSC->lpVtbl->GetFormat(gcap.pVSC, @pmt)
		'DV capture does not use a VIDEOINFOHEADER
		If (hr = NOERROR) Then
			'If (pmt->formattype = FORMAT_VideoInfo) Then
			Dim As VIDEOINFOHEADER Ptr pvi = Cast(VIDEOINFOHEADER Ptr, pmt->pbFormat)
			pvi->AvgTimePerFrame = Cast(LONGLONG, (10000000 / gcap.FrameRate))
			hr = gcap.pVSC->lpVtbl->SetFormat(gcap.pVSC, pmt)
			If (hr <> NOERROR) Then Debug.Print("Error " & hr & ": Cannot set frame rate for preview")
			'End If
			'DeleteMediaType(pmt)
		End If
	End If
	
	'make sure we process events while we're previewing!
	hr = gcap.pFg->lpVtbl->QueryInterface(gcap.pFg, @IID_IMediaEventEx, @gcap.pME)
	If (hr = NOERROR) Then
		gcap.pME->lpVtbl->SetNotifyWindow(gcap.pME, Cast(OAHWND, ghwndApp), WM_FGNOTIFY, 0)
	End If
	
	'All done.
	'potential debug output - what the graph looks like
	'DumpGraph(gcap.pFg, 1)
	
	gcap.fPreviewGraphBuilt = True
	Return True
End Function

'Start previewing
Function StartPreview() As BOOL
	'way ahead of you
	If (gcap.fPreviewing) Then Return True
	If (gcap.fPreviewGraphBuilt = False) Then Return False
	
	'run the graph
	Dim As IMediaControl Ptr pMC = NULL
	Dim As HRESULT hr = gcap.pFg->lpVtbl->QueryInterface(gcap.pFg, @IID_IMediaControl, @pMC)
	If (SUCCEEDED(hr)) Then
		hr = pMC->lpVtbl->Run(pMC)
		If (FAILED(hr)) Then
			'stop parts that ran
			pMC->lpVtbl->Stop(pMC)
		End If
		pMC->lpVtbl->Release(pMC)
		If (FAILED(hr)) Then Debug.Print("Error " & hr & ": Cannot run preview graph")
		Return False
	End If
	
	gcap.fPreviewing = True
	Return True
End Function

'stop the preview graph
Function StopPreview() As BOOL
	'way ahead of you
	If (gcap.fPreviewing = False) Then Return False
	
	'stop the graph
	Dim As IMediaControl Ptr pMC = NULL
	Dim As HRESULT hr = gcap.pFg->lpVtbl->QueryInterface(gcap.pFg, @IID_IMediaControl, @pMC)
	If (SUCCEEDED(hr)) Then
		hr = pMC->lpVtbl->Stop(pMC)
		pMC->lpVtbl->Release(pMC)
	End If
	If (FAILED(hr)) Then
		Debug.Print("Error " & hr & ": Cannot mStop preview graph")
		Return False
	End If
	
	gcap.fPreviewing = False
	
	'!!! get rid of menu garbage
	InvalidateRect(ghwndApp, NULL, True)
	Return True
End Function

'Start the capture graph
Function StartCapture() As BOOL
	Dim As BOOL f, fHasStreamControl
	Dim As HRESULT hr
	
	'way ahead of you
	If (gcap.fCapturing) Then Return True
	
	'or we'll get confused
	If (gcap.fPreviewing) Then StopPreview()
	
	'or we'll crash
	If Not (gcap.fCaptureGraphBuilt) Then Return False
	
	'This amount will be subtracted from the number of dropped and not
	'dropped frames reported by the filter.  Since we might be having the
	'filter running while the pin is turned off, we don't want any of the
	'frame statistics from the time the pin is off interfering with the
	'statistics we gather while the pin is on
	gcap.lDroppedBase = 0
	gcap.lNotBase = 0
	
	Dim As REFERENCE_TIME mStart = MAX_TIME, mStop = MAX_TIME
	
	'don't capture quite yet...
	hr = gcap.pBuilder->lpVtbl->ControlStream(gcap.pBuilder, @PIN_CATEGORY_CAPTURE, NULL, NULL, @mStart, NULL, 0, 0)
	'DbgLog((LOG_TRACE,1,TEXT("Capture OFF returns %x"), hr))
	
	'Do we have the ability to control capture and preview separately?
	fHasStreamControl = SUCCEEDED(hr)
	
	'prepare to run the graph
	Dim As IMediaControl Ptr pMC = NULL
	hr = gcap.pFg->lpVtbl->QueryInterface(gcap.pFg, @IID_IMediaControl, @pMC)
	If (FAILED(hr)) Then
		Debug.Print("Error " & hr & ": Cannot get IMediaControl")
		Return False
	End If
	
	'If we were able to keep capture off, then we can
	'run the graph now for frame accurate mStart later yet still showing a
	'preview.   Otherwise, we can't run the graph yet without capture
	'mStarting too, so we'll pause it so the latency between when they
	'press a key and when capture begins is still small (but they won't have
	'a preview while they wait to press a key)
	
	If (fHasStreamControl) Then
		hr = pMC->lpVtbl->Run(pMC)
	Else
		hr = pMC->lpVtbl->Pause(pMC)
	End If
	If (FAILED(hr)) Then
		'stop parts that mStarted
		pMC->lpVtbl->Stop(pMC)
		pMC->lpVtbl->Release(pMC)
		Debug.Print("Error " & hr & ": Cannot mStart graph")
		Return False
	End If
	
	'press a key to mStart capture
	'f = DoDialog(ghwndApp, IDD_PressAKeyDialog, Cast(DLGPROC, PressAKeyProc), 0)
	If f = NULL Then
		pMC->lpVtbl->Stop(pMC)
		pMC->lpVtbl->Release(pMC)
		If (gcap.fWantPreview) Then
			BuildPreviewGraph()
			StartPreview()
		End If
		Return f
	End If
	
	'mStart capture NOW!
	If (fHasStreamControl) Then
		'we may not have this yet
		If gcap.pDF = NULL Then hr = gcap.pBuilder->lpVtbl->FindInterface(gcap.pBuilder, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Interleaved, gcap.pVCap, @IID_IAMDroppedFrames, @gcap.pDF)
		If (hr <> NOERROR) Then hr = gcap.pBuilder->lpVtbl->FindInterface(gcap.pBuilder, @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Video, gcap.pVCap, @IID_IAMDroppedFrames, @gcap.pDF)
	End If
	
	'turn the capture pin on now!
	hr = gcap.pBuilder->lpVtbl->ControlStream(gcap.pBuilder, @PIN_CATEGORY_CAPTURE, NULL, NULL, NULL, @mStop, 0, 0)
	'DbgLog((LOG_TRACE,0,TEXT("Capture ON returns %x"), hr))
	'make note of the current dropped frame counts
	If (gcap.pDF) Then
		gcap.pDF->lpVtbl->GetNumDropped(gcap.pDF, @gcap.lDroppedBase)
		gcap.pDF->lpVtbl->GetNumNotDropped(gcap.pDF, @gcap.lNotBase)
		'DbgLog((LOG_TRACE,0,TEXT("Dropped counts are %ld and %ld"),
		'		gcap.lDroppedBase, gcap.lNotBase))
		
	Else
		hr = pMC->lpVtbl->Run(pMC)
		If (FAILED(hr)) Then
			'stop parts that mStarted
			pMC->lpVtbl->Stop(pMC)
			pMC->lpVtbl->Release(pMC)
			Debug.Print("Error " & hr & ": Cannot run graph")
			Return False
		End If
	End If
	
	pMC->lpVtbl->Release(pMC)
	
	'when did we mStart capture?
	gcap.lCapStartTime = timeGetTime()
	
	'30 times a second I want to update my status bar - #captured, #dropped
	SetTimer(ghwndApp, 1, 33, NULL)
	
	gcap.fCapturing = True
	Return True
End Function

'stop the capture graph

Function StopCapture() As BOOL
	'way ahead of you
	If Not gcap.fCapturing Then Return False
	
	
	'stop the graph
	Dim As IMediaControl Ptr pMC = NULL
	Dim As HRESULT hr = gcap.pFg->lpVtbl->QueryInterface(gcap.pFg, @IID_IMediaControl, @pMC)
	If (SUCCEEDED(hr)) Then
		hr = pMC->lpVtbl->Stop(pMC)
		pMC->lpVtbl->Release(pMC)
	End If
	If (FAILED(hr)) Then
		Debug.Print("Error " & hr & ": Cannot mStop graph")
		Return False
	End If
	
	'when the graph was stopped
	gcap.lCapStopTime = timeGetTime()
	
	'no more status bar updates
	KillTimer(ghwndApp, 1)
	
	'one last time for the final count and all the stats
	UpdateStatus(True)
	
	gcap.fCapturing = False
	
	'!!! get rid of menu garbage
	InvalidateRect(ghwndApp, NULL, True)
	
	Return True
End Function

'Let's talk about UI for a minute.  There are many programmatic interfaces
'you can use to program a capture filter or related filter to capture the
'way you want it to.... eg:  IAMStreamConfig, IAMVideoCompression,
'IAMCrossbar, IAMTVTuner, IAMTVAudio, IAMAnalogVideoDecoder, IAMCameraControl,
'IAMVideoProcAmp, etc.
'
'But you probably want some UI to let the user play with all these settings.
'For new WDM-style capture devices, we offer some default UI you can use.
'The code below shows how to bring up all of the dialog boxes supported
'by any capture filters.
'
'The following code shows you how you can bring up all of the
'dialogs supported by a particular object at once on a big page with lots
'of thumb tabs.  You do this by mStarting with an interface on the object that
'you want, and using ISpecifyPropertyPages to get the whole list, and
'OleCreatePropertyFrame to bring them all up.  This way you will get custom
'property pages a filter has, too, that are not one of the standard pages that
'you know about.  There are at least 9 objects that may have property pages.
'Your app already has 2 of the object pointers, the video capture filter and
'the audio capture filter (let's call them pVCap and pACap)
'1.  The video capture filter - pVCap
'2.  The video capture filter's capture pin - get this by calling
'    FindInterface(&PIN_CATEGORY_CAPTURE, pVCap, IID_IPin, &pX)
'3.  The video capture filter's preview pin - get this by calling
'    FindInterface(&PIN_CATEGORY_PREVIEW, pVCap, IID_IPin, &pX)
'4.  The audio capture filter - pACap
'5.  The audio capture filter's capture pin - get this by calling
'    FindInterface(&PIN_CATEGORY_CAPTURE, pACap, IID_IPin, &pX)
'6.  The crossbar connected to the video capture filter - get this by calling
'    FindInterface(NULL, pVCap, IID_IAMCrossbar, &pX)
'7.  There is a possible second crossbar to control audio - get this by
'    looking upstream of the first crossbar like this:
'    FindInterface(&LOOK_UPSTREAM_ONLY, pX, IID_IAMCrossbar, &pX2)
'8.  The TV Tuner connected to the video capture filter - get this by calling
'    FindInterface(NULL, pVCap, IID_IAMTVTuner, &pX)
'9.  The TV Audio connected to the audio capture filter - get this by calling
'    FindInterface(NULL, pACap, IID_IAMTVAudio, &pX)
'10. We have a helper class, CCrossbar, which makes the crossbar issue less
'    confusing.  In fact, although not supported here, there may be more than
'    two crossbars, arranged in many different ways.  An application may not
'    wish to have separate dialogs for each crossbar, but instead hide the
'    complexity and simply offer the user a list of inputs that can be chosen.
'    This list represents all the unique inputs from all the crossbars.
'    The crossbar helper class does this and offers that list as #10.  It is
'    expected that an application will either provide the crossbar dialogs
'    above (#6 and #7) OR provide the input list (this #10), but not both.
'    That would be confusing because if you select an input using dialog 6 or
'    7 the input list here in #10 won't know about your choice.
'
'Your last choice for UI is to make your own pages, and use the results of
'your custom page to call the interfaces programmatically.


Sub MakeMenuOptions()
	'    HRESULT hr
	'    HMENU hMenuSub = GetSubMenu(GetMenu(ghwndApp), 2) 'Options menu
	'
	'    'remove any old choices from the last device
	'    RemoveMenu(hMenuSub, 4, MF_BYPOSITION)
	'    RemoveMenu(hMenuSub, 4, MF_BYPOSITION)
	'    RemoveMenu(hMenuSub, 4, MF_BYPOSITION)
	'    RemoveMenu(hMenuSub, 4, MF_BYPOSITION)
	'    RemoveMenu(hMenuSub, 4, MF_BYPOSITION)
	'    RemoveMenu(hMenuSub, 4, MF_BYPOSITION)
	'    RemoveMenu(hMenuSub, 4, MF_BYPOSITION)
	'    RemoveMenu(hMenuSub, 4, MF_BYPOSITION)
	'    RemoveMenu(hMenuSub, 4, MF_BYPOSITION)
	'    RemoveMenu(hMenuSub, 4, MF_BYPOSITION)
	'
	'    int zz = 0
	'    gcap.iFormatDialogPos = -1
	'    gcap.iSourceDialogPos = -1
	'    gcap.iDisplayDialogPos = -1
	'    gcap.iVCapDialogPos = -1
	'    gcap.iVCrossbarDialogPos = -1
	'    gcap.iTVTunerDialogPos = -1
	'    gcap.iACapDialogPos = -1
	'    gcap.iACrossbarDialogPos = -1
	'    gcap.iTVAudioDialogPos = -1
	'    gcap.iVCapCapturePinDialogPos = -1
	'    gcap.iVCapPreviewPinDialogPos = -1
	'    gcap.iACapCapturePinDialogPos = -1
	'
	'    'If this device supports the old legacy UI dialogs, offer them
	'
	'    if (gcap.pDlg and !gcap.pDlg->HasDialog(VfwCaptureDialog_Format)) {
	'	AppendMenu(hMenuSub, MF_STRING, MENU_DIALOG0 + zz, TEXT("Video Format..."))
	'	gcap.iFormatDialogPos = zz++
	'    }
	'    if (gcap.pDlg and !gcap.pDlg->HasDialog(VfwCaptureDialog_Source)) {
	'	AppendMenu(hMenuSub, MF_STRING, MENU_DIALOG0 + zz, TEXT("Video Source..."))
	'	gcap.iSourceDialogPos = zz++
	'    }
	'    if (gcap.pDlg and !gcap.pDlg->HasDialog(VfwCaptureDialog_Display)) {
	'	AppendMenu(hMenuSub, MF_STRING, MENU_DIALOG0 + zz, TEXT("Video Display..."))
	'	gcap.iDisplayDialogPos = zz++
	'    }
	'
	'    'Also check the audio capture filter at this point, since even non wdm devices
	'    'may support an IAMAudioInputMixer property page (we'll also get any wdm filter
	'    'properties here as well). We'll get any audio capture pin property pages just
	'    'a bit later.
	'    if (gcap.pACap <> NULL)
	'    {
	'        ISpecifyPropertyPages *pSpec
	'        CAUUID cauuid
	'
	'        hr = gcap.pACap->QueryInterface(IID_ISpecifyPropertyPages, (void **)&pSpec)
	'        if (hr = S_OK) {
	'            hr = pSpec->GetPages(&cauuid)
	'            if (hr = S_OK and cauuid.cElems > 0) {
	'                AppendMenu(hMenuSub,MF_STRING,MENU_DIALOG0+zz, TEXT("Audio Capture Filter..."))
	'                gcap.iACapDialogPos = zz++
	'                CoTaskMemFree(cauuid.pElems)
	'            }
	'            pSpec->Release()
	'        }
	'    }
	'
	'    'don't bother looking for new property pages if the old ones are supported
	'    'or if we don't have a capture filter
	'    if (gcap.pVCap = NULL or gcap.iFormatDialogPos <> -1)
	'	return
	'
	'    'New WDM devices support new UI and new interfaces.
	'    'Your app can use some default property
	'    'pages for UI if you'd like (like we do here) or if you don't like our
	'    'dialog boxes, feel free to make your own and programmatically set
	'    'the capture options through interfaces like IAMCrossbar, IAMCameraControl
	'    'etc.
	'
	'    'There are 9 objects that might support property pages.  Let's go through
	'    'them.
	'
	'    ISpecifyPropertyPages *pSpec
	'    CAUUID cauuid
	'
	'    '1. the video capture filter itself
	'
	'    hr = gcap.pVCap->QueryInterface(IID_ISpecifyPropertyPages, (void **)&pSpec)
	'    if (hr = S_OK) {
	'        hr = pSpec->GetPages(&cauuid)
	'        if (hr = S_OK and cauuid.cElems > 0) {
	'	    AppendMenu(hMenuSub,MF_STRING,MENU_DIALOG0+zz, TEXT("Video Capture Filter..."))
	'	    gcap.iVCapDialogPos = zz++
	'	    CoTaskMemFree(cauuid.pElems)
	'	}
	'	pSpec->Release()
	'    }
	'
	'    '2.  The video capture capture pin
	'
	'    IAMStreamConfig *pSC
	'    hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
	'			&MEDIATYPE_Interleaved,
	'			gcap.pVCap, IID_IAMStreamConfig, (void **)&pSC)
	'    if (hr <> S_OK)
	'        hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
	'				&MEDIATYPE_Video, gcap.pVCap,
	'				IID_IAMStreamConfig, (void **)&pSC)
	'    if (hr = S_OK) {
	'        hr = pSC->QueryInterface(IID_ISpecifyPropertyPages, (void **)&pSpec)
	'        if (hr = S_OK) {
	'            hr = pSpec->GetPages(&cauuid)
	'            if (hr = S_OK and cauuid.cElems > 0) {
	'	        AppendMenu(hMenuSub,MF_STRING,MENU_DIALOG0+zz, TEXT("Video Capture Pin..."))
	'	        gcap.iVCapCapturePinDialogPos = zz++
	'	        CoTaskMemFree(cauuid.pElems)
	'	    }
	'	    pSpec->Release()
	'        }
	'	pSC->Release()
	'    }
	'
	'    '3.  The video capture preview pin.
	'    'This basically sets the format being previewed.  Typically, you
	'    'want to capture and preview using the SAME format, instead of having to
	'    'enter the same value in 2 dialog boxes.  For a discussion on this, see
	'    'the comment above the MakePreviewGraph function.
	'
	'    hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_PREVIEW,
	'				&MEDIATYPE_Interleaved, gcap.pVCap,
	'				IID_IAMStreamConfig, (void **)&pSC)
	'    if (hr <> NOERROR)
	'        hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_PREVIEW,
	'				&MEDIATYPE_Video, gcap.pVCap,
	'				IID_IAMStreamConfig, (void **)&pSC)
	'    if (hr = S_OK) {
	'        hr = pSC->QueryInterface(IID_ISpecifyPropertyPages, (void **)&pSpec)
	'        if (hr = S_OK) {
	'            hr = pSpec->GetPages(&cauuid)
	'            If (hr = S_OK and CAUUID.cElems > 0) {
	'	        AppendMenu(hMenuSub,MF_STRING,MENU_DIALOG0+zz,TEXT("Video Preview Pin..."))
	'	        gcap.iVCapPreviewPinDialogPos = zz++
	'		CoTaskMemFree(CAUUID.pElems)
	'	    }
	'	    pSpec->Release()
	'        }
	'	pSC->Release()
	'    }
	'
	'    '4 & 5.  The video crossbar, And a possible Second crossbar
	'
	'    IAMCrossbar *pX, *pX2
	'    IBaseFilter *pXF
	'    hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
	'				&MEDIATYPE_Interleaved, gcap.pVCap,
	'				IID_IAMCrossbar, (VOID **)&pX)
	'    If (hr <> S_OK)
	'        hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
	'				&MEDIATYPE_Video, gcap.pVCap,
	'				IID_IAMCrossbar, (VOID **)&pX)
	'    If (hr = S_OK) {
	'        hr = pX->QueryInterface(IID_IBaseFilter, (VOID **)&pXF)
	'        If (hr = S_OK) {
	'            hr = pX->QueryInterface(IID_ISpecifyPropertyPages, (VOID **)&pSpec)
	'            If (hr = S_OK) {
	'                hr = pSpec->GetPages(&CAUUID)
	'                If (hr = S_OK and CAUUID.cElems > 0) {
	'	            AppendMenu(hMenuSub,MF_STRING,MENU_DIALOG0+zz,
	'						TEXT("Video Crossbar..."))
	'	            gcap.iVCrossbarDialogPos = zz++
	'		    CoTaskMemFree(CAUUID.pElems)
	'	        }
	'	        pSpec->Release()
	'            }
	'            hr = gcap.pBuilder->FindInterface(&LOOK_UPSTREAM_ONLY, NULL, pXF,
	'				IID_IAMCrossbar, (VOID **)&pX2)
	'            If (hr = S_OK) {
	'                hr = pX2->QueryInterface(IID_ISpecifyPropertyPages,
	'							(void **)&pSpec)
	'                if (hr = S_OK) {
	'                    hr = pSpec->GetPages(&cauuid)
	'                    if (hr = S_OK and cauuid.cElems > 0) {
	'	                AppendMenu(hMenuSub,MF_STRING,MENU_DIALOG0+zz,
	'						TEXT("Second Crossbar..."))
	'	                gcap.iACrossbarDialogPos = zz++
	'		        CoTaskMemFree(cauuid.pElems)
	'	            }
	'	            pSpec->Release()
	'                }
	'	        pX2->Release()
	'	    }
	' 	    pXF->Release()
	'        }
	'	pX->Release()
	'    }
	'
	'    '6.  The TVTuner
	'
	'    IAMTVTuner *pTV
	'    hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
	'				&MEDIATYPE_Interleaved, gcap.pVCap,
	'				IID_IAMTVTuner, (void **)&pTV)
	'    if (hr <> S_OK)
	'        hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
	'				&MEDIATYPE_Video, gcap.pVCap,
	'				IID_IAMTVTuner, (void **)&pTV)
	'    if (hr = S_OK) {
	'        hr = pTV->QueryInterface(IID_ISpecifyPropertyPages, (void **)&pSpec)
	'        if (hr = S_OK) {
	'            hr = pSpec->GetPages(&cauuid)
	'            if (hr = S_OK and cauuid.cElems > 0) {
	'	        AppendMenu(hMenuSub,MF_STRING,MENU_DIALOG0+zz, TEXT("TV Tuner..."))
	'	        gcap.iTVTunerDialogPos = zz++
	'		CoTaskMemFree(cauuid.pElems)
	'	    }
	'	    pSpec->Release()
	'        }
	' 	pTV->Release()
	'    }
	'
	'    'no audio capture, we're done
	'    if (gcap.pACap = NULL)
	'	return
	'
	'    '7.  The Audio capture filter itself... Thanks anyway, but we got these already
	'
	'    '8.  The Audio capture pin
	'
	'    hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
	'				&MEDIATYPE_Audio, gcap.pACap,
	'				IID_IAMStreamConfig, (void **)&pSC)
	'    if (hr = S_OK) {
	'        hr = pSC->QueryInterface(IID_ISpecifyPropertyPages, (void **)&pSpec)
	'        if (hr = S_OK) {
	'            hr = pSpec->GetPages(&cauuid)
	'            if (hr = S_OK and cauuid.cElems > 0) {
	'	        AppendMenu(hMenuSub,MF_STRING,MENU_DIALOG0+zz, TEXT("Audio Capture Pin..."))
	'	        gcap.iACapCapturePinDialogPos = zz++
	'		CoTaskMemFree(cauuid.pElems)
	'	    }
	'	    pSpec->Release()
	'        }
	' 	pSC->Release()
	'    }
	'
	'    '9.  The TV Audio filter
	'
	'    IAMTVAudio *pTVA
	'    hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
	'				&MEDIATYPE_Audio, gcap.pACap,
	'				IID_IAMTVAudio, (void **)&pTVA)
	'    if (hr = S_OK) {
	'        hr = pTVA->QueryInterface(IID_ISpecifyPropertyPages, (void **)&pSpec)
	'        if (hr = S_OK) {
	'            hr = pSpec->GetPages(&cauuid)
	'            if (hr = S_OK and cauuid.cElems > 0) {
	'	        AppendMenu(hMenuSub,MF_STRING,MENU_DIALOG0+zz, TEXT("TV Audio..."))
	'	        gcap.iTVAudioDialogPos = zz++
	'		CoTaskMemFree(cauuid.pElems)
	'	    }
	'	    pSpec->Release()
	'        }
	' 	pTVA->Release()
	'    }
	'
	'    '10.  Crossbar class helper menu item, to let you choose an input
	'
	'    if (gcap.pCrossbar and gcap.NumberOfVideoInputs) {
	'        gcap.hMenuPopup = CreatePopupMenu()
	'        LONG j
	'        LONG  PhysicalType
	'        TCHAR buf[MAX_PATH]
	'        LONG InputToEnable = -1
	'
	'	gcap.iVideoInputMenuPos = zz++
	'        AppendMenu(hMenuSub, MF_SEPARATOR, 0, NULL)
	'
	'        for (j = 0 j < gcap.NumberOfVideoInputs j++) {
	'            EXECUTE_ASSERT (S_OK = gcap.pCrossbar->GetInputType (j, &PhysicalType))
	'            EXECUTE_ASSERT (S_OK = gcap.pCrossbar->GetInputName (j, buf, sizeof (buf)))
	'            AppendMenu(gcap.hMenuPopup,MF_STRING,MENU_DIALOG0+zz, buf)
	'            zz++
	'
	'            'Route the first TVTuner by default
	'            if ((PhysicalType = PhysConn_Video_Tuner) and InputToEnable = -1) {
	'                InputToEnable = j
	'            }
	'        }
	'
	'        AppendMenu(hMenuSub, MF_STRING | MF_POPUP, (UINT)gcap.hMenuPopup, TEXT("Video Input"))
	'
	'        if (InputToEnable = -1) {
	'            InputToEnable = 0
	'        }
	'        CheckMenuItem(gcap.hMenuPopup, InputToEnable, MF_BYPOSITION | MF_CHECKED)
	'
	'        gcap.pCrossbar->SetInputIndex (InputToEnable)
	'    }
	'    '!!! anything needed to delete the popup when selecting a new input?
End Sub

'how many captured/dropped so far

Sub UpdateStatus(fAllStats As BOOL)
	'    HRESULT hr
	'    LONG lDropped, lNot, lAvgFrameSize
	'    TCHAR tach[160]
	'
	'    'we use this interface to get the number of captured and dropped frames
	'    'NOTE:  We cannot query for this interface earlier, as it may not be
	'    'available until the pin is connected
	'    if (!gcap.pDF) {
	'	hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
	'				&MEDIATYPE_Interleaved, gcap.pVCap,
	'				IID_IAMDroppedFrames, (void **)&gcap.pDF)
	'	if (hr <> S_OK)
	'	    hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
	'				&MEDIATYPE_Video, gcap.pVCap,
	'				IID_IAMDroppedFrames, (void **)&gcap.pDF)
	'    }
	'
	'    'this filter can't tell us dropped frame info.
	'    if (!gcap.pDF) {
	'	statusUpdateStatus(ghwndStatus,
	'			TEXT("Filter cannot report capture information"))
	'	return
	'    }
	'
	'    hr = gcap.pDF->GetNumDropped(&lDropped)
	'    if (hr = S_OK)
	'	hr = gcap.pDF->GetNumNotDropped(&lNot)
	'    if (hr <> S_OK)
	'	return
	'
	'    lDropped -= gcap.lDroppedBase
	'    lNot -= gcap.lNotBase
	'
	'    if (!fAllStats) {
	'	LONG lTime = timeGetTime() - gcap.lCapmStartTime
	'	wsprintf(tach, TEXT("Captured %d frames (%d dropped) %d.%dsec"), lNot,
	'				lDropped, lTime / 1000,
	'				lTime / 100 - lTime / 1000 * 10)
	'	statusUpdateStatus(ghwndStatus, tach)
	'	return
	'    }
	'
	'    'we want all possible stats, including capture time and actual acheived
	'    'frame rate and data rate (as opposed to what we tried to get).  These
	'    'numbers are an indication that though we dropped frames just now, if we
	'    'chose a data rate and frame rate equal to the numbers I'm about to
	'    'print, we probably wouldn't drop any frames.
	'
	'    'average size of frame captured
	'    hr = gcap.pDF->GetAverageFrameSize(&lAvgFrameSize)
	'    if (hr <> S_OK)
	'	return
	'
	'    'how long capture lasted
	'    LONG lDurMS = gcap.lCapStopTime - gcap.lCapmStartTime
	'    double flFrame     'acheived frame rate
	'    LONG lData         'acheived data rate
	'
	'    if (lDurMS > 0) {
	'	flFrame = (double)(LONGLONG)lNot * 1000. /
	'						(double)(LONGLONG)lDurMS
	'	lData = (LONG)(LONGLONG)(lNot / (double)(LONGLONG)lDurMS *
	'				1000. * (double)(LONGLONG)lAvgFrameSize)
	'    } else {
	'	flFrame = 0.
	'	lData = 0
	'    }
	'
	'    wsprintf(tach, TEXT("Captured %d frames in %d.%d sec (%d dropped): %d.%d fps %d.%d Meg/sec"),
	'		lNot, lDurMS / 1000, lDurMS / 100 - lDurMS / 1000 * 10,
	'		lDropped, (int)flFrame,
	'		(int)(flFrame * 10.) - (int)flFrame * 10,
	'		lData / 1000000,
	'		lData / 1000 - (lData / 1000000 * 1000))
	'    statusUpdateStatus(ghwndStatus, tach)
End Sub

'Check the devices we're currently using and make filters for them

Sub ChooseDevices Overload (pmVideo As IMoniker Ptr, pmAudio As IMoniker Ptr)
	'{
	'    USES_CONVERSION
	'    #define VERSIZE 40
	'    #define DESCSIZE 80
	'    int versize = VERSIZE
	'    int descsize = DESCSIZE
	'    WCHAR wachVer[VERSIZE], wachDesc[DESCSIZE]
	'    TCHAR tachStatus[VERSIZE + DESCSIZE + 5]
	'
	'
	'      'they chose a new device. rebuild the graphs
	'    if (gcap.pmVideo <> pmVideo or gcap.pmAudio <> pmAudio)
	'    {
	'        if(pmVideo) {
	'            pmVideo->AddRef()
	'        }
	'        if(pmAudio) {
	'            pmAudio->AddRef()
	'        }
	'        IMonRelease(gcap.pmVideo)
	'        IMonRelease(gcap.pmAudio)
	'        gcap.pmVideo = pmVideo
	'        gcap.pmAudio = pmAudio
	'        if (gcap.fPreviewing)
	'	        StopPreview()
	'	    if (gcap.fCaptureGraphBuilt or gcap.fPreviewGraphBuilt)
	'	        TearDownGraph()
	'	    FreeCapFilters()
	'	    InitCapFilters()
	'	    if (gcap.fWantPreview) { 'were we previewing?
	'	        BuildPreviewGraph()
	'	        mStartPreview()
	'	    }
	'	    MakeMenuOptions()	'the UI choices change per device
	'    }
	'
	'	'Set the check marks for the devices menu.
	'	int i
	'    for(i = 0 i < NUMELMS(gcap.rgpmVideoMenu) i++) {
	'		if (gcap.rgpmVideoMenu[i] = NULL)
	'			break
	'		CheckMenuItem(  GetMenu(ghwndApp),
	'                MENU_VDEVICE0 + i,
	'                (S_OK = gcap.rgpmVideoMenu[i]->IsEqual(gcap.pmVideo)) ? MF_CHECKED : MF_UNCHECKED)
	'
	'    }
	'
	'    for(i = 0 i < NUMELMS(gcap.rgpmAudioMenu) i++) {
	'		if (gcap.rgpmAudioMenu[i] = NULL)
	'			break
	'		CheckMenuItem(  GetMenu(ghwndApp),
	'                MENU_ADEVICE0 + i,
	'                (S_OK = gcap.rgpmAudioMenu[i]->IsEqual(gcap.pmAudio)) ? MF_CHECKED : MF_UNCHECKED)
	'
	'    }
	'
	'
	'
	'    'Put the video driver name in the status bar - if the filter supports
	'    'IAMVideoCompression::GetInfo, that's the best way to get the name and
	'    'the version.  Otherwise use the name we got from device enumeration
	'    'as a fallback.
	'    if (gcap.pVC) {
	'	HRESULT hr = gcap.pVC->GetInfo(wachVer, &versize, wachDesc, &descsize,
	'							NULL, NULL, NULL, NULL)
	'	if (hr = S_OK) {
	'	    wsprintf(tachStatus, TEXT("%s - %s"), W2T(wachDesc), W2T(wachVer))
	'	    statusUpdateStatus(ghwndStatus, tachStatus)
	'	    return
	'	}
	'    }
	'    statusUpdateStatus(ghwndStatus, W2T(gcap.wachFriendlyName))
End Sub

Sub ChooseDevices Overload (szVideo As CHAR Ptr, szAudio As CHAR Ptr)
	'    WCHAR wszVideo[1024],  wszAudio[1024]
	'    MultiByteToWideChar(CP_ACP, 0, szVideo, -1, wszVideo, NUMELMS(wszVideo))
	'    MultiByteToWideChar(CP_ACP, 0, szAudio, -1, wszAudio, NUMELMS(wszAudio))
	'
	'    IBindCtx *lpBC
	'    HRESULT hr = CreateBindCtx(0, &lpBC)
	'    IMoniker *pmVideo = 0, *pmAudio = 0
	'    if (SUCCEEDED(hr))
	'    {
	'        DWORD dwEaten
	'        hr = MkParseDisplayName(lpBC, wszVideo, &dwEaten,
	'                                &pmVideo)
	'        hr = MkParseDisplayName(lpBC, wszAudio, &dwEaten,
	'                                &pmAudio)
	'
	'        lpBC->Release()
	'    }
	'
	'    'Handle the case where the video capture device used for the previous session
	'    'is not available now.
	'    BOOL bFound = FALSE
	'    if (pmVideo <> NULL)
	'    {
	'            for(int i = 0 i < NUMELMS(gcap.rgpmVideoMenu) i++)
	'            {
	'                if (gcap.rgpmVideoMenu[i] <> NULL and
	'                    S_OK = gcap.rgpmVideoMenu[i]->IsEqual(pmVideo))
	'                {
	'                    bFound = TRUE
	'                    break
	'                }
	'            }
	'    }
	'
	'    if (!bFound)
	'    {
	'        if (gcap.iNumVCapDevices > 0)
	'        {
	'            IMonRelease(pmVideo)
	'            ASSERT(gcap.rgpmVideoMenu[0] <> NULL)
	'            pmVideo = gcap.rgpmVideoMenu[0]
	'            pmVideo->AddRef()
	'        }
	'        else
	'            goto CleanUp
	'    }
	'
	'    ChooseDevices(pmVideo, pmAudio)
	'
	'CleanUp:
	'    IMonRelease(pmVideo)
	'    IMonRelease(pmAudio)
	'}
End Sub

'put all installed video and audio devices in the menus
'void AddDevicesToMenu()
Sub AddDevicesToMenu()
	'{
	'    USES_CONVERSION
	'
	'    if(gcap.fDeviceMenuPopulated) {
	'        return
	'    }
	'    gcap.fDeviceMenuPopulated = true
	'    gcap.iNumVCapDevices = 0
	'
	'    UINT    uIndex = 0
	'    HMENU   hMenuSub
	'    HRESULT hr
	'	BOOL bCheck = FALSE
	'
	'    hMenuSub = GetSubMenu(GetMenu(ghwndApp), 1)        'Devices menu
	'
	'    'Clean the sub menu
	'	int iMenuItems = GetMenuItemCount(hMenuSub)
	'	if (iMenuItems = -1)
	'	{
	'		debug.print("Error Cleaning Devices Menu")
	'		return
	'	}
	'	else if (iMenuItems > 0)
	'	{
	'		for (int i = 0 i < iMenuItems i++)
	'		{
	'			RemoveMenu(hMenuSub, 0, MF_BYPOSITION)
	'		}
	'
	'	}
	'
	'	{
	'        for(int i = 0 i < NUMELMS(gcap.rgpmVideoMenu) i++) {
	'            IMonRelease(gcap.rgpmVideoMenu[i])
	'        }
	'        for( i = 0 i < NUMELMS(gcap.rgpmAudioMenu) i++) {
	'            IMonRelease(gcap.rgpmAudioMenu[i])
	'        }
	'    }
	'
	'
	'    'enumerate all video capture devices
	'    ICreateDevEnum *pCreateDevEnum
	'    hr = CoCreateInstance(CLSID_SystemDeviceEnum, NULL, CLSCTX_INPROC_SERVER,
	'			  IID_ICreateDevEnum, (void**)&pCreateDevEnum)
	'    if (hr <> NOERROR)
	'	{
	'		debug.print("Error Creating Device Enumerator")
	'		return
	'	}
	'
	'    IEnumMoniker *pEm
	'    hr = pCreateDevEnum->CreateClassEnumerator(CLSID_VideoInputDeviceCategory,
	'								&pEm, 0)
	'    if (hr <> NOERROR) {
	'	debug.print("Sorry, you have no video capture hardware")
	'	goto EnumAudio
	'    }
	'    pEm->Reset()
	'    ULONG cFetched
	'    IMoniker *pM
	'    while(hr = pEm->Next(1, &pM, &cFetched), hr=S_OK)
	'    {
	'	IPropertyBag *pBag
	'	hr = pM->BindToStorage(0, 0, IID_IPropertyBag, (void **)&pBag)
	'	if(SUCCEEDED(hr)) {
	'	    VARIANT var
	'	    var.vt = VT_BSTR
	'	    hr = pBag->Read(L"FriendlyName", &var, NULL)
	'	    if (hr = NOERROR) {
	'		AppendMenu(hMenuSub, MF_STRING, MENU_VDEVICE0 + uIndex,
	'							W2T(var.bstrVal))
	'
	'		if (gcap.pmVideo <> 0 and (S_OK = gcap.pmVideo->IsEqual(pM)))
	'			bCheck = TRUE
	'		CheckMenuItem(	hMenuSub,
	'						MENU_VDEVICE0 + uIndex,
	'						(bCheck ? MF_CHECKED : MF_UNCHECKED))
	'		bCheck = False
	'		EnableMenuItem(	hMenuSub,
	'						MENU_VDEVICE0 + uIndex,
	'						(gcap.fCapturing ? MF_DISABLED : MF_ENABLED))
	'
	'
	'		SysFreeString(Var.bstrVal)
	'
	'                Assert(gcap.rgpmVideoMenu[uIndex] = 0)
	'                gcap.rgpmVideoMenu[uIndex] = pM
	'                pM->AddRef()
	'	    }
	'	    pBag->Release()
	'	}
	'	pM->Release()
	'	uIndex++
	'    }
	'    pEm->Release()
	'
	'    gcap.iNumVCapDevices = uIndex
	'
	'    'separate the video And audio devices
	'    AppendMenu(hMenuSub, MF_SEPARATOR, 0, NULL)
	'
	EnumAudio:
	'
	'    'enumerate all audio capture devices
	'    uIndex = 0
	'	bCheck = False
	'
	'	Assert(pCreateDevEnum <> NULL)
	'
	'    hr = pCreateDevEnum->CreateClassEnumerator(CLSID_AudioInputDeviceCategory,
	'								&pEm, 0)
	'    pCreateDevEnum->Release()
	'    If (hr <> NOERROR)
	'	return
	'    pEm->Reset()
	'    while(hr = pEm->Next(1, &pM, &cFetched), hr=S_OK)
	'    {
	'	IPropertyBag *pBag
	'	hr = pM->BindToStorage(0, 0, IID_IPropertyBag, (void **)&pBag)
	'	if(SUCCEEDED(hr)) {
	'	    VARIANT var
	'	    var.vt = VT_BSTR
	'	    hr = pBag->Read(L"FriendlyName", &var, NULL)
	'	    if (hr = NOERROR) {
	'		AppendMenu(hMenuSub, MF_STRING, MENU_ADEVICE0 + uIndex,
	'							W2T(var.bstrVal))
	'
	'		if (gcap.pmAudio <> 0 and (S_OK = gcap.pmAudio->IsEqual(pM)))
	'			bCheck = TRUE
	'		CheckMenuItem(	hMenuSub,
	'						MENU_ADEVICE0 + uIndex,
	'						(bCheck ? MF_CHECKED : MF_UNCHECKED))
	'		bCheck = FALSE
	'		EnableMenuItem(	hMenuSub,
	'						MENU_ADEVICE0 + uIndex,
	'						(gcap.fCapturing ? MF_DISABLED : MF_ENABLED))
	'
	'		SysFreeString(var.bstrVal)
	'
	'                ASSERT(gcap.rgpmAudioMenu[uIndex] = 0)
	'                gcap.rgpmAudioMenu[uIndex] = pM
	'                pM->AddRef()
	'	    }
	'	    pBag->Release()
	'	}
	'	pM->Release()
	'	uIndex++
	'    }
	'    pEm->Release()
End Sub

'let them pick a frame rate

Sub ChooseFrameRate()
	'    double rate = gcap.FrameRate
	'
	'    DoDialog(ghwndApp, IDD_FrameRateDialog, (DLGPROC)FrameRateProc, 0)
	'
	'    HRESULT hr = E_FAIL
	'
	'    'If somebody unchecks "use frame rate" it means we will no longer
	'    'tell the filter what frame rate to use... it will either continue
	'    'using the last one, or use some default, or if you bring up a dialog
	'    'box that has frame rate choices, it will obey them.
	'
	'    'new frame rate?
	'    if (gcap.fUseFrameRate and gcap.FrameRate <> rate) {
	'	if (gcap.fPreviewing)
	'	    StopPreview()
	'	'now tell it what frame rate to capture at.  Just find the format it
	'	'is capturing with, and leave everything else alone
	'	if (gcap.pVSC) {
	'	    AM_MEDIA_TYPE *pmt
	'	    hr = gcap.pVSC->GetFormat(&pmt)
	'	    'DV capture does not use a VIDEOINFOHEADER
	'            if (hr = NOERROR) {
	'		if (pmt->formattype = FORMAT_VideoInfo) {
	'		    VIDEOINFOHEADER *pvi = (VIDEOINFOHEADER *)pmt->pbFormat
	'		    pvi->AvgTimePerFrame =(LONGLONG)(10000000 / gcap.FrameRate)
	'                    hr = gcap.pVSC->SetFormat(pmt)
	'                    if (hr <> S_OK)
	'		        debug.print("%x: Cannot set new frame rate", hr)
	'		}
	'		DeleteMediaType(pmt)
	'	    }
	'	}
	'	if (hr <> NOERROR)
	'	    debug.print("Cannot set frame rate for capture")
	'	if (gcap.fWantPreview)  'we were previewing
	'	    mStartPreview()
	'    }
End Sub

'let them set a capture time limit

Sub ChooseTimeLimit()
	'{
	'    DoDialog(ghwndApp, IDD_TimeLimitDialog, (DLGPROC)TimeLimitProc, 0)
	'}
End Sub

'choose an audio capture format using ACM

Sub ChooseAudioFormat()
	Dim As ACMFORMATCHOOSE cfmt
	Dim As DWORD dwSize
	Dim As LPWAVEFORMATEX lpwfx
	Dim As AM_MEDIA_TYPE Ptr pmt
	
	'there's no point if we can't set a new format
	If (gcap.pASC = NULL) Then Return
	
	'What's the largest format size around?
	acmMetrics(NULL, ACM_METRIC_MAX_SIZE_FORMAT, @dwSize)
	Dim As HRESULT hr = gcap.pASC->lpVtbl->GetFormat(gcap.pASC, @pmt)
	If (hr <> NOERROR) Then Return
	'lpwfx = Cast(LPWAVEFORMATEX, pmt)->pbFormat
	dwSize = Max(dwSize, lpwfx->cbSize + SizeOf(WAVEFORMATEX))
	
	'!!! This doesn't really map to the supported formats of the filter.
	'We should be using a property page based on IAMStreamConfig
	
	'Put up a dialog box initialized with the current format
	'If lpwfx = Cast(LPWAVEFORMATEX, GlobalAllocPtr(GHND, dwSize)) Then
	CopyMemory(lpwfx, pmt->pbFormat, pmt->cbFormat)
	'_fmemset(@cfmt, 0, SizeOf(ACMFORMATCHOOSE))
	cfmt.cbStruct = SizeOf(ACMFORMATCHOOSE)
	cfmt.fdwStyle = ACMFORMATCHOOSE_STYLEF_INITTOWFXSTRUCT
	'show only formats we can capture
	cfmt.fdwEnum = ACM_FORMATENUMF_HARDWARE Or ACM_FORMATENUMF_INPUT
	cfmt.hwndOwner = ghwndApp
	cfmt.pwfx = lpwfx
	cfmt.cbwfx = dwSize
	
	'we chose a new format... so give it to the capture filter
	If (Not ACMFORMATCHOOSE(@cfmt)) Then
		If (gcap.fPreviewing) Then StopPreview()  'can't call IAMStreamConfig::SetFormat
		'while streaming
		'((CMediaType *)pmt)->SetFormat((LPBYTE)lpwfx,lpwfx->cbSize + SizeOf(WAVEFORMATEX))
		'Cast(iAMMediaType Ptr, @pmt)
		
		gcap.pASC->lpVtbl->SetFormat(gcap.pASC, pmt)  'filter will reconnect
		If (gcap.fWantPreview) Then StartPreview()
	End If
	GlobalFreePtr(lpwfx)
	'End If
	'DeleteMediaType(pmt)
End Sub
'
'/*----------------------------------------------------------------------------*\
'|    AppCommand()
'|
'|    Process all of our WM_COMMAND messages.
'\*----------------------------------------------------------------------------*/
'LONG PASCAL AppCommand (HWND hwnd, unsigned msg, WPARAM wParam, LPARAM lParam)
'{
'    HRESULT hr
'    int id = GET_WM_COMMAND_ID(wParam, lParam)
'    switch(id)
'    {
'	'
'	'Our about box
'	'
'	case MENU_ABOUT:
'	    DialogBox(ghInstApp, MAKEINTRESOURCE(IDD_ABOUT), hwnd,
'							(DLGPROC)AboutDlgProc)
'	    break
'
'	'
'	'We want out of here!
'	'
'	case MENU_EXIT:
'	    PostMessage(hwnd,WM_CLOSE,0,0L)
'	    break
'
'	'choose a capture file
'	'
'	case MENU_SET_CAP_FILE:
'	    SetCaptureFile(hwnd)
'	    break
'
'	'pre-allocate the capture file
'	'
'	case MENU_ALLOC_CAP_FILE:
'	    AllocCaptureFile(hwnd)
'	    break
'
'	'save the capture file
'	'
'	case MENU_SAVE_CAP_FILE:
'	    SaveCaptureFile(hwnd)
'	    break
'
'	'mStart capturing
'	'
'	case MENU_mStart_CAP:
'	    if (gcap.fPreviewing)
'		StopPreview()
'	    if (gcap.fPreviewGraphBuilt)
'		TearDownGraph()
'	    BuildCaptureGraph()
'	    mStartCapture()
'	    break
'
'	'toggle preview
'	'
'	case MENU_PREVIEW:
'	    gcap.fWantPreview = !gcap.fWantPreview
'	    if (gcap.fWantPreview) {
'		BuildPreviewGraph()
'		mStartPreview()
'	    } else
'		StopPreview()
'	    break
'
'	'stop capture
'	'
'	case MENU_STOP_CAP:
'	    StopCapture()
'	    if (gcap.fWantPreview) {
'		BuildPreviewGraph()
'		mStartPreview()
'	    }
'	    break
'
'	'select the master stream
'	'
'	case MENU_NOMASTER:
'	    gcap.iMasterStream = -1
'	    if (gcap.pConfigAviMux) {
'		hr = gcap.pConfigAviMux->SetMasterStream(gcap.iMasterStream)
'		if (hr <> NOERROR)
'		    debug.print("SetMasterStream failed!")
'	    }
'	    break
'	case MENU_AUDIOMASTER:
'	    gcap.iMasterStream = 1
'	    if (gcap.pConfigAviMux) {
'		hr = gcap.pConfigAviMux->SetMasterStream(gcap.iMasterStream)
'		if (hr <> NOERROR)
'		    debug.print("SetMasterStream failed!")
'	    }
'	    break
'	case MENU_VIDEOMASTER:
'	    gcap.iMasterStream = 0
'	    if (gcap.pConfigAviMux) {
'		hr = gcap.pConfigAviMux->SetMasterStream(gcap.iMasterStream)
'		if (hr <> NOERROR)
'		    debug.print("SetMasterStream failed!")
'	    }
'	    break
'
'	'toggle capturing audio
'	case MENU_CAP_AUDIO:
'	    if (gcap.fPreviewing)
'		StopPreview()
'	    gcap.fCapAudio = !gcap.fCapAudio
'	    'when we capture we'll need a different graph now
'	    if (gcap.fCaptureGraphBuilt or gcap.fPreviewGraphBuilt)
'		TearDownGraph()
'	    if (gcap.fWantPreview) {
'		BuildPreviewGraph()
'		mStartPreview()
'	    }
'	    break
'
'	'toggle closed captioning
'	case MENU_CAP_CC:
'	    if (gcap.fPreviewing)
'		StopPreview()
'	    gcap.fCapCC = !gcap.fCapCC
'	    'when we capture we'll need a different graph now
'	    if (gcap.fCaptureGraphBuilt or gcap.fPreviewGraphBuilt)
'		TearDownGraph()
'	    if (gcap.fWantPreview) {
'		BuildPreviewGraph()
'		mStartPreview()
'	    }
'	    break
'
'	'choose the audio capture format
'	'
'	case MENU_AUDIOFORMAT:
'	    ChooseAudioFormat()
'	    break
'
'	'pick a frame rate
'	'
'	case MENU_FRAMERATE:
'	    ChooseFrameRate()
'	    break
'
'	'pick a time limit
'	'
'	case MENU_TIMELIMIT:
'	    ChooseTimeLimit()
'	    break
'
'	'pick which video capture device to use
'	'pick which video capture device to use
'	'
'	case MENU_VDEVICE0:
'	case MENU_VDEVICE1:
'	case MENU_VDEVICE2:
'	case MENU_VDEVICE3:
'	case MENU_VDEVICE4:
'	case MENU_VDEVICE5:
'	case MENU_VDEVICE6:
'	case MENU_VDEVICE7:
'	case MENU_VDEVICE8:
'	case MENU_VDEVICE9:
'	    ChooseDevices(gcap.rgpmVideoMenu[id - MENU_VDEVICE0], gcap.pmAudio)
'	    break
'
'	'pick which audio capture device to use
'	'
'	case MENU_ADEVICE0:
'	case MENU_ADEVICE1:
'	case MENU_ADEVICE2:
'	case MENU_ADEVICE3:
'	case MENU_ADEVICE4:
'	case MENU_ADEVICE5:
'	case MENU_ADEVICE6:
'	case MENU_ADEVICE7:
'	case MENU_ADEVICE8:
'	case MENU_ADEVICE9:
'	    ChooseDevices(gcap.pmVideo, gcap.rgpmAudioMenu[id - MENU_ADEVICE0])
'	    break
'
'	'video format dialog
'	'
'	case MENU_DIALOG0:
'	case MENU_DIALOG1:
'	case MENU_DIALOG2:
'	case MENU_DIALOG3:
'	case MENU_DIALOG4:
'	case MENU_DIALOG5:
'	case MENU_DIALOG6:
'	case MENU_DIALOG7:
'	case MENU_DIALOG8:
'	case MENU_DIALOG9:
'	case MENU_DIALOGA:
'	case MENU_DIALOGB:
'	case MENU_DIALOGC:
'	case MENU_DIALOGD:
'	case MENU_DIALOGE:
'	case MENU_DIALOGF:
'
' 	    'they want the VfW format dialog
'	    if (id - MENU_DIALOG0 = gcap.iFormatDialogPos) {
'		'this dialog will not work while previewing
'		if (gcap.fWantPreview)
'		    StopPreview()
'		HRESULT hrD
'	        hrD = gcap.pDlg->ShowDialog(VfwCaptureDialog_Format, ghwndApp)
'		'Oh uh!  Sometimes bringing up the FORMAT dialog can result
'		'in changing to a capture format that the current graph
'		'can't handle.  It looks like that has happened and we'll
'		'have to rebuild the graph.
'		if (hrD = VFW_E_CANNOT_CONNECT) {
'    		    DbgLog((LOG_TRACE,1,TEXT("DIALOG CORRUPTED GRAPH!")))
'		    TearDownGraph()	'now we need to rebuild
'		    '!!! This won't work if we've left a stranded h/w codec
'		}
'
'		'Resize our window to be the same size that we're capturing
'	        if (gcap.pVSC) {
'		    AM_MEDIA_TYPE *pmt
'		    'get format being used NOW
'		    hr = gcap.pVSC->GetFormat(&pmt)
'	    	    'DV capture does not use a VIDEOINFOHEADER
'            	    if (hr = NOERROR) {
'	 		if (pmt->formattype = FORMAT_VideoInfo) {
'		            'resize our window to the new capture size
'		            ResizeWindow(HEADER(pmt->pbFormat)->biWidth,
'					abs(HEADER(pmt->pbFormat)->biHeight))
'			}
'		        DeleteMediaType(pmt)
'		    }
'	        }
'
'	        if (gcap.fWantPreview) {
'		    BuildPreviewGraph()
'		    mStartPreview()
'		}
'	    } else if (id - MENU_DIALOG0 = gcap.iSourceDialogPos) {
'		'this dialog will not work while previewing
'		if (gcap.fWantPreview)
'		    StopPreview()
'	        gcap.pDlg->ShowDialog(VfwCaptureDialog_Source, ghwndApp)
'	        if (gcap.fWantPreview)
'		    mStartPreview()
'	    } else if (id - MENU_DIALOG0 = gcap.iDisplayDialogPos) {
'		'this dialog will not work while previewing
'		if (gcap.fWantPreview)
'		    StopPreview()
'	        gcap.pDlg->ShowDialog(VfwCaptureDialog_Display, ghwndApp)
'	        if (gcap.fWantPreview)
'		    mStartPreview()
'
'	    'now the code for the new dialogs
'
'	    } else if (id - MENU_DIALOG0 = gcap.iVCapDialogPos) {
'		ISpecifyPropertyPages *pSpec
'		CAUUID cauuid
'    	        hr = gcap.pVCap->QueryInterface(IID_ISpecifyPropertyPages,
'							(void **)&pSpec)
'    		if (hr = S_OK) {
'        	    hr = pSpec->GetPages(&cauuid)
'                    hr = OleCreatePropertyFrame(ghwndApp, 30, 30, NULL, 1,
'                    (IUnknown **)&gcap.pVCap, cauuid.cElems,
'		    (GUID *)cauuid.pElems, 0, 0, NULL)
'		    CoTaskMemFree(cauuid.pElems)
'		    pSpec->Release()
'		}
'
'	    } else if (id - MENU_DIALOG0 = gcap.iVCapCapturePinDialogPos) {
'		'You can change this pin's output format in these dialogs.
'		'If the capture pin is already connected to somebody who's
'		'fussy about the connection type, that may prevent using
'		'this dialog(!) because the filter it's connected to might not
'		'allow reconnecting to a new format. (EG: you switch from RGB
'                'to some compressed type, and need to pull in a decoder)
'		'I need to tear down the graph downstream of the
'		'capture filter before bringing up these dialogs.
'		'In any case, the graph must be STOPPED when calling them.
'		if (gcap.fWantPreview)
'		    StopPreview()	'make sure graph is stopped
'			'The capture pin that we are trying to set the format on is connected if
'			'one of these variable is set to TRUE. The pin should be disconnected for
'			'the dialog to work properly.
'			if (gcap.fCaptureGraphBuilt or gcap.fPreviewGraphBuilt) {
'				DbgLog((LOG_TRACE,1,TEXT("Tear down graph for dialog")))
'				TearDownGraph()	'graph could prevent dialog working
'			}
'    		IAMStreamConfig *pSC
'    		hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
'				&MEDIATYPE_Interleaved, gcap.pVCap,
'				IID_IAMStreamConfig, (void **)&pSC)
'	 	if (hr <> NOERROR)
'    		    hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
'				&MEDIATYPE_Video, gcap.pVCap,
'				IID_IAMStreamConfig, (void **)&pSC)
'		ISpecifyPropertyPages *pSpec
'		CAUUID cauuid
'    	        hr = pSC->QueryInterface(IID_ISpecifyPropertyPages,
'							(void **)&pSpec)
'    		if (hr = S_OK) {
'        	    hr = pSpec->GetPages(&cauuid)
'                    hr = OleCreatePropertyFrame(ghwndApp, 30, 30, NULL, 1,
'                    (IUnknown **)&pSC, cauuid.cElems,
'		    (GUID *)cauuid.pElems, 0, 0, NULL)
'
'		    '!!! What if changing output formats couldn't reconnect
'		    'and the graph is broken?  Shouldn't be possible...
'
'	            if (gcap.pVSC) {
'		        AM_MEDIA_TYPE *pmt
'		        'get format being used NOW
'		        hr = gcap.pVSC->GetFormat(&pmt)
'	    	        'DV capture does not use a VIDEOINFOHEADER
'            	        if (hr = NOERROR) {
'	 		    if (pmt->formattype = FORMAT_VideoInfo) {
'		                'resize our window to the new capture size
'		                ResizeWindow(HEADER(pmt->pbFormat)->biWidth,
'					  abs(HEADER(pmt->pbFormat)->biHeight))
'			    }
'		            DeleteMediaType(pmt)
'		        }
'	            }
'
'		    CoTaskMemFree(cauuid.pElems)
'		    pSpec->Release()
'		}
'		pSC->Release()
'	        if (gcap.fWantPreview) {
'		    BuildPreviewGraph()
'		    mStartPreview()
'		}
'
'
'	    } else if (id - MENU_DIALOG0 = gcap.iVCapPreviewPinDialogPos) {
'		'this dialog may not work if the preview pin is connected
'		'already, because the downstream filter may reject a format
'		'change, so we better kill the graph. (EG: We switch from
'                'capturing RGB to some compressed fmt, and need to pull in
'                'a decompressor)
'		if (gcap.fWantPreview) {
'		    StopPreview()
'		    TearDownGraph()
'		}
'    		IAMStreamConfig *pSC
'		'This dialog changes the preview format, so it might affect
'		'the format being drawn.  Our app's window size is taken
'		'from the size of the capture pin's video, not the preview
'		'pin, so changing that here won't have any effect. All in all,
'		'this probably won't be a terribly useful dialog in this app.
'    		hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_PREVIEW,
'				&MEDIATYPE_Interleaved, gcap.pVCap,
'				IID_IAMStreamConfig, (void **)&pSC)
'		if (hr <> NOERROR)
'    		    hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_PREVIEW,
'				&MEDIATYPE_Video, gcap.pVCap,
'				IID_IAMStreamConfig, (void **)&pSC)
'		ISpecifyPropertyPages *pSpec
'		CAUUID cauuid
'    	        hr = pSC->QueryInterface(IID_ISpecifyPropertyPages,
'							(void **)&pSpec)
'    		if (hr = S_OK) {
'        	    hr = pSpec->GetPages(&cauuid)
'                    hr = OleCreatePropertyFrame(ghwndApp, 30, 30, NULL, 1,
'                    (IUnknown **)&pSC, cauuid.cElems,
'		    (GUID *)cauuid.pElems, 0, 0, NULL)
'		    CoTaskMemFree(cauuid.pElems)
'		    pSpec->Release()
'		}
'		pSC->Release()
'		if (gcap.fWantPreview) {
'		    BuildPreviewGraph()
'		    mStartPreview()
'		}
'
'	    } else if (id - MENU_DIALOG0 = gcap.iVCrossbarDialogPos) {
'    		IAMCrossbar *pX
'    		hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
'				&MEDIATYPE_Interleaved, gcap.pVCap,
'				IID_IAMCrossbar, (void **)&pX)
'		if (hr <> NOERROR)
'    		    hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
'				&MEDIATYPE_Video, gcap.pVCap,
'				IID_IAMCrossbar, (void **)&pX)
'		ISpecifyPropertyPages *pSpec
'		CAUUID cauuid
'    	        hr = pX->QueryInterface(IID_ISpecifyPropertyPages,
'							(void **)&pSpec)
'    		if (hr = S_OK) {
'        	    hr = pSpec->GetPages(&cauuid)
'                    hr = OleCreatePropertyFrame(ghwndApp, 30, 30, NULL, 1,
'                    (IUnknown **)&pX, cauuid.cElems,
'		    (GUID *)cauuid.pElems, 0, 0, NULL)
'		    CoTaskMemFree(cauuid.pElems)
'		    pSpec->Release()
'		}
'		pX->Release()
'
'	    } else if (id - MENU_DIALOG0 = gcap.iTVTunerDialogPos) {
'    		IAMTVTuner *pTV
'    		hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
'				&MEDIATYPE_Interleaved, gcap.pVCap,
'				IID_IAMTVTuner, (void **)&pTV)
'		if (hr <> NOERROR)
'    		    hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
'				&MEDIATYPE_Video, gcap.pVCap,
'				IID_IAMTVTuner, (void **)&pTV)
'		ISpecifyPropertyPages *pSpec
'		CAUUID cauuid
'    	        hr = pTV->QueryInterface(IID_ISpecifyPropertyPages,
'							(void **)&pSpec)
'    		if (hr = S_OK) {
'        	    hr = pSpec->GetPages(&cauuid)
'                    hr = OleCreatePropertyFrame(ghwndApp, 30, 30, NULL, 1,
'                    (IUnknown **)&pTV, cauuid.cElems,
'		    (GUID *)cauuid.pElems, 0, 0, NULL)
'		    CoTaskMemFree(cauuid.pElems)
'		    pSpec->Release()
'		}
'		pTV->Release()
'
'	    } else if (id - MENU_DIALOG0 = gcap.iACapDialogPos) {
'		ISpecifyPropertyPages *pSpec
'		CAUUID cauuid
'    	        hr = gcap.pACap->QueryInterface(IID_ISpecifyPropertyPages,
'							(void **)&pSpec)
'    		if (hr = S_OK) {
'        	    hr = pSpec->GetPages(&cauuid)
'                    hr = OleCreatePropertyFrame(ghwndApp, 30, 30, NULL, 1,
'                    (IUnknown **)&gcap.pACap, cauuid.cElems,
'		    (GUID *)cauuid.pElems, 0, 0, NULL)
'		    CoTaskMemFree(cauuid.pElems)
'		    pSpec->Release()
'		}
'
'	    } else if (id - MENU_DIALOG0 = gcap.iACapCapturePinDialogPos) {
'		'this dialog will not work while previewing - it might change
'		'the output format!
'		if (gcap.fWantPreview)
'		    StopPreview()
'    		IAMStreamConfig *pSC
'    		hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
'				&MEDIATYPE_Audio, gcap.pACap,
'				IID_IAMStreamConfig, (void **)&pSC)
'		ISpecifyPropertyPages *pSpec
'		CAUUID cauuid
'    	        hr = pSC->QueryInterface(IID_ISpecifyPropertyPages,
'							(void **)&pSpec)
'    		if (hr = S_OK) {
'        	    hr = pSpec->GetPages(&cauuid)
'                    hr = OleCreatePropertyFrame(ghwndApp, 30, 30, NULL, 1,
'                    (IUnknown **)&pSC, cauuid.cElems,
'		    (GUID *)cauuid.pElems, 0, 0, NULL)
'		    CoTaskMemFree(cauuid.pElems)
'		    pSpec->Release()
'		}
'		pSC->Release()
'	        if (gcap.fWantPreview)
'		    mStartPreview()
'
'	    } else if (id - MENU_DIALOG0 = gcap.iACrossbarDialogPos) {
'    		IAMCrossbar *pX, *pX2
'		IBaseFilter *pXF
'		'we could use better Error checking here... I'm assuming
'		'This won't fail
'    		hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
'				&MEDIATYPE_Interleaved, gcap.pVCap,
'				IID_IAMCrossbar, (VOID **)&pX)
'		If (hr <> NOERROR)
'    		    hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
'				&MEDIATYPE_Video, gcap.pVCap,
'				IID_IAMCrossbar, (VOID **)&pX)
'		hr = pX->QueryInterface(IID_IBaseFilter, (VOID **)&pXF)
'    		hr = gcap.pBuilder->FindInterface(&LOOK_UPSTREAM_ONLY, NULL,
'				pXF, IID_IAMCrossbar, (VOID **)&pX2)
'		ISpecifyPropertyPages *pSpec
'		CAUUID CAUUID
'    	        hr = pX2->QueryInterface(IID_ISpecifyPropertyPages,
'							(VOID **)&pSpec)
'    		If (hr = S_OK) {
'        	    hr = pSpec->GetPages(&CAUUID)
'                    hr = OleCreatePropertyFrame(ghwndApp, 30, 30, NULL, 1,
'                    (IUnknown **)&pX2, CAUUID.cElems,
'		    (GUID *)CAUUID.pElems, 0, 0, NULL)
'		    CoTaskMemFree(CAUUID.pElems)
'		    pSpec->Release()
'		}
'		pX2->Release()
'		pXF->Release()
'		pX->Release()
'
'	    } Else If (id - MENU_DIALOG0 = gcap.iTVAudioDialogPos) {
'    		IAMTVAudio *pTVA
'    		hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
'				&MEDIATYPE_Audio, gcap.pACap,
'				IID_IAMTVAudio, (VOID **)&pTVA)
'		ISpecifyPropertyPages *pSpec
'		CAUUID CAUUID
'    	        hr = pTVA->QueryInterface(IID_ISpecifyPropertyPages,
'							(VOID **)&pSpec)
'    		If (hr = S_OK) {
'        	    hr = pSpec->GetPages(&cauuid)
'                    hr = OleCreatePropertyFrame(ghwndApp, 30, 30, NULL, 1,
'                    (IUnknown **)&pTVA, cauuid.cElems,
'		    (GUID *)cauuid.pElems, 0, 0, NULL)
'		    CoTaskMemFree(cauuid.pElems)
'		    pSpec->Release()
'		}
'		pTVA->Release()
'
'        } else if (((id - MENU_DIALOG0) >  gcap.iVideoInputMenuPos) and
'                    (id - MENU_DIALOG0) <= gcap.iVideoInputMenuPos + gcap.NumberOfVideoInputs) {
'            'Remove existing checks
'            for (int j = 0 j < gcap.NumberOfVideoInputs j++) {
'
'                CheckMenuItem(gcap.hMenuPopup, j, MF_BYPOSITION |
'                              ((j = (id - MENU_DIALOG0) - gcap.iVideoInputMenuPos - 1) ?
'                              MF_CHECKED : MF_UNCHECKED ))
'            }
'
'            if (gcap.pCrossbar) {
'                EXECUTE_ASSERT (S_OK = gcap.pCrossbar->SetInputIndex ((id - MENU_DIALOG0) - gcap.iVideoInputMenuPos - 1))
'            }
'
'	}
'
'	break
'
'    }
'    return 0L
'}
'
'
'/*----------------------------------------------------------------------------*\
'|   debug.print - Opens a Message box with a error message in it.  The user can     |
'|            select the OK button to continue                                  |
'\*----------------------------------------------------------------------------*/
'Function debug.print (sz As LPTSTR, ...) As Integer
'{
'    Static TCHAR tach[2000]
'    va_list va
'
'    va_mStart(va, sz)
'    wvsprintf (tach, sz, va)
'    va_end(va)
'    MessageBox(ghwndApp, tach, NULL, MB_OK|MB_ICONEXCLAMATION|MB_TASKMODAL)
'    Return False
'End Function
'
'
'/* AboutDlgProc()
' *
' * Dialog Procedure for the "about" dialog box.
' *
' */
'
'BOOL CALLBACK AboutDlgProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
'{
'	switch (msg) {
'	case WM_COMMAND:
'		EndDialog(hwnd, TRUE)
'		return TRUE
'	case WM_INITDIALOG:
'		return TRUE
'	}
'	return FALSE
'}
'
'
''pre-allocate the capture file
''
Function AllocCaptureFile(HWND As HWND) As BOOL
	
	'    USES_CONVERSION
	'
	'    'we'll get into an infinite loop in the dlg proc setting a value
	'    if (gcap.szCaptureFile[0] = 0)
	'	return FALSE
	'
	'    /*
	'     * show the allocate file space dialog to encourage
	'     * the user to pre-allocate space
	'     */
	'    if (DoDialog(hWnd, IDD_AllocCapFileSpace, (DLGPROC)AllocCapFileProc, 0)) {
	'
	'	'ensure repaint after dismissing dialog before
	'	'possibly lengthy operation
	'	UpdateWindow(ghwndApp)
	'
	'	'User has hit OK. Alloc requested capture file space
	'	BOOL f = MakeBuilder()
	'	if (!f)
	'	    return FALSE
	'	if (gcap.pBuilder->AllocCapFile(T2W(gcap.szCaptureFile),
	'		(DWORDLONG)gcap.wCapFileSize * 1024L * 1024L) <> NOERROR) {
	'	    MessageBox(ghwndApp, TEXT("Error"),
	'			TEXT("Failed to pre-allocate capture file space"),
	'			MB_OK | MB_ICONEXCLAMATION)
	'	    return FALSE
	'	}
	'	return TRUE
	'    } else {
	Return False
	'    }
End Function
'
'/*
' * Put up the open file dialog
' */
'BOOL OpenFileDialog(HWND hWnd, LPTSTR pszName, int cb)
'{
'    OPENFILENAME ofn
'    LPTSTR p
'    TCHAR        szFileName[_MAX_PATH]
'    TCHAR        szBuffer[_MAX_PATH]
'
'    if (pszName = NULL or cb <= 0)
'	return FALSE
'
'    'mStart with capture file as current file name
'    szFileName[0] = 0
'    lstrcpy(szFileName, gcap.szCaptureFile)
'
'    'Get just the path info
'    'Terminate the full path at the last backslash
'    lstrcpy(szBuffer, szFileName)
'    for (p = szBuffer + lstrlen(szBuffer) p > szBuffer p--) {
'	if (*p = '\\') {
'	    *(p+1) = '\0'
'	    break
'	}
'    }
'
'    _fmemset(&ofn, 0, sizeof(OPENFILENAME))
'    ofn.lStructSize = sizeof(OPENFILENAME)
'    ofn.hwndOwner = hWnd
'    ofn.lpstrFilter = "Microsoft AVI\0*.avi\0\0"
'    ofn.nFilterIndex = 0
'    ofn.lpstrFile = szFileName
'    ofn.nMaxFile = sizeof(szFileName)
'    ofn.lpstrFileTitle = NULL
'    ofn.lpstrTitle = "Set Capture File"
'    ofn.nMaxFileTitle = 0
'    ofn.lpstrInitialDir = szBuffer
'    ofn.Flags = OFN_HIDEREADONLY | OFN_NOREADONLYRETURN | OFN_PATHMUSTEXIST
'
'    if (GetOpenFileName(&ofn)) {
'	'We have a capture file name
'	lstrcpyn(pszName, szFileName, cb)
'	return TRUE
'    } else {
'	return FALSE
'    }
'}
'
'
'/*
' * Put up a dialog to allow the user to select a capture file.
' */
Function SetCaptureFile(HWND As HWND) As BOOL
	'{
	'    USES_CONVERSION
	'
	'    if (OpenFileDialog(hWnd, gcap.szCaptureFile, _MAX_PATH)) {
	'	OFSTRUCT os
	'
	'	'We have a capture file name
	'
	'	/*
	'	 * if this is a new file, then invite the user to
	'	 * allocate some space
	'	 */
	'	if (OpenFile(gcap.szCaptureFile, &os, OF_EXIST) = HFILE_ERROR) {
	'
	'	    'bring up dialog, and set new file size
	'	    BOOL f = AllocCaptureFile(hWnd)
	'	    if (!f)
	'		return FALSE
	'	}
	'    } else {
	'	return FALSE
	'    }
	'
	'    SetAppCaption()    'new a new app caption
	'
	'    'tell the file writer to use the new filename
	'    if (gcap.pSink) {
	'	gcap.pSink->SetFileName(T2W(gcap.szCaptureFile), NULL)
	'    }
	'
	Return True
End Function
'
'
'/*
' * Put up a dialog to allow the user to save the contents of the capture file
' * elsewhere
' */
Function SaveCaptureFile(HWND As HWND) As BOOL
	'    HRESULT hr
	'    TCHAR tachDstFile[_MAX_PATH]
	'
	'    if (gcap.pBuilder = NULL)
	'	return FALSE
	'
	'    if (OpenFileDialog(hWnd, tachDstFile, _MAX_PATH)) {
	'
	'	'We have a capture file name
	'	statusUpdateStatus(ghwndStatus, TEXT("Saving capture file - please wait..."))
	'
	'	'we need our own graph builder because the main one might not exist
	'	ICaptureGraphBuilder2 *pBuilder
	'	hr = CoCreateInstance((REFCLSID)CLSID_CaptureGraphBuilder2,
	'			NULL, CLSCTX_INPROC, (REFIID)IID_ICaptureGraphBuilder2,
	'			(void **)&pBuilder)
	'
	'	if (hr = NOERROR) {
	'	    'allow the user to press ESC to abort... ask for progress
	'        CProgress *pProg = new CProgress(TEXT(""), NULL, &hr)
	'        IAMCopyCaptureFileProgress *pIProg = NULL
	'        if (pProg) {
	'            hr = pProg->QueryInterface(IID_IAMCopyCaptureFileProgress,
	'                                            (void **)&pIProg)
	'        }
	'	    hr = pBuilder->CopyCaptureFile(T2W(gcap.szCaptureFile),
	'                                       T2W(tachDstFile), TRUE, pIProg)
	'        if (pIProg)
	'            pIProg->Release()
	'	    pBuilder->Release()
	'	}
	'
	'	if (hr = S_OK)
	'	    statusUpdateStatus(ghwndStatus, "Capture file saved")
	'	else if (hr = S_FALSE)
	'	    statusUpdateStatus(ghwndStatus, "Capture file save aborted")
	'	else
	'	    statusUpdateStatus(ghwndStatus, "Capture file save ERROR")
	'	return (hr = NOERROR ? TRUE : FALSE)
	'
	'    } else {
	Return True    'they cancelled or something
	'    }
End Function
'
''brings up a dialog box
''
'Function DoDialog(hwndParent As HWND,DialogID As Integer,fnDialog As DLGPROC,LPARAM As Long) As Integer
'	Dim As DLGPROC fn
'	Dim As Integer result
'	
'	fn = Cast(DLGPROC, MakeProcInstance(fnDialog, ghInstApp))
'	result = DialogBoxParam(ghInstApp, MAKEINTRESOURCE(DialogID), hwndParent, fn, LPARAM)
'	FreeProcInstance(fn)
'	
'	Return result
'End Function
'
'
''
''GetFreeDiskSpace: Function to Measure Available Disk Space
''
'static long GetFreeDiskSpaceInKB(LPSTR pFile)
'{
'    DWORD dwFreeClusters, dwBytesPerSector, dwSectorsPerCluster, dwClusters
'    char RootName[MAX_PATH]
'    LPSTR ptmp    'required arg
'    ULARGE_INTEGER ulA, ulB, ulFreeBytes
'
'    'need to find path for root directory on drive containing
'    'this file.
'
'    GetFullPathName(pFile, sizeof(RootName), RootName, &ptmp)
'
'    'truncate this to the name of the root directory (god how tedious)
'    if (RootName[0] = '\\' and RootName[1] = '\\') {
'
'	'path begins with  \\server\share\path so skip the first
'	'three backslashes
'	ptmp = &RootName[2]
'	while (*ptmp and (*ptmp <> '\\')) {
'	    ptmp++
'	}
'	if (*ptmp) {
'	    'advance past the third backslash
'	    ptmp++
'	}
'    } else {
'	'path must be drv:\path
'	ptmp = RootName
'    }
'
'    'find next backslash and put a null after it
'    while (*ptmp and (*ptmp <> '\\')) {
'	ptmp++
'    }
'    'found a backslash ?
'    If (*ptmp) {
'	'skip it And insert NULL
'	ptmp++
'	*ptmp = '\0'
'    }
'
'    'the only real way of finding Out free disk Space is calling
'    'GetDiskFreeSpaceExA, but it doesn't exist on Win95
'
'    HINSTANCE h = LoadLibrary(TEXT("kernel32.dll"))
'    If (h) {
'	typedef BOOL (WINAPI *MyFunc)(LPCSTR RootName, PULARGE_INTEGER pulA, PULARGE_INTEGER pulB, PULARGE_INTEGER pulFreeBytes)
'	MyFunc pfnGetDiskFreeSpaceEx = (MyFunc)GetProcAddress(h,
'						"GetDiskFreeSpaceExA")
'	FreeLibrary(h)
'	If (pfnGetDiskFreeSpaceEx) {
'	    If (!pfnGetDiskFreeSpaceEx(RootName, &ulA, &ulB, &ulFreeBytes))
'		Return -1
'	    Return (Long)(ulFreeBytes.QuadPart / 1024)
'	}
'    }
'
'    If (!GetDiskFreeSpace(RootName, &dwSectorsPerCluster, &dwBytesPerSector,
'					&dwFreeClusters, &dwClusters))
'	Return (-1)
'    Return(MulDiv(dwSectorsPerCluster * dwBytesPerSector,
'		   dwFreeClusters,
'		   1024))
'}
'
'
'
''AllocCapFileProc: Capture file Space Allocation Dialog Box Procedure
''
'Int FAR pascal AllocCapFileProc(HWND hDlg, UINT Message, UINT WPARAM, Long LPARAM)
'{
'    Static Int      nFreeMBs = 0
'
'    switch (Message) {
'	case WM_INITDIALOG:
'	{
'	    DWORDLONG        dwlFileSize = 0
'	    long             lFreeSpaceInKB
'
'	    'Get current capture file name and measure its size
'	    dwlFileSize = GetSize(gcap.szCaptureFile)
'
'	    'Get free disk space and add current capture file size to that.
'	    'Convert the available space to MBs.
'	    if ((lFreeSpaceInKB =
'			GetFreeDiskSpaceInKB(gcap.szCaptureFile)) <> -1L) {
'		lFreeSpaceInKB += (long)(dwlFileSize / 1024)
'		nFreeMBs = lFreeSpaceInKB / 1024
'		SetDlgItemInt(hDlg, IDD_SetCapFileFree, nFreeMBs, TRUE)
'	    } else {
'		EnableWindow(GetDlgItem(hDlg, IDD_SetCapFileFree), FALSE)
'	    }
'
'	    gcap.wCapFileSize = (WORD) (dwlFileSize / (1024L * 1024L))
'
'	    SetDlgItemInt(hDlg, IDD_SetCapFileSize, gcap.wCapFileSize, TRUE)
'	    return TRUE
'	}
'
'	case WM_COMMAND :
'	    switch (GET_WM_COMMAND_ID(wParam, lParam)) {
'		case IDOK :
'		{
'		    int         iCapFileSize
'
'		    iCapFileSize = (int) GetDlgItemInt(hDlg, IDD_SetCapFileSize, NULL, TRUE)
'		    if (iCapFileSize <= 0 or iCapFileSize > nFreeMBs) {
'			'You are asking for more than we have !! Sorry, ...
'			SetDlgItemInt(hDlg, IDD_SetCapFileSize, iCapFileSize, TRUE)
'			SetFocus(GetDlgItem(hDlg, IDD_SetCapFileSize))
'			MessageBeep(MB_ICONEXCLAMATION)
'			return FALSE
'		    }
'		    gcap.wCapFileSize = (WORD)iCapFileSize
'
'		    EndDialog(hDlg, TRUE)
'		    return TRUE
'		}
'
'		case IDCANCEL :
'		    EndDialog(hDlg, FALSE)
'		    return TRUE
'
'		case IDD_SetCapFileSize:
'		{
'		    long l
'		    BOOL bchanged
'		    TCHAR tachBuffer[21]
'
'		    'check that entered size is a valid number
'		    GetDlgItemText(hDlg, IDD_SetCapFileSize, tachBuffer,
'                                                        sizeof(tachBuffer))
'		    l = atol(tachBuffer)
'		    bchanged = FALSE
'		    if (l < 1) {
'			l = 1
'			bchanged = TRUE
'		    'don't infinite loop if there's < 1 Meg free
'		    } else if (l > nFreeMBs and nFreeMBs > 0) {
'			l = nFreeMBs
'			bchanged = TRUE
'		    } else {
'			'make sure there are no non-digit chars
'			'atol() will ignore trailing non-digit characters
'			int c = 0
'			while (tachBuffer[c]) {
'			    if (IsCharAlpha(tachBuffer[c]) or
'				!IsCharAlphaNumeric(tachBuffer[c])) {
'
'				'string contains non-digit chars - reset
'				l = 1
'				bchanged = TRUE
'				break
'			    }
'			    c++
'			}
'		    }
'		    if (bchanged) {
'			wsprintf(tachBuffer, TEXT("%ld"), l)
'			SetDlgItemText(hDlg, IDD_SetCapFileSize, tachBuffer)
'		    }
'		    break
'		}
'	    }
'	    break
'    }
'
'    return FALSE
'}
'
'
''
''FrameRateProc: Choose a frame rate
''
'int FAR PASCAL FrameRateProc(HWND hwnd, UINT msg, UINT wParam, LONG lParam)
'{
'  TCHAR  tach[32]
'
'  switch (msg) {
'    case WM_INITDIALOG:
'	/* put the current frame rate in the box */
'	sprintf(tach, TEXT("%f"), gcap.FrameRate, tach)
'	SetDlgItemText(hwnd, IDC_FRAMERATE, tach)
'	CheckDlgButton(hwnd, IDC_USEFRAMERATE, gcap.fUseFrameRate)
'	break
'
'    Case WM_COMMAND:
'	switch(WPARAM){
'	    Case IDCANCEL:
'		EndDialog(HWND, False)
'		break
'
'	    Case IDOK:
'		/* Get the New frame rate */
'		GetDlgItemText(HWND, IDC_FRAMERATE, tach, SizeOf(tach))
'		If (atof(tach) <= 0.) {
'		    debug.print("Invalid frame rate.")
'		    break
'		}
'		gcap.FrameRate = atof(tach)
'		gcap.fUseFrameRate = IsDlgButtonChecked(HWND, IDC_USEFRAMERATE)
'		EndDialog(HWND, True)
'		break
'	}
'	break
'
'    default:
'	Return False
'  }
'  Return True
'}
'
'
''
''TimeLimitProc: Choose a capture Time limit
''
'Int FAR pascal TimeLimitProc(HWND HWND, UINT MSG, UINT WPARAM, Long LPARAM)
'{
'  TCHAR   tach[32]
'  DWORD   dwTimeLimit
'
'  switch (MSG) {
'    Case WM_INITDIALOG:
'	/* Put the current Time limit info in the boxes */
'	sprintf(tach, TEXT("%d"), gcap.dwTimeLimit, tach)
'	SetDlgItemText(hwnd, IDC_TIMELIMIT, tach)
'	CheckDlgButton(hwnd, IDC_USETIMELIMIT, gcap.fUseTimeLimit)
'	break
'
'    case WM_COMMAND:
'	switch(wParam){
'	    case IDCANCEL:
'		EndDialog(hwnd, FALSE)
'		break
'
'	    case IDOK:
'		/* get the new time limit */
'		dwTimeLimit = GetDlgItemInt(hwnd, IDC_TIMELIMIT, NULL, FALSE)
'		gcap.dwTimeLimit = dwTimeLimit
'		gcap.fUseTimeLimit = IsDlgButtonChecked(hwnd, IDC_USETIMELIMIT)
'		EndDialog(hwnd, TRUE)
'		break
'	}
'	break
'
'    default:
'	return FALSE
'  }
'  Return True
'}
'
'
''
''PressAKeyProc: Press OK To capture
''
'Int FAR pascal PressAKeyProc(HWND HWND, UINT MSG, UINT WPARAM, Long LPARAM)
'{
'  TCHAR tach[_MAX_PATH]
'
'  switch (MSG) {
'    Case WM_INITDIALOG:
'	/* set the current file Name in the box */
'	wsprintf(tach, TEXT("%s"), gcap.szCaptureFile)
'	SetDlgItemText(HWND, IDC_CAPFILENAME, tach)
'	break
'
'    Case WM_COMMAND:
'	switch(WPARAM){
'	    Case IDCANCEL:
'		EndDialog(HWND, False)
'		break
'
'	    Case IDOK:
'		EndDialog(HWND, True)
'		break
'	}
'	break
'
'    default:
'	Return False
'  }
'  Return True
'}
'
Function GetSize(tach As LPCTSTR) As DWORDLONG
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

