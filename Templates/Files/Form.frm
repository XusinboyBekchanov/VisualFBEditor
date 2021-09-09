#ifdef __FB_WIN32__
	'#Compile "Form1.rc"
#endif
'#Region "Form" '...'
	#include once "mff/Form.bi"
	
	Using My.Sys.Forms
	
	Type Form1Type Extends Form
		
	End Type
	
	Dim Shared Form1 As Form1Type
	
	#ifndef _NOT_AUTORUN_FORMS_
		Form1.Show
		
		App.Run
	#endif
'#End Region
