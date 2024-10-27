'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "frmDisplay.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/Panel.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/ListControl.bi"
	
	'EnumDisplayDevices
	'	  https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-enumdisplaydevicesa
	'
	'EnumDisplaySettingsEx
	'	  https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-enumdisplaysettingsexa
	'
	'ChangeDisplaySettingsEx
	'    https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-changedisplaysettingsexw
	'
	'SetDisplayConfig
	'	  https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setdisplayconfig
	'
	'QueryDisplayConfig
	'    https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-querydisplayconfig
	'
	'GetDisplayConfigBufferSizes
	'    https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getdisplayconfigbuffersizes
	
	Const EDS_ROTATEDMODE = &H00000004
	Const QDC_VIRTUAL_MODE_AWARE= &h00000010
	Const QDC_INCLUDE_HMD = &h00000020
	Const QDC_VIRTUAL_REFRESH_RATE_AWARE= &h00000040
	
	Using My.Sys.Forms
	
	Type frmDisplayType Extends Form
		Dim mtrCount As Integer = -1
		Dim mtrMI(Any) As MONITORINFO
		Dim mtrHMtr(Any) As HMONITOR
		Dim mtrHDC(Any) As HDC
		Dim mtrRECT(Any) As tagRECT
		
		Declare Sub EnumDisplayMode(ByVal NameIndex As Integer, ByVal FlagIndex As Integer)
		Declare Sub GetDisplayMode(ByVal NameIndex As Integer, ByVal FlagIndex As Integer, ByVal Index As Integer)
		Declare Static Function MonitorEnumProc(ByVal hMtr As HMONITOR , ByVal hDCMonitor As HDC , ByVal lprcMonitor As LPRECT , ByVal dwData As LPARAM) As WINBOOL
		
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub cmdSetDisplayConfig_Click(ByRef Sender As Control)
		Declare Sub cmdEnumDisplaySettings_Click(ByRef Sender As Control)
		Declare Sub cmdEnumDisplayDevices_Click(ByRef Sender As Control)
		Declare Sub ComboBoxEdit3_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub cmdEnumDisplayMonitors_Click(ByRef Sender As Control)
		Declare Sub cmdQueryDisplayConfig_Click(ByRef Sender As Control)
		Declare Sub cmdChangeDisplaySettings_Click(ByRef Sender As Control)
		Declare Sub ComboBoxEdit4_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub ListControl2_Click(ByRef Sender As Control)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Constructor
		
		Dim As Panel Panel1, Panel2, Panel3, Panel4
		Dim As TextBox TextBox1
		Dim As CommandButton cmdQueryDisplayConfig, cmdSetDisplayConfig, cmdEnumDisplayMonitors, cmdEnumDisplayDevices, cmdEnumDisplaySettings, cmdChangeDisplaySettings
		Dim As ComboBoxEdit ComboBoxEdit1, ComboBoxEdit2, ComboBoxEdit3, ComboBoxEdit5, ComboBoxEdit4
		Dim As ListControl ListControl1, ListControl2
	End Type
	
	Constructor frmDisplayType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = My.Sys.Language
			End With
		#endif
		' frmDisplay
		With This
			.Name = "frmDisplay"
			.Text = ML("VisualFBEditor Multiple Display")
			.StartPosition = FormStartPosition.CenterScreen
			.Designer = @This
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			#ifdef __FB_64BIT__
				'...instructions for 64bit OSes...
				.Caption = ML("VisualFBEditor Multiple Display64")
			#else
				'...instructions for other OSes
				.Caption = ML("VisualFBEditor Multiple Display32")
			#endif
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.SetBounds 0, 0, 800, 600
		End With
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = "Panel1"
			.TabIndex = 0
			.Align = DockStyle.alLeft
			.ExtraMargins.Top = 10
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 10
			.ExtraMargins.Bottom = 10
			.SetBounds 10, 10, 230, 551
			.Parent = @This
		End With
		' Panel2
		With Panel2
			.Name = "Panel2"
			.Text = "Panel2"
			.TabIndex = 1
			.Align = DockStyle.alClient
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.ExtraMargins.Bottom = 10
			.ExtraMargins.Top = 10
			.SetBounds 280, 10, 674, 551
			.Parent = @This
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = ""
			.TabIndex = 2
			.Multiline = True
			.ScrollBars = ScrollBarsType.Both
			.Align = DockStyle.alClient
			.Font.Name = "Consolas"
			.SetBounds 0, 0, 524, 541
			.Parent = @Panel2
		End With
		' Panel3
		With Panel3
			.Name = "Panel3"
			.Text = "Panel3"
			.TabIndex = 14
			.Align = DockStyle.alTop
			.SetBounds 0, 0, 230, 320
			.Parent = @Panel1
		End With
		' cmdQueryDisplayConfig
		With cmdQueryDisplayConfig
			.Name = "cmdQueryDisplayConfig"
			.Text = ML("Query Display Config")
			.TabIndex = 16
			.SetBounds 0, 120, 230, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdQueryDisplayConfig_Click)
			.Parent = @Panel3
		End With
		' ComboBoxEdit1
		With ComboBoxEdit1
			.Name = "ComboBoxEdit1"
			.Text = "ComboBoxEdit1"
			.TabIndex = 17
			.SetBounds 0, 0, 230, 21
			.Parent = @Panel3
		End With
		' cmdSetDisplayConfig
		With cmdSetDisplayConfig
			.Name = "cmdSetDisplayConfig"
			.Text = ML("Set Display Config")
			.TabIndex = 18
			.SetBounds 120, 150, 110, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdSetDisplayConfig_Click)
			.Parent = @Panel3
		End With
		' ComboBoxEdit2
		With ComboBoxEdit2
			.Name = "ComboBoxEdit2"
			.Text = "ComboBoxEdit2"
			.TabIndex = 19
			.SetBounds 0, 150, 110, 21
			.Parent = @Panel3
		End With
		' cmdEnumDisplayMonitors
		With cmdEnumDisplayMonitors
			.Name = "cmdEnumDisplayMonitors"
			.Text = ML("Enum Display Monitors")
			.TabIndex = 20
			.SetBounds 0, 190, 230, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdEnumDisplayMonitors_Click)
			.Parent = @Panel3
		End With
		' cmdEnumDisplayDevices
		With cmdEnumDisplayDevices
			.Name = "cmdEnumDisplayDevices"
			.Text = ML("Enum Display Devices")
			.TabIndex = 23
			.SetBounds 0, 220, 230, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdEnumDisplayDevices_Click)
			.Parent = @Panel3
		End With
		' cmdEnumDisplaySettings
		With cmdEnumDisplaySettings
			.Name = "cmdEnumDisplaySettings"
			.Text = ML("Enum Display Settings")
			.TabIndex = 24
			.SetBounds 0, 270, 230, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdEnumDisplaySettings_Click)
			.Parent = @Panel3
		End With
		' ComboBoxEdit3
		With ComboBoxEdit3
			.Name = "ComboBoxEdit3"
			.Text = "ComboBoxEdit3"
			.TabIndex = 26
			.SetBounds 0, 240, 230, 21
			.Designer = @This
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @ComboBoxEdit3_Selected)
			.Parent = @Panel3
		End With
		' Panel4
		With Panel4
			.Name = "Panel4"
			.Text = "Panel4"
			.TabIndex = 27
			.Align = DockStyle.alBottom
			.SetBounds 0, 501, 230, 50
			.Parent = @Panel1
		End With
		' cmdChangeDisplaySettings
		With cmdChangeDisplaySettings
			.Name = "cmdChangeDisplaySettings"
			.Text = ML("Change Display Settings")
			.TabIndex = 28
			.SetBounds 0, 30, 230, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdChangeDisplaySettings_Click)
			.Parent = @Panel4
		End With
		' ComboBoxEdit5
		With ComboBoxEdit5
			.Name = "ComboBoxEdit5"
			.Text = "ComboBoxEdit5"
			.TabIndex = 18
			.SetBounds 0, 0, 230, 21
			.Parent = @Panel4
		End With
		' ListControl1
		With ListControl1
			.Name = "ListControl1"
			.Text = "ListControl1"
			.TabIndex = 19
			.SelectionMode = SelectionModes.smMultiExtended
			.SetBounds 0, 30, 230, 85
			.Parent = @Panel3
		End With
		' ComboBoxEdit4
		With ComboBoxEdit4
			.Name = "ComboBoxEdit4"
			.Text = "ComboBoxEdit4"
			.TabIndex = 20
			.SetBounds 0, 290, 230, 21
			.Designer = @This
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @ComboBoxEdit4_Selected)
			.Parent = @Panel3
		End With
		' ListControl2
		With ListControl2
			.Name = "ListControl2"
			.Text = "ListControl2"
			.TabIndex = 19
			.Align = DockStyle.alClient
			.SetBounds 0, 320, 230, 173
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @ListControl2_Click)
			.Parent = @Panel1
		End With
	End Constructor
	
	Dim Shared frmDisplay As frmDisplayType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmDisplay.MainForm = True
		frmDisplay.Show
		App.Run
	#endif
