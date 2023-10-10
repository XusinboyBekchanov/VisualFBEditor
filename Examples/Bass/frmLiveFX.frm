'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "frmLiveFX.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#ifdef __FB_64BIT__
		#libpath "./lib/win64"
	#else
		#libpath "./lib/win32"
	#endif
	#include once "mff/Form.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/Label.bi"
	#include once "mff/TrackBar.bi"
	#include once "mff/TimerComponent.bi"
	#include once "mff/GroupBox.bi"
	#include once "mff/ProgressBar.bi"
	#include once "vbcompat.bi"
	#include once "string.bi"
	#include once "crt/math.bi"
	#include once "bass.bi"
	#include once "BassBase.bi"
	
	Using My.Sys.Forms
	
	Type frmLiveFXType Extends Form
		fxtype(3) As DWORD = { BASS_FX_DX8_REVERB, BASS_FX_DX8_GARGLE, BASS_FX_DX8_FLANGER, BASS_FX_DX8_CHORUS }
		
		info As BASS_INFO
		rchan As HRECORD = 0	' recording channel
		chan As HSTREAM = 0		' playback stream
		fx(3) As HFX			' FX handles
		Input As DWORD		' current Input source
		volume As Single = 0.5	' volume level
		
		#define DEFAULTRATE 44100
		#define TARGETBUFS 2 ' managed buffer level target (higher = more safety margin + higher latency)
		
		prebuf As Boolean	' prebuffering
		initrate As DWORD	' initial Output rate
		rate As DWORD		' current Output rate
		ratedelay As DWORD	' rate change delay
		buftarget As DWORD	' target buffer amount
		buflevel As Single 	' current/average buffer amount
		
		Declare Static Function StreamCallback(ByVal handle As HSTREAM, ByVal buffer As Any Ptr, ByVal length As DWORD, ByVal user As Any Ptr) As DWORD
		Declare Function StreamProc(ByVal handle As HSTREAM, ByVal buffer As Any Ptr, ByVal length As DWORD, ByVal user As Any Ptr) As DWORD
