' gdipText gdip文本
' Copyright (c) 2024 CM.Wang
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
	mStringTrimming = StringTrimmingNone
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

Private Sub gdipText.TextPath(pLeft As Single, pTop As Single, ByRef pText As WString, pPathReset As Boolean = False)
	MeasureString(pText)
	
	Dim mTextDRectF As GpRectF
	With mTextDRectF
		.X = pLeft
		.Y = pTop
		.Width = mTextWidth
		.Height = mTextHeight
	End With
	
	If pPathReset Then
		If mPath Then 
			GdipResetPath(mPath)
		Else
			GdipCreatePath(mFillMode, @mPath)
		End If
	End If
	If mPath = NULL Then GdipCreatePath(mFillMode, @mPath)
	GdipAddPathString(mPath, @pText, Len(pText), mFontFamily, mFontStyle, mFontSize, @mTextDRectF, mStringFormat)
End Sub

Private Sub gdipText.TextOut(pGraphics As GpGraphics Ptr, ByRef pText As WString, ByVal pLeft As Long = 0, ByVal pTop As Long = 0, ByVal pForeColor As ARGB = &HFF000000)
	MeasureString(pText)
	
	Dim sTextDRectF As GpRectF
	With sTextDRectF
		.X = pLeft
		.Y = pTop
		.Width = mTextWidth
		.Height = mTextHeight
	End With
	
	Dim sBrush As Any Ptr
	Dim sPath As GpPath Ptr
	GdipCreatePath(mFillMode, @sPath)
	GdipAddPathString(sPath, @pText, -1, mFontFamily, mFontStyle, mFontSize, @sTextDRectF, mStringFormat)
	GdipCreateSolidFill(pForeColor, @sBrush)
	GdipFillPath(pGraphics, sBrush, sPath)
	GdipDeletePath(sPath)
	GdipDeleteBrush(sBrush)
End Sub

Private Function gdipText.TextHeight(ByRef pText As WString) As Single
	MeasureString(pText)
	Return mTextHeight
End Function
Private Function gdipText.TextWidth(ByRef pText As WString) As Single
	MeasureString(pText)
	Return mTextWidth
End Function

Private Sub gdipText.MeasureString(ByRef pText As WString)
	Dim sTmpBitmap As gdipBitmap
	sTmpBitmap.Initial(mWidth, mHeight)
	
	If mStringFormat = NULL Then FontCreate()

	Dim layoutRect As RectF
	With layoutRect 
		.X = 0
		.Y = 0
		.Width = mWidth
		.Height = mHeight
	End With
	Dim As INT_ codepointsFitted, linesFilled

	Dim boundingBox As RectF
	With boundingBox
		.X = 0
		.Y = 0
		.Width = 0
		.Height = 0
	End With
	'GetTextExtentPoint32
	GdipMeasureString(sTmpBitmap.Graphics, @pText, Len(pText), mFontHandle, @layoutRect, mStringFormat, @boundingBox, @codepointsFitted, @linesFilled)
	mTextWidth = boundingBox.Width - boundingBox.X
	mTextHeight = boundingBox.Height - boundingBox.Y
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