'#End Region

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
		Return ML("COMPOSITE VIDEO")
	Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_COMPONENT_VIDEO
		Return ML("COMPONENT VIDEO")
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
		Return ML("DISPLAYPORT EXTERNAL")
	Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_DISPLAYPORT_EMBEDDED
		Return ML("DISPLAYPORT EMBEDDED")
	Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_UDI_EXTERNAL
		Return ML("UDI EXTERNAL")
	Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_UDI_EMBEDDED
		Return ML("UDI EMBEDDED")
	Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_SDTVDONGLE
		Return ML("SD TV DONGLE")
		'Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_MIRACAST
		'	Return "MIRACAST"
		'Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_INDIRECT_WIRED
		'	Return "INDIRECT_WIRED"
		'Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_INDIRECT_VIRTUAL
		'	Return "INDIRECT_VIRTUAL"
		'Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_DISPLAYPORT_USB_TUNNEL
		'	Return "DISPLAYPORT_USB_TUNNEL"
	Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_INTERNAL
		Return ML("INTERNAL")
	Case DISPLAYCONFIG_OUTPUT_TECHNOLOGY_FORCE_UINT32
		Return ML("FORCE UINT32")
	Case Else
		Return ML("Unknow")
	End Select
End Function

Private Sub RECT2WStr(ret As tagRECT, txt As TextBox Ptr)
	txt->AddLine ML("Left") & ": " & ret.left
	txt->AddLine ML("Right") & ": " & ret.right
	txt->AddLine ML("Top") & ": " & ret.top
	txt->AddLine ML("Bottom") & ": " & ret.bottom
