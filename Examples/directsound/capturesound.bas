#pragma once
'capturesound声音捕捉
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "capturesound.bi"

Private Function WaveFileCreate(WaveFile As ZString Ptr, ByVal sample As Long = 44100, ByVal bits As Long = 16, ByVal channel As Long = 1) As Boolean
	wavHeader.fmt.nSamplesPerSec = sample
	wavHeader.fmt.wBitsPerSample = IIf(bits = 8, 8, 16)
	wavHeader.fmt.nChannels      = IIf(channel = 1, 1, 2)
	wavHeader.fmt.nBlockAlign     = wavHeader.fmt.nChannels      * wavHeader.fmt.wBitsPerSample / 8
	wavHeader.fmt.nAvgBytesPerSec = wavHeader.fmt.nSamplesPerSec * wavHeader.fmt.nBlockAlign
	
	Dim As FILE Ptr fileHandle = fopen(WaveFile, @Str("wb"))
	If fileHandle = NULL Then
		Print "WaveFileCreate: Failed to open file for writing"
		Return False
	End If
	Dim As DWORD bytesWritten = fwrite(@wavHeader, 1, SizeOf(wavHeader), fileHandle)
	fclose(fileHandle)
	If bytesWritten <> SizeOf(wavHeader) Then
		Print "WaveFileCreate: Failed to write all data to file"
		Return False
	End If
	
	Return True
End Function

Private Function WaveFileWriteData(WaveFile As ZString Ptr, bufferData As LPBYTE, bufferSize As DWORD) As Boolean
	Dim As FILE Ptr fileHandle
	
	fileHandle = fopen(WaveFile, @Str("ab"))
	If fileHandle = NULL Then
		Print "WaveFileWriteData: Failed to open file for writing"
		Return False
	End If
	
	Dim As DWORD bytesWritten = fwrite(bufferData, 1, bufferSize, fileHandle)
	fclose(fileHandle)
	
	If bytesWritten <> bufferSize Then
		Print "WaveFileWriteData: Failed to write all data to file"
		Return False
	End If
	
	Return True
End Function

Private Function WaveFileClose(WaveFile As ZString Ptr) As Boolean
	Dim As FILE Ptr fileHandle = fopen(WaveFile, @Str("r+"))
	If fileHandle = NULL Then
		Print "WaveFileClose: Failed to open file for writing"
		Return False
	End If
	Dim As DWORD filesize = ftell(fileHandle)
	
	wavHeader.riff.riffBlockSize = filesize - SizeOf(WAVEHEADER_DATA)
	wavHeader.data.dataBlockSize = filesize - SizeOf(WAVEHEADER)
	
	fseek(fileHandle, 0, SEEK_SET)
	Dim As DWORD bytesWritten = fwrite(@wavHeader, 1, SizeOf(wavHeader), fileHandle)
	fclose(fileHandle)
	If bytesWritten <> SizeOf(wavHeader) Then
		Print "WaveFileClose: Failed to write all data to file"
		Return False
	End If
	
	Return True
End Function

Private Function InitNotifications() As HRESULT
	Dim As HRESULT hr
	
	' Create a notification event, for when the sound stops playing
	hr = g_pDSBCapture->lpVtbl->QueryInterface(g_pDSBCapture, @IID_IDirectSoundNotify, @g_pDSNotify)
	DXTRACE_MSG("InitNotifications()g_pDSBCapture->lpVtbl->QueryInterface", hr)
	
	' Setup the notification positions
	g_aPosNotify = New DSBPOSITIONNOTIFY[NUM_REC_NOTIFICATIONS]
	For i As Integer = 0 To NUM_REC_NOTIFICATIONS - 1
		g_aPosNotify[i].dwOffset = (g_dwNotifySize * i) + g_dwNotifySize - 1
		g_aPosNotify[i].hEventNotify = g_hNotificationEvent
	Next
	
	' Tell DirectSound when to notify us. the notification will come in the from
	' of signaled events that are handled in WinMain()
	hr = g_pDSNotify->lpVtbl->SetNotificationPositions(g_pDSNotify, NUM_REC_NOTIFICATIONS, g_aPosNotify)
	DXTRACE_MSG("InitNotifications()g_pDSNotify->lpVtbl->SetNotificationPositions", hr)
	
	Return hr
End Function

Private Function CreateCaptureBuffer(pwfxInput As WAVEFORMATEX Ptr) As HRESULT
	Dim As HRESULT hr
	Dim As DSCBUFFERDESC dscbd
	
	'Set the notification size
	g_dwNotifySize = Max(1024, pwfxInput->nAvgBytesPerSec / 8)
	g_dwNotifySize -= g_dwNotifySize Mod pwfxInput->nBlockAlign
	DXTRACE_MSG("CreateCaptureBuffer()g_dwNotifySize", g_dwNotifySize)
	
	'Set the buffer sizes
	g_dwCaptureBufferSize = g_dwNotifySize * NUM_REC_NOTIFICATIONS
	DXTRACE_MSG("CreateCaptureBuffer()g_dwCaptureBufferSize", g_dwCaptureBufferSize)
	
	'Create the capture buffer
	dscbd.dwSize        = SizeOf(DSCBUFFERDESC)
	dscbd.dwBufferBytes = g_dwCaptureBufferSize
	dscbd.lpwfxFormat   = pwfxInput ' Set the format during creatation
	
	hr = g_pDSCapture->lpVtbl->CreateCaptureBuffer(g_pDSCapture, @dscbd, @g_pDSBCapture, NULL)
	DXTRACE_MSG("CreateCaptureBuffer()g_pDSCapture->lpVtbl->CreateCaptureBuffer", hr)
	
	g_dwNextCaptureOffset = 0
	
	Return hr
