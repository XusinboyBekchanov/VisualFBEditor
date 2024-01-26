' Text Clock文字时钟
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "gdipTextClock.bi"

Private Constructor TextClock
	WLet(mBackFile, "")
	WLet(mFontName, "Arial")
	WLet(mColon, ":")
	mTxt.mFontStyle = mFontStyle
End Constructor

Private Destructor TextClock
	If mFontName Then Deallocate mFontName
	mFontName = NULL
	If mBackFile Then Deallocate mBackFile
	mBackFile = NULL
	If mColon Then Deallocate mColon
	mColon = NULL
	If mDt Then Deallocate mDt
	mDt = NULL
End Destructor

Private Sub TextClock.Release()
	
End Sub

Private Property TextClock.FileName(ByRef fFileName As WString)
	If Dir(fFileName) = "" Then
		mBackScale = mTxtScale
	Else
		WLet(mBackFile, fFileName)
		mBackImage.ImageFile = *mBackFile
		mBackScale = mBackImage.Height / mBackImage.Width
	End If
End Property
Private Property TextClock.FileName() ByRef As WString
	If mBackFile Then
		Return *mBackFile
	Else
		Return ""
	End If
End Property

Private Sub TextClock.TextFont(pName As WString, pStyle As FontStyle)
	WLet(mFontName, pName)
	mFontStyle = pStyle
End Sub

Private Sub TextClock.Background(ByVal pWidth As Single = 400, ByVal pHeight As Single = 300)
	'If mHeight <> pHeight Then mByHeight = True
	'If mWidth <> pWidth Then mByHeight = False
	
	mWidth = pWidth
	mHeight = pHeight

	CalculateSize()

	Dim tmpBitmap As gdipBitmap
	
	mBackBitmap.Initial(mWidth, mHeight)
	If mBackEnabled Then
		tmpBitmap.Initial(mWidth, mHeight)
		tmpBitmap.DrawScaleImage(mBackImage.Image)
		If mBackBlur Then FastBoxBlurHV(tmpBitmap.Image, mBackBlur)
		mBackBitmap.DrawAlphaImage(tmpBitmap.Image, mBackAlpha)
	End If
	If mTrayEnabled Then
		mTrayBitmap.Initial(mWidth, mHeight)
		GdipGraphicsClear(mTrayBitmap.Graphics, mTrayAlpha Shl 24 Or mTrayColor)

		'外框线
		'Dim sPen As GpPen Ptr
		'GdipCreatePen1((mTrayAlpha Shl 24) Or mOutlineColor, mOutlineSize, UnitPixel, @sPen)
		'GdipDrawRectangle(mTrayBitmap.Graphics, sPen, 0, 0, mWidth, mHeight)
		'GdipDeletePen(sPen)
	End If
	
	mUpdate = True
End Sub

Private Function TextClock.ImageUpdate() As GpImage Ptr
	Static sTimer As Integer
	Static sBlink As Boolean
	Dim dTimer As Integer = Int(VBTimer())
	
	Dim sImg As gdipBitmap
	sImg.Initial(mWidth, mHeight)
	If (mUpdate = True) Or (sTimer <> dTimer) Then
		mUpdate = False
		sTimer = dTimer
		sBlink = IIf(mBlinkColon, True , False)
		mUpdateBitmap.Initial(mWidth, mHeight)
		If mTrayEnabled Then mUpdateBitmap.DrawImage(mTrayBitmap.Image, 0, 0)
		If mBackEnabled Then mUpdateBitmap.DrawScaleImage(mBackBitmap.Image)
		
		'绘制有冒号的文字时钟
		sImg.DrawImage(DrawClock(True), mClockLeft, mClockTop)
		If mTextBlur Then FastBoxBlurHV(sImg.Image, mTextBlur)
		mUpdateBitmap.DrawImage(sImg.Image, 0, 0)
		If mBlur Then FastBoxBlurHV(mUpdateBitmap.Image, mBlur)
	Else
		If (mBlinkColon = True) And (sBlink = True) And (VBTimerMS() > 0.5) Then
			sBlink = False
			mUpdateBitmap.Initial(mWidth, mHeight)
			If mTrayEnabled Then mUpdateBitmap.DrawImage(mTrayBitmap.Image, 0, 0)
			If mBackEnabled Then mUpdateBitmap.DrawScaleImage(mBackBitmap.Image)
			
			'绘制没有冒号的文字时钟
			sImg.DrawImage(DrawClock(False), mClockLeft, mClockTop)
			If mTextBlur Then FastBoxBlurHV(sImg.Image, mTextBlur)
			mUpdateBitmap.DrawImage(sImg.Image, 0, 0)
			If mBlur Then FastBoxBlurHV(mUpdateBitmap.Image, mBlur)
		End If
	End If
	Return mUpdateBitmap.Image
