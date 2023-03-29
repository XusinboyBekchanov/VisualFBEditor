' DrawClockCalendar 绘制时钟日历
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

#include once "DrawClockCalendar.bi"

Destructor DitalClock
	
End Destructor

Constructor DitalClock
	mColon = ":"
	FontNameE = "Arial"
	FontNameC = "微软雅黑"
	
	'调颜色
	mClr(0) = vbRGB(mC(7), mC(6), mC(8)) 'backcolor_clock
	mClr(1) = vbRGB(mC(0), mC(0), mC(0)) 'forecolor_hour
	mClr(2) = vbRGB(mC(0), mC(0), mC(0)) 'forecolor_minute
	mClr(3) = vbRGB(mC(0), mC(0), mC(0)) 'backcolor_colon
	mClr(4) = vbRGB(mC(0), mC(0), mC(0)) 'backcolor_ampm
	mClr(5) = vbRGB(mC(0), mC(0), mC(0)) 'forecolor_sec
End Constructor

Private Property DitalClock.Colon() As String
	Return mColon
End Property

Private Property DitalClock.Colon(s As String)
	mColon = s
End Property

Private Property DitalClock.Width() As Integer
	Return mW(0)
End Property

Private Property DitalClock.Height() As Integer
	Return mH(0)
End Property

Private Function DitalClock.FontSize() As Integer
	Return mFontSize
End Function

Private Sub DitalClock.CalculateSize(Canvas As My.Sys.Drawing.Canvas)
	mFontSize = Canvas.Height / 1.5
	Canvas.Font.Size = mFontSize
	Canvas.Font.Name = FontNameE
	Canvas.Font.Bold = True
	
	mDt = "00" & mColon & "00"
	mH(0) = Canvas.TextHeight(mDt)
	
	mW(1) = Canvas.TextWidth(mDt)
	Canvas.Font.Size = mFontSize / 3
	mW(2) = Canvas.TextWidth(" MW")
	mW(0) = mW(1) + mW(2)
	
	mOx = (Canvas.Width - mW(0)) / 2
	mOy = (Canvas.Height - mH(0)) / 2
End Sub

Private Sub DitalClock.DrawClock(ByRef Canvas As My.Sys.Drawing.Canvas, DateTime As Double, ByVal Mark As Integer = -1)
	Static sMark As Long
	Dim cal As LunarCalendar
	
	CalculateSize(Canvas)
	
	'时钟区域
	Canvas.Pen.Color = mClr(0)
	Canvas.Line 0, 0, Canvas.Width, Canvas.Height, mClr(0) , "F"
	'Canvas.Line mOx, mOy, mOx + mW(0), mOy + mH(0), mClr(0) , "F"
	
	Canvas.Font.Name = FontNameE
	Canvas.Font.Bold = True
	Canvas.Font.Size = mFontSize
	
	'时
	mDt = Format(DateTime, "hh")
	Canvas.TextOut mOx, mOy, mDt, mClr(1)
	'分
	mDt = Format(DateTime, "mm")
	Canvas.TextOut mOx + mW(1) - Canvas.TextWidth(mDt), mOy, mDt, mClr(2)
	'冒号(-1保持, 0不绘, 1绘制)
	If Mark >-1 Then sMark = Mark
	If sMark <> 0 Then Canvas.TextOut mOx + (mW(1) - Canvas.TextWidth(mColon)) / 2, mOy, mColon, mClr(3)
	'上下午
	Canvas.Font.Size = mFontSize * 3 / 8
	mDt = IIf(Hour(DateTime) < 12, "AM", "PM")
	Canvas.TextOut mOx + mW(1) + (mW(2) - Canvas.TextWidth(mDt)) / 2 , mOy + mH(0) / 2 - Canvas.TextHeight(mDt) , mDt, mClr(4)
	'秒
	mDt = Format(DateTime, "ss")
	Canvas.TextOut mOx + mW(1) + (mW(2) - Canvas.TextWidth(mDt)) / 2 , mOy + mH(0) / 2, mDt, mClr(5)
End Sub

'############################################################

Destructor DayCalendar
	
End Destructor