End Sub

Private Sub Path2WStr(PathInfo As DISPLAYCONFIG_PATH_INFO, txt As TextBox Ptr)
	txt->AddLine ML("FLAGS") & ": " & PathInfo.flags
	txt->AddLine ML("sourceInfo adapterId HighPart") & ": " & PathInfo.sourceInfo.adapterId.HighPart
	txt->AddLine ML("sourceInfo adapterId LowPart") & ": " & PathInfo.sourceInfo.adapterId.LowPart
	txt->AddLine ML("sourceInfo id") &  ": " & PathInfo.sourceInfo.id
	txt->AddLine ML("sourceInfo modeInfoIdx") & ": " & PathInfo.sourceInfo.modeInfoIdx
	txt->AddLine ML("sourceInfo statusFlags") & ": " & PathInfo.sourceInfo.statusFlags
	txt->AddLine ML("targetInfo adapterId HighPart") & ": " & PathInfo.targetInfo.adapterId.HighPart
	txt->AddLine ML("targetInfo adapterId LowPart") & ": " & PathInfo.targetInfo.adapterId.LowPart
	txt->AddLine ML("targetInfo id") & ": " & PathInfo.targetInfo.id
	txt->AddLine ML("targetInfo modeInfoIdx") & ": " & PathInfo.targetInfo.modeInfoIdx
	txt->AddLine ML("targetInfo outputTechnology") & ": " & PathInfo.targetInfo.outputTechnology
	txt->AddLine ML("targetInfo refreshRate Denominator") & ": " & PathInfo.targetInfo.refreshRate.Denominator
	txt->AddLine ML("targetInfo refreshRate Numerator") & ": " & PathInfo.targetInfo.refreshRate.Numerator
	txt->AddLine ML("targetInfo rotation") & ": " & PathInfo.targetInfo.rotation
	txt->AddLine ML("targetInfo scaling") & ": " & PathInfo.targetInfo.scaling
	txt->AddLine ML("targetInfo scanLineOrdering") & ": " & PathInfo.targetInfo.scanLineOrdering
	txt->AddLine ML("targetInfo statusFlags") & ": " & PathInfo.targetInfo.statusFlags
	txt->AddLine ML("targetInfo targetAvailable") & ": " & PathInfo.targetInfo.targetAvailable
	txt->AddLine ML("output Technology") & ": " & OutPutWStr(PathInfo.targetInfo.outputTechnology)
End Sub

