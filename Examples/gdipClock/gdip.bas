' gdip
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

#include once "gdip.bi"
#include once "gdipText.bi"
#include once "gdipForm.bi"

Private Constructor gdipToken
	Initial()
End Constructor

Private Destructor gdipToken
	Release()
End Destructor

Private Sub gdipToken.Initial()
	'初始化GDI+函数库
	If mToken Then Exit Sub
	Dim uInput As GdiplusStartupInput
	uInput.GdiplusVersion = 1
	GdiplusStartup(@mToken, @uInput, NULL)
End Sub

Private Sub gdipToken.Release()
	'清理GDI+使用过的资源
	If mToken = 0 Then Exit Sub
	GdiplusShutdown mToken
	mToken = NULL
End Sub

Private Constructor gdipDC(ByVal phWnd As HANDLE = 0)
	Initial(phWnd)
End Constructor

Private Destructor gdipDC
	Release()
End Destructor

Private Property gdipDC.DC() As HDC
	Return mDC
End Property

Private Sub gdipDC.Initial(ByVal phWnd As HANDLE = 0, ByVal pWidth As Single = 400, ByVal pHeight As Single = 300)
	Release()
	If phWnd Then
		mHWND = phWnd
		mDC = GetDC(phWnd)
	Else
		mDC = CreateCompatibleDC(0)
		mDtHWND = GetDesktopWindow()
		mDtDC = GetDC(mDtHWND)
		mBitmap = CreateCompatibleBitmap(mDtDC, pWidth, pHeight)
		mOldDC = SelectObject(mDC, mBitmap)
	End If
End Sub

Private Sub gdipDC.Release()
	If mBitmap Then
		DeleteObject(mBitmap)
		mBitmap = NULL
	End If
	
	If mOldDC Then
		SelectObject(0, mOldDC)
		DeleteObject(mOldDC)
		mOldDC = NULL
	End If
	
	If mDC Then
		DeleteDC(mDC)
		ReleaseDC(0, mDC)
		mDC = NULL
	End If
	
	If mDtDC Then
		DeleteDC(mDtDC)
		ReleaseDC(0, mDtDC)
		mDtDC = NULL
	End If
End Sub

Private Constructor gdipGraphics(ByVal pDC As HDC = 0, ByVal pClear As Boolean = False)
	Initial(pDC)
End Constructor

Private Destructor gdipGraphics
	Release()
End Destructor

Private Sub gdipGraphics.Initial(ByVal pDC As HDC = 0, ByVal pClear As Boolean = False)
	Release()
	If pDC Then
		GdipCreateFromHDC(pDC, @mGraphics)
		GdipSetSmoothingMode(mGraphics, SmoothingModeAntiAlias)
		GdipSetPixelOffsetMode(mGraphics, PixelOffsetModeHighQuality)
		GdipSetTextRenderingHint(mGraphics, TextRenderingHintAntiAlias)
		
		If pClear Then GdipGraphicsClear(mGraphics, mBackColor)
	End If
End Sub

Private Sub gdipGraphics.Release()
	If mGraphics Then
		GdipDeleteGraphics(mGraphics)
		mGraphics = NULL
	End If
End Sub

Private Property gdipGraphics.Graphics() As GpGraphics Ptr
	Return mGraphics
End Property

Private Sub gdipGraphics.DrawImage(pImage As GpImage Ptr, pX As Single = 0, pY As Single = 0)
	Dim As Single sWidth, sHeight
	GdipGetImageDimension(pImage, @sWidth, @sHeight)
	GdipDrawImageRect(mGraphics, pImage, pX, pY, sWidth, sHeight)
End Sub

Private Constructor gdipImage
	
End Constructor

Private Destructor gdipImage
	Release()
End Destructor

Private Sub gdipImage.Release
	'释放图像资源
	If mImage Then
		GdipDisposeImage(mImage)
		mImage = NULL
	End If
	
	If mResizedImage Then
		GdipDisposeImage(mResizedImage)
		mResizedImage = NULL
	End If
End Sub

Private Function gdipImage.FromFile(ImageFile As WString) As GpImage Ptr
	Dim pImage As GpImage Ptr
	GdipLoadImageFromFile(@ImageFile, @pImage)
	Image = pImage
	Return pImage
End Function

Private Property gdipImage.Height As Single
	Return mHeight
End Property

Private Property gdipImage.Width As Single
	Return mWidth
End Property

Private Property gdipImage.Image(pImage As GpImage Ptr)
	Release()
	mImage= pImage
	If mImage Then
		GdipGetImageDimension(mImage, @mWidth, @mHeight)
	End If
End Property

Private Property gdipImage.Image As GpImage Ptr
	Return mImage
End Property

