'#########################################################
'#  frmTools.bi                                          #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (2020)                   #
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
#include once "mff/ComboBoxEdit.bi"
#include once "mff/HotKey.bi"

Using My.Sys.Forms

'#Region "Form"
	Type frmTools Extends Form
		Declare Static Sub cmdOK_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub lvTools_SelectedItemChanged(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ItemIndex As Integer)
		Declare Static Sub lvTools_ItemClick(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Static Sub cmdAdd_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdChange_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdRemove_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub Form_Create(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub txtParameters_Change(ByRef Designer As My.Sys.Object, ByRef Sender As TextBox)
		Declare Static Sub txtWorkingFolder_Change(ByRef Designer As My.Sys.Object, ByRef Sender As TextBox)
		Declare Static Sub cboEvent_Change(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub hkShortcut_Change(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub chkWaitComplete_Click(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
		Declare Static Sub cmdMoveUp_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdMoveDown_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Constructor
		Declare Destructor
		
		Dim As ListView lvTools
		Dim As CommandButton cmdOK, cmdCancel, cmdHelp, cmdAdd, cmdChange, cmdRemove, cmdWorkingFolder, cmdMoveUp, cmdMoveDown
		Dim As Label lblParameters, lblInfo, lblWorkingFolder, lblTrigger, lblShortcut
		Dim As TextBox txtParameters, txtWorkingFolder
		Dim As ComboBoxEdit cboEvent
		Dim As HotKey hkShortcut
		Dim As CheckBox chkWaitComplete
	End Type
	
	Common Shared pfTools As frmTools Ptr
'#End Region

Enum LoadTypes
	OnlyOnUserSelected
	OnEditorStartup
	BeforeCompile
	AfterCompile
End Enum

Type UserToolType Extends ToolType
	WorkingFolder As UString
	Accelerator As String
	LoadType As LoadTypes
	WaitComplete As Boolean
	Declare Sub Execute()
End Type

#ifndef __USE_MAKE__
	#include once "frmTools.frm"
#endif