Private Sub Mode2WStr(ModeInfo As DISPLAYCONFIG_MODE_INFO, txt As TextBox Ptr)
	txt->AddLine ML("adapterId HighPart") & ": " & ModeInfo.adapterId.HighPart
	txt->AddLine ML("adapterId LowPart") & ": " & ModeInfo.adapterId.LowPart
	txt->AddLine ML("id") & ": " & ModeInfo.id
	txt->AddLine ML("infoType") & ": " & ModeInfo.infoType
	txt->AddLine ML("sourceMode Height") & ": " & ModeInfo.sourceMode.height
	txt->AddLine ML("sourceMode Width") & ": " & ModeInfo.sourceMode.width
	txt->AddLine ML("sourceMode PixelFormat") & ": " & ModeInfo.sourceMode.pixelFormat
	txt->AddLine ML("sourceMode position.x") & ": " & ModeInfo.sourceMode.position.x
	txt->AddLine ML("sourceMode position.y") & ": " & ModeInfo.sourceMode.position.y
	txt->AddLine ML("targetMode targetVideoSignalInfo activeSize CX ") & ": " & ModeInfo.targetMode.targetVideoSignalInfo.activeSize.cx
	txt->AddLine ML("targetMode targetVideoSignalInfo activeSize CY") & ": " & ModeInfo.targetMode.targetVideoSignalInfo.activeSize.cy
	txt->AddLine ML("targetMode targetVideoSignalInfo hSyncFreq Denominator ") & ": " & ModeInfo.targetMode.targetVideoSignalInfo.hSyncFreq.Denominator
	txt->AddLine ML("targetMode targetVideoSignalInfo hSyncFreq Numerator") & ": " & ModeInfo.targetMode.targetVideoSignalInfo.hSyncFreq.Numerator
	txt->AddLine ML("targetMode targetVideoSignalInfo pixelRate") & ": " & ModeInfo.targetMode.targetVideoSignalInfo.pixelRate
	txt->AddLine ML("targetMode targetVideoSignalInfo scanLineOrdering") & ": " & ModeInfo.targetMode.targetVideoSignalInfo.scanLineOrdering
	txt->AddLine ML("targetMode targetVideoSignalInfo totalSize cx") & ": " & ModeInfo.targetMode.targetVideoSignalInfo.totalSize.cx
	txt->AddLine ML("targetMode targetVideoSignalInfo totalSize yx") & ": " & ModeInfo.targetMode.targetVideoSignalInfo.totalSize.cy
	txt->AddLine ML("targetMode targetVideoSignalInfo vSyncFreq Denominator") & ": " & ModeInfo.targetMode.targetVideoSignalInfo.vSyncFreq.Denominator
	txt->AddLine ML("targetMode targetVideoSignalInfo vSyncFreq Numerator") & ": " & ModeInfo.targetMode.targetVideoSignalInfo.vSyncFreq.Numerator
	txt->AddLine ML("targetMode targetVideoSignalInfo videoStandard") & ": " & ModeInfo.targetMode.targetVideoSignalInfo.videoStandard
	txt->AddLine ML("scanLineOrdering") & ": " & ScanOrderWStr(ModeInfo.targetMode.targetVideoSignalInfo.scanLineOrdering)
End Sub

