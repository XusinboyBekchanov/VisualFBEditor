﻿'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	
	Using My.Sys.Forms
	
	Type Form1Type Extends Form
		Declare Constructor
		
	End Type
	
	Constructor Form1Type
		' Form1
		With This
			.Name = "Form1"
			.Text = "Form1"
			.Designer = @This
			.SetBounds 0, 0, 350, 300
		End With
	End Constructor
	
	Dim Shared Form1 As Form1Type
	
	#if _MAIN_FILE_ = __FILE__
        #ifdef __USE_WINAPI__  
            InitDarkMode  
            SetDarkMode(True, True)  
        #endif  
		Form1.MainForm = True
		Form1.Show
		App.Run
	#endif
'#End Region
