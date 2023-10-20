'fullduplexfilter全双工滤波器
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

#include once "fullduplexfilter.bi"

'-----------------------------------------------------------------------------
'Name: InitDirectSound()
'Desc: Initilizes DirectSound
'-----------------------------------------------------------------------------
Private Function InitDirectSound(hDlg As HWND, cbInput As GUID Ptr, cbOutput As GUID Ptr) As HRESULT
	Dim As HRESULT hr
	Dim As DSBUFFERDESC dsbdesc
	
	'ZeroMemory(@g_aPosNotify, SizeOf(DSBPOSITIONNOTIFY) * NUM_PLAY_NOTIFICATIONS)
	g_dwOutputBufferSize  = 0
	g_dwCaptureBufferSize = 0
	g_dwNotifySize        = 0
	g_dwNextOutputOffset  = 0
	
	'Create IDirectSound using the preferred sound device
	hr = DirectSoundCreate(cbOutput, @g_pDS, NULL)
	DXTRACE_MSG("InitDirectSound()DirectSoundCreate(cbOutput, @g_pDS, NULL)", hr)
	
	'Set coop level to DSSCL_PRIORITY
	hr = g_pDS->lpVtbl->SetCooperativeLevel(g_pDS, hDlg, DSSCL_PRIORITY)
	DXTRACE_MSG("InitDirectSound()g_pDS->lpVtbl->SetCooperativeLevel(g_pDS, hDlg, DSSCL_PRIORITY)", hr)
	
	'Obtain primary buffer
	'ZeroMemory(@dsbdesc, SizeOf(DSBUFFERDESC))
	With dsbdesc
		.dwSize  = SizeOf(DSBUFFERDESC)
		.dwFlags = DSBCAPS_PRIMARYBUFFER Or DSBCAPS_CTRLVOLUME
	End With
	hr = g_pDS->lpVtbl->CreateSoundBuffer(g_pDS, @dsbdesc, @g_pDSBPrimary, NULL)
	DXTRACE_MSG("InitDirectSound()g_pDS->lpVtbl->CreateSoundBuffer(g_pDS, @dsbdesc, @g_pDSBPrimary, NULL)", hr)
	
	'Create IDirectSoundCapture using the preferred capture device
	hr = DirectSoundCaptureCreate(cbInput, @g_pDSCapture, NULL)
	DXTRACE_MSG("InitDirectSound()DirectSoundCaptureCreate(cbInput, @g_pDSCapture, NULL)", hr)
	
	Return S_OK
End Function

'-----------------------------------------------------------------------------
'Name: FreeDirectSound()
'Desc: Releases DirectSound
'-----------------------------------------------------------------------------
Private Function FreeDirectSound() As HRESULT
	'Release DirectSound interfaces
	SAFE_DELETE_ARRAY(g_aPosNotify)
	SAFE_RELEASE(g_pDSNotify)
	SAFE_RELEASE(g_pDSBPrimary)
	SAFE_RELEASE(g_pDSBOutput)
	SAFE_RELEASE(g_pDSBCapture)
	SAFE_RELEASE(g_pDSCapture)
	SAFE_RELEASE(g_pDS)
	Return S_OK
End Function

'-----------------------------------------------------------------------------
'Name: SetBufferFormats()
'Desc: Sets the buffer formats for the primary buffer, and the capture buffer
'-----------------------------------------------------------------------------
Private Function SetBufferFormats(pwfxInput As WAVEFORMATEX Ptr, pwfxOutput As WAVEFORMATEX Ptr) As HRESULT
	If g_pDSBPrimary = NULL Or g_pDSCapture = NULL Then Return S_FALSE
	
	Dim As HRESULT hr
	'Set the format of the primary buffer
	'to the format of the output buffer
	hr = g_pDSBPrimary->lpVtbl->SetFormat(g_pDSBPrimary, pwfxOutput)
	DXTRACE_MSG("SetBufferFormats()g_pDSBPrimary->lpVtbl->SetFormat(g_pDSBPrimary, pwfxOutput)", hr)
	
	'Set the notification size
	g_dwNotifySize = Max(4069, pwfxInput->nAvgBytesPerSec / 8)
	g_dwNotifySize -= g_dwNotifySize Mod pwfxInput->nBlockAlign
	
	'Set the buffer sizes
	g_dwOutputBufferSize  = g_dwNotifySize * NUM_PLAY_NOTIFICATIONS / 2
	g_dwCaptureBufferSize = g_dwNotifySize * NUM_PLAY_NOTIFICATIONS
	
	'Create the capture buffer
	'SAFE_RELEASE(g_pDSBCapture)
	Dim As DSCBUFFERDESC dscbd
	'ZeroMemory(@dscbd, SizeOf(dscbd))
	dscbd.dwSize        = SizeOf(dscbd)
	dscbd.dwBufferBytes = g_dwCaptureBufferSize
	dscbd.lpwfxFormat   = pwfxInput 'Set the format during creatation
	hr = g_pDSCapture->lpVtbl->CreateCaptureBuffer(g_pDSCapture, @dscbd, @g_pDSBCapture, NULL)
	DXTRACE_MSG("SetBufferFormats()g_pDSCapture->lpVtbl->CreateCaptureBuffer(g_pDSCapture, @dscbd, @g_pDSBCapture, NULL)", hr)
	
	Return hr
