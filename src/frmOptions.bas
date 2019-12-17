'#########################################################
'#  frmOptions.bas                                       #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (2018-2019)              #
'#########################################################

#include once "frmOptions.bi"
#include once "TabWindow.bi"

Dim Shared Languages As WStringList
Dim Shared fOptions As frmOptions
pfOptions = @fOptions

'#Region "Form"
	Constructor frmOptions
		' Form1
		This.Name = "frmOptions"
		This.Text = ML("Options")
		This.OnCreate = @Form_Create
		This.OnClose = @Form_Close
		This.OnShow = @Form_Show
		This.MinimizeBox = False
		This.MaximizeBox = False
		This.SetBounds 0, 0, 630, 488
		This.StartPosition = FormStartPosition.CenterParent
		This.Caption = ML("Options")
		This.BorderStyle = FormBorderStyle.FixedDialog
		' tvOptions
		tvOptions.Name = "tvOptions"
		tvOptions.Text = "TreeView1"
		tvOptions.SetBounds 10, 10, 178, 400
		tvOptions.HideSelection = False
		tvOptions.OnSelChange = @TreeView1_SelChange
		tvOptions.Parent = @This
		' cmdOK
		cmdOK.Name = "cmdOK"
		cmdOK.Text = ML("OK")
		cmdOK.SetBounds 348, 427, 90, 24
		cmdOK.OnClick = @cmdOK_Click
		cmdOK.Caption = ML("OK")
		cmdOK.Parent = @This
		' cmdCancel
		cmdCancel.Name = "cmdCancel"
		cmdCancel.Text = ML("Cancel")
		cmdCancel.SetBounds 437, 427, 90, 24
		cmdCancel.OnClick = @cmdCancel_Click
		cmdCancel.Parent = @This
		' cmdApply
		cmdApply.Name = "cmdApply"
		cmdApply.Text = ML("Apply")
		cmdApply.SetBounds 526, 427, 90, 24
		cmdApply.OnClick = @cmdApply_Click
		cmdApply.Parent = @This
		' lblBlack
		lblBlack.Name = "lblBlack"
		lblBlack.Text = ""
		lblBlack.BorderStyle = 2
		lblBlack.BackColor = 8421504
		lblBlack.SetBounds 11, 419, 606, 1
		lblBlack.Parent = @This
		' lblWhite
		lblWhite.Name = "lblWhite"
		lblWhite.Text = ""
		lblWhite.BackColor = 16777215
		lblWhite.SetBounds 11, 420, 606, 1
		lblWhite.Parent = @This
		' pnlGeneral
		pnlGeneral.Name = "pnlGeneral"
		pnlGeneral.Text = ""
		pnlGeneral.SetBounds 190, 10, 426, 400
		pnlGeneral.Parent = @This
		' pnlCodeEditor
		pnlCodeEditor.Name = "pnlCodeEditor"
		pnlCodeEditor.Text = ""
		pnlCodeEditor.SetBounds 190, 10, 426, 400
		pnlCodeEditor.Parent = @This
		' pnlColorsAndFonts
		pnlColorsAndFonts.Name = "pnlColorsAndFonts"
		pnlColorsAndFonts.Text = ""
		pnlColorsAndFonts.SetBounds 190, 10, 426, 400
		pnlColorsAndFonts.Parent = @This
		' pnlCompiler
		pnlCompiler.Name = "pnlCompiler"
		pnlCompiler.Text = ""
		pnlCompiler.SetBounds 190, 10, 426, 400
		pnlCompiler.Parent = @This
		' pnlMake
		pnlMake.Name = "pnlMake"
		pnlMake.Text = ""
		pnlMake.SetBounds 190, 10, 426, 400
		pnlMake.Parent = @This
		' pnlDebugger
		pnlDebugger.Name = "pnlDebugger"
		pnlDebugger.Text = ""
		pnlDebugger.SetBounds 190, 10, 426, 400
		pnlDebugger.Parent = @This
		' pnlTerminal
		pnlTerminal.Name = "pnlTerminal"
		pnlTerminal.Text = ""
		pnlTerminal.SetBounds 190, 10, 426, 400
		pnlTerminal.Parent = @This
		' pnlDesigner
		pnlDesigner.Name = "pnlDesigner"
		pnlDesigner.Text = ""
		pnlDesigner.SetBounds 190, 10, 426, 400
		pnlDesigner.Parent = @This
		' pnlLocalization
		pnlLocalization.Name = "pnlLocalization"
		pnlLocalization.Text = ""
		pnlLocalization.SetBounds 190, 10, 426, 400
		pnlLocalization.OnClick = @pnlLocalization_Click
		pnlLocalization.Parent = @This
		' pnlHelp
		pnlHelp.Name = "pnlHelp"
		pnlHelp.Text = ""
		pnlHelp.SetBounds 190, 10, 426, 400
		pnlHelp.Parent = @This
		' grbDefaultCompilers
		With grbDefaultCompilers
			.Name = "grbDefaultCompilers"
			.Text = "Default Compilers"
			.SetBounds 10, -2, 416, 128
			.Parent = @pnlCompiler
		End With
		' grbCompilerPaths
		With grbCompilerPaths
			.Name = "grbCompilerPaths"
			.Text = "Compiler Paths"
			.SetBounds 10, 134, 416, 264
			.Parent = @pnlCompiler
		End With
		' lblCompiler32
		lblCompiler32.Name = "lblCompiler32"
		lblCompiler32.Text = ML("Compiler") & " " & ML("32-bit")
		lblCompiler32.SetBounds 26, 16, 260, 18
		lblCompiler32.Parent = @pnlCompiler
		' TextBox1
		TextBox1.Name = "TextBox1"
		TextBox1.Text = "fbc.exe"
		TextBox1.SetBounds 26, 314, 362, 20
		TextBox1.Parent = @pnlCompiler
		' lblCompiler64
		lblCompiler64.Name = "lblCompiler64"
		lblCompiler64.Text = ML("Compiler") & " " & ML("64-bit")
		lblCompiler64.SetBounds 26, 66, 266, 18
		lblCompiler64.Parent = @pnlCompiler
		' grbDefaultDebugger
		With grbDefaultDebugger
			.Name = "grbDefaultDebugger"
			.Text = "Default Debugger"
			.SetBounds 10, -2, 416, 64
			.Parent = @pnlDebugger
		End With
		' grbDebuggerPaths
		With grbDebuggerPaths
			.Name = "grbDebuggerPaths"
			.Text = "Debugger Paths"
			.SetBounds 10, 70, 416, 328
			.Parent = @pnlDebugger
		End With
		' cboDebugger
		With cboDebugger
			.Name = "cboDebugger"
			.Text = "cboCompiler321"
			.SetBounds 26, 24, 384, 21
			.Parent = @pnlDebugger
		End With
		' txtDebugger
		txtDebugger.Name = "txtDebugger"
		txtDebugger.Text = "gdb"
		txtDebugger.SetBounds 26, 314, 362, 20
		txtDebugger.Parent = @pnlDebugger
		' grbDefaultTerminal
		With grbDefaultTerminal
			.Name = "grbDefaultTerminal"
			.Text = "Default Terminal"
			.SetBounds 10, -2, 416, 64
			.Parent = @pnlTerminal
		End With
		' cboTerminal
		With cboTerminal
			.Name = "cboTerminal"
			.Text = "cboTerminal"
			.SetBounds 26, 24, 384, 21
			.Parent = @pnlTerminal
		End With
		' grbTerminalPaths
		With grbTerminalPaths
			.Name = "grbTerminalPaths"
			.Text = "Terminal Paths"
			.SetBounds 10, 70, 416, 328
			.Parent = @pnlTerminal
		End With
		' lvTerminalPaths
		With lvTerminalPaths
			.Name = "lvTerminalPaths"
			.Text = "lvTerminalPaths"
			.SetBounds 26, 94, 384, 216
			.Parent = @pnlTerminal
		End With
		' txtTerminalVersion
		With txtTerminalVersion
			.Name = "txtTerminalVersion"
			.SetBounds 26, 338, 386, 20
			.Parent = @pnlTerminal
		End With
		' cmdAddTerminal
		With cmdAddTerminal
			.Name = "cmdAddTerminal"
			.Text = "Add"
			.SetBounds 25, 361, 128, 24
			.Caption = "Add"
			.OnClick = @cmdAddTerminal_Click
			.Parent = @pnlTerminal
		End With
		' cmdRemoveTerminal
		With cmdRemoveTerminal
			.Name = "cmdRemoveTerminal"
			.Text = "Remove"
			.SetBounds 155, 361, 128, 24
			.OnClick = @cmdRemoveTerminal_Click
			.Parent = @pnlTerminal
		End With
		' cmdClearDebuggers1
		With cmdClearTerminals
			.Name = "cmdClearTerminals"
			.Text = "Clear"
			.SetBounds 285, 361, 128, 24
			.OnClick = @cmdClearTerminals_Click
			.Parent = @pnlTerminal
		End With
		' txtTerminal
		txtTerminal.Name = "txtTerminal"
		txtTerminal.Text = "gnome-terminal"
		txtTerminal.SetBounds 26, 314, 362, 20
		txtTerminal.Parent = @pnlTerminal
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
		CommandButton4.SetBounds 388, 313, 24, 22
		CommandButton4.Caption = "..."
		CommandButton4.OnClick = @CommandButton4_Click
		CommandButton4.OnMouseUp = @CommandButton4_MouseUp
		CommandButton4.Parent = @pnlCompiler
		' cmdAddCompiler
		cmdAddCompiler.Name = "cmdAddCompiler"
		cmdAddCompiler.Text = "Add"
		cmdAddCompiler.SetBounds 25, 361, 128, 24
		cmdAddCompiler.Caption = "Add"
		cmdAddCompiler.OnClick = @CommandButton5_Click
		cmdAddCompiler.ID = 1007
		cmdAddCompiler.OnClick = @cmdAddCompiler_Click
		cmdAddCompiler.Parent = @pnlCompiler
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
		pnlIncludes.SetBounds 190, 10, 426, 400
		pnlIncludes.Text = ""
		pnlIncludes.Parent = @This
		' grbIncludePaths
		With grbIncludePaths
			.Name = "grbIncludePaths"
			.Text = "Include Paths"
			.SetBounds 10, -2, 416, 224
			.Parent = @pnlIncludes
		End With
		' grbLibraryPaths
		With grbLibraryPaths
			.Name = "grbLibraryPaths"
			.Text = "Library Paths"
			.SetBounds 10, 230, 416, 168
			.Parent = @pnlIncludes
		End With
		' lblMFF
		lblMFF.Name = "lblMFF"
		lblMFF.Text = ML("MFF path:")
		lblMFF.SetBounds 26, 24, 138, 18
		lblMFF.Caption = ML("MFF path:")
		lblMFF.Parent = @pnlIncludes
		' txtMFFpath
		txtMFFpath.Name = "txtMFFpath"
		txtMFFpath.SetBounds 90, 24, 297, 20
		txtMFFpath.Parent = @pnlIncludes
		' cmdMFFPath
		cmdMFFPath.Name = "cmdMFFPath"
		cmdMFFPath.Text = "..."
		cmdMFFPath.SetBounds 387, 23, 24, 22
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
		chkTabAsSpaces.SetBounds 10, 63, 264, 18
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
		lblTabSize.SetBounds 66, 111, 138, 16
		lblTabSize.Caption = ML("Tab Size:")
		lblTabSize.Parent = @pnlCodeEditor
		' txtTabSize
		txtTabSize.Name = "txtTabSize"
		txtTabSize.Text = ""
		txtTabSize.SetBounds 209, 109, 90, 20
		txtTabSize.Parent = @pnlCodeEditor
		' chkShowSpaces
		chkShowSpaces.Name = "chkShowSpaces"
		chkShowSpaces.Text = ML("Show Spaces")
		chkShowSpaces.SetBounds 10, 43, 264, 18
		chkShowSpaces.Caption = ML("Show Spaces")
		chkShowSpaces.Parent = @pnlCodeEditor
		' lstIncludePaths
		lstIncludePaths.Name = "lstIncludePaths"
		lstIncludePaths.Text = "ListControl1"
		lstIncludePaths.SetBounds 26, 71, 360, 134
		lstIncludePaths.Parent = @pnlIncludes
		' lstLibraryPaths
		lstLibraryPaths.Name = "lstLibraryPaths"
		lstLibraryPaths.Text = "ListControl11"
		lstLibraryPaths.SetBounds 26, 252, 360, 132
		lstLibraryPaths.Parent = @pnlIncludes
		' lblOthers
		lblOthers.Name = "lblOthers"
		lblOthers.Text = "Others:"
		lblOthers.SetBounds 26, 48, 138, 18
		lblOthers.Caption = "Others:"
		lblOthers.Parent = @pnlIncludes
		' cmdAddInclude
		cmdAddInclude.Name = "cmdAddInclude"
		cmdAddInclude.Text = "+"
		cmdAddInclude.SetBounds 386, 70, 24, 22
		cmdAddInclude.Caption = "+"
		cmdAddInclude.Parent = @pnlIncludes
		' cmdRemoveInclude
		cmdRemoveInclude.Name = "cmdRemoveInclude"
		cmdRemoveInclude.Text = "-"
		cmdRemoveInclude.SetBounds 386, 91, 24, 22
		cmdRemoveInclude.Caption = "-"
		cmdRemoveInclude.Parent = @pnlIncludes
		' cmdAddLibrary
		cmdAddLibrary.Name = "cmdAddLibrary"
		cmdAddLibrary.Text = "+"
		cmdAddLibrary.SetBounds 386, 251, 24, 22
		cmdAddLibrary.Caption = "+"
		cmdAddLibrary.Parent = @pnlIncludes
		' cmdRemoveLibrary
		cmdRemoveLibrary.Name = "cmdRemoveLibrary"
		cmdRemoveLibrary.Text = "-"
		cmdRemoveLibrary.SetBounds 386, 272, 24, 22
		cmdRemoveLibrary.Caption = "-"
		cmdRemoveLibrary.Parent = @pnlIncludes
		' cmdDebugger
		cmdDebugger.Name = "cmdDebugger"
		cmdDebugger.Text = "..."
		cmdDebugger.SetBounds 388, 313, 24, 22
		cmdDebugger.Caption = "..."
		cmdDebugger.OnClick = @cmdDebugger_Click
		cmdDebugger.Parent = @pnlDebugger
		' cmdTerminal
		cmdTerminal.Name = "cmdTerminal"
		cmdTerminal.Text = "..."
		cmdTerminal.SetBounds 388, 313, 24, 22
		cmdTerminal.Caption = "..."
		cmdTerminal.OnClick = @cmdTerminal_Click
		cmdTerminal.Parent = @pnlTerminal
		' lblHistoryLimit
		lblHistoryLimit.Name = "lblHistoryLimit"
		lblHistoryLimit.Text = ML("History limit:")
		lblHistoryLimit.SetBounds 66, 134, 150, 17
		lblHistoryLimit.Parent = @pnlCodeEditor
		' txtHistoryLimit
		txtHistoryLimit.Name = "txtHistoryLimit"
		txtHistoryLimit.SetBounds 209, 132, 90, 20
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
		cboCase.SetBounds 209, 85, 162, 21
		cboCase.Parent = @pnlCodeEditor
		' chkChangeKeywordsCase
		chkChangeKeywordsCase.Name = "chkChangeKeywordsCase"
		chkChangeKeywordsCase.Text = ML("Change Keywords Case to:")
		chkChangeKeywordsCase.SetBounds 10, 86, 194, 18
		chkChangeKeywordsCase.Parent = @pnlCodeEditor
		' cboTabStyle
		cboTabStyle.Name = "cboTabStyle"
		cboTabStyle.Text = "cboCase1"
		cboTabStyle.SetBounds 209, 61, 162, 21
		cboTabStyle.Parent = @pnlCodeEditor
		' grbColors
		grbColors.Name = "grbColors"
		grbColors.Text = "Colors"
		grbColors.SetBounds 10, -2, 416, 336
		grbColors.Parent = @pnlColorsAndFonts
		' grbFont
		grbFont.Name = "grbFont"
		grbFont.Text = "Font (applies to all styles)"
		grbFont.SetBounds 10, 342, 416, 56
		grbFont.Parent = @pnlColorsAndFonts
		' grbMakeToolPaths
		With grbMakeToolPaths
			.Name = "grbMakeToolPaths"
			.Text = "Make Tool Paths"
			.SetBounds 10, 70, 416, 328
			.Parent = @pnlMake
		End With
		' lvMakeToolPaths
		With lvMakeToolPaths
			.Name = "lvMakeToolPaths"
			.Text = "lvMakeToolPaths"
			.SetBounds 26, 94, 384, 216
			.Parent = @pnlMake
		End With
		' txtMakeVersion
		With txtMakeVersion
			.Name = "txtMakeVersion"
			.SetBounds 26, 338, 386, 20
			.Text = ""
			.Parent = @pnlMake
		End With
		' cmdAddMakeTool
		With cmdAddMakeTool
			.Name = "cmdAddMakeTool"
			.Text = "Add"
			.SetBounds 25, 361, 128, 24
			.Caption = "Add"
			.OnClick = @cmdAddMakeTool_Click
			.Parent = @pnlMake
		End With
		' cmdRemoveMakeTool
		With cmdRemoveMakeTool
			.Name = "cmdRemoveMakeTool"
			.Text = "Remove"
			.SetBounds 155, 361, 128, 24
			.Caption = "Remove"
			.OnClick = @cmdRemoveMakeTool_Click
			.Parent = @pnlMake
		End With
		' cmdClearMakeTool
		With cmdClearMakeTools
			.Name = "cmdClearMakeTools"
			.Text = "Clear"
			.SetBounds 285, 361, 128, 24
			.Caption = "Clear"
			.OnClick = @cmdClearMakeTools_Click
			.Parent = @pnlMake
		End With
		' grbDefaultMakeTool
		With grbDefaultMakeTool
			.Name = "grbDefaultMakeTool"
			.Text = "Default Make Tool"
			.SetBounds 10, -2, 416, 64
			.Parent = @pnlMake
		End With
		' cboMakeTool
		With cboMakeTool
			.Name = "cboMakeTool"
			.Text = "cboMakeTool"
			.SetBounds 26, 24, 384, 21
			.Parent = @pnlMake
		End With
		' txtMake
		txtMake.Name = "txtMake"
		txtMake.Text = "make"
		txtMake.SetBounds 26, 314, 362, 20
		txtMake.Parent = @pnlMake
		' CommandButton7
		CommandButton7.Name = "CommandButton7"
		CommandButton7.Text = "..."
		CommandButton7.SetBounds 388, 313, 24, 22
		CommandButton7.Caption = "..."
		CommandButton7.OnClick = @CommandButton7_Click
		CommandButton7.Parent = @pnlMake
		' cboTheme
		cboTheme.Name = "cboTheme"
		cboTheme.Text = "ComboBoxEdit2"
		cboTheme.SetBounds 24, 24, 224, 21
		cboTheme.OnChange = @cboTheme_Change
		cboTheme.Parent = @pnlColorsAndFonts
		' lstColorKeys
		lstColorKeys.Name = "lstColorKeys"
		lstColorKeys.Text = "ListControl1"
		lstColorKeys.SetBounds 24, 56, 224, 264
		lstColorKeys.OnChange = @lstColorKeys_Change
		lstColorKeys.Parent = @pnlColorsAndFonts
		' cmdAdd
		cmdAdd.Name = "cmdAdd"
		cmdAdd.Text = "Add"
		cmdAdd.SetBounds 264, 23, 71, 23
		cmdAdd.Caption = "Add"
		cmdAdd.OnClick = @cmdAdd_Click
		cmdAdd.Parent = @pnlColorsAndFonts
		' cmdRemove
		cmdRemove.Name = "cmdRemove"
		cmdRemove.Text = "Remove"
		cmdRemove.SetBounds 336, 23, 71, 23
		cmdRemove.Caption = "Remove"
		cmdRemove.OnClick = @cmdRemove_Click
		cmdRemove.Parent = @pnlColorsAndFonts
		' lblColorForeground
		lblColorForeground.Name = "lblColorForeground"
		lblColorForeground.Text = ""
		lblColorForeground.SetBounds 9, 16, 72, 20
		lblColorForeground.BackColor = 0
		lblColorForeground.Parent = @pnlColor
		' cmdForeground
		cmdForeground.Name = "cmdForeground"
		cmdForeground.Text = "..."
		cmdForeground.SetBounds 79, 15, 24, 22
		cmdForeground.Caption = "..."
		cmdForeground.OnClick = @cmdForeground_Click
		cmdForeground.Parent = @pnlColor
		' cmdFont
		cmdFont.Name = "cmdFont"
		cmdFont.Text = "..."
		cmdFont.SetBounds 384, 363, 24, 22
		cmdFont.Caption = "..."
		cmdFont.OnClick = @cmdFont_Click
		cmdFont.Parent = @pnlColorsAndFonts
		' lblFont
		lblFont.Name = "lblFont"
		lblFont.Text = "Font"
		lblFont.SetBounds 35, 366, 344, 16
		lblFont.Caption = "Font"
		lblFont.Parent = @pnlColorsAndFonts
		' txtProjectsPath
		txtProjectsPath.Name = "txtProjectsPath"
		txtProjectsPath.Text = "./Projects"
		txtProjectsPath.SetBounds 10, 368, 390, 20
		txtProjectsPath.Parent = @pnlGeneral
		' cmdProjectsPath
		cmdProjectsPath.Name = "cmdProjectsPath"
		cmdProjectsPath.Text = "..."
		cmdProjectsPath.SetBounds 400, 367, 24, 22
		cmdProjectsPath.Caption = "..."
		cmdProjectsPath.Parent = @pnlGeneral
		' lblProjectsPath
		lblProjectsPath.Name = "lblProjectsPath"
		lblProjectsPath.Text = "Projects path:"
		lblProjectsPath.SetBounds 13, 350, 96, 16
		lblProjectsPath.Caption = "Projects path:"
		lblProjectsPath.Parent = @pnlGeneral
		' lblColorBackground
		lblColorBackground.Name = "lblColorBackground"
		lblColorBackground.SetBounds 9, 56, 72, 20
		lblColorBackground.BackColor = 0
		lblColorBackground.Text = ""
		lblColorBackground.Parent = @pnlColor
		' cmdBackground
		cmdBackground.Name = "cmdBackground"
		cmdBackground.Text = "..."
		cmdBackground.SetBounds 79, 55, 24, 22
		cmdBackground.Caption = "..."
		cmdBackground.OnClick = @cmdBackground_Click
		cmdBackground.Parent = @pnlColor
		' lblForeground
		lblForeground.Name = "lblForeground"
		lblForeground.Text = "Foreground:"
		lblForeground.SetBounds 8, 0, 136, 16
		lblForeground.Caption = "Foreground:"
		lblForeground.Parent = @pnlColor
		' lblBackground
		lblBackground.Name = "lblBackground"
		lblBackground.Text = "Background:"
		lblBackground.SetBounds 8, 40, 136, 16
		lblBackground.Caption = "Background:"
		lblBackground.Parent = @pnlColor
		' lblIndicator
		lblIndicator.Name = "lblIndicator"
		lblIndicator.Text = "Indicator:"
		lblIndicator.SetBounds 8, 80, 136, 16
		lblIndicator.Caption = "Indicator:"
		lblIndicator.Parent = @pnlColor
		' lblColorIndicator
		lblColorIndicator.Name = "lblColorIndicator"
		lblColorIndicator.Text = ""
		lblColorIndicator.SetBounds 9, 96, 72, 20
		lblColorIndicator.BackColor = 0
		lblColorIndicator.Parent = @pnlColor
		' cmdIndicator
		cmdIndicator.Name = "cmdIndicator"
		cmdIndicator.Text = "..."
		cmdIndicator.SetBounds 79, 95, 24, 22
		cmdIndicator.Caption = "..."
		cmdIndicator.OnClick = @cmdIndicator_Click
		cmdIndicator.Parent = @pnlColor
		' 
		' chkForeground
		chkForeground.Name = "chkForeground"
		chkForeground.Text = "Auto"
		chkForeground.SetBounds 112, 19, 48, 16
		chkForeground.Caption = "Auto"
		chkForeground.OnClick = @chkForeground_Click
		chkForeground.Parent = @pnlColor
		' chkBackground
		chkBackground.Name = "chkBackground"
		chkBackground.Text = "Auto"
		chkBackground.SetBounds 112, 59, 48, 16
		chkBackground.Caption = "Auto"
		chkBackground.OnClick = @chkBackground_Click
		chkBackground.Parent = @pnlColor
		' chkIndicator
		chkIndicator.Name = "chkIndicator"
		chkIndicator.Text = "Auto"
		chkIndicator.SetBounds 112, 99, 48, 16
		chkIndicator.Caption = "Auto"
		chkIndicator.OnClick = @chkIndicator_Click
		chkIndicator.Parent = @pnlColor
		' chkBold
		chkBold.Name = "chkBold"
		chkBold.Text = "Bold"
		chkBold.SetBounds 8, 195, 104, 16
		chkBold.Caption = "Bold"
		chkBold.OnClick = @chkBold_Click
		chkBold.Parent = @pnlColor
		' chkItalic
		chkItalic.Name = "chkItalic"
		chkItalic.Text = "Italic"
		chkItalic.SetBounds 8, 219, 72, 16
		chkItalic.Caption = "Italic"
		chkItalic.OnClick = @chkItalic_Click
		chkItalic.Parent = @pnlColor
		' chkUnderline
		chkUnderline.Name = "chkUnderline"
		chkUnderline.Text = "Underline"
		chkUnderline.SetBounds 8, 243, 104, 16
		chkUnderline.Caption = "Underline"
		chkUnderline.OnClick = @chkUnderline_Click
		chkUnderline.Parent = @pnlColor
		' pnlColor
		pnlColor.Name = "pnlColor"
		pnlColor.Text = ""
		pnlColor.SetBounds 256, 54, 160, 264
		pnlColor.Parent = @pnlColorsAndFonts
		' chkUseMakeOnStartWithCompile
		chkUseMakeOnStartWithCompile.Name = "chkUseMakeOnStartWithCompile"
		chkUseMakeOnStartWithCompile.Text = ML("Use make on start with compile (if exists makefile)")
		chkUseMakeOnStartWithCompile.SetBounds 10, 64, 400, 16
		chkUseMakeOnStartWithCompile.Caption = ML("Use make on start with compile (if exists makefile)")
		chkUseMakeOnStartWithCompile.Parent = @pnlGeneral
		' lvCompilerPaths
		With lvCompilerPaths
			.Name = "lvCompilerPaths"
			.Text = "ListView1"
			.SetBounds 26, 158, 384, 152
			.Parent = @pnlCompiler
		End With
		' cboCompiler32
		With cboCompiler32
			.Name = "cboCompiler32"
			.Text = "ComboBoxEdit2"
			.SetBounds 26, 40, 384, 21
			.Parent = @pnlCompiler
		End With
		' cboCompiler64
		With cboCompiler64
			.Name = "cboCompiler64"
			.Text = "ComboBoxEdit21"
			.SetBounds 26, 88, 384, 21
			.Parent = @pnlCompiler
		End With
		' cmdRemoveCompiler
		With cmdRemoveCompiler
			.Name = "cmdRemoveCompiler"
			.Text = "Remove"
			.SetBounds 155, 361, 128, 24
			.Caption = "Remove"
			.OnClick = @cmdRemoveCompiler_Click
			.Parent = @pnlCompiler
		End With
		' cmdClearCompilers
		With cmdClearCompilers
			.Name = "cmdClearCompilers"
			.Text = "Clear"
			.SetBounds 285, 361, 128, 24
			.Caption = "Clear"
			.OnClick = @cmdClearCompilers_Click
			.Parent = @pnlCompiler
		End With
		' TextBox2
		With TextBox2
			.Name = "TextBox2"
			.Text = ""
			.SetBounds 26, 338, 386, 20
			.Parent = @pnlCompiler
		End With
		' lvDebuggerPaths
		With lvDebuggerPaths
			.Name = "lvDebuggerPaths"
			.Text = "lvCompilerPaths1"
			.SetBounds 26, 94, 384, 216
			.Parent = @pnlDebugger
		End With
		' txtDebuggerVersion
		With txtDebuggerVersion
			.Name = "txtDebuggerVersion"
			.SetBounds 26, 338, 386, 20
			.Parent = @pnlDebugger
		End With
		' cmdAddDebugger
		With cmdAddDebugger
			.Name = "cmdAddDebugger"
			.Text = "Add"
			.SetBounds 25, 361, 128, 24
			.Caption = "Add"
			.OnClick = @cmdAddDebugger_Click
			.Parent = @pnlDebugger
		End With
		' cmdRemoveDebugger
		With cmdRemoveDebugger
			.Name = "cmdRemoveDebugger"
			.Text = "Remove"
			.SetBounds 155, 361, 128, 24
			.Caption = "Remove"
			.OnClick = @cmdRemoveDebugger_Click
			.Parent = @pnlDebugger
		End With
		' cmdClearDebuggers
		With cmdClearDebuggers
			.Name = "cmdClearDebuggers"
			.Text = "Clear"
			.SetBounds 285, 361, 128, 24
			.Caption = "Clear"
			.OnClick = @cmdClearDebuggers_Click
			.Parent = @pnlDebugger
		End With
	End Constructor
	
	#ifndef _NOT_AUTORUN_FORMS_
		fOptions.Show
		
		App.Run
	#endif
