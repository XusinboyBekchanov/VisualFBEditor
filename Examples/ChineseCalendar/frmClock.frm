' Chinese Calendar 中国日历
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		Const _MAIN_FILE_ = __FILE__
		#ifdef __FB_WIN32__
			#cmdline "Clock.rc"
		#endif
	#endif
	#include once "mff/Form.bi"
	#include once "mff/Panel.bi"
	#include once "mff/TimerComponent.bi"
	#include once "mff/Picture.bi"
	
	#include once "string.bi"
	#include once "vbcompat.bi"
	
	#include once "LunarCalendar.bi"
	#include once "DrawClockCalendar.bi"
	
	#include once "frmDayCalendar.frm"
	#include once "frmMonthCalendar.frm"
	
	Using My.Sys.Forms
	
	Type frmClockType Extends Form
		DClock As DitalClock
		
		Declare Static Sub _TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Sub TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Static Sub _TimerComponent2_Timer(ByRef Sender As TimerComponent)
		Declare Sub TimerComponent2_Timer(ByRef Sender As TimerComponent)
		Declare Static Sub _Form_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub Form_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Static Sub _Picture1_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub Picture1_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Constructor
		
		Dim As TimerComponent TimerComponent1, TimerComponent2
		Dim As Panel Picture1
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
			.MaximizeBox = False
			.StartPosition = FormStartPosition.CenterScreen
			.Location = Type<My.Sys.Drawing.Point>(0, 0)
			.OnMouseUp = @_Form_MouseUp
			.Size = Type<My.Sys.Drawing.Size>(330, 130)
			.SetBounds 0, 0, 330, 140
		End With
		' TimerComponent1
		With TimerComponent1
			.Name = "TimerComponent1"
			.Interval = 20
			.Enabled = True
			.SetBounds 10, 10, 16, 16
			.Designer = @This
			.OnTimer = @_TimerComponent1_Timer
			.Parent = @This
		End With
		' TimerComponent2
		With TimerComponent2
			.Name = "TimerComponent2"
			.Interval = 500
			.SetBounds 40, 10, 16, 16
			.Designer = @This
			.OnTimer = @_TimerComponent2_Timer
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
			.DoubleBuffered = True
			.SetBounds 65250, 0, 224, 91
			.Designer = @This
			.OnPaint = @_Picture1_Paint
			.Parent = @This
		End With
	End Constructor
	
	Private Sub frmClockType._Picture1_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		(*Cast(frmClockType Ptr, Sender.Designer)).Picture1_Paint(Sender, Canvas)
	End Sub
	
	Private Sub frmClockType._Form_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		(*Cast(frmClockType Ptr, Sender.Designer)).Form_MouseUp(Sender, MouseButton, x, y, Shift)
	End Sub
	
	Private Sub frmClockType._TimerComponent2_Timer(ByRef Sender As TimerComponent)
		(*Cast(frmClockType Ptr, Sender.Designer)).TimerComponent2_Timer(Sender)
	End Sub
	
	Private Sub frmClockType._TimerComponent1_Timer(ByRef Sender As TimerComponent)
		(*Cast(frmClockType Ptr, Sender.Designer)).TimerComponent1_Timer(Sender)
	End Sub
	
	Dim Shared frmClock As frmClockType
	
	#if _MAIN_FILE_ = __FILE__
		frmClock.MainForm = True
		frmClock.Show
		App.Run
	#endif
'#End Region

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

Private Sub frmClockType.Form_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	Select Case MouseButton
	Case 0 'left
		frmDayCalendar.Show(frmClock)
	Case 1 'right
		frmMonthCalendar.Show(frmClock)
	Case 2 'middle
	End Select
End Sub

Private Sub frmClockType.Picture1_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	DClock.DrawClock Canvas, Now, -1
End Sub
