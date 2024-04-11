'midiPlayer.bas
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

'Some of codes are refer to:
'https://github.com/stoves3/fb
' midiPlayer - MIDI Library for FreeBASIC by oog / Proog.de
'http://www.freebasic.net/forum/viewtopic.php?t=12995
' QB like PLAY plus more...
' angros47 Freebasic sfx library Files
'https://freebasic.net/forum/viewtopic.php?t=26256
' Audio library for FreeBasic - Features
'https://sourceforge.net/projects/freebasic-sfx-library/files/

#include once "midiPlayer.bi"

Constructor midiPlayer
	
End Constructor

Destructor midiPlayer
	If midiThread Then Stop()
	If midiHandle Then midiOutClose(midiHandle)
	Release()
End Destructor

'Speed adjustable timer
Function midiPlayer.baseTimer() As Double
	Return Timer * mSpeed
End Function

'Set/Get speed
Property midiPlayer.Speed(v As Double)
	If mSpeed <> v Then
		mSpeed = v
		If midiThread Then playTo(nextSeq->playTime)
	End If
End Property
Property midiPlayer.Speed As Double
	Return mSpeed
End Property

'Get TotalTime
Property midiPlayer.TotalTime As Double
	Return playTime
End Property

'Set/Get position
Property midiPlayer.Position(v As Double)
	If midiThread Then playTo(v)
End Property
Property midiPlayer.Position As Double
	If midiThread Then Return nextSeq->playTime
End Property

'playstatus
Property midiPlayer.PlayStatus As MidiPlayStatus
	Return mPlayStatus
End Property
Property midiPlayer.PlayStatus (v As MidiPlayStatus)
	mPlayStatus = v
	If OnPlayStatus Then OnPlayStatus(mOwner, mPlayStatus)
End Property

'Set/Get volume
Property midiPlayer.Volume As ULong
	If midiHandle= NULL Then Exit Property
	Dim v As ULong
	midiOutGetVolume(midiHandle, @v)
	Return v
End Property
Property midiPlayer.Volume(v As ULong)
	If midiHandle= NULL Then Exit Property
	midiOutSetVolume(midiHandle, v)
End Property

'stop ThreadPlay
Sub midiPlayer.Stop()
	If midiThread Then
		breakPlaying = True
		Do
			App.DoEvents
		Loop While midiThread
	End If
End Sub

'last error message
Property midiPlayer.ErrMsg() As String
	Return mErrorMessage
End Property

