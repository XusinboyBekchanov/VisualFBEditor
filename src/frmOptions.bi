'#########################################################
'#  frmOptions.bi                                        #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "mff/Form.bi"
#include once "mff/TreeView.bi"
#include once "mff/CommandButton.bi"
#include once "mff/Label.bi"
#include once "mff/Panel.bi"
#include once "mff/TextBox.bi"
#include once "mff/ComboBoxEdit.bi"
#include once "mff/IniFile.bi"
#include once "mff/CheckBox.bi"
#include once "mff/ListControl.bi"
#include once "mff/CommandButton.bi"
#include once "mff/CheckBox.bi"
#include once "mff/GroupBox.bi"
#include once "mff/Label.bi"
#include once "mff/Panel.bi"
#include once "mff/TextBox.bi"
#include once "mff/Picture.bi"
#include once "mff/ComboBoxEdit.bi"
#include once "mff/Dialogs.bi"
#include once "Main.bi"
#include once "EditControl.bi"
#include once "frmTheme.bi"
#include once "frmPath.bi"
#include once "mff/ListView.bi"
#include once "mff/RadioButton.bi"
#include once "mff/HotKey.bi"

Using My.Sys.Forms

Common Shared As Integer oldIndex, newIndex

'#Region "Form"
	Type frmOptions Extends Form
		Declare Static Sub cmdOK_Click(ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Static Sub Form_Create(ByRef Sender As Control)
		Declare Static Sub cmdApply_Click(ByRef Sender As Control)
		Declare Static Sub Form_Destroy(ByRef Sender As Form)
		Declare Static Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Static Sub Form_Show(ByRef Sender As Form)
		Declare Static Sub cmdForeground_Click(ByRef Sender As Control)
		Declare Static Sub cmdInterfaceFont_Click(ByRef Sender As Control)
		Declare Static Sub TreeView1_SelChange(ByRef Sender As TreeView, ByRef Item As TreeNode)
		Declare Static Sub pnlIncludes_ActiveControlChange(ByRef Sender As Control)
		Declare Static Sub cmdMFFPath_Click(ByRef Sender As Control)
		Declare Static Sub cmdFont_Click(ByRef Sender As Control)
		Declare Static Sub lstColorKeys_Change(ByRef Sender As Control)
		Declare Static Sub cmdBackground_Click(ByRef Sender As Control)
		Declare Static Sub cmdIndicator_Click(ByRef Sender As Control)
		Declare Static Sub cboTheme_Change(ByRef Sender As Control)
		Declare Static Sub chkForeground_Click(ByRef Sender As CheckBox)
		Declare Static Sub chkBackground_Click(ByRef Sender As CheckBox)
		Declare Static Sub chkIndicator_Click(ByRef Sender As CheckBox)
		Declare Static Sub chkBold_Click(ByRef Sender As CheckBox)
		Declare Static Sub chkItalic_Click(ByRef Sender As CheckBox)
		Declare Static Sub chkUnderline_Click(ByRef Sender As CheckBox)
		Declare Static Sub cmdAdd_Click(ByRef Sender As Control)
		Declare Static Sub cmdRemove_Click(ByRef Sender As Control)
		Declare Static Sub cmdAddCompiler_Click(ByRef Sender As Control)
		Declare Static Sub cmdRemoveCompiler_Click(ByRef Sender As Control)
		Declare Static Sub cmdClearCompilers_Click(ByRef Sender As Control)
		Declare Static Sub cmdAddMakeTool_Click(ByRef Sender As Control)
		Declare Static Sub cmdRemoveMakeTool_Click(ByRef Sender As Control)
		Declare Static Sub cmdClearMakeTools_Click(ByRef Sender As Control)
		Declare Static Sub cmdAddDebugger_Click(ByRef Sender As Control)
		Declare Static Sub cmdRemoveDebugger_Click(ByRef Sender As Control)
		Declare Static Sub cmdClearDebuggers_Click(ByRef Sender As Control)
		Declare Static Sub cmdAddTerminal_Click(ByRef Sender As Control)
		Declare Static Sub cmdRemoveTerminal_Click(ByRef Sender As Control)
		Declare Static Sub cmdClearTerminals_Click(ByRef Sender As Control)
		Declare Static Sub cmdFrame_Click(ByRef Sender As Control)
		Declare Static Sub chkFrame_Click(ByRef Sender As CheckBox)
		Declare Static Sub cmdChangeCompiler_Click(ByRef Sender As Control)
		Declare Static Sub cmdChangeTerminal_Click(ByRef Sender As Control)
		Declare Static Sub cmdChangeDebugger_Click(ByRef Sender As Control)
		Declare Static Sub cmdChangeMakeTool_Click(ByRef Sender As Control)
		Declare Static Sub cmdAddHelp_Click(ByRef Sender As Control)
		Declare Static Sub cmdChangeHelp_Click(ByRef Sender As Control)
		Declare Static Sub cmdRemoveHelp_Click(ByRef Sender As Control)
		Declare Static Sub cmdClearHelps_Click(ByRef Sender As Control)
		Declare Sub LoadSettings()
		Declare Static Sub cmdAddInclude_Click(ByRef Sender As Control)
		Declare Static Sub cmdAddLibrary_Click(ByRef Sender As Control)
		Declare Static Sub cmdRemoveInclude_Click(ByRef Sender As Control)
		Declare Static Sub cmdRemoveLibrary_Click(ByRef Sender As Control)
		Declare Static Sub cmdProjectsPath_Click(ByRef Sender As Control)
		Declare Static Sub lvShortcuts_SelectedItemChanged(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Static Sub cmdSetShortcut_Click(ByRef Sender As Control)
		Declare Constructor
		Declare Destructor
		
		Dim As TreeView tvOptions
		Dim As CommandButton cmdOK, cmdCancel, cmdApply, cmdAddCompiler, cmdMFFPath, cmdAddInclude, cmdRemoveInclude, cmdAddLibrary, cmdRemoveLibrary, cmdChangeDebugger, cmdChangeTerminal, cmdChangeMakeTool, cmdAdd, cmdRemove, cmdForeground, cmdFont, cmdProjectsPath, cmdBackground, cmdIndicator, cmdRemoveCompiler, cmdClearCompilers, cmdAddDebugger, cmdRemoveDebugger, cmdClearDebuggers, cmdAddMakeTool, cmdRemoveMakeTool, cmdClearMakeTools, cmdAddTerminal, cmdRemoveTerminal, cmdClearTerminals, cmdSetShortcut
		Dim As Label lblBlack, lblWhite, lblCompiler32, lblCompiler64, lblTabSize, lblHistoryLimit, lblGridSize, lblFont, lblProjectsPath, lblForeground, lblBackground, lblIndicator, lblOthers, lblShortcut
		Dim As Panel pnlGeneral, pnlLocalization, pnlShortcuts, pnlThemes, pnlCodeEditor, pnlColorsAndFonts, pnlCompiler, pnlMake, pnlDebugger, pnlTerminal, pnlDesigner, pnlHelp, pnlIncludes, Panel1, pnlThemesCheckboxes, pnlColors, pnlGrid
		Dim As Picture lblColorForeground, lblColorBackground, lblColorIndicator
		Dim As TextBox txtMFFpath, txtTabSize, txtHistoryLimit, txtGridSize, txtProjectsPath
		Dim As ComboBoxEdit cboLanguage, cboCase, cboTabStyle, cboTheme, cboCompiler32, cboCompiler64, cboDebugger, cboMakeTool, cboTerminal, cboHelp
		Dim As CheckBox CheckBox1, chkAutoCreateRC, chkAutoSaveCurrentFileBeforeCompiling, chkEnableAutoComplete, chkTabAsSpaces, chkAutoIndentation, chkShowSpaces, chkShowAlignmentGrid, chkSnapToGrid, chkChangeKeywordsCase, chkForeground, chkBackground, chkIndicator, chkBold, chkItalic, chkUnderline, chkUseMakeOnStartWithCompile
		Dim As HotKey hkShortcut
		Dim OpenD As OpenFileDialog
		Dim BrowsD As FolderBrowserDialog
		Dim ColorD As ColorDialog
		Dim FontD As FontDialog
		Dim As WString Ptr EditFontName, InterfFontName, oldInterfFontName
		Dim As Integer EditFontSize, InterfFontSize, oldInterfFontSize
		Dim Colors(16, 7) As Integer
		Dim As WStringList HotKeysPriv
		Dim As Boolean HotKeysChanged
		Dim As Integer LibraryPathsCount
		Dim As ListControl lstIncludePaths, lstLibraryPaths, lstColorKeys
		Dim As GroupBox grbGrid, grbColors, grbThemes, grbFont, grbDefaultCompilers, grbCompilerPaths, grbDefaultDebugger, grbDebuggerPaths, grbMakeToolPaths, grbDefaultMakeTool, grbDefaultTerminal, grbTerminalPaths, grbIncludePaths, grbLibraryPaths, grbLanguage, grbDefaultHelp, grbHelpPaths, grbWhenCompiling, grbShortcuts
		Dim As ListView lvCompilerPaths, lvDebuggerPaths, lvMakeToolPaths, lvTerminalPaths, lvHelpPaths, lvShortcuts
		Dim As Label lblInterfaceFont
		Dim As CommandButton cmdInterfaceFont
		Dim As Label lblInterfaceFontLabel
		Dim As CheckBox chkDisplayIcons
		Dim As CheckBox chkShowMainToolbar
		Dim As CheckBox chkAutoReloadLastOpenSources
		Dim As CheckBox chkAutoCreateBakFiles
		Dim As Label lblFrame
		Dim As Picture lblColorFrame
		Dim As CommandButton cmdFrame, cmdChangeCompiler, cmdAddHelp, cmdChangeHelp, cmdRemoveHelp, cmdClearHelps
		Dim As CheckBox chkFrame
		Dim As CheckBox chkHighlightCurrentWord
		Dim As CheckBox chkHighlightCurrentLine
		Dim As CheckBox chkHighlightBrackets, chkIncludeMFFPath
		Dim As Boolean oldDisplayMenuIcons
		Dim As RadioButton optSaveCurrentFile, optDoNotSave, optSaveAllFiles
	End Type
'#End Region

Common Shared pfOptions As frmOptions Ptr

#ifndef __USE_MAKE__
	#include once "frmOptions.bas"
#endif
