' Gregorian Calendar Lunar Calendar公历农历
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

#include once "LunarCalendar.bi"

Destructor LunarCalendar
	
End Destructor

Constructor LunarCalendar
	'位操作初使化模块函数 modBit4VB中定义
	Dim i As Integer
	For i = 0 To 30
		BitPower(i) = 2 ^ i
	Next
	BitPower(31) = &H80000000
End Constructor

'位测试 ,测试位为1 返回真
Private Function LunarCalendar.mvarBitTest32(Number As Long, bit As Long) As Boolean
	If bit < 0 Or bit > 31 Then '不是整数位
		Return False
	Else
		If Number And BitPower(bit) Then
			Return True
		Else
			Return False
		End If
	End If
End Function

'计算农历上的节气
Private Property LunarCalendar.lSolarTerm() As UString
	Dim baseDateAndTime As Double
	Dim newdate As Double
	Dim num As Double
	Dim Y As Long
	Dim TempStr As UString
	
	baseDateAndTime = DateValue("1900/1/6") + TimeValue("2:05:00")
	Y = mvarsYear
	TempStr = ""
	
	Dim i As Long
	For i = 1 To 24
		num = 525948.76 * (Y - 1900) + sTermInfo(i - 1)
		newdate = DateAdd("n", num, baseDateAndTime)  '按分钟计算,之所以不按秒钟计算，是因为会溢出
		If Abs(DateDiff("d", newdate, mvarDate)) = 0 Then
			TempStr = SolarTerm(i - 1)
			Exit For
		End If
	Next
	
	lSolarTerm = TempStr
End Property

'计算按第几周星期几计算的节日
Private Property LunarCalendar.wHoliday() As UString
	Dim W As Long
	Dim i As Long
	Dim b As Long
	Dim FirstDay As Double
	Dim TempStr As UString
	TempStr = ""
	b = UBound(wHolidayInfo)
	For i = 0 To b
		If wHolidayInfo(i).Month = mvarsMonth Then  '当月份相当时
			W = Weekday(mvarDate)
			If wHolidayInfo(i).Recess = W Then  '仅当星期几也相等时
				FirstDay = DateValue(mvarsMonth & "/" & 1 & "/" & mvarsYear) '取当月第一天
				If (DateDiff("ww", FirstDay, mvarDate) = wHolidayInfo(i).Day) Then
					TempStr = *wHolidayInfo(i).HolidayName
				End If
			End If
		End If
	Next
	wHoliday = TempStr
End Property

'求农历节日
Private Property LunarCalendar.lHoliday() As UString
	Dim i As Long
	Dim b As Long
	Dim TempStr As UString
	Dim oy As Long
	Dim odate As Double
	Dim ndate As Double
	TempStr = ""
	b = UBound(lHolidayInfo)
	If mvarlMonth = 12 And (mvarlDay = 29 Or mvarlDay = 30) Then
		oy = mvarlYear '保存农历年数
		odate = mvarDate
		ndate = mvarDate + 1
		sInitDate(Year(ndate), Month(ndate), Day(ndate)) '计算第二天的属性
		If oy = mvarlYear - 1 Then '如果农历年数增加了1
			TempStr = "除夕"
			sInitDate(Year(odate), Month(odate), Day(odate)) '恢复到今天原有数据
			
		End If
	Else
		For i = 0 To b
			If (lHolidayInfo(i).Month = mvarlMonth) And _
				(lHolidayInfo(i).Day = mvarlDay) Then
				TempStr = *lHolidayInfo(i).HolidayName
				Exit For
			End If
		Next
	End If
	lHoliday = TempStr
End Property

'求公历节日
Private Property LunarCalendar.sHoliday() As UString
	Dim i As Long
	Dim b As Long
	Dim TempStr As UString
	
	TempStr = ""
	b = UBound(sHolidayInfo)
	For i = 0 To b
		If (sHolidayInfo(i).Month = mvarsMonth) And _
			(sHolidayInfo(i).Day = mvarsDay) Then
			TempStr = *sHolidayInfo(i).HolidayName
			Exit For
		End If
	Next
	sHoliday = TempStr
End Property

