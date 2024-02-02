' Text Clock文字时钟
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "gdip.bi"
#include once "win\GdiPlus.bi"
#include once "vbcompat.bi"

Type TextClock
	mBackAlpha As Single = &H80
	mBackBitmap As gdipBitmap
	mBackBlur As Integer = 0
	mBackEnabled As Boolean = True
	mBackFile As WString Ptr
	mBackImage As gdipImage
	mBackScale As Single = 0
	mBlinkColon As Boolean = True
	mBlur As Integer = 0
	mBorderAlpha As ARGB = &HFF
	mBorderColor As ARGB = &HFFFFFF
	mBorderEnabled As Boolean = True
	mBorderSize As Single = 1
	mByHeight As Boolean
	mClockHeight As Single
	mClockLeft As Single
	mClockTop As Single
	mClockWidth As Single
	mColon As WString Ptr
	mDt As WString Ptr
	mFontName As WString Ptr
	mFontSize As Single
	mFontSize2 As Single
	mFontStyle As FontStyle = FontStyleBold
	mGradientMode As LinearGradientMode = LinearGradientModeVertical
	mH(1) As Single
	mHeight As Single
	mOutlineAlpha As ARGB = &HFF
	mOutlineColor As ARGB = &HBF3F7F
	mOutlineEnabled As Boolean = True
	mOutlineSize As Single = 1
	mPanelAlpha As ARGB = &H80
	mPanelColor As ARGB = &HFFFFFF
	mPanelEnabled As Boolean = True
	mShadowAlpha As ARGB = &HFF
	mShadowEnabled As Boolean = True
	mShadowSize As Single = 0.03
	mShowSecond As Boolean = True
	mTextAlpha1 As ARGB = &HFF
	mTextAlpha2 As ARGB = &HFF
	mTextBlur As Integer = 0
	mTextColor1 As ARGB = &HFF00FF
	mTextColor2 As ARGB = &H00FFFF
	mTxt As gdipText
	mTxtScale As Single = 1
	mUnitPixel As Unit = UnitPixel
	mUpdate As Boolean
	mUpdateBitmap As gdipBitmap
	mW(4) As Single
	mWidth As Single
	
	Declare Constructor
	Declare Destructor
	Declare Function DrawClock(ByVal pColon As Boolean = True) As GpImage Ptr
	Declare Function ImageUpdate() As GpImage Ptr
	Declare Property FileName() ByRef As WString
	Declare Property FileName(ByRef fFileName As WString)
	Declare Sub Background(ByVal pWidth As Single = 400, ByVal pHeight As Single = 300)
	Declare Sub CalculateSize()
	Declare Sub Release()
	Declare Sub TextAlpha(ByVal pTextAlpha1 As ARGB = &HFF, ByVal pTextAlpha2 As ARGB = &HFF)
	Declare Sub TextColor(ByVal pTextColor1 As ARGB = &H000000, ByVal pTextColor2 As ARGB = &H000000)
	Declare Sub TextFont(pName As WString, pStyle As FontStyle)
End Type

#ifndef __USE_MAKE__
	#include once "gdipTextClock.bas"
#endif
