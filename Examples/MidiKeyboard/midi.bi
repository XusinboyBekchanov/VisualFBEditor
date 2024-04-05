'midi.bi
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

'Some of codes are refer to Test of midiOutShortMsg()
'https://www.freebasic.net/forum/viewtopic.php?t=29670

#include once "win\mmsystem.bi"
#include once "vbcompat.bi"

#define vbRGB(r, g, b) CULng((CUByte(b) Shl 16) Or (CUByte(g) Shl 8) Or CUByte(r))

Type RectPi Extends Rect
	Width As Integer
	Height As Integer
End Type

#macro InRange(v, l, h)
	If v < l Then
		v = l
	ElseIf v > h Then
		v = h
	End If
#endmacro

'乐器
Enum InstrumentsEnum
	' Piano
	GrandPiano
	BrightPiano
	EGrandPiano
	HonkytonkPiano
	EPiano1
	EPiano2
	Harpsichord
	Clavi
	
	' Chromatic Perc
	Celesta
	Glockenspiel
	MusicBox
	Vibraphone
	Marimba
	Xylophone
	TubularBells
	Dulcimer
	
	' Organ
	DrawbarOrgan
	PercusionOrgan
	RockOrgan
	ChurchOrgan
	ReedOrgan
	Accordion
	Harmonica
	TangoAccordion
	
	' Guitar
	NylonstrGuitar
	SteelstrGuitar
	JazzGuitar
	CleanGuitar
	MutedGuitar
	OverdriveGuitar
	DistortionGuitar
	GuitarHarmonics
	
	' Bass
	AcousticBass
	FingeredBass
	PickedBass
	FretlessBass
	SlapBass1
	SlapBass2
	SynthBass1
	SynthBass2
	
	' Strings/Orch
	Violin
	Viola
	Cello
	Contrabass
	TremoloStrings
	PizzictoStrings
	Harp
	Timpani
	
	' Ensemble
	Strings1
	Strings2
	SynthStrings1
	SynthStrings2
	ChoirAahs
	VoiceOohs
	SynthVoice
	OrchestraHit
	
	' Brass
	Trumpet
	Trombone
	Tuba
	MutedTrumpet
	FrenchHorn
	BrassSection
	SynthBrass1
	SynthBrass2
	
	' Reed
	SopranoSax
	AltoSax
	TenorSax
	BaritoneSax
	Oboe
	EnglishHorn
	Bassoon
	Clarinet
	
	' Pipe
	Piccolo
	Flute
	Recorder
	PanFlute
	BlownBottle
	Shakuhachi
	Whistle
	Ocarina
	
	' Synth Lead
	SquareLead
	SawLead
	CalliopeLead
	ChiffLead
	CharangLead
	VoiceLead
	FifthLead
	BassLead
	
	' Synth Pad
	NewAgePad
	WarmPad
	PolysynthPad
	ChoirPad
	BowedPad
	MetallicPad
	HaloPad
	SweepPad
	
	' Synth FX
	Rain
	Soundtrack
	Crystal
	Atmosphere
	Brightness
	Goblins
	Echoes
	SciFi
	
	' Ethnic
	Sitar
	Banjo
	Shamisen
	Koto
	Kalimba
	Bagpipe
	Fiddle
	Shanai
	
	' Percussive
	TinkleBell
	Agogo
	SteelDrums
	Woodblock
	TaikoDrum
	MelodicDrum
	SynthDrum
	RevCymbal
	
	' Special FX
	GtrFretNoise
	BreathNoise
	Seashore
	BirdTweet
	Telephone
	Helicopter
	Applause
	Gunshot
End Enum

'通道
Enum ChannelsEnum
	channel1 = 0
	channel2
	channel3
	channel4
	channel5
	channel6
	channel7
	channel8
	channel9
	channel10
	channel11
	channel12
	channel13
	channel14
	channel15
	channel16
End Enum

