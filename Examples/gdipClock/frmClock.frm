'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "gdipClock.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/TimerComponent.bi"
	#include once "mff/Menus.bi"
	#include once "mff/Dialogs.bi"
	
	#include once "gdip.bi"
	#include once "gdipAnalogClock.bi"
	#include once "gdipTextClock.bi"
	
	#include once "../SapiTTS/Speech.bi"
	#include once "../MDINotepad/Text.bi"
	
	Const MSG_SAPI_EVENT = WM_USER + 1024   ' --> change me
	
	Using My.Sys.Forms
	Using Speech
	
	Type frmClockType Extends Form
		pSpVoice As Afx_ISpVoice Ptr
		mVoiceCount As Integer = -1
		mAudioCount As Integer = -1
		mLanguage As Integer = 0
		mnuVoiceSub(Any) As MenuItem Ptr
		mnuAudioSub(Any) As MenuItem Ptr
		
		Declare Sub SpeechNow(sDt As Double, ByVal sLan As Integer = 0)
		Declare Sub SpeechInit()
		
		sKey(Any) As WString Ptr
		sKeyLen(Any) As Integer
		sKeyCount As Integer = 33
		Declare Sub ProfileInitial()
		Declare Sub ProfileRelease()
		Declare Sub ProfileLoad(sFileName As WString)
		Declare Sub ProfileSave(sFileName As WString)
		Declare Property IndexOfTextColor() As Integer
		Declare Property IndexOfAnnouce() As Integer
		Declare Property IndexOfVoice() ByRef As WString
		Declare Property IndexOfAudio() ByRef As WString
		Declare Property IndexOfTextColor(v As Integer)
		Declare Property IndexOfAnnouce(v As Integer)
		Declare Property IndexOfVoice(ByRef v As WString)
		Declare Property IndexOfAudio(ByRef v As WString)
		
		'initial gdip token
		Token As gdipToken
		'form trans
		frmTrans As gdipForm
		'form display device
		frmDC As gdipDC
		'memory display device
		memDC As gdipDC
		'form canvas
		frmGraphic As gdipGraphics
		
		'draw analog coloc
		Dim mAnalogClock As AnalogClock
		
		'draw text coloc
		Dim mTextClock As TextClock
		
		Dim mAlphaAlg As UINT = &HE0
		Dim mAlphaTxt As UINT = &HFF
		Dim mOpacity As UINT = &H80
		
		Declare Sub TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Sub mnuMenu_Click(ByRef Sender As MenuItem)
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub Form_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Message(ByRef Sender As Control, ByRef Msg As Message)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Constructor
		Dim As TimerComponent TimerComponent1
		Dim As PopupMenu PopupMenu1
		Dim As MenuItem mnuAnalog, mnuAnalogSetting, mnuFileAnalog, mnuDrawTray, mnuDrawScale, MenuItem1, mnuText, mnuTextSetting, mnuShadow, mnuBlack, mnuRed, mnuGreen, mnuGradient, mnuShowSecond, mnuBlinkColon, MenuItem10, mnuAnalogText, mnuHand, mnuWhite, mnuBlue, MenuItem2, mnuBackgroundText, MenuItem3, MenuItem4, mnuExit, MenuItem6, mnuTransparent, mnuOpacity, mnuAspectRatio, mnuBorder, MenuItem9, mnuAbout, MenuItem7, mnuTextTray, MenuItem5, mnuSpeechNow, mnuAnnounce, MenuItem8, mnuAutoStart, mnuClickThrough, mnuAlwaysOnTop, mnuVoice, mnuAudio, MenuItem13, mnuAnnounce1, mnuAnnounce3, mnuAnnounce2, mnuAnnounce0, mnuHide, mnuBackgroundAnalog, mnuFileText, mnuAnalogTextSet, MenuItem11, mnuTextFont, MenuItem12
		Dim As OpenFileDialog OpenFileDialog1
		Dim As FontDialog FontDialog1
	End Type
	
	Constructor frmClockType
		' frmClock
		With This
			.Name = "frmClock"
			.Text = "GDIP Clock"
			.Designer = @This
			.Caption = "GDIP Clock"
			.ContextMenu = @PopupMenu1
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Form_Resize)
			.OnMouseMove = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Form_MouseMove)
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnMessage = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Msg As Message), @Form_Message)
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.Icon = "1"
			.SetBounds 0, 0, 240, 200
		End With
		' TimerComponent1
		With TimerComponent1
			.Name = "TimerComponent1"
			.Interval = 200
			.Enabled = True
			.SetBounds 70, 30, 16, 16
			.Designer = @This
			.OnTimer = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent), @TimerComponent1_Timer)
			.Parent = @This
		End With
		' PopupMenu1
		With PopupMenu1
			.Name = "PopupMenu1"
			.SetBounds 40, 30, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' mnuAlwaysOnTop
		With mnuAlwaysOnTop
			.Name = "mnuAlwaysOnTop"
			.Designer = @This
			.Caption = "Always on top"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuClickThrough
		With mnuClickThrough
			.Name = "mnuClickThrough"
			.Designer = @This
			.Caption = "Click through"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuAutoStart
		With mnuAutoStart
			.Name = "mnuAutoStart"
			.Designer = @This
			.Caption = "Auto start"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' MenuItem8
		With MenuItem8
			.Name = "MenuItem8"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuAnalog
		With mnuAnalog
			.Name = "mnuAnalog"
			.Designer = @This
			.Caption = "Analog"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuAnalogSetting
		With mnuAnalogSetting
			.Name = "mnuAnalogSetting"
			.Designer = @This
			.Caption = "Setting"
			.Parent = @PopupMenu1
		End With
		' mnuAspectRatio
		With mnuAspectRatio
			.Name = "mnuAspectRatio"
			.Designer = @This
			.Caption = "Aspect ratio"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Checked = True
			.Parent = @mnuAnalogSetting
		End With
		' mnuBackgroundAnalog
		With mnuBackgroundAnalog
			.Name = "mnuBackgroundAnalog"
			.Designer = @This
			.Caption = "Background"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' mnuFileAnalog
		With mnuFileAnalog
			.Name = "mnuFileAnalog"
			.Designer = @This
			.Caption = "File..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' MenuItem3
		With MenuItem3
			.Name = "MenuItem3"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuAnalogSetting
		End With
		' mnuDrawTray
		With mnuDrawTray
			.Name = "mnuDrawTray"
			.Designer = @This
			.Caption = "Draw tray"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' mnuDrawScale
		With mnuDrawScale
			.Name = "mnuDrawScale"
			.Designer = @This
			.Caption = "Draw scale"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' MenuItem1
		With MenuItem1
			.Name = "MenuItem1"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuText
		With mnuText
			.Name = "mnuText"
			.Designer = @This
			.Caption = "Text"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuTextSetting
		With mnuTextSetting
			.Name = "mnuTextSetting"
			.Designer = @This
			.Caption = "Setting"
			.Enabled = False
			.Parent = @PopupMenu1
		End With
		' mnuBackgroundText
		With mnuBackgroundText
			.Name = "mnuBackgroundText"
			.Designer = @This
			.Caption = "Background"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuFileText
		With mnuFileText
			.Name = "mnuFileText"
			.Designer = @This
			.Caption = "File..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' MenuItem11
		With MenuItem11
			.Name = "MenuItem11"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuTextSetting
		End With
		' mnuTextSet
		With mnuTextFont
			.Name = "mnuTextFont"
			.Designer = @This
			.Caption = "Text..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' MenuItem2
		With MenuItem2
			.Name = "MenuItem2"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuTextSetting
		End With
		' mnuTextTray
		With mnuTextTray
			.Name = "mnuTextTray"
			.Designer = @This
			.Caption = "Draw tray"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Checked = True
			.Parent = @mnuTextSetting
		End With
		' mnuShowSecond
		With mnuShowSecond
			.Name = "mnuShowSecond"
			.Designer = @This
			.Caption = "Show Second"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuBlinkColon
		With mnuBlinkColon
			.Name = "mnuBlinkColon"
			.Designer = @This
			.Caption = "Blink colon"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' MenuItem9
		With MenuItem9
			.Name = "MenuItem9"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuTextSetting
		End With
		' mnuBorder
		With mnuBorder
			.Name = "mnuBorder"
			.Designer = @This
			.Caption = "Broder"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuShadow
		With mnuShadow
			.Name = "mnuShadow"
			.Designer = @This
			.Caption = "Shadow"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' MenuItem10
		With MenuItem10
			.Name = "MenuItem10"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuTextSetting
		End With
		' mnuBlack
		With mnuBlack
			.Name = "mnuBlack"
			.Designer = @This
			.Caption = "Black"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuWhite
		With mnuWhite
			.Name = "mnuWhite"
			.Designer = @This
			.Caption = "White"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuRed
		With mnuRed
			.Name = "mnuRed"
			.Designer = @This
			.Caption = "Red"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuGreen
		With mnuGreen
			.Name = "mnuGreen"
			.Designer = @This
			.Caption = "Green"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuBlue
		With mnuBlue
			.Name = "mnuBlue"
			.Designer = @This
			.Caption = "Blue"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuGradient
		With mnuGradient
			.Name = "mnuGradient"
			.Designer = @This
			.Caption = "Gradient"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuHand
		With mnuHand
			.Name = "mnuHand"
			.Designer = @This
			.Caption = "Hand"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' MenuItem12
		With MenuItem12
			.Name = "MenuItem12"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogText
		With mnuAnalogText
			.Name = "mnuAnalogText"
			.Designer = @This
			.Caption = "Text"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogTextSet
		With mnuAnalogTextSet
			.Name = "mnuAnalogTextSet"
			.Designer = @This
			.Caption = "Text..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' MenuItem4
		With MenuItem4
			.Name = "MenuItem4"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuTransparent
		With mnuTransparent
			.Name = "mnuTransparent"
			.Designer = @This
			.Caption = "Transparent"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuOpacity
		With mnuOpacity
			.Name = "mnuOpacity"
			.Designer = @This
			.Caption = "Opacity"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuHide
		With mnuHide
			.Name = "mnuHide"
			.Designer = @This
			.Caption = "Hide"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' MenuItem5
		With MenuItem5
			.Name = "MenuItem5"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuAnnounce
		With mnuAnnounce
			.Name = "mnuAnnounce"
			.Designer = @This
			.Caption = "Announce"
			.Enabled = False
			.Parent = @PopupMenu1
		End With
		' mnuSpeechNow
		With mnuSpeechNow
			.Name = "mnuSpeechNow"
			.Designer = @This
			.Caption = "Speech time"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' MenuItem7
		With MenuItem7
			.Name = "MenuItem7"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuAbout
		With mnuAbout
			.Name = "mnuAbout"
			.Designer = @This
			.Caption = "About"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' MenuItem6
		With MenuItem6
			.Name = "MenuItem6"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuExit
		With mnuExit
			.Name = "mnuExit"
			.Designer = @This
			.Caption = "Exit"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' OpenFileDialog1
		With OpenFileDialog1
			.Name = "OpenFileDialog1"
			.SetBounds 10, 30, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' mnuVoice
		With mnuVoice
			.Name = "mnuVoice"
			.Designer = @This
			.Caption = "Voice"
			.Enabled = False
			.Parent = @mnuAnnounce
		End With
		' mnuAudio
		With mnuAudio
			.Name = "mnuAudio"
			.Designer = @This
			.Caption = "Audio"
			.Enabled = False
			.Parent = @mnuAnnounce
		End With
		' MenuItem13
		With MenuItem13
			.Name = "MenuItem13"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuAnnounce
		End With
		' mnuAnnounce0
		With mnuAnnounce0
			.Name = "mnuAnnounce0"
			.Designer = @This
			.Caption = "None"
			.Parent = @mnuAnnounce
		End With
		' mnuAnnounce1
		With mnuAnnounce1
			.Name = "mnuAnnounce1"
			.Designer = @This
			.Caption = "Hourly"
			.Parent = @mnuAnnounce
		End With
		' mnuAnnounce2
		With mnuAnnounce2
			.Name = "mnuAnnounce2"
			.Designer = @This
			.Caption = "Half hour"
			.Parent = @mnuAnnounce
		End With
		' mnuAnnounce3
		With mnuAnnounce3
			.Name = "mnuAnnounce3"
			.Designer = @This
			.Caption = "Quarter hour"
			.Checked = True
			.Parent = @mnuAnnounce
		End With
		' FontDialog1
		With FontDialog1
			.Name = "FontDialog1"
			.SetBounds 100, 30, 16, 16
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frmClock As frmClockType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmClock.MainForm = True
		frmClock.Show
		App.Run
	#endif
