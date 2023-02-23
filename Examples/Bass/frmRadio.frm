'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		Const _MAIN_FILE_ = __FILE__
		#ifdef __FB_WIN32__
			#cmdline "frmRadio.rc"
		#endif
	#endif
	#include once "mff/Form.bi"
	#include once "mff/GroupBox.bi"
	#include once "mff/Label.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/TimerComponent.bi"
	
	#include once "vbcompat.bi"
	#include once "string.bi"
	#include once "bass.bi"
	
	#define BASS_SYNC_HLS_SEGMENT	&H10300
	#define BASS_TAG_HLS_EXTINF		&h14000
	
	Using My.Sys.Forms
	
	Type frmRadioType Extends Form
		
		urls(10) As String = { _
		"http://stream-dc1.radioparadise.com/rp_192m.ogg", "http://www.radioparadise.com/m3u/mp3-32.m3u", _
		"http://somafm.com/secretagent.pls", "http://somafm.com/secretagent32.pls", _
		"http://somafm.com/suburbsofgoa.pls", "http://somafm.com/suburbsofgoa32.pls", _
		"http://bassdrive.com/bassdrive.m3u", "http://bassdrive.com/bassdrive3.m3u", _
		"http://sc6.radiocaroline.net:8040/listen.pls", "http://sc2.radiocaroline.net:8010/listen.pls" _
		}
		
		cLock As CRITICAL_SECTION
		chan As HSTREAM ' stream chandle
		
		Declare Sub ShowError(es As String)
		Declare Sub DoMeta()
		Declare Static Sub MetaSync(ByVal chandle As HSYNC, ByVal channel As DWORD, ByVal cData As DWORD, ByVal user As Any Ptr)
		Declare Static Sub StallSync(ByVal chandle As HSYNC, ByVal channel As DWORD, ByVal cData As DWORD, ByVal user As Any Ptr)
		Declare Static Sub FreeSync(ByVal chandle As HSYNC, ByVal channel As DWORD, ByVal cData As DWORD, ByVal user As Any Ptr)
		Declare Static Sub StatusProc(ByVal buffer As Const Any Ptr, ByVal length As DWORD, ByVal user As Any Ptr)
		Declare Function OpenURL(ByVal url As String) As DWORD
		
		Declare Static Sub _Form_Create(ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Static Sub _CommandButton1_Click(ByRef Sender As Control)
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Static Sub _CommandButton6_Click(ByRef Sender As Control)
		Declare Sub CommandButton6_Click(ByRef Sender As Control)
		Declare Static Sub _Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Static Sub _TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Sub TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Static Sub _CommandButton11_Click(ByRef Sender As Control)
		Declare Sub CommandButton11_Click(ByRef Sender As Control)
		Declare Static Sub _CheckBox1_Click(ByRef Sender As CheckBox)
		Declare Sub CheckBox1_Click(ByRef Sender As CheckBox)
		Declare Static Sub _TextBox1_Change(ByRef Sender As TextBox)
		Declare Sub TextBox1_Change(ByRef Sender As TextBox)
		Declare Constructor
		
		Dim As GroupBox GroupBox1, GroupBox2, GroupBox3, GroupBox4
		Dim As Label Label1, Label2, Label3, Label4, Label5
		Dim As CommandButton CommandButton1, CommandButton2, CommandButton3, CommandButton4, CommandButton5, CommandButton6, CommandButton7, CommandButton8, CommandButton9, CommandButton10, CommandButton11
		Dim As ComboBoxEdit ComboBoxEdit1
		Dim As TextBox TextBox1
		Dim As CheckBox CheckBox1
		Dim As TimerComponent TimerComponent1
	End Type
	
	Constructor frmRadioType
		' frmRadio
		With This
			.Name = "frmRadio"
			.Text = "BASS internet radio example"
			.Caption = "BASS internet radio example"
			.BorderStyle = FormBorderStyle.Fixed3D
			.MaximizeBox = False
			.MinimizeBox = False
			.StartPosition = FormStartPosition.CenterScreen
			.Designer = @This
			.OnCreate = @_Form_Create
			.OnClose = @_Form_Close
			.SetBounds 0, 0, 350, 400
		End With
		' GroupBox1
		With GroupBox1
			.Name = "GroupBox1"
			.Text = "Presets"
			.TabIndex = 0
			.Caption = "Presets"
			.SetBounds 10, 10, 320, 80
			.Parent = @This
		End With
		' Label1
		With Label1
			.Name = "Label1"
			.Text = "High bitrate"
			.TabIndex = 1
			.Caption = "High bitrate"
			.SetBounds 10, 20, 80, 20
			.Parent = @GroupBox1
		End With
		' Label2
		With Label2
			.Name = "Label2"
			.Text = "Low bitrate"
			.TabIndex = 2
			.Caption = "Low bitrate"
			.SetBounds 10, 50, 90, 20
			.Parent = @GroupBox1
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "1"
			.TabIndex = 3
			.Caption = "1"
			.SetBounds 120, 20, 30, 20
			.Designer = @This
			.OnClick = @_CommandButton1_Click
			.Parent = @GroupBox1
		End With
		' CommandButton2
		With CommandButton2
			.Name = "CommandButton2"
			.Text = "2"
			.TabIndex = 4
			.Caption = "2"
			.SetBounds 160, 20, 30, 20
			.Designer = @This
			.OnClick = @_CommandButton1_Click
			.Parent = @GroupBox1
		End With
		' CommandButton3
		With CommandButton3
			.Name = "CommandButton3"
			.Text = "3"
			.TabIndex = 5
			.Caption = "3"
			.SetBounds 200, 20, 30, 20
			.Designer = @This
			.OnClick = @_CommandButton1_Click
			.Parent = @GroupBox1
		End With
		' CommandButton4
		With CommandButton4
			.Name = "CommandButton4"
			.Text = "4"
			.TabIndex = 6
			.Caption = "4"
			.SetBounds 240, 20, 30, 20
			.Designer = @This
			.OnClick = @_CommandButton1_Click
			.Parent = @GroupBox1
		End With
		' CommandButton5
		With CommandButton5
			.Name = "CommandButton5"
			.Text = "5"
			.TabIndex = 7
			.Caption = "5"
			.SetBounds 280, 20, 30, 20
			.Designer = @This
			.OnClick = @_CommandButton1_Click
			.Parent = @GroupBox1
		End With
		' CommandButton6
		With CommandButton6
			.Name = "CommandButton6"
			.Text = "1"
			.TabIndex = 8
			.Caption = "1"
			.SetBounds 120, 50, 30, 20
			.Designer = @This
			.OnClick = @_CommandButton6_Click
			.Parent = @GroupBox1
		End With
		' CommandButton7
		With CommandButton7
			.Name = "CommandButton7"
			.Text = "2"
			.TabIndex = 9
			.Caption = "2"
			.SetBounds 160, 50, 30, 20
			.Designer = @This
			.OnClick = @_CommandButton6_Click
			.Parent = @GroupBox1
		End With
		' CommandButton8
		With CommandButton8
			.Name = "CommandButton8"
			.Text = "3"
			.TabIndex = 10
			.Caption = "3"
			.SetBounds 200, 50, 30, 20
			.Designer = @This
			.OnClick = @_CommandButton6_Click
			.Parent = @GroupBox1
		End With
		' CommandButton9
		With CommandButton9
			.Name = "CommandButton9"
			.Text = "4"
			.TabIndex = 11
			.Caption = "4"
			.SetBounds 240, 50, 30, 20
			.Designer = @This
			.OnClick = @_CommandButton6_Click
			.Parent = @GroupBox1
		End With
		' CommandButton10
		With CommandButton10
			.Name = "CommandButton10"
			.Text = "5"
			.TabIndex = 12
			.Caption = "5"
			.SetBounds 280, 50, 30, 20
			.Designer = @This
			.OnClick = @_CommandButton6_Click
			.Parent = @GroupBox1
		End With
		' GroupBox2
		With GroupBox2
			.Name = "GroupBox2"
			.Text = "Custom"
			.TabIndex = 13
			.Caption = "Custom"
			.SetBounds 10, 100, 320, 50
			.Parent = @This
		End With
		' ComboBoxEdit1
		With ComboBoxEdit1
			.Name = "ComboBoxEdit1"
			.Text = ""
			.TabIndex = 14
			.SetBounds 10, 20, 220, 21
			.Style = ComboBoxEditStyle.cbDropDown
			.Parent = @GroupBox2
		End With
		' CommandButton11
		With CommandButton11
			.Name = "CommandButton11"
			.Text = "Open"
			.TabIndex = 15
			.Caption = "Open"
			.SetBounds 240, 20, 70, 20
			.Designer = @This
			.OnClick = @_CommandButton11_Click
			.Parent = @GroupBox2
		End With
		' GroupBox3
		With GroupBox3
			.Name = "GroupBox3"
			.Text = "Currently playing"
			.TabIndex = 16
			.Caption = "Currently playing"
			.SetBounds 10, 160, 320, 120
			.Parent = @This
		End With
		' Label3
		With Label3
			.Name = "Label3"
			.Text = ""
			.TabIndex = 17
			.Alignment = AlignmentConstants.taCenter
			.Caption = ""
			.SetBounds 10, 20, 300, 50
			.Parent = @GroupBox3
		End With
		' Label4
		With Label4
			.Name = "Label4"
			.Text = "not playing"
			.TabIndex = 18
			.Alignment = AlignmentConstants.taCenter
			.Caption = "not playing"
			.SetBounds 10, 70, 300, 20
			.Parent = @GroupBox3
		End With
		' Label5
		With Label5
			.Name = "Label5"
			.Text = ""
			.TabIndex = 19
			.Alignment = AlignmentConstants.taCenter
			.Caption = ""
			.SetBounds 10, 90, 300, 20
			.Parent = @GroupBox3
		End With
		' GroupBox4
		With GroupBox4
			.Name = "GroupBox4"
			.Text = "Proxy server"
			.TabIndex = 20
			.Caption = "Proxy server"
			.SetBounds 10, 290, 320, 70
			.Parent = @This
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = ""
			.TabIndex = 21
			.Enabled = False
			.SetBounds 10, 20, 300, 20
			.Designer = @This
			.OnChange = @_TextBox1_Change
			.Parent = @GroupBox4
		End With
		' CheckBox1
		With CheckBox1
			.Name = "CheckBox1"
			.Text = "Direct connection"
			.TabIndex = 22
			.Caption = "Direct connection"
			.Checked = True
			.SetBounds 10, 40, 140, 20
			.Designer = @This
			.OnClick = @_CheckBox1_Click
			.Parent = @GroupBox4
		End With
		' TimerComponent1
		With TimerComponent1
			.Name = "TimerComponent1"
			.SetBounds 290, 0, 16, 16
			.Designer = @This
			.OnTimer = @_TimerComponent1_Timer
			.Parent = @GroupBox3
		End With
	End Constructor
	
	Private Sub frmRadioType._TextBox1_Change(ByRef Sender As TextBox)
		*Cast(frmRadioType Ptr, Sender.Designer).TextBox1_Change(Sender)
	End Sub
	
	Private Sub frmRadioType._CheckBox1_Click(ByRef Sender As CheckBox)
		*Cast(frmRadioType Ptr, Sender.Designer).CheckBox1_Click(Sender)
	End Sub
	
	Private Sub frmRadioType._CommandButton11_Click(ByRef Sender As Control)
		*Cast(frmRadioType Ptr, Sender.Designer).CommandButton11_Click(Sender)
	End Sub
	
	Private Sub frmRadioType._TimerComponent1_Timer(ByRef Sender As TimerComponent)
		*Cast(frmRadioType Ptr, Sender.Designer).TimerComponent1_Timer(Sender)
	End Sub
	
	Private Sub frmRadioType._Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		*Cast(frmRadioType Ptr, Sender.Designer).Form_Close(Sender, Action)
	End Sub
	
	Private Sub frmRadioType._CommandButton6_Click(ByRef Sender As Control)
		*Cast(frmRadioType Ptr, Sender.Designer).CommandButton6_Click(Sender)
	End Sub
	
	Private Sub frmRadioType._CommandButton1_Click(ByRef Sender As Control)
		*Cast(frmRadioType Ptr, Sender.Designer).CommandButton1_Click(Sender)
	End Sub
	
	Private Sub frmRadioType._Form_Create(ByRef Sender As Control)
		*Cast(frmRadioType Ptr, Sender.Designer).Form_Create(Sender)
	End Sub
	
	Dim Shared frmRadio As frmRadioType
	
	#ifndef _NOT_AUTORUN_FORMS_
		#define _NOT_AUTORUN_FORMS_
		
		frmRadio.Show
		
		App.Run
	#endif
'#End Region

' display cError messages
Private Sub frmRadioType.ShowError(es As String)
	MessageBox(0, es & vbCrLf & "Error code: " & BASS_ErrorGetCode(), 0, 0)
End Sub

' update stream title from metacdata
Private Sub frmRadioType.DoMeta()
	Dim As ZString Ptr meta = Cast(ZString Ptr, BASS_ChannelGetTags(chan, BASS_TAG_META)) ' got Shoutcast metacdata
	If (meta = 0) Then
		meta = Cast(ZString Ptr, BASS_ChannelGetTags(chan, BASS_TAG_OGG)) ' got Icecast/OGG tags
		If (meta = 0) Then
			meta = Cast(ZString Ptr, BASS_ChannelGetTags(chan, BASS_TAG_HLS_EXTINF)) ' got HLS segment info
		End If
	End If
	If (meta) Then
		If InStr(Label3.Text, *meta) = 0 Then Label3.Text = *meta
	End If
End Sub

Private Sub frmRadioType.MetaSync(ByVal chandle As HSYNC, ByVal channel As DWORD, ByVal cData As DWORD, ByVal user As Any Ptr)
	*Cast(frmRadioType Ptr, user).DoMeta()
End Sub

Private Sub frmRadioType.StallSync(ByVal chandle As HSYNC, ByVal channel As DWORD, ByVal cData As DWORD, ByVal user As Any Ptr)
	If (cData = 0) Then ' stalled
		*Cast(frmRadioType Ptr, user).TimerComponent1.Enabled = True ' start buffer monitoring
	End If
End Sub

Private Sub frmRadioType.FreeSync(ByVal chandle As HSYNC, ByVal channel As DWORD, ByVal cData As DWORD, ByVal user As Any Ptr)
	*Cast(frmRadioType Ptr, user).chan = 0
	*Cast(frmRadioType Ptr, user).Label4.Text =  "not playing"
	*Cast(frmRadioType Ptr, user).Label3.Text =  ""
	*Cast(frmRadioType Ptr, user).Label5.Text =  ""
End Sub

Private Sub frmRadioType.StatusProc(ByVal buffer As Const Any Ptr, ByVal length As DWORD, ByVal user As Any Ptr)
	'(buffer As Any Ptr, length As DWORD, user As Any Ptr)
	If buffer <> 0 And length = 0 Then ' got HTTP/ICY tags, And This Is still the current request Then
		Dim As ZString Ptr proc = Cast(ZString Ptr, buffer)
		If InStr(*Cast(frmRadioType Ptr, user).Label5.Text, *proc) = 0 Then *Cast(frmRadioType Ptr, user).Label5.Text = *proc ' display status
	End If
End Sub

Private Function frmRadioType.OpenURL(ByVal url As String) As DWORD
	ComboBoxEdit1.Text = url
	If (chan) Then BASS_StreamFree(chan) ' Close old stream
	Label4.Text =  "connecting..."
	Label3.Text =  ""
	Label5.Text =  ""
	
	Dim As DWORD c
	c = BASS_StreamCreateURL(url, 0, BASS_STREAM_BLOCK Or BASS_STREAM_STATUS Or BASS_STREAM_AUTOFREE Or BASS_SAMPLE_FLOAT, @StatusProc(), @This) ' open URL
	EnterCriticalSection(@cLock)
	chan = c ' This Is Now the current stream
	LeaveCriticalSection(@cLock)
	If (chan = 0) Then ' failed To Open
		Label4.Text =  "not playing"
		ShowError("Can't play the stream")
	Else
		' set syncs For stream title updates
		BASS_ChannelSetSync(chan, BASS_SYNC_META, 0, @MetaSync(), @This) ' Shoutcast
		BASS_ChannelSetSync(chan, BASS_SYNC_OGG_CHANGE, 0, @MetaSync(), @This) ' Icecast/OGG
		BASS_ChannelSetSync(chan, BASS_SYNC_HLS_SEGMENT, 0, @MetaSync(), @This) ' HLS
		' set sync For stalling/buffering
		BASS_ChannelSetSync(chan, BASS_SYNC_STALL, 0, @StallSync(), @This)
		' set sync For End of stream (when freed due To AUTOFREE)
		BASS_ChannelSetSync(chan, BASS_SYNC_FREE, 0, @FreeSync(), @This)
		' play it!
		BASS_ChannelPlay(chan, False)
		' start buffer monitoring (And display stream info when done)
		TimerComponent1.Enabled = True
	End If
	Return 0
End Function

Private Sub frmRadioType.Form_Create(ByRef Sender As Control)
	' check the correct BASS was loaded
	If (HiWord(BASS_GetVersion()) <> BASSVERSION) Then
		MessageBox(0, "An incorrect version of BASS.DLL was loaded", 0, MB_ICONERROR)
	End If
	' enable playlist processing
	BASS_SetConfig(BASS_CONFIG_NET_PLAYLIST, 1)
	
	' initialize default Output device
	If (BASS_Init(-1, 44100, 0, This.Handle, NULL) = 0) Then
		ShowError("Can't initialize device")
	End If
	
	BASS_PluginLoad("bass_aac.dll", 0) ' load BASS_AAC (If present) For AAC support On older Windows
	BASS_PluginLoad("bassflac.dll", 0) ' load BASSFLAC (If present) For FLAC support
	BASS_PluginLoad("basshls.dll", 0) ' load BASSHLS (If present) For HLS support
	
	InitializeCriticalSection(@cLock)
	
	ComboBoxEdit1.AddItem "http://www.radioparadise.com/m3u/mp3-128.m3u"
	ComboBoxEdit1.AddItem "http://www.radioparadise.com/m3u/mp3-32.m3u"
	ComboBoxEdit1.AddItem "http://icecast.timlradio.co.uk/vr160.ogg"
	ComboBoxEdit1.AddItem "http://icecast.timlradio.co.uk/vr32.ogg"
	ComboBoxEdit1.AddItem "http://icecast.timlradio.co.uk/a8160.ogg"
	ComboBoxEdit1.AddItem "http://icecast.timlradio.co.uk/a832.ogg"
	ComboBoxEdit1.AddItem "http://somafm.com/secretagent.pls"
	ComboBoxEdit1.AddItem "http://somafm.com/secretagent24.pls"
	ComboBoxEdit1.AddItem "http://somafm.com/suburbsofgoa.pls"
	ComboBoxEdit1.AddItem "http://somafm.com/suburbsofgoa24.pls"
	ComboBoxEdit1.AddItem "http://ai-radio.org/128.ogg"
	ComboBoxEdit1.AddItem "http://ai-radio.org/256.ogg"
	ComboBoxEdit1.AddItem "http://ai-radio.org/320.ogg"
	ComboBoxEdit1.AddItem "http://ai-radio.org/44.flac"
	ComboBoxEdit1.AddItem "http://ai-radio.org/320.opus"
	ComboBoxEdit1.AddItem "https://www.wxxi.org/sites/default/files/am-aac-triton.m3u"
	ComboBoxEdit1.AddItem "https://www.wxxi.org/sites/default/files/am-mp3-triton.m3u"
	ComboBoxEdit1.AddItem "https://www.wxxi.org/sites/default/files/fm-aac-triton.m3u"
	ComboBoxEdit1.AddItem "https://www.wxxi.org/sites/default/files/fm-mp3-triton.m3u"
	ComboBoxEdit1.AddItem "https://www.wxxi.org/sites/default/files/rr-aac-triton.m3u"
	ComboBoxEdit1.AddItem "https://www.wxxi.org/sites/default/files/rr-mp3-triton.m3u"
	ComboBoxEdit1.AddItem "https://www.wxxi.org/sites/default/files/weos-aac-triton.m3u"
	ComboBoxEdit1.AddItem "https://www.wxxi.org/sites/default/files/weos-mp3-triton.m3u"
	ComboBoxEdit1.AddItem "https://www.wxxi.org/sites/default/files/with-aac-triton.m3u"
	ComboBoxEdit1.AddItem "https://www.wxxi.org/sites/default/files/with-mp3-triton.m3u"
	ComboBoxEdit1.AddItem "https://www.wxxi.org/sites/default/files/wrur-aac-triton.m3u"
	ComboBoxEdit1.AddItem "https://www.wxxi.org/sites/default/files/wrur-mp3-triton.m3u"
End Sub

Private Sub frmRadioType.CommandButton1_Click(ByRef Sender As Control)
	OpenURL(urls(CInt(Sender.Text) - 1))
End Sub

Private Sub frmRadioType.CommandButton6_Click(ByRef Sender As Control)
	OpenURL(urls(CInt(Sender.Text) + 4))
End Sub

Private Sub frmRadioType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	BASS_Free()
	BASS_PluginFree(0)
End Sub

Private Sub frmRadioType.TimerComponent1_Timer(ByRef Sender As TimerComponent)
	' monitor buffering progress
	Dim As DWORD active = BASS_ChannelIsActive(chan)
	If (active = BASS_ACTIVE_STALLED) Then
		Label4.Text = "buffering..." & 100 - BASS_StreamGetFilePosition(chan, BASS_FILEPOS_BUFFERING) & "%"
	Else
		TimerComponent1.Enabled = False ' finished buffering, Stop monitoring
		If (active) Then
			If Label4.Text <> "playing" Then Label4.Text = "playing"
			' Get the stream Name And URL
			Dim As ZString Ptr icy = Cast(ZString Ptr, BASS_ChannelGetTags(chan, BASS_TAG_ICY))
			If (icy = 0) Then icy = Cast(ZString Ptr, BASS_ChannelGetTags(chan, BASS_TAG_HTTP)) ' no ICY tags, try HTTP
			If (icy) Then
				If InStr(Label5.Text, *icy) = 0 Then Label5.Text = *icy
			End If
			DoMeta()
		End If
	End If
End Sub

Private Sub frmRadioType.CommandButton11_Click(ByRef Sender As Control)
	OpenURL(ComboBoxEdit1.Text)
End Sub

Private Sub frmRadioType.CheckBox1_Click(ByRef Sender As CheckBox)
	If CheckBox1.Checked Then
		BASS_SetConfigPtr(BASS_CONFIG_NET_PROXY, NULL) ' disable proxy
		TextBox1.Enabled = False
		Label5.Text = CheckBox1.Text
	Else
		Dim As WString Ptr proxy = Cast(WString Ptr, @TextBox1.Text)
		BASS_SetConfigPtr(BASS_CONFIG_NET_PROXY, proxy) ' set proxy server
		TextBox1.Enabled = True
		Label5.Text = "Proxy: " & *proxy
	End If
End Sub

Private Sub frmRadioType.TextBox1_Change(ByRef Sender As TextBox)
	CheckBox1_Click(CheckBox1)
End Sub
