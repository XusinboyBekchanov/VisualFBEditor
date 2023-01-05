#pragma once
' PipeProcess 管道处理
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

Type PipeProcess
Private : '私有变量
	dwMode As DWORD
	hPipeErrRead As HANDLE
	hPipeErrWrite As HANDLE
	hPipeInRead As HANDLE
	hPipeInWrite As HANDLE
	hPipeOutRead As HANDLE
	hPipeOutWrite As HANDLE
	mErrorLevel As Long
	mOwner As Any Ptr = 0
	mThread As Any Ptr '线程ID
	mThreadAlive As Boolean = False
	stProcessInfo As PROCESS_INFORMATION
	stStartInfo As STARTUPINFO

Private : '私有函数
	Declare Static Function ThreadPipeRead(ByVal pParam As LPVOID) As DWORD

Public : '构造与析构函数
	Declare Constructor
	Declare Destructor

Public : '共有函数，类的事件
	OnPipeClosed As Sub(Owner As Any Ptr, ErrorLevel As Long)
	OnPipeRead As Sub(Owner As Any Ptr, DataRead As ZString, Length As Long)
Public : '共有函数，类的方法
	Declare Function PipeCreate(Owner As Any Ptr, cmd As WString, msrtn As WString) As WINBOOL
	Declare Function PipeWrite(a As String) As Long
	Declare Sub PipeRead()
	Declare Function PipeClosed() As WINBOOL
Public : '共有函数，类的属性
End Type

#ifndef __USE_MAKE__
	#include once "PipeProcess.bas"
#endif