'#End Region

'Region Tray Menu
#include once "windows.bi"
Dim Shared As NOTIFYICONDATA SystrayIcon
Const WM_SHELLNOTIFY = WM_USER + 5

Function CheckAutoStart() As Integer
	#ifdef __USE_WINAPI__
		'Region registry
		Dim As Any Ptr hReg
		Static As WString Ptr sNewRegValue= 0
		Dim As DWORD lRegLen = 0
		Dim As DWORD lpType  = 0
		Dim As Long lRes
		
		'open
		lRes = RegOpenKeyEx(HKEY_CURRENT_USER, "SOFTWARE\Microsoft\Windows\CurrentVersion\Run", 0, KEY_ALL_ACCESS, @hReg)
		If lRes <> ERROR_SUCCESS Then
			RegCloseKey(hReg)
			Exit Function
		End If
		
		lRes = RegQueryValueEx(hReg, WStr("VFBE GDIP Clock"), 0, @lpType, 0, @lRegLen)
		If lRes <> ERROR_SUCCESS Then RegCloseKey(hReg): Exit Function
		
		sNewRegValue = Reallocate(sNewRegValue, (lRegLen + 1) * 2)
		lRes = RegQueryValueEx(hReg, WStr("VFBE GDIP Clock"), 0, @lpType, Cast(Byte Ptr, sNewRegValue), @lRegLen)
		If lRes <> ERROR_SUCCESS Then RegCloseKey(hReg): Exit Function
		
		'close registry
		RegCloseKey(hReg)
		
		Return lRegLen
	#else
		Return 0
	#endif
