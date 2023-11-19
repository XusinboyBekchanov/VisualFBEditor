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
		This.ExtraMargins.Bottom = -1
		This.ExtraMargins.Left = 0
		This.ExtraMargins.Top = 0
		This.SetBounds 0, 0, 631, 488
		This.StartPosition = FormStartPosition.CenterParent
		'This.Caption = ML("Options")
		This.CancelButton = @cmdCancel
		'This.DefaultButton = @cmdOK
		This.Designer = @This
		This.BorderStyle = FormBorderStyle.FixedDialog
		' pnlCompiler
		pnlCompiler.Name = "pnlCompiler"
		pnlCompiler.Text = ""
		pnlCompiler.Align = DockStyle.alClient
		pnlCompiler.ExtraMargins.Bottom = 9
		pnlCompiler.ExtraMargins.Top = 4
		pnlCompiler.ExtraMargins.Right = 10
		pnlCompiler.Margins.Left = 10
		pnlCompiler.TabIndex = 67
		pnlCompiler.SetBounds 188, 4, 427, 400
		pnlCompiler.Parent = @This
		' pnlMake
		pnlMake.Name = "pnlMake"
		pnlMake.Text = ""
		pnlMake.ExtraMargins.Top = 4
		pnlMake.ExtraMargins.Bottom = 9
		pnlMake.ExtraMargins.Right = 10
		pnlMake.Margins.Left = 10
		pnlMake.Align = DockStyle.alClient
		pnlMake.TabIndex = 68
		pnlMake.SetBounds 188, 4, 427, 400
		pnlMake.Parent = @This
		' pnlDebugger
		pnlDebugger.Name = "pnlDebugger"
		pnlDebugger.Text = ""
		pnlDebugger.ExtraMargins.Top = 4
		pnlDebugger.ExtraMargins.Bottom = 9
		pnlDebugger.ExtraMargins.Right = 10
		pnlDebugger.Margins.Left = 10
		pnlDebugger.Align = DockStyle.alClient
		pnlDebugger.TabIndex = 69
		pnlDebugger.SetBounds 188, 4, 427, 400
		pnlDebugger.Parent = @This
		' pnlTerminal
		pnlTerminal.Name = "pnlTerminal"
		pnlTerminal.Text = ""
		pnlTerminal.Margins.Left = 10
		pnlTerminal.ExtraMargins.Top = 4
		pnlTerminal.ExtraMargins.Right = 10
		pnlTerminal.ExtraMargins.Bottom = 9
		pnlTerminal.Align = DockStyle.alClient
		pnlTerminal.TabIndex = 70
		pnlTerminal.SetBounds 188, 4, 427, 400
		pnlTerminal.Parent = @This
		' pnlDesigner
		pnlDesigner.Name = "pnlDesigner"
		pnlDesigner.Text = ""
		pnlDesigner.ExtraMargins.Top = 4
		pnlDesigner.ExtraMargins.Right = 10
		pnlDesigner.ExtraMargins.Bottom = 9
		pnlDesigner.Align = DockStyle.alClient
		pnlDesigner.Margins.Left = 10
		pnlDesigner.TabIndex = 71
		pnlDesigner.SetBounds -162, 4, 427, 400
		pnlDesigner.Parent = @This
		' pnlLocalization
		pnlLocalization.Name = "pnlLocalization"
		pnlLocalization.Text = ""
		pnlLocalization.ExtraMargins.Top = 4
		pnlLocalization.ExtraMargins.Bottom = 9
		pnlLocalization.ExtraMargins.Right = 10
		pnlLocalization.Align = DockStyle.alClient
		pnlLocalization.Margins.Left = 10
		pnlLocalization.TabIndex = 72
		pnlLocalization.SetBounds 188, 4, 427, 400
		pnlLocalization.Parent = @This
		' pnlThemes
		pnlThemes.Name = "pnlThemes"
		pnlThemes.Text = ""
		pnlThemes.ExtraMargins.Top = 4
		pnlThemes.ExtraMargins.Bottom = 9
		pnlThemes.ExtraMargins.Right = 10
		pnlThemes.Margins.Left = 10
		pnlThemes.Align = DockStyle.alClient
		pnlThemes.TabIndex = 73
		pnlThemes.SetBounds 188, 4, 427, 400
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
		pnlShortcuts.TabIndex = 74
		pnlShortcuts.SetBounds 188, 4, 427, 400
		pnlShortcuts.Parent = @This
		' pnlHelp
		pnlHelp.Name = "pnlHelp"
		pnlHelp.Text = ""
		pnlHelp.ExtraMargins.Top = 4
		pnlHelp.ExtraMargins.Right = 10
		pnlHelp.ExtraMargins.Bottom = 9
		pnlHelp.Margins.Left = 10
		pnlHelp.Align = DockStyle.alClient
		pnlHelp.TabIndex = 75
		pnlHelp.SetBounds 188, 4, 427, 400
		pnlHelp.Parent = @This
		' pnlOtherEditors
		pnlOtherEditors.Name = "pnlOtherEditors"
		pnlOtherEditors.Text = ""
		pnlOtherEditors.ExtraMargins.Right = 10
		pnlOtherEditors.Align = DockStyle.alClient
		pnlOtherEditors.ExtraMargins.Bottom = 9
		pnlOtherEditors.ExtraMargins.Top = 4
		pnlOtherEditors.TabIndex = 76
		pnlOtherEditors.SetBounds 188, 4, 427, 400
		pnlOtherEditors.Parent = @This
		' pnlIncludes
		pnlIncludes.Name = "pnlIncludes"
		pnlIncludes.ExtraMargins.Bottom = 9
		pnlIncludes.ExtraMargins.Right = 10
		pnlIncludes.Align = DockStyle.alClient
		pnlIncludes.ExtraMargins.Top = 4
		pnlIncludes.TabIndex = 77
		pnlIncludes.SetBounds 188, 4, 427, 400
		pnlIncludes.Text = ""
		pnlIncludes.Parent = @This
		' pnlCodeEditor
		pnlCodeEditor.Name = "pnlCodeEditor"
		pnlCodeEditor.Text = ""
		pnlCodeEditor.ExtraMargins.Top = 4
		pnlCodeEditor.ExtraMargins.Bottom = 9
		pnlCodeEditor.ExtraMargins.Right = 10
		pnlCodeEditor.Margins.Left = 10
		pnlCodeEditor.Align = DockStyle.alClient
		pnlCodeEditor.TabIndex = 78
		pnlCodeEditor.SetBounds 188, 4, 427, 400
		pnlCodeEditor.Parent = @This
		' pnlColorsAndFonts
		pnlColorsAndFonts.Name = "pnlColorsAndFonts"
		pnlColorsAndFonts.Text = ""
		pnlColorsAndFonts.ExtraMargins.Top = 4
		pnlColorsAndFonts.ExtraMargins.Right = 10
		pnlColorsAndFonts.ExtraMargins.Bottom = 9
		pnlColorsAndFonts.Margins.Left = 10
		pnlColorsAndFonts.Align = DockStyle.alClient
		pnlColorsAndFonts.TabIndex = 79
		pnlColorsAndFonts.SetBounds 188, 4, 427, 400
		pnlColorsAndFonts.Parent = @This
		' pnlGeneral
		pnlGeneral.Name = "pnlGeneral"
		pnlGeneral.Text = ""
		pnlGeneral.Margins.Left = 10
		pnlGeneral.ExtraMargins.Top = 0
		pnlGeneral.ExtraMargins.Bottom = 9
		pnlGeneral.ExtraMargins.Right = 10
		pnlGeneral.Align = DockStyle.alClient
		pnlGeneral.Margins.Top = 0
		pnlGeneral.TabIndex = 1
		pnlGeneral.SetBounds 188, 0, 427, 404
		pnlGeneral.Parent = @This
		' pnlCommands
		With pnlCommands
			.Name = "pnlCommands"
			.Text = "Panel1"
			.TabIndex = 80
			.Align = DockStyle.alBottom
			.Margins.Top = 0
			.Margins.Right = 0
			.Margins.Left = 0
			.Margins.Bottom = 0
			.AutoSize = True
			.SetBounds 0, 415, 625, 44
			.Designer = @This
			.Parent = @This
		End With
		' tvOptions
		tvOptions.Name = "tvOptions"
		tvOptions.Text = "TreeView1"
		tvOptions.Align = DockStyle.alLeft
		tvOptions.ExtraMargins.Top = 10
		tvOptions.ExtraMargins.Left = 10
		tvOptions.ExtraMargins.Bottom = 10
		tvOptions.TabIndex = 0
		tvOptions.SetBounds 10, 10, 178, 393
		tvOptions.HideSelection = False
		tvOptions.OnSelChanged = @TreeView1_SelChange
		tvOptions.Parent = @This
		'cmdOK.Caption = ML("OK")
		' cmdApply
		cmdApply.Name = "cmdApply"
		cmdApply.Text = ML("Apply")
		cmdApply.Align = DockStyle.alRight
		cmdApply.ExtraMargins.Bottom = 10
		cmdApply.ExtraMargins.Right = 10
		cmdApply.ExtraMargins.Top = 10
		cmdApply.TabIndex = 81
		cmdApply.SetBounds 525, 10, 90, 24
		cmdApply.OnClick = @cmdApply_Click
		cmdApply.Parent = @pnlCommands
		' cmdCancel
		cmdCancel.Name = "cmdCancel"
		cmdCancel.Text = ML("Cancel")
		cmdCancel.Align = DockStyle.alRight
		cmdCancel.ExtraMargins.Bottom = 10
		cmdCancel.ExtraMargins.Top = 10
		cmdCancel.TabIndex = 82
		cmdCancel.SetBounds 435, 10, 90, 24
		cmdCancel.OnClick = @cmdCancel_Click
		cmdCancel.Parent = @pnlCommands
		' cmdOK
		cmdOK.Name = "cmdOK"
		cmdOK.Text = ML("OK")
		cmdOK.Default = True
		cmdOK.Align = DockStyle.alRight
		cmdOK.ExtraMargins.Bottom = 10
		cmdOK.ExtraMargins.Top = 10
		cmdOK.TabIndex = 83
		cmdOK.SetBounds 345, 10, 90, 24
		cmdOK.OnClick = @cmdOK_Click
		cmdOK.Parent = @pnlCommands
		' lblBlack
		lblBlack.Name = "lblBlack"
		lblBlack.Text = ""
		lblBlack.BorderStyle = 2
		lblBlack.BackColor = 8421504
		lblBlack.ExtraMargins.Right = 1
		lblBlack.ExtraMargins.Left = 0
		lblBlack.Align = DockStyle.alClient
		lblBlack.ExtraMargins.Bottom = 1
		lblBlack.Anchor.Right = 1
		lblBlack.Anchor.Left = 1
		lblBlack.TabIndex = 61
		lblBlack.SetBounds 0, 0, 604, 1
		lblBlack.Parent = @pnlLine
		' grbDefaultCompilers
		With grbDefaultCompilers
			.Name = "grbDefaultCompilers"
			.Text = ML("Default Compilers")
			.AutoSize = True
			.Align = DockStyle.alTop
			.ExtraMargins.Left = 0
			.Margins.Top = 20
			.Margins.Right = 15
			.Margins.Left = 15
			.Margins.Bottom = 15
			.TabIndex = 84
			.SetBounds 10, 0, 417, 123
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
			.TabIndex = 85
			.SetBounds 10, 0, 417, 400
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
			.TabIndex = 86
			.SetBounds 10, 128, 417, 272
			.Parent = @pnlCompiler
		End With
		' lblShortcut
		lblShortcut.Name = "lblShortcut"
		lblShortcut.Text = ML("Select shortcut") & ":"
		lblShortcut.ExtraMargins.Right = 0
		lblShortcut.Align = DockStyle.alLeft
		lblShortcut.CenterImage = True
		lblShortcut.TabIndex = 20
		lblShortcut.SetBounds 0, 0, 126, 20
		lblShortcut.Parent = @pnlSelectShortcut
		' hkShortcut
		hkShortcut.Name = "hkShortcut"
		hkShortcut.ExtraMargins.Left = 0
		hkShortcut.ExtraMargins.Bottom = 0
		hkShortcut.ExtraMargins.Right = 0
		hkShortcut.Align = DockStyle.alClient
		hkShortcut.TabIndex = 21
		hkShortcut.SetBounds 126, 0, 206, 20
		hkShortcut.Parent = @pnlSelectShortcut
		' cmdSetShortcut
		cmdSetShortcut.Name = "cmdSetShortcut"
		cmdSetShortcut.Text = ML("Set")
		#ifdef __USE_WINAPI__
			cmdSetShortcut.ExtraMargins.Top = -1
			cmdSetShortcut.ExtraMargins.Bottom = -1
			cmdSetShortcut.ExtraMargins.Right = -1
		#endif
		cmdSetShortcut.Align = DockStyle.alRight
		cmdSetShortcut.TabIndex = 22
		cmdSetShortcut.SetBounds 332, -1, 56, 22
		cmdSetShortcut.OnClick = @cmdSetShortcut_Click
		cmdSetShortcut.Parent = @pnlSelectShortcut
		' lvShortcuts
		With lvShortcuts
			.Name = "lvShortcuts"
			.Text = "lvShortcuts"
			.Align = DockStyle.alClient
			.ExtraMargins.Bottom = 15
		lvShortcuts.TabIndex = 87
			.SetBounds 15, 22, 387, 328
			.OnSelectedItemChanged = @lvShortcuts_SelectedItemChanged
			.Parent = @grbShortcuts
		End With
		' grbDefaultDebuggers
		With grbDefaultDebuggers
			.Name = "grbDefaultDebuggers"
			.Text = ML("Default Debuggers")
			.Align = DockStyle.alTop
			.TabIndex = 88
			.SetBounds 10, 0, 417, 128
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
			.TabIndex = 89
			.SetBounds 10, 203, 417, 197
			.Parent = @pnlDebugger
		End With
		' cboDebugger32
		With cboDebugger32
			.Name = "cboDebugger32"
			.Text = "cboCompiler321"
			.TabIndex = 90
			.SetBounds 18, 39, 184, 21
			.Parent = @grbDefaultDebuggers
		End With
		' grbDefaultTerminal
		With grbDefaultTerminal
			.Name = "grbDefaultTerminal"
			.Text = ML("Default Terminal")
			.Align = DockStyle.alTop
			.TabIndex = 91
			.SetBounds 10, 0, 417, 64
			.Parent = @pnlTerminal
		End With
		' cboTerminal
		With cboTerminal
			.Name = "cboTerminal"
			.Text = "cboTerminal"
			.TabIndex = 92
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
			.TabIndex = 93
			.SetBounds 10, 168, 417, 232
			.Parent = @pnlTerminal
		End With
		' lvTerminalPath
		With lvTerminalPaths
			.Name = "lvTerminalPaths"
			.Text = "lvTerminalPaths"
			.ExtraMargins.Bottom = 15
			.Align = DockStyle.alClient
		lvTerminalPaths.TabIndex = 94
			.SetBounds 15, 22, 387, 156
			.Designer = @This
			.OnItemActivate = @lvTerminalPaths_ItemActivate_
			.Parent = @grbTerminalPaths
		End With
		With cmdClearTerminals
			.Name = "cmdClearTerminals"
			.Text = ML("&Clear")
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 0
			.ExtraMargins.Bottom = 0
			.Align = DockStyle.alRight
			.TabIndex = 16
			.SetBounds 290, 0, 97, 24
			.OnClick = @cmdClearTerminals_Click
			.Parent = @hbxTerminal
		End With
		' cmdRemoveTerminal
		With cmdRemoveTerminal
			.Name = "cmdRemoveTerminal"
			.Text = ML("&Remove")
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 0
			.ExtraMargins.Bottom = 0
			.Align = DockStyle.alRight
			.TabIndex = 17
			.SetBounds 193, 0, 97, 24
			.OnClick = @cmdRemoveTerminal_Click
			.Parent = @hbxTerminal
		End With
		' cmdChangeTerminal
		cmdChangeTerminal.Name = "cmdChangeTerminal"
		cmdChangeTerminal.Text = ML("Chan&ge")
		cmdChangeTerminal.ExtraMargins.Right = 0
		cmdChangeTerminal.ExtraMargins.Bottom = 0
		cmdChangeTerminal.ExtraMargins.Left = 0
		cmdChangeTerminal.Align = DockStyle.alRight
		cmdChangeTerminal.TabIndex = 18
		cmdChangeTerminal.SetBounds 96, 0, 97, 24
		cmdChangeTerminal.OnClick = @cmdChangeTerminal_Click
		cmdChangeTerminal.Parent = @hbxTerminal
		' cmdAddTerminal
		With cmdAddTerminal
			.Name = "cmdAddTerminal"
			.Text = ML("&Add")
			.ExtraMargins.Left = 0
			.ExtraMargins.Right = 0
			.Align = DockStyle.alRight
			.ExtraMargins.Bottom = 0
			.TabIndex = 19
			.SetBounds -1, 0, 97, 24
			.OnClick = @cmdAddTerminal_Click
			.Parent = @hbxTerminal
		End With
		' cmdClearDebuggers1
		' grbLanguage
		With grbLanguage
			.Name = "grbLanguage"
			.Text = ML("Language")
			.Align = DockStyle.alClient
			.Margins.Top = 22
			.Margins.Right = 15
			.Margins.Left = 15
			.Margins.Bottom = 15
			.TabIndex = 95
			.SetBounds 10, 0, 417, 400
			.Parent = @pnlLocalization
		End With
		' grbThemes
		With grbThemes
			.Name = "grbThemes"
			.Text = ML("Themes")
			.Align = DockStyle.alClient
			.Margins.Top = 20
			.Margins.Right = 10
			.Margins.Left = 10
			.Margins.Bottom = 10
			.TabIndex = 96
			.SetBounds 10, 0, 417, 400
			.Parent = @pnlThemes
		End With
		' pnlLanguage
		With pnlLanguage
			.Name = "pnlLanguage"
			.Text = "Panel1"
			.AutoSize = True
			.TabIndex = 97
			.Align = DockStyle.alTop
			.SetBounds 15, 22, 387, 21
			.Designer = @This
			.Parent = @grbLanguage
		End With
		' cboLanguage
		cboLanguage.Name = "cboLanguage"
		'ComboBoxEdit1.Text = "russian"
		cboLanguage.Align = DockStyle.alClient
		cboLanguage.ExtraMargins.Right = 0
		cboLanguage.ControlIndex = 0
		cboLanguage.TabIndex = 98
		cboLanguage.SetBounds 0, 0, 257, 21
		cboLanguage.Parent = @pnlLanguage
		' cmdClearCompilers
		With cmdClearCompilers
			.Name = "cmdClearCompilers"
			.Text = ML("&Clear")
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 0
			.ExtraMargins.Bottom = 0
			.Align = DockStyle.alRight
			.TabIndex = 4
			.SetBounds 290, 0, 97, 24
			.OnClick = @cmdClearCompilers_Click
			.Parent = @hbxCompilers
		End With
		' cmdRemoveCompiler
		With cmdRemoveCompiler
			.Name = "cmdRemoveCompiler"
			.Text = ML("&Remove")
			.ExtraMargins.Bottom = 0
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 0
			.Align = DockStyle.alRight
			.TabIndex = 5
			.SetBounds 193, 0, 97, 24
			.OnClick = @cmdRemoveCompiler_Click
			.Parent = @hbxCompilers
		End With
		' cmdChangeCompiler
		With cmdChangeCompiler
			.Name = "cmdChangeCompiler"
			.Text = ML("Chan&ge")
			.ExtraMargins.Bottom = 0
			.ExtraMargins.Left = 0
			.ExtraMargins.Right = 0
			.Align = DockStyle.alRight
			.TabIndex = 6
			.SetBounds 96, 0, 97, 24
			.OnClick = @cmdChangeCompiler_Click
			.Parent = @hbxCompilers
		End With
		' cmdAddCompiler
		cmdAddCompiler.Name = "cmdAddCompiler"
		cmdAddCompiler.Text = ML("&Add")
		cmdAddCompiler.ExtraMargins.Left = 0
		cmdAddCompiler.ExtraMargins.Bottom = 0
		cmdAddCompiler.ExtraMargins.Right = 0
		cmdAddCompiler.Align = DockStyle.alRight
		cmdAddCompiler.TabIndex = 7
		cmdAddCompiler.SetBounds -1, 0, 97, 24
		cmdAddCompiler.OnClick = @cmdAddCompiler_Click
		cmdAddCompiler.Parent = @hbxCompilers
		' vbxGeneral
		With vbxGeneral
			.Name = "vbxGeneral"
			.Text = "VerticalBox1"
			.TabIndex = 99
			.Align = DockStyle.alTop
			.SetBounds 10, 0, 417, 383
			.Designer = @This
			.Parent = @pnlGeneral
		End With
		' chkAutoCreateBakFiles
		With chkAutoCreateBakFiles
			.Name = "chkAutoCreateBakFiles"
			.Text = ML("Auto create bak files before saving")
			.ExtraMargins.Top = 5
			.Align = DockStyle.alTop
			.TabIndex = 100
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 0, 5, 223, 21
			.ID = 1009
			.Parent = @vbxGeneral
		End With
		' chkAutoCreateRC
		chkAutoCreateRC.Name = "chkAutoCreateRC"
		chkAutoCreateRC.Text = ML("Auto create resource and manifest files (.rc, .xml)")
		chkAutoCreateRC.ExtraMargins.Top = 5
		chkAutoCreateRC.Align = DockStyle.alTop
		chkAutoCreateRC.TabIndex = 101
		chkAutoCreateRC.Constraints.Height = 21
		chkAutoCreateRC.AutoSize = True
		chkAutoCreateRC.SetBounds 0, 28, 295, 21
		chkAutoCreateRC.Parent = @vbxGeneral
		' CheckBox1
		CheckBox1.Name = "CheckBox1"
		CheckBox1.Text = ML("Auto increment version")
		CheckBox1.Align = DockStyle.alTop
		CheckBox1.ExtraMargins.Top = 5
		CheckBox1.TabIndex = 102
		CheckBox1.Constraints.Height = 21
		CheckBox1.AutoSize = True
		CheckBox1.SetBounds 0, 51, 166, 21
		CheckBox1.Parent = @vbxGeneral
		' chkAddRelativePathsToRecent
		With chkAddRelativePathsToRecent
			.Name = "chkAddRelativePathsToRecent"
			.Text = ML("Add relative paths to recent")
			.TabIndex = 103
			.ExtraMargins.Top = 5
			.Align = DockStyle.alTop
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 0, 74, 190, 21
			.Parent = @vbxGeneral
		End With
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
			.TabIndex = 104
			.SetBounds 10, 0, 417, 214
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
			.TabIndex = 105
			.SetBounds 10, 222, 417, 178
			.Parent = @pnlIncludes
		End With
		' pnlIncludeMFFPath
		With pnlIncludeMFFPath
			.Name = "pnlIncludeMFFPath"
			.Text = ""
			.Align = DockStyle.alTop
			.TabIndex = 106
			.SetBounds 15, 23, 387, 16
			.Parent = @grbIncludePaths
		End With
		' chkIncludeMFFPath
		With chkIncludeMFFPath
			.Name = "chkIncludeMFFPath"
			.Text = ML("Include MFF Path") & ":"
			.Align = DockStyle.alNone
			.TabIndex = 107
			.SetBounds 0, -2, 152, 18
			.Parent = @pnlIncludeMFFPath
		End With
		' txtMFFpath
		txtMFFpath.Name = "txtMFFpath"
		txtMFFpath.Align = DockStyle.alTop
		txtMFFpath.ExtraMargins.Left = 150
		txtMFFpath.ExtraMargins.Right = 24
		txtMFFpath.ExtraMargins.Top = -18
		txtMFFpath.TabIndex = 108
		txtMFFpath.SetBounds 165, 21, 213, 20
		txtMFFpath.Parent = @grbIncludePaths
		' cmdMFFPath
		cmdMFFPath.Name = "cmdMFFPath"
		cmdMFFPath.Text = "..."
		cmdMFFPath.TabIndex = 109
		cmdMFFPath.SetBounds 377, 20, 24, 22
		cmdMFFPath.OnClick = @cmdMFFPath_Click
		cmdMFFPath.Parent = @grbIncludePaths
		' vbxCodeEditor
		With vbxCodeEditor
			.Name = "vbxCodeEditor"
			.Text = "HorizontalBox1"
			.TabIndex = 110
			.Align = DockStyle.alTop
			.SetBounds 10, 0, 420, 387
			.Designer = @This
			.Parent = @pnlCodeEditor
		End With
		' chkAutoIndentation
		chkAutoIndentation.Name = "chkAutoIndentation"
		chkAutoIndentation.Text = ML("Auto Indentation")
		chkAutoIndentation.ExtraMargins.Top = 2
		chkAutoIndentation.Align = DockStyle.alTop
		chkAutoIndentation.TabIndex = 111
		chkAutoIndentation.Constraints.Height = 21
		chkAutoIndentation.AutoSize = True
		chkAutoIndentation.SetBounds 0, 2, 137, 21
		chkAutoIndentation.Parent = @vbxCodeEditor
		' chkEnableAutoComplete
		chkEnableAutoComplete.Name = "chkEnableAutoComplete"
		chkEnableAutoComplete.Text = ML("Enable Auto Complete")
		chkEnableAutoComplete.ExtraMargins.Top = 0
		chkEnableAutoComplete.Align = DockStyle.alTop
		chkEnableAutoComplete.TabIndex = 112
		chkEnableAutoComplete.Constraints.Height = 21
		chkEnableAutoComplete.AutoSize = True
		chkEnableAutoComplete.SetBounds 0, 23, 161, 21
		chkEnableAutoComplete.Parent = @vbxCodeEditor
		' chkEnableAutoSuggestions
		With chkEnableAutoSuggestions
			.Name = "chkEnableAutoSuggestions"
			.Text = ML("Enable Auto Suggestions")
			.TabIndex = 228
			.Align = DockStyle.alTop
			.ControlIndex = 1
			'.Caption = ML("Enable Auto Suggestions")
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 0, 44, 174, 21
			.Designer = @This
			.Parent = @vbxCodeEditor
		End With
		' chkShowSpaces
		chkShowSpaces.Name = "chkShowSpaces"
		chkShowSpaces.Text = ML("Show Spaces")
		chkShowSpaces.Align = DockStyle.alTop
		chkShowSpaces.ExtraMargins.Top = 0
		chkShowSpaces.TabIndex = 113
		chkShowSpaces.Constraints.Height = 21
		chkShowSpaces.AutoSize = True
		chkShowSpaces.SetBounds 0, 65, 118, 21
		chkShowSpaces.Parent = @vbxCodeEditor
		' chkShowKeywordsTooltip
		With chkShowKeywordsTooltip
			.Name = "chkShowKeywordsTooltip"
			.Text = ML("Show Keywords Tooltip")
			.TabIndex = 114
			.ExtraMargins.Top = 0
			.Align = DockStyle.alTop
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 0, 86, 166, 21
			'.Caption = ML("Show Keywords Tooltip")
			.Parent = @vbxCodeEditor
		End With
		' chkShowTooltipsAtTheTop
		With chkShowTooltipsAtTheTop
			.Name = "chkShowTooltipsAtTheTop"
			.Text = ML("Show Tooltips at the Top")
			.TabIndex = 115
			.ExtraMargins.Top = 0
			.Align = DockStyle.alTop
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 0, 107, 174, 21
			.Designer = @This
			.Parent = @vbxCodeEditor
		End With
		' chkShowHorizontalSeparatorLines
		With chkShowHorizontalSeparatorLines
			.Name = "chkShowHorizontalSeparatorLines"
			.Text = ML("Show Horizontal Separator Lines")
			.TabIndex = 230
			.Align = DockStyle.alTop
			.ControlIndex = 6
			'.Caption = ML("Show Horizontal Separator Lines")
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 0, 128, 210, 21
			.Designer = @This
			.Parent = @vbxCodeEditor
		End With
		' chkHighlightCurrentWord
		With chkHighlightCurrentWord
			.Name = "chkHighlightCurrentWord"
			.Text = ML("Highlight Current Word")
			.ExtraMargins.Top = 0
			.Align = DockStyle.alTop
			.TabIndex = 116
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 0, 149, 165, 21
			.Parent = @vbxCodeEditor
		End With
		' chkHighlightCurrentLine
		With chkHighlightCurrentLine
			.Name = "chkHighlightCurrentLine"
			.Text = ML("Highlight Current Line")
			.ExtraMargins.Top = 0
			.Align = DockStyle.alTop
			.TabIndex = 117
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 0, 170, 158, 21
			.Parent = @vbxCodeEditor
		End With
		' chkHighlightBrackets
		With chkHighlightBrackets
			.Name = "chkHighlightBrackets"
			.Text = ML("Highlight Brackets")
			.ExtraMargins.Top = 0
			.Align = DockStyle.alTop
			.TabIndex = 118
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 0, 191, 140, 21
			.Parent = @vbxCodeEditor
		End With
		' chkAddSpacesToOperators
		With chkAddSpacesToOperators
			.Name = "chkAddSpacesToOperators"
			.Text = ML("Add Spaces To Operators")
			.TabIndex = 119
			.ExtraMargins.Top = 0
			.Align = DockStyle.alTop
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 0, 212, 178, 21
			'.Caption = ML("Add Spaces To Operators")
			.Parent = @vbxCodeEditor
		End With
		' chkSyntaxHighlightingIdentifiers
		With chkSyntaxHighlightingIdentifiers
			.Name = "chkSyntaxHighlightingIdentifiers"
			.Text = ML("Syntax Highlighting Identifiers")
			.TabIndex = 121
			.Align = DockStyle.alTop
			'.Caption = ML("Syntax Highlighting Identifiers")
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 0, 233, 199, 21
			.Designer = @This
			.Parent = @vbxCodeEditor
		End With
		' chkChangeIdentifiersCase
		With chkChangeIdentifiersCase
			.Name = "chkChangeIdentifiersCase"
			.Text = ML("Change Identifiers Case")
			.TabIndex = 120
			.Align = DockStyle.alTop
			.Caption = ML("Change Identifiers Case")
			.ExtraMargins.Top = 0
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 0, 254, 171, 21
			.Designer = @This
			.Parent = @vbxCodeEditor
		End With
		' chkChangeKeywordsCase
		chkChangeKeywordsCase.Name = "chkChangeKeywordsCase"
		chkChangeKeywordsCase.Text = ML("Change Keywords Case To") & ":"
		chkChangeKeywordsCase.ExtraMargins.Top = 0
		chkChangeKeywordsCase.Align = DockStyle.alLeft
		chkChangeKeywordsCase.ExtraMargins.Right = 0
		chkChangeKeywordsCase.TabIndex = 31
		chkChangeKeywordsCase.Constraints.Height = 21
		chkChangeKeywordsCase.AutoSize = True
		chkChangeKeywordsCase.SetBounds 0, 0, 202, 21
		chkChangeKeywordsCase.Parent = @pnlChangeKeywordsCase
		' cboCase
		cboCase.Name = "cboCase"
		cboCase.Text = "ComboBoxEdit2"
		cboCase.ExtraMargins.Right = 20
		cboCase.ExtraMargins.Top = 0
		cboCase.ExtraMargins.Left = 0
		cboCase.Align = DockStyle.alRight
		cboCase.ExtraMargins.Bottom = 2
		cboCase.TabIndex = 32
		cboCase.SetBounds 215, 0, 182, 21
		cboCase.Parent = @pnlChangeKeywordsCase
		' chkTabAsSpaces
		chkTabAsSpaces.Name = "chkTabAsSpaces"
		chkTabAsSpaces.Text = ML("Treat Tab as Spaces")
		chkTabAsSpaces.ExtraMargins.Top = 0
		chkTabAsSpaces.Align = DockStyle.alLeft
		chkTabAsSpaces.ExtraMargins.Right = 0
		'chkTabAsSpaces.Caption = ML("Treat Tab as Spaces") & ":"
		chkTabAsSpaces.TabIndex = 33
		chkTabAsSpaces.Constraints.Height = 21
		chkTabAsSpaces.AutoSize = True
		chkTabAsSpaces.SetBounds 0, 0, 171, 21
		chkTabAsSpaces.Parent = @pnlTreatTabAsSpaces
		' cboTabStyle
		cboTabStyle.Name = "cboTabStyle"
		cboTabStyle.Text = "cboCase1"
		cboTabStyle.ExtraMargins.Left = 0
		cboTabStyle.ExtraMargins.Right = 20
		cboTabStyle.Align = DockStyle.alRight
		cboTabStyle.ExtraMargins.Top = 0
		cboTabStyle.ExtraMargins.Bottom = 2
		cboTabStyle.TabIndex = 34
		cboTabStyle.SetBounds 215, 0, 182, 21
		cboTabStyle.Parent = @pnlTreatTabAsSpaces
		' lblTabSize
		lblTabSize.Name = "lblTabSize"
		lblTabSize.Text = ML("Tab Size") & ":"
		lblTabSize.ExtraMargins.Left = 40
		lblTabSize.ExtraMargins.Right = 0
		lblTabSize.Align = DockStyle.alClient
		lblTabSize.ExtraMargins.Top = 2
		lblTabSize.TabIndex = 35
		lblTabSize.SetBounds 40, 2, 175, 18
		lblTabSize.Parent = @pnlTabSize
		' txtTabSize
		txtTabSize.Name = "txtTabSize"
		txtTabSize.Text = ""
		txtTabSize.ExtraMargins.Left = 0
		txtTabSize.ExtraMargins.Right = 130
		txtTabSize.ExtraMargins.Top = 0
		txtTabSize.Align = DockStyle.alRight
		txtTabSize.ExtraMargins.Bottom = 2
		txtTabSize.TabIndex = 36
		txtTabSize.SetBounds 215, 0, 72, 18
		txtTabSize.Parent = @pnlTabSize
		' lstIncludePaths
		lstIncludePaths.Name = "lstIncludePaths"
		lstIncludePaths.Text = "ListControl1"
		lstIncludePaths.Align = DockStyle.alClient
		lstIncludePaths.ExtraMargins.Right = 25
		lstIncludePaths.TabIndex = 122
		lstIncludePaths.SetBounds 15, 68, 362, 121
		lstIncludePaths.Parent = @grbIncludePaths
		' lstLibraryPaths
		lstLibraryPaths.Name = "lstLibraryPaths"
		lstLibraryPaths.Text = "ListControl11"
		lstLibraryPaths.Align = DockStyle.alClient
		lstLibraryPaths.ExtraMargins.Right = 25
		lstLibraryPaths.ExtraMargins.Top = 2
		lstLibraryPaths.TabIndex = 123
		lstLibraryPaths.SetBounds 15, 22, 362, 134
		lstLibraryPaths.Parent = @grbLibraryPaths
		' lblOthers
		lblOthers.Name = "lblOthers"
		lblOthers.Text = ML("Others") & ":"
		lblOthers.Align = DockStyle.alTop
		lblOthers.ExtraMargins.Top = 5
		lblOthers.ExtraMargins.Bottom = 4
		lblOthers.TabIndex = 124
		lblOthers.SetBounds 15, 46, 387, 18
		lblOthers.Parent = @grbIncludePaths
		' cmdAddInclude
		cmdAddInclude.Name = "cmdAddInclude"
		cmdAddInclude.Text = "+"
		cmdAddInclude.TabIndex = 125
		cmdAddInclude.SetBounds 376, 67, 24, 22
		cmdAddInclude.OnClick = @cmdAddInclude_Click
		cmdAddInclude.Parent = @grbIncludePaths
		' cmdRemoveInclude
		cmdRemoveInclude.Name = "cmdRemoveInclude"
		cmdRemoveInclude.Text = "-"
		cmdRemoveInclude.TabIndex = 126
		cmdRemoveInclude.SetBounds 376, 88, 24, 22
		cmdRemoveInclude.OnClick = @cmdRemoveInclude_Click
		cmdRemoveInclude.Parent = @grbIncludePaths
		' cmdAddLibrary
		cmdAddLibrary.Name = "cmdAddLibrary"
		cmdAddLibrary.Text = "+"
		cmdAddLibrary.TabIndex = 127
		cmdAddLibrary.SetBounds 376, 21, 24, 22
		cmdAddLibrary.OnClick = @cmdAddLibrary_Click
		cmdAddLibrary.Parent = @grbLibraryPaths
		' cmdRemoveLibrary
		cmdRemoveLibrary.Name = "cmdRemoveLibrary"
		cmdRemoveLibrary.Text = "-"
		cmdRemoveLibrary.TabIndex = 128
		cmdRemoveLibrary.SetBounds 376, 42, 24, 22
		cmdRemoveLibrary.OnClick = @cmdRemoveLibrary_Click
		cmdRemoveLibrary.Parent = @grbLibraryPaths
		' lblHistoryLimit
		lblHistoryLimit.Name = "lblHistoryLimit"
		lblHistoryLimit.Text = ML("History limit") & ":"
		lblHistoryLimit.ExtraMargins.Top = 2
		lblHistoryLimit.ExtraMargins.Left = 40
		lblHistoryLimit.ExtraMargins.Right = 0
		lblHistoryLimit.Align = DockStyle.alClient
		lblHistoryLimit.TabIndex = 37
		lblHistoryLimit.SetBounds 40, 2, 175, 18
		lblHistoryLimit.Parent = @pnlHistoryLimit
		' txtHistoryLimit
		txtHistoryLimit.Name = "txtHistoryLimit"
		txtHistoryLimit.ExtraMargins.Top = 0
		txtHistoryLimit.ExtraMargins.Right = 130
		txtHistoryLimit.ExtraMargins.Left = 0
		txtHistoryLimit.Align = DockStyle.alRight
		txtHistoryLimit.ExtraMargins.Bottom = 2
		txtHistoryLimit.TabIndex = 38
		txtHistoryLimit.SetBounds 215, 0, 72, 18
		txtHistoryLimit.Text = ""
		txtHistoryLimit.Parent = @pnlHistoryLimit
		' grbGrid
		grbGrid.Name = "grbGrid"
		grbGrid.Text = ML("Grid")
		grbGrid.Align = DockStyle.alTop
		grbGrid.TabIndex = 129
		grbGrid.SetBounds 10, 0, 417, 122
		grbGrid.Parent = @pnlDesigner
		' lblGridSize
		lblGridSize.Name = "lblGridSize"
		lblGridSize.Text = ML("Size") & ":"
		lblGridSize.TabIndex = 130
		lblGridSize.SetBounds 16, 31, 60, 18
		lblGridSize.Parent = @grbGrid
		' txtGridSize
		txtGridSize.Name = "txtGridSize"
		txtGridSize.Text = "10"
		txtGridSize.TabIndex = 131
		txtGridSize.SetBounds 73, 31, 114, 18
		txtGridSize.Parent = @grbGrid
		' chkShowAlignmentGrid
		chkShowAlignmentGrid.Name = "chkShowAlignmentGrid"
		chkShowAlignmentGrid.Text = ML("Show Alignment Grid")
		chkShowAlignmentGrid.TabIndex = 65
		chkShowAlignmentGrid.SetBounds 8, -5, 186, 30
		chkShowAlignmentGrid.Parent = @pnlGrid
		' chkSnapToGrid
		chkSnapToGrid.Name = "chkSnapToGrid"
		chkSnapToGrid.Text = ML("Snap to Grid")
		chkSnapToGrid.TabIndex = 66
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
		grbColors.TabIndex = 132
		grbColors.SetBounds 10, 0, 417, 349
		grbColors.Parent = @pnlColorsAndFonts
		' grbFont
		grbFont.Name = "grbFont"
		grbFont.Text = ML("Font (applies to all styles)")
		grbFont.Align = DockStyle.alBottom
		grbFont.ExtraMargins.Top = 5
		grbFont.AutoSize = True
		grbFont.TabIndex = 133
		grbFont.SetBounds 10, 354, 417, 46
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
			.TabIndex = 134
			.SetBounds 10, 92, 417, 308
			.Parent = @pnlMake
		End With
		' lvMakeToolPaths
		With lvMakeToolPaths
			.Name = "lvMakeToolPaths"
			.Text = "lvMakeToolPaths"
			.Align = DockStyle.alClient
			.ExtraMargins.Bottom = 15
		lvMakeToolPaths.TabIndex = 135
			.SetBounds 15, 22, 387, 232
			.Designer = @This
			.OnItemActivate = @lvMakeToolPaths_ItemActivate_
			.Parent = @grbMakeToolPaths
		End With
		With cmdClearMakeTools
			.Name = "cmdClearMakeTools"
			.Text = ML("&Clear")
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 0
			.ExtraMargins.Bottom = 0
			.Align = DockStyle.alRight
			.TabIndex = 8
			.SetBounds 290, 0, 97, 24
			.OnClick = @cmdClearMakeTools_Click
			.Parent = @hbxMakeTool
		End With
		' cmdRemoveMakeTool
		With cmdRemoveMakeTool
			.Name = "cmdRemoveMakeTool"
			.Text = ML("&Remove")
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 0
			.ExtraMargins.Bottom = 0
			.Align = DockStyle.alRight
			.TabIndex = 9
			.SetBounds 193, 0, 97, 24
			.OnClick = @cmdRemoveMakeTool_Click
			.Parent = @hbxMakeTool
		End With
		' cmdChangeMakeTool
		cmdChangeMakeTool.Name = "cmdChangeMakeTool"
		cmdChangeMakeTool.Text = ML("Chan&ge")
		cmdChangeMakeTool.ExtraMargins.Left = 0
		cmdChangeMakeTool.ExtraMargins.Right = 0
		cmdChangeMakeTool.ExtraMargins.Bottom = 0
		cmdChangeMakeTool.Align = DockStyle.alRight
		cmdChangeMakeTool.TabIndex = 10
		cmdChangeMakeTool.SetBounds 96, 0, 97, 24
		cmdChangeMakeTool.OnClick = @cmdChangeMakeTool_Click
		cmdChangeMakeTool.Parent = @hbxMakeTool
		' cmdAddMakeTool
		With cmdAddMakeTool
			.Name = "cmdAddMakeTool"
			.Text = ML("&Add")
			.ExtraMargins.Left = 0
			.ExtraMargins.Bottom = 0
			.ExtraMargins.Right = 0
			.Align = DockStyle.alRight
			.TabIndex = 11
			.SetBounds -1, 0, 97, 24
			.OnClick = @cmdAddMakeTool_Click
			.IsChild = True
			.ID = 1010
			.Parent = @hbxMakeTool
		End With
		' cmdClearMakeTool
		' grbDefaultMakeTool
		With grbDefaultMakeTool
			.Name = "grbDefaultMakeTool"
			.Text = ML("Default Make Tool")
			.Align = DockStyle.alTop
			.Margins.Top = 20
			.Margins.Right = 15
			.Margins.Left = 15
			.Margins.Bottom = 15
			.AutoSize = True
			.TabIndex = 136
			.SetBounds 10, 0, 417, 56
			.Parent = @pnlMake
		End With
		' cboMakeTool
		With cboMakeTool
			.Name = "cboMakeTool"
			.Text = "cboMakeTool"
			.Align = DockStyle.alTop
			.TabIndex = 137
			.SetBounds 15, 20, 387, 21
			.Parent = @grbDefaultMakeTool
		End With
		' cboTheme
		cboTheme.Name = "cboTheme"
		cboTheme.Text = "ComboBoxEdit2"
		cboTheme.Align = DockStyle.alTop
		cboTheme.ExtraMargins.Right = 15
		cboTheme.ExtraMargins.Bottom = 15
		cboTheme.TabIndex = 39
		cboTheme.SetBounds 0, 0, 212, 21
		cboTheme.OnChange = @cboTheme_Change
		cboTheme.Parent = @vbxTheme
		' lstColorKeys
		lstColorKeys.Name = "lstColorKeys"
		lstColorKeys.Text = "ListControl1"
		lstColorKeys.Align = DockStyle.alClient
		lstColorKeys.ExtraMargins.Right = 15
		lstColorKeys.ControlIndex = 2
		lstColorKeys.TabIndex = 221
		lstColorKeys.SetBounds 0, 36, 212, 277
		lstColorKeys.OnChange = @lstColorKeys_Change
		lstColorKeys.Parent = @vbxTheme
		' cmdAdd
		cmdAdd.Name = "cmdAdd"
		cmdAdd.Text = ML("&Add")
		cmdAdd.ControlIndex = 1
		cmdAdd.Align = DockStyle.alClient
		cmdAdd.ExtraMargins.Bottom = 0
		cmdAdd.TabIndex = 40
		cmdAdd.SetBounds 0, 0, 83, 23
		cmdAdd.OnClick = @cmdAdd_Click
		cmdAdd.Parent = @hbxThemeCommands
		' cmdRemove
		cmdRemove.Name = "cmdRemove"
		cmdRemove.Text = ML("&Remove")
		cmdRemove.ControlIndex = 0
		cmdRemove.Align = DockStyle.alRight
		cmdRemove.TabIndex = 41
		cmdRemove.SetBounds 83, 0, 71, 23
		cmdRemove.OnClick = @cmdRemove_Click
		cmdRemove.Parent = @hbxThemeCommands
		' chkForeground
		chkForeground.Name = "chkForeground"
		chkForeground.Text = ML("Auto")
		chkForeground.Align = DockStyle.alRight
		chkForeground.ExtraMargins.Left = 5
		chkForeground.TabIndex = 43
		chkForeground.SetBounds 106, 0, 48, 22
		chkForeground.OnClick = @chkForeground_Click
		chkForeground.Parent = @hbxForeground
		' txtColorForeground
		txtColorForeground.Name = "txtColorForeground"
		txtColorForeground.Text = ""
		txtColorForeground.Align = DockStyle.alClient
		txtColorForeground.TabIndex = 44
		txtColorForeground.SetBounds 0, 0, 77, 22
		txtColorForeground.BackColor = 0
		txtColorForeground.Designer = @This
		txtColorForeground.OnKeyPress = @_txtColorForeground_KeyPress
		txtColorForeground.Parent = @hbxForeground
		' cmdForeground
		cmdForeground.Name = "cmdForeground"
		cmdForeground.Text = "..."
		cmdForeground.Align = DockStyle.alRight
		cmdForeground.TabIndex = 45
		cmdForeground.SetBounds 77, 0, 24, 22
		'cmdForeground.Caption = "..."
		cmdForeground.OnClick = @cmdForeground_Click
		cmdForeground.Parent = @hbxForeground
		' cmdFont
		cmdFont.Name = "cmdFont"
		cmdFont.Text = "..."
		cmdFont.ExtraMargins.Bottom = 10
		cmdFont.ExtraMargins.Right = 10
		cmdFont.Align = DockStyle.alRight
		cmdFont.ExtraMargins.Top = 20
		cmdFont.TabIndex = 138
		cmdFont.SetBounds 383, 20, 24, 16
		'cmdFont.Caption = "..."
		cmdFont.OnClick = @cmdFont_Click
		cmdFont.Parent = @grbFont
		' lblFont
		lblFont.Name = "lblFont"
		lblFont.Text = ML("Font")
		lblFont.Align = DockStyle.alClient
		lblFont.ExtraMargins.Left = 10
		lblFont.ExtraMargins.Top = 20
		lblFont.ExtraMargins.Bottom = 10
		lblFont.CenterImage = True
		lblFont.TabIndex = 139
		lblFont.SetBounds 10, 20, 373, 16
		lblFont.Parent = @grbFont
		'cmdProjectsPath.Caption = "..."
		' chkBackground
		chkBackground.Name = "chkBackground"
		chkBackground.Text = ML("Auto")
		chkBackground.Align = DockStyle.alRight
		chkBackground.ExtraMargins.Left = 5
		chkBackground.TabIndex = 47
		chkBackground.SetBounds 106, 0, 48, 24
		chkBackground.OnClick = @chkBackground_Click
		chkBackground.Parent = @hbxBackground
		' txtColorBackground
		txtColorBackground.Name = "txtColorBackground"
		txtColorBackground.Align = DockStyle.alClient
		txtColorBackground.TabIndex = 48
		txtColorBackground.SetBounds 0, 0, 77, 24
		txtColorBackground.BackColor = 0
		txtColorBackground.Text = ""
		txtColorBackground.Designer = @This
		txtColorBackground.OnKeyPress = @_txtColorBackground_KeyPress
		txtColorBackground.Parent = @hbxBackground
		' cmdBackground
		cmdBackground.Name = "cmdBackground"
		cmdBackground.Text = "..."
		cmdBackground.Align = DockStyle.alRight
		cmdBackground.TabIndex = 49
		cmdBackground.SetBounds 77, 0, 24, 24
		'cmdBackground.Caption = "..."
		cmdBackground.OnClick = @cmdBackground_Click
		cmdBackground.Parent = @hbxBackground
		' hbxThemeCommands
		With hbxThemeCommands
			.Name = "hbxThemeCommands"
			.Text = "HorizontalBox1"
			.TabIndex = 219
			.ControlIndex = 0
			.Align = DockStyle.alTop
			.ExtraMargins.Bottom = 14
			.SetBounds 0, 0, 154, 23
			.Designer = @This
			.Parent = @vbxColors
		End With
		' lblForeground
		lblForeground.Name = "lblForeground"
		lblForeground.Text = ML("Foreground") & ":"
		lblForeground.ControlIndex = 1
		lblForeground.Align = DockStyle.alTop
		lblForeground.TabIndex = 42
		lblForeground.SetBounds 0, 37, 154, 16
		lblForeground.Parent = @vbxColors
		' hbxForeground
		With hbxForeground
			.Name = "hbxForeground"
			.Text = "HorizontalBox1"
			.TabIndex = 224
			.ControlIndex = 2
			.Align = DockStyle.alTop
			.SetBounds 0, 53, 154, 22
			.Designer = @This
			.Parent = @vbxColors
		End With
		' lblBackground
		lblBackground.Name = "lblBackground"
		lblBackground.Text = ML("Background") & ":"
		lblBackground.ControlIndex = 3
		lblBackground.Align = DockStyle.alTop
		lblBackground.ExtraMargins.Top = 2
		lblBackground.TabIndex = 46
		lblBackground.SetBounds 0, 77, 154, 16
		lblBackground.Parent = @vbxColors
		' hbxBackground
		With hbxBackground
			.Name = "hbxBackground"
			.Text = "HorizontalBox1"
			.TabIndex = 225
			.ControlIndex = 4
			.Align = DockStyle.alTop
			.SetBounds 0, 93, 154, 24
			.Designer = @This
			.Parent = @vbxColors
		End With
		' lblFrame
		With lblFrame
			.Name = "lblFrame"
			.Text = ML("Frame") & ":"
			.ControlIndex = 5
			.Align = DockStyle.alTop
			.ExtraMargins.Top = 2
			.TabIndex = 50
			.SetBounds 0, 119, 154, 16
			.Parent = @vbxColors
		End With
		' hbxFrame
		With hbxFrame
			.Name = "hbxFrame"
			.Text = "HorizontalBox1"
			.TabIndex = 226
			.ControlIndex = 6
			.Align = DockStyle.alTop
			.SetBounds 0, 135, 154, 23
			.Designer = @This
			.Parent = @vbxColors
		End With
		' lblIndicator
		lblIndicator.Name = "lblIndicator"
		lblIndicator.Text = ML("Indicator") & ":"
		lblIndicator.ControlIndex = 7
		lblIndicator.Align = DockStyle.alTop
		lblIndicator.ExtraMargins.Top = 2
		lblIndicator.TabIndex = 54
		lblIndicator.SetBounds 0, 160, 154, 16
		lblIndicator.Parent = @vbxColors
		' hbxIndicator
		With hbxIndicator
			.Name = "hbxIndicator"
			.Text = "HorizontalBox1"
			.TabIndex = 227
			.ControlIndex = 11
			.Align = DockStyle.alTop
			.SetBounds 0, 176, 154, 23
			.Designer = @This
			.Parent = @vbxColors
		End With
		' chkBold
		chkBold.Name = "chkBold"
		chkBold.Text = ML("Bold")
		chkBold.ControlIndex = 8
		chkBold.Align = DockStyle.alTop
		chkBold.ExtraMargins.Top = 5
		chkBold.TabIndex = 58
		chkBold.Constraints.Height = 21
		chkBold.AutoSize = true
		chkBold.SetBounds 0, 204, 75, 21
		chkBold.OnClick = @chkBold_Click
		chkBold.Parent = @vbxColors
		' chkItalic
		chkItalic.Name = "chkItalic"
		chkItalic.Text = ML("Italic")
		chkItalic.ControlIndex = 9
		chkItalic.Align = DockStyle.alTop
		chkItalic.TabIndex = 59
		chkItalic.Constraints.Height = 21
		chkItalic.AutoSize = true
		chkItalic.SetBounds 0, 225, 78, 21
		chkItalic.OnClick = @chkItalic_Click
		chkItalic.Parent = @vbxColors
		' chkUnderline
		chkUnderline.Name = "chkUnderline"
		chkUnderline.Text = ML("Underline")
		chkUnderline.ControlIndex = 10
		chkUnderline.Align = DockStyle.alTop
		chkUnderline.TabIndex = 60
		chkUnderline.Constraints.Height = 21
		chkUnderline.AutoSize = true
		chkUnderline.SetBounds 0, 246, 100, 21
		chkUnderline.OnClick = @chkUnderline_Click
		chkUnderline.Parent = @vbxColors
		' chkIndicator
		chkIndicator.Name = "chkIndicator"
		chkIndicator.Text = ML("Auto")
		chkIndicator.Align = DockStyle.alRight
		chkIndicator.ExtraMargins.Left = 5
		chkIndicator.TabIndex = 55
		chkIndicator.SetBounds 106, 0, 48, 23
		chkIndicator.OnClick = @chkIndicator_Click
		chkIndicator.Parent = @hbxIndicator
		' txtColorIndicator
		txtColorIndicator.Name = "txtColorIndicator"
		txtColorIndicator.Text = ""
		txtColorIndicator.Align = DockStyle.alClient
		txtColorIndicator.TabIndex = 56
		txtColorIndicator.SetBounds 0, 0, 77, 23
		txtColorIndicator.BackColor = 0
		txtColorIndicator.Designer = @This
		txtColorIndicator.OnKeyPress = @_txtColorIndicator_KeyPress
		txtColorIndicator.Parent = @hbxIndicator
		' cmdIndicator
		cmdIndicator.Name = "cmdIndicator"
		cmdIndicator.Text = "..."
		cmdIndicator.Align = DockStyle.alRight
		cmdIndicator.TabIndex = 57
		cmdIndicator.SetBounds 77, 0, 24, 23
		'cmdIndicator.Caption = "..."
		cmdIndicator.OnClick = @cmdIndicator_Click
		cmdIndicator.Parent = @hbxIndicator
		'
		' chkUseMakeOnStartWithCompile
		chkUseMakeOnStartWithCompile.Name = "chkUseMakeOnStartWithCompile"
		chkUseMakeOnStartWithCompile.Text = ML("Use make on start with compile (if exists makefile)")
		chkUseMakeOnStartWithCompile.Align = DockStyle.alTop
		chkUseMakeOnStartWithCompile.ExtraMargins.Top = 10
		chkUseMakeOnStartWithCompile.ExtraMargins.Bottom = 10
		chkUseMakeOnStartWithCompile.ExtraMargins.Left = 15
		chkUseMakeOnStartWithCompile.TabIndex = 140
		chkUseMakeOnStartWithCompile.Constraints.Height = 21
		chkUseMakeOnStartWithCompile.AutoSize = True
		chkUseMakeOnStartWithCompile.SetBounds 25, 66, 293, 21
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
		lvCompilerPaths.TabIndex = 141
			.SetBounds 15, 57, 387, 161
			.Images = @imgList
			'.StateImages = @imgList
			.SmallImages = @imgList
			.Designer = @This
			.OnItemActivate = @lvCompilerPaths_ItemActivate_
			.Parent = @grbCompilerPaths
		End With
		' lblCompiler32
		lblCompiler32.Name = "lblCompiler32"
		lblCompiler32.Text = ML("Compiler") & " " & ML("32-bit")
		lblCompiler32.Align = DockStyle.alTop
		lblCompiler32.TabIndex = 142
		lblCompiler32.SetBounds 15, 20, 387, 18
		lblCompiler32.Parent = @grbDefaultCompilers
		' cboCompiler32
		With cboCompiler32
			.Name = "cboCompiler32"
			.Text = "ComboBoxEdit2"
			.Align = DockStyle.alTop
			.TabIndex = 143
			.SetBounds 15, 38, 387, 21
			.Parent = @grbDefaultCompilers
		End With
		' lblCompiler64
		lblCompiler64.Name = "lblCompiler64"
		lblCompiler64.Text = ML("Compiler") & " " & ML("64-bit")
		lblCompiler64.Align = DockStyle.alTop
		lblCompiler64.ExtraMargins.Top = 10
		lblCompiler64.TabIndex = 144
		lblCompiler64.SetBounds 15, 69, 387, 18
		lblCompiler64.Parent = @grbDefaultCompilers
		' cboCompiler64
		With cboCompiler64
			.Name = "cboCompiler64"
			.Text = "ComboBoxEdit21"
			.Align = DockStyle.alTop
			.TabIndex = 145
			.SetBounds 15, 87, 387, 21
			.Parent = @grbDefaultCompilers
		End With
		' lvDebuggerPaths
		With lvDebuggerPaths
			.Name = "lvDebuggerPaths"
			.Text = "lvCompilerPaths1"
			.Align = DockStyle.alClient
			.ExtraMargins.Bottom = 15
		lvDebuggerPaths.TabIndex = 146
			.SetBounds 15, 22, 387, 121
			.Designer = @This
			.OnItemActivate = @lvDebuggerPaths_ItemActivate_
			.Parent = @grbDebuggerPaths
		End With
		' cmdClearDebuggers
		With cmdClearDebuggers
			.Name = "cmdClearDebuggers"
			.Text = ML("&Clear")
			.ExtraMargins.Bottom = 0
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 0
			.Align = DockStyle.alRight
			.TabIndex = 12
			.SetBounds 290, 0, 97, 24
			.OnClick = @cmdClearDebuggers_Click
			.Parent = @hbxDebugger
		End With
		' cmdRemoveDebugger
		With cmdRemoveDebugger
			.Name = "cmdRemoveDebugger"
			.Text = ML("&Remove")
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 0
			.ExtraMargins.Bottom = 0
			.Align = DockStyle.alRight
			.TabIndex = 13
			.SetBounds 193, 0, 97, 24
			.OnClick = @cmdRemoveDebugger_Click
			.Parent = @hbxDebugger
		End With
		' cmdChangeDebugger
		cmdChangeDebugger.Name = "cmdChangeDebugger"
		cmdChangeDebugger.Text = ML("Chan&ge")
		cmdChangeDebugger.ExtraMargins.Left = 0
		cmdChangeDebugger.ExtraMargins.Right = 0
		cmdChangeDebugger.Align = DockStyle.alRight
		cmdChangeDebugger.ExtraMargins.Bottom = 0
		cmdChangeDebugger.TabIndex = 14
		cmdChangeDebugger.SetBounds 96, 0, 97, 24
		cmdChangeDebugger.OnClick = @cmdChangeDebugger_Click
		cmdChangeDebugger.Parent = @hbxDebugger
		' cmdAddDebugger
		With cmdAddDebugger
			.Name = "cmdAddDebugger"
			.Text = ML("&Add")
			.ExtraMargins.Left = 0
			.ExtraMargins.Right = 0
			.Align = DockStyle.alRight
			.ExtraMargins.Bottom = 0
			.TabIndex = 15
			.SetBounds -1, 0, 97, 24
			.OnClick = @cmdAddDebugger_Click
			.Parent = @hbxDebugger
		End With
		' pnlInterfaceFont
		With pnlInterfaceFont
			.Name = "pnlInterfaceFont"
			.Text = "Panel2"
			.Align = DockStyle.alTop
			.ExtraMargins.Bottom = 20
			.AutoSize = True
			.TabIndex = 147
			.SetBounds 10, 20, 397, 20
			.Parent = @grbThemes
		End With
		' lblInterfaceFontLabel
		With lblInterfaceFontLabel
			.Name = "lblInterfaceFontLabel"
			.Text = ML("Interface font") & ":"
			.ControlIndex = 6
			.Align = DockStyle.alLeft
			.TabIndex = 148
			.SetBounds 0, 0, 108, 20
			.Parent = @pnlInterfaceFont
		End With
		' lblInterfaceFont
		With lblInterfaceFont
			.Name = "lblInterfaceFont"
			.Text = "Tahoma, 8 pt"
			.ControlIndex = 5
			.Align = DockStyle.alLeft
			.TabIndex = 149
			.SetBounds 108, 0, 264, 20
			'.Caption = "Tahoma, 8 pt"
			.Parent = @pnlInterfaceFont
		End With
		' cmdInterfaceFont
		With cmdInterfaceFont
			.Name = "cmdInterfaceFont"
			.Text = "..."
			.ControlIndex = 7
			.Align = DockStyle.alRight
			.TabIndex = 150
			.SetBounds 373, 0, 24, 20
			'.Caption = "..."
			.OnClick = @cmdInterfaceFont_Click
			.Parent = @pnlInterfaceFont
		End With
		' chkDisplayIcons
		With chkDisplayIcons
			.Name = "chkDisplayIcons"
			.Text = ML("Display Icons in the Menu")
			.Align = DockStyle.alTop
			.TabIndex = 151
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 10, 60, 177, 21
			.Parent = @grbThemes
		End With
		' chkShowMainToolbar
		With chkShowMainToolbar
			.Name = "chkShowMainToolbar"
			.Text = ML("Show main Toolbar")
			.Align = DockStyle.alTop
			.TabIndex = 152
			.Constraints.Height = 21
			.AutoSize = true
			.SetBounds 10, 81, 145, 21
			.Parent = @grbThemes
		End With
		'chkShowToolBoxLocal
		With chkShowToolBoxLocal
			.Name = "chkShowToolBoxLocal"
			.Text = ML("Display ToolBox in localized language.")
			.Align = DockStyle.alTop
			.TabIndex = 153
			.Constraints.Height = 21
			.AutoSize = true
			.SetBounds 10, 102, 235, 21
			.Parent = @grbThemes
		End With
		'chkShowPropLocal
		With chkShowPropLocal
			.Name = "chkShowPropLocal"
			.Text = ML("Display Property of Control in localized language.")
			.Align = DockStyle.alTop
			.TabIndex = 154
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 10, 122, 290, 21
			.Parent = @grbThemes
		End With
		' chkFrame
		With chkFrame
			.Name = "chkFrame"
			.Text = ML("Auto")
			.Align = DockStyle.alRight
			.ExtraMargins.Left = 5
			.TabIndex = 51
			.SetBounds 106, 0, 48, 23
			.OnClick = @chkFrame_Click
			.Parent = @hbxFrame
		End With
		' txtColorFrame
		With txtColorFrame
			.Name = "txtColorFrame"
			.Align = DockStyle.alClient
			.TabIndex = 52
			.SetBounds 0, 0, 77, 23
			.BackColor = 0
			.Designer = @This
			.OnKeyPress = @_txtColorFrame_KeyPress
			.Parent = @hbxFrame
		End With
		' cmdFrame
		With cmdFrame
			.Name = "cmdFrame"
			.Text = "..."
			.Align = DockStyle.alRight
			.TabIndex = 53
			.SetBounds 77, 0, 24, 23
			'.Caption = "..."
			.OnClick = @cmdFrame_Click
			.Parent = @hbxFrame
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
			.AutoSize = True
			.TabIndex = 155
			.SetBounds 10, 0, 417, 61
			.Parent = @pnlHelp
		End With
		' cboHelp
		With cboHelp
			.Name = "cboHelp"
			.Text = "cboHelp"
			.Align = DockStyle.alTop
			.TabIndex = 156
			.SetBounds 15, 22, 387, 21
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
			.TabIndex = 157
			.SetBounds 10, 66, 417, 334
			.Parent = @pnlHelp
		End With
		' lvHelpPaths
		With lvHelpPaths
			.Name = "lvHelpPaths"
			.Text = "lvTerminalPaths1"
			.ExtraMargins.Bottom = 15
			.Align = DockStyle.alClient
		lvHelpPaths.TabIndex = 158
			.SetBounds 15, 22, 387, 258
			.Designer = @This
			.OnItemActivate = @lvHelpPaths_ItemActivate_
			.Parent = @grbHelpPaths
		End With
		With cmdClearHelps
			.Name = "cmdClearHelps"
			.Text = ML("&Clear")
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 0
			.ExtraMargins.Bottom = 0
			.Align = DockStyle.alRight
			.TabIndex = 23
			.SetBounds 290, 0, 97, 24
			.OnClick = @cmdClearHelps_Click
			.Parent = @hbxHelp
		End With
		' cmdRemoveHelp
		With cmdRemoveHelp
			.Name = "cmdRemoveHelp"
			.Text = ML("&Remove")
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 0
			.ExtraMargins.Bottom = 0
			.Align = DockStyle.alRight
			.TabIndex = 24
			.SetBounds 193, 0, 97, 24
			.OnClick = @cmdRemoveHelp_Click
			.Parent = @hbxHelp
		End With
		' cmdChangeHelp
		With cmdChangeHelp
			.Name = "cmdChangeHelp"
			.Text = ML("Chan&ge")
			.ExtraMargins.Bottom = 0
			.ExtraMargins.Left = 0
			.ExtraMargins.Right = 0
			.Align = DockStyle.alRight
			.TabIndex = 25
			.SetBounds 96, 0, 97, 24
			.OnClick = @cmdChangeHelp_Click
			.Parent = @hbxHelp
		End With
		' cmdAddHelp
		With cmdAddHelp
			.Name = "cmdAddHelp"
			.Text = ML("&Add")
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 0
			.Align = DockStyle.alRight
			.ExtraMargins.Bottom = 0
			.TabIndex = 26
			.SetBounds -1, 0, 97, 24
			.OnClick = @cmdAddHelp_Click
			.Parent = @hbxHelp
		End With
		' cmdClearHelp
		' optSaveCurrentFile
		With optSaveCurrentFile
			.Name = "optSaveCurrentFile"
			.Text = ML("Save Current Project / File")
			.TabIndex = 62
			.SetBounds 18, 22, 184, 16
			.Parent = @grbWhenCompiling
		End With
		' optDoNotSave
		With optDoNotSave
			.Name = "optDoNotSave"
			.Text = ML("Don't Save")
			.TabIndex = 63
			.SetBounds 18, 90, 184, 16
			.Parent = @grbWhenCompiling
		End With
		' optSaveAllFiles
		With optSaveAllFiles
			.Name = "optSaveAllFiles"
			.Text = ML("Save All Files")
			.TabIndex = 64
			.SetBounds 18, 45, 184, 16
			.Parent = @grbWhenCompiling
		End With
		' pnlGrid
		With pnlGrid
			.Name = "pnlGrid"
			.Text = "Panel2"
			.TabIndex = 159
			.SetBounds 10, 63, 314, 56
			.Parent = @grbGrid
		End With
		' chkLimitDebug
		With chkLimitDebug
			.Name = "chkLimitDebug"
			.Text = ML("Limit debug to the directory of the main file")
			.Align = DockStyle.alTop
			.ExtraMargins.Top = 10
			.TabIndex = 160
			.Constraints.Height = 21
			.AutoSize = true
			.SetBounds 10, 138, 261, 21
			.Parent = @pnlDebugger
		End With
		' chkDisplayWarningsInDebug
		With chkDisplayWarningsInDebug
			.Name = "chkDisplayWarningsInDebug"
			.Text = ML("Display warnings in debug")
			.ExtraMargins.Top = 5
			.Align = DockStyle.alTop
			.TabIndex = 161
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 10, 159, 179, 21
			.Parent = @pnlDebugger
		End With
		' chkCreateNonStaticEventHandlers
		With chkCreateNonStaticEventHandlers
			.Name = "chkCreateNonStaticEventHandlers"
			.Text = ML("Create non-static event handlers")
			.TabIndex = 162
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
			.TabIndex = 163
			.SetBounds 22, 21, 260, 18
			.Parent = @grbDefaultDebuggers
		End With
		' cboDebugger1
		With cboDebugger64
			.Name = "cboDebugger64"
			.TabIndex = 164
			.SetBounds 18, 89, 184, 21
			.Parent = @grbDefaultDebuggers
		End With
		' lblDebugger64
		With lblDebugger64
			.Name = "lblDebugger64"
			.Text = ML("Debugger") & " " & ML("64-bit")
			.TabIndex = 165
			.SetBounds 22, 71, 260, 18
			.Parent = @grbDefaultDebuggers
		End With
		' grbOtherEditors
		With grbOtherEditors
			.Name = "grbOtherEditors"
			.Text = ML("Other Editors")
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 0
			.ExtraMargins.Left = 10
			.Margins.Top = 21
			.Margins.Right = 15
			.Margins.Left = 15
			.Margins.Bottom = 15
			.TabIndex = 166
			.SetBounds 10, 0, 417, 400
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
			.TabIndex = 167
			.SetBounds 15, 21, 387, 325
			.Designer = @This
			.OnItemActivate = @lvOtherEditors_ItemActivate_
			.Parent = @grbOtherEditors
		End With
		' cmdClearEditor
		With cmdClearEditor
			.Name = "cmdClearEditor"
			.Text = ML("&Clear")
			.ExtraMargins.Bottom = 0
			.ExtraMargins.Left = 0
			.ExtraMargins.Right = 0
			.Align = DockStyle.alRight
			.TabIndex = 27
			.SetBounds 290, 0, 97, 24
			.Designer = @This
			.OnClick = @cmdClearEditor_Click_
			.Parent = @hbxEditors
		End With
		' cmdRemoveEditor
		With cmdRemoveEditor
			.Name = "cmdRemoveEditor"
			.Text = ML("&Remove")
			.Align = DockStyle.alRight
			.ExtraMargins.Bottom = 0
			.ExtraMargins.Left = 0
			.ExtraMargins.Right = 0
			.TabIndex = 28
			.SetBounds 193, 0, 97, 24
			.Designer = @This
			.OnClick = @cmdRemoveEditor_Click_
			.Parent = @hbxEditors
		End With
		' cmdChangeEditor
		With cmdChangeEditor
			.Name = "cmdChangeEditor"
			.Text = ML("Chan&ge")
			.Align = DockStyle.alRight
			.ExtraMargins.Bottom = 0
			.ExtraMargins.Left = 0
			.ExtraMargins.Right = 0
			.TabIndex = 29
			.SetBounds 96, 0, 97, 24
			.Designer = @This
			.OnClick = @cmdChangeEditor_Click_
			.Parent = @hbxEditors
		End With
		' cmdAddEditor
		With cmdAddEditor
			.Name = "cmdAddEditor"
			.Text = ML("&Add")
			.Align = DockStyle.alRight
			.ExtraMargins.Left = 0
			.ExtraMargins.Bottom = 0
			.ExtraMargins.Right = 0
			.TabIndex = 30
			.SetBounds -1, 0, 97, 24
			'.Caption = "Add"
			.Designer = @This
			.OnClick = @cmdAddEditor_Click_
			.Parent = @hbxEditors
		End With
			'.Caption = "Change"
			'.Caption = "Remove"
			'.Caption = "Clear"
		' grbWhenVFBEStarts
		With grbWhenVFBEStarts
			.Name = "grbWhenVFBEStarts"
			.Text = ML("When Visual FB Editor starts") & ":"
			.Align = DockStyle.alTop
			.ExtraMargins.Top = 5
			'.Caption = ML("When Visual FB Editor starts") & ":"
			.TabIndex = 168
			.SetBounds 0, 97, 417, 120
			.Parent = @vbxGeneral
		End With
		' grbWhenCompiling
		With grbWhenCompiling
			.Name = "grbWhenCompiling"
			.Text = ML("When compiling") & ":"
			.Align = DockStyle.alTop
			.ExtraMargins.Top = 5
			.TabIndex = 169
			.SetBounds 0, 222, 417, 120
			.Parent = @vbxGeneral
		End With
		' lblProjectsPath
		lblProjectsPath.Name = "lblProjectsPath"
		lblProjectsPath.Text = ML("Projects path") & ":"
		lblProjectsPath.Align = DockStyle.alTop
		lblProjectsPath.ExtraMargins.Top = 5
		lblProjectsPath.TabIndex = 170
		lblProjectsPath.SetBounds 0, 347, 417, 16
		lblProjectsPath.Parent = @vbxGeneral
		' txtProjectsPath
		txtProjectsPath.Name = "txtProjectsPath"
		txtProjectsPath.Text = "./Projects"
		txtProjectsPath.Align = DockStyle.alClient
		txtProjectsPath.ExtraMargins.Bottom = 0
		txtProjectsPath.ExtraMargins.Right = 0
		txtProjectsPath.ControlIndex = 0
		txtProjectsPath.TabIndex = 2
		txtProjectsPath.SetBounds 0, 0, 394, 20
		txtProjectsPath.Parent = @pnlProjectsPath
		' cmdProjectsPath
		cmdProjectsPath.Name = "cmdProjectsPath"
		cmdProjectsPath.Text = "..."
		cmdProjectsPath.Align = DockStyle.alRight
		#ifdef __USE_WINAPI__
			cmdProjectsPath.ExtraMargins.Bottom = -1
			cmdProjectsPath.ExtraMargins.Top = -1
			cmdProjectsPath.ExtraMargins.Right = -1
		#endif
		cmdProjectsPath.ControlIndex = 1
		cmdProjectsPath.TabIndex = 3
		cmdProjectsPath.SetBounds 394, -1, 24, 22
		cmdProjectsPath.OnClick = @cmdProjectsPath_Click
		cmdProjectsPath.Parent = @pnlProjectsPath
		' optPromptForProjectAndFile
		With optPromptForProjectAndFile
			.Name = "optPromptForProjectAndFile"
			.Text = ML("Prompt for Project / File")
			.TabIndex = 171
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
			.TabIndex = 172
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
			.TabIndex = 173
			.SetBounds 19, 67, 184, 16
			.Designer = @This
			.OnClick = @optOpenLastSession_Click
			.Parent = @grbWhenVFBEStarts
		End With
		' optDoNotNothing
		With optDoNotNothing
			.Name = "optDoNotNothing"
			.Text = ML("Don't Nothing")
			.TabIndex = 174
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
			.TabIndex = 175
			.SetBounds 222, 41, 175, 21
			.Parent = @grbWhenVFBEStarts
		End With
		' cmdFindCompilers
		With cmdFindCompilers
			.Name = "cmdFindCompilers"
			.Text = ML("&Find")
			.TabIndex = 177
			.Align = DockStyle.alTop
			.ExtraMargins.Left = 300
			.ExtraMargins.Right = -1
			.SetBounds 315, 20, 88, 24
			'.Caption = ML("&Find")
			.Designer = @This
			.OnClick = @cmdFindCompilers_Click_
			.Parent = @grbCompilerPaths
		End With
		' lblFindCompilersFromComputer
		With lblFindCompilersFromComputer
			.Name = "lblFindCompilersFromComputer"
			.Text = ML("Find Compilers from Computer?")
			.TabIndex = 178
			.ExtraMargins.Top = -22
			.ExtraMargins.Right = 100
			.Align = DockStyle.alTop
			.SetBounds 15, 22, 287, 20
			'.Caption = ML("Find Compilers from Computer:")
			.Parent = @grbCompilerPaths
		End With
		' optPromptToSave
		With optPromptToSave
			.Name = "optPromptToSave"
			.Text = ML("Prompt To Save")
			.TabIndex = 176
			.SetBounds 18, 68, 184, 16
			'.Caption = ML("Prompt To Save")
			.Parent = @grbWhenCompiling
		End With
		' cboOpenedFile
		With cboOpenedFile
			.Name = "cboOpenedFile"
			.Text = "ComboBoxEdit1"
			.TabIndex = 179
			.SetBounds 222, 65, 175, 21
			.Parent = @grbWhenVFBEStarts
		End With
		' chkCreateFormTypesWithoutTypeWord
		With chkCreateFormTypesWithoutTypeWord
			.Name = "chkCreateFormTypesWithoutTypeWord"
			.Text = ML("Create Form types without Type word")
			.TabIndex = 180
			.SetBounds 12, 128, 288, 24
			'.Caption = ML("Create Form types without Type word")
			.Parent = @pnlDesigner
		End With
		' grbCommandPromptOptions
		With grbCommandPromptOptions
			.Name = "grbCommandPromptOptions"
			.Text = ML("Command Prompt options")
			.TabIndex = 181
			.Align = DockStyle.alTop
			.ExtraMargins.Top = 5
			.SetBounds 10, 69, 417, 94
			'.Caption = ML("Command Prompt options")
			.Parent = @pnlTerminal
		End With
		' optMainFileFolder
		With optMainFileFolder
			.Name = "optMainFileFolder"
			.Text = ML("Main File folder")
			.TabIndex = 182
			.SetBounds 20, 39, 220, 20
			'.Caption = ML("Main File folder")
			.Parent = @grbCommandPromptOptions
		End With
		' lblOpenCommandPromptIn
		With lblOpenCommandPromptIn
			.Name = "lblOpenCommandPromptIn"
			.Text = ML("Open command prompt in:")
			.TabIndex = 183
			.SetBounds 20, 19, 380, 20
			'.Caption = ML("Open command prompt in:")
			.Parent = @grbCommandPromptOptions
		End With
		' optInFolder
		With optInFolder
			.Name = "optInFolder"
			.Text = ML("Folder") & ":"
			.TabIndex = 184
			.SetBounds 20, 59, 120, 20
			'.Caption = ML("Folder:")
			.Parent = @grbCommandPromptOptions
		End With
		' txtInFolder
		With txtInFolder
			.Name = "txtInFolder"
			.Text = "./Projects"
			.TabIndex = 185
			.SetBounds 140, 58, 240, 20
			.Parent = @grbCommandPromptOptions
		End With
		' cmdInFolder
		With cmdInFolder
			.Name = "cmdInFolder"
			.Text = "..."
			.TabIndex = 186
			.SetBounds 380, 57, 24, 22
			.Designer = @This
			.OnClick = @cmdInFolder_Click_
			.Parent = @grbCommandPromptOptions
		End With
		' lblIntellisenseLimit
		With lblIntellisenseLimit
			.Name = "lblIntellisenseLimit"
			.Text = ML("Intellisense limit") & ":"
			.TabIndex = 187
			'.Caption = ML("Intellisense limit") & ":"
			.ExtraMargins.Top = 2
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 40
			.Align = DockStyle.alClient
			.SetBounds 40, 2, 175, 18
			.Parent = @pnlIntellisenseLimit
		End With
		' txtIntellisenseLimit
		With txtIntellisenseLimit
			.Name = "txtIntellisenseLimit"
			.TabIndex = 188
			.Text = ""
			.ExtraMargins.Left = 0
			.ExtraMargins.Top = 0
			.ExtraMargins.Right = 130
			.Align = DockStyle.alRight
			.ControlIndex = 2
			.ExtraMargins.Bottom = 2
			.SetBounds 215, 0, 72, 18
			.Parent = @pnlIntellisenseLimit
		End With
		' chkTurnOnEnvironmentVariables
		With chkTurnOnEnvironmentVariables
			.Name = "chkTurnOnEnvironmentVariables"
			.Text = ML("Turn on Environment variables") & ":"
			.TabIndex = 191
			'.Caption = ML("Turn on Environment variables") & ":"
			.ExtraMargins.Top = 5
			.Align = DockStyle.alTop
			.ExtraMargins.Right = 170
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 10, 180, 219, 21
			.Parent = @pnlDebugger
		End With
		' txtEnvironmentVariables
		With txtEnvironmentVariables
			.Name = "txtEnvironmentVariables"
			.Text = ""
			.TabIndex = 189
			.Align = DockStyle.alTop
			.ExtraMargins.Top = -18
			.ExtraMargins.Left = 230
			.ExtraMargins.Right = 15
			.SetBounds 240, 178, 172, 21
			.Parent = @pnlDebugger
		End With
		' lblDebugger321
		With lblDebugger321
			.Name = "lblDebugger321"
			.Text = ML("GDB") & " " & ML("32-bit")
			.TabIndex = 190
			'.Caption = ML("GDB") & " " & ML("32-bit")
			.SetBounds 222, 21, 180, 18
			.Parent = @grbDefaultDebuggers
		End With
		' cboGDBDebugger32
		With cboGDBDebugger32
			.Name = "cboGDBDebugger32"
			.Text = "cboCompiler321"
			.TabIndex = 192
			.SetBounds 218, 39, 184, 21
			.Parent = @grbDefaultDebuggers
		End With
		' lblDebugger641
		With lblDebugger641
			.Name = "lblDebugger641"
			.Text = ML("GDB") & " " & ML("64-bit")
			.TabIndex = 193
			'.Caption = ML("GDB") & " " & ML("64-bit")
			.SetBounds 222, 71, 180, 18
			.Parent = @grbDefaultDebuggers
		End With
		' cboGDBDebugger64
		With cboGDBDebugger64
			.Name = "cboGDBDebugger64"
			.Text = "cboDebugger64"
			.TabIndex = 194
			.SetBounds 218, 89, 184, 21
			.Parent = @grbDefaultDebuggers
		End With
		' chkDarkMode
		With chkDarkMode
			.Name = "chkDarkMode"
			.Text = ML("Dark Mode (available for Linux, Windows 10 and above)")
			.TabIndex = 195
			'.Caption = ML("Dark Mode")
			'.Caption = ML("Dark Mode (available for Linux, Windows 10 and above)")
			.Align = DockStyle.alTop
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 10, 142, 323, 21
			.Parent = @grbThemes
		End With
		' chkPlaceStaticEventHandlersAfterTheConstructor
		With chkPlaceStaticEventHandlersAfterTheConstructor
			.Name = "chkPlaceStaticEventHandlersAfterTheConstructor"
			.Text = ML("Place static event handlers after the Constructor")
			.TabIndex = 196
			'.Caption = ML("Place static event handlers after the Constructor")
			.SetBounds 32, 172, 310, 24
			.Parent = @pnlDesigner
		End With
		' chkCreateStaticEventHandlersWithAnUnderscoreAtTheBeginning
		With chkCreateStaticEventHandlersWithAnUnderscoreAtTheBeginning
			.Name = "chkCreateStaticEventHandlersWithAnUnderscoreAtTheBeginning"
			.Text = ML("Create static event handlers with an underscore at the beginning")
			.TabIndex = 197
			'.Caption = ML("Create static event handlers with an underscore at the beginning")
			.SetBounds 32, 195, 380, 24
			.Parent = @pnlDesigner
		End With
		' txtHistoryCodeDays
		With txtHistoryCodeDays
			.Name = "txtHistoryCodeDays"
			.Text = "3"
			.TabIndex = 198
			.ExtraMargins.Top = 0
			.ExtraMargins.Right = 130
			.ExtraMargins.Left = 0
			.Align = DockStyle.alRight
			.ExtraMargins.Bottom = 2
			.SetBounds 215, 0, 72, 18
			.Designer = @This
			.Parent = @pnlHistoryFileSavingDays
		End With
		' cmdUpdateLng
		With cmdUpdateLng
			.Name = "cmdUpdateLng"
			.Text = ML("Scan and Update")
			.TabIndex = 200
			.Hint = ML("Scan the text string in source code and update languages files")
			#ifdef __USE_WINAPI__
				.ExtraMargins.Top = -1
				.ExtraMargins.Bottom = -1
			#endif
			.ExtraMargins.Left = 0
			.Align = DockStyle.alRight
			.ExtraMargins.Right = 0
			.SetBounds 257, -1, 130, 23
			.Designer = @This
			.OnClick = @cmdUpdateLng_Click_
			.Parent = @pnlLanguage
		End With
		' chkAllLNG
		With chkAllLNG
			.Name = "chkAllLNG"
			.Text = ML("Update all language file (*.lng)")
			.TabIndex = 201
			.Checked = False
			.Align = DockStyle.alTop
			.ExtraMargins.Top = 5
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 15, 48, 217, 21
			.Designer = @This
			.Parent = @grbLanguage
		End With
		' cmdUpdateLngVFPFolds1
		' cmdUpdateLngHTMLFolds1
			
			
		' cmdReplaceInFiles
		' cmdReplaceInFiles1
		' lblShowMsg
		With lblShowMsg
			.Name = "lblShowMsg"
			.Text = ""
			.TabIndex = 202
			.Caption = ""
			.Align = DockStyle.alTop
			.ExtraMargins.Top = 10
			.SetBounds 15, 78, 387, 20
			.Designer = @This
			.Parent = @grbLanguage
		End With
		' pnlLine
		With pnlLine
			.Name = "pnlLine"
			.Text = "Panel2"
			.TabIndex = 203
			.Align = DockStyle.alBottom
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.BackColor = 16777215
			.SetBounds 10, 413, 605, 2
			.Designer = @This
			.Parent = @This
		End With
		' pnlProjectsPath
		With pnlProjectsPath
			.Name = "pnlProjectsPath"
			.Text = "Panel1"
			.TabIndex = 204
			.Align = DockStyle.alTop
			.AutoSize = True
			.ControlIndex = 7
			.SetBounds 0, 363, 417, 20
			.Designer = @This
			.Parent = @vbxGeneral
		End With
		' pnlSelectShortcut
		With pnlSelectShortcut
			.Name = "pnlSelectShortcut"
			.Text = "Panel1"
			.TabIndex = 205
			.Align = DockStyle.alBottom
			.AutoSize = True
			.SetBounds 15, 365, 387, 20
			.Designer = @This
			.Parent = @grbShortcuts
		End With
		' pnlChangeKeywordsCase
		With pnlChangeKeywordsCase
			.Name = "pnlChangeKeywordsCase"
			.Text = "Panel1"
			.TabIndex = 206
			.Align = DockStyle.alTop
			.AutoSize = True
			.SetBounds 0, 233, 417, 23
			.Designer = @This
			.Parent = @vbxCodeEditor
		End With
		' lblHistoryDay
		With lblHistoryDay
			.Name = "lblHistoryDay"
			.Text = ML("History file saving days") & ":"
			.TabIndex = 199
			.ExtraMargins.Top = 2
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 40
			.Align = DockStyle.alClient
			.ControlIndex = 0
			'.Caption = ML("History file saving days") & ":"
			.SetBounds 40, 2, 175, 18
			.Designer = @This
			.Parent = @pnlHistoryFileSavingDays
		End With
		' pnlTreatTabAsSpaces
		With pnlTreatTabAsSpaces
			.Name = "pnlTreatTabAsSpaces"
			.Text = "Panel1"
			.TabIndex = 207
			.Align = DockStyle.alTop
			.AutoSize = True
			.SetBounds 0, 256, 417, 23
			.Designer = @This
			.Parent = @vbxCodeEditor
		End With
		' pnlTabSize
		With pnlTabSize
			.Name = "pnlTabSize"
			.Text = "Panel1"
			.TabIndex = 208
			.Align = DockStyle.alTop
			.AutoSize = True
			.SetBounds 0, 279, 417, 20
			.Designer = @This
			.Parent = @vbxCodeEditor
		End With
		' pnlHistoryLimit
		With pnlHistoryLimit
			.Name = "pnlHistoryLimit"
			.Text = "Panel1"
			.TabIndex = 211
			.Align = DockStyle.alTop
			.AutoSize = True
			.SetBounds 0, 299, 417, 20
			.Designer = @This
			.Parent = @vbxCodeEditor
		End With
		' pnlIntellisenseLimit
		With pnlIntellisenseLimit
			.Name = "pnlIntellisenseLimit"
			.Text = "Panel1"
			.TabIndex = 215
			.Align = DockStyle.alTop
			.AutoSize = True
			.SetBounds 0, 319, 417, 20
			.Designer = @This
			.Parent = @vbxCodeEditor
		End With
		' pnlHistoryFileSavingDays
		With pnlHistoryFileSavingDays
			.Name = "pnlHistoryFileSavingDays"
			.Text = "Panel1"
			.TabIndex = 218
			.Align = DockStyle.alTop
			.AutoSize = True
			.SetBounds 0, 339, 417, 20
			.Designer = @This
			.Parent = @vbxCodeEditor
		End With
		lvShortcuts.Columns.Add ML("Action"), , 250
		lvShortcuts.Columns.Add ML("Shortcut"), , 100
		lvOtherEditors.Columns.Add ML("Version"), , 126
		lvOtherEditors.Columns.Add ML("Extensions"), , 126
		lvOtherEditors.Columns.Add ML("Path"), , 126
		lvOtherEditors.Columns.Add ML("Command line"), , 80
		lvCompilerPaths.Columns.Add ML("Version"), , 190
		lvCompilerPaths.Columns.Add ML("Path"), , 190
		lvCompilerPaths.Columns.Add ML("Command line"), , 80
		lvMakeToolPaths.Columns.Add ML("Version"), , 190
		lvMakeToolPaths.Columns.Add ML("Path"), , 190
		lvMakeToolPaths.Columns.Add ML("Command line"), , 80
		lvDebuggerPaths.Columns.Add ML("Version"), , 190
		lvDebuggerPaths.Columns.Add ML("Path"), , 190
		lvDebuggerPaths.Columns.Add ML("Command line"), , 80
		lvTerminalPaths.Columns.Add ML("Version"), , 190
		lvTerminalPaths.Columns.Add ML("Path"), , 190
		lvTerminalPaths.Columns.Add ML("Command line"), , 80
		lvHelpPaths.Columns.Add ML("Version"), , 190
		lvHelpPaths.Columns.Add ML("Path"), , 190
		' hbxEditors
		With hbxEditors
			.Name = "hbxEditors"
			.Text = "HorizontalBox1"
			.TabIndex = 209
			.Align = DockStyle.alBottom
			.SetBounds 15, 361, 387, 24
			.Designer = @This
			.Parent = @grbOtherEditors
		End With
		' hbxCompilers
		With hbxCompilers
			.Name = "hbxCompilers"
			.Text = "HorizontalBox1"
			.TabIndex = 210
			.Align = DockStyle.alBottom
			.SetBounds 15, 233, 387, 24
			.Designer = @This
			.Parent = @grbCompilerPaths
		End With
		' hbxHelp
		With hbxHelp
			.Name = "hbxHelp"
			.Text = "HorizontalBox1"
			.TabIndex = 212
			.Align = DockStyle.alBottom
			.SetBounds 15, 295, 387, 24
			.Designer = @This
			.Parent = @grbHelpPaths
		End With
		' hbxTerminal
		With hbxTerminal
			.Name = "hbxTerminal"
			.Text = "HorizontalBox1"
			.TabIndex = 213
			.Align = DockStyle.alBottom
			.SetBounds 15, 193, 387, 24
			.Designer = @This
			.Parent = @grbTerminalPaths
		End With
		' hbxDebugger
		With hbxDebugger
			.Name = "hbxDebugger"
			.Text = "HorizontalBox1"
			.TabIndex = 214
			.Align = DockStyle.alBottom
			.SetBounds 15, 158, 387, 24
			.Designer = @This
			.Parent = @grbDebuggerPaths
		End With
		' hbxMakeTool
		With hbxMakeTool
			.Name = "hbxMakeTool"
			.Text = "HorizontalBox1"
			.TabIndex = 216
			.Align = DockStyle.alBottom
			.SetBounds 15, 269, 387, 24
			.Designer = @This
			.Parent = @grbMakeToolPaths
		End With
		' hbxColors
		With hbxColors
			.Name = "hbxColors"
			.Text = "HorizontalBox1"
			.TabIndex = 217
			.Align = DockStyle.alClient
			.SetBounds 15, 21, 387, 313
			.Designer = @This
			.Parent = @grbColors
		End With
		' vbxTheme
		With vbxTheme
			.Name = "vbxTheme"
			.Text = "VerticalBox1"
			.TabIndex = 222
			.Align = DockStyle.alClient
			.SetBounds 0, 0, 227, 313
			.Designer = @This
			.Parent = @hbxColors
		End With
		' vbxColors
		With vbxColors
			.Name = "vbxColors"
			.Text = "VerticalBox1"
			.TabIndex = 223
			.ControlIndex = 0
			.Align = DockStyle.alNone
			.SetBounds 0, 0, 154, 252
			.Designer = @This
			.Parent = @sccColors
		End With
		' sccColors
		With sccColors
			.Name = "sccColors"
			.Text = "ScrollControl1"
			.TabIndex = 220
			.Align = DockStyle.alRight
			.SetBounds 227, 0, 160, 313
			.Designer = @This
			.Parent = @hbxColors
		End With
		' pnlAutoSaveCharMax
		With pnlAutoSaveCharMax
			.Name = "pnlAutoSaveCharMax"
			.Text = "Panel1"
			.TabIndex = 230
			.Align = DockStyle.alTop
			.ControlIndex = 18
			.SetBounds 0, 337, 420, 20
			.Designer = @This
			.Parent = @vbxCodeEditor
		End With
		' lbAutoSaveCharMax
		With lbAutoSaveCharMax
			.Name = "lbAutoSaveCharMax"
			.Text = ML("Autosave after entered chars") & ": "
			.ExtraMargins.Top = 2
			.ExtraMargins.Left = 40
			.ExtraMargins.Right = 0
			.Align = DockStyle.alClient
			.TabIndex = 231
			.SetBounds 40, 2, 175, 18
			.Parent = @pnlAutoSaveCharMax
		End With
		' txtAutoSaveCharMax
		With txtAutoSaveCharMax
			.Name = "txtAutoSaveCharMax"
			.ExtraMargins.Top = 0
			.ExtraMargins.Right = 130
			.ExtraMargins.Left = 0
			.Align = DockStyle.alRight
			.ExtraMargins.Bottom = 2
			.TabIndex = 232
			.SetBounds 215, 0, 72, 18
			.Text = "100"
			.Parent = @pnlAutoSaveCharMax
		End With
		' chkCreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt
		With chkCreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt
			.Name = "chkCreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt"
			.Text = ML("Create event handlers without static event handler if event allows it")
			.TabIndex = 233
			.ControlIndex = 4
			.Caption = ML("Create event handlers without static event handler if event allows it")
			.SetBounds 32, 219, 380, 24
			.Designer = @This
			.Parent = @pnlDesigner
		End With
	End Constructor
	
	Private Sub frmOptions._txtColorIndicator_KeyPress(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer)
		(*Cast(frmOptions Ptr, Sender.Designer)).txtColorIndicator_KeyPress(Sender, Key)
	End Sub
	
	Private Sub frmOptions._txtColorFrame_KeyPress(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer)
		(*Cast(frmOptions Ptr, Sender.Designer)).txtColorFrame_KeyPress(Sender, Key)
	End Sub
	
	Private Sub frmOptions._txtColorBackground_KeyPress(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer)
		(*Cast(frmOptions Ptr, Sender.Designer)).txtColorBackground_KeyPress(Sender, Key)
	End Sub
	
	Private Sub frmOptions._txtColorForeground_KeyPress(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer)
		(*Cast(frmOptions Ptr, Sender.Designer)).txtColorForeground_KeyPress(Sender, Key)
	End Sub
	
	Private Sub frmOptions.cmdUpdateLng_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		(*Cast(frmOptions Ptr, Sender.Designer)).cmdUpdateLng_Click(Sender)
	End Sub
	
	Private Sub frmOptions.chkCreateNonStaticEventHandlers_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
		(*Cast(frmOptions Ptr, Sender.Designer)).chkCreateNonStaticEventHandlers_Click(Sender)
	End Sub
	
	Destructor frmOptions
		FDisposing = True
		WDeAllocate(InterfFontName)
		WDeAllocate(oldInterfFontName)
		WDeAllocate(EditFontName)
	End Destructor
	
	#ifndef _NOT_AUTORUN_FORMS_
		fOptions.Show
		
		App.Run
	#endif