Private Sub DD2WStr(ddDisplay As DISPLAY_DEVICE, txt As TextBox Ptr)
	txt->AddLine ML("Device ID") & "= " & ddDisplay.DeviceID
	txt->AddLine ML("Device Key") & "= " & ddDisplay.DeviceKey
	txt->AddLine ML("Device Name") & "= " & ddDisplay.DeviceName
	txt->AddLine ML("Device String") & "= " & ddDisplay.DeviceString
	txt->AddLine ML("State Flags") & "= " & ddDisplay.StateFlags
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
	txt->AddLine IIf(dmDevMode.dmFields And DM_BITSPERPEL , " @ " , "   ")    & "dmBitsPerPel         = " & dmDevMode.dmBitsPerPel
	txt->AddLine IIf(dmDevMode.dmFields And DM_COLLATE , " @ " , "   ")       & "dmCollate            = " & dmDevMode.dmCollate
	txt->AddLine IIf(dmDevMode.dmFields And DM_COLOR , " @ " , "   ")         & "dmColor              = " & dmDevMode.dmColor
	txt->AddLine IIf(dmDevMode.dmFields And DM_COPIES , " @ " , "   ")        & "dmCopies             = " & dmDevMode.dmCopies
	txt->AddLine IIf(dmDevMode.dmFields And DM_DEFAULTSOURCE , " @ " , "   ") & "dmDefaultSource      = " & dmDevMode.dmDefaultSource
	txt->AddLine "   " & ML("dmDeviceName") & "         = " & dmDevMode.dmDeviceName
	txt->AddLine IIf(dmDevMode.dmFields And DM_DISPLAYFIXEDOUTPUT , " @ " , "   ") & "dmDisplayFixedOutput = " & dmDevMode.dmDisplayFixedOutput
	txt->AddLine IIf(dmDevMode.dmFields And DM_DISPLAYFLAGS , " @ " , "   ")       & "dmDisplayFlags       = " & dmDevMode.dmDisplayFlags
	txt->AddLine IIf(dmDevMode.dmFields And DM_DISPLAYFREQUENCY , " @ " , "   ")   & "dmDisplayFrequency   = " & dmDevMode.dmDisplayFrequency
	txt->AddLine IIf(dmDevMode.dmFields And DM_DISPLAYORIENTATION , " @ " , "   ") & "dmDisplayOrientation = " & dmDevMode.dmDisplayOrientation
	txt->AddLine IIf(dmDevMode.dmFields And DM_DITHERTYPE , " @ " , "   ")         & "dmDitherType         = " & dmDevMode.dmDitherType
	txt->AddLine "   " & ML("dmDriverExtra") & "        = " & dmDevMode.dmDriverExtra
	txt->AddLine "   " & ML("dmDriverVersion") & "      = " & dmDevMode.dmDriverVersion
	txt->AddLine IIf(dmDevMode.dmFields And DM_DUPLEX , " @ " , "   ") & "dmDuplex             = " & dmDevMode.dmDuplex
	txt->AddLine "   " & ML("dmFields") & "             = " & dmDevMode.dmFields ' & ", member to change the display settings.")
	txt->AddLine IIf(dmDevMode.dmFields And DM_FORMNAME , " @ " , "   ")      & "dmFormName           = " & dmDevMode.dmFormName
	txt->AddLine IIf(dmDevMode.dmFields And DM_ICMINTENT , " @ " , "   ")     & "dmICMIntent          = " & dmDevMode.dmICMIntent
	txt->AddLine IIf(dmDevMode.dmFields And DM_ICMMETHOD , " @ " , "   ")     & "dmICMMethod          = " & dmDevMode.dmICMMethod
	txt->AddLine IIf(dmDevMode.dmFields And DM_LOGPIXELS , " @ " , "   ")     & "dmLogPixels          = " & dmDevMode.dmLogPixels
	txt->AddLine IIf(dmDevMode.dmFields And DM_MEDIATYPE , " @ " , "   ")     & "dmMediaType          = " & dmDevMode.dmMediaType
	txt->AddLine IIf(dmDevMode.dmFields And DM_NUP , " @ " , "   ")           & "dmNup                = " & dmDevMode.dmNup
	txt->AddLine IIf(dmDevMode.dmFields And DM_ORIENTATION , " @ " , "   ")   & "dmOrientation        = " & dmDevMode.dmOrientation
	txt->AddLine IIf(dmDevMode.dmFields And DM_PANNINGHEIGHT , " @ " , "   ") & "dmPanningHeight      = " & dmDevMode.dmPanningHeight
	txt->AddLine IIf(dmDevMode.dmFields And DM_PANNINGWIDTH , " @ " , "   ")  & "dmPanningWidth       = " & dmDevMode.dmPanningWidth
	txt->AddLine IIf(dmDevMode.dmFields And DM_PAPERLENGTH , " @ " , "   ")   & "dmPaperLength        = " & dmDevMode.dmPaperLength
	txt->AddLine IIf(dmDevMode.dmFields And DM_PAPERSIZE , " @ " , "   ")     & "dmPaperSize          = " & dmDevMode.dmPaperSize
	txt->AddLine IIf(dmDevMode.dmFields And DM_PAPERWIDTH , " @ " , "   ")    & "dmPaperWidth         = " & dmDevMode.dmPaperWidth
	txt->AddLine IIf(dmDevMode.dmFields And DM_PELSHEIGHT , " @ " , "   ")    & "dmPelsHeight         = " & dmDevMode.dmPelsHeight
	txt->AddLine IIf(dmDevMode.dmFields And DM_PELSWIDTH , " @ " , "   ")     & "dmPelsWidth          = " & dmDevMode.dmPelsWidth
	txt->AddLine IIf(dmDevMode.dmFields And DM_POSITION , " @ " , "   ")      & "dmPosition.x         = " & dmDevMode.dmPosition.x
	txt->AddLine IIf(dmDevMode.dmFields And DM_POSITION , " @ " , "   ")    & "dmPosition.y         = " & dmDevMode.dmPosition.y
	txt->AddLine IIf(dmDevMode.dmFields And DM_PRINTQUALITY , " @ " , "   ")  & "dmPrintQuality       = " & dmDevMode.dmPrintQuality
	txt->AddLine "   " & ML("dmReserved1") & "          = " & dmDevMode.dmReserved1
	txt->AddLine "   " & ML("dmReserved2 ") & "         = " & dmDevMode.dmReserved2
	txt->AddLine IIf(dmDevMode.dmFields And DM_SCALE , " @ " , "   ") & "dmScale              = " & dmDevMode.dmScale
	txt->AddLine "   " & ML("dmSize") & "               = " & dmDevMode.dmSize
	txt->AddLine "   " & ML("dmSpecVersion") & "        = " & dmDevMode.dmSpecVersion
	txt->AddLine IIf(dmDevMode.dmFields And DM_TTOPTION , " @ " , "   ")    & "dmTTOption           = " & dmDevMode.dmTTOption
	txt->AddLine IIf(dmDevMode.dmFields And DM_YRESOLUTION , " @ " , "   ") & "dmYResolution        = " & dmDevMode.dmYResolution
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

Private Sub frmDisplayType.GetDisplayMode(ByVal NameIndex As Integer, ByVal FlagIndex As Integer, ByVal Index As Integer)
	If NameIndex < 0 Or FlagIndex < 0 Then Exit Sub
	
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
	EnumDisplaySettingsEx(ComboBoxEdit3.Item(NameIndex), Index, @dmDevModeCur, dwFlags)
	
	TextBox1.Clear
	TextBox1.AddLine ComboBoxEdit3.Item(NameIndex)
	TextBox1.AddLine ML("Total DEVMODE number") & ": " & ListControl2.ItemCount
	TextBox1.AddLine ML("Current DEVMODE") & ": " & ListControl2.Item(Index)
	TextBox1.AddLine ML("Current DEVMODE number") & ": " & Index
	DM2WStr(dmDevModeCur, @TextBox1)
	Deallocate(tmpi)
	Deallocate(tmpc)
