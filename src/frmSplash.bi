'#########################################################
'#  frmSplash.bas                                        #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (2018-2019)              #
'#########################################################

#include once "mff\Form.bi"
#include once "mff\Label.bi"
#include once "mff\ImageBox.bi"

Using My.Sys.Forms

'#Region "Form"
	Type frmSplash Extends Form
		Declare Static Sub lblImage_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub lblImage_Click(ByRef Sender As Control)
		Declare Static Sub lblProcess_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Label)
		Declare Sub lblProcess_Click(ByRef Sender As Label)
		Declare Constructor
		Dim As ImageBox lblImage
		Dim As Label lblSplash, lblInfo, lblProcess, lblSplash1
	End Type
	
	Common Shared As frmSplash Ptr pfSplash
'#End Region

#ifndef __USE_MAKE__
	#include once "frmSplash.frm"
#endif
 
