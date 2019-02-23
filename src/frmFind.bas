'Compile with -g -s console "SI FreeBasic.rc"
#Include Once "mff/Form.bi"
#Include Once "mff/Label.bi"
#Include Once "mff/TextBox.bi"
#Include Once "mff/CheckBox.bi"
#Include Once "mff/CommandButton.bi"
#Include Once "mff/TrackBar.bi"
#Include Once "mff/Label.bi"

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

    Private Sub frmFind._btnFind_Click_(ByRef Sender As Control)
        With Me
            .btnFind_Click(Sender)
        End With
    End Sub

    Private Sub frmFind._btnFindAll_Click_(ByRef Sender As Control)
        Me.btnFindAll_Click(Sender)
    End Sub

    Private Sub frmFind._btnCancel_Click_(ByRef Sender As Control)
        Me.btnCancel_Click(Sender)
    End Sub

    Private Sub frmFind._Form_Show_(ByRef Sender As Form)
        Me.Form_Show(Sender)
    End Sub

    Private Sub frmFind._Form_Close_(ByRef Sender As Form, Byref Action As Integer)
        Me.Form_Close(Sender, Action)
    End Sub

    Constructor frmFind
        This.Width = 415
        Height = 130
        This.Opacity = 140
        Caption = ML("Find")
        lblFind.Caption = ML("Find What") & ":"
        lblFind.SetBounds 10, 10, 80, 26
        lblFind.Parent = @This
        txtFind.SetBounds 90, 10, 300, 26
        txtFind.Anchor.Left = asAnchor
        txtFind.Anchor.Right = asAnchor
        txtFind.Parent = @This
        chkRegistr.Caption = ML("Match Case")
        chkRegistr.SetBounds 90, 41, 140, 20
        chkRegistr.Parent = @This
        btnFind.Caption = ML("&Find Next")
        btnFind.Default = True
        btnFind.SetBounds 90, 66, 100, 26
        btnFind.Anchor.Right = asAnchor
        btnFind.Parent = @This
        btnFindAll.Caption = ML("Find &All")
        btnFindAll.SetBounds 190, 66, 100, 26
        btnFindAll.Anchor.Right = asAnchor
        btnFindAll.Parent = @This
        btnCancel.Caption = ML("&Cancel")
        btnCancel.Anchor.Right = asAnchor
        btnCancel.SetBounds 290, 66, 100, 26
        btnCancel.Parent = @This
        'AddRange 10, @lblFind, @txtFind, @lblReplace, @txtReplace, @chkRegistr, @btnFind, @btnReplace, @btnFindAll, @btnReplaceAll, @btnCancel
        OnShow = @_Form_Show_
        OnClose = @_Form_Close_
        btnFind.OnClick = @_btnFind_Click_
        btnFindAll.OnClick = @_btnFindAll_Click_
        btnCancel.OnClick = @_btnCancel_Click_
        This.DefaultButton = @btnFind
        This.CancelButton = @btnCancel
        'This.BorderStyle = 2
        ' TrackBar1
        TrackBar1.Name = "TrackBar1"
        TrackBar1.Text = "TrackBar1"
        TrackBar1.SetBounds 276, 42, 114, 18
        TrackBar1.OnChange = @TrackBar1_Change
        TrackBar1.Parent = @This
        TrackBar1.MinValue = 50
        TrackBar1.MaxValue = 255
        TrackBar1.Position = This.Opacity
        ' lblTrack
        lblTrack.Name = "lblTrack"
        lblTrack.Text = "50"
        lblTrack.SetBounds 240, 40, 30, 18
        lblTrack.Caption = "50"
        lblTrack.Parent = @This
    End Constructor

    Destructor frmFind
        
    End Destructor
'#End Region

Public Function frmFind.Find(Down As Boolean, bNotShowResults As Boolean = False) As Integer
    Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, tabCode.SelectedTab)
    if tb = 0 Then Exit Function
    Dim txt As EditControl Ptr = @tb->txtCode
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

Private Sub frmFind.btnFind_Click(ByRef Sender As Control)
    Find True 'True
End Sub

Private Sub frmFind.btnFindAll_Click(ByRef Sender As Control)
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

Private Sub frmFind.btnCancel_Click(ByRef Sender As Control)
    This.CloseForm
End Sub

Private Sub frmFind.Form_Show(ByRef Sender As Form)
    Sender.Center
    txtFind.Text = Clipboard.GetAsText
    txtFind.SelectAll
    txtFind.SetFocus
End Sub

Private Sub frmFind.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
    if 1 then
        
    End If
End Sub

Private Sub frmFind.TrackBar1_Change(BYREF Sender As TrackBar,Position As Integer)
    Cast(frmFind Ptr, Sender.Parent)->Opacity = Sender.Position
    Cast(frmFind Ptr, Sender.Parent)->lblTrack.Text = WStr(Sender.Position)
End Sub