'		Declare Sub UpdateInfo()
		Declare Sub ShowError(es As String)
		Declare Function InitDevice(RecDevice As Integer, OutDevice As Integer) As Boolean
		
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub ComboBoxEdit1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub ComboBoxEdit2_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub CheckBox1_Click(ByRef Sender As CheckBox)
		Declare Sub CheckBox2_Click(ByRef Sender As CheckBox)
		Declare Sub TrackBar1_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Sub TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Sub TrackBar2_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Sub TrackBar3_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Sub ComboBoxEdit3_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Constructor
		
		Dim As ComboBoxEdit ComboBoxEdit1, ComboBoxEdit2, ComboBoxEdit3
		Dim As CheckBox CheckBox1, CheckBox2, CheckBox3, CheckBox4, CheckBox5
		Dim As Label Label1, Label2
		Dim As TrackBar TrackBar1, TrackBar2, TrackBar3
		Dim As TimerComponent TimerComponent1
		Dim As GroupBox GroupBox1, GroupBox2, GroupBox3
		Dim As ProgressBar ProgressBar1
	End Type
	
	Constructor frmLiveFXType
		' frmLiveFX
		With This
			.Name = "frmLiveFX"
			.Text = "BASS full-duplex example"
			.BorderStyle = FormBorderStyle.FixedDialog
			.MinimizeBox = False
			.MaximizeBox = False
			.StartPosition = FormStartPosition.CenterScreen
			.Designer = @This
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.SetBounds 0, 0, 260, 440
		End With
		' GroupBox1
		With GroupBox1
			.Name = "GroupBox1"
			.Text = "Input"
			.TabIndex = 0
			.Caption = "Input"
			.SetBounds 10, 10, 230, 130
			.Parent = @This
		End With
		' ComboBoxEdit1
		With ComboBoxEdit1
			.Name = "ComboBoxEdit1"
			.Text = "ComboBoxEdit1"
			.TabIndex = 1
			.SetBounds 10, 20, 210, 21
			.Designer = @This
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @ComboBoxEdit1_Selected)
			.Parent = @GroupBox1
		End With
		' ComboBoxEdit2
		With ComboBoxEdit2
			.Name = "ComboBoxEdit2"
			.Text = "ComboBoxEdit2"
			.TabIndex = 2
			.SetBounds 10, 50, 210, 21
			.Designer = @This
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @ComboBoxEdit2_Selected)
			.Parent = @GroupBox1
		End With
		' Label2
		With Label2
			.Name = "Label2"
			.Text = ""
			.TabIndex = 3
			.Alignment = AlignmentConstants.taCenter
			.Caption = ""
			.SetBounds 10, 80, 210, 20
			.Parent = @GroupBox1
		End With
		' TrackBar2
		With TrackBar2
			.Name = "TrackBar2"
			.Text = "TrackBar2"
			.TabIndex = 4
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.ThumbLength = 15
			.MaxValue = 100
			.SetBounds 10, 100, 210, 20
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TrackBar, Position As Integer), @TrackBar2_Change)
			.Parent = @GroupBox1
		End With
		' GroupBox2
		With GroupBox2
			.Name = "GroupBox2"
			.Text = "Output"
			.TabIndex = 5
			.Caption = "Output"
			.SetBounds 10, 150, 230, 80
			.Parent = @This
		End With
		' ComboBoxEdit3
		With ComboBoxEdit3
			.Name = "ComboBoxEdit3"
			.Text = "ComboBoxEdit3"
			.TabIndex = 6
			.SetBounds 10, 20, 210, 21
			.Designer = @This
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @ComboBoxEdit3_Selected)
			.Parent = @GroupBox2
		End With
		' TrackBar3
		With TrackBar3
			.Name = "TrackBar3"
			.Text = "TrackBar3"
			.TabIndex = 7
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.ThumbLength = 15
			.MaxValue = 100
			.SetBounds 10, 50, 210, 20
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TrackBar, Position As Integer), @TrackBar3_Change)
			.Parent = @GroupBox2
		End With
		' GroupBox3
		With GroupBox3
			.Name = "GroupBox3"
			.Text = "Stream"
			.TabIndex = 8
			.Caption = "Stream"
			.SetBounds 10, 240, 230, 160
			.Parent = @This
		End With
		' ProgressBar1
		With ProgressBar1
			.Name = "ProgressBar1"
			.Text = "ProgressBar1"
			.SetBounds 10, 30, 210, 10
			.Parent = @GroupBox3
		End With
		' TrackBar1
		With TrackBar1
			.Name = "TrackBar1"
			.Text = "TrackBar1"
			.TabIndex = 10
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.ThumbLength = 15
			.MaxValue = 100
			.SetBounds 10, 50, 210, 20
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TrackBar, Position As Integer), @TrackBar1_Change)
			.Parent = @GroupBox3
		End With
		' CheckBox1
		With CheckBox1
			.Name = "CheckBox1"
			.Text = "Manage buffer level"
			.TabIndex = 11
			.Caption = "Manage buffer level"
			.BackColor = 15790320
			.BorderStyle = BorderStyles.bsNone
			.Checked = False
			.DoubleBuffered = False
			.SetBounds 10, 80, 110, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CheckBox1_Click)
			.Parent = @GroupBox3
		End With
		' Label1
		With Label1
			.Name = "Label1"
			.Text = ""
			.TabIndex = 12
			.Alignment = AlignmentConstants.taCenter
			.ID = 1009
			.Caption = ""
			.Border = LabelBorder.sbSunken
			.SetBounds 150, 80, 70, 20
			.Parent = @GroupBox3
		End With
		' CheckBox2
		With CheckBox2
			.Name = "CheckBox2"
			.Text = "Reverb"
			.TabIndex = 13
			.Caption = "Reverb"
			.SetBounds 10, 110, 110, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CheckBox2_Click)
			.Parent = @GroupBox3
		End With
		' CheckBox3
		With CheckBox3
			.Name = "CheckBox3"
			.Text = "Gargle"
			.TabIndex = 14
			.Caption = "Gargle"
			.SetBounds 120, 110, 100, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CheckBox2_Click)
			.Parent = @GroupBox3
		End With
		' CheckBox4
		With CheckBox4
			.Name = "CheckBox4"
			.Text = "Flanger"
			.TabIndex = 15
			.Caption = "Flanger"
			.SetBounds 10, 130, 100, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CheckBox2_Click)
			.Parent = @GroupBox3
		End With
		' CheckBox5
		With CheckBox5
			.Name = "CheckBox5"
			.Text = "Chorus"
			.TabIndex = 16
			.Caption = "Chorus"
			.SetBounds 120, 130, 100, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CheckBox2_Click)
			.Parent = @GroupBox3
		End With
		' TimerComponent1
		With TimerComponent1
			.Name = "TimerComponent1"
			.Enabled = False
			.Interval = 1000
			.SetBounds 0, 0, 16, 16
			.Designer = @This
			.OnTimer = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent), @TimerComponent1_Timer)
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frmLiveFX As frmLiveFXType
	
	#ifndef _NOT_AUTORUN_FORMS_
		#define _NOT_AUTORUN_FORMS_
		
		frmLiveFX.Show
		
		App.Run
	#endif
