'#########################################################
'#  frmFind.bi                                           #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "mff/Form.bi"
#include once "mff/Label.bi"
#include once "mff/TextBox.bi"
#include once "mff/ComboBoxEdit.bi"
#include once "mff/CheckBox.bi"
#include once "mff/CommandButton.bi"
#include once "mff/TrackBar.bi"
#include once "mff/Label.bi"
#include once "mff/RadioButton.bi"
#include once "TabWindow.bi"

Using My.Sys.Forms

'#Region "Form"
	Type frmFind Extends Form
	Private:
		Dim As Integer iStartLine, iStartChar, iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		Dim As WString * MAX_PATH FFileName
	Public:
		Declare Function Find(Down As Boolean, bNotShowResults As Boolean = False) As Integer
		Declare Function FindAll(ByRef lvSearchResult As ListView Ptr, tTab As TabPage Ptr = tpFind, ByRef tSearch As WString = "", bNotShowResults As Boolean = False) As Integer
		Declare Sub btnCancel_Click(ByRef Sender As Control)
		Declare Sub btnFind_Click(ByRef Sender As Control)
		Declare Sub btnFindAll_Click(ByRef Sender As Control)
		Declare Sub btnFindPrev_Click(ByRef Sender As Control)
		Declare Sub btnReplace_Click(ByRef Sender As Control)
		Declare Sub btnReplaceAll_Click(ByRef Sender As Control)
		Declare Sub btnReplaceShow_Click(ByRef Sender As Control)
		Declare Sub cboFindRange_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub chkBox_Click(ByRef Sender As CheckBox)
		Declare Sub FindInProj(ByRef lvSearchResult As ListView Ptr, ByRef tSearch As WString="", ByRef tn As TreeNode Ptr)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Sub ReplaceInProj(ByRef tSearch As WString="", ByRef tReplace As WString="", ByRef tn As TreeNode Ptr)
		Declare Sub TrackBar1_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Constructor
		Declare Destructor
		
		Dim As CheckBox chkMatchCase, chkMatchWholeWords, chkUsePatternMatching
		Dim As Label lblFind, lblTrack, lblReplace
		Dim As ComboBoxEdit txtFind, txtReplace, cboFindRange
		Dim As CommandButton btnCancel, btnFind, btnFindPrev, btnReplaceAll, btnReplace, btnReplaceShow, btnFindAll
		Dim As TrackBar TrackBar1
		As Boolean mFormFind = True
	End Type
	Common Shared As frmFind Ptr pfFind
'#End Region
Declare Sub FindSubProj(Param As Any Ptr)
Declare Sub ReplaceSubProj(Param As Any Ptr)

#ifndef __USE_MAKE__
	#include once "frmFind.frm"
#endif