'#End Region

Private Sub frmOptions.cmdOK_Click(ByRef Sender As Control)
	cmdApply_Click(Sender)
	Cast(frmOptions Ptr, Sender.Parent)->CloseForm
End Sub

Private Sub frmOptions.cmdCancel_Click(ByRef Sender As Control)
	Cast(frmOptions Ptr, Sender.Parent)->CloseForm
End Sub

Sub frmOptions.LoadSettings()
	With fOptions
		.chkTabAsSpaces.Checked = TabAsSpaces
		.cboTabStyle.ItemIndex = ChoosedTabStyle
		.cboCase.ItemIndex = ChoosedKeyWordsCase
		.chkChangeKeywordsCase.Checked = ChangeKeywordsCase
		.TextBox1.Text = ""
		.TextBox2.Text = ""
		.txtMake.Text = ""
		.txtDebugger.Text = ""
		.txtTerminal.Text = ""
		.chkUseMakeOnStartWithCompile.Checked = UseMakeOnStartWithCompile
		.TextBox3.Text = WGet(HelpPath)
		.txtTabSize.Text = Str(TabWidth)
		.txtHistoryLimit.Text = Str(HistoryLimit)
		.txtMFFPath.Text = *MFFPath
		.txtProjectsPath.Text = *ProjectsPath
		.CheckBox1.Checked = AutoIncrement
		.chkEnableAutoComplete.Checked = AutoComplete
		.chkAutoSaveCompile.Checked = AutoSaveCompile
		.chkAutoIndentation.Checked = AutoIndentation
		.chkAutoCreateRC.Checked = AutoCreateRC
		.chkShowSpaces.Checked = ShowSpaces
		.txtGridSize.Text = Str(GridSize)
		.chkShowAlignmentGrid.Checked = ShowAlignmentGrid
		.chkSnapToGrid.Checked = SnapToGridOption
		.ComboBoxEdit1.Clear
		Dim As String f
		Dim As WString Ptr s
		f = Dir(ExePath & "/Settings/Languages/*.lng")
		While f <> ""
			Open ExePath & "/Settings/Languages/" & f For Input Encoding "utf-8" As #1
			WReallocate s, LOF(1)
			If Not EOF(1) Then
				Line Input #1, *s
				Languages.Add Left(f, Len(f) - 4)
				.ComboBoxEdit1.AddItem *s
			End If
			Close #1
			f = Dir()
		Wend
		WDeallocate s
		newIndex = Languages.IndexOf(CurLanguage)
		.ComboBoxEdit1.ItemIndex = newIndex
		oldIndex = newIndex
		.cboTheme.Clear
		f = Dir(ExePath & "/Settings/Themes/*.ini")
		While f <> ""
			.cboTheme.AddItem Left(f, Len(f) - 4)
			f = Dir()
		Wend
		.cboTheme.ItemIndex = .cboTheme.IndexOf(*CurrentTheme)
		.cboCompiler32.Clear
		.cboCompiler64.Clear
		.lvCompilerPaths.ListItems.Clear
		.cboCompiler32.AddItem ML("(not selected)")
		.cboCompiler64.AddItem ML("(not selected)")
		For i As Integer = 0 To pCompilers->Count - 1
			.lvCompilerPaths.ListItems.Add pCompilers->Item(i)->Key
			.lvCompilerPaths.ListItems.Item(i)->Text(1) = pCompilers->Item(i)->Text
			.cboCompiler32.AddItem pCompilers->Item(i)->Key
			.cboCompiler64.AddItem pCompilers->Item(i)->Key
		Next
		.cboCompiler32.ItemIndex = Max(0, .cboCompiler32.IndexOf(*DefaultCompiler32))
		.cboCompiler64.ItemIndex = Max(0, .cboCompiler64.IndexOf(*DefaultCompiler64))
		.cboMakeTool.Clear
		.lvMakeToolPaths.ListItems.Clear
		.cboMakeTool.AddItem ML("(not selected)")
		For i As Integer = 0 To pMakeTools->Count - 1
			.lvMakeToolPaths.ListItems.Add pMakeTools->Item(i)->Key
			.lvMakeToolPaths.ListItems.Item(i)->Text(1) = pMakeTools->Item(i)->Text
			.cboMakeTool.AddItem pMakeTools->Item(i)->Key
		Next
		.cboMakeTool.ItemIndex = Max(0, .cboMakeTool.IndexOf(*DefaultMakeTool))
		.cboDebugger.Clear
		.lvDebuggerPaths.ListItems.Clear
		.cboDebugger.AddItem ML("Integrated IDE Debugger")
		For i As Integer = 0 To pDebuggers->Count - 1
			.lvDebuggerPaths.ListItems.Add pDebuggers->Item(i)->Key
			.lvDebuggerPaths.ListItems.Item(i)->Text(1) = pDebuggers->Item(i)->Text
			.cboDebugger.AddItem pDebuggers->Item(i)->Key
		Next
		.cboDebugger.ItemIndex = Max(0, .cboDebugger.IndexOf(*DefaultDebugger))
		.cboTerminal.Clear
		.lvTerminalPaths.ListItems.Clear
		.cboTerminal.AddItem ML("(not selected)")
		For i As Integer = 0 To pTerminals->Count - 1
			.lvTerminalPaths.ListItems.Add pTerminals->Item(i)->Key
			.lvTerminalPaths.ListItems.Item(i)->Text(1) = pTerminals->Item(i)->Text
			.cboTerminal.AddItem pTerminals->Item(i)->Key
		Next
		.cboTerminal.ItemIndex = Max(0, .cboTerminal.IndexOf(*DefaultTerminal))
		For i As Integer = 0 To 13
			For j As Integer = 0 To 5
				.Colors(i, j) = -2
			Next
		Next
		.Colors(0, 0) = BookmarksForeground
		.Colors(0, 1) = BookmarksBackground
		.Colors(0, 2) = BookmarksIndicator
		.Colors(0, 3) = BookmarksBold
		
		.Colors(0, 4) = BookmarksItalic
		.Colors(0, 5) = BookmarksUnderline
		.Colors(1, 0) = BreakpointsForeground
		.Colors(1, 1) = BreakpointsBackground
		.Colors(1, 2) = BreakpointsIndicator
		.Colors(1, 3) = BreakpointsBold
		.Colors(1, 4) = BreakpointsItalic
		.Colors(1, 5) = BreakpointsUnderline
		.Colors(2, 0) = CommentsForeground
		.Colors(2, 1) = CommentsBackground
		.Colors(2, 3) = CommentsBold
		.Colors(2, 4) = CommentsItalic
		.Colors(2, 5) = CommentsUnderline
		.Colors(3, 0) = CurrentLineForeground
		.Colors(3, 1) = CurrentLineBackground
		.Colors(4, 0) = ExecutionLineForeground
		.Colors(4, 1) = ExecutionLineBackground
		.Colors(4, 2) = ExecutionLineIndicator
		.Colors(5, 0) = FoldLinesForeground
		.Colors(6, 0) = IndicatorLinesForeground
		.Colors(7, 0) = KeywordsForeground
		.Colors(7, 1) = KeywordsBackground
		.Colors(7, 3) = KeywordsBold
		.Colors(7, 4) = KeywordsItalic
		.Colors(7, 5) = KeywordsUnderline
		.Colors(8, 0) = LineNumbersForeground
		.Colors(8, 1) = LineNumbersBackground
		.Colors(8, 3) = LineNumbersBold
		.Colors(8, 4) = LineNumbersItalic
		.Colors(8, 5) = LineNumbersUnderline
		.Colors(9, 0) = NormalTextForeground
		.Colors(9, 1) = NormalTextBackground
		.Colors(9, 3) = NormalTextBold
		.Colors(9, 4) = NormalTextItalic
		.Colors(9, 5) = NormalTextUnderline
		.Colors(10, 0) = PreprocessorsForeground
		.Colors(10, 1) = PreprocessorsBackground
		.Colors(10, 3) = PreprocessorsBold
		.Colors(10, 4) = PreprocessorsItalic
		.Colors(10, 5) = PreprocessorsUnderline
		.Colors(11, 0) = SelectionForeground
		.Colors(11, 1) = SelectionBackground
		.Colors(12, 0) = SpaceIdentifiersForeground
		.Colors(13, 0) = StringsForeground
		.Colors(13, 1) = StringsBackground
		.Colors(13, 3) = StringsBold
		.Colors(13, 4) = StringsItalic
		.Colors(13, 5) = StringsUnderline
		.lstColorKeys_Change(.lstColorKeys)
		WLet .EditFontName, *EditorFontName
		.EditFontSize = EditorFontSize
		.lblFont.Font.Name = *EditorFontName
		.lblFont.Caption = *.EditFontName & ", " & .EditFontSize & "pt"
		.tvOptions.SelectedNode = .tvOptions.Nodes.Item(0)
		.TreeView1_SelChange .tvOptions, *.tvOptions.Nodes.Item(0)
	End With
