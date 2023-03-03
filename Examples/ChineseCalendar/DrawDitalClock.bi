' DrawDitalClock 绘制数字时钟日历
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

#include once "mff/Canvas.bi"

Type DrawDitalClock
Private:
	mW(Any) As Integer
	mH(Any) As Integer
	mCanvas As My.Sys.Drawing.Canvas Ptr
	mFontSize As Integer
	mDt As String
	mColon As String
	mShowCalendar As Boolean
Public:
	Declare Constructor
	Declare Destructor
	Declare Property Colon() As String
	Declare Property Colon(s As String)
	Declare Property ShowCalendar As Boolean
	Declare Property ShowCalendar(s As Boolean)
	Declare Property FontSize() As Integer
	Declare Property FontSize(s As Integer)
	Declare Property Width() As Integer
	Declare Property Height() As Integer
	Declare Sub Initial(ByRef Canvas As My.Sys.Drawing.Canvas)
	Declare Sub PaintClock(ByRef Canvas As My.Sys.Drawing.Canvas, DateTime As Double, ByVal Mark As Integer = -1, ByVal DrawCalendar As Boolean = False)
End Type

Type DrawCalendar
Private:
	'当月第一天
	mDayStart As Double
	'当月天数
	mDayCount As Integer
	'当天
	mDay As Integer
	'当月第一天星期几 (星期日为每周第一天)
	mWeekStart As Integer
	'行数
	mLineCount As Integer
	'格子高
	mCellHeight As Integer
	'格子宽
	mCellWidth As Integer
	cal As Calendar
	
	mHeight As Integer
	mWidth As Integer
	mDateTime As Double
	mFontSize As Integer
Public:
	Declare Constructor
	Declare Destructor
	'Declare Function XY2Date(dif As Integer) As Double
	Declare Function XY2Date(x As Integer, y As Integer) As Double
	Declare Sub PaintCalendar(ByRef Canvas As My.Sys.Drawing.Canvas, DateTime As Double)
End Type

#ifndef __USE_MAKE__
	#include once "DrawDitalClock.bas"
#endif
