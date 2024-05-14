' Chinese Calendar 中国日历
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Clock.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/Panel.bi"
	#include once "mff/TimerComponent.bi"
	#include once "mff/Picture.bi"
	#include once "mff/Menus.bi"
	#include once "mff/ComboBoxEdit.bi"

	#include once "string.bi"
	#include once "vbcompat.bi"
	
	#include once "DrawClockCalendar.bi"
	#include once "../Sapi/Speech.bi"
	
	Using My.Sys.Forms
	Using Speech
	
	Const MSG_SAPI_EVENT = WM_USER + 1024   ' --> change me
	
	Type frmClockType Extends Form
		#ifdef __USE_WINAPI__
			pSpVoice As ISpVoice Ptr
		#endif
		
		mDClock As DitalClock
		mVoiceCount As Integer = -1
		mAudioCount As Integer = -1
		mLanguage As Integer = 0
		
		mnuVoiceSub(Any) As MenuItem Ptr
		mnuAudioSub(Any) As MenuItem Ptr
		
		Declare Sub SpeechNow(sDt As Double, ByVal sLan As Integer = 0)
		Declare Sub SpeechInit()
		
		Declare Sub TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Sub TimerComponent2_Timer(ByRef Sender As TimerComponent)
		Declare Sub Panel1_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub mnuMenu_Click(ByRef Sender As MenuItem)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Sub Form_Message(ByRef Sender As Control, ByRef Msg As Message)
		Declare Sub Form_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub Form_Move(ByRef Sender As Control)
		Declare Constructor
		
		Dim As TimerComponent TimerComponent1, TimerComponent2
		Dim As Panel Panel1
		Dim As PopupMenu PopupMenu1
		Dim As MenuItem mnuAlwaysOnTop, mnuClickThrough, mnuAutoStart, mnuTransparent, mnuBar3, mnuArrange, mnuDayCalendar, mnuMonthCalendar, mnuBar4, mnuAbout, mnuBar5, mnuExit, mnuClose, mnuHide, mnuBlinkColon, mnuShowSec, mnuHideCaption, mnuNoneBorder, mnuBar2, mnuAnnounce, mnuAnnounce1, mnuAnnounce2, mnuAnnounce3, mnuAnnounce0, mnuABar1, mnuBar1, mnuAudio, mnuVoice, mnuHeight, mnuOpacity, mnuSpeechNow
	End Type
	
	Constructor frmClockType
		' frmClock
		With This
			.Name = "frmClock"
			.Text = "VFBE Clock 32"
			#ifdef __FB_64BIT__
				.Caption = "VFBE Clock64"
			#else
				.Caption = "VFBE Clock32"
			#endif
			.Designer = @This
			.Font.Name = "Consolas"
			.Font.Size = 12
			.Font.Bold = True
			.StartPosition = FormStartPosition.CenterScreen
			.Location = Type<My.Sys.Drawing.Point>(0, 0)
			.Size = Type<My.Sys.Drawing.Size>(330, 130)
			.ContextMenu = @PopupMenu1
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnDestroy = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Destroy)
			.OnMessage = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Msg As Message), @Form_Message)
			.OnMouseMove = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Form_MouseMove)
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Form_Resize)
			.OnMove = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Move)
			.Opacity = 254
			.TransparentColor = mDClock.mClr(0)
			.Icon = "1"
			.SetBounds 0, 0, 330, 140
		End With
		' TimerComponent1
		With TimerComponent1
			.Name = "TimerComponent1"
			.Interval = 20
			.Enabled = True
			.SetBounds 10, 10, 16, 16
			.Designer = @This
			.OnTimer = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent), @TimerComponent1_Timer)
			.Parent = @This
		End With
		' TimerComponent2
		With TimerComponent2
			.Name = "TimerComponent2"
			.Interval = 500
			.SetBounds 40, 10, 16, 16
			.Designer = @This
			.OnTimer = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent), @TimerComponent2_Timer)
			.Parent = @This
		End With
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = ""
			.TabIndex = 0
			.Align = DockStyle.alClient
			.Location = Type<My.Sys.Drawing.Point>(0, 0)
			.Size = Type<My.Sys.Drawing.Size>(324, 91)
			.Enabled = False
			.DoubleBuffered = True
			.SetBounds 65280, 0, 314, 101
			.Designer = @This
			.OnPaint = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas), @Panel1_Paint)
			.Parent = @This
		End With
		' PopupMenu1
		With PopupMenu1
			.Name = "PopupMenu1"
			.SetBounds 70, 10, 16, 16
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
		' mnuBar1
		With mnuBar1
			.Name = "mnuBar1"
			.Designer = @This
			.Caption = "-"
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
		' mnuTransparent
		With mnuTransparent
			.Name = "mnuTransparent"
			.Designer = @This
			.Caption = "Transparent"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuBlinkColon
		With mnuBlinkColon
			.Name = "mnuBlinkColon"
			.Designer = @This
			.Caption = "Blink colon"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuShowSec
		With mnuShowSec
			.Name = "mnuShowSec"
			.Designer = @This
			.Caption = "Show second"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuHideCaption
		With mnuHideCaption
			.Name = "mnuHideCaption"
			.Designer = @This
			.Caption = "Hide caption"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuNoneBorder
		With mnuNoneBorder
			.Name = "mnuNoneBorder"
			.Designer = @This
			.Caption = "None border"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuHide
		With mnuHide
			.Name = "mnuHide"
			.Designer = @This
			.Caption = "Hide clock"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuHeight
		With mnuHeight
			.Name = "mnuHeight"
			.Designer = @This
			.Caption = "Height size"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuBar2
		With mnuBar2
			.Name = "mnuBar2"
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
		' mnuBar3
		With mnuBar3
			.Name = "mnuBar3"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuArrange
		With mnuArrange
			.Name = "mnuArrange"
			.Designer = @This
			.Caption = "Arrange"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuDayCalendar
		With mnuDayCalendar
			.Name = "mnuDayCalendar"
			.Designer = @This
			.Caption = "Day calendar"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuMonthCalendar
		With mnuMonthCalendar
			.Name = "mnuMonthCalendar"
			.Designer = @This
			.Caption = "Month calendar"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuClose
		With mnuClose
			.Name = "mnuClose"
			.Designer = @This
			.Caption = "Close"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuBar4
		With mnuBar4
			.Name = "mnuBar4"
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
		' mnuBar5
		With mnuBar5
			.Name = "mnuBar5"
			.Designer = @This
			.Caption = "-"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
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
		' mnuABar1
		With mnuABar1
			.Name = "mnuABar1"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuAnnounce
		End With
		' mnuAnnounce0
		With mnuAnnounce0
			.Name = "mnuAnnounce0"
			.Designer = @This
			.Caption = "None"
			.Checked = False
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnnounce
		End With
		' mnuAnnounce1
		With mnuAnnounce1
			.Name = "mnuAnnounce1"
			.Designer = @This
			.Caption = "Hourly"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnnounce
		End With
		' mnuAnnounce2
		With mnuAnnounce2
			.Name = "mnuAnnounce2"
			.Designer = @This
			.Caption = "Half hour"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnnounce
		End With
		' mnuAnnounce3
		With mnuAnnounce3
			.Name = "mnuAnnounce3"
			.Designer = @This
			.Caption = "Quarter hour"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnnounce
		End With
	End Constructor
	
	Dim Shared frmClock As frmClockType
	
	#if _MAIN_FILE_ = __FILE__
		frmClock.MainForm = True
		frmClock.Show
		App.Run
	#endif
