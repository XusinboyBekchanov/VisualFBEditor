'Monitor显示器
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "Monitor.bi"

Private Function EDSEdwFlags(Index As Integer) As DWORD
	Select Case Index
	Case 0
		Function = EDS_RAWMODE
	Case 1
		Function = EDS_ROTATEDMODE
	End Select
End Function

Private Function CDSdwFlags(Index As Integer) As DWORD
	Select Case Index
	Case 0
		Function = 0
	Case 1
		Function = CDS_FULLSCREEN
	Case 2
		Function = CDS_GLOBAL
	Case 3
		Function = CDS_NORESET
	Case 4
		Function = CDS_RESET
	Case 5
		Function = CDS_SET_PRIMARY
	Case 6
		Function = CDS_TEST
	Case 7
		Function = CDS_UPDATEREGISTRY
	Case 8
		Function = CDS_VIDEOPARAMETERS
	Case 9
		Function = CDS_ENABLE_UNSAFE_MODES
	Case 10
		Function = CDS_DISABLE_UNSAFE_MODES
	End Select
End Function

Private Function ScanOrderWStr(tpy As DISPLAYCONFIG_SCANLINE_ORDERING) ByRef As WString
	Select Case tpy
	Case DISPLAYCONFIG_SCANLINE_ORDERING_UNSPECIFIED
		Return "UNSPECIFIED"
	Case DISPLAYCONFIG_SCANLINE_ORDERING_PROGRESSIVE
		Return "PROGRESSIVE"
	Case DISPLAYCONFIG_SCANLINE_ORDERING_INTERLACED
		Return "INTERLACED"
	Case DISPLAYCONFIG_SCANLINE_ORDERING_INTERLACED_UPPERFIELDFIRST
		Return "UPPERFIELDFIRST"
	Case DISPLAYCONFIG_SCANLINE_ORDERING_INTERLACED_LOWERFIELDFIRST
		Return "LOWERFIELDFIRST"
	Case DISPLAYCONFIG_SCANLINE_ORDERING_FORCE_UINT32
		Return "FORCE_UINT32"
	Case Else
		Return "Unknow"
	End Select
End Function

Private Function OutPutWStr(tpy As DISPLAYCONFIG_VIDEO_OUTPUT_TECHNOLOGY) ByRef As WString
	Select Case tpy
	Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_OTHER
		Return "OTHER"
	Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_HD15
		Return "HD15(VGA)"
	Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_SVIDEO
		Return "SVIDEO"
	Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_COMPOSITE_VIDEO
		Return "COMPOSITE_VIDEO"
	Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_COMPONENT_VIDEO
		Return "COMPONENT_VIDEO"
	Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_DVI
		Return "DVI"
	Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_HDMI
		Return "HDMI"
	Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_LVDS
		Return "LVDS"
	Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_D_JPN
		Return "D_JPN"
	Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_SDI
		Return "SDI"
	Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_DISPLAYPORT_EXTERNAL
		Return "DISPLAYPORT_EXTERNAL"
	Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_DISPLAYPORT_EMBEDDED
		Return "DISPLAYPORT_EMBEDDED"
	Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_UDI_EXTERNAL
		Return "UDI_EXTERNAL"
	Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_UDI_EMBEDDED
		Return "UDI_EMBEDDED"
	Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_SDTVDONGLE
		Return "SDTVDONGLE"
		'Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_MIRACAST
		'	Return "MIRACAST"
		'Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_INDIRECT_WIRED
		'	Return "INDIRECT_WIRED"
		'Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_INDIRECT_VIRTUAL
		'	Return "INDIRECT_VIRTUAL"
		'Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_DISPLAYPORT_USB_TUNNEL
		'	Return "DISPLAYPORT_USB_TUNNEL"
	Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_INTERNAL
		Return "INTERNAL"
	Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_FORCE_UINT32
		Return "FORCE_UINT32"
	Case Else
		Return "Unknow"
	End Select
End Function

Private Sub RECT2WStr(ret As tagRECT, txt As TextBox Ptr, ByVal h As String = "")
	txt->AddLine h & "Left:     " & ret.left
	txt->AddLine h & "Right:    " & ret.right
	txt->AddLine h & "Top:      " & ret.top
	txt->AddLine h & "Bottom:   " & ret.bottom