Private Function gdipImage.Resize(pNewWidth As Single, pNewHeight As Single) As GpImage Ptr
	'返回拉伸后的mImage
	'注意需要手动释放GdipDisposeImage(mResizedImage)
	
	Dim fGraphics As GpGraphics Ptr
	'准备画布和位图
	GdipCreateBitmapFromScan0(pNewWidth, pNewHeight, 0, PixelFormat32bppARGB, 0, @mResizedImage)
	GdipGetImageGraphicsContext(mResizedImage, @fGraphics)
	
	'创建一个缩放矩阵
	Dim fMatrix As GpMatrix Ptr
	GdipCreateMatrix(@fMatrix)
	GdipScaleMatrix(fMatrix, pNewWidth / mWidth, pNewHeight / mHeight, 0)
	GdipSetWorldTransform(fGraphics, fMatrix)
	'绘制缩放后的图像
	GdipDrawImageRect(fGraphics, mImage, 0, 0, mWidth, mHeight)
	
	GdipDeleteGraphics(fGraphics)
	GdipDeleteMatrix(fMatrix)
	
	Return mResizedImage
End Function

'https://lotsacode.wordpress.com/2010/12/08/fast-blur-box-blur-With-accumulator/
Sub _GDIPlus_BitmapApplyFilter_FastBoxBlur(ByVal hImage As GpImage Ptr, range As ULong)
	If hImage = NULL Then Exit Sub
	If (range Mod 2) = 0 Then range += 1
	FastBoxBlurH(hImage, range)
	FastBoxBlurV(hImage, range)
End Sub

'https://lotsacode.wordpress.com/2010/12/08/fast-blur-box-blur-With-accumulator/
Sub FastBoxBlurH(hImage As GpImage Ptr, range As ULong)
	Dim As Single w, h
	GdipGetImageDimension(hImage, @w, @h)
	
	Dim As BitmapData tBitmapData
	Dim As GpRect tRect = Type(0, 0, w, h)
	
	Dim As Long halfRange = range \ 2, index = 0, NewColors(0 To w), hits, a, r, g, b, oldPixel, col, newPixel
	
	GdipBitmapLockBits(Cast(GpBitmap Ptr, hImage), @tRect, ImageLockModeRead Or ImageLockModeWrite, PixelFormat32bppARGB, @tBitmapData)
	For y As UInteger = 0 To h - 1
		a = 0
		r = 0
		g = 0
		b = 0
		hits = 0
		For x As Integer = -halfRange To w - 1
			oldPixel = x - halfRange - 1
			If oldPixel >= 0 Then
				col = Cast(ULong Ptr, tBitmapData.Scan0)[index + oldPixel]
				If col <> 0 Then
					a -= CUByte(col Shr 24)
					r -= CUByte(col Shr 16)
					g -= CUByte(col Shr 8)
					b -= CUByte(col)
				End If
				hits -= 1
			End If
			newPixel = x + halfRange
			If newPixel < w Then
				col = Cast(ULong Ptr, tBitmapData.Scan0)[index + newPixel]
				If col <> 0 Then
					a += CUByte(col Shr 24)
					r += CUByte(col Shr 16)
					g += CUByte(col Shr 8)
					b += CUByte(col)
				End If
				hits += 1
			End If
			If x >= 0 Then
				NewColors(x) = (CUByte(a / hits) Shl 24) Or (CUByte(r / hits) Shl 16) Or (CUByte(g / hits) Shl 8) Or CUByte(b / hits)
			End If
		Next
		For x As UInteger = 0 To w - 1
			Cast(ULong Ptr, tBitmapData.Scan0)[index + x] = NewColors(x)
		Next
		index += w
	Next
	GdipBitmapUnlockBits(Cast(GpBitmap Ptr, hImage), @tBitmapData)
End Sub

'https://lotsacode.wordpress.com/2010/12/08/fast-blur-box-blur-With-accumulator/
Sub FastBoxBlurV(hImage As GpImage Ptr, range As ULong)
	Dim As Single w, h
	GdipGetImageDimension(hImage, @w, @h)
	
	Dim As BitmapData tBitmapData
	Dim As GpRect tRect = Type(0, 0, w, h)
	
	Dim As Long halfRange = range \ 2, index, NewColors(0 To h), hits, a, r, g, b, oldPixel, col, newPixel, _
	oldPixelOffset = -(halfRange + 1) * w, newPixelOffset = (halfRange) * w
	
	GdipBitmapLockBits(Cast(GpBitmap Ptr, hImage), @tRect, ImageLockModeRead Or ImageLockModeWrite, PixelFormat32bppARGB, @tBitmapData)
	For x As UInteger = 0 To w - 1
		hits = 0
		a = 0
		r = 0
		g = 0
		b = 0
		index = -halfRange * w + x
		For y As Integer = -halfRange To h - 1
			oldPixel = y - halfRange - 1
			If oldPixel >= 0 Then
				col = Cast(ULong Ptr, tBitmapData.Scan0)[index + oldPixelOffset]
				If col <> 0 Then
					a -= CUByte(col Shr 24)
					r -= CUByte(col Shr 16)
					g -= CUByte(col Shr 8)
					b -= CUByte(col)
				End If
				hits -= 1
			End If
			newPixel = y + halfRange
			If newPixel < h Then
				col = Cast(ULong Ptr, tBitmapData.Scan0)[index + newPixelOffset]
				If col <> 0 Then
					a += CUByte(col Shr 24)
					r += CUByte(col Shr 16)
					g += CUByte(col Shr 8)
					b += CUByte(col)
				End If
				hits += 1
			End If
			If y >= 0 Then
				NewColors(y) = (CUByte(a / hits) Shl 24) Or (CUByte(r / hits) Shl 16) Or (CUByte(g / hits) Shl 8) Or CUByte(b / hits)
			End If
			index += w
		Next
		For y As UInteger = 0 To h - 1
			Cast(ULong Ptr, tBitmapData.Scan0)[y * w + x] = NewColors(y)
		Next
	Next
	GdipBitmapUnlockBits(Cast(GpBitmap Ptr, hImage), @tBitmapData)
