'BASS for freebasic translate by Cm.Wang

#pragma once

#define BUFSTEP 1000000 ' memory allocation unit

Type WAVEHEADER_RIFF ' == 12 bytes ==
	RIFF          As Long ' "RIFF" = &H46464952
	riffBlockSize As DWORD ' reclen - 8
	riffBlockType As Long ' "WAVE" = &H45564157
End Type

Type WAVEFORMATCM ' == 24 bytes ==
	wfBlockType As Long ' "fmt " = &H20746D66
	wfBlockSize As DWORD ' == block size begins from here = 16 bytes
	wFormatTag      As UShort
	nChannels       As UShort
	nSamplesPerSec  As Long
	nAvgBytesPerSec As Long
	nBlockAlign     As UShort
	wBitsPerSample  As UShort
End Type

Type WAVEHEADER_DATA ' == 8 bytes ==
	dataBlockType As Long ' "data" = &H61746164
	dataBlockSize As DWORD ' reclen - 44
End Type

Type BassRecord
Private : '私有变量
	' sample Format
	RecFreq As Integer
	RecChans As Integer
	' recording buffer
	RecBuf As Byte Ptr
	' recording length
	RecLen As DWORD = 0
	' recording channel
	RecStream As HSTREAM = 0
	RecMonitoring As Boolean = False
	RecStatus As BassStatus
	wr As WAVEHEADER_RIFF Ptr
	wf As WAVEFORMATCM Ptr
	wd As WAVEHEADER_DATA Ptr
Private : '私有函数
	Declare Sub Release()
	Declare Static Function RecCallBack(ByVal handle As HRECORD, ByVal recbuffer As Const Any Ptr, ByVal reclength As DWORD, ByVal user As Any Ptr) As BOOL
	Declare Function RecProcess(ByVal handle As HRECORD, ByVal recbuffer As Const Any Ptr, ByVal reclength As DWORD, ByVal user As Any Ptr) As BOOL
Public : '构造与析构函数
	Declare Constructor
	Declare Destructor
Public : '共有类的事件
Public : '共有类的方法
Public : '共有类的属性
	Declare Property Stream As HSTREAM
	Declare Property Buffer As Byte Ptr
	Declare Property Length As DWORD
	Declare Property Status As BassStatus
Public : '共有过程和函数
	Declare Function Monitor(Sample As Integer) As Boolean
	Declare Function Start(Sample As Integer) As Boolean
	Declare Function Restart() As Boolean
	Declare Sub Stop()
	Declare Sub Pause()
	Declare Sub Resume()
	Declare Sub Write(File As WString)
End Type

#ifndef __USE_MAKE__
	#include once "BassRecord.bas"
#endif
