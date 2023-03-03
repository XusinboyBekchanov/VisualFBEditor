#include once "mff/Form.bi"
#include once "mff/ListView.bi"
#include once "mff/CommandButton.bi"
#include once "mff/Label.bi"
#include once "Main.bi"

Using My.Sys.Forms

'#Region "Form"
	Type frmTrek Extends Form
		Declare Static Sub cmdOK_Click(ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Static Sub lvTrek_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Static Sub Form_Show(ByRef Sender As Form)
		Declare Static Sub lvTrek_SelectedItemChanged(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Static Sub _Form_Create(ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Static Sub _Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Constructor
		
		Dim As ListView lvTrek
		Dim As CommandButton cmdOK
		Dim As CommandButton cmdCancel
		Dim As Label lblComment, lblLabelComment
		Dim As ListViewItem Ptr SelectedItem
	End Type
	
	Common Shared pfTrek As frmTrek Ptr
'#End Region

#ifndef __USE_MAKE__
	#include once "frmTrek.frm"
#endif
