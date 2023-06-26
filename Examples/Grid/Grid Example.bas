#ifdef __FB_WIN32__
	'#Compile "Form1.rc"
#endif
'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/Grid.bi"
	
	Using My.Sys.Forms
	
	Type Form1Type Extends Form
		Declare Constructor
		
		Dim As Grid Grid1
	End Type
	
	Constructor Form1Type
		' Form1
		With This
			.Name = "Form1"
			.Text = "Form1"
			.SetBounds 0, 0, 350, 300
		End With
		' Grid1
		With Grid1
			.Name = "Grid1"
			.Text = "Grid1"
			.TabIndex = 0
			.Align = DockStyle.alClient
			.SetBounds 0, 0, 334, 261
			.Parent = @This
			.Columns.Add "Column 1", , 150
			.Columns.Add "Column 2", , 150
			.Columns[1].Tag = @"0"
			.Rows.Add "Row 1 Column 1"
			.Rows.Add "Row 2 Column 1"
			.Rows.Add "Row 3 Column 1"
			.Rows.Add "Row 4 Column 1"
			Grid1[0][1].Text = "Row 1 Column 2"
			Grid1[1][1].Text = "Row 2 Column 2"
			.Rows[2][1].Text = "Row 3 Column 2"
			.Cells(3, 1)->Text = "Row 4 Column 2"
			.Rows[3].Tag = @"1"
		End With
	End Constructor
	
	Dim Shared Form1 As Form1Type
	
	#ifndef _NOT_AUTORUN_FORMS_
		#define _NOT_AUTORUN_FORMS_
		
		Form1.Show
		
		App.Run
	#endif
'#End Region
