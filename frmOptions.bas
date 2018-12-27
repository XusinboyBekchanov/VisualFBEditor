'#Compile "mff\xpmanifest.rc"
#Include Once "mff\Form.bi"
#Include Once "mff\TreeView.bi"
#Include Once "mff\CommandButton.bi"
#Include Once "mff\Label.bi"
#Include Once "mff\Panel.bi"
#Include Once "mff\TextBox.bi"
#Include Once "mff\ComboBoxEdit.bi"
#Include Once "mff\IniFile.bi"
#Include Once "mff\CheckBox.bi"
#Include Once "mff\ListControl.bi"

Using My.Sys.Forms

Dim Shared Languages As WStringList
Dim Shared As Integer oldIndex, newIndex

'#Region "Form"
    Type frmOptions Extends Form
        Declare Static Sub CommandButton1_Click(ByRef Sender As Control)
        Declare Static Sub CommandButton2_Click(ByRef Sender As Control)
        Declare Static Sub Form_Create(ByRef Sender As Control)
        Declare Static Sub CommandButton3_Click(ByRef Sender As Control)
        Declare Static Sub Form_Destroy(ByRef Sender As Form)
        Declare Static Sub Form_Close(ByRef Sender As Form, BYREF Action As Integer)
        Declare Static Sub Form_Show(ByRef Sender As Form)
        Declare Static Sub CommandButton4_Click(ByRef Sender As Control)
        Declare Static Sub CommandButton5_Click(ByRef Sender As Control)
        Declare Static Sub CommandButton6_Click(ByRef Sender As Control)
        Declare Static Sub CommandButton4_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
        Declare Static Sub TreeView1_SelChange(BYREF Sender As TreeView, BYREF Item As TreeNode)
        Declare Static Sub pnlIncludes_ActiveControlChange(ByRef Sender As Control)
        Declare Static Sub cmdMFFPath_Click(ByRef Sender As Control)
        Declare Constructor
        
        Dim As TreeView tvOptions
        Dim As CommandButton CommandButton1, CommandButton2, CommandButton3, CommandButton4, CommandButton5, CommandButton6, cmdMFFPath, cmdAddInclude, cmdRemoveInclude, cmdAddLibrary, cmdRemoveLibrary
        Dim As Label lblBlack, lblWhite, lblCompiler32, lblCompiler64, lblLanguage, lblHelp, lblMFF, lblTabSize, lblMFF1, lblLibraryFiles
        Dim As Panel pnlGeneral, pnlCodeEditor, pnlCompiler, pnlLocalization, pnlHelp, pnlIncludes
        Dim As TextBox TextBox1, TextBox2, TextBox3, txtMFFpath, txtTabSize
        Dim As ComboBoxEdit ComboBoxEdit1
        Dim As CheckBox CheckBox1, chkAutoCreateRC, chkAutoSaveCompile, chkEnableAutoComplete, chkTabAsSpaces, chkAutoIndentation, chkShowSpaces
        Dim OpenD As OpenFileDialog
        Dim BrowsD As FolderBrowserDialog
        Dim As ListControl lstIncludePaths, lstLibraryPaths
    End Type
    
    Constructor frmOptions
        ' Form1
        This.Name = "frmOptions"
        This.Text = ML("Options")
        This.OnCreate = @Form_Create
        This.OnClose = @Form_Close
        This.OnShow = @Form_Show
        This.MinimizeBox = false
        This.MaximizeBox = false
        This.SetBounds 0, 0, 582, 384
        This.Center
        This.BorderStyle = FormBorderStyle.FixedDialog
        ' tvOptions
        tvOptions.Name = "tvOptions"
        tvOptions.Text = "TreeView1"
        tvOptions.SetBounds 10, 10, 132, 296
        tvOptions.HideSelection = False
        tvOptions.OnSelChange = @TreeView1_SelChange
        tvOptions.Parent = @This
        ' CommandButton1
        CommandButton1.Name = "CommandButton1"
        CommandButton1.Text = ML("OK")
        CommandButton1.SetBounds 300, 323, 90, 24
        CommandButton1.OnClick = @CommandButton1_Click
        CommandButton1.Caption = ML("OK")
        CommandButton1.Parent = @This
        ' CommandButton2
        CommandButton2.Name = "CommandButton2"
        CommandButton2.Text = ML("Cancel")
        CommandButton2.SetBounds 389, 323, 90, 24
        CommandButton2.OnClick = @CommandButton2_Click
        CommandButton2.Parent = @This
        ' CommandButton3
        CommandButton3.Name = "CommandButton3"
        CommandButton3.Text = ML("Apply")
        CommandButton3.SetBounds 478, 323, 90, 24
        CommandButton3.OnClick = @CommandButton3_Click
        CommandButton3.Parent = @This
        ' lblBlack
        lblBlack.Name = "lblBlack"
        lblBlack.Text = ""
        lblBlack.BorderStyle = 2
        lblBlack.BackColor = 0
        lblBlack.SetBounds 7, 315, 558, 1
        lblBlack.Parent = @This
        ' lblWhite
        lblWhite.Name = "lblWhite"
        lblWhite.Text = ""
        lblWhite.BackColor = 15790320
        lblWhite.SetBounds 6, 319, 553, 1
        lblWhite.Parent = @This
        ' pnlGeneral
        pnlGeneral.Name = "pnlGeneral"
        pnlGeneral.Text = ""
        pnlGeneral.SetBounds 142, 10, 426, 296
        pnlGeneral.Parent = @This
        ' pnlCodeEditor
        pnlCodeEditor.Name = "pnlCodeEditor"
        pnlCodeEditor.Text = ""
        pnlCodeEditor.SetBounds 142, 10, 426, 296
        pnlCodeEditor.Parent = @This
        ' pnlCompiler
        pnlCompiler.Name = "pnlCompiler"
        pnlCompiler.Text = ""
        pnlCompiler.SetBounds 142, 10, 426, 296
        pnlCompiler.Parent = @This
        ' pnlLocalization
        pnlLocalization.Name = "pnlLocalization"
        pnlLocalization.Text = ""
        pnlLocalization.SetBounds 142, 10, 426, 296
        pnlLocalization.Parent = @This
        ' pnlHelp
        pnlHelp.Name = "pnlHelp"
        pnlHelp.Text = ""
        pnlHelp.SetBounds 142, 10, 426, 296
        pnlHelp.Parent = @This
        ' lblCompiler32
        lblCompiler32.Name = "lblCompiler32"
        lblCompiler32.Text = ML("Compilator") & " " & ML("32-bit")
        lblCompiler32.SetBounds 10, 0, 276, 18
        lblCompiler32.Parent = @pnlCompiler
        ' TextBox1
        TextBox1.Name = "TextBox1"
        TextBox1.Text = "fbc.exe"
        TextBox1.SetBounds 10, 18, 386, 18
        TextBox1.Parent = @pnlCompiler
        ' lblCompiler64
        lblCompiler64.Name = "lblCompiler64"
        lblCompiler64.Text = ML("Compilator") & " " & ML("64-bit")
        lblCompiler64.SetBounds 10, 42, 282, 18
        lblCompiler64.Parent = @pnlCompiler
        ' TextBox2
        TextBox2.Name = "TextBox2"
        TextBox2.Text = "fbc.exe"
        TextBox2.SetBounds 10, 60, 386, 18
        TextBox2.Parent = @pnlCompiler
        ' TextBox3
        TextBox3.Name = "TextBox3"
        TextBox3.Text = ""
        TextBox3.SetBounds 10, 18, 379, 18
        TextBox3.Parent = @pnlHelp
        ' lblHelp
        lblHelp.Name = "lblHelp"
        lblHelp.Text = ML("Help") & ":"
        lblHelp.SetBounds 10, 0, 96, 18
        lblHelp.Parent = @pnlHelp
        ' lblLanguage
        lblLanguage.Name = "lblLanguage"
        lblLanguage.Text = ML("Language") & ":"
        lblLanguage.SetBounds 10, 0, 96, 18
        lblLanguage.Parent = @pnlLocalization
        ' ComboBoxEdit1
        ComboBoxEdit1.Name = "ComboBoxEdit1"
        'ComboBoxEdit1.Text = "russian"
        ComboBoxEdit1.SetBounds 10, 18, 408, 21
        ComboBoxEdit1.Parent = @pnlLocalization
        ' CommandButton4
        CommandButton4.Name = "CommandButton4"
        CommandButton4.Text = "..."
        CommandButton4.SetBounds 396, 18, 24, 18
        CommandButton4.Caption = "..."
        CommandButton4.OnClick = @CommandButton4_Click
        CommandButton4.OnMouseUp = @CommandButton4_MouseUp
        CommandButton4.Parent = @pnlCompiler
        ' CommandButton5
        CommandButton5.Name = "CommandButton5"
        CommandButton5.Text = "..."
        CommandButton5.SetBounds 396, 60, 24, 18
        CommandButton5.Caption = "..."
        CommandButton5.OnClick = @CommandButton5_Click
        CommandButton5.Parent = @pnlCompiler
        ' CommandButton6
        CommandButton6.Name = "CommandButton6"
        CommandButton6.Text = "..."
        CommandButton6.SetBounds 390, 18, 24, 18
        CommandButton6.Caption = "..."
        CommandButton6.OnClick = @CommandButton6_Click
        CommandButton6.Parent = @pnlHelp
        ' CheckBox1
        CheckBox1.Name = "CheckBox1"
        CheckBox1.Text = "Auto Increment version"
        CheckBox1.SetBounds 10, 0, 264, 18
        CheckBox1.Caption = "Auto Increment version"
        CheckBox1.Parent = @pnlGeneral
        ' chkAutoCreateRC
        chkAutoCreateRC.Name = "chkAutoCreateRC"
        chkAutoCreateRC.Text = "Auto create resource (.rc, .xml) files"
        chkAutoCreateRC.SetBounds 10, 20, 252, 18
        chkAutoCreateRC.Parent = @pnlGeneral
        ' pnlIncludes
        pnlIncludes.Name = "pnlIncludes"
        pnlIncludes.SetBounds 142, 10, 426, 296
        pnlIncludes.Text = ""
        pnlIncludes.Parent = @This
        ' lblMFF
        lblMFF.Name = "lblMFF"
        lblMFF.Text = "MFF path:"
        lblMFF.SetBounds 10, 0, 96, 18
        lblMFF.Caption = "MFF path:"
        lblMFF.Parent = @pnlIncludes
        ' txtMFFpath
        txtMFFpath.Name = "txtMFFpath"
        txtMFFpath.SetBounds 10, 16, 390, 18
        txtMFFpath.Parent = @pnlIncludes
        ' cmdMFFPath
        cmdMFFPath.Name = "cmdMFFPath"
        cmdMFFPath.Text = "..."
        cmdMFFPath.SetBounds 400, 16, 24, 18
        cmdMFFPath.Caption = "..."
        cmdMFFPath.OnClick = @cmdMFFPath_Click
        cmdMFFPath.Parent = @pnlIncludes
        ' chkAutoSaveCompile
        chkAutoSaveCompile.Name = "chkAutoSaveCompile"
        chkAutoSaveCompile.Text = "Avto save files before compiling"
        chkAutoSaveCompile.SetBounds 10, 41, 252, 18
        chkAutoSaveCompile.Caption = "Avto save files before compiling"
        chkAutoSaveCompile.Parent = @pnlGeneral
        ' chkEnableAutoComplete
        chkEnableAutoComplete.Name = "chkEnableAutoComplete"
        chkEnableAutoComplete.Text = "Enable Auto Complete"
        chkEnableAutoComplete.SetBounds 10, 21, 264, 18
        chkEnableAutoComplete.Caption = "Enable Auto Complete"
        chkEnableAutoComplete.Parent = @pnlCodeEditor
        ' chkTabAsSpaces
        chkTabAsSpaces.Name = "chkTabAsSpaces"
        chkTabAsSpaces.Text = "Treat Tab as Spaces"
        chkTabAsSpaces.SetBounds 10, 42, 264, 18
        chkTabAsSpaces.Caption = "Treat Tab as Spaces"
        chkTabAsSpaces.Parent = @pnlCodeEditor
        ' chkAutoIndentation
        chkAutoIndentation.Name = "chkAutoIndentation"
        chkAutoIndentation.Text = "Auto Indentation"
        chkAutoIndentation.SetBounds 10, 0, 264, 18
        chkAutoIndentation.Caption = "Auto Indentation"
        chkAutoIndentation.Parent = @pnlCodeEditor
        ' lblTabSize
        lblTabSize.Name = "lblTabSize"
        lblTabSize.Text = "Tab Size:"
        lblTabSize.SetBounds 10, 180, 48, 18
        lblTabSize.Caption = "Tab Size:"
        lblTabSize.Parent = @pnlCodeEditor
        ' txtTabSize
        txtTabSize.Name = "txtTabSize"
        txtTabSize.Text = ""
        txtTabSize.SetBounds 63, 178, 72, 18
        txtTabSize.Parent = @pnlCodeEditor
        ' chkShowSpaces
        chkShowSpaces.Name = "chkShowSpaces"
        chkShowSpaces.Text = "Show Spaces"
        chkShowSpaces.SetBounds 10, 63, 264, 18
        chkShowSpaces.Caption = "Show Spaces"
        chkShowSpaces.Parent = @pnlCodeEditor
        ' lstIncludePaths
        lstIncludePaths.Name = "lstIncludePaths"
        lstIncludePaths.Text = "ListControl1"
        lstIncludePaths.SetBounds 10, 57, 390, 108
        lstIncludePaths.Parent = @pnlIncludes
        ' lstLibraryPaths
        lstLibraryPaths.Name = "lstLibraryPaths"
        lstLibraryPaths.Text = "ListControl11"
        lstLibraryPaths.SetBounds 10, 188, 390, 108
        lstLibraryPaths.Parent = @pnlIncludes
        ' lblMFF1
        lblMFF1.Name = "lblMFF1"
        lblMFF1.Text = "Include paths:"
        lblMFF1.SetBounds 11, 39, 96, 18
        lblMFF1.Caption = "Include paths:"
        lblMFF1.Parent = @pnlIncludes
        ' lblLibraryFiles
        lblLibraryFiles.Name = "lblLibraryFiles"
        lblLibraryFiles.Text = "Library paths:"
        lblLibraryFiles.SetBounds 12, 170, 102, 16
        lblLibraryFiles.Caption = "Library paths:"
        lblLibraryFiles.Parent = @pnlIncludes
        ' cmdAddInclude
        cmdAddInclude.Name = "cmdAddInclude"
        cmdAddInclude.Text = "+"
        cmdAddInclude.SetBounds 400, 56, 24, 20
        cmdAddInclude.Caption = "+"
        cmdAddInclude.Parent = @pnlIncludes
        ' cmdRemoveInclude
        cmdRemoveInclude.Name = "cmdRemoveInclude"
        cmdRemoveInclude.Text = "-"
        cmdRemoveInclude.SetBounds 400, 75, 24, 21
        cmdRemoveInclude.Caption = "-"
        cmdRemoveInclude.Parent = @pnlIncludes
        ' cmdAddLibrary
        cmdAddLibrary.Name = "cmdAddLibrary"
        cmdAddLibrary.Text = "+"
        cmdAddLibrary.SetBounds 400, 187, 24, 23
        cmdAddLibrary.Caption = "+"
        cmdAddLibrary.Parent = @pnlIncludes
        ' cmdRemoveLibrary
        cmdRemoveLibrary.Name = "cmdRemoveLibrary"
        cmdRemoveLibrary.Text = "-"
        cmdRemoveLibrary.SetBounds 400, 209, 24, 23
        cmdRemoveLibrary.Caption = "-"
        cmdRemoveLibrary.Parent = @pnlIncludes
    End Constructor
    
    Dim Shared fOptions As frmOptions
        
    #IfnDef _NOT_AUTORUN_FORMS_
        frm.Show
    
        App.Run
    #EndIf
