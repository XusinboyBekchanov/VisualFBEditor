#IfDef __FB_Win32__
	#IfDef __FB_64bit__
	    '#Compile -s gui -x "../VisualFBEditor64.exe" "VisualFBEditor.rc" -exx
	#Else
	    '#Compile -w all -s console -x "../VisualFBEditor32.exe" "VisualFBEditor.rc" -exx
	#EndIf
#Else
	#IfDef __FB_64bit__
	    '#Compile -s gui -x "../VisualFBEditor64_gtk3" -exx
	#Else
	    '#Compile -s gui -x "../VisualFBEditor32_gtk3" -exx
	#EndIf
#EndIf
'#Define __USE_GTK3__

On Error Goto AA
#Define GetMN
Declare Sub m(ByRef msg As WString)
Declare Function ML(ByRef msg As WString) ByRef As WString

Dim Shared MFFPath As WString Ptr
Dim Shared MFFDll As WString Ptr

#Define _NOT_AUTORUN_FORMS_

#Include Once "mff/Dialogs.bi"
#Include Once "mff/Form.bi"
#Include Once "mff/TextBox.bi"
#Include Once "mff/RichTextBox.bi"
#Include Once "mff/TabControl.bi"
#Include Once "mff/StatusBar.bi"
#Include Once "mff/Splitter.bi"
#Include Once "mff/ToolBar.bi"
#Include Once "mff/ListControl.bi"
#Include Once "mff/CheckBox.bi"
#Include Once "mff/ComboBoxEdit.bi"
#Include Once "mff/ComboBoxEx.bi"
#Include Once "mff/RadioButton.bi"
#Include Once "mff/ProgressBar.bi"
#Include Once "mff/ScrollBarControl.bi"
#Include Once "mff/Label.bi"
#Include Once "mff/Panel.bi"
#Include Once "mff/TrackBar.bi"
#Include Once "mff/UpDown.bi"
#Include Once "mff/Animate.bi"
#Include Once "mff/Clipboard.bi"
#Include Once "mff/TreeView.bi"
#Include Once "mff/ListView.bi"
#Include Once "mff/IniFile.bi"

Declare Sub PopupClick(ByRef Sender As My.Sys.Object)
Declare Sub mClick(Sender As My.Sys.Object)
Dim Shared As WString Ptr Compilator32, Compilator64, Debugger, Terminal

Using My.Sys.Forms
Using My.Sys.Drawing

Declare Sub LoadLanguageTexts
Dim Shared As String CurLanguage
Dim Shared As iniFile iniSettings
Dim Shared As WString Ptr HelpPath
Dim Shared As Boolean AutoIncrement
Dim Shared As Boolean AutoIndentation
Dim Shared As Boolean AutoComplete
Dim Shared As Boolean AutoCreateRC
Dim Shared As Boolean AutoSaveCompile
Dim Shared As Boolean ShowSpaces
Dim Shared As Integer TabWidth
Dim Shared As Integer HistoryLimit
Dim Shared As Integer TabAsSpaces
Dim Shared As TreeNode Ptr MainNode

Dim Shared As Form frmMain

'#Include Once "mff/LinkLabel.bi"

#Include Once "frmSplash.bas"

Dim Shared As frmSplash fSplash
#IfDef __USE_GTK__
	fSplash.Icon.LoadFromFile(exepath & "/resources/VisualFBEditor.ico")
#EndIf
fSplash.Show
Dim Shared As StatusBar stBar
Dim Shared As Splitter splLeft, splRight, splBottom, splProperties, splEvents
Dim Shared As ListControl lstLeft
Dim Shared As CheckBox chkLeft
Dim Shared As RadioButton radButton
Dim Shared As ProgressBar prLeft
Dim Shared As ScrollBarControl scrLeft
Dim Shared As Label lblLeft
Dim Shared As Panel pnlLeft, pnlRight, pnlBottom, pnlPropertyValue
Dim Shared As Trackbar trLeft
Dim Shared As TextBox txtCommands, txtPropertyValue, txtLabelProperty, txtLabelEvent
Dim Shared As UpDown udLeft
Dim Shared As ScrollBarControl scrTool
Dim Shared As MainMenu mnuMain
Dim Shared As ComboBoxEdit cboPropertyValue
Dim Shared As SaveFileDialog SaveD

#Include Once "file.bi"
#Include Once "Designer.bi"
#Include Once "TabWindow.bas"
#Include Once "Debug.bas"
#Include Once "frmFind.bas"
#Include Once "frmReplace.bas"
#Include Once "frmGoto.bas"
#Include Once "frmFindInFiles.bas"
#Include Once "frmAbout.bas"
#Include Once "frmOptions.bas"

Dim Shared As frmFind fFind
Dim Shared As frmReplace fReplace
Dim Shared As frmGoto fGoto
Dim Shared As frmAbout fAbout

Sub tabCode_Paint(ByRef Sender As Control) '...'
    MoveCloseButtons
End Sub

Sub SelectError(ByRef FileName As WString, iLine As Integer, tabw As TabWindow Ptr = 0)
    Dim tb As TabWindow Ptr
    If tabw <> 0 AndAlso tabCode.IndexOfTab(tabw) <> -1 Then
        tb = tabw
        tb->SelectTab
    Else
        If FileName = "" Then Exit Sub
        tb = AddTab(FileName)
    End If
    tb->txtCode.SetSelection iLine - 1, iLine - 1, 0, tb->txtCode.LineLength(iLine - 1)
End Sub

Sub SelectSearchResult(ByRef FileName As WString, iLine As Integer, iSelStart As Integer, iSelLength As Integer, tabw As TabWindow Ptr = 0)
    Dim tb As TabWindow Ptr
    If tabw <> 0 AndAlso tabCode.IndexOfTab(tabw) <> -1 Then
        tb = tabw
        tb->SelectTab
    Else
        If FileName = "" Then Exit Sub
        tb = AddTab(FileName)
    End If
    tb->txtCode.SetSelection iLine - 1, iLine - 1, iSelStart - 1, iSelStart + iSelLength - 1
End Sub

Sub txtOutput_DblClick(ByRef Sender As Control) '...'
    Dim Buff As WString Ptr = @txtOutput.Lines(txtOutput.GetLineFromCharIndex)
    Dim As WString Ptr FileName, ErrTitle
    Dim As Integer iLine
    SplitError(*Buff, FileName, ErrTitle, iLine)
    SelectError(*FileName, iLine)
End Sub

Function GetTreeNodeChild(tn As TreeNode Ptr, ByRef FileName As WString) As TreeNode Ptr
    If tbExplorer.Buttons.Item(3)->Checked Then
        If EndsWith(FileName, ".bi") Then
            Return tn->Nodes.Item(0) 
        ElseIf EndsWith(FileName, ".bas") Then
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

Dim Shared As ExplorerElement Ptr ee, pee
Dim Shared As TreeNode Ptr tn, tn3
Function AddProject(ByRef FileName As WString = "") As TreeNode Ptr
    If FileName <> "" Then
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
        pee = New ExplorerElement
        WLet pee->FileName, FileName
        tn->Tag = pee
        Open FileName For Input Encoding "utf-8" As #1
        WReallocate buff, LOF(1)
        Do Until EOF(1)
            Line Input #1, *buff
            If StartsWith(*buff, "File=") OrElse StartsWith(*buff, "*File=") Then
                Pos1 = Instr(*buff, "=")
                If Pos1 <> 0 Then
                	bMain = StartsWith(*buff, "*")
                    *buff = Mid(*buff, Pos1 + 1)
                    ee = New ExplorerElement
                    If Instr(*buff, ":") OrElse CInt(StartsWith(*buff, "/")) Then
                        WLet ee->FileName, *buff
                    Else
                    	WLet ee->FileName, GetFolderName(FileName) & *buff
                    End If
                    tn1 = GetTreeNodeChild(tn, *buff)
                    tn2 = tn1->Nodes.Add(GetFileName(*ee->FileName), , *ee->FileName, "File", "File", True)
                    tn2->Tag = ee
                    tn1->Expand
                    If bMain Then
                        WLet pee->MainFileName, *ee->FileName
                    End If
                End If
            End If
        Loop
        Close #1
    End If
    tn->Expand
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
	        Line Input #3, *buff
	        If StartsWith(*buff, "File=") OrElse StartsWith(*buff, "*File=") Then
	            Pos1 = Instr(*buff, "=")
	            If Pos1 <> 0 Then
    				bMain = StartsWith(*buff, "*")
	                WLet filn, Mid(*buff, Pos1 + 1)
						If CInt(InStr(*filn, ":") = 0) AndAlso CInt(Not StartsWith(*filn, "/")) Then
							WLet filn, GetFolderName(FileName) & *filn
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
    If Not OpenD.Execute Then Exit Sub
    AddSession OpenD.FileName
	TabLeft.Tabs[0]->SelectTab
End Sub

