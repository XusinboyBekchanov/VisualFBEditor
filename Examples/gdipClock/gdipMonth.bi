' gdipMonth
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "gdip.bi"
#include once "..\ChineseCalendar\Lunar.bi"

Enum MonthColorIdx
	MonthFocus = 0
	MonthControl
	MonthWeek
	MonthDay
	MonthSelect
	MonthToday
	MonthHoliday
	MonthOther
	MonthImageFile
	MonthTray
	MonthPanel
	MonthGlobal
End Enum

Type gdipMonth
	mForeColor(MonthGlobal) As ARGB = {&HBF3F7F,   &HFFFFFF,   &H000000,   &H000000,   &HBF3F7F,   &H0000FF,   &HFF0000,   &H000000,   &H000000,   &H000000,   &HBF3F7F,   &H000000}
	mForeAlpha(MonthGlobal) As ARGB = {&H80000000, &HFF000000, &HFF000000, &HFF000000, &H80000000, &HFF000000, &HFF000000, &H40000000, &HFF000000, &HFF000000, &HFF000000, &HFF000000}
	mBackColor(MonthGlobal) As ARGB = {&HFFFFFF,   &HBF3F7F,   &HFFBFDF,   &HFFFFFF,   &HFFBFDF,   &H000000,   &H000000,   &H000000,   &H000000,   &H000000,   &HFFFFFF,   &H000000}
	mBackAlpha(MonthGlobal) As ARGB = {&H40000000, &HFF000000, &H80000000, &H40000000, &H80000000, &HFF000000, &HFF000000, &H40000000, &H80000000, &HFF000000, &H40000000, &HFF000000}
	
	mBackBitmap As gdipBitmap
	mBackBlur As Integer = 0
	mBackEnabled As Boolean = True
	mBackImage As gdipImage
	mBackScale As Single = 1
	mBorderSize As Single = 1
	mByHeight As Boolean = True
	mCalendar As Lunar
	mCellHeight As Single
	mCellWidth As Single
	mControlHeight As Single
	mDay As Integer
	mDayCount As Integer
	mDayStart As Double
	mFontName As WString Ptr
	mFontSize As Single
	mForceUpdate As Boolean = True
	mHeight As Single
	mLineCount As Integer
	mMonth As Integer
	mMouseLocate As Integer = 0
	mMouseX As Single = -1
	mMouseY As Single = -1
	mOffsetY As Single = 1
	mOutlineEnabled As Boolean = True
	mOutlineSize As Single = 1
	mPanelEnabled As Boolean = True
	mSelectDate As Double
	mSelectDateX As Integer
	mSelectDateY As Integer
	mShowControls As Boolean
	mShowWeeks As Boolean
	mTrayEnabled As Boolean = True
	mUpdateBitmap As gdipBitmap
	mWeekStart As Integer
	mWeeksWidth As Single = 0
	mWidth As Single
	mYear As Integer
	
	Declare Constructor
	Declare Destructor
	Declare Function DataExpire(pWidth As Single, pHeight As Single, pSelectDate As Double) As Boolean
	Declare Function DateCalculate(pType As String, pAdd As Integer) As Double
	Declare Function ImageUpdate(pSelectDate As Double) As GpImage Ptr
	Declare Function MonthCalendar() As GpImage Ptr
	Declare Function XY2Date(x As Integer, y As Integer) As Double
	Declare Property FileName() ByRef As WString
	Declare Property FileName(ByRef fFileName As WString)
	Declare Sub Background(pWidth As Single, pHeight As Single, pSelectDate As Double)
End Type

#ifndef __USE_MAKE__
	#include once "gdipMonth.bas"
#endif
