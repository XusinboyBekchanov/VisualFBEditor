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
		Declare Static Sub Form_Show(ByRef Sender As Form)
		Declare Static Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Constructor
		
		Dim As CommandButton cmdPath, cmdOK, cmdCancel
		Dim As TextBox txtVersion, txtPath, txtCommandLine
		Dim As Label lblVersion, lblPath, lblCommandLine
		Dim As OpenFileDialog OpenD
		Dim As FolderBrowserDialog BrowseD
		Dim As Boolean ChooseFolder, SetFileNameToVersion
	End Type
	
	Common Shared pfPath As frmPath Ptr
'#End Region

#ifndef __USE_MAKE__
	#include once "frmPath.frm"
#endif
