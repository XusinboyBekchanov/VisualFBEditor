' Text Clock文字时钟
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "gdip.bi"
#include once "win\GdiPlus.bi"
#include once "vbcompat.bi"

Type TextClock
	mByHeight As Boolean
	
	mUpdateBitmap As gdipBitmap
	mUpdate As Boolean
	mBlur As Integer = 0
	
	mBackBitmap As gdipBitmap
	mBackEnabled As Boolean = False
	mBackScale As Single = 1
	mBackImage As gdipImage
	mBackFile As WString Ptr
	mBackAlpha As Single = &H80
	mBackBlur As Integer = 0
	
	mTrayBitmap As gdipBitmap
	mTrayEnabled As Boolean = False
	mTrayAlpha As ARGB = &H40
	mTrayColor As ARGB = &HFFFFFF
	
	mTxt As gdipText
	mTxtScale As Single = 1
	
	mWidth As Single
	mHeight As Single
	
	mColon As WString Ptr
	mDt As WString Ptr
	mW(4) As Single
	mH(1) As Single
	
	mFontName As WString Ptr
	mFontStyle As FontStyle = FontStyleBold
	mFontSize As Single
	mFontSize2 As Single
	
	mClockLeft As Single
	mClockTop As Single
	mClockWidth As Single
	mClockHeight As Single
	
	mShowSecond As Boolean = True
	mBlinkColon As Boolean = True
	
	mShadowEnabled As Boolean = True
	mShadowSize As Single = 0.03
	mShadowAlpha As ARGB = &HFF
	
	mGradientMode As LinearGradientMode = LinearGradientModeVertical
	mTextColor1 As ARGB = &HFF00FF
	mTextColor2 As ARGB = &H00FFFF
	mTextAlpha1 As ARGB = &HFF
	mTextAlpha2 As ARGB = &HFF
	mTextBlur As Integer = 0
	
	mBorderEnabled As Boolean = True
	mBorderAlpha As ARGB = &HFF
	mBorderColor As ARGB = &HFFFFFF
	mBorderSize As Single = 1
	
	mUnitPixel As Unit = UnitPixel
	
	mOutlineSize As Single = 1
	mOutlineColor As ARGB = &HBF3F7F
	
	Declare Property FileName(ByRef fFileName As WString)
	Declare Property FileName() ByRef As WString
	Declare Sub TextFont(pName As WString, pStyle As FontStyle)
	Declare Sub TextAlpha(ByVal pTextAlpha1 As ARGB = &HFF, ByVal pTextAlpha2 As ARGB = &HFF)
	Declare Sub TextColor(ByVal pTextColor1 As ARGB = &H000000, ByVal pTextColor2 As ARGB = &H000000)
	Declare Sub Background(ByVal pWidth As Single = 400, ByVal pHeight As Single = 300)
	Declare Sub CalculateSize()
	Declare Function DrawClock(ByVal pColon As Boolean = True) As GpImage Ptr
	Declare Function ImageUpdate() As GpImage Ptr
	Declare Constructor
	Declare Destructor
	Declare Sub Release()
End Type

#ifndef __USE_MAKE__
	#include once "gdipTextClock.bas"
#endif
