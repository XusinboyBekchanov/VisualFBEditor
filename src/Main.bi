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

Using My.Sys.Forms

Declare Function ML(ByRef msg As WString) ByRef As WString
Declare Sub PopupClick(ByRef Sender As My.Sys.Object)
Declare Sub mClick(Sender As My.Sys.Object)
Declare Sub mClickMRU(Sender As My.Sys.Object)
Declare Sub LoadLanguageTexts

Common Shared As Form Ptr pfrmMain
Common Shared As SaveFileDialog Ptr pSaveD
Common Shared As ListView Ptr plvSearch
Common Shared As TreeListView Ptr plvProperties, plvEvents
Common Shared As ImageList Ptr pimgList, pimgListTools
Common Shared As ProgressBar Ptr pprProgress
Common Shared As TextBox Ptr ptxtPropertyValue
Common Shared As ToolBar Ptr ptbStandard
Common Shared As ToolButton Ptr SelectedTool
Common Shared As TabControl Ptr ptabCode, ptabBottom, ptabRight
Common Shared As TreeView Ptr ptvExplorer
Common Shared As IniFile Ptr piniSettings, piniTheme
Common Shared As MenuItem Ptr mnuUseDebugger

Common Shared As Boolean AutoIncrement
Common Shared As Boolean AutoComplete
Common Shared As Boolean AutoCreateRC
Common Shared As Boolean AutoSaveCompile
Common Shared As Boolean UseMakeOnStartWithCompile
Common Shared As Boolean UseDebugger
Common Shared As Boolean CompileGUI
Common Shared As Boolean mFormFind ' David Change
Common Shared As Boolean InDebug
Common Shared As String CurLanguage
Common Shared As WString Ptr sTemp, sTemp2
Common Shared As WString Ptr HelpPath
Common Shared As WString Ptr ProjectsPath
Common Shared As WString Ptr DefaultMakeTool, CurrentMakeTool1, CurrentMakeTool2, MakeToolPath
Common Shared As WString Ptr DefaultDebugger, CurrentDebugger, DebuggerPath, DefaultTerminal, CurrentTerminal, TerminalPath
Common Shared As WString Ptr DefaultCompiler32, CurrentCompiler32, DefaultCompiler64, CurrentCompiler64, Compiler32Path, Compiler64Path
Common Shared As WString Ptr Compiler32Arguments, Compiler64Arguments, Make1Arguments, Make2Arguments, RunArguments, DebugArguments

Common Shared As WStringList Ptr pComps, pGlobalFunctions, pAddIns
Common Shared As Dictionary Ptr pCompilers, pMakeTools, pDebuggers, pTerminals

Declare Sub NewProject
Declare Sub OpenProject
Declare Sub AddMRUFile(ByRef FileName As WString)
Declare Sub AddFileToProject
Declare Sub RemoveFileFromProject
Declare Function SaveProject(ByRef tn As TreeNode Ptr, bWithQuestion As Boolean = False) As Boolean
Declare Function CloseProject(tn As TreeNode Ptr) As Boolean
Declare Function GetFullPath(ByRef Path As WString) ByRef As WString
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
Declare Sub WithFolder
Declare Sub Save
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
Declare Sub CloseAllTabs(WithoutCurrent As Boolean = False)
Declare Sub RunHelp(Param As Any Ptr)

#ifndef __USE_MAKE__
	#include once "Main.bas"
#endif
