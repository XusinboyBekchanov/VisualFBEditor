'#Region "Form"
	#if defined(__FB_WIN32__) AndAlso defined(__FB_MAIN__)
		#cmdline "Form1.rc"
	#endif
	#include once "mff/Form.bi"
	
	Using My.Sys.Forms
	
	Type Form1Type Extends Form
		
	End Type
	
	Dim Shared Form1 As Form1Type
	
	#ifdef __FB_MAIN__
		Form1.Show
		
		App.Run
	#endif
'#End Region