'#End Region

Private Sub frmOptions.cmdOK_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	cmdApply_Click(Designer, Sender)
	fOptions.CloseForm
End Sub

Private Sub frmOptions.cmdCancel_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	fOptions.cboTheme.ItemIndex = fOptions.cboTheme.IndexOf(*CurrentTheme)
	fOptions.cboTheme_Change(Designer, Sender)
	fOptions.CloseForm
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
		.TreeView1_SelChange *.tvOptions.Designer, .tvOptions, * (.tvOptions.Nodes.Item(0))
		.chkTabAsSpaces.Checked = TabAsSpaces
		.cboTabStyle.ItemIndex = ChoosedTabStyle
		.cboCase.ItemIndex = ChoosedKeyWordsCase
		.chkSyntaxHighlightingIdentifiers.Checked = SyntaxHighlightingIdentifiers 
		.chkChangeIdentifiersCase.Checked = ChangeIdentifiersCase
		.chkChangeKeywordsCase.Checked = ChangeKeyWordsCase
		.chkAddSpacesToOperators.Checked = AddSpacesToOperators
		.chkUseMakeOnStartWithCompile.Checked = UseMakeOnStartWithCompile
		.chkLimitDebug.Checked = LimitDebug
		.chkTurnOnEnvironmentVariables.Checked = TurnOnEnvironmentVariables
		.txtEnvironmentVariables.Text = *EnvironmentVariables
		.txtTabSize.Text = Str(TabWidth)
		.txtHistoryLimit.Text = Str(HistoryLimit)
		.txtIntellisenseLimit.Text = Str(IntellisenseLimit)
		.txtHistoryCodeDays.Text = Str(HistoryCodeDays)
		.txtAutoSaveCharMax.Text = Str(AutoSaveCharMax)
		.txtMFFpath.Text = *MFFPath
		.chkIncludeMFFPath.Checked = IncludeMFFPath
		.txtProjectsPath.Text = *ProjectsPath
		.CheckBox1.Checked = AutoIncrement
		.chkEnableAutoComplete.Checked = AutoComplete
		.chkEnableAutoSuggestions.Checked = AutoSuggestions
		.chkAutoIndentation.Checked = AutoIndentation
		.chkAutoCreateRC.Checked = AutoCreateRC
		.chkAutoCreateBakFiles.Checked = AutoCreateBakFiles
		.chkAddRelativePathsToRecent.Checked = AddRelativePathsToRecent
		.chkCreateNonStaticEventHandlers.Checked = CreateNonStaticEventHandlers
		.chkPlaceStaticEventHandlersAfterTheConstructor.Checked = PlaceStaticEventHandlersAfterTheConstructor
		.chkCreateStaticEventHandlersWithAnUnderscoreAtTheBeginning.Checked = CreateStaticEventHandlersWithAnUnderscoreAtTheBeginning
		.chkCreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt.Checked = CreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt
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
		.chkShowHorizontalSeparatorLines.Checked = ShowHorizontalSeparatorLines
		.chkHighlightBrackets.Checked = HighlightBrackets
		.chkHighlightCurrentLine.Checked = HighlightCurrentLine
		.chkHighlightCurrentWord.Checked = HighlightCurrentWord
		.txtGridSize.Text = Str(GridSize)
		.chkShowAlignmentGrid.Checked = ShowAlignmentGrid
		.chkSnapToGrid.Checked = SnapToGridOption
		.cboLanguage.Clear
		.chkDisplayIcons.Checked = DisplayMenuIcons
		.chkShowMainToolbar.Checked = ShowMainToolBar
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
		'WDeAllocate(s) '
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
		AddColors ColorLineLabels, , , , False
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
		AddColors RealNumbers, , , , False
		AddColors ColorOperators, , , , False
		AddColors Selection, , , , False, False, False, False
		AddColors SpaceIdentifiers, , , , False, False, False, False
		AddColors Strings, , , , False
		
		.lstColorKeys.ItemIndex = 0
		.lstColorKeys_Change(*.lstColorKeys.Designer, .lstColorKeys)
		WLet(.EditFontName, *EditorFontName)
		.EditFontSize = EditorFontSize
		.lblFont.Font.Name = *EditorFontName
		.lblFont.Caption = * (.EditFontName) & ", " & .EditFontSize & "pt"
		WLet(.InterfFontName, *InterfaceFontName)
		WLet(.oldInterfFontName, *InterfaceFontName)
		.InterfFontSize = InterfaceFontSize
		.oldInterfFontSize = InterfaceFontSize
		.oldDisplayMenuIcons = DisplayMenuIcons
		.oldDarkMode = DarkMode
		.lblInterfaceFont.Font.Name = *InterfaceFontName
		.lblInterfaceFont.Caption = * (.InterfFontName) & ", " & .InterfFontSize & "pt"
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

