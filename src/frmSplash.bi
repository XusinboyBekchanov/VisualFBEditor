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
		Declare Constructor
		
		Dim As ImageBox lblImage
		Dim As Label lblSplash, lblInfo, lblProcess
	End Type
	
	Common Shared As frmSplash Ptr pfSplash
'#End Region

#ifndef __USE_MAKE__
	#include once "frmSplash.frm"
#endif