'#End Region

' display cError messages
Private Sub frmLiveFXType.ShowError(es As String)
	MessageBox(0, es & vbCrLf & "Error code: " & BASS_ErrorGetCode(), 0, 0)
End Sub

Private Function frmLiveFXType.StreamCallback(ByVal handle As HSTREAM, ByVal buffer As Any Ptr, ByVal length As DWORD, ByVal user As Any Ptr) As DWORD
	Return (*Cast(frmLiveFXType Ptr, user)).StreamProc(handle, buffer, length, user)
End Function

Private Function frmLiveFXType.StreamProc(ByVal handle As HSTREAM, ByVal buffer As Any Ptr, ByVal length As DWORD, ByVal user As Any Ptr) As DWORD
	Dim As DWORD got = BASS_ChannelGetData(rchan, NULL, BASS_DATA_AVAILABLE) ' Get recording buffer level
	buflevel = (buflevel * 49 + got) / 50.0
	If (got = 0) Then prebuf = True ' prebuffer again If buffer Is empty
	If (prebuf) Then ' prebuffering
		buflevel = got
		If (got < IIf(buftarget, buftarget, length)) Then Return 0 ';  haven 't got enough yet
		prebuf = False
		ratedelay = 10
	End If
	Dim As DWORD r = rate
	If (buftarget) Then
		#if 1 ' target buffer amount = minimum
			If (got < buftarget) Then ' buffer level Is low
				r = initrate * 0.999 ' slow down slightly
				ratedelay = 10 + (buftarget - got) / 16 ' prevent speeding-up again too soon
			ElseIf (ratedelay = 0) Then
				If (buflevel >= buftarget * 1.1) Then ' buffer level Is high
					r = initrate * 1.001 ' speed up slightly
				Else ' buffer level Is in range
					r = initrate ' normal speed
				End If
			Else
				ratedelay -= 1
			End If
		#else ' target buffer amount = average
			If (buflevel < buftarget) Then ' buffer level Is low
				r = initrate * 0.999 ' slow down slightly
			ElseIf (buflevel >= buftarget * 1.1) Then ' buffer level Is high
				r = initrate * 1.001 ' speed up slightly
			Else ' buffer level Is in range
				r = initrate ' normal speed
			End If
		#endif
	Else
		r = initrate
	End If
	If (r <> rate) Then BASS_ChannelSetAttribute(chan, BASS_ATTRIB_FREQ, rate = r)
	Return BASS_ChannelGetData(rchan, buffer, length) ' Get the Data
