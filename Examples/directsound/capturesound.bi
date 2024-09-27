#pragma once
'capturesound声音捕捉
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "mff/ComboBoxEdit.bi"
Using My.Sys.Forms

#include once "dsbase.bi"

Dim Shared As IDirectSoundCapture Ptr           g_pDSCapture           = NULL
Dim Shared As IDirectSoundCaptureBuffer Ptr     g_pDSBCapture          = NULL
Dim Shared As IDirectSoundNotify Ptr            g_pDSNotify            = NULL

Dim Shared As WAVEFORMATEX                      g_wfxInput

Dim Shared As DWORD                             g_dwNotifySize
Dim Shared As LPDSBPOSITIONNOTIFY               g_aPosNotify           = NULL
Dim Shared As HANDLE                            g_hNotificationEvent

Dim Shared As DWORD                             g_dwCaptureBufferSize
Dim Shared As DWORD                             g_dwNextCaptureOffset

Type WAVEHEADER_RIFF ' == 12 bytes ==
	RIFF          As Long = &H46464952 ' "RIFF"
	riffBlockSize As DWORD ' reclen - 8
	riffBlockType As Long = &H45564157 ' "WAVE"
End Type

Type WAVEHEADER_FMT ' == 24 bytes ==
	wfBlockType As Long         = &H20746D66 ' "fmt "
	wfBlockSize As DWORD        = 16 ' == block size begins from here = 16 bytes
	wFormatTag      As UShort   = WAVE_FORMAT_PCM
	nChannels       As UShort
	nSamplesPerSec  As Long
	nAvgBytesPerSec As Long
	nBlockAlign     As UShort
	wBitsPerSample  As UShort
End Type

Type WAVEHEADER_DATA ' == 8 bytes ==
	dataBlockType As Long = &H61746164 ' "data"
	dataBlockSize As DWORD ' reclen - 44
End Type

Type WAVEHEADER
	riff As WAVEHEADER_RIFF
	fmt As WAVEHEADER_FMT
	data As WAVEHEADER_DATA
End Type

Dim Shared As WAVEHEADER wavHeader

Declare Function WaveFileCreate(WaveFile As ZString Ptr, ByVal sample As Long = 44100, ByVal bits As Long = 16, ByVal channel As Long = 1) As Boolean
Declare Function WaveFileWriteData(WaveFile As ZString Ptr, bufferData As LPBYTE, bufferSize As DWORD) As Boolean
Declare Function WaveFileClose(WaveFile As ZString Ptr) As Boolean
Declare Function InitNotifications() As HRESULT
Declare Function CreateCaptureBuffer(pwfxInput As WAVEFORMATEX Ptr) As HRESULT
Declare Function RecordCapturedData(WaveFile As ZString Ptr) As DWORD
Declare Function RecordStart() As HRESULT
Declare Function RecordStop() As HRESULT
Declare Function InitDirectSound(hDlg As HWND, pDeviceGuid As GUID Ptr) As HRESULT
Declare Function FreeDirectSound() As HRESULT

#ifndef __USE_MAKE__
	#include once "capturesound.bas"
#endif