Sub OpenProgram()
	Dim As OpenFileDialog OpenD
    OpenD.Filter = ML("FreeBasic Files") & " (*.vfs, *.vfp, *.bas, *.bi, *.rc)|*.vfs;*.vfp;*.bas;*.bi;*.rc|" & ML("VisualFBEditor Session") & " (*.vfs)|" & ML("VisualFBEditor Project") & " (*.vfp)|*.vfp|" & ML("FreeBasic Module") & " (*.bas)|*.bas|" & ML("FreeBasic Include File") & " (*.bi)|*.bi|" & ML("FreeBasic Resource Files") & " (*.rc)|*.rc|" & ML("All Files") & "|*.*|"
    If OpenD.Execute Then
        If EndsWith(OpenD.Filename, ".vfs") Then
            AddSession OpenD.Filename
        ElseIf EndsWith(OpenD.Filename, ".vfp") Then
        	AddProject OpenD.Filename
        Else
            AddTab OpenD.Filename
        End If
    End If
    TabLeft.Tabs[0]->SelectTab
End Sub

Function SaveSession() As Boolean
    SaveD.Filter = ML("VisualFBEditor Session") & " (*.vfs)|*.vfs|"
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
	        Zv = IIF(tn1 = MainNode, "*", "")
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

Function SaveProject(tn As TreeNode Ptr, bWithQuestion As Boolean = False) As Boolean
    If tn = 0 Then Return True
    If tn->ImageKey <> "Project" Then Return True
    pee = tn->Tag
    If pee = 0 OrElse WGet(pee->FileName) = "" Then
        SaveD.FileName = Left(tn->Text, Len(tn->Text) - IIF(EndsWith(tn->Text, " *"), 2, 0))
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
    End If
    Dim As TreeNode Ptr tn1, tn2
    Dim As String Zv = "*"
    Open *pee->FileName For Output Encoding "utf-8" As #1
    For i As Integer = 0 To tn->Nodes.Count - 1
        tn1 = tn->Nodes.Item(i)
        ee = tn1->Tag
        If ee <> 0 Then
            Zv = IIF(*ee->FileName = *pee->MainFileName, "*", "")
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
                    Zv = IIF(*ee->FileName = *pee->MainFileName, "*", "")
                    If StartsWith(*ee->FileName, GetFolderName(*pee->FileName)) Then
                        Print #1, Zv & "File=" & Replace(Mid(*ee->FileName, Len(GetFolderName(*pee->FileName)) + 1), "\", "/")
                    Else
                        Print #1, Zv & "File=" & *ee->FileName
                    End If
                End If
            Next
        End If
    Next
    Close #1
    tn->Text = GetFileName(*pee->FileName)
    tn->Tag = pee
    Return True
End Function

Sub SaveAll()
    Dim tb As TabWindow Ptr
    For i As Long = 0 To tabCode.TabCount - 1
        tb = Cast(TabWindow Ptr, tabCode.Tabs[i])
        tb->Save
    Next i
    For i As Long = 0 To tvExplorer.Nodes.Count - 1
        If tvExplorer.Nodes.Item(i)->ImageKey = "Project" Then
            SaveProject tvExplorer.Nodes.Item(i)
        End If
    Next i
End Sub

Sub CloseAllTabs()
    Dim tb As TabWindow Ptr
    For i As Long = 0 To tabCode.TabCount - 1
        tb = Cast(TabWindow Ptr, tabCode.Tabs[i])
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
        ShowMessages ML("File") & " " & *HelpPath & " " & ML("not found")
    Else
        Var tb = Cast(TabWindow Ptr, tabCode.SelectedTab)
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
    For i As Integer = 0 To tabCode.TabCount - 1
        tb = Cast(TabWindow Ptr, tabCode.Tabs[i])
        If tb->tn = tn Then
            If tb->CloseTab = False Then Exit Sub
            Exit For
        End If
    Next i
    If Not EndsWith(tn->ParentNode->Text, " *") Then tn->ParentNode->Text &= " *"
    If tn->ParentNode->Nodes.IndexOf(tn) <> -1 Then tn->ParentNode->Nodes.Remove tn->ParentNode->Nodes.IndexOf(tn)
End Sub

Sub SetAsMain()
	Dim As TreeNode Ptr tn = tvExplorer.SelectedNode
    If tn->ParentNode = 0 Then
    	MainNode = tn
    	lblLeft.Text = ML("Main File") & ": " & MainNode->Text
    Else
    	Dim As ExplorerElement Ptr ee = tn->Tag
    	Dim As TreeNode Ptr ptn = GetParentNode(tn)
    	If ptn <> 0 Then
        	Dim As ExplorerElement Ptr pee = ptn->Tag
				If pee = 0 Then
					pee = New ExplorerElement
	        		WLet pee->FileName, ""
				End If
        	If ee <> 0 AndAlso pee <> 0 Then
            	WLet pee->MainFileName, *ee->FileName
            	If Not EndsWith(ptn->Text, " *") Then ptn->Text &= " *"
            	If ptn->Tag = 0 Then ptn->Tag = pee
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
			For i As Integer = 0 To tabCode.TabCount - 1
				tb = Cast(TabWindow Ptr, tabCode.Tabs[i])
				If tb->tn = tn Then
					tb->Save
					Exit For
				End If
            Next i
        End If
    Else
        Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, tabCode.SelectedTab)
        If tb = 0 Then Exit Sub
        tb->Save
    End If
End Sub

Function CloseProject(tn As TreeNode Ptr) As Boolean
    If tn = 0 Then Return True
    If tn->ImageKey <> "Project" Then Return True
    Dim tb As TabWindow Ptr
    For j As Integer = 0 To tn->Nodes.Count - 1
        For i As Integer = 0 To tabCode.TabCount - 1
            tb = Cast(TabWindow Ptr, tabCode.Tab(i))
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

Sub NextBookmark(iTo As Integer = 1) '...'
    If tabCode.SelectedTab = 0 Then Exit Sub
    Dim As Integer i, j, k, n, iStart, iEnd, iStartLine, iEndLine
    Dim As EditControl Ptr txt
    Dim As EditControlLine Ptr FECLine
    Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
    Dim As Integer CurTabIndex = tabCode.SelectedTab->Index
    If iTo = 1 Then
        iStart = 0
        iEnd = tabCode.TabCount - 1
    Else
        iStart = tabCode.TabCount - 1
        iEnd = 0
    End If
    For k = 1 To 2    
        For j = IIF(k = 1, CurTabIndex, iStart) To IIF(k = 1, iEnd, CurTabIndex) Step iTo
            txt = @Cast(TabWindow Ptr, tabCode.Tabs[j])->txtCode
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
                    tabCode.Tabs[j]->SelectTab
                    txt->SetSelection i, i, 0, 0
                    Exit Sub
                End If
            Next
        Next j
    Next k
End Sub

Sub ClearAllBookmarks
    For i As Integer = 0 To tabCode.TabCount -1
        Cast(TabWindow Ptr, tabCode.Tabs[i])->txtCode.ClearAllBookmarks
    Next
End Sub

#IfNDef __USE_GTK__
	Sub TimerProc(hwnd As HWND, uMsg AS UINT, idEvent AS UINT_PTR, dwTime AS DWORD)
		If FnTab < 0 Or Fcurlig < 1 Then Exit Sub
		If source(Fntab) = "" Then Exit Sub
		Var tb = AddTab(LCase(source(Fntab)))
		If tb = 0 Then Exit Sub
		tb->txtCode.CurExecutedLine = Fcurlig - 1
		tb->txtCode.SetSelection Fcurlig - 1, Fcurlig - 1, 0, 0
		tb->txtCode.PaintControl
		CurEC = @tb->txtCode
		SetForegroundWindow frmMain.Handle
		FnTab = 0
		Fcurlig = -1
	End Sub
#EndIf

Sub ChangeTabsTn(TnPrev As TreeNode Ptr, Tn As TreeNode Ptr)
    Dim tb As TabWindow Ptr
    For i As Integer = 0 To tabCode.TabCount - 1
        tb = Cast(TabWindow Ptr, tabCode.Tabs[i])
        If tb->tn = TnPrev Then
            tb->tn = Tn
            If tabCode.SelectedTab = tabCode.Tabs[i] Then Tn->SelectItem
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
                    For k As Integer = tn->Nodes.Item(j)->Nodes.Count - 1 To 0 Step - 1
                        tn2 = tn->Nodes.Add(tn->Nodes.Item(j)->Nodes.Item(k)->Text, , , "File", "File", True)
                        tn2->Tag = tn->Nodes.Item(j)->Nodes.Item(k)->Tag
                        ChangeTabsTn tn->Nodes.Item(j)->Nodes.Item(k), tn2
                    Next k
                    tn->Nodes.Remove j
                End If
            Next
        End If
    Next
End Sub

