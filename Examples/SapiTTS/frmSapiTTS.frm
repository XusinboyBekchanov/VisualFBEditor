'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "frmSapiTTS.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/TrackBar.bi"
	#include once "mff/VScrollBar.bi"
	#include once "mff/ComboBoxEx.bi"
	#include once "mff/Dialogs.bi"
	#include once "mff/TimerComponent.bi"
	#include once "mff/GroupBox.bi"
	
	#include once "Speech.bi"
	
	Using My.Sys.Forms
	Using Speech
	
	Const MSG_SAPI_EVENT = WM_USER + 1024   ' --> change me
	
	Type frmSapiTTSType Extends Form
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Sub Form_Message(ByRef Sender As Control, ByRef MSG As Message)
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Sub ComboBoxEdit1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub TrackBar1_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Sub TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Constructor
		
		pSpVoice As Afx_ISpVoice Ptr
		
		Dim As TextBox TextBox1, TextBox2
		Dim As GroupBox GroupBox1, GroupBox2
		Dim As ComboBoxEdit ComboBoxEdit1, ComboBoxEdit2, ComboBoxEdit3
		Dim As CommandButton CommandButton1, CommandButton2, CommandButton3, CommandButton4
		Dim As TrackBar TrackBar1, TrackBar2
		Dim As SaveFileDialog SaveFileDialog1
		Dim As TimerComponent TimerComponent1
	End Type
	
	Constructor frmSapiTTSType
		' frmSapiTTS
		With This
			.Name = "frmSapiTTS"
			.Text = "SAPI Text-to-Speech"
			.Caption = "SAPI Text-to-Speech"
			.StartPosition = FormStartPosition.CenterScreen
			.Designer = @This
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnMessage = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Msg As Message), @Form_Message)
			.OnDestroy = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Destroy)
			.BorderStyle = FormBorderStyle.FixedDialog
			.SetBounds 0, 0, 346, 380
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = "" & _
			"The SAPI application programming interface (API) dramatically reduces " & _
			"the code overhead required for an application to use speech recognition " & _
			"and text-to-speech, making speech technology more accessible and robust " & _
			"for a wide range of applications."
			.TabIndex = 0
			.Multiline = True
			.ScrollBars = ScrollBarsType.Vertical
			.WordWraps = True
			.HideSelection = False
			.SetBounds 10, 10, 320, 81
			.Designer = @This
			.Parent = @This
		End With
		' GroupBox1
		With GroupBox1
			.Name = "GroupBox1"
			.Text = "Speach to Audio"
			.TabIndex = 2
			.Caption = "Speach to Audio"
			.SetBounds 10, 130, 320, 100
			.Designer = @This
			.Parent = @This
		End With
		' ComboBoxEdit1
		With ComboBoxEdit1
			.Name = "ComboBoxEdit1"
			.Text = "ComboBoxEdit1"
			.TabIndex = 3
			.Style = ComboBoxEditStyle.cbDropDown
			.Hint = "Voice"
			.ControlIndex = 2
			.SetBounds 10, 100, 320, 21
			.Designer = @This
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @ComboBoxEdit1_Selected)
			.Parent = @This
		End With
		' GroupBox2
		With GroupBox2
			.Name = "GroupBox2"
			.Text = "Speach to File"
			.TabIndex = 4
			.Caption = "Speach to File"
			.SetBounds 10, 240, 320, 100
			.Designer = @This
			.Parent = @This
		End With
		' ComboBoxEdit2
		With ComboBoxEdit2
			.Name = "ComboBoxEdit2"
			.Text = "ComboBoxEdit2"
			.TabIndex = 5
			.Style = ComboBoxEditStyle.cbDropDown
			.Hint = "Output"
			.SetBounds 10, 20, 300, 21
			.Designer = @This
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @ComboBoxEdit1_Selected)
			.Parent = @GroupBox1
		End With
		' TrackBar1
		With TrackBar1
			.Name = "TrackBar1"
			.Text = "TrackBar1"
			.TabIndex = 6
			.MinValue = -10
			.Hint = "Rate"
			.SetBounds 10, 55, 200, 10
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TrackBar, Position As Integer), @TrackBar1_Change)
			.Parent = @GroupBox1
		End With
		' TrackBar2
		With TrackBar2
			.Name = "TrackBar2"
			.Text = "TrackBar2"
			.TabIndex = 7
			.MaxValue = 100
			.Hint = "Volume"
			.SetBounds 10, 75, 200, 10
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TrackBar, Position As Integer), @TrackBar1_Change)
			.Parent = @GroupBox1
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "Speach"
			.TabIndex = 8
			.Caption = "Speach"
			.Align = DockStyle.alNone
			.Anchor.Right = AnchorStyle.asNone
			.SetBounds 220, 50, 90, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton1_Click)
			.Parent = @GroupBox1
		End With
		' CommandButton2
		With CommandButton2
			.Name = "CommandButton2"
			.Text = "Stop"
			.TabIndex = 9
			.Caption = "Stop"
			.Align = DockStyle.alNone
			.Anchor.Right = AnchorStyle.asNone
			.Enabled = False
			.SetBounds 220, 70, 90, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton1_Click)
			.Parent = @GroupBox1
		End With
		' TextBox2
		With TextBox2
			.Name = "TextBox2"
			.Text = "TextBox2"
			.TabIndex = 10
			.SetBounds 10, 20, 300, 20
			.Designer = @This
			.Parent = @GroupBox2
		End With
		' ComboBoxEdit3
		With ComboBoxEdit3
			.Name = "ComboBoxEdit3"
			.Text = "ComboBoxEdit3"
			.TabIndex = 11
			.Hint = "Audio Format"
			.SetBounds 10, 55, 200, 21
			.Designer = @This
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @ComboBoxEdit1_Selected)
			.AddItem "8kHz 8Bit Mono"
			.AddItem "8kHz 8Bit Stereo"
			.AddItem "8kHz 16Bit Mono"
			.AddItem "8kHz 16Bit Stereo"
			.AddItem "11kHz 8Bit Mono"
			.AddItem "11kHz 8Bit Stereo"
			.AddItem "11kHz 16Bit Mono"
			.AddItem "11kHz 16Bit Stereo"
			.AddItem "12kHz 8Bit Mono"
			.AddItem "12kHz 8Bit Stereo"
			.AddItem "12kHz 16Bit Mono"
			.AddItem "12kHz 16Bit Stereo"
			.AddItem "16kHz 8Bit Mono"
			.AddItem "16kHz 8Bit Stereo"
			.AddItem "16kHz 16Bit Mono"
			.AddItem "16kHz 16Bit Stereo"
			.AddItem "22kHz 8Bit Mono"
			.AddItem "22kHz 8Bit Stereo"
			.AddItem "22kHz 16Bit Mono"
			.AddItem "22kHz 16Bit Stereo"
			.AddItem "24kHz 8Bit Mono"
			.AddItem "24kHz 8Bit Stereo"
			.AddItem "24kHz 16Bit Mono"
			.AddItem "24kHz 16Bit Stereo"
			.AddItem "32kHz 8Bit Mono"
			.AddItem "32kHz 8Bit Stereo"
			.AddItem "32kHz 16Bit Mono"
			.AddItem "32kHz 16Bit Stereo"
			.AddItem "44kHz 8Bit Mono"
			.AddItem "44kHz 8Bit Stereo"
			.AddItem "44kHz 16Bit Mono"
			.AddItem "44kHz 16Bit Stereo"
			.AddItem "48kHz 8Bit Mono"
			.AddItem "48kHz 8Bit Stereo"
			.AddItem "48kHz 16Bit Mono"
			.AddItem "48kHz 16Bit Stereo"
			.ItemIndex = SAFT44kHz16BitStereo - SAFT8kHz8BitMono
			.Parent = @GroupBox2
		End With
		' CommandButton3
		With CommandButton3
			.Name = "CommandButton3"
			.Text = "Select"
			.TabIndex = 12
			.Caption = "Select"
			.SetBounds 220, 49, 90, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton1_Click)
			.Parent = @GroupBox2
		End With
		' CommandButton4
		With CommandButton4
			.Name = "CommandButton4"
			.Text = "Speach to file"
			.TabIndex = 13
			.Caption = "Speach to file"
			.SetBounds 220, 69, 90, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton1_Click)
			.Parent = @GroupBox2
		End With
		' SaveFileDialog1
		With SaveFileDialog1
			.Name = "SaveFileDialog1"
			.Filter = "Wave file|*.wav"
			.SetBounds 10, -1, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' TimerComponent1
		With TimerComponent1
			.Name = "TimerComponent1"
			.Interval = 100
			.SetBounds 40, -1, 16, 16
			.Designer = @This
			.OnTimer = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent), @TimerComponent1_Timer)
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frmSapiTTS As frmSapiTTSType

	#if _MAIN_FILE_ = __FILE__
		'App.DarkMode= True
		frmSapiTTS.MainForm = True
		frmSapiTTS.Show
		App.Run
	#endif
