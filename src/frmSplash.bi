'#########################################################
'#  frmSplash.bas                                        #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (2018-2019)              #
'#########################################################

#Include Once "mff\Form.bi"
#Include Once "mff\Label.bi"
#Include Once "mff\ImageBox.bi"

Using My.Sys.Forms

'#Region "Form"
	Type frmSplash Extends Form
		Declare Static Sub Form_Size(ByRef Sender As Form)
		Declare Static Sub Form_Show(ByRef Sender As Form)
		Declare Static Sub Form_Create(ByRef Sender As Control)
		Declare Constructor
		
		Dim As ImageBox lblImage
		Dim As Label lblSplash, lblInfo
	End Type
'#End Region

#IfNDef __USE_MAKE__
	#Include Once "frmSplash.bas"
#EndIf
