' gdipMonth
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "gdip.bi"
#include once "..\ChineseCalendar\Lunar.bi"

Type gdipMonth
	mCalendar As Lunar
	
	mTextBitmap As gdipBitmap
	mBackBitmap As gdipBitmap
	mBackEnabled As Boolean = True
	mBackScale As Single = 1
	mBackImage As gdipImage
	mBackAlpha As Single = &H80
	mBackBlur As Integer = 0
	
	mTrayBitmap As gdipBitmap
	mMonthBitmap As gdipBitmap
	mUpdateBitmap As gdipBitmap
	mTxt As gdipText

	mTrayEnabled As Boolean = True
	mTrayBlur As Integer = 0
	mTrayAlpha As Single = &HFF
	
	'显示第几周
	mShowWeeks As Boolean
	'显示控制
	mShowControls As Boolean
	'用高度计算
	mByHeight As Boolean = True
	'强制更新
	mForceUpdate As Boolean = True
	
	mColorStyle As Integer = 0
	mBackOpacity As Integer = &HE0
	mForeOpacity As Integer = &HFF
	mDisableOpacity As Integer = &H30
	mSelectOpacity As Integer = &H80
	mMouseOpacity As Integer = &H40
	mMouseX As Single = -1
	mMouseY As Single = -1
	mMouseLocate As Integer = 0
	mSelectDateX As Integer
	mSelectDateY As Integer
	mDay As Integer
	mMonth As Integer
	mYear As Integer
	'当月天数
	mDayCount As Integer
	'当月第一天星期几 (星期日为每周第一天)
	mWeekStart As Integer
	'行数
	mLineCount As Integer
	
	'选择日期
	mSelectDate As Double
	'当月第一天
	mDayStart As Double
	
	mOffsetY As Single = 1
	'格子高,宽
	mCellHeight As Single
	mCellWidth As Single
	'显示第几周的宽度
	mWeeksWidth As Single = 0
	mHeight As Single
	mWidth As Single
	mBorderSize As Single = 1
	mFontSize As Single
	mFontName As WString Ptr
	mControlHeight As Single
	
	'index            0     1     2     3     4     5     6     7     8
	mC(8) As UByte = {&h00, &h1f, &h3f, &h5f, &h7f, &h9f, &hbf, &hdf, &hff}
	
	mClr(Any) As ARGB
	
	Declare Constructor
	Declare Destructor
	Declare Property FileName(ByRef fFileName As WString)
	Declare Property FileName() ByRef As WString
	Declare Function XY2Date(x As Integer, y As Integer) As Double
	Declare Function DateCalculate(pType As String, pAdd As Integer) As Double
	Declare Function DataExpire(pWidth As Single, pHeight As Single, pSelectDate As Double) As Boolean
	Declare Sub Background(pWidth As Single, pHeight As Single, pSelectDate As Double)
	Declare Sub MonthCalendar()
	Declare Function ImageUpdate(pSelectDate As Double) As GpImage Ptr
End Type

#ifndef __USE_MAKE__
	#include once "gdipMonth.bas"
#endif