'#End Region

Private Sub frmSapiTTSType.Form_Create(ByRef Sender As Control)
	CoInitialize(NULL)
	' // Create an instance of the SpVoice object
	
	Dim classID As IID, riid As IID
	CLSIDFromString(Afx_CLSID_SpVoice, @classID)
	IIDFromString(Afx_IID_ISpVoice, @riid)
	CoCreateInstance(@classID, NULL, CLSCTX_ALL, @riid, @pSpVoice)
	
	If pSpVoice Then
		' // Set the object of interest to word boundaries
		pSpVoice->SetInterest(SPFEI(SPEI_WORD_BOUNDARY), SPFEI(SPEI_WORD_BOUNDARY))
		' // Set the handle of the window that will receive the MSG_SAPI_EVENT message
		pSpVoice->SetNotifyWindowMessage(Handle, MSG_SAPI_EVENT, 0, 0)
		
		Dim pVoice As Afx_ISpObjectToken Ptr
		Dim pToken As Afx_ISpObjectTokenCategory Ptr
		Dim mToken As Afx_IEnumSpObjectTokens Ptr
		Dim cToken As Afx_ISpObjectToken Ptr
		Dim pCount As Long
		Dim i As Long
		Dim mWStr As WString Ptr = CAllocate(1024)
		
		pSpVoice->GetVoice(@pVoice)
		pVoice->GetCategory(@pToken)
		pToken->EnumTokens(@"", @"", @mToken)
		mToken->GetCount(@pCount)
		
		ComboBoxEdit1.Clear
		For i = 0 To pCount - 1
			mToken->Item(i, @cToken)
			cToken->GetStringValue(NULL, @mWStr)
			ComboBoxEdit1.AddItem *mWStr
			ComboBoxEdit1.ItemData(i) = cToken
		Next
		ComboBoxEdit1.ItemIndex = 0
		
		mToken->Release()
		pVoice->Release()
		pToken->Release()
		
		pSpVoice->GetOutputObjectToken(@pVoice)
		pVoice->GetCategory(@pToken)
		pToken->EnumTokens(@"", @"", @mToken)
		mToken->GetCount(@pCount)
		
		ComboBoxEdit2.Clear
		For i = 0 To pCount - 1
			mToken->Item(i, @cToken)
			cToken->GetStringValue(NULL, @mWStr)
			ComboBoxEdit2.AddItem *mWStr
			ComboBoxEdit2.ItemData(i) = cToken
		Next
		ComboBoxEdit2.ItemIndex = 0
		
		mToken->Release()
		pVoice->Release()
		pToken->Release()
		
		Dim lg As Long
		Dim us As UShort
		pSpVoice->GetRate(@lg)
		TrackBar1.Position = lg
		pSpVoice->GetVolume(@us)
		TrackBar2.Position = us
	End If
	
	TextBox2.Text = CurDir & "\SapiTTS.wav"
