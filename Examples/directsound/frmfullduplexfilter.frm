'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "frmfullduplexfilter.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/GroupBox.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/TrackBar.bi"
	
	#include once "fullduplexfilter.bi"
	
	Using My.Sys.Forms
	
	Type Form1Type Extends Form
		bStarting As BOOL
		
		Declare Static Function ThreadDuplexFilter(ByVal pParam As LPVOID) As DWORD
		Declare Sub DuplexFilter()
		Declare Sub CtlEnabled(b As Boolean)
		
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Sub TrackBar1_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Constructor
		
		Dim As GroupBox GroupBox1, GroupBox2, GroupBox3
		Dim As ComboBoxEdit ComboBoxEdit1, ComboBoxEdit2, ComboBoxEdit3, ComboBoxEdit4, ComboBoxEdit5, ComboBoxEdit6, ComboBoxEdit7, ComboBoxEdit8
		Dim As CommandButton CommandButton1
		Dim As TrackBar TrackBar1, TrackBar2
	End Type
	
	Constructor Form1Type
		' Form1
		With This
			.Name = "Form1"
			.Text = "FullDuplexFilter"
			.Designer = @This
			.Caption = "FullDuplexFilter"
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnDestroy = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Destroy)
			.BorderStyle = FormBorderStyle.FixedDialog
			.MaximizeBox = False
			.StartPosition = FormStartPosition.CenterScreen
			.SetBounds 0, 0, 366, 360
		End With
		' GroupBox1
		With GroupBox1
			.Name = "GroupBox1"
			.Text = "Device"
			.TabIndex = 0
			.SetBounds 10, 10, 340, 100
			.Designer = @This
			.Parent = @This
		End With
		' ComboBoxEdit1
		With ComboBoxEdit1
			.Name = "ComboBoxEdit1"
			.Text = "ComboBoxEdit1"
			.TabIndex = 1
			.Style = ComboBoxEditStyle.cbDropDown
			.Hint = "Intput device"
			.SetBounds 10, 30, 320, 21
			.Designer = @This
			.Parent = @GroupBox1
		End With
		' ComboBoxEdit2
		With ComboBoxEdit2
			.Name = "ComboBoxEdit2"
			.Text = "ComboBoxEdit2"
			.TabIndex = 2
			.Style = ComboBoxEditStyle.cbDropDown
			.Hint = "Output device"
			.SetBounds 10, 60, 320, 21
			.Designer = @This
			.Parent = @GroupBox1
		End With
		' GroupBox2
		With GroupBox2
			.Name = "GroupBox2"
			.Text = "Input"
			.TabIndex = 3
			.SetBounds 10, 120, 160, 160
			.Designer = @This
			.Parent = @This
		End With
		' GroupBox3
		With GroupBox3
			.Name = "GroupBox3"
			.Text = "Output"
			.TabIndex = 4
			.SetBounds 190, 120, 160, 160
			.Designer = @This
			.Parent = @This
		End With
		' ComboBoxEdit3
		With ComboBoxEdit3
			.Name = "ComboBoxEdit3"
			.Text = "ComboBoxEdit3"
			.TabIndex = 5
			.SetBounds 10, 30, 140, 21
			.Designer = @This
			.Parent = @GroupBox2
		End With
		' ComboBoxEdit4
		With ComboBoxEdit4
			.Name = "ComboBoxEdit4"
			.Text = "ComboBoxEdit4"
			.TabIndex = 6
			.SetBounds 10, 60, 140, 21
			.Designer = @This
			.Parent = @GroupBox2
		End With
		' ComboBoxEdit5
		With ComboBoxEdit5
			.Name = "ComboBoxEdit5"
			.Text = "ComboBoxEdit5"
			.TabIndex = 7
			.SetBounds 10, 90, 140, 21
			.Designer = @This
			.Parent = @GroupBox2
		End With
		' ComboBoxEdit6
		With ComboBoxEdit6
			.Name = "ComboBoxEdit6"
			.Text = "ComboBoxEdit6"
			.TabIndex = 8
			.SetBounds 10, 30, 140, 21
			.Designer = @This
			.Parent = @GroupBox3
		End With
		' ComboBoxEdit7
		With ComboBoxEdit7
			.Name = "ComboBoxEdit7"
			.Text = "ComboBoxEdit7"
			.TabIndex = 9
			.SetBounds 10, 60, 140, 21
			.Designer = @This
			.Parent = @GroupBox3
		End With
		' ComboBoxEdit8
		With ComboBoxEdit8
			.Name = "ComboBoxEdit8"
			.Text = "ComboBoxEdit8"
			.TabIndex = 10
			.SetBounds 10, 90, 140, 21
			.Designer = @This
			.Parent = @GroupBox3
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "Start"
			.TabIndex = 11
			.SetBounds 200, 300, 140, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton1_Click)
			.Parent = @This
		End With
		' TrackBar1
		With TrackBar1
			.Name = "TrackBar1"
			.Text = "TrackBar1"
			.TabIndex = 12
			.TickMark = TickMarks.tmBoth
			.ID = 1617
			.TickStyle = TickStyles.tsNone
			.Enabled = False
			.MaxValue = 0
			.MinValue = -10000
			.SetBounds 10, 130, 140, 10
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TrackBar, Position As Integer), @TrackBar1_Change)
			.Parent = @GroupBox2
		End With
		' TrackBar2
		With TrackBar2
			.Name = "TrackBar2"
			.Text = "TrackBar2"
			.TabIndex = 13
			.TickMark = TickMarks.tmBoth
			.ID = 1616
			.TickStyle = TickStyles.tsNone
			.Enabled = False
			.MinValue = -10000
			.MaxValue = 0
			.SetBounds 10, 130, 140, 10
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TrackBar, Position As Integer), @TrackBar1_Change)
			.Parent = @GroupBox3
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

