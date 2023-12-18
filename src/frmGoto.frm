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
		This.Name = "frmGoto"
		This.Width = 320
		This.Height = 100
		#ifdef __USE_GTK__
			This.Icon.LoadFromFile(ExePath & "/Resources/VisualFBEditor.ico")
		#else
			This.Icon.LoadFromResourceID(1)
		#endif
		This.StartPosition = FormStartPosition.CenterParent
		lblFind.Caption = ML("Line") & ":"
		lblFind.Align = DockStyle.alLeft
		lblFind.CenterImage = True
		lblFind.ID = 1095
		lblFind.SetBounds 65180, 0, 74, 20
		lblFind.Parent = @Panel1
		txtFind.Name = "txtFind"
		txtFind.Align = DockStyle.alClient
		txtFind.SetBounds 65254, 0, 210, 20
		txtFind.Anchor.Left = AnchorStyle.asNone
		txtFind.Anchor.Right = AnchorStyle.asNone
		txtFind.Parent = @Panel1
		btnCancel.Caption = ML("&Cancel")
		btnCancel.Anchor.Right = AnchorStyle.asNone
		btnCancel.Align = DockStyle.alRight
		btnCancel.ExtraMargins.Left = 10
		btnCancel.SetBounds 184, 0, 100, 20
		btnCancel.Parent = @Panel2
		'AddRange 10, @lblFind, @txtFind, @lblReplace, @txtReplace, @chkRegistr, @btnFind, @btnReplace, @btnFindAll, @btnReplaceAll, @btnCancel
		OnShow = @_Form_Show_
		btnCancel.Text = ML("&Cancel")
		btnCancel.OnClick = @_btnCancel_Click_
		btnFind.Caption = ML("&Go")
		btnFind.Default = True
		btnFind.Align = DockStyle.alRight
		btnFind.SetBounds 74, 0, 100, 20
		btnFind.Anchor.Right = AnchorStyle.asNone
		btnFind.Parent = @Panel2
		btnFind.Text = ML("&Go")
		btnFind.OnClick = @_btnFind_Click_
		This.DefaultButton = @btnFind
		This.Caption = ML("Goto")
		This.Margins.Top = 10
		This.Margins.Right = 10
		This.Margins.Left = 10
		This.Margins.Bottom = 10
		This.AutoSize = True
		This.CancelButton = @btnCancel
		'This.BorderStyle = 2
		' VerticalBox1
		With VerticalBox1
			.Name = "VerticalBox1"
			.Text = "VerticalBox1"
			.TabIndex = 5
			.Align = DockStyle.alTop
			.SetBounds 0, 0, 304, 20
			.Designer = @This
			.Parent = @This
		End With
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = "Panel1"
			.TabIndex = 6
			.AutoSize = True
			.Align = DockStyle.alTop
			.SetBounds 0, 0, 284, 20
			.Designer = @This
			.Parent = @VerticalBox1
		End With
		' Panel2
		With Panel2
			.Name = "Panel2"
			.Text = "Panel2"
			.TabIndex = 7
			.Align = DockStyle.alTop
			.ExtraMargins.Top = 10
			.AutoSize = True
			.SetBounds 0, 20, 284, 20
			.Designer = @This
			.Parent = @VerticalBox1
		End With
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
