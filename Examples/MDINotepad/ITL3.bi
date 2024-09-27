#pragma once
' ITL3 ITaskbarList3
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

Type ITL3
Private : '私有变量
	hWndForm As HWND
	mInit As Long
	tl3 As ITaskbarList3 Ptr
Public :
	'构造与析构函数
	Declare Constructor
	Declare Destructor
	'共有函数，类的方法
	Declare Function SetState(tbpFlags As TBPFLAG) As HRESULT
	Declare Function SetValue(ullCompleted As ULONGLONG, ullTotal As ULONGLONG) As HRESULT
	Declare Sub Initial(ByVal nVal As HWND)
	'共有函数，类的属性
	Declare Property WndForm() As HWND
	Declare Property WndForm(ByVal nVal As HWND)
End Type

#ifndef __USE_MAKE__
	#include once "ITL3.bas"
#endif
