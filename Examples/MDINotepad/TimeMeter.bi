#pragma once
' TimeMeter 计时器
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

Type TimeMeter
Private :
	tFrequency As LongInt
	tStart As LongInt
	tEnd As LongInt
Public :
	Declare Constructor
	Declare Destructor
	Declare Sub Start() '开始计时
	Declare Function Passed() As Double '过去的时间
End Type

#ifndef __USE_MAKE__
	#include once "TimeMeter.bas"
#endif
