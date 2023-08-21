'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/ToolBar.bi"
	#include once "mff/ListView.bi"
	#include once "mff/GroupBox.bi"
	#include once "mff/ImageBox.bi"
	#include once "mff/Splitter.bi"
	#include once "mff/Panel.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Label.bi"
	#include once "mff/ImageList.bi"
	#include once "mff/TextBox.bi"

	Using My.Sys.Forms
	
	Type frmPathP As frmPath Ptr
	
	Type frmImageManager Extends Form
		Declare Static Sub Form_Show_(ByRef Designer As My.Sys.Object, ByRef Sender As Form)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Static Sub cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Static Sub cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdOK_Click(ByRef Sender As Control)
		Declare Static Sub lvImages_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub lvImages_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Static Sub lvImages_SelectedItemChanged_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub lvImages_SelectedItemChanged(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Static Sub tbToolbar_ButtonClick_(ByRef Designer As My.Sys.Object, ByRef Sender As ToolBar, ByRef Button As ToolButton)
		Declare Sub tbToolbar_ButtonClick(ByRef Sender As ToolBar,ByRef Button As ToolButton)
		Declare Static Sub Form_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Static Sub optCustom_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton)
		Declare Sub optCustom_Click(ByRef Sender As RadioButton)
		Declare Static Sub opt16x16_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton)
		Declare Sub opt16x16_Click(ByRef Sender As RadioButton)
		Declare Static Sub opt32x32_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton)
		Declare Sub opt32x32_Click(ByRef Sender As RadioButton)
		Declare Static Sub opt48x48_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton)
		Declare Sub opt48x48_Click(ByRef Sender As RadioButton)
		Declare Static Sub MenuItemClick_(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Object)
		Declare Sub MenuItemClick(ByRef Sender As My.Sys.Object)
		Declare Constructor
		
		Dim As ToolBar tbToolbar
		Dim As ListView lvImages
		Dim As GroupBox gbImagePreview
		Dim As ImageBox imgImage
		Dim As Splitter Splitter1
		Dim As Panel pnlCommands, pnlOptions
		Dim As CommandButton cmdOK, cmdCancel
		Dim As Label lblResourceFile, lblSize, lblWidth, lblHeight
		Dim As RadioButton opt16x16, opt32x32, opt48x48, optCustom
		Dim As UString ResourceFile, ExeFileName
		Dim As Boolean WithoutMainNode, OnlyIcons
		Dim As ImageList ImageList1
		Dim As ImageList Ptr CurrentImageList
		Dim As TabWindow Ptr tb
		Dim As My.Sys.Forms.Designer Ptr Des
		Dim As frmPathP pfrmPath
		Dim As TextBox txtWidth, txtHeight
		Dim As ListViewItem Ptr SelectedItem
		Dim As List SelectedItems
	End Type
	
	Dim Shared pfImageManager As frmImageManager Ptr
	Dim Shared pfImageListEditor As frmImageManager Ptr
'#End Region

#ifndef __USE_MAKE__
	#include once "frmImageManager.frm"
#endif
