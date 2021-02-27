#ifdef __FB_WIN32__
	'#Compile -exx "Form1.rc"
#else
	'#Compile -exx
#endif
'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/Chart.bi"
	
	Using My.Sys.Forms
	
	Type Form1 Extends Form
		Declare Static Sub Chart1_Create_(ByRef Sender As Control)
		Declare Sub Chart1_Create(ByRef Sender As Control)
		Declare Constructor
		
		Dim As Chart Chart1
	End Type
	
	Constructor Form1
		' Form1
		With This
			.Name = "Form1"
			.Text = "Form1"
			.SetBounds 0, 0, 350, 300
		End With
		' Chart1
		With Chart1
			.Name = "Chart1"
			.Text = "Chart1"
			.Title = "Chart1"
			.SetBounds 0, 0, 334, 261
			.Designer = @This
			.OnCreate = @Chart1_Create_
			.Align = DockStyle.alClient
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared fForm1 As Form1
	
	#ifndef _NOT_AUTORUN_FORMS_
		fForm1.Show
		
		App.Run
	#endif
'#End Region

Private Sub Form1.Chart1_Create_(ByRef Sender As Control)
	*Cast(Form1 Ptr, Sender.Designer).Chart1_Create(Sender)
End Sub
Private Sub Form1.Chart1_Create(ByRef Sender As Control)
	Chart1.AddItem "20001", 10, clRed
	Chart1.AddItem "20002", 10, clGreen
	Chart1.AddItem "20003", 10, clBlue
End Sub