Private Sub frmOptions.Form_Create(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
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
		.cboCase.Clear
		.cboCase.AddItem ML("Original Case")
		.cboCase.AddItem ML("Lower Case")
		.cboCase.AddItem ML("Upper Case")
		.cboTabStyle.Clear
		.cboTabStyle.AddItem ML("Everywhere")
		.cboTabStyle.AddItem ML("Only after the words")
		.lstColorKeys.Clear
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
		.lstColorKeys.AddItem ML("Identifiers") & ": " & ML("Line Labels")
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
		.lstColorKeys.AddItem ML("Real Numbers")
		.lstColorKeys.AddItem ML("Operators")
		.lstColorKeys.AddItem ML("Selection")
		.lstColorKeys.AddItem ML("Space Identifiers")
		.lstColorKeys.AddItem ML("Strings")
		ReDim .Colors(.lstColorKeys.Items.Count - 1, 7)
		.lstColorKeys.ItemIndex = 0
		.cboOpenedFile.Clear
		.cboOpenedFile.AddItem ML("All file types")
		.cboOpenedFile.AddItem ML("Session file")
		.cboOpenedFile.AddItem ML("Folder")
		.cboOpenedFile.AddItem ML("Project file")
		.cboOpenedFile.AddItem ML("Other file types")
		For i As Integer = 0 To pfrmMain->Menu->Count - 1
			AddShortcuts(pfrmMain->Menu->Item(i))
		Next
		.LoadSettings
		cboDefaultProjectFileCheckEnable
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
		SetColor ColorLineLabels
		SetColor ColorLocalVariables
		SetColor ColorMacros
		SetColor ColorGlobalNamespaces
		SetColor ColorProperties
		SetColor ColorSharedVariables
		SetColor ColorSubs
		SetColor ColorGlobalTypes
		SetColor IndicatorLines
		For k As Integer = 0 To UBound(Keywords)
			SetColor Keywords(k)
		Next k
		SetColor LineNumbers
		SetColor NormalText
		SetColor Numbers
		SetColor RealNumbers
		SetColor ColorOperators
		SetColor Selection
		SetColor SpaceIdentifiers
		SetColor Strings
		SetAutoColors
	End With
End Sub

Private Sub frmOptions.cmdApply_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	On Error Goto ErrorHandler
	Dim As ToolType Ptr Tool
	With fOptions
		For i As Integer = 0 To pCompilers->Count - 1
			_Delete(Cast(ToolType Ptr, pCompilers->Item(i)->Object))
		Next
		pCompilers->Clear
		Dim As UString tempStr
		For i As Integer = 0 To .lvCompilerPaths.ListItems.Count - 1
			tempStr = .lvCompilerPaths.ListItems.Item(i)->Text(0)
			Tool = _New(ToolType)
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
			_Delete(Cast(ToolType Ptr, pMakeTools->Item(i)->Object))
		Next
		pMakeTools->Clear
		For i As Integer = 0 To .lvMakeToolPaths.ListItems.Count - 1
			tempStr = .lvMakeToolPaths.ListItems.Item(i)->Text(0)
			Tool = _New(ToolType)
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
			_Delete(Cast(ToolType Ptr, pDebuggers->Item(i)->Object))
		Next
		pDebuggers->Clear
		For i As Integer = 0 To .lvDebuggerPaths.ListItems.Count - 1
			tempStr = .lvDebuggerPaths.ListItems.Item(i)->Text(0)
			Tool = _New(ToolType)
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
			_Delete(Cast(ToolType Ptr, pTerminals->Item(i)->Object))
		Next
		pTerminals->Clear
		For i As Integer = 0 To .lvTerminalPaths.ListItems.Count - 1
			tempStr = .lvTerminalPaths.ListItems.Item(i)->Text(0)
			Tool = _New(ToolType)
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
			_Delete(Cast(ToolType Ptr, pOtherEditors->Item(i)->Object))
		Next
		pOtherEditors->Clear
		For i As Integer = 0 To .lvOtherEditors.ListItems.Count - 1
			tempStr = .lvOtherEditors.ListItems.Item(i)->Text(0)
			Tool = _New(ToolType)
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
		WLet(MFFPath, .txtMFFpath.Text)
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
		AutoSaveCharMax = Val(.txtAutoSaveCharMax.Text)
		UseMakeOnStartWithCompile = .chkUseMakeOnStartWithCompile.Checked
		LimitDebug = .chkLimitDebug.Checked
		DisplayWarningsInDebug = .chkDisplayWarningsInDebug.Checked
		TurnOnEnvironmentVariables = .chkTurnOnEnvironmentVariables.Checked
		WLet(EnvironmentVariables, .txtEnvironmentVariables.Text)
		AutoIncrement = .CheckBox1.Checked
		AutoIndentation = .chkAutoIndentation.Checked
		AutoComplete = .chkEnableAutoComplete.Checked
		AutoSuggestions = .chkEnableAutoSuggestions.Checked
		AutoCreateRC = .chkAutoCreateRC.Checked
		AutoCreateBakFiles = .chkAutoCreateBakFiles.Checked
		AddRelativePathsToRecent = .chkAddRelativePathsToRecent.Checked
		CreateNonStaticEventHandlers = .chkCreateNonStaticEventHandlers.Checked
		PlaceStaticEventHandlersAfterTheConstructor = .chkPlaceStaticEventHandlersAfterTheConstructor.Checked
		CreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt = .chkCreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt.Checked
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
		ShowHorizontalSeparatorLines = .chkShowHorizontalSeparatorLines.Checked
		HighlightBrackets = .chkHighlightBrackets.Checked
		HighlightCurrentLine = .chkHighlightCurrentLine.Checked
		HighlightCurrentWord = .chkHighlightCurrentWord.Checked
		TabAsSpaces = .chkTabAsSpaces.Checked
		ChoosedTabStyle = .cboTabStyle.ItemIndex
		GridSize = Val(.txtGridSize.Text)
		ShowAlignmentGrid = .chkShowAlignmentGrid.Checked
		SnapToGridOption = .chkSnapToGrid.Checked
		SyntaxHighlightingIdentifiers = .chkSyntaxHighlightingIdentifiers.Checked
		ChangeIdentifiersCase = .chkChangeIdentifiersCase.Checked
		ChangeKeyWordsCase = .chkChangeKeywordsCase.Checked
		ChoosedKeyWordsCase = .cboCase.ItemIndex
		AddSpacesToOperators = .chkAddSpacesToOperators.Checked
		WLet(CurrentTheme, .cboTheme.Text)
		WLet(EditorFontName, * (.EditFontName))
		EditorFontSize = .EditFontSize
		WLet(InterfaceFontName, * (.InterfFontName))
		InterfaceFontSize = .InterfFontSize
		DisplayMenuIcons = .chkDisplayIcons.Checked
		ShowMainToolBar = .chkShowMainToolbar.Checked
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
		piniSettings->WriteInteger "Options", "AutoSaveCharMax", AutoSaveCharMax
		piniSettings->WriteInteger "Options", "HistoryCodeCleanDay", HistoryCodeCleanDay
		piniSettings->WriteBool "Options", "UseMakeOnStartWithCompile", UseMakeOnStartWithCompile
		piniSettings->WriteBool "Options", "LimitDebug", LimitDebug
		piniSettings->WriteBool "Options", "DisplayWarningsInDebug", DisplayWarningsInDebug
		piniSettings->WriteBool "Options", "TurnOnEnvironmentVariables", TurnOnEnvironmentVariables
		piniSettings->WriteString "Options", "EnvironmentVariables", *EnvironmentVariables
		piniSettings->WriteBool "Options", "AutoIncrement", AutoIncrement
		piniSettings->WriteBool "Options", "AutoIndentation", AutoIndentation
		piniSettings->WriteBool "Options", "AutoComplete", AutoComplete
		piniSettings->WriteBool "Options", "AutoSuggestions", AutoSuggestions
		piniSettings->WriteBool "Options", "AutoCreateRC", AutoCreateRC
		piniSettings->WriteBool "Options", "AutoCreateBakFiles", AutoCreateBakFiles
		piniSettings->WriteBool "Options", "AddRelativePathsToRecent", AddRelativePathsToRecent
		piniSettings->WriteString "Options", "DefaultProjectFile", WGet(DefaultProjectFile)
		piniSettings->WriteInteger "Options", "LastOpenedFileType", LastOpenedFileType
		piniSettings->WriteInteger "Options", "WhenVisualFBEditorStarts", WhenVisualFBEditorStarts
		piniSettings->WriteInteger "Options", "AutoSaveBeforeCompiling", AutoSaveBeforeCompiling
		piniSettings->WriteBool "Options", "ShowSpaces", ShowSpaces
		piniSettings->WriteBool "Options", "ShowKeywordsTooltip", ShowKeywordsToolTip
		piniSettings->WriteBool "Options", "ShowTooltipsAtTheTop", ShowTooltipsAtTheTop
		piniSettings->WriteBool "Options", "ShowHorizontalSeparatorLines", ShowHorizontalSeparatorLines
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
		piniSettings->WriteBool "Options", "CreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt", CreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt
		piniSettings->WriteBool "Options", "CreateFormTypesWithoutTypeWord", CreateFormTypesWithoutTypeWord
		piniSettings->WriteBool "Options", "OpenCommandPromptInMainFileFolder", OpenCommandPromptInMainFileFolder
		piniSettings->WriteString "Options", "CommandPromptFolder", *CommandPromptFolder
		piniSettings->WriteBool "Options", "SyntaxHighlightingIdentifiers", SyntaxHighlightingIdentifiers
		piniSettings->WriteBool "Options", "ChangeIdentifiersCase", ChangeIdentifiersCase
		piniSettings->WriteBool "Options", "ChangeKeywordsCase", ChangeKeyWordsCase
		piniSettings->WriteInteger "Options", "ChoosedKeywordsCase", ChoosedKeyWordsCase
		piniSettings->WriteBool "Options", "AddSpacesToOperators", AddSpacesToOperators
		
		piniSettings->WriteString "Options", "CurrentTheme", *CurrentTheme
		
		piniSettings->WriteString "Options", "EditorFontName", *EditorFontName
		piniSettings->WriteInteger "Options", "EditorFontSize", EditorFontSize
		piniSettings->WriteString "Options", "InterfaceFontName", *InterfaceFontName
		piniSettings->WriteInteger "Options", "InterfaceFontSize", InterfaceFontSize
		piniSettings->WriteBool "Options", "DisplayMenuIcons", DisplayMenuIcons
		piniSettings->WriteBool "Options", "ShowMainToolbar", ShowMainToolBar
		piniSettings->WriteBool "Options", "DarkMode", DarkMode
		'piniSettings->WriteBool "Options", "ShowToolBoxLocal", gLocalToolBox
		piniSettings->WriteBool("Options", "PropertiesLocal", gLocalProperties) 'David Change
		pfrmMain->Menu->ImagesList = IIf(DisplayMenuIcons, pimgList, 0)
		MainReBar.Visible = ShowMainToolBar
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
		
		piniTheme->WriteInteger("Colors", "CommonVariablesForeground",  IIf(ColorCommonVariables.ForegroundOption = Identifiers.ForegroundOption, -1, ColorCommonVariables.ForegroundOption))
		piniTheme->WriteInteger("Colors", "CommonVariablesBackground", IIf(ColorCommonVariables.BackgroundOption = Identifiers.BackgroundOption, -1, ColorCommonVariables.BackgroundOption))
		piniTheme->WriteInteger("Colors", "CommonVariablesFrame", IIf(ColorCommonVariables.FrameOption = Identifiers.FrameOption, -1, ColorCommonVariables.FrameOption))
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
		
		piniTheme->WriteInteger("Colors", "LineLabelsForeground", IIf(ColorLineLabels.ForegroundOption = Identifiers.ForegroundOption, -1, ColorLineLabels.ForegroundOption))
		piniTheme->WriteInteger("Colors", "LineLabelsBackground", IIf(ColorLineLabels.BackgroundOption = Identifiers.BackgroundOption, -1, ColorLineLabels.BackgroundOption))
		piniTheme->WriteInteger("Colors", "LineLabelsFrame", IIf(ColorLineLabels.FrameOption = Identifiers.FrameOption, -1, ColorLineLabels.FrameOption))
		piniTheme->WriteInteger("FontStyles", "LineLabelsBold", ColorLineLabels.Bold)
		piniTheme->WriteInteger("FontStyles", "LineLabelsItalic", ColorLineLabels.Italic)
		piniTheme->WriteInteger("FontStyles", "LineLabelsUnderline", ColorLineLabels.Underline)
		
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
		piniTheme->WriteInteger("Colors", "NumbersForeground", Numbers.ForegroundOption)
		piniTheme->WriteInteger("Colors", "NumbersBackground", Numbers.BackgroundOption)
		piniTheme->WriteInteger("Colors", "NumbersFrame", Numbers.FrameOption)
		piniTheme->WriteInteger("FontStyles", "NumbersBold", Numbers.Bold)
		piniTheme->WriteInteger("FontStyles", "NumbersItalic", Numbers.Italic)
		piniTheme->WriteInteger("FontStyles", "NumbersUnderline", Numbers.Underline)
		piniTheme->WriteInteger("Colors", "OperatorsForeground", ColorOperators.ForegroundOption)
		piniTheme->WriteInteger("Colors", "OperatorsBackground", ColorOperators.BackgroundOption)
		piniTheme->WriteInteger("Colors", "OperatorsFrame", ColorOperators.FrameOption)
		piniTheme->WriteInteger("FontStyles", "OperatorsBold", ColorOperators.Bold)
		piniTheme->WriteInteger("FontStyles", "OperatorsItalic", ColorOperators.Italic)
		piniTheme->WriteInteger("FontStyles", "OperatorsUnderline", ColorOperators.Underline)
		piniTheme->WriteInteger("Colors", "RealNumbersForeground", RealNumbers.ForegroundOption)
		piniTheme->WriteInteger("Colors", "RealNumbersBackground", RealNumbers.BackgroundOption)
		piniTheme->WriteInteger("Colors", "RealNumbersFrame", RealNumbers.FrameOption)
		piniTheme->WriteInteger("FontStyles", "RealNumbersBold", RealNumbers.Bold)
		piniTheme->WriteInteger("FontStyles", "RealNumbersItalic", RealNumbers.Italic)
		piniTheme->WriteInteger("FontStyles", "RealNumbersUnderline", RealNumbers.Underline)
		piniTheme->WriteInteger("Colors", "SelectionForeground", Selection.ForegroundOption)
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

Private Sub frmOptions.Form_Close(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer)
	If newIndex <> oldIndex Then MsgBox ML("Localization changes will be applied the next time the application is run.")
	If *InterfaceFontName <> *fOptions.oldInterfFontName OrElse InterfaceFontSize <> fOptions.oldInterfFontSize Then MsgBox ML("Interface font changes will be applied the next time the application is run.")
	If DisplayMenuIcons <> fOptions.oldDisplayMenuIcons Then MsgBox ML("Display icons in the menu changes will be applied the next time the application is run.")
	'If DarkMode <> fOptions.oldDarkMode Then MsgBox ML("Dark Mode changes will be applied the next time the application is run.")
	'If fOptions.HotKeysChanged Then MsgBox ML("Hotkey changes will be applied the next time the application is run.")
End Sub

Private Sub frmOptions.Form_Show(ByRef Designer As My.Sys.Object, ByRef Sender As Form)
	
End Sub

Private Sub frmOptions.TreeView1_SelChange(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode)
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

Private Sub frmOptions.pnlIncludes_ActiveControlChange(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	
End Sub

Private Sub frmOptions.cmdMFFPath_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		.BrowsD.InitialDir = GetFullPath(.txtMFFpath.Text)
		If .BrowsD.Execute Then
			.txtMFFpath.Text = .BrowsD.Directory
		End If
	End With
End Sub

Private Sub frmOptions.cmdFont_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		.FontD.Font.Name = * (.EditFontName)
		.FontD.Font.Size = .EditFontSize
		If .FontD.Execute Then
			WLet(.EditFontName, .FontD.Font.Name)
			.EditFontSize = .FontD.Font.Size
			.lblFont.Font.Name = * (.EditFontName)
			.lblFont.Caption = * (.EditFontName) & ", " & .EditFontSize & "pt"
		End If
	End With
End Sub

Private Sub frmOptions.lstColorKeys_Change(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		Var i = fOptions.lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		If UBound(.Colors, 1) < 0 Then Exit Sub
		Dim As Integer NormOrIdentifiers = IIf(i > 8 AndAlso i < 26, 8, 29 + UBound(Keywords))
		.txtColorForeground.BackColor = IIf(.Colors(i, 0) = -1, .Colors(NormOrIdentifiers, 0), .Colors(i, 0))
		.chkForeground.Checked = CBool(i <> NormOrIdentifiers) AndAlso CBool(.Colors(i, 0) = -1 OrElse .Colors(i, 0) = .Colors(NormOrIdentifiers, 0))
		.txtColorForeground.Text = Str(.txtColorForeground.BackColor)
		.txtColorForeground.ForeColor = CInt(.txtColorForeground.BackColor) Shl 2
		
		.txtColorBackground.BackColor = IIf(.Colors(i, 1) = -1, .Colors(NormOrIdentifiers, 1), .Colors(i, 1))
		.txtColorBackground.Visible = .Colors(i, 1) <> -2
		.txtColorBackground.Text = Str(.txtColorBackground.BackColor)
		.txtColorBackground.ForeColor = CInt(.txtColorBackground.BackColor) Shl 2
		.lblBackground.Visible = .Colors(i, 1) <> -2
		.cmdBackground.Visible = .Colors(i, 1) <> -2
		.chkBackground.Visible = .Colors(i, 1) <> -2
		.chkBackground.Checked = CBool(i <> NormOrIdentifiers) AndAlso CBool(.Colors(i, 1) = -1 OrElse .Colors(i, 1) = .Colors(NormOrIdentifiers, 1))
		
		.txtColorFrame.BackColor = IIf(.Colors(i, 2) = -1, .Colors(NormOrIdentifiers, 2), .Colors(i, 2))
		.txtColorFrame.Visible = .Colors(i, 2) <> -2
		.txtColorFrame.Text = Str(.txtColorFrame.BackColor)
		.txtColorFrame.ForeColor = CInt(.txtColorFrame.BackColor) Shl 2
		.lblFrame.Visible = .Colors(i, 2) <> -2
		.cmdFrame.Visible = .Colors(i, 2) <> -2
		.chkFrame.Visible = .Colors(i, 2) <> -2
		.chkFrame.Checked = CBool(i <> NormOrIdentifiers) AndAlso .Colors(i, 2) = (.Colors(i, 2) = -1 OrElse .Colors(i, 2) = .Colors(NormOrIdentifiers, 2))
		
		.txtColorIndicator.BackColor = IIf(.Colors(i, 3) = -1, .Colors(NormOrIdentifiers, 3), .Colors(i, 3))
		.txtColorIndicator.Visible = .Colors(i, 3) <> -2
		.txtColorIndicator.Text = Str(.txtColorIndicator.BackColor)
		.txtColorIndicator.ForeColor = CInt(.txtColorIndicator.BackColor) Shl 2
		.lblIndicator.Visible = .Colors(i, 3) <> -2
		.cmdIndicator.Visible = .Colors(i, 3) <> -2
		.chkIndicator.Visible = .Colors(i, 3) <> -2
		.chkIndicator.Checked = CBool(i <> 0) AndAlso .Colors(i, 3) = (.Colors(i, 3) = -1 OrElse .Colors(i, 3) = .Colors(0, 3))
		
		.chkBold.Visible = .Colors(i, 4) <> -2
		.chkBold.Checked = .Colors(i, 4)
		.chkItalic.Visible = .Colors(i, 4) <> -2
		.chkItalic.Checked = .Colors(i, 5)
		.chkUnderline.Visible = .Colors(i, 4) <> -2
		.chkUnderline.Checked = .Colors(i, 6)
	End With
End Sub

Private Sub frmOptions.cmdForeground_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions.ColorD
		Var i = fOptions.lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Color = fOptions.Colors(i, 0)
		If .Execute Then
			fOptions.txtColorForeground.BackColor = .Color
			fOptions.chkForeground.Checked = False
			fOptions.Colors(i, 0) = .Color
			fOptions.txtColorForeground.Text = Str(.Color)
		End If
	End With
End Sub

Private Sub frmOptions.cmdBackground_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions.ColorD
		Var i = fOptions.lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Color = fOptions.Colors(i, 1)
		If .Execute Then
			fOptions.txtColorBackground.BackColor = .Color
			fOptions.chkBackground.Checked = False
			fOptions.Colors(i, 1) = .Color
			fOptions.txtColorBackground.Text = Str(.Color)
		End If
	End With
End Sub

Private Sub frmOptions.cmdFrame_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions.ColorD
		Var i = fOptions.lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Color = fOptions.Colors(i, 2)
		If .Execute Then
			fOptions.txtColorFrame.BackColor = .Color
			fOptions.chkFrame.Checked = False
			fOptions.Colors(i, 2) = .Color
			fOptions.txtColorFrame.Text = Str(.Color)
		End If
	End With
End Sub

Private Sub frmOptions.cmdIndicator_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions.ColorD
		Var i = fOptions.lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Color = fOptions.Colors(i, 3)
		If .Execute Then
			fOptions.txtColorIndicator.BackColor = .Color
			fOptions.chkIndicator.Checked = False
			fOptions.Colors(i, 3) = .Color
			fOptions.txtColorIndicator.Text = Str(.Color)
		End If
	End With
End Sub

Private Sub frmOptions.cboTheme_Change(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		If UBound(.Colors) = -1 Then Exit Sub
		piniTheme->Load ExePath & "/Settings/Themes/" & fOptions.cboTheme.Text & ".ini"
		#ifdef __USE_GTK__
			.Colors(30 + UBound(Keywords), 0) = piniTheme->ReadInteger("Colors", "NormalTextForeground", clBlack)
			.Colors(30 + UBound(Keywords), 1) = piniTheme->ReadInteger("Colors", "NormalTextBackground", clWhite)
			.Colors(30 + UBound(Keywords), 2) = piniTheme->ReadInteger("Colors", "NormalTextFrame", clBlack)
		#else
			.Colors(30 + UBound(Keywords), 0) = piniTheme->ReadInteger("Colors", "NormalTextForeground", IIf(g_darkModeEnabled, darkTextColor, clBlack))
			.Colors(30 + UBound(Keywords), 1) = piniTheme->ReadInteger("Colors", "NormalTextBackground", IIf(g_darkModeEnabled, darkBkColor, clWhite))
			.Colors(30 + UBound(Keywords), 2) = piniTheme->ReadInteger("Colors", "NormalTextFrame", IIf(g_darkModeEnabled, darkTextColor, clBlack))
		#endif
		.Colors(30 + UBound(Keywords), 4) = piniTheme->ReadInteger("FontStyles", "NormalTextBold", 0)
		.Colors(30 + UBound(Keywords), 5) = piniTheme->ReadInteger("FontStyles", "NormalTextItalic", 0)
		.Colors(30 + UBound(Keywords), 6) = piniTheme->ReadInteger("FontStyles", "NormalTextUnderline", 0)
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
		.Colors(8, 0) = piniTheme->ReadInteger("Colors", "IdentifiersForeground", .Colors(30 + UBound(Keywords), 0))
		.Colors(8, 1) = piniTheme->ReadInteger("Colors", "IdentifiersBackground", .Colors(30 + UBound(Keywords), 1) )
		.Colors(8, 2) = piniTheme->ReadInteger("Colors", "IdentifiersFrame", .Colors(30 + UBound(Keywords), 2))
		.Colors(8, 4) = piniTheme->ReadInteger("FontStyles", "IdentifiersBold", 0)
		.Colors(8, 5) = piniTheme->ReadInteger("FontStyles", "IdentifiersItalic", 0)
		.Colors(8, 6) = piniTheme->ReadInteger("FontStyles", "IdentifiersUnderline", 0)
		
		.Colors(9, 0) = piniTheme->ReadInteger("Colors", "ByRefParametersForeground", .Colors(8, 0))
		.Colors(9, 1) = piniTheme->ReadInteger("Colors", "ByRefParametersBackground", .Colors(8, 1))
		.Colors(9, 2) = piniTheme->ReadInteger("Colors", "ByRefParametersFrame", .Colors(8, 2))
		.Colors(9, 4) = piniTheme->ReadInteger("FontStyles", "ByRefParametersBold", 0)
		.Colors(9, 5) = piniTheme->ReadInteger("FontStyles", "ByRefParametersItalic", 0)
		.Colors(9, 6) = piniTheme->ReadInteger("FontStyles", "ByRefParametersUnderline", 0)
		
		.Colors(10, 0) = piniTheme->ReadInteger("Colors", "ByValParametersForeground", .Colors(8, 0))
		.Colors(10, 1) = piniTheme->ReadInteger("Colors", "ByValParametersBackground", .Colors(8, 1))
		.Colors(10, 2) = piniTheme->ReadInteger("Colors", "ByValParametersFrame", .Colors(8, 2))
		.Colors(10, 4) = piniTheme->ReadInteger("FontStyles", "ByValParametersBold", 0)
		.Colors(10, 5) = piniTheme->ReadInteger("FontStyles", "ByValParametersItalic", 0)
		.Colors(10, 6) = piniTheme->ReadInteger("FontStyles", "ByValParametersUnderline", 0)
		
		.Colors(11, 0) = piniTheme->ReadInteger("Colors", "CommonVariablesForeground", .Colors(8, 0))
		.Colors(11, 1) = piniTheme->ReadInteger("Colors", "CommonVariablesBackground", .Colors(8, 1))
		.Colors(11, 2) = piniTheme->ReadInteger("Colors", "CommonVariablesFrame", .Colors(8, 2))
		.Colors(11, 4) = piniTheme->ReadInteger("FontStyles", "CommonVariablesBold", 0)
		.Colors(11, 5) = piniTheme->ReadInteger("FontStyles", "CommonVariablesItalic", 0)
		.Colors(11, 6) = piniTheme->ReadInteger("FontStyles", "CommonVariablesUnderline", 0)
		
		.Colors(12, 0) = piniTheme->ReadInteger("Colors", "ComponentsForeground", .Colors(8, 0))
		.Colors(12, 1) = piniTheme->ReadInteger("Colors", "ComponentsBackground", .Colors(8, 1))
		.Colors(12, 2) = piniTheme->ReadInteger("Colors", "ComponentsFrame", .Colors(8, 2))
		.Colors(12, 4) = piniTheme->ReadInteger("FontStyles", "ComponentsBold", 0)
		.Colors(12, 5) = piniTheme->ReadInteger("FontStyles", "ComponentsItalic", 0)
		.Colors(12, 6) = piniTheme->ReadInteger("FontStyles", "ComponentsUnderline", 0)
		
		.Colors(13, 0) = piniTheme->ReadInteger("Colors", "ConstantsForeground", .Colors(8, 0))
		.Colors(13, 1) = piniTheme->ReadInteger("Colors", "ConstantsBackground", .Colors(8, 1))
		.Colors(13, 2) = piniTheme->ReadInteger("Colors", "ConstantsFrame", .Colors(8, 2))
		.Colors(13, 4) = piniTheme->ReadInteger("FontStyles", "ConstantsBold", 0)
		.Colors(13, 5) = piniTheme->ReadInteger("FontStyles", "ConstantsItalic", 0)
		.Colors(13, 6) = piniTheme->ReadInteger("FontStyles", "ConstantsUnderline", 0)
		
		.Colors(14, 0) = piniTheme->ReadInteger("Colors", "DefinesForeground", .Colors(8, 0))
		.Colors(14, 1) = piniTheme->ReadInteger("Colors", "DefinesBackground", .Colors(8, 1))
		.Colors(14, 2) = piniTheme->ReadInteger("Colors", "DefinesFrame", .Colors(8, 2))
		.Colors(14, 4) = piniTheme->ReadInteger("FontStyles", "DefinesBold", 0)
		.Colors(14, 5) = piniTheme->ReadInteger("FontStyles", "DefinesItalic", 0)
		.Colors(14, 6) = piniTheme->ReadInteger("FontStyles", "DefinesUnderline", 0)
		
		.Colors(15, 0) = piniTheme->ReadInteger("Colors", "FieldsForeground", .Colors(8, 0))
		.Colors(15, 1) = piniTheme->ReadInteger("Colors", "FieldsBackground", .Colors(8, 1))
		.Colors(15, 2) = piniTheme->ReadInteger("Colors", "FieldsFrame", .Colors(8, 2))
		.Colors(15, 4) = piniTheme->ReadInteger("FontStyles", "FieldsBold", 0)
		.Colors(15, 5) = piniTheme->ReadInteger("FontStyles", "FieldsItalic", 0)
		.Colors(15, 6) = piniTheme->ReadInteger("FontStyles", "FieldsUnderline", 0)
		
		.Colors(16, 0) = piniTheme->ReadInteger("Colors", "GlobalFunctionsForeground", .Colors(8, 0))
		.Colors(16, 1) = piniTheme->ReadInteger("Colors", "GlobalFunctionsBackground", .Colors(8, 1))
		.Colors(16, 2) = piniTheme->ReadInteger("Colors", "GlobalFunctionsFrame", .Colors(8, 2))
		.Colors(16, 4) = piniTheme->ReadInteger("FontStyles", "GlobalFunctionsBold", 0)
		.Colors(16, 5) = piniTheme->ReadInteger("FontStyles", "GlobalFunctionsItalic", 0)
		.Colors(16, 6) = piniTheme->ReadInteger("FontStyles", "GlobalFunctionsUnderline", 0)
		
		.Colors(17, 0) = piniTheme->ReadInteger("Colors", "EnumMembersForeground", .Colors(8, 0))
		.Colors(17, 1) = piniTheme->ReadInteger("Colors", "EnumMembersBackground", .Colors(8, 1))
		.Colors(17, 2) = piniTheme->ReadInteger("Colors", "EnumMembersFrame", .Colors(8, 2))
		.Colors(17, 4) = piniTheme->ReadInteger("FontStyles", "EnumMembersBold", 0)
		.Colors(17, 5) = piniTheme->ReadInteger("FontStyles", "EnumMembersItalic", 0)
		.Colors(17, 6) = piniTheme->ReadInteger("FontStyles", "EnumMembersUnderline", 0)
		
		.Colors(18, 0) = piniTheme->ReadInteger("Colors", "GlobalEnumsForeground", .Colors(8, 0))
		.Colors(18, 1) = piniTheme->ReadInteger("Colors", "GlobalEnumsBackground", .Colors(8, 1))
		.Colors(18, 2) = piniTheme->ReadInteger("Colors", "GlobalEnumsFrame", .Colors(8, 2))
		.Colors(18, 4) = piniTheme->ReadInteger("FontStyles", "GlobalEnumsBold", 0)
		.Colors(18, 5) = piniTheme->ReadInteger("FontStyles", "GlobalEnumsItalic", 0)
		.Colors(18, 6) = piniTheme->ReadInteger("FontStyles", "GlobalEnumsUnderline", 0)
		
		.Colors(19, 0) = piniTheme->ReadInteger("Colors", "LineLabelsForeground", .Colors(8, 0))
		.Colors(19, 1) = piniTheme->ReadInteger("Colors", "LineLabelsBackground", .Colors(8, 1))
		.Colors(19, 2) = piniTheme->ReadInteger("Colors", "LineLabelsFrame", .Colors(8, 2))
		.Colors(19, 4) = piniTheme->ReadInteger("FontStyles", "LineLabelsBold", 0)
		.Colors(19, 5) = piniTheme->ReadInteger("FontStyles", "LineLabelsItalic", 0)
		.Colors(19, 6) = piniTheme->ReadInteger("FontStyles", "LineLabelsUnderline", 0)
		
		.Colors(20, 0) = piniTheme->ReadInteger("Colors", "LocalVariablesForeground", .Colors(8, 0))
		.Colors(20, 1) = piniTheme->ReadInteger("Colors", "LocalVariablesBackground", .Colors(8, 1))
		.Colors(20, 2) = piniTheme->ReadInteger("Colors", "LocalVariablesFrame", .Colors(8, 2))
		.Colors(20, 4) = piniTheme->ReadInteger("FontStyles", "LocalVariablesBold", 0)
		.Colors(20, 5) = piniTheme->ReadInteger("FontStyles", "LocalVariablesItalic", 0)
		.Colors(20, 6) = piniTheme->ReadInteger("FontStyles", "LocalVariablesUnderline", 0)
		
		.Colors(21, 0) = piniTheme->ReadInteger("Colors", "MacrosForeground", .Colors(8, 0))
		.Colors(21, 1) = piniTheme->ReadInteger("Colors", "MacrosBackground", .Colors(8, 1))
		.Colors(21, 2) = piniTheme->ReadInteger("Colors", "MacrosFrame", .Colors(8, 2))
		.Colors(21, 4) = piniTheme->ReadInteger("FontStyles", "MacrosBold", 0)
		.Colors(21, 5) = piniTheme->ReadInteger("FontStyles", "MacrosItalic", 0)
		.Colors(21, 6) = piniTheme->ReadInteger("FontStyles", "MacrosUnderline", 0)
		
		.Colors(22, 0) = piniTheme->ReadInteger("Colors", "GlobalNamespacesForeground", .Colors(8, 0))
		.Colors(22, 1) = piniTheme->ReadInteger("Colors", "GlobalNamespacesBackground", .Colors(8, 1))
		.Colors(22, 2) = piniTheme->ReadInteger("Colors", "GlobalNamespacesFrame", .Colors(8, 2))
		.Colors(22, 4) = piniTheme->ReadInteger("FontStyles", "GlobalNamespacesBold", 0)
		.Colors(22, 5) = piniTheme->ReadInteger("FontStyles", "GlobalNamespacesItalic", 0)
		.Colors(22, 6) = piniTheme->ReadInteger("FontStyles", "GlobalNamespacesUnderline", 0)
		
		.Colors(23, 0) = piniTheme->ReadInteger("Colors", "PropertiesForeground", .Colors(8, 0))
		.Colors(23, 1) = piniTheme->ReadInteger("Colors", "PropertiesBackground", .Colors(8, 1))
		.Colors(23, 2) = piniTheme->ReadInteger("Colors", "PropertiesFrame", .Colors(8, 2))
		.Colors(23, 4) = piniTheme->ReadInteger("FontStyles", "PropertiesBold", 0)
		.Colors(23, 5) = piniTheme->ReadInteger("FontStyles", "PropertiesItalic", 0)
		.Colors(23, 6) = piniTheme->ReadInteger("FontStyles", "PropertiesUnderline", 0)
		
		.Colors(24, 0) = piniTheme->ReadInteger("Colors", "SharedVariablesForeground", .Colors(8, 0))
		.Colors(24, 1) = piniTheme->ReadInteger("Colors", "SharedVariablesBackground", .Colors(8, 1))
		.Colors(24, 2) = piniTheme->ReadInteger("Colors", "SharedVariablesFrame", .Colors(8, 2))
		.Colors(24, 4) = piniTheme->ReadInteger("FontStyles", "SharedVariablesBold", 0)
		.Colors(24, 5) = piniTheme->ReadInteger("FontStyles", "SharedVariablesItalic", 0)
		.Colors(24, 6) = piniTheme->ReadInteger("FontStyles", "SharedVariablesUnderline", 0)
		
		.Colors(25, 0) = piniTheme->ReadInteger("Colors", "SubsForeground", .Colors(8, 0))
		.Colors(25, 1) = piniTheme->ReadInteger("Colors", "SubsBackground", .Colors(8, 1))
		.Colors(25, 2) = piniTheme->ReadInteger("Colors", "SubsFrame", .Colors(8, 2))
		.Colors(25, 4) = piniTheme->ReadInteger("FontStyles", "SubsBold", 0)
		.Colors(25, 5) = piniTheme->ReadInteger("FontStyles", "SubsItalic", 0)
		.Colors(25, 6) = piniTheme->ReadInteger("FontStyles", "SubsUnderline", 0)
		
		.Colors(26, 0) = piniTheme->ReadInteger("Colors", "GlobalTypesForeground", .Colors(8, 0))
		.Colors(26, 1) = piniTheme->ReadInteger("Colors", "GlobalTypesBackground", .Colors(8, 1))
		.Colors(26, 2) = piniTheme->ReadInteger("Colors", "GlobalTypesFrame", .Colors(8, 2))
		.Colors(26, 4) = piniTheme->ReadInteger("FontStyles", "GlobalTypesBold", 0)
		.Colors(26, 5) = piniTheme->ReadInteger("FontStyles", "GlobalTypesItalic", 0)
		.Colors(26, 6) = piniTheme->ReadInteger("FontStyles", "GlobalTypesUnderline", 0)
		
		.Colors(27, 0) = piniTheme->ReadInteger("Colors", "IndicatorLinesForeground", -1)
		Dim As Integer k
		For k = 0 To UBound(Keywords)
			.Colors(28 + k, 0) = piniTheme->ReadInteger("Colors", Replace(KeywordLists.Item(k), " ", "") & "Foreground", piniTheme->ReadInteger("Colors", "KeywordsForeground", -1))
			.Colors(28 + k, 1) = piniTheme->ReadInteger("Colors", Replace(KeywordLists.Item(k), " ", "") & "Background", piniTheme->ReadInteger("Colors", "KeywordsBackground", -1))
			.Colors(28 + k, 2) = piniTheme->ReadInteger("Colors", Replace(KeywordLists.Item(k), " ", "") & "Frame", piniTheme->ReadInteger("Colors", "KeywordsFrame", -1))
			.Colors(28 + k, 4) = piniTheme->ReadInteger("FontStyles", Replace(KeywordLists.Item(k), " ", "") & "Bold", piniTheme->ReadInteger("Colors", "KeywordsBold", 0))
			.Colors(28 + k, 5) = piniTheme->ReadInteger("FontStyles", Replace(KeywordLists.Item(k), " ", "") & "Italic", piniTheme->ReadInteger("Colors", "KeywordsItalic", 0))
			.Colors(28 + k, 6) = piniTheme->ReadInteger("FontStyles", Replace(KeywordLists.Item(k), " ", "") & "Underline", piniTheme->ReadInteger("Colors", "KeywordsUnderline", 0))
		Next k
		k = UBound(Keywords)
		.Colors(29 + k, 0) = piniTheme->ReadInteger("Colors", "LineNumbersForeground", -1)
		.Colors(29 + k, 1) = piniTheme->ReadInteger("Colors", "LineNumbersBackground", -1)
		.Colors(29 + k, 2) = piniTheme->ReadInteger("Colors", "LineNumbersFrame", -1)
		.Colors(29 + k, 4) = piniTheme->ReadInteger("FontStyles", "LineNumbersBold", 0)
		.Colors(29 + k, 5) = piniTheme->ReadInteger("FontStyles", "LineNumbersItalic", 0)
		.Colors(29 + k, 6) = piniTheme->ReadInteger("FontStyles", "LineNumbersUnderline", 0)
		.Colors(31 + k, 0) = piniTheme->ReadInteger("Colors", "NumbersForeground", -1)
		.Colors(31 + k, 1) = piniTheme->ReadInteger("Colors", "NumbersBackground", -1)
		.Colors(31 + k, 2) = piniTheme->ReadInteger("Colors", "NumbersFrame", -1)
		.Colors(31 + k, 4) = piniTheme->ReadInteger("FontStyles", "NumbersBold", 0)
		.Colors(31 + k, 5) = piniTheme->ReadInteger("FontStyles", "NumbersItalic", 0)
		.Colors(31 + k, 6) = piniTheme->ReadInteger("FontStyles", "NumbersUnderline", 0)
		.Colors(32 + k, 0) = piniTheme->ReadInteger("Colors", "RealNumbersForeground", -1)
		.Colors(32 + k, 1) = piniTheme->ReadInteger("Colors", "RealNumbersBackground", -1)
		.Colors(32 + k, 2) = piniTheme->ReadInteger("Colors", "RealNumbersFrame", -1)
		.Colors(32 + k, 4) = piniTheme->ReadInteger("FontStyles", "RealNumbersBold", 0)
		.Colors(32 + k, 5) = piniTheme->ReadInteger("FontStyles", "RealNumbersItalic", 0)
		.Colors(32 + k, 6) = piniTheme->ReadInteger("FontStyles", "RealNumbersUnderline", 0)
		.Colors(33 + k, 0) = piniTheme->ReadInteger("Colors", "OperatorsForeground", -1)
		.Colors(33 + k, 1) = piniTheme->ReadInteger("Colors", "OperatorsBackground", -1)
		.Colors(33 + k, 2) = piniTheme->ReadInteger("Colors", "OperatorsFrame", -1)
		.Colors(33 + k, 4) = piniTheme->ReadInteger("FontStyles", "OperatorsBold", 0)
		.Colors(33 + k, 5) = piniTheme->ReadInteger("FontStyles", "OperatorsItalic", 0)
		.Colors(33 + k, 6) = piniTheme->ReadInteger("FontStyles", "OperatorsUnderline", 0)
		.Colors(34 + k, 0) = piniTheme->ReadInteger("Colors", "SelectionForeground", -1)
		.Colors(34 + k, 1) = piniTheme->ReadInteger("Colors", "SelectionBackground", -1)
		.Colors(34 + k, 2) = piniTheme->ReadInteger("Colors", "SelectionFrame", -1)
		.Colors(35 + k, 0) = piniTheme->ReadInteger("Colors", "SpaceIdentifiersForeground", -1)
		.Colors(36 + k, 0) = piniTheme->ReadInteger("Colors", "StringsForeground", -1)
		.Colors(36 + k, 1) = piniTheme->ReadInteger("Colors", "StringsBackground", -1)
		.Colors(36 + k, 2) = piniTheme->ReadInteger("Colors", "StringsFrame", -1)
		.Colors(36 + k, 4) = piniTheme->ReadInteger("FontStyles", "StringsBold", 0)
		.Colors(36 + k, 5) = piniTheme->ReadInteger("FontStyles", "StringsItalic", 0)
		.Colors(36 + k, 6) = piniTheme->ReadInteger("FontStyles", "StringsUnderline", 0)
		.lstColorKeys_Change(*.lstColorKeys.Designer, .lstColorKeys)
		SetColors
		Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb <> 0 Then
			#ifdef __USE_GTK__
				tb->txtCode.Update
			#else
				tb->txtCode.PaintControl True
				'RedrawWindow tb->txtCode.Handle, NULL, NULL, RDW_INVALIDATE
			#endif
		End If
	End With
End Sub

Private Sub frmOptions.chkForeground_Click(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
	With fOptions
		Var i = .lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Colors(i, 0) = IIf(.chkForeground.Checked, -1, .txtColorForeground.BackColor)
	End With
End Sub

Private Sub frmOptions.chkBackground_Click(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
	With fOptions
		Var i = .lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Colors(i, 1) = IIf(.chkBackground.Checked, -1, .txtColorBackground.BackColor)
	End With
End Sub

Private Sub frmOptions.chkFrame_Click(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
	With fOptions
		Var i = .lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Colors(i, 2) = IIf(.chkFrame.Checked, -1, .txtColorFrame.BackColor)
	End With
End Sub

Private Sub frmOptions.chkIndicator_Click(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
	With fOptions
		Var i = .lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Colors(i, 3) = IIf(.chkIndicator.Checked, -1, .txtColorIndicator.BackColor)
	End With
End Sub

Private Sub frmOptions.chkBold_Click(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
	With fOptions
		Var i = .lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Colors(i, 4) = IIf(.chkBold.Checked, -1, 0)
	End With
End Sub

Private Sub frmOptions.chkItalic_Click(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
	With fOptions
		Var i = .lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Colors(i, 5) = IIf(.chkItalic.Checked, -1, 0)
	End With
End Sub

Private Sub frmOptions.chkUnderline_Click(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
	With fOptions
		Var i = .lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Colors(i, 6) = IIf(.chkUnderline.Checked, -1, 0)
	End With
End Sub

Private Sub frmOptions.cmdAdd_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	If pfTheme->ShowModal() = ModalResults.OK Then
		With fOptions
			.cboTheme.AddItem pfTheme->txtThemeName.Text
			.cboTheme.ItemIndex = .cboTheme.IndexOf(pfTheme->txtThemeName.Text)
			.cboTheme_Change(Designer, Sender)
		End With
	End If
End Sub

Private Sub frmOptions.cmdRemove_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		Kill ExePath & "/Settings/Themes/" & .cboTheme.Text & ".ini"
		.cboTheme.RemoveItem .cboTheme.ItemIndex
		.cboTheme.ItemIndex = 0
		.cboTheme_Change(Designer, Sender)
	End With
End Sub

Private Sub frmOptions.cmdAddCompiler_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
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

Private Sub frmOptions.cmdChangeCompiler_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
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
				.lvCompilerPaths.SelectedItem->ImageKey = IIf(FileExists(GetFullPath(pfPath->txtPath.Text)), "", "FileError")
				.lvCompilerPaths.SelectedItem->SelectedImageKey = IIf(FileExists(GetFullPath(pfPath->txtPath.Text)), "", "FileError")
			Else
				MsgBox ML("This version is exists!")
			End If
		End If
	End With
End Sub

Private Sub frmOptions.cmdRemoveCompiler_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
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

Private Sub frmOptions.cmdClearCompilers_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
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

Private Sub frmOptions.cmdAddMakeTool_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
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

Private Sub frmOptions.cmdChangeMakeTool_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
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

Private Sub frmOptions.cmdRemoveMakeTool_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		If .lvMakeToolPaths.SelectedItem = 0 Then Exit Sub
		Var iIndex = .cboMakeTool.IndexOf(.lvMakeToolPaths.SelectedItem->Text(0))
		If iIndex > -1 Then .cboMakeTool.RemoveItem iIndex
		If .cboMakeTool.ItemIndex = -1 Then .cboMakeTool.ItemIndex = 0
		.lvMakeToolPaths.ListItems.Remove .lvMakeToolPaths.SelectedItemIndex
	End With
End Sub

Private Sub frmOptions.cmdClearMakeTools_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		.lvMakeToolPaths.ListItems.Clear
		.cboMakeTool.Clear
		.cboMakeTool.AddItem ML("(not selected)")
		.cboMakeTool.ItemIndex = 0
	End With
End Sub

Private Sub frmOptions.cmdAddDebugger_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
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

Private Sub frmOptions.cmdChangeDebugger_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
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

Private Sub frmOptions.cmdRemoveDebugger_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		If .lvDebuggerPaths.SelectedItem = 0 Then Exit Sub
		Var iIndex = .cboDebugger32.IndexOf(.lvDebuggerPaths.SelectedItem->Text(0))
		If iIndex > -1 Then .cboDebugger32.RemoveItem iIndex: .cboDebugger64.RemoveItem iIndex
		If .cboDebugger32.ItemIndex = -1 Then .cboDebugger32.ItemIndex = 0
		If .cboDebugger64.ItemIndex = -1 Then .cboDebugger64.ItemIndex = 0
		.lvDebuggerPaths.ListItems.Remove .lvDebuggerPaths.SelectedItemIndex
	End With
End Sub

Private Sub frmOptions.cmdClearDebuggers_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
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

Private Sub frmOptions.cmdAddTerminal_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
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

Private Sub frmOptions.cmdChangeTerminal_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
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

Private Sub frmOptions.cmdRemoveTerminal_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		If .lvTerminalPaths.SelectedItem = 0 Then Exit Sub
		Var iIndex = .cboTerminal.IndexOf(.lvTerminalPaths.SelectedItem->Text(0))
		If iIndex > -1 Then .cboTerminal.RemoveItem iIndex
		If .cboTerminal.ItemIndex = -1 Then .cboTerminal.ItemIndex = 0
		.lvTerminalPaths.ListItems.Remove .lvTerminalPaths.SelectedItemIndex
	End With
End Sub

Private Sub frmOptions.cmdClearTerminals_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		.lvTerminalPaths.ListItems.Clear
		.cboTerminal.Clear
		.cboTerminal.AddItem ML("(not selected)")
		.cboTerminal.ItemIndex = 0
	End With
End Sub

Private Sub frmOptions.cmdAddHelp_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
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

Private Sub frmOptions.cmdChangeHelp_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
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

Private Sub frmOptions.cmdRemoveHelp_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		If .lvHelpPaths.SelectedItem = 0 Then Exit Sub
		Var iIndex = .cboHelp.IndexOf(.lvHelpPaths.SelectedItem->Text(0))
		If iIndex > -1 Then .cboHelp.RemoveItem iIndex
		If .cboHelp.ItemIndex = -1 Then .cboHelp.ItemIndex = 0
		.lvHelpPaths.ListItems.Remove .lvHelpPaths.SelectedItemIndex
	End With
End Sub

Private Sub frmOptions.cmdClearHelps_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		.lvHelpPaths.ListItems.Clear
		.cboHelp.Clear
		.cboHelp.AddItem ML("(not selected)")
		.cboHelp.ItemIndex = 0
	End With
End Sub

Private Sub frmOptions.cmdInterfaceFont_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		.FontD.Font.Name = * (.InterfFontName)
		.FontD.Font.Size = .InterfFontSize
		If .FontD.Execute Then
			WLet(.InterfFontName, .FontD.Font.Name)
			.InterfFontSize = .FontD.Font.Size
			.lblInterfaceFont.Font.Name = * (.InterfFontName)
			.lblInterfaceFont.Caption = *(.InterfFontName) & ", " & .InterfFontSize & "pt"
		End If
	End With
End Sub

Private Sub frmOptions.cmdAddInclude_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
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

Private Sub frmOptions.cmdAddLibrary_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
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

Private Sub frmOptions.cmdRemoveInclude_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Var Index = fOptions.lstIncludePaths.ItemIndex
	If Index <> -1 Then fOptions.lstIncludePaths.RemoveItem Index
End Sub

Private Sub frmOptions.cmdRemoveLibrary_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Var Index = fOptions.lstLibraryPaths.ItemIndex
	If Index <> -1 Then fOptions.lstLibraryPaths.RemoveItem Index
End Sub

Private Sub frmOptions.cmdProjectsPath_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		.BrowsD.InitialDir = GetFullPath(.txtProjectsPath.Text)
		If .BrowsD.Execute Then
			.txtProjectsPath.Text = .BrowsD.Directory
		End If
	End With
End Sub

Private Sub frmOptions.lvShortcuts_SelectedItemChanged(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	With fOptions
		Var Index = .lvShortcuts.SelectedItemIndex
		If Index > -1 Then
			.hkShortcut.Text = .lvShortcuts.SelectedItem->Text(1)
		End If
	End With
End Sub

Private Sub frmOptions.cmdSetShortcut_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		Var Index = .lvShortcuts.SelectedItemIndex
		If Index > -1 Then
			.lvShortcuts.SelectedItem->Text(1) = .hkShortcut.Text
			.HotKeysChanged = True
		End If
	End With
End Sub

Private Sub frmOptions.cmdAddEditor_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmOptions Ptr, Sender.Designer)).cmdAddEditor_Click(Sender)
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

Private Sub frmOptions.cmdChangeEditor_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmOptions Ptr, Sender.Designer)).cmdChangeEditor_Click(Sender)
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

Private Sub frmOptions.cmdRemoveEditor_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmOptions Ptr, Sender.Designer)).cmdRemoveEditor_Click(Sender)
End Sub
Private Sub frmOptions.cmdRemoveEditor_Click(ByRef Sender As Control)
	With lvOtherEditors
		If .SelectedItem = 0 Then Exit Sub
		.ListItems.Remove .SelectedItemIndex
	End With
End Sub

Private Sub frmOptions.cmdClearEditor_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmOptions Ptr, Sender.Designer)).cmdClearEditor_Click(Sender)
End Sub
Private Sub frmOptions.cmdClearEditor_Click(ByRef Sender As Control)
	lvOtherEditors.ListItems.Clear
End Sub

Sub cboDefaultProjectFileCheckEnable
	fOptions.cboDefaultProjectFile.Enabled = fOptions.optCreateProjectFile.Checked
	fOptions.cboOpenedFile.Enabled = fOptions.optOpenLastSession.Checked
End Sub

Private Sub frmOptions.optPromptForProjectAndFiles_Click(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton)
	cboDefaultProjectFileCheckEnable
End Sub

Private Sub frmOptions.optCreateProjectFile_Click(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton)
	cboDefaultProjectFileCheckEnable
End Sub

Private Sub frmOptions.optOpenLastSession_Click(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton)
	cboDefaultProjectFileCheckEnable
End Sub

Private Sub frmOptions.optDoNotNothing_Click(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton)
	cboDefaultProjectFileCheckEnable
End Sub

Dim Shared As Boolean bStop
Dim Shared As Integer FindedCompilersCount
Dim Shared As UString FolderName = GetFolderName(pApp->FileName)
Sub FindCompilers(ByRef Path As WString)
	Dim As WString * 1024 f, f1, f2, f3
	Dim As UInteger Attr, NameCount
	Dim As WStringList Folders
	#ifdef __FB_WIN32__
	If Path = "" Then Exit Sub
	#endif
	If FormClosing OrElse bStop Then Exit Sub
	If EndsWith(Path, "\Windows") Then Exit Sub
	ThreadsEnter
	'fOptions.lblFindCompilersFromComputer.Text = Path
	pstBar->Panels[0]->Caption = Path
	ThreadsLeave
	f = Dir(Path & Slash & "*", fbDirectory Or fbHidden Or fbSystem Or fbArchive Or fbReadOnly, Attr)
	While f <> ""
		If FormClosing OrElse bStop Then Exit Sub
		If f <> "." AndAlso f <> ".." AndAlso (Attr And fbDirectory) Then Folders.Add Path & IIf(EndsWith(Path, Slash), "", Slash) & f
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
	#ifdef __FB_WIN32__
		Dim As String disk0 = CurDir
		For i As Integer = 65 To 90
			If FormClosing OrElse bStop Then Exit For
			If ChDir(Chr(i) & ":") = 0 Then FindCompilers Chr(i) & ":"
		Next
		ChDir(disk0)
	#else
		FindCompilers ""
	#endif
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
		f1 = Mid(f, Len(f) - 16)
		If Len(f1) > 16 Then
			d2 = DateValue(Mid(f1, 1, 4) & "/" & Mid(f1, 5, 2) & "/" & Mid(f1, 7, 2))
			If DateDiff( "d", d2, Now()) > HistoryCodeDays Then Kill Path & Slash & f
		End If
		f = Dir()
	Wend
	HistoryCodeCleanDay = DateValue(Format(Now, "yyyy/mm/dd"))
End Sub

Private Sub frmOptions.cmdFindCompilers_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmOptions Ptr, Sender.Designer)).cmdFindCompilers_Click(Sender)
End Sub

Private Sub frmOptions.cmdFindCompilers_Click(ByRef Sender As Control)
	bStop = cmdFindCompilers.Text = ML("Stop")
	FindProcessStartStop()
End Sub

Private Sub frmOptions.lvOtherEditors_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	(*Cast(frmOptions Ptr, Sender.Designer)).lvOtherEditors_ItemActivate(Sender, ItemIndex)
End Sub
Private Sub frmOptions.lvOtherEditors_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	cmdChangeEditor_Click cmdChangeEditor
End Sub

Private Sub frmOptions.lvTerminalPaths_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	(*Cast(frmOptions Ptr, Sender.Designer)).lvTerminalPaths_ItemActivate(Sender, ItemIndex)
End Sub
Private Sub frmOptions.lvTerminalPaths_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	cmdChangeTerminal_Click *cmdChangeTerminal.Designer, cmdChangeTerminal
End Sub

Private Sub frmOptions.lvDebuggerPaths_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	(*Cast(frmOptions Ptr, Sender.Designer)).lvDebuggerPaths_ItemActivate(Sender, ItemIndex)
End Sub
Private Sub frmOptions.lvDebuggerPaths_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	cmdChangeDebugger_Click *cmdChangeDebugger.Designer, cmdChangeDebugger
End Sub

Private Sub frmOptions.lvHelpPaths_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	(*Cast(frmOptions Ptr, Sender.Designer)).lvHelpPaths_ItemActivate(Sender, ItemIndex)
End Sub
Private Sub frmOptions.lvHelpPaths_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	cmdChangeHelp_Click *cmdChangeHelp.Designer, cmdChangeHelp
End Sub

Private Sub frmOptions.lvMakeToolPaths_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	(*Cast(frmOptions Ptr, Sender.Designer)).lvMakeToolPaths_ItemActivate(Sender, ItemIndex)
End Sub
Private Sub frmOptions.lvMakeToolPaths_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	cmdChangeMakeTool_Click *cmdChangeMakeTool.Designer, cmdChangeMakeTool
End Sub

Private Sub frmOptions.lvCompilerPaths_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	(*Cast(frmOptions Ptr, Sender.Designer)).lvCompilerPaths_ItemActivate(Sender, ItemIndex)
End Sub
Private Sub frmOptions.lvCompilerPaths_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	cmdChangeCompiler_Click *cmdChangeCompiler.Designer, cmdChangeCompiler
End Sub

Private Sub frmOptions.cmdInFolder_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmOptions Ptr, Sender.Designer)).cmdInFolder_Click(Sender)
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
	chkCreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt.Enabled = chkCreateNonStaticEventHandlers.Checked