End Sub

Private Sub frmDisplayType.EnumDisplayMode(ByVal NameIndex As Integer, ByVal FlagIndex As Integer)
	ListControl2.Clear
	If NameIndex < 0 Or FlagIndex < 0 Then Exit Sub
	
	Dim dmDevMode() As DEVMODE
	Dim dmDevModeCur As DEVMODE
	Dim iModeCur As Integer = -1
	Dim iModeNum As Integer = -1
	Dim i As Long
	Dim tmpi As String
	Dim tmpc As String
	
	Dim dwFlags As DWORD = EDSEdwFlags(FlagIndex)
	
	memset (@dmDevModeCur, 0, SizeOf(DEVMODE))
	dmDevModeCur.dmSize = SizeOf(DEVMODE)
	EnumDisplaySettingsEx(ComboBoxEdit3.Item(NameIndex), ENUM_CURRENT_SETTINGS, @dmDevModeCur, dwFlags)
	
	tmpc = DM2SimpleWStr(dmDevModeCur)
	
	Do
		i = iModeNum + 1
		ReDim Preserve dmDevMode(i)
		memset (@dmDevMode(i), 0, SizeOf(DEVMODE))
		dmDevMode(i).dmSize = SizeOf(DEVMODE)
		
		If EnumDisplaySettingsEx(ComboBoxEdit3.Item(NameIndex), i , @dmDevMode(i), dwFlags) Then
			tmpi = DM2SimpleWStr(dmDevMode(i))
			ListControl2.AddItem i & " - " & tmpi
			If tmpc = tmpi Then
				iModeCur = i
			End If
			iModeNum = i
		Else
			Exit Do
		End If
	Loop While (True)
	ListControl2.ItemIndex = iModeCur
	TextBox1.Clear
	TextBox1.AddLine ComboBoxEdit3.Item(NameIndex)
	TextBox1.AddLine ML("Total DEVMODE number") & ": " & iModeNum
	TextBox1.AddLine ML("Current DEVMODE number") & ": " & iModeCur
	DM2WStr(dmDevModeCur, @TextBox1)
End Sub

Private Sub frmDisplayType.Form_Create(ByRef Sender As Control)
	ComboBoxEdit1.AddItem ML("QDC_ALL_PATHS")
	ComboBoxEdit1.AddItem ML("QDC_ONLY_ACTIVE_PATHS")
	ComboBoxEdit1.AddItem ML("QDC_DATABASE_CURRENT")
	ComboBoxEdit1.ItemIndex = 0
	ListControl1.AddItem ML("QDC_VIRTUAL_MODE_AWARE")
	ListControl1.AddItem ML("QDC_INCLUDE_HMD")
	ListControl1.AddItem ML("QDC_VIRTUAL_REFRESH_RATE_AWARE")
	ListControl1.AddItem ML("NONE")
	ListControl1.ItemIndex = 0
	
	ComboBoxEdit4.AddItem ML("EDS RAWMODE")
	ComboBoxEdit4.AddItem ML("EDS ROTATEDMODE")
	ComboBoxEdit4.ItemIndex = 0
	
	ComboBoxEdit2.AddItem ML("Clone") '"SDC_TOPOLOGY_CLONE"
	ComboBoxEdit2.AddItem ML("Extended") '"SDC_TOPOLOGY_EXTEND"
	ComboBoxEdit2.AddItem ML("Internal") '"SDC_TOPOLOGY_INTERNAL"
	ComboBoxEdit2.AddItem ML("External") '"SDC_TOPOLOGY_EXTERNAL"
	ComboBoxEdit2.ItemIndex = 0
	
	ComboBoxEdit5.AddItem "0"
	ComboBoxEdit5.AddItem ML("CDS FULLSCREEN")
	ComboBoxEdit5.AddItem ML("CDS GLOBAL")
	ComboBoxEdit5.AddItem ML("CDS NORESET")
	ComboBoxEdit5.AddItem ML("CDS RESET")
	ComboBoxEdit5.AddItem ML("CDS SET PRIMARY")
	ComboBoxEdit5.AddItem ML("CDS TEST")
	ComboBoxEdit5.AddItem ML("CDS UPDATEREGISTRY")
	ComboBoxEdit5.AddItem ML("CDS VIDEOPARAMETERS")
	ComboBoxEdit5.AddItem ML("CDS ENABLE UNSAFE MODES")
	ComboBoxEdit5.AddItem ML("CDS DISABLE UNSAFE MODES")
	ComboBoxEdit5.ItemIndex = 7
	TextBox1.Text =  ML("Hello!") & WChr(55357 , 56832)
End Sub