End Sub

Private Sub frmSapiTTSType.CommandButton1_Click(ByRef Sender As Control)
	Select Case LCase(Sender.Text)
	Case "speach"
		If pSpVoice Then pSpVoice->Speak(@TextBox1.Text , SVSFlagsAsync, NULL)
		CommandButton1.Text = "Pause"
		CommandButton2.Enabled = True
		CommandButton4.Enabled = False
		TimerComponent1.Enabled = True
	Case "pause"
		If pSpVoice Then pSpVoice->Pause()
		Sender.Text = "Resume"
	Case "resume"
		If pSpVoice Then pSpVoice->Resume()
		Sender.Text = "Pause"
	Case "stop"
		If pSpVoice Then pSpVoice->Resume()
		If pSpVoice Then pSpVoice->Speak(@" ", SVSFPurgeBeforeSpeak, NULL)
		CommandButton1.Text = "Speach"
		TimerComponent1.Enabled = False
		CommandButton2.Enabled = False
		CommandButton4.Enabled = True
	Case "select"
		SaveFileDialog1.FileName= TextBox2.Text
		If SaveFileDialog1.Execute() Then
			TextBox2.Text = SaveFileDialog1.FileName
		End If
	Case "speach to file"
		
		If PathFileExists(@TextBox2.Text) Then
			If MsgBox( !"Overwrite exist file?\r\n" & TextBox2.Text, "File overwrite confirmation.", mtWarning, btYesNo) <> MessageResult.mrYes Then Exit Sub
		End If
		
		ComboBoxEdit1.Enabled = False
		ComboBoxEdit2.Enabled = False
		TextBox2.Enabled = False
		CommandButton1.Enabled = False
		CommandButton3.Enabled = False
		CommandButton4.Enabled = False
		
		App.DoEvents()
		
		Dim classID As IID, riid As IID
		Dim pSpFileStream As Afx_ISpeechFileStream Ptr
		Dim pSpAudioFormat As Afx_ISpeechAudioFormat Ptr
		
		'创建音频输出文件流设备
		CLSIDFromString(AFX_CLSID_SpFileStream, @classID)
		IIDFromString(AFX_IID_ISpeechFileStream, @riid)
		CoCreateInstance(@classID, NULL, CLSCTX_INPROC_SERVER, @riid, @pSpFileStream)
		
		'设置音频格式
		If ComboBoxEdit3.ItemIndex >-1 Then
			Dim aft As SpeechAudioFormatType
			pSpFileStream->get_Format(@pSpAudioFormat)
			pSpAudioFormat->get_Type(@aft)
			aft = ComboBoxEdit3.ItemIndex + SAFT8kHz8BitMono
			pSpAudioFormat->put_Type(aft)
			pSpFileStream->putref_Format(pSpAudioFormat)
		End If
		
		'打开文件流
		pSpFileStream->Open(@TextBox2.Text, SSFMCreateForWrite, False)
		
		'语音指向文件流设备
		pSpVoice->SetOutput(pSpFileStream, True)
		
		'文字转语音
		pSpVoice->Speak(@TextBox1.Text , SVSFNLPSpeakPunc, NULL)
		
		'关闭音频流
		pSpFileStream->Close()
		pSpVoice->SetOutput(ComboBoxEdit2.ItemData(ComboBoxEdit2.ItemIndex), True)
		
		'释放资源
		pSpAudioFormat->Release()
		pSpFileStream->Release()
		
		ComboBoxEdit1.Enabled = True
		ComboBoxEdit2.Enabled = True
		TextBox2.Enabled = True
		CommandButton1.Enabled = True
		CommandButton3.Enabled = True
		CommandButton4.Enabled = True
	End Select
