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
Const VER_PATCH  = "4"
Const VERSION    = VER_MAJOR + "." + VER_MINOR + "." + VER_PATCH
Const BUILD_DATE = __DATE__
Const SIGN       = "VisualFBEditor " + VERSION

#define GetMN
'#define FBMLD_NO_MULTITHREADING
'#include "fbmld.bi"

#include once "Main.bi"
#include once "Debug.bi"
#include once "Designer.bi"
#include once "frmOptions.bi"
#include once "frmGoto.bi"
#include once "frmFind.bi"
#include once "frmFindInFiles.bi"
#include once "frmProjectProperties.bi"
#include once "frmParameters.bi"
#include once "frmAddIns.bi"
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
	Dim As UString cmd = Environ("COMSPEC") & " /K cd /D """ & GetFolderName(MainFile) & """"
	Shell(cmd)
End Sub

Sub FindInFiles
	ThreadCreate(@FindSub)
End Sub
Sub ReplaceInFiles
	ThreadCreate(@ReplaceSub)
End Sub
Sub mClickMRU(Sender As My.Sys.Object)
	OpenFiles Sender.ToString
End Sub

Sub mClickHelp(ByRef Sender As My.Sys.Object)
	ThreadCreate(@RunHelp, @Cast(MenuItem Ptr, @Sender)->ImageKey)
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
	Case "AddFileToProject":                    AddFileToProject
	Case "RemoveFileFromProject":               RemoveFileFromProject
	Case "OpenProjectFolder":                   OpenProjectFolder
	Case "ProjectProperties":                   pfProjectProperties->RefreshProperties: pfProjectProperties->ShowModal *pfrmMain
	Case "SetAsMain": 			                SetAsMain
	Case "TBUseDebugger":                       ChangeUseDebugger ptbStandard->Buttons.Item("TBUseDebugger")->Checked, 0
	Case "UseDebugger":                         ChangeUseDebugger Not mnuUseDebugger->Checked, 1
	Case "Folder":                              WithFolder
	Case "SyntaxCheck":                         ThreadCreate(@SyntaxCheck)
	Case "Compile":                             ThreadCreate(@CompileProgram)
	Case "Make":                                ThreadCreate(@MakeExecute)
	Case "MakeClean":                           ThreadCreate(@MakeClean)
	Case "FormatProject":                       ThreadCreate(@FormatProject) 'FormatProject 0
	Case "UnformatProject":                     ThreadCreate(@FormatProject, Cast(Any Ptr, 1)) 'FormatProject Cast(Any Ptr, 1)
	Case "Parameters":                          pfParameters->ShowModal *pfrmMain
	Case "StartWithCompile"
		'SaveAll 'David Change
		If InDebug Then
			#ifndef __USE_GTK__
				ChangeEnabledDebug False, True, True
				fastrun()
			#endif
		ElseIf UseDebugger Then
			#ifndef __USE_GTK__
				runtype = RTFRUN
				CurrentTimer = SetTimer(0, 0, 1, @TimerProc)
			#endif
			ThreadCreate(@StartDebuggingWithCompile)
		Else
			ThreadCreate(@CompileAndRun)
		End If
	Case "Start"
		If InDebug Then
			#ifndef __USE_GTK__
				ChangeEnabledDebug False, True, True
				fastrun()
			#endif
		ElseIf UseDebugger Then
			#ifndef __USE_GTK__
				runtype = RTFRUN
				CurrentTimer = SetTimer(0, 0, 1, @TimerProc)
			#endif
			ThreadCreate(@StartDebugging)
		Else
			ThreadCreate(@RunProgram)
		End If
	Case "Break":                   'If tb->Compile("Run") Then ThreadCreate(@RunWithDebug)
	Case "End":
		#ifndef __USE_GTK__
			For i As Integer = 1 To linenb 'restore old instructions
				WriteProcessMemory(dbghand, Cast(LPVOID, rline(i).ad), @rLine(i).sv, 1, 0)
			Next
			runtype = RTFREE
			'but_enable()
			thread_rsm()
			DeleteDebugCursor
			ChangeEnabledDebug True, False, False
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
	Case "SaveAs", "Close", "SyntaxCheck", "Compile", "CompileAndRun", "Run", "RunToCursor", _
		"Start", "Stop", "StepInto", "FindNext","FindPrev", "Goto", "SetNextStatement", "SortLines", _
		"AddWatch", "ShowVar", "NextBookmark", "PreviousBookmark", "ClearAllBookmarks", "SwitchCodeForm" 'David Change
		Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb = 0 Then Exit Sub
		Select Case Sender.ToString
		Case "Save":                        tb->Save
		Case "SaveAs":                      tb->SaveAs
		Case "Close":                       tb->CloseTab
		Case "SortLines":                   tb->SortLines
			#ifndef __USE_GTK__
			Case "SetNextStatement":        exe_mod()
			Case "ShowVar":                 var_tip(1)
			Case "RunToCursor":             brk_set(9)
			Case "AddWatch":                var_tip(2)
			#endif
		Case "FindNext":                    pfFind->Find(True)
		Case "FindPrev":                    pfFind->Find(False)
		Case "Goto":                        pfGoto->Show *pfrmMain
		Case "NextBookmark":                NextBookmark 1
		Case "PreviousBookmark":            NextBookmark -1
		Case "ClearAllBookmarks":           ClearAllBookmarks
		Case "SwitchCodeForm":           'David Change
			If tb->pnlForm.Visible  Then
				tb->pnlCode.Visible = True
				tb->pnlForm.Visible = False
				tb->splForm.Visible = False
			Else
				tb->pnlCode.Visible = False
				tb->pnlForm.Align = 5
				tb->pnlForm.Visible = True
				tb->splForm.Visible = False
				If tb->bNotDesign = False Then tb->FormDesign
				
			End If
			tb->RequestAlign
		End Select
	Case "SaveAll":                         SaveAll
	Case "CloseAll":                        CloseAllTabs
	Case "CloseAllWithoutCurrent":          CloseAllTabs(True)
	Case "Exit":                            pfrmMain->CloseForm
	Case "Find":                            mFormFind = True: pfFind->Show *pfrmMain
	Case "FindInFiles":                     mFormFindInFile = True:  pfFindFile->Show *pfrmMain
	Case "ReplaceInFiles":                  mFormFindInFile = False:  pfFindFile->Show *pfrmMain
	Case "Replace":                         mFormFind = False: pfFind->Show *pfrmMain
	Case "NewForm":                         AddTab ExePath + "/Templates/Files/Form.bas", True
		#ifndef __USE_GTK__
		Case "ShowString":                  string_sh(tviewvar)
		Case "ShowExpandVariable":          shwexp_new(tviewvar)
		#endif
	Case "Undo", "Redo", "Cut", "Copy", "Paste", "SelectAll", "SingleComment", "BlockComment", "UnComment", _
		"Indent", "Outdent", "Format", "Unformat", "NumberOn", "NumberOff", "ProcedureNumberOn", "ProcedureNumberOff", _
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
				Case "Breakpoint":              ec->BreakPoint
				Case "CollapseAll":             ec->CollapseAll
				Case "UnCollapseAll":           ec->UnCollapseAll
				Case "CompleteWord":            CompleteWord
				Case "ToggleBookmark":          ec->Bookmark
				Case "Define":                  tb->Define
				Case "NumberOn":        	    tb->NumberOn
				Case "NumberOff":               tb->NumberOff
				Case "ProcedureNumberOn":       tb->ProcedureNumberOn
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
	Case "Content":                         ThreadCreate(@RunHelp)
	Case "FreeBasicForums":                 OpenUrl "https://www.freebasic.net/forum/index.php"
	Case "FreeBasicWiKi":                   OpenUrl "https://www.freebasic.net/wiki/wikka.php?wakka=PageIndex"
	Case "GitHubWebSite":                   OpenUrl "https://github.com"
	Case "FreeBasicRepository":             OpenUrl "https://github.com/freebasic/fbc"
	Case "VisualFBEditorRepository":        OpenUrl "https://github.com/XusinboyBekchanov/VisualFBEditor"
	Case "MyFbFrameworkRepository":         OpenUrl "https://github.com/XusinboyBekchanov/MyFbFramework"
	Case "About":                           pfAbout->Show *pfrmMain
	End Select
End Sub


