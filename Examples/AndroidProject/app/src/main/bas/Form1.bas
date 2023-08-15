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
	#include once "mff/CheckBox.bi"
	#include once "mff/MonthCalendar.bi"
	#include once "mff/ListView.bi"
	Using My.Sys.Forms
	
	Type Form1Type Extends Form
		Declare Static Sub CommandButton1_Click_(ByRef Sender As Control)
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Static Sub TextBox1_Change_(ByRef Sender As TextBox)
		Declare Sub TextBox1_Change(ByRef Sender As TextBox)
		Declare Constructor
		
		Dim As CommandButton CommandButton1
		Dim As TextBox TextBox1
		Dim As Label Label1
		Dim As CheckBox CheckBox1
		Dim As MonthCalendar MonthCalendar1
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
			.SetBounds 0, 60, 257, 37
			.Designer = @This
			.OnClick = @CommandButton1_Click_
			.Parent = @This
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = "TextBox1"
			.TabIndex = 0
			.SetBounds 70, 10, 170, 30
			.Designer = @This
			.OnChange = @TextBox1_Change_
			.Parent = @This
		End With
		' Label1
		With Label1
			.Name = "Label1"
			.Text = "Label1"
			.TabIndex = 0
			.SetBounds 10, 10, 50, 20
			.Parent = @This
		End With
		' CheckBox1
		With CheckBox1
			.Name = "CheckBox1"
			.Text = "CheckBox1"
			.TabIndex = 5
			.SetBounds 30, 310, 170, 30
			.Parent = @This
		End With
		' MonthCalendar1
		With MonthCalendar1
			.Name = "MonthCalendar1"
			.Text = "MonthCalendar1"
			.TabIndex = 4
			.SetBounds 10, 110, 230, 190
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

Private Sub Form1Type.CommandButton1_Click_(ByRef Sender As Control)
	(*Cast(Form1Type Ptr, Sender.Designer)).CommandButton1_Click(Sender)
End Sub
Private Sub Form1Type.CommandButton1_Click(ByRef Sender As Control)
	Me.Text = Form1.Width & ", " & Form1.Height & ", " & CommandButton1.Width & ", " & CommandButton1.Height
End Sub

Private Sub Form1Type.TextBox1_Change_(ByRef Sender As TextBox)
	(*Cast(Form1Type Ptr, Sender.Designer)).TextBox1_Change(Sender)
End Sub
Private Sub Form1Type.TextBox1_Change(ByRef Sender As TextBox)
	Me.Text = Sender.Text
End Sub
