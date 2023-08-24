'BASS for freebasic translate by Cm.Wang

#include once "BassRaido.bi"
#pragma once


Private Constructor BassRaido
	InitializeCriticalSection(@RaidoLock)
End Constructor
	
Private Destructor BassRaido
	Stop()
End Destructor

' update stream title from metacdata
Private Sub BassRaido.DoMeta()
	Dim As ZString Ptr meta = Cast(ZString Ptr, BASS_ChannelGetTags(RaidoStream, BASS_TAG_META)) '  got Shoutcast metacdata
	If (meta = 0) Then
		meta = Cast(ZString Ptr, BASS_ChannelGetTags(RaidoStream, BASS_TAG_OGG)) '  got Icecast/OGG tags
		If (meta = 0) Then
			meta = Cast(ZString Ptr, BASS_ChannelGetTags(RaidoStream, BASS_TAG_HLS_EXTINF)) '  got HLS segment info
		End If
	End If
	If (meta) Then
		If OnMeta Then OnMeta(mOwner, meta)
'		If InStr(TextBox5.Text, *meta) = 0 Then TextBox5.Text = *meta
	End If
End Sub

Private Sub BassRaido.MetaSync(ByVal chandle As HSYNC, ByVal channel As DWORD, ByVal cData As DWORD, ByVal user As Any Ptr)
	(*Cast(BassRaido Ptr, user)).DoMeta()
End Sub

Private Sub BassRaido.StallSync(ByVal chandle As HSYNC, ByVal channel As DWORD, ByVal cData As DWORD, ByVal user As Any Ptr)
	If (cData = 0) Then '  stalled
		If (*Cast(BassRaido Ptr, user)).OnStall Then (*Cast(BassRaido Ptr, user)).OnStall((*Cast(BassRaido Ptr, user)).mOwner)
	End If
End Sub

Private Sub BassRaido.FreeSync(ByVal chandle As HSYNC, ByVal channel As DWORD, ByVal cData As DWORD, ByVal user As Any Ptr)
	If (*Cast(BassRaido Ptr, user)).OnFree Then (*Cast(BassRaido Ptr, user)).OnFree((*Cast(BassRaido Ptr, user)).mOwner)
End Sub

Private Sub BassRaido.StatusProc(ByVal buffer As Const Any Ptr, ByVal length As DWORD, ByVal user As Any Ptr)
	'(buffer As Any Ptr, length As DWORD, user As Any Ptr)
	If buffer <> 0 And length = 0 Then '  got HTTP/ICY tags, And This Is still the current request Then
		If (*Cast(BassRaido Ptr, user)).OnStatus Then
			Dim As ZString Ptr proc = Cast(ZString Ptr, buffer)
			(*Cast(BassRaido Ptr, user)).OnStatus((*Cast(BassRaido Ptr, user)).mOwner, proc)
		End If
'		If InStr(*Cast(frmBassType Ptr, user).Label6.Text, *proc) = 0 Then *Cast(frmBassType Ptr, user).Label6.Text = *proc '  display status
	End If
End Sub

Private Function BassRaido.OpenURL(Owner As Any Ptr, ByVal url As String) As HSTREAM
	mOwner = Owner
	' Close old stream
	If (RaidoStream) Then BASS_StreamFree(RaidoStream)
	
	' open URL
	Dim As HSTREAM c = BASS_StreamCreateURL(url, 0, BASS_STREAM_BLOCK Or BASS_STREAM_STATUS Or BASS_STREAM_AUTOFREE Or BASS_SAMPLE_FLOAT, @StatusProc(), @This)
	EnterCriticalSection(@RaidoLock)
	RaidoStream = c ' This Is Now the current stream
	LeaveCriticalSection(@RaidoLock)
	If RaidoStream Then ' Ok To Open
		' set syncs For stream title updates
		BASS_ChannelSetSync(RaidoStream, BASS_SYNC_META, 0, @MetaSync(), @This) '  Shoutcast
		BASS_ChannelSetSync(RaidoStream, BASS_SYNC_OGG_CHANGE, 0, @MetaSync(), @This) '  Icecast/OGG
		BASS_ChannelSetSync(RaidoStream, BASS_SYNC_HLS_SEGMENT, 0, @MetaSync(), @This) '  HLS
		' set sync For stalling/buffering
		BASS_ChannelSetSync(RaidoStream, BASS_SYNC_STALL, 0, @StallSync(), @This)
		' set sync For End of stream (when freed due To AUTOFREE)
		BASS_ChannelSetSync(RaidoStream, BASS_SYNC_FREE, 0, @FreeSync(), @This)
		' play it!
		BASS_ChannelPlay(RaidoStream, False)
		' start buffer monitoring (And display stream info when done)
		RaidoStatus = BassStatus.BassPlay
	Else
		RaidoStatus = BassStatus.BassError
	End If
	Return RaidoStream
End Function

Private Property BassRaido.Stream As HSTREAM
	Property = RaidoStream
End Property

Private Sub BassRaido.Pause()
	If (RaidoStream) Then
		Bass_ChannelPause(RaidoStream)
	End If
End Sub

Private Sub BassRaido.Resume()
	If (RaidoStream) Then
		Bass_ChannelPlay(RaidoStream, 0)
	End If
End Sub

Private Sub BassRaido.Stop()
	If RaidoStream Then
		BASS_ChannelStop(RaidoStream)
		RaidoStream = 0
	End If
End Sub
