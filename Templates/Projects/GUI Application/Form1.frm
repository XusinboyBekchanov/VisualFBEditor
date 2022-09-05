'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__ __FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
	#endif
	#include once "mff/Form.bi"
	
	Using My.Sys.Forms
	
	Type Form1Type Extends Form
		
	End Type
	
	Dim Shared Form1 As Form1Type
	
	#ifdef __MAIN_FILE__ = __FILE__
		Form1.Show
		
		App.Run
	#endif
'#End Region
