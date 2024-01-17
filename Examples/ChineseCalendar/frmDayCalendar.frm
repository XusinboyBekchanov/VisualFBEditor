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
	#include once "mff/Menus.bi"
	
	Using My.Sys.Forms
	
	Type frmDayCalendarType Extends Form
		mDayCal As DayCalendar
		mDispDate As Double     'Display date
		
		Declare Sub Panel1_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub Form_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub mnu_Click(ByRef Sender As MenuItem)
		Declare Constructor
		
		Dim As Panel Panel1
		Dim As PopupMenu PopupMenu1
		Dim As MenuItem mnuBoth, mnuGregorian, mnuLunar
	End Type
	
	Constructor frmDayCalendarType
		' frmDayCalendar
		With This
			.Name = "frmDayCalendar"
			#ifdef __FB_64BIT__
				.Caption = "VFBE DayCalendar64"
			#else
				.Caption = "VFBE DayCalendar32"
			#endif
			.Designer = @This
			.Size = Type<My.Sys.Drawing.Size>(330, 250)
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.OnMouseMove = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Form_MouseMove)
			.Icon = "2"
			.Opacity = 254
			.ContextMenu = @PopupMenu1
			.TransparentColor = mDayCal.mClr(6)
			.SetBounds 0, 0, 330, 250
		End With
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = "Panel1"
			.TabIndex = 0
			.Align = DockStyle.alClient
			.Location = Type<My.Sys.Drawing.Point>(0, 0)
			.Size = Type<My.Sys.Drawing.Size>(334, 261)
			.Enabled = False
			.DoubleBuffered = true
			.SetBounds 0, 0, 314, 211
			.Designer = @This
			.OnPaint = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas), @Panel1_Paint)
			.Parent = @This
		End With
		' PopupMenu1
		With PopupMenu1
			.Name = "PopupMenu1"
			.SetBounds 50, 10, 16, 16
			.Designer = @This
			.Parent = @Panel1
		End With
		' mnuBoth
		With mnuBoth
			.Name = "mnuBoth"
			.Designer = @This
			.Caption = "Both"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuGregorian
		With mnuGregorian
			.Name = "mnuGregorian"
			.Designer = @This
			.Caption = "Gregorian calendar"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuLunar
		With mnuLunar
			.Name = "mnuLunar"
			.Designer = @This
			.Caption = "Lunar calendar"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Parent = @PopupMenu1
		End With
	End Constructor
	
	Dim Shared frmDayCalendar As frmDayCalendarType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmDayCalendar.MainForm = True
		frmDayCalendar.Show
		App.Run
	#endif
'#End Region

Private Sub frmDayCalendarType.Panel1_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	If mDispDate = 0 Then mDispDate = Now
	mDayCal.DrawDayCalendar(Canvas, mDispDate, frmClock.mnuHeight.Checked)
	#ifdef __FB_64BIT__
		Caption = "VFBE DayCalendar64 " & Format(mDispDate, "yyyy/mm/dd")
	#else
		Caption = "VFBE DayCalendar32 " & Format(mDispDate, "yyyy/mm/dd")
	#endif
End Sub

Private Sub frmDayCalendarType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	frmClock.mnuDayCalendar.Checked = False
End Sub

Private Sub frmDayCalendarType.Form_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	If MouseButton <> 0 Then Exit Sub
	#ifdef __USE_WINAPI__
		ReleaseCapture()
		SendMessage(Sender.Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0)
	#endif
End Sub

Private Sub frmDayCalendarType.mnu_Click(ByRef Sender As MenuItem)
	mnuBoth.Checked = False 
	mnuGregorian.Checked = False 
	mnuLunar.Checked = False 
	Select Case Sender.Name
	Case "mnuBoth"
		Sender.Checked = True
		mDayCal.DrawStyle= 0
	Case "mnuGregorian"
		Sender.Checked = True
		mDayCal.DrawStyle= 1
	Case "mnuLunar"
		Sender.Checked = True
		mDayCal.DrawStyle= 2
	End Select
	Panel1.Repaint
End Sub
