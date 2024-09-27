'capturesound声音捕捉
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "frmcapturesound.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/Label.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/StatusBar.bi"
	#include once "mff/TimerComponent.bi"
	#include once "mff/Dialogs.bi"
	
	#include once "capturesound.bi"
	#include once "../MDINotepad/text.bi"
	Using My.Sys.Forms
	
	Type Form1Type Extends Form
		bStarting As BOOL
		nLength As DWORD
		nTime As Double
		
		Declare Static Function ThreadCaptureSound(ByVal pParam As LPVOID) As DWORD
		Declare Sub CaptureSound()
		Declare Sub CtlEnabled(b As Boolean)
		
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Sub TextBox1_DblClick(ByRef Sender As Control)
		Declare Constructor
		
		Dim As Label Label1, Label2, Label3, Label4, Label5
		Dim As ComboBoxEdit ComboBoxEdit1, ComboBoxEdit2, ComboBoxEdit3, ComboBoxEdit4
		Dim As TextBox TextBox1
		Dim As CommandButton CommandButton1
		Dim As StatusBar StatusBar1
		Dim As StatusPanel StatusPanel1
		Dim As TimerComponent TimerComponent1
		Dim As SaveFileDialog SaveFileDialog1
	End Type
	
	Constructor Form1Type
		' Form1
		With This
			.Name = "Form1"
			.Text = "CaptureSound"
			.Designer = @This
			.Caption = "CaptureSound"
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnDestroy = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Destroy)
			.BorderStyle = FormBorderStyle.FixedDialog
			.MaximizeBox = False
			.StartPosition = FormStartPosition.CenterScreen
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Form_Resize)
			.SetBounds 0, 0, 530, 240
		End With
		' Label1
		With Label1
			.Name = "Label1"
			.Text = "Capture device"
			.TabIndex = 0
			.SetBounds 10, 10, 500, 20
			.Designer = @This
			.Parent = @This
		End With
		' Label2
		With Label2
			.Name = "Label2"
			.Text = "Sample"
			.TabIndex = 1
			.SetBounds 10, 70, 160, 20
			.Designer = @This
			.Parent = @This
		End With
		' Label3
		With Label3
			.Name = "Label3"
			.Text = "Bits"
			.TabIndex = 2
			.SetBounds 180, 70, 160, 20
			.Designer = @This
			.Parent = @This
		End With
		' Label4
		With Label4
			.Name = "Label4"
			.Text = "Channel"
			.TabIndex = 3
			.SetBounds 350, 70, 160, 20
			.Designer = @This
			.Parent = @This
		End With
		' Label5
		With Label5
			.Name = "Label5"
			.Text = "File"
			.TabIndex = 4
			.SetBounds 10, 130, 330, 20
			.Designer = @This
			.Parent = @This
		End With
		' ComboBoxEdit1
		With ComboBoxEdit1
			.Name = "ComboBoxEdit1"
			.Text = "ComboBoxEdit1"
			.TabIndex = 5
			.Style = ComboBoxEditStyle.cbDropDown
			.SetBounds 10, 30, 500, 21
			.Designer = @This
			.Parent = @This
		End With
		' ComboBoxEdit2
		With ComboBoxEdit2
			.Name = "ComboBoxEdit2"
			.Text = "ComboBoxEdit2"
			.TabIndex = 6
			.SetBounds 10, 90, 160, 21
			.Designer = @This
			.Parent = @This
		End With
		' ComboBoxEdit3
		With ComboBoxEdit3
			.Name = "ComboBoxEdit3"
			.Text = "ComboBoxEdit3"
			.TabIndex = 7
			.SetBounds 180, 90, 160, 21
			.Designer = @This
			.Parent = @This
		End With
		' ComboBoxEdit4
		With ComboBoxEdit4
			.Name = "ComboBoxEdit4"
			.Text = "ComboBoxEdit4"
			.TabIndex = 8
			.SetBounds 350, 90, 160, 21
			.Designer = @This
			.Parent = @This
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = CurDir & "\rec.wav"
			.TabIndex = 9
			.SetBounds 10, 150, 330, 20
			.Designer = @This
			.OnDblClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @TextBox1_DblClick)
			.Parent = @This
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "Record"
			.TabIndex = 10
			.SetBounds 350, 150, 160, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton1_Click)
			.Parent = @This
		End With
		' StatusBar1
		With StatusBar1
			.Name = "StatusBar1"
			.Text = "StatusBar1"
			.Align = DockStyle.alBottom
			.SetBounds 0, 189, 524, 22
			.Designer = @This
			.Parent = @This
		End With
		' StatusPanel1
		With StatusPanel1
			.Name = "StatusPanel1"
			.Designer = @This
			.Parent = @StatusBar1
		End With
		' TimerComponent1
		With TimerComponent1
			.Name = "TimerComponent1"
			.Interval = 100
			.SetBounds 30, 170, 16, 16
			.Designer = @This
			.OnTimer = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent), @TimerComponent1_Timer)
			.Parent = @This
		End With
		' SaveFileDialog1
		With SaveFileDialog1
			.Name = "SaveFileDialog1"
			.Filter = "Wave file|*.wav"
			.SetBounds 0, 170, 16, 16
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

