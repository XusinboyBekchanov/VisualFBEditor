' gdip
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

#include once "win\GdiPlus.bi"
#include once "vbcompat.bi"

Declare Sub _GDIPlus_BitmapApplyFilter_FastBoxBlur(ByVal hImage As GpImage Ptr, range As ULong)
Declare Sub FastBoxBlurH(hImage As GpImage Ptr, range As ULong)
Declare Sub FastBoxBlurV(hImage As GpImage Ptr, range As ULong)

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
	Declare Sub Release()
	Declare Function FromFile(ImageFile As WString) As GpImage Ptr
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
	'Declare Property Bitmap(pImage As GpBitmap Ptr)
	Declare Property Image() As GpImage Ptr
	'Declare Property Graphics(pGraphics As GpGraphics Ptr)
	Declare Property Graphics() As GpGraphics Ptr
	Declare Property Height() As Single
	Declare Property Width() As Single
	Declare Sub DrawImage(pImage As GpImage Ptr, pX As Single, pY As Single)
	Declare Sub DrawScaleImage(pImage As GpImage Ptr)
	Declare Sub DrawRotateImage(pImage As GpImage Ptr, pAngle As Single)
	Declare Sub DrawAlphaImage(pImage As GpImage Ptr, pAlpha As Single)
	Declare Constructor(ByVal pWidth As Single = 400, ByVal pHeight As Single = 300)
	Declare Destructor
End Type

#ifndef __USE_MAKE__
	#include once "gdip.bas"
#endif
