' gdipText gdip文本
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "win\GdiPlus.bi"
#include once "gdip.bi"

Type gdipText
	mFontName As WString Ptr
	mFontSize As REAL
	mFontStyle As FontStyle

	mStringFormat As GpStringFormat Ptr
	mStringAlignment As StringAlignment
	mStringTrimming As StringTrimming
	mFontFamily As GpFontFamily Ptr
	mFontHandle As GpFont Ptr
	mUnitPixel As Unit = UnitPixel
	mFillMode As GpFillMode
	mTextWidth As Single
	mTextHeight As Single

	mWidth As Single
	mHeight As Single

	mPath As GpPath Ptr
	mPen As GpPen Ptr
	mBrush As Any Ptr
	
	mBordyGradientMode As LinearGradientMode
	mBordyWrapMode As GpWrapMode
	
	mBackBitmap As gdipBitmap
	mUpdateBitmap As gdipBitmap

	Declare Sub SetFont(pFontName As WString, pFontSize As REAL, pFontStyle As FontStyle)
	Declare Sub FontRelease()
	Declare Sub FontCreate()
	
	Declare Sub MeasureString(ByRef pText As WString)
	Declare Function TextHeight(ByRef pText As WString) As Single
	Declare Function TextWidth(ByRef pText As WString) As Single
	Declare Sub TextOut(pGraphics As GpGraphics Ptr, ByRef pText As WString, ByVal pLeft As Long = 0, ByVal pTop As Long = 0, ByVal pForeColor As ARGB = &HFF000000)
	Declare Sub TextPath(pLeft As Single, pTop As Single, ByRef pText As WString, pPathReset As Boolean = False)
	
	Declare Constructor
	Declare Destructor
	Declare Sub Initial(ByVal pWidth As Single = 400, ByVal pHeight As Single = 300)
	Declare Sub Release()
End Type

#ifndef __USE_MAKE__
	#include once "gdipText.bas"
#endif



