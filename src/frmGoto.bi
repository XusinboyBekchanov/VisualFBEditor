'#########################################################
'#  frmGoto.bas                                          #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (2018-2019)              #
'#########################################################

#include once "mff/Form.bi"
#include once "mff/Label.bi"
#include once "mff/NumericUpDown.bi"
#include once "mff/CommandButton.bi"
#include once "TabWindow.bi"
#include once "mff/VerticalBox.bi"
#include once "mff/Panel.bi"

#define Me3 (*Cast(frmGoto Ptr, Sender.GetForm))

Using My.Sys.Forms

'#Region "Form"
	Type frmGoto Extends Form
		Declare Static Sub _Form_Show_(ByRef Designer As My.Sys.Object, ByRef Sender As Form)
		Declare Static Sub _btnFind_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub _btnCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Sub btnFind_Click(ByRef Sender As Control)
		Declare Sub btnCancel_Click(ByRef Sender As Control)
		Declare Constructor
		Declare Destructor
		
		Dim As Label lblFind
		Dim As NumericUpDown txtFind
		Dim As CommandButton btnFind, btnCancel
		Dim As VerticalBox VerticalBox1
		Dim As Panel Panel1, Panel2
	End Type
	
	Common Shared As frmGoto Ptr pfGoto
'#End Region

#ifndef __USE_MAKE__
	#include once "frmGoto.frm"
#endif