End Sub

Private Sub frmOptions.Form_Create(ByRef Sender As Control)
	With fOptions
		.tvOptions.Nodes.Clear
		Var tnGeneral = .tvOptions.Nodes.Add(ML("General"), "General")
		Var tnEditor = .tvOptions.Nodes.Add(ML("Code Editor"), "CodeEditor")
		Var tnCompiler = .tvOptions.Nodes.Add(ML("Compiler"), "Compiler")
		Var tnDebugger = .tvOptions.Nodes.Add(ML("Debugger"), "Debugger")
		.tvOptions.Nodes.Add(ML("Designer"), "Designer")
		tnEditor->Nodes.Add(ML("Colors And Fonts"), "ColorsAndFonts")
		tnCompiler->Nodes.Add(ML("Includes"), "Includes")
		tnCompiler->Nodes.Add(ML("Make Tool"), "MakeTool")
		tnGeneral->Nodes.Add(ML("Localization"), "Localization")
		tnDebugger->Nodes.Add(ML("Terminal"), "Terminal")
		.tvOptions.Nodes.Add(ML("Help"), "Help")
		.tvOptions.ExpandAll
		.lvCompilerPaths.Columns.Add ML("Version"), , 200
		.lvCompilerPaths.Columns.Add ML("Path"), , 200
		.lvMakeToolPaths.Columns.Add ML("Version"), , 200
		.lvMakeToolPaths.Columns.Add ML("Path"), , 200
		.lvDebuggerPaths.Columns.Add ML("Version"), , 200
		.lvDebuggerPaths.Columns.Add ML("Path"), , 200
		.lvTerminalPaths.Columns.Add ML("Version"), , 200
		.lvTerminalPaths.Columns.Add ML("Path"), , 200
		.cboCase.AddItem ML("Original Case")
		.cboCase.AddItem ML("Lower Case")
		.cboCase.AddItem ML("Upper Case")
		.cboTabStyle.AddItem ML("Everywhere")
		.cboTabStyle.AddItem ML("Only after the words")
		.lstColorKeys.AddItem "Bookmarks"
		.lstColorKeys.AddItem "Breakpoints"
		.lstColorKeys.AddItem "Comments"
		.lstColorKeys.AddItem "Current Line"
		.lstColorKeys.AddItem "Executed Line"
		.lstColorKeys.AddItem "Fold Lines"
		.lstColorKeys.AddItem "Indicator Lines"
		.lstColorKeys.AddItem "Keywords"
		.lstColorKeys.AddItem "Line Numbers"
		.lstColorKeys.AddItem "Normal Text"
		.lstColorKeys.AddItem "Preprocessors"
		.lstColorKeys.AddItem "Selection"
		.lstColorKeys.AddItem "Space Identifiers"
		.lstColorKeys.AddItem "Strings"
		.lstColorKeys.ItemIndex = 0
		.LoadSettings
	End With
