'BASS for freebasic translate by Cm.Wang

#pragma once

Type BassRaido
Public : '共有变量
	mOwner As Any Ptr = 0
Private : '私有变量
	RaidoLock As CRITICAL_SECTION
	RaidoStream As HSTREAM ' stream chandle
	RaidoStatus As BassStatus
	
Private : '私有函数
	Declare Static Sub MetaSync(ByVal chandle As HSYNC, ByVal channel As DWORD, ByVal cData As DWORD, ByVal user As Any Ptr)
	Declare Static Sub StallSync(ByVal chandle As HSYNC, ByVal channel As DWORD, ByVal cData As DWORD, ByVal user As Any Ptr)
	Declare Static Sub FreeSync(ByVal chandle As HSYNC, ByVal channel As DWORD, ByVal cData As DWORD, ByVal user As Any Ptr)
	Declare Static Sub StatusProc(ByVal buffer As Const Any Ptr, ByVal length As DWORD, ByVal user As Any Ptr)
	
Public : '构造与析构函数
	Declare Constructor
	Declare Destructor
Public : '共有类的事件
	OnMeta As Sub(Owner As Any Ptr, Meta As ZString Ptr)
	OnFree As Sub(Owner As Any Ptr)
	OnStall As Sub(Owner As Any Ptr)
	OnStatus As Sub(Owner As Any Ptr, Status As ZString Ptr)
Public : '共有类的方法
Public : '共有类的属性
	Declare Property Stream As HSTREAM
Public : '共有过程和函数
	Declare Function OpenURL(Owner As Any Ptr, ByVal url As String) As HSTREAM
	Declare Sub Stop()
	Declare Sub Pause()
	Declare Sub Resume()
	Declare Sub DoMeta()
End Type


#ifndef __USE_MAKE__
	#include once "BassRaido.bas"
#endif
