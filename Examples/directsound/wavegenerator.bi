#pragma once
'wavegenerator波形发生器
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

#include once "dsbase.bi"

Dim Shared As IDirectSound Ptr          mDirectSound = NULL
Dim Shared As IDirectSoundBuffer Ptr    mSoundBuffer = NULL
Dim Shared As DSBUFFERDESC              mDsDesc
Dim Shared As WAVEFORMATEX              mWfEx

Dim Shared As Integer mBufferLength
Dim Shared As Integer mOscillatorFreq = 4410
Dim Shared As Integer mSamplesPerSec = 44100

#ifndef __USE_MAKE__
	#include once "wavegenerator.bas"
#endif

