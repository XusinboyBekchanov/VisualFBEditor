#pragma once
'wavegenerator波形发生器
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

#include once "wavegenerator.bi"

Private Function WaveStart(pGUID As LPGUID, my_HWND As HWND, ByVal WaveType As Integer = 0) As HRESULT
	Dim As HRESULT hr
	
	hr = DirectSoundCreate(pGUID, @mDirectSound, NULL)
	DXTRACE_MSG("DirectSoundCreate:", hr)
	
	hr = IDirectSound_SetCooperativeLevel(mDirectSound, my_HWND, DSSCL_EXCLUSIVE)
	DXTRACE_MSG("IDirectSound_SetCooperativeLevel:", hr)
	
	mBufferLength = mSamplesPerSec / mOscillatorFreq
	DXTRACE_MSG("mBufferLength: ", mBufferLength)
	
	WaveFormatSet(mSamplesPerSec, 8, 1, @mWfEx)
	
	memset (@mDsDesc, 0, SizeOf(DSBUFFERDESC))
	With mDsDesc
		.dwSize = SizeOf (DSBUFFERDESC)
		.dwFlags = DSBCAPS_GLOBALFOCUS Or DSBCAPS_CTRLVOLUME Or DSBCAPS_CTRLFREQUENCY Or DSBCAPS_CTRLPAN
		.dwBufferBytes = mBufferLength      ' must be 0 for primary buffer
		.lpwfxFormat = @mWfEx               ' must be null for primary buffer
	End With
	
	hr = IDirectSound_CreateSoundBuffer(mDirectSound, @mDsDesc, @mSoundBuffer, NULL)
	DXTRACE_MSG("IDirectSound_CreateSoundBuffer:", hr)
	
	Static As UCHAR mByteBuffer(mBufferLength)
	
	Dim gsx As Single
	Dim i As Long
	Dim n As Single
	Dim Osc2Samp As Single
	
	ReDim mByteBuffer(mBufferLength)
	
	Select Case WaveType
	Case 0
		'sin wave正玄波
		gsx = 4 * Atn(1) * 2 / mBufferLength
		For i = 0 To mBufferLength
			n = i * gsx
			Osc2Samp = Sin(n) * 127
			mByteBuffer(i) = Osc2Samp + 128
		Next
	Case 1
		'square wave方波
		gsx = mBufferLength / 2 ' 计算周期长度
		For i = 0 To mBufferLength
			If i < gsx Then
				Osc2Samp = 0    '低电平
			Else
				Osc2Samp = 255 '高电平
			End If
			mByteBuffer(i) = Osc2Samp
		Next
	Case 2
		'sawtooth wave锯齿波
		gsx = 255
		gsx = gsx / mBufferLength ' 计算增量
		For i = 0 To mBufferLength
			Osc2Samp = i * gsx ' 递增序列
			mByteBuffer(i) = Osc2Samp
		Next
	Case 3
		'triangular wave三角波
		gsx = 510 / mBufferLength ' 计算增量
		For i = 0 To mBufferLength
			If i < mBufferLength / 2 Then
				Osc2Samp = i * gsx ' 正半周期递增
			Else
				Osc2Samp = 510 - (i * gsx) ' 负半周期递减，总幅度为510
			End If
			mByteBuffer(i) = Osc2Samp
		Next
	End Select
	
	Static As UCHAR Ptr buff1=NULL,buff2=NULL,temp
	Static As DWORD buff_len1=0,buff_len2=0
	temp = @mByteBuffer(0)
	
	hr = IDirectSoundBuffer_SetCurrentPosition(mSoundBuffer, 0)
	DXTRACE_MSG("IDirectSoundBuffer_SetCurrentPosition:", hr)
	
	hr = IDirectSoundBuffer_Lock(mSoundBuffer, 0, mBufferLength, @buff1, @buff_len1, @buff2, @buff_len2, DSBLOCK_FROMWRITECURSOR)
	DXTRACE_MSG("IDirectSoundBuffer_Lock:", hr)
	
	memcpy(buff1,temp,buff_len1)
	memcpy(buff2, (temp + buff_len1), buff_len2)
	
	DXTRACE_MSG("buff_len1: ", buff_len1)
	DXTRACE_MSG("buff_len2: ", buff_len2)
	
	hr=IDirectSoundBuffer_Unlock(mSoundBuffer,buff1,buff_len1,buff2,buff_len2)
	DXTRACE_MSG("IDirectSoundBuffer_Unlock:", hr)
	
	Return hr
End Function

Private Function WavePlay() As HRESULT
	Dim As HRESULT hr
	hr = IDirectSoundBuffer_Play(mSoundBuffer, 0, 0, DSBPLAY_LOOPING)
	DXTRACE_MSG("IDirectSoundBuffer_play:", hr)
	
	Return hr
End Function


Private Function WaveStop() As HRESULT
	Dim As HRESULT hr
	hr = IDirectSoundBuffer_Stop(mSoundBuffer)
	
	SAFE_RELEASE(mSoundBuffer)
	SAFE_RELEASE(mDirectSound)
	Return hr
End Function

