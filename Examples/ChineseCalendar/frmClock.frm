' Chinese Calendar 中国日历
' Copyright (c) 2023 CM.Wang
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
	
	#include once "string.bi"
	#include once "vbcompat.bi"
	
	#include once "LunarCalendar.bi"
	#include once "DrawClockCalendar.bi"
	
	Using My.Sys.Forms
	
	Type frmClockType Extends Form
		DClock As DitalClock
		
		Declare Sub TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Sub TimerComponent2_Timer(ByRef Sender As TimerComponent)
		Declare Sub Picture1_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub mnu_Click(ByRef Sender As MenuItem)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Sub Form_Message(ByRef Sender As Control, ByRef Msg As Message)
		Declare Sub Form_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Constructor
		
		Dim As TimerComponent TimerComponent1, TimerComponent2
		Dim As Panel Picture1
		Dim As PopupMenu PopupMenu1
		Dim As MenuItem mnuAlwaysOnTop, mnuClickThrough, mnuAutoStart, mnuTransparent, mnuBar1, mnuArrange, mnuDayCalendar, mnuMonthCalendar, mnuBar2, mnuAbout, mnuBar3, mnuExit, mnuClose, mnuHide, mnuBlinkColon, mnuShowSec, mnuHideCaption, mnuNoneBorder
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
			.Opacity = 254
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
		' Picture1
		With Picture1
			.Name = "Picture1"
			.Text = ""
			.TabIndex = 0
			.Align = DockStyle.alClient
			.Location = Type<My.Sys.Drawing.Point>(0, 0)
			.Size = Type<My.Sys.Drawing.Size>(324, 91)
			.Enabled = False
			.SetBounds 65250, 0, 314, 101
			.Designer = @This
			.OnPaint = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas), @Picture1_Paint)
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
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuClickThrough
		With mnuClickThrough
			.Name = "mnuClickThrough"
			.Designer = @This
			.Caption = "Click through"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuAutoStart
		With mnuAutoStart
			.Name = "mnuAutoStart"
			.Designer = @This
			.Caption = "Auto start"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuTransparent
		With mnuTransparent
			.Name = "mnuTransparent"
			.Designer = @This
			.Caption = "Transparent"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuBlinkColon
		With mnuBlinkColon
			.Name = "mnuBlinkColon"
			.Designer = @This
			.Caption = "Blink colon"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuShowSec
		With mnuShowSec
			.Name = "mnuShowSec"
			.Designer = @This
			.Caption = "Show second"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuHideCaption
		With mnuHideCaption
			.Name = "mnuHideCaption"
			.Designer = @This
			.Caption = "Hide caption"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuNoneBorder
		With mnuNoneBorder
			.Name = "mnuNoneBorder"
			.Designer = @This
			.Caption = "None border"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuHide
		With mnuHide
			.Name = "mnuHide"
			.Designer = @This
			.Caption = "Hide clock"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuBar1
		With mnuBar1
			.Name = "mnuBar1"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuArrange
		With mnuArrange
			.Name = "mnuArrange"
			.Designer = @This
			.Caption = "Arrange"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuDayCalendar
		With mnuDayCalendar
			.Name = "mnuDayCalendar"
			.Designer = @This
			.Caption = "Day calendar"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuMonthCalendar
		With mnuMonthCalendar
			.Name = "mnuMonthCalendar"
			.Designer = @This
			.Caption = "Month calendar"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuClose
		With mnuClose
			.Name = "mnuClose"
			.Designer = @This
			.Caption = "Close"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuBar2
		With mnuBar2
			.Name = "mnuBar2"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuAbout
		With mnuAbout
			.Name = "mnuAbout"
			.Designer = @This
			.Caption = "About"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuBar3
		With mnuBar3
			.Name = "mnuBar3"
			.Designer = @This
			.Caption = "-"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuExit
		With mnuExit
			.Name = "mnuExit"
			.Designer = @This
			.Caption = "Exit"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Parent = @PopupMenu1
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