Private Function frmDisplayType.MonitorEnumProc(ByVal hMtr As HMONITOR , ByVal hDCMonitor As HDC , ByVal lprcMonitor As LPRECT , ByVal dwData As LPARAM) As WINBOOL
	Dim a As frmDisplayType Ptr = Cast(frmDisplayType Ptr, dwData)
	a->mtrCount += 1
	
	ReDim Preserve a->mtrHMtr(a->mtrCount)
	ReDim Preserve a->mtrHDC(a->mtrCount)
	ReDim Preserve a->mtrRECT(a->mtrCount)
	ReDim Preserve a->mtrMI(a->mtrCount)
	a->mtrHMtr(a->mtrCount) = hMtr
	a->mtrHDC(a->mtrCount) = hDCMonitor
	memcpy(VarPtr(a->mtrRECT(a->mtrCount)), lprcMonitor, SizeOf(tagRECT))
	a->mtrMI(a->mtrCount).cbSize = SizeOf(MONITORINFO)
	GetMonitorInfo(hMtr, @(a->mtrMI(a->mtrCount)))
	Return True
End Function

Private Sub frmDisplayType.cmdSetDisplayConfig_Click(ByRef Sender As Control)
	Dim flag As UINT32
	Select Case ComboBoxEdit2.ItemIndex
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
	TextBox1.Clear
	TextBox1.AddLine ComboBoxEdit2.Item(ComboBoxEdit2.ItemIndex)
	TextBox1.AddLine ML("Set Display Config") & " = " & rtn
	TextBox1.AddLine QDCrtn2WStr(rtn)
End Sub

Private Sub frmDisplayType.cmdEnumDisplaySettings_Click(ByRef Sender As Control)
	EnumDisplayMode(ComboBoxEdit3.ItemIndex, ComboBoxEdit4.ItemIndex)
End Sub

Private Sub frmDisplayType.cmdEnumDisplayDevices_Click(ByRef Sender As Control)
	ListControl2.Clear
	ComboBoxEdit3.Clear
	
	Dim iDevNum As DWORD = 0
	
	Dim ddDisplay As DISPLAY_DEVICE
	Dim edd As WINBOOL
	
	Dim eds As WINBOOL
	Dim dmDevMode As DEVMODE
	Dim dwFlags As DWORD = EDSEdwFlags(ComboBoxEdit4.ItemIndex)
	Dim tmp As WString Ptr
	TextBox1.Clear
	Do
		memset (@ddDisplay, 0, SizeOf(ddDisplay))
		ddDisplay.cb = SizeOf(ddDisplay)
		memset (@dmDevMode, 0, SizeOf(dmDevMode))
		dmDevMode.dmSize = SizeOf(dmDevMode)
		
		edd = EnumDisplayDevices(NULL, iDevNum, @ddDisplay, EDD_GET_DEVICE_INTERFACE_NAME)
		eds = EnumDisplaySettingsEx(ddDisplay.DeviceName, ENUM_CURRENT_SETTINGS, @dmDevMode, dwFlags)
		If (edd And eds) Then
			'		If (edd) Then
			ComboBoxEdit3.AddItem ddDisplay.DeviceName
			TextBox1.AddLine ML("Enum Display Devices") & ": " & iDevNum + 1 & " = " & edd & " =========================================="
			DD2WStr(ddDisplay, @TextBox1)
			'TextBox1.AddLine *tmp
			TextBox1.AddLine ""
			TextBox1.AddLine ML("Enum Display Settings") & ": " & ddDisplay.DeviceName & " = " & eds & " --------------------------------------"
			TextBox1.AddLine ML("dmDevMode")
			DM2WStr(dmDevMode, @TextBox1)
			'TextBox1.AddLine *tmp
			TextBox1.AddLine "---------------------------------------"
			TextBox1.AddLine ""
			iDevNum += 1
		Else
			Exit Do
		End If
	Loop While True
	Deallocate (tmp)
End Sub

Private Sub frmDisplayType.ComboBoxEdit3_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	EnumDisplayMode(ItemIndex, ComboBoxEdit4.ItemIndex)
End Sub

Private Sub frmDisplayType.cmdEnumDisplayMonitors_Click(ByRef Sender As Control)
	mtrCount = -1
	Erase mtrMI
	Erase mtrHMtr
	Erase mtrHDC
	Erase mtrRECT
	Dim tmp As WString Ptr
	TextBox1.Clear
	TextBox1.AddLine ML("Enum Display Monitors") & ": " & EnumDisplayMonitors(NULL , NULL , @MonitorEnumProc, Cast(LPARAM, @This))
	TextBox1.AddLine ML("Monitor count") & ": " & mtrCount + 1
	Dim i As Integer
	For i = 0 To mtrCount
		TextBox1.AddLine ""
		TextBox1.AddLine ML("Monitor") & ": " & i + 1 & " ================="
		TextBox1.AddLine ML("Enum Display Monitors") & " ---------"
		TextBox1.AddLine ML("hMtr") & ": " & mtrHMtr(i)
		TextBox1.AddLine ML("hDCMonitor") & " = " & mtrHDC(i)
		
		RECT2WStr(mtrRECT(i), @TextBox1)
		'TextBox1.AddLine ML("lprcMonitor = " & *tmp
		TextBox1.AddLine ML("Get Monitor Info") & " --------------"
		RECT2WStr(mtrMI(i).rcMonitor, @TextBox1)
		'TextBox1.AddLine ML("rcMonitor = " & *tmp
		RECT2WStr(mtrMI(i).rcWork, @TextBox1)
		'TextBox1.AddLine ML("rcWork = " & *tmp
		TextBox1.AddLine ML("dwFlags") & " = " & mtrMI(i).dwFlags & IIf(mtrMI(i).dwFlags = MONITORINFOF_PRIMARY, ", " & ML("This is the primary display monitor."), ", " & ML("This is not the primary display monitor."))
	Next
	Deallocate(tmp)