'#End Region

Private Sub frmOptions.CommandButton1_Click(ByRef Sender As Control)
    CommandButton3_Click(Sender)
    Cast(frmOptions Ptr, Sender.Parent)->CloseForm
End Sub

Private Sub frmOptions.CommandButton2_Click(ByRef Sender As Control)
    Cast(frmOptions Ptr, Sender.Parent)->CloseForm
End Sub

Private Sub frmOptions.Form_Create(ByRef Sender As Control)
    Dim As String f
    Dim s As WString Ptr
    #IfDef __FB_Win32__
		iniSettings.Create ExePath & "/VisualFBEditor.ini"
    #Else
		iniSettings.Create ExePath & "/VisualFBEditorX.ini"
    #EndIF
    With fOptions
        .ComboBoxEdit1.Clear
        .tvOptions.Nodes.Clear
        .tvOptions.Nodes.Add ML("General"), "General"
        .tvOptions.Nodes.Add ML("Code Editor"), "CodeEditor"
        .tvOptions.Nodes.Add ML("Compiler"), "Compiler"
        .tvOptions.Nodes.Add ML("Includes"), "Includes"
        .tvOptions.Nodes.Add ML("Localization"), "Localization"
        .tvOptions.Nodes.Add ML("Help"), "Help"
        .TextBox1.Text = iniSettings.ReadString("Options", "Compilator32", "fbc.exe")
        .TextBox2.Text = iniSettings.ReadString("Options", "Compilator64", "fbc.exe")
        .TextBox3.Text = iniSettings.ReadString("Options", "HelpPath", "")
        .txtTabSize.Text = Str(iniSettings.ReadInteger("Options", "TabWidth", 4))
        .txtMFFPath.Text = iniSettings.ReadString("Options", "MFFPath", *MFFPath)
        .CheckBox1.Checked = iniSettings.ReadBool("Options", "AutoIncrement", true)
        .chkEnableAutoComplete.Checked = iniSettings.ReadBool("Options", "AutoComplete", true)
        .chkAutoSaveCompile.Checked = iniSettings.ReadBool("Options", "AutoSaveBeforeCompiling", true)
        .chkAutoIndentation.Checked = iniSettings.ReadBool("Options", "AutoIndentation", true)
        .chkAutoCreateRC.Checked = iniSettings.ReadBool("Options", "AutoCreateRC", true)
        .chkShowSpaces.Checked = iniSettings.ReadBool("Options", "ShowSpaces", true)
        f = Dir(exepath & "/languages/*.lng")
        While f <> ""
            Open exepath & "/languages/" & f For Input Encoding "utf-8" As #1
            WReallocate s, LOF(1)
            If Not EOF(1) Then
                Line Input #1, *s
                Languages.Add Left(f, Len(f) - 4)
                .ComboBoxEdit1.AddItem *s
            End If
            Close #1
            f = dir()
        Wend
        newIndex = Languages.IndexOf(iniSettings.ReadString("Options", "Language", "english"))
        .ComboBoxEdit1.ItemIndex = newIndex
        oldIndex = newIndex
        .TreeView1_SelChange .tvOptions, *.tvOptions.Nodes.Item(0)
        'Dim i As Integer = 0
		'.pnlGeneral.Visible = i = 0
		'.pnlCodeEditor.Visible = i = 1
		'.pnlCompiler.Visible = i = 2
		'.pnlIncludes.Visible = i = 3
		'.pnlLocalization.Visible = i = 4
		'.pnlHelp.Visible = i = 5
    End With
