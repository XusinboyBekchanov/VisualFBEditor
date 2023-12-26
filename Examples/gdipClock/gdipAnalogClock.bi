' Analog Clock模拟时钟
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

#include once "gdip.bi"
#include once "win\GdiPlus.bi"
#include once "vbcompat.bi"

Type AnalogClock
	mBackBitmap As gdipBitmap
	mUpdateBitmap As gdipBitmap
	mTray As Boolean = True
	mHand As Boolean = True
	mScale As Boolean = True
	
	mText As Boolean = True
	mFontName As WString Ptr
	mFontColor As ARGB = &HFF000000
	mFontBold As Boolean = True
	
	mBackground As Boolean = False
	mBGScale As Single = 1
	mImgBack As gdipImage
	mFile As WString Ptr

	mFormat As WString Ptr
	
	mWidth As Single
	mHeight As Single
	
	Declare Property FileName(ByRef fFileName As WString)
	Declare Property FileName() ByRef As WString
	Declare Sub ImageInit(ByVal pWidth As Single = 300, ByVal pHeight As Single = 400, ByVal pAlpha As UByte = 255)
	Declare Function ImageUpdate(ByVal pAlpha As UByte = 255) As GpImage Ptr
	
	Declare Constructor
	Declare Destructor
	Declare Sub Release()
End Type

#ifndef __USE_MAKE__
	#include once "gdipAnalogClock.bas"
#endif