Private Property LunarCalendar.sHolidayRecess() As Boolean
	Dim i As Long
	Dim b As Long
	Dim TempStr As Boolean
	
	TempStr = False
	b = UBound(sHolidayInfo)
	For i = 0 To b
		If (sHolidayInfo(i).Month = mvarsMonth) And _
			(sHolidayInfo(i).Day = mvarsDay) Then
			TempStr = sHolidayInfo(i).Recess = 1
			Exit For
		End If
	Next
	sHolidayRecess = TempStr
End Property

'是否是农历的闰月
Private Property LunarCalendar.IsLeap() As Boolean
	IsLeap = mvarIsLeap
End Property

Private Function LunarCalendar.lHour(H As Double) As UString
	lHour = HourName(Hour(H))
End Function

Private Property LunarCalendar.lDay() As Long
	lDay = mvarlDay
End Property

Private Property LunarCalendar.lMonth() As Long
	lMonth = mvarlMonth
End Property

Private Property LunarCalendar.lYear() As Long
	lYear = mvarlYear
End Property

Private Property LunarCalendar.sWeekDay() As Long
	sWeekDay = Weekday(mvarDate)
End Property

'计算星期几中文字串
Private Property LunarCalendar.sWeekDayStr() As UString
	Select Case Weekday(mvarDate)
	Case vbSunday
		sWeekDayStr = "星期日"
	Case vbMonday
		sWeekDayStr = "星期一"
	Case vbTuesday
		sWeekDayStr = "星期二"
	Case vbWednesday
		sWeekDayStr = "星期三"
	Case vbThursday
		sWeekDayStr = "星期四"
	Case vbFriday
		sWeekDayStr = "星期五"
	Case vbSaturday
		sWeekDayStr = "星期六"
	End Select
End Property

Private Function LunarCalendar.Constellation2(m As Long, d As Long) As UString
	Dim tempDate As Double
	Dim ConstellName As UString
	
	tempDate = DateValue("2000/" & m & "/" & d)
	
	Select Case tempDate
	Case DateValue("2000/3/21") To DateValue("2000/4/19")
		ConstellName = "阳性、火象星座，守护行星：火星"
	Case DateValue("2000/4/20") To DateValue("2000/5/20")
		ConstellName = "阴性、地象星座，守护行星：金星"
	Case DateValue("2000/5/21") To DateValue("2000/6/21")
		ConstellName = "阳性、风象星座，守护行星：水星"
	Case DateValue("2000/6/22") To DateValue("2000/7/22")
		ConstellName = "阴性、水象星座守护行星：月亮"
	Case DateValue("2000/7/23") To DateValue("2000/8/22")
		ConstellName = "阳性、火象星座，守护行星：太阳"
	Case DateValue("2000/8/23") To DateValue("2000/9/22")
		ConstellName = "阴性、土象星座，守护行星：水星"
	Case DateValue("2000/9/23") To DateValue("2000/10/23")
		ConstellName = "阳性、风象星座，守护行星：金星"
	Case DateValue("2000/10/24") To DateValue("2000/11/21")
		ConstellName = "阴性、水象星座，守护行星：冥王星(传统上为火星)"
	Case DateValue("2000/11/22") To DateValue("2000/12/21")
		ConstellName = "阳性、火象星座，守护行星：木星"
	Case DateValue("2000/12/22") To DateValue("2000/12/31")
		ConstellName = "阴性、土象星座，守护行星：土星"
	Case DateValue("2000/1/1") To DateValue("2000/1/19")
		ConstellName = "阴性、土象星座，守护行星：土星"
	Case DateValue("2000/1/20") To DateValue("2000/2/18")
		ConstellName = "阳性、风象星座,守护行星：天王星(传统上为土星)"
	Case DateValue("2000/2/19") To DateValue("2000/3/20")
		ConstellName = "阴性、水象星座，守护行星：海王星"
	Case Else
		ConstellName = ""
	End Select
	Constellation2 = ConstellName
End Function

Private Property LunarCalendar.sDay() As Long
	sDay = mvarsDay
End Property

Private Property LunarCalendar.sMonth() As Long
	sMonth = mvarsMonth
End Property

