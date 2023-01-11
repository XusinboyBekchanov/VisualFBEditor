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
		Declare Static Sub Form_Show_(ByRef Sender As Form)
		Declare Static Sub Form_Close_(ByRef Sender As Control, ByRef Action As Integer)
		Declare Static Sub Form_Create_(ByRef Sender As Control)
		Declare Static Sub btnFind_Click_(ByRef Sender As Control)
		Declare Static Sub btnFindAll_Click_(ByRef Sender As Control)
		Declare Static Sub btnFindPrev_Click_(ByRef Sender As Control)
		Declare Static Sub btnReplace_Click_(ByRef Sender As Control)
		Declare Static Sub btnReplaceAll_Click_(ByRef Sender As Control)
		Declare Static Sub btnReplaceShow_Click_(ByRef Sender As Control)
		Declare Static Sub btnCancel_Click_(ByRef Sender As Control)
		Declare Static Sub TrackBar1_Change_(ByRef Sender As TrackBar, Position As Integer)
		Declare Static Sub cboFindRange_Selected_(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Sub Form_Close(ByRef Sender As Control, ByRef Action As Integer)
		Declare Sub btnFind_Click(ByRef Sender As Control)
		Declare Function FindAll(ByRef lvSearchResult As ListView Ptr, tTab As TabPage Ptr = tpFind, ByRef tSearch As WString = "", bNotShowResults As Boolean = False) As Integer
		Declare Sub FindInProj(ByRef lvSearchResult As ListView Ptr, ByRef tSearch As WString="", ByRef tn As TreeNode Ptr)
		Declare Sub ReplaceInProj(ByRef tSearch As WString="", ByRef tReplace As WString="", ByRef tn As TreeNode Ptr)
		Declare Sub btnFindPrev_Click(ByRef Sender As Control)
		Declare Sub btnReplace_Click(ByRef Sender As Control)
		Declare Sub btnReplaceAll_Click(ByRef Sender As Control)
		Declare Sub btnReplaceShow_Click(ByRef Sender As Control)
		Declare Sub btnCancel_Click(ByRef Sender As Control)
		Declare Function Find(Down As Boolean, bNotShowResults As Boolean = False) As Integer
		Declare Sub TrackBar1_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Sub btnFindAll_Click(ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub cboFindRange_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Constructor
		Declare Destructor

		Dim As CheckBox chkMatchCase, chkMatchWholeWords, chkUsePatternMatching
		Dim As Label lblFind, lblTrack, lblReplace
		Dim As ComboBoxEdit txtFind, txtReplace, cboFindRange
		Dim As CommandButton btnCancel, btnFind, btnFindPrev, btnReplaceAll, btnReplace, btnReplaceShow, btnFindAll
		Dim As TrackBar TrackBar1
		Dim As Integer ActionReplace
	End Type
	Common Shared As frmFind Ptr pfFind
'#End Region
Declare Sub FindSubProj(Param As Any Ptr)
Declare Sub ReplaceSubProj(Param As Any Ptr)

#ifndef __USE_MAKE__
	#include once "frmFind.frm"
#endif
 