End Function

Sub AutoStartReg(flag As Boolean = True)
	#ifdef __USE_WINAPI__
		'Region registry
		Dim As Any Ptr hReg
		Dim As WString Ptr sNewRegValue
		Dim As Integer lRegLen = (Len(WChr(34) & Command(0) & WChr(34) & WChr(0)) + 1) * 2
		
		sNewRegValue = Allocate(lRegLen)
		*sNewRegValue = WChr(34) & Command(0) & WChr(34) & WChr(0)
		
		'open
		RegOpenKeyEx(HKEY_CURRENT_USER, "SOFTWARE\Microsoft\Windows\CurrentVersion\Run", 0, KEY_ALL_ACCESS, @hReg)
		
		If flag Then
			RegSetValueEx(hReg, WStr("VFBE GDIP Clock"), NULL, REG_SZ, Cast(Byte Ptr, sNewRegValue), lRegLen)
		Else
			RegDeleteValue(hReg, WStr("VFBE GDIP Clock"))
		End If
		
		RegFlushKey(hReg)
		
		'close registry
		RegCloseKey(hReg)
		Deallocate(sNewRegValue)
	#endif
End Sub

Private Sub frmClockType.ProfileInitial()
	ReDim sKey(sKeyCount)
	ReDim sKeyLen(sKeyCount)
	WLet(sKey(0), WStr("Left = "))
	WLet(sKey(1), WStr("Top = "))
	WLet(sKey(2), WStr("Width = "))
	WLet(sKey(3), WStr("Height = "))
	WLet(sKey(4), WStr("Always on top = "))
	WLet(sKey(5), WStr("Click through = "))
	WLet(sKey(6), WStr("Analog = "))
	WLet(sKey(7), WStr("Analog Background file = "))
	WLet(sKey(8), WStr("Analog Background = "))
	WLet(sKey(9), WStr("Analog Aspect ratio = "))
	WLet(sKey(10), WStr("Analog Draw tray = "))
	WLet(sKey(11), WStr("Analog Draw scale = "))
	WLet(sKey(12), WStr("Analog Hand = "))
	WLet(sKey(13), WStr("Analog Text = "))
	WLet(sKey(14), WStr("Text = "))
	WLet(sKey(15), WStr("Text Background file = "))
	WLet(sKey(16), WStr("Text Background = "))
	WLet(sKey(17), WStr("Text Draw tray = "))
	WLet(sKey(18), WStr("Text Show second = "))
	WLet(sKey(19), WStr("Text Blink colon = "))
	WLet(sKey(20), WStr("Text Broder = "))
	WLet(sKey(21), WStr("Text Shadow = "))
	WLet(sKey(22), WStr("Text Color = "))
	WLet(sKey(23), WStr("Transparent = "))
	WLet(sKey(24), WStr("Opacity = "))
	WLet(sKey(25), WStr("Hide = "))
	WLet(sKey(26), WStr("Announce freequency = "))
	WLet(sKey(27), WStr("Voice = "))
	WLet(sKey(28), WStr("Audio = "))
	WLet(sKey(29), WStr("Analog Font Name = "))
	WLet(sKey(30), WStr("Analog Font Bold = "))
	WLet(sKey(31), WStr("Analog Font Color = "))
	WLet(sKey(32), WStr("Text Font Name = "))
	WLet(sKey(33), WStr("Text Font Bold = "))
	Dim i As Integer
	For i = 0 To sKeyCount
		sKeyLen(i) = Len(*sKey(i))
	Next
End Sub

Private Sub frmClockType.ProfileRelease()
	Erase sKeyLen
	ArrayDeallocate(sKey())
End Sub

