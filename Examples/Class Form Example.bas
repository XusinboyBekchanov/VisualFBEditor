'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		Const _MAIN_FILE_ = __FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
	#endif
	#include once "mff/Form.bi"
	
	RedefineClassKeyword
	
	Using My.Sys.Forms
	
	Class Form1Type Extends Form
		
		__StartOfClassBody__
		
		__EndOfClassBody__
	End Class
	
	Dim Shared Form1 As Form1Type
	
	#if _MAIN_FILE_ = __FILE__
		Form1.MainForm = True
		Form1.Show
		App.Run
	#endif
'#End Region