End Sub

Private Sub Path2WStr(PathInfo As DISPLAYCONFIG_PATH_INFO, txt As TextBox Ptr)
	txt->AddLine "FLAGS: " & PathInfo.flags
	txt->AddLine "sourceInfo.adapterId.HighPart: " & PathInfo.sourceInfo.adapterId.HighPart
	txt->AddLine "sourceInfo.adapterId.LowPart: " & PathInfo.sourceInfo.adapterId.LowPart
	txt->AddLine "sourceInfo.id: " & PathInfo.sourceInfo.id
	txt->AddLine "sourceInfo.modeInfoIdx: " & PathInfo.sourceInfo.modeInfoIdx
	txt->AddLine "sourceInfo.statusFlags: " & PathInfo.sourceInfo.statusFlags
	txt->AddLine "targetInfo.adapterId.HighPart: " & PathInfo.targetInfo.adapterId.HighPart
	txt->AddLine "targetInfo.adapterId.LowPart: " & PathInfo.targetInfo.adapterId.LowPart
	txt->AddLine "targetInfo.id: " & PathInfo.targetInfo.id
	txt->AddLine "targetInfo.modeInfoIdx: " & PathInfo.targetInfo.modeInfoIdx
	txt->AddLine "targetInfo.outputTechnology: " & PathInfo.targetInfo.outputTechnology
	txt->AddLine "targetInfo.refreshRate.Denominator: " & PathInfo.targetInfo.refreshRate.Denominator
	txt->AddLine "targetInfo.refreshRate.Numerator: " & PathInfo.targetInfo.refreshRate.Numerator
	txt->AddLine "targetInfo.rotation: " & PathInfo.targetInfo.rotation
	txt->AddLine "targetInfo.scaling: " & PathInfo.targetInfo.scaling
	txt->AddLine "targetInfo.scanLineOrdering: " & PathInfo.targetInfo.scanLineOrdering
	txt->AddLine "targetInfo.statusFlags: " & PathInfo.targetInfo.statusFlags
	txt->AddLine "targetInfo.targetAvailable: " & PathInfo.targetInfo.targetAvailable
	txt->AddLine "outputTechnology=" & OutPutWStr(PathInfo.targetInfo.outputTechnology)
End Sub

Private Sub Mode2WStr(ModeInfo As DISPLAYCONFIG_MODE_INFO, txt As TextBox Ptr)
	txt->AddLine "adapterId.HighPart: " & ModeInfo.adapterId.HighPart
	txt->AddLine "adapterId.LowPart: " & ModeInfo.adapterId.LowPart
	txt->AddLine "id: " & ModeInfo.id
	txt->AddLine "infoType: " & ModeInfo.infoType
	txt->AddLine "sourceMode.Height: " & ModeInfo.sourceMode.height
	txt->AddLine "sourceMode.Width: " & ModeInfo.sourceMode.width
	txt->AddLine "sourceMode.PixelFormat: " & ModeInfo.sourceMode.pixelFormat
	txt->AddLine "sourceMode.position.x: " & ModeInfo.sourceMode.position.x
	txt->AddLine "sourceMode.position.y: " & ModeInfo.sourceMode.position.y
	txt->AddLine "targetMode.targetVideoSignalInfo.activeSize.CX : " & ModeInfo.targetMode.targetVideoSignalInfo.activeSize.cx
	txt->AddLine "targetMode.targetVideoSignalInfo.activeSize.CY: " & ModeInfo.targetMode.targetVideoSignalInfo.activeSize.cy
	txt->AddLine "targetMode.targetVideoSignalInfo.hSyncFreq.Denominator : " & ModeInfo.targetMode.targetVideoSignalInfo.hSyncFreq.Denominator
	txt->AddLine "targetMode.targetVideoSignalInfo.hSyncFreq.Numerator: " & ModeInfo.targetMode.targetVideoSignalInfo.hSyncFreq.Numerator
	txt->AddLine "targetMode.targetVideoSignalInfo.pixelRate: " & ModeInfo.targetMode.targetVideoSignalInfo.pixelRate
	txt->AddLine "targetMode.targetVideoSignalInfo.scanLineOrdering: " & ModeInfo.targetMode.targetVideoSignalInfo.scanLineOrdering
	txt->AddLine "targetMode.targetVideoSignalInfo.totalSize.cx: " & ModeInfo.targetMode.targetVideoSignalInfo.totalSize.cx
	txt->AddLine "targetMode.targetVideoSignalInfo.totalSize.yx: " & ModeInfo.targetMode.targetVideoSignalInfo.totalSize.cy
	txt->AddLine "targetMode.targetVideoSignalInfo.vSyncFreq.Denominator: " & ModeInfo.targetMode.targetVideoSignalInfo.vSyncFreq.Denominator
	txt->AddLine "targetMode.targetVideoSignalInfo.vSyncFreq.Numerator: " & ModeInfo.targetMode.targetVideoSignalInfo.vSyncFreq.Numerator
	txt->AddLine "targetMode.targetVideoSignalInfo.videoStandard: " & ModeInfo.targetMode.targetVideoSignalInfo.videoStandard
	txt->AddLine "scanLineOrdering=" & ScanOrderWStr(ModeInfo.targetMode.targetVideoSignalInfo.scanLineOrdering)
