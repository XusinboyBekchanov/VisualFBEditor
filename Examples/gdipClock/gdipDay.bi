' gdipDay
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "gdip.bi"
#include once "..\ChineseCalendar\Lunar.bi"

Type gdipDay
Public:
	mShowStyle As Integer = 0
	
	mMouseOpacity As Integer = &H40
	mMouseX As Integer = -1
	mMouseY As Integer = -1
	mMouseLocate As Integer = 0
	
	mBackOpacity As Integer = &HE0
	mForeOpacity As Integer = &HFF
	
	mBackBitmap As gdipBitmap
	mBackEnabled As Boolean = True
	mBackScale As Single = 1
	mBackImage As gdipImage

	mBackAlpha As Single = &H80
	mBackBlur As Integer = 0

	mTrayEnabled As Boolean = True
	mTrayBlur As Integer = 0
	mTrayAlpha As Single = &HFF
	
	mTrayBitmap As gdipBitmap
	mDayBitmap As gdipBitmap
	mUpdateBitmap As gdipBitmap
	mTxt As gdipText
	
	'强制更新
	mForceUpdate As Boolean = True
	
	mBorderSize As Single = 1
	mWidth As Single
	mHeight As Single
	mSelectDate As Double
	mByHeight As Boolean
	
	mW(0) As Single
	mH(3) As Single
	mOH(3) As Single
	mSplitXScale As Single = 0.4
	mOffsetX As Single
	
	'index            0     1     2     3     4     5     6     7     8
	mC(8) As UByte = {&h00, &h1f, &h3f, &h5f, &h7f, &h9f, &hbf, &hdf, &hff}
	
	mClr(10) As ARGB
	mFontSize As Single
	mFontName As WString Ptr
	mCalendar As Lunar
	
	Declare Constructor
	Declare Destructor
	Declare Property FileName(ByRef fFileName As WString)
	Declare Property FileName() ByRef As WString
	Declare Sub Background(pWidth As Single, pHeight As Single, pSelectDate As Double)
	Declare Sub DayCalendar()
	Declare Function DataExpire(pWidth As Single, pHeight As Single, pSelectDate As Double) As Boolean
	Declare Function ImageUpdate(pSelectDate As Double) As GpImage Ptr
End Type

#ifndef __USE_MAKE__
	#include once "gdipDay.bas"
#endif