Sub mClick(Sender As My.Sys.Object)
    Select Case Sender.ToString
    Case "NewProject":          NewProject
    Case "OpenProject":         OpenProject
    Case "OpenSession":         OpenSession
    Case "SaveProject":         SaveProject tvExplorer.SelectedNode
    Case "SaveSession":         SaveSession
    Case "CloseProject":        CloseProject GetParentNode(tvExplorer.SelectedNode)
    Case "New":                 AddTab
    Case "Open":                OpenProgram
    Case "Save":                Save
    Case "AddFileToProject":    AddFileToProject
    Case "RemoveFileFromProject": RemoveFileFromProject
    Case "SetAsMain": 			SetAsMain
    Case "Folder":              WithFolder
    Case "SyntaxCheck" :    Compile("Check")
    Case "Compile" :        Compile
    Case "Run":             
		#IfDef __USE_GTK__
			RunProgram(0)
		#Else
			ThreadCreate(@RunProgram)
		#EndIf
    Case "CompileAndRun":   If Compile Then ThreadCreate(@RunProgram)
    Case "Start":
        If InDebug Then
			#IfNDef __USE_GTK__
				fastrun()
			#EndIf
        Else
			#IfDef __USE_GTK__
				If Compile("-g") Then RunWithDebug(0)
			#Else
				runtype = RTFRUN
				If Compile("-g") Then SetTimer(0, 0, 1, @TimerProc): ThreadCreate(@RunWithDebug): KillTimer 0, 0
			#EndIf
        End If
    Case "Pause":           'If tb->Compile("-g") Then ThreadCreate(@RunWithDebug)
    Case "Stop":  
		#IfNDef __USE_GTK__
			For i As Integer = 1 To linenb 'restore old instructions
				WriteProcessMemory(dbghand, Cast(LPVOID, rline(i).ad), @rLine(i).sv, 1, 0)
			Next
			runtype = RTFREE
			'but_enable()
			DeleteDebugCursor
			thread_rsm()     
		#EndIf   
    Case "SaveAs", "Close", "SyntaxCheck", "Compile", "CompileAndRun", "Run", "RunToCursor", _
         "Start", "Stop", "StepInto", "Find", "Replace", "FindNext", "Goto", "SetNextStatement", _
         "AddWatch", "ShowVar", "NextBookmark", "PreviousBookmark", "ClearAllBookmarks"
        Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, tabCode.SelectedTab)
        If tb = 0 Then Exit Sub
        Select Case Sender.ToString
        Case "Save":            tb->Save
        Case "SaveAs":          tb->SaveAs
        Case "Close":           tb->CloseTab
        #IfNDef __USE_GTK__
			Case "SetNextStatement": exe_mod()
			Case "ShowVar":         var_tip(1)
			Case "StepInto":        
				If InDebug Then
					stopcode=0
					'bcktrk_close
					SetFocus(windmain)
					thread_rsm
				Else
					runtype = RTSTEP
					If Compile("-g") Then SetTimer(0, 0, 1, @TimerProc): ThreadCreate(@RunWithDebug): KillTimer 0, 0
				End If
			Case "RunToCursor":     brk_set(9)
			Case "AddWatch":        var_tip(2)
        #EndIf
        Case "Find":            fFind.Show frmMain
        Case "Replace":         fReplace.Show frmMain
        Case "FindNext":        fFind.Find(True)
        Case "FindPrev":        fFind.Find(False)
        Case "Goto":            fGoto.Show frmMain
        Case "NextBookmark":    NextBookmark 1
        Case "PreviousBookmark": NextBookmark -1
        Case "ClearAllBookmarks": ClearAllBookmarks
        End Select
    Case "SaveAll":             SaveAll
    Case "CloseAll":            CloseAllTabs
    Case "Exit":                frmMain.CloseForm
    Case "FindInFiles":         fFindFile.Show frmMain
    Case "NewForm":             AddTab ExePath + "/templates/Form.bas", True
    #IfNDef __USE_GTK__
		Case "ShowString":          string_sh(tviewvar)
		Case "ShowExpandVariable":  shwexp_new(tviewvar)
    #EndIf
    Case "Undo", "Redo", "Cut", "Copy", "Paste", "SelectAll", "SingleComment", "BlockComment", "UnComment", _
        "Indent", "Outdent", "Format", "NumberOn", "NumberOff", "ProcedureNumberOn", "ProcedureNumberOff", "Breakpoint", "ToggleBookmark", "CollapseAll", _
        "UnCollapseAll", "CompleteWord", "OnErrorResumeNext", "OnErrorGoto", "OnErrorGotoResumeNext", "RemoveErrorHandling"
        If frmMain.ActiveControl = 0 Then Exit Sub
        If frmMain.ActiveControl->ClassName <> "EditControl" And frmMain.ActiveControl->ClassName <> "TextBox" Then Exit Sub
        If frmMain.ActiveControl->ClassName = "TextBox" Then
            Dim txt As TextBox Ptr = Cast(TextBox Ptr, frmMain.ActiveControl)
            Select Case Sender.ToString
            Case "Undo":            txt->Undo
            Case "Cut":             txt->CutToClipboard
            Case "Copy":            txt->CopyToClipboard
            Case "Paste":           txt->PasteFromClipboard
            Case "SelectAll":       txt->SelectAll
            End Select
        End If
        Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, tabCode.SelectedTab)
        If tb = 0 Then Exit Sub
        If tb->cboClass.ItemIndex > 0 Then
            Dim des As Designer Ptr = tb->Des
            If des = 0 Then Exit Sub
            Select Case Sender.ToString
            Case "Cut":             des->CutControl
            Case "Copy":            des->CopyControl
            Case "Paste":           des->PasteControl
            End Select
        ElseIf frmMain.ActiveControl->ClassName = "EditControl" Then
            Dim ec As EditControl Ptr = @tb->txtCode
            Select Case Sender.ToString
            Case "Redo":            ec->Redo
            Case "Undo":            ec->Undo
            Case "Cut":             ec->CutToClipboard
            Case "Copy":            ec->CopyToClipboard
            Case "Paste":           ec->PasteFromClipboard
            Case "SelectAll":       ec->SelectAll
            Case "SingleComment":   ec->CommentSingle
            Case "BlockComment":    ec->CommentBlock
            Case "UnComment":       ec->UnComment
            Case "Indent":          ec->Indent
            Case "Outdent":         ec->Outdent
            Case "Breakpoint":  ec->BreakPoint
            Case "CollapseAll":  ec->CollapseAll
            Case "UnCollapseAll":  ec->UnCollapseAll
            Case "CompleteWord":  CompleteWord    
            Case "ToggleBookmark":  ec->Bookmark
            Case "Define":          tb->Define
            Case "Format":          tb->FormatBlock
            Case "NumberOn":        		tb->NumberOn
            Case "NumberOff":               tb->NumberOff
            Case "ProcedureNumberOn":       tb->ProcedureNumberOn
            Case "ProcedureNumberOff":      tb->ProcedureNumberOff
            Case "OnErrorResumeNext":       tb->SetErrorHandling "On Error Resume Next", ""
            Case "OnErrorGoto":             tb->SetErrorHandling "On Error Goto ErrorHandler", ""
            Case "OnErrorGotoResumeNext":   tb->SetErrorHandling "On Error Goto ErrorHandler", "Resume Next"
            Case "RemoveErrorHandling":     tb->RemoveErrorHandling
            End Select
        End If
    Case "Options": fOptions.Show frmMain
    Case "Content":
    	#IfDef __USE_GTK__
    		RunHelp(0)
    	#Else
    		ThreadCreate(@RunHelp)
    	#EndIf
    Case "About": fAbout.Show frmMain
    End Select
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
        Select Case lCase(tbi->BaseName)
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