End Sub

Private Sub DD2WStr(ddDisplay As DISPLAY_DEVICE, txt As TextBox Ptr)
	txt->AddLine ML("Device ID") & " = " & ddDisplay.DeviceID
	txt->AddLine ML("Device Key") & " = " & ddDisplay.DeviceKey
	txt->AddLine ML("Device Name") & " = " & ddDisplay.DeviceName
	txt->AddLine ML("Device String") & " = " & ddDisplay.DeviceString
	txt->AddLine ML("State Flags") & " = " & ddDisplay.StateFlags
	txt->AddLine IIf (ddDisplay.StateFlags And DISPLAY_DEVICE_ACTIVE , " @ ", "   ") & "DISPLAY_DEVICE_ACTIVE"
	txt->AddLine IIf (ddDisplay.StateFlags And DISPLAY_DEVICE_MIRRORING_DRIVER , " @ ", "   ") & "DISPLAY_DEVICE_MIRRORING_DRIVER"
	txt->AddLine IIf (ddDisplay.StateFlags And DISPLAY_DEVICE_MODESPRUNED , " @ ", "   ") & "DISPLAY_DEVICE_MODESPRUNED"
	txt->AddLine IIf (ddDisplay.StateFlags And DISPLAY_DEVICE_PRIMARY_DEVICE , " @ ", "   ") & "DISPLAY_DEVICE_PRIMARY_DEVICE"
	txt->AddLine IIf (ddDisplay.StateFlags And DISPLAY_DEVICE_REMOVABLE , " @ ", "   ") & "DISPLAY_DEVICE_REMOVABLE"
	txt->AddLine IIf (ddDisplay.StateFlags And DISPLAY_DEVICE_VGA_COMPATIBLE , " @ ", "   ") & "DISPLAY_DEVICE_VGA_COMPATIBLE"
End Sub

Private Function DM2SimpleWStr(dmDevMode As DEVMODE) ByRef As String
	Static a As String
	a = "(" & dmDevMode.dmPelsWidth & " x " & dmDevMode.dmPelsHeight & ") " & dmDevMode.dmBitsPerPel & "Bit, @" & dmDevMode.dmDisplayFrequency & "Hertz, O" & dmDevMode.dmDisplayOrientation
	Return a
End Function

