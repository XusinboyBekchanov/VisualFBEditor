' Analog Clock模拟时钟
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "gdip.bi"
#include once "win\GdiPlus.bi"
#include once "vbcompat.bi"

Type AnalogClock
	mPi As Double = Atn(1) * 4
	mCenterX As Single
	mCenterY As Single
	'时针大小
	mHandHourSize As Single
	mHandMinuteSize As Single
	mHandSecondSize As Single
	'时针后端偏移
	mHandHourTail As Single
	mHandMinuteTail As Single
	mHandSecondTail As Single
	'时针前端长度
	mHandHourFront As Single
	mHandMinuteFront As Single
	mHandSecondFront As Single
	mHandHourEnabled As Boolean = True
	mHandMinuteEnabled As Boolean = True
	mHandSecondEnabled As Boolean = False
	
	mAHourColor As ARGB
	mAMinuteColor As ARGB
	mASecondColor As ARGB
	mPenHour As GpPen Ptr
	mPenMinute As GpPen Ptr
	mPenSecond As GpPen Ptr
	
	mUpdateBitmap As gdipBitmap
	
	mTrayEnabled As Boolean = True
	mTrayBlur As Integer = 0
	mTrayAlpha As Single = &HFF
	
	mTrayFaceColor1 As ARGB = &HFFFFFF
	mTrayFaceColor2 As ARGB = &HE0E0E0
	mTrayFaceAlpha1 As ARGB = &HFF
	mTrayFaceAlpha2 As ARGB = &HFF
	mTrayShadowColor As ARGB = &H000000
	mTrayShadowAlpha As ARGB = &H90
	mTrayEdgeColor1 As ARGB = &HFFFFFF
	mTrayEdgeColor2 As ARGB = &H000000
	mTrayEdgeAlpha1 As ARGB = &HFF
	mTrayEdgeAlpha2 As ARGB = &HFF
	
	mHandEnabled As Boolean = True
	mHandAlpha As ARGB = &HB0
	mHandSecondColor As ARGB = &HFF0000
	mHandMinuteColor As ARGB = &H0000FF
	mHandHourColor As ARGB = &H00FF00
	mHandBlur As Integer = 0
	mHandSecond As Boolean = True
	mHandScale As Single = 1
	mHandOffsetX As Single = 0
	mHandOffsetY As Single = 0
	
	mScaleEnabled As Boolean = True
	mScaleColor As ARGB = &H000000
	mScaleAlpha As ARGB = &H80
	mScaleBlur As Integer = 0
	
	mTextEnabled As Boolean = True
	mTextColor As ARGB = &H000000
	mTextAlpha As ARGB = &H80
	mTextBlur As Integer = 0
	mTextFormat As WString Ptr
	mTextFont As WString Ptr
	mTextBold As Boolean = True
	mTextSize As Single = 0.128
	mTextScale As Single = 1
	mTextOffsetX As Single = 1
	mTextOffsetY As Single = 1.4
	
	mBackBitmap As gdipBitmap
	mBackEnabled As Boolean = False
	mBackScale As Single = 1
	mBackImage As gdipImage
	mBackFile As WString Ptr
	mBackAlpha As Single = &H80
	mBackBlur As Integer = 0
	
	mBlur As Integer = 0
	mWidth As Single
	mHeight As Single
	
	Declare Property FileName(ByRef fFileName As WString)
	Declare Property FileName() ByRef As WString
	Declare Sub Background(ByVal pWidth As Single = 300, ByVal pHeight As Single = 400)
	Declare Function ImageUpdate() As GpImage Ptr
	Declare Function DrawTray() As GpImage Ptr
	Declare Function DrawScale() As GpImage Ptr
	Declare Function DrawText() As GpImage Ptr
	Declare Function DrawHand() As GpImage Ptr
	
	Declare Constructor
	Declare Destructor
	Declare Sub Release()
End Type

#ifndef __USE_MAKE__
	#include once "gdipAnalogClock.bas"
#endif