Private Function Form1Type.ThreadDuplexFilter(ByVal pParam As LPVOID) As DWORD
	Cast(Form1Type Ptr, pParam)->DuplexFilter()
	Return 0
End Function

Private Sub Form1Type.DuplexFilter()
	Dim hr As HRESULT
	
	Debug.Print "g_hNotificationEvent: " & g_hNotificationEvent
	
	'Init DirectSound
	hr = InitDirectSound(Handle, ComboBoxEdit1.ItemData(ComboBoxEdit1.ItemIndex), ComboBoxEdit2.ItemData(ComboBoxEdit2.ItemIndex))
	DXTRACE_MSG("InitDirectSound()", hr)
	
	'Set Buffer Formats
	WaveFormatSet(CInt(ComboBoxEdit3.Item(ComboBoxEdit3.ItemIndex)), CInt(ComboBoxEdit4.Item(ComboBoxEdit4.ItemIndex)), CInt(ComboBoxEdit5.Item(ComboBoxEdit5.ItemIndex)), @g_WaveFormatInput)
	WaveFormatSet(CInt(ComboBoxEdit6.Item(ComboBoxEdit6.ItemIndex)), CInt(ComboBoxEdit7.Item(ComboBoxEdit7.ItemIndex)), CInt(ComboBoxEdit8.Item(ComboBoxEdit8.ItemIndex)), @g_WaveFormatOutput)

	hr = SetBufferFormats(@g_WaveFormatInput, @g_WaveFormatOutput)
	DXTRACE_MSG("SetBufferFormats()", hr)
	
	hr = CreateOutputBuffer()
	DXTRACE_MSG("CreateOutputBuffer()", hr)
	
	hr = StartBuffers()
	DXTRACE_MSG("StartBuffers()", hr)

	CtlEnabled False
	
	bStarting = True
	DXTRACE_MSG("While(bStarting)=true", 0)
	While(bStarting)
		hr = MsgWaitForMultipleObjects(1, @g_hNotificationEvent, False, INFINITE, QS_ALLEVENTS)
		Select Case hr
		Case WAIT_OBJECT_0
			'g_hNotificationEvent is signaled
			
			'This means that DirectSound just finished playing
			'a piece of the buffer, so we need to fill the circular
			'buffer with new sound from the wav file
			
			hr = HandleNotification()
			DXTRACE_MSG("==HandleNotification==", hr)
			If (hr) Then bStarting = False
		Case WAIT_OBJECT_0 + 1
			DXTRACE_MSG("Windows messages are available", 0)
		End Select
	Wend
	DXTRACE_MSG("While(bStarting)=false", 0)
	
	If g_pDSBCapture<> NULL And g_pDSBOutput <> NULL Then
		g_pDSBCapture->lpVtbl->Stop(g_pDSBCapture)
		g_pDSBOutput->lpVtbl->Stop(g_pDSBOutput)
	End If
	
	'Clean up everything
	hr = FreeDirectSound()
	DXTRACE_MSG("FreeDirectSound()", hr)

	CtlEnabled(True)