End Function

Private Sub TextClock.CalculateSize()
	mTxt.Initial(mWidth, mWidth)
	mUpdateBitmap.Initial(mWidth, mHeight)
	If mByHeight Then
		mFontSize = mHeight                 '时分字体大小
	Else
		If mShowSecond Then
			mFontSize = mWidth / 3.8        '时分字体大小
		Else
			mFontSize = mWidth / 2.8        '时分字体大小
		End If
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
	mTxtScale = mClockHeight / mClockWidth
	If mBackScale = 0 Then mBackScale = mTxtScale 
End Sub

Private Function TextClock.DrawClock(ByVal pColon As Boolean = True) As GpImage Ptr
	Static sBitmap As gdipBitmap
	Static sBitmapSardow As gdipBitmap
	
	mTxt.SetFont(*mFontName, mFontSize, mFontStyle)
	'时
	WLet(mDt, Format(Hour(Now), "0"))
	Dim sofx As Single
	sofx = mTxt.TextWidth(*mDt)
	mTxt.TextPath(mW(1) - sofx, 0, *mDt, True)
	
	'冒号
	sofx = mTxt.TextWidth(*mColon)
	If pColon Then mTxt.TextPath(mW(1) + (mW(2) - sofx) / 2, 0, *mColon)
	
	'分
	WLet(mDt, Format(Minute(Now), "00"))
	mTxt.TextPath(mW(1) + mW(2), 0, *mDt)
	
	If mShowSecond Then
		'上下午
		mTxt.SetFont(*mFontName, mFontSize2, mFontStyle)
		WLet(mDt, IIf(Hour(Now) > 12, "PM", "AM"))
		sofx = mTxt.TextWidth(*mDt)
		mTxt.TextPath(mW(1) * 2 + mW(2) + mW(4) / 3 - sofx / 2 , mH(0) / 2 - mH(1), *mDt)
		'秒
		WLet(mDt, Format(Second(Now), "00"))
		sofx = mTxt.TextWidth(*mDt)
		mTxt.TextPath(mW(1) * 2 + mW(2) + mW(4) / 3 - sofx / 2 , mH(0) / 2 - mH(1) * 0.12, *mDt)
	End If
	
	Dim sBrush As Any Ptr
	Dim sPen As GpPen Ptr
	Dim sBordyGradientMode As LinearGradientMode = LinearGradientModeVertical ' LinearGradientModeHorizontal
	Dim sBordyWrapMode As GpWrapMode= WrapModeTile
	Dim sTextDRectF As GpRectF
	
	With sTextDRectF
		.X = 0 ' - sSize
		.Y = 0 ' - sSize
		.Width = mClockWidth ' + sSize
		.Height = mClockHeight ' + sSize
	End With
	sBitmap.Initial(mClockWidth, mClockHeight)
	
	If mShadowEnabled Then
		sBitmapSardow.Initial(mClockWidth, mClockHeight)
		GdipCreateLineBrushFromRect(@sTextDRectF, mTextAlpha1 Shl 24 Or &H000000, mTextAlpha2 Shl 24 Or &H000000, sBordyGradientMode, sBordyWrapMode, @sBrush)
		GdipFillPath(sBitmapSardow.Graphics, sBrush, mTxt.mPath)
		GdipDeleteBrush(sBrush)
		sBitmap.DrawImage(sBitmapSardow.Image, mFontSize * mShadowSize, mFontSize * mShadowSize)
		FastBoxBlurHV(sBitmap.Image, mFontSize * mShadowSize)
	End If
	
	GdipCreateLineBrushFromRect(@sTextDRectF, mTextAlpha1 Shl 24 Or mTextColor1, mTextAlpha2 Shl 24 Or mTextColor2, mGradientMode, sBordyWrapMode, @sBrush)
	GdipFillPath(sBitmap.Graphics, sBrush, mTxt.mPath)
	
	If mBorderEnabled Then
		GdipCreatePen1(mBorderAlpha Shl 24 Or mBorderColor, mBorderSize, mUnitPixel, @sPen)
		GdipDrawPath(sBitmap.Graphics, sPen, mTxt.mPath)
		GdipDeletePen(sPen)
	End If
	
	GdipDeleteBrush(sBrush)
	
	Return sBitmap.Image
End Function

Private Sub TextClock.TextAlpha(ByVal pTextAlpha1 As ARGB = &HFF, ByVal pTextAlpha2 As ARGB = &HFF)
	mTextAlpha1 = pTextAlpha1
	mTextAlpha2 = pTextAlpha2
End Sub
Private Sub TextClock.TextColor(ByVal pTextColor1 As ARGB = &H000000, ByVal pTextColor2 As ARGB = &H000000)
	mTextColor1 = pTextColor1
	mTextColor2 = pTextColor2
End Sub

