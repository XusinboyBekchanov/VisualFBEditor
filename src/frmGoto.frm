'#########################################################
'#  frmGoto.bas                                          #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (2018-2019)              #
'#########################################################

#include once "frmGoto.bi"

Dim Shared As frmGoto fGoto
pfGoto = @fGoto

'#Region "Form"
	Private Sub frmGoto._btnFind_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		With Me3
			.btnFind_Click(Sender)
		End With
	End Sub
	
	Private Sub frmGoto._btnCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Me3.btnCancel_Click(Sender)
	End Sub
	
	Private Sub frmGoto._Form_Show_(ByRef Designer As My.Sys.Object, ByRef Sender As Form)
		Me3.Form_Show(Sender)
	End Sub
	
	Constructor frmGoto
		This.Width = 320
		This.Height = 100
		#ifdef __USE_GTK__
			This.Icon.LoadFromFile(ExePath & "/Resources/VisualFBEditor.ico")
		#else
			This.Icon.LoadFromResourceID(1)
		#endif
		This.StartPosition = FormStartPosition.CenterParent
		lblFind.Caption = ML("Line") & ":"
		lblFind.SetBounds 10, 10, 80, 20
		lblFind.Parent = @This
		txtFind.SetBounds 90, 10, 203, 20
		txtFind.Anchor.Left = asAnchor
		txtFind.Anchor.Right = asAnchor
		txtFind.Parent = @This
		btnFind.Caption = ML("&Go")
		btnFind.Default = True
		btnFind.SetBounds 90, 36, 100, 20
		btnFind.Anchor.Right = asAnchor
		btnFind.Parent = @This
		btnCancel.Caption = ML("&Cancel")
		btnCancel.Anchor.Right = asAnchor
		btnCancel.SetBounds 194, 36, 100, 20
		btnCancel.Parent = @This
		'AddRange 10, @lblFind, @txtFind, @lblReplace, @txtReplace, @chkRegistr, @btnFind, @btnReplace, @btnFindAll, @btnReplaceAll, @btnCancel
		OnShow = @_Form_Show_
		btnFind.Text = ML("&Go")
		btnFind.OnClick = @_btnFind_Click_
		btnCancel.Text = ML("&Cancel")
		btnCancel.OnClick = @_btnCancel_Click_
		This.DefaultButton = @btnFind
		This.Caption = ML("Goto")
		This.CancelButton = @btnCancel
		'This.BorderStyle = 2
	End Constructor
	
	Destructor frmGoto
	
	End Destructor
'#End Region

Private Sub frmGoto.btnFind_Click(ByRef Sender As Control)
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	Dim txt As EditControl Ptr = @tb->txtCode
	If Val(txtFind.Text) <= 0 Then Exit Sub
	This.CloseForm
	txt->SetSelection Val(txtFind.Text) - 1, Val(txtFind.Text) - 1, 0, 0
	txt->SetFocus
End Sub

Private Sub frmGoto.btnCancel_Click(ByRef Sender As Control)
	This.CloseForm
End Sub

Private Sub frmGoto.Form_Show(ByRef Sender As Form)
	txtFind.SelectAll
	txtFind.SetFocus
End Sub