Function CheckAutoStart() As Integer
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
	
	lRes = RegQueryValueEx(hReg, WStr("VFBE ChineseCalendar"), 0, @lpType, 0, @lRegLen)
	If lRes <> ERROR_SUCCESS Then RegCloseKey(hReg): Exit Function
	
	sNewRegValue = Reallocate(sNewRegValue, (lRegLen + 1) * 2)
	lRes = RegQueryValueEx(hReg, WStr("VFBE ChineseCalendar"), 0, @lpType, Cast(Byte Ptr, sNewRegValue), @lRegLen)
	If lRes <> ERROR_SUCCESS Then RegCloseKey(hReg): Exit Function
	
	'close registry
	RegCloseKey(hReg)
	
	Return lRegLen
End Function

Sub AutoStartReg(flag As Boolean = True)
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
End Sub

Private Sub frmClockType.TimerComponent1_Timer(ByRef Sender As TimerComponent)
	Static st As String
	Dim dnow As Double= Now()
	Dim dt As String = Format(dnow, "hh:mm:ss")
	If st = dt Then Exit Sub
	
	st = dt
	If mnuBlinkColon.Checked Then
		TimerComponent2.Enabled = False
		TimerComponent2.Enabled = True
	End If
	
	DClock.Mark = 1
	Picture1.Repaint
	'DClock.DrawClock Picture1.Canvas, dnow, 1
End Sub

Private Sub frmClockType.TimerComponent2_Timer(ByRef Sender As TimerComponent)
	TimerComponent2.Enabled = False
	DClock.Mark = 0
	Picture1.Repaint
	'DClock.DrawClock Picture1.Canvas, Now, 0
End Sub

Private Sub frmClockType.Picture1_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	DClock.DrawClock Canvas, Now, -1
End Sub

