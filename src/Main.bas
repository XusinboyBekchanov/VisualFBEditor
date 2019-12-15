#include once "Main.bi"
#include once "mff/Dialogs.bi"
#include once "mff/Form.bi"
#include once "mff/TextBox.bi"
#include once "mff/RichTextBox.bi"
#include once "mff/TabControl.bi"
#include once "mff/StatusBar.bi"
#include once "mff/Splitter.bi"
#include once "mff/ToolBar.bi"
#include once "mff/ListControl.bi"
#include once "mff/CheckBox.bi"
#include once "mff/ComboBoxEdit.bi"
#include once "mff/ComboBoxEx.bi"
#include once "mff/RadioButton.bi"
#include once "mff/ProgressBar.bi"
#include once "mff/ScrollBarControl.bi"
#include once "mff/Label.bi"
#include once "mff/Panel.bi"
#include once "mff/TrackBar.bi"
#include once "mff/Clipboard.bi"
#include once "mff/TreeView.bi"
#include once "mff/TreeListView.bi"
#include once "mff/IniFile.bi"

Using My.Sys.Forms
Using My.Sys.Drawing

'Enum TabAsSpacesStyle
'	EveryWhere = 0
'	OnlyАfterWords = 1
'End Enum

'#Include Once "mff/LinkLabel.bi"

#include once "frmSplash.bi"

Dim Shared As frmSplash fSplash: fSplash.Show
Dim Shared As iniFile iniSettings, iniTheme
Dim Shared As Toolbar tbStandard, tbExplorer, tbForm, tbProperties, tbEvents
Dim Shared As StatusBar stBar
Dim Shared As Splitter splLeft, splRight, splBottom, splProperties, splEvents
Dim Shared As ListControl lstLeft
Dim Shared As CheckBox chkLeft
Dim Shared As RadioButton radButton
Dim Shared As ScrollBarControl scrLeft
Dim Shared As Label lblLeft
Dim Shared As Panel pnlLeft, pnlRight, pnlBottom, pnlPropertyValue
Dim Shared As Trackbar trLeft
Dim Shared As ScrollBarControl scrTool
Dim Shared As MainMenu mnuMain
Dim Shared As MenuItem Ptr mnuStartWithCompile, mnuStart, mnuBreak, mnuEnd, mnuRestart, miRecentProjects, miRecentFiles
Dim Shared As SaveFileDialog SaveD
#ifndef __USE_GTK__
	Dim Shared As PageSetupDialog PageSetupD
	Dim Shared As PrintDialog PrintD
	Dim Shared As PrintPreviewDialog PrintPreviewD
	Dim Shared As My.Sys.ComponentModel.Printer pPrinter
#endif
Dim Shared As WStringList GlobalFunctions, AddIns, Comps, mlKeys, mlTexts, MRUFiles, MRUProjects
Dim Shared As Dictionary Compilers, MakeTools, Debuggers, Terminals
Dim Shared As ListView lvErrors, lvSearch
Dim Shared As ProgressBar prProgress
Dim Shared As TextBox txtPropertyValue, txtLabelProperty, txtLabelEvent
Dim Shared As ComboBoxEdit cboPropertyValue
Dim Shared As PopupMenu mnuForm, mnuVars, mnuExplorer, mnuTabs
Dim Shared As ImageList imgList, imgListD, imgListTools, imgListStates
Dim Shared As TreeListView lvProperties, lvEvents
Dim Shared As ToolPalette tbToolBox
Dim Shared As TabControl tabLeft, tabRight, tabDebug
Dim Shared As TreeView tvExplorer, tvVar, tvPrc, tvThd, tvWch
Dim Shared As TextBox txtOutput, txtImmediate
Dim Shared As TabControl tabCode, tabBottom
Dim Shared As Form frmMain
pfrmMain = @frmMain
pSaveD = @SaveD
piniSettings = @iniSettings
piniTheme = @iniTheme
pGlobalFunctions = @GlobalFunctions
pAddIns = @AddIns
pCompilers = @Compilers
pMakeTools = @MakeTools
pDebuggers = @Debuggers
pTerminals = @Terminals
plvSearch = @lvSearch
ptbStandard = @tbStandard
plvProperties = @lvProperties
plvEvents = @lvEvents
pprProgress = @prProgress
ptxtPropertyValue = @txtPropertyValue
ptvExplorer = @tvExplorer
ptabCode = @tabCode
ptabBottom = @tabBottom
ptabRight = @tabRight
pimgList = @imgList
pimgListTools = @imgListTools
pComps = @Comps
LoadLanguageTexts

#include once "file.bi"
#include once "Designer.bi"
#include once "TabWindow.bi"
#include once "Debug.bi"
#include once "frmFind.bi"
#include once "frmGoto.bi"
#include once "frmFindInFiles.bi"
#include once "frmAddIns.bi"
#include once "frmAbout.bi"
#include once "frmOptions.bi"
#include once "frmParameters.bi"
#include once "frmProjectProperties.bi"

Function ML(ByRef V As WString) ByRef As WString
	If mlKeys.Contains(V) Then
		If mlTexts.Item(mlKeys.IndexOf(V)) <> "" Then
			Return mlTexts.Item(mlKeys.IndexOf(V))
		End If
	End If
	Return V
End Function

Sub ToolGroupsToCursor()
	tbToolBox.Groups.Item(0)->Buttons.Item(0)->Checked = True 
	tbToolBox.Groups.Item(1)->Buttons.Item(0)->Checked = True
	tbToolBox.Groups.Item(2)->Buttons.Item(0)->Checked = True
	tbToolBox.Groups.Item(3)->Buttons.Item(0)->Checked = True
End Sub

Sub ClearMessages()
	txtOutput.Text = ""
	txtOutput.Update
End Sub

Sub tabCode_Paint(ByRef Sender As Control) '...'
	MoveCloseButtons
End Sub

Sub SelectError(ByRef FileName As WString, iLine As Integer, tabw As TabWindow Ptr = 0)
	Dim tb As TabWindow Ptr
	If tabw <> 0 AndAlso ptabCode->IndexOfTab(tabw) <> -1 Then
		tb = tabw
		tb->SelectTab
	Else
		If FileName = "" Then Exit Sub
		tb = AddTab(FileName)
	End If
	tb->txtCode.SetSelection iLine - 1, iLine - 1, 0, tb->txtCode.LineLength(iLine - 1)
End Sub

Sub lvProperties_CellEditing(ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr, ByVal SubItemIndex As Integer, CellEditor As Control Ptr)
	CellEditor = @cboPropertyValue
End Sub

Sub lvProperties_CellEdited(ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr, ByVal SubItemIndex As Integer, ByRef NewText As WString)
	PropertyChanged Sender, NewText, False
End Sub

Sub txtPropertyValue_LostFocus(ByRef Sender As Control)
	PropertyChanged Sender, Sender.Text, False
End Sub

Sub cboPropertyValue_Change(ByRef Sender As Control)
	PropertyChanged Sender, Sender.Text, True
End Sub

Function GetShortFileName(ByRef FileName As WString, ByRef FilePath As WString) ByRef As WString
	If StartsWith(FileName, GetFolderName(FilePath)) Then
		WLet sTemp, Mid(FileName, Len(GetFolderName(FilePath)) + 1)
		Return *sTemp
	Else
		Return FileName
	End If
End Function