'控制符
Enum ControlModeChangesEnum           ' Byte1, Byte2
	BankSelectHi                  = &H00 ' 0-127 MSB
	ModulationwheelHi                    ' 0-127 MSB
	BreathControlHi                      ' 0-127 MSB
	UndefinedHi1                         ' 0-127 MSB
	FootControllerHi                     ' 0-127 MSB
	PortamentoTimeHI                     ' 0-127 MSB
	DataEntryHi                          ' 0-127 MSB
	ChannelVolumeHi                      ' 0-127 MSB
	BalanceHi                            ' 0-127 MSB
	
	PanHi                         = &H0A ' 0-127 MSB
	ExpressionControllerHi               ' 0-127 MSB
	EffectControl1Hi                     ' 0-127 MSB
	EffectControl2Hi                     ' 0-127 MSB
	
	GeneralPurposeController1Hi   = &H10 ' 0-127 MSB
	GeneralPurposeController2Hi          ' 0-127 MSB
	GeneralPurposeController3Hi          ' 0-127 MSB
	GeneralPurposeController4Hi          ' 0-127 MSB
	
	BankSelectLo                  = &H20 ' 0-127 LSB
	ModulationWheelLo                    ' 0-127 LSB
	BreathControlLo                      ' 0-127 LSB
	
	FootControllerLo              = &H24 ' 0-127 LSB
	PortamentoTimeLo                     ' 0-127 LSB
	DataEntryLo                          ' 0-127 LSB
	ChannelVolumeLo                      ' 0-127 LSB
	BalanceLo                            ' 0-127 LSB
	
	PanLo                         = &H42 ' 0-127 LSB
	ExpressionControllerLo               ' 0-127 LSB
	EffectControl1Lo                     ' 0-127 LSB
	EffectControl2Lo                     ' 0-127 LSB
	
	GeneralPurposeControllerLo1   = &H30 ' 0-127 LSB
	GeneralPurposeControllerLo2          ' 0-127 LSB
	GeneralPurposeControllerLo3          ' 0-127 LSB
	GeneralPurposeControllerLo4          ' 0-127 LSB
	
	DamperPedal                   = &H40 ' Sustain <63=off >64=on
	Portamento                           ' on/off  <63=off >64=on
	Sustenuto                            ' on/off  <63=off >64=on
	SoftPedal                            ' on/off  <63=off >64=on
	LegatoFootSwitch                     ' on/off  <63=off >64=on
	Hold2                                ' on/off  <63=off >64=on
	
	SoundController1Lo                   ' Variation  0-127 LSB
	SoundController2Lo                   ' Timbre     0-127 LSB
	SoundController3Lo                   ' Release 	  0-127 LSB
	SoundController4Lo                   ' Attack     0-127 LSB
	SoundController5Lo                   ' Brightness 0-127 LSB
	
	SoundController6Lo                   ' 0-127 LSB
	SoundController7Lo                   ' 0-127 LSB
	SoundController8Lo                   ' 0-127 LSB
	SoundController9Lo                   ' 0-127 LSB
	SoundController10Lo                  ' 0-127 LSB
	
	GeneralPurposeController5Lo          ' 0-127 LSB
	GeneralPurposeController6Lo          ' 0-127 LSB
	GeneralPurposeController7Lo          ' 0-127 LSB
	GeneralPurposeController8Lo          ' 0-127 LSB
	PortamentoControlLo                  ' 0-127 Source Note
	
	Effects1DepthLo               = &H5B ' 0-127 LSB
	Effects2DepthLo                      ' 0-127 LSB
	Effects3DepthLo                      ' 0-127 LSB
	Effects4DepthLo                      ' 0-127 LSB
	Effects5DepthLo                      ' 0-127 LSB
	DataEntryInc                         '= +1 	(none)
	DataEntryDec                         '= -1 	(none)
	NonRegisteredParameterNumberLo       ' 0-127 LSB
	NonRegisteredParameterNumberHi       ' 0-127 MSB
	RegisteredParameterNumberLo          ' 0-127 LSB
	RegisteredParameterNumberHi          ' 0-127 MSB
	
	AllSoundOff                   = &H78 ' 0
	ResetAllControllers                  ' 0
	LocalControl                         ' 0=off 127=on
	AllNotesOff                          ' 0
	OmniModeOff                          ' (+ all notes off) 	0
	OmniModeOn                           ' (+ all notes off) 	0
	PolyModeOnOff                        ' (+ all notes off)
	PolyModeOn                           ' (incl mono=off +all notes off) 	0