Sub tpShakl_Resize(ByRef Sender As Control)
    tbToolBox.Width = tpShakl->ClientWidth - IIF(scrTool.Visible, scrTool.Width, 0)
    scrTool.MaxValue = Max(0, tbToolBox.Height - (tpShakl->ClientHeight - tbForm.Height))
    scrTool.Visible = scrTool.MaxValue <> 0
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
    #IfNDef __USE_GTK__
		#IfDef __FB_64bit__
			WLet MFFDll, *MFFPath & "/mff64.dll"
		#Else
			WLet MFFDll, *MFFPath & "/mff32.dll"
		#EndIf
	#Else
		#IfDef __USE_GTK3__
			#IfDef __FB_64bit__
				WLet MFFDll, *MFFPath & "/libmff64_gtk3.so"
			#Else
				WLet MFFDll, *MFFPath & "/libmff32_gtk3.so"
			#EndIf
		#Else
			#IfDef __FB_64bit__
				WLet MFFDll, *MFFPath & "/libmff64_gtk2.so"
			#Else
				WLet MFFDll, *MFFPath & "/libmff32_gtk2.so"
			#EndIf
		#EndIf
	#EndIf
	MFF = DyLibLoad(*MFFDll)
    Dim As ToolBoxItem Ptr tbi
    #IfNDef __USE_GTK__
		cur = crArrow
    #EndIf
    Dim cl As Integer = clSilver
    #IfDef __USE_GTK__
		gtk_icon_theme_append_search_path(gtk_icon_theme_get_default(), *MFFPath & "/resources")
		tbToolBox.Align = 5
    #Else
		imgListTools.AddMasked "DropDown", cl, "DropDown"
		imgListTools.AddMasked "Kursor", cl, "Cursor"
    #EndIf
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
    f = dir(IncludePath & "*.bi")
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
                If CInt(StartsWith(Trim(lcase(*b)), "type ")) AndAlso CInt(InStr(lcase(*b), " as ") = 0) Then
                    Pos1 = Instr(" " & lcase(*b), " type ")
                    If Pos1 > 0 Then
                        Pos2 = Instr(lcase(*b), " extends ")
                        If Pos2 > 0 Then
                            t = Trim(Mid(*b, Pos1 + 5, Pos2 - Pos1 - 5))
                            e = Trim(Mid(*b, Pos2 + 9))
                            Var Pos4 = Instr(e, "'")
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
                        if Not Comps.Contains(t) Then
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
                            Var Pos3 = Instr(Trim(*b), "(")
                            Var n = Len(Trim(*b)) - Len(Trim(Mid(Trim(*b), 12)))
                            Var Pos4 = Instr(n + 1, Trim(*b), " ")
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
                            Var Pos3 = Instr(Trim(*b), "(")
                            Var n = Len(Trim(*b)) - Len(Trim(Mid(Trim(*b), 18)))
                            Var Pos4 = Instr(n + 1, Trim(*b), " ")
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
                            If Instr(*b, "(") = 0 Then
                                Var Pos3 = InStr(LCase(LTrim(*b)), " as ")
                                Var te = New TypeElement
                                te->Name = Trim(Mid(LTrim(*b), 18, Pos3 - 18 + 1))
                                If EndsWith(RTrim(lCase(te->Name)), " byref") Then te->Name = Left(te->Name, Len(Trim(te->Name)) - 6)
                                te->TypeName = Trim(Mid(LTrim(*b), Pos3 + 4))
                                Var Pos4 = Instr(te->TypeName, "'")
                                If Pos4 > 0 Then
                                    Var Pos5 = Instr(Trim(Mid(te->TypeName, Pos4 + 1)), " ")
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
                        End If
                    ElseIf StartsWith(Trim(LCase(*b)), "dim ") Then
                    Else
                        Var Pos3 = InStr(LCase(LTrim(*b)), " as ")
                        If Pos3 > 0 Then
                            Var te = New TypeElement
                            te->Name = Trim(Left(LTrim(*b), Pos3))
                            te->TypeName = Trim(Mid(LTrim(*b), Pos3 + 4))
                            Var Pos4 = Instr(te->TypeName, "'")
                            If Pos4 > 0 Then
                                Var Pos5 = Instr(Trim(Mid(te->TypeName, Pos4 + 1)), " ")
                                If Pos5 > 0 Then
                                    te->EnumTypeName = Left(Trim(Mid(te->TypeName, Pos4 + 1)), Pos5 - 1)
                                Else
                                    te->EnumTypeName = Trim(Mid(te->TypeName, Pos4 + 1))
                                End If
                                te->TypeName = Trim(Left(te->TypeName, Pos4 - 1))
                            End If
                            Pos4 = InstrRev(te->TypeName, ".")
                            If Pos4 > 0 Then te->TypeName = Mid(te->TypeName, Pos4 + 1)
                            te->ElementType = IIF(StartsWith(LCase(te->TypeName), "sub("), "Event", "Property")
                            te->Locals = inPubPriPro
                            WLet te->Parameters, Trim(*b)
                            If Comment Then WLet te->Comment, *Comment: WLet Comment, ""
                            If tbi Then tbi->Elements.Add te->Name, te
                        End If
                    End If
                ElseIf CInt(StartsWith(Trim(lcase(*b)), "enum ")) Then
                    InEnum = True
                    t = Trim(Mid(Trim(*b), 6))
                    Var Pos2 = Instr(t, "'")
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
                ElseIf CInt(StartsWith(Trim(lcase(*b)), "end enum")) Then
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
                EndIf
                App.DoEvents
            Loop
            Close #ff
        End if
        f = dir()
    Wend
    Comps.Sort
    Var iOld = -1, iNew = 0
    Dim As String it = "Cursor", g(1 to 4): g(1) = ML("Controls"): g(2) = ML("Containers"): g(3) = ML("Components"): g(4) = ML("Dialogs")
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
            If lCase(Comps.Item(i)) = "control" Or lCase(Comps.Item(i)) = "containercontrol" Or lCase(Comps.Item(i)) = "menu" Or lCase(Comps.Item(i)) = "component" Or lCase(Comps.Item(i)) = "dialog" Then Continue For
            iNew = GetTypeControl(Comps.Item(i))
            If Comps.Contains(Comps.Item(i)) Then
                Var tbi = Cast(ToolBoxItem Ptr, Comps.Object(Comps.IndexOf(Comps.Item(i))))
                tbi->ControlType = iNew
            End If
            If iNew = 0 Then Continue For
            'If iNew <> j Then Continue For
            it = Comps.Item(i)
            #IfNDef __USE_GTK__
				imgListTools.AddMasked it, cl, it, MFF
            #EndIf
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

Sub LoadKeyWords
    Dim b As String
    Open exepath & "/keywords/keywords0" For Input As #1
    Do Until EOF(1)
        Input #1, b
        keywords0.Add b
    Loop
    Close #1
    Open exepath & "/keywords/keywords1" For Input As #1
    Do Until EOF(1)
        Input #1, b
        keywords1.Add b
    Loop
    Close #1
    Open exepath & "/keywords/keywords2" For Input As #1
    Do Until EOF(1)
        Input #1, b
        keywords2.Add b
    Loop
    Close #1
    Open exepath & "/keywords/keywords3" For Input As #1
    Do Until EOF(1)
        Input #1, b
        keywords3.Add b
    Loop
    Close #1
End Sub

Sub LoadLanguageTexts
    #IfDef __FB_Win32__
		iniSettings.Create ExePath & "/VisualFBEditor.ini"
    #Else
		iniSettings.Create ExePath & "/VisualFBEditorX.ini"
    #EndIf
    CurLanguage = iniSettings.ReadString("Options", "Language", "english")
    If CurLanguage = "" Then
        mlKeys.Add "#Til"
        mlTexts.Add "English"
        Exit Sub
    End If
    Dim b As WString Ptr
    Dim As Integer i, Pos1
    Open exepath & "/languages/" & CurLanguage & ".lng" For Input Encoding "utf-8" As #1
    WReallocate b, LOF(1)
    Do Until EOF(1)
        Line Input #1, *b
        Pos1 = Instr(*b, "=")
        If Pos1 > 0 Then
            mlKeys.Add Trim(Left(*b, Pos1 - 1), " ")
            mlTexts.Add Trim(Mid(*b, Pos1 + 1), " ")
        End If
    Loop
    Close #1
End Sub

Dim cl As Integer = clSilver

	imgList.AddMasked "New", cl, "New"
	imgList.AddMasked "Open", cl, "Open"
	imgList.AddMasked "Save", cl, "Save"
	imgList.AddMasked "SaveAll", cl, "SaveAll"
	imgList.AddMasked "Close", cl, "Close"
	imgList.AddMasked "Exit", cl, "Exit"
	imgList.AddMasked "Undo", cl, "Undo"
	imgList.AddMasked "Redo", cl, "Redo"
	imgList.AddMasked "Cut", cl, "Cut"
	imgList.AddMasked "Copy", cl, "Copy"
	imgList.AddMasked "Paste", cl, "Paste"
	imgList.AddMasked "Search", cl, "Find"
	imgList.AddMasked "Code", cl, "Code"
	imgList.AddMasked "Form", cl, "Form"
	imgList.AddMasked "CodeAndForm", cl, "CodeAndForm"
	imgList.AddMasked "Compile", cl, "Compile"
	imgList.AddMasked "Run", cl, "Run"
	imgList.AddMasked "CompileAndRun", cl, "CompileAndRun"
	imgList.AddMasked "Help", cl, "Help"
	imgList.AddMasked "About", cl, "About"
	imgList.AddMasked "List", cl, "Try"
	imgList.AddMasked "File", cl, "File"
	imgList.AddMasked "Settings", cl, "Parameters"
	imgList.AddMasked "SyntaxCheck", cl, "SyntaxCheck"
	imgList.AddMasked "Folder", cl, "Folder"
	imgList.AddMasked "Project", cl, "Project"
	imgList.AddMasked "Add", cl, "Add"
	imgList.AddMasked "Remove", cl, "Remove"
	imgList.AddMasked "Start", cl, "Start"
	imgList.AddMasked "Pause", cl, "Pause"
	imgList.AddMasked "Stop", cl, "Stop"
	imgList.AddMasked "Error", cl, "Error"
	imgList.AddMasked "Warning", cl, "Warning"
	imgList.AddMasked "Label", cl, "Label"
	imgList.AddMasked "Component", cl, "Component"
	imgList.AddMasked "Property", cl, "Property"
	imgList.AddMasked "Sub", cl, "Sub"
	imgList.AddMasked "Bookmark", cl, "Bookmark"
	imgList.AddMasked "Breakpoint", cl, "Breakpoint"
	imgList.AddMasked "B32", cl, "B32"
	imgList.AddMasked "B64", cl, "B64"
	imgList.AddMasked "Opened", cl, "Opened"
	imgList.AddMasked "Tools", cl, "Tools"
	imgList.AddMasked "StandartTypes", cl, "StandartTypes"
	imgList.AddMasked "Enum", cl, "Enum"
	imgList.AddMasked "Function", cl, "Function"
	imgList.AddMasked "Collapsed", cl, "Collapsed"
	imgList.AddMasked "Categorized", cl, "Categorized"

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
miFile->Add(ML("Recent Projects"), "", "RecentProjects", @mclick)
miFile->Add(ML("Recent Files"), "", "RecentFile", @mclick)
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
miEdit->Add(ML("Single Comment") & !"\tCtrl+I", "", "SingleComment", @mclick)
miEdit->Add(ML("Block Comment") & !"\tCtrl+Alt+I", "", "BlockComment", @mclick)
miEdit->Add(ML("Uncomment Block") & !"\tCtrl+Shift+I", "", "UnComment", @mclick)
miEdit->Add("-")
miEdit->Add(ML("Select All") & !"\tCtrl+A", "", "SelectAll", @mclick)
miEdit->Add("-")
miEdit->Add(ML("Indent") & !"\tTab", "", "Indent", @mclick)
miEdit->Add(ML("Outdent") & !"\tShift+Tab", "", "Outdent", @mclick)
miEdit->Add(ML("Format") & !"\tCtrl+Tab", "", "Format", @mclick)
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
miBuild->Add(ML("Run") & !"\tShift+F5", "Run", "Run", @mclick)
miBuild->Add(ML("Compile/Run") & !"\tCtrl+F5", "CompileAndRun", "CompileAndRun", @mclick)
miBuild->Add("-")
miBuild->Add(ML("Compile With Debugger"), "", "CompileWithDebugger", @mclick)
miBuild->Add("-")
miBuild->Add(ML("Parameters"), "Parameters", "CompileOptions", @mclick)

