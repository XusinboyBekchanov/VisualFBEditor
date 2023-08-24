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
		Declare Sub mnuAlwaysOnTop_Click(ByRef Sender As MenuItem)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Constructor
		
		Dim As TimerComponent TimerComponent1, TimerComponent2
		Dim As Panel Picture1
		Dim As PopupMenu PopupMenu1
		Dim As MenuItem mnuAlwaysOnTop, mnuClickThrough, mnuAutoStart, mnuTransparent, mnuBar1, mnuArrange, mnuDayCalendar, mnuMonthCalendar, mnuBar2, mnuAbout, mnuBar3, mnuExit, mnuClose
	End Type
	
	Constructor frmClockType
		' frmClock
		With This
			.Name = "frmClock"
			.Text = "VFBE Clock 32"
			#ifdef __USE_GTK__
				This.Icon.LoadFromFile(ExePath & ".\clock.ico")
			#else
				This.Icon.LoadFromResourceID(1)
			#endif
			#ifdef __FB_64BIT__
				.Caption = "VFBE Clock64"
			#else
				.Caption = "VFBE Clock32"
			#endif
			.Designer = @This
			.Font.Name = "Consolas"
			.Font.Size = 12
			.Font.Bold = True
			.BorderStyle = FormBorderStyle.Sizable
			.StartPosition = FormStartPosition.CenterScreen
			.Location = Type<My.Sys.Drawing.Point>(0, 0)
			.Size = Type<My.Sys.Drawing.Size>(330, 130)
			.ContextMenu = @PopupMenu1
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.Opacity = 250
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
			.SetBounds 65190, 0, 314, 101
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
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuAlwaysOnTop_Click)
			.Parent = @PopupMenu1
		End With
		' mnuClickThrough
		With mnuClickThrough
			.Name = "mnuClickThrough"
			.Designer = @This
			.Caption = "Click through"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuAlwaysOnTop_Click)
			.Parent = @PopupMenu1
		End With
		' mnuAutoStart
		With mnuAutoStart
			.Name = "mnuAutoStart"
			.Designer = @This
			.Caption = "Auto Start"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuAlwaysOnTop_Click)
			.Parent = @PopupMenu1
		End With
		' mnuTransparent
		With mnuTransparent
			.Name = "mnuTransparent"
			.Designer = @This
			.Caption = "Transparent"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuAlwaysOnTop_Click)
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
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuAlwaysOnTop_Click)
			.Parent = @PopupMenu1
		End With
		' mnuDayCalendar
		With mnuDayCalendar
			.Name = "mnuDayCalendar"
			.Designer = @This
			.Caption = "Day calendar"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuAlwaysOnTop_Click)
			.Parent = @PopupMenu1
		End With
		' mnuMonthCalendar
		With mnuMonthCalendar
			.Name = "mnuMonthCalendar"
			.Designer = @This
			.Caption = "Month calendar"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuAlwaysOnTop_Click)
			.Parent = @PopupMenu1
		End With
		' mnuClose
		With mnuClose
			.Name = "mnuClose"
			.Designer = @This
			.Caption = "Close"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuAlwaysOnTop_Click)
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
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuAlwaysOnTop_Click)
			.Parent = @PopupMenu1
		End With
		' mnuBar3
		With mnuBar3
			.Name = "mnuBar3"
			.Designer = @This
			.Caption = "-"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuAlwaysOnTop_Click)
			.Parent = @PopupMenu1
		End With
		' mnuExit
		With mnuExit
			.Name = "mnuExit"
			.Designer = @This
			.Caption = "Exit"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuAlwaysOnTop_Click)
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
	If lRes <> ERROR_SUCCESS Then Exit Function
	
	lRes = RegQueryValueEx(hReg, WStr("VFBE ChineseCalendar"), 0, @lpType, 0, @lRegLen)
	If lRes <> ERROR_SUCCESS Then Exit Function
	
	sNewRegValue = Reallocate(sNewRegValue, (lRegLen + 1) * 2)
	lRes = RegQueryValueEx(hReg, WStr("VFBE ChineseCalendar"), 0, @lpType, Cast(Byte Ptr, sNewRegValue), @lRegLen)
	If lRes <> ERROR_SUCCESS Then Exit Function
	
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
	TimerComponent2.Enabled = False
	TimerComponent2.Enabled = True
	DClock.DrawClock Picture1.Canvas, dnow, 1
End Sub

Private Sub frmClockType.TimerComponent2_Timer(ByRef Sender As TimerComponent)
	TimerComponent2.Enabled = False
	DClock.DrawClock Picture1.Canvas, Now, 0
End Sub

Private Sub frmClockType.Picture1_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	DClock.DrawClock Canvas, Now, -1
End Sub

Private Sub frmClockType.mnuAlwaysOnTop_Click(ByRef Sender As MenuItem)
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
		frmDayCalendar.Opacity = IIf(Sender.Checked = True, 127, 255)
		frmMonthCalendar.Opacity = IIf(Sender.Checked = True, 127, 255)
	Case "mnuArrange"
		frmDayCalendar.Move Left, Top + Height, Width, Height * 2
		frmMonthCalendar.Move frmDayCalendar.Left, frmDayCalendar.Top + frmDayCalendar.Height, Width, Height * 2
	Case "mnuDayCalendar"
		If Sender.Checked Then
			frmDayCalendar.CloseForm
			Sender.Checked = False
		Else
			frmDayCalendar.Show(frmClock)
			Sender.Checked = True
		End If
	Case "mnuMonthCalendar"
		If Sender.Checked Then
			frmMonthCalendar.CloseForm
			Sender.Checked = False
		Else
			frmMonthCalendar.Show(frmClock)
			Sender.Checked = True
		End If
	Case "mnuClose"
		frmDayCalendar.CloseForm
		frmMonthCalendar.CloseForm
	Case "mnuAbout"
		MsgBox(!"Visual FB Editor\r\n\r\nChineseCalendar Example\r\nBy Cm Wang", "ChineseCalendar Example")
	Case "mnuExit"
		CloseForm
	End Select
End Sub

Private Sub frmClockType.Form_Create(ByRef Sender As Control)
	If CheckAutoStart() Then mnuAutoStart.Checked = True
End Sub
