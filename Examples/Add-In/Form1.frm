#ifdef __FB_WIN32__
	#cmdline "Form1.rc"
#endif
'#Region "Form"
	#include once "mff/Form.bi"
	
	Using My.Sys.Forms
	
	Type Form1Type Extends Form
		Declare Static Sub Form_Click_(ByRef Sender As Control)
		Declare Sub Form_Click(ByRef Sender As Control)
		Declare Constructor
		
	End Type
	
	Constructor Form1Type
		' Form1
		With This
			.Name = "Form1"
			.Text = "Form1"
			.Designer = @This
			.OnClick = @Form_Click_
			.SetBounds 0, 0, 350, 300
		End With
	End Constructor
	
	Private Sub Form1Type.Form_Click_(ByRef Sender As Control)
		*Cast(Form1Type Ptr, Sender.Designer).Form_Click(Sender)
	End Sub
	
	Dim Shared Form1 As Form1Type
	
	#ifndef _NOT_AUTORUN_FORMS_
		#define _NOT_AUTORUN_FORMS_
		
		Form1.Show
		
		App.Run
	#endif
'#End Region

Private Sub Form1Type.Form_Click(ByRef Sender As Control)
	
End Sub