End Sub

Private Function VBTimerMS() As Double
	'获取标准时间
	Dim As SYSTEMTIME sysTime, locTime
	GetSystemTime(@sysTime)
	'换算成本地时间
	Dim As TIME_ZONE_INFORMATION tizTime
	GetTimeZoneInformation(@tizTime)
	SystemTimeToTzSpecificLocalTime(@tizTime, @sysTime, @locTime)
	Return locTime.wMilliseconds / 1000
End Function

Private Function VBTimer() As Double
	'获取标准时间
	Dim As SYSTEMTIME sysTime, locTime
	GetSystemTime(@sysTime)
	'换算成本地时间
	Dim As TIME_ZONE_INFORMATION tizTime
	GetTimeZoneInformation(@tizTime)
	SystemTimeToTzSpecificLocalTime(@tizTime, @sysTime, @locTime)
	'凌晨开始的秒数
	Return locTime.wHour * 3600 + locTime.wMinute* 60 + locTime.wSecond + locTime.wMilliseconds / 1000
End Function

Private Function AnalogClockText(fWidth As Single, fHeight As Single, fName As WString, fBold As Boolean, ByVal fColor As ARGB = &h000000, ByVal fAlpha As UByte= 255) As Any Ptr
	Dim fTimeFormat As String = "h:mm:ss"
	Dim fFontSize As Single = 0.125
	Dim fOffsetX As Single = 1 
	Dim fOffsetY As Single = 1.4
	
	Static tmpBitmap As gdipBitmap
	tmpBitmap.Initial(fWidth, fHeight)
	
	Dim tmpTxt As gdipText
	tmpTxt.Initial(fWidth, fHeight)
	tmpTxt.SetFont(fName, fWidth * fFontSize, IIf(fBold, FontStyleBold, FontStyleRegular))

	Dim sx As Single = (fWidth - tmpTxt.TextWidth(Format(Now, fTimeFormat))) / 2 * fOffsetX
	Dim sy As Single = (fHeight - tmpTxt.TextHeight(Format(Now, fTimeFormat))) / 2 * fOffsetY

	tmpTxt.TextOut(tmpBitmap.Graphics, Format(Now, fTimeFormat), sx, sy, fAlpha Shl 24 Or fColor)
	Return tmpBitmap.Image
End Function