'play a midifile
Sub midiPlayer.Play(filename As String)
	If midiThread Then Stop()
	
	ReDim heap(heapMax)
	ReDim textinfo(textinfoMax)
	ReDim MIChannel(maskChannel)
	ReDim UsedChannel(maskChannel)
	ReDim EnabledChannel(maskChannel)
	Device = midiDevice
	
	'load file into midiBuffer
	Dim filenum As Integer = FreeFile()
	If Open(filename For Binary Access Read As #filenum ) = 0 Then
		midiBuffer = Input(LOF(filenum), filenum)
		midiUByte = StrPtr(midiBuffer)
		Close #filenum
		readMidi()
		buildSequence()
		midiThread = ThreadCreate(Cast(Any Ptr, @threadPlay), @This)
	Else
		reportError("ERROR - Can't open [" & filename & "] file.")
	End If
End Sub

Function midiPlayer.threadPlay(ByVal pParam As Any Ptr) As Any Ptr
	Dim sPause As Boolean
	Dim a As midiPlayer Ptr = Cast(midiPlayer Ptr , pParam)
	a->PlayStatus = MidiPlayStatus.MidiPlaying
	Do
		a->playTo(0)
		Do
			If a->threadPause Then
				If sPause = False Then
					a->PlayStatus = MidiPlayStatus.MidiPause
					midiOutReset(a->midiHandle)
					sPause = True
				End If
				Sleep 50
			Else
				a->saveEnergy()
				If sPause Then
					a->PlayStatus = MidiPlayStatus.MidiContinue
					sPause = False
				End If
				a->playLoop()
			End If
			If a->breakPlaying Then Exit Do
		Loop Until a->isEndOfMusic
		If a->breakPlaying Then Exit Do
		If a->loopOne = False Then Exit Do
		a->PlayStatus = MidiPlayStatus.MidiLooping
	Loop While True
	midiOutReset(a->midiHandle)
	
	If a->breakPlaying Then
		a->Release()
		a->PlayStatus = MidiPlayStatus.MidiBreak
	Else
		a->Release()
		a->PlayStatus = MidiPlayStatus.MidiStopped
	End If
	
	Return 0
End Function

Sub midiPlayer.Resume(ByVal dPosition As Double= -1)
	If pausePosition < 0 Then Exit Sub
	If threadPause = False Then Exit Sub
	If midiThread = False Then Exit Sub
	playTo(IIf(Position < 0, pausePosition, Position))
	threadPause = False
	pausePosition = -1
End Sub

Function midiPlayer.Pause(p As Boolean) As Double
	If threadPause Then Return -1
	If midiThread = False Then Return -1
	threadPause= True
	pausePosition = nextSeq->playTime
	Return pausePosition
End Function

'Device MIDI interface
Property midiPlayer.Device(selectdevice As UINT)
	Dim b As Boolean = threadPause
	If midiHandle Then
		If midiDevice = selectdevice Then Exit Property
		threadPause= True
		midiOutClose(midiHandle)
	End If
	midiDevice = selectdevice
	midiOutOpen(@midiHandle, midiDevice, 0, 0, NULL)
	threadPause = b
End Property
Property midiPlayer.Device() As UINT
	Return midiDevice
End Property

'get next 4 character string chunk ID
Function midiPlayer.getHeaderStr() As String
	Dim As String r
	For i As Integer= 1 To 4
		r += Chr(getByte)
	Next
	Return r
End Function

'get next byte
Function midiPlayer.getByte() As UInteger
	getByte = * (midiUByte + midiAddress)
	midiAddress += 1
End Function

'get next 4 byte number
Function midiPlayer.getNum4() As UInteger
	Return (getByte Shl 24) + (getByte Shl 16) + (getByte Shl 8) + (getByte)
End Function

'get next 2 byte number
Function midiPlayer.getNum2() As UInteger
	Return (getByte Shl 8) + (getByte)
End Function

'sequencer
'get next variable size number (vtime)
Function midiPlayer.getVar() As UInteger
	Dim As UInteger n, d
	d=getByte
	n+=(d And 127)
	While (d And 128) = 128
		n=n Shl 7
		d=getByte
		n+=(d And 127)
	Wend
	Return n
End Function

'return event type
Function midiPlayer.eventType(eventCode As Integer) As ParameterType
	Select Case eventCode
	Case &H80 To &H8F:  'Note Off
		Return channel_Para1_Para2
	Case &H90 To &H9F:  'Note On
		Return channel_Para1_Para2
	Case &HA0 To &HAF:  'Polyphonic Key Pressure (Aftertouch)
		Return channel_Para1_Para2
	Case &HB0 To &HBF:  'Controller / Channel Mode Messages
		Return channel_Para1_Para2
	Case &HC0 To &HCF:  'Program Change
		Return channel_Para1
	Case &HD0 To &HDF:  'Channel Pressure (Aftertouch)
		Return channel_Para1
	Case &HE0 To &HEF:  'Pitch Bend
		Return channel_Para1_Para2
		'System Common Messages
	Case &HF0:      'System Exclusive
		Return vData
	Case &HF1:      'MIDI Time Code Quarter Frame (0nnndddd )
		Return channel_Para1
	Case &HF2:      'Song Position Pointer
		Return channel_Para1_Para2
	Case &HF3:      'Song Select (0.127)
		Return channel_Para1
	Case &HF6:      'Tune Request
		Return noParameter
	Case &HF7:      'End of System Exclusive (EOX)
		Return noParameter
		'System Real Time Messages - Don't expect in a MIDI file
	Case &HF8:      'Timing Clock
		Return noParameter
	Case &HFA:      'Start
		Return noParameter
	Case &HFB:      'Continue
		Return noParameter
	Case &HFC:      'Stop
		Return noParameter
	Case &HFE:      'Active Sensing
		Return noParameter
	Case &HFF:      'System Reset
		Return noParameter
		'Meta Events
	Case &HFF00:    'Sequence Number
		'Sequence Number - pattern number of a Type 2 MIDI file
		'or the number of a sequence in a Type 0 or Type 1 MIDI file
		Return channel_Para1_Para2
	Case &HFF01:    'Text Event
		Return vString
	Case &HFF02:    'Copyright Notice
		Return vString
	Case &HFF03:    'Sequence/Track Name
		Return vString
	Case &HFF04:    'Instrument Name
		Return vString
	Case &HFF05:    'Lyrics
		Return vString
	Case &HFF06:    'Marker
		Return vString
	Case &HFF07:    'Cue Point
		Return vString
	Case &HFF20:    'MIDI Channel Prefix - associate channel with next meta events
		Return vData
	Case &HFF21:    'MIDI Port
		Return vData
	Case &HFF2F:    'End Of Track
		Return vData
	Case &HFF51:    'Set Tempo
		Return vData
	Case &HFF54:    '
		Return vData
	Case &HFF58:    '
		Return vData
	Case &HFF59:    '
		Return vData
	Case &HFF7F:    '
		Return vData
	Case Else:    '
		Return vUndefined
	End Select
End Function

'read event data
Sub midiPlayer.readEventData(event As tEvent Ptr)
	Dim As UByte b
	Dim As Integer d
	'1 - define parameter type (pType)
	event->pType = eventType(event->evCode)
	'2 - read parameters
	Select Case event->pType
	Case noParameter:
		'no Parameter
		'- nothing to do
	Case channel_Para1:
		'EvPara1
		event->evPara1=getByte
	Case channel_Para1_Para2:
		'EvPara1, EvPara2
		event->evPara1=getByte
		event->evPara2=getByte
	Case vString:
		'variable String on heap, evPara1=Heap Pointer
		'first byte is counter
		d=getByte
		event->evPara2=textinfoPtr
		For i As Integer=1 To d
			textinfo(textinfoPtr)+=Chr(getByte)
		Next
		textinfoPtr+=1
	Case vData:
		'variable data on heap, evPara1=Heap Pointer
		'first byte is counter
		d=getByte
		event->evPara2=heapPtr
		heap(heapPtr)=d       'size counter byte
		heapPtr+=1
		For i As Integer=1 To d
			heap(heapPtr)=getByte
			heapPtr+=1
		Next
		'if event is "Set Tempo" then store tempo change
		If event->evCode = &HFF51 Then
			event->setTempo=(heap(heapPtr-3)Shl 16)_
			+(heap(heapPtr-2)Shl 8)+heap(heapPtr-1)
		End If
	Case bit7FlagData:
		'variable data on heap, evPara1=Heap Pointer
		'last byte has bit7=1
		event->evPara2=heapPtr
		Do
			b=getByte
			heap(heapPtr)=b
			heapPtr+=1
		Loop Until ((b And 128) = 128)
	End Select
End Sub

'MIDI event is playable (note on, off...)
Function midiPlayer.isPlayable(eventCode As Integer) As Boolean
	'1 - define parameter type (pType)
	Select Case eventCode
	Case &H80 To &HEF
		'Dim c As UByte = eventCode And maskChannel
		'Return EnabledChannel(c)
		Return True
	End Select
	Return False
End Function

Sub midiPlayer.reportError(sErrMsg As String)
	mErrorMessage = sErrMsg 
	PlayStatus = MidiPlayStatus.MidiError
End Sub

'read all events in a chunk
Sub midiPlayer.readTrackEvents(trkNum As Integer, event As tEvent Ptr, startAddr As Integer, endAddr As Integer)
	Dim As tEvent Ptr tradeEvent
	Dim As tEvent Ptr newEvent
	Dim As UInteger eventDTime
	Dim As UInteger eventCode, runningStatus
	Dim As Integer eventAddress
	
	midiAddress = startAddr
	tradeEvent = event
	While midiAddress < endAddr
		eventDTime=getVar
		eventAddress=midiAddress
		eventCode=getByte
		If eventCode=&HFF Then eventCode=&HFF00 Or getByte
		'Running Status is a data-thinning technique.
		'It allows for the omision of status bytes if the current
		'message to be transmitted has the same status byte
		'(ie the same command and MIDI channel) as the previous
		'message. It thus only applies to Channel (Voice and Mode)
		'messages (0x8n - 0xEn).
		'allow "runnung status" repeat codes
		If (eventCode And &HFF80)=0 Then
			midiAddress-=1
			If runningStatus<>0 Then
				eventCode=runningStatus       'save the running status
			Else
				reportError("ERROR - Running Status is zero at @" + Hex(midiAddress))
			End If
		End If
		newEvent = NewtEvent()
		newEvent->pNext=0
		newEvent->pPrev = tradeEvent
		tradeEvent->pNext = newEvent
		tradeEvent=newEvent
		newEvent->evDTime=eventDTime
		newEvent->evCode=eventCode
		newEvent->evAddr=eventAddress
		readEventData(newEvent)
		trackInfo(trkNum).Enabled = True      'track is enabled by default
		'track info / analyse
		If isPlayable(eventCode) Then
			runningStatus=eventCode       'save the running status
			trackInfo(trkNum).noteEvents += 1    'count number of note events
			Var ch=1 Shl(eventCode And maskChannel) 'bit0 = channel 0, bit15 = channel 15
			UsedChannel(eventCode And maskChannel) = True
			EnabledChannel(eventCode And maskChannel) = True
			trackInfo(trkNum).useChannels = trackInfo(trkNum).useChannels Or ch
			If (eventCode And maskEventType) = NoteOn Then
				'store first note as lowest and highest note
				If trackInfo(trkNum).hiNote< 0 Then
					trackInfo(trkNum).loNote= newEvent->evPara1
					trackInfo(trkNum).hiNote= newEvent->evPara1
				Else
					If newEvent->evPara1 < trackInfo(trkNum).loNote Then
						trackInfo(trkNum).loNote= newEvent->evPara1
					ElseIf newEvent->evPara1 > trackInfo(trkNum).hiNote Then
						trackInfo(trkNum).hiNote= newEvent->evPara1
					End If
				End If
			End If
		Else
			Select Case eventCode
			Case &H00F0:    'SysEx Event
				trackInfo(trkNum).sysEx += 1       'count events
				runningStatus=0               'clear the running status
			Case &H00F0 To &H00F7: 'System Common and System Exclusive messages
				runningStatus=0               'clear the running status
			Case &HFF00:    'Sequence Number
				trackInfo(trkNum).seqNumber = newEvent->evPara1 Shl 8 + newEvent->evPara2
			Case &HFF01:    'Text Event: track notes, comments...
				trackInfo(trkNum).textEvents += 1  'count events
			Case &HFF02:    'Copyright Notice
				If trackInfo(trkNum).Copyright <> "" Then trackInfo(trkNum).Copyright += stringSeparator
				trackInfo(trkNum).Copyright += textinfo(newEvent->evPara2)
			Case &HFF03:    'Sequence/Track Name
				If trackInfo(trkNum).stName<> "" Then trackInfo(trkNum).stName += stringSeparator
				trackInfo(trkNum).stName+= textinfo(newEvent->evPara2)
			Case &HFF04:    'Instrument Name
				If trackInfo(trkNum).instrument <> "" Then trackInfo(trkNum).instrument += stringSeparator
				trackInfo(trkNum).instrument += textinfo(newEvent->evPara2)
			Case &HFF05:    'Karaoke, usually a syllable or group of works per quarter note.
				trackInfo(trkNum).lyrics += 1    'count events
			Case &HFF06:    'Marker
				trackInfo(trkNum).marker += 1    'count events
			Case &HFF07:    'Cue Point
				trackInfo(trkNum).cuePoint += 1  'count events
			Case &HFF20:    'MIDI Channel Prefix
				trackInfo(trkNum).prefix += 1    'count events
			Case &HFF21:    'MIDI Port
				trackInfo(trkNum).port += 1      'count events
			Case &HFF2F:    'End Of Track
				trackInfo(trkNum).endOT += 1     'count events
			Case &HFF51:    'Set Tempo
				trackInfo(trkNum).tempo += 1     'count events
			Case &HFF54:    'SMPTE Offset
				trackInfo(trkNum).sOffset += 1   'count events
			Case &HFF58:    'Time Signature
				trackInfo(trkNum).timeSig += 1   'count events
			Case &HFF59:    'Key Signature
				trackInfo(trkNum).keySig += 1    'count events
			Case &HFF7F:    'Sequencer Specific
				trackInfo(trkNum).seqSpec += 1   'count events
			Case Else:
				trackInfo(trkNum).unknown += 1   'count events
			End Select
		End If
		trackInfo(trkNum).numEvents += 1       'count number of all events
	Wend
End Sub

'get track chunk
Sub midiPlayer.readTrackChunk(trkNum As Integer)
	Dim startAddr As Integer = midiAddress
	Dim As ttrChunk trChunk
	trChunk.chunkID      = getHeaderStr
	trChunk.chunkSize    = getNum4
	midiAddress = startAddr + trChunk.chunkSize+ 8
	If (trChunk.chunkID <> "MTrk") Then
		reportError("ERROR - Invalid Track Chunk " + Str(trkNum) + ":" + trChunk.chunkID)
	End If
	
	Dim As tEvent Ptr newEvent = NewtEvent()
	trackEvent(trkNum) = newEvent
	newEvent->pPrev = 0
	newEvent->pNext = 0
	newEvent->evCode= -1   'track start
	readTrackEvents(trkNum, newEvent, startAddr + 8, startAddr + trChunk.chunkSize + 7)
End Sub

'get header chunk
Sub midiPlayer.readHeaderChunk()
	MThd.chunkID      = getHeaderStr
	MThd.chunkSize    = getNum4
	MThd.formatType   = getNum2
	MThd.numOfTracks  = getNum2
	MThd.timeDivision = getNum2
	
	If (MThd.timeDivision And &H8000) <> 0 Then
		reportError("ERROR - Format not supported")
	End If
	If (MThd.chunkID <> "MThd") OrElse (MThd.formatType> 2) Then
		reportError("ERROR - Invalid Header Chunk: " & MThd.chunkID & " or Type: " & MThd.formatType)
	End If
End Sub

'read file from midiBuffer into sequencer
Sub midiPlayer.readMidi()
	readHeaderChunk()
	
	ReDim trackEvent(1 To MThd.numOfTracks)
	ReDim playEvent(0 To MThd.numOfTracks)
	ReDim trackInfo(1 To MThd.numOfTracks)
	
	For i As Integer = 1 To MThd.numOfTracks
		readTrackChunk(i)
	Next
	
	'prepare midi sequence for playing
	If MThd.numOfTracks Then retimeTrack()
End Sub

'retime midi tracks
'calculate absolute tick counter for every event
Sub midiPlayer.retimeTrack()
	Dim As Integer ticksCounter
	Dim As tEvent Ptr thisEvent
	Dim As String s
	For i As Integer = 1 To MThd.numOfTracks
		ticksCounter=0
		thisEvent = trackEvent(i)
		While thisEvent<>0
			ticksCounter+=thisEvent->evDTime
			thisEvent->evTicks=ticksCounter
			thisEvent = thisEvent->pNext
		Wend
		'store track lenght (ticksCounter of last event)
		trackInfo(i).lastTicks=ticksCounter
	Next
End Sub

'detect end of track by event code or zero pointer
Function midiPlayer.isEndOfTrack(event As tEvent Ptr) As Boolean
	If (event = 0) OrElse (event->evCode = &hFF2F) Then
		Return True
	Else
		Return False
	End If
End Function

'build sequence
Sub midiPlayer.buildSequence()
	Dim As Integer nextEvent
	Dim As Integer lastTicks = 0
	
	rootSeq = NewtSequence()
	nextSeq = rootSeq
	'set play cursors to track start (get first event with pNext)
	For i As Integer = 1 To MThd.numOfTracks
		playEvent(i) = trackEvent(i)->pNext  '->pNext, because first element is dummy
	Next
	playTime=0
	lastTime=0
	midiTempo = 50000 '60000000 / 120 set to default value
	Do
		'search all tracks for next to play event (time)
		For i As Integer = 1 To MThd.numOfTracks
			'1) set nextEvent to a valid track
			If isEndOfTrack(playEvent(nextEvent)) AndAlso Not(isEndOfTrack(playEvent(i))) Then
				nextEvent = i
			End If
			'2) set what track has the next event in time but ignore "end of track" event
			If (playEvent(i) <> 0) AndAlso (playEvent(i)->evCode <>&HFF2F) AndAlso (playEvent(i)->evTicks <= playEvent(nextEvent)->evTicks) Then
				nextEvent = i
			End If
		Next
		'store next event in sequence
		nextSeq->trackIdx = nextEvent
		nextSeq->pEvent   = playEvent(nextEvent)
		nextSeq->pNext    = NewtSequence()
		'calculate playtime of actual MIDI event
		playTime = lastTime + (nextSeq->pEvent->evTicks - lastTicks)*midiTempo / MThd.timeDivision / 1e6
		nextSeq->playTime = playTime
		If nextSeq->pEvent->setTempo > 0 Then
			'MICROSECONDS_PER_MINUTE = 60000000
			'BPM = MICROSECONDS_PER_MINUTE / MPQN
			'MPQN = MICROSECONDS_PER_MINUTE / BPM
			midiTempo=nextSeq->pEvent->setTempo
			lastTicks=nextSeq->pEvent->evTicks
			lastTime=playTime
		End If
		
		nextSeq=nextSeq->pNext
		If playEvent(nextEvent)<>0 Then playEvent(nextEvent)=playEvent(nextEvent)->pNext
	Loop Until playEvent(nextEvent) = 0
End Sub

'save energy, sleep while nothing to play
Sub midiPlayer.saveEnergy()
	'wait for next event to be played
	'but no longer than 20 ms to prevent blocking user interface
	
	If nextSeq<>0 AndAlso (nextSeq->pEvent<>0) Then
		If nextSeq->playTime - (baseTimer - lastTime) > 0.025 Then
			Dim i As Integer = 20 / mSpeed
			Sleep IIf(i < 1, 1, i)
		Else
			While nextSeq->playTime > (baseTimer - lastTime)
				Sleep 1
			Wend
		End If
	End If
End Sub

'play MIDI file from "midiSeq"
Sub midiPlayer.playMidiEvent(midiSeq As tSequence Ptr)
	'play next MIDI event
	If midiSeq->pEvent->setTempo > 0 Then
		midiTempo = midiSeq->pEvent->setTempo
	End If
	'play note, if channel is enabled
	If trackInfo(midiSeq->trackIdx).Enabled AndAlso isPlayable(midiSeq->pEvent->evCode) Then
		midiMsg.Number = midiSeq->pEvent->evCode
		midiMsg.ParmA  = midiSeq->pEvent->evPara1
		midiMsg.ParmB  = midiSeq->pEvent->evPara2
		
		Dim c As UByte = midiMsg.Number And maskChannel 'Channel
		Dim e As UByte = midiMsg.Number And &H00F0 'Event
		Select Case e
		Case NoteOff
			If OnNoteOff Then OnNoteOff(mOwner, c, midiMsg.ParmA)
		Case NoteOn
			If midiMsg.ParmB Then
				If EnabledChannel(c) = False Then Exit Sub
				If OnNoteOn Then OnNoteOn(mOwner, c, midiMsg.ParmA, midiMsg.ParmB)
			Else
				If OnNoteOff Then OnNoteOff(mOwner, c, midiMsg.ParmA)
			End If
		Case PolyphonicAftertouch
			If midiMsg.ParmB = 0 Then
				If OnNoteOff Then OnNoteOff(mOwner, c, midiMsg.ParmA)
			End If
		Case ProgramChange
			If OnChange Then OnChange(mOwner, c, midiMsg.ParmA)
			MIChannel(c) = midiMsg.ParmA
		End Select
		midiOutShortMsg(midiHandle, *CPtr(Integer Ptr, @midiMsg))
	End If
End Sub

'check if no more to play
Function midiPlayer.isEndOfMusic() As Integer
	Return (nextSeq=0) OrElse (nextSeq->pEvent=0)
End Function

'play next MIDI event from "seq" in a loop
Sub midiPlayer.playTo(dPosition As Double)
	nextSeq = rootSeq
	startTime = baseTimer - dPosition
	lastTime = startTime
	updateTime = 0
	
	If dPosition>0 Then
		'search for event to be played
		While nextSeq->playTime <= dPosition
			If (nextSeq=0) OrElse (nextSeq->pEvent=0) Then Exit While
			nextSeq = nextSeq->pNext
		Wend
		midiOutReset(midiHandle)
	End If
End Sub

'play next MIDI event from sequence in a loop
Sub midiPlayer.playLoop()
	'wait until next event has to be played current time
	Dim t As Double = baseTimer - lastTime
	If (t - updateTime) > updateFrequency Then
		updateTime = t
		If OnPosition Then OnPosition(mOwner, t)
	End If
	If nextSeq->playTime > t Then Exit Sub
	Do
		'break by breakPlaying signal
		If breakPlaying Then Exit Sub
		'break by end of midi sequence
		If (nextSeq = 0) OrElse (nextSeq->pEvent = 0) Then Exit Do
		'play next MIDI event
		playMidiEvent(nextSeq)
		nextSeq = nextSeq->pNext
	Loop While nextSeq->playTime <= t
End Sub

Function midiPlayer.NewtEvent() As tEvent Ptr
	NewtEventCount += 1
	ReDim Preserve NewtEventPtr(NewtEventCount)
	NewtEventPtr(NewtEventCount) = New tEvent
	Return NewtEventPtr(NewtEventCount)
End Function
Function midiPlayer.NewtSequence() As tSequence Ptr
	NewtSequenceCount += 1
	ReDim Preserve NewtSequencePtr(NewtSequenceCount)
	NewtSequencePtr(NewtSequenceCount) = New tSequence
	Return NewtSequencePtr(NewtSequenceCount)
End Function

Sub midiPlayer.Release()
	Dim i As Integer
	For i = 0 To NewtEventCount
		Delete NewtEventPtr(i)
	Next
	For i = 0 To NewtSequenceCount
		Delete NewtSequencePtr(i)
	Next
	Erase NewtEventPtr
	Erase NewtSequencePtr
	NewtEventCount = -1
	NewtSequenceCount = -1
	
	Erase heap
	Erase textinfo
	Erase trackEvent
	Erase playEvent
	Erase trackInfo
	Erase MTrk
	Erase UsedChannel
	Erase EnabledChannel
	Erase MIChannel
	
	midiBuffer = ""
	heapPtr = 0
	textinfoPtr = 0
	midiAddress = 0
	threadPause = False
	pausePosition = -1
	breakPlaying = False
	If midiThread Then midiThread = NULL
End Sub