Var miDebug = mnuMain.Add(ML("Debug"), "", "Debug")
miDebug->Add(ML("Start") & !"\tF5", "Start", "Start", @mclick)
miDebug->Add(ML("Pause") & !"\tCtrl+Pause", "Pause", "Pause", @mclick)
miDebug->Add(ML("Stop"), "Stop", "Stop", @mclick)
miDebug->Add("-")
miDebug->Add(ML("Breakpoint") & !"\tF9", "Breakpoint", "Breakpoint", @mclick)
miDebug->Add(ML("Clear All Breakpoints"), "", "ClearAllBreakpoints", @mclick)
miDebug->Add("-")
miDebug->Add(ML("Step Into") & !"\tF8", "", "StepInto", @mclick)

Var miXizmat = mnuMain.Add(ML("Service"), "", "Service")
miXizmat->Add(ML("Addins ..."), "", "Addins", @mclick)
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

tbStandard.ImagesList = @imgList
tbStandard.HotImagesList = @imgList
tbStandard.Align = 3
tbStandard.Flat = True
tbStandard.List = True
tbStandard.Buttons.Add tbsAutosize, "New",,@mClick, "New", , ML("&New"), True
tbStandard.Buttons.Add , "Open",, @mClick, "Open", , ML("&Open ..."), True
tbStandard.Buttons.Add , "Save",, @mClick, "Save", , ML("&Save ..."), True
tbStandard.Buttons.Add , "SaveAll",, @mClick, "SaveAll", , ML("Save All"), True
tbStandard.Buttons.Add tbsSeparator
tbStandard.Buttons.Add , "Undo",, @mClick, "Undo", , ML("Undo"), True
tbStandard.Buttons.Add , "Redo",, @mClick, "Redo", , ML("Redo"), True
tbStandard.Buttons.Add tbsSeparator
tbStandard.Buttons.Add , "Cut",, @mClick, "Cut", , ML("Cut"), True
tbStandard.Buttons.Add , "Copy",, @mClick, "Copy", , ML("Copy"), True
tbStandard.Buttons.Add , "Paste",, @mClick, "Paste", , ML("Paste"), True
tbStandard.Buttons.Add tbsSeparator
tbStandard.Buttons.Add , "Find",, @mClick, "Find", , ML("Find"), True
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
tbStandard.Buttons.Add , "Compile",, @mClick, "Compile", , ML("Compile"), True
tbStandard.Buttons.Add , "Run",, @mClick, "Run", , ML("Run"), True
tbStandard.Buttons.Add , "CompileAndRun",, @mClick, "CompileAndRun", , ML("Compile/Run"), True
tbStandard.Buttons.Add tbsSeparator
tbStandard.Buttons.Add , "Start",, @mClick, "Start", , ML("Start"), True
tbStandard.Buttons.Add , "Pause",, @mClick, "Pause", , ML("Pause"), True
tbStandard.Buttons.Add , "Stop",, @mClick, "Stop", , ML("Stop"), True
tbStandard.Buttons.Add tbsSeparator
tbStandard.Buttons.Add tbsCheck Or tbsAutosize, "Form",, @mClick, "Form", , ML("Console/GUI"), True
tbStandard.Buttons.Add tbsSeparator
#IfDef __USE_GTK__
	tbStandard.Buttons.Add tbsAutosize Or tbsCheckGroup, "B32",, @mClick, "B32", , ML("32-bit"), True
	tbStandard.Buttons.Add tbsAutosize Or tbsCheckGroup, "B64",, @mClick, "B64", , ML("64-bit"), True
	#IfDef __FB_64bit__
		tbStandard.Buttons.Item("B64")->Checked = True
	#Else
		tbStandard.Buttons.Item("B32")->Checked = True
	#EndIf
#Else
	#IfDef __FB_64bit__
		tbStandard.Buttons.Add tbsAutosize Or tbsCheckGroup, "B32",, @mClick, "B32", , ML("32-bit"), True
		tbStandard.Buttons.Add tbsAutosize Or tbsCheckGroup, "B64",, @mClick, "B64", , ML("64-bit"), True, tstEnabled Or tstChecked
	#Else
		tbStandard.Buttons.Add tbsAutosize Or tbsCheckGroup, "B32",, @mClick, "B32", , ML("32-bit"), True, tstEnabled Or tstChecked
		tbStandard.Buttons.Add tbsAutosize Or tbsCheckGroup, "B64",, @mClick, "B64", , ML("64-bit"), True
	#EndIf
#EndIf
'tbStandard.AddRange 1, @cboCommands

stBar.Align = 4
stBar.Add ML("Press F1 for get more information")
stBar.Add "NUM"

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
    tpShakl_Resize *tpShakl
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
        #IfDef __USE_GTK__
			pnlLeft.Width = 30
        #Else
			pnlLeft.Width = tabLeft.ItemWidth(0) + 2
        #EndIf
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
    #IfDef __USE_GTK__
	    If Item.Nodes.Count > 0 Then
	    	If Item.IsExpanded Then
	    		Item.Collapse
	    	Else
	    		Item.Expand
	    	End If
	    End If
    #EndIf
    If Item.ImageKey = "Project" Then Exit Sub
    Dim t As Boolean
    For i As Integer = 0 To tabCode.TabCount - 1
        If Cast(TabWindow Ptr, tabCode.Tabs[i])->tn = @Item Then
            tabCode.TabIndex = tabCode.Tabs[i]->Index
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
    For i As Integer = 0 To tabCode.TabCount - 1
        If Cast(TabWindow Ptr, tabCode.Tabs[i])->tn = tn Then
            tabCode.TabIndex = tabCode.Tabs[i]->Index
            t = True
            Exit For
        End If
    Next i
    If Not t Then
        If tn->Tag <> 0 Then AddTab *Cast(ExplorerElement Ptr, tn->Tag)->FileName, , tn
    End If
End Sub

Sub tvExplorer_KeyDown(ByRef Sender As Control, Key As Integer,Shift As Integer)
    #IfDef __USE_GTK__
    	Select Case Key
    	Case GDK_KEY_LEFT
    		
    	End Select
    #Else
		If Key = VK_Return Then tvExplorer_DblClick Sender
	#EndIf
End Sub

tvExplorer.Images = @imgList
tvExplorer.SelectedImages = @imgList
tvExplorer.Align = 5
tvExplorer.HideSelection = False
'tvExplorer.Sorted = True
'tvExplorer.OnDblClick = @tvExplorer_DblClick
tvExplorer.OnNodeActivate = @tvExplorer_NodeActivate
tvExplorer.OnKeyDown = @tvExplorer_KeyDown
tvExplorer.ContextMenu = @mnuExplorer

Sub tabLeft_SelChange(ByRef Sender As Control, NewIndex As Integer)
    #IfDef __USE_GTK__
		If tabLeft.TabPosition = tpLeft And pnlLeft.Width = 30 Then
    #Else
		If tabLeft.TabPosition = tpLeft And tabLeft.TabIndex <> -1 Then
    #EndIf
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

Sub pnlLeft_Resize(ByRef Sender As Control)
	#IfDef __USE_GTK__
		If pnlLeft.Width <> 30 Then tabLeftWidth = pnlLeft.Width ': tabLeft.Width = pnlLeft.Width
	#Else
		If tabLeft.TabIndex <> -1 Then tabLeftWidth = pnlLeft.Width
	#EndIf
