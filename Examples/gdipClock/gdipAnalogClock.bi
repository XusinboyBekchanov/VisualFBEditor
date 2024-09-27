' Analog Clock模拟时钟
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "gdip.bi"
#include once "win\GdiPlus.bi"
#include once "vbcompat.bi"

Type AnalogClock
	mAHourColor As ARGB
	mAMinuteColor As ARGB
	mASecondColor As ARGB
	mBackAlpha As Single = &H80
	mBackBitmap As gdipBitmap
	mBackBlur As Integer = 0
	mBackEnabled As Boolean = True
	mBackFile As WString Ptr
	mBackImage As gdipImage
	mBackScale As Single = 1
	mBlur As Integer = 0
	mCenterX As Single
	mCenterY As Single
	mHandAlpha As ARGB = &HFF
	mHandBlur As Integer = 0
	mHandEnabled As Boolean = True
	mHandHourColor As ARGB = &H00FF00
	mHandHourEnabled As Boolean = True
	mHandHourFront As Single
	mHandHourSize As Single
	mHandHourTail As Single
	mHandMinuteColor As ARGB = &H0000FF
	mHandMinuteEnabled As Boolean = True
	mHandMinuteFront As Single
	mHandMinuteSize As Single
	mHandMinuteTail As Single
	mHandOffsetX As Single = 0
	mHandOffsetY As Single = 0
	mHandScale As Single = 1
	mHandSecondColor As ARGB = &HFF0000
	mHandSecondEnabled As Boolean = True
	mHandSecondFront As Single
	mHandSecondSize As Single
	mHandSecondTail As Single
	mHeight As Single
	mOutlineAlpha As ARGB = &HFF
	mOutlineColor As ARGB = &HBF3F7F
	mOutlineEnabled As Boolean = True
	mOutlineSize As Single = 1
	mPanelAlpha As ARGB = &H80
	mPanelColor As ARGB = &HFFFFFF
	mPanelEnabled As Boolean = True
	mPenHour As GpPen Ptr
	mPenMinute As GpPen Ptr
	mPenSecond As GpPen Ptr
	mPi As Double = Atn(1) * 4
	mScaleAlpha As ARGB = &HFF
	mScaleBlur As Integer = 0
	mScaleColor As ARGB = &H000000
	mScaleEnabled As Boolean = True
	mTextAlpha As ARGB = &HFF
	mTextBlur As Integer = 0
	mTextBold As Boolean = True
	mTextColor As ARGB = &H000000
	mTextEnabled As Boolean = True
	mTextFont As WString Ptr
	mTextFormat As WString Ptr
	mTextOffsetX As Single = 1
	mTextOffsetY As Single = 1.5
	mTextScale As Single = 1
	mTextSize As Single = 0.12
	mTrayAlpha As Single = &HFF
	mTrayBlur As Integer = 0
	mTrayEdgeAlpha1 As ARGB = &HFF
	mTrayEdgeAlpha2 As ARGB = &HFF
	mTrayEdgeColor1 As ARGB = &HFFFFFF
	mTrayEdgeColor2 As ARGB = &H000000
	mTrayEnabled As Boolean = True
	mTrayFaceAlpha1 As ARGB = &HFF
	mTrayFaceAlpha2 As ARGB = &HFF
	mTrayFaceColor1 As ARGB = &HFFFFFF
	mTrayFaceColor2 As ARGB = &HE0E0E0
	mTrayShadowAlpha As ARGB = &H90
	mTrayShadowColor As ARGB = &H000000
	mUpdateBitmap As gdipBitmap
	mWidth As Single
	
	Declare Constructor
	Declare Destructor
	Declare Function DrawHand() As GpImage Ptr
	Declare Function DrawScale() As GpImage Ptr
	Declare Function DrawText() As GpImage Ptr
	Declare Function DrawTray() As GpImage Ptr
	Declare Function ImageUpdate() As GpImage Ptr
	Declare Property FileName() ByRef As WString
	Declare Property FileName(ByRef fFileName As WString)
	Declare Sub Background(ByVal pWidth As Single = 300, ByVal pHeight As Single = 400)
	Declare Sub Release()
End Type

#ifndef __USE_MAKE__
	#include once "gdipAnalogClock.bas"
#endif