Private Sub frmClockType.mnu_Click(ByRef Sender As MenuItem)
	Select Case Sender.Name
	Case "mnuAlwaysOnTop"
		If Sender.Checked Then
			Sender.Checked = False
			SetWindowPos Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE Or SWP_NOACTIVATE
			SetWindowLongPtr(Handle, GWL_EXSTYLE, GetWindowLongPtr(Handle, GWL_EXSTYLE) Xor WS_EX_TOPMOST Or WS_EX_LAYERED)
		Else
			Sender.Checked = True
			SetWindowPos Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE Or SWP_NOACTIVATE
			SetWindowLongPtr(Handle, GWL_EXSTYLE, GetWindowLongPtr(Handle, GWL_EXSTYLE) Or WS_EX_TOPMOST Or WS_EX_LAYERED)
		End If
	Case "mnuClickThrough"
		If Sender.Checked Then
			Sender.Checked = False
			SetWindowLongPtr(Handle, GWL_EXSTYLE, GetWindowLongPtr(Handle, GWL_EXSTYLE) Xor WS_EX_TRANSPARENT Or WS_EX_LAYERED)
		Else
			Sender.Checked = True
			SetWindowLongPtr(Handle, GWL_EXSTYLE, GetWindowLongPtr(Handle, GWL_EXSTYLE) Or WS_EX_TRANSPARENT Or WS_EX_LAYERED)
		End If
	Case "mnuAutoStart"
		If Sender.Checked Then
			Sender.Checked = False
		Else
			Sender.Checked = True
		End If
		AutoStartReg Sender.Checked
		CheckAutoStart
	Case "mnuTransparent"
		If Sender.Checked Then
			Sender.Checked = False
		Else
			Sender.Checked = True
		End If
		Opacity = IIf(Sender.Checked = True, 127, 255)
		frmDayCalendar.Opacity = Opacity
		frmMonthCalendar.Opacity = Opacity
	Case "mnuNoneBorder"
		If Sender.Checked Then
			Sender.Checked = False
		Else
			Sender.Checked = True
		End If
		BorderStyle = IIf(Sender.Checked, FormBorderStyle.None, FormBorderStyle.Sizable)
		frmDayCalendar.BorderStyle = BorderStyle
		frmMonthCalendar.BorderStyle = BorderStyle
	Case "mnuHideCaption"
		If Sender.Checked Then
			Sender.Checked = False
		Else
			Sender.Checked = True
		End If
		ShowCaption = Not Sender.Checked
		frmDayCalendar.ShowCaption = ShowCaption
		frmMonthCalendar.ShowCaption = ShowCaption
	Case "mnuShowSec"
		If Sender.Checked Then
			Sender.Checked = False
		Else
			Sender.Checked = True
		End If
		DClock.ShowSecond = Sender.Checked
	Case "mnuBlinkColon"
		If Sender.Checked Then
			Sender.Checked = False
		Else
			Sender.Checked = True
		End If
	Case "mnuHide"
		Sender.Checked = Sender.Checked = False
		This.Visible = Sender.Checked = False
		If mnuDayCalendar.Checked Then frmDayCalendar.Visible = This.Visible
		If mnuMonthCalendar.Checked Then frmMonthCalendar.Visible = This.Visible
	Case "mnuArrange"
		If frmDayCalendar.Handle Then
			frmDayCalendar.Move Left, Top + Height, Width, Height * 1.8
			If frmMonthCalendar.Handle Then
				frmMonthCalendar.Move frmDayCalendar.Left, frmDayCalendar.Top + frmDayCalendar.Height, Width, Height * 1.8
			Else
				Print "frmMonthCalendar"
			End If
		Else
			Print "frmDayCalendar"
			If frmMonthCalendar.Handle Then
				frmMonthCalendar.Move Left, Top + Height, Width, Height * 1.8
			Else
				Print "frmMonthCalendar"
			End If
		End If
	Case "mnuDayCalendar"
		If Sender.Checked Then
			frmDayCalendar.CloseForm
			Sender.Checked = False
		Else
			frmDayCalendar.Show(frmClock)
			frmDayCalendar.Visible = mnuHide.Checked = False
			frmDayCalendar.ShowCaption = ShowCaption
			frmDayCalendar.BorderStyle = BorderStyle
			Sender.Checked = True
		End If
	Case "mnuMonthCalendar"
		If Sender.Checked Then
			frmMonthCalendar.CloseForm
			Sender.Checked = False
		Else
			frmMonthCalendar.Show(frmClock)
			frmMonthCalendar.Visible = mnuHide.Checked = False
			frmMonthCalendar.ShowCaption = ShowCaption
			frmMonthCalendar.BorderStyle = BorderStyle
			Sender.Checked = True
		End If
	Case "mnuClose"
		If mnuDayCalendar.Checked Then frmDayCalendar.CloseForm
		If mnuMonthCalendar.Checked Then frmMonthCalendar.CloseForm
	Case "mnuAbout"
		MsgBox(!"Visual FB Editor\r\n\r\nChineseCalendar Example\r\nBy Cm Wang", "ChineseCalendar Example")
	Case "mnuExit"
		CloseForm
	End Select
End Sub

Private Sub frmClockType.Form_Create(ByRef Sender As Control)
	If CheckAutoStart() Then mnuAutoStart.Checked = True
	
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
End Sub

Private Sub frmClockType.Form_Destroy(ByRef Sender As Control)
	Shell_NotifyIcon(NIM_DELETE, @SystrayIcon)
End Sub

Private Sub frmClockType.Form_Message(ByRef Sender As Control, ByRef Msg As Message)
	Select Case Msg.Msg
	Case WM_SHELLNOTIFY
		If Msg.lParam = WM_RBUTTONDOWN Then
			Dim tPOINT As Point
			GetCursorPos(@tPOINT)
			SetForegroundWindow(Handle)
			PopupMenu1.Popup(tPOINT.X, tPOINT.Y)
		End If
	End Select
End Sub

Private Sub frmClockType.Form_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	If MouseButton <> 0 Then Exit Sub
	ReleaseCapture()
	SendMessage(Sender.Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0)
End Sub
