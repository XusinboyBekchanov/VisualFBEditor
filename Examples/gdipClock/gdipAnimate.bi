'gdipAnimate动画
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "gdip.bi"

Type gdipAnimate
Private:
	mFrameCountX As Integer
	mFrameCountY As Integer
	mFrameWidth As Integer
	mFrameHeight As Integer
	mFrameX As Integer
	mFrameY As Integer
	
	mFileBitmap As gdipBitmap
Public:
	mWidth As Single
	mHeight As Single
	mAnimate As gdipBitmap
	mRotate As RotateFlipType = RotateNoneFlipNone
	Declare Constructor
	Declare Destructor
	Declare Sub Initial(sFileName As WString, sFramWidth As Integer, sFramHeight As Integer)
	Declare Function Animate(ByVal sInc As Integer = 1) As GpImage Ptr
	Declare Sub Release()
End Type

Private Sub gdipAnimate.Initial(sFileName As WString, sFramWidth As Integer, sFramHeight As Integer)
	mFileBitmap.DrawFromFile(sFileName)
	mFrameCountX = mFileBitmap.Width / sFramWidth - 1
	mFrameCountY = mFileBitmap.Height / sFramHeight - 1
	mFrameWidth = sFramWidth
	mFrameHeight = sFramHeight
End Sub

Private Function gdipAnimate.Animate(ByVal sInc As Integer = 1) As GpImage Ptr
	mAnimate.Initial(mFrameWidth, mFrameHeight)
	
	If mFrameX < mFrameCountX Then
		mFrameX += sInc
	Else
		
		If mFrameY < mFrameCountY Then
			mFrameY += sInc
		Else
			mFrameY = 0
		End If
		mFrameX = 0
	End If
	GdipDrawImageRectRectI(mAnimate.Graphics, mFileBitmap.Image, 0, 0, mFrameWidth, mFrameHeight, mFrameWidth*mFrameX, mFrameHeight*mFrameY, mFrameWidth, mFrameHeight, UnitPixel, NULL, NULL, NULL)
	GdipImageRotateFlip(mAnimate.Image, mRotate)
	Return mAnimate.Image
End Function

Private Constructor gdipAnimate
	
End Constructor

Private Destructor gdipAnimate
	
End Destructor

#ifndef __USE_MAKE__
	#include once "gdipAnimate.bas"
#endif