End Enum

Enum MetaEventsEnum
	SequenceNumber       = &H00
	TextEvent
	CopyrightNotice
	SequenceTrackName
	InstrumentName
	Lyric
	Marker
	CuePoint
	ChanneelPrefix       = &H20
	EndofTrack           = &H2F
	SetTempo             = &H51
	SMPTEOffset          = &H54
	TimeSignature        = &H58
	KeySignature
	SequencerSpecific    = &H7F
End Enum

'事件
Enum SequencerEventsEnum  'Statusbyte data  byte1            data byte2
	NoteOff              = &H80 'b1000:chn  note 0-127       (none)
	NoteOn               = &H90 'b1001:chn  note 0-127       velocity   0-127
	PolyphonicAftertouch = &HA0 'b1010:chn  note 0-127       aftertouch 0-127
	ControlMode          = &HB0 'b1011:chn  (see ControlModeChanges)
	ProgramChange        = &HC0 'b1100:chn  program    0-127 (none)
	ChannelAftertouch    = &HD0 'b1101:chn  Aftertouch 0-127 (none)
	PitchWheelControl    = &HE0 'b1110:chn  LSB 0-127        MSB 0-127
	SysEx                = &HF0 'b1111:0000
	
	MIDITimeCode         = &HF1 'b1111:0001
	
	SongPositionPointer  = &HF2 'b1111:0010
	SongSelect           = &HF3 'b1111:0011
	Undefined1           = &HF4 'b1111:0100
	Undefined2           = &HF5 'b1111:0101
	TuneRequest          = &HF6 'b1111:0110
	EOFSysEx             = &HF7 'b1111:0111
	TimingClock          = &HF8 'b1111:1000
	Undefined3           = &HF9 'b1111:1001
	
	MIDIStart            = &HFA 'b1111:1010
	MIDIContinue         = &HFB 'b1111:1011
	MIDIStop             = &HFC 'b1111:1100
	
	Undefined4           = &HFD 'b1111:1101
	ActiveSensing        = &HFE 'b1111:1110
	SystemReset          = &HFF 'b1111:1111
End Enum

'八度音程
'+1=C# +3=D# +6=F# +8=G# +10=A#
'+0=C  +2=D  +4=E  +5=F  +7=G   +9A   +11=B or H
Enum OctavesEnum
	octaveM =   0 ' minus 1
	octave0 =  12
	octave1 =  24
	octave2 =  36
	octave3 =  48
	octave4 =  60 ' midle C
	octave5 =  72
	octave6 =  84
	octave7 =  96
	octave8 = 108
	octave9 = 120
End Enum

'音调
Enum NotesEnum
	_C   =  0
	_Cis =  1
	_D   =  2
	_E   =  3
	_Eis =  4
	_F   =  5
	_Fis =  6
	_G   =  7
	_Gis =  8
	_A   =  9
	_Ais = 10
	_B   = 11 ' or H
	_H   = _B
End Enum

Type Event
	Union
		As Byte  bytes(3)
		As ULong event
	End Union
End Type

Public Const MidiChannelCount = channel16 'start from 0
Public Const MidiInstrumentCount = Gunshot 'start from 0

