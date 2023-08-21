'#########################################################
'#  frmProjectProperties.bi                              #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "mff/Form.bi"
#include once "mff/TabControl.bi"
#include once "mff/CommandButton.bi"
#include once "mff/Label.bi"
#include once "mff/ComboBoxEdit.bi"
#include once "mff/TextBox.bi"
#include once "mff/GroupBox.bi"
#include once "mff/Panel.bi"
#include once "mff/CheckBox.bi"
#include once "mff/ImageBox.bi"
#include once "mff/ListControl.bi"
#include once "mff/Picture.bi"
#include once "mff/RadioButton.bi"
#include once "mff/Dictionary.bi"
#include once "mff/TreeView.bi"

Using My.Sys.Forms

'#Region "Form"
	Type frmProjectProperties Extends Form
		Declare Static Sub cmdOK_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub pnlApplication_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub tpCompile_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub lstType_Change(ByRef Designer As My.Sys.Object, ByRef Sender As ListControl)
		Declare Static Sub txtValue_LostFocus(ByRef Designer As My.Sys.Object, ByRef Sender As TextBox)
		Declare Static Sub Form_Show      (ByRef Designer As My.Sys.Object, ByRef Sender As Form)
		Declare Static Sub optCompileToGas_Click(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton)
		Declare Static Sub optCompileToGcc_Click(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton)
		Declare Sub RefreshProperties()
		Declare Static Sub cmdAdvancedOptions_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub optCompileByDefault_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton)
		Declare Sub optCompileByDefault_Click(ByRef Sender As RadioButton)
		Declare Static Sub optCompileToLLVM_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton)
		Declare Sub optCompileToLLVM_Click(ByRef Sender As RadioButton)
		Declare Static Sub CommandButton1_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Static Sub tpDebugging_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub tpDebugging_Click(ByRef Sender As Control)
		Declare Static Sub chkAndroidProject_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
		Declare Sub chkAndroidProject_Click(ByRef Sender As CheckBox)
		Declare Static Sub cmdAndroidSDKLocation_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdAndroidSDKLocation_Click(ByRef Sender As Control)
		Declare Static Sub cmdAndroidNDKLocation_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdAndroidNDKLocation_Click(ByRef Sender As Control)
		Declare Static Sub cmdJDKLocation_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdJDKLocation_Click(ByRef Sender As Control)
		Declare Static Sub cmdCompiler_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdCompiler_Click(ByRef Sender As Control)
		Declare Static Sub txtCompilerPath_Change_(ByRef Designer As My.Sys.Object, ByRef Sender As TextBox)
		Declare Sub txtCompilerPath_Change(ByRef Sender As TextBox)
		Declare Static Sub cboCompiler_Selected_(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub cboCompiler_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Static Sub chkManifest_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
		Declare Sub chkManifest_Click(ByRef Sender As CheckBox)
		Declare Static Sub _cboOptimizationLevel_Selected(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub cboOptimizationLevel_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Static Sub _Form_Create(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Static Sub _cmdAddComponent_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdAddComponent_Click(ByRef Sender As Control)
		Declare Static Sub _cmdRemoveComponent_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdRemoveComponent_Click(ByRef Sender As Control)
		Declare Static Sub _cmdAddOtherInclude_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdAddOtherInclude_Click(ByRef Sender As Control)
		Declare Static Sub _cmdRemoveOtherInclude_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdRemoveOtherInclude_Click(ByRef Sender As Control)
		Declare Static Sub _cmdAddLibrary_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdAddLibrary_Click(ByRef Sender As Control)
		Declare Static Sub _cmdRemoveLibrary_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdRemoveLibrary_Click(ByRef Sender As Control)
		Declare Constructor
		
		Dim As TabControl tabProperties
		Dim As TabPage tpGeneral, tpMake, tpCompile, tpDebugging, tpAndroidSettings, tpIncludes
		Dim As CommandButton cmdOK, cmdCancel, cmdHelp, cmdAdvancedOptions, CommandButton1, cmdAndroidSDKLocation, cmdAndroidNDKLocation, cmdJDKLocation, cmdCompiler, cmdAddComponent, cmdRemoveComponent, cmdAddOtherInclude, cmdRemoveOtherInclude, cmdAddLibrary, cmdRemoveLibrary
		Dim As Label lblProjectType, lblMainFile, lblProjectName, lblProjectDescription, lblCompilationArguments64, lblIcon, lblTitle, lblMajor, lblMinor, lblRevision, lblBuild, lblResourceFile, lblIconResourceFile, lblCompilationArguments32Linux, lblCompilationArguments64Linux, lblCompilationArguments32, lblType, lblValue, lblHelpFileName, lblCompilationArguments321, lblSubsystem, lblAndroidSDKLocation, lblAndroidNDKLocation, lblJDKLocation, lblCompiler, lblBatchCompilationFileWindows, lblBatchCompilationFileLinux, lblComponents, lblOthers
		Dim As Picture picCompileToGCC, picVersionNumber, picApplication, picVersionInformation, picCompilationArguments, picComponents, picOtherIncludes
		Dim As ComboBoxEdit cboProjectType, cboMainFile, cboResourceFile, cboIconResourceFile, cboOptimizationLevel, cboSubsystem, cboCompiler, cboBatchCompilationFileWindows, cboBatchCompilationFileLinux
		Dim As TextBox txtProjectName, txtProjectDescription, txtCompilationArguments32Windows, txtCompilationArguments64Windows, txtIcon, txtTitle, txtMajor, txtMinor, txtRevision, txtBuild, txtCompilationArguments32Linux, txtValue, txtHelpFileName, txtCommandLineArguments, txtCompilationArguments64Linux, txtAndroidSDKLocation, txtAndroidNDKLocation, txtJDKLocation, txtCompilerPath
		Dim As GroupBox grbVersionNumber, grbApplication, grbVersionInformation, grbCompilationArguments, grbCompileToGCC, grbIncludePaths, grbLibraryPaths
		Dim As CheckBox chkAutoIncrementVersion, chkCreateDebugInfo, chkPassAllModuleFilesToCompiler, chkManifest, chkRunAsAdministrator, chkOpenProjectAsFolder
		Dim As ListControl lstType, lstComponents, lstOtherIncludes, lstLibraryPaths
		Dim As RadioButton optCompileToGas, optCompileToGcc, optOptimizationFastCode, optOptimizationLevel, optOptimizationSmallCode, optNoOptimization, optCompileByDefault, optCompileToLLVM
		Dim As Dictionary Types, MainFiles, ResourceFiles, IconResourceFiles, BatchCompilationFilesWindows, BatchCompilationFilesLinux
		Dim As TreeNode Ptr ProjectTreeNode
		Dim As ImageBox imgIcon
		Dim As FolderBrowserDialog BrowseD
		Dim As OpenFileDialog OpenD
	End Type
	
	Common Shared pfProjectProperties As frmProjectProperties Ptr
'#End Region

#ifndef __USE_MAKE__
	#include once "frmProjectProperties.frm"
#endif
