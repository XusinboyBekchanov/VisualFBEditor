'#########################################################
'#  frmFindInFiles.bas                                   #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "mff/Form.bi"
#include once "mff/Label.bi"
#include once "mff/TextBox.bi"
#include once "mff/CheckBox.bi"
#include once "mff/CommandButton.bi"
#include once "mff/Dialogs.bi"
#include once "dir.bi"
#include once "TabWindow.bi"
#include once "mff/Panel.bi"

Using My.Sys.Forms

'#Region "Form"
	Type frmFindInFiles Extends Form
		Declare Static Sub _Form_Show_(ByRef Designer As My.Sys.Object, ByRef Sender As Form)
		Declare Static Sub _Form_Close_(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer)
		Declare Static Sub _btnFind_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub _btnCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub btnBrowse_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub btnFind_Click(ByRef Sender As Control)
		Declare Sub btnCancel_Click(ByRef Sender As Control)
		Declare Sub FindSub(Param As Any Ptr)
		Declare Sub ReplaceSub(Param As Any Ptr)
		Declare Sub Find(ByRef lvSearchResult As ListView Ptr,ByRef Path As WString,ByRef Search As WString="")
		Declare Sub ReplaceInFile(ByRef Path As WString ="", ByRef tSearch As WString="", ByRef tReplace As WString="")
		Declare Static Sub btnReplace_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub Form_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Static Sub _Form_Create(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Constructor
		Declare Destructor
		
		Dim As CheckBox chkMatchCase, chkSearchInSub, chkUsePatternMatching, chkWholeWordsOnly
		Dim As Label lblFind, lblReplace
		Dim As TextBox txtFind, txtReplace, txtPath
		Dim As Label lblPath
		Dim As CommandButton btnFind, btnBrowse, btnCancel, btnReplace
		Dim As FolderBrowserDialog FolderDialog
		
		Dim As Panel Panel1
	End Type
	Common Shared As frmFindInFiles Ptr pfFindFile
'#End Region

Declare Sub FindSub(Param As Any Ptr)
Declare Sub FindInFiles()
Declare Sub ReplaceSub(Param As Any Ptr)
Declare Sub ReplaceInFiles()

#ifndef __USE_MAKE__
	#include once "frmFindInFiles.frm"
#endif
