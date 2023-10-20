'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "frmsoundfx.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/Dialogs.bi"
	#include once "mff/TrackBar.bi"
	#include once "mff/Label.bi"
	
	#include once "dsbase.bi"
	
	Using My.Sys.Forms
	
	Type Form1Type Extends Form
		Declare Sub CommandButton_Click(ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Sub TrackBar_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Constructor
		
		Dim As TextBox TextBox1
		Dim As CommandButton CommandButton1, CommandButton2
		Dim As CheckBox CheckBox1
		Dim As OpenFileDialog OpenFileDialog1
		Dim As TrackBar TrackBar1, TrackBar2
		Dim As Label Label1, Label2
	End Type
	
	Constructor Form1Type
		' Form1
		With This
			.Name = "Form1"
			.Text = "DirectX Sample Audio Player"
			.Designer = @This
			.StartPosition = FormStartPosition.CenterScreen
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnDestroy = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Destroy)
			.Caption = "DirectX Sample Audio Player"
			.SetBounds 0, 0, 350, 180
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = "F:\OfficePC_Update\!Media\mid\salamanders lifeforce.mid"
			.TabIndex = 0
			.SetBounds 120, 10, 200, 20
			.Designer = @This
			.Parent = @This
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "Play"
			.TabIndex = 1
			.Caption = "Play"
			.SetBounds 220, 50, 100, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @This
		End With
		' CheckBox1
		With CheckBox1
			.Name = "CheckBox1"
			.Text = "Loop file"
			.TabIndex = 2
			.Caption = "Loop file"
			.SetBounds 10, 50, 140, 20
			.Designer = @This
			.Parent = @This
		End With
		' CommandButton2
		With CommandButton2
			.Name = "CommandButton2"
			.Text = "Open"
			.TabIndex = 3
			.Caption = "Open"
			.SetBounds 10, 10, 100, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @This
		End With
		' OpenFileDialog1
		With OpenFileDialog1
			.Name = "OpenFileDialog1"
			.Filter = "*.*"
			.FileTitle = "All file"
			.SetBounds 10, 70, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' TrackBar1
		With TrackBar1
			.Name = "TrackBar1"
			.Text = "TrackBar1"
			.TabIndex = 4
			.MinValue = -10
			.TickStyle = TickStyles.tsNone
			.ID = 1044
			.TickMark = TickMarks.tmBottomRight
			.ThumbLength = 15
			.Frequency = 0
			.PageSize = 2
			.SetBounds 10, 100, 150, 20
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TrackBar, Position As Integer), @TrackBar_Change)
			.Parent = @This
		End With
		' TrackBar2
		With TrackBar2
			.Name = "TrackBar2"
			.Text = "TrackBar2"
			.TabIndex = 5
			.MaxValue = 0
			.MinValue = -10000
			.TickStyle = TickStyles.tsNone
			.ID = 1041
			.ThumbLength = 15
			.SetBounds 170, 100, 150, 20
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TrackBar, Position As Integer), @TrackBar_Change)
			.Parent = @This
		End With
		' Label1
		With Label1
			.Name = "Label1"
			.Text = "Tempo"
			.TabIndex = 6
			.Alignment = AlignmentConstants.taCenter
			.Caption = "Tempo"
			.SetBounds 10, 80, 150, 20
			.Designer = @This
			.Parent = @This
		End With
		' Label2
		With Label2
			.Name = "Label2"
			.Text = "Volume"
			.TabIndex = 7
			.Alignment = AlignmentConstants.taCenter
			.Caption = "Volume"
			.SetBounds 170, 80, 150, 20
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared Form1 As Form1Type
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		Form1.MainForm = True
		Form1.Show
		App.Run
	#endif
'#End Region

'Todo: SoundFX in dssound.bi not being imported on freebasic

Dim Shared As IDirectMusicSegment8 Ptr m_pSegment = NULL
Dim Shared As IDirectMusicLoader8 Ptr m_pLoader = NULL
Dim Shared As IDirectMusicPerformance8 Ptr m_pPerformance = NULL
Dim Shared As IDirectMusicAudioPath8 Ptr m_pEmbeddedAudioPath = NULL