End Sub

pnlLeft.Align = 1
pnlLeft.Width = tabLeftWidth
pnlLeft.OnReSize = @pnlLeft_Resize

tabLeft.Width = tabLeftWidth
tabLeft.Align = 5
tabLeft.OnClick = @tabLeft_Click
tabLeft.OnDblClick = @tabLeft_DblClick
tabLeft.OnSelChange = @tabLeft_SelChange
pnlLeft.Add @tabLeft
'tabLeft.TabPosition = tpLeft

Var tpLoyiha = tabLeft.AddTab(ML("Project"))

tpShakl = tabLeft.AddTab(ML("Form"))

lblLeft.Align = 4
lblLeft.Text = ML("Main File") & ": " & ML("Automatic")

tpLoyiha->Add @tbExplorer
tpLoyiha->Add @lblLeft
tpLoyiha->Add @tvExplorer
#IfNDef __USE_GTK__
	tpShakl->Add @scrTool
#EndIf
tpShakl->Add @tbToolBox
tpShakl->Add @tbForm 
tpShakl->OnReSize = @tpShakl_Resize
'tabLeft.Tabs[1]->Style = tabLeft.Tabs[1]->Style Or ES_AUTOVSCROLL or WS_VSCROLL

'pnlLeft.Width = 153
'pnlLeft.Align = 1
'pnlLeft.AddRange 1, @tabLeft

Sub tbProperties_ButtonClick(Sender As My.Sys.Object)
    Var tb = Cast(TabWindow Ptr, tabCode.SelectedTab)
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

Sub lvProperties_SelectedItemChanged(ByRef Sender As ListView, BYREF Item As ListViewItem)
    Var tb = Cast(TabWindow Ptr, tabCode.SelectedTab)
    If tb = 0 OrElse tb->Des = 0 OrElse tb->Des->SelectedControl = 0 OrElse tb->Des->ReadPropertyFunc = 0 Then Exit Sub
    Dim As Rect lpRect
    lvProperties.SetFocus
    txtPropertyValue.Visible = False
    pnlPropertyValue.Visible = False
    #IfNDef __USE_GTK__
		ListView_GetSubItemRect(lvProperties.Handle, Item.Index, 1, LVIR_BOUNDS, @lpRect)
    #EndIf
    Var te = GetPropertyType(WGet(tb->Des->ReadPropertyFunc(tb->Des->SelectedControl, "ClassName")), GetItemText(Item))
    If te = 0 Then Exit Sub
    If LCase(te->TypeName) = "boolean" Then
        CtrlEdit = @pnlPropertyValue
        cboPropertyValue.Clear
        cboPropertyValue.AddItem " false"
        cboPropertyValue.AddItem " true"
        cboPropertyValue.ItemIndex = cboPropertyValue.IndexOf(" " & Item.Text(1))
    ElseIf LCase(te->TypeName) = "integer" AndAlso CInt(te->EnumTypeName <> "") AndAlso CInt(Comps.Contains(te->EnumTypeName)) Then
        CtrlEdit = @pnlPropertyValue
        cboPropertyValue.Clear
        Var tbi = Cast(ToolBoxItem Ptr, Comps.Object(Comps.IndexOf(te->EnumTypeName)))
        If tbi Then
            For i As Integer = 0 To tbi->Elements.Count - 1
                cboPropertyValue.AddItem " " & i & " - " & tbi->Elements.Item(i)
            Next i
            If Val(Item.Text(1)) >= 0 AndAlso Val(Item.Text(1)) <= tbi->Elements.Count - 1 Then
                cboPropertyValue.ItemIndex = Val(Item.Text(1))
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
        cboPropertyValue.ItemIndex = cboPropertyValue.IndexOf(" " & Item.Text(1))
    Else
        Dim tbi As ToolBoxItem Ptr
        If Comps.Contains(te->TypeName) Then tbi = Cast(ToolBoxItem Ptr, Comps.Object(Comps.IndexOf(te->TypeName)))
        If tbi AndAlso tbi->ElementType = "Enum" Then
            CtrlEdit = @pnlPropertyValue
            cboPropertyValue.Clear
            For i As Integer = 0 To tbi->Elements.Count - 1
                cboPropertyValue.AddItem " " & i & " - " & tbi->Elements.Item(i)
            Next i
            If Val(Item.Text(1)) >= 0 AndAlso Val(Item.Text(1)) <= tbi->Elements.Count - 1 Then
                cboPropertyValue.ItemIndex = Val(Item.Text(1))
            End If
        Else
            CtrlEdit = @txtPropertyValue
            CtrlEdit->Text = Item.Text(1)
        End If
    End If
    CtrlEdit->SetBounds lpRect.Left, lpRect.Top, lpRect.Right - lpRect.Left, lpRect.Bottom - lpRect.Top - 1
    If CtrlEdit = @pnlPropertyValue Then cboPropertyValue.Width = lpRect.Right - lpRect.Left + 2
    CtrlEdit->Visible = True
    If te->Comment <> 0 Then
        txtLabelProperty.Text = *te->Comment
    End If
End Sub

Sub lvProperties_ItemDblClick(ByRef Sender As ListView, BYREF Item As ListViewItem)
    ClickProperty Item.Index
End Sub

Sub lvEvents_ItemDblClick(ByRef Sender As ListView, BYREF Item As ListViewItem)
    Dim As TabWindow Ptr tb = tabRight.Tag
    If tb = 0 OrElse tb->Des = 0 OrElse tb->Des->SelectedControl = 0 Then Exit Sub
    FindEvent tb->Des->SelectedControl, Item.Text(0)
End Sub

Sub lvProperties_EndScroll(ByRef Sender As ListView)
    If CtrlEdit = 0 Then Exit Sub
    If lvProperties.SelectedItem = 0 Then
        CtrlEdit->Visible = False
    Else
        Dim As Rect lpRect
        #IfNDef __USE_GTK__
			ListView_GetSubItemRect(lvProperties.Handle, lvProperties.SelectedItem->Index, 1, LVIR_BOUNDS, @lpRect)
        #EndIf
        'If lpRect.Top < lpRect.Bottom - lpRect.Top Then
        '    txtPropertyValue.Visible = False
        'Else
            CtrlEdit->SetBounds lpRect.Left, lpRect.Top, lpRect.Right - lpRect.Left, lpRect.Bottom - lpRect.Top - 1
            CtrlEdit->Visible = True
        'End If
    End If
End Sub

Dim Shared lvWidth As Integer

Sub lvProperties_Resize(ByRef Sender As Control)
    lvWidth = lvProperties.Width - 22
    lvProperties.Columns.Column(1)->Width = (lvWidth - 32) / 2
    lvProperties.Columns.Column(0)->Width = lvWidth - (lvWidth - 32) / 2
    txtPropertyValue.Width = (lvWidth - 32) / 2
    pnlPropertyValue.Width = (lvWidth - 32) / 2
    cboPropertyValue.Width = (lvWidth - 32) / 2 + 2
    lvProperties_EndScroll(*Cast(ListView Ptr, @Sender))
End Sub

Sub lvEvents_Resize(ByRef Sender As Control)
    lvWidth = lvEvents.Width - 22
    lvEvents.Columns.Column(0)->Width = lvWidth / 2
    lvEvents.Columns.Column(1)->Width = lvWidth / 2
    'lvEvents_EndScroll(*Cast(ListView Ptr, @Sender))
End Sub

Sub lvProperties_KeyDown(ByRef Sender As Control, Key As Integer, Shift As Integer)
    Dim iItem As Integer
	Dim dwState As Integer
	Dim iIndent As Integer
	Dim iIndentChild As Integer
	' Get the selected item...
	#IfNDef __USE_GTK__
		iItem = ListView_GetNextItem(lvProperties.Handle, -1, LVNI_FOCUSED Or LVNI_SELECTED)
	#EndIf
	If (iItem <> -1) Then
    ' Get the item's indent and state values
	#IfNDef __USE_GTK__
		dwState = Listview_GetItemStateEx(lvProperties.Handle, iItem, iIndent)
		Select Case Key
		  ' ========================================================
		  ' The right arrow key expands the selected item, then selects the current
		  ' item's first child
		  Case VK_RIGHT
			' If the item is collaped, expanded it, otherwise select
			' the first child of the selected item (if any)
			If (dwState = 1) Then
			  AddChildItems(iItem, iIndent)
			ElseIf (dwState = 2) Then
			  If iItem < lvProperties.ListItems.Count - 1 AndAlso lvProperties.ListItems.Item(iItem + 1)->Indent > iIndent Then
				  ListView_SetItemState(lvProperties.Handle, iItem + 1, LVIS_FOCUSED Or LVIS_SELECTED, LVIS_FOCUSED Or LVIS_SELECTED)
			  End If
			  'iItem = ListView_GetRelativeItem(m_hwndLV, iItem, lvriChild)
			  'If (iItem <> -1) Then Call ListView_SetFocusedItem(lvProperties.Handle, iItem)
			End If
		  ' ========================================================
		  ' The left arrow key collapses the selected item, then selects the current
		  ' item's parent. The backspace key only selects the current item's parent
		  Case VK_LEFT, VK_BACK
			' If vbKeyLeft and the item is expanded, collaped it, otherwise select
			' the parent of the selected item (if any)
			If (Key = VK_LEFT) And (dwState = 2) Then
				RemoveChildItems(iItem, iIndent)
			Else
				For i As Integer = iItem To 0 Step -1
					dwState = Listview_GetItemStateEx(lvProperties.Handle, i, iIndentChild)
					If iIndentChild < iIndent Then
						ListView_SetItemState(lvProperties.Handle, i, LVIS_FOCUSED Or LVIS_SELECTED, LVIS_FOCUSED Or LVIS_SELECTED)
						Exit For
					End If
				Next
	'          iItem = ListView_GetRelativeItem(m_hwndLV, iItem, lvriParent)
	'          If (iItem <> LVI_NOITEM) Then
	'            Call ListView_SetFocusedItem(m_hwndLV, iItem)
	'            Call ListView_EnsureVisible(m_hwndLV, iItem, False)
	'          End If
			End If
		End Select   ' KeyCode
	#EndIf
  End If   ' (iItem <> LVI_NOITEM)
