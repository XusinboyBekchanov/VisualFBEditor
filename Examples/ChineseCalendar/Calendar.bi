' Gregorian Calendar Lunar Calendar公历农历
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

Private Type HolidayStruct
	Month As Long
	Day As Long
	Recess As Long
	HolidayName As WString Ptr
End Type

Type Calendar
Private:
	'0-31
	BitPower(31) As Long
	'内部使用标准的日期变量
	mvarDate As Double
	'保持属性值的局部变量
	mvarsYear As Long
	mvarsMonth As Long
	mvarsDay As Long
	mvarlYear As Long
	mvarlMonth As Long
	mvarlDay As Long
	mvarIsLeap As Boolean
	
	'定义类内部用公用变量
	SolarMonth(11) As Long = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
	Gan(10) As String = {"甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"}
	Zhi(11) As String = {"子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"}
	Animals(11) As String = {"鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"}
	SolarTerm(23) As String = {"小寒", "大寒", "立春", "雨水", "惊蛰", "春分", "清明", "谷雨", "立夏", "小满", "芒种", "夏至", "小暑", "大暑", "立秋", "处暑", "白露", "秋分", "寒露", "霜降", "立冬", "小雪", "大雪", "冬至"}
	sTermInfo(23) As Long = {0, 21208, 42467, 63836, 85337, 107014, 128867, 150921, 173149, 195551, 218072, 240693, 263343, 285989, 308563, 331033, 353350, 375494, 397447, 419210, 440795, 462224, 483532, 504758}
	nStr1(11) As String = {"日", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"}
	nStr2(4) As String = {"初", "十", "廿", "卅", "　"}

	'根据VB的位计算特点,故扩充原有的数据位,将其变成32位
	LunarInfo(150) As Long = { _
	&H104BD8, &H104AE0, &H10A570, &H1054D5, &H10D260, &H10D950, &H116554, &H1056A0, &H109AD0, &H1055D2, _
	&H104AE0, &H10A5B6, &H10A4D0, &H10D250, &H11D255, &H10B540, &H10D6A0, &H10ADA2, &H1095B0, &H114977, _
	&H104970, &H10A4B0, &H10B4B5, &H106A50, &H106D40, &H11AB54, &H102B60, &H109570, &H1052F2, &H104970, _
	&H106566, &H10D4A0, &H10EA50, &H106E95, &H105AD0, &H102B60, &H1186E3, &H1092E0, &H11C8D7, &H10C950, _
	&H10D4A0, &H11D8A6, &H10B550, &H1056A0, &H11A5B4, &H1025D0, &H1092D0, &H10D2B2, &H10A950, &H10B557, _
	&H106CA0, &H10B550, &H115355, &H104DA0, &H10A5D0, &H114573, &H1052D0, &H10A9A8, &H10E950, &H106AA0, _
	&H10AEA6, &H10AB50, &H104B60, &H10AAE4, &H10A570, &H105260, &H10F263, &H10D950, &H105B57, &H1056A0, _
	&H1096D0, &H104DD5, &H104AD0, &H10A4D0, &H10D4D4, &H10D250, &H10D558, &H10B540, &H10B5A0, &H1195A6, _
	&H1095B0, &H1049B0, &H10A974, &H10A4B0, &H10B27A, &H106A50, &H106D40, &H10AF46, &H10AB60, &H109570, _
	&H104AF5, &H104970, &H1064B0, &H1074A3, &H10EA50, &H106B58, &H1055C0, &H10AB60, &H1096D5, &H1092E0, _
	&H10C960, &H10D954, &H10D4A0, &H10DA50, &H107552, &H1056A0, &H10ABB7, &H1025D0, &H1092D0, &H10CAB5, _
	&H10A950, &H10B4A0, &H10BAA4, &H10AD50, &H1055D9, &H104BA0, &H10A5B0, &H115176, &H1052B0, &H10A930, _
	&H107954, &H106AA0, &H10AD50, &H105B52, &H104B60, &H10A6E6, &H10A4E0, &H10D260, &H10EA65, &H10D530, _
	&H105AA0, &H1076A3, &H1096D0, &H104BD7, &H104AD0, &H10A4D0, &H11D0B6, &H10D250, &H10D520, &H10DD45, _
	&H10B5A0, &H1056D0, &H1055B2, &H1049B0, &H10A577, &H10A4B0, &H10AA50, &H11B255, &H106D20, &H10ADA0}
	
	LunarYearDays(150) As Long = { _
	384, 354, 355, 383, 354, 355, 384, 354, 355, 384, _
	354, 384, 354, 354, 384, 354, 355, 384, 355, 384, _
	354, 354, 384, 354, 354, 385, 354, 355, 384, 354, _
	383, 354, 355, 384, 355, 354, 384, 354, 384, 354, _
	354, 384, 355, 354, 385, 354, 354, 384, 354, 384, _
	354, 355, 384, 354, 355, 384, 354, 383, 355, 354, _
	384, 355, 354, 384, 355, 353, 384, 355, 384, 354, _
	355, 384, 354, 354, 384, 354, 384, 354, 355, 384, _
	355, 354, 384, 354, 384, 354, 354, 384, 355, 355, _
	384, 354, 354, 383, 355, 384, 354, 355, 384, 354, _
	354, 384, 354, 355, 384, 354, 385, 354, 354, 384, _
	354, 354, 384, 355, 384, 354, 355, 384, 354, 354, _
	384, 354, 355, 384, 354, 384, 354, 354, 384, 355, _
	354, 384, 355, 384, 354, 354, 384, 354, 354, 384, _
	355, 355, 384, 354, 384, 354, 354, 384, 354, 355}
	
	'公历节日 1表示放假日
	sHolidayInfo(65) As HolidayStruct = { _
	(1, 1, 1, @"元旦"), _
	(2, 2, 0, @"世界湿地日"), _
	(2, 14, 0, @"情人节"), _
	(2, 10, 0, @"国际气象节"), _
	(3, 1, 0, @"国际海豹日"), _
	(3, 5, 0, @"学雷锋纪念日"), _
	(3, 8, 0, @"妇女节"), _
	(3, 12, 0, @"植树节 孙中山逝世纪念日"), _
	(3, 14, 0, @"国际警察日"), _
	(3, 15, 0, @"消费者权益日"), _
	(3, 17, 0, @"中国国医节 国际航海日"), _
	(3, 21, 0, @"世界森林日 消除种族歧视国际日 世界儿歌日"), _
	(3, 22, 0, @"世界水日"), _
	(3, 24, 0, @"世界防治结核病日"), _
	(4, 1, 0, @"愚人节"), _
	(4, 28, 0, @"08'胶济铁路火车相撞"), _
	(4, 7, 0, @"世界卫生日"), _
	(4, 22, 0, @"世界地球日"), _
	(5, 1, 1, @"劳动节"), _
	(5, 4, 0, @"青年节"), _
	(5, 12, 0, @"08'汶川地震 护士节"), _
	(5, 31, 0, @"世界无烟日"), _
	(5, 8, 0, @"世界红十字日"), _
	(5, 12, 0, @"国际护士节"), _
	(6, 1, 0, @"儿童节"), _
	(6, 5, 0, @"世界环境保护日"), _
	(6, 26, 0, @"国际禁毒日"), _
	(7, 1, 0, @"建党节 香港回归纪念 世界建筑日"), _
	(7, 11, 0, @"世界人口日"), _
	(8, 1, 0, @"建军节"), _
	(8, 8, 0, @"中国男子节 父亲节"), _
	(8, 15, 0, @"抗日战争胜利纪念"), _
	(9, 9, 0, @"毛泽东逝世纪念"), _
	(9, 10, 0, @"教师节"), _
	(9, 18, 0, @"九·一八事变纪念日"), _
	(9, 28, 0, @"孔子诞辰"), _
	(9, 20, 0, @"国际爱牙日"), _
	(9, 27, 0, @"世界旅游日"), _
	(10, 1, 0, @"国庆节 国际音乐日"), _
	(10, 2, 1, @"国庆节假日"), _
	(10, 3, 1, @"国庆节假日"), _
	(10, 6, 0, @"老人节"), _
	(10, 24, 0, @"联合国日"), _
	(11, 12, 0, @"孙中山诞辰纪念"), _
	(11, 3, 0, @"本软件作者生日"), _
	(11, 1, 0, @"国际旅游电影节"), _
	(11, 8, 0, @"中国记者日"), _
	(11, 10, 0, @"世界青年日"), _
	(11, 14, 0, @"世界糖尿病日"), _
	(11, 17, 0, @"世界学生节"), _
	(12, 1, 0, @"世界艾滋病日"), _
	(12, 3, 0, @"世界残疾人日"), _
	(12, 20, 0, @"澳门回归纪念"), _
	(12, 24, 0, @"平安夜"), _
	(12, 25, 0, @"圣诞节"), _
	(12, 26, 0, @"毛泽东诞辰纪念"), _
	(12, 9, 0, @"世界足球日"), _
	(12, 10, 0, @"世界人权日"), _
	(12, 13, 0, @"南京大屠杀纪念日"), _
	(9, 3, 0, @"抗日战争胜利日"), _
	(9, 17, 0, @"国际和平日"), _
	(9, 20, 0, @"全国爱牙日"), _
	(10, 8, 0, @"全国高血压日"), _
	(10, 15, 0, @"国际盲人节(白手杖日)"), _
	(10, 16, 0, @"世界粮食日"), _
	(10, 31, 0, @"万圣节") _
	}
	
	'农历节日 1表示放假日
	lHolidayInfo(8) As HolidayStruct = { _
	(1, 1, 1, @"春节"), _
	(1, 15, 0, @"元宵节"), _
	(5, 5, 1, @"端午节"), _
	(7, 7, 0, @"七夕情人节"), _
	(7, 15, 0, @"中元节 盂兰盆节"), _
	(8, 15, 1, @"中秋节"), _
	(9, 9, 0, @"重阳节"), _
	(12, 8, 0, @"腊八节"), _
	(12, 24, 0, @"小年") _
	}
	
	'某月的第几个星期几
	wHolidayInfo(8) As HolidayStruct = { _
	(5, 2, 1, @"国际母亲节"), _
	(5, 3, 1, @"全国助残日"), _
	(6, 3, 1, @"父亲节"), _
	(9, 3, 3, @"国际和平日"), _
	(9, 4, 1, @"国际聋人节"), _
	(10, 1, 2, @"国际住房日"), _
	(10, 1, 4, @"国际减轻自然灾害日"), _
	(11, 4, 5, @"感恩节") _
	}

Public:
	MonthNameS(11) As String = {"JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"}
	MonthName(11) As String = {"JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"}
	'时辰———十二地支纪一昼24小时为十二时辰
	HourName(23) As String = {"子正", "丑初", "丑正", "寅初", "寅正", "卯初", "卯正", "辰初", "辰正", "巳初", "巳正", "午初", "午正", "未初", "未正", "申初", "申正", "酉初", "酉正", "戌初", "戌正", "亥初", "亥正", "子初"}
	'农历月份名
	MonName(12) As String = {"*", "正", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一", "腊"}
	'星期名称
	WeekName(7) As String = {" * ", "星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"}
	WeekNameS(7) As String = {" * ", "日", "一", "二", "三", "四", "五", "六"}
	
	Declare Constructor
	Declare Destructor
	Declare Function mvarBitTest32(Number As Long, Bit As Long) As Boolean
	Declare Property lSolarTerm() As String
	Declare Property wHoliday() As String
	Declare Property lHoliday() As String
	Declare Property sHoliday() As String
	Declare Property sHolidayRecess() As Boolean
	Declare Property IsLeap() As Boolean
	Declare Function lHour(H As Double) As String
	Declare Property lDay() As Long
	Declare Property lMonth() As Long
	Declare Property lYear() As Long
	Declare Property sWeekDay() As Long
	Declare Property sWeekDayStr() As String
	Declare Function Constellation2(m As Long, d As Long) As String
	Declare Property sDay() As Long
	Declare Property sMonth() As Long
	Declare Property sYear() As Long
	Declare Function IsToday(Y As Long, m As Long, d As Long) As Boolean
	Declare Function Era(Y As Long) As String
	Declare Function GanZhi(num As Long) As String
	Declare Function YearAttribute(Y As Long) As String
	Declare Function UpNumber(Dxs As String) As String
	Declare Function Converts(NumStr As String) As String
	Declare Function CDayStr(d As Long) As String
	Declare Function Constellation(m As Long, d As Long) As String
	Declare Function lYearDays(ByVal Y As Long) As Long
	Declare Function lMonthDays(ByVal Y As Long, ByVal m As Long) As Long
	Declare Function leapDays(Y As Long) As Long
	Declare Function leapMonth(Y As Long) As Long
	Declare Function SolarDays(Y As Long, m As Long) As Long
	Declare Sub sInitDate(ByVal Y As Long, ByVal m As Long, ByVal d As Long)
	Declare Sub lInitDate(ByVal Y As Long, ByVal m As Long, ByVal d As Long, ByVal LeapFlag As Boolean = False)
End Type

#ifndef __USE_MAKE__
	#include once "Calendar.bas"
#endif


