#ifdef __FB_WIN32__
	'#Compile "Form1.rc"
#endif
'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/PageScroller.bi"
	#include once "mff/CommandButton.bi"
	
	Using My.Sys.Forms
	
	Type Form1Type Extends Form
		Declare Static Sub CommandButton1_Click_(ByRef Sender As Control)
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Static Sub PageScroller1_Scroll_(ByRef Sender As PageScroller, ByRef NewPos As Integer)
		Declare Sub PageScroller1_Scroll(ByRef Sender As PageScroller, ByRef NewPos As Integer)
		Declare Constructor
		
		Dim As PageScroller PageScroller1
		Dim As CommandButton CommandButton1
	End Type
	
	Constructor Form1Type
		' Form1
		With This
			.Name = "Form1"
			.Text = "Form1"
			.SetBounds 0, 0, 350, 300
		End With
		' PageScroller1
		With PageScroller1
			.Name = "PageScroller1"
			.Text = "PageScroller1"
			.TabIndex = 0
			'.Style = PageScrollerStyle.psHorizontal
			.Align = DockStyle.alClient
			.SetBounds 0, 0, 334, 261
			.Designer = @This
			.OnScroll = @PageScroller1_Scroll_
			.Parent = @This
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "CommandButton1"
			.TabIndex = 1
			.SetBounds 0, 0, 400, 120
			.Designer = @This
			.OnClick = @CommandButton1_Click_
			.Parent = @PageScroller1
		End With
	End Constructor
	
	Dim Shared Form1 As Form1Type
	
	#ifndef _NOT_AUTORUN_FORMS_
		#define _NOT_AUTORUN_FORMS_
		
		Form1.Show
		
		App.Run
	#endif
'#End Region

Private Sub Form1Type.CommandButton1_Click_(ByRef Sender As Control)
	*Cast(Form1Type Ptr, Sender.Designer).CommandButton1_Click(Sender)
End Sub
Private Sub Form1Type.CommandButton1_Click(ByRef Sender As Control)
	?1
End Sub

Private Sub Form1Type.PageScroller1_Scroll_(ByRef Sender As PageScroller, ByRef NewPos As Integer)
	*Cast(Form1Type Ptr, Sender.Designer).PageScroller1_Scroll(Sender, NewPos)
End Sub
Private Sub Form1Type.PageScroller1_Scroll(ByRef Sender As PageScroller, ByRef NewPos As Integer)
	?NewPos
End Sub
