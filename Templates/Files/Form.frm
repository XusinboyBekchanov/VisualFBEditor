#ifdef __FB_WIN32__
	'#Compile "Form1.rc"
#endif
'#Region "Form" '...'
	#include once "mff/Form.bi"
	
	Using My.Sys.Forms
	
	Type Form1 Extends Form
		
	End Type
	
	Dim Shared fForm1 As Form1
	
	#ifndef _NOT_AUTORUN_FORMS_
		fForm1.Show
		
		App.Run
	#endif
'#End Region
