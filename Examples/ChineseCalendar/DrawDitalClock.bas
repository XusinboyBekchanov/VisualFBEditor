' DrawDitalClock 绘制数字时钟日历
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

#include once "DrawDitalClock.bi"

Destructor DrawDitalClock
	
End Destructor

Constructor DrawDitalClock
	mCanvas = null
	mColon = ":"
	mShowCalendar = True
	ReDim mH(3) As Integer
	ReDim mW(2) As Integer
End Constructor

Private Sub DrawDitalClock.Initial(ByRef Canvas As My.Sys.Drawing.Canvas)
	mCanvas = @Canvas
End Sub

Private Property DrawDitalClock.ShowCalendar() As Boolean
	Return mShowCalendar
End Property

Private Property DrawDitalClock.ShowCalendar(s As Boolean)
	mShowCalendar = s
End Property

Private Property DrawDitalClock.Colon() As String
	Return mColon
End Property

Private Property DrawDitalClock.Colon(s As String)
	mColon = s
End Property

Private Property DrawDitalClock.Width() As Integer
	Return mW(0)
End Property

Private Property DrawDitalClock.Height() As Integer
	If mShowCalendar Then
		Return mH(0)
	Else
		Return mH(1)
	End If
End Property

Private Property DrawDitalClock.FontSize() As Integer
	Return mFontSize
End Property

Private Property DrawDitalClock.FontSize(s As Integer)
	mFontSize = s
	
	If mCanvas = null Then Exit Property
	
	mCanvas->Font.Size = mFontSize
	mCanvas->Font.Name = "微软雅黑"
	mCanvas->Font.Bold = True
	
	mDt = "00" & mColon & "00"
	mW(1) = mCanvas->TextWidth(mDt)
	mH(1) = mCanvas->TextHeight(mDt)
	
	mCanvas->Font.Size = mFontSize / 3
	mW(2) = mCanvas->TextWidth("MW")
	
	mH(2) = mH(1) / 3
	mH(3) = mH(1) / 4
	
	mW(0) = mW(1) + mW(2)
	mH(0) = mH(1) * 2 + mH(2) + mH(3) * 2
End Property

