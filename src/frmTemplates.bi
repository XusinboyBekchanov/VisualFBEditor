'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/TabControl.bi"
	#include once "mff/TreeView.bi"
	#include once "mff/ListView.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/OpenFileControl.bi"
	#include once "mff/Panel.bi"
	#include once "mff/Label.bi"
	#include once "mff/TextBox.bi"
	
	Using My.Sys.Forms
	
	Type frmTemplates Extends Form
		Declare Static Sub cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Static Sub cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdOK_Click(ByRef Sender As Control)
		Declare Static Sub tvTemplates_SelChanged_(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode)
		Declare Sub tvTemplates_SelChanged(ByRef Sender As TreeView, ByRef Item As TreeNode)
		Declare Static Sub _Form_Create(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Static Sub lvTemplates_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub lvTemplates_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Static Sub Form_Show_(ByRef Designer As My.Sys.Object, ByRef Sender As Form)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Static Sub Form_Close_(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Static Sub tvRecent_SelChanged_(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode)
		Declare Sub tvRecent_SelChanged(ByRef Sender As TreeView, ByRef Item As TreeNode)
		Declare Static Sub lvRecent_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub lvRecent_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Static Sub OpenFileControl1_FileActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As OpenFileControl)
		Declare Sub OpenFileControl1_FileActivate(ByRef Sender As OpenFileControl)
		Declare Static Sub TabControl1_SelChange_(ByRef Designer As My.Sys.Object, ByRef Sender As TabControl, NewIndex As Integer)
		Declare Sub TabControl1_SelChange(ByRef Sender As TabControl, NewIndex As Integer)
		Declare Static Sub cmdSaveLocation_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdSaveLocation_Click(ByRef Sender As Control)
		Declare Static Sub lvTemplates_SelectedItemChanged_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub lvTemplates_SelectedItemChanged(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Static Sub cmdClear_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdClear_Click(ByRef Sender As Control)
		Declare Static Sub cmdRemove_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdRemove_Click(ByRef Sender As Control)
		Declare Static Sub cmdChange_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdChange_Click(ByRef Sender As Control)
		Declare Static Sub cmdAdd_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdAdd_Click(ByRef Sender As Control)
		Declare Constructor
		
		Dim As TabControl TabControl1
		Dim As TabPage tpNew, tpExisting, tpRecent
		Dim As TreeView tvTemplates, tvRecent
		Dim As ListView lvTemplates, lvRecent
		Dim As CommandButton cmdOK, cmdCancel, cmdSaveLocation, cmdClear, cmdRemove, cmdChange, cmdAdd
		Dim As WStringList Templates
		Dim As Boolean OnlyFiles, RecentChanged
		Dim As UString SelectedTemplate, SelectedFile, SelectedFolder
		Dim As OpenFileControl OpenFileControl1
		Dim As Panel pnlBottom, pnlSaveLocation, pnlRecent
		Dim As Label lblSaveLocation
		Dim As TextBox txtSaveLocation
	End Type
	
	Common Shared pfTemplates As frmTemplates Ptr
'#End Region

#ifndef __USE_MAKE__
	#include once "frmTemplates.frm"
#endif