Function GetFirstCompileLine(ByRef FileName As WString, ByRef Project As ProjectElement Ptr) ByRef As WString
	Dim As Boolean Bit32 = tbStandard.Buttons.Item("B32")->Checked
	If Project Then
		#ifdef __USE_GTK__
			WLet sTemp2, IIf(Bit32, *Project->CompilationArguments32Linux, WGet(Project->CompilationArguments64Linux))
		#else
			WLet sTemp2, IIf(Bit32, *Project->CompilationArguments32Windows, WGet(Project->CompilationArguments64Windows))
		#endif
		#ifdef __FB_WIN32__
			If WGet(Project->ResourceFileName) <> "" Then WLet sTemp2, *sTemp2 & " """ & GetShortFileName(WGet(Project->ResourceFileName), FileName) & """"
		#else
			If WGet(Project->IconResourceFileName) <> "" Then WLet sTemp2, *sTemp2 & " """ & GetShortFileName(WGet(Project->IconResourceFileName), FileName) & """"
		#endif
		Select Case Project->ProjectType
		Case 0
		Case 1: WAdd sTemp2, " -dll"
		Case 2: WAdd sTemp2, " -lib"
		End Select
	Else
		WLet sTemp2, ""
	End If
	WAdd sTemp2, " " & IIf(Bit32, *Compiler32Arguments, *Compiler64Arguments)
	If Open(FileName For Input Encoding "utf-8" As #1) = 0 Then
		Dim sLine As WString Ptr
		Dim As Integer i, n, l = 0
		Dim As Boolean k(10)
		k(l) = True
		WReallocate sLine, LOF(1)
		Do Until EOF(1)
			Line Input #1, *sLine
			If StartsWith(LTrim(LCase(*sLine), Any !"\t "), "#ifdef __fb_win32__") Then
				l = l + 1
				#ifdef __FB_WIN32__
					k(l) = True
				#else
					k(l) = False
				#endif
			ElseIf StartsWith(LTrim(LCase(*sLine), Any !"\t "), "#ifndef __fb_win32__") Then
				l = l + 1
				#ifndef __FB_WIN32__
					k(l) = True
				#else
					k(l) = False
				#endif
			ElseIf StartsWith(LTrim(LCase(*sLine), Any !"\t "), "#ifdef __fb_64bit__") Then
				l = l + 1
				k(l) = tbStandard.Buttons.Item("B64")->Checked
			ElseIf StartsWith(LTrim(LCase(*sLine), Any !"\t "), "#ifndef __fb_64bit__") Then
				l = l + 1
				k(l) = Not tbStandard.Buttons.Item("B64")->Checked
			ElseIf StartsWith(LTrim(LCase(*sLine), Any !"\t "), "#else") Then
				k(l) = Not k(l)
			ElseIf StartsWith(LTrim(LCase(*sLine), Any !"\t "), "#endif") Then
				l = l - 1
				If l < 0 Then 
					Close #1
					Return *sTemp2
				End If
			Else
				For i = 0 To l
					If k(i) = False Then Exit For
				Next
				If i > l Then
					Close #1
					If StartsWith(LTrim(LCase(*sLine), Any !"\t "), "'#compile ") Then
						WLet sTemp2, Mid(LTrim(*sLine, Any !"\t "), 11) & " " & *sTemp2
					End If
					WDeallocate sLine
					Return *sTemp2
				End If
			End If
			If l >= 10 Then
				Close #1
				WDeallocate sLine
				Return *sTemp2
			End If
		Loop
		Close #1
		WDeallocate sLine
	End If
	Return *sTemp2
End Function

#ifdef __FB_WIN32__
	#define Slash "\"
#else
	#define Slash "/"
#endif

Function GetFullPath(ByRef Path As WString) ByRef As WString
	If CInt(Not StartsWith(Path, "\\")) AndAlso CInt(InStr(Path, ":") = 0) Then
		WLet sTemp, ExePath & Slash & Path
		Return Replace(*sTemp, "/", "\")
	Else
		Return Path
	End If
End Function

Function Compile(Parameter As String = "") As Integer
	On Error Goto ErrorHandler
	Dim As ProjectElement Ptr Project
	Dim As TreeNode Ptr ProjectNode
	ThreadsEnter()
	Dim MainFile As WString Ptr: WLet MainFile, GetMainFile(AutoSaveCompile, Project, ProjectNode)
	ThreadsLeave()
	Dim FirstLine As WString Ptr: WLet FirstLine, GetFirstCompileLine(*MainFile, Project)
	Versioning *MainFile, *FirstLine, Project, ProjectNode
	Dim FileOut As Integer
	Dim FbcExe As WString Ptr
	Dim ExeName As WString Ptr: WLet ExeName, GetExeFileName(*MainFile, *FirstLine)
	'Dim LogFileName As WString Ptr
	Dim LogFileName2 As WString Ptr
	Dim BatFileName As WString Ptr
	Dim fbcCommand As WString Ptr
	Dim CompileWith As WString Ptr
	Dim MFFPathC As WString Ptr
	Dim As WString Ptr ErrFileName, ErrTitle
	Dim As Integer iLine
	Dim LogText As WString Ptr
	Dim As Boolean Bit32 = tbStandard.Buttons.Item("B32")->Checked
	If Len(*MainFile) <= 0 Then
		ThreadsEnter() 
		ShowMessages ML("No Main file found")& "!"  'David Adding 
		ThreadsLeave() 
		Return 0
	End If
	WLet MFFPathC, *MFFPath
	If CInt(InStr(*MFFPathC, ":") = 0) AndAlso CInt(Not StartsWith(*MFFPathC, "/")) Then WLet MFFPathC, ExePath & "/" & *MFFPath
	FbcExe = IIf(Bit32, Compiler32Path, Compiler64Path)
	#ifdef __USE_GTK__
		If g_find_program_in_path(*FbcExe) = NULL Then
	#else
		If Not FileExists(*FbcExe) Then
	#endif
		ThreadsEnter()
		ShowMessages ML("File") & " """ & *FbcExe & """ " & ML("not found") & "!"
		ThreadsLeave()
		Return 0
	End If
	
	WLet BatFileName, ExePath + "/debug.bat"
	Dim As Boolean Band, Yaratilmadi
	ChDir(GetFolderName(*MainFile))
	If Parameter = "Check" Then
		WLet ExeName, "chk.dll"
	End If
	ClearMessages
	If *FbcExe <> "" Then
		FileOut = FreeFile
		If Dir(*ExeName) <> "" Then 'delete exe if exist
			If Kill(*ExeName) <> 0 Then
				'ShowMessages(Str(Time) & ": " & "Exe fayl band.")
				Band = True
				'Return 0
			End If
		End If
		WLet CompileWith, *FirstLine
		If CInt(InStr(*CompileWith, " -s ") = 0) AndAlso CInt(tbStandard.Buttons.Item("Form")->Checked) Then
			WLet CompileWith, *CompileWith & " -s gui"
		End If
		If CInt(UseDebugger) OrElse CInt(CInt(Project) AndAlso CInt(Project->CreateDebugInfo)) Then WLet CompileWith, *CompileWith & " -g"
		If Project Then
			If Project->CompileToGCC Then 
				WLet CompileWith, *CompileWith & " -gen gcc" & IIf(Project->OptimizationLevel > 0, " -Wc -O" & WStr(Project->OptimizationLevel), IIf(Project->OptimizationFastCode, " -Wc -Ofast", IIf(Project->OptimizationSmallCode, " -Wc -Os", "")))
			End If
			
		End If
		'WLet LogFileName, ExePath & "/Temp/debug_compil.log"
		WLet LogFileName2, ExePath & "/Temp/debug_compil2.log"
		WLet fbcCommand, " -b """ & GetFileName(*MainFile) & """ " & *CompileWith & " -i """ & *MFFPathC & """"
		If Parameter <> "" AndAlso Parameter <> "Make" AndAlso Parameter <> "MakeClean" Then
			If Parameter = "Check" Then WLet fbcCommand, *fbcCommand & " -x """ & *ExeName & """" Else WLet fbcCommand, *fbcCommand
		End If
		Dim As WString Ptr PipeCommand
		If CInt(Parameter = "Make") OrElse CInt(CInt(Parameter = "Run") AndAlso CInt(UseMakeOnStartWithCompile) AndAlso CInt(FileExists(GetFolderName(*MainFile) & "/makefile"))) Then
			Dim As String Colon = ""
			#ifdef __USE_GTK__
				Colon = ":"
			#endif
			WLet PipeCommand, """" & *MakeToolPath & """ FBC" & Colon & "=""""""" & *fbcexe & """"""" XFLAG" & Colon & "=""-x """"" & *ExeName & """""""" & IIf(UseDebugger, " GFLAG" & Colon & "=-g", "") & " " & *Make1Arguments
		ElseIf Parameter = "MakeClean" Then
			WLet PipeCommand, """" & *MakeToolPath & """ " & *Make2Arguments
		Else
			WLet PipeCommand, """" & *fbcexe & """ " & *fbcCommand
		End If
		If Parameter <> "Check" Then 
			ThreadsEnter()
			ShowMessages(Str(Time) + ": " + IIf(Parameter = "MakeClean", ML("Clean"), ML("Compilation")) & ": " & *PipeCommand & " ..." + WChr(13) + WChr(10))
			ThreadsLeave()
		End If
		'OPEN *BatFileName For Output As #FileOut
		'Print #FileOut, *fbcCommand  + " > """ + *LogFileName + """" + " 2>""" + *LogFileName2 + """"
		'Close #FileOut
		'Shell("""" + BatFileName + """")
		ChDir(GetFolderName(*MainFile))
		'Shell(*fbcCommand  + "> """ + *LogFileName + """" + " 2> """ + *LogFileName2 + """")
		'Open Pipe *fbcCommand  + "> """ + *LogFileName + """" + " 2> """ + *LogFileName2 + """" For Input As #1
		'Close #1
		'PipeCmd "", *PipeCommand & " > """ + *LogFileName + """" + " 2> """ + *LogFileName2 + """"
		ThreadsEnter()
		StartProgress
		lvErrors.ListItems.Clear
		ThreadsLeave()
		Dim As Long nLen, nLen2
		Dim As Boolean Log2_
		#ifdef __USE_GTK__
			If Open Pipe(*PipeCommand & " 2> """ + *LogFileName2 + """" For Input As #1) = 0 Then
		#else
			If Open Pipe("""" & *PipeCommand & " 2> """ + *LogFileName2 + """" & """" For Input As #1) = 0 Then
				ShowWindow(getconsolewindow,SW_HIDE)
		#endif
			nLen = LOF(1) + 1
			Dim Buff As String
			WReallocate LogText, nLen * 2 + 2
			*LogText = ""
			'WLet Buff, Space(nLen)
			While Not EOF(1)
				Line Input #1, Buff
				SplitError(Buff, ErrFileName, ErrTitle, iLine)
				ThreadsEnter()
				If *ErrFileName <> "" AndAlso InStr(*ErrFileName, "/") = 0 AndAlso InStr(*ErrFileName, "\") = 0 Then WLet ErrFileName, GetFolderName(*MainFile) & *ErrFileName
				lvErrors.ListItems.Add *ErrTitle, IIf(InStr(*ErrTitle, "warning"), "Warning", IIf(InStr(LCase(*ErrTitle), "error"), "Error", "Info"))
				lvErrors.ListItems.Item(lvErrors.ListItems.Count - 1)->Text(1) = WStr(iLine)
				lvErrors.ListItems.Item(lvErrors.ListItems.Count - 1)->Text(2) = *ErrFileName
				ShowMessages(Buff, False)
				ThreadsLeave()
				'*LogText = *LogText & *Buff & WChr(13) & WChr(10)
			Wend
			'WDeallocate Buff
			Close #1
		End If
		WDeallocate PipeCommand
		#ifdef __USE_GTK__
			Yaratilmadi = g_find_program_in_path(*ExeName) = NULL
		#else
			Yaratilmadi = Dir(*ExeName) = ""
		#endif
		'		If Open(*LogFileName For Input As #1) = 0 Then
		'			nLen = LOF(1) + 1
		'			Dim Buff As WString Ptr
		'			WReallocate LogText, nLen * 2 + 2
		'			*LogText = ""
		'			WLet Buff, Space(nLen)
		'			While Not EOF(1)
		'				Line Input #1, *Buff
		'				SplitError(*Buff, ErrFileName, ErrTitle, iLine)
		'				ThreadsEnter()
		'				If *ErrFileName <> "" AndAlso InStr(*ErrFileName, "/") = 0 AndAlso InStr(*ErrFileName, "\") = 0 Then WLet ErrFileName, GetFolderName(*MainFile) & *ErrFileName
		'				lvErrors.ListItems.Add *ErrTitle, IIF(Instr(*ErrTitle, "warning"), "Warning", IIF(Instr(lcase(*ErrTitle), "error"), "Error", "Info"))
		'				lvErrors.ListItems.Item(lvErrors.ListItems.Count - 1)->Text(1) = WStr(iLine)
		'				lvErrors.ListItems.Item(lvErrors.ListItems.Count - 1)->Text(2) = *ErrFileName
		'				ThreadsLeave()
		'				*LogText = *LogText & *Buff & WChr(13) & WChr(10)
		'			Wend
		'			WDeallocate Buff
		'			Close #1
		'		End If
		
		If Open(*LogFileName2 For Input As #2) = 0 Then
			nLen2 = LOF(2) + 1
			Dim Buff As String
			'WReallocate LogText, (nLen + nLen2) * 2 + 2
			'WLet Buff, Space(nLen2)
			While Not EOF(2)
				Line Input #2, Buff
				'If Trim(*Buff) <> "" Then lvErrors.ListItems.Add *Buff
				SplitError(Buff, ErrFileName, ErrTitle, iLine)
				ThreadsEnter()
				If *ErrFileName <> "" AndAlso InStr(*ErrFileName, "/") = 0 AndAlso InStr(*ErrFileName, "\") = 0 Then WLet ErrFileName, GetFolderName(*MainFile) & *ErrFileName
				lvErrors.ListItems.Add *ErrTitle, IIf(InStr(*ErrTitle, "warning"), "Warning", IIf(InStr(LCase(*ErrTitle), "error"), "Error", "Info"))
				lvErrors.ListItems.Item(lvErrors.ListItems.Count - 1)->Text(1) = WStr(iLine)
				lvErrors.ListItems.Item(lvErrors.ListItems.Count - 1)->Text(2) = *ErrFileName
				ShowMessages(Buff, False)
				ThreadsLeave()
				'*LogText = *LogText & *Buff & WChr(13) & WChr(10)
				Log2_ = True
			Wend
			Close #2
			'WDeallocate Buff
		End If
		ThreadsEnter()
		If lvErrors.ListItems.Count <> 0 Then
			ptabBottom->Tabs[1]->Caption = ML("Errors") & " (" & lvErrors.ListItems.Count & " " & ML("Pos") & ")"
		Else
			ptabBottom->Tabs[1]->Caption = ML("Errors")
		End If
		'ShowMessages(*LogText)
		ThreadsLeave()
		'If LogFileName Then Deallocate LogFileName
		If LogFileName2 Then Deallocate LogFileName2
		If BatFileName Then Deallocate BatFileName
		WDeallocate fbcCommand
		WDeallocate CompileWith
		WDeallocate MFFPathC
		WDeallocate MainFile
		WDeallocate FirstLine
		WDeallocate ExeName
		ThreadsEnter()
		ShowMessages("")
		StopProgress
		ThreadsLeave()
		If Yaratilmadi Or Band Then
			ThreadsEnter()
			If Parameter <> "Check" Then
				ShowMessages(Str(Time) & ": " & ML("Do not build file."))
				If (Not Log2_) AndAlso lvErrors.ListItems.Count <> 0 Then ptabBottom->Tabs[1]->SelectTab
			ElseIf lvErrors.ListItems.Count <> 0 Then
				ShowMessages(Str(Time) & ": " & ML("Checking ended."))
				ptabBottom->Tabs[1]->SelectTab
			Else
				ShowMessages(Str(Time) & ": " & ML("No errors or warnings were found."))
			End If
			ThreadsLeave()
			WDeallocate LogText
			Return 0
		Else
			ThreadsEnter()
			If InStr(*LogText, "warning") > 0 Then
				If Parameter <> "Check" Then
					ShowMessages(Str(Time) & ": " & ML("Layout has been successfully completed, but there are warnings."))
				End If
			Else
				If Parameter <> "Check" Then
					ShowMessages(Str(Time) & ": " & ML("Layout succeeded!"))
				Else
					ShowMessages(Str(Time) & ": " & ML("Syntax errors not found!"))
				End If
			End If
			ThreadsLeave()
			WDeallocate LogText
			Return 1
		End If
	Else
		WDeallocate LogText
		Return 0
	End If
	Exit Function
	ErrorHandler:
	ThreadsEnter()
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " " & _
	"in function " & ZGet(Erfn()) & " " & _
	"in module " & ZGet(Ermn())
	ThreadsLeave()
End Function

Sub SelectSearchResult(ByRef FileName As WString, iLine As Integer, iSelStart As Integer, iSelLength As Integer, tabw As TabWindow Ptr = 0)
	Dim tb As TabWindow Ptr
	If tabw <> 0 AndAlso ptabCode->IndexOfTab(tabw) <> -1 Then
		tb = tabw
		tb->SelectTab
	Else
		If FileName = "" Then Exit Sub
		tb = AddTab(FileName)
	End If
	tb->txtCode.SetSelection iLine - 1, iLine - 1, iSelStart - 1, iSelStart + iSelLength - 1
End Sub

Sub txtOutput_DblClick(ByRef Sender As Control)
	Dim Buff As WString Ptr = @txtOutput.Lines(txtOutput.GetLineFromCharIndex)
	Dim As WString Ptr ErrFileName, ErrTitle
	Dim As ProjectElement Ptr Project
	Dim As TreeNode Ptr ProjectNode
	Dim As Integer iLine
	SplitError(*Buff, ErrFileName, ErrTitle, iLine)
	Dim MainFile As WString Ptr: WLet MainFile, GetMainFile(False, Project, ProjectNode)
	If *ErrFileName <> "" AndAlso InStr(*ErrFileName, "/") = 0 AndAlso InStr(*ErrFileName, "\") = 0 Then WLet ErrFileName, GetFolderName(*MainFile) & *ErrFileName
	WDeallocate MainFile
	SelectError(*ErrFileName, iLine)
End Sub

Function GetTreeNodeChild(tn As TreeNode Ptr, ByRef FileName As WString) As TreeNode Ptr
	If tbExplorer.Buttons.Item(3)->Checked Then
		If EndsWith(FileName, ".bi") Then
			Return tn->Nodes.Item(0) 
		ElseIf EndsWith(FileName, ".bas") OrElse EndsWith(FileName, ".inc") Then
			Return tn->Nodes.Item(1)
		ElseIf EndsWith(FileName, ".rc") Then
			Return tn->Nodes.Item(2)
		Else
			Return tn->Nodes.Item(3)
		End If
	Else
		Return tn
	End If
End Function

Sub AddMRUProject(ByRef FileName As WString)
	Var i = MRUProjects.IndexOf(FileName)
	If i <> 0 Then
		If i > 0 Then MRUProjects.Remove i
		MRUProjects.Insert 0, FileName
		For i = 0 To Min(miRecentProjects->Count - 1, MRUProjects.Count - 1)
			miRecentProjects->Item(i)->Caption = MRUProjects.Item(i)
			miRecentProjects->Item(i)->Name = MRUProjects.Item(i)
		Next
		For i = i To Min(9, MRUProjects.Count - 1)
			miRecentProjects->Add(MRUProjects.Item(i), "", MRUProjects.Item(i), @mClickMRU)
		Next
	End If
End Sub

'Extern "rtlib"
'   Declare Function LineInputWstr Alias "fb_FileLineInputWstr"_
'      ( _
'         ByVal filenumber As Long, _
'         ByVal dst As WString Ptr, _
'         ByVal maxchars As Integer _
'      ) As Long
'End Extern

Dim Shared As ExplorerElement Ptr ee, pee
Dim Shared As TreeNode Ptr tn, tn3
Function AddProject(ByRef FileName As WString = "") As TreeNode Ptr
	If FileName <> "" Then
		AddMRUProject FileName
		Dim As WString Ptr buff
		Dim As Integer Pos1
		For i As Integer = 0 To tvExplorer.Nodes.Count - 1
			If tvExplorer.Nodes.Item(i)->Tag <> 0 AndAlso LCase(Replace(*Cast(ExplorerElement Ptr, tvExplorer.Nodes.Item(i)->Tag)->FileName, "\", "/")) = LCase(Replace(FileName, "\", "/", , , 1)) Then
				tvExplorer.Nodes.Item(i)->SelectItem
				Return tvExplorer.Nodes.Item(i)
			End If
		Next
		tn = tvExplorer.Nodes.Add(GetFileName(FileName), , FileName, "Project", "Project")
	Else
		Var n = 0
		Dim NewName As String
		Do
			n = n + 1
			NewName = "Project" & Str(n)
		Loop While tvExplorer.Nodes.Contains(NewName)
		tn = tvExplorer.Nodes.Add(NewName & " *", , , "Project", "Project")
	End If
	'If tn <> 0 Then
	If tbExplorer.Buttons.Item(3)->Checked Then
		tn->Nodes.Add ML("Includes"), "Includes", , "Opened", "Opened"
		tn->Nodes.Add ML("Sources"), "Sources", , "Opened", "Opened"
		tn->Nodes.Add ML("Resources"), "Resources", , "Opened", "Opened"
		tn->Nodes.Add ML("Others"), "Others", , "Opened", "Opened"
		'End if
	End If
	tn->SelectItem
	If FileName <> "" Then
		If Not FileExists(FileName) Then
			MsgBox ML("File not found") & ": " & FileName
			Return tn
		End If
		Dim As TreeNode Ptr tn1, tn2
		Dim buff As WString Ptr
		Dim Pos1 As Integer
		Dim bMain As Boolean
		Dim As ProjectElement Ptr ppe
		pee = New ExplorerElement
		WLet pee->FileName, FileName
		ppe = New ProjectElement
		pee->Project = ppe
		tn->Tag = pee
		Dim As String Parameter
		If Open(FileName For Input Encoding "utf-8" As #1) = 0 Then
			WReallocate buff, LOF(1)
			Do Until EOF(1)
				'LineInputWstr 1, buff, LOF(1)
				Line Input #1, *buff
				Pos1 = InStr(*buff, "=")
				If Pos1 <> 0 Then
					Parameter = Left(*buff, Pos1 - 1)
				Else
					Parameter = ""
				End If
				If Parameter = "File" OrElse Parameter = "*File" Then
					bMain = StartsWith(*buff, "*")
					*buff = Mid(*buff, Pos1 + 1)
					ee = New ExplorerElement
					If CInt(InStr(*buff, ":") = 0) OrElse CInt(StartsWith(*buff, "/")) Then
						#ifdef __USE_GTK__
							WLet ee->FileName, GetFolderName(FileName) & *buff
						#else
							WLet ee->FileName, GetFolderName(FileName) & Replace(*buff, "/", "\")
						#endif
					Else
						WLet ee->FileName, *buff
					End If
					tn1 = GetTreeNodeChild(tn, *buff)
					tn2 = tn1->Nodes.Add(GetFileName(*ee->FileName), , *ee->FileName, "File", "File", True)
					tn2->Tag = ee
					tn1->Expand
					If bMain Then
						If EndsWith(*ee->FileName, ".rc") OrElse EndsWith(*ee->FileName, ".res") Then
							WLet ppe->ResourceFileName, *ee->FileName
						ElseIf EndsWith(*ee->FileName, ".xpm") Then
							WLet ppe->IconResourceFileName, *ee->FileName
						Else
							WLet ppe->MainFileName, *ee->FileName
						End If
					End If
				ElseIf Parameter = "ProjectType" Then
					ppe->ProjectType = Val(Mid(*Buff, Pos1 + 1))
				ElseIf Parameter = "ProjectName" Then
					WLet ppe->ProjectName, Mid(*Buff, Pos1 + 2, Len(*Buff) - Pos1 - 2)
				ElseIf Parameter = "HelpFileName" Then
					WLet ppe->HelpFileName, Mid(*Buff, Pos1 + 2, Len(*Buff) - Pos1 - 2)
				ElseIf Parameter = "ProjectDescription" Then
					WLet ppe->ProjectDescription, Mid(*Buff, Pos1 + 2, Len(*Buff) - Pos1 - 2)
				ElseIf Parameter = "MajorVersion" Then
					ppe->MajorVersion = Val(Mid(*Buff, Pos1 + 1))
				ElseIf Parameter = "MinorVersion" Then
					ppe->MinorVersion = Val(Mid(*Buff, Pos1 + 1))
				ElseIf Parameter = "RevisionVersion" Then
					ppe->RevisionVersion = Val(Mid(*Buff, Pos1 + 1))
				ElseIf Parameter = "BuildVersion" Then
					ppe->BuildVersion = Val(Mid(*Buff, Pos1 + 1))
				ElseIf Parameter = "AutoIncrementVersion" Then
					ppe->AutoIncrementVersion = CBool(Mid(*Buff, Pos1 + 1))
				ElseIf Parameter = "ApplicationTitle" Then
					WLet ppe->ApplicationTitle, Mid(*Buff, Pos1 + 2, Len(*Buff) - Pos1 - 2)
				ElseIf Parameter = "ApplicationIcon" Then
					WLet ppe->ApplicationIcon, Mid(*Buff, Pos1 + 2, Len(*Buff) - Pos1 - 2)
				ElseIf Parameter = "CompanyName" Then
					WLet ppe->CompanyName, Mid(*Buff, Pos1 + 2, Len(*Buff) - Pos1 - 2)
				ElseIf Parameter = "FileDescription" Then
					WLet ppe->FileDescription, Mid(*Buff, Pos1 + 2, Len(*Buff) - Pos1 - 2)
				ElseIf Parameter = "InternalName" Then
					WLet ppe->InternalName, Mid(*Buff, Pos1 + 2, Len(*Buff) - Pos1 - 2)
				ElseIf Parameter = "LegalCopyright" Then
					WLet ppe->LegalCopyright, Mid(*Buff, Pos1 + 2, Len(*Buff) - Pos1 - 2)
				ElseIf Parameter = "LegalTrademarks" Then
					WLet ppe->LegalTrademarks, Mid(*Buff, Pos1 + 2, Len(*Buff) - Pos1 - 2)
				ElseIf Parameter = "OriginalFilename" Then
					WLet ppe->OriginalFilename, Mid(*Buff, Pos1 + 2, Len(*Buff) - Pos1 - 2)
				ElseIf Parameter = "ProductName" Then
					WLet ppe->ProductName, Mid(*Buff, Pos1 + 2, Len(*Buff) - Pos1 - 2)
				ElseIf Parameter = "CompileToGCC" Then
					ppe->CompileToGCC = CBool(Mid(*Buff, Pos1 + 1))
				ElseIf Parameter = "OptimizationLevel" Then
					ppe->OptimizationLevel = Val(Mid(*Buff, Pos1 + 1))
				ElseIf Parameter = "OptimizationFastCode" Then
					ppe->OptimizationFastCode = CBool(Mid(*Buff, Pos1 + 1))
				ElseIf Parameter = "OptimizationSmallCode" Then
					ppe->OptimizationFastCode = CBool(Mid(*Buff, Pos1 + 1))
				ElseIf Parameter = "CompilationArguments32Windows" Then
					WLet ppe->CompilationArguments32Windows, Mid(*Buff, Pos1 + 2, Len(*Buff) - Pos1 - 2)
				ElseIf Parameter = "CompilationArguments64Windows" Then
					WLet ppe->CompilationArguments64Windows, Mid(*Buff, Pos1 + 2, Len(*Buff) - Pos1 - 2)
				ElseIf Parameter = "CompilationArguments32Linux" Then
					WLet ppe->CompilationArguments32Linux, Mid(*Buff, Pos1 + 2, Len(*Buff) - Pos1 - 2)
				ElseIf Parameter = "CompilationArguments64Linux" Then
					WLet ppe->CompilationArguments64Linux, Mid(*Buff, Pos1 + 2, Len(*Buff) - Pos1 - 2)
				ElseIf Parameter = "CommandLineArguments" Then
					WLet ppe->CommandLineArguments, Mid(*Buff, Pos1 + 2, Len(*Buff) - Pos1 - 2)
				ElseIf Parameter = "CreateDebugInfo" Then
					ppe->CreateDebugInfo = CBool(Mid(*Buff, Pos1 + 1))
				End If
			Loop
			Close #1
		End If
	End If
	tn->Expand
	pfProjectProperties->RefreshProperties
	Return tn
End Function

Sub OpenProject()
	Dim As OpenFileDialog OpenD
	OpenD.Filter = ML("VisualFBEditor Project") & " (*.vfp)|*.vfp|" & ML("All Files") & "|*.*|"
	If Not OpenD.Execute Then Exit Sub
	AddProject OpenD.FileName
	TabLeft.Tabs[0]->SelectTab
End Sub

Function AddSession(ByRef FileName As WString) As Boolean
	If Open(FileName For Input Encoding "utf-8" As #3) = 0 Then
		Dim As WString Ptr buff
		Dim As WString Ptr filn
		Dim As Boolean bMain
		Dim As Integer Pos1 
		WReallocate buff, LOF(3)
		Do Until EOF(3)
			'LineInputWstr 3, buff, LOF(3)
			Line Input #3, *buff
			If StartsWith(*buff, "File=") OrElse StartsWith(*buff, "*File=") Then
				Pos1 = InStr(*buff, "=")
				If Pos1 <> 0 Then
					bMain = StartsWith(*buff, "*")
					WLet filn, Mid(*buff, Pos1 + 1)
					If CInt(InStr(*filn, ":") = 0) OrElse CInt(StartsWith(*filn, "/")) Then
						#ifdef __USE_GTK__
							WLet filn, GetFolderName(FileName) & *filn
						#else
							WLet filn, GetFolderName(FileName) & Replace(*filn, "/", "\")
						#endif
					End If
					Dim tn As TreeNode Ptr
					If EndsWith(*filn, ".vfp") Then
						tn = AddProject(*filn)
					Else
						Var tb = AddTab(*filn)
						If tb Then tn = tb->tn
					End If
					If bMain Then
						MainNode = tn
						lblLeft.Text = ML("Main File") & ": " & MainNode->Text
					End If
				End If
			End If
		Loop
		Close #3
		WDeallocate filn
		WDeallocate buff
		Return True
	End If
	Return False
End Function

Sub OpenSession()
	Dim As OpenFileDialog OpenD
	OpenD.Filter = ML("VisualFBEditor Session") & " (*.vfs)|*.vfs|" & ML("All Files") & "|*.*|"
	OpenD.InitialDir = GetFullPath(*ProjectsPath)
	If Not OpenD.Execute Then Exit Sub
	AddSession OpenD.FileName
	TabLeft.Tabs[0]->SelectTab
End Sub

Sub AddMRUFile(ByRef FileName As WString)
	Var i = MRUFiles.IndexOf(FileName)
	If i <> 0 Then
		If i > 0 Then MRUFiles.Remove i
		MRUFiles.Insert 0, FileName
		For i = 0 To Min(miRecentFiles->Count - 1, MRUFiles.Count - 1)
			miRecentFiles->Item(i)->Caption = MRUFiles.Item(i)
			miRecentFiles->Item(i)->Name = MRUFiles.Item(i)
		Next
		For i = i To Min(9, MRUFiles.Count - 1)
			miRecentFiles->Add(MRUFiles.Item(i), "", MRUFiles.Item(i), @mClickMRU)
		Next
	End If
End Sub

Sub OpenFiles(ByRef FileName As WString)
	If EndsWith(FileName, ".vfs") Then
		AddSession FileName
	ElseIf EndsWith(FileName, ".vfp") Then
		AddProject FileName
	Else
		AddMRUFile FileName
		AddTab FileName
	End If
End Sub

Sub OpenProgram()
	Dim As OpenFileDialog OpenD
	OpenD.InitialDir = GetFullPath(*ProjectsPath)
	OpenD.Filter = ML("FreeBasic Files") & " (*.vfs, *.vfp, *.bas, *.bi, *.rc)|*.vfs;*.vfp;*.bas;*.bi;*.rc|" & ML("VisualFBEditor Session") & " (*.vfs)|" & ML("VisualFBEditor Project") & " (*.vfp)|*.vfp|" & ML("FreeBasic Module") & " (*.bas)|*.bas|" & ML("FreeBasic Include File") & " (*.bi)|*.bi|" & ML("FreeBasic Resource Files") & " (*.rc)|*.rc|" & ML("All Files") & "|*.*|"
	If OpenD.Execute Then
		OpenFiles(OpenD.Filename)
	End If
	TabLeft.Tabs[0]->SelectTab
End Sub

Function SaveSession() As Boolean
	SaveD.Filter = ML("VisualFBEditor Session") & " (*.vfs)|*.vfs|"
	SaveD.InitialDir = GetFullPath(*ProjectsPath)
	If Not SaveD.Execute Then Return False
	If FileExists(SaveD.Filename) Then
		Select Case MsgBox(ML("Want to replace the session") & " """ & SaveD.Filename & """?", "Visual FB Editor", mtWarning, btYesNo)
		Case mrYES: 
		Case mrNO: Return SaveSession()
		End Select
	End If
	Dim As TreeNode Ptr tn1
	Dim As Integer p
	Dim As String Zv
	If Open(SaveD.Filename For Output Encoding "utf-8" As #1) = 0 Then
		For i As Integer = 0 To tvExplorer.Nodes.Count - 1
			tn1 = tvExplorer.Nodes.Item(i)
			ee = tn1->Tag
			If ee = 0 Then Continue For
			Zv = IIf(tn1 = MainNode, "*", "")
			If StartsWith(*ee->FileName, GetFolderName(SaveD.Filename)) Then
				Print #1, Zv & "File=" & Replace(Mid(*ee->FileName, Len(GetFolderName(SaveD.Filename)) + 1), "\", "/")
			Else
				Print #1, Zv & "File=" & *ee->FileName
			End If
		Next
		Close #1
	End If
	Return True
End Function

Function SaveProject(ByRef tn As TreeNode Ptr, bWithQuestion As Boolean = False) As Boolean
	If tn = 0 Then Return True
	If tn->ImageKey <> "Project" Then Return True
	pee = tn->Tag
	If pee = 0 OrElse WGet(pee->FileName) = "" Then
		SaveD.FileName = Left(tn->Text, Len(tn->Text) - IIf(EndsWith(tn->Text, " *"), 2, 0))
		SaveD.InitialDir = GetFullPath(*ProjectsPath)
		SaveD.Filter = ML("VisualFBEditor Project") & " (*.vfp)|*.vfp|"
		If Not SaveD.Execute Then Return False
		If FileExists(SaveD.Filename) Then
			Select Case MsgBox(ML("Want to replace the project") & " """ & SaveD.Filename & """?", "Visual FB Editor", mtWarning, btYesNo)
			Case mrYES:
			Case mrNO: Return SaveProject(tn, bWithQuestion)
			End Select
		End If
		pee = New ExplorerElement
		WLet pee->FileName, SaveD.FileName
		AddMRUProject SaveD.FileName
	End If
	Dim As TreeNode Ptr tn1, tn2
	Dim As String Zv = "*"
	Open *pee->FileName For Output Encoding "utf-8" As #1
	For i As Integer = 0 To tn->Nodes.Count - 1
		tn1 = tn->Nodes.Item(i)
		ee = tn1->Tag
		If ee <> 0 Then
			Zv = IIf(pee->Project AndAlso (*ee->FileName = *pee->Project->MainFileName OrElse *ee->FileName = *pee->Project->ResourceFileName OrElse *ee->FileName = *pee->Project->IconResourceFileName), "*", "")
			If StartsWith(*ee->FileName, GetFolderName(*pee->FileName)) Then
				Print #1, Zv & "File=" & Replace(Mid(*ee->FileName, Len(GetFolderName(*pee->FileName)) + 1), "\", "/")
			Else
				Print #1, Zv & "File=" & *ee->FileName
			End If
		ElseIf tn1->Nodes.Count > 0 Then
			For j As Integer = 0 To tn1->Nodes.Count - 1
				tn2 = tn1->Nodes.Item(j)
				ee = tn2->Tag
				If ee <> 0 Then
					Zv = IIf(pee->Project AndAlso (*ee->FileName = *pee->Project->MainFileName OrElse *ee->FileName = *pee->Project->ResourceFileName OrElse *ee->FileName = *pee->Project->IconResourceFileName), "*", "")
					If StartsWith(Replace(*ee->FileName, "\", "/"), Replace(GetFolderName(*pee->FileName), "\", "/", , , 1)) Then
						Print #1, Zv & "File=" & Replace(Mid(*ee->FileName, Len(GetFolderName(*pee->FileName)) + 1), "\", "/")
					Else
						Print #1, Zv & "File=" & *ee->FileName
					End If
				End If
			Next
		End If
	Next
	Dim As ProjectElement Ptr ppe = pee->Project
	If ppe = 0 Then ppe = New ProjectElement
	Print #1, "ProjectType=" & ppe->ProjectType
	Print #1, "ProjectName=""" & *ppe->ProjectName & """"
	Print #1, "HelpFileName=""" & *ppe->HelpFileName & """"
	Print #1, "ProjectDescription=""" & *ppe->ProjectDescription & """"
	Print #1, "MajorVersion=" & ppe->MajorVersion
	Print #1, "MinorVersion=" & ppe->MinorVersion
	Print #1, "RevisionVersion=" & ppe->RevisionVersion
	Print #1, "BuildVersion=" & ppe->BuildVersion
	Print #1, "AutoIncrementVersion=" & ppe->AutoIncrementVersion
	Print #1, "ApplicationTitle=""" & *ppe->ApplicationTitle & """"
	Print #1, "ApplicationIcon=""" & *ppe->ApplicationIcon & """"
	Print #1, "CompanyName=""" & *ppe->CompanyName & """"
	Print #1, "FileDescription=""" & *ppe->FileDescription & """"
	Print #1, "InternalName=""" & *ppe->InternalName & """"
	Print #1, "LegalCopyright=""" & *ppe->LegalCopyright & """"
	Print #1, "LegalTrademarks=""" & *ppe->LegalTrademarks & """"
	Print #1, "OriginalFilename=""" & *ppe->OriginalFilename & """"
	Print #1, "ProductName=""" & *ppe->ProductName & """"
	Print #1, "CompileToGCC=" & ppe->CompileToGCC
	Print #1, "OptimizationLevel=" & ppe->OptimizationLevel
	Print #1, "OptimizationFastCode=" & ppe->OptimizationFastCode
	Print #1, "OptimizationSmallCode=" & ppe->OptimizationSmallCode
	Print #1, "CompilationArguments32Windows=""" & *ppe->CompilationArguments32Windows & """"
	Print #1, "CompilationArguments64Windows=""" & *ppe->CompilationArguments64Windows & """"
	Print #1, "CompilationArguments32Linux=""" & *ppe->CompilationArguments32Linux & """"
	Print #1, "CompilationArguments64Linux=""" & *ppe->CompilationArguments64Linux & """"
	Print #1, "CommandLineArguments=""" & *ppe->CommandLineArguments & """"
	Print #1, "CreateDebugInfo=" & ppe->CreateDebugInfo
	Close #1
	tn->Text = GetFileName(*pee->FileName)
	tn->Tag = pee
	Return True
End Function

Sub SaveAll()
	Dim tb As TabWindow Ptr
	For i As Long = 0 To ptabCode->TabCount - 1
		tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
		tb->Save
	Next i
	For i As Long = 0 To tvExplorer.Nodes.Count - 1
		If tvExplorer.Nodes.Item(i)->ImageKey = "Project" Then
			SaveProject tvExplorer.Nodes.Item(i)
		End If
	Next i
End Sub

Sub PrintThis()
	#IfNDef __USE_GTK__
		PrintD.Execute
	#EndIf
End Sub

Sub PrintPreview()
	#IfNDef __USE_GTK__
		PrintPreviewD.Execute
	#EndIf
End Sub

Sub PageSetup()
	#IfNDef __USE_GTK__
		PageSetupD.Execute
	#EndIf
End Sub

Sub CloseAllTabs(WithoutCurrent As Boolean = False)
	Dim tb As TabWindow Ptr
	Dim j As Integer = ptabCode->TabIndex
	For i As Long = 0 To ptabCode->TabCount - 1
		If WithoutCurrent Then
			If i = j Then Continue For
		End If
		tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
		tb->CloseTab
	Next i
End Sub

TYPE HH_AKLINK 
	cbStruct     AS LONG         ' int       cbStruct;     // sizeof this structure
	fReserved    AS BOOLEAN      ' BOOL      fReserved;    // must be FALSE (really!)
	pszKeywords  AS WSTRING PTR  ' LPCTSTR   pszKeywords;  // semi-colon separated keywords
	pszUrl       AS WSTRING PTR  ' LPCTSTR   pszUrl;       // URL to jump to if no keywords found (may be NULL)
	pszMsgText   AS WSTRING PTR  ' LPCTSTR   pszMsgText;   // Message text to display in MessageBox if pszUrl is NULL and no keyword match
	pszMsgTitle  AS WSTRING PTR  ' LPCTSTR   pszMsgTitle;  // Message text to display in MessageBox if pszUrl is NULL and no keyword match
	pszWindow    AS WSTRING PTR  ' LPCTSTR   pszWindow;    // Window to display URL in
	fIndexOnFail AS BOOLEAN      ' BOOL      fIndexOnFail; // Displays index if keyword lookup fails.
END TYPE


#Define HH_DISPLAY_TOPIC   0000
#Define HH_DISPLAY_TOC     0001
#Define HH_KEYWORD_LOOKUP  0013
#Define HH_HELP_CONTEXT    0015

Sub RunHelp(Param As Any Ptr)
	If Not FileExists(*HelpPath) Then
		ThreadsEnter()
		ShowMessages ML("File") & " " & *HelpPath & " " & ML("not found")
		ThreadsLeave()
	Else
		Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If CInt(tb <> 0) Then 'AndAlso CInt(tb->txtCode.Focused) Then
			#IfDef __USE_GTK__
				PipeCmd "", *HelpPath
			#Else
				Dim wszKeyword As WString * MAX_PATH = tb->txtCode.GetWordAtCursor
				Dim As Any Ptr gpHelpLib
				Dim HtmlHelpW As Function (BYVAL hwndCaller AS HWnd, _
				BYVAL pswzFile AS WSTRING Ptr, _
				BYVAL uCommand AS UINT, _
				BYVAL dwData AS DWORD_PTR _
				) AS HWND
				' Load the HTML help library for displaying FreeBASIC help *.chm file
				gpHelpLib = DyLibLoad( "hhctrl.ocx" )
				HtmlHelpW = DyLibSymbol( gpHelpLib, "HtmlHelpW")
				If HtmlHelpW <> 0 Then
					Dim li As HH_AKLINK
					With li
						.cbStruct     = SizeOf(HH_AKLINK)
						.fReserved    = FALSE 
						.pszKeywords  = @wszKeyword
						.pszUrl       = Null
						.pszMsgText   = Null
						.pszMsgTitle  = Null
						.pszWindow    = Null
						.fIndexOnFail = FALSE 
					End With
					HtmlHelpW(0, *HelpPath, HH_DISPLAY_TOC, Null)
					If wszKeyword <> "" Then
						If HtmlHelpW(0, *HelpPath, HH_KEYWORD_LOOKUP, Cast(DWORD_PTR, @li)) = 0 Then
							' Normal case search failed, try a ucase search
							wszKeyword     = UCase(wszKeyword)
							li.pszKeywords = @wszKeyword
							HtmlHelpW(0, *HelpPath, HH_KEYWORD_LOOKUP, Cast(DWORD_PTR, @li))
						End If
					End If
				End If
				Dylibfree(gpHelpLib)
			#EndIf
		End If
		'ShellExecute(NULL, "open", *HelpPath, "", "", SW_SHOW)
	End If
End Sub

Sub NewProject()
	AddProject
End Sub

'Dim Shared fileNames(100) As WString Ptr

Function ContainsFileName(tn As TreeNode Ptr, ByRef FileName As WString) As Boolean
	For i As Integer = 0 To tn->Nodes.Count - 1
		ee = tn->Nodes.Item(i)->Tag
		If ee <> 0 Then
			If *ee->FileName = FileName Then
				Return True
			End If
		End If
	Next
	Return False
End Function

Sub AddFileToProject
	If tvExplorer.SelectedNode = 0 Then Exit Sub
	Dim As TreeNode Ptr ptn
	ptn = GetParentNode(tvExplorer.SelectedNode)
	If ptn->ImageKey <> "Project" Then Exit Sub
	Dim OpenD As OpenFileDialog
	OpenD.Options.Include ofOldStyleDialog
	OpenD.MultiSelect = True
	OpenD.Filter = ML("FreeBasic Files") & " (*.vfp, *.bas, *.bi, *.rc)|*.vfp;*.bas;*.bi;*.rc|" & ML("VisualFBEditor Project") & " (*.vfp)|*.vfp|" & ML("FreeBasic Module") & " (*.bas)|*.bas|" & ML("FreeBasic Include File") & " (*.bi)|*.bi|" & ML("FreeBasic Resource Files") & " (*.rc)|*.rc|" & ML("All Files") & "|*.*|"
	If OpenD.Execute Then
		Dim tn1 As TreeNode Ptr
		For i As Integer = 0 To OpenD.FileNames.Count - 1
			tn1 = GetTreeNodeChild(ptn, OpenD.FileNames.Item(i))
			If ContainsFileName(tn1, OpenD.FileNames.Item(i)) Then Continue For
			tn3 = tn1->Nodes.Add(GetFileName(OpenD.FileNames.Item(i)), , , "File", "File", True)
			ee = New ExplorerElement
			WLet ee->FileName, OpenD.FileNames.Item(i)
			tn3->Tag = ee
			'tn1->Expand
		Next
		If Not EndsWith(ptn->Text, " *") Then ptn->Text &= " *"
		If ptn->Nodes.Count > 0 Then
			If Not ptn->IsExpanded Then ptn->Expand
			For i As Integer = 0 To ptn->Nodes.Count - 1
				If CInt(ptn->Nodes.Item(i)->Nodes.Count > 0) Then ptn->Nodes.Item(i)->Expand
			Next
			pfProjectProperties->RefreshProperties
		End If
	End If
End Sub

Sub RemoveFileFromProject
	If tvExplorer.SelectedNode = 0 Then Exit Sub
	If tvExplorer.SelectedNode->Tag = 0 Then Exit Sub
	If tvExplorer.SelectedNode->ParentNode = 0 Then Exit Sub
	Dim As TreeNode Ptr ptn
	ptn = GetParentNode(tvExplorer.SelectedNode)
	If ptn->ImageKey <> "Project" Then Exit Sub
	Dim tn As TreeNode Ptr = tvExplorer.SelectedNode
	Dim tb As TabWindow Ptr
	For i As Integer = 0 To ptabCode->TabCount - 1
		tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
		If tb->tn = tn Then
			If tb->CloseTab = False Then Exit Sub
			Exit For
		End If
	Next i
	If Not EndsWith(tn->ParentNode->Text, " *") Then tn->ParentNode->Text &= " *"
	If tn->ParentNode->Nodes.IndexOf(tn) <> -1 Then tn->ParentNode->Nodes.Remove tn->ParentNode->Nodes.IndexOf(tn)
	pfProjectProperties->RefreshProperties
End Sub

Sub OpenProjectFolder
	Dim As TreeNode Ptr ptn = tvExplorer.SelectedNode
	If ptn = 0 Then Exit Sub
	ptn = GetParentNode(ptn)
	Dim As ExplorerElement Ptr ee = ptn->Tag
	If ee = 0 Then Exit Sub
	If WGet(ee->FileName) <> "" Then
		#IfDef __USE_GTK__
			Shell "xdg-open """ & GetFolderName(*ee->FileName) & """"
		#Else
			Shell "explorer """ & Replace(GetFolderName(*ee->FileName), "/", "\") & """"
		#EndIf
	End If
End Sub

Sub SetAsMain()
	Dim As TreeNode Ptr tn = tvExplorer.SelectedNode
	If CInt(pTabCode->Focused) AndAlso CInt(pTabCode->SelectedTab <> 0) Then tn = Cast(TabWindow Ptr, pTabCode->SelectedTab)->tn
	If tn->ParentNode = 0 Then
		MainNode = tn
		lblLeft.Text = ML("Main File") & ": " & MainNode->Text
	Else
		Dim As ExplorerElement Ptr ee = tn->Tag
		Dim As TreeNode Ptr ptn = GetParentNode(tn)
		Dim As ProjectElement Ptr ppe
		If ptn <> 0 Then
			Dim As ExplorerElement Ptr pee = ptn->Tag
			If pee = 0 Then
				pee = New ExplorerElement
				WLet pee->FileName, ""
			End If
			If pee->Project = 0 Then
				ppe = New ProjectElement
				pee->Project = ppe
			End If
			If ee <> 0 AndAlso pee <> 0 AndAlso pee->Project <> 0 Then
				WLet pee->Project->MainFileName, *ee->FileName
				If Not EndsWith(ptn->Text, " *") Then ptn->Text &= " *"
				If ptn->Tag = 0 Then ptn->Tag = pee
				pfProjectProperties->RefreshProperties
			End If
		End If
	End If
End Sub

Sub Save()
	If tvExplorer.Focused Then
		If tvExplorer.SelectedNode = 0 Then Exit Sub
		If tvExplorer.SelectedNode->ImageKey = "Project" Then
			SaveProject tvExplorer.SelectedNode
		Else
			Dim tn As TreeNode Ptr = tvExplorer.SelectedNode
			Dim tb As TabWindow Ptr
			If tn = 0 Then Exit Sub
			For i As Integer = 0 To ptabCode->TabCount - 1
				tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
				If tb->tn = tn Then
					tb->Save
					Exit For
				End If
			Next i
		End If
	Else
		Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb = 0 Then Exit Sub
		tb->Save
	End If
End Sub

Function CloseProject(tn As TreeNode Ptr) As Boolean
	If tn = 0 Then Return True
	If tn->ImageKey <> "Project" Then Return True
	Dim tb As TabWindow Ptr
	For j As Integer = 0 To tn->Nodes.Count - 1
		For i As Integer = 0 To ptabCode->TabCount - 1
			tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
			If tb->tn = tn->Nodes.Item(j) Then
				If CInt(tb) AndAlso Cint(Not tb->CloseTab) Then Return False
				Exit For
			End If
		Next i
	Next
	If EndsWith(tn->Text, " *") Then
		Select Case MsgBox(ML("Want to save the project") & " """ & tn->Text & """?", "Visual FB Editor", mtWarning, btYesNoCancel)
		Case mrYES: 
		Case mrNO: Return True
		Case mrCANCEL: Return False
		End Select
		If Not SaveProject(tn) Then Return False
	End If
	If tvExplorer.Nodes.IndexOf(tn) <> -1 Then tvExplorer.Nodes.Remove tvExplorer.Nodes.IndexOf(tn)
	Return True
End Function

Sub NextBookmark(iTo As Integer = 1)
	If ptabCode->SelectedTab = 0 Then Exit Sub
	Dim As Integer i, j, k, n, iStart, iEnd, iStartLine, iEndLine
	Dim As EditControl Ptr txt
	Dim As EditControlLine Ptr FECLine
	Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	Dim As Integer CurTabIndex = ptabCode->SelectedTab->Index
	If iTo = 1 Then
		iStart = 0
		iEnd = ptabCode->TabCount - 1
	Else
		iStart = ptabCode->TabCount - 1
		iEnd = 0
	End If
	For k = 1 To 2    
		For j = IIf(k = 1, CurTabIndex, iStart) To IIf(k = 1, iEnd, CurTabIndex) Step iTo
			txt = @Cast(TabWindow Ptr, ptabCode->Tabs[j])->txtCode
			If iTo = 1 Then
				iStartLine = 0
				iEndLine = txt->FLines.Count - 1
			Else
				iStartLine = txt->FLines.Count - 1
				iEndLine = 0
			End If
			If k = 1 AndAlso j = CurTabIndex Then
				txt->GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
				n = iSelEndLine + iTo
			Else
				n = iStartLine
			End If
			For i = n To iEndLine Step iTo
				FECLine = txt->FLines.Items[i]
				If FECLine->Bookmark Then
					ptabCode->Tabs[j]->SelectTab
					txt->SetSelection i, i, 0, 0
					Exit Sub
				End If
			Next
		Next j
	Next k
End Sub

Sub ClearAllBookmarks
	For i As Integer = 0 To ptabCode->TabCount -1
		Cast(TabWindow Ptr, ptabCode->Tabs[i])->txtCode.ClearAllBookmarks
	Next
End Sub

Sub ChangeUseDebugger(bUseDebugger As Boolean, ChangeObject As Integer = -1)
	UseDebugger = bUseDebugger
	If ChangeObject <> 0 Then tbStandard.Buttons.Item("TBUseDebugger")->Checked = bUseDebugger
	If ChangeObject <> 1 AndAlso mnuUseDebugger->Checked <> UseDebugger Then mnuUseDebugger->Checked = bUseDebugger
End Sub

Sub ChangeEnabledDebug(bStart As Boolean, bBreak As Boolean, bEnd As Boolean)
	ThreadsEnter()
	tbStandard.Buttons.Item("StartWithCompile")->Enabled = bStart
	tbStandard.Buttons.Item("Start")->Enabled = bStart
	tbStandard.Buttons.Item("Break")->Enabled = bBreak
	tbStandard.Buttons.Item("End")->Enabled = bEnd
	mnuStartWithCompile->Enabled = bStart
	mnuStart->Enabled = bStart
	mnuBreak->Enabled = bBreak
	mnuEnd->Enabled = bEnd
	ThreadsLeave()
End Sub

#ifndef __USE_GTK__
	Sub TimerProc(hwnd As HWND, uMsg As UINT, idEvent As UINT_PTR, dwTime As DWORD)
		If FnTab < 0 Or Fcurlig < 1 Then Exit Sub
		If source(Fntab) = "" Then Exit Sub
		Var tb = AddTab(LCase(source(Fntab)))
		If tb = 0 Then Exit Sub
		ChangeEnabledDebug True, False, True
		tb->txtCode.CurExecutedLine = Fcurlig - 1
		tb->txtCode.SetSelection Fcurlig - 1, Fcurlig - 1, 0, 0
		tb->txtCode.PaintControl
		CurEC = @tb->txtCode
		SetForegroundWindow frmMain.Handle
		FnTab = 0
		Fcurlig = -1
	End Sub
#endif

Function EqualPaths(ByRef a As WString, ByRef b As WString) As Boolean
	Dim FileNameLeft As WString Ptr
	Dim FileNameRight As WString Ptr
	WLet FileNameLeft, Replace(a, "\", "/")
	If EndsWith(*FileNameLeft, ":") Then *FileNameLeft = Left(*FileNameLeft, Len(*FileNameLeft) - 1)
	WLet FileNameRight, Replace(b, "\", "/")
	EqualPaths = LCase(*FileNameLeft) = LCase(*FileNameRight)
	WDeallocate FileNameLeft
	WDeallocate FileNameRight
End Function    

Sub ChangeTabsTn(TnPrev As TreeNode Ptr, Tn As TreeNode Ptr)
	Dim tb As TabWindow Ptr
	For i As Integer = 0 To ptabCode->TabCount - 1
		tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
		If tb->tn = TnPrev Then
			tb->tn = Tn
			If ptabCode->SelectedTab = ptabCode->Tabs[i] Then Tn->SelectItem
			Exit For
		End If
	Next
End Sub

Sub WithFolder
	Dim As TreeNode Ptr tnI, tnS, tnR, tnO
	For i As Integer = 0 To tvExplorer.Nodes.Count - 1
		If tvExplorer.Nodes.Item(i)->ImageKey = "Project" Then
			tn = tvExplorer.Nodes.Item(i)
			If tbExplorer.Buttons.Item(3)->Checked Then
				tnI = tn->Nodes.Add(ML("Includes"), "Includes", , "Opened", "Opened")
				tnS = tn->Nodes.Add(ML("Sources"), "Sources", , "Opened", "Opened")
				tnR = tn->Nodes.Add(ML("Resources"), "Resources", , "Opened", "Opened")
				tnO = tn->Nodes.Add(ML("Others"), "Others", , "Opened", "Opened")
			End If
			Dim As TreeNode Ptr tn1, tn2
			For j As Integer = tn->Nodes.Count - 1 To 0 Step -1
				If tbExplorer.Buttons.Item(3)->Checked Then
					If tn->Nodes.Item(j)->Tag <> 0 Then
						If EndsWith(tn->Nodes.Item(j)->Text, ".bi") Then
							tn1 = tnI
						ElseIf EndsWith(tn->Nodes.Item(j)->Text, ".bas") Then
							tn1 = tnS
						ElseIf EndsWith(tn->Nodes.Item(j)->Text, ".rc") Then
							tn1 = tnR
						Else
							tn1 = tnO
						End If
						tn2 = tn1->Nodes.Add(tn->Nodes.Item(j)->Text, , , "File", "File", True)
						tn2->Tag = tn->Nodes.Item(j)->Tag
						ChangeTabsTn tn->Nodes.Item(j), tn2
						'                        If tn->Expanded Then
						'                            
						'                        End If
						tn1->Expand
						tn->Nodes.Remove j
					End If
				Else
					For k As Integer = 0 To tn->Nodes.Item(j)->Nodes.Count - 1
						tn2 = tn->Nodes.Add(tn->Nodes.Item(j)->Nodes.Item(k)->Text, , , "File", "File")
					    '?k, tn->Text, tn->Nodes.Item(j)->Text, tn->Nodes.Item(j)->Nodes.Item(k)->Text
						tn2->Tag = tn->Nodes.Item(j)->Nodes.Item(k)->Tag
						ChangeTabsTn tn->Nodes.Item(j)->Nodes.Item(k), tn2
					Next k
					tn->Nodes.Remove j
				End If
			Next
		End If
	Next
End Sub

Sub CompileProgram(Param As Any Ptr)
	Compile
End Sub

Sub CompileAndRun(Param As Any Ptr)
	If Compile("Run") Then RunProgram(0)
End Sub

Sub MakeExecute(Param As Any Ptr)
	Compile("Make")
End Sub

Sub MakeClean(Param As Any Ptr)
	Compile("MakeClean")
End Sub

Sub SyntaxCheck(Param As Any Ptr)
	Compile("Check")
End Sub

Sub ToolBoxClick(ByRef Sender As My.Sys.Object)
	With *Cast(ToolButton Ptr, @Sender)
		If .Style = tbsCheck Then
			Var flag = .Checked
			tbToolBox.UpdateLock
			'For i As Integer = tbToolBox.Buttons.IndexOf(Cast(ToolButton Ptr, @Sender)) + 2 To tbToolBox.Buttons.Count - 1
			'   If tbToolBox.Buttons.Item(i)->Style = tbsCheck Then
			'       Exit For
			'   End If
			'   tbToolBox.Buttons.Item(i)->Visible = Flag
			'Next
			Var c = 0
			'For i As Integer = 0 To tbToolBox.Buttons.Count - 1
			'    If tbToolBox.Buttons.Item(i)->Visible Then c = c + 1
			'Next
			scrTool.MaxValue = c
			tbToolBox.UpdateUnLock
		ElseIf .Name = "Cursor" Then
			SelectedClass = ""
			SelectedTool = 0
			SelectedType = 0
		Else
			'If .Checked Then
			SelectedClass = Sender.ToString
			SelectedTool = Cast(ToolButton Ptr, @Sender)
			SelectedType = Cast(ToolBoxItem Ptr, SelectedTool->Tag)->ControlType
			'End If
		End If
	End With
End Sub

Function GetTypeControl(ControlType As String) As Integer
	If Comps.Contains(ControlType) Then
		Var tbi = Cast(ToolBoxItem Ptr, Comps.Object(Comps.IndexOf(ControlType))) 'Breakpoint
		Select Case LCase(tbi->BaseName)
		Case "control": Return 1
		Case "containercontrol": Return 2
		Case "component": Return 3
		Case "dialog": Return 4
		Case "": Return 0
		Case Else
			If ControlType = tbi->BaseName Then Return 0 Else Return GetTypeControl(tbi->BaseName)
		End Select
	Else
		Return 0
	End If
End Function

Dim Shared tpShakl As TabPage Ptr

Sub tpShakl_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	#ifdef __USE_GTK__
		tbToolBox.SetBounds 0, tbForm.Height, NewWidth, NewHeight
	#else
		tbToolBox.SetBounds 0, tbForm.Height, NewWidth - IIf(scrTool.Visible, scrTool.Width, 0), NewHeight
		scrTool.MaxValue = Max(0, tbToolBox.Height - (NewHeight - tbForm.Height))
		scrTool.Visible = scrTool.MaxValue <> 0
	#endif
End Sub

Sub tbToolBox_MouseWheel(ByRef Sender As Control, Direction As Integer, x As Integer, y As Integer, Shift As Integer)
	scrTool.Position = Min(scrTool.MaxValue, Max(scrTool.MinValue, scrTool.Position + -Direction * scrTool.ArrowChangeSize))
End Sub

Sub scrTool_MouseWheel(ByRef Sender As Control, Direction As Integer, x As Integer, y As Integer, Shift As Integer)
	scrTool.Position = Min(scrTool.MaxValue, Max(scrTool.MinValue, scrTool.Position + -Direction * scrTool.ArrowChangeSize))
End Sub

Sub LoadToolBox
	Dim As String f, t, e, b1
	Dim As WString Ptr b
	Dim As Integer Pos1, Pos2, i, j
	Dim As My.Sys.Drawing.Cursor cur
	Dim As Integer Result
	Dim As String IncludePath
	Dim MFF As Any Ptr
	WLet MFFPath, iniSettings.ReadString("Options", "MFFPath", "./MyFbFramework")
	#ifndef __USE_GTK__
		#ifdef __FB_64BIT__
			WLet MFFDll, *MFFPath & "/mff64.dll"
		#else
			WLet MFFDll, *MFFPath & "/mff32.dll"
		#endif
	#else
		#ifdef __USE_GTK3__
			#ifdef __FB_64BIT__
				WLet MFFDll, *MFFPath & "/libmff64_gtk3.so"
			#else
				WLet MFFDll, *MFFPath & "/libmff32_gtk3.so"
			#endif
		#else
			#ifdef __FB_64BIT__
				WLet MFFDll, *MFFPath & "/libmff64_gtk2.so"
			#else
				WLet MFFDll, *MFFPath & "/libmff32_gtk2.so"
			#endif
		#endif
	#endif
	MFF = DyLibLoad(*MFFDll)
	Dim As ToolBoxItem Ptr tbi
	#ifndef __USE_GTK__
		cur = crArrow
	#endif
	Dim cl As Integer = clSilver
	#ifdef __USE_GTK__
		gtk_icon_theme_append_search_path(gtk_icon_theme_get_default(), *MFFPath & "/resources")
		tbToolBox.Align = 5
	#else
		imgListTools.AddPng "DropDown", "DropDown"
		imgListTools.AddPng "Kursor", "Cursor"
	#endif
	tbToolBox.Top = tbForm.Height
	tbToolBox.Flat = True
	tbToolBox.Wrapable = True
	tbToolBox.BorderStyle = 0
	tbToolBox.List = True
	tbToolBox.Style = tpsBothHorizontal
	tbToolBox.OnMouseWheel = @tbToolBox_MouseWheel
	tbToolBox.ImagesList = @imgListTools
	tbToolBox.HotImagesList = @imgListTools
	IncludePath = GetFolderName(*MFFDll) & "mff/"
	f = Dir(IncludePath & "*.bi")
	Var inType = False
	Var inEnum = False
	Dim ff As Integer = FreeFile
	Var inPubPriPro = 0
	Dim Comment As WString Ptr
	While f <> ""
		ff = FreeFile
		Result = Open(IncludePath & f For Input Encoding "utf-32" As #ff)
		If Result <> 0 Then Result = Open(IncludePath & f For Input Encoding "utf-16" As #ff)
		If Result <> 0 Then Result = Open(IncludePath & f For Input Encoding "utf-8" As #ff)
		If Result <> 0 Then Result = Open(IncludePath & f For Input As #ff)
		If Result = 0 Then
			inType = False
			WReallocate b, LOF(ff)
			Do Until EOF(ff)
				Line Input #ff, *b
				*b = replace(*b, !"\t", " ")
				b1 = *b
				If Trim(b1) = "" Then Continue Do
				If CInt(StartsWith(Trim(LCase(*b)), "type ")) AndAlso CInt(InStr(LCase(*b), " as ") = 0) Then
					Pos1 = InStr(" " & LCase(*b), " type ")
					If Pos1 > 0 Then
						Pos2 = InStr(LCase(*b), " extends ")
						If Pos2 > 0 Then
							t = Trim(Mid(*b, Pos1 + 5, Pos2 - Pos1 - 5))
							e = Trim(Mid(*b, Pos2 + 9))
							Var Pos4 = InStr(e, "'")
							If Pos4 > 0 Then
								e = Trim(Left(e, Pos4 - 1))
							End If
						Else
							Pos2 = InStr(Pos1 + 5, LCase(*b), " ")
							If Pos2 > 0 Then
								t = Trim(Mid(*b, Pos1 + 5, Pos2 - Pos1 - 5))
							Else
								t = Trim(Mid(*b, Pos1 + 5))
							End If
							e = ""
						End If
						If Not Comps.Contains(t) Then
							If t = "Object" And e = "Object" Then
								t = "My.Sys.Object"
								e = ""
							End If
							inType = True
							inPubPriPro = 0
							tbi = New ToolBoxItem
							tbi->Name = t
							tbi->BaseName = e
							tbi->ElementType = "Type"
							WLet tbi->LibraryName, "MFF"
							WLet tbi->LibraryFile, *MFFDll
							WLet tbi->IncludeFile, "mff/" & f
							Comps.Add t, tbi
						End If
					End If
				ElseIf StartsWith(Trim(LCase(*b)) & " ", "end type ") Then
					inType = False
				ElseIf inType Then
					If StartsWith(Trim(*b), "'") Then
						WAdd Comment, Mid(Trim(*b), 2) & Chr(13) & Chr(10)
					ElseIf StartsWith(Trim(LCase(*b)) & " ", "public: ") Then
						inPubPriPro = 0
						WLet Comment, ""
					ElseIf StartsWith(Trim(LCase(*b)) & " ", "private: ") Then
						inPubPriPro = 1
						WLet Comment, ""
					ElseIf StartsWith(Trim(LCase(*b)) & " ", "protected: ") Then
						inPubPriPro = 2
						WLet Comment, ""
					ElseIf StartsWith(Trim(LCase(*b)), "declare ") Then
						If StartsWith(Trim(LCase(*b)), "declare sub ") Then
							Var Pos3 = InStr(Trim(*b), "(")
							Var n = Len(Trim(*b)) - Len(Trim(Mid(Trim(*b), 12)))
							Var Pos4 = InStr(n + 1, Trim(*b), " ")
							If Pos4 > 0 AndAlso (Pos4 < Pos3 OrElse Pos3 = 0) Then Pos3 = Pos4
							Var te = New TypeElement
							If Pos3 = 0 Then
								te->Name = Trim(Mid(Trim(*b), 13))
							Else
								te->Name = Trim(Mid(Trim(*b), 13, Pos3 - 13))
							End If
							te->TypeName = ""
							te->ElementType = "Sub"
							te->Locals = inPubPriPro
							WLet te->Parameters, Mid(Trim(*b), 13)
							If Comment Then WLet te->Comment, *Comment: WLet Comment, ""
							If tbi Then tbi->Elements.Add te->Name, te
						ElseIf StartsWith(Trim(LCase(*b)), "declare function ") Then
							Var Pos3 = InStr(Trim(*b), "(")
							Var n = Len(Trim(*b)) - Len(Trim(Mid(Trim(*b), 18)))
							Var Pos4 = InStr(n + 1, Trim(*b), " ")
							If Pos4 > 0 AndAlso (Pos4 < Pos3 OrElse Pos3 = 0) Then Pos3 = Pos4
							Var te = New TypeElement
							If Pos3 = 0 Then
								te->Name = Trim(Mid(Trim(*b), 18))
							Else
								te->Name = Trim(Mid(Trim(*b), 18, Pos3 - 18))
							End If
							te->TypeName = ""
							te->ElementType = "Function"
							te->Locals = inPubPriPro
							WLet te->Parameters, Mid(Trim(*b), 18)
							If Comment Then WLet te->Comment, *Comment: WLet Comment, ""
							If tbi Then tbi->Elements.Add te->Name, te
						ElseIf StartsWith(Trim(LCase(*b)), "declare property ") Then
							Var Pos3 = InStr(LCase(LTrim(*b)), " as ")
							Var Pos_ = InStr(LCase(LTrim(*b)), "(")
							If Pos_ > 0 AndAlso Pos_ < Pos3 Then Pos3 = Pos_ - 1
							Var te = New TypeElement
							te->Name = Trim(Mid(LTrim(*b), 18, Pos3 - 18 + 1))
							If EndsWith(RTrim(LCase(te->Name)), "()") Then te->Name = Left(te->Name, Len(Trim(te->Name)) - 2)
							If EndsWith(RTrim(LCase(te->Name)), " byref") Then te->Name = Left(te->Name, Len(Trim(te->Name)) - 6)
							te->TypeName = Trim(Mid(LTrim(*b), Pos3 + 4))
							Var Pos4 = InStr(te->TypeName, "'")
							If Pos4 > 0 Then
								Var Pos5 = InStr(Trim(Mid(te->TypeName, Pos4 + 1)), " ")
								If Pos5 > 0 Then
									te->EnumTypeName = Left(Trim(Mid(te->TypeName, Pos4 + 1)), Pos5 - 1)
								Else
									te->EnumTypeName = Trim(Mid(te->TypeName, Pos4 + 1))
								End If
								te->TypeName = Trim(Left(te->TypeName, Pos4 - 1))
							End If
							te->ElementType = "Property"
							te->Locals = inPubPriPro
							WLet te->Parameters, Mid(Trim(*b), 17)
							If Comment Then WLet te->Comment, *Comment: WLet Comment, ""
							If tbi Then tbi->Elements.Add te->Name, te
						End If
					ElseIf StartsWith(Trim(LCase(*b)), "dim ") Then
						
					Else
						Var Pos3 = InStr(LCase(LTrim(*b)), " as ")
						If Pos3 > 0 Then
							Var te = New TypeElement
							te->Name = Trim(Left(LTrim(*b), Pos3))
							te->TypeName = Trim(Mid(LTrim(*b), Pos3 + 4))
							Var Pos4 = InStr(te->TypeName, "'")
							If Pos4 > 0 Then
								Var Pos5 = InStr(Trim(Mid(te->TypeName, Pos4 + 1)), " ")
								If Pos5 > 0 Then
									te->EnumTypeName = Left(Trim(Mid(te->TypeName, Pos4 + 1)), Pos5 - 1)
								Else
									te->EnumTypeName = Trim(Mid(te->TypeName, Pos4 + 1))
								End If
								te->TypeName = Trim(Left(te->TypeName, Pos4 - 1))
							End If
							Pos4 = InStrRev(te->TypeName, ".")
							If Pos4 > 0 Then te->TypeName = Mid(te->TypeName, Pos4 + 1)
							te->ElementType = IIf(StartsWith(LCase(te->TypeName), "sub("), "Event", "Property")
							te->Locals = inPubPriPro
							WLet te->Parameters, Trim(*b)
							If Comment Then WLet te->Comment, *Comment: WLet Comment, ""
							If tbi Then tbi->Elements.Add te->Name, te
						End If
					End If
				ElseIf CInt(StartsWith(Trim(LCase(*b)), "enum ")) Then
					InEnum = True
					t = Trim(Mid(Trim(*b), 6))
					Var Pos2 = InStr(t, "'")
					If Pos2 > 0 Then t = Trim(Left(t, Pos2 - 1))
					If Not Comps.Contains(t) Then
						tbi = New ToolBoxItem
						tbi->Name = t
						tbi->BaseName = ""
						tbi->ElementType = "Enum"
						WLet tbi->LibraryName, "MFF"
						WLet tbi->LibraryFile, *MFFDll
						WLet tbi->IncludeFile, "mff/" & f
						Comps.Add t, tbi
					End If
				ElseIf CInt(StartsWith(Trim(LCase(*b)), "end enum")) Then
					InEnum = False
				ElseIf inEnum Then
					Dim As WString Ptr res()
					Split *b, ",", res()
					For i As Integer = 0 To UBound(res)
						Var Pos3 = InStr(*res(i), "=")
						If Pos3 > 0 Then
							t = Trim(Left(*res(i), Pos3 - 1))
						Else
							t = Trim(*res(i))
						End If
						Var te = New TypeElement
						te->Name = t
						te->TypeName = ""
						te->ElementType = ""
						te->Locals = 0
						WLet te->Parameters, ""
						If tbi Then tbi->Elements.Add te->Name, te
						Deallocate res(i)
					Next i
				ElseIf CInt(StartsWith(Trim(LCase(*b), Any !"\t "), "sub ")) OrElse _
					CInt(StartsWith(Trim(LCase(*b), Any !"\t "), "private sub ")) OrElse _
					CInt(StartsWith(Trim(LCase(*b), Any !"\t "), "public sub ")) OrElse _
					CInt(StartsWith(Trim(LCase(*b), Any !"\t "), "declare sub ")) Then
					Var Pos3 = InStr(Trim(*b, Any !"\t "), "(")
					Var SubPos = InStr(Trim(LCase(*b), Any !"\t "), " sub ") + 4
					Var n = Len(Trim(*b, Any !"\t ")) - Len(Trim(Mid(Trim(*b, Any !"\t "), SubPos), Any !"\t "))
					Var Pos4 = InStr(n + 1, Trim(*b, Any !"\t "), " ")
					If Pos4 > 0 AndAlso (Pos4 < Pos3 OrElse Pos3 = 0) Then Pos3 = Pos4
					Var te = New TypeElement
					If Pos3 = 0 Then
						te->Name = Trim(Mid(Trim(*b, Any !"\t "), SubPos))
					Else
						te->Name = Trim(Mid(Trim(*b, Any !"\t "), SubPos, Pos3 - SubPos))
					End If
					te->TypeName = ""
					te->ElementType = "Sub"
					te->Locals = IIf(StartsWith(Trim(LCase(*b), Any !"\t "), "private sub "), 1, 0)
					WLet te->Parameters, Mid(Trim(*b, Any !"\t "), SubPos)
					If Comment Then WLet te->Comment, *Comment: WLet Comment, ""
					GlobalFunctions.Add te->Name, te
				ElseIf CInt(StartsWith(Trim(LCase(*b), Any !"\t "), "function ")) OrElse _
					CInt(StartsWith(Trim(LCase(*b), Any !"\t "), "private function ")) OrElse _
					CInt(StartsWith(Trim(LCase(*b), Any !"\t "), "public function ")) OrElse _
					CInt(StartsWith(Trim(LCase(*b), Any !"\t "), "declare function ")) Then
					Var Pos3 = InStr(Trim(*b, Any !"\t "), "(")
					Var SubPos = InStr(Trim(LCase(*b), Any !"\t "), " function") + 9
					Var n = Len(Trim(*b, Any !"\t ")) - Len(Trim(Mid(Trim(*b, Any !"\t "), SubPos), Any !"\t "))
					Var Pos4 = InStr(n + 1, Trim(*b, Any !"\t "), " ")
					If Pos4 > 0 AndAlso (Pos4 < Pos3 OrElse Pos3 = 0) Then Pos3 = Pos4
					Var te = New TypeElement
					If Pos3 = 0 Then
						te->Name = Trim(Mid(Trim(*b, Any !"\t "), SubPos))
					Else
						te->Name = Trim(Mid(Trim(*b, Any !"\t "), SubPos, Pos3 - SubPos))
					End If
					te->TypeName = ""
					te->ElementType = "Function"
					te->Locals = IIf(StartsWith(Trim(LCase(*b), Any !"\t "), "private function "), 1, 0)
					WLet te->Parameters, Mid(Trim(*b, Any !"\t "), SubPos)
					If Comment Then WLet te->Comment, *Comment: WLet Comment, ""
					GlobalFunctions.Add te->Name, te
				EndIf
				pApp->DoEvents
			Loop
			Close #ff
		End If
		f = Dir()
	Wend
	Comps.Sort
	Var iOld = -1, iNew = 0
	Dim As String it = "Cursor", g(1 To 4): g(1) = ML("Controls"): g(2) = ML("Containers"): g(3) = ML("Components"): g(4) = ML("Dialogs")
	tbToolBox.Groups.Add ML("Controls")
	tbToolBox.Groups.Add ML("Containers")
	tbToolBox.Groups.Add ML("Components")
	tbToolBox.Groups.Add ML("Dialogs")
	tbToolBox.Groups.Item(0)->Buttons.Add(tbsCheckGroup,it,,@ToolBoxClick, it, it, it, True, tstEnabled Or tstWrap Or tstChecked)
	tbToolBox.Groups.Item(1)->Buttons.Add(tbsCheckGroup,it,,@ToolBoxClick, it, it, it, True, tstEnabled Or tstWrap Or tstChecked)
	tbToolBox.Groups.Item(2)->Buttons.Add(tbsCheckGroup,it,,@ToolBoxClick, it, it, it, True, tstEnabled Or tstWrap Or tstChecked)
	tbToolBox.Groups.Item(3)->Buttons.Add(tbsCheckGroup,it,,@ToolBoxClick, it, it, it, True, tstEnabled Or tstWrap Or tstChecked)
	'For j As Integer = 1 To 4
	'    If j > 1 Then tbToolBox.Buttons.Add tbsSeparator,,,,,,,,tstHidden
	'    tbToolBox.Buttons.Add tbsCheck,"DropDown",,@ToolBoxClick,g(j),g(j),,,tstEnabled Or tstChecked Or tstWrap
	'    tbToolBox.Buttons.Add tbsSeparator
	For i = 0 To Comps.Count - 1
		If LCase(Comps.Item(i)) = "control" Or LCase(Comps.Item(i)) = "containercontrol" Or LCase(Comps.Item(i)) = "menu" Or LCase(Comps.Item(i)) = "component" Or LCase(Comps.Item(i)) = "dialog" Then Continue For
		iNew = GetTypeControl(Comps.Item(i))
		If Comps.Contains(Comps.Item(i)) Then
			Var tbi = Cast(ToolBoxItem Ptr, Comps.Object(Comps.IndexOf(Comps.Item(i))))
			tbi->ControlType = iNew
		End If
		If iNew = 0 Then Continue For
		'If iNew <> j Then Continue For
		it = Comps.Item(i)
		#ifndef __USE_GTK__
			imgListTools.AddPng it, it, MFF
		#endif
		Var toolb = tbToolBox.Groups.Item(iNew - 1)->Buttons.Add(tbsCheckGroup,it,,@ToolBoxClick, it, it, it, True, tstEnabled Or tstWrap)
		toolb->Tag = Comps.Object(i)
		iOld = iNew
	Next i
	'With *tbToolBox.Buttons.Button(tbToolBox.Buttons.Count - 1)
	'    If .State = tstEnabled Then .State = tstEnabled Or tstWrap
	'End With
	'Next j
	If MFF Then DyLibFree(MFF)
End Sub

Sub LoadLanguageTexts
	#ifdef __FB_WIN32__
		#ifdef __FB_64BIT__
			iniSettings.Load ExePath & "/Settings/VisualFBEditor64.ini"
		#else
			iniSettings.Load ExePath & "/Settings/VisualFBEditor32.ini"
		#endif
	#else
		#ifdef __FB_64BIT__
			iniSettings.Load ExePath & "/Settings/VisualFBEditorX64.ini"
		#else
			iniSettings.Load ExePath & "/Settings/VisualFBEditorX32.ini"
		#endif
	#endif
	CurLanguage = iniSettings.ReadString("Options", "Language", "english")
	If CurLanguage = "" Then
		mlKeys.Add "#Til"
		mlTexts.Add "English"
		Exit Sub
	End If
	Dim b As WString Ptr
	Dim As Integer i, Pos1
	Open ExePath & "/Settings/Languages/" & CurLanguage & ".lng" For Input Encoding "utf-8" As #1
	WReallocate b, LOF(1)
	Do Until EOF(1)
		Line Input #1, *b
		Pos1 = InStr(*b, "=")
		If Pos1 > 0 Then
			mlKeys.Add Trim(Left(*b, Pos1 - 1), " ")
			mlTexts.Add Trim(Mid(*b, Pos1 + 1), " ")
		End If
	Loop
	Close #1
End Sub

imgList.Name = "imgList"
imgList.AddPng "StartWithCompile", "StartWithCompile"
imgList.AddPng "Start", "Start"
imgList.AddPng "Break", "Break"
imgList.AddPng "EndProgram", "End"
imgList.AddPng "New", "New"
imgList.AddPng "Open", "Open"
imgList.AddPng "Save", "Save"
imgList.AddPng "SaveAll", "SaveAll"
imgList.AddPng "Close", "Close"
imgList.AddPng "Exit", "Exit"
imgList.AddPng "Undo", "Undo"
imgList.AddPng "Redo", "Redo"
imgList.AddPng "Cut", "Cut"
imgList.AddPng "Copy", "Copy"
imgList.AddPng "Paste", "Paste"
imgList.AddPng "Search", "Find"
imgList.AddPng "Code", "Code"
imgList.AddPng "Console", "Console"
imgList.AddPng "Form", "Form"
imgList.AddPng "Format", "Format"
imgList.AddPng "Unformat", "Unformat"
imgList.AddPng "CodeAndForm", "CodeAndForm"
imgList.AddPng "SyntaxCheck", "SyntaxCheck"
imgList.AddPng "List", "Try"
imgList.AddPng "UseDebugger", "UseDebugger"
imgList.AddPng "Compile", "Compile"
imgList.AddPng "Make", "Make"
imgList.AddPng "Help", "Help"
imgList.AddPng "About", "About"
imgList.AddPng "File", "File"
imgList.AddPng "Settings", "Parameters"
imgList.AddPng "Folder", "Folder"
imgList.AddPng "Project", "Project"
imgList.AddPng "Add", "Add"
imgList.AddPng "Remove", "Remove"
imgList.AddPng "Error", "Error"
imgList.AddPng "Warning", "Warning"
imgList.AddPng "Info", "Info"
imgList.AddPng "Label", "Label"
imgList.AddPng "Component", "Component"
imgList.AddPng "Property", "Property"
imgList.AddPng "Sub", "Sub"
imgList.AddPng "Bookmark", "Bookmark"
imgList.AddPng "Breakpoint", "Breakpoint"
imgList.AddPng "B32", "B32"
imgList.AddPng "B64", "B64"
imgList.AddPng "Opened", "Opened"
imgList.AddPng "Tools", "Tools"
imgList.AddPng "StandartTypes", "StandartTypes"
imgList.AddPng "Enum", "Enum"
imgList.AddPng "Type", "Type"
imgList.AddPng "Function", "Function"
imgList.AddPng "Event", "Event"
imgList.AddPng "Collapsed", "Collapsed"
imgList.AddPng "Categorized", "Categorized"
imgList.AddPng "Comment", "Comment"
imgList.AddPng "UnComment", "UnComment"
imgList.AddPng "Print", "Print"
imgList.AddPng "PrintPreview", "PrintPreview"
imgListD.AddPng "StartWithCompileD", "StartWithCompile"
imgListD.AddPng "StartD", "Start"
imgListD.AddPng "BreakD", "Break"
imgListD.AddPng "EndD", "End"

mnuMain.ImagesList = @imgList

Var miFile = mnuMain.Add(ML("File"), "", "File")
miFile->Add(ML("New Project") & !"\tCtrl+Shift+N", "Project", "NewProject", @mclick)
miFile->Add(ML("Open Project") & !"\tCtrl+Shift+O", "", "OpenProject", @mclick)
miFile->Add(ML("Close Project") & !"\tCtrl+Shift+Q", "", "CloseProject", @mclick)
miFile->Add("-")
miFile->Add(ML("&New") & !"\tCtrl+N", "New", "New", @mclick)
miFile->Add(ML("&Open ...") & !"\tCtrl+O", "Open", "Open", @mclick)
miFile->Add("-")
miFile->Add(ML("Open Session") & !"\tCtrl+Alt+O", "", "OpenSession", @mclick)
miFile->Add(ML("Save Session") & !"\tCtrl+Alt+S", "", "SaveSession", @mclick)
miFile->Add("-")
miFile->Add(ML("&Save ...") & !"\tCtrl+S", "Save", "Save", @mclick)
miFile->Add(ML("Save As ..."), "", "SaveAs", @mclick)
miFile->Add(ML("Save All") & !"\tCtrl+Shift+S", "SaveAll", "SaveAll", @mclick)
miFile->Add("-")
miFile->Add(ML("&Close") & !"\tCtrl+F4", "Close", "Close", @mclick)
miFile->Add(ML("Close All") & !"\tCtrl+Shift+F4", "", "CloseAll", @mclick)
miFile->Add("-")
miFile->Add(ML("&Print") & !"\tCtrl+P", "Print", "Print", @mclick)
miFile->Add(ML("P&rint Preview"), "PrintPreview", "PrintPreview", @mclick)
miFile->Add(ML("Page &Setup"), "", "PageSetup", @mclick)
miFile->Add("-")
'David Change
miRecentProjects = miFile->Add(ML("Recent Projects"), "", "RecentProjects", @mclick)
Dim sTmp As WString Ptr
For i As Integer = 0 To 9 
	WLet sTmp, iniSettings.ReadString("MRUProjects", "MRUProject_0" & WStr(i), "")
	If Trim(*sTmp) <> "" Then
		MRUProjects.Add *sTmp ' Changed by Xusinboy
		miRecentProjects->Add(*sTmp, "", *sTmp, @mClickMRU) ' Changed by Xusinboy
	Else
		Exit For
	End If
Next
miRecentFiles = miFile->Add(ML("Recent Files"), "", "RecentFiles", @mclick)
For i As Integer = 0 To 9
	WLet sTmp, iniSettings.ReadString("MRUFiles", "MRUFile_0" & WStr(i), "")
	If Trim(*sTmp) <> "" Then
		MRUFiles.Add *sTmp ' Changed by Xusinboy
		miRecentFiles->Add(*sTmp, "", *sTmp, @mClickMRU) ' Changed by Xusinboy
	Else
		Exit For
	End If
Next
WDeallocate sTmp
miFile->Add("-")
miFile->Add(ML("&Exit") & !"\tAlt+F4", "Exit", "Exit", @mclick)

Var miEdit = mnuMain.Add(ML("Edit"), "", "Tahrir")
miEdit->Add(ML("Undo") & !"\tCtrl+Z", "Undo", "Undo", @mclick)
miEdit->Add(ML("Redo") & !"\tCtrl+Y", "Redo", "Redo", @mclick)
miEdit->Add("-")
miEdit->Add(ML("Cut") & !"\tCtrl+X", "Cut", "Cut", @mclick)
miEdit->Add(ML("Copy") & !"\tCtrl+C", "Copy", "Copy", @mclick)
miEdit->Add(ML("Paste") & !"\tCtrl+V", "Paste", "Paste", @mclick)
miEdit->Add("-")
miEdit->Add(ML("Single Comment") & !"\tCtrl+I", "Comment", "SingleComment", @mclick)
miEdit->Add(ML("Block Comment") & !"\tCtrl+Alt+I", "", "BlockComment", @mclick)
miEdit->Add(ML("Uncomment Block") & !"\tCtrl+Shift+I", "UnComment", "UnComment", @mclick)
miEdit->Add("-")
miEdit->Add(ML("Select All") & !"\tCtrl+A", "", "SelectAll", @mclick)
miEdit->Add("-")
miEdit->Add(ML("Indent") & !"\tTab", "", "Indent", @mclick)
miEdit->Add(ML("Outdent") & !"\tShift+Tab", "", "Outdent", @mclick)
miEdit->Add("-")
miEdit->Add(ML("Format") & !"\tCtrl+Tab", "Format", "Format", @mclick)
miEdit->Add(ML("Unformat") & !"\tCtrl+Shift+Tab", "Unformat", "Unformat", @mclick)
Var miTry = miEdit->Add(ML("Error Handling"), "", "Try")
miTry->Add(ML("Numbering"), "", "NumberOn", @mclick)
miTry->Add(ML("Remove Numbering"), "", "NumberOff", @mclick)
miTry->Add("-")
miTry->Add(ML("Procedure numbering"), "", "ProcedureNumberOn", @mclick)
miTry->Add(ML("Remove Procedure numbering"), "", "ProcedureNumberOff", @mclick)
miTry->Add("-")
miTry->Add("On Error Resume Next", "", "OnErrorResumeNext", @mclick)
miTry->Add("On Error Goto ...", "", "OnErrorGoto", @mclick)
miTry->Add("On Error Goto ... Resume Next", "", "OnErrorGotoResumeNext", @mclick)
miTry->Add(ML("Remove Error Handling"), "", "RemoveErrorHandling", @mclick)
miEdit->Add("-")
miEdit->Add(ML("Collapse All"), "", "CollapseAll", @mclick)
miEdit->Add(ML("Uncollapse All"), "", "UnCollapseAll", @mclick)
miEdit->Add("-")
miEdit->Add(ML("Complete Word") & !"\tCtrl+Space", "", "CompleteWord", @mclick)
miEdit->Add("-")
Var miBookmark = miEdit->Add(ML("Bookmarks"), "", "Bookmarks")
miBookmark->Add(ML("Toggle Bookmark") & !"\tF6", "Bookmark", "ToggleBookmark", @mclick)
miBookmark->Add(ML("Next Bookmark") & !"\tCtrl+F6", "", "NextBookmark", @mclick)
miBookmark->Add(ML("Previous Bookmark") & !"\tCtrl+Shift+F6", "", "PreviousBookmark", @mclick)
miBookmark->Add(ML("Clear All Bookmarks"), "", "ClearAllBookmarks", @mclick)

Var miSearch = mnuMain.Add(ML("Search"), "", "Search")
miSearch->Add(ML("Find ...") & !"\tCtrl+F", "Find", "Find", @mclick)
miSearch->Add(ML("Replace ...") & !"\tCtrl+H", "", "Replace", @mclick)
miSearch->Add(ML("Find Next") & !"\tF3", "", "FindNext", @mclick)
miSearch->Add(ML("Find Previous") & !"\tShift+F3", "", "FindPrev", @mclick)
miSearch->Add(ML("Find In Files ...") & !"\tCtrl+Shift+F", "", "FindInFiles", @mclick)
miSearch->Add(ML("Goto") & !"\tCtrl+G", "", "Goto", @mclick)

Var miProject = mnuMain.Add(ML("Project"), "", "Project")
miProject->Add(ML("Add File To Project"), "Add", "AddFileToProject", @mclick)
miProject->Add(ML("Remove File From Project"), "Remove", "RemoveFileFromProject", @mclick)
miProject->Add("-")
miProject->Add(ML("Open Project Folder"), "", "OpenProjectFolder", @mclick)
miProject->Add("-")
miProject->Add(ML("Project Properties ..."), "", "ProjectProperties", @mclick)

Var miForm = mnuMain.Add(ML("Form"), "", "Form")
miForm->Add(ML("New Form"), "Form", "NewForm", @mclick)
miForm->Add("-")
miForm->Add(ML("Switch Code/Form"), "Code", "SwitchCodeForm", @mclick)

Var miBuild = mnuMain.Add(ML("Build"), "", "Build")
miBuild->Add(ML("Syntax Check"), "SyntaxCheck", "SyntaxCheck", @mclick)
miBuild->Add("-")
miBuild->Add(ML("Compile") & !"\tCtrl+F9", "Compile", "Compile", @mclick)
miBuild->Add("-")
miBuild->Add(ML("Make"), "Make", "Make", @mclick)
miBuild->Add(ML("MakeClean"), "", "MakeClean", @mclick)
miBuild->Add("-")
miBuild->Add(ML("Parameters"), "Parameters", "Parameters", @mclick)

Var miDebug = mnuMain.Add(ML("Debug"), "", "Debug")
mnuUseDebugger = miDebug->Add(ML("Use Debugger"), "", "UseDebugger", @mclick, True)
miDebug->Add("-")
miDebug->Add(ML("Step Into") & !"\tF8", "", "StepInto", @mclick)
miDebug->Add(ML("Step Over") & !"\tShift+F8", "", "StepOver", @mclick)
miDebug->Add(ML("Step Out") & !"\tCtrl+Shift+F8", "", "StepOut", @mclick)
miDebug->Add(ML("Run To Cursor") & !"\tCtrl+F8", "", "RunTuCursor", @mclick)
miDebug->Add("-")
miDebug->Add(ML("Add Watch"), "", "AddWatch", @mclick)
miDebug->Add("-")
miDebug->Add(ML("Toggle Breakpoint") & !"\tF9", "Breakpoint", "Breakpoint", @mclick)
miDebug->Add(ML("Clear All Breakpoints") & !"\tCtrl+Shift+F9", "", "ClearAllBreakpoints", @mclick)
miDebug->Add("-")
miDebug->Add(ML("Set Next Statement"), "", "SetNextStatement", @mclick)
miDebug->Add(ML("Show Next Statement") & !"\t", "", "ShowNextStatement", @mclick)

Var miRun = mnuMain.Add(ML("Run"), "", "Run")
mnuStartWithCompile = miRun->Add(ML("Start With Compile") & !"\tF5", "StartWithCompile", "StartWithCompile", @mclick)
mnuStart = miRun->Add(ML("Start") & !"\tCtrl+F5", "Start", "Start", @mclick)
mnuBreak = miRun->Add(ML("Break") & !"\tCtrl+Pause", "Break", "Break", @mclick)
mnuEnd = miRun->Add(ML("End"), "End", "End", @mclick)
mnuRestart = miRun->Add(ML("Restart") & !"\tShift+F5", "", "Restart", @mclick)
mnuBreak->Enabled = False
mnuEnd->Enabled = False
mnuRestart->Enabled = False

Var miXizmat = mnuMain.Add(ML("Service"), "", "Service")
miXizmat->Add(ML("Add-Ins ..."), "", "AddIns", @mclick)
miXizmat->Add("-")
miXizmat->Add(ML("Options"), "Tools", "Options", @mclick)

Var miHelp = mnuMain.Add(ML("Help"), "", "Help")
miHelp->Add(ML("Content") & !"\tF1", "Help", "Content", @mclick)
miHelp->Add("-")
miHelp->Add(ML("About"), "About", "About", @mclick)

mnuForm.ImagesList = @imgList '<m>
mnuForm.Add(ML("Cut"), "Cut", "Cut", @mclick)
mnuForm.Add(ML("Copy"), "Copy", "Copy", @mclick)
mnuForm.Add(ML("Paste"), "Paste", "Paste", @mclick)

mnuTabs.ImagesList = @imgList '<m>
mnuTabs.Add(ML("Set As Main"), "SetAsMain", "SetAsMain", @mclick)
mnuTabs.Add("-")
mnuTabs.Add(ML("Close"), "Close", "Close", @mclick)
mnuTabs.Add(ML("Close All Without Current"), "CloseAllWithoutCurrent", "CloseAllWithoutCurrent", @mclick)
mnuTabs.Add(ML("Close All"), "CloseAll", "CloseAll", @mclick)

mnuVars.ImagesList = @imgList '<m>
mnuVars.Add(ML("Show String"), "", "ShowString", @mclick)
mnuVars.Add(ML("Show/Expand Variable"), "", "ShowExpandVariable", @mclick)

mnuExplorer.ImagesList = @imgList '<m>
mnuExplorer.Add(ML("Add File To Project"), "Add", "AddFileToProject", @mclick)
mnuExplorer.Add(ML("Remove File From Project"), "Remove", "RemoveFileFromProject", @mclick)
mnuExplorer.Add("-")
mnuExplorer.Add(ML("Set As Main"), "", "SetAsMain", @mclick)
mnuExplorer.Add("-")
mnuExplorer.Add(ML("Open Project Folder"), "", "OpenProjectFolder", @mclick)
mnuExplorer.Add("-")
mnuExplorer.Add(ML("Project Properties ..."), "", "ProjectProperties", @mclick)

'txtCommands.Left = 300
'txtCommands.AnchorRight = asAnchor
'cboCommands.ImagesList = @imgList
'txtCommands.Style = cbDropDown
'txtCommands.Align = 3
'txtCommands.Items.Add "fdfd"

tbStandard.Name = "Standard"
tbStandard.ImagesList = @imgList
tbStandard.HotImagesList = @imgList
tbStandard.DisabledImagesList = @imgListD
tbStandard.Align = 3
tbStandard.Flat = True
tbStandard.List = True
tbStandard.Buttons.Add tbsAutosize, "New",,@mClick, "New", , ML("&New") & " (Ctrl+N)", True
tbStandard.Buttons.Add , "Open",, @mClick, "Open", , ML("&Open ...") & " (Ctrl+O)", True
tbStandard.Buttons.Add , "Save",, @mClick, "Save", , ML("&Save ...") & " (Ctrl+S)", True
tbStandard.Buttons.Add , "SaveAll",, @mClick, "SaveAll", , ML("Save All") & " (Shift+Ctrl+S)", True
tbStandard.Buttons.Add tbsSeparator
tbStandard.Buttons.Add , "Undo",, @mClick, "Undo", , ML("Undo") & " (Ctrl+Z)", True
tbStandard.Buttons.Add , "Redo",, @mClick, "Redo", , ML("Redo") & " (Ctrl+Y)", True
tbStandard.Buttons.Add tbsSeparator
tbStandard.Buttons.Add , "Cut",, @mClick, "Cut", , ML("Cut") & " (Ctrl+X)", True
tbStandard.Buttons.Add , "Copy",, @mClick, "Copy", , ML("Copy") & " (Ctrl+C)", True
tbStandard.Buttons.Add , "Paste",, @mClick, "Paste", , ML("Paste") & " (Ctrl+V)", True
tbStandard.Buttons.Add tbsSeparator
tbStandard.Buttons.Add , "Find",, @mClick, "Find", , ML("Find") & " (Ctrl+F)", True
tbStandard.Buttons.Add tbsSeparator
tbStandard.Buttons.Add , "Format",, @mClick, "Format", , ML("Format") & " (Ctrl+Tab)", True
tbStandard.Buttons.Add , "Unformat",, @mClick, "Unformat", , ML("Unformat") & " (Shift+Ctrl+Tab)", True
tbStandard.Buttons.Add tbsSeparator
tbStandard.Buttons.Add , "Comment",, @mClick, "SingleComment", , ML("Single comment") & " (Ctrl+I)", True
tbStandard.Buttons.Add , "UnComment",, @mClick, "UnComment", , ML("UnComment") & " (Shift+Ctrl+I)", True
tbStandard.Buttons.Add tbsSeparator
tbStandard.Buttons.Add , "SyntaxCheck",, @mClick, "SyntaxCheck", , ML("Syntax Check"), True
Var tbButton = tbStandard.Buttons.Add(tbsWholeDropdown, "Try",, @mClick, "Try", ML("Error Handling"), ML("Error Handling"), True)
tbButton->DropDownMenu.Add ML("Numbering"), "", "NumberOn", @mclick
tbButton->DropDownMenu.Add ML("Remove Numbering"), "", "NumberOff", @mclick
tbButton->DropDownMenu.Add "-"
tbButton->DropDownMenu.Add ML("Procedure numbering"), "", "ProcedureNumberOn", @mclick
tbButton->DropDownMenu.Add ML("Remove Procedure numbering"), "", "ProcedureNumberOff", @mclick
tbButton->DropDownMenu.Add "-"
tbButton->DropDownMenu.Add "On Error Resume Next", "", "OnErrorResumeNext", @mclick
tbButton->DropDownMenu.Add "On Error Goto ...", "", "OnErrorGoto", @mclick
tbButton->DropDownMenu.Add "On Error Goto ... Resume Next", "", "OnErrorGotoResumeNext", @mclick
tbButton->DropDownMenu.Add ML("Remove Error Handling"), "", "RemoveErrorHandling", @mclick
tbStandard.Buttons.Add tbsSeparator
tbStandard.Buttons.Add tbsCheck Or tbsAutoSize, "UseDebugger",, @mClick, "TBUseDebugger", , ML("Use Debugger"), True
tbStandard.Buttons.Add , "Compile",, @mClick, "Compile", , ML("Compile") & " (Ctrl+F9)", True
Var tbMake = tbStandard.Buttons.Add(tbsAutosize Or tbsWholeDropdown, "Make",, @mClick, "Make", , ML("Make"), True)
tbMake->DropDownMenu.Add "Make", "", "Make", @mclick
tbMake->DropDownMenu.Add "Make clean", "", "MakeClean", @mclick
tbStandard.Buttons.Add , "Parameters",, @mClick, "Parameters", , ML("Parameters"), True
tbStandard.Buttons.Add tbsSeparator
tbStandard.Buttons.Add , "StartWithCompile",, @mClick, "StartWithCompile", , ML("Start With Compile") & " (F5)", True
tbStandard.Buttons.Add , "Start",, @mClick, "Start", , ML("Start") & " (Ctrl+F5)", True
tbStandard.Buttons.Add , "Break",, @mClick, "Break", , ML("Break") & " (Ctrl+Pause)", True, 0
tbStandard.Buttons.Add , "End",, @mClick, "End", , ML("End"), True, 0
tbStandard.Buttons.Add tbsSeparator
tbStandard.Buttons.Add tbsAutosize Or tbsCheckGroup, "Console",, @mClick, "Console", , ML("Console"), True
tbStandard.Buttons.Add tbsAutosize Or tbsCheckGroup, "Form",, @mClick, "Form", , ML("GUI"), True
tbStandard.Buttons.Add tbsSeparator
#ifdef __USE_GTK__
	tbStandard.Buttons.Add tbsCheckGroup, "B32",, @mClick, "B32", , ML("32-bit"), True
	tbStandard.Buttons.Add tbsCheckGroup, "B64",, @mClick, "B64", , ML("64-bit"), True
	#ifdef __FB_64BIT__
		tbStandard.Buttons.Item("B64")->Checked = True
	#else
		tbStandard.Buttons.Item("B32")->Checked = True
	#endif
#else
	'#IfDef __FB_64bit__
	tbStandard.Buttons.Add tbsAutosize Or tbsCheckGroup, "B32",, @mClick, "B32", , ML("32-bit"), True
	'	tbStandard.Buttons.Add tbsAutosize Or tbsCheckGroup, "B64",, @mClick, "B64", , ML("64-bit"), True, tstEnabled Or tstChecked
	'#Else
	'	tbStandard.Buttons.Add tbsAutosize Or tbsCheckGroup, "B32",, @mClick, "B32", , ML("32-bit"), True, tstEnabled Or tstChecked
	tbStandard.Buttons.Add tbsAutosize Or tbsCheckGroup, "B64",, @mClick, "B64", , ML("64-bit"), True
	'#EndIf
	#ifdef __FB_64BIT__
		tbStandard.Buttons.Item("B64")->Checked = True
	#else
		tbStandard.Buttons.Item("B32")->Checked = True
	#endif
#endif
'tbStandard.AddRange 1, @cboCommands

#ifdef __USE_GTK__
	Function progress_cb(user_data As gpointer) As gboolean
	    gtk_progress_bar_pulse(GTK_PROGRESS_BAR(user_data))
	    Return True
	End Function
#endif

#ifdef __USE_GTK__
	Dim Shared progress_bar_timer_id As guint
#endif
Sub StartProgress
	prProgress.Visible = True
	#ifdef __USE_GTK__
		progress_bar_timer_id = g_timeout_add(100, @progress_cb, prProgress.Widget)
	#endif
End Sub

Sub StopProgress
	#ifdef __USE_GTK__
		If progress_bar_timer_id <> 0 Then
			'g_source_remove(progress_bar_timer_id)
			'progress_bar_timer_id = 0
		End If
	#endif
	prProgress.Visible = False
End Sub

stBar.Align = 4
stBar.Add ML("Press F1 for get more information")
Var spProgress = stBar.Add("")
spProgress->Width = 100
stBar.Add "NUM"

prProgress.Visible = False
prProgress.Marquee = True
prProgress.SetMarquee True, 100
#ifdef __USE_GTK__
	prProgress.Height = 30
	gtk_box_pack_end (GTK_BOX (gtk_statusbar_get_message_area (gtk_statusbar(stBar.Widget))), prProgress.Widget, False, True, 10)
#else
	prProgress.Top = 3
	prProgress.Parent = @stBar
#endif

'stBar.Add ""
'stBar.Panels[1]->Alignment = 1

LoadToolBox

tbExplorer.ImagesList = @imgList
tbExplorer.Align = 3
tbExplorer.Buttons.Add , "Add",, @mClick, "AddFileToProject", , ML("Add File To Project"), True
tbExplorer.Buttons.Add , "Remove",, @mClick, "RemoveFileFromProject", , ML("Remove File From Project"), True
tbExplorer.Buttons.Add tbsSeparator
tbExplorer.Buttons.Add tbsCheck, "Folder",, @mClick, "Folder", , ML("Show Folders"), True
tbExplorer.Flat = True

Sub tbFormClick(ByRef Sender As My.Sys.Object)
	Var bFlag = Cast(ToolButton Ptr, @Sender)->Checked 
	Select Case Sender.ToString
	Case "Text"
		If bFlag Then
			tbToolBox.Style = tpsBothHorizontal
		Else
			tbToolBox.Style = tpsIcons
		End If
		'tbToolBox.RecreateWnd
	End Select
	tpShakl_Resize *tpShakl, tpShakl->Width, tpShakl->Height
End Sub

tbForm.ImagesList = @imgList
tbForm.Align = 3
tbForm.List = True
tbForm.Buttons.Add tbsCheck, "Label", , @tbFormClick, "Text", "", ML("Text"), , tstChecked Or tstEnabled
tbForm.Buttons.Add tbsSeparator
tbForm.Buttons.Add , "Component", , ,"", "", ML("Add Components")
tbForm.Flat = True

Dim Shared As Integer tabLeftWidth = 150, tabRightWidth = 150, tabBottomHeight = 150

splLeft.Align = 1
splRight.Align = 2
splBottom.Align = 4

Function GetLeftClosedStyle As Boolean
	Return Not tabLeft.TabPosition = tpTop
End Function

Sub SetLeftClosedStyle(Value As Boolean)
	If Value Then
		'tabLeft.Align = 1
		tabLeft.TabPosition = tpLeft
		tabLeft.TabIndex = -1
		#ifdef __USE_GTK__
			pnlLeft.Width = 30
		#else
			pnlLeft.Width = tabLeft.ItemWidth(0) + 2
		#endif
		splLeft.Visible = False
	Else
		pnlLeft.Width = tabLeftWidth
		'tabLeft.Width = tabLeftWidth
		tabLeft.TabPosition = tpTop
		'tabLeft.Align = 5
		splLeft.Visible = True
	End If
	'#IfNDef __USE_GTK__
	frmMain.RequestAlign
	'#EndIf
End Sub

Sub tabLeft_DblClick(ByRef Sender As Control)
	SetLeftClosedStyle Not GetLeftClosedStyle
End Sub

Sub scrTool_Scroll(ByRef Sender As Control, ByRef NewPos As Integer)
	tbToolBox.Top = tbForm.Height - NewPos
End Sub

scrTool.Style = sbVertical
scrTool.Align = 2
scrTool.ArrowChangeSize = tbToolBox.ButtonHeight
scrTool.PageSize = 3 * scrTool.ArrowChangeSize
scrTool.OnScroll = @scrTool_Scroll
scrTool.OnMouseWheel = @scrTool_MouseWheel
scrTool.OnResize = @tpShakl_Resize

Sub tvExplorer_NodeActivate(ByRef Sender As Control, ByRef Item As TreeNode)
	#ifdef __USE_GTK__
		If Item.Nodes.Count > 0 Then
			If Item.IsExpanded Then
				Item.Collapse
			Else
				Item.Expand
			End If
		End If
	#endif
	If Item.ImageKey = "Project" Then Exit Sub
	Dim t As Boolean
	For i As Integer = 0 To ptabCode->TabCount - 1
		If Cast(TabWindow Ptr, ptabCode->Tabs[i])->tn = @Item Then
			ptabCode->TabIndex = ptabCode->Tabs[i]->Index
			t = True
			Exit For
		End If
	Next i
	If Not t Then
		If Item.Tag <> 0 Then AddTab *Cast(ExplorerElement Ptr, Item.Tag)->FileName, , @Item
	End If
End Sub

Sub tvExplorer_DblClick(ByRef Sender As Control)
	Dim tn As TreeNode Ptr = tvExplorer.SelectedNode
	If tn = 0 Then Exit Sub
	If tn->ImageKey = "Project" Then Exit Sub
	Dim t As Boolean
	For i As Integer = 0 To ptabCode->TabCount - 1
		If Cast(TabWindow Ptr, ptabCode->Tabs[i])->tn = tn Then
			ptabCode->TabIndex = ptabCode->Tabs[i]->Index
			t = True
			Exit For
		End If
	Next i
	If Not t Then
		If tn->Tag <> 0 Then AddTab *Cast(ExplorerElement Ptr, tn->Tag)->FileName, , tn
	End If
End Sub

Sub tvExplorer_KeyDown(ByRef Sender As Control, Key As Integer,Shift As Integer)
	#ifdef __USE_GTK__
		Select Case Key
		Case GDK_KEY_LEFT
			
		End Select
	#else
		If Key = VK_Return Then tvExplorer_DblClick Sender
	#endif
End Sub

Sub tvExplorer_SelChange(ByRef Sender As TreeView, ByRef Item As TreeNode)
	Static OldParentNode As TreeNode Ptr
	Dim As TreeNode Ptr ptn = tvExplorer.SelectedNode
	If ptn = 0 Then Exit Sub
	ptn = GetParentNode(ptn)
	If Not OldParentNode = ptn Then 
		pfProjectProperties->RefreshProperties
		OldParentNode = ptn
	End If
End Sub

tvExplorer.Images = @imgList
tvExplorer.SelectedImages = @imgList
tvExplorer.Align = 5
tvExplorer.HideSelection = False
'tvExplorer.Sorted = True
'tvExplorer.OnDblClick = @tvExplorer_DblClick
tvExplorer.OnNodeActivate = @tvExplorer_NodeActivate
tvExplorer.OnKeyDown = @tvExplorer_KeyDown
tvExplorer.OnSelChange = @tvExplorer_SelChange
tvExplorer.ContextMenu = @mnuExplorer

Sub tabLeft_SelChange(ByRef Sender As Control, NewIndex As Integer)
	#ifdef __USE_GTK__
		If tabLeft.TabPosition = tpLeft And pnlLeft.Width = 30 Then
	#else
		If tabLeft.TabPosition = tpLeft And tabLeft.TabIndex <> -1 Then
	#endif
		tabLeft.SetFocus
		pnlLeft.Width = tabLeftWidth
		pnlLeft.RequestAlign
		splLeft.Visible = True
		'#IfNDef __USE_GTK__
		frmMain.RequestAlign
		'#EndIf
	End If
End Sub

Sub tabLeft_Click(ByRef Sender As Control)
	If tabLeft.TabPosition = tpLeft And pnlLeft.Width = 30 Then
		tabLeft.SetFocus
		pnlLeft.Width = tabLeftWidth
		pnlLeft.RequestAlign
		splLeft.Visible = True
		frmMain.RequestAlign
	End If
End Sub

Sub pnlLeft_Resize(ByRef Sender As Control, NewWidth As Integer = -1, NewHeight As Integer = -1)
	#ifdef __USE_GTK__
		If pnlLeft.Width <> 30 Then tabLeftWidth = NewWidth ': tabLeft.Width = pnlLeft.Width
	#else
		If tabLeft.TabIndex <> -1 Then tabLeftWidth = pnlLeft.Width
	#endif
End Sub

pnlLeft.Name = "pnlLeft"
pnlLeft.Align = 1
pnlLeft.Width = tabLeftWidth
pnlLeft.OnReSize = @pnlLeft_Resize

tabLeft.Name = "tabLeft"
tabLeft.Width = tabLeftWidth
tabLeft.Align = 5
tabLeft.OnClick = @tabLeft_Click
tabLeft.OnDblClick = @tabLeft_DblClick
tabLeft.OnSelChange = @tabLeft_SelChange
pnlLeft.Add @tabLeft
'tabLeft.TabPosition = tpLeft

Var tpLoyiha = tabLeft.AddTab(ML("Project"))

tpShakl = tabLeft.AddTab(ML("Form"))
tpShakl->Name = "tpShakl"

lblLeft.Align = 4
lblLeft.Text = ML("Main File") & ": " & ML("Automatic")

tpLoyiha->Add @tbExplorer
tpLoyiha->Add @lblLeft
tpLoyiha->Add @tvExplorer
#ifndef __USE_GTK__
	tpShakl->Add @scrTool
#endif
tpShakl->Add @tbToolBox
tpShakl->Add @tbForm 
tpShakl->OnReSize = @tpShakl_Resize
'tabLeft.Tabs[1]->Style = tabLeft.Tabs[1]->Style Or ES_AUTOVSCROLL or WS_VSCROLL

'pnlLeft.Width = 153
'pnlLeft.Align = 1
'pnlLeft.AddRange 1, @tabLeft

Sub tbProperties_ButtonClick(Sender As My.Sys.Object)
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	Select Case Sender.ToString
	Case "Properties"
		
	End Select
End Sub

tbProperties.ImagesList = @imgList
tbProperties.Align = 3
tbProperties.Buttons.Add tbsCheck, "Categorized", , @tbProperties_ButtonClick, "PropertyCategory", "", ML("Categorized"), , tstEnabled Or tstChecked
tbProperties.Buttons.Add tbsSeparator
tbProperties.Buttons.Add , "Property", , @tbProperties_ButtonClick, "Properties", "", ML("Properties"), , tstEnabled
tbProperties.Flat = True

tbEvents.ImagesList = @imgList
tbEvents.Align = 3
tbEvents.Buttons.Add tbsCheck, "Categorized", , @tbProperties_ButtonClick, "EventCategory", "", ML("Categorized"), , tstEnabled
tbEvents.Buttons.Add tbsSeparator
tbEvents.Flat = True

Sub txtPropertyValue_KeyDown(ByRef Sender As Control, Key As Integer, Shift As Integer)
	
End Sub

Sub txtPropertyValue_KeyUp(ByRef Sender As Control, Key As Integer, Shift As Integer)
	If Key = 13 Then
		lvProperties.SetFocus
	End If
End Sub

Sub txtPropertyValue_KeyPress(ByRef Sender As Control, Key As Byte)
	
End Sub

'txtPropertyValue.BorderStyle = 0
txtPropertyValue.Visible = False
txtPropertyValue.WantReturn = True
txtPropertyValue.OnKeyDown = @txtPropertyValue_KeyDown
txtPropertyValue.OnKeyUp = @txtPropertyValue_KeyUp
txtPropertyValue.OnKeyPress = @txtPropertyValue_KeyPress
txtPropertyValue.OnLostFocus = @txtPropertyValue_LostFocus

cboPropertyValue.OnKeyUp = @txtPropertyValue_KeyUp
cboPropertyValue.OnChange = @cboPropertyValue_Change
cboPropertyValue.Left = -1
cboPropertyValue.Top = -2

pnlPropertyValue.Visible = False
pnlPropertyValue.Add @cboPropertyValue

Dim Shared CtrlEdit As Control Ptr
Dim Shared Cpnt As Component Ptr

Sub lvProperties_SelectedItemChanged(ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 OrElse tb->Des = 0 OrElse tb->Des->SelectedControl = 0 OrElse tb->Des->ReadPropertyFunc = 0 Then Exit Sub
	Dim As Rect lpRect
	'Dim As TreeListViewItem Ptr Item = lvProperties.ListItems.Item(ItemIndex)
	lvProperties.SetFocus
	txtPropertyValue.Visible = False
	pnlPropertyValue.Visible = False
	#ifndef __USE_GTK__
		ListView_GetSubItemRect(lvProperties.Handle, Item->GetItemIndex, 1, LVIR_BOUNDS, @lpRect)
	#EndIf
	Var te = GetPropertyType(WGet(tb->Des->ReadPropertyFunc(tb->Des->SelectedControl, "ClassName")), GetItemText(Item))
	If te = 0 Then Exit Sub
	If LCase(te->TypeName) = "boolean" Then
		CtrlEdit = @pnlPropertyValue
		cboPropertyValue.Clear
		cboPropertyValue.AddItem " false"
		cboPropertyValue.AddItem " true"
		cboPropertyValue.ItemIndex = cboPropertyValue.IndexOf(" " & Item->Text(1))
	ElseIf LCase(te->TypeName) = "integer" AndAlso CInt(te->EnumTypeName <> "") AndAlso CInt(Comps.Contains(te->EnumTypeName)) Then
		CtrlEdit = @pnlPropertyValue
		cboPropertyValue.Clear
		Var tbi = Cast(ToolBoxItem Ptr, Comps.Object(Comps.IndexOf(te->EnumTypeName)))
		If tbi Then
			For i As Integer = 0 To tbi->Elements.Count - 1
				cboPropertyValue.AddItem " " & i & " - " & tbi->Elements.Item(i)
			Next i
			If Val(Item->Text(1)) >= 0 AndAlso Val(Item->Text(1)) <= tbi->Elements.Count - 1 Then
				cboPropertyValue.ItemIndex = Val(Item->Text(1))
			End If
		End If
	ElseIf IsBase(te->TypeName, "Component") Then
		CtrlEdit = @pnlPropertyValue
		cboPropertyValue.Clear
		For i As Integer = 1 To tb->cboClass.Items.Count - 1
			Cpnt = tb->cboClass.Items.Item(i)->Object
			If Cpnt <> 0 Then
				If CInt(te->EnumTypeName <> "") Then
					If (CInt(Cpnt->ClassName = Trim(te->EnumTypeName)) OrElse CInt(IsBase(Cpnt->ClassName, Trim(te->EnumTypeName)))) Then
						cboPropertyValue.AddItem " " & Cpnt->Name
					End If
				ElseIf CInt(Cpnt->ClassName = WithoutPtr(Trim(te->TypeName))) OrElse CInt(IsBase(Cpnt->ClassName, WithoutPtr(Trim(te->TypeName)))) Then
					cboPropertyValue.AddItem " " & Cpnt->Name
				End If
			End If
		Next i
		cboPropertyValue.ItemIndex = cboPropertyValue.IndexOf(" " & Item->Text(1))
	Else
		Dim tbi As ToolBoxItem Ptr
		If Comps.Contains(te->TypeName) Then tbi = Cast(ToolBoxItem Ptr, Comps.Object(Comps.IndexOf(te->TypeName)))
		If tbi AndAlso tbi->ElementType = "Enum" Then
			CtrlEdit = @pnlPropertyValue
			cboPropertyValue.Clear
			For i As Integer = 0 To tbi->Elements.Count - 1
				cboPropertyValue.AddItem " " & i & " - " & tbi->Elements.Item(i)
			Next i
			If Val(Item->Text(1)) >= 0 AndAlso Val(Item->Text(1)) <= tbi->Elements.Count - 1 Then
				cboPropertyValue.ItemIndex = Val(Item->Text(1))
			End If
		Else
			CtrlEdit = @txtPropertyValue
			CtrlEdit->Text = Item->Text(1)
		End If
	End If
	CtrlEdit->SetBounds lpRect.Left, lpRect.Top, lpRect.Right - lpRect.Left, lpRect.Bottom - lpRect.Top - 1
	If CtrlEdit = @pnlPropertyValue Then cboPropertyValue.Width = lpRect.Right - lpRect.Left + 2
	CtrlEdit->Visible = True
	If te->Comment <> 0 Then
		txtLabelProperty.Text = *te->Comment
	End If
End Sub

'Sub lvProperties_ItemDblClick(ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
'    If Item <> 0 Then ClickProperty Item->Index
'End Sub

Sub lvEvents_ItemDblClick(ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
	Dim As TabWindow Ptr tb = tabRight.Tag
	If tb = 0 OrElse tb->Des = 0 OrElse tb->Des->SelectedControl = 0 Then Exit Sub
	If Item <> 0 Then FindEvent tb->Des->SelectedControl, Item->Text(0)
End Sub

Sub lvProperties_EndScroll(ByRef Sender As TreeListView)
	If CtrlEdit = 0 Then Exit Sub
	If lvProperties.SelectedItem = 0 Then
		CtrlEdit->Visible = False
	Else
		Dim As Rect lpRect
		#IfNDef __USE_GTK__
			ListView_GetSubItemRect(lvProperties.Handle, lvProperties.SelectedItem->Index, 1, LVIR_BOUNDS, @lpRect)
		#endif
		'If lpRect.Top < lpRect.Bottom - lpRect.Top Then
		'    txtPropertyValue.Visible = False
		'Else
		CtrlEdit->SetBounds lpRect.Left, lpRect.Top, lpRect.Right - lpRect.Left, lpRect.Bottom - lpRect.Top - 1
		CtrlEdit->Visible = True
		'End If
	End If
End Sub

Dim Shared lvWidth As Integer

Sub lvProperties_Resize(ByRef Sender As Control, NewWidth As Integer = -1, NewHeight As Integer = -1)
	lvWidth = lvProperties.Width - 22
	lvProperties.Columns.Column(1)->Width = (lvWidth - 32) / 2
	lvProperties.Columns.Column(0)->Width = lvWidth - (lvWidth - 32) / 2
	txtPropertyValue.Width = (lvWidth - 32) / 2
	pnlPropertyValue.Width = (lvWidth - 32) / 2
	cboPropertyValue.Width = (lvWidth - 32) / 2 + 2
	lvProperties_EndScroll(*Cast(TreeListView Ptr, @Sender))
End Sub

Sub lvEvents_Resize(ByRef Sender As Control, NewWidth As Integer = -1, NewHeight As Integer = -1)
	lvWidth = lvEvents.Width - 22
	lvEvents.Columns.Column(0)->Width = lvWidth / 2
	lvEvents.Columns.Column(1)->Width = lvWidth / 2
	'lvEvents_EndScroll(*Cast(ListView Ptr, @Sender))
End Sub

'Sub lvProperties_KeyDown(ByRef Sender As Control, Key As Integer, Shift As Integer)
'    Dim iItem As Integer
'	Dim dwState As Integer
'	Dim iIndent As Integer
'	Dim iIndentChild As Integer
'	' Get the selected item...
'	#IfNDef __USE_GTK__
'		iItem = ListView_GetNextItem(lvProperties.Handle, -1, LVNI_FOCUSED Or LVNI_SELECTED)
'	#EndIf
'	If (iItem <> -1) Then
'    ' Get the item's indent and state values
'	#IfNDef __USE_GTK__
'		dwState = Listview_GetItemStateEx(lvProperties.Handle, iItem, iIndent)
'		Select Case Key
'		  ' ========================================================
'		  ' The right arrow key expands the selected item, then selects the current
'		  ' item's first child
'		  Case VK_RIGHT
'			' If the item is collaped, expanded it, otherwise select
'			' the first child of the selected item (if any)
'			If (dwState = 1) Then
'			  AddChildItems(iItem, iIndent)
'			ElseIf (dwState = 2) Then
'			  If iItem < lvProperties.ListItems.Count - 1 AndAlso lvProperties.ListItems.Item(iItem + 1)->Indent > iIndent Then
'				  ListView_SetItemState(lvProperties.Handle, iItem + 1, LVIS_FOCUSED Or LVIS_SELECTED, LVIS_FOCUSED Or LVIS_SELECTED)
'			  End If
'			  'iItem = ListView_GetRelativeItem(m_hwndLV, iItem, lvriChild)
'			  'If (iItem <> -1) Then Call ListView_SetFocusedItem(lvProperties.Handle, iItem)
'			End If
'		  ' ========================================================
'		  ' The left arrow key collapses the selected item, then selects the current
'		  ' item's parent. The backspace key only selects the current item's parent
'		  Case VK_LEFT, VK_BACK
'			' If vbKeyLeft and the item is expanded, collaped it, otherwise select
'			' the parent of the selected item (if any)
'			If (Key = VK_LEFT) And (dwState = 2) Then
'				RemoveChildItems(iItem, iIndent)
'			Else
'				For i As Integer = iItem To 0 Step -1
'					dwState = Listview_GetItemStateEx(lvProperties.Handle, i, iIndentChild)
'					If iIndentChild < iIndent Then
'						ListView_SetItemState(lvProperties.Handle, i, LVIS_FOCUSED Or LVIS_SELECTED, LVIS_FOCUSED Or LVIS_SELECTED)
'						Exit For
'					End If
'				Next
'	'          iItem = ListView_GetRelativeItem(m_hwndLV, iItem, lvriParent)
'	'          If (iItem <> LVI_NOITEM) Then
'	'            Call ListView_SetFocusedItem(m_hwndLV, iItem)
'	'            Call ListView_EnsureVisible(m_hwndLV, iItem, False)
'	'          End If
'			End If
'		End Select   ' KeyCode
'	#EndIf
'  End If   ' (iItem <> LVI_NOITEM)
'End Sub

Sub lvEvents_KeyDown(ByRef Sender As Control, ByRef Item As TreeListViewItem Ptr)
	
End Sub

Sub lvProperties_KeyPress(ByRef Sender As Control, Key As Byte)
	txtPropertyValue.Text = WChr(Key)
	txtPropertyValue.SetFocus
	txtPropertyValue.SetSel 1, 1
	Key = 0
End Sub

Sub lvProperties_KeyUp(ByRef Sender As Control, Key As Integer, Shift As Integer)
	#ifndef __USE_GTK__
		Select Case Key
		Case VK_Return: txtPropertyValue.SetFocus
		Case VK_Left, VK_Right, VK_Up, VK_Down, VK_NEXT, VK_PRIOR
		End Select
	#endif
	'Key = 0
End Sub

imgListStates.AddPng "Collapsed", "Collapsed"
imgListStates.AddPng "Expanded", "Expanded"
imgListStates.AddPng "Property", "Property"
imgListStates.AddPng "Event", "Event"

lvProperties.Align = 5
'lvProperties.Sort = ssSortAscending
lvProperties.StateImages = @imgListStates
lvProperties.SmallImages = @imgListStates
'lvProperties.ColumnHeaderHidden = True
lvProperties.Columns.Add ML("Property"), , 70
lvProperties.Columns.Add ML("Value"), , 50, , True
lvProperties.Add @txtPropertyValue
lvProperties.Add @pnlPropertyValue
lvProperties.OnSelectedItemChanged = @lvProperties_SelectedItemChanged
lvProperties.OnEndScroll = @lvProperties_EndScroll
lvProperties.OnResize = @lvProperties_Resize
'lvProperties.OnMouseDown = @lvProperties_MouseDown
'lvProperties.OnKeyDown = @lvProperties_KeyDown
'lvProperties.OnItemDblClick = @lvProperties_ItemDblClick
lvProperties.OnKeyUp = @lvProperties_KeyUp
lvProperties.OnCellEditing = @lvProperties_CellEditing
lvProperties.OnCellEdited = @lvProperties_CellEdited
lvProperties.OnItemExpanding = @lvProperties_ItemExpanding

lvEvents.Align = 5
lvEvents.Sort = ssSortAscending
lvEvents.Columns.Add ML("Event"), , 70
lvEvents.Columns.Add ML("Value"), , -2
lvEvents.OnItemKeyDown = @lvEvents_KeyDown
#ifdef __USE_GTK__
	lvEvents.OnItemActivate = @lvEvents_ItemDblClick
#else
	lvEvents.OnItemDblClick = @lvEvents_ItemDblClick
#endif
lvEvents.OnResize = @lvEvents_Resize
lvEvents.SmallImages = @imgListStates

splProperties.Align = 4

splEvents.Align = 4

txtLabelProperty.Height = 50
txtLabelProperty.Align = 4
txtLabelProperty.Multiline = True
txtLabelProperty.ReadOnly = True
#ifndef __USE_GTK__
	txtLabelProperty.BackColor = clBtnFace
#EndIf
txtLabelProperty.WordWraps = True

txtLabelEvent.Height = 50
txtLabelEvent.Align = 4
txtLabelEvent.Multiline = True
txtLabelEvent.ReadOnly = True
#IfNDef __USE_GTK__
	txtLabelEvent.BackColor = clBtnFace
#EndIf
txtLabelEvent.WordWraps = True

Function GetRightClosedStyle As Boolean
	Return Not tabRight.TabPosition = tpTop
End Function

Sub SetRightClosedStyle(Value As Boolean)
	If Value Then
		tabRight.TabPosition = tpRight
		tabRight.TabIndex = -1
		#IfDef __USE_GTK__
			pnlRight.Width = 30
		#Else
			pnlRight.Width = tabRight.ItemWidth(0) + 2
		#EndIf
		splRight.Visible = False
		pnlRight.RequestAlign
	Else
		tabRight.TabPosition = tpTop
		tabRight.Width = tabRightWidth
		pnlRight.Width = tabRightWidth
		'pnlRight.RequestAlign
		splRight.Visible = True
		
	End If
	frmMain.RequestAlign
End Sub

Sub tabRight_DblClick(ByRef Sender As Control)
	SetRightClosedStyle Not GetRightClosedStyle
End Sub

Sub tabRight_SelChange(ByRef Sender As Control, NewIndex As Integer)
	#IfDef __USE_GTK__
		If tabRight.TabPosition = tpRight And pnlRight.Width = 30 Then
	#Else
		If tabRight.TabPosition = tpRight And tabRight.TabIndex <> -1 Then
	#EndIf
		tabRight.SetFocus
		pnlRight.Width = tabRightWidth
		pnlRight.RequestAlign
		splRight.Visible = True
		frmMain.RequestAlign
	End If
End Sub

tvVar.Align = 5
tvPrc.Align = 5
tvThd.Align = 5
tvWch.Align = 5

tvVar.ContextMenu = @mnuVars

Sub tabRight_Click(ByRef Sender As Control)
	If tabRight.TabPosition = tpRight And pnlRight.Width = 30 Then
		tabRight.SetFocus
		pnlRight.Width = tabRightWidth
		pnlRight.RequestAlign
		splRight.Visible = True
		frmMain.RequestAlign
	End If
End Sub

Sub pnlRight_Resize(ByRef Sender As Control, NewWidth As Integer = -1, NewHeight As Integer = -1)
	#ifdef __USE_GTK__
		If pnlRight.Width <> 30 Then tabRightWidth = NewWidth: tabRight.SetBounds(0, 0, tabRightWidth, NewHeight)
	#else
		If tabRight.TabIndex <> -1 Then tabRightWidth = tabRight.Width
	#endif
End Sub

pnlRight.Align = 2
pnlRight.Width = tabRightWidth
pnlRight.OnResize = @pnlRight_Resize

tabRight.Width = tabRightWidth
#ifdef __USE_GTK__
	tabRight.Align = 2
#else
	tabRight.Align = 5
#endif
tabRight.OnClick = @tabRight_Click
tabRight.OnDblClick = @tabRight_DblClick
tabRight.OnSelChange = @tabRight_SelChange
'tabRight.TabPosition = tpRight
tabRight.AddTab(ML("Properties"))
tabRight.Tabs[0]->Add @tbProperties
tabRight.Tabs[0]->Add @txtLabelProperty
tabRight.Tabs[0]->Add @splProperties
tabRight.Tabs[0]->Add @lvProperties
tabRight.AddTab(ML("Events"))
tabRight.Tabs[1]->Add @tbEvents
tabRight.Tabs[1]->Add @txtLabelEvent
tabRight.Tabs[1]->Add @splEvents
tabRight.Tabs[1]->Add @lvEvents
pnlRight.Add @tabRight

'pnlRight.Width = 153
'pnlRight.Align = 2
'pnlRight.AddRange 1, @tabRight

'ptabCode->Images.AddIcon bmp

Sub tabCode_SelChange(ByRef Sender As TabControl, NewIndex As Integer)
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, Sender.Tab(NewIndex))
	If tb = 0 Then Exit Sub
	tb->tn->SelectItem
	If frmMain.ActiveControl <> tb And frmMain.ActiveControl <> @tb->txtCode Then tb->txtCode.SetFocus
	lvProperties.ListItems.Clear
	tb->FillAllProperties
End Sub

ptabCode->Images = @imgList
ptabCode->Align = 5
ptabCode->OnPaint = @tabCode_Paint
ptabCode->OnSelChange = @tabCode_SelChange
ptabCode->ContextMenu = @mnuTabs

txtOutput.Name = "txtOutput"
txtOutput.Align = 5
txtOutput.Multiline = True
txtOutput.ScrollBars = 3
txtOutput.OnDblClick = @txtOutput_DblClick

Sub txtImmediate_KeyDown(ByRef Sender As Control, Key As Integer, Shift As Integer)
	Dim As Integer iLine = txtImmediate.GetLineFromCharIndex(txtImmediate.SelStart)
	Dim As WString Ptr sLine = @txtImmediate.Lines(iLine)
	Dim bCtrl As Boolean
	#ifdef __USE_GTK__
		bCtrl = Shift And GDK_Control_MASK
	#else
		bCtrl = GetKeyState(VK_CONTROL) And 8000
	#endif
	If CInt(Not bCtrl) AndAlso CInt(WGet(sLine) <> "") Then
		If Key = Keys.Enter Then
			Open ExePath & "/Temp/FBTemp.bas" For Output Encoding "utf-8" As #1
			Print #1, WGet(sLine)
			Close #1
			Dim As WString Ptr FbcExe, ExeName
			If tbStandard.Buttons.Item("B32")->Checked Then
				FbcExe = Compiler32Path
			Else
				FbcExe = Compiler64Path
			End If
			PipeCmd "", """" & *FbcExe & """ -b """ & ExePath & "/Temp/FBTemp.bas"" -i """ & ExePath & "/" & *MFFPath & """ > """ & ExePath & "/Temp/debug_compil.log"" 2> """ & ExePath & "/Temp/debug_compil2.log"""
			Dim As WString Ptr Buff, LogText
			Dim As WString Ptr ErrFileName, ErrTitle
			Dim As Integer nLen, nLen2
			If Open(ExePath & "/Temp/debug_compil.log" For Input As #1) = 0 Then
				nLen = LOF(1) + 1
				WLet LogText, ""
				WLet Buff, Space(nLen)
				While Not EOF(1)
					Line Input #1, *Buff
					SplitError(*Buff, ErrFileName, ErrTitle, iLine)
					WLet LogText, *LogText & *ErrTitle & !"\r"
				Wend
				Close #1
			End If
			If Open(exepath & "/Temp/debug_compil2.log" For Input As #1) = 0 Then
				nLen2 = LOF(1) + 1
				WLet Buff, Space(nLen2)
				While Not EOF(1)
					Line Input #1, *Buff
					WLet LogText, *LogText & *Buff & !"\r"
				Wend
				Close #1
			End If
			Key = 0
			If WGet(LogText) <> "" Then
				MsgBox !"Compile error:\r\r" & *LogText, , mtWarning
			Else
				#IfDef __USE_GTK__
					WLet ExeName, ExePath & "/Temp/FBTemp"
				#Else
					WLet ExeName, ExePath & "/Temp/FBTemp.exe"
				#EndIf
				PipeCmd "", """" & *ExeName & """ > """ & ExePath & "/Temp/debug_compil.log"" 2> """ & ExePath & "/Temp/debug_compil2.log"""
				Dim Result As Integer
				Result = Open(exepath & "/Temp/debug_compil.txt" For Input As #2)
				'				If Result <> 0 Then Result = Open(exepath & "/Temp/debug_compil.log" For Input Encoding "utf-16" As #2)
				'				If Result <> 0 Then Result = Open(exepath & "/Temp/debug_compil.log" For Input Encoding "utf-8" As #2)
				'				If Result <> 0 Then Result = Open(exepath & "/Temp/debug_compil.log" For Input As #2)
				If Result = 0 Then
					Dim As WString Ptr Buff2
					nLen = LOF(2) + 1
					'WReallocate Buff2, nLen
					Dim As Integer i
					WLet Buff2, WInput(nLen, #2)
					'While Not EOF(2)
					'Line Input #2, *Buff2
					i = txtImmediate.GetCharIndexFromLine(iLine) + txtImmediate.GetLineLength(iLine)
					txtImmediate.SetSel i, i
					txtImmediate.SelText = wchr(13) & wchr(10) & *Buff2
					ptabBottom->Update
					txtImmediate.Update
					frmMain.Update
					'Wend
					WDeallocate Buff2
					Close #2
				End If
				Kill *ExeName
			End If
			WDeallocate Buff
			WDeallocate ExeName
			WDeallocate LogText
			WDeallocate ErrFileName
			WDeallocate ErrTitle
		End If
	End If
	If Not EndsWith(txtImmediate.Text, !"\r") Then txtImmediate.Text &= !"\r"
End Sub

txtImmediate.Align = 5
txtImmediate.Multiline = True
txtImmediate.ScrollBars = 3
txtImmediate.OnKeyDown = @txtImmediate_KeyDown

Sub lvErrors_ItemActivate(ByRef Sender As Control, ByVal itemIndex As Integer)
	Dim Item As ListViewItem Ptr = lvErrors.ListItems.Item(itemIndex)
	SelectError(item->Text(2), Val(item->Text(1)), item->Tag)
End Sub

'Sub lvErrors_KeyDown(ByRef Sender As Control, Key As Integer,Shift As Integer)
'    #IfNDef __USE_GTK__
'		If Key = VK_Return Then 
'			Dim lvi As ListViewItem Ptr = lvErrors.SelectedItem
'			If lvi <> 0 Then lvErrors_ItemDblClick Sender, *lvi
'		End If
'	#EndIf
'End Sub

lvErrors.Images = @imgList
lvErrors.StateImages = @imgList
lvErrors.SmallImages = @imgList
lvErrors.Align = 5
lvErrors.Columns.Add ML("Content"), , 500, cfLeft
lvErrors.Columns.Add ML("Line"), , 50, cfRight
lvErrors.Columns.Add ML("File"), , 300, cfLeft
lvErrors.OnItemActivate = @lvErrors_ItemActivate
'lvErrors.OnKeyDown = @lvErrors_KeyDown

Sub lvSearch_ItemActivate(ByRef Sender As Control, ByVal itemIndex As Integer)
	Dim Item As ListViewItem Ptr = lvSearch.ListItems.Item(itemIndex)
	SelectSearchResult(item->Text(3), Val(item->Text(1)), Val(item->Text(2)), Len(lvSearch.Text), item->Tag)
End Sub

'Sub lvSearch_KeyDown(ByRef Sender As Control, Key As Integer,Shift As Integer)
'    #IfNDef __USE_GTK__
'		If Key = VK_Return Then 
'			Dim lvi As ListViewItem Ptr = lvSearch.SelectedItem
'			If lvi <> 0 Then lvSearch_ItemDblClick Sender, *lvi
'		End If
'	#EndIf
'End Sub

lvSearch.Align = 5
lvSearch.Columns.Add ML("Line Text"), , 500, cfLeft
lvSearch.Columns.Add ML("Line"), , 50, cfRight
lvSearch.Columns.Add ML("Column"), , 50, cfRight
lvSearch.Columns.Add ML("File"), , 300, cfLeft
lvSearch.OnItemActivate = @lvSearch_ItemActivate
'lvSearch.OnKeyDown = @lvSearch_KeyDown

Function GetBottomClosedStyle As Boolean
	Return Not ptabBottom->TabPosition = tpTop
End Function

Sub SetBottomClosedStyle(Value As Boolean)
	If Value Then
		ptabBottom->TabPosition = tpBottom
		ptabBottom->TabIndex = -1
		#ifdef __USE_GTK__
			pnlBottom.Height = 25
		#else
			pnlBottom.Height = ptabBottom->ItemHeight(0) + 2
		#endif
		splBottom.Visible = False
		'pnlBottom.RequestAlign
	Else
		ptabBottom->TabPosition = tpTop
		ptabBottom->Height = tabBottomHeight
		pnlBottom.Height = tabBottomHeight
		pnlBottom.RequestAlign
		splBottom.Visible = True
	End If
	'#IfNDef __USE_GTK__
	frmMain.RequestAlign
	'#EndIf
End Sub

Sub tabBottom_DblClick(ByRef Sender As Control) '...'
	SetBottomClosedStyle Not GetBottomClosedStyle
End Sub

Sub tabBottom_SelChange(ByRef Sender As Control, NewIndex As Integer)
	#ifdef __USE_GTK__
		If ptabBottom->TabPosition = tpBottom And pnlBottom.Height = 25 Then
	#else
		If ptabBottom->TabPosition = tpBottom And ptabBottom->TabIndex <> -1 Then
	#endif
		ptabBottom->SetFocus
		pnlBottom.Height = tabBottomHeight
		pnlBottom.RequestAlign
		splBottom.Visible = True
		frmMain.RequestAlign '<bp>
	End If
End Sub

Sub tabBottom_Click(ByRef Sender As Control) '<...>
	#ifdef __USE_GTK__
		If ptabBottom->TabPosition = tpBottom And pnlBottom.Height = 25 Then
	#else
		If ptabBottom->TabPosition = tpBottom And ptabBottom->TabIndex <> -1 Then
	#endif
		ptabBottom->SetFocus
		pnlBottom.Height = tabBottomHeight
		pnlBottom.RequestAlign
		splBottom.Visible = True
		frmMain.RequestAlign '<bp>
	End If
End Sub

Sub ShowMessages(ByRef msg As WString, ChangeTab As Boolean = True)
	If ChangeTab Then 
		tabBottom_SelChange(*ptabBottom, 0)
		tabBottom.TabIndex = 0
	End If
	txtOutput.SetSel txtOutput.GetTextLength, txtOutput.GetTextLength
	txtOutput.SelText = msg & WChr(13) & WChr(10)
	tabBottom.Update
	txtOutput.Update
	frmMain.Update
	#ifdef __USE_GTK__
		While gtk_events_pending()
			gtk_main_iteration()
		Wend
	#endif
	'    txtOutput.ScrollToCaret
End Sub

Sub pnlBottom_Resize(ByRef Sender As Control, NewWidth As Integer = -1, NewHeight As Integer = -1)
	#ifdef __USE_GTK__
		If pnlBottom.Height <> 25 Then tabBottomHeight = NewHeight: ptabBottom->SetBounds 0, 0, NewWidth, tabBottomHeight
	#else
		If ptabBottom->TabIndex <> -1 Then tabBottomHeight = ptabBottom->Height
	#endif
End Sub

pnlBottom.Name = "pnlBottom"
pnlBottom.Align = 4
pnlBottom.Height = tabBottomHeight
pnlBottom.OnResize = @pnlBottom_Resize

'ptabBottom->Images.AddIcon bmp
ptabBottom->Name = "tabBottom"
ptabBottom->Height = tabBottomHeight
#ifdef __USE_GTK__
	ptabBottom->Align = 4
#else
	ptabBottom->Align = 5
#endif
'ptabBottom->TabPosition = tpBottom
ptabBottom->AddTab(ML("Output"))
ptabBottom->AddTab(ML("Errors"))
ptabBottom->AddTab(ML("Find"))
ptabBottom->AddTab(ML("Immediate"))
ptabBottom->AddTab(ML("Locals"))
ptabBottom->AddTab(ML("Processes"))
ptabBottom->AddTab(ML("Threads"))
ptabBottom->AddTab(ML("Watches"))
ptabBottom->Tabs[0]->Add @txtOutput
ptabBottom->Tabs[1]->Add @lvErrors
ptabBottom->Tabs[2]->Add @lvSearch
ptabBottom->Tabs[3]->Add @txtImmediate
ptabBottom->Tabs[4]->Add @tvVar
ptabBottom->Tabs[5]->Add @tvPrc
ptabBottom->Tabs[6]->Add @tvThd
ptabBottom->Tabs[7]->Add @tvWch
ptabBottom->OnClick = @tabBottom_Click
ptabBottom->OnDblClick = @tabBottom_DblClick
ptabBottom->OnSelChange = @tabBottom_SelChange
'pnlBottom.Height = 153
'pnlBottom.Align = 4
'pnlBottom.AddRange 1, @tabBottom
pnlBottom.Add ptabBottom

LoadKeyWords '<bm>

Sub frmMain_ActiveControlChanged(ByRef sender As My.Sys.Object)
	If frmMain.ActiveControl = 0 Then Exit Sub
	If tabLeft.TabPosition = tpLeft And tabLeft.TabIndex <> -1 Then
		If frmMain.ActiveControl->Parent <> tabLeft.SelectedTab AndAlso frmMain.ActiveControl <> @tabLeft Then
			splLeft.Visible = False
			#ifdef __USE_GTK__
				pnlLeft.Width = 30
			#else
				tabLeft.TabIndex = -1
				pnlLeft.Width = tabLeft.ItemWidth(0) + 2
			#endif
			frmMain.RequestAlign
		End If
	End If
	If tabRight.TabPosition = tpRight And tabRight.TabIndex <> -1 Then
		If frmMain.ActiveControl->Parent <> tabRight.SelectedTab AndAlso frmMain.ActiveControl <> @tabRight _
			AndAlso frmMain.ActiveControl <> @txtPropertyValue AndAlso frmMain.ActiveControl <> @cboPropertyValue Then
			splRight.Visible = False
			#ifdef __USE_GTK__
				pnlRight.Width = 30
			#else
				tabRight.TabIndex = -1
				pnlRight.Width = tabRight.ItemWidth(0) + 2
			#endif
			frmMain.RequestAlign
		End If
	End If
	If ptabBottom->TabPosition = tpBottom And ptabBottom->TabIndex <> -1 Then
		If frmMain.ActiveControl->Parent <> ptabBottom->SelectedTab AndAlso frmMain.ActiveControl <> ptabBottom Then
			splBottom.Visible = False
			#ifdef __USE_GTK__
				pnlBottom.Height = 25
			#else
				ptabBottom->TabIndex = -1
				pnlBottom.Height = ptabBottom->ItemHeight(0) + 2
			#endif
			frmMain.RequestAlign
		End If
	End If
End Sub

Sub frmMain_Resize(ByRef sender As My.Sys.Object, NewWidth As Integer = -1, NewHeight As Integer = -1)
	#ifndef __USE_GTK__
		stBar.Panels[0]->Width = frmMain.ClientWidth - 50
		prProgress.Left = stBar.Width - stBar.Panels[2]->Width - prProgress.Width - 3
	#endif
End Sub

Sub frmMain_DropFile(ByRef sender As My.Sys.Object, ByRef FileName As WString)
	AddTab FileName
End Sub

Sub ConnectAddIn(AddIn As String)
	Dim As Sub(VisualFBEditorApp As Any Ptr, ByRef AppPath As WString) OnConnection
	Dim As Any Ptr AddInDll
	Dim As String f
	#ifdef __FB_WIN32__
		f = Dir(ExePath & "/AddIns/" & AddIn & ".dll")
	#else
		f = Dir(ExePath & "/AddIns/" & AddIn & ".so")
	#endif
	AddInDll = DyLibLoad(ExePath & "/AddIns/" & f)
	If AddInDll <> 0 Then
		OnConnection = DyLibSymbol(AddInDll, "OnConnection")
		If OnConnection Then
			OnConnection(pApp, pApp->FileName)
			AddIns.Add AddIn, AddInDll
		End If
	End If
End Sub

Sub DisConnectAddIn(AddIn As String)
	Dim As Sub(VisualFBEditorApp As Any Ptr) OnDisconnection
	Dim As Any Ptr AddInDll
	Dim i As Integer = AddIns.IndexOf(AddIn)
	If i <> -1 Then
		AddInDll = AddIns.Object(i)
		If AddInDll <> 0 Then
			OnDisconnection = DyLibSymbol(AddInDll, "OnDisconnection")
			If OnDisconnection Then
				OnDisconnection(pApp)
				DyLibFree(AddInDll)
			End If
		End If
		AddIns.Remove i
	End If
End Sub

Sub LoadAddIns
	Dim As String f, AddIn
	#IfDef __Fb_Win32__
		f = dir(exepath & "/AddIns/*.dll")
	#Else
		f = dir(exepath & "/AddIns/*.so")
	#EndIf
	While f <> ""
		AddIn = Left(f, InStrRev(f, ".") - 1)
		If iniSettings.ReadBool("AddInsOnStartup", AddIn, False) Then
			ConnectAddIn AddIn
		End If
		f = Dir()
	Wend
End Sub

Sub UnLoadAddins
	Dim As Any Ptr AddInDll
	For i As Integer = 0 To AddIns.Count - 1
		DisconnectAddIn AddIns.Item(i)
	Next
	AddIns.Clear
End Sub

Sub SetAutoColors
	BookmarksForeground = IIf(BookmarksForegroundOption = -1, -1, BookmarksForegroundOption)
	BookmarksBackground = IIf(BookmarksBackgroundOption = -1, -1, BookmarksBackgroundOption)
	BookmarksIndicator = IIf(BookmarksIndicatorOption = -1, clAqua, BookmarksIndicatorOption)
	BreakpointsForeground = IIf(BreakpointsForegroundOption = -1, clWhite, BreakpointsForegroundOption)
	BreakpointsBackground = IIf(BreakpointsBackgroundOption = -1, clMaroon, BreakpointsBackgroundOption)
	BreakpointsIndicator = IIf(BreakpointsIndicatorOption = -1, clMaroon, BreakpointsIndicatorOption)
	CommentsForeground = IIf(CommentsForegroundOption = -1, clGreen, CommentsForegroundOption)
	CommentsBackground = IIf(CommentsBackgroundOption = -1, -1, CommentsBackgroundOption)
	CurrentLineForeground = IIf(CurrentLineForegroundOption = -1, -1, CurrentLineForegroundOption)
	CurrentLineBackground = IIf(CurrentLineBackgroundOption = -1, clBtnFace, CurrentLineBackgroundOption)
	ExecutionLineForeground = IIf(ExecutionLineForegroundOption = -1, clBlack, ExecutionLineForegroundOption)
	ExecutionLineBackground = IIf(ExecutionLineBackgroundOption = -1, clYellow, ExecutionLineBackgroundOption)
	ExecutionLineIndicator = IIf(ExecutionLineIndicatorOption = -1, clYellow, ExecutionLineIndicatorOption)
	FoldLinesForeground = IIf(FoldLinesForegroundOption = -1, clBtnShadow, FoldLinesForegroundOption)
	IndicatorLinesForeground = IIf(IndicatorLinesForegroundOption = -1, clBlack, IndicatorLinesForegroundOption)
	KeywordsForeground = IIf(KeywordsForegroundOption = -1, clBlue, KeywordsForegroundOption)
	KeywordsBackground = IIf(KeywordsBackgroundOption = -1, -1, KeywordsBackgroundOption)
	LineNumbersForeground = IIf(LineNumbersForegroundOption = -1, clBlack, LineNumbersForegroundOption)
	LineNumbersBackground = IIf(LineNumbersBackgroundOption = -1, clBtnFace, LineNumbersBackgroundOption)
	NormalTextForeground = IIf(NormalTextForegroundOption = -1, clBlack, NormalTextForegroundOption)
	NormalTextBackground = IIf(NormalTextBackgroundOption = -1, clWhite, NormalTextBackgroundOption)
	PreprocessorsForeground = IIf(PreprocessorsForegroundOption = -1, clPurple, PreprocessorsForegroundOption)
	PreprocessorsBackground = IIf(PreprocessorsBackgroundOption = -1, -1, PreprocessorsBackgroundOption)
	SelectionForeground = IIf(SelectionForegroundOption = -1, clHighlightText, SelectionForegroundOption)
	SelectionBackground = IIf(SelectionBackgroundOption = -1, clHighlight, SelectionBackgroundOption)
	SpaceIdentifiersForeground = IIf(SpaceIdentifiersForegroundOption = -1, clLtGray, SpaceIdentifiersForegroundOption)
	StringsForeground = IIf(StringsForegroundOption = -1, clMaroon, StringsForegroundOption)
	StringsBackground = IIf(StringsBackgroundOption = -1, -1, StringsBackgroundOption)
End Sub

Sub frmMain_Create(ByRef Sender As Control)
	#ifdef __USE_GTK__
		'gtk_window_set_icon_name(GTK_WINDOW(frmMain.widget), "VisualFBEditor1")
		'gtk_window_set_icon_name(GTK_WINDOW(frmMain.widget), ToUTF8("VisualFBEditor4"))
	#endif
	
	tabLeftWidth = iniSettings.ReadInteger("MainWindow", "LeftWidth", tabLeftWidth)
	SetLeftClosedStyle iniSettings.ReadBool("MainWindow", "LeftClosed", True)
	tabRightWidth = iniSettings.ReadInteger("MainWindow", "RightWidth", tabRightWidth)
	SetRightClosedStyle iniSettings.ReadBool("MainWindow", "RightClosed", True)
	tabBottomHeight = iniSettings.ReadInteger("MainWindow", "BottomHeight", tabBottomHeight)
	SetBottomClosedStyle iniSettings.ReadBool("MainWindow", "BottomClosed", True)
	tbExplorer.Buttons.Item(3)->Checked = iniSettings.ReadBool("MainWindow", "ProjectFolders", True)
	tbForm.Buttons.Item(0)->Checked = iniSettings.ReadBool("MainWindow", "ToolLabels", True)
	ChangeUseDebugger iniSettings.ReadBool("MainWindow", "UseDebugger", True)
	Var bGUI = iniSettings.ReadBool("MainWindow", "CompileGUI", True)
	tbStandard.Buttons.Item("Form")->Checked = bGUI
	tbStandard.Buttons.Item("Console")->Checked = Not bGUI
	Dim As WString Ptr tempStr
	For i As Integer = 0 To 9
		WLet tempStr, iniSettings.ReadString("Compilers", "Version_" & WStr(i), "")
		If *tempStr <> "" Then
			Compilers.Add *tempStr, iniSettings.ReadString("Compilers", "Path_" & WStr(i), "")
		End If
		WLet tempStr, iniSettings.ReadString("MakeTools", "Version_" & WStr(i), "")
		If *tempStr <> "" Then
			MakeTools.Add *tempStr, iniSettings.ReadString("MakeTools", "Path_" & WStr(i), "")
		End If
		WLet tempStr, iniSettings.ReadString("Debuggers", "Version_" & WStr(i), "")
		If *tempStr <> "" Then
			Debuggers.Add *tempStr, iniSettings.ReadString("Debuggers", "Path_" & WStr(i), "")
		End If
		WLet tempStr, iniSettings.ReadString("Terminals", "Version_" & WStr(i), "")
		If *tempStr <> "" Then
			Terminals.Add *tempStr, iniSettings.ReadString("Terminals", "Path_" & WStr(i), "")
		End If
	Next
	WDeallocate tempStr
	WLet CurrentCompiler32, ""
	WLet CurrentCompiler64, ""
	WLet CurrentMakeTool1, ""
	WLet CurrentMakeTool2, ""
	WLet CurrentTerminal, ""
	WLet CurrentDebugger, ""
	WLet DefaultCompiler32, iniSettings.ReadString("Compilers", "DefaultCompiler32", "")
	WLet DefaultCompiler64, iniSettings.ReadString("Compilers", "DefaultCompiler64", "")
	WLet Compiler32Path, Compilers.Get(*DefaultCompiler32, "fbc")
	WLet Compiler64Path, Compilers.Get(*DefaultCompiler64, "fbc")
	WLet DefaultMakeTool, iniSettings.ReadString("MakeTools", "DefaultMakeTool", "make")
	WLet MakeToolPath, MakeTools.Get(*DefaultMakeTool, "make")
	WLet DefaultDebugger, iniSettings.ReadString("Debuggers", "DefaultDebugger", "")
	WLet DebuggerPath, Debuggers.Get(*DefaultDebugger, "")
	WLet DefaultTerminal, iniSettings.ReadString("Terminals", "DefaultTerminal", "")
	WLet TerminalPath, Terminals.Get(*DefaultTerminal, "")
	UseMakeOnStartWithCompile = iniSettings.ReadBool("Options", "UseMakeOnStartWithCompile", False)
	WLet HelpPath, iniSettings.ReadString("Options", "HelpPath", "")
	WLet ProjectsPath, iniSettings.ReadString("Options", "ProjectsPath", "./Projects")
	GridSize = iniSettings.ReadInteger("Options", "GridSize", 10)
	ShowAlignmentGrid = iniSettings.ReadBool("Options", "ShowAlignmentGrid", True)
	SnapToGridOption = iniSettings.ReadBool("Options", "SnapToGrid", True)
	AutoIncrement = iniSettings.ReadBool("Options", "AutoIncrement", True)
	AutoCreateRC = iniSettings.ReadBool("Options", "AutoCreateRC", True)
	AutoSaveCompile = iniSettings.ReadBool("Options", "AutoSaveCompile", True)
	AutoComplete = iniSettings.ReadBool("Options", "AutoComplete", True)
	AutoIndentation = iniSettings.ReadBool("Options", "AutoIndentation", True)
	ShowSpaces = iniSettings.ReadBool("Options", "ShowSpaces", True)
	TabAsSpaces = iniSettings.ReadBool("Options", "TabAsSpaces", True)
	ChoosedTabStyle = iniSettings.ReadInteger("Options", "ChoosedTabStyle", 1)
	TabWidth = iniSettings.ReadInteger("Options", "TabWidth", 4)
	HistoryLimit = iniSettings.ReadInteger("Options", "HistoryLimit", 20)
	ChangeKeyWordsCase = iniSettings.ReadBool("Options", "ChangeKeyWordsCase", True)
	ChoosedKeyWordsCase = iniSettings.ReadInteger("Options", "ChoosedKeyWordsCase", 0)
	WLet CurrentTheme, iniSettings.ReadString("Options", "CurrentTheme", "Default Theme")
	WLet EditorFontName, iniSettings.ReadString("Options", "EditorFontName", "Courier New")
	EditorFontSize = iniSettings.ReadInteger("Options", "EditorFontSize", 10)
	
	WLet Compiler32Arguments, iniSettings.ReadString("Parameters", "Compiler32Arguments", "-exx")
	WLet Compiler64Arguments, iniSettings.ReadString("Parameters", "Compiler64Arguments", "-exx")
	WLet Make1Arguments, iniSettings.ReadString("Parameters", "Make1Arguments", "")
	WLet Make2Arguments, iniSettings.ReadString("Parameters", "Make2Arguments", "clean")
	WLet RunArguments, iniSettings.ReadString("Parameters", "RunArguments", "")
	
	iniTheme.Load ExePath & "/Settings/Themes/" & *CurrentTheme & ".ini"
	BookmarksForegroundOption = iniTheme.ReadInteger("Colors", "BookmarksForeground", -1)
	BookmarksBackgroundOption = iniTheme.ReadInteger("Colors", "BookmarksBackground", -1)
	BookmarksIndicatorOption = iniTheme.ReadInteger("Colors", "BookmarksIndicator", -1)
	BookmarksBold = iniTheme.ReadInteger("FontStyles", "BookmarksBold", 0)
	BookmarksItalic = iniTheme.ReadInteger("FontStyles", "BookmarksItalic", 0)
	BookmarksUnderline = iniTheme.ReadInteger("FontStyles", "BookmarksUnderline", 0)
	BreakpointsForegroundOption = iniTheme.ReadInteger("Colors", "BreakpointsForeground", -1)
	BreakpointsBackgroundOption = iniTheme.ReadInteger("Colors", "BreakpointsBackground", -1)
	BreakpointsIndicatorOption = iniTheme.ReadInteger("Colors", "BreakpointsIndicator", -1)
	BreakpointsBold = iniTheme.ReadInteger("FontStyles", "BreakpointsBold", 0)
	BreakpointsItalic = iniTheme.ReadInteger("FontStyles", "BreakpointsItalic", 0)
	BreakpointsUnderline = iniTheme.ReadInteger("FontStyles", "BreakpointsUnderline", 0)
	CommentsForegroundOption = iniTheme.ReadInteger("Colors", "CommentsForeground", -1)
	CommentsBackgroundOption = iniTheme.ReadInteger("Colors", "CommentsBackground", -1)
	CommentsBold = iniTheme.ReadInteger("FontStyles", "CommentsBold", 0)
	CommentsItalic = iniTheme.ReadInteger("FontStyles", "CommentsItalic", 0)
	CommentsUnderline = iniTheme.ReadInteger("FontStyles", "CommentsUnderline", 0)
	CurrentLineForegroundOption = iniTheme.ReadInteger("Colors", "CurrentLineForeground", -1)
	CurrentLineBackgroundOption = iniTheme.ReadInteger("Colors", "CurrentLineBackground", -1)
	ExecutionLineForegroundOption = iniTheme.ReadInteger("Colors", "ExecutionLineForeground", -1)
	ExecutionLineBackgroundOption = iniTheme.ReadInteger("Colors", "ExecutionLineBackground", -1)
	ExecutionLineIndicatorOption = iniTheme.ReadInteger("Colors", "ExecutionLineIndicator", -1)
	FoldLinesForegroundOption = iniTheme.ReadInteger("Colors", "FoldLinesForeground", -1)
	IndicatorLinesForegroundOption = iniTheme.ReadInteger("Colors", "IndicatorLinesForeground", -1)
	KeywordsForegroundOption = iniTheme.ReadInteger("Colors", "KeywordsForeground", -1)
	KeywordsBackgroundOption = iniTheme.ReadInteger("Colors", "KeywordsBackground", -1)
	KeywordsBold = iniTheme.ReadInteger("FontStyles", "KeywordsBold", 0)
	KeywordsItalic = iniTheme.ReadInteger("FontStyles", "KeywordsItalic", 0)
	KeywordsUnderline = iniTheme.ReadInteger("FontStyles", "KeywordsUnderline", 0)
	LineNumbersForegroundOption = iniTheme.ReadInteger("Colors", "LineNumbersForeground", -1)
	LineNumbersBackgroundOption = iniTheme.ReadInteger("Colors", "LineNumbersBackground", -1)
	LineNumbersBold = iniTheme.ReadInteger("FontStyles", "LineNumbersBold", 0)
	LineNumbersItalic = iniTheme.ReadInteger("FontStyles", "LineNumbersItalic", 0)
	LineNumbersUnderline = iniTheme.ReadInteger("FontStyles", "LineNumbersUnderline", 0)
	NormalTextForegroundOption = iniTheme.ReadInteger("Colors", "NormalTextForeground", -1)
	NormalTextBackgroundOption = iniTheme.ReadInteger("Colors", "NormalTextBackground", -1)
	NormalTextBold = iniTheme.ReadInteger("FontStyles", "NormalTextBold", 0)
	NormalTextItalic = iniTheme.ReadInteger("FontStyles", "NormalTextItalic", 0)
	NormalTextUnderline = iniTheme.ReadInteger("FontStyles", "NormalTextUnderline", 0)
	PreprocessorsForegroundOption = iniTheme.ReadInteger("Colors", "PreprocessorsForeground", -1)
	PreprocessorsBackgroundOption = iniTheme.ReadInteger("Colors", "PreprocessorsBackground", -1)
	PreprocessorsBold = iniTheme.ReadInteger("FontStyles", "PreprocessorsBold", 0)
	PreprocessorsItalic = iniTheme.ReadInteger("FontStyles", "PreprocessorsItalic", 0)
	PreprocessorsUnderline = iniTheme.ReadInteger("FontStyles", "PreprocessorsUnderline", 0)
	SelectionForegroundOption = iniTheme.ReadInteger("Colors", "SelectionForeground", -1)
	SelectionBackgroundOption = iniTheme.ReadInteger("Colors", "SelectionBackground", -1)
	SpaceIdentifiersForegroundOption = iniTheme.ReadInteger("Colors", "SpaceIdentifiersForeground", -1)
	StringsForegroundOption = iniTheme.ReadInteger("Colors", "StringsForeground", -1)
	StringsBackgroundOption = iniTheme.ReadInteger("Colors", "StringsBackground", -1)
	StringsBold = iniTheme.ReadInteger("FontStyles", "StringsBold", 0)
	StringsItalic = iniTheme.ReadInteger("FontStyles", "StringsItalic", 0)
	StringsUnderline = iniTheme.ReadInteger("FontStyles", "StringsUnderline", 0)
	SetAutoColors
	
	Var file = Command(-1)
	If file = "" Then
		'AddTab ExePath & "/Templates/Form.bas", True
	Else
		OpenFiles file
	End If
	#ifndef __USE_GTK__
		windmain = frmMain.Handle
		htab2    = ptabCode->Handle
		tviewVar = tvVar.Handle
		tviewPrc = tvPrc.Handle
		tviewThd = tvThd.Handle
		tviewWch = tvWch.Handle
		DragAcceptFiles(frmMain.Handle, True)
	#endif
	LoadAddins
End Sub

Sub frmMain_Close(ByRef Sender As Form, ByRef Action As Integer)
	On Error Goto ErrorHandler
	Dim tb As TabWindow Ptr
	For i As Integer = 0 To ptabCode->TabCount - 1
		tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
		If CInt(tb) AndAlso CInt(Not tb->CloseTab) Then Action = 0: Return
	Next i
	For i As Integer = tvExplorer.Nodes.Count - 1 To 0 Step -1
		If tvExplorer.Nodes.Item(i)->ImageKey = "Project" Then
			If Not CloseProject(tvExplorer.Nodes.Item(i)) Then Action = 0: Return
		End If
	Next i
	iniSettings.WriteBool("MainWindow", "LeftClosed", GetLeftClosedStyle)    
	iniSettings.WriteInteger("MainWindow", "LeftWidth", tabLeftWidth)
	iniSettings.WriteBool("MainWindow", "RightClosed", GetRightClosedStyle)
	iniSettings.WriteInteger("MainWindow", "RightWidth", tabRightWidth)
	iniSettings.WriteBool("MainWindow", "BottomClosed", GetBottomClosedStyle)
	iniSettings.WriteInteger("MainWindow", "BottomHeight", tabBottomHeight)
	iniSettings.WriteBool("MainWindow", "ProjectFolders", tbExplorer.Buttons.Item(3)->Checked)
	iniSettings.WriteBool("MainWindow", "ToolLabels", tbForm.Buttons.Item(0)->Checked)
	iniSettings.WriteBool("MainWindow", "UseDebugger", UseDebugger)
	iniSettings.WriteBool("MainWindow", "CompileGUI", tbStandard.Buttons.Item("Form")->Checked)
	
	For i As Integer = 0 To Min(9, MRUFiles.Count - 1) 'David change
		iniSettings.WriteString("MRUFiles", "MRUFile_0" & WStr(i), MRUFiles.Item(i))
	Next
	For i As Integer = 0 To Min(9, MRUProjects.Count - 1)
		iniSettings.WriteString("MRUProjects", "MRUProject_0" & WStr(i), MRUProjects.Item(i))
	Next
	
	UnLoadAddins
	Exit Sub
	ErrorHandler:
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " " & _
	"in function " & ZGet(Erfn()) & " " & _
	"in module " & ZGet(Ermn())
End Sub

#ifdef __USE_GTK__
	frmMain.Icon.LoadFromFile(ExePath & "/Resources/VisualFBEditor.ico")
#else
	frmMain.Icon.LoadFromResourceID(1)
#endif
frmMain.StartPosition = FormStartPosition.DefaultBounds
frmMain.MainForm = True
#ifdef __FB_64BIT__
	frmMain.Text = "Visual FB Editor (x64)"
#else
	frmMain.Text = "Visual FB Editor (x32)"
#endif
frmMain.OnActiveControlChange = @frmMain_ActiveControlChanged
frmMain.OnResize = @frmMain_Resize
frmMain.OnCreate = @frmMain_Create
frmMain.OnClose = @frmMain_Close
frmMain.OnDropFile = @frmMain_DropFile
frmMain.Menu = @mnuMain
frmMain.Add @tbStandard
frmMain.Add @stBar
frmMain.Add @pnlLeft
frmMain.Add @splLeft
frmMain.Add @pnlRight
frmMain.Add @splRight
frmMain.Add @pnlBottom
frmMain.Add @splBottom
frmMain.Add ptabCode

frmMain.CreateWnd
frmMain.Show

fSplash.CloseForm

pApp->MainForm = @frmMain
pApp->Run

Sub OnProgramStart() Constructor
	
End Sub

Sub OnProgramQuit() Destructor
	WDeallocate sTemp
	WDeallocate sTemp2
	WDeallocate HelpPath
	WDeallocate ProjectsPath
	WDeallocate DefaultMakeTool
	WDeallocate CurrentMakeTool1
	WDeallocate CurrentMakeTool2
	WDeallocate MakeToolPath
	WDeallocate DefaultDebugger
	WDeallocate CurrentDebugger
	WDeallocate DebuggerPath
	WDeallocate DefaultTerminal
	WDeallocate CurrentTerminal
	WDeallocate TerminalPath
	WDeallocate DefaultCompiler32
	WDeallocate CurrentCompiler32
	WDeallocate DefaultCompiler64
	WDeallocate CurrentCompiler64
	WDeallocate Compiler32Path
	WDeallocate Compiler64Path
	WDeallocate Compiler32Arguments
	WDeallocate Compiler64Arguments
	WDeallocate Make1Arguments
	WDeallocate Make2Arguments
	WDeallocate RunArguments
	WDeallocate DebugArguments
'	For i As Integer = 0 To Comps.Count - 1
'		#ifndef __USE_GTK__
'			Delete Cast(ToolBoxItem Ptr, Comps.Object(i))
'		#endif
'	Next
'	Comps.Clear
End Sub

End
AA:
MsgBox ErrDescription(Err) & " (" & Err & ") " & _
"in function " & ZGet(Erfn()) & " " & _
"in module " & ZGet(Ermn()) ' & " " & _
'"in line " & Erl()
