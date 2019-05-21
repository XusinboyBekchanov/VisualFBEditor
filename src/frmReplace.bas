'#########################################################
'#  frmReplace.bas                                       #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (2018-2019)              #
'#########################################################

#Include Once "mff/Form.bi"
#Include Once "mff/Label.bi"
#Include Once "mff/TextBox.bi"
#Include Once "mff/CheckBox.bi"
#Include Once "mff/CommandButton.bi"

#Define Me2 *Cast(frmReplace Ptr, Sender.GetForm)

Using My.Sys.Forms
    
'#Region "Form"
    Type frmReplace Extends Form 
        Declare Static Sub _Form_Show_(ByRef Sender As Form)
        Declare Static Sub _Form_Close_(ByRef Sender As Form, BYREF Action As Integer)
        Declare Static Sub _btnFind_Click_(ByRef Sender As Control)
        Declare Static Sub _btnFindAll_Click_(ByRef Sender As Control)
        Declare Static Sub _btnReplace_Click_(ByRef Sender As Control)
        Declare Static Sub _btnReplaceAll_Click_(ByRef Sender As Control)
        Declare Static Sub _btnCancel_Click_(ByRef Sender As Control)
        
        Declare Sub Form_Show(ByRef Sender As Form)
        Declare Sub Form_Close(ByRef Sender As Form, BYREF Action As Integer)
        Declare Sub btnFind_Click(ByRef Sender As Control)
        Declare Sub btnFindAll_Click(ByRef Sender As Control)
        Declare Sub btnReplace_Click(ByRef Sender As Control)
        Declare Sub btnReplaceAll_Click(ByRef Sender As Control)
        Declare Sub btnCancel_Click(ByRef Sender As Control)
        Declare Function Find(Down As Boolean, bNotShowResults As Boolean = False) As Integer
        Declare Constructor
        Declare Destructor
        
        Dim As CheckBox chkRegistr
        Dim As Label lblFind
        Dim As TextBox txtFind
        Dim As Label lblReplace
        Dim As TextBox txtReplace
        Dim As CommandButton btnFind, btnReplace, btnReplaceAll, btnCancel
    End Type

    Private Sub frmReplace._btnFind_Click_(ByRef Sender As Control)
        With Me2
            .btnFind_Click(Sender)
        End With
    End Sub

    Private Sub frmReplace._btnFindAll_Click_(ByRef Sender As Control)
        Me2.btnFindAll_Click(Sender)
    End Sub

    Private Sub frmReplace._btnReplace_Click_(ByRef Sender As Control)
        Me2.btnReplace_Click(Sender)
    End Sub

    Private Sub frmReplace._btnReplaceAll_Click_(ByRef Sender As Control)
        Me2.btnReplaceAll_Click(Sender)
    End Sub

    Private Sub frmReplace._btnCancel_Click_(ByRef Sender As Control)
        Me2.btnCancel_Click(Sender)
    End Sub

    Private Sub frmReplace._Form_Show_(ByRef Sender As Form)
        Me2.Form_Show(Sender)
    End Sub

    Private Sub frmReplace._Form_Close_(ByRef Sender As Form, Byref Action As Integer)
        Me2.Form_Close(Sender, Action)
    End Sub

    Constructor frmReplace
        This.BorderStyle = FormBorderStyle.FixedDialog
        This.MaximizeBox = false
        This.MinimizeBox = false
        This.Icon.ResName = "Logo"
        This.SetBounds 0, 0, 405, 140
        Caption = ML("Replace")
        lblFind.Caption = ML("Find What") & ":"
        lblFind.SetBounds 10, 10, 80, 20
        lblFind.Parent = @This
        txtFind.SetBounds 90, 10, 300, 20
        txtFind.Anchor.Left = asAnchor
        txtFind.Anchor.Right = asAnchor
        txtFind.Parent = @This
        lblReplace.Caption = ML("Replace") & ":"
        lblReplace.SetBounds 10, 35, 80, 20
        lblReplace.Parent = @This
        txtReplace.SetBounds 90, 35, 300, 20
        txtReplace.Anchor.Left = asAnchor
        txtReplace.Anchor.Right = asAnchor
        txtReplace.Parent = @This
        chkRegistr.Caption = ML("Match Case")
        chkRegistr.SetBounds 90, 60, 140, 20
        chkRegistr.Parent = @This
        btnFind.Caption = ML("&Find")
        btnFind.Default = True
        btnFind.SetBounds 10, 85, 85, 20
        btnFind.Anchor.Right = asAnchor
        btnFind.Parent = @This
        btnReplace.Caption = ML("&Replace")
        btnReplace.SetBounds 95, 85, 85, 20
        btnReplace.Anchor.Right = asAnchor
        btnReplace.Parent = @This
        btnReplaceAll.Caption = ML("Replace All")
        btnReplaceAll.SetBounds 180, 85, 125, 20
        btnReplaceAll.Anchor.Right = asAnchor
        btnReplaceAll.Parent = @This
        btnCancel.Caption = ML("&Cancel")
        btnCancel.Anchor.Right = asAnchor
        btnCancel.SetBounds 305, 85, 85, 20
        btnCancel.Parent = @This
        'AddRange 10, @lblFind, @txtFind, @lblReplace, @txtReplace, @chkRegistr, @btnFind, @btnReplace, @btnFindAll, @btnReplaceAll, @btnCancel
        OnShow = @_Form_Show_
        OnClose = @_Form_Close_
        btnFind.OnClick = @_btnFind_Click_
        btnReplace.OnClick = @_btnReplace_Click_
        btnReplaceAll.OnClick = @_btnReplaceAll_Click_
        btnCancel.OnClick = @_btnCancel_Click_
        DefaultButton = @btnFind
        CancelButton = @btnCancel
        'This.BorderStyle = 2
    End Constructor

    Destructor frmReplace
        
    End Destructor