End Sub

Private Sub frmOptions.CommandButton3_Click(ByRef Sender As Control)
    On Error Goto ErrorHandler
    With *Cast(frmOptions Ptr, Sender.Parent)
        WLet Compilator32, .TextBox1.Text
        WLet Compilator64, .TextBox2.Text
        WLet HelpPath, .TextBox3.Text
        WLet MFFPath, .txtMFFPath.Text
        #IfDef __FB_64bit__
            WLet MFFDll, *MFFPath & "\mff\mff64.dll"
        #Else
            WLet MFFDll, *MFFPath & "\mff\mff32.dll"
        #EndIf
        TabWidth = Val(.txtTabSize.Text)
        AutoIncrement = .CheckBox1.Checked
        AutoIndentation = .chkAutoIndentation.Checked
        AutoComplete = .chkEnableAutoComplete.Checked
        AutoSaveCompile = .chkAutoSaveCompile.Checked
        AutoCreateRC = .chkAutoCreateRC.Checked
        ShowSpaces = .chkShowSpaces.Checked
        TabAsSpaces = .chkTabAsSpaces.Checked
        iniSettings.WriteString "Options", "Compilator32", *Compilator32
        iniSettings.WriteString "Options", "Compilator64", *Compilator64
        iniSettings.WriteString "Options", "HelpPath", *HelpPath
        iniSettings.WriteString "Options", "MFFPath", *MFFPath
        iniSettings.WriteString "Options", "Language", Languages.Item(.ComboBoxEdit1.ItemIndex)
        iniSettings.WriteInteger "Options", "TabWidth", TabWidth
        iniSettings.WriteBool "Options", "AutoIndentation", AutoIndentation
        iniSettings.WriteBool "Options", "AutoIncrement", AutoIncrement
        iniSettings.WriteBool "Options", "AutoCreateRC", AutoCreateRC
        iniSettings.WriteBool "Options", "AutoComplete", AutoComplete
        iniSettings.WriteBool "Options", "AutoSaveBeforeCompiling", AutoSaveCompile
        newIndex = .ComboBoxEdit1.ItemIndex
    End With
    Exit Sub