End Sub

Private Sub Form1Type.CtlEnabled(b As Boolean)
	Dim lVol As Long
	Dim nb As Boolean = IIf(b, False, True)
	ComboBoxEdit1.Enabled = b
	ComboBoxEdit2.Enabled = b
	ComboBoxEdit3.Enabled = b
	ComboBoxEdit4.Enabled = b
	ComboBoxEdit5.Enabled = b
	ComboBoxEdit6.Enabled = b
	ComboBoxEdit7.Enabled = b
	ComboBoxEdit8.Enabled = b
	TrackBar1.Enabled = nb 
	TrackBar2.Enabled = nb 
	If b Then
		CommandButton1.Text = "Start"
	Else
		CommandButton1.Text = "Stop"
		If g_pDSBPrimary Then 
			g_pDSBPrimary->lpVtbl->getVolume(g_pDSBPrimary, @lVol)
			TrackBar1.Position = lVol
		End If
		If g_pDSBOutput Then 
			g_pDSBOutput->lpVtbl->getVolume(g_pDSBOutput, @lVol)
			TrackBar2.Position = lVol
		End If
	End If
End Sub

Private Sub Form1Type.Form_Create(ByRef Sender As Control)
	Debug.Clear
	CoInitialize(NULL)
	
	DirectSoundCaptureEnumerate(@DSoundEnumCallback, @ComboBoxEdit1)
	DirectSoundEnumerate(@DSoundEnumCallback, @ComboBoxEdit2)
	ComboBoxEdit1.ItemIndex = 0
	ComboBoxEdit2.ItemIndex = 0
	
	WaveFormat2Combo(@ComboBoxEdit3, @ComboBoxEdit4, @ComboBoxEdit5)
	WaveFormat2Combo(@ComboBoxEdit6, @ComboBoxEdit7, @ComboBoxEdit8)
	
	g_hNotificationEvent = CreateEvent(NULL, False, False, NULL)
End Sub

Private Sub Form1Type.Form_Destroy(ByRef Sender As Control)
	CloseHandle(g_hNotificationEvent)
	g_hNotificationEvent = NULL
	
	CoUninitialize()
End Sub

Private Sub Form1Type.CommandButton1_Click(ByRef Sender As Control)
	Select Case Sender.Text
	Case "Start"
		Debug.Clear
		ThreadCreate(Cast(Any Ptr , @ThreadDuplexFilter) , @This)
	Case "Stop"
		bStarting = False
		DXTRACE_MSG("Stop click", 0)
	End Select
End Sub

Private Sub Form1Type.TrackBar1_Change(ByRef Sender As TrackBar, Position As Integer)
	Dim lVol As Long = Position
	Select Case Sender.Name
	Case "TrackBar1"
		If g_pDSBPrimary Then g_pDSBPrimary->lpVtbl->setVolume(g_pDSBPrimary, lVol)
	Case "TrackBar2"
		If g_pDSBOutput Then g_pDSBOutput->lpVtbl->setVolume(g_pDSBOutput, lVol)
	End Select
	
	Debug.Print "Position: " & Position
End Sub
