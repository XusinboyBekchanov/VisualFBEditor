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
	Declare Sub Initlal(ByVal pWidth As Single= 400, ByVal pHeight As Single = 300)
	'Declare Property Bitmap(pImage As GpBitmap Ptr)
	Declare Property Image() As GpImage Ptr
	'Declare Property Graphics(pGraphics As GpGraphics Ptr)
	Declare Property Graphics() As GpGraphics Ptr
	Declare Property Height() As Single
	Declare Property Width() As Single
	Declare Sub DrawImage Overload (pImage As GpImage Ptr)
	Declare Sub DrawImage Overload (pImage As GpImage Ptr, pX As Single, pY As Single)
	Declare Sub DrawImage Overload (pImage As GpImage Ptr, pX As Single, pY As Single, ByVal pW As Single, pH As Single)
	Declare Constructor(ByVal pWidth As Single = 400, ByVal pHeight As Single = 300)
	Declare Destructor
End Type

Private Sub gdipBitmap.DrawImage Overload (pImage As GpImage Ptr)
	If pImage = NULL Then Exit Sub
	
	'填满拉伸绘制
	Dim As Single fOriginalWidth, fOriginalHeight
	Dim As Single fNewWidth, fNewHeight
	
	fNewWidth = mWidth
	fNewHeight = mHeight
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
	'GdipDisposeImage(pImage)
End Sub

Private Sub gdipBitmap.DrawImage Overload (pImage As GpImage Ptr, pX As Single, pY As Single, pW As Single, pH As Single)
	If pImage = NULL Then Exit Sub
	'拉伸绘制
End Sub

Private Sub gdipBitmap.DrawImage Overload (pImage As GpImage Ptr, pX As Single, pY As Single)
	If pImage = NULL Then Exit Sub
	'原始尺寸绘制
	Dim As Single sWidth, sHeight
	GdipGetImageDimension(pImage, @sWidth, @sHeight)
	GdipDrawImageRect(mGraphics, pImage, pX, pY, sWidth, sHeight)
	'GdipDisposeImage(pImage)
End Sub
Private Sub gdipBitmap.Release()
	GdipDisposeImage(mBitmap)
	mBitmap = NULL
	GdipDeleteGraphics(mGraphics)
	mGraphics = NULL
End Sub
Private Sub gdipBitmap.Initlal(ByVal pWidth As Single = 400, ByVal pHeight As Single = 300)
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
	Initlal(pWidth, pHeight)
End Constructor

Private Destructor gdipBitmap
	Release()
End Destructor

#ifndef __USE_MAKE__
	#include once "gdip.bas"
#endif
