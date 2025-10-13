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
		With This
			.Name = "frmGoto"
			.Caption = ML("Goto")
			#ifdef __USE_GTK__
				.Icon.LoadFromFile(ExePath & "/Resources/VisualFBEditor.ico")
			#else
				.Icon.LoadFromResourceID(1)
			#endif
			.MinimizeBox = False
			.MaximizeBox = False
			.OnShow = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form), @Form_Show)
			.DefaultButton = @btnFind
			.CancelButton = @btnCancel
			.Designer = @This
			.BorderStyle = FormBorderStyle.FixedToolWindow
			.SetBounds 0, 0, 243, 95
		End With
		
		With lblFind
			.Caption = ML("Line") & ":"
			.Align = DockStyle.alLeft
			.CenterImage = True
			.ID = 1095
			.SetBounds 5, 0, 74, 20
			.Parent = @Panel1
		End With
		
		With txtFind
			.Name = "txtFind"
			.Align = DockStyle.alClient
			.SetBounds 70, 0, 210, 20
			.Anchor.Left = AnchorStyle.asNone
			.Anchor.Right = AnchorStyle.asNone
			.Parent = @Panel1
			.Designer = @This
		End With
		
		With btnCancel
			.Caption = ML("&Cancel")
			.Anchor.Right = AnchorStyle.asNone
			.Align = DockStyle.alRight
			.ExtraMargins.Left = 10
			.SetBounds 184, 0, 100, 20
			.Parent = @Panel2
			.Designer = @This
			.Text = ML("&Cancel")
			.OnClick = @_btnCancel_Click_
		End With
		
		With btnFind
			.Caption = ML("&Go")
			.Default = True
			.Align = DockStyle.alRight
			.SetBounds 74, 0, 100, 20
			.Anchor.Right = AnchorStyle.asNone
			.Designer = @This
			.Parent = @Panel2
			.Text = ML("&Go")
			.OnClick = @_btnFind_Click_
		End With
		' VerticalBox1
		With VerticalBox1
			.Name = "VerticalBox1"
			.Text = "VerticalBox1"
			.TabIndex = 5
			.Align = DockStyle.alTop
			.BorderStyle = BorderStyles.bsNone
			.SetBounds 0, 0, 227, 50
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