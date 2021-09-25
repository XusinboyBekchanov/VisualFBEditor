#ifdef __FB_WIN32__
	'#Compile "Form1.rc"
#endif
'#Region "Form"
	'#define __USE_GTK3__
	#include once "mff/Form.bi"
	#include once "mff/Animate.bi"
	#include once "mff/CommandButton.bi"
	
	Using My.Sys.Forms
	
	Type Form1Type Extends Form
		Declare Static Sub Form_Show_(ByRef Sender As Form)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Static Sub Form_Click_(ByRef Sender As Control)
		Declare Sub Form_Click(ByRef Sender As Control)
		Declare Static Sub CommandButton1_Click_(ByRef Sender As Control)
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Static Sub CommandButton2_Click_(ByRef Sender As Control)
		Declare Sub CommandButton2_Click(ByRef Sender As Control)
		Declare Constructor
		
		Dim As Animate Animate1
		Dim As CommandButton CommandButton1, CommandButton2
	End Type
	
	Constructor Form1Type
		' Form1
		With This
			.Name = "Form1"
			.Text = "Form1"
			.Designer = @This
			.OnShow = @Form_Show_
			.OnClick = @Form_Click_
			.SetBounds 0, 0, 350, 460
		End With
		' Animate1
		With Animate1
			.Name = "Animate1"
			.Text = "Animate1"
			'.CommonAvi = CommonAVIs.aviCopyFileEx
			.AutoSize = True
			.Transparency = False
			.SetBounds 40, 40, 272, 100
			.Parent = @This
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "Play"
			.TabIndex = 0
			.Caption = "Play"
			.SetBounds 10, 380, 157, 34
			.Designer = @This
			.OnClick = @CommandButton1_Click_
			.Parent = @This
		End With
		' CommandButton2
		With CommandButton2
			.Name = "CommandButton2"
			.Text = "Stop"
			.TabIndex = 1
			.Caption = "Stop"
			.SetBounds 170, 380, 157, 34
			.Designer = @This
			.OnClick = @CommandButton2_Click_
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared Form1 As Form1Type
	
	#ifndef _NOT_AUTORUN_FORMS_
		#define _NOT_AUTORUN_FORMS_
		
		Form1.Show
		
		App.Run
	#endif
'#End Region

Private Sub Form1Type.Form_Show_(ByRef Sender As Form)
	*Cast(Form1Type Ptr, Sender.Designer).Form_Show(Sender)
End Sub
Private Sub Form1Type.Form_Show(ByRef Sender As Form)
	#ifdef __USE_GTK__
		Animate1.File = "./Resources/horse.gif"
	#else
		Animate1.File = "./Resources/horse.avi"
	#endif
	Animate1.Open
	Animate1.Play
	'Animate1.Close
End Sub

Private Sub Form1Type.Form_Click_(ByRef Sender As Control)
	*Cast(Form1Type Ptr, Sender.Designer).Form_Click(Sender)
End Sub
Private Sub Form1Type.Form_Click(ByRef Sender As Control)
	ANimAte1.Stop
End Sub

Private Sub Form1Type.CommandButton1_Click_(ByRef Sender As Control)
	*Cast(Form1Type Ptr, Sender.Designer).CommandButton1_Click(Sender)
End Sub
Private Sub Form1Type.CommandButton1_Click(ByRef Sender As Control)
	Animate1.Play
End Sub

Private Sub Form1Type.CommandButton2_Click_(ByRef Sender As Control)
	*Cast(Form1Type Ptr, Sender.Designer).CommandButton2_Click(Sender)
End Sub
Private Sub Form1Type.CommandButton2_Click(ByRef Sender As Control)
	Animate1.Stop
End Sub
