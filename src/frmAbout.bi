'#########################################################
'#  frmAbout.bi                                         #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include Once "mff/Form.bi"
#include Once "mff/CheckBox.bi"
#include Once "mff/Label.bi"
#include Once "mff/LinkLabel.bi"
#include Once "mff/CommandButton.bi"
#include Once "mff/RichTextBox.bi"
#include Once "mff/ImageBox.bi"
#include Once "Main.bi"
#include Once "mff/Picture.bi"

Using My.Sys.Forms

'#Region "Form"
	Type frmAbout Extends Form
		Declare Static Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Static Sub lblImage_Click(ByRef Sender As ImageBox)
		Declare Constructor

		Dim As Label Label1, lblInfo
		Dim As LinkLabel Label2
		Dim As CommandButton CommandButton1
		Dim As ImageBox lblIcon
		Dim As ImageBox lblImage
	End Type

	Common Shared As frmAbout Ptr pfAbout
'#End Region

#ifndef __USE_MAKE__
	#include Once "frmAbout.bas"
#endif