'#End Region

'Region Tray Menu
#include once "windows.bi"
Dim Shared As NOTIFYICONDATA SystrayIcon
Const WM_SHELLNOTIFY = WM_USER + 5

#include once "frmDayCalendar.frm"
#include once "frmMonthCalendar.frm"



Private Function CheckAutoStart() As Integer
	Dim As Integer CheckResult = 0
	#ifdef __USE_WINAPI__
		'Region registry
		
		Dim As Any Ptr hReg
		Dim As WString Ptr sNewRegValue = NULL
		Dim As DWORD lRegLen = 0
		Dim As DWORD lpType  = 0
		Dim As Long lRes
		'open
		lRes = RegOpenKeyEx(HKEY_CURRENT_USER, "SOFTWARE\Microsoft\Windows\CurrentVersion\Run", 0, KEY_ALL_ACCESS, @hReg)
		If lRes <> ERROR_SUCCESS Then
			RegCloseKey(hReg)
			Exit Function
		End If
		
		lRes = RegQueryValueEx(hReg, WStr("VFBE ChineseCalendar"), 0, @lpType, 0, @lRegLen)
		If lRes <> ERROR_SUCCESS Then RegCloseKey(hReg): Exit Function
		
		sNewRegValue = Reallocate(sNewRegValue, (lRegLen + 1) * 2)
		lRes = RegQueryValueEx(hReg, WStr("VFBE ChineseCalendar"), 0, @lpType, Cast(Byte Ptr, sNewRegValue), @lRegLen)
		If lRes <> ERROR_SUCCESS Then RegCloseKey(hReg): Exit Function
		
		'close registry
		RegCloseKey(hReg)
		CheckResult = InStr(*sNewRegValue, Command(0))
		Deallocate(sNewRegValue)
	#endif
	Return CheckResult
End Function

Private Sub AutoStartReg(flag As Boolean = True)
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
			RegSetValueEx(hReg, WStr("VFBE ChineseCalendar"), NULL, REG_SZ, Cast(Byte Ptr, sNewRegValue), lRegLen)
		Else
			RegDeleteValue(hReg, WStr("VFBE ChineseCalendar"))
		End If
		
		RegFlushKey(hReg)
		
		'close registry
		RegCloseKey(hReg)
		Deallocate(sNewRegValue)
	#endif
End Sub

Private Sub frmClockType.TimerComponent1_Timer(ByRef Sender As TimerComponent)
	Static st As String
	Dim dnow As Double = Now()
	Dim dt As String = Format(dnow, "hh:mm:ss")
	If st = dt Then Exit Sub
	
	st = dt
	If mnuBlinkColon.Checked Then
		TimerComponent2.Enabled = False
		TimerComponent2.Enabled = True
	End If
	mDClock.Mark = 1
	Panel1.Repaint
	
	If mnuAnnounce0.Checked Then Exit Sub
	If Second(dnow) <> 0 Then Exit Sub
	Dim m As Integer = Minute(dnow)
	Dim h As Integer = Hour(dnow)
	If mnuAnnounce1.Checked Then
		If m = 0 Then SpeechNow(dnow, mLanguage)
	End If
	If mnuAnnounce2.Checked Then
		If m = 0 Or m = 30 Then SpeechNow(dnow, mLanguage)
	End If
	If mnuAnnounce3.Checked Then
		If m = 0 Or m = 15 Or m = 30 Or m = 45 Then SpeechNow(dnow, mLanguage)
	End If
End Sub

Private Sub frmClockType.SpeechInit()
	#ifdef __USE_WINAPI__
		' // Create an instance of the SpVoice object
		Dim classID As IID, riid As IID
		CLSIDFromString(CLSID_SpVoice, @classID)
		IIDFromString(IID_ISpVoice, @riid)
		CoCreateInstance(@classID, NULL, CLSCTX_ALL, @riid, @pSpVoice)
		If pSpVoice = NULL Then Exit Sub
		
		mnuAnnounce.Enabled = True
		
		' // Set the object of interest to word boundaries
		pSpVoice->SetInterest(SPFEI(SPEI_WORD_BOUNDARY), SPFEI(SPEI_WORD_BOUNDARY))
		' // Set the handle of the window that will receive the MSG_SAPI_EVENT message
		pSpVoice->SetNotifyWindowMessage(Handle, MSG_SAPI_EVENT, 0, 0)
		
		Dim pVoice As ISpObjectToken Ptr
		Dim pAudio As ISpObjectToken Ptr
		Dim pTokenCategory As ISpObjectTokenCategory Ptr
		Dim pTokenEnum As IEnumSpObjectTokens Ptr
		
		Dim pTokenItem As ISpObjectToken Ptr
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

Private Sub frmClockType.TimerComponent2_Timer(ByRef Sender As TimerComponent)
	TimerComponent2.Enabled = False
	mDClock.Mark = 0
	Panel1.Repaint
End Sub

Private Sub frmClockType.Panel1_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	mDClock.DrawClock(Canvas, Now, mnuHeight.Checked)
End Sub