Private Sub DM2WStr(dmDevMode As DEVMODE, txt As TextBox Ptr)
	txt->AddLine IIf(dmDevMode.dmFields And DM_BITSPERPEL , " @ " , "   ")      & "dmBitsPerPel         = " & dmDevMode.dmBitsPerPel
	txt->AddLine IIf(dmDevMode.dmFields And DM_COLLATE , " @ " , "   ")         & "dmCollate            = " & dmDevMode.dmCollate
	txt->AddLine IIf(dmDevMode.dmFields And DM_COLOR , " @ " , "   ")           & "dmColor              = " & dmDevMode.dmColor
	txt->AddLine IIf(dmDevMode.dmFields And DM_COPIES , " @ " , "   ")          & "dmCopies             = " & dmDevMode.dmCopies
	txt->AddLine IIf(dmDevMode.dmFields And DM_DEFAULTSOURCE , " @ " , "   ")   & "dmDefaultSource      = " & dmDevMode.dmDefaultSource
	txt->AddLine "   " & "dmDeviceName         = " & dmDevMode.dmDeviceName
	txt->AddLine IIf(dmDevMode.dmFields And DM_DISPLAYFIXEDOUTPUT , " @ " , "   ")  & "dmDisplayFixedOutput = " & dmDevMode.dmDisplayFixedOutput
	txt->AddLine IIf(dmDevMode.dmFields And DM_DISPLAYFLAGS , " @ " , "   ")        & "dmDisplayFlags       = " & dmDevMode.dmDisplayFlags
	txt->AddLine IIf(dmDevMode.dmFields And DM_DISPLAYFREQUENCY , " @ " , "   ")    & "dmDisplayFrequency   = " & dmDevMode.dmDisplayFrequency
	txt->AddLine IIf(dmDevMode.dmFields And DM_DISPLAYORIENTATION , " @ " , "   ")  & "dmDisplayOrientation = " & dmDevMode.dmDisplayOrientation
	txt->AddLine IIf(dmDevMode.dmFields And DM_DITHERTYPE , " @ " , "   ")          & "dmDitherType         = " & dmDevMode.dmDitherType
	txt->AddLine "   " & "dmDriverExtra        = " & dmDevMode.dmDriverExtra
	txt->AddLine "   " & "dmDriverVersion      = " & dmDevMode.dmDriverVersion
	txt->AddLine IIf(dmDevMode.dmFields And DM_DUPLEX , " @ " , "   ") & "dmDuplex             = " & dmDevMode.dmDuplex
	txt->AddLine "   " & "dmFields             = " & dmDevMode.dmFields ' & ", member to change the display settings.")
	txt->AddLine IIf(dmDevMode.dmFields And DM_FORMNAME , " @ " , "   ")        & "dmFormName           = " & dmDevMode.dmFormName
	txt->AddLine IIf(dmDevMode.dmFields And DM_ICMINTENT , " @ " , "   ")       & "dmICMIntent          = " & dmDevMode.dmICMIntent
	txt->AddLine IIf(dmDevMode.dmFields And DM_ICMMETHOD , " @ " , "   ")       & "dmICMMethod          = " & dmDevMode.dmICMMethod
	txt->AddLine IIf(dmDevMode.dmFields And DM_LOGPIXELS , " @ " , "   ")       & "dmLogPixels          = " & dmDevMode.dmLogPixels
	txt->AddLine IIf(dmDevMode.dmFields And DM_MEDIATYPE , " @ " , "   ")       & "dmMediaType          = " & dmDevMode.dmMediaType
	txt->AddLine IIf(dmDevMode.dmFields And DM_NUP , " @ " , "   ")             & "dmNup                = " & dmDevMode.dmNup
	txt->AddLine IIf(dmDevMode.dmFields And DM_ORIENTATION , " @ " , "   ")     & "dmOrientation        = " & dmDevMode.dmOrientation
	txt->AddLine IIf(dmDevMode.dmFields And DM_PANNINGHEIGHT , " @ " , "   ")   & "dmPanningHeight      = " & dmDevMode.dmPanningHeight
	txt->AddLine IIf(dmDevMode.dmFields And DM_PANNINGWIDTH , " @ " , "   ")    & "dmPanningWidth       = " & dmDevMode.dmPanningWidth
	txt->AddLine IIf(dmDevMode.dmFields And DM_PAPERLENGTH , " @ " , "   ")     & "dmPaperLength        = " & dmDevMode.dmPaperLength
	txt->AddLine IIf(dmDevMode.dmFields And DM_PAPERSIZE , " @ " , "   ")       & "dmPaperSize          = " & dmDevMode.dmPaperSize
	txt->AddLine IIf(dmDevMode.dmFields And DM_PAPERWIDTH , " @ " , "   ")      & "dmPaperWidth         = " & dmDevMode.dmPaperWidth
	txt->AddLine IIf(dmDevMode.dmFields And DM_PELSHEIGHT , " @ " , "   ")      & "dmPelsHeight         = " & dmDevMode.dmPelsHeight
	txt->AddLine IIf(dmDevMode.dmFields And DM_PELSWIDTH , " @ " , "   ")       & "dmPelsWidth          = " & dmDevMode.dmPelsWidth
	txt->AddLine IIf(dmDevMode.dmFields And DM_POSITION , " @ " , "   ")        & "dmPosition.x         = " & dmDevMode.dmPosition.x
	txt->AddLine IIf(dmDevMode.dmFields And DM_POSITION , " @ " , "   ")        & "dmPosition.y         = " & dmDevMode.dmPosition.y
	txt->AddLine IIf(dmDevMode.dmFields And DM_PRINTQUALITY , " @ " , "   ")    & "dmPrintQuality       = " & dmDevMode.dmPrintQuality
	txt->AddLine "   " & "dmReserved1          = " & dmDevMode.dmReserved1
	txt->AddLine "   " & "dmReserved2          = " & dmDevMode.dmReserved2
	txt->AddLine IIf(dmDevMode.dmFields And DM_SCALE , " @ " , "   ")           & "dmScale              = " & dmDevMode.dmScale
	txt->AddLine "   " & "dmSize               = " & dmDevMode.dmSize
	txt->AddLine "   " & "dmSpecVersion        = " & dmDevMode.dmSpecVersion
	txt->AddLine IIf(dmDevMode.dmFields And DM_TTOPTION , " @ " , "   ")        & "dmTTOption           = " & dmDevMode.dmTTOption
	txt->AddLine IIf(dmDevMode.dmFields And DM_YRESOLUTION , " @ " , "   ")     & "dmYResolution        = " & dmDevMode.dmYResolution