End Sub

Private Sub frmOptions.cmdApply_Click(ByRef Sender As Control)
	On Error Goto ErrorHandler
	With fOptions
		pCompilers->Clear
		Dim As WString Ptr tempStr
		For i As Integer = 0 To .lvCompilerPaths.ListItems.Count - 1
			WLet tempStr, .lvCompilerPaths.ListItems.Item(i)->Text(0)
			pCompilers->Add *tempStr, .lvCompilerPaths.ListItems.Item(i)->Text(1)
		Next
		WLet DefaultCompiler32, IIf(.cboCompiler32.ItemIndex = 0, "", .cboCompiler32.Text)
		WLet DefaultCompiler64, IIf(.cboCompiler64.ItemIndex = 0, "", .cboCompiler64.Text)
		WLet Compiler32Path, pCompilers->Get(*DefaultCompiler32)
		WLet Compiler64Path, pCompilers->Get(*DefaultCompiler64)
		pMakeTools->Clear
		For i As Integer = 0 To .lvMakeToolPaths.ListItems.Count - 1
			WLet tempStr, .lvMakeToolPaths.ListItems.Item(i)->Text(0)
			pMakeTools->Add *tempStr, .lvMakeToolPaths.ListItems.Item(i)->Text(1)
		Next
		WLet DefaultMakeTool, IIf(.cboMakeTool.ItemIndex = 0, "", .cboMakeTool.Text)
		WLet MakeToolPath, pMakeTools->Get(*DefaultMakeTool)
		pDebuggers->Clear
		For i As Integer = 0 To .lvDebuggerPaths.ListItems.Count - 1
			WLet tempStr, .lvDebuggerPaths.ListItems.Item(i)->Text(0)
			pDebuggers->Add *tempStr, .lvDebuggerPaths.ListItems.Item(i)->Text(1)
		Next
		WLet DefaultDebugger, IIf(.cboDebugger.ItemIndex = 0, "", .cboDebugger.Text)
		WLet DebuggerPath, pDebuggers->Get(*DefaultDebugger)
		pTerminals->Clear
		For i As Integer = 0 To .lvTerminalPaths.ListItems.Count - 1
			WLet tempStr, .lvTerminalPaths.ListItems.Item(i)->Text(0)
			pTerminals->Add *tempStr, .lvTerminalPaths.ListItems.Item(i)->Text(1)
		Next
		WDeallocate tempStr
		WLet DefaultTerminal, IIf(.cboTerminal.ItemIndex = 0, "", .cboTerminal.Text)
		WLet TerminalPath, pTerminals->Get(*DefaultTerminal)
		WLet HelpPath, .TextBox3.Text
		WLet MFFPath, .txtMFFPath.Text
		WLet ProjectsPath, .txtProjectsPath.Text
		#ifdef __FB_64BIT__
			WLet MFFDll, *MFFPath & "/mff64.dll"
		#else
			WLet MFFDll, *MFFPath & "/mff32.dll"
		#endif
		TabWidth = Val(.txtTabSize.Text)
		HistoryLimit = Val(.txtHistoryLimit.Text)
		UseMakeOnStartWithCompile = .chkUseMakeOnStartWithCompile.Checked
		AutoIncrement = .CheckBox1.Checked
		AutoIndentation = .chkAutoIndentation.Checked
		AutoComplete = .chkEnableAutoComplete.Checked
		AutoCreateRC = .chkAutoCreateRC.Checked
		AutoSaveCompile = .chkAutoSaveCompile.Checked
		ShowSpaces = .chkShowSpaces.Checked
		TabAsSpaces = .chkTabAsSpaces.Checked
		ChoosedTabStyle = .cboTabStyle.ItemIndex
		GridSize = Val(.txtGridSize.Text)
		ShowAlignmentGrid = .chkShowAlignmentGrid.Checked
		SnapToGridOption = .chkSnapToGrid.Checked
		ChangeKeywordsCase = .chkChangeKeywordsCase.Checked
		ChoosedKeywordsCase = .cboCase.ItemIndex
		WLet CurrentTheme, .cboTheme.Text
		WLet EditorFontName, *.EditFontName
		EditorFontSize = .EditFontSize
		BookmarksForegroundOption = .Colors(0, 0)
		BookmarksBackgroundOption = .Colors(0, 1)
		BookmarksIndicatorOption = .Colors(0, 2)
		BookmarksBold = .Colors(0, 3)
		BookmarksItalic = .Colors(0, 4)
		BookmarksUnderline = .Colors(0, 5)
		BreakpointsForegroundOption = .Colors(1, 0)
		BreakpointsBackgroundOption = .Colors(1, 1)
		BreakpointsIndicatorOption = .Colors(1, 2)
		BreakpointsBold = .Colors(1, 3)
		BreakpointsItalic = .Colors(1, 4)
		BreakpointsUnderline = .Colors(1, 5)
		CommentsForegroundOption = .Colors(2, 0)
		CommentsBackgroundOption = .Colors(2, 1)
		CommentsBold = .Colors(2, 3)
		CommentsItalic = .Colors(2, 4)
		CommentsUnderline = .Colors(2, 5)
		CurrentLineForegroundOption = .Colors(3, 0)
		CurrentLineBackgroundOption = .Colors(3, 1)
		ExecutionLineForegroundOption = .Colors(4, 0)
		ExecutionLineBackgroundOption = .Colors(4, 1)
		ExecutionLineIndicatorOption = .Colors(4, 2)
		FoldLinesForegroundOption = .Colors(5, 0)
		IndicatorLinesForegroundOption = .Colors(6, 0)
		KeywordsForegroundOption = .Colors(7, 0)
		KeywordsBackgroundOption = .Colors(7, 1)
		KeywordsBold = .Colors(7, 3)
		KeywordsItalic = .Colors(7, 4)
		KeywordsUnderline = .Colors(7, 5)
		LineNumbersForegroundOption = .Colors(8, 0)
		LineNumbersBackgroundOption = .Colors(8, 1)
		LineNumbersBold = .Colors(8, 3)
		LineNumbersItalic = .Colors(8, 4)
		LineNumbersUnderline = .Colors(8, 5)
		NormalTextForegroundOption = .Colors(9, 0)
		NormalTextBackgroundOption = .Colors(9, 1)
		NormalTextBold = .Colors(9, 3)
		NormalTextItalic = .Colors(9, 4)
		NormalTextUnderline = .Colors(9, 5)
		PreprocessorsForegroundOption = .Colors(10, 0)
		PreprocessorsBackgroundOption = .Colors(10, 1)
		PreprocessorsBold = .Colors(10, 3)
		PreprocessorsItalic = .Colors(10, 4)
		PreprocessorsUnderline = .Colors(10, 5)
		SelectionForegroundOption = .Colors(11, 0)
		SelectionBackgroundOption = .Colors(11, 1)
		SpaceIdentifiersForegroundOption = .Colors(12, 0)
		StringsForegroundOption = .Colors(13, 0)
		StringsBackgroundOption = .Colors(13, 1)
		StringsBold = .Colors(13, 3)
		StringsItalic = .Colors(13, 4)
		StringsUnderline = .Colors(13, 5)
		SetAutoColors
		
		piniSettings->WriteString "Compilers", "DefaultCompiler32", *DefaultCompiler32
		piniSettings->WriteString "Compilers", "DefaultCompiler64", *DefaultCompiler64
		For i As Integer = 0 To pCompilers->Count - 1
			piniSettings->WriteString "Compilers", "Version_" & WStr(i), pCompilers->Item(i)->Key
			piniSettings->WriteString "Compilers", "Path_" & WStr(i), pCompilers->Item(i)->Text
		Next
		piniSettings->WriteString "MakeTools", "DefaultMakeTool", *DefaultMakeTool
		For i As Integer = 0 To pMakeTools->Count - 1
			piniSettings->WriteString "MakeTools", "Version_" & WStr(i), pMakeTools->Item(i)->Key
			piniSettings->WriteString "MakeTools", "Path_" & WStr(i), pMakeTools->Item(i)->Text
		Next
		piniSettings->WriteString "Debuggers", "DefaultDebugger", *DefaultDebugger
		For i As Integer = 0 To pDebuggers->Count - 1
			piniSettings->WriteString "Debuggers", "Version_" & WStr(i), pDebuggers->Item(i)->Key
			piniSettings->WriteString "Debuggers", "Path_" & WStr(i), pDebuggers->Item(i)->Text
		Next
		piniSettings->WriteString "Terminals", "DefaultTerminal", *DefaultTerminal
		For i As Integer = 0 To pTerminals->Count - 1
			piniSettings->WriteString "Terminals", "Version_" & WStr(i), pTerminals->Item(i)->Key
			piniSettings->WriteString "Terminals", "Path_" & WStr(i), pTerminals->Item(i)->Text
		Next
		piniSettings->WriteString "Options", "HelpPath", *HelpPath
		piniSettings->WriteString "Options", "MFFPath", *MFFPath
		piniSettings->WriteString "Options", "ProjectsPath", *ProjectsPath
		piniSettings->WriteString "Options", "Language", Languages.Item(.ComboBoxEdit1.ItemIndex)
		piniSettings->WriteInteger "Options", "TabWidth", TabWidth
		piniSettings->WriteInteger "Options", "HistoryLimit", HistoryLimit
		piniSettings->WriteBool "Options", "UseMakeOnStartWithCompile", UseMakeOnStartWithCompile
		piniSettings->WriteBool "Options", "AutoIncrement", AutoIncrement
		piniSettings->WriteBool "Options", "AutoIndentation", AutoIndentation
		piniSettings->WriteBool "Options", "AutoComplete", AutoComplete
		piniSettings->WriteBool "Options", "AutoCreateRC", AutoCreateRC
		piniSettings->WriteBool "Options", "AutoSaveBeforeCompiling", AutoSaveCompile
		piniSettings->WriteBool "Options", "ShowSpaces", ShowSpaces
		piniSettings->WriteBool "Options", "TabAsSpaces", TabAsSpaces
		piniSettings->WriteInteger "Options", "GridSize", GridSize
		piniSettings->WriteBool "Options", "ShowAlignmentGrid", ShowAlignmentGrid
		piniSettings->WriteBool "Options", "SnapToGrid", SnapToGridOption
		piniSettings->WriteBool "Options", "ChangeKeywordsCase", ChangeKeywordsCase
		piniSettings->WriteInteger "Options", "ChoosedKeywordsCase", ChoosedKeywordsCase
		
		piniSettings->WriteString "Options", "CurrentTheme", *CurrentTheme
		
		piniSettings->WriteString "Options", "EditorFontName", *EditorFontName
		piniSettings->WriteInteger "Options", "EditorFontSize", EditorFontSize
		
		piniTheme->Load ExePath & "/Settings/Themes/" & *CurrentTheme & ".ini"
		piniTheme->WriteInteger("Colors", "BookmarksForeground", BookmarksForeground)
		piniTheme->WriteInteger("Colors", "BookmarksBackground", BookmarksBackground)
		piniTheme->WriteInteger("Colors", "BookmarksIndicator", BookmarksIndicator)
		piniTheme->WriteInteger("FontStyles", "BookmarksBold", BookmarksBold)
		piniTheme->WriteInteger("FontStyles", "BookmarksItalic", BookmarksItalic)
		piniTheme->WriteInteger("FontStyles", "BookmarksUnderline", BookmarksUnderline)
		piniTheme->WriteInteger("Colors", "BreakpointsForeground", BreakpointsForeground)
		piniTheme->WriteInteger("Colors", "BreakpointsBackground", BreakpointsBackground)
		piniTheme->WriteInteger("Colors", "BreakpointsIndicator", BreakpointsIndicator)
		piniTheme->WriteInteger("FontStyles", "BreakpointsBold", BreakpointsBold)
		piniTheme->WriteInteger("FontStyles", "BreakpointsItalic", BreakpointsItalic)
		piniTheme->WriteInteger("FontStyles", "BreakpointsUnderline", BreakpointsUnderline)
		piniTheme->WriteInteger("Colors", "CommentsForeground", CommentsForeground)
		piniTheme->WriteInteger("Colors", "CommentsBackground", CommentsBackground)
		piniTheme->WriteInteger("FontStyles", "CommentsBold", CommentsBold)
		piniTheme->WriteInteger("FontStyles", "CommentsItalic", CommentsItalic)
		piniTheme->WriteInteger("FontStyles", "CommentsUnderline", CommentsUnderline)
		piniTheme->WriteInteger("Colors", "CurrentLineForeground", CurrentLineForeground)
		piniTheme->WriteInteger("Colors", "CurrentLineBackground", CurrentLineBackground)
		piniTheme->WriteInteger("Colors", "ExecutionLineForeground", ExecutionLineForeground)
		piniTheme->WriteInteger("Colors", "ExecutionLineBackground", ExecutionLineBackground)
		piniTheme->WriteInteger("Colors", "ExecutionLineIndicator", ExecutionLineIndicator)
		piniTheme->WriteInteger("Colors", "FoldLinesForeground", FoldLinesForeground)
		piniTheme->WriteInteger("Colors", "IndicatorLinesForeground", IndicatorLinesForeground)
		piniTheme->WriteInteger("Colors", "KeywordsForeground", KeywordsForeground)
		piniTheme->WriteInteger("Colors", "KeywordsBackground", KeywordsBackground)
		piniTheme->WriteInteger("FontStyles", "KeywordsBold", KeywordsBold)
		piniTheme->WriteInteger("FontStyles", "KeywordsItalic", KeywordsItalic)
		piniTheme->WriteInteger("FontStyles", "KeywordsUnderline", KeywordsUnderline)
		piniTheme->WriteInteger("Colors", "LineNumbersForeground", LineNumbersForeground)
		piniTheme->WriteInteger("Colors", "LineNumbersBackground", LineNumbersBackground)
		piniTheme->WriteInteger("FontStyles", "LineNumbersBold", LineNumbersBold)
		piniTheme->WriteInteger("FontStyles", "LineNumbersItalic", LineNumbersItalic)
		piniTheme->WriteInteger("FontStyles", "LineNumbersUnderline", LineNumbersUnderline)
		piniTheme->WriteInteger("Colors", "NormalTextForeground", NormalTextForeground)
		piniTheme->WriteInteger("Colors", "NormalTextBackground", NormalTextBackground)
		piniTheme->WriteInteger("FontStyles", "NormalTextBold", NormalTextBold)
		piniTheme->WriteInteger("FontStyles", "NormalTextItalic", NormalTextItalic)
		piniTheme->WriteInteger("FontStyles", "NormalTextUnderline", NormalTextUnderline)
		piniTheme->WriteInteger("Colors", "PreprocessorsForeground", PreprocessorsForeground)
		piniTheme->WriteInteger("Colors", "PreprocessorsBackground", PreprocessorsBackground)
		piniTheme->WriteInteger("FontStyles", "PreprocessorsBold", PreprocessorsBold)
		piniTheme->WriteInteger("FontStyles", "PreprocessorsItalic", PreprocessorsItalic)
		piniTheme->WriteInteger("FontStyles", "PreprocessorsUnderline", PreprocessorsUnderline)
		piniTheme->WriteInteger("Colors", "SelectionForeground", SelectionForeground)
		piniTheme->WriteInteger("Colors", "SelectionBackground", SelectionBackground)
		piniTheme->WriteInteger("Colors", "SpaceIdentifiersForeground", SpaceIdentifiersForeground)
		piniTheme->WriteInteger("Colors", "StringsForeground", StringsForeground)
		piniTheme->WriteInteger("Colors", "StringsBackground", StringsBackground)
		piniTheme->WriteInteger("FontStyles", "StringsBold", StringsBold)
		piniTheme->WriteInteger("FontStyles", "StringsItalic", StringsItalic)
		piniTheme->WriteInteger("FontStyles", "StringsUnderline", StringsUnderline)
		
		Dim As TabWindow Ptr tb
		For i As Integer = 0 To ptabCode->TabCount - 1
			tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
			tb->txtCode.Font.Name = *EditorFontName
			tb->txtCode.Font.Size = EditorFontSize
		Next
		newIndex = .ComboBoxEdit1.ItemIndex
	End With
	Exit Sub
	ErrorHandler:
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " " & _
	"in function " & ZGet(Erfn()) & " " & _
	"in module " & ZGet(Ermn())