End Function

Private Function RecordCapturedData(WaveFile As ZString Ptr) As DWORD
	Dim As HRESULT  hr
	Dim As VOID Ptr pbCaptureData    = NULL
	Dim As DWORD    dwCaptureLength
	Dim As VOID Ptr pbCaptureData2   = NULL
	Dim As DWORD    dwCaptureLength2
	Dim As VOID Ptr pbPlayData       = NULL
	Dim As UINT     dwDataWrote
	Dim As DWORD    dwReadPos
	Dim As DWORD    dwCapturePos
	Dim As Long     lLockSize
	
	If (NULL = g_pDSBCapture) Then DXTRACE_MSG("RecordCapturedData()g_pDSBCapture", S_FALSE)
	
	hr = g_pDSBCapture->lpVtbl->GetCurrentPosition(g_pDSBCapture, @dwCapturePos, @dwReadPos)
	DXTRACE_MSG("RecordCapturedData()g_pDSBCapture->lpVtbl->GetCurrentPosition", hr)
	DXTRACE_MSG("RecordCapturedData()dwCapturePos", dwCapturePos)
	DXTRACE_MSG("RecordCapturedData()dwReadPos", dwReadPos)
	
	lLockSize = dwReadPos - g_dwNextCaptureOffset
	If (lLockSize < 0) Then lLockSize += g_dwCaptureBufferSize
	
	' Block align lock size so that we are always write on a boundary
	lLockSize -= (lLockSize Mod g_dwNotifySize)
	
	If (lLockSize = 0) Then DXTRACE_MSG("RecordCapturedData()lLockSize = 0", S_FALSE) 
	
	' Lock the capture buffer down
	hr = g_pDSBCapture->lpVtbl->Lock(g_pDSBCapture, g_dwNextCaptureOffset, lLockSize, @pbCaptureData, @dwCaptureLength, @pbCaptureData2, @dwCaptureLength2, 0L)
	DXTRACE_MSG("RecordCapturedData()g_pDSBCapture->lpVtbl->Lock", hr)

	' Write the data into the wav file
	WaveFileWriteData(WaveFile, pbCaptureData, dwCaptureLength)
	
	' Move the capture offset along
	g_dwNextCaptureOffset += dwCaptureLength
	g_dwNextCaptureOffset = (g_dwNextCaptureOffset Mod g_dwCaptureBufferSize) ' Circular buffer
	
	If (pbCaptureData2 <> NULL) Then
		' Write the data into the wav file
		
		WaveFileWriteData(WaveFile, pbCaptureData2, dwCaptureLength2)
		
		' Move the capture offset along
		g_dwNextCaptureOffset += dwCaptureLength2
		g_dwNextCaptureOffset = (g_dwNextCaptureOffset Mod g_dwCaptureBufferSize) ' Circular buffer
	End If
	
	' Unlock the capture buffer
	hr = g_pDSBCapture->lpVtbl->Unlock(g_pDSBCapture, pbCaptureData,  dwCaptureLength, pbCaptureData2, dwCaptureLength2)
	DXTRACE_MSG("RecordCapturedData()g_pDSBCapture->lpVtbl->Unlock", hr)
	
	Return dwCaptureLength
End Function

Private Function RecordStart() As HRESULT
	Dim As HRESULT hr
	
	hr = g_pDSBCapture->lpVtbl->Start(g_pDSBCapture, DSCBSTART_LOOPING)
	DXTRACE_MSG("RecordStart()g_pDSBCapture->lpVtbl->Start", hr)

	Return hr
End Function

Private Function RecordStop() As HRESULT
	Dim As HRESULT hr
	
	' Stop the capture and read any data that
	' was not caught by a notification
	If (NULL = g_pDSBCapture) Then Return S_OK
	
	' Stop the buffer, and read any data that was not
	' caught by a notification
	hr = g_pDSBCapture->lpVtbl->Stop(g_pDSBCapture)
	DXTRACE_MSG("RecordStop()g_pDSBCapture->lpVtbl->Stop", hr)
	
	Return hr
End Function

Private Function InitDirectSound(hDlg As HWND, pDeviceGuid As GUID Ptr) As HRESULT
	Dim As HRESULT hr
	FreeDirectSound()
	
	g_dwCaptureBufferSize = 0
	g_dwNotifySize        = 0
	
	' Create IDirectSoundCapture Using the preferred capture device
	hr = DirectSoundCaptureCreate(pDeviceGuid, @g_pDSCapture, NULL)
	DXTRACE_MSG("InitDirectSound()DirectSoundCaptureCreate", hr)
	
	Return hr
End Function

Private Function FreeDirectSound() As HRESULT
	' Release DirectSound interfaces
	SAFE_RELEASE(g_pDSNotify)
	SAFE_RELEASE(g_pDSBCapture)
	SAFE_RELEASE(g_pDSCapture)
	
	SAFE_DELETE_ARRAY(g_aPosNotify)
	
	g_dwCaptureBufferSize = 0
	g_dwNotifySize        = 0
	
	Return S_OK
End Function