End Sub

Private Function QDCrtn2WStr(ByVal rtn As Long) ByRef As WString
	Select Case rtn
	Case ERROR_SUCCESS
		Return ML("The function succeeded.")
	Case ERROR_INVALID_PARAMETER
		Return ML("The combination of parameters and flags specified is invalid.")
	Case ERROR_NOT_SUPPORTED
		Return ML("The system is not running a graphics driver that was written according to the Windows Display Driver Model (WDDM). The function is only supported on a system with a WDDM driver running.")
	Case ERROR_ACCESS_DENIED
		Return ML("The caller does not have access to the console session. This error occurs if the calling process does not have access to the current desktop or is running on a remote session.")
	Case ERROR_GEN_FAILURE
		Return ML("An unspecified error occurred.")
	Case ERROR_BAD_CONFIGURATION
		Return ML("The function could not find a workable solution for the source and target modes that the caller did not specify.")
	Case Else
		Return ML("Unknow status.")
	End Select
End Function

Private Function CDSErtnWstr(ByVal rtn As Long) ByRef As WString
	Select Case rtn
	Case DISP_CHANGE_SUCCESSFUL
		Return ML("The settings change was successful.")
	Case DISP_CHANGE_BADFLAGS
		Return ML("An invalid set of values was used in the dwFlags parameter.")
	Case DISP_CHANGE_BADMODE
		Return ML("The graphics mode is not supported.")
	Case DISP_CHANGE_BADPARAM
		Return ML("An invalid parameter was used. This error can include an invalid value or combination of values.")
	Case DISP_CHANGE_FAILED
		Return ML("The display driver failed the specified graphics mode.")
	Case DISP_CHANGE_NOTUPDATED
		Return ML("ChangeDisplaySettingsEx was unable to write settings to the registry.")
	Case DISP_CHANGE_RESTART
		Return ML("The user must restart the computer for the graphics mode to work.")
	Case Else
		Return ML("Unknow status.")
	End Select
End Function

Private Destructor Monitor
	Release()
End Destructor

Private Constructor Monitor
	
End Constructor

Private Sub Monitor.Release()
	mtrCount = -1
	Erase mtrMI
	Erase mtrMIEx
	Erase mtrHMtr
	Erase mtrHDC
	Erase mtrRECT
