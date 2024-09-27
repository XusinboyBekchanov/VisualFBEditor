#pragma once
'fullduplexfilter全双工滤波器
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "dsbase.bi"

Dim Shared As IDirectSound Ptr              g_pDS            = NULL
Dim Shared As IDirectSoundCapture Ptr       g_pDSCapture     = NULL
Dim Shared As IDirectSoundBuffer Ptr        g_pDSBPrimary    = NULL
Dim Shared As IDirectSoundBuffer Ptr        g_pDSBOutput     = NULL
Dim Shared As IDirectSoundCaptureBuffer Ptr g_pDSBCapture    = NULL

Dim Shared As IDirectSoundNotify Ptr        g_pDSNotify      = NULL
Dim Shared As LPDSBPOSITIONNOTIFY           g_aPosNotify

Dim Shared As HANDLE                        g_hNotificationEvent
Dim Shared As DWORD                         g_dwOutputBufferSize
Dim Shared As DWORD                         g_dwCaptureBufferSize
Dim Shared As DWORD                         g_dwNextOutputOffset
Dim Shared As DWORD                         g_dwNextCaptureOffset
Dim Shared As DWORD                         g_dwNotifySize
Dim Shared As WAVEFORMATEX                  g_WaveFormatCapture
Dim Shared As WAVEFORMATEX                  g_WaveFormatInput
Dim Shared As WAVEFORMATEX                  g_WaveFormatOutput

Declare Function InitDirectSound(hDlg As HWND, cbInput As GUID Ptr, cbOutput As GUID Ptr) As HRESULT
Declare Function FreeDirectSound() As HRESULT
Declare Function SetBufferFormats(pwfxInput As WAVEFORMATEX Ptr, pwfxOutput As WAVEFORMATEX Ptr) As HRESULT
Declare Function CreateOutputBuffer() As HRESULT
Declare Function StartBuffers() As HRESULT
Declare Function HandleNotification() As HRESULT

#ifndef __USE_MAKE__
	#include once "fullduplexfilter.bas"
#endif