End Sub

Private Sub frmOptions.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	'Sender.FreeWnd
	'Sender.Handle = 0
	#ifndef __USE_GTK__
		If newIndex <> oldIndex Then MsgBox ML("The language will change after the program is restarted"), "Visual FB Editor", MB_OK Or MB_ICONINFORMATION Or MB_TOPMOST Or MB_TASKMODAL
	#endif
End Sub

Private Sub frmOptions.Form_Show(ByRef Sender As Form)
	With fOptions
		.LoadSettings
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
			.TextBox2.Text = GetFileName(Left(GetFolderName(.OpenD.FileName), Len(GetFolderName(.OpenD.FileName)) - 1))
		End If
	End With
End Sub

Private Sub frmOptions.TreeView1_SelChange(ByRef Sender As TreeView, ByRef Item As TreeNode)
	With fOptions
		Dim Key As String = Item.Name
		.pnlGeneral.Visible = Key = "General"
		.pnlCodeEditor.Visible = Key = "CodeEditor"
		.pnlColorsAndFonts.Visible = Key = "ColorsAndFonts"
		.pnlCompiler.Visible = Key = "Compiler"
		.pnlMake.Visible = Key = "MakeTool"
		.pnlDebugger.Visible = Key = "Debugger"
		.pnlTerminal.Visible = Key = "Terminal"
		.pnlDesigner.Visible = Key = "Designer"
		.pnlIncludes.Visible = Key = "Includes"
		.pnlLocalization.Visible = Key = "Localization"
		.pnlHelp.Visible = Key = "Help"
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
			.txtDebuggerVersion.Text = GetFileName(.OpenD.FileName)
			If EndsWith(.txtDebuggerVersion.Text, ".exe") Then .txtDebuggerVersion.Text = Left(.txtDebuggerVersion.Text, Len(.txtDebuggerVersion.Text) - 4)
		End If
	End With