End Sub

Private Sub Monitor.EnumDisplayDevice(dwFlags As DWORD, cob As ComboBoxEdit Ptr, lst As ListControl Ptr, txt As TextBox Ptr)
	lst->Clear
	cob->Clear
	
	Dim iDevNum As DWORD = 0
	Dim ddDisplay As DISPLAY_DEVICE
	Dim dmDevMode As DEVMODE
	'Dim dwFlags As DWORD = EDSEdwFlags(ComboBoxEdit4.ItemIndex)
	txt->Clear
	Do
		memset (@ddDisplay, 0, SizeOf(ddDisplay))
		ddDisplay.cb = SizeOf(ddDisplay)
		memset (@dmDevMode, 0, SizeOf(dmDevMode))
		dmDevMode.dmSize = SizeOf(dmDevMode)
		
		If EnumDisplayDevices(NULL, iDevNum, @ddDisplay, EDD_GET_DEVICE_INTERFACE_NAME) Then
			txt->AddLine "EnumDisplayDevices " & iDevNum + 1 & " =========================================="
			DD2WStr(ddDisplay, txt)
			txt->AddLine ""
			
			If EnumDisplaySettingsEx(ddDisplay.DeviceName, ENUM_CURRENT_SETTINGS, @dmDevMode, dwFlags) Then
				cob->AddItem ddDisplay.DeviceName
				txt->AddLine "EnumDisplaySettingsEx " & ddDisplay.DeviceName & " --------------------------------------"
				txt->AddLine "dmDevMode"
				DM2WStr(dmDevMode, txt)
				txt->AddLine "---------------------------------------"
				txt->AddLine ""
			End If
			
			iDevNum += 1
		Else
			Exit Do
		End If
	Loop While True
End Sub

Private Sub Monitor.SetDisplayConfigs(cob As ComboBoxEdit Ptr, txt As TextBox Ptr)
	Dim flag As UINT32
	Select Case cob->ItemIndex
	Case 0
		flag = SDC_TOPOLOGY_CLONE
	Case 1
		flag = SDC_TOPOLOGY_EXTEND
	Case 2
		flag = SDC_TOPOLOGY_INTERNAL
	Case 3
		flag = SDC_TOPOLOGY_EXTERNAL
	End Select
	flag = flag Or SDC_APPLY
	
	Dim rtn As Integer = SetDisplayConfig(0, NULL, 0, NULL, flag)
	txt->Clear
	txt->AddLine cob->Item(cob->ItemIndex)
	txt->AddLine ML("Set Display Config") & " = " & rtn
	txt->AddLine QDCrtn2WStr(rtn)
End Sub

Private Sub Monitor.QueryDisplayConfigs(cob As ComboBoxEdit Ptr, lst As ListControl Ptr, txt As TextBox Ptr)
	Dim rtn As Long
	
	Dim PathArraySize As UINT32 = 0
	Dim ModeArraySize  As UINT32 = 0
	Dim flags As UINT32
	
	Select Case cob->ItemIndex
	Case 0
		flags = QDC_ALL_PATHS
	Case 1
		flags = QDC_ONLY_ACTIVE_PATHS
	Case Else
		flags = QDC_DATABASE_CURRENT
	End Select
	
	Dim i As Integer
	For i = 0 To lst->ItemCount - 1
		If lst->Selected(i) Then
			Select Case i
			Case 0
				flags += QDC_VIRTUAL_MODE_AWARE
			Case 1
				flags += QDC_INCLUDE_HMD
			Case 2
				flags += QDC_VIRTUAL_REFRESH_RATE_AWARE
			End Select
		End If
	Next
	
	rtn = GetDisplayConfigBufferSizes(flags, @PathArraySize, @ModeArraySize)
	txt->Clear
	txt->AddLine "GetDisplayConfigBufferSizes = " & rtn & ", " & flags
	txt->AddLine "PathArraySize = " & PathArraySize
	txt->AddLine "ModeArraySize = " & ModeArraySize
	txt->AddLine QDCrtn2WStr(rtn)
	
	Dim currentTopologyId As DISPLAYCONFIG_TOPOLOGY_ID
	Dim PathArray(PathArraySize-1) As DISPLAYCONFIG_PATH_INFO
	Dim ModeArray(ModeArraySize-1) As DISPLAYCONFIG_MODE_INFO
	
	rtn = QueryDisplayConfig(flags, @PathArraySize, @PathArray(0), @ModeArraySize, @ModeArray(0) , @currentTopologyId)
	txt->AddLine ""
	txt->AddLine "QueryDisplayConfig = " & rtn
	txt->AddLine QDCrtn2WStr(rtn)
	
	Dim tmp As WString Ptr
	
	txt->AddLine "PathArray()===================="
	For i = 0 To PathArraySize-1
		txt->AddLine "Index: " & i & " --------------------"
		Path2WStr(PathArray(i), txt)
		txt->AddLine *tmp
	Next
	txt->AddLine "ModeArray()===================="
	For i = 0 To ModeArraySize-1
		txt->AddLine "Index: " & i & " --------------------"
		Mode2WStr(ModeArray(i), txt)
		txt->AddLine *tmp
	Next
	Deallocate(tmp)
