'#Compile "mff\xpmanifest.rc"
#Include Once "mff\Form.bi"
#Include Once "mff\CheckBox.bi"
#Include Once "mff\Label.bi"
#Include Once "mff\LinkLabel.bi"
#Include Once "mff\CommandButton.bi"

Using My.Sys.Forms

'#Region "Form"
    Type frmAbout Extends Form
        Declare Static Sub CommandButton1_Click(ByRef Sender As Control)
        Declare Constructor
        
        Dim As Label Label1, lblInfo
        Dim As LinkLabel Label2, Label3
        Dim As CommandButton CommandButton1
        Dim As ImageBox lblIcon
    End Type
    
    Constructor frmAbout
        On Error Goto ErrorHandler
        This.Name = "frmAbout"
        This.Text = ML("About")
        This.SetBounds 0, 0, 350, 300
        This.BorderStyle = FormBorderStyle.FixedDialog
        This.MaximizeBox = false
        This.MinimizeBox = false
        This.Center
        Label1.Name = "Label1"
        Label1.Text = "Visual FB Editor " & App.Version
        Label1.Font.Name = "Times New Roman"
        Label1.Font.Bold = True
        Label1.Font.Size = 15
        Label1.SetBounds 84, 12, 240, 24
        Label1.Parent = @This
        CommandButton1.Name = "CommandButton1"
        CommandButton1.Text = "OK"
            '.DefaultButton = True
        CommandButton1.SetBounds 234, 228, 92, 26
        CommandButton1.OnClick = @CommandButton1_Click
        CommandButton1.Parent = @This
        ' Label2                                
        Label2.Name = "Label2"
        Label2.Text = ML("Author") & !": Xusinboy Bekchanov\re-mail: <A href=""mailto:bxusinboy@mail.ru"">bxusinboy@mail.ru</A>"
        Label2.SetBounds 24, 90, 216, 72
        Label2.Parent = @This
        ' Label3
        Label3.Name = "Label3"
        Label3.Text = ML("For donation") & !": \rWebMoney: WMZ: Z884195021874"
        Label3.SetBounds 24, 162, 216, 30
        Label3.Parent = @This
        ' lblIcon
        lblIcon.Name = "lblIcon"
        lblIcon.Text = "lblIcon"
        'lblIcon.RealSizeImage = false
        #IfDef __USE_GTK__
			lblIcon.Graphic.Icon.LoadFromFile(exepath & "/resources/VisualFBEditor.ico", 48, 48)
        #Else
			lblIcon.Graphic.Icon.LoadFromResourceID(1, 48, 48)
        #EndIf
        lblIcon.SetBounds 18, 12, 48, 48
        lblIcon.Parent = @This
        ' lblInfo
        lblInfo.Name = "lblInfo"
        lblInfo.Text = ML("Editor for FreeBasic")
        lblInfo.SetBounds 90, 36, 234, 18
        lblInfo.Font.Name = "Times New Roman"
        lblInfo.Font.Bold = true
        lblInfo.Font.Size = 10
        lblInfo.Parent = @This
        Exit Constructor
    ErrorHandler:
        MsgBox ErrDescription(Err) & " (" & Err & ") " & _
            "in line " & Erl() & " " & _
            "in function " & ZGet(Erfn()) & " " & _
            "in module " & ZGet(Ermn())
    End Constructor
    
    #IfnDef _NOT_AUTORUN_FORMS_
        Dim frm As frmAbout
        frm.Show
    
        App.Run
    #EndIf
'#End Region

Private Sub frmAbout.CommandButton1_Click(ByRef Sender As Control)
    Cast(Form Ptr, Sender.Parent)->CloseForm
End Sub