End Function

'-----------------------------------------------------------------------------
'Name: CreateOutputBuffer()
'Desc: Creates the ouptut buffer and sets up the notification positions
'      on the capture buffer
'-----------------------------------------------------------------------------
Private Function CreateOutputBuffer() As HRESULT
	Dim As HRESULT hr
	Dim As WAVEFORMATEX wfxInput

	If g_hNotificationEvent = NULL Then g_hNotificationEvent = CreateEvent(NULL, False, False, NULL)
	Debug.Print "g_hNotificationEvent: " & g_hNotificationEvent
	
	DXTRACE_MSG("CreateOutputBuffer()g_pDSBCapture", g_pDSBCapture)
	DXTRACE_MSG("CreateOutputBuffer()g_pDS", g_pDS)
	DXTRACE_MSG("CreateOutputBuffer()g_hNotificationEvent", g_hNotificationEvent)
	DXTRACE_MSG("CreateOutputBuffer()g_dwOutputBufferSize", g_dwOutputBufferSize)
	DXTRACE_MSG("CreateOutputBuffer()g_dwNotifySize", g_dwNotifySize)
		
	If g_pDSBCapture = NULL Or g_pDS = NULL Or g_hNotificationEvent = NULL Or g_dwOutputBufferSize = 0 Or g_dwNotifySize = 0 Then
		DXTRACE_ERR("CreateOutputBuffer() exit", S_FALSE)
	End If
	
	'This sample works by creating notification events which
	'are signaled when the capture buffer reachs specific offsets
	'WinMain() waits for the associated event to be signaled, and
	'when it is, it calls HandleNotifications() which copy the
	'data from the capture buffer into the output buffer
	'ZeroMemory(@wfxInput, SizeOf(wfxInput))
	hr = g_pDSBCapture->lpVtbl->GetFormat(g_pDSBCapture, @wfxInput, SizeOf(wfxInput), NULL)
	DXTRACE_MSG("CreateOutputBuffer()g_pDSBCapture->lpVtbl->GetFormat(g_pDSBCapture, @wfxInput, SizeOf(wfxInput), NULL)", hr)
	'Create the direct sound buffer using the same format as the
	'capture buffer.
	Dim As DSBUFFERDESC dsbd
	'ZeroMemory(@dsbd, SizeOf(DSBUFFERDESC))
	dsbd.dwSize          = SizeOf(DSBUFFERDESC)
	dsbd.dwFlags         = DSBCAPS_GLOBALFOCUS Or DSBCAPS_CTRLVOLUME
	dsbd.dwBufferBytes   = g_dwOutputBufferSize
	dsbd.guid3DAlgorithm = GUID_NULL
	dsbd.lpwfxFormat     = @wfxInput
	'Create the DirectSound buffer
	hr = g_pDS->lpVtbl->CreateSoundBuffer(g_pDS, @dsbd, @g_pDSBOutput, NULL)
	DXTRACE_MSG("CreateOutputBuffer()g_pDS->lpVtbl->CreateSoundBuffer(g_pDS, @dsbd, @g_pDSBOutput, NULL)", hr)
	
	'Create a notification event, for when the sound stops playing
	hr = g_pDSBCapture->lpVtbl->QueryInterface(g_pDSBCapture, @IID_IDirectSoundNotify, @g_pDSNotify)
	DXTRACE_MSG("CreateOutputBuffer()g_pDSBCapture->lpVtbl->QueryInterface(g_pDSBCapture, @IID_IDirectSoundNotify, @g_pDSNotify)", hr)
	
	'Setup the notification positions
	g_aPosNotify = New DSBPOSITIONNOTIFY[NUM_PLAY_NOTIFICATIONS]
	For i As Integer = 0 To NUM_PLAY_NOTIFICATIONS - 1
		g_aPosNotify[i].dwOffset = (g_dwNotifySize * i) + g_dwNotifySize - 1
		g_aPosNotify[i].hEventNotify = g_hNotificationEvent
	Next
	
	'Tell DirectSound when to notify us. the notification will come in the from
	'of signaled events that are handled in WinMain()
	hr = g_pDSNotify->lpVtbl->SetNotificationPositions(g_pDSNotify, NUM_PLAY_NOTIFICATIONS, g_aPosNotify)
	DXTRACE_MSG("CreateOutputBuffer()g_pDSNotify->lpVtbl->SetNotificationPositions(g_pDSNotify, NUM_PLAY_NOTIFICATIONS, g_aPosNotify)", hr)
	
	Return hr