Private Sub frmClockType.ProfileLoad(sFileName As WString)
	Dim s As WString Ptr
	Dim v As WString Ptr
	
	WLet(s, TextFromFile(sFileName))
	
	Dim ss() As WString Ptr
	Dim i As Integer
	Dim j As Integer = SplitWStr(*s, !"\r\n", ss())
	Dim k As Integer
	Dim l As Integer
	Dim m As Integer
	
	Dim frmLocate(3) As Integer
	frmLocate(0) = This.Left
	frmLocate(1) = This.Top
	frmLocate(2) = This.Width
	frmLocate(3) = This.Height
	
	For i = 0 To j
		l = Len(*ss(i))
		For k = 0 To sKeyCount
			m = InStr(*ss(i), *sKey(k))
			If m Then
				WLet(v, Mid(*ss(i), m + sKeyLen(k), l - sKeyLen(k)))
				Print i, m, sKeyLen(k), *sKey(k), *v
				Select Case k
				Case 0
					frmLocate(0) = CInt(*v)
				Case 1
					frmLocate(1) = CInt(*v)
				Case 2
					frmLocate(2) = CInt(*v)
				Case 3
					frmLocate(3) = CInt(*v)
				Case 4
					mnuAlwaysOnTop.Checked = CBool(*v)
				Case 5
					mnuClickThrough.Checked = CBool(*v)
				Case 6
					If CBool(*v) Then mnuMenu_Click(mnuAnalog)
				Case 7
					If *v <> "" Then
						mAnalogClock.FileName = *v
						mnuFileAnalog.Caption = *v
					End If
				Case 8
					mnuBackgroundAnalog.Checked = CBool(*v)
					mAnalogClock.mBackground = mnuBackgroundAnalog.Checked
				Case 9
					mnuAspectRatio.Checked = CBool(*v)
				Case 10
					mnuDrawTray.Checked = CBool(*v)
					mAnalogClock.mTray = mnuDrawTray.Checked
				Case 11
					mnuDrawScale.Checked = CBool(*v)
					mAnalogClock.mScale = mnuDrawScale.Checked
				Case 12
					mnuHand.Checked = CBool(*v)
					mAnalogClock.mHand = mnuHand.Checked
				Case 13
					mnuAnalogText.Checked = CBool(*v)
					mAnalogClock.mText = mnuAnalogText.Checked
				Case 14
					If CBool(*v) Then mnuMenu_Click(mnuText)
				Case 15
					If *v <> "" Then
						mTextClock.FileName = *v
						mnuFileText.Caption = *v
					End If
				Case 16
					mnuBackgroundText.Checked = CBool(*v)
					mTextClock.mBackground = mnuBackgroundText.Checked
				Case 17
					mnuTextTray.Checked = CBool(*v)
					mTextClock.mTray = mnuTextTray.Checked
				Case 18
					mnuShowSecond.Checked = CBool(*v)
					mTextClock.mShowSecond = mnuShowSecond.Checked
				Case 19
					mnuBlinkColon.Checked = CBool(*v)
					mTextClock.mBlinkColon = mnuBlinkColon.Checked
				Case 20
					mnuBorder.Checked = CBool(*v)
					mTextClock.mShowBorder = mnuBorder.Checked
				Case 21
					mnuShadow.Checked = CBool(*v)
					mTextClock.mShowShadow = mnuShadow.Checked
				Case 22 'color
					IndexOfTextColor = CInt(*v)
				Case 23
					mnuTransparent.Checked = CBool(*v)
				Case 24
					mnuOpacity.Checked = CBool(*v)
				Case 25
					'mnuHide.Checked = CBool(*v)
					'This.Visible = mnuHide.Checked
				Case 26 'announce
					IndexOfAnnouce = CInt(*v)
				Case 27 'voice
					IndexOfVoice = *v
				Case 28 'audio
					IndexOfAudio = *v
					
				Case 29
					WLet(mAnalogClock.mFontName, *v)
				Case 30
					mAnalogClock.mFontBold = CBool(*v) 
				Case 31
					mAnalogClock.mFontColor = CULng(*v) 
				Case 32
					WLet(mTextClock.mFontName, *v)
				Case 33
					mTextClock.mFontStyle = CLng(*v) 
				End Select
				
				Exit For
			End If
		Next
	Next
	
	ArrayDeallocate(ss())
	Deallocate(s)
	Deallocate(v)

	This.Move(frmLocate(0), frmLocate(1), frmLocate(2), frmLocate(3))
	If mnuAlwaysOnTop.Checked Then FormStyle = FormStyles.fsStayOnTop
	If mnuClickThrough.Checked Then SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) Or WS_EX_TRANSPARENT)
End Sub

Private Sub frmClockType.ProfileSave(sFileName As WString)
	Dim ss() As WString Ptr
	
	ReDim ss(sKeyCount)
	
	WLet(ss(0), *sKey(0) & This.Left)
	WLet(ss(1), *sKey(1) & This.Top)
	WLet(ss(2), *sKey(2) & This.Width)
	WLet(ss(3), *sKey(3) & This.Height)
	WLet(ss(4), *sKey(4) & mnuAlwaysOnTop.Checked)
	WLet(ss(5), *sKey(5) & mnuClickThrough.Checked)
	WLet(ss(6), *sKey(6) & mnuAnalog.Checked)
	WLet(ss(7), *sKey(7) & mAnalogClock.FileName)
	WLet(ss(8), *sKey(8) & mnuBackgroundAnalog.Checked)
	WLet(ss(9), *sKey(9) & mnuAspectRatio.Checked)
	WLet(ss(10), *sKey(10) & mnuDrawTray.Checked)
	WLet(ss(11), *sKey(11) & mnuDrawScale.Checked)
	WLet(ss(12), *sKey(12) & mnuHand.Checked)
	WLet(ss(13), *sKey(13) & mnuAnalogText.Checked)
	WLet(ss(14), *sKey(14) & mnuText.Checked)
	WLet(ss(15), *sKey(15) & mTextClock.FileName)
	WLet(ss(16), *sKey(16) & mnuBackgroundText.Checked)
	WLet(ss(17), *sKey(17) & mnuTextTray.Checked)
	WLet(ss(18), *sKey(18) & mnuShowSecond.Checked)
	WLet(ss(19), *sKey(19) & mnuBlinkColon.Checked)
	WLet(ss(20), *sKey(20) & mnuBorder.Checked)
	WLet(ss(21), *sKey(21) & mnuShadow.Checked)
	WLet(ss(22), *sKey(22) & IndexOfTextColor)
	WLet(ss(23), *sKey(23) & mnuTransparent.Checked)
	WLet(ss(24), *sKey(24) & mnuOpacity.Checked)
	WLet(ss(25), *sKey(25) & mnuHide.Checked)
	WLet(ss(26), *sKey(26) & IndexOfAnnouce)
	WLet(ss(27), *sKey(27) & IndexOfVoice)
	WLet(ss(28), *sKey(28) & IndexOfAudio)
	
	WLet(ss(29), *sKey(29) & *mAnalogClock.mFontName)
	WLet(ss(30), *sKey(30) & mAnalogClock.mFontBold)
	WLet(ss(31), *sKey(31) & mAnalogClock.mFontColor)

	WLet(ss(32), *sKey(32) & *mTextClock.mFontName)
	WLet(ss(33), *sKey(33) & mTextClock.mFontStyle)
	
	Dim s As WString Ptr
	JoinWStr(ss(), !"\r\n", s)
	If Dir(sFileName) <> "" Then Kill(sFileName)
	TextToFile(sFileName, *s)
	Debug.Print *s
	ArrayDeallocate(ss())
	Deallocate(s)