End Sub


Private Function UzLot(Text As UString) As UString
	Dim As Integer Qadam
	Dim As UString txt, Old(2), U, stat
	Dim As UString Spravka(10000), Malumot(10000), Uzbek(100), Lotin(100)
  Spravka(1) = "MAXSUL": Malumot(1) = "MAHSUL"
  Spravka(2) = "XARAJAT": Malumot(2) = "HARAJAT"
  Spravka(3) = "XIS": Malumot(3) = "HIS"
  Spravka(4) = "XARJ": Malumot(4) = "HARJ"
  Spravka(5) = "XAK": Malumot(5) = "HAQ"
  Spravka(6) = "XUKUK": Malumot(6) = "HUQUQ"
  Spravka(7) = "KARZ": Malumot(7) = "QARZ"
  Spravka(8) = "XAR": Malumot(8) = "HAR"
  Spravka(9) = "EXTI": Malumot(9) = "EHTI"
  Spravka(10) = "XOSIL": Malumot(10) = "HOSIL"
  Spravka(11) = "MAXAL": Malumot(11) = "MAHAL"
  Spravka(12) = "XAM": Malumot(12) = "HAM"
  Spravka(13) = "KARZ": Malumot(13) = "QARZ"
  Spravka(14) = "XUJJAT": Malumot(14) = "HUJJAT"
  Spravka(15) = "UKUV": Malumot(15) = "O'QUV"
  Spravka(16) = "TUGRI": Malumot(16) = "TO'G'RI"
  Spravka(17) = "FARK": Malumot(17) = "FARQ"
  Spravka(18) = "UZBEK": Malumot(18) = "O'ZBEK"
  Qadam = 0
  Dim As UString Result = Text
  Dim As Integer a, b
  Dim As UString e = Text & " "
  Dim As Integer p, h, j, y
  Dim As UString R, t
  Var d = Len(e)
  Var w = 54
  Dim As UString Z = "АаИиОоУуЭэЮюЯя ,.-:;`@!~#$%^&*()_+=|\?/><"
  Dim As UString x = " `~!@#$%^&*()_+|\=-/,.<>?/"
  Dim As UString UzbekHarf = "АаБбВвГгДдЖжЗзИиЙйКкЛлМмНнОоПпРрСсТтУуФфХхЪъЫыЭэЉљ" + WChr(1178) + WChr(1179) + WChr(1202) + WChr(1203) + "Е" +  "е"  + "Ё"  + "ё"  + "Ц"  + "ц"  + "Ч"  + "ч"  + "Ш"  + "ш"  + "Щ"  + "щ"  + "Ю"  + "ю"  + "Я"  + "я"  + "Њ"  + "Ў"  + "ў"  + "њ"  + WChr(1170) + WChr(1171) + "Ьь"
  Dim As UString LotinHarf = "AaBbVvGgDdJjZzIiYyKkLlMmNnOoPpRrSsTtUuFfXxʼʼIiEeQq" + "Q"        + "q"        + "H"        + "h"        + "YE" + "ye" + "YO" + "yo" + "TS" + "ts" + "CH" + "ch" + "SH" + "sh" + "SH" + "sh" + "YU" + "yu" + "YA" + "ya" + "Oʻ" + "Oʻ" + "oʻ" + "oʻ" + "Gʻ"       + "gʻ"
  txt = ""
  For i As Integer = 1 To d + 1
    Old(2) = Old(1)
    Old(1) = txt
    txt = Mid(e, i, 1)
    U = Old(2)
    For f As Integer = 1 To Len(UzbekHarf)
      Uzbek(f) = Mid(UzbekHarf, f, 1)
      If f > w Then p = p + 2: Lotin(f) = Mid(LotinHarf, p - 1, 2) Else p = f: Lotin(f) = Mid(LotinHarf, p, 1)
      If Old(1) = Uzbek(f) Then
        If Len(Lotin(f)) = 1 Then
          R = R + Uzbek(f): t = t + Lotin(f)
        Else
          Select Case Old(1)
            Case "ц"
              If InStr(Left(Z, 14), U) > 0 And U <> "" Then
                R = R + Old(1): t = t + "ts"
              Else: R = R + Old(1): t = t + "s": End If
            Case "Ц"
              If InStr(Left(Z, 14), U) > 0 And U <> "" Then
                R = R + Old(1): t = t + "TS"
              Else
                R = R + Old(1): t = t + "S"
              End If
            Case "е"
              If InStr(Z, U) > 0 Then
                R = R + Old(1): t = t + "ye"
              Else: R = R + Old(1): t = t + "e": End If
            Case "Е"
              If U = UCase(U) And txt = UCase(txt) And InStr(x, U) = 0 Or U = UCase(U) And txt = UCase(txt) And InStr(x, txt) = 0 Then
                If InStr(Z, U) > 0 Then
                  R = R + Old(1): t = t + "YE"
                Else
                  R = R + Old(1): t = t + "E"
                End If
              Else
                R = R + Old(1): t = t + "Ye"
              End If
            Case Else
              If U = UCase(U) And txt = UCase(txt) And InStr(x, U) = 0 Or U = UCase(U) And txt = UCase(txt) And InStr(x, txt) = 0 Then
                R = R + Uzbek(f): t = t + Lotin(f)
              Else: R = R + Uzbek(f): t = t + Left(Lotin(f), 1) + LCase(Right(Lotin(f), 1)): h = 0
              End If
          End Select
        End If
        Exit For
      ElseIf InStr(UzbekHarf, Old(1)) = 0 Then
        If t <> "" Or R <> "" Then
          j = 1
          Do While Spravka(j) <> ""
            For y = 1 To 3
              t = Replace(t, Spravka(j), Malumot(j))
              a = Len(Spravka(j)): b = Len(Malumot(j))
              If y = 1 Then Spravka(j) = Left(Spravka(j), 1) + LCase(Right(Spravka(j), a - 1)): Malumot(j) = Left(Malumot(j), 1) + LCase(Right(Malumot(j), b - 1))
              If y = 2 Then Spravka(j) = LCase(Spravka(j)): Malumot(j) = LCase(Malumot(j))
              If y = 3 Then Spravka(j) = UCase(Spravka(j)): Malumot(j) = UCase(Malumot(j))
            Next y: j = j + 1
          Loop
          Result = Replace(Result, R, t, 1, 1)
          t = "": R = ""
        End If
      End If
    Next f
  Next i
  Return Result
