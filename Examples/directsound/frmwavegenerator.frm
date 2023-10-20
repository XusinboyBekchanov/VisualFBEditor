'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "frmwavegenerator.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/TrackBar.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Label.bi"
	
	#include once "wavegenerator.bi"
	
	Using My.Sys.Forms
	
	Type Form1Type Extends Form
		
		Declare Sub CtlEnabled(b As Boolean)
		
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Sub TrackBar1_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Constructor
		
		Dim As ComboBoxEdit ComboBoxEdit1, ComboBoxEdit2, ComboBoxEdit3
		Dim As TrackBar TrackBar1, TrackBar2, TrackBar3
		Dim As CommandButton CommandButton1
		Dim As Label Label1, Label2, Label3
	End Type
	
	Constructor Form1Type
		' Form1
		With This
			.Name = "Form1"
			.Text = "Wave Generator"
			.Designer = @This
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnDestroy = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Destroy)
			.Caption = "Wave Generator"
			.StartPosition = FormStartPosition.CenterScreen
			.SetBounds 0, 0, 350, 310
		End With
		' ComboBoxEdit1
		With ComboBoxEdit1
			.Name = "ComboBoxEdit1"
			.Text = "ComboBoxEdit1"
			.TabIndex = 0
			.Hint = "Output device"
			.Style = ComboBoxEditStyle.cbDropDown
			.SetBounds 10, 20, 310, 21
			.Designer = @This
			.Parent = @This
		End With
		' ComboBoxEdit2
		With ComboBoxEdit2
			.Name = "ComboBoxEdit2"
			.Text = "ComboBoxEdit2"
			.TabIndex = 1
			.Hint = "Samples Per Sec"
			.SetBounds 10, 60, 150, 21
			.Designer = @This
			.Parent = @This
			.AddItem "44100"
			.ItemData(0) = Cast(Any Ptr, 44100)
			.ItemIndex = 0
		End With
		' ComboBoxEdit3
		With ComboBoxEdit3
			.Name = "ComboBoxEdit3"
			.Text = "ComboBoxEdit3"
			.TabIndex = 2
			.Hint = "Wave type"
			.SetBounds 170, 60, 150, 21
			.Designer = @This
			.Parent = @This
			.AddItem "Sin"
			.AddItem "Square"
			.AddItem "Sawtooth"
			.AddItem "Triangular"
			.ItemIndex = 0
		End With
		' TrackBar1
		With TrackBar1
			.Name = "TrackBar1"
			.Text = "TrackBar1"
			.TabIndex = 3
			.MaxValue = 0
			.MinValue = -10000
			.Hint = "Volume"
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.Position = -1500
			.SetBounds 10, 130, 150, 20
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TrackBar, Position As Integer), @TrackBar1_Change)
			.Parent = @This
		End With
		' TrackBar2
		With TrackBar2
			.Name = "TrackBar2"
			.Text = "TrackBar2"
			.TabIndex = 4
			.MinValue = -10000
			.MaxValue = 10000
			.Hint = "Balance"
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.SetBounds 170, 130, 150, 20
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TrackBar, Position As Integer), @TrackBar1_Change)
			.Parent = @This
		End With
		' TrackBar3
		With TrackBar3
			.Name = "TrackBar3"
			.Text = "TrackBar3"
			.TabIndex = 5
			.MinValue = 20
			.MaxValue = 20000
			.Hint = "Frequency"
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.Position = 240
			.SetBounds 10, 190, 310, 20
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TrackBar, Position As Integer), @TrackBar1_Change)
			.Parent = @This
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "Start"
			.TabIndex = 6
			.Caption = "Start"
			.SetBounds 120, 230, 110, 30
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton1_Click)
			.Parent = @This
		End With
		' Label1
		With Label1
			.Name = "Label1"
			.Text = "Label1"
			.TabIndex = 7
			.Alignment = AlignmentConstants.taCenter
			.SetBounds 10, 110, 150, 16
			.Designer = @This
			.Parent = @This
		End With
		' Label2
		With Label2
			.Name = "Label2"
			.Text = "Label2"
			.TabIndex = 8
			.Alignment = AlignmentConstants.taCenter
			.SetBounds 170, 110, 150, 16
			.Designer = @This
			.Parent = @This
		End With
		' Label3
		With Label3
			.Name = "Label3"
			.Text = "Label3"
			.TabIndex = 9
			.Alignment = AlignmentConstants.taCenter
			.SetBounds 10, 170, 310, 16
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

