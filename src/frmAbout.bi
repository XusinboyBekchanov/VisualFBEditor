'#########################################################
'#  frmAbout.bi                                         #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "mff/Form.bi"
#include once "mff/CheckBox.bi"
#include once "mff/Label.bi"
#include once "mff/LinkLabel.bi"
#include once "mff/CommandButton.bi"
#include once "mff/RichTextBox.bi"
#include once "mff/ImageBox.bi"
#include once "Main.bi"
#include once "mff/Picture.bi"

Using My.Sys.Forms

'#Region "Form"
	Type frmAbout Extends Form
		Declare Static Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Static Sub lblImage_Click(ByRef Sender As ImageBox)
		Declare Static Sub Label2_LinkClicked(ByRef Sender As LinkLabel, ByVal ItemIndex As Integer, ByRef Link1 As WString, ByRef Action As Integer)
		Declare Constructor
		
		Dim As Label Label1, lblInfo
		Dim As LinkLabel Label2
		Dim As CommandButton CommandButton1
		Dim As ImageBox imgIcon, imgQRCode
	End Type
	
	Common Shared As frmAbout Ptr pfAbout
'#End Region

#ifndef __USE_MAKE__
	#include once "frmAbout.bas"
#endif
