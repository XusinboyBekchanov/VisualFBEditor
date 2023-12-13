'#########################################################
'#  frmParameters.bas                                    #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################
#include once "mff/Form.bi"
#include once "mff/GroupBox.bi"
#include once "mff/CommandButton.bi"
#include once "mff/Label.bi"
#include once "mff/TextBox.bi"
#include once "mff/ComboBoxEdit.bi"
#include once "mff/Panel.bi"

Using My.Sys.Forms

'#Region "Form"
	Type frmParameters Extends Form
		Declare Static Sub cmdOK_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub Form_Create(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub LoadSettings()
		Declare Static Sub Form_Show(ByRef Designer As My.Sys.Object, ByRef Sender As Form)
		Declare Sub lblAddCompilerOption32_Click(ByRef Sender As Label)
		Declare Sub lblAddCompilerOption64_Click(ByRef Sender As Label)
		Declare Constructor
		
		Dim As GroupBox grbCompile, grbMake, grbRun, grbDebug
		Dim As CommandButton cmdOK, cmdCancel
		Dim As Label lblfbc32, lblfbc64, lblMake1, llblMake2, lblRun, lblDebug32, lblDebug64
		Dim As TextBox txtfbc64, txtfbc32, txtMake1, txtMake2, txtRun, txtDebug32, txtDebug64
		Dim As ComboBoxEdit cboCompiler32, cboCompiler64, cboMake1, cboMake2, cboRun, cboDebug32, cboDebug64
		Dim As Label lblAddCompilerOption32, lblAddCompilerOption64
	End Type
	
	Common Shared pfParameters As frmParameters Ptr
'#End Region

#ifndef __USE_MAKE__
	#include once "frmParameters.frm"
#endif