Dim Shared As DWORD dwDefaultPathType = DMUS_APATH_DYNAMIC_STEREO
Dim Shared As DWORD dwPChannels = 128
Dim Shared As DWORD dwFlags = DMUS_SEGF_BEAT
Dim Shared As HANDLE g_hDMusicMessageEvent = NULL

Dim Shared As IDirectMusicPerformance Ptr pPerf = NULL

Private Function MusicPlay(hForm As HANDLE, filename As WString Ptr, ByVal fileloop As Boolean = False) As HRESULT
	Dim hr As HRESULT
	
	'Create loader object
	hr = CoCreateInstance(@CLSID_DirectMusicLoader, NULL, CLSCTX_ALL, @IID_IDirectMusicLoader8, @m_pLoader)
	DXTRACE_MSG("1", hr)
	
	'Create performance object
	hr = CoCreateInstance(@CLSID_DirectMusicPerformance, NULL, CLSCTX_ALL, @IID_IDirectMusicPerformance8, @m_pPerformance)
	DXTRACE_MSG("2", hr)
	
	If m_pPerformance = NULL Then Return hr
	
	'Register segment notification
	g_hDMusicMessageEvent = CreateEvent(NULL, False, False, NULL)
	pPerf = Cast(IDirectMusicPerformance Ptr, m_pPerformance)
	hr = pPerf->lpVtbl->AddNotificationType(pPerf, @GUID_NOTIFICATION_SEGMENT)
	DXTRACE_MSG("2.1", hr)
	hr = pPerf->lpVtbl->SetNotificationHandle(pPerf, g_hDMusicMessageEvent, 0)
	DXTRACE_MSG("2.2", hr)
	
	'Initialize the performance With the standard audio path.
	'This initializes Both DirectMusic And DirectSound And
	'sets up the synthesizer. Typcially its easist To use an
	'audio path For playing music And sound effects.
	hr = m_pPerformance->lpVtbl->InitAudio(m_pPerformance, NULL, NULL, hForm, dwDefaultPathType, dwPChannels, DMUS_AUDIOF_ALL, NULL)
	DXTRACE_MSG("3", hr)
	
	'Tells the loader to cleanup any garbage from previously
	m_pLoader->lpVtbl->CollectGarbage(m_pLoader)
	DXTRACE_MSG("4", hr)

	'Load a default music segment
	hr = m_pLoader->lpVtbl->LoadObjectFromFile(m_pLoader, @CLSID_DirectMusicSegment, @IID_IDirectMusicSegment8, filename, @m_pSegment)
	DXTRACE_MSG("5", hr)
	
	'Set the segment to repeat many times
	hr = m_pSegment->lpVtbl->SetRepeats(m_pSegment, IIf(fileloop, DMUS_SEG_REPEAT_INFINITE, 0))
	DXTRACE_MSG("6", hr)
	
	Dim As IUnknown Ptr pConfig = NULL
	hr = m_pSegment->lpVtbl->GetAudioPathConfig(m_pSegment, @pConfig)
	DXTRACE_MSG("7", hr)
	hr = m_pPerformance->lpVtbl->CreateAudioPath(m_pPerformance, pConfig, True, @m_pEmbeddedAudioPath)
	DXTRACE_MSG("8", hr)
	SAFE_RELEASE(pConfig)
	
	'For DirectMusic must know if the file is a standard MIDI file or not in order to load the correct instruments.
	If InStr(1, *filename, ".mid") Then
		hr = m_pSegment->lpVtbl->SetParam(m_pSegment, @GUID_StandardMIDIFile, &hFFFFFFFF, 0, 0, NULL)
		DXTRACE_MSG("8.1", hr)
	End If

    'If we are loading a wav, Then disable the tempo slider since tempo adjustments will not take effect when playing wav files.
	If InStr(1, *filename, ".wav") Then
	Else
	End If
	
	'If No audio path was passed in, Then download to the embedded audio path If it exists else download To the performance
	If (m_pEmbeddedAudioPath) Then
		hr = m_pSegment->lpVtbl->Download(m_pSegment, Cast(IUnknown Ptr, m_pEmbeddedAudioPath))
		DXTRACE_MSG("8.2", hr)
	Else
		hr = m_pSegment->lpVtbl->Download(m_pSegment, Cast(IUnknown Ptr, m_pPerformance))
		DXTRACE_MSG("8.3", hr)
	End If
	
	'plays on the default audio path
	hr = m_pPerformance->lpVtbl->PlaySegmentEx(m_pPerformance, Cast(IUnknown Ptr, m_pSegment), 0, NULL, dwFlags, 0, 0, NULL, Cast(IUnknown Ptr, m_pEmbeddedAudioPath))
	DXTRACE_MSG("9", hr)
	
	Return hr
