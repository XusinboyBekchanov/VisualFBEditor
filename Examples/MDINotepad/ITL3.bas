#pragma once
' ITL3 ITaskbarList3
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

#include once "ITL3.bi"

Constructor ITL3
	mInit=False
End Constructor

Destructor ITL3
	If mInit Then tl3->lpVtbl->Release(tl3)
End Destructor

Property ITL3.WndForm() As HWND
	Return hWndForm
End Property

Property ITL3.WndForm(ByVal nVal As HWND)
	hWndForm = nVal
End Property

Sub ITL3.Initial(ByVal nVal As HWND)
	CoCreateInstance(@CLSID_TaskbarList,NULL,CLSCTX_INPROC_SERVER,@IID_ITaskbarList3,@tl3)
	tl3->lpVtbl->HrInit(tl3)
	WndForm = nVal
	mInit=True
End Sub

Function ITL3.SetValue(ullCompleted As ULONGLONG ,ullTotal As ULONGLONG) As HRESULT
	Return tl3->lpVtbl->SetProgressValue(tl3 , hWndForm , ullCompleted , ullTotal)
End Function

Function ITL3.SetState(tbpFlags As TBPFLAG) As HRESULT
	Return tl3->lpVtbl->SetProgressState(tl3 , hWndForm , tbpFlags)
End Function
