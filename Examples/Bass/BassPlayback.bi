'BASS for freebasic translate by Cm.Wang

#pragma once

Type BassPlayback
Private : '私有变量
	PlayStream As HSTREAM ' the streams
	PlayLength As QWORD = 0
	PlayPosition As QWORD
	PlayStatus As BassStatus
	PlayBuffer As Boolean
Private : '私有函数
Public : '构造与析构函数
	Declare Constructor
	Declare Destructor
Public : '共有类的事件
Public : '共有类的方法
Public : '共有类的属性
	Declare Property BufferPlaying As Boolean
	Declare Property Status As BassStatus
	Declare Property Stream As HSTREAM
	Declare Property Length As DWORD
	Declare Property Position As DWORD
	Declare Property Position(dpos As DWORD)
Public : '共有过程和函数
	
	Declare Function OpenBuffer(Buffer As Any Ptr, Length As QWORD, bLoop As Boolean = True) As Boolean
	Declare Function OpenFile(File As WString, bLoop As Boolean = True) As Boolean
	Declare Function Restart() As Boolean
	Declare Sub Play()
	Declare Sub Stop()
	Declare Sub Pause()
	Declare Sub Resume()
End Type

#ifndef __USE_MAKE__
	#include once "BassPlayback.bas"
#endif