End Function

Private Function MusicStop() As HRESULT
	Dim hr As HRESULT
	
	'~CMusicManager()
	If (m_pPerformance) Then
		hr = m_pPerformance->lpVtbl->Stop(m_pPerformance, NULL, NULL, 0, 0)
		DXTRACE_MSG("10", hr)
		hr = m_pPerformance->lpVtbl->CloseDown(m_pPerformance)
		DXTRACE_MSG("11", hr)
	End If
	SAFE_RELEASE(m_pPerformance)
	
	'~CMusicSegment()
	'Tell the loader that this object should now be released
	If m_pSegment Then
		If (m_pLoader) Then m_pLoader->lpVtbl->ReleaseObjectByUnknown(m_pLoader, Cast(IUnknown Ptr, m_pSegment))
		If m_pEmbeddedAudioPath Then
			hr = m_pSegment->lpVtbl->Unload(m_pSegment, Cast(IUnknown Ptr, m_pEmbeddedAudioPath))
			DXTRACE_MSG("12", hr)
		Else
			hr = m_pSegment->lpVtbl->Unload(m_pSegment, Cast(IUnknown Ptr, m_pPerformance))
			DXTRACE_MSG("13", hr)
		End If
	End If
	SAFE_RELEASE(m_pEmbeddedAudioPath)
	SAFE_RELEASE(m_pSegment)
	SAFE_RELEASE(m_pPerformance)
	SAFE_RELEASE(m_pLoader)
	
	If g_hDMusicMessageEvent Then
		CloseHandle(g_hDMusicMessageEvent)
		g_hDMusicMessageEvent = NULL
	End If
	
	Return hr
End Function

Private Sub Form1Type.CommandButton_Click(ByRef Sender As Control)
	
	Select Case Sender.Text
	Case "Open"
		OpenFileDialog1.FileName = TextBox1.Text
		If OpenFileDialog1.Execute() Then
			TextBox1.Text = OpenFileDialog1.FileName
		End If
	Case "Play"
		Debug.Clear
		MusicPlay(Handle, @TextBox1.Text, CheckBox1.Checked)
		
		Sender.Text = "Stop"
	Case "Stop"
		MusicStop()
		Sender.Text = "Play"
	End Select
End Sub

Private Sub Form1Type.Form_Create(ByRef Sender As Control)
	'Initialize COM
	CoInitialize(NULL)
End Sub

Private Sub Form1Type.Form_Destroy(ByRef Sender As Control)
	'Uninitialize COM
	MusicStop()
	CoUninitialize()
End Sub

Private Sub Form1Type.TrackBar_Change(ByRef Sender As TrackBar, Position As Integer)
	Dim As IDirectMusicPerformance Ptr pPerf = NULL
	pPerf = Cast(IDirectMusicPerformance Ptr, m_pPerformance)
	
	If pPerf = NULL Then Exit Sub
	Select Case Sender.Name
	Case "TrackBar1"
		Dim fTempo As FLOAT = Position
		pPerf->lpVtbl->SetGlobalParam(pPerf, @GUID_PerfMasterTempo, @fTempo, SizeOf(FLOAT))
		Label1.Caption = "Tempo: " & Position
	Case "TrackBar2"
		Dim nVolume As Long = Position
		pPerf->lpVtbl->SetGlobalParam(pPerf, @GUID_PerfMasterVolume, @nVolume, SizeOf(Long))
		Label2.Caption = "Volume: " & Position
	End Select
End Sub
