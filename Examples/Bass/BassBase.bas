'BASS for freebasic translate by Cm.Wang

#include once "BassBase.bi"
#pragma once

Private Function Len2Str(Stream As HSTREAM, ByVal D As QWORD) As String
	Dim pt As Integer
	pt = BASS_ChannelBytes2Seconds(Stream, d)
	Dim s As String = Format(pt \ 60, "0") & ":" & Format(pt Mod 60, "00")
	Return s
End Function

Private Function OutputDeviceList(ByRef cbx As ComboBoxEdit Ptr) As Integer
	' // Get list of output devices
	Dim As Integer c = 0, def = -1
	Dim As BASS_DEVICEINFO di
	cbx->Clear
	While Bass_GetDeviceInfo(c, @di)
		cbx->AddItem *Cast(ZString Ptr, di.name)
		If (di.flags And BASS_DEVICE_DEFAULT) Then ' got the default device
			def = c
		End If
		c += 1
	Wend
	cbx->ItemIndex = def
	Return def
End Function

Private Function InputDeviceList(ByRef cbx As ComboBoxEdit Ptr) As Integer
	' Get list of input devices
	Dim As Integer c = 0, def = -1
	Dim As BASS_DEVICEINFO di
	cbx->Clear
	While BASS_RecordGetDeviceInfo(c, @di)
		cbx->AddItem *Cast(ZString Ptr, di.name)
		If (di.flags And BASS_DEVICE_DEFAULT) Then ' got the default device
			def = c
		End If
		c += 1
	Wend
	cbx->ItemIndex = def
	Return def
End Function

Private Function OutputInit(Device As Long, hHandle As HANDLE) As Boolean
	' free current device
	Bass_Free()
	' initalize New device
	If BASS_Init(Device, 44100, 0, hHandle, 0) Then Return True
	Return False
End Function

Private Function InputInit(Device As Long) As Boolean
	' free current device (And recording channel) If there Is one
	BASS_RecordFree()
	
	' initalize New device
	If BASS_RecordInit(Device) Then Return True
	Return False
End Function

Private Sub InputInfo(ByRef RecInput As DWORD, cb As ComboBoxEdit Ptr, lb As Label Ptr, tb As TrackBar Ptr, vallb As Label Ptr)
	'  Get list of inputs
	Dim As Integer c = 0
	RecInput = -1
	Dim As ZString Ptr DevName
	cb->Clear
	
	Do
		DevName = Cast(ZString Ptr, BASS_RecordGetInputName(c))
		If DevName Then
			cb->AddItem *DevName
			If (BASS_RecordGetInput(c, NULL) And BASS_INPUT_OFF) = 0 Then ' This one Is currently "on"
				RecInput = c
				cb->ItemIndex = c
			EndIf
			c += 1
		End If
	Loop While DevName
	
	Dim As WString * 256 InputType
	Dim As Single InputLevel
	Dim As Integer it = BASS_RecordGetInput(RecInput, @InputLevel) ' Get info On the Input
	If (it = -1 Or InputLevel < 0) Then ' failed To Get level
		it = BASS_RecordGetInput(-1, @InputLevel) ' try master Input instead
		If (it = -1 Or InputLevel < 0) Then '  that failed too
			InputLevel = 1 ' just display 100%
			cb->Enabled = False
		Else
			cb->Enabled = True
		End If
	Else
		cb->Enabled = True
	End If
	tb->Enabled = cb->Enabled
	tb->Position = InputLevel * 10000 ' set the level slider
	vallb->Text = Format(InputLevel, "0.0000")
	
	Select Case it And BASS_INPUT_TYPE_MASK
	Case BASS_INPUT_TYPE_DIGITAL
		InputType = "digital"
	Case BASS_INPUT_TYPE_LINE
		InputType = "line-in"
	Case BASS_INPUT_TYPE_MIC
		InputType = "microphone"
	Case BASS_INPUT_TYPE_SYNTH
		InputType = "midi synth"
	Case BASS_INPUT_TYPE_CD
		InputType = "analog cd"
	Case BASS_INPUT_TYPE_PHONE
		InputType = "telephone"
	Case BASS_INPUT_TYPE_SPEAKER
		InputType = "pc speaker"
	Case BASS_INPUT_TYPE_WAVE
		InputType = "wave/pcm"
	Case BASS_INPUT_TYPE_AUX
		InputType = "aux"
	Case BASS_INPUT_TYPE_ANALOG
		InputType = "analog"
	Case Else
		InputType = "undefined"
		Dim As BASS_DEVICEINFO info
		BASS_RecordGetDeviceInfo(BASS_RecordGetDevice(), @info)
		If (info.flags And BASS_DEVICE_LOOPBACK) Then InputType = "loopback"
	End Select
	lb->text = InputType ' display the type
End Sub

Private Sub RecSetInput(RecInput As Integer)
	Dim As Integer i = 0
	While BASS_RecordSetInput(i, BASS_INPUT_OFF, -1) ' 1st disable all inputs, then...
		i += 1
	Wend
	BASS_RecordSetInput(RecInput, BASS_INPUT_ON, -1) '  enable the selected
End Sub
