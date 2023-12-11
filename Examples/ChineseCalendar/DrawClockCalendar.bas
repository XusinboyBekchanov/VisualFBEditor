' DrawClockCalendar 绘制时钟日历
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

#include once "DrawClockCalendar.bi"

'DitalClock############################################################
Dim Shared As Single fPi, fRad, fDeg
fPi = Acos(-1)
fRad = fPi / 180
fDeg = 180 / fPi
Dim Shared As ULong iShadowColor, iShadowColor2 = &h90000000
iShadowColor = &h20A0A0A0

Destructor DitalClock
	
End Destructor

Constructor DitalClock
	mColon = ":"
	FontNameE = "Arial"
	FontNameClock = "FX-LED"
	FontNameC = "微软雅黑"
	
	'调颜色
	mClr(0) = vbRGB(mC(7), mC(6), mC(8)) 'backcolor_clock
	mClr(1) = vbRGB(mC(0), mC(0), mC(0)) 'forecolor_hour
	mClr(2) = vbRGB(mC(0), mC(0), mC(0)) 'forecolor_minute
	mClr(3) = vbRGB(mC(0), mC(0), mC(0)) 'backcolor_colon
	mClr(4) = vbRGB(mC(0), mC(0), mC(0)) 'backcolor_ampm
	mClr(5) = vbRGB(mC(0), mC(0), mC(0)) 'forecolor_sec
End Constructor

Private Property DitalClock.ShowSecond() As Boolean
	Return mShowSec
End Property

Private Property DitalClock.ShowSecond(b As Boolean)
	mShowSec = b
End Property

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

Private Sub DitalClock.CalculateSize(Canvas As My.Sys.Drawing.Canvas, ByVal byHeight As Boolean = True)
	mDt = "00" & mColon & "00"
	If byHeight Then
		mFontSize = Canvas.Height / 1.38 '时分字体大小
	Else
		mFontSize = Canvas.Width / 4.3     '时分字体大小
	End If
	Canvas.Font.Size = mFontSize
	Canvas.Font.Name = FontNameClock
	Canvas.Font.Bold = True
	
	mH(0) = Canvas.TextHeight(mDt)      '整体高度
	mW(1) = Canvas.TextWidth(mDt)       '时分宽度
	Canvas.Font.Size = mFontSize / 3    '秒字体大小
	mW(2) = Canvas.TextWidth(" MW")     '秒宽度
	If mShowSec Then
		mW(0) = mW(1) + mW(2)           '整体宽度
	Else
		mW(0) = mW(1)                   '整体宽度
	End If
	mOx = (Canvas.Width - mW(0)) / 2    'x偏移
	mOy = (Canvas.Height - mH(0)) / 2   'y偏移
End Sub

Private Sub DitalClock.DrawClockImg(ByRef Canvas As My.Sys.Drawing.Canvas, DateTime As Double, fDiameter As Integer, CenterX As Integer = 0, CenterY As Integer = 0)
	'GdipGraphicsClear(Canvas.GdipGraphics, &h00000000)
	'GdipDrawImageRect(Canvas.GdipGraphics, Canvas.GdipImage, 0, 0, fDiameter, fDiameter)
	mDt = Format(Second(DateTime), "00")
	If Trim(mDS) = "" OrElse mDS <> mDt Then
		mDS = mDt
	Else 
		Exit Sub
	End If
	Dim As UByte iSec = CUByte(Format(Second(DateTime), "00"))
	Dim As UByte iMin = CUByte(Format(Minute(DateTime), "00"))
	'iHr = tTime.wHour + iHr_Delta
	Dim As UByte iHr = CUByte(Format(Hour(DateTime), "00"))
	'Dim As UByte fMSec = CUByte(Format(DateTime-iHr * 3600 - iMin * 60 - iSec, "#0.000"))
	'Debug.Print iHr, iMin, iSec, fMSec 
	Dim As Single Radius = fDiameter / 2 *.37
	'Draw Hour hands
	If iHr > 12 Then iHr -= 12
	Dim As Single hourX = CenterX + (Radius) * Sin((iHr + iHr / 60.0) * 30 * fRad)
	Dim As Single hourY = CenterY - (Radius) * Cos((iHr + iHr / 60.0) * 30 * fRad)
	Canvas.DrawWidth = 1
	Canvas.Circle(CenterX, CenterY, Radius *.05)
	Canvas.DrawWidth = 8
	Canvas.Pen.Color = clBlack
	Canvas.Line(CenterX, CenterY, hourX, hourY)
	
	
	'Draw minute hands
	Dim As Single minuteX = CenterX + (Radius + .05*Radius) * Sin(iMin * 6 * fRad)
	Dim As Single minuteY = CenterY - (Radius + .05*Radius) * Cos(iMin * 6 * fRad)
	Canvas.DrawWidth = 5
	Canvas.Line(CenterX, CenterY, minuteX, minuteY)
		
	'Draw second hands
	Dim As Single secondX = CenterX + (Radius + .15*Radius) * Sin(iSec * 6 * fRad)
	Dim As Single secondY = CenterY - (Radius + .15*Radius) * Cos(iSec * 6 * fRad)
	Canvas.DrawWidth = 3
	Canvas.Pen.Color = clRed
	Canvas.Line(CenterX, CenterY, secondX, secondY)
	
