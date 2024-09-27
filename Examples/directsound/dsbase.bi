#pragma once
'dsbase ds基础库
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "mff/ComboBoxEdit.bi"
Using My.Sys.Forms

#include once "win/mmreg.bi"
#include once "win/mmsystem.bi"
#include once "crt/fcntl.bi"
#include once "win/dbt.bi"
#include once "win/msacm.bi"
#include once "win/mmsystem.bi"
#include once "win/d3d9types.bi"
#include once "win/dsound.bi"
#include once "win/dshow.bi"
#include once "win/winbase.bi"
#include once "win/winnt.bi"
#include once "win/windowsx.bi"
#include once "win/dmusicc.bi"
#include once "win/dmusici.bi"
#include once "win/dsound.bi"

#include once "vbcompat.bi"

#define SAFE_DELETE(p) If (p) Then Delete (p) : (p) = NULL
#define SAFE_DELETE_ARRAY(p) If (p) Then Delete[] (p) : (p) = NULL
#define SAFE_RELEASE(p) If (p) Then (p)->lpVtbl->Release((p)) : (p) = NULL

#define NUM_REC_NOTIFICATIONS 16
#define NUM_PLAY_NOTIFICATIONS 16
#define NUM_BUFFERS (16)

#define DXTRACE_ERR(Str, hr) Debug.Print "DXTRACE_ERR " & hr & ": " & Str : Return hr
#define DXTRACE_MSG(Str, hr) Debug.Print "DXTRACE_MSG " & hr & ": " & Str
#define DXTRACE_PRINT(Str, hr) Print "DXTRACE_MSG " & hr & ": " & Str
#define DXTRACE_DEBUG(Str, hr) Debug.Print "DXTRACE_DEBUG " & hr & ": " & Str: Return

#define WAVEFILE_READ   1
#define WAVEFILE_WRITE  2

#define WAVEFILE_READ   1
#define WAVEFILE_WRITE  2

Declare Function DSoundEnumCallback(ByVal pGUID As LPGUID, ByVal strDesc As LPCWSTR, ByVal strDrvName As LPCWSTR, ByVal pContext As LPVOID) As WINBOOL
Declare Sub WaveFormatSet(Samples As Integer, Bits As Integer, Channels As Integer, pwfx As WAVEFORMATEX Ptr)
Declare Sub WaveFormat2Combo(Cb1 As LPVOID, Cb2 As LPVOID, Cb3 As LPVOID)

#ifndef __USE_MAKE__
	#include once "dsbase.bas"
#endif