'乐器
Dim Shared InstrumentsStringE(Gunshot) As WString Ptr = { _
@WStr("Acoustic Grand Piano"), _
@WStr("Bright Acoustic Piano"), _
@WStr("Electric Grand Piano"), _
@WStr("Honky-tonk Piano"), _
@WStr("Electric Piano 1 (Rhodes Piano)"), _
@WStr("Electric Piano 2 (Chorused Piano)"), _
@WStr("Harpsichord"), _
@WStr("Clavinet"), _
@WStr("Celesta"), _
@WStr("Glockenspiel"), _
@WStr("Music Box"), _
@WStr("Vibraphone"), _
@WStr("Marimba"), _
@WStr("Xylophone"), _
@WStr("Tubular Bells"), _
@WStr("Dulcimer (Santur)"), _
@WStr("Drawbar Organ (Hammond)"), _
@WStr("Percussive Organ"), _
@WStr("Rock Organ"), _
@WStr("Church Organ"), _
@WStr("Reed Organ"), _
@WStr("Accordion (French)"), _
@WStr("Harmonica"), _
@WStr("Tango Accordion (Band neon)"), _
@WStr("Acoustic Guitar (nylon)"), _
@WStr("Acoustic Guitar (steel)"), _
@WStr("Electric Guitar (jazz)"), _
@WStr("Electric Guitar (clean)"), _
@WStr("Electric Guitar (muted)"), _
@WStr("Overdriven Guitar"), _
@WStr("Distortion Guitar"), _
@WStr("Guitar harmonics"), _
@WStr("Acoustic Bass"), _
@WStr("Electric Bass (fingered)"), _
@WStr("Electric Bass (picked)"), _
@WStr("Fretless Bass"), _
@WStr("Slap Bass 1"), _
@WStr("Slap Bass 2"), _
@WStr("Synth Bass 1"), _
@WStr("Synth Bass 2"), _
@WStr("Violin"), _
@WStr("Viola"), _
@WStr("Cello"), _
@WStr("Contrabass"), _
@WStr("Tremolo Strings"), _
@WStr("Pizzicato Strings"), _
@WStr("Orchestral Harp"), _
@WStr("Timpani"), _
@WStr("String Ensemble 1 (strings)"), _
@WStr("String Ensemble 2 (slow strings)"), _
@WStr("SynthStrings 1"), _
@WStr("SynthStrings 2"), _
@WStr("Choir Aahs"), _
@WStr("Voice Oohs"), _
@WStr("Synth Voice"), _
@WStr("Orchestra Hit"), _
@WStr("Trumpet"), _
@WStr("Trombone"), _
@WStr("Tuba"), _
@WStr("Muted Trumpet"), _
@WStr("French Horn"), _
@WStr("Brass Section"), _
@WStr("SynthBrass 1"), _
@WStr("SynthBrass 2"), _
@WStr("Soprano Sax"), _
@WStr("Alto Sax"), _
@WStr("Tenor Sax"), _
@WStr("Baritone Sax"), _
@WStr("Oboe"), _
@WStr("English Horn"), _
@WStr("Bassoon"), _
@WStr("Clarinet"), _
@WStr("Piccolo"), _
@WStr("Flute"), _
@WStr("Recorder"), _
@WStr("Pan Flute"), _
@WStr("Blown Bottle"), _
@WStr("Shakuhachi"), _
@WStr("Whistle"), _
@WStr("Ocarina"), _
@WStr("Lead 1 (square wave)"), _
@WStr("Lead 2 (sawtooth wave)"), _
@WStr("Lead 3 (calliope)"), _
@WStr("Lead 4 (chiffer)"), _
@WStr("Lead 5 (charang)"), _
@WStr("Lead 6 (voice solo)"), _
@WStr("Lead 7 (fifths)"), _
@WStr("Lead 8 (bass + lead)"), _
@WStr("Pad 1 (new age Fantasia)"), _
@WStr("Pad 2 (warm)"), _
@WStr("Pad 3 (polysynth)"), _
@WStr("Pad 4 (choir space voice)"), _
@WStr("Pad 5 (bowed glass)"), _
@WStr("Pad 6 (metallic pro)"), _
@WStr("Pad 7 (halo)"), _
@WStr("Pad 8 (sweep)"), _
@WStr("FX 1 (rain)"), _
@WStr("FX 2 (soundtrack)"), _
@WStr("FX 3 (crystal)"), _
@WStr("FX 4 (atmosphere)"), _
@WStr("FX 5 (brightness)"), _
@WStr("FX 6 (goblins)"), _
@WStr("FX 7 (echoes, drops)"), _
@WStr("FX 8 (sci-fi, star theme)"), _
@WStr("Sitar"), _
@WStr("Banjo"), _
@WStr("Shamisen"), _
@WStr("Koto"), _
@WStr("Kalimba"), _
@WStr("Bag pipe"), _
@WStr("Fiddle"), _
@WStr("Shanai"), _
@WStr("Tinkle Bell"), _
@WStr("Agogo"), _
@WStr("Steel Drums"), _
@WStr("Woodblock"), _
@WStr("Taiko Drum"), _
@WStr("Melodic Tom"), _
@WStr("Synth Drum"), _
@WStr("Reverse Cymbal"), _
@WStr("Guitar Fret Noise"), _
@WStr("Breath Noise"), _
@WStr("Seashore"), _
@WStr("Bird Tweet"), _
@WStr("Telephone Ring"), _
@WStr("Helicopter"), _
@WStr("Applause"), _
@WStr("Gunshot") _
}

