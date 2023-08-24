#pragma once
' TimeMeter 计时器
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

#include once "TimeMeter.bi"

Constructor TimeMeter
	QueryPerformanceFrequency Cast(PLARGE_INTEGER , @tFrequency)
	Start
End Constructor

Destructor TimeMeter

End Destructor

Private Sub TimeMeter.Start()
	QueryPerformanceCounter Cast(PLARGE_INTEGER ,@tStart)
End Sub

Private Function TimeMeter.Passed() As Double
	QueryPerformanceCounter Cast(PLARGE_INTEGER ,@tEnd)
	Return (tEnd - tStart) / tFrequency
End Function