End Sub
Private Sub DitalClock.DrawClock(ByRef Canvas As My.Sys.Drawing.Canvas, DateTime As Double, ByVal byHeight As Boolean = True)
	Dim cal As LunarCalendar
	
	'时钟区域
	'Canvas.Pen.Color = mClr(0)
	'Canvas.Line 0, 0, Canvas.Width, Canvas.Height, mClr(0) , "F"
	CalculateSize(Canvas, byHeight)
	Canvas.Font.Name = FontNameClock
	Canvas.Font.Bold = True
	Canvas.Font.Size = mFontSize
	'时
	mDt = Format(Hour(DateTime), "0")
	If Trim(mDh) = "" OrElse mDh <> mDt Then
		Canvas.TextOut(mOx + Canvas.TextWidth("00") - Canvas.TextWidth(mDt), mOy, mDt, mClr(1))
		mDh = mDt
	End If
	'分
	mDt = Format(Minute(DateTime), "00")
	If Trim(mDm) = "" OrElse mDm <> mDt Then
		Canvas.TextOut(mOx + mW(1) - Canvas.TextWidth(mDt), mOy, mDt, mClr(2))
		mDh = mDt
	End If
	
	'Mark冒号(0不绘, 1绘制)
	If Mark Then Canvas.TextOut(mOx + (mW(1) - Canvas.TextWidth(mColon)) / 2, mOy, mColon, mClr(3))
	
	If mShowSec = False Then Exit Sub
	
	'上下午
	Canvas.Font.Size = mFontSize * 3 / 8
	mDt = IIf(Hour(DateTime) < 12, "AM", "PM")
	'If Trim(mDPM) = "" OrElse mDPM <> mDt Then
	Canvas.TextOut(mOx + mW(1) + (mW(2) - Canvas.TextWidth(mDt)) / 2 , mOy + mH(0) / 2 - Canvas.TextHeight(mDt) , mDt, mClr(4))
	mDPM = mDt
	'End If
	'秒
	mDt = Format(Second(DateTime), "00")
	If Trim(mDS) = "" OrElse mDS <> mDt Then
		Canvas.TextOut(mOx + mW(1) + (mW(2) - Canvas.TextWidth(mDt)) / 2 , mOy + mH(0) / 2, mDt, mClr(5))
		mDS = mDt
	End If
End Sub

'DayCalendar############################################################

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

Private Sub DayCalendar.CalculateSize(Canvas As My.Sys.Drawing.Canvas, ByVal byHeight As Boolean = True)
	If byHeight Then
		mFontSize = Canvas.Height / 3
	Else
		mFontSize = Canvas.Width / 4.5
	End If
	
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

Private Property DayCalendar.DrawStyle() As Integer
	Return mDrawStyle
End Property

Private Property DayCalendar.DrawStyle(val As Integer)
	mDrawStyle= val
End Property

