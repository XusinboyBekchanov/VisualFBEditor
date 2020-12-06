'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/TabControl.bi"
	#include once "mff/TreeView.bi"
	#include once "mff/ListView.bi"
	#include once "mff/CommandButton.bi"
	
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
		Declare Constructor
		
		Dim As TabControl TabControl1
		Dim As TabPage tpNew
		Dim As TreeView tvTemplates
		Dim As ListView lvTemplates
		Dim As CommandButton cmdOK, cmdCancel
		Dim As WStringList Templates
	End Type
	
	Common Shared pfTemplates As frmTemplates Ptr
'#End Region

#ifndef __USE_MAKE__
	#include once "frmTemplates.frm"
#endif