Private Property LunarCalendar.sYear() As Long
	sYear = mvarsYear
End Property

Private Function LunarCalendar.IsToday(Y As Long, m As Long, d As Long) As Boolean
	
	If (Year(Now()) = Y) And _
		(Month(Now()) = m) And _
		(Day(Now()) = d) Then
		IsToday = True
	Else
		IsToday = False
	End If
	
End Function

'根据年份不同计算当年属于什么朝代
Private Function LunarCalendar.Era(Y As Long) As UString
	Dim TempStr As String
	
	If Y < 1874 Then
		TempStr = "未知"
	Else
		If Y <= 1908 Then
			TempStr = "清朝光绪"
			If Y = 1874 Then
				TempStr = TempStr & "元年"
			Else
				TempStr = TempStr & UpNumber("" & (Y - 1874)) & "年"
			End If
		Else
			If Y <= 1910 Then
				TempStr = "清朝宣统"
				If Y = 1909 Then
					TempStr = TempStr & "元年"
				Else
					TempStr = TempStr & UpNumber("" & (Y - 1909 + 1)) & "年"
				End If
			Else
				If Y < 1949 Then
					TempStr = "中华民国"
					If Y = 1912 Then
						TempStr = TempStr & "元年"
					Else
						TempStr = TempStr & UpNumber("" & (Y - 1912 + 1)) & "年"
					End If
				Else
					TempStr = "中华人民共和国成立"
					If Y = 1949 Then
						TempStr = TempStr & "了"
					Else
						Select Case Y
						Case 2000
							TempStr = "千禧年"
						Case Else
							TempStr = TempStr & UpNumber("" & (Y - 1949)) & "周年"
						End Select
					End If
				End If
			End If
		End If
	End If
	
	Era = TempStr
End Function

' 传入 num 传回干支, 0=甲子
Private Function LunarCalendar.GanZhi(num As Long) As UString
	Dim TempStr As UString
	Dim i As Long
	i = (num - 1864) Mod 60 '计算干支
	TempStr = Gan(i Mod 10) & Zhi(i Mod 12)
	GanZhi = TempStr
End Function

'计算年的属相字串
Private Function LunarCalendar.YearAttribute(Y As Long) As UString
	YearAttribute = Animals((Y - 1900) Mod 12)
End Function

'将数字汉化
Private Function LunarCalendar.UpNumber(Dxs As UString) As UString
	
	'检测为空时
	If Trim(Dxs) = "" Then
		UpNumber = ""
		Exit Function
	End If
	
	Dim Sw As Integer, SzUp As Integer, TempStr As UString, DXStr As UString
	Sw = Len(Trim(Dxs))
	
	Dim i As Integer
	For i = 1 To Sw
		TempStr = Right(Trim(Dxs), i)
		TempStr = Left(TempStr, 1)
		TempStr = Converts(TempStr)
		Select Case i
		Case 1
			If TempStr = "零" Then
				TempStr = ""
			Else
				TempStr = TempStr + ""
			End If
		Case 2
			If TempStr = "零" Then
				TempStr = "零"
			Else
				TempStr = TempStr + "十"
			End If
		Case 3
			If TempStr = "零" Then
				TempStr = "零"
			Else
				TempStr = TempStr + "百"
			End If
		Case 4
			If TempStr = "零" Then
				TempStr = "零"
			Else
				TempStr = TempStr + "千"
			End If
		Case 5
			If TempStr = "零" Then
				TempStr = "万"
			Else
				TempStr = TempStr + "万"
			End If
		Case 6
			If TempStr = "零" Then
				TempStr = "零"
			Else
				TempStr = TempStr + "十"
			End If
		Case 7
			If TempStr = "零" Then
				TempStr = "零"
			Else
				TempStr = TempStr + "百"
			End If
		Case 8
			If TempStr = "零" Then
				TempStr = "零"
			Else
				TempStr = TempStr + "千"
			End If
		Case 9
			If TempStr = "零" Then
				TempStr = "亿"
			Else
				TempStr = TempStr + "亿"
			End If
		End Select
		Dim TempA As String
		TempA = Left(Trim(DXStr), 1)
		If TempStr = "零" Then
			Select Case TempA
			Case "零"
				DXStr = DXStr
			Case "万"
				DXStr = DXStr
			Case "亿"
				DXStr = DXStr
			Case Else
				DXStr = TempStr + DXStr
			End Select
		Else
			DXStr = TempStr + DXStr
		End If
	Next
	
	UpNumber = DXStr
