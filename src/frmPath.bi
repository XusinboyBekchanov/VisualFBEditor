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
		Declare Static Sub cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdOK_Click(ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Static Sub cmdPath_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdPath_Click(ByRef Sender As Control)
		Declare Static Sub Form_Show_(ByRef Designer As My.Sys.Object, ByRef Sender As Form)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Static Sub Form_Close_(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Static Sub _Form_Create(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Constructor
		
		Dim As CommandButton cmdPath, cmdOK, cmdCancel
		Dim As TextBox txtVersion, txtPath, txtCommandLine, txtExtensions
		Dim As Label lblVersion, lblPath, lblCommandLine, lblExtensions
		Dim As OpenFileDialog OpenD
		Dim As FolderBrowserDialog BrowseD
		Dim As Boolean ChooseFolder, SetFileNameToVersion, WithoutVersion, WithoutCommandLine, WithExtensions, WithType, WithKey, ForConfiguration
		Dim As UString ExeFileName
		Dim As ComboBoxEdit cboType
		Dim As UString cboTypeText, txtCommandLineText, txtExtensionsText
	End Type
	
	Common Shared pfPath As frmPath Ptr
	Common Shared pfPathImageList As frmPath Ptr
'#End Region

#ifndef __USE_MAKE__
	#include once "frmPath.frm"
#endif
