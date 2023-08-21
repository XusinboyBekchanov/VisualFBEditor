'#########################################################
'#  frmTheme.bi                                          #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "mff/Form.bi"
#include once "mff/Label.bi"
#include once "mff/TextBox.bi"
#include once "mff/CommandButton.bi"

Using My.Sys.Forms

'#Region "Form"
	Type frmTheme Extends Form
		Declare Static Sub cmdOK_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Constructor
		
		Dim As Label lblThemeName
		Dim As TextBox txtThemeName
		Dim As CommandButton cmdOK, cmdCancel
	End Type
	
	Common Shared pfTheme As frmTheme Ptr
'#End Region

#ifndef __USE_MAKE__
	#include once "frmTheme.frm"
#endif
