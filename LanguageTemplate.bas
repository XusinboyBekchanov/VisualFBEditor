'#Compile -ex "mff\xpmanifest.rc"
#Include Once "mff\Form.bi"
#Include Once "mff\TextBox.bi"
#Include Once "mff\Label.bi"
#Include Once "mff\Dialogs.bi"
#Include Once "mff\CommandButton.bi"

Using My.Sys.Forms

'#Region "Form"
    Type Form1 Extends Form
        Declare Static Sub CommandButton2_Click(ByRef Sender As Control)
        Declare Static Sub CommandButton1_Create(ByRef Sender As Control)
        Declare Static Sub CommandButton1_Click(ByRef Sender As Control)
        Declare Static Sub CommandButton3_Click(ByRef Sender As Control)
        Declare Constructor
        
        Dim As TextBox TextBox1, TextBox2
        Dim As Label Label1, Label2
        Dim As CommandButton CommandButton1, CommandButton2, CommandButton3
    End Type
    
    Constructor Form1
        ' Form1
        This.Name = "Form1"
        This.Text = "Form1"
        This.SetBounds 0, 0, 350, 156
        ' TextBox1
        TextBox1.Name = "TextBox1"
        TextBox1.Text = ""
        TextBox1.SetBounds 90, 24, 210, 18
        TextBox1.Parent = @This
        ' Label1
        Label1.Name = "Label1"
        Label1.Text = "Yo`l"
        Label1.SetBounds 12, 24, 78, 18
        Label1.Caption = "Yo`l"
        Label1.Parent = @This
        ' CommandButton1
        CommandButton1.Name = "CommandButton1"
        CommandButton1.Text = "Bajarish"
        CommandButton1.SetBounds 144, 84, 90, 30
        CommandButton1.Caption = "Bajarish"
        CommandButton1.OnCreate = @CommandButton1_Create
        CommandButton1.OnClick = @CommandButton1_Click
        CommandButton1.Parent = @This
        ' CommandButton2
        CommandButton2.Name = "CommandButton2"
        CommandButton2.Text = "..."
        CommandButton2.SetBounds 300, 24, 24, 18
        CommandButton2.Caption = "..."
        CommandButton2.OnClick = @CommandButton2_Click
        CommandButton2.Parent = @This
        ' Label2
        Label2.Name = "Label2"
        Label2.Text = "Til yo`li"
        Label2.SetBounds 12, 54, 78, 18
        Label2.Caption = "Til yo`li"
        Label2.Parent = @This
        ' TextBox2
        TextBox2.Name = "TextBox2"
        TextBox2.Text = ""
        TextBox2.SetBounds 90, 54, 210, 18
        TextBox2.Parent = @This
        ' CommandButton3
        CommandButton3.Name = "CommandButton3"
        CommandButton3.Text = "..."
        CommandButton3.SetBounds 300, 54, 24, 18
        CommandButton3.Caption = "..."
        CommandButton3.OnClick = @CommandButton3_Click
        CommandButton3.Parent = @This
    End Constructor
    
    #IfnDef _NOT_AUTORUN_FORMS_
        Dim frm As Form1
        frm.Show
    
        App.Run
    #EndIf
'#End Region


Private Sub Form1.CommandButton2_Click(ByRef Sender As Control)
    Dim OpenD As OpenFileDialog
    OpenD.Filter = "FreeBasic fayllari (.bi, .bas, .vfp)|*.bi;*.bas;*.vfp|"
    If OpenD.Execute Then
        Cast(Form1 Ptr, Sender.Parent)->TextBox1.Text = OpenD.FileName
    End If
End Sub

Private Sub Form1.CommandButton1_Create(ByRef Sender As Control)
    
End Sub

Function GetFolderName(ByRef FileName As WString) ByRef As WString
    Dim Pos1 As Long = InstrRev(FileName, "\")
    Dim s  As WString Ptr = CAllocate((Pos1 + 1) * SizeOf(WString))
    If Pos1 > 0 then
        *s = Left(FileName, Pos1)
        Return *s
    End If
    Return ""
End Function

Private Sub Form1.CommandButton1_Click(ByRef Sender As Control)
    Dim As WString Ptr buff, buff1, lang_name, fileName
    Dim As String Key
    Dim As Integer p, p1, n
    Dim As WStringList mlKeys, mlTexts, mlKeysNew
    Open Cast(Form1 Ptr, Sender.Parent)->TextBox2.Text For Input Encoding "utf-8" As #1
    WReallocate buff, LOF(1)
    n = 0
    Do Until EOF(1)
        Line Input #1, *buff
        n = n + 1
        If n = 1 Then
            WLet lang_name, *buff
        Else
            p = Instr(LCase(*buff), " = ")
            If p > 0 Then
                Key = Trim(Left(*buff, p - 1))
                If Not mlKeys.Contains(Key) Then
                    mlKeys.Add Key
                    mlTexts.Add Mid(*buff, p + 3)
                End If
            End If
        End If
    Loop
    Close #1
    Open Cast(Form1 Ptr, Sender.Parent)->TextBox1.Text For Input Encoding "utf-8" As #1
    WReallocate buff, LOF(1)
    Do Until EOF(1)
        Line Input #1, *buff
        If StartsWith(*buff, "File=") Then
            *buff = Mid(*buff, 6)
            If Instr(*buff, ":") Then
                WLet fileName, *buff
            Else
                WLet fileName, GetFolderName(Cast(Form1 Ptr, Sender.Parent)->TextBox1.Text) & *buff
            End If
            Open *fileName For Input Encoding "utf-8" As #3
            WReallocate buff1, LOF(3)
            Do Until EOF(3)
                Line Input #3, *buff1
                p = Instr(LCase(*buff1), "ml(""")
                Do While p > 0
                    p1 = Instr(p + 1, *buff1, """)")
                    If p1 > 0 Then
                        Key = Mid(*buff1, p + 4, p1 - p - 4)
                        If Key <> """" Then
                            If Not mlKeysNew.Contains(Key) Then mlKeysNew.Add Key
                        End If
                    End If
                    p = Instr(p1 + 1, LCase(*buff1), "ml(""")
                Loop
            Loop
            Close #3
        End If
    Loop
    Close #1
    Open Cast(Form1 Ptr, Sender.Parent)->TextBox2.Text For Output Encoding "utf-8" As #1
    Print #1, *lang_name
    mlKeysNew.Sort
    For i As Integer = 0 To mlKeysNew.Count - 1
        Key = mlKeysNew.Item(i)
        Print #1, Key & " = " & IIF(mlKeys.Contains(Key), mlTexts.Item(mlKeys.IndexOf(Key)), "")
    Next
    Close #1
    MsgBox "Bajarildi!"
End Sub

Private Sub Form1.CommandButton3_Click(ByRef Sender As Control)
    Dim OpenD As OpenFileDialog
    OpenD.Filter = "Til fayli (.lng)|*.lng|"
    If OpenD.Execute Then
        Cast(Form1 Ptr, Sender.Parent)->TextBox2.Text = OpenD.FileName
    End If
End Sub
