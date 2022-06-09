﻿'#########################################################
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
#include once "mff/TimerComponent.bi"

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
		Declare Static Sub cmdAddEditor_Click_(ByRef Sender As Control)
		Declare Sub cmdAddEditor_Click(ByRef Sender As Control)
		Declare Static Sub cmdChangeEditor_Click_(ByRef Sender As Control)
		Declare Sub cmdChangeEditor_Click(ByRef Sender As Control)
		Declare Static Sub cmdRemoveEditor_Click_(ByRef Sender As Control)
		Declare Sub cmdRemoveEditor_Click(ByRef Sender As Control)
		Declare Static Sub cmdClearEditor_Click_(ByRef Sender As Control)
		Declare Sub cmdClearEditor_Click(ByRef Sender As Control)
		Declare Static Sub optPromptForProjectAndFiles_Click(ByRef Sender As RadioButton)
		Declare Static Sub optCreateProjectFile_Click(ByRef Sender As RadioButton)
		Declare Static Sub optOpenLastSession_Click(ByRef Sender As RadioButton)
		Declare Static Sub optDoNotNothing_Click(ByRef Sender As RadioButton)
		Declare Static Sub cmdFindCompilers_Click_(ByRef Sender As Control)
		Declare Sub cmdFindCompilers_Click(ByRef Sender As Control)
		Declare Static Sub lvOtherEditors_ItemActivate_(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub lvOtherEditors_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Static Sub lvTerminalPaths_ItemActivate_(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub lvTerminalPaths_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Static Sub lvDebuggerPaths_ItemActivate_(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub lvDebuggerPaths_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Static Sub lvHelpPaths_ItemActivate_(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub lvHelpPaths_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Static Sub lvMakeToolPaths_ItemActivate_(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub lvMakeToolPaths_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Static Sub lvCompilerPaths_ItemActivate_(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub lvCompilerPaths_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Static Sub cmdInFolder_Click_(ByRef Sender As Control)
		Declare Sub cmdInFolder_Click(ByRef Sender As Control)
		Declare Static Sub chkCreateNonStaticEventHandlers_Click_(ByRef Sender As CheckBox)
		Declare Sub chkCreateNonStaticEventHandlers_Click(ByRef Sender As CheckBox)
		Declare Static Sub cmdUpdateLng_Click_(ByRef Sender As Control)
		Declare Sub cmdUpdateLng_Click(ByRef Sender As Control)
		Declare Constructor
		Declare Destructor
		
		Dim As TreeView tvOptions
		Dim As CommandButton cmdOK, cmdCancel, cmdApply, cmdAddCompiler, cmdMFFPath, cmdAddInclude, cmdRemoveInclude, cmdAddLibrary, cmdRemoveLibrary, cmdChangeDebugger, cmdChangeTerminal, cmdChangeMakeTool, cmdAdd, cmdRemove, cmdForeground, cmdFont, cmdProjectsPath, cmdBackground, cmdIndicator, cmdRemoveCompiler, cmdClearCompilers, cmdAddDebugger, cmdRemoveDebugger, cmdClearDebuggers, cmdAddMakeTool, cmdRemoveMakeTool, cmdClearMakeTools, cmdAddTerminal, cmdRemoveTerminal, cmdClearTerminals, cmdSetShortcut
		Dim As Label lblBlack, lblWhite, lblCompiler32, lblCompiler64, lblTabSize, lblHistoryLimit, lblGridSize, lblFont, lblProjectsPath, lblForeground, lblBackground, lblIndicator, lblOthers, lblShortcut
		Dim As Panel pnlGeneral, pnlLocalization, pnlShortcuts, pnlThemes, pnlCodeEditor, pnlColorsAndFonts, pnlCompiler, pnlMake, pnlDebugger, pnlTerminal, pnlDesigner, pnlHelp, pnlIncludes, pnlIncludeMFFPath, pnlThemesCheckboxes, pnlColors, pnlGrid, pnlOtherEditors
		Dim As Picture lblColorForeground, lblColorBackground, lblColorIndicator
		Dim As TextBox txtMFFpath, txtTabSize, txtHistoryLimit, txtGridSize, txtProjectsPath, txtInFolder, txtIntellisenseLimit, txtEnvironmentVariables, txtHistoryCodeDays,  txtFoldsHtml(0), txtFoldsLng
		Dim As ComboBoxEdit cboLanguage, cboCase, cboTabStyle, cboTheme, cboCompiler32, cboCompiler64, cboDebugger32, cboMakeTool, cboTerminal, cboHelp, cboDebugger64, cboDefaultProjectFile, cboOpenedFile, cboGDBDebugger32, cboGDBDebugger64
		Dim As CheckBox CheckBox1, chkAutoCreateRC, chkAutoSaveCurrentFileBeforeCompiling, chkEnableAutoComplete, chkTabAsSpaces, chkAutoIndentation, chkShowSpaces, chkShowAlignmentGrid, chkSnapToGrid, chkChangeKeywordsCase, chkForeground, chkBackground, chkIndicator, chkBold, chkItalic, chkUnderline, chkUseMakeOnStartWithCompile
		Dim As HotKey hkShortcut
		Dim OpenD As OpenFileDialog
		Dim BrowsD As FolderBrowserDialog
		Dim ColorD As ColorDialog
		Dim FontD As FontDialog
		Dim As WString Ptr EditFontName, InterfFontName, oldInterfFontName
		Dim As Boolean oldDarkMode
		Dim As Integer EditFontSize, InterfFontSize, oldInterfFontSize
		Dim Colors(Any, Any) As Integer
		Dim ColorsCount As Integer
		Dim As Boolean FDisposing
		Dim As WStringList HotKeysPriv, Templates
		Dim As Boolean HotKeysChanged
		Dim As Integer LibraryPathsCount
		Dim As ListControl lstIncludePaths, lstLibraryPaths, lstColorKeys
		Dim As GroupBox grbGrid, grbColors, grbThemes, grbFont, grbDefaultCompilers, grbCompilerPaths, grbDefaultDebuggers, grbDebuggerPaths, grbMakeToolPaths, grbDefaultMakeTool, grbDefaultTerminal, grbTerminalPaths, grbIncludePaths, grbLibraryPaths, grbLanguage, grbDefaultHelp, grbHelpPaths, grbWhenCompiling, grbShortcuts, grbOtherEditors, grbWhenVFBEStarts, grbCommandPromptOptions
		Dim As ListView lvCompilerPaths, lvDebuggerPaths, lvMakeToolPaths, lvTerminalPaths, lvHelpPaths, lvShortcuts, lvOtherEditors
		Dim As Label lblInterfaceFont
		Dim As CommandButton cmdInterfaceFont
		Dim As Label lblInterfaceFontLabel
		Dim As CheckBox chkDisplayIcons, chkShowMainToolbar, chkAutoCreateBakFiles, chkShowToolBoxLocal, chkShowPropLocal
		Dim As Label lblFrame, lblDebugger32, lblDebugger64, lblFindCompilersFromComputer, lblOpenCommandPromptIn, lblIntellisenseLimit, lblDebugger321, lblDebugger641, lblHistoryDay, lblShowMsg
		Dim As Picture lblColorFrame
		Dim As CommandButton cmdFrame, cmdChangeCompiler, cmdAddHelp, cmdChangeHelp, cmdRemoveHelp, cmdClearHelps, cmdAddEditor, cmdChangeEditor, cmdRemoveEditor, cmdClearEditor, cmdFindCompilers, cmdInFolder, cmdUpdateLng,  cmdUpdateLngHTMLFolds(0),  cmdReplaceInFiles(0)
		Dim As CheckBox chkFrame, chkAllLNG
		Dim As CheckBox chkHighlightCurrentWord
		Dim As CheckBox chkHighlightCurrentLine
		Dim As CheckBox chkHighlightBrackets, chkIncludeMFFPath, chkLimitDebug, chkDisplayWarningsInDebug, chkCreateNonStaticEventHandlers, chkShowKeywordsTooltip, chkAddSpacesToOperators, chkCreateFormTypesWithoutTypeWord, chkTurnOnEnvironmentVariables, chkDarkMode, chkPlaceStaticEventHandlersAfterTheConstructor, chkCreateStaticEventHandlersWithAnUnderscoreAtTheBeginning, chkAddRelativePathsToRecent, chkShowTooltipsAtTheTop
		Dim As Boolean oldDisplayMenuIcons
		Dim As RadioButton optSaveCurrentFile, optDoNotSave, optSaveAllFiles, optPromptForProjectAndFile, optCreateProjectFile, optOpenLastSession, optDoNotNothing, optPromptToSave, optMainFileFolder, optInFolder
	End Type
'#End Region

Declare Sub FindCompilersSub(Param As Any Ptr)

Declare Sub cboDefaultProjectFileCheckEnable
Declare Sub HistoryCodeClean(ByRef Path As WString)
Common Shared pfOptions As frmOptions Ptr

#ifndef __USE_MAKE__
	#include once "frmOptions.frm"
#endif
