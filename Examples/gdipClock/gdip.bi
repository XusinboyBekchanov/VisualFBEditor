' gdip
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "win\GdiPlus.bi"
#include once "vbcompat.bi"

#define vbRGB(r, g, b) CULng((CUByte(b) Shl 16) Or (CUByte(g) Shl 8) Or CUByte(r))

Type gdipToken
Private:
	mToken As ULONG_PTR = NULL
Public:
	Declare Constructor
	Declare Destructor
	Declare Sub Initial()
	Declare Sub Release()
End Type

Type gdipDC
	mHWND As HWND
	mDC As HDC
	mDtHWND As HWND
	mDtDC As HDC
	mBitmap As HBITMAP
	mOldDC As HDC
	
	Declare Property DC() As HDC
	Declare Constructor(ByVal phWnd As HANDLE = 0)
	Declare Destructor
	Declare Sub Initial(ByVal phWnd As HANDLE = 0, ByVal pWidth As Single = 400, ByVal pHeight As Single = 300)
	Declare Sub Release()
End Type

Type gdipGraphics
Private:
	mBackColor As ARGB = &HFF808080
	mGraphics As GpGraphics Ptr
Public:
	Declare Property Graphics() As GpGraphics Ptr
	Declare Constructor(ByVal pDC As HDC = 0, ByVal pClear As Boolean = False)
	Declare Destructor
	Declare Sub Initial(ByVal pDC As HDC = 0, ByVal pClear As Boolean = False)
	Declare Sub Release()
	Declare Sub DrawImage(pImage As GpImage Ptr, pX As Single = 0, pY As Single = 0)
End Type

Type gdipImage
Private:
	mHeight As Single
	mWidth As Single
	mImage As GpImage Ptr
	mResizedImage As Any Ptr
Public:
	mFileName As WString Ptr
	Declare Sub Release()
	Declare Property ImageFile(ByRef pFileName As WString)
	Declare Property ImageFile() ByRef As WString
	Declare Property Image(pImage As GpImage Ptr)
	Declare Property Image() As GpImage Ptr
	Declare Function Resize(pNewWidth As Single, pNewHeight As Single) As GpImage Ptr
	Declare Property Height() As Single
	Declare Property Width() As Single
	Declare Constructor
	Declare Destructor
End Type

Type gdipBitmap
Private:
	mWidth As Single
	mHeight As Single
	mBitmap As Any Ptr
	mGraphics As GpGraphics Ptr
Public:
	Declare Sub Release()
	Declare Sub Initial(ByVal pWidth As Single= 400, ByVal pHeight As Single = 300)
	Declare Property Image(pImage As GpBitmap Ptr)
	Declare Property Image() As GpImage Ptr
	Declare Property Graphics() As GpGraphics Ptr
	Declare Property Height() As Single
	Declare Property Width() As Single
	
	Declare Sub DrawFromFile(ImageFile As WString)
	Declare Sub DrawImage(pImage As GpImage Ptr, pX As Single, pY As Single)
	Declare Sub DrawPartImage(pImage As GpImage Ptr, pDestX As Single, pDestY As Single,  pSrcX As Single, pSrcY As Single, pSrcWidth As Single, pSrcHeight As Single, ByVal pAlpha As Integer = &HFF)
	Declare Sub DrawScaleImage(pImage As GpImage Ptr, ByVal pWidth As Single = 0, ByVal pHeight As Single = 0)
	Declare Sub DrawRotateImage(pImage As GpImage Ptr, pAngle As Single)
	Declare Sub DrawAlphaImage(pImage As GpImage Ptr, pAlpha As Single)
	Declare Constructor(ByVal pWidth As Single = 400, ByVal pHeight As Single = 300)
	Declare Destructor
End Type

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

'https://lotsacode.wordpress.com/2010/12/08/fast-blur-box-blur-With-accumulator/
Sub FastBoxBlurHV(ByVal hImage As GpImage Ptr, range As ULong)
	If hImage = NULL Then Exit Sub
	If (range Mod 2) = 0 Then range += 1
	FastBoxBlurH(hImage, range)
	FastBoxBlurV(hImage, range)
End Sub

Private Function Color2Gdip(fColor As ARGB) As ARGB
	Dim a As ARGB = fColor And &HFF000000
	Dim r As ARGB = (fColor And &H000000FF) Shl 16
	Dim g As ARGB = fColor And &H0000FF00
	Dim b As ARGB = (fColor And &H00FF0000) Shr 16
	Return a Or r Or g Or b
End Function

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

#ifndef __USE_MAKE__
	#include once "gdip.bas"
#endif
