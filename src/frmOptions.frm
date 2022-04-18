'#########################################################
'#  frmOptions.bas                                       #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
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
		#ifdef __USE_GTK__
			This.Icon.LoadFromFile(ExePath & "/Resources/VisualFBEditor.ico")
		#else
			This.Icon.LoadFromResourceID(1)
		#endif
		This.MinimizeBox = False
		This.MaximizeBox = False
		This.SetBounds 0, 0, 630, 488
		This.StartPosition = FormStartPosition.CenterParent
		This.FormStyle = FormStyles.fsStayOnTop
		'This.Caption = ML("Options")
		This.CancelButton = @cmdCancel
		This.DefaultButton = @cmdOK
		This.BorderStyle = FormBorderStyle.FixedDialog
		' tvOptions
		tvOptions.Name = "tvOptions"
		tvOptions.Text = "TreeView1"
		tvOptions.SetBounds 10, 6, 178, 400
		tvOptions.HideSelection = False
		tvOptions.OnSelChanged = @TreeView1_SelChange
		tvOptions.Parent = @This
		' cmdOK
		cmdOK.Name = "cmdOK"
		cmdOK.Text = ML("OK")
		cmdOK.Default = True
		cmdOK.SetBounds 348, 427, 90, 24
		cmdOK.OnClick = @cmdOK_Click
		'cmdOK.Caption = ML("OK")
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
		pnlColorsAndFonts.SetBounds 190, 2, 426, 400
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
		pnlLocalization.SetBounds 190, 2, 426, 400
		pnlLocalization.Parent = @This
		' pnlThemes
		pnlThemes.Name = "pnlThemes"
		pnlThemes.Text = ""
		pnlThemes.SetBounds 190, 2, 426, 408
		pnlThemes.Parent = @This
		' pnlShortcuts
		pnlShortcuts.Name = "pnlShortcuts"
		pnlShortcuts.Text = ""
		pnlShortcuts.SetBounds 190, 2, 426, 408
		pnlShortcuts.Parent = @This
		' pnlHelp
		pnlHelp.Name = "pnlHelp"
		pnlHelp.Text = ""
		pnlHelp.SetBounds 190, 2, 426, 400
		pnlHelp.Parent = @This
		' pnlOtherEditors
		pnlOtherEditors.Name = "pnlOtherEditors"
		pnlOtherEditors.Text = ""
		pnlOtherEditors.SetBounds 190, 2, 436, 410
		pnlOtherEditors.Parent = @This
		' grbDefaultCompilers
		With grbDefaultCompilers
			.Name = "grbDefaultCompilers"
			.Text = ML("Default Compilers")
			.SetBounds 10, -2, 416, 128
			.Parent = @pnlCompiler
		End With
		' grbShortcuts
		With grbShortcuts
			.Name = "grbShortcuts"
			.Text = ML("Shortcuts")
			.SetBounds 10, 6, 416, 400
			.Parent = @pnlShortcuts
		End With
		' grbCompilerPaths
		With grbCompilerPaths
			.Name = "grbCompilerPaths"
			.Text = ML("Compiler Paths")
			.SetBounds 10, 134, 416, 264
			.Parent = @pnlCompiler
		End With
		' lblShortcut
		lblShortcut.Name = "lblShortcut"
		lblShortcut.Text = ML("Select shortcut") & ":"
		lblShortcut.SetBounds 18, 369, 132, 18
		lblShortcut.Parent = @grbShortcuts
		' hkShortcut
		hkShortcut.Name = "hkShortcut"
		hkShortcut.SetBounds 146, 367, 199, 19
		hkShortcut.Parent = @grbShortcuts
		' cmdSetShortcut
		cmdSetShortcut.Name = "cmdSetShortcut"
		cmdSetShortcut.Text = ML("Set")
		cmdSetShortcut.SetBounds 354, 366, 52, 21
		cmdSetShortcut.OnClick = @cmdSetShortcut_Click
		cmdSetShortcut.Parent = @grbShortcuts
		' lvShortcuts
		With lvShortcuts
			.Name = "lvShortcuts"
			.Text = "lvShortcuts"
			.SetBounds 18, 22, 384, 333
			.OnSelectedItemChanged = @lvShortcuts_SelectedItemChanged
			.Parent = @grbShortcuts
		End With
		' lblCompiler32
		lblCompiler32.Name = "lblCompiler32"
		lblCompiler32.Text = ML("Compiler") & " " & ML("32-bit")
		lblCompiler32.SetBounds 18, 24, 260, 18
		lblCompiler32.Parent = @grbDefaultCompilers
		' lblCompiler64
		lblCompiler64.Name = "lblCompiler64"
		lblCompiler64.Text = ML("Compiler") & " " & ML("64-bit")
		lblCompiler64.SetBounds 18, 74, 266, 18
		lblCompiler64.Parent = @grbDefaultCompilers
		' grbDefaultDebuggers
		With grbDefaultDebuggers
			.Name = "grbDefaultDebuggers"
			.Text = ML("Default Debuggers")
			.SetBounds 10, -2, 416, 128
			.Parent = @pnlDebugger
		End With
		' grbDebuggerPaths
		With grbDebuggerPaths
			.Name = "grbDebuggerPaths"
			.Text = ML("Debugger Paths")
			.SetBounds 10, 204, 416, 194
			.Parent = @pnlDebugger
		End With
		' cboDebugger32
		With cboDebugger32
			.Name = "cboDebugger32"
			.Text = "cboCompiler321"
			.SetBounds 18, 39, 184, 21
			.Parent = @grbDefaultDebuggers
		End With
		' grbDefaultTerminal
		With grbDefaultTerminal
			.Name = "grbDefaultTerminal"
			.Text = ML("Default Terminal")
			.SetBounds 10, -2, 416, 64
			.Parent = @pnlTerminal
		End With
		' cboTerminal
		With cboTerminal
			.Name = "cboTerminal"
			.Text = "cboTerminal"
			.SetBounds 18, 24, 384, 21
			.Parent = @grbDefaultTerminal
		End With
		' grbTerminalPaths
		With grbTerminalPaths
			.Name = "grbTerminalPaths"
			.Text = ML("Terminal Paths")
			.SetBounds 10, 170, 416, 228
			.Parent = @pnlTerminal
		End With
		' lvTerminalPath
		With lvTerminalPaths
			.Name = "lvTerminalPaths"
			.Text = "lvTerminalPaths"
			.SetBounds 18, 22, 384, 156
			.Designer = @This
			.OnItemActivate = @lvTerminalPaths_ItemActivate_
			.Parent = @grbTerminalPaths
		End With
		' cmdAddTerminal
		With cmdAddTerminal
			.Name = "cmdAddTerminal"
			.Text = ML("&Add")
			.SetBounds 17, 188, 96, 24
			.OnClick = @cmdAddTerminal_Click
			.Parent = @grbTerminalPaths
		End With
		' cmdRemoveTerminal
		With cmdRemoveTerminal
			.Name = "cmdRemoveTerminal"
			.Text = ML("&Remove")
			.SetBounds 211, 188, 96, 24
			.OnClick = @cmdRemoveTerminal_Click
			.Parent = @grbTerminalPaths
		End With
		' cmdClearDebuggers1
		With cmdClearTerminals
			.Name = "cmdClearTerminals"
			.Text = ML("&Clear")
			.SetBounds 307, 188, 96, 24
			.OnClick = @cmdClearTerminals_Click
			.Parent = @grbTerminalPaths
		End With
		' grbLanguage
		With grbLanguage
			.Name = "grbLanguage"
			.Text = ML("Language")
			.SetBounds 8, 6, 414, 395
			.Parent = @pnlLocalization
		End With
		' grbThemes
		With grbThemes
			.Name = "grbThemes"
			.Text = ML("Themes")
			.SetBounds 8, 7, 414, 394
			.Parent = @pnlThemes
		End With
		' cboLanguage
		cboLanguage.Name = "cboLanguage"
		'ComboBoxEdit1.Text = "russian"
		cboLanguage.SetBounds 10, 20, 392, 21
		cboLanguage.Parent = @grbLanguage
		' cmdAddCompiler
		cmdAddCompiler.Name = "cmdAddCompiler"
		cmdAddCompiler.Text = ML("&Add")
		cmdAddCompiler.SetBounds 17, 224, 96, 24
		cmdAddCompiler.OnClick = @cmdAddCompiler_Click
		cmdAddCompiler.Parent = @grbCompilerPaths
		' CheckBox1
		CheckBox1.Name = "CheckBox1"
		CheckBox1.Text = ML("Auto increment version")
		CheckBox1.SetBounds 10, 0, 318, 18
		CheckBox1.Parent = @pnlGeneral
		' chkAutoCreateRC
		chkAutoCreateRC.Name = "chkAutoCreateRC"
		chkAutoCreateRC.Text = ML("Auto create resource and manifest files (.rc, .xml)")
		chkAutoCreateRC.SetBounds 10, 22, 300, 18
		chkAutoCreateRC.Parent = @pnlGeneral
		' pnlIncludes
		pnlIncludes.Name = "pnlIncludes"
		pnlIncludes.SetBounds 190, 6, 426, 408
		pnlIncludes.Text = ""
		pnlIncludes.Parent = @This
		' grbIncludePaths
		With grbIncludePaths
			.Name = "grbIncludePaths"
			.Text = ML("Include Paths")
			.SetBounds 10, 3, 416, 216
			.Parent = @pnlIncludes
		End With
		' grbLibraryPaths
		With grbLibraryPaths
			.Name = "grbLibraryPaths"
			.Text = ML("Library Paths")
			.SetBounds 10, 230, 416, 168
			.Parent = @pnlIncludes
		End With
		' txtMFFpath
		txtMFFpath.Name = "txtMFFpath"
		txtMFFpath.SetBounds 160, 21, 217, 20
		txtMFFpath.Parent = @grbIncludePaths
		' cmdMFFPath
		cmdMFFPath.Name = "cmdMFFPath"
		cmdMFFPath.Text = "..."
		cmdMFFPath.SetBounds 377, 20, 24, 22
		cmdMFFPath.OnClick = @cmdMFFPath_Click
		cmdMFFPath.Parent = @grbIncludePaths
		' chkEnableAutoComplete
		chkEnableAutoComplete.Name = "chkEnableAutoComplete"
		chkEnableAutoComplete.Text = ML("Enable Auto Complete")
		chkEnableAutoComplete.SetBounds 10, 21, 264, 18
		chkEnableAutoComplete.Parent = @pnlCodeEditor
		' chkTabAsSpaces
		chkTabAsSpaces.Name = "chkTabAsSpaces"
		chkTabAsSpaces.Text = ML("Treat Tab as Spaces")
		chkTabAsSpaces.SetBounds 10, 175, 264, 18
		chkTabAsSpaces.Parent = @pnlCodeEditor
		' chkAutoIndentation
		chkAutoIndentation.Name = "chkAutoIndentation"
		chkAutoIndentation.Text = ML("Auto Indentation")
		chkAutoIndentation.SetBounds 10, 0, 264, 18
		chkAutoIndentation.Parent = @pnlCodeEditor
		' lblTabSize
		lblTabSize.Name = "lblTabSize"
		lblTabSize.Text = ML("Tab Size") & ":"
		lblTabSize.SetBounds 66, 223, 138, 16
		lblTabSize.Parent = @pnlCodeEditor
		' txtTabSize
		txtTabSize.Name = "txtTabSize"
		txtTabSize.Text = ""
		txtTabSize.SetBounds 209, 221, 90, 20
		txtTabSize.Parent = @pnlCodeEditor
		' chkShowSpaces
		chkShowSpaces.Name = "chkShowSpaces"
		chkShowSpaces.Text = ML("Show Spaces")
		chkShowSpaces.SetBounds 10, 43, 264, 18
		chkShowSpaces.Parent = @pnlCodeEditor
		' lstIncludePaths
		lstIncludePaths.Name = "lstIncludePaths"
		lstIncludePaths.Text = "ListControl1"
		lstIncludePaths.SetBounds 17, 68, 360, 121
		lstIncludePaths.Parent = @grbIncludePaths
		' lstLibraryPaths
		lstLibraryPaths.Name = "lstLibraryPaths"
		lstLibraryPaths.Text = "ListControl11"
		lstLibraryPaths.SetBounds 16, 22, 360, 132
		lstLibraryPaths.Parent = @grbLibraryPaths
		' lblOthers
		lblOthers.Name = "lblOthers"
		lblOthers.Text = ML("Others") & ":"
		lblOthers.SetBounds 16, 48, 138, 18
		lblOthers.Parent = @grbIncludePaths
		' cmdAddInclude
		cmdAddInclude.Name = "cmdAddInclude"
		cmdAddInclude.Text = "+"
		cmdAddInclude.SetBounds 376, 67, 24, 22
		cmdAddInclude.OnClick = @cmdAddInclude_Click
		cmdAddInclude.Parent = @grbIncludePaths
		' cmdRemoveInclude
		cmdRemoveInclude.Name = "cmdRemoveInclude"
		cmdRemoveInclude.Text = "-"
		cmdRemoveInclude.SetBounds 376, 88, 24, 22
		cmdRemoveInclude.OnClick = @cmdRemoveInclude_Click
		cmdRemoveInclude.Parent = @grbIncludePaths
		' cmdAddLibrary
		cmdAddLibrary.Name = "cmdAddLibrary"
		cmdAddLibrary.Text = "+"
		cmdAddLibrary.SetBounds 376, 21, 24, 22
		cmdAddLibrary.OnClick = @cmdAddLibrary_Click
		cmdAddLibrary.Parent = @grbLibraryPaths
		' cmdRemoveLibrary
		cmdRemoveLibrary.Name = "cmdRemoveLibrary"
		cmdRemoveLibrary.Text = "-"
		cmdRemoveLibrary.SetBounds 376, 42, 24, 22
		cmdRemoveLibrary.OnClick = @cmdRemoveLibrary_Click
		cmdRemoveLibrary.Parent = @grbLibraryPaths
		' cmdChangeDebugger
		cmdChangeDebugger.Name = "cmdChangeDebugger"
		cmdChangeDebugger.Text = ML("Chan&ge")
		cmdChangeDebugger.SetBounds 114, 153, 96, 24
		cmdChangeDebugger.OnClick = @cmdChangeDebugger_Click
		cmdChangeDebugger.Parent = @grbDebuggerPaths
		' cmdChangeTerminal
		cmdChangeTerminal.Name = "cmdChangeTerminal"
		cmdChangeTerminal.Text = ML("Chan&ge")
		cmdChangeTerminal.SetBounds 114, 188, 96, 24
		cmdChangeTerminal.OnClick = @cmdChangeTerminal_Click
		cmdChangeTerminal.Parent = @grbTerminalPaths
		' lblHistoryLimit
		lblHistoryLimit.Name = "lblHistoryLimit"
		lblHistoryLimit.Text = ML("History limit") & ":"
		lblHistoryLimit.SetBounds 66, 246, 150, 17
		lblHistoryLimit.Parent = @pnlCodeEditor
		' txtHistoryLimit
		txtHistoryLimit.Name = "txtHistoryLimit"
		txtHistoryLimit.SetBounds 209, 244, 90, 20
		txtHistoryLimit.Text = ""
		txtHistoryLimit.Parent = @pnlCodeEditor
		' grbGrid
		grbGrid.Name = "grbGrid"
		grbGrid.Text = ML("Grid")
		grbGrid.SetBounds 8, -1, 414, 122
		grbGrid.Parent = @pnlDesigner
		' lblGridSize
		lblGridSize.Name = "lblGridSize"
		lblGridSize.Text = ML("Size") & ":"
		lblGridSize.SetBounds 16, 31, 60, 18
		lblGridSize.Parent = @grbGrid
		' txtGridSize
		txtGridSize.Name = "txtGridSize"
		txtGridSize.Text = "10"
		txtGridSize.SetBounds 73, 31, 114, 18
		txtGridSize.Parent = @grbGrid
		' chkShowAlignmentGrid
		chkShowAlignmentGrid.Name = "chkShowAlignmentGrid"
		chkShowAlignmentGrid.Text = ML("Show Alignment Grid")
		chkShowAlignmentGrid.SetBounds 8, -5, 186, 30
		chkShowAlignmentGrid.Parent = @pnlGrid
		' chkSnapToGrid
		chkSnapToGrid.Name = "chkSnapToGrid"
		chkSnapToGrid.Text = ML("Snap to Grid")
		chkSnapToGrid.SetBounds 8, 19, 138, 24
		chkSnapToGrid.Parent = @pnlGrid
		' cboCase
		cboCase.Name = "cboCase"
		cboCase.Text = "ComboBoxEdit2"
		cboCase.SetBounds 209, 197, 162, 21
		cboCase.Parent = @pnlCodeEditor
		' chkChangeKeywordsCase
		chkChangeKeywordsCase.Name = "chkChangeKeywordsCase"
		chkChangeKeywordsCase.Text = ML("Change Keywords Case To") & ":"
		chkChangeKeywordsCase.SetBounds 10, 198, 194, 18
		chkChangeKeywordsCase.Parent = @pnlCodeEditor
		' cboTabStyle
		cboTabStyle.Name = "cboTabStyle"
		cboTabStyle.Text = "cboCase1"
		cboTabStyle.SetBounds 209, 173, 162, 21
		cboTabStyle.Parent = @pnlCodeEditor
		' grbColors
		grbColors.Name = "grbColors"
		grbColors.Text = ML("Colors")
		grbColors.SetBounds 10, 6, 416, 336
		grbColors.Parent = @pnlColorsAndFonts
		' grbFont
		grbFont.Name = "grbFont"
		grbFont.Text = ML("Font (applies to all styles)")
		grbFont.SetBounds 10, 342, 416, 56
		grbFont.Parent = @pnlColorsAndFonts
		' grbMakeToolPaths
		With grbMakeToolPaths
			.Name = "grbMakeToolPaths"
			.Text = ML("Make Tool Paths")
			.SetBounds 10, 100, 416, 298
			.Parent = @pnlMake
		End With
		' lvMakeToolPaths
		With lvMakeToolPaths
			.Name = "lvMakeToolPaths"
			.Text = "lvMakeToolPaths"
			.SetBounds 18, 22, 384, 226
			.Designer = @This
			.OnItemActivate = @lvMakeToolPaths_ItemActivate_
			.Parent = @grbMakeToolPaths
		End With
		' cmdAddMakeTool
		With cmdAddMakeTool
			.Name = "cmdAddMakeTool"
			.Text = ML("&Add")
			.SetBounds 17, 259, 96, 24
			.OnClick = @cmdAddMakeTool_Click
			.IsChild = True
			.ID = 1010
			.Parent = @grbMakeToolPaths
		End With
		' cmdRemoveMakeTool
		With cmdRemoveMakeTool
			.Name = "cmdRemoveMakeTool"
			.Text = ML("&Remove")
			.SetBounds 211, 259, 96, 24
			.OnClick = @cmdRemoveMakeTool_Click
			.Parent = @grbMakeToolPaths
		End With
		' cmdClearMakeTool
		With cmdClearMakeTools
			.Name = "cmdClearMakeTools"
			.Text = ML("&Clear")
			.SetBounds 307, 259, 96, 24
			.OnClick = @cmdClearMakeTools_Click
			.Parent = @grbMakeToolPaths
		End With
		' grbDefaultMakeTool
		With grbDefaultMakeTool
			.Name = "grbDefaultMakeTool"
			.Text = ML("Default Make Tool")
			.SetBounds 10, -2, 416, 64
			.Parent = @pnlMake
		End With
		' cboMakeTool
		With cboMakeTool
			.Name = "cboMakeTool"
			.Text = "cboMakeTool"
			.SetBounds 18, 24, 384, 21
			.Parent = @grbDefaultMakeTool
		End With
		' cmdChangeMakeTool
		cmdChangeMakeTool.Name = "cmdChangeMakeTool"
		cmdChangeMakeTool.Text = ML("Chan&ge")
		cmdChangeMakeTool.SetBounds 114, 259, 96, 24
		cmdChangeMakeTool.OnClick = @cmdChangeMakeTool_Click
		cmdChangeMakeTool.Parent = @grbMakeToolPaths
		' cboTheme
		cboTheme.Name = "cboTheme"
		cboTheme.Text = "ComboBoxEdit2"
		cboTheme.SetBounds 18, 20, 224, 21
		cboTheme.OnChange = @cboTheme_Change
		cboTheme.Parent = @grbColors
		' lstColorKeys
		lstColorKeys.Name = "lstColorKeys"
		lstColorKeys.Text = "ListControl1"
		lstColorKeys.SetBounds 18, 55, 224, 264
		lstColorKeys.OnChange = @lstColorKeys_Change
		lstColorKeys.Parent = @grbColors
		' cmdAdd
		cmdAdd.Name = "cmdAdd"
		cmdAdd.Text = ML("&Add")
		cmdAdd.SetBounds 258, 20, 71, 23
		cmdAdd.OnClick = @cmdAdd_Click
		cmdAdd.Parent = @grbColors
		' cmdRemove
		cmdRemove.Name = "cmdRemove"
		cmdRemove.Text = ML("&Remove")
		cmdRemove.SetBounds 330, 20, 71, 23
		cmdRemove.OnClick = @cmdRemove_Click
		cmdRemove.Parent = @grbColors
		' lblColorForeground
		lblColorForeground.Name = "lblColorForeground"
		lblColorForeground.Text = ""
		lblColorForeground.SetBounds 258, 71, 72, 20
		lblColorForeground.BackColor = 0
		lblColorForeground.Parent = @grbColors
		' cmdForeground
		cmdForeground.Name = "cmdForeground"
		cmdForeground.Text = "..."
		cmdForeground.SetBounds 330, 70, 24, 22
		'cmdForeground.Caption = "..."
		cmdForeground.OnClick = @cmdForeground_Click
		cmdForeground.Parent = @grbColors
		' cmdFont
		cmdFont.Name = "cmdFont"
		cmdFont.Text = "..."
		cmdFont.SetBounds 376, 18, 24, 22
		'cmdFont.Caption = "..."
		cmdFont.OnClick = @cmdFont_Click
		cmdFont.Parent = @grbFont
		' lblFont
		lblFont.Name = "lblFont"
		lblFont.Text = ML("Font")
		lblFont.SetBounds 23, 23, 344, 16
		lblFont.Parent = @grbFont
		' txtProjectsPath
		txtProjectsPath.Name = "txtProjectsPath"
		txtProjectsPath.Text = "./Projects"
		txtProjectsPath.SetBounds 10, 368, 390, 20
		txtProjectsPath.Parent = @pnlGeneral
		' cmdProjectsPath
		cmdProjectsPath.Name = "cmdProjectsPath"
		cmdProjectsPath.Text = "..."
		cmdProjectsPath.SetBounds 400, 367, 24, 22
		'cmdProjectsPath.Caption = "..."
		cmdProjectsPath.OnClick = @cmdProjectsPath_Click
		cmdProjectsPath.Parent = @pnlGeneral
		' lblProjectsPath
		lblProjectsPath.Name = "lblProjectsPath"
		lblProjectsPath.Text = ML("Projects path") & ":"
		lblProjectsPath.SetBounds 13, 350, 96, 16
		lblProjectsPath.Parent = @pnlGeneral
		' lblColorBackground
		lblColorBackground.Name = "lblColorBackground"
		lblColorBackground.SetBounds 258, 113, 72, 20
		lblColorBackground.BackColor = 0
		lblColorBackground.Text = ""
		lblColorBackground.Parent = @grbColors
		' cmdBackground
		cmdBackground.Name = "cmdBackground"
		cmdBackground.Text = "..."
		cmdBackground.SetBounds 330, 112, 24, 22
		'cmdBackground.Caption = "..."
		cmdBackground.OnClick = @cmdBackground_Click
		cmdBackground.Parent = @grbColors
		' lblForeground
		lblForeground.Name = "lblForeground"
		lblForeground.Text = ML("Foreground") & ":"
		lblForeground.SetBounds 258, 55, 136, 16
		lblForeground.Parent = @grbColors
		' lblBackground
		lblBackground.Name = "lblBackground"
		lblBackground.Text = ML("Background") & ":"
		lblBackground.SetBounds 258, 96, 136, 16
		lblBackground.Parent = @grbColors
		' lblIndicator
		lblIndicator.Name = "lblIndicator"
		lblIndicator.Text = ML("Indicator") & ":"
		lblIndicator.SetBounds 258, 176, 136, 16
		lblIndicator.Parent = @grbColors
		' lblColorIndicator
		lblColorIndicator.Name = "lblColorIndicator"
		lblColorIndicator.Text = ""
		lblColorIndicator.SetBounds 258, 192, 72, 20
		lblColorIndicator.BackColor = 0
		lblColorIndicator.Parent = @grbColors
		' cmdIndicator
		cmdIndicator.Name = "cmdIndicator"
		cmdIndicator.Text = "..."
		cmdIndicator.SetBounds 330, 191, 24, 22
		'cmdIndicator.Caption = "..."
		cmdIndicator.OnClick = @cmdIndicator_Click
		cmdIndicator.Parent = @grbColors
		'
		' chkForeground
		chkForeground.Name = "chkForeground"
		chkForeground.Text = ML("Auto")
		chkForeground.SetBounds 0, 9, 48, 16
		chkForeground.OnClick = @chkForeground_Click
		chkForeground.Parent = @pnlColors
		' chkBackground
		chkBackground.Name = "chkBackground"
		chkBackground.Text = ML("Auto")
		chkBackground.SetBounds 0, 51, 48, 16
		chkBackground.OnClick = @chkBackground_Click
		chkBackground.Parent = @pnlColors
		' chkIndicator
		chkIndicator.Name = "chkIndicator"
		chkIndicator.Text = ML("Auto")
		chkIndicator.SetBounds 0, 130, 48, 16
		chkIndicator.OnClick = @chkIndicator_Click
		chkIndicator.Parent = @pnlColors
		' chkBold
		chkBold.Name = "chkBold"
		chkBold.Text = ML("Bold")
		chkBold.SetBounds 268, 251, 107, 16
		chkBold.OnClick = @chkBold_Click
		chkBold.Parent = @pnlColorsAndFonts
		' chkItalic
		chkItalic.Name = "chkItalic"
		chkItalic.Text = ML("Italic")
		chkItalic.SetBounds 268, 275, 99, 16
		chkItalic.OnClick = @chkItalic_Click
		chkItalic.Parent = @pnlColorsAndFonts
		' chkUnderline
		chkUnderline.Name = "chkUnderline"
		chkUnderline.Text = ML("Underline")
		chkUnderline.SetBounds 268, 299, 107, 16
		chkUnderline.OnClick = @chkUnderline_Click
		chkUnderline.Parent = @pnlColorsAndFonts
		' chkUseMakeOnStartWithCompile
		chkUseMakeOnStartWithCompile.Name = "chkUseMakeOnStartWithCompile"
		chkUseMakeOnStartWithCompile.Text = ML("Use make on start with compile (if exists makefile)")
		chkUseMakeOnStartWithCompile.SetBounds 15, 73, 390, 16
		'chkUseMakeOnStartWithCompile.Caption = ML("Use make on start with compile (if exists makefile)")
		chkUseMakeOnStartWithCompile.Parent = @pnlMake
		' lvCompilerPaths
		With lvCompilerPaths
			.Name = "lvCompilerPaths"
			.Text = "ListView1"
			.SetBounds 18, 44, 384, 172
			.Images = @imgList
			'.StateImages = @imgList
			.SmallImages = @imgList
			.Designer = @This
			.OnItemActivate = @lvCompilerPaths_ItemActivate_
			.Parent = @grbCompilerPaths
		End With
		' cboCompiler32
		With cboCompiler32
			.Name = "cboCompiler32"
			.Text = "ComboBoxEdit2"
			.SetBounds 18, 40, 384, 21
			.Parent = @grbDefaultCompilers
		End With
		' cboCompiler64
		With cboCompiler64
			.Name = "cboCompiler64"
			.Text = "ComboBoxEdit21"
			.SetBounds 18, 90, 384, 21
			.Parent = @grbDefaultCompilers
		End With
		' cmdRemoveCompiler
		With cmdRemoveCompiler
			.Name = "cmdRemoveCompiler"
			.Text = ML("&Remove")
			.SetBounds 211, 224, 96, 24
			.OnClick = @cmdRemoveCompiler_Click
			.Parent = @grbCompilerPaths
		End With
		' cmdClearCompilers
		With cmdClearCompilers
			.Name = "cmdClearCompilers"
			.Text = ML("&Clear")
			.SetBounds 308, 224, 96, 24
			.OnClick = @cmdClearCompilers_Click
			.Parent = @grbCompilerPaths
		End With
		' lvDebuggerPaths
		With lvDebuggerPaths
			.Name = "lvDebuggerPaths"
			.Text = "lvCompilerPaths1"
			.SetBounds 18, 22, 384, 122
			.Designer = @This
			.OnItemActivate = @lvDebuggerPaths_ItemActivate_
			.Parent = @grbDebuggerPaths
		End With
		' cmdAddDebugger
		With cmdAddDebugger
			.Name = "cmdAddDebugger"
			.Text = ML("&Add")
			.SetBounds 17, 153, 96, 24
			.OnClick = @cmdAddDebugger_Click
			.Parent = @grbDebuggerPaths
		End With
		' cmdRemoveDebugger
		With cmdRemoveDebugger
			.Name = "cmdRemoveDebugger"
			.Text = ML("&Remove")
			.SetBounds 211, 153, 96, 24
			.OnClick = @cmdRemoveDebugger_Click
			.Parent = @grbDebuggerPaths
		End With
		' cmdClearDebuggers
		With cmdClearDebuggers
			.Name = "cmdClearDebuggers"
			.Text = ML("&Clear")
			.SetBounds 307, 153, 96, 24
			.OnClick = @cmdClearDebuggers_Click
			.Parent = @grbDebuggerPaths
		End With
		' lblInterfaceFont
		With lblInterfaceFont
			.Name = "lblInterfaceFont"
			.Text = "Tahoma, 8 pt"
			.SetBounds 145, 20, 264, 16
			'.Caption = "Tahoma, 8 pt"
			.Parent = @grbThemes
		End With
		' cmdInterfaceFont
		With cmdInterfaceFont
			.Name = "cmdInterfaceFont"
			.Text = "..."
			.SetBounds 376, 20, 24, 22
			'.Caption = "..."
			.OnClick = @cmdInterfaceFont_Click
			.Parent = @grbThemes
		End With
		' lblInterfaceFontLabel
		With lblInterfaceFontLabel
			.Name = "lblInterfaceFontLabel"
			.Text = ML("Interface font") & ":"
			.SetBounds 10, 20, 108, 16
			.Parent = @grbThemes
		End With
		' chkDisplayIcons
		With chkDisplayIcons
			.Name = "chkDisplayIcons"
			.Text = ML("Display Icons in the Menu")
			.SetBounds 2, 1, 216, 16
			.Parent = @pnlThemesCheckboxes
		End With
		' chkShowMainToolbar
		With chkShowMainToolbar
			.Name = "chkShowMainToolbar"
			.Text = ML("Show main Toolbar")
			.SetBounds 2, 18, 224, 24
			.Parent = @pnlThemesCheckboxes
		End With
		' chkAutoCreateBakFiles
		With chkAutoCreateBakFiles
			.Name = "chkAutoCreateBakFiles"
			.Text = ML("Auto create bak files before saving")
			.SetBounds 10, 46, 400, 16
			.ID = 1009
			.Parent = @pnlGeneral
		End With
		' lblFrame
		With lblFrame
			.Name = "lblFrame"
			.Text = ML("Frame") & ":"
			.SetBounds 258, 136, 136, 16
			.Parent = @grbColors
		End With
		' lblColorFrame
		With lblColorFrame
			.Name = "lblColorFrame"
			.SetBounds 258, 152, 72, 20
			.BackColor = 0
			.Parent = @grbColors
		End With
		' cmdFrame
		With cmdFrame
			.Name = "cmdFrame"
			.Text = "..."
			.SetBounds 330, 151, 24, 22
			'.Caption = "..."
			.OnClick = @cmdFrame_Click
			.Parent = @grbColors
		End With
		' chkFrame
		With chkFrame
			.Name = "chkFrame"
			.Text = ML("Auto")
			.SetBounds 0, 90, 48, 16
			.OnClick = @chkFrame_Click
			.Parent = @pnlColors
		End With
		' chkHighlightCurrentWord
		With chkHighlightCurrentWord
			.Name = "chkHighlightCurrentWord"
			.Text = ML("Highlight Current Word")
			.SetBounds 10, 104, 192, 26
			.Parent = @pnlCodeEditor
		End With
		' chkHighlightCurrentLine
		With chkHighlightCurrentLine
			.Name = "chkHighlightCurrentLine"
			.Text = ML("Highlight Current Line")
			.SetBounds 10, 86, 224, 16
			.Parent = @pnlCodeEditor
		End With
		' chkHighlightBrackets
		With chkHighlightBrackets
			.Name = "chkHighlightBrackets"
			.Text = ML("Highlight Brackets")
			.SetBounds 10, 131, 154, 18
			.Parent = @pnlCodeEditor
		End With
		' cmdChangeCompiler
		With cmdChangeCompiler
			.Name = "cmdChangeCompiler"
			.Text = ML("Chan&ge")
			.SetBounds 114, 224, 96, 24
			.OnClick = @cmdChangeCompiler_Click
			.Parent = @grbCompilerPaths
		End With
		' grbDefaultHelp
		With grbDefaultHelp
			.Name = "grbDefaultHelp"
			.Text = ML("Default Help")
			.SetBounds 10, 6, 416, 64
			.Parent = @pnlHelp
		End With
		' cboHelp
		With cboHelp
			.Name = "cboHelp"
			.Text = "cboHelp"
			.SetBounds 18, 24, 384, 21
			.Parent = @grbDefaultHelp
		End With
		' grbHelpPaths
		With grbHelpPaths
			.Name = "grbHelpPaths"
			.Text = ML("Help Paths")
			.SetBounds 10, 78, 416, 324
			.Parent = @pnlHelp
		End With
		' lvHelpPaths
		With lvHelpPaths
			.Name = "lvHelpPaths"
			.Text = "lvTerminalPaths1"
			.SetBounds 18, 22, 384, 256
			.Designer = @This
			.OnItemActivate = @lvHelpPaths_ItemActivate_
			.Parent = @grbHelpPaths
		End With
		' cmdAddHelp
		With cmdAddHelp
			.Name = "cmdAddHelp"
			.Text = ML("&Add")
			.SetBounds 17, 288, 96, 24
			.OnClick = @cmdAddHelp_Click
			.Parent = @grbHelpPaths
		End With
		' cmdChangeHelp
		With cmdChangeHelp
			.Name = "cmdChangeHelp"
			.Text = ML("Chan&ge")
			.SetBounds 114, 288, 96, 24
			.OnClick = @cmdChangeHelp_Click
			.Parent = @grbHelpPaths
		End With
		' cmdRemoveHelp
		With cmdRemoveHelp
			.Name = "cmdRemoveHelp"
			.Text = ML("&Remove")
			.SetBounds 211, 288, 96, 24
			.OnClick = @cmdRemoveHelp_Click
			.Parent = @grbHelpPaths
		End With
		' cmdClearHelp
		With cmdClearHelps
			.Name = "cmdClearHelps"
			.Text = ML("&Clear")
			.SetBounds 307, 288, 96, 24
			.OnClick = @cmdClearHelps_Click
			.Parent = @grbHelpPaths
		End With
		' grbWhenCompiling
		With grbWhenCompiling
			.Name = "grbWhenCompiling"
			.Text = ML("When compiling") & ":"
			.SetBounds 8, 221, 416, 120
			.Parent = @pnlGeneral
		End With
		' optSaveCurrentFile
		With optSaveCurrentFile
			.Name = "optSaveCurrentFile"
			.Text = ML("Save Current Project / File")
			.SetBounds 18, 22, 184, 16
			.Parent = @grbWhenCompiling
		End With
		' optDoNotSave
		With optDoNotSave
			.Name = "optDoNotSave"
			.Text = ML("Don't Save")
			.SetBounds 18, 90, 184, 16
			.Parent = @grbWhenCompiling
		End With
		' optSaveAllFiles
		With optSaveAllFiles
			.Name = "optSaveAllFiles"
			.Text = ML("Save All Files")
			.SetBounds 18, 45, 184, 16
			.Parent = @grbWhenCompiling
		End With
		' pnlIncludeMFFPath
		With pnlIncludeMFFPath
			.Name = "pnlIncludeMFFPath"
			.Text = ""
			.SetBounds 8, 23, 152, 16
			.Parent = @grbIncludePaths
		End With
		' chkIncludeMFFPath
		With chkIncludeMFFPath
			.Name = "chkIncludeMFFPath"
			.Text = ML("Include MFF Path") & ":"
			.SetBounds 7, 0, 150, 18
			.Parent = @pnlIncludeMFFPath
		End With
		' pnlThemesCheckboxes
		With pnlThemesCheckboxes
			.Name = "pnlThemesCheckboxes"
			.Text = "Panel2"
			.SetBounds 10, 63, 320, 198
			.Parent = @grbThemes
		End With
		' pnlColors
		With pnlColors
			.Name = "pnlColors"
			.Text = "Panel2"
			.SetBounds 360, 64, 40, 160
			.Parent = @grbColors
		End With
		' pnlGrid
		With pnlGrid
			.Name = "pnlGrid"
			.Text = "Panel2"
			.SetBounds 10, 63, 314, 56
			.Parent = @grbGrid
		End With
		' chkLimitDebug
		With chkLimitDebug
			.Name = "chkLimitDebug"
			.Text = ML("Limit debug to the directory of the main file")
			.SetBounds 15, 136, 390, 16
			.Parent = @pnlDebugger
		End With
		' chkDisplayWarningsInDebug
		With chkDisplayWarningsInDebug
			.Name = "chkDisplayWarningsInDebug"
			.Text = ML("Display warnings in debug")
			.SetBounds 15, 158, 390, 16
			.Parent = @pnlDebugger
		End With
		' chkCreateNonStaticEventHandlers
		With chkCreateNonStaticEventHandlers
			.Name = "chkCreateNonStaticEventHandlers"
			.Text = ML("Create non-static event handlers")
			.SetBounds 12, 150, 288, 24
			'.Caption = ML("Create non-static event handlers")
			.Designer = @This
			.OnClick = @chkCreateNonStaticEventHandlers_Click_
			.Parent = @pnlDesigner
		End With
		' lblDebugger32
		With lblDebugger32
			.Name = "lblDebugger32"
			.Text = ML("Debugger") & " " & ML("32-bit")
			.SetBounds 22, 21, 260, 18
			.Parent = @grbDefaultDebuggers
		End With
		' cboDebugger1
		With cboDebugger64
			.Name = "cboDebugger64"
			.SetBounds 18, 89, 184, 21
			.Parent = @grbDefaultDebuggers
		End With
		' lblDebugger64
		With lblDebugger64
			.Name = "lblDebugger64"
			.Text = ML("Debugger") & " " & ML("64-bit")
			.SetBounds 22, 71, 260, 18
			.Parent = @grbDefaultDebuggers
		End With
		' grbOtherEditors
		With grbOtherEditors
			.Name = "grbOtherEditors"
			.Text = "Other Editors"
			.SetBounds 10, 3, 416, 401
			.Parent = @pnlOtherEditors
		End With
		' lvOtherEditors
		With lvOtherEditors
			.Name = "lvOtherEditors"
			.Text = "lvHelpPaths1"
			.SetBounds 18, 22, 384, 326
			.Designer = @This
			.OnItemActivate = @lvOtherEditors_ItemActivate_
			.Parent = @grbOtherEditors
		End With
		' cmdAddEditor
		With cmdAddEditor
			.Name = "cmdAddEditor"
			.Text = ML("&Add")
			.SetBounds 17, 361, 96, 24
			'.Caption = "Add"
			.Designer = @This
			.OnClick = @cmdAddEditor_Click_
			.Parent = @grbOtherEditors
		End With
		' cmdChangeEditor
		With cmdChangeEditor
			.Name = "cmdChangeEditor"
			.Text = ML("Chan&ge")
			.SetBounds 114, 361, 96, 24
			'.Caption = "Change"
			.Designer = @This
			.OnClick = @cmdChangeEditor_Click_
			.Parent = @grbOtherEditors
		End With
		' cmdRemoveEditor
		With cmdRemoveEditor
			.Name = "cmdRemoveEditor"
			.Text = ML("&Remove")
			.SetBounds 211, 361, 96, 24
			'.Caption = "Remove"
			.Designer = @This
			.OnClick = @cmdRemoveEditor_Click_
			.Parent = @grbOtherEditors
		End With
		' cmdClearEditor
		With cmdClearEditor
			.Name = "cmdClearEditor"
			.Text = ML("&Clear")
			.SetBounds 307, 361, 96, 24
			'.Caption = "Clear"
			.Designer = @This
			.OnClick = @cmdClearEditor_Click_
			.Parent = @grbOtherEditors
		End With
		' grbWhenVFBEStarts
		With grbWhenVFBEStarts
			.Name = "grbWhenVFBEStarts"
			.Text = ML("When VisualFBEditor starts") & ":"
			.SetBounds 8, 94, 416, 120
			.Parent = @pnlGeneral
		End With
		' optPromptForProjectAndFile
		With optPromptForProjectAndFile
			.Name = "optPromptForProjectAndFile"
			.Text = ML("Prompt for Project / File")
			.SetBounds 18, 22, 184, 16
			'.Caption = ML("Prompt for Project / File")
			.Designer = @This
			.OnClick = @optPromptForProjectAndFiles_Click
			.Parent = @grbWhenVFBEStarts
		End With
		' optCreateProjectFile
		With optCreateProjectFile
			.Name = "optCreateProjectFile"
			.Text = ML("Create Project / File")
			.SetBounds 18, 45, 184, 16
			'.Caption = ML("Create Project / File")
			.Designer = @This
			.OnClick = @optCreateProjectFile_Click
			.Parent = @grbWhenVFBEStarts
		End With
		' optOpenLastSession
		With optOpenLastSession
			.Name = "optOpenLastSession"
			.Text = ML("Open Last Opened File")
			.SetBounds 19, 67, 184, 16
			.Designer = @This
			.OnClick = @optOpenLastSession_Click
			.Parent = @grbWhenVFBEStarts
		End With
		' optDoNotNothing
		With optDoNotNothing
			.Name = "optDoNotNothing"
			.Text = ML("Don't Nothing")
			.SetBounds 19, 90, 184, 16
			'.Caption = ML("Don't Nothing")
			.Designer = @This
			.OnClick = @optDoNotNothing_Click
			.Parent = @grbWhenVFBEStarts
		End With
		' cboDefaultProjectFile
		With cboDefaultProjectFile
			.Name = "cboDefaultProjectFile"
			.Text = "ComboBoxEdit1"
			.SetBounds 222, 41, 175, 21
			.Parent = @grbWhenVFBEStarts
		End With
		' cmdFindCompilers
		With cmdFindCompilers
			.Name = "cmdFindCompilers"
			.Text = ML("&Find")
			.TabIndex = 167
			.SetBounds 307, 14, 96, 24
			'.Caption = ML("&Find")
			.Designer = @This
			.OnClick = @cmdFindCompilers_Click_
			.Parent = @grbCompilerPaths
		End With
		' lblFindCompilersFromComputer
		With lblFindCompilersFromComputer
			.Name = "lblFindCompilersFromComputer"
			.Text = ML("Find Compilers from Computer:")
			.TabIndex = 168
			.SetBounds 20, 19, 280, 20
			'.Caption = ML("Find Compilers from Computer:")
			.Parent = @grbCompilerPaths
		End With
		' optPromptToSave
		With optPromptToSave
			.Name = "optPromptToSave"
			.Text = ML("Prompt To Save")
			.TabIndex = 166
			.SetBounds 18, 68, 184, 16
			'.Caption = ML("Prompt To Save")
			.Parent = @grbWhenCompiling
		End With
		' chkShowKeywordsTooltip
		With chkShowKeywordsTooltip
			.Name = "chkShowKeywordsTooltip"
			.Text = ML("Show Keywords Tooltip")
			.TabIndex = 170
			.SetBounds 10, 63, 264, 18
			'.Caption = ML("Show Keywords Tooltip")
			.Parent = @pnlCodeEditor
		End With
		' chkAddSpacesToOperators
		With chkAddSpacesToOperators
			.Name = "chkAddSpacesToOperators"
			.Text = ML("Add Spaces To Operators")
			.TabIndex = 171
			.SetBounds 10, 153, 194, 18
			'.Caption = ML("Add Spaces To Operators")
			.Parent = @pnlCodeEditor
		End With
		' cboOpenedFile
		With cboOpenedFile
			.Name = "cboOpenedFile"
			.Text = "ComboBoxEdit1"
			.TabIndex = 172
			.SetBounds 222, 65, 175, 21
			.Parent = @grbWhenVFBEStarts
		End With
		' chkCreateFormTypesWithoutTypeWord
		With chkCreateFormTypesWithoutTypeWord
			.Name = "chkCreateFormTypesWithoutTypeWord"
			.Text = ML("Create Form types without Type word")
			.TabIndex = 173
			.SetBounds 12, 128, 288, 24
			'.Caption = ML("Create Form types without Type word")
			.Parent = @pnlDesigner
		End With
		' grbCommandPromptOptions
		With grbCommandPromptOptions
			.Name = "grbCommandPromptOptions"
			.Text = ML("Command Prompt options")
			.TabIndex = 174
			.SetBounds 10, 68, 416, 94
			'.Caption = ML("Command Prompt options")
			.Parent = @pnlTerminal
		End With
		' optMainFileFolder
		With optMainFileFolder
			.Name = "optMainFileFolder"
			.Text = ML("Main File folder")
			.TabIndex = 175
			.SetBounds 20, 39, 220, 20
			'.Caption = ML("Main File folder")
			.Parent = @grbCommandPromptOptions
		End With
		' lblOpenCommandPromptIn
		With lblOpenCommandPromptIn
			.Name = "lblOpenCommandPromptIn"
			.Text = ML("Open command prompt in:")
			.TabIndex = 176
			.SetBounds 20, 19, 380, 20
			'.Caption = ML("Open command prompt in:")
			.Parent = @grbCommandPromptOptions
		End With
		' optInFolder
		With optInFolder
			.Name = "optInFolder"
			.Text = ML("Folder") & ":"
			.TabIndex = 177
			.SetBounds 20, 59, 120, 20
			'.Caption = ML("Folder:")
			.Parent = @grbCommandPromptOptions
		End With
		' txtInFolder
		With txtInFolder
			.Name = "txtInFolder"
			.Text = "./Projects"
			.TabIndex = 178
			.SetBounds 140, 58, 240, 20
			.Parent = @grbCommandPromptOptions
		End With
		' cmdInFolder
		With cmdInFolder
			.Name = "cmdInFolder"
			.Text = "..."
			.TabIndex = 179
			.SetBounds 380, 57, 24, 22
			.Designer = @This
			.OnClick = @cmdInFolder_Click_
			.Parent = @grbCommandPromptOptions
		End With
		' lblIntellisenseLimit
		With lblIntellisenseLimit
			.Name = "lblIntellisenseLimit"
			.Text = ML("Intellisense limit") & ":"
			.TabIndex = 180
			'.Caption = ML("Intellisense limit") & ":"
			.SetBounds 66, 269, 150, 17
			.Parent = @pnlCodeEditor
		End With
		' txtIntellisenseLimit
		With txtIntellisenseLimit
			.Name = "txtIntellisenseLimit"
			.TabIndex = 181
			.SetBounds 209, 267, 90, 20
			.Parent = @pnlCodeEditor
		End With
		' txtEnvironmentVariables
		With txtEnvironmentVariables
			.Name = "txtEnvironmentVariables"
			.Text = ""
			.TabIndex = 182
			.SetBounds 262, 180, 150, 20
			.Parent = @pnlDebugger
		End With
		' chkTurnOnEnvironmentVariables
		With chkTurnOnEnvironmentVariables
			.Name = "chkTurnOnEnvironmentVariables"
			.Text = ML("Turn on Environment variables") & ":"
			.TabIndex = 184
			'.Caption = ML("Turn on Environment variables") & ":"
			.SetBounds 15, 182, 200, 16
			.Parent = @pnlDebugger
		End With
		' lblDebugger321
		With lblDebugger321
			.Name = "lblDebugger321"
			.Text = ML("GDB") & " " & ML("32-bit")
			.TabIndex = 184
			'.Caption = ML("GDB") & " " & ML("32-bit")
			.SetBounds 222, 21, 180, 18
			.Parent = @grbDefaultDebuggers
		End With
		' cboGDBDebugger32
		With cboGDBDebugger32
			.Name = "cboGDBDebugger32"
			.Text = "cboCompiler321"
			.TabIndex = 185
			.SetBounds 218, 39, 184, 21
			.Parent = @grbDefaultDebuggers
		End With
		' lblDebugger641
		With lblDebugger641
			.Name = "lblDebugger641"
			.Text = ML("GDB") & " " & ML("64-bit")
			.TabIndex = 186
			'.Caption = ML("GDB") & " " & ML("64-bit")
			.SetBounds 222, 71, 180, 18
			.Parent = @grbDefaultDebuggers
		End With
		' cboGDBDebugger64
		With cboGDBDebugger64
			.Name = "cboGDBDebugger64"
			.Text = "cboDebugger64"
			.TabIndex = 187
			.SetBounds 218, 89, 184, 21
			.Parent = @grbDefaultDebuggers
		End With
		' chkDarkMode
		With chkDarkMode
			.Name = "chkDarkMode"
			.Text = ML("Dark Mode (available for Linux, Windows 10 and above)")
			.TabIndex = 188
			'.Caption = ML("Dark Mode")
			.Caption = ML("Dark Mode (available for Linux, Windows 10 and above)")
			.SetBounds 2, 38, 384, 24
			.Parent = @pnlThemesCheckboxes
		End With
		' chkPlaceStaticEventHandlersAfterTheConstructor
		With chkPlaceStaticEventHandlersAfterTheConstructor
			.Name = "chkPlaceStaticEventHandlersAfterTheConstructor"
			.Text = ML("Place static event handlers after the Constructor")
			.TabIndex = 189
			'.Caption = ML("Place static event handlers after the Constructor")
			.SetBounds 32, 172, 310, 24
			.Parent = @pnlDesigner
		End With
		' chkCreateStaticEventHandlersWithAnUnderscoreAtTheBeginning
		With chkCreateStaticEventHandlersWithAnUnderscoreAtTheBeginning
			.Name = "chkCreateStaticEventHandlersWithAnUnderscoreAtTheBeginning"
			.Text = ML("Create static event handlers with an underscore at the beginning")
			.TabIndex = 190
			'.Caption = ML("Create static event handlers with an underscore at the beginning")
			.SetBounds 32, 195, 380, 24
			.Parent = @pnlDesigner
		End With
		' chkAddRelativePathsToRecent
		With chkAddRelativePathsToRecent
			.Name = "chkAddRelativePathsToRecent"
			.Text = ML("Add relative paths to recent")
			.TabIndex = 191
			.Caption = ML("Add relative paths to recent")
			.SetBounds 10, 69, 400, 16
			.Parent = @pnlGeneral
		End With
	End Constructor
	
	Private Sub frmOptions.chkCreateNonStaticEventHandlers_Click_(ByRef Sender As CheckBox)
		*Cast(frmOptions Ptr, Sender.Designer).chkCreateNonStaticEventHandlers_Click(Sender)
	End Sub
	
	Destructor frmOptions
		FDisposing = True
		WDeallocate InterfFontName
		WDeallocate OldInterfFontName
		WDeallocate EditFontName
	End Destructor
	
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