Constructor DayCalendar
	mColon = ":"
	mShowCalendar = False
	FontNameE = "Arial"
	FontNameC = "微软雅黑"
	
	'调颜色
	mClr(0) = vbRGB(mC(7), mC(6), mC(8)) 'backcolor_clock
	mClr(1) = vbRGB(mC(0), mC(0), mC(0)) 'forecolor_clock
	mClr(2) = vbRGB(mC(6), mC(2), mC(4)) 'backcolor_year
	mClr(3) = vbRGB(mC(8), mC(8), mC(8)) 'forecolor_year
	mClr(4) = vbRGB(mC(8), mC(6), mC(7)) 'backcolor_month
	mClr(5) = vbRGB(mC(0), mC(0), mC(0)) 'forecolor_month
	mClr(6) = vbRGB(mC(8), mC(8), mC(8)) 'backcolor_day
	mClr(7) = vbRGB(mC(0), mC(0), mC(0)) 'forecolor_day
	mClr(8) = vbRGB(mC(8), mC(6), mC(7)) 'backcolor_week
	mClr(9) = vbRGB(mC(0), mC(0), mC(0)) 'forecolor_week
	mClr(10) = vbRGB(mC(7), mC(6), mC(8)) 'forecolor_middle
End Constructor

Private Property DayCalendar.Width() As Integer
	Return mW(0)
End Property

Private Property DayCalendar.Height() As Integer
	If mShowCalendar Then
		Return mH(0)
	Else
		Return mH(1)
	End If
End Property

Private Function DayCalendar.FontSize() As Integer
	Return mFontSize
End Function

Private Sub DayCalendar.CalculateSize(Canvas As My.Sys.Drawing.Canvas)
	mFontSize = Canvas.Height / 3
	
	Canvas.Font.Size = mFontSize
	Canvas.Font.Name = FontNameE
	Canvas.Font.Bold = True
	
	mDt = "00" & mColon & "00"
	mH(0) = Canvas.Height
	mH(1) = Canvas.TextHeight(mDt)
	mH(2) = mH(1) * 0.4
	mH(3) = mH(1) * 0.3
	mH(1) = mH(0) - mH(2) - mH(3) * 2 'Canvas.TextHeight(mDt)
	
	mW(0) = Canvas.Width
End Sub