End Sub

Private Sub frmClockType.SpeechNow(sDt As Double, ByVal sLan As Integer = 0)
	Dim As WString Ptr s
	Dim m As Integer = Minute(sDt)
	Dim h As Integer = Hour(sDt)
	
	Dim s2(2) As String
	
	Select Case sLan
	Case 0
		s2(0) = "It's {hour} o'clock"
		s2(1) = "It's {hour} {minute}"
		s2(2) = "It's {hour} {minute}"
	Case 1
		s2(0) = "现在是 {hour} 点整"
		s2(1) = "现在是 {hour} 点半"
		s2(2) = "现在是 {hour} 点 {minute} 分"
	End Select
	
	Select Case m
	Case 0
		WLet(s, Replace(Replace(s2(0), "{hour}", "" & h), "{minute}", Format(m, "00")))
	Case 30
		WLet(s, Replace(Replace(s2(1), "{hour}", "" & h), "{minute}", Format(m, "00")))
	Case Else
		WLet(s, Replace(Replace(s2(2), "{hour}", "" & h), "{minute}", Format(m, "00")))
	End Select
	#ifdef __USE_WINAPI__
		If pSpVoice Then pSpVoice->Speak(s, SVSFlagsAsync, NULL)
	#endif
	WDeAllocate(s)
End Sub

Private Sub frmClockType.SpeechInit()
	#ifdef __USE_WINAPI__
		' // Create an instance of the SpVoice object
		Dim classID As IID, riid As IID
		CLSIDFromString(Afx_CLSID_SpVoice, @classID)
		IIDFromString(Afx_IID_ISpVoice, @riid)
		CoCreateInstance(@classID, NULL, CLSCTX_ALL, @riid, @pSpVoice)
		If pSpVoice = NULL Then Exit Sub
		
		mnuAnnounce.Enabled = True
		
		' // Set the object of interest to word boundaries
		pSpVoice->SetInterest(SPFEI(SPEI_WORD_BOUNDARY), SPFEI(SPEI_WORD_BOUNDARY))
		' // Set the handle of the window that will receive the MSG_SAPI_EVENT message
		pSpVoice->SetNotifyWindowMessage(Handle, MSG_SAPI_EVENT, 0, 0)
		
		Dim pVoice As Afx_ISpObjectToken Ptr
		Dim pAudio As Afx_ISpObjectToken Ptr
		Dim pTokenCategory As Afx_ISpObjectTokenCategory Ptr
		Dim pTokenEnum As Afx_IEnumSpObjectTokens Ptr
		
		Dim pTokenItem As Afx_ISpObjectToken Ptr
		Dim pStr As WString Ptr = CAllocate(0, 2048)
		Dim pCount As Long
		Dim i As Long
		
		pSpVoice->GetVoice(@pVoice)
		pVoice->GetCategory(@pTokenCategory)
		pTokenCategory->EnumTokens(@"", @"", @pTokenEnum)
		pTokenEnum->GetCount(@pCount)
		mVoiceCount = pCount - 1
		
		If mVoiceCount >-1 Then
			ReDim mnuVoiceSub(mVoiceCount)
			For i = 0 To mVoiceCount
				pTokenEnum->Item(i, @pTokenItem)
				pTokenItem->GetStringValue(NULL, @pStr)
				
				mnuVoiceSub(i) = New MenuItem
				mnuVoiceSub(i)->Designer = @This
				mnuVoiceSub(i)->Parent = @mnuVoice
				mnuVoiceSub(i)->Name = "mnuVoiceSub" & i
				mnuVoiceSub(i)->Caption = *pStr
				mnuVoiceSub(i)->OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
				mnuVoiceSub(i)->Tag = pTokenItem
				
				mnuVoice.Add mnuVoiceSub(i)
			Next
			mnuVoiceSub(0)->Checked = True
			mnuVoice.Enabled = True
			mnuMenu_Click(*mnuVoiceSub(0))
			
			pVoice->Release()
			pVoice = NULL
			pTokenCategory->Release()
			pTokenCategory = NULL
			pTokenEnum->Release()
			pTokenEnum = NULL
		End If
		
		pSpVoice->GetOutputObjectToken(@pAudio)
		pAudio->GetCategory(@pTokenCategory)
		pTokenCategory->EnumTokens(@"", @"", @pTokenEnum)
		pTokenEnum->GetCount(@pCount)
		mAudioCount = pCount - 1
		
		If mAudioCount >-1 Then
			ReDim mnuAudioSub(mAudioCount)
			For i = 0 To mAudioCount
				pTokenEnum->Item(i, @pTokenItem)
				pTokenItem->GetStringValue(NULL, @pStr)
				
				mnuAudioSub(i) = New MenuItem
				mnuAudioSub(i)->Designer = @This
				mnuAudioSub(i)->Parent = @mnuAudio
				mnuAudioSub(i)->Name = "mnuAudioSub" & i
				mnuAudioSub(i)->Caption = *pStr
				mnuAudioSub(i)->OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
				mnuAudioSub(i)->Tag = pTokenItem
				
				mnuAudio.Add mnuAudioSub(i)
			Next
			mnuAudioSub(0)->Checked = True
			
			pAudio->Release()
			pAudio = NULL
			pTokenCategory->Release()
			pTokenCategory = NULL
			pTokenEnum->Release()
			pTokenEnum = NULL
			
			mnuAudio.Enabled = True
		End If
	#endif
End Sub

Private Property frmClockType.IndexOfTextColor(v As Integer)
	Select Case v
	Case 0
		mnuMenu_Click(mnuBlack)
	Case 1
		mnuMenu_Click(mnuWhite)
	Case 2
		mnuMenu_Click(mnuRed)
	Case 3
		mnuMenu_Click(mnuGreen)
	Case 4
		mnuMenu_Click(mnuBlue)
	Case Else
		mnuMenu_Click(mnuGradient)
	End Select
End Property
Private Property frmClockType.IndexOfTextColor() As Integer
	If mnuBlack.Checked Then Return 0
	If mnuWhite.Checked Then Return 1
	If mnuRed.Checked Then Return 2
	If mnuGreen.Checked Then Return 3
	If mnuBlue.Checked Then Return 4
	If mnuGradient.Checked Then Return 5
