' SerialPort 串口
' Copyright (c) 2022 CM.Wang
' Freeware. Use at your own risk.

'https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-getcommstate
'https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-setcommstate
'https://learn.microsoft.com/en-us/windows/desktop/api/winbase/ns-winbase-dcb
'https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-getcommmodemstatus

#pragma once

#include once "vbcompat.bi"
#include once "win/winbase.bi"
#include once "../MDINotepad/Text.bi"

Type SerialPort
Private:
	mName(Any) As WString Ptr
	mIndex As Integer
	mCount As Integer
	mHandle As HANDLE
	mThread As Any Ptr
	mOwner As Any Ptr
	mOverlapped As OVERLAPPED
	
	Declare Static Function ThreadProcedure(ByVal pParam As LPVOID) As DWORD
Public:
	Declare Constructor
	Declare Destructor
	Declare Function Write(ByVal WriteData As ZString Ptr, ByVal DataLength As Integer) As Integer
	Declare Property Count() As Integer
	Declare Property ComHandle() As HANDLE
	Declare Property Name(ByVal Index As Integer) ByRef As WString 
	Declare Function Enumerate(ByVal PortMaxNumber As Long = 255) As Integer
	Declare Function Open(ByVal Index As Integer, ByVal Owner As Any Ptr) As HANDLE
	Declare Function Close() As Boolean
	
	OndDtaArrive As Sub(Owner As Any Ptr, ArriveData As ZString Ptr, DataLength As Integer) '接收串口数据
End Type

#ifndef __USE_MAKE__
	#include once "SerialPort.bas"
#endif


