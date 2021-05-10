#ifdef __FB_WIN32__
	'#Compile -exx "Form1.rc"
#else
	'#Compile -exx
#endif
'#Region "Form" '...'
	#include once "mff/Form.bi"
	
	Using My.Sys.Forms
	
	Type Form1 Extends Form
		Declare Constructor
		
	End Type
	
	Constructor Form1
		' Form1
		With This
			.Name = "Form1"
			.Text = "Form1"
			.Icon = "1"
			.SetBounds 0, 0, 350, 300
		End With
	End Constructor
	
	Dim Shared fForm1 As Form1
	
	#ifndef _NOT_AUTORUN_FORMS_
		fForm1.Show
		
		App.Run
	#endif
'#End Region
