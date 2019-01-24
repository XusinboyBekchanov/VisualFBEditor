'Compile with -g -s console "SI FreeBasic.rc"
#Include Once "mff/Form.bi"
#Include Once "mff/Label.bi"
#Include Once "mff/TextBox.bi"
#Include Once "mff/CommandButton.bi"

#Define Me3 *Cast(frmGoto Ptr, Sender.GetForm)

Using My.Sys.Forms
    
'#Region "Form"
    Type frmGoto Extends Form
        Declare Static Sub _Form_Show_(ByRef Sender As Form)
        Declare Static Sub _btnFind_Click_(ByRef Sender As Control)
        Declare Static Sub _btnCancel_Click_(ByRef Sender As Control)
        
        Declare Sub Form_Show(ByRef Sender As Form)
        Declare Sub btnFind_Click(ByRef Sender As Control)
        Declare Sub btnCancel_Click(ByRef Sender As Control)
        Declare Constructor
        Declare Destructor
        
        Dim As Label lblFind
        Dim As TextBox txtFind
        Dim As CommandButton btnFind, btnCancel
    End Type

    Private Sub frmGoto._btnFind_Click_(ByRef Sender As Control)
        With Me3
            .btnFind_Click(Sender)
        End With
    End Sub

    Private Sub frmGoto._btnCancel_Click_(ByRef Sender As Control)
        Me3.btnCancel_Click(Sender)
    End Sub

    Private Sub frmGoto._Form_Show_(ByRef Sender As Form)
        Me3.Form_Show(Sender)
    End Sub

    Constructor frmGoto
        This.Width = 320
        Height = 100
        Caption = "Oʻtish"
        lblFind.Caption = "Qator:"
        lblFind.SetBounds 10, 10, 80, 20
        lblFind.Parent = @This
        txtFind.SetBounds 90, 10, 204, 20
        txtFind.Anchor.Left = asAnchor
        txtFind.Anchor.Right = asAnchor
        txtFind.Parent = @This
        btnFind.Caption = "&Oʻtish"
        btnFind.Default = True
        btnFind.SetBounds 90, 36, 100, 20
        btnFind.Anchor.Right = asAnchor
        btnFind.Parent = @This
        btnCancel.Caption = "&Bekor"
        btnCancel.Anchor.Right = asAnchor
        btnCancel.SetBounds 194, 36, 100, 20
        btnCancel.Parent = @This
        'AddRange 10, @lblFind, @txtFind, @lblReplace, @txtReplace, @chkRegistr, @btnFind, @btnReplace, @btnFindAll, @btnReplaceAll, @btnCancel
        OnShow = @_Form_Show_
        btnFind.OnClick = @_btnFind_Click_
        btnCancel.OnClick = @_btnCancel_Click_
        This.DefaultButton = @btnFind
        This.CancelButton = @btnCancel
        'This.BorderStyle = 2
    End Constructor

    Destructor frmGoto
        
    End Destructor
'#End Region

Private Sub frmGoto.btnFind_Click(ByRef Sender As Control)
    If This.FParent = 0 Then Exit Sub
    If Cast(Form Ptr, This.Parent)->ActiveControl = 0 Then Exit Sub
    If Cast(Form Ptr, This.Parent)->ActiveControl->ClassName <> "EditControl" Then Exit Sub
    Dim txt As EditControl Ptr = Cast(EditControl Ptr, Cast(Form Ptr, This.Parent)->ActiveControl)
    If Val(txtFind.Text) <= 0 Then Exit Sub
    This.CloseForm
    txt->SetSelection Val(txtFind.Text) - 1, Val(txtFind.Text) - 1, 0, 0
    txt->SetFocus
End Sub

Private Sub frmGoto.btnCancel_Click(ByRef Sender As Control)
    This.CloseForm
End Sub

Private Sub frmGoto.Form_Show(ByRef Sender As Form)
    Sender.Center
    txtFind.SelectAll
    txtFind.SetFocus
End Sub