End Function

Private Sub frmOptions.cmdUpdateLng_Click(ByRef Sender As Control)
	Dim As WString Ptr lang_name
	Dim As WString * 1024 Buff, FileNameLng, FileNameSrc
	Dim As String tKey, f
	Dim As UString tText
	Dim As Integer Pos1, p, p1, n, Result, Fn1, Fn2
	Dim As Dictionary mlKeysGeneral, mlKeysCompiler, mlKeysProperty, mlKeysTemplates, mlKeyWords, mlKeysCompilerEnglish, mlKeysPropertyEnglish, mlKeysTemplatesEnglish, mlKeyWordsEnglish, mlKeysGeneralEnglish
	Dim As Boolean StartGeneral, StartKeyWords, StartProperty, StartCompiler, StartTemplates, IsComment = False
	cmdUpdateLng.Enabled = False
	'lblShowMsg.Visible = True
	' Produce English.lng from Projects at first
	FileNameLng = ExePath & "/Settings/Languages/English.lng"
	Fn1 = FreeFile_
	Result = Open(FileNameLng For Input Encoding "utf-8" As #Fn1)
	If Result <> 0 Then Result = Open(FileNameLng For Input Encoding "utf-16" As #Fn1)
	If Result <> 0 Then Result = Open(FileNameLng For Input Encoding "utf-32" As #Fn1)
	If Result <> 0 Then Result = Open(FileNameLng For Input As #Fn1)
	If Result = 0 Then
		StartGeneral = True
		Line Input #Fn1, Buff
		WLet(lang_name, Buff)
		Do Until EOF(Fn1)
			Line Input #Fn1, Buff
			If LCase(Trim(Buff)) = "[keywords]" Then
				StartKeyWords = True
				StartProperty = False
				StartCompiler = False
				StartTemplates = False
				StartGeneral = False
			ElseIf LCase(Trim(Buff)) = "[property]" Then
				StartKeyWords = False
				StartProperty = True
				StartCompiler = False
				StartTemplates = False
				StartGeneral = False
			ElseIf LCase(Trim(Buff)) = "[compiler]" Then
				StartKeyWords = False
				StartProperty = False
				StartCompiler = True
				StartTemplates = False
				StartGeneral = False
			ElseIf LCase(Trim(Buff)) = "[templates]" Then
				StartKeyWords = False
				StartProperty = False
				StartCompiler = False
				StartTemplates = True
				StartGeneral = False
			ElseIf LCase(Trim(Buff)) = "[general]" Then
				StartKeyWords = False
				StartProperty = False
				StartCompiler = False
				StartTemplates = False
				StartGeneral = True
			End If
			Pos1 = InStr(Buff, "=")
			If Len(Trim(Buff, Any !"\t ")) > 0 AndAlso Pos1 > 0 Then
				'David Change For the Control Property's Language.
				'note: "=" already Replaced by "~"
				tKey = Trim(..Left(Buff, Pos1 - 1), Any !"\t ")
				tText = Trim(Mid(Buff, Pos1 + 1), Any !"\t ")
				If tText <> "" Then
					If InStr(tKey, "~") Then tKey = Replace(tKey, "~", "=")
					If StartGeneral = True Then
						mlKeysGeneralEnglish.Add tKey, tText
					ElseIf StartProperty = True Then
						mlKeysPropertyEnglish.Add tKey, tText
					ElseIf StartKeyWords = True Then
						mlKeyWordsEnglish.Add tKey, tText
					ElseIf StartCompiler = True Then
						mlKeysCompilerEnglish.Add tKey, tText
					ElseIf StartTemplates = True Then
						mlKeysTemplatesEnglish.Add tKey, tText
					End If
				End If
			End If
		Loop
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
	CloseFile_(Fn1)
	Fn1 = FreeFile_
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
				Fn2 = FreeFile_
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
									If tKey <> """" AndAlso Not mlKeysGeneralEnglish.ContainsKey(tKey) Then
										mlKeysGeneralEnglish.Add tKey, ""
										tKey = Replace(tKey, "&", "")
										If Not mlKeysGeneralEnglish.ContainsKey(tKey) Then mlKeysGeneralEnglish.Add tKey, ""
									End If
								End If
							End If
							p = InStr(p + 1, LCase(Buff), "ml(""")
						Loop
						p = InStr(LCase(Buff), "ms(""")
						Do While p > 0
							p1 = InStr(p + 1, Buff, """,")
							If p1 > 0 Then
								tKey = Trim(Mid(Buff, p + 4, p1 - p - 4), Any !"\t ")
								If tKey <> "" Then
									If tKey <> """" AndAlso Not mlKeysGeneralEnglish.ContainsKey(tKey) Then
										mlKeysGeneralEnglish.Add tKey, ""
										tKey = Replace(tKey, "&", "")
										If Not mlKeysGeneralEnglish.ContainsKey(tKey) Then mlKeysGeneralEnglish.Add tKey, ""
									End If
								End If
							End If
							p = InStr(p + 1, LCase(Buff), "ms(""")
						Loop
					Loop
					App.DoEvents
				Else
					lblShowMsg.Text = ML("File not found") & "! " & FileNameSrc
				End If
				CloseFile_(Fn2)
			End If
		Loop
	Else
		lblShowMsg.Text = ML("File not found") & "! " & ExePath & "/VisualFBEditor.vfp"
		mlKeysGeneral.Clear
		mlKeysProperty.Clear
		mlKeysCompiler.Clear
		mlKeysTemplates.Clear
		mlKeyWords.Clear
		cmdUpdateLng.Enabled = True
		Exit Sub
	End If
	CloseFile_(Fn1)
	f = Dir(ExePath & "/Templates/Projects/*.vfp")
	Dim As String TemplateName
	While f <> ""
		TemplateName = ..Left(f, IfNegative(InStr(f, ".") - 1, Len(f)))
		mlKeysGeneralEnglish.Add TemplateName
		f = Dir()
	Wend
	Dim As String IconName
	f = Dir(ExePath & "/Templates/Files/*")
	While f <> ""
		TemplateName = ..Left(f, IfNegative(InStr(f, ".") - 1, Len(f)))
		mlKeysGeneralEnglish.Add TemplateName
		f = Dir()
	Wend
	Fn1 = FreeFile_
	If Open(ExePath & "/Settings/Others/Compiler error messages.txt" For Input Encoding "utf-8" As #Fn1) = 0 Then
		Do Until EOF(Fn1)
			Line Input #Fn1, Buff
			If Not IsNumeric(.Left(Buff, 1)) Then Continue Do
			Var Pos1 = InStr(Buff, " ")
			If Pos1 > 0 Then
				mlKeysCompilerEnglish.Add Trim(Mid(Buff, Pos1 + 1))
			End If
		Loop
	End If
	CloseFile_(Fn1)
	mlKeysCompilerEnglish.SortKeys
	Fn1 = FreeFile_
	If Open(ExePath & "/Settings/Others/Properties.txt" For Input Encoding "utf-8" As #Fn1) = 0 Then
		Do Until EOF(Fn1)
			Line Input #Fn1, Buff
			Var Pos1 = InStr(Buff, "=")
			If Pos1 > 0 Then
				mlKeysPropertyEnglish.Add Trim(.Left(Buff, Pos1 - 1))
			End If
		Loop
	End If
	CloseFile_(Fn1)
	mlKeyWordsEnglish.Add "#endmacro"
	mlKeyWordsEnglish.Add "EndIf"
	For i As Integer = 0 To Globals.Functions.Count - 1
		Dim As TypeElement Ptr te = Globals.Functions.Object(i)
		If te->ElementType = E_Keyword OrElse te->ElementType = E_KeywordFunction OrElse te->ElementType = E_KeywordSub Then
			mlKeyWordsEnglish.Add te->Name
		ElseIf te->ElementType = E_KeywordOperator Then
			Dim As Boolean bFind
			For j As Integer = 1 To Len(te->Name)
				If InStr("!#$&~)*+-./<>@[]\^=", Mid(te->Name, j, 1)) > 0 Then
					bFind = True
					Exit For
				End If
			Next
			If Not bFind Then
				mlKeyWordsEnglish.Add te->Name
			End If
		End If
	Next
	App.DoEvents
	mlKeysGeneralEnglish.SortKeys
	lblShowMsg.Text = ML("Save") & " " & FileNameLng
	Fn1 = FreeFile_
	Open FileNameLng For Output Encoding "utf-8" As #Fn1
	Print #Fn1, *lang_name
	App.DoEvents
	Print #Fn1, "[Compiler]"
	For i As Integer = 0 To mlKeysCompilerEnglish.Count - 1
		tKey = mlKeysCompilerEnglish.Item(i)->Key
		If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
		If tKey <> "" Then Print #Fn1, tKey & " = " '& mlKeysGeneral.Item(i)->Text
	Next
	App.DoEvents
	Print #Fn1, "[General]"
	For i As Integer = 0 To mlKeysGeneralEnglish.Count - 1
		tKey = mlKeysGeneralEnglish.Item(i)->Key
		If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
		If tKey <> "" Then Print #Fn1, tKey & " = " '& mlKeysGeneral.Item(i)->Text
	Next
	App.DoEvents
	Print #Fn1, "[Keywords]"
	For i As Integer = 0 To mlKeyWordsEnglish.Count - 1
		tKey = mlKeyWordsEnglish.Item(i)->Key
		If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
		If tKey <> "" Then Print #Fn1, tKey & " = " '& mlKeysGeneral.Item(i)->Text
	Next
	App.DoEvents
	Print #Fn1, "[Property]"
	For i As Integer = 0 To mlKeysPropertyEnglish.Count - 1
		tKey = mlKeysPropertyEnglish.Item(i)->Key
		If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
		If tKey <> "" Then Print #Fn1, tKey & " = " '& mlKeysGeneral.Item(i)->Text
	Next
	App.DoEvents
	Print #Fn1, "[Templates]"
	For i As Integer = 0 To mlKeysTemplatesEnglish.Count - 1
		tKey = mlKeysTemplatesEnglish.Item(i)->Key
		If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
		If tKey <> "" Then Print #Fn1, tKey & " = " '& mlKeysGeneral.Item(i)->Text
	Next
	CloseFile_(Fn1)
	App.DoEvents
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
		If p > 0 Then f = Trim(Mid(cboLanguage.Text, p + 1)) & ".lng" Else Exit Sub
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
		Fn1 = FreeFile_
		FileNameLng = ExePath & "/Settings/Languages/" & f
		Result = Open(FileNameLng For Input Encoding "utf-8" As #Fn1)
		If Result <> 0 Then Result = Open(FileNameLng For Input Encoding "utf-16" As #Fn1)
		If Result <> 0 Then Result = Open(FileNameLng For Input Encoding "utf-32" As #Fn1)
		If Result <> 0 Then Result = Open(FileNameLng For Input As #Fn1)
		If Result = 0 Then
			StartGeneral = True
			This.Text =  ML("Updating ...") & " " & FileNameLng
			Line Input #Fn1, Buff
			WLet(lang_name, Buff)
			Do Until EOF(Fn1)
				Line Input #Fn1, Buff
				If LCase(Trim(Buff)) = "[keywords]" Then
					StartKeyWords = True
					StartProperty = False
					StartCompiler = False
					StartTemplates = False
					StartGeneral = False
				ElseIf LCase(Trim(Buff)) = "[property]" Then
					StartKeyWords = False
					StartProperty = True
					StartCompiler = False
					StartTemplates = False
					StartGeneral = False
				ElseIf LCase(Trim(Buff)) = "[compiler]" Then
					StartKeyWords = False
					StartProperty = False
					StartCompiler = True
					StartTemplates = False
					StartGeneral = False
				ElseIf LCase(Trim(Buff)) = "[templates]" Then
					StartKeyWords = False
					StartProperty = False
					StartCompiler = False
					StartTemplates = True
					StartGeneral = False
				ElseIf LCase(Trim(Buff)) = "[general]" Then
					StartKeyWords = False
					StartProperty = False
					StartCompiler = False
					StartTemplates = False
					StartGeneral = True
				End If
				Pos1 = InStr(Buff, "=")
				If Len(Trim(Buff, Any !"\t ")) > 0 AndAlso Pos1 > 0 Then
					'David Change For the Control Property's Language.
					'note: "=" already converted to "~"
					tKey = Trim(..Left(Buff, Pos1 - 1), Any !"\t ")
					If EndsWith(tKey, " (needs to be removed)") Then
						tKey = Trim(..Left(tKey, Len(tKey) - 22), Any !"\t ")
					End If
					tText = Trim(Mid(Buff, Pos1 + 1), Any !"\t ")
					If tText <> "" Then
						If InStr(tKey, "~") Then tKey = Replace(tKey, "~", "=")
						If StartGeneral = True Then
							mlKeysGeneral.Add tKey, tText
						ElseIf StartProperty = True Then
							mlKeysProperty.Add tKey, tText
						ElseIf StartKeyWords = True Then
							mlKeyWords.Add tKey, tText
						ElseIf StartCompiler = True Then
							mlKeysCompiler.Add tKey, tText
						ElseIf StartTemplates = True Then
							mlKeysTemplates.Add tKey, tText
						End If
					End If
				End If
			Loop
			mlKeysGeneral.SortKeys
			mlKeysProperty.SortKeys
			mlKeysCompiler.SortKeys
			mlKeysTemplates.SortKeys
			mlKeyWords.SortKeys
			App.DoEvents
			
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
		CloseFile_(Fn1)
		App.DoEvents
		
		For i As Integer = 0 To mlKeysGeneralEnglish.Count - 1
			tKey = mlKeysGeneralEnglish.Item(i)->Key
			If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
			If tKey <> "" Then
				If Not mlKeysGeneral.ContainsKey(tKey, , True) Then 
					mlKeysGeneral.Add tKey, , CPtr(Any Ptr, 1)
				Else
					mlKeysGeneral.Item(mlKeysGeneral.IndexOfKey(tKey, , True))->Object = CPtr(Any Ptr, 1)
				End If
			End If
		Next
		For i As Integer = 0 To mlKeysPropertyEnglish.Count - 1
			tKey = mlKeysPropertyEnglish.Item(i)->Key
			If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
			If tKey <> "" Then
				If Not mlKeysProperty.ContainsKey(tKey) Then
					mlKeysProperty.Add tKey, , CPtr(Any Ptr, 1)
				Else
					mlKeysProperty.Item(mlKeysProperty.IndexOfKey(tKey))->Object = CPtr(Any Ptr, 1)
				End If
			End If
		Next
		For i As Integer = 0 To mlKeysCompilerEnglish.Count - 1
			tKey = mlKeysCompilerEnglish.Item(i)->Key
			'If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
			If tKey <> "" Then
				If Not mlKeysCompiler.ContainsKey(tKey) Then 
					mlKeysCompiler.Add tKey, , CPtr(Any Ptr, 1)
				Else
					mlKeysCompiler.Item(mlKeysCompiler.IndexOfKey(tKey))->Object = CPtr(Any Ptr, 1)
				End If
			End If
		Next
		For i As Integer = 0 To mlKeysTemplatesEnglish.Count - 1
			tKey = mlKeysTemplatesEnglish.Item(i)->Key
			If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
			If tKey <> "" Then
				If Not mlKeysTemplates.ContainsKey(tKey) Then 
					mlKeysTemplates.Add tKey, , CPtr(Any Ptr, 1)
				Else
					mlKeysTemplates.Item(mlKeysTemplates.IndexOfKey(tKey))->Object = CPtr(Any Ptr, 1)
				End If
			End If
		Next
		For i As Integer = 0 To mlKeyWordsEnglish.Count - 1
			tKey = mlKeyWordsEnglish.Item(i)->Key
			If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
			If tKey <> "" Then
				If Not mlKeyWords.ContainsKey(tKey) Then 
					mlKeyWords.Add tKey, , CPtr(Any Ptr, 1)
				Else
					mlKeyWords.Item(mlKeyWords.IndexOfKey(tKey))->Object = CPtr(Any Ptr, 1)
				End If
			End If
		Next
		mlKeysGeneral.SortKeys
		mlKeysProperty.SortKeys
		mlKeysCompiler.SortKeys
		mlKeysTemplates.SortKeys
		mlKeyWords.SortKeys
		Dim As Integer FnL
		'Save the Language file
		If EndsWith(FileNameLng, "uzbekcyril.lng") Then
			FnL = FreeFile_
			Open .Left(FileNameLng, Len(FileNameLng) - 14) & "uzbeklatin.lng" For Output Encoding "utf-8" As #FnL
		End If
		Fn1 = FreeFile_
		Open FileNameLng For Output Encoding "utf-8" As #Fn1
		Print #Fn1, *lang_name
		If FnL Then
			Print #FnL, "﻿Oʻzbekcha (lotin)"
		End If
		lblShowMsg.Text = ML("Saving ...") & " " & FileNameLng
		App.DoEvents
		Print #Fn1, "[Compiler]"
		If FnL Then
			Print #FnL, "[Compiler]"
		End If
		For i As Integer = 0 To mlKeysCompiler.Count - 1
			tKey = mlKeysCompiler.Item(i)->Key
			If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
			If tKey <> "" Then
				If mlKeysCompiler.Item(i)->Object = 0 Then
					If mlKeysCompiler.Item(i)->Text <> "" Then
						Print #Fn1, tKey & IIf(Not EndsWith(tKey, " (needs to be removed)"), " (needs to be removed)", "") & " = " & mlKeysCompiler.Item(i)->Text
						If FnL Then
							Print #FnL, tKey & IIf(Not EndsWith(tKey, " (needs to be removed)"), " (needs to be removed)", "") & " = " & UzLot(mlKeysCompiler.Item(i)->Text)
						End If
					End If
				Else
					Print #Fn1, tKey & " = " & mlKeysCompiler.Item(i)->Text
					If FnL Then
						Print #FnL, tKey & " = " & UzLot(mlKeysCompiler.Item(i)->Text)
					End If
				End If
			End If
		Next
		App.DoEvents
		Print #Fn1, "[General]"
		If FnL Then
			Print #FnL, "[General]"
		End If
		For i As Integer = 0 To mlKeysGeneral.Count - 1
			tKey = mlKeysGeneral.Item(i)->Key
			If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
			If tKey <> "" Then
				If mlKeysGeneral.Item(i)->Object = 0 Then
					If mlKeysGeneral.Item(i)->Text <> "" Then
						Print #Fn1, tKey & IIf(Not EndsWith(tKey, " (needs to be removed)"), " (needs to be removed)", "") & " = " & mlKeysGeneral.Item(i)->Text
						If FnL Then
							Print #FnL, tKey & IIf(Not EndsWith(tKey, " (needs to be removed)"), " (needs to be removed)", "") & " = " & UzLot(mlKeysGeneral.Item(i)->Text)
						End If
					End If
				Else
					Print #Fn1, tKey & " = " & mlKeysGeneral.Item(i)->Text
					If FnL Then
						Print #FnL, tKey & " = " & UzLot(mlKeysGeneral.Item(i)->Text)
					End If
				End If
			End If
		Next
		App.DoEvents
		Print #Fn1, "[Keywords]"
		If FnL Then
			Print #FnL, "[Keywords]"
		End If
		For i As Integer = 0 To mlKeyWords.Count - 1
			tKey = mlKeyWords.Item(i)->Key
			If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
			If tKey <> "" Then
				If mlKeyWords.Item(i)->Object = 0 Then
					If mlKeyWords.Item(i)->Text <> "" Then
						Print #Fn1, tKey & IIf(Not EndsWith(tKey, " (needs to be removed)"), " (needs to be removed)", "") & " = " & mlKeyWords.Item(i)->Text
						If FnL Then
							Print #FnL, tKey & IIf(Not EndsWith(tKey, " (needs to be removed)"), " (needs to be removed)", "") & " = " & UzLot(mlKeyWords.Item(i)->Text)
						End If
					End If
				Else
					Print #Fn1, tKey & " = " & mlKeyWords.Item(i)->Text
					If FnL Then
						Print #FnL, tKey & " = " & UzLot(mlKeyWords.Item(i)->Text)
					End If
				End If
			End If
		Next
		App.DoEvents
		Print #Fn1, "[Property]"
		If FnL Then
			Print #FnL, "[Property]"
		End If
		For i As Integer = 0 To mlKeysProperty.Count - 1
			tKey = mlKeysProperty.Item(i)->Key
			If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
			If tKey <> "" Then 
				If mlKeysProperty.Item(i)->Object = 0 Then
					If mlKeysProperty.Item(i)->Text <> "" Then
						Print #Fn1, tKey & IIf(Not EndsWith(tKey, " (needs to be removed)"), " (needs to be removed)", "") & " = " & mlKeysProperty.Item(i)->Text
						If FnL Then
							Print #FnL, tKey & IIf(Not EndsWith(tKey, " (needs to be removed)"), " (needs to be removed)", "") & " = " & UzLot(mlKeysProperty.Item(i)->Text)
						End If
					End If
				Else
					Print #Fn1, tKey & " = " & mlKeysProperty.Item(i)->Text
					If FnL Then
						Print #FnL, tKey & " = " & UzLot(mlKeysProperty.Item(i)->Text)
					End If
				End If
			End If
		Next
		App.DoEvents
		Print #Fn1, "[Templates]"
		If FnL Then
			Print #FnL, "[Templates]"
		End If
		For i As Integer = 0 To mlKeysTemplates.Count - 1
			tKey = mlKeysTemplates.Item(i)->Key
			If InStr(tKey, "=") Then tKey = Replace(tKey, "=", "~")
			If tKey <> "" Then 
				If mlKeysTemplates.Item(i)->Object = 0 Then
					If mlKeysTemplates.Item(i)->Text <> "" Then
						Print #Fn1, tKey & IIf(Not EndsWith(tKey, " (needs to be removed)"), " (needs to be removed)", "") & " = " & mlKeysTemplates.Item(i)->Text
						If FnL Then
							Print #FnL, tKey & IIf(Not EndsWith(tKey, " (needs to be removed)"), " (needs to be removed)", "") & " = " & UzLot(mlKeysTemplates.Item(i)->Text)
						End If
					End If
				Else
					Print #Fn1, tKey & " = " & mlKeysTemplates.Item(i)->Text
					If FnL Then
						Print #FnL, tKey & " = " & UzLot(mlKeysTemplates.Item(i)->Text)
					End If
				End If
			End If
		Next
		CloseFile_(Fn1)
		If FnL Then
			CloseFile_(FnL)
		End If
		App.DoEvents
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
	This.Text =  ML("Options")
	lblShowMsg.Text = ML("Saved") & ": " & FileNameLng
	
	'WebBrowser1.Navigate("https://cn.bing.com/translator?ref=TThis&&text=&from=en&to=cn")
	
End Sub

Private Sub frmOptions.txtColorForeground_KeyPress(ByRef Sender As Control, Key As Integer)
	If Key = 13 Then
		Var i = fOptions.lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		txtColorForeground.BackColor = Val(txtColorForeground.Text)
		chkForeground.Checked = False
		Colors(i, 0) = txtColorForeground.BackColor
	End If
End Sub

Private Sub frmOptions.txtColorBackground_KeyPress(ByRef Sender As Control, Key As Integer)
	If Key = 13 Then
		Var i = fOptions.lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		txtColorBackground.BackColor = Val(txtColorBackground.Text)
		chkBackground.Checked = False
		Colors(i, 1) = txtColorBackground.BackColor
	End If
End Sub

Private Sub frmOptions.txtColorFrame_KeyPress(ByRef Sender As Control, Key As Integer)
	If Key = 13 Then 
		Var i = fOptions.lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		txtColorFrame.BackColor = Val(txtColorFrame.Text)
		chkFrame.Checked = False
		Colors(i, 2) = txtColorFrame.BackColor
	End If
End Sub

Private Sub frmOptions.txtColorIndicator_KeyPress(ByRef Sender As Control, Key As Integer)
	If Key = 13 Then 
		Var i = fOptions.lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		txtColorIndicator.BackColor = Val(txtColorIndicator.Text)
		chkIndicator.Checked = False
		Colors(i, 3) = txtColorIndicator.BackColor
	End If
End Sub