End Property

Private Property frmClockType.IndexOfAnnouce(v As Integer)
	Select Case v
	Case 0
		mnuMenu_Click(mnuAnnounce0)
	Case 1
		mnuMenu_Click(mnuAnnounce1)
	Case 2
		mnuMenu_Click(mnuAnnounce2)
	Case Else
		mnuMenu_Click(mnuAnnounce3)
	End Select
End Property
Private Property frmClockType.IndexOfAnnouce() As Integer
	If mnuAnnounce0.Checked Then Return 0
	If mnuAnnounce1.Checked Then Return 1
	If mnuAnnounce2.Checked Then Return 2
	If mnuAnnounce3.Checked Then Return 3
End Property

Private Property frmClockType.IndexOfVoice(ByRef v As WString)
	Dim i As Integer
	For i = 0 To mVoiceCount
		If mnuVoiceSub(i)->Caption = v Then
			mnuMenu_Click(*mnuVoiceSub(i))
			Exit Property
		End If
	Next
End Property
Private Property frmClockType.IndexOfVoice() ByRef As WString
	Dim i As Integer
	For i = 0 To mVoiceCount
		If mnuVoiceSub(i)->Checked Then
			Return mnuVoiceSub(i)->Caption
		End If
	Next
End Property
Private Property frmClockType.IndexOfAudio(ByRef v As WString)
	Dim i As Integer
	For i = 0 To mAudioCount
		If mnuAudioSub(i)->Caption = v Then
			mnuMenu_Click(*mnuAudioSub(i))
			Exit Property
		End If
	Next
End Property

Private Property frmClockType.IndexOfAudio() ByRef As WString
	Dim i As Integer
	For i = 0 To mAudioCount
		If mnuAudioSub(i)->Checked Then
			Return mnuAudioSub(i)->Caption
		End If
	Next
End Property