Private Sub DayCalendar.DrawDayCalendar(ByRef Canvas As My.Sys.Drawing.Canvas, DateTime As Double)
	Dim cal As LunarCalendar
	
	CalculateSize(Canvas)
	
	cal.sInitDate(Year(DateTime), Month(DateTime), Day(DateTime))
	
	'年区域
	Canvas.Pen.Color = mClr(2)
	Canvas.Line 0, 0, mW(0), mH(2), mClr(2), "F"
	'月区域
	Canvas.Pen.Color = mClr(4)
	Canvas.Line 0, mH(2), mW(0), mH(2) + mH(3), mClr(4), "F"
	'日区域
	Canvas.Pen.Color = mClr(6)
	Canvas.Line 0, mH(2) + mH(3), mW(0), mH(0) - mH(3), mClr(6), "F"
	'周区域
	Canvas.Pen.Color = mClr(8)
	Canvas.Line 0, mH(0) - mH(3), mW(0), mH(0), mClr(8), "F"
	
	'日期区域线
	Canvas.Pen.Color = mClr(10)
	Canvas.Line mW(0) / 2 - 1 , 0, mW(0) / 2 + 1, mH(0), mClr(0), "F"
	
	'年
	Canvas.Font.Name = FontNameE
	Canvas.Font.Bold = True
	Canvas.Font.Size = mFontSize / 3
	mDt = Format(DateTime, "yyyy")
	Canvas.TextOut (mW(0) / 2 - Canvas.TextWidth(mDt)) / 2, (mH(2) - Canvas.TextHeight(mDt)) / 2, mDt, mClr(3)
	Canvas.Font.Name = FontNameC
	mDt = cal.GanZhi(cal.lYear) & " (" & cal.YearAttribute(cal.lYear) & ")"
	Canvas.TextOut mW(0) / 2 + (mW(0) / 2 - Canvas.TextWidth(mDt)) / 2, (mH(2) - Canvas.TextHeight(mDt)) / 2, mDt, mClr(3)
	'月
	Canvas.Font.Size = mFontSize / 4
	mDt = cal.MonName(Month(DateTime))
	Canvas.TextOut (mW(0) / 2 - Canvas.TextWidth(mDt)) / 2, mH(2) + (mH(3) - Canvas.TextHeight(mDt)) / 2, mDt, mClr(5)
	mDt = IIf(cal.IsLeap, "闰", "") & cal.MonName(cal.lMonth) & "月"
	Canvas.TextOut mW(0) / 2 + (mW(0) / 2 - Canvas.TextWidth(mDt)) / 2, mH(2) + (mH(3) - Canvas.TextHeight(mDt)) / 2, mDt, mClr(5)
	
	'公历日
	Dim h1 As Integer = 0
	Dim h2 As Integer = 0
	Dim Dt As UString
	
	Canvas.Font.Bold = True
	Canvas.Font.Name = FontNameC
	mDt = Format(DateTime, "d")
	Canvas.Font.Size = mFontSize / 4
	h1 = Canvas.TextHeight(mDt)
	
	Canvas.Font.Name = FontNameE
	Dt = cal.sHoliday & cal.wHoliday
	If Dt <> "" Then
		'公历节日
		Canvas.Font.Size = mFontSize
		h2 = Canvas.TextHeight(mDt)
		Canvas.TextOut (mW(0) / 2 - Canvas.TextWidth(mDt)) / 2, mH(2) + mH(3) + (mH(1) - (h1 + h2)) / 2, mDt, mClr(7)
		Canvas.Font.Bold = False
		Canvas.Font.Name = FontNameC
		Canvas.Font.Size = mFontSize / 4
		Canvas.TextOut (mW(0) / 2 - Canvas.TextWidth(Dt)) / 2, mH(0) -  mH(3) * 2, Dt, mClr(2)
	Else
		Canvas.Font.Size = mFontSize / 3 * 4
		Canvas.TextOut (mW(0) / 2 - Canvas.TextWidth(mDt)) / 2, mH(2) + mH(3) + (mH(0) - mH(2) - mH(3) * 2 - Canvas.TextHeight(mDt)) / 2, mDt, mClr(7)
	End If
	
	'农历日
	Canvas.Font.Bold = True
	Canvas.Font.Name = FontNameC
	Dt = cal.lSolarTerm & cal.lHoliday
	mDt = cal.CDayStr(cal.lDay)
	If Dt <> "" Then
		'农历节日
		Canvas.Font.Size = mFontSize / 5 * 3
		h2 = Canvas.TextHeight(mDt)
		Canvas.TextOut mW(0) / 2 + (mW(0) / 2 - Canvas.TextWidth(mDt)) / 2, mH(2) + mH(3) + (mH(1) - (h1 + h2)) / 2, mDt, mClr(7)
		Canvas.Font.Bold = False
		Canvas.Font.Size = mFontSize / 4
		Canvas.TextOut mW(0) / 2 + (mW(0) / 2 - Canvas.TextWidth(mDt)) / 2, mH(0) -  mH(3) * 2, Dt, mClr(2)
	Else
		Canvas.Font.Size = mFontSize / 4 * 3
		mDt = cal.CDayStr(cal.lDay)
		Canvas.TextOut mW(0) / 2 + (mW(0) / 2 - Canvas.TextWidth(mDt)) / 2, mH(2) + mH(3) + (mH(0) - mH(2) - mH(3) * 2 - Canvas.TextHeight(mDt)) / 2, mDt, mClr(7)
	End If
	'星期
	Canvas.Font.Bold = False
	Canvas.Font.Name = FontNameC
	Canvas.Font.Size = mFontSize / 4
	mDt = cal.WeekName(Weekday(DateTime))
	Canvas.TextOut (mW(0) / 2 - Canvas.TextWidth(mDt)) / 2, mH(0) - mH(3)+ (mH(3) - Canvas.TextHeight(mDt)) / 2, mDt, mClr(9)
	mDt = "第 " & DatePart("ww", DateTime) & " 周"
	Canvas.TextOut mW(0) / 2 + (mW(0) / 2 - Canvas.TextWidth(mDt)) / 2, mH(0) - mH(3) + (mH(3) - Canvas.TextHeight(mDt)) / 2, mDt, mClr(9)
End Sub

'############################################################

Destructor MonthCalendar
End Destructor

Constructor MonthCalendar
	mFontSize = 10
	FontNameE = "Arial"
	FontNameC = "微软雅黑"
	
	'调颜色
	mClr(0) = vbRGB(mC(7), mC(6), mC(8)) 'backcolor_title
	mClr(2) = vbRGB(mC(0), mC(0), mC(0)) 'forecolor_title
	mClr(3) = vbRGB(mC(4), mC(0), mC(0)) 'forecolor_titleweekend
	mClr(4) = vbRGB(mC(8), mC(8), mC(8)) 'backcolor_day
	mClr(5) = vbRGB(mC(0), mC(0), mC(0)) 'forecolor_day
	mClr(6) = vbRGB(mC(4), mC(0), mC(0)) 'forecolor_dayweekend
	mClr(7) = vbRGB(mC(3), mC(3), mC(3)) 'forecolor_dayluner
	mClr(8) = vbRGB(mC(8), mC(3), mC(3)) 'forecolor_daylunerweekend
	mClr(9) = vbRGB(mC(0), mC(0), mC(8)) 'forecolor_daynow
	mClr(10) = vbRGB(mC(3), mC(3), mC(8)) 'forecolor_daylunernow
	mClr(11) = vbRGB(mC(8), mC(6), mC(7)) 'backcolor_dayselect
	mClr(12) = vbRGB(mC(6), mC(2), mC(4)) 'forecolor_dayselect
	mClr(13) = vbRGB(mC(7), mC(7), mC(7)) 'forecolor_daydisable