Private Sub DrawDitalClock.PaintClock(ByRef Canvas As My.Sys.Drawing.Canvas, DateTime As Double, ByVal Mark As Integer = -1, ByVal DrawCalendar As Boolean = False)
	Static sMark As Long
	Dim cal As Calendar
	
	If DrawCalendar Then Canvas.Line 0, 0, mW(0), mH(0), , "F"
	
	Canvas.Pen.Color = &hc0c0c0
	Canvas.Line 0, 0, mW(0), mH(1), &hffc0c0 , "F"
	
	Canvas.Font.Name = "微软雅黑"
	Canvas.Font.Bold = True
	Canvas.Font.Size = mFontSize
	mDt = Format(DateTime, "hh")
	Canvas.TextOut 0, 0, mDt
	mDt = Format(DateTime, "mm")
	Canvas.TextOut mW(1) - Canvas.TextWidth(mDt), 0, mDt
	
	If Mark >-1 Then sMark = Mark
	
	If sMark <> 0 Then Canvas.TextOut (mW(1) - Canvas.TextWidth(mColon)) / 2, 0, mColon
	
	Canvas.Font.Size = mFontSize / 3
	mDt = IIf(Hour(DateTime) < 12, "AM", "PM")
	Canvas.TextOut mW(1) + (mW(2) - Canvas.TextWidth(mDt)) / 2 , mH(1) / 2 - Canvas.TextHeight(mDt) , mDt
	mDt = Format(DateTime, "ss")
	Canvas.TextOut mW(1) + (mW(2) - Canvas.TextWidth(mDt)) / 2 , mH(1) / 2, mDt
	
	If mShowCalendar = False Then Exit Sub
	If DrawCalendar = False Then Exit Sub
	
	Canvas.Font.Name = "微软雅黑"
	Canvas.Font.Bold = False
	
	cal.sInitDate(Year(DateTime), Month(DateTime), Day(DateTime))
	Canvas.Pen.Color = &h8040C0
	Canvas.Line 0, mH(1), mW(0), mH(1) + mH(2), &h8040C0, "F"
	Canvas.Pen.Color = &ha080F0
	Canvas.Line 0, mH(1) + mH(2), mW(0), mH(1) + mH(2) + mH(3), &ha080F0, "F"
	Canvas.Pen.Color = &ha080F0
	Canvas.Line 0, mH(0) - mH(3), mW(0), mH(0), &ha080F0, "F"
	
	'年
	Canvas.Font.Size = mFontSize / 3
	mDt = Format(DateTime, "yyyy")
	Canvas.TextOut (mW(0) / 2 - Canvas.TextWidth(mDt)) / 2, mH(1) + (mH(2) - Canvas.TextHeight(mDt)) / 2, mDt, &hffffff
	mDt = cal.GanZhi(cal.lYear) & " (" & cal.YearAttribute(cal.lYear) & ")"
	Canvas.TextOut mW(0) / 2 + (mW(0) / 2 - Canvas.TextWidth(mDt)) / 2, mH(1) + (mH(2) - Canvas.TextHeight(mDt)) / 2, mDt, &hffffff
	'月
	Canvas.Font.Size = mFontSize / 4
	mDt = MonthName(Month(DateTime))
	Canvas.TextOut (mW(0) / 2 - Canvas.TextWidth(mDt)) / 2, mH(1) + mH(2) + (mH(3) - Canvas.TextHeight(mDt)) / 2, mDt ', &hffffff
	mDt = IIf(cal.IsLeap, "闰", "") & cal.MonName(cal.lMonth) & "月"
	Canvas.TextOut mW(0) / 2 + (mW(0) / 2 - Canvas.TextWidth(mDt)) / 2, mH(1) + mH(2) + (mH(3) - Canvas.TextHeight(mDt)) / 2, mDt ', &hffffff
	'日
	Dim h1 As Integer = 0
	Dim h2 As Integer = 0
	Dim Dt As String
	Canvas.Font.Bold = True
	mDt = Format(DateTime, "d")
	Dt = cal.sHoliday & cal.wHoliday
	If Dt <> "" Then
		Canvas.Font.Size = mFontSize / 4
		h1 = Canvas.TextHeight(Dt)
		Canvas.Font.Size = mFontSize
		h2 = Canvas.TextHeight(mDt)
		Canvas.TextOut (mW(0) / 2 - Canvas.TextWidth(mDt)) / 2, mH(1) + mH(2) + mH(3) + (mH(1) - (h1 + h2)) / 2, mDt
		Canvas.Font.Size = mFontSize / 4
		Canvas.TextOut (mW(0) / 2 - Canvas.TextWidth(Dt)) / 2, mH(1) + mH(2) + mH(3) + mH(1) - h1, Dt, &h808080
	Else
		Canvas.Font.Size = mFontSize / 2 * 3
		Canvas.TextOut (mW(0) / 2 - Canvas.TextWidth(mDt)) / 2, mH(1) + mH(2) + mH(3) + (mH(1) - Canvas.TextHeight(mDt)) / 2, mDt
	End If
	
	Dt = cal.lSolarTerm & cal.lHoliday
	mDt = cal.CDayStr(cal.lDay)
	If Dt <> "" Then
		Canvas.Font.Size = mFontSize / 4
		h1 = Canvas.TextHeight(Dt)
		Canvas.Font.Size = mFontSize / 7 * 5
		h2 = Canvas.TextHeight(mDt)
		Canvas.TextOut mW(0) / 2 + (mW(0) / 2 - Canvas.TextWidth(mDt)) / 2, mH(1) + mH(2) + mH(3) + (mH(1) - (h1 + h2)) / 2, mDt
		Canvas.Font.Size = mFontSize / 4
		Canvas.TextOut mW(0) / 2 + (mW(0) / 2 - Canvas.TextWidth(mDt)) / 2, mH(1) + mH(2) + mH(3) + mH(1) - h1, Dt, &h808080
	Else
		Canvas.Font.Size = mFontSize / 7 * 6
		mDt = cal.CDayStr(cal.lDay)
		Canvas.TextOut mW(0) / 2 + (mW(0) / 2 - Canvas.TextWidth(mDt)) / 2, mH(1) + mH(2) + mH(3) + (mH(1) - Canvas.TextHeight(mDt)) / 2, mDt
	End If
	'星期
	Canvas.Font.Bold = False
	Canvas.Font.Size = mFontSize / 4
	mDt = WeekdayName(Weekday(DateTime))
	Canvas.TextOut (mW(0) / 2 - Canvas.TextWidth(mDt)) / 2, mH(1) * 2 + mH(2) + mH(3) + (mH(3) - Canvas.TextHeight(mDt)) / 2, mDt ', &hffffff
	mDt = "第 " & DatePart("ww", DateTime) & " 周"
	Canvas.TextOut mW(0) / 2 + (mW(0) / 2 - Canvas.TextWidth(mDt)) / 2, mH(1) * 2 + mH(2) + mH(3) + (mH(3) - Canvas.TextHeight(mDt)) / 2, mDt ', &hffffff
