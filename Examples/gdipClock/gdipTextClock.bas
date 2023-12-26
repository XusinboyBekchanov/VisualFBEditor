' Text Clock文字时钟
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

#include once "gdipTextClock.bi"

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

Private Sub TextClock.TextFont(pName As WString, pStyle As FontStyle)
	WLet(mFontName, pName)
	mFontStyle = pStyle
End Sub

Private Sub TextClock.ImageInit(ByVal pWidth As Single = 400, ByVal pHeight As Single = 300, ByVal pAlpha As UByte = 255)
	mWidth = pWidth
	mHeight = pHeight
	mTxt.Initial(mWidth, mWidth)
	mBackBitmap.Initial(mWidth, mHeight)
	CalculateSize()
	mTrayBitmap.Initial(mClockWidth, mClockHeight)
	GdipGraphicsClear(mTrayBitmap.Graphics, &H404080F0)
	If mBackground Then mBackBitmap.DrawScaleImage(mImgBack.Image)
	If mTray Then mBackBitmap.DrawImage(mTrayBitmap.Image, mClockLeft, mClockTop)
	mUpdate= True
End Sub

Private Function TextClock.ImageUpdate(ByVal pAlpha As UByte = 255) As GpImage Ptr
	Static sTimer As Integer
	Static sMs As Boolean
	Dim dTimer As Integer = Int(VBTimer())
	
	If (mUpdate = True) Or (sTimer <> dTimer) Then
		sTimer = dTimer
		sMs = True
		mUpdateBitmap.Initial(mWidth, mHeight)
		mUpdateBitmap.DrawScaleImage(mBackBitmap.Image)
		mUpdateBitmap.DrawImage(DrawClock(True, pAlpha), 0, 0)
	Else
		If (mBlinkColon = True) And (sMs = True) And (VBTimerMS() > 0.5) Then
			sMs = False
			mUpdateBitmap.Initial(mWidth, mHeight)
			mUpdateBitmap.DrawScaleImage(mBackBitmap.Image)
			mUpdateBitmap.DrawImage(DrawClock(False, pAlpha), 0, 0)
		End If
	End If
	mUpdate = False
	Return mUpdateBitmap.Image
End Function

Private Sub TextClock.CalculateSize()
	mUpdateBitmap.Initial(mWidth, mHeight)
	
	If mShowSecond Then
		mFontSize = mWidth / 3.6        '时分字体大小
	Else
		mFontSize = mWidth / 3.1        '时分字体大小
	End If
	mTxt.SetFont(*mFontName, mFontSize, mFontStyle)
	mW(1) = mTxt.TextWidth("00")        '时宽度
	mW(2) = 0 'mTxt.TextWidth(*mColon) / 6 '冒号宽度, 不知道为啥一个冒号的宽度这么宽
	mH(0) = mTxt.TextHeight("00")       '整体高度
	mW(3) = mW(1)                       '分宽度
	
	If mShowSecond Then
		mFontSize2 = mFontSize / 2.5    '秒字体大小
		mTxt.SetFont(*mFontName, mFontSize2, mFontStyle)
		mW(4) = mTxt.TextWidth("IM")    '秒宽度
		mH(1) = mTxt.TextHeight("IM")   '秒高度
		mW(0) = mW(1) + mW(2) + mW(3) + mW(4)   '整体宽度
	Else
		mW(0) = mW(1) + mW(2) + mW(3)   '整体宽度
	End If
	
	mClockWidth = mW(0)
	mClockHeight = mH(0) * 0.9
	mClockLeft = (mWidth - mClockWidth) / 2     'x偏移
	mClockTop = (mHeight - mClockHeight) / 2    'y偏移
End Sub

Private Function TextClock.DrawClock(ByVal pColon As Boolean = True, ByVal pAlpha As UByte = 255) As GpImage Ptr
	Static sBitmap As gdipBitmap
	Static sBitmapSardow As gdipBitmap
	
	mTxt.SetFont(*mFontName, mFontSize, mFontStyle)
	'时
	WLet(mDt, Format(Hour(Now), "0"))
	Dim sofx As Single
	sofx = mTxt.TextWidth(*mDt)
	mTxt.TextPath(mClockLeft + mW(1) - sofx, mClockTop, *mDt, True)
	
	'冒号
	sofx = mTxt.TextWidth(*mColon)
	If pColon Then mTxt.TextPath(mClockLeft + mW(1) + (mW(2) - sofx) / 2, mClockTop, *mColon)
	
	'分
	WLet(mDt, Format(Minute(Now), "00"))
	mTxt.TextPath(mClockLeft + mW(1) + mW(2), mClockTop, *mDt)
	
	If mShowSecond Then
		'上下午
		mTxt.SetFont(*mFontName, mFontSize2, mFontStyle)
		WLet(mDt, IIf(Hour(Now) > 12, "PM", "AM"))
		sofx = mTxt.TextWidth(*mDt)
		mTxt.TextPath(mClockLeft + mW(1) * 2 + mW(2) + mW(4) / 3 - sofx / 2 , mClockTop + mH(0) / 2 - mH(1), *mDt)
		'秒
		WLet(mDt, Format(Second(Now), "00"))
		sofx = mTxt.TextWidth(*mDt)
		mTxt.TextPath(mClockLeft + mW(1) * 2 + mW(2) + mW(4) / 3 - sofx / 2 , mClockTop + mH(0) / 2 - mH(1) * 0.12, *mDt)
	End If
	
	Dim sBrush As Any Ptr
	Dim sPen As GpPen Ptr
	Dim sBordyGradientMode As LinearGradientMode = LinearGradientModeVertical ' LinearGradientModeHorizontal
	Dim sBordyWrapMode As GpWrapMode= WrapModeTile
	Dim sTextDRectF As GpRectF
	
	Dim sSize As Single = mFontSize * (mShadowSize + mBorderSize)
	
	With sTextDRectF
		.X = mClockLeft - sSize
		.Y = mClockTop - sSize
		.Width = mW(0) + sSize
		.Height = mH(0) + sSize
		sBitmap.Initial(.X + .Width, .Y + .Height)
	End With
	
	If mShowShadow Then
		sBitmapSardow.Initial(mWidth, mHeight)
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