End Function

'-----------------------------------------------------------------------------
'Name: StartBuffers()
'Desc: Start the capture buffer, and the start playing the output buffer
'-----------------------------------------------------------------------------
Private Function StartBuffers() As HRESULT
	Dim As WAVEFORMATEX wfxOutput
	Dim As Any Ptr pDSLockedBuffer =  NULL
	Dim As DWORD dwDSLockedBufferSize
	Dim As HRESULT hr
	
	If g_pDSBCapture = NULL Or g_pDSBOutput = NULL Then Return S_FALSE
	
	'Find out where the capture buffer is right now, then write data
	'some extra amount forward to make sure we're ahead of the write cursor
	hr = g_pDSBCapture->lpVtbl->GetCurrentPosition(g_pDSBCapture, @g_dwNextCaptureOffset, NULL)
	DXTRACE_MSG("StartBuffers()g_pDSBCapture->lpVtbl->GetCurrentPosition", hr)
	
	g_dwNextCaptureOffset -= g_dwNextCaptureOffset Mod g_dwNotifySize
	g_dwNextOutputOffset = g_dwNextCaptureOffset + (2 * g_dwNotifySize)
	g_dwNextOutputOffset = g_dwNextOutputOffset Mod g_dwOutputBufferSize  'Circular buffer
	'Tell the capture buffer to start recording
	hr = g_pDSBCapture->lpVtbl->Start(g_pDSBCapture, DSCBSTART_LOOPING)
	DXTRACE_MSG("StartBuffers()g_pDSBCapture->lpVtbl->Start", hr)
	
	'Rewind the output buffer, fill it with silence, and play it
	hr = g_pDSBOutput->lpVtbl->SetCurrentPosition(g_pDSBOutput, g_dwNextOutputOffset)
	DXTRACE_MSG("StartBuffers()g_pDSBOutput->lpVtbl->SetCurrentPosition", hr)
	
	'Save the format of the capture buffer in g_pCaptureWaveFormat
	'ZeroMemory(@g_WaveFormatCapture, SizeOf(WAVEFORMATEX))
	hr = g_pDSBCapture->lpVtbl->GetFormat(g_pDSBCapture, @g_WaveFormatCapture, SizeOf(WAVEFORMATEX), NULL)
	DXTRACE_MSG("StartBuffers()g_pDSBCapture->lpVtbl->GetFormat", hr)
	
	'Get the format of the output buffer
	'ZeroMemory(@wfxOutput, SizeOf(wfxOutput))
	hr = g_pDSBOutput->lpVtbl->GetFormat(g_pDSBOutput, @wfxOutput, SizeOf(wfxOutput), NULL)
	DXTRACE_MSG("StartBuffers()g_pDSBOutput->lpVtbl->GetFormat", hr)
	
	'Fill the output buffer with silence at first
	'As capture data arrives, HandleNotifications() will fill
	'the output buffer with wave data.
	hr = g_pDSBOutput->lpVtbl->Lock(g_pDSBOutput, 0, g_dwOutputBufferSize, @pDSLockedBuffer, @dwDSLockedBufferSize, NULL, NULL, 0)
	DXTRACE_MSG("StartBuffers()g_pDSBOutput->lpVtbl->Lock", hr)
	
	FillMemory(pDSLockedBuffer, dwDSLockedBufferSize, IIf(wfxOutput.wBitsPerSample = 8, 128, 0))
	hr = g_pDSBOutput->lpVtbl->Unlock(g_pDSBOutput, pDSLockedBuffer, dwDSLockedBufferSize, NULL, NULL)
	DXTRACE_MSG("StartBuffers()g_pDSBOutput->lpVtbl->Unlock", hr)
	
	'Play the output buffer
	hr = g_pDSBOutput->lpVtbl->Play(g_pDSBOutput, 0, 0, DSBPLAY_LOOPING)
	DXTRACE_MSG("StartBuffers()g_pDSBOutput->lpVtbl->Play", hr)
	
	Return hr
End Function

