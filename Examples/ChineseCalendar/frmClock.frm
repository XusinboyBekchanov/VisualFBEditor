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
	#include once "mff/TimerComponent.bi"
	#include once "string.bi"
	#include once "vbcompat.bi"
	#include once "Calendar.bi"
	#include once "frmCalendar.frm"
	
	Using My.Sys.Forms
	
	Type frmClockType Extends Form
		a As Calendar
		h As Integer
		w As Integer
		Declare Static Sub _TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Sub TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Static Sub _TimerComponent2_Timer(ByRef Sender As TimerComponent)
		Declare Sub TimerComponent2_Timer(ByRef Sender As TimerComponent)
		Declare Static Sub _Form_Create(ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Static Sub _Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Static Sub _Form_DblClick(ByRef Sender As Control)
		Declare Sub Form_DblClick(ByRef Sender As Control)
		Declare Static Sub _Form_Click(ByRef Sender As Control)
		Declare Sub Form_Click(ByRef Sender As Control)
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
			.OnCreate = @_Form_Create
			.BorderStyle = FormBorderStyle.FixedSingle
			.MaximizeBox = False
			.StartPosition = FormStartPosition.CenterScreen
			.Location = Type<My.Sys.Drawing.Point>(0, 0)
			.OnPaint = @_Form_Paint
			.OnDblClick = @_Form_DblClick
			.OnClick = @_Form_Click
			.SetBounds 0, 0, 350, 300
		End With
		' TimerComponent1
		With TimerComponent1
			.Name = "TimerComponent1"
			.Interval = 100
			.Enabled = True
			.SetBounds 60, 90, 16, 16
			.Designer = @This
			.OnTimer = @_TimerComponent1_Timer
			.Parent = @This
		End With
		' TimerComponent2
		With TimerComponent2
			.Name = "TimerComponent2"
			.Interval = 500
			.SetBounds 130, 90, 16, 16
			.Designer = @This
			.OnTimer = @_TimerComponent2_Timer
			.Parent = @This
		End With
	End Constructor
	
	Private Sub frmClockType._Form_Click(ByRef Sender As Control)
		(*Cast(frmClockType Ptr, Sender.Designer)).Form_Click(Sender)
	End Sub
	
	Private Sub frmClockType._Form_DblClick(ByRef Sender As Control)
		(*Cast(frmClockType Ptr, Sender.Designer)).Form_DblClick(Sender)
	End Sub
	
	Private Sub frmClockType._Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		(*Cast(frmClockType Ptr, Sender.Designer)).Form_Paint(Sender, Canvas)
	End Sub
	
	Private Sub frmClockType._Form_Create(ByRef Sender As Control)
		(*Cast(frmClockType Ptr, Sender.Designer)).Form_Create(Sender)
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

Sub TimePrint(frmClk As frmClockType, datetime As Double, ByVal b As Boolean = True, ByVal c As Boolean = False)
	Dim fs As Integer = 72
	frmClk.Canvas.Font.Name = "微软雅黑"
	frmClk.Canvas.Font.Bold = True
	frmClk.Canvas.Font.Size = fs
	
	Dim dt As String = "00:00"
	
	Dim w1 As Integer = frmClk.Canvas.TextWidth(dt)
	Dim h1 As Integer = frmClk.Canvas.TextHeight(dt)
	frmClk.Canvas.Font.Size = fs / 3 + 3
	Dim w2 As Integer = frmClk.Canvas.TextWidth("MW")
	Dim w As Integer = w1 + w2

	Dim h2 As Integer = h1 / 3
	Dim h3 As Integer = h1 / 4
	
	Dim h As Integer = h1 * 2 + h2 + h3 * 2
	
	frmClk.Height = frmClk.h + h
	frmClk.Width = frmClk.w + w

	If c Then frmClk.Canvas.Line 0, 0, w, h, , "F"

	frmClk.Canvas.Pen.Color = &hffc0c0
	frmClk.Canvas.Line 0, 0, w, h1, &hffc0c0 , "F"
	
	frmClk.Canvas.Font.Size = fs
	dt = Format(datetime, "hh")
	frmClk.Canvas.TextOut 0, 0, dt
	dt = Format(datetime, "mm")
	frmClk.Canvas.TextOut w1 - frmClk.Canvas.TextWidth(dt), 0, dt
	Dim p As String = ":"
	If b Then frmClk.Canvas.TextOut (w1 - frmClk.Canvas.TextWidth(p)) / 2, 0, ":"
	
	frmClk.Canvas.Font.Size = fs / 3 + 3
	p = IIf(Hour(datetime) < 12, "AM", "PM")
	frmClk.Canvas.TextOut w1 + (w2 - frmClk.Canvas.TextWidth(p)) / 2 , h1 / 2 - frmClk.Canvas.TextHeight(p) , p
	p = Format(datetime, "ss")
	frmClk.Canvas.TextOut w1 + (w2 - frmClk.Canvas.TextWidth(p)) / 2 , h1 / 2, p
	
	If c = False Then Exit Sub

	fs = 68	 
	frmClk.Canvas.Font.Name = "微软雅黑"
	frmClk.Canvas.Font.Bold = False
	 
	frmClk.a.sInitDate(Year(datetime), Month(datetime), Day(datetime))
	frmClk.Canvas.Pen.Color = &h8040C0
	frmClk.Canvas.Line 0, h1, w, h1 + h2, &h8040C0, "F"
	frmClk.Canvas.Pen.Color = &ha080F0
	frmClk.Canvas.Line 0, h1 + h2, w, h1 + h2 + h3, &ha080F0, "F"
	frmClk.Canvas.Pen.Color = &ha080F0
	frmClk.Canvas.Line 0, h - h3, w, h, &ha080F0, "F"
	
	'年
	frmClk.Canvas.Font.Size = fs / 3
	dt = Format(datetime, "yyyy")
	frmClk.Canvas.TextOut (w / 2 - frmClk.Canvas.TextWidth(dt)) / 2, h1 + (h2 - frmClk.Canvas.TextHeight(dt)) / 2, dt, &hffffff
	dt = frmClk.a.GanZhi(frmClk.a.lYear) & " (" & frmClk.a.YearAttribute(frmClk.a.lYear) & ")"
	frmClk.Canvas.TextOut w / 2 + (w / 2 - frmClk.Canvas.TextWidth(dt)) / 2, h1 + (h2 - frmClk.Canvas.TextHeight(dt)) / 2, dt , &hffffff
	'月
	frmClk.Canvas.Font.Size = fs / 4
	dt = MonthName(Month(datetime))
	frmClk.Canvas.TextOut (w / 2 - frmClk.Canvas.TextWidth(dt)) / 2, h1 + h2 + (h3 - frmClk.Canvas.TextHeight(dt)) / 2, dt, &hffffff
	dt = frmClk.a.MonName(frmClk.a.lMonth) & "月"
	frmClk.Canvas.TextOut w / 2 + (w / 2 - frmClk.Canvas.TextWidth(dt)) / 2, h1 + h2 + (h3 - frmClk.Canvas.TextHeight(dt)) / 2, dt, &hffffff
	'日
	frmClk.Canvas.Font.Size = fs 
	dt = Format(datetime, "d")
	frmClk.Canvas.TextOut (w / 2 - frmClk.Canvas.TextWidth(dt)) / 2, h1 + h2 + h3 + (h1 - frmClk.Canvas.TextHeight(dt)) / 2, dt
	frmClk.Canvas.Font.Size = fs / 5 * 4
	dt = frmClk.a.CDayStr(frmClk.a.lDay)
	frmClk.Canvas.TextOut w / 2 + (w / 2 - frmClk.Canvas.TextWidth(dt)) / 2, h1 + h2 + h3 + (h1 - frmClk.Canvas.TextHeight(dt)) / 2, dt
	'星期
	frmClk.Canvas.Font.Size = fs / 4
	dt = WeekdayName(Weekday(datetime)) & " 第" & DatePart("ww", datetime) & "周"
	frmClk.Canvas.TextOut (w / 2 - frmClk.Canvas.TextWidth(dt)) / 2, h1 * 2 + h2 + h3 + (h3 - frmClk.Canvas.TextHeight(dt)) / 2, dt, &hffffff
	dt = frmClk.a.lHour(datetime)
	frmClk.Canvas.TextOut w / 2 + (w / 2 - frmClk.Canvas.TextWidth(dt)) / 2, h1 * 2 + h2 + h3 + (h3 - frmClk.Canvas.TextHeight(dt)) / 2, dt, &hffffff
End Sub

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
		TimePrint This, Now, True, False
	Else
		TimePrint This, Now, True, True
		sd = dd
	End If
	
	'a.sInitDate(Year(dnow), Month(dnow), Day(dnow))
	'Debug.Clear
	'Debug.Print "农历年：" & a.lYear & "，天干地支，简称干支：" & a.GanZhi(a.lYear) & "，属性：" & a.YearAttribute(a.lYear)
	'Debug.Print "农历月：" & a.lMonth & "，" & a.MonName(a.lMonth) & "月"
	'Debug.Print "农历日：" & a.lDay & "，" & a.CDayStr(a.lDay)
	'Debug.Print "小时：" & Hour(dnow) & "，时辰：" & a.lHour(dnow)
	'Debug.Print "公历节日：" & a.sHoliday
	'Debug.Print "农历节日：" & a.lHoliday
	'Debug.Print "周节日：" & a.wHoliday
	'Debug.Print "星期：" & a.sWeekDayStr
	'Debug.Print a.Constellation(Month(dnow), Day(dnow))
	'Debug.Print a.Constellation2(Month(dnow), Day(dnow))
	'Debug.Print a.Era(Year(dnow))
End Sub

Private Sub frmClockType.TimerComponent2_Timer(ByRef Sender As TimerComponent)
	TimerComponent2.Enabled = False
	TimePrint This, Now, False, False
End Sub

Private Sub frmClockType.Form_Create(ByRef Sender As Control)
	Dim lRT As Rect
	
	'获取控件矩形
	GetClientRect(Handle, @lRT)
	w = Width - lRT.Right + lRT.Left
	h = Height - lRT.Bottom + lRT.Top
End Sub

Private Sub frmClockType.Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	TimePrint This, Now, True, True
End Sub

Private Sub frmClockType.Form_DblClick(ByRef Sender As Control)
	frmCalendar.Show(frmClock)
End Sub

Private Sub frmClockType.Form_Click(ByRef Sender As Control)
	
End Sub