Private Function AnalogClockHand(fWidth As Single, fHeight As Single, ByVal fAlpha As UByte = 255, ByVal fOfsCenterX As Single = 0, ByVal fOfsCenterY As Single = 0, ByVal fScale As Single = 1) As Any Ptr
	Dim As Any Ptr hGfx
	Dim As Any Ptr hBitmap
	
	Dim ph As GpPen Ptr
	Dim pm As GpPen Ptr
	Dim ps As GpPen Ptr
	Dim pBshHur As Any Ptr
	Dim pBshMin As Any Ptr
	Dim pBshSec As Any Ptr
	Dim pBshDot As Any Ptr
	
	Dim hc As ARGB = fAlpha Shl 24 Or &H00FF00
	Dim mc As ARGB = fAlpha Shl 24 Or &H0000FF
	Dim sc As ARGB = fAlpha Shl 24 Or &HFF0000
	
	'时针大小
	Dim As Single sh = 0.08 * fScale
	'分针大小
	Dim As Single sm = 0.06 * fScale
	'秒针大小
	Dim As Single ss = 0.02 * fScale
	
	'时针后端偏移
	Dim As Single oh = 0.15 * fScale
	'分针后端偏移
	Dim As Single om = 0.15 * fScale
	'秒针后端偏移
	Dim As Single os = 0.2 * fScale
	
	'时针前端长度%
	Dim As Single mh = 0.6 * fScale
	'分针前端长度%
	Dim As Single mm = 0.65 * fScale
	'秒针前端长度%
	Dim As Single ms = 0.85 * fScale
	
	Dim pi As Double= Atn(1) * 4
	
	'准备画布和位图
	GdipCreateBitmapFromScan0(fWidth, fHeight, 0, PixelFormat32bppARGB, 0, @hBitmap)
	GdipGetImageGraphicsContext(hBitmap, @hGfx)
	GdipSetSmoothingMode(hGfx, 4)
	GdipSetPixelOffsetMode(hGfx, 4)
	GdipSetTextRenderingHint(hGfx, 4)
	
	'绘制指针时钟
	Dim centerX As Single = fWidth / 2 + fOfsCenterX
	Dim centerY As Single = fHeight / 2 + fOfsCenterY
	
	GdipCreatePen1(hc, centerX * sh, UnitPixel, @ph)
	GdipCreatePen1(mc, centerX * sm, UnitPixel, @pm)
	GdipCreatePen1(sc, centerX * ss, UnitPixel, @ps)
	
	Dim p1 As GpPointF, p2 As GpPointF
	p1.X = 0
	p1.Y = 0
	p2.X = 100
	p2.Y = 100
	GdipCreateLineBrush(@p1, @p2, hc, hc, WrapModeTileFlipXY, @pBshHur)
	GdipCreateLineBrush(@p1, @p2, mc, mc, WrapModeTileFlipXY, @pBshMin)
	GdipCreateLineBrush(@p1, @p2, sc, sc, WrapModeTileFlipXY, @pBshSec)
	GdipCreateLineBrush(@p1, @p2, fAlpha Shl 24 Or &HFFFFFF, fAlpha Shl 24 Or &HFFFFFF, WrapModeTileFlipXY, @pBshDot)
	
	Dim currentTime As Double= VBTimer()
	Dim tmH As Double, tmM As Double, tmS As Double
	
	'时
	tmH = currentTime / 3600
	'分
	tmM = currentTime / 60 - Fix(tmH) * 60
	'秒
	tmS = currentTime - Fix(tmH) * 3600 + Fix(tmM) * 60
	
	'换算成角度
	Dim aHour As Double, aMin As Double, aSec As Double
	aHour = pi / 2 - tmH / 12 * 2 * pi
	aMin = pi / 2 - tmM / 60 * 2 * pi
	aSec = pi / 2 - tmS / 60 * 2 * pi
	
	GdipDrawLine(hGfx, ph, centerX - centerX * oh * Cos(aHour), centerY + centerY * oh * Sin(aHour), centerX + (centerX * mh) * Cos(aHour), centerY - (centerY * mh) * Sin(aHour))
	'GdipFillEllipse(hGfx, pBshHur, centerX - 20, centerY - 20, 40, 40) '绘制椭圆
	GdipDrawLine(hGfx, pm, centerX - centerX * om * Cos(aMin), centerY + centerY * om * Sin(aMin), centerX + (centerX * mm) * Cos(aMin), centerY - (centerY * mm) * Sin(aMin))
	'GdipFillEllipse(hGfx, pBshMin, centerX - 13, centerY - 13, 26, 26) '绘制椭圆
	GdipDrawLine(hGfx, ps, centerX - centerX * os * Cos(aSec), centerY + centerY * os * Sin(aSec), centerX + (centerX * ms) * Cos(aSec), centerY - (centerY* ms) * Sin(aSec))
	
	GdipFillEllipse(hGfx, pBshSec, centerX - centerX * (sh + ss) / 2 , centerY - centerX * (sh + ss) / 2 , centerX * (sh + ss), centerX * (sh + ss)) '绘制椭圆
	GdipFillEllipse(hGfx, pBshDot, centerX - centerX * sm / 2, centerY - centerX * sm / 2, centerX * sm, centerX * sm) '绘制椭圆
	
	'清除绘画
	'Dim fPath As GpPath Ptr
	'GdipCreatePath(FillModeAlternate, @fPath)
	'GdipAddPathEllipse(fPath, centerX - centerX * sm / 2, centerY - centerX * sm / 2, centerX * sm, centerX * sm)
	'GdipSetClipPath(hGfx, fPath, CombineModeReplace)
	'GdipGraphicsClear(hGfx, 0)
	'GdipDeletePath(fPath)
	'GdipResetClip(hGfx)
	
	GdipDeletePen(ph)
	GdipDeletePen(pm)
	GdipDeletePen(ps)
	
	GdipDeleteBrush(pBshHur)
	GdipDeleteBrush(pBshMin)
	GdipDeleteBrush(pBshSec)
	GdipDeleteBrush(pBshDot)
	GdipDeleteGraphics(hGfx)
	
	Return hBitmap
End Function

