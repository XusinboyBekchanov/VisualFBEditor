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

Using My.Sys.Forms

'#Region "Form"
	Type frmTools Extends Form
		Declare Static Sub cmdOK_Click(ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Static Sub Form_Click(ByRef Sender As Control)
		Declare Static Sub Form_Create(ByRef Sender As Control)
		Declare Static Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Static Sub lvAddIns_SelectedItemChanged(ByRef Sender As ListView, ItemIndex As Integer)
		Declare Static Sub Form_Show(ByRef Sender As Form)
		Declare Static Sub lvAddIns_ItemClick(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Constructor
		Declare Destructor
		
		Dim As ListView lvTools
		Dim As CommandButton cmdOK, cmdCancel, cmdHelp
	End Type
	
	Common Shared pfTools As frmTools Ptr
'#End Region

Enum LoadTypes
	UserSelectOnly
End Enum

Type ToolType
	Name As UString
	Path As UString
	Parameters As UString
	WorkingFolder As UString
	Accelerator As String
	LoadType As LoadTypes
	WaitComplete As Boolean
	Declare Sub Execute()
	Declare Destructor
End Type

#ifndef __USE_MAKE__
	#include once "frmTools.bas"
#endif