End Function

Private Function LunarCalendar.Converts(NumStr As String) As UString
	Select Case Val(NumStr)
	Case 0
		Converts = "零"
	Case 1
		Converts = "一"
	Case 2
		Converts = "二"
	Case 3
		Converts = "三"
	Case 4
		Converts = "四"
	Case 5
		Converts = "五"
	Case 6
		Converts = "六"
	Case 7
		Converts = "七"
	Case 8
		Converts = "八"
	Case 9
		Converts = "九"
	End Select
End Function

'中文日期
Private Function LunarCalendar.CDayStr(d As Long) As UString
	Dim s As UString
	Select Case d
	Case 0
		s = ""
	Case 10
		s = "初十"
	Case 20
		s = "二十"
	Case 30
		s = "三十"
	Case Else
		s = nStr2(d \ 10)  '整数除法
		s = s & nStr1(d Mod 10)
	End Select
	CDayStr = s
End Function

'计算星座归属
Private Function LunarCalendar.Constellation(m As Long, d As Long) As UString
	Dim tempDate As Double
	Dim ConstellName As String
	
	tempDate = DateValue("2000/" & m & "/" & d)
	
	Select Case tempDate
	Case DateValue("2000/3/21") To DateValue("2000/4/19")
		ConstellName = "山羊"
	Case DateValue("2000/4/20") To DateValue("2000/5/20")
		ConstellName = "金牛"
	Case DateValue("2000/5/21") To DateValue("2000/6/21")
		ConstellName = "双子"
	Case DateValue("2000/6/22") To DateValue("2000/7/22")
		ConstellName = "巨蟹"
	Case DateValue("2000/7/23") To DateValue("2000/8/22")
		ConstellName = "狮子"
	Case DateValue("2000/8/23") To DateValue("2000/9/22")
		ConstellName = "处女"
	Case DateValue("2000/9/23") To DateValue("2000/10/23")
		ConstellName = "天平"
	Case DateValue("2000/10/24") To DateValue("2000/11/21")
		ConstellName = "天蝎"
	Case DateValue("2000/11/22") To DateValue("2000/12/21")
		ConstellName = "射手"
	Case DateValue("2000/12/22") To DateValue("2000/12/31")
		ConstellName = "摩蝎"
	Case DateValue("2000/1/1") To DateValue("2000/1/19")
		ConstellName = "摩蝎"
	Case DateValue("2000/1/20") To DateValue("2000/2/18")
		ConstellName = "水瓶"
	Case DateValue("2000/2/19") To DateValue("2000/3/20")
		ConstellName = "双鱼"
	Case Else
		ConstellName = ""
	End Select
	Constellation = ConstellName
End Function

'以下为类内部使用的一些函数

'传回农历 y年的总天数
Private Function LunarCalendar.lYearDays(ByVal Y As Long) As Long
	lYearDays = LunarYearDays(Y - 1900)  '先计算出每年的天数,并形成数组,以减少以后的运算时间
End Function

'传回农历 y年m月的总天数
Private Function LunarCalendar.lMonthDays(ByVal Y As Long, ByVal m As Long) As Long
	'If (LunarInfo(y - 1900) And &H1000FFFF) And BitRight32(&H10000, m) Then
	
	If mvarBitTest32((LunarInfo(Y - 1900) And &H1000FFFF), 16 - m) Then
		lMonthDays = 30
	Else
		lMonthDays = 29
	End If
End Function

'传回农历 y年闰月的天数
Private Function LunarCalendar.leapDays(Y As Long) As Long
	If leapMonth(Y) Then
		If LunarInfo(Y - 1900) And &H10000 Then
			leapDays = 30
		Else
			leapDays = 29
		End If
	Else
		leapDays = 0
	End If
End Function

