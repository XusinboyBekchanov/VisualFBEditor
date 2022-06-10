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
		'This.Caption = ML("Options")
		This.CancelButton = @cmdCancel
		'This.DefaultButton = @cmdOK
		This.Designer = @This
		This.BorderStyle = FormBorderStyle.FixedDialog
		' tvOptions
		tvOptions.Name = "tvOptions"
		tvOptions.Text = "TreeView1"
		tvOptions.Align = DockStyle.alLeft
		tvOptions.ExtraMargins.Top = 10
		tvOptions.ExtraMargins.Left = 10
		tvOptions.ExtraMargins.Bottom = 10
		tvOptions.SetBounds 10, 10, 178, 397
		tvOptions.HideSelection = False
		tvOptions.OnSelChanged = @TreeView1_SelChange
		tvOptions.Parent = @This
		' cmdOK
		cmdOK.Name = "cmdOK"
		cmdOK.Text = ML("OK")
		cmdOK.Default = True
		cmdOK.SetBounds 347, 427, 90, 24
		cmdOK.OnClick = @cmdOK_Click
		'cmdOK.Caption = ML("OK")
		cmdOK.Parent = @This
		' cmdCancel
		cmdCancel.Name = "cmdCancel"
		cmdCancel.Text = ML("Cancel")
		cmdCancel.SetBounds 436, 427, 90, 24
		cmdCancel.OnClick = @cmdCancel_Click
		cmdCancel.Parent = @This
		' cmdApply
		cmdApply.Name = "cmdApply"
		cmdApply.Text = ML("Apply")
		cmdApply.SetBounds 525, 427, 90, 24
		cmdApply.OnClick = @cmdApply_Click
		cmdApply.Parent = @This
		' lblWhite
		lblWhite.Name = "lblWhite"
		lblWhite.Text = ""
		lblWhite.BackColor = 16777215
		lblWhite.ExtraMargins.Left = 10
		lblWhite.ExtraMargins.Right = 10
		lblWhite.ExtraMargins.Bottom = 40
		lblWhite.Align = DockStyle.alBottom
		lblWhite.SetBounds 10, 418, 604, 2
		lblWhite.Parent = @This
		' lblBlack
		lblBlack.Name = "lblBlack"
		lblBlack.Text = ""
		lblBlack.BorderStyle = 2
		lblBlack.BackColor = 8421504
		lblBlack.ExtraMargins.Right = 11
		lblBlack.ExtraMargins.Left = 10
		lblBlack.Align = DockStyle.alBottom
		lblBlack.ExtraMargins.Bottom = -1
		lblBlack.SetBounds 10, 417, 603, 1
		lblBlack.Parent = @This
		' pnlGeneral
		pnlGeneral.Name = "pnlGeneral"
		pnlGeneral.Text = ""
		pnlGeneral.Margins.Left = 10
		pnlGeneral.ExtraMargins.Top = 4
		pnlGeneral.ExtraMargins.Bottom = 9
		pnlGeneral.ExtraMargins.Right = 10
		pnlGeneral.Align = DockStyle.alClient
		pnlGeneral.Margins.Top = 0
		pnlGeneral.SetBounds 188, -6, 426, 404
		pnlGeneral.Parent = @This
		' pnlCodeEditor
		pnlCodeEditor.Name = "pnlCodeEditor"
		pnlCodeEditor.Text = ""
		pnlCodeEditor.ExtraMargins.Top = 4
		pnlCodeEditor.ExtraMargins.Bottom = 9
		pnlCodeEditor.ExtraMargins.Right = 10
		pnlCodeEditor.Margins.Left = 10
		pnlCodeEditor.Align = DockStyle.alClient
		pnlCodeEditor.SetBounds 187, 4, 426, 404
		pnlCodeEditor.Parent = @This
		' pnlColorsAndFonts
		pnlColorsAndFonts.Name = "pnlColorsAndFonts"
		pnlColorsAndFonts.Text = ""
		pnlColorsAndFonts.ExtraMargins.Top = 4
		pnlColorsAndFonts.ExtraMargins.Right = 10
		pnlColorsAndFonts.ExtraMargins.Bottom = 9
		pnlColorsAndFonts.Margins.Left = 10
		pnlColorsAndFonts.Align = DockStyle.alClient
		pnlColorsAndFonts.SetBounds 188, 4, 426, 404
		pnlColorsAndFonts.Parent = @This
		' pnlCompiler
		pnlCompiler.Name = "pnlCompiler"
		pnlCompiler.Text = ""
		pnlCompiler.Align = DockStyle.alClient
		pnlCompiler.ExtraMargins.Bottom = 9
		pnlCompiler.ExtraMargins.Top = 4
		pnlCompiler.ExtraMargins.Right = 10
		pnlCompiler.Margins.Left = 10
		pnlCompiler.SetBounds 188, 4, 426, 404
		pnlCompiler.Parent = @This
		' pnlMake
		pnlMake.Name = "pnlMake"
		pnlMake.Text = ""
		pnlMake.ExtraMargins.Top = 4
		pnlMake.ExtraMargins.Bottom = 9
		pnlMake.ExtraMargins.Right = 10
		pnlMake.Margins.Left = 10
		pnlMake.Align = DockStyle.alClient
		pnlMake.SetBounds 188, 4, 426, 404
		pnlMake.Parent = @This
		' pnlDebugger
		pnlDebugger.Name = "pnlDebugger"
		pnlDebugger.Text = ""
		pnlDebugger.ExtraMargins.Top = 4
		pnlDebugger.ExtraMargins.Bottom = 9
		pnlDebugger.ExtraMargins.Right = 10
		pnlDebugger.Margins.Left = 10
		pnlDebugger.Align = DockStyle.alClient
		pnlDebugger.SetBounds 188, 4, 426, 404
		pnlDebugger.Parent = @This
		' pnlTerminal
		pnlTerminal.Name = "pnlTerminal"
		pnlTerminal.Text = ""
		pnlTerminal.Margins.Left = 10
		pnlTerminal.ExtraMargins.Top = 4
		pnlTerminal.ExtraMargins.Right = 10
		pnlTerminal.ExtraMargins.Bottom = 9
		pnlTerminal.Align = DockStyle.alClient
		pnlTerminal.SetBounds 188, 4, 426, 404
		pnlTerminal.Parent = @This
		' pnlDesigner
		pnlDesigner.Name = "pnlDesigner"
		pnlDesigner.Text = ""
		pnlDesigner.ExtraMargins.Top = 4
		pnlDesigner.ExtraMargins.Right = 10
		pnlDesigner.ExtraMargins.Bottom = 9
		pnlDesigner.Align = DockStyle.alClient
		pnlDesigner.Margins.Left = 10
		pnlDesigner.SetBounds 188, 4, 426, 404
		pnlDesigner.Parent = @This
		' pnlLocalization
		pnlLocalization.Name = "pnlLocalization"
		pnlLocalization.Text = ""
		pnlLocalization.ExtraMargins.Top = 4
		pnlLocalization.ExtraMargins.Bottom = 9
		pnlLocalization.ExtraMargins.Right = 10
		pnlLocalization.Align = DockStyle.alClient
		pnlLocalization.Margins.Left = 10
		pnlLocalization.SetBounds 188, 4, 426, 404
		pnlLocalization.Parent = @This
		' pnlThemes
		pnlThemes.Name = "pnlThemes"
		pnlThemes.Text = ""
		pnlThemes.ExtraMargins.Top = 4
		pnlThemes.ExtraMargins.Bottom = 9
		pnlThemes.ExtraMargins.Right = 10
		pnlThemes.Margins.Left = 10
		pnlThemes.Align = DockStyle.alClient
		pnlThemes.SetBounds 188, 4, 426, 404
		pnlThemes.Parent = @This
		' pnlShortcuts
		pnlShortcuts.Name = "pnlShortcuts"
		pnlShortcuts.Text = ""
		pnlShortcuts.Margins.Left = 10
		pnlShortcuts.Margins.Right = 0
		pnlShortcuts.ExtraMargins.Bottom = 9
		pnlShortcuts.ExtraMargins.Top = 4
		pnlShortcuts.ExtraMargins.Right = 10
		pnlShortcuts.Align = DockStyle.alClient
		pnlShortcuts.SetBounds 188, 4, 426, 404
		pnlShortcuts.Parent = @This
		' pnlHelp
		pnlHelp.Name = "pnlHelp"
		pnlHelp.Text = ""
		pnlHelp.ExtraMargins.Top = 4
		pnlHelp.ExtraMargins.Right = 10
		pnlHelp.ExtraMargins.Bottom = 9
		pnlHelp.Margins.Left = 10
		pnlHelp.Align = DockStyle.alClient
		pnlHelp.SetBounds 188, 4, 426, 404
		pnlHelp.Parent = @This
		' pnlOtherEditors
		pnlOtherEditors.Name = "pnlOtherEditors"
		pnlOtherEditors.Text = ""
		pnlOtherEditors.ExtraMargins.Right = 10
		pnlOtherEditors.Align = DockStyle.alClient
		pnlOtherEditors.ExtraMargins.Bottom = 9
		pnlOtherEditors.ExtraMargins.Top = 4
		pnlOtherEditors.SetBounds 188, 4, 426, 404
		pnlOtherEditors.Parent = @This
		' grbDefaultCompilers
		With grbDefaultCompilers
			.Name = "grbDefaultCompilers"
			.Text = ML("Default Compilers")
			.Align = DockStyle.alTop
			.ExtraMargins.Left = 0
			.Margins.Top = 20
			.Margins.Right = 15
			.Margins.Left = 15
			.Margins.Bottom = 15
			.SetBounds 10, 0, 416, 128
			.Parent = @pnlCompiler
		End With
		' grbShortcuts
		With grbShortcuts
			.Name = "grbShortcuts"
			.Text = ML("Shortcuts")
			.Align = DockStyle.alClient
			.Margins.Top = 22
			.Margins.Right = 15
			.Margins.Left = 15
			.Margins.Bottom = 15
			.SetBounds 10, 0, 416, 404
			.Parent = @pnlShortcuts
		End With
		' grbCompilerPaths
		With grbCompilerPaths
			.Name = "grbCompilerPaths"
			.Text = ML("Compiler Paths")
			.ExtraMargins.Left = 0
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 5
			.Margins.Top = 20
			.Margins.Right = 15
			.Margins.Left = 15
			.Margins.Bottom = 15
			.SetBounds 10, 133, 416, 271
			.Parent = @pnlCompiler
		End With
		' lblShortcut
		lblShortcut.Name = "lblShortcut"
		lblShortcut.Text = ML("Select shortcut") & ":"
		lblShortcut.ExtraMargins.Right = 250
		lblShortcut.Align = DockStyle.alBottom
		lblShortcut.SetBounds 15, 371, 136, 18
		lblShortcut.Parent = @grbShortcuts
		' hkShortcut
		hkShortcut.Name = "hkShortcut"
		hkShortcut.ExtraMargins.Left = 130
		hkShortcut.ExtraMargins.Bottom = -18
		hkShortcut.ExtraMargins.Right = 60
		hkShortcut.Align = DockStyle.alBottom
		hkShortcut.SetBounds 145, 369, 196, 19
		hkShortcut.Parent = @grbShortcuts
		' cmdSetShortcut
		cmdSetShortcut.Name = "cmdSetShortcut"
		cmdSetShortcut.Text = ML("Set")
		cmdSetShortcut.ExtraMargins.Bottom = -20
		cmdSetShortcut.ExtraMargins.Right = -1
		cmdSetShortcut.ExtraMargins.Left = 330
		cmdSetShortcut.Align = DockStyle.alBottom
		cmdSetShortcut.SetBounds 345, 369, 57, 21
		cmdSetShortcut.OnClick = @cmdSetShortcut_Click
		cmdSetShortcut.Parent = @grbShortcuts
		' lvShortcuts
		With lvShortcuts
			.Name = "lvShortcuts"
			.Text = "lvShortcuts"
			.Align = DockStyle.alClient
			.ExtraMargins.Bottom = 15
			.SetBounds 15, 22, 386, 332
			.OnSelectedItemChanged = @lvShortcuts_SelectedItemChanged
			.Parent = @grbShortcuts
		End With
		' grbDefaultDebuggers
		With grbDefaultDebuggers
			.Name = "grbDefaultDebuggers"
			.Text = ML("Default Debuggers")
			.Align = DockStyle.alTop
			.SetBounds 10, 0, 416, 128
			.Parent = @pnlDebugger
		End With
		' grbDebuggerPaths
		With grbDebuggerPaths
			.Name = "grbDebuggerPaths"
			.Text = ML("Debugger Paths")
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 5
			.Margins.Top = 22
			.Margins.Right = 15
			.Margins.Left = 15
			.Margins.Bottom = 15
			.SetBounds 10, 203, 416, 201
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
			.Align = DockStyle.alTop
			.SetBounds 10, 0, 416, 64
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
			.ExtraMargins.Top = 5
			.Align = DockStyle.alClient
			.Margins.Top = 22
			.Margins.Right = 15
			.Margins.Left = 15
			.Margins.Bottom = 15
			.SetBounds 10, 168, 416, 236
			.Parent = @pnlTerminal
		End With
		' lvTerminalPath
		With lvTerminalPaths
			.Name = "lvTerminalPaths"
			.Text = "lvTerminalPaths"
			.ExtraMargins.Bottom = 15
			.Align = DockStyle.alClient
			.SetBounds 15, 22, 386, 160
			.Designer = @This
			.OnItemActivate = @lvTerminalPaths_ItemActivate_
			.Parent = @grbTerminalPaths
		End With
		' cmdAddTerminal
		With cmdAddTerminal
			.Name = "cmdAddTerminal"
			.Text = ML("&Add")
			.ExtraMargins.Left = -1
			.ExtraMargins.Right = 290
			.Align = DockStyle.alBottom
			.SetBounds 14, 197, 97, 24
			.OnClick = @cmdAddTerminal_Click
			.Parent = @grbTerminalPaths
		End With
		' cmdRemoveTerminal
		With cmdRemoveTerminal
			.Name = "cmdRemoveTerminal"
			.Text = ML("&Remove")
			.ExtraMargins.Right = 96
			.ExtraMargins.Left = 193
			.ExtraMargins.Bottom = -24
			.Align = DockStyle.alBottom
			.SetBounds 208, 197, 97, 24
			.OnClick = @cmdRemoveTerminal_Click
			.Parent = @grbTerminalPaths
		End With
		' cmdClearDebuggers1
		With cmdClearTerminals
			.Name = "cmdClearTerminals"
			.Text = ML("&Clear")
			.ExtraMargins.Right = -1
			.ExtraMargins.Left = 290
			.ExtraMargins.Bottom = -24
			.Align = DockStyle.alBottom
			.SetBounds 305, 197, 97, 24
			.OnClick = @cmdClearTerminals_Click
			.Parent = @grbTerminalPaths
		End With
		' grbLanguage
		With grbLanguage
			.Name = "grbLanguage"
			.Text = ML("Language")
			.Align = DockStyle.alClient
			.Margins.Top = 22
			.Margins.Right = 15
			.Margins.Left = 15
			.Margins.Bottom = 15
			.SetBounds 10, 0, 416, 404
			.Parent = @pnlLocalization
		End With
		' grbThemes
		With grbThemes
			.Name = "grbThemes"
			.Text = ML("Themes")
			.Align = DockStyle.alClient
			.SetBounds 10, 0, 416, 404
			.Parent = @pnlThemes
		End With
		' cboLanguage
		cboLanguage.Name = "cboLanguage"
		'ComboBoxEdit1.Text = "russian"
		cboLanguage.Align = DockStyle.alTop
		cboLanguage.ExtraMargins.Right = 140
		cboLanguage.SetBounds 15, 22, 246, 21
		cboLanguage.Parent = @grbLanguage
		' cmdAddCompiler
		cmdAddCompiler.Name = "cmdAddCompiler"
		cmdAddCompiler.Text = ML("&Add")
		cmdAddCompiler.ExtraMargins.Left = -1
		cmdAddCompiler.ExtraMargins.Bottom = 0
		cmdAddCompiler.ExtraMargins.Right = 290
		cmdAddCompiler.Align = DockStyle.alBottom
		cmdAddCompiler.SetBounds 14, 222, 97, 24
		cmdAddCompiler.OnClick = @cmdAddCompiler_Click
		cmdAddCompiler.Parent = @grbCompilerPaths
		' CheckBox1
		CheckBox1.Name = "CheckBox1"
		CheckBox1.Text = ML("Auto increment version")
		CheckBox1.Align = DockStyle.alTop
		CheckBox1.ExtraMargins.Top = 5
		CheckBox1.SetBounds 10, 5, 416, 18
		CheckBox1.Parent = @pnlGeneral
		' chkAutoCreateRC
		chkAutoCreateRC.Name = "chkAutoCreateRC"
		chkAutoCreateRC.Text = ML("Auto create resource and manifest files (.rc, .xml)")
		chkAutoCreateRC.ExtraMargins.Top = 5
		chkAutoCreateRC.Align = DockStyle.alTop
		chkAutoCreateRC.SetBounds 10, 28, 416, 18
		chkAutoCreateRC.Parent = @pnlGeneral
		' pnlIncludes
		pnlIncludes.Name = "pnlIncludes"
		pnlIncludes.ExtraMargins.Bottom = 9
		pnlIncludes.ExtraMargins.Right = 10
		pnlIncludes.Align = DockStyle.alClient
		pnlIncludes.ExtraMargins.Top = 4
		pnlIncludes.SetBounds 188, 4, 426, 404
		pnlIncludes.Text = ""
		pnlIncludes.Parent = @This
		' grbIncludePaths
		With grbIncludePaths
			.Name = "grbIncludePaths"
			.Text = ML("Include Paths")
			.Align = DockStyle.alClient
			.ExtraMargins.Left = 10
			.Margins.Top = 23
			.Margins.Right = 15
			.Margins.Left = 15
			.Margins.Bottom = 15
			.SetBounds 10, 0, 416, 218
			.Parent = @pnlIncludes
		End With
		' grbLibraryPaths
		With grbLibraryPaths
			.Name = "grbLibraryPaths"
			.Text = ML("Library Paths")
			.Align = DockStyle.alBottom
			.ExtraMargins.Left = 10
			.ExtraMargins.Top = 8
			.Margins.Top = 20
			.Margins.Right = 15
			.Margins.Left = 15
			.Margins.Bottom = 15
			.SetBounds 10, 226, 416, 178
			.Parent = @pnlIncludes
		End With
		' pnlIncludeMFFPath
		With pnlIncludeMFFPath
			.Name = "pnlIncludeMFFPath"
			.Text = ""
			.Align = DockStyle.alTop
			.SetBounds 15, 68, 386, 16
			.Parent = @grbIncludePaths
		End With
		' chkIncludeMFFPath
		With chkIncludeMFFPath
			.Name = "chkIncludeMFFPath"
			.Text = ML("Include MFF Path") & ":"
			.Align = DockStyle.alNone
			.SetBounds 0, -2, 152, 18
			.Parent = @pnlIncludeMFFPath
		End With
		' txtMFFpath
		txtMFFpath.Name = "txtMFFpath"
		txtMFFpath.Align = DockStyle.alTop
		txtMFFpath.ExtraMargins.Left = 150
		txtMFFpath.ExtraMargins.Right = 24
		txtMFFpath.ExtraMargins.Top = -18
		txtMFFpath.SetBounds 165, 21, 212, 20
		txtMFFpath.Parent = @grbIncludePaths
		' cmdMFFPath
		cmdMFFPath.Name = "cmdMFFPath"
		cmdMFFPath.Text = "..."
		cmdMFFPath.SetBounds 377, 20, 24, 22
		cmdMFFPath.OnClick = @cmdMFFPath_Click
		cmdMFFPath.Parent = @grbIncludePaths
		' chkAutoIndentation
		chkAutoIndentation.Name = "chkAutoIndentation"
		chkAutoIndentation.Text = ML("Auto Indentation")
		chkAutoIndentation.ExtraMargins.Top = 2
		chkAutoIndentation.Align = DockStyle.alTop
		chkAutoIndentation.SetBounds 10, 2, 416, 21
		chkAutoIndentation.Parent = @pnlCodeEditor
		' chkEnableAutoComplete
		chkEnableAutoComplete.Name = "chkEnableAutoComplete"
		chkEnableAutoComplete.Text = ML("Enable Auto Complete")
		chkEnableAutoComplete.ExtraMargins.Top = 0
		chkEnableAutoComplete.Align = DockStyle.alTop
		chkEnableAutoComplete.SetBounds 10, 23, 416, 21
		chkEnableAutoComplete.Parent = @pnlCodeEditor
		' chkShowSpaces
		chkShowSpaces.Name = "chkShowSpaces"
		chkShowSpaces.Text = ML("Show Spaces")
		chkShowSpaces.Align = DockStyle.alTop
		chkShowSpaces.ExtraMargins.Top = 0
		chkShowSpaces.SetBounds 10, 46, 416, 21
		chkShowSpaces.Parent = @pnlCodeEditor
		' chkShowKeywordsTooltip
		With chkShowKeywordsTooltip
			.Name = "chkShowKeywordsTooltip"
			.Text = ML("Show Keywords Tooltip")
			.TabIndex = 170
			.ExtraMargins.Top = 0
			.Align = DockStyle.alTop
			.SetBounds 10, 69, 416, 21
			'.Caption = ML("Show Keywords Tooltip")
			.Parent = @pnlCodeEditor
		End With
		' chkShowTooltipsAtTheTop
		With chkShowTooltipsAtTheTop
			.Name = "chkShowTooltipsAtTheTop"
			.Text = ML("Show Tooltips at the Top")
			.TabIndex = 192
			.ExtraMargins.Top = 0
			.Align = DockStyle.alTop
			.SetBounds 10, 92, 416, 21
			.Designer = @This
			.Parent = @pnlCodeEditor
		End With
		' chkHighlightCurrentWord
		With chkHighlightCurrentWord
			.Name = "chkHighlightCurrentWord"
			.Text = ML("Highlight Current Word")
			.ExtraMargins.Top = 0
			.Align = DockStyle.alTop
			.SetBounds 10, 115, 416, 21
			.Parent = @pnlCodeEditor
		End With
		' chkHighlightCurrentLine
		With chkHighlightCurrentLine
			.Name = "chkHighlightCurrentLine"
			.Text = ML("Highlight Current Line")
			.ExtraMargins.Top = 0
			.Align = DockStyle.alTop
			.SetBounds 10, 138, 416, 21
			.Parent = @pnlCodeEditor
		End With
		' chkHighlightBrackets
		With chkHighlightBrackets
			.Name = "chkHighlightBrackets"
			.Text = ML("Highlight Brackets")
			.ExtraMargins.Top = 0
			.Align = DockStyle.alTop
			.SetBounds 10, 161, 416, 21
			.Parent = @pnlCodeEditor
		End With
		' chkAddSpacesToOperators
		With chkAddSpacesToOperators
			.Name = "chkAddSpacesToOperators"
			.Text = ML("Add Spaces To Operators")
			.TabIndex = 171
			.ExtraMargins.Top = 0
			.Align = DockStyle.alTop
			.SetBounds 10, 181, 416, 21
			'.Caption = ML("Add Spaces To Operators")
			.Parent = @pnlCodeEditor
		End With
		' chkChangeIdentifiersCase
		With chkChangeIdentifiersCase
			.Name = "chkChangeIdentifiersCase"
			.Text = ML("Change Identifiers Case")
			.TabIndex = 200
			.Align = DockStyle.alTop
			.Caption = ML("Change Identifiers Case")
			.ExtraMargins.Top = 0
			.SetBounds 10, 201, 416, 21
			.Designer = @This
			.Parent = @pnlCodeEditor
		End With
		' chkChangeKeywordsCase
		chkChangeKeywordsCase.Name = "chkChangeKeywordsCase"
		chkChangeKeywordsCase.Text = ML("Change Keywords Case To") & ":"
		chkChangeKeywordsCase.ExtraMargins.Top = 0
		chkChangeKeywordsCase.Align = DockStyle.alTop
		chkChangeKeywordsCase.ExtraMargins.Right = 230
		chkChangeKeywordsCase.SetBounds 10, 221, 186, 21
		chkChangeKeywordsCase.Parent = @pnlCodeEditor
		' cboCase
		cboCase.Name = "cboCase"
		cboCase.Text = "ComboBoxEdit2"
		cboCase.ExtraMargins.Right = 50
		cboCase.ExtraMargins.Top = -21
		cboCase.ExtraMargins.Left = 200
		cboCase.Align = DockStyle.alTop
		cboCase.SetBounds 210, 212, 166, 21
		cboCase.Parent = @pnlCodeEditor
		' chkTabAsSpaces
		chkTabAsSpaces.Name = "chkTabAsSpaces"
		chkTabAsSpaces.Text = ML("Treat Tab as Spaces")
		chkTabAsSpaces.ExtraMargins.Top = 0
		chkTabAsSpaces.Align = DockStyle.alTop
		chkTabAsSpaces.ExtraMargins.Right = 230
		chkTabAsSpaces.SetBounds 10, 244, 186, 21
		chkTabAsSpaces.Parent = @pnlCodeEditor
		' cboTabStyle
		cboTabStyle.Name = "cboTabStyle"
		cboTabStyle.Text = "cboCase1"
		cboTabStyle.ExtraMargins.Left = 200
		cboTabStyle.ExtraMargins.Right = 50
		cboTabStyle.Align = DockStyle.alTop
		cboTabStyle.ExtraMargins.Top = -19
		cboTabStyle.SetBounds 210, 238, 166, 21
		cboTabStyle.Parent = @pnlCodeEditor
		' lblTabSize
		lblTabSize.Name = "lblTabSize"
		lblTabSize.Text = ML("Tab Size") & ":"
		lblTabSize.ExtraMargins.Left = 60
		lblTabSize.ExtraMargins.Right = 230
		lblTabSize.Align = DockStyle.alTop
		lblTabSize.ExtraMargins.Top = 2
		lblTabSize.SetBounds 70, 262, 126, 18
		lblTabSize.Parent = @pnlCodeEditor
		' txtTabSize
		txtTabSize.Name = "txtTabSize"
		txtTabSize.Text = ""
		txtTabSize.ExtraMargins.Left = 200
		txtTabSize.ExtraMargins.Right = 130
		txtTabSize.ExtraMargins.Top = -18
		txtTabSize.Align = DockStyle.alTop
		txtTabSize.SetBounds 210, 256, 86, 20
		txtTabSize.Parent = @pnlCodeEditor
		' lstIncludePaths
		lstIncludePaths.Name = "lstIncludePaths"
		lstIncludePaths.Text = "ListControl1"
		lstIncludePaths.Align = DockStyle.alClient
		lstIncludePaths.ExtraMargins.Right = 25
		lstIncludePaths.SetBounds 15, 68, 361, 134
		lstIncludePaths.Parent = @grbIncludePaths
		' lstLibraryPaths
		lstLibraryPaths.Name = "lstLibraryPaths"
		lstLibraryPaths.Text = "ListControl11"
		lstLibraryPaths.Align = DockStyle.alClient
		lstLibraryPaths.ExtraMargins.Right = 25
		lstLibraryPaths.ExtraMargins.Top = 2
		lstLibraryPaths.SetBounds 15, 22, 361, 134
		lstLibraryPaths.Parent = @grbLibraryPaths
		' lblOthers
		lblOthers.Name = "lblOthers"
		lblOthers.Text = ML("Others") & ":"
		lblOthers.Align = DockStyle.alTop
		lblOthers.ExtraMargins.Top = 5
		lblOthers.ExtraMargins.Bottom = 4
		lblOthers.SetBounds 15, 46, 386, 18
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
		' cmdChangeTerminal
		cmdChangeTerminal.Name = "cmdChangeTerminal"
		cmdChangeTerminal.Text = ML("Chan&ge")
		cmdChangeTerminal.ExtraMargins.Right = 193
		cmdChangeTerminal.ExtraMargins.Bottom = -24
		cmdChangeTerminal.ExtraMargins.Left = 96
		cmdChangeTerminal.Align = DockStyle.alBottom
		cmdChangeTerminal.SetBounds 111, 197, 97, 24
		cmdChangeTerminal.OnClick = @cmdChangeTerminal_Click
		cmdChangeTerminal.Parent = @grbTerminalPaths
		' lblHistoryLimit
		lblHistoryLimit.Name = "lblHistoryLimit"
		lblHistoryLimit.Text = ML("History limit") & ":"
		lblHistoryLimit.ExtraMargins.Top = 2
		lblHistoryLimit.ExtraMargins.Left = 60
		lblHistoryLimit.ExtraMargins.Right = 230
		lblHistoryLimit.Align = DockStyle.alTop
		lblHistoryLimit.SetBounds 70, 287, 126, 18
		lblHistoryLimit.Parent = @pnlCodeEditor
		' txtHistoryLimit
		txtHistoryLimit.Name = "txtHistoryLimit"
		txtHistoryLimit.ExtraMargins.Top = -18
		txtHistoryLimit.ExtraMargins.Right = 130
		txtHistoryLimit.ExtraMargins.Left = 200
		txtHistoryLimit.Align = DockStyle.alTop
		txtHistoryLimit.SetBounds 210, 253, 86, 20
		txtHistoryLimit.Text = ""
		txtHistoryLimit.Parent = @pnlCodeEditor
		' grbGrid
		grbGrid.Name = "grbGrid"
		grbGrid.Text = ML("Grid")
		grbGrid.Align = DockStyle.alTop
		grbGrid.SetBounds 10, 0, 416, 122
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
		' grbColors
		grbColors.Name = "grbColors"
		grbColors.Text = ML("Colors")
		grbColors.Align = DockStyle.alClient
		grbColors.Margins.Top = 21
		grbColors.Margins.Right = 15
		grbColors.Margins.Left = 15
		grbColors.Margins.Bottom = 15
		grbColors.SetBounds 10, 0, 416, 343
		grbColors.Parent = @pnlColorsAndFonts
		' grbFont
		grbFont.Name = "grbFont"
		grbFont.Text = ML("Font (applies to all styles)")
		grbFont.Align = DockStyle.alBottom
		grbFont.ExtraMargins.Top = 5
		grbFont.SetBounds 10, 348, 416, 56
		grbFont.Parent = @pnlColorsAndFonts
		' grbMakeToolPaths
		With grbMakeToolPaths
			.Name = "grbMakeToolPaths"
			.Text = ML("Make Tool Paths")
			.Align = DockStyle.alClient
			.Margins.Top = 22
			.Margins.Right = 15
			.Margins.Left = 15
			.Margins.Bottom = 15
			.SetBounds 10, 100, 416, 304
			.Parent = @pnlMake
		End With
		' lvMakeToolPaths
		With lvMakeToolPaths
			.Name = "lvMakeToolPaths"
			.Text = "lvMakeToolPaths"
			.Align = DockStyle.alClient
			.ExtraMargins.Bottom = 15
			.SetBounds 15, 22, 386, 228
			.Designer = @This
			.OnItemActivate = @lvMakeToolPaths_ItemActivate_
			.Parent = @grbMakeToolPaths
		End With
		' cmdAddMakeTool
		With cmdAddMakeTool
			.Name = "cmdAddMakeTool"
			.Text = ML("&Add")
			.ExtraMargins.Left = -1
			.ExtraMargins.Bottom = 0
			.ExtraMargins.Right = 290
			.Align = DockStyle.alBottom
			.SetBounds 14, 265, 97, 24
			.OnClick = @cmdAddMakeTool_Click
			.IsChild = True
			.ID = 1010
			.Parent = @grbMakeToolPaths
		End With
		' cmdRemoveMakeTool
		With cmdRemoveMakeTool
			.Name = "cmdRemoveMakeTool"
			.Text = ML("&Remove")
			.ExtraMargins.Right = 96
			.ExtraMargins.Left = 193
			.ExtraMargins.Bottom = -24
			.Align = DockStyle.alBottom
			.SetBounds 208, 265, 97, 24
			.OnClick = @cmdRemoveMakeTool_Click
			.Parent = @grbMakeToolPaths
		End With
		' cmdClearMakeTool
		With cmdClearMakeTools
			.Name = "cmdClearMakeTools"
			.Text = ML("&Clear")
			.ExtraMargins.Right = -1
			.ExtraMargins.Left = 290
			.ExtraMargins.Bottom = -24
			.Align = DockStyle.alBottom
			.SetBounds 305, 265, 97, 24
			.OnClick = @cmdClearMakeTools_Click
			.Parent = @grbMakeToolPaths
		End With
		' grbDefaultMakeTool
		With grbDefaultMakeTool
			.Name = "grbDefaultMakeTool"
			.Text = ML("Default Make Tool")
			.Align = DockStyle.alTop
			.Margins.Top = 20
			.Margins.Right = 15
			.Margins.Left = 15
			.Margins.Bottom = 15
			.SetBounds 10, 0, 416, 64
			.Parent = @pnlMake
		End With
		' cboMakeTool
		With cboMakeTool
			.Name = "cboMakeTool"
			.Text = "cboMakeTool"
			.Align = DockStyle.alBottom
			.SetBounds 15, 28, 386, 21
			.Parent = @grbDefaultMakeTool
		End With
		' cmdChangeMakeTool
		cmdChangeMakeTool.Name = "cmdChangeMakeTool"
		cmdChangeMakeTool.Text = ML("Chan&ge")
		cmdChangeMakeTool.ExtraMargins.Left = 96
		cmdChangeMakeTool.ExtraMargins.Right = 193
		cmdChangeMakeTool.ExtraMargins.Bottom = -24
		cmdChangeMakeTool.Align = DockStyle.alBottom
		cmdChangeMakeTool.SetBounds 111, 265, 97, 24
		cmdChangeMakeTool.OnClick = @cmdChangeMakeTool_Click
		cmdChangeMakeTool.Parent = @grbMakeToolPaths
		' cboTheme
		cboTheme.Name = "cboTheme"
		cboTheme.Text = "ComboBoxEdit2"
		cboTheme.Align = DockStyle.alTop
		cboTheme.ExtraMargins.Right = 160
		cboTheme.ExtraMargins.Bottom = 15
		cboTheme.SetBounds 15, 21, 226, 21
		cboTheme.OnChange = @cboTheme_Change
		cboTheme.Parent = @grbColors
		' lstColorKeys
		lstColorKeys.Name = "lstColorKeys"
		lstColorKeys.Text = "ListControl1"
		lstColorKeys.Align = DockStyle.alLeft
		lstColorKeys.SetBounds 15, 57, 226, 264
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
		txtProjectsPath.Align = DockStyle.alBottom
		txtProjectsPath.ExtraMargins.Bottom = 1
		txtProjectsPath.ExtraMargins.Right = 26
		txtProjectsPath.SetBounds 10, 383, 390, 20
		txtProjectsPath.Parent = @pnlGeneral
		' cmdProjectsPath
		cmdProjectsPath.Name = "cmdProjectsPath"
		cmdProjectsPath.Text = "..."
		cmdProjectsPath.Align = DockStyle.alBottom
		cmdProjectsPath.ExtraMargins.Bottom = -21
		cmdProjectsPath.ExtraMargins.Left = 392
		cmdProjectsPath.SetBounds 402, 382, 24, 22
		'cmdProjectsPath.Caption = "..."
		cmdProjectsPath.OnClick = @cmdProjectsPath_Click
		cmdProjectsPath.Parent = @pnlGeneral
		' lblProjectsPath
		lblProjectsPath.Name = "lblProjectsPath"
		lblProjectsPath.Text = ML("Projects path") & ":"
		lblProjectsPath.Align = DockStyle.alBottom
		lblProjectsPath.ExtraMargins.Top = 15
		lblProjectsPath.SetBounds 10, 366, 416, 16
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
		chkUseMakeOnStartWithCompile.Align = DockStyle.alTop
		chkUseMakeOnStartWithCompile.ExtraMargins.Top = 10
		chkUseMakeOnStartWithCompile.ExtraMargins.Bottom = 10
		chkUseMakeOnStartWithCompile.ExtraMargins.Left = 15
		chkUseMakeOnStartWithCompile.SetBounds 25, 74, 401, 16
		'chkUseMakeOnStartWithCompile.Caption = ML("Use make on start with compile (if exists makefile)")
		chkUseMakeOnStartWithCompile.Parent = @pnlMake
		' lvCompilerPaths
		With lvCompilerPaths
			.Name = "lvCompilerPaths"
			.Text = "ListView1"
			.Align = DockStyle.alClient
			.ExtraMargins.Left = 0
			.ExtraMargins.Right = 0
			.ExtraMargins.Bottom = 15
			.ExtraMargins.Top = 15
			.SetBounds 16, 57, 384, 160
			.Images = @imgList
			'.StateImages = @imgList
			.SmallImages = @imgList
			.Designer = @This
			.OnItemActivate = @lvCompilerPaths_ItemActivate_
			.Parent = @grbCompilerPaths
		End With
		' cboCompiler64
		With cboCompiler64
			.Name = "cboCompiler64"
			.Text = "ComboBoxEdit21"
			.Align = DockStyle.alBottom
			.SetBounds 15, 92, 386, 21
			.Parent = @grbDefaultCompilers
		End With
		' lblCompiler64
		lblCompiler64.Name = "lblCompiler64"
		lblCompiler64.Text = ML("Compiler") & " " & ML("64-bit")
		lblCompiler64.Align = DockStyle.alBottom
		lblCompiler64.ExtraMargins.Top = 10
		lblCompiler64.SetBounds 15, 74, 386, 18
		lblCompiler64.Parent = @grbDefaultCompilers
		' cboCompiler32
		With cboCompiler32
			.Name = "cboCompiler32"
			.Text = "ComboBoxEdit2"
			.Align = DockStyle.alBottom
			.SetBounds 15, 92, 386, 21
			.Parent = @grbDefaultCompilers
		End With
		' lblCompiler32
		lblCompiler32.Name = "lblCompiler32"
		lblCompiler32.Text = ML("Compiler") & " " & ML("32-bit")
		lblCompiler32.Align = DockStyle.alBottom
		lblCompiler32.SetBounds 15, 74, 386, 18
		lblCompiler32.Parent = @grbDefaultCompilers
		' cmdRemoveCompiler
		With cmdRemoveCompiler
			.Name = "cmdRemoveCompiler"
			.Text = ML("&Remove")
			.ExtraMargins.Bottom = -24
			.ExtraMargins.Right = 96
			.ExtraMargins.Left = 193
			.Align = DockStyle.alBottom
			.SetBounds 209, 232, 96, 24
			.OnClick = @cmdRemoveCompiler_Click
			.Parent = @grbCompilerPaths
		End With
		' cmdClearCompilers
		With cmdClearCompilers
			.Name = "cmdClearCompilers"
			.Text = ML("&Clear")
			.ExtraMargins.Right = -1
			.ExtraMargins.Left = 290
			.ExtraMargins.Bottom = -24
			.Align = DockStyle.alBottom
			.SetBounds 305, 232, 97, 24
			.OnClick = @cmdClearCompilers_Click
			.Parent = @grbCompilerPaths
		End With
		' lvDebuggerPaths
		With lvDebuggerPaths
			.Name = "lvDebuggerPaths"
			.Text = "lvCompilerPaths1"
			.Align = DockStyle.alClient
			.ExtraMargins.Bottom = 15
			.SetBounds 15, 22, 386, 125
			.Designer = @This
			.OnItemActivate = @lvDebuggerPaths_ItemActivate_
			.Parent = @grbDebuggerPaths
		End With
		' cmdAddDebugger
		With cmdAddDebugger
			.Name = "cmdAddDebugger"
			.Text = ML("&Add")
			.ExtraMargins.Left = -1
			.ExtraMargins.Right = 290
			.Align = DockStyle.alBottom
			.SetBounds 14, 162, 97, 24
			.OnClick = @cmdAddDebugger_Click
			.Parent = @grbDebuggerPaths
		End With
		' cmdChangeDebugger
		cmdChangeDebugger.Name = "cmdChangeDebugger"
		cmdChangeDebugger.Text = ML("Chan&ge")
		cmdChangeDebugger.ExtraMargins.Left = 96
		cmdChangeDebugger.ExtraMargins.Right = 193
		cmdChangeDebugger.Align = DockStyle.alBottom
		cmdChangeDebugger.ExtraMargins.Bottom = -24
		cmdChangeDebugger.SetBounds 111, 186, 97, 24
		cmdChangeDebugger.OnClick = @cmdChangeDebugger_Click
		cmdChangeDebugger.Parent = @grbDebuggerPaths
		' cmdRemoveDebugger
		With cmdRemoveDebugger
			.Name = "cmdRemoveDebugger"
			.Text = ML("&Remove")
			.ExtraMargins.Right = 96
			.ExtraMargins.Left = 193
			.ExtraMargins.Bottom = -24
			.Align = DockStyle.alBottom
			.SetBounds 208, 162, 97, 24
			.OnClick = @cmdRemoveDebugger_Click
			.Parent = @grbDebuggerPaths
		End With
		' cmdClearDebuggers
		With cmdClearDebuggers
			.Name = "cmdClearDebuggers"
			.Text = ML("&Clear")
			.ExtraMargins.Bottom = -24
			.ExtraMargins.Right = -1
			.ExtraMargins.Left = 290
			.Align = DockStyle.alBottom
			.SetBounds 305, 162, 97, 24
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
			.Align = DockStyle.alTop
			.SetBounds 0, 0, 340, 20
			.Parent = @pnlThemesCheckboxes
		End With
		' chkShowMainToolbar
		With chkShowMainToolbar
			.Name = "chkShowMainToolbar"
			.Text = ML("Show main Toolbar")
			.Align = DockStyle.alTop
			.SetBounds 0, 18, 340, 20
			.Parent = @pnlThemesCheckboxes
		End With
		'chkShowToolBoxLocal
		With chkShowToolBoxLocal
			.Name = "chkShowToolBoxLocal"
			.Text = ML("Display ToolBox in localized language.")
			.Align = DockStyle.alTop
			.SetBounds 0, 36, 340, 20
			.Parent = @pnlThemesCheckboxes
		End With
		'chkShowPropLocal
		With chkShowPropLocal
			.Name = "chkShowPropLocal"
			.Text = ML("Display Property of Control in localized language.")
			.Align = DockStyle.alTop
			.SetBounds 0, 60, 340, 20
			.Parent = @pnlThemesCheckboxes
		End With
		' chkAutoCreateBakFiles
		With chkAutoCreateBakFiles
			.Name = "chkAutoCreateBakFiles"
			.Text = ML("Auto create bak files before saving")
			.ExtraMargins.Top = 5
			.Align = DockStyle.alTop
			.SetBounds 10, 51, 416, 18
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
		' cmdChangeCompiler
		With cmdChangeCompiler
			.Name = "cmdChangeCompiler"
			.Text = ML("Chan&ge")
			.ExtraMargins.Bottom = -24
			.ExtraMargins.Left = 96
			.ExtraMargins.Right = 193
			.Align = DockStyle.alBottom
			.SetBounds 111, 232, 97, 24
			.OnClick = @cmdChangeCompiler_Click
			.Parent = @grbCompilerPaths
		End With
		' grbDefaultHelp
		With grbDefaultHelp
			.Name = "grbDefaultHelp"
			.Text = ML("Default Help")
			.Align = DockStyle.alTop
			.Margins.Top = 22
			.Margins.Left = 15
			.Margins.Bottom = 18
			.Margins.Right = 15
			.SetBounds 10, 0, 416, 64
			.Parent = @pnlHelp
		End With
		' cboHelp
		With cboHelp
			.Name = "cboHelp"
			.Text = "cboHelp"
			.Align = DockStyle.alBottom
			.SetBounds 15, 25, 386, 21
			.Parent = @grbDefaultHelp
		End With
		' grbHelpPaths
		With grbHelpPaths
			.Name = "grbHelpPaths"
			.Text = ML("Help Paths")
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 5
			.Margins.Top = 22
			.Margins.Right = 15
			.Margins.Left = 15
			.Margins.Bottom = 15
			.SetBounds 10, 69, 416, 335
			.Parent = @pnlHelp
		End With
		' lvHelpPaths
		With lvHelpPaths
			.Name = "lvHelpPaths"
			.Text = "lvTerminalPaths1"
			.ExtraMargins.Bottom = 15
			.Align = DockStyle.alClient
			.SetBounds 15, 22, 386, 259
			.Designer = @This
			.OnItemActivate = @lvHelpPaths_ItemActivate_
			.Parent = @grbHelpPaths
		End With
		' cmdAddHelp
		With cmdAddHelp
			.Name = "cmdAddHelp"
			.Text = ML("&Add")
			.ExtraMargins.Right = 290
			.ExtraMargins.Left = -1
			.Align = DockStyle.alBottom
			.SetBounds 14, 296, 97, 24
			.OnClick = @cmdAddHelp_Click
			.Parent = @grbHelpPaths
		End With
		' cmdChangeHelp
		With cmdChangeHelp
			.Name = "cmdChangeHelp"
			.Text = ML("Chan&ge")
			.ExtraMargins.Bottom = -24
			.ExtraMargins.Left = 96
			.ExtraMargins.Right = 193
			.Align = DockStyle.alBottom
			.SetBounds 111, 296, 97, 24
			.OnClick = @cmdChangeHelp_Click
			.Parent = @grbHelpPaths
		End With
		' cmdRemoveHelp
		With cmdRemoveHelp
			.Name = "cmdRemoveHelp"
			.Text = ML("&Remove")
			.ExtraMargins.Right = 96
			.ExtraMargins.Left = 193
			.ExtraMargins.Bottom = -24
			.Align = DockStyle.alBottom
			.SetBounds 208, 296, 97, 24
			.OnClick = @cmdRemoveHelp_Click
			.Parent = @grbHelpPaths
		End With
		' cmdClearHelp
		With cmdClearHelps
			.Name = "cmdClearHelps"
			.Text = ML("&Clear")
			.ExtraMargins.Right = -1
			.ExtraMargins.Left = 290
			.ExtraMargins.Bottom = -24
			.Align = DockStyle.alBottom
			.SetBounds 305, 296, 97, 24
			.OnClick = @cmdClearHelps_Click
			.Parent = @grbHelpPaths
		End With
		' grbWhenCompiling
		With grbWhenCompiling
			.Name = "grbWhenCompiling"
			.Text = ML("When compiling") & ":"
			.Align = DockStyle.alBottom
			.ExtraMargins.Top = 5
			.SetBounds 10, 231, 416, 120
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
		' pnlThemesCheckboxes
		With pnlThemesCheckboxes
			.Name = "pnlThemesCheckboxes"
			.Text = "Panel2"
			.SetBounds 10, 63, 340, 198
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
			.Align = DockStyle.alTop
			.ExtraMargins.Top = 10
			.SetBounds 10, 138, 416, 16
			.Parent = @pnlDebugger
		End With
		' chkDisplayWarningsInDebug
		With chkDisplayWarningsInDebug
			.Name = "chkDisplayWarningsInDebug"
			.Text = ML("Display warnings in debug")
			.ExtraMargins.Top = 5
			.Align = DockStyle.alTop
			.SetBounds 10, 164, 416, 16
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
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 0
			.ExtraMargins.Left = 10
			.Margins.Top = 21
			.Margins.Right = 15
			.Margins.Left = 15
			.Margins.Bottom = 15
			.SetBounds 10, 0, 416, 404
			.Parent = @pnlOtherEditors
		End With
		' lvOtherEditors
		With lvOtherEditors
			.Name = "lvOtherEditors"
			.Text = "lvHelpPaths1"
			.ExtraMargins.Top = 0
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 0
			.Align = DockStyle.alClient
			.ExtraMargins.Bottom = 15
			.SetBounds 16, 21, 384, 329
			.Designer = @This
			.OnItemActivate = @lvOtherEditors_ItemActivate_
			.Parent = @grbOtherEditors
		End With
		' cmdAddEditor
		With cmdAddEditor
			.Name = "cmdAddEditor"
			.Text = ML("&Add")
			.Align = DockStyle.alBottom
			.ExtraMargins.Left = -1
			.ExtraMargins.Bottom = 0
			.ExtraMargins.Right = 290
			.SetBounds 15, 365, 98, 24
			'.Caption = "Add"
			.Designer = @This
			.OnClick = @cmdAddEditor_Click_
			.Parent = @grbOtherEditors
		End With
		' cmdChangeEditor
		With cmdChangeEditor
			.Name = "cmdChangeEditor"
			.Text = ML("Chan&ge")
			.Align = DockStyle.alBottom
			.ExtraMargins.Bottom = -24
			.ExtraMargins.Left = 96
			.ExtraMargins.Right = 193
			.SetBounds 113, 365, 96, 24
			'.Caption = "Change"
			.Designer = @This
			.OnClick = @cmdChangeEditor_Click_
			.Parent = @grbOtherEditors
		End With
		' cmdRemoveEditor
		With cmdRemoveEditor
			.Name = "cmdRemoveEditor"
			.Text = ML("&Remove")
			.Align = DockStyle.alBottom
			.ExtraMargins.Bottom = -24
			.ExtraMargins.Left = 193
			.ExtraMargins.Right = 96
			.SetBounds 208, 365, 97, 24
			'.Caption = "Remove"
			.Designer = @This
			.OnClick = @cmdRemoveEditor_Click_
			.Parent = @grbOtherEditors
		End With
		' cmdClearEditor
		With cmdClearEditor
			.Name = "cmdClearEditor"
			.Text = ML("&Clear")
			.ExtraMargins.Bottom = -24
			.ExtraMargins.Left = 290
			.ExtraMargins.Right = -1
			.Align = DockStyle.alBottom
			.SetBounds 305, 365, 96, 24
			'.Caption = "Clear"
			.Designer = @This
			.OnClick = @cmdClearEditor_Click_
			.Parent = @grbOtherEditors
		End With
		' grbWhenVFBEStarts
		With grbWhenVFBEStarts
			.Name = "grbWhenVFBEStarts"
			.Text = ML("When VisualFBEditor starts") & ":"
			.Align = DockStyle.alBottom
			.SetBounds 10, 116, 416, 120
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
			.Align = DockStyle.alTop
			.ExtraMargins.Left = 300
			.ExtraMargins.Right = -1
			.SetBounds 315, 20, 87, 24
			'.Caption = ML("&Find")
			.Designer = @This
			.OnClick = @cmdFindCompilers_Click_
			.Parent = @grbCompilerPaths
		End With
		' lblFindCompilersFromComputer
		With lblFindCompilersFromComputer
			.Name = "lblFindCompilersFromComputer"
			.Text = ML("Find Compilers from Computer?")
			.TabIndex = 168
			.ExtraMargins.Top = -22
			.ExtraMargins.Right = 100
			.Align = DockStyle.alTop
			.SetBounds 15, 22, 286, 20
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
			.Align = DockStyle.alTop
			.ExtraMargins.Top = 5
			.SetBounds 10, 69, 416, 94
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
			.ExtraMargins.Top = 2
			.ExtraMargins.Right = 230
			.ExtraMargins.Left = 60
			.Align = DockStyle.alTop
			.SetBounds 70, 312, 126, 18
			.Parent = @pnlCodeEditor
		End With
		' txtIntellisenseLimit
		With txtIntellisenseLimit
			.Name = "txtIntellisenseLimit"
			.TabIndex = 181
			.Text = ""
			.ExtraMargins.Left = 200
			.ExtraMargins.Top = -18
			.ExtraMargins.Right = 130
			.Align = DockStyle.alTop
			.SetBounds 210, 275, 86, 20
			.Parent = @pnlCodeEditor
		End With
		' chkTurnOnEnvironmentVariables
		With chkTurnOnEnvironmentVariables
			.Name = "chkTurnOnEnvironmentVariables"
			.Text = ML("Turn on Environment variables") & ":"
			.TabIndex = 184
			'.Caption = ML("Turn on Environment variables") & ":"
			.ExtraMargins.Top = 5
			.Align = DockStyle.alTop
			.ExtraMargins.Right = 170
			.SetBounds 10, 180, 246, 16
			.Parent = @pnlDebugger
		End With
		' txtEnvironmentVariables
		With txtEnvironmentVariables
			.Name = "txtEnvironmentVariables"
			.Text = ""
			.TabIndex = 182
			.Align = DockStyle.alTop
			.ExtraMargins.Top = -18
			.ExtraMargins.Left = 230
			.ExtraMargins.Right = 15
			.SetBounds 240, 178, 171, 20
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
			.Align = DockStyle.alTop
			.SetBounds 0, 84, 340, 20
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
			.ExtraMargins.Top = 5
			.Align = DockStyle.alTop
			.SetBounds 20, 72, 416, 18
			.Parent = @pnlGeneral
		End With
		' lblHistoryDay
		With lblHistoryDay
			.Name = "lblHistoryDay"
			.Text = ML("History file saving days")
			.TabIndex = 194
			.ExtraMargins.Top = 2
			.ExtraMargins.Right = 230
			.ExtraMargins.Left = 60
			.Align = DockStyle.alTop
			.SetBounds 70, 328, 126, 18
			.Designer = @This
			.Parent = @pnlCodeEditor
		End With
		' txtHistoryCodeDays
		With txtHistoryCodeDays
			.Name = "txtHistoryCodeDays"
			.Text = "3"
			.TabIndex = 193
			.ExtraMargins.Top = -18
			.ExtraMargins.Right = 130
			.ExtraMargins.Left = 200
			.Align = DockStyle.alTop
			.SetBounds 210, 277, 86, 20
			.Designer = @This
			.Parent = @pnlCodeEditor
		End With
		' cmdUpdateLng
		With cmdUpdateLng
			.Name = "cmdUpdateLng"
			.Text = ML("Scan and Update")
			.TabIndex = 195
			.Hint = ML("Scan the text string in source code and update languages files")
			.ExtraMargins.Top = -22
			.ExtraMargins.Left = 250
			.Align = DockStyle.alTop
			.SetBounds 265, 21, 136, 23
			.Designer = @This
			.OnClick = @cmdUpdateLng_Click_
			.Parent = @grbLanguage
		End With
		' chkAllLNG
		With chkAllLNG
			.Name = "chkAllLNG"
			.Text = ML("Update all language file.") & "(*.lng)"
			.TabIndex = 196
			.Checked = False
			.Align = DockStyle.alTop
			.ExtraMargins.Top = 5
			.SetBounds 30, 71, 386, 20
			.Designer = @This
			.Parent = @grbLanguage
		End With
		' cmdUpdateLngVFPFolds1
		' cmdUpdateLngHTMLFolds1
			'.Hint = ML("Supports batch replacement by Enter key separation.")
			
		' cmdReplaceInFiles
		' cmdReplaceInFiles1
		' lblShowMsg
		With lblShowMsg
			.Name = "lblShowMsg"
			.Text = ""
			.TabIndex = 197
			.Caption = ""
			.Align = DockStyle.alTop
			.ExtraMargins.Top = 10
			.SetBounds 15, 79, 386, 20
			.Designer = @This
			.Parent = @grbLanguage
		End With
	End Constructor
	
	Private Sub frmOptions.cmdUpdateLng_Click_(ByRef Sender As Control)
		*Cast(frmOptions Ptr, Sender.Designer).cmdUpdateLng_Click(Sender)
	End Sub
	
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
		.chkChangeIdentifiersCase.Checked = ChangeIdentifiersCase
		.chkChangeKeywordsCase.Checked = ChangeKeywordsCase
		.chkAddSpacesToOperators.Checked = AddSpacesToOperators
		.chkUseMakeOnStartWithCompile.Checked = UseMakeOnStartWithCompile
		.chkLimitDebug.Checked = LimitDebug
		.chkTurnOnEnvironmentVariables.Checked = TurnOnEnvironmentVariables
		.txtEnvironmentVariables.Text = *EnvironmentVariables
		.txtTabSize.Text = Str(TabWidth)
		.txtHistoryLimit.Text = Str(HistoryLimit)
		.txtIntellisenseLimit.Text = Str(IntellisenseLimit)
		.txtHistoryCodeDays.Text = Str(HistoryCodeDays)
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
		.chkShowTooltipsAtTheTop.Checked = ShowTooltipsAtTheTop
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
		'.chkShowToolBoxLocal.Checked = gLocalToolBox
		.chkShowPropLocal.Checked = gLocalProperties
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
			Else
				Languages.Add ..Left(f, Len(f) - 4)
				.cboLanguage.AddItem ..Left(f, Len(f) - 4) & " (" & ML("format does not match") & ")"
			End If
			CloseFile_(Fn)
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
			.lvCompilerPaths.ListItems.Add pCompilers->Item(i)->Key, IIf(FileExists(GetFullPath(pCompilers->Item(i)->Text)), "", "FileError")
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
		.ColorsCount = 0
		AddColors Bookmarks
		AddColors Breakpoints
		AddColors Comments, , , , False
		AddColors CurrentBrackets, , , , False
		AddColors CurrentLine, , , , False, False, False, False
		AddColors CurrentWord, , , , False
		AddColors ExecutionLine, , , , , False, False, False
		AddColors FoldLines, , False, False, False, False, False, False
		AddColors Identifiers, , , , False
		AddColors ColorByRefParameters, , , , False
		AddColors ColorByValParameters, , , , False
		AddColors ColorCommonVariables, , , , False
		AddColors ColorComps, , , , False
		AddColors ColorConstants, , , , False
		AddColors ColorDefines, , , , False
		AddColors ColorFields, , , , False
		AddColors ColorGlobalFunctions, , , , False
		AddColors ColorEnumMembers, , , , False
		AddColors ColorGlobalEnums, , , , False
		AddColors ColorLocalVariables, , , , False
		AddColors ColorMacros, , , , False
		AddColors ColorGlobalNamespaces, , , , False
		AddColors ColorProperties, , , , False
		AddColors ColorSharedVariables, , , , False
		AddColors ColorSubs, , , , False
		AddColors ColorGlobalTypes, , , , False
		AddColors IndicatorLines, , False, False, False, False, False, False
		For k As Integer = 0 To UBound(Keywords)
			'ReDim Preserve Keywords(k)
			AddColors Keywords(k), , , , False
		Next
		
		AddColors LineNumbers, , , False, False
		AddColors NormalText, , , , False
		AddColors Numbers, , , , False
		AddColors ColorOperators, , , , False
		AddColors RealNumbers, , , , False
		AddColors Selection, , , , False, False, False, False
		AddColors SpaceIdentifiers, , False, False, False, False, False, False
		AddColors Strings, , , , False
		
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

