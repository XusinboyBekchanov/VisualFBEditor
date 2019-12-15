'#########################################################
'#  frmFind.bi                                          #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (2018-2019)              #
'#########################################################

#Include Once "mff/Form.bi"
#Include Once "mff/Label.bi"
#Include Once "mff/TextBox.bi"
#Include Once "mff/CheckBox.bi"
#Include Once "mff/CommandButton.bi"
#Include Once "mff/TrackBar.bi"
#Include Once "mff/Label.bi"
#Include Once "TabWindow.bi"

#Define Me *Cast(frmFind Ptr, Sender.GetForm)

Using My.Sys.Forms

'#Region "Form"
	Type frmFind Extends Form
		Declare Static Sub _Form_Show_(ByRef Sender As Form)
		Declare Static Sub _Form_Close_(ByRef Sender As Form, BYREF Action As Integer)
		Declare Static Sub _btnFind_Click_(ByRef Sender As Control)
		Declare Static Sub _btnFindAll_Click_(ByRef Sender As Control)
		Declare Static Sub _btnCancel_Click_(ByRef Sender As Control)
		
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Sub Form_Close(ByRef Sender As Form, BYREF Action As Integer)
		Declare Sub btnFind_Click(ByRef Sender As Control)
		Declare Sub btnFindAll_Click(ByRef Sender As Control)
		Declare Sub btnCancel_Click(ByRef Sender As Control)
		Declare Function Find(Down As Boolean, bNotShowResults As Boolean = False) As Integer
		Declare Static Sub TrackBar1_Change(BYREF Sender As TrackBar,Position As Integer)
		Declare Constructor
		Declare Destructor
		
		Dim As CheckBox chkRegistr
		Dim As Label lblFind, lblTrack
		Dim As TextBox txtFind
		Dim As CommandButton btnFind, btnFindAll, btnCancel
		Dim As TrackBar TrackBar1
	End Type
	
	Common Shared As frmFind Ptr pfFind
'#End Region

#IfNDef __USE_MAKE__
	#Include Once "frmFind.bas"
#EndIf
