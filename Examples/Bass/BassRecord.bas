'BASS for freebasic translate by Cm.Wang

#include once "BassRecord.bi"
#pragma once

Private Constructor BassRecord
End Constructor
	
Private Destructor BassRecord
	Release()
End Destructor

Private Function BassRecord.RecCallBack(ByVal handle As HRECORD, ByVal recbuffer As Const Any Ptr, ByVal reclength As DWORD, ByVal user As Any Ptr) As BOOL
	Return (*Cast(BassRecord Ptr, user)).RecProcess (handle, recbuffer, reclength, user)
End Function

Private Function BassRecord.RecProcess(ByVal handle As HRECORD, ByVal recbuffer As Const Any Ptr, ByVal reclength As DWORD, ByVal user As Any Ptr) As BOOL
	' increase buffer size If needed
	If ((RecLen Mod BUFSTEP) + reclength >= BUFSTEP) Then
		Dim As Byte Ptr newbuf = realloc(RecBuf, ((RecLen + reclength) / BUFSTEP + 1) * BUFSTEP)
		If (newbuf = 0) Then
			RecStream = 0
			free(RecBuf)
			RecBuf = NULL
			'Out of memory!
			Return False ' Stop recording
		End If
		RecBuf = newbuf
	End If
	' buffer the Data
	memcpy(RecBuf + RecLen, recbuffer, reclength)
	RecLen += reclength
	Return True ' Continue recording
End Function

Private Function BassRecord.Restart() As Boolean
	If Buffer Then ' Continue recording On the New device... Then
		Dim As DWORD newRecStream
		If RecMonitoring Then
			newRecStream = BASS_RecordStart(RecFreq, RecChans, 0, NULL, NULL)
			RecStatus = BassStatus.BassMonitor
		Else
			newRecStream = BASS_RecordStart(RecFreq, RecChans, 0, @RecCallback, @This)
			RecStatus = BassStatus.BassPlay
		End If
		If newRecStream Then
			RecStream = newRecStream
			Return True
		EndIf
	End If
End Function

Private Function BassRecord.Start(Sample As Integer) As Boolean
	This.Release()
	
	' Allocate initial buffer And make Space For WAVE header
	RecBuf = malloc(BUFSTEP)
	RecLen = 44
	
	' Get selected sample Format
	Select Case Sample
	Case 0, 1
		RecFreq = 48000
	Case 2, 3
		RecFreq = 44100
	Case Else
		RecFreq = 22050
	End Select
	RecChans = 1 + (Sample Mod 1)
	
	RecMonitoring = False
	' start recording
	RecStream = BASS_RecordStart(RecFreq, RecChans, 0, @RecCallback, @This)
	If RecStream = 0 Then
		free(RecBuf)
		RecBuf = 0
		RecStatus = BassStatus.BassStop
		Return False
	Else
		RecStatus = BassStatus.BassPlay
		Return True
	End If
End Function

Private Function BassRecord.Monitor(Sample As Integer) As Boolean
	This.Release()
	
	' Get selected sample Format
	Select Case Sample
	Case 0, 1
		RecFreq = 48000
	Case 2, 3
		RecFreq = 44100
	Case Else
		RecFreq = 22050
	End Select
	RecChans = 1 + (Sample Mod 1)
	
	' start monitoring
	RecStream = BASS_RecordStart(RecFreq, RecChans, 0, NULL, NULL)
	If RecStream = 0 Then
		RecMonitoring = False
		Return False
	Else
		RecStatus = BassStatus.BassMonitor
		RecMonitoring = True
		Return True
	End If
End Function

Private Sub BassRecord.Release()
	If RecStream Then This.Stop()
	RecStream = NULL
	RecStatus = BassStatus.BassStop
	If (RecBuf) Then
		free(RecBuf)
		RecBuf = NULL
	End If
	RecLen = 0
End Sub

Private Sub BassRecord.Pause()
	If (RecStream) Then
		Bass_ChannelPause(RecStream)
		RecStatus = BassStatus.BassPause
	End If
End Sub

Private Sub BassRecord.Resume()
	If (RecStream) Then
		Bass_ChannelPlay(RecStream, 0)
		RecStatus = BassStatus.BassPlay
	End If
End Sub

Private Sub BassRecord.Stop()
	If RecStream Then
		BASS_ChannelStop(RecStream)
		RecStream = NULL
		RecStatus = BassStatus.BassStop
		If RecMonitoring = False Then
			' fill the WAVE header
			wr = Cast(WAVEHEADER_RIFF Ptr, RecBuf)
			wf = Cast(WAVEFORMATCM Ptr, RecBuf + 12)
			wd = Cast(WAVEHEADER_DATA Ptr, RecBuf + 36)
			
			' Set WAV "RIFF" header
			wr->RIFF          = &H46464952 ' "RIFF"
			'	wr->riffBlockSize = 0      ' after recording
			wr->riffBlockType = &H45564157 ' "WAVE"
			
			' Set WAV "fmt " header
			wf->wfBlockType = &H20746D66 ' "fmt "
			wf->wfBlockSize = 16
			wf->wFormatTag  = 1
			
			wf->nChannels      = RecChans
			wf->wBitsPerSample =  16
			wf->nSamplesPerSec = RecFreq
			wf->nBlockAlign     = wf->nChannels      * wf->wBitsPerSample / 8
			wf->nAvgBytesPerSec = wf->nSamplesPerSec * wf->nBlockAlign
			
			' set WAV "data" header
			wd->dataBlockType = &H61746164 ' "data"
			
			wr->riffBlockSize = RecLen - 8
			wd->dataBlockSize = RecLen - 44
		End If
	End If
End Sub

Private Sub BassRecord.Write(File As WString)
	Dim FileHandle As Any Ptr, WriteLen As Long, OF As OFSTRUCT
	
	FileHandle = CreateFileW(File, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL)
	If (FileHandle = 0) Then Return
	
	WriteFile(FileHandle, RecBuf, RecLen, @WriteLen, NULL)
	CloseHandle(FileHandle)
End Sub

Private Property BassRecord.Stream As HSTREAM
	Property = RecStream
End Property

Private Property BassRecord.Buffer As Byte Ptr
	Property = RecBuf
End Property

Private Property BassRecord.Length As DWORD
	Property = RecLen
End Property

Private Property BassRecord.Status As BassStatus
	Property = RecStatus
End Property

