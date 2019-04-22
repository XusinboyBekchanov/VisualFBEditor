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
#Include Once "mff/CommandButton.bi"
#Include Once "mff/CheckBox.bi"
#Include Once "mff/GroupBox.bi"
#Include Once "mff/Label.bi"
#Include Once "mff/Panel.bi"
#Include Once "mff/TextBox.bi"
#Include Once "mff/ComboBoxEdit.bi"

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
        Declare Static Sub cmdDebugger_Click(ByRef Sender As Control)
        Declare Static Sub cmdTerminal_Click(ByRef Sender As Control)
        Declare Static Sub pnlLocalization_Click(ByRef Sender As Control)
        Declare Static Sub txtHistoryLimit_Change(BYREF Sender As TextBox)
        Declare Constructor
        
        Dim As TreeView tvOptions
        Dim As CommandButton CommandButton1, CommandButton2, CommandButton3, CommandButton4, CommandButton5, CommandButton6, cmdMFFPath, cmdAddInclude, cmdRemoveInclude, cmdAddLibrary, cmdRemoveLibrary, cmdDebugger, cmdTerminal
        Dim As Label lblBlack, lblWhite, lblCompiler32, lblCompiler64, lblLanguage, lblHelp, lblMFF, lblTabSize, lblMFF1, lblLibraryFiles, lblDebugger, lblTerminal, lblHistoryLimit, lblGridSize
        Dim As Panel pnlGeneral, pnlCodeEditor, pnlCompiler, pnlDebugger, pnlDesigner, pnlLocalization, pnlHelp, pnlIncludes
        Dim As TextBox TextBox1, TextBox2, TextBox3, txtMFFpath, txtTabSize, txtDebugger, txtTerminal, txtHistoryLimit, txtGridSize
        Dim As ComboBoxEdit ComboBoxEdit1, cboCase
        Dim As CheckBox CheckBox1, chkAutoCreateRC, chkAutoSaveCompile, chkEnableAutoComplete, chkTabAsSpaces, chkAutoIndentation, chkShowSpaces, chkShowAlignmentGrid, chkSnapToGrid, chkChangeKeywordsCase
        Dim OpenD As OpenFileDialog
        Dim BrowsD As FolderBrowserDialog
        Dim As ListControl lstIncludePaths, lstLibraryPaths
        Dim As GroupBox grbGrid
    End Type
    
    Constructor frmOptions
        LoadLanguageTexts
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
        This.Caption = ML("Options")
        This.BorderStyle = FormBorderStyle.FixedDialog
        ' tvOptions
        tvOptions.Name = "tvOptions"
        tvOptions.Text = "TreeView1"
        tvOptions.SetBounds 10, 10, 130, 296
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
        ' pnlDebugger
        pnlDebugger.Name = "pnlCompiler"
        pnlDebugger.Text = ""
        pnlDebugger.SetBounds 142, 10, 426, 296
        pnlDebugger.Parent = @This
        ' pnlDesigner
        pnlDesigner.Name = "pnlDesigner"
        pnlDesigner.Text = ""
        pnlDesigner.SetBounds 142, 10, 426, 296
        pnlDesigner.Parent = @This
        ' pnlLocalization
        pnlLocalization.Name = "pnlLocalization"
        pnlLocalization.Text = ""
        pnlLocalization.SetBounds 142, 10, 426, 296
        pnlLocalization.OnClick = @pnlLocalization_Click
        pnlLocalization.Parent = @This
        ' pnlHelp
        pnlHelp.Name = "pnlHelp"
        pnlHelp.Text = ""
        pnlHelp.SetBounds 142, 10, 426, 296
        pnlHelp.Parent = @This
        ' lblCompiler32
        lblCompiler32.Name = "lblCompiler32"
        lblCompiler32.Text = ML("Compiler") & " " & ML("32-bit")
        lblCompiler32.SetBounds 10, 0, 276, 18
        lblCompiler32.Parent = @pnlCompiler
        ' TextBox1
        TextBox1.Name = "TextBox1"
        TextBox1.Text = "fbc.exe"
        TextBox1.SetBounds 10, 18, 386, 20
        TextBox1.Parent = @pnlCompiler
        ' lblCompiler64
        lblCompiler64.Name = "lblCompiler64"
        lblCompiler64.Text = ML("Compiler") & " " & ML("64-bit")
        lblCompiler64.SetBounds 10, 42, 282, 18
        lblCompiler64.Parent = @pnlCompiler
        ' TextBox2
        TextBox2.Name = "TextBox2"
        TextBox2.Text = "fbc.exe"
        TextBox2.SetBounds 10, 60, 386, 20
        TextBox2.Parent = @pnlCompiler
        ' lblDebugger
        lblDebugger.Name = "lblDebugger"
        lblDebugger.Text = ML("Debugger")
        lblDebugger.SetBounds 10, 0, 276, 18
        lblDebugger.Parent = @pnlDebugger
        ' txtDebugger
        txtDebugger.Name = "txtDebugger"
        txtDebugger.Text = "gdb"
        txtDebugger.SetBounds 10, 18, 386, 20
        txtDebugger.Parent = @pnlDebugger
        ' lblTerminal
        lblTerminal.Name = "lblTerminal"
        lblTerminal.Text = ML("Terminal")
        lblTerminal.SetBounds 10, 42, 282, 18
        lblTerminal.Parent = @pnlDebugger
        ' txtTerminal
        txtTerminal.Name = "txtTerminal"
        txtTerminal.Text = "gnome-terminal"
        txtTerminal.SetBounds 10, 60, 386, 20
        txtTerminal.Parent = @pnlDebugger
        ' TextBox3
        TextBox3.Name = "TextBox3"
        TextBox3.Text = ""
        TextBox3.SetBounds 10, 18, 385, 20
        TextBox3.Parent = @pnlHelp
        ' lblHelp
        lblHelp.Name = "lblHelp"
        lblHelp.Text = ML("Help") & ":"
        lblHelp.SetBounds 10, 0, 96, 18
        lblHelp.Parent = @pnlHelp
        ' lblLanguage
        lblLanguage.Name = "lblLanguage"
        lblLanguage.Text = ML("Language") & ":"
        lblLanguage.SetBounds 10, 0, 162, 18
        lblLanguage.Parent = @pnlLocalization
        ' ComboBoxEdit1
        ComboBoxEdit1.Name = "ComboBoxEdit1"
        'ComboBoxEdit1.Text = "russian"
        ComboBoxEdit1.SetBounds 10, 18, 408, 30
        ComboBoxEdit1.Parent = @pnlLocalization
        ' CommandButton4
        CommandButton4.Name = "CommandButton4"
        CommandButton4.Text = "..."
        CommandButton4.SetBounds 396, 17, 24, 22
        CommandButton4.Caption = "..."
        CommandButton4.OnClick = @CommandButton4_Click
        CommandButton4.OnMouseUp = @CommandButton4_MouseUp
        CommandButton4.Parent = @pnlCompiler
        ' CommandButton5
        CommandButton5.Name = "CommandButton5"
        CommandButton5.Text = "..."
        CommandButton5.SetBounds 396, 59, 24, 22
        CommandButton5.Caption = "..."
        CommandButton5.OnClick = @CommandButton5_Click
        CommandButton5.Parent = @pnlCompiler
        ' CommandButton6
        CommandButton6.Name = "CommandButton6"
        CommandButton6.Text = "..."
        CommandButton6.SetBounds 395, 17, 24, 22
        CommandButton6.Caption = "..."
        CommandButton6.OnClick = @CommandButton6_Click
        CommandButton6.Parent = @pnlHelp
        ' CheckBox1
        CheckBox1.Name = "CheckBox1"
        CheckBox1.Text = ML("Auto Increment version")
        CheckBox1.SetBounds 10, 0, 318, 18
        CheckBox1.Caption = ML("Auto Increment version")
        CheckBox1.Parent = @pnlGeneral
        ' chkAutoCreateRC
        chkAutoCreateRC.Name = "chkAutoCreateRC"
        chkAutoCreateRC.Text = ML("Auto create resource (.rc, .xml) files")
        chkAutoCreateRC.SetBounds 10, 20, 300, 18
        chkAutoCreateRC.Parent = @pnlGeneral
        ' pnlIncludes
        pnlIncludes.Name = "pnlIncludes"
        pnlIncludes.SetBounds 142, 10, 426, 296
        pnlIncludes.Text = ""
        pnlIncludes.Parent = @This
        ' lblMFF
        lblMFF.Name = "lblMFF"
        lblMFF.Text = ML("MFF path:")
        lblMFF.SetBounds 10, 0, 138, 18
        lblMFF.Caption = ML("MFF path:")
        lblMFF.Parent = @pnlIncludes
        ' txtMFFpath
        txtMFFpath.Name = "txtMFFpath"
        txtMFFpath.SetBounds 10, 16, 390, 20
        txtMFFpath.Parent = @pnlIncludes
        ' cmdMFFPath
        cmdMFFPath.Name = "cmdMFFPath"
        cmdMFFPath.Text = "..."
        cmdMFFPath.SetBounds 400, 15, 24, 22
        cmdMFFPath.Caption = "..."
        cmdMFFPath.OnClick = @cmdMFFPath_Click
        cmdMFFPath.Parent = @pnlIncludes
        ' chkAutoSaveCompile
        chkAutoSaveCompile.Name = "chkAutoSaveCompile"
        chkAutoSaveCompile.Text = ML("Avto save files before compiling")
        chkAutoSaveCompile.SetBounds 10, 41, 324, 18
        chkAutoSaveCompile.Caption = ML("Avto save files before compiling")
        chkAutoSaveCompile.Parent = @pnlGeneral
        ' chkEnableAutoComplete
        chkEnableAutoComplete.Name = "chkEnableAutoComplete"
        chkEnableAutoComplete.Text = ML("Enable Auto Complete")
        chkEnableAutoComplete.SetBounds 10, 21, 264, 18
        chkEnableAutoComplete.Caption = ML("Enable Auto Complete")
        chkEnableAutoComplete.Parent = @pnlCodeEditor
        ' chkTabAsSpaces
        chkTabAsSpaces.Name = "chkTabAsSpaces"
        chkTabAsSpaces.Text = ML("Treat Tab as Spaces")
        chkTabAsSpaces.SetBounds 10, 42, 264, 18
        chkTabAsSpaces.Caption = ML("Treat Tab as Spaces")
        chkTabAsSpaces.Parent = @pnlCodeEditor
        ' chkAutoIndentation
        chkAutoIndentation.Name = "chkAutoIndentation"
        chkAutoIndentation.Text = ML("Auto Indentation")
        chkAutoIndentation.SetBounds 10, 0, 264, 18
        chkAutoIndentation.Caption = ML("Auto Indentation")
        chkAutoIndentation.Parent = @pnlCodeEditor
        ' lblTabSize
        lblTabSize.Name = "lblTabSize"
        lblTabSize.Text = ML("Tab Size:")
        lblTabSize.SetBounds 66, 115, 106, 16
        lblTabSize.Caption = ML("Tab Size:")
        lblTabSize.Parent = @pnlCodeEditor
        ' txtTabSize
        txtTabSize.Name = "txtTabSize"
        txtTabSize.Text = ""
        txtTabSize.SetBounds 177, 112, 90, 20
        txtTabSize.Parent = @pnlCodeEditor
        ' chkShowSpaces
        chkShowSpaces.Name = "chkShowSpaces"
        chkShowSpaces.Text = ML("Show Spaces")
        chkShowSpaces.SetBounds 10, 63, 264, 18
        chkShowSpaces.Caption = ML("Show Spaces")
        chkShowSpaces.Parent = @pnlCodeEditor
        ' lstIncludePaths
        lstIncludePaths.Name = "lstIncludePaths"
        lstIncludePaths.Text = "ListControl1"
        lstIncludePaths.SetBounds 10, 63, 390, 102
        lstIncludePaths.Parent = @pnlIncludes
        ' lstLibraryPaths
        lstLibraryPaths.Name = "lstLibraryPaths"
        lstLibraryPaths.Text = "ListControl11"
        lstLibraryPaths.SetBounds 10, 188, 390, 108
        lstLibraryPaths.Parent = @pnlIncludes
        ' lblMFF1
        lblMFF1.Name = "lblMFF1"
        lblMFF1.Text = ML("Include paths:")
        lblMFF1.SetBounds 11, 45, 150, 18
        lblMFF1.Caption = ML("Include paths:")
        lblMFF1.Parent = @pnlIncludes
        ' lblLibraryFiles
        lblLibraryFiles.Name = "lblLibraryFiles"
        lblLibraryFiles.Text = ML("Library paths:")
        lblLibraryFiles.SetBounds 12, 170, 150, 16
        lblLibraryFiles.Caption = ML("Library paths:")
        lblLibraryFiles.Parent = @pnlIncludes
        ' cmdAddInclude
        cmdAddInclude.Name = "cmdAddInclude"
        cmdAddInclude.Text = "+"
        cmdAddInclude.SetBounds 400, 62, 24, 22
        cmdAddInclude.Caption = "+"
        cmdAddInclude.Parent = @pnlIncludes
        ' cmdRemoveInclude
        cmdRemoveInclude.Name = "cmdRemoveInclude"
        cmdRemoveInclude.Text = "-"
        cmdRemoveInclude.SetBounds 400, 83, 24, 22
        cmdRemoveInclude.Caption = "-"
        cmdRemoveInclude.Parent = @pnlIncludes
        ' cmdAddLibrary
        cmdAddLibrary.Name = "cmdAddLibrary"
        cmdAddLibrary.Text = "+"
        cmdAddLibrary.SetBounds 400, 187, 24, 22
        cmdAddLibrary.Caption = "+"
        cmdAddLibrary.Parent = @pnlIncludes
        ' cmdRemoveLibrary
        cmdRemoveLibrary.Name = "cmdRemoveLibrary"
        cmdRemoveLibrary.Text = "-"
        cmdRemoveLibrary.SetBounds 400, 208, 24, 22
        cmdRemoveLibrary.Caption = "-"
        cmdRemoveLibrary.Parent = @pnlIncludes
        ' cmdDebugger
        cmdDebugger.Name = "cmdDebugger"
        cmdDebugger.Text = "..."
        cmdDebugger.SetBounds 396, 17, 24, 22
        cmdDebugger.Caption = "..."
        cmdDebugger.OnClick = @cmdDebugger_Click
        cmdDebugger.Parent = @pnlDebugger
        ' cmdTerminal
        cmdTerminal.Name = "cmdTerminal"
        cmdTerminal.Text = "..."
        cmdTerminal.SetBounds 396, 59, 24, 22
        cmdTerminal.Caption = "..."
        cmdTerminal.OnClick = @cmdTerminal_Click
        cmdTerminal.Parent = @pnlDebugger
        ' lblHistoryLimit
        lblHistoryLimit.Name = "lblHistoryLimit"
        lblHistoryLimit.Text = ML("History limit:")
        lblHistoryLimit.SetBounds 66, 141, 102, 17
        lblHistoryLimit.Parent = @pnlCodeEditor
        ' txtHistoryLimit
        txtHistoryLimit.Name = "txtHistoryLimit"
        txtHistoryLimit.SetBounds 177, 139, 90, 20
        txtHistoryLimit.OnChange = @txtHistoryLimit_Change
        txtHistoryLimit.Text = ""
        txtHistoryLimit.Parent = @pnlCodeEditor
        ' grbGrid
        grbGrid.Name = "grbGrid"
        grbGrid.Text = ML("Grid")
        grbGrid.SetBounds 8, -1, 414, 144
        grbGrid.Parent = @pnlDesigner
        ' lblGridSize
        lblGridSize.Name = "lblGridSize"
        lblGridSize.Text = ML("Size:")
        lblGridSize.SetBounds 24, 31, 60, 18
        lblGridSize.Parent = @pnlDesigner
        ' txtGridSize
        txtGridSize.Name = "txtGridSize"
        txtGridSize.Text = "10"
        txtGridSize.SetBounds 81, 31, 114, 18
        txtGridSize.Parent = @pnlDesigner
        ' chkShowAlignmentGrid
        chkShowAlignmentGrid.Name = "chkShowAlignmentGrid"
        chkShowAlignmentGrid.Text = ML("Show Alignment Grid")
        chkShowAlignmentGrid.SetBounds 80, 51, 138, 30
        chkShowAlignmentGrid.Parent = @pnlDesigner
        ' chkSnapToGrid
        chkSnapToGrid.Name = "chkSnapToGrid"
        chkSnapToGrid.Text = ML("Snap to Grid")
        chkSnapToGrid.SetBounds 80, 75, 138, 24
        chkSnapToGrid.Parent = @pnlDesigner
        ' cboCase
        cboCase.Name = "cboCase"
        cboCase.Text = "ComboBoxEdit2"
        cboCase.SetBounds 177, 83, 90, 21
        cboCase.Parent = @pnlCodeEditor
        ' chkChangeKeywordsCase
        chkChangeKeywordsCase.Name = "chkChangeKeywordsCase"
        chkChangeKeywordsCase.Text = ML("Change Keywords Case to:")
        chkChangeKeywordsCase.SetBounds 10, 84, 162, 18
        chkChangeKeywordsCase.Parent = @pnlCodeEditor
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
    With fOptions
        .ComboBoxEdit1.Clear
        .tvOptions.Nodes.Clear
        .tvOptions.Nodes.Add ML("General"), "General"
        .tvOptions.Nodes.Add ML("Code Editor"), "CodeEditor"
        .tvOptions.Nodes.Add ML("Compiler"), "Compiler"
        .tvOptions.Nodes.Add ML("Debugger"), "Debugger"
        .tvOptions.Nodes.Add ML("Designer"), "Designer"
        .tvOptions.Nodes.Add ML("Includes"), "Includes"
        .tvOptions.Nodes.Add ML("Localization"), "Localization"
        .tvOptions.Nodes.Add ML("Help"), "Help"
        .cboCase.AddItem ML("Original Case")
        .cboCase.AddItem ML("Lower Case")
        .cboCase.AddItem ML("Upper Case")
        .cboCase.ItemIndex = ChoosedKeyWordsCase
        .chkChangeKeywordsCase.Checked = ChangeKeywordsCase
        .TextBox1.Text = WGet(Compilator32)
        .TextBox2.Text = WGet(Compilator64)
        .txtDebugger.Text = WGet(Debugger)
        .txtTerminal.Text = WGet(Terminal)
        .TextBox3.Text = WGet(HelpPath)
        .txtTabSize.Text = Str(TabWidth)
        .txtHistoryLimit.Text = Str(HistoryLimit)
        .txtMFFPath.Text = *MFFPath
        .CheckBox1.Checked = AutoIncrement
        .chkEnableAutoComplete.Checked = AutoComplete
        .chkAutoSaveCompile.Checked = AutoSaveCompile
        .chkAutoIndentation.Checked = AutoIndentation
        .chkAutoCreateRC.Checked = AutoCreateRC
        .chkShowSpaces.Checked = ShowSpaces
        .txtGridSize.Text = Str(GridSize)
        .chkShowAlignmentGrid.Checked = ShowAlignmentGrid
        .chkSnapToGrid.Checked = SnapToGridOption
        f = Dir(exepath & "/Languages/*.lng")
        While f <> ""
            Open exepath & "/Languages/" & f For Input Encoding "utf-8" As #1
            WReallocate s, LOF(1)
            If Not EOF(1) Then
                Line Input #1, *s
                Languages.Add Left(f, Len(f) - 4)
                .ComboBoxEdit1.AddItem *s
            End If
            Close #1
            f = dir()
        Wend
        newIndex = Languages.IndexOf(CurLanguage)
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
        WLet Debugger, .txtDebugger.Text
        WLet Terminal, .txtTerminal.Text
        WLet HelpPath, .TextBox3.Text
        WLet MFFPath, .txtMFFPath.Text
        #IfDef __FB_64bit__
            WLet MFFDll, *MFFPath & "/mff64.dll"
        #Else
            WLet MFFDll, *MFFPath & "/mff32.dll"
        #EndIf
        TabWidth = Val(.txtTabSize.Text)
        HistoryLimit = Val(.txtHistoryLimit.Text)
        AutoIncrement = .CheckBox1.Checked
        AutoIndentation = .chkAutoIndentation.Checked
        AutoComplete = .chkEnableAutoComplete.Checked
        AutoCreateRC = .chkAutoCreateRC.Checked
        AutoSaveCompile = .chkAutoSaveCompile.Checked
        ShowSpaces = .chkShowSpaces.Checked
        TabAsSpaces = .chkTabAsSpaces.Checked
        GridSize = Val(.txtGridSize.Text)
        ShowAlignmentGrid = .chkShowAlignmentGrid.Checked
        SnapToGridOption = .chkSnapToGrid.Checked
        ChangeKeywordsCase = .chkChangeKeywordsCase.Checked
        ChoosedKeywordsCase = .cboCase.ItemIndex
        iniSettings.WriteString "Options", "Compilator32", *Compilator32
        iniSettings.WriteString "Options", "Compilator64", *Compilator64
        iniSettings.WriteString "Options", "Debugger", *Debugger
        iniSettings.WriteString "Options", "Terminal", *Terminal
        iniSettings.WriteString "Options", "HelpPath", *HelpPath
        iniSettings.WriteString "Options", "MFFPath", *MFFPath
        iniSettings.WriteString "Options", "Language", Languages.Item(.ComboBoxEdit1.ItemIndex)
        iniSettings.WriteInteger "Options", "TabWidth", TabWidth
        iniSettings.WriteInteger "Options", "HistoryLimit", HistoryLimit
        iniSettings.WriteBool "Options", "AutoIncrement", AutoIncrement
        iniSettings.WriteBool "Options", "AutoIndentation", AutoIndentation
        iniSettings.WriteBool "Options", "AutoComplete", AutoComplete
        iniSettings.WriteBool "Options", "AutoCreateRC", AutoCreateRC
        iniSettings.WriteBool "Options", "AutoSaveBeforeCompiling", AutoSaveCompile
        iniSettings.WriteBool "Options", "ShowSpaces", ShowSpaces
        iniSettings.WriteBool "Options", "TabAsSpaces", TabAsSpaces
        iniSettings.WriteInteger "Options", "GridSize", GridSize
        iniSettings.WriteBool "Options", "ShowAlignmentGrid", ShowAlignmentGrid
        iniSettings.WriteBool "Options", "SnapToGrid", SnapToGridOption
        iniSettings.WriteBool "Options", "ChangeKeywordsCase", ChangeKeywordsCase
        iniSettings.WriteInteger "Options", "ChoosedKeywordsCase", ChoosedKeywordsCase
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
    	.tvOptions.Nodes.Item(0)->SelectItem
        '.TreeView1_SelChange .tvOptions, *.tvOptions.Nodes.Item(0)
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
        .pnlDebugger.Visible = i = 3
        .pnlDesigner.Visible = i = 4
        .pnlIncludes.Visible = i = 5
        .pnlLocalization.Visible = i = 6
        .pnlHelp.Visible = i = 7
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

Private Sub frmOptions.cmdDebugger_Click(ByRef Sender As Control)
    With *Cast(frmOptions Ptr, Sender.GetForm)
        .OpenD.Filter = ML("All Files") & "|*.*;"
        If .OpenD.Execute Then
            .txtDebugger.Text = .OpenD.FileName 
        End If
    End With
End Sub

Private Sub frmOptions.cmdTerminal_Click(ByRef Sender As Control)
    With *Cast(frmOptions Ptr, Sender.GetForm)
        .OpenD.Filter = ML("All Files") & "|*.*;"
        If .OpenD.Execute Then
            .txtTerminal.Text = .OpenD.FileName 
        End If
    End With
End Sub

Private Sub frmOptions.pnlLocalization_Click(ByRef Sender As Control)
	
End Sub

Private Sub frmOptions.txtHistoryLimit_Change(BYREF Sender As TextBox)
	
End Sub
