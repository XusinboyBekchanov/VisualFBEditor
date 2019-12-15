'#########################################################
'#  frmGoto.bas                                          #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (2018-2019)              #
'#########################################################

#Include Once "mff/Form.bi"
#Include Once "mff/Label.bi"
#Include Once "mff/TextBox.bi"
#Include Once "mff/CommandButton.bi"
#Include Once "TabWindow.bi"

#Define Me3 *Cast(frmGoto Ptr, Sender.GetForm)

Using My.Sys.Forms

'#Region "Form"
	Type frmGoto Extends Form
		Declare Static Sub _Form_Show_(ByRef Sender As Form)
		Declare Static Sub _btnFind_Click_(ByRef Sender As Control)
		Declare Static Sub _btnCancel_Click_(ByRef Sender As Control)
		
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Sub btnFind_Click(ByRef Sender As Control)
		Declare Sub btnCancel_Click(ByRef Sender As Control)
		Declare Constructor
		Declare Destructor
		
		Dim As Label lblFind
		Dim As TextBox txtFind
		Dim As CommandButton btnFind, btnCancel
	End Type
	
	Common Shared As frmGoto Ptr pfGoto
'#End Region

#IfNDef __USE_MAKE__
	#Include Once "frmGoto.bas"
#EndIf
