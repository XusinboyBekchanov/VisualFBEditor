'midiPlayer.bi
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

#include once "windows.bi"
#include once "vbcompat.bi"
#include once "win/mmsystem.bi"
#include once "midi.bi"

Type MidiMessage Field=1
	Number As UByte
	ParmA As UByte
	ParmB As UByte
	Reserved As UByte
End Type

Type thdChunk
	chunkID      As String
	chunkSize    As UInteger
	formatType   As Integer
	numOfTracks  As Integer
	timeDivision As Integer
End Type

Type ttrChunk
	chunkID     As String
	chunkSize   As UInteger
End Type

Type ttrInfo
	Enabled     As Boolean    'if false track will not be played string events of the same type will be concatenated, separated by const stringSeparator
	Copyright   As String     'copyright information.
	stName      As String     'Sequence/Track Name
	instrument  As String     'Instrument Name
	lastTicks   As Integer    'ticks counter of last event (~track length)
	seqNumber   As Integer    'Sequence Number, pattern number of a Type 2 MIDI file or the number of a sequence in a Type 0 or Type 1 MIDI file
	loNote      As Integer    'lowest note of track (to scale graphics)
	hiNote      As Integer    'highest note of track (to scale graphics)
	numEvents   As Integer    'count number of all events
	noteEvents  As Integer    'count number of note events
	useChannels As Integer    'bit0 = channel 0, bit15 = channel 15
	textEvents  As Integer    'meta FF01, track notes, comments, etc., usually ASCII
	lyrics      As Integer    'meta FF05, Karaoke, usually a syllable or group of works per quarter note.
	marker      As Integer    'Marker
	cuePoint    As Integer    'Cue Point
	prefix      As Integer    'MIDI Channel Prefix
	port        As Integer    'MIDI Port Select
	endOT       As Integer    'End Of Track
	tempo       As Integer    'Set Tempo
	sOffset     As Integer    'SMPTE Offset
	timeSig     As Integer    'Time Signature
	keySig      As Integer    'Key Signature
	seqSpec     As Integer    'Sequencer Specific
	sysEx       As Integer    'SysEx Event
	unknown     As Integer    'unkwown event
End Type

Enum ParameterType
	noParameter             ' 0: no Parameter
	channel_Para1           ' 1: EvPara1
	channel_Para1_Para2     ' 2: EvPara1, EvPara2
	vString                 ' 3: variable String on heap, evPara1=Heap Pointer
	'    first byte is counter
	vData                   ' 4: variable data on heap, evPara1=Heap Pointer
	'    first byte is counter
	bit7FlagData            ' 5: variable data on heap, evPara1=Heap Pointer
	'    last byte has bit7=1
	vUndefined              ' 6: event code is undefined, so paraType is also
End Enum

Type tEvent
	evDTime As Integer      'time source (relative ticks / Quarternote)
	evTicks As Integer      'sum of ticks from start (absolute)
	evCode As Integer       '0x80-0xFF / 0xFF00-0xFFFF
	evAddr As Integer       'address of event in MIDI file (when load from file)
	setTempo As Integer     'Microseconds/Quarter-Note or 0
	pType As ParameterType  'see enum ParameterType
	evPara1 As Integer      '0x00-0x7F / Heap Pointer
	evPara2 As Integer      '0x00-0x7F / Data Index
	pNext As tEvent Ptr     'chain pointer
	pPrev As tEvent Ptr     'chain pointer
End Type

Type tSequence
	pEvent As tEvent Ptr    'MIDI event
	playTime As Double      'playtime in seconds
	trackIdx As Integer     'track index number (0 = Track 1...)
	pNext As tSequence Ptr  'chain pointer
End Type

Enum MidiPlayStatus
	MidiStopped = 0
	MidiPlaying = 1
	MidiPause= 2
	MidiContinue= 3
	MidiBreak = 4
	MidiLooping = 5
	MidiError = 6
End Enum