'绘制表盘, 参考GDI+ Swiss Railway Clock, Coded by UEZ
'https://www.freebasic.net/forum/viewtopic.php?t=26454
Private Function AnalogClockPanel(fDiameter As Single, ByVal fAlpha As UByte = 255) As Any Ptr
	Dim As Any Ptr hGfx
	Dim As Any Ptr hBitmap, hBrush, hBrushL, hBrushLB, hPen, hPenL, hFamily, hStringFormat, hFont, hMatrix
	Dim As Single fBorderSize = fDiameter * 0.03333
	Dim As Single fSize = fDiameter * 0.9475 - fBorderSize / 2, fRadius = fDiameter / 2, fShadow_vx = fDiameter * 0.0095, fShadow_vy = fDiameter * 0.01
	Dim As GpPointF tPoint1, tPoint2
	
	Dim As Single fPi, fRad, fDeg
	fPi = Acos(-1)
	fRad = fPi / 180
	fDeg = 180 / fPi
	Dim As Single fShadowAngle
	
	'准备画布和位图
	GdipCreateBitmapFromScan0(fDiameter, fDiameter, 0, PixelFormat32bppARGB, 0, @hBitmap)
	GdipGetImageGraphicsContext(hBitmap, @hGfx)
	GdipSetSmoothingMode(hGfx, 4)
	GdipSetPixelOffsetMode(hGfx, 4)
	GdipSetTextRenderingHint(hGfx, 4)
	
	tPoint1.X = fBorderSize
	tPoint1.Y = fBorderSize
	tPoint2.X = fSize
	tPoint2.Y = fSize
	GdipCreateLineBrush(@tPoint1, @tPoint2, fAlpha Shl 24 Or &hFFFFFF, fAlpha Shl 24 Or &hB0B0B0, 3, @hBrushLB)
	
	GdipSetLineSigmaBlend(hBrushLB, 0.5, 0.85)
	
	GdipCreateMatrix(@hMatrix)
	GdipTranslateMatrix(hMatrix, fSize * 2, fSize * 2, 1)
	GdipRotateMatrix(hMatrix, 90, 1)
	GdipTranslateMatrix(hMatrix, -fSize * 2, -fSize * 2, 1)
	GdipMultiplyLineTransform(hBrushLB, hMatrix, 0)
	GdipDeleteMatrix(hMatrix)
	
	'填充表盘底色
	GdipFillEllipse(hGfx, hBrushLB, fBorderSize, fBorderSize, fSize, fSize)
	
	'绘制表盘阴影
	fShadowAngle = Atn(fShadow_vy / fShadow_vx) * fDeg
	If fShadow_vx < 0 And fShadow_vy >= 0 Then fShadowAngle += 180
	If fShadow_vx < 0 And fShadow_vy < 0 Then fShadowAngle -= 180
	GdipCreatePen1((fAlpha And &h90) Shl 24 Or &h000000, fBorderSize, 2, @hPen)
	GdipDrawEllipse(hGfx, hPen, fBorderSize + fShadow_vx, fBorderSize + fShadow_vy, fSize, fSize)
	'阴影模糊处理
	_GDIPlus_BitmapApplyFilter_FastBoxBlur(hBitmap, fDiameter * 0.02)
	
	'绘制表盘边缘
	tPoint1.X = 0
	tPoint1.Y = 0
	tPoint2.X = fSize
	tPoint2.Y = fSize
	GdipCreateLineBrush(@tPoint1, @tPoint2, fAlpha Shl 24 Or &hFFFFFFF, fAlpha Shl 24 Or &h000000, 3, @hBrushL)
	GdipSetLineSigmaBlend(hBrushL, 0.6, 1.0)
	GdipSetLineGammaCorrection(hBrushL, True)
	GdipCreatePen2(hBrushL, fBorderSize, UnitPixel, @hPenL)
	GdipDrawEllipse(hGfx, hPenL, fBorderSize, fBorderSize, fSize, fSize)
	
	'绘制表盘刻度
	GdipCreateSolidFill(fAlpha Shl 24 Or &h000000, @hBrush)
	
	'刻度距离边缘
	Dim As Single fPosY = fDiameter / 11
	'粗刻度
	Dim As Single iWidth1 = fDiameter / 48, iHeight1 = fDiameter / 15, iWidth12 = iWidth1 / 2
	'细刻度
	Dim As Single iWidth2 = fDiameter / 100, iHeight2 = fDiameter / 25, iWidth22 = iWidth2 / 2
	
	GdipTranslateWorldTransform(hGfx, fRadius, fRadius, 0)
	GdipRotateWorldTransform(hGfx, -6.0, MatrixOrderPrepend)
	GdipTranslateWorldTransform(hGfx, -fRadius, -fRadius, 0)
	For i As UByte = 0 To 59
		GdipTranslateWorldTransform(hGfx, fRadius, fRadius, 0)
		GdipRotateWorldTransform(hGfx, 6.0, MatrixOrderPrepend)
		GdipTranslateWorldTransform(hGfx, -fRadius, -fRadius, 0)
		If (i Mod 5) = 0 Then
			'绘制粗刻度
			GdipFillRectangle(hGfx, hBrush, fRadius - iWidth12, fPosY, iWidth1, iHeight1)
		Else
			'绘制细刻度
			GdipFillRectangle(hGfx, hBrush, fRadius - iWidth22, fPosY, iWidth2, iHeight2)
		End If
	Next
	GdipResetWorldTransform(hGfx)
	
	GdipDeleteFont(hFont)
	GdipDeleteFontFamily(hFamily)
	GdipDeleteStringFormat(hStringFormat)
	GdipDeleteBrush(hBrush)
	GdipDeleteBrush(hBrushL)
	GdipDeleteBrush(hBrushLB)
	GdipDeletePen(hPen)
	GdipDeletePen(hPenL)
	GdipDeleteGraphics(hGfx)
	
	Return hBitmap
