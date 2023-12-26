' gdipText gdip文本
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

#include once "gdipText.bi"

Private Constructor gdipText
	Initial(400, 300)
End Constructor

Private Destructor gdipText
	Release()
	WDeAllocate(mFontName)
End Destructor

Private Sub gdipText.Initial(ByVal pWidth As Single = 400, ByVal pHeight As Single = 300)
	mWidth = pWidth
	mHeight = pHeight
	
	WLet(mFontName, WStr("Arial"))
	mUnitPixel = UnitPixel
	mFontStyle = FontStyleRegular
	mFontSize = 24
	mStringAlignment = StringAlignmentNear
	mFillMode = FillModeAlternate
	mBordyGradientMode = LinearGradientModeHorizontal
	mBordyWrapMode = WrapModeTile
End Sub

Private Sub gdipText.Release()
	If mStringFormat Then GdipDeleteStringFormat(mStringFormat)
	If mFontFamily Then GdipDeleteFontFamily(mFontFamily)
	If mFontHandle Then GdipDeleteFont(mFontHandle)
	If mPath Then GdipDeletePath(mPath)
	If mPen Then GdipDeletePen(mPen)
	If mBrush Then GdipDeleteBrush(mBrush)
	
	mStringFormat = NULL
	mFontFamily = NULL
	mFontHandle = NULL
	mPath = NULL
	mPen = NULL
	mBrush = NULL
End Sub

Private Sub gdipText.TextPath(pLeft As Single, pTop As Single, pText As WString, pPathInit As Boolean = False)
	MeasureString(pText)
	
	Dim mTextDRectF As GpRectF
	With mTextDRectF
		.X = pLeft
		.Y = pTop
		.Width = mTextWidth
		.Height = mTextHeight
	End With
	
	If pPathInit Then
		If mPath Then GdipDeletePath(mPath)
		GdipCreatePath(mFillMode, @mPath)
	End If
	GdipAddPathString(mPath, @pText, Len(pText), mFontFamily, mFontStyle, mFontSize, @mTextDRectF, mStringFormat)
End Sub

Private Sub gdipText.TextOut(pGraphics As GpGraphics Ptr, pText As WString, ByVal pLeft As Long = 0, ByVal pTop As Long = 0, ByVal pForeColor As ARGB = &HFF000000)
	MeasureString(pText)
	
	Dim mTextDRectF As GpRectF
	
	With mTextDRectF
		.X = pLeft
		.Y = pTop
		.Width = mTextWidth
		.Height = mTextHeight
	End With
	
	If mPath Then GdipDeletePath(mPath)
	GdipCreatePath(mFillMode, @mPath)
	GdipAddPathString(mPath, @pText, -1, mFontFamily, mFontStyle, mFontSize, @mTextDRectF, mStringFormat)
	
	If mBrush Then GdipDeleteBrush(mBrush)
	GdipCreateSolidFill(pForeColor, @mBrush)
	GdipFillPath(pGraphics, mBrush, mPath)
	
	If mPath Then GdipDeletePath(mPath)
	If mBrush Then GdipDeleteBrush(mBrush)
End Sub

Private Function gdipText.TextHeight(pText As WString) As Single
	MeasureString(pText)
	Return mTextHeight
End Function
Private Function gdipText.TextWidth(pText As WString) As Single
	MeasureString(pText)
	Return mTextWidth
End Function

Private Sub gdipText.MeasureString(pText As WString)
	Dim tmpBitmap As gdipBitmap
	tmpBitmap.Initial(mWidth, mHeight)
	If mStringFormat = NULL Then FontCreate()
	Dim BoundingBox As RectF
	With BoundingBox
		.X = 0
		.Y = 0
		.Width = 0
		.Height = 0
	End With
	
	Dim mTextDRectF As GpRectF
	With mTextDRectF
		.X = 0
		.Y = 0
		.Width = mWidth
		.Height = mHeight
	End With
	Dim As INT_ sWidth, sHeight
	'GetTextExtentPoint32
	GdipMeasureString(tmpBitmap.Graphics, @pText, Len(pText), mFontHandle, @mTextDRectF, mStringFormat, @BoundingBox, @sWidth, @sHeight)
	mTextWidth = BoundingBox.Width - BoundingBox.X
	mTextHeight = BoundingBox.Height - BoundingBox.Y
	'Print pText, mTextWidth, sWidth
	'mTextWidth = sWidth
	'mTextHeight = sHeight
End Sub

Private Sub gdipText.SetFont(pFontName As WString, pFontSize As REAL, pFontStyle As FontStyle)
	WLet(mFontName, pFontName)
	mFontSize = pFontSize
	mFontStyle = pFontStyle
	FontCreate()
End Sub

Private Sub gdipText.FontCreate()
	FontRelease()
	GdipCreateStringFormat(0, 0, @mStringFormat)
	GdipSetStringFormatAlign(mStringFormat, mStringAlignment)
	GdipCreateFontFamilyFromName(mFontName, 0, @mFontFamily)
	GdipCreateFont(mFontFamily, mFontSize, mFontStyle, mUnitPixel, @mFontHandle)
End Sub

Private Sub gdipText.FontRelease()
	If mStringFormat Then GdipDeleteStringFormat(mStringFormat)
	If mFontFamily Then GdipDeleteFontFamily(mFontFamily)
	If mFontHandle Then GdipDeleteFont(mFontHandle)
	
	mStringFormat = NULL
	mFontFamily = NULL
	mFontHandle = NULL
End Sub