Private Sub DayCalendar.DrawDayCalendar(ByRef Canvas As My.Sys.Drawing.Canvas, ByVal DateTime As Double, ByVal byHeight As Boolean = True)
	Dim cal As LunarCalendar
	Canvas.Font.Name = FontNameE
	CalculateSize(Canvas, byHeight)
	
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
	'周节日区域
	Canvas.Pen.Color = mClr(8)
	Canvas.Line 0, mH(0) - mH(3), mW(0), mH(0), mClr(8), "F"
	
	Dim xOffset As Single = IIf(DrawStyle= 0, mW(0) / 2, mW(0))
	
	Select Case DrawStyle
	Case 0 '公历+农历
		'日期区域线
		Canvas.Pen.Color = mClr(10)
		Canvas.Line xOffset - 1 , 0, xOffset + 1, mH(0), mClr(0), "F"
		
		'年
		Canvas.Font.Name = FontNameE
		Canvas.Font.Bold = True
		Canvas.Font.Size = mFontSize / 2.5
		'公历年
		mDt = Format(Year(DateTime), "0000")
		Canvas.TextOut(xOffset - Canvas.TextWidth(mDt)) / 2, (mH(2) - Canvas.TextHeight(mDt)) / 2, mDt, mClr(3)
		Canvas.Font.Name = FontNameC
		'农历年
		mDt = cal.GanZhi(cal.lYear) & "." & cal.YearAttribute(cal.lYear) & ""
		Canvas.TextOut(xOffset + (xOffset - Canvas.TextWidth(mDt)) / 2, (mH(2) - Canvas.TextHeight(mDt)) / 2, mDt, mClr(3))
		
		'月
		Canvas.Font.Size = mFontSize / 3.5
		'公历月
		mDt = cal.MonthNameCn(Month(DateTime))
		Canvas.TextOut(xOffset - Canvas.TextWidth(mDt)) / 2, mH(2) + (mH(3) - Canvas.TextHeight(mDt)) / 2, mDt, mClr(5)
		'农历月
		mDt = IIf(cal.IsLeap, "闰", "") & cal.MonName(cal.lMonth) & "月"
		Canvas.TextOut(xOffset + (xOffset - Canvas.TextWidth(mDt)) / 2, mH(2) + (mH(3) - Canvas.TextHeight(mDt)) / 2, mDt, mClr(5))
		
		'公历日
		Canvas.Font.Bold = True
		mDt = Format(Day(DateTime), "0")
		Canvas.Font.Name = FontNameE
		Canvas.Font.Size = mFontSize
		Canvas.TextOut(xOffset - Canvas.TextWidth(mDt)) / 2, mH(2) + mH(3) + (mH(0) - mH(2) - mH(3) * 2 - Canvas.TextHeight(mDt)) / 2, mDt, mClr(7)
		
		'农历日
		Canvas.Font.Name = FontNameC
		Canvas.Font.Size = mFontSize / 5 * 3
		mDt = cal.CDayStr(cal.lDay)
		Canvas.TextOut(xOffset + (xOffset - Canvas.TextWidth(mDt)) / 2, mH(2) + mH(3) + (mH(0) - mH(2) - mH(3) * 2 - Canvas.TextHeight(mDt)) / 2, mDt, mClr(7))
		
		'星期
		Canvas.Font.Bold = False
		Canvas.Font.Name = FontNameC
		Canvas.Font.Size = mFontSize / 4.5
		
		'公历节日
		mDt = cal.sHoliday & cal.wHoliday
		If mDt = "" Then mDt = cal.WeekNameCn(Weekday(DateTime))
		Canvas.TextOut(xOffset - Canvas.TextWidth(mDt)) / 2, mH(0) - mH(3) + (mH(3) - Canvas.TextHeight(mDt)) / 2, mDt, mClr(9)
		
		'农历节日
		mDt = cal.lSolarTerm & cal.lHoliday
		If mDt = "" Then mDt = "第 " & DatePart("ww", DateTime) & " 周"
		Canvas.TextOut(xOffset + (xOffset - Canvas.TextWidth(mDt)) / 2, mH(0) - mH(3) + (mH(3) - Canvas.TextHeight(mDt)) / 2, mDt, mClr(9))
	Case 1 '公历
		'年
		Canvas.Font.Name = FontNameE
		Canvas.Font.Bold = True
		Canvas.Font.Size = mFontSize / 2.5
		'公历年
		mDt = Format(Year(DateTime), "0000")
		Canvas.TextOut(xOffset - Canvas.TextWidth(mDt)) / 2, (mH(2) - Canvas.TextHeight(mDt)) / 2, mDt, mClr(3)
		Canvas.Font.Name = FontNameC
		
		'月
		Canvas.Font.Size = mFontSize / 3.5
		'公历月
		mDt = cal.MonthNameCn(Month(DateTime))
		Canvas.TextOut(xOffset - Canvas.TextWidth(mDt)) / 2, mH(2) + (mH(3) - Canvas.TextHeight(mDt)) / 2, mDt, mClr(5)
		
		'公历日
		Canvas.Font.Bold = True
		mDt = Format(Day(DateTime), "0")
		Canvas.Font.Name = FontNameE
		Canvas.Font.Size = mFontSize
		Canvas.TextOut(xOffset - Canvas.TextWidth(mDt)) / 2, mH(2) + mH(3) + (mH(0) - mH(2) - mH(3) * 2 - Canvas.TextHeight(mDt)) / 2, mDt, mClr(7)
		
		'星期
		Canvas.Font.Bold = False
		Canvas.Font.Name = FontNameC
		Canvas.Font.Size = mFontSize / 4.5
		
		'公历节日
		mDt = cal.sHoliday & cal.wHoliday
		If mDt = "" Then mDt = cal.WeekNameCn(Weekday(DateTime))
		Canvas.TextOut(xOffset - Canvas.TextWidth(mDt)) / 2, mH(0) - mH(3) + (mH(3) - Canvas.TextHeight(mDt)) / 2, mDt, mClr(9)
	Case 2 '农历
		'年
		Canvas.Font.Name = FontNameE
		Canvas.Font.Bold = True
		Canvas.Font.Size = mFontSize / 2.5
		'农历年
		mDt = cal.GanZhi(cal.lYear) & "." & cal.YearAttribute(cal.lYear) & ""
		Canvas.TextOut(xOffset - Canvas.TextWidth(mDt)) / 2, (mH(2) - Canvas.TextHeight(mDt)) / 2, mDt, mClr(3)
		
		'月
		Canvas.Font.Size = mFontSize / 3.5
		'农历月
		mDt = IIf(cal.IsLeap, "闰", "") & cal.MonName(cal.lMonth) & "月"
		Canvas.TextOut(xOffset - Canvas.TextWidth(mDt)) / 2, mH(2) + (mH(3) - Canvas.TextHeight(mDt)) / 2, mDt, mClr(5)
		
		'农历日
		Canvas.Font.Name = FontNameC
		Canvas.Font.Size = mFontSize / 5 * 3
		mDt = cal.CDayStr(cal.lDay)
		Canvas.TextOut(xOffset - Canvas.TextWidth(mDt)) / 2, mH(2) + mH(3) + (mH(0) - mH(2) - mH(3) * 2 - Canvas.TextHeight(mDt)) / 2, mDt, mClr(7)
		
		'星期
		Canvas.Font.Bold = False
		Canvas.Font.Name = FontNameC
		Canvas.Font.Size = mFontSize / 4.5
		
		'农历节日
		mDt = cal.lSolarTerm & cal.lHoliday
		If mDt = "" Then mDt = "第 " & DatePart("ww", DateTime) & " 周"
		Canvas.TextOut(xOffset - Canvas.TextWidth(mDt)) / 2, mH(0) - mH(3) + (mH(3) - Canvas.TextHeight(mDt)) / 2, mDt, mClr(9)
	End Select
