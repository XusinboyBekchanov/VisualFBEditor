'#########################################################
'#  TabWindow.bas                                        #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "TabWindow.bi"
#include once "frmImageManager.bi"
#include once "Debug.bi"
#include once "vbcompat.bi"  ' for could using format function
#define TabSpace IIf(TabAsSpaces AndAlso ChoosedTabStyle = 0, WSpace(TabWidth), !"\t")

Dim Shared FPropertyItems As WStringList
Dim Shared FListItems As WStringList
Dim Shared txtCodeBi As EditControl
Dim Shared mnuCode As PopupMenu
pmnuCode = @mnuCode
Dim Shared MouseHoverTimerVal As Double
txtCodeBi.WithHistory = False

Destructor ExplorerElement
	If FileName Then _Deallocate( FileName)
	If TemplateFileName Then _Deallocate( TemplateFileName)
End Destructor

Constructor ProjectElement
	WLet(FileDescription, "{ProjectDescription}")
	WLet(ProductName, "{ProjectName}")
	Manifest = True
End Constructor

Destructor ProjectElement
	WDeAllocate(MainFileName)
	WDeAllocate(ResourceFileName)
	WDeAllocate(IconResourceFileName)
	WDeAllocate(BatchCompilationFileNameWindows)
	WDeAllocate(BatchCompilationFileNameLinux)
	WDeAllocate(ProjectName)
	WDeAllocate(HelpFileName)
	WDeAllocate(ProjectDescription)
	WDeAllocate(ApplicationTitle)
	WDeAllocate(ApplicationIcon)
	WDeAllocate(CompanyName)
	WDeAllocate(FileDescription)
	WDeAllocate(InternalName)
	WDeAllocate(LegalCopyright)
	WDeAllocate(LegalTrademarks)
	WDeAllocate(OriginalFilename)
	WDeAllocate(ProductName)
	WDeAllocate(CompilationArguments32Windows)
	WDeAllocate(CompilationArguments64Windows)
	WDeAllocate(CompilationArguments32Linux)
	WDeAllocate(CompilationArguments64Linux)
	WDeAllocate(CompilerPath)
	WDeAllocate(CommandLineArguments)
	WDeAllocate(AndroidSDKLocation)
	WDeAllocate(AndroidNDKLocation)
	WDeAllocate(JDKLocation)
	Files.Clear
End Destructor

Type TabCtl Extends TabControl
	Declare Static Sub MoveCloseButtons(ptabCode As TabControl Ptr)
End Type

Public Sub TabCtl.MoveCloseButtons(ptabCode As TabControl Ptr)
	Dim As Rect RR
	For i As Integer = 0 To ptabCode->TabCount - 1
		Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->Tabs[i])
		Dim As Boolean bVisible
		If tb = 0 Then Continue For
		#ifndef __USE_GTK__
			SendMessage(ptabCode->Handle, TCM_GETITEMRECT, tb->Index, CInt(@RR))
			bVisible = True
			If ptabCode->UpDownControl.Handle AndAlso CInt(ptabCode->UpDownControl.Visible) AndAlso RR.Right - ScaleX(18) + ScaleX(14) > ScaleX(ptabCode->UpDownControl.Left) Then bVisible = False
			tb->btnClose.Visible = bVisible
			MoveWindow tb->btnClose.Handle, RR.Right - ScaleX(18), ScaleY(4), ScaleX(14), ScaleY(14), True
			'If g_darkModeSupported AndAlso g_darkModeEnabled Then
			'	UpdateWindow ptabCode->Handle
			'End If
		#endif
	Next i
	#ifndef __USE_GTK__
		If g_darkModeSupported AndAlso g_darkModeEnabled Then
			UpdateWindow ptabCode->Handle
		End If
	#endif
End Sub

Sub PopupClick(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Object)
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 OrElse tb->Des = 0 Then Exit Sub
	Select Case Sender.ToString
	Case "Default":         DesignerDblClickControl(*tb->Des, tb->Des->SelectedControl)
	Case "Copy":            tb->Des->CopyControl()
	Case "Cut":             tb->Des->CutControl()
	Case "Paste":           tb->Des->PasteControl()
	Case "Delete":          tb->Des->DeleteControl()
	Case "Duplicate":       tb->Des->DuplicateControl
	Case "BringToFront":    DesignerBringToFront(*tb->Des, tb->Des->SelectedControl)
	Case "SendToBack":      DesignerSendToBack(*tb->Des, tb->Des->SelectedControl)
	Case "Properties":      If tb->Des->OnClickProperties Then tb->Des->OnClickProperties(*tb->Des, tb->Des->SelectedControl)
	End Select
End Sub

' Could not find in the child node
Function FileNameInTreeNode(tn As TreeNode Ptr, ByRef FileName As WString) As TreeNode Ptr
	If tn = 0 Then Return 0
	Dim As ExplorerElement Ptr ee
	Dim As TreeNode Ptr FindNode
	Dim tParent As Boolean
	If tn->Tag <> 0 Then
		ee = tn->Tag
		If EqualPaths(*ee->FileName, FileName) Then Return tn
	End If
	If tn->Nodes.Count > 0 Then
		For i As Integer = 0 To tn->Nodes.Count - 1
			FindNode = FileNameInTreeNode(tn->Nodes.Item(i), FileName)
			If FindNode <> 0 Then Return FindNode
		Next
	End If
	Return 0
End Function

Sub FormatProject(UnFormat As Any Ptr)
	Dim As TreeNode Ptr tn, tn1, tn2 = ptvExplorer->SelectedNode
	Dim As ExplorerElement Ptr ee
	Dim As EditControl txt
	Dim As EditControl Ptr ptxt
	Dim As TabWindow Ptr tb, tbCurrent = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	Dim FileEncoding As FileEncodings, NewLineType As NewLineTypes
	If tn2 <> 0 Then tn2 = GetParentNode(tn2)
	If tn2 = 0 OrElse tn2->ImageKey <> "Project" Then Exit Sub
	ThreadsEnter()
	pstBar->Panels[0]->Caption = IIf(UnFormat, ML("UnFormat Project"), ML("Format Project")) &"... "
	ThreadsLeave()
	If tbCurrent <> 0 Then tbCurrent->txtCode.UpdateLock
	pfrmMain->Enabled = False
	StartProgress
	For i As Integer = 0 To tn2->Nodes.Count - 1
		tn = tn2->Nodes.Item(i)
		ee = tn->Tag
		If ee = 0 Then
			For j As Integer = 0 To tn->Nodes.Count - 1
				tn1 = tn->Nodes.Item(j)
				If tn1 <> 0 Then
					ee = tn1->Tag
					If ee <> 0 AndAlso (EndsWith(*ee->FileName, ".bas") OrElse EndsWith(*ee->FileName, ".bi") OrElse EndsWith(*ee->FileName, ".inc") OrElse EndsWith(*ee->FileName, ".frm")) Then
						tb = GetTab(*ee->FileName)
						If tb = 0 Then
							txt.LoadFromFile(*ee->FileName, FileEncoding, NewLineType)
							ptxt = @txt
						Else
							ptxt = @tb->txtCode
						End If
						If UnFormat Then ptxt->UnformatCode(True) Else ptxt->FormatCode(True)
						If tb = 0 Then ptxt->SaveToFile(*ee->FileName, FileEncoding, NewLineType)
					End If
				End If
			Next
		ElseIf (EndsWith(*ee->FileName, ".bas") OrElse EndsWith(*ee->FileName, ".bi") OrElse EndsWith(*ee->FileName, ".inc") OrElse EndsWith(*ee->FileName, ".frm")) Then
			tb = GetTab(*ee->FileName)
			If tb = 0 Then
				txt.LoadFromFile(*ee->FileName, FileEncoding, NewLineType)
				ptxt = @txt
			Else
				ptxt = @tb->txtCode
			End If
			If UnFormat Then ptxt->UnformatCode(True) Else ptxt->FormatCode(True)
			If tb = 0 Then ptxt->SaveToFile(*ee->FileName, FileEncoding, NewLineType)
		End If
	Next
	StopProgress
	pfrmMain->Enabled = True
	If tbCurrent <> 0 Then tbCurrent->txtCode.UpdateUnLock
	ThreadsEnter()
	pstBar->Panels[0]->Caption = ML("Press F1 for get more information")
	ThreadsLeave()
End Sub

Sub NumberingModule(pSender As Any Ptr)
	Dim As Boolean bMacro = StartsWith(Cast(My.Sys.Object Ptr, pSender)->ToString, "ModuleMacroNumberOn")
	Dim As Boolean bStartsOfProcs = EndsWith(Cast(My.Sys.Object Ptr, pSender)->ToString, "StartsOfProcs")
	Dim As Boolean bPreprocesssor = StartsWith(Cast(My.Sys.Object Ptr, pSender)->ToString, "ModulePreprocessor")
	Dim As Boolean bRemove = Cast(My.Sys.Object Ptr, pSender)->ToString = "ModuleNumberOff"
	Dim As Boolean bRemovePreprocessor = Cast(My.Sys.Object Ptr, pSender)->ToString = "ModulePreprocessorNumberOff"
	Dim As EditControl Ptr ptxt
	Dim As TabWindow Ptr tbCurrent = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tbCurrent <> 0 Then tbCurrent->txtCode.UpdateLock Else Exit Sub
	pfrmMain->Enabled = False
	StartProgress
	ptxt = @tbCurrent->txtCode
	If bPreprocesssor Then
		If bRemovePreprocessor Then PreprocessorNumberingOff(*ptxt, True) Else PreprocessorNumberingOn(*ptxt, tbCurrent->FileName, True)
	Else
		If bRemove Then NumberingOff(0, ptxt->LinesCount - 1, *ptxt, True) Else NumberingOn(0, ptxt->LinesCount - 1, bMacro, *ptxt, True, bStartsOfProcs)
	End If
	StopProgress
	pfrmMain->Enabled = True
	If tbCurrent <> 0 Then tbCurrent->txtCode.UpdateUnLock
End Sub

Sub NumberingProject(pSender As Any Ptr)
	Dim As TreeNode Ptr tn, tn1, tn2 = ptvExplorer->SelectedNode
	Dim As ExplorerElement Ptr ee
	Dim As Boolean bMacro = StartsWith(Cast(My.Sys.Object Ptr, pSender)->ToString, "ProjectMacroNumberOn")
	Dim As Boolean bStartsOfProcs = EndsWith(Cast(My.Sys.Object Ptr, pSender)->ToString, "StartsOfProcs")
	Dim As Boolean bPreprocesssor = StartsWith(Cast(My.Sys.Object Ptr, pSender)->ToString, "ProjectPreprocessor")
	Dim As Boolean bRemove = Cast(My.Sys.Object Ptr, pSender)->ToString = "ProjectNumberOff"
	Dim As Boolean bRemovePreprocessor = Cast(My.Sys.Object Ptr, pSender)->ToString = "ProjectPreprocessorNumberOff"
	Dim As EditControl txt
	Dim As EditControl Ptr ptxt
	Dim As TabWindow Ptr tb, tbCurrent = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	Dim FileEncoding As FileEncodings, NewLineType As NewLineTypes
	If tn2 <> 0 Then tn2 = GetParentNode(tn2)
	If tn2 = 0 OrElse tn2->ImageKey <> "Project" Then Exit Sub
	If tbCurrent <> 0 Then tbCurrent->txtCode.UpdateLock
	pfrmMain->Enabled = False
	StartProgress
	For i As Integer = 0 To tn2->Nodes.Count - 1
		tn = tn2->Nodes.Item(i)
		ee = tn->Tag
		If ee = 0 Then
			For j As Integer = 0 To tn->Nodes.Count - 1
				tn1 = tn->Nodes.Item(j)
				If tn1 <> 0 Then
					ee = tn1->Tag
					If ee <> 0 AndAlso (EndsWith(LCase(*ee->FileName), ".bas") OrElse EndsWith(LCase(*ee->FileName), ".bi") OrElse EndsWith(LCase(*ee->FileName), ".inc") OrElse EndsWith(LCase(*ee->FileName), ".frm")) Then
						tb = GetTab(*ee->FileName)
						If tb = 0 Then
							txt.LoadFromFile(*ee->FileName, FileEncoding, NewLineType)
							ptxt = @txt
						Else
							ptxt = @tb->txtCode
						End If
						If bPreprocesssor Then
							If bRemovePreprocessor Then PreprocessorNumberingOff(*ptxt, True) Else PreprocessorNumberingOn(*ptxt, *ee->FileName, True)
						Else
							If bRemove Then NumberingOff(0, ptxt->LinesCount - 1, *ptxt, True) Else NumberingOn(0, ptxt->LinesCount - 1, bMacro, *ptxt, True, bStartsOfProcs)
						End If
						If tb = 0 Then
							FileCopy  *ee->FileName, GetBakFileName(*ee->FileName)
							ptxt->SaveToFile(*ee->FileName, FileEncoding, NewLineType)
						End If
					End If
				End If
			Next
		ElseIf (EndsWith(LCase(*ee->FileName), ".bas") OrElse EndsWith(LCase(*ee->FileName), ".bi") OrElse EndsWith(LCase(*ee->FileName), ".inc") OrElse EndsWith(LCase(*ee->FileName), ".frm")) Then
			tb = GetTab(*ee->FileName)
			If tb = 0 Then
				txt.LoadFromFile(*ee->FileName, FileEncoding, NewLineType)
				ptxt = @txt
			Else
				ptxt = @tb->txtCode
			End If
			If bPreprocesssor Then
				If bRemovePreprocessor Then PreprocessorNumberingOff(*ptxt, True) Else PreprocessorNumberingOn(*ptxt, *ee->FileName, True)
			Else
				If bRemove Then NumberingOff(0, ptxt->LinesCount - 1, *ptxt, True) Else NumberingOn(0, ptxt->LinesCount - 1, bMacro, *ptxt, True, bStartsOfProcs)
			End If
			If tb = 0 Then
				FileCopy  *ee->FileName, GetBakFileName(*ee->FileName)
				ptxt->SaveToFile(*ee->FileName, FileEncoding, NewLineType)
			End If
		End If
	Next
	StopProgress
	pfrmMain->Enabled = True
	If tbCurrent <> 0 Then tbCurrent->txtCode.UpdateUnLock
	MsgBox ML("Done") & "!"
End Sub

Function GetTab(ByRef FileName As WString) As TabWindow Ptr
	Dim As TabWindow Ptr tb
	For j As Integer = 0 To TabPanels.Count - 1
		Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
		For i As Integer = 0 To ptabCode->TabCount - 1
			tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
			If EqualPaths(tb->FileName, FileName) Then Return tb
		Next i
	Next j
	Return 0
End Function

Function GetTabFromTn(tn As TreeNode Ptr) As TabWindow Ptr
	Dim As TabWindow Ptr tb
	For j As Integer = 0 To TabPanels.Count - 1
		Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
		For i As Integer = 0 To ptabCode->TabCount - 1
			tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
			If tb->tn = tn Then Return tb
		Next i
	Next j
	Return 0
End Function

Function ProjectNameSameWithFolder(ptn As TreeNode Ptr) As Boolean
	If ptn AndAlso ptn->Tag Then
		Dim As WString Ptr FileName = Cast(ExplorerElement Ptr, ptn->Tag)->FileName
		If LCase(GetFileName(*FileName)) = LCase(GetFileName(GetFolderName(*FileName, False)) & ".vfp") Then
			Return True
		ElseIf FileExists(*FileName & "/" & GetFileName(*FileName) & ".vfp") Then
			Return True
		End If
	End If
	Return False
End Function

Sub ChangeMenuItemsEnabled
	Dim As TreeNode Ptr ptn = GetParentNode(tvExplorer.SelectedNode)
	Dim bEnabled As Boolean = tvExplorer.Nodes.Count > 0
	Dim bEnabledTab As Boolean = miWindow->Count > 3
	Dim bEnabledProject As Boolean = ptn AndAlso (ptn->ImageKey = "Project" OrElse ptn->ImageKey = "MainProject")
	Dim bEnabledFolderProject As Boolean = ptn AndAlso ((ptn->ImageKey = "Project") OrElse (ptn->ImageKey = "MainProject")) AndAlso CInt(ProjectNameSameWithFolder(ptn))
	Dim bEnabledProjectAndFolder As Boolean = ptn AndAlso ((ptn->ImageKey = "Project") OrElse (ptn->ImageKey = "MainProject") OrElse (ptn->ImageKey = "Opened"))
	'tbExplorer.Buttons.Item(3)->Enabled = Not(CBool(ptn > 0) AndAlso CBool(ptn->Tag > 0) AndAlso Cast(ProjectElement Ptr, ptn->Tag)->ProjectIsFolder)
	miShowWithFolders->Enabled = bEnabledProject
	miShowWithoutFolders->Enabled = bEnabledProject
	miShowAsFolder->Enabled = bEnabledFolderProject
	miSaveProject->Enabled = bEnabledProjectAndFolder
	miSaveProjectAs->Enabled = bEnabledProjectAndFolder
	miCloseProject->Enabled = bEnabledProjectAndFolder
	miCloseFolder->Enabled = bEnabledProjectAndFolder
	miExplorerCloseProject->Enabled = bEnabledProjectAndFolder
	miProjectProperties->Enabled = bEnabledProjectAndFolder
	miExplorerProjectProperties->Enabled = bEnabledProjectAndFolder
	mnuWindowSeparator->Visible = bEnabledTab
	miCode->Enabled = bEnabledTab
	miGoto->Enabled = bEnabledTab
	miDefine->Enabled = bEnabledTab
	miAddProcedure->Enabled = bEnabledTab
	mnuSplitHorizontally->Enabled = bEnabledTab
	mnuSplitVertically->Enabled = bEnabledTab
	miSave->Enabled = bEnabled
	tbtSave->Enabled = bEnabled
	miSaveAs->Enabled = bEnabled
	miSaveAll->Enabled = bEnabled
	tbtSaveAll->Enabled = bEnabled
	miClose->Enabled = bEnabled
	miCloseAll->Enabled = bEnabled
	miCloseSession->Enabled = bEnabled
	miPrint->Enabled = bEnabled
	miPrintPreview->Enabled = bEnabled
	miPageSetup->Enabled = bEnabled
	miOpenProjectFolder->Enabled = bEnabled
	miExplorerOpenProjectFolder->Enabled = bEnabled
	miImageManager->Enabled = bEnabled
	miRemoveFileFromProject->Enabled = bEnabled
	tbtRemoveFileFromProject->Enabled = bEnabled
	miFind->Enabled = bEnabled
	miFindNext->Enabled = bEnabled
	miFindPrevious->Enabled = bEnabled
	miReplace->Enabled = bEnabled
	miNextBookmark->Enabled = bEnabled
	miPreviousBookmark->Enabled = bEnabled
	miClearAllBookmarks->Enabled = bEnabled
	miClearAllBreakpoints->Enabled = bEnabled
	mnuStart->Enabled = bEnabled
	mnuStartWithCompile->Enabled = bEnabled
	tbtFind->Enabled = bEnabled
	tbtStart->Enabled = bEnabled
	tbtStartWithCompile->Enabled = bEnabled
	miSyntaxCheck->Enabled = bEnabled
	tbtSyntaxCheck->Enabled = bEnabled
	tbtSuggestions->Enabled = bEnabled
	miSuggestions->Enabled = bEnabled
	miCompile->Enabled = bEnabled
	tbtCompile->Enabled = bEnabled
	miCompileAll->Enabled = bEnabled
	miBuildBundle->Enabled = bEnabled
	miBuildAPK->Enabled = bEnabled
	miGenerateSignedBundle->Enabled = bEnabled
	miGenerateSignedAPK->Enabled = bEnabled
	miMake->Enabled = bEnabled
	miMakeClean->Enabled = bEnabled
	dmiMake->Enabled = bEnabled
	dmiMakeClean->Enabled = bEnabled
	miFormatProject->Enabled = bEnabled
	miUnformatProject->Enabled = bEnabled
	miProjectMacroNumbering->Enabled = bEnabled
	miProjectMacroNumberingStartsOfProcedures->Enabled = bEnabled
	miRemoveProjectNumbering->Enabled = bEnabled
	miProjectPreprocessorNumbering->Enabled = bEnabled
	miRemoveProjectPreprocessorNumbering->Enabled = bEnabled
	miModuleMacroNumbering->Enabled = bEnabled
	miModuleMacroNumberingStartsOfProcedures->Enabled = bEnabled
	miRemoveModuleNumbering->Enabled = bEnabled
	miModulePreprocessorNumbering->Enabled = bEnabled
	miRemoveModulePreprocessorNumbering->Enabled = bEnabled
	dmiModuleMacroNumbering->Enabled = bEnabled
	dmiModuleMacroNumberingStartsOfProcedures->Enabled = bEnabled
	dmiRemoveModuleNumbering->Enabled = bEnabled
	dmiModulePreprocessorNumbering->Enabled = bEnabled
	dmiRemoveModulePreprocessorNumbering->Enabled = bEnabled
	miStepInto->Enabled = bEnabled
	miStepOver->Enabled = bEnabled
End Sub

Function AddTab(ByRef FileName As WString = "", bNew As Boolean = False, TreeN As TreeNode Ptr = 0, bNoActivate As Boolean = False) As TabWindow Ptr
	Static As Boolean TabAdding
	If TabAdding Then Return 0
	On Error Goto ErrorHandler
	TabAdding = True
	MouseHoverTimerVal = Timer
	Dim bFind As Boolean
	Dim As UString FileNameNew
	Dim As TabWindow Ptr tb
	FileNameNew = FileName
	If EndsWith(FileNameNew, ":") Then FileNameNew = ..Left(FileNameNew, Len(FileNameNew) - 1)
	If FileName <> "" Then
		Dim As TabControl Ptr ptabCode
		For j As Integer = 0 To TabPanels.Count - 1
			ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
			For i As Integer = 0 To ptabCode->TabCount - 1
				If EqualPaths(Cast(TabWindow Ptr, ptabCode->Tabs[i])->FileName, FileNameNew) Then
					bFind = True
					tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
					If Not bNoActivate Then tb->SelectTab
					TabAdding = False
					Return tb
				End If
			Next i
		Next j
		If Not bFind Then
			Dim tn2 As TreeNode Ptr
			For i As Integer = 0 To ptvExplorer->Nodes.Count - 1
				tn2 = FileNameInTreeNode(ptvExplorer->Nodes.Item(i), FileNameNew)
				If tn2 <> 0 Then
					TreeN = tn2
					Exit For
				End If
			Next i
		End If
	End If
	ptabCode->UpdateLock
	If Not bFind Then
		tb = _New( TabWindow(FileNameNew, bNew, TreeN))
		If tb = 0 Then
			MsgBox ML("Memory was not allocated")
			TabAdding = False
			Return 0
		End If
		With *tb
			frmMain.Cursor = crWait
			If FileName <> "" Then
				#ifndef __USE_GTK__
					.DateFileTime = GetFileLastWriteTime(FileNameNew)
				#endif
			End If
			tb->UseVisualStyleBackColor = True
			tb->CheckExtension FileName
			'.txtCode.ContextMenu = @mnuCode
			ptabCode->AddTab(Cast(TabPage Ptr, tb))
			#ifdef __USE_GTK__
				'.layout = gtk_layout_new(NULL, NULL)
				'gtk_widget_set_size_request(.layout, 16, 16)
				'gtk_layout_put(gtk_layout(.layout), .btnClose.widget, 0, 0)
				gtk_box_pack_end (GTK_BOX (._Box), .btnClose.Handle, False, False, 0)
				gtk_widget_show_all(._Box)
			#else
				ptabCode->Add(@.btnClose)
			#endif
			tb->ImageKey = GetIconName(FileNameNew)
			If Not bNoActivate Then .SelectTab Else .Visible = True: ptabCode->RequestAlign: .Visible = False
			.tbrTop.Buttons.Item(1)->Checked = True
			If FileName <> "" Then
				pApp = @VisualFBEditorApp
				pApp->MainForm = @frmMain
				.txtCode.LoadFromFile(FileNameNew, tb->FileEncoding, tb->NewLineType, True)
				If bNew Then
					Dim As String NewFormName, LeftSpace
					Dim As UString LineTrim
					Dim bChanged As Boolean
					If TreeN <> 0 Then
						NewFormName = ..Left(TreeN->Text, Len(TreeN->Text) - 5)
					End If
					For i As Integer = 0 To .txtCode.LinesCount - 1
						LeftSpace = Left(.txtCode.Lines(i), Len(.txtCode.Lines(i)) - Len(Trim(.txtCode.Lines(i), Any !"\t ")))
						LineTrim = Trim(.txtCode.Lines(i), Any !"\t ")
						bChanged = False
						If CreateFormTypesWithoutTypeWord Then
							If LineTrim = "Type Form1Type Extends Form" Then
								.txtCode.ReplaceLine(i, LeftSpace & "Type Form1 Extends Form")
								bChanged = True
							ElseIf LineTrim = "Class Form1Type Extends Form" Then
								.txtCode.ReplaceLine(i, LeftSpace & "Class Form1 Extends Form")
								bChanged = True
							ElseIf LineTrim = "Dim Shared Form1 As Form1Type" Then
								.txtCode.ReplaceLine(i, LeftSpace & "Dim Shared fForm1 As Form1")
								bChanged = True
							ElseIf LineTrim = "Form1.Show" Then
								.txtCode.ReplaceLine(i, LeftSpace & "fForm1.Show")
								bChanged = True
							End If
							If bChanged Then LineTrim = .txtCode.Lines(i)
						End If
						If TreeN Then
							If LineTrim = "Type Form1 Extends Form" Then
								.txtCode.ReplaceLine(i, LeftSpace & "Type " & NewFormName & " Extends Form")
							ElseIf LineTrim = "Type Form1Type Extends Form" Then
								.txtCode.ReplaceLine(i, LeftSpace & "Type " & NewFormName & "Type Extends Form")
							ElseIf LineTrim = "Class Form1 Extends Form" Then
								.txtCode.ReplaceLine(i, LeftSpace & "Class " & NewFormName & " Extends Form")
							ElseIf LineTrim = "Class Form1Type Extends Form" Then
								.txtCode.ReplaceLine(i, LeftSpace & "Class " & NewFormName & "Type Extends Form")
							ElseIf LineTrim = "Constructor Form1Type" Then
								.txtCode.ReplaceLine(i, LeftSpace & "Constructor " & NewFormName & "Type")
							ElseIf LineTrim = "Constructor Form1" Then
								.txtCode.ReplaceLine(i, LeftSpace & "Constructor " & NewFormName)
							ElseIf LineTrim = "' Form1" Then
								.txtCode.ReplaceLine(i, LeftSpace & "' " & NewFormName)
							ElseIf LineTrim = ".Name = ""Form1""" Then
								.txtCode.ReplaceLine(i, LeftSpace & ".Name = """ & NewFormName & """")
							ElseIf LineTrim = ".Text = ""Form1""" Then
								.txtCode.ReplaceLine(i, LeftSpace & ".Text = """ & NewFormName & """")
							ElseIf LineTrim = "Dim Shared fForm1 As Form1" Then
								.txtCode.ReplaceLine(i, LeftSpace & "Dim Shared f" & NewFormName & " As " & NewFormName)
							ElseIf LineTrim = "Dim Shared Form1 As Form1Type" Then
								.txtCode.ReplaceLine(i, LeftSpace & "Dim Shared " & NewFormName & " As " & NewFormName & "Type")
							ElseIf LineTrim = "fForm1.MainForm = True" Then
								.txtCode.ReplaceLine(i, LeftSpace & "f" & NewFormName & ".MainForm = True")
							ElseIf LineTrim = "Form1.MainForm = True" Then
								.txtCode.ReplaceLine(i, LeftSpace & NewFormName & ".MainForm = True")
							ElseIf LineTrim = "fForm1.Show" Then
								.txtCode.ReplaceLine(i, LeftSpace & "f" & NewFormName & ".Show")
								Exit For
							ElseIf LineTrim = "Form1.Show" Then
								.txtCode.ReplaceLine(i, LeftSpace & NewFormName & ".Show")
								Exit For
							End If
						End If
					Next
				End If
			Else
				#ifdef __FB_WIN32__
					tb->NewLineType = NewLineTypes.WindowsCRLF
				#else
					tb->NewLineType = NewLineTypes.LinuxLF
				#endif
				tb->FileEncoding = FileEncodings.Utf8
			End If
			ChangeFileEncoding tb->FileEncoding
			ChangeNewLineType tb->NewLineType
			.FormDesign(bNoActivate)
			If CBool(FileName <> "") AndAlso CBool(tb->Project <> 0) AndAlso (EndsWith(FileName, "Form.frm") OrElse EndsWith(FileName, "UserControl.bas")) Then
				If Not tb->Project->Components.Contains("Controls/MyFbFramework") Then tb->Project->Components.Add "Controls/MyFbFramework"
			End If
			pApp->MainForm = @frmMain
			If FileName <> "" Then
				.txtCode.ClearUndo
				.Modified = bNew
			End If
			.txtCode.ScrollToCaret
			ChangeMenuItemsEnabled
			frmMain.Cursor = 0
		End With
		If tb->cboClass.Items.Count < 2 Then
			miForm->Enabled = False
			miCodeAndForm->Enabled = False
			tb->tbrTop.Buttons.Item("Form")->Enabled = False
			tb->tbrTop.Buttons.Item("CodeAndForm")->Enabled = False
			tb->tbrTop.Buttons.Item("Code")->Checked = True: tbrTop_ButtonClick *tb->tbrTop.Designer, tb->tbrTop, *tb->tbrTop.Buttons.Item("Code")
			SetRightClosedStyle True, True
		Else
			SetRightClosedStyle False, False
			miForm->Enabled = True
			miCodeAndForm->Enabled = True
			tb->tbrTop.Buttons.Item("Form")->Enabled = True
			tb->tbrTop.Buttons.Item("CodeAndForm")->Enabled = True
			tpProperties->SelectTab
		End If
		TabCtl.MoveCloseButtons ptabCode
	End If
	tb->txtCode.SetFocus
	ptabCode->UpdateUnLock
	ptabCode->Update
	TextChanged = False
	TabAdding = False
	Return tb
	Exit Function
	ErrorHandler:
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " " & _
	"in function " & ZGet(Erfn()) & " " & _
	"in module " & ZGet(Ermn())
End Function

Sub m(ByRef MSG As WString, InDebug As Boolean = False)
	If InDebug AndAlso Not DisplayWarningsInDebug Then Exit Sub
	ShowMessages MSG
End Sub

Sub OnChangeEdit(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Static CurLine As Integer, bChanged As Boolean
	Var tb = Cast(TabWindow Ptr, Sender.Tag)
	If tb = 0 Then Exit Sub
	tb->Modified = True
	TextChanged = True
	'    'Exit Sub
	'    With tb->txtCode
	'        If Not .Focused Then Exit Sub
	'        tb->FormDesign tb->tbrTop.Buttons.Item(1)->Checked
	'    End With
End Sub

'Declare Function get_var_value(VarName As String, LineIndex As Integer) As String

Sub OnMouseMoveEdit(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	'	Var tb = Cast(TabWindow Ptr, Sender.Tag)
	'	If tb = 0 Then Exit Sub
	'	#ifndef __USE_GTK__
	'		Dim ByRef As HWND hwndTT = tb->txtCode.ToolTipHandle
	'		If hwndTT <> 0 Then
	'			Dim As TOOLINFO    ti
	'			ZeroMemory(@ti, SizeOf(ti))
	'			ti.cbSize = SizeOf(ti)
	'			ti.hwnd   = tb->txtCode.Handle
	'			SendMessage(hwndTT, TTM_GETTOOLINFO, 0, CInt(@ti))
	'			SendMessage(hwndTT, TTM_TRACKACTIVATE, False, Cast(LPARAM, @ti))
	'		End If
	'	#endif
End Sub

Sub OnMouseHoverEdit(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	#ifndef __USE_GTK__
		If Not InDebug AndAlso Timer - MouseHoverTimerVal <= 4 Then Exit Sub
		Static As Integer OldY, OldX
		MouseHoverTimerVal = Timer
		Var tb = Cast(TabWindow Ptr, Sender.Tag)
		If tb = 0  OrElse tb->txtCode.LinesCount < 1 Then Exit Sub
		If tb->txtCode.DropDownShowed Then Exit Sub
		If tb->txtCode.ToolTipShowed And CBool((Abs(OldY - y) > 20 OrElse Abs(OldX - x) > 50)) Then
			tb->txtCode.CloseToolTip
			Exit Sub
		End If
		OldY = y: OldX = x
		Dim As String sWord = tb->txtCode.GetWordAtPoint(UnScaleX(x), UnScaleY(y), True)
		If sWord <> "" Then
			'			If Not InDebug Then
			'				Dim As Integer iSelEndLine, iSelEndChar
			'				iSelEndLine = tb->txtCode.LineIndexFromPoint(UnScaleX(X), UnScaleY(Y))
			'				iSelEndChar = tb->txtCode.CharIndexFromPoint(UnScaleX(X), UnScaleY(Y))
			'				tb->txtCode.SetSelection(iSelEndLine, iSelEndLine, iSelEndChar, iSelEndChar)
			'				OnKeyPressEdit(tb->txtCode, 5)
			'				Exit Sub
			'			End If
			Dim As WString * 250 Value
			If InDebug Then Value = get_var_value(sWord, tb->txtCode.LineIndexFromPoint(x, y)) Else Exit Sub
			If Value <> "" Then
				Dim ByRef As HWND hwndTT = tb->ToolTipHandle
				Dim As TOOLINFO    ti
				ZeroMemory(@ti, SizeOf(ti))
				ti.cbSize = SizeOf(ti)
				ti.hwnd   = tb->txtCode.Handle
				'ti.uId    = Cast(UINT, FHandle)
				If hwndTT = 0 Then
					hwndTT = CreateWindow(TOOLTIPS_CLASS, "", WS_POPUP, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, NULL, Cast(HMENU, NULL), GetModuleHandle(NULL), NULL)
					ti.uFlags = TTF_IDISHWND Or TTF_TRACK Or TTF_ABSOLUTE Or TTF_PARSELINKS Or TTF_TRANSPARENT
					ti.hinst  = GetModuleHandle(NULL)
					ti.lpszText  = @Value
					'SendMessage(hwndTT, TTM_SETDELAYTIME, TTDT_INITIAL, 100)
					SendMessage(hwndTT, TTM_ADDTOOL, 0, Cast(LPARAM, @ti))
				Else
					SendMessage(hwndTT, TTM_GETTOOLINFO, 0, CInt(@ti))
					ti.lpszText = @Value
					SendMessage(hwndTT, TTM_UPDATETIPTEXT, 0, CInt(@ti))
				End If
				Dim As Point Pt
				Pt.X = x
				Pt.Y = y
				ClientToScreen tb->txtCode.Handle, @Pt
				SendMessage(hwndTT, TTM_TRACKPOSITION, 0, MAKELPARAM(Pt.X, Pt.Y + 10))
				SendMessage(hwndTT, TTM_SETMAXTIPWIDTH, 0, 1000)
				SendMessage(hwndTT, TTM_TRACKACTIVATE, True, Cast(LPARAM, @ti))
				tb->ToolTipHandle = hwndTT
				Exit Sub
			End If
		End If
		Dim ByRef As HWND hwndTT = tb->ToolTipHandle
		If hwndTT <> 0 Then
			Dim As TOOLINFO    ti
			ZeroMemory(@ti, SizeOf(ti))
			ti.cbSize = SizeOf(ti)
			ti.hwnd   = tb->txtCode.Handle
			SendMessage(hwndTT, TTM_GETTOOLINFO, 0, CInt(@ti))
			SendMessage(hwndTT, TTM_TRACKACTIVATE, False, Cast(LPARAM, @ti))
		End If
	#endif
End Sub

Function IsLabel(ByRef LeftA As WString) As Boolean
	Dim strLeftA As String = Trim(LeftA, Any !"\t ")
	If EndsWith(strLeftA, ":") Then
		strLeftA = LCase(..Left(strLeftA, Len(strLeftA) - 1))
		Dim t As Integer
		If InStr("," & SingleConstructions & ",", "," & strLeftA & ",") > 0 Then Return False
		For i As Integer = 1 To Len(strLeftA)
			t = Asc(Mid(strLeftA, i, 1))
			If t >= 48 And t <= 57 Or t >= 65 And t <= 90 Or t >= 97 And t <= 122 Or t = Asc("_") Then
			Else: Return False
			End If
		Next
		Return True
	Else
		Return False
	End If
End Function

Property TabWindow.Modified As Boolean
	Return txtCode.Modified
End Property

Property TabWindow.Modified(Value As Boolean)
	If Value Then
		If Not EndsWith(Caption, "*") Then
			Caption = Caption + "*"
			TabCtl.MoveCloseButtons Cast(TabControl Ptr, This.Parent)
		End If
	Else
		If EndsWith(Caption, "*") Then
			Caption = ..Left(Caption, Len(Caption) - 1)
		End If
	End If
	txtCode.Modified = Value
End Property

'Function Likes(a As String, ContructionPart As String) As Boolean
'  Dim m As Variant, k As Long
'  m = Split(ContructionPart, ",")
'  For k = 0 To UBound(m)
'    If LCase(Trim(a)) Like LCase(m(k)) Then
'      Likes = True
'      Exit Function
'    End If
'  Next k
'End Function
'
'Function GetLikeConstruction(a As String, Optional k As Integer = 0, Optional e As Integer = 0) As Long
'  Dim i As Long
'  GetLikeConstruction = -1
'  If a = "" Then Exit Function
'  For i = 0 To 12
'    If Likes(a, Constructions(i, 0)) And Not Likes(a, Constructions(i, 3)) And k >= 0 Then
'      GetLikeConstruction = i: e = 1
'      Exit Function
'    ElseIf Likes(a, Constructions(i, 1)) And k <= 0 Then
'      GetLikeConstruction = i: e = 2
'      Exit Function
'    ElseIf Likes(a, Constructions(i, 2)) And k <= 1 Then
'      GetLikeConstruction = i: e = 3
'      Exit Function
'    End If
'  Next i
'End Function
'
Sub CloseButton_MouseUp(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	Dim tb As TabWindow Ptr = Cast(CloseButton Ptr, @Sender)->tbParent
	If tb = 0 Then Exit Sub
	CloseTab(tb)
End Sub

Sub CloseButton_MouseMove(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	Dim btn As CloseButton Ptr = Cast(CloseButton Ptr, @Sender)
	If btn= 0 OrElse btn->BackColor = clRed Then Exit Sub
	#ifndef __USE_GTK__
		btn->BackColor = clRed
		btn->Font.Color = clWhite
	#endif
	btn->MouseIn = True
	'DeAllocate btn
End Sub

Sub CloseButton_MouseLeave(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Dim btn As CloseButton Ptr = Cast(CloseButton Ptr, @Sender)
	If btn= 0 Then Exit Sub
	#ifndef __USE_GTK__
		btn->BackColor = btn->OldBackColor
		btn->Font.Color = btn->OldForeColor
	#endif
	btn->MouseIn = False
End Sub

#ifdef __USE_GTK__
	Function CloseButton_OnDraw(widget As GtkWidget Ptr, cr As cairo_t Ptr, data1 As gpointer) As Boolean
		Dim As CloseButton Ptr cb = Cast(Any Ptr, data1)
		
		#ifdef __FB_WIN32__
			cairo_select_font_face(cr, "Courier", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
		#else
			cairo_select_font_face(cr, "Noto Mono", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
		#endif
		cairo_set_font_size(cr, 11)
		
		#ifdef __USE_GTK3__
			Var width1 = gtk_widget_get_allocated_width (widget)
			Var height1 = gtk_widget_get_allocated_height (widget)
		#else
			Var width1 = widget->allocation.width
			Var height1 = widget->allocation.height
		#endif
		
		If cb->MouseIn Then
			cairo_rectangle(cr, width1 - 16, (height1 - 16) / 2, 16, 16)
			cairo_set_source_rgb(cr, 1.0, 0.0, 0.0)
			cairo_fill (cr)
			cairo_set_source_rgb(cr, 1.0, 1.0, 1.0)
		Else
			cairo_set_source_rgb(cr, 0.0, 0.0, 0.0)
		End If
		Dim As PangoRectangle extend
		pango_layout_set_text(cb->layout, ToUtf8("×"), Len(ToUtf8("×")))
		pango_cairo_update_layout(cr, cb->layout)
		#ifdef pango_version
			Dim As PangoLayoutLine Ptr pl = pango_layout_get_line_readonly(cb->layout, 0)
		#else
			Dim As PangoLayoutLine Ptr pl = pango_layout_get_line(cb->layout, 0)
		#endif
		pango_layout_line_get_pixel_extents(pl, NULL, @extend)
		cairo_move_to(cr, width1 - 16 + (16 - extend.width) / 2, (height1 - extend.height) / 2 + extend.height - 3)
		pango_cairo_show_layout_line(cr, pl)
		Return False
	End Function
	
	Function CloseButton_OnExposeEvent(widget As GtkWidget Ptr, Event As GdkEventExpose Ptr, data1 As gpointer) As Boolean
		Dim As cairo_t Ptr cr = gdk_cairo_create(Event->window)
		CloseButton_OnDraw(widget, cr, data1)
		cairo_destroy(cr)
		Return False
	End Function
#endif

Constructor CloseButton
	Base.OnMouseUp = @CloseButton_MouseUp
	OnMouseMove = @CloseButton_MouseMove
	OnMouseLeave = @CloseButton_MouseLeave
	OldBackColor = This.BackColor
	OldForeColor = This.Font.Color
	#ifdef __USE_GTK__
		#ifdef __USE_GTK3__
			g_signal_connect(widget, "draw", G_CALLBACK(@CloseButton_OnDraw), @This)
		#else
			g_signal_connect(widget, "expose-event", G_CALLBACK(@CloseButton_OnExposeEvent), @This)
		#endif
		This.Width = 20
		This.Height = 20
		Dim As PangoContext Ptr pcontext
		pcontext = gtk_widget_create_pango_context(widget)
		layout = pango_layout_new(pcontext)
		Dim As PangoFontDescription Ptr desc
		#ifdef __FB_WIN32__
			desc = pango_font_description_from_string ("Courier 11")
		#else
			desc = pango_font_description_from_string ("Noto Mono 11")
		#endif
		pango_layout_set_font_description (layout, desc)
		pango_font_description_free (desc)
	#else
		This.Alignment = taCenter
		Caption = "×"
	#endif
	'SubClass = True
End Constructor

Destructor CloseButton
	
End Destructor

Property TabWindow.Caption ByRef As WString
	Return WGet(FCaptionNew)
End Property

Property TabWindow.Caption(ByRef Value As WString)
	FCaptionNew = _Reallocate(FCaptionNew, (Len(Value) + 1) * SizeOf(WString))
	*FCaptionNew = Value
	#ifdef __USE_GTK__
		Base.Caption = Value
	#else
		Base.Caption = Value + Space(5)
	#endif
End Property

Property TabWindow.FileName ByRef As WString
	If WGet(FFileName) = "" Then
		Return ML("Untitled")
	Else
		Return WGet(FFileName)
	End If
End Property

Property TabWindow.FileName(ByRef Value As WString)
	WLet(FFileName,  Value)
	txtCode.Content.FileName = Value
End Property

Operator TabWindow.Cast As TabPage Ptr
	Return Cast(TabPage Ptr, @This)
End Operator

Sub DeleteFromTypeElement(te As TypeElement Ptr)
	If te->ElementType <> E_Enum Then
		For j As Integer = te->Elements.Count - 1 To 0 Step -1
			DeleteFromTypeElement(te->Elements.Object(j))
		Next
	End If
	te->Types.Clear
	te->Enums.Clear
	te->Elements.Clear
	_Delete(Cast(TypeElement Ptr, te))
End Sub

Sub RemoveGlobalTypeElements(ByRef FileName As WString)
	Var FileIndex = IncludeFiles.IndexOf(FileName)
	If FileIndex <> 0 Then
		MutexLock tlockSave
		Dim As EditControlContent Ptr File = IncludeFiles.Object(FileIndex)
		If File Then
			File->Includes.Clear
			File->IncludeLines.Clear
		End If
		Dim As TypeElement Ptr te, te1
		For i As Integer = pGlobalNamespaces->Count - 1 To 0 Step -1
			te = pGlobalNamespaces->Object(i)
			For j As Integer = te->Elements.Count - 1 To 0 Step -1
				te1 = te->Elements.Object(j)
				If te1->FileName = FileName Then
					te->Elements.Remove j
				End If
			Next
		Next
		For i As Integer = pGlobalNamespaces->Count - 1 To 0 Step -1
			te = pGlobalNamespaces->Object(i)
			If te->FileName = FileName Then
				te->Elements.Clear
				_Delete(Cast(TypeElement Ptr, pGlobalNamespaces->Object(i)))
				pGlobalNamespaces->Remove i
			End If
		Next
		For i As Integer = pGlobalTypes->Count - 1 To 0 Step -1
			te = pGlobalTypes->Object(i)
			If te->FileName = FileName Then
				DeleteFromTypeElement(te)
				'For j As Integer = te->Elements.Count - 1 To 0 Step -1
				'	_Delete(Cast(TypeElement Ptr, te->Elements.Object(j)))
				'Next
				'te->Elements.Clear
				'_Delete(Cast(TypeElement Ptr, pGlobalTypes->Object(i)))
				pGlobalTypes->Remove i
			Else
				For j As Integer = te->Elements.Count - 1 To 0 Step -1
					te1 = te->Elements.Object(j)
					If te1->FileName = FileName Then
						_Delete(Cast(TypeElement Ptr, te->Elements.Object(j)))
						te->Elements.Remove j
					End If
				Next
			End If
		Next
		'For i As Integer = pComps->Count - 1 To 0 Step -1
		'	te = pComps->Object(i)
		'	If te->FileName = FileName Then
		'		For j As Integer = te->Elements.Count - 1 To 0 Step -1
		'			Delete_(Cast(TypeElement Ptr, te->Elements.Object(j)))
		'		Next
		'		te->Elements.Clear
		'		Delete_(Cast(TypeElement Ptr, pComps->Object(i)))
		'		pComps->Remove i
		'	Else
		'		For j As Integer = te->Elements.Count - 1 To 0 Step -1
		'			te1 = te->Elements.Object(j)
		'			If te1->FileName = FileName Then
		'				Delete_(Cast(TypeElement Ptr, te->Elements.Object(j)))
		'				te->Elements.Remove j
		'			End If
		'		Next
		'	End If
		'Next
		For i As Integer = pGlobalEnums->Count - 1 To 0 Step -1
			te = pGlobalEnums->Object(i)
			If te->FileName = FileName Then
				For j As Integer = te->Elements.Count - 1 To 0 Step -1
					_Delete(Cast(TypeElement Ptr, te->Elements.Object(j)))
				Next
				te->Elements.Clear
				_Delete(Cast(TypeElement Ptr, pGlobalEnums->Object(i)))
				pGlobalEnums->Remove i
			End If
		Next
		For i As Integer = pGlobalFunctions->Count - 1 To 0 Step -1
			te = pGlobalFunctions->Object(i)
			If te->FileName = FileName Then
				_Delete(Cast(TypeElement Ptr, pGlobalFunctions->Object(i)))
				pGlobalFunctions->Remove i
			End If
		Next
		For i As Integer = pGlobalTypeProcedures->Count - 1 To 0 Step -1
			te = pGlobalTypeProcedures->Object(i)
			If te->FileName = FileName Then
				_Delete(Cast(TypeElement Ptr, pGlobalTypeProcedures->Object(i)))
				pGlobalTypeProcedures->Remove i
			End If
		Next
		For i As Integer = pGlobalArgs->Count - 1 To 0 Step -1
			te = pGlobalArgs->Object(i)
			If te->FileName = FileName Then
				_Delete(Cast(TypeElement Ptr, pGlobalArgs->Object(i)))
				pGlobalArgs->Remove i
			End If
		Next
		'LoadFunctions FileName, LoadParam.OnlyFilePathOverwrite, GlobalTypes, GlobalEnums, GlobalFunctions, GlobalArgs
		MutexUnlock tlockSave
	End If
End Sub

Function TabWindow.SaveTab As Boolean
	'  It is important to creat a backup file by time.
	'If txtCode.Modified = True Then
	If AutoCreateBakFiles Then
		FileCopy *FFileName, Str(GetBakFileName(*FFileName)) '
	End If
	txtCode.SaveToFile(*FFileName, FileEncoding, NewLineType) ', False
	IsNew = False
	Modified = False
	#ifndef __USE_GTK__
		DateFileTime = GetFileLastWriteTime(*FFileName)
	#endif
	Var Idx = -1
	If IncludeFiles.Contains(FileName, , , , Idx) Then
		RemoveGlobalTypeElements FileName
		If Not pLoadPaths->Contains(FileName) Then
			pLoadPaths->Add FileName
		End If
		ThreadCounter(ThreadCreate_(@LoadOnlyFilePathOverwrite, @pLoadPaths->Item(pLoadPaths->IndexOf(FileName))))
	End If
	Return True
End Function

Function TabWindow.SaveAs As Boolean
	SetSaveDialogParameters(FileName)
	If pSaveD->Execute Then
		WLet(LastOpenPath, GetFolderName(pSaveD->FileName))
		If FileExists(pSaveD->FileName) Then
			Select Case MsgBox(ML("Want to replace the file") & " """ & pSaveD->FileName & """?", App.Title, mtWarning, btYesNoCancel)
			Case mrCancel: Return False
			Case mrNo: Return SaveAs
			End Select
		End If
		Caption = GetFileName(pSaveD->FileName)
		tn->Text = Caption
		mi->Caption = Caption
		WLet(FFileName, pSaveD->FileName)
		txtCode.Content.FileName = *FFileName
		CheckExtension *FFileName
		MutexLock tlockSuggestions
		For i As Integer = 0 To lvSuggestions.ListItems.Count - 1
			If lvSuggestions.ListItems.Item(i)->Tag = @This Then
				lvSuggestions.ListItems.Item(i)->Text(3) = *FFileName
			End If
		Next
		MutexUnlock tlockSuggestions
		Dim As ExplorerElement Ptr ee = tn->Tag
		Dim As TreeNode Ptr ptn = GetParentNode(tn)
		If ee = 0 Then
			ee = _New( ExplorerElement)
			tn->Tag = ee
		End If
		If ptn <> 0 AndAlso ptn->ImageKey = "Project" Then
			Dim As ProjectElement Ptr pee = ptn->Tag
			If pee <> 0 Then
				If WGet(pee->MainFileName) = WGet(ee->FileName) Then WLet(pee->MainFileName, pSaveD->FileName)
				If WGet(pee->ResourceFileName) = WGet(ee->FileName) Then WLet(pee->ResourceFileName, pSaveD->FileName)
				If WGet(pee->IconResourceFileName) = WGet(ee->FileName) Then WLet(pee->IconResourceFileName, pSaveD->FileName)
				If WGet(pee->BatchCompilationFileNameWindows) = WGet(ee->FileName) Then WLet(pee->BatchCompilationFileNameWindows, pSaveD->FileName)
				If WGet(pee->BatchCompilationFileNameLinux) = WGet(ee->FileName) Then WLet(pee->BatchCompilationFileNameLinux, pSaveD->FileName)
				If Not EndsWith(ptn->Text, "*") Then ptn->Text & = "*"
			End If
		End If
		WLet(ee->FileName, pSaveD->FileName)
		AddMRUFile pSaveD->FileName
		Return SaveTab
	End If
	Return False
End Function

Function TabWindow.Save As Boolean
	If InStr(*FFileName, "/") > 0 OrElse InStr(*FFileName, "\") > 0 Then Return SaveTab Else Return SaveAs
End Function

Sub TabWindowRemovedCheck(pParentTabCode As TabControl Ptr)
	If pParentTabCode->TabCount = 0 Then
		Dim As TabPanel Ptr ptabPanelParent = Cast(TabPanel Ptr, pParentTabCode->Parent)
		Var Idx = ptabPanelParent->IndexOf(pParentTabCode)
		If Idx >= 2 Then
			Dim As TabPanel Ptr ptabPanelChild = Cast(TabPanel Ptr, ptabPanelParent->Controls[Idx - 2])
			ptabPanelChild->Align = DockStyle.alClient
			ptabPanelParent->Remove ptabPanelParent->Controls[Idx - 1]
			pParentTabCode->Visible = False
			ptabCode = @ptabPanelChild->tabCode
			mnuTabs.ParentWindow = ptabCode
			ptabPanelParent->RequestAlign
		Else
			Var ptabPanel = ptabPanelParent
			Do While *ptabPanel->Parent Is TabPanel
				Dim As TabPanel Ptr ptabPanelParent = Cast(TabPanel Ptr, ptabPanel->Parent)
				Var Idx = ptabPanelParent->IndexOf(ptabPanel)
				If Idx >= 2 AndAlso ptabPanel->Align = DockStyle.alClient Then
					Dim As TabPanel Ptr ptabPanelChild = Cast(TabPanel Ptr, ptabPanelParent->Controls[Idx - 2])
					ptabPanelChild->Align = DockStyle.alClient
					ptabPanelParent->Remove ptabPanelParent->Controls[Idx - 1]
					ptabPanelParent->Remove ptabPanel
					TabPanels.Remove TabPanels.IndexOf(ptabPanel)
					_Delete(ptabPanel)
					ptabPanelParent->RequestAlign
					ptabCode = @ptabPanelChild->tabCode
					mnuTabs.ParentWindow = ptabCode
					ptabPanel = 0
					Exit Do
				ElseIf ptabPanel->Align <> DockStyle.alClient Then
					If ptabPanelParent->tabCode.Visible Then
						ptabCode = @ptabPanelParent->tabCode
					Else
						ptabCode = @Cast(TabPanel Ptr, ptabPanelParent->Controls[Idx + 2])->tabCode
					End If
					mnuTabs.ParentWindow = ptabCode
					ptabPanelParent->Remove ptabPanelParent->Controls[Idx + 1]
					ptabPanelParent->Remove ptabPanel
					TabPanels.Remove TabPanels.IndexOf(ptabPanel)
					_Delete(ptabPanel)
					ptabPanelParent->RequestAlign
					ptabPanel = 0
					Exit Do
				Else
					ptabPanelParent->Remove ptabPanel
					TabPanels.Remove TabPanels.IndexOf(ptabPanel)
					_Delete(ptabPanel)
					ptabPanel = ptabPanelParent
				End If
			Loop
			If ptabPanel > 0 AndAlso ptabPanel->Parent = pfrmMain Then
				ptabPanel->tabCode.Visible = True
				ptabCode = @ptabPanel->tabCode
				mnuTabs.ParentWindow = ptabCode
			End If
		End If
	End If
End Sub

Function CloseTab(ByRef tb As TabWindow Ptr, WithoutMessage As Boolean = False) As Boolean
	If tb = 0 Then Return False
	Dim As TabControl Ptr pParentTabCode = tb->Parent
	If tb->CloseTab(WithoutMessage) Then
		ChangeMenuItemsEnabled
		If pfMenuEditor->tb = tb Then pfMenuEditor->CloseForm
		If pfImageListEditor->tb = tb Then pfImageListEditor->CloseForm
		#ifndef __USE_GTK__
			_Delete(tb)
		#endif
		TabWindowRemovedCheck(pParentTabCode)
		Return True
	Else
		Return False
	End If
End Function

Function TabWindow.CloseTab(WithoutMessage As Boolean = False) As Boolean
	If txtCode.Modified AndAlso Not WithoutMessage Then
		Select Case MsgBox(ML("Want to save the file") & " """ & Caption & """?", "Visual FB Editor", mtWarning, btYesNoCancel)
		Case mrYes: Save
		Case mrNo:
		Case mrCancel: Return False
		End Select
	End If
	QuitThread Project, @This
	If Project = 0 Then
		MutexLock tlockSuggestions
		For i As Integer = lvSuggestions.ListItems.Count - 1 To 0 Step -1
			If lvSuggestions.ListItems.Item(i)->Tag = @This Then
				lvSuggestions.ListItems.Remove i
			End If
		Next
		tpSuggestions->Caption = ML("Suggestions") & IIf(lvSuggestions.ListItems.Count = 0, "", " (" & lvSuggestions.ListItems.Count & " " & ML("Pos") & ")")
		MutexUnlock tlockSuggestions
	End If
	Var ptabCode = Cast(TabControl Ptr, This.Parent)
	ptabCode->Remove(@btnClose)
	miWindow->Remove This.mi
	_Delete(This.mi)
	btnClose.FreeWnd
	ptabCode->DeleteTab(This.Index)
	If tn <> 0 AndAlso tn->ImageKey <> "Project" Then ', Will remove all project from tree
		If ptvExplorer->Nodes.IndexOf(tn) <> -1 Then
			If tn->Tag <> 0 Then _Delete(Cast(ExplorerElement Ptr, tn->Tag))
			ptvExplorer->Nodes.Remove ptvExplorer->Nodes.IndexOf(tn)
			If MainNode = tn Then
				MainNode = 0
				SetMainNode 0
			End If
		End If
	End If
	If ptabCode->SelectedTabIndex = This.Index Then
		plvProperties->Nodes.Clear
		plvEvents->Nodes.Clear
		txtLabelProperty.Text = ""
		txtLabelEvent.Text = ""
		pnlPropertyValue.Visible = False
	End If
	If ptabCode->TabCount = 0 Then pfrmMain->Caption = App.Title
	TabCtl.MoveCloseButtons ptabCode
	FreeWnd
	Return True
End Function

'Sub TabWindow.FindProceduresAndTypes

'End Sub

Sub TabWindow.FillProperties(ByRef ClassName As WString)
	If ClassName = "" Then Exit Sub
	Dim As Integer i, iIndex
	If pComps->Contains(ClassName, , , , iIndex) Then
		Dim As TypeElement Ptr te, tbi = pComps->Object(iIndex)
		If tbi Then
			i = 0
			Do While i <= tbi->Elements.Count - 1
				te = tbi->Elements.Object(i)
				If te Then
					With *te
						If .Locals = 0 Then
							If Not FPropertyItems.Contains(.Name) Then
								FPropertyItems.Add .Name, te
							End If
						End If
					End With
				End If
				i += 1
			Loop
			FillProperties tbi->TypeName
		End If
	End If
End Sub

Function GetPropertyType(ClassName As String, PropertyName As String) As TypeElement Ptr
	Dim iIndex As Integer
	Dim Pos2 As Integer
	Dim tbi As TypeElement Ptr
	Dim te As TypeElement Ptr
	Dim TypeN As String = WithoutPointers(ClassName)
	If InStr(TypeN, ".") AndAlso TypeN <> "My.Sys.Object" Then TypeN = Mid(TypeN, InStrRev(TypeN, ".") + 1)
	If pComps->Contains(TypeN, , , , iIndex) Then
		tbi = pComps->Object(iIndex)
		If tbi Then
			Pos2 = InStr(PropertyName, ".")
			If Pos2 > 0 Then
				te = GetPropertyType(TypeN, ..Left(PropertyName, Pos2 - 1))
				If te <> 0 Then Return GetPropertyType(te->TypeName, Mid(PropertyName, Pos2 + 1))
			Else
				iIndex = tbi->Elements.IndexOf(PropertyName)
				If iIndex <> -1 Then
					Return Cast(TypeElement Ptr, tbi->Elements.Object(iIndex))
				ElseIf tbi->TypeName <> "" Then
					Return GetPropertyType(tbi->TypeName, PropertyName)
				Else
					Return 0
				End If
			End If
		End If
	End If
	Return 0
End Function

Function IsBase(ByRef TypeName As String, ByRef BaseName As String, tb As TabWindow Ptr = 0) As Boolean
	Dim iIndex As Integer
	Dim tbi As TypeElement Ptr
	Dim As WStringOrStringListItem Ptr ListItem
	Dim TypeN As String = WithoutPointers(TypeName)
	If TypeName = BaseName Then Return True
	If InStr(TypeN, ".") AndAlso TypeN <> "My.Sys.Object" Then TypeN = Mid(TypeN, InStrRev(TypeN, ".") + 1)
	If pComps->Contains(TypeN, , , , iIndex) Then
		tbi = pComps->Object(iIndex)
		If tbi Then
			If tbi->TypeName = BaseName Then
				Return True
			ElseIf tbi->TypeName = "My.Sys.Object" AndAlso BaseName = "Object" Then
				Return True
			ElseIf tbi->TypeName <> "" Then
				Return IsBase(tbi->TypeName, BaseName, tb)
			Else
				Return False
			End If
		End If
	ElseIf tb Then
		If tb->txtCode.Content.Types.Contains(TypeN, , , , iIndex) Then
			tbi = tb->txtCode.Content.Types.Object(iIndex)
			If tbi Then
				If tbi->TypeName = BaseName Then
					Return True
				ElseIf tbi->TypeName = "My.Sys.Object" AndAlso BaseName = "Object" Then
					Return True
				ElseIf tbi->TypeName <> "" AndAlso (InStr(tbi->TypeName, ".") = 0 OrElse TypeN <> Mid(tbi->TypeName, InStrRev(tbi->TypeName, ".") + 1)) Then
					Return IsBase(tbi->TypeName, BaseName, tb)
				Else
					Return False
				End If
			End If
		ElseIf pGlobalTypes->Contains(TypeN, , , , iIndex, ListItem) Then
			tbi = pGlobalTypes->Object(iIndex)
			If tbi Then
				If tbi->TypeName = BaseName Then
					Return True
				ElseIf tbi->TypeName = "My.Sys.Object" AndAlso BaseName = "Object" Then
					Return True
				ElseIf tbi->TypeName <> "" AndAlso (InStr(tbi->TypeName, ".") = 0 OrElse TypeN <> Mid(tbi->TypeName, InStrRev(tbi->TypeName, ".") + 1)) Then
					Return IsBase(tbi->TypeName, BaseName, tb)
				Else
					Return False
				End If
			End If
		ElseIf pGlobalEnums->Contains(TypeN, , , , iIndex) Then
			tbi = pGlobalEnums->Object(iIndex)
			If tbi Then
				If tbi->TypeName = BaseName Then
					Return True
				ElseIf tbi->TypeName = "My.Sys.Object" AndAlso BaseName = "Object" Then
					Return True
				ElseIf tbi->TypeName <> "" Then
					Return IsBase(tbi->TypeName, BaseName, tb)
				Else
					Return False
				End If
			End If
		End If
	End If
	Return False
End Function

Function GetOriginalType(ByRef TypeName As String) As String
	Dim iIndex As Integer
	Dim tbi As TypeElement Ptr
	Dim TypeN As String = WithoutPointers(TypeName)
	If InStr(TypeN, ".") AndAlso TypeN <> "My.Sys.Object" Then TypeN = Mid(TypeN, InStrRev(TypeN, ".") + 1)
	If pComps->Contains(TypeN, , , , iIndex) Then
		tbi = pComps->Object(iIndex)
		If tbi Then
			If tbi->ElementType = E_TypeCopy Then
				Return GetOriginalType(tbi->TypeName)
			Else
				Return TypeName
			End If
		End If
	End If
	Return ""
End Function

Function TabWindow.ReadObjProperty(ByRef Obj As Any Ptr, ByRef PropertyName As String, Cpnt As Any Ptr = 0) ByRef As WString
	On Error Goto ErrorHandler
	WLet(FLine, "")
	If Des = 0 Then Return ""
	Dim As SymbolsType Ptr st = Des->Symbols(Obj)
	If st = 0 AndAlso Cpnt <> 0 Then st = Des->Symbols(Cpnt)
	If st = 0 OrElse st->ReadPropertyFunc = 0 Then Return ""
	If Obj = 0 Then Return *FLine
	te = GetPropertyType(WGet(st->ReadPropertyFunc(Obj, "ClassName")), PropertyName)
	If te = 0 Then Return *FLine
	Dim As Integer iIndex = -1
	With *te
		Select Case te->ElementType
		Case E_Event
			Var Idx = Events.IndexOfKey(PropertyName, Obj)
			If Idx <> -1 Then WLet(FLine, Events.Item(Idx)->Text)
		Case E_Property, E_Field
			Var Pos1 = InStr(PropertyName, ".")
			If Des <> 0 AndAlso st->ReadPropertyFunc <> 0 Then
				pTemp = st->ReadPropertyFunc(Obj, PropertyName)
			Else
				pTemp = 0
			End If
			If pTemp <> 0 Then
				Select Case LCase(.TypeName)
				Case "wstring", "wstring ptr", "wstringlist", "dictionary", "point", "size": WLet(FLine, QWString(pTemp))
				Case "string", "zstring": WLet(FLine, QZString(pTemp))
				Case "any", "any ptr": If AnyTexts.ContainsObject(pTemp) Then WLet(FLine, AnyTexts.Item(AnyTexts.IndexOfObject(pTemp))) Else WLet(FLine, "")
				Case "control ptr", "control": WLet(FLine, QWString(st->ReadPropertyFunc(pTemp, "Name")))
				Case "integer": iTemp = QInteger(pTemp)
					WLet(FLine, WStr(iTemp))
					If (te->EnumTypeName <> "") AndAlso CInt(pGlobalEnums->Contains(te->EnumTypeName, , , , iIndex)) Then
						tbi = pGlobalEnums->Object(iIndex)
						If tbi Then
							Dim As TypeElement Ptr te1
							For i As Integer = 0 To tbi->Elements.Count - 1
								te1 = tbi->Elements.Object(i)
								If te1 <> 0 AndAlso te1->Value = Str(iTemp) Then iTemp = i: Exit For
							Next
							If iTemp >= 0 AndAlso iTemp <= tbi->Elements.Count - 1 Then WLet(FLine, WStr(iTemp) & " - " & tbi->Elements.Item(iTemp))
						End If
					End If
				Case "long": iTemp = QLong(pTemp): WLet(FLine, WStr(iTemp))
				Case "ulong": iTemp = QULong(pTemp): WLet(FLine, WStr(iTemp))
				Case "single": iTemp = QSingle(pTemp): WLet(FLine, WStr(iTemp))
				Case "double": iTemp = QDouble(pTemp): WLet(FLine, WStr(iTemp))
				Case "boolean": WLet(FLine, WStr(QBoolean(pTemp)))
				Case Else:
					If IsBase(.TypeName, "My.Sys.Object") AndAlso CInt(st->ToStringFunc <> 0) Then
						WLet(FLine, st->ToStringFunc(pTemp))
					ElseIf pGlobalEnums->Contains(.TypeName, , , , iIndex) Then
						iTemp = QInteger(pTemp)
						tbi = pGlobalEnums->Object(iIndex)
						If tbi Then
							Dim As TypeElement Ptr te1
							For i As Integer = 0 To tbi->Elements.Count - 1
								te1 = tbi->Elements.Object(i)
								If te1 <> 0 AndAlso te1->Value = Str(iTemp) Then iTemp = i: Exit For
							Next
							If iTemp >= 0 AndAlso iTemp <= tbi->Elements.Count - 1 Then WLet(FLine, WStr(iTemp) & " - " & tbi->Elements.Item(iTemp))
						End If
					End If
				End Select
			ElseIf Pos1 > 0 Then
				te = GetPropertyType(WGet(st->ReadPropertyFunc(Obj, "ClassName")), ..Left(PropertyName, Pos1 - 1))
				If te = 0 Then Return *FLine
				If IsBase(te->TypeName, "My.Sys.Object") Then
					If Des <> 0 AndAlso st->ReadPropertyFunc <> 0 Then
						Return ReadObjProperty(st->ReadPropertyFunc(Obj, ..Left(PropertyName, Pos1 - 1)), Mid(PropertyName, Pos1 + 1), IIf(Cpnt = 0, Obj, Cpnt))
					End If
				End If
			ElseIf IsBase(.TypeName, "Component") Then
				WLet(FLine, ML("(None)"))
			End If
		End Select
	End With
	Return *FLine
	'End If
	Exit Function
	ErrorHandler:
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " " & _
	"in function " & ZGet(Erfn()) & " " & _
	"in module " & ZGet(Ermn())
End Function

Function TabWindow.GetFormattedPropertyValue(ByRef Obj As Any Ptr, ByRef PropertyName As String, Cpnt As Any Ptr = 0) ByRef As WString
	On Error Goto ErrorHandler
	WLet(FLine, "")
	If Obj = 0 Then Return *FLine
	If Des = 0 Then Return *FLine
	Dim As SymbolsType Ptr st = Des->Symbols(Obj)
	If st = 0 AndAlso Cpnt <> 0 Then st = Des->Symbols(Cpnt)
	If st = 0 OrElse st->ReadPropertyFunc = 0 Then Return *FLine
	Dim As Integer Pos1, iIndex = -1
	Pos1 = InStr(PropertyName, ".")
	pTemp = st->ReadPropertyFunc(Obj, PropertyName)
	Dim As TypeElement Ptr tbi, te = GetPropertyType(WGet(st->ReadPropertyFunc(Obj, "ClassName")), PropertyName)
	If te = 0 Then Return *FLine
	With *te
		If pTemp <> 0 Then
			Select Case LCase(.TypeName)
			Case "wstring", "string", "zstring", "wstringlist", "dictionary"
				WLet(FLine, QWString(pTemp))
				If Len(Trim(*FLine)) > 1 AndAlso StartsWith(*FLine, "=") Then
					WLetEx FLine, Mid(*FLine, 2), True
				Else
					WLetEx FLine, """" & Replace(*FLine, """", """""") & """", True
				End If
			Case "point"
				WLetEx FLine, "Type<My.Sys.Drawing.Point>(" & QWString(pTemp) & ")", True
			Case "size"
				WLetEx FLine, "Type<My.Sys.Drawing.Size>(" & QWString(pTemp) & ")", True
			Case "any", "any ptr"
				If AnyTexts.ContainsObject(pTemp) Then WLet(FLine, AnyTexts.Item(AnyTexts.IndexOfObject(pTemp))) Else WLet(FLine, "")
				If Len(Trim(*FLine)) > 1 AndAlso StartsWith(*FLine, "=") Then
					WLetEx FLine, Mid(*FLine, 2), True
				Else
					WLetEx FLine, "@""" & Replace(*FLine, """", """""") & """", True
				End If
			Case "icon", "bitmaptype", "cursor", "graphictype": If st->ToStringFunc <> 0 Then WLet(FLine, """" & st->ToStringFunc(pTemp) & """")
			Case "integer": iTemp = QInteger(pTemp)
				WLet(FLine, WStr(iTemp))
				If (te->EnumTypeName <> "") AndAlso CInt(pGlobalEnums->Contains(te->EnumTypeName, , , , iIndex)) Then
					tbi = pGlobalEnums->Object(iIndex)
					If tbi Then
						Dim As TypeElement Ptr te1
						For i As Integer = 0 To tbi->Elements.Count - 1
							te1 = tbi->Elements.Object(i)
							If te1 <> 0 AndAlso te1->Value = Str(iTemp) Then iTemp = i: Exit For
						Next
						If iTemp >= 0 AndAlso iTemp <= tbi->Elements.Count - 1 Then WLet(FLine, te->EnumTypeName & "." & tbi->Elements.Item(iTemp))
					End If
				End If
			Case "long": iTemp = QLong(pTemp): WLet(FLine, WStr(iTemp))
			Case "ulong": iTemp = QULong(pTemp): WLet(FLine, WStr(iTemp))
			Case "single": iTemp = QSingle(pTemp): WLet(FLine, WStr(iTemp))
			Case "double": iTemp = QDouble(pTemp): WLet(FLine, WStr(iTemp))
			Case "boolean": WLet(FLine, WStr(QBoolean(pTemp)))
			Case Else
				If pGlobalEnums->Contains(.TypeName, , , , iIndex) Then
					tbi = pGlobalEnums->Object(iIndex)
					iTemp = QInteger(pTemp)
					If tbi Then
						Dim As TypeElement Ptr te1
						For i As Integer = 0 To tbi->Elements.Count - 1
							te1 = tbi->Elements.Object(i)
							If te1 <> 0 AndAlso te1->Value = Str(iTemp) Then iTemp = i: Exit For
						Next
						If iTemp >= 0 AndAlso iTemp <= tbi->Elements.Count - 1 Then WLet(FLine, te->TypeName & "." & tbi->Elements.Item(iTemp))
					End If
				ElseIf IsBase(.TypeName, "Component") Then
					Dim As String pTempName = WGet(st->ReadPropertyFunc(pTemp, "Name"))
					If pTempName <> "" Then
						iIndex = cboClass.Items.IndexOf(pTempName)
						If iIndex <> -1 OrElse PropertyName = "ParentMenu" Then
							WLet(FLine, "@" & pTempName)
							If iIndex = 1 Then
								WLet(FLine, "@This")
							End If
						End If
					End If
				End If
			End Select
		ElseIf Pos1 > 0 Then
			te = GetPropertyType(WGet(st->ReadPropertyFunc(Obj, "ClassName")), ..Left(PropertyName, Pos1 - 1))
			If te = 0 Then Return *FLine
			If IsBase(te->TypeName, "My.Sys.Object") Then
				If st <> 0 AndAlso st->ReadPropertyFunc <> 0 Then
					Return GetFormattedPropertyValue(st->ReadPropertyFunc(Obj, ..Left(PropertyName, Pos1 - 1)), Mid(PropertyName, Pos1 + 1), IIf(Cpnt = 0, Obj, Cpnt))
				End If
			End If
		ElseIf IsBase(.TypeName, "Component") Then
			WLet(FLine, "0")
		End If
	End With
	Return *FLine
	Exit Function
	ErrorHandler:
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " " & _
	"in function " & ZGet(Erfn()) & " " & _
	"in module " & ZGet(Ermn())
End Function

Function TabWindow.WriteObjProperty(ByRef Obj As Any Ptr, ByRef PropertyName As String, ByRef Value As WString, FromText As Boolean = False, Cpnt As Any Ptr = 0) As Boolean
	If Obj = 0 Then Return False
	If Des = 0 Then Return False
	Dim As SymbolsType Ptr st = Des->Symbols(Obj)
	If st = 0 AndAlso Cpnt <> 0 Then st = Des->Symbols(Cpnt)
	If st = 0 OrElse st->ReadPropertyFunc = 0 Then Return False
	Dim Result As Boolean
	Dim As Integer iIndex = -1,  Pos1 = InStr(PropertyName, ".")
	Dim As TypeElement Ptr tbi, te = GetPropertyType(WGet(st->ReadPropertyFunc(Obj, "ClassName")), PropertyName)
	If te <> 0 Then
		WLet(FLine3, Value)
		#ifndef __USE_GTK__
			Dim hwnd1 As HWND
			Dim hTemp As Any Ptr
			If st <> 0 AndAlso st->ReadPropertyFunc <> 0 Then hTemp = st->ReadPropertyFunc(Obj, "Handle")
			If hTemp Then hwnd1 = *Cast(HWND Ptr, hTemp)
		#endif
		Select Case te->ElementType
		Case E_Event
			Dim EventName As String
			If StartsWith(Value, "@") Then
				EventName = Mid(Value, 2)
			ElseIf StartsWith(LCase(Value), "cast(sub(byref designer as my.sys.object,") Then
				Var Pos1 = InStr(Value, "@")
				EventName = Trim(Mid(Value, Pos1 + 1))
				EventName = ..Left(EventName, Len(EventName) - 1)
			Else
				EventName = Value
			End If
			iIndex = Events.IndexOfKey(PropertyName, Obj)
			If iIndex <> -1 Then
				Events.Item(iIndex)->Text = EventName
			Else
				Events.Add PropertyName, EventName, Obj
			End If
		Case E_Property, E_Field
			Select Case LCase(te->TypeName)
			Case "wstring", "string", "zstring", "icon", "cursor", "bitmaptype", "graphictype", "wstringlist", "dictionary"
				'?"VFE2:" & *FLine
				If FromText Then
					If StartsWith(*FLine3, """") AndAlso EndsWith(*FLine3, """") Then
						WLet(FLine4, Replace(Mid(*FLine3, 2, Len(*FLine3) - 2), """""", """"))
						'WLet(FLine3, *FLine4)
					Else
						WLet(FLine4, "=" & *FLine3)
					End If
				Else
					WLet(FLine4, *FLine3)
				End If
				'WLetEx FLine4, Replace(*FLine3, """""", """"), True
				'WLetEx FLine4, *FLine3, True
				'?"VFE3:" & *FLine
				If Des <> 0 AndAlso st->WritePropertyFunc <> 0 Then
					Result = st->WritePropertyFunc(Obj, PropertyName, Cast(Any Ptr, FLine4))
				End If
				'            Case "control ptr", "control pointer"
				'                If LCase(*FLine2) = "this" Then
				'                    Result = Cpnt->WriteProperty(PropertyName, frmForm)
				'                ElseIf cboClass.Items.Contains(*FLine2) Then
				'                    PropertyCtrl = Cast(Any Ptr, cboClass.Items.Item(cboClass.Items.IndexOf(*FLine2))->Object)
				'                    Result = Cpnt->WriteProperty(PropertyName, PropertyCtrl)
				'                End If
				Select Case LCase(te->TypeName)
				Case "icon", "cursor", "bitmaptype", "graphictype": SetGraphicProperty Obj, PropertyName, te->TypeName, *FLine4
				Case Else
					If PropertyName = "ImageKey" Then SetGraphicProperty Obj, "Image", "BitmapType", *FLine4
				End Select
			Case "any", "any ptr"
				Dim As WString Ptr FLine5
				If FromText Then
					If StartsWith(*FLine3, "@""") AndAlso EndsWith(*FLine3, """") Then
						WLet(FLine5, Replace(Mid(*FLine3, 3, Len(*FLine3) - 3), """""", """"))
					ElseIf StartsWith(*FLine3, """") AndAlso EndsWith(*FLine3, """") Then
						WLet(FLine5, Replace(Mid(*FLine3, 2, Len(*FLine3) - 2), """""", """"))
					Else
						WLet(FLine5, "=" & *FLine3)
					End If
				Else
					WLet(FLine5, *FLine3)
				End If
				Dim As Boolean bContains
				If AnyTexts.ContainsObject(FLine5) Then AnyTexts.Item(AnyTexts.IndexOfObject(FLine5)) = *FLine5: bContains = True Else AnyTexts.Add *FLine5, FLine5
				If st <> 0 AndAlso st->WritePropertyFunc <> 0 Then Result = st->WritePropertyFunc(Obj, PropertyName, Cast(Any Ptr, FLine5))
				If bContains Then WDeAllocate(FLine5)
			Case "integer", "long", "ulong", "single", "double"
				iTemp = Val(*FLine3)
				If (te->EnumTypeName <> "") AndAlso CInt(pGlobalEnums->Contains(te->EnumTypeName, , , , iIndex)) Then
					tbi = pGlobalEnums->Object(iIndex)
					If tbi Then
						If tbi->Elements.Contains(*FLine3, , , , iIndex) Then
							iTemp = iIndex
						ElseIf StartsWith(*FLine3, te->EnumTypeName & ".") AndAlso tbi->Elements.Contains(Mid(*FLine3, Len(Trim(te->EnumTypeName)) + 2), , , , iIndex) Then
							iTemp = iIndex
						End If
						If iTemp > -1 Then
							Dim As TypeElement Ptr te1 = tbi->Elements.Object(iTemp)
							If te1 <> 0 AndAlso te1->Value <> "" Then
								iTemp = Val(te1->Value)
							End If
						End If
					End If
				End If
				If Des <> 0 AndAlso st->WritePropertyFunc <> 0 Then
					Select Case LCase(te->TypeName)
					Case "integer"
						Dim As Integer intTemp = iTemp
						Result = st->WritePropertyFunc(Obj, PropertyName, Cast(Any Ptr, @intTemp))
					Case "long"
						Dim As Long iTemp = Val(*FLine3)
						Result = st->WritePropertyFunc(Obj, PropertyName, Cast(Any Ptr, @iTemp))
					Case "ulong"
						Dim As ULong iTemp = Val(*FLine3)
						Result = st->WritePropertyFunc(Obj, PropertyName, Cast(Any Ptr, @iTemp))
					Case "double"
						Dim As Double iTemp = Val(*FLine3)
						Result = st->WritePropertyFunc(Obj, PropertyName, Cast(Any Ptr, @iTemp))
					Case "single"
						Dim As Single iTemp = Val(*FLine3)
						Result = st->WritePropertyFunc(Obj, PropertyName, Cast(Any Ptr, @iTemp))
					End Select
				End If
			Case "boolean"
				bTemp = Cast(Boolean, Trim(*FLine3))
				If Des <> 0 AndAlso st->WritePropertyFunc <> 0 Then
					Result = st->WritePropertyFunc(Obj, PropertyName, Cast(Any Ptr, @bTemp))
				End If
			Case Else:
				If pGlobalEnums->Contains(te->TypeName, , , , iIndex) Then
					tbi = pGlobalEnums->Object(pGlobalEnums->IndexOf(te->TypeName))
					If tbi Then
						Dim iTemp As Integer
						iTemp = Val(*FLine3)
						If tbi->Elements.Contains(*FLine3, , , , iIndex) Then
							iTemp = iIndex
						ElseIf StartsWith(*FLine3, te->TypeName & ".") AndAlso tbi->Elements.Contains(Mid(*FLine3, Len(Trim(te->TypeName)) + 2), , , , iIndex) Then
							iTemp = iIndex
						End If
						If iTemp > -1 Then
							Dim As TypeElement Ptr te1 = tbi->Elements.Object(iTemp)
							If te1 <> 0 AndAlso te1->Value <> "" Then
								iTemp = Val(te1->Value)
							End If
						End If
						If st <> 0 AndAlso st->WritePropertyFunc <> 0 AndAlso iTemp > -1 Then
							Result = st->WritePropertyFunc(Obj, PropertyName, Cast(Any Ptr, @iTemp))
						End If
					End If
				Else
					If StartsWith(*FLine3, "@") Then WLetEx(FLine3, Mid(*FLine3, 2), True)
					If st AndAlso LCase(*FLine3) = "this" Then
						Dim hTemp As Any Ptr
						If st->ReadPropertyFunc <> 0 Then hTemp = st->ReadPropertyFunc(Des->DesignControl, "Name")
						If hTemp <> 0 Then WLet(FLine3, QWString(hTemp))
					End If
					If *FLine3 <> "" Then
						iIndex = cboClass.Items.IndexOf(Trim(*FLine3))
						If iIndex <> -1 Then
							PropertyCtrl = Cast(Any Ptr, cboClass.Items.Item(iIndex)->Object)
							If Des <> 0 AndAlso st->WritePropertyFunc <> 0 Then
								Var te = GetPropertyType(QWString(st->ReadPropertyFunc(Obj, "ClassName")), PropertyName)
								If te <> 0 Then
									Dim As String PropertyType = GetOriginalType(te->TypeName)
									Dim As String PropertyCtrlType = QWString(st->ReadPropertyFunc(PropertyCtrl, "ClassName"))
									If IsBase(PropertyCtrlType, PropertyType) Then
										Result = st->WritePropertyFunc(Obj, PropertyName, PropertyCtrl)
									Else
										MsgBox "Unable set property " & PropertyName & " with type " & PropertyType & " of " & QWString(st->ReadPropertyFunc(Cpnt, "Name")) & " to " & QWString(st->ReadPropertyFunc(PropertyCtrl, "Name")) & " with type " & PropertyCtrlType
									End If
								End If
							End If
						ElseIf Trim(*FLine3) = ML("(None)") Then
							If st <> 0 AndAlso st->WritePropertyFunc <> 0 Then Result = st->WritePropertyFunc(Obj, PropertyName, 0)
						Else
							Dim Pos1 As Integer = InStr(*FLine3, ".")
							If Pos1 > 0 Then
								iIndex = cboClass.Items.IndexOf(Trim(..Left(*FLine3, Pos1 - 1)))
								If iIndex > -1 Then
									PropertyCtrl = Cast(Any Ptr, cboClass.Items.Item(iIndex)->Object)
									Dim As Any Ptr Ctrl2 = st->ReadPropertyFunc(PropertyCtrl, Trim(Mid(*FLine3, Pos1 + 1)))
									If Ctrl2 <> 0 AndAlso st->WritePropertyFunc <> 0 Then
										Var te = GetPropertyType(QWString(st->ReadPropertyFunc(Obj, "ClassName")), PropertyName)
										If te <> 0 Then
											Dim As String PropertyType = GetOriginalType(te->TypeName)
											Dim As String PropertyCtrlType = QWString(st->ReadPropertyFunc(PropertyCtrl, "ClassName"))
											If IsBase(PropertyCtrlType, PropertyType) Then
												Result = st->WritePropertyFunc(Obj, PropertyName, Ctrl2)
											Else
												MsgBox "Unable set property " & PropertyName & " with type " & PropertyType & " of " & QWString(st->ReadPropertyFunc(Obj, "Name")) & " to " & QWString(st->ReadPropertyFunc(PropertyCtrl, "Name")) & " with type " & PropertyCtrlType
											End If
										End If
									End If
								End If
							End If
						End If
					End If
				End If
			End Select
		End Select
		#ifndef __USE_GTK__
			Dim hwnd2 As HWND
			If hTemp Then hwnd2 = *Cast(HWND Ptr, hTemp)
			If hwnd1 <> hwnd2 Then
				If Des AndAlso hwnd1 = Des->Dialog Then
					Des->Dialog = hwnd2
				End If
			End If
		#endif
	End If
	If CInt(Pos1 > 0) AndAlso CInt(Result = False) Then
		te = GetPropertyType(WGet(st->ReadPropertyFunc(Obj, "ClassName")), ..Left(PropertyName, Pos1 - 1))
		If te = 0 Then Return False
		If IsBase(te->TypeName, "My.Sys.Object") Then
			If Des <> 0 AndAlso st->ReadPropertyFunc <> 0 Then
				Return WriteObjProperty(st->ReadPropertyFunc(Obj, ..Left(PropertyName, Pos1 - 1)), Mid(PropertyName, Pos1 + 1), Value, , IIf(Cpnt = 0, Obj, Cpnt))
			End If
		Else
			Return False
		End If
	End If
	Return Result
End Function

Function GetTypeIsPointer(te As TypeElement Ptr) As Boolean
	If Not te->TypeIsPointer Then
		Dim iIndex As Integer
		Dim tbi As TypeElement Ptr
		Dim TypeN As String = WithoutPointers(te->TypeName)
		If InStr(TypeN, ".") AndAlso TypeN <> "My.Sys.Object" Then TypeN = Mid(TypeN, InStrRev(TypeN, ".") + 1)
		If pComps->Contains(TypeN, , , , iIndex) Then
			tbi = pComps->Object(iIndex)
			If tbi Then
				If tbi->ElementType = E_TypeCopy Then
					Return GetTypeIsPointer(tbi)
				End If
			End If
		End If
	End If
	Return te->TypeIsPointer
End Function

Sub TabWindow.FillAllProperties()
	If Des = 0 OrElse Des->SelectedControl = 0 Then Exit Sub
	ptabRight->Tag = @This
	ptabRight->UpdateLock
	cboFunction.Items.Clear
	If cboClass.ItemIndex = 0 Then
		cboFunction.Items.Add WStr("(") & ML("Declarations") & ")" & WChr(0), , "Sub", "Sub"
	Else
		cboFunction.Items.Add "(" & ML("Events") & ")", , "Event", "Event"
	End If
	cboFunction.ItemIndex = 0
	plvProperties->Nodes.Clear
	plvEvents->Nodes.Clear
	Dim SelCount As Integer = Des->SelectedControls.Count
	Dim OnlySelected As Boolean = Not Des->SelectedControls.Contains(Des->SelectedControl)
	If OnlySelected Then SelCount = 1
	Dim As WStringList FPropertyItemsAll
	Dim As UString ItemText
	For i As Integer = 0 To SelCount - 1
		FPropertyItems.Clear
		If OnlySelected Then
			Dim As SymbolsType Ptr st = Des->Symbols(Des->SelectedControl)
			If st AndAlso st->ReadPropertyFunc Then FillProperties WGet(st->ReadPropertyFunc(Des->SelectedControl, "ClassName"))
		Else
			Dim As SymbolsType Ptr st = Des->Symbols(Des->SelectedControls.Item(i))
			If st AndAlso st->ReadPropertyFunc Then FillProperties WGet(st->ReadPropertyFunc(Des->SelectedControls.Item(i), "ClassName"))
		End If
		If SelCount > 1 Then
			For lvPropertyCount As Integer = 0 To FPropertyItems.Count - 1
				FPropertyItemsAll.Add FPropertyItems.Item(lvPropertyCount)
			Next
		End If
	Next i
	FPropertyItems.Sort
	For lvPropertyCount As Integer = 0 To FPropertyItems.Count - 1
		ItemText = ReadObjProperty(Des->SelectedControl, FPropertyItems.Item(lvPropertyCount))
		If SelCount > 1 Then
			If LCase(FPropertyItems.Item(lvPropertyCount)) = "name" OrElse LCase(FPropertyItems.Item(lvPropertyCount)) = "id" Then Continue For
			If FPropertyItemsAll.CountOf(FPropertyItems.Item(lvPropertyCount)) <> SelCount Then Continue For
			If ItemText <> "" Then
				For i As Integer = 0 To SelCount - 1
					If ReadObjProperty(Des->SelectedControls.Item(i), FPropertyItems.Item(lvPropertyCount)) <> ItemText Then
						ItemText = ""
						Exit For
					End If
				Next i
			End If
		End If
		'If Instr(FPropertyItems.Item(lvPropertyCount), ".") Then Continue For
		te = FPropertyItems.Object(lvPropertyCount)
		If te = 0 Then Continue For
		With *te
			If CInt(LCase(.Name) <> "handle") AndAlso CInt(LCase(.TypeName) <> "hwnd") AndAlso CInt(LCase(.TypeName) <> "jobject") AndAlso CInt(LCase(.TypeName) <> "gtkwidget") AndAlso (CInt(.ElementType = E_Property) OrElse CInt(.ElementType = E_Field)) Then
				If plvProperties->Nodes.Count <= lvPropertyCount Then
					Dim As Boolean iBool = pComps->Contains(.TypeName)
					Dim As Boolean TypeIsPointer = GetTypeIsPointer(te)
					lvItem = plvProperties->Nodes.Add(FPropertyItems.Item(lvPropertyCount), 2, IIf(TypeIsPointer = False AndAlso iBool, 1, 0))
					If TypeIsPointer = False AndAlso iBool Then lvItem->Nodes.Add
				Else
					lvItem = plvProperties->Nodes.Item(lvPropertyCount)
					lvItem->Text(0) = FPropertyItems.Item(lvPropertyCount)
					lvItem->Text(1) = ""
				End If
				lvItem->Text(1) = ItemText 'ReadObjProperty(Des->SelectedControl, FPropertyItems.Item(lvPropertyCount))
			ElseIf .ElementType = E_Event Then
				cboFunction.Items.Add .Name, , "Event", "Event"
				lvItem = plvEvents->Nodes.Add(.Name, 3)
				lvItem->Text(1) = ReadObjProperty(Des->SelectedControl, .Name)
				'If *Ctrl Is Control Then
				'    cboFunction.Items.Add .Name & "NS", , "Sub", "Sub", , 1
				'End If
			End If
		End With
	Next
	'cboFunction.Items.Sort
	'lvProperties.ListItems.Sort
	'lvEvents.ListItems.Sort
	ptabRight->UpdateUnLock
End Sub

Sub DesignerChangeSelection(ByRef Sender As Designer, Ctrl As Any Ptr, iLeft As Integer = -1, iTop As Integer = -1, iWidth As Integer = -1, iHeight As Integer = -1)
	Static SelectedCtrl As Any Ptr
	Static SelectedCount As Integer
	If Ctrl = 0 Then Exit Sub
	Dim tb As TabWindow Ptr = Sender.Tag
	If tb = 0 Then Exit Sub
	If tb->Des = 0 Then Exit Sub
	If SelectedCtrl = Ctrl AndAlso SelectedCount = Sender.SelectedControls.Count AndAlso tb->cboClass.ItemIndex <> 0 AndAlso lvProperties.Nodes.Count <> 0 Then Exit Sub
	'tb->Des->SelectedControl = Ctrl
	SelectedCtrl = Ctrl
	SelectedCount = Sender.SelectedControls.Count
	bNotFunctionChange = True
	If tb->Des->Symbols(Ctrl) AndAlso tb->Des->Symbols(Ctrl)->ReadPropertyFunc <> 0 Then
		Dim As String SelControlName = WGet(tb->Des->Symbols(Ctrl)->ReadPropertyFunc(Ctrl, "Name"))
		Dim As String SelControlNames = SelControlName
		tb->cboClass.ItemIndex = tb->cboClass.Items.IndexOf(SelControlName)
		For i As Integer = 0 To SelectedCount - 1
			If Sender.SelectedControls.Item(i) = Sender.SelectedControl Then Continue For
			SelControlNames = SelControlNames & ", " & WGet(tb->Des->Symbols(Sender.SelectedControls.Item(i))->ReadPropertyFunc(Sender.SelectedControls.Item(i), "Name"))
		Next
		tbProperties.Buttons.Item("SelControlName")->Caption = SelControlNames
		tbEvents.Buttons.Item("SelControlName")->Caption = SelControlNames
	End If
	tb->FillAllProperties
	If Sender.SelectedControls.Contains(Sender.SelectedControl) Then
		tb->pnlForm.SetFocus
	End If
	bNotFunctionChange = False
End Sub

Sub GetControls(Des As Designer Ptr, ByRef lst As List, Ctrl As Any Ptr)
	lst.Add Ctrl
	Dim As SymbolsType Ptr st = Des->Symbols(Ctrl)
	If Des->Controls.Contains(Ctrl) Then
		If st AndAlso st->ReadPropertyFunc AndAlso st->ControlByIndexFunc Then
			Dim j As Integer Ptr = st->ReadPropertyFunc(Ctrl, "ControlCount")
			If j <> 0 Then
				For i As Integer = 0 To *j - 1
					GetControls Des, lst, st->ControlByIndexFunc(Ctrl, i)
				Next
			End If
		End If
	End If
End Sub

Sub CheckBi(ByRef ptxtCode As EditControl Ptr, ByRef txtCodeBi As EditControl, ByRef ptxtCodeBi As EditControl Ptr, tb As TabWindow Ptr)
	If ptxtCode = @txtCodeBi Then
		Var tb1 = AddTab(..Left(tb->FileName, Len(tb->FileName) - 4) & ".bi", , , True)
		If tb1>0 Then
			tb->SelectTab
			ptxtCode = @tb1->txtCode
			ptxtCodeBi = ptxtCode
			ptxtCodeBi->Changing "Unsur qo`shish"
		Else
			MsgBox ML("Memory was not allocated")
		End If
	End If
End Sub

Sub GetBiFile(ByRef ptxtCode As EditControl Ptr, ByRef txtCodeBi As EditControl, ByRef ptxtCodeBi As EditControl Ptr, tb As TabWindow Ptr, IsBas As Boolean, ByRef bFind As Boolean, i As Integer, ByRef iStart As Integer, ByRef iEnd As Integer)
	If tb = 0 OrElse tb->txtCode.LinesCount < 1 Then Exit Sub
	If CInt(IsBas) AndAlso CInt(Not bFind) AndAlso CInt(StartsWith(Trim(LCase(tb->txtCode.Lines(i)), Any !"\t "), "#include once """ & LCase(GetFileName(..Left(tb->FileName, Len(tb->FileName) - 4) & ".bi")) & """")) Then
		Var tbBi = GetTab(..Left(tb->FileName, Len(tb->FileName) - 4) & ".bi")
		Dim FileEncoding As FileEncodings, NewLineType As NewLineTypes
		bFind = True
		If tbBi Then
			ptxtCode = @tbBi->txtCode
			ptxtCodeBi = ptxtCode
		Else
			txtCodeBi.LoadFromFile(..Left(tb->FileName, Len(tb->FileName) - 4) & ".bi", FileEncoding, NewLineType)
			ptxtCode = @txtCodeBi
		End If
		iStart = 0
		iEnd = ptxtCode->LinesCount - 1
	Else
		ptxtCode = @tb->txtCode
		iStart = i
		iEnd = i
	End If
End Sub

Sub DesignerBringToFront(ByRef Sender As Designer, Ctrl As Any Ptr)
	Sender.BringToFront
	Dim tb As TabWindow Ptr = Sender.Tag
	If tb = 0 OrElse Ctrl = 0 OrElse tb->Des = 0 Then Exit Sub
End Sub

Sub DesignerSendToBack(ByRef Sender As Designer, Ctrl As Any Ptr)
	Sender.SendToBack
End Sub

Sub DesignerDeleteControl(ByRef Sender As Designer, Ctrl As Any Ptr)
	Dim tb As TabWindow Ptr = Sender.Tag
	If tb = 0 Then Exit Sub
	If tb->Des = 0 Then Exit Sub
	If tb->Des->DesignControl = 0 Then Exit Sub
	If Ctrl = 0 Then Exit Sub
	Dim FLine As WString Ptr
	Dim frmName As WString * 100
	Dim frmTypeName As WString * 100
	Dim CtrlName As WString * 100
	Dim CtrlNameNew As WString * 100
	Dim As SymbolsType Ptr stDesignControl = tb->Des->Symbols(tb->Des->DesignControl)
	Dim As SymbolsType Ptr st = tb->Des->Symbols(Ctrl)
	If stDesignControl = 0 OrElse stDesignControl->ReadPropertyFunc = 0 Then Exit Sub
	If st = 0 OrElse st->ReadPropertyFunc = 0 Then Exit Sub
	frmName = WGet(stDesignControl->ReadPropertyFunc(tb->Des->DesignControl, "Name"))
	CtrlName = WGet(st->ReadPropertyFunc(Ctrl, "Name"))
	Dim ECLine As EditControlLine Ptr
	Var b = False
	Var w = False
	Var s = 0
	Dim As EditControl Ptr ptxtCode, ptxtCodeBi
	Dim As EditControl txtCodeBi
	Dim As Boolean bFind, IsBas = EndsWith(LCase(tb->FileName), ".bas") OrElse EndsWith(LCase(tb->FileName), ".frm")
	Dim As Integer iStart, iEnd, i = 0, k
	tb->txtCode.Changing "Unsurni o`chirish"
	'tb->txtCode.SaveToFile(GetBakFileName(tb->FileName), tb->FileEncoding, tb->NewLineType)
	'tb->AutoSaveCharCount = 0
	Do While i < tb->txtCode.LinesCount - 1
		GetBiFile(ptxtCode, txtCodeBi, ptxtCodeBi, tb, IsBas, bFind, i, iStart, iEnd)
		k = iStart
		Do While k <= iEnd
			WLet(FLine, Trim(LCase(ptxtCode->Lines(k)), Any !"\t "))
			If Not b AndAlso (StartsWith(*FLine, "type " & LCase(frmName) & " ") OrElse StartsWith(*FLine, "class " & LCase(frmName) & " ")) Then
				b = True
				frmTypeName = frmName
			ElseIf Not b AndAlso (StartsWith(*FLine, "type " & LCase(frmName & "Type ")) OrElse StartsWith(*FLine, "class " & LCase(frmName & "Type "))) Then
				b = True
				frmTypeName = frmName & "Type"
			ElseIf b AndAlso (StartsWith(*FLine & " ", "end type ") OrElse StartsWith(*FLine & " ", "end class ") OrElse StartsWith(*FLine & " ", "__startofclassbody__ ")) Then
				s = k
				Exit Do, Do
			ElseIf b AndAlso StartsWith(*FLine, "dim as ") Then
				If StartsWith(*FLine, "dim as " & LCase(WGet(st->ReadPropertyFunc(Ctrl, "ClassName"))) & " ") Then
					Var p = InStr(LCase(RTrim(ptxtCode->Lines(k), Any !"\t ")) & ",", " " & LCase(CtrlName) & ",")
					' ,  No Space after ","
					If p = 0 Then p = InStr(LCase(RTrim(ptxtCode->Lines(k), Any !"\t ")) & ",", "," & LCase(CtrlName) & ",")
					If p > 0 Then '
						If InStr(CtrlName,"(")>0 AndAlso InStr(CtrlName,"(0)")<1 Then ' it is Control Array
							Dim As WString Ptr Temp
							CtrlNameNew = StringExtract(CtrlName,"(")
							', Change the ubound only
							CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
							CtrlNameNew = CtrlNameNew & "(" & WStr(Val(StringExtract(CtrlName,"(",")"))-1) & ")"
							ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), p) & " " & CtrlNameNew &  Mid(ptxtCode->Lines(k), p + Len(CtrlName) + 1)
							WDeAllocate(Temp)
						Else
							If Trim(..Left(LCase(ptxtCode->Lines(k)), p), Any !"\t ") = "dim as " & LCase(WGet(st->ReadPropertyFunc(Ctrl, "ClassName"))) AndAlso Trim(Mid(ptxtCode->Lines(k), p + Len(LCase(CtrlName)) + 1), Any !"\t ") = "" Then
								CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
								ptxtCode->DeleteLine k
								k = k - 1
							ElseIf InStr(*FLine & ",", " " & LCase(CtrlName) & ",") Then
								CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
								If EndsWith(*FLine, " " & LCase(CtrlName)) Then
									ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), p - 2)
								Else
									ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), p - 1) & Mid(ptxtCode->Lines(k), p + Len(CtrlName) + 2)
								End If
								' for No Space after ","
							ElseIf InStr(*FLine & ",", "," & LCase(CtrlName) & ",") Then
								CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
								ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), p - 1) & Mid(ptxtCode->Lines(k), p + Len(CtrlName) + 1)
							End If
						End If
					End If
					If CtrlName <> frmName Then tb->cboClass.Items.Remove tb->cboClass.Items.IndexOf(CtrlName)
				End If
			End If
			k = k + 1
		Loop
		i = i + 1
	Loop
	b = False
	w = False
	Do While i < tb->txtCode.LinesCount - 1
		k = iStart
		Do While k <= IIf(ptxtCode = @tb->txtCode, i, ptxtCode->LinesCount - 1)
			WLet(FLine, Trim(LCase(ptxtCode->Lines(k)), Any !"\t "))
			If Not b AndAlso StartsWith(*FLine & " ", "constructor " & LCase(frmTypeName) & " ") Then
				b = True
			ElseIf b AndAlso StartsWith(*FLine & " ", "end constructor ") Then
				Exit Do, Do
			ElseIf b Then
				If StartsWith(*FLine & " ", "' " & LCase(CtrlName) & " ") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->DeleteLine k
					tb->ConstructorEnd -= 1
					k = k - 1
				ElseIf StartsWith(*FLine & " ", "with " & LCase(CtrlName) & " ") Then
					w = True
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->DeleteLine k
					tb->ConstructorEnd -= 1
					k = k - 1
				ElseIf w AndAlso StartsWith(*FLine & " ", "end with ") Then
					w = False
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->DeleteLine k
					tb->ConstructorEnd -= 1
					k = k - 1
				ElseIf w AndAlso StartsWith(*FLine, ".") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->DeleteLine k
					tb->ConstructorEnd -= 1
					k = k - 1
				ElseIf StartsWith(*FLine, LCase(CtrlName) & ".") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->DeleteLine k
					tb->ConstructorEnd -= 1
					k = k - 1
				End If
			End If
			k = k + 1
		Loop
		i = i + 1
		ptxtCode = @tb->txtCode
		iStart = i
		iEnd = i
	Loop
	WDeAllocate(FLine)
	bNotDesignForms = True
	ptxtCode->Changed "Unsurni o`chirish"
	If ptxtCodeBi <> 0 Then ptxtCodeBi->Changed "Unsurni o`chirish"
	bNotDesignForms = False
End Sub

Function ChangeControl(ByRef Sender As Designer, Cpnt As Any Ptr, ByRef PropertyName As WString = "", BeforeCtrl As Any Ptr = 0, AfterCtrl As Any Ptr = 0, iLeft As Integer = -1, iTop As Integer = -1, iWidth As Integer = -1, iHeight As Integer = -1) As Integer
	On Error Goto ErrorHandler
	Dim tb As TabWindow Ptr = Sender.Tag
	If tb = 0 Then Return 0
	If tb->Des = 0 Then Return 0
	If Cpnt = 0 Then Return 0
	If tb->Des->DesignControl = 0 Then Return 0
	'Dim As Integer iLeft, iTop, iWidth, iHeight
	Dim frmName As WString * 100
	Dim frmTypeName As WString * 100
	Dim CtrlName As WString * 100
	Dim CtrlNameBase As WString * 100
	Dim BeforeCtrlName As WString * 100
	Dim AfterCtrlName As WString * 100
	Dim As SymbolsType Ptr stDesignControl = tb->Des->Symbols(tb->Des->DesignControl)
	Dim As SymbolsType Ptr st = tb->Des->Symbols(Cpnt)
	Dim As SymbolsType Ptr stBeforeCtrl = tb->Des->Symbols(BeforeCtrl)
	Dim As SymbolsType Ptr stAfterCtrl = tb->Des->Symbols(AfterCtrl)
	If stDesignControl = 0 OrElse stDesignControl->ReadPropertyFunc = 0 Then Return 0
	If st = 0 OrElse st->ReadPropertyFunc = 0 Then Return 0
	frmName = WGet(stDesignControl->ReadPropertyFunc(tb->Des->DesignControl, "Name"))
	CtrlName = WGet(st->ReadPropertyFunc(Cpnt, "Name"))
	If BeforeCtrl AndAlso stBeforeCtrl AndAlso stBeforeCtrl->ReadPropertyFunc Then BeforeCtrlName = WGet(stBeforeCtrl->ReadPropertyFunc(BeforeCtrl, "Name"))
	If AfterCtrl AndAlso stAfterCtrl AndAlso stAfterCtrl->ReadPropertyFunc Then AfterCtrlName = WGet(stAfterCtrl->ReadPropertyFunc(AfterCtrl, "Name"))
	If CtrlName = frmName Then CtrlName = "This"
	Dim InsLineCount As Integer
	Dim As WStringList WithArgs
	Dim As IntegerList CuttingLines
	Dim As WString Ptr FLine, FLine1, FLine2, FLineType
	Var b = False, t = False
	Var d = False, sl = 0, tp = 0, ep = 0, j = 0, n = 0
	Dim As Integer iLeft1, iTop1, iWidth1, iHeight1
	Dim As EditControl Ptr ptxtCode, ptxtCodeBi
	Dim As EditControl txtCodeBi
	Dim As Boolean bFind, IsBas = EndsWith(LCase(tb->FileName), ".bas") OrElse EndsWith(LCase(tb->FileName), ".frm")
	Dim As Boolean bOldChangingStarted = tb->txtCode.ChangingStarted
	Dim As Integer iStart, iEnd, i, k, dj
	WLet(FLine1, "")
	For i = 0 To tb->txtCode.LinesCount - 1
		GetBiFile(ptxtCode, txtCodeBi, ptxtCodeBi, tb, IsBas, bFind, i, iStart, iEnd)
		For k As Integer = iStart To iEnd
			If ptxtCode->Lines(k) = "" Then Continue For
			' for Muilt line for the same control, sometimes No Space after ","
			WLet(FLine2, Trim(LCase(ptxtCode->Lines(k)), Any !"\t "))
			If StartsWith(*FLine2, "type " & LCase(frmName) & " ") OrElse StartsWith(*FLine2, "class " & LCase(frmName) & " ") Then
				sl = Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))
				WLet(FLineType, ..Left(ptxtCode->Lines(k), sl))
				tp = k
				b = True
				frmTypeName = frmName
			ElseIf StartsWith(*FLine2, "type " & LCase(frmName) & "type ") OrElse StartsWith(*FLine2, "class " & LCase(frmName) & "type ") Then
				sl = Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))
				WLet(FLineType, ..Left(ptxtCode->Lines(k), sl))
				tp = k
				b = True
				frmTypeName = frmName & "Type"
			ElseIf b Then
				If StartsWith(*FLine2 & " ", "end type ") OrElse StartsWith(*FLine2 & " ", "end class ") OrElse StartsWith(*FLine2 & " ", "__startofclassbody__ ") Then
					j = k
					sl = Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))
					WLet(FLine1, ..Left(ptxtCode->Lines(k), sl))
					Exit For, For
					' Ctrl Array
				ElseIf StartsWith(*FLine2, "dim as " & LCase(WGet(st->ReadPropertyFunc(Cpnt, "ClassName"))) & " ") Then
					d = True
					If Len(*FLine2) > 1024 - Len(", " & CtrlName) Then d = False
					If InStr(CtrlName, "(")  Then
						CtrlNameBase = Trim(StringExtract(CtrlName, "("))
					Else
						CtrlNameBase = Trim(CtrlName)
					End If
					j = k + 1
					dj = j
					If InStr(CtrlName,"(") < 1 AndAlso (InStr(*FLine2 & ",", " " & LCase(CtrlName) & ",") _
						OrElse InStr(*FLine2 & ",", "," & LCase(CtrlName) & ",")) Then
						t = True
						Exit For, For
					ElseIf InStr(CtrlName,"(") > 0 AndAlso (InStr(*FLine2, " " & LCase(CtrlNameBase) & "(") _ 'Ctrl Array
						Or InStr(*FLine2, "," & LCase(CtrlNameBase) & "(")) Then 'Ctrl Array
						Dim As String CtrlArrayOld = StringExtract(ptxtCode->Lines(k), CtrlNameBase & "(" ,")")
						Dim As String CtrlArrayNew = StringExtract(CtrlName, CtrlNameBase & "(" ,")")
						If Val(CtrlArrayNew) > Val(CtrlArrayOld) Then
							ptxtCode->ReplaceLine k, Replace(ptxtCode->Lines(k), CtrlNameBase & "("  & CtrlArrayOld & ")",CtrlNameBase & "(" & CtrlArrayNew & ")")
						End If
						t = True
						Exit For, For
					End If
				End If
			End If
		Next
	Next
	If Not t Then
		If tb->Des->DesignControl <> Cpnt Then
			CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
			If d Then
				ptxtCode->ReplaceLine dj - 1, RTrim(ptxtCode->Lines(dj - 1)) & ", " & CtrlName
			Else
				ptxtCode->InsertLine j, *FLineType & TabSpace & "Dim As " & WGet(st->ReadPropertyFunc(Cpnt, "ClassName")) & " " & CtrlName
				InsLineCount += 1
				tb->ConstructorStart += 1
				tb->ConstructorEnd += 1
			End If
		End If
	End If
	t = False: b = False
	For l As Integer = tp + 1 To ptxtCode->LinesCount - 1
		If StartsWith(LTrim(LCase(ptxtCode->Lines(l)), Any !"\t ") & " ", "declare constructor ") Then
			t = True
		ElseIf StartsWith(LTrim(LCase(ptxtCode->Lines(l)), Any !"\t ") & " ", "end type ") OrElse StartsWith(LTrim(LCase(ptxtCode->Lines(l)), Any !"\t ") & " ", "end class ") OrElse StartsWith(LTrim(LCase(ptxtCode->Lines(l)), Any !"\t ") & " ", "__startofclassbody__ ") Then
			ep = l
			Exit For
		End If
	Next
	If Not t Then
		CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
		ptxtCode->InsertLine tp + 1, *FLineType & TabSpace & "Declare Constructor"
		InsLineCount += 1
	End If
	Var sc = 0, se = 0
	Var BeforeCtrlLine = 0, AfterCtrlLine = 0
	Var bWith = False
	j = 0: n = 0
	t = False
	For i = i To tb->txtCode.LinesCount - 1
		For k = iStart To IIf(ptxtCode = @tb->txtCode, i, ptxtCode->LinesCount - 1)
			If StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t ") & " ", "constructor " & LCase(frmName) & " ") Or StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t ") & " ", "constructor " & LCase(frmName) & "type ") Then
				sc = k
				b = True
				sl = Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))
				WLet(FLine1, ..Left(ptxtCode->Lines(k), sl))
			ElseIf b Then
				If StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t ") & " ", "end constructor ") Then
					se = k
					Exit For, For
				ElseIf BeforeCtrl AndAlso Trim(LCase(ptxtCode->Lines(k)), Any !"\t ") = "' " & LCase(BeforeCtrlName) Then
					BeforeCtrlLine = k
				ElseIf BeforeCtrl AndAlso BeforeCtrlLine = 0 AndAlso CInt(StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), LCase(BeforeCtrlName) & ".")) OrElse CInt(CInt(WithArgs.Count > 0) AndAlso CInt(WithArgs.Item(WithArgs.Count - 1) = BeforeCtrlName) AndAlso CInt(StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "."))) Then
					AfterCtrlLine = k
				ElseIf AfterCtrl AndAlso CInt(StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), LCase(AfterCtrlName) & ".")) OrElse CInt(CInt(WithArgs.Count > 0) AndAlso CInt(WithArgs.Item(WithArgs.Count - 1) = AfterCtrlName) AndAlso CInt(StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "."))) Then
					AfterCtrlLine = k
				ElseIf Trim(LCase(ptxtCode->Lines(k)), Any !"\t ") = "' " & LCase(CtrlName) Then
					If BeforeCtrl OrElse AfterCtrl Then CuttingLines.Add k, ptxtCode->Content.Lines.Items[k]
				ElseIf StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "with ") Then
					WithArgs.Add Trim(Mid(Trim(ptxtCode->Lines(k), Any !"\t "), 5), Any !"\t ")
					If BeforeCtrl OrElse AfterCtrl Then
						If Trim(LCase(ptxtCode->Lines(k)), Any !"\t ") = "with " & LCase(CtrlName) Then
							CuttingLines.Add k, ptxtCode->Content.Lines.Items[k]
						End If
						If BeforeCtrl AndAlso BeforeCtrlLine = 0 AndAlso Trim(LCase(ptxtCode->Lines(k)), Any !"\t ") = "with " & LCase(BeforeCtrlName) Then BeforeCtrlLine = k
						If AfterCtrl AndAlso Trim(LCase(ptxtCode->Lines(k)), Any !"\t ") = "with " & LCase(AfterCtrlName) Then AfterCtrlLine = k
					End If
				ElseIf StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "end with") Then
					If WithArgs.Count > 0 Then
						If BeforeCtrl OrElse AfterCtrl Then
							If WithArgs.Item(WithArgs.Count - 1) = CtrlName Then
								CuttingLines.Add k, ptxtCode->Content.Lines.Items[k]
							ElseIf AfterCtrl AndAlso WithArgs.Item(WithArgs.Count - 1) = AfterCtrlName Then
								AfterCtrlLine = k
							End If
						End If
						WithArgs.Remove WithArgs.Count - 1
					End If
				ElseIf CInt(StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), LCase(CtrlName) & ".")) OrElse CInt(CInt(WithArgs.Count > 0) AndAlso CInt(WithArgs.Item(WithArgs.Count - 1) = CtrlName) AndAlso CInt(StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "."))) Then
					If BeforeCtrl OrElse AfterCtrl Then CuttingLines.Add k, ptxtCode->Content.Lines.Items[k]
					j = k
					bWith = WithArgs.Count > 0 AndAlso WithArgs.Item(WithArgs.Count - 1) = CtrlName
					Var p = InStr(ptxtCode->Lines(k), ".")
					If p Then
						If StartsWith(Trim(LCase(Mid(ptxtCode->Lines(k), p + 1)), Any !"\t "), "setbounds ") Then
							n = k
							If iLeft <> -1 AndAlso iTop <> -1 AndAlso iWidth <> -1 AndAlso iHeight <> - 1 Then
								iLeft1 = iLeft
								iTop1 = iTop
								iHeight1 = iHeight
								iWidth1 = iWidth
							Else
								tb->Des->GetControlBounds(Cpnt, iLeft1, iTop1, iWidth1, iHeight1)
							End If
							CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
							ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), p + 10) & iLeft1 & ", " & iTop1 & ", " & iWidth1 & ", " & iHeight1
							'Ctrl2 = Cast(Control Ptr, Cpnt)
							'.ReplaceLine i, ..Left(.Lines(i), p + Len(LCase(CtrlName)) + 10) & Ctrl2->Left & ", " & Ctrl2->Top & ", " & Ctrl2->Width & ", " & Ctrl2->Height
							If LCase(PropertyName) = "left" OrElse LCase(PropertyName) = "top" OrElse LCase(PropertyName) = "width" OrElse LCase(PropertyName) = "height" Then t = True
						ElseIf StartsWith(Trim(LCase(Mid(ptxtCode->Lines(k), p + 1)), Any !"\t "), "left ") Then
							Var p1 = InStr(LCase(ptxtCode->Lines(k)), "=")
							If p1 Then
								CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
								ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), p1) & " " & tb->GetFormattedPropertyValue(Cpnt, "Left")
								If LCase(PropertyName) = "left" Then t = True
							End If
						ElseIf StartsWith(Trim(LCase(Mid(ptxtCode->Lines(k), p + 1)), Any !"\t "), "top ") Then
							Var p1 = InStr(LCase(ptxtCode->Lines(k)), "=")
							If p1 Then
								CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
								ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), p1) & " " & tb->GetFormattedPropertyValue(Cpnt, "Top")
								If LCase(PropertyName) = "top" Then t = True
							End If
						ElseIf CInt(PropertyName <> "") AndAlso CInt(StartsWith(Mid(LCase(ptxtCode->Lines(k)), p + 1), LCase(PropertyName) & " ") OrElse StartsWith(Mid(LCase(ptxtCode->Lines(k)), p + 1), LCase(PropertyName) & "=")) Then
							Var p1 = InStr(LCase(ptxtCode->Lines(k)), "=")
							If p1 Then
								CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
								ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), p1) & " " & tb->GetFormattedPropertyValue(Cpnt, PropertyName)
								t = True
							End If
						End If
					End If
				End If
			End If
		Next
		ptxtCode = @tb->txtCode
		iStart = i + 1
		iEnd = i + 1
	Next
	If n > 0 Then j = n
	Dim q As Integer = 0
	If sc = 0 Then
		CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
		ptxtCode->InsertLine ep + 2, *FLine1
		ptxtCode->InsertLine ep + 3, *FLine1 & "Constructor " & frmTypeName: tb->ConstructorStart = ep + 3
		ptxtCode->InsertLine ep + 4, *FLine1 & TabSpace & "' " & frmName
		ptxtCode->InsertLine ep + 5, *FLine1 & TabSpace & "With This"
		ptxtCode->InsertLine ep + 6, *FLine1 & TabSpace & TabSpace & ".Name = """ & frmName & """"
		ptxtCode->InsertLine ep + 7, *FLine1 & TabSpace & TabSpace & ".Text = """ & WGet(stDesignControl->ReadPropertyFunc(tb->Des->DesignControl, "Text")) & """"
		If PropertyName <> "" AndAlso PropertyName <> "Text" AndAlso PropertyName <> "Name" AndAlso PropertyName <> "Location.X" AndAlso PropertyName <> "Location.Y" AndAlso PropertyName <> "Size.Width" AndAlso PropertyName <> "Size.Height" Then
			WLet(FLine, tb->GetFormattedPropertyValue(tb->Des->DesignControl, PropertyName))
			If *FLine <> "" Then ptxtCode->InsertLine ep + 8, *FLine1 & TabSpace & TabSpace & "." & PropertyName & " = " & *FLine: q = 1
		End If
		ptxtCode->InsertLine ep + q + 8, *FLine1 & TabSpace & TabSpace & ".Designer = @This"
		tb->Des->GetControlBounds(tb->Des->DesignControl, iLeft1, iTop1, iWidth1, iHeight1)
		ptxtCode->InsertLine ep + q + 9, *FLine1 & TabSpace & TabSpace & ".SetBounds " & iLeft1 & ", " & iTop1 & ", " & iWidth1 & ", " & iHeight1
		ptxtCode->InsertLine ep + q + 10, *FLine1 & TabSpace & "End With"
		ptxtCode->InsertLine ep + q + 11, *FLine1 & "End Constructor": tb->ConstructorEnd = ep + q + 11
		InsLineCount += q + 11
		If Cpnt = tb->Des->DesignControl Then j = ep + q + 11: t = True
		se = ep + q + 11
	ElseIf se = 0 Then
		'Var l = .CharIndexFromLine(sc + 1)
		'.ChangeText ..Left(.Text, l) & Space(sl) & "End Constructor" & Chr(13) & Mid(.Text, l + 1), "Tugatuvchi konstruktor qo`shildi", .SelStart, , False
		se = sc + 1
	End If
	If j = 0 Then
		If BeforeCtrlLine > 0 Then se = BeforeCtrlLine
		CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
		Dim ParentName As String
		If Cpnt <> 0 Then
			If st->ReadPropertyFunc(Cpnt, "Parent") Then
				If st->ReadPropertyFunc(Cpnt, "Parent") = tb->Des->DesignControl Then
					ParentName = "This"
				Else
					Dim ParentCtrl As Any Ptr = st->ReadPropertyFunc(Cpnt, "Parent")
					Dim As SymbolsType Ptr stParent = tb->Des->Symbols(ParentCtrl)
					If stParent AndAlso stParent->ReadPropertyFunc Then ParentName = WGet(stParent->ReadPropertyFunc(ParentCtrl, "Name"))
				End If
			End If
		End If
		If st->IsControlFunc <> 0 AndAlso CInt(st->IsControlFunc(Cpnt)) Then
			ptxtCode->InsertLine se, *FLine1 & TabSpace & "' " & CtrlName
			ptxtCode->InsertLine se + 1, *FLine1 & TabSpace & "With " & CtrlName
			ptxtCode->InsertLine se + 2, *FLine1 & TabSpace & TabSpace & ".Name = """ & CtrlName & """"
			tb->ConstructorEnd += 3
			InsLineCount += 3
			q = 0
			If WGet(st->ReadPropertyFunc(Cpnt, "Text")) <> "" Then
				'				WLet FLine, CtrlName
				'				If tb->Des->WritePropertyFunc <> 0 Then tb->Des->WritePropertyFunc(Cpnt, "Text", FLine)
				ptxtCode->InsertLine se + 3, *FLine1 & TabSpace & TabSpace & ".Text = """ & WGet(st->ReadPropertyFunc(Cpnt, "Text")) & """"
				InsLineCount += 1
				tb->ConstructorEnd += 1
				q = 1
			End If
			If st->ReadPropertyFunc(Cpnt, "TabIndex") <> 0 Then
				ptxtCode->InsertLine se + q + 3, *FLine1 & TabSpace & TabSpace & ".TabIndex = " & QInteger(st->ReadPropertyFunc(Cpnt, "TabIndex"))
				InsLineCount += 1
				tb->ConstructorEnd += 1
				q += 1
			End If
			If PropertyName <> "" AndAlso PropertyName <> "Text" AndAlso PropertyName <> "TabIndex" AndAlso PropertyName <> "Location.X" AndAlso PropertyName <> "Location.Y" AndAlso PropertyName <> "Size.Width" AndAlso PropertyName <> "Size.Height" Then
				WLet(FLine, tb->GetFormattedPropertyValue(Cpnt, PropertyName))
				'  Confuse the formatcode function
				If *FLine <> "" Then
					ptxtCode->InsertLine se + q + 3, *FLine1 & TabSpace & TabSpace & "." & PropertyName & " = " & *FLine: q += 1
					tb->ConstructorEnd += 1
				End If
			End If
			If iLeft <> -1 AndAlso iTop <> -1 AndAlso iWidth <> -1 AndAlso iHeight <> - 1 Then
				iLeft1 = iLeft
				iTop1 = iTop
				iWidth1 = iWidth
				iHeight1 = iHeight
			Else
				tb->Des->GetControlBounds(Cpnt, iLeft1, iTop1, iWidth1, iHeight1)
			End If
			ptxtCode->InsertLine se + q + 3, *FLine1 & TabSpace & TabSpace & ".SetBounds " & iLeft1 & ", " & iTop1 & ", " & iWidth1 & ", " & iHeight1
			InsLineCount += 1
			tb->ConstructorEnd += 1
			ptxtCode->InsertLine se + q + 4, *FLine1 & TabSpace & TabSpace & ".Designer = @This"
			InsLineCount += 1
			tb->ConstructorEnd += 1
			If Cpnt <> tb->Des->DesignControl Then ptxtCode->InsertLine se + q + 5, *FLine1 & TabSpace & TabSpace & ".Parent = @" & ParentName: InsLineCount += 1: q += 1
			ptxtCode->InsertLine se + q + 5, *FLine1 & TabSpace & "End With": InsLineCount += 1
			tb->ConstructorEnd += 1
		ElseIf st->IsComponentFunc <> 0 AndAlso CInt(st->IsComponentFunc(Cpnt)) Then
			q = 0
			If iLeft <> -1 AndAlso iTop <> -1 AndAlso iWidth <> -1 AndAlso iHeight <> - 1 Then
				iLeft1 = iLeft
				iTop1 = iTop
				iWidth1 = iWidth
				iHeight1 = iHeight
			Else
				tb->Des->GetControlBounds(Cpnt, iLeft1, iTop1, iWidth1, iHeight1)
			End If
			ptxtCode->InsertLine se, *FLine1 & TabSpace & "' " & CtrlName
			ptxtCode->InsertLine se + 1, *FLine1 & TabSpace & "With " & CtrlName
			ptxtCode->InsertLine se + 2, *FLine1 & TabSpace & TabSpace & ".Name = """ & CtrlName & """"
			ptxtCode->InsertLine se + 3, *FLine1 & TabSpace & TabSpace & ".SetBounds " & iLeft1 & ", " & iTop1 & ", " & iWidth1 & ", " & iHeight1
			ptxtCode->InsertLine se + 4, *FLine1 & TabSpace & TabSpace & ".Designer = @This"
			ptxtCode->InsertLine se + 5, *FLine1 & TabSpace & TabSpace & ".Parent = @" & ParentName
			tb->ConstructorEnd += 6
			'  Confuse the formatcode function
			If PropertyName <> "" AndAlso PropertyName <> "Name" Then
				ptxtCode->InsertLine se + 6, *FLine1 & TabSpace & TabSpace & "." & PropertyName & " = " & tb->GetFormattedPropertyValue(Cpnt, PropertyName): q += 1
				tb->ConstructorEnd += 1
			End If
			ptxtCode->InsertLine se + q + 6, *FLine1 & TabSpace & "End With"
			InsLineCount += q + 6
			tb->ConstructorEnd += 1
		Else
			q = 0
			ptxtCode->InsertLine se, *FLine1 & TabSpace & "' " & CtrlName
			ptxtCode->InsertLine se + 1, *FLine1 & TabSpace & "With " & CtrlName
			ptxtCode->InsertLine se + 2, *FLine1 & TabSpace & TabSpace & ".Name = """ & CtrlName & """"
			ptxtCode->InsertLine se + 3, *FLine1 & TabSpace & TabSpace & ".Designer = @This"
			tb->ConstructorEnd += 4
			'  Confuse the formatcode function
			If PropertyName = "Parent" Then
				ptxtCode->InsertLine se + 4, *FLine1 & TabSpace & TabSpace & ".Parent = @" & ParentName: q += 1
				tb->ConstructorEnd += 1
			ElseIf PropertyName <> "" AndAlso PropertyName <> "Name" AndAlso PropertyName <> "Location.X" AndAlso PropertyName <> "Location.Y" AndAlso PropertyName <> "Size.Width" AndAlso PropertyName <> "Size.Height" Then
				ptxtCode->InsertLine se + 4, *FLine1 & TabSpace & TabSpace & "." & PropertyName & " = " & tb->GetFormattedPropertyValue(Cpnt, PropertyName): q += 1
				tb->ConstructorEnd += 1
			End If
			ptxtCode->InsertLine se + q + 4, *FLine1 & TabSpace & "End With"
			InsLineCount += q + 4
			tb->ConstructorEnd += 1
		End If
	Else
		If BeforeCtrlLine > 0 AndAlso BeforeCtrlLine < j Then
			For i As Integer = 0 To CuttingLines.Count - 1
				j = BeforeCtrlLine + i
				ptxtCode->InsertLine j, *Cast(EditControlLine Ptr, CuttingLines.Object(i))->Text
				ptxtCode->DeleteLine CuttingLines.Item(i) + 1
			Next
		ElseIf AfterCtrlLine > 0 AndAlso AfterCtrlLine > j Then
			For i As Integer = 0 To CuttingLines.Count - 1
				j = AfterCtrlLine + 1
				ptxtCode->InsertLine j, *Cast(EditControlLine Ptr, CuttingLines.Object(i))->Text
				ptxtCode->DeleteLine CuttingLines.Item(i) - i
			Next
		End If
		If Not t Then
			If PropertyName <> "" AndAlso PropertyName <> "Location.X" AndAlso PropertyName <> "Location.Y" AndAlso PropertyName <> "Size.Width" AndAlso PropertyName <> "Size.Height" Then
				CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
				WLet(FLine, tb->GetFormattedPropertyValue(Cpnt, PropertyName))
				If *FLine <> "" Then
					If bWith Then
						ptxtCode->InsertLine j, *FLine1 & TabSpace & TabSpace & "." & PropertyName & " = " & *FLine: q += 1
						tb->ConstructorEnd += 1
					Else
						ptxtCode->InsertLine j, *FLine1 & TabSpace & CtrlName & "." & PropertyName & " = " & *FLine: q += 1
						tb->ConstructorEnd += 1
					End If
				End If
			End If
			InsLineCount += q
		End If
	End If
	If Not bOldChangingStarted Then
		bNotDesignForms = True
		ptxtCode->Changed ""
		If ptxtCodeBi <> 0 Then ptxtCodeBi->Changed ""
		bNotDesignForms = False
	End If
	WDeAllocate(FLine)
	WDeAllocate(FLine1)
	WDeAllocate(FLine2)
	WDeAllocate(FLineType)
	Return InsLineCount
	Exit Function
	ErrorHandler:
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " " & _
	"in function " & ZGet(Erfn()) & " " & _
	"in module " & ZGet(Ermn())
End Function

Sub TabWindow.CheckExtension(ByRef sFileName As WString)
	txtCode.Content.CStyle = CInt(EndsWith(LCase(sFileName), ".rc")) OrElse CInt(EndsWith(LCase(sFileName), ".c")) OrElse CInt(EndsWith(LCase(sFileName), ".cpp")) OrElse CInt(EndsWith(LCase(sFileName), ".java")) OrElse CInt(EndsWith(LCase(sFileName), ".h")) OrElse CInt(EndsWith(LCase(sFileName), ".xml")) OrElse CInt(EndsWith(LCase(sFileName), ".bat"))
	txtCode.SyntaxEdit = txtCode.Content.CStyle OrElse CInt(sFileName = "") OrElse CInt(EndsWith(LCase(sFileName), ".bas")) OrElse CInt(EndsWith(LCase(sFileName), ".frm")) OrElse CInt(EndsWith(LCase(sFileName), ".bi")) OrElse CInt(EndsWith(LCase(sFileName), ".inc"))
End Sub

Sub TabWindow.ChangeName(ByRef OldName As WString, ByRef NewName As WString)
	Dim iIndex As Integer = cboClass.Items.IndexOf(OldName)
	If Des = 0 Then Exit Sub
	If Des->DesignControl = 0 Then Exit Sub
	Dim As SymbolsType Ptr stDesignControl = Des->Symbols(Des->DesignControl)
	Dim frmName As String
	If stDesignControl AndAlso stDesignControl->ReadPropertyFunc <> 0 Then
		frmName = WGet(stDesignControl->ReadPropertyFunc(Des->DesignControl, "Name"))
	End If
	If iIndex = 1 AndAlso stDesignControl AndAlso stDesignControl->WritePropertyFunc <> 0 Then stDesignControl->WritePropertyFunc(Des->DesignControl, "Name", @NewName)
	Dim As Boolean b, c
	If iIndex > -1 Then cboClass.Items.Item(iIndex)->Text = NewName
	Dim As TabWindow Ptr tb = @This
	Dim As EditControl txtCodeBi
	Dim As EditControl Ptr ptxtCode, ptxtCodeBi
	Dim As Integer iStart, iEnd
	Dim As Boolean bFind, IsBas = EndsWith(LCase(tb->FileName), ".bas") OrElse EndsWith(LCase(tb->FileName), ".frm")
	For i As Integer = 0 To tb->txtCode.LinesCount - 1
		GetBiFile(ptxtCode, txtCodeBi, ptxtCodeBi, tb, IsBas, bFind, i, iStart, iEnd)
		For k As Integer = iStart To iEnd
			If StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")), "type " & LCase(frmName) & " ") OrElse StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")), "class " & LCase(frmName) & " ") Then
				c = True
				If iIndex = 1 Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))) & ..Left(LTrim(ptxtCode->Lines(k), Any !"\t "), 5) & NewName & Mid(LTrim(ptxtCode->Lines(k), Any !"\t "), Len(frmName) + 6)
				End If
			ElseIf StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")), "type " & LCase(frmName) & "type ") OrElse StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")), "class " & LCase(frmName) & "type ") Then
				c = True
				If iIndex = 1 Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))) & ..Left(LTrim(ptxtCode->Lines(k), Any !"\t "), 5) & NewName & "Type" & Mid(LTrim(ptxtCode->Lines(k), Any !"\t "), Len(frmName & "Type") + 6)
				End If
			ElseIf c Then
				If StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")) & " ", "end type ") OrElse StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")) & " ", "end class ") OrElse StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")) & " ", "__startofclassbody__ ") Then
					c = False
				ElseIf StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")), "dim as ") Then
					Var Pos1 = InStr(LCase(RTrim(ptxtCode->Lines(k))) & ",", " " & LCase(OldName) & ",")
					' for Ctrl Array
					If Pos1=0 Then Pos1 = InStr(LCase(RTrim(ptxtCode->Lines(k))) & ",", "," & LCase(OldName) & ",")
					If Pos1 > 0 Then
						CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
						ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), Pos1) & NewName & Mid(ptxtCode->Lines(k), Len(OldName) + Pos1 + 1)
					End If
				End If
			ElseIf StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")) & " ", "constructor " & LCase(frmName) & " ") Then
				If iIndex = 1 Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))) & ..Left(LTrim(ptxtCode->Lines(k), Any !"\t "), 12) & NewName & Mid(LTrim(ptxtCode->Lines(k), Any !"\t "), Len(frmName) + 13)
				End If
				b = True
			ElseIf StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")) & " ", "constructor " & LCase(frmName) & "type ") Then
				If iIndex = 1 Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))) & ..Left(LTrim(ptxtCode->Lines(k), Any !"\t "), 12) & NewName & "Type" & Mid(LTrim(ptxtCode->Lines(k), Any !"\t "), Len(frmName & "Type") + 13)
				End If
				b = True
			ElseIf b Then
				If StartsWith(LTrim(LCase(ptxtCode->Lines(k)) & " ", Any !"\t "), "end constructor ") Then
					b = False
				ElseIf StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")) & " ", "with " & LCase(OldName) & " ") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))) & ..Left(LTrim(ptxtCode->Lines(k), Any !"\t "), 5) & NewName & Mid(LTrim(ptxtCode->Lines(k), Any !"\t "), Len(OldName) + 6)
				ElseIf StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")) & " ", "' " & LCase(OldName) & " ") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))) & ..Left(LTrim(ptxtCode->Lines(k), Any !"\t "), 2) & NewName & Mid(LTrim(ptxtCode->Lines(k), Any !"\t "), Len(OldName) + 3)
				ElseIf StartsWith(LTrim(LCase(ptxtCode->Lines(k)), Any !"\t "), LCase(OldName) & ".") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))) & NewName & Mid(LTrim(ptxtCode->Lines(k), Any !"\t "), Len(OldName) + 1)
				ElseIf EndsWith(RTrim(LCase(ptxtCode->Lines(k)), " "), "@" & LCase(OldName)) Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(OldName)) & NewName
				End If
			ElseIf iIndex = 1 Then
				If StartsWith(LTrim(LCase(ptxtCode->Lines(k)), Any !"\t "), "private sub " & LCase(OldName) & ".") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))) & ..Left(LTrim(ptxtCode->Lines(k), Any !"\t "), 12) & NewName & Mid(LTrim(ptxtCode->Lines(k), Any !"\t "), Len(OldName) + 13)
				ElseIf StartsWith(LTrim(LCase(ptxtCode->Lines(k)), Any !"\t "), "private sub " & LCase(OldName) & "type.") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))) & ..Left(LTrim(ptxtCode->Lines(k), Any !"\t "), 12) & NewName & "Type" & Mid(LTrim(ptxtCode->Lines(k), Any !"\t "), Len(OldName & "Type") + 13)
				ElseIf StartsWith(LTrim(LCase(ptxtCode->Lines(k)), Any !"\t "), "public sub " & LCase(OldName) & ".") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))) & ..Left(LTrim(ptxtCode->Lines(k), Any !"\t "), 11) & NewName & Mid(LTrim(ptxtCode->Lines(k), Any !"\t "), Len(OldName) + 12)
				ElseIf StartsWith(LTrim(LCase(ptxtCode->Lines(k)), Any !"\t "), "public sub " & LCase(OldName) & "type.") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))) & ..Left(LTrim(ptxtCode->Lines(k), Any !"\t "), 11) & NewName & "Type" & Mid(LTrim(ptxtCode->Lines(k), Any !"\t "), Len(OldName & "Type") + 12)
				ElseIf StartsWith(LTrim(LCase(ptxtCode->Lines(k)), Any !"\t "), "cast(" & LCase(OldName) & " ") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))) & ..Left(LTrim(ptxtCode->Lines(k), Any !"\t "), 5) & NewName & Mid(LTrim(ptxtCode->Lines(k), Any !"\t "), Len(OldName) + 6)
				ElseIf StartsWith(LTrim(LCase(ptxtCode->Lines(k)), Any !"\t "), "*cast(" & LCase(OldName) & " ") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))) & ..Left(LTrim(ptxtCode->Lines(k), Any !"\t "), 6) & NewName & Mid(LTrim(ptxtCode->Lines(k), Any !"\t "), Len(OldName) + 7)
				ElseIf StartsWith(LTrim(LCase(ptxtCode->Lines(k)), Any !"\t "), "(*cast(" & LCase(OldName) & " ") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))) & ..Left(LTrim(ptxtCode->Lines(k), Any !"\t "), 7) & NewName & Mid(LTrim(ptxtCode->Lines(k), Any !"\t "), Len(OldName) + 8)
				ElseIf StartsWith(LTrim(LCase(ptxtCode->Lines(k)), Any !"\t "), "cast(" & LCase(OldName) & "type ") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))) & ..Left(LTrim(ptxtCode->Lines(k), Any !"\t "), 5) & NewName & "Type" & Mid(LTrim(ptxtCode->Lines(k), Any !"\t "), Len(OldName & "Type") + 6)
				ElseIf StartsWith(LTrim(LCase(ptxtCode->Lines(k)), Any !"\t "), "*cast(" & LCase(OldName) & "type ") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))) & ..Left(LTrim(ptxtCode->Lines(k), Any !"\t "), 6) & NewName & "Type" & Mid(LTrim(ptxtCode->Lines(k), Any !"\t "), Len(OldName & "Type") + 7)
				ElseIf StartsWith(LTrim(LCase(ptxtCode->Lines(k)), Any !"\t "), "(*cast(" & LCase(OldName) & "type ") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))) & ..Left(LTrim(ptxtCode->Lines(k), Any !"\t "), 7) & NewName & "Type" & Mid(LTrim(ptxtCode->Lines(k), Any !"\t "), Len(OldName & "Type") + 8)
				End If
			End If
			If iIndex = 1 Then
				If EndsWith(RTrim(LCase(ptxtCode->Lines(k)), Any !"\t "), LCase(OldName) & " as " & LCase(OldName) & "type") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(OldName) * 2 - 8) & NewName & " As " & NewName & "Type"
				ElseIf EndsWith(RTrim(LCase(ptxtCode->Lines(k)), Any !"\t "), " as " & LCase(OldName) & "type") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(OldName) - 4) & NewName & "Type"
				ElseIf EndsWith(RTrim(LCase(ptxtCode->Lines(k)), Any !"\t "), " as " & LCase(OldName)) Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(OldName)) & NewName
				ElseIf EndsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), LCase(OldName) & ".mainform = true") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(OldName) - 16) & NewName & ".MainForm = True"
				ElseIf EndsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), LCase(OldName) & ".show") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, ..Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(OldName) - 5) & NewName & ".Show"
				End If
			End If
		Next
	Next
	FormDesign True
End Sub

Function GetItemText(ByRef Item As TreeListViewItem Ptr) As String
	If Item = 0 Then Return ""
	Dim As String PropertyName = Item->Text(0)
	If Item->ParentItem = 0 Then
		Return PropertyName
	Else
		Return GetItemText(Item->ParentItem) & "." & PropertyName
	End If
End Function

Sub PropertyChanged(ByRef Sender As Control, ByRef Sender_Text As WString, IsCombo As Boolean)
	Var tb = Cast(TabWindow Ptr, tabRight.Tag)
	If tb = 0 Then Exit Sub
	If tb->Des = 0 Then Exit Sub
	If tb->Des->SelectedControl = 0 Then Exit Sub
	If plvProperties->SelectedItem = 0 Then Exit Sub
	Dim As String PropertyName = GetItemText(plvProperties->SelectedItem), PropertyName_
	'Var te = GetPropertyType(tb->SelectedControl->ClassName, PropertyName)
	'If te = 0 Then Exit Sub
	Dim FLine As WString Ptr
	Dim SenderText As UString
	Dim As Integer SelCount = tb->Des->SelectedControls.Count
	Dim As Boolean Different, OnlySelected = Not tb->Des->SelectedControls.Contains(tb->Des->SelectedControl)
	Dim As List SelectedControls
	Dim As List Ptr pSelectedControls
	SelectedControls.Add tb->Des->SelectedControl
	If OnlySelected Then
		SelCount = 1
		pSelectedControls = @SelectedControls
	Else
		pSelectedControls = @tb->Des->SelectedControls
	End If
	SenderText = IIf(IsCombo, Mid(Sender_Text, 2), Sender_Text)
	With tb->txtCode
		Dim As UString OldText = tb->ReadObjProperty(tb->Des->SelectedControl, PropertyName)
		If SelCount > 1 Then
			For i As Integer = 0 To SelCount - 1
				If tb->ReadObjProperty(pSelectedControls->Item(i), PropertyName) <> OldText Then
					Different = True
					Exit For
				End If
			Next i
		End If
		If SenderText <> OldText OrElse Different Then
			If CInt(PropertyName = "Name") AndAlso CInt(tb->cboClass.Items.Contains(SenderText)) Then
				MsgBox ML("This name is exists!"), "VisualFBEditor", mtWarning
				#ifndef __USE_GTK__
					Sender.Text = OldText
				#endif
				Exit Sub
			End If
			pfrmMain->UpdateLock
			.Changing "Unsurni o`zgartirish"
			If PropertyName = "Name" Then tb->ChangeName tb->ReadObjProperty(tb->Des->SelectedControl, PropertyName), SenderText
			For i As Integer = 0 To SelCount - 1
				Dim As Integer iLeft, iTop, iWidth, iHeight
				Dim As SymbolsType Ptr st = tb->Des->Symbols(pSelectedControls->Item(i))
				If st AndAlso st->IsComponentFunc AndAlso CInt(st->IsComponentFunc(pSelectedControls->Item(i))) Then
					If st->ComponentGetBoundsSub Then st->ComponentGetBoundsSub(pSelectedControls->Item(i), iLeft, iTop, iWidth, iHeight)
				End If
				#ifdef __USE_GTK__
					Dim As GtkWidget Ptr tmpWidget
					If st AndAlso st->ReadPropertyFunc Then tmpWidget = st->ReadPropertyFunc(pSelectedControls->Item(i), "widget")
				#endif
				tb->WriteObjProperty(pSelectedControls->Item(i), PropertyName, Sender_Text)
				#ifdef __USE_GTK__
					pApp->DoEvents
				#endif
				Dim As Integer iLeft2, iTop2, iWidth2, iHeight2
				If st AndAlso st->IsComponentFunc AndAlso CInt(st->IsComponentFunc(pSelectedControls->Item(i))) Then
					If st->ComponentGetBoundsSub Then st->ComponentGetBoundsSub(pSelectedControls->Item(i), iLeft2, iTop2, iWidth2, iHeight2)
					If iLeft <> iLeft2 OrElse iTop <> iTop2 OrElse iWidth <> iWidth2 OrElse iHeight <> iHeight2 Then tb->Des->MoveDots pSelectedControls->Item(i), False
				End If
				#ifdef __USE_GTK__
					Dim As GtkWidget Ptr tmpChangedWidget
					If st AndAlso st->ReadPropertyFunc Then tmpChangedWidget = st->ReadPropertyFunc(pSelectedControls->Item(i), "widget")
					If tmpWidget <> tmpChangedWidget Then
						tb->Des->HookControl(tmpChangedWidget)
						tb->Des->FSelControl = tmpChangedWidget
						If g_object_get_data(G_OBJECT(tmpChangedWidget), "drawed") = tb->Des Then tb->Des->MoveDots pSelectedControls->Item(i)
					End If
				#endif
			Next i
			#ifdef __USE_WINAPI__
				If PropertyName = "Menu" Then tb->Des->CheckTopMenuVisible
				'Sender.Text = tb->ReadObjProperty(tb->Des->SelectedControl, PropertyName)
				plvProperties->SelectedItem->Text(1) = SenderText
			#endif
			If PropertyName = "TabIndex" Then
				For i As Integer = 2 To tb->cboClass.ItemCount - 1
					ChangeControl(*tb->Des, tb->cboClass.Items.Item(i)->Object, "TabIndex")
				Next
			ElseIf PropertyName = "ControlIndex" Then
				For i As Integer = 0 To SelCount - 1
					Dim As SymbolsType Ptr st = tb->Des->Symbols(pSelectedControls->Item(i))
					Dim As Any Ptr BeforeCtrl
					If st AndAlso st->ReadPropertyFunc AndAlso st->WritePropertyFunc AndAlso st->ReadPropertyFunc(pSelectedControls->Item(i), "Parent") Then
						Dim As Any Ptr ParentCtrl = st->ReadPropertyFunc(pSelectedControls->Item(i), "Parent")
						Dim As SymbolsType Ptr stParent = tb->Des->Symbols(ParentCtrl)
						If stParent AndAlso stParent->ReadPropertyFunc AndAlso stParent->ControlByIndexFunc AndAlso QInteger(stParent->ReadPropertyFunc(ParentCtrl, "ControlCount")) > 1 Then
							BeforeCtrl = stParent->ControlByIndexFunc(ParentCtrl, Val(SenderText) + 1)
						End If
					End If
					ChangeControl(*tb->Des, pSelectedControls->Item(i), PropertyName, BeforeCtrl)
				Next i
			Else
				For i As Integer = 0 To SelCount - 1
					ChangeControl(*tb->Des, pSelectedControls->Item(i), PropertyName)
				Next i
			End If
			For j As Integer = 0 To SelCount - 1
				'If tb->frmForm Then tb->frmForm->MoveDots Cast(Control Ptr, tb->SelectedControl)->Handle, False
				If SelCount = 1 Then
					For i As Integer = 0 To plvProperties->Nodes.Count - 1
						'If SelCount > 1 AndAlso plvProperties->Nodes.Item(i)->Text(1) = "" Then Continue For
						PropertyName_ = GetItemText(plvProperties->Nodes.Item(i))
						If (PropertyName_ = "Location" OrElse PropertyName_ = "Size") AndAlso PropertyName <> "Location.X" AndAlso PropertyName <> "Location.Y" AndAlso PropertyName <> "Size.Width" AndAlso PropertyName <> "Size.Height" Then Continue For
						Dim TempWS As UString
						TempWS = tb->ReadObjProperty(pSelectedControls->Item(j), PropertyName_)
						If TempWS <> plvProperties->Nodes.Item(i)->Text(1) Then
							plvProperties->Nodes.Item(i)->Text(1) = TempWS
							ChangeControl(*tb->Des, pSelectedControls->Item(j), PropertyName_)
						End If
					Next i
				End If
				#ifndef __USE_GTK__
					Dim As SymbolsType Ptr st = tb->Des->Symbols(pSelectedControls->Item(j))
					If st AndAlso st->ReadPropertyFunc Then
						If QWString(st->ReadPropertyFunc(pSelectedControls->Item(j), "ClassName")) = "MenuItem" Then
							tb->Des->TopMenu->Repaint
							If pfMenuEditor->Visible Then pfMenuEditor->Repaint
						ElseIf QWString(st->ReadPropertyFunc(pSelectedControls->Item(j), "ClassName")) = "ToolButton" Then
							If pfMenuEditor->Visible Then pfMenuEditor->Repaint
						End If
					End If
				#endif
			Next j
			bNotDesignForms = True
			.Changed "Unsurni o`zgartirish"
			bNotDesignForms = False
			pfrmMain->UpdateUnLock
		End If
		.PaintControl(True)
	End With
End Sub

Sub DesignerModified(ByRef Sender As Designer, Ctrl As Any Ptr, PropertyName As String = "", BeforeCtrl As Any Ptr = 0, AfterCtrl As Any Ptr = 0, iLeft As Integer = -1, iTop As Integer = -1, iWidth As Integer = -1, iHeight As Integer = -1)
	Dim tb As TabWindow Ptr = Sender.Tag
	If tb = 0 Then Exit Sub
	With tb->txtCode
		pfrmMain->UpdateLock
		If PropertyName = "" Then
			Dim GridPropertyName As String
			Dim TempWS As UString
			For i As Integer = 0 To plvProperties->Nodes.Count - 1
				GridPropertyName = GetItemText(plvProperties->Nodes.Item(i))
				If GridPropertyName = "Left" OrElse GridPropertyName = "Top" OrElse GridPropertyName = "Width" OrElse GridPropertyName = "Height" Then
					TempWS = tb->ReadObjProperty(tb->Des->SelectedControl, GridPropertyName)
					If TempWS <> plvProperties->Nodes.Item(i)->Text(1) Then
						plvProperties->Nodes.Item(i)->Text(1) = TempWS
						If CInt(plvProperties->Nodes.Item(i) = plvProperties->SelectedItem) AndAlso CInt(ptxtPropertyValue->Visible) Then
							ptxtPropertyValue->Text = plvProperties->Nodes.Item(i)->Text(1)
						End If
					End If
				End If
			Next i
		End If
		.Changing "Unsurni o`zgartirish"
		ChangeControl(Sender, Ctrl, PropertyName, BeforeCtrl, AfterCtrl, iLeft, iTop, iWidth, iHeight)
		bNotDesignForms = True
		.Changed "Unsurni o`zgartirish"
		bNotDesignForms = False
		'tb->FormDesign True
		tb->txtCode.PaintControl True
		pfrmMain->UpdateUnLock
	End With
End Sub

Sub DesignerInsertControl(ByRef Sender As Designer, ByRef ClassName As String, Ctrl As Any Ptr, CopiedCtrl As Any Ptr, BeforeCtrl As Any Ptr, iLeft2 As Integer, iTop2 As Integer, iWidth2 As Integer, iHeight2 As Integer)
	On Error Goto ErrorHandler
	Dim tb As TabWindow Ptr = Sender.Tag
	If tb = 0 Then Exit Sub
	If tb->Des = 0 Then Exit Sub
	If tb->Des->DesignControl = 0 Then Exit Sub
	If Ctrl = 0 Then Exit Sub
	Dim As SymbolsType Ptr stDesignControl = tb->Des->Symbols(tb->Des->DesignControl)
	Dim As SymbolsType Ptr st = tb->Des->Symbols(Ctrl)
	Dim As SymbolsType Ptr stCopied = tb->Des->Symbols(CopiedCtrl)
	If stDesignControl = 0 OrElse stDesignControl->ReadPropertyFunc = 0 Then Exit Sub
	If st = 0 OrElse st->ReadPropertyFunc = 0 Then Exit Sub
	Dim As UString LibraryPath = Replace(GetRelative(GetFolderName(st->Path, False), ExePath), "\", "/")
	If tb->Project <> 0 AndAlso Not tb->Project->Components.Contains(LibraryPath) Then tb->Project->Components.Add LibraryPath
	Dim NewName As String = WGet(st->ReadPropertyFunc(Ctrl, "Name"))
	tb->cboClass.Items.Add NewName, Ctrl, ClassName, ClassName, , 1, tb->FindControlIndex(NewName)
	'tb->txtCode.SaveToFile(GetBakFileName(tb->FileName), tb->FileEncoding, tb->NewLineType)
	'tb->AutoSaveCharCount = 0
	Dim As EditControl txtCodeBi
	Dim As EditControl Ptr ptxtCode, ptxtCodeBi
	Dim As Integer iStart, iEnd, j
	Dim As Boolean bFind, IsBas = EndsWith(LCase(tb->FileName), ".bas") OrElse EndsWith(LCase(tb->FileName), ".frm")
	Dim tbi As TypeElement Ptr
	If SelectedTool <> 0 Then
		tbi = SelectedTool->Tag
		SelectedTool->Checked = False
		SelectedClass = ""
		SelectedTool = 0
		SelectedType = 0
	End If
	Var Idx = -1
	If CBool(tbi = 0) AndAlso CBool(CopiedCtrl <> 0) AndAlso CBool(stCopied <> 0) AndAlso CBool(stCopied->ReadPropertyFunc <> 0) AndAlso Comps.Contains(WGet(stCopied->ReadPropertyFunc(CopiedCtrl, "ClassName")), , , , Idx) Then
		tbi = Comps.Object(Idx)
	End If
	If tbi <> 0 Then
		Dim As String frmName
		frmName = WGet(stDesignControl->ReadPropertyFunc(tb->Des->DesignControl, "Name"))
		Var t = False, b = False
		Var k = 0
		tb->txtCode.Changing "Unsur qo`shish"
		For i As Integer = 0 To tb->txtCode.LinesCount - 1
			GetBiFile(ptxtCode, txtCodeBi, ptxtCodeBi, tb, IsBas, bFind, i, iStart, iEnd)
			For k As Integer = iStart To iEnd
				If StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "#include ") Then
					b = True
					If InStr(LCase(ptxtCode->Lines(k)), """" & LCase(tbi->IncludeFile & """")) Then
						t = True
						Exit For, For
					End If
				ElseIf b Then
					j = k
					Exit For, For
				End If
			Next
		Next
		Var InsLineCount = 0
		If Not t Then
			CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
			ptxtCode->InsertLine j, ..Left(ptxtCode->Lines(j - 1), Len(ptxtCode->Lines(j - 1)) - Len(LTrim(ptxtCode->Lines(j - 1), Any !"\t "))) & "#include once """ & tbi->IncludeFile & """"
			InsLineCount += 1
			tb->ConstructorStart += 1
			tb->ConstructorEnd += 1
		End If
	End If
	ChangeControl(Sender, Ctrl, , BeforeCtrl, , iLeft2, iTop2, iWidth2, iHeight2)
	If CopiedCtrl <> 0 Then
		FPropertyItems.Clear
		tb->FillProperties ClassName
		FPropertyItems.Sort
		For i As Integer = 0 To FPropertyItems.Count - 1
			Select Case FPropertyItems.Item(i)
			Case "Left", "Top", "Width", "Height", "Name", "ID", "TabIndex", "ClassName", "Parent", "Location", "Size"
			Case Else
				If Trim(tb->ReadObjProperty(Ctrl, FPropertyItems.Item(i))) <> Trim(tb->ReadObjProperty(CopiedCtrl, FPropertyItems.Item(i))) Then
					tb->WriteObjProperty(Ctrl, FPropertyItems.Item(i), tb->ReadObjProperty(CopiedCtrl, FPropertyItems.Item(i)))
					ChangeControl Sender, Ctrl, FPropertyItems.Item(i), 0, 0, iLeft2, iTop2, iWidth2, iHeight2
				End If
			End Select
		Next
	End If
	If stDesignControl->ControlSetFocusSub <> 0 Then stDesignControl->ControlSetFocusSub(tb->Des->DesignControl)
	bNotDesignForms = True
	tb->txtCode.Changed "Unsur qo`shish"
	If ptxtCodeBi <> 0 Then ptxtCodeBi->Changed "Unsur qo`shish"
	bNotDesignForms = False
	ToolGroupsToCursor
	Exit Sub
	ErrorHandler:
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " " & _
	"in function " & ZGet(Erfn()) & " " & _
	"in module " & ZGet(Ermn())
End Sub

Sub DesignerInsertComponent(ByRef Sender As Designer, ByRef ClassName As String, Cpnt As Any Ptr, CopiedCpnt As Any Ptr, BeforeCpnt As Any Ptr, iLeft2 As Integer, iTop2 As Integer)
	DesignerInsertControl(Sender, ClassName, Cpnt, CopiedCpnt, BeforeCpnt, iLeft2, iTop2, 16, 16)
End Sub

Sub DesignerInsertObject(ByRef Sender As Designer, ByRef ClassName As String, Obj As Any Ptr, CopiedObj As Any Ptr, BeforeObj As Any Ptr)
	DesignerInsertControl(Sender, ClassName, Obj, CopiedObj, BeforeObj, -1, -1, -1, -1)
End Sub

Sub DesignerInsertingControl(ByRef Sender As Designer, ByRef ClassName As String, ByRef AName As String)
	Dim tb As TabWindow Ptr = Sender.Tag
	If tb = 0 Then Exit Sub
	Dim PrevName As String = AName
	Dim NewName As String
	If CInt(PrevName <> ClassName) AndAlso CInt(PrevName <> "") AndAlso CInt(Not tb->cboClass.Items.Contains(PrevName)) Then
		NewName = PrevName
	Else
		'  for Control Array
		Dim As Integer CtrlArrayNum = -1
		If InStr(PrevName,"(") < 1 Then
			Var n = 0
			Do
				n = n + 1
				NewName = AName & Str(n)
			Loop While (tb->cboClass.Items.Contains(NewName) OrElse tb->cboClass.Items.Contains(NewName & "(0)")) ' Ctrl Array
		Else
			Var n = 0
			AName = StringExtract(PrevName, "(")
			Do
				n = n + 1
				NewName = AName & "(" & Str(n) & ")"
			Loop While tb->cboClass.Items.Contains(NewName)
		End If
	End If
	AName = NewName
End Sub

Sub cboClass_Change(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	If Sender.Parent = 0 Then Exit Sub
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, Sender.Parent->Parent->Parent)
	If tb = 0 Then Exit Sub
	Var ii = Sender.ItemIndex
	If ii = -1 Then Exit Sub
	If ii = 0 Then
		With tb->cboFunction
			.Items.Clear
			.Items.Add WStr("(") & ML("Declarations") & ")" & WChr(0), , "Sub", "Sub"
			.ItemIndex = 0
			Dim As String imgKey = "Sub"
			For i As Integer = 0 To tb->txtCode.Content.Functions.Count - 1
				Var te = Cast(TypeElement Ptr, tb->txtCode.Content.Functions.Object(i))
				If te->ElementType = E_Property Then imgKey = "Property" Else imgKey = "Sub"
				.Items.Add te->DisplayName, te, imgKey, imgKey
			Next
		End With
	Else
		Dim Ctrl As Any Ptr = Cast(ComboBoxEx Ptr, @Sender)->Items.Item(Sender.ItemIndex)->Object
		If Ctrl = 0 Then Exit Sub
		'If Not Sender.Focused Then Exit Sub
		If tb->Des = 0 Then Exit Sub
		Dim As SymbolsType Ptr st = tb->Des->Symbols(Ctrl)
		If st AndAlso st->ReadPropertyFunc <> 0 Then
			#ifdef __USE_GTK__
				'tb->Des->SelectedControl = Ctrl
				'tb->Des->MoveDots(tb->Des->ReadPropertyFunc(Ctrl, "Widget"))
			#else
				Dim iParentCtrl As Any Ptr = tb->Des->GetParentControl(Ctrl)
				If iParentCtrl <> 0 Then tb->Des->BringToFront iParentCtrl
				tb->Des->SelectedControls.Clear
				tb->Des->SelectedControl = Ctrl
				Dim As HWND Ptr hw = st->ReadPropertyFunc(Ctrl, "Handle")
				If hw <> 0 Then tb->Des->MoveDots(Ctrl, False) Else tb->Des->MoveDots(0, False)
				DesignerChangeSelection *tb->Des, Ctrl
			#endif
		End If
	End If
End Sub

Sub OnLinkClickedEdit(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Link1 As WString)
	Var tb = Cast(TabWindow Ptr, Sender.Tag)
	If tb = 0 Then Exit Sub
	AddTab GetRelativePath(Link1, tb->FileName)
End Sub

Sub OnToolTipLinkClickedEdit(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Link1 As WString)
	If Trim(Link1)="" Then Exit Sub
	Dim As UString res(Any)
	Split(Link1, "~", res())
	If UBound(res) >= 3 Then
		If res(0) = *KeywordsHelpPath Then
			HelpOption.CurrentPath = ""
			'If InStr(Link1, "##") > 0 Then
			'	HelpOption.CurrentWord = "#" & res(4)
			'Else
			HelpOption.CurrentWord = res(3)
			'End If
			ThreadCounter(ThreadCreate_(@RunHelp, @HelpOption))
		Else
			SelectSearchResult res(0), Val(res(1)) + 1, , , , res(2)
		End If
	End If
End Sub

Function GetCorrectParam(ByVal Param As String) As String
	'Param = Trim(Param)
	If EndsWith(Param, """""") Then Param = ..Left(Param, Len(Param) - 2)
	If EndsWith(Param, "=") Then Param = ..Left(Param, Len(Param) - 1)
	Return Param
End Function

Sub OnUndoingEdit(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Var tb = Cast(TabWindow Ptr, Sender.Tag)
	If tb = 0 Then Exit Sub
	QuitThread tb->Project, tb
End Sub

Sub OnUndoEdit(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Var tb = Cast(TabWindow Ptr, Sender.Tag)
	If tb = 0 Then Exit Sub
	tb->FormDesign
End Sub

Sub OnRedoingEdit(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Var tb = Cast(TabWindow Ptr, Sender.Tag)
	If tb = 0 Then Exit Sub
	QuitThread tb->Project, tb
End Sub

Sub OnRedoEdit(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Var tb = Cast(TabWindow Ptr, Sender.Tag)
	If tb = 0 Then Exit Sub
	tb->FormDesign
End Sub

Sub OnLineAddingEdit(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByVal CurrentLine As Integer)
	Var tb = Cast(TabWindow Ptr, Sender.Tag)
	If tb = 0 Then Exit Sub
	QuitThread tb->Project, tb
End Sub

Sub OnLineRemovingEdit(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByVal CurrentLine As Integer)
	Var tb = Cast(TabWindow Ptr, Sender.Tag)
	If tb = 0 Then Exit Sub
	QuitThread tb->Project, tb
End Sub

Sub OnLineChangeEdit(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByVal CurrentLine As Integer, ByVal OldLine As Integer)
	Var tb = Cast(TabWindow Ptr, Sender.Tag)
	If tb = 0 Then Exit Sub
	bNotFunctionChange = True
	If TextChanged AndAlso tb->txtCode.SyntaxEdit Then
		With tb->txtCode
			'If Not .Focused Then bNotFunctionChange = False: Exit Sub
			If OldLine > -1 AndAlso OldLine < .Content.Lines.Count Then
				Dim As EditControlLine Ptr ecl = Cast(EditControlLine Ptr, .Content.Lines.Items[OldLine])
				If CInt(ecl->CommentIndex = 0) Then
					If CInt(EndsWith(RTrim(*ecl->Text), "++") OrElse EndsWith(RTrim(*ecl->Text), "--")) AndAlso CInt(IsArg(Asc(Mid(RTrim(*ecl->Text), Len(RTrim(*ecl->Text)) - 2, 1)))) Then
						Dim As UString res(Any), b
						Split(*ecl->Text, """", res())
						For j As Integer = 0 To UBound(res)
							If j = 0 Then
								b = res(0)
							ElseIf j Mod 2 = 0 Then
								b &= """" & res(j)
							Else
								b &= """" & WSpace(Len(res(j)))
							End If
						Next
						WLet(ecl->Text, RTrim(..Left(*ecl->Text, Len(RTrim(*ecl->Text)) - 2)) & Right(RTrim(*ecl->Text), 1) & "=1")
						b &= "1"
					End If
					If ChangeKeyWordsCase Then
						
					End If
					If AddSpacesToOperators Then
						tb->AddSpaces OldLine, OldLine
						'						Dim As UString c, cn, cp
						'						For i As Integer = Len(b) To 1 Step -1
						'							c = Mid(b, i, 1)
						'							cn = Mid(b, i + 1, 1)
						'							cp = Mid(b, i - 1, 1)
						'							If InStr("+-*/\<>&=',:;", c) Then
						'								If CInt(IsArg(Asc(cn)) OrElse InStr("{[("")]}*@", cn) > 0) AndAlso CInt(Mid(*ecl->Text, i, 2) <> "&H" AndAlso CInt(c <> "'")) AndAlso CInt(c <> "-" OrElse InStr("+-*/=", Right(RTrim(..Left(*ecl->Text, i - 1)), 1)) = 0 AndAlso LCase(Right(RTrim(..Left(*ecl->Text, i - 1)), 6)) <> "return") AndAlso CInt(Mid(*ecl->Text, i - 1, 2) <> "->") AndAlso CInt(CInt(c <> "*") OrElse CInt(IsNumeric(cn)) OrElse CInt(Not IsArg(Asc(cn)))) OrElse CInt(InStr(",:;", c) > 0 AndAlso cn <> "" AndAlso cn <> " " AndAlso cn <> !"\t") Then
						'									WLetEx ecl->Text, ..Left(*ecl->Text, i) & " " & Mid(*ecl->Text, i + 1), True
						'								End If
						'								If CInt(CInt(IsArg(Asc(cp)) OrElse InStr("{[("")]}", cp) > 0) AndAlso CInt(c <> ",") AndAlso CInt(c <> ":") AndAlso CInt(c <> ";") AndAlso CInt(Mid(*ecl->Text, i, 2) <> "->") AndAlso CInt(CInt(c <> "*") OrElse CInt(IsNumeric(cn)) OrElse CInt(Not IsArg(Asc(cn))))) OrElse CInt(CInt(c = "-") AndAlso CInt(cp <> " ") AndAlso CInt(cp <> !"\t") AndAlso CInt(IsArg(Asc(cn))) AndAlso CInt(InStr("+-*/=", Right(RTrim(..Left(*ecl->Text, i - 1)), 1)) > 0)) Then
						'									WLetEx ecl->Text, ..Left(*ecl->Text, i - 1) & " " & Mid(*ecl->Text, i), True
						'								End If
						'							End If
						'						Next
						'If Trim(*ecl->Text, Any !"\t ") <> "" Then WLetEx ecl->Text, RTrim(*ecl->Text, Any !"\t "), True
					End If
				End If
			End If
			If tb->tbrTop.Buttons.Item("Code")->Checked AndAlso CBool(OldLine = -1 OrElse (OldLine >= tb->ConstructorStart AndAlso OldLine <= tb->ConstructorEnd)) Then
				tb->FormNeedDesign = True
			End If
			tb->FormDesign bNotDesignForms OrElse tb->tbrTop.Buttons.Item("Code")->Checked OrElse (CBool(OldLine < tb->ConstructorStart) AndAlso CBool(OldLine <> -1)) OrElse CBool(OldLine > tb->ConstructorEnd) 'Not EndsWith(tb->cboFunction.Text, " [Constructor]")
		End With
		TextChanged = False
	End If
	'    If tb->cboClass.ItemIndex <> 0 Then
	'        tb->cboClass.ItemIndex = 0
	'        cboClass_Change tb->cboClass, 0
	'    End If
	If tb->cboClass.ItemIndex <> 0 Then
		tb->cboClass.ItemIndex = 0
		cboClass_Change *tb->cboClass.Designer, tb->cboClass, 0
	End If
	Dim As TypeElement Ptr te1, te2
	Dim t As Boolean
	For i As Integer = 0 To tb->txtCode.Content.Functions.Count - 1
		te2 = tb->txtCode.Content.Functions.Object(i)
		If te2 = 0 Then Continue For
		If te2->StartLine <= CurrentLine And te2->EndLine >= CurrentLine Then
			If tb->cboFunction.ItemIndex <> i + 1 Then tb->cboFunction.ItemIndex = i + 1
			t = True
			bNotFunctionChange = False
			Exit Sub
			'For j As Integer = 1 To tb->cboFunction.Items.Count - 1
			'                If te2 = tb->cboFunction.Items.Item(j)->Object Then
			'                	tb->cboFunction.ItemIndex = j
			'                    t = True
			'                    bNotFunctionChange = False
			'                    Exit Sub
			'                End If
			'            Next
		End If
	Next
	tb->cboFunction.ItemIndex = 0
	bNotFunctionChange = False
End Sub

Function GetOnlyArguments(ArgumentsLine As String) As String
	Dim As UString res(Any)
	Dim As Integer Pos1
	Dim As String Result
	Split(Mid(..Left(ArgumentsLine, Len(ArgumentsLine) - 1), 2), ",", res())
	For i As Integer = 0 To UBound(res)
		If Trim(LCase(res(i))) = "byref designer as my.sys.object" Then Continue For
		If StartsWith(LTrim(LCase(res(i))), "byref ") OrElse StartsWith(LTrim(LCase(res(i))), "byval ") Then
			res(i) = Mid(res(i), 7)
		End If
		Pos1 = InStr(LCase(res(i)), " as ")
		If Pos1 > 0 Then
			res(i) = ..Left(res(i), Pos1 - 1)
		End If
		If Result = "" Then
			Result = Trim(res(i))
		Else
			Result &= ", " & Trim(res(i))
		End If
	Next
	Return "(" & Result & ")"
End Function

Sub FindEvent(tbw As TabWindow Ptr, Cpnt As Any Ptr, EventName As String)
	On Error Goto ErrorHandler
	If Cpnt = 0 Then Exit Sub
	Dim As TabWindow Ptr tb = ptabRight->Tag
	If tb = 0 Then
		tb = tbw
	End If
	If tb = 0 Then Exit Sub
	If tb->Des = 0 Then Exit Sub
	If tb->Des->DesignControl = 0 Then Exit Sub
	Dim As SymbolsType Ptr st = tb->Des->Symbols(Cpnt)
	Dim As SymbolsType Ptr stDesignControl = tb->Des->Symbols(tb->Des->DesignControl)
	If st = 0 OrElse st->ReadPropertyFunc = 0 Then Exit Sub
	If stDesignControl = 0 OrElse stDesignControl->ReadPropertyFunc = 0 Then Exit Sub
	Dim frmName As String
	Dim frmTypeName As String
	frmName = WGet(stDesignControl->ReadPropertyFunc(tb->Des->DesignControl, "Name"))
	If Cpnt = 0 Then Exit Sub
	Dim CtrlName As String = WGet(st->ReadPropertyFunc(Cpnt, "Name"))
	If Cpnt = tb->Des->DesignControl Then CtrlName = "This"
	Dim As String CtrlName2 = CtrlName
	If InStr(CtrlName, "(") Then
		CtrlName2 = StringExtract(CtrlName2, "(")
	ElseIf CtrlName = "This" Then
		CtrlName2 = "Form"
	End If
	Var EventName2 = Mid(EventName, IIf(StartsWith(LCase(EventName), "on"), 3, 1))
	Dim As String SubName = CtrlName2 & "_" & EventName2, SubNameNew
	SubNameNew = SubName
	Var ii = tb->cboClass.ItemIndex
	Var jj = tb->cboFunction.ItemIndex
	If ii < 0 Then Exit Sub
	Dim As EditControl Ptr ptxtCode, ptxtCodeBi, ptxtCodeType, ptxtCodeConstructor
	Dim As EditControl txtCodeBi
	Dim As Boolean bFind, IsBas = EndsWith(LCase(tb->FileName), ".bas") OrElse EndsWith(LCase(tb->FileName), ".frm")
	Dim As Integer iStart, iEnd, i, k
	Dim As WString Ptr FLine1
	Dim As WStringList WithArgs
	Dim As String WithCtrlName
	Var bWith = False
	WLet(FLine1, "")
	tb->txtCode.Changing "Hodisa qo`shish"
	ChangeControl *tb->Des, Cpnt
	Dim As Boolean b, c, e, f, t, td, tdns, tt, tdes
	Dim As Integer j, l, p, LineEndType, LineEndConstructor
	For i = 0 To tb->txtCode.LinesCount - 1
		GetBiFile(ptxtCode, txtCodeBi, ptxtCodeBi, tb, IsBas, bFind, i, iStart, iEnd)
		For k As Integer = iStart To iEnd
			If (Not b) AndAlso (StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "type " & LCase(frmName) & " ") OrElse StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "class " & LCase(frmName) & " ")) Then
				b = True
				ptxtCodeType = ptxtCode
				frmTypeName = frmName
			ElseIf (Not b) AndAlso (StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "type " & LCase(frmName) & "type ") OrElse StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "class " & LCase(frmName) & "type ")) Then
				b = True
				ptxtCodeType = ptxtCode
				frmTypeName = frmName & "Type"
			ElseIf b Then
				If Not e Then
					If StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t ") & " ", "end type ") OrElse StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t ") & " ", "end class ") OrElse StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t ") & " ", "__startofclassbody__ ") Then
						e = True: LineEndType = k
					ElseIf StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "declare constructor") Then
						j = k
					ElseIf StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "declare static") Then
						l = k
						If StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "declare static sub " & LCase(SubName)) OrElse StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "declare static function " & LCase(SubName)) Then
							td = True
						End If
					End If
				ElseIf e Then
					If (Not c) AndAlso StartsWith(LCase(Trim(ptxtCode->Lines(k), Any !"\t ")) & " ", "constructor " & LCase(frmTypeName) & " ") Then
						c = True
						ptxtCodeConstructor = ptxtCode
					ElseIf c Then
						If Not f Then
							If StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "with ") Then
								WithArgs.Add Trim(Mid(Trim(ptxtCode->Lines(k), Any !"\t "), 5), Any !"\t ")
							ElseIf StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "end with") Then
								If WithArgs.Count > 0 Then WithArgs.Remove WithArgs.Count - 1
							ElseIf CInt(StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")), LCase(CtrlName & "."))) OrElse CInt(CInt(WithArgs.Count > 0) AndAlso CInt(WithArgs.Item(WithArgs.Count - 1) = CtrlName) AndAlso CInt(StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "."))) Then
								p = k
								bWith = WithArgs.Count > 0 AndAlso WithArgs.Item(WithArgs.Count - 1) = CtrlName
								Var p1 = InStr(ptxtCode->Lines(k), ".")
								If p1 Then
									If CInt(EventName <> "") AndAlso CInt(StartsWith(Mid(LCase(ptxtCode->Lines(k)), p1 + 1), LCase(EventName & "="))) OrElse _
										CInt(StartsWith(Mid(LCase(ptxtCode->Lines(k)), p1 + 1), LCase(EventName & " "))) Then
										Var Pos1 = InStr(ptxtCode->Lines(k), "=")
										If Pos1 > 0 Then
											SubName = Trim(Mid(ptxtCode->Lines(k), Pos1 + 1))
											tt = True
											If StartsWith(SubName, "@") Then
												SubName = Mid(SubName, 2)
											ElseIf StartsWith(LCase(SubName), "cast(sub(byref designer as my.sys.object,") Then
												Var Pos1 = InStr(SubName, "@")
												SubName = Trim(Mid(SubName, Pos1 + 1))
												SubName = ..Left(SubName, Len(SubName) - 1)
											End If
										End If
									ElseIf CInt(StartsWith(Mid(LCase(ptxtCode->Lines(k)), p1 + 1), "designer=")) OrElse _
										CInt(StartsWith(Mid(LCase(ptxtCode->Lines(k)), p1 + 1), "designer ")) Then
										tdes = True
									End If
								End If
							ElseIf StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")), "end constructor") Then
								f = True : LineEndConstructor = k + 1
							End If
						ElseIf f Then
							If StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")), LCase("Public Sub " & frmTypeName & "." & SubName)) OrElse _
								StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")), LCase("Private Sub " & frmTypeName & "." & SubName)) OrElse _
								StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")), LCase("Sub " & frmTypeName & "." & SubName)) OrElse _
								StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")), LCase("Public Sub " & frmTypeName & "._" & SubName)) OrElse _
								StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")), LCase("Private Sub " & frmTypeName & "._" & SubName)) OrElse _
								StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")), LCase("Sub " & frmTypeName & "._" & SubName)) OrElse _
								StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")), LCase("Public Function " & frmTypeName & "." & SubName)) OrElse _
								StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")), LCase("Private Function " & frmTypeName & "." & SubName)) OrElse _
								StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")), LCase("Function " & frmTypeName & "." & SubName)) OrElse _
								StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")), LCase("Public Function " & frmTypeName & "._" & SubName)) OrElse _
								StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")), LCase("Private Function " & frmTypeName & "._" & SubName)) OrElse _
								StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")), LCase("Function " & frmTypeName & "._" & SubName)) Then
								Var n = Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))
								ptxtCode->SetSelection k + 1, k + 1, n + Len(TabSpace), n + Len(TabSpace)
								ptxtCode->TopLine = k
								ptxtCode->SetFocus
								OnLineChangeEdit *tb->txtCode.Designer, tb->txtCode, i + 1, i + 1
								SetCodeVisible tb
								t = True
								Exit Sub
							End If
						End If
					End If
				End If
			End If
		Next k
		ptxtCode = @tb->txtCode
		iStart = i + 1
		iEnd = i + 1
	Next i
	If Not t Then
		Dim As TypeElement Ptr te = GetPropertyType(WGet(st->ReadPropertyFunc(Cpnt, "ClassName")), EventName)
		Dim As Integer q1, q2, q
		If te = 0 Then Exit Sub
		Var Pos1 = InStr(te->TypeName, "(")
		If Not td Then
			ptxtCode = ptxtCodeType
			CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
			If CreateNonStaticEventHandlers Then
				If CreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt AndAlso InStr(LCase(te->TypeName), "(byref designer as my.sys.object,") > 0 Then
					ptxtCode->InsertLine j, ..Left(ptxtCode->Lines(j), Len(ptxtCode->Lines(j)) - Len(LTrim(ptxtCode->Lines(j), Any !"\t "))) & "Declare " & Left(te->TypeName, Pos1 - 1) & " " & SubName & "(" & Trim(Mid(te->TypeName, Pos1 + 33))
					tb->ConstructorStart += 1
					tb->ConstructorEnd += 1
					If ptxtCode = @tb->txtCode Then q1 = 1 Else q2 = 1
				Else
					If PlaceStaticEventHandlersAfterTheConstructor Then
						ptxtCode->InsertLine j, ..Left(ptxtCode->Lines(j), Len(ptxtCode->Lines(j)) - Len(LTrim(ptxtCode->Lines(j), Any !"\t "))) & "Declare Static " & Left(te->TypeName, Pos1 - 1) & " " & IIf(CreateStaticEventHandlersWithAnUnderscoreAtTheBeginning, "_", "") & SubName & IIf(Not CreateStaticEventHandlersWithAnUnderscoreAtTheBeginning, "_", "") & Mid(te->TypeName, Pos1)
					Else
						ptxtCode->InsertLine j, ..Left(ptxtCode->Lines(j), Len(ptxtCode->Lines(j)) - Len(LTrim(ptxtCode->Lines(j), Any !"\t "))) & "Declare Static " & Left(te->TypeName, Pos1 - 1) & " " & IIf(CreateStaticEventHandlersWithAnUnderscoreAtTheBeginning, "_", "") & SubName & IIf(Not CreateStaticEventHandlersWithAnUnderscoreAtTheBeginning, "_", "") & Mid(te->TypeName, Pos1)
					End If
					If InStr(LCase(te->TypeName), "(byref designer as my.sys.object,") > 0 Then
						ptxtCode->InsertLine j + 1, ..Left(ptxtCode->Lines(j), Len(ptxtCode->Lines(j)) - Len(LTrim(ptxtCode->Lines(j), Any !"\t "))) & "Declare " & Left(te->TypeName, Pos1 - 1) & " " & SubName & "(" & Trim(Mid(te->TypeName, Pos1 + 33))
					Else
						ptxtCode->InsertLine j + 1, ..Left(ptxtCode->Lines(j), Len(ptxtCode->Lines(j)) - Len(LTrim(ptxtCode->Lines(j), Any !"\t "))) & "Declare " & Left(te->TypeName, Pos1 - 1) & " " & SubName & Mid(te->TypeName, Pos1)
					End If
					tb->ConstructorStart += 2
					tb->ConstructorEnd += 2
					If ptxtCode = @tb->txtCode Then q1 = 2 Else q2 = 2
				End If
			Else
				ptxtCode->InsertLine j, ..Left(ptxtCode->Lines(j), Len(ptxtCode->Lines(j)) - Len(LTrim(ptxtCode->Lines(j), Any !"\t "))) & "Declare Static " & Left(te->TypeName, Pos1 - 1) & " " & SubName & Mid(te->TypeName, Pos1)
				tb->ConstructorStart += 1
				tb->ConstructorEnd += 1
				If ptxtCode = @tb->txtCode Then q1 += 1 Else q2 += 1
			End If
		End If
		If Not tt Then
			If c Then ptxtCode = ptxtCodeConstructor
			CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
			q = IIf(ptxtCode = @tb->txtCode, q1, q2)
			If bWith Then WithCtrlName = "" Else WithCtrlName = CtrlName
			If CreateNonStaticEventHandlers AndAlso Not tdes Then ptxtCode->InsertLine p + q, ..Left(ptxtCode->Lines(p + q), Len(ptxtCode->Lines(p + q)) - Len(LTrim(ptxtCode->Lines(p + q), Any !"\t "))) & WithCtrlName & ".Designer = @This": q += 1: If ptxtCode = @tb->txtCode Then q1 += 1 Else q2 += 1
			If CreateNonStaticEventHandlers AndAlso CreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt AndAlso InStr(LCase(te->TypeName), "(byref designer as my.sys.object,") > 0 Then
				ptxtCode->InsertLine p + q, ..Left(ptxtCode->Lines(p + q), Len(ptxtCode->Lines(p + q)) - Len(LTrim(ptxtCode->Lines(p + q), Any !"\t "))) & WithCtrlName & "." & EventName & " = Cast(" & Left(te->TypeName, Pos1 - 1) & "(ByRef Designer As My.Sys.Object, " & Trim(Mid(te->TypeName, Pos1 + 33)) & ", @" & SubName & ")"
			Else
				ptxtCode->InsertLine p + q, ..Left(ptxtCode->Lines(p + q), Len(ptxtCode->Lines(p + q)) - Len(LTrim(ptxtCode->Lines(p + q), Any !"\t "))) & WithCtrlName & "." & EventName & " = @" & IIf(CreateNonStaticEventHandlers AndAlso CreateStaticEventHandlersWithAnUnderscoreAtTheBeginning, "_", "") & SubName & IIf(CreateNonStaticEventHandlers AndAlso Not CreateStaticEventHandlersWithAnUnderscoreAtTheBeginning, "_", "")
			End If
			tb->ConstructorEnd += 1
			If ptxtCode = @tb->txtCode Then q1 += 1 Else q2 += 1
		End If
		ptxtCode = @tb->txtCode
		q = q1
		If LineEndConstructor < 1 Then LineEndConstructor = i - 1
		
		ptxtCode->InsertLine i + q, ""
		If CreateNonStaticEventHandlers Then
			If CreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt AndAlso InStr(LCase(te->TypeName), "(byref designer as my.sys.object,") > 0 Then
			Else
				SubNameNew = IIf(CreateStaticEventHandlersWithAnUnderscoreAtTheBeginning, "_", "") & SubName & IIf(Not CreateStaticEventHandlersWithAnUnderscoreAtTheBeginning, "_", "")
				If PlaceStaticEventHandlersAfterTheConstructor Then
					Dim As String LeftTabSpace = ..Left(ptxtCode->Lines(LineEndConstructor + q), Len(ptxtCode->Lines(LineEndConstructor + q)) - Len(LTrim(ptxtCode->Lines(LineEndConstructor + q), Any !"\t ")))
					ptxtCode->InsertLine LineEndConstructor + 1 + q, LeftTabSpace
					ptxtCode->InsertLine LineEndConstructor + q + 1, LeftTabSpace & "Private " & Left(te->TypeName, Pos1 - 1) & " " & frmTypeName & "." & SubNameNew & Mid(te->TypeName, Pos1)
					ptxtCode->InsertLine LineEndConstructor + q + 2, LeftTabSpace & TabSpace & IIf(Pos1 = 4, "", "Return ") & "(*Cast(" & frmTypeName & " Ptr, Sender.Designer))." & SubName & GetOnlyArguments(Mid(te->TypeName, Pos1))
					ptxtCode->InsertLine LineEndConstructor + q + 3, LeftTabSpace & "End " & Left(te->TypeName, Pos1 - 1)
					q += 4
				Else
					ptxtCode->InsertLine i + q + 1, "Private " & Left(te->TypeName, Pos1 - 1) & " " & frmTypeName & "." & SubNameNew & Mid(te->TypeName, Pos1)
					ptxtCode->InsertLine i + q + 2, TabSpace & IIf(Pos1 = 4, "", "Return ") & "(*Cast(" & frmTypeName & " Ptr, Sender.Designer))." & SubName & GetOnlyArguments(Mid(te->TypeName, Pos1))
					ptxtCode->InsertLine i + q + 3, "End " & Left(te->TypeName, Pos1 - 1)
					q += 3
				End If
			End If
		End If
		If CreateNonStaticEventHandlers AndAlso InStr(LCase(te->TypeName), "(byref designer as my.sys.object,") > 0 Then
			ptxtCode->InsertLine i + q + 1, "Private " & Left(te->TypeName, Pos1 - 1) & " " & frmTypeName & "." & SubName & "(" & Trim(Mid(te->TypeName, Pos1 + 33))
		Else
			ptxtCode->InsertLine i + q + 1, "Private " & Left(te->TypeName, Pos1 - 1) & " " & frmTypeName & "." & SubName & Mid(te->TypeName, Pos1)
		End If
		If InStr(CtrlName, "(") Then
			ptxtCode->InsertLine i + q + 2, TabSpace & "Dim As Integer Index = Val(Mid(Sender.Name, InStrRev(Sender.Name, ""("") + 1))"
		Else
			ptxtCode->InsertLine i + q + 2, TabSpace
		End If
		ptxtCode->InsertLine i + q + 3, "End " & Left(te->TypeName, Pos1 - 1)
		bNotDesignForms = True
		ptxtCode->SetSelection i + q + 2, i + q + 2, Len(TabSpace), Len(TabSpace)
		ptxtCode->TopLine = i + q + 1
		ptxtCode->Changed "Hodisa qo`shish"
		ptxtCode->SetFocus
		If plvEvents->Nodes.Contains(EventName) Then
			plvEvents->Nodes.Item(plvEvents->Nodes.IndexOf(EventName))->Text(1) = SubNameNew
		End If
		tb->Events.Add EventName, SubNameNew, Cpnt
		OnLineChangeEdit *tb->txtCode.Designer, tb->txtCode, i + q + 2, i + q + 2
		SetCodeVisible tb
		bNotDesignForms = False
	End If
	WDeAllocate(FLine1)
	Exit Sub
	ErrorHandler:
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " " & _
	"in function " & ZGet(Erfn()) & " " & _
	"in module " & ZGet(Ermn())
End Sub

Sub cboFunction_Change(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	If bNotFunctionChange Then Exit Sub
	If Sender.Parent = 0 Then Exit Sub
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, Sender.Parent->Parent->Parent)
	If tb = 0 Then Exit Sub
	'If frmMain.ActiveControl AndAlso frmMain.ActiveControl->ClassName = "EditControl" Then Exit Sub
	Dim frmName As String
	If tb->Des <> 0 AndAlso tb->Des->Symbols(tb->Des->DesignControl) AndAlso tb->Des->Symbols(tb->Des->DesignControl)->ReadPropertyFunc <> 0 AndAlso tb->Des->DesignControl <> 0 Then frmName = WGet(tb->Des->Symbols(tb->Des->DesignControl)->ReadPropertyFunc(tb->Des->DesignControl, "Name"))
	Var ii = tb->cboClass.ItemIndex
	Var jj = tb->cboFunction.ItemIndex
	If ii < 0 Then Exit Sub
	Dim As Boolean b, c, e, f, t, td, tdns, tt, ttns
	Dim As Integer i, j, k, l
	With tb->txtCode
		If ii = 0 Then
			If jj = 0 Then
				.SetFocus
				.SetSelection 0, 0, 0, 0
				t = True
			ElseIf jj > 0 Then
				Dim te As TypeElement Ptr
				Dim i As Integer
				te = tb->cboFunction.Items.Item(jj)->Object
				If te <> 0 Then
					i = te->StartLine
					Var n = Len(.Lines(i)) - Len(LTrim(.Lines(i)))
					If te->Declaration Then
						.SetSelection i, i, n, n
					Else
						.SetSelection i + 1, i + 1, n, n
					End If
					.TopLine = i
					.SetFocus
					t = True
				End If
				SetCodeVisible tb
			End If
			Exit Sub
		ElseIf ii = 1 And jj = 0 Then
			For i = 0 To .LinesCount - 1
				If StartsWith(Trim(LCase(.Lines(i))), "type " & LCase(frmName) & " ") Then
					Var n = Len(.Lines(i)) - Len(LTrim(.Lines(i)))
					.TopLine = i
					.SetSelection i + 1, i + 1, n + 4, n + 4
					.SetFocus
					t = True
					Exit Sub
				End If
			Next i
		ElseIf Sender.ItemIndex <> -1 Then
			FindEvent tb, tb->cboClass.Items.Item(tb->cboClass.ItemIndex)->Object, tb->cboFunction.Items.Item(Sender.ItemIndex)->Text
		End If
	End With
End Sub

Sub DesignerDblClickControl(ByRef Sender As Designer, Ctrl As Any Ptr)
	Dim tb As TabWindow Ptr = Sender.Tag
	If tb = 0 Then Exit Sub
	frmMain.UpdateLock
	Dim As SymbolsType Ptr st = tb->Des->Symbols(Ctrl)
	If st = 0 OrElse st->ReadPropertyFunc = 0 Then Exit Sub
	Select Case QWString(st->ReadPropertyFunc(Ctrl, "ClassName"))
	Case "MainMenu", "PopupMenu"
		pfMenuEditor->tb = tb
		pfMenuEditor->Des = @Sender
		pfMenuEditor->CurrentMenu = Ctrl
		pfMenuEditor->CurrentToolBar = 0
		pfMenuEditor->CurrentStatusBar = 0
		pfMenuEditor->ParentRect = 0
		pfMenuEditor->Caption = ML("Menu Editor") & ": " & QWString(st->ReadPropertyFunc(Ctrl, "Name"))
		pfMenuEditor->Repaint
		pfMenuEditor->Show *pfrmMain
	Case "ToolBar"
		pfMenuEditor->tb = tb
		pfMenuEditor->Des = @Sender
		pfMenuEditor->CurrentMenu = 0
		pfMenuEditor->CurrentToolBar = Ctrl
		pfMenuEditor->CurrentStatusBar = 0
		pfMenuEditor->Caption = ML("ToolBar Editor") & ": " & QWString(st->ReadPropertyFunc(Ctrl, "Name"))
		pfMenuEditor->Repaint
		pfMenuEditor->Show *pfrmMain
	Case "StatusBar"
		pfMenuEditor->tb = tb
		pfMenuEditor->Des = @Sender
		pfMenuEditor->CurrentMenu = 0
		pfMenuEditor->CurrentToolBar = 0
		pfMenuEditor->CurrentStatusBar = Ctrl
		pfMenuEditor->Caption = ML("StatusBar Editor") & ": " & QWString(st->ReadPropertyFunc(Ctrl, "Name"))
		pfMenuEditor->Repaint
		pfMenuEditor->Show *pfrmMain
	Case "ImageList"
		pfImageListEditor->tb = tb
		pfImageListEditor->Des = @Sender
		pfImageListEditor->CurrentImageList = Ctrl
		pfImageListEditor->Caption = ML("ImageList Editor") & ": " & QWString(st->ReadPropertyFunc(Ctrl, "Name"))
		pfImageListEditor->Show *pfrmMain
	Case Else
		If tb->cboFunction.Items.Count > 1 Then
			FindEvent tb, tb->cboClass.Items.Item(tb->cboClass.ItemIndex)->Object, "OnClick"
			If tb->tbrTop.Buttons.Item("CodeAndForm")->Checked Then
				tb->tbrTop.Buttons.Item("Code")->Checked = True
				tbrTop_ButtonClick *tb->tbrTop.Designer, tb->tbrTop, *tb->tbrTop.Buttons.Item("Code")
			End If
			'			tb->pnlCode.Visible = True
			'			tb->pnlForm.Visible = False
			'			tb->splForm.Visible = False
			'			tpProject->SelectTab
			'			tb->RequestAlign
		End If
	End Select
	frmMain.UpdateUnLock
End Sub

Sub DesignerClickMenuItem(ByRef Sender As Designer, MenuItem As Any Ptr)
	Dim tb As TabWindow Ptr = Sender.Tag
	If tb = 0 Then Exit Sub
	FindEvent tb, MenuItem, "OnClick"
	'	If tb->tbrTop.Buttons.Item(2)->Checked Then
	'		tb->tbrTop.Buttons.Item(1)->Checked = True
	'	End If
End Sub

Sub DesignerClickProperties(ByRef Sender As Designer, Ctrl As Any Ptr)
	Dim tb As TabWindow Ptr = Sender.Tag
	If tb = 0 Then Exit Sub
	tpProperties->SelectTab
End Sub

#ifdef __USE_GTK__
	Sub lvIntellisense_ItemActivate(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
#else
	Sub cboIntellisense_Selected(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		If ItemIndex < 0 OrElse ItemIndex > Cast(ComboBoxEx Ptr, @Sender)->Items.Count - 1 Then Exit Sub
#endif
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	Dim sLine As WString Ptr = @tb->txtCode.Lines(SelLinePos)
	Dim As Integer i, Pos1, Pos2, Pos3, xStartPlus, xEndPlus, yStartPlus, yEndPlus
	Dim As String Symbol
	Dim As TypeElement Ptr te, teParam, teParamNew
	#ifdef __USE_GTK__
	With tb->txtCode.lvIntellisense
	#else
	With tb->txtCode.cboIntellisense
	#endif
		If tb->txtCode.FileDropDown Then
			Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
			tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
			i = iSelEndChar
			#ifdef __USE_GTK__
			If .ListItems.Item(ItemIndex)->ImageKey <> "Folder" Then Symbol = """"
			#else
			If .Items.Item(ItemIndex)->ImageKey <> "Folder" Then Symbol = """"
			#endif
		Else
			i = GetNextCharIndex(*sLine, SelCharPos)
		End If
		#ifdef __USE_GTK__
		If .ListItems.Item(ItemIndex) Then
			te = .ListItems.Item(ItemIndex)->Tag
		#else
		If .Items.Item(ItemIndex) Then
			te = .ItemData(ItemIndex)
		#endif
			If te <> 0 AndAlso te->ElementType = E_Snippet Then
				tb->txtCode.ClearCarets
				Dim As UString Parameters = te->Parameters
				Var n = Len(*sLine) - Len(LTrim(*sLine, Any !"\t "))
				Parameters = Replace(Parameters, !"\r", !"\r" & Left(*sLine, n))
				If te->Elements.Count > 0 AndAlso te->Elements.Object(0) > 0 Then
					teParam = te->Elements.Object(0)
					xStartPlus = teParam->StartChar
					xEndPlus = teParam->EndChar
					yStartPlus = teParam->StartLine
					yEndPlus = teParam->EndLine
				Else
					Pos2 = InStrRev(Parameters, !"\r")
					xStartPlus = Len(Parameters) - Pos2
					xEndPlus = xStartPlus
					yStartPlus = InStrCount(Parameters, !"\r")
					yEndPlus = yStartPlus
				End If
				For j As Integer = 0 To te->Elements.Count - 1
					teParam = te->Elements.Object(j)
					teParamNew = New TypeElement
					teParamNew->Name = teParam->Name
					teParamNew->DisplayName = teParam->DisplayName
					teParamNew->StartChar = teParam->StartChar + n
					teParamNew->StartLine = teParam->StartLine + SelLinePos
					teParamNew->EndChar = teParam->EndChar + n
					teParamNew->EndLine = teParam->EndLine + SelLinePos
					tb->txtCode.Carets.Add Val(teParam->Name), teParamNew
				Next
				tb->txtCode.CurrentCaret = 1
				tb->txtCode.ReplaceLine SelLinePos, ..Left(*sLine, SelCharPos) & Parameters & Symbol & Mid(*sLine, i + 1)
				tb->txtCode.SetSelection SelLinePos + yStartPlus, SelLinePos + yEndPlus, n + xStartPlus, n + xEndPlus
			Else
				#ifdef __USE_GTK__
					tb->txtCode.SetSelection SelLinePos, SelLinePos, SelCharPos, i, True
					tb->txtCode.ChangeText .ListItems.Item(ItemIndex)->Text(0) & Symbol
					'tb->txtCode.ReplaceLine SelLinePos, ..Left(*sLine, SelCharPos) & .ListItems.Item(ItemIndex)->Text(0) & Symbol & Mid(*sLine, i + 1)
					i = SelCharPos + Len(.ListItems.Item(ItemIndex)->Text(0) & Symbol)
				#else
					tb->txtCode.SetSelection SelLinePos, SelLinePos, SelCharPos, i, True
					tb->txtCode.ChangeText .Items.Item(ItemIndex)->Text & Symbol
					'tb->txtCode.ReplaceLine SelLinePos, ..Left(*sLine, SelCharPos) & .Items.Item(ItemIndex)->Text & Symbol & Mid(*sLine, i + 1)
					i = SelCharPos + Len(.Items.Item(ItemIndex)->Text & Symbol)
				#endif
				'tb->txtCode.SetSelection SelLinePos, SelLinePos, i, i
			End If
		End If
		tb->txtCode.SetFocus
		#ifdef __USE_GTK__
			tb->txtCode.CloseDropDown
		#endif
	End With
End Sub

Declare Sub tabCode_SelChange(ByRef Designer As My.Sys.Object, ByRef Sender As TabControl, newIndex As Integer)

Sub OnGotFocusEdit(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Var tb = Cast(TabWindow Ptr, Sender.Tag)
	If tb = 0 Then Exit Sub
	If tb->Index = -1 Then Exit Sub
	tb->txtCode.Content.ExternalIncludesLoaded = False
	If ptabCode <> tb->Parent Then
		ptabCode = tb->Parent
		tabCode_SelChange Designer, *ptabCode, tb->Index
	End If
End Sub

Function AddSorted(tb As TabWindow Ptr, ByRef Text As WString, te As TypeElement Ptr = 0, ByRef Starts As WString = "", ByRef c As Integer = 0, ByRef imgKey As WString = "Sub", bKeywords As Boolean = True, Files As WStringList Ptr = 0, FileLines As IntegerList Ptr = 0) As Boolean
	On Error Goto ErrorHandler
	Var Idx = -1
	If Starts <> "" AndAlso Not StartsWith(LCase(Text), LCase(Starts)) Then Return True
	If (Not bKeywords) AndAlso CBool(Files = 0 OrElse ((Not Files->Contains(te->FileName, , , , Idx)) OrElse (FileLines <> 0) AndAlso (FileLines->Item(Idx) <> -1) AndAlso te->StartLine > FileLines->Item(Idx))) Then Return True
	c += 1
	If c > IntellisenseLimit Then Return False
	Dim As String imgKeyNew = imgKey
	If te = 0 Then
		imgKeyNew = "StandartTypes"
	ElseIf te->ElementType = E_Sub Then
		imgKeyNew = "Sub"
	ElseIf te->ElementType = E_Function Then
		imgKeyNew = "Function"
	ElseIf te->ElementType = E_Namespace Then
		imgKeyNew = "Sub"
	ElseIf te->ElementType = E_Enum Then
		imgKeyNew = "Enum"
	ElseIf te->ElementType = E_EnumItem Then
		imgKeyNew = "EnumItem"
	ElseIf te->ElementType = E_Property Then
		imgKeyNew = "Property"
	ElseIf te->ElementType = E_Event Then
		imgKeyNew = "Event"
	ElseIf te->ElementType = E_Type OrElse te->ElementType = E_TypeCopy OrElse te->ElementType = E_Union Then
		imgKeyNew = "Type"
	ElseIf te->ElementType = E_Keyword OrElse te->ElementType = E_KeywordFunction OrElse te->ElementType = E_KeywordSub OrElse te->ElementType = E_KeywordOperator Then
		imgKeyNew = "StandartTypes"
	End If
	#ifdef __USE_GTK__
		Dim iIndex As Integer = -1
		With tb->txtCode.lvIntellisense.ListItems
			For i As Integer = 0 To .Count - 1
				If LCase(.Item(i)->Text(0)) = LCase(Text) Then
					Return True
				ElseIf LCase(.Item(i)->Text(0)) > LCase(Text) Then
					iIndex = i: Exit For
				End If
			Next i
			Var item = .Add(Text, imgKeyNew, , , iIndex)
			item->Tag = te
		End With
	#else
		Dim iIndex As Integer = -1
		With tb->txtCode.cboIntellisense.Items
			For i As Integer = 0 To .Count - 1
				If LCase(.Item(i)->Text) = LCase(Text) Then
					Return True
				ElseIf LCase(.Item(i)->Text) > LCase(Text) Then
					iIndex = i: Exit For
				End If
			Next i
			.Add Text, te, imgKeyNew, imgKeyNew, , , iIndex
		End With
	#endif
	Return True
	Exit Function
	ErrorHandler:
	MsgBox Text & " " & ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " (Handler line: " & __LINE__ & ") " & _
	"in function " & ZGet(Erfn()) & " (Handler function: " & __FUNCTION__ & ") " & _
	"in module " & ZGet(Ermn()) & " (Handler file: " & __FILE__ & ") "
End Function

Sub AddAllIncludedFiles(ByRef Files As WStringList, ByRef FileLines As IntegerList, ByRef Path As WString, OldFile As EditControlContent Ptr = 0)
	If Not Files.Contains(Path) Then
		Var Idx = Files.Add(Path)
		FileLines.Insert Idx, -1
		Dim As EditControlContent Ptr File = 0
		If OldFile = 0 Then
			If IncludeFiles.Contains(Path, , , , Idx) Then
				File = IncludeFiles.Object(Idx)
			End If
		Else
			File = OldFile
		End If
		If File <> 0 Then
			For i As Integer = 0 To File->Includes.Count - 1
				AddAllIncludedFiles Files, FileLines, File->Includes.Item(i), File->Includes.Object(i)
			Next
		End If
	End If
End Sub

Sub UpdateIncludedFilesList(ByRef Content As EditControlContent, ByRef Files As WStringList, ByRef FileLines As IntegerList, iSelStartLine As Integer)
	With Content
		Files.Clear
		FileLines.Clear
		For i As Integer = 0 To .ExternalFiles.Count - 1
			Var Idx = Files.Add(.ExternalFiles.Item(i))
			FileLines.Insert Idx, .ExternalFileLines.Item(i)
		Next
		For i As Integer = 0 To .ExternalIncludes.Count - 1
			AddAllIncludedFiles Files, FileLines, .ExternalIncludes.Item(i)
		Next
		For i As Integer = 0 To .Includes.Count - 1
			If .IncludeLines.Item(i) > iSelStartLine Then Exit For
			AddAllIncludedFiles Files, FileLines, .Includes.Item(i)
		Next
	End With
End Sub

Function AddExternalIncludes(ByRef Content As EditControlContent, ItemFile As EditControlContent Ptr, ByRef Path As WString, ByRef FileName As WString) As Boolean
	Dim As EditControlContent Ptr File
	If ItemFile = 0 Then
		Var Idx = -1
		If IncludeFiles.Contains(Path, , , , Idx) Then
			File = IncludeFiles.Object(Idx)
		End If
	Else
		File = ItemFile
	End If
	If File Then
		If File->FileName = FileName Then
			Return True
		End If
		For i As Integer = 0 To File->Includes.Count - 1
			If GetFolderName(File->Includes.Item(i)) <> GetFolderName(FileName) Then Continue For
			If Content.CheckedFiles.Contains(File->Includes.Item(i)) Then Continue For
			Content.CheckedFiles.Add File->Includes.Item(i)
			If AddExternalIncludes(Content, File->Includes.Object(i), File->Includes.Item(i), FileName) Then
				Var IncludedLine = File->IncludeLines.Item(i)
				Content.ExternalFiles.Add File->FileName
				Content.ExternalFileLines.Add IncludedLine - 1
				For j As Integer = 0 To File->Includes.Count - 1
					If File->IncludeLines.Item(j) > IncludedLine Then Exit For
					Content.ExternalIncludes.Add File->Includes.Item(j)
				Next
				Return True
			End If
		Next
	End If
	Return False
End Function

Sub FillFromConstructionBlock(cb As ConstructionBlock Ptr, ByRef Text As String)
	If cb = 0 Then Return
	If Text = "" Then
		Dim te As TypeElement Ptr
		For i As Integer = 0 To cb->Elements.Count - 1
			te = cb->Elements.Object(i)
			FListItems.Add te->Name, te
		Next i
	Else
		Var tIndex = cb->Elements.IndexOf(Text)
		If tIndex <> -1 Then
			Dim te As TypeElement Ptr
			For i As Integer = 0 To cb->Elements.Count - 1
				te = cb->Elements.Object(i)
				If te AndAlso LCase(te->Name) = LCase(Text) Then FListItems.Add te->Name, te
			Next i
		End If
	End If
	FillFromConstructionBlock(cb->InConstructionBlock, Text)
End Sub

Sub FillAllIntellisenses(ByRef Starts As WString = "")
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	#ifdef __USE_GTK__
		tb->txtCode.lvIntellisense.ListItems.Clear
	#else
		tb->txtCode.cboIntellisense.Items.Clear
	#endif
	If Not AddSorted(tb, "_", , Starts) Then Exit Sub
	Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	Dim c As Integer
	Dim As EditControlLine Ptr ECLine = tb->txtCode.Content.Lines.Item(iSelEndLine)
	Dim As WStringList Ptr keywordlist
	For k As Integer = 0 To KeywordLists.Count - 1
		keywordlist = KeywordLists.Object(k)
		If ECLine <> 0 AndAlso (ECLine->InAsm OrElse StartsWith(LCase(Left(*ECLine->Text, iSelStartChar)), "asm ")) Then
			If keywordlist <> pkeywordsAsm Then
				Continue For
			End If
		ElseIf keywordlist = pkeywordsAsm Then
			Continue For
		End If
		For i As Integer = 0 To keywordlist->Count - 1
			If Not AddSorted(tb, GetKeyWordCase(keywordlist->Item(i)), , Starts) Then Exit Sub
		Next
	Next
	For i As Integer = 0 To Snippets.Count - 1
		If Not AddSorted(tb, Snippets.Item(i), Snippets.Object(i), Starts, c) Then Exit Sub
	Next
	'	For i As Integer = 0 To pKeyWords0->Count - 1
	'		If Not AddSorted(tb, GetKeyWordCase(pKeyWords0->Item(i)), , Starts) Then Exit Sub
	'	Next
	'	For i As Integer = 0 To pKeyWords1->Count - 1
	'		If Not AddSorted(tb, GetKeyWordCase(pKeyWords1->Item(i)), , Starts) Then Exit Sub
	'	Next
	'	For i As Integer = 0 To pKeyWords2->Count - 1
	'		If Not AddSorted(tb, GetKeyWordCase(pKeyWords2->Item(i)), , Starts) Then Exit Sub
	'	Next
	'	For i As Integer = 0 To pKeyWords3->Count - 1
	'		If Not AddSorted(tb, GetKeyWordCase(pKeyWords3->Item(i)), , Starts) Then Exit Sub
	'	Next
	For i As Integer = 0 To tb->txtCode.Content.Types.Count - 1
		If tb->txtCode.Content.Types.Object(i) <> 0 AndAlso Cast(TypeElement Ptr, tb->txtCode.Content.Types.Object(i))->StartLine > iSelStartLine Then Continue For
		If Not AddSorted(tb, tb->txtCode.Content.Types.Item(i), tb->txtCode.Content.Types.Object(i), Starts) Then Exit Sub
	Next
	For i As Integer = 0 To tb->txtCode.Content.Enums.Count - 1
		If tb->txtCode.Content.Enums.Object(i) <> 0 AndAlso Cast(TypeElement Ptr, tb->txtCode.Content.Enums.Object(i))->StartLine > iSelStartLine Then Continue For
		If Not AddSorted(tb, tb->txtCode.Content.Enums.Item(i), tb->txtCode.Content.Enums.Object(i), Starts, , "Enum") Then Exit Sub
	Next
	For i As Integer = 0 To tb->txtCode.Content.Procedures.Count - 1
		If tb->txtCode.Content.Procedures.Object(i) <> 0 AndAlso Cast(TypeElement Ptr, tb->txtCode.Content.Procedures.Object(i))->StartLine > iSelStartLine Then Continue For
		If Not AddSorted(tb, tb->txtCode.Content.Procedures.Item(i), tb->txtCode.Content.Procedures.Object(i), Starts, , "Sub") Then Exit Sub
	Next
	For i As Integer = 0 To tb->txtCode.Content.Args.Count - 1
		If tb->txtCode.Content.Args.Object(i) <> 0 AndAlso Cast(TypeElement Ptr, tb->txtCode.Content.Args.Object(i))->StartLine > iSelStartLine Then Continue For
		If Not AddSorted(tb, tb->txtCode.Content.Args.Item(i), tb->txtCode.Content.Args.Object(i), Starts) Then Exit Sub
	Next
	Dim As Integer Pos1
	Dim As String TypeName
	Dim As TypeElement Ptr te, te1
	If tb->cboFunction.ItemIndex > -1 Then te1 = tb->cboFunction.Items.Item(tb->cboFunction.ItemIndex)->Object
	If te1 Then
		If Len(te1->OwnerTypeName) > 0 Then TypeName = te1->OwnerTypeName
		'Pos1 = InStr(te1->DisplayName, "["): If Pos1 > 0 Then TypeName = Trim(..Left(te1->DisplayName, Pos1 - 1))
		'Pos1 = InStr(te1->FullName, "."): If Pos1 > 0 Then TypeName = Trim(..Left(te1->FullName, Pos1 - 1))
	End If
	If TypeName <> "" Then FillIntellisenseByName "", TypeName, Starts, , True, True
	If te1 <> 0 Then
		For i As Integer = 0 To te1->Elements.Count - 1
			te = te1->Elements.Object(i)
			If te <> 0 Then
				If Not AddSorted(tb, te->Name, te, Starts, c) Then Exit Sub
			End If
		Next
	End If
	If ECLine Then
		If ECLine->InConstructionBlock Then
			FListItems.Clear
			FillFromConstructionBlock ECLine->InConstructionBlock, ""
			For i As Integer = 0 To FListItems.Count - 1
				te = FListItems.Object(i)
				If te <> 0 Then
					If Not AddSorted(tb, te->Name, te, Starts, c) Then Exit Sub
				End If
			Next
		End If
	End If
	'If tb->bLineChanged Then
	'	UpdateIncludedFilesList tb, iSelStartLine
	'	tb->bLineChanged = False
	'End If
	Dim As WStringList Ptr pFiles '= @tb->txtCode.FileList
	Dim As IntegerList Ptr pFileLines '= @tb->txtCode.FileListLines
	If ECLine Then
		pFiles = ECLine->FileList
		pFileLines = ECLine->FileListLines
	End If
	For i As Integer = 0 To pGlobalNamespaces->Count - 1
		If Not AddSorted(tb, pGlobalNamespaces->Item(i), pGlobalNamespaces->Object(i), Starts, c, "Sub", False, pFiles, pFileLines) Then Exit Sub
	Next
	'If Len(Starts) < 3 Then Exit Sub
	For i As Integer = 0 To pComps->Count - 1
		If Not AddSorted(tb, pComps->Item(i), pComps->Object(i), Starts, c, , False, pFiles, pFileLines) Then Exit Sub
	Next
	For i As Integer = 0 To pGlobalTypes->Count - 1
		If Not AddSorted(tb, pGlobalTypes->Item(i), pGlobalTypes->Object(i), Starts, c, , False, pFiles, pFileLines) Then Exit Sub
	Next
	For i As Integer = 0 To pGlobalEnums->Count - 1
		If Not AddSorted(tb, pGlobalEnums->Item(i), pGlobalEnums->Object(i), Starts, c, , False, pFiles, pFileLines) Then Exit Sub
	Next
	For i As Integer = 0 To pGlobalFunctions->Count - 1
		If Not AddSorted(tb, pGlobalFunctions->Item(i), pGlobalFunctions->Object(i), Starts, c, "Sub", False, pFiles, pFileLines) Then Exit Sub
	Next
	For i As Integer = 0 To pGlobalArgs->Count - 1
		If Not AddSorted(tb, pGlobalArgs->Item(i), pGlobalArgs->Object(i), Starts, c, , False, pFiles, pFileLines) Then Exit Sub
	Next
End Sub

Sub FillTypeIntellisenses(ByRef Starts As WString = "")
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	#ifdef __USE_GTK__
		tb->txtCode.lvIntellisense.ListItems.Clear
	#else
		tb->txtCode.cboIntellisense.Items.Clear
	#endif
	Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	Dim As EditControlLine Ptr ECLine = tb->txtCode.Content.Lines.Item(iSelEndLine)
	Dim c As Integer
	If pkeywords1 <> 0 Then
		For i As Integer = 0 To pkeywords1->Count - 1
			AddSorted tb, GetKeyWordCase(pkeywords1->Item(i)), , Starts
		Next
	End If
	AddSorted tb, GetKeyWordCase("Const"), , Starts
	AddSorted tb, GetKeyWordCase("TypeOf"), , Starts
	AddSorted tb, GetKeyWordCase("Sub"), , Starts
	AddSorted tb, GetKeyWordCase("Function"), , Starts
	For i As Integer = 0 To tb->txtCode.Content.Types.Count - 1
		If tb->txtCode.Content.Types.Object(i) <> 0 AndAlso Cast(TypeElement Ptr, tb->txtCode.Content.Types.Object(i))->StartLine > iSelStartLine Then Continue For
		If Not AddSorted(tb, tb->txtCode.Content.Types.Item(i), tb->txtCode.Content.Types.Object(i), Starts) Then Exit Sub
	Next
	For i As Integer = 0 To tb->txtCode.Content.Enums.Count - 1
		If tb->txtCode.Content.Enums.Object(i) <> 0 AndAlso Cast(TypeElement Ptr, tb->txtCode.Content.Enums.Object(i))->StartLine > iSelStartLine Then Continue For
		If Not AddSorted(tb, tb->txtCode.Content.Enums.Item(i), tb->txtCode.Content.Enums.Object(i), Starts, , "Type") Then Exit Sub
	Next
	'If Len(Starts) < 3 Then Exit Sub
	'If tb->bLineChanged Then
	'	UpdateIncludedFilesList tb, iSelStartLine
	'	tb->bLineChanged = False
	'End If
	Dim As WStringList Ptr pFiles '= @tb->txtCode.FileList
	Dim As IntegerList Ptr pFileLines '= @tb->txtCode.FileListLines
	If ECLine Then
		pFiles = ECLine->FileList
		pFileLines = ECLine->FileListLines
		If ECLine->InConstructionBlock Then
			For i As Integer = 0 To ECLine->InConstructionBlock->Types.Count - 1
				If ECLine->InConstructionBlock->Types.Object(i) <> 0 AndAlso Cast(TypeElement Ptr, ECLine->InConstructionBlock->Types.Object(i))->StartLine > iSelStartLine Then Continue For
				If Not AddSorted(tb, ECLine->InConstructionBlock->Types.Item(i), ECLine->InConstructionBlock->Types.Object(i), Starts) Then Exit Sub
			Next
			For i As Integer = 0 To ECLine->InConstructionBlock->Enums.Count - 1
				If ECLine->InConstructionBlock->Enums.Object(i) <> 0 AndAlso Cast(TypeElement Ptr, ECLine->InConstructionBlock->Enums.Object(i))->StartLine > iSelStartLine Then Continue For
				If Not AddSorted(tb, ECLine->InConstructionBlock->Enums.Item(i), ECLine->InConstructionBlock->Enums.Object(i), Starts, , "Type") Then Exit Sub
			Next
			If ECLine->InConstructionBlock->Construction Then
				For i As Integer = 0 To ECLine->InConstructionBlock->Construction->Types.Count - 1
					If ECLine->InConstructionBlock->Construction->Types.Object(i) <> 0 AndAlso Cast(TypeElement Ptr, ECLine->InConstructionBlock->Construction->Types.Object(i))->StartLine > iSelStartLine Then Continue For
					If Not AddSorted(tb, ECLine->InConstructionBlock->Construction->Types.Item(i), ECLine->InConstructionBlock->Construction->Types.Object(i), Starts) Then Exit Sub
				Next
				For i As Integer = 0 To ECLine->InConstructionBlock->Construction->Enums.Count - 1
					If ECLine->InConstructionBlock->Construction->Enums.Object(i) <> 0 AndAlso Cast(TypeElement Ptr, ECLine->InConstructionBlock->Construction->Enums.Object(i))->StartLine > iSelStartLine Then Continue For
					If Not AddSorted(tb, ECLine->InConstructionBlock->Construction->Enums.Item(i), ECLine->InConstructionBlock->Construction->Enums.Object(i), Starts, , "Type") Then Exit Sub
				Next
			End If
		End If
	End If
	For i As Integer = 0 To pComps->Count - 1
		If Not AddSorted(tb, pComps->Item(i), pComps->Object(i), Starts, c, , False, pFiles, pFileLines) Then Exit Sub
	Next
	For i As Integer = 0 To pGlobalTypes->Count - 1
		If Not AddSorted(tb, pGlobalTypes->Item(i), pGlobalTypes->Object(i), Starts, c, , False, pFiles, pFileLines) Then Exit Sub
	Next
	For i As Integer = 0 To pGlobalEnums->Count - 1
		If Not AddSorted(tb, pGlobalEnums->Item(i), pGlobalEnums->Object(i), Starts, c, , False, pFiles, pFileLines) Then Exit Sub
	Next
	For i As Integer = 0 To pGlobalNamespaces->Count - 1
		If Not AddSorted(tb, pGlobalNamespaces->Item(i), pGlobalNamespaces->Object(i), Starts, c, , False, pFiles, pFileLines) Then Exit Sub
	Next
End Sub

Function AddFileSorted(tb As TabWindow Ptr, ByRef Text As WString, ByRef Starts As WString = "", ByRef c As Integer = 0, ByRef imgKey As WString = "") As Boolean
	On Error Goto ErrorHandler
	If Starts <> "" AndAlso Not StartsWith(LCase(Text), LCase(Starts)) Then Return True
	c += 1
	If c > IntellisenseLimit Then Return False
	Dim As String imgKeyNew = imgKey
	If imgKeyNew = "" Then imgKeyNew = GetIconName(Text)
	#ifdef __USE_GTK__
		Dim iIndex As Integer = -1
		With tb->txtCode.lvIntellisense.ListItems
			For i As Integer = 0 To .Count - 1
				If LCase(.Item(i)->Text(0)) = LCase(Text) Then
					Return True
				ElseIf LCase(.Item(i)->Text(0)) > LCase(Text) Then
					iIndex = i: Exit For
				End If
			Next i
			Var item = .Add(Text, imgKeyNew, , , iIndex)
		End With
	#else
		Dim iIndex As Integer = -1
		With tb->txtCode.cboIntellisense.Items
			For i As Integer = 0 To .Count - 1
				If LCase(.Item(i)->Text) = LCase(Text) Then
					Return True
				ElseIf LCase(.Item(i)->Text) > LCase(Text) Then
					iIndex = i: Exit For
				End If
			Next i
			.Add Text, 0, imgKeyNew, imgKeyNew, , , iIndex
		End With
	#endif
	Return True
	Exit Function
	ErrorHandler:
	MsgBox Text & " " & ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " (Handler line: " & __LINE__ & ") " & _
	"in function " & ZGet(Erfn()) & " (Handler function: " & __FUNCTION__ & ") " & _
	"in module " & ZGet(Ermn()) & " (Handler file: " & __FILE__ & ") "
End Function

Function AddPaths(tb As TabWindow Ptr, ByRef Path As WString, ByRef Starts As WString = "", ByRef c As Integer = 0) As Boolean
	Dim As WString * 1024 f
	Dim As UInteger Attr
	f = Dir(Path & Slash & "*", fbReadOnly Or fbHidden Or fbSystem Or fbDirectory Or fbArchive, Attr)
	While f <> ""
		If (Attr And fbDirectory) <> 0 Then
			If Not AddFileSorted(tb, f, Starts, c, "Folder") Then Return False
		ElseIf EndsWith(LCase(f), ".bas") OrElse EndsWith(LCase(f), ".bi") OrElse EndsWith(LCase(f), ".inc") OrElse EndsWith(LCase(f), ".frm") Then
			If Not AddFileSorted(tb, f, Starts, c) Then Return False
		End If
		f = Dir(Attr)
	Wend
	Return True
End Function

Sub FillFileIntellisenses(ByRef Path As WString = "", ByRef Starts As WString = "")
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	#ifdef __USE_GTK__
		tb->txtCode.lvIntellisense.ListItems.Clear
	#else
		tb->txtCode.cboIntellisense.Items.Clear
	#endif
	Dim c As Integer
	If Path <> "" Then
		If Not AddPaths(tb, Path, Starts, c) Then Exit Sub
	Else
		Dim As WString * 1024 f
		Dim As UInteger Attr
		If Not tb->IsNew Then
			If Not AddPaths(tb, GetFolderName(tb->FileName), Starts, c) Then Exit Sub
		End If
		Dim As Library Ptr CtlLibrary
		For i As Integer = 0 To ControlLibraries.Count - 1
			CtlLibrary = ControlLibraries.Item(i)
			If Not CtlLibrary->Enabled Then Continue For
			If Not AddPaths(tb, GetOSPath(GetFullPath(GetFullPath(CtlLibrary->IncludeFolder, CtlLibrary->Path))), Starts, c) Then Exit Sub
		Next
		#ifndef __FB_WIN32__
			If Not AddPaths(tb, GetOSPath(GetFolderName(GetFolderName(GetFullPath(*Compiler32Path))) & "include/freebasic"), Starts, c) Then Exit Sub
			If Not AddPaths(tb, GetOSPath(GetFolderName(GetFolderName(GetFullPath(*Compiler64Path))) & "include/freebasic"), Starts, c) Then Exit Sub
		#else
			If Not AddPaths(tb, GetOSPath(GetFolderName(GetFullPath(*Compiler32Path)) & "inc"), Starts, c) Then Exit Sub
			If Not AddPaths(tb, GetOSPath(GetFolderName(GetFullPath(*Compiler64Path)) & "inc"), Starts, c) Then Exit Sub
		#endif
		For i As Integer = 0 To pIncludePaths->Count - 1
			If Not AddPaths(tb, GetOSPath(pIncludePaths->Item(i)), Starts, c) Then Exit Sub
		Next
	End If
End Sub

Function TabWindow.FillIntellisense(ByRef ClassName As WString, ByRef FromClassName As WString, pList As WStringOrStringList Ptr, bLocal As Boolean = False, bAll As Boolean = False, TypesOnly As Boolean = False, tb As TabWindow Ptr = 0) As Boolean
	If ClassName = "" Then Return False
	Var Index = pList->IndexOf(ClassName)
	If Index = -1 Then Return False
	tbi = pList->Object(Index)
	If tbi Then
		Var i = 0
		Do While i <= tbi->Elements.Count - 1
			te = tbi->Elements.Object(i)
			If te Then
				With *te
					If (bLocal OrElse CBool(.Locals = 0) OrElse CBool(FromClassName = ClassName) OrElse CBool(.Locals = 1 AndAlso IsBase(FromClassName, ClassName, tb))) AndAlso _
						((Not TypesOnly) OrElse (TypesOnly AndAlso CBool(.ElementType = E_Type OrElse .ElementType = E_TypeCopy OrElse .ElementType = E_Enum OrElse .ElementType = E_Namespace))) Then
						If bAll OrElse Not FListItems.Contains(.Name) Then
							FListItems.Add tbi->Elements.Item(i), te
						End If
					End If
				End With
			End If
			i += 1
		Loop
		If FillIntellisense(tbi->TypeName, FromClassName, pList, bLocal, bAll, TypesOnly, tb) Then
		ElseIf FillIntellisense(tbi->TypeName, FromClassName, @txtCode.Content.Types, bLocal, bAll, TypesOnly, tb) Then
		ElseIf FillIntellisense(tbi->TypeName, FromClassName, @txtCode.Content.Enums, bLocal, bAll, TypesOnly, tb) Then
		ElseIf FillIntellisense(tbi->TypeName, FromClassName, @txtCode.Content.Namespaces, bLocal, bAll, TypesOnly, tb) Then
		ElseIf FillIntellisense(tbi->TypeName, FromClassName, pComps, bLocal, bAll, TypesOnly, tb) Then
		ElseIf FillIntellisense(tbi->TypeName, FromClassName, pGlobalTypes, bLocal, bAll, TypesOnly, tb) Then
		ElseIf FillIntellisense(tbi->TypeName, FromClassName, pGlobalEnums, bLocal, bAll, TypesOnly, tb) Then
		ElseIf FillIntellisense(tbi->TypeName, FromClassName, pGlobalNamespaces, bLocal, bAll, TypesOnly, tb) Then
		End If
	End If
	Return True
End Function

Function Ekvivalent(ByRef a As WString, ByRef b As WString) As Integer
	Dim i As Integer
	For i = 1 To Len(b)
		If LCase(Mid(a, i, 1)) <> LCase(Mid(b, i, 1)) Then Return i - 1
	Next
	Return i - 1
End Function

Sub FindComboIndex(tb As TabWindow Ptr, ByRef sLine As WString, iEndChar As Integer)
	Dim As WString Ptr sTempRight
	For i As Integer = iEndChar + 1 To Len(sLine)
		If CInt(IsArg(Asc(Mid(sLine, i, 1)))) OrElse CInt(Mid(sLine, i, 1) = "#") Then WLetEx(sTempRight, *sTempRight & Mid(sLine, i, 1), True) Else Exit For
	Next
	#ifdef __USE_GTK__
		With tb->txtCode.lvIntellisense
	#else
		With tb->txtCode.cboIntellisense
	#endif
		Dim As Integer Ekv, EkvOld, iPos = -1, i
		#ifdef __USE_GTK__
			For i = 0 To .ListItems.Count - 1
				Ekv = Ekvivalent(.ListItems.Item(i)->Text(0), *sTempRight)
		#else
			For i = 0 To .Items.Count - 1
				Ekv = Ekvivalent(.Items.Item(i)->Text, *sTempRight)
		#endif
			If Ekv < EkvOld Then
				Exit For
			ElseIf Ekv > EkvOld Then
				iPos = i
			End If
			EkvOld = Ekv
		Next
		#ifdef __USE_GTK__
			.SelectedItemIndex = iPos
		#else
			.ItemIndex = iPos
		#endif
		tb->txtCode.LastItemIndex = iPos
		tb->txtCode.FocusedItemIndex = iPos
		If iPos > 0 Then
			#ifdef __USE_GTK__
				If CInt(*sTempRight = "") OrElse CInt(Not StartsWith(LCase(.ListItems.Item(i - 1)->Text(0)), LCase(*sTempRight))) Then
			#else
				If CInt(*sTempRight = "") OrElse CInt(Not StartsWith(LCase(.Items.Item(i - 1)->Text), LCase(*sTempRight))) Then
			#endif
				tb->txtCode.LastItemIndex = -1
			End If
		End If
	End With
	WDeAllocate(sTempRight)
End Sub

Sub FillIntellisenseByName(Value As String, TypeName As String, Starts As String = "", bLocal As Boolean = False, bAll As Boolean = False, NotClear As Boolean = False, TypesOnly As Boolean = False, Oldte As TypeElement Ptr = 0)
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	Dim As EditControlLine Ptr ECLine = tb->txtCode.Content.Lines.Item(iSelStartLine)
	Dim As WStringList Ptr pFiles
	Dim As IntegerList Ptr pFileLines
	Dim As String FromClassName
	If ECLine Then
		pFiles = ECLine->FileList
		pFileLines = ECLine->FileListLines
		If ECLine->InConstruction > 0 Then
			Dim As TypeElement Ptr te = ECLine->InConstruction
			FromClassName = te->OwnerTypeName
			'Var Pos1 = InStr(FromClassName, ".")
			'If (CBool(Pos1 > 0) OrElse EndsWith(te->DisplayName, "[Constructor]") OrElse EndsWith(te->DisplayName, "[Destructor]")) Then
			'	If Pos1 > 0 Then
			'		FromClassName = ..Left(FromClassName, Pos1 - 1)
			'	Else
			'		FromClassName = te->Name
			'	End If
			'Else
			'	FromClassName = ""
			'End If
		End If
	End If
	Dim As String sTemp2 = TypeName
	If tb->Des Then
		Dim As SymbolsType Ptr stDesignControl = tb->Des->Symbols(tb->Des->DesignControl)
		If stDesignControl AndAlso stDesignControl->ReadPropertyFunc Then
			If CInt(LCase(Value) = "this") AndAlso CInt(tb->Des->DesignControl) Then
				Dim As TypeElement Ptr te1
				If tb->cboFunction.ItemIndex > -1 Then te1 = tb->cboFunction.ItemData(tb->cboFunction.ItemIndex)
				Dim As String frmName = WGet(stDesignControl->ReadPropertyFunc(tb->Des->DesignControl, "Name"))
				If te1 Then
					If te1->OwnerTypeName = frmName Then
						sTemp2 = frmName
					ElseIf te1->OwnerTypeName = frmName & "Type" Then
						sTemp2 = frmName & "Type"
					End If
				End If
			End If
		End If
	End If
	FListItems.Clear
	If Not NotClear Then
		#ifdef __USE_GTK__
			tb->txtCode.lvIntellisense.ListItems.Clear
			tb->txtCode.lvIntellisense.Sort = ssSortAscending
		#else
			tb->txtCode.cboIntellisense.Items.Clear
			'tb->txtCode.cboIntellisense.Sort = True
		#endif
	End If
	Dim As TypeElement Ptr te, te1
	Dim As Integer Pos1
	'Dim As String TypeName, FuncName = tb->cboFunction.Text
	'	If tb->cboFunction.ItemIndex > -1 Then te1 = tb->cboFunction.Items.Item(tb->cboFunction.ItemIndex)->Object
	'	Pos1 = InStr(tb->cboFunction.Text, "["): If Pos1 > 0 Then FuncName = Trim(..Left(tb->cboFunction.Text, Pos1 - 1)): TypeName = FuncName
	'	Pos1 = InStr(FuncName, "."): If Pos1 > 0 Then TypeName = Trim(..Left(FuncName, Pos1 - 1))
	'	If te1 <> 0 AndAlso te1->Elements.Contains(sTemp2) Then
	'		te = te1->Elements.Object(te1->Elements.IndexOf(sTemp2))
	'	ElseIf tb->Procedures.Contains(sTemp2) Then
	'		te = tb->Procedures.Object(tb->Procedures.IndexOf(sTemp2))
	'	ElseIf tb->Args.Contains(sTemp2) Then
	'		te = tb->Args.Object(tb->Args.IndexOf(sTemp2))
	'	ElseIf pGlobalFunctions->Contains(sTemp2) Then
	'		te = pGlobalFunctions->Object(pGlobalFunctions->IndexOf(sTemp2))
	'	ElseIf pGlobalArgs->Contains(sTemp2) Then
	'		te = pGlobalArgs->Object(pGlobalArgs->IndexOf(sTemp2))
	'	ElseIf TypeName <> "" Then
	'		If tb->Types.Contains(TypeName) Then
	'			tb->FillIntellisense TypeName, @tb->Types, True
	'		ElseIf tb->Enums.Contains(TypeName) Then
	'			tb->FillIntellisense TypeName, @tb->Enums, True
	'		ElseIf pComps->Contains(TypeName) Then
	'			tb->FillIntellisense TypeName, pComps, True
	'		ElseIf pGlobalTypes->Contains(TypeName) Then
	'			tb->FillIntellisense TypeName, pGlobalTypes, True
	'		ElseIf pGlobalEnums->Contains(TypeName) Then
	'			tb->FillIntellisense TypeName, pGlobalEnums, True
	'		End If
	'		If FListItems.Contains(sTemp2) Then
	'			te = FListItems.Object(FListItems.IndexOf(sTemp2))
	'		End If
	'		FListItems.Clear
	'	End If
	'	If te <> 0 Then sTemp2 = te->TypeName
	If TypeName <> "" AndAlso LCase(Value) = "base" Then
		FListItems.Add "Base"
	End If
	
	Var Idx = -1
	'If TypesOnly Then
	'	If tb->txtCode.Content.Namespaces.Contains(sTemp2, , , , Idx) AndAlso Cast(TypeElement Ptr, tb->txtCode.Content.Namespaces.Object(Idx))->StartLine <= iSelStartLine Then
	'		tb->FillIntellisense sTemp2, FromClassName, @tb->txtCode.Content.Namespaces, bLocal, bAll, TypesOnly, tb
	'	ElseIf tb->txtCode.Content.ContainsInListFiles(pGlobalNamespaces, sTemp2, Idx, pFiles, pFileLines) Then
	'		tb->FillIntellisense sTemp2, FromClassName, pGlobalNamespaces, bLocal, bAll, TypesOnly, tb
	'	End If
	'Else
	If CBool(ECLine <> 0) AndAlso CBool(ECLine->InConstructionBlock <> 0) AndAlso ECLine->InConstructionBlock->Types.Contains(sTemp2, , , , Idx) AndAlso CBool(Cast(TypeElement Ptr, ECLine->InConstructionBlock->Types.Object(Idx))->StartLine <= iSelStartLine) Then
		tb->FillIntellisense sTemp2, FromClassName, @ECLine->InConstructionBlock->Types, bLocal, bAll, TypesOnly, tb
	ElseIf CBool(ECLine <> 0) AndAlso CBool(ECLine->InConstructionBlock <> 0) AndAlso ECLine->InConstructionBlock->Enums.Contains(sTemp2, , , , Idx) AndAlso CBool(Cast(TypeElement Ptr, ECLine->InConstructionBlock->Enums.Object(Idx))->StartLine <= iSelStartLine) Then
		tb->FillIntellisense sTemp2, FromClassName, @ECLine->InConstructionBlock->Enums, bLocal, bAll, TypesOnly, tb
	ElseIf CBool(ECLine <> 0) AndAlso CBool(ECLine->InConstructionBlock <> 0) AndAlso CBool(ECLine->InConstructionBlock->Construction <> 0) AndAlso ECLine->InConstructionBlock->Construction->Types.Contains(sTemp2, , , , Idx) AndAlso CBool(Cast(TypeElement Ptr, ECLine->InConstructionBlock->Construction->Types.Object(Idx))->StartLine <= iSelStartLine) Then
		tb->FillIntellisense sTemp2, FromClassName, @ECLine->InConstructionBlock->Construction->Types, bLocal, bAll, TypesOnly, tb
	ElseIf CBool(ECLine <> 0) AndAlso CBool(ECLine->InConstructionBlock <> 0) AndAlso CBool(ECLine->InConstructionBlock->Construction <> 0) AndAlso ECLine->InConstructionBlock->Construction->Enums.Contains(sTemp2, , , , Idx) AndAlso CBool(Cast(TypeElement Ptr, ECLine->InConstructionBlock->Construction->Enums.Object(Idx))->StartLine <= iSelStartLine) Then
		tb->FillIntellisense sTemp2, FromClassName, @ECLine->InConstructionBlock->Construction->Enums, bLocal, bAll, TypesOnly, tb
	ElseIf CBool(Oldte <> 0) AndAlso Oldte->Elements.Contains(sTemp2, , , , Idx) Then
		tb->FillIntellisense sTemp2, FromClassName, @Oldte->Elements, bLocal, bAll, TypesOnly, tb
	ElseIf tb->txtCode.Content.Types.Contains(sTemp2, , , , Idx) AndAlso CBool(Cast(TypeElement Ptr, tb->txtCode.Content.Types.Object(Idx))->StartLine <= iSelStartLine) Then
		tb->FillIntellisense sTemp2, FromClassName, @tb->txtCode.Content.Types, bLocal, bAll, TypesOnly, tb
	ElseIf tb->txtCode.Content.Enums.Contains(sTemp2, , , , Idx) AndAlso Cast(TypeElement Ptr, tb->txtCode.Content.Enums.Object(Idx))->StartLine <= iSelStartLine Then
		tb->FillIntellisense sTemp2, FromClassName, @tb->txtCode.Content.Enums, bLocal, bAll, TypesOnly, tb
	ElseIf tb->txtCode.Content.Namespaces.Contains(sTemp2, , , , Idx) AndAlso Cast(TypeElement Ptr, tb->txtCode.Content.Namespaces.Object(Idx))->StartLine <= iSelStartLine Then
		tb->FillIntellisense sTemp2, FromClassName, @tb->txtCode.Content.Namespaces, bLocal, bAll, TypesOnly, tb
		tb->FillIntellisense sTemp2, FromClassName, pGlobalNamespaces, bLocal, bAll, TypesOnly, tb
	ElseIf tb->txtCode.Content.ContainsInListFiles(pComps, sTemp2, Idx, pFiles, pFileLines) Then
		tb->FillIntellisense sTemp2, FromClassName, pComps, bLocal, bAll, TypesOnly, tb
	ElseIf tb->txtCode.Content.ContainsInListFiles(pGlobalTypes, sTemp2, Idx, pFiles, pFileLines) Then
		tb->FillIntellisense sTemp2, FromClassName, pGlobalTypes, bLocal, bAll, TypesOnly, tb
	ElseIf tb->txtCode.Content.ContainsInListFiles(pGlobalEnums, sTemp2, Idx, pFiles, pFileLines) Then
		tb->FillIntellisense sTemp2, FromClassName, pGlobalEnums, bLocal, bAll, TypesOnly, tb
	ElseIf tb->txtCode.Content.ContainsInListFiles(pGlobalNamespaces, sTemp2, Idx, pFiles, pFileLines) Then
		tb->FillIntellisense sTemp2, FromClassName, pGlobalNamespaces, bLocal, bAll, TypesOnly, tb
	Else
		Exit Sub
	End If
	FListItems.Sort
	For i As Integer = 0 To FListItems.Count - 1
		Dim As String imgKey = "Sub"
		te = FListItems.Object(i)
		If te = 0 Then
			imgKey = "StandartTypes"
		ElseIf te->ElementType = E_Property Then
			imgKey = "Property"
		ElseIf te->ElementType = E_Function Then
			imgKey = "Function"
		ElseIf te->ElementType = E_Event Then
			imgKey = "Event"
		ElseIf te->ElementType = E_Enum Then
			imgKey = "Enum"
		ElseIf te->ElementType = E_Type OrElse te->ElementType = E_TypeCopy OrElse te->ElementType = E_Union Then
			imgKey = "Type"
		End If
		If NotClear Then
			If Not AddSorted(tb, FListItems.Item(i), te, Starts) Then Exit Sub
		Else
			#ifdef __USE_GTK__
				Var lvItem = tb->txtCode.lvIntellisense.ListItems.Add(FListItems.Item(i), imgKey)
				lvItem->Tag = te
			#else
				tb->txtCode.cboIntellisense.Items.Add FListItems.Item(i), te, imgKey, imgKey
			#endif
		End If
	Next i
End Sub

Declare Function GetParameters(sWord As String, te As TypeElement Ptr, teOld As TypeElement Ptr) As UString

Sub SetParametersFromDropDown()
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	Dim As Integer Index
	#ifdef __USE_GTK__
		Index = tb->txtCode.lvIntellisense.SelectedItemIndex
		If Index = -1 Then Exit Sub
		With *tb->txtCode.lvIntellisense.ListItems.Item(Index)
			If tb->txtCode.FileDropDown Then
				tb->txtCode.HintDropDown = .Text(0)
			Else
				tb->txtCode.HintDropDown = GetParameters(.Text(0), .Tag, tb->txtCode.DropDownTypeElement)
				If tb->txtCode.HintDropDown = "" Then tb->txtCode.HintDropDown = .Text(0)
			End If
		End With
	#else
		Index = tb->txtCode.cboIntellisense.ItemIndex
		If Index = -1 Then Exit Sub
		With tb->txtCode.cboIntellisense
			If tb->txtCode.FileDropDown Then
				tb->txtCode.HintDropDown = .Text
			Else
				Dim As String sWord = .Item(Index)
				Dim As TypeElement Ptr te = .ItemData(Index)
				tb->txtCode.HintDropDown = GetParameters(sWord, te, tb->txtCode.DropDownTypeElement)
				If tb->txtCode.HintDropDown = "" Then tb->txtCode.HintDropDown = .Text
			End If
		End With
	#endif
	tb->txtCode.UpdateDropDownToolTip
End Sub

#ifdef __USE_GTK__
	Sub Intellisense_SelectedItemChanged(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
#else
	Sub Intellisense_SelectedItemChanged(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit)
#endif
	SetParametersFromDropDown
End Sub

Sub CompleteWord
	Static OldWord As String
	If FormClosing Then Exit Sub
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar, k
	tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	SelLinePos = iSelEndLine
	Dim sLine As WString Ptr = @tb->txtCode.Lines(iSelEndLine)
	Dim As Integer posL, posR = 0: k = 0
	Do
		posR = InStr(posR + 1, *sLine, """")
		If posR >= iSelEndChar OrElse posR < 1 Then Exit Do
		k += 1
	Loop
	If k Mod 2 = 1 Then Exit Sub
	k = InStrRev(*sLine, "'", iSelEndChar)
	If k > 0 Then
		posL = InStrRev(*sLine, """", k) : posR = InStr(k, *sLine, """")
		If Not (posL  > 0 AndAlso (posL < k AndAlso posR > k)) Then Exit Sub
	End If
	Dim As String s, sTemp, sTemp2, TypeName, OldTypeName
	
	Dim As TypeElement Ptr te, te1, teOld, teTypeOld
	Dim As Boolean b, c, d, f
	SelCharPos = 0
	For i As Integer = iSelEndChar To 1 Step -1
		s = Mid(*sLine, i, 1)
		If CInt(IsArg(Asc(s))) OrElse CInt(s = "#") Then
			If b Or f Then
				sTemp2 = s & sTemp2
			Else
				sTemp = s & sTemp
			End If
			If f Then d = True
		ElseIf CInt(s = " " OrElse s = !"\t") AndAlso CInt(Not d) AndAlso CInt(Not b) AndAlso CInt(Not c) Then
			If Not f Then SelCharPos = i
			f = True
			Exit For
		ElseIf s = "." Then
			b = True
			TypeName = tb->txtCode.Content.GetLeftArgTypeName(iSelEndLine, i - 1, te, teOld, teTypeOld, OldTypeName)
			SelCharPos = i
			Exit For
		ElseIf s = ">" Then
			c = True
			SelCharPos = i
		ElseIf CInt(c) AndAlso CInt(s = "-") Then
			TypeName = tb->txtCode.Content.GetLeftArgTypeName(iSelEndLine, i - 1, te, teOld, teTypeOld, OldTypeName)
			b = True
			Exit For
		ElseIf s = Chr(34) Then
			Exit Sub
		Else
			If SelCharPos = 0 Then SelCharPos = i
			Exit For
		End If
	Next
	If OldWord <> "" AndAlso StartsWith(sTemp, OldWord) Then Exit Sub
	'If teOld <> 0 OrElse OldTypeName <> "" Then
	'		If OldTypeName <> "" Then
	'			TypeName = OldTypeName
	'		Else
	'			TypeName = teOld->TypeName
	'		End If
	If TypeName = "" AndAlso teOld <> 0 AndAlso teOld->Value <> "" Then
		TypeName = tb->txtCode.Content.GetTypeFromValue(teOld->Value, SelLinePos)
	End If
	If TypeName <> "" Then
		FillIntellisenseByName sTemp, TypeName
	Else
		If LCase(sTemp2) = "as" Then
			FillTypeIntellisenses sTemp
		Else
			FillAllIntellisenses sTemp
		End If
	End If
	#ifdef __USE_GTK__
		If tb->txtCode.lvIntellisense.ListItems.Count = 0 Then OldWord = sTemp: Exit Sub
		With tb->txtCode.lvIntellisense
	#else
		If tb->txtCode.cboIntellisense.Items.Count = 0 Then OldWord = sTemp: Exit Sub
		With tb->txtCode.cboIntellisense
	#endif
		FindComboIndex(tb, *sLine, SelCharPos)
		#ifdef __USE_GTK__
			If CInt(tb->txtCode.LastItemIndex <> -1 AndAlso tb->txtCode.LastItemIndex < .ListItems.Count) AndAlso _
				CInt(Not StartsWith(LCase(.ListItems.Item(tb->txtCode.LastItemIndex)->Text(0)), LCase(sTemp))) Then
		#else
			If CInt(tb->txtCode.LastItemIndex <> -1 AndAlso tb->txtCode.LastItemIndex < .Items.Count) AndAlso _
				CInt(Not StartsWith(LCase(.Items.Item(tb->txtCode.LastItemIndex)->Text), LCase(sTemp))) Then
		#endif
			Dim i As Integer = GetNextCharIndex(*sLine, SelCharPos)
			#ifdef __USE_GTK__
				If tb->txtCode.lvIntellisense.SelectedItem Then
					tb->txtCode.ReplaceLine iSelEndLine, ..Left(*sLine, SelCharPos) & .SelectedItem->Text(0) & Mid(*sLine, i + 1)
					i = SelCharPos + Len(.SelectedItem->Text(0))
				End If
			#else
				tb->txtCode.ReplaceLine iSelEndLine, ..Left(*sLine, SelCharPos) & .Text & Mid(*sLine, i + 1)
				i = SelCharPos + Len(.Text)
			#endif
			tb->txtCode.SetSelection SelLinePos, SelLinePos, i, i
			Exit Sub
		End If
		tb->txtCode.DropDownTypeElement = 0
		tb->txtCode.FileDropDown = False
		SetParametersFromDropDown
		tb->txtCode.ShowDropDownAt SelLinePos, SelCharPos
	End With
End Sub

Private Function GetFuncStartChar(sLine As WString Ptr, iSelEndChar As Integer, ByRef iSelEndCharFunc As Integer, ByRef iParamCount As Integer = -1) As Integer
	Dim As Integer iCount, iSelStartCharFunc
	Dim As String Symb
	Dim As Boolean bStarted, bStartedFunc, bQuotation, bArithmetic
	Dim As UString res(Any), b
	iParamCount = 0
	Split *sLine, """", res()
	b = ""
	For j As Integer = 0 To UBound(res)
		If j = 0 Then
			b = res(0)
		ElseIf j Mod 2 = 0 Then
			b &= """" & res(j)
		Else
			b &= """" & WSpace(Len(res(j)))
		End If
	Next
	iSelEndCharFunc = iSelEndChar
	For i As Integer = iSelEndChar To 1 Step -1
		Symb = Mid(b, i, 1)
		If bStartedFunc Then
			If (Not IsArg(Asc(Symb))) AndAlso (Symb <> "?") Then
				If bArithmetic Then
					bStarted = False
					bStartedFunc = False
					bArithmetic = False
				Else
					iSelStartCharFunc = i
					Exit For
				End If
			End If
		ElseIf Symb = "(" Then
			If iCount = 0 Then
				iSelEndCharFunc = i - 1 '+ 1
				bStartedFunc = True
			Else
				iCount -= 1
				bStarted = False
			End If
		ElseIf Symb = ")" Then
			iCount += 1
			bStarted = False
			'		ElseIf Symb = """" Then
			'			bQuotation = Not bQuotation
		ElseIf Not bQuotation AndAlso iCount = 0 Then
			If (Symb = " " OrElse Symb = !"\t") AndAlso Not (LCase(Mid(b, i + 1, 3)) = "ptr" OrElse LCase(Mid(b, i + 1, 7)) = "pointer") Then
				bStarted = True
			ElseIf Symb = "," Then
				iParamCount += 1
				bStarted = False
			ElseIf InStr("+-/\&", Symb) Then
				bArithmetic = True
				bStarted = False
			ElseIf Symb = "?" Then
				iSelStartCharFunc = i - 1
				Exit For
			ElseIf (Not IsArg(Asc(Symb))) AndAlso (Symb <> "?") Then
				bStarted = False
			ElseIf i > 4 AndAlso (LCase(Mid(b, i - 5, 6)) = " byval" OrElse LCase(Mid(b, i - 5, 6)) = ",byval" OrElse LCase(Mid(b, i - 5, 6)) = " byref" OrElse LCase(Mid(b, i - 5, 6)) = ",byref") Then
				bStarted = False
			ElseIf bStarted Then
				iSelEndCharFunc = i '+ 1
				bStartedFunc = True
			End If
		End If
	Next
	Return iSelStartCharFunc
End Function

Function GetParameters(sWord As String, te As TypeElement Ptr, teOld As TypeElement Ptr) As UString
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Return ""
	Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	Dim As EditControlLine Ptr ECLine = tb->txtCode.Content.Lines.Item(iSelStartLine)
	Dim As String FromClassName
	Dim As Integer Index, iPos
	Dim As WStringList ParametersList
	Dim As String Symb, FuncName, Parameters, Parameter, InCondition
	Dim As UString Comments, Link1
	Dim As String TypeName
	If ECLine Then
		InCondition = ECLine->InCondition
		If ECLine->InConstruction > 0 Then
			Dim te As TypeElement Ptr = ECLine->InConstruction
			FromClassName = te->OwnerTypeName

			'Var Pos1 = InStr(FromClassName, ".")
			'If (CBool(Pos1 > 0) OrElse EndsWith(te->DisplayName, "[Constructor]") OrElse EndsWith(te->DisplayName, "[Destructor]")) Then
			'	If Pos1 > 0 Then
			'		FromClassName = ..Left(FromClassName, Pos1 - 1)
			'	Else
			'		FromClassName = te->Name
			'	End If
			'Else
			'	FromClassName = ""
			'End If
		End If
	End If
	If teOld <> 0 Then
		Index = teOld->Elements.IndexOf(sWord)
		If Index > -1 Then
			For i As Integer = Index To teOld->Elements.Count - 1
				te = teOld->Elements.Object(i)
				If te <> 0 AndAlso LCase(te->Name) = LCase(sWord) AndAlso CInt(Not ParametersList.Contains(te->Parameters)) Then
					Parameter = te->Parameters
					iPos = InStr(LCase(Parameter), LCase(sWord))
					FuncName = Mid(Parameter, iPos, Len(sWord))
					Link1 = te->FileName & "~" & Str(te->StartLine) & "~" & FuncName & "~" & FuncName
					ParametersList.Add te->Parameters
					Parameters &= IIf(Parameters = "", "", !"\r") & ..Left(Parameter, iPos - 1) & "<a href=""" & Link1 & """>" & FuncName & "</a>" & Mid(Parameter, iPos + Len(sWord))
					If te->Comment <> "" Then Comments &= "" & te->Comment
				End If
			Next
		End If
		If teOld->ElementType = E_Type Then
			TypeName = teOld->Name
		Else
			TypeName = teOld->TypeName
		End If
		If TypeName <> "" Then
			FListItems.Clear
			If tb->txtCode.Content.Types.Contains(TypeName) Then
				tb->FillIntellisense TypeName, FromClassName, @tb->txtCode.Content.Types, True, True
			ElseIf tb->txtCode.Content.Enums.Contains(TypeName) Then
				tb->FillIntellisense TypeName, FromClassName, @tb->txtCode.Content.Enums, True, True
			ElseIf pComps->Contains(TypeName) Then
				tb->FillIntellisense TypeName, FromClassName, pComps, True, True
			ElseIf pGlobalTypes->Contains(TypeName) Then
				tb->FillIntellisense TypeName, FromClassName, pGlobalTypes, True, True
			ElseIf pGlobalEnums->Contains(TypeName) Then
				tb->FillIntellisense TypeName, FromClassName, pGlobalEnums, True, True
			End If
			Index = FListItems.IndexOf(sWord)
			If Index > -1 Then
				For i As Integer = Index To FListItems.Count - 1
					te = FListItems.Object(i)
					If te <> 0 AndAlso LCase(te->Name) = LCase(sWord) AndAlso CInt(Not ParametersList.Contains(te->Parameters)) Then
						Parameter = te->Parameters
						iPos = InStr(LCase(Parameter), LCase(sWord))
						FuncName = Mid(Parameter, iPos, Len(sWord))
						Link1 = te->FileName & "~" & Str(te->StartLine) & "~" & FuncName & "~" & FuncName
						ParametersList.Add te->Parameters
						Parameters &= IIf(Parameters = "", "", !"\r") & ..Left(Parameter, iPos - 1) & "<a href=""" & Link1 & """>" & FuncName & "</a>" & Mid(Parameter, iPos + Len(sWord))
						If te->Comment <> "" Then Comments &= "" & te->Comment
					End If
				Next
			End If
			For i As Integer = 0 To tb->txtCode.Content.Functions.Count - 1
				te = tb->txtCode.Content.Functions.Object(i)
				If te <> 0 AndAlso LCase(Trim(te->Name)) = LCase(sWord) AndAlso CInt(Not ParametersList.Contains(te->Parameters)) Then
					'Var Pos1 = InStr(te->FullName, ".")
					If (Len(te->OwnerTypeName) > 0) AndAlso IsBase(TypeName, te->OwnerTypeName, tb) Then
						Parameter = te->Parameters
						iPos = InStr(LCase(Parameter), LCase(sWord))
						FuncName = Mid(Parameter, iPos, Len(sWord))
						Link1 = te->FileName & "~" & Str(te->StartLine) & "~" & FuncName & "~" & FuncName
						ParametersList.Add te->Parameters
						Parameters &= IIf(Parameters = "", "", !"\r") & ..Left(Parameter, iPos - 1) & "<a href=""" & Link1 & """>" & FuncName & "</a>" & Mid(Parameter, iPos + Len(sWord))
						If te->Comment <> "" Then Comments &= "" & te->Comment
					End If
				End If
			Next
			For i As Integer = pGlobalTypeProcedures->Count - 1 To 0 Step -1
				te = pGlobalTypeProcedures->Object(i)
				If te <> 0 AndAlso LCase(Trim(te->Name)) = LCase(sWord) AndAlso CInt(Not ParametersList.Contains(te->Parameters)) Then
					'Var Pos1 = InStr(te->FullName, ".")
					If (Len(te->OwnerTypeName) > 0) AndAlso IsBase(TypeName, te->OwnerTypeName, tb) Then
						Parameter = te->Parameters
						iPos = InStr(LCase(Parameter), LCase(sWord))
						FuncName = Mid(Parameter, iPos, Len(sWord))
						Link1 = te->FileName & "~" & Str(te->StartLine) & "~" & FuncName & "~" & FuncName
						ParametersList.Add te->Parameters
						Parameters &= IIf(Parameters = "", "", !"\r") & ..Left(Parameter, iPos - 1) & "<a href=""" & Link1 & """>" & FuncName & "</a>" & Mid(Parameter, iPos + Len(sWord))
						If te->Comment <> "" Then Comments &= "" & te->Comment
					End If
				End If
			Next
		End If
	Else
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		Dim As EditControlLine Ptr FECLine = tb->txtCode.Content.Lines.Item(iSelEndLine)
		If FECLine > 0 Then
			If FECLine->InConstructionBlock > 0 Then
				FListItems.Clear
				FillFromConstructionBlock FECLine->InConstructionBlock, sWord
				For i As Integer = 0 To FListItems.Count - 1
					te = FListItems.Object(i)
					If te <> 0 AndAlso LCase(te->Name) = LCase(sWord) AndAlso CInt(Not ParametersList.Contains(te->Parameters)) Then
						Parameter = te->Parameters
						iPos = InStr(LCase(Parameter), LCase(sWord))
						FuncName = Mid(Parameter, iPos, Len(sWord))
						Link1 = te->FileName & "~" & Str(te->StartLine) & "~" & FuncName & "~" & FuncName
						ParametersList.Add te->Parameters
						Parameters &= IIf(Parameters = "", "", !"\r") & ..Left(Parameter, iPos - 1) & "<a href=""" & Link1 & """>" & FuncName & "</a>" & Mid(Parameter, iPos + Len(sWord))
						If te->Comment <> "" Then Comments &= "" & te->Comment
					End If
				Next
			End If
			If FECLine->InConstruction > 0 Then
				Index = Cast(TypeElement Ptr, FECLine->InConstruction)->Elements.IndexOf(LCase(sWord))
				If Index <> -1 Then
					Var lst = @Cast(TypeElement Ptr, FECLine->InConstruction)->Elements
					For i As Integer = Index To lst->Count - 1
						te = lst->Object(i)
						If te <> 0 AndAlso LCase(te->Name) = LCase(sWord) AndAlso CInt(Not ParametersList.Contains(te->Parameters)) Then
							Parameter = te->Parameters
							iPos = InStr(LCase(Parameter), LCase(sWord))
							FuncName = Mid(Parameter, iPos, Len(sWord))
							Link1 = te->FileName & "~" & Str(te->StartLine) & "~" & FuncName & "~" & FuncName
							ParametersList.Add te->Parameters
							Parameters &= IIf(Parameters = "", "", !"\r") & ..Left(Parameter, iPos - 1) & "<a href=""" & Link1 & """>" & FuncName & "</a>" & Mid(Parameter, iPos + Len(sWord))
							If te->Comment <> "" Then Comments &= "" & te->Comment
						End If
					Next
				End If
				Dim As TypeElement Ptr te = FECLine->InConstruction
				TypeName = te->OwnerTypeName
				'Var Pos1 = InStr(TypeName, ".")
				'If CBool(Pos1 > 0) OrElse EndsWith(te->DisplayName, "[Constructor]") OrElse EndsWith(te->DisplayName, "[Destructor]") Then
				If Len(TypeName) > 0 Then
					'If Pos1 > 0 Then
					'	TypeName = ..Left(TypeName, Pos1 - 1)
					'Else
					'	TypeName = te->Name
					'End If
					If TypeName <> "" Then
						If tb->txtCode.Content.Types.Contains(TypeName) Then
							tb->FillIntellisense TypeName, FromClassName, @tb->txtCode.Content.Types, True
						ElseIf tb->txtCode.Content.Enums.Contains(TypeName) Then
							tb->FillIntellisense TypeName, FromClassName, @tb->txtCode.Content.Enums, True
						ElseIf pComps->Contains(TypeName) Then
							tb->FillIntellisense TypeName, FromClassName, pComps, True
						ElseIf pGlobalTypes->Contains(TypeName) Then
							tb->FillIntellisense TypeName, FromClassName, pGlobalTypes, True
						ElseIf pGlobalEnums->Contains(TypeName) Then
							tb->FillIntellisense TypeName, FromClassName, pGlobalEnums, True
						End If
						If FListItems.Contains(sWord) Then
							For i As Integer = 0 To FListItems.Count - 1
								te = FListItems.Object(i)
								If te <> 0 AndAlso LCase(te->Name) = LCase(sWord) AndAlso CInt(Not ParametersList.Contains(te->Parameters)) Then
									Parameter = te->Parameters
									iPos = InStr(LCase(Parameter), LCase(sWord))
									FuncName = Mid(Parameter, iPos, Len(sWord))
									Link1 = te->FileName & "~" & Str(te->StartLine) & "~" & FuncName & "~" & FuncName
									ParametersList.Add te->Parameters
									Parameters &= IIf(Parameters = "", "", !"\r") & ..Left(Parameter, iPos - 1) & "<a href=""" & Link1 & """>" & FuncName & "</a>" & Mid(Parameter, iPos + Len(sWord))
									If te->Comment <> "" Then Comments &= "" & te->Comment
								End If
							Next
						End If
						FListItems.Clear
						For i As Integer = 0 To tb->txtCode.Content.Functions.Count - 1
							te = tb->txtCode.Content.Functions.Object(i)
							If te <> 0 AndAlso LCase(Trim(te->Name)) = LCase(sWord) AndAlso CInt(Not ParametersList.Contains(te->Parameters)) Then
								'Var Pos1 = InStr(te->FullName, ".")
								If (Len(te->OwnerTypeName) > 0) AndAlso IsBase(TypeName, te->OwnerTypeName, tb) Then
									Parameter = te->Parameters
									iPos = InStr(LCase(Parameter), LCase(sWord))
									FuncName = Mid(Parameter, iPos, Len(sWord))
									Link1 = te->FileName & "~" & Str(te->StartLine) & "~" & FuncName & "~" & FuncName
									ParametersList.Add te->Parameters
									Parameters &= IIf(Parameters = "", "", !"\r") & ..Left(Parameter, iPos - 1) & "<a href=""" & Link1 & """>" & FuncName & "</a>" & Mid(Parameter, iPos + Len(sWord))
									If te->Comment <> "" Then Comments &= "" & te->Comment
								End If
							End If
						Next
						For i As Integer = pGlobalTypeProcedures->Count - 1 To 0 Step -1
							te = pGlobalTypeProcedures->Object(i)
							If te <> 0 AndAlso LCase(Trim(te->Name)) = LCase(sWord) AndAlso CInt(Not ParametersList.Contains(te->Parameters)) Then
								'Var Pos1 = InStr(te->FullName, ".")
								If (Len(te->OwnerTypeName) > 0) AndAlso IsBase(TypeName, te->OwnerTypeName, tb) Then
									Parameter = te->Parameters
									iPos = InStr(LCase(Parameter), LCase(sWord))
									FuncName = Mid(Parameter, iPos, Len(sWord))
									Link1 = te->FileName & "~" & Str(te->StartLine) & "~" & FuncName & "~" & FuncName
									ParametersList.Add te->Parameters
									Parameters &= IIf(Parameters = "", "", !"\r") & ..Left(Parameter, iPos - 1) & "<a href=""" & Link1 & """>" & FuncName & "</a>" & Mid(Parameter, iPos + Len(sWord))
									If te->Comment <> "" Then Comments &= "" & te->Comment
								End If
							End If
						Next
					End If
				End If
			End If
		End If
		If te <> 0 AndAlso LCase(te->Name) = LCase(sWord) AndAlso CInt(Not ParametersList.Contains(te->Parameters)) Then
			If Not ShowKeywordsToolTip Then
				If te->ElementType = E_Keyword Then Return ""
			End If
			Dim As UString res(Any)
			Split te->Parameters, !"\r", res()
			For n As Integer = 0 To UBound(res)
				Parameter = res(n) 'te->Parameters
				Parameters &= IIf(Parameters = "", "", !"\r")
				iPos = InStr(LCase(Parameter), LCase(sWord))
				'If StartsWith(Trim(LCase(Parameter)), LCase(sWord)) Then
				If iPos > 0 Then
					FuncName = Mid(Parameter, iPos, Len(sWord))
					Link1 = te->FileName & "~" & Str(te->StartLine) & "~" & FuncName & "~" & FuncName
					Parameters &= ..Left(Parameter, iPos - 1) & "<a href=""" & Link1 & """>" & FuncName & "</a>" & Mid(Parameter, iPos + Len(sWord))
				Else
					Parameters &= Parameter
				End If
			Next n
			ParametersList.Add te->Parameters
			If te->Comment <> "" Then Comments &= "" & te->Comment
		End If
		If (FECLine > 0) AndAlso FECLine->InAsm Then
			Index = GlobalAsmFunctionsHelp.IndexOf(sWord)
			If Index > -1 Then
				te = GlobalAsmFunctionsHelp.Object(Index)
				If te <> 0 AndAlso LCase(te->Name) = LCase(sWord) AndAlso CInt(Not ParametersList.Contains(te->Parameters)) Then
					Dim As UString res(Any)
					Split te->Parameters, !"\r", res()
					For n As Integer = 0 To UBound(res)
						Parameter = res(n) 'te->Parameters
						Parameters &= IIf(Parameters = "", "", !"\r")
						iPos = InStr(LCase(Parameter), LCase(sWord))
						'If StartsWith(Trim(LCase(Parameter)), LCase(sWord)) Then
						If iPos > 0 AndAlso IsArg(Asc(Mid(Parameter, iPos - 1, 1))) = 0 Then
							FuncName = Mid(Parameter, iPos, Len(sWord))
							Link1 = te->FileName & "~" & Str(te->StartLine) & "~" & FuncName & "~" & FuncName
							Parameters &= ..Left(Parameter, iPos - 1) & "<a href=""" & Link1 & """>" & Mid(Parameter, iPos, Len(sWord)) & "</a>" & Mid(Parameter, iPos + Len(sWord))
						Else
							Parameters &= Parameter
						End If
					Next n
					ParametersList.Add te->Parameters
					If te->Comment <> "" Then Comments &= "" & te->Comment
				End If
			End If
		Else
			Index = tb->txtCode.Content.Procedures.IndexOf(sWord)
			If Index > -1 Then
				For i As Integer = Index To tb->txtCode.Content.Procedures.Count - 1
					te = tb->txtCode.Content.Procedures.Object(i)
					If te <> 0 AndAlso LCase(te->Name) = LCase(sWord) Then
						If CInt(Not ParametersList.Contains(te->Parameters)) Then
							Parameter = te->Parameters
							iPos = InStr(LCase(Parameter), LCase(sWord))
							FuncName = Mid(Parameter, iPos, Len(sWord))
							Link1 = te->FileName & "~" & Str(te->StartLine) & "~" & FuncName & "~" & FuncName
							Parameters &= IIf(Parameters = "", "", !"\r") & ..Left(Parameter, iPos - 1) & "<a href=""" & Link1 & """>" & FuncName & "</a>" & Mid(Parameter, iPos + Len(sWord))
							ParametersList.Add te->Parameters
							If te->Comment <> "" Then Comments &= "" & te->Comment
						End If
					Else
						Exit For
					End If
				Next
			End If
			Index = pGlobalFunctions->IndexOf(sWord)
			If Index > -1 Then
				For i As Integer = Index To pGlobalFunctions->Count - 1
					te = pGlobalFunctions->Object(i)
					If CBool(te <> 0) AndAlso CBool(LCase(te->Name) = LCase(sWord)) Then 'AndAlso CBool(Not te->TypeProcedure)
						If CInt(Not ParametersList.Contains(te->Parameters)) Then
							Dim As UString res(Any)
							Split te->Parameters, !"\r", res()
							For n As Integer = 0 To UBound(res)
								Parameter = res(n) 'te->Parameters
								Parameters &= IIf(Parameters = "", "", !"\r")
								iPos = InStr(LCase(Parameter), LCase(sWord))
								'If StartsWith(Trim(LCase(Parameter)), LCase(sWord)) Then
								If iPos > 0 AndAlso IsArg(Asc(Mid(Parameter, iPos - 1, 1))) = 0 Then
									FuncName = Mid(Parameter, iPos, Len(sWord))
									Link1 = te->FileName & "~" & Str(te->StartLine) & "~" & FuncName & "~" & FuncName
									Parameters &= ..Left(Parameter, iPos - 1) & "<a href=""" & Link1 & """>" & Mid(Parameter, iPos, Len(sWord)) & "</a>" & Mid(Parameter, iPos + Len(sWord))
								Else
									Parameters &= Parameter
								End If
							Next n
							ParametersList.Add te->Parameters
							If te->Comment <> "" Then Comments &= "" & te->Comment
							Index = GlobalFunctionsHelp.IndexOf(sWord)
							If Index > -1 Then
								te = GlobalFunctionsHelp.Object(Index)
								If te <> 0 AndAlso LCase(te->Name) = LCase(sWord) AndAlso CInt(Not ParametersList.Contains(te->Parameters)) Then
									Dim As UString res(Any)
									Split te->Parameters, !"\r", res()
									For n As Integer = 0 To UBound(res)
										Parameter = res(n) 'te->Parameters
										Parameters &= IIf(Parameters = "", "", !"\r")
										iPos = InStr(LCase(Parameter), LCase(sWord))
										'If StartsWith(Trim(LCase(Parameter)), LCase(sWord)) Then
										If iPos > 0 AndAlso IsArg(Asc(Mid(Parameter, iPos - 1, 1))) = 0 Then
											FuncName = Mid(Parameter, iPos, Len(sWord))
											Link1 = te->FileName & "~" & Str(te->StartLine) & "~" & FuncName & "~" & FuncName
											Parameters &= ..Left(Parameter, iPos - 1) & "<a href=""" & Link1 & """>" & Mid(Parameter, iPos, Len(sWord)) & "</a>" & Mid(Parameter, iPos + Len(sWord))
										Else
											Parameters &= Parameter
										End If
									Next n
									ParametersList.Add te->Parameters
									If te->Comment <> "" Then Comments &= "" & te->Comment
								End If
							End If
						End If
					Else
						Exit For
					End If
				Next
			End If
		End If
	End If
	If Comments <> "" Then
		Parameters &= !"\r_________________\r" & Comments
	End If
	Return Parameters
End Function

Sub ParameterInfo(Key As Integer = Asc(","), SelStartChar As Integer = -1, SelEndChar As Integer = -1, sWordAt As String = "")
	If FormClosing Then Exit Sub
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar, k, iSelStartCharFunc, iSelEndCharFunc
	tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	Dim sLine As WString Ptr = @tb->txtCode.Lines(iSelEndLine)
	Dim As Integer posL, posR = 0: k = 0
	Do
		posR = InStr(posR + 1, *sLine, """")
		If posR >= iSelEndChar OrElse posR < 1 Then Exit Do
		k += 1
	Loop
	If k Mod 2 = 1 Then Exit Sub
	k = InStrRev(*sLine, "'", iSelEndChar)
	If k > 0 Then
		posL = InStrRev(*sLine, """", k) : posR = InStr(k, *sLine, """")
		If Not (posL  > 0 AndAlso (posL < k AndAlso posR > k)) Then Exit Sub
	End If
	Dim As String sWord
	Dim As Integer iCount, iPos
	iSelEndCharFunc = iSelEndChar
	If SelStartChar <> -1 Then
		iSelStartCharFunc = SelStartChar
		iSelEndCharFunc = SelEndChar
		sWord = sWordAt
	Else
		If Key = Asc(",") Then
			'If tb->txtCode.ToolTipShowed Then Exit Sub
			iSelStartCharFunc = GetFuncStartChar(sLine, iSelEndChar, iSelEndCharFunc)
		End If
		If Key = Asc("?") OrElse Mid(tb->txtCode.Lines(iSelEndLine), iSelEndChar, 1) = "?" Then
			sWord = "?"
			iSelStartCharFunc = iSelEndChar - 1
		ElseIf Mid(tb->txtCode.Lines(iSelEndLine), iSelStartCharFunc + 1, 1) = "?" Then
			sWord = "?"
		Else
			sWord = tb->txtCode.GetWordAt(iSelEndLine, iSelEndCharFunc - IIf(Key = 0, 0, 1), , True, iSelStartCharFunc)
		End If
	End If
	Dim As TypeElement Ptr te, teOld, teTypeOld
	Dim As String TypeName, OldTypeName
	If sWord = "" Then Exit Sub
	TypeName = tb->txtCode.Content.GetLeftArgTypeName(iSelEndLine, iSelEndCharFunc - 1, te, teOld, teTypeOld, OldTypeName)
	Dim Parameters As UString = GetParameters(sWord, te, teOld)
	If Parameters <> "" Then
		tb->txtCode.HintWord = sWord
		tb->txtCode.Hint = Parameters
		tb->txtCode.ShowToolTipAt(iSelEndLine, iSelStartCharFunc)
		tb->txtCode.SetFocus
		If Key <> 0 Then OnSelChangeEdit(*tb->txtCode.Designer, tb->txtCode, iSelEndLine, iSelEndChar)
	ElseIf Key = 0 Then
		OnSelChangeEdit(*tb->txtCode.Designer, tb->txtCode, iSelEndLine, iSelEndChar)
	End If
End Sub

Sub OnSelChangeEdit(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByVal CurrentLine As Integer, ByVal CurrentCharIndex As Integer)
	Var tb = Cast(TabWindow Ptr, Sender.Tag)
	If tb = 0 Then Exit Sub
	MouseHoverTimerVal = Timer
	Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar, k
	tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	pstBar->Panels[1]->Caption = ML("Row") + " " + WStr(iSelEndLine + 1) + " : " + WStr(tb->txtCode.LinesCount) + WSpace(2) + _
	ML("Column") + " " + WStr(iSelEndChar) + " : " + WStr(Len(tb->txtCode.Lines(iSelEndLine))) + WSpace(2) + _
	ML("Selection") + " " + WStr(Len(tb->txtCode.SelText))
	If Not tb->txtCode.ToolTipShowed Then Exit Sub
	Dim sLine As WString Ptr = @tb->txtCode.Lines(iSelEndLine)
	Dim As WStringList ParametersList
	Dim As String sWord, sWordAt, Symb, FuncName, Parameters, Parameter, Link1, Param
	Dim As UString Lines(Any), Params(Any), LinkParse(Any)
	Dim As Integer iCount, iPos, iPos1, iPos2, n, iParamCount, iSelStartCharFunc, iSelEndCharFunc
	Parameters = tb->txtCode.Hint
	Split Parameters, !"\r", Lines()
	iSelStartCharFunc = GetFuncStartChar(sLine, iSelEndChar, iSelEndCharFunc, iParamCount)
	If Mid(*sLine, iSelStartCharFunc + 1, 1) = "?" Then
		sWordAt = "?"
	Else
		sWordAt = tb->txtCode.GetWordAt(iSelEndLine, iSelEndCharFunc - 2, , True, iSelStartCharFunc)
	End If
	If iSelStartCharFunc <> tb->txtCode.ToolTipChar Then
		If iSelStartCharFunc < 0 Then Exit Sub
		ParameterInfo , iSelStartCharFunc, iSelEndCharFunc, sWordAt
		Exit Sub
	End If
	sWord = tb->txtCode.HintWord
	If sWordAt <> sWord Then Exit Sub
	For i As Integer = 0 To UBound(Lines)
		If Lines(i) = "_________________" Then Exit For
		iPos = InStr(Lines(i), "<a href=""")
		iPos1 = InStr(Lines(i), """>")
		iPos2 = InStr(Lines(i), "</a>")
		Link1 = Mid(Lines(i), iPos + 9, iPos1 - iPos - 9)
		Split Link1, "~", LinkParse()
		If UBound(LinkParse) < 2 Then Continue For
		Lines(i) = ..Left(Lines(i), iPos - 1) & LinkParse(2) & Mid(Lines(i), iPos2 + 4)
		Split GetChangedCommas(Replace(Lines(i), """", "”"), True), ",", Params()
		For j As Integer = 0 To UBound(Params)
			Params(j) = Replace(Replace(Params(j), ";", ","), "`", "=")
			iPos = InStr(Params(j), "(")
			iPos1 = InStr(Params(j), ")")
			If j = 0 AndAlso ((iSelEndChar = iSelEndCharFunc AndAlso iParamCount = 0) OrElse (iPos = 0 AndAlso UBound(Params) = 0 AndAlso Mid(Params(0), InStr(LCase(Params(0)), LCase(sWord)) + Len(sWord), 1) <> " ") OrElse (iParamCount - 1 >= UBound(Params))) Then 'AndAlso (Mid(Params(0), InStr(LCase(Params(0)), LCase(sWord)) + Len(sWord), 1) <> " " OrElse CBool(iSelEndChar = iSelEndCharFunc))) Then
				iPos = InStr(LCase(Params(j)), LCase(sWord))
				If iPos > 0 Then
					sWord = Mid(Params(j), iPos, Len(sWord))
					Params(j) = ..Left(Params(j), iPos - 1) & "<a href=""" & LinkParse(0) & "~" & LinkParse(1) & "~" & sWord & "~" & sWord & """>" & sWord & "</a>" & Mid(Params(j), iPos + Len(sWord))
				End If
			ElseIf iParamCount = j Then
				n = Len(Params(j)) - Len(LTrim(Params(j)))
				If j = 0 AndAlso ..Left(Params(0), 1) = " " Then iPos = InStr(InStr(LCase(Params(j)), LCase(sWord)) + 1, Params(j), " ")
				If ..Left(Params(0), 1) = " " Then iPos1 = Len(Params(j)) + 1
				If iPos1 = 0 Then iPos1 = Len(Params(j)) + 1
				If j = 0 AndAlso iPos > 0 Then
					Param = Mid(Params(j), iPos + 1, iPos1 - iPos - 1)
					Params(j) = ..Left(Params(j), iPos) & "<a href=""" & LinkParse(0) & "~" & LinkParse(1) & "~" & GetCorrectParam(Param) & "~" & sWord & """>" &  Param & "</a>" & Mid(Params(j), iPos1)
				ElseIf iParamCount = UBound(Params) Then
					If iPos1 = 0 Then iPos1 = Len(Params(j)) + 1
					Param = ..Left(Params(j), iPos1 - 1)
					Params(j) = "<a href=""" & LinkParse(0) & "~" & LinkParse(1) & "~" & GetCorrectParam(Param) & "~" & sWord & """>" & Param & "</a>" & Mid(Params(j), iPos1) 'WString(n, " ") &
				ElseIf iParamCount < UBound(Params) Then
					Params(j) = "<a href=""" & LinkParse(0) & "~" & LinkParse(1) & "~" & GetCorrectParam(Params(j)) & "~" & sWord & """>" &  Params(j) & "</a>" 'WString(n, " ") &
				End If
			End If
		Next
		Lines(i) = Join(Params(), ",")
	Next
	Dim As UString JoinedHint = Join(Lines(), !"\r")
	If JoinedHint <> tb->txtCode.Hint Then
		tb->txtCode.Hint = JoinedHint
		tb->txtCode.UpdateToolTip
	End If
End Sub

'Function GetLeftArg(tb As TabWindow Ptr, iSelEndLine As Integer, iSelEndChar As Integer) As String
'	If tb = 0 Then Return ""
'	Dim As String sTemp
'	Dim sLine As WString Ptr = @tb->txtCode.Lines(iSelEndLine)
'	Dim j As Integer
'	For i As Integer = iSelEndChar To 1 Step -1
'		If IsArg(Asc(Mid(*sLine, i, 1))) Then sTemp = Mid(*sLine, i, 1) & sTemp Else Exit For
'	Next
'	If sTemp = "" Then
'		Var WithCount = 1
'		Dim As EditControlLine Ptr ECLine
'		For i As Integer = iSelEndLine To 0 Step -1
'			ECLine = tb->txtCode.Content.Lines.Items[i]
'			If ECLine->ConstructionIndex > 12 Then
'				Return ""
'			ElseIf ECLine->ConstructionIndex = 10 Then
'				If ECLine->ConstructionPart = 2 Then
'					WithCount += 1
'				ElseIf ECLine->ConstructionPart = 0 Then
'					WithCount -= 1
'					If WithCount < 0 Then
'						Return ""
'					ElseIf WithCount = 0 Then
'						sTemp = Trim(Mid(Trim(*ECLine->Text, Any !"\t "), 5), Any !"\t ")
'						Exit For
'					End If
'				End If
'			End If
'		Next
'	End If
'	Return sTemp
'End Function

Function GetChangedCommas(Value As String, FromSecond As Boolean = False) As String
	Dim As String ch, Text
	Dim As Boolean b, bQ
	Dim As Integer iCount = IIf(FromSecond, -1, 0)
	For i As Integer = 1 To Len(Value)
		ch = Mid(Value, i, 1)
		If ch = """" Then
			bQ = Not bQ
		ElseIf Not bQ Then
			If ch = "(" OrElse ch = "{" Then
				iCount += 1
				If iCount = 1 Then b = True
			ElseIf b AndAlso (CBool(ch = ")") OrElse CBool(ch = "}")) Then
				iCount -= 1
				If iCount = 0 Then b = False
			ElseIf b AndAlso ch = "," Then
				Text &= ";"
				Continue For
			ElseIf b AndAlso ch = "=" Then
				Text &= "`"
				Continue For
			End If
		ElseIf ch = "," Then
			Text &= ";"
			Continue For
		ElseIf ch = "=" Then
			Text &= "`"
			Continue For
		End If
		Text &= ch
	Next
	Return Text
End Function

'Function GetTypeFromValue(tb As TabWindow Ptr, Value As String) As String
'	If tb = 0 OrElse Value= "" Then Return ""
'	Dim As String sTemp
'	If StartsWith(LCase(Value), "cast(") OrElse StartsWith(LCase(Value), "*cast(") Then
'		Var Pos1 = InStr(Value, "(")
'		Var Pos2 = InStr(Value, ",")
'		If Pos2 > 0 Then
'			sTemp = WithoutPointers(Trim(Mid(Value, Pos1 + 1, Pos2 - Pos1 - 1)))
'		End If
'	Else
'		Dim As String TypeName
'		Dim As Integer j, iCount
'		Dim As String ch
'		Dim As Boolean b
'		For i As Integer = Len(Value) To 1 Step -1
'			ch = Mid(Value, i, 1)
'			If ch = ")" Then
'				iCount += 1
'				b = True
'			ElseIf b AndAlso ch = "(" Then
'				iCount -= 1
'				If iCount = 0 Then b = False
'			ElseIf Not b Then
'				If IsArg(Asc(ch)) Then
'					sTemp = ch & sTemp
'				ElseIf sTemp <> "" Then
'					If ch = "." Then
'						TypeName = GetTypeFromValue(tb, ..Left(Value, i - 1))
'					ElseIf ch = ">" AndAlso i > 0 AndAlso Mid(Value, i - 1, 1) = "-" Then
'						TypeName = GetTypeFromValue(tb, ..Left(Value, i - 2))
'					End If
'					Exit For
'				Else
'					Exit For
'				End If
'			End If
'		Next
'		If tb->Des Then
'			Dim As SymbolsType Ptr stDesignControl = tb->Des->Symbols(tb->Des->DesignControl)
'			If stDesignControl AndAlso stDesignControl->ReadPropertyFunc Then
'				If CInt(LCase(sTemp) = "this") AndAlso CInt(tb->Des->DesignControl) AndAlso CInt(StartsWith(tb->cboFunction.Text, WGet(stDesignControl->ReadPropertyFunc(tb->Des->DesignControl, "Name")) & " ") OrElse StartsWith(tb->cboFunction.Text, WGet(stDesignControl->ReadPropertyFunc(tb->Des->DesignControl, "Name")) & ".")) Then
'					sTemp = WGet(stDesignControl->ReadPropertyFunc(tb->Des->DesignControl, "Name"))
'				End If
'			End If
'		End If
'		Dim As TypeElement Ptr te, te1
'		Dim As Integer Pos1
'		Dim As String FuncName = tb->cboFunction.Text
'		If TypeName <> "" Then
'			If tb->txtCode.Types.Contains(TypeName) Then
'				tb->FillIntellisense TypeName, @tb->txtCode.Types, True
'			ElseIf tb->txtCode.Enums.Contains(TypeName) Then
'				tb->FillIntellisense TypeName, @tb->txtCode.Enums, True
'			ElseIf pComps->Contains(TypeName) Then
'				tb->FillIntellisense TypeName, pComps, True
'			ElseIf pGlobalTypes->Contains(TypeName) Then
'				tb->FillIntellisense TypeName, pGlobalTypes, True
'			ElseIf pGlobalEnums->Contains(TypeName) Then
'				tb->FillIntellisense TypeName, pGlobalEnums, True
'			End If
'			If FListItems.Contains(sTemp) Then
'				te = FListItems.Object(FListItems.IndexOf(sTemp))
'			End If
'			FListItems.Clear
'		Else
'			If tb->cboFunction.ItemIndex > -1 Then te1 = tb->cboFunction.Items.Item(tb->cboFunction.ItemIndex)->Object
'			Pos1 = InStr(tb->cboFunction.Text, "["): If Pos1 > 0 Then FuncName = Trim(..Left(tb->cboFunction.Text, Pos1 - 1)): TypeName = FuncName
'			Pos1 = InStr(FuncName, "."): If Pos1 > 0 Then TypeName = Trim(..Left(FuncName, Pos1 - 1))
'			If te1 <> 0 AndAlso te1->Elements.Contains(sTemp) Then
'				te = te1->Elements.Object(te1->Elements.IndexOf(sTemp))
'			ElseIf tb->txtCode.Procedures.Contains(sTemp) Then
'				te = tb->txtCode.Procedures.Object(tb->txtCode.Procedures.IndexOf(sTemp))
'			ElseIf tb->txtCode.Args.Contains(sTemp) Then
'				te = tb->txtCode.Args.Object(tb->txtCode.Args.IndexOf(sTemp))
'			ElseIf pGlobalFunctions->Contains(sTemp) Then
'				te = pGlobalFunctions->Object(pGlobalFunctions->IndexOf(sTemp))
'			ElseIf pGlobalArgs->Contains(sTemp) Then
'				te = pGlobalArgs->Object(pGlobalArgs->IndexOf(sTemp))
'			ElseIf TypeName <> "" Then
'				If tb->txtCode.Types.Contains(TypeName) Then
'					'teEnumOld = tb->Types.Object(tb->Types.IndexOf(TypeName))
'					tb->FillIntellisense TypeName, @tb->txtCode.Types, True
'				ElseIf tb->txtCode.Enums.Contains(TypeName) Then
'					tb->FillIntellisense TypeName, @tb->txtCode.Enums, True
'				ElseIf pComps->Contains(TypeName) Then
'					tb->FillIntellisense TypeName, pComps, True
'				ElseIf pGlobalTypes->Contains(TypeName) Then
'					tb->FillIntellisense TypeName, pGlobalTypes, True
'				ElseIf pGlobalEnums->Contains(TypeName) Then
'					tb->FillIntellisense TypeName, pGlobalEnums, True
'				End If
'				If FListItems.Contains(sTemp) Then
'					te = FListItems.Object(FListItems.IndexOf(sTemp))
'				End If
'				FListItems.Clear
'			End If
'		End If
'		If te <> 0 Then
'			sTemp = te->TypeName
'			If sTemp = "" AndAlso te->Value <> "" Then
'				sTemp = GetTypeFromValue(tb, te->Value)
'			End If
'		End If
'	End If
'	Return sTemp
'End Function

'Function GetLeftArgTypeName(tb As TabWindow Ptr, iSelEndLine As Integer, iSelEndChar As Integer, ByRef teEnum As TypeElement Ptr = 0, ByRef teEnumOld As TypeElement Ptr = 0, ByRef OldTypeName As String = "", ByRef Types As Boolean = False) As String
'	If tb = 0 Then Return ""
'	Dim As String sTemp, sTemp2, TypeName, BaseTypeName
'	Dim sLine As WString Ptr
'	Dim As Integer j, iCount, Pos1, iIndex
'	Dim As String ch
'	Dim As Boolean b
'	For j = iSelEndLine To 0 Step -1
'		sLine = @tb->txtCode.Lines(j)
'		If j < iSelEndLine AndAlso Not EndsWith(RTrim(*sLine), " _") Then Exit For
'		For i As Integer = IIf(j = iSelEndLine, iSelEndChar, Len(*sLine)) To 1 Step -1
'			ch = Mid(*sLine, i, 1)
'			If ch = ")" OrElse ch = "]" Then
'				iCount += 1
'				b = True
'			ElseIf CInt(b) AndAlso CInt(ch = "(" OrElse ch = "[") Then
'				iCount -= 1
'				If iCount = 0 Then b = False
'			ElseIf Not b Then
'				If IsArg(Asc(ch)) Then
'					sTemp = ch & sTemp
'				ElseIf sTemp <> "" Then
'					If ch = "." Then
'						TypeName = GetLeftArgTypeName(tb, j, i - 1, teEnumOld, , , Types)
'					ElseIf ch = ">" AndAlso i > 0 AndAlso Mid(*sLine, i - 1, 1) = "-" Then
'						TypeName = GetLeftArgTypeName(tb, j, i - 2, teEnumOld, , , Types)
'					ElseIf CBool(CBool(ch = " ") OrElse CBool(ch = !"\t")) AndAlso CBool(i > 0) AndAlso EndsWith(RTrim(LCase(Left(*sLine, i - 1)), Any "\t "), " as") Then
'						Types = True
'					End If
'					Exit For, For
'				Else
'					Exit For, For
'				End If
'			End If
'			sTemp2 = ch & sTemp2
'		Next
'	Next
'	If StartsWith(LCase(sTemp2), "cast") Then
'		Return GetTypeFromValue(tb, sTemp2)
'	End If
'	If CInt(sTemp = "") AndAlso CInt(StartsWith(sTemp2, "(")) AndAlso CInt(EndsWith(sTemp2, ")")) Then
'		Return GetTypeFromValue(tb, Left(sTemp2, Len(sTemp2) - 1))
'	ElseIf sTemp = "" AndAlso sTemp2 = "" Then
'		Var WithCount = 1
'		Dim As EditControlLine Ptr ECLine
'		For i As Integer = j - 1 To 0 Step -1
'			ECLine = tb->txtCode.Content.Lines.Items[i]
'			If ECLine->ConstructionIndex > 12 Then
'				Return ""
'			ElseIf ECLine->ConstructionIndex = 10 Then
'				If ECLine->ConstructionPart = 2 Then
'					WithCount += 1
'				ElseIf ECLine->ConstructionPart = 0 Then
'					WithCount -= 1
'					If WithCount < 0 Then
'						Return ""
'					ElseIf WithCount = 0 Then
'						TypeName = GetLeftArgTypeName(tb, i, Len(*ECLine->Text), teEnumOld, , , Types)
'						teEnum = teEnumOld
'						Return TypeName
'					End If
'				End If
'			End If
'		Next
'	End If
'	If tb->Des Then
'		Dim As SymbolsType Ptr stDesignControl = tb->Des->Symbols(tb->Des->DesignControl)
'		If stDesignControl AndAlso stDesignControl->ReadPropertyFunc Then
'			If CInt(LCase(sTemp) = "this") AndAlso CInt(tb->Des->DesignControl) Then
'				Dim As String frmName = WGet(stDesignControl->ReadPropertyFunc(tb->Des->DesignControl, "Name"))
'				If CInt(StartsWith(tb->cboFunction.Text, frmName & " ") OrElse StartsWith(tb->cboFunction.Text, frmName & ".")) Then
'					sTemp = frmName
'				ElseIf CInt(StartsWith(tb->cboFunction.Text, frmName & "Type ") OrElse StartsWith(tb->cboFunction.Text, frmName & "Type.")) Then
'					sTemp = frmName & "Type"
'				End If
'			End If
'		End If
'	End If
'	Dim As TypeElement Ptr te, te1, te2
'	If TypeName <> "" Then
'		If LCase(sTemp) = "base" Then
'			If tb->txtCode.Types.Contains(TypeName, , , , iIndex) Then
'				te2 = tb->txtCode.Types.Object(iIndex)
'				If te2 <> 0 Then BaseTypeName = te2->TypeName
'			ElseIf pComps->Contains(TypeName, , , , iIndex) Then
'				te2 = pComps->Object(iIndex)
'				If te2 <> 0 Then BaseTypeName = te2->TypeName
'			ElseIf pGlobalTypes->Contains(TypeName, , , , iIndex) Then
'				te2 = pGlobalTypes->Object(iIndex)
'				If te2 <> 0 Then BaseTypeName = te2->TypeName
'			End If
'			If BaseTypeName <> "" Then
'				If tb->txtCode.Types.Contains(BaseTypeName, , , , iIndex) Then
'					teEnum = tb->txtCode.Types.Object(iIndex)
'				ElseIf pComps->Contains(BaseTypeName, , , , iIndex) Then
'					teEnum = pComps->Object(iIndex)
'				ElseIf pGlobalTypes->Contains(BaseTypeName, , , , iIndex) Then
'					teEnum = pGlobalTypes->Object(iIndex)
'				End If
'				teEnumOld = 0
'				OldTypeName = ""
'				Return BaseTypeName
'			End If
'		End If
'		If tb->txtCode.Types.Contains(TypeName) Then
'			tb->FillIntellisense TypeName, @tb->txtCode.Types, True
'		ElseIf tb->txtCode.Enums.Contains(TypeName) Then
'			tb->FillIntellisense TypeName, @tb->txtCode.Enums, True
'		ElseIf pComps->Contains(TypeName) Then
'			tb->FillIntellisense TypeName, pComps, True
'		ElseIf pGlobalTypes->Contains(TypeName) Then
'			tb->FillIntellisense TypeName, pGlobalTypes, True
'		ElseIf pGlobalEnums->Contains(TypeName) Then
'			tb->FillIntellisense TypeName, pGlobalEnums, True
'		ElseIf pGlobalNamespaces->Contains(TypeName) Then
'			tb->FillIntellisense TypeName, pGlobalNamespaces, True
'		End If
'		If FListItems.Contains(sTemp, , , , iIndex) Then
'			te = FListItems.Object(iIndex)
'			OldTypeName = TypeName
'		End If
'		FListItems.Clear
'	Else
'		Dim As String FuncName = tb->cboFunction.Text
'		If tb->cboFunction.ItemIndex > -1 Then te1 = tb->cboFunction.Items.Item(tb->cboFunction.ItemIndex)->Object
'		Pos1 = InStr(tb->cboFunction.Text, "["): If Pos1 > 0 Then FuncName = Trim(..Left(tb->cboFunction.Text, Pos1 - 1)): TypeName = FuncName
'		Pos1 = InStr(FuncName, "."): If Pos1 > 0 Then TypeName = Trim(..Left(FuncName, Pos1 - 1))
'		If LCase(sTemp) = "this" Then
'			Return TypeName
'		ElseIf LCase(sTemp) = "base" Then
'			If tb->txtCode.Types.Contains(TypeName, , , , iIndex) Then
'				te2 = tb->txtCode.Types.Object(iIndex)
'				If te2 <> 0 Then BaseTypeName = te2->TypeName
'			ElseIf pComps->Contains(TypeName, , , , iIndex) Then
'				te2 = pComps->Object(iIndex)
'				If te2 <> 0 Then BaseTypeName = te2->TypeName
'			ElseIf pGlobalTypes->Contains(TypeName, , , , iIndex) Then
'				te2 = pGlobalTypes->Object(iIndex)
'				If te2 <> 0 Then BaseTypeName = te2->TypeName
'			End If
'			If BaseTypeName <> "" Then
'				If tb->txtCode.Types.Contains(BaseTypeName, , , , iIndex) Then
'					teEnum = tb->txtCode.Types.Object(iIndex)
'				ElseIf pComps->Contains(BaseTypeName, , , , iIndex) Then
'					teEnum = pComps->Object(iIndex)
'				ElseIf pGlobalTypes->Contains(BaseTypeName, , , , iIndex) Then
'					teEnum = pGlobalTypes->Object(iIndex)
'				End If
'				teEnumOld = 0
'				OldTypeName = ""
'				Return BaseTypeName
'			End If
'		End If
'		If te1 <> 0 AndAlso te1->Elements.Contains(sTemp, , , , iIndex) Then
'			te = te1->Elements.Object(iIndex)
'		ElseIf tb->txtCode.Procedures.Contains(sTemp, , , , iIndex) Then
'			te = tb->txtCode.Procedures.Object(iIndex)
'		ElseIf tb->txtCode.Args.Contains(sTemp, , , , iIndex) Then
'			te = tb->txtCode.Args.Object(iIndex)
'		ElseIf pGlobalFunctions->Contains(sTemp, , , , iIndex) Then
'			te = pGlobalFunctions->Object(iIndex)
'		ElseIf pGlobalArgs->Contains(sTemp, , , , iIndex) Then
'			te = pGlobalArgs->Object(iIndex)
'		ElseIf pGlobalTypes->Contains(sTemp, , , , iIndex) Then
'			te = pGlobalTypes->Object(iIndex)
'		ElseIf pGlobalNamespaces->Contains(sTemp, , , , iIndex) Then
'			te = pGlobalNamespaces->Object(iIndex)
'		ElseIf TypeName <> "" Then
'			If tb->txtCode.Types.Contains(TypeName) Then
'				'teEnumOld = tb->Types.Object(tb->Types.IndexOf(TypeName))
'				tb->FillIntellisense TypeName, @tb->txtCode.Types, True
'			ElseIf tb->txtCode.Enums.Contains(TypeName) Then
'				tb->FillIntellisense TypeName, @tb->txtCode.Enums, True
'			ElseIf pComps->Contains(TypeName) Then
'				tb->FillIntellisense TypeName, pComps, True
'			ElseIf pGlobalTypes->Contains(TypeName) Then
'				tb->FillIntellisense TypeName, pGlobalTypes, True
'			ElseIf pGlobalEnums->Contains(TypeName) Then
'				tb->FillIntellisense TypeName, pGlobalEnums, True
'			ElseIf pGlobalNamespaces->Contains(TypeName) Then
'				tb->FillIntellisense TypeName, pGlobalNamespaces, True
'			End If
'			If FListItems.Contains(sTemp, , , , iIndex) Then
'				te = FListItems.Object(iIndex)
'				OldTypeName = TypeName
'			End If
'			FListItems.Clear
'		End If
'	End If
'	If te <> 0 Then
'		sTemp = te->TypeName
'		If te->ElementType = "Namespace" OrElse te->ElementType = "Type" OrElse te->ElementType = "TypeCopy" OrElse te->ElementType = "Union" OrElse te->ElementType = "Enum" Then
'			sTemp = te->Name
'		Else
'			Pos1 = InStrRev(sTemp, ".")
'			If Pos1 > 0 Then sTemp = Mid(sTemp, Pos1 + 1)
'		End If
'		If sTemp = "" AndAlso te->Value <> "" Then
'			sTemp = GetTypeFromValue(tb, te->Value)
'		End If
'	End If
'	teEnum = te
'	Return sTemp
'End Function

Sub OnDropDownCloseUp(ByRef Designer As My.Sys.Object, ByRef Sender As EditControl)
	'Sender.FileDropDown = False
End Sub

Sub OnKeyDownEdit(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer)
	Var tb = Cast(TabWindow Ptr, Sender.Tag)
	If tb = 0 Then Exit Sub
	#ifdef __USE_GTK__
		If Key = GDK_KEY_SPACE AndAlso (Shift And GDK_CONTROL_MASK) Then
			CompleteWord
		End If
	#endif
	If CBool(Key = 32) AndAlso tb->txtCode.DropDownShowed AndAlso Not tb->txtCode.FileDropDown Then 
		tb->txtCode.CloseDropDown
	ElseIf CBool(Key = 8) AndAlso tb->txtCode.DropDownShowed AndAlso tb->txtCode.FileDropDown Then
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		Dim sLine As WString Ptr = @tb->txtCode.Lines(iSelEndLine)
		Select Case Mid(*sLine, iSelEndChar, 1)
		Case Slash, BackSlash
			If StartsWith(LCase(Trim(*sLine, Any !"\t ")), "#include") Then
				Dim sTemp As WString * 1024
				Var Pos1 = InStr(Left(*sLine, iSelEndChar - 1), """")
				If Pos1 = 0 Then Exit Sub
				sTemp = Mid(*sLine, Pos1 + 1, iSelEndChar - Pos1 - 1)
				Var Pos2 = InStrRev(sTemp, Slash)
				Var Pos3 = InStrRev(sTemp, BackSlash)
				If Pos3 > Pos2 Then Pos2 = Pos3
				If Pos2 = 0 Then
					WLet(tb->txtCode.DropDownPath, "")
				Else
					WLet(tb->txtCode.DropDownPath, GetRelativePath(Left(sTemp, Pos2 - 1)))
				End If
				Pos1 = Pos1 + Pos2
				FillFileIntellisenses *tb->txtCode.DropDownPath, IIf(Pos2 = 0, sTemp, Mid(sTemp, Pos2 + 1))
				SelLinePos = iSelEndLine
				SelCharPos = Pos1
				FindComboIndex tb, *sLine, iSelEndChar - 1
				#ifdef __USE_GTK__
					If tb->txtCode.LastItemIndex = -1 Then tb->txtCode.lvIntellisense.SelectedItemIndex = -1
				#endif
				tb->txtCode.DropDownTypeElement = 0
				tb->txtCode.FileDropDown = True
				SetParametersFromDropDown
				tb->txtCode.ShowDropDownAt SelLinePos, SelCharPos
			End If
		End Select
	End If
	'    If Key = 13 Then
	'        If tb->txtCode.DropDownShowed Then
	'            tb->txtCode.cboIntellisense.ShowDropDown False
	'            cboIntellisense_Selected tb->txtCode.cboIntellisense
	'            Key = 0
	'        End If
	'    End If
End Sub

Sub OnKeyPressEdit(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer)
	MouseHoverTimerVal = Timer
	Var tb = Cast(TabWindow Ptr, Sender.Tag)
	If tb = 0 Then Exit Sub
	If IsArg(Key) Then tb->AutoSaveCharCount += 1
	If tb->AutoSaveCharCount > AutoSaveCharMax Then 
	    tb->txtCode.SaveToFile(GetBakFileName(tb->FileName), tb->FileEncoding, tb->NewLineType)
		tb->AutoSaveCharCount = 0
	End If
	If (CInt(Key = Asc(".")) OrElse CInt(Key = Asc(">"))) AndAlso CInt(Not tb->txtCode.DropDownShowed) Then
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar, k
		tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		Dim sLine As WString Ptr = @tb->txtCode.Lines(iSelEndLine)
		Dim As Integer posL, posR = 0: k = 0
		Do
			posR = InStr(posR + 1, *sLine, """")
			If posR >= iSelEndChar OrElse posR < 1 Then Exit Do
			k += 1
		Loop
		If k Mod 2 = 1 Then Exit Sub
		k = InStrRev(*sLine, "'", iSelEndChar)
		If k > 0 Then
			posL = InStrRev(*sLine, """", k) : posR = InStr(k, *sLine, """")
			If Not (posL  > 0 AndAlso (posL < k AndAlso posR > k)) Then Exit Sub
		End If
		k = 1
		If Key = Asc(">") Then
			If Mid(*sLine, iSelEndChar - 1, 1) <> "-" Then Exit Sub
			k = 2
		End If
		Dim As Boolean Types
		Dim As TypeElement Ptr te, Oldte, OldTypete
		Dim As String OldTypeName
		Dim As String TypeName = tb->txtCode.Content.GetLeftArgTypeName(iSelEndLine, iSelEndChar - k, te, Oldte, OldTypete, OldTypeName, Types) 'GetLeftArgTypeName(tb, iSelEndLine, iSelEndChar - k, te, , , Types)
		If Trim(TypeName) = "" Then Exit Sub
		FillIntellisenseByName tb->txtCode.GetWordAt(iSelEndLine, iSelEndChar - k), TypeName, , , , , Types, OldTypete
		#ifdef __USE_GTK__
			If tb->txtCode.lvIntellisense.ListItems.Count = 0 Then Exit Sub
		#else
			If tb->txtCode.cboIntellisense.Items.Count = 0 Then Exit Sub
		#endif
		SelLinePos = iSelEndLine
		SelCharPos = iSelEndChar
		FindComboIndex tb, *sLine, iSelEndChar
		tb->txtCode.DropDownTypeElement = te
		tb->txtCode.FileDropDown = False
		SetParametersFromDropDown
		tb->txtCode.ShowDropDownAt SelLinePos, SelCharPos
	ElseIf CInt(Key = Asc("=")) AndAlso CInt(Not tb->txtCode.DropDownShowed) Then
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar, k, iIndex
		tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		If iSelEndLine <= 0 Then Exit Sub
		Dim sLine As WString Ptr = @tb->txtCode.Lines(iSelEndLine)
		Dim As Integer posL, posR = 0: k = 0
		Do
			posR = InStr(posR + 1, *sLine, """")
			If posR >= iSelEndChar OrElse posR < 1 Then Exit Do
			k += 1
		Loop
		If k Mod 2 = 1 Then Exit Sub
		k = InStrRev(*sLine, "'", iSelEndChar)
		If k > 0 Then
			posL = InStrRev(*sLine, """", k) : posR = InStr(k, *sLine, """")
			If Not (posL  > 0 AndAlso (posL < k AndAlso posR > k)) Then Exit Sub
		End If
		Dim As TypeElement Ptr teEnum
		Dim As String OldTypeName
		Dim As String TypeName = tb->txtCode.Content.GetLeftArgTypeName(iSelEndLine, Len(RTrim(..Left(*sLine, iSelEndChar - 1))), teEnum, , , OldTypeName)
		#ifdef __USE_GTK__
			tb->txtCode.lvIntellisense.ListItems.Clear
		#else
			tb->txtCode.cboIntellisense.Items.Clear
		#endif
		Dim As TypeElement Ptr te
		If TypeName = "" Then
			Exit Sub
		ElseIf TypeName = "Boolean" Then
			AddSorted tb, GetKeyWordCase("False")
			AddSorted tb, GetKeyWordCase("True")
		ElseIf tb->txtCode.Content.Enums.Contains(TypeName, , , , iIndex) Then
			te = tb->txtCode.Content.Enums.Object(iIndex)
			If te <> 0 Then
				For i As Integer = 0 To te->Elements.Count - 1
					AddSorted tb, IIf(te->Name = "", "", te->Name & ".") & te->Elements.Item(i), te->Elements.Object(i)
				Next
			End If
		ElseIf pGlobalEnums->Contains(TypeName, , , , iIndex) Then
			te = pGlobalEnums->Object(iIndex)
			If te <> 0 Then
				For i As Integer = 0 To te->Elements.Count - 1
					AddSorted tb, IIf(te->Name = "", "", te->Name & ".") & te->Elements.Item(i), te->Elements.Object(i)
				Next
			End If
		ElseIf CInt(teEnum <> 0) AndAlso CInt(teEnum->EnumTypeName <> "") AndAlso CInt(pGlobalEnums->Contains(teEnum->EnumTypeName, , , , iIndex)) Then
			te = pGlobalEnums->Object(iIndex)
			If te <> 0 Then
				For i As Integer = 0 To te->Elements.Count - 1
					AddSorted tb, IIf(te->Name = "", "", te->Name & ".") & te->Elements.Item(i), te->Elements.Object(i)
				Next
			End If
		Else
			Exit Sub
		End If
		If iSelEndChar = Len(*sLine) Then tb->txtCode.ReplaceLine iSelEndLine, *sLine & " "
		SelLinePos = iSelEndLine
		SelCharPos = iSelEndChar + 1
		FindComboIndex tb, *sLine, iSelEndChar + 1
		#ifdef __USE_GTK__
			If tb->txtCode.LastItemIndex = -1 Then tb->txtCode.lvIntellisense.SelectedItemIndex = -1
		#endif
		tb->txtCode.DropDownTypeElement = 0
		tb->txtCode.FileDropDown = False
		SetParametersFromDropDown
		tb->txtCode.ShowDropDownAt SelLinePos, SelCharPos
	ElseIf CInt(Key = Asc(" ")) OrElse CInt(Key = Asc(!"\t")) OrElse CInt(Key = Asc("(")) OrElse CInt(Key = Asc(",")) OrElse CInt(Key = Asc("?")) OrElse CInt(Key = 5) AndAlso CInt(Not tb->txtCode.DropDownShowed) Then
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar, k
		tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		Dim sLine As WString Ptr = @tb->txtCode.Lines(iSelEndLine)
		Dim As Integer posL, posR = 0: k = 0
		Do
			posR = InStr(posR + 1, *sLine, """")
			If posR >= iSelEndChar OrElse posR < 1 Then Exit Do
			k += 1
		Loop
		If k Mod 2 = 1 Then Exit Sub
		k = InStrRev(*sLine, "'", iSelEndChar)
		If k > 0 Then
			posL = InStrRev(*sLine, """", k) : posR = InStr(k, *sLine, """")
			If Not (posL  > 0 AndAlso (posL < k AndAlso posR > k)) Then Exit Sub
		End If
		If CInt(Key = Asc(" ") OrElse Key = Asc(!"\t")) AndAlso (CInt(EndsWith(RTrim(LCase(..Left(*sLine, iSelEndChar))), " as")) OrElse _
			CInt(EndsWith(RTrim(LCase(..Left(*sLine, iSelEndChar))), !"\tas"))OrElse _
			CInt(RTrim(LCase(..Left(*sLine, iSelEndChar))) = "as")) Then
			FillTypeIntellisenses
			SelLinePos = iSelEndLine
			SelCharPos = iSelEndChar
			FindComboIndex tb, *sLine, iSelEndChar
			#ifdef __USE_GTK__
				If tb->txtCode.LastItemIndex = -1 Then tb->txtCode.lvIntellisense.SelectedItemIndex = -1
			#endif
			tb->txtCode.DropDownTypeElement = 0
			tb->txtCode.FileDropDown = False
			SetParametersFromDropDown
			tb->txtCode.ShowDropDownAt SelLinePos, SelCharPos
		Else
			ParameterInfo Key
		End If
	ElseIf CInt(Key = Asc("""")) OrElse CInt(Key = Asc(Slash)) OrElse CInt(Key = Asc(BackSlash)) Then
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar, k
		tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		Dim sLine As WString Ptr = @tb->txtCode.Lines(iSelEndLine)
		If StartsWith(LCase(Trim(*sLine, Any !"\t ")), "#include") Then
			Var Pos1 = InStr(Left(*sLine, iSelEndChar - 1), """")
			If Key = Asc("""") Then
				If Pos1 > 0 Then tb->txtCode.CloseDropDown: Exit Sub
				WLet(tb->txtCode.DropDownPath, "")
			Else
				If Pos1 = 0 Then Exit Sub
				WLet(tb->txtCode.DropDownPath, GetRelativePath(Mid(*sLine, Pos1 + 1, iSelEndChar - Pos1 - 1)))
			End If
			FillFileIntellisenses *tb->txtCode.DropDownPath
			SelLinePos = iSelEndLine
			SelCharPos = iSelEndChar
			FindComboIndex tb, *sLine, iSelEndChar
			#ifdef __USE_GTK__
				If tb->txtCode.LastItemIndex = -1 Then tb->txtCode.lvIntellisense.SelectedItemIndex = -1
			#endif
			tb->txtCode.DropDownTypeElement = 0
			tb->txtCode.FileDropDown = True
			SetParametersFromDropDown
			tb->txtCode.ShowDropDownAt SelLinePos, SelCharPos
		End If
	ElseIf tb->txtCode.DropDownShowed Then
		Dim As Boolean bExternalIncludesLoaded = tb->txtCode.Content.ExternalIncludesLoaded
		If (CInt(bExternalIncludesLoaded = False) OrElse CInt(LoadFunctionsCount > 0)) AndAlso CInt(Not tb->txtCode.FileDropDown) Then
			If tb->IsNew Then GetIncludeFiles tb->txtCode.Content, 0
		Else
			If Key <> 8 AndAlso Key <> 127 Then
				#ifdef __USE_GTK__
					If tb->txtCode.lvIntellisense.ListItems.Count = 0 Then Exit Sub
				#else
					If tb->txtCode.cboIntellisense.ItemCount = 0 Then Exit Sub
				#endif
			End If
		End If
		#ifdef __USE_GTK__
			If Key = GDK_KEY_Home OrElse Key = GDK_KEY_End OrElse Key = GDK_KEY_Left OrElse Key = GDK_KEY_Right OrElse _
				Key = GDK_KEY_Escape OrElse Key = GDK_KEY_Escape OrElse Key = GDK_KEY_Up OrElse Key = GDK_KEY_Down OrElse _
				Key = GDK_KEY_Page_Up OrElse Key = GDK_KEY_Page_Down Then
				Exit Sub
			End If
		#endif
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar, k
		tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		Dim sLine As WString Ptr = @tb->txtCode.Lines(iSelEndLine)
		Dim sTemp As WString * 1024
		sTemp = Mid(*sLine, tb->txtCode.DropDownChar + 1, iSelEndChar + 1 - (tb->txtCode.DropDownChar + 1))
		Static OldWord As WString * 200
		If tb->txtCode.FileDropDown Then
			FillFileIntellisenses *tb->txtCode.DropDownPath, sTemp
		Else
			If CBool(OldWord <> "") AndAlso StartsWith(sTemp, OldWord) AndAlso bExternalIncludesLoaded AndAlso CBool(LoadFunctionsCount = 0) Then Exit Sub
			If EndsWith(RTrim(..Left(LCase(*sLine), tb->txtCode.DropDownChar)), " as") Then
				FillTypeIntellisenses sTemp
			ElseIf EndsWith(..Left(*sLine, tb->txtCode.DropDownChar), ".") Then
				'FillIntellisenseByName GetLeftArg(tb, iSelEndLine, tb->txtCode.DropDownChar - 1)
			ElseIf EndsWith(..Left(*sLine, tb->txtCode.DropDownChar), "->") Then
				'FillIntellisenseByName GetLeftArg(tb, iSelEndLine, tb->txtCode.DropDownChar - 2)
			Else
				If Trim(Mid(*sLine, tb->txtCode.DropDownChar + 1)) = "" Then
					tb->txtCode.CloseDropDown
				Else
					FillAllIntellisenses sTemp
				End If
			End If
		End If
		#ifdef __USE_GTK__
			If tb->txtCode.lvIntellisense.ListItems.Count = 0 Then OldWord = sTemp: Exit Sub
		#else
			If tb->txtCode.cboIntellisense.ItemCount = 0 Then 
				OldWord = sTemp: Exit Sub
			Else
				Dim As HWND h = Cast(HWND, SendMessage(tb->txtCode.cboIntellisense.Handle, CBEM_GETCOMBOCONTROL, 0, 0))
				Dim As COMBOBOXINFO cbINFO
				cbINFO.cbSize = SizeOf(COMBOBOXINFO)
				GetComboBoxInfo(h, @cbINFO)
				If cbINFO.hwndList Then
					Dim As Rect rc
					GetWindowRect cbINFO.hwndList, @rc
					MoveWindow cbINFO.hwndList, rc.Left, rc.Top, rc.Right - rc.Left, Max(1, Min(tb->txtCode.cboIntellisense.ItemCount, 7)) * ScaleY(tb->txtCode.cboIntellisense.ItemHeight) + 2, True
				End If
			End If
		#endif
		If OldWord <> "" Then OldWord = ""
		FindComboIndex tb, *sLine, tb->txtCode.DropDownChar
		#ifdef __USE_GTK__
			If tb->txtCode.LastItemIndex = -1 Then tb->txtCode.lvIntellisense.SelectedItemIndex = -1
		#else
			If tb->txtCode.LastItemIndex = -1 Then tb->txtCode.cboIntellisense.ItemIndex = -1
		#endif
	ElseIf AutoComplete AndAlso (CBool(Key >= Asc("A") AndAlso Key <= Asc("Z")) OrElse CBool(Key >= Asc("a") AndAlso Key <= Asc("z")) OrElse CBool(Key = Asc("_"))) Then
		CompleteWord
	End If
End Sub

Function GetResNamePath(ByRef ResName As WString, ByRef ResourceFile As WString) As UString
	'Dim As UString ResourceFile = GetResourceFile(True)
	Dim As WString * 1024 FilePath
	If InStr(ResName, ".") Then
		FilePath = GetRelativePath(ResName, ResourceFile)
		Return FilePath
	Else
		Var Fn = FreeFile_
		Var Result = Open(ResourceFile For Input Encoding "utf-8" As #Fn)
		If Result <> 0 Then Result = Open(ResourceFile For Input Encoding "utf-32" As #Fn)
		If Result <> 0 Then Result = Open(ResourceFile For Input Encoding "utf-16" As #Fn)
		If Result <> 0 Then Result = Open(ResourceFile For Input As #Fn)
		If Result = 0 Then
			Dim As WString * 1024 sLine
			Dim As Integer Pos1
			Dim As String Image
			Do Until EOF(Fn)
				Line Input #Fn, sLine
				Pos1 = InStr(sLine, " BITMAP "): Image = "BITMAP"
				If Pos1 = 0 Then Pos1 = InStr(sLine, " PNG "): Image = "PNG"
				If Pos1 = 0 Then Pos1 = InStr(sLine, " RCDATA "): Image = "RCDATA"
				If Pos1 = 0 Then Pos1 = InStr(sLine, " ICON "): Image = "ICON"
				If Pos1 = 0 Then Pos1 = InStr(sLine, " CURSOR "): Image = "CURSOR"
				If Pos1 > 0 Then
					If Trim(LCase(..Left(sLine, Pos1 - 1))) = Trim(LCase(ResName)) Then
						FilePath = Trim(Mid(sLine, Pos1 + 2 + Len(Image)))
						If EndsWith(FilePath, """") Then FilePath = ..Left(FilePath, Len(FilePath) - 1)
						If StartsWith(FilePath, """") Then FilePath = Mid(FilePath, 2)
						FilePath = GetRelativePath(FilePath, ResourceFile)
						CloseFile_(Fn)
						Return FilePath
					End If
				End If
			Loop
		End If
		CloseFile_(Fn)
		Return ""
	End If
End Function

Sub TabWindow.SetGraphicProperty(Ctrl As Any Ptr, PropertyName As String, TypeName As String, ByRef ResName As WString)
	If Des = 0 Then Exit Sub
	Dim As SymbolsType Ptr st = Des->Symbols(Ctrl)
	If st = 0 OrElse st->ReadPropertyFunc = 0 Then Exit Sub
	Dim As Any Ptr Graphic = st->ReadPropertyFunc(Ctrl, PropertyName)
	If Graphic = 0 Then Exit Sub
	If ResName = "" Then
		Select Case LCase(TypeName)
		Case "graphictype"
			If st->GraphicTypeLoadFromFileFunc Then st->GraphicTypeLoadFromFileFunc(Graphic, "")
			#ifndef __USE_GTK__
				Des->BitmapHandle = 0
			#endif
		Case "bitmaptype"
			If st->BitmapTypeLoadFromFileFunc Then st->BitmapTypeLoadFromFileFunc(Graphic, "")
		Case "icon"
			If st->IconLoadFromFileFunc Then st->IconLoadFromFileFunc(Graphic, "")
		Case "cursor"
			If st->CursorLoadFromFileFunc Then st->CursorLoadFromFileFunc(Graphic, "")
		End Select
		Exit Sub
	End If
	Dim As UString ResourceFile = GetResourceFile(True)
	Dim As WString * 1024 FilePath = GetResNamePath(ResName, ResourceFile)
	Select Case LCase(TypeName)
	Case "graphictype"
		If st->GraphicTypeLoadFromFileFunc Then st->GraphicTypeLoadFromFileFunc(Graphic, FilePath)
	Case "bitmaptype"
		If st->BitmapTypeLoadFromFileFunc Then st->BitmapTypeLoadFromFileFunc(Graphic, FilePath)
	Case "icon"
		If st->IconLoadFromFileFunc Then st->IconLoadFromFileFunc(Graphic, FilePath)
	Case "cursor"
		If st->CursorLoadFromFileFunc Then st->CursorLoadFromFileFunc(Graphic, FilePath)
	End Select
	#ifndef __USE_GTK__
		If Ctrl = Des->DesignControl AndAlso StartsWith(PropertyName, "Graphic") Then
			Dim As SymbolsType Ptr stDesignControl = Des->Symbols(Des->DesignControl)
			If stDesignControl AndAlso stDesignControl->ReadPropertyFunc Then
				Dim As Any Ptr Graphic = stDesignControl->ReadPropertyFunc(Des->DesignControl, "Graphic")
				If Graphic <> 0 Then
					Dim As Any Ptr Bitm = stDesignControl->ReadPropertyFunc(Graphic, "Bitmap")
					If Bitm <> 0 Then
						Dim As HBITMAP Ptr pHBitmap = stDesignControl->ReadPropertyFunc(Bitm, "Handle")
						If pHBitmap <> 0 Then
							Des->BitmapHandle = *pHBitmap
						End If
					End If
				End If
			End If
		End If
	#endif
End Sub

#ifdef __USE_GTK__
	#ifdef __USE_GTK3__
		Function Overlay_get_child_position(self As GtkOverlay Ptr, widget As GtkWidget Ptr, allocation As GdkRectangle Ptr, user_data As Any Ptr) As Boolean
			Dim As Designer Ptr Des = user_data
			allocation->x = Cast(Integer, g_object_get_data(G_OBJECT(widget), "@@@Left"))
			allocation->y = Cast(Integer, g_object_get_data(G_OBJECT(widget), "@@@Top"))
			allocation->width = Des->DotSize
			allocation->height = Des->DotSize
			Return True
		End Function
	#endif
#endif

Function TabWindow.FindControlIndex(ArgName As String) As Integer
	Dim i As Integer = 2
	For i = 2 To cboClass.Items.Count - 1
		If LCase(cboClass.Items.Item(i)->Text) > LCase(ArgName) Then Return i
	Next
	Return i
End Function

Sub TabWindowFormDesign
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	tb->FormDesign
End Sub

Sub AnalyzeTab(Param As Any Ptr)
	Dim As Object Ptr tbOrProject = Param
	Dim As TabWindow Ptr tb1, tb
	Dim As ProjectElement Ptr Project
	If *tbOrProject Is TabWindow Then
		tb = Cast(TabWindow Ptr, tbOrProject)
	Else
		Project = Cast(ProjectElement Ptr, tbOrProject)
	End If
	If GetQuitThread(Project, tb) Then SetLastThread Project, tb, 0: Exit Sub
	Dim As EditControlLine Ptr FECLine
	Dim As Integer i, j, l, IzohBoshi, QavsBoshi, MatnBoshi, iC, t, u, tIndex, tIndex1, r, q, Pos1
	Dim As WString Ptr s
	Dim As Boolean bQ, LinePrinted, WithOldSymbol, bKeyWord, TwoDots, OneDot, bWithoutWith, CStyle, ContinueFromNext, bTypeAs, bInAsm, bFind
	Dim As String KeyWord, Matn, MatnLCase, OldMatnLCase, MatnLCaseWithoutOldSymbol, MatnWithoutOldSymbol, OriginalCaseWord, TypeName1, OldTypeName
	Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	Dim As ListViewItem Ptr LastItem
	Dim As ECColorScheme Ptr sc
	Dim As TypeElement Ptr te, te1, te2, Oldte
	Dim As WStringOrStringList Ptr pkeywords
	Dim As EditControlContent Ptr ecc
	Dim As ConstructionBlock Ptr cb
	Dim As List Contents
	Dim As List TabWindows
	If Project Then
		For i As Integer = 0 To Project->Contents.Count - 1
			tb1 = GetTab(Cast(EditControlContent Ptr, Project->Contents.Item(i))->FileName)
			If tb1 Then
				Contents.Add @tb1->txtCode.Content
			Else
				Contents.Add Project->Contents.Item(i)
			End If
			TabWindows.Add tb1
		Next
	Else
		Contents.Add @tb->txtCode.Content
		TabWindows.Add tb
	End If
	If tb Then
		CStyle = tb->txtCode.Content.CStyle
		tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	End If
	For kk As Integer = 0 To Contents.Count - 1
		ecc = Contents.Item(kk)
		For i As Integer = ecc->Types.Count - 1 To 0 Step -1
			te = ecc->Types.Object(i)
			te->Used = False
			For j As Integer = te->Elements.Count - 1 To 0 Step -1
				te1 = te->Elements.Object(j)
				te1->Used = False
			Next
		Next
		For i As Integer = ecc->Enums.Count - 1 To 0 Step -1
			te = ecc->Enums.Object(i)
			te->Used = False
		Next
		For i As Integer = ecc->Namespaces.Count - 1 To 0 Step -1
			te = ecc->Namespaces.Object(i)
			te->Used = False
		Next
		For i As Integer = ecc->TypeProcedures.Count - 1 To 0 Step -1
			te = ecc->TypeProcedures.Object(i)
			For j As Integer = te->Elements.Count - 1 To 0 Step -1
				te1 = te->Elements.Object(j)
				te1->Used = False
			Next
		Next
		For i As Integer = ecc->Procedures.Count - 1 To 0 Step -1
			te = ecc->Procedures.Object(i)
			te->Used = False
			If te->Declaration Then Continue For
			For j As Integer = te->Elements.Count - 1 To 0 Step -1
				te1 = te->Elements.Object(j)
				te1->Used = False
			Next
		Next
		For i As Integer = ecc->ConstructionBlocks.Count - 1 To 0 Step -1
			cb = ecc->ConstructionBlocks.Item(i)
			For j As Integer = cb->Elements.Count - 1 To 0 Step -1
				te = cb->Elements.Object(j)
				te->Used = False
			Next
		Next
		For i As Integer = ecc->LineLabels.Count - 1 To 0 Step -1
			te = ecc->LineLabels.Object(i)
			te->Used = False
		Next
		For i As Integer = ecc->Args.Count - 1 To 0 Step -1
			te = ecc->Args.Object(i)
			te->Used = False
		Next
	Next kk
	For kk As Integer = 0 To Contents.Count - 1
		ecc = Contents.Item(kk)
		For z As Integer = 0 To ecc->Lines.Count - 1
			If GetQuitThread(Project, tb) Then SetLastThread Project, tb, 0: Exit Sub
			FECLine = ecc->Lines.Items[z]
			Dim As WStringList Ptr pFiles = FECLine->FileList
			Dim As IntegerList Ptr pFileLines = FECLine->FileListLines
			i = i + 1
			If z > 0 Then iC = Cast(EditControlLine Ptr, ecc->Lines.Items[z - 1])->CommentIndex
			s = FECLine->Text
			l = Len(*s)
			bQ = False
			j = 1
			IzohBoshi = 0
			QavsBoshi = 0
			MatnBoshi = 0
			IzohBoshi = 1
			Do While j <= l
				If GetQuitThread(Project, tb) Then SetLastThread Project, tb, 0: Exit Sub
				If iC = 0 AndAlso Mid(*s, j, 1) = """" Then
					bQ = Not bQ
					If bQ Then
						QavsBoshi = j
					Else
						'FECLine->Ends.Add j, @Strings
					End If
				ElseIf Not bQ Then
					If Mid(*s, j, 2) = IIf(CStyle, "/*", "/'") Then
						iC = iC + 1
						If iC = 1 Then
							IzohBoshi = j
						End If
						j = j + 1
					ElseIf iC > 0 AndAlso Mid(*s, j, 2) = IIf(CStyle, "*/", "'/") Then
						iC = iC - 1
						j = j + 1
						If iC = 0 Then
							'FECLine->Ends.Add j, @Comments
						End If
					ElseIf iC = 0 Then
						t = Asc(Mid(*s, j, 1))
						u = Asc(Mid(*s, j + 1, 1))
						If LCase(Mid(" " & *s & " ", j, 5)) = " rem " OrElse LCase(Mid(" " & *s & " ", j, 6)) = " @rem " OrElse LCase(Mid(" " & *s & " ", j, 5)) = !"\trem " Then
							If CInt(ChangeKeyWordsCase) AndAlso CInt(iSelEndLine <> z) AndAlso pkeywords2 <> 0 Then
								'If Not CStyle Then
								'	KeyWord = GetKeyWordCase("rem", pkeywords2)
								'	If KeyWord <> Mid(*s, j, 3) Then Mid(*s, j, 3) = KeyWord
								'End If
							End If
							'FECLine->Ends.Add l, @Comments
							Exit Do
						ElseIf t >= 48 AndAlso t <= 57 OrElse t >= 65 AndAlso t <= 90 OrElse t >= 97 AndAlso t <= 122 OrElse (CInt(FECLine->InAsm = False) AndAlso t = Asc("#")) OrElse t = Asc("$") OrElse t = Asc("_") Then
							If MatnBoshi = 0 Then MatnBoshi = j
							If Not (u >= 48 AndAlso u <= 57 OrElse u >= 65 AndAlso u <= 90 OrElse u >= 97 AndAlso u <= 122 OrElse u = Asc("#") OrElse u = Asc("$") OrElse u = Asc("_")) Then
								Matn = Mid(*s, MatnBoshi, j - MatnBoshi + 1)
								MatnLCase = LCase(Matn)
								If InStr("#$", .Left(Matn, 1)) Then
									MatnLCaseWithoutOldSymbol = Mid(MatnLCase, 2)
									MatnWithoutOldSymbol = Mid(Matn, 2)
									WithOldSymbol = True
								Else
									MatnLCaseWithoutOldSymbol = MatnLCase
									MatnWithoutOldSymbol = Matn
									WithOldSymbol = False
								End If
								bTypeAs = StartsWith(LCase(Trim(*s, Any !"\t ")), "type ") AndAlso OldMatnLCase = "as"
								sc = @Identifiers
								OriginalCaseWord = "":   TypeName1 = "" : te = 0
								If MatnBoshi > 0 Then r = Asc(Mid(*s, MatnBoshi - 1, 1)) Else r = 0 '  ' "->"=45-62
								If MatnBoshi > 1 Then q = Asc(Mid(*s, MatnBoshi - 2, 1)) Else q = 0
								pkeywords = 0
								If CStyle Then
									If MatnLCase = "#define" OrElse MatnLCase = "#include" OrElse MatnLCase = "#macro" Then
										If pkeywords0 <> 0 Then
											sc = @Keywords(KeywordLists.IndexOfObject(pkeywords0)) '@Preprocessors
										End If
									End If
								Else
									bKeyWord = False
									tIndex = -1
									OriginalCaseWord = ""
									bInAsm = (FECLine->InAsm OrElse StartsWith(LCase(Trim(*s, Any !"\t ")), "asm")) AndAlso CBool(MatnLCase <> "asm")
									If bInAsm Then
										tIndex = pkeywordsAsm->IndexOf(MatnLCase)
										If tIndex > -1 Then
											sc = @Keywords(KeywordLists.IndexOfObject(pkeywordsAsm)) '@Asm
											OriginalCaseWord = pkeywordsAsm->Item(tIndex)
											bKeyWord = True
										End If
									End If
									TwoDots = CBool(r = 46 AndAlso q = 46)
									OneDot = False
									bWithoutWith = False
									
									'Membership
									If ChangeIdentifiersCase OrElse SyntaxHighlightingIdentifiers Then
										If Not bInAsm Then
											If CBool(tIndex = -1) AndAlso (Not TwoDots) AndAlso (CBool(r = 46) OrElse CBool(q = 45 AndAlso r = 62)) Then
												OneDot = True
												ecc->GetLeftArgTypeName(z, j, te, , , OldTypeName, , bWithoutWith)
												If te = 0 Then
													'?Matn
												End If
												If bWithoutWith Then
													TwoDots = True
													OneDot = False
												ElseIf te > 0 Then
													tIndex = 0
													If (te->StartLine < z) OrElse MatnBoshi > te->StartChar Then te->Used = True
													OriginalCaseWord = te->Name
													If SyntaxHighlightingIdentifiers Then
														Select Case te->ElementType
														Case E_EnumItem
															sc = @ColorEnumMembers
														Case E_Sub
															sc = @ColorSubs
														Case E_Function
															sc = @ColorGlobalFunctions
														Case E_Property
															sc = @ColorProperties
														Case E_Field, E_Event
															sc = @ColorFields
														Case E_Namespace
															sc = @ColorGlobalNamespaces
														Case E_Type, E_TypeCopy
															sc = @ColorGlobalTypes
														Case E_Enum
															sc = @ColorGlobalEnums
														Case E_Define
															sc = @ColorDefines
														Case E_Macro
															sc = @ColorMacros
														Case Else
															sc = @ColorLocalVariables
														End Select
													End If
												End If
												
												If tIndex = -1 Then
													tIndex = ecc->Defines.IndexOf(MatnLCase)
													If tIndex <> -1 Then
														If Cast(TypeElement Ptr, ecc->Defines.Object(tIndex))->StartLine > z Then
															tIndex = -1
														Else
															OriginalCaseWord = ecc->Defines.Item(tIndex)
															pkeywords = @ecc->Defines
															te = ecc->Defines.Object(tIndex)
															If (te->StartLine < z) OrElse MatnBoshi > te->StartChar Then te->Used = True
															If te > 0 AndAlso SyntaxHighlightingIdentifiers Then
																sc = @ColorDefines
															End If
														End If
													End If
												End If
												
												If tIndex = -1 Then
													tIndex = ecc->IndexOfInListFiles(pGlobalDefines, MatnLCase, pFiles, pFileLines)
													If tIndex <> -1 Then
														te = pGlobalDefines->Object(tIndex)
														te->Used = True
														OriginalCaseWord = pGlobalDefines->Item(tIndex)
														pkeywords = pGlobalDefines
														If te > 0 AndAlso SyntaxHighlightingIdentifiers Then
															sc = @ColorDefines
														End If
													End If
												End If
											End If
										End If
											
										If Not OneDot Then
											If Not bInAsm Then
												If tIndex = -1 AndAlso OldMatnLCase <> "as" Then
													For i As Integer = 0 To FECLine->Args.Count - 1
														tIndex = Cast(TypeElement Ptr, FECLine->Args.Item(i))->Elements.IndexOf(MatnLCase)
														If tIndex <> -1 Then
															pkeywords = @Cast(TypeElement Ptr, FECLine->Args.Item(i))->Elements
															OriginalCaseWord = pkeywords->Item(tIndex)
															te = pkeywords->Object(tIndex)
															If te > 0 AndAlso SyntaxHighlightingIdentifiers Then
																te->Used = True
																Select Case te->ElementType
																Case E_ByRefParameter
																	sc = @ColorByRefParameters
																Case E_ByValParameter
																	sc = @ColorByValParameters
																Case E_Field, E_Event
																	sc = @ColorFields
																Case Else
																	sc = @ColorLocalVariables
																End Select
															End If
															Exit For
														End If
													Next
												End If
											End If
												
											'Procedure
											If (Not TwoDots) AndAlso (tIndex = -1) AndAlso (FECLine->InConstructionBlock > 0) Then
												te = GetFromConstructionBlock(FECLine->InConstructionBlock, MatnLCaseWithoutOldSymbol, z, (OldMatnLCase = "as") AndAlso Not WithOldSymbol)
												If te > 0 Then
													tIndex = 0
													pkeywords = @Cast(ConstructionBlock Ptr, FECLine->InConstructionBlock)->Elements
													OriginalCaseWord = te->Name
													If SyntaxHighlightingIdentifiers Then
														If (te->StartLine < z) OrElse MatnBoshi > te->StartChar Then te->Used = True
														Select Case te->ElementType
														Case E_Sub
															sc = @ColorSubs
														Case E_Function
															sc = @ColorGlobalFunctions
														Case E_Property
															sc = @ColorProperties
														Case E_ByRefParameter
															sc = @ColorByRefParameters
														Case E_ByValParameter
															sc = @ColorByValParameters
														Case E_Field, E_Event
															sc = @ColorFields
														Case E_EnumItem
															sc = @ColorEnumMembers
														Case E_LineLabel
															sc = @ColorLineLabels
														Case Else
															sc = @ColorLocalVariables
														End Select
													End If
												End If
											End If
											
											If (Not TwoDots) AndAlso tIndex = -1 AndAlso FECLine->InConstruction > 0 AndAlso ((OldMatnLCase <> "as") OrElse WithOldSymbol) Then
												tIndex = Cast(TypeElement Ptr, FECLine->InConstruction)->Elements.IndexOf(MatnLCaseWithoutOldSymbol)
												If tIndex <> -1 Then
													If Cast(TypeElement Ptr, Cast(TypeElement Ptr, FECLine->InConstruction)->Elements.Object(tIndex))->StartLine > z AndAlso Cast(TypeElement Ptr, Cast(TypeElement Ptr, FECLine->InConstruction)->Elements.Object(tIndex))->ElementType <> E_LineLabel Then
														tIndex = -1
													Else
														pkeywords = @Cast(TypeElement Ptr, FECLine->InConstruction)->Elements
														OriginalCaseWord = pkeywords->Item(tIndex)
														te = pkeywords->Object(tIndex)
														If te > 0 AndAlso SyntaxHighlightingIdentifiers Then
															If (te->StartLine < z) OrElse MatnBoshi > te->StartChar Then te->Used = True
															Select Case te->ElementType
															Case E_Sub
																sc = @ColorSubs
															Case E_Function
																sc = @ColorGlobalFunctions
															Case E_Property
																sc = @ColorProperties
															Case E_ByRefParameter
																sc = @ColorByRefParameters
															Case E_ByValParameter
																sc = @ColorByValParameters
															Case E_Field, E_Event
																sc = @ColorFields
															Case E_EnumItem
																sc = @ColorEnumMembers
															Case E_LineLabel
																sc = @ColorLineLabels
															Case Else
																sc = @ColorLocalVariables
															End Select
														End If
													End If
												End If
												
												If tIndex = -1 Then
													te = FECLine->InConstruction
													TypeName1 = te->OwnerTypeName
													'Pos1 = InStr(TypeName1, ".")
													'If (CBool(Pos1 > 0) OrElse EndsWith(te->DisplayName, "[Constructor]") OrElse EndsWith(te->DisplayName, "[Destructor]")) AndAlso (CBool(FECLine->InConstruction->StartLine <> z) OrElse FECLine->InConstruction->Declaration) Then
														If (Len(te->OwnerTypeName) > 0) AndAlso (CBool(FECLine->InConstruction->StartLine <> z) OrElse FECLine->InConstruction->Declaration) Then
														'If Pos1 > 0 Then
														'	TypeName1 = ..Left(TypeName1, Pos1 - 1)
														'Else
														'	TypeName1 = te->Name
														'End If
														te = 0
														If ecc->ContainsIn(TypeName1, MatnLCaseWithoutOldSymbol, @ecc->Types, pFiles, pFileLines, True, , , te, z) Then
														ElseIf ecc->ContainsIn(TypeName1, MatnLCaseWithoutOldSymbol, @ecc->Enums, pFiles, pFileLines, True, , , te, z) Then
														ElseIf (ecc->Globals <> 0) AndAlso ecc->ContainsIn(TypeName1, MatnLCaseWithoutOldSymbol, @ecc->Globals->Types, pFiles, pFileLines, True, , , te, z) Then
														ElseIf (ecc->Globals <> 0) AndAlso ecc->ContainsIn(TypeName1, MatnLCaseWithoutOldSymbol, @ecc->Globals->Enums, pFiles, pFileLines, True, , , te, z) Then
														ElseIf ecc->ContainsIn(TypeName1, MatnLCaseWithoutOldSymbol, pComps, pFiles, pFileLines, True, , , te) Then
														ElseIf ecc->ContainsIn(TypeName1, MatnLCaseWithoutOldSymbol, pGlobalTypes, pFiles, pFileLines, True, , , te) Then
														ElseIf ecc->ContainsIn(TypeName1, MatnLCaseWithoutOldSymbol, pGlobalEnums, pFiles, pFileLines, True, , , te) Then
														End If
														If te > 0 Then
															If (te->StartLine < z) OrElse MatnBoshi > te->StartChar Then te->Used = True
															OriginalCaseWord = te->Name
															tIndex = 0
															If SyntaxHighlightingIdentifiers Then
																Select Case te->ElementType
																Case E_Sub
																	sc = @ColorSubs
																Case E_Function
																	sc = @ColorGlobalFunctions
																Case E_Property
																	sc = @ColorProperties
																Case E_Field, E_Event
																	sc = @ColorFields
																Case Else
																	sc = @ColorLocalVariables
																End Select
															End If
														End If
													End If
												End If
											End If
										End If
									End If
									
									If Not bInAsm Then
										If Not OneDot Then
											' Keywords
											If tIndex = -1 Then
												For k As Integer = 1 To KeywordLists.Count - 1
													pkeywords = KeywordLists.Object(k)
													tIndex = pkeywords->IndexOf(MatnLCase)
													If tIndex > -1 Then
														OriginalCaseWord = pkeywords->Item(tIndex)
														sc = @Keywords(k)
														bKeyWord = True
														Exit For
													End If
													pkeywords = 0
													tIndex = -1
												Next
											End If
										End If
									End If
										
									If WithOldSymbol Then MatnLCase = MatnLCaseWithoutOldSymbol
									
									If ChangeIdentifiersCase OrElse SyntaxHighlightingIdentifiers Then
										If Not OneDot Then
											'Module
											If (tIndex = -1) AndAlso ((OldMatnLCase <> "as") OrElse WithOldSymbol) Then
												tIndex = ecc->Args.IndexOf(MatnLCase)
												If tIndex <> -1 Then
													If Cast(TypeElement Ptr, ecc->Args.Object(tIndex))->StartLine > z Then
														tIndex = -1
													Else
														'tb->OriginalCaseWord = tb->txtCode.Args.Item(tIndex)
														pkeywords = @ecc->Args
														te = Cast(TypeElement Ptr, ecc->Args.Object(tIndex))
														If te > 0 AndAlso SyntaxHighlightingIdentifiers Then
															If (te->StartLine < z) OrElse MatnBoshi > te->StartChar Then te->Used = True
															Select Case te->ElementType
															Case E_EnumItem
																sc = @ColorEnumMembers
															Case E_CommonVariable
																sc = @ColorCommonVariables
															Case E_Constant
																sc = @ColorConstants
															Case E_SharedVariable
																sc = @ColorSharedVariables
															Case Else
																sc = @ColorLocalVariables
															End Select
														End If
													End If
												End If
											End If
											
											If Not bInAsm Then
												If tIndex = -1 AndAlso (OldMatnLCase <> "as") Then
													tIndex = ecc->Procedures.IndexOf(MatnLCase)
													If tIndex <> -1 Then
														If Cast(TypeElement Ptr, ecc->Procedures.Object(tIndex))->StartLine > z Then
															tIndex = -1
														Else
															'tb->OriginalCaseWord = tb->txtCode.Procedures.Item(tIndex)
															pkeywords = @ecc->Procedures
															te = Cast(TypeElement Ptr, ecc->Procedures.Object(tIndex))
															If te > 0 AndAlso SyntaxHighlightingIdentifiers Then
																If Not te->Used Then
																	If (te->StartLine < z) OrElse MatnBoshi > te->StartChar Then 
																		te->Used = True
																		If te->Declaration Then
																			bFind = False
																			For ii As Integer = tIndex + 1 To ecc->Procedures.Count - 1
																				te1 = ecc->Procedures.Object(ii)
																				If LCase(te1->Name) <> MatnLCase Then Exit For
																				If Not te1->Declaration Then
																					te1->Used = True
																					bFind = True
																					Exit For
																				End If
																			Next
																			If (Not bFind) AndAlso ecc->Globals > 0 Then
																				tIndex1 = ecc->Globals->Functions.IndexOf(MatnLCase)
																				If tIndex1 <> -1 Then
																					For ii As Integer = tIndex1 To ecc->Globals->Functions.Count - 1
																						te1 = ecc->Globals->Functions.Object(ii)
																						If LCase(te1->Name) <> MatnLCase Then Exit For
																						If Not te1->Declaration Then
																							te1->Used = True
																							bFind = True
																							Exit For
																						End If
																					Next
																				End If
																			End If
																		End If
																	End If
																End If
																Select Case te->ElementType
																Case E_Constructor, E_Destructor
																	sc = @ColorGlobalTypes
																Case E_Function
																	sc = @ColorGlobalFunctions
																Case E_Sub
																	sc = @ColorSubs
																Case E_Define
																	sc = @ColorDefines
																Case E_Macro
																	sc = @ColorMacros
																Case E_Property
																	sc = @ColorProperties
																End Select
															End If
														End If
													End If
												End If
												
												If tIndex = -1 Then
													tIndex = ecc->Types.IndexOf(MatnLCase)
													If tIndex <> -1 Then
														te = Cast(TypeElement Ptr, ecc->Types.Object(tIndex))
														If (Not bTypeAs) AndAlso te->StartLine > z Then
															tIndex = -1
														Else
															If (te->StartLine < z) OrElse MatnBoshi > te->StartChar Then te->Used = True
															If SyntaxHighlightingIdentifiers Then sc = @ColorGlobalTypes
															'tb->OriginalCaseWord = tb->txtCode.Types.Item(tIndex)
															pkeywords = @ecc->Types
														End If
													End If
												End If
												
												If tIndex = -1 Then
													tIndex = ecc->Enums.IndexOf(MatnLCase)
													If tIndex <> -1 Then
														te = Cast(TypeElement Ptr, ecc->Enums.Object(tIndex))
														If (Not bTypeAs) AndAlso te->StartLine > z Then
															tIndex = -1
														Else
															If (te->StartLine < z) OrElse MatnBoshi > te->StartChar Then te->Used = True
															If SyntaxHighlightingIdentifiers Then sc = @ColorGlobalEnums
															'tb->OriginalCaseWord = tb->txtCode.Enums.Item(tIndex)
															pkeywords = @ecc->Enums
														End If
													End If
												End If
												
												If tIndex = -1 Then
													tIndex = ecc->Namespaces.IndexOf(MatnLCase)
													If tIndex <> -1 Then
														te = Cast(TypeElement Ptr, ecc->Namespaces.Object(tIndex))
														If te->StartLine > z Then
															tIndex = -1
														Else
															If (te->StartLine < z) OrElse MatnBoshi > te->StartChar Then te->Used = True
															If SyntaxHighlightingIdentifiers Then sc = @ColorGlobalNamespaces
															'tb->OriginalCaseWord = tb->txtCode.Namespaces.Item(tIndex)
															pkeywords = @ecc->Namespaces
														End If
													End If
												End If
											End If
												
											'Project
											If ecc->Globals > 0 Then
												If Not bInAsm Then
													If tIndex = -1 Then
														If bTypeAs Then
															tIndex = ecc->Globals->Types.IndexOf(MatnLCase)
														Else
															tIndex = ecc->IndexOfInListFiles(@ecc->Globals->Types, MatnLCase, pFiles, pFileLines)
														End If
														If tIndex <> -1 Then
															te = Cast(TypeElement Ptr, ecc->Globals->Types.Object(tIndex))
															te->Used = True
															If SyntaxHighlightingIdentifiers Then sc = @ColorGlobalTypes
															OriginalCaseWord = ecc->Globals->Types.Item(tIndex)
															pkeywords = @ecc->Globals->Types
														End If
													End If
													
													If tIndex = -1 Then
														If bTypeAs Then
															tIndex = ecc->Globals->Enums.IndexOf(MatnLCase)
														Else
															tIndex = ecc->IndexOfInListFiles(@ecc->Globals->Enums, MatnLCase, pFiles, pFileLines)
														End If
														'If MatnLCase = "wstringorstringlist" Then
														'	For i As Integer = 0 To pFiles->Count - 1
														'		?pFiles->Item(i)
														'	Next
														'End If
														If tIndex <> -1 Then
															te = Cast(TypeElement Ptr, ecc->Globals->Enums.Object(tIndex))
															te->Used = True
															If SyntaxHighlightingIdentifiers Then sc = @ColorGlobalEnums
															OriginalCaseWord = ecc->Globals->Enums.Item(tIndex)
															pkeywords = @ecc->Globals->Enums
														End If
													End If
												End If
													
												If tIndex = -1 AndAlso ((OldMatnLCase <> "as") OrElse WithOldSymbol) Then
													tIndex = ecc->IndexOfInListFiles(@ecc->Globals->Args, MatnLCase, pFiles, pFileLines)
													If tIndex <> -1 Then
														te = ecc->Globals->Args.Object(tIndex)
														te->Used = True
														OriginalCaseWord = ecc->Globals->Args.Item(tIndex)
														pkeywords = @ecc->Globals->Args
														If te > 0 AndAlso SyntaxHighlightingIdentifiers Then
															Select Case te->ElementType
															Case E_EnumItem
																sc = @ColorEnumMembers
															Case E_CommonVariable
																sc = @ColorCommonVariables
															Case E_Constant
																sc = @ColorConstants
															Case E_SharedVariable
																sc = @ColorSharedVariables
															Case Else
																sc = @ColorLocalVariables
															End Select
														End If
													End If
												End If
												
												If Not bInAsm Then
													If tIndex = -1 Then
														tIndex = ecc->IndexOfInListFiles(@ecc->Globals->Functions, MatnLCase, pFiles, pFileLines)
														If tIndex <> -1 Then
															te = ecc->Globals->Functions.Object(tIndex)
															If Not te->Used Then
																te->Used = True
																If te->Declaration Then
																	For ii As Integer = tIndex + 1 To ecc->Globals->Functions.Count - 1
																		te1 = ecc->Globals->Functions.Object(ii)
																		If LCase(te1->Name) <> MatnLCase Then Exit For
																		If Not te1->Declaration Then
																			te1->Used = True
																			Exit For
																		End If
																	Next
																End If
															End If
															OriginalCaseWord = ecc->Globals->Functions.Item(tIndex)
															pkeywords = @ecc->Globals->Functions
															If te > 0 AndAlso SyntaxHighlightingIdentifiers Then
																Select Case te->ElementType
																Case E_Constructor, E_Destructor
																	sc = @ColorGlobalTypes
																Case E_Keyword
																	sc = @ColorGlobalFunctions
																Case E_Function
																	sc = @ColorGlobalFunctions
																Case E_Sub
																	sc = @ColorSubs
																Case E_Define
																	sc = @ColorDefines
																Case E_Macro
																	sc = @ColorMacros
																Case E_Property
																	sc = @ColorProperties
																End Select
															End If
														End If
													End If
													
													If tIndex = -1 Then
														tIndex = ecc->IndexOfInListFiles(@ecc->Globals->Namespaces, MatnLCase, pFiles, pFileLines)
														If tIndex <> -1 Then
															te = ecc->Globals->Namespaces.Object(tIndex)
															te->Used = True
															If SyntaxHighlightingIdentifiers Then sc = @ColorGlobalNamespaces
															OriginalCaseWord = ecc->Globals->Namespaces.Item(tIndex)
															pkeywords = @ecc->Globals->Namespaces
														End If
													End If
												End If
											End If
											
											If Not bInAsm Then
												'Global
												If tIndex = -1 Then
													If bTypeAs Then
														tIndex = pComps->IndexOf(MatnLCase)
													Else
														tIndex = ecc->IndexOfInListFiles(pComps, MatnLCase, pFiles, pFileLines)
													End If
													If tIndex <> -1 Then
														If SyntaxHighlightingIdentifiers Then sc = @ColorComps
														OriginalCaseWord = pComps->Item(tIndex)
														pkeywords = pComps
													End If
												End If
												
												If tIndex = -1 Then
													If bTypeAs Then
														tIndex = pGlobalTypes->IndexOf(MatnLCase)
													Else
														tIndex = ecc->IndexOfInListFiles(pGlobalTypes, MatnLCase, pFiles, pFileLines)
													End If
													If tIndex <> -1 Then
														If SyntaxHighlightingIdentifiers Then sc = @ColorGlobalTypes
														OriginalCaseWord = pGlobalTypes->Item(tIndex)
														pkeywords = pGlobalTypes
													End If
												End If
												
												If tIndex = -1 Then
													If bTypeAs Then
														tIndex = pGlobalEnums->IndexOf(MatnLCase)
													Else
														tIndex = ecc->IndexOfInListFiles(pGlobalEnums, MatnLCase, pFiles, pFileLines)
													End If
													If tIndex <> -1 Then
														If SyntaxHighlightingIdentifiers Then sc = @ColorGlobalEnums
														OriginalCaseWord = pGlobalEnums->Item(tIndex)
														pkeywords = pGlobalEnums
													End If
												End If
											End If
											
											If tIndex = -1 AndAlso ((OldMatnLCase <> "as") OrElse WithOldSymbol) Then
												tIndex = ecc->IndexOfInListFiles(pGlobalArgs, MatnLCase, pFiles, pFileLines)
												If tIndex <> -1 Then
													te = pGlobalArgs->Object(tIndex)
													OriginalCaseWord = pGlobalArgs->Item(tIndex)
													pkeywords = pGlobalArgs
													If te > 0 AndAlso SyntaxHighlightingIdentifiers Then
														Select Case te->ElementType
														Case E_EnumItem
															sc = @ColorEnumMembers
														Case E_CommonVariable
															sc = @ColorCommonVariables
														Case E_Constant
															sc = @ColorConstants
														Case E_SharedVariable
															sc = @ColorSharedVariables
														Case Else
															sc = @ColorLocalVariables
														End Select
													End If
												End If
											End If
											
											If Not bInAsm Then
												If tIndex = -1 Then
													tIndex = ecc->IndexOfInListFiles(pGlobalFunctions, MatnLCase, pFiles, pFileLines)
													If tIndex <> -1 Then
														te = pGlobalFunctions->Object(tIndex)
														OriginalCaseWord = pGlobalFunctions->Item(tIndex)
														pkeywords = pGlobalFunctions
														If te > 0 AndAlso SyntaxHighlightingIdentifiers Then
															Select Case te->ElementType
															Case E_Constructor, E_Destructor
																sc = @ColorGlobalTypes
															Case E_Keyword
																sc = @ColorGlobalFunctions
															Case E_Function
																sc = @ColorGlobalFunctions
															Case E_Sub
																sc = @ColorSubs
															Case E_Define
																sc = @ColorDefines
															Case E_Macro
																sc = @ColorMacros
															Case E_Property
																sc = @ColorProperties
															End Select
														End If
													End If
												End If
												
												If tIndex = -1 Then
													tIndex = ecc->IndexOfInListFiles(pGlobalNamespaces, MatnLCase, pFiles, pFileLines)
													If tIndex <> -1 Then
														If SyntaxHighlightingIdentifiers Then sc = @ColorGlobalNamespaces
														OriginalCaseWord = pGlobalNamespaces->Item(tIndex)
														pkeywords = pGlobalNamespaces
													End If
												End If
											End If
											
											If tIndex = -1 Then
												tIndex = ecc->LineLabels.IndexOf(MatnLCase)
												If tIndex <> -1 Then
													te = ecc->LineLabels.Object(tIndex)
													te->Used = True
													If SyntaxHighlightingIdentifiers Then sc = @ColorLineLabels
													OriginalCaseWord = ecc->LineLabels.Item(tIndex)
													pkeywords = @ecc->LineLabels
												End If
											End If
										End If
									End If
									If bKeyWord AndAlso ChangeKeyWordsCase AndAlso MatnLCase = LCase(OriginalCaseWord) AndAlso iSelEndLine <> z Then
										'KeyWord = GetKeyWordCase(Matn, 0, OriginalCaseWord)
										'If KeyWord <> Matn Then
										'	Mid(*FECLine->Text, MatnBoshi, j - MatnBoshi + 1) = KeyWord
										'End If
									ElseIf (Not bKeyWord) AndAlso ChangeIdentifiersCase AndAlso MatnLCase = LCase(OriginalCaseWord) AndAlso tIndex <> -1 AndAlso iSelEndLine <> z Then
										If MatnWithoutOldSymbol <> OriginalCaseWord Then
											'Mid(*FECLine->Text, MatnBoshi + IIf(WithOldSymbol, 1, 0), j - MatnBoshi + 1) = OriginalCaseWord
										End If
									ElseIf tIndex = -1 Then
										If isNumeric(Matn) OrElse isNumeric(MatnWithoutOldSymbol) Then
											If InStr(Matn, ".") Then
												sc = @RealNumbers
											Else
												sc = @Numbers
											End If
										Else
											sc = @Identifiers
											If (Not CStyle) AndAlso CBool(Matn <> "_") AndAlso CBool(OldMatnLCase <> "defined") AndAlso CBool(OldMatnLCase <> "ifdef") AndAlso CBool(OldMatnLCase <> "ifndef") AndAlso CBool(r <> Asc("&")) AndAlso (Not StartsWith(Trim(LCase(*s), Any !"\t "), "#define")) AndAlso (Not StartsWith(Trim(LCase(*s), Any !"\t "), "#undef")) Then
												If GetQuitThread(Project, tb) Then SetLastThread Project, tb, 0: Exit Sub
												MutexLock tlockSuggestions
												ThreadsEnter
												Dim As Integer ii = 0, AddIndex = -1
												Dim As UString ErrorText = ML("Error: Identifier not declared") & ", " & Matn & ". " & ML("Declare it")
												Dim As UString FileName_ = ecc->FileName
												Dim As UString ProjectFileName_
												If Project Then ProjectFileName_ = *Project->FileName
												If LastItem Then ii = LastItem->Index + IIf(ContinueFromNext, 1, 0)
												ContinueFromNext = False
												Do While ii < lvSuggestions.ListItems.Count
													If GetQuitThread(Project, tb) Then MutexUnlock tlockSuggestions: SetLastThread Project, tb, 0: Exit Sub
													LastItem = lvSuggestions.ListItems.Item(ii)
													With *LastItem
														If Project Then
															If .Text(4) < ProjectFileName_ Then ii += 1: Continue Do
															If .Text(4) > ProjectFileName_ Then AddIndex = ii: Exit Do
														Else
															If .Text(3) < FileName_ Then ii += 1: Continue Do
															If .Text(3) > FileName_ Then AddIndex = ii: Exit Do
															If tb->IsNew AndAlso .Tag < tb Then ii += 1: Continue Do
															If tb->IsNew AndAlso .Tag > tb Then AddIndex = ii: Exit Do
														End If
														If .Text(0) = ErrorText AndAlso .Text(1) = WStr(z + 1) AndAlso .Text(2) = WStr(MatnBoshi) AndAlso .Text(3) = FileName_ AndAlso .Text(4) = ProjectFileName_ Then ContinueFromNext = True: Exit Do
														'If Not .Text(0) = ErrorText Then
														'	?WStr(z + 1), ii, .Text(0), ErrorText, GetCurrentThreadId
														'End If
														.ImageKey = "Error"
														.Text(0) = ErrorText
														.Text(1) = WStr(z + 1)
														.Text(2) = WStr(MatnBoshi)
														.Text(3) = FileName_
														.Text(4) = ProjectFileName_
														.Tag = TabWindows.Item(kk)
														ContinueFromNext = True
														Exit Do
													End With
												Loop
												If Not ContinueFromNext Then
													LastItem = *lvSuggestions.ListItems.Add(ErrorText, "Error", , , AddIndex)
													With *LastItem
														.Text(1) = WStr(z + 1)
														.Text(2) = WStr(MatnBoshi)
														.Text(3) = FileName_
														.Text(4) = ProjectFileName_
														.Tag = TabWindows.Item(kk)
														ContinueFromNext = True
													End With
													'If tpSuggestions->Caption <> ML("Suggestions") & IIf(lvSuggestions.ListItems.Count, " (" & lvSuggestions.ListItems.Count & " " & ML("Pos") & ")", "") Then
													'	tpSuggestions->Caption = ML("Suggestions") & IIf(lvSuggestions.ListItems.Count, " (" & lvSuggestions.ListItems.Count & " " & ML("Pos") & ")", "")
													'End If
												End If
												ThreadsLeave
												MutexUnlock tlockSuggestions
											End If
										End If
									End If
								End If
								OldMatnLCase = MatnLCase: Oldte = te
								If (Not bKeyWord) AndAlso WithOldSymbol Then
									'FECLine->Ends.Add MatnBoshi, @NormalText
									'FECLine->Ends.Add j, sc
								Else
									'FECLine->Ends.Add j, sc
								End If
								'End If
								MatnBoshi = 0
							End If
						ElseIf IIf(CStyle, Mid(*s, j, 2) = "//", IIf(FECLine->InAsm, Chr(t) = "#" OrElse Chr(t) = "'", Chr(t) = "'")) Then
							'FECLine->Ends.Add l, @Comments
							Exit Do
						'ElseIf tb->txtCode.CharType(Mid(*s, j, 1)) = 2 Then
						'	'FECLine->Ends.Add j, @ColorOperators
						ElseIf Chr(t) <> " " Then
							'FECLine->Ends.Add j, @NormalText
						End If
					End If
				End If
				j = j + 1
			Loop
			If iC > 0 Then
				'FECLine->Ends.Add l, @Comments
			ElseIf bQ Then
				'FECLine->Ends.Add j, @Strings
			End If
			'If CurExecutedLine <> i AndAlso OldExecutedLine <> i Then FECLine->EndsCompleted = True
		Next z
	Next kk
	Dim As List NotUsedIdentifiers
	For kk As Integer = 0 To Contents.Count - 1
		ecc = Contents.Item(kk)
		For i As Integer = 0 To ecc->Types.Count - 1
			te = ecc->Types.Object(i)
			If te->Used = False Then
				NotUsedIdentifiers.Add te
			End If
			For j As Integer = 0 To te->Elements.Count - 1
				te1 = te->Elements.Object(j)
				If te1->Used = False Then
					NotUsedIdentifiers.Add te1
				End If
			Next
		Next
		For i As Integer = 0 To ecc->Enums.Count - 1
			te = ecc->Enums.Object(i)
			If te->Used = False Then
				NotUsedIdentifiers.Add te
			End If
		Next
		For i As Integer = 0 To ecc->Namespaces.Count - 1
			te = ecc->Namespaces.Object(i)
			If te->Used = False Then
				NotUsedIdentifiers.Add te
			End If
		Next
		For i As Integer = 0 To ecc->TypeProcedures.Count - 1
			te = ecc->TypeProcedures.Object(i)
			For j As Integer = 0 To te->Elements.Count - 1
				te1 = te->Elements.Object(j)
				If te1->Used = False Then
					NotUsedIdentifiers.Add te1
				End If
			Next
		Next
		For i As Integer = 0 To ecc->Procedures.Count - 1
			te = ecc->Procedures.Object(i)
			If te->Used = False Then
				NotUsedIdentifiers.Add te
			End If
			If te->Declaration Then Continue For
			For j As Integer = 0 To te->Elements.Count - 1
				te1 = te->Elements.Object(j)
				If te1->Used = False Then
					NotUsedIdentifiers.Add te1
				End If
			Next
		Next
		For i As Integer = ecc->ConstructionBlocks.Count - 1 To 0 Step -1
			cb = ecc->ConstructionBlocks.Item(i)
			For j As Integer = cb->Elements.Count - 1 To 0 Step -1
				te = cb->Elements.Object(j)
				If te->Used = False Then
					NotUsedIdentifiers.Add te
				End If
			Next
		Next
		For i As Integer = 0 To ecc->LineLabels.Count - 1
			te = ecc->LineLabels.Object(i)
			If te->Used = False Then
				NotUsedIdentifiers.Add te
			End If
		Next
		For i As Integer = 0 To ecc->Args.Count - 1
			te = ecc->Args.Object(i)
			If te->Used = False Then
				NotUsedIdentifiers.Add te
			End If
		Next
	Next kk
	MutexLock tlockSuggestions
	ThreadsEnter
	For i As Integer = 0 To NotUsedIdentifiers.Count - 1
		te = NotUsedIdentifiers.Item(i)
		If CBool(te->ElementType = E_Constructor) OrElse CBool(te->ElementType = E_Destructor) OrElse CBool(te->ElementType = E_ByValParameter) OrElse CBool(te->ElementType = E_ByRefParameter) Then Continue For
		If (te->ElementType = E_Enum OrElse te->ElementType = E_Type OrElse te->ElementType = E_Union) AndAlso te->Name = "" Then Continue For
		Dim As Integer ii = 0, AddIndex = -1, MatnBoshi = te->StartChar, z = te->StartLine
		Dim As UString ErrorText = ML("Warning: Identifier not used") & ", " & te->Name & ", " & ML("delete it if not needed")
		Dim As UString FileName_ = te->FileName
		Dim As UString ProjectFileName_
		If Project Then ProjectFileName_ = *Project->FileName
		If LastItem Then ii = LastItem->Index + IIf(ContinueFromNext, 1, 0)
		ContinueFromNext = False
		Do While ii < lvSuggestions.ListItems.Count
			If GetQuitThread(Project, tb) Then MutexUnlock tlockSuggestions: SetLastThread Project, tb, 0: Exit Sub
			LastItem = lvSuggestions.ListItems.Item(ii)
			With *LastItem
				If Project Then
					If .Text(4) < ProjectFileName_ Then ii += 1: Continue Do
					If .Text(4) > ProjectFileName_ Then AddIndex = ii: Exit Do
				Else
					If .Text(3) < FileName_ Then ii += 1: Continue Do
					If .Text(3) > FileName_ Then AddIndex = ii: Exit Do
					If tb->IsNew AndAlso .Tag < tb Then ii += 1: Continue Do
					If tb->IsNew AndAlso .Tag > tb Then AddIndex = ii: Exit Do
				End If
				If .Text(0) = ErrorText AndAlso .Text(1) = WStr(z + 1) AndAlso .Text(2) = WStr(MatnBoshi) AndAlso .Text(3) = FileName_ AndAlso .Text(4) = ProjectFileName_ Then ContinueFromNext = True: Exit Do
				'If Not .Text(0) = ErrorText Then
				'	?WStr(z + 1), ii, .Text(0), ErrorText, GetCurrentThreadId
				'End If
				.ImageKey = "Warning"
				.Text(0) = ErrorText
				.Text(1) = WStr(z + 1)
				.Text(2) = WStr(MatnBoshi)
				.Text(3) = FileName_
				.Text(4) = ProjectFileName_
				.Tag = te->Tag
				ContinueFromNext = True
				Exit Do
			End With
		Loop
		If Not ContinueFromNext Then
			LastItem = *lvSuggestions.ListItems.Add(ErrorText, "Warning", , , AddIndex)
			With *LastItem
				.Text(1) = WStr(z + 1)
				.Text(2) = WStr(MatnBoshi)
				.Text(3) = FileName_
				.Text(4) = ProjectFileName_
				.Tag = te->Tag
				ContinueFromNext = True
			End With
			'If tpSuggestions->Caption <> ML("Suggestions") & IIf(lvSuggestions.ListItems.Count, " (" & lvSuggestions.ListItems.Count & " " & ML("Pos") & ")", "") Then
			'	tpSuggestions->Caption = ML("Suggestions") & IIf(lvSuggestions.ListItems.Count, " (" & lvSuggestions.ListItems.Count & " " & ML("Pos") & ")", "")
			'End If
		End If
	Next i
	Dim As Integer ii = 0
	If LastItem Then ii = LastItem->Index + IIf(ContinueFromNext, 1, 0)
	Do While ii < lvSuggestions.ListItems.Count
		If Project Then
			If lvSuggestions.ListItems.Item(ii)->Text(4) < *Project->FileName Then ii += 1: Continue Do
			If lvSuggestions.ListItems.Item(ii)->Text(4) > *Project->FileName Then Exit Do
		Else
			If lvSuggestions.ListItems.Item(ii)->Text(3) < tb->FileName Then ii += 1: Continue Do
			If lvSuggestions.ListItems.Item(ii)->Text(3) > tb->FileName Then Exit Do
			If tb->IsNew AndAlso lvSuggestions.ListItems.Item(ii)->Tag < tb Then ii += 1: Continue Do
			If tb->IsNew AndAlso lvSuggestions.ListItems.Item(ii)->Tag > tb Then Exit Do
		End If
		lvSuggestions.ListItems.Remove ii
	Loop
	If tpSuggestions->Caption <> ML("Suggestions") & IIf(lvSuggestions.ListItems.Count, " (" & lvSuggestions.ListItems.Count & " " & ML("Pos") & ")", "") Then
		tpSuggestions->Caption = ML("Suggestions") & IIf(lvSuggestions.ListItems.Count, " (" & lvSuggestions.ListItems.Count & " " & ML("Pos") & ")", "")
	End If
	ThreadsLeave
	MutexUnlock tlockSuggestions
	SetLastThread Project, tb, 0
End Sub

Sub QuitThread(Project As ProjectElement Ptr, tb As TabWindow Ptr)
	SetQuitThread Project, tb, True
	If GetLastThread(Project, tb) <> 0 Then
		#ifndef __USE_GTK__
			Dim As MSG msg
			While GetMessage(@msg, NULL, 0, 0)
				If GetLastThread(Project, tb) = 0 Then Exit While
				If msg.hwnd = lvSuggestions.Handle Then
					TranslateMessage @msg
					DispatchMessage @msg
				End If
			Wend
		#endif
	End If
End Sub

Function GetQuitThread(Project As ProjectElement Ptr, tb As TabWindow Ptr) As Boolean
	If Project Then
		Return Project->bQuitThread
	Else
		Return tb->bQuitThread
	End If
End Function

Sub SetQuitThread(Project As ProjectElement Ptr, tb As TabWindow Ptr, Value As Boolean)
	If Project Then
		Project->bQuitThread = Value
	Else
		tb->bQuitThread = Value
	End If
End Sub

Function GetLastThread(Project As ProjectElement Ptr, tb As TabWindow Ptr) As Any Ptr
	If Project Then
		Return Project->LastThread
	Else
		Return tb->LastThread
	End If
End Function

Sub SetLastThread(Project As ProjectElement Ptr, tb As TabWindow Ptr, ThreadID As Any Ptr)
	If Project Then
		Project->LastThread = ThreadID
	Else
		tb->LastThread = ThreadID
	End If
End Sub

Sub GetIncludeFiles(ByRef Content As EditControlContent, Project As ProjectElement Ptr)
	If SyntaxHighlightingIdentifiers OrElse ChangeIdentifiersCase OrElse AutoSuggestions Then
		Dim As EditControlLine Ptr ECLine
		Dim As TreeNode Ptr ProjectNode
		Dim As UString MainFile = GetMainFile(, Project, ProjectNode, True, True)
		Content.CheckedFiles.Clear
		Content.ExternalFiles.Clear
		Content.ExternalFileLines.Clear
		Content.ExternalIncludes.Clear
		Content.ExternalFiles.Add Content.FileName
		Content.ExternalFileLines.Add 0
		AddExternalIncludes Content, 0, MainFile, Content.FileName
		Content.ExternalIncludesLoaded = True
		For i As Integer = Content.FileLists.Count - 1 To 0 Step -1
			_Delete( Cast(WStringList Ptr, Content.FileLists.Item(i)))
		Next
		For i As Integer = Content.FileListsLines.Count - 1 To 0 Step -1
			_Delete( Cast(IntegerList Ptr, Content.FileListsLines.Item(i)))
		Next
		Content.FileLists.Clear
		Content.FileListsLines.Clear
		Dim As WStringList Ptr LastFileList
		Dim As IntegerList Ptr LastFileListLines
		Dim As Integer OldIncludeLine = -1
		For i As Integer = 0 To Content.Lines.Count - 1
			ECLine = Content.Lines.Items[i]
			If OldIncludeLine = i - 1 Then
				Dim As WStringList Ptr FileList
				Dim As IntegerList Ptr FileListLines
				FileList = _New(WStringList)
				FileListLines = _New(IntegerList)
				Content.FileLists.Add FileList
				Content.FileListsLines.Add FileListLines
				FileList->Sorted = True
				If LastFileList = 0 Then
					UpdateIncludedFilesList Content, *FileList, *FileListLines, i
				Else
					For j As Integer = 0 To LastFileList->Count - 1
						FileList->Add LastFileList->Item(j)
						FileListLines->Add LastFileListLines->Item(j)
					Next
					For j As Integer = 0 To Content.IncludeLines.Count - 1
						If Content.IncludeLines.Item(j) = OldIncludeLine Then
							AddAllIncludedFiles *FileList, *FileListLines, Content.Includes.Item(j)
							Exit For
						End If
					Next j
				End If
				LastFileList = FileList
				LastFileListLines = FileListLines
			End If
			ECLine->FileList = LastFileList
			ECLine->FileListLines = LastFileListLines
			For j As Integer = 0 To Content.IncludeLines.Count - 1
				If Content.IncludeLines.Item(j) = i Then
					OldIncludeLine = i
					Exit For
				End If
			Next j
		Next
	End If
End Sub

Sub SetLineAndCharParameters(te As TypeElement Ptr, ByRef ECLines As List)
	Dim As Integer u = te->StartChar, l, ll = te->StartLine
	Dim As EditControlLine Ptr ECLine2
	For i As Integer = 0 To ECLines.Count - 1
		ECLine2 = ECLines.Items[i]
		l = Len(*ECLine2->Text)
		If u > l Then
			u = u - l
			ll += 1
		Else
			Exit For
		End If
	Next
	If te->EndLine - te->StartLine <= 1 Then
		te->EndLine += ll - te->StartLine
	End If
	te->StartLine = ll
	te->StartChar = u
	te->EndChar = u + Len(te->Name)
End Sub

Sub SplitParameters(ByRef bTrim As WString, Pos5 As Integer, ByRef Parameters As WString, ByRef FileName As WString, func As TypeElement Ptr, LineIndex As Integer, ECLine As EditControlLine Ptr, ByRef ECLines As List, ByRef InCondition As String, Declaration As Boolean, AddArgs As Boolean, tb As TabWindow Ptr = 0, u1 As Integer = 0)
	If Parameters <> "" Then
		If CBool(ECLine <> 0) AndAlso AddArgs Then ECLine->Args.Add func
		Dim As UString CurType, res1(Any), ElementValue
		Dim As Integer Pos1, Pos2, l, c, u = u1, uu, ct
		For i As Integer = Pos5 To Len(bTrim) - 1
			l += 1
			If bTrim[i] = Asc("(") Then
				c += 1
			ElseIf bTrim[i] = Asc(")") Then
				c -= 1
				If c = -1 Then
					l -= 1
					Exit For
				End If
			End If
		Next
		u = u + Pos5
		Split GetChangedCommas(Mid(bTrim, Pos5 + 1, l)), ",", res1()
		uu = u
		For n As Integer = 0 To UBound(res1)
			u = uu
			uu += Len(res1(n)) + 1
			u += Len(res1(n)) - Len(LTrim(res1(n)))
			res1(n) = Trim(Replace(res1(n), ";", ","))
			Pos1 = InStr(res1(n), "=")
			If Pos1 > 0 Then
				ElementValue = Trim(Mid(res1(n), Pos1 + 1))
				u += Len(res1(n)) - Len(LTrim(res1(n)))
				res1(n) = Trim(..Left(res1(n), Pos1 - 1))
			Else
				ElementValue = ""
			End If
			Pos1 = InStr(LCase(res1(n)), " as ")
			If Pos1 > 0 Then
				CurType = Trim(Mid(res1(n), Pos1 + 4))
				CurType = Replace(CurType, "`", "=")
				'Pos2 = InStr(CurType, "*")  'David Change,  a As WString*2
				'If Pos2 > 1 Then CurType = Trim(Mid(res1(n), Pos1 + Len("as") + 2, Pos2 - Pos1 - Len("as") - 1)) Else CurType = Trim(Mid(res1(n), Pos1 + Len("as") + 2))
				'If Pos1 > 0 Then 
					u += Len(res1(n)) - Len(LTrim(res1(n)))
					res1(n) = Trim(..Left(res1(n), Pos1 - 1))
				'End If
			End If
			Var te = _New( TypeElement)
			If res1(n).ToLower.StartsWith("byref") Then
				u += Len(res1(n)) - Len(LTrim(Mid(res1(n), 6)))
				res1(n) = Trim(Mid(res1(n), 6))
				te->ElementType = E_ByRefParameter
			ElseIf res1(n).ToLower.StartsWith("byval") Then
				u += Len(res1(n)) - Len(LTrim(Mid(res1(n), 6)))
				res1(n) = Trim(Mid(res1(n), 6))
				te->ElementType = E_ByValParameter
			Else
				te->ElementType = E_ByValParameter
			End If
			Pos1 = InStr(res1(n), "(")
			If Pos1 > 0 Then
				u += Len(res1(n)) - Len(LTrim(res1(n)))
				res1(n) = Trim(..Left(res1(n), Pos1 - 1))
			End If
			u += Len(res1(n)) - Len(LTrim(res1(n).TrimAll))
			res1(n) = res1(n).TrimAll
			If (Not (CurType.ToLower.StartsWith("sub") OrElse CurType.ToLower.StartsWith("function"))) AndAlso LCase(CurType) <> "my.sys.object" Then
				Pos1 = InStrRev(CurType, ".")
				If Pos1 > 0 Then CurType = Mid(CurType, Pos1 + 1)
			End If
			te->Name = res1(n)
			te->InCondition = InCondition
			te->Declaration = Declaration
			te->DisplayName = res1(n)
			te->TypeIsPointer = CurType.ToLower.EndsWith(" pointer") OrElse CurType.ToLower.EndsWith(" ptr")
			'te->ElementType = IIf(StartsWith(LCase(te->TypeName), "sub("), "Event", "Property")
			te->TypeName = CurType
			te->TypeName = WithoutPointers(te->TypeName)
			te->Value = ElementValue
			te->Locals = 0
			te->StartLine = LineIndex
			te->EndLine = LineIndex
			te->StartChar = u
			te->EndChar = u + Len(res1(n))
			te->Parameters = res1(n) & " As " & CurType
			te->FileName = FileName
			te->Tag = tb
			SetLineAndCharParameters te, ECLines
			func->Elements.Add te->Name, te
		Next
	End If
End Sub

Sub LoadFunctionsWithContent(ByRef FileName As WString, ByRef Project As ProjectElement Ptr, ByRef Content As EditControlContent)
	Dim As TypeElement Ptr te, te1, tbi, func
	Dim As ConstructionBlock Ptr cb
	For i As Integer = Content.Types.Count - 1 To 0 Step -1
		DeleteFromTypeElement(Content.Types.Object(i))
		'te = Content.Types.Object(i)
		'For j As Integer = te->Elements.Count - 1 To 0 Step -1
		'	te1 = te->Elements.Object(j)
		'	For k As Integer = te1->Elements.Count - 1 To 0 Step -1
		'		_Delete(Cast(TypeElement Ptr, te1->Elements.Object(k)))
		'	Next
		'	te1->Elements.Clear
		'	_Delete( Cast(TypeElement Ptr, te->Elements.Object(j)))
		'Next
		'te->Elements.Clear
		'_Delete( Cast(TypeElement Ptr, Content.Types.Object(i)))
	Next
	For i As Integer = Content.Enums.Count - 1 To 0 Step -1
		_Delete( Cast(TypeElement Ptr, Content.Enums.Object(i)))
	Next
	For i As Integer = Content.Namespaces.Count - 1 To 0 Step -1
		_Delete( Cast(TypeElement Ptr, Content.Namespaces.Object(i)))
	Next
	For i As Integer = Content.TypeProcedures.Count - 1 To 0 Step -1
		DeleteFromTypeElement(Content.TypeProcedures.Object(i))
		'te = Content.TypeProcedures.Object(i)
		'For j As Integer = te->Elements.Count - 1 To 0 Step -1
		'	te1 = te->Elements.Object(j)
		'	For k As Integer = te1->Elements.Count - 1 To 0 Step -1
		'		_Delete(Cast(TypeElement Ptr, te1->Elements.Object(k)))
		'	Next
		'	te1->Elements.Clear
		'	_Delete( Cast(TypeElement Ptr, te->Elements.Object(j)))
		'Next
		'te->Elements.Clear
		'_Delete( Cast(TypeElement Ptr, Content.TypeProcedures.Object(i)))
	Next
	For i As Integer = Content.Procedures.Count - 1 To 0 Step -1
		DeleteFromTypeElement(Content.Procedures.Object(i))
		'te = Content.Procedures.Object(i)
		'For j As Integer = te->Elements.Count - 1 To 0 Step -1
		'	te1 = te->Elements.Object(j)
		'	For k As Integer = te1->Elements.Count - 1 To 0 Step -1
		'		_Delete(Cast(TypeElement Ptr, te1->Elements.Object(k)))
		'	Next
		'	te1->Elements.Clear
		'	_Delete( Cast(TypeElement Ptr, te->Elements.Object(j)))
		'Next
		'te->Elements.Clear
		'_Delete( Cast(TypeElement Ptr, Content.Procedures.Object(i)))
	Next
	For i As Integer = Content.ConstructionBlocks.Count - 1 To 0 Step -1
		cb = Content.ConstructionBlocks.Item(i)
		For j As Integer = cb->Elements.Count - 1 To 0 Step -1
			DeleteFromTypeElement(cb->Elements.Object(j))
			'_Delete( Cast(TypeElement Ptr, cb->Elements.Object(j)))
		Next
		cb->Types.Clear
		cb->Enums.Clear
		cb->Elements.Clear
		_Delete(Cast(ConstructionBlock Ptr, Content.ConstructionBlocks.Item(i)))
	Next
	For i As Integer = Content.LineLabels.Count - 1 To 0 Step -1
		_Delete( Cast(TypeElement Ptr, Content.LineLabels.Object(i)))
	Next
	For i As Integer = Content.Args.Count - 1 To 0 Step -1
		DeleteFromTypeElement(Content.Args.Object(i))
		'te = Content.Args.Object(i)
		'For j As Integer = te->Elements.Count - 1 To 0 Step -1
		'	_Delete(Cast(TypeElement Ptr, te->Elements.Object(j)))
		'Next
		'_Delete( Cast(TypeElement Ptr, Content.Args.Object(i)))
	Next
	Content.Types.Clear
	Content.Defines.Clear
	Content.Functions.Clear
	Content.ConstructionBlocks.Clear
	Content.Namespaces.Clear
	Content.Enums.Clear
	Content.TypeProcedures.Clear
	Content.Procedures.Clear
	Content.LineLabels.Clear
	Content.Args.Clear
	Dim As Integer Pos1, Pos2, Pos3, Pos4, Pos5, iStart, iEnd, l, nc
	Dim As Integer OldIncludeLine = -1, LastIndexFunctions, inPubProPri
	Dim As WStringList Ptr LastFileList
	Dim As IntegerList Ptr LastFileListLines
	Dim As UString sFileName = FileName
	Dim As TabWindow Ptr tb
	Dim As EditControlLine Ptr ECLine, ECLine2
	Dim As EditControlStatement Ptr ECStatement, OldECStatement = 0, ecs
	Dim As ConstructionBlock Ptr block, blockprev
	Dim As UString Comments, b, b0, b1, b2, bTrim, bTrimLCase, b0Trim, b0TrimLCase
	Dim As WStringList WithArgs, Namespaces, Includes
	Dim As Integer WithConstructionLine = -1, OldWithConstructionLine = -1
	Dim As WString Ptr FPath, FLine1, FLine2
	Dim As String CurrentCondition
	Dim As Boolean IsBas = EndsWith(LCase(FileName), ".bas") OrElse EndsWith(LCase(FileName), ".frm"), inFunc, bFind, bCurrentFile
	Dim As Integer IncludesCount
	Dim As Boolean IncludesChanged
	Dim As List Constructs, ConstructBlocks
	If IsBas Then
		WLet(FLine1, ..Left(FileName, Len(FileName) - 4) & ".bi")
		WLetEx FLine2, GetFileName(*FLine1), True
	Else
		WLet(FLine1, "")
		WLet(FLine2, "")
	End If
	If SyntaxHighlightingIdentifiers OrElse ChangeIdentifiersCase OrElse AutoSuggestions Then
		If Content.ExternalIncludesLoaded Then
			For i As Integer = 0 To Content.Lines.Count - 1
				b = *Cast(EditControlLine Ptr, Content.Lines.Item(i))->Text
				If StartsWith(LCase(Trim(b, Any !"\t ")), "#include ") Then
					Pos1 = InStr(b, """")
					If Pos1 > 0 Then
						Pos2 = InStr(Pos1 + 1, b, """")
						If Pos2 - Pos1 - 1 > 0 Then WLet(FPath, GetRelativePath(Mid(b, Pos1 + 1, Pos2 - Pos1 - 1), FileName)) Else WLet(FPath, "")
						IncludesCount += 1
						If IncludesCount > Content.OldIncludes.Count OrElse *FPath <> Content.OldIncludes.Item(IncludesCount - 1) Then 'i <> OldIncludeLines.Item(IncludesCount - 1)
							IncludesChanged = True
							Exit For
						End If
					End If
				End If
			Next
			If IncludesCount <> Content.OldIncludes.Count Then
				IncludesChanged = True
			End If
		Else
			Dim As TreeNode Ptr ProjectNode
			Dim As UString MainFile = GetMainFile(, Project, ProjectNode, True, True)
			Content.CheckedFiles.Clear
			Content.ExternalFiles.Clear
			Content.ExternalFileLines.Clear
			Content.ExternalIncludes.Clear
			Content.ExternalFiles.Add sFileName
			Content.ExternalFileLines.Add 0
			AddExternalIncludes Content, 0, MainFile, sFileName
			Content.ExternalIncludesLoaded = True
			IncludesChanged = True
		End If
		If IncludesChanged Then
			For i As Integer = Content.FileLists.Count - 1 To 0 Step -1
				_Delete( Cast(WStringList Ptr, Content.FileLists.Item(i)))
			Next
			For i As Integer = Content.FileListsLines.Count - 1 To 0 Step -1
				_Delete( Cast(IntegerList Ptr, Content.FileListsLines.Item(i)))
			Next
			Content.FileLists.Clear
			Content.FileListsLines.Clear
			Content.Includes.Clear
			Content.IncludeLines.Clear
			Content.OldIncludes.Clear
			Content.OldIncludeLines.Clear
		End If
	End If
	IncludesCount = 0
	For j As Integer = 0 To Content.Lines.Count - 1
		'If (Not bFind) AndAlso IsBas AndAlso StartsWith(LTrim(LCase(*Cast(EditControlLine Ptr, Content.Lines.Item(j))->Text), Any !"\t "), "#include once """ & LCase(*FLine2) & """") Then
		'	sFileName = *FLine1
		'	If IncludesChanged Then
		'		Content.Includes.Add sFileName
		'		Content.IncludeLines.Add j
		'		Includes.Add sFileName
		'	End If
		'	OldIncludeLine = j
		'	bFind = True
		'	iStart = 0
		'	iEnd = Content.Lines.Count - 1
		'	bCurrentFile = False
		'Else
			sFileName = FileName
			iStart = j
			iEnd = j
			bCurrentFile = True
		'End If
		For i As Integer = iStart To iEnd
			ECLine = Content.Lines.Items[i]
			If bCurrentFile Then
				ECLine->Args.Clear
				ECLine->Ends.Clear
				ECLine->EndsCompleted = False
				If SyntaxHighlightingIdentifiers OrElse ChangeIdentifiersCase OrElse AutoSuggestions Then
					If OldIncludeLine = i - 1 Then
						Dim As WStringList Ptr FileList
						Dim As IntegerList Ptr FileListLines
						IncludesCount += 1
						If IncludesChanged Then
							FileList = _New(WStringList)
							FileListLines = _New(IntegerList)
							Content.FileLists.Add FileList
							Content.FileListsLines.Add FileListLines
							FileList->Sorted = True
							If LastFileList = 0 Then
								UpdateIncludedFilesList Content, *FileList, *FileListLines, j
							Else
								For i As Integer = 0 To LastFileList->Count - 1
									FileList->Add LastFileList->Item(i)
									FileListLines->Add LastFileListLines->Item(i)
								Next
								For i As Integer = 0 To Includes.Count - 1
									AddAllIncludedFiles *FileList, *FileListLines, Includes.Item(i)
									Content.OldIncludes.Add Includes.Item(i)
									Content.OldIncludeLines.Add OldIncludeLine
								Next i
							End If
							Includes.Clear
						Else
							FileList = Content.FileLists.Item(IncludesCount - 1)
							FileListLines = Content.FileListsLines.Item(IncludesCount - 1)
						End If
						LastFileList = FileList
						LastFileListLines = FileListLines
						ECLine->FileList = LastFileList
						ECLine->FileListLines = LastFileListLines
					End If
				End If
				ECLine->FileList = LastFileList
				ECLine->FileListLines = LastFileListLines
				ECLine->InConstruction = 0
				ECLine->InConstructionBlock = 0
				If block Then ECLine->InConstructionBlock = block
				If inFunc Then ECLine->InConstruction = func
			End If
			b1 = Replace(*ECLine->Text, !"\t", " ")
			If StartsWith(Trim(b1), "'") Then
				Comments &= Mid(Trim(b1), 2) & Chr(13) & Chr(10)
				Continue For
			ElseIf Trim(b1) = "" Then
				Comments = ""
				Continue For
			End If
			'Dim As UString res(Any)
			'Split(b1, """", res())
			'b2 = ""
			'For j As Integer = 0 To UBound(res)
			'	If j = 0 Then
			'		b2 = res(0)
			'	ElseIf j Mod 2 = 0 Then
			'		b2 &= """" & res(j)
			'	Else
			'		b2 &= """" & WSpace(Len(res(j)))
			'	End If
			'Next
			'Pos1 = InStr(b2, "/'")
			'Pos2 = InStr(b2, "'")
			'If Pos1 = 0 OrElse (Pos2 <> 0 AndAlso Pos2 < Pos1) Then Pos1 = Pos2
			'If Pos1 > 0 Then
			'	b2 = ..Left(b2, Pos1 - 1)
			'End If
			'If inFunc AndAlso func <> 0 AndAlso (func->ElementType = "Type" OrElse func->ElementType = "Union") Then
			'	b2 = Replace(b2, ":", "%")
			'End If
			'Split(b2, ":", res())
			Dim As Integer k = 1, u
			'For jj As Integer = 0 To UBound(res)
			For jj As Integer = 0 To ECLine->Statements.Count - 1
				ECStatement = ECLine->Statements.Items[jj]
				ECStatement->InConstruction = 0
				ECStatement->InConstructionBlock = 0
				If OldECStatement > 0 AndAlso EndsWith(Trim(*OldECStatement->Text), " _") Then 
					OldECStatement = ECStatement
					k = k + Len(*ECStatement->Text) + 1
					If i > 0 Then
						ECLine2 = Content.Lines.Items[i - 1]
						For iii As Integer = 0 To ECLine2->Args.Count - 1
							ECLine->Args.Add ECLine2->Args.Items[iii]
						Next
					End If
					Continue For
				Else
					OldECStatement = ECStatement
				End If
				b2 = *ECStatement->Text
				Dim As List ECLines
				ECLines.Add ECLine
				If EndsWith(RTrim(b2), " _") Then
					For iii As Integer = i To Content.Lines.Count - 1
						ECLine2 = Content.Lines.Items[iii]
						If iii > i Then
							b1 = IIf(EndsWith(RTrim(b1), " _"), ..Left(b1, Len(RTrim(b1)) - 1) & Space(Len(b1) - Len(RTrim(b1)) + 1), b1) & Replace(*ECLine2->Text, !"\t", " ")
							ECLine2->Args.Clear
							ECLines.Add ECLine2
						End If
						For iiii As Integer = IIf(iii = i, jj + 1, 0) To ECLine2->Statements.Count - 1
							ecs = ECLine2->Statements.Items[iiii]
							b2 = ..Left(b2, Len(RTrim(b2)) - 1) & Space(Len(b2) - Len(RTrim(b2)) + 1) & *ecs->Text
							If Not EndsWith(Trim(*ecs->Text), " _") Then
								Exit For, For
							End If
						Next
					Next
				End If
				'l = Len(res(jj))
				l = Len(b2)
				b = Mid(b1, k, l)
				b0 = Mid(b2, k, l)
				bTrim = Trim(b, Any !"\t ")
				b0Trim = Trim(Mid(b2, k, l))
				bTrimLCase = LCase(bTrim)
				b0TrimLCase = LCase(Trim(b0, Any !"\t "))
				u = k
				'k = k + Len(res(jj)) + 1
				k = k + l + 1
				u = u + Len(b) - Len(LTrim(b, Any !"\t "))
				'			ECLine->InConstructionIndex = ConstructionIndex
				'			ECLine->InConstructionPart = ConstructionPart
				'			If ECLine->ConstructionIndex > 0 AndAlso ECLine->ConstructionIndex <> 1 AndAlso ECLine->ConstructionIndex <> 2 AndAlso ECLine->ConstructionIndex <> 3 Then
				'				If ECLine->ConstructionPart = 0 Then
				'					ConstructionIndex = ECLine->ConstructionIndex
				'					ConstructionBlocks.Add ECLine
				'				ElseIf ECLine->ConstructionPart = 1 Then
				'					ConstructionPart = ECLine->ConstructionPart
				'				ElseIf ECLine->ConstructionPart = 2 Then
				'					If ConstructionBlocks.Count > 0 Then
				'						ECLIne2 = ConstructionBlocks.Items[ConstructionBlocks.Count - 1]
				'						If ECLine2->ConstructionIndex <> ECLine->ConstructionIndex AndAlso ECLine2->ConstructionIndex <> 3 AndAlso ECLine2->ConstructionIndex <> 2 Then
				'							' Does not match construction blocks
				'						Else
				'							ConstructionBlocks.Remove ConstructionBlocks.Count - 1
				'							If ConstructionBlocks.Count > 0 Then
				'								ECLIne2 = ConstructionBlocks.Items[ConstructionBlocks.Count - 1]
				'								ConstructionIndex = ECLIne2->ConstructionIndex
				'								ConstructionPart = 0
				'							Else
				'								ConstructionIndex = -1
				'								ConstructionPart = 0
				'							End If
				'						End If
				'					Else
				'						' Do not found construction index
				'					End If
				'				End If
				'			End If
				ECLine->InWithConstruction = WithConstructionLine
				If ECLine->ConstructionIndex = C_With Then
					If ECLine->ConstructionPart = 0 Then
						OldWithConstructionLine = WithConstructionLine
						WithConstructionLine = i
					Else
						WithConstructionLine = OldWithConstructionLine
					End If
				End If
				If StartsWith(bTrimLCase, "#include ") Then
					#ifndef __USE_GTK__
						Pos1 = InStr(b, """")
						If Pos1 > 0 Then
							Pos2 = InStr(Pos1 + 1, b, """")
							If Pos2 - Pos1 - 1 > 0 Then
								WLet(FPath, GetRelativePath(Mid(b, Pos1 + 1, Pos2 - Pos1 - 1), FileName))
								If bCurrentFile Then
									If IncludesChanged Then
										Content.Includes.Add *FPath
										Content.IncludeLines.Add j
										Includes.Add *FPath
									End If
									OldIncludeLine = j
								End If
								If Not pLoadPaths->Contains(*FPath) Then
									Var AddedIndex = pLoadPaths->Add(*FPath)
									ThreadCounter(ThreadCreate_(@LoadFunctionsSub, @pLoadPaths->Item(AddedIndex)))
								End If
							Else
								WLet(FPath, "")
							End If
						End If
					#endif
				Else
					If (ECStatement->ConstructionIndex >= 0) AndAlso (ECStatement->ConstructionIndex <> C_P_If) AndAlso (ECStatement->ConstructionIndex <> C_P_Region) Then
						If ECStatement->ConstructionPart > 0 Then
							If ConstructBlocks.Count > 0 Then ConstructBlocks.Remove ConstructBlocks.Count - 1
							If ConstructBlocks.Count > 0 Then
								block = ConstructBlocks.Item(ConstructBlocks.Count - 1)
							Else
								block = 0
							End If
							If ECStatement->ConstructionPart <> 2 Then ECStatement->InConstructionBlock = block
						End If
						If ECStatement->ConstructionPart < 2 Then
							Var cb = _New(ConstructionBlock)
							cb->ConstructionIndex = ECStatement->ConstructionIndex
							cb->ConstructionPart = ECStatement->ConstructionPart
							cb->InConstructionBlock = block
							ConstructBlocks.Add cb
							Content.ConstructionBlocks.Add cb
							block = cb
							ECLine->InConstructionBlock = block
							ECStatement->InConstructionBlock = block
						End If
					End If
					If ECStatement->ConstructionIndex >= 0 AndAlso Constructions(ECStatement->ConstructionIndex).Accessible Then
						If ECStatement->ConstructionPart = 0 Then
							Pos1 = 0
							Pos2 = 0
							l = 0
							inPubProPri = 0
							inFunc = True
							Pos1 = InStr(" " & bTrimLCase & IIf(ECStatement->ConstructionIndex = C_Enum OrElse ECStatement->ConstructionIndex = C_Type OrElse ECStatement->ConstructionIndex = C_Union, " ", ""), " " & LCase(Constructions(ECStatement->ConstructionIndex).Name0) & " ")
							If Pos1 > 0 Then
								l = Len(Trim(Constructions(ECStatement->ConstructionIndex).Name0)) + 1
								u = u + Len(bTrim) - Len(LTrim(Mid(bTrim, Pos1 + l)))
								bTrim = Trim(Mid(bTrim, Pos1 + l))
								bTrimLCase = Trim(Mid(bTrimLCase, Pos1 + l))
								l = 0
								Pos1 = 1
								Pos4 = Pos1 + l
								Pos2 = InStr(Pos1 + l, bTrim, "(")
								Pos5 = Pos2
								Pos3 = InStr(Pos1 + l, bTrim, " ")
								If Pos3 > 0 AndAlso (Pos2 = 0 OrElse Pos3 < Pos2) Then Pos2 = Pos3
								te = _New( TypeElement)
								If Pos2 > 0 Then
									te->Name = Trim(Mid(bTrim, Pos1 + l, Pos2 - Pos1 - l))
								Else
									te->Name = Trim(Mid(bTrim, Pos1 + l))
								End If
								te->InCondition = CurrentCondition
								te->StartChar = u ' + Pos1 + l
								te->EndChar = te->StartChar + Len(te->Name)
								Pos1 = InStr(te->Name, ".")
								Dim As Boolean TypeProcedure
								If Pos1 > 0 Then 
									te->DisplayName = Mid(te->Name, Pos1 + 1) & " [" & ..Left(te->Name, Pos1 - 1) & "]"
									te->OwnerTypeName = Left(te->Name, Pos1 - 1)
									te->Name = Mid(te->Name, Pos1 + 1): TypeProcedure = True: te->StartChar = te->StartChar + Pos1 + l
								Else
									te->DisplayName = te->Name
								End If
								If ECStatement->ConstructionIndex = C_Property Then
									If EndsWith(bTrim, ")") Then
										te->DisplayName = te->DisplayName & " [Let]"
									Else
										te->DisplayName = te->DisplayName & " [Get]"
									End If
								ElseIf CInt(ECStatement->ConstructionIndex >= C_Enum AndAlso ECStatement->ConstructionIndex <= C_Union) OrElse CInt(ECStatement->ConstructionIndex >= C_Operator AndAlso ECStatement->ConstructionIndex <= C_Destructor) Then
									te->DisplayName = te->DisplayName & " [" & Trim(Constructions(ECStatement->ConstructionIndex).Name0) & "]"
								Else
									te->DisplayName = te->DisplayName
								End If
								'te->TypeProcedure = TypeProcedure
								Pos2 = InStr(bTrim, ")")
								If ECStatement->ConstructionIndex = C_Constructor OrElse ECStatement->ConstructionIndex = C_Destructor Then
									te->TypeName = te->Name
									te->OwnerTypeName = te->Name
									te->Parameters = te->Name & IIf(Pos5 > 0, Mid(bTrim, Pos5), "()")
								Else
									te->Parameters = Mid(bTrim, Pos4 + Pos1)
									Pos3 = InStr(Pos2, bTrimLCase, ")as ")
									If Pos3 = 0 Then Pos3 = InStr(Pos2 + 1, bTrimLCase, " as ")
									If Pos3 = 0 Then Pos3 = InStr(Pos2 + 1, bTrimLCase, " extends "): If Pos3 > 0 Then Pos3 += 5
									If Pos3 = 0 Then Pos3 = Len(b)
									te->TypeName = Trim(Mid(bTrim, Pos3 + 4))
									If te->Name = "Object" And te->TypeName = "Object" Then
										te->Name = "My.Sys.Object"
										te->TypeName = ""
									End If
									Pos4 = InStr(te->TypeName, "'")
									If Pos4 > 0 Then
										te->TypeName = Trim(..Left(te->TypeName, Pos4 - 1))
									End If
									te->TypeName = WithoutPointers(te->TypeName)
								End If
								Select Case ECStatement->ConstructionIndex
								Case C_P_Macro: te->ElementType = E_Macro
								Case C_Enum: te->ElementType = E_Enum
								Case C_Class, C_Type: te->ElementType = E_Type
								Case C_Union: te->ElementType = E_Union
								Case C_Sub: te->ElementType = E_Sub
								Case C_Function: te->ElementType = E_Function
								Case C_Property: te->ElementType = E_Property
								Case C_Operator: te->ElementType = E_Operator
								Case C_Constructor: te->ElementType = E_Constructor
								Case C_Destructor: te->ElementType = E_Destructor
								End Select
								te->StartLine = i
								te->EndLine = i + 1
								te->FileName = sFileName
								te->Tag = tb
								SetLineAndCharParameters te, ECLines
								ECStatement->InConstruction = te
								ECLine->InConstruction = te
								If block Then block->Construction = te
								If (te->Name = "") AndAlso Constructs.Count > 0 Then
									func = Constructs.Item(Constructs.Count - 1)
								Else
									func = te
								End If
								Constructs.Add func
								If Comments <> "" Then te->Comment = Comments: Comments = ""
								LastIndexFunctions = Content.Functions.Add(te->DisplayName, te)
								blockprev = 0
								If ConstructBlocks.Count > 1 Then
									blockprev = ConstructBlocks.Item(ConstructBlocks.Count - 2)
								End If
								If blockprev Then
									Select Case blockprev->ConstructionIndex
									Case C_Enum, C_Type, C_Union, C_Class
										blockprev->Construction->Elements.Add te->Name, te
									Case Else
										blockprev->Elements.Add te->Name, te
									End Select
								Else
									If ECStatement->ConstructionIndex = C_Enum Then
										Content.Enums.Add te->Name, te
										Project->Globals.Enums.Add te->Name, te
									ElseIf ECStatement->ConstructionIndex = C_Type OrElse ECStatement->ConstructionIndex = C_Class OrElse ECStatement->ConstructionIndex = C_Union Then
										Content.Types.Add te->Name, te
										Project->Globals.Types.Add te->Name, te
									ElseIf TypeProcedure Then
										Content.TypeProcedures.Add te->Name, te
										Project->Globals.TypeProcedures.Add te->Name, te
									Else
										Content.Procedures.Add te->Name, te
										Project->Globals.Functions.Add te->Name, te
										If ECStatement->ConstructionIndex = C_P_Macro Then Content.Defines.Add te->Name, te
									End If
									If Not TypeProcedure Then
										If Namespaces.Count > 0 Then
											Var Index = Content.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
											If Index > -1 Then Cast(TypeElement Ptr, Content.Namespaces.Object(Index))->Elements.Add te->Name, te
										End If
									End If
								End If
								If Pos2 > 0 AndAlso Pos5 > 0 Then
									SplitParameters bTrim, Pos5, Mid(bTrim, Pos5 + 1, Pos2 - Pos5 - 1), sFileName, te, i, 0, ECLines, CurrentCondition, False, bCurrentFile, tb, u
									'Dim As UString CurType, res1(Any), ElementValue
									'Split GetChangedCommas(Parameters), ",", res1()
									'For n As Integer = 0 To UBound(res1)
									'	If Trim(res1(n)) = "" Then Continue For
									'	res1(n) = Replace(res1(n), ";", ",")
									'	Pos1 = InStr(res1(n), "=")
									'	If Pos1 > 0 Then
									'		ElementValue = Trim(Mid(res1(n), Pos1 + 1))
									'	Else
									'		ElementValue = ""
									'	End If
									'	If Pos1 > 0 Then res1(n) = Trim(..Left(res1(n), Pos1 - 1))
									'	Pos1 = InStr(LCase(res1(n)), " as ")
									'	If Pos1 > 0 Then
									'		CurType = Trim(Mid(res1(n), Pos1 + 4))
									'		CurType = Replace(CurType, "`", "=")
									'		Pos2 = InStr(CurType, "*")  'David Change,  a As WString*2
									'		If Pos2 > 1 Then CurType = Trim(Mid(res1(n), Pos1 + Len("as") + 2, Pos2 - Pos1 - Len("as") - 1)) Else CurType = Trim(Mid(res1(n), Pos1 + Len("as") + 2))
									'		If Pos1 > 0 Then res1(n) = Trim(..Left(res1(n), Pos1 - 1))
									'	End If
									'	Var te = New_( TypeElement)
									'	If res1(n).ToLower.StartsWith("byref") Then
									'		res1(n) = Trim(Mid(res1(n), 6))
									'		te->ElementType = "ByRefParameter"
									'	ElseIf res1(n).ToLower.StartsWith("byval") Then
									'		res1(n) = Trim(Mid(res1(n), 6))
									'		te->ElementType = "ByValParameter"
									'	Else
									'		te->ElementType = "ByValParameter"
									'	End If
									'	Pos1 = InStr(res1(n), "(")
									'	If Pos1 > 0 Then
									'		res1(n) = Trim(..Left(res1(n), Pos1 - 1))
									'	End If
									'	res1(n) = res1(n).TrimAll
									'	If Not (CurType.ToLower.StartsWith("sub") OrElse CurType.ToLower.StartsWith("function")) Then
									'		Pos1 = InStrRev(CurType, ".")
									'		If Pos1 > 0 Then CurType = Mid(CurType, Pos1 + 1)
									'	End If
									'	te->Name = res1(n)
									'	te->DisplayName = res1(n)
									'	te->TypeIsPointer = CurType.ToLower.EndsWith(" pointer") OrElse CurType.ToLower.EndsWith(" ptr")
									'	'te->ElementType = IIf(StartsWith(LCase(te->TypeName), "sub("), "Event", "Property")
									'	te->TypeName = CurType
									'	te->TypeName = WithoutPointers(te->TypeName)
									'	te->Value = ElementValue
									'	te->Locals = 0
									'	te->StartLine = i
									'	te->EndLine = i
									'	te->Parameters = res1(n) & " As " & CurType
									'	te->FileName = sFileName
									'	te->Tag = tb
									'	func->Elements.Add te->Name, te
									'Next
								End If
							End If
						ElseIf ECStatement->ConstructionPart = 2 Then
							If func <> 0 Then
								func->EndLine = i: inFunc = False
								LastIndexFunctions = -1
								If Constructs.Count > 0 Then Constructs.Remove Constructs.Count - 1
								If Constructs.Count > 0 Then
									ECLine->InConstruction = Constructs.Item(Constructs.Count - 1)
									ECStatement->InConstruction = Constructs.Item(Constructs.Count - 1)
									func = ECStatement->InConstruction
									inFunc = True
								Else
									ECLine->InConstruction = 0
									ECStatement->InConstruction = 0
								End If
							End If
						ElseIf ECStatement->ConstructionPart = 1 AndAlso (ECStatement->ConstructionIndex = C_Type OrElse ECStatement->ConstructionIndex = C_Class) Then
							If StartsWith(bTrimLCase & " ", "public: ") Then
								inPubProPri = 0
							ElseIf StartsWith(bTrimLCase & " ", "protected: ") Then
								inPubProPri = 1
							ElseIf StartsWith(bTrimLCase & " ", "private: ") Then
								inPubProPri = 2
							End If
						End If
					ElseIf ECStatement->ConstructionIndex = C_Namespace Then
						If ECStatement->ConstructionPart = 0 Then
							Pos1 = InStr(11, bTrim, " ")
							Dim As String Names
							Dim As UString res1(Any)
							If Pos1 = 0 Then
								Names = Trim(Mid(bTrim, 11))
							Else
								Names = Trim(Mid(bTrim, 11, Pos1 - 11))
							End If
							Split(Names, ".", res1())
							nc = UBound(res1)
							For n As Integer = 0 To nc
								te = _New( TypeElement)
								te->Name = Trim(res1(n))
								te->DisplayName = te->Name
								te->InCondition = CurrentCondition
								te->ElementType = E_Namespace
								te->Parameters = bTrim
								Pos4 = InStr(te->Parameters, "'")
								If Pos4 > 0 Then
									te->Parameters = Trim(.Left(te->Parameters, Pos4 - 1))
								End If
								te->StartLine = i
								te->EndLine = i
								te->ControlType = nc
								If Comments <> "" Then te->Comment = Comments: Comments = ""
								te->FileName = sFileName
								te->Tag = tb
								SetLineAndCharParameters te, ECLines
								Content.Namespaces.Add te->Name, te
								Project->Globals.Namespaces.Add te->Name, te
								If Namespaces.Count > 0 Then
									Var Index = Content.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
									If Index > -1 Then Cast(TypeElement Ptr, Content.Namespaces.Object(Index))->Elements.Add te->Name, te
								End If
								Namespaces.Add te->Name, te
							Next
						ElseIf ECStatement->ConstructionPart = 2 Then
							If Namespaces.Count > 0 Then
								nc = Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->ControlType
								For ii As Integer = 0 To nc
									If Namespaces.Count > 0 Then Namespaces.Remove Namespaces.Count - 1
								Next ii
							End If
						End If
					'ElseIf StartsWith(bTrimLCase & " ", "public: ") Then
					'	inPubProPri = 0
					'ElseIf StartsWith(bTrimLCase & " ", "protected: ") Then
					'	inPubProPri = 1
					'ElseIf StartsWith(bTrimLCase & " ", "private: ") Then
					'	inPubProPri = 2
					ElseIf StartsWith(bTrimLCase & " ", "#define ") Then
						Dim As UString b2 = Trim(Mid(bTrim, 9))
						Pos1 = InStr(b2, " ")
						Pos2 = InStr(b2, "(")
						Pos3 = InStr(b2, ")")
						Pos5 = Pos2
						If Pos2 > 0 AndAlso (Pos2 < Pos1 OrElse Pos1 = 0) Then Pos1 = Pos2
						te = _New( TypeElement)
						If Pos1 = 0 Then
							te->Name = Trim(b2)
						Else
							te->Name = Trim(Left(b2, Pos1 - 1))
						End If
						te->DisplayName = te->Name
						te->InCondition = CurrentCondition
						te->ElementType = E_Define
						te->Parameters = bTrim
						Pos4 = InStr(te->Parameters, "'")
						If Pos4 > 0 Then
							te->Parameters = Trim(..Left(te->Parameters, Pos4 - 1))
						End If
						If Pos1 > 0 Then
							te->Value = Trim(Mid(b2, IIf(Pos3, Pos3, Pos1) + 1))
						End If
						te->StartLine = i
						te->EndLine = i
						If Comments <> "" Then te->Comment = Comments: Comments = ""
						te->FileName = sFileName
						te->Tag = tb
						SetLineAndCharParameters te, ECLines
						'Content.FunctionsOthers.Add te->DisplayName, te
						Content.Defines.Add te->Name, te
						If inFunc AndAlso CBool(func <> 0) Then
							If block AndAlso block->ConstructionIndex <> C_Enum AndAlso block->ConstructionIndex <> C_Type AndAlso block->ConstructionIndex <> C_Union AndAlso block->ConstructionIndex <> C_Class Then
								block->Elements.Add te->Name, te
							Else
								func->Elements.Add te->Name, te
							End If
						Else
							If block Then 
								block->Elements.Add te->Name, te
							Else
								Content.Procedures.Add te->Name, te
								Project->Globals.Functions.Add te->Name, te
								If Namespaces.Count > 0 Then
									Var Index = Content.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
									If Index > -1 Then Cast(TypeElement Ptr, Content.Namespaces.Object(Index))->Elements.Add te->Name, te
								End If
							End If
						End If
						Pos2 = InStr(b2, ")")
						If Pos2 > 0 AndAlso Pos5 > 0 Then
							SplitParameters b2, Pos5, Mid(b2, Pos5 + 1, Pos2 - Pos5 - 1), sFileName, te, i, ECLine, ECLines, CurrentCondition, False, bCurrentFile, tb
							'Var teDeclare = te
							'Dim As UString CurType, res1(Any), ElementValue
							'Split GetChangedCommas(Mid(bTrim, Pos5 + 1, Pos2 - Pos5 - 1)), ",", res1()
							'For n As Integer = 0 To UBound(res1)
							'	If Trim(res1(n)) = "" Then Continue For
							'	res1(n) = Trim(Replace(res1(n), ";", ","))
							'	Pos1 = InStr(res1(n), "=")
							'	If Pos1 > 0 Then
							'		ElementValue = Trim(Mid(res1(n), Pos1 + 1))
							'	Else
							'		ElementValue = ""
							'	End If
							'	If Pos1 > 0 Then res1(n) = Trim(..Left(res1(n), Pos1 - 1))
							'	Pos1 = InStr(LCase(res1(n)), " as ")
							'	If Pos1 > 0 Then
							'		CurType = Trim(Mid(res1(n), Pos1 + 4))
							'		CurType = Replace(CurType, "`", "=")
							'		res1(n) = Trim(..Left(res1(n), Pos1 - 1))
							'	End If
							'	Var te = New_(TypeElement)
							'	If res1(n).ToLower.StartsWith("byref") Then
							'		res1(n) = Trim(Mid(res1(n), 6))
							'		te->ElementType = "ByRefParameter"
							'	ElseIf res1(n).ToLower.StartsWith("byval") Then
							'		res1(n) = Trim(Mid(res1(n), 6))
							'		te->ElementType = "ByValParameter"
							'	Else
							'		te->ElementType = "ByValParameter"
							'	End If
							'	Pos1 = InStr(res1(n), "(")
							'	If Pos1 > 0 Then
							'		res1(n) = Trim(..Left(res1(n), Pos1 - 1))
							'	End If
							'	res1(n) = res1(n).TrimAll
							'	If Not (CurType.ToLower.StartsWith("sub") OrElse CurType.ToLower.StartsWith("function")) Then
							'		Pos1 = InStrRev(CurType, ".")
							'		If Pos1 > 0 Then CurType = Mid(CurType, Pos1 + 1)
							'	End If
							'	te->Name = res1(n)
							'	te->DisplayName = res1(n)
							'	te->TypeIsPointer = CurType.ToLower.EndsWith(" pointer") OrElse CurType.ToLower.EndsWith(" ptr")
							'	'te->ElementType = IIf(StartsWith(LCase(te->TypeName), "sub("), "Event", "Property")
							'	te->TypeName = WithoutPointers(CurType)
							'	te->Value = ElementValue
							'	te->Locals = 0
							'	te->StartLine = i
							'	te->EndLine = i
							'	te->Parameters = res1(n) & " As " & CurType
							'	te->FileName = sFileName
							'	te->Tag = tb
							'	teDeclare->Elements.Add te->Name, te
							'Next
						End If
					ElseIf inFunc AndAlso func <> 0 AndAlso func->ElementType = E_Enum Then
						If StartsWith(bTrim, "#") OrElse StartsWith(bTrim, "'") Then Continue For
						Dim As String t
						Dim As UString b2 = bTrim, res1(), ElementValue
						Dim As Integer uu
						Pos2 = InStr(b2, "'")
						If Pos2 > 0 Then u = u + Len(b2) - Len(LTrim(b2)): b2 = Trim(.Left(b2, Pos2 - 1))
						Split b2, ",", res1()
						uu = u
						For n As Integer = 0 To UBound(res1)
							u = uu
							uu += Len(res1(n)) + 1
							Pos3 = InStr(res1(n), "=")
							If Pos3 > 0 Then
								ElementValue = Trim(Mid(res1(n), Pos3 + 1))
							Else
								ElementValue = ""
							End If
							Var te = _New( TypeElement)
							u = u + Len(res1(n)) - Len(LTrim(res1(n)))
							If Pos3 > 0 Then
								t = Trim(.Left(res1(n), Pos3 - 1))
							Else
								t = Trim(res1(n))
							End If
							te->Name = t
							If func->Name <> "" Then
								te->DisplayName = func->Name & "." & te->Name
							Else
								te->DisplayName = te->Name
							End If
							te->InCondition = CurrentCondition
							te->ElementType = E_EnumItem
							te->Value = ElementValue
							te->StartLine = i
							te->EndLine = i
							te->StartChar = u
							te->EndChar = u + Len(te->Name)
							te->Parameters = Trim(res1(n))
							te->FileName = sFileName
							If func Then func->Elements.Add te->Name, te
							Content.Args.Add te->Name, te
							Project->Globals.Args.Add te->Name, te
						Next n
					ElseIf StartsWith(bTrimLCase, "declare ") Then
						iStart = 9
						Pos1 = InStr(9, bTrim, " ")
						Pos2 = InStrRev(bTrim, ")")
						Pos3 = InStr(9, bTrim, "(")
						Pos5 = Pos3
						'n = Len(Trim(*FLine)) - Len(Trim(Mid(Trim(*FLine), Pos1)))
						If StartsWith(Trim(Mid(bTrimLCase, 9)), "static ") OrElse StartsWith(Trim(Mid(bTrimLCase, 9)), "virtual ") OrElse StartsWith(Trim(Mid(bTrimLCase, 9)), "abstract ") Then
							iStart = Pos1
							Pos1 = InStr(Pos1 + 1, bTrim, " ")
						End If
						Pos4 = InStr(Pos1 + 1, bTrim, " ")
						If Pos4 > 0 AndAlso (Pos4 < Pos3 OrElse Pos3 = 0) Then Pos3 = Pos4
						Pos4 = InStr(bTrim, "(")
						If Pos4 > 0 AndAlso (Pos4 < Pos1 OrElse Pos1 = 0) Then Pos1 = Pos4
						te = _New( TypeElement)
						te->Declaration = True
						Select Case LCase(IIf(Pos1 = 0, Trim(Mid(bTrim, iStart)), Trim(Mid(bTrim, iStart, Pos1 - iStart))))
						Case "sub": te->ElementType = E_Sub
						Case "function": te->ElementType = E_Function
						Case "property": te->ElementType = E_Property
						Case "operator": te->ElementType = E_Operator
						Case "constructor": te->ElementType = E_Constructor
						Case "destructor": te->ElementType = E_Destructor
						End Select
						If inFunc Then
							te->Locals = inPubProPri
						End If
						te->InCondition = CurrentCondition
						If inFunc AndAlso func <> 0 AndAlso (te->ElementType = E_Constructor OrElse te->ElementType = E_Destructor) Then
							te->Name = func->Name
							te->DisplayName = func->Name & " [" & IIf(te->ElementType = E_Constructor, "Constructor", "Destructor") & "] [Declare]"
							te->TypeName = func->Name
							te->Parameters = te->Name & IIf(Pos4 > 0, Mid(bTrim, Pos4), "()")
						Else
							If Pos3 = 0 Then
								te->Name = Trim(Mid(bTrim, Pos1))
							Else
								te->Name = Trim(Mid(bTrim, Pos1, Pos3 - Pos1))
							End If
							If te->ElementType = E_Property Then
								If EndsWith(bTrim, ")") Then
									te->DisplayName = te->Name & " [Let] [Declare]"
								Else
									te->DisplayName = te->Name & " [Get] [Declare]"
								End If
							Else
								te->DisplayName = te->Name & " [Declare]"
							End If
							te->Parameters = Trim(Mid(bTrim, Pos1))
							If inFunc AndAlso func <> 0 Then te->DisplayName = func->Name & "." & te->DisplayName
							Pos2 = InStr(bTrim, ")")
							Pos3 = InStr(Pos2, bTrimLCase, ")as ")
							If Pos3 = 0 Then Pos3 = InStr(Pos2 + 1, bTrimLCase, " as ")
							If Pos3 = 0 Then
								te->TypeName = ""
							Else
								te->TypeName = Trim(Mid(bTrim, Pos3 + 4))
							End If
							Pos4 = InStr(te->TypeName, " ")
							If Pos4 < 1 Then Pos4 = InStr(te->TypeName, "'")
							If Pos4 > 0 Then
								te->TypeName = Trim(..Left(te->TypeName, Pos4 - 1))
							End If
							te->TypeName = WithoutPointers(te->TypeName)
						End If
						te->StartLine = i
						te->EndLine = i
						te->FileName = sFileName
						te->Tag = tb
						SetLineAndCharParameters te, ECLines
						'ECLine->InConstruction = te
						If Comments <> "" Then te->Comment = Comments: Comments = ""
						If inFunc AndAlso func <> 0 AndAlso te->ElementType <> E_Constructor AndAlso te->ElementType <> E_Destructor Then
							func->Elements.Add te->Name, te
						Else
							'Content.FunctionsOthers.Add te->DisplayName, te
							Content.Procedures.Add te->Name, te
							Project->Globals.Functions.Add te->Name, te
						End If
						If Pos2 > 0 AndAlso Pos5 > 0 Then
							SplitParameters bTrim, Pos5, Mid(bTrim, Pos5 + 1, Pos2 - Pos5 - 1), sFileName, te, i, ECLine, ECLines, CurrentCondition, True, bCurrentFile, tb
							'Var teDeclare = te
							'Dim As UString CurType, res1(Any), ElementValue
							'Split GetChangedCommas(Mid(bTrim, Pos5 + 1, Pos2 - Pos5 - 1)), ",", res1()
							'For n As Integer = 0 To UBound(res1)
							'	If Trim(res1(n)) = "" Then Continue For
							'	res1(n) = Trim(Replace(res1(n), ";", ","))
							'	Pos1 = InStr(res1(n), "=")
							'	If Pos1 > 0 Then
							'		ElementValue = Trim(Mid(res1(n), Pos1 + 1))
							'	Else
							'		ElementValue = ""
							'	End If
							'	If Pos1 > 0 Then res1(n) = Trim(..Left(res1(n), Pos1 - 1))
							'	Pos1 = InStr(LCase(res1(n)), " as ")
							'	If Pos1 > 0 Then
							'		CurType = Trim(Mid(res1(n), Pos1 + 4))
							'		CurType = Replace(CurType, "`", "=")
							'		res1(n) = Trim(..Left(res1(n), Pos1 - 1))
							'	End If
							'	Var te = New_( TypeElement)
							'	If res1(n).ToLower.StartsWith("byref") Then
							'		res1(n) = Trim(Mid(res1(n), 6))
							'		te->ElementType = "ByRefParameter"
							'	ElseIf res1(n).ToLower.StartsWith("byval") Then
							'		res1(n) = Trim(Mid(res1(n), 6))
							'		te->ElementType = "ByValParameter"
							'	Else
							'		te->ElementType = "ByValParameter"
							'	End If
							'	Pos1 = InStr(res1(n), "(")
							'	If Pos1 > 0 Then
							'		res1(n) = Trim(..Left(res1(n), Pos1 - 1))
							'	End If
							'	res1(n) = res1(n).TrimAll
							'	If Not (CurType.ToLower.StartsWith("sub") OrElse CurType.ToLower.StartsWith("function")) Then
							'		Pos1 = InStrRev(CurType, ".")
							'		If Pos1 > 0 Then CurType = Mid(CurType, Pos1 + 1)
							'	End If
							'	te->Name = res1(n)
							'	te->DisplayName = res1(n)
							'	te->TypeIsPointer = CurType.ToLower.EndsWith(" pointer") OrElse CurType.ToLower.EndsWith(" ptr")
							'	'te->ElementType = IIf(StartsWith(LCase(te->TypeName), "sub("), "Event", "Property")
							'	te->TypeName = WithoutPointers(CurType)
							'	te->Value = ElementValue
							'	te->Locals = 0
							'	te->StartLine = i
							'	te->EndLine = i
							'	te->Parameters = res1(n) & " As " & CurType
							'	te->FileName = sFileName
							'	te->Tag = tb
							'	teDeclare->Elements.Add te->Name, te
							'Next
						End If
					ElseIf EndsWith(Trim(b1), ":") AndAlso IsArg2(bTrim) AndAlso Not Content.Functions.Contains(bTrim) Then
						Var te = _New(TypeElement)
						te->Name = bTrim
						te->DisplayName = Trim(b1)
						te->InCondition = CurrentCondition
						te->ElementType = E_LineLabel
						te->TypeName = ""
						te->Locals = 0
						te->StartLine = i
						te->EndLine = i
						te->StartChar = u
						te->EndChar = u + Len(bTrim)
						te->Parameters = te->DisplayName
						te->FileName = sFileName
						te->Tag = tb
						SetLineAndCharParameters te, ECLines
						If inFunc AndAlso func <> 0 Then
							func->Elements.Add te->Name, te
						Else
							Content.LineLabels.Add te->Name, te
						End If
					Else
						If CInt(StartsWith(bTrimLCase, "as ")) OrElse _
							CInt(CInt(InStr(b0TrimLCase, " as ")) AndAlso CInt(InStr(b0TrimLCase, " as #") = 0)) OrElse _
							CInt(StartsWith(bTrimLCase, "const ")) OrElse _
							CInt(StartsWith(bTrimLCase, "common ")) OrElse _
							CInt(StartsWith(bTrimLCase, "var ")) Then
							Dim As UString b2 = b0Trim
							Dim As Integer uu, ct
							If b2.ToLower.StartsWith("dim ") OrElse b2.ToLower.StartsWith("redim ") OrElse b2.ToLower.StartsWith("static ") OrElse b2.ToLower.StartsWith("var ") OrElse b2.ToLower.StartsWith("const ") OrElse b2.ToLower.StartsWith("common ") OrElse b2.ToLower.StartsWith("for ") Then
								b2 = Trim(Mid(b0Trim, InStr(b0Trim, " ")))
								u += Len(b0Trim) - Len(b2)
							End If
							Dim As UString CurType, ElementValue
							Dim As UString res1(Any)
							Dim As Boolean bShared, bOldAs
							'Pos1 = InStr(b2, "'")
							'If Pos1 > 0 Then b2 = Trim(..Left(b2, Pos1 - 1))
							If b2.ToLower.StartsWith("shared ") Then bShared = True: u += Len(b2) - Len(Trim(Mid(b2, 7))): b2 = Trim(Mid(b2, 7))
							If b2.ToLower.StartsWith("import ") Then u += Len(b2) - Len(Trim(Mid(b2, 7))): b2 = Trim(Mid(b2, 7))
							If b2.ToLower.StartsWith("byref ") Then u += Len(b2) - Len(Trim(Mid(b2, 6))): b2 = Trim(Mid(b2, 6))
							If b2.ToLower.StartsWith("type ") Then u += Len(b2) - Len(Trim(Mid(b2, 5))): b2 = Trim(Mid(b2, 5))
							If b2.ToLower.StartsWith("as ") Then
								bOldAs = True
								CurType = Trim(Mid(b2, 4))
								u += Len(b2) - Len(CurType)
								Pos1 = InStr(CurType, " ")
								Pos2 = InStr(CurType, " Ptr ")
								Pos3 = InStr(CurType, " Pointer ")
								If StartsWith(CurType, "tbrkol") Then
									bOldAs = True
								End If
								If Pos2 > 0 Then
									Pos1 = Pos2 + 4
								ElseIf Pos3 > 0 Then
									Pos1 = Pos2 + 8
								End If
								If Pos1 > 0 Then
									u += Pos1
									Split GetChangedCommas(Mid(CurType, Pos1 + 1)), ",", res1()
									'							Pos2 = InStr(CurType, "*")   'David Change,  As WString *2 a,b,c,
									'							If Pos2 > 1 Then Pos1 = Pos2
									'							If Pos1 > 1 Then CurType = Trim(..Left(CurType, Pos1 - 1))
									If UBound(res1) > -1 Then
										CurType = ..Left(CurType, Pos1 + Len(res1(0)))
									End If
								End If
							Else
								Split GetChangedCommas(b2), ",", res1()
							End If
							uu = u
							For n As Integer = 0 To UBound(res1)
								u = uu
								uu += Len(res1(n)) + 1
								res1(n) = Replace(res1(n), ";", ",")
								Pos1 = InStr(res1(n), "=")
								If Pos1 > 0 Then
									'ct += Len(res1(n)) - Pos1 + 1
									ElementValue = Trim(Mid(res1(n), Pos1 + 1))
									If CBool(n = 0) AndAlso bOldAs Then
										CurType = Trim(..Left(CurType, Len(CurType) - Len(res1(n)) + Pos1 - 2))
										CurType = Replace(CurType, "`", "=")
									End If
								Else
									ElementValue = ""
								End If
								If Pos1 > 0 Then res1(n) = Trim(..Left(res1(n), Pos1 - 1))
								Pos1 = InStr(LCase(res1(n)), " as ")
								If Pos1 > 0 AndAlso Not bOldAs Then
									CurType = Trim(Mid(res1(n), Pos1 + Len("As") + 2))
									CurType = Replace(CurType, "`", "=")
									res1(n) = Trim(..Left(res1(n), Pos1 - 1))
								End If
								Pos1 = InStr(res1(n), ":")
								If Pos1 > 0 Then
									ct += Len(res1(n)) - Pos1 + 1
									res1(n) = Trim(..Left(res1(n), Pos1 - 1))
								End If
								If res1(n).ToLower.StartsWith("byref") OrElse res1(n).ToLower.StartsWith("byval") Then
									ct += Len(res1(n)) - Len(Trim(Mid(res1(n), 6)))
									u += Len(res1(n)) - Len(Trim(Mid(res1(n), 6)))
									res1(n) = Trim(Mid(res1(n), 6))
								End If
								Pos1 = InStr(res1(n), "(")
								If Pos1 > 0 Then
									ct += Len(res1(n)) - Pos1 + 1
									res1(n) = Trim(..Left(res1(n), Pos1 - 1))
								End If
								Pos1 = InStr(LCase(res1(n)), " alias ")
								If Pos1 > 0 Then
									ct += Len(res1(n)) - Pos1 + 1
									res1(n) = Trim(..Left(res1(n), Pos1 - 1))
								End If
								ct += Len(res1(n)) - Len(res1(n).TrimAll)
								res1(n) = res1(n).TrimAll
								Pos1 = InStrRev(res1(n), " ")
								If Pos1 > 0 Then
									u += Len(res1(n)) - Len(Trim(Mid(res1(n), Pos1 + 1)))
									res1(n) = Trim(Mid(res1(n), Pos1 + 1))
								End If
								If CBool(n = 0) AndAlso bOldAs Then
									CurType = Trim(..Left(CurType, Len(CurType) - Len(res1(n)) - ct))
								End If
								If Not (CurType.ToLower.StartsWith("sub") OrElse CurType.ToLower.StartsWith("function")) Then
									Pos1 = InStrRev(CurType, ".")
									If Pos1 > 0 Then CurType = Mid(CurType, Pos1 + 1)
								End If
								Var te = _New( TypeElement)
								te->Name = res1(n)
								te->InCondition = CurrentCondition
								te->StartChar = u
								te->EndChar = te->StartChar + Len(te->Name)
								te->DisplayName = res1(n)
								te->TypeIsPointer = CurType.ToLower.EndsWith(" pointer") OrElse CurType.ToLower.EndsWith(" ptr")
								te->TypeName = CurType
								te->TypeName = WithoutPointers(te->TypeName)
								If StartsWith(bTrimLCase, "type ") Then
									te->ElementType = E_TypeCopy
								ElseIf StartsWith(bTrimLCase, "common ") Then
									te->ElementType = E_CommonVariable
								ElseIf StartsWith(bTrimLCase, "const ") Then
									te->ElementType = E_Constant
								ElseIf bShared Then
									te->ElementType = E_SharedVariable
								Else
									te->ElementType = IIf(StartsWith(LCase(te->TypeName), "sub(") OrElse StartsWith(LCase(te->TypeName), "function("), E_Event, IIf(inFunc AndAlso func <> 0 AndAlso func->ElementType = E_Type, E_Field, E_LocalVariable))
								End If
								te->Value = ElementValue
								If inFunc Then
									te->Locals = inPubProPri
								Else
									te->Locals = 0 'IIf(bShared, 0, 2)
								End If
								te->StartLine = i
								te->EndLine = i
								te->Parameters = res1(n) & " As " & CurType
								te->FileName = sFileName
								te->Tag = tb
								SetLineAndCharParameters te, ECLines
								If inFunc AndAlso CBool(func <> 0) AndAlso Not bShared Then
									If block AndAlso block->ConstructionIndex <> C_Enum AndAlso block->ConstructionIndex <> C_Type AndAlso block->ConstructionIndex <> C_Union AndAlso block->ConstructionIndex <> C_Class Then
										block->Elements.Add te->Name, te
									Else
										func->Elements.Add te->Name, te
									End If
								ElseIf StartsWith(bTrimLCase, "type ") Then
									Content.Types.Add te->Name, te
								ElseIf bShared Then
									Content.Args.Add te->Name, te
									Project->Globals.Args.Add te->Name, te
								Else
									If block Then 
										block->Elements.Add te->Name, te
									Else
										Content.Args.Add te->Name, te
										Project->Globals.Args.Add te->Name, te
									End If
									If Namespaces.Count > 0 Then
										Var Index = Content.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
										If Index > -1 Then Cast(TypeElement Ptr, Content.Namespaces.Object(Index))->Elements.Add te->Name, te
									End If
								End If
								If te->ElementType = E_Event Then
									Dim As UString bTrim = CurType
									Pos2 = InStrRev(bTrim, ")")
									Pos5 = InStr(bTrim, "(")
									If Pos2 > 0 AndAlso Pos5 > 0 Then
										SplitParameters bTrim, Pos5, Mid(bTrim, Pos5 + 1, Pos2 - Pos5 - 1), sFileName, te, i, ECLine, ECLines, CurrentCondition, True, bCurrentFile, tb
										'Var teDeclare = te
										'Dim As UString CurType, res1(Any), ElementValue
										'Split GetChangedCommas(Mid(bTrim, Pos5 + 1, Pos2 - Pos5 - 1)), ",", res1()
										'For n As Integer = 0 To UBound(res1)
										'	If Trim(res1(n)) = "" Then Continue For
										'	res1(n) = Trim(Replace(res1(n), ";", ","))
										'	Pos1 = InStr(res1(n), "=")
										'	If Pos1 > 0 Then
										'		ElementValue = Trim(Mid(res1(n), Pos1 + 1))
										'	Else
										'		ElementValue = ""
										'	End If
										'	If Pos1 > 0 Then res1(n) = Trim(..Left(res1(n), Pos1 - 1))
										'	Pos1 = InStr(LCase(res1(n)), " as ")
										'	If Pos1 > 0 Then
										'		CurType = Trim(Mid(res1(n), Pos1 + 4))
										'		CurType = Replace(CurType, "`", "=")
										'		res1(n) = Trim(..Left(res1(n), Pos1 - 1))
										'	End If
										'	Var te = New_( TypeElement)
										'	If res1(n).ToLower.StartsWith("byref") Then
										'		res1(n) = Trim(Mid(res1(n), 6))
										'		te->ElementType = "ByRefParameter"
										'	ElseIf res1(n).ToLower.StartsWith("byval") Then
										'		res1(n) = Trim(Mid(res1(n), 6))
										'		te->ElementType = "ByValParameter"
										'	Else
										'		te->ElementType = "ByValParameter"
										'	End If
										'	Pos1 = InStr(res1(n), "(")
										'	If Pos1 > 0 Then
										'		res1(n) = Trim(..Left(res1(n), Pos1 - 1))
										'	End If
										'	res1(n) = res1(n).TrimAll
										'	If Not (CurType.ToLower.StartsWith("sub") OrElse CurType.ToLower.StartsWith("function")) Then
										'		Pos1 = InStrRev(CurType, ".")
										'		If Pos1 > 0 Then CurType = Mid(CurType, Pos1 + 1)
										'	End If
										'	te->Name = res1(n)
										'	te->DisplayName = res1(n)
										'	te->TypeIsPointer = CurType.ToLower.EndsWith(" pointer") OrElse CurType.ToLower.EndsWith(" ptr")
										'	'te->ElementType = IIf(StartsWith(LCase(te->TypeName), "sub("), "Event", "Property")
										'	te->TypeName = WithoutPointers(CurType)
										'	te->Value = ElementValue
										'	te->Locals = 0
										'	te->StartLine = i
										'	te->EndLine = i
										'	te->Parameters = res1(n) & " As " & CurType
										'	te->FileName = sFileName
										'	te->Tag = tb
										'	teDeclare->Elements.Add te->Name, te
										'Next
									End If
								End If
							Next
						End If
					End If
				End If
			Next jj
		Next
	Next
End Sub

Sub Suggestions
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	Dim As ProjectElement Ptr Project
	Dim As EditControlContent Ptr ecc
	Dim As TreeNode Ptr ProjectNode
	Dim As UString MainFile
	Dim As Object Ptr tbOrProject = tb
	MainFile = GetMainFile(, Project, ProjectNode)
	If (tb = 0) AndAlso (Project = 0) Then Exit Sub
	If Project Then
		tbOrProject = Project
		If Project->Contents.Count = 0 Then
			pstBar->Panels[0]->Caption = ML("Loading project contents ...")
			For i As Integer = 0 To Project->Files_.Count - 1
				If EndsWith(Project->Files_.Item(i), ".bas") OrElse EndsWith(Project->Files_.Item(i), ".frm") OrElse EndsWith(Project->Files_.Item(i), ".bi") OrElse EndsWith(Project->Files_.Item(i), ".inc") Then
					ecc = _New(EditControlContent)
					ecc->FileName = Project->Files_.Item(i)
					ecc->Globals = @Project->Globals
					ecc->Tag = Project
					Project->Contents.Add ecc
					LoadFunctions ecc->FileName, LoadParam.OnlyFilePathOverwriteWithContent, Globals.Types, Globals.Enums, Globals.Functions, Globals.TypeProcedures, Globals.Args, , , ecc
					ecc->ExternalIncludesLoaded = LoadFunctionsCount = 0
					'LoadFunctionsWithContent Project->Files_.Item(i), Project, *ecc
				End If
			Next
			RestoreStatusText
			If LoadFunctionsCount > 0 Then
				MsgBox ML("Project content loaded. IntelliSense is not fully loaded yet.")
				Exit Sub
			End If
		End If
		If LoadFunctionsCount = 0 Then
			For i As Integer = 0 To Project->Contents.Count - 1
				ecc = Project->Contents.Item(i)
				If Not ecc->ExternalIncludesLoaded Then
					GetIncludeFiles *ecc, Project
				End If
			Next
		End If
	End If
	If LoadFunctionsCount > 0 Then
		MsgBox ML("IntelliSense is not fully loaded yet!")
		Exit Sub
	End If
	tpSuggestions->SelectTab
	QuitThread Project, tb
	SetQuitThread Project, tb, False
	SetLastThread Project, tb, ThreadCreate(@AnalyzeTab, tbOrProject)
End Sub

Sub TabWindow.FormDesign(NotForms As Boolean = False)
	On Error Goto ErrorHandler
	If bNotDesign OrElse FormClosing Then Exit Sub
	pfrmMain->UpdateLock
	bNotDesign = True
	QuitThread Project, @This
	Dim CtrlName As String
	Dim SelControlName As String
	Dim CurrentMenuName As String
	Dim CurrentToolBarName As String
	Dim CurrentStatusBarName As String
	Dim CurrentImageListName As String
	Dim ActiveCtrlName As String
	Dim SelControlNames As WStringList
	Dim bSelControlFind As Boolean
	Dim As UString ResourceFile = GetResourceFile(True)
	txtCode.DropDownTypeElement = 0
	If CInt(NotForms = False) AndAlso CInt(Des) Then
		With *Des
			If Des->SymbolsReadProperty(pfImageListEditor->CurrentImageList) Then CurrentImageListName = WGet(Des->Symbols(pfImageListEditor->CurrentImageList)->ReadPropertyFunc(pfImageListEditor->CurrentImageList, "Name"))
			If Des->SymbolsReadProperty(pfMenuEditor->ActiveCtrl) Then ActiveCtrlName = WGet(Des->Symbols(pfMenuEditor->ActiveCtrl)->ReadPropertyFunc(pfMenuEditor->ActiveCtrl, "Name"))
			If Des->SymbolsReadProperty(pfMenuEditor->ActiveCtrl) Then CurrentMenuName = WGet(Des->Symbols(pfMenuEditor->CurrentMenu)->ReadPropertyFunc(pfMenuEditor->CurrentMenu, "Name"))
			If Des->SymbolsReadProperty(pfMenuEditor->CurrentToolBar) Then CurrentToolBarName = WGet(Des->Symbols(pfMenuEditor->CurrentToolBar)->ReadPropertyFunc(pfMenuEditor->CurrentToolBar, "Name"))
			If Des->SymbolsReadProperty(pfMenuEditor->CurrentStatusBar) Then CurrentStatusBarName = WGet(Des->Symbols(pfMenuEditor->CurrentStatusBar)->ReadPropertyFunc(pfMenuEditor->CurrentStatusBar, "Name"))
			If .SelectedControl <> 0 AndAlso Des->SymbolsReadProperty(.SelectedControl) Then SelControlName = WGet(Des->Symbols(.SelectedControl)->ReadPropertyFunc(.SelectedControl, "Name"))
			For j As Integer = 0 To .SelectedControls.Count - 1
				If Des->SymbolsReadProperty(.SelectedControls.Items[j]) Then SelControlNames.Add WGet(Des->Symbols(.SelectedControls.Items[j])->ReadPropertyFunc(.SelectedControls.Items[j], "Name"))
			Next
			'If .SelectedControl = .DesignControl Then bSelControlFind = True
			If .DesignControl Then
				.UnHook
				Dim As SymbolsType Ptr stDesignControl = Des->SymbolsReadProperty(.DesignControl)
				If stDesignControl AndAlso iGet(stDesignControl->ReadPropertyFunc(.DesignControl, "ControlCount")) > 0 Then
					For i As Integer = iGet(stDesignControl->ReadPropertyFunc(.DesignControl, "ControlCount")) - 1 To 0 Step -1
						If stDesignControl->RemoveControlSub AndAlso stDesignControl->ControlByIndexFunc Then stDesignControl->RemoveControlSub(.DesignControl, stDesignControl->ControlByIndexFunc(.DesignControl, i))
					Next i
				End If
				If stDesignControl AndAlso stDesignControl->WritePropertyFunc Then stDesignControl->WritePropertyFunc(Des->DesignControl, "Menu", 0)
				For i As Integer = 2 To cboClass.Items.Count - 1
					CurCtrl = 0
					CBItem = cboClass.Items.Item(i)
					If CBItem <> 0 Then CurCtrl = CBItem->Object
					If CurCtrl <> 0 Then
						Dim As SymbolsType Ptr st = Des->Symbols(CurCtrl)
						'Fixme Hange here with ctrl RichEdit
						If st AndAlso st->ReadPropertyFunc AndAlso WGet(st->ReadPropertyFunc(CurCtrl, "ClassName")) <> "RichTextBox" Then
							'If .ReadPropertyFunc(CurCtrl, "Tag") <> 0 Then Delete_(Cast(Dictionary Ptr, .ReadPropertyFunc(CurCtrl, "Tag")))
							If st->DeleteComponentFunc Then st->DeleteComponentFunc(CurCtrl)
						Else
							''Delete the last one not current one. But still one more remain exist
							If CurCtrlRichedit <> 0 Then
								Dim As SymbolsType Ptr st = Des->Symbols(CurCtrlRichedit)
								'If .ReadPropertyFunc(CurCtrlRichedit, "Tag") <> 0 Then Delete_(Cast(Dictionary Ptr, .ReadPropertyFunc(CurCtrlRichedit, "Tag")))
								If st AndAlso st->DeleteComponentFunc Then st->DeleteComponentFunc(CurCtrlRichedit)
							End If
							CurCtrlRichedit = CurCtrl
						End If
					End If
				Next i
				.Hook
			End If
			.SelectedControls.Clear
			.Objects.Clear
			.Controls.Clear
			Events.Clear
			If .DesignControl Then
				.Objects.Add .DesignControl
				Dim As Any Ptr st = .CtrlSymbols.Object(0)
				.CtrlSymbols.Clear
				.CtrlSymbols.Add .DesignControl, st
			Else
				.CtrlSymbols.Clear
			End If
		End With
	End If
	If CInt(NotForms = False) Then
		cboClass.Items.Clear
		cboClass.Items.Add "(" & ML("General") & ")" & Chr(0), , "DropDown", "DropDown"
		cboClass.ItemIndex = 0
	End If
	'LoadFunctionsWithContent FileName, Project, txtCode.Content
	Dim As TypeElement Ptr te, te1, func
	Dim As ConstructionBlock Ptr block, blockprev, ifblock, cb
	For i As Integer = txtCode.Content.Types.Count - 1 To 0 Step -1
		DeleteFromTypeElement(txtCode.Content.Types.Object(i))
		'te = txtCode.Content.Types.Object(i)
		'For j As Integer = te->Elements.Count - 1 To 0 Step -1
		'	te1 = te->Elements.Object(j)
		'	For k As Integer = te1->Elements.Count - 1 To 0 Step -1
		'		_Delete(Cast(TypeElement Ptr, te1->Elements.Object(k)))
		'	Next
		'	te1->Elements.Clear
		'	_Delete( Cast(TypeElement Ptr, te->Elements.Object(j)))
		'Next
		'te->Elements.Clear
		'_Delete( Cast(TypeElement Ptr, txtCode.Content.Types.Object(i)))
	Next
	For i As Integer = txtCode.Content.Enums.Count - 1 To 0 Step -1
		_Delete( Cast(TypeElement Ptr, txtCode.Content.Enums.Object(i)))
		txtCode.Content.Enums.Remove i
	Next
	For i As Integer = txtCode.Content.Namespaces.Count - 1 To 0 Step -1
		_Delete( Cast(TypeElement Ptr, txtCode.Content.Namespaces.Object(i)))
		txtCode.Content.Namespaces.Remove i
	Next
	For i As Integer = txtCode.Content.TypeProcedures.Count - 1 To 0 Step -1
		DeleteFromTypeElement(txtCode.Content.TypeProcedures.Object(i))
		txtCode.Content.TypeProcedures.Remove i
		'te = txtCode.Content.TypeProcedures.Object(i)
		'For j As Integer = te->Elements.Count - 1 To 0 Step -1
		'	te1 = te->Elements.Object(j)
		'	For k As Integer = te1->Elements.Count - 1 To 0 Step -1
		'		_Delete(Cast(TypeElement Ptr, te1->Elements.Object(k)))
		'	Next
		'	te1->Elements.Clear
		'	_Delete( Cast(TypeElement Ptr, te->Elements.Object(j)))
		'Next
		'te->Elements.Clear
		'_Delete( Cast(TypeElement Ptr, txtCode.Content.TypeProcedures.Object(i)))
	Next
	For i As Integer = txtCode.Content.Procedures.Count - 1 To 0 Step -1
		DeleteFromTypeElement(txtCode.Content.Procedures.Object(i))
		txtCode.Content.Procedures.Remove i
		'te = txtCode.Content.Procedures.Object(i)
		'For j As Integer = te->Elements.Count - 1 To 0 Step -1
		'	te1 = te->Elements.Object(j)
		'	For k As Integer = te1->Elements.Count - 1 To 0 Step -1
		'		_Delete(Cast(TypeElement Ptr, te1->Elements.Object(k)))
		'	Next
		'	te1->Elements.Clear
		'	_Delete( Cast(TypeElement Ptr, te->Elements.Object(j)))
		'Next
		'te->Elements.Clear
		'_Delete( Cast(TypeElement Ptr, txtCode.Content.Procedures.Object(i)))
	Next
	For i As Integer = txtCode.Content.ConstructionBlocks.Count - 1 To 0 Step -1
		cb = txtCode.Content.ConstructionBlocks.Item(i)
		For j As Integer = cb->Elements.Count - 1 To 0 Step -1
			DeleteFromTypeElement(cb->Elements.Object(j))
			'_Delete( Cast(TypeElement Ptr, cb->Elements.Object(j)))
		Next
		cb->Types.Clear
		cb->Enums.Clear
		cb->Elements.Clear
		_Delete(Cast(ConstructionBlock Ptr, txtCode.Content.ConstructionBlocks.Item(i)))
		txtCode.Content.ConstructionBlocks.Remove i
	Next
	For i As Integer = txtCode.Content.LineLabels.Count - 1 To 0 Step -1
		_Delete( Cast(TypeElement Ptr, txtCode.Content.LineLabels.Object(i)))
		txtCode.Content.LineLabels.Remove i
	Next
	For i As Integer = txtCode.Content.Args.Count - 1 To 0 Step -1
		DeleteFromTypeElement(txtCode.Content.Args.Object(i))
		txtCode.Content.Args.Remove i
		'te = txtCode.Content.Args.Object(i)
		'For j As Integer = te->Elements.Count - 1 To 0 Step -1
		'	_Delete(Cast(TypeElement Ptr, te->Elements.Object(j)))
		'Next
		'_Delete( Cast(TypeElement Ptr, txtCode.Content.Args.Object(i)))
	Next
	For i As Integer = AnyTexts.Count - 1 To 0 Step -1
		_Delete( Cast(WString Ptr, AnyTexts.Object(i)))
		AnyTexts.Remove i
	Next
	txtCode.Content.Types.Clear
	txtCode.Content.Defines.Clear
	txtCode.Content.Functions.Clear
	txtCode.Content.ConstructionBlocks.Clear
	txtCode.Content.Namespaces.Clear
	txtCode.Content.Enums.Clear
	txtCode.Content.TypeProcedures.Clear
	txtCode.Content.Procedures.Clear
	txtCode.Content.LineLabels.Clear
	txtCode.Content.Args.Clear
	AnyTexts.Clear
	''ThreadCreate_(@LoadFromTabWindow, @This)
	''LoadFunctions FileName, OnlyFilePath, Types, Procedures, Args, @txtCode
	t = False
	Var bT = False
	c = False
	txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	Dim As Integer iStart, iEnd, CtrlArrayNum, Pos1, Pos2, Pos3, Pos4, Pos5, l, n, nc, inPubProPri = 0, ConstructionIndex = -1, ConstructionPart, LastIndexFunctions
	Dim ptxtCode As EditControl Ptr = 0
	Dim As Boolean bFind, bTrue = True
	Dim As String CurrentCondition
	Dim As WStringList WithArgs, Namespaces, Includes
	Dim ConstructionBlocks As List
	Dim As UString Comments, b, b0, b1, b2, bTrim, bTrimLCase, b0Trim, b0TrimLCase
	Dim As Boolean IsBas = EndsWith(LCase(FileName), ".bas") OrElse EndsWith(LCase(FileName), ".frm"), inFunc
	Dim FileEncoding As FileEncodings, NewLineType As NewLineTypes
	Dim As Integer WithConstructionLine = -1, OldWithConstructionLine = -1
	Dim As List Constructs, ConstructBlocks, IfConstructBlocks
	Dim As WString Ptr FLine
	If IsBas Then
		WLet(FLine1, ..Left(FileName, Len(FileName) - 4) & ".bi")
		WLet(FLine2, GetFileName(*FLine1))
	Else
		WLet(FLine1, "")
		WLet(FLine2, "")
	End If
	Dim As UString sFileName = FileName
	Dim As TabWindow Ptr tb
	Dim As Integer OldIncludeLine = -1
	Dim As WStringList Ptr LastFileList
	Dim As IntegerList Ptr LastFileListLines
	Dim As Integer IncludesCount
	Dim As Boolean IncludesChanged
	If SyntaxHighlightingIdentifiers OrElse ChangeIdentifiersCase OrElse AutoSuggestions Then
		If txtCode.Content.ExternalIncludesLoaded Then
			For i As Integer = 0 To txtCode.LinesCount - 1
				b = txtCode.Lines(i)
				If StartsWith(LCase(Trim(b, Any !"\t ")), "#include ") Then
					Pos1 = InStr(b, """")
					If Pos1 > 0 Then
						Pos2 = InStr(Pos1 + 1, b, """")
						If Pos2 - Pos1 - 1 > 0 Then WLet(FPath, GetRelativePath(Mid(b, Pos1 + 1, Pos2 - Pos1 - 1), FileName)) Else *FPath = ""
						IncludesCount += 1
						If IncludesCount > txtCode.Content.OldIncludes.Count OrElse *FPath <> txtCode.Content.OldIncludes.Item(IncludesCount - 1) Then 'i <> OldIncludeLines.Item(IncludesCount - 1)
							IncludesChanged = True
							Exit For
						End If
					End If
				End If
			Next
			If IncludesCount <> txtCode.Content.OldIncludes.Count Then
				IncludesChanged = True
			End If
		Else
			Dim As TreeNode Ptr ProjectNode
			Dim As UString MainFile = GetMainFile(, Project, ProjectNode, True)
			If Project Then txtCode.Content.Globals = @Project->Globals
			txtCode.Content.CheckedFiles.Clear
			txtCode.Content.ExternalFiles.Clear
			txtCode.Content.ExternalFileLines.Clear
			txtCode.Content.ExternalIncludes.Clear
			txtCode.Content.ExternalFiles.Add sFileName
			txtCode.Content.ExternalFileLines.Add 0
			AddExternalIncludes txtCode.Content, 0, MainFile, sFileName
			txtCode.Content.ExternalIncludesLoaded = True
			IncludesChanged = True
		End If
		If IncludesChanged Then
			For i As Integer = txtCode.Content.FileLists.Count - 1 To 0 Step -1
				_Delete( Cast(WStringList Ptr, txtCode.Content.FileLists.Item(i)))
				txtCode.Content.FileLists.Remove i
			Next
			For i As Integer = txtCode.Content.FileListsLines.Count - 1 To 0 Step -1
				_Delete( Cast(IntegerList Ptr, txtCode.Content.FileListsLines.Item(i)))
				txtCode.Content.FileListsLines.Remove i
			Next
			txtCode.Content.FileLists.Clear
			txtCode.Content.FileListsLines.Clear
			txtCode.Content.Includes.Clear
			txtCode.Content.IncludeLines.Clear
			txtCode.Content.OldIncludes.Clear
			txtCode.Content.OldIncludeLines.Clear
		End If
	End If
	IncludesCount = 0
	OldECStatement = 0
	For j As Integer = 0 To txtCode.LinesCount - 1
		If (Not bFind) AndAlso (NotForms = False) AndAlso IsBas AndAlso StartsWith(LTrim(LCase(txtCode.Lines(j)), Any !"\t "), "#include once """ & LCase(*FLine2) & """") Then
			sFileName = *FLine1
			If IncludesChanged Then
				txtCode.Content.Includes.Add sFileName
				txtCode.Content.IncludeLines.Add j
				Includes.Add sFileName
			End If
			OldIncludeLine = j
			tb = GetTab(sFileName)
			If tb = 0 Then
				txtCodeBi.LoadFromFile *FLine1, FileEncoding, NewLineType
				ptxtCode = @txtCodeBi
			Else
				ptxtCode = @tb->txtCode
			End If
			bFind = True
			iStart = 0
			iEnd = ptxtCode->LinesCount - 1
		Else
			sFileName = FileName
			tb = @This
			ptxtCode = @txtCode
			iStart = j
			iEnd = j
		End If
		For i As Integer = iStart To iEnd
			ECLine = ptxtCode->Content.Lines.Items[i]
			If ptxtCode = @txtCode Then
				ECLine->Args.Clear
				ECLine->Ends.Clear
				ECLine->EndsCompleted = False
				If SyntaxHighlightingIdentifiers OrElse ChangeIdentifiersCase OrElse AutoSuggestions Then
					If OldIncludeLine = i - 1 Then
						Dim As WStringList Ptr FileList
						Dim As IntegerList Ptr FileListLines
						IncludesCount += 1
						If IncludesChanged Then
							FileList = _New(WStringList)
							FileListLines = _New(IntegerList)
							txtCode.Content.FileLists.Add FileList
							txtCode.Content.FileListsLines.Add FileListLines
							FileList->Sorted = True
							If LastFileList = 0 Then
								UpdateIncludedFilesList txtCode.Content, *FileList, *FileListLines, j
							Else
								For i As Integer = 0 To LastFileList->Count - 1
									FileList->Add LastFileList->Item(i)
									FileListLines->Add LastFileListLines->Item(i)
								Next
								For i As Integer = 0 To Includes.Count - 1
									AddAllIncludedFiles *FileList, *FileListLines, Includes.Item(i)
									txtCode.Content.OldIncludes.Add Includes.Item(i)
									txtCode.Content.OldIncludeLines.Add OldIncludeLine
								Next i
							End If
							Includes.Clear
						Else
							FileList = txtCode.Content.FileLists.Item(IncludesCount - 1)
							FileListLines = txtCode.Content.FileListsLines.Item(IncludesCount - 1)
						End If
						LastFileList = FileList
						LastFileListLines = FileListLines
						ECLine->FileList = LastFileList
						ECLine->FileListLines = LastFileListLines
					End If
				End If
				ECLine->FileList = LastFileList
				ECLine->FileListLines = LastFileListLines
				ECLine->InConstruction = 0
				ECLine->InConstructionBlock = 0
				ECLine->InCondition = CurrentCondition
				If inFunc Then ECLine->InConstruction = func
				If block Then ECLine->InConstructionBlock = block
			End If
			FLine = ECLine->Text
			b1 = Replace(*ECLine->Text, !"\t", " ")
			If StartsWith(Trim(b1), "'") Then
				Comments &= Mid(Trim(b1), 2) & Chr(13) & Chr(10)
				Continue For
			ElseIf Trim(b1) = "" Then
				Comments = ""
				Continue For
			End If
			'Dim As UString res(Any)
			'Split(b1, """", res())
			'b2 = ""
			'For j As Integer = 0 To UBound(res)
			'	If j = 0 Then
			'		b2 = res(0)
			'	ElseIf j Mod 2 = 0 Then
			'		b2 &= """" & res(j)
			'	Else
			'		b2 &= """" & WSpace(Len(res(j)))
			'	End If
			'Next
			'Pos1 = InStr(b2, "/'")
			'Pos2 = InStr(b2, "'")
			'If Pos1 = 0 OrElse (Pos2 <> 0 AndAlso Pos2 < Pos1) Then Pos1 = Pos2
			'If Pos1 > 0 Then
			'	b2 = ..Left(b2, Pos1 - 1)
			'End If
			'If inFunc AndAlso func <> 0 AndAlso (func->ElementType = "Type" OrElse func->ElementType = "Union") Then
			'	b2 = Replace(b2, ":", "%")
			'End If
			'Split(b2, ":", res())
			Dim As Integer k = 1, u
			'For jj As Integer = 0 To UBound(res)
			For jj As Integer = 0 To ECLine->Statements.Count - 1
				ECStatement = ECLine->Statements.Items[jj]
				If ptxtCode = @txtCode Then
					ECStatement->InConstruction = 0
					ECStatement->InConstructionBlock = 0
				End If
				If OldECStatement > 0 AndAlso EndsWith(Trim(*OldECStatement->Text), " _") Then 
					OldECStatement = ECStatement
					k = k + Len(*ECStatement->Text) + 1
					If i > 0 Then
						If ptxtCode = @txtCode Then
							ECLine2 = ptxtCode->Content.Lines.Items[i - 1]
							For iii As Integer = 0 To ECLine2->Args.Count - 1
								ECLine->Args.Add ECLine2->Args.Items[iii]
							Next
						End If
					End If
					Continue For
				Else
					OldECStatement = ECStatement
				End If
				b2 = *ECStatement->Text
				Dim As List ECLines
				ECLines.Add ECLine
				If EndsWith(RTrim(b2), " _") Then
					For iii As Integer = i To ptxtCode->Content.Lines.Count - 1
						ECLine2 = ptxtCode->Content.Lines.Items[iii]
						If iii > i Then
							b1 = IIf(EndsWith(RTrim(b1), " _"), ..Left(b1, Len(RTrim(b1)) - 1) & Space(Len(b1) - Len(RTrim(b1)) + 1), b1) & Replace(*ECLine2->Text, !"\t", " ")
							If ptxtCode = @txtCode Then
								ECLine2->Args.Clear
							End If
							ECLines.Add ECLine2
						End If
						For iiii As Integer = IIf(iii = i, jj + 1, 0) To ECLine2->Statements.Count - 1
							ecs = ECLine2->Statements.Items[iiii]
							b2 = ..Left(b2, Len(RTrim(b2)) - 1) & Space(Len(b2) - Len(RTrim(b2)) + 1) & *ecs->Text
							If Not EndsWith(Trim(*ecs->Text), " _") Then
								Exit For, For
							End If
						Next
					Next
				End If
				'l = Len(res(jj))
				l = Len(b2)
				b = Mid(b1, k, l)
				b0 = Mid(b2, k, l)
				bTrim = Trim(b, Any !"\t ")
				b0Trim = Trim(Mid(b2, k, l))
				bTrimLCase = LCase(bTrim)
				b0TrimLCase = LCase(Trim(b0, Any !"\t "))
				u = k
				'k = k + Len(res(jj)) + 1
				k = k + l + 1
				u = u + Len(b) - Len(LTrim(b, Any !"\t "))
				''			ECLine->InConstructionIndex = ConstructionIndex
				''			ECLine->InConstructionPart = ConstructionPart
				''			If ECLine->ConstructionIndex > 0 AndAlso ECLine->ConstructionIndex <> 1 AndAlso ECLine->ConstructionIndex <> 2 AndAlso ECLine->ConstructionIndex <> 3 Then
				''				If ECLine->ConstructionPart = 0 Then
				''					ConstructionIndex = ECLine->ConstructionIndex
				''					ConstructionBlocks.Add ECLine
				''				ElseIf ECLine->ConstructionPart = 1 Then
				''					ConstructionPart = ECLine->ConstructionPart
				''				ElseIf ECLine->ConstructionPart = 2 Then
				''					If ConstructionBlocks.Count > 0 Then
				''						ECLIne2 = ConstructionBlocks.Items[ConstructionBlocks.Count - 1]
				''						If ECLine2->ConstructionIndex <> ECLine->ConstructionIndex AndAlso ECLine2->ConstructionIndex <> 3 AndAlso ECLine2->ConstructionIndex <> 2 Then
				''							' Does not match construction blocks
				''						Else
				''							ConstructionBlocks.Remove ConstructionBlocks.Count - 1
				''							If ConstructionBlocks.Count > 0 Then
				''								ECLIne2 = ConstructionBlocks.Items[ConstructionBlocks.Count - 1]
				''								ConstructionIndex = ECLIne2->ConstructionIndex
				''								ConstructionPart = 0
				''							Else
				''								ConstructionIndex = -1
				''								ConstructionPart = 0
				''							End If
				''						End If
				''					Else
				''						' Do not found construction index
				''					End If
				''				End If
				''			End If
				If ptxtCode = @txtCode Then
					ECLine->InWithConstruction = WithConstructionLine
				End If
				If ECLine->ConstructionIndex = C_With Then
					If ECLine->ConstructionPart = 0 Then
						OldWithConstructionLine = WithConstructionLine
						WithConstructionLine = i
					Else
						WithConstructionLine = OldWithConstructionLine
					End If
				End If
				If StartsWith(bTrimLCase, "#include ") Then
					Pos1 = InStr(b, """")
					If Pos1 > 0 Then
						Pos2 = InStr(Pos1 + 1, b, """")
						If Pos2 - Pos1 - 1 > 0 Then
							WLet(FPath, GetRelativePath(Mid(b, Pos1 + 1, Pos2 - Pos1 - 1), FileName))
							If ptxtCode = @txtCode Then
								If IncludesChanged Then
									txtCode.Content.Includes.Add *FPath
									txtCode.Content.IncludeLines.Add j
									Includes.Add *FPath
								End If
								OldIncludeLine = j
							End If
							If Not pLoadPaths->Contains(*FPath) Then
								Var AddedIndex = pLoadPaths->Add(*FPath)
								ThreadCounter(ThreadCreate_(@LoadFunctionsSub, @pLoadPaths->Item(AddedIndex)))
							End If
						Else
							WLet(FPath, "")
						End If
					End If
				Else
					If (ECStatement->ConstructionIndex >= 0) AndAlso (ECStatement->ConstructionIndex <> C_P_Region) Then
						If ECStatement->ConstructionIndex = C_P_If Then
							If ECStatement->ConstructionPart < 2 Then
								If StartsWith(LCase(Trim(*ECStatement->Text)), "#if ") Then
									CurrentCondition = Trim(Mid(Trim(*ECStatement->Text), 5))
								ElseIf StartsWith(LCase(Trim(*ECStatement->Text)), "#ifdef") Then
									CurrentCondition = Trim(Mid(Trim(*ECStatement->Text), 7))
								ElseIf StartsWith(LCase(Trim(*ECStatement->Text)), "#ifndef") Then
									CurrentCondition = "Not " & Trim(Mid(Trim(*ECStatement->Text), 8))
								ElseIf StartsWith(LCase(Trim(*ECStatement->Text)), "#elseif") Then
									CurrentCondition = Trim(Mid(Trim(*ECStatement->Text), 8))
								ElseIf StartsWith(LCase(Trim(*ECStatement->Text)), "#else") Then
									CurrentCondition = "Not " & CurrentCondition
								End If
								'If ifblock Then CurrentCondition = ifblock  CurrentCondition
							End If
							If ECStatement->ConstructionPart > 0 Then
								If IfConstructBlocks.Count > 0 Then IfConstructBlocks.Remove IfConstructBlocks.Count - 1
								If IfConstructBlocks.Count > 0 Then
									ifblock = IfConstructBlocks.Item(IfConstructBlocks.Count - 1)
									If ECStatement->ConstructionPart = 2 Then CurrentCondition = ifblock->Condition
								Else
									ifblock = 0
									If ECStatement->ConstructionPart = 2 Then CurrentCondition = ""
								End If
								'If ECStatement->ConstructionPart <> 2 Then ECStatement->InConstructionBlock = ifblock: ECLine->InConstructionBlock = ifblock
							End If
							If ECStatement->ConstructionPart < 2 Then
								Var cb = _New(ConstructionBlock)
								cb->ConstructionIndex = ECStatement->ConstructionIndex
								cb->ConstructionPart = ECStatement->ConstructionPart
								cb->InConstructionBlock = ifblock
								cb->Condition = CurrentCondition
								IfConstructBlocks.Add cb
								txtCode.Content.ConstructionBlocks.Add cb
								ifblock = cb
							End If
						Else
							If ECStatement->ConstructionPart > 0 Then
								If ConstructBlocks.Count > 0 Then
									If block AndAlso block->InConstructionBlock AndAlso block->Condition = "Not " & block->InConstructionBlock->Condition Then
										If ptxtCode = @txtCode Then
											ECStatement->ConstructionPartCount += 1
										End If
										ConstructBlocks.Remove ConstructBlocks.Count - 1
										If ConstructBlocks.Count > 0 Then ConstructBlocks.Remove ConstructBlocks.Count - 1
									Else
										ConstructBlocks.Remove ConstructBlocks.Count - 1
									End If
								End If
								If ConstructBlocks.Count > 0 Then
									block = ConstructBlocks.Item(ConstructBlocks.Count - 1)
								Else
									block = 0
								End If
								If ECStatement->ConstructionPart <> 2 Then 
									If ptxtCode = @txtCode Then
										ECStatement->InConstructionBlock = block
										ECLine->InConstructionBlock = block
									End If
								End If
							End If
							If ECStatement->ConstructionPart < 2 Then
								Var cb = _New(ConstructionBlock)
								cb->ConstructionIndex = ECStatement->ConstructionIndex
								cb->ConstructionPart = ECStatement->ConstructionPart
								cb->InConstructionBlock = block
								cb->Condition = CurrentCondition
								ConstructBlocks.Add cb
								txtCode.Content.ConstructionBlocks.Add cb
								block = cb
								If ptxtCode = @txtCode Then
									ECLine->InConstructionBlock = block
									ECStatement->InConstructionBlock = block
								End If
							End If
						End If
					End If
					If ECStatement->ConstructionIndex >= 0 AndAlso Constructions(ECStatement->ConstructionIndex).Accessible Then
						If ECStatement->ConstructionPart = 0 Then
							Pos1 = 0
							Pos2 = 0
							l = 0
							inPubProPri = 0
							inFunc = True
							Pos1 = InStr(" " & bTrimLCase & IIf(ECStatement->ConstructionIndex = C_Enum OrElse ECStatement->ConstructionIndex = C_Type OrElse ECStatement->ConstructionIndex = C_Union, " ", ""), " " & LCase(Constructions(ECStatement->ConstructionIndex).Name0) & " ")
							If Pos1 > 0 Then
								l = Len(Trim(Constructions(ECStatement->ConstructionIndex).Name0)) + 1
								u = u + Len(bTrim) - Len(LTrim(Mid(bTrim, Pos1 + l)))
								bTrim = Trim(Mid(bTrim, Pos1 + l))
								bTrimLCase = Trim(Mid(bTrimLCase, Pos1 + l))
								l = 0
								Pos1 = 1
								Pos4 = Pos1 + l
								Pos2 = InStr(Pos1 + l, bTrim, "(")
								Pos5 = Pos2
								Pos3 = InStr(Pos1 + l, bTrim, " ")
								If Pos3 > 0 AndAlso (Pos2 = 0 OrElse Pos3 < Pos2) Then Pos2 = Pos3
								te = _New( TypeElement)
								If Pos2 > 0 Then
									te->Name = Trim(Mid(bTrim, Pos1 + l, Pos2 - Pos1 - l))
								Else
									te->Name = Trim(Mid(bTrim, Pos1 + l))
								End If
								te->InCondition = CurrentCondition
								te->StartChar = u
								te->EndChar = te->StartChar + Len(te->Name)
								Pos1 = InStr(te->Name, ".")
								Dim As Boolean TypeProcedure
								If Pos1 > 0 Then 
									te->DisplayName = Mid(te->Name, Pos1 + 1) & " [" & ..Left(te->Name, Pos1 - 1) & "]"
									te->OwnerTypeName = .Left(te->Name, Pos1 - 1)
									te->Name = Mid(te->Name, Pos1 + 1): TypeProcedure = True: te->StartChar = te->StartChar + Pos1 + l
								Else
									te->DisplayName = te->Name
								End If
								If ECStatement->ConstructionIndex = C_Property Then
									If EndsWith(bTrim, ")") Then
										te->DisplayName = te->DisplayName & " [Let]"
									Else
										te->DisplayName = te->DisplayName & " [Get]"
									End If
								ElseIf CInt(ECStatement->ConstructionIndex >= C_Enum AndAlso ECStatement->ConstructionIndex <= C_Union) OrElse CInt(ECStatement->ConstructionIndex >= C_Operator AndAlso ECStatement->ConstructionIndex <= C_Destructor) Then
									te->DisplayName = te->DisplayName & " [" & Trim(Constructions(ECStatement->ConstructionIndex).Name0) & "]"
								Else
									te->DisplayName = te->DisplayName
								End If
								'te->TypeProcedure = TypeProcedure
								Pos2 = InStr(bTrim, ")")
								If ECStatement->ConstructionIndex = C_Constructor OrElse ECStatement->ConstructionIndex = C_Destructor Then
									te->TypeName = te->Name
									te->OwnerTypeName = te->Name
									te->Parameters = te->Name & IIf(Pos5 > 0, Mid(bTrim, Pos5), "()")
								Else
									te->Parameters = Mid(bTrim, Pos4 + Pos1)
									Pos3 = InStr(Pos2, bTrimLCase, ")as ")
									If Pos3 = 0 Then Pos3 = InStr(Pos2 + 1, bTrimLCase, " as ")
									If Pos3 = 0 Then Pos3 = InStr(Pos2 + 1, bTrimLCase, " extends "): If Pos3 > 0 Then Pos3 += 5
									If Pos3 = 0 Then Pos3 = Len(b)
									te->TypeName = Trim(Mid(bTrim, Pos3 + 4))
									If te->Name = "Object" And te->TypeName = "Object" Then
										te->Name = "My.Sys.Object"
										te->TypeName = ""
									End If
									Pos4 = InStr(te->TypeName, "'")
									If Pos4 > 0 Then
										te->TypeName = Trim(..Left(te->TypeName, Pos4 - 1))
									End If
									te->TypeName = WithoutPointers(te->TypeName)
								End If
								Select Case ECStatement->ConstructionIndex
								Case C_P_Macro: te->ElementType = E_Macro
								Case C_Enum: te->ElementType = E_Enum
								Case C_Class, C_Type: te->ElementType = E_Type
								Case C_Union: te->ElementType = E_Union
								Case C_Sub: te->ElementType = E_Sub
								Case C_Function: te->ElementType = E_Function
								Case C_Property: te->ElementType = E_Property
								Case C_Operator: te->ElementType = E_Operator
								Case C_Constructor: te->ElementType = E_Constructor
								Case C_Destructor: te->ElementType = E_Destructor
								End Select
								te->StartLine = i
								te->EndLine = i + 1
								te->FileName = sFileName
								te->Tag = tb
								SetLineAndCharParameters te, ECLines
								If ptxtCode = @txtCode OrElse ptxtCode = @txtCodeBi Then
									ECStatement->InConstruction = te
									ECLine->InConstruction = te
								End If
								If block Then block->Construction = te
								If (te->Name = "") AndAlso Constructs.Count > 0 Then
									func = Constructs.Item(Constructs.Count - 1)
								Else
									func = te
								End If
								Constructs.Add te
								If Comments <> "" Then te->Comment = Comments: Comments = ""
								If ptxtCode = @txtCode Then LastIndexFunctions = txtCode.Content.Functions.Add(te->DisplayName, te)
								blockprev = 0
								If ConstructBlocks.Count > 1 Then
									blockprev = ConstructBlocks.Item(ConstructBlocks.Count - 2)
								End If
								If blockprev Then
									Select Case blockprev->ConstructionIndex
									Case C_Enum, C_Type, C_Union, C_Class
										If blockprev->Construction Then
											blockprev->Construction->Elements.Add te->Name, te
											If ECStatement->ConstructionIndex = C_Enum Then
												blockprev->Construction->Enums.Add te->Name, te
											ElseIf ECStatement->ConstructionIndex = C_Type OrElse ECStatement->ConstructionIndex = C_Class OrElse ECStatement->ConstructionIndex = C_Union Then
												blockprev->Construction->Types.Add te->Name, te
											End If
										End If
									Case Else
										blockprev->Elements.Add te->Name, te
										If ECStatement->ConstructionIndex = C_Enum Then
											blockprev->Enums.Add te->Name, te
										ElseIf ECStatement->ConstructionIndex = C_Type OrElse ECStatement->ConstructionIndex = C_Class OrElse ECStatement->ConstructionIndex = C_Union Then
											blockprev->Types.Add te->Name, te
										End If
									End Select
								Else
									If ECStatement->ConstructionIndex = C_Enum Then
										txtCode.Content.Enums.Add te->Name, te
									ElseIf ECStatement->ConstructionIndex = C_Type OrElse ECStatement->ConstructionIndex = C_Class OrElse ECStatement->ConstructionIndex = C_Union Then
										txtCode.Content.Types.Add te->Name, te
									ElseIf TypeProcedure Then
										txtCode.Content.TypeProcedures.Add te->Name, te
									Else
										txtCode.Content.Procedures.Add te->Name, te
										If ECStatement->ConstructionIndex = C_P_Macro Then txtCode.Content.Defines.Add te->Name, te
									End If
									If Not TypeProcedure Then
										If Namespaces.Count > 0 Then
											Var Index = txtCode.Content.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
											If Index > -1 Then Cast(TypeElement Ptr, txtCode.Content.Namespaces.Object(Index))->Elements.Add te->Name, te
										End If
									End If
								End If
								If Pos2 > 0 AndAlso Pos5 > 0 Then
									SplitParameters bTrim, Pos5, Mid(bTrim, Pos5 + 1, Pos2 - Pos5 - 1), sFileName, te, i, 0, ECLines, CurrentCondition, False, ptxtCode = @txtCode, tb, u
								End If
							End If
						ElseIf ECStatement->ConstructionPart = 2 Then
							If func <> 0 Then
								func->EndLine = i: inFunc = False
								LastIndexFunctions = -1
								If Constructs.Count > 0 Then Constructs.Remove Constructs.Count - 1
								If Constructs.Count > 0 Then
									func = Constructs.Item(Constructs.Count - 1)
									If ptxtCode = @txtCode Then
										ECLine->InConstruction = func
										ECStatement->InConstruction = func
									End If
									inFunc = True
								Else
									If ptxtCode = @txtCode Then
										ECLine->InConstruction = 0
										ECStatement->InConstruction = 0
									End If
								End If
							End If
						ElseIf ECStatement->ConstructionPart = 1 Then
							If (ECStatement->ConstructionIndex = C_Type OrElse ECStatement->ConstructionIndex = C_Class) Then
								If StartsWith(bTrimLCase & " ", "public: ") Then
									inPubProPri = 0
								ElseIf StartsWith(bTrimLCase & " ", "protected: ") Then
									inPubProPri = 1
								ElseIf StartsWith(bTrimLCase & " ", "private: ") Then
									inPubProPri = 2
								End If
							End If
						End If
					ElseIf ECStatement->ConstructionIndex = C_Namespace Then
						If ECStatement->ConstructionPart = 0 Then
							Pos1 = InStr(11, bTrim, " ")
							Dim As String Names
							Dim As UString res1(Any)
							If Pos1 = 0 Then
								Names = Trim(Mid(bTrim, 11))
							Else
								Names = Trim(Mid(bTrim, 11, Pos1 - 11))
							End If
							Split(Names, ".", res1())
							nc = UBound(res1)
							For n As Integer = 0 To nc
								te = _New( TypeElement)
								te->Name = Trim(res1(n))
								te->DisplayName = te->Name
								te->InCondition = CurrentCondition
								te->ElementType = E_Namespace
								te->Parameters = bTrim
								Pos4 = InStr(te->Parameters, "'")
								If Pos4 > 0 Then
									te->Parameters = Trim(.Left(te->Parameters, Pos4 - 1))
								End If
								te->StartLine = i
								te->EndLine = i
								te->ControlType = nc
								If Comments <> "" Then te->Comment = Comments: Comments = ""
								te->FileName = sFileName
								te->Tag = tb
								SetLineAndCharParameters te, ECLines
								txtCode.Content.Namespaces.Add te->Name, te
								If Namespaces.Count > 0 Then
									Var Index = txtCode.Content.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
									If Index > -1 Then Cast(TypeElement Ptr, txtCode.Content.Namespaces.Object(Index))->Elements.Add te->Name, te
								End If
								Namespaces.Add te->Name, te
							Next
						ElseIf ECStatement->ConstructionPart = 2 Then
							If Namespaces.Count > 0 Then
								nc = Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->ControlType
								For ii As Integer = 0 To nc
									If Namespaces.Count > 0 Then Namespaces.Remove Namespaces.Count - 1
								Next ii
							End If
						End If
					'ElseIf StartsWith(bTrimLCase & " ", "public: ") Then
					'	inPubProPri = 0
					'ElseIf StartsWith(bTrimLCase & " ", "protected: ") Then
					'	inPubProPri = 1
					'ElseIf StartsWith(bTrimLCase & " ", "private: ") Then
					'	inPubProPri = 2
					ElseIf StartsWith(bTrimLCase & " ", "#define ") Then
						Dim As UString b2 = Trim(Mid(bTrim, 9))
						Pos1 = InStr(b2, " ")
						Pos2 = InStr(b2, "(")
						Pos3 = InStr(b2, ")")
						Pos5 = Pos2
						If Pos2 > 0 AndAlso (Pos2 < Pos1 OrElse Pos1 = 0) Then Pos1 = Pos2
						te = _New( TypeElement)
						If Pos1 = 0 Then
							te->Name = Trim(b2)
						Else
							te->Name = Trim(..Left(b2, Pos1 - 1))
						End If
						te->DisplayName = te->Name
						te->InCondition = CurrentCondition
						te->ElementType = E_Define
						te->Parameters = bTrim
						Pos4 = InStr(te->Parameters, "'")
						If Pos4 > 0 Then
							te->Parameters = Trim(..Left(te->Parameters, Pos4 - 1))
						End If
						If Pos1 > 0 Then
							te->Value = Trim(Mid(b2, IIf(Pos3, Pos3, Pos1) + 1))
						End If
						te->StartLine = i
						te->EndLine = i
						If Comments <> "" Then te->Comment = Comments: Comments = ""
						te->FileName = sFileName
						te->Tag = tb
						SetLineAndCharParameters te, ECLines
						'txtCode.Content.FunctionsOthers.Add te->DisplayName, te
						txtCode.Content.Defines.Add te->Name, te
						If inFunc AndAlso CBool(func <> 0) Then
							If block AndAlso block->ConstructionIndex <> C_Enum AndAlso block->ConstructionIndex <> C_Type AndAlso block->ConstructionIndex <> C_Union AndAlso block->ConstructionIndex <> C_Class Then
								block->Elements.Add te->Name, te
							Else
								func->Elements.Add te->Name, te
							End If
						Else
							If block Then 
								block->Elements.Add te->Name, te
							Else
								txtCode.Content.Procedures.Add te->Name, te
								If Namespaces.Count > 0 Then
									Var Index = txtCode.Content.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
									If Index > -1 Then Cast(TypeElement Ptr, txtCode.Content.Namespaces.Object(Index))->Elements.Add te->Name, te
								End If
							End If
						End If
						Pos2 = InStr(b2, ")")
						If Pos2 > 0 AndAlso Pos5 > 0 Then
							SplitParameters b2, Pos5, Mid(b2, Pos5 + 1, Pos2 - Pos5 - 1), sFileName, te, i, ECLine, ECLines, CurrentCondition, False, ptxtCode = @txtCode, tb
						End If
					ElseIf inFunc AndAlso func <> 0 AndAlso func->ElementType = E_Enum Then
						If StartsWith(bTrim, "#") OrElse StartsWith(bTrim, "'") Then Continue For
						Dim As String t
						Dim As UString b2 = bTrim, res1(), ElementValue
						Dim As Integer uu
						Pos2 = InStr(b2, "'")
						If Pos2 > 0 Then u = u + Len(b2) - Len(LTrim(b2)): b2 = Trim(.Left(b2, Pos2 - 1))
						Split b2, ",", res1()
						uu = u
						For n As Integer = 0 To UBound(res1)
							u = uu
							uu += Len(res1(n)) + 1
							Pos3 = InStr(res1(n), "=")
							If Pos3 > 0 Then
								ElementValue = Trim(Mid(res1(n), Pos3 + 1))
							Else
								ElementValue = ""
							End If
							Var te = _New( TypeElement)
							u = u + Len(res1(n)) - Len(LTrim(res1(n)))
							If Pos3 > 0 Then
								t = Trim(.Left(res1(n), Pos3 - 1))
							Else
								t = Trim(res1(n))
							End If
							te->Name = t
							If func->Name <> "" Then
								te->DisplayName = func->Name & "." & te->Name
							Else
								te->DisplayName = te->Name
							End If
							te->InCondition = CurrentCondition
							te->ElementType = E_EnumItem
							te->Value = ElementValue
							te->StartLine = i
							te->EndLine = i
							te->StartChar = u
							te->EndChar = u + Len(te->Name)
							te->Parameters = Trim(res1(n))
							te->FileName = sFileName
							If func Then func->Elements.Add te->Name, te
							txtCode.Content.Args.Add te->Name, te
						Next n
					ElseIf StartsWith(bTrimLCase, "declare ") Then
						iStart = 9
						Pos1 = InStr(9, bTrim, " ")
						Pos2 = InStrRev(bTrim, ")")
						Pos3 = InStr(9, bTrim, "(")
						Pos5 = Pos3
						'n = Len(Trim(*FLine)) - Len(Trim(Mid(Trim(*FLine), Pos1)))
						If StartsWith(Trim(Mid(bTrimLCase, 9)), "static ") OrElse StartsWith(Trim(Mid(bTrimLCase, 9)), "virtual ") OrElse StartsWith(Trim(Mid(bTrimLCase, 9)), "abstract ") Then
							iStart = Pos1
							Pos1 = InStr(Pos1 + 1, bTrim, " ")
						End If
						Pos4 = InStr(Pos1 + 1, bTrim, " ")
						If Pos4 > 0 AndAlso (Pos4 < Pos3 OrElse Pos3 = 0) Then Pos3 = Pos4
						Pos4 = InStr(bTrim, "(")
						If Pos4 > 0 AndAlso (Pos4 < Pos1 OrElse Pos1 = 0) Then Pos1 = Pos4
						te = _New( TypeElement)
						te->Declaration = True
						Select Case LCase(IIf(Pos1 = 0, Trim(Mid(bTrim, iStart)), Trim(Mid(bTrim, iStart, Pos1 - iStart))))
						Case "sub": te->ElementType = E_Sub
						Case "function": te->ElementType = E_Function
						Case "property": te->ElementType = E_Property
						Case "operator": te->ElementType = E_Operator
						Case "constructor": te->ElementType = E_Constructor
						Case "destructor": te->ElementType = E_Destructor
						End Select
						If inFunc Then
							te->Locals = inPubProPri
						End If
						te->InCondition = CurrentCondition
						If inFunc AndAlso func <> 0 AndAlso (te->ElementType = E_Constructor OrElse te->ElementType = E_Destructor) Then
							te->Name = func->Name
							te->DisplayName = func->Name & " [" & IIf(te->ElementType = E_Constructor, "Constructor", "Destructor") & "] [Declare]"
							te->TypeName = func->Name
							te->Parameters = te->Name & IIf(Pos4 > 0, Mid(bTrim, Pos4), "()")
						Else
							If Pos3 = 0 Then
								te->Name = Trim(Mid(bTrim, Pos1))
							Else
								te->Name = Trim(Mid(bTrim, Pos1, Pos3 - Pos1))
							End If
							If te->ElementType = E_Property Then
								If EndsWith(bTrim, ")") Then
									te->DisplayName = te->Name & " [Let] [Declare]"
								Else
									te->DisplayName = te->Name & " [Get] [Declare]"
								End If
							Else
								te->DisplayName = te->Name & " [Declare]"
							End If
							te->Parameters = Trim(Mid(bTrim, Pos1))
							If inFunc AndAlso func <> 0 Then te->DisplayName = func->Name & "." & te->DisplayName
							Pos2 = InStr(bTrim, ")")
							Pos3 = InStr(Pos2, bTrimLCase, ")as ")
							If Pos3 = 0 Then Pos3 = InStr(Pos2 + 1, bTrimLCase, " as ")
							If Pos3 = 0 Then
								te->TypeName = ""
							Else
								te->TypeName = Trim(Mid(bTrim, Pos3 + 4))
							End If
							Pos4 = InStr(te->TypeName, " ")
							If Pos4 < 1 Then Pos4 = InStr(te->TypeName, "'")
							If Pos4 > 0 Then
								te->TypeName = Trim(..Left(te->TypeName, Pos4 - 1))
							End If
							te->TypeName = WithoutPointers(te->TypeName)
						End If
						te->StartLine = i
						te->EndLine = i
						te->FileName = sFileName
						te->Tag = tb
						SetLineAndCharParameters te, ECLines
						'ECLine->InConstruction = te
						If Comments <> "" Then te->Comment = Comments: Comments = ""
						If inFunc AndAlso func <> 0 AndAlso te->ElementType <> E_Constructor AndAlso te->ElementType <> E_Destructor Then
							func->Elements.Add te->Name, te
						Else
							'txtCode.Content.FunctionsOthers.Add te->DisplayName, te
							txtCode.Content.Procedures.Add te->Name, te
						End If
						If Pos2 > 0 AndAlso Pos5 > 0 Then
							SplitParameters bTrim, Pos5, Mid(bTrim, Pos5 + 1, Pos2 - Pos5 - 1), sFileName, te, i, ECLine, ECLines, CurrentCondition, True, ptxtCode = @txtCode, tb
						End If
					ElseIf EndsWith(Trim(b1), ":") AndAlso IsArg2(bTrim) AndAlso Not txtCode.Content.Functions.Contains(bTrim) Then
						Var te = _New(TypeElement)
						te->Name = bTrim
						te->DisplayName = Trim(b1)
						te->InCondition = CurrentCondition
						te->ElementType = E_LineLabel
						te->TypeName = ""
						te->Locals = 0
						te->StartLine = i
						te->EndLine = i
						te->StartChar = u
						te->EndChar = u + Len(bTrim)
						te->Parameters = te->DisplayName
						te->FileName = sFileName
						te->Tag = tb
						SetLineAndCharParameters te, ECLines
						If inFunc AndAlso func <> 0 Then
							func->Elements.Add te->Name, te
						Else
							txtCode.Content.LineLabels.Add te->Name, te
						End If
					Else
						If CInt(StartsWith(bTrimLCase, "as ")) OrElse _
							CInt(CInt(InStr(b0TrimLCase, " as ")) AndAlso CInt(InStr(b0TrimLCase, " as #") = 0)) OrElse _
							CInt(StartsWith(bTrimLCase, "const ")) OrElse _
							CInt(StartsWith(bTrimLCase, "common ")) OrElse _
							CInt(StartsWith(bTrimLCase, "var ")) Then
							Dim As UString b2 = b0Trim
							Dim As Integer uu, ct
							If b2.ToLower.StartsWith("dim ") OrElse b2.ToLower.StartsWith("redim ") OrElse b2.ToLower.StartsWith("static ") OrElse b2.ToLower.StartsWith("var ") OrElse b2.ToLower.StartsWith("const ") OrElse b2.ToLower.StartsWith("common ") OrElse b2.ToLower.StartsWith("for ") Then
								b2 = Trim(Mid(b0Trim, InStr(b0Trim, " ")))
								u += Len(b0Trim) - Len(b2)
							ElseIf InStr(b2.ToLower, "cast(sub(") > 0 Then
								Var Pos1 = InStr(b2.ToLower, "cast(sub(")
								Var Pos2 = InStr(b2.ToLower, "), @")
								'b2 = Trim(Mid(b0Trim, InStr(b0Trim, " ")))
							End If
							Dim As UString CurType, ElementValue
							Dim As UString res1(Any)
							Dim As Boolean bShared, bOldAs
							'Pos1 = InStr(b2, "'")
							'If Pos1 > 0 Then b2 = Trim(..Left(b2, Pos1 - 1))
							If b2.ToLower.StartsWith("shared ") Then bShared = True: u += Len(b2) - Len(Trim(Mid(b2, 7))): b2 = Trim(Mid(b2, 7))
							If b2.ToLower.StartsWith("import ") Then u += Len(b2) - Len(Trim(Mid(b2, 7))): b2 = Trim(Mid(b2, 7))
							If b2.ToLower.StartsWith("byref ") Then u += Len(b2) - Len(Trim(Mid(b2, 6))): b2 = Trim(Mid(b2, 6))
							If b2.ToLower.StartsWith("type ") Then u += Len(b2) - Len(Trim(Mid(b2, 5))): b2 = Trim(Mid(b2, 5))
							If b2.ToLower.StartsWith("as ") Then
								bOldAs = True
								CurType = Trim(Mid(b2, 4))
								u += Len(b2) - Len(CurType)
								Pos1 = InStr(CurType, " ")
								Pos2 = InStr(CurType, " Ptr ")
								Pos3 = InStr(CurType, " Pointer ")
								If Pos2 > 0 Then
									Pos1 = Pos2 + 4
								ElseIf Pos3 > 0 Then
									Pos1 = Pos2 + 8
								End If
								If Pos1 > 0 Then
									u += Pos1
									Split GetChangedCommas(Mid(CurType, Pos1 + 1)), ",", res1()
									'							Pos2 = InStr(CurType, "*")   'David Change,  As WString *2 a,b,c,
									'							If Pos2 > 1 Then Pos1 = Pos2
									'							If Pos1 > 1 Then CurType = Trim(..Left(CurType, Pos1 - 1))
									If UBound(res1) > -1 Then
										CurType = ..Left(CurType, Pos1 + Len(res1(0)))
									End If
								End If
							Else
								Split GetChangedCommas(b2), ",", res1()
							End If
							uu = u
							For n As Integer = 0 To UBound(res1)
								u = uu
								uu += Len(res1(n)) + 1
								res1(n) = Trim(Replace(res1(n), ";", ","))
								Pos1 = InStr(res1(n), "=")
								If Pos1 > 0 Then
									'ct += Len(res1(n)) - Pos1 + 1
									ElementValue = Trim(Mid(res1(n), Pos1 + 1))
									If CBool(n = 0) AndAlso bOldAs Then
										CurType = Trim(..Left(CurType, Len(CurType) - Len(res1(n)) + Pos1 - 2))
										CurType = Replace(CurType, "`", "=")
									End If
								Else
									ElementValue = ""
								End If
								If Pos1 > 0 Then res1(n) = Trim(..Left(res1(n), Pos1 - 1))
								Pos1 = InStr(LCase(res1(n)), " as ")
								If Pos1 > 0 AndAlso Not bOldAs Then
									CurType = Trim(Mid(res1(n), Pos1 + Len("As") + 2))
									CurType = Replace(CurType, "`", "=")
									res1(n) = Trim(..Left(res1(n), Pos1 - 1))
								End If
								Pos1 = InStr(res1(n), ":")
								If Pos1 > 0 Then
									ct += Len(res1(n)) - Pos1 + 1
									res1(n) = Trim(..Left(res1(n), Pos1 - 1))
								End If
								If res1(n).ToLower.StartsWith("byref") OrElse res1(n).ToLower.StartsWith("byval") Then
									ct += Len(res1(n)) - Len(Trim(Mid(res1(n), 6)))
									u += Len(res1(n)) - Len(Trim(Mid(res1(n), 6)))
									res1(n) = Trim(Mid(res1(n), 6))
								End If
								Pos1 = InStr(res1(n), "(")
								If Pos1 > 0 Then
									ct += Len(res1(n)) - Pos1 + 1
									res1(n) = Trim(..Left(res1(n), Pos1 - 1))
								End If
								Pos1 = InStr(LCase(res1(n)), " alias ")
								If Pos1 > 0 Then
									ct += Len(res1(n)) - Pos1 + 1
									res1(n) = Trim(..Left(res1(n), Pos1 - 1))
								End If
								ct += Len(res1(n)) - Len(res1(n).TrimAll)
								res1(n) = res1(n).TrimAll
								Pos1 = InStrRev(res1(n), " ")
								If Pos1 > 0 Then
									u += Len(res1(n)) - Len(LTrim(Mid(res1(n), Pos1 + 1)))
									res1(n) = Trim(Mid(res1(n), Pos1 + 1))
								End If
								If CBool(n = 0) AndAlso bOldAs Then
									CurType = Trim(..Left(CurType, Len(CurType) - Len(res1(n)) - ct))
								End If
								If Not (CurType.ToLower.StartsWith("sub") OrElse CurType.ToLower.StartsWith("function")) Then
									Pos1 = InStrRev(CurType, ".")
									'If Pos1 > 0 Then CurType = Mid(CurType, Pos1 + 1)
								End If
								Var te = _New( TypeElement)
								te->Name = res1(n)
								te->InCondition = CurrentCondition
								te->StartChar = u
								te->EndChar = te->StartChar + Len(te->Name)
								te->DisplayName = res1(n)
								te->TypeIsPointer = CurType.ToLower.EndsWith(" pointer") OrElse CurType.ToLower.EndsWith(" ptr")
								te->TypeName = CurType
								te->TypeName = WithoutPointers(te->TypeName)
								If StartsWith(bTrimLCase, "type ") Then
									te->ElementType = E_TypeCopy
								ElseIf StartsWith(bTrimLCase, "common ") Then
									te->ElementType = E_CommonVariable
								ElseIf StartsWith(bTrimLCase, "const ") Then
									te->ElementType = E_Constant
								ElseIf bShared Then
									te->ElementType = E_SharedVariable
								Else
									te->ElementType = IIf(StartsWith(LCase(te->TypeName), "sub(") OrElse StartsWith(LCase(te->TypeName), "sub ") OrElse StartsWith(LCase(te->TypeName), "function(") OrElse StartsWith(LCase(te->TypeName), "function "), E_Event, IIf(inFunc AndAlso func <> 0 AndAlso func->ElementType = E_Type, E_Field, E_LocalVariable))
								End If
								te->Value = ElementValue
								If inFunc Then
									te->Locals = inPubProPri
								Else
									te->Locals = 0 'IIf(bShared, 0, 2)
								End If
								te->StartLine = i
								te->EndLine = i
								te->Parameters = res1(n) & " As " & CurType
								te->FileName = sFileName
								te->Tag = tb
								SetLineAndCharParameters te, ECLines
								If inFunc AndAlso CBool(func <> 0) AndAlso Not bShared Then
									If block AndAlso block->ConstructionIndex <> C_Enum AndAlso block->ConstructionIndex <> C_Type AndAlso block->ConstructionIndex <> C_Union AndAlso block->ConstructionIndex <> C_Class Then
										block->Elements.Add te->Name, te
									Else
										func->Elements.Add te->Name, te
									End If
								ElseIf StartsWith(bTrimLCase, "type ") Then
									txtCode.Content.Types.Add te->Name, te
								ElseIf bShared Then
									txtCode.Content.Args.Add te->Name, te
								Else
									If block Then
										block->Elements.Add te->Name, te
									Else
										txtCode.Content.Args.Add te->Name, te
									End If
									If Namespaces.Count > 0 Then
										Var Index = txtCode.Content.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
										If Index > -1 Then Cast(TypeElement Ptr, txtCode.Content.Namespaces.Object(Index))->Elements.Add te->Name, te
									End If
								End If
								If te->ElementType = E_Event Then
									Dim As UString bTrim = CurType
									Pos2 = InStrRev(bTrim, ")")
									Pos5 = InStr(bTrim, "(")
									If Pos2 > 0 AndAlso Pos5 > 0 Then
										SplitParameters bTrim, Pos5, Mid(bTrim, Pos5 + 1, Pos2 - Pos5 - 1), sFileName, te, i, ECLine, ECLines, CurrentCondition, True, ptxtCode = @txtCode, tb
									End If
								ElseIf StartsWith(LCase(te->Value), "cast(sub(") Then
									te->ElementType = ElementTypes.E_ByRefParameter
									Dim As UString bTrim = te->Value
									Pos5 = 9
									Pos2 = InStr(Pos5 + 1, bTrim, ")")
									If Pos2 > 0 AndAlso Pos5 > 0 Then
										SplitParameters bTrim, Pos5, Mid(bTrim, Pos5 + 1, Pos2 - Pos5 - 1), sFileName, te, i, ECLine, ECLines, CurrentCondition, True, ptxtCode = @txtCode, tb
									End If
								End If
							Next
						End If
					End If
				End If
				If CInt(NotForms = False) AndAlso CInt(Not bT) AndAlso CInt((ECStatement->ConstructionIndex = C_Type OrElse ECStatement->ConstructionIndex = C_Class)) AndAlso _
					CInt(ECStatement->InConstruction > 0) AndAlso ((LCase(ECStatement->InConstruction->TypeName) = "form") OrElse (LCase(ECStatement->InConstruction->TypeName) = "usercontrol")) Then
					If Des = 0 Then
						This.Visible = True
						pnlForm.Visible = True
						splForm.Visible = True
						If Not tbrTop.Buttons.Item(3)->Checked Then tbrTop.Buttons.Item(3)->Checked = True
						#ifndef __USE_GTK__
							If pnlForm.Handle = 0 Then pnlForm.CreateWnd
						#endif
						Des = _New( My.Sys.Forms.Designer(@pnlForm))
						If Des = 0 Then FLine= 0: bNotDesign = False: pfrmMain->UpdateUnLock: Exit Sub
						Des->Tag = @This
						Des->OnInsertingControl = @DesignerInsertingControl
						Des->OnInsertControl = @DesignerInsertControl
						Des->OnInsertComponent = @DesignerInsertComponent
						Des->OnInsertObject = @DesignerInsertObject
						Des->OnChangeSelection = @DesignerChangeSelection
						Des->OnDeleteControl = @DesignerDeleteControl
						Des->OnDblClickControl = @DesignerDblClickControl
						Des->OnClickMenuItem = @DesignerClickMenuItem
						Des->OnClickProperties = @DesignerClickProperties
						Des->OnModified = @DesignerModified
						'Des->MFF = DyLibLoad(*MFFDll)
						Des->TopMenu = @pnlTopMenu
						#ifdef __USE_GTK3__
							Des->overlay = pnlForm.overlaywidget
							If Des->overlay Then
								g_signal_connect(Des->overlay, "get-child-position", G_CALLBACK(@Overlay_get_child_position), Des)
							End If
						#endif
						'Des->layout = pnlForm.layoutwidget
						'Des->ContextMenu = @mnuForm
						pnlTopMenu.Visible = False
					End If
					Pos1 = InStr(Trim(LCase(*FLine), Any !"\t "), " extends ")
					Pos5 = 6
					If ECStatement->ConstructionIndex = C_Class Then
						Pos5 = 7
					End If
					frmTypeName = Mid(Trim(*FLine, Any !"\t "), Pos5, Pos1 - Pos5)
					If EndsWith(LCase(frmTypeName), "type") Then
						frmName = ..Left(frmTypeName, Len(frmTypeName) - 4)
					Else
						frmName = frmTypeName
					End If
					If Des AndAlso Des->DesignControl = 0 Then
						With *Des
							If EndsWith(Trim(LCase(*FLine), Any !"\t "), " usercontrol") Then
								.DesignControl = .CreateControl("UserControl", frmName, frmName, 0, 0, 0, 350, 300, True)
							Else
								.DesignControl = .CreateControl("Form", frmName, frmName, 0, 0, 0, 350, 300, True)
							End If
							If .DesignControl = 0 Then  FLine = 0: bNotDesign = False: pfrmMain->UpdateUnLock: Exit Sub
							'MFF = DyLibLoad(*MFFDll)
							'.FLibs.Add *MFFDll, MFF
							'ReadPropertyFunc = DylibSymbol(MFF, "ReadProperty")
							'WritePropertyFunc = DylibSymbol(MFF, "WriteProperty")
							Dim As SymbolsType Ptr stDesignControl = Des->Symbols(.DesignControl)
							If stDesignControl AndAlso stDesignControl->WritePropertyFunc Then
								stDesignControl->WritePropertyFunc(.DesignControl, "IsChild", @bTrue)
								#ifdef __USE_GTK__
									stDesignControl->WritePropertyFunc(.DesignControl, "ParentWidget", pnlForm.widget)
								#else
									Dim As HWND pnlFormHandle = pnlForm.Handle
									stDesignControl->WritePropertyFunc(.DesignControl, "ParentHandle", @pnlFormHandle)
									'.ComponentSetBoundsSub(.DesignControl, 0, 0, 350, 300)
								#endif
								stDesignControl->WritePropertyFunc(.DesignControl, "DesignMode", @bTrue)
								stDesignControl->WritePropertyFunc(.DesignControl, "Visible", @bTrue)
								'.DesignControl->Parent = @pnlForm
							End If
							If stDesignControl AndAlso stDesignControl->ReadPropertyFunc Then
								#ifdef __USE_GTK__
									Dim As GtkWidget Ptr DCLayoutWidget = stDesignControl->ReadPropertyFunc(.DesignControl, "LayoutWidget")
									If DCLayoutWidget <> 0 Then
										.layoutwidget = DCLayoutWidget
										gtk_widget_set_can_focus(.layoutwidget, True)
									End If
									Dim As GtkWidget Ptr DCWidget = stDesignControl->ReadPropertyFunc(.DesignControl, "Widget")
									If DCWidget <> 0 Then
										'										Dim As GtkStyleContext Ptr context
										'										context = gtk_widget_get_style_context(DCWidget)
										'										gtk_style_context_add_class(context,"design_control")
										.Dialog = DCWidget
										'gtk_widget_set_can_focus(DCWidget, True)
									End If
								#else
									Dim As HWND Ptr DCHandle = stDesignControl->ReadPropertyFunc(.DesignControl, "Handle")
									If DCHandle <> 0 Then
										SetParent *DCHandle, pnlForm.Handle
										.Dialog = *DCHandle
									End If
								#endif
							End If
							RequestAlign
						End With
					End If
					cboClass.Items.Add(frmName, Des->DesignControl, "Form", "Form")
					bT = True
				ElseIf bT Then
					If Trim(LCase(*FLine), Any !"\t ") = "end type" OrElse Trim(LCase(*FLine), Any !"\t ") = "end class" OrElse Trim(LCase(*FLine), Any !"\t ") = "__startofclassbody__" Then
						t = True
					ElseIf Not t Then
						If StartsWith(Trim(LCase(*FLine), Any !"\t "), "dim as ") Then
							sText = Trim(Mid(Trim(*FLine, Any !"\t "), 8), Any !"\t ")
							If Trim(sText) = "" Then Continue For
							p = InStr(sText, " ")
							If p Then
								TypeName = Trim(..Left(sText, p), Any !"\t ")
								sText = Trim(Mid(Trim(sText, Any !"\t "), p))
								If StartsWith(LCase(sText), "ptr ") OrElse StartsWith(LCase(sText), "pointer ") Then
									Continue For
									p = InStr(sText, " ")
									If p Then sText = Trim(Mid(Trim(sText), p), " ")
								End If
								ArgName = ""
								p = InStr(sText, ",")
								Do While p > 0
									ArgName = Trim(..Left(sText, p - 1), Any !"\t ")
									If InStr(ArgName,"(") > 0 Then  ' It is Ctrl Array Then
										CtrlArrayNum = Val(StringExtract(ArgName,"(",")"))
										Dim As String tCtrlName = StringExtract(ArgName,"(")
										For i As Integer =0 To CtrlArrayNum
											ArgName=tCtrlName & "(" & Str(i) & ")"
											Ctrl = Des->CreateControl(TypeName, ArgName, ArgName, 0, 0, 0, 0, 0)
											If Ctrl = 0 Then
												Ctrl = Des->CreateComponent(TypeName, ArgName, 0, 0, 0)
											End If
											If Ctrl = 0 Then
												Ctrl = Des->CreateObject(TypeName)
											End If
											cboClass.Items.Add ArgName, Ctrl, TypeName, TypeName, , 1, FindControlIndex(ArgName)
										Next
									Else
										Ctrl = Des->CreateControl(TypeName, ArgName, ArgName, 0, 0, 0, 0, 0)
										If Ctrl = 0 Then
											Ctrl = Des->CreateComponent(TypeName, ArgName, 0, 0, 0)
										End If
										If Ctrl = 0 Then
											Ctrl = Des->CreateObject(TypeName)
										End If
										cboClass.Items.Add ArgName, Ctrl, TypeName, TypeName, , 1, FindControlIndex(ArgName)
									End If
									sText = Trim(Mid(sText, p + 1), Any !"\t ")
									p = InStr(sText, ",")
								Loop
								If InStr(sText,"(") > 0 Then  ' It is Ctrl Array
									CtrlArrayNum = Val(StringExtract(sText,"(",")"))
									Dim As String tCtrlName = StringExtract(sText,"(")
									For i As Integer =0 To CtrlArrayNum
										Ctrl = Des->CreateControl(TypeName, tCtrlName & "(" & Str(i) & ")", tCtrlName & "(" & Str(i) & ")", 0, 0, 0, 0, 0)
										If Ctrl = 0 Then
											Ctrl = Des->CreateComponent(TypeName, tCtrlName & "(" & Str(i) & ")", 0, 0, 0)
										End If
										If Ctrl = 0 Then
											Ctrl = Des->CreateObject(TypeName)
										End If
										cboClass.Items.Add tCtrlName & "(" & Str(i) & ")", Ctrl, TypeName, TypeName, , 1, FindControlIndex(tCtrlName & "(" & Str(i) & ")")
									Next
								Else
									Ctrl = Des->CreateControl(TypeName, sText, sText, 0, 0, 0, 0, 0)
									If Ctrl = 0 Then
										Ctrl = Des->CreateComponent(TypeName, sText, 0, 0, 0)
									End If
									If Ctrl = 0 Then
										Ctrl = Des->CreateObject(TypeName)
									End If
									cboClass.Items.Add sText, Ctrl, TypeName, TypeName, , 1, FindControlIndex(sText)
								End If
							End If
						End If
					ElseIf CInt(Not c) AndAlso CInt(StartsWith(LTrim(LCase(*FLine), Any !"\t ") & " ", "constructor " & LCase(frmTypeName) & " ")) Then
						ConstructorStart = j
						c = True
					ElseIf CInt(c) AndAlso Trim(LCase(*FLine), Any !"\t ") = "end constructor" Then
						ConstructorEnd = j
						c = False
						'Exit For
					ElseIf c Then
						ArgName = ""
						If StartsWith(LTrim(LCase(*FLine), Any !"\t "), "with ") Then
							WithArgs.Add Trim(Mid(LTrim(*FLine, Any !"\t "), 5), Any !"\t ")
						ElseIf StartsWith(LTrim(LCase(*FLine), Any !"\t "), "end with") Then
							If WithArgs.Count > 0 Then WithArgs.Remove WithArgs.Count - 1
						Else
							p = InStr(*FLine, ".")
							p1 = InStr(*FLine, "=")
							'If p > p1 Then p = 0
							If p > 0 Then
								ArgName = Trim(..Left(*FLine, p - 1), Any !"\t ")
								If ArgName = "" AndAlso WithArgs.Count > 0 Then ArgName = WithArgs.Item(WithArgs.Count - 1)
								If LCase(ArgName) = "this" Then ArgName = frmName
							ElseIf p1 AndAlso (InStr(*FLine, "->") = 0) Then
								ArgName = frmName
							End If
							Ctrl = 0
							If cboClass.Items.Contains(ArgName) Then
								CBItem = cboClass.Items.Item(cboClass.Items.IndexOf(ArgName))
								If CBItem <> 0 Then Ctrl = Cast(Any Ptr, CBItem->Object)
							End If
							If Ctrl Then
								Dim As SymbolsType Ptr st = Des->Symbols(Ctrl)
								If p1 Then
									PropertyName = Trim(Mid(*FLine, p + 1, p1 - p - 1), Any !"\t ")
									FLin = Mid(b, p1 + 1)
									FLin = Trim(FLin, Any !"\t ")
									If Len(FLin) <> 0 Then
										WLet(FLine2, Trim(Mid(b, p1 + 1), Any !"\t "))
										'If StartsWith(*FLine2, "@") Then WLet(FLine3, Trim(Mid(*FLine2, 2), Any !"\t ")): WLet(FLine2, *FLine3)
										Dim As Boolean Result
										Result = WriteObjProperty(Ctrl, PropertyName, *FLine2, True)
										If Result Then
											If st AndAlso st->ReadPropertyFunc Then
												#ifdef __USE_GTK__
													If LCase(PropertyName) = "parent" AndAlso st->ReadPropertyFunc(Ctrl, "Widget") Then
														Des->HookControl(st->ReadPropertyFunc(Ctrl, "Widget"))
												#else
													Dim hwnd1 As HWND Ptr = st->ReadPropertyFunc(Ctrl, "Handle")
													If LCase(PropertyName) = "parent" AndAlso hwnd1 AndAlso *hwnd1 Then
														Des->HookControl(*hwnd1)
												#endif
													If SelControlNames.Contains(QWString(st->ReadPropertyFunc(Ctrl, "Name"))) Then
														Des->SelectedControls.Add Ctrl
													End If
													CtrlName = QWString(st->ReadPropertyFunc(Ctrl, "Name"))
													If SelControlName = CtrlName Then
														Des->SelectedControl = Ctrl
														Des->MoveDots Des->SelectedControl, False
														bSelControlFind = True
													End If
													If CurrentImageListName = CtrlName Then pfImageManager->CurrentImageList = Ctrl
													If ActiveCtrlName = CtrlName Then pfMenuEditor->ActiveCtrl = Ctrl
													If CurrentMenuName = CtrlName Then pfMenuEditor->CurrentMenu = Ctrl
													If CurrentToolBarName = CtrlName Then pfMenuEditor->CurrentToolBar = Ctrl
													If CurrentStatusBarName = CtrlName Then pfMenuEditor->CurrentStatusBar = Ctrl
												End If
												#ifdef __USE_GTK__
													gtk_widget_show(st->ReadPropertyFunc(Ctrl, "Widget"))
												#endif
											End If
										End If
									End If
								ElseIf LCase(Mid(*FLine, p + 1, 10)) = "setbounds " Then
									lLeft = 0: lTop = 0: lWidth = 0: lHeight = 0
									sText = Mid(*FLine, p + 10)
									p1 = InStr(sText, ",")
									If p1 > 0 Then
										lLeft = Val(..Left(sText, p1 - 1))
										sText = Mid(sText, p1 + 1)
										p1 = InStr(sText, ",")
										If p1 > 0 Then
											lTop = Val(..Left(sText, p1 - 1))
											sText = Mid(sText, p1 + 1)
											p1 = InStr(sText, ",")
											If p1 > 0 Then
												lWidth = Val(..Left(sText, p1 - 1))
												lHeight = Val(Mid(sText, p1 + 1))
											End If
										End If
									End If
									Des->MoveControl(Ctrl, lLeft, lTop, lWidth, lHeight)
								ElseIf (LCase(Mid(*FLine, p + 1, 4)) = "add " OrElse LCase(Mid(*FLine, p + 1, 12)) = "addfromfile ") AndAlso st AndAlso st->ReadPropertyFunc AndAlso WGet(st->ReadPropertyFunc(Ctrl, "ClassName")) = "ImageList" Then
									p1 = InStr(p + 1, *FLine, " ")
									sRight = ""
									sText = Mid(*FLine, p1 + 1)
									p1 = InStr(sText, ",")
									If p1 > 0 Then
										sRight = Trim(Mid(sText, p1 + 1))
										sText = Trim(..Left(sText, p1 - 1))
									End If
									If StartsWith(sRight, """") Then sRight = Mid(sRight, 2)
									If EndsWith(sRight, """") Then sRight = ..Left(sRight, Len(sRight) - 1)
									If StartsWith(sText, """") Then sText = Mid(sText, 2)
									If EndsWith(sText, """") Then sText = ..Left(sText, Len(sText) - 1)
									If st->ImageListAddFromFileSub Then
										If LCase(Mid(*FLine, p + 1, 4)) = "add " Then
											st->ImageListAddFromFileSub(Ctrl, GetResNamePath(sText, ResourceFile), sRight)
										Else
											st->ImageListAddFromFileSub(Ctrl, GetRelativePath(sText, ResourceFile), sRight)
										End If
									End If
								End If
							End If
						End If
					End If
				End If
			Next
		Next
	Next
	If Des <> 0 Then Des->CheckTopMenuVisible False, True
	If CInt(NotForms = False) AndAlso CInt(Des) AndAlso CInt(Des->DesignControl) Then
		If Not bSelControlFind Then
			Des->SelectedControl = Des->DesignControl
			#ifdef __USE_GTK__
				Dim As GtkWidget Ptr Widget
				If Des->SymbolsReadProperty(Des->SelectedControl) Then Widget = Des->Symbols(Des->SelectedControl)->ReadPropertyFunc(Des->SelectedControl, "Widget")
				If Widget <> 0 Then gtk_widget_show_all(Widget)
			#else
				Dim As HWND Ptr DesCtrlHandle
				If Des->SymbolsReadProperty(Des->SelectedControl) Then DesCtrlHandle = Des->Symbols(Des->SelectedControl)->ReadPropertyFunc(Des->DesignControl, "Handle")
				Des->MoveDots Des->DesignControl, False
			#endif
			If Des->SelectedControls.Count > 1 Then Des->MoveDots Des->SelectedControl, False
		End If
		Dim PropertyName As String
		For i As Integer = 0 To plvProperties->Nodes.Count - 1
			PropertyName = GetItemText(plvProperties->Nodes.Item(i))
			Dim TempWS As UString
			TempWS = ReadObjProperty(Des->SelectedControl, PropertyName)
			If LCase(TempWS) <> LCase(plvProperties->Nodes.Item(i)->Text(1)) Then
				plvProperties->Nodes.Item(i)->Text(1) = TempWS
				If plvProperties->SelectedItem = plvProperties->Nodes.Item(i) AndAlso pnlPropertyValue.Visible Then
					If cboPropertyValue.Visible Then
						cboPropertyValue.ItemIndex = cboPropertyValue.IndexOf(" " & TempWS)
					Else
						txtPropertyValue.Text = TempWS
					End If
				End If
			End If
		Next i
		For i As Integer = 0 To plvEvents->Nodes.Count - 1
			PropertyName = GetItemText(plvEvents->Nodes.Item(i))
			Dim TempWS As UString
			TempWS = ReadObjProperty(Des->SelectedControl, PropertyName)
			If LCase(TempWS) <> LCase(plvEvents->Nodes.Item(i)->Text(1)) Then
				plvEvents->Nodes.Item(i)->Text(1) = TempWS
			End If
		Next i
		'FillAllProperties
	End If
	'Functions.Sort 'Already sorted while add items
	If cboClass.ItemIndex = 0 Then
		Dim As TypeElement Ptr te2
		Dim t As Boolean
		For i As Integer = cboFunction.Items.Count - 1 To 1 Step -1
			t = False
			For j As Integer = txtCode.Content.Functions.Count - 1 To 0 Step -1
				te2 = txtCode.Content.Functions.Object(j)
				If te2 = 0 Then Continue For
				'If te2->Tag = @This Then
				If CInt(Not te2->Find) AndAlso CInt(te2->DisplayName = cboFunction.Items.Item(i)->Text) Then 'CInt(Not te1->Find) AndAlso
					te2->Find = True
					cboFunction.Items.Item(i)->Object = te2
					t = True
					Exit For
				End If
				'End If
			Next j
			If Not t Then
				cboFunction.Items.Remove i
			End If
		Next i
		For j As Integer = 0 To txtCode.Content.Functions.Count - 1
			te2 = txtCode.Content.Functions.Object(j)
			'If te2->Tag = @This Then
			If Not te2->Find Then
				Dim As String imgKey = "Sub"
				If te2->ElementType = E_Property Then
					imgKey = "Property"
				ElseIf te2->ElementType = E_Function Then
					imgKey = "Function"
				End If
				t = False
				For i As Integer = 1 To cboFunction.Items.Count - 1
					If LCase(cboFunction.Items.Item(i)->Text) > LCase(te2->DisplayName) Then
						If Not (CBool(InStr(te2->DisplayName, "._") > 0) AndAlso CreateStaticEventHandlersWithAnUnderscoreAtTheBeginning) Then cboFunction.Items.Add te2->DisplayName, te2, imgKey, imgKey, , , i
						t = True
						Exit For
					End If
				Next i
				If Not t AndAlso Not (CBool(InStr(te2->DisplayName, "._") > 0) AndAlso CreateStaticEventHandlersWithAnUnderscoreAtTheBeginning) Then cboFunction.Items.Add te2->DisplayName, te2, imgKey, imgKey
			End If
			'End If
		Next
		'cboClass_Change cboClass
		'OnLineChangeEdit txtCode, iSelEndLine
	End If
	WithArgs.Clear
	ConstructionBlocks.Clear
	SelControlNames.Clear
	bNotDesign = False
	pfrmMain->UpdateUnLock
	SetQuitThread Project, @This, False
	If AutoSuggestions AndAlso LoadFunctionsCount = 0 Then
		If (Project = 0) OrElse ProjectAutoSuggestions Then
			If IsNew Then
				SetLastThread Project, @This, ThreadCreate(@AnalyzeTab, @This)
			End If
		End If
	End If
	FLine= 0
	Exit Sub
	ErrorHandler:
	FLine= 0
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " " & _
	"in function " & ZGet(Erfn()) & " " & _
	"in module " & ZGet(Ermn())
End Sub

Sub tbrTop_ButtonClick(ByRef Designer As My.Sys.Object, ByRef Sender As ToolBar, ByRef Button As ToolButton)
	Var tb = Cast(TabWindow Ptr, Cast(ToolButton Ptr, @Button)->Ctrl->Parent->Parent->Parent)
	If tb = 0 Then Exit Sub
	With *tb
		Select Case Button.Name
		Case "Code"
			.pnlCode.Visible = True
			.pnlForm.Visible = False
			.splForm.Visible = False
			'tpProject->SelectTab
		Case "Form"
			'If tb->cboClass.Items.Count < 2 Then Exit Sub
			.pnlCode.Visible = False
			.pnlForm.Align = DockStyle.alClient
			.pnlForm.Visible = True
			.splForm.Visible = False
			If (.bNotDesign = False) AndAlso tb->FormNeedDesign Then .FormDesign: tb->FormNeedDesign = False
			tpToolbox->SelectTab
		Case "CodeAndForm"
			'If tb->cboClass.Items.Count < 2 Then Exit Sub
			.pnlForm.Align = DockStyle.alRight
			.pnlForm.Width = 350
			.pnlForm.Visible = True
			.splForm.Visible = True
			.pnlCode.Visible = True
			If (.bNotDesign = False) AndAlso tb->FormNeedDesign Then .FormDesign: tb->FormNeedDesign = False
			tpToolbox->SelectTab
		End Select
		.RequestAlign
	End With
End Sub

Sub cboIntellisense_DropDown(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit)
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	tb->txtCode.DropDownShowed = True
End Sub

Dim Shared As Long CurrentTimerCloseUp

'#ifndef __USE_GTK__
'	Sub TimerProcCloseUp(HWND As HWND, uMsg As UINT, idEvent As UINT_PTR, dwTime As DWORD)
'		Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
'		If tb = 0 Then Exit Sub
'		tb->txtCode.CloseDropDownToolTip
'		KillTimer 0, CurrentTimerCloseUp
'	End Sub
'#endif

Sub cboIntellisense_CloseUp(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit)
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	tb->txtCode.DropDownShowed = False
	tb->txtCode.CloseDropDownToolTip
	'CurrentTimerCloseUp = SetTimer(0, 0, 1000, @TimerProcCloseUp)
End Sub

Sub TabWindow_Destroy(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	pApp->DoEvents
End Sub

Sub TabWindow_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	If tb->pnlForm.Visible AndAlso tb->pnlForm.Align = 2 AndAlso tb->pnlForm.Width > tb->Width Then
		tb->pnlForm.Width = tb->Width - tb->splForm.Width
	End If
End Sub

'mnuCode.ImagesList = pimgList '<m>
mnuCode.Add(ML("Cu&t") & !"\tCtrl+X", "Cut", "Cut", @mClick)
mnuCode.Add(ML("&Copy") & !"\tCtrl+C", "Copy", "Copy", @mClick)
mnuCode.Add(ML("&Paste") & !"\tCtrl+V", "Paste", "Paste", @mClick)
mnuCode.Add("-")
Var miToogle = mnuCode.Add(ML("Toggle"), "", "Toggle")
miToogle->Add(ML("Breakpoint"), "Breakpoint", "Breakpoint", @mClick)
miToogle->Add(ML("Bookmark"), "Bookmark", "ToggleBookmark", @mClick)
mnuCode.Add("-")
mnuCode.Add(ML("Add Watch"), "", "AddWatch", @mClick)
mnuCode.Add(ML("Run To Cursor"), "", "RunToCursor", @mClick)
mnuCode.Add(ML("Set Next Statement"), "", "SetNextStatement", @mClick)
mnuCode.Add("-")
mnuCode.Add(ML("Define"), "", "Define", @mClick)
mnuCode.Add("-")
mnuCode.Add(ML("Convert to Lowercase"), "", "ConvertToLowercase", @mClick)
mnuCode.Add(ML("Convert to Uppercase"), "", "ConvertToUppercase", @mClick)
mnuCode.Add("-")
mnuCode.Add(ML("Sort Lines"), "", "SortLines", @mClick)
mnuCode.Add(ML("Format With Basis Word"), "", "FormatWithBasisWord", @mClick)
Sub pnlForm_Message(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef msg As Message)
	Dim As Panel Ptr pnl = Cast(Panel Ptr, @Sender)
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, pnl->Parent)
	If tb = 0 OrElse tb->Des = 0 Then Exit Sub
	#ifndef __USE_GTK__
		Select Case msg.Msg
		Case WM_SIZE
			Dim As Integer dwClientX = pnl->ClientWidth 'UnScaleX(LoWord(msg.lParam))
			Dim As Integer dwClientY = pnl->ClientHeight 'UnScaleY(HiWord(msg.lParam))
			Dim As Integer iLeft, iTop, iWidth, iHeight
			Dim si As SCROLLINFO
			If tb->Des AndAlso tb->Des->DesignControl Then
				tb->Des->GetControlBounds(tb->Des->DesignControl, iLeft, iTop, iWidth, iHeight)
			End If
			iWidth += 2 * tb->Des->DotSize
			iHeight += 2 * tb->Des->DotSize
			
			' Set the vertical scrolling range and page size
			si.cbSize = SizeOf(si)
			si.fMask  = SIF_RANGE Or SIF_PAGE
			si.nMin   = 0
			If dwClientX - iWidth < 0 Then
				si.nMax   = ScaleX(iWidth - dwClientX)
			Else
				si.nMax   = 0
			End If
			si.nPage  = 3
			SetScrollInfo(msg.hWnd, SB_HORZ, @si, True)
			If si.nMax = 0 Then
				ScrollWindowEx msg.hWnd, -tb->Des->OffsetX, 0, 0, 0, 0, 0, SW_ERASE Or SW_SCROLLCHILDREN Or SW_INVALIDATE
				tb->Des->OffsetX = 0
			End If
			
			si.cbSize = SizeOf(si)
			si.fMask  = SIF_RANGE Or SIF_PAGE
			si.nMin   = 0
			If dwClientY - iHeight < 0 Then
				si.nMax   = ScaleY(iHeight - dwClientY)
			Else
				si.nMax   = 0
			End If
			si.nPage  = 3
			SetScrollInfo(msg.hWnd, SB_VERT, @si, True)
			If si.nMax = 0 Then
				ScrollWindowEx msg.hWnd, 0, -tb->Des->OffsetY, 0, 0, 0, 0, SW_ERASE Or SW_SCROLLCHILDREN Or SW_INVALIDATE
				tb->Des->OffsetY = 0
			End If
		Case WM_MOUSEWHEEL
			Dim As Byte scrDirection
			Dim si As SCROLLINFO
			Dim As Integer OldPos
			Dim scrStyle As Byte
			Dim As Boolean bShifted
			bShifted = GetKeyState(VK_SHIFT) And 8000
			If bShifted Then
				scrStyle = SB_HORZ
			Else
				scrStyle = SB_VERT
			End If
			#ifdef __FB_64BIT__
				If msg.wParam < 4000000000 Then
					scrDirection = 1
				Else
					scrDirection = -1
				End If
			#else
				scrDirection = Sgn(msg.wParam)
			#endif
			si.cbSize = SizeOf (si)
			si.fMask  = SIF_ALL
			GetScrollInfo (msg.hWnd, scrStyle, @si)
			OldPos = si.nPos
			If scrDirection = -1 Then
				si.nPos = Min(si.nPos + 3, si.nMax)
			Else
				si.nPos = Max(si.nPos - 3, si.nMin)
			End If
			si.fMask = SIF_POS
			SetScrollInfo(msg.hWnd, scrStyle, @si, True)
			GetScrollInfo(msg.hWnd, scrStyle, @si)
			If (Not si.nPos = OldPos) Then
				tb->Des->OffsetY += OldPos - si.nPos
				If bShifted Then
					ScrollWindowEx msg.hWnd, OldPos - si.nPos, 0, 0, 0, 0, 0, SW_ERASE Or SW_SCROLLCHILDREN Or SW_INVALIDATE
				Else
					ScrollWindowEx msg.hWnd, 0, OldPos - si.nPos, 0, 0, 0, 0, SW_ERASE Or SW_SCROLLCHILDREN Or SW_INVALIDATE
				End If
			End If
		Case WM_HSCROLL, WM_VSCROLL
			Dim scrStyle As Byte
			Dim si As SCROLLINFO
			Dim As Integer OldPos
			If msg.Msg = WM_HSCROLL Then
				scrStyle = SB_HORZ
			Else
				scrStyle = SB_VERT
			End If
			si.cbSize = SizeOf (si)
			si.fMask  = SIF_ALL
			GetScrollInfo (msg.hWnd, scrStyle, @si)
			OldPos = si.nPos
			Select Case msg.wParamLo
			Case SB_TOP, SB_LEFT
				si.nPos = si.nMin
			Case SB_BOTTOM, SB_RIGHT
				si.nPos = si.nMax
			Case SB_LINEUP, SB_LINELEFT
				si.nPos -= 3
			Case SB_LINEDOWN, SB_LINERIGHT
				si.nPos += 3
			Case SB_PAGEUP, SB_PAGELEFT
				si.nPos -= si.nPage
			Case SB_PAGEDOWN, SB_PAGERIGHT
				si.nPos += si.nPage
			Case SB_THUMBPOSITION, SB_THUMBTRACK
				si.nPos = si.nTrackPos
			End Select
			si.fMask = SIF_POS
			SetScrollInfo(msg.hWnd, scrStyle, @si, True)
			GetScrollInfo(msg.hWnd, scrStyle, @si)
			If (Not si.nPos = OldPos) Then
				If scrStyle = SB_HORZ Then
					tb->Des->OffsetX += OldPos - si.nPos
					ScrollWindowEx msg.hWnd, OldPos - si.nPos, 0, 0, 0, 0, 0, SW_ERASE Or SW_SCROLLCHILDREN Or SW_INVALIDATE
				Else
					tb->Des->OffsetY += OldPos - si.nPos
					ScrollWindowEx msg.hWnd, 0, OldPos - si.nPos, 0, 0, 0, 0, SW_ERASE Or SW_SCROLLCHILDREN Or SW_INVALIDATE
				End If
			End If
		End Select
	#endif
End Sub

Private Sub OnSplitHorizontallyChangeEdit(ByRef Designer As My.Sys.Object, ByRef Sender As EditControl, Splitted As Boolean)
	mnuSplitHorizontally->Checked = Splitted
End Sub

Private Sub OnSplitVerticallyChangeEdit(ByRef Designer As My.Sys.Object, ByRef Sender As EditControl, Splitted As Boolean)
	mnuSplitVertically->Checked = Splitted
End Sub

Sub tabCode_MouseUp(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	If MouseButton <> 1 Then Exit Sub
	With *Cast(TabControl Ptr, @Sender)
		Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, .SelectedTab)
		If tb = 0 Then Exit Sub
		Dim tn As TreeNode Ptr = tb->tn
		If tn = 0 Then Exit Sub
		If tn->ParentNode <> 0 Then
			miTabSetAsMain->Caption = ML("Set as Main")
		Else
			miTabSetAsMain->Caption = ML("Set as Start Up")
		End If
		miTabReloadHistoryCode->Enabled = tb->FileName <> "" AndAlso tb->FileName <> ML("Untitled")
		Var SplitEnabled = .TabCount > 1
		mnuTabs.Item("SplitUp")->Enabled = SplitEnabled
		mnuTabs.Item("SplitDown")->Enabled = SplitEnabled
		mnuTabs.Item("SplitLeft")->Enabled = SplitEnabled
		mnuTabs.Item("SplitRight")->Enabled = SplitEnabled
		Sender.ContextMenu = @mnuTabs
	End With
End Sub

Sub tabCode_Paint(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	TabCtl.MoveCloseButtons Cast(TabControl Ptr, @Sender)
End Sub

Dim Shared As TabControl Ptr RemovedFromTabCode
Sub tabCode_TabAdded(ByRef Designer As My.Sys.Object, ByRef Sender As TabControl, Page As TabPage Ptr, NewIndex As Integer)
	#ifdef __USE_WINAPI__
		Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, Page)
		If tb->btnClose.Parent <> 0 AndAlso tb->btnClose.Parent <> @Sender Then
			Dim As TabControl Ptr OldtabCode = Cast(TabControl Ptr, tb->btnClose.Parent)
			Sender.Add @tb->btnClose
			If OldtabCode Then TabWindowRemovedCheck(OldtabCode)
		End If
	#else
		If RemovedFromTabCode Then TabWindowRemovedCheck(RemovedFromTabCode)
	#endif
End Sub

Sub tabCode_TabRemoved(ByRef Designer As My.Sys.Object, ByRef Sender As TabControl, Page As TabPage Ptr, FromIndex As Integer)
	RemovedFromTabCode = @Sender
End Sub

Sub tabPanel_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	With *Cast(TabPanel Ptr, @Sender)
		For i As Integer = 0 To .ControlCount - 1
			If * (.Controls[i]) Is TabPanel Then
				If .Controls[i]->Align = DockStyle.alLeft OrElse .Controls[i]->Align = DockStyle.alRight Then
					.Controls[i]->Width = .Controls[i]->Width * NewWidth / .OldWidth
				ElseIf .Controls[i]->Align = DockStyle.alTop OrElse .Controls[i]->Align = DockStyle.alBottom Then
					.Controls[i]->Height = .Controls[i]->Height * NewHeight / .OldHeight
				End If
			End If
		Next
		.RequestAlign NewWidth, NewHeight, True
		.OldWidth = NewWidth
		.OldHeight = NewHeight
	End With
End Sub

Constructor TabPanel
	tabCode.Images = @imgList
	tabCode.GroupName = "tabCode"
	tabCode.Align = DockStyle.alClient
	tabCode.Detachable = True
	tabCode.Reorderable = True
	tabCode.OnPaint = @tabCode_Paint
	tabCode.OnSelChange = @tabCode_SelChange
	tabCode.OnMouseUp = @tabCode_MouseUp
	tabCode.OnTabAdded = @tabCode_TabAdded
	tabCode.OnTabRemoved = @tabCode_TabRemoved
	tabCode.ContextMenu = @mnuTabs
	This.OldWidth = This.Width
	This.OldHeight = This.Height
	This.OnResize = @tabPanel_Resize
	This.Add @tabCode
End Constructor

Constructor TabWindow(ByRef wFileName As WString = "", bNew As Boolean = False, TreeN As TreeNode Ptr = 0)
	WLet(FCaption, "")
	WLet(FFileName, "")
	txtCode.Font.Name = *EditorFontName
	txtCode.Font.Size = Max(8, EditorFontSize)
	txtCode.Align = DockStyle.alClient
	txtCode.OnChange = @OnChangeEdit
	txtCode.OnLineChange = @OnLineChangeEdit
	txtCode.OnLineAdding = @OnLineAddingEdit
	txtCode.OnLineRemoving = @OnLineRemovingEdit
	txtCode.OnLineChange = @OnLineChangeEdit
	txtCode.OnSelChange = @OnSelChangeEdit
	txtCode.OnLinkClicked = @OnLinkClickedEdit
	txtCode.OnToolTipLinkClicked = @OnToolTipLinkClickedEdit
	txtCode.OnGotFocus = @OnGotFocusEdit
	txtCode.OnKeyDown = @OnKeyDownEdit
	txtCode.OnKeyPress = @OnKeyPressEdit
	txtCode.OnUndoing = @OnUndoingEdit
	txtCode.OnUndo = @OnUndoEdit
	txtCode.OnRedoing = @OnRedoingEdit
	txtCode.OnRedo = @OnRedoEdit
	txtCode.OnDropDownCloseUp = @OnDropDownCloseUp
	txtCode.OnSplitHorizontallyChange = @OnSplitHorizontallyChangeEdit
	txtCode.OnSplitVerticallyChange = @OnSplitVerticallyChangeEdit
	txtCode.Content.FileName = ML("Untitled")
	txtCode.Tag = @This
	txtCode.ShowHint = False
	'CheckedFiles.Sorted = True
	#ifdef __USE_GTK__
		txtCode.lvIntellisense.OnSelectedItemChanged = @Intellisense_SelectedItemChanged
	#else
		txtCode.cboIntellisense.OnChange = @Intellisense_SelectedItemChanged
	#endif
	'OnPaste = @OnPasteEdit
	txtCode.OnMouseMove = @OnMouseMoveEdit
	txtCode.OnMouseHover = @OnMouseHoverEdit
	'txtCode.tbParent = @This
	This.Width = 180
	This.OnDestroy = @TabWindow_Destroy
	This.OnResize = @TabWindow_Resize
	'txtCode.Types.Sorted = True
	'txtCode.Enums.Sorted = True
	'txtCode.Procedures.Sorted = True
	'txtCode.Functions.Sorted = True
	'txtCode.FunctionsOthers.Sorted = True
	'txtCode.Args.Sorted = True
	lvPropertyWidth = 150
	btnClose.tbParent = @This
	#ifdef __USE_GTK__
		pnlTop.Height = 33
	#else
		pnlTop.Height = 25
	#endif
	pnlTop.Align = DockStyle.alTop
	#ifdef __USE_GTK__
		pnlTopCombo.Height = 33
	#else
		pnlTopCombo.Height = 25
	#endif
	txtCode.ContextMenu = @mnuCode
	pnlTopCombo.Align = DockStyle.alClient
	pnlTopCombo.Width = 101
	pnlForm.Name = "Designer"
	pnlForm.Width = 360
	pnlForm.Align = DockStyle.alRight
	pnlCode.Align = DockStyle.alClient
	pnlEdit.Align = DockStyle.alClient
	pnlTopMenu.Parent = @pnlForm
	#ifndef __USE_GTK__
		pnlTopMenu.Font.Name = "Tahoma"
		pnlTopMenu.Font.Size = 8
	#endif
	'lvComponentsList.Images = @imgListTools
	'lvComponentsList.StateImages = @imgListTools
	'lvComponentsList.SmallImages = @imgListTools
	'lvComponentsList.View = vsIcon
	'Dim As My.Sys.Drawing.Cursor crRArrow, crHand
	'crRArrow.LoadFromResourceName("Select")
	'crHand.LoadFromResourceName("Hand")
	splForm.Align = SplitterAlignmentConstants.alRight
	cboClass.ImagesList = pimgListTools
	'cboClass.ItemIndex = 0
	'cboClass.SetBounds 0, 2, 60, 20
	tbrTop.ImagesList = pimgList
	#ifdef __USE_GTK__
		tbrTop.Width = 150
		pnlToolbar.Width = 150
	#else
		tbrTop.Width = 75
		pnlToolbar.Width = 75
	#endif
	tbrTop.Align = DockStyle.alRight
	tbrTop.Buttons.Add tbsSeparator
	tbrTop.Buttons.Add tbsCheckGroup, "Code", , , "Code", , ML("Show Code"), True ' Show the toollips
	tbrTop.Buttons.Add tbsCheckGroup, "Form", , , "Form", , ML("Show Form"), True ' Show the toollips
	tbrTop.Buttons.Add tbsCheckGroup, "CodeAndForm", , , "CodeAndForm", , ML("Show Code And Form"), True '
	tbrTop.OnButtonClick = @tbrTop_ButtonClick
	tbrTop.Flat = True
	pnlToolbar.Align = DockStyle.alRight
	cboClass.Width = 50
	#ifdef __USE_GTK__
		cboClass.Top = 0
		#ifdef __USE_GTK3__
			cboClass.Height = 20
		#else
			cboClass.Height = 30
		#endif
	#else
		cboClass.Top = 1
		cboClass.Height = 30 * 22
		cboClass.DropDownCount = 30
	#endif
	cboClass.Anchor.Left = asAnchor
	cboClass.Anchor.Right = asAnchorProportional
	cboClass.OnSelected = @cboClass_Change
	cboClass.ImagesList = pimgListTools
	cboFunction.ImagesList = pimgList
	cboFunction.Left = 50 + 0 + 1
	cboFunction.Width = 50
	#ifdef __USE_GTK__
		cboFunction.Top = 0
		#ifdef __USE_GTK3__
			cboFunction.Height = 20
		#else
			cboFunction.Height = 30
		#endif
	#else
		cboFunction.Top = 1
		cboFunction.Height = 30 * 22
		cboFunction.DropDownCount = 30
	#endif
	cboFunction.Anchor.Left = asAnchorProportional
	cboFunction.Anchor.Right = asAnchor
	cboFunction.OnSelected = @cboFunction_Change
	'cboFunction.Sort = True
	cboFunction.Items.Add WStr("(") & ML("Declarations") & ")" & WChr(0), , "Sub", "Sub"
	cboFunction.ItemIndex = 0
	pnlForm.Visible = False
	pnlForm.OnMessage = @pnlForm_Message
	splForm.Visible = False
	pnlToolbar.Add @tbrTop
	pnlTop.Add @pnlToolbar
	pnlTop.Add @pnlTopCombo
	pnlTopCombo.Add @cboClass
	pnlTopCombo.Add @cboFunction
	If CInt(wFileName <> "") And CInt(bNew = False OrElse TreeN <> 0) Then
		If bNew Then
			If TreeN > 0 Then FileName = TreeN->Text
			If EndsWith(FileName, "*") Then FileName = ..Left(FileName, Len(FileName) - 1)
		Else
			FileName = wFileName
		End If
		'txtCode.LoadFromFile(wFileName, False)
		This.Caption = GetFileName(FileName)
	Else
		This.Caption = ML("Untitled") & "*"
	End If
	IsNew = bNew OrElse wFileName = ""
	pnlForm.Top = -500
	#ifdef __USE_GTK__
		#ifdef __USE_GTK3__
			pnlForm.overlaywidget = gtk_overlay_new()
			gtk_container_add(GTK_CONTAINER(pnlForm.overlaywidget), pnlForm.Handle)
			pnlForm.scrolledwidget = gtk_scrolled_window_new(NULL, NULL)
			gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(pnlForm.scrolledwidget), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC)
			gtk_container_add(GTK_CONTAINER(pnlForm.scrolledwidget), pnlForm.overlaywidget)
			'layout = gtk_layout_new(NULL, NULL)
			'gtk_overlay_add_overlay(gtk_overlay(overlay), layout)
		#else
			pnlForm.scrolledwidget = gtk_scrolled_window_new(NULL, NULL)
			gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(pnlForm.scrolledwidget), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC)
			gtk_container_add(GTK_CONTAINER(pnlForm.scrolledwidget), pnlForm.Handle)
		#endif
	#else
		pnlForm.Style = pnlForm.Style Or WS_HSCROLL Or WS_VSCROLL
	#endif
	pnlCode.Add @txtCode
	This.Add @pnlTop
	This.Add @pnlForm
	This.Add @splForm
	This.Add @pnlCode
	#ifdef __USE_GTK__
		txtCode.lvIntellisense.OnItemActivate = @lvIntellisense_ItemActivate
	#else
		txtCode.cboIntellisense.ImagesList = pimgList
		txtCode.cboIntellisense.OnDropDown = @cboIntellisense_DropDown
		txtCode.cboIntellisense.OnCloseUp = @cboIntellisense_CloseUp
		txtCode.cboIntellisense.OnSelected = @cboIntellisense_Selected
	#endif
	'cboIntellisense.Style = cbDropDown
	'This.ImageIndex = pimgList->IndexOf("File")
	'This.ImageKey = "File"
	'    OnHandleIsAllocated = @HandleIsAllocated
	If TreeN <> 0 Then
		tn = TreeN
	Else
		Dim As ExplorerElement Ptr ee
		For i As Integer = 0 To ptvExplorer->Nodes.Count - 1
			ee = ptvExplorer->Nodes.Item(i)->Tag
			If ee <> 0 Then
				If *ee->FileName = FileName Then
					tn = ptvExplorer->Nodes.Item(i)
					Exit For
				End If
			End If
			For j As Integer = 0 To ptvExplorer->Nodes.Item(i)->Nodes.Count - 1
				ee = ptvExplorer->Nodes.Item(i)->Nodes.Item(j)->Tag
				If ee <> 0 Then
					If *ee->FileName = FileName Then
						tn = ptvExplorer->Nodes.Item(i)->Nodes.Item(j)
						Exit For
					End If
				End If
			Next
			If tn <> 0 Then Exit For
		Next i
		If tn = 0 Then
			tn = ptvExplorer->Nodes.Add(This.Caption, , , "File", "File")
		End If
	End If
	ptn = GetParentNode(tn)
	mi = miWindow->Add(This.Caption, "", , @mClickWindow, True)
	mi->Tag = @This
End Constructor

Destructor TabWindow
	If FCaptionNew Then _Deallocate( FCaptionNew)
	If FFileName Then _Deallocate( FFileName)
	If FLine Then _Deallocate( FLine)
	If FLine1 Then _Deallocate( FLine1)
	If FLine2 Then _Deallocate( FLine2)
	If FLine3 Then _Deallocate( FLine3)
	If FLine4 Then _Deallocate( FLine4)
	If FPath Then _Deallocate( FPath)
	'	If pLocalTypes = @Types Then pLocalTypes = 0
	'	If pLocalEnums = @Enums Then pLocalEnums = 0
	'	If pLocalProcedures = @Procedures Then pLocalProcedures = 0
	'	If pLocalFunctions = @Functions Then pLocalFunctions = 0
	'	If pLocalFunctionsOthers = @FunctionsOthers Then pLocalFunctionsOthers = 0
	'	If pLocalArgs = @Args Then pLocalArgs = 0
	If Des <> 0 Then
		For i As Integer = cboClass.Items.Count - 1 To 1 Step -1
			CurCtrl = 0
			CBItem = cboClass.Items.Item(i)
			If CBItem <> 0 Then CurCtrl = CBItem->Object
			If CurCtrl <> 0 Then
				#ifndef __USE_GTK__
					Dim As SymbolsType Ptr st = Des->Symbols(CurCtrl)
					'If Des->ReadPropertyFunc(CurCtrl, "Tag") <> 0 Then Delete_(Cast(Dictionary Ptr, Des->ReadPropertyFunc(CurCtrl, "Tag")))
					If st AndAlso st->DeleteComponentFunc Then st->DeleteComponentFunc(CurCtrl)
				#endif
			End If
		Next i
		_Delete( Des)
	End If
	cboClass.Items.Clear
	cboFunction.Items.Clear
	Dim As TypeElement Ptr te, te1
	Dim As ConstructionBlock Ptr cb
	For i As Integer = txtCode.Content.Types.Count - 1 To 0 Step -1
		te = txtCode.Content.Types.Object(i)
		For j As Integer = te->Elements.Count - 1 To 0 Step -1
			te1 = te->Elements.Object(j)
			For k As Integer = te1->Elements.Count - 1 To 0 Step -1
				_Delete(Cast(TypeElement Ptr, te1->Elements.Object(k)))
			Next
			te1->Elements.Clear
			_Delete( Cast(TypeElement Ptr, te->Elements.Object(j)))
		Next
		te->Elements.Clear
		_Delete( Cast(TypeElement Ptr, txtCode.Content.Types.Object(i)))
	Next
	For i As Integer = txtCode.Content.Enums.Count - 1 To 0 Step -1
		_Delete( Cast(TypeElement Ptr, txtCode.Content.Enums.Object(i)))
	Next
	For i As Integer = txtCode.Content.Namespaces.Count - 1 To 0 Step -1
		_Delete( Cast(TypeElement Ptr, txtCode.Content.Namespaces.Object(i)))
	Next
	For i As Integer = txtCode.Content.TypeProcedures.Count - 1 To 0 Step -1
		te = txtCode.Content.TypeProcedures.Object(i)
		For j As Integer = te->Elements.Count - 1 To 0 Step -1
			te1 = te->Elements.Object(j)
			For k As Integer = te1->Elements.Count - 1 To 0 Step -1
				_Delete(Cast(TypeElement Ptr, te1->Elements.Object(k)))
			Next
			te1->Elements.Clear
			_Delete( Cast(TypeElement Ptr, te->Elements.Object(j)))
		Next
		te->Elements.Clear
		_Delete( Cast(TypeElement Ptr, txtCode.Content.TypeProcedures.Object(i)))
	Next
	For i As Integer = txtCode.Content.Procedures.Count - 1 To 0 Step -1
		te = txtCode.Content.Procedures.Object(i)
		For j As Integer = te->Elements.Count - 1 To 0 Step -1
			te1 = te->Elements.Object(j)
			For k As Integer = te1->Elements.Count - 1 To 0 Step -1
				_Delete(Cast(TypeElement Ptr, te1->Elements.Object(k)))
			Next
			te1->Elements.Clear
			_Delete( Cast(TypeElement Ptr, te->Elements.Object(j)))
		Next
		te->Elements.Clear
		_Delete( Cast(TypeElement Ptr, txtCode.Content.Procedures.Object(i)))
	Next
	For i As Integer = txtCode.Content.ConstructionBlocks.Count - 1 To 0 Step -1
		cb = txtCode.Content.ConstructionBlocks.Item(i)
		For j As Integer = cb->Elements.Count - 1 To 0 Step -1
			_Delete( Cast(TypeElement Ptr, cb->Elements.Object(j)))
		Next
		cb->Elements.Clear
		_Delete(Cast(ConstructionBlock Ptr, txtCode.Content.ConstructionBlocks.Item(i)))
	Next
	For i As Integer = txtCode.Content.LineLabels.Count - 1 To 0 Step -1
		_Delete( Cast(TypeElement Ptr, txtCode.Content.LineLabels.Object(i)))
		txtCode.Content.LineLabels.Remove i
	Next
	For i As Integer = txtCode.Content.Args.Count - 1 To 0 Step -1
		te = txtCode.Content.Args.Object(i)
		For j As Integer = te->Elements.Count - 1 To 0 Step -1
			_Delete(Cast(TypeElement Ptr, te->Elements.Object(j)))
		Next
		_Delete( Cast(TypeElement Ptr, txtCode.Content.Args.Object(i)))
	Next
	For i As Integer = AnyTexts.Count - 1 To 0 Step -1
		_Delete( Cast(WString Ptr, AnyTexts.Object(i)))
	Next
	For i As Integer = txtCode.Content.FileLists.Count - 1 To 0 Step -1
		_Delete( Cast(WStringList Ptr, txtCode.Content.FileLists.Item(i)))
	Next
	For i As Integer = txtCode.Content.FileListsLines.Count - 1 To 0 Step -1
		_Delete( Cast(IntegerList Ptr, txtCode.Content.FileListsLines.Item(i)))
	Next
	txtCode.Content.Functions.Clear
	txtCode.Content.ConstructionBlocks.Clear
	txtCode.Content.Namespaces.Clear
	txtCode.Content.Types.Clear
	txtCode.Content.TypeProcedures.Clear
	txtCode.Content.Procedures.Clear
	txtCode.Content.LineLabels.Clear
	txtCode.Content.Args.Clear
	txtCode.Content.FileLists.Clear
	txtCode.Content.FileListsLines.Clear
	txtCode.Content.ExternalFiles.Clear
	txtCode.Content.ExternalFileLines.Clear
	txtCode.Content.ExternalIncludes.Clear
	txtCode.Content.CheckedFiles.Clear
	AnyTexts.Clear
	Events.Clear
	If ptabRight->Tag = @This Then ptabRight->Tag = 0
	'If tn <> 0 Then ptvExplorer->RemoveRoot ptvExplorer->IndexOfRoot(tn)
End Destructor

'Public Function STATEIMAGEMASKTOINDEX(iState As Integer) As Integer
'
'  STATEIMAGEMASKTOINDEX = iState / (2 ^ 12)
'End Function
'
'#IfNDef __USE_GTK__
'	Public Function Listview_GetItemStateEx(hwndLV As HWND, iItem As Integer, ByRef iIndent As Integer) As Integer
'		Dim lvi As LVITEM
'
'
'		lvi.mask = LVIF_STATE Or LVIF_INDENT
'		lvi.iItem = iItem
'		lvi.stateMask = LVIS_STATEIMAGEMASK
'
'
'		If ListView_GetItem(hwndLV, @lvi) Then
'			iIndent = lvi.iIndent
'			Return STATEIMAGEMASKTOINDEX(lvi.state And LVIS_STATEIMAGEMASK)
'		End If
'
'
'	End Function
'#EndIf
'
'#IfNDef __USE_GTK__
'	Public Function Listview_SetItemStateEx(hwndLV As HWND, iItem As Integer, iIndent As Integer, dwState As Integer) As Boolean
'		Dim lvi As LVITEM
'		lvi.mask = LVIF_STATE Or LVIF_INDENT
'		lvi.iItem = iItem
'		lvi.iIndent = iIndent
'		lvi.state = INDEXTOSTATEIMAGEMASK(dwState)
'		lvi.stateMask = LVIS_STATEIMAGEMASK
'		Return ListView_SetItem(hwndLV, @lvi)
'	End Function
'#EndIF

'Sub AddChildItems(iParentItem As Integer, iParentIndent As Integer)
'    If (iParentItem <> -1) Then
'		#IfNDef __USE_GTK__
'			Listview_SetItemStateEx(lvProperties.Handle, iParentItem, iParentIndent, 2)
'        #EndIf
'        Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, tabRight.Tag)
'        If tb = 0 Then Exit Sub
'        If tb->Des = 0 Then Exit Sub
'        If tb->Des->ReadPropertyFunc = 0 Then Exit Sub
'        If tb->Des->SelectedControl = 0 Then Exit Sub
'        Dim PropertyName As String = GetItemText(lvProperties.ListItems.Item(iParentItem))
'        Var te = GetPropertyType(WGet(tb->Des->ReadPropertyFunc(tb->Des->SelectedControl, "ClassName")), PropertyName)
'        If te = 0 Then Exit Sub
'        tabRight.UpdateLock
'        Dim lvItem As TreeListViewItem Ptr
'        FPropertyItems.Clear
'        tb->FillProperties te->TypeName
'        FPropertyItems.Sort
'        For lvPropertyCount As Integer = FPropertyItems.Count - 1 To 0 Step -1
'            te = FPropertyItems.Object(lvPropertyCount)
'            If te = 0 Then Continue For
'            With *te
'                If Cint(LCase(.Name) <> "handle") AndAlso Cint(LCase(.TypeName) <> "hwnd") AndAlso Cint(.ElementType = "Property") Then
'                    lvItem = lvProperties.ListItems.Insert(iParentItem + 1, FPropertyItems.Item(lvPropertyCount), 2, IIF(Comps.Contains(.TypeName), 1, 0), iParentIndent + 1)
'                    lvItem->Text(1) = tb->ReadObjProperty(tb->Des->SelectedControl, PropertyName & "." & FPropertyItems.Item(lvPropertyCount))
'                End If
'            End With
'        Next
'        tabRight.UpdateUnlock
'    End If
'End Sub
'
'Sub RemoveChildItems(iParentItem As Integer, iParentIndent As Integer)
'    #IfNDef __USE_GTK__
'		Listview_SetItemStateEx(lvProperties.Handle, iParentItem, iParentIndent, 1)
'    #EndIf
'    Var nItems = lvProperties.ListItems.Count
'    Dim iChildIndent As Integer
'    Do
'		#IfNDef __USE_GTK__
'			Listview_GetItemStateEx(lvProperties.Handle, iParentItem + 1, iChildIndent)
'        #EndIf
'        If (iChildIndent > iParentIndent) Then
'
'            ' Remove the item directly below the collapsing parent (VB ListItems are one-based)
'            lvProperties.ListItems.Remove (iParentItem + 1)
'
'            ' Keep a count of ListView items so we don't try to remove more
'            ' items than are in the ListView (when collapsing the last parent).
'
'           nItems = nItems - 1
'        End If
'
'  Loop While (iChildIndent > iParentIndent) And (iParentItem + 1 < nItems)
'End Sub
'
'Sub ClickProperty(Item As Integer)
'    Dim dwState As Integer
'    Dim iIndent As Integer
'    #IfNDef __USE_GTK__
'		Dim lvi As LVITEM
'		lvi.mask = LVIF_STATE Or LVIF_INDENT
'		lvi.iItem = Item
'		lvi.stateMask = LVIS_STATEIMAGEMASK
'		If ListView_GetItem(lvProperties.Handle, @lvi) Then
'			iIndent = lvi.iIndent
'			dwState = STATEIMAGEMASKTOINDEX(lvi.state And LVIS_STATEIMAGEMASK)
'			If dwState > 0 Then
'				If (dwState = 1) Then
'					AddChildItems(Item, iIndent)
'				Else
'					RemoveChildItems(Item, iIndent)
'				End If
'			End If
'		End If
'	#EndIf
'End Sub
'
'Sub lvProperties_MouseDown(BYREF Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
'    #IfNDef __USE_GTK__
'		Dim lvhti As LVHITTESTINFO
'		If MouseButton = 0 Then
'			lvhti.pt.x = x
'			lvhti.pt.y = y
'			If (ListView_HitTest(Sender.Handle, @lvhti) <> -1) Then
'				If (lvhti.flags = LVHT_ONITEMSTATEICON) Then
'					ClickProperty lvhti.iItem
'				End If
'			End If
'		End If
'	#EndIf
'End Sub

Sub lvProperties_ItemExpanding(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
	If Item AndAlso Item->Nodes.Count > 0 AndAlso Item->Nodes.Item(0)->Text(0) = "" Then
		Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabRight->Tag)
		If tb = 0 Then Exit Sub
		If tb->Des = 0 Then Exit Sub
		If tb->Des->SelectedControl = 0 Then Exit Sub
		Dim As SymbolsType Ptr st = tb->Des->Symbols(tb->Des->SelectedControl)
		If st = 0 OrElse st->ReadPropertyFunc = 0 Then Exit Sub
		Dim PropertyName As String = GetItemText(Item)
		Var te = GetPropertyType(WGet(st->ReadPropertyFunc(tb->Des->SelectedControl, "ClassName")), PropertyName)
		If te = 0 Then Exit Sub
		ptabRight->UpdateLock
		Dim lvItem As TreeListViewItem Ptr
		Dim As UString ItemText
		Dim As Integer SelCount = tb->Des->SelectedControls.Count
		FPropertyItems.Clear
		tb->FillProperties te->TypeName
		FPropertyItems.Sort
		For lvPropertyCount As Integer = FPropertyItems.Count - 1 To 0 Step -1
			ItemText = tb->ReadObjProperty(tb->Des->SelectedControl, PropertyName & "." & FPropertyItems.Item(lvPropertyCount))
			If SelCount > 1 AndAlso ItemText <> "" Then
				For i As Integer = 0 To SelCount - 1
					If tb->ReadObjProperty(tb->Des->SelectedControls.Item(i), PropertyName & "." & FPropertyItems.Item(lvPropertyCount)) <> ItemText Then
						ItemText = ""
						Exit For
					End If
				Next i
			End If
			te = FPropertyItems.Object(lvPropertyCount)
			If te = 0 Then Continue For
			With *te
				If CInt(LCase(.Name) <> "handle") AndAlso CInt(LCase(.TypeName) <> "hwnd") AndAlso CInt(LCase(.TypeName) <> "jobject") AndAlso CInt(LCase(.TypeName) <> "gtkwidget") AndAlso (CInt(.ElementType = E_Property) OrElse CInt(.ElementType = E_Field)) Then
					lvItem = Item->Nodes.Add(FPropertyItems.Item(lvPropertyCount), 2, IIf(pComps->Contains(.TypeName), 1, 0))
					lvItem->Text(1) = ItemText 'tb->ReadObjProperty(tb->Des->SelectedControl, PropertyName & "." & FPropertyItems.Item(lvPropertyCount))
					If pComps->Contains(.TypeName) Then
						lvItem->Nodes.Add
					End If
				End If
			End With
		Next
		Item->Nodes.Remove 0
		ptabRight->UpdateUnLock
	End If
End Sub

Function SplitError(ByRef sLine As WString, ByRef ErrFileName As WString Ptr, ByRef ErrTitle As WString Ptr, ByRef ErrorLine As Integer) As UShort
	Dim As Integer Pos1, Pos2, Pos3 'David Change for ML
	Dim As WString * 50 bFlagErr = ""
	WLet(ErrFileName, "")
	WLet(ErrTitle, sLine)
	ErrorLine = 0
	Pos1 = InStr(LCase(sLine), ") error ")
	If Pos1 = 0 Then Pos1 = InStr(LCase(sLine), "error:")
	If Pos1 = 0 Then Pos1 = InStr(LCase(sLine), "ld.exe:")
	If Pos1 = 0 Then Pos1 = InStr(LCase(sLine), "error!")
	If Pos1 = 0 Then
		Pos1 = InStr(LCase(sLine), " warning")
		If Pos1 > 0 Then bFlagErr = "Warning"
	Else
		bFlagErr = "Error"
	End If
	If Pos1 = 0 Then
		Pos1 = InStr(3, sLine, ":")
		If Pos1 = 0 Then Return -1
		Pos2 = InStr(Pos1 + 1, sLine, ":")
		If Pos2 = 0 Then Return -1
		'If Not IsNumeric(Mid(sLine, Pos1 + 1, Pos2 - Pos1 - 1)) Then Return -1
		Swap Pos1, Pos2
	Else
		Pos2 = InStrRev(sLine, "(", Pos1)
		If Pos2 = 0 Then Pos2 = InStr(Pos1, sLine, ":") 'David Changed
		'If Pos2 = 0 Then Return -1
	End If
	If InStr(LCase(sLine), "error!") Then
		Pos2 = InStr(Pos1, sLine, "Line ")
		Pos3 = InStr(Pos2, sLine, " of Resource Script (")
		ErrorLine = Val(Mid(sLine, Pos2 + 5, Pos3 - Pos2 - 1))
		Pos2 = InStr(Pos3, sLine, ")")
		WLet(ErrFileName, Mid(sLine, Pos3 + 21, Pos2 - Pos3 - 21))
	ElseIf InStr(LCase(sLine), "fatal error") OrElse InStr(LCase(sLine), ": error:") Then
		Pos2 = InStr(3, sLine, ":")
		WLet(ErrFileName, Left(sLine, Pos2 - 1))
		Pos3 = InStr(Pos2 + 1, sLine, ":")
		ErrorLine = Val(Mid(sLine, Pos2 + 1, Pos3 - Pos2 - 1))
	Else
		ErrorLine = Val(Mid(sLine, Pos2 + 1, Pos1 - Pos2 - 1))
		'If ErrorLine = 0 Then Return 0
		WLet(ErrFileName, Left(sLine, Pos2 - 1))
	End If
	If StartsWith(*ErrFileName, "In file included from ") Then
		WLet(ErrTitle, Left(sLine, 22))
		WLetEx(ErrFileName, Mid(*ErrFileName, 23), True)
	Else
		Pos3 = InStr(Pos1, sLine, ":")
		If Pos3 > 0 Then
			Dim As String Dots = IIf(bFlagErr = "", "", ": ")
			Pos2 = InStrRev(sLine, ",")
			If Pos2 < 1 Then
				Pos2 = Len(sLine)
			ElseIf Mid(sLine, Pos2 - 1, 3) = "','" Then
				Pos1 = InStrRev(sLine, ",", Pos2 - 1)
				If Pos1 > 1 Then Pos2 = Pos1
			End If
			If InStr(Mid(sLine, Pos2),", found") = 1 Then
				WLet(ErrTitle, ML(bFlagErr) + Dots + MLCompilerFun(Trim(Mid(sLine, Pos3 + 1, Pos2 - Pos3 - 1))) + ", " + ML("found") + (Mid(sLine, Pos2 + Len(", found"))))
			ElseIf InStr(Mid(sLine, Pos2),", before") = 1 Then
				WLet(ErrTitle, ML(bFlagErr) + Dots + MLCompilerFun(Trim(Mid(sLine, Pos3 + 1, Pos2 - Pos3 - 1))) + ", " + ML("before") + (Mid(sLine, Pos2 + Len(", before"))))
			ElseIf InStr(Mid(sLine, Pos2),", after") = 1 Then
				WLet(ErrTitle, ML(bFlagErr) + Dots + MLCompilerFun(Trim(Mid(sLine, Pos3 + 1, Pos2 - Pos3 - 1))) + ", " + ML("after") + (Mid(sLine, Pos2 + Len(", after"))))
			ElseIf InStr(Mid(sLine, Pos2),", exiting") = 1 Then
				WLet(ErrTitle, ML(bFlagErr) + Dots + MLCompilerFun(Trim(Mid(sLine, Pos3 + 1, Pos2 - Pos3 - 1))) + ", " + ML("Exit") + (Mid(sLine, Pos2 + Len(", exiting"))))
			ElseIf InStr(Mid(sLine, Pos2),", at parameter") = 1 Then
				WLet(ErrTitle, ML(bFlagErr) + Dots + MLCompilerFun(Trim(Mid(sLine, Pos3 + 1, Pos2 - Pos3 - 1))) + ", " + ML("at parameter") + (Mid(sLine, Pos2 + Len(", at parameter"))))
				'at parameter
			Else
				If Pos2 > Pos3 Then
					Dim As WString * 250 tStr = Trim(Mid(sLine, Pos3 + 1, Pos2 - Pos3))
					If Right(tStr, 1) = "," Then tStr = Trim(Mid(sLine, Pos3 + 1, Pos2 - Pos3 - 1)) 'Strange. Sometime got letter ","
					WLet(ErrTitle, ML(bFlagErr) + Dots + MLCompilerFun(tStr) & IIf(Mid(sLine, Pos2 + 1) <> "", ", " + (Mid(sLine, Pos2 + 2)), "")) '& Mid(sLine, Pos2+1)
				Else
					WLet(ErrTitle, ML(bFlagErr) + Dots + MLCompilerFun(Trim(Mid(sLine, Pos3 + 1))))
				End If
			End If
		Else
			WLet(ErrTitle, Mid(sLine, Pos1 + 1))
		End If
	End If
	If bFlagErr = "Warning"  Then
		Return 1
	ElseIf bFlagErr = "Error"  Then
		Return 2
	Else
		Return 0
	End If
End Function

Function Err2Description(Code As Integer) ByRef As WString
	Select Case Code
	Case 0: Return ML("No error")
	Case 1: Return ML("Illegal function call")
	Case 2: Return ML("File not found signal")
	Case 3, 1073741819:  Return ML("File I/O error")
	Case 4: Return ML("Out of memory")
	Case 5: Return ML("Illegal resume")
	Case 6, 3221226356: Return ML("Out of bounds array access")
	Case 7: Return ML("Null Pointer Access")
	Case 8: Return ML("No privileges")
	Case 9: Return ML("Interrupted signal")
	Case 10: Return ML("Illegal instruction signal")
	Case 11: Return ML("Floating point error signal")
	Case 12: Return ML("Segmentation violation signal")
	Case 13: Return ML("Termination request signal")
	Case 14: Return ML("Abnormal termination signal")
	Case 15: Return ML("Quit request signal")
	Case 16: Return ML("Return without gosub")
	Case 17: Return ML("End of file")
	Case 193: Return ML("Could not execute:Bad executable format")
	Case 3221225477: Return ML("Stack Overflow")
	Case Else: Return WStr("")
	End Select
End Function

Sub PipeCmd(ByRef file As WString, ByRef cmd As WString)
	Dim As WString Ptr fileW, cmdW
	'WLet fileW, file
	'WLet cmdW, cmd
	#ifdef __USE_GTK__
		Shell cmd
		'Dim As gint i_retcode = 0, i_exitcode = 0
		'i_retcode = g_spawn_command_line_sync(ToUTF8(cmd), NULL, NULL, @i_exitcode, NULL)
	#else
		WLet(cmdW, "cmd /c """ + cmd + """|clip")
		Dim PI As PROCESS_INFORMATION
		Dim SI As STARTUPINFO
		SI.wShowWindow = SW_HIDE
		SI.cb = SizeOf(STARTUPINFO)
		SI.dwFlags = STARTF_USESHOWWINDOW
		
		CreateProcess(0, cmdW, 0, 0, 1, NORMAL_PRIORITY_CLASS, 0, 0, @SI, @PI)
		WaitForSingleObject(PI.hProcess, INFINITE)
		CloseHandle(PI.hProcess)
		CloseHandle(PI.hThread)
	#endif
End Sub

#ifdef __USE_GTK__
	Function build_create_shellscript(ByRef working_dir As WString, ByRef cmd As WString, autoclose As Boolean, bDebug As Boolean = False, ByRef Arguments As WString = "") As String
		'?Replace(cmd, "\", "/")
		'?!"#!/bin/sh\n\nrm $0\n\ncd " & Replace(working_dir, "\", "/") & !"\n\n" & Replace(cmd, "\", "/") & !"\n\necho ""\n\n------------------\n(program exited with code: $?)"" \n\n" & IIF(autoclose, "", !"\necho ""Press return to continue""\n#to be more compatible with shells like ""dash\ndummy_var=""""\nread dummy_var") & !"\n"
		Dim As Boolean Bit32 = tbt32Bit->Checked
		Dim As WString Ptr DebuggerPath = IIf(Bit32, Debugger32Path, Debugger64Path)
		Dim As String ScriptPath
		Dim As Integer Fn = FreeFile_
		ScriptPath = *g_get_tmp_dir() & "/vfb_run_script.sh"
		Open ScriptPath For Output As #Fn
		Print #Fn, "#!/bin/sh"
		Print #Fn, ""
		Print #Fn, "rm $0"
		Print #Fn, ""
		Print #Fn, "cd " & Replace(working_dir, "\", "/")
		Print #Fn, ""
		Print #Fn, IIf(bDebug, """" & WGet(DebuggerPath) & """" & " ", "") & Replace(cmd, "\", "/") & " " & Arguments
		Print #Fn, ""
		Print #Fn, !"echo ""\n\n------------------\n(program exited with code: $?)"" \n\n" & IIf(autoclose, "", !"\necho ""Press return to continue""\n#to be more compatible with shells like ""dash\ndummy_var=""""\nread dummy_var") & !"\n"
		CloseFile_(Fn)
		ScriptPath = "sh " & ScriptPath
		Return ScriptPath
	End Function
#endif

'#IfDef __USE_GTK__
'Type VteInfo
'	Dim As gboolean load_vte			'/* this is the preference, NOT the current instance VTE state */
'	Dim As gboolean load_vte_cmdline	'/* this is the command line option */
'	Dim As gboolean have_vte			'/* use this field to check if the current instance has VTE */
'	Dim As gchar Ptr lib_vte
'	Dim As gchar Ptr dir
'End Type
'Dim Shared As VteInfo vte_info
'
'Type VteConfig
'	Dim As GtkWidget Ptr vte
'	Dim As GtkWidget Ptr menu
'	Dim As GtkWidget Ptr im_submenu
'	Dim As gboolean scroll_on_key
'	Dim As gboolean scroll_on_out
'	Dim As gboolean ignore_menu_bar_accel
'	Dim As gboolean follow_path
'	Dim As gboolean run_in_vte
'	Dim As gboolean skip_run_script
'	Dim As gboolean enable_bash_keys
'	Dim As gboolean cursor_blinks
'	Dim As gboolean send_selection_unsafe
'	Dim As gint scrollback_lines
'	Dim As gchar Ptr shell
'	Dim As gchar Ptr font
'	Dim As gchar Ptr send_cmd_prefix
'	Dim As GdkColor colour_fore
'	Dim As GdkColor colour_back
'End Type
'Dim Shared As VteConfig Ptr vc
'
'Enum VteTerminalCursorBlinkMode
'	VTE_CURSOR_BLINK_SYSTEM,
'	VTE_CURSOR_BLINK_ON,
'	VTE_CURSOR_BLINK_OFF
'End Enum
'
'Enum VtePtyFlags
'	/' we don't care for the other possible values '/
'	VTE_PTY_DEFAULT = 0
'End Enum
'
'/ Incomplete VteTerminal struct from vte/vte.h. '/
'Type VteTerminal As _VteTerminal
'Type _VteTerminal
'	Dim As GtkWidget Ptr widget
'	Dim As GtkAdjustment Ptr adjustment
'End Type
'
'#define VTE_TERMINAL(obj) (G_TYPE_CHECK_INSTANCE_CAST((obj), VTE_TYPE_TERMINAL, VteTerminal))
'#define VTE_TYPE_TERMINAL (vf->vte_terminal_get_type())
'
'/' Holds function pointers we need to access the VTE API. '/

'Type VteFunctions
'	vte_get_major_version As Function() As guint
'	vte_get_minor_version As Function() As guint
'	vte_terminal_new As Function() As GtkWidget Ptr
'	vte_terminal_fork_command As Function (terminal As VteTerminal Ptr, command1 As const gchar Ptr, argv As gchar Ptr Ptr, _
'										envv As gchar Ptr Ptr, directory As const gchar Ptr, lastlog As gboolean, _
'										utmp As gboolean, wtmp As gboolean) As pid_t
'	vte_terminal_spawn_sync As Function(terminal As VteTerminal Ptr, pty_flags As VtePtyFlags, _
'										 working_directory As const gchar Ptr, argv As gchar Ptr Ptr, envv As gchar Ptr Ptr, _
'										 spawn_flags As GSpawnFlags, child_setup As GSpawnChildSetupFunc, _
'										 child_setup_data As gpointer, child_pid As GPid Ptr, _
'										 cancellable As GCancellable Ptr, error As GError Ptr Ptr) As gboolean
''	void (*vte_terminal_set_size) (VteTerminal *terminal, glong columns, glong rows);
''	void (*vte_terminal_set_word_chars) (VteTerminal *terminal, const char *spec);
''	void (*vte_terminal_set_word_char_exceptions) (VteTerminal *terminal, const char *exceptions);
''	void (*vte_terminal_set_mouse_autohide) (VteTerminal *terminal, gboolean setting);
''	void (*vte_terminal_reset) (VteTerminal *terminal, gboolean full, gboolean clear_history);
'	vte_terminal_get_type As Function() As GType
''	void (*vte_terminal_set_scroll_on_output) (VteTerminal *terminal, gboolean scroll);
''	void (*vte_terminal_set_scroll_on_keystroke) (VteTerminal *terminal, gboolean scroll);
''	void (*vte_terminal_set_font) (VteTerminal *terminal, const PangoFontDescription *font_desc);
''	void (*vte_terminal_set_scrollback_lines) (VteTerminal *terminal, glong lines);
'	vte_terminal_get_has_selection As Function(terminal As VteTerminal Ptr) As gboolean
'	vte_terminal_copy_clipboard As Sub(terminal As VteTerminal Ptr)
'	vte_terminal_paste_clipboard As Sub(terminal As VteTerminal Ptr)
''	void (*vte_terminal_set_color_foreground) (VteTerminal *terminal, const GdkColor *foreground);
''	void (*vte_terminal_set_color_bold) (VteTerminal *terminal, const GdkColor *foreground);
''	void (*vte_terminal_set_color_background) (VteTerminal *terminal, const GdkColor *background);
''	void (*vte_terminal_feed_child) (VteTerminal *terminal, const char *data, glong length);
''	void (*vte_terminal_im_append_menuitems) (VteTerminal *terminal, GtkMenuShell *menushell);
''	void (*vte_terminal_set_cursor_blink_mode) (VteTerminal *terminal,
''												VteTerminalCursorBlinkMode mode);
''	void (*vte_terminal_set_cursor_blinks) (VteTerminal *terminal, gboolean blink);
''	void (*vte_terminal_select_all) (VteTerminal *terminal);
''	void (*vte_terminal_set_audible_bell) (VteTerminal *terminal, gboolean is_audible);
''	GtkAdjustment* (*vte_terminal_get_adjustment) (VteTerminal *terminal);
''#if GTK_CHECK_VERSION(3, 0, 0)
''	/* hack for the VTE 2.91 API using GdkRGBA: we wrap the API to keep using GdkColor on our side */
''	void (*vte_terminal_set_color_foreground_rgba) (VteTerminal *terminal, const GdkRGBA *foreground);
''	void (*vte_terminal_set_color_bold_rgba) (VteTerminal *terminal, const GdkRGBA *foreground);
''	void (*vte_terminal_set_color_background_rgba) (VteTerminal *terminal, const GdkRGBA *background);
''#endif
'End Type
'
''#Inclib "vte-2.91"
'
''Declare Function vte_terminal_new() As GtkWidget Ptr
'	'pid_t (*vte_terminal_fork_command) (VteTerminal *terminal, const char *command, char **argv,
'	'									char **envv, const char *directory, gboolean lastlog,
'	'									gboolean utmp, gboolean wtmp);
'	'gboolean (*vte_terminal_spawn_sync) (VteTerminal *terminal, VtePtyFlags pty_flags,
'	'									 const char *working_directory, char **argv, char **envv,
''										 GSpawnFlags spawn_flags, GSpawnChildSetupFunc child_setup,
'	'									 gpointer child_setup_data, GPid *child_pid,
'	'									 GCancellable *cancellable, GError **error);
'	'
'
'Dim Shared As GModule Ptr module = NULL
'Dim Shared As VteFunctions Ptr vf
'Dim Shared As GtkWidget Ptr vte
'Dim Shared As GtkWidget Ptr win
'
'Sub create_vte()
'	'Dim As GtkWidget Ptr vte, scrollbar, hbox
'	vte = vf->vte_terminal_new()
'	win = gtk_window_new(GTK_WINDOW_TOPLEVEL)
'	gtk_container_add(gtk_container(win), vte)
'
'	'vte = vf->vte_terminal_new()
'	'vc->vte = vte
'	'scrollbar = gtk_vscrollbar_new(vf->vte_terminal_get_adjustment(VTE_TERMINAL(vte)));
'	'gtk_widget_set_can_focus(scrollbar, FALSE);
'
'	'/* create menu now so copy/paste shortcuts work */
'	'vc->menu = vte_create_popup_menu();
'	'g_object_ref_sink(vc->menu);
'
'	'hbox = gtk_hbox_new(FALSE, 0);
'	'gtk_box_pack_start(GTK_BOX(hbox), vte, TRUE, TRUE, 0);
'	'gtk_box_pack_start(GTK_BOX(hbox), scrollbar, FALSE, FALSE, 0);
'
'	'/* set the default widget size first to prevent VTE expanding too much,
'	' * sometimes causing the hscrollbar to be too big or out of view. */
'	'gtk_widget_set_size_request(GTK_WIDGET(vte), 10, 10);
'	'vf->vte_terminal_set_size(VTE_TERMINAL(vte), 30, 1);
'
'	'vf->vte_terminal_set_mouse_autohide(VTE_TERMINAL(vte), TRUE);
'	'if (vf->vte_terminal_set_word_chars)
'	'	vf->vte_terminal_set_word_chars(VTE_TERMINAL(vte), VTE_WORDCHARS);
'	'else if (vf->vte_terminal_set_word_char_exceptions)
'	'	vf->vte_terminal_set_word_char_exceptions(VTE_TERMINAL(vte), VTE_ADDITIONAL_WORDCHARS);
'
'	'gtk_drag_dest_set(vte, GTK_DEST_DEFAULT_ALL,
'	'	dnd_targets, G_N_ELEMENTS(dnd_targets), GDK_ACTION_COPY);
'
'	'g_signal_connect(vte, "child-exited", G_CALLBACK(vte_start), NULL);
'	'g_signal_connect(vte, "button-press-event", G_CALLBACK(vte_button_pressed), NULL);
'	'g_signal_connect(vte, "event", G_CALLBACK(vte_keypress_cb), NULL);
'	'g_signal_connect(vte, "key-release-event", G_CALLBACK(vte_keyrelease_cb), NULL);
'	'g_signal_connect(vte, "commit", G_CALLBACK(vte_commit_cb), NULL);
'	'g_signal_connect(vte, "motion-notify-event", G_CALLBACK(on_motion_event), NULL);
'	'g_signal_connect(vte, "drag-data-received", G_CALLBACK(vte_drag_data_received), NULL);
'
'	'/* start shell on idle otherwise the initial prompt can get corrupted */
'	'g_idle_add(vte_start_idle, NULL);
'
'	'gtk_widget_show_all(hbox);
'	'terminal_label = gtk_label_new(_("Terminal"));
'	'gtk_notebook_insert_page(GTK_NOTEBOOK(msgwindow.notebook), hbox, terminal_label, MSG_VTE);
'
'	'g_signal_connect_after(vte, "realize", G_CALLBACK(on_vte_realize), NULL);
'End Sub
'
'
'Sub vte_close()
'	g_free(vf)
'	/' free the vte widget before unloading vte module
'	 * this prevents a segfault on X close window if the message window is hidden '/
'	gtk_widget_destroy(vc->vte)
'	gtk_widget_destroy(vc->menu)
'	g_object_unref(vc->menu)
'	g_free(vc->shell)
'	g_free(vc->font)
'	g_free(vc->send_cmd_prefix)
'	g_free(vc)
'	'g_free(gtk_menu_key_accel)
'	/' Don't unload the module explicitly because it causes a segfault on FreeBSD. The segfault
'	 * happens when the app really exits, not directly on g_module_close(). This still needs to
'	 * be investigated. '/
'	/'g_module_close(module); '/
'End Sub
'
'Function vte_register_symbols(mod1 As GModule Ptr) As gboolean
'	g_module_symbol(mod1, "vte_get_major_version", @vf->vte_get_major_version)
'	g_module_symbol(mod1, "vte_get_minor_version", @vf->vte_get_minor_version)
'	If Not g_module_symbol(mod1, "vte_terminal_new", @vf->vte_terminal_new) Then
'		'MsgBox "Not loaded vte_terminal_new"
'	End If
'	g_module_symbol(mod1, "vte_terminal_spawn_sync", @vf->vte_terminal_spawn_sync)
'	g_module_symbol(mod1, "vte_terminal_get_type", @vf->vte_terminal_get_type)
'	g_module_symbol(mod1, "vte_terminal_get_has_selection", @vf->vte_terminal_get_has_selection)
'	g_module_symbol(mod1, "vte_terminal_copy_clipboard", @vf->vte_terminal_copy_clipboard)
'	g_module_symbol(mod1, "vte_terminal_paste_clipboard", @vf->vte_terminal_paste_clipboard)
'	return TRUE
'End Function
'
'Sub vte_init()
'	'module = g_module_open(vte_info.lib_vte, G_MODULE_BIND_LAZY)
'	'if (module = NULL) Then
'		Dim As Integer i = 0
'		Dim As Const String sonames(15) = {"libvte-2.91.so", "libvte-2.91.so.0", "libvte2_90.so", "libvte2_90.so.9", "libvte.so", "libvte.so.9", "libvte.so.8", "libvte.so.4", ""}
'		Do While sonames(i) <> "" AndAlso module = NULL
'			module = g_module_open(toutf8(sonames(i)), G_MODULE_BIND_LAZY)
'			i = i + 1
'		Loop
'	'End If
'
'	if (module = NULL) Then
'		vte_info.have_vte = FALSE
'		MsgBox "Could not load libvte.so, embedded terminal support disabled"
'		return
'	else
'		vf = g_new0(VteFunctions, 1)
'		if (vte_register_symbols(module)) Then
'			vte_info.have_vte = TRUE
'		else
'			vte_info.have_vte = FALSE
'			g_free(vf)
'			/' FIXME: is closing the module safe? see vte_close() and test on FreeBSD */
'			/*g_module_close(module);'/
'			module = NULL
'			return
'		End If
'	End If
'
'	create_vte()
'
'End Sub
'
'vte_init
'
'Sub run_exit_cb(child_pid As GPid, status As gint, user_data As gpointer)
'
'	If child_pid > 0 Then g_spawn_close_pid(child_pid)
'	child_pid = 0
'	ShowMessages(Time & ": " & ML("Application finished. Returned code") & ": " & status & " - " & Err2Description(status))
'	#IfDef __USE_GTK3__
'		gtk_window_close(gtk_window(user_data))
'	#Else
'		gtk_widget_destroy(gtk_widget(user_data))
'	#EndIf
'
'End Sub
'
'Enum
'	POPUP_COPY
'	POPUP_PASTE
'End Enum
'
'Sub vte_popup_menu_clicked(menuitem As GtkMenuItem Ptr, user_data As gpointer)
'	Select Case (GPOINTER_TO_INT(user_data))
'		case POPUP_COPY:
'			if (vf->vte_terminal_get_has_selection(VTE_TERMINAL(vte))) Then
'				vf->vte_terminal_copy_clipboard(VTE_TERMINAL(vte))
'			End If
'		case POPUP_PASTE:
'			vf->vte_terminal_paste_clipboard(VTE_TERMINAL(vte))
'	End Select
'End Sub
'
'Function vte_create_popup_menu() As GtkWidget Ptr
'	Dim As GtkWidget Ptr menu, item
'
'	menu = gtk_menu_new()
'
'	item = gtk_menu_item_new_with_label(ToUTF8(ML("Copy")))
'	gtk_widget_show(item)
'	gtk_container_add(GTK_CONTAINER(menu), item)
'	g_signal_connect(item, "activate", G_CALLBACK(@vte_popup_menu_clicked), GINT_TO_POINTER(POPUP_COPY))
'
'	item = gtk_menu_item_new_with_label(ToUTF8(ML("Paste")))
'	gtk_widget_show(item)
'	gtk_container_add(GTK_CONTAINER(menu), item)
'	g_signal_connect(item, "activate", G_CALLBACK(@vte_popup_menu_clicked), GINT_TO_POINTER(POPUP_PASTE))
'
'	return menu
'End Function
'
'Dim Shared As GtkWidget Ptr vte_menu
'vte_menu = vte_create_popup_menu()
'
'Function vte_button_pressed(widget As GtkWidget Ptr, event1 As GdkEventButton Ptr, user_data As gpointer) As gboolean
'	if (event1->button = 3) Then
'		gtk_widget_grab_focus(widget)
'		vte = widget
'		gtk_menu_popup(gtk_menu(vte_menu), NULL, NULL, NULL, NULL, event1->button, event1->time)
'		return TRUE
'	elseif (event1->button = 2) Then
'		gtk_widget_grab_focus(widget)
'	End If
'	return FALSE
'End Function
'#EndIf

Function GetMainFile(bSaveTab As Boolean = False, ByRef Project As ProjectElement Ptr = 0, ByRef ProjectNode As TreeNode Ptr = 0, WithoutMainNode As Boolean = False, FromProject As Boolean = False) As UString
	Dim As TabWindow Ptr tb
	Dim As TreeNode Ptr Node = ProjectNode
	If FromProject AndAlso Project <> 0 Then Return *Project->MainFileName
	If Node = 0 Then Node = MainNode
	If Node <> 0 AndAlso Not WithoutMainNode Then
		Dim ee As ExplorerElement Ptr
		ee = Node->Tag
		If Node->ImageKey = "Project" OrElse ee AndAlso *ee Is ProjectElement Then
			ProjectNode = Node
			If ee Then Project = Cast(ProjectElement Ptr, ee)
			If ee AndAlso Project AndAlso WGet(Project->MainFileName) <> "" Then
				Return WGet(Project->MainFileName)
			Else
				MsgBox ML("Project Main File don't set")
			End If
		ElseIf ee = 0 OrElse ee->FileName = 0 OrElse *ee->FileName = "" Then
			For j As Integer = 0 To TabPanels.Count - 1
				Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
				For i As Integer = 0 To ptabCode->TabCount - 1
					tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
					If tb AndAlso tb->tn = Node Then
						If bSaveTab Then
							If tb->Modified Then tb->Save
						End If
						Return tb->FileName
					End If
				Next i
			Next j
		Else
			Return *ee->FileName
		End If
	Else
		tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb = 0 Then
			Dim As TreeNode Ptr tn
			If tvExplorer.SelectedNode = 0 Then
				If tvExplorer.Nodes.Count > 0 Then
					tn = tvExplorer.Nodes.Item(0)
				Else
					Return ""
				End If
			Else
				tn = tvExplorer.SelectedNode
			End If
			tn = GetParentNode(tn)
			If tn->ImageKey = "Project" OrElse tn->Tag <> 0 AndAlso *Cast(ExplorerElement Ptr, tn->Tag) Is ProjectElement Then
				ProjectNode = tn
				Dim As ExplorerElement Ptr ee = tn->Tag
				If ee Then Project = Cast(ProjectElement Ptr, ee)
				If ee AndAlso Project AndAlso Project->MainFileName <> 0 AndAlso *Project->MainFileName <> "" Then Return *Project->MainFileName
			End If
			Return ""
		Else
			If bSaveTab Then
				If tb->Modified Then tb->Save
			End If
			Var tn = tb->ptn
			If tn->ImageKey = "Project" OrElse tn->Tag <> 0 AndAlso *Cast(ExplorerElement Ptr, tn->Tag) Is ProjectElement Then
				ProjectNode = tn
				Dim As ExplorerElement Ptr ee = tn->Tag
				If ee Then Project = Cast(ProjectElement Ptr, ee)
				If ee AndAlso Project AndAlso Project->MainFileName <> 0 AndAlso *Project->MainFileName <> "" Then Return *Project->MainFileName
			End If
			Return tb->FileName
		End If
	End If
	Return ""
End Function

Function GetResourceFile(WithoutMainNode As Boolean = False, ByRef FirstLine As WString = "") As UString
	Dim As UString ResourceFile, MainFile, sFirstLine, CompileLine
	Dim As ProjectElement Ptr Project
	Dim As TreeNode Ptr ProjectNode
	MainFile = GetMainFile(, Project, ProjectNode, WithoutMainNode)
	If FirstLine = "" Then
		sFirstLine = GetFirstCompileLine(MainFile, Project, CompileLine, True)
	Else
		sFirstLine = FirstLine
	End If
	Dim As WString Ptr Buff, File, sLines
	ResourceFile = ""
	WLet(Buff, " " & Trim(sFirstLine & CompileLine, Any !"\t ") & " ")
	Dim As UString FolderName = GetFolderName(MainFile), FolderNameRes
	Dim QavsBoshi As Boolean
	Dim As String SearchSymbol = """"
	For i As Integer = 1 To 2
		If i = 2 Then SearchSymbol = " "
		Var Pos1 = InStr(*Buff, SearchSymbol), Pos2 = 1
		Do While Pos1 > 0
			QavsBoshi = Not QavsBoshi
			If QavsBoshi Then
				Pos2 = Pos1
			Else
				WLet(File, Mid(*Buff, Pos2 + 1, Pos1 - Pos2 - 1))
				If EndsWith(LCase(*File), ".rc") Then
					ResourceFile = *File
					FolderNameRes = GetFolderName(ResourceFile)
					If FolderNameRes = "" Then ResourceFile = IIf(FolderName = "", ExePath & Slash & "Projects" & Slash, FolderName) & ResourceFile
					Exit For
				End If
			End If
			If i = 2 Then QavsBoshi = True: Pos2 = Pos1
			Pos1 = InStr(Pos1 + 1, *Buff, SearchSymbol)
		Loop
	Next
	WDeAllocate(Buff)
	WDeAllocate(File)
	If FirstLine <> "" Then Return *ResourceFile.vptr
	If ResourceFile = "" Then
		Var Pos1 = InStrRev(MainFile, ".")
		ResourceFile = IIf(Pos1 = 0, MainFile & ".rc", ..Left(MainFile, Pos1 - 1) & ".rc")
		FolderNameRes = GetFolderName(ResourceFile)
		If FolderNameRes = "" Then ResourceFile = IIf(FolderName = "", ExePath & Slash & "Projects" & Slash, FolderName) & ResourceFile
	End If
	Return *ResourceFile.vptr
End Function

Sub Versioning(ByRef FileName As WString, ByRef sFirstLine As WString, ByRef Project As ProjectElement Ptr = 0, ByRef ProjectNode As TreeNode Ptr = 0)
	'If StartsWith(LTrim(LCase(sFirstLine), Any !"\t "), "'#compile ") Then
	Dim As WString Ptr Buff, File, sLines
	Dim As WString * 1024 sLine
	Var bAutoIncrement = CInt(AutoIncrement) OrElse CInt(Project AndAlso CInt(Project->AutoIncrementVersion))
	If Project <> 0 AndAlso bAutoIncrement Then
		Project->BuildVersion += 1
		If AutoSaveBeforeCompiling AndAlso ProjectNode <> 0 Then
			If AutoSaveBeforeCompiling = 1 Then
				If ProjectNode->ImageKey <> "Opened" Then SaveProject ProjectNode
			ElseIf AutoSaveBeforeCompiling = 2 Then
				SaveAll
			End If
		End If
	End If
	WLet(File, GetResourceFile(, sFirstLine))
	Var bFinded = False, bChanged = False
	Dim As String NewLine = ""
	If AutoCreateRC Then
		If *File <> "" Then
			If Not FileExists(*File) Then
				FileCopy ExePath & "/Templates/Files/Resource.rc", *File
			End If
			If Not FileExists(GetFolderName(FileName) & "Manifest.xml") Then
				FileCopy ExePath & "/Templates/Files/Manifest.xml", *GetFolderName(FileName).vptr & "Manifest.xml"
				ManifestIcoCopy = True
			End If
		End If
	End If
	If *File <> "" AndAlso FileExists(*File) Then
		Var Fn = FreeFile_
		If Open(*File For Input Encoding "utf-8" As #Fn) = 0 Then
			Dim As Integer iStartImages, MinResID
			Dim As String MinResName
			Dim As UString ResPath
			Var n = 0
			Var bChangeIcon = False
			Do Until EOF(Fn)
				Line Input #Fn, sLine
				n += 1
				bChanged = False
				If CInt(bAutoIncrement) AndAlso CInt(StartsWith(LCase(sLine), "#define ver_fileversion ")) Then
					If Project Then
						Var Pos3 = InStrRev(sLine, " ")
						If Pos3 > 0 Then
							WLet(sLines, *sLines & NewLine & ..Left(sLine, Pos3) & Project->MajorVersion & "," & Project->MinorVersion & "," & Project->RevisionVersion & "," & Project->BuildVersion)
							bChanged = True
							'									ThreadsEnter()
							'									If CInt(ProjectNode) AndAlso CInt(Not EndsWith(ProjectNode->Text, "*")) Then ProjectNode->Text &= "*"
							'									ThreadsLeave()
						End If
					Else
						Var Pos3 = InStrRev(sLine, ",")
						If Pos3 > 0 Then
							WLet(sLines, *sLines & NewLine & ..Left(sLine, Pos3) & Val(Mid(sLine, Pos3 + 1)) + 1)
							bChanged = True
						End If
					End If
				ElseIf CInt(bAutoIncrement) AndAlso CInt(StartsWith(LCase(sLine), "#define ver_fileversion_str ")) Then
					If Project Then
						Var Pos3 = InStr(sLine, """")
						If Pos3 > 0 Then
							WLet(sLines, *sLines & NewLine & ..Left(sLine, Pos3) & Project->MajorVersion & "." & Project->MinorVersion & "." & Project->RevisionVersion & "." & Project->BuildVersion & "\0""")
							bChanged = True
						End If
					Else
						Var Pos3 = InStrRev(sLine, ".")
						If Pos3 > 0 Then
							WLet(sLines, *sLines & NewLine & ..Left(sLine, Pos3) & Val(Mid(sLine, Pos3 + 1, Len(sLine) - Pos3 - 3)) + 1 & "\0""")
							bChanged = True
						End If
					End If
				ElseIf Project Then
					If StartsWith(LCase(sLine), "#define app_title_str ") Then
						Var Pos3 = InStr(sLine, """")
						If Pos3 > 0 Then
							WLet(sLines, *sLines & NewLine & ..Left(sLine, Pos3) & WGet(Project->ApplicationTitle) & "\0""")
							bChanged = True
						End If
					ElseIf StartsWith(LCase(sLine), "#define ver_companyname_str ") Then
						Var Pos3 = InStr(sLine, """")
						If Pos3 > 0 Then
							WLet(sLines, *sLines & NewLine & ..Left(sLine, Pos3) & WGet(Project->CompanyName) & "\0""")
							bChanged = True
						End If
					ElseIf StartsWith(LCase(sLine), "#define ver_filedescription_str ") Then
						Var Pos3 = InStr(sLine, """")
						If Pos3 > 0 Then
							WLet(sLines, *sLines & NewLine & ..Left(sLine, Pos3) & Replace(WGet(Project->FileDescription), "{ProjectDescription}", WGet(Project->ProjectDescription)) & "\0""")
							bChanged = True
						End If
					ElseIf StartsWith(LCase(sLine), "#define ver_internalname_str ") Then
						Var Pos3 = InStr(sLine, """")
						If Pos3 > 0 Then
							WLet(sLines, *sLines & NewLine & ..Left(sLine, Pos3) & WGet(Project->InternalName) & "\0""")
							bChanged = True
						End If
					ElseIf StartsWith(LCase(sLine), "#define ver_legalcopyright_str ") Then
						Var Pos3 = InStr(sLine, """")
						If Pos3 > 0 Then
							WLet(sLines, *sLines & NewLine & ..Left(sLine, Pos3) & WGet(Project->LegalCopyright) & "\0""")
							bChanged = True
						End If
					ElseIf StartsWith(LCase(sLine), "#define ver_legaltrademarks_str ") Then
						Var Pos3 = InStr(sLine, """")
						If Pos3 > 0 Then
							WLet(sLines, *sLines & NewLine & ..Left(sLine, Pos3) & WGet(Project->LegalTrademarks) & "\0""")
							bChanged = True
						End If
					ElseIf StartsWith(LCase(sLine), "#define ver_originalfilename_str ") Then
						Var Pos3 = InStr(sLine, """")
						If Pos3 > 0 Then
							WLet(sLines, *sLines & NewLine & ..Left(sLine, Pos3) & WGet(Project->OriginalFilename) & "\0""")
							bChanged = True
						End If
					ElseIf StartsWith(LCase(sLine), "#define ver_productname_str ") Then
						Var Pos3 = InStr(sLine, """")
						If Pos3 > 0 Then
							WLet(sLines, *sLines & NewLine & ..Left(sLine, Pos3) & Replace(WGet(Project->ProductName), "{ProjectName}", WGet(Project->ProjectName)) & "\0""")
							bChanged = True
						End If
					ElseIf StartsWith(LCase(sLine), "#define ver_productversion ") Then
						Var Pos3 = InStrRev(sLine, " ")
						If Pos3 > 0 Then
							WLet(sLines, *sLines & NewLine & ..Left(sLine, Pos3) & Project->MajorVersion & "," & Project->MinorVersion & "," & Project->RevisionVersion & ",0")
							bChanged = True
						End If
					ElseIf StartsWith(LCase(sLine), "#define ver_productversion_str ") Then
						Var Pos3 = InStr(sLine, """")
						If Pos3 > 0 Then
							WLet(sLines, *sLines & NewLine & ..Left(sLine, Pos3) & Project->MajorVersion & "." & Project->MinorVersion & "." & Project->RevisionVersion & "\0""")
							bChanged = True
						End If
					ElseIf Project AndAlso LCase(Trim(*Project->ApplicationIcon)) <> "a" AndAlso Trim(*Project->ApplicationIcon) <> "" AndAlso (InStr(LCase(sLine), " icon ") OrElse InStr(LCase(sLine), " bitmap ") OrElse InStr(LCase(sLine), " png ") OrElse InStr(LCase(sLine), " cursor ") OrElse InStr(LCase(sLine), " rcdata ")) Then
						If iStartImages = 0 Then iStartImages = n
						If InStr(LCase(sLine), " icon ") Then
							Dim As Integer Pos1
							Dim As String ResNameOrID
							Pos1 = InStr(LTrim(sLine, Any !"\t "), " ")
							If Pos1 > 0 Then
								ResNameOrID = Trim(..Left(LTrim(sLine, Any !"\t "), Pos1 - 1), Any !"\t ")
								If isNumeric(ResNameOrID) Then
									If MinResID = 0 OrElse MinResID > Val(ResNameOrID) Then MinResID = Val(ResNameOrID)
								Else
									If MinResName = "" OrElse LCase(MinResName) > LCase(ResNameOrID) Then MinResName = ResNameOrID
								End If
								If LCase(ResNameOrID) = Trim(LCase(*Project->ApplicationIcon)) Then ResPath = Mid(LTrim(sLine, Any !"\t "), Pos1)
								If LCase(ResNameOrID) = "a" Then
									bChanged = True
									n -= 1
								End If
							End If
						End If
					ElseIf StartsWith(LCase(sLine), "1 24 ") AndAlso Project->Manifest = False Then
						WLet(sLines, *sLines & NewLine & "//" & sLine)
						bChanged = True
					ElseIf StartsWith(LCase(sLine), "//1 24 ") AndAlso Project->Manifest Then
						WLet(sLines, *sLines & NewLine & Mid(sLine, 3))
						bChanged = True
					End If
				End If
				If bChanged Then
					bFinded = True
				Else
					WLet(sLines, *sLines & NewLine & sLine)
				End If
				If n = 1 Then NewLine = WChr(13) & WChr(10)
			Loop
			If Project AndAlso LCase(Trim(*Project->ApplicationIcon)) <> "a" AndAlso Trim(*Project->ApplicationIcon) <> "" Then
				If isNumeric(*Project->ApplicationIcon) Then
					If MinResName <> "" OrElse (MinResID <> 0 AndAlso Val(*Project->ApplicationIcon) > MinResID) Then
						bChangeIcon = True
						bFinded = True
					End If
				ElseIf LCase(*Project->ApplicationIcon) > LCase(MinResName) Then
					bChangeIcon = True
					bFinded = True
				End If
			End If
			If bFinded Then
				Var Fn2 = FreeFile_
				If Open(*File For Output Encoding "utf-8" As #Fn2) = 0 Then
					Print #Fn2, *sLines;
					If bChangeIcon AndAlso ResPath <> "" Then Print #Fn2, Chr(13, 10) & "A" & ResPath
				End If
				CloseFile_(Fn2)
			End If
		End If
		CloseFile_(Fn)
	End If
	Var Fn = FreeFile_
	bFinded = False
	WLet(sLines, "")
	If Open(GetFolderName(*File) & "Manifest.xml" For Input Encoding "utf-8" As #Fn) = 0 Then
		Do Until EOF(Fn)
			Line Input #Fn, sLine
			bChanged = False
			If Project Then
				If StartsWith(LCase(sLine), "                <!-- <requestedexecutionlevel level=""requireadministrator"" uiaccess=""false"" /> -->") AndAlso Project->RunAsAdministrator Then
					WLet(sLines, *sLines & NewLine & "                <requestedExecutionLevel level=""requireAdministrator"" uiAccess=""false"" />")
					bChanged = True
				ElseIf StartsWith(LCase(sLine), "                <requestedexecutionlevel level=""requireadministrator"" uiaccess=""false"" />") AndAlso Project->RunAsAdministrator = False Then
					WLet(sLines, *sLines & NewLine & "                <!-- <requestedExecutionLevel level=""requireAdministrator"" uiAccess=""false"" /> -->")
					bChanged = True
				End If
			End If
			If bChanged Then
				bFinded = True
			Else
				WLet(sLines, *sLines & NewLine & sLine)
			End If
		Loop
		If bFinded Then
			Var Fn2 = FreeFile_
			If Open(GetFolderName(*File) & "Manifest.xml" For Output Encoding "utf-8" As #Fn2) = 0 Then
				Print #Fn2, *sLines;
			End If
			CloseFile_(Fn2)
		End If
	End If
	CloseFile_(Fn)
	If Buff Then _Deallocate( Buff)
	If File Then _Deallocate( File)
	If sLines Then _Deallocate( sLines)
	'End If
End Sub

Function CheckCondition(ByRef sLine As WString, ForWindows As Boolean) As Boolean
	If StartsWith(sLine, "not ") Then
		Return Not CheckCondition(Mid(sLine, 5), ForWindows)
	Else
		Select Case sLine
		Case "__fb_win32__", "defined(__fb_win32__)"
			If ForWindows Then
				Return True
			Else
				#ifdef __FB_WIN32__
					Return True
				#else
					Return False
				#endif
			End If
		Case "__fb_linux__", "defined(__fb_linux__)"
			#ifdef __FB_LINUX__
				Return True
			#else
				Return False
			#endif
		Case "__fb_main__", "defined(__fb_main__)"
			Return True
		Case "__fb_64bit__", "defined(__fb_64bit__)"
			Return tbt64Bit->Checked
		Case "__use_winapi__", "defined(__use_winapi__)"
			Return InStr(LCase(UseDefine), "__use_winapi__") > 0
		Case "__use_gtk2__", "defined(__use_gtk2__)"
			Return InStr(LCase(UseDefine), "__use_gtk2__") > 0
		Case "__use_gtk3__", "defined(__use_gtk3__)"
			Return InStr(LCase(UseDefine), "__use_gtk3__") > 0
		Case "__use_gtk4__", "defined(__use_gtk4__)"
			Return InStr(LCase(UseDefine), "__use_gtk4__") > 0
		Case "__use_gtk__", "defined(__use_gtk__)"
			Return InStr(LCase(UseDefine), "__use_gtk__") > 0
		Case Else
			Return False
		End Select
	End If
End Function

Function CheckExpression(ByRef sLine As WString, ForWindows As Boolean) As Boolean
	Dim As UString resultOrElse()
	Split(sLine, " orelse ", resultOrElse())
	Dim As Boolean bOrElse
	For i As Integer = 0 To UBound(resultOrElse)
		Dim As UString resultAndAlso()
		Dim As UString item = Trim(resultOrElse(i))
		Split(item, " andalso ", resultAndAlso())
		Dim As Boolean bAndAlso
		For j As Integer = 0 To UBound(resultAndAlso)
			Dim As UString item = Trim(resultAndAlso(j))
			If j = 0 Then
				bAndAlso = CheckCondition(item, ForWindows)
			Else
				bAndAlso = bAndAlso AndAlso CheckCondition(item, ForWindows)
			End If
		Next
		If i = 0 Then
			bOrElse = bAndAlso
		Else
			bOrElse = bOrElse OrElse bAndAlso
		End If
	Next
	Return bOrElse
End Function

Function GetFirstCompileLine(ByRef FileName As WString, ByRef Project As ProjectElement Ptr, CompileLine As UString, ForWindows As Boolean = False) As UString
	Dim As Boolean Bit32 = tbt32Bit->Checked
	Dim As UString Result
	CompileLine = ""
	Result = IIf(Bit32, *Compiler32Arguments, *Compiler64Arguments)
	If Project Then
		If ForWindows Then
			Result += " " & IIf(Bit32, *Project->CompilationArguments32Windows, WGet(Project->CompilationArguments64Windows))
		Else
			#ifdef __USE_GTK__
				Result += " " & IIf(Bit32, *Project->CompilationArguments32Linux, WGet(Project->CompilationArguments64Linux))
			#else
				Result += " " & IIf(Bit32, *Project->CompilationArguments32Windows, WGet(Project->CompilationArguments64Windows))
			#endif
		End If
		Select Case Project->ProjectType
		Case 0
		Case 1: Result += " -dll"
		Case 2: Result += " -lib"
		End Select
	End If
	If InStr(Result, " -s ") = 0 Then
		If CInt(tbtConsole->Checked) Then
			Result += " -s console"
		ElseIf CInt(tbtGUI->Checked) Then
			Result += " -s gui"
		End If
	End If
	If CInt(UseDebugger) OrElse CInt(CInt(Project) AndAlso CInt(Project->CreateDebugInfo)) Then Result += " -g"
	If CInt(InStr(Result, " -v ") = 0)  Then
		Result += " -v "
	End If
	If Project Then
		If InStr(Result, " -s ") = 0 Then
			Select Case Project->Subsystem
			Case 0
			Case 1: Result += " -s console"
			Case 2: Result += " -s gui"
			End Select
		End If
		If Project->CompileTo = ToGAS Then
			Result += " -gen gas" & IIf(Not Bit32, "64", "")
		ElseIf Project->CompileTo = ToLLVM Then
			Result += " -gen llvm"
		ElseIf Project->CompileTo = ToGCC Then
			Result += " -gen gcc" & IIf(Project->OptimizationLevel > 0, " -Wc -O" & WStr(Project->OptimizationLevel), IIf(Project->OptimizationFastCode, " -Wc -Ofast", IIf(Project->OptimizationSmallCode, " -Wc -Os", ""))) & _
			IIf(Project->ShowUnusedLabelWarnings, " -Wc -Wunused-label", "") & IIf(Project->ShowUnusedFunctionWarnings, " -Wc -Wunused-function", "") & IIf(Project->ShowUnusedVariableWarnings, " -Wc -Wunused-variable", "") & _
			IIf(Project->ShowUnusedButSetVariableWarnings, " -Wc -Wunused-but-set-variable", "") & IIf(Project->ShowMainWarnings, " -Wc -Wmain", "")
		End If
	End If
	If UseDefine <> "" Then Result += " -d " & UseDefine
	Dim As Integer LinesCount, d, Fn
	Dim As Boolean bFromTab
	Dim As TabWindow Ptr tb
	Var FileOpenResult = -1
	If FileName = ML("Untitled") Then
		tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb <> 0 Then
			FileOpenResult = 0
			bFromTab = True
			LinesCount = tb->txtCode.LinesCount
		End If
	Else
		Fn = FreeFile_
		FileOpenResult = Open(FileName For Input Encoding "utf-8" As #Fn)
		If FileOpenResult <> 0 Then FileOpenResult = Open(FileName For Input As #Fn)
	End If
	If FileOpenResult = 0 Then
		Dim As WString * 1024 sLine
		Dim As Integer i, n, l = 0
		Dim As Boolean k(10), kIfElseIf(10)
		k(l) = True
		kIfElseIf(l) = True
		Do Until IIf(bFromTab, d = LinesCount, EOF(Fn))
			If bFromTab Then
				sLine = tb->txtCode.Lines(d)
				d = d + 1
			Else
				Line Input #Fn, sLine
			End If
			If StartsWith(LTrim(LCase(sLine), Any !"\t "), "'") AndAlso Not StartsWith(LTrim(LCase(sLine), Any !"\t "), "'#compile ") Then
				Continue Do
			ElseIf StartsWith(LTrim(LCase(sLine), Any !"\t "), "#if ") Then
				l = l + 1
				k(l) = CheckExpression(Mid(LTrim(LCase(sLine), Any !"\t "), 5), ForWindows)
				kIfElseIf(l) = k(l)
			ElseIf StartsWith(LTrim(LCase(sLine), Any !"\t "), "#ifdef ") Then
				l = l + 1
				k(l) = CheckExpression(Mid(LTrim(LCase(sLine), Any !"\t "), 8), ForWindows)
				kIfElseIf(l) = k(l)
			ElseIf StartsWith(LTrim(LCase(sLine), Any !"\t "), "#ifndef ") Then
				l = l + 1
				k(l) = Not CheckExpression(Mid(LTrim(LCase(sLine), Any !"\t "), 9), ForWindows)
				kIfElseIf(l) = k(l)
			ElseIf StartsWith(LTrim(LCase(sLine), Any !"\t "), "#elseif ") Then
				k(l) = CheckExpression(Mid(LTrim(LCase(sLine), Any !"\t "), 9), ForWindows)
				kIfElseIf(l) = kIfElseIf(l) OrElse k(l)
			ElseIf StartsWith(LTrim(LCase(sLine), Any !"\t "), "#else") Then
				k(l) = Not kIfElseIf(l)
			ElseIf StartsWith(LTrim(LCase(sLine), Any !"\t "), "#endif") Then
				l = l - 1
				If l < 0 Then Exit Do
			Else
				For i = 0 To l
					If k(i) = False Then Exit For
				Next
				If i > l Then
					If StartsWith(LTrim(LCase(sLine), Any !"\t "), "'#compile ") Then
						Result = Result & " " & Mid(LTrim(sLine, Any !"\t "), 11)
					ElseIf StartsWith(LTrim(LCase(sLine), Any !"\t "), "#cmdline ") Then
						CompileLine = CompileLine & " " & WithoutQuotes(Trim(Mid(Trim(sLine, Any !"\t "), 10), Any !"\t "))
					End If
					'Exit Do
				End If
			End If
			If l >= 10 Then Exit Do
		Loop
	End If
	If Not bFromTab Then
		CloseFile_(Fn)
	End If
	If Project Then
		Dim As UString ResourceFileName
		If ForWindows Then
			If WGet(Project->ResourceFileName) <> "" Then ResourceFileName = GetShortFileName(WGet(Project->ResourceFileName), FileName)
		Else
			#ifdef __FB_WIN32__
				If WGet(Project->ResourceFileName) <> "" Then ResourceFileName = GetShortFileName(WGet(Project->ResourceFileName), FileName)
			#else
				If WGet(Project->IconResourceFileName) <> "" Then ResourceFileName = GetShortFileName(WGet(Project->IconResourceFileName), FileName)
			#endif
		End If
		If ResourceFileName <> "" Then 'AndAlso InStr(Result & CompileLine, ResourceFileName) = 0
			Result += " """ & ResourceFileName & """"
		End If
	End If
	Return Result
End Function

Sub RunEmulator(Param As Any Ptr)
	#ifndef __USE_GTK__
		Dim As WString Ptr SdkDir = Param
		Dim As WString Ptr Workdir, CmdL
		Dim As UString AvdName
		#define BufferSize 2048
		If Not FileExists(*SdkDir & "\emulator\emulator.exe") Then
			ShowMessages ML("File not found") & ": " & *SdkDir & "\emulator\emulator.exe", False
			Exit Sub
		End If
		For i As Integer = 0 To 1
			Select Case i
			Case 0: WLet(CmdL, *SdkDir & "\emulator\emulator.exe -list-avds")
			Case 1: WLet(CmdL, *SdkDir & "\emulator\emulator.exe -avd " & AvdName)
			End Select
			If i = 1 Then
				ShowMessages ML("Run AVD:") & " " & AvdName & "", False
			End If
			Dim si As STARTUPINFO
			Dim pi As PROCESS_INFORMATION
			Dim sa As SECURITY_ATTRIBUTES
			Dim hReadPipe As HANDLE
			Dim hWritePipe As HANDLE
			Dim sBuffer As ZString * BufferSize
			Dim sOutput As UString
			Dim bytesRead As DWORD
			Dim result_ As Integer
			Dim Buff As WString * 2048
			
			sa.nLength = SizeOf(SECURITY_ATTRIBUTES)
			sa.lpSecurityDescriptor = NULL
			sa.bInheritHandle = True
			
			If CreatePipe(@hReadPipe, @hWritePipe, @sa, 0) = 0 Then
				ShowMessages(ML("Error: Couldn't Create Pipe"), False)
				Exit For
			End If
			
			si.cb = Len(STARTUPINFO)
			si.dwFlags = STARTF_USESTDHANDLES Or STARTF_USESHOWWINDOW
			si.hStdOutput = hWritePipe
			si.hStdError = hWritePipe
			si.wShowWindow = 0
			
			If CreateProcess(0, CmdL, @sa, @sa, 1, NORMAL_PRIORITY_CLASS, 0, 0, @si, @pi) = 0 Then
				ShowMessages(ML("Error: Couldn't Create Process"), False)
				Exit For
			End If
			
			CloseHandle hWritePipe
			
			Dim As Integer Pos1
			Do
				result_ = ReadFile(hReadPipe, @sBuffer, BufferSize, @bytesRead, ByVal 0)
				sBuffer = Left(sBuffer, bytesRead)
				Pos1 = InStrRev(sBuffer, Chr(10))
				If Pos1 > 0 Then
					Dim res() As UString
					sOutput += Left(sBuffer, Pos1 - 1)
					Split sOutput, Chr(10), res()
					For j As Integer = 0 To UBound(res)
						Buff = res(j)
						If i = 0 Then
							AvdName = Buff
							If EndsWith(AvdName, Chr(13)) Then
								AvdName = Left(AvdName, Len(AvdName) - 1)
							End If
							Exit Do
						Else
							ShowMessages(Buff, False)
						End If
					Next j
					sOutput = Mid(sBuffer, Pos1 + 1)
				Else
					sOutput += sBuffer
				End If
			Loop While result_
			
			CloseHandle pi.hProcess
			CloseHandle pi.hThread
			CloseHandle hReadPipe
			If AvdName = "" Then
				ShowMessages(ML("Install AVD!"), False)
				Exit For
			End If
		Next
		WDeAllocate(CmdL)
	#endif
End Sub

Sub RunLogCat(Param As Any Ptr)
	#ifndef __USE_GTK__
		Dim As WString Ptr SdkDir = Param
		Dim As WString Ptr Workdir, CmdL
		#define BufferSize 2048
		If Not FileExists(*SdkDir & "\platform-tools\adb.exe") Then
			ShowMessages ML("File not found") & ": " & *SdkDir & "\platform-tools\adb.exe", False
			Exit Sub
		End If
		For i As Integer = 0 To 1
			Select Case i
			Case 0: WLet(CmdL, *SdkDir & "\platform-tools\adb logcat -c")
			Case 1: WLet(CmdL, *SdkDir & "\platform-tools\adb logcat")
			End Select
			Dim si As STARTUPINFO
			Dim pi As PROCESS_INFORMATION
			Dim sa As SECURITY_ATTRIBUTES
			Dim hReadPipe As HANDLE
			Dim hWritePipe As HANDLE
			Dim sBuffer As ZString * BufferSize
			Dim sOutput As UString
			Dim bytesRead As DWORD
			Dim result_ As Integer
			Dim Buff As WString * 2048
			
			sa.nLength = SizeOf(SECURITY_ATTRIBUTES)
			sa.lpSecurityDescriptor = NULL
			sa.bInheritHandle = True
			
			If CreatePipe(@hReadPipe, @hWritePipe, @sa, 0) = 0 Then
				ShowMessages(ML("Error: Couldn't Create Pipe"), False)
				Exit For
			End If
			
			si.cb = Len(STARTUPINFO)
			si.dwFlags = STARTF_USESTDHANDLES Or STARTF_USESHOWWINDOW
			si.hStdOutput = hWritePipe
			si.hStdError = hWritePipe
			si.wShowWindow = 0
			
			If CreateProcess(0, CmdL, @sa, @sa, 1, NORMAL_PRIORITY_CLASS, 0, 0, @si, @pi) = 0 Then
				ShowMessages(ML("Error: Couldn't Create Process"), False)
				Exit For
			End If
			
			CloseHandle hWritePipe
			
			Dim As Integer Pos1
			Do
				result_ = ReadFile(hReadPipe, @sBuffer, BufferSize, @bytesRead, ByVal 0)
				sBuffer = Left(sBuffer, bytesRead)
				Pos1 = InStrRev(sBuffer, Chr(10))
				If Pos1 > 0 Then
					Dim res() As UString
					sOutput += Left(sBuffer, Pos1 - 1)
					Split sOutput, Chr(10), res()
					For j As Integer = 0 To UBound(res)
						Buff = res(j)
						If InStr(Buff, "DEBUG") Then
							ShowMessages(Buff, False)
						End If
					Next j
					sOutput = Mid(sBuffer, Pos1 + 1)
				Else
					sOutput += sBuffer
				End If
			Loop While result_
			
			CloseHandle pi.hProcess
			CloseHandle pi.hThread
			CloseHandle hReadPipe
		Next
		WDeAllocate(CmdL)
	#endif
End Sub

Sub RunPr(Debugger As String = "")
	On Error Goto ErrorHandler
	Dim Result As Integer
	Dim As ProjectElement Ptr Project
	Dim As TreeNode Ptr ProjectNode
	Dim As UString CompileLine, MainFile = GetMainFile(, Project, ProjectNode)
	Dim As UString FirstLine = GetFirstCompileLine(MainFile, Project, CompileLine)
	Dim ExeFileName As WString Ptr
	If CBool(Project <> 0) AndAlso (Not EndsWith(*Project->FileName, ".vfp")) AndAlso FileExists(*Project->FileName & "/local.properties") Then
		Dim As String ApkFileName = *Project->FileName & "/app/build/outputs/apk/debug/app-debug.apk"
		If Not FileExists(ApkFileName) Then
			ShowMessages ML("Do not found apk file!")
			Exit Sub
		End If
		Dim As Integer Fn = FreeFile_
		Open *Project->FileName & "/local.properties" For Input As #Fn
		Dim SDKDir As UString
		Dim pBuff As WString Ptr
		Dim As Integer FileSize
		FileSize = LOF(Fn)
		WReAllocate(pBuff, FileSize)
		Do Until EOF(Fn)
			LineInputWstr Fn, pBuff, FileSize
			If StartsWith(*pBuff, "sdk.dir=") Then
				SDKDir = Replace(Replace(Mid(*pBuff, 9), "\\", "\"), "\:", ":")
				Exit Do
			End If
		Loop
		CloseFile_(Fn)
		If SDKDir = "" Then
			ShowMessages ML("Sdk.dir not specified in file local.properties!")
			Exit Sub
		End If
		If Not FileExists(*Project->FileName & "/app/build.gradle") Then
			ShowMessages ML("File") & " " & *Project->FileName & "/app/build.gradle " & ML("not found") & "!"
			Exit Sub
		End If
		Fn = FreeFile_
		Open *Project->FileName & "/app/build.gradle" For Input As #Fn
		Dim applicationId As String
		FileSize = LOF(Fn)
		WReAllocate(pBuff, FileSize)
		Do Until EOF(Fn)
			LineInputWstr Fn, pBuff, FileSize
			If StartsWith(Trim(*pBuff), "applicationId ") Then
				applicationId = Left(Mid(Trim(*pBuff), 16), Len(Mid(Trim(*pBuff), 16)) - 1)
				Exit Do
			End If
		Loop
		CloseFile_(Fn)
		If applicationId = "" Then
			ShowMessages ML("applicationId not found in file app/build.gradle!")
			Exit Sub
		End If
		Dim As WString Ptr Workdir, CmdL
		WLet(ExeFileName, SDKDir & "\platform-tools\adb")
		WLet(CmdL, SDKDir & "\platform-tools\adb uninstall " & applicationId)
		WLet(Workdir, SDKDir & "\platform-tools")
		#ifdef __USE_WINAPI__
			If Not FileExists(SDKDir & "\platform-tools\adb.exe") Then
				ShowMessages ML("File not found") & ": " & SDKDir & "\platform-tools\adb.exe", False
				Exit Sub
			End If
			For i As Integer = 0 To 2
				#define BufferSize 2048
				Select Case i
				Case 0: WLet(CmdL, SDKDir & "\platform-tools\adb uninstall " & applicationId)
				Case 1: WLet(CmdL, SDKDir & "\platform-tools\adb install -t " & ApkFileName)
				Case 2: WLet(CmdL, SDKDir & "\platform-tools\adb shell am start " & applicationId & "/" & applicationId & ".mffActivity")
				End Select
				Dim si As STARTUPINFO
				Dim pi As PROCESS_INFORMATION
				Dim sa As SECURITY_ATTRIBUTES
				Dim hReadPipe As HANDLE
				Dim hWritePipe As HANDLE
				Dim sBuffer As ZString * BufferSize
				Dim sOutput As UString
				Dim bytesRead As DWORD
				Dim result_ As Integer
				Dim Buff As WString * 2048
				
				sa.nLength = SizeOf(SECURITY_ATTRIBUTES)
				sa.lpSecurityDescriptor = NULL
				sa.bInheritHandle = True
				
				If CreatePipe(@hReadPipe, @hWritePipe, @sa, 0) = 0 Then
					ShowMessages(ML("Error: Couldn't Create Pipe"), False)
					Exit For
				End If
				
				si.cb = Len(STARTUPINFO)
				si.dwFlags = STARTF_USESTDHANDLES Or STARTF_USESHOWWINDOW
				si.hStdOutput = hWritePipe
				si.hStdError = hWritePipe
				si.wShowWindow = 0
				
				If CreateProcess(0, CmdL, @sa, @sa, 1, NORMAL_PRIORITY_CLASS, 0, 0, @si, @pi) = 0 Then
					ShowMessages(ML("Error: Couldn't Create Process"), False)
					Exit For
				End If
				
				CloseHandle hWritePipe
				
				Dim As Integer Pos1
				Do
					result_ = ReadFile(hReadPipe, @sBuffer, BufferSize, @bytesRead, ByVal 0)
					sBuffer = Left(sBuffer, bytesRead)
					Pos1 = InStrRev(sBuffer, Chr(10))
					If Pos1 > 0 Then
						Dim res() As UString
						sOutput += Left(sBuffer, Pos1 - 1)
						Split sOutput, Chr(10), res()
						For j As Integer = 0 To UBound(res)
							Buff = res(j)
							ShowMessages(Buff, False)
							If StartsWith(Buff, "- waiting for device -") Then
								ThreadCreate_(@RunEmulator, SDKDir.vptr)
								ThreadCreate_(@RunLogCat, SDKDir.vptr)
							End If
						Next j
						sOutput = Mid(sBuffer, Pos1 + 1)
					Else
						sOutput += sBuffer
					End If
				Loop While result_
				
				CloseHandle pi.hProcess
				CloseHandle pi.hThread
				CloseHandle hReadPipe
			Next
		#endif
		If Workdir Then _Deallocate( Workdir)
		If CmdL Then _Deallocate(CmdL)
	Else
		WLet(ExeFileName, (GetExeFileName(MainFile, CompileLine & " " & FirstLine)))
		#ifdef __USE_GTK__
			Dim As GPid pid = 0
			'		Dim As GtkWidget Ptr win, vte
			'		win = gtk_window_new(gtk_window_toplevel)
			'		If vf->vte_terminal_new <> 0 Then
			'			vte = vf->vte_terminal_new()
			'			g_signal_connect(vte, "button-press-event", G_CALLBACK(@vte_button_pressed), NULL)
			'			gtk_container_add(gtk_container(win), vte)
			'			'Dim As gint i_retcode = 0, i_exitcode = 0
			'			Dim As gchar Ptr Ptr argv = g_strsplit(ToUTF8(build_create_shellscript(GetFolderName(*ExeFileName), *ExeFileName, False)), " ", -1)
			'			gtk_widget_show_all(win)
			'			Dim As GError Ptr error1
			'			vf->vte_terminal_spawn_sync(vte_terminal(vte), VTE_PTY_DEFAULT, ToUTF8(GetFolderName(*ExeFileName)), argv, NULL, G_SPAWN_SEARCH_PATH Or G_SPAWN_DO_NOT_REAP_CHILD, NULL, NULL, @pid, NULL, @error1)
			'	    	If pid > 0 Then
			'	    		g_child_watch_add(pid, @run_exit_cb, win)
			'	    	Else
			'				m *error1->message
			'	    		run_exit_cb(pid, 0, win)
			'	    	End If
			'	    Else
			Dim As WString Ptr Arguments
			WLet(Arguments, *RunArguments)
			If Project Then WLet(Arguments, *Arguments & " " & WGet(Project->CommandLineArguments))
			If 0 Then
				Result = Shell("""" & WGet(TerminalPath) & """ --wait -- """ & build_create_shellscript(GetFolderName(*ExeFileName), *ExeFileName, False, , *Arguments) & """")
			Else
				ChDir(GetFolderName(*ExeFileName))
				Dim As UString CommandLine
				If EndsWith(*ExeFileName, ".html") Then
					CommandLine = "http://localhost:8000/" & GetFileName(*ExeFileName)
				Else
					Dim As ToolType Ptr Tool
					Dim As Integer Idx = pTerminals->IndexOfKey(*CurrentTerminal)
					If Idx <> - 1 Then
						Tool = pTerminals->Item(Idx)->Object
						CommandLine = Tool->GetCommand(Trim(Replace(*ExeFileName, "\", "/") & IIf(*Arguments = "", "", " " & *Arguments)))
						#ifndef __FB_WIN32__
							If Tool->Parameters = "" Then CommandLine &= " --wait -- "
						#endif
					Else
						CommandLine &= """" & Trim(Replace(*ExeFileName, "\", "/") & IIf(*Arguments = "", "", " " & *Arguments)) & """"
					End If
				End If
				ThreadsEnter()
				ShowMessages(Time & ": " & ML("Run") & ": " & CommandLine + " ...")
				ThreadsLeave()
				Result = Shell(CommandLine)
			End If
			WDeAllocate Arguments
			ThreadsEnter()
			ShowMessages(Time & ": " & ML("Application finished. Returned code") & ": " & Result & " - " & Err2Description(Result))
			ThreadsLeave()
			'EndIf
			'i_retcode = g_spawn_command_line_sync(ToUTF8(build_create_shellscript(GetFolderName(*ExeFileName), *ExeFileName, False)), NULL, NULL, @i_exitcode, NULL)
			'?build_create_shellscript(GetFolderName(*ExeFileName), *ExeFileName, False)
			'Shell "sh " & build_create_shellscript(GetFolderName(*ExeFileName), *ExeFileName, False)
		#else
			Dim As Integer pClass
			Dim As WString Ptr Workdir, CmdL
			Dim As ULong ExitCode 
			If EndsWith(*ExeFileName, ".html") Then
				WLet(*CmdL, "explorer http://localhost:8000/" & GetFileName(*ExeFileName))
			Else
				WLet(CmdL, """" & *ExeFileName & """ " & *RunArguments)
				If Project Then WLetEx CmdL, *CmdL & " " & WGet(Project->CommandLineArguments), True
				Var Pos1 = InStrRev(*ExeFileName, Slash)
				If Pos1 = 0 Then Pos1 = Len(*ExeFileName)
				WLet(Workdir, Left(*ExeFileName, Pos1))
				'			If WGet(TerminalPath) <> "" Then
				'				WLet CmdL, """" & WGet(TerminalPath) & """ /K ""cd /D """ & *Workdir & """ & " & *CmdL & """"
				'				wLet ExeFileName, Replace(WGet(TerminalPath), BackSlash, Slash)
				'			End If
				If WGet(TerminalPath) <> "" Then
					Dim As ToolType Ptr Tool
					Dim As Integer Idx = pTerminals->IndexOfKey(*CurrentTerminal)
					If Idx <> - 1 Then
						Tool = pTerminals->Item(Idx)->Object
						WLet(CmdL, Tool->GetCommand(*ExeFileName) & " " & *RunArguments)
					End If
					'WLetEx CmdL, " /K ""cd /D """ & *Workdir & """ & " & *CmdL & """", True
					WLet(ExeFileName, Replace(WGet(TerminalPath), BackSlash, Slash))
				End If
			End If
			ShowMessages(Time & ": " & ML("Run") & ": " & *CmdL + " ...")
			If InStr(FirstLine & CompileLine, "-s gui") Then
				#define BufferSize 2048
				Dim si As STARTUPINFO
				Dim pi As PROCESS_INFORMATION
				Dim sa As SECURITY_ATTRIBUTES
				Dim hReadPipe As HANDLE
				Dim hWritePipe As HANDLE
				Dim sBuffer As ZString * BufferSize
				Dim sOutput As WString * BufferSize
				Dim bytesRead As DWORD
				Dim As Integer result1, nPos, nPos1
				sa.nLength = SizeOf(SECURITY_ATTRIBUTES)
				sa.lpSecurityDescriptor = NULL
				sa.bInheritHandle = True
				
				If CreatePipe(@hReadPipe, @hWritePipe, @sa, 0) = 0 Then
					ShowMessages(ML("Error: Couldn't Create Pipe"), False)
					If Workdir Then _Deallocate(Workdir)
					If CmdL Then _Deallocate(CmdL)
					ChangeEnabledDebug True, False, False
					Exit Sub
				End If
				
				si.cb = Len(STARTUPINFO)
				si.dwFlags = STARTF_USESTDHANDLES Or STARTF_USESHOWWINDOW
				si.hStdOutput = hWritePipe
				si.hStdError = hWritePipe
				si.wShowWindow = SW_SHOW
				pClass = NORMAL_PRIORITY_CLASS Or CREATE_UNICODE_ENVIRONMENT Or CREATE_NEW_CONSOLE
				ChDir(GetFolderName(*ExeFileName))
				If CreateProcess(0, *CmdL, @sa, @sa, 1, pClass, 0, 0, @si, @pi) = 0 Then
					ShowMessages(ML("Error: Couldn't Create Process"), False)
					If Workdir Then _Deallocate(Workdir)
					If CmdL Then _Deallocate(CmdL)
					ChangeEnabledDebug True, False, False
					Exit Sub
				End If
				CloseHandle hWritePipe
				Do
					result1 = ReadFile(hReadPipe, @sBuffer, BufferSize, @bytesRead, ByVal 0)
					sBuffer = Left(sBuffer, bytesRead)
					Var Pos1 = InStrRev(sBuffer, Chr(10))
					If Pos1 > 0 Then
						Dim res() As WString Ptr
						sOutput += Left(sBuffer, Pos1 - 1)
						Split sOutput, WChr(10), res()
						For i As Integer = 0 To UBound(res)
							ShowMessages *res(i)
							If Len(*res(i)) <= 1 Then Continue For
							If InStr(*res(i), Chr(13)) > 0 Then *res(i) = Left(*res(i), Len(*res(i)) - 1)
							'ShowMessages Str(Time) & ": " & ML("DebugPrint") & ": " & *res(i)
							_Deallocate(res(i)): res(i) = 0
						Next i
						Erase res
						sOutput = ""
					Else
						sOutput += sBuffer
					End If
				Loop While result1
				
				CloseHandle pi.hProcess
				CloseHandle pi.hThread
				CloseHandle hReadPipe
				result1 = GetLastError()
				ShowMessages(Time & ": " & ML("Application finished. Returned code") & ": " & IIf(result1 = ERROR_BROKEN_PIPE, "0 - " & Err2Description(0), result1  & " - " & GetErrorString(result1)))
			Else
				Dim SInfo As STARTUPINFO
				Dim PInfo As PROCESS_INFORMATION
				SInfo.cb = Len(SInfo)
				SInfo.dwFlags = STARTF_USESHOWWINDOW
				SInfo.wShowWindow = SW_NORMAL
				pClass = CREATE_UNICODE_ENVIRONMENT Or CREATE_NEW_CONSOLE
				ChDir(GetFolderName(*ExeFileName))
				If CreateProcessW(NULL, CmdL, ByVal NULL, ByVal NULL, False, pClass, NULL, Workdir, @SInfo, @PInfo) Then
					dbghand = PInfo.hProcess
					prun = True
					WaitForSingleObject PInfo.hProcess, INFINITE
					GetExitCodeProcess(PInfo.hProcess, @ExitCode)
					CloseHandle(PInfo.hProcess)
					CloseHandle(PInfo.hThread)
					prun = False
					Result = ExitCode
					'Result = Shell(Debugger & """" & *ExeFileName + """")
					ShowMessages(Time & ": " & ML("Application finished. Returned code") & ": " & Result & " - " & Err2Description(Result))
				Else
					Result = GetLastError()
					ShowMessages(Time & ": " & ML("Application do not run. Error code") & ": " & Result & " - " & GetErrorString(Result))
				End If
				'		Else
				'			WLet CmdL, """" & WGet(TerminalPath) & """ /K ""cd /D """ & *Workdir & """ & " & *CmdL & """", True
				'			ShowMessages(Time & ": " & ML("Run") & ": " & *CmdL & " ...")
				'			Result = Shell(*CmdL)
				'			ShowMessages(Time & ": " & ML("The application finished. Returned code") & ": " & Result & " - " & Err2Description(Result))
				'		End If
			End If
			ChangeEnabledDebug True, False, False
			'End If
			RestoreStatusText
			If Workdir Then _Deallocate(Workdir)
			If CmdL Then _Deallocate(CmdL)
		#endif
	End If
	If ExeFileName Then _Deallocate( ExeFileName)
	Exit Sub
	ErrorHandler:
	ThreadsEnter()
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " " & _
	"in function " & ZGet(Erfn()) & " " & _
	"in module " & ZGet(Ermn())
	ThreadsLeave()
End Sub

Sub RunProgram(Param As Any Ptr)
	RunPr
End Sub

Sub TabWindow.AddSpaces(ByVal StartLine As Integer = -1, ByVal EndLine As Integer = -1)
	If txtCode.Content.CStyle Then Exit Sub
	With txtCode
		If StartLine = -1 Or EndLine = -1 Then
			StartLine = 0
			EndLine = .LinesCount - 1
		End If
		Dim As EditControlLine Ptr ecl
		Dim As UString res(Any), b
		Dim As UString c, cn, cp
		For l As Integer = StartLine To EndLine
			ecl = .Content.Lines.Items[l]
			If ecl->CommentIndex <> 0 Then Continue For
			If ecl->InAsm Then Continue For
			Split(*ecl->Text, """", res())
			For j As Integer = 0 To UBound(res)
				If j = 0 Then
					b = res(0)
				ElseIf j Mod 2 = 0 Then
					b &= """" & res(j)
				Else
					b &= """" & WSpace(Len(res(j)))
				End If
			Next
			Dim As Integer Pos1 = InStr(b, "'")
			If Pos1 > 0 Then b = ..Left(b, Pos1)
			For i As Integer = Len(b) To 1 Step -1
				c = Mid(b, i, 1)
				cn = Mid(b, i + 1, 1)
				cp = Mid(b, i - 1, 1)
				If InStr("+-*/\<>&=',:;""()^", c) Then
					If CInt(IsArg(Asc(cn)) OrElse InStr("{[("")]}*@", cn) > 0) AndAlso CInt(LCase(Mid(*ecl->Text, i, 2)) <> "/'") AndAlso _
						CInt(LCase(Mid(*ecl->Text, i, 2)) <> "&h" AndAlso LCase(Mid(*ecl->Text, i, 2)) <> "&o" AndAlso CInt(c <> """")) AndAlso CInt(c <> "'") AndAlso CInt(c <> "(") AndAlso CInt(c <> ")") AndAlso _
						CInt(c <> "<" OrElse LCase(Right(RTrim(..Left(*ecl->Text, i - 1)), 4)) <> "type") AndAlso _
						CInt(c <> ">" OrElse InStr(..Left(LCase(*ecl->Text), i - 1), "type<") = 0) AndAlso _
						CInt(c <> "-" OrElse InStr("([{,;:+-*/=<>eE", Right(RTrim(..Left(*ecl->Text, i - 1)), 1)) = 0 AndAlso LCase(Right(RTrim(..Left(*ecl->Text, i - 1)), 6)) <> "return" AndAlso LCase(Right(RTrim(..Left(*ecl->Text, i - 1)), 3)) <> " to" AndAlso LCase(Right(RTrim(..Left(*ecl->Text, i - 1)), 5)) <> " step") AndAlso _
						CInt(Mid(*ecl->Text, i - 1, 2) <> "->") AndAlso CInt(CInt(c <> "*") OrElse CInt(IsNumeric(cn)) OrElse CInt(Not IsArg(Asc(cn)))) OrElse _
						CInt(InStr(",:;=", c) > 0 AndAlso (c <> "=" OrElse cn <> ">") AndAlso cn <> "" AndAlso cn <> " " AndAlso cn <> !"\t") OrElse _
						CInt(c = """" AndAlso IsArg(Asc(cn))) OrElse CInt(c = ")" AndAlso IsArg(Asc(cn))) Then
						WLetEx ecl->Text, ..Left(*ecl->Text, i) & " " & Mid(*ecl->Text, i + 1), True
					End If
					If CInt(CInt(IsArg(Asc(cp)) OrElse InStr("{[("")]}", cp) > 0) AndAlso CInt(c <> """") AndAlso CInt(c <> "'") AndAlso CInt(c <> ",") AndAlso CInt(c <> ":") AndAlso _
						CInt(c <> ";") AndAlso CInt(c <> "(") AndAlso CInt(c <> ")") AndAlso CInt(Mid(*ecl->Text, i, 2) <> "->") AndAlso _
						CInt(CInt(c <> "*") OrElse CInt(IsNumeric(cn)) OrElse CInt(Not IsArg(Asc(cn)))) AndAlso _
						CInt(CInt(c <> ">") OrElse InStr(..Left(LCase(*ecl->Text), i - 1), "type<") = 0)) AndAlso _
						CInt(CInt(c <> "-") OrElse CInt(cp <> " ") AndAlso CInt(cp <> !"\t") AndAlso CInt(IsArg(Asc(cn))) AndAlso CInt(c <> "'") AndAlso _
						CInt(InStr("+-*/=", Right(RTrim(..Left(*ecl->Text, i - 1)), 1)) > 0) AndAlso _
						CInt(InStr("({[", cp) = 0) OrElse CInt(IsArg(Asc(cp))) AndAlso CInt(LCase(cp) <> "e") OrElse CInt(InStr(""")]}", cp) > 0)) OrElse _
						CInt(c = """" AndAlso IsArg(Asc(cp))) OrElse CInt(c = "(" AndAlso cp = """") OrElse CInt(c = "'" AndAlso cp <> "" AndAlso cp <> " " AndAlso cp <> !"\t" AndAlso cp <> "/") Then
						WLetEx ecl->Text, ..Left(*ecl->Text, i - 1) & " " & Mid(*ecl->Text, i), True
					End If
				End If
			Next
		Next l
	End With
End Sub

Sub NumberingOn(ByVal StartLine As Integer = -1, ByVal EndLine As Integer = -1, bMacro As Boolean = False, ByRef txtCode As EditControl, WithoutUpdate As Boolean = False, StartsOfProcs As Boolean = False)
	With txtCode
		If Not WithoutUpdate Then .UpdateLock
		.Changing("Raqamlash")
		If StartLine = -1 Or EndLine = -1 Then
			Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
			.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
			StartLine = iSelStartLine
			EndLine = iSelEndLine - IIf(iSelEndChar = 0, 1, 0)
		End If
		Dim As EditControlLine Ptr FECLine
		Dim As Integer n, NotNumberingScopesCount, NamespacesCount
		Dim As Boolean bNotNumberNext, bNotNumberThis, bInFunction, bInType, bFunctionStart, bChanged
		For i As Integer = StartLine To EndLine
			FECLine = .Content.Lines.Items[i]
			bChanged = False
			bNotNumberThis = bNotNumberNext
			bNotNumberNext = False
			If EndsWith(RTrim(*FECLine->Text, Any !"\t "), " _") OrElse EndsWith(RTrim(*FECLine->Text, Any !"\t "), ",_") Then
				bNotNumberNext = True
			End If
			If CBool(Trim(*FECLine->Text, Any !"\t ") = "") OrElse StartsWith(LTrim(*FECLine->Text, Any !"\t "), "'") OrElse StartsWith(LTrim(*FECLine->Text, Any !"\t "), "#") Then
				Continue For
			ElseIf StartsWith(LTrim(LCase(*FECLine->Text), Any !"\t "), "select case ") Then
				bNotNumberNext = True
			ElseIf FECLine->ConstructionIndex = C_Namespace Then
				If FECLine->ConstructionPart = 0 Then
					NamespacesCount += 1
				ElseIf FECLine->ConstructionPart = 2 Then
					NamespacesCount -= 1
				End If
				Continue For
			ElseIf FECLine->ConstructionIndex = C_Extern OrElse FECLine->ConstructionIndex = C_Asm OrElse FECLine->ConstructionIndex >= C_Enum AndAlso FECLine->ConstructionIndex <= C_Union Then
				If FECLine->ConstructionPart = 0 Then
					NotNumberingScopesCount += 1
				ElseIf FECLine->ConstructionPart = 2 Then
					NotNumberingScopesCount -= 1
				End If
				Continue For
			ElseIf FECLine->ConstructionIndex >= C_Sub Then
				bInFunction = FECLine->ConstructionPart <> 2
				If bInFunction Then bFunctionStart = False
				Continue For
			ElseIf FECLine->ConstructionIndex >= C_Namespace AndAlso Constructions(FECLine->ConstructionIndex).Collapsible Then
				Continue For
			ElseIf (NamespacesCount > 0 AndAlso Not bInFunction) OrElse NotNumberingScopesCount > 0 Then
				Continue For
			End If
			If StartsOfProcs Then
				If bInFunction AndAlso Not bFunctionStart Then
					bFunctionStart = True
				Else
					Continue For
				End If
			End If
			n = Len(*FECLine->Text) - Len(LTrim(*FECLine->Text))
			If StartsWith(LTrim(*FECLine->Text), "?") Then
				Var Pos1 = InStr(LTrim(*FECLine->Text), ":")
				If IsNumeric(Mid(..Left(LTrim(*FECLine->Text), Pos1 - 1), 2)) Then
					WLet(FECLine->Text, Space(n) & Mid(LTrim(*FECLine->Text), Pos1 + 1))
					bChanged = True
				End If
			ElseIf bMacro AndAlso StartsWith(LTrim(*FECLine->Text, Any !"\t "), "_L ") Then 'OrElse StartsWith(LTrim(LCase(*FECLine->Text), Any !"\t "), "dim ") Then
				bNotNumberThis = True
			ElseIf StartsWith(LTrim(*FECLine->Text, Any !"\t "), "_L ") AndAlso Not bMacro Then 'OrElse StartsWith(LTrim(LCase(*FECLine->Text), Any !"\t "), "dim ") Then
				WLet(FECLine->Text, Space(n) & Mid(LTrim(*FECLine->Text), 4))
				bChanged = True
				'			ElseIf StartsWith(LTrim(*FECLine->Text, Any !"\t "), "debugprint") Then
				'				bNotNumberThis = True
				'			ElseIf StartsWith(LTrim(*FECLine->Text, Any !"\t "), "?") Then
				'				bNotNumberThis = True
			ElseIf IsLabel(*FECLine->Text) Then
				bNotNumberThis = True
			ElseIf FECLine->InConstructionIndex = C_Asm OrElse FECLine->InConstructionIndex = C_Select_Case AndAlso FECLine->InConstructionPart = 0 OrElse _
				FECLine->InConstructionIndex >= C_Namespace AndAlso FECLine->InConstructionIndex <= C_Union Then
				bNotNumberThis = True
			End If
			If Not bNotNumberThis Then
				If bMacro Then
					WLet(FECLine->Text, "_L " & *FECLine->Text) '& IIf(StartsWith(*FECLine->Text, " ") OrElse StartsWith(*FECLine->Text, !"\t"), "", " ")
				Else
					WLet(FECLine->Text, "?" & WStr(i + 1) & ":" & *FECLine->Text)
					'WLet FECLine->Text, "DebugPrint(__FILE__ & " & Chr(34) & " Line " & Chr(34) & " & __LINE__, True, False) : " & Trim(*FECLine->Text, Any !" \t ")
				End If
				bChanged = True
			End If
			If bChanged Then
				FECLine->Ends.Clear
				FECLine->EndsCompleted = False
			End If
		Next i
		.Changed("Raqamlash")
		If Not WithoutUpdate Then .UpdateUnLock
		.PaintControl True
		'.ShowCaretPos True
	End With
End Sub

Sub TabWindow.NumberOn(ByVal StartLine As Integer = -1, ByVal EndLine As Integer = -1, bMacro As Boolean = False)
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	NumberingOn StartLine, EndLine, bMacro, tb->txtCode
End Sub

Sub PreprocessorNumberingOn(ByRef txtCode As EditControl, ByRef FileName As WString, WithoutUpdate As Boolean = False)
	With txtCode
		If Not WithoutUpdate Then .UpdateLock
		.Changing("Preprocessor Numbering")
		Dim As EditControlLine Ptr FECLine, FECLineOld
		For i As Integer = .LinesCount - 1 To 0 Step -1
			FECLine = .Content.Lines.Items[i]
			If i > 0 Then
				FECLineOld = .Content.Lines.Items[i - 1]
				If EndsWith(RTrim(*FECLineOld->Text, Any !"\t "), " _") Then Continue For
				If StartsWith(LTrim(LCase(*FECLineOld->Text), Any !"\t "), "#print __line__") Then Continue For
			End If
			If Trim(*FECLine->Text, Any !"\t ") = "" Then Continue For
			If StartsWith(LTrim(LCase(*FECLine->Text), Any !"\t "), "#print __line__") Then Continue For
			If StartsWith(LTrim(*FECLine->Text, Any !"\t "), "'") Then Continue For
			.InsertLine i, "#print __LINE__ - " & FileName
		Next i
		.Changed("Preprocessor Numbering")
		If Not WithoutUpdate Then .UpdateUnLock
		'.ShowCaretPos True
	End With
End Sub

Sub TabWindow.PreprocessorNumberOn()
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	PreprocessorNumberingOn tb->txtCode, tb->FileName
End Sub

Sub GetProcedureLines(ByRef ehStart As Integer, ByRef ehEnd As Integer)
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	With tb->txtCode
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar, i
		.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		Dim As EditControlLine Ptr FECLine
		For i = iSelStartLine To 0 Step -1
			FECLine = .Content.Lines.Items[i]
			If FECLine->ConstructionIndex >= C_Sub  Then
				If FECLine->ConstructionPart = 0 Then
					ehStart = i + 1
					Exit For
				Else
					ehEnd = .Content.Lines.Count - 1
					Exit Sub
				End If
			End If
		Next i
		Dim As Boolean t
		For i = iSelStartLine To .Content.Lines.Count - 1
			FECLine = .Content.Lines.Items[i]
			If FECLine->ConstructionIndex >= C_Sub Then
				t = True
				ehEnd = i - 1
				Exit For
			End If
		Next i
		If Not t Then ehEnd = i - 1
	End With
End Sub

Sub TabWindow.SetErrorHandling(StartLine As String, EndLine As String)
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	With tb->txtCode
		.UpdateLock
		.Changing("Error handling")
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		Dim As EditControlLine Ptr FECLine
		Dim As Integer ehStart, ehEnd
		Dim Bosh As Boolean
		Dim n As Integer
		Dim As String ExitLine, LeftSpace
		For i As Integer = iSelStartLine To 0 Step -1
			FECLine = .Content.Lines.Items[i]
			If FECLine->ConstructionIndex >= C_Sub  Then
				If FECLine->ConstructionPart = 0 Then
					ehStart = i + 1
					Select Case FECLine->ConstructionIndex
					Case C_Sub: ExitLine = "Exit Sub"
					Case C_Function: ExitLine = "Exit Function"
					Case C_Property: ExitLine = "Exit Property"
					Case C_Operator: ExitLine = "Exit Operator"
					Case C_Constructor: ExitLine = "Exit Constructor"
					Case C_Destructor: ExitLine = "Exit Destructor"
					End Select
					n = Len(*FECLine->Text) - Len(LTrim(*FECLine->Text, Any !"\t "))
					LeftSpace = ..Left(*FECLine->Text, n)
					Exit For
				Else
					Bosh = True
					If StartsWith(Trim(.Lines(0), Any "\t "), "'#Compile ") Then
						ehStart = 1
					Else
						ehStart = 0
					End If
					ExitLine = "End"
					n = 0
					Exit For
				End If
			End If
		Next i
		If ExitLine <> "" Then
			If CInt(.Content.Lines.Count - 1 >= ehStart) AndAlso (CInt(StartsWith(LTrim(.Lines(ehStart), Any !"\t "), "On Error ")) OrElse CInt(StartsWith(LTrim(.Lines(ehStart), Any !"\t "), "On Local Error "))) Then
				If StartLine <> "" Then
					.ReplaceLine ehStart, LeftSpace & !"\t" & StartLine
				Else
					.DeleteLine ehStart
					If iSelStartLine > ehStart Then iSelStartLine -= 1
				End If
			ElseIf StartLine <> "" Then
				.InsertLine ehStart, LeftSpace & !"\t" & StartLine
				iSelStartLine += 1
			End If
			Dim t As Boolean
			If Bosh Then
				ehEnd = .Content.Lines.Count - 1
			Else
				Dim i As Integer
				For i = iSelStartLine To .Content.Lines.Count - 1
					FECLine = .Content.Lines.Items[i]
					If FECLine->ConstructionIndex >= C_Sub  Then
						If FECLine->ConstructionPart = 2 Then
							t = True
							ehEnd = i - 1
							Exit For
						Else
							t = True
							ehEnd = i - 1
							Exit For
						End If
					End If
				Next i
				If Not t Then
					ehEnd = i
				End If
			End If
			t = False
			Dim p As Integer
			For i As Integer = ehEnd - 1 To ehStart Step -1
				FECLine = .Content.Lines.Items[i]
				If FECLine->ConstructionIndex >= C_Sub Then
					p = i
					Exit For
				ElseIf StartsWith(Trim(.Lines(i), Any !"\t "),  ExitLine) Then
					p = i
					t = True
					Exit For
				End If
			Next i
			If t Then
				FECLine = .Content.Lines.Items[ehEnd]
				If FECLine->ConstructionIndex >= C_Sub Then
					ehEnd -= 1
				End If
				For j As Integer = ehEnd To p Step -1
					.DeleteLine j
					ehEnd -= 1
				Next j
			End If
			If StartsWith(Trim(.Lines(ehEnd), Any !"\t "),  "On Local Error Goto 0") Then
				.DeleteLine ehEnd
				ehEnd -= 1
			End If
			If StartLine <> "" And StartLine <> "On Error Resume Next" Then
				If StartLine = "On Local Error Goto ErrorHandler" Then .InsertLine ehEnd + 1, LeftSpace & !"\t" & "On Local Error Goto 0": ehEnd += 1
				.InsertLine ehEnd + 1, LeftSpace & !"\t" & ExitLine
				.InsertLine ehEnd + 2, LeftSpace & "ErrorHandler:"
				.InsertLine ehEnd + 3, LeftSpace & !"\t" & "MsgBox ErrDescription(Err) & "" ("" & Err & "") "" & _"
				.InsertLine ehEnd + 4, LeftSpace & !"\t\t" & """in line "" & Erl() & "" (Handler line: "" & __LINE__ & "") "" & _"
				.InsertLine ehEnd + 5, LeftSpace & !"\t\t" & """in function "" & ZGet(Erfn()) & "" (Handler function: "" & __FUNCTION__ & "") "" & _"
				.InsertLine ehEnd + 6, LeftSpace & !"\t\t" & """in module "" & ZGet(Ermn()) & "" (Handler file: "" & __FILE__ & "") """
				If EndLine <> "" Then .InsertLine ehEnd + 7, LeftSpace & !"\t" & EndLine
			End If
		End If
		.Changed("Error handling")
		.UpdateUnLock
		'.ShowCaretPos True
	End With
End Sub

Sub TabWindow.RemoveErrorHandling()
	SetErrorHandling "", ""
End Sub

Sub NumberingOff(ByVal StartLine As Integer = -1, ByVal EndLine As Integer = -1, ByRef txtCode As EditControl, WithoutUpdate As Boolean = False)
	With txtCode
		If Not WithoutUpdate Then .UpdateLock
		.Changing("Raqamlarni olish")
		If StartLine = -1 Or EndLine = -1 Then
			Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
			.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
			StartLine = iSelStartLine
			EndLine = iSelEndLine - IIf(iSelEndChar = 0, 1, 0)
		End If
		Dim As EditControlLine Ptr FECLine
		Dim As Integer n
		For i As Integer = StartLine To EndLine
			FECLine = .Content.Lines.Items[i]
			n = Len(*FECLine->Text) - Len(LTrim(*FECLine->Text))
			If StartsWith(LTrim(*FECLine->Text, Any !"\t "), "?") Then
				Var Pos1 = InStr(LTrim(*FECLine->Text), ":")
				If IsNumeric(Mid(..Left(LTrim(*FECLine->Text), Pos1 - 1), 2)) Then
					WLet(FECLine->Text, Space(n) & Mid(LTrim(*FECLine->Text), Pos1 + 1))
					FECLine->Ends.Clear
					FECLine->EndsCompleted = False
				End If
			ElseIf StartsWith(LTrim(*FECLine->Text, Any !"\t "), "_L ") Then
				WLet(FECLine->Text, Mid(LTrim(*FECLine->Text), 4))
				FECLine->Ends.Clear
				FECLine->EndsCompleted = False
			End If
		Next i
		.Changed("Raqamlarni olish")
		If Not WithoutUpdate Then .UpdateUnLock
		'.ShowCaretPos True
		.PaintControl True
	End With
End Sub

Sub TabWindow.NumberOff(ByVal StartLine As Integer = -1, ByVal EndLine As Integer = -1)
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	NumberingOff StartLine, EndLine, tb->txtCode
End Sub

Sub PreprocessorNumberingOff(ByRef txtCode As EditControl, WithoutUpdate As Boolean = False)
	With txtCode
		If Not WithoutUpdate Then .UpdateLock
		.Changing("Remove Preprocessor Numbering")
		Dim As EditControlLine Ptr FECLine
		Dim As Integer n
		For i As Integer = .LinesCount - 1 To 0 Step -1
			FECLine = .Content.Lines.Items[i]
			If StartsWith(LTrim(LCase(*FECLine->Text), Any !"\t "), "#print __line__") Then
				.DeleteLine i
			End If
		Next i
		.Changed("Remove Preprocessor Numbering")
		If Not WithoutUpdate Then .UpdateUnLock
		'.ShowCaretPos True
	End With
End Sub

Sub TabWindow.PreprocessorNumberOff()
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	PreprocessorNumberingOff tb->txtCode
End Sub

Sub TabWindow.ProcessMessage(ByRef msg As Message)
	#ifndef __USE_GTK__
		Select Case msg.Msg
		Case EM_SETMODIFY
			FormDesign
		End Select
	#endif
	Base.ProcessMessage(msg)
End Sub

Sub TabWindow.SortLines(ByVal StartLine As Integer = -1, ByVal EndLine As Integer = -1)
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	With tb->txtCode
		.UpdateLock
		.Changing("Sort Lines")
		If StartLine = -1 Or EndLine = -1 Then
			Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
			.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
			StartLine = iSelStartLine
			EndLine = iSelEndLine - IIf(iSelEndChar = 0, 1, 0)
		End If
		Dim As EditControlLine Ptr FECLine
		Dim As Integer n = 0
		Dim As WStringList Lines
		For i As Integer = StartLine To EndLine
			FECLine = .Content.Lines.Items[i]
			Lines.Add *FECLine->Text
		Next i
		Lines.Sort
		For i As Integer = StartLine To EndLine
			FECLine = .Content.Lines.Items[i]
			WLet(FECLine->Text, Lines.Item(n))
			n = n + 1
		Next i
		Lines.Clear
		.Changed("Sort Lines")
		.UpdateUnLock
		'.ShowCaretPos True
	End With
End Sub

Sub TabWindow.DeleteBlankLines(ByVal StartLine As Integer = -1, ByVal EndLine As Integer = -1)
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	With tb->txtCode
		.UpdateLock
		.Changing("DeleteBlankLines")
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		If StartLine = -1 Or EndLine = -1 Then
			.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
			iSelEndLine = iSelEndLine - IIf(iSelEndChar = 0, 1, 0)
		Else
			iSelStartLine= StartLine :  iSelEndLine = EndLine
		End If
		If iSelStartLine < 0 OrElse iSelStartLine > .LinesCount - 1 OrElse iSelEndLine > .LinesCount - 1 Then Exit Sub
		Dim As EditControlLine Ptr FECLine
		For i As Integer = iSelEndLine To iSelStartLine Step -1
			FECLine = .Content.Lines.Items[i]
			If i > 0 AndAlso Trim(*FECLine->Text, Any !"\t ") = "" AndAlso Trim(* (Cast(EditControlLine Ptr, .Content.Lines.Items[i - 1])->Text), Any !"\t ") = "" Then
				.DeleteLine i
			End If
		Next i
		.Changed("DeleteBlankLines")
		.UpdateUnLock
	End With
End Sub

Sub TabWindow.FormatWithBasisWord(ByVal StartLine As Integer = -1, ByVal EndLine As Integer = -1)
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	With tb->txtCode
		If StartLine = -1 Or EndLine = -1 Then
			Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
			.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
			StartLine = iSelStartLine
			EndLine = iSelEndLine - IIf(iSelEndChar = 0, 1, 0)
		End If
		Dim As EditControlLine Ptr FECLine= .Content.Lines.Items[StartLine]
		If FECLine->CommentIndex > 0 OrElse StartsWith(LTrim(*FECLine->Text, Any !"\t "), "'") Then Return
		.UpdateLock
		.Changing("FormatWithBasisWord")
		Dim As WString * 10 BasisWord = ""
		Dim As Integer BasisPosition, PosiWord, Pos1
		ECLine = .Content.Lines.Items[StartLine]
		PosiWord = 99999
		Pos1 = InStr(LCase(*FECLine->Text), " = ")
		If Pos1 > 1 Then PosiWord = Pos1 : BasisWord = " = "
		Pos1 = InStr(LCase(*FECLine->Text), " as ")
		If Pos1 > 1 AndAlso PosiWord > Pos1 Then PosiWord = Pos1 : BasisWord = " as "
		Pos1 = InStr(LCase(*FECLine->Text), ": ")
		If Pos1 > 1 AndAlso PosiWord > Pos1 Then PosiWord = Pos1 : BasisWord = ": "
		Pos1 = InStr(LCase(*FECLine->Text), ", ")
		If Pos1 > 1 AndAlso PosiWord > Pos1 Then PosiWord = Pos1 : BasisWord = ", "
		Pos1 = InStr(LCase(*FECLine->Text), "  ")
		If Pos1 > 1 AndAlso BasisWord = "" Then PosiWord = Pos1 : BasisWord = "  "
		If BasisWord <> "" Then
			Dim As WString Ptr LineStr
			Dim j As Integer
			For i As Integer = StartLine To EndLine
				FECLine = .Content.Lines.Items[i]
				If FECLine->CommentIndex = 0 AndAlso StartsWith(LTrim(*FECLine->Text, Any !"\t "), "'") = False Then
					If BasisWord = "  " Then
						Pos1 = InStr(*FECLine->Text, BasisWord)
						If Pos1 > 0 Then
							For j = Pos1 To Len(*FECLine->Text)
								If Mid(*FECLine->Text, j, 1) <> " " Then Exit For
							Next
							WLet(LineStr, *FECLine->Text)
							WLet(FECLine->Text, RTrim(Mid(*LineStr, 1, j - 1) , Any !"\t ") & "  " & LTrim(Mid(*LineStr, j)))
						End If
					End If
					BasisPosition = Max(BasisPosition, InStr(LCase(*FECLine->Text), BasisWord))
				End If
			Next
			For i As Integer = StartLine To EndLine
				FECLine = .Content.Lines.Items[i]
				Pos1 = InStr(LCase(*FECLine->Text), BasisWord)
				If CBool(Pos1 > 0) AndAlso CBool(Pos1 <= BasisPosition) AndAlso CBool(FECLine->CommentIndex = 0) AndAlso (Not StartsWith(LTrim(*FECLine->Text, Any !"\t "), "'")) AndAlso CBool(Right(Trim(*FECLine->Text, Any !"\t "), 2) <> "'/") Then
					WLet(LineStr, *FECLine->Text)
					FECLine->Ends.Clear
					FECLine->EndsCompleted = False
					WLet(FECLine->Text, RTrim(Mid(*LineStr, 1, Pos1), Any !"\t ") & Space(BasisPosition - Len(RTrim(Mid(*LineStr, 1, Pos1), Any !"\t "))) & LTrim(Mid(*LineStr, Pos1 + 1)))
				End If
			Next
			_Deallocate(LineStr)
		End If
		.Changed("FormatWithBasisWord")
		.UpdateUnLock
	End With
End Sub

Sub TabWindow.ConvertToLowercase(ByVal StartLine As Integer = -1, ByVal EndLine As Integer = -1)
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	With tb->txtCode
		.UpdateLock
		.Changing("ConvertToLowercase")
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		If StartLine = -1 Or EndLine = -1 Then
			.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
			iSelEndLine = iSelEndLine - IIf(iSelEndChar = 0, 1, 0)
		Else
			iSelStartLine = StartLine :  iSelEndLine = EndLine
			iSelStartChar = 1 : iSelEndChar = -1
		End If
		If iSelStartLine < 0 OrElse iSelStartLine > .LinesCount - 1 OrElse iSelEndLine > .LinesCount - 1 Then Exit Sub
		Dim As EditControlLine Ptr FECLine = .Content.Lines.Items[iSelStartLine]
		Dim As WString Ptr LineStr
		WLet(LineStr, *FECLine->Text)
		FECLine->Ends.Clear
		FECLine->EndsCompleted = False
		If iSelStartLine >= 0 AndAlso iSelEndLine <> iSelStartLine Then
			If Trim(*LineStr, Any !"\t ") <> "" Then WLet(FECLine->Text, Mid(*LineStr, 1, iSelStartChar) & LCase(Mid(*LineStr, iSelStartChar + 1)))
			FECLine = .Content.Lines.Items[iSelEndLine]
			WLet(LineStr, *FECLine->Text)
			If Trim(*LineStr, Any !"\t ") <> "" Then WLet(FECLine->Text, LCase(Mid(*LineStr, 1, iSelEndChar)) & Mid(*LineStr, iSelEndChar + 1))
		Else
			If iSelEndChar = -1 Then iSelEndChar = Len(*LineStr)
			If Trim(*LineStr, Any !"\t ") <> "" Then WLet(FECLine->Text, Mid(*LineStr, 1, iSelStartChar) & LCase(Mid(*LineStr, iSelStartChar + 1, iSelEndChar - iSelStartChar)) & Mid(*LineStr, iSelEndChar + 1))
		End If
		If iSelEndLine > iSelStartLine + 1 Then
			For i As Integer = iSelStartLine + 1 To iSelEndLine - 1
				FECLine = .Content.Lines.Items[i]
				WLet(LineStr, *FECLine->Text)
				FECLine->Ends.Clear
				FECLine->EndsCompleted = False
				If Trim(*LineStr, Any !"\t ") <> "" Then WLet(FECLine->Text, LCase(*LineStr))
			Next i
		End If
		_Deallocate(LineStr)
		.Changed("ConvertToLowercase")
		.UpdateUnLock
	End With
End Sub

Sub TabWindow.ConvertToUppercase(ByVal StartLine As Integer = -1, ByVal EndLine As Integer = -1)
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	With tb->txtCode
		.UpdateLock
		.Changing("ConvertToLowercase")
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		If StartLine = -1 Or EndLine = -1 Then
			.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
			iSelEndLine = iSelEndLine - IIf(iSelEndChar = 0, 1, 0)
		Else
			iSelStartLine = StartLine :  iSelEndLine = EndLine
			iSelStartChar = 1 : iSelEndChar = -1
		End If
		If iSelStartLine < 0 OrElse iSelStartLine > .LinesCount - 1 OrElse iSelEndLine > .LinesCount - 1 Then Exit Sub
		Dim As EditControlLine Ptr FECLine = .Content.Lines.Items[iSelStartLine]
		Dim As WString Ptr LineStr
		WLet(LineStr, *FECLine->Text)
		FECLine->Ends.Clear
		FECLine->EndsCompleted = False
		If iSelStartLine >= 0 AndAlso iSelEndLine <> iSelStartLine Then
			If Trim(*LineStr, Any !"\t ") <> "" Then WLet(FECLine->Text, Mid(*LineStr, 1, iSelStartChar) & UCase(Mid(*LineStr, iSelStartChar + 1)))
			FECLine = .Content.Lines.Items[iSelEndLine]
			WLet(LineStr, *FECLine->Text)
			If Trim(*LineStr, Any !"\t ") <> "" Then WLet(FECLine->Text, UCase(Mid(*LineStr, 1, iSelEndChar)) & Mid(*LineStr, iSelEndChar + 1))
		Else
			If iSelEndChar = -1 Then iSelEndChar = Len(*LineStr)
			If Trim(*LineStr, Any !"\t ") <> "" Then WLet(FECLine->Text, Mid(*LineStr, 1, iSelStartChar) & UCase(Mid(*LineStr, iSelStartChar + 1, iSelEndChar - iSelStartChar)) & Mid(*LineStr, iSelEndChar + 1))
		End If
		If iSelEndLine > iSelStartLine + 1 Then
			For i As Integer = iSelStartLine + 1 To iSelEndLine - 1
				FECLine = .Content.Lines.Items[i]
				FECLine->Ends.Clear
				FECLine->EndsCompleted = False
				WLet(LineStr, *FECLine->Text)
				If Trim(*LineStr, Any !"\t ") <> "" Then WLet(FECLine->Text, UCase(*LineStr))
			Next i
		End If
		_Deallocate(LineStr)
		.Changed("ConvertToLowercase")
		.UpdateUnLock
	End With
End Sub

Sub TabWindow.ProcedureNumberOn(bMacro As Boolean = False)
	Dim As Integer ehStart, ehEnd
	GetProcedureLines ehStart, ehEnd
	NumberOn ehStart, ehEnd, bMacro
End Sub

Sub TabWindow.ProcedureNumberOff
	Dim As Integer ehStart, ehEnd
	GetProcedureLines ehStart, ehEnd
	NumberOff ehStart, ehEnd
End Sub

Sub TabWindow.Define
	Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar, k, Pos1
	txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	Dim As EditControlLine Ptr ECLine = txtCode.Content.Lines.Item(iSelStartLine)
	Dim As String FromClassName
	Dim sLine As WString Ptr = @txtCode.Lines(iSelEndLine)
	Dim As String TypeName, OldTypeName, Parameters, sWord = txtCode.GetWordAt(iSelEndLine, iSelEndChar)
	Dim As TypeElement Ptr te, te1, te2, teOld, teTypeOld
	If sWord = "" Then Exit Sub
	If ECLine Then
		If ECLine->InConstruction > 0 Then
			te = ECLine->InConstruction
			FromClassName = te->OwnerTypeName
			'Var Pos1 = InStr(FromClassName, ".")
			'If (CBool(Pos1 > 0) OrElse EndsWith(te->DisplayName, "[Constructor]") OrElse EndsWith(te->DisplayName, "[Destructor]")) Then
			'	If Pos1 > 0 Then
			'		FromClassName = ..Left(FromClassName, Pos1 - 1)
			'	Else
			'		FromClassName = te->Name
			'	End If
			'Else
			'	FromClassName = ""
			'End If
		End If
	End If
	With pfTrek->lvTrek.ListItems
		.Clear
		txtCode.Content.GetLeftArgTypeName(iSelEndLine, GetNextCharIndex(*sLine, iSelEndChar), te2, teOld, teTypeOld, OldTypeName)
		If teOld <> 0 OrElse OldTypeName <> "" Then
			If OldTypeName <> "" Then
				TypeName = OldTypeName
			ElseIf teOld->ElementType = E_Type Then
				TypeName = teOld->Name
			Else
				TypeName = teOld->TypeName
			End If
			If TypeName = "" AndAlso teOld <> 0 AndAlso teOld->Value <> "" Then
				TypeName = txtCode.Content.GetTypeFromValue(teOld->Value, iSelEndLine)
			End If
			If teOld <> 0 Then
				For i As Integer = 0 To teOld->Elements.Count - 1
					te = teOld->Elements.Object(i)
					If te <> 0 AndAlso LCase(Trim(te->Name)) = LCase(sWord) Then
						If te->StartLine = iSelEndLine Then Continue For
						.Add te->DisplayName
						.Item(.Count - 1)->Text(1) = te->Parameters
						.Item(.Count - 1)->Text(2) = WStr(te->StartLine + 1)
						.Item(.Count - 1)->Text(3) = WStr(te->StartChar)
						.Item(.Count - 1)->Text(4) = te->FileName
						.Item(.Count - 1)->Text(5) = te->Comment
						.Item(.Count - 1)->Tag = te->Tag
					End If
				Next
			End If
			FListItems.Clear
			If txtCode.Content.Types.Contains(TypeName) Then
				FillIntellisense TypeName, FromClassName, @txtCode.Content.Types, True, True
			ElseIf txtCode.Content.Enums.Contains(TypeName) Then
				FillIntellisense TypeName, FromClassName, @txtCode.Content.Enums, True, True
			ElseIf pComps->Contains(TypeName) Then
				FillIntellisense TypeName, FromClassName, pComps, True, True
			ElseIf pGlobalTypes->Contains(TypeName) Then
				FillIntellisense TypeName, FromClassName, pGlobalTypes, True, True
			ElseIf pGlobalEnums->Contains(TypeName) Then
				FillIntellisense TypeName, FromClassName, pGlobalEnums, True, True
			End If
			For i As Integer = 0 To FListItems.Count - 1
				te = FListItems.Object(i)
				If te <> 0 AndAlso LCase(Trim(te->Name)) = LCase(sWord) Then
					If te->StartLine = iSelEndLine Then Continue For
					.Add te->DisplayName
					.Item(.Count - 1)->Text(1) = te->Parameters
					.Item(.Count - 1)->Text(2) = WStr(te->StartLine + 1)
					.Item(.Count - 1)->Text(3) = WStr(te->StartChar)
					.Item(.Count - 1)->Text(4) = te->FileName
					.Item(.Count - 1)->Text(5) = te->Comment
					.Item(.Count - 1)->Tag = te->Tag
				End If
			Next
			For i As Integer = 0 To txtCode.Content.Functions.Count - 1
				te = txtCode.Content.Functions.Object(i)
				If te <> 0 AndAlso LCase(Trim(te->Name)) = LCase(sWord) Then
					If te->StartLine = iSelEndLine Then Continue For
					'Var Pos1 = InStr(te->FullName, ".")
					If (Len(te->OwnerTypeName) > 0) AndAlso IsBase(TypeName, te->OwnerTypeName, @This) Then
						.Add te->DisplayName
						.Item(.Count - 1)->Text(1) = te->Parameters
						.Item(.Count - 1)->Text(2) = WStr(te->StartLine + 1)
						.Item(.Count - 1)->Text(3) = WStr(te->StartChar)
						.Item(.Count - 1)->Text(4) = te->FileName
						.Item(.Count - 1)->Text(5) = te->Comment
						.Item(.Count - 1)->Tag = te->Tag
					End If
				End If
			Next
			For i As Integer = pGlobalTypeProcedures->Count - 1 To 0 Step -1
				te = pGlobalTypeProcedures->Object(i)
				If te <> 0 AndAlso LCase(Trim(te->Name)) = LCase(sWord) Then
					If te->StartLine = iSelEndLine Then Continue For
					'Var Pos1 = InStr(te->FullName, ".")
					If CBool(Len(te->OwnerTypeName) > 0) AndAlso CBool(te->FileName <> FileName) AndAlso IsBase(TypeName, te->OwnerTypeName, @This) Then
						.Add te->DisplayName
						.Item(.Count - 1)->Text(1) = te->Parameters
						.Item(.Count - 1)->Text(2) = WStr(te->StartLine + 1)
						.Item(.Count - 1)->Text(3) = WStr(te->StartChar)
						.Item(.Count - 1)->Text(4) = te->FileName
						.Item(.Count - 1)->Text(5) = te->Comment
						.Item(.Count - 1)->Tag = te->Tag
					End If
				End If
			Next
		Else
			If te2 <> 0 AndAlso (Not (te2->FileName = FileName AndAlso te2->StartLine = iSelEndLine)) Then
				.Add te2->DisplayName
				.Item(.Count - 1)->Text(1) = te2->Parameters
				.Item(.Count - 1)->Text(2) = WStr(te2->StartLine + 1)
				.Item(.Count - 1)->Text(3) = WStr(te2->StartChar)
				.Item(.Count - 1)->Text(4) = te2->FileName
				.Item(.Count - 1)->Text(5) = te2->Comment
				.Item(.Count - 1)->Tag = te2->Tag
			End If
			If ECLine Then
				If ECLine->InConstructionBlock > 0 Then
					FListItems.Clear
					FillFromConstructionBlock ECLine->InConstructionBlock, sWord
					For i As Integer = 0 To FListItems.Count - 1
						te = FListItems.Object(i)
						If te->StartLine = iSelEndLine Then Continue For
						.Add te->DisplayName
						.Item(.Count - 1)->Text(1) = te->Parameters
						.Item(.Count - 1)->Text(2) = WStr(te->StartLine + 1)
						.Item(.Count - 1)->Text(3) = WStr(te->StartChar)
						.Item(.Count - 1)->Text(4) = te->FileName
						.Item(.Count - 1)->Text(5) = te->Comment
						.Item(.Count - 1)->Tag = te->Tag
					Next
				End If
			End If
			If cboFunction.ItemIndex > -1 Then te1 = cboFunction.Items.Item(cboFunction.ItemIndex)->Object
			If te1 Then 
				If Len(te->OwnerTypeName) > 0 Then TypeName = te->OwnerTypeName
				'Pos1 = InStr(te1->DisplayName, "["): If Pos1 > 0 Then TypeName = Trim(..Left(te1->DisplayName, Pos1 - 1))
				'Pos1 = InStr(te1->FullName, "."): If Pos1 > 0 Then TypeName = Trim(..Left(te1->FullName, Pos1 - 1))
			End If
			If te1 <> 0 AndAlso te1->Elements.Contains(sWord) Then
				For i As Integer = 0 To te1->Elements.Count - 1
					te = te1->Elements.Object(i)
					If te <> 0 AndAlso LCase(Trim(te->Name)) = LCase(sWord) Then
						If te->StartLine = iSelEndLine Then Continue For
						If te = te2 Then Continue For
						.Add te->DisplayName
						.Item(.Count - 1)->Text(1) = te->Parameters
						.Item(.Count - 1)->Text(2) = WStr(te->StartLine + 1)
						.Item(.Count - 1)->Text(3) = WStr(te->StartChar)
						.Item(.Count - 1)->Text(4) = te->FileName
						.Item(.Count - 1)->Text(5) = te->Comment
						.Item(.Count - 1)->Tag = te->Tag
					End If
				Next
			End If
			If TypeName <> "" Then
				If txtCode.Content.Types.Contains(TypeName) Then
					FillIntellisense TypeName, FromClassName, @txtCode.Content.Types, True
				ElseIf txtCode.Content.Enums.Contains(TypeName) Then
					FillIntellisense TypeName, FromClassName, @txtCode.Content.Enums, True
				ElseIf pComps->Contains(TypeName) Then
					FillIntellisense TypeName, FromClassName, pComps, True
				ElseIf pGlobalTypes->Contains(TypeName) Then
					FillIntellisense TypeName, FromClassName, pGlobalTypes, True
				ElseIf pGlobalEnums->Contains(TypeName) Then
					FillIntellisense TypeName, FromClassName, pGlobalEnums, True
				End If
				If FListItems.Contains(sWord) Then
					For i As Integer = 0 To FListItems.Count - 1
						te = FListItems.Object(i)
						If te <> 0 AndAlso LCase(Trim(te->Name)) = LCase(sWord) Then
							If te->StartLine = iSelEndLine Then Continue For
							If te = te2 Then Continue For
							.Add te->DisplayName
							.Item(.Count - 1)->Text(1) = te->Parameters
							.Item(.Count - 1)->Text(2) = WStr(te->StartLine + 1)
							.Item(.Count - 1)->Text(3) = WStr(te->StartChar)
							.Item(.Count - 1)->Text(4) = te->FileName
							.Item(.Count - 1)->Text(5) = te->Comment
							.Item(.Count - 1)->Tag = te->Tag
						End If
					Next
				End If
				FListItems.Clear
			End If
			For i As Integer = 0 To txtCode.Content.Functions.Count - 1
				te = txtCode.Content.Functions.Object(i)
				If te <> 0 AndAlso LCase(Trim(te->Name)) = LCase(sWord) Then
					If te->StartLine = iSelEndLine Then Continue For
					If te = te2 Then Continue For
					.Add te->DisplayName
					.Item(.Count - 1)->Text(1) = te->Parameters
					.Item(.Count - 1)->Text(2) = WStr(te->StartLine + 1)
					.Item(.Count - 1)->Text(3) = WStr(te->StartChar)
					.Item(.Count - 1)->Text(4) = te->FileName
					.Item(.Count - 1)->Text(5) = te->Comment
					.Item(.Count - 1)->Tag = te->Tag
				End If
			Next
			For i As Integer = 0 To txtCode.Content.LineLabels.Count - 1
				te = txtCode.Content.LineLabels.Object(i)
				If te <> 0 AndAlso LCase(Trim(te->Name)) = LCase(sWord) Then
					If te->StartLine = iSelEndLine Then Continue For
					If te = te2 Then Continue For
					.Add te->DisplayName
					.Item(.Count - 1)->Text(1) = te->Parameters
					.Item(.Count - 1)->Text(2) = WStr(te->StartLine + 1)
					.Item(.Count - 1)->Text(3) = WStr(te->StartChar)
					.Item(.Count - 1)->Text(4) = te->FileName
					.Item(.Count - 1)->Text(5) = te->Comment
					.Item(.Count - 1)->Tag = te->Tag
				End If
			Next
			For i As Integer = 0 To txtCode.Content.Args.Count - 1
				te = txtCode.Content.Args.Object(i)
				If te <> 0 AndAlso LCase(Trim(te->Name)) = LCase(sWord) Then
					If te->StartLine = iSelEndLine Then Continue For
					If te = te2 Then Continue For
					.Add te->DisplayName
					.Item(.Count - 1)->Text(1) = te->Parameters
					.Item(.Count - 1)->Text(2) = WStr(te->StartLine + 1)
					.Item(.Count - 1)->Text(3) = WStr(te->StartChar)
					.Item(.Count - 1)->Text(4) = te->FileName
					.Item(.Count - 1)->Text(5) = te->Comment
					.Item(.Count - 1)->Tag = te->Tag
				End If
			Next
			For i As Integer = 0 To pGlobalFunctions->Count - 1
				te = pGlobalFunctions->Object(i)
				If CBool(te <> 0) AndAlso CBool(LCase(Trim(te->Name)) = LCase(sWord)) Then 'AndAlso CBool(Not te->TypeProcedure)
					If te->FileName = FileName Then Continue For
					If te = te2 Then Continue For
					.Add te->DisplayName
					.Item(.Count - 1)->Text(1) = te->Parameters
					.Item(.Count - 1)->Text(2) = WStr(te->StartLine + 1)
					.Item(.Count - 1)->Text(3) = WStr(te->StartChar)
					.Item(.Count - 1)->Text(4) = te->FileName
					.Item(.Count - 1)->Text(5) = te->Comment
					.Item(.Count - 1)->Tag = te->Tag
				End If
			Next
			For i As Integer = 0 To pGlobalArgs->Count - 1
				te = Cast(TypeElement Ptr, pGlobalArgs->Object(i))
				If te <> 0 AndAlso LCase(Trim(te->Name)) = LCase(sWord) Then
					If te->FileName = FileName Then Continue For
					If te = te2 Then Continue For
					.Add te->DisplayName
					.Item(.Count - 1)->Text(1) = te->Parameters
					.Item(.Count - 1)->Text(2) = WStr(te->StartLine + 1)
					.Item(.Count - 1)->Text(3) = WStr(te->StartChar)
					.Item(.Count - 1)->Text(4) = te->FileName
					.Item(.Count - 1)->Text(5) = te->Comment
					.Item(.Count - 1)->Tag = te->Tag
				End If
			Next
			For i As Integer = 0 To pComps->Count - 1
				te = pComps->Object(i)
				If te <> 0 AndAlso LCase(Trim(pComps->Item(i))) = LCase(sWord) Then
					If te->FileName = FileName Then Continue For
					If te = te2 Then Continue For
					.Add te->DisplayName
					.Item(.Count - 1)->Text(1) = te->Parameters
					.Item(.Count - 1)->Text(2) = WStr(te->StartLine + 1)
					.Item(.Count - 1)->Text(3) = WStr(te->StartChar)
					.Item(.Count - 1)->Text(4) = te->FileName
					.Item(.Count - 1)->Text(5) = te->Comment
					.Item(.Count - 1)->Tag = te->Tag
				End If
			Next
			For i As Integer = 0 To pGlobalTypes->Count - 1
				te = pGlobalTypes->Object(i)
				If te <> 0 AndAlso LCase(Trim(pGlobalTypes->Item(i))) = LCase(sWord) Then
					If te = te2 Then Continue For
					.Add te->DisplayName
					.Item(.Count - 1)->Text(1) = te->Parameters
					.Item(.Count - 1)->Text(2) = WStr(te->StartLine + 1)
					.Item(.Count - 1)->Text(3) = WStr(te->StartChar)
					.Item(.Count - 1)->Text(4) = te->FileName
					.Item(.Count - 1)->Text(5) = te->Comment
					.Item(.Count - 1)->Tag = te->Tag
				End If
			Next
			For i As Integer = 0 To pGlobalEnums->Count - 1
				te = pGlobalEnums->Object(i)
				If te <> 0 AndAlso LCase(Trim(pGlobalEnums->Item(i))) = LCase(sWord) Then
					If te = te2 Then Continue For
					.Add te->DisplayName
					.Item(.Count - 1)->Text(1) = te->Parameters
					.Item(.Count - 1)->Text(2) = WStr(te->StartLine + 1)
					.Item(.Count - 1)->Text(3) = WStr(te->StartChar)
					.Item(.Count - 1)->Text(4) = te->FileName
					.Item(.Count - 1)->Text(5) = te->Comment
					.Item(.Count - 1)->Tag = te->Tag
					For j As Integer = 0 To te->Elements.Count - 1
						te1 = te->Elements.Object(j)
						If te1 <> 0 AndAlso LCase(Trim(te1->Name)) = LCase(sWord) Then
							If te1 = te2 Then Continue For
							.Add te1->DisplayName
							.Item(.Count - 1)->Text(1) = te1->Parameters
							.Item(.Count - 1)->Text(2) = WStr(te1->StartLine + 1)
							.Item(.Count - 1)->Text(3) = WStr(te1->StartChar)
							.Item(.Count - 1)->Text(4) = te1->FileName
							.Item(.Count - 1)->Text(5) = te1->Comment
							.Item(.Count - 1)->Tag = te1->Tag
						End If
					Next
				End If
			Next
			For i As Integer = 0 To pGlobalNamespaces->Count - 1
				te = pGlobalNamespaces->Object(i)
				If te <> 0 AndAlso LCase(Trim(pGlobalNamespaces->Item(i))) = LCase(sWord) Then
					If te = te2 Then Continue For
					.Add te->DisplayName
					.Item(.Count - 1)->Text(1) = te->Parameters
					.Item(.Count - 1)->Text(2) = WStr(te->StartLine + 1)
					.Item(.Count - 1)->Text(3) = WStr(te->StartChar)
					.Item(.Count - 1)->Text(4) = te->FileName
					.Item(.Count - 1)->Text(5) = te->Comment
					.Item(.Count - 1)->Tag = te->Tag
				End If
			Next
		End If
		If .Count = 0 Then
		ElseIf .Count = 1 Then
			SelectSearchResult .Item(0)->Text(4), Val(.Item(0)->Text(2)), IIf(.Item(0)->Text(3) = "0", -1, Val(.Item(0)->Text(3))), , .Item(0)->Tag, sWord
		Else
			If pfTrek->ShowModal = ModalResults.OK Then
				Var item = pfTrek->SelectedItem
				If item <> 0 Then
					SelectSearchResult item->Text(4), Val(item->Text(2)), IIf(item->Text(3) = "0", -1, Val(item->Text(3))), , item->Tag, sWord
				End If
			End If
		End If
	End With
End Sub