ErrorHandler:
    MsgBox ErrDescription(Err) & " (" & Err & ") " & _
        "in line " & Erl() & " " & _
        "in function " & ZGet(Erfn()) & " " & _
        "in module " & ZGet(Ermn())
End Sub

Private Sub frmOptions.Form_Close(ByRef Sender As Form, BYREF Action As Integer)
    'Sender.FreeWnd
    'Sender.Handle = 0
    #IfNDef __USE_GTK__
		If newIndex <> oldIndex Then MsgBox ML("The language will change after the program is restarted"), "Visual FB Editor", MB_OK Or MB_ICONINFORMATION OR MB_TOPMOST OR MB_TASKMODAL
	#EndIf
End Sub

Private Sub frmOptions.Form_Show(ByRef Sender As Form)
    With fOptions
        .TreeView1_SelChange .tvOptions, *.tvOptions.Nodes.Item(0)
    End With
End Sub

Private Sub frmOptions.CommandButton4_Click(ByRef Sender As Control)
'    With *Cast(frmOptions Ptr, Sender.GetForm)
'        .TextBox1.SetFocus
'        ReleaseCapture
'        .OpenD.Filter = ML("All Files") & "|*.*;"
'        If .OpenD.Execute Then
'            .TextBox1.Text = .OpenD.FileName 
'        End If
'    End With
End Sub