Private Sub frmClockType.mnuMenu_Click(ByRef Sender As MenuItem)
	Select Case Sender.Name
	Case "mnuAlwaysOnTop"
		Sender.Checked = Not Sender.Checked
		FormStyle = IIf(Sender.Checked, FormStyles.fsStayOnTop, FormStyles.fsNormal)
	Case "mnuClickThrough"
		Sender.Checked = Not Sender.Checked
		If Sender.Checked Then
			#ifdef __USE_WINAPI__
				SetWindowLongPtr(Handle, GWL_EXSTYLE, GetWindowLongPtr(Handle, GWL_EXSTYLE) Or WS_EX_TRANSPARENT)
				If frmDayCalendar.Handle Then SetWindowLongPtr(frmDayCalendar.Handle, GWL_EXSTYLE, GetWindowLongPtr(frmDayCalendar.Handle, GWL_EXSTYLE) Or WS_EX_TRANSPARENT)
				If frmMonthCalendar.Handle Then SetWindowLongPtr(frmMonthCalendar.Handle, GWL_EXSTYLE, GetWindowLongPtr(frmMonthCalendar.Handle, GWL_EXSTYLE) Or WS_EX_TRANSPARENT)
			#endif
		Else
			#ifdef __USE_WINAPI__
				SetWindowLongPtr(Handle, GWL_EXSTYLE, GetWindowLongPtr(Handle, GWL_EXSTYLE) Xor WS_EX_TRANSPARENT)
				If frmDayCalendar.Handle Then SetWindowLongPtr(frmDayCalendar.Handle, GWL_EXSTYLE, GetWindowLongPtr(frmDayCalendar.Handle, GWL_EXSTYLE) Xor WS_EX_TRANSPARENT)
				If frmMonthCalendar.Handle Then SetWindowLongPtr(frmMonthCalendar.Handle, GWL_EXSTYLE, GetWindowLongPtr(frmMonthCalendar.Handle, GWL_EXSTYLE) Xor WS_EX_TRANSPARENT)
			#endif
		End If
	Case "mnuAutoStart"
		Sender.Checked = Not Sender.Checked
		AutoStartReg Sender.Checked
		CheckAutoStart
	Case "mnuOpacity"
		Sender.Checked = Not Sender.Checked
		Opacity = IIf(Sender.Checked = True, 127, 255)
		If frmDayCalendar.Handle Then frmDayCalendar.Opacity = Opacity
		If frmMonthCalendar.Handle Then frmMonthCalendar.Opacity = Opacity
	Case "mnuTransparent"
		Sender.Checked = Not Sender.Checked
		Transparent = Sender.Checked
		If frmDayCalendar.Handle Then frmDayCalendar.Transparent = Transparent
		If frmMonthCalendar.Handle Then frmMonthCalendar.Transparent = Transparent
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
	Case "mnuNoneBorder"
		Sender.Checked = Not Sender.Checked
		BorderStyle = IIf(Sender.Checked, FormBorderStyle.None, FormBorderStyle.Sizable)
		If frmDayCalendar.Handle Then frmDayCalendar.BorderStyle = BorderStyle
		If frmMonthCalendar.Handle Then frmMonthCalendar.BorderStyle = BorderStyle
	Case "mnuHideCaption"
		Sender.Checked = Not Sender.Checked
		ShowCaption = Not Sender.Checked
		If frmDayCalendar.Handle Then frmDayCalendar.ShowCaption = ShowCaption
		If frmMonthCalendar.Handle Then frmMonthCalendar.ShowCaption = ShowCaption
	Case "mnuShowSec"
		Sender.Checked = Not Sender.Checked
		mDClock.ShowSecond = Sender.Checked
	Case "mnuBlinkColon"
		Sender.Checked = Not Sender.Checked
	Case "mnuHide"
		Sender.Checked = Not Sender.Checked
		This.Visible = Sender.Checked = False
		If frmDayCalendar.Handle Then frmDayCalendar.Visible = This.Visible
		If frmMonthCalendar.Handle Then frmMonthCalendar.Visible = This.Visible
	Case "mnuHeight"
		Sender.Checked = Not Sender.Checked
		Panel1.Repaint
		If frmDayCalendar.Handle Then frmDayCalendar.Panel1.Repaint
		If frmMonthCalendar.Handle Then frmMonthCalendar.Panel2.Repaint
		Panel1.Repaint
	Case "mnuArrange"
		Sender.Checked = Not Sender.Checked
		Form_Resize(This, 0, 0)
	Case "mnuDayCalendar"
		Sender.Checked = Not Sender.Checked
		With frmDayCalendar
			If Sender.Checked Then
				.Show(frmClock)
				.Visible = Not mnuHide.Checked
				If mnuClickThrough.Checked Then
					#ifdef __USE_WINAPI__
						SetWindowLongPtr(.Handle, GWL_EXSTYLE, GetWindowLongPtr(.Handle, GWL_EXSTYLE) Or WS_EX_TRANSPARENT)
					#endif
				Else
					'SetWindowLongPtr(.Handle, GWL_EXSTYLE, GetWindowLongPtr(.Handle, GWL_EXSTYLE) Xor WS_EX_TRANSPARENT)
				End If
				.ShowCaption = ShowCaption
				.BorderStyle = BorderStyle
				.Opacity = Opacity
				.Transparent = Transparent
			Else
				If .Handle Then .CloseForm
			End If
		End With
		Form_Resize(This, 0, 0)
	Case "mnuMonthCalendar"
		Sender.Checked = Not Sender.Checked
		With frmMonthCalendar
			If Sender.Checked Then
				.Show(frmClock)
				.Visible = Not mnuHide.Checked
				If mnuClickThrough.Checked Then
					#ifdef __USE_WINAPI__
						SetWindowLongPtr(.Handle, GWL_EXSTYLE, GetWindowLongPtr(.Handle, GWL_EXSTYLE) Or WS_EX_TRANSPARENT)
					#endif
				Else
					'SetWindowLongPtr(.Handle, GWL_EXSTYLE, GetWindowLongPtr(.Handle, GWL_EXSTYLE) Xor WS_EX_TRANSPARENT)
				End If
				.ShowCaption = ShowCaption
				.BorderStyle = BorderStyle
				.Opacity = Opacity
				.Transparent = Transparent
			Else
				If .Handle Then .CloseForm
			End If
		End With
		Form_Resize(This, 0, 0)
	Case "mnuClose"
		If mnuDayCalendar.Checked Then frmDayCalendar.CloseForm
		If mnuMonthCalendar.Checked Then frmMonthCalendar.CloseForm
	Case "mnuAbout"
		MsgBox(!"Visual FB Editor\r\n\r\nChineseCalendar Example\r\nBy Cm Wang", "ChineseCalendar Example")
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
						If pSpVoice Then pSpVoice->SetVoice(Cast(ISpObjectToken Ptr, Sender.Tag))
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
						If pSpVoice Then pSpVoice->SetOutput(Cast(ISpObjectToken Ptr, Sender.Tag), True)
					#endif
				Else
					mnuAudioSub(i)->Checked = False
				End If
			Next
		End If
	End Select
