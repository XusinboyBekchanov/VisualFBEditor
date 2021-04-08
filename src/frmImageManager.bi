'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/ToolBar.bi"
	#include once "mff/ListView.bi"
	#include once "mff/GroupBox.bi"
	
	Using My.Sys.Forms
	
	Type frmImageManager Extends Form
		Declare Constructor
		
		Dim As ToolBar ToolBar1
		Dim As ListView ListView1
		Dim As GroupBox GroupBox1
	End Type
	
	Dim Shared pfImageManager As frmImageManager Ptr
	
'#End Region