End Function

Private Function AnalogClockTray(fDiameter As Single, ByVal fAlpha As UByte = 255) As Any Ptr
	Dim As Any Ptr hGfx
	Dim As Any Ptr hBitmap, hBrush, hBrushL, hBrushLB, hPen, hPenL, hFamily, hStringFormat, hFont, hMatrix
	Dim As Single fBorderSize = fDiameter * 0.03333
	Dim As Single fSize = fDiameter * 0.9475 - fBorderSize / 2, fRadius = fDiameter / 2, fShadow_vx = fDiameter * 0.0095, fShadow_vy = fDiameter * 0.01
	Dim As GpPointF tPoint1, tPoint2
	
	Dim As Single fPi, fRad, fDeg
	fPi = Acos(-1)
	fRad = fPi / 180
	fDeg = 180 / fPi
	Dim As Single fShadowAngle
	
	'准备画布和位图
	GdipCreateBitmapFromScan0(fDiameter, fDiameter, 0, PixelFormat32bppARGB, 0, @hBitmap)
	GdipGetImageGraphicsContext(hBitmap, @hGfx)
	GdipSetSmoothingMode(hGfx, SmoothingModeAntiAlias)
	GdipSetPixelOffsetMode(hGfx, PixelOffsetModeHighQuality)
	GdipSetTextRenderingHint(hGfx, TextRenderingHintAntiAlias)
	
	tPoint1.X = fBorderSize
	tPoint1.Y = fBorderSize
	tPoint2.X = fSize
	tPoint2.Y = fSize
	GdipCreateLineBrush(@tPoint1, @tPoint2, fAlpha Shl 24 Or &hFFFFFF, fAlpha Shl 24 Or &hB0B0B0, 3, @hBrushLB)
	
	GdipSetLineSigmaBlend(hBrushLB, 0.5, 0.85)
	
	GdipCreateMatrix(@hMatrix)
	GdipTranslateMatrix(hMatrix, fSize * 2, fSize * 2, 1)
	GdipRotateMatrix(hMatrix, 90, 1)
	GdipTranslateMatrix(hMatrix, -fSize * 2, -fSize * 2, 1)
	GdipMultiplyLineTransform(hBrushLB, hMatrix, 0)
	GdipDeleteMatrix(hMatrix)
	
	'填充表盘底色
	GdipFillEllipse(hGfx, hBrushLB, fBorderSize, fBorderSize, fSize, fSize)
	
	'绘制表盘阴影
	fShadowAngle = Atn(fShadow_vy / fShadow_vx) * fDeg
	If fShadow_vx < 0 And fShadow_vy >= 0 Then fShadowAngle += 180
	If fShadow_vx < 0 And fShadow_vy < 0 Then fShadowAngle -= 180
	GdipCreatePen1((fAlpha And &h90) Shl 24 Or &h000000, fBorderSize, 2, @hPen)
	GdipDrawEllipse(hGfx, hPen, fBorderSize + fShadow_vx, fBorderSize + fShadow_vy, fSize, fSize)
	'阴影模糊处理
	_GDIPlus_BitmapApplyFilter_FastBoxBlur(hBitmap, fDiameter * 0.02)
	
	'绘制表盘边缘
	tPoint1.X = 0
	tPoint1.Y = 0
	tPoint2.X = fSize
	tPoint2.Y = fSize
	GdipCreateLineBrush(@tPoint1, @tPoint2, fAlpha Shl 24 Or &hFFFFFFF, fAlpha Shl 24 Or &h000000, 3, @hBrushL)
	GdipSetLineSigmaBlend(hBrushL, 0.6, 1.0)
	GdipSetLineGammaCorrection(hBrushL, True)
	GdipCreatePen2(hBrushL, fBorderSize, UnitPixel, @hPenL)
	GdipDrawEllipse(hGfx, hPenL, fBorderSize, fBorderSize, fSize, fSize)
	
	GdipDeleteFont(hFont)
	GdipDeleteFontFamily(hFamily)
	GdipDeleteStringFormat(hStringFormat)
	GdipDeleteBrush(hBrush)
	GdipDeleteBrush(hBrushL)
	GdipDeleteBrush(hBrushLB)
	GdipDeletePen(hPen)
	GdipDeletePen(hPenL)
	GdipDeleteGraphics(hGfx)
	
	Return hBitmap
End Function