End Sub

Private Sub frmDisplayType.cmdQueryDisplayConfig_Click(ByRef Sender As Control)
	Dim rtn As Long
	
	Dim PathArraySize As UINT32 = 0
	Dim ModeArraySize  As UINT32 = 0
	Dim flags As UINT32
	
	Select Case ComboBoxEdit1.ItemIndex
	Case 0
		flags = QDC_ALL_PATHS
	Case 1
		flags = QDC_ONLY_ACTIVE_PATHS
	Case Else
		flags = QDC_DATABASE_CURRENT
	End Select
	
	Dim i As Integer
	For i = 0 To ListControl1.ItemCount - 1
		If ListControl1.Selected(i) Then
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
	TextBox1.Clear
	TextBox1.AddLine ML("Get Display Config Buffer Sizes") & " = " & rtn & ", " & flags
	TextBox1.AddLine ML("Path Array Size") & " = " & PathArraySize
	TextBox1.AddLine ML("Mode Array Size") & " = " & ModeArraySize
	TextBox1.AddLine QDCrtn2WStr(rtn)
	
	Dim currentTopologyId As DISPLAYCONFIG_TOPOLOGY_ID
	Dim PathArray(PathArraySize-1) As DISPLAYCONFIG_PATH_INFO
	Dim ModeArray(ModeArraySize-1) As DISPLAYCONFIG_MODE_INFO
	
	rtn = QueryDisplayConfig(flags, @PathArraySize, @PathArray(0), @ModeArraySize, @ModeArray(0) , @currentTopologyId)
	TextBox1.AddLine ""
	TextBox1.AddLine ML("Query Display Config") & " = " & rtn
	TextBox1.AddLine QDCrtn2WStr(rtn)
	
	Dim tmp As WString Ptr
	
	TextBox1.AddLine "PathArray()===================="
	For i = 0 To PathArraySize-1
		TextBox1.AddLine ML("Index") & ": " & i & " --------------------"
		Path2WStr(PathArray(i), @TextBox1)
		TextBox1.AddLine *tmp
	Next
	TextBox1.AddLine "ModeArray()===================="
	For i = 0 To ModeArraySize-1
		TextBox1.AddLine ML("Index") & ": " & i & " --------------------"
		Mode2WStr(ModeArray(i), @TextBox1)
		TextBox1.AddLine *tmp
	Next
	Deallocate(tmp)
End Sub

Private Sub frmDisplayType.cmdChangeDisplaySettings_Click(ByRef Sender As Control)
	Dim dmDevMode As DEVMODEW
	memset(@dmDevMode, 0, SizeOf(dmDevMode))
	dmDevMode.dmSize = SizeOf (dmDevMode)
	Dim dwFlags As DWORD = EDSEdwFlags(ComboBoxEdit4.ItemIndex)
	
	Dim brtn As WINBOOL = EnumDisplaySettingsEx(ComboBoxEdit3.Item(ComboBoxEdit3.ItemIndex), ListControl2.ItemIndex , @dmDevMode, dwFlags)
	Dim rtn As Long = ChangeDisplaySettingsEx(ComboBoxEdit3.Item(ComboBoxEdit3.ItemIndex), @dmDevMode , NULL , CDSdwFlags(ComboBoxEdit5.ItemIndex) , NULL)
	TextBox1.Clear
	TextBox1.AddLine ML("Enum Display Settings") & ": " & brtn
	TextBox1.AddLine ML("Change Display Settings") & ": " & rtn
	TextBox1.AddLine CDSErtnWstr(rtn)
End Sub

Private Sub frmDisplayType.ListControl2_Click(ByRef Sender As Control)
	GetDisplayMode(ComboBoxEdit3.ItemIndex, ComboBoxEdit4.ItemIndex, ListControl2.ItemIndex)
End Sub

Private Sub frmDisplayType.ComboBoxEdit4_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	EnumDisplayMode(ComboBoxEdit3.ItemIndex, ItemIndex)
End Sub


Private Sub frmDisplayType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	Erase mtrMI
	Erase mtrHMtr
	Erase mtrHDC
	Erase mtrRECT
End Sub
