'#########################################################
'#  VisualFBEditor.bas                                   #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################
'#ifndef __FB_WIN32__
'	#cmdline "-gen gas64"
'#endif
'#define __USE_GTK__
#ifndef __USE_MAKE__
	'#define __USE_GTK3__
	#define _NOT_AUTORUN_FORMS_
#endif

#if defined(__USE_WINAPI__) OrElse defined(__FB_WIN32__) AndAlso Not defined(__USE_GTK__)
	#ifdef __FB_64BIT__
		#cmdline "-x ../VisualFBEditor64.exe"
	#else
		#cmdline "-x ../VisualFBEditor32.exe"
	#endif
#elseif defined(__USE_GTK__) AndAlso defined(__FB_WIN32__)
	#ifdef __FB_64BIT__
		#ifdef __USE_GTK3__
			#cmdline "-x ../VisualFBEditor64_gtk3.exe"
		#else
			#cmdline "-x ../VisualFBEditor64_gtk2.exe"
		#endif
	#else
		#ifdef __USE_GTK3__
			#cmdline "-x ../VisualFBEditor32_gtk3.exe"
		#else
			#cmdline "-x ../VisualFBEditor32_gtk2.exe"
		#endif
	#endif
#else
	#ifdef __FB_64BIT__
		#ifdef __USE_GTK3__
			#cmdline "-x ../VisualFBEditor64_gtk3"
		#else
			#cmdline "-x ../VisualFBEditor64_gtk2"
		#endif
	#else
		#ifdef __USE_GTK3__
			#cmdline "-x ../VisualFBEditor32_gtk3"
		#else
			#cmdline "-x ../VisualFBEditor32_gtk2"
		#endif
	#endif
#endif

#define APP_TITLE "Visual FB Editor"
#define VER_MAJOR "1"
#define VER_MINOR "3"
#define VER_PATCH "7"
#define VER_BUILD "0"
Const VERSION    = VER_MAJOR + "." + VER_MINOR + "." + VER_PATCH
Const BUILD_DATE = __DATE__
Const SIGN       = APP_TITLE + " " + VERSION

On Error Goto AA

#define MEMCHECK 0
#define FILENUMCHECK 1
#define _L DebugPrint_ __LINE__ & ": " & __FILE__ & ": " & __FUNCTION__:

Declare Sub DebugPrint_(ByRef MSG As WString)

#include once "Main.bi"
#include once "Debug.bi"
#include once "Designer.bi"
#include once "frmAddProcedure.frm"
#include once "frmAddType.frm"
#include once "frmOptions.bi"
#include once "frmGoto.bi"
#include once "frmFind.bi"
#include once "frmFindInFiles.bi"
#include once "frmProjectProperties.bi"
#include once "frmImageManager.bi"
#include once "frmParameters.bi"
#include once "frmAddIns.bi"
#include once "frmTools.bi"
#include once "frmAbout.bi"
#include once "TabWindow.bi"

Sub DebugPrint_(ByRef msg As WString)
	Debug.Print msg, True, False, False, False
End Sub

Sub StartDebuggingWithCompile(Param As Any Ptr)
	'	ThreadsEnter
	'	ChangeEnabledDebug False, True, True
	'	ThreadsLeave
	If Compile("RunWithDebug") Then Else ThreadsEnter: ChangeEnabledDebug True, False, False: ThreadsLeave
End Sub

Sub StartDebugging(Param As Any Ptr)
	ThreadsEnter
	ChangeEnabledDebug False, True, True
	ThreadsLeave
	RunProgramWithDebug(0)
End Sub

