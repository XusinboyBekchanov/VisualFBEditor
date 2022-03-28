#ifdef __FB_WIN32__
	#cmdline "Form1.rc"
#endif
'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/Grid.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/CheckBox.bi"
	
	Using My.Sys.Forms
	
	Type Form1Type Extends Form
		Declare Constructor
		
		Dim As Grid Grid1
		Dim As ComboBoxEdit ComboBoxEdit1
		Dim As CheckBox CheckBox1
	End Type
	
	Constructor Form1Type
		' Form1
		With This
			.Name = "Form1"
			.Text = "Form1"
			.SetBounds 0, 0, 350, 300
		End With
		' Grid1
		With Grid1
			.Name = "Grid1"
			.Text = "Grid1"
			.TabIndex = 0
			.SetBounds 52, 72, 118, 33
			.Parent = @This
		End With
		' ComboBoxEdit1
		With ComboBoxEdit1
			.Name = "ComboBoxEdit1"
			.Text = "ComboBoxEdit1"
			.TabIndex = 1
			.SetBounds 104, 185, 164, 29
			.Parent = @This
		End With
		' CheckBox1
		With CheckBox1
			.Name = "CheckBox1"
			.Text = "CheckBox1"
			.TabIndex = 2
			.SetBounds 66, 130, 138, 23
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