End Sub

Private Sub frmSapiTTSType.Form_Message(ByRef Sender As Control, ByRef MSG As Message)
	Select Case MSG.Msg
	Case MSG_SAPI_EVENT
		Dim eventItem As SPEVENT, eventStatus As SPVOICESTATUS
		Do
			If pSpVoice->GetEvents(1, @eventItem, NULL) <> S_OK Then Exit Do
			If eventItem.eEventId = SPEI_WORD_BOUNDARY Then
				'显示播报进度
				pSpVoice->GetStatus(@eventStatus, NULL)
				TextBox1.SelStart = eventStatus.ulInputWordPos
				TextBox1.SelLength = eventStatus.ulInputWordLen
			End If
		Loop
	End Select
End Sub

Private Sub frmSapiTTSType.Form_Destroy(ByRef Sender As Control)
	'释放资源
	pSpVoice->Release()
	CoUninitialize()
End Sub

Private Sub frmSapiTTSType.ComboBoxEdit1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	Select Case Sender.Name
	Case "ComboBoxEdit1"
		pSpVoice->SetVoice(Sender.ItemData(ItemIndex))
	Case "ComboBoxEdit2"
		pSpVoice->SetOutput(Sender.ItemData(ItemIndex), True)
	End Select
End Sub

Private Sub frmSapiTTSType.TrackBar1_Change(ByRef Sender As TrackBar, Position As Integer)
	Select Case Sender.Name
	Case "TrackBar1"
		If pSpVoice Then pSpVoice->SetRate(Position)
	Case "TrackBar2"
		If pSpVoice Then pSpVoice->SetVolume(Position)
	End Select
End Sub

Private Sub frmSapiTTSType.TimerComponent1_Timer(ByRef Sender As TimerComponent)
	If pSpVoice= NULL Then Exit Sub
	Dim eventStatus As SPVOICESTATUS
	pSpVoice->GetStatus(@eventStatus, NULL)
	If eventStatus.dwRunningState= 1 Then
		'语音播报完成
		CommandButton1_Click(CommandButton2)
	End If
End Sub
