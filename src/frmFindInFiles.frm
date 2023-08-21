'#########################################################
'#  frmFindInFiles.bas                                   #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (2018-2019)              #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "frmFindInFiles.bi"

Dim Shared As frmFindInFiles fFindFile
pfFindFile = @fFindFile

'#Region "Form"
	Private Sub frmFindInFiles._btnFind_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		With fFindFile
			.btnFind_Click(Sender)
		End With
	End Sub
	
	Private Sub frmFindInFiles._btnCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		fFindFile.btnCancel_Click(Sender)
	End Sub
	
	Private Sub frmFindInFiles._Form_Show_(ByRef Designer As My.Sys.Object, ByRef Sender As Form)
		fFindFile.Form_Show(Sender)
	End Sub
	
	Private Sub frmFindInFiles._Form_Close_(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer)
		fFindFile.Form_Close(Sender, Action)
	End Sub
	
	Constructor frmFindInFiles
		This.Name = "frmFindInFiles"
		This.StartPosition = FormStartPosition.CenterParent
		#ifdef __USE_GTK__
			This.Icon.LoadFromFile(ExePath & "/Resources/VisualFBEditor.ico")
		#else
			This.Icon.LoadFromResourceID(1)
		#endif
		This.BorderStyle = FormBorderStyle.Sizable
		This.Caption = ML("Find In Files")
		This.ID = 1000
		'This.IsChild = True
		This.OnResize = @Form_Resize
		This.Designer = @This
		This.OnCreate = @_Form_Create
		This.SetBounds 0, 0, 440, 224
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = ""
			.TabIndex = 13
			.SetBounds 6, 64, 416, 180
			.Anchor.Left = asAnchor
			.Anchor.Right = asAnchor
			.Parent = @This
		End With
		lblFind.Name = "lblFind"
		lblFind.Caption = ML("Find What") & ":"
		lblFind.TabIndex = 0
		lblFind.SetBounds 10, 11, 85, 20
		lblFind.Parent = @This
		
		txtFind.Name = "txtFind"
		txtFind.TabIndex = 1
		txtFind.SetBounds 97, 8, 318, 26
		txtFind.Anchor.Left = asAnchor
		txtFind.Anchor.Right = asAnchor
		txtFind.Parent = @This
		
		lblPath.Name = "lblPath"
		lblPath.Caption = ML("In Folder") & ":"
		lblPath.TabIndex = 4
		lblPath.SetBounds 4, 9, 85, 20
		lblPath.Parent =  @Panel1
		
		btnBrowse.Name = "btnBrowse"
		btnBrowse.Caption = "..."
		btnBrowse.TabIndex = 6
		btnBrowse.SetBounds 376, 3, 34, 28
		btnBrowse.Anchor.Right = asAnchor
		btnBrowse.Parent =  @Panel1
		
		txtPath.Name = "txtPath"
		txtPath.TabIndex = 5
		txtPath.SetBounds 91, 4, 282, 26
		txtPath.Anchor.Left = asAnchor
		txtPath.Anchor.Right = asAnchor
		txtPath.Parent =  @Panel1
		
		chkMatchCase.Name = "chkMatchCase"
		chkMatchCase.Caption = ML("Match Case")
		chkMatchCase.TabIndex = 7
		chkMatchCase.SetBounds 92, 38, 150, 22
		chkMatchCase.Parent =  @Panel1
		chkSearchInSub.Name = "chkSearchInSub"
		chkSearchInSub.Caption = ML("Search Subfolders")
		chkSearchInSub.TabIndex = 9
		chkSearchInSub.SetBounds 92, 63, 150, 22
		chkSearchInSub.Checked = True
		chkSearchInSub.Parent =  @Panel1
		'btnFind
		With btnFind
			.Name = "btnFind"
			.Caption = ML("&Find")
			.Default = True
			.TabIndex = 10
			.SetBounds 90, 92, 106, 30
			.Anchor.Left = asAnchor
			.Parent =  @Panel1
			.OnClick = @_btnFind_Click_
		End With
		
		' btnReplace
		With btnReplace
			.Name = "btnReplace"
			.Text = ML("&Replace")
			.TabIndex = 11
			.SetBounds 199, 92, 106, 30
			.Anchor.Right = asAnchor
			.OnClick = @btnReplace_Click
			.Parent = @Panel1
		End With
		
		'btnFind
		With btnCancel
			.Name="btnCancel"
			.Caption = ML("&Cancel")
		btnCancel.TabIndex = 12
			.SetBounds 308, 92, 104, 30
			.Anchor.Right = asAnchor
			.Parent = @Panel1
		End With
		
		OnShow = @_Form_Show_
		OnClose = @_Form_Close_
		
		btnCancel.OnClick = @_btnCancel_Click_
		btnBrowse.OnClick = @btnBrowse_Click
		DefaultButton = @btnFind
		CancelButton = @btnCancel
		'This.BorderStyle = 2
		
		With lblReplace
			.Name = "lblReplace"
			.Text = ML("Replace")+":"
			.TabIndex = 2
			.SetBounds 10, 41, 82, 25
			.Parent =  @This
		End With
		
		' txtReplace
		With txtReplace
			.Name = "txtReplace"
			.Text = ""
			.TabIndex = 3
			.SetBounds 97, 38, 318, 26
			.Anchor.Left = asAnchor
			.Anchor.Right = asAnchor
			.Parent = @This
		End With
		' chkUsePatternMatching
		With chkUsePatternMatching
			.Name = "chkUsePatternMatching"
			.Text = ML("Use Pattern Matching")
			.TabIndex = 8
			.Caption = ML("Use Pattern Matching")
			.SetBounds 252, 63, 150, 22
			.Parent = @Panel1
		End With
		' FolderDialog
		With FolderDialog
			.Name = "FolderDialog"
			.SetBounds 0, 0, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' chkWholeWordsOnly
		With chkWholeWordsOnly
			.Name = "chkWholeWordsOnly"
			.Text = ML("Find Whole Words Only")
			.TabIndex = 14
			.ControlIndex = 3
			.Caption = ML("Find Whole Words Only")
			.SetBounds 252, 38, 150, 22
			.Designer = @This
			.Parent = @Panel1
		End With
	End Constructor
	
	Private Sub frmFindInFiles._Form_Create(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		(*Cast(frmFindInFiles Ptr, Sender.Designer)).Form_Create(Sender)
	End Sub
	
	Destructor frmFindInFiles
		
	End Destructor
'#End Region

Sub frmFindInFiles.Find(ByRef lvSearchResult As ListView Ptr, ByRef Path As WString = "", ByRef tSearch As WString = "")
	Dim f As WString * 1024
	Dim Buffout As WString Ptr
	Dim As Integer Result, Pos1
	Dim Buff As WString * 1024 '
	Dim As Integer iLine, iStart, Fn
	Dim As UInteger Attr
	ThreadsEnter
	Dim As Boolean SearchInSub = chkSearchInSub.Checked
	Dim As Boolean MatchCase = chkMatchCase.Checked
	Dim As Boolean MatchWholeWords = chkWholeWordsOnly.Checked
	Dim As Boolean UsePatternMatching = chkUsePatternMatching.Checked
	ThreadsLeave
	Dim As WStringList Folders
	If Path = "" OrElse tSearch = "" Then Exit Sub
	If SearchInSub Then
		f = Dir(Path & Slash & "*", fbReadOnly Or fbHidden Or fbSystem Or fbDirectory Or fbArchive, Attr)
	Else
		f = Dir(Path & Slash & "*", fbReadOnly Or fbHidden Or fbSystem Or fbArchive, Attr)
	End If
	WLet(gSearchSave, tSearch)
	While f <> ""
		If FormClosing Then Exit Sub
		If (Attr And fbDirectory) <> 0 Then
			If f <> "." AndAlso f <> ".." Then Folders.Add Path & IIf(EndsWith(Path, Slash), "", Slash) & f
		ElseIf EndsWith(LCase(f), ".bas") OrElse EndsWith(LCase(f), ".bi") OrElse EndsWith(LCase(f), ".rc") _
			OrElse EndsWith(LCase(f), ".inc") OrElse EndsWith(LCase(f), ".frm") OrElse EndsWith(LCase(f), ".ini") _
			OrElse EndsWith(LCase(f), ".txt") OrElse EndsWith(LCase(f), ".log") OrElse EndsWith(LCase(f), ".lng") _
			OrElse EndsWith(LCase(f), ".vfp") OrElse EndsWith(LCase(f), ".vfs") OrElse EndsWith(LCase(f), ".xml") _
			OrElse EndsWith(LCase(f), ".c") OrElse EndsWith(LCase(f), ".h") OrElse EndsWith(LCase(f), ".cpp") OrElse EndsWith(LCase(f), ".java") Then
			Fn = FreeFile_
			Result = Open(Path & Slash & f For Input Encoding "utf-8" As #Fn)
			If Result <> 0 Then Result = Open(Path & Slash & f For Input Encoding "utf-16" As #Fn)
			If Result <> 0 Then Result = Open(Path & Slash & f For Input Encoding "utf-32" As #Fn)
			If Result <> 0 Then Result = Open(Path & Slash & f For Input As #Fn)
			If Result = 0 Then
				iLine = 0
				Do Until EOF(Fn)
					Line Input #Fn, Buff
					iLine += 1
					Pos1 = 0
					Do
						If UsePatternMatching Then
							If MatchCase Then
								Pos1 = InStrMatch(Buff, tSearch, Pos1 + 1)
							Else
								Pos1 = InStrMatch(LCase(Buff), LCase(tSearch), Pos1 + 1)
							End If
						ElseIf MatchCase Then
							Pos1 = InStr(Pos1 + 1, Buff, tSearch)
						Else
							Pos1 = InStr(Pos1 + 1, LCase(Buff), LCase(tSearch))
						End If
						If MatchWholeWords AndAlso Pos1 > 0 Then
							If IsNotAlpha(Mid(Buff, Pos1 - 1, 1)) AndAlso IsNotAlpha(Mid(Buff, Pos1 + Len(tSearch), 1)) Then Exit Do
						Else
							Exit Do
						End If
					Loop
					While Pos1 > 0
						ThreadsEnter
						lvSearchResult->ListItems.Add Buff
						lvSearchResult->ListItems.Item(lvSearchResult->ListItems.Count - 1)->Text(1) = WStr(iLine)
						lvSearchResult->ListItems.Item(lvSearchResult->ListItems.Count - 1)->Text(2) = WStr(Pos1)
						lvSearchResult->ListItems.Item(lvSearchResult->ListItems.Count - 1)->Text(3) = Path & IIf(EndsWith(Path, Slash), "", Slash) & f
						pfrmMain->Update
						ThreadsLeave
						Pos1 = Pos1 + Len(tSearch) - 1
						Do
							If UsePatternMatching Then
								If MatchCase Then
									Pos1 = InStrMatch(Buff, tSearch, Pos1 + 1)
								Else
									Pos1 = InStrMatch(LCase(Buff), LCase(tSearch), Pos1 + 1)
								End If
							ElseIf MatchCase Then
								Pos1 = InStr(Pos1 + 1, Buff, tSearch)
							Else
								Pos1 = InStr(Pos1 + 1, LCase(Buff), LCase(tSearch))
							End If
							If MatchWholeWords AndAlso Pos1 > 0 Then
								If IsNotAlpha(Mid(Buff, Pos1 - 1, 1)) AndAlso IsNotAlpha(Mid(Buff, Pos1 + Len(tSearch), 1)) Then Exit Do
							Else
								Exit Do
							End If
						Loop
					Wend
				Loop
			Else
				'MsgBox ML("Open file failure!") &  " " & ML("in function") & " frmFindInFiles.Find"  & WChr(13,10) & "  " & Path & f
			End If
			CloseFile_(Fn)
		End If
		f = Dir(Attr)
	Wend
	If SearchInSub Then
		For i As Integer = 0 To Folders.Count - 1
			Find lvSearchResult, Folders.Item(i), tSearch
		Next
	End If
	Folders.Clear
End Sub

Sub FindSub(Param As Any Ptr)
	ThreadsEnter
	tpFind->SelectTab
	plvSearch->ListItems.Clear
	StartProgress
	With fFindFile
		.btnFind.Enabled = False
		.txtPath.Text  = Replace(.txtPath.Text, BackSlash, Slash)
		If EndsWith(.txtPath.Text, Slash) = False Then .txtPath.Text =.txtPath.Text & Slash
		ThreadsLeave
		.Find plvSearch, .txtPath.Text, .txtFind.Text
		ThreadsEnter
		.btnFind.Enabled = True
	End With
	StopProgress
	tpFind->Caption = ML("Find") & " (" & plvSearch->ListItems.Count & " " & ML("Pos") & ")"
	ThreadsLeave
End Sub

Sub ReplaceSub(Param As Any Ptr)
	ThreadsEnter
	plvSearch->ListItems.Clear
	StartProgress
	With fFindFile
		.btnFind.Enabled = False
		.btnReplace.Enabled = False
		.txtPath.Text  = Replace(.txtPath.Text,BackSlash,Slash)
		If EndsWith(.txtPath.Text,Slash) = False Then .txtPath.Text =.txtPath.Text & Slash
		ThreadsLeave
		.ReplaceInFile .txtPath.Text, .txtFind.Text,.txtReplace.Text
		ThreadsEnter
		.btnFind.Enabled = True
		.btnReplace.Enabled = True
	End With
	StopProgress
	tpFind->Caption = ML("Replace") & " (" & plvSearch->ListItems.Count & " " & ML("Pos") & ")"
	ThreadsLeave
End Sub

Private Sub frmFindInFiles.btnFind_Click(ByRef Sender As Control)
	FindInFiles
End Sub

Private Sub frmFindInFiles.btnCancel_Click(ByRef Sender As Control)
	This.CloseForm
End Sub

Private Sub frmFindInFiles.btnBrowse_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	fFindFile.FolderDialog.InitialDir = GetFullPath(fFindFile.txtPath.Text)
	If fFindFile.FolderDialog.Execute Then
		fFindFile.txtPath.Text = fFindFile.FolderDialog.Directory
	End If
End Sub

Private Sub frmFindInFiles.Form_Show(ByRef Sender As Form)
	fFindFile.txtFind.SelectAll
	fFindFile.txtFind.SetFocus
End Sub

Private Sub frmFindInFiles.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	If 1 Then
		
	End If
End Sub
Private Sub frmFindInFiles.btnReplace_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	ReplaceInFiles
End Sub
Private Sub frmFindInFiles.ReplaceInFile(ByRef Path As WString ="", ByRef tSearch As WString="", ByRef tReplace As WString="")
	Dim f As WString * 255
	Dim BuffOut As WString Ptr
	Dim FNameOpen As WString * 255
	Dim As Integer Result, Pos1
	Dim Buff As WString * 1024
	Dim As Integer iLine, iStart
	Dim As Integer Attr, Fn
	Dim As WStringList Folders
	Dim MLString As WString * 255
	Dim SubStr() As WString Ptr
	Dim As WString Ptr Temp
	Dim As WString * 5 tML = WChr(77) & WChr(76) & WChr(40)& WChr(34)
	If Path = "" OrElse tSearch="" OrElse (tSearch = tReplace AndAlso LCase(tML) <> LCase(tReplace)) Then Exit Sub
	If LCase(tSearch) = LCase(tReplace) Then WLet(BuffOut, "File")
	If chkSearchInSub.Checked Then
		f = Dir(Path & "*", fbReadOnly Or fbHidden Or fbSystem Or fbDirectory Or fbArchive, Attr)
	Else
		f = Dir(Path & "*", fbReadOnly Or fbHidden Or fbSystem Or fbArchive, Attr)
	End If
	WLet(gSearchSave, tSearch)
	While f <> ""
		If (Attr And fbDirectory) <> 0 Then
			If f <> "." AndAlso f <> ".." Then Folders.Add  Path & f
		ElseIf EndsWith(LCase(f), ".bas") OrElse EndsWith(LCase(f), ".bi") OrElse EndsWith(LCase(f), ".rc") _
			OrElse EndsWith(LCase(f), ".inc") OrElse EndsWith(LCase(f), ".frm") _
			OrElse EndsWith(LCase(f), ".txt") OrElse EndsWith(LCase(f), ".log") OrElse EndsWith(LCase(f), ".lng") _
			OrElse EndsWith(LCase(f), ".vfp") OrElse EndsWith(LCase(f), ".vfs") OrElse EndsWith(LCase(f), ".xml") _
			OrElse EndsWith(LCase(f), ".c") OrElse EndsWith(LCase(f), ".h") OrElse EndsWith(LCase(f), ".cpp") OrElse EndsWith(LCase(f), ".java") Then
			If LCase(tML) <> LCase(tReplace) Then
				FNameOpen = GetBakFileName(Path & f)
				' https://www.freebasic.net/forum/viewtopic.php?f=2&t=27370&p=257529&hilit=FileCopy#p257529
				#ifdef __USE_GTK__
					FileCopy  Path & f, FNameOpen  'Function FileCopy suport unicode file name, But FileExist  is Ok in linux
				#else
					CopyFileW Path & f, FNameOpen, False
				#endif
			Else
				FNameOpen = Path & f
			End If
			Fn = FreeFile_
			Result = Open(FNameOpen For Input Encoding "utf-8" As #Fn)
			If Result <> 0 Then Result = Open(FNameOpen For Input Encoding "utf-16" As #Fn)
			If Result <> 0 Then Result = Open(FNameOpen For Input Encoding "utf-32" As #Fn)
			If Result <> 0 Then Result = Open(FNameOpen For Input As #Fn)
			If Result = 0 Then
				iLine = 0
				If LCase(tSearch) <> LCase(tReplace) Then WLet(BuffOut, "")
				Do Until EOF(Fn)
					Line Input #Fn, Buff
					iLine += 1
					If chkMatchCase.Checked Then
						Pos1 = InStr(Buff, tSearch)
					Else
						Pos1 = InStr(LCase(Buff), LCase(tSearch))
					End If
					If Pos1 > 0 Then
						If LCase(tSearch) = LCase(tReplace) Then
							Var NumS = StringSubStringAll(Buff,tML, WChr(34) & ")",SubStr())
							For i As Integer =0 To NumS-1
								If InStr(*BuffOut, WChr(13,10) & *SubStr(i))<=0 Then
									WAdd BuffOut, WChr(13,10) & *SubStr(i)
									If InStr(*SubStr(i), "&")>0 Then WAdd BuffOut, WChr(13,10) & Replace(*SubStr(i),"&","")
								End If
							Next
							#ifndef __USE_MAKE__
								WDeAllocateEx(SubStr())
							#endif
						Else
							If *BuffOut="" Then
								WLet(BuffOut, Replace(Buff, tSearch, tReplace,,,chkMatchCase.Checked))
							Else
								WAdd BuffOut, WChr(13,10) & Replace(Buff, tSearch, tReplace,,, chkMatchCase.Checked)
							End If
						End If
					ElseIf LCase(tSearch) <> LCase(tReplace) Then
						If *BuffOut="" Then
							WLet(BuffOut, Buff)
						Else
							WAdd BuffOut, WChr(13,10) & Buff
						End If
					End If
					While Pos1 > 0
						ThreadsEnter
						plvSearch->ListItems.Add Buff
						plvSearch->ListItems.Item(plvSearch->ListItems.Count - 1)->Text(1) = WStr(iLine)
						plvSearch->ListItems.Item(plvSearch->ListItems.Count - 1)->Text(2) = WStr(Pos1)
						plvSearch->ListItems.Item(plvSearch->ListItems.Count - 1)->Text(3) =  Path & f
						pfrmMain->Update
						ThreadsLeave
						Pos1 = InStr(Pos1 + Len(tSearch), LCase(Buff), LCase(tSearch))
					Wend
				Loop
				If LCase(tSearch) <> LCase(tReplace) Then
					Var Fn1 = FreeFile_
					If Open(Path & f For Output Encoding "utf-8" As #Fn1) = 0 Then
						Print #Fn1, *BuffOut
					Else
						MsgBox ML("Open file failure!") & " " & ML("in function") & " frmFindInFiles.ReplaceInFile" & WChr(13,10) & "  " & Path & f
					End If
					CloseFile_(Fn1)
				End If
			End If
			CloseFile_(Fn)
		End If
		f = Dir(Attr)
	Wend
	If chkSearchInSub.Checked Then
		For i As Integer = 0 To Folders.Count - 1
			ReplaceInFile Folders.Item(i), tSearch, tReplace
		Next
	End If
	txtReplace.Text = ""
	If LCase(tML) = LCase(tReplace) Then
		Fn = FreeFile_
		If Open(ExePath & "\Languages.txt" For Output Encoding "utf-8" As #Fn) = 0 Then
			Print #Fn, *BuffOut
		End If
		CloseFile_(Fn)
	End If
	WDeAllocate(BuffOut)
	Folders.Clear
	WDeAllocate(Temp)
End Sub

Private Sub frmFindInFiles.Form_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	fFindFile.Panel1.Height =NewHeight - 30
	fFindFile.Panel1.Width = NewWidth - 25
End Sub

Private Sub frmFindInFiles.Form_Create(ByRef Sender As Control)
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	' for limited the Muilti line
	Var Posi = InStr(Clipboard.GetAsText, WChr(13)) - 1
	If Posi < 1 Then Posi = InStr(Clipboard.GetAsText, WChr(10)) - 1
	If Posi < 1 Then Posi = Len(Clipboard.GetAsText)
	fFindFile.txtFind.Text = ..Left(Clipboard.GetAsText, Posi)
	If tb <> 0 AndAlso tb->FileName <> "" Then
		fFindFile.txtPath.Text = GetFolderName(tb->FileName)
	Else
		fFindFile.txtPath.Text = ExePath
	End If
	fFindFile.Panel1.Top = IIf(mFormFindInFile, 35, 64)
	fFindFile.Height=IIf(mFormFindInFile,208,236)
	fFindFile.Caption=IIf(mFormFindInFile,ML("Find In Files"),ML("Replace In Files"))
	fFindFile.btnReplace.Visible =Not mFormFindInFile
	fFindFile.lblReplace.Visible =Not mFormFindInFile
	fFindFile.txtReplace.Visible =Not mFormFindInFile
End Sub
