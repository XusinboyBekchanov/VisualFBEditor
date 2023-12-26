' Trans Form 透明窗口
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

#include once "gdipForm.bi"

Private Constructor gdipForm
	Initial()
End Constructor

Private Destructor gdipForm
	Release()
End Destructor

Private Sub gdipForm.Initial()
	
End Sub

Private Sub gdipForm.Release()
	'释放Graphics对象的函数
	If mGraphics Then GdipDeleteGraphics(mGraphics)
	'释放位图
	If hHBitmap Then DeleteObject(hHBitmap)
	'释放绘制的对象
	If hOldDC AndAlso hMemDC Then SelectObject(hMemDC, hOldDC)
	'释放兼容设备上下文
	If hMemDC Then DeleteDC(hMemDC)
	'释放设备
	If hScrDC Then ReleaseDC(0, hScrDC)
	'释放位图
	If mImage Then GdipDisposeImage(mImage)
	If mBitmap Then DeleteObject(mBitmap)
End Sub

Private Sub gdipForm.Create(Handle As HWND, Img As GpImage Ptr)
	Release()
	
	mHandle = Handle
	GdipGetImageDimension(Img, @sWidth, @sHeight)
	
	With bmHeader.bmiHeader
		.biSize = SizeOf(bmHeader)
		.biBitCount = 32  '当然要有透明通道，所以是32bppBitmap
		.biWidth = sWidth
		.biHeight = sHeight
		.biPlanes = 1
		.biSizeImage = .biWidth * .biHeight * 4  '32位就是4个字节
	End With
	
	'获取指定窗口的设备, 释放ReleaseDC
	hScrDC = GetDC(mHandle)
	'创建一个与指定设备兼容的内存设备, 当不再需要时，释放DeleteDC
	hMemDC = CreateCompatibleDC(hScrDC)
	'创建一个与设备无关的位图, 释放'DeleteObject
	hHBitmap = CreateDIBSection(hMemDC, @bmHeader, DIB_RGB_COLORS, 0, 0, 0)
	'用于在设备上下文（DC，Device Context）中选择一个可绘制的对象, 释放SelectObject(hMemDC, hOldDC)
	hOldDC = SelectObject(hMemDC, hHBitmap)
	
	'创建一个Graphics对象用于在Windows设备驱动程序中绘制图形, 释放GdipDeleteGraphics
	GdipCreateFromHDC(hMemDC, @mGraphics)
	
	GdipSetSmoothingMode(mGraphics, SmoothingModeAntiAlias)
	GdipSetSmoothingMode(mGraphics, SmoothingModeAntiAlias)
	GdipSetPixelOffsetMode(mGraphics, PixelOffsetModeHighQuality)
	GdipSetTextRenderingHint(mGraphics, TextRenderingHintAntiAlias)
	
	'背景色
	'GdipGraphicsClear(mGraphics, mBackColor)
	
	'在指定的矩形区域内绘制图像'释放GdipDisposeImage
	GdipDrawImageRect(mGraphics, Img, 0, 0, sWidth, sHeight)
End Sub

Private Sub gdipForm.DrawImage(sImg As GpImage Ptr, sX As Single = 0, sY As Single = 0)
	Dim As Single sWidth, sHeight
	GdipGetImageDimension(sImg, @sWidth, @sHeight)
	GdipDrawImageRect(mGraphics, sImg, sX, sY, sWidth, sHeight)
End Sub

Private Property gdipForm.Enabled() As Boolean
	If mHandle = NULL Then Return False
	mEnabled = GetWindowLong(mHandle, GWL_EXSTYLE) And WS_EX_LAYERED
	Return mEnabled
End Property

Private Property gdipForm.Enabled(val As Boolean)
	mEnabled = val
	If mHandle = NULL Then Return
	If val Then
		'更新具有透明效果的窗口
		SetWindowLong mHandle, GWL_EXSTYLE, GetWindowLong(mHandle, GWL_EXSTYLE) Or WS_EX_LAYERED
	Else
		'更新不具有透明效果的窗口
		SetWindowLong mHandle, GWL_EXSTYLE, GetWindowLong(mHandle, GWL_EXSTYLE) And Not WS_EX_LAYERED
	End If
End Property

Private Property gdipForm.Graphic() As GpGraphics Ptr
	Return mGraphics
End Property

Private Sub gdipForm.Transform(ByVal Alpha As Integer = 255)
	With ULWpsize
		.cx = sWidth
		.cy = sHeight
	End With
	With ULWpblend
		.BlendOp = AC_SRC_OVER
		.BlendFlags = 0
		.SourceConstantAlpha = Alpha
		.AlphaFormat = AC_SRC_ALPHA
	End With
	
	Dim lRT As Rect
	'获取控件矩形
	GetWindowRect(mHandle, @lRT)
	With ULWpptDst
		.X = lRT.Left
		.Y = lRT.Top
	End With
	
	With ULWpptSrc
		.X = 0
		.Y = 0
	End With
	
	'设置窗口WS_EX_LAYERED
	If mEnabled = False Then Enabled = True
	
	'更新具有透明效果的窗口
	UpdateLayeredWindow(mHandle, hScrDC, @ULWpptDst, @ULWpsize, hMemDC, @ULWpptSrc, ULWcrKey, @ULWpblend, ULW_ALPHA)
End Sub

