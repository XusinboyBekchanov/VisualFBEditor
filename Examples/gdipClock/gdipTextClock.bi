' Text Clock文字时钟
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

#include once "gdip.bi"
#include once "win\GdiPlus.bi"
#include once "vbcompat.bi"

Type TextClock
	mBackBitmap As gdipBitmap
	mUpdateBitmap As gdipBitmap
	
	mBackground As Boolean = False
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
	mOx As Single
	mOy As Single
	
	mShowSecond As Boolean = True
	mBlinkColon As Boolean = True
	mShowBorder As Boolean = True
	mShowShadow As Boolean = True
	mShadowSize As Single = 0.03
	
	mTextColor As ARGB = &HFFFF00FF
	mTextColor1 As ARGB = &HFF00FF00
	mBorderColor As ARGB = &HFFFFFFFF
	mBorderSize As Single = 0.03
	mUnitPixel As Unit = UnitPixel
	
	Declare Property FileName(ByRef fFileName As WString)
	Declare Property FileName() ByRef As WString
	Declare Sub TextColor(ByVal pTextColor As ARGB = &HFF000000, ByVal pTextColor1 As ARGB = &HFF000000)
	Declare Sub ImageInit(ByVal pWidth As Single = 400, ByVal pHeight As Single = 300, ByVal pAlpha As UByte = 255)
	Declare Sub CalculateSize()
	Declare Function DrawClock(ByVal pColon As Boolean = True, ByVal pAlpha As UByte = 255) As GpImage Ptr
	Declare Function ImageUpdate(ByVal pAlpha As UByte = 255) As GpImage Ptr
	Declare Constructor
	Declare Destructor
	Declare Sub Release()
End Type


Private Constructor TextClock
	WLet(mFontName, "Arial")
	WLet(mColon, ":")
	mTxt.mFontStyle = mFontStyle
End Constructor

Private Destructor TextClock
	If mFontName Then Deallocate mFontName
	mFontName = NULL
	If mFile Then Deallocate mFile
	mFile = NULL
	If mColon Then Deallocate mColon
	mColon = NULL
	If mDt Then Deallocate mDt
	mDt = NULL
End Destructor

Private Sub TextClock.Release()
	
End Sub

Private Property TextClock.FileName(ByRef fFileName As WString)
	WLet(mFile, fFileName)
	mImgBack.FromFile(*mFile)
	mBGScale = mImgBack.Height / mImgBack.Width
End Property
Private Property TextClock.FileName() ByRef As WString
	Return *mFile
End Property

Private Sub TextClock.ImageInit(ByVal pWidth As Single = 400, ByVal pHeight As Single = 300, ByVal pAlpha As UByte = 255)
	mWidth = pWidth
	mHeight = pHeight
	mTxt.Initial(mWidth, mHeight)
	mBackBitmap.Initlal(mWidth, mHeight)
	CalculateSize()
	If mBackground Then mBackBitmap.DrawImage(mImgBack.Image)
End Sub

Private Function TextClock.ImageUpdate(ByVal pAlpha As UByte = 255) As GpImage Ptr
	mUpdateBitmap.Initlal(mWidth, mHeight)
	
	mUpdateBitmap.DrawImage(mBackBitmap.Image)
	
	If VBTimerMS > 0.5 And mBlinkColon = True Then
		mUpdateBitmap.DrawImage(DrawClock(False, pAlpha), 0, 0)
	Else
		mUpdateBitmap.DrawImage(DrawClock(True, pAlpha), 0, 0)
	End If
	
	Return mUpdateBitmap.Image
End Function

Private Sub TextClock.CalculateSize()
	mUpdateBitmap.Initlal(mWidth, mHeight)
	
	If mShowSecond Then
		mFontSize = mWidth / 3.8        '时分字体大小
	Else
		mFontSize = mWidth / 2.9        '时分字体大小
	End If
	mTxt.SetFont(*mFontName, mFontSize, mFontStyle)
	mW(1) = mTxt.TextWidth("00")        '时宽度
	mW(2) = mTxt.TextWidth(*mColon) / 4 '冒号宽度, 不知道为啥一个冒号的宽度这么宽
	mH(0) = mTxt.TextHeight("00")       '整体高度
	mW(3) = mW(1)                       '分宽度
	
	If mShowSecond Then
		mFontSize2 = mFontSize / 2.8    '秒字体大小
		mTxt.SetFont(*mFontName, mFontSize2, mFontStyle)
		mW(4) = mTxt.TextWidth("WM")    '秒宽度
		mH(1) = mTxt.TextHeight("WM")   '秒高度
		mW(0) = mW(1) + mW(2) + mW(3) + mW(4)   '整体宽度
	Else
		mW(0) = mW(1) + mW(2) + mW(3)   '整体宽度
	End If
	
	mOx = (mWidth - mW(0)) / 2          'x偏移
	mOy = (mHeight - mH(0)) / 2         'y偏移
