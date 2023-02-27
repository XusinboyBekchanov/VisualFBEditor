'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		Const _MAIN_FILE_ = __FILE__
		#ifdef __FB_WIN32__
			#cmdline "frmPipe.rc"
		#endif
	#endif
	#include once "mff/Form.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/Panel.bi"
	#include once "vbcompat.bi"
	#include once "PipeProcess.bi"
	
	Using My.Sys.Forms
	
	Type frmPipeType Extends Form
		mPp As PipeProcess
		
		Declare Sub InitCmd(ByRef cmd As WString)
		
		Declare Static Sub OnPipeRead(o As Any Ptr, DataRead As ZString, Length As Long)
		Declare Static Sub OnPipeClosed(o As Any Ptr, ErrorLevel As Long)
		Declare Sub PipeReady(b As Boolean)
		Declare Sub PipeClear()
		
		Declare Static Sub _Form_Create(ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Static Sub _CommandButton1_Click(ByRef Sender As Control)
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Static Sub _CommandButton2_Click(ByRef Sender As Control)
		Declare Sub CommandButton2_Click(ByRef Sender As Control)
		Declare Static Sub _CommandButton3_Click(ByRef Sender As Control)
		Declare Sub CommandButton3_Click(ByRef Sender As Control)
		Declare Static Sub _ComboBoxEdit2_KeyUp(ByRef Sender As ComboBoxEdit, Key As Integer, Shift As Integer)
		Declare Sub ComboBoxEdit2_KeyUp(ByRef Sender As ComboBoxEdit, Key As Integer, Shift As Integer)
		Declare Static Sub _ComboBoxEdit1_KeyUp(ByRef Sender As ComboBoxEdit, Key As Integer, Shift As Integer)
		Declare Sub ComboBoxEdit1_KeyUp(ByRef Sender As ComboBoxEdit, Key As Integer, Shift As Integer)
		Declare Constructor
		
		Dim As TextBox TextBox5, TextBox3, TextBox4
		Dim As Panel Panel1
		Dim As ComboBoxEdit ComboBoxEdit2, ComboBoxEdit1
		Dim As CommandButton CommandButton2, CommandButton1, CommandButton3
	End Type
	
	Constructor frmPipeType
		' frmPipe
		With This
			.Name = "frmPipe"
			.Text = "PipeProcess"
			.Designer = @This
			.OnCreate = @_Form_Create
			.StartPosition = FormStartPosition.CenterScreen
			#ifdef __FB_64BIT__
				'...instructions for 64bit OSes...
				.Caption = "VFBE PipeProcess64"
			#else
				'...instructions for other OSes
				.Caption = "VFBE PipeProcess32"
			#endif
			.SetBounds 0, 0, 826, 500
		End With
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = "Panel1"
			.TabIndex = 0
			.Align = DockStyle.alTop
			.ExtraMargins.Top = 10
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.SetBounds 0, 0, 814, 140
			.Parent = @This
		End With
		' ComboBoxEdit1
		With ComboBoxEdit1
			.Name = "ComboBoxEdit1"
			.Text = "cmd"
			.TabIndex = 1
			.Style = ComboBoxEditStyle.cbDropDown
			.SetBounds 0, 0, 240, 21
			.Designer = @This
			.OnKeyUp = @_ComboBoxEdit1_KeyUp
			.Parent = @Panel1
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "Create"
			.TabIndex = 2
			.SetBounds 250, 0, 90, 20
			.Designer = @This
			.OnClick = @_CommandButton1_Click
			.Parent = @Panel1
		End With
		' ComboBoxEdit2
		With ComboBoxEdit2
			.Name = "ComboBoxEdit2"
			.Text = "dir"
			.TabIndex = 3
			.Style = ComboBoxEditStyle.cbDropDown
			.SetBounds 350, 0, 240, 21
			.Designer = @This
			.OnKeyUp = @_ComboBoxEdit2_KeyUp
			.Parent = @Panel1
		End With
		' CommandButton2
		With CommandButton2
			.Name = "CommandButton2"
			.Text = "Enter"
			.TabIndex = 4
			.SetBounds 600, 0, 90, 20
			.Designer = @This
			.OnClick = @_CommandButton2_Click
			.Parent = @Panel1
		End With
		' CommandButton3
		With CommandButton3
			.Name = "CommandButton3"
			.Text = "Clear"
			.TabIndex = 5
			.SetBounds 700, 0, 90, 20
			.Designer = @This
			.OnClick = @_CommandButton3_Click
			.Parent = @Panel1
		End With
		' TextBox3
		With TextBox3
			.Name = "TextBox3"
			.Text = "TextBox3"
			.TabIndex = 6
			.Multiline = True
			.ID = 1007
			.ScrollBars = ScrollBarsType.Both
			.Font.Name = "Consolas"
			.SetBounds 0, 30, 340, 110
			.Parent = @Panel1
		End With
		' TextBox4
		With TextBox4
			.Name = "TextBox4"
			.Text = "TextBox4"
			.TabIndex = 7
			.Multiline = True
			.ScrollBars = ScrollBarsType.Both
			.Font.Name = "Consolas"
			.SetBounds 350, 30, 440, 110
			.Parent = @Panel1
		End With
		' TextBox5
		With TextBox5
			.Name = "TextBox5"
			.Text = "TextBox5"
			.TabIndex = 8
			.Align = DockStyle.alClient
			.ExtraMargins.Bottom = 10
			.ExtraMargins.Left = 10
			.ExtraMargins.Right = 10
			.ExtraMargins.Top = 10
			.Font.Name = "Consolas"
			.SetBounds 10, 160, 790, 291
			.ScrollBars = ScrollBarsType.Both
			.Multiline = True
			.ID = 1010
			.Parent = @This
		End With
	End Constructor
	
	Private Sub frmPipeType._Form_Create(ByRef Sender As Control)
		(*Cast(frmPipeType Ptr, Sender.Designer)).Form_Create(Sender)
	End Sub
	Private Sub frmPipeType._CommandButton1_Click(ByRef Sender As Control)
		(*Cast(frmPipeType Ptr, Sender.Designer)).CommandButton1_Click(Sender)
	End Sub
	Private Sub frmPipeType._CommandButton2_Click(ByRef Sender As Control)
		(*Cast(frmPipeType Ptr, Sender.Designer)).CommandButton2_Click(Sender)
	End Sub
	Private Sub frmPipeType._CommandButton3_Click(ByRef Sender As Control)
		(*Cast(frmPipeType Ptr, Sender.Designer)).CommandButton3_Click(Sender)
	End Sub
	Private Sub frmPipeType._ComboBoxEdit2_KeyUp(ByRef Sender As ComboBoxEdit, Key As Integer, Shift As Integer)
		(*Cast(frmPipeType Ptr, Sender.Designer)).ComboBoxEdit2_KeyUp(Sender, Key, Shift)
	End Sub
	Private Sub frmPipeType._ComboBoxEdit1_KeyUp(ByRef Sender As ComboBoxEdit, Key As Integer, Shift As Integer)
		(*Cast(frmPipeType Ptr, Sender.Designer)).ComboBoxEdit1_KeyUp(Sender, Key, Shift)
	End Sub
	
	Dim Shared frmPipe As frmPipeType
	
	#if _MAIN_FILE_ = __FILE__
		frmPipe.MainForm = True
		frmPipe.Show
		App.Run
	#endif
'#End Region

Private Sub frmPipeType.OnPipeRead(o As Any Ptr, DataRead As ZString, Length As Long)
	Cast(frmPipeType Ptr, o)->TextBox5.Text = Cast(frmPipeType Ptr, o)->TextBox5.Text + DataRead
	Cast(frmPipeType Ptr, o)->TextBox5.SelStart = Cast(frmPipeType Ptr, o)->TextBox5.GetTextLength
	SendMessage(Cast(frmPipeType Ptr, o)->TextBox5.Handle, EM_SCROLLCARET, 0, 0)
End Sub

Private Sub frmPipeType.OnPipeClosed(o As Any Ptr,ErrorLevel As Long)
	Cast(frmPipeType Ptr, o)->TextBox4.Text = "PipeClosed Return " + Format(ErrorLevel, "0")
	Cast(frmPipeType Ptr, o)->PipeReady(True)
End Sub

Private Sub frmPipeType.PipeReady(b As Boolean)
	Dim nb As Boolean
	
	If b Then
		nb = False
		CommandButton1.Caption = "Create"
	Else
		nb = True
		CommandButton1.Caption = "Close"
	End If
	ComboBoxEdit1.Enabled = b
	ComboBoxEdit2.Enabled = nb
	CommandButton2.Enabled = nb
End Sub

Private Sub frmPipeType.PipeClear()
	TextBox3.Text = ""
	TextBox4.Text = ""
	TextBox5.Text = ""
End Sub

Private Sub frmPipeType.InitCmd(ByRef cmd As WString)
	ComboBoxEdit2.Clear
	Select Case LCase(cmd)
	Case "cmd"
		ComboBoxEdit2.AddItem "c:"
		ComboBoxEdit2.AddItem "dir"
		ComboBoxEdit2.AddItem "cd \users\cm.wang\desktop\test"
		ComboBoxEdit2.AddItem "cd"
		ComboBoxEdit2.AddItem "cls"
		ComboBoxEdit2.AddItem "prompt"
		ComboBoxEdit2.AddItem "echo %date%"
		ComboBoxEdit2.AddItem "echo %time%"
		ComboBoxEdit2.AddItem "exit 123"
	Case "diskpart"
		ComboBoxEdit2.AddItem "list disk"
		ComboBoxEdit2.AddItem "select disk 0"
		ComboBoxEdit2.AddItem "list partition"
		ComboBoxEdit2.AddItem "select partition 0"
		ComboBoxEdit2.AddItem "help"
		ComboBoxEdit2.AddItem "exit"
	Case "wmic"
		ComboBoxEdit2.AddItem "/?"
		ComboBoxEdit2.AddItem "process list"
		ComboBoxEdit2.AddItem "servive list"
		ComboBoxEdit2.AddItem "bios list"
		ComboBoxEdit2.AddItem "cpu get CurrentClockSpeed"
		ComboBoxEdit2.AddItem "desktopmonitor"
		ComboBoxEdit2.AddItem "DISKDRIVE get Caption,size,InterfaceType"
		ComboBoxEdit2.AddItem "ENVIRONMENT where name='temp' get UserName,VariableValue"
		ComboBoxEdit2.AddItem "LOGICALDISK get name,Description,filesystem,size,freespace"
		ComboBoxEdit2.AddItem "memphysical list"
		ComboBoxEdit2.AddItem "nic list"
	End Select
End Sub

Private Sub frmPipeType.Form_Create(ByRef Sender As Control)
	mPp.OnPipeRead = @OnPipeRead
	mPp.OnPipeClosed = @OnPipeClosed
	PipeReady(True)
	PipeClear()
	ComboBoxEdit1.AddItem "cmd"
	ComboBoxEdit1.AddItem "diskpart"
	ComboBoxEdit1.AddItem "chkdsk"
	ComboBoxEdit1.AddItem "wmic"
	ComboBoxEdit1.ItemIndex = 0
	InitCmd(ComboBoxEdit1.Item(0))
End Sub

Private Sub frmPipeType.CommandButton1_Click(ByRef Sender As Control)
	Dim rtnl As Long
	Dim rtns As WString * 1024
	
	Select Case CommandButton1.Caption
	Case "Close"
		rtnl = mPp.PipeClosed()
		PipeReady(True)
		TextBox4.Text = "PipeClosed " & rtnl
	Case Else
		rtnl = mPp.PipeCreate(@This, ComboBoxEdit1.Text, rtns)
		If rtnl = -1 Then
			PipeClear()
			PipeReady(False)
		End If
		TextBox3.AddLine ComboBoxEdit1.Text
		TextBox4.Text = rtns + " " & rtnl
		InitCmd(ComboBoxEdit1.Text)
	End Select
End Sub

Private Sub frmPipeType.CommandButton2_Click(ByRef Sender As Control)
	TextBox3.AddLine ComboBoxEdit2.Text
	TextBox4.Text = "Write " & mPp.PipeWrite(ComboBoxEdit2.Text + vbCrLf) & "byties"
End Sub

Private Sub frmPipeType.CommandButton3_Click(ByRef Sender As Control)
	PipeClear()
End Sub

Private Sub frmPipeType.ComboBoxEdit2_KeyUp(ByRef Sender As ComboBoxEdit, Key As Integer, Shift As Integer)
	Select Case Key
	Case 13
		CommandButton2_Click(Sender)
		ComboBoxEdit2.Text = ""
	Case 3
		TextBox3.AddLine Chr(3)
		TextBox4.Text = "Write " & mPp.PipeWrite(Chr(3)) & "byties"
	End Select
	TextBox4.AddLine "Key: " & Key & ", Shift: " & Shift
End Sub

Private Sub frmPipeType.ComboBoxEdit1_KeyUp(ByRef Sender As ComboBoxEdit, Key As Integer, Shift As Integer)
	Select Case Key
	Case 13
		CommandButton1_Click(Sender)
	End Select
	TextBox3.AddLine "Key: " & Key & ", Shift: " & Shift
End Sub