Private Sub frmOptions.CommandButton5_Click(ByRef Sender As Control)
    With *Cast(frmOptions Ptr, Sender.GetForm)
        '.TextBox2.SetFocus
        .OpenD.Filter = ML("All Files") & "|*.*;"
        If .OpenD.Execute Then
            .TextBox2.Text = .OpenD.FileName 
        End If
    End With
End Sub

Private Sub frmOptions.CommandButton6_Click(ByRef Sender As Control)
    With *Cast(frmOptions Ptr, Sender.GetForm)
        '.TextBox3.SetFocus
        .OpenD.Filter = ML("All Files") & "|*.*;"
        If .OpenD.Execute Then
            .TextBox3.Text = .OpenD.FileName 
        End If
    End With    
End Sub


Private Sub frmOptions.CommandButton4_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
    With *Cast(frmOptions Ptr, Sender.GetForm)
        '.TextBox1.SetFocus
        'ReleaseCapture
        .OpenD.Filter = ML("All Files") & "|*.*;"
        If .OpenD.Execute Then
            .TextBox1.Text = .OpenD.FileName 
        End If
    End With
End Sub

Private Sub frmOptions.TreeView1_SelChange(BYREF Sender As TreeView, BYREF Item As TreeNode)
    With fOptions
        Dim i As Integer = Item.Index
        .pnlGeneral.Visible = i = 0
        .pnlCodeEditor.Visible = i = 1
        .pnlCompiler.Visible = i = 2
        .pnlIncludes.Visible = i = 3
        .pnlLocalization.Visible = i = 4
        .pnlHelp.Visible = i = 5
    End With
End Sub

Private Sub frmOptions.pnlIncludes_ActiveControlChange(ByRef Sender As Control)
    
End Sub

Private Sub frmOptions.cmdMFFPath_Click(ByRef Sender As Control)
    With fOptions
        If .BrowsD.Execute Then
            .txtMFFPath.Text = .BrowsD.Directory
        End If
    End With
End Sub
