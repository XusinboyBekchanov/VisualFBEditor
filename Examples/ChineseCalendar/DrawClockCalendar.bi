﻿' DrawClockCalendar 绘制时钟日历
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

#include once "mff/Canvas.bi"

#define vbRGB(r, g, b) CULng((CUByte(b) Shl 16) Or (CUByte(g) Shl 8) Or CUByte(r))

Type DitalClock
Private:
	mFontSize As Integer
	mDt As String
	mColon As String
	mW(2) As Integer
	mH(0) As Integer
	mOx As Integer
	mOy As Integer
	'index            0     1     2     3     4     5     6     7     8
	mC(8) As UByte = {&h00, &h1f, &h3f, &h5f, &h7f, &h9f, &hbf, &hdf, &hff}
	mClr(5) As ULong
	mShowSec As Boolean = True
	Declare Sub CalculateSize(Canvas As My.Sys.Drawing.Canvas)
Public:
	FontNameE As String
	FontNameC As String
	
	Declare Constructor
	Declare Destructor
	Declare Property ShowSecond() As Boolean
	Declare Property ShowSecond(b As Boolean)
	Declare Property Colon() As String
	Declare Property Colon(s As String)
	Declare Function FontSize() As Integer
	Declare Property Width() As Integer
	Declare Property Height() As Integer
	Declare Sub DrawClock(ByRef Canvas As My.Sys.Drawing.Canvas, DateTime As Double, ByVal Mark As Integer = -1)
End Type

Type DayCalendar
Private:
	mFontSize As Integer
	mDt As String
	mColon As String
	mShowCalendar As Boolean
	mW(0) As Integer
	mH(3) As Integer
	
	'index            0     1     2     3     4     5     6     7     8
	mC(8) As UByte = {&h00, &h1f, &h3f, &h5f, &h7f, &h9f, &hbf, &hdf, &hff}
	mClr(10) As ULong
	
	Declare Sub CalculateSize(Canvas As My.Sys.Drawing.Canvas)
Public:
	FontNameE As String
	FontNameC As String
	
	Declare Constructor
	Declare Destructor
	Declare Function FontSize() As Integer
	Declare Property Width() As Integer
	Declare Property Height() As Integer
	Declare Sub DrawDayCalendar(ByRef Canvas As My.Sys.Drawing.Canvas, DateTime As Double)
End Type

Type MonthCalendar
Private:
	'当天
	mDateTime As Double
	'当月第一天
	mDayStart As Double
	'当月天数
	mDayCount As Integer
	'当月第一天星期几 (星期日为每周第一天)
	mWeekStart As Integer
	'行数
	mLineCount As Integer
	'格子高
	mCellHeight As Integer
	'格子宽
	mCellWidth As Integer
	cal As LunarCalendar
	
	mHeight As Integer
	mWidth As Integer
	mFontSize As Integer
	'index            0     1     2     3     4     5     6     7     8
	mC(8) As UByte = {&h00, &h1f, &h3f, &h5f, &h7f, &h9f, &hbf, &hdf, &hff}
	mClr(13) As ULong
Public:
	FontNameE As String
	FontNameC As String
	
	Declare Constructor
	Declare Destructor
	Declare Function XY2Date(x As Integer, y As Integer) As Double
	Declare Sub DrawMonthCalendar(ByRef Canvas As My.Sys.Drawing.Canvas, DateTime As Double)
End Type

#ifndef __USE_MAKE__
	#include once "DrawClockCalendar.bas"
#endif