Private Sub frmClockType.mnuMenu_Click(ByRef Sender As MenuItem)
	Dim i As Integer
	
	Select Case Sender.Name
	Case "mnuAlwaysOnTop"
		Sender.Checked = Not Sender.Checked
		FormStyle = IIf(Sender.Checked, FormStyles.fsStayOnTop, FormStyles.fsNormal)
	Case "mnuClickThrough"
		Sender.Checked = Not Sender.Checked
		i = GetWindowLong(Handle, GWL_EXSTYLE)
		SetWindowLong(Handle, GWL_EXSTYLE, IIf(Sender.Checked, i Or WS_EX_TRANSPARENT, i Xor WS_EX_TRANSPARENT))
	Case "mnuAutoStart"
		Sender.Checked = Not Sender.Checked
		AutoStartReg Sender.Checked
		CheckAutoStart
	Case "mnuAnnounce0"
		mnuAnnounce0.Checked = True
		mnuAnnounce1.Checked = False
		mnuAnnounce2.Checked = False
		mnuAnnounce3.Checked = False
	Case "mnuAnnounce1"
		mnuAnnounce0.Checked = False
		mnuAnnounce1.Checked = True
		mnuAnnounce2.Checked = False
		mnuAnnounce3.Checked = False
	Case "mnuAnnounce2"
		mnuAnnounce0.Checked = False
		mnuAnnounce1.Checked = False
		mnuAnnounce2.Checked = True
		mnuAnnounce3.Checked = False
	Case "mnuAnnounce3"
		mnuAnnounce0.Checked = False
		mnuAnnounce1.Checked = False
		mnuAnnounce2.Checked = False
		mnuAnnounce3.Checked = True
	Case "mnuSpeechNow"
		SpeechNow(Now(), mLanguage)
		
	Case "mnuAnalog"
		Sender.Checked = True
		mnuText.Checked = False
		Form_Resize(This, Width, Height)
	Case "mnuText"
		Sender.Checked = True
		mnuAnalog.Checked = False
		Form_Resize(This, Width, Height)
	Case "mnuTransparent"
		Sender.Checked = Not Sender.Checked
		If Sender.Checked Then
			If frmTrans.Enabled = Sender.Checked Then frmTrans.Enabled = Not Sender.Checked
		End If
		'GDI透明
		frmTrans.Enabled = Sender.Checked
		Form_Resize(This, Width, Height)
		If Sender.Checked Then Exit Sub
		'窗口透明
		If frmTrans.Enabled = False Then frmTrans.Enabled = True
		Opacity = IIf(mnuOpacity.Checked, mOpacity, &HFF)
	Case "mnuOpacity"
		Sender.Checked = Not Sender.Checked
		If mnuTransparent.Checked Then
		Else
			'窗口透明
			If frmTrans.Enabled = False Then frmTrans.Enabled = True
			Opacity = IIf(mnuOpacity.Checked, mOpacity, &HFF)
		End If
	Case "mnuHide"
		Sender.Checked = Not Sender.Checked
		This.Visible = Sender.Checked = False
	Case "mnuBackgroundAnalog"
		Sender.Checked = Not Sender.Checked
		mAnalogClock.mBackground = Sender.Checked
		Form_Resize(This, Width, Height)
	Case "mnuFileAnalog"
		OpenFileDialog1.FileName = mAnalogClock.FileName
		If OpenFileDialog1.Execute Then
			mAnalogClock.FileName = OpenFileDialog1.FileName
			mnuFileAnalog.Caption = OpenFileDialog1.FileName
		End If
		Form_Resize(This, Width, Height)
	Case "mnuAspectRatio"
		Sender.Checked = Not Sender.Checked
		Form_Resize(This, Width, Height)
	Case "mnuHand"
		Sender.Checked = Not Sender.Checked
		mAnalogClock.mHand = Sender.Checked
		Form_Resize(This, Width, Height)
	Case "mnuDrawTray"
		Sender.Checked = Not Sender.Checked
		mAnalogClock.mTray = Sender.Checked
		Form_Resize(This, Width, Height)
	Case "mnuDrawScale"
		Sender.Checked = Not Sender.Checked
		mAnalogClock.mScale = Sender.Checked
		Form_Resize(This, Width, Height)
	Case "mnuAnalogText"
		Sender.Checked = Not Sender.Checked
		mAnalogClock.mText = Sender.Checked
		Form_Resize(This, Width, Height)
	Case "mnuAnalogTextSet"
		FontDialog1.Font.Name = *mAnalogClock.mFontName
		FontDialog1.Font.Color = mAnalogClock.mFontColor
		FontDialog1.Font.Bold =  mAnalogClock.mFontBold
		If FontDialog1.Execute Then
			WLet(mAnalogClock.mFontName, FontDialog1.Font.Name)
			mAnalogClock.mFontColor = FontDialog1.Font.Color
			mAnalogClock.mFontBold = FontDialog1.Font.Bold
			mnuAnalogTextSet.Caption = *mAnalogClock.mFontName & ", " & mAnalogClock.mFontBold & ", &&H" & Hex(mAnalogClock.mFontColor) & "..."
		End If
	Case "mnuBackgroundText"
		Sender.Checked = Not Sender.Checked
		mTextClock.mBackground = Sender.Checked
		Form_Resize(This, Width, Height)
	Case "mnuFileText"
		OpenFileDialog1.FileName = mTextClock.FileName
		If OpenFileDialog1.Execute Then
			mTextClock.FileName = OpenFileDialog1.FileName
			mnuFileText.Caption = OpenFileDialog1.FileName
		End If
		Form_Resize(This, Width, Height)
	Case "mnuTextFont"
		FontDialog1.Font.Name = *mTextClock.mFontName
		FontDialog1.Font.Bold = IIf(mTextClock.mFontStyle = FontStyleBold, True, False)
		If FontDialog1.Execute Then
			mTextClock.TextFont(FontDialog1.Font.Name, IIf(FontDialog1.Font.Bold, FontStyleBold, FontStyleRegular))
			mnuTextFont.Caption = *mTextClock.mFontName & ", " & mTextClock.mFontStyle & "..."
			Form_Resize(This, Width, Height)
		End If
	Case "mnuTextTray"
		Sender.Checked = Not Sender.Checked
		mTextClock.mTray = Sender.Checked
		Form_Resize(This, Width, Height)
	Case "mnuShowSecond"
		Sender.Checked = Not Sender.Checked
		mTextClock.mShowSecond = Sender.Checked
		Form_Resize(This, Width, Height)
	Case "mnuBlinkColon"
		Sender.Checked = Not Sender.Checked
		mTextClock.mBlinkColon = Sender.Checked
		Form_Resize(This, Width, Height)
	Case "mnuBorder"
		Sender.Checked = Not Sender.Checked
		mTextClock.mShowBorder = Sender.Checked
		Form_Resize(This, Width, Height)
	Case "mnuShadow"
		Sender.Checked = Not Sender.Checked
		mTextClock.mShowShadow = Sender.Checked
		Form_Resize(This, Width, Height)
	Case "mnuBlack"
		mnuBlack.Checked = False
		mnuWhite.Checked = False
		mnuRed.Checked = False
		mnuGreen.Checked = False
		mnuBlue.Checked = False
		mnuGradient.Checked = False
		mTextClock.TextColor(&HFF000000, &HFF000000)
		Sender.Checked = True
	Case "mnuWhite"
		mnuBlack.Checked = False
		mnuWhite.Checked = False
		mnuRed.Checked = False
		mnuGreen.Checked = False
		mnuBlue.Checked = False
		mnuGradient.Checked = False
		mTextClock.TextColor(&HFFFFFFFF, &HFFFFFFFF)
		Sender.Checked = True
	Case "mnuRed"
		mnuBlack.Checked = False
		mnuWhite.Checked = False
		mnuRed.Checked = False
		mnuGreen.Checked = False
		mnuBlue.Checked = False
		mnuGradient.Checked = False
		mTextClock.TextColor(&HFFFF0000, &HFFFF0000)
		Sender.Checked = True
	Case "mnuGreen"
		mnuBlack.Checked = False
		mnuWhite.Checked = False
		mnuRed.Checked = False
		mnuGreen.Checked = False
		mnuBlue.Checked = False
		mnuGradient.Checked = False
		mTextClock.TextColor(&HFF00FF00, &HFF00FF00)
		Sender.Checked = True
	Case "mnuBlue"
		mnuBlack.Checked = False
		mnuWhite.Checked = False
		mnuRed.Checked = False
		mnuGreen.Checked = False
		mnuBlue.Checked = False
		mnuGradient.Checked = False
		mTextClock.TextColor(&HFF0000FF, &HFF0000FF)
		Sender.Checked = True
	Case "mnuGradient"
		mnuBlack.Checked = False
		mnuWhite.Checked = False
		mnuRed.Checked = False
		mnuGreen.Checked = False
		mnuBlue.Checked = False
		mnuGradient.Checked = False
		mTextClock.TextColor(&HFFFF00FF, &HFF00FFFF)
		Sender.Checked = True
	Case "mnuAbout"
		MsgBox(!"Visual FB Editor\r\nGDIP Clock\r\nBy Cm Wang", "GDIP Clock")
	Case "mnuExit"
		CloseForm
	Case Else
		Dim i As Integer
		Sender.Checked = True
		
		If InStr(Sender.Name, "mnuVoice") Then
			If InStr(Sender.Caption, "English") Then mLanguage = 0
			If InStr(Sender.Caption, "Chinese") Then mLanguage = 1
			For i = 0 To mVoiceCount
				If @Sender = mnuVoiceSub(i) Then
					#ifdef __USE_WINAPI__
						If pSpVoice Then pSpVoice->SetVoice(Cast(Afx_ISpObjectToken Ptr, Sender.Tag))
					#endif
				Else
					mnuVoiceSub(i)->Checked = False
				End If
			Next
		End If
		If InStr(Sender.Name, "mnuAudio") Then
			For i = 0 To mAudioCount
				If @Sender = mnuAudioSub(i) Then
					#ifdef __USE_WINAPI__
						If pSpVoice Then pSpVoice->SetOutput(Cast(Afx_ISpObjectToken Ptr, Sender.Tag), True)
					#endif
				Else
					mnuAudioSub(i)->Checked = False
				End If
			Next
		End If
	End Select
	
	mnuAnalogSetting.Enabled = mnuAnalog.Checked
	mnuTextSetting.Enabled = mnuText.Checked
	'Print "mnuMenu_Click"
End Sub

