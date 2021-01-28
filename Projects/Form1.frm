#ifdef __FB_WIN32__
	'#Compile -exx "Form1.rc"
#else
	'#Compile -exx
#endif
'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/CommandButton.bi"
	
	Using My.Sys.Forms
	
	Type Form1 Extends Form
		Declare Static Sub CommandButton1_Click_(ByRef Sender As Control)
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Constructor
		
		Dim As CheckBox CheckBox1
		Dim As CommandButton CommandButton1
	End Type
	
	Constructor Form1
		' Form1
		With This
			.Name = "Form1"
			.Text = "Form1"
			.SetBounds 0, 0, 350, 300
		End With
		' CheckBox1
		With CheckBox1
			.Name = "CheckBox1"
			.Text = "CheckB566ox1"
			.TabIndex = 0
			.SetBounds 60, 100, 120, 50
			.Caption = "CheckB566ox1"
			.Parent = @This
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "CommandButton11545"
			.TabIndex = 1
			.SetBounds 40, 200, 230, 30
			.Designer = @This
			.OnClick = @CommandButton1_Click_
			.Caption = "CommandButton11545"
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared fForm1 As Form1
	
	#ifndef _NOT_AUTORUN_FORMS_
		fForm1.Show
		
		App.Run
	#endif
'#End Region

Private Sub Form1.CommandButton1_Click_(ByRef Sender As Control)
	*Cast(Form1 Ptr, Sender.Designer).CommandButton1_Click(Sender)
End Sub
Private Sub Form1.CommandButton1_Click(ByRef Sender As Control)
	MsgBox "sdsdsd"
End Sub


