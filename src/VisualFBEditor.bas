'#########################################################
'#  VisualFBEditor.bas                                   #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

'#define __USE_GTK__
#ifndef __USE_MAKE__
	#define __USE_GTK3__
	#define _NOT_AUTORUN_FORMS_
#endif

Const VER_MAJOR  = "1"
Const VER_MINOR  = "2"
Const VER_PATCH  = "8"
Const VERSION    = VER_MAJOR + "." + VER_MINOR + "." + VER_PATCH
Const BUILD_DATE = __DATE__
Const SIGN       = "VisualFBEditor " + VERSION

On Error Goto AA

'#define GetMN

#define MEMCHECK 0

#include once "Main.bi"
#include once "Debug.bi"
#include once "Designer.bi"
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

Sub StartDebuggingWithCompile(Param As Any Ptr)
	ChangeEnabledDebug False, True, True
	If Compile("Run") Then RunWithDebug(0) Else ChangeEnabledDebug True, False, False
End Sub

Sub StartDebugging(Param As Any Ptr)
	ChangeEnabledDebug False, True, True
	RunWithDebug(0)
End Sub

Sub RunCmd(Param As Any Ptr)
	Dim As UString MainFile = GetMainFile()
	Dim As UString cmd
	#ifdef __USE_GTK__
		cmd = WGet(TerminalPath) & " --working-directory=""" & GetFolderName(MainFile) & """"
		Shell(cmd)
	#else
		cmd = Environ("COMSPEC") & " /K cd /D """ & GetFolderName(MainFile) & """"
		Dim As Integer pClass
		Dim As WString Ptr Workdir, CmdL
		Dim SInfo As STARTUPINFO
		Dim PInfo As PROCESS_INFORMATION
		WLet(CmdL, cmd)
		WLet(Workdir, GetFolderName(MainFile))
		SInfo.cb = Len(SInfo)
		SInfo.dwFlags = STARTF_USESHOWWINDOW
		SInfo.wShowWindow = SW_NORMAL
		pClass = CREATE_UNICODE_ENVIRONMENT Or CREATE_NEW_CONSOLE
		If CreateProcessW(Null, CmdL, ByVal Null, ByVal Null, False, pClass, Null, Workdir, @SInfo, @PInfo) Then
			CloseHandle(pinfo.hProcess)
			CloseHandle(pinfo.hThread)
		End If
		If WorkDir Then Deallocate_( WorkDir)
		If CmdL Then Deallocate_( CmdL)
	#endif
End Sub

Sub FindInFiles
	ThreadCreate(@FindSub)
End Sub
Sub ReplaceInFiles
	ThreadCreate(@ReplaceSub)
End Sub

Sub mClickMRU(Sender As My.Sys.Object)
	If Sender.ToString = "ClearFiles" Then
		miRecentFiles->Clear
		miRecentFiles->Enabled = False
		MRUFiles.Clear
	ElseIf Sender.ToString = "ClearProjects" Then
		miRecentProjects->Clear
		miRecentProjects->Enabled = False
		MRUProjects.Clear
	ElseIf Sender.ToString = "ClearFolders" Then
		miRecentFolders->Clear
		miRecentFolders->Enabled = False
		MRUFolders.Clear
	ElseIf Sender.ToString = "ClearSessions" Then
		miRecentSessions->Clear
		miRecentSessions->Enabled = False
		MRUSessions.Clear
	Else
		OpenFiles Sender.ToString
	End If
End Sub
Sub mClickHelp(ByRef Sender As My.Sys.Object)
	HelpOption.CurrentPath = Cast(MenuItem Ptr, @Sender)->ImageKey
	HelpOption.CurrentWord = ""
	ThreadCreate(@RunHelp, @HelpOption)
End Sub

Sub mClickTool(ByRef Sender As My.Sys.Object)
	Dim As MenuItem Ptr mi = Cast(MenuItem Ptr, @Sender)
	If mi = 0 Then Exit Sub
	Dim As UserToolType Ptr tt = mi->Tag
	If tt <> 0 Then tt->Execute
End Sub

Sub mClick(Sender As My.Sys.Object)
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
	Case "CommandPrompt":                       ThreadCreate(@RunCmd)
	Case "AddFromTemplates":                    AddFromTemplates
	Case "AddFilesToProject":                   AddFilesToProject
	Case "RemoveFileFromProject":               RemoveFileFromProject
	Case "OpenProjectFolder":                   OpenProjectFolder
	Case "ProjectProperties":                   pfProjectProperties->RefreshProperties: pfProjectProperties->ShowModal *pfrmMain
	Case "SetAsMain":                           SetAsMain
	Case "ProjectExplorer":                     ptabLeft->Tab(0)->SelectTab
	Case "PropertiesWindow":                    ptabRight->Tab(0)->SelectTab
	Case "EventsWindow":                        ptabRight->Tab(1)->SelectTab
	Case "ToolBox":                             ptabLeft->Tab(1)->SelectTab
	Case "OutputWindow":                        ptabBottom->Tab(0)->SelectTab
	Case "ErrorsWindow":                        ptabBottom->Tab(1)->SelectTab
	Case "FindWindow":                          ptabBottom->Tab(2)->SelectTab
	Case "ToDoWindow":                          ptabBottom->Tab(3)->SelectTab
	Case "ChangeLogWindow":                     ptabBottom->Tab(4)->SelectTab
	Case "ImmediateWindow":                     ptabBottom->Tab(5)->SelectTab
	Case "LocalsWindow":                        ptabBottom->Tab(6)->SelectTab
	Case "ProcessesWindow":                     ptabBottom->Tab(7)->SelectTab
	Case "ThreadsWindow":                       ptabBottom->Tab(8)->SelectTab
	Case "WatchWindow":                         ptabBottom->Tab(9)->SelectTab
	Case "ImageManager":                        pfImageManager->Show *pfrmMain
	Case "Toolbars":                            ShowMainToolbar = Not ShowMainToolbar: ptbStandard->Visible = ShowMainToolbar: pfrmMain->RequestAlign
	Case "TBUseDebugger":                       ChangeUseDebugger ptbStandard->Buttons.Item("TBUseDebugger")->Checked, 0
	Case "UseDebugger":                         ChangeUseDebugger Not mnuUseDebugger->Checked, 1
	Case "Folder":                              WithFolder
	Case "SyntaxCheck":                         If SaveAllBeforeCompile Then ThreadCreate(@SyntaxCheck)
	Case "Compile":                             If SaveAllBeforeCompile Then ThreadCreate(@CompileProgram)
	Case "Make":                                If SaveAllBeforeCompile Then ThreadCreate(@MakeExecute)
	Case "MakeClean":                           ThreadCreate(@MakeClean)
	Case "FormatProject":                       ThreadCreate(@FormatProject) 'FormatProject 0
	Case "UnformatProject":                     ThreadCreate(@FormatProject, Cast(Any Ptr, 1)) 'FormatProject Cast(Any Ptr, 1)
	Case "Parameters":                          pfParameters->ShowModal *pfrmMain
	Case "StartWithCompile"
		If SaveAllBeforeCompile Then
			'SaveAll '
			If InDebug Then
				#ifndef __USE_GTK__
					ChangeEnabledDebug False, True, True
					fastrun()
					'runtype = RTRUN
					'thread_rsm()
				#endif
			ElseIf UseDebugger Then
				#ifndef __USE_GTK__
					runtype = RTFRUN
					'runtype = RTRUN
					CurrentTimer = SetTimer(0, 0, 1, @TimerProc)
				#endif
				ThreadCreate(@StartDebuggingWithCompile)
			Else
				ThreadCreate(@CompileAndRun)
			End If
		End If
	Case "Start"
		If InDebug Then
			#ifndef __USE_GTK__
				ChangeEnabledDebug False, True, True
				fastrun()
'				runtype = RTRUN
'				thread_rsm()
			#endif
		ElseIf UseDebugger Then
			#ifndef __USE_GTK__
				runtype = RTFRUN
				'runtype = RTRUN
				CurrentTimer = SetTimer(0, 0, 1, @TimerProc)
			#endif
			ThreadCreate(@StartDebugging)
		Else
			ThreadCreate(@RunProgram)
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
			EndIf
			Stopcode=CSHALTBU
			'SetFocus(richeditcur)
		#endif
	Case "End":
		#ifdef __USE_GTK__
			ChangeEnabledDebug True, False, False
		#else
			'kill_process("Terminate immediatly no saved data, other option Release")
			For i As Integer = 1 To linenb 'restore old instructions
				WriteProcessMemory(dbghand, Cast(LPVOID, rline(i).ad), @rLine(i).sv, 1, 0)
			Next
			runtype = RTFREE
			'but_enable()
			thread_rsm()
			DeleteDebugCursor
			ChangeEnabledDebug True, False, False
		#endif
	Case "Restart"
		#ifndef __USE_GTK__
			If prun AndAlso kill_process("Trying to launch but debuggee still running")=False Then
				Exit Sub
			End If
			runtype = RTFRUN
			'runtype = RTRUN
			CurrentTimer = SetTimer(0, 0, 1, @TimerProc)
			Restarting = True
			ThreadCreate(@StartDebugging)
		#endif
	Case "StepInto":
		If InDebug Then
			ChangeEnabledDebug False, True, True
			#ifndef __USE_GTK__
				stopcode=0
				'bcktrk_close
				SetFocus(windmain)
				thread_rsm
			#endif
		Else
			#ifndef __USE_GTK__
				runtype = RTSTEP
				CurrentTimer = SetTimer(0, 0, 1, @TimerProc)
			#endif
			ThreadCreate(@StartDebugging)
		End If
	Case "StepOver":
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
				CurrentTimer = SetTimer(0, 0, 1, @TimerProc)
			#endif
			ThreadCreate(@StartDebugging)
		End If
	Case "SaveAs", "Close", "SyntaxCheck", "Compile", "CompileAndRun", "Run", "RunToCursor", _
		"Start", "Stop", "StepOut", "FindNext","FindPrev", "Goto", "SetNextStatement", "SortLines", _
		"AddWatch", "ShowVar", "NextBookmark", "PreviousBookmark", "ClearAllBookmarks", "Code", "Form", "CodeAndForm" '
		Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb = 0 Then Exit Sub
		Select Case Sender.ToString
		Case "Save":                        tb->Save
		Case "SaveAs":                      tb->SaveAs
		Case "Close":                       CloseTab(tb)
		Case "SortLines":                   tb->SortLines
			#ifndef __USE_GTK__
			Case "SetNextStatement":        exe_mod()
			Case "ShowVar":                 var_tip(1)
			Case "StepOut":
				If InDebug Then
					ChangeEnabledDebug False, True, True
					If (threadcur<>0 AndAlso proc_find(thread(threadcur).id,KLAST)<>proc_find(thread(threadcur).id,KFIRST)) _
						OrElse (threadcur=0 AndAlso proc(procr(proc_find(thread(0).id,KLAST)).idx).nm<>"main") Then 'impossible to go out first proc of thread, constructore for shared 22/12/2015
						procad = procsv
						runtype = RTFRUN
					End If
					SetFocus(windmain)
					thread_rsm()
				End If
			Case "RunToCursor":
				If InDebug Then
					ChangeEnabledDebug False, True, True
					brk_set(9)
				Else
					RunningToCursor = True
					runtype = RTFRUN
					CurrentTimer = SetTimer(0, 0, 1, @TimerProc)
					ThreadCreate(@StartDebugging)
				End If
			Case "AddWatch":                var_tip(2)
			#endif
		Case "FindNext":                    pfFind->Find(True)
		Case "FindPrev":                    pfFind->Find(False)
		Case "Goto":                        pfGoto->Show *pfrmMain
		Case "NextBookmark":                NextBookmark 1
		Case "PreviousBookmark":            NextBookmark -1
		Case "ClearAllBookmarks":           ClearAllBookmarks
		Case "Code":                        tbrTop_ButtonClick tb->tbrTop, *tb->tbrTop.Buttons.Item("Code") 
		Case "Form":                        tbrTop_ButtonClick tb->tbrTop, *tb->tbrTop.Buttons.Item("Form")
		Case "CodeAndForm":                 tbrTop_ButtonClick tb->tbrTop, *tb->tbrTop.Buttons.Item("CodeAndForm")
		End Select
	Case "SaveAll":                         SaveAll
	Case "CloseAll":                        CloseAllTabs
	Case "CloseAllWithoutCurrent":          CloseAllTabs(True)
	Case "Exit":                            pfrmMain->CloseForm
	Case "Find":                            mFormFind = True: pfFind->Show *pfrmMain
	Case "FindInFiles":                     mFormFindInFile = True:  pfFindFile->Show *pfrmMain
	Case "ReplaceInFiles":                  mFormFindInFile = False:  pfFindFile->Show *pfrmMain
	Case "Replace":                         mFormFind = False: pfFind->Show *pfrmMain
	Case "PinLeft":                         SetLeftClosedStyle Not tbLeft.Buttons.Item("PinLeft")->Checked, False
	Case "PinRight":                        SetRightClosedStyle Not tbRight.Buttons.Item("PinRight")->Checked, False
	Case "PinBottom":                       SetBottomClosedStyle Not tbBottom.Buttons.Item("PinBottom")->Checked, False
	Case "EraseOutputWindow":               txtOutput.Text = ""
	Case "AddForm":                         AddFromTemplate ExePath + "/Templates/Files/Form.frm"
	Case "AddModule":                       AddFromTemplate ExePath + "/Templates/Files/Module.bas"
	Case "AddIncludeFile":                  AddFromTemplate ExePath + "/Templates/Files/Include File.bi"
	Case "AddUserControl":                  AddFromTemplate ExePath + "/Templates/Files/User Control.bas"
	Case "AddResource":                     AddFromTemplate ExePath + "/Templates/Files/Resource.rc"
	Case "AddManifest":                     AddFromTemplate ExePath + "/Templates/Files/Manifest.xml"
	Case "PlainText", "Utf8", "Utf16", "Utf32"
		Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		Dim FileEncoding As FileEncodings
		Select Case Sender.ToString
		Case "PlainText": FileEncoding = FileEncodings.PlainText
		Case "Utf8": FileEncoding = FileEncodings.Utf8
		Case "Utf16": FileEncoding = FileEncodings.Utf16
		Case "Utf32": FileEncoding = FileEncodings.Utf32
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
		#ifndef __USE_GTK__
		Case "ShowString":                  string_sh(tviewvar)
		Case "ShowExpandVariable":          shwexp_new(tviewvar)
		#endif
	Case "Undo", "Redo", "Cut", "Copy", "Paste", "SelectAll", "SingleComment", "BlockComment", "UnComment", _
		"Indent", "Outdent", "Format", "Unformat", "AddSpaces", "NumberOn", "MacroNumberOn", "NumberOff", "ProcedureNumberOn", "ProcedureMacroNumberOn", "ProcedureNumberOff", _
		"PreprocessorNumberOn", "PreprocessorNumberOff", "Breakpoint", "ToggleBookmark", "CollapseAll", "UnCollapseAll", _
		"CompleteWord", "OnErrorResumeNext", "OnErrorGoto", "OnErrorGotoResumeNext", "RemoveErrorHandling", "Define"
		If pfrmMain->ActiveControl = 0 Then Exit Sub
		If pfrmMain->ActiveControl->ClassName <> "EditControl" AndAlso pfrmMain->ActiveControl->ClassName <> "TextBox" AndAlso pfrmMain->ActiveControl->ClassName <> "Panel" Then Exit Sub
		Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If pfrmMain->ActiveControl->ClassName = "TextBox" Then
			Dim txt As TextBox Ptr = Cast(TextBox Ptr, pfrmMain->ActiveControl)
			Select Case Sender.ToString
			Case "Undo":                    txt->Undo
			Case "Cut":                     txt->CutToClipboard
			Case "Copy":                    txt->CopyToClipboard
			Case "Paste":                   txt->PasteFromClipboard
			Case "SelectAll":               txt->SelectAll
			End Select
		ElseIf tb <> 0 Then
			If tb->cboClass.ItemIndex > 0 Then
				Dim des As Designer Ptr = tb->Des
				If des = 0 Then Exit Sub
				Select Case Sender.ToString
				Case "Cut":                     des->CutControl
				Case "Copy":                    des->CopyControl
				Case "Paste":                   des->PasteControl
				End Select
			ElseIf pfrmMain->ActiveControl->ClassName = "EditControl" OrElse pfrmMain->ActiveControl->ClassName = "Panel" Then
				Dim ec As EditControl Ptr = @tb->txtCode
				Select Case Sender.ToString
				Case "Redo":                    ec->Redo
				Case "Undo":                    ec->Undo
				Case "Cut":                     ec->CutToClipboard
				Case "Copy":                    ec->CopyToClipboard
				Case "Paste":                   ec->PasteFromClipboard
				Case "SelectAll":               ec->SelectAll
				Case "SingleComment":           ec->CommentSingle
				Case "BlockComment":            ec->CommentBlock
				Case "UnComment":               ec->UnComment
				Case "Indent":                  ec->Indent
				Case "Outdent":                 ec->Outdent
				Case "Format":                  ec->FormatCode
				Case "Unformat":                ec->UnformatCode
				Case "AddSpaces":               tb->AddSpaces
				Case "Breakpoint":
					#ifndef __USE_GTK__
						If InDebug Then: brk_set(1): End If
					#endif
					ec->BreakPoint
				Case "CollapseAll":             ec->CollapseAll
				Case "UnCollapseAll":           ec->UnCollapseAll
				Case "CompleteWord":            CompleteWord
				Case "ToggleBookmark":          ec->Bookmark
				Case "Define":                  tb->Define
				Case "NumberOn":        	    tb->NumberOn
				Case "MacroNumberOn":        	tb->NumberOn , , True
				Case "NumberOff":               tb->NumberOff
				Case "ProcedureNumberOn":       tb->ProcedureNumberOn
				Case "ProcedureMacroNumberOn":  tb->ProcedureNumberOn True
				Case "ProcedureNumberOff":      tb->ProcedureNumberOff
				Case "PreprocessorNumberOn":    tb->PreprocessorNumberOn
				Case "PreprocessorNumberOff":   tb->PreprocessorNumberOff
				Case "OnErrorResumeNext":       tb->SetErrorHandling "On Error Resume Next", ""
				Case "OnErrorGoto":             tb->SetErrorHandling "On Error Goto ErrorHandler", ""
				Case "OnErrorGotoResumeNext":   tb->SetErrorHandling "On Error Goto ErrorHandler", "Resume Next"
				Case "RemoveErrorHandling":     tb->RemoveErrorHandling
				End Select
			End If
		End If
	Case "Options":                         pfOptions->Show *pfrmMain
	Case "AddIns":                          pfAddIns->Show *pfrmMain
	Case "Tools":                           pfTools->Show *pfrmMain
	Case "Content":                         ThreadCreate(@RunHelp)
	Case "FreeBasicForums":                 OpenUrl "https://www.freebasic.net/forum/index.php"
	Case "FreeBasicWiKi":                   OpenUrl "https://www.freebasic.net/wiki/wikka.php?wakka=PageIndex"
	Case "GitHubWebSite":                   OpenUrl "https://github.com"
	Case "FreeBasicRepository":             OpenUrl "https://github.com/freebasic/fbc"
	Case "VisualFBEditorRepository":        OpenUrl "https://github.com/XusinboyBekchanov/VisualFBEditor"
	Case "VisualFBEditorWiKi":              OpenUrl "https://github.com/XusinboyBekchanov/VisualFBEditor/wiki"
	Case "MyFbFrameworkRepository":         OpenUrl "https://github.com/XusinboyBekchanov/MyFbFramework"
	Case "MyFbFrameworkWiKi":               OpenUrl "https://github.com/XusinboyBekchanov/MyFbFramework/wiki"
	Case "About":                           pfAbout->Show *pfrmMain
	End Select
End Sub

pApp->MainForm = @frmMain
pApp->Run

End
AA:
MsgBox ErrDescription(Err) & " (" & Err & ") " & _
"in function " & ZGet(Erfn()) & " " & _
"in module " & ZGet(Ermn()) ' & " " & _
'"in line " & Erl()
