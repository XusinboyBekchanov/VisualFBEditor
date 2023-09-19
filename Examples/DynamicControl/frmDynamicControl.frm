'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "frmDynamicControl.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/CheckedListBox.bi"
	#include once "mff/ImageBox.bi"
	#include once "mff/Label.bi"
	#include once "mff/ListControl.bi"
	#include once "mff/ProgressBar.bi"
	#include once "mff/RadioButton.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/Picture.bi"
	#include once "mff/TrackBar.bi"
	
	Using My.Sys.Forms
	
	Type Form3Type Extends Form
		lstCtl As List
		LstFrm As List
		
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Sub Form_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Constructor
		
		Dim As CommandButton CommandButton1, CommandButton2, CommandButton3, CommandButton4
		Dim As ComboBoxEdit ComboBoxEdit1
		Dim As CheckBox CheckBox1
		Dim As Label Label1
	End Type
	
	Constructor Form3Type
		' Form3
		With This
			.Name = "Form3"
			.Text = "Dynamic Control Example"
			.Designer = @This
			.Caption = "Dynamic Control Example"
			.OnMouseMove = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Form_MouseMove)
			.SetBounds 0, 0, 650, 380
		End With
		' ComboBoxEdit1
		With ComboBoxEdit1
			.Name = "ComboBoxEdit1"
			.Text = "ComboBoxEdit1"
			.TabIndex = 0
			.SetBounds 10, 10, 140, 21
			.Designer = @This
			.Parent = @This
			.AddItem("CommandButton")
			.AddItem("ComboBoxEdit")
			.AddItem("CheckBox")
			.AddItem("CheckedListBox")
			.AddItem("ImageBox")
			.AddItem("ListControl")
			.AddItem("ProgressBar")
			.AddItem("RadioButton")
			.AddItem("TextBox")
			.AddItem("Picture")
			.AddItem("TrackBar")
			'more controls...
			.ItemIndex = 0
		End With
		' CheckBox1
		With CheckBox1
			.Name = "CheckBox1"
			.Text = "Auto next"
			.TabIndex = 1
			.Caption = "Auto next"
			.Checked = True
			.SetBounds 10, 40, 140, 20
			.Designer = @This
			.Parent = @This
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "Add control"
			.TabIndex = 1
			.Caption = "Add control"
			.SetBounds 10, 80, 140, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton1_Click)
			.Parent = @This
		End With
		' CommandButton2
		With CommandButton2
			.Name = "CommandButton2"
			.Text = "Delete control"
			.TabIndex = 2
			.Caption = "Delete control"
			.SetBounds 10, 110, 140, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton1_Click)
			.Parent = @This
		End With
		' Label1
		With Label1
			.Name = "Label1"
			.Text = "Control count: 0"
			.TabIndex = 3
			.Caption = "Control count: 0"
			.SetBounds 10, 140, 140, 20
			.Designer = @This
			.Parent = @This
		End With
		' CommandButton3
		With CommandButton3
			.Name = "CommandButton3"
			.Text = "Create form"
			.TabIndex = 4
			.Caption = "Create form"
			.SetBounds 10, 280, 140, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton1_Click)
			.Parent = @This
		End With
		' CommandButton4
		With CommandButton4
			.Name = "CommandButton4"
			.Text = "Destroy form"
			.TabIndex = 5
			.Caption = "Destroy form"
			.SetBounds 10, 310, 140, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton1_Click)
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared Form3 As Form3Type
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		Form3.MainForm = True
		Form3.Show
		App.Run
	#endif
'#End Region

Private Sub Form3Type.CommandButton1_Click(ByRef Sender As Control)
	Dim i As Integer
	Dim j As Integer
	Dim y As Integer
	Dim x As Integer
	
	Select Case Sender.Name
	Case "CommandButton1" 'Add control
		Dim a As Control Ptr
		Dim s As String = ComboBoxEdit1.Items.Item(ComboBoxEdit1.ItemIndex)
		Select Case s
		Case "CommandButton"
			a = New CommandButton
		Case "ComboBoxEdit"
			a = New ComboBoxEdit
		Case "CheckBox"
			a = New CheckBox
		Case "CheckedListBox"
			a = New CheckedListBox
		Case "ImageBox"
			a = New ImageBox
			a->BorderStyle= BorderStyles.bsClient
		Case "ListControl"
			a = New ListControl
		Case "ProgressBar"
			a = New ProgressBar
		Case "RadioButton"
			a = New RadioButton
		Case "TextBox"
			a = New TextBox
		Case "Picture"
			a = New Picture
			a->BorderStyle= BorderStyles.bsClient
		Case "TrackBar"
			a = New TrackBar
		Case Else
			'more controls...
		End Select
		
		lstCtl.Add a
		i = lstCtl.Count - 1
		
		a->Name = s & "_" & i
		a->Text = Cast(Control Ptr, a)->Name
		a->OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton1_Click)
		a->OnMouseMove = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Form_MouseMove)
		a->Hint = a->Name
		This.Add a
		x = i \ ComboBoxEdit1.ItemCount + 1
		y = i Mod ComboBoxEdit1.ItemCount
		
		a->Move x * 140 + (x + 1) * 10, y * 20 + (y + 1) * 10, 140, 20
		a->Visible = True
		Label1.Caption = "Control count: " & i + 1
		Debug.Print "Control add: " & i & ", x=" & x & ", y=" & y
		
		If CheckBox1.Checked = False Then Exit Sub 
		i = ComboBoxEdit1.ItemIndex
		i += 1
		If i > ComboBoxEdit1.ItemCount - 1 Then i = 0
		ComboBoxEdit1.ItemIndex = i
	Case "CommandButton2" 'Delete control
		i = lstCtl.Count
		If i < 1 Then Exit Sub
		i -= 1
		
		Dim a As Control Ptr = lstCtl.Item(i)
		a->Visible= False

		This.Remove a
		Delete a
		lstCtl.Remove i
		Label1.Caption = "Control count: " & i
	Case "CommandButton3" 'Create form
		Dim a As Form3Type Ptr
		a = New Form3Type
		LstFrm.Add a
		i = LstFrm.Count
		Debug.Print "Form add: " & i

		a->Name = "Form" & i
		a->Caption = a->Name
		a->Show(This)
		a->Visible = True 
	Case "CommandButton4" 'Destroy form
		i = LstFrm.Count
		If i < 1 Then Exit Sub
		
		Debug.Print "Form remove: " & i
		Dim a As Form3Type Ptr = LstFrm.Item(i - 1)
		a->CloseForm
		Delete a
		LstFrm.Remove i - 1
	Case Else
		MsgBox "(" & Sender.Name & ") was clicked."
	End Select
End Sub

Private Sub Form3Type.Form_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	Debug.Print "MouseButton: " & MouseButton
	If MouseButton <> 0 Then Exit Sub
	ReleaseCapture()
	SendMessage(Sender.Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0)
End Sub
