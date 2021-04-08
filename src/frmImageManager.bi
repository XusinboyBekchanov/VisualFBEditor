'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/ToolBar.bi"
	#include once "mff/ListView.bi"
	#include once "mff/GroupBox.bi"
	#include once "mff/ImageBox.bi"
	#include once "mff/Splitter.bi"
	#include once "mff/Panel.bi"
	#include once "mff/CommandButton.bi"
	
	Using My.Sys.Forms
	
	Type frmImageManager Extends Form
		Declare Static Sub Form_Show_(ByRef Sender As Form)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Static Sub cmdCancel_Click_(ByRef Sender As Control)
		Declare Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Static Sub cmdOK_Click_(ByRef Sender As Control)
		Declare Sub cmdOK_Click(ByRef Sender As Control)
		Declare Static Sub lvImages_ItemActivate_(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub lvImages_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Static Sub lvImages_SelectedItemChanged_(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub lvImages_SelectedItemChanged(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Constructor
		
		Dim As ToolBar tbToolbar
		Dim As ListView lvImages
		Dim As GroupBox gbImagePreview
		Dim As ImageBox imgImage
		Dim ResourceFile As UString
		Dim As Splitter Splitter1
		Dim As Panel pnlCommands
		Dim As CommandButton cmdOK, cmdCancel
	End Type
	
	Dim Shared pfImageManager As frmImageManager Ptr
	
'#End Region

#ifndef __USE_MAKE__
	#include once "frmImageManager.frm"
#endif