End Sub

Sub lvEvents_KeyDown(ByRef Sender As Control, BYREF Item As ListViewItem)
    
End Sub

Sub lvProperties_KeyPress(ByRef Sender As Control, Key As Byte)
    txtPropertyValue.Text = WChr(Key)
    txtPropertyValue.SetFocus
    txtPropertyValue.SetSel 1, 1
    Key = 0
End Sub

Sub lvProperties_KeyUp(ByRef Sender As Control, Key As Integer, Shift As Integer)
    #IfNDef __USE_GTK__
		Select Case Key
		Case VK_Return: txtPropertyValue.SetFocus
		Case VK_Left, VK_Right, VK_Up, VK_Down, VK_NEXT, VK_PRIOR
		End Select
	#EndIf
    'Key = 0
End Sub

'#IfNDef __USE_GTK__
	imgListStates.AddMasked "Collapsed", cl, "Collapsed"
	imgListStates.AddMasked "Expanded", cl, "Expanded"
	imgListStates.AddMasked "Property", cl, "Property"
	imgListStates.AddMasked "Run", cl, "Run"
'#EndIf

lvProperties.Align = 5
'lvProperties.Sort = ssSortAscending
lvProperties.StateImages = @imgListStates
lvProperties.SmallImages = @imgListStates
lvProperties.ColumnHeaderHidden = True
lvProperties.Columns.Add ML("Property"), , 70
lvProperties.Columns.Add ML("Value"), , 50, , True
lvProperties.Add @txtPropertyValue
lvProperties.Add @pnlPropertyValue
lvProperties.OnSelectedItemChanged = @lvProperties_SelectedItemChanged
lvProperties.OnEndScroll = @lvProperties_EndScroll
lvProperties.OnResize = @lvProperties_Resize
lvProperties.OnMouseDown = @lvProperties_MouseDown
lvProperties.OnKeyDown = @lvProperties_KeyDown
lvProperties.OnItemDblClick = @lvProperties_ItemDblClick
lvProperties.OnKeyUp = @lvProperties_KeyUp

lvEvents.Align = 5
lvEvents.Sort = ssSortAscending
lvEvents.Columns.Add ML("Event"), , 70
lvEvents.Columns.Add ML("Value"), , -2
lvEvents.OnItemKeyDown = @lvEvents_KeyDown
#IfDef __USE_GTK__
	lvEvents.OnItemActivate = @lvEvents_ItemDblClick
#Else
	lvEvents.OnItemDblClick = @lvEvents_ItemDblClick
#EndIf
lvEvents.OnResize = @lvEvents_Resize
lvEvents.SmallImages = @imgListStates

splProperties.Align = 4

splEvents.Align = 4

txtLabelProperty.Height = 50
txtLabelProperty.Align = 4
txtLabelProperty.Multiline = True
txtLabelProperty.ReadOnly = True
#IfNDef __USE_GTK__
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

Sub pnlRight_Resize(ByRef Sender As Control)
    #IfDef __USE_GTK__
		If pnlRight.Width <> 30 Then tabRightWidth = pnlRight.Width: tabRight.Width = tabRightWidth: tabRight.Left = 0
	#Else
		If tabRight.TabIndex <> -1 Then tabRightWidth = tabRight.Width
	#EndIf
End Sub

pnlRight.Align = 2
pnlRight.Width = tabRightWidth
pnlRight.OnResize = @pnlRight_Resize

tabRight.Width = tabRightWidth
#IfDef __USE_GTK__
	tabRight.Align = 2
#Else
	tabRight.Align = 5
#EndIf
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

'tabCode.Images.AddIcon bmp

Sub tabCode_SelChange(ByRef Sender As TabControl, NewIndex As Integer)
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, Sender.Tab(NewIndex))
    If tb = 0 Then Exit Sub
    tb->tn->SelectItem
    If frmMain.ActiveControl <> tb And frmMain.ActiveControl <> @tb->txtCode Then tb->txtCode.SetFocus
    lvProperties.ListItems.Clear
    tb->FillAllProperties
End Sub

tabCode.Images = @imgList
tabCode.Align = 5
tabCode.OnPaint = @tabCode_Paint
tabCode.OnSelChange = @tabCode_SelChange
    
txtOutput.Align = 5
txtOutput.Multiline = True
txtOutput.ScrollBars = 3
txtOutput.OnDblClick = @txtOutput_DblClick

Sub lvErrors_ItemActivate(ByRef Sender As Control, ByRef item As ListViewItem) '...'
    SelectError(item.Text(2), Val(item.Text(1)), item.Tag)
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

Sub lvSearch_ItemActivate(ByRef Sender As Control, ByRef item As ListViewItem)
    SelectSearchResult(item.Text(3), Val(item.Text(1)), Val(item.Text(2)), Len(lvSearch.Text), item.Tag)
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
    Return Not tabBottom.TabPosition = tpTop
End Function

Sub SetBottomClosedStyle(Value As Boolean)
    If Value Then
        tabBottom.TabPosition = tpBottom
        tabBottom.TabIndex = -1
        #IfDef __USE_GTK__
			pnlBottom.Height = 25
        #Else
			pnlBottom.Height = tabBottom.ItemHeight(0) + 2
        #EndIf
        splBottom.Visible = False
        'pnlBottom.RequestAlign
    Else
        tabBottom.TabPosition = tpTop
		tabBottom.Height = tabBottomHeight
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
	#IfDef __USE_GTK__
	If tabBottom.TabPosition = tpBottom And pnlBottom.Height = 25 Then
    #Else
    If tabBottom.TabPosition = tpBottom And tabBottom.TabIndex <> -1 Then
    #EndIf
        tabBottom.SetFocus
        pnlBottom.Height = tabBottomHeight
        pnlBottom.RequestAlign
        splBottom.Visible = True
        frmMain.RequestAlign '<bp>
    End If
End Sub

Sub tabBottom_Click(ByRef Sender As Control) '<...>
	#IfDef __USE_GTK__
	If tabBottom.TabPosition = tpBottom And pnlBottom.Height = 25 Then
    #Else
    If tabBottom.TabPosition = tpBottom And tabBottom.TabIndex <> -1 Then
    #EndIf
        tabBottom.SetFocus
        pnlBottom.Height = tabBottomHeight
        pnlBottom.RequestAlign
        splBottom.Visible = True
        frmMain.RequestAlign '<bp>
    End If
End Sub

Sub pnlBottom_Resize(ByRef Sender As Control)
	#IfDef __USE_GTK__
		If pnlBottom.Height <> 25 Then tabBottomHeight = pnlBottom.Height: tabBottom.Height = tabBottomHeight: tabBottom.Top = 0
	#Else
		If tabBottom.TabIndex <> -1 Then tabBottomHeight = tabBottom.Height
	#EndIf
End Sub

pnlBottom.Align = 4
pnlBottom.Height = tabBottomHeight
pnlBottom.OnResize = @pnlBottom_Resize

'tabBottom.Images.AddIcon bmp
tabBottom.Height = tabBottomHeight
#IfDef __USE_GTK__
	tabBottom.Align = 4
#Else
	tabBottom.Align = 5
#EndIf
'tabBottom.TabPosition = tpBottom
tabBottom.AddTab(ML("Output"))
tabBottom.AddTab(ML("Errors"))
tabBottom.AddTab(ML("Find"))
tabBottom.AddTab(ML("Locals"))
tabBottom.AddTab(ML("Processes"))
tabBottom.AddTab(ML("Threads"))
tabBottom.AddTab(ML("Watches"))
tabBottom.Tabs[0]->Add @txtOutput
tabBottom.Tabs[1]->Add @lvErrors
tabBottom.Tabs[2]->Add @lvSearch
tabBottom.Tabs[3]->Add @tvVar
tabBottom.Tabs[4]->Add @tvPrc
tabBottom.Tabs[5]->Add @tvThd
tabBottom.Tabs[6]->Add @tvWch
tabBottom.OnClick = @tabBottom_Click
tabBottom.OnDblClick = @tabBottom_DblClick
tabBottom.OnSelChange = @tabBottom_SelChange
'pnlBottom.Height = 153
'pnlBottom.Align = 4
'pnlBottom.AddRange 1, @tabBottom
pnlBottom.Add @tabBottom

