'BASS for freebasic translate by Cm.Wang

#include once "BassPlayback.bi"
#pragma once

Private Constructor BassPlayback
	PlayStatus = BassStatus.BassStop
	PlayBuffer = False 
End Constructor
	
Private Destructor BassPlayback
	Stop()
End Destructor

Private Sub BassPlayback.Pause()
	If (PlayStream) Then
		Bass_ChannelPause(PlayStream)
		PlayStatus = BassStatus.BassPause
	End If
End Sub

Private Sub BassPlayback.Play()
	If (PlayStream) Then
		Bass_ChannelPlay(PlayStream, 0)
		PlayStatus = BassStatus.BassPlay
	End If
End Sub

Private Sub BassPlayback.Resume()
	Play()
End Sub

Private Function BassPlayback.OpenBuffer(aBuffer As Any Ptr, qLength As QWORD, bLoop As Boolean = True) As Boolean
	Stop()
	
	Dim As DWORD flag = BASS_SAMPLE_FX Or BASS_UNICODE
	If bLoop Then flag = flag Or BASS_SAMPLE_LOOP
	PlayStream = BASS_StreamCreateFile(True , aBuffer, 0, qLength, flag)
	If PlayStream Then
		PlayLength = BASS_ChannelGetLength(PlayStream , BASS_POS_BYTE)
		Play()
		PlayBuffer = True
		Return True
	End If
End Function

Private Function BassPlayback.OpenFile(File As WString, bLoop As Boolean = True) As Boolean
	Stop()
	
	Dim As DWORD flag = BASS_SAMPLE_FX Or BASS_UNICODE
	If bLoop Then flag = flag Or BASS_SAMPLE_LOOP
	PlayStream = BASS_StreamCreateFile(0 , @File, 0, 0, flag)
	If PlayStream Then
		PlayLength = BASS_ChannelGetLength(PlayStream , BASS_POS_BYTE)
		Play()
		PlayBuffer = False
		Return True
	End If
End Function

Private Sub BassPlayback.Stop()
	If PlayStream Then
		Bass_ChannelStop(PlayStream)
		Bass_StreamFree(PlayStream)
		PlayStream = 0
		PlayStatus = BassStatus.BassStop
		PlayBuffer = False
	End If
End Sub

Private Property BassPlayback.BufferPlaying As Boolean
	Property = PlayBuffer
End Property

Private Property BassPlayback.Status As BassStatus
	Property = PlayStatus
End Property

Private Property BassPlayback.Stream As HSTREAM
	Property = PlayStream
End Property

Private Property BassPlayback.Length As DWORD
	Property = PlayLength
End Property

Private Property BassPlayback.Position As DWORD
	PlayPosition = BASS_ChannelGetPosition(PlayStream, BASS_POS_BYTE)
	Property = PlayPosition
End Property

Private Property BassPlayback.Position(dpos As DWORD)
	BASS_ChannelSetPosition(PlayStream, dpos, BASS_POS_BYTE)
	PlayPosition = dpos
End Property

