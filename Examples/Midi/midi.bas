'midi.bas
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

'Some of codes are refer to Test of midiOutShortMsg()
'https://www.freebasic.net/forum/viewtopic.php?t=29670

#include once "midi.bi"

'更改乐器
'see InstrumentEnum,InstrumentString for Instrument
Function SendProgramChange(hDev As HMIDIOUT, Chn As ChannelsEnum, Instrument As UByte) As MMRESULT
	Dim As Event ev
	InRange(Chn, 0, 15)
	InRange(Instrument, 0, 127)
	ev.bytes(0) = ProgramChange Or Chn
	ev.bytes(1) = Instrument
	Return midiOutShortMsg(hDev, ev.event)
End Function

'音调调节轮
' 7low and 7hi bits=14 bits (0 - 16383)
Function SendPitchWheelControl(hDev As HMIDIOUT, Chn As ChannelsEnum, Num As InstrumentsEnum) As MMRESULT
	Dim As Event ev
	InRange(Chn, 0, 15)
	InRange(Num, 0, 16383)
	ev.bytes(0) = PitchWheelControl Or Chn
	ev.bytes(1) = Num And &H7F
	Num Shr = 7
	ev.bytes(2) = Num And &H7F
	Return midiOutShortMsg(hDev, ev.event)
End Function

'音符发声
'参数分别为通道编号，音调，速度
Function SendNoteOn(hDev As HMIDIOUT, Chn As ChannelsEnum, Note As UByte, Vel As UByte) As MMRESULT
	Dim As Event ev
	InRange(Chn, 0, 15)
	InRange(Note, 0, 127)
	InRange(Vel, 0, 127)
	ev.bytes(0) = NoteOn Or Chn
	ev.bytes(1) = Note
	ev.bytes(2) = Vel
	Return midiOutShortMsg(hDev, ev.event)
End Function

'音符禁声
'参数分别为通道编号，音调，速度
Function SendNoteOff(hDev As HMIDIOUT, Chn As ChannelsEnum, Note As UByte, Vel As UByte) As MMRESULT
	Dim As Event ev
	InRange(Chn, 0, 15)
	InRange(Note, 0, 127)
	InRange(Vel, 0, 127)
	ev.bytes(0) = NoteOff Or Chn
	ev.bytes(1) = Note
	ev.bytes(2) = Vel
	Return midiOutShortMsg(hDev, ev.event)
End Function
