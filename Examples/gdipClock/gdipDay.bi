' gdipDay
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "gdip.bi"
#include once "..\ChineseCalendar\Lunar.bi"

Enum DayColorIdx
	DayFocus = 0
	DayYear
	DayMonth
	DayDay
	DayWeek
	DayImageFile
	DayTray
	DayPanel
	DayGlobal
End Enum

Type gdipDay
	mForeColor(DayGlobal) As ARGB = {&HBF3F7F,   &HFFFFFF,   &H000000,   &H000000,   &H000000,   &H000000,   &H000000,   &HBF3F7F,   &H000000}
	mForeAlpha(DayGlobal) As ARGB = {&H80000000, &HFF000000, &HFF000000, &HFF000000, &HFF000000, &HFF000000, &HFF000000, &HFF000000, &HFF000000}
	mBackColor(DayGlobal) As ARGB = {&HFFFFFF,   &HBF3F7F,   &HFFBFDF,   &HFFFFFF,   &HFFBFDF,   &HFFBFDF,   &H000000,   &HFFFFFF,   &H000000}
	mBackAlpha(DayGlobal) As ARGB = {&H40000000, &HFF000000, &H80000000, &H40000000, &H40000000, &H80000000, &HFF000000, &H40000000, &HFF000000}
	
	mBackBitmap As gdipBitmap
	mBackBlur As Integer = 0
	mBackEnabled As Boolean = True
	mBackImage As gdipImage
	mBackScale As Single = 1
	mBorderSize As Single = 1
	mByHeight As Boolean
	mCalendar As Lunar
	mFontName As WString Ptr
	mFontSize As Single
	mForceUpdate As Boolean = True
	mH(3) As Single
	mHeight As Single
	mMouseLocate As Integer = 0
	mMouseX As Integer = -1
	mMouseY As Integer = -1
	mOffsetX As Single
	mOH(3) As Single
	mOutlineEnabled As Boolean = True
	mOutlineSize As Single = 1
	mPanelEnabled As Boolean = True
	mSelectDate As Double
	mShowStyle As Integer = 0
	mSplitXScale As Single = 0.45
	mTrayEnabled As Boolean = True
	mTxt As gdipText
	mUpdateBitmap As gdipBitmap
	mW(0) As Single
	mWidth As Single
	
	Declare Constructor
	Declare Destructor
	Declare Function DataExpire(pWidth As Single, pHeight As Single, pSelectDate As Double) As Boolean
	Declare Function DayCalendar() As GpImage Ptr
	Declare Function ImageUpdate(pSelectDate As Double) As GpImage Ptr
	Declare Property FileName() ByRef As WString
	Declare Property FileName(ByRef fFileName As WString)
	Declare Sub Background(pWidth As Single, pHeight As Single, pSelectDate As Double)
End Type

#ifndef __USE_MAKE__
	#include once "gdipDay.bas"
#endif