End Sub

Private Sub frmOptions.cmdTerminal_Click(ByRef Sender As Control)
	With *Cast(frmOptions Ptr, Sender.GetForm)
		.OpenD.Filter = ML("All Files") & "|*.*;"
		If .OpenD.Execute Then
			.txtTerminal.Text = .OpenD.FileName 
			.txtTerminalVersion.Text = GetFileName(.OpenD.FileName)
			If EndsWith(.txtTerminalVersion.Text, ".exe") Then .txtTerminalVersion.Text = Left(.txtTerminalVersion.Text, Len(.txtTerminalVersion.Text) - 4)
		End If
	End With
End Sub

Private Sub frmOptions.pnlLocalization_Click(ByRef Sender As Control)
	
End Sub

Private Sub frmOptions.txtHistoryLimit_Change(ByRef Sender As TextBox)
	
End Sub

Private Sub frmOptions.CommandButton7_Click(ByRef Sender As Control)
	With *pfOptions
		.OpenD.Filter = ML("All Files") & "|*.*;"
		If .OpenD.Execute Then
			.txtMake.Text = .OpenD.FileName 
			.txtMakeVersion.Text = GetFileName(.OpenD.FileName)
			If EndsWith(.txtMakeVersion.Text, ".exe") Then .txtMakeVersion.Text = Left(.txtMakeVersion.Text, Len(.txtMakeVersion.Text) - 4)
		End If
	End With