'#End Region

Public Function frmReplace.Find(Down As Boolean, bNotShowResults As Boolean = False) As Integer
    If This.FParent = 0 Then Exit Function
    If Cast(Form Ptr, This.Parent)->ActiveControl = 0 Then Exit Function
    If Cast(Form Ptr, This.Parent)->ActiveControl->ClassName <> "EditControl" Then Exit Function
    Dim txt As EditControl Ptr = Cast(EditControl Ptr, Cast(Form Ptr, This.Parent)->ActiveControl)
    Dim Result As Integer
    Dim bRegistr As Boolean = chkRegistr.Checked
    Dim buff As WString Ptr
    Dim search As WString Ptr = @txtFind.Text
    Dim iStartChar As Integer, iStartLine As Integer
    Dim i As Integer
    If Down Then
        If bNotShowResults Then
            iStartChar = 1
            iStartLine = 0
        Else
            Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
            txt->GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
            iStartChar = iSelEndChar + 1
            iStartLine = iSelEndLine
        End If
        For i = iStartLine To txt->LinesCount - 1
            buff = @txt->Lines(i)
            If bRegistr Then
                Result = Instr(iStartChar, *buff, *search)
            Else
                Result = Instr(iStartChar, lcase(*buff), lcase(*search))
            End if
            If Result > 0 Then Exit For
            iStartChar = 1
        Next i
    Else
        If bNotShowResults Then
            iStartLine = txt->LinesCount - 1
            iStartChar = Len(txt->Lines(iStartLine))
        Else
            Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
            txt->GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
            iStartLine = iSelStartLine
            iStartChar = iSelStartChar
        End If
        For i = iStartLine To 0 Step -1
            buff = @txt->Lines(i)
            If i <> iStartLine Then iStartChar = Len(*buff)
            If bRegistr Then
                Result = InstrRev(*buff, *search, iStartChar)
            Else
                Result = InstrRev(lcase(*buff), lcase(*search), iStartChar)
            End if
            If Result > 0 Then Exit For
        Next i
    End If
    If Result <> 0 Then
        txt->SetSelection i, i, Result - 1, Result + Len(*search) - 1
    ElseIf bNotShowResults Then
        Return Result
    Else
        'If MessageBox(btnFind.Handle, @WStr("Izlash oxiriga yetdi, qaytadan izlashni xohlaysizmi?"), @WStr("Izlash"), MB_YESNO) = IDYES Then
        'If MsgBox("Izlash oxiriga yetdi, qaytadan izlashni xohlaysizmi?", "Izlash", MB_YESNO) = IDYES Then
            Result = Find(Down, True)
            If Result = 0 Then
                'ShowMessage("Izlanayotgan matn topilmadi!")
            End If
        'End If
    End If
    txtFind.SetFocus
    Return Result