End Sub

Private Sub Monitor.EnumDisplayMode(DiviceName As LPCWSTR, dwFlags As DWORD, lst As ListControl Ptr, txt As TextBox Ptr)
	lst->Clear
	If DiviceName = NULL Then Exit Sub
	
	Dim dmDevMode() As DEVMODE
	Dim dmDevModeCur As DEVMODE
	Dim iModeCur As Integer = -1
	Dim iModeNum As Integer = -1
	Dim i As Long
	Dim tmpi As String
	Dim tmpc As String
	
	'Dim dwFlags As DWORD = EDSEdwFlags(FlagIndex)
	
	memset (@dmDevModeCur, 0, SizeOf(DEVMODE))
	dmDevModeCur.dmSize = SizeOf(DEVMODE)
	EnumDisplaySettingsEx(DiviceName, ENUM_CURRENT_SETTINGS, @dmDevModeCur, dwFlags)
	
	tmpc = DM2SimpleWStr(dmDevModeCur)
	
	Do
		i = iModeNum + 1
		ReDim Preserve dmDevMode(i)
		memset (@dmDevMode(i), 0, SizeOf(DEVMODE))
		dmDevMode(i).dmSize = SizeOf(DEVMODE)
		
		If EnumDisplaySettingsEx(DiviceName, i , @dmDevMode(i), dwFlags) Then
			tmpi = DM2SimpleWStr(dmDevMode(i))
			lst->AddItem i & " - " & tmpi
			If tmpc = tmpi Then
				iModeCur = i
			End If
			iModeNum = i
		Else
			Exit Do
		End If
	Loop While (True)
	lst->ItemIndex = iModeCur
	txt->Clear
	txt->AddLine "DiviceName: " & *DiviceName
	txt->AddLine ML("Total DEVMODE number") & ": " & iModeNum
	txt->AddLine ML("Current DEVMODE number") & ": " & iModeCur
	DM2WStr(dmDevModeCur, txt)
End Sub

Private Sub Monitor.GetDisplayMode(DiviceName As LPCWSTR, ByVal FlagIndex As Integer, ByVal Index As Integer, lst As ListControl Ptr, txt As TextBox Ptr)
	If DiviceName = NULL Or FlagIndex < 0 Then Exit Sub
	
	Dim dmDevMode() As DEVMODE
	Dim dmDevModeCur As DEVMODE
	Dim iModeCur As Integer = -1
	Dim iModeNum As Integer = -1
	Dim i As Long
	Dim tmpi As WString Ptr
	Dim tmpc As WString Ptr
	
	Dim dwFlags As DWORD = EDSEdwFlags(FlagIndex)
	
	memset (@dmDevModeCur, 0, SizeOf(DEVMODE))
	dmDevModeCur.dmSize = SizeOf(DEVMODE)
	EnumDisplaySettingsEx(DiviceName, Index, @dmDevModeCur, dwFlags)
	
	txt->Clear
	txt->AddLine "DiviceName: " & *DiviceName
	txt->AddLine ML("Total DEVMODE number") & ": " & lst->ItemCount
	txt->AddLine ML("Current DEVMODE") & ": " & lst->Item(Index)
	txt->AddLine ML("Current DEVMODE number") & ": " & Index
	DM2WStr(dmDevModeCur, txt)
	Deallocate(tmpi)
	Deallocate(tmpc)
