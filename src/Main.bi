'#########################################################
'#  Main.bi                                              #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "mff/WStringList.bi"
#include once "mff/Dictionary.bi"
#include once "mff/Form.bi"
#include once "mff/Dialogs.bi"
#include once "mff/TreeView.bi"
#include once "mff/TreeListView.bi"
#include once "mff/ProgressBar.bi"
#include once "mff/TabControl.bi"
#include once "mff/ToolPalette.bi"
#include once "mff/TextBox.bi"
#include once "mff/IniFile.bi"
#ifndef __USE_GTK__
	#include once "mff/PageSetupDialog.bi"
	#include once "mff/PrintDialog.bi"
	#include once "mff/PrintPreviewDialog.bi"
	#include once "mff/Printer.bi"
#endif

#ifdef __FB_WIN32__
	#ifdef __FB_64BIT__
		#define SettingsPath ExePath & "/Settings/VisualFBEditor64.ini"
	#else
		#define SettingsPath ExePath & "/Settings/VisualFBEditor32.ini"
	#endif
#else
	#ifdef __FB_64BIT__
		#define SettingsPath ExePath & "/Settings/VisualFBEditorX64.ini"
	#else
		#define SettingsPath ExePath & "/Settings/VisualFBEditorX32.ini"
	#endif
#endif

#ifdef __FB_WIN32__
	#define Slash "\"
	#define BackSlash "/"
#else
	#define Slash "/"
	#define BackSlash "\"
#endif

Using My.Sys.Forms

Declare Function ML(ByRef msg As WString) ByRef As WString
Declare Sub PopupClick(ByRef Sender As My.Sys.Object)
Declare Sub mClick(Sender As My.Sys.Object)
Declare Sub mClickMRU(Sender As My.Sys.Object)
Declare Sub mClickHelp(Sender As My.Sys.Object)
Declare Sub mClickTool(Sender As My.Sys.Object)
Declare Sub LoadSettings
Declare Sub LoadLanguageTexts

Common Shared As Form Ptr pfrmMain
Common Shared As SaveFileDialog Ptr pSaveD
Common Shared As ListView Ptr plvSearch, plvToDo 'David Change
Common Shared As TreeListView Ptr plvProperties, plvEvents
Common Shared As ImageList Ptr pimgList, pimgListTools
Common Shared As ProgressBar Ptr pprProgress
Common Shared As TextBox Ptr ptxtPropertyValue
Common Shared As ToolBar Ptr ptbStandard
Common Shared As ToolButton Ptr SelectedTool
Common Shared As TabControl Ptr ptabCode, ptabLeft, ptabBottom, ptabRight
Common Shared As TreeView Ptr ptvExplorer
Common Shared As IniFile Ptr piniSettings, piniTheme
Common Shared As MenuItem Ptr mnuUseDebugger, miHelps, miXizmat

Common Shared As Boolean AutoIncrement
Common Shared As Boolean AutoComplete
Common Shared As Boolean AutoCreateRC
Common Shared As Boolean AutoCreateBakFiles
Common Shared As Boolean AutoReloadLastOpenFiles
Common Shared As Boolean UseMakeOnStartWithCompile
Common Shared As Boolean LimitDebug
Common Shared As Boolean UseDebugger
Common Shared As Boolean CompileGUI
Common Shared As Boolean mFormFind, mFormFindInFile
Common Shared As Boolean InDebug, FormClosing
Common Shared As Boolean HighlightCurrentLine, HighlightCurrentWord, HighlightBrackets
Common Shared As Boolean mTabSelChangeByError
Common Shared As Boolean DisplayMenuIcons, ShowMainToolBar
Common Shared As Integer AutoSaveBeforeCompiling
Common Shared As Integer IncludeMFFPath
Common Shared As Integer gSearchItemIndex
Common Shared As Integer InterfaceFontSize
Common Shared As String CurLanguage
Common Shared As WString Ptr InterfaceFontName
Common Shared As WString Ptr gSearchSave
Common Shared As WString Ptr ProjectsPath, LastOpenPath
Common Shared As WString Ptr DefaultHelp, HelpPath
Common Shared As WString Ptr DefaultMakeTool, CurrentMakeTool1, CurrentMakeTool2, MakeToolPath
Common Shared As WString Ptr DefaultDebugger, CurrentDebugger, DebuggerPath, DefaultTerminal, CurrentTerminal, TerminalPath
Common Shared As WString Ptr DefaultCompiler32, CurrentCompiler32, DefaultCompiler64, CurrentCompiler64, Compiler32Path, Compiler64Path
Common Shared As WString Ptr Compiler32Arguments, Compiler64Arguments, Make1Arguments, Make2Arguments, RunArguments, DebugArguments
Common Shared As Any Ptr tlock, tlockSave

