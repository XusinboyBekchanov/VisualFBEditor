'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/TabControl.bi"
	#include once "mff/TreeView.bi"
	#include once "mff/ListView.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/OpenFileControl.bi"
	#include once "mff/Panel.bi"
	
	Using My.Sys.Forms
	
	Type frmTemplates Extends Form
		Declare Static Sub cmdCancel_Click_(ByRef Sender As Control)
		Declare Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Static Sub cmdOK_Click_(ByRef Sender As Control)
		Declare Sub cmdOK_Click(ByRef Sender As Control)
		Declare Static Sub tvTemplates_SelChanged_(ByRef Sender As TreeView, ByRef Item As TreeNode)
		Declare Sub tvTemplates_SelChanged(ByRef Sender As TreeView, ByRef Item As TreeNode)
		Declare Static Sub Form_Create_(ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Static Sub lvTemplates_ItemActivate_(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub lvTemplates_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Static Sub Form_Show_(ByRef Sender As Form)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Static Sub Form_Close_(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Static Sub tvRecent_SelChanged_(ByRef Sender As TreeView, ByRef Item As TreeNode)
		Declare Sub tvRecent_SelChanged(ByRef Sender As TreeView, ByRef Item As TreeNode)
		Declare Static Sub lvRecent_ItemActivate_(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub lvRecent_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Static Sub OpenFileControl1_FileActivate_(ByRef Sender As OpenFileControl)
		Declare Sub OpenFileControl1_FileActivate(ByRef Sender As OpenFileControl)
		Declare Constructor
		
		Dim As TabControl TabControl1
		Dim As TabPage tpNew, tpExisting, tpRecent
		Dim As TreeView tvTemplates, tvRecent
		Dim As ListView lvTemplates, lvRecent
		Dim As CommandButton cmdOK, cmdCancel
		Dim As WStringList Templates
		Dim As Boolean OnlyFiles
		Dim As UString SelectedTemplate, SelectedFile
		Dim As OpenFileControl OpenFileControl1
		Dim As Panel pnlBottom
	End Type
	
	Common Shared pfTemplates As frmTemplates Ptr
'#End Region

#ifndef __USE_MAKE__
	#include once "frmTemplates.frm"
#endif
