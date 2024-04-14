#ifdef __FB_WIN32__
	'#Compile "Form1.rc"
#endif
'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/ListView.bi"
	#include once "mff/ImageList.bi"
	
	Using My.Sys.Forms
	
	Type Form1Type Extends Form
		Declare Constructor
		
		Dim As ImageList ImageList1
		Dim As ListView ListView1
	End Type
	
	Constructor Form1Type
		' Form1
		With This
			.Name = "Form1"
			.Text = "Form1"
			.SetBounds 0, 0, 350, 300
		End With
		' ImageList1
		With ImageList1
			.Name = "ImageList1"
			.SetBounds 50, 170, 16, 16
			.Parent = @This
			.Add "About", "About"
		End With
		' ListView1
		With ListView1
			.Name = "ListView1"
			.Text = "ListView1"
			.TabIndex = 0
			.Images = @ImageList1
			.SmallImages = @ImageList1
			.SetBounds 19, 30, 280, 130
			.Parent = @This
			.Columns.Add "Column1", , 100
			.Columns.Add "Column2", , 100
			Var Item1 = .ListItems.Add("Item1", "About")
			Item1->Text(1) = "Item1_1"
			Item1->Tag = @"Item"
			.ListItems.Add "Item2"
		End With
	End Constructor
	
	Dim Shared Form1 As Form1Type
	
	#ifndef _NOT_AUTORUN_FORMS_
		#define _NOT_AUTORUN_FORMS_
		
		Form1.Show
		
		App.Run
	#endif
'#End Region
