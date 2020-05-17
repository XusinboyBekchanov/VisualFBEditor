'#########################################################
'#  frmAbout.bas                                         #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#Include Once "mff/Form.bi"
#Include Once "mff/CheckBox.bi"
#Include Once "mff/Label.bi"
#Include Once "mff/LinkLabel.bi"
#Include Once "mff/CommandButton.bi"
#Include Once "mff/RichTextBox.bi"
#Include Once "mff/ImageBox.bi"
#Include Once "Main.bi"

Using My.Sys.Forms

'#Region "Form"
	Type frmAbout Extends Form
		Declare Static Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Constructor
		
		Dim As Label Label1, lblInfo
		Dim As LinkLabel Label2
		Dim As CommandButton CommandButton1
		Dim As ImageBox lblIcon
	End Type
	
	Common Shared As frmAbout Ptr pfAbout
'#End Region

#IfNDef __USE_MAKE__
	#Include Once "frmAbout.bas"
#EndIf