Sub RunCmd(Param As Any Ptr)
	Dim As UString MainFile = GetMainFile()
	Dim As UString cmd
	Dim As WString Ptr Workdir, CmdL
	If Trim(MainFile) = "" OrElse Trim(MainFile) = ML("Untitled") Then MainFile = GetFullPath(*ProjectsPath & "\1", pApp->FileName)
	If OpenCommandPromptInMainFileFolder Then
		WLet(Workdir, GetFolderName(MainFile))
	Else
		WLet(Workdir, *CommandPromptFolder)
	End If
	#ifdef __USE_GTK__
		cmd = WGet(TerminalPath) & " --working-directory=""" & *Workdir & """"
		Shell(cmd)
	#else
		cmd = Environ("COMSPEC") & " /K cd /D """ & *Workdir & """"
		Dim As Integer pClass
		Dim SInfo As STARTUPINFO
		Dim PInfo As PROCESS_INFORMATION
		WLet(CmdL, cmd)
		SInfo.cb = Len(SInfo)
		SInfo.dwFlags = STARTF_USESHOWWINDOW
		SInfo.wShowWindow = SW_NORMAL
		pClass = CREATE_UNICODE_ENVIRONMENT Or CREATE_NEW_CONSOLE
		If CreateProcessW(NULL, CmdL, ByVal NULL, ByVal NULL, False, pClass, NULL, Workdir, @SInfo, @PInfo) Then
			CloseHandle(PInfo.hProcess)
			CloseHandle(PInfo.hThread)
		End If
		If CmdL Then _Deallocate( CmdL)
	#endif
	If Workdir Then _Deallocate( Workdir)
End Sub

Sub FindInFiles
	ThreadCounter(ThreadCreate_(@FindSub))
End Sub
Sub ReplaceInFiles
	ThreadCounter(ThreadCreate_(@ReplaceSub))
End Sub

Sub mClickUseDefine(ByRef Designer As My.Sys.Object, Sender As My.Sys.Object)
	Dim As String MenuName = Sender.ToString
	Dim As Integer Pos1 = InStr(MenuName, ":")
	If Pos1 = 0 Then Exit Sub
	If miUseDefine <> 0 Then miUseDefine->Checked = False
	If Pos1 = 0 Then Pos1 = Len(MenuName)
	UseDefine = Mid(MenuName, Pos1 + 1)
	miUseDefine = Cast(MenuItem Ptr, @Sender)
	miUseDefine->Checked = True
End Sub
Sub mClickAIChat(ByRef Designer As My.Sys.Object, Sender As My.Sys.Object)
	Dim As WString * MAX_PATH FileName
	Select Case Sender.ToString
	Case "AIChatEdit"
		If Trim(txtAIAgent.SelText) = "" Then
			txtAIAgent.SelStart = InStrRev(txtAIAgent.Text, "```", txtAIAgent.SelStart + 3)
			txtAIAgent.SelEnd = InStr(txtAIAgent.SelStart + 3, txtAIAgent.Text, "```")
		End If
		If Trim(txtAIAgent.SelText) = "" Then Exit Sub
		FileName= GetFullPath(ExePath & Slash & "Temp" & Slash & ML("Untitled") & ".bas")
		SaveToFile(FileName, txtAIAgent.SelText)
		AddTab FileName, True
	Case "AIChatOpen"
		Dim As OpenFileDialog OpenD
		OpenD.InitialDir = ExePath & Slash & "AIChat"
		OpenD.Filter = ML("AIChat Files") & " (*.md)|*.md|" & ML("All Files") & "|*.*|"
		If OpenD.Execute Then
			frmMain.Cursor = crWait
			FileName= GetFileName(OpenD.FileName)
			AIMessages.LoadFromFile(OpenD.FileName)
			If AIMessages.Count < 1 Then frmMain.Cursor = 0 : Exit Sub
			AddMRUAIChat FileName
			WLet(RecentAIChat, FileName)
			_Deallocate(AIBodyWStringPtr ): AIBodyWStringPtr = 0
			For i As Integer = 0 To AIMessages.Count - 1
				If i <> AIMessages.Count - 1 Then
					WAdd(AIBodyWStringPtr, AIMessages.Item(i)->Key & Chr(10) & AIMessages.Item(i)->Text & Chr(10))
				Else
					WAdd(AIBodyWStringPtr, AIMessages.Item(i)->Key & Chr(10) & AIMessages.Item(i)->Text)
				End If
			Next
			
			WLet(AIBodyWStringSavePtr, *AIBodyWStringPtr)
			_Deallocate(AIBodyWStringPtr): AIBodyWStringPtr = 0
			If AIBodyWStringSavePtr Then AIBodyWStringPtr = MDtoRTF(*AIBodyWStringSavePtr)
			If AIBodyWStringPtr Then
				txtAIAgent.TextRTF = *AIBodyWStringPtr
				txtAIAgent.Zoom = Int(txtAIAgent.ScaleX(100) * 0.50)
				txtAIAgent.ScrollToCaret
				txtAIRequest.Enabled = True
				txtAIRequest.SetFocus
			End If
			_Deallocate(AIBodyWStringPtr): AIBodyWStringPtr = 0
			frmMain.Cursor = 0
		End If
	Case "AIChatSave"
		If AIMessages.Count < 1 Then Exit Sub
		frmMain.Cursor = crWait
		FileName = IIf(RecentAIChat, *RecentAIChat, Mid(FormatFileName(Left(AIMessages.Item(0)->Key, 50)) & Format(Now, "yyyymmdd_hhmm") & ".md", 16))
		AIMessages.SaveToFile(ExePath & "/AIChat/" & FileName)
		AIMessages.SaveToFile(ExePath & "/AIChat/" & FileName)
		WLet(RecentAIChat, FileName)
		frmMain.Cursor = 0
	Case "AIChatSaveAs"
		If AIMessages.Count < 1 Then Exit Sub
		Dim As OpenFileDialog OpenD
		SaveD.InitialDir = ExePath & "/AIChat/"
		SaveD.Caption = "Save AIChat Files"
		SaveD.Filter = ML("AIChat Files") & " (*.md)|*.md|" & ML("All Files") & "|*.*|"
		If Not SaveD.Execute Then Exit Sub
		AIMessages.SaveToFile(SaveD.FileName)
		FileName = GetFileName(SaveD.FileName)
		AIMessages.SaveToFile(SaveD.FileName)
		FileName = GetFileName(SaveD.FileName)
		AddMRUAIChat FileName
		WLet(RecentAIChat, FileName)
	Case "ClearAIChat"
		miRecentAIChat->Clear
		miRecentAIChat->Enabled = False
		MRUAIChat.Clear
	Case Else
		FileName= ExePath & "/AIChat/" & Sender.ToString
		AIMessages.LoadFromFile(FileName)
		If AIMessages.Count < 1 Then Exit Sub
		AddMRUAIChat Sender.ToString
		WLet(RecentAIChat, Sender.ToString)
		_Deallocate(AIBodyWStringPtr)
		For i As Integer = 0 To AIMessages.Count - 1
			If i <> AIMessages.Count - 1 Then
				WAdd(AIBodyWStringPtr, AIMessages.Item(i)->Key & Chr(13, 10) & AIMessages.Item(i)->Text & Chr(13, 10))
			Else
				WAdd(AIBodyWStringPtr, AIMessages.Item(i)->Key & Chr(13, 10) & AIMessages.Item(i)->Text)
			End If
		Next
		WLet(AIBodyWStringSavePtr, *AIBodyWStringPtr)
		AIBodyWStringPtr = MDtoRTF(*AIBodyWStringSavePtr)
		txtAIAgent.TextRTF = *AIBodyWStringPtr
		txtAIAgent.Zoom = Int(txtAIAgent.ScaleX(100) * 0.50)
		txtAIRequest.Enabled = True
		txtAIRequest.SetFocus
		_Deallocate(AIBodyWStringPtr): AIBodyWStringPtr = 0
	End Select
End Sub

Sub mClickMRU(ByRef Designer As My.Sys.Object, Sender As My.Sys.Object)
	Select Case Sender.ToString
	Case "ClearFiles"
		miRecentFiles->Clear
		miRecentFiles->Enabled = False
		MRUFiles.Clear
	Case "ClearProjects"
		miRecentProjects->Clear
		miRecentProjects->Enabled = False
		MRUProjects.Clear
	Case "ClearFolders"
		miRecentFolders->Clear
		miRecentFolders->Enabled = False
		MRUFolders.Clear
	Case "ClearSessions"
		miRecentSessions->Clear
		miRecentSessions->Enabled = False
		MRUSessions.Clear
	Case Else
		OpenFiles GetFullPath(Sender.ToString)
	End Select
End Sub

Sub mClickHelp(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Object)
	HelpOption.CurrentPath = Cast(MenuItem Ptr, @Sender)->ImageKey
	HelpOption.CurrentWord = ""
	ThreadCounter(ThreadCreate_(@RunHelp, @HelpOption))
End Sub

Sub mClickTool(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Object)
	Dim As MenuItem Ptr mi = Cast(MenuItem Ptr, @Sender)
	If mi = 0 Then Exit Sub
	Dim As UserToolType Ptr tt = mi->Tag
	If tt <> 0 Then tt->Execute
End Sub

Sub mClickWindow(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Object)
	Dim As MenuItem Ptr mi = Cast(MenuItem Ptr, @Sender)
	If mi = 0 Then Exit Sub
	Dim As TabWindow Ptr tb = mi->Tag
	If tb <> 0 Then tb->SelectTab
End Sub

Sub SelectNextControl
	Select Case frmMain.ActiveControl
	Case @txtExplorer: tvExplorer.SetFocus
	Case @tvExplorer: txtExplorer.SetFocus
	Case @txtForm: tbToolBox.SetFocus
	Case @tbToolBox: txtForm.SetFocus
	Case @txtProperties: lvProperties.SetFocus
	Case @lvProperties: txtProperties.SetFocus
	Case @txtEvents: lvEvents.SetFocus
	Case @lvEvents: txtEvents.SetFocus
	End Select
End Sub

Sub ClearThreadsWindow
	lvThreads.Nodes.Clear
	tpThreads->Caption = ML("Threads")
End Sub

Sub mClick(ByRef Designer_ As My.Sys.Object, Sender As My.Sys.Object)
	Select Case Sender.ToString
	Case "NewProject":                          NewProject
	Case "OpenProject":                         OpenProject
	Case "OpenFolder":                          OpenFolder
	Case "OpenSession":                         OpenSession
	Case "SaveProject":                         SaveProject ptvExplorer->SelectedNode
	Case "SaveProjectAs":                       SaveProject ptvExplorer->SelectedNode, True
	Case "SaveSession":                         SaveSession
	Case "CloseFolder":                         CloseFolder GetParentNode(ptvExplorer->SelectedNode)
	Case "CloseProject":                        CloseProject GetParentNode(ptvExplorer->SelectedNode)
	Case "New":                                 AddTab
	Case "Open":                                OpenProgram
	Case "Save":                                Save
	Case "Print":                               PrintThis
	Case "PrintPreview":                        PrintPreview
	Case "PageSetup":                           PageSetup
	Case "CommandPrompt":                       ThreadCounter(ThreadCreate_(@RunCmd))
	Case "AddFromTemplates":                    AddFromTemplates
	Case "AddFilesToProject":                   AddFilesToProject
	Case "Rename":                              RenameFile
	Case "RemoveFileFromProject":               RemoveFileFromProject
	Case "OpenProjectFolder":                   OpenProjectFolder
	Case "ProjectProperties":                   pfProjectProperties->ShowModal *pfrmMain : pfProjectProperties->CenterToParent
	Case "SetAsMain":                           SetAsMain @Sender = miTabSetAsMain
	Case "ClearStartUp":                        SetMainNode 0
	Case "ReloadHistoryCode":                   ReloadHistoryCode
	Case "ProblemsCopy":                        If lvProblems.ListItems.Count < 1 Then Return Else Clipboard.SetAsText lvProblems.SelectedItem->Text(0)
	Case "ProblemsCopyAll":
		Dim As WString Ptr tmpStrPtr
		If lvProblems.ListItems.Count < 1 Then Return
		For j As Integer = 0 To lvProblems.ListItems.Count - 1
			WAdd(tmpStrPtr, !"\r\n" & lvProblems.ListItems.Item(j)->Text(0))
		Next
		Clipboard.SetAsText *tmpStrPtr
		_Deallocate(tmpStrPtr)
	Case "DarkMode":
		DarkMode = Not DarkMode
		App.DarkMode = DarkMode
		If (*CurrentTheme = "Default Theme" AndAlso DarkMode) OrElse (*CurrentTheme = "Dark (Visual Studio)" AndAlso Not DarkMode) Then
			*CurrentTheme = IIf(DarkMode, "Dark (Visual Studio)", "Default Theme")
			LoadTheme
			UpdateAllTabWindows
		End If
		#ifdef __USE_WINAPI__
			If DarkMode AndAlso g_darkModeSupported Then
				txtLabelProperty.BackColor = darkBkColor
				txtLabelEvent.BackColor = darkBkColor
				fAddIns.txtDescription.BackColor = darkBkColor
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
					DrawMenuBar pApp->Forms[i]->Handle
				End If
			Next i
		#endif
	Case "UseDirect2D":                         frmMain.UpdateLock: UseDirect2D = tbtUseDirect2D->Checked: frmMain.Repaint: frmMain.UpdateUnLock
	Case "ProjectExplorer":                     tpProject->SelectTab: txtExplorer.SetFocus
	Case "PropertiesWindow":                    tpProperties->SelectTab: txtProperties.SetFocus
	Case "EventsWindow":                        tpEvents->SelectTab: txtEvents.SetFocus
	Case "Toolbox":                             tpToolbox->SelectTab: txtForm.SetFocus
	Case "OutputWindow":                        tpOutput->SelectTab
	Case "ProblemsWindow":                      tpProblems->SelectTab
	Case "SuggestionsWindow":                   tpSuggestions->SelectTab
	Case "FindWindow":                          tpFind->SelectTab
	Case "ToDoWindow":                          tpToDo->SelectTab
	Case "ChangeLogWindow":                     tpChangeLog->SelectTab
	Case "ImmediateWindow":                     tpImmediate->SelectTab
	Case "LocalsWindow":                        tpLocals->SelectTab
	Case "GlobalsWindow":                       tpGlobals->SelectTab
		'Case "ProceduresWindow":                    tpProcedures->SelectTab
	Case "ThreadsWindow":                       tpThreads->SelectTab
	Case "WatchWindow":                         tpWatches->SelectTab
	Case "ImageManager":                        pfImageManager->Show *pfrmMain : pfImageManager->CenterToParent
	Case "Toolbars":                            'ShowMainToolbar = Not ShowMainToolbar: ReBar1.Visible = ShowMainToolbar: pfrmMain->RequestAlign
	Case "Standard":                            ShowStandardToolBar = Not ShowStandardToolBar: MainReBar.Bands.Item(0)->Visible = ShowStandardToolBar: mnuStandardToolBar->Checked = ShowStandardToolBar: pfrmMain->RequestAlign
	Case "Edit":                                ShowEditToolBar = Not ShowEditToolBar: MainReBar.Bands.Item(1)->Visible = ShowEditToolBar: mnuEditToolBar->Checked = ShowEditToolBar: pfrmMain->RequestAlign
	Case "Project":                             ShowProjectToolBar = Not ShowProjectToolBar: MainReBar.Bands.Item(2)->Visible = ShowProjectToolBar: mnuProjectToolBar->Checked = ShowProjectToolBar: pfrmMain->RequestAlign
	Case "FormFormat":                          ShowFormatToolBar = Not ShowFormatToolBar: MainReBar.Bands.Item(6)->Visible = ShowFormatToolBar: mnuFormatToolBar->Checked = ShowFormatToolBar: pfrmMain->RequestAlign
	Case "Build":                               ShowBuildToolBar = Not ShowBuildToolBar: MainReBar.Bands.Item(3)->Visible = ShowBuildToolBar: mnuBuildToolBar->Checked = ShowBuildToolBar: pfrmMain->RequestAlign
	Case "Debug":                               ShowDebugToolBar = Not ShowDebugToolBar: MainReBar.Bands.Item(4)->Visible = ShowDebugToolBar: mnuDebugToolBar->Checked = ShowDebugToolBar: pfrmMain->RequestAlign
	Case "Run":                                 ShowRunToolBar = Not ShowRunToolBar: MainReBar.Bands.Item(5)->Visible = ShowRunToolBar: mnuRunToolBar->Checked = ShowRunToolBar: pfrmMain->RequestAlign
	Case "TBUseDebugger":                       ChangeUseDebugger tbtUseDebugger->Checked, 0
	Case "UseDebugger":                         ChangeUseDebugger Not mnuUseDebugger->Checked, 1
	Case "UseProfiler":                         mnuUseProfiler->Checked = Not mnuUseProfiler->Checked
	Case "ShowWithFolders":                     ChangeFolderType ProjectFolderTypes.ShowWithFolders
	Case "ShowWithoutFolders":                  ChangeFolderType ProjectFolderTypes.ShowWithoutFolders
	Case "ShowAsFolder":                        ChangeFolderType ProjectFolderTypes.ShowAsFolder
	Case "SyntaxCheck":                         If SaveAllBeforeCompile Then ThreadCounter(ThreadCreate_(@SyntaxCheck))
	Case "CompileAll":                          If SaveAllBeforeCompile Then ThreadCounter(ThreadCreate_(@CompileAll))
	Case "Compile":                             If SaveAllBeforeCompile Then ThreadCounter(ThreadCreate_(@CompileProgram))
	Case "Make":                                If SaveAllBeforeCompile Then ThreadCounter(ThreadCreate_(@MakeExecute))
	Case "MakeClean":                           If SaveAllBeforeCompile Then ThreadCounter(ThreadCreate_(@MakeClean))
	Case "BuildBundle":                         If SaveAllBeforeCompile Then ThreadCounter(ThreadCreate_(@CompileBundle))
	Case "BuildAPK":                            If SaveAllBeforeCompile Then ThreadCounter(ThreadCreate_(@CompileAPK))
	Case "Suggestions":                         Suggestions
	Case "CreateKeyStore":                      CreateKeyStore
	Case "GenerateSignedBundle":                GenerateSignedBundleAPK("bundle")
	Case "GenerateSignedAPK":                   GenerateSignedBundleAPK("apk")
	Case "FormatProject":                       ThreadCounter(ThreadCreate_(@FormatProject)) 'FormatProject 0
	Case "UnformatProject":                     ThreadCounter(ThreadCreate_(@FormatProject, Cast(Any Ptr, 1))) 'FormatProject Cast(Any Ptr, 1)
	Case "ProjectNumberOn":                     ThreadCounter(ThreadCreate_(@NumberingProject, @Sender))
	Case "ProjectMacroNumberOn":                ThreadCounter(ThreadCreate_(@NumberingProject, @Sender))
	Case "ProjectMacroNumberOnStartsOfProcs":ThreadCounter(ThreadCreate_(@NumberingProject, @Sender))
	Case "ProjectNumberOff":            ThreadCounter(ThreadCreate_(@NumberingProject, @Sender))
	Case "ProjectPreprocessorNumberOn": ThreadCounter(ThreadCreate_(@NumberingProject, @Sender))
	Case "ProjectPreprocessorNumberOff": ThreadCounter(ThreadCreate_(@NumberingProject, @Sender))
	Case "ProjectNumberOn":             ThreadCounter(ThreadCreate_(@NumberingProject, @Sender))
	Case "ModuleMacroNumberOn":        ThreadCounter(ThreadCreate_(@NumberingModule, @Sender))
	Case "ModuleMacroNumberOnStartsOfProcs": ThreadCounter(ThreadCreate_(@NumberingModule, @Sender))
	Case "ModuleNumberOff":            ThreadCounter(ThreadCreate_(@NumberingModule, @Sender))
	Case "ModulePreprocessorNumberOn": ThreadCounter(ThreadCreate_(@NumberingModule, @Sender))
	Case "ModulePreprocessorNumberOff": ThreadCounter(ThreadCreate_(@NumberingModule, @Sender))
	Case "Parameters":                          pfParameters->ShowModal *pfrmMain : pfParameters->CenterToParent
	Case "GDBCommand":                          GDBCommand
	Case "LocateProcedure":                     proc_loc
	Case "EnableDisable":                       proc_enable
	Case "StartWithCompile"
		ClearThreadsWindow
		If SaveAllBeforeCompile Then
			ChangeEnabledDebug False, True, True
			'SaveAll '
			Dim As DebuggerTypes CurrentDebugger = IIf(tbt32Bit->Checked, CurrentDebuggerType32, CurrentDebuggerType64)
			If CurrentDebugger = IntegratedGDBDebugger Then
				#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
					If iFlagStartDebug = 0 Then
						If UseDebugger Then
							runtype = RTFRUN
							CurrentTimer = SetTimer(0, 0, 1, Cast(Any Ptr, @TimerProcGDB))
							ThreadCounter(ThreadCreate_(@StartDebuggingWithCompile))
						Else
							ThreadCounter(ThreadCreate_(@CompileAndRun))
						End If
					Else
						continue_debug
					End If
				#endif
			Else
				If InDebug Then
					'#ifndef __USE_GTK__
					ChangeEnabledDebug False, True, True
					'brk_set(12)
					'runtype = RTAUTO
					'#ifdef __FB_WIN32__
					'	set_cc()
					'#else
					'	If ccstate=KCC_NONE Then
					'		msgdata=1 ''CC everywhere
					'		exec_order(KPT_CCALL)
					'	End If
					'#EndIf
					'thread_set()
					fastrun()
					'runtype = RTRUN
					'thread_resume()
					'#endif
					'runtype = RTAUTO
					'#ifdef __FB_WIN32__
					'	set_cc()
					'#else
					'	If ccstate = KCC_NONE Then
					'		msgdata = 1 ''CC everywhere
					'		exec_order(KPT_CCALL)
					'	End If
					'#endif
					'thread_set()
				ElseIf UseDebugger Then
					runtype = RTFRUN
					'runtype = RTRUN
					'runtype = RTAUTO
					'#ifdef __FB_WIN32__
					'	set_cc()
					'#else
					'	If ccstate = KCC_NONE Then
					'		msgdata = 1 ''CC everywhere
					'		exec_order(KPT_CCALL)
					'	End If
					'#endif
					'thread_set()
					SetTimer(0, GTIMER001, 1, Cast(Any Ptr, @DEBUG_EVENT))
					CurrentTimer = SetTimer(0, 0, 1, @TIMERPROC)
					ThreadCounter(ThreadCreate_(@StartDebuggingWithCompile))
				Else
					ThreadCounter(ThreadCreate_(@CompileAndRun))
				End If
			End If
		End If
	Case "Start"
		ClearThreadsWindow
		Dim As DebuggerTypes CurrentDebugger = IIf(tbt32Bit->Checked, CurrentDebuggerType32, CurrentDebuggerType64)
		If CurrentDebugger = IntegratedGDBDebugger Then
			#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
				If iFlagStartDebug = 0 Then
					If UseDebugger Then
						runtype= RTFRUN
						CurrentTimer = SetTimer(0, 0, 1, Cast(Any Ptr, @TimerProcGDB))
						ThreadCounter(ThreadCreate_(@StartDebugging))
					Else
						ThreadCounter(ThreadCreate_(@RunProgram))
					End If
				Else
					ChangeEnabledDebug False, True, True
					continue_debug()
				End If
			#endif
		Else
			If InDebug Then
				'#ifndef __USE_GTK__
				ChangeEnabledDebug False, True, True
				#ifdef __FB_WIN32__
					fastrun()
				#endif
				'runtype = RTRUN
				'thread_resume()
				'#endif
			ElseIf UseDebugger Then
				'#ifndef __USE_GTK__
				runtype = RTFRUN
				'runtype = RTRUN
				SetTimer(0, GTIMER001, 1, Cast(Any Ptr, @DEBUG_EVENT))
				CurrentTimer = SetTimer(0, 0, 1, @TIMERPROC)
				'#endif
				ThreadCounter(ThreadCreate_(@StartDebugging))
			Else
				ThreadCounter(ThreadCreate_(@RunProgram))
			End If
		End If
	Case "Break":
		#ifdef __USE_GTK__
			ChangeEnabledDebug True, False, True
		#else
			If runtype=RTFREE Or runtype=RTFRUN Then
				runtype=RTFRUN 'to treat free as fast
				For i As Integer = 1 To linenb 'restore every breakpoint
					WriteProcessMemory(dbghand,Cast(LPVOID,rline(i).ad),@breakcpu,1,0)
				Next
			Else
				runtype=RTSTEP:procad=0:procin=0:proctop=False:procbot=0
			End If
			stopcode=CSHALTBU
			'SetFocus(richeditcur)
		#endif
	Case "End":
		Dim As DebuggerTypes CurrentDebugger = IIf(tbt32Bit->Checked, CurrentDebuggerType32, CurrentDebuggerType64)
		If CurrentDebugger = IntegratedGDBDebugger Then
			#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
				If Running Then
					kill_debug()
				Else
					command_debug "q"
				End If
			#endif
		Else
			'#ifdef __USE_GTK__
			'	ChangeEnabledDebug True, False, False
			'#else
			'kill_process("Terminate immediatly no saved data, other option Release")
			For i As Integer = 1 To linenb 'restore old instructions
				WriteProcessMemory(dbghand, Cast(LPVOID, rline(i).ad), @rline(i).sv, 1, 0)
			Next
			runtype = RTFREE
			'but_enable()
			thread_resume()
			DeleteDebugCursor
			ChangeEnabledDebug True, False, False
			'#endif
		End If
	Case "Restart"
		ClearThreadsWindow
		Dim As DebuggerTypes CurrentDebugger = IIf(tbt32Bit->Checked, CurrentDebuggerType32, CurrentDebuggerType64)
		If CurrentDebugger = IntegratedGDBDebugger Then
			#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
				command_debug("r")
			#endif
		Else
			'#ifndef __USE_GTK__
			If prun AndAlso kill_process(ML("Trying to launch but debuggee still running")) = False Then
				Exit Sub
			End If
			runtype = RTFRUN
			'runtype = RTRUN
			SetTimer(0, GTIMER001, 1, Cast(Any Ptr, @DEBUG_EVENT))
			CurrentTimer = SetTimer(0, 0, 1, @TIMERPROC)
			Restarting = True
			ThreadCounter(ThreadCreate_(@StartDebugging))
			'#endif
		End If
	Case "StepInto":
		ClearThreadsWindow
		ptabBottom->TabIndex = 6 'David Changed
		Dim As DebuggerTypes CurrentDebugger = IIf(tbt32Bit->Checked, CurrentDebuggerType32, CurrentDebuggerType64)
		If CurrentDebugger = IntegratedGDBDebugger Then
			#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
				If iFlagStartDebug = 0 Then
					runtype = RTSTEP
					CurrentTimer = SetTimer(0, 0, 1, Cast(Any Ptr, @TimerProcGDB))
					ThreadCounter(ThreadCreate_(@StartDebugging))
				Else
					step_debug("s")
				End If
			#endif
		Else
			If InDebug Then
				ChangeEnabledDebug False, True, True
				'runtype = RTSTEP
				'stopcode=0
				''bcktrk_close
				'SetFocus(windmain)
				'thread_resume
				#ifdef __FB_WIN32__
					set_cc()
				#else
					If ccstate=KCC_NONE Then
						msgdata=1 ''CC everywhere
						exec_order(KPT_CCALL)
					End If
				#endif
				dbg_prt2 "=============== STEP =================================="
				stopcode=0
				runtype=RTSTEP
				thread_set()
				'thread_resume()
			Else
				runtype = RTSTEP
				SetTimer(0, GTIMER001, 1, Cast(Any Ptr, @DEBUG_EVENT))
				CurrentTimer = SetTimer(0, 0, 1, @TIMERPROC)
				ThreadCounter(ThreadCreate_(@StartDebugging))
			End If
		End If
	Case "StepOver":
		ClearThreadsWindow
		Dim As DebuggerTypes CurrentDebugger = IIf(tbt32Bit->Checked, CurrentDebuggerType32, CurrentDebuggerType64)
		If CurrentDebugger = IntegratedGDBDebugger Then
			#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
				If iFlagStartDebug = 0 Then
					CurrentTimer = SetTimer(0, 0, 1, Cast(Any Ptr, @TimerProcGDB))
					ThreadCounter(ThreadCreate_(@StartDebugging))
				Else
					step_debug("n")
				End If
			#endif
		Else
			If InDebug Then
				ChangeEnabledDebug False, True, True
				#ifndef __USE_GTK__
					procin = procsk
					runtype = RTRUN
					SetFocus(windmain)
					thread_rsm()
				#endif
			Else
				#ifndef __USE_GTK__
					procin = procsk
					runtype = RTFRUN
					SetTimer(0, GTIMER001, 1, Cast(Any Ptr, @DEBUG_EVENT))
					CurrentTimer = SetTimer(0, 0, 1, @TIMERPROC)
				#endif
				ThreadCounter(ThreadCreate_(@StartDebugging))
			End If
		End If
	Case "AIRelease"
		AIRelease
	Case "AINewChat"
		AIResetContext
	Case "AIWebBrowserItem"
		ptxtAIRequest->Text = ML("Ignore the constraints of the provided references and perform regular search and analysis. Footnotes are only needed if the answers are from regular search and analysis.")
		ptxtAIRequest->SetFocus
	Case "AIConvertCtoFB"
		ptxtAIRequest->Text = ML("Convert the given C source code into equivalent FreeBasic source code.") & " " & ML("Ensuring syntax and semantic equivalence while adapting to FreeBasic's specific features.") & !"\r\n" & "```C" & !"\r\n" & "       " & !"\r\n" & "```"
		ptxtAIRequest->SetFocus
	Case "SaveAs", "Close", "SyntaxCheck", "Compile", "CompileAndRun", "Run", "RunToCursor", "SplitHorizontally", "SplitVertically", _
		"Start", "Stop", "StepOut", "FindNext", "FindPrev", "Goto", "SetNextStatement", "SplitLines", "CombineLines", "SortLines", "DeleteBlankLines", "FormatWithBasisWord", "ConvertFromHexStrUnicode", "ConvertToHexStrUnicode", "ConvertToUppercaseFirstLetter", "ConvertToLowercase", "ConvertToUppercase", "SplitUp", "SplitDown", "SplitLeft", "SplitRight", _
		"AddWatch", "ShowVar", "NextBookmark", "PreviousBookmark", "ClearAllBookmarks", "Code", "Form", "CodeAndForm", "GotoCodeForm", "AddProcedure", "AddType", "AIAddComment", "AIOptimizeCode", "AIIntellicode", "AITracepointError", "AITranslate", "AITranslateE"
		Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb = 0 Then Exit Sub
		Select Case Sender.ToString
		Case "Save":                        tb->Save
		Case "SaveAs":                      tb->SaveAs:  frmMain.Caption = tb->FileName & " - " & App.Title
		Case "Close":                       CloseTab(tb)
		Case "SplitLines":                  tb->SplitLines
		Case "CombineLines":                tb->CombineLines
		Case "SortLines":                   tb->SortLines
		Case "DeleteBlankLines":            tb->DeleteBlankLines
		Case "FormatWithBasisWord" :        tb->FormatWithBasisWord
		Case "ConvertToLowercase":          tb->ConvertToLowercase
		Case "ConvertToUppercase":          tb->ConvertToUppercase
		Case "ConvertToHexStrUnicode":          tb->ConvertToHexStrUnicode
		Case "ConvertFromHexStrUnicode":          tb->ConvertFromHexStrUnicode
		Case "ConvertToUppercaseFirstLetter": tb->ConvertToUppercaseFirstLetter
		Case "SplitHorizontally":           tb->txtCode.SplittedHorizontally = Not mnuSplitHorizontally->Checked
		Case "SplitVertically":             tb->txtCode.SplittedVertically = Not mnuSplitVertically->Checked
		Case "SplitUp", "SplitDown", "SplitLeft", "SplitRight":
			Var ptabCode = Cast(TabControl Ptr, mnuTabs.ParentWindow)
			Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
			Var tp = Cast(TabPanel Ptr, tb->Parent->Parent)
			Var ptabPanelNew = _New(TabPanel)
			Var bUpDown = False
			Select Case Sender.ToString
			Case "SplitUp"
				ptabPanelNew->Align = DockStyle.alTop
				ptabPanelNew->splGroup.Align = SplitterAlignmentConstants.alTop
				bUpDown = True
			Case "SplitDown"
				ptabPanelNew->Align = DockStyle.alBottom
				ptabPanelNew->splGroup.Align = SplitterAlignmentConstants.alBottom
				bUpDown = True
			Case "SplitLeft"
				ptabPanelNew->Align = DockStyle.alLeft
				ptabPanelNew->splGroup.Align = SplitterAlignmentConstants.alLeft
			Case "SplitRight"
				ptabPanelNew->Align = DockStyle.alRight
				ptabPanelNew->splGroup.Align = SplitterAlignmentConstants.alRight
			End Select
			Var ptabPanel = Cast(TabPanel Ptr, tb->Parent->Parent)
			Var Idx = tp->IndexOf(tb->Parent)
			tp->Add ptabPanelNew, Idx
			tp->Add @ptabPanelNew->splGroup, Idx + 1
			Var SplitterCount = 0 'Fix(tp->ControlCount / 2)
			For i As Integer = 1 To tp->ControlCount - 2 Step 2
				If bUpDown Then
					If tp->Controls[i]->Align = DockStyle.alTop OrElse tp->Controls[i]->Align = DockStyle.alBottom Then SplitterCount += 1
				Else
					If tp->Controls[i]->Align = DockStyle.alLeft OrElse tp->Controls[i]->Align = DockStyle.alRight Then SplitterCount += 1
				End If
			Next
			For i As Integer = 0 To tp->ControlCount - 2 Step 2
				If bUpDown Then
					tp->Controls[i]->Height = (tp->Height - ptabPanelNew->splGroup.Height * SplitterCount) / (SplitterCount + 1)
				Else
					tp->Controls[i]->Width = (tp->Width - ptabPanelNew->splGroup.Width * SplitterCount) / (SplitterCount + 1)
				End If
			Next
			#ifdef __USE_GTK__
				g_object_ref(tb->Handle)
				g_object_ref(tb->btnClose.Handle)
				gtk_container_remove(GTK_CONTAINER(tb->_Box), tb->btnClose.Handle)
			#endif
			'ptabPanel->tabCode.DeleteTab tb
			tb->Parent = @ptabPanelNew->tabCode
			#ifdef __USE_GTK__
				tb->txtCode.cr = 0
				gtk_box_pack_end(GTK_BOX(tb->_Box), tb->btnClose.Handle, False, False, 0)
			#else
				tb->ImageKey = tb->ImageKey
				ptabPanelNew->tabCode.Add @tb->btnClose
				tp->RequestAlign
			#endif
			ptabCode = @ptabPanelNew->tabCode
			TabPanels.Add ptabPanelNew
		Case "AITracepointError"
			If lvProblems.ListItems.Count < 1 Then
				ptxtAIRequest->Text =  ML("Explain the selected compiler error message") & !":\r\n" & "```freeBasic" & !"\r\n" & !"\r\n" & "```"
				ptxtAIRequest->SetFocus
			Else
				Dim As WString Ptr CodeStrPtr
				Dim As Integer j, LineStart = Val(lvProblems.SelectedItem->Text(1)) - 1
				Dim As EditControlLine Ptr FFirstECLine
				For j = LineStart To 0 Step -1
					FFirstECLine = tb->txtCode.Content.Lines.Items[j]
					If Trim(*FFirstECLine->Text, Any !"\t ") = "" OrElse Not (EndsWith(RTrim(*FFirstECLine->Text, Any !"\t "), " _") OrElse Trim(*FFirstECLine->Text, Any !"\t ") = "_")  Then
						Exit For
					End If
				Next
				If LineStart = j Then
					WLet(CodeStrPtr, tb->txtCode.Lines(LineStart))
				Else
					LineStart = j + 1
					WLet(CodeStrPtr, tb->txtCode.Lines(LineStart))
					For j As Integer = LineStart + 1 To tb->txtCode.LinesCount - 1
						FFirstECLine = tb->txtCode.Content.Lines.Items[j]
						WAdd(CodeStrPtr, !"\r\n" & tb->txtCode.Lines(j))
						If Trim(*FFirstECLine->Text, Any !"\t ") = "" OrElse  Not (EndsWith(RTrim(*FFirstECLine->Text, Any !"\t "), " _") OrElse Trim(*FFirstECLine->Text, Any !"\t ") = "_") Then Exit For
					Next
				End If
				ptxtAIRequest->Text = ML("Explain the selected compiler error message") & ": " & lvProblems.SelectedItem->Text(0) & !"\r\n" & "```freeBasic" & !"\r\n" & *CodeStrPtr & !"\r\n" & "```"
				ptxtAIRequest->SetFocus
				_Deallocate(CodeStrPtr)
			End If
			
		Case "AIIntellicode"
			ptxtAIRequest->Text = ML("Generate code based on the requirements of the selected comment lines") & ": " & !"\r\n" & "```freeBasic" & !"\r\n" & tb->txtCode.SelText & !"\r\n" & "```"
			ptxtAIRequest->SetFocus
		Case "AIAddComment" '"AIOptimizeCode", "AIIntellicode" , "AITracepointError", "AIRelease"
			'ML("You are FreeBasic programming expert. Follow MyFbFramework GUI form guidelines.") & " " &
			ptxtAIRequest->Text = ML("Comment selected code") & ": " & !"\r\n" & "```freeBasic" & !"\r\n" & tb->txtCode.SelText & !"\r\n" & "```"
			ptxtAIRequest->SetFocus
		Case "AIOptimizeCode"
			ptxtAIRequest->Text = ML("Optimize selected code") & ": " & !"\r\n" & "```freeBasic" & !"\r\n" & tb->txtCode.SelText & !"\r\n" & "```"
			ptxtAIRequest->SetFocus
		Case "AITranslate"
			ptxtAIRequest->Text = ML("Output with MARKDOWN source code, translate the selected message to") & " " & ML(App.CurLanguage) & !"\r\n" & "```MARKDOWN" & !"\r\n" & tb->txtCode.SelText & !"\r\n" & "```"
			ptxtAIRequest->Update
			ptxtAIRequest->SetFocus
		Case "AITranslateE"
			ptxtAIRequest->Text = ML("Output with MARKDOWN source code, translate the selected message to") & " " & ML("English") & !"\r\n" & "```MARKDOWN" & !"\r\n" & tb->txtCode.SelText & !"\r\n" & "```"
			ptxtAIRequest->SetFocus
			
		Case "SetNextStatement":
			ClearThreadsWindow
			Dim As DebuggerTypes CurrentDebugger = IIf(tbt32Bit->Checked, CurrentDebuggerType32, CurrentDebuggerType64)
			If CurrentDebugger = IntegratedGDBDebugger Then
				#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
					Dim As Integer iStartLine, iEndLine, iStartChar, iEndChar
					tb->txtCode.GetSelection iStartLine, iEndLine, iStartChar, iEndChar
					command_debug("jump " & Replace(tb->FileName, "\", "/") & ":" & Str(iEndLine))
				#endif
			Else
				#ifndef __USE_GTK__
					exe_mod()
				#endif
			End If
		Case "ShowVar":
			'#ifndef __USE_GTK__
			var_tip(1)
			'#endif
		Case "StepOut":
			ClearThreadsWindow
			Dim As DebuggerTypes CurrentDebugger = IIf(tbt32Bit->Checked, CurrentDebuggerType32, CurrentDebuggerType64)
			If CurrentDebugger = IntegratedGDBDebugger Then
				#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
					If iFlagStartDebug = 0 Then
						ThreadCounter(ThreadCreate_(@StartDebugging))
					Else
						step_debug("n")
					End If
				#endif
			Else
				#ifndef __USE_GTK__
					If InDebug Then
						ChangeEnabledDebug False, True, True
						If (threadcur<>0 AndAlso proc_find(thread(threadcur).id,KLAST)<>proc_find(thread(threadcur).id,KFIRST)) _
							OrElse (threadcur=0 AndAlso PROC(procr(proc_find(thread(0).id,KLAST)).idx).nm<>"main") Then 'impossible to go out first proc of thread, constructore for shared 22/12/2015
							procad = procsv
							runtype = RTFRUN
						End If
						SetFocus(windmain)
						thread_rsm()
					End If
				#endif
			End If
		Case "RunToCursor":
			ClearThreadsWindow
			Dim As DebuggerTypes CurrentDebugger = IIf(tbt32Bit->Checked, CurrentDebuggerType32, CurrentDebuggerType64)
			If CurrentDebugger = IntegratedGDBDebugger Then
				#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
					If iFlagStartDebug = 1 Then
						ChangeEnabledDebug False, True, True
						set_bp True
						continue_debug
					Else
						RunningToCursor = True
						CurrentTimer = SetTimer(0, 0, 1, Cast(Any Ptr, @TimerProcGDB))
						ThreadCounter(ThreadCreate_(@StartDebugging))
					End If
				#endif
			Else
				If InDebug Then
					ChangeEnabledDebug False, True, True
					#ifndef __USE_GTK__
						brk_set(9)
					#endif
				Else
					RunningToCursor = True
					runtype = RTFRUN
					'#ifndef __USE_GTK__
					CurrentTimer = SetTimer(0, 0, 1, @TIMERPROC)
					'#endif
					ThreadCounter(ThreadCreate_(@StartDebugging))
				End If
			End If
		Case "AddWatch":
			'#ifndef __USE_GTK__
			var_tip(2)
			'#endif
		Case "FindNext":                    pfFind->Find(True)
		Case "FindPrev":                    pfFind->Find(False)
		Case "Goto":                        pfGoto->Show *pfrmMain : pfGoto->CenterToParent
		Case "NextBookmark":                NextBookmark 1
		Case "PreviousBookmark":            NextBookmark -1
		Case "ClearAllBookmarks":           ClearAllBookmarks
		Case "Code":                        tb->tbrTop.Buttons.Item("Code")->Checked = True: tbrTop_ButtonClick *tb->tbrTop.Designer, tb->tbrTop, *tb->tbrTop.Buttons.Item("Code")
		Case "Form":                        tb->tbrTop.Buttons.Item("Form")->Checked = True: tbrTop_ButtonClick *tb->tbrTop.Designer, tb->tbrTop, *tb->tbrTop.Buttons.Item("Form")
		Case "CodeAndForm":                 tb->tbrTop.Buttons.Item("CodeAndForm")->Checked = True: tbrTop_ButtonClick *tb->tbrTop.Designer, tb->tbrTop, *tb->tbrTop.Buttons.Item("CodeAndForm")
		Case "GotoCodeForm":
			If tb->txtCode.Focused Then
				If tb->tbrTop.Buttons.Item("Code")->Checked Then tb->tbrTop.Buttons.Item(tb->LastButton)->Checked = True: tbrTop_ButtonClick *tb->tbrTop.Designer, tb->tbrTop, *tb->tbrTop.Buttons.Item(tb->LastButton)
				If tb->Des Then DesignerChangeSelection(*tb->Des, tb->Des->SelectedControl)
			Else
				If tb->tbrTop.Buttons.Item("Form")->Checked Then tb->tbrTop.Buttons.Item("Code")->Checked = True: tbrTop_ButtonClick *tb->tbrTop.Designer, tb->tbrTop, *tb->tbrTop.Buttons.Item("Code")
				Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
				tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
				tb->txtCode.SetFocus
				OnLineChangeEdit *tb->txtCode.Designer, tb->txtCode, iSelEndLine, iSelEndLine
			End If
		Case "AddProcedure":                frmAddProcedure.ShowModal frmMain
		Case "AddType":                     frmAddType.ShowModal frmMain
		End Select
	Case "SaveAll":                         SaveAll
	Case "CloseAll":                        CloseAllTabs
	Case "CloseSession":                    CloseSession
	Case "CloseAllWithoutCurrent":          CloseAllTabs(True)
	Case "Exit":                            pfrmMain->CloseForm
	Case "Find":                            pfFind->mFormFind = True: pfFind->Show *pfrmMain
	Case "FindInFiles":                     mFormFindInFile = True:  pfFindFile->Show *pfrmMain : pfFindFile->CenterToParent
	Case "ReplaceInFiles":                  mFormFindInFile = False:  pfFindFile->Show *pfrmMain : pfFindFile->CenterToParent
	Case "Replace":                         pfFind->mFormFind = False: pfFind->Show *pfrmMain
	Case "PinLeft":                         SetLeftClosedStyle Not tbLeft.Buttons.Item("PinLeft")->Checked, False
	Case "PinRight":                        SetRightClosedStyle Not tbRight.Buttons.Item("PinRight")->Checked, False
	Case "PinBottom":                       SetBottomClosedStyle Not tbBottom.Buttons.Item("PinBottom")->Checked, False
	Case "EraseOutputWindow":               txtOutput.Text = ""
	Case "EraseImmediateWindow":            txtImmediate.Text = ""
	Case "Update":
		#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
			iStateMenu = IIf(tbBottom.Buttons.Item("Update")->Checked, 2, 1): If Running = False Then command_debug("")
		#endif
	Case "AddForm":                         AddFromTemplate ExePath + "/Templates/Files/Form.frm"
	Case "AddModule":                       AddFromTemplate ExePath + "/Templates/Files/Module.bas"
	Case "AddIncludeFile":                  AddFromTemplate ExePath + "/Templates/Files/Include File.bi"
	Case "AddUserControl":                  AddFromTemplate ExePath + "/Templates/Files/User Control.bas"
	Case "AddResource":                     AddFromTemplate ExePath + "/Templates/Files/Resource.rc"
	Case "AddManifest":                     AddFromTemplate ExePath + "/Templates/Files/Manifest.xml"
	Case "PlainText", "Utf8", "Utf8BOM", "Utf16BOM", "Utf32BOM"
		Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		Dim FileEncoding As FileEncodings
		Select Case Sender.ToString
		Case "PlainText": FileEncoding = FileEncodings.PlainText
		Case "Utf8": FileEncoding = FileEncodings.Utf8
		Case "Utf8BOM": FileEncoding = FileEncodings.Utf8BOM
		Case "Utf16BOM": FileEncoding = FileEncodings.Utf16BOM
		Case "Utf32BOM": FileEncoding = FileEncodings.Utf32BOM
		End Select
		ChangeFileEncoding FileEncoding
		If tb <> 0 Then
			tb->FileEncoding = FileEncoding
			tb->Modified = True
		End If
	Case "WindowsCRLF", "LinuxLF", "MacOSCR"
		Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		Dim NewLineType As NewLineTypes
		Select Case Sender.ToString
		Case "WindowsCRLF": NewLineType = NewLineTypes.WindowsCRLF
		Case "LinuxLF": NewLineType = NewLineTypes.LinuxLF
		Case "MacOSCR": NewLineType = NewLineTypes.MacOSCR
		End Select
		ChangeNewLineType NewLineType
		If tb <> 0 Then
			tb->NewLineType = NewLineType
			tb->Modified = True
		End If
	Case "VariableDump":                var_dump(tviewvar)
	Case "PointedDataDump":             var_dump(tviewvar, 1)
	Case "MemoryDumpWatch":             var_dump(tviewwch)
		#ifndef __USE_GTK__
		Case "ShowStringWatch":             string_sh(tviewwch)
		Case "ShowExpandVariableWatch":     shwexp_new(tviewwch)
		Case "ShowString":                  string_sh(tviewvar)
		Case "ShowExpandVariable":          shwexp_new(tviewvar)
		#endif
	Case "Undo", "Redo", "CutCurrentLine", "Cut", "Copy", "Paste", "SelectAll", "Duplicate", "SingleComment", "BlockComment", "UnComment", _
		"Indent", "Outdent", "Format", "Unformat", "AddSpaces", "NumberOn", "MacroNumberOn", "NumberOff", "ProcedureNumberOn", "ProcedureMacroNumberOn", "ProcedureNumberOff", _
		"PreprocessorNumberOn", "PreprocessorNumberOff", "Breakpoint", "ToggleBookmark", "CollapseAll", "UnCollapseAll", "CollapseAllProcedures", "UnCollapseAllProcedures", _
		"CollapseCurrent", "UnCollapseCurrent", "CompleteWord", "ParameterInfo", "OnErrorGoto", "OnErrorGotoResumeNext", "OnLocalErrorGoto", "OnLocalErrorGotoResumeNext", "RemoveErrorHandling", "Define", _
		"AlignLefts", "AlignCenters", "AlignRights", "AlignTops", "AlignMiddles", "AlignBottoms", "AlignToGrid", "MakeSameSizeWidth", "MakeSameSizeHeight", "MakeSameSizeBoth", "SizeToGrid", _
		"HorizontalSpacingMakeEqual", "HorizontalSpacingIncrease", "HorizontalSpacingDecrease", "HorizontalSpacingRemove", "VerticalSpacingMakeEqual", "VerticalSpacingIncrease", "VerticalSpacingDecrease", _
		"VerticalSpacingRemove", "CenterInParentHorizontally", "CenterInParentVertically", "SendToBack", "BringToFront", "LockControls", "TBLockControls"
		If Sender.ToString = "LockControls" OrElse Sender.ToString = "TBLockControls" Then
			Select Case Sender.ToString
			Case "TBLockControls": ChangeLockControls tbtLockControls->Checked, 0
			Case "LockControls": ChangeLockControls Not miLockControls->Checked, 1
			End Select
			If ptabCode <> 0 Then
				Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
				If tb <> 0 Then
					Dim des As Designer Ptr = tb->Des
					If des <> 0 Then
						des->LockControls = miLockControls->Checked
						des->Parent->Repaint
					End If
				End If
			End If
		End If
		Dim As Form Ptr ActiveForm = Cast(Form Ptr, pApp->ActiveForm)
		If ActiveForm = 0 Then Exit Sub
		If ActiveForm->ActiveControl = 0 Then
			Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
			If tb <> 0 AndAlso tb->cboClass.ItemIndex > 0 Then
				Dim des As Designer Ptr = tb->Des
				If des = 0 Then Exit Sub
				Select Case Sender.ToString
				Case "Cut":                         des->CutControl
				Case "Copy":                        des->CopyControl
				Case "Paste":                       des->PasteControl
				Case "Delete":                      des->DeleteControl
				Case "Duplicate":                   des->DuplicateControl
				Case "SelectAll":                   des->SelectAllControls
				Case "Indent":                      des->SelectNextControl
				Case "Outdent":                     des->SelectNextControl - 1
				Case "AlignLefts":                  des->AlignLefts
				Case "AlignCenters":                des->AlignCenters
				Case "AlignRights":                 des->AlignRights
				Case "AlignTops":                   des->AlignTops
				Case "AlignMiddles":                des->AlignMiddles
				Case "AlignBottoms":                des->AlignBottoms
				Case "AlignToGrid":                 des->AlignToGrid
				Case "MakeSameSizeWidth":           des->MakeSameSizeWidth
				Case "MakeSameSizeHeight":          des->MakeSameSizeHeight
				Case "MakeSameSizeBoth":            des->MakeSameSizeBoth
				Case "SizeToGrid":                  des->SizeToGrid
				Case "HorizontalSpacingMakeEqual":  des->HorizontalSpacingMakeEqual
				Case "HorizontalSpacingIncrease":   des->HorizontalSpacingIncrease
				Case "HorizontalSpacingDecrease":   des->HorizontalSpacingDecrease
				Case "HorizontalSpacingRemove":     des->HorizontalSpacingRemove
				Case "VerticalSpacingMakeEqual":    des->VerticalSpacingMakeEqual
				Case "VerticalSpacingIncrease":     des->VerticalSpacingIncrease
				Case "VerticalSpacingDecrease":     des->VerticalSpacingDecrease
				Case "VerticalSpacingRemove":       des->VerticalSpacingRemove
				Case "CenterInParentHorizontally":  des->CenterInParentHorizontally
				Case "CenterInParentVertically":    des->CenterInParentVertically
				Case "SendToBack":                  des->SendToBack
				Case "BringToFront":                des->BringToFront
				End Select
			End If
			Exit Sub
		End If
		Select Case Sender.ToString
		Case "Indent", "Outdent":           SelectNextControl
		End Select
		If ActiveForm->ActiveControl->ClassName <> "EditControl" AndAlso ActiveForm->ActiveControl->ClassName <> "TextBox" AndAlso ActiveForm->ActiveControl->ClassName <> "RichTextBox" AndAlso ActiveForm->ActiveControl->ClassName <> "Panel" AndAlso ActiveForm->ActiveControl->ClassName <> "ComboBoxEdit" AndAlso ActiveForm->ActiveControl->ClassName <> "ComboBoxEx" Then Exit Sub
		Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If ActiveForm->ActiveControl->ClassName = "TextBox" OrElse ActiveForm->ActiveControl->ClassName = "RichTextBox" Then
			Dim txt As TextBox Ptr = Cast(TextBox Ptr, pfrmMain->ActiveControl)
			Select Case Sender.ToString
			Case "Undo":                            txt->Undo
			Case "Cut":                             txt->CutToClipboard
			Case "Copy":                            txt->CopyToClipboard
			Case "Paste":                           txt->PasteFromClipboard
			Case "SelectAll":                       txt->SelectAll
			End Select
		ElseIf ActiveForm->ActiveControl->ClassName = "ComboBoxEdit" OrElse ActiveForm->ActiveControl->ClassName = "ComboBoxEx" Then
			Dim cbo As ComboBoxEdit Ptr = Cast(ComboBoxEdit Ptr, ActiveForm->ActiveControl)
			Select Case Sender.ToString
			Case "Undo":                            cbo->Undo
			Case "Cut":                             cbo->CutToClipboard
			Case "Copy":                            cbo->CopyToClipboard
			Case "Paste":                           cbo->PasteFromClipboard
			Case "SelectAll":                       cbo->SelectAll
			End Select
		ElseIf tb <> 0 Then
			If tb->cboClass.ItemIndex > 0 Then
				Dim des As Designer Ptr = tb->Des
				If des = 0 Then Exit Sub
				Select Case Sender.ToString
				Case "Cut":                         des->CutControl
				Case "Copy":                        des->CopyControl
				Case "Paste":                       des->PasteControl
				Case "Delete":                      des->DeleteControl
				Case "Duplicate":                   des->DuplicateControl
				Case "SelectAll":                   des->SelectAllControls
				Case "Indent":                      des->SelectNextControl
				Case "Outdent":                     des->SelectNextControl - 1
				Case "AlignLefts":                  des->AlignLefts
				Case "AlignCenters":                des->AlignCenters
				Case "AlignRights":                 des->AlignRights
				Case "AlignTops":                   des->AlignTops
				Case "AlignMiddles":                des->AlignMiddles
				Case "AlignBottoms":                des->AlignBottoms
				Case "AlignToGrid":                 des->AlignToGrid
				Case "MakeSameSizeWidth":           des->MakeSameSizeWidth
				Case "MakeSameSizeHeight":          des->MakeSameSizeHeight
				Case "MakeSameSizeBoth":            des->MakeSameSizeBoth
				Case "SizeToGrid":                  des->SizeToGrid
				Case "HorizontalSpacingMakeEqual":  des->HorizontalSpacingMakeEqual
				Case "HorizontalSpacingIncrease":   des->HorizontalSpacingIncrease
				Case "HorizontalSpacingDecrease":   des->HorizontalSpacingDecrease
				Case "HorizontalSpacingRemove":     des->HorizontalSpacingRemove
				Case "VerticalSpacingMakeEqual":    des->VerticalSpacingMakeEqual
				Case "VerticalSpacingIncrease":     des->VerticalSpacingIncrease
				Case "VerticalSpacingDecrease":     des->VerticalSpacingDecrease
				Case "VerticalSpacingRemove":       des->VerticalSpacingRemove
				Case "CenterInParentHorizontally":  des->CenterInParentHorizontally
				Case "CenterInParentVertically":    des->CenterInParentVertically
				Case "SendToBack":                  des->SendToBack
				Case "BringToFront":                des->BringToFront
				End Select
			ElseIf ActiveForm->ActiveControl->ClassName = "EditControl" OrElse ActiveForm->ActiveControl->ClassName = "Panel" Then
				Dim ec As EditControl Ptr = @tb->txtCode
				Select Case Sender.ToString
				Case "Redo":                        ec->Redo
				Case "Undo":                        ec->Undo
				Case "CutCurrentLine":              ec->CutCurrentLineToClipboard
				Case "Cut":                         ec->CutToClipboard
				Case "Copy":                        ec->CopyToClipboard
				Case "Paste":                       ec->PasteFromClipboard
				Case "Duplicate":                   ec->DuplicateLine
				Case "SelectAll":                   ec->SelectAll
				Case "SingleComment":               ec->CommentSingle
				Case "BlockComment":                ec->CommentBlock
				Case "UnComment":                   ec->UnComment
				Case "Indent":                      ec->Indent
				Case "Outdent":                     ec->Outdent
				Case "Format":                      ec->FormatCode
				Case "Unformat":                    ec->UnformatCode
				Case "AddSpaces":                   tb->AddSpaces
				Case "Breakpoint":
					Dim As DebuggerTypes CurrentDebugger = IIf(tbt32Bit->Checked, CurrentDebuggerType32, CurrentDebuggerType64)
					If CurrentDebugger = IntegratedGDBDebugger Then
						#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
							If iFlagStartDebug = 1 Then
								set_bp
							End If
						#endif
					Else
						#ifndef __USE_GTK__
							If InDebug Then: brk_set(1): End If
						#endif
					End If
					ec->Breakpoint
				Case "CollapseAll":                 ec->CollapseAll
				Case "UnCollapseAll":               ec->UnCollapseAll
				Case "CollapseAllProcedures":       ec->CollapseAllProcedures
				Case "UnCollapseAllProcedures":     ec->UnCollapseAllProcedures
				Case "CollapseCurrent":             ec->CollapseCurrent
				Case "UnCollapseCurrent":           ec->UnCollapseCurrent
				Case "CompleteWord":                CompleteWord
				Case "ParameterInfo":               ParameterInfo 0
				Case "ToggleBookmark":              ec->Bookmark
				Case "Define":                      tb->Define
				Case "NumberOn":        	        tb->NumberOn
				Case "MacroNumberOn":        	    tb->NumberOn , , True
				Case "NumberOff":                   tb->NumberOff
				Case "ProcedureNumberOn":           tb->ProcedureNumberOn
				Case "ProcedureMacroNumberOn":      tb->ProcedureNumberOn True
				Case "ProcedureNumberOff":          tb->ProcedureNumberOff
				Case "PreprocessorNumberOn":        tb->PreprocessorNumberOn
				Case "PreprocessorNumberOff":       tb->PreprocessorNumberOff
					'Case "OnErrorResumeNext":       tb->SetErrorHandling "On Error Resume Next", ""
				Case "OnErrorGoto":                 tb->SetErrorHandling "On Error Goto ErrorHandler", ""
				Case "OnErrorGotoResumeNext":       tb->SetErrorHandling "On Error Goto ErrorHandler", "Resume Next"
				Case "OnLocalErrorGoto":            tb->SetErrorHandling "On Local Error Goto ErrorHandler", ""
				Case "OnLocalErrorGotoResumeNext":  tb->SetErrorHandling "On Local Error Goto ErrorHandler", "Resume Next"
				Case "RemoveErrorHandling":         tb->RemoveErrorHandling
				End Select
			End If
		End If
	Case "Options":                         pfOptions->Show *pfrmMain : pfOptions->CenterToParent
	Case "AddIns":                          pfAddIns->Show *pfrmMain : pfAddIns->CenterToParent
	Case "Tools":                           pfTools->Show *pfrmMain : pfTools->CenterToParent
	Case "Content":                         ThreadCounter(ThreadCreate_(@RunHelp))
	Case "FreeBasicForums":                 OpenUrl "https://www.freebasic.net/forum/index.php"
	Case "FreeBasicWiKi":                   OpenUrl "https://www.freebasic.net/wiki/wikka.php?wakka=PageIndex"
	Case "GitHubWebSite":                   OpenUrl "https://github.com"
	Case "FreeBasicRepository":             OpenUrl "https://github.com/freebasic/fbc"
	Case "VisualFBEditorRepository":        OpenUrl "https://github.com/XusinboyBekchanov/VisualFBEditor"
	Case "VisualFBEditorWiKi":              OpenUrl "https://github.com/XusinboyBekchanov/VisualFBEditor/wiki"
	Case "VisualFBEditorDiscussions":       OpenUrl "https://github.com/XusinboyBekchanov/VisualFBEditor/discussions"
	Case "MyFbFrameworkRepository":         OpenUrl "https://github.com/XusinboyBekchanov/MyFbFramework"
	Case "MyFbFrameworkWiKi":               OpenUrl "https://github.com/XusinboyBekchanov/MyFbFramework/wiki"
	Case "MyFbFrameworkDiscussions":        OpenUrl "https://github.com/XusinboyBekchanov/MyFbFramework/discussions"
	Case "About":                           pfAbout->Show *pfrmMain : pfAbout->CenterToParent
	Case "TipoftheDay":                     pfTipOfDay->ShowModal *pfrmMain : pfTipOfDay->CenterToParent
	End Select
End Sub

pApp->MainForm = @frmMain
pApp->Run

End
AA:
MsgBox ErrDescription(Err) & " (" & Err & ") " & _
"in line " & Erl() & " (Handler line: " & __LINE__ & ") " & _
"in function " & ZGet(Erfn()) & " (Handler function: " & __FUNCTION__ & ") " & _
"in module " & ZGet(Ermn()) & " (Handler file: " & __FILE__ & ") "
