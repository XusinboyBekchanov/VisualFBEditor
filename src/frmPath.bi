'#########################################################
'#  frmPath.bi                                           #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#########################################################

#include once "mff/Form.bi"
#include once "mff/CommandButton.bi"
#include once "mff/TextBox.bi"
#include once "mff/Label.bi"
#include once "Main.bi"

Using My.Sys.Forms

'#Region "Form"
	Type frmPath Extends Form
		Declare Static Sub cmdOK_Click(ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Static Sub cmdPath_Click(ByRef Sender As Control)
		Declare Constructor
		
		Dim As CommandButton cmdPath, cmdOK, cmdCancel
		Dim As TextBox txtVersion, txtPath
		Dim As Label lblVersion, lblPath
		Dim As OpenFileDialog OpenD
	End Type
	
	Common Shared pfPath As frmPath Ptr
'#End Region

#ifndef __USE_MAKE__
	#include once "frmPath.bas"
#endif