End Constructor

Private Sub MonthCalendar.DrawMonthCalendar(ByRef Canvas As My.Sys.Drawing.Canvas, DateTime As Double)
	mDateTime= DateTime
	mWidth = Canvas.Width
	mFontSize = mWidth \ 30
	mHeight = Canvas.Height
	'当月第一天
	mDayStart = DateSerial(Year(DateTime), Month(DateTime), 1)
	'当月天数
	mDayCount = DateDiff("d", mDayStart, DateAdd("m", 1, mDayStart))
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
	Dim n As Double = DateSerial(Year(Now), Month(Now), Day(Now))
	Dim m As Integer
	Dim o As Integer = 1
	'文字
	Dim dt As UString
	'文字颜色
	Dim cr As ULong
	
	'星期区域
	Canvas.Pen.Color = mClr(0)
	Canvas.Line 0, 0, mWidth, mCellHeight, mClr(0), "F"
	Canvas.Font.Name= FontNameC
	Canvas.Font.Bold = True
	Canvas.Font.Size = mFontSize
	
	'绘制日历星期抬头
	For i = 0 To 6
		If i = 0 Or i = 6 Then cr = mClr(6) Else cr = mClr(5)
		dt = cal.WeekNameS(i + 1)
		Canvas.TextOut(i * mCellWidth + (mCellWidth - Canvas.TextWidth(dt)) / 2, (mCellHeight - Canvas.TextHeight(dt)) / 2, dt, cr)
	Next
	
	'日期区域
	Canvas.Pen.Color = mClr(4)
	Canvas.Line 0, mCellHeight , mWidth, mHeight, mClr(4) , "F"
	
	'绘制日期和农历
	Dim yy As Integer = Year(DateTime)
	Dim mm As Integer = Month(DateTime)
	Dim dd As Integer = Day(DateTime)
	Dim md As Double
	For i = 1 To (mLineCount - 1) * 7
		md = DateAdd("d", i - mWeekStart - 2, mDayStart)
		yy = Year(md)
		mm = Month(md)
		dd = Day(md)
		x = (i - 1) Mod 7
		y = (i - 1) \ 7 + 2
		dt = "" & dd
		If n = md Then
			cr = mClr(9)
		Else
			If (i > (mWeekStart + 1)) And (i < (mDayCount + mWeekStart + 2)) Then
				If x = 0 Or x = 6 Then cr = mClr(6) Else cr = mClr(5)
			Else
				cr = mClr(13)
			End If
		End If
		If md = DateTime Then
			'选中日期区域
			Canvas.Pen.Color = mClr(12)
			Canvas.Line x * mCellWidth, (y - 1) * mCellHeight, x * mCellWidth + mCellWidth, y * mCellHeight , mClr(11) , "F"
		End If
		Canvas.Font.Name= FontNameE
		Canvas.Font.Size = mFontSize
		Canvas.Font.Bold = True
		Canvas.TextOut(x * mCellWidth + (mCellWidth - Canvas.TextWidth(dt)) / 2, y * mCellHeight - mCellHeight / 2 - Canvas.TextHeight(dt) + o, dt, cr)
		
		cal.sInitDate(yy, mm, dd)
		dt = cal.lHoliday & cal.lSolarTerm
		If cal.CDayStr(cal.lDay) = "初一" Then
			dt = IIf(cal.IsLeap, "闰", "") & cal.MonName(cal.lMonth) & "月" & IIf(dt = "", "", "("  & dt & ")")
		End If
		If dt = "" Then dt = cal.CDayStr(cal.lDay)
		If n = md Then
			cr = mClr(10)
		Else
			If (i > (mWeekStart + 1)) And (i < (mDayCount + mWeekStart + 2)) Then
				If x = 0 Or x = 6 Then cr = mClr(8) Else cr = mClr(7)
			End If
		End If
		Canvas.Font.Name= FontNameC
		Canvas.Font.Size = mFontSize / 10 * 8
		Canvas.Font.Bold = False
		Canvas.TextOut(x * mCellWidth + (mCellWidth - Canvas.TextWidth(dt)) / 2, y * mCellHeight - mCellHeight / 2 - o, dt, cr)
	Next
End Sub

Private Function MonthCalendar.XY2Date(x As Integer, y As Integer) As Double
	Return DateAdd("d", (y \ mCellHeight) * 7 + (x \ mCellWidth) - mWeekStart - 8, mDayStart)
End Function
