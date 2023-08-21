'#########################################################
'#  frmAddIns.bas                                        #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (2018-2019)              #
'#########################################################

#include once "mff/Form.bi"
#include once "mff/ListView.bi"
#include once "mff/CommandButton.bi"
#include once "mff/Label.bi"
#include once "mff/TextBox.bi"
#include once "mff/GroupBox.bi"
#include once "mff/CheckBox.bi"
#include once "mff/Panel.bi"
#include once "Main.bi"

Using My.Sys.Forms

'#Region "Form"
	Type frmAddIns Extends Form
		Declare Static Sub cmdOK_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub Form_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub Form_Create(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub chkLoaded_Click(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
		Declare Static Sub chkLoadOnStartup_Click(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
		Declare Static Sub Form_Close(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer)
		Declare Static Sub lvAddIns_SelectedItemChanged(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ItemIndex As Integer)
		Declare Static Sub Form_Show(ByRef Designer As My.Sys.Object, ByRef Sender As Form)
		Declare Static Sub lvAddIns_ItemClick(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Constructor
		Declare Destructor
		
		Dim As ListView lvAddIns
		Dim As CommandButton cmdOK, cmdCancel, cmdHelp
		Dim As Label lblDescription
		Dim As TextBox txtDescription
		Dim As GroupBox grbLoadBehavior
		Dim As CheckBox chkLoaded, chkLoadOnStartup
		Dim As Panel pnlLoadBehavior
	End Type
	
	Common Shared pfAddIns As frmAddIns Ptr
'#End Region

Type AddInType
	Loaded As Boolean
	LoadedOriginal As Boolean
	LoadOnStartup As Boolean
	LoadOnStartupINI As Boolean
	Description As WString Ptr
	Path As WString Ptr
	Declare Destructor
End Type
Common Shared pAvailableAddIns As List Ptr

Declare Sub ConnectAddIn(AddIn As String)
Declare Sub DisconnectAddIn(AddIn As String)

#ifndef __USE_MAKE__
	#include once "frmAddIns.frm"
#endif