Private Sub frmClockType.Form_Create(ByRef Sender As Control)
	CoInitialize(NULL)
	ProfileInitial()
	SpeechInit()
	If CheckAutoStart() Then mnuAutoStart.Checked = True
	
	If mnuAnalog.Checked Then
		mAnalogClock.ImageInit(ClientWidth, ClientHeight, mAlphaAlg)
		frmTrans.Create(Handle, mAnalogClock.ImageUpdate(mAlphaAlg))
	End If
	If mnuText.Checked Then
		mTextClock.ImageInit(ClientWidth, ClientHeight, mAlphaTxt)
		frmTrans.Create(Handle, mTextClock.ImageUpdate(mAlphaTxt))
	End If
	
	With SystrayIcon
		.cbSize = SizeOf(SystrayIcon)
		.hWnd = Handle
		.uID = This.ID
		.uFlags = NIF_ICON Or NIF_TIP Or NIF_MESSAGE
		.szTip = !"VisualFBEditor\r\nGDIP Clock\r\nBy Cm Wang\0"
		.uCallbackMessage = WM_SHELLNOTIFY
		.hIcon = This.Icon.Handle
		.uVersion = NOTIFYICON_VERSION
	End With
	Shell_NotifyIcon(NIM_ADD, @SystrayIcon)
	App.DoEvents
	
	With SystrayIcon
		.uFlags =  NIF_INFO
		.szInfo = !"\0"
		.szInfoTitle = !"\0"
	End With
	Shell_NotifyIcon(NIM_MODIFY, @SystrayIcon)
	App.DoEvents
	
	mnuAnalogTextSet.Caption = *mAnalogClock.mFontName & ", " & mAnalogClock.mFontBold & ", &&H" & Hex(mAnalogClock.mFontColor) & "..."
	mnuTextFont.Caption = *mTextClock.mFontName & ", " & mTextClock.mFontStyle & "..."

	ProfileLoad(FullName2Path(App.FileName) & "\" & "gdipClock.ini")
	
	With SystrayIcon
		.uFlags =  NIF_INFO
		.szInfo = !"GDIP Clock\0"
		.szInfoTitle = !"VisualFBEditor\0"
		.uTimeout = 1
		.dwInfoFlags = 1
	End With
	Shell_NotifyIcon(NIM_MODIFY, @SystrayIcon)
End Sub

Private Sub frmClockType.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	If mnuTransparent.Checked Then
		If mnuAnalog.Checked Then
			If mnuAspectRatio.Checked Then
				'保持宽高比例
				If mnuBackgroundAnalog.Checked Then
					Height = mAnalogClock.mBGScale * Width
				Else
					Height = Width
				End If
			End If
			mAnalogClock.ImageInit(Width, Height, mAlphaAlg)
		End If
		If mnuText.Checked Then
			mTextClock.ImageInit(Width, Height, mAlphaTxt)
			'保持宽高比例
			Height = mTextClock.mClockHeight
		End If
	Else
		Dim h As Single = Height - ClientHeight
		If mnuAnalog.Checked Then
			If mnuAspectRatio.Checked Then
				'保持宽高比例
				If mnuBackgroundAnalog.Checked Then
					Height = h + mAnalogClock.mBGScale * ClientWidth
				Else
					Height = h + ClientWidth
				End If
			End If
			mAnalogClock.ImageInit(ClientWidth, ClientHeight, mAlphaAlg)
		End If
		If mnuText.Checked Then
			mTextClock.ImageInit(ClientWidth, ClientHeight, mAlphaTxt)
			'保持宽高比例
			Height = mTextClock.mClockHeight + h
		End If
	End If
	TimerComponent1_Timer(TimerComponent1)
	'Print "Form_Resize", Width, Height
End Sub

Private Sub frmClockType.TimerComponent1_Timer(ByRef Sender As TimerComponent)
	If mnuTransparent.Checked Then
		If mnuAnalog.Checked Then frmTrans.Create(Handle, mAnalogClock.ImageUpdate(mAlphaAlg))
		If mnuText.Checked Then frmTrans.Create(Handle, mTextClock.ImageUpdate(mAlphaTxt))
		frmTrans.Transform(IIf(mnuOpacity.Checked, mOpacity, &HFF))
	Else
		frmDC.Initial(Handle)
		memDC.Initial(0, ClientWidth, ClientHeight)
		frmGraphic.Initial(memDC.DC, True)
		If mnuAnalog.Checked Then frmGraphic.DrawImage(mAnalogClock.ImageUpdate(mAlphaAlg))
		If mnuText.Checked Then frmGraphic.DrawImage(mTextClock.ImageUpdate(mAlphaTxt))
		BitBlt(frmDC.DC, 0, 0, ClientWidth, ClientHeight, memDC.DC, 0, 0, SRCCOPY)
	End If
	
	Static sNow As Double
	Dim dNow As Double = Now()
	
	If sNow = dNow Then Exit Sub
	sNow = dNow
	If mnuAnnounce0.Checked Then Exit Sub
	If Second(dNow) <> 0 Then Exit Sub
	Dim m As Integer = Minute(dNow)
	Dim h As Integer = Hour(dNow)
	If mnuAnnounce1.Checked Then
		If m = 0 Then SpeechNow(dNow, mLanguage)
	End If
	If mnuAnnounce2.Checked Then
		If m = 0 Or m = 30 Then SpeechNow(dNow, mLanguage)
	End If
	If mnuAnnounce3.Checked Then
		If m = 0 Or m = 15 Or m = 30 Or m = 45 Then SpeechNow(dNow, mLanguage)
	End If
	'Print "TimerComponent1_Timer"
End Sub

Private Sub frmClockType.Form_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	If MouseButton <> 0 Then Exit Sub
	ReleaseCapture()
	SendMessage(Sender.Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0)
End Sub

Private Sub frmClockType.Form_Message(ByRef Sender As Control, ByRef Msg As Message)
	Select Case Msg.Msg
	Case WM_SHELLNOTIFY
		Select Case Msg.lParam
		Case WM_LBUTTONDBLCLK
			mnuMenu_Click(mnuHide)
		Case WM_RBUTTONDOWN
			Dim tPOINT As Point
			GetCursorPos(@tPOINT)
			SetForegroundWindow(Handle)
			PopupMenu1.Popup(tPOINT.X, tPOINT.Y)
		End Select
	End Select
End Sub

Private Sub frmClockType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	ProfileSave(FullName2Path(App.FileName) & "\" & "gdipClock.ini")
	ProfileRelease()
	CoUninitialize()
	Shell_NotifyIcon(NIM_DELETE, @SystrayIcon)
End Sub