Private Function AnalogClockScale(fDiameter As Single, ByVal fAlpha As UByte = 255) As Any Ptr
	Dim As Any Ptr hGfx
	Dim As Any Ptr hBitmap, hBrush, hBrushL, hBrushLB, hPen, hPenL, hFamily, hStringFormat, hFont, hMatrix
	Dim As Single fBorderSize = fDiameter * 0.03333
	Dim As Single fSize = fDiameter * 0.9475 - fBorderSize / 2, fRadius = fDiameter / 2, fShadow_vx = fDiameter * 0.0095, fShadow_vy = fDiameter * 0.01
	Dim As GpPointF tPoint1, tPoint2
	
	Dim As Single fPi, fRad, fDeg
	fPi = Acos(-1)
	fRad = fPi / 180
	fDeg = 180 / fPi
	Dim As Single fShadowAngle
	
	'准备画布和位图
	GdipCreateBitmapFromScan0(fDiameter, fDiameter, 0, PixelFormat32bppARGB, 0, @hBitmap)
	GdipGetImageGraphicsContext(hBitmap, @hGfx)
	GdipSetSmoothingMode(hGfx, SmoothingModeAntiAlias)
	GdipSetPixelOffsetMode(hGfx, PixelOffsetModeHighQuality)
	GdipSetTextRenderingHint(hGfx, TextRenderingHintAntiAlias)
	
	'绘制表盘刻度
	GdipCreateSolidFill(fAlpha Shl 24 Or &h000000, @hBrush)
	
	'刻度距离边缘
	Dim As Single fPosY = fDiameter / 11
	'粗刻度
	Dim As Single iWidth1 = fDiameter / 48, iHeight1 = fDiameter / 15, iWidth12 = iWidth1 / 2
	'细刻度
	Dim As Single iWidth2 = fDiameter / 100, iHeight2 = fDiameter / 25, iWidth22 = iWidth2 / 2
	
	GdipTranslateWorldTransform(hGfx, fRadius, fRadius, 0)
	GdipRotateWorldTransform(hGfx, -6.0, MatrixOrderPrepend)
	GdipTranslateWorldTransform(hGfx, -fRadius, -fRadius, 0)
	For i As UByte = 0 To 59
		GdipTranslateWorldTransform(hGfx, fRadius, fRadius, 0)
		GdipRotateWorldTransform(hGfx, 6.0, MatrixOrderPrepend)
		GdipTranslateWorldTransform(hGfx, -fRadius, -fRadius, 0)
		If (i Mod 5) = 0 Then
			'绘制粗刻度
			GdipFillRectangle(hGfx, hBrush, fRadius - iWidth12, fPosY, iWidth1, iHeight1)
		Else
			'绘制细刻度
			GdipFillRectangle(hGfx, hBrush, fRadius - iWidth22, fPosY, iWidth2, iHeight2)
		End If
	Next
	GdipResetWorldTransform(hGfx)
	
	GdipDeleteFont(hFont)
	GdipDeleteFontFamily(hFamily)
	GdipDeleteStringFormat(hStringFormat)
	GdipDeleteBrush(hBrush)
	GdipDeleteBrush(hBrushL)
	GdipDeleteBrush(hBrushLB)
	GdipDeletePen(hPen)
	GdipDeletePen(hPenL)
	GdipDeleteGraphics(hGfx)
	
	Return hBitmap
End Function


Private Sub gdipBitmap.DrawScaleImage(pImage As GpImage Ptr)
	'填满拉伸绘制
	If pImage = NULL Then Exit Sub
	
	Dim As Single fNewWidth, fNewHeight
	fNewWidth = mWidth
	fNewHeight = mHeight
	
	Dim As Single fOriginalWidth, fOriginalHeight
	GdipGetImageDimension(pImage, @fOriginalWidth, @fOriginalHeight)
	
	'准备画布和位图
	Dim fResizedImage As Any Ptr
	Dim fGraphics As GpGraphics Ptr
	GdipCreateBitmapFromScan0(fNewWidth, fNewHeight, 0, PixelFormat32bppARGB, 0, @fResizedImage)
	GdipGetImageGraphicsContext(fResizedImage, @fGraphics)
	
	'创建一个缩放矩阵
	Dim fMatrix As GpMatrix Ptr
	GdipCreateMatrix(@fMatrix)
	GdipScaleMatrix(fMatrix, fNewWidth / fOriginalWidth, fNewHeight / fOriginalHeight, 0)
	GdipSetWorldTransform(fGraphics, fMatrix)
	
	'绘制图像
	GdipDrawImageRect(fGraphics, pImage, 0, 0, fOriginalWidth, fOriginalHeight)
	'绘制缩放后的图像
	GdipDrawImageRect(mGraphics, fResizedImage, 0, 0, mWidth, mHeight)
	
	'释放资源
	GdipDeleteGraphics(fGraphics)
	GdipDeleteMatrix(fMatrix)
	GdipDisposeImage(fResizedImage)
End Sub