'-----------------------------------------------------------------------------
'Name: RestoreBuffer()
'Desc: Restores a lost buffer. *pbWasRestored returns TRUE if the buffer was
'      restored.  It can also NULL if the information is not needed.
'-----------------------------------------------------------------------------
'Private Function RestoreBuffer(pDSBuffer As LPDIRECTSOUNDBUFFER, pbRestored As BOOL Ptr) As HRESULT
'	Dim As HRESULT hr
'	If (pbRestored <> NULL) Then *pbRestored = False
'	If (NULL = pDSBuffer) Then Return S_FALSE
'	
'	Dim As DWORD dwStatus
'	hr = pDSBuffer->lpVtbl->GetStatus(pDSBuffer, @dwStatus)
'	DXTRACE_MSG("RestoreBuffer", hr)
'	
'	If (dwStatus And DSBSTATUS_BUFFERLOST) Then
'		'Since the app could have just been activated, then
'		'DirectSound may not be giving us control yet, so
'		'the restoring the buffer may fail.
'		'If it does, sleep until DirectSound gives us control.
'		Do
'			hr = pDSBuffer->lpVtbl->Restore(pDSBuffer)
'			If (hr = DSERR_BUFFERLOST) Then Sleep(10)
'			hr = pDSBuffer->lpVtbl->Restore(pDSBuffer)
'		Loop While(hr)
'		
'		If (pbRestored <> NULL) Then *pbRestored = True
'		Return S_OK
'	Else
'		Return S_FALSE
'	End If
'End Function


'-----------------------------------------------------------------------------
'Name: HandleNotification()
'Desc: Handle the notification that tells us to copy data from the
'      capture buffer to the output buffer
'-----------------------------------------------------------------------------
Private Function HandleNotification() As HRESULT
	Dim As HRESULT hr
	Dim As Any Ptr pDSCaptureLockedBuffer =  NULL
	Dim As Any Ptr pDSOutputLockedBuffer =  NULL
	Dim As DWORD dwDSCaptureLockedBufferSize
	Dim As DWORD dwDSOutputLockedBufferSize
	Dim As DWORD dwStatus
	'Make sure buffers were not lost, if the were we need
	'to start the capture again
	hr = g_pDSBOutput->lpVtbl->GetStatus(g_pDSBOutput,@dwStatus)
	DXTRACE_MSG("GetStatus", hr)
	
	If (dwStatus And DSBSTATUS_BUFFERLOST) Then
		hr = StartBuffers()
		DXTRACE_MSG("StartBuffers", hr)
		Return S_OK
	End If
	
	'Lock the capture buffer down
	hr = g_pDSBCapture->lpVtbl->Lock(g_pDSBCapture, g_dwNextCaptureOffset, g_dwNotifySize, @pDSCaptureLockedBuffer, @dwDSCaptureLockedBufferSize, NULL, NULL, 0L)
	DXTRACE_MSG("Lock", hr)
	
	'Lock the output buffer down
	hr = g_pDSBOutput->lpVtbl->Lock(g_pDSBOutput,g_dwNextOutputOffset, g_dwNotifySize, @pDSOutputLockedBuffer, @dwDSOutputLockedBufferSize, NULL, NULL, 0L)
	DXTRACE_MSG("Lock", hr)
	
	'These should be equal
	If (dwDSOutputLockedBufferSize <> dwDSCaptureLockedBufferSize) Then
		DXTRACE_ERR("Error", hr)
		Return E_FAIL
	End If  'Sanity check unhandled case
	
	'Just copy the memory from the
	'capture buffer to the playback buffer
	CopyMemory(pDSOutputLockedBuffer, pDSCaptureLockedBuffer, dwDSOutputLockedBufferSize)
	
	'Unlock the play buffer
	g_pDSBOutput->lpVtbl->Unlock(g_pDSBOutput,pDSOutputLockedBuffer, dwDSOutputLockedBufferSize,NULL, 0)
	'Unlock the capture buffer
	g_pDSBCapture->lpVtbl->Unlock(g_pDSBCapture,pDSCaptureLockedBuffer, dwDSCaptureLockedBufferSize,NULL, 0)
	'Move the capture offset along
	g_dwNextCaptureOffset += dwDSCaptureLockedBufferSize
	g_dwNextCaptureOffset = g_dwNextCaptureOffset Mod g_dwCaptureBufferSize 'Circular buffer
	'Move the playback offset along
	g_dwNextOutputOffset += dwDSOutputLockedBufferSize
	g_dwNextOutputOffset = g_dwNextOutputOffset Mod g_dwOutputBufferSize 'Circular buffer
	Return S_OK
End Function