Dim Shared InstrumentsStringC(Gunshot) As WString Ptr = { _
@WStr("大钢琴(声学钢琴)"), _
@WStr("明亮的钢琴"), _
@WStr("电钢琴"), _
@WStr("酒吧钢琴"), _
@WStr("柔和的电钢琴"), _
@WStr("加合唱效果的电钢琴"), _
@WStr("羽管键琴(拨弦古钢琴)"), _
@WStr("科拉维科特琴(击弦古钢琴)"), _
@WStr("钢片琴"), _
@WStr("钟琴"), _
@WStr("八音盒"), _
@WStr("颤音琴"), _
@WStr("马林巴"), _
@WStr("木琴"), _
@WStr("管钟"), _
@WStr("大扬琴"), _
@WStr("击杆风琴"), _
@WStr("打击式风琴"), _
@WStr("摇滚风琴"), _
@WStr("教堂风琴"), _
@WStr("簧管风琴"), _
@WStr("手风琴"), _
@WStr("口琴"), _
@WStr("探戈手风琴"), _
@WStr("尼龙弦吉他"), _
@WStr("钢弦吉他"), _
@WStr("爵士电吉他"), _
@WStr("清音电吉他"), _
@WStr("闷音电吉他"), _
@WStr("加驱动效果的电吉他"), _
@WStr("加失真效果的电吉他"), _
@WStr("吉他和音"), _
@WStr("大贝司(声学贝司)"), _
@WStr("电贝司(指弹)"), _
@WStr("电贝司(拨片)"), _
@WStr("无品贝司"), _
@WStr("掌击贝司1"), _
@WStr("掌击贝司2"), _
@WStr("电子合成贝司1"), _
@WStr("电子合成贝司2"), _
@WStr("小提琴"), _
@WStr("中提琴"), _
@WStr("大提琴"), _
@WStr("低音大提琴"), _
@WStr("弦乐群颤音音色"), _
@WStr("弦乐群拨弦音色"), _
@WStr("竖琴"), _
@WStr("定音鼓"), _
@WStr("弦乐合奏音色1"), _
@WStr("弦乐合奏音色2"), _
@WStr("合成弦乐合奏音色1"), _
@WStr("合成弦乐合奏音色2"), _
@WStr("人声合唱-啊"), _
@WStr("人声-嘟"), _
@WStr("合成人声"), _
@WStr("管弦乐敲击齐奏"), _
@WStr("小号"), _
@WStr("长号"), _
@WStr("大号"), _
@WStr("加弱音器小号"), _
@WStr("法国号(圆号)"), _
@WStr("铜管组(铜管乐器合奏音色)"), _
@WStr("合成铜管音色1"), _
@WStr("合成铜管音色2"), _
@WStr("高音萨克斯风"), _
@WStr("次中音萨克斯风"), _
@WStr("中音萨克斯风"), _
@WStr("低音萨克斯风"), _
@WStr("双簧管"), _
@WStr("英国管"), _
@WStr("巴松(大管)"), _
@WStr("单簧管(黑管)"), _
@WStr("短笛"), _
@WStr("长笛"), _
@WStr("竖笛"), _
@WStr("排箫"), _
@WStr("吹瓶"), _
@WStr("日本尺八"), _
@WStr("口哨声"), _
@WStr("奥卡雷那"), _
@WStr("合成主音1(方波)"), _
@WStr("合成主音2(锯齿波)"), _
@WStr("合成主音3"), _
@WStr("合成主音4"), _
@WStr("合成主音5"), _
@WStr("合成主音6(人声)"), _
@WStr("合成主音7(平行五度)"), _
@WStr("合成主音8(贝司加主音)"), _
@WStr("合成音色1(新世纪)"), _
@WStr("合成音色2(温暖)"), _
@WStr("合成音色3"), _
@WStr("合成音色4(合唱)"), _
@WStr("合成音色5"), _
@WStr("合成音色6(金属声)"), _
@WStr("合成音色7(光环)"), _
@WStr("合成音色8"), _
@WStr("合成效果1雨声"), _
@WStr("合成效果2音轨"), _
@WStr("合成效果3水晶"), _
@WStr("合成效果4大气"), _
@WStr("合成效果5明亮"), _
@WStr("合成效果6鬼怪"), _
@WStr("合成效果7回声"), _
@WStr("合成效果8科幻"), _
@WStr("西塔尔(印度)"), _
@WStr("班卓琴(美洲)"), _
@WStr("三昧线(日本)"), _
@WStr("十三弦筝(日本)"), _
@WStr("卡林巴"), _
@WStr("风笛"), _
@WStr("民族提琴"), _
@WStr("山奈"), _
@WStr("叮当铃"), _
@WStr("阿戈戈铃"), _
@WStr("钢鼓"), _
@WStr("木鱼"), _
@WStr("太鼓"), _
@WStr("通通鼓"), _
@WStr("合成鼓"), _
@WStr("铜钹"), _
@WStr("吉他换把杂音"), _
@WStr("呼吸声"), _
@WStr("海浪声"), _
@WStr("鸟鸣"), _
@WStr("电话铃"), _
@WStr("直升机"), _
@WStr("鼓掌声"), _
@WStr("枪声") _
}