End Sub

Private Function TextClock.DrawClock(ByVal pColon As Boolean = True, ByVal pAlpha As UByte = 255) As GpImage Ptr
	Static sBitmap As gdipBitmap
	Static sBitmapSardow As gdipBitmap
	
	mTxt.SetFont(*mFontName, mFontSize, mFontStyle)
	'时
	WLet(mDt, Format(Hour(Now), "0"))
	Dim sofx As Single
	sofx = mTxt.TextWidth(*mDt)
	mTxt.TextPath(mOx + mW(1) - sofx, mOy, *mDt, True)

	'冒号
	sofx = mTxt.TextWidth(*mColon)
	If pColon Then mTxt.TextPath(mOx + mW(1) + (mW(2) - sofx) / 2, mOy, *mColon)

	'分
	WLet(mDt, Format(Minute(Now), "00"))
	mTxt.TextPath(mOx + mW(1) + mW(2), mOy, *mDt)
	
	If mShowSecond Then
		'上下午
		mTxt.SetFont(*mFontName, mFontSize2, mFontStyle)
		WLet(mDt, IIf(Hour(Now) > 12, "PM", "AM"))
		sofx = mTxt.TextWidth(*mDt)
		mTxt.TextPath(mOx + mW(1) * 2 + mW(2) + (mW(4) - sofx) / 2 , mOy + mH(0) / 2 - mH(1), *mDt)
		'秒
		WLet(mDt, Format(Second(Now), "00"))
		sofx = mTxt.TextWidth(*mDt)
		mTxt.TextPath(mOx + mW(1) * 2 + mW(2) + (mW(4) - sofx) / 2 , mOy + mH(0) / 2, *mDt)
	End If
	
	Dim sBrush As Any Ptr
	Dim sPen As GpPen Ptr
	Dim sBordyGradientMode As LinearGradientMode = LinearGradientModeHorizontal
	Dim sBordyWrapMode As GpWrapMode= WrapModeTile
	Dim sTextDRectF As GpRectF
	
	Dim sSize As Single = mFontSize * (mShadowSize + mBorderSize)

	With sTextDRectF
		.X = mOx - sSize
		.Y = mOy - sSize
		.Width = mW(0) + sSize
		.Height = mH(0) + sSize
		sBitmap.Initlal(.X + .Width, .Y + .Height)
	End With
	
	If mShowShadow Then
		sBitmapSardow.Initlal(mWidth, mHeight)
		GdipCreateLineBrushFromRect(@sTextDRectF, pAlpha Shl 24 Or &H000000, pAlpha Shl 24 Or &H000000, sBordyGradientMode, sBordyWrapMode, @sBrush)
		GdipFillPath(sBitmapSardow.Graphics, sBrush, mTxt.mPath)
		GdipDeleteBrush(sBrush)
		sBitmap.DrawImage(sBitmapSardow.Image, mFontSize * mShadowSize, mFontSize * mShadowSize)
		_GDIPlus_BitmapApplyFilter_FastBoxBlur(sBitmap.Image, mFontSize * mShadowSize)
	End If
	
	If mShowBorder Then
		GdipCreatePen1(mBorderColor, mFontSize * mBorderSize, mUnitPixel, @sPen)
		GdipDrawPath(sBitmap.Graphics, sPen, mTxt.mPath)
		GdipDeletePen(sPen)
	End If
	
	GdipCreateLineBrushFromRect(@sTextDRectF, pAlpha Shl 24 Or &HFFFFFF And mTextColor, pAlpha Shl 24 Or &HFFFFFF And mTextColor1, sBordyGradientMode, sBordyWrapMode, @sBrush)
	GdipFillPath(sBitmap.Graphics, sBrush, mTxt.mPath)
	GdipDeleteBrush(sBrush)
	
	Return sBitmap.Image
End Function

Private Sub TextClock.TextColor(ByVal pTextColor As ARGB = &HFF000000, ByVal pTextColor1 As ARGB = &HFF000000)
	mTextColor = pTextColor
	mTextColor1 = pTextColor1
End Sub

#ifndef __USE_MAKE__
	#include once "gdipTextClock.bas"
#endif
