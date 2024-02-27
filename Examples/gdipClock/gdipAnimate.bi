'gdipAnimate动画
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "gdip.bi"
#include once "win\combaseapi.bi"

Type gdipAnimate
Private:
	mFileBitmap As gdipBitmap
	
	mFrameCountX As Integer
	mFrameCountY As Integer
	mFrameWidth As Integer
	mFrameHeight As Integer
	
	'Todo: FrameDimensionTime freebasic not decdared at gdip Win32
	GUID_FrameDimensionTime As GUID
Public:
	mAnimate As gdipBitmap
	
	mFrameIndex As Integer
	mFrameCount As ULong
	mFrameDelays(Any) As Integer
	mIsGif As Boolean
	
	mWidth As Single
	mHeight As Single
	mRotate As RotateFlipType = RotateNoneFlipNone
	
	Declare Constructor
	Declare Destructor
	Declare Sub ImageFile(sFileName As WString, ByVal sFrameWidth As Integer = 0, ByVal sFrameHeight As Integer = 0, ByVal sFrameCount As Integer = -1)
	Declare Function ImageFrame(ByVal sInc As Integer = 1) As GpImage Ptr
End Type

#ifndef __USE_MAKE__
	#include once "gdipAnimate.bas"
#endif