Private Sub Form1Type.Form_Create(ByRef Sender As Control)
	Debug.Clear
	
	CoInitialize(NULL)
	DirectSoundCaptureEnumerate(@DSoundEnumCallback, @ComboBoxEdit1)
	ComboBoxEdit1.ItemIndex = 0
	
	WaveFormat2Combo(@ComboBoxEdit2, @ComboBoxEdit3, @ComboBoxEdit4)
	g_hNotificationEvent = CreateEvent(NULL, False, False, NULL)
End Sub

Private Sub Form1Type.Form_Destroy(ByRef Sender As Control)
	CloseHandle(g_hNotificationEvent)
	FreeDirectSound()
	CoUninitialize()
End Sub

Private Function Form1Type.ThreadCaptureSound(ByVal pParam As LPVOID) As DWORD
	Cast(Form1Type Ptr, pParam)->CaptureSound()
	Return 0
End Function

Private Sub Form1Type.CaptureSound()
	nLength = 0
	Dim hr As HRESULT
	Dim filename As ZString Ptr
	TextToAnsi(TextBox1.Text, filename)
	
	WaveFileCreate(filename, CLng(ComboBoxEdit2.Items.Item(ComboBoxEdit2.ItemIndex)), CLng(ComboBoxEdit3.Items.Item(ComboBoxEdit3.ItemIndex)), CLng(ComboBoxEdit4.Items.Item(ComboBoxEdit4.ItemIndex)))
	
	hr = InitDirectSound(Handle, Cast(GUID Ptr, ComboBoxEdit1.ItemData(ComboBoxEdit1.ItemIndex)))
	WaveFormatSet(CInt(ComboBoxEdit2.ItemData(ComboBoxEdit2.ItemIndex)), CInt(ComboBoxEdit3.ItemData(ComboBoxEdit3.ItemIndex)), CInt(ComboBoxEdit4.ItemData(ComboBoxEdit4.ItemIndex)), @g_wfxInput)
	hr = CreateCaptureBuffer(@g_wfxInput)
	hr = InitNotifications()
	hr = RecordStart()
	
	nTime = Timer
	CtlEnabled(False)
	
	bStarting = True
	DXTRACE_MSG("While(bStarting)=true", 0)
	While(bStarting)
		hr = MsgWaitForMultipleObjects(1, @g_hNotificationEvent, False, INFINITE, QS_ALLEVENTS)
		Select Case hr
		Case WAIT_OBJECT_0
			'g_hNotificationEvents[0] is signaled
			
			'This means that DirectSound just finished playing
			'a piece of the buffer, so we need to fill the circular
			'buffer with new sound from the wav file
			
			nLength += RecordCapturedData(filename)
			DXTRACE_MSG("==RecordCapturedData==", hr)
		Case WAIT_OBJECT_0 + 1
			DXTRACE_MSG("Windows messages are available", 0)
		End Select
		App.DoEvents
	Wend
	DXTRACE_MSG("While(bStarting)=false", 0)
	
	hr = RecordStop()
	nLength += RecordCapturedData(filename)
	
	WaveFileClose(filename)
	FreeDirectSound()
	CtlEnabled(True)
	Deallocate(filename)
End Sub

Private Sub Form1Type.CtlEnabled(b As Boolean)
	Dim nb As Boolean = IIf(b, False, True)
	ComboBoxEdit1.Enabled = b
	ComboBoxEdit2.Enabled = b
	ComboBoxEdit3.Enabled = b
	ComboBoxEdit4.Enabled = b
	TextBox1.Enabled = b
	
	TimerComponent1.Enabled = nb
	
	If b Then
		CommandButton1.Text = "Record"
	Else
		CommandButton1.Text = "Stop"
	End If
	
End Sub

Private Sub Form1Type.CommandButton1_Click(ByRef Sender As Control)
	Select Case Sender.Text
	Case "Record"
		Debug.Clear
		ThreadCreate(Cast(Any Ptr , @ThreadCaptureSound) , @This)
	Case "Stop"
		bStarting = False
		DXTRACE_MSG("Stop click", 0)
	End Select
End Sub

Private Sub Form1Type.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	StatusPanel1.Width = This.Width
End Sub

Private Sub Form1Type.TimerComponent1_Timer(ByRef Sender As TimerComponent)
	StatusPanel1.Caption = "Record write " & Format(nLength, "0#,###") & " bytes, " & Format(Timer - nTime, "0.00") & " seconds."
End Sub

Private Sub Form1Type.TextBox1_DblClick(ByRef Sender As Control)
	SaveFileDialog1.FileName = TextBox1.Text
	If SaveFileDialog1.Execute() Then
		TextBox1.Text = SaveFileDialog1.FileName
	End If
End Sub
