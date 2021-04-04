#ifdef __FB_WIN32__
	'#Compile -exx "Form1.rc"
#else
	'#Compile -exx
#endif
'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/Menus.bi"
	
	Using My.Sys.Forms
	
	Type Form1 Extends Form
		Declare Constructor
		
		Dim As MainMenu MainMenu1
		Dim As MenuItem MenuItem1, MenuItem2, MenuItem3, MenuItem4, MenuItem5
	End Type
	
	Constructor Form1
		' Form1
		With This
			.Name = "Form1"
			.Text = "Form1"
			.Menu = @MainMenu1
			.SetBounds 0, 0, 350, 300
		End With
		' MainMenu1
		With MainMenu1
			.Name = "MainMenu1"
			.SetBounds 160, 80, 16, 16
			.Parent = @This
		End With
		' MenuItem1
		With MenuItem1
			.Name = "MenuItem1"
			.Caption = "MenuItem1"
			.ParentMenu = @MainMenu1
		End With
		' MenuItem2
		With MenuItem2
			.Name = "MenuItem2"
			.Caption = "MenuItem2"
			.ParentMenu = @MainMenu1
		End With
		' MenuItem3
		With MenuItem3
			.Name = "MenuItem3"
			.Caption = "MenuItem3"
			.ParentMenu = @MainMenu1
			
		End With
		' MenuItem4
		With MenuItem4
			.Name = "MenuItem4"
			.Caption = "MenuItem4"
			.Parent = @MenuItem1
		End With
		' MenuItem5
		With MenuItem5
			.Name = "MenuItem5"
			.Caption = "MenuItem5"
			.Parent = @MenuItem2
		End With
	End Constructor
	
	Dim Shared fForm1 As Form1
	
	#ifndef _NOT_AUTORUN_FORMS_
		fForm1.Show
		
		App.Run
	#endif
'#End Region