End Function

Private Sub frmReplace.btnFind_Click(ByRef Sender As Control)
    Find True 'True
End Sub

Private Sub frmReplace.btnFindAll_Click(ByRef Sender As Control)
    Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, tabCode.SelectedTab)
    if tb = 0 Then Exit Sub
    Dim bRegistr As Boolean = chkRegistr.Checked
    Dim buff As WString Ptr
    Dim search As WString Ptr = @txtFind.Text
    Dim As Integer Pos1
    lvSearch.ListItems.Clear
    lvSearch.Text = *search
    For i As Integer = 0 TO tb->txtCode.LinesCount - 1
        buff = @tb->txtCode.Lines(i)
        If bRegistr Then
            Pos1 = Instr(*buff, *search)
        Else
            Pos1 = Instr(lcase(*buff), lcase(*search))
        End If
        While Pos1 > 0
            lvSearch.ListItems.Add *buff
            lvSearch.ListItems.Item(lvSearch.ListItems.Count - 1)->Text(1) = WStr(i + 1)
            lvSearch.ListItems.Item(lvSearch.ListItems.Count - 1)->Text(2) = WStr(Pos1)
            lvSearch.ListItems.Item(lvSearch.ListItems.Count - 1)->Text(3) = tb->FileName
            lvSearch.ListItems.Item(lvSearch.ListItems.Count - 1)->Tag = tb
            If bRegistr Then
                Pos1 = Instr(Pos1 + 1, *buff, *search)
            Else
                Pos1 = Instr(Pos1 + 1, lcase(*buff), lcase(*search))
            End If
        Wend
    Next i
    tabBottom.TabIndex = 2
    tabBottom.Tabs[2]->Caption = ML("Find") & " (" & lvSearch.ListItems.Count & " " & ML("Pos") & ")"
End Sub

Private Sub frmReplace.btnReplace_Click(ByRef Sender As Control)
    If This.FParent = 0 Then Exit SUb
    If Cast(Form Ptr, This.Parent)->ActiveControl = 0 Then Exit Sub
    If Cast(Form Ptr, This.Parent)->ActiveControl->ClassName <> "EditControl" Then Exit Sub
    Dim txt As EditControl Ptr = Cast(EditControl Ptr, Cast(Form Ptr, This.Parent)->ActiveControl)
    If lcase(txt->SelText) = lcase(txtFind.Text) Then
        txt->SelText = txtReplace.Text
    Else
        Find True    
    End If
End Sub

Private Sub frmReplace.btnReplaceAll_Click(ByRef Sender As Control)
    If This.FParent = 0 Then Exit Sub
    If Cast(Form Ptr, This.Parent)->ActiveControl = 0 Then Exit Sub
    If Cast(Form Ptr, This.Parent)->ActiveControl->ClassName <> "EditControl" Then Exit Sub
    Dim txt As EditControl Ptr = Cast(EditControl Ptr, Cast(Form Ptr, This.Parent)->ActiveControl)
    Dim Result As Boolean
    txt->SetSelection 0, 0, 0, 0
    Result = Find(True, True)
    While Result
        txt->SelText = txtReplace.Text
        Result = Find(True, True)
    Wend
    txtFind.SetFocus
End Sub

Private Sub frmReplace.btnCancel_Click(ByRef Sender As Control)
    This.CloseForm
End Sub

Private Sub frmReplace.Form_Show(ByRef Sender As Form)
    Sender.Center
    txtFind.Text = Clipboard.GetAsText
    txtFind.SelectAll
    txtFind.SetFocus
End Sub

Private Sub frmReplace.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
    if 1 then
        
    End If
End Sub