Function Html2Text(ByRef inHtml As WString, ByRef StrMarkStart As WString = "", ByRef StrMarkEnd As WString = "") As String
	If Trim(inHtml) = "" Then Return ""
	Dim As  String ret
	Dim As String HtmlCodes(0 To ...) = { "nbsp", " ", "amp", "&", "quot", """", "lt", "<", "gt", ">" }
	Dim As Integer i = 1, j, k, p, q
	If Len(StrMarkStart) > 0 Then
		k = InStr(inHtml, StrMarkStart)
		If k < 1 Then k = 1
		j = InStr(inHtml, StrMarkEnd)
		If j < 1 Then j = Len(inHtml)
		ret = Trim(Mid(inHtml, k, j - k + 1))
	Else
		ret = Trim(inHtml)
	End If
	
	Do
		p = InStr(i, LCase(ret), "<script") 'remove <script
		If p > 0 Then
			q = InStr(p, LCase(ret), "</script>")
			If q > 0 Then
				ret = Left(ret, p - 1)  + Mid(ret, q + 9)
			Else
				ret = Left(ret, p - 1)
				Exit Do
			End If
		End If
		i = InStr(i, ret, "<")
		If i < 1 Then Exit Do
		k = InStr(i, ret, ">")
		If k > 0 Then
			If ( LCase(Mid(ret, i + 1, Len("br "))) = "br " ) OrElse ( LCase(Mid(ret, i + 1, Len("br>"))) = "br>" ) Then
				ret = Left(ret, i - 1) + Chr(13, 10) + Mid(ret, k + 1)
			Else
				ret = Left(ret, i - 1) + Mid(ret, k + 1)
			End If
		Else
			Exit Do
		End If
	Loop
	
	i = 1
	Do
		i = InStr(i, ret, "&")
		If i < 1 Then Exit Do
		If ( Asc( ret , i + 1 ) = Asc( "#" ) ) Then
			Dim As Integer j = i + 2
			Dim As Integer c = 0
			Do
				Select Case Asc( ret, j )
				Case Asc("0") To Asc("9")
					If ( c <= 255 ) Then c = c * 10 + Asc( ret, j ) - Asc("0")
				Case Else
					Exit Do
				End Select
				j += 1
			Loop
			If ( c > 0 And c <= 255 ) Then
				If ( Mid( ret, j, 1) = ";" ) Then j += 1
				ret = Trim(Left(ret, i - 1)) + Chr(c) + Trim(Mid(ret, j))
			End If
		Else
			
			For q As Integer = 0 To UBound(HtmlCodes) Step 2
				If ( LCase(Mid( ret, i + 1, Len( HtmlCodes(q) ))) = HtmlCodes(q) ) Then
					j = i + Len( HtmlCodes(q) ) + 1
					If ( Mid( ret, j, 1) = ";" ) Then j += 1
					ret = Left(ret, i - 1) + HtmlCodes(q + 1) + Mid(ret, j)
					i += Len( HtmlCodes(q + 1) ) - 1
					Exit For
				End If
			Next
		End If
		i += 1
	Loop
	Return ret
End Function

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
		.lstColorKeys.AddItem ML("Identifiers") & ": " & ML("ByRef Parameters")
		.lstColorKeys.AddItem ML("Identifiers") & ": " & ML("ByVal Parameters")
		.lstColorKeys.AddItem ML("Identifiers") & ": " & ML("Common Variables")
		.lstColorKeys.AddItem ML("Identifiers") & ": " & ML("Components")
		.lstColorKeys.AddItem ML("Identifiers") & ": " & ML("Constants")
		.lstColorKeys.AddItem ML("Identifiers") & ": " & ML("Defines")
		.lstColorKeys.AddItem ML("Identifiers") & ": " & ML("Fields")
		.lstColorKeys.AddItem ML("Identifiers") & ": " & ML("Functions")
		.lstColorKeys.AddItem ML("Identifiers") & ": " & ML("Enum Members")
		.lstColorKeys.AddItem ML("Identifiers") & ": " & ML("Enums")
		.lstColorKeys.AddItem ML("Identifiers") & ": " & ML("Local Variables")
		.lstColorKeys.AddItem ML("Identifiers") & ": " & ML("Macros")
		.lstColorKeys.AddItem ML("Identifiers") & ": " & ML("Namespaces")
		.lstColorKeys.AddItem ML("Identifiers") & ": " & ML("Properties")
		.lstColorKeys.AddItem ML("Identifiers") & ": " & ML("Shared Variables")
		.lstColorKeys.AddItem ML("Identifiers") & ": " & ML("Subs")
		.lstColorKeys.AddItem ML("Identifiers") & ": " & ML("Types")
		.lstColorKeys.AddItem ML("Indicator Lines")
		For k As Integer = 0 To KeywordLists.Count - 1
			.lstColorKeys.AddItem ML("Keywords") & ": " & ML(KeywordLists.Item(k))
		Next k
		.lstColorKeys.AddItem ML("Line Numbers")
		.lstColorKeys.AddItem ML("Normal Text")
		.lstColorKeys.AddItem ML("Numbers")
		.lstColorKeys.AddItem ML("Operators")
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
		ReDim .Colors(35 + KeywordLists.Count - 1, 7)
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
		SetColor Breakpoints
		SetColor Comments
		SetColor CurrentBrackets
		SetColor CurrentLine
		SetColor CurrentWord
		SetColor ExecutionLine
		SetColor FoldLines
		SetColor Identifiers
		SetColor ColorByRefParameters
		SetColor ColorByValParameters
		SetColor ColorCommonVariables
		SetColor ColorComps
		SetColor ColorConstants
		SetColor ColorDefines
		SetColor ColorFields
		SetColor ColorGlobalFunctions
		SetColor ColorEnumMembers
		SetColor ColorGlobalEnums
		SetColor ColorLocalVariables
		SetColor ColorMacros
		SetColor ColorGlobalNamespaces
		SetColor ColorProperties
		SetColor ColorSharedVariables
		SetColor ColorSubs
		SetColor ColorGlobalTypes
		SetColor IndicatorLines
		'		IndicatorLines.ForegroundOption = .Colors(8, 0)
		For k As Integer = 0 To UBound(Keywords)
			SetColor Keywords(k)
		Next k
		
		SetColor LineNumbers
		SetColor NormalText
		SetColor Numbers
		SetColor ColorOperators
		SetColor RealNumbers
		SetColor Selection
		SetColor SpaceIdentifiers
		SetColor Strings
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
		If Val(.txtHistoryCodeDays.Text) < HistoryCodeDays Then
			HistoryCodeDays = Val(.txtHistoryCodeDays.Text)
			HistoryCodeClean(ExePath & "/Temp")
		Else
			HistoryCodeDays = Val(.txtHistoryCodeDays.Text)
		End If
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
		ShowTooltipsAtTheTop = .chkShowTooltipsAtTheTop.Checked
		HighlightBrackets = .chkHighlightBrackets.Checked
		HighlightCurrentLine = .chkHighlightCurrentLine.Checked
		HighlightCurrentWord = .chkHighlightCurrentWord.Checked
		TabAsSpaces = .chkTabAsSpaces.Checked
		ChoosedTabStyle = .cboTabStyle.ItemIndex
		GridSize = Val(.txtGridSize.Text)
		ShowAlignmentGrid = .chkShowAlignmentGrid.Checked
		SnapToGridOption = .chkSnapToGrid.Checked
		ChangeIdentifiersCase = .chkChangeIdentifiersCase.Checked
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
		'gLocalToolBox = .chkShowToolBoxLocal.Checked
		gLocalProperties = .chkShowPropLocal.Checked
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
		piniSettings->WriteInteger "Options", "HistoryCodeDays", HistoryCodeDays
		piniSettings->WriteInteger "Options", "HistoryCodeCleanDay", HistoryCodeCleanDay
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
		piniSettings->WriteBool "Options", "ShowTooltipsAtTheTop", ShowTooltipsAtTheTop
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
		piniSettings->WriteBool "Options", "ChangeIdentifiersCase", ChangeIdentifiersCase
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
		'piniSettings->WriteBool "Options", "ShowToolBoxLocal",gLocalToolBox
		piniSettings->WriteBool("Options", "PropertiesLocal", gLocalProperties) 'David Change
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
		
		piniTheme->WriteInteger("Colors", "ByRefParametersForeground",  IIf(ColorByRefParameters.ForegroundOption = Identifiers.ForegroundOption, -1, ColorByRefParameters.ForegroundOption))
		piniTheme->WriteInteger("Colors", "ByRefParametersBackground", IIf(ColorByRefParameters.BackgroundOption = Identifiers.BackgroundOption, -1, ColorByRefParameters.BackgroundOption))
		piniTheme->WriteInteger("Colors", "ByRefParametersFrame", IIf(ColorByRefParameters.FrameOption = Identifiers.FrameOption, -1, ColorByRefParameters.FrameOption))
		piniTheme->WriteInteger("FontStyles", "ByRefParametersBold", ColorByRefParameters.Bold)
		piniTheme->WriteInteger("FontStyles", "ByRefParametersItalic", ColorByRefParameters.Italic)
		piniTheme->WriteInteger("FontStyles", "ByRefParametersUnderline", ColorByRefParameters.Underline)
		
		piniTheme->WriteInteger("Colors", "ByValParametersForeground",  IIf(ColorByValParameters.ForegroundOption = Identifiers.ForegroundOption, -1, ColorByValParameters.ForegroundOption))
		piniTheme->WriteInteger("Colors", "ByValParametersBackground", IIf(ColorByValParameters.BackgroundOption = Identifiers.BackgroundOption, -1, ColorByValParameters.BackgroundOption))
		piniTheme->WriteInteger("Colors", "ByValParametersFrame", IIf(ColorByValParameters.FrameOption = Identifiers.FrameOption, -1, ColorByValParameters.FrameOption))
		piniTheme->WriteInteger("FontStyles", "ByValParametersBold", ColorByValParameters.Bold)
		piniTheme->WriteInteger("FontStyles", "ByValParametersItalic", ColorByValParameters.Italic)
		piniTheme->WriteInteger("FontStyles", "ByValParametersUnderline", ColorByValParameters.Underline)
		
		piniTheme->WriteInteger("Colors", "CommonVariablesForeground",  IIf(ColorByValParameters.ForegroundOption = Identifiers.ForegroundOption, -1, ColorByValParameters.ForegroundOption))
		piniTheme->WriteInteger("Colors", "CommonVariablesBackground", IIf(ColorByValParameters.BackgroundOption = Identifiers.BackgroundOption, -1, ColorByValParameters.BackgroundOption))
		piniTheme->WriteInteger("Colors", "CommonVariablesFrame", IIf(ColorCommonVariables.FrameOption = Identifiers.FrameOption, -1, ColorByValParameters.FrameOption))
		piniTheme->WriteInteger("FontStyles", "CommonVariablesBold", ColorCommonVariables.Bold)
		piniTheme->WriteInteger("FontStyles", "CommonVariablesItalic", ColorCommonVariables.Italic)
		piniTheme->WriteInteger("FontStyles", "CommonVariablesUnderline", ColorCommonVariables.Underline)
		
		piniTheme->WriteInteger("Colors", "ComponentsForeground", IIf(ColorComps.ForegroundOption = Identifiers.ForegroundOption, -1, ColorComps.ForegroundOption))
		piniTheme->WriteInteger("Colors", "ComponentsBackground", IIf(ColorComps.BackgroundOption = Identifiers.BackgroundOption, -1, ColorComps.BackgroundOption))
		piniTheme->WriteInteger("Colors", "ComponentsFrame", IIf(ColorComps.FrameOption = Identifiers.FrameOption, -1, ColorComps.FrameOption))
		piniTheme->WriteInteger("FontStyles", "ComponentsBold", ColorComps.Bold)
		piniTheme->WriteInteger("FontStyles", "ComponentsItalic", ColorComps.Italic)
		piniTheme->WriteInteger("FontStyles", "ComponentsUnderline", ColorComps.Underline)
		
		piniTheme->WriteInteger("Colors", "ConstantsForeground", IIf(ColorConstants.ForegroundOption = Identifiers.ForegroundOption, -1, ColorConstants.ForegroundOption))
		piniTheme->WriteInteger("Colors", "ConstantsBackground", IIf(ColorConstants.BackgroundOption = Identifiers.BackgroundOption, -1, ColorConstants.BackgroundOption))
		piniTheme->WriteInteger("Colors", "ConstantsFrame", IIf(ColorConstants.FrameOption = Identifiers.FrameOption, -1, ColorConstants.FrameOption))
		piniTheme->WriteInteger("FontStyles", "ConstantsBold", ColorConstants.Bold)
		piniTheme->WriteInteger("FontStyles", "ConstantsItalic", ColorConstants.Italic)
		piniTheme->WriteInteger("FontStyles", "ConstantsUnderline", ColorConstants.Underline)
		
		piniTheme->WriteInteger("Colors", "DefinesForeground", IIf(ColorDefines.ForegroundOption = Identifiers.ForegroundOption, -1, ColorDefines.ForegroundOption))
		piniTheme->WriteInteger("Colors", "DefinesBackground", IIf(ColorDefines.BackgroundOption = Identifiers.BackgroundOption, -1, ColorDefines.BackgroundOption))
		piniTheme->WriteInteger("Colors", "DefinesFrame", IIf(ColorDefines.FrameOption = Identifiers.FrameOption, -1, ColorDefines.FrameOption))
		piniTheme->WriteInteger("FontStyles", "DefinesBold", ColorDefines.Bold)
		piniTheme->WriteInteger("FontStyles", "DefinesItalic", ColorDefines.Italic)
		piniTheme->WriteInteger("FontStyles", "DefinesUnderline", ColorDefines.Underline)
		
		piniTheme->WriteInteger("Colors", "FieldsForeground", IIf(ColorFields.ForegroundOption = Identifiers.ForegroundOption, -1, ColorFields.ForegroundOption))
		piniTheme->WriteInteger("Colors", "FieldsBackground", IIf(ColorFields.BackgroundOption = Identifiers.BackgroundOption, -1, ColorFields.BackgroundOption))
		piniTheme->WriteInteger("Colors", "FieldsFrame", IIf(ColorFields.FrameOption = Identifiers.FrameOption, -1, ColorFields.FrameOption))
		piniTheme->WriteInteger("FontStyles", "FieldsBold", ColorFields.Bold)
		piniTheme->WriteInteger("FontStyles", "FieldsItalic", ColorFields.Italic)
		piniTheme->WriteInteger("FontStyles", "FieldsUnderline", ColorFields.Underline)
		
		piniTheme->WriteInteger("Colors", "GlobalFunctionsForeground", IIf(ColorGlobalFunctions.ForegroundOption = Identifiers.ForegroundOption, -1, ColorGlobalFunctions.ForegroundOption))
		piniTheme->WriteInteger("Colors", "GlobalFunctionsBackground", IIf(ColorGlobalFunctions.BackgroundOption = Identifiers.BackgroundOption, -1, ColorGlobalFunctions.BackgroundOption))
		piniTheme->WriteInteger("Colors", "GlobalFunctionsFrame", IIf(ColorGlobalFunctions.FrameOption = Identifiers.FrameOption, -1, ColorGlobalFunctions.FrameOption))
		piniTheme->WriteInteger("FontStyles", "GlobalFunctionsBold", ColorGlobalFunctions.Bold)
		piniTheme->WriteInteger("FontStyles", "GlobalFunctionsItalic", ColorGlobalFunctions.Italic)
		piniTheme->WriteInteger("FontStyles", "GlobalFunctionsUnderline", ColorGlobalFunctions.Underline)
		
		piniTheme->WriteInteger("Colors", "EnumMembersForeground", IIf(ColorEnumMembers.ForegroundOption = Identifiers.ForegroundOption, -1, ColorEnumMembers.ForegroundOption))
		piniTheme->WriteInteger("Colors", "EnumMembersBackground", IIf(ColorEnumMembers.BackgroundOption = Identifiers.BackgroundOption, -1, ColorEnumMembers.BackgroundOption))
		piniTheme->WriteInteger("Colors", "EnumMembersFrame", IIf(ColorEnumMembers.FrameOption = Identifiers.FrameOption, -1, ColorEnumMembers.FrameOption))
		piniTheme->WriteInteger("FontStyles", "EnumMembersBold", ColorEnumMembers.Bold)
		piniTheme->WriteInteger("FontStyles", "EnumMembersItalic", ColorEnumMembers.Italic)
		piniTheme->WriteInteger("FontStyles", "EnumMembersUnderline", ColorEnumMembers.Underline)
		
		piniTheme->WriteInteger("Colors", "GlobalEnumsForeground", IIf(ColorGlobalEnums.ForegroundOption = Identifiers.ForegroundOption, -1, ColorGlobalEnums.ForegroundOption))
		piniTheme->WriteInteger("Colors", "GlobalEnumsBackground", IIf(ColorGlobalEnums.BackgroundOption = Identifiers.BackgroundOption, -1, ColorGlobalEnums.BackgroundOption))
		piniTheme->WriteInteger("Colors", "GlobalEnumsFrame", IIf(ColorGlobalEnums.FrameOption = Identifiers.FrameOption, -1, ColorGlobalEnums.FrameOption))
		piniTheme->WriteInteger("FontStyles", "GlobalEnumsBold", ColorGlobalEnums.Bold)
		piniTheme->WriteInteger("FontStyles", "GlobalEnumsItalic", ColorGlobalEnums.Italic)
		piniTheme->WriteInteger("FontStyles", "GlobalEnumsUnderline", ColorGlobalEnums.Underline)
		
		piniTheme->WriteInteger("Colors", "LocalVariablesForeground", IIf(ColorLocalVariables.ForegroundOption = Identifiers.ForegroundOption, -1, ColorLocalVariables.ForegroundOption))
		piniTheme->WriteInteger("Colors", "LocalVariablesBackground", IIf(ColorLocalVariables.BackgroundOption = Identifiers.BackgroundOption, -1, ColorLocalVariables.BackgroundOption))
		piniTheme->WriteInteger("Colors", "LocalVariablesFrame", IIf(ColorLocalVariables.FrameOption = Identifiers.FrameOption, -1, ColorLocalVariables.FrameOption))
		piniTheme->WriteInteger("FontStyles", "LocalVariablesBold", ColorLocalVariables.Bold)
		piniTheme->WriteInteger("FontStyles", "LocalVariablesItalic", ColorLocalVariables.Italic)
		piniTheme->WriteInteger("FontStyles", "LocalVariablesUnderline", ColorLocalVariables.Underline)
		
		piniTheme->WriteInteger("Colors", "MacrosForeground", IIf(ColorMacros.ForegroundOption = Identifiers.ForegroundOption, -1, ColorMacros.ForegroundOption))
		piniTheme->WriteInteger("Colors", "MacrosBackground", IIf(ColorMacros.BackgroundOption = Identifiers.BackgroundOption, -1, ColorMacros.BackgroundOption))
		piniTheme->WriteInteger("Colors", "MacrosFrame", IIf(ColorMacros.FrameOption = Identifiers.FrameOption, -1, ColorMacros.FrameOption))
		piniTheme->WriteInteger("FontStyles", "MacrosBold", ColorMacros.Bold)
		piniTheme->WriteInteger("FontStyles", "MacrosItalic", ColorMacros.Italic)
		piniTheme->WriteInteger("FontStyles", "MacrosUnderline", ColorMacros.Underline)
		
		piniTheme->WriteInteger("Colors", "GlobalNamespacesForeground", IIf(ColorGlobalNamespaces.ForegroundOption = Identifiers.ForegroundOption, -1, ColorGlobalNamespaces.ForegroundOption))
		piniTheme->WriteInteger("Colors", "GlobalNamespacesBackground", IIf(ColorGlobalNamespaces.BackgroundOption = Identifiers.BackgroundOption, -1, ColorGlobalNamespaces.BackgroundOption))
		piniTheme->WriteInteger("Colors", "GlobalNamespacesFrame", IIf(ColorGlobalNamespaces.FrameOption = Identifiers.FrameOption, -1, ColorGlobalNamespaces.FrameOption))
		piniTheme->WriteInteger("FontStyles", "GlobalNamespacesBold", ColorGlobalNamespaces.Bold)
		piniTheme->WriteInteger("FontStyles", "GlobalNamespacesItalic", ColorGlobalNamespaces.Italic)
		piniTheme->WriteInteger("FontStyles", "GlobalNamespacesUnderline", ColorGlobalNamespaces.Underline)
		
		piniTheme->WriteInteger("Colors", "PropertiesForeground",  IIf(ColorProperties.ForegroundOption = Identifiers.ForegroundOption, -1, ColorProperties.ForegroundOption))
		piniTheme->WriteInteger("Colors", "PropertiesBackground", IIf(ColorProperties.BackgroundOption = Identifiers.BackgroundOption, -1, ColorProperties.BackgroundOption))
		piniTheme->WriteInteger("Colors", "PropertiesFrame", IIf(ColorProperties.FrameOption = Identifiers.FrameOption, -1, ColorProperties.FrameOption))
		piniTheme->WriteInteger("FontStyles", "PropertiesBold", ColorProperties.Bold)
		piniTheme->WriteInteger("FontStyles", "PropertiesItalic", ColorProperties.Italic)
		piniTheme->WriteInteger("FontStyles", "PropertiesUnderline", ColorProperties.Underline)
		
		piniTheme->WriteInteger("Colors", "SharedVariablesForeground", IIf(ColorSharedVariables.ForegroundOption = Identifiers.ForegroundOption, -1, ColorSharedVariables.ForegroundOption))
		piniTheme->WriteInteger("Colors", "SharedVariablesBackground", IIf(ColorSharedVariables.BackgroundOption = Identifiers.BackgroundOption, -1, ColorSharedVariables.BackgroundOption))
		piniTheme->WriteInteger("Colors", "SharedVariablesFrame", IIf(ColorSharedVariables.FrameOption = Identifiers.FrameOption, -1, ColorSharedVariables.FrameOption))
		piniTheme->WriteInteger("FontStyles", "SharedVariablesBold", ColorSharedVariables.Bold)
		piniTheme->WriteInteger("FontStyles", "SharedVariablesItalic", ColorSharedVariables.Italic)
		piniTheme->WriteInteger("FontStyles", "SharedVariablesUnderline", ColorSharedVariables.Underline)
		
		piniTheme->WriteInteger("Colors", "SubsForeground", IIf(ColorSubs.ForegroundOption = Identifiers.ForegroundOption, -1, ColorSubs.ForegroundOption))
		piniTheme->WriteInteger("Colors", "SubsBackground", IIf(ColorSubs.BackgroundOption = Identifiers.BackgroundOption, -1, ColorSubs.BackgroundOption))
		piniTheme->WriteInteger("Colors", "SubsFrame", IIf(ColorSubs.FrameOption = Identifiers.FrameOption, -1, ColorSubs.FrameOption))
		piniTheme->WriteInteger("FontStyles", "SubsBold", ColorSubs.Bold)
		piniTheme->WriteInteger("FontStyles", "SubsItalic", ColorSubs.Italic)
		piniTheme->WriteInteger("FontStyles", "SubsUnderline", ColorSubs.Underline)
		
		piniTheme->WriteInteger("Colors", "GlobalTypesForeground", IIf(ColorGlobalTypes.ForegroundOption = Identifiers.ForegroundOption, -1, ColorGlobalTypes.ForegroundOption))
		piniTheme->WriteInteger("Colors", "GlobalTypesBackground", IIf(ColorGlobalTypes.BackgroundOption = Identifiers.BackgroundOption, -1, ColorGlobalTypes.BackgroundOption))
		piniTheme->WriteInteger("Colors", "GlobalTypesFrame", IIf(ColorGlobalTypes.FrameOption = Identifiers.FrameOption, -1, ColorGlobalTypes.FrameOption))
		piniTheme->WriteInteger("FontStyles", "GlobalTypesBold", ColorGlobalTypes.Bold)
		piniTheme->WriteInteger("FontStyles", "GlobalTypesItalic", ColorGlobalTypes.Italic)
		piniTheme->WriteInteger("FontStyles", "GlobalTypesUnderline", ColorGlobalTypes.Underline)
		
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
		piniTheme->WriteInteger("Colors", "OperatorsForeground", IIf(ColorOperators.ForegroundOption = Identifiers.ForegroundOption, -1, ColorOperators.ForegroundOption))
		piniTheme->WriteInteger("Colors", "OperatorsBackground", IIf(ColorOperators.BackgroundOption = Identifiers.BackgroundOption, -1, ColorOperators.BackgroundOption))
		piniTheme->WriteInteger("Colors", "OperatorsFrame", IIf(ColorOperators.FrameOption = Identifiers.FrameOption, -1, ColorOperators.FrameOption))
		piniTheme->WriteInteger("FontStyles", "OperatorsBold", ColorOperators.Bold)
		piniTheme->WriteInteger("FontStyles", "OperatorsItalic", ColorOperators.Italic)
		piniTheme->WriteInteger("FontStyles", "OperatorsUnderline", ColorOperators.Underline)
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
		For jj As Integer = 0 To TabPanels.Count - 1
			Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
			For i As Integer = 0 To ptabCode->TabCount - 1
				tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
				tb->txtCode.Font.Name = *EditorFontName
				tb->txtCode.Font.Size = EditorFontSize
			Next
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
				.lvCompilerPaths.SelectedItem->ImageKey = IIf(FileExists(GetFullpath(pfPath->txtPath.Text)), "", "FileError")
				.lvCompilerPaths.SelectedItem->SelectedImageKey = IIf(FileExists(GetFullpath(pfPath->txtPath.Text)), "", "FileError")
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

Sub HistoryCodeClean(ByRef Path As WString)
	Dim As WString * 1024 f, f1
	Dim As Double d2
	Dim As UInteger Attr, NameCount
	If Trim(Path) = "" Then Exit Sub
	If FormClosing OrElse bStop Then Exit Sub
	If EndsWith(Path, "\Windows") Then Exit Sub
	f = Dir(Path & Slash & "*.bak", fbArchive, Attr)
	While Len(Trim(f)) > 0
		If FormClosing OrElse bStop Then Exit Sub
		F1 = Mid(f, Len(f) - 16)
		If Len(F1) > 16 Then
			d2 = DateValue(Mid(F1, 1, 4) & "/" & Mid(F1, 5, 2) & "/" & Mid(F1, 7, 2))
			If DateDiff( "d", d2, Now()) > HistoryCodeDays Then Kill Path & Slash & f
		End If
		f = Dir()
	Wend
	HistoryCodeCleanDay = DateValue(Format(Now, "yyyy/mm/dd"))
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

Private Sub frmOptions.cmdUpdateLng_Click(ByRef Sender As Control)
	Dim As WString Ptr lang_name
	Dim As WString * 1024 Buff, FileNameLng, FileNameSrc
	Dim As String tKey, f
	Dim As Integer Pos1, p, p1, n, Result, Fn1, Fn2
	Dim As Dictionary mlKeysGeneral, mlKeysCompiler, mlKeysProperty, mlKeysTemplates, mlKeyWords, mlKeysCompilerEnglish, mlKeysPropertyEnglish, mlKeysTemplatesEnglish, mlKeyWordsEnglish, mlKeysGeneralEnglish
	Dim As Boolean StartGeneral, StartKeyWords, StartProperty, StartCompiler, StartTemplates, IsComment = False
	cmdUpdateLng.Enabled = False
	'lblShowMsg.Visible = True
	' Produce English.lng from Projects at first
	FileNameLng = ExePath & "/Settings/Languages/English.lng"
	Fn1 = FreeFile
	Result = Open(FileNameLng For Input Encoding "utf-8" As #Fn1)
	If Result <> 0 Then Result = Open(FileNameLng For Input Encoding "utf-16" As #Fn1)
	If Result <> 0 Then Result = Open(FileNameLng For Input Encoding "utf-32" As #Fn1)
	If Result <> 0 Then Result = Open(FileNameLng For Input As #Fn1)
	If Result = 0 Then
		StartGeneral = True
		Line Input #Fn1, Buff
		wLet lang_name, Buff
		Do Until EOF(Fn1)
			Line Input #Fn1, Buff
			If LCase(Trim(Buff)) = "[keywords]" Then
				StartKeyWords = True
				StartProperty = False
				StartCompiler = False
				Starttemplates = False
				StartGeneral = False
			ElseIf LCase(Trim(Buff)) = "[property]" Then
				StartKeyWords = False
				StartProperty = True
				StartCompiler = False
				Starttemplates = False
				StartGeneral = False
			ElseIf LCase(Trim(Buff)) = "[compiler]" Then
				StartKeyWords = False
				StartProperty = False
				StartCompiler = True
				Starttemplates = False
				StartGeneral = False
			ElseIf LCase(Trim(Buff)) = "[templates]" Then
				StartKeyWords = False
				StartProperty = False
				StartCompiler = False
				Starttemplates = True
				StartGeneral = False
			ElseIf LCase(Trim(Buff)) = "[general]" Then
				StartKeyWords = False
				StartProperty = False
				StartCompiler = False
				Starttemplates = False
				StartGeneral = True
			End If
			Pos1 = InStr(Buff, "=")
			If Len(Trim(Buff, Any !"\t ")) > 0 AndAlso Pos1 > 0 Then
				'David Change For the Control Property's Language.
				'note: "=" already Replaced by "~"
				tKey = Trim(..Left(Buff, Pos1 - 1), Any !"\t ")
				If InStr(tKey, "~") Then tKey = Replace(tKey, "~", "=")
				If StartGeneral = True Then
					mlKeysGeneralEnglish.Add tKey, Trim(Mid(Buff, Pos1 + 1), Any !"\t ")
				ElseIf StartProperty = True Then
					mlKeysPropertyEnglish.Add tKey, Trim(Mid(Buff, Pos1 + 1), Any !"\t ")
				ElseIf StartKeyWords = True Then
					mlKeyWordsEnglish.Add tKey, Trim(Mid(Buff, Pos1 + 1), Any !"\t ")
				ElseIf StartCompiler = True Then
					mlKeysCompilerEnglish.Add tKey, Trim(Mid(Buff, Pos1 + 1), Any !"\t ")
				ElseIf StartTemplates = True Then
					mlKeysTemplatesEnglish.Add tKey, Trim(Mid(Buff, Pos1 + 1), Any !"\t ")
				End If
			End If
		Loop
		Close Fn1
		mlKeysGeneralEnglish.SortKeys
		mlKeysPropertyEnglish.SortKeys
		mlKeysCompilerEnglish.SortKeys
		mlKeysTemplatesEnglish.SortKeys
		mlKeyWordsEnglish.SortKeys
	Else
		lblShowMsg.Text = ML("File not found") & "! " & FileNameLng
		mlKeysGeneral.Clear
		mlKeysProperty.Clear
		mlKeysCompiler.Clear
		mlKeysTemplates.Clear
		mlKeyWords.Clear
		mlKeysGeneralEnglish.Clear
		mlKeysPropertyEnglish.Clear
		mlKeysCompilerEnglish.Clear
		mlKeysTemplatesEnglish.Clear
		mlKeyWordsEnglish.Clear
		cmdUpdateLng.Enabled = True
		Exit Sub
	End If
	Fn1= FreeFile
	If Open(ExePath & "/VisualFBEditor.vfp" For Input Encoding "utf-8" As #Fn1) = 0 Then
		IsComment = False
		Do Until EOF(Fn1)
			Line Input #Fn1, Buff
			If InStr(Trim(Buff, Any !"\t "), "'") = 1 Then Continue Do
			If InStr(Trim(Buff, Any !"\t "), "/*") = 1 Then IsComment = True
			If InStr(Trim(Buff, Any !"\t "), "*/") > 1 Then
				IsComment = False
				Continue Do
			End If
			If IsComment Then Continue Do
			If StartsWith(Buff, "File=") OrElse StartsWith(Buff, "*File=") Then
				Buff = Mid(Buff, InStr(Buff, "=") + 1)
				If InStr(Buff, ":") Then
					FileNameSrc = Buff
				Else
					FileNameSrc = ExePath & "/" & Buff
				End If
				Fn2 = FreeFile
				If Open(FileNameSrc For Input Encoding "utf-8" As #Fn2) = 0 Then
					Print "FileNameSrc: " & FileNameSrc
					lblShowMsg.Text = ML("Open") & "...  " & FileNameSrc
					Do Until EOF(Fn2)
						Line Input #Fn2, Buff
						p = InStr(LCase(Buff), "ml(""")
						Do While p > 0
							p1 = InStr(p + 1, Buff, """)")
							If p1 > 0 Then
								tKey = Trim(Mid(Buff, p + 4, p1 - p - 4), Any !"\t ")
								If tKey <> "" Then
									If Not mlKeysGeneralEnglish.ContainsKey(tKey) Then
										mlKeysGeneralEnglish.Add tKey, ""
										tkey = replace(tkey, "&", "")
										If Not mlKeysGeneralEnglish.ContainsKey(tkey) Then mlKeysGeneralEnglish.Add tKey, ""
									End If
								End If
							End If
							p = InStr(p1 + 1, LCase(Buff), "ml(""")
						Loop
					Loop
					Close #Fn2
					App.DoEvents
				Else
					lblShowMsg.Text = ML("File not found") & "! " & FileNameSrc
				End If
			End If
		Loop
		Close #Fn1
	Else
		lblShowMsg.Text = ML("File not found") & "! " & ExePath & "/VisualFBEditor.vfp"
		mlKeysGeneral.Clear
		mlKeysProperty.Clear
		mlKeysCompiler.Clear
		mlKeysTemplates.Clear
		mlKeywords.Clear
		cmdUpdateLng.Enabled = True
		Exit Sub
	End If
	App.DoEvents
	mlKeysGeneralEnglish.SortKeys
	lblShowMsg.Text = ML("Save") & " " & FileNameLng
	Fn1 = FreeFile
	Open FileNameLng For Output Encoding "utf-8" As #Fn1
	Print #Fn1, *lang_name
	APP.DoEvents
	Print #Fn1, "[Keywords]"
	For i As Integer = 0 To mlKeyWordsEnglish.Count - 1
		tKey = mlKeyWordsEnglish.Item(i)->Key
		If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
		If tKey <> "" Then Print #Fn1, tKey & " = " '& mlKeysGeneral.Item(i)->Text
	Next
	APP.DoEvents
	Print #Fn1, "[Property]"
	For i As Integer = 0 To mlKeysPropertyEnglish.Count - 1
		tKey = mlKeysPropertyEnglish.Item(i)->Key
		If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
		If tKey <> "" Then Print #Fn1, tKey & " = " '& mlKeysGeneral.Item(i)->Text
	Next
	APP.DoEvents
	Print #Fn1, "[Templates]"
	For i As Integer = 0 To mlKeysTemplatesEnglish.Count - 1
		tKey = mlKeysTemplatesEnglish.Item(i)->Key
		If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
		If tKey <> "" Then Print #Fn1, tKey & " = " '& mlKeysGeneral.Item(i)->Text
	Next
	APP.DoEvents
	Print #Fn1, "[Compiler]"
	For i As Integer = 0 To mlKeysCompilerEnglish.Count - 1
		tKey = mlKeysCompilerEnglish.Item(i)->Key
		If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
		If tKey <> "" Then Print #Fn1, tKey & " = " '& mlKeysGeneral.Item(i)->Text
	Next
	APP.DoEvents
	Print #Fn1, "[General]"
	For i As Integer = 0 To mlKeysGeneralEnglish.Count - 1
		tKey = mlKeysGeneralEnglish.Item(i)->Key
		If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
		If tKey <> "" Then Print #Fn1, tKey & " = " '& mlKeysGeneral.Item(i)->Text
	Next
	Close #Fn1
	APP.DoEvents
	' Produce other Language .lng file from Projects.
	mlKeysGeneral.Clear
	mlKeysCompiler.Clear
	mlKeysTemplates.Clear
	mlKeysProperty.Clear
	mlKeyWords.Clear
	If chkAllLNG.Checked Then
		f = Dir(ExePath & "/Settings/Languages/*.lng")
	Else
		p = InStr(cboLanguage.Text, "-")
		If p > 0 Then f = Trim(Mid(cboLanguage.Text, p + 1)) & ".lng " Else Exit Sub
	End If
	While f <> ""
		StartGeneral = True
		mlKeysGeneral.Clear
		mlKeysProperty.Clear
		mlKeysCompiler.Clear
		mlKeysTemplates.Clear
		mlKeyWords.Clear
		If chkAllLNG.Checked AndAlso InStr(LCase(f), "english.lng") > 0 Then
			f = Dir()
			If f = "" Then
				cmdUpdateLng.Enabled = True
				Exit Sub
			End If
		End If
		Fn1 = FreeFile
		FileNameLng = ExePath & "/Settings/Languages/" & f
		Result = Open(FileNameLng For Input Encoding "utf-8" As #Fn1)
		If Result <> 0 Then Result = Open(FileNameLng For Input Encoding "utf-16" As #Fn1)
		If Result <> 0 Then Result = Open(FileNameLng For Input Encoding "utf-32" As #Fn1)
		If Result <> 0 Then Result = Open(FileNameLng For Input As #Fn1)
		If Result = 0 Then
			StartGeneral = True
			This.Text =  "******* Updating ... " & FileNameLng
			Line Input #Fn1, Buff
			wLet lang_name, Buff
			Do Until EOF(Fn1)
				Line Input #Fn1, Buff
				If LCase(Trim(Buff)) = "[keywords]" Then
					StartKeyWords = True
					StartProperty = False
					StartCompiler = False
					Starttemplates = False
					StartGeneral = False
				ElseIf LCase(Trim(Buff)) = "[property]" Then
					StartKeyWords = False
					StartProperty = True
					StartCompiler = False
					Starttemplates = False
					StartGeneral = False
				ElseIf LCase(Trim(Buff)) = "[compiler]" Then
					StartKeyWords = False
					StartProperty = False
					StartCompiler = True
					Starttemplates = False
					StartGeneral = False
				ElseIf LCase(Trim(Buff)) = "[templates]" Then
					StartKeyWords = False
					StartProperty = False
					StartCompiler = False
					Starttemplates = True
					StartGeneral = False
				ElseIf LCase(Trim(Buff)) = "[general]" Then
					StartKeyWords = False
					StartProperty = False
					StartCompiler = False
					Starttemplates = False
					StartGeneral = True
				End If
				Pos1 = InStr(Buff, "=")
				If Len(Trim(Buff, Any !"\t ")) > 0 AndAlso Pos1 > 0 Then
					'David Change For the Control Property's Language.
					'note: "=" already converted to "~"
					tKey = Trim(..Left(Buff, Pos1 - 1), Any !"\t ")
					If InStr(tKey, "~") Then tKey = Replace(tKey, "~", "=")
					If StartGeneral = True Then
						mlKeysGeneral.Add tKey, Trim(Mid(Buff, Pos1 + 1), Any !"\t ")
					ElseIf StartProperty = True Then
						mlKeysProperty.Add tKey, Trim(Mid(Buff, Pos1 + 1), Any !"\t ")
					ElseIf StartKeyWords = True Then
						mlKeyWords.Add tKey, Trim(Mid(Buff, Pos1 + 1), Any !"\t ")
					ElseIf StartCompiler = True Then
						mlKeysCompiler.Add tKey, Trim(Mid(Buff, Pos1 + 1), Any !"\t ")
					ElseIf StartTemplates = True Then
						mlKeysTemplates.Add tKey, Trim(Mid(Buff, Pos1 + 1), Any !"\t ")
					End If
				End If
			Loop
			Close Fn1
			mlKeysGeneral.SortKeys
			mlKeysProperty.SortKeys
			mlKeysCompiler.SortKeys
			mlKeysTemplates.SortKeys
			mlKeywords.SortKeys
			APP.DoEvents
			
'			'Add the not exist one
'			txtHtmlFind.Text = ""
'			txtHtmlFind.Text = txtHtmlFind.Text & Chr(13, 10) & *lang_name
'			txtHtmlFind.Text = txtHtmlFind.Text & Chr(13, 10) & "[KeyWords]"
'			For i As Integer = 0 To mlKeyWordsEnglish.Count - 1
'				tKey = mlKeyWordsEnglish.Item(i)->Key
'				If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
'				If Not mlKeyWords.ContainsKey(tKey) Then
'					mlKeyWords.Add tKey
'					If Not chkAllLNG.Checked Then txtHtmlFind.Text = txtHtmlFind.Text & Chr(13, 10) & tKey
'				End If
'			Next
'			APP.DoEvents
'			txtHtmlFind.Text = txtHtmlFind.Text & Chr(13, 10) & "[Property]"
'			For i As Integer = 0 To mlKeysPropertyEnglish.Count - 1
'				tKey = mlKeysPropertyEnglish.Item(i)->Key
'				If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
'				If Not mlKeysProperty.ContainsKey(tKey) Then
'					mlKeysProperty.Add tKey
'					If Not chkAllLNG.Checked Then txtHtmlFind.Text = txtHtmlFind.Text & Chr(13, 10) & tKey
'				End If
'			Next
'			APP.DoEvents
'			txtHtmlFind.Text = txtHtmlFind.Text & Chr(13, 10) & "[Templates]"
'			For i As Integer = 0 To mlKeysTemplatesEnglish.Count - 1
'				tKey = mlKeysTemplatesEnglish.Item(i)->Key
'				If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
'				If Not mlKeysTemplates.ContainsKey(tKey) Then
'					mlKeysTemplates.Add tKey
'					If Not chkAllLNG.Checked Then txtHtmlFind.Text = txtHtmlFind.Text & Chr(13, 10) & tKey
'				End If
'			Next
'			APP.DoEvents
'			txtHtmlFind.Text = txtHtmlFind.Text & Chr(13, 10) & "[Compiler]"
'			For i As Integer = 0 To mlKeysCompilerEnglish.Count - 1
'				tKey = mlKeysCompilerEnglish.Item(i)->Key
'				If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
'				If Not mlKeysCompiler.ContainsKey(tKey) Then
'					mlKeysCompiler.Add tKey
'					If Not chkAllLNG.Checked Then txtHtmlFind.Text = txtHtmlFind.Text & Chr(13, 10) & tKey
'				End If
'			Next
'			APP.DoEvents
'			txtHtmlFind.Text = txtHtmlFind.Text & Chr(13, 10) & "[General]"
'			For i As Integer = 0 To mlKeysGeneralEnglish.Count - 1
'				tKey = mlKeysGeneralEnglish.Item(i)->Key
'				If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
'				If Not mlKeysGeneral.ContainsKey(tKey) Then
'					mlKeysGeneral.Add tKey
'					If Not chkAllLNG.Checked Then txtHtmlFind.Text = txtHtmlFind.Text & Chr(13, 10) & tKey
'				End If
'			Next
		Else
			lblShowMsg.Text = lblShowMsg.Text & Chr(13, 10) & "File not found！" & FileNameLng
			mlKeysGeneral.Clear
			mlKeysProperty.Clear
			mlKeysCompiler.Clear
			mlKeysTemplates.Clear
			mlKeyWords.Clear
			mlKeysGeneralEnglish.Clear
			mlKeysPropertyEnglish.Clear
			mlKeysCompilerEnglish.Clear
			mlKeysTemplatesEnglish.Clear
			mlKeyWordsEnglish.Clear
			cmdUpdateLng.Enabled = True
			Exit Sub
		End If
		App.DoEvents
		
		mlKeysGeneral.SortKeys
		mlKeysProperty.SortKeys
		mlKeysCompiler.SortKeys
		mlKeysTemplates.SortKeys
		mlKeyWords.SortKeys
		
		'Save the Language file
		Fn1 = FreeFile
		Open FileNameLng For Output Encoding "utf-8" As #Fn1
		Print #Fn1, *lang_name
		lblShowMsg.Text = " Saving ... " & FileNameLng
		APP.DoEvents
		Print #Fn1, "[Keywords]"
		For i As Integer = 0 To mlKeyWords.Count - 1
			tKey = mlKeyWords.Item(i)->Key
			If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
			If tKey <> "" Then Print #Fn1, tKey & " = " & mlKeyWords.Item(i)->Text
		Next
		APP.DoEvents
		Print #Fn1, "[Property]"
		For i As Integer = 0 To mlKeysProperty.Count - 1
			tKey = mlKeysProperty.Item(i)->Key
			If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
			If tKey <> "" Then Print #Fn1, tKey & " = " & mlKeysProperty.Item(i)->Text
		Next
		APP.DoEvents
		Print #Fn1, "[Templates]"
		For i As Integer = 0 To mlKeysTemplates.Count - 1
			tKey = mlKeysTemplates.Item(i)->Key
			If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
			If tKey <> "" Then Print #Fn1, tKey & " = " & mlKeysTemplates.Item(i)->Text
		Next
		APP.DoEvents
		Print #Fn1, "[Compiler]"
		For i As Integer = 0 To mlKeysCompiler.Count - 1
			tKey = mlKeysCompiler.Item(i)->Key
			If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
			If tKey <> "" Then Print #Fn1, tKey & " = " & mlKeysCompiler.Item(i)->Text
		Next
		APP.DoEvents
		Print #Fn1, "[General]"
		For i As Integer = 0 To mlKeysGeneral.Count - 1
			tKey = mlKeysGeneral.Item(i)->Key
			If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
			If tKey <> "" Then Print #Fn1, tKey & " = " & mlKeysGeneral.Item(i)->Text
		Next
		Close #Fn1
		APP.DoEvents
		If chkAllLNG.Checked Then f = Dir() Else Exit While
	Wend
	App.DoEvents
	mlKeysGeneral.Clear
	mlKeysProperty.Clear
	mlKeysCompiler.Clear
	mlKeysTemplates.Clear
	mlKeyWords.Clear
	mlKeysGeneralEnglish.Clear
	mlKeysPropertyEnglish.Clear
	mlKeysCompilerEnglish.Clear
	mlKeysTemplatesEnglish.Clear
	mlKeyWordsEnglish.Clear
	cmdUpdateLng.Enabled = True
	'WebBrowser1.Navigate("https://cn.bing.com/translator?ref=TThis&&text=&from=en&to=cn")
	
End Sub