End Sub

Private Sub frmClockType.Form_Create(ByRef Sender As Control)
	If CheckAutoStart() Then mnuAutoStart.Checked = True
	
	SetWindowLong Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) Or WS_EX_LAYERED
	
	#ifdef __USE_WINAPI__
		CoInitialize(NULL)
		SpeechInit()
		
		With SystrayIcon
			.cbSize = SizeOf(SystrayIcon)
			.hWnd = Handle
			.uID = This.ID
			.uFlags = NIF_ICON Or NIF_TIP Or NIF_MESSAGE
			.szTip = !"VisualFBEditor\r\nChineseCalendar\0"
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
		
		With SystrayIcon
			.uFlags =  NIF_INFO
			.szInfo = !"Chinese Calendar\0"
			.szInfoTitle = !"VisualFBEditor\0"
			.uTimeout = 1
			.dwInfoFlags = 1
		End With
		Shell_NotifyIcon(NIM_MODIFY, @SystrayIcon)
	#else
		
	#endif
End Sub

Private Sub frmClockType.Form_Destroy(ByRef Sender As Control)
	#ifdef __USE_WINAPI__
		Shell_NotifyIcon(NIM_DELETE, @SystrayIcon)
		'释放资源
		pSpVoice->Release()
		CoUninitialize()
	#endif
End Sub

Private Sub frmClockType.Form_Message(ByRef Sender As Control, ByRef Msg As Message)
	#ifdef __USE_WINAPI__
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
		Case WM_NCCALCSIZE
			'Have a small bar after hide the caption, this code to remove it.
			'There also have a None Border option for full display on the form.
			'If you like the small bar, then remark it.
			'If Not ShowCaption Then
			'	Dim As LPNCCALCSIZE_PARAMS pncc = Cast(LPNCCALCSIZE_PARAMS, Msg.lParam)
			'	pncc->rgrc(0).Top -= 6
			'End If
		End Select
	#endif
End Sub

Private Sub frmClockType.Form_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	If MouseButton <> 0 Then Exit Sub
	#ifdef __USE_WINAPI__
		ReleaseCapture()
		SendMessage(Sender.Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0)
	#endif
End Sub

Private Sub frmClockType.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	If mnuArrange.Checked Then
		If frmDayCalendar.Handle Then
			frmDayCalendar.Move Left, Top + Height, Width, Height * 1.78
			If frmMonthCalendar.Handle Then frmMonthCalendar.Move Left, Top + Height * 2.78, Width, Height * 1.78
		Else
			If frmMonthCalendar.Handle Then frmMonthCalendar.Move Left, Top + Height, Width, Height * 1.78
		End If
	End If
End Sub

Private Sub frmClockType.Form_Move(ByRef Sender As Control)
	Form_Resize(This, 0, 0)
End Sub
