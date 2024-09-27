'enumdevices设备枚举
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "dsbase.bi"

Dim Shared As IDirectSound Ptr          g_pDS        = NULL
Dim Shared As IDirectSoundCapture Ptr   g_pDSCapture = NULL

Declare Function FreeDirectSound() As HRESULT
Declare Function InitDirectSound(pSoundGUID As GUID Ptr, pCaptureGUID As GUID Ptr) As HRESULT

#ifndef __USE_MAKE__
	#include once "enumdevices.bas"
#endif