Sub AddColors(ByRef cs As ECColorScheme, Foreground As Boolean = True, Background As Boolean = True, Frame As Boolean = True, Indicator As Boolean = True, Bold As Boolean = True, Italic As Boolean = True, Underline As Boolean = True)
	With fOptions
		.Colors(.ColorsCount, 0) = IIf(Foreground, cs.Foreground, -2)
		.Colors(.ColorsCount, 1) = IIf(Background, cs.Background, -2)
		.Colors(.ColorsCount, 2) = IIf(Frame, cs.Frame, -2)
		.Colors(.ColorsCount, 3) = IIf(Indicator, cs.Indicator, -2)
		.Colors(.ColorsCount, 4) = IIf(Bold, cs.Bold, -2)
		.Colors(.ColorsCount, 5) = IIf(Italic, cs.Italic, -2)
		.Colors(.ColorsCount, 6) = IIf(Underline, cs.Underline, -2)
		.ColorsCount += 1
	End With
End Sub

Sub frmOptions.LoadSettings()
	With fOptions
		.tvOptions.SelectedNode = .tvOptions.Nodes.Item(0)
		.TreeView1_SelChange .tvOptions, *.tvOptions.Nodes.Item(0)
		.chkTabAsSpaces.Checked = TabAsSpaces
		.cboTabStyle.ItemIndex = ChoosedTabStyle
		.cboCase.ItemIndex = ChoosedKeyWordsCase
		.chkChangeKeywordsCase.Checked = ChangeKeywordsCase
		.chkAddSpacesToOperators.Checked = AddSpacesToOperators
		.chkUseMakeOnStartWithCompile.Checked = UseMakeOnStartWithCompile
		.chkLimitDebug.Checked = LimitDebug
		.chkTurnOnEnvironmentVariables.Checked = TurnOnEnvironmentVariables
		.txtEnvironmentVariables.Text = *EnvironmentVariables
		.txtTabSize.Text = Str(TabWidth)
		.txtHistoryLimit.Text = Str(HistoryLimit)
		.txtIntellisenseLimit.Text = Str(IntellisenseLimit)
		.txtMFFPath.Text = *MFFPath
		.chkIncludeMFFPath.Checked = IncludeMFFPath
		.txtProjectsPath.Text = *ProjectsPath
		.CheckBox1.Checked = AutoIncrement
		.chkEnableAutoComplete.Checked = AutoComplete
		.chkAutoIndentation.Checked = AutoIndentation
		.chkAutoCreateRC.Checked = AutoCreateRC
		.chkAutoCreateBakFiles.Checked = AutoCreateBakFiles
		.chkAddRelativePathsToRecent.Checked = AddRelativePathsToRecent
		.chkCreateNonStaticEventHandlers.Checked = CreateNonStaticEventHandlers
		.chkPlaceStaticEventHandlersAfterTheConstructor.Checked = PlaceStaticEventHandlersAfterTheConstructor
		.chkCreateStaticEventHandlersWithAnUnderscoreAtTheBeginning.Checked = CreateStaticEventHandlersWithAnUnderscoreAtTheBeginning
		.chkCreateFormTypesWithoutTypeWord.Checked = CreateFormTypesWithoutTypeWord
		.chkCreateNonStaticEventHandlers_Click(.chkCreateNonStaticEventHandlers)
		.optMainFileFolder.Checked = OpenCommandPromptInMainFileFolder
		.optInFolder.Checked = Not OpenCommandPromptInMainFileFolder
		.txtInFolder.Text = *CommandPromptFolder
		Select Case WhenVisualFBEditorStarts
		Case 0: .optDoNotNothing.Checked = True
		Case 1: .optPromptForProjectAndFile.Checked = True
		Case 2: .optCreateProjectFile.Checked = True
		Case 3: .optOpenLastSession.Checked = True
		End Select
		Select Case AutoSaveBeforeCompiling
		Case 0: .optDoNotSave.Checked = True
		Case 1: .optSaveCurrentFile.Checked = True
		Case 2: .optSaveAllFiles.Checked = True
		Case 3: .optPromptToSave.Checked = True
		End Select
		.chkShowSpaces.Checked = ShowSpaces
		.chkShowKeywordsTooltip.Checked = ShowKeywordsToolTip
		.chkHighlightBrackets.Checked = HighlightBrackets
		.chkHighlightCurrentLine.Checked = HighlightCurrentLine
		.chkHighlightCurrentWord.Checked = HighlightCurrentWord
		.txtGridSize.Text = Str(GridSize)
		.chkShowAlignmentGrid.Checked = ShowAlignmentGrid
		.chkSnapToGrid.Checked = SnapToGridOption
		.cboLanguage.Clear
		.chkDisplayIcons.Checked = DisplayMenuIcons
		.chkShowMainToolbar.Checked = ShowMainToolbar
		.chkDarkMode.Checked = DarkMode
		Dim As String f
		Dim As Integer Fn, Result
		Dim Buff As WString * 2048 '
		Dim As UString FileName
		'On Error Resume Next
		.cboDefaultProjectFile.Clear
		f = Dir(ExePath & "/Templates/Projects/*.vfp")
		While f <> ""
			.cboDefaultProjectFile.AddItem ..Left(f, IfNegative(InStr(f, ".") - 1, Len(f)))
			Templates.Add "Projects/" & f
			f = Dir()
		Wend
		f = Dir(ExePath & "/Templates/Files/*")
		While f <> ""
			.cboDefaultProjectFile.AddItem ..Left(f, IfNegative(InStr(f, ".") - 1, Len(f)))
			Templates.Add "Files/" & f
			f = Dir()
		Wend
		.cboDefaultProjectFile.ItemIndex = Templates.IndexOf(WGet(DefaultProjectFile))
		.cboOpenedFile.ItemIndex = LastOpenedFileType
		f = Dir(ExePath & "/Settings/Languages/*.lng")
		While f <> ""
			FileName = ExePath & "/Settings/Languages/" & f
			Fn = FreeFile_
			Result = Open(FileName For Input Encoding "utf-8" As #Fn)
			If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-16" As #Fn)
			If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-32" As #Fn)
			If Result <> 0 Then Result = Open(FileName For Input As #Fn)
			If Result = 0 Then
				'WReallocate s, LOF(Fn) '
				If Not EOF(Fn) Then
					Line Input #Fn, Buff  '
					Languages.Add ..Left(f, Len(f) - 4)
					.cboLanguage.AddItem Buff & " - " & ..Left(f, Len(f) - 4)
				End If
				CloseFile_(Fn)
			Else
				Languages.Add ..Left(f, Len(f) - 4)
				.cboLanguage.AddItem ..Left(f, Len(f) - 4) & " (" & ML("format does not match") & ")"
			End If
			f = Dir()
		Wend
		HotKeysChanged = False 
		'On Error Goto 0
		'WDeallocate s '
		newIndex = Languages.IndexOf(CurLanguage)
		.cboLanguage.ItemIndex = newIndex
		oldIndex = newIndex
		.cboTheme.Clear
		f = Dir(ExePath & "/Settings/Themes/*.ini")
		While f <> ""
			.cboTheme.AddItem ..Left(f, Len(f) - 4)
			f = Dir()
		Wend
		.cboTheme.ItemIndex = .cboTheme.IndexOf(*CurrentTheme)
		.cboCompiler32.Clear
		.cboCompiler64.Clear
		.lvCompilerPaths.ListItems.Clear
		.cboCompiler32.AddItem ML("(not selected)")
		.cboCompiler64.AddItem ML("(not selected)")
		For i As Integer = 0 To pCompilers->Count - 1
			.lvCompilerPaths.ListItems.Add pCompilers->Item(i)->Key, IIf(FileExists(pCompilers->Item(i)->Text), "", "FileError")
			.lvCompilerPaths.ListItems.Item(i)->Text(1) = pCompilers->Item(i)->Text
			.lvCompilerPaths.ListItems.Item(i)->Text(2) = Cast(ToolType Ptr, pCompilers->Item(i)->Object)->Parameters
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
			.lvMakeToolPaths.ListItems.Item(i)->Text(2) = Cast(ToolType Ptr, pMakeTools->Item(i)->Object)->Parameters
			.cboMakeTool.AddItem pMakeTools->Item(i)->Key
		Next
		.cboMakeTool.ItemIndex = Max(0, .cboMakeTool.IndexOf(*DefaultMakeTool))
		.cboDebugger32.Clear
		.cboDebugger64.Clear
		.cboGDBDebugger32.Clear
		.cboGDBDebugger64.Clear
		.lvDebuggerPaths.ListItems.Clear
		.cboDebugger32.AddItem ML("Integrated IDE Debugger")
		.cboDebugger32.AddItem ML("Integrated GDB Debugger")
		.cboDebugger64.AddItem ML("Integrated IDE Debugger")
		.cboDebugger64.AddItem ML("Integrated GDB Debugger")
		For i As Integer = 0 To pDebuggers->Count - 1
			.lvDebuggerPaths.ListItems.Add pDebuggers->Item(i)->Key
			.lvDebuggerPaths.ListItems.Item(i)->Text(1) = pDebuggers->Item(i)->Text
			.lvDebuggerPaths.ListItems.Item(i)->Text(2) = Cast(ToolType Ptr, pDebuggers->Item(i)->Object)->Parameters
			.cboDebugger32.AddItem pDebuggers->Item(i)->Key
			.cboDebugger64.AddItem pDebuggers->Item(i)->Key
			.cboGDBDebugger32.AddItem pDebuggers->Item(i)->Key
			.cboGDBDebugger64.AddItem pDebuggers->Item(i)->Key
		Next
		.cboDebugger32.ItemIndex = Max(0, .cboDebugger32.IndexOf(*DefaultDebugger32))
		.cboDebugger64.ItemIndex = Max(0, .cboDebugger64.IndexOf(*DefaultDebugger64))
		.cboGDBDebugger32.ItemIndex = Max(0, .cboGDBDebugger32.IndexOf(*GDBDebugger32))
		.cboGDBDebugger64.ItemIndex = Max(0, .cboGDBDebugger64.IndexOf(*GDBDebugger64))
		.cboTerminal.Clear
		.lvTerminalPaths.ListItems.Clear
		.cboTerminal.AddItem ML("(not selected)")
		For i As Integer = 0 To pTerminals->Count - 1
			.lvTerminalPaths.ListItems.Add pTerminals->Item(i)->Key
			.lvTerminalPaths.ListItems.Item(i)->Text(1) = pTerminals->Item(i)->Text
			.lvTerminalPaths.ListItems.Item(i)->Text(2) = Cast(ToolType Ptr, pTerminals->Item(i)->Object)->Parameters
			.cboTerminal.AddItem pTerminals->Item(i)->Key
		Next
		.cboTerminal.ItemIndex = Max(0, .cboTerminal.IndexOf(*DefaultTerminal))
		.lvOtherEditors.ListItems.Clear
		For i As Integer = 0 To pOtherEditors->Count - 1
			.lvOtherEditors.ListItems.Add pOtherEditors->Item(i)->Key
			.lvOtherEditors.ListItems.Item(i)->Text(1) = Cast(ToolType Ptr, pOtherEditors->Item(i)->Object)->Extensions
			.lvOtherEditors.ListItems.Item(i)->Text(2) = pOtherEditors->Item(i)->Text
			.lvOtherEditors.ListItems.Item(i)->Text(3) = Cast(ToolType Ptr, pOtherEditors->Item(i)->Object)->Parameters
		Next
		.cboHelp.Clear
		.lvHelpPaths.ListItems.Clear
		.cboHelp.AddItem ML("(not selected)")
		For i As Integer = 0 To pHelps->Count - 1
			.lvHelpPaths.ListItems.Add pHelps->Item(i)->Key
			.lvHelpPaths.ListItems.Item(i)->Text(1) = pHelps->Item(i)->Text
			.cboHelp.AddItem pHelps->Item(i)->Key
		Next
		.cboHelp.ItemIndex = Max(0, .cboHelp.IndexOf(*DefaultHelp))
		.lstIncludePaths.Clear
		For i As Integer = 0 To pIncludePaths->Count - 1
			.lstIncludePaths.AddItem pIncludePaths->Item(i)
		Next
		.lstLibraryPaths.Clear
		For i As Integer = 0 To pLibraryPaths->Count - 1
			.lstLibraryPaths.AddItem pLibraryPaths->Item(i)
		Next
'		For i As Integer = 0 To 15
'			For j As Integer = 0 To 6
'				.Colors(i, j) = -2
'			Next
'		Next
		.ColorsCount = 0
		AddColors Bookmarks
'		.Colors(0, 0) = Bookmarks.Foreground
'		.Colors(0, 1) = Bookmarks.Background
'		.Colors(0, 2) = Bookmarks.Frame
'		.Colors(0, 3) = Bookmarks.Indicator
'		.Colors(0, 4) = Bookmarks.Bold
'		.Colors(0, 5) = Bookmarks.Italic
'		.Colors(0, 6) = Bookmarks.Underline
		AddColors Breakpoints
'		.Colors(1, 0) = Breakpoints.Foreground
'		.Colors(1, 1) = Breakpoints.Background
'		.Colors(1, 2) = Breakpoints.Frame
'		.Colors(1, 3) = Breakpoints.Indicator
'		.Colors(1, 4) = Breakpoints.Bold
'		.Colors(1, 5) = Breakpoints.Italic
'		.Colors(1, 6) = Breakpoints.Underline
		AddColors Comments, , , , False
'		.Colors(2, 0) = Comments.Foreground
'		.Colors(2, 1) = Comments.Background
'		.Colors(2, 2) = Comments.Frame
'		.Colors(2, 4) = Comments.Bold
'		.Colors(2, 5) = Comments.Italic
'		.Colors(2, 6) = Comments.Underline
		AddColors CurrentBrackets, , , , False
'		.Colors(3, 0) = CurrentBrackets.Foreground
'		.Colors(3, 1) = CurrentBrackets.Background
'		.Colors(3, 2) = CurrentBrackets.Frame
'		.Colors(3, 4) = CurrentBrackets.Bold
'		.Colors(3, 5) = CurrentBrackets.Italic
'		.Colors(3, 6) = CurrentBrackets.Underline
		AddColors CurrentLine, , , , False, False, False, False
'		.Colors(4, 0) = CurrentLine.Foreground
'		.Colors(4, 1) = CurrentLine.Background
'		.Colors(4, 2) = CurrentLine.Frame
		AddColors CurrentWord, , , , False
'		.Colors(5, 0) = CurrentWord.Foreground
'		.Colors(5, 1) = CurrentWord.Background
'		.Colors(5, 2) = CurrentWord.Frame
'		.Colors(5, 4) = CurrentWord.Bold
'		.Colors(5, 5) = CurrentWord.Italic
'		.Colors(5, 6) = CurrentWord.Underline
		AddColors ExecutionLine, , , , , False, False, False
'		.Colors(6, 0) = ExecutionLine.Foreground
'		.Colors(6, 1) = ExecutionLine.Background
'		.Colors(6, 2) = ExecutionLine.Frame
'		.Colors(6, 3) = ExecutionLine.Indicator
		AddColors FoldLines, , False, False, False, False, False, False
'		.Colors(7, 0) = FoldLines.Foreground
		AddColors Identifiers, , , , False
		AddColors IndicatorLines, , False, False, False, False, False, False
'		.Colors(8, 0) = IndicatorLines.Foreground
		For k As Integer = 0 To UBound(Keywords)
			'ReDim Preserve Keywords(k)
			AddColors Keywords(k), , , , False
		Next
'		.Colors(9, 0) = Keywords.Foreground
'		.Colors(9, 1) = Keywords.Background
'		.Colors(9, 2) = Keywords.Frame
'		.Colors(9, 4) = Keywords.Bold
'		.Colors(9, 5) = Keywords.Italic
'		.Colors(9, 6) = Keywords.Underline
		AddColors LineNumbers, , , False, False
'		.Colors(10, 0) = LineNumbers.Foreground
'		.Colors(10, 1) = LineNumbers.Background
'		.Colors(10, 4) = LineNumbers.Bold
'		.Colors(10, 5) = LineNumbers.Italic
'		.Colors(10, 6) = LineNumbers.Underline
		AddColors NormalText, , , , False
'		.Colors(11, 0) = NormalText.Foreground
'		.Colors(11, 1) = NormalText.Background
'		.Colors(11, 2) = NormalText.Frame
'		.Colors(11, 4) = NormalText.Bold
'		.Colors(11, 5) = NormalText.Italic
'		.Colors(11, 6) = NormalText.Underline
'		.Colors(12, 0) = Preprocessors.Foreground
'		.Colors(12, 1) = Preprocessors.Background
'		.Colors(12, 2) = Preprocessors.Frame
'		.Colors(12, 4) = Preprocessors.Bold
'		.Colors(12, 5) = Preprocessors.Italic
'		.Colors(12, 6) = Preprocessors.Underline
		AddColors Numbers, , , , False
		AddColors RealNumbers, , , , False
		AddColors Selection, , , , False, False, False, False
'		.Colors(13, 0) = Selection.Foreground
'		.Colors(13, 1) = Selection.Background
'		.Colors(13, 2) = Selection.Frame
		AddColors SpaceIdentifiers, , False, False, False, False, False, False
'		.Colors(14, 0) = SpaceIdentifiers.Foreground
		AddColors Strings, , , , False
'		.Colors(15, 0) = Strings.Foreground
'		.Colors(15, 1) = Strings.Background
'		.Colors(15, 2) = Strings.Frame
'		.Colors(15, 4) = Strings.Bold
'		.Colors(15, 5) = Strings.Italic
'		.Colors(15, 6) = Strings.Underline
		.lstColorKeys.ItemIndex = 0
		.lstColorKeys_Change(.lstColorKeys)
		WLet(.EditFontName, *EditorFontName)
		.EditFontSize = EditorFontSize
		.lblFont.Font.Name = *EditorFontName
		.lblFont.Caption = *.EditFontName & ", " & .EditFontSize & "pt"
		WLet(.InterfFontName, *InterfaceFontName)
		WLet(.OldInterfFontName, *InterfaceFontName)
		.InterfFontSize = InterfaceFontSize
		.oldInterfFontSize = InterfaceFontSize
		.oldDisplayMenuIcons = DisplayMenuIcons
		.oldDarkMode = DarkMode
		.lblInterfaceFont.Font.Name = *InterfaceFontName
		.lblInterfaceFont.Caption = *.InterfFontName & ", " & .InterfFontSize & "pt"
	End With
End Sub

Sub AddShortcuts(item As MenuItem Ptr, ByRef Prefix As WString = "")
	With fOptions
		If StartsWith(item->Name, "Recent") OrElse item->Caption = "-" Then Exit Sub
		Dim As UString itemCaption = Replace(IIf(Prefix = "", "", Prefix & " -> ") & item->Caption, "&", "")
		Dim As UString itemHotKey
		Dim As Integer Pos1 = InStr(itemCaption, !"\t")
		If Pos1 > 0 Then
			itemHotKey = Mid(itemCaption, Pos1 + 1)
			itemCaption = Left(itemCaption, Pos1 - 1)
		End If
		If item->Count = 0 Then
			.HotKeysPriv.Add item->Name
			.lvShortcuts.ListItems.Add itemCaption
			.lvShortcuts.ListItems.Item(.lvShortcuts.ListItems.Count - 1)->Text(1) = itemHotKey
			.lvShortcuts.ListItems.Item(.lvShortcuts.ListItems.Count - 1)->Tag = item
		Else
			For i As Integer = 0 To item->Count - 1
				AddShortcuts item->Item(i), itemCaption
			Next
		End If
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
		tnGeneral->Nodes.Add(ML("Localization"), "Localization")
		tnGeneral->Nodes.Add(ML("Shortcuts"), "Shortcuts")
		tnGeneral->Nodes.Add(ML("Themes"), "Themes")
		tnEditor->Nodes.Add(ML("Colors And Fonts"), "ColorsAndFonts")
		tnEditor->Nodes.Add(ML("Other Editors"), "OtherEditors")
		tnCompiler->Nodes.Add(ML("Includes"), "Includes")
		tnCompiler->Nodes.Add(ML("Make Tool"), "MakeTool")
		tnDebugger->Nodes.Add(ML("Terminal"), "Terminal")
		.tvOptions.Nodes.Add(ML("Help"), "Help")
		.tvOptions.ExpandAll
		.lvShortcuts.Columns.Add ML("Action"), , 250
		.lvShortcuts.Columns.Add ML("Shortcut"), , 100
		.lvOtherEditors.Columns.Add ML("Version"), , 126
		.lvOtherEditors.Columns.Add ML("Extensions"), , 126
		.lvOtherEditors.Columns.Add ML("Path"), , 126
		.lvOtherEditors.Columns.Add ML("Commad line"), , 80
		.lvCompilerPaths.Columns.Add ML("Version"), , 190
		.lvCompilerPaths.Columns.Add ML("Path"), , 190
		.lvCompilerPaths.Columns.Add ML("Command line"), , 80
		.lvMakeToolPaths.Columns.Add ML("Version"), , 190
		.lvMakeToolPaths.Columns.Add ML("Path"), , 190
		.lvMakeToolPaths.Columns.Add ML("Command line"), , 80
		.lvDebuggerPaths.Columns.Add ML("Version"), , 190
		.lvDebuggerPaths.Columns.Add ML("Path"), , 190
		.lvDebuggerPaths.Columns.Add ML("Command line"), , 80
		.lvTerminalPaths.Columns.Add ML("Version"), , 190
		.lvTerminalPaths.Columns.Add ML("Path"), , 190
		.lvTerminalPaths.Columns.Add ML("Command line"), , 80
		.lvHelpPaths.Columns.Add ML("Version"), , 190
		.lvHelpPaths.Columns.Add ML("Path"), , 190
		.cboCase.AddItem ML("Original Case")
		.cboCase.AddItem ML("Lower Case")
		.cboCase.AddItem ML("Upper Case")
		.cboTabStyle.AddItem ML("Everywhere")
		.cboTabStyle.AddItem ML("Only after the words")
		.lstColorKeys.AddItem ML("Bookmarks")
		.lstColorKeys.AddItem ML("Breakpoints")
		.lstColorKeys.AddItem ML("Comments")
		.lstColorKeys.AddItem ML("Current Brackets")
		.lstColorKeys.AddItem ML("Current Line")
		.lstColorKeys.AddItem ML("Current Word")
		.lstColorKeys.AddItem ML("Executed Line")
		.lstColorKeys.AddItem ML("Fold Lines")
		.lstColorKeys.AddItem ML("Identifiers")
		.lstColorKeys.AddItem ML("Indicator Lines")
		For k As Integer = 0 To KeywordLists.Count - 1
			.lstColorKeys.AddItem ML("Keywords") & ": " & KeywordLists.Item(k)
		Next k
		.lstColorKeys.AddItem ML("Line Numbers")
		.lstColorKeys.AddItem ML("Normal Text")
		.lstColorKeys.AddItem ML("Numbers")
		.lstColorKeys.AddItem ML("Real Numbers")
'		.lstColorKeys.AddItem ML("Preprocessors")
		.lstColorKeys.AddItem ML("Selection")
		.lstColorKeys.AddItem ML("Space Identifiers")
		.lstColorKeys.AddItem ML("Strings")
		.lstColorKeys.ItemIndex = 0
		.cboOpenedFile.AddItem ML("All file types")
		.cboOpenedFile.AddItem ML("Session file")
		.cboOpenedFile.AddItem ML("Folder")
		.cboOpenedFile.AddItem ML("Project file")
		.cboOpenedFile.AddItem ML("Other file types")
		For i As Integer = 0 To pfrmMain->Menu->Count - 1
			AddShortcuts(pfrmMain->Menu->Item(i))
		Next
		ReDim .Colors(17 + KeywordLists.Count - 1, 7)
		.LoadSettings
	End With
End Sub

Sub SetColor(ByRef cs As ECColorScheme)
	With fOptions
		cs.ForegroundOption = .Colors(.ColorsCount, 0)
		cs.BackgroundOption = .Colors(.ColorsCount, 1)
		cs.FrameOption = .Colors(.ColorsCount, 2)
		cs.IndicatorOption = .Colors(.ColorsCount, 3)
		cs.Bold = .Colors(.ColorsCount, 4)
		cs.Italic = .Colors(.ColorsCount, 5)
		cs.Underline = .Colors(.ColorsCount, 6)
		.ColorsCount += 1
	End With
End Sub

Sub SetColors
	With fOptions
		.ColorsCount = 0
		SetColor Bookmarks
'		Bookmarks.ForegroundOption = .Colors(0, 0)
'		Bookmarks.BackgroundOption = .Colors(0, 1)
'		Bookmarks.FrameOption = .Colors(0, 2)
'		Bookmarks.IndicatorOption = .Colors(0, 3)
'		Bookmarks.Bold = .Colors(0, 4)
'		Bookmarks.Italic = .Colors(0, 5)
'		Bookmarks.Underline = .Colors(0, 6)
		SetColor Breakpoints
'		Breakpoints.ForegroundOption = .Colors(1, 0)
'		Breakpoints.BackgroundOption = .Colors(1, 1)
'		Breakpoints.FrameOption = .Colors(1, 2)
'		Breakpoints.IndicatorOption = .Colors(1, 3)
'		Breakpoints.Bold = .Colors(1, 4)
'		Breakpoints.Italic = .Colors(1, 5)
'		Breakpoints.Underline = .Colors(1, 6)
		SetColor Comments
'		Comments.ForegroundOption = .Colors(2, 0)
'		Comments.BackgroundOption = .Colors(2, 1)
'		Comments.FrameOption = .Colors(2, 2)
'		Comments.Bold = .Colors(2, 4)
'		Comments.Italic = .Colors(2, 5)
'		Comments.Underline = .Colors(2, 6)
		SetColor CurrentBrackets
'		CurrentBrackets.ForegroundOption = .Colors(3, 0)
'		CurrentBrackets.BackgroundOption = .Colors(3, 1)
'		CurrentBrackets.FrameOption = .Colors(3, 2)
'		CurrentBrackets.Bold = .Colors(3, 4)
'		CurrentBrackets.Italic = .Colors(3, 5)
'		CurrentBrackets.Underline = .Colors(3, 6)
		SetColor CurrentLine
'		CurrentLine.ForegroundOption = .Colors(4, 0)
'		CurrentLine.BackgroundOption = .Colors(4, 1)
'		CurrentLine.FrameOption = .Colors(4, 2)
		SetColor CurrentWord
'		CurrentWord.ForegroundOption = .Colors(5, 0)
'		CurrentWord.BackgroundOption = .Colors(5, 1)
'		CurrentWord.FrameOption = .Colors(5, 2)
'		CurrentWord.Bold = .Colors(5, 4)
'		CurrentWord.Italic = .Colors(5, 5)
'		CurrentWord.Underline = .Colors(5, 6)
		SetColor ExecutionLine
'		ExecutionLine.ForegroundOption = .Colors(6, 0)
'		ExecutionLine.BackgroundOption = .Colors(6, 1)
'		ExecutionLine.FrameOption = .Colors(6, 2)
'		ExecutionLine.IndicatorOption = .Colors(6, 3)
		SetColor FoldLines
'		FoldLines.ForegroundOption = .Colors(7, 0)
		SetColor Identifiers
		SetColor IndicatorLines
'		IndicatorLines.ForegroundOption = .Colors(8, 0)
		For k As Integer = 0 To UBound(Keywords)
			SetColor Keywords(k)
		Next k
'		Keywords.ForegroundOption = .Colors(9, 0)
'		Keywords.BackgroundOption = .Colors(9, 1)
'		Keywords.FrameOption = .Colors(9, 2)
'		Keywords.Bold = .Colors(9, 4)
'		Keywords.Italic = .Colors(9, 5)
'		Keywords.Underline = .Colors(9, 6)
		SetColor LineNumbers
'		LineNumbers.ForegroundOption = .Colors(10, 0)
'		LineNumbers.BackgroundOption = .Colors(10, 1)
'		LineNumbers.Bold = .Colors(10, 4)
'		LineNumbers.Italic = .Colors(10, 5)
'		LineNumbers.Underline = .Colors(10, 6)
		SetColor NormalText
		SetColor Numbers
		SetColor RealNumbers
'		NormalText.ForegroundOption = .Colors(11, 0)
'		NormalText.BackgroundOption = .Colors(11, 1)
'		NormalText.FrameOption = .Colors(11, 2)
'		NormalText.Bold = .Colors(11, 4)
'		NormalText.Italic = .Colors(11, 5)
'		NormalText.Underline = .Colors(11, 6)
'		Preprocessors.ForegroundOption = .Colors(12, 0)
'		Preprocessors.BackgroundOption = .Colors(12, 1)
'		Preprocessors.FrameOption = .Colors(12, 2)
'		Preprocessors.Bold = .Colors(12, 4)
'		Preprocessors.Italic = .Colors(12, 5)
'		Preprocessors.Underline = .Colors(12, 6)
		SetColor Selection
'		Selection.ForegroundOption = .Colors(13, 0)
'		Selection.BackgroundOption = .Colors(13, 1)
'		Selection.FrameOption = .Colors(13, 2)
		SetColor SpaceIdentifiers
'		SpaceIdentifiers.ForegroundOption = .Colors(14, 0)
		SetColor Strings
'		Strings.ForegroundOption = .Colors(15, 0)
'		Strings.BackgroundOption = .Colors(15, 1)
'		Strings.FrameOption = .Colors(15, 2)
'		Strings.Bold = .Colors(15, 4)
'		Strings.Italic = .Colors(15, 5)
'		Strings.Underline = .Colors(15, 6)
		SetAutoColors
	End With
End Sub

Private Sub frmOptions.cmdApply_Click(ByRef Sender As Control)
	On Error Goto ErrorHandler
	Dim As ToolType Ptr Tool
	With fOptions
		For i As Integer = 0 To pCompilers->Count - 1
			Delete_(Cast(ToolType Ptr, pCompilers->Item(i)->Object))
		Next
		pCompilers->Clear
		Dim As UString tempStr
		For i As Integer = 0 To .lvCompilerPaths.ListItems.Count - 1
			tempStr = .lvCompilerPaths.ListItems.Item(i)->Text(0)
			Tool = New_(ToolType)
			Tool->Name = tempStr
			Tool->Path = .lvCompilerPaths.ListItems.Item(i)->Text(1)
			Tool->Parameters = .lvCompilerPaths.ListItems.Item(i)->Text(2)
			pCompilers->Add tempStr, .lvCompilerPaths.ListItems.Item(i)->Text(1), Tool
		Next
		If *DefaultCompiler32 <> IIf(.cboCompiler32.ItemIndex = 0, "", .cboCompiler32.Text) OrElse Not pCompilers->ContainsKey(*CurrentCompiler32) Then
			WLet(DefaultCompiler32, IIf(.cboCompiler32.ItemIndex = 0, "", .cboCompiler32.Text))
			WLet(CurrentCompiler32, *DefaultCompiler32)
		End If
		If *DefaultCompiler64 <> IIf(.cboCompiler64.ItemIndex = 0, "", .cboCompiler64.Text) OrElse Not pCompilers->ContainsKey(*CurrentCompiler64) Then
			WLet(DefaultCompiler64, IIf(.cboCompiler64.ItemIndex = 0, "", .cboCompiler64.Text))
			WLet(CurrentCompiler64, *DefaultCompiler64)
		End If
		WLet(Compiler32Path, pCompilers->Get(*CurrentCompiler32))
		WLet(Compiler64Path, pCompilers->Get(*CurrentCompiler64))
		For i As Integer = 0 To pMakeTools->Count - 1
			Delete_(Cast(ToolType Ptr, pMakeTools->Item(i)->Object))
		Next
		pMakeTools->Clear
		For i As Integer = 0 To .lvMakeToolPaths.ListItems.Count - 1
			tempStr = .lvMakeToolPaths.ListItems.Item(i)->Text(0)
			Tool = New_(ToolType)
			Tool->Name = tempStr
			Tool->Path = .lvMakeToolPaths.ListItems.Item(i)->Text(1)
			Tool->Parameters = .lvMakeToolPaths.ListItems.Item(i)->Text(2)
			pMakeTools->Add tempStr, .lvMakeToolPaths.ListItems.Item(i)->Text(1), Tool
		Next
		If CInt(*DefaultMakeTool <> IIf(.cboMakeTool.ItemIndex = 0, "", .cboMakeTool.Text)) OrElse CInt(Not pMakeTools->ContainsKey(*CurrentMakeTool1)) OrElse CInt(Not pMakeTools->ContainsKey(*CurrentMakeTool2)) Then
			WLet(DefaultMakeTool, IIf(.cboMakeTool.ItemIndex = 0, "", .cboMakeTool.Text))
			WLet(CurrentMakeTool1, *DefaultMakeTool)
			WLet(CurrentMakeTool2, *DefaultMakeTool)
		End If
		WLet(MakeToolPath1, pMakeTools->Get(*CurrentMakeTool1))
		WLet(MakeToolPath2, pMakeTools->Get(*CurrentMakeTool2))
		For i As Integer = 0 To pDebuggers->Count - 1
			Delete_(Cast(ToolType Ptr, pDebuggers->Item(i)->Object))
		Next
		pDebuggers->Clear
		For i As Integer = 0 To .lvDebuggerPaths.ListItems.Count - 1
			tempStr = .lvDebuggerPaths.ListItems.Item(i)->Text(0)
			Tool = New_(ToolType)
			Tool->Name = tempStr
			Tool->Path = .lvDebuggerPaths.ListItems.Item(i)->Text(1)
			Tool->Parameters = .lvDebuggerPaths.ListItems.Item(i)->Text(2)
			pDebuggers->Add tempStr, .lvDebuggerPaths.ListItems.Item(i)->Text(1), Tool
		Next
		If *DefaultDebugger32 <> IIf(.cboDebugger32.ItemIndex = 0, "", .cboDebugger32.Text) OrElse Not pDebuggers->ContainsKey(*CurrentDebugger32) Then
			WLet(DefaultDebugger32, IIf(.cboDebugger32.ItemIndex = 0, "", .cboDebugger32.Text))
			WLet(CurrentDebugger32, *DefaultDebugger32)
		End If
		If *DefaultDebugger64 <> IIf(.cboDebugger64.ItemIndex = 0, "", .cboDebugger64.Text) OrElse Not pDebuggers->ContainsKey(*CurrentDebugger64) Then
			WLet(DefaultDebugger64, IIf(.cboDebugger64.ItemIndex = 0, "", .cboDebugger64.Text))
			WLet(CurrentDebugger64, *DefaultDebugger64)
		End If
		WLet(Debugger32Path, pDebuggers->Get(*CurrentDebugger32))
		WLet(Debugger64Path, pDebuggers->Get(*CurrentDebugger64))
		WLet(GDBDebugger32, .cboGDBDebugger32.Text)
		WLet(GDBDebugger64, .cboGDBDebugger64.Text)
		WLet(GDBDebugger32Path, pDebuggers->Get(*GDBDebugger32))
		WLet(GDBDebugger64Path, pDebuggers->Get(*GDBDebugger64))
		For i As Integer = 0 To pTerminals->Count - 1
			Delete_(Cast(ToolType Ptr, pTerminals->Item(i)->Object))
		Next
		pTerminals->Clear
		For i As Integer = 0 To .lvTerminalPaths.ListItems.Count - 1
			tempStr = .lvTerminalPaths.ListItems.Item(i)->Text(0)
			Tool = New_(ToolType)
			Tool->Name = tempStr
			Tool->Path = .lvTerminalPaths.ListItems.Item(i)->Text(1)
			Tool->Parameters = .lvTerminalPaths.ListItems.Item(i)->Text(2)
			pTerminals->Add tempStr, .lvTerminalPaths.ListItems.Item(i)->Text(1), Tool
		Next
		If *DefaultTerminal <> IIf(.cboTerminal.ItemIndex = 0, "", .cboTerminal.Text) OrElse Not pTerminals->ContainsKey(*CurrentTerminal) Then
			WLet(DefaultTerminal, IIf(.cboTerminal.ItemIndex = 0, "", .cboTerminal.Text))
			WLet(CurrentTerminal, *DefaultTerminal)
		End If
		WLet(TerminalPath, pTerminals->Get(*CurrentTerminal))
		For i As Integer = 0 To pOtherEditors->Count - 1
			Delete_(Cast(ToolType Ptr, pOtherEditors->Item(i)->Object))
		Next
		pOtherEditors->Clear
		For i As Integer = 0 To .lvOtherEditors.ListItems.Count - 1
			tempStr = .lvOtherEditors.ListItems.Item(i)->Text(0)
			Tool = New_(ToolType)
			Tool->Name = tempStr
			Tool->Extensions = .lvOtherEditors.ListItems.Item(i)->Text(1)
			Tool->Path = .lvOtherEditors.ListItems.Item(i)->Text(2)
			Tool->Parameters = .lvOtherEditors.ListItems.Item(i)->Text(3)
			pOtherEditors->Add tempStr, .lvOtherEditors.ListItems.Item(i)->Text(2), Tool
		Next
		pHelps->Clear
		miHelps->Clear
		For i As Integer = 0 To .lvHelpPaths.ListItems.Count - 1
			tempStr = .lvHelpPaths.ListItems.Item(i)->Text(0)
			pHelps->Add tempStr, .lvHelpPaths.ListItems.Item(i)->Text(1)
			miHelps->Add(tempStr, .lvHelpPaths.ListItems.Item(i)->Text(1), , @mClickHelp)
		Next
		WLet(DefaultHelp, IIf(.cboHelp.ItemIndex = 0, "", .cboHelp.Text))
		WLet(HelpPath, pHelps->Get(*DefaultHelp))
		pIncludePaths->Clear
		For i As Integer = 0 To .lstIncludePaths.ItemCount - 1
			pIncludePaths->Add .lstIncludePaths.Item(i)
		Next
		pLibraryPaths->Clear
		For i As Integer = 0 To .lstLibraryPaths.ItemCount - 1
			pLibraryPaths->Add .lstLibraryPaths.Item(i)
		Next
		IncludeMFFPath = .chkIncludeMFFPath.Checked
		WLet(MFFPath, .txtMFFPath.Text)
		WLet(ProjectsPath, .txtProjectsPath.Text)
		#ifdef __FB_64BIT__
			WLet(MFFDll, *MFFPath & "/mff64.dll")
		#else
			WLet(MFFDll, *MFFPath & "/mff32.dll")
		#endif
		TabWidth = Val(.txtTabSize.Text)
		HistoryLimit = Val(.txtHistoryLimit.Text)
		IntellisenseLimit = Val(.txtIntellisenseLimit.Text)
		UseMakeOnStartWithCompile = .chkUseMakeOnStartWithCompile.Checked
		LimitDebug = .chkLimitDebug.Checked
		DisplayWarningsInDebug = .chkDisplayWarningsInDebug.Checked
		TurnOnEnvironmentVariables = .chkTurnOnEnvironmentVariables.Checked
		WLet(EnvironmentVariables, .txtEnvironmentVariables.Text)
		AutoIncrement = .CheckBox1.Checked
		AutoIndentation = .chkAutoIndentation.Checked
		AutoComplete = .chkEnableAutoComplete.Checked
		AutoCreateRC = .chkAutoCreateRC.Checked
		AutoCreateBakFiles = .chkAutoCreateBakFiles.Checked
		AddRelativePathsToRecent = .chkAddRelativePathsToRecent.Checked
		CreateNonStaticEventHandlers = .chkCreateNonStaticEventHandlers.Checked
		PlaceStaticEventHandlersAfterTheConstructor = .chkPlaceStaticEventHandlersAfterTheConstructor.Checked
		CreateStaticEventHandlersWithAnUnderscoreAtTheBeginning = .chkCreateStaticEventHandlersWithAnUnderscoreAtTheBeginning.Checked
		CreateFormTypesWithoutTypeWord = .chkCreateFormTypesWithoutTypeWord.Checked
		OpenCommandPromptInMainFileFolder = .optMainFileFolder.Checked
		WLet(CommandPromptFolder, .txtInFolder.Text)
		If .cboDefaultProjectFile.ItemIndex = -1 Then
			WLet(DefaultProjectFile, "")
		Else
			WLet(DefaultProjectFile, .Templates.Item(.cboDefaultProjectFile.ItemIndex))
		End If
		LastOpenedFileType = .cboOpenedFile.ItemIndex
		WhenVisualFBEditorStarts = IIf(.optPromptForProjectAndFile.Checked, 1, IIf(.optCreateProjectFile.Checked, 2, IIf(.optOpenLastSession.Checked, 3, 0)))
		AutoSaveBeforeCompiling = IIf(.optSaveCurrentFile.Checked, 1, IIf(.optSaveAllFiles.Checked, 2, IIf(.optPromptToSave.Checked, 3, 0)))
		ShowSpaces = .chkShowSpaces.Checked
		ShowKeywordsToolTip = .chkShowKeywordsTooltip.Checked
		HighlightBrackets = .chkHighlightBrackets.Checked
		HighlightCurrentLine = .chkHighlightCurrentLine.Checked
		HighlightCurrentWord = .chkHighlightCurrentWord.Checked
		TabAsSpaces = .chkTabAsSpaces.Checked
		ChoosedTabStyle = .cboTabStyle.ItemIndex
		GridSize = Val(.txtGridSize.Text)
		ShowAlignmentGrid = .chkShowAlignmentGrid.Checked
		SnapToGridOption = .chkSnapToGrid.Checked
		ChangeKeywordsCase = .chkChangeKeywordsCase.Checked
		ChoosedKeywordsCase = .cboCase.ItemIndex
		AddSpacesToOperators = .chkAddSpacesToOperators.Checked
		WLet(CurrentTheme, .cboTheme.Text)
		WLet(EditorFontName, *.EditFontName)
		EditorFontSize = .EditFontSize
		WLet(InterfaceFontName, *.InterfFontName)
		InterfaceFontSize = .InterfFontSize
		DisplayMenuIcons = .chkDisplayIcons.Checked
		ShowMainToolbar = .chkShowMainToolbar.Checked
		DarkMode = .chkDarkMode.Checked
		SetColors
		If .HotKeysChanged Then
			Dim As Integer Pos1, Fn = FreeFile_
			Dim As MenuItem Ptr Item
			Dim As String Key
			Open ExePath & "/Settings/Others/HotKeys.txt" For Output As #Fn
			For i As Integer = 0 To .lvShortcuts.ListItems.Count - 1
				If .HotKeysPriv.Item(i) = "" Then Continue For
				Item = .lvShortcuts.ListItems.Item(i)->Tag
				Pos1 = InStr(Item->Caption, !"\t")
				If Pos1 = 0 Then Pos1 = Len(Item->Caption) + 1
				Key = .lvShortcuts.ListItems.Item(i)->Text(1)
				Item->Caption = ..Left(Item->Caption, Pos1 - 1) & !"\t" & Key
				Print #Fn, .HotKeysPriv.Item(i) & "=" & Key
			Next
			CloseFile_(Fn)
			pfrmMain->Menu->ParentWindow = pfrmMain
		End If
		piniSettings->WriteString "Compilers", "DefaultCompiler32", *DefaultCompiler32
		piniSettings->WriteString "Compilers", "DefaultCompiler64", *DefaultCompiler64
		Dim i As Integer = 0
		For i As Integer = 0 To pCompilers->Count - 1
			piniSettings->WriteString "Compilers", "Version_" & WStr(i), pCompilers->Item(i)->Key
			piniSettings->WriteString "Compilers", "Path_" & WStr(i), pCompilers->Item(i)->Text
			piniSettings->WriteString "Compilers", "Command_" & WStr(i), Cast(ToolType Ptr, pCompilers->Item(i)->Object)->Parameters
		Next
		i = pCompilers->Count
		Do Until piniSettings->KeyExists("Compilers", "Version_" & WStr(i)) = -1
			piniSettings->KeyRemove "Compilers", "Version_" & WStr(i)
			piniSettings->KeyRemove "Compilers", "Path_" & WStr(i)
			piniSettings->KeyRemove "Compilers", "Command_" & WStr(i)
			i += 1
		Loop
		piniSettings->WriteString "MakeTools", "DefaultMakeTool", *DefaultMakeTool
		For i As Integer = 0 To pMakeTools->Count - 1
			piniSettings->WriteString "MakeTools", "Version_" & WStr(i), pMakeTools->Item(i)->Key
			piniSettings->WriteString "MakeTools", "Path_" & WStr(i), pMakeTools->Item(i)->Text
			piniSettings->WriteString "MakeTools", "Command_" & WStr(i), Cast(ToolType Ptr, pMakeTools->Item(i)->Object)->Parameters
		Next
		i = pMakeTools->Count
		Do Until piniSettings->KeyExists("MakeTools", "Version_" & WStr(i)) = -1
			piniSettings->KeyRemove "MakeTools", "Version_" & WStr(i)
			piniSettings->KeyRemove "MakeTools", "Path_" & WStr(i)
			piniSettings->KeyRemove "MakeTools", "Command_" & WStr(i)
			i += 1
		Loop
		piniSettings->WriteString "Debuggers", "DefaultDebugger32", *DefaultDebugger32
		piniSettings->WriteString "Debuggers", "DefaultDebugger64", *DefaultDebugger64
		piniSettings->WriteString "Debuggers", "GDBDebugger32", *GDBDebugger32
		piniSettings->WriteString "Debuggers", "GDBDebugger64", *GDBDebugger64
		For i As Integer = 0 To pDebuggers->Count - 1
			piniSettings->WriteString "Debuggers", "Version_" & WStr(i), pDebuggers->Item(i)->Key
			piniSettings->WriteString "Debuggers", "Path_" & WStr(i), pDebuggers->Item(i)->Text
			piniSettings->WriteString "Debuggers", "Command_" & WStr(i), Cast(ToolType Ptr, pDebuggers->Item(i)->Object)->Parameters
		Next
		i = pDebuggers->Count
		Do Until piniSettings->KeyExists("Debuggers", "Version_" & WStr(i)) = -1
			piniSettings->KeyRemove "Debuggers", "Version_" & WStr(i)
			piniSettings->KeyRemove "Debuggers", "Path_" & WStr(i)
			piniSettings->KeyRemove "Debuggers", "Command_" & WStr(i)
			i += 1
		Loop
		piniSettings->WriteString "Terminals", "DefaultTerminal", *DefaultTerminal
		For i As Integer = 0 To pTerminals->Count - 1
			piniSettings->WriteString "Terminals", "Version_" & WStr(i), pTerminals->Item(i)->Key
			piniSettings->WriteString "Terminals", "Path_" & WStr(i), pTerminals->Item(i)->Text
			piniSettings->WriteString "Terminals", "Command_" & WStr(i), Cast(ToolType Ptr, pTerminals->Item(i)->Object)->Parameters
		Next
		i = pTerminals->Count
		Do Until piniSettings->KeyExists("Terminals", "Version_" & WStr(i)) = -1
			piniSettings->KeyRemove "Terminals", "Version_" & WStr(i)
			piniSettings->KeyRemove "Terminals", "Path_" & WStr(i)
			piniSettings->KeyRemove "Terminals", "Command_" & WStr(i)
			i += 1
		Loop
		For i As Integer = 0 To pOtherEditors->Count - 1
			piniSettings->WriteString "OtherEditors", "Version_" & WStr(i), pOtherEditors->Item(i)->Key
			piniSettings->WriteString "OtherEditors", "Extensions_" & WStr(i), Cast(ToolType Ptr, pOtherEditors->Item(i)->Object)->Extensions
			piniSettings->WriteString "OtherEditors", "Path_" & WStr(i), pOtherEditors->Item(i)->Text
			piniSettings->WriteString "OtherEditors", "Command_" & WStr(i), Cast(ToolType Ptr, pOtherEditors->Item(i)->Object)->Parameters
		Next
		Do Until piniSettings->KeyExists("OtherEditors", "Version_" & WStr(i)) = -1
			piniSettings->KeyRemove "OtherEditors", "Version_" & WStr(i)
			piniSettings->KeyRemove "OtherEditors", "Extensions_" & WStr(i)
			piniSettings->KeyRemove "OtherEditors", "Path_" & WStr(i)
			piniSettings->KeyRemove "OtherEditors", "Command_" & WStr(i)
			i += 1
		Loop
		piniSettings->WriteString "Helps", "DefaultHelp", *DefaultHelp
		For i As Integer = 0 To pHelps->Count - 1
			piniSettings->WriteString "Helps", "Version_" & WStr(i), pHelps->Item(i)->Key
			piniSettings->WriteString "Helps", "Path_" & WStr(i), pHelps->Item(i)->Text
		Next
		i = pHelps->Count
		Do Until piniSettings->KeyExists("Helps", "Version_" & WStr(i)) = -1
			piniSettings->KeyRemove "Helps", "Version_" & WStr(i)
			piniSettings->KeyRemove "Helps", "Path_" & WStr(i)
			i += 1
		Loop
		For i As Integer = 0 To pIncludePaths->Count - 1
			piniSettings->WriteString "IncludePaths", "Path_" & WStr(i), pIncludePaths->Item(i)
		Next
		i = pIncludePaths->Count
		Do Until piniSettings->KeyExists("IncludePaths", "Path_" & WStr(i)) = -1
			piniSettings->KeyRemove "IncludePaths", "Path_" & WStr(i)
			i += 1
		Loop
		For i As Integer = 0 To pLibraryPaths->Count - 1
			piniSettings->WriteString "LibraryPaths", "Path_" & WStr(i), pLibraryPaths->Item(i)
		Next
		i = pLibraryPaths->Count
		Do Until piniSettings->KeyExists("LibraryPaths", "Path_" & WStr(i)) = -1
			piniSettings->KeyRemove "LibraryPaths", "Path_" & WStr(i)
			i += 1
		Loop
		piniSettings->WriteBool "Options", "IncludeMFFPath", IncludeMFFPath
		piniSettings->WriteString "Options", "MFFPath", *MFFPath
		piniSettings->WriteString "Options", "ProjectsPath", *ProjectsPath
		piniSettings->WriteString "Options", "Language", Languages.Item(.cboLanguage.ItemIndex)
		piniSettings->WriteInteger "Options", "TabWidth", TabWidth
		piniSettings->WriteInteger "Options", "HistoryLimit", HistoryLimit
		piniSettings->WriteInteger "Options", "IntellisenseLimit", IntellisenseLimit
		piniSettings->WriteBool "Options", "UseMakeOnStartWithCompile", UseMakeOnStartWithCompile
		piniSettings->WriteBool "Options", "LimitDebug", LimitDebug
		piniSettings->WriteBool "Options", "DisplayWarningsInDebug", DisplayWarningsInDebug
		piniSettings->WriteBool "Options", "TurnOnEnvironmentVariables", TurnOnEnvironmentVariables
		piniSettings->WriteString "Options", "EnvironmentVariables", *EnvironmentVariables
		piniSettings->WriteBool "Options", "AutoIncrement", AutoIncrement
		piniSettings->WriteBool "Options", "AutoIndentation", AutoIndentation
		piniSettings->WriteBool "Options", "AutoComplete", AutoComplete
		piniSettings->WriteBool "Options", "AutoCreateRC", AutoCreateRC
		piniSettings->WriteBool "Options", "AutoCreateBakFiles", AutoCreateBakFiles
		piniSettings->WriteBool "Options", "AddRelativePathsToRecent", AddRelativePathsToRecent
		piniSettings->WriteString "Options", "DefaultProjectFile", WGet(DefaultProjectFile)
		piniSettings->WriteInteger "Options", "LastOpenedFileType", LastOpenedFileType
		piniSettings->WriteInteger "Options", "WhenVisualFBEditorStarts", WhenVisualFBEditorStarts
		piniSettings->WriteInteger "Options", "AutoSaveBeforeCompiling", AutoSaveBeforeCompiling
		piniSettings->WriteBool "Options", "ShowSpaces", ShowSpaces
		piniSettings->WriteBool "Options", "ShowKeywordsTooltip", ShowKeywordsTooltip
		piniSettings->WriteBool "Options", "HighlightBrackets", HighlightBrackets
		piniSettings->WriteBool "Options", "HighlightCurrentLine", HighlightCurrentLine
		piniSettings->WriteBool "Options", "HighlightCurrentWord", HighlightCurrentWord
		piniSettings->WriteBool "Options", "TabAsSpaces", TabAsSpaces
		piniSettings->WriteInteger "Options", "GridSize", GridSize
		piniSettings->WriteBool "Options", "ShowAlignmentGrid", ShowAlignmentGrid
		piniSettings->WriteBool "Options", "SnapToGrid", SnapToGridOption
		piniSettings->WriteBool "Options", "CreateNonStaticEventHandlers", CreateNonStaticEventHandlers
		piniSettings->WriteBool "Options", "PlaceStaticEventHandlersAfterTheConstructor", PlaceStaticEventHandlersAfterTheConstructor
		piniSettings->WriteBool "Options", "CreateStaticEventHandlersWithAnUnderscoreAtTheBeginning", CreateStaticEventHandlersWithAnUnderscoreAtTheBeginning
		piniSettings->WriteBool "Options", "CreateFormTypesWithoutTypeWord", CreateFormTypesWithoutTypeWord
		piniSettings->WriteBool "Options", "OpenCommandPromptInMainFileFolder", OpenCommandPromptInMainFileFolder
		piniSettings->WriteString "Options", "CommandPromptFolder", *CommandPromptFolder
		piniSettings->WriteBool "Options", "ChangeKeywordsCase", ChangeKeywordsCase
		piniSettings->WriteInteger "Options", "ChoosedKeywordsCase", ChoosedKeywordsCase
		piniSettings->WriteBool "Options", "AddSpacesToOperators", AddSpacesToOperators
		
		piniSettings->WriteString "Options", "CurrentTheme", *CurrentTheme
		
		piniSettings->WriteString "Options", "EditorFontName", *EditorFontName
		piniSettings->WriteInteger "Options", "EditorFontSize", EditorFontSize
		piniSettings->WriteString "Options", "InterfaceFontName", *InterfaceFontName
		piniSettings->WriteInteger "Options", "InterfaceFontSize", InterfaceFontSize
		piniSettings->WriteBool "Options", "DisplayMenuIcons", DisplayMenuIcons
		piniSettings->WriteBool "Options", "ShowMainToolbar", ShowMainToolbar
		piniSettings->WriteBool "Options", "DarkMode", DarkMode
		pfrmMain->Menu->ImagesList = IIf(DisplayMenuIcons, pimgList, 0)
		ReBar1.Visible = ShowMainToolbar
		pfrmMain->RequestAlign
		SetDarkMode DarkMode, False
		#ifdef __USE_WINAPI__
			If DarkMode Then
				txtLabelProperty.BackColor = GetSysColor(COLOR_WINDOW)
				txtLabelEvent.BackColor = GetSysColor(COLOR_WINDOW)
				fAddIns.txtDescription.BackColor = GetSysColor(COLOR_WINDOW)
			Else
				txtLabelProperty.BackColor = clBtnFace
				txtLabelEvent.BackColor = clBtnFace
				fAddIns.txtDescription.BackColor = clBtnFace
			End If
			For i As Integer = 0 To pApp->FormCount - 1
				If pApp->Forms[i]->Handle Then
					AllowDarkModeForWindow pApp->Forms[i]->Handle, DarkMode
					RefreshTitleBarThemeColor(pApp->Forms[i]->Handle)
					RedrawWindow pApp->Forms[i]->Handle, 0, 0, RDW_INVALIDATE Or RDW_ALLCHILDREN
				End If
			Next i
		#endif
		
		piniTheme->Load ExePath & "/Settings/Themes/" & *CurrentTheme & ".ini"
		piniTheme->WriteInteger("Colors", "BookmarksForeground", Bookmarks.ForegroundOption)
		piniTheme->WriteInteger("Colors", "BookmarksBackground", Bookmarks.BackgroundOption)
		piniTheme->WriteInteger("Colors", "BookmarksFrame", Bookmarks.FrameOption)
		piniTheme->WriteInteger("Colors", "BookmarksIndicator", Bookmarks.IndicatorOption)
		piniTheme->WriteInteger("FontStyles", "BookmarksBold", Bookmarks.Bold)
		piniTheme->WriteInteger("FontStyles", "BookmarksItalic", Bookmarks.Italic)
		piniTheme->WriteInteger("FontStyles", "BookmarksUnderline", Bookmarks.Underline)
		piniTheme->WriteInteger("Colors", "BreakpointsForeground", Breakpoints.ForegroundOption)
		piniTheme->WriteInteger("Colors", "BreakpointsBackground", Breakpoints.BackgroundOption)
		piniTheme->WriteInteger("Colors", "BreakpointsFrame", Breakpoints.FrameOption)
		piniTheme->WriteInteger("Colors", "BreakpointsIndicator", Breakpoints.IndicatorOption)
		piniTheme->WriteInteger("FontStyles", "BreakpointsBold", Breakpoints.Bold)
		piniTheme->WriteInteger("FontStyles", "BreakpointsItalic", Breakpoints.Italic)
		piniTheme->WriteInteger("FontStyles", "BreakpointsUnderline", Breakpoints.Underline)
		piniTheme->WriteInteger("Colors", "CommentsForeground", Comments.ForegroundOption)
		piniTheme->WriteInteger("Colors", "CommentsBackground", Comments.BackgroundOption)
		piniTheme->WriteInteger("Colors", "CommentsFrame", Comments.FrameOption)
		piniTheme->WriteInteger("FontStyles", "CommentsBold", Comments.Bold)
		piniTheme->WriteInteger("FontStyles", "CommentsItalic", Comments.Italic)
		piniTheme->WriteInteger("FontStyles", "CommentsUnderline", Comments.Underline)
		piniTheme->WriteInteger("Colors", "CurrentBracketsForeground", CurrentBrackets.ForegroundOption)
		piniTheme->WriteInteger("Colors", "CurrentBracketsBackground", CurrentBrackets.BackgroundOption)
		piniTheme->WriteInteger("Colors", "CurrentBracketsFrame", CurrentBrackets.FrameOption)
		piniTheme->WriteInteger("FontStyles", "CurrentBracketsBold", CurrentBrackets.Bold)
		piniTheme->WriteInteger("FontStyles", "CurrentBracketsItalic", CurrentBrackets.Italic)
		piniTheme->WriteInteger("FontStyles", "CurrentBracketsUnderline", CurrentBrackets.Underline)
		piniTheme->WriteInteger("Colors", "CurrentLineForeground", CurrentLine.ForegroundOption)
		piniTheme->WriteInteger("Colors", "CurrentLineBackground", CurrentLine.BackgroundOption)
		piniTheme->WriteInteger("Colors", "CurrentLineFrame", CurrentLine.FrameOption)
		piniTheme->WriteInteger("Colors", "CurrentWordForeground", CurrentWord.ForegroundOption)
		piniTheme->WriteInteger("Colors", "CurrentWordBackground", CurrentWord.BackgroundOption)
		piniTheme->WriteInteger("Colors", "CurrentWordFrame", CurrentWord.FrameOption)
		piniTheme->WriteInteger("FontStyles", "CurrentWordBold", CurrentWord.Bold)
		piniTheme->WriteInteger("FontStyles", "CurrentWordItalic", CurrentWord.Italic)
		piniTheme->WriteInteger("FontStyles", "CurrentWordUnderline", CurrentWord.Underline)
		piniTheme->WriteInteger("Colors", "ExecutionLineForeground", ExecutionLine.ForegroundOption)
		piniTheme->WriteInteger("Colors", "ExecutionLineBackground", ExecutionLine.BackgroundOption)
		piniTheme->WriteInteger("Colors", "ExecutionLineFrame", ExecutionLine.FrameOption)
		piniTheme->WriteInteger("Colors", "ExecutionLineIndicator", ExecutionLine.IndicatorOption)
		piniTheme->WriteInteger("Colors", "FoldLinesForeground", FoldLines.ForegroundOption)
		piniTheme->WriteInteger("Colors", "IdentifiersForeground", Identifiers.ForegroundOption)
		piniTheme->WriteInteger("Colors", "IdentifiersBackground", Identifiers.BackgroundOption)
		piniTheme->WriteInteger("Colors", "IdentifiersFrame", Identifiers.FrameOption)
		piniTheme->WriteInteger("FontStyles", "IdentifiersBold", Identifiers.Bold)
		piniTheme->WriteInteger("FontStyles", "IdentifiersItalic", Identifiers.Italic)
		piniTheme->WriteInteger("FontStyles", "IdentifiersUnderline", Identifiers.Underline)
		piniTheme->WriteInteger("Colors", "IndicatorLinesForeground", IndicatorLines.ForegroundOption)
		For k As Integer = 0 To UBound(Keywords)
			piniTheme->WriteInteger("Colors", Replace(KeywordLists.Item(k), " ", "") & "Foreground", Keywords(k).ForegroundOption)
			piniTheme->WriteInteger("Colors", Replace(KeywordLists.Item(k), " ", "") & "Background", Keywords(k).BackgroundOption)
			piniTheme->WriteInteger("Colors", Replace(KeywordLists.Item(k), " ", "") & "Frame", Keywords(k).FrameOption)
			piniTheme->WriteInteger("FontStyles", Replace(KeywordLists.Item(k), " ", "") & "Bold", Keywords(k).Bold)
			piniTheme->WriteInteger("FontStyles", Replace(KeywordLists.Item(k), " ", "") & "Italic", Keywords(k).Italic)
			piniTheme->WriteInteger("FontStyles", Replace(KeywordLists.Item(k), " ", "") & "Underline", Keywords(k).Underline)
		Next k
		piniTheme->WriteInteger("Colors", "LineNumbersForeground", LineNumbers.ForegroundOption)
		piniTheme->WriteInteger("Colors", "LineNumbersBackground", LineNumbers.BackgroundOption)
		piniTheme->WriteInteger("FontStyles", "LineNumbersBold", LineNumbers.Bold)
		piniTheme->WriteInteger("FontStyles", "LineNumbersItalic", LineNumbers.Italic)
		piniTheme->WriteInteger("FontStyles", "LineNumbersUnderline", LineNumbers.Underline)
		piniTheme->WriteInteger("Colors", "NormalTextForeground", NormalText.ForegroundOption)
		piniTheme->WriteInteger("Colors", "NormalTextBackground", NormalText.BackgroundOption)
		piniTheme->WriteInteger("Colors", "NormalTextFrame", NormalText.FrameOption)
		piniTheme->WriteInteger("FontStyles", "NormalTextBold", NormalText.Bold)
		piniTheme->WriteInteger("FontStyles", "NormalTextItalic", NormalText.Italic)
		piniTheme->WriteInteger("FontStyles", "NormalTextUnderline", NormalText.Underline)
'		piniTheme->WriteInteger("Colors", "PreprocessorsForeground", Preprocessors.ForegroundOption)
'		piniTheme->WriteInteger("Colors", "PreprocessorsBackground", Preprocessors.BackgroundOption)
'		piniTheme->WriteInteger("Colors", "PreprocessorsFrame", Preprocessors.FrameOption)
'		piniTheme->WriteInteger("FontStyles", "PreprocessorsBold", Preprocessors.Bold)
'		piniTheme->WriteInteger("FontStyles", "PreprocessorsItalic", Preprocessors.Italic)
'		piniTheme->WriteInteger("FontStyles", "PreprocessorsUnderline", Preprocessors.Underline)
		piniTheme->WriteInteger("Colors", "NumbersForeground", Numbers.ForegroundOption)
		piniTheme->WriteInteger("Colors", "NumbersBackground", Numbers.BackgroundOption)
		piniTheme->WriteInteger("Colors", "NumbersFrame", Numbers.FrameOption)
		piniTheme->WriteInteger("FontStyles", "NumbersBold", Numbers.Bold)
		piniTheme->WriteInteger("FontStyles", "NumbersItalic", Numbers.Italic)
		piniTheme->WriteInteger("FontStyles", "NumbersUnderline", Numbers.Underline)
		piniTheme->WriteInteger("Colors", "RealNumbersForeground", RealNumbers.ForegroundOption)
		piniTheme->WriteInteger("Colors", "RealNumbersBackground", RealNumbers.BackgroundOption)
		piniTheme->WriteInteger("Colors", "RealNumbersFrame", RealNumbers.FrameOption)
		piniTheme->WriteInteger("FontStyles", "RealNumbersBold", RealNumbers.Bold)
		piniTheme->WriteInteger("FontStyles", "RealNumbersItalic", RealNumbers.Italic)
		piniTheme->WriteInteger("FontStyles", "RealNumbersUnderline", RealNumbers.Underline)
'		piniTheme->WriteInteger("Colors", "SelectionForeground", Selection.ForegroundOption)
		piniTheme->WriteInteger("Colors", "SelectionBackground", Selection.BackgroundOption)
		piniTheme->WriteInteger("Colors", "SelectionFrame", Selection.FrameOption)
		piniTheme->WriteInteger("Colors", "SpaceIdentifiersForeground", SpaceIdentifiers.ForegroundOption)
		piniTheme->WriteInteger("Colors", "StringsForeground", Strings.ForegroundOption)
		piniTheme->WriteInteger("Colors", "StringsBackground", Strings.BackgroundOption)
		piniTheme->WriteInteger("Colors", "StringsFrame", Strings.FrameOption)
		piniTheme->WriteInteger("FontStyles", "StringsBold", Strings.Bold)
		piniTheme->WriteInteger("FontStyles", "StringsItalic", Strings.Italic)
		piniTheme->WriteInteger("FontStyles", "StringsUnderline", Strings.Underline)
		
		Dim As TabWindow Ptr tb
		For i As Integer = 0 To ptabCode->TabCount - 1
			tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
			tb->txtCode.Font.Name = *EditorFontName
			tb->txtCode.Font.Size = EditorFontSize
		Next
		newIndex = .cboLanguage.ItemIndex
	End With
	Exit Sub
	ErrorHandler:
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " " & _
	"in function " & ZGet(Erfn()) & " " & _
	"in module " & ZGet(Ermn())
End Sub

Private Sub frmOptions.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	If newIndex <> oldIndex Then MsgBox ML("Localization changes will be applied the next time the application is run.")
	If *InterfaceFontName <> *fOptions.oldInterfFontName OrElse InterfaceFontSize <> fOptions.oldInterfFontSize Then MsgBox ML("Interface font changes will be applied the next time the application is run.")
	If DisplayMenuIcons <> fOptions.oldDisplayMenuIcons Then MsgBox ML("Display icons in the menu changes will be applied the next time the application is run.")
	'If DarkMode <> fOptions.oldDarkMode Then MsgBox ML("Dark Mode changes will be applied the next time the application is run.")
	'If fOptions.HotKeysChanged Then MsgBox ML("Hotkey changes will be applied the next time the application is run.")
End Sub

Private Sub frmOptions.Form_Show(ByRef Sender As Form)
	With fOptions
		.LoadSettings
		cboDefaultProjectFileCheckEnable
	End With
End Sub

Private Sub frmOptions.TreeView1_SelChange(ByRef Sender As TreeView, ByRef Item As TreeNode)
	With fOptions
		If .FDisposing Then Exit Sub
		Dim Key As String = Item.Name
		.pnlGeneral.Visible = Key = "General"
		.pnlCodeEditor.Visible = Key = "CodeEditor"
		.pnlShortcuts.Visible = Key = "Shortcuts"
		.pnlThemes.Visible = Key = "Themes"
		.pnlColorsAndFonts.Visible = Key = "ColorsAndFonts"
		.pnlCompiler.Visible = Key = "Compiler"
		.pnlMake.Visible = Key = "MakeTool"
		.pnlDebugger.Visible = Key = "Debugger"
		.pnlTerminal.Visible = Key = "Terminal"
		.pnlDesigner.Visible = Key = "Designer"
		.pnlIncludes.Visible = Key = "Includes"
		.pnlLocalization.Visible = Key = "Localization"
		.pnlOtherEditors.Visible = Key = "OtherEditors"
		.pnlHelp.Visible = Key = "Help"
	End With
End Sub

Private Sub frmOptions.pnlIncludes_ActiveControlChange(ByRef Sender As Control)
	
End Sub

Private Sub frmOptions.cmdMFFPath_Click(ByRef Sender As Control)
	With fOptions
		.BrowsD.InitialDir = GetFullPath(.txtMFFPath.Text)
		If .BrowsD.Execute Then
			.txtMFFPath.Text = .BrowsD.Directory
		End If
	End With
End Sub

Private Sub frmOptions.cmdFont_Click(ByRef Sender As Control)
	With fOptions
		.FontD.Font.Name = *.EditFontName
		.FontD.Font.Size = .EditFontSize
		If .FontD.Execute Then
			WLet(.EditFontName, .FontD.Font.Name)
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
		If UBound(.Colors, 1) < 0 Then Exit Sub
		.lblColorForeground.BackColor = Max(0, .Colors(i, 0))
		.chkForeground.Checked = .Colors(i, 0) = -1
		
		.lblColorBackground.BackColor = Max(0, .Colors(i, 1))
		.lblColorBackground.Visible = .Colors(i, 1) <> -2
		.lblBackground.Visible = .Colors(i, 1) <> -2
		.cmdBackground.Visible = .Colors(i, 1) <> -2
		.chkBackground.Visible = .Colors(i, 1) <> -2
		.chkBackground.Checked = .Colors(i, 1) = -1
		
		.lblColorFrame.BackColor = Max(0, .Colors(i, 2))
		.lblColorFrame.Visible = .Colors(i, 2) <> -2
		.lblFrame.Visible = .Colors(i, 2) <> -2
		.cmdFrame.Visible = .Colors(i, 2) <> -2
		.chkFrame.Visible = .Colors(i, 2) <> -2
		.chkFrame.Checked = .Colors(i, 2) = -1
		
		.lblColorIndicator.BackColor = Max(0, .Colors(i, 3))
		.lblColorIndicator.Visible = .Colors(i, 3) <> -2
		.lblIndicator.Visible = .Colors(i, 3) <> -2
		.cmdIndicator.Visible = .Colors(i, 3) <> -2
		.chkIndicator.Visible = .Colors(i, 3) <> -2
		.chkIndicator.Checked = .Colors(i, 3) = -1
		
		.chkBold.Visible = .Colors(i, 4) <> -2
		.chkBold.Checked = .Colors(i, 4)
		.chkItalic.Visible = .Colors(i, 4) <> -2
		.chkItalic.Checked = .Colors(i, 5)
		.chkUnderline.Visible = .Colors(i, 4) <> -2
		.chkUnderline.Checked = .Colors(i, 6)
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

Private Sub frmOptions.cmdFrame_Click(ByRef Sender As Control)
	With fOptions.ColorD
		Var i = fOptions.lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Color = fOptions.Colors(i, 2)
		If .Execute Then
			fOptions.lblColorFrame.BackColor = .Color
			fOptions.chkFrame.Checked = False
			fOptions.Colors(i, 2) = .Color
		End If
	End With
End Sub

Private Sub frmOptions.cmdIndicator_Click(ByRef Sender As Control)
	With fOptions.ColorD
		Var i = fOptions.lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Color = fOptions.Colors(i, 3)
		If .Execute Then
			fOptions.lblColorIndicator.BackColor = .Color
			fOptions.chkIndicator.Checked = False
			fOptions.Colors(i, 3) = .Color
		End If
	End With
End Sub

Private Sub frmOptions.cboTheme_Change(ByRef Sender As Control)
	With fOptions
		piniTheme->Load ExePath & "/Settings/Themes/" & fOptions.cboTheme.Text & ".ini"
		.Colors(0, 0) = piniTheme->ReadInteger("Colors", "BookmarksForeground", -1)
		.Colors(0, 1) = piniTheme->ReadInteger("Colors", "BookmarksBackground", -1)
		.Colors(0, 2) = piniTheme->ReadInteger("Colors", "BookmarksFrame", -1)
		.Colors(0, 3) = piniTheme->ReadInteger("Colors", "BookmarksIndicator", -1)
		.Colors(0, 4) = piniTheme->ReadInteger("FontStyles", "BookmarksBold", 0)
		.Colors(0, 5) = piniTheme->ReadInteger("FontStyles", "BookmarksItalic", 0)
		.Colors(0, 6) = piniTheme->ReadInteger("FontStyles", "BookmarksUnderline", 0)
		.Colors(1, 0) = piniTheme->ReadInteger("Colors", "BreakpointsForeground", -1)
		.Colors(1, 1) = piniTheme->ReadInteger("Colors", "BreakpointsBackground", -1)
		.Colors(1, 2) = piniTheme->ReadInteger("Colors", "BreakpointsFrame", -1)
		.Colors(1, 3) = piniTheme->ReadInteger("Colors", "BreakpointsIndicator", -1)
		.Colors(1, 4) = piniTheme->ReadInteger("FontStyles", "BreakpointsBold", 0)
		.Colors(1, 5) = piniTheme->ReadInteger("FontStyles", "BreakpointsItalic", 0)
		.Colors(1, 6) = piniTheme->ReadInteger("FontStyles", "BreakpointsUnderline", 0)
		.Colors(2, 0) = piniTheme->ReadInteger("Colors", "CommentsForeground", -1)
		.Colors(2, 1) = piniTheme->ReadInteger("Colors", "CommentsBackground", -1)
		.Colors(2, 2) = piniTheme->ReadInteger("Colors", "CommentsFrame", -1)
		.Colors(2, 4) = piniTheme->ReadInteger("FontStyles", "CommentsBold", 0)
		.Colors(2, 5) = piniTheme->ReadInteger("FontStyles", "CommentsItalic", 0)
		.Colors(2, 6) = piniTheme->ReadInteger("FontStyles", "CommentsUnderline", 0)
		.Colors(3, 0) = piniTheme->ReadInteger("Colors", "CurrentBracketsForeground", -1)
		.Colors(3, 1) = piniTheme->ReadInteger("Colors", "CurrentBracketsBackground", -1)
		.Colors(3, 2) = piniTheme->ReadInteger("Colors", "CurrentBracketsFrame", -1)
		.Colors(3, 3) = piniTheme->ReadInteger("Colors", "CurrentBracketsIndicator", -1)
		.Colors(3, 4) = piniTheme->ReadInteger("FontStyles", "CurrentBracketsBold", 0)
		.Colors(3, 5) = piniTheme->ReadInteger("FontStyles", "CurrentBracketsItalic", 0)
		.Colors(3, 6) = piniTheme->ReadInteger("FontStyles", "CurrentBracketsUnderline", 0)
		.Colors(4, 0) = piniTheme->ReadInteger("Colors", "CurrentLineForeground", -1)
		.Colors(4, 1) = piniTheme->ReadInteger("Colors", "CurrentLineBackground", -1)
		.Colors(4, 2) = piniTheme->ReadInteger("Colors", "CurrentLineFrame", -1)
		.Colors(5, 0) = piniTheme->ReadInteger("Colors", "CurrentWordForeground", -1)
		.Colors(5, 1) = piniTheme->ReadInteger("Colors", "CurrentWordBackground", -1)
		.Colors(5, 2) = piniTheme->ReadInteger("Colors", "CurrentWordFrame", -1)
		.Colors(5, 3) = piniTheme->ReadInteger("Colors", "CurrentWordIndicator", -1)
		.Colors(5, 4) = piniTheme->ReadInteger("FontStyles", "CurrentWordBold", 0)
		.Colors(5, 5) = piniTheme->ReadInteger("FontStyles", "CurrentWordItalic", 0)
		.Colors(5, 6) = piniTheme->ReadInteger("FontStyles", "CurrentWordUnderline", 0)
		.Colors(6, 0) = piniTheme->ReadInteger("Colors", "ExecutionLineForeground", -1)
		.Colors(6, 1) = piniTheme->ReadInteger("Colors", "ExecutionLineBackground", -1)
		.Colors(6, 2) = piniTheme->ReadInteger("Colors", "ExecutionLineFrame", -1)
		.Colors(6, 3) = piniTheme->ReadInteger("Colors", "ExecutionLineIndicator", -1)
		.Colors(7, 0) = piniTheme->ReadInteger("Colors", "FoldLinesForeground", -1)
		.Colors(8, 0) = piniTheme->ReadInteger("Colors", "IdentifiersForeground", piniTheme->ReadInteger("Colors", "NormalTextForeground", -1))
		.Colors(8, 1) = piniTheme->ReadInteger("Colors", "IdentifiersBackground", piniTheme->ReadInteger("Colors", "NormalTextBackground", -1))
		.Colors(8, 2) = piniTheme->ReadInteger("Colors", "IdentifiersFrame", piniTheme->ReadInteger("Colors", "NormalTextFrame", -1))
		.Colors(8, 4) = piniTheme->ReadInteger("FontStyles", "IdentifiersBold", piniTheme->ReadInteger("FontStyles", "NormalTextBold", 0))
		.Colors(8, 5) = piniTheme->ReadInteger("FontStyles", "IdentifiersItalic", piniTheme->ReadInteger("FontStyles", "NormalTextItalic", 0))
		.Colors(8, 6) = piniTheme->ReadInteger("FontStyles", "IdentifiersUnderline", piniTheme->ReadInteger("FontStyles", "NormalTextUnderline", 0))
		.Colors(9, 0) = piniTheme->ReadInteger("Colors", "IndicatorLinesForeground", -1)
		Dim As Integer k
		For k = 0 To UBound(Keywords)
			.Colors(10 + k, 0) = piniTheme->ReadInteger("Colors", Replace(KeywordLists.Item(k), " ", "") & "Foreground", piniTheme->ReadInteger("Colors", "KeywordsForeground", -1))
			.Colors(10 + k, 1) = piniTheme->ReadInteger("Colors", Replace(KeywordLists.Item(k), " ", "") & "Background", piniTheme->ReadInteger("Colors", "KeywordsBackground", -1))
			.Colors(10 + k, 2) = piniTheme->ReadInteger("Colors", Replace(KeywordLists.Item(k), " ", "") & "Frame", piniTheme->ReadInteger("Colors", "KeywordsFrame", -1))
			.Colors(10 + k, 4) = piniTheme->ReadInteger("FontStyles", Replace(KeywordLists.Item(k), " ", "") & "Bold", piniTheme->ReadInteger("Colors", "KeywordsBold", 0))
			.Colors(10 + k, 5) = piniTheme->ReadInteger("FontStyles", Replace(KeywordLists.Item(k), " ", "") & "Italic", piniTheme->ReadInteger("Colors", "KeywordsItalic", 0))
			.Colors(10 + k, 6) = piniTheme->ReadInteger("FontStyles", Replace(KeywordLists.Item(k), " ", "") & "Underline", piniTheme->ReadInteger("Colors", "KeywordsUnderline", 0))
		Next k
		k = UBound(Keywords)
		.Colors(11 + k, 0) = piniTheme->ReadInteger("Colors", "LineNumbersForeground", -1)
		.Colors(11 + k, 1) = piniTheme->ReadInteger("Colors", "LineNumbersBackground", -1)
		.Colors(11 + k, 4) = piniTheme->ReadInteger("FontStyles", "LineNumbersBold", 0)
		.Colors(11 + k, 5) = piniTheme->ReadInteger("FontStyles", "LineNumbersItalic", 0)
		.Colors(11 + k, 6) = piniTheme->ReadInteger("FontStyles", "LineNumbersUnderline", 0)
		.Colors(12 + k, 0) = piniTheme->ReadInteger("Colors", "NormalTextForeground", -1)
		.Colors(12 + k, 1) = piniTheme->ReadInteger("Colors", "NormalTextBackground", -1)
		.Colors(12 + k, 2) = piniTheme->ReadInteger("Colors", "NormalTextFrame", -1)
		.Colors(12 + k, 4) = piniTheme->ReadInteger("FontStyles", "NormalTextBold", 0)
		.Colors(12 + k, 5) = piniTheme->ReadInteger("FontStyles", "NormalTextItalic", 0)
		.Colors(12 + k, 6) = piniTheme->ReadInteger("FontStyles", "NormalTextUnderline", 0)
'		.Colors(12 + k, 0) = piniTheme->ReadInteger("Colors", "PreprocessorsForeground", -1)
'		.Colors(12 + k, 1) = piniTheme->ReadInteger("Colors", "PreprocessorsBackground", -1)
'		.Colors(12 + k, 2) = piniTheme->ReadInteger("Colors", "PreprocessorsFrame", -1)
'		.Colors(12 + k, 4) = piniTheme->ReadInteger("FontStyles", "PreprocessorsBold", 0)
'		.Colors(12 + k, 5) = piniTheme->ReadInteger("FontStyles", "PreprocessorsItalic", 0)
'		.Colors(12 + k, 6) = piniTheme->ReadInteger("FontStyles", "PreprocessorsUnderline", 0)
		.Colors(13 + k, 0) = piniTheme->ReadInteger("Colors", "NumbersForeground", piniTheme->ReadInteger("Colors", "NormalTextForeground", -1))
		.Colors(13 + k, 1) = piniTheme->ReadInteger("Colors", "NumbersBackground", piniTheme->ReadInteger("Colors", "NormalTextBackground", -1))
		.Colors(13 + k, 2) = piniTheme->ReadInteger("Colors", "NumbersFrame", piniTheme->ReadInteger("Colors", "NormalTextFrame", -1))
		.Colors(13 + k, 4) = piniTheme->ReadInteger("FontStyles", "NumbersBold", piniTheme->ReadInteger("FontStyles", "NormalTextBold", 0))
		.Colors(13 + k, 5) = piniTheme->ReadInteger("FontStyles", "NumbersItalic", piniTheme->ReadInteger("FontStyles", "NormalTextItalic", 0))
		.Colors(13 + k, 6) = piniTheme->ReadInteger("FontStyles", "NumbersUnderline", piniTheme->ReadInteger("FontStyles", "NormalTextUnderline", 0))
		.Colors(14 + k, 0) = piniTheme->ReadInteger("Colors", "RealNumbersForeground", piniTheme->ReadInteger("Colors", "NumbersForeground", -1))
		.Colors(14 + k, 1) = piniTheme->ReadInteger("Colors", "RealNumbersBackground", piniTheme->ReadInteger("Colors", "NumbersBackground", -1))
		.Colors(14 + k, 2) = piniTheme->ReadInteger("Colors", "RealNumbersFrame", piniTheme->ReadInteger("Colors", "NumbersFrame", -1))
		.Colors(14 + k, 4) = piniTheme->ReadInteger("FontStyles", "RealNumbersBold", piniTheme->ReadInteger("FontStyles", "NumbersBold", 0))
		.Colors(14 + k, 5) = piniTheme->ReadInteger("FontStyles", "RealNumbersItalic", piniTheme->ReadInteger("FontStyles", "NumbersItalic", 0))
		.Colors(14 + k, 6) = piniTheme->ReadInteger("FontStyles", "RealNumbersUnderline", piniTheme->ReadInteger("FontStyles", "NumbersUnderline", 0))
		.Colors(15 + k, 0) = piniTheme->ReadInteger("Colors", "SelectionForeground", -1)
		.Colors(15 + k, 1) = piniTheme->ReadInteger("Colors", "SelectionBackground", -1)
		.Colors(15 + k, 2) = piniTheme->ReadInteger("Colors", "SelectionFrame", -1)
		.Colors(16 + k, 0) = piniTheme->ReadInteger("Colors", "SpaceIdentifiersForeground", -1)
		.Colors(17 + k, 0) = piniTheme->ReadInteger("Colors", "StringsForeground", -1)
		.Colors(17 + k, 1) = piniTheme->ReadInteger("Colors", "StringsBackground", -1)
		.Colors(17 + k, 2) = piniTheme->ReadInteger("Colors", "StringsFrame", -1)
		.Colors(17 + k, 4) = piniTheme->ReadInteger("FontStyles", "StringsBold", 0)
		.Colors(17 + k, 5) = piniTheme->ReadInteger("FontStyles", "StringsItalic", 0)
		.Colors(17 + k, 6) = piniTheme->ReadInteger("FontStyles", "StringsUnderline", 0)
		.lstColorKeys_Change(.lstColorKeys)
		Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb <> 0 Then
			SetColors
			#ifdef __USE_GTK__
				tb->txtCode.Update
			#else
				RedrawWindow tb->txtCode.Handle, NULL, NULL, RDW_INVALIDATE
			#endif
		End If
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

Private Sub frmOptions.chkFrame_Click(ByRef Sender As CheckBox)
	With fOptions
		Var i = .lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Colors(i, 2) = IIf(.chkFrame.Checked, -1, .lblColorFrame.BackColor)
	End With
End Sub

Private Sub frmOptions.chkIndicator_Click(ByRef Sender As CheckBox)
	With fOptions
		Var i = .lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Colors(i, 3) = IIf(.chkIndicator.Checked, -1, .lblColorIndicator.BackColor)
	End With
End Sub

Private Sub frmOptions.chkBold_Click(ByRef Sender As CheckBox)
	With fOptions
		Var i = .lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Colors(i, 4) = IIf(.chkBold.Checked, -1, 0)
	End With
End Sub

Private Sub frmOptions.chkItalic_Click(ByRef Sender As CheckBox)
	With fOptions
		Var i = .lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Colors(i, 5) = IIf(.chkItalic.Checked, -1, 0)
	End With
End Sub

Private Sub frmOptions.chkUnderline_Click(ByRef Sender As CheckBox)
	With fOptions
		Var i = .lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Colors(i, 6) = IIf(.chkUnderline.Checked, -1, 0)
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
	pfPath->txtVersion.Text = ""
	pfPath->txtPath.Text = ""
	pfPath->txtCommandLine.Text = ""
	If pfPath->ShowModal() = ModalResults.OK Then
		With fOptions
			If .cboCompiler32.IndexOf(pfPath->txtVersion.Text) = -1 Then
				.lvCompilerPaths.ListItems.Add pfPath->txtVersion.Text, IIf(FileExists(pfPath->txtPath.Text), "", "FileError")
				.lvCompilerPaths.ListItems.Item(.lvCompilerPaths.ListItems.Count - 1)->Text(1) = pfPath->txtPath.Text
				.lvCompilerPaths.ListItems.Item(.lvCompilerPaths.ListItems.Count - 1)->Text(2) = pfPath->txtCommandLine.Text
				.cboCompiler32.AddItem pfPath->txtVersion.Text
				.cboCompiler64.AddItem pfPath->txtVersion.Text
			Else
				MsgBox ML("This version is exists!")
			End If
		End With
	End If
End Sub

Private Sub frmOptions.cmdChangeCompiler_Click(ByRef Sender As Control)
	With fOptions
		If .lvCompilerPaths.SelectedItem = 0 Then Exit Sub
		pfPath->txtVersion.Text = .lvCompilerPaths.SelectedItem->Text(0)
		pfPath->txtPath.Text = .lvCompilerPaths.SelectedItem->Text(1)
		pfPath->txtCommandLine.Text = .lvCompilerPaths.SelectedItem->Text(2)
		If pfPath->ShowModal() = ModalResults.OK Then
			If .lvCompilerPaths.SelectedItem->Text(0) = pfPath->txtVersion.Text OrElse .cboCompiler32.IndexOf(pfPath->txtVersion.Text) = -1 Then
				Var i = .cboCompiler32.IndexOf(.lvCompilerPaths.SelectedItem->Text(0))
				.cboCompiler32.Item(i) = pfPath->txtVersion.Text
				.cboCompiler64.Item(i) = pfPath->txtVersion.Text
				.lvCompilerPaths.SelectedItem->Text(0) = pfPath->txtVersion.Text
				.lvCompilerPaths.SelectedItem->Text(1) = pfPath->txtPath.Text
				.lvCompilerPaths.SelectedItem->Text(2) = pfPath->txtCommandLine.Text
				.lvCompilerPaths.SelectedItem->ImageKey = IIf(FileExists(pfPath->txtPath.Text), "", "FileError")
				.lvCompilerPaths.SelectedItem->SelectedImageKey = IIf(FileExists(pfPath->txtPath.Text), "", "FileError")
			Else
				MsgBox ML("This version is exists!")
			End If
		End If
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
	pfPath->txtVersion.Text = ""
	pfPath->txtPath.Text = ""
	pfPath->txtCommandLine.Text = ""
	If pfPath->ShowModal() = ModalResults.OK Then
		With fOptions
			If .cboMakeTool.IndexOf(pfPath->txtVersion.Text) = -1 Then
				.lvMakeToolPaths.ListItems.Add pfPath->txtVersion.Text
				.lvMakeToolPaths.ListItems.Item(.lvMakeToolPaths.ListItems.Count - 1)->Text(1) = pfPath->txtPath.Text
				.lvMakeToolPaths.ListItems.Item(.lvMakeToolPaths.ListItems.Count - 1)->Text(2) = pfPath->txtCommandLine.Text
				.cboMakeTool.AddItem pfPath->txtVersion.Text
			Else
				MsgBox ML("This version is exists!")
			End If
		End With
	End If
End Sub

Private Sub frmOptions.cmdChangeMakeTool_Click(ByRef Sender As Control)
	With fOptions
		If .lvMakeToolPaths.SelectedItem = 0 Then Exit Sub
		pfPath->txtVersion.Text = .lvMakeToolPaths.SelectedItem->Text(0)
		pfPath->txtPath.Text = .lvMakeToolPaths.SelectedItem->Text(1)
		pfPath->txtCommandLine.Text = .lvMakeToolPaths.SelectedItem->Text(2)
		If pfPath->ShowModal() = ModalResults.OK Then
			If .lvMakeToolPaths.SelectedItem->Text(0) = pfPath->txtVersion.Text OrElse .cboMakeTool.IndexOf(pfPath->txtVersion.Text) = -1 Then
				Var i = .cboTerminal.IndexOf(.lvMakeToolPaths.SelectedItem->Text(0))
				.cboMakeTool.Item(i) = pfPath->txtVersion.Text
				.lvMakeToolPaths.SelectedItem->Text(0) = pfPath->txtVersion.Text
				.lvMakeToolPaths.SelectedItem->Text(1) = pfPath->txtPath.Text
				.lvMakeToolPaths.SelectedItem->Text(2) = pfPath->txtCommandLine.Text
			Else
				MsgBox ML("This version is exists!")
			End If
		End If
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
	pfPath->txtVersion.Text = ""
	pfPath->txtPath.Text = ""
	pfPath->txtCommandLine.Text = ""
	If pfPath->ShowModal() = ModalResults.OK Then
		With fOptions
			If .cboDebugger32.IndexOf(pfPath->txtVersion.Text) = -1 Then
				.lvDebuggerPaths.ListItems.Add pfPath->txtVersion.Text
				.lvDebuggerPaths.ListItems.Item(.lvDebuggerPaths.ListItems.Count - 1)->Text(1) = pfPath->txtPath.Text
				.lvDebuggerPaths.ListItems.Item(.lvDebuggerPaths.ListItems.Count - 1)->Text(2) = pfPath->txtCommandLine.Text
				.cboDebugger32.AddItem pfPath->txtVersion.Text
				.cboDebugger64.AddItem pfPath->txtVersion.Text
			Else
				MsgBox ML("This version is exists!")
			End If
		End With
	End If
End Sub

Private Sub frmOptions.cmdChangeDebugger_Click(ByRef Sender As Control)
	With fOptions
		If .lvDebuggerPaths.SelectedItem = 0 Then Exit Sub
		pfPath->txtVersion.Text = .lvDebuggerPaths.SelectedItem->Text(0)
		pfPath->txtPath.Text = .lvDebuggerPaths.SelectedItem->Text(1)
		pfPath->txtCommandLine.Text = .lvDebuggerPaths.SelectedItem->Text(2)
		If pfPath->ShowModal() = ModalResults.OK Then
			If .lvDebuggerPaths.SelectedItem->Text(0) = pfPath->txtVersion.Text OrElse .cboDebugger32.IndexOf(pfPath->txtVersion.Text) = -1 Then
				Var i = .cboDebugger32.IndexOf(.lvDebuggerPaths.SelectedItem->Text(0))
				.cboDebugger32.Item(i) = pfPath->txtVersion.Text
				.cboDebugger64.Item(i) = pfPath->txtVersion.Text
				.lvDebuggerPaths.SelectedItem->Text(0) = pfPath->txtVersion.Text
				.lvDebuggerPaths.SelectedItem->Text(1) = pfPath->txtPath.Text
				.lvDebuggerPaths.SelectedItem->Text(2) = pfPath->txtCommandLine.Text
			Else
				MsgBox ML("This version is exists!")
			End If
		End If
	End With
End Sub

Private Sub frmOptions.cmdRemoveDebugger_Click(ByRef Sender As Control)
	With fOptions
		If .lvDebuggerPaths.SelectedItem = 0 Then Exit Sub
		Var iIndex = .cboDebugger32.IndexOf(.lvDebuggerPaths.SelectedItem->Text(0))
		If iIndex > -1 Then .cboDebugger32.RemoveItem iIndex: .cboDebugger64.RemoveItem iIndex
		If .cboDebugger32.ItemIndex = -1 Then .cboDebugger32.ItemIndex = 0
		If .cboDebugger64.ItemIndex = -1 Then .cboDebugger64.ItemIndex = 0
		.lvDebuggerPaths.ListItems.Remove .lvDebuggerPaths.SelectedItemIndex
	End With
End Sub

Private Sub frmOptions.cmdClearDebuggers_Click(ByRef Sender As Control)
	With fOptions
		.lvDebuggerPaths.ListItems.Clear
		.cboDebugger32.Clear
		.cboDebugger32.AddItem ML("Integrated IDE Debugger")
		.cboDebugger32.AddItem ML("Integrated GDB Debugger")
		.cboDebugger32.ItemIndex = 0
		.cboDebugger64.Clear
		.cboDebugger64.AddItem ML("Integrated IDE Debugger")
		.cboDebugger64.AddItem ML("Integrated GDB Debugger")
		.cboDebugger64.ItemIndex = 0
		.cboGDBDebugger32.Clear
		.cboGDBDebugger64.Clear
	End With
End Sub

Private Sub frmOptions.cmdAddTerminal_Click(ByRef Sender As Control)
	pfPath->txtVersion.Text = ""
	pfPath->txtPath.Text = ""
	pfPath->txtCommandLine.Text = ""
	If pfPath->ShowModal() = ModalResults.OK Then
		With fOptions
			If .cboTerminal.IndexOf(pfPath->txtVersion.Text) = -1 Then
				.lvTerminalPaths.ListItems.Add pfPath->txtVersion.Text
				.lvTerminalPaths.ListItems.Item(.lvTerminalPaths.ListItems.Count - 1)->Text(1) = pfPath->txtPath.Text
				.lvTerminalPaths.ListItems.Item(.lvTerminalPaths.ListItems.Count - 1)->Text(2) = pfPath->txtCommandLine.Text
				.cboTerminal.AddItem pfPath->txtVersion.Text
			Else
				MsgBox ML("This version is exists!")
			End If
		End With
	End If
End Sub

Private Sub frmOptions.cmdChangeTerminal_Click(ByRef Sender As Control)
	With fOptions
		If .lvTerminalPaths.SelectedItem = 0 Then Exit Sub
		pfPath->txtVersion.Text = .lvTerminalPaths.SelectedItem->Text(0)
		pfPath->txtPath.Text = .lvTerminalPaths.SelectedItem->Text(1)
		pfPath->txtCommandLine.Text = .lvTerminalPaths.SelectedItem->Text(2)
		If pfPath->ShowModal() = ModalResults.OK Then
			If .lvTerminalPaths.SelectedItem->Text(0) = pfPath->txtVersion.Text OrElse .cboTerminal.IndexOf(pfPath->txtVersion.Text) = -1 Then
				Var i = .cboTerminal.IndexOf(.lvTerminalPaths.SelectedItem->Text(0))
				.cboTerminal.Item(i) = pfPath->txtVersion.Text
				.lvTerminalPaths.SelectedItem->Text(0) = pfPath->txtVersion.Text
				.lvTerminalPaths.SelectedItem->Text(1) = pfPath->txtPath.Text
				.lvTerminalPaths.SelectedItem->Text(2) = pfPath->txtCommandLine.Text
			Else
				MsgBox ML("This version is exists!")
			End If
		End If
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

Private Sub frmOptions.cmdAddHelp_Click(ByRef Sender As Control)
	pfPath->txtVersion.Text = ""
	pfPath->txtPath.Text = ""
	pfPath->WithoutCommandLine = True
	If pfPath->ShowModal() = ModalResults.OK Then
		With fOptions
			If .cboHelp.IndexOf(pfPath->txtVersion.Text) = -1 Then
				.lvHelpPaths.ListItems.Add pfPath->txtVersion.Text
				.lvHelpPaths.ListItems.Item(.lvHelpPaths.ListItems.Count - 1)->Text(1) = pfPath->txtPath.Text
				.cboHelp.AddItem pfPath->txtVersion.Text
			Else
				MsgBox ML("This version is exists!")
			End If
		End With
	End If
End Sub

Private Sub frmOptions.cmdChangeHelp_Click(ByRef Sender As Control)
	With fOptions
		If .lvHelpPaths.SelectedItem = 0 Then Exit Sub
		pfPath->txtVersion.Text = .lvHelpPaths.SelectedItem->Text(0)
		pfPath->txtPath.Text = .lvHelpPaths.SelectedItem->Text(1)
		pfPath->WithoutCommandLine = True
		If pfPath->ShowModal() = ModalResults.OK Then
			If .lvHelpPaths.SelectedItem->Text(0) = pfPath->txtVersion.Text OrElse .cboHelp.IndexOf(pfPath->txtVersion.Text) = -1 Then
				Var i = .cboHelp.IndexOf(.lvHelpPaths.SelectedItem->Text(0))
				.cboHelp.Item(i) = pfPath->txtVersion.Text
				.lvHelpPaths.SelectedItem->Text(0) = pfPath->txtVersion.Text
				.lvHelpPaths.SelectedItem->Text(1) = pfPath->txtPath.Text
			Else
				MsgBox ML("This version is exists!")
			End If
		End If
	End With
End Sub

Private Sub frmOptions.cmdRemoveHelp_Click(ByRef Sender As Control)
	With fOptions
		If .lvHelpPaths.SelectedItem = 0 Then Exit Sub
		Var iIndex = .cboHelp.IndexOf(.lvHelpPaths.SelectedItem->Text(0))
		If iIndex > -1 Then .cboHelp.RemoveItem iIndex
		If .cboHelp.ItemIndex = -1 Then .cboHelp.ItemIndex = 0
		.lvHelpPaths.ListItems.Remove .lvHelpPaths.SelectedItemIndex
	End With
End Sub

Private Sub frmOptions.cmdClearHelps_Click(ByRef Sender As Control)
	With fOptions
		.lvHelpPaths.ListItems.Clear
		.cboHelp.Clear
		.cboHelp.AddItem ML("(not selected)")
		.cboHelp.ItemIndex = 0
	End With
End Sub

Private Sub frmOptions.cmdInterfaceFont_Click(ByRef Sender As Control)
	With fOptions
		.FontD.Font.Name = *.InterfFontName
		.FontD.Font.Size = .InterfFontSize
		If .FontD.Execute Then
			WLet(.InterfFontName, .FontD.Font.Name)
			.InterfFontSize = .FontD.Font.Size
			.lblInterfaceFont.Font.Name = *.InterfFontName
			.lblInterfaceFont.Caption = *.InterfFontName & ", " & .InterfFontSize & "pt"
		End If
	End With
End Sub

Private Sub frmOptions.cmdAddInclude_Click(ByRef Sender As Control)
	pfPath->txtPath.Text = ""
	pfPath->ChooseFolder = True
	If pfPath->ShowModal() = ModalResults.OK Then
		With fOptions
			If Not .lstIncludePaths.Items.Contains(pfPath->txtPath.Text) Then
				'.lstIncludePaths.Items.Add pfPath->txtPath.Text
				.lstIncludePaths.AddItem pfPath->txtPath.Text
			Else
				MsgBox ML("This path is exists!")
			End If
		End With
	End If
End Sub

Private Sub frmOptions.cmdAddLibrary_Click(ByRef Sender As Control)
	pfPath->txtPath.Text = ""
	pfPath->ChooseFolder = True
	If pfPath->ShowModal() = ModalResults.OK Then
		With fOptions
			If Not .lstLibraryPaths.Items.Contains(pfPath->txtPath.Text) Then
				'.lstLibraryPaths.Items.Add pfPath->txtPath.Text
				.lstLibraryPaths.AddItem pfPath->txtPath.Text
			Else
				MsgBox ML("This path is exists!")
			End If
		End With
	End If
End Sub

Private Sub frmOptions.cmdRemoveInclude_Click(ByRef Sender As Control)
	Var Index = fOptions.lstIncludePaths.ItemIndex
	If Index <> -1 Then fOptions.lstIncludePaths.RemoveItem Index
End Sub

Private Sub frmOptions.cmdRemoveLibrary_Click(ByRef Sender As Control)
	Var Index = fOptions.lstLibraryPaths.ItemIndex
	If Index <> -1 Then fOptions.lstLibraryPaths.RemoveItem Index
End Sub

Private Sub frmOptions.cmdProjectsPath_Click(ByRef Sender As Control)
	With fOptions
		.BrowsD.InitialDir = GetFullPath(.txtProjectsPath.Text)
		If .BrowsD.Execute Then
			.txtProjectsPath.Text = .BrowsD.Directory
		End If
	End With
End Sub

Private Sub frmOptions.lvShortcuts_SelectedItemChanged(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	With fOptions
		Var Index = .lvShortcuts.SelectedItemIndex
		If Index > -1 Then
			.hkShortcut.Text = .lvShortcuts.SelectedItem->Text(1)
		End If
	End With
End Sub

Private Sub frmOptions.cmdSetShortcut_Click(ByRef Sender As Control)
	With fOptions
		Var Index = .lvShortcuts.SelectedItemIndex
		If Index > -1 Then
			.lvShortcuts.SelectedItem->Text(1) = .hkShortcut.Text
			.HotKeysChanged = True
		End If
	End With
End Sub

Private Sub frmOptions.cmdAddEditor_Click_(ByRef Sender As Control)
	*Cast(frmOptions Ptr, Sender.Designer).cmdAddEditor_Click(Sender)
End Sub
Private Sub frmOptions.cmdAddEditor_Click(ByRef Sender As Control)
	pfPath->txtVersion.Text = ""
	pfPath->txtExtensions.Text = ""
	pfPath->txtPath.Text = ""
	pfPath->txtCommandLine.Text = ""
	pfPath->WithExtensions = True
	If pfPath->ShowModal() = ModalResults.OK Then
		With lvOtherEditors.ListItems
			Var ItemsCount = .Count
			If .IndexOf(pfPath->txtVersion.Text) = -1 Then
				.Add pfPath->txtVersion.Text
				.Item(ItemsCount)->Text(1) = pfPath->txtExtensions.Text
				.Item(ItemsCount)->Text(2) = pfPath->txtPath.Text
				.Item(ItemsCount)->Text(3) = pfPath->txtCommandLine.Text
			Else
				MsgBox ML("This version is exists!")
			End If
		End With
	End If
End Sub

Private Sub frmOptions.cmdChangeEditor_Click_(ByRef Sender As Control)
	*Cast(frmOptions Ptr, Sender.Designer).cmdChangeEditor_Click(Sender)
End Sub
Private Sub frmOptions.cmdChangeEditor_Click(ByRef Sender As Control)
	With lvOtherEditors
		If .SelectedItem = 0 Then Exit Sub
		pfPath->txtVersion.Text = .SelectedItem->Text(0)
		pfPath->txtExtensions.Text = .SelectedItem->Text(1)
		pfPath->txtPath.Text = .SelectedItem->Text(2)
		pfPath->txtCommandLine.Text = .SelectedItem->Text(3)
		pfPath->WithExtensions = True
		If pfPath->ShowModal() = ModalResults.OK Then
			If .SelectedItem->Text(0) = pfPath->txtVersion.Text OrElse .ListItems.IndexOf(pfPath->txtVersion.Text) = -1 Then
				Var i = .ListItems.IndexOf(.SelectedItem->Text(0))
				.SelectedItem->Text(0) = pfPath->txtVersion.Text
				.SelectedItem->Text(1) = pfPath->txtExtensions.Text
				.SelectedItem->Text(2) = pfPath->txtPath.Text
				.SelectedItem->Text(3) = pfPath->txtCommandLine.Text
			Else
				MsgBox ML("This version is exists!")
			End If
		End If
	End With
End Sub

Private Sub frmOptions.cmdRemoveEditor_Click_(ByRef Sender As Control)
	*Cast(frmOptions Ptr, Sender.Designer).cmdRemoveEditor_Click(Sender)
End Sub
Private Sub frmOptions.cmdRemoveEditor_Click(ByRef Sender As Control)
	With lvOtherEditors
		If .SelectedItem = 0 Then Exit Sub
		.ListItems.Remove .SelectedItemIndex
	End With
End Sub

Private Sub frmOptions.cmdClearEditor_Click_(ByRef Sender As Control)
	*Cast(frmOptions Ptr, Sender.Designer).cmdClearEditor_Click(Sender)
End Sub
Private Sub frmOptions.cmdClearEditor_Click(ByRef Sender As Control)
	lvOtherEditors.ListItems.Clear
End Sub

Sub cboDefaultProjectFileCheckEnable
	fOptions.cboDefaultProjectFile.Enabled = fOptions.optCreateProjectFile.Checked
	fOptions.cboOpenedFile.Enabled = fOptions.optOpenLastSession.Checked
End Sub

Private Sub frmOptions.optPromptForProjectAndFiles_Click(ByRef Sender As RadioButton)
	cboDefaultProjectFileCheckEnable
End Sub

Private Sub frmOptions.optCreateProjectFile_Click(ByRef Sender As RadioButton)
	cboDefaultProjectFileCheckEnable
End Sub

Private Sub frmOptions.optOpenLastSession_Click(ByRef Sender As RadioButton)
	cboDefaultProjectFileCheckEnable
End Sub

Private Sub frmOptions.optDoNotNothing_Click(ByRef Sender As RadioButton)
	cboDefaultProjectFileCheckEnable
End Sub

Dim Shared As Boolean bStop
Dim Shared As Integer FindedCompilersCount
Dim Shared As UString FolderName = GetFolderName(pApp->FileName)
Sub FindCompilers(ByRef Path As WString)
	Dim As WString * 1024 f, f1, f2, f3
	Dim As UInteger Attr, NameCount
	Dim As WStringList Folders
	If Path = "" Then Exit Sub
	If FormClosing OrElse bStop Then Exit Sub
	If EndsWith(Path, "\Windows") Then Exit Sub
	ThreadsEnter
	'fOptions.lblFindCompilersFromComputer.Text = Path
	pstBar->Panels[0]->Caption = Path
	ThreadsLeave
	f = Dir(Path & Slash & "*", fbDirectory, Attr)
	While f <> ""
		If FormClosing OrElse bStop Then Exit Sub
		If f <> "." AndAlso f <> ".." Then Folders.Add Path & IIf(EndsWith(Path, Slash), "", Slash) & f
		f = Dir(Attr)
	Wend
	f = Dir(Path & Slash & "fbc*", fbReadOnly Or fbHidden Or fbSystem Or fbArchive, Attr)
	While f <> ""
		If FormClosing OrElse bStop Then Exit Sub
'		If (Attr And fbDirectory) <> 0 Then
'			If f <> "." AndAlso f <> ".." Then Folders.Add Path & IIf(EndsWith(Path, Slash), "", Slash) & f
		#ifdef __FB_WIN32__
			If LCase(f) = "fbc.exe" OrElse LCase(f) = "fbc32.exe" OrElse LCase(f) = "fbc64.exe" Then
		#else
			If LCase(f) = "fbc" Then
		#endif
			f1 = Path & IIf(EndsWith(Path, Slash), "", Slash) & f
			ThreadsEnter
			With fOptions.lvCompilerPaths.ListItems
				For i As Integer = 0 To .Count - 1
					If EqualPaths(.Item(i)->Text(1), f1) Then f = Dir(Attr): ThreadsLeave: Continue While
				Next
				If StartsWith(f1, FolderName) Then f1 = "." & Slash & Mid(f1, Len(FolderName) + 1)
				f2 = GetFileName(GetFolderName(f1, False))
				If f2 = "bin" Then f2 = GetFileName(GetFolderName(GetFolderName(f1, False), False))
				If EndsWith(f, "32.exe") Then: f2 = f2 & " 32": ElseIf EndsWith(f, "64.exe") Then: f2 = f2 & " 64": End If
				NameCount = 0
				f3 = f2
				While .Contains(f3)
					NameCount += 1
					f3 = f2 & " " & NameCount
				Wend
				.Add f3
				.Item(.Count - 1)->Text(1) = f1
				fOptions.cboCompiler32.AddItem f3
				fOptions.cboCompiler64.AddItem f3
			End With
			ThreadsLeave
			FindedCompilersCount += 1
		End If
		f = Dir(Attr)
	Wend
	For i As Integer = 0 To Folders.Count - 1
		FindCompilers Folders.Item(i)
	Next
	Folders.Clear
End Sub

Sub FindProcessStartStop()
	With fOptions
		If bStop Then
			StopProgress
			.cmdFindCompilers.Text = ML("&Find")
			'fOptions.lblFindCompilersFromComputer.Text = ML("Find Compilers from Computer:")
			RestoreStatusText
		Else
			StartProgress
			.cmdFindCompilers.Text = ML("Stop")
			ThreadCounter(ThreadCreate_(@FindCompilersSub))
		End If
		.cmdAddCompiler.Enabled = bStop
		.cmdChangeCompiler.Enabled = bStop
		.cmdRemoveCompiler.Enabled = bStop
		.cmdClearCompilers.Enabled = bStop
	End With
End Sub

Sub FindCompilersSub(Param As Any Ptr)
	Dim As String disk0 = CurDir
	For i As Integer = 65 To 90
		If FormClosing OrElse bStop Then Exit For
		If ChDir(Chr(i) & ":") = 0 Then FindCompilers Chr(i) & ":"
	Next
	ChDir(disk0)
	ThreadsEnter
	bStop = True: FindProcessStartStop
	If FindedCompilersCount = 0 Then
		MsgBox ML("No сompilers found"), App.Title
	Else
		MsgBox ML("Number of compilers found") & ": " & Str(FindedCompilersCount), App.Title
	End If
	ThreadsLeave
End Sub

Private Sub frmOptions.cmdFindCompilers_Click_(ByRef Sender As Control)
	*Cast(frmOptions Ptr, Sender.Designer).cmdFindCompilers_Click(Sender)
End Sub

Private Sub frmOptions.cmdFindCompilers_Click(ByRef Sender As Control)
	bStop = cmdFindCompilers.Text = ML("Stop")
	FindProcessStartStop()
End Sub

Private Sub frmOptions.lvOtherEditors_ItemActivate_(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	*Cast(frmOptions Ptr, Sender.Designer).lvOtherEditors_ItemActivate(Sender, ItemIndex)
End Sub
Private Sub frmOptions.lvOtherEditors_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	cmdChangeEditor_Click cmdChangeEditor
End Sub

Private Sub frmOptions.lvTerminalPaths_ItemActivate_(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	*Cast(frmOptions Ptr, Sender.Designer).lvTerminalPaths_ItemActivate(Sender, ItemIndex)
End Sub
Private Sub frmOptions.lvTerminalPaths_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	cmdChangeTerminal_Click cmdChangeTerminal
End Sub

Private Sub frmOptions.lvDebuggerPaths_ItemActivate_(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	*Cast(frmOptions Ptr, Sender.Designer).lvDebuggerPaths_ItemActivate(Sender, ItemIndex)
End Sub
Private Sub frmOptions.lvDebuggerPaths_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	cmdChangeDebugger_Click cmdChangeDebugger
End Sub

Private Sub frmOptions.lvHelpPaths_ItemActivate_(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	*Cast(frmOptions Ptr, Sender.Designer).lvHelpPaths_ItemActivate(Sender, ItemIndex)
End Sub
Private Sub frmOptions.lvHelpPaths_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	cmdChangeHelp_Click cmdChangeHelp
End Sub

Private Sub frmOptions.lvMakeToolPaths_ItemActivate_(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	*Cast(frmOptions Ptr, Sender.Designer).lvMakeToolPaths_ItemActivate(Sender, ItemIndex)
End Sub
Private Sub frmOptions.lvMakeToolPaths_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	cmdChangeMakeTool_Click cmdChangeMakeTool
End Sub

Private Sub frmOptions.lvCompilerPaths_ItemActivate_(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	*Cast(frmOptions Ptr, Sender.Designer).lvCompilerPaths_ItemActivate(Sender, ItemIndex)
End Sub
Private Sub frmOptions.lvCompilerPaths_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	cmdChangeCompiler_Click cmdChangeCompiler
End Sub

Private Sub frmOptions.cmdInFolder_Click_(ByRef Sender As Control)
	*Cast(frmOptions Ptr, Sender.Designer).cmdInFolder_Click(Sender)
End Sub
Private Sub frmOptions.cmdInFolder_Click(ByRef Sender As Control)
	BrowsD.InitialDir = GetFullPath(txtInFolder.Text)
	If BrowsD.Execute Then
		txtInFolder.Text = BrowsD.Directory
	End If
End Sub

Private Sub frmOptions.chkCreateNonStaticEventHandlers_Click(ByRef Sender As CheckBox)
	chkPlaceStaticEventHandlersAfterTheConstructor.Enabled = chkCreateNonStaticEventHandlers.Checked
	chkCreateStaticEventHandlersWithAnUnderscoreAtTheBeginning.Enabled = chkCreateNonStaticEventHandlers.Checked
End Sub
