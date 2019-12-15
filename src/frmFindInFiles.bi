'#########################################################
'#  frmFindInFiles.bas                                   #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (2018-2019)              #
'#########################################################

#Include Once "mff/Form.bi"
#Include Once "mff/Label.bi"
#Include Once "mff/TextBox.bi"
#Include Once "mff/CheckBox.bi"
#Include Once "mff/CommandButton.bi"
#Include Once "mff/Dialogs.bi"
#Include Once "dir.bi"
#Include Once "TabWindow.bi"

Using My.Sys.Forms

'#Region "Form"
	Type frmFindInFiles Extends Form
		Declare Static Sub _Form_Show_(ByRef Sender As Form)
		Declare Static Sub _Form_Close_(ByRef Sender As Form, BYREF Action As Integer)
		Declare Static Sub _btnFind_Click_(ByRef Sender As Control)
		Declare Static Sub _btnCancel_Click_(ByRef Sender As Control)
		Declare Static Sub btnBrowse_Click(ByRef Sender As Control)
		
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Sub Form_Close(ByRef Sender As Form, BYREF Action As Integer)
		Declare Sub btnFind_Click(ByRef Sender As Control)
		Declare Sub btnCancel_Click(ByRef Sender As Control)
		Declare Sub Find(ByRef Path As WString)
		Declare Constructor
		Declare Destructor
		
		Dim As CheckBox chkRegistr, chkRecursive
		Dim As Label lblFind
		Dim As TextBox txtFind
		Dim As Label lblPath
		Dim As TextBox txtPath
		Dim As CommandButton btnFind, btnBrowse, btnCancel
		Dim As FolderBrowserDialog FolderDialog
	End Type
	
	Common Shared As frmFindInFiles Ptr pfFindFile
'#End Region

Declare Sub FindSub(Param As Any Ptr)
Declare Sub FindInFiles()

#IfNDef __USE_MAKE__
	#Include Once "frmFindInFiles.bas"
#EndIf
