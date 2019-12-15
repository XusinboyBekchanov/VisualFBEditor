'#########################################################
'#  frmAddIns.bas                                        #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (2018-2019)              #
'#########################################################

#Include Once "mff/Form.bi"
#Include Once "mff/ListView.bi"
#Include Once "mff/CommandButton.bi"
#Include Once "mff/Label.bi"
#Include Once "mff/TextBox.bi"
#Include Once "mff/GroupBox.bi"
#Include Once "mff/CheckBox.bi"
#Include Once "mff/Panel.bi"
#Include Once "Main.bi"

Using My.Sys.Forms

'#Region "Form"
	Type frmAddIns Extends Form
		Declare Static Sub cmdOK_Click(ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Static Sub Form_Click(ByRef Sender As Control)
		Declare Static Sub Form_Create(ByRef Sender As Control)
		Declare Static Sub chkLoaded_Click(ByRef Sender As CheckBox)
		Declare Static Sub chkLoadOnStartup_Click(ByRef Sender As CheckBox)
		Declare Static Sub Form_Close(ByRef Sender As Form, BYREF Action As Integer)
		Declare Static Sub lvAddIns_SelectedItemChanged(ByRef Sender As ListView, ItemIndex As Integer)
		Declare Static Sub Form_Show(ByRef Sender As Form)
		Declare Static Sub lvAddIns_ItemClick(ByRef Sender As ListView, ByVal ItemIndex As Integer)
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
End Type
Common Shared pAvailableAddIns As List Ptr

Declare Sub ConnectAddIn(AddIn As String)
Declare Sub DisconnectAddIn(AddIn As String)

#IfNDef __USE_MAKE__
	#Include Once "frmAddIns.bas"
#EndIf