'传回农历 y年闰哪个月 1-12 , 没闰传回 0
Private Function LunarCalendar.leapMonth(Y As Long) As Long
	Dim i As Long
	i = LunarInfo(Y - 1900) And &HF
	If i > 12 Then
		Debug.Print "" & Y
	End If
	leapMonth = i
End Function

'计算公历年月的天数
Private Function LunarCalendar.SolarDays(Y As Long, m As Long) As Long
	Dim d As Long
	
	If (Y Mod 4) = 0 Then   '闰年
		If m = 2 Then
			d = 29
		Else
			d = SolarMonth(m - 1)
		End If
	Else
		If m = 2 Then
			d = 28
		Else
			d = SolarMonth(m - 1)
		End If
	End If
	
	SolarDays = d
End Function

'主要的函数,用公历年月日对日期对象进行初使化,在此函数内部完成对私有对象属性的设置
Private Sub LunarCalendar.sInitDate(ByVal y As Long, ByVal m As Long, ByVal d As Long)
	Dim i As Long
	Dim leap As Long
	Dim temp As Long
	Dim offset As Long
	
	mvarDate = DateSerial(y, m, d)
	mvarsYear = y
	mvarsMonth = m
	mvarsDay = d
	
	'农历日期计算部分
	leap = 0
	temp = 0
	
	offset = mvarDate - DateValue("1900/1/30")  '计算两天的基本差距
	
	For i = 1900 To 2049
		temp = lYearDays(i)  '求当年农历年天数
		
		offset = offset - temp
		If offset < 1 Then Exit For
	Next
	
	offset = offset + temp
	mvarlYear = i
	
	leap = leapMonth(i) '闰哪个月
	
	mvarIsLeap = False
	For i = 1 To 12
		'闰月
		If CBool(leap > 0) And CBool(i = (leap + 1)) And CBool(mvarIsLeap = False) Then
			mvarIsLeap = True
			i = i - 1
			temp = leapDays(mvarlYear)   '计算闰月天数
		Else
			mvarIsLeap = False
			temp = lMonthDays(mvarlYear, i) '计算非闰月天数
		End If
		
		offset = offset - temp
		If offset <= 0 Then Exit For
	Next
	
	offset = offset + temp
	mvarlMonth = i
	mvarlDay = offset
	
End Sub

'主要的函数,用农历年月日对日期对象进行初使化,在此函数内部完成对私有对象属性的设置
Private Sub LunarCalendar.lInitDate(ByVal y As Long, ByVal m As Long, ByVal d As Long, ByVal LeapFlag As Boolean = False)
	Dim i As Long
	Dim leap As Long
	Dim temp As Long
	Dim offset As Long
	
	mvarlYear = y
	mvarlMonth = m
	mvarlDay = d
	
	offset = 0
	
	For i = 1900 To y - 1
		temp = LunarYearDays(i - 1900) '求当年农历年天数
		offset = offset + temp
	Next
	
	leap = leapMonth(y) '闰哪个月
	If m <> leap Then
		mvarIsLeap = False  '当前日期并非闰月
	Else
		mvarIsLeap = LeapFlag  '使用用户输入的是否闰月月份
	End If
	
	If (m < leap) Or (leap = 0) Then   '当闰月在当前日期后
		For i = 1 To m - 1
			temp = lMonthDays(y, i) '计算非闰月天数
			offset = offset + temp
		Next
	Else   '在闰月后
		If mvarIsLeap = False Then  '用户要计算非闰月的月份
			For i = 1 To m - 1
				temp = lMonthDays(y, i) '计算非闰月天数
				offset = offset + temp
			Next
			If m > leap Then
				temp = leapDays(y)   '计算闰月天数
				offset = offset + temp
			End If
			
		Else  '此时只有mvarisleap=ture,
			For i = 1 To m
				temp = lMonthDays(y, i) '计算非闰月天数
				offset = offset + temp
			Next
		End If
	End If
	
	offset = offset + d '加上当月的天数
	mvarDate = DateAdd("d", offset, DateValue("1900/1/30"))
	mvarsYear = Year(mvarDate)
	mvarsMonth = Month(mvarDate)
	mvarsDay = Day(mvarDate)
End Sub