End Function

Private Function frmLiveFXType.InitDevice(RecDevice As Integer, OutDevice As Integer) As Boolean
	' initalize New input device
	If (chan) Then BASS_StreamFree(chan) ' free Output stream
	chan = 0
	If (rchan) Then BASS_StreamFree(rchan) ' free Output stream
	rchan = 0

	InputInit(RecDevice)
	
	' get list of inputs
	InputInfo(Input, @ComboBoxEdit2, @Label2, @TrackBar2, @Label2)
	
	Dim As BASS_RECORDINFO rinfo
	BASS_RecordGetInfo(@rinfo)
'	
	initrate = rinfo.freq
	' use the native recording rate (If available)
	rate = IIf (initrate, rinfo.freq, DEFAULTRATE)
	
	' start Output immediately To avoid needing a burst of Data at start of stream
	BASS_SetConfig(BASS_CONFIG_DEV_NONSTOP, 1)
	
	' initialize default Output device
	OutputInit(OutDevice, This.Handle)
	
	volume = BASS_GetVolume
	TrackBar3.Position = volume* 100
	
	BASS_GetInfo(@info)
	If (info.dsver < 8) Then
		' no DX8, so disable effect buttons
		CheckBox2.Enabled = True
		CheckBox3.Enabled = True
		CheckBox4.Enabled = True
		CheckBox5.Enabled = True
	End If
	
	chan = BASS_StreamCreate(rate, 2, BASS_SAMPLE_FLOAT, @StreamCallback, @This) ' create Output stream
	BASS_ChannelSetAttribute(chan, BASS_ATTRIB_BUFFER, 0) ' disable playback buffering
	BASS_ChannelGetAttribute(chan, BASS_ATTRIB_VOL, @volume) ' get volume level
	TrackBar1.Position = volume* 100

	' set effects
	If CheckBox2.Checked Then
		fx(0) = BASS_ChannelSetFX(chan, fxtype(0), 0)
	Else
		If fx(0) Then BASS_ChannelRemoveFX(chan, fx(0))
		fx(0) = 0
	End If
	If CheckBox3.Checked Then
		fx(1) = BASS_ChannelSetFX(chan, fxtype(1), 1)
	Else
		If fx(1) Then BASS_ChannelRemoveFX(chan, fx(1))
		fx(1) = 0
	End If
	If CheckBox4.Checked Then
		fx(2) = BASS_ChannelSetFX(chan, fxtype(2), 2)
	Else
		If fx(2) Then BASS_ChannelRemoveFX(chan, fx(1))
		fx(2) = 0
	End If
	If CheckBox5.Checked Then
		fx(3) = BASS_ChannelSetFX(chan, fxtype(3), 3)
	Else
		If fx(3) Then BASS_ChannelRemoveFX(chan, fx(3))
		fx(3) = 0
	End If
	
	' don 't need/want a big recording buffer
	BASS_SetConfig(BASS_CONFIG_REC_BUFFER, (TARGETBUFS + 3) * info.minbuf)
	
	' record without a RECORDPROC so Output stream can pull Data from it
	rchan = BASS_RecordStart(rate, 2, BASS_SAMPLE_FLOAT, NULL, 0)
	If (rchan = 0) Then
		ShowError("Can't start recording")
		BASS_RecordFree()
		BASS_StreamFree(chan)
		Return False
	End If
	If CheckBox1.Enabled Then
		buftarget = BASS_ChannelSeconds2Bytes(rchan, TARGETBUFS * info.minbuf / 1000.0) ' target buffer level
	Else
		buftarget = 0
	End If
	prebuf = True ' start prebuffering
	BASS_ChannelPlay(chan, False) ' start the Output
	
	Return True
	
End Function