End Sub

Private Sub Monitor.EnumDisplayMonitor(txt As TextBox Ptr)
	Release()
	
	txt->Clear
	txt->AddLine "EnumDisplayMonitors: " & EnumDisplayMonitors(NULL , NULL , @EnumDisplayMonitorProc, Cast(LPARAM, @This))
	txt->AddLine "Monitor count: " & mtrCount + 1
	Dim i As Integer
	For i = 0 To mtrCount
		txt->AddLine ""
		txt->AddLine "Monitor " & i + 1 & " ================="
		txt->AddLine "EnumDisplayMonitors---------"
		txt->AddLine "hMtr =        " & mtrHMtr(i)
		txt->AddLine "hDCMonitor =  " & mtrHDC(i)
		txt->AddLine "####mrtRECT"
		RECT2WStr(mtrRECT(i), txt, "    ")
		txt->AddLine "GetMonitorInfo--------------"
		txt->AddLine "####rcMonitor"
		RECT2WStr(mtrMI(i).rcMonitor, txt, "    ")
		txt->AddLine "####rcWork"
		RECT2WStr(mtrMI(i).rcWork, txt, "    ")
		txt->AddLine "dwFlags =     " & mtrMI(i).dwFlags & IIf(mtrMI(i).dwFlags = MONITORINFOF_PRIMARY, ", This is the primary display monitor.", ", This is not the primary display monitor.")
		txt->AddLine "szDevice =    " & mtrMIEx(i).szDevice
	Next
End Sub

Private Sub Monitor.ChangeDisplaySettings(DiviceName As LPCWSTR, ByVal ModeNum As Integer, dwFlags As DWORD, dwFlags2 As DWORD, txt As TextBox Ptr)
	Dim dmDevMode As DEVMODEW
	memset(@dmDevMode, 0, SizeOf(dmDevMode))
	dmDevMode.dmSize = SizeOf (dmDevMode)
	
	Dim brtn As WINBOOL = EnumDisplaySettingsEx(DiviceName, ModeNum, @dmDevMode, dwFlags)
	Dim rtn As Long = ChangeDisplaySettingsEx(DiviceName, @dmDevMode, NULL, dwFlags2, NULL)
	txt->Clear
	txt->AddLine "EnumDisplaySettingsEx: " & brtn
	txt->AddLine "ChangeDisplaySettingsEx: " & rtn
	txt->AddLine CDSErtnWstr(rtn)
End Sub

Private Function Monitor.EnumDisplayMonitorProc(ByVal hMtr As HMONITOR , ByVal hDCMonitor As HDC , ByVal lprcMonitor As LPRECT , ByVal dwData As LPARAM) As WINBOOL
	Dim a As Monitor Ptr = Cast(Monitor Ptr, dwData)
	a->mtrCount += 1
	
	ReDim Preserve a->mtrHMtr(a->mtrCount)
	ReDim Preserve a->mtrHDC(a->mtrCount)
	ReDim Preserve a->mtrRECT(a->mtrCount)
	ReDim Preserve a->mtrMI(a->mtrCount)
	ReDim Preserve a->mtrMIEx(a->mtrCount)
	a->mtrHMtr(a->mtrCount) = hMtr
	a->mtrHDC(a->mtrCount) = hDCMonitor
	memcpy(VarPtr(a->mtrRECT(a->mtrCount)), lprcMonitor, SizeOf(tagRECT))
	a->mtrMI(a->mtrCount).cbSize = SizeOf(MONITORINFO)
	GetMonitorInfo(hMtr, @(a->mtrMI(a->mtrCount)))
	a->mtrMIEx(a->mtrCount).cbSize = SizeOf(MONITORINFOEX)
	'GetMonitorInfo(hMtr, @(a->mtrMIEx(a->mtrCount)))
	Return True
End Function