End Sub

'MonthCalendar############################################################

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
	mClr(14) = vbRGB(mC(3), mC(3), mC(3)) 'forecolor_weeks
End Constructor

Private Sub MonthCalendar.DrawMonthCalendar(ByRef Canvas As My.Sys.Drawing.Canvas, ByVal DateTime As Double, ByVal byHeight As Boolean = True)
	Dim yy As Integer = Year(DateTime)
	Dim mm As Integer = Month(DateTime)
	Dim dd As Integer = Day(DateTime)
	
	mDateTime = DateSerial(yy, mm, dd)
	mWidth = Canvas.Width
	mHeight = Canvas.Height
	If byHeight Then
		mFontSize = mHeight / 21
	Else
		mFontSize = mWidth / 36
	End If
	
	'当月第一天
	mDayStart = DateSerial(yy, mm, 1)
	
	'当月天数
	mDayCount = DateDiff("d", mDayStart, DateAdd("m", 1, mDayStart))
	'当月第一天星期几 (星期日为每周第一天)
	mWeekStart = Weekday(mDayStart) - 2
	'行数
	mLineCount = (mWeekStart + mDayCount) \ 7 + 2
	'格子宽
	mCellWidth = mWidth / IIf(mShowWeeks, 8, 7)
	If mShowWeeks Then
		mWeeksWidth = mCellWidth
	Else
		mWeeksWidth = 0
	End If
	'格子高
	mCellHeight = mHeight / mLineCount
	
	Dim i As Integer
	Dim x As Integer
	Dim y As Integer
	Dim n As Double = DateSerial(Year(Now), Month(Now), Day(Now))
	Dim m As Integer
	Dim o As Integer = 1
	'文字
	Dim dt As String
	'文字颜色
	Dim cr As ULong
	
	'星期区域
	Canvas.Pen.Color = mClr(0)
	Canvas.Line 0, 0, mWidth, mCellHeight, mClr(0), "F"
	
	Canvas.Font.Size = mFontSize
	
	'绘制周次
	If mShowWeeks Then
		cr = mClr(14)
		dt = "周次"
		Canvas.Font.Name = FontNameC
		Canvas.Font.Bold = True
		Canvas.TextOut((mCellWidth - Canvas.TextWidth(dt)) / 2, (mCellHeight - Canvas.TextHeight(dt)) / 2, dt, cr)
		Canvas.Font.Name = FontNameE
		Canvas.Font.Bold = False
		For i = 1 To mLineCount
			dt = "" & DatePart("ww", DateAdd("d", (i - 1) * 7, mDayStart))
			Canvas.TextOut((mCellWidth - Canvas.TextWidth(dt)) / 2, (mCellHeight * i) + (mCellHeight - Canvas.TextHeight(dt)) / 2, dt, cr)
		Next
	End If
	
	Canvas.Font.Name = FontNameC
	Canvas.Font.Bold = True
	'绘制日历星期抬头
	For i = 0 To 6
		If i = 0 Or i = 6 Then cr = mClr(6) Else cr = mClr(5)
		dt = cal.WeekNameS(i + 1)
		Canvas.TextOut(mWeeksWidth + i * mCellWidth + (mCellWidth - Canvas.TextWidth(dt)) / 2, (mCellHeight - Canvas.TextHeight(dt)) / 2, dt, cr)
	Next
	
	'日期区域
	Canvas.Pen.Color = mClr(4)
	Canvas.Line mWeeksWidth, mCellHeight , mWidth, mHeight, mClr(4) , "F"
	
	'绘制日期和农历
	
	Dim md As Double
	For i = 1 To (mLineCount - 1) * 7
		md = DateAdd("d", i - mWeekStart - 2, mDayStart)
		yy = Year(md)
		mm = Month(md)
		dd = Day(md)
		cal.sInitDate(yy, mm, dd)
		
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
		If md = mDateTime Then
			'选中日期区域
			Canvas.Pen.Color = mClr(12)
			Canvas.Line mWeeksWidth + x * mCellWidth, (y - 1) * mCellHeight, mWeeksWidth + x * mCellWidth + mCellWidth, y * mCellHeight , mClr(11) , "F"
		End If
		Canvas.Font.Name= FontNameE
		Canvas.Font.Size = mFontSize
		Canvas.Font.Bold = True
		Canvas.TextOut(mWeeksWidth + x * mCellWidth + (mCellWidth - Canvas.TextWidth(dt)) / 2, y * mCellHeight - mCellHeight / 2 - Canvas.TextHeight(dt) + o, dt, cr)
		
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
		Canvas.TextOut(mWeeksWidth + x * mCellWidth + (mCellWidth - Canvas.TextWidth(dt)) / 2, y * mCellHeight - mCellHeight / 2 - o, dt, cr)
	Next
End Sub

Private Property MonthCalendar.ShowWeeks() As Boolean
	Return mShowWeeks
End Property

Private Property MonthCalendar.ShowWeeks(val As Boolean)
	mShowWeeks = val
End Property

Private Function MonthCalendar.XY2Date(x As Integer, y As Integer) As Double
	Dim x1 As Integer = x - mWeeksWidth
	If y < mCellHeight Or x1 < 0 Then Return mDateTime
	Return DateAdd("d", (y \ mCellHeight) * 7 + (x1 \ mCellWidth) - mWeekStart - 8, mDayStart)
End Function