End Sub

Destructor DrawCalendar
End Destructor

Constructor DrawCalendar
	mFontSize= 10
End Constructor

Private Sub DrawCalendar.PaintCalendar(ByRef Canvas As My.Sys.Drawing.Canvas, DateTime As Double)
	mDateTime = DateTime
	mWidth = Canvas.Width
	mFontSize= mWidth \ 30
	mHeight = Canvas.Height
	'当月第一天
	mDayStart = DateSerial(Year(DateTime), Month(DateTime), 1)
	'当月天数
	mDayCount = DateDiff("d", mDayStart, DateAdd("m", 1, mDayStart))
	'当天
	mDay = Day(DateTime)
	'当月第一天星期几 (星期日为每周第一天)
	mWeekStart = Weekday(mDayStart) - 2
	'行数
	mLineCount = (mWeekStart + mDayCount) \ 7 + 2
	'格子宽
	mCellWidth = mWidth / 7
	'格子高
	mCellHeight = mHeight / mLineCount
	
	Dim i As Integer
	Dim x As Integer
	Dim y As Integer
	Dim c As Integer
	Dim n As Double
	Dim m As Integer
	
	'文字
	Dim dt As String
	'文字颜色
	Dim cr As Integer
	
	Canvas.Pen.Color = &h8080ff
	Canvas.Line 0, 0, mWidth, mHeight, , "F"
	
	Canvas.Font.Name= "微软雅黑"
	Canvas.Font.Bold = True
	Canvas.Font.Size = mFontSize
	
	'绘制日历星期抬头
	For i = 0 To 6
		If i = 0 Or i = 6 Then cr = &h000080 Else cr = &h404040
		dt = cal.WeekNameS(i + 1)
		Canvas.TextOut(i * mCellWidth + (mCellWidth - Canvas.TextWidth(dt)) / 2, (mCellHeight - Canvas.TextHeight(dt)) / 2, dt, cr)
	Next
	
	'绘制日期和农历
	n = DateSerial(Year(Now), Month(Now), Day(Now))
	Dim yy As Integer = Year(DateTime)
	Dim mm As Integer = Month(DateTime)
	For i = 1 To mDayCount
		c = mWeekStart + i
		x = (c Mod 7)
		y = c \ 7+2
		If i = mDay Then
			Canvas.Pen.Color = &h4040ff
			Canvas.Line x * mCellWidth, (y - 1) * mCellHeight, x * mCellWidth + mCellWidth, y * mCellHeight , &h8080ff , "F"
		End If
		dt = Format(i)
		Canvas.Font.Name= "Arial"
		Canvas.Font.Size = mFontSize
		Canvas.Font.Bold = True
		If n = DateSerial(yy, mm, i) Then m = True Else m = False
		If m Then
			cr = &hFF0000
		Else
			If x = 0 Or x = 6 Then cr = &h000080 Else cr = &h0
		End If
		Canvas.TextOut(x * mCellWidth + (mCellWidth - Canvas.TextWidth(dt)) / 2, y * mCellHeight - mCellHeight / 2 - Canvas.TextHeight(dt), dt, cr)
		cal.sInitDate(yy, mm, i)
		dt = cal.lHoliday & cal.lSolarTerm
		If cal.CDayStr(cal.lDay) = "初一" Then
			dt = IIf(cal.IsLeap, "闰", "") & cal.MonName(cal.lMonth) & "月" & IIf(dt = "", "", "("  & dt & ")")
		End If
		If dt = "" Then dt = cal.CDayStr(cal.lDay)
		Canvas.Font.Name= "微软雅黑"
		Canvas.Font.Size = mFontSize / 10 * 8
		Canvas.Font.Bold = False
		If m Then
			cr = &hFF4040
		Else
			If x = 0 Or x = 6 Then cr = &h404080 Else cr = &h404040
		End If
		Canvas.TextOut(x * mCellWidth + (mCellWidth - Canvas.TextWidth(dt)) / 2, y * mCellHeight - mCellHeight / 2, dt, cr)
	Next
End Sub

Private Function DrawCalendar.XY2Date(x As Integer, y As Integer) As Double
	Dim x1 As Integer = x \ mCellWidth
	Dim y1 As Integer = y \ mCellHeight
	
	Dim dif As Integer = y1 * 7 + x1 - mWeekStart - 8
	Return DateAdd("d", dif, mDayStart)
End Function
