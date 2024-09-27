' Trans Form 透明窗口
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "win\GdiPlus.bi"

'建立gdip透明窗口
Type gdipForm
	'UpdateLayeredWindow
	hScrDC As HDC
	hMemDC As HDC
	hOldDC As HDC
	
	ULWpptDst As Point
	ULWpsize As tagSIZE
	ULWpptSrc As Point
	ULWcrKey As COLORREF
	ULWpblend As BLENDFUNCTION
	
	bmHeader As BITMAPINFO
	hHBitmap As HBITMAP
	
	mBitmap As GpBitmap Ptr
	mImage As GpImage Ptr
	
	sHeight As Single
	sWidth As Single
	
	mGraphics As GpGraphics Ptr
	
	mEnabled As Boolean
	mHandle As HWND
	
	mBackColor As ARGB = &hFF808080
	
	Declare Constructor
	Declare Destructor
	Declare Sub Create(Handle As HWND, Img As GpImage Ptr)
	Declare Sub DrawImage(sImg As GpImage Ptr, sX As Single = 0, sY As Single = 0)
	Declare Sub Initial()
	Declare Sub Release()
	
	Declare Property Enabled() As Boolean
	Declare Property Enabled(val As Boolean)
	Declare Property Graphic() As GpGraphics Ptr
	Declare Sub Transform(ByVal Alpha As Integer = 255)
End Type

#ifndef __USE_MAKE__
	#include once "gdipForm.bas"
#endif
