'#########################################################
'#  frmPath.bi                                           #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#########################################################

#include once "mff/Form.bi"
#include once "mff/CommandButton.bi"
#include once "mff/TextBox.bi"
#include once "mff/Label.bi"
#include once "mff/ComboBoxEdit.bi"
#include once "Main.bi"

Using My.Sys.Forms

'#Region "Form"
	Type frmPath Extends Form
		Declare Static Sub cmdOK_Click_(ByRef Sender As Control)
		Declare Sub cmdOK_Click(ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click_(ByRef Sender As Control)
		Declare Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Static Sub cmdPath_Click_(ByRef Sender As Control)
		Declare Sub cmdPath_Click(ByRef Sender As Control)
		Declare Static Sub Form_Show_(ByRef Sender As Form)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Static Sub Form_Close_(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Constructor
		
		Dim As CommandButton cmdPath, cmdOK, cmdCancel
		Dim As TextBox txtVersion, txtPath, txtCommandLine, txtExtensions
		Dim As Label lblVersion, lblPath, lblCommandLine, lblExtensions
		Dim As OpenFileDialog OpenD
		Dim As FolderBrowserDialog BrowseD
		Dim As Boolean ChooseFolder, SetFileNameToVersion, WithoutCommandLine, WithExtensions, WithType, WithKey
		Dim As UString ExeFileName
		Dim As ComboBoxEdit cboType
	End Type
	
	Common Shared pfPath As frmPath Ptr
	Common Shared pfPathImageList As frmPath Ptr
'#End Region

#ifndef __USE_MAKE__
	#include once "frmPath.frm"
#endif