Dim Shared PercussionStringE(Gunshot) As WString Ptr = { _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr("B1	Acoustic Bass Drum"), _
@WStr("C2	Bass Drum 1"), _
@WStr("C#2	Side Stick"), _
@WStr("D2	Acoustic Snare"), _
@WStr("D#2	Hand Clap"), _
@WStr("E2	Electric Snare"), _
@WStr("F2	Low Floor Tom"), _
@WStr("F#2	Closed Hi Hat"), _
@WStr("G2	High Floor Tom"), _
@WStr("G#2	Pedal Hi-Hat"), _
@WStr("A2	Low Tom"), _
@WStr("A#2	Open Hi-Hat"), _
@WStr("B2	Low-Mid Tom"), _
@WStr("C3	Hi Mid Tom"), _
@WStr("C#3	Crash Cymbal 1"), _
@WStr("D3	High Tom"), _
@WStr("D#3	Ride Cymbal 1"), _
@WStr("E3	Chinese Cymbal"), _
@WStr("F3	Ride Bell"), _
@WStr("F#3	Tambourine"), _
@WStr("G3	Splash Cymbal"), _
@WStr("G#3	Cowbell"), _
@WStr("A3	Crash Cymbal 2"), _
@WStr("A#3	Vibraslap"), _
@WStr("B3	Ride Cymbal 2"), _
@WStr("C4	Hi Bongo"), _
@WStr("C#4	Low Bongo"), _
@WStr("D4	Mute Hi Conga"), _
@WStr("D#4	Open Hi Conga"), _
@WStr("E4	Low Conga"), _
@WStr("F4	High Timbale"), _
@WStr("F#4	Low Timbale"), _
@WStr("G4	High Agogo"), _
@WStr("G#4	Low Agogo"), _
@WStr("A4	Cabasa"), _
@WStr("A#4	Maracas"), _
@WStr("B4	Short Whistle"), _
@WStr("C5	Long Whistle"), _
@WStr("C#5	Short Guiro"), _
@WStr("D5	Long Guiro"), _
@WStr("D#5	Claves"), _
@WStr("E5	Hi Wood Block"), _
@WStr("F5	Low Wood Block"), _
@WStr("F#5	Mute Cuica"), _
@WStr("G5	Open Cuica"), _
@WStr("G#5	Mute Triangle"), _
@WStr("A5	Open Triangle"), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr(""), _
@WStr("") _
}

Dim Shared NoteStringE(11) As WString Ptr = { _
@WStr("C"), _
@WStr("C#"), _
@WStr("D"), _
@WStr("D#"), _
@WStr("E"), _
@WStr("F"), _
@WStr("F#"), _
@WStr("G"), _
@WStr("G#"), _
@WStr("A"), _
@WStr("A#"), _
@WStr("B") _
}

#ifndef __USE_MAKE__
	#include once "midi.bas"
#endif