Private Sub gdipBitmap.DrawAlphaImage(pImage As GpImage Ptr, pAlpha As Single)
	'Alpha绘制
	Dim As Single fOriginalWidth, fOriginalHeight
	GdipGetImageDimension(pImage, @fOriginalWidth, @fOriginalHeight)
	
	' 创建图像属性
	Dim fImageAttr As GpImageAttributes Ptr
	GdipCreateImageAttributes(@fImageAttr)
	
	' 设置颜色矩阵进行 alpha 混合
	Dim fColorMatrix As ColorMatrix = Type( _
	{{1.0, 0.0, 0.0, 0.0, 0.0}, _
	{0.0, 1.0, 0.0, 0.0, 0.0}, _
	{0.0, 0.0, 1.0, 0.0, 0.0}, _
	{0.0, 0.0, 0.0, pAlpha, 0.0}, _
	{0.0, 0.0, 0.0, 0.0, 1.0}} _
	)
	
	GdipSetImageAttributesColorMatrix(fImageAttr, ColorAdjustTypeBitmap, True, @fColorMatrix, NULL, ColorMatrixFlagsDefault)

	' 绘制 alpha 混合后的图像
	GdipDrawImageRectRectI(mGraphics, pImage, 0, 0, fOriginalWidth, fOriginalHeight, 0, 0, fOriginalWidth, fOriginalHeight, UnitPixel, fImageAttr, NULL, NULL)
End Sub

Private Sub gdipBitmap.DrawRotateImage(pImage As GpImage Ptr, pAngle As Single)
	'旋转绘制
	If pImage = NULL Then Exit Sub
	
	Dim As Single fOriginalWidth, fOriginalHeight
	GdipGetImageDimension(pImage, @fOriginalWidth, @fOriginalHeight)
	Dim fCenterX As Single = fOriginalWidth / 2.0
	Dim fCenterY As Single = fOriginalHeight / 2.0
	
	'准备画布和位图
	Dim fResizedImage As Any Ptr
	Dim fGraphics As GpGraphics Ptr
	GdipCreateBitmapFromScan0(fOriginalWidth, fOriginalHeight, 0, PixelFormat32bppARGB, 0, @fResizedImage)
	GdipGetImageGraphicsContext(fResizedImage, @fGraphics)
	
	'创建一个缩放矩阵
	Dim fMatrix As GpMatrix Ptr
	GdipCreateMatrix(@fMatrix)
	GdipTranslateMatrix(fMatrix, fCenterX, fCenterY, MatrixOrderPrepend)
	GdipRotateMatrix(fMatrix, pAngle, MatrixOrderPrepend)
	GdipTranslateMatrix(fMatrix, -fCenterX, -fCenterY, MatrixOrderPrepend)
	GdipSetWorldTransform(fGraphics, fMatrix)
	
	'绘制图像
	GdipDrawImageRect(fGraphics, pImage, 0, 0, fOriginalWidth, fOriginalHeight)
	'绘旋转后的图像
	GdipDrawImageRect(mGraphics, fResizedImage, 0, 0, mWidth, mHeight)
	
	'释放资源
	GdipDeleteGraphics(fGraphics)
	GdipDeleteMatrix(fMatrix)
	GdipDisposeImage(fResizedImage)
End Sub

Private Sub gdipBitmap.DrawImage Overload (pImage As GpImage Ptr, pX As Single, pY As Single)
	'原始尺寸绘制
	If pImage = NULL Then Exit Sub
	Dim As Single sWidth, sHeight
	GdipGetImageDimension(pImage, @sWidth, @sHeight)
	GdipDrawImageRect(mGraphics, pImage, pX, pY, sWidth, sHeight)
End Sub
Private Sub gdipBitmap.Release()
	GdipDisposeImage(mBitmap)
	mBitmap = NULL
	GdipDeleteGraphics(mGraphics)
	mGraphics = NULL
End Sub
Private Sub gdipBitmap.Initial(ByVal pWidth As Single = 400, ByVal pHeight As Single = 300)
	Release()
	'准备画布和位图
	mWidth = pWidth
	mHeight = pHeight
	GdipCreateBitmapFromScan0(mWidth, mHeight, 0, PixelFormat32bppARGB, 0, @mBitmap)
	GdipGetImageGraphicsContext(mBitmap, @mGraphics)
	GdipSetSmoothingMode(mGraphics, SmoothingModeAntiAlias)
	GdipSetPixelOffsetMode(mGraphics, PixelOffsetModeHighQuality)
	GdipSetTextRenderingHint(mGraphics, TextRenderingHintAntiAlias)
End Sub
'Private Property gdipBitmap.Bitmap(pImage As GpBitmap Ptr)
'
'End Property
Private Property gdipBitmap.Image() As GpImage Ptr
	Return mBitmap
End Property
'Private Property gdipBitmap.Graphics(pGraphics As GpGraphics Ptr)
'
'End Property
Private Property gdipBitmap.Graphics() As GpGraphics Ptr
	Return mGraphics
End Property
Private Property gdipBitmap.Height() As Single
	Return mHeight
End Property
Private Property gdipBitmap.Width() As Single
	Return mWidth
End Property

Private Constructor gdipBitmap(ByVal pWidth As Single = 400, ByVal pHeight As Single = 300)
	Initial(pWidth, pHeight)
End Constructor

Private Destructor gdipBitmap
	Release()
End Destructor
