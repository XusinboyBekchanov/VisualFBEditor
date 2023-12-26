' Text Clock文字时钟
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

#include once "gdip.bi"
#include once "win\GdiPlus.bi"
#include once "vbcompat.bi"

Type TextClock
	mBackBitmap As gdipBitmap
	mUpdateBitmap As gdipBitmap
	mTrayBitmap As gdipBitmap
	
	mUpdate As Boolean
	
	mBackground As Boolean = False
	mTray As Boolean = True
	mBGScale As Single = 1
	mImgBack As gdipImage
	mFile As WString Ptr
	
	mTxt As gdipText
	
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
	mShowBorder As Boolean = True
	mShowShadow As Boolean = True
	mShadowSize As Single = 0.03
	
	mTextColor As ARGB = &HFFFF00FF
	mTextColor1 As ARGB = &HFF00FFFF
	mBorderColor As ARGB = &HFFFFFFFF
	mBorderSize As Single = 0.03
	mUnitPixel As Unit = UnitPixel
	
	Declare Property FileName(ByRef fFileName As WString)
	Declare Property FileName() ByRef As WString
	Declare Sub TextFont(pName As WString, pStyle As FontStyle)
	Declare Sub TextColor(ByVal pTextColor As ARGB = &HFF000000, ByVal pTextColor1 As ARGB = &HFF000000)
	Declare Sub ImageInit(ByVal pWidth As Single = 400, ByVal pHeight As Single = 300, ByVal pAlpha As UByte = 255)
	Declare Sub CalculateSize()
	Declare Function DrawClock(ByVal pColon As Boolean = True, ByVal pAlpha As UByte = 255) As GpImage Ptr
	Declare Function ImageUpdate(ByVal pAlpha As UByte = 255) As GpImage Ptr
	Declare Constructor
	Declare Destructor
	Declare Sub Release()
End Type

#ifndef __USE_MAKE__
	#include once "gdipTextClock.bas"
#endif