Type midiPlayer
Private:
	Const maskEventType       = &Hf0  'hi nibble=event type, lo nibble=channel
	Const maskChannel         = &H0f  'hi nibble=event type, lo nibble=channel
	Const stringSeparator     = "|"
	
	threadPause As Boolean
	breakPlaying As Boolean
	pausePosition As Double
	
	Const heapMax = 999999
	heapPtr As Integer
	heap(Any) As Integer
	Const textinfoMax=9999
	textinfoPtr As Integer
	textinfo(Any) As String
	
	thisEvent As tEvent Ptr
	trackEvent(Any) As tEvent Ptr
	playEvent(Any) As tEvent Ptr  'cursor to next event of this track
	trackInfo(Any) As ttrInfo
	
	nextSeq As tSequence Ptr
	rootSeq As tSequence Ptr
	nextEvent As Integer
	startTime As Double
	lastTime As Double
	
	midiTempo As LongInt
	midiMsg As MidiMessage
	
	playTime As Double
	
	mSpeed As Double = 1
	midiDevice As UINT = MIDI_MAPPER    'MIDI device id
	midiHandle As HMIDIOUT              'MIDI device interface for sending MIDI output
	mPlayStatus As MidiPlayStatus
	
	updateTime As Double
	updateFrequency As Double = 0.1
	
	mErrorMessage As String
	
	midiBuffer As String
	midiUByte As UByte Ptr
	midiAddress As Integer
	
	MThd As thdChunk
	MTrk(Any) As ttrChunk
	
	Declare Function getByte() As UInteger
	Declare Function getHeaderChunk() As thdChunk
	Declare Function getHeaderStr() As String
	Declare Function getNum2() As UInteger
	Declare Function getNum4() As UInteger
	Declare Function getTrackChunk() As ttrChunk
	Declare Function getVar() As UInteger
	Declare Sub readEventData(event As tEvent Ptr)
	Declare Sub readHeaderChunk()
	Declare Sub readMidi()
	Declare Sub readTrackChunk(trkNum As Integer)
	Declare Sub readTrackEvents(trkNum As Integer, event As tEvent Ptr, startAddr As Integer, endAddr As Integer)
	
	NewtEventPtr(Any) As tEvent Ptr
	NewtEventCount As Integer = -1
	Declare Function NewtEvent() As tEvent Ptr
	NewtSequenceCount As Integer = -1
	NewtSequencePtr(Any) As tSequence Ptr
	Declare Function NewtSequence() As tSequence Ptr
	
	Declare Function baseTimer() As Double
	Declare Function eventType(eventCode As Integer) As ParameterType
	Declare Function isEndOfMusic() As Integer
	Declare Function isEndOfTrack(Event As tEvent Ptr) As Boolean
	Declare Function isPlayable(eventCode As Integer) As Boolean
	Declare Property PlayStatus (v As MidiPlayStatus)
	Declare Static Function threadPlay(ByVal pParam As Any Ptr) As Any Ptr
	Declare Sub buildSequence()
	Declare Sub playLoop()
	Declare Sub playMidiEvent(midiSeq As tSequence Ptr)
	Declare Sub playTo(dPosition As Double)
	Declare Sub Release()
	Declare Sub reportError(sErrMsg As String)
	Declare Sub retimeTrack()
	Declare Sub saveEnergy()
	
Public:
	midiThread As Any Ptr
	mOwner As Any Ptr
	loopOne As Boolean
	UsedChannel(Any) As Boolean
	EnabledChannel(Any) As Boolean
	MIChannel(Any) As UByte
	
	Declare Sub Play(filename As String)
	Declare Sub Resume(ByVal dPosition As Double = -1)
	Declare Function Pause(p As Boolean) As Double
	Declare Sub Stop()
	Declare Property Speed As Double
	Declare Property Speed(v As Double)
	Declare Property TotalTime As Double
	Declare Property Position(v As Double)
	Declare Property Position As Double
	Declare Property Volume As ULong
	Declare Property Volume(v As ULong)
	Declare Property Device() As UINT
	Declare Property Device(selectDevice As UINT)
	Declare Property PlayStatus As MidiPlayStatus
	Declare Property ErrMsg() As String
	
	OnChange As Sub(Owner As Any Ptr, Channel As UByte, Instrument As UByte)
	OnNoteOff As Sub(Owner As Any Ptr, Channel As UByte, Note As UByte)
	OnNoteOn As Sub(Owner As Any Ptr, Channel As UByte, Note As UByte, Velocity As UByte)
	OnPlayStatus As Sub(Owner As Any Ptr, sStatus As MidiPlayStatus)
	OnPosition As Sub(Owner As Any Ptr, sPosition As Double)
	
	Declare Constructor
	Declare Destructor
End Type

#ifndef __USE_MAKE__
	#include once "midiPlayer.bas"
#endif