LoadKeyWords '<bm>

Sub frmMain_ActiveControlChanged(ByRef sender As My.Sys.Object)
    If frmMain.ActiveControl = 0 Then Exit Sub
    If tabLeft.TabPosition = tpLeft And tabLeft.TabIndex <> -1 Then
        If frmMain.ActiveControl->Parent <> tabLeft.SelectedTab AndAlso frmMain.ActiveControl <> @tabLeft Then
            splLeft.Visible = False
            #IfDef __USE_GTK__
				pnlLeft.Width = 30
            #Else
				tabLeft.TabIndex = -1
				pnlLeft.Width = tabLeft.ItemWidth(0) + 2
            #EndIf
            frmMain.RequestAlign
        End If
    End If
    If tabRight.TabPosition = tpRight And tabRight.TabIndex <> -1 Then
        If frmMain.ActiveControl->Parent <> tabRight.SelectedTab AndAlso frmMain.ActiveControl <> @tabRight _
        	AndAlso frmMain.ActiveControl <> @txtPropertyValue AndAlso frmMain.ActiveControl <> @cboPropertyValue Then
            splRight.Visible = False
            #IfDef __USE_GTK__
				pnlRight.Width = 30
			#Else
				tabRight.TabIndex = -1
				pnlRight.Width = tabRight.ItemWidth(0) + 2
			#EndIf
            frmMain.RequestAlign
        End If
    End If
    If tabBottom.TabPosition = tpBottom And tabBottom.TabIndex <> -1 Then
        If frmMain.ActiveControl->Parent <> tabBottom.SelectedTab AndAlso frmMain.ActiveControl <> @tabBottom Then
            splBottom.Visible = False
            #IfDef __USE_GTK__
				pnlBottom.Height = 25
            #Else
				tabBottom.TabIndex = -1
				pnlBottom.Height = tabBottom.ItemHeight(0) + 2
            #EndIf
			frmMain.RequestAlign
        End If
    End If
End Sub

Sub frmMain_Resize(ByRef sender As My.Sys.Object)
    stBar.Panels[0]->Width = frmMain.ClientWidth - 50
End Sub

Sub frmMain_DropFile(ByRef sender As My.Sys.Object, ByRef FileName As WString)
    AddTab FileName
End Sub

Sub frmMain_Create(ByRef Sender As Control)
	#IfDef __USE_GTK__
		'gtk_window_set_icon_name(GTK_WINDOW(frmMain.widget), "VisualFBEditor1")
		'gtk_window_set_icon_name(GTK_WINDOW(frmMain.widget), ToUTF8("VisualFBEditor4"))
	#EndIf
	tabLeftWidth = iniSettings.ReadInteger("MainWindow", "LeftWidth", tabLeftWidth)
    SetLeftClosedStyle iniSettings.ReadBool("MainWindow", "LeftClosed", True)
    tabRightWidth = iniSettings.ReadInteger("MainWindow", "RightWidth", tabRightWidth)
    SetRightClosedStyle iniSettings.ReadBool("MainWindow", "RightClosed", True)
    tabBottomHeight = iniSettings.ReadInteger("MainWindow", "BottomHeight", tabBottomHeight)
    SetBottomClosedStyle iniSettings.ReadBool("MainWindow", "BottomClosed", True)
    tbExplorer.Buttons.Item(3)->Checked = iniSettings.ReadBool("MainWindow", "ProjectFolders", True)
    #IfDef __FB_Win32__
		WLet Compilator32, iniSettings.ReadString("Options", "Compilator32", "fbc.exe")
		WLet Compilator64, iniSettings.ReadString("Options", "Compilator64", "fbc.exe")
		WLet Debugger, iniSettings.ReadString("Options", "Debugger", "")
		WLet Terminal, iniSettings.ReadString("Options", "Terminal", "")
    #Else
		WLet Compilator32, iniSettings.ReadString("Options", "Compilator32", "fbc")
		WLet Compilator64, iniSettings.ReadString("Options", "Compilator64", "fbc")
		WLet Debugger, iniSettings.ReadString("Options", "Debugger", "gdb")
		WLet Terminal, iniSettings.ReadString("Options", "Terminal", "gnome-terminal")
    #EndIf
    WLet HelpPath, iniSettings.ReadString("Options", "HelpPath", "")
    AutoIncrement = iniSettings.ReadBool("Options", "AutoIncrement", true)
    AutoCreateRC = iniSettings.ReadBool("Options", "AutoCreateRC", true)
    AutoSaveCompile = iniSettings.ReadBool("Options", "AutoSaveCompile", true)
    AutoComplete = iniSettings.ReadBool("Options", "AutoComplete", true)
    AutoIndentation = iniSettings.ReadBool("Options", "AutoIndentation", true)
    ShowSpaces = iniSettings.ReadBool("Options", "ShowSpaces", true)
    TabWidth = iniSettings.ReadInteger("Options", "TabWidth", 4)
    HistoryLimit = iniSettings.ReadInteger("Options", "HistoryLimit", 20)
    Var file = Command(-1)
    If file = "" Then
        'AddTab ExePath & "/templates/Form.bas", True
    Else
        AddTab file
    End If
    #IfNDef __USE_GTK__
		windmain = frmMain.Handle
		htab2    = tabCode.Handle
		tviewVar = tvVar.Handle
		tviewPrc = tvPrc.Handle
		tviewThd = tvThd.Handle
		tviewWch = tvWch.Handle
		DragAcceptFiles(frmMain.Handle, true)
	#EndIf
End Sub

Sub frmMain_Close(ByRef Sender As Form, ByRef Action As Integer)
    On Error Goto ErrorHandler
    Dim tb As TabWindow Ptr
    For i As Integer = 0 To tabCode.TabCount - 1
        tb = Cast(TabWindow Ptr, tabCode.Tab(i))
        If CInt(tb) AndAlso Cint(Not tb->CloseTab) Then Action = 0: Return
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
    Exit Sub
ErrorHandler:
    MsgBox ErrDescription(Err) & " (" & Err & ") " & _
        "in line " & Erl() & " " & _
        "in function " & ZGet(Erfn()) & " " & _
        "in module " & ZGet(Ermn())
End Sub

'For i As Integer = 1 To 4
	'eeer = NULL
	'Dim As GdkPixbuf Ptr icon = gdk_pixbuf_new_from_file(exepath & "/resources/VisualFBEditor" & Trim(Str(i)) & ".png", @eeer)

	  '?exepath & "/resources/VisualFBEditor" & Trim(Str(i)) & ".png"
'	  if (icon = 0) Then Continue For
'	  list1 = g_list_append(list1, icon)
'	  ?icon
'Next i

#IfDef __USE_GTK__
	frmMain.Icon.LoadFromFile(exepath & "/resources/VisualFBEditor.ico")
#Else
	frmMain.Icon.LoadFromResourceID(1)
#EndIf
frmMain.Height = 500
frmMain.Width = 800
frmMain.MainForm = True
#IfDef __FB_64bit__
    frmMain.Text = "Visual FB Editor (x64)"
#Else
    frmMain.Text = "Visual FB Editor (x32)"
#EndIf
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
frmMain.Add @tabCode

'#IfDef __USE_GTK__
'	Dim As GtkCssProvider Ptr provider
'	Dim As GdkDisplay Ptr display
'	Dim As GdkScreen Ptr gscreen
'	
'	' ---------------------------------------------------- CSS -----------------------------------------------------------
'	provider = gtk_css_provider_new ()
'	display = gdk_display_get_default ()
'	gscreen = gdk_display_get_default_screen (display)
'	gtk_style_context_add_provider_for_screen (gscreen, GTK_STYLE_PROVIDER (provider), GTK_STYLE_PROVIDER_PRIORITY_APPLICATION)
'	Dim As gchar myCssFile = "./main.css"
'	Dim as GError Ptr error1 = 0
'	
'	gtk_css_provider_load_from_file(provider, g_file_new_for_path(myCssFile), @error1)
'	'g_object_unref (provider)
'#EndIf

'gtk_window_set_icon_name(GTK_WINDOW(frmMain.widget), ToUTF8("VisualFBEditor4"))    
frmMain.CreateWnd
frmMain.Show
'gtk_window_set_icon_name(GTK_WINDOW(frmMain.widget), ToUTF8("VisualFBEditor4"))    
'?gtk_window_set_default_icon_from_file(exepath & "/resources/VisualFBEditor-0.png", null)

fSplash.CloseForm

App.MainForm = @frmMain
App.Run

End
AA:
MsgBox ErrDescription(Err) & " (" & Err & ") " & _
    "in function " & ZGet(Erfn()) & " " & _
    "in module " & ZGet(Ermn()) ' & " " & _
    '"in line " & Erl()


