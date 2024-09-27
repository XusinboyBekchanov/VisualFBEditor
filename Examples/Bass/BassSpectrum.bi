'BASS for freebasic translate by Cm.Wang

#pragma once

Type BassSpectrum
Private : '私有变量
	SpecWidth  As Integer = 368 ' display width
	SpecHeight As Integer = 127 ' height (changing requires palette adjustments too)
	
	specbuf(Any) As Byte
	
	specmode As Integer ' spectrum mode
	specpos As Integer ' marker Pos For 3D mode
	
	bh As BITMAPINFO Ptr
	dt(Any) As Byte
Private : '私有函数
	
Public : '构造与析构函数
	Declare Constructor
	Declare Destructor
Public : '共有类的事件
Public : '共有类的方法
Public : '共有类的属性
	Declare Property Mode() As Integer 
	Declare Property Mode(ByVal nVal As Integer)
	
Public : '共有过程和函数
	Declare Sub Init(w As Integer = 368 , h As Integer = 127)
	Declare Sub Update(Chan As DWORD, hWnd As HANDLE)
End Type

#ifndef __USE_MAKE__
	#include once "BassSpectrum.bas"
#endif
