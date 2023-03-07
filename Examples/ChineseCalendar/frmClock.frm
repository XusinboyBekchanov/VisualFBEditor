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
	
	#include once "string.bi"
	#include once "vbcompat.bi"
	#include once "Calendar.bi"
	
	#include once "DrawDitalClock.bi"
	#include once "frmCalendar.frm"
	
	Using My.Sys.Forms
	
	Type frmClockType Extends Form
		DrawNC As DrawDitalClock
		
		Declare Static Sub _TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Sub TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Static Sub _TimerComponent2_Timer(ByRef Sender As TimerComponent)
		Declare Sub TimerComponent2_Timer(ByRef Sender As TimerComponent)
		Declare Static Sub _Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Static Sub _Form_DblClick(ByRef Sender As Control)
		Declare Sub Form_DblClick(ByRef Sender As Control)
		Declare Static Sub _Form_Create(ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Static Sub _Form_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub Form_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Static Sub _Form_MouseWheel(ByRef Sender As Control, Direction As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub Form_MouseWheel(ByRef Sender As Control, Direction As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Constructor
		
		Dim As TimerComponent TimerComponent1, TimerComponent2
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
				.Caption = "VFBE Clock 64"
			#else
				.Caption = "VFBE Clock 32"
			#endif
			.Designer = @This
			.Font.Name = "Consolas"
			.Font.Size = 12
			.Font.Bold = True
			.BorderStyle = FormBorderStyle.FixedSingle
			.MaximizeBox = False
			.StartPosition = FormStartPosition.CenterScreen
			.Location = Type<My.Sys.Drawing.Point>(0, 0)
			.OnPaint = @_Form_Paint
			.OnDblClick = @_Form_DblClick
			.OnCreate = @_Form_Create
			.OnMouseUp = @_Form_MouseUp
			.OnMouseWheel = @_Form_MouseWheel
			.SetBounds 0, 0, 350, 300
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
	End Constructor
	
	Private Sub frmClockType._Form_MouseWheel(ByRef Sender As Control, Direction As Integer, x As Integer, y As Integer, Shift As Integer)
		(*Cast(frmClockType Ptr, Sender.Designer)).Form_MouseWheel(Sender, Direction, x, y, Shift)
	End Sub
	
	Private Sub frmClockType._Form_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		(*Cast(frmClockType Ptr, Sender.Designer)).Form_MouseUp(Sender, MouseButton, x, y, Shift)
	End Sub
	
	Private Sub frmClockType._Form_Create(ByRef Sender As Control)
		(*Cast(frmClockType Ptr, Sender.Designer)).Form_Create(Sender)
	End Sub
	
	Private Sub frmClockType._Form_DblClick(ByRef Sender As Control)
		(*Cast(frmClockType Ptr, Sender.Designer)).Form_DblClick(Sender)
	End Sub
	
	Private Sub frmClockType._Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		(*Cast(frmClockType Ptr, Sender.Designer)).Form_Paint(Sender, Canvas)
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
	Static sd As String
	Dim dnow As Double= Now()
	Dim dt As String = Format(dnow, "hh:mm:ss")
	If st = dt Then Exit Sub
	st = dt
	TimerComponent2.Enabled = False
	TimerComponent2.Enabled = True
	
	Dim dd As String = Format(dnow, "yyyy/mm/dd")
	If sd = dd Then
		DrawNC.PaintClock Canvas, Now, 1, False
	Else
		DrawNC.PaintClock Canvas, Now, 1, True
		sd = dd
	End If
End Sub

Private Sub frmClockType.TimerComponent2_Timer(ByRef Sender As TimerComponent)
	TimerComponent2.Enabled = False
	DrawNC.PaintClock Canvas, Now, 0, False
End Sub

Private Sub frmClockType.Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	DrawNC.PaintClock Canvas, Now, -1, True
End Sub

Private Sub frmClockType.Form_DblClick(ByRef Sender As Control)
	frmCalendar.Show(frmClock)
End Sub

Private Sub frmClockType.Form_Create(ByRef Sender As Control)
	DrawNC.Initial Canvas
	DrawNC.FontSize = 48
	'Width = DrawNC.Width : Height = DrawNC.Height + ScaleY(10)
	Move Left, Top, Width - ClientWidth + DrawNC.Width, Height - ClientHeight + DrawNC.Height
	Form_MouseUp Sender, 0, 0, 0, 0
End Sub

Private Sub frmClockType.Form_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	Select Case MouseButton
	Case 0 'left
	Case 1 'right
		If DrawNC.ShowCalendar Then
			DrawNC.ShowCalendar = False
		Else
			DrawNC.ShowCalendar = True
		End If
	Case 2 'middle
	End Select
	'获取控件矩形
	'Dim lRT As Rect
	'GetClientRect(Handle, @lRT)
	'设置窗口大小
	'Height = Height - lRT.Bottom + lRT.Top + DrawNC.Height
	'Width = Width - lRT.Right + lRT.Left + DrawNC.Width
	'DrawNC.PaintClock Canvas, Now, -1, True
End Sub

Private Sub frmClockType.Form_MouseWheel(ByRef Sender As Control, Direction As Integer, x As Integer, y As Integer, Shift As Integer)
	Select Case Direction
	Case -1
		If DrawNC.FontSize > 40 Then DrawNC.FontSize = DrawNC.FontSize - 2
	Case 1
		If DrawNC.FontSize < 200 Then DrawNC.FontSize = DrawNC.FontSize + 2
	End Select
	'获取控件矩形
	'Dim lRT As Rect
	'GetClientRect(Handle, @lRT)
	'设置窗口大小
	'Height = Height - lRT.Bottom + lRT.Top + DrawNC.Height
	'	Width = Width - lRT.Right + lRT.Left + DrawNC.Width
	DrawNC.PaintClock Canvas, Now, -1, True
	'Width = DrawNC.Width : Height = DrawNC.Height + ScaleY(10)
	Move Left, Top, Width - ClientWidth + DrawNC.Width, Height - ClientHeight + DrawNC.Height
End Sub