End Sub

Private Sub frmOptions.cmdFont_Click(ByRef Sender As Control)
	With fOptions
		.FontD.Font.Name = *.EditFontName
		.FontD.Font.Size = .EditFontSize
		If .FontD.Execute Then
			WLet *.EditFontName, .FontD.Font.Name
			.EditFontSize = .FontD.Font.Size
			.lblFont.Font.Name = *.EditFontName
			.lblFont.Caption = *.EditFontName & ", " & .EditFontSize & "pt"
		End If
	End With
End Sub

Private Sub frmOptions.lstColorKeys_Change(ByRef Sender As Control)
	With fOptions
		Var i = fOptions.lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.lblColorForeground.BackColor = .Colors(i, 0)
		.chkForeground.Checked = .Colors(i, 0) = -1
		
		.lblColorBackground.Visible = .Colors(i, 1) <> -2
		.lblBackground.Visible = .Colors(i, 1) <> -2
		.cmdBackground.Visible = .Colors(i, 1) <> -2
		.chkBackground.Visible = .Colors(i, 1) <> -2
		.lblColorBackground.BackColor = .Colors(i, 1)
		.chkBackground.Checked = .Colors(i, 1) = -1
		
		.lblColorIndicator.Visible = .Colors(i, 2) <> -2
		.lblIndicator.Visible = .Colors(i, 2) <> -2
		.cmdIndicator.Visible = .Colors(i, 2) <> -2
		.chkIndicator.Visible = .Colors(i, 2) <> -2
		.lblColorIndicator.BackColor = .Colors(i, 2)
		.chkIndicator.Checked = .Colors(i, 2) = -1
		
		.chkBold.Visible = .Colors(i, 3) <> -2
		.chkBold.Checked = .Colors(i, 3)
		.chkItalic.Visible = .Colors(i, 3) <> -2
		.chkItalic.Checked = .Colors(i, 4)
		.chkUnderline.Visible = .Colors(i, 3) <> -2
		.chkUnderline.Checked = .Colors(i, 5)
	End With
End Sub

Private Sub frmOptions.cmdForeground_Click(ByRef Sender As Control)
	With fOptions.ColorD
		Var i = fOptions.lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Color = fOptions.Colors(i, 0)
		If .Execute Then
			fOptions.lblColorForeground.BackColor = .Color
			fOptions.chkForeground.Checked = False
			fOptions.Colors(i, 0) = .Color
		End If
	End With
End Sub

Private Sub frmOptions.cmdBackground_Click(ByRef Sender As Control)
	With fOptions.ColorD
		Var i = fOptions.lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Color = fOptions.Colors(i, 1)
		If .Execute Then
			fOptions.lblColorBackground.BackColor = .Color
			fOptions.chkBackground.Checked = False
			fOptions.Colors(i, 1) = .Color
		End If
	End With
End Sub

Private Sub frmOptions.cmdIndicator_Click(ByRef Sender As Control)
	With fOptions.ColorD
		Var i = fOptions.lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Color = fOptions.Colors(i, 2)
		If .Execute Then
			fOptions.lblColorIndicator.BackColor = .Color
			fOptions.chkIndicator.Checked = False
			fOptions.Colors(i, 2) = .Color
		End If
	End With
End Sub

Private Sub frmOptions.cboTheme_Change(ByRef Sender As Control)
	With fOptions
		piniTheme->Load ExePath & "/Settings/Themes/" & fOptions.cboTheme.Text & ".ini"
		.Colors(0, 0) = piniTheme->ReadInteger("Colors", "BookmarksForeground", -1)
		.Colors(0, 1) = piniTheme->ReadInteger("Colors", "BookmarksBackground", -1)
		.Colors(0, 2) = piniTheme->ReadInteger("Colors", "BookmarksIndicator", -1)
		.Colors(0, 3) = piniTheme->ReadInteger("FontStyles", "BookmarksBold", 0)
		.Colors(0, 4) = piniTheme->ReadInteger("FontStyles", "BookmarksItalic", 0)
		.Colors(0, 5) = piniTheme->ReadInteger("FontStyles", "BookmarksUnderline", 0)
		.Colors(1, 0) = piniTheme->ReadInteger("Colors", "BreakpointsForeground", -1)
		.Colors(1, 1) = piniTheme->ReadInteger("Colors", "BreakpointsBackground", -1)
		.Colors(1, 2) = piniTheme->ReadInteger("Colors", "BreakpointsIndicator", -1)
		.Colors(1, 3) = piniTheme->ReadInteger("FontStyles", "BreakpointsBold", 0)
		.Colors(1, 4) = piniTheme->ReadInteger("FontStyles", "BreakpointsItalic", 0)
		.Colors(1, 5) = piniTheme->ReadInteger("FontStyles", "BreakpointsUnderline", 0)
		.Colors(2, 0) = piniTheme->ReadInteger("Colors", "CommentsForeground", -1)
		.Colors(2, 1) = piniTheme->ReadInteger("Colors", "CommentsBackground", -1)
		.Colors(2, 3) = piniTheme->ReadInteger("FontStyles", "CommentsBold", 0)
		.Colors(2, 4) = piniTheme->ReadInteger("FontStyles", "CommentsItalic", 0)
		.Colors(2, 5) = piniTheme->ReadInteger("FontStyles", "CommentsUnderline", 0)
		.Colors(3, 0) = piniTheme->ReadInteger("Colors", "CurrentLineForeground", -1)
		.Colors(3, 1) = piniTheme->ReadInteger("Colors", "CurrentLineBackground", -1)
		.Colors(4, 0) = piniTheme->ReadInteger("Colors", "ExecutionLineForeground", -1)
		.Colors(4, 1) = piniTheme->ReadInteger("Colors", "ExecutionLineBackground", -1)
		.Colors(4, 2) = piniTheme->ReadInteger("Colors", "ExecutionLineIndicator", -1)
		.Colors(5, 0) = piniTheme->ReadInteger("Colors", "FoldLinesForeground", -1)
		.Colors(6, 0) = piniTheme->ReadInteger("Colors", "IndicatorLinesForeground", -1)
		.Colors(7, 0) = piniTheme->ReadInteger("Colors", "KeywordsForeground", -1)
		.Colors(7, 1) = piniTheme->ReadInteger("Colors", "KeywordsBackground", -1)
		.Colors(7, 3) = piniTheme->ReadInteger("FontStyles", "KeywordsBold", 0)
		.Colors(7, 4) = piniTheme->ReadInteger("FontStyles", "KeywordsItalic", 0)
		.Colors(7, 5) = piniTheme->ReadInteger("FontStyles", "KeywordsUnderline", 0)
		.Colors(8, 0) = piniTheme->ReadInteger("Colors", "LineNumbersForeground", -1)
		.Colors(8, 1) = piniTheme->ReadInteger("Colors", "LineNumbersBackground", -1)
		.Colors(8, 3) = piniTheme->ReadInteger("FontStyles", "LineNumbersBold", 0)
		.Colors(8, 4) = piniTheme->ReadInteger("FontStyles", "LineNumbersItalic", 0)
		.Colors(8, 5) = piniTheme->ReadInteger("FontStyles", "LineNumbersUnderline", 0)
		.Colors(9, 0) = piniTheme->ReadInteger("Colors", "NormalTextForeground", -1)
		.Colors(9, 1) = piniTheme->ReadInteger("Colors", "NormalTextBackground", -1)
		.Colors(9, 3) = piniTheme->ReadInteger("FontStyles", "NormalTextBold", 0)
		.Colors(9, 4) = piniTheme->ReadInteger("FontStyles", "NormalTextItalic", 0)
		.Colors(9, 5) = piniTheme->ReadInteger("FontStyles", "NormalTextUnderline", 0)
		.Colors(10, 0) = piniTheme->ReadInteger("Colors", "PreprocessorsForeground", -1)
		.Colors(10, 1) = piniTheme->ReadInteger("Colors", "PreprocessorsBackground", -1)
		.Colors(10, 3) = piniTheme->ReadInteger("FontStyles", "PreprocessorsBold", 0)
		.Colors(10, 4) = piniTheme->ReadInteger("FontStyles", "PreprocessorsItalic", 0)
		.Colors(10, 5) = piniTheme->ReadInteger("FontStyles", "PreprocessorsUnderline", 0)
		.Colors(11, 0) = piniTheme->ReadInteger("Colors", "SelectionForeground", -1)
		.Colors(11, 1) = piniTheme->ReadInteger("Colors", "SelectionBackground", -1)
		.Colors(12, 0) = piniTheme->ReadInteger("Colors", "SpaceIdentifiersForeground", -1)
		.Colors(13, 0) = piniTheme->ReadInteger("Colors", "StringsForeground", -1)
		.Colors(13, 1) = piniTheme->ReadInteger("Colors", "StringsBackground", -1)
		.Colors(13, 3) = piniTheme->ReadInteger("FontStyles", "StringsBold", 0)
		.Colors(13, 4) = piniTheme->ReadInteger("FontStyles", "StringsItalic", 0)
		.Colors(13, 5) = piniTheme->ReadInteger("FontStyles", "StringsUnderline", 0)
		.lstColorKeys_Change(.lstColorKeys)
	End With