Private Sub frmLiveFXType.Form_Create(ByRef Sender As Control)
	Dim hr As HRESULT
	hr = CoInitialize(0)
	
	' check the correct BASS was loaded
	If (HiWord(BASS_GetVersion()) <> BASSVERSION) Then
		MessageBox(This.Handle, "An incorrect version of BASS.DLL was loaded", 0, MB_ICONERROR)
	End If
	
	MessageBox(This.Handle, "Setting the input to the output loopback (or 'Stereo Mix' or similar on the same soundcard) with the level set high is likely to result in nasty feedback.", "Feedback warning", MB_ICONWARNING)
	
	InputDeviceList(@ComboBoxEdit1)
	OutputDeviceList(@ComboBoxEdit3)
	InitDevice(ComboBoxEdit1.ItemIndex, ComboBoxEdit3.ItemIndex)
	TimerComponent1.Enabled = True
End Sub

Private Sub frmLiveFXType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	BASS_RecordFree()
	BASS_Free()
	CoUninitialize()
End Sub

Private Sub frmLiveFXType.ComboBoxEdit1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	InitDevice(ComboBoxEdit1.ItemIndex, ComboBoxEdit3.ItemIndex)
End Sub

Private Sub frmLiveFXType.ComboBoxEdit2_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	Input = ItemIndex
	RecSetInput(Input)
	InputInfo(Input, @ComboBoxEdit2, @Label2, @TrackBar2, @Label2)
End Sub

Private Sub frmLiveFXType.CheckBox1_Click(ByRef Sender As CheckBox)
	If CheckBox1.Checked Then
		buftarget = BASS_ChannelSeconds2Bytes(rchan, TARGETBUFS * info.minbuf / 1000.0) ' target buffer level
	Else
		buftarget = 0
	End If
'	TimerComponent1.Enabled = CheckBox1.Checked
End Sub

Private Sub frmLiveFXType.CheckBox2_Click(ByRef Sender As CheckBox)
	Dim As Integer i = 0
	Select Case Sender.Text
	Case "Reverb"
		i = 0
	Case "Gargle"
		i = 1
	Case "Flanger"
		i = 2
	Case "Chorus"
		i = 3
	End Select
	
	If Sender.Checked Then
		fx(i) = BASS_ChannelSetFX(chan, fxtype(i), i)
	Else
		If (fx(i)) Then
			BASS_ChannelRemoveFX(chan, fx(i))
			fx(i) = 0
		End If
	End If
End Sub

Private Sub frmLiveFXType.TrackBar1_Change(ByRef Sender As TrackBar, Position As Integer)
	volume = Position / 100
	BASS_ChannelSetAttribute(chan, BASS_ATTRIB_VOL, volume)
End Sub

Private Sub frmLiveFXType.TimerComponent1_Timer(ByRef Sender As TimerComponent)
	Dim As Single level = 0
	If (chan <> 0) Then
		BASS_ChannelGetLevelEx(chan, @level, 0.1, BASS_LEVEL_MONO) ' Get current level
		If (level > 0) Then
			level = 1 + 0.5 * log10(level) ' convert To dB (40dB range)
			If (level < 0) Then level = 0
		End If
		ProgressBar1.Position = level * 100
	End If
	If (rchan) Then ' display current buffer level
		Label1.Text = Format(BASS_ChannelBytes2Seconds(rchan, buflevel) * 1000, "0.0") & "ms"
	Else
		Label1.Text = "na"
	End If
End Sub

Private Sub frmLiveFXType.TrackBar2_Change(ByRef Sender As TrackBar, Position As Integer)
	Dim f As Single= Position / 100
	If BASS_RecordSetInput(Input, BASS_INPUT_ON, f) = 0 Then
		BASS_RecordSetInput(-1, BASS_INPUT_ON, f)
	End If
End Sub

Private Sub frmLiveFXType.TrackBar3_Change(ByRef Sender As TrackBar, Position As Integer)
	BASS_SetVolume(Position / 100)
End Sub

Private Sub frmLiveFXType.ComboBoxEdit3_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	InitDevice(ComboBoxEdit1.ItemIndex, ComboBoxEdit3.ItemIndex)
End Sub