Private Sub Form1Type.CtlEnabled(bstart As Boolean)
	Dim nbstart As Boolean = IIf(bstart, False, True)
	ComboBoxEdit1.Enabled = bstart
	ComboBoxEdit2.Enabled = bstart
	ComboBoxEdit3.Enabled = bstart
	TrackBar1.Enabled = nbstart
	TrackBar2.Enabled = nbstart
	TrackBar3.Enabled = nbstart
	Label1.Enabled = nbstart
	Label2.Enabled = nbstart
	Label3.Enabled = nbstart
	If bstart Then
		CommandButton1.Text = "Start"
	Else
		CommandButton1.Text = "Stop"
	End If
End Sub

Private Sub Form1Type.Form_Create(ByRef Sender As Control)
	Debug.Clear
	CoInitialize(NULL)
	DirectSoundEnumerate(@DSoundEnumCallback, @ComboBoxEdit1)
	ComboBoxEdit1.ItemIndex = 0
	TrackBar1_Change TrackBar1, TrackBar1.Position
	TrackBar1_Change TrackBar2, TrackBar2.Position
	TrackBar1_Change TrackBar3, TrackBar3.Position
	
	CtlEnabled True
End Sub

Private Sub Form1Type.Form_Destroy(ByRef Sender As Control)
	CoUninitialize()
End Sub

Private Sub Form1Type.CommandButton1_Click(ByRef Sender As Control)
	Dim d As DWORD
	Dim l As Long
	
	Select Case Sender.Text
	Case "Start"
		CtlEnabled False
		WaveStart(ComboBoxEdit1.ItemData(ComboBoxEdit1.ItemIndex), Handle, ComboBoxEdit3.ItemIndex)
			l = TrackBar1.Position
			IDirectSoundBuffer_SetVolume(mSoundBuffer, l)
			l = TrackBar2.Position
			IDirectSoundBuffer_SetPan(mSoundBuffer, l)
			d = TrackBar3.Position * mBufferLength
			IDirectSoundBuffer_SetFrequency(mSoundBuffer, d)
			WavePlay()
	Case "Stop"
		CtlEnabled True
		WaveStop()
	End Select
End Sub

Private Sub Form1Type.TrackBar1_Change(ByRef Sender As TrackBar, Position As Integer)
	Dim hr As HRESULT
	Dim d As DWORD
	Dim l As Long
	Select Case Sender.Name
	Case "TrackBar1" 'wave format
		Label1.Text = Sender.Hint & ": " & Position
		
		If mSoundBuffer Then
			IDirectSoundBuffer_GetVolume(mSoundBuffer, @l)
			Debug.Print "mSoundBuffer GetVolume: " & l
			l=Cast(Long,Position)
			hr = IDirectSoundBuffer_SetVolume(mSoundBuffer, l)
		End If
	Case "TrackBar2" 'wave type
		Label2.Text = Sender.Hint & ": " & Position
		
		If mSoundBuffer Then
			IDirectSoundBuffer_GetPan(mSoundBuffer, @l)
			Debug.Print "mSoundBuffer GetPan" & l
			l = Cast(Long, Position)
			hr = IDirectSoundBuffer_SetPan(mSoundBuffer, l)
		End If
	Case "TrackBar3" 'frequency
		Label3.Text = Sender.Hint & ": " & Position
		
		If mSoundBuffer Then
			IDirectSoundBuffer_GetFrequency(mSoundBuffer, @d)
			Debug.Print "mSoundBuffer GetFrequency: " & d / mBufferLength
			d = Cast(DWORD, Position)
			hr = IDirectSoundBuffer_SetFrequency(mSoundBuffer, d * mBufferLength)
			Debug.Print "mSoundBuffer SetFrequency: " & hr
		End If
	End Select
End Sub
