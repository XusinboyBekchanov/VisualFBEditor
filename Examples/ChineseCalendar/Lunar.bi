' Gregorian Calendar Lunar Calendar公历农历
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.
' https://thuthuataccess.com/forum/thread-4765.html

Private Type Holiday
	Month As Long
	Day As Long
	Recess As Long
	HolidayName As WString Ptr
End Type

Type Lunar
	lDay As Integer
	lMonth As Integer
	lYear As Integer
	IsLeap As Boolean
	sYear As Integer
	sMonth As Integer
	sDay As Integer
	sDate As Double
	
	WeekNameFull(7) As String = {" * ", "星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"}
	WeekName(7) As String = {" * ", "日", "一", "二", "三", "四", "五", "六"}
	nStr1(11) As String = {"日", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"}
	nStr2(4) As String = {"初", "十", "廿", "卅", "　"}	
	lMonthName(12) As String = {"*", "正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "腊月"}
	sMonthName(12) As String = {"*", "一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"}
	Gan(10) As String = {"甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"}
	Zhi(11) As String = {"子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"}
	Animals(11) As String = {"鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"}
	SolarTerm(23) As String = {"小寒", "大寒", "立春", "雨水", "惊蛰", "春分", "清明", "谷雨", "立夏", "小满", "芒种", "夏至", "小暑", "大暑", "立秋", "处暑", "白露", "秋分", "寒露", "霜降", "立冬", "小雪", "大雪", "冬至"}
	TermInfo(23) As Long = {0, 21208, 42467, 63836, 85337, 107014, 128867, 150921, 173149, 195551, 218072, 240693, 263343, 285989, 308563, 331033, 353350, 375494, 397447, 419210, 440795, 462224, 483532, 504758}
	MonthMask(11) As Integer = {32768, 16384, 8192, 4096, 2048, 1024, 512, 256, 128, 64, 32, 16}
	LunarInfo(299) As Integer = { _
	&H3C4BD8, &H624AE0, &H4CA570, &H3854D5, &H5CD260, &H44D950, &H315554, &H5656A0, &H409AD0, &H2A55D2, &H504AE0, &H3AA5B6, &H60A4D0, &H48D250, &H33D255, &H58B540, &H42D6A0, &H2CADA2, &H5295B0, &H3F4977, _
	&H644970, &H4CA4B0, &H36B4B5, &H5C6A50, &H466D40, &H2FAB54, &H562B60, &H409570, &H2C52F2, &H504970, &H3A6566, &H5ED4A0, &H48EA50, &H336A95, &H585AD0, &H442B60, &H2F86E3, &H5292E0, &H3DC8D7, &H62C950, _
	&H4CD4A0, &H35D8A6, &H5AB550, &H4656A0, &H31A5B4, &H5625D0, &H4092D0, &H2AD2B2, &H50A950, &H38B557, &H5E6CA0, &H48B550, &H355355, &H584DA0, &H42A5B0, &H2F4573, &H5452B0, &H3CA9A8, &H60E950, &H4C6AA0, _
	&H36AEA6, &H5AAB50, &H464B60, &H30AAE4, &H56A570, &H405260, &H28F263, &H4ED940, &H38DB47, &H5CD6A0, &H4896D0, &H344DD5, &H5A4AD0, &H42A4D0, &H2CD4B4, &H52B250, &H3CD558, &H60B540, &H4AB5A0, &H3755A6, _
	&H5C95B0, &H4649B0, &H30A974, &H56A4B0, &H40AA50, &H29AA52, &H4E6D20, &H39AD47, &H5EAB60, &H489370, &H344AF5, &H5A4970, &H4464B0, &H2C74A3, &H50EA50, &H3D6A58, &H6256A0, &H4AAAD0, &H3696D5, &H5C92E0, _
	&H46C960, &H2ED954, &H54D4A0, &H3EDA50, &H2A7552, &H4E56A0, &H38A7A7, &H5EA5D0, &H4A92B0, &H32AAB5, &H58A950, &H42B4A0, &H2CBAA4, &H50AD50, &H3C55D9, &H624BA0, &H4CA5B0, &H375176, &H5C5270, &H466930, _
	&H307934, &H546AA0, &H3EAD50, &H2A5B52, &H504B60, &H38A6E6, &H5EA4E0, &H48D260, &H32EA65, &H56D520, &H40DAA0, &H2D56A3, &H5256D0, &H3C4AFB, &H6249D0, &H4CA4D0, &H37D0B6, &H5AB250, &H44B520, &H2EDD25, _
	&H54B5A0, &H3E55D0, &H2A55B2, &H5049B0, &H3AA577, &H5EA4B0, &H48AA50, &H33B255, &H586D20, &H40AD60, &H2D4B63, &H525370, &H3E49E8, &H60C970, &H4C54B0, &H3768A6, &H5ADA50, &H445AA0, &H2FA6A4, &H54AAD0, _
	&H4052E0, &H28D2E3, &H4EC950, &H38D557, &H5ED4A0, &H46D950, &H325D55, &H5856A0, &H42A6D0, &H2C55D4, &H5252B0, &H3CA9B8, &H62A930, &H4AB490, &H34B6A6, &H5AAD50, &H4655A0, &H2EAB64, &H54A570, &H4052B0, _
	&H2AB173, &H4E6930, &H386B37, &H5E6AA0, &H48AD50, &H332AD5, &H582B60, &H42A570, &H2E52E4, &H50D160, &H3AE958, &H60D520, &H4ADA90, &H355AA6, &H5A56D0, &H462AE0, &H30A9D4, &H54A2D0, &H3ED150, &H28E952, _
	&H4EB520, &H38D727, &H5EADA0, &H4A55B0, &H362DB5, &H5A45B0, &H44A2B0, &H2EB2B4, &H54A950, &H3CB559, &H626B20, &H4CAD50, &H385766, &H5C5370, &H484570, &H326574, &H5852B0, &H406950, &H2A7953, &H505AA0, _
	&H3BAAA7, &H5EA6D0, &H4A4AE0, &H35A2E5, &H5AA550, &H42D2A0, &H2DE2A4, &H52D550, &H3E5ABB, &H6256A0, &H4C96D0, &H3949B6, &H5E4AB0, &H46A8D0, &H30D4B5, &H56B290, &H40B550, &H2A6D52, &H504DA0, &H3B9567, _
	&H609570, &H4A49B0, &H34A975, &H5A64B0, &H446A90, &H2CBA94, &H526B50, &H3E2B60, &H28AB61, &H4C9570, &H384AE6, &H5CD160, &H46E4A0, &H2EED25, &H54DA90, &H405B50, &H2C36D3, &H502AE0, &H3A93D7, &H6092D0, _
	&H4AC950, &H32D556, &H58B4A0, &H42B690, &H2E5D94, &H5255B0, &H3E25FA, &H6425B0, &H4E92B0, &H36AAB6, &H5C6950, &H4674A0, &H31B2A5, &H54AD50, &H4055A0, &H2AAB73, &H522570, &H3A5377, &H6052B0, &H4A6950, _
	&H346D56, &H585AA0, &H42AB50, &H2E56D4, &H544AE0, &H3CA570, &H2864D2, &H4CD260, &H36EAA6, &H5AD550, &H465AA0, &H30ADA5, &H5695D0, &H404AD0, &H2AA9B3, &H50A4D0, &H3AD2B7, &H5EB250, &H48B540, &H33D556}
	
	'公历节日 1表示放假日
	sHolidayDB(65) As Holiday = { _
	(1, 1, 1, @WStr("元旦")), _
	(2, 2, 0, @WStr("世界湿地日")), _
	(2, 14, 0, @WStr("情人节")), _
	(2, 10, 0, @WStr("国际气象节")), _
	(3, 1, 0, @WStr("国际海豹日")), _
	(3, 5, 0, @WStr("学雷锋纪念日")), _
	(3, 8, 0, @WStr("妇女节")), _
	(3, 12, 0, @WStr("植树节 孙中山逝世纪念日")), _
	(3, 14, 0, @WStr("国际警察日")), _
	(3, 15, 0, @WStr("消费者权益日")), _
	(3, 17, 0, @WStr("中国国医节 国际航海日")), _
	(3, 21, 0, @WStr("世界森林日 消除种族歧视国际日 世界儿歌日")), _
	(3, 22, 0, @WStr("世界水日")), _
	(3, 24, 0, @WStr("世界防治结核病日")), _
	(4, 1, 0, @WStr("愚人节")), _
	(4, 28, 0, @WStr("08'胶济铁路火车相撞")), _
	(4, 7, 0, @WStr("世界卫生日")), _
	(4, 22, 0, @WStr("世界地球日")), _
	(5, 1, 1, @WStr("劳动节")), _
	(5, 4, 0, @WStr("青年节")), _
	(5, 12, 0, @WStr("08'汶川地震 护士节")), _
	(5, 31, 0, @WStr("世界无烟日")), _
	(5, 8, 0, @WStr("世界红十字日")), _
	(5, 12, 0, @WStr("国际护士节")), _
	(6, 1, 0, @WStr("儿童节")), _
	(6, 5, 0, @WStr("世界环境保护日")), _
	(6, 26, 0, @WStr("国际禁毒日")), _
	(7, 1, 0, @WStr("建党节 香港回归纪念 世界建筑日")), _
	(7, 11, 0, @WStr("世界人口日")), _
	(8, 1, 0, @WStr("建军节")), _
	(8, 8, 0, @WStr("中国男子节 父亲节")), _
	(8, 15, 0, @WStr("抗日战争胜利纪念")), _
	(9, 9, 0, @WStr("毛泽东逝世纪念")), _
	(9, 10, 0, @WStr("教师节")), _
	(9, 18, 0, @WStr("九·一八事变纪念日")), _
	(9, 28, 0, @WStr("孔子诞辰")), _
	(9, 20, 0, @WStr("国际爱牙日")), _
	(9, 27, 0, @WStr("世界旅游日")), _
	(10, 1, 0, @WStr("国庆节 国际音乐日")), _
	(10, 2, 1, @WStr("国庆节假日")), _
	(10, 3, 1, @WStr("国庆节假日")), _
	(10, 6, 0, @WStr("老人节")), _
	(10, 24, 0, @WStr("联合国日")), _
	(11, 12, 0, @WStr("孙中山诞辰纪念")), _
	(11, 3, 0, @WStr("本软件作者生日")), _
	(11, 1, 0, @WStr("国际旅游电影节")), _
	(11, 8, 0, @WStr("中国记者日")), _
	(11, 10, 0, @WStr("世界青年日")), _
	(11, 14, 0, @WStr("世界糖尿病日")), _
	(11, 17, 0, @WStr("世界学生节")), _
	(12, 1, 0, @WStr("世界艾滋病日")), _
	(12, 3, 0, @WStr("世界残疾人日")), _
	(12, 20, 0, @WStr("澳门回归纪念")), _
	(12, 24, 0, @WStr("平安夜")), _
	(12, 25, 0, @WStr("圣诞节")), _
	(12, 26, 0, @WStr("毛泽东诞辰纪念")), _
	(12, 9, 0, @WStr("世界足球日")), _
	(12, 10, 0, @WStr("世界人权日")), _
	(12, 13, 0, @WStr("南京大屠杀纪念日")), _
	(9, 3, 0, @WStr("抗日战争胜利日")), _
	(9, 17, 0, @WStr("国际和平日")), _
	(9, 20, 0, @WStr("全国爱牙日")), _
	(10, 8, 0, @WStr("全国高血压日")), _
	(10, 15, 0, @WStr("国际盲人节(白手杖日)")), _
	(10, 16, 0, @WStr("世界粮食日")), _
	(10, 31, 0, @WStr("万圣节")) _
	}
	
	'农历节日 1表示放假日
	lHolidayDB(8) As Holiday = { _
	(1, 1, 1, @WStr("春节")), _
	(1, 15, 0, @WStr("元宵节")), _
	(5, 5, 1, @WStr("端午节")), _
	(7, 7, 0, @WStr("七夕情人节")), _
	(7, 15, 0, @WStr("中元节 盂兰盆节")), _
	(8, 15, 1, @WStr("中秋节")), _
	(9, 9, 0, @WStr("重阳节")), _
	(12, 8, 0, @WStr("腊八节")), _
	(12, 24, 0, @WStr("小年")) _
	}
	
	'某月的第几个星期几
	wHolidayDB(8) As Holiday = { _
	(5, 2, 1, @WStr("国际母亲节")), _
	(5, 3, 1, @WStr("全国助残日")), _
	(6, 3, 1, @WStr("父亲节")), _
	(9, 3, 3, @WStr("国际和平日")), _
	(9, 4, 1, @WStr("国际聋人节")), _
	(10, 1, 2, @WStr("国际住房日")), _
	(10, 1, 4, @WStr("国际减轻自然灾害日")), _
	(11, 4, 5, @WStr("感恩节")) _
	}
	
	Declare Sub Init(y As Integer, m As Integer, d As Integer)          '初始化
	Declare Function LeapDays(y As Integer) As Integer                  '传回农历y年闰月的天数
	Declare Function LeapMonth(y As Integer) As Integer                 '传回农历y年闰哪个月 1-12 , 没闰传回 0
	Declare Function lMonthDays(y As Integer, m As Integer) As Integer  '传回农历y年m月的总天数
	Declare Function lYearDays(y As Integer) As Integer                 '传回农历y年的总天数
	
	Declare Function GanZhi(y As Integer) As String                     '传回农历y年天干地支
	Declare Function YearAttribute(y As Integer) As String              '传回农历y年生肖
	Declare Property lSolarTerm() As String                             '节气
	Declare Property wHoliday() As String                               '星期节日
	Declare Property lHoliday() As String                               '农历节日
	Declare Property sHoliday() As String                               '公历节日
	Declare Function lDayName(d As Integer) As String                   '农历日期名
End Type

#ifndef __USE_MAKE__
	#include once "Lunar.bas"
#endif