Common Shared As List Ptr pTools
Common Shared As WStringList Ptr pComps, pGlobalNamespaces, pGlobalTypes, pGlobalEnums, pGlobalFunctions, pGlobalArgs, pAddIns, pIncludeFiles, pLoadPaths, pIncludePaths, pLibraryPaths
Common Shared As Dictionary Ptr pCompilers, pMakeTools, pDebuggers, pTerminals, pHelps

Enum LoadParam
	OnlyFilePath
	OnlyFilePathOverwrite
	OnlyIncludeFiles
	FilePathAndIncludeFiles
End Enum

Declare Sub NewProject
Declare Sub OpenProject
Declare Sub AddMRUFile(ByRef FileName As WString)
Declare Sub AddMRUProject(ByRef FileName As WString) 'David Change
Declare Sub AddMRUSession(ByRef FileName As WString) 'David Change
Declare Sub AddFileToProject
Declare Sub RemoveFileFromProject
Declare Sub OpenUrl(ByVal url As String)
Declare Function AddProject(ByRef FileName As WString = "", pFilesList As WStringList Ptr = 0, tn As TreeNode Ptr = 0) As TreeNode Ptr
Declare Function SaveProject(ByRef tn As TreeNode Ptr, bWithQuestion As Boolean = False) As Boolean
Declare Function CloseProject(tn As TreeNode Ptr) As Boolean
Declare Sub SetMainNode(tn As TreeNode Ptr)
Declare Sub OpenProjectFolder
Declare Sub OpenFiles(ByRef FileName As WString)
Declare Sub OpenSession
Declare Sub OpenProgram()
Declare Sub PrintThis()
Declare Sub PrintPreview()
Declare Sub PageSetup()
Declare Sub SetAsMain()
Declare Sub SetAutoColors
Declare Sub StartProgress()
Declare Sub StopProgress()
Declare Function EqualPaths(ByRef a As WString, ByRef b As WString) As Boolean
Declare Sub ChangeEnabledDebug(bStart As Boolean, bBreak As Boolean, bEnd As Boolean)
Declare Sub ChangeUseDebugger(bUseDebugger As Boolean, ChangeObject As Integer = -1)
#ifndef __USE_GTK__
	Common Shared As UINT_PTR CurrentTimer
	Declare Sub TimerProc(hwnd As HWND, uMsg As UINT, idEvent As UINT_PTR, dwTime As DWORD)
#endif
Declare Function WithoutPointers(ByRef e As String) As String
Declare Sub WithFolder
Declare Sub Save
Declare Sub SaveAllBeforeCompile()
Declare Function SaveSession() As Boolean
Declare Sub CompileProgram(Param As Any Ptr)
Declare Sub CompileWithDebugger(Param As Any Ptr)
Declare Sub CompileAndRun(Param As Any Ptr)
Declare Sub MakeExecute(Param As Any Ptr)
Declare Sub MakeClean(Param As Any Ptr)
Declare Sub SyntaxCheck(Param As Any Ptr)
Declare Sub NextBookmark(iTo As Integer = 1)
Declare Sub ClearAllBookmarks
Declare Sub SaveAll()
Declare Sub FormatProject(UnFormat As Any Ptr)
Declare Function GetChangedCommas(Value As String) As String
Declare Function GetFileName(ByRef FileName As WString) As UString
Declare Function GetExeFileName(ByRef FileName As WString, ByRef sLine As WString) As UString
Declare Function GetBakFileName(ByRef FileName As WString) As UString
Declare Function GetShortFileName(ByRef FileName As WString, ByRef FilePath As WString) As UString
Declare Function GetFolderName(ByRef FileName As WString, WithSlash As Boolean = True) As UString
Declare Function GetOSPath(ByRef Path As WString) As UString
Declare Function GetFullPath(ByRef Path As WString, ByRef FromFile As WString = "") As UString
Declare Function GetRelativePath(ByRef Path As WString, ByRef FromFile As WString = "") As UString
Declare Function Compile(Parameter As String = "") As Integer
Declare Sub LoadFunctions(ByRef Path As WString, LoadParameter As LoadParam = FilePathAndIncludeFiles, ByRef Types As WStringList, ByRef Enums As WStringList, ByRef Functions As WStringList, ByRef Args As WStringList, ec As Control Ptr = 0)
Declare Sub LoadFunctionsSub(Param As Any Ptr)
Declare Sub LoadOnlyFilePath(Param As Any Ptr)
Declare Sub LoadOnlyFilePathOverwrite(Param As Any Ptr)
Declare Sub LoadOnlyIncludeFiles(Param As Any Ptr)
Declare Sub LoadFromTabWindow(Param As Any Ptr)
Declare Sub CloseAllTabs(WithoutCurrent As Boolean = False)
Declare Sub RunHelp(Param As Any Ptr)

Common Shared As Integer tabLeftWidth, tabRightWidth, tabBottomHeight
Declare Sub SetLeftClosedStyle(Value As Boolean)
Declare Sub SetRightClosedStyle(Value As Boolean)
Declare Sub SetBottomClosedStyle(Value As Boolean)

#ifndef __USE_MAKE__
	#include once "Main.bas"
#endif
