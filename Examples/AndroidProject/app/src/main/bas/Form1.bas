#ifdef __FB_WIN32__
	'#Compile -x "../jniLibs/x86/libmff-app.so" -target i686-linux-android -v -dll -sysroot "D:/GitHub/android-ndk-r12b-windows-x86/android-ndk-r12b/platforms/android-9/arch-x86" -Wl "-L D:/GitHub/android-ndk-r12b-windows-x86/android-ndk-r12b/platforms/android-9/arch-x86/usr/lib"
#else
	'#Compile -x "../jniLibs/x86/libmff-app.so" -target i686-linux-android -v -dll -sysroot "/mnt/media/GitHub/android-ndk-r12b/platforms/android-9/arch-x86"
#endif

#define package mff_example_application

'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/Label.bi"
	#include once "mff/Panel.bi"
	Using My.Sys.Forms
	
	Type Form1Type Extends Form
		Declare Static Sub CommandButton1_Click_(ByRef Sender As Control)
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Static Sub TextBox1_Change_(ByRef Sender As TextBox)
		Declare Sub TextBox1_Change(ByRef Sender As TextBox)
		Declare Constructor
		
		Dim As CommandButton CommandButton1, CommandButton2
		Dim As TextBox TextBox1
		Dim As Label Label1
		Dim As Panel Panel1
	End Type
	
	Constructor Form1Type
		' Form1
		With This
			.Name = "Form1"
			.Text = "Form1"
			.BorderStyle = FormBorderStyle.None
			.SetBounds 0, 0, 257, 377
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "CommandButton1"
			.TabIndex = 0
			.Align = DockStyle.alNone
			.SetBounds 0, 70, 257, 27
			.Designer = @This
			.OnClick = @CommandButton1_Click_
			.Parent = @This
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = "TextBox1"
			.TabIndex = 0
			.SetBounds 70, 10, 170, 40
			.Designer = @This
			.OnChange = @TextBox1_Change_
			.Parent = @This
		End With
		' Label1
		With Label1
			.Name = "Label1"
			.Text = "Label1"
			.TabIndex = 0
			.SetBounds 10, 10, 50, 40
			.Parent = @This
		End With
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = "Panel1"
			.TabIndex = 3
			.SetBounds 70, 130, 130, 100
			.Parent = @This
		End With
		' CommandButton2
		With CommandButton2
			.Name = "CommandButton2"
			.Text = "CommandButton2"
			.TabIndex = 4
			.SetBounds 10, 300, 20, 30
			.Parent = @Panel1
		End With
	End Constructor
	
	Dim Shared Form1 As Form1Type
	
	#ifndef _NOT_AUTORUN_FORMS_
		#define _NOT_AUTORUN_FORMS_
		
		Form1.Show
		
		App.Run
	#endif
'#End Region

Private Sub Form1Type.CommandButton1_Click_(ByRef Sender As Control)
	*Cast(Form1Type Ptr, Sender.Designer).CommandButton1_Click(Sender)
End Sub
Private Sub Form1Type.CommandButton1_Click(ByRef Sender As Control)
	Me.Text = Form1.Width & ", " & Form1.Height & ", " & CommandButton1.Width & ", " & CommandButton1.Height
End Sub

Private Sub Form1Type.TextBox1_Change_(ByRef Sender As TextBox)
	*Cast(Form1Type Ptr, Sender.Designer).TextBox1_Change(Sender)
End Sub
Private Sub Form1Type.TextBox1_Change(ByRef Sender As TextBox)
	Me.Text = Sender.Text
End Sub
