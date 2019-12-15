'#########################################################
'#  frmOptions.bas                                       #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (2018-2019)              #
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
#include once "mff/ListView.bi"

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
		Declare Static Sub CommandButton4_Click(ByRef Sender As Control)
		Declare Static Sub CommandButton5_Click(ByRef Sender As Control)
		Declare Static Sub CommandButton6_Click(ByRef Sender As Control)
		Declare Static Sub cmdForeground_Click(ByRef Sender As Control)
		Declare Static Sub CommandButton4_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Static Sub TreeView1_SelChange(ByRef Sender As TreeView, ByRef Item As TreeNode)
		Declare Static Sub pnlIncludes_ActiveControlChange(ByRef Sender As Control)
		Declare Static Sub cmdMFFPath_Click(ByRef Sender As Control)
		Declare Static Sub cmdDebugger_Click(ByRef Sender As Control)
		Declare Static Sub cmdTerminal_Click(ByRef Sender As Control)
		Declare Static Sub pnlLocalization_Click(ByRef Sender As Control)
		Declare Static Sub txtHistoryLimit_Change(ByRef Sender As TextBox)
		Declare Static Sub CommandButton7_Click(ByRef Sender As Control)
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
		Declare Sub LoadSettings()
		Declare Constructor
		
		Dim As TreeView tvOptions
		Dim As CommandButton cmdOK, cmdCancel, cmdApply, CommandButton4, cmdAddCompiler, CommandButton6, cmdMFFPath, cmdAddInclude, cmdRemoveInclude, cmdAddLibrary, cmdRemoveLibrary, cmdDebugger, cmdTerminal, CommandButton7, cmdAdd, cmdRemove, cmdForeground, cmdFont, cmdProjectsPath, cmdBackground, cmdIndicator, cmdRemoveCompiler, cmdClearCompilers, cmdAddDebugger, cmdRemoveDebugger, cmdClearDebuggers, cmdAddMakeTool, cmdRemoveMakeTool, cmdClearMakeTools, cmdAddTerminal, cmdRemoveTerminal, cmdClearTerminals
		Dim As Label lblBlack, lblWhite, lblCompiler32, lblCompiler64, lblLanguage, lblHelp, lblMFF, lblTabSize, lblHistoryLimit, lblGridSize, lblFont, lblProjectsPath, lblForeground, lblBackground, lblIndicator, lblOthers
		Dim As Panel pnlGeneral, pnlCodeEditor, pnlColorsAndFonts, pnlCompiler, pnlMake, pnlDebugger, pnlTerminal, pnlDesigner, pnlLocalization, pnlHelp, pnlIncludes, pnlColor
		Dim As Picture lblColorForeground, lblColorBackground, lblColorIndicator
		Dim As TextBox TextBox1, TextBox3, txtMFFpath, txtTabSize, txtDebugger, txtTerminal, txtHistoryLimit, txtGridSize, txtMake, txtProjectsPath, TextBox2, txtDebuggerVersion, txtMakeVersion, txtTerminalVersion
		Dim As ComboBoxEdit ComboBoxEdit1, cboCase, cboTabStyle, cboTheme, cboCompiler32, cboCompiler64, cboDebugger, cboMakeTool, cboTerminal
		Dim As CheckBox CheckBox1, chkAutoCreateRC, chkAutoSaveCompile, chkEnableAutoComplete, chkTabAsSpaces, chkAutoIndentation, chkShowSpaces, chkShowAlignmentGrid, chkSnapToGrid, chkChangeKeywordsCase, chkForeground, chkBackground, chkIndicator, chkBold, chkItalic, chkUnderline, chkUseMakeOnStartWithCompile
		Dim OpenD As OpenFileDialog
		Dim BrowsD As FolderBrowserDialog
		Dim ColorD As ColorDialog
		Dim FontD As FontDialog
		Dim EditFontName As WString Ptr
		Dim EditFontSize As Integer
		Dim Colors(14, 6) As Integer
		Dim As Integer LibraryPathsCount
		Dim As ListControl lstIncludePaths, lstLibraryPaths, lstColorKeys
		Dim As GroupBox grbGrid, grbColors, grbFont, grbDefaultCompilers, grbCompilerPaths, grbDefaultDebugger, grbDebuggerPaths, grbMakeToolPaths, grbDefaultMakeTool, grbDefaultTerminal, grbTerminalPaths, grbIncludePaths, grbLibraryPaths
		Dim As ListView lvCompilerPaths, lvDebuggerPaths, lvMakeToolPaths, lvTerminalPaths
	End Type
'#End Region

Common Shared pfOptions As frmOptions Ptr

#ifndef __USE_MAKE__
	#Include Once "frmOptions.bas"
#EndIf