End Sub

Private Sub frmOptions.chkForeground_Click(ByRef Sender As CheckBox)
	With fOptions
		Var i = .lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Colors(i, 0) = IIf(.chkForeground.Checked, -1, .lblColorForeground.BackColor)
	End With
End Sub

Private Sub frmOptions.chkBackground_Click(ByRef Sender As CheckBox)
	With fOptions
		Var i = .lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Colors(i, 1) = IIf(.chkBackground.Checked, -1, .lblColorBackground.BackColor)
	End With
End Sub

Private Sub frmOptions.chkIndicator_Click(ByRef Sender As CheckBox)
	With fOptions
		Var i = .lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Colors(i, 2) = IIf(.chkIndicator.Checked, -1, .lblColorIndicator.BackColor)
	End With
End Sub

Private Sub frmOptions.chkBold_Click(ByRef Sender As CheckBox)
	With fOptions
		Var i = .lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Colors(i, 3) = IIf(.chkBold.Checked, -1, 0)
	End With
End Sub

Private Sub frmOptions.chkItalic_Click(ByRef Sender As CheckBox)
	With fOptions
		Var i = .lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Colors(i, 4) = IIf(.chkItalic.Checked, -1, 0)
	End With
End Sub

Private Sub frmOptions.chkUnderline_Click(ByRef Sender As CheckBox)
	With fOptions
		Var i = .lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Colors(i, 5) = IIf(.chkUnderline.Checked, -1, 0)
	End With
End Sub

Private Sub frmOptions.cmdAdd_Click(ByRef Sender As Control)
	If pfTheme->ShowModal() = ModalResults.OK Then
		With fOptions
			.cboTheme.AddItem pfTheme->txtThemeName.Text
			.cboTheme.ItemIndex = .cboTheme.IndexOf(pfTheme->txtThemeName.Text)
			.cboTheme_Change(Sender)
		End With
	End If
End Sub

Private Sub frmOptions.cmdRemove_Click(ByRef Sender As Control)
	With fOptions
		Kill ExePath & "/Settings/Themes/" & .cboTheme.Text & ".ini"
		.cboTheme.RemoveItem .cboTheme.ItemIndex
		.cboTheme.ItemIndex = 0
		.cboTheme_Change(Sender)
	End With
End Sub

Private Sub frmOptions.cmdAddCompiler_Click(ByRef Sender As Control)
	With fOptions
		.lvCompilerPaths.ListItems.Add .TextBox2.Text
		.lvCompilerPaths.ListItems.Item(.lvCompilerPaths.ListItems.Count - 1)->Text(1) = .TextBox1.Text
		If .cboCompiler32.IndexOf(.TextBox2.Text) = -1 Then .cboCompiler32.AddItem .TextBox2.Text
		If .cboCompiler64.IndexOf(.TextBox2.Text) = -1 Then .cboCompiler64.AddItem .TextBox2.Text
		.TextBox1.Text = ""
		.TextBox2.Text = ""
	End With
End Sub

Private Sub frmOptions.cmdRemoveCompiler_Click(ByRef Sender As Control)
	With fOptions
		If .lvCompilerPaths.SelectedItem = 0 Then Exit Sub
		Var iIndex = .cboCompiler32.IndexOf(.lvCompilerPaths.SelectedItem->Text(0))
		If iIndex > -1 Then .cboCompiler32.RemoveItem iIndex
		If .cboCompiler32.ItemIndex = -1 Then .cboCompiler32.ItemIndex = 0
		iIndex = .cboCompiler64.IndexOf(.lvCompilerPaths.SelectedItem->Text(0))
		If iIndex > -1 Then .cboCompiler64.RemoveItem iIndex
		If .cboCompiler64.ItemIndex = -1 Then .cboCompiler64.ItemIndex = 0
		.lvCompilerPaths.ListItems.Remove .lvCompilerPaths.SelectedItemIndex
	End With
End Sub

Private Sub frmOptions.cmdClearCompilers_Click(ByRef Sender As Control)
	With fOptions
		.lvCompilerPaths.ListItems.Clear
		.cboCompiler32.Clear
		.cboCompiler64.Clear
		.cboCompiler32.AddItem ML("(not selected)")
		.cboCompiler64.AddItem ML("(not selected)")
		.cboCompiler32.ItemIndex = 0
		.cboCompiler64.ItemIndex = 0
	End With
End Sub

Private Sub frmOptions.cmdAddMakeTool_Click(ByRef Sender As Control)
	With fOptions
		.lvMakeToolPaths.ListItems.Add .txtMakeVersion.Text
		.lvMakeToolPaths.ListItems.Item(.lvMakeToolPaths.ListItems.Count - 1)->Text(1) = .txtMake.Text
		If .cboMakeTool.IndexOf(.txtMakeVersion.Text) = -1 Then .cboMakeTool.AddItem .txtMakeVersion.Text
		.txtMake.Text = ""
		.txtMakeVersion.Text = ""
	End With
End Sub

Private Sub frmOptions.cmdRemoveMakeTool_Click(ByRef Sender As Control)
	With fOptions
		If .lvMakeToolPaths.SelectedItem = 0 Then Exit Sub
		Var iIndex = .cboMakeTool.IndexOf(.lvMakeToolPaths.SelectedItem->Text(0))
		If iIndex > -1 Then .cboMakeTool.RemoveItem iIndex
		If .cboMakeTool.ItemIndex = -1 Then .cboMakeTool.ItemIndex = 0
		.lvMakeToolPaths.ListItems.Remove .lvMakeToolPaths.SelectedItemIndex
	End With
End Sub

Private Sub frmOptions.cmdClearMakeTools_Click(ByRef Sender As Control)
	With fOptions
		.lvMakeToolPaths.ListItems.Clear
		.cboMakeTool.Clear
		.cboMakeTool.AddItem ML("(not selected)")
		.cboMakeTool.ItemIndex = 0
	End With
End Sub

Private Sub frmOptions.cmdAddDebugger_Click(ByRef Sender As Control)
	With fOptions
		.lvDebuggerPaths.ListItems.Add .txtDebuggerVersion.Text
		.lvDebuggerPaths.ListItems.Item(.lvDebuggerPaths.ListItems.Count - 1)->Text(1) = .txtDebugger.Text
		If .cboDebugger.IndexOf(.txtDebuggerVersion.Text) = -1 Then .cboDebugger.AddItem .txtDebuggerVersion.Text
		.txtDebugger.Text = ""
		.txtDebuggerVersion.Text = ""
	End With
End Sub

Private Sub frmOptions.cmdRemoveDebugger_Click(ByRef Sender As Control)
	With fOptions
		If .lvDebuggerPaths.SelectedItem = 0 Then Exit Sub
		Var iIndex = .cboDebugger.IndexOf(.lvDebuggerPaths.SelectedItem->Text(0))
		If iIndex > -1 Then .cboDebugger.RemoveItem iIndex
		If .cboDebugger.ItemIndex = -1 Then .cboDebugger.ItemIndex = 0
		.lvDebuggerPaths.ListItems.Remove .lvDebuggerPaths.SelectedItemIndex
	End With
End Sub

Private Sub frmOptions.cmdClearDebuggers_Click(ByRef Sender As Control)
	With fOptions
		.lvDebuggerPaths.ListItems.Clear
		.cboDebugger.Clear
		.cboDebugger.AddItem ML("Integrated IDE Debugger")
		.cboDebugger.ItemIndex = 0
	End With
End Sub

Private Sub frmOptions.cmdAddTerminal_Click(ByRef Sender As Control)
		With fOptions
		.lvTerminalPaths.ListItems.Add .txtTerminalVersion.Text
		.lvTerminalPaths.ListItems.Item(.lvTerminalPaths.ListItems.Count - 1)->Text(1) = .txtTerminal.Text
		If .cboTerminal.IndexOf(.txtTerminalVersion.Text) = -1 Then .cboTerminal.AddItem .txtTerminalVersion.Text
		.txtTerminal.Text = ""
		.txtTerminalVersion.Text = ""
	End With
End Sub

Private Sub frmOptions.cmdRemoveTerminal_Click(ByRef Sender As Control)
	With fOptions
		If .lvTerminalPaths.SelectedItem = 0 Then Exit Sub
		Var iIndex = .cboTerminal.IndexOf(.lvTerminalPaths.SelectedItem->Text(0))
		If iIndex > -1 Then .cboTerminal.RemoveItem iIndex
		If .cboTerminal.ItemIndex = -1 Then .cboTerminal.ItemIndex = 0
		.lvTerminalPaths.ListItems.Remove .lvTerminalPaths.SelectedItemIndex
	End With
End Sub

Private Sub frmOptions.cmdClearTerminals_Click(ByRef Sender As Control)
	With fOptions
		.lvTerminalPaths.ListItems.Clear
		.cboTerminal.Clear
		.cboTerminal.AddItem ML("(not selected)")
		.cboTerminal.ItemIndex = 0
	End With
End Sub
