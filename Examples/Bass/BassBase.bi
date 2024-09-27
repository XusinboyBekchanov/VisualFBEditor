'BASS for freebasic translate by Cm.Wang

#pragma once

#include once "vbcompat.bi"
#include once "string.bi"
#include once "bass.bi"

#define BASS_SYNC_HLS_SEGMENT	&H10300
#define BASS_TAG_HLS_EXTINF		&h14000

Enum BassStatus
	BassStop
	BassPlay
	BassRecord
	BassPause
	BassMonitor
	BassError
End Enum

Using My.Sys.Forms

Declare Function Len2Str(Stream As HSTREAM, ByVal D As QWORD) As String

Declare Function OutputDeviceList(ByRef cbx As ComboBoxEdit Ptr) As Integer
Declare Function OutputInit(Device As Long, hHandle As HANDLE) As Boolean

Declare Function InputDeviceList(ByRef cbx As ComboBoxEdit Ptr) As Integer
Declare Function InputInit(Device As Long) As Boolean

Declare Sub InputInfo(ByRef RecInput As DWORD, cb As ComboBoxEdit Ptr, lb As Label Ptr, tb As TrackBar Ptr, vallb As Label Ptr)
Declare Sub RecSetInput(RecInput As Integer)

#ifndef __USE_MAKE__
	#include once "BassBase.bas"
#endif
