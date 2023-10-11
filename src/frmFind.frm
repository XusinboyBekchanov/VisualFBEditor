'#########################################################
'#  frmFind.bas                                          #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "frmFind.bi"
Dim Shared As frmFind fFind
pfFind = @fFind

'#Region "Form"
	
	Constructor frmFind
		'frmFind
		With This
			.Name = "frmFind"
			.Opacity = 210
			.Caption = ML("Find")
			#ifdef __USE_GTK__
				.Icon.LoadFromFile(ExePath & "/Resources/VisualFBEditor.ico")
			#else
				.BorderStyle = FormBorderStyle.FixedDialog
				.Icon.LoadFromResourceID(1)
			#endif
			.MinimizeBox = False
			.MaximizeBox = False
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnShow = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form), @Form_Show)
			.DefaultButton = @btnFind
			.CancelButton = @btnCancel
			.Designer = @This
			.SetBounds 0, 0, 433, 85
		End With
		'btnReplaceShow
		With btnReplaceShow
			.Name = "btnReplaceShow"
			.Text = "˅"
			.TabIndex = 0
			.Hint = ML("Expand to Replace Mode")
			.SetBounds 3, 2, 16, 21
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @btnReplaceShow_Click)
			.Designer = @This
			.Parent = @This
		End With
		'lblFind
		With lblFind
			.Name = "lblFind"
			.TabIndex = 1
			.Alignment = AlignmentConstants.taRight
			.SetBounds 22, 4, 45, 16
			.Text = ML("Find") & ":"
			.Designer = @This
			.Parent = @This
		End With
		'txtFind
		With txtFind
			.Name = "txtFind"
			.Style = cbDropDown
			.TabIndex = 2
			.SetBounds 69, 1, 140, 21
			.Text = ""
			.Designer = @This
			.Parent = @This
		End With
		'cboFindRange
		With cboFindRange
			.Name = "cboFindRange"
			.Text = "cboFindRange"
			.AddItem ML("Procedure")
			.AddItem ML("Module")
			.AddItem ML("Project")
			.AddItem ML("Selected")
			.TabIndex = 3
			.Hint = ML("Find Range")
			.SetBounds 213, 1, 66, 21
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @cboFindRange_Selected)
			.Designer = @This
			.Parent = @This
		End With
		'chkMatchCase
		With chkMatchCase
			.Name = "chkMatchCase"
			.TabIndex = 4
			.Hint = ML("Match Case")
			.SetBounds 284, 1, 30, 21
			.Text = "Aa"
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox), @chkBox_Click)
			.Parent = @This
		End With
		'chkMatchWholeWords
		With chkMatchWholeWords
			.Name = "chkMatchWholeWords"
			.Text = "W"
			.TabIndex = 5
			.Hint = ML("Match Whole Words")
			.SetBounds 316, 1, 30, 21
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox), @chkBox_Click)
			.Parent = @This
		End With
		'chkUsePatternMatching
		With chkUsePatternMatching
			.Name = "chkUsePatternMatching"
			.Text = ".*"
			.TabIndex = 6
			.Hint = ML("Use Pattern Matching")
			.Caption = ".*"
			.SetBounds 345, 1, 30, 21
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox), @chkBox_Click)
			.Parent = @This
		End With
		'btnFindPrev
		With btnFindPrev
			.Name = "btnFindPrev"
			.Text = "<"
			.TabIndex = 7
			.Hint = ML("Find Previous") & " (" & HK("Find Previous", "Shift + F3") & ")"
			.SetBounds 376, 1, 25, 22
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @btnFindPrev_Click)
			.Designer = @This
			.Parent = @This
		End With
		'btnFind
		With btnFind
			.Name = "btnFind"
			.Text = ">"
			.Default = True
			.TabIndex = 8
			.Hint = ML("Find Next") & " (" & HK("Find Next", "F3") & ")"
			.SetBounds 403, 1, 25, 21
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @btnFind_Click)
			.Designer = @This
			.Parent = @This
		End With
		'lblTrack
		With lblTrack
			.Name = "lblTrack"
			.TabIndex = 9
			.Alignment = AlignmentConstants.taCenter
			.Hint = ML("Find Form Opacity")
			.SetBounds 4, 30, 16, 11
			.Designer = @This
			.Parent = @This
		End With
		'TrackBar1
		
		With TrackBar1
			.Name = "TrackBar1"
			.Text = "TrackBar1"
			.MinValue = 100
			.MaxValue = 255
			.TabIndex = 10
			.Style = TrackBarOrientation.tbHorizontal
			.Hint = ML("Find Form Opacity")
			.SetBounds -2, 42, 27, 10
			.Position = 210 'This.Opacity
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TrackBar, Position As Integer), @TrackBar1_Change)
			.Designer = @This
			.Parent = @This
		End With
		'lblReplace
		With lblReplace
			.Name = "lblReplace"
			.Text = ML("Replace") & ":"
			.TabIndex = 11
			.Alignment = AlignmentConstants.taRight
			.SetBounds 22, 35, 45, 16
			.Designer = @This
			.Parent = @This
		End With
		'txtReplace
		With txtReplace
			.Name = "txtReplace"
			.Style = cbDropDown
			.Text = ""
			.TabIndex = 12
			.SetBounds 69, 32, 140, 21
			.Designer = @This
			.Parent = @This
		End With
		'btnReplace
		With btnReplace
			.Name = "btnReplace"
			.Text = ML("&Replace")
			.TabIndex = 13
			.Hint = ML("Replace")
			.SetBounds 212, 32, 110, 22
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @btnReplace_Click)
			.Designer = @This
			.Parent = @This
		End With
		'btnReplaceAll
		With btnReplaceAll
			.Name = "btnReplaceAll"
			.Text = ML("Replace &All")
			.TabIndex = 14
			.Hint = ML("Replace All")
			.SetBounds 326, 32, 102, 22
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @btnReplaceAll_Click)
			.Designer = @This
			.Parent = @This
		End With
		
		'btnFindAll
		With btnFindAll
			.Name = "btnFindAll"
			.Text = ML("All")
			.TabIndex = 15
			.Hint = ML("Find All")
			.Visible = False
			.SetBounds 480, 3, 25, 23
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @btnFindAll_Click)
			.Designer = @This
			.Parent = @This
		End With
		'btnCancel
		With btnCancel
			.Name = "btnCancel"
			.Text = ML("&Cancel")
			.TabIndex = 16
			.SetBounds 250, 500, 100, 30
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @btnCancel_Click)
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Destructor frmFind
		
	End Destructor
	
	#ifndef _NOT_AUTORUN_FORMS_
		fFind.Show
		App.Run
	#endif
'#End Region

Public Function frmFind.Find(Down As Boolean, bNotShowResults As Boolean = False) As Integer
	If txtFind.Text = "" OrElse mTabSelChangeByError Then Exit Function
	If CInt(*gSearchSave <> txtFind.Text OrElse plvSearch->ListItems.Count < 1) AndAlso CInt(cboFindRange.ItemIndex = 2) Then FindAll plvSearch, tpFind, , False : WLet(gSearchSave, txtFind.Text)
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Function
	Dim txt As EditControl Ptr = @tb->txtCode
	Dim Result As Integer
	Dim As Boolean bMatchCase = chkMatchCase.Checked
	Dim buff As WString Ptr
	Dim As Integer i, SearchCount, SearchLen
	If CInt(*gSearchSave <> txtFind.Text OrElse plvSearch->ListItems.Count < 1) OrElse CInt(tb > 0 AndAlso tb->txtCode.ModifiedLine = True AndAlso cboFindRange.ItemIndex < 2) Then FindAll plvSearch, tpFind, , False : WLet(gSearchSave, txtFind.Text): tb->txtCode.ModifiedLine = False
	If plvSearch->ListItems.Count < 1 Then This.Caption = ML("Find: No Results") : Return -1
	If cboFindRange.ItemIndex = 1 OrElse cboFindRange.ItemIndex = 2 Then
		iSelStartLine = 0: iSelEndLine = tb->txtCode.LinesCount - 1: iSelStartChar = 0: iSelEndChar = Len(tb->txtCode.Lines(iSelEndLine))
	ElseIf cboFindRange.ItemIndex = 0 Then
		tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar, cboFindRange.ItemIndex = 0 OrElse cboFindRange.ItemIndex = 3
	End If
	Dim As ListViewItem Ptr Item
	SearchCount = plvSearch->ListItems.Count - 1
	SearchLen = Len(*gSearchSave)
	If gSearchItemIndex < 0 OrElse gSearchItemIndex > SearchCount Then gSearchItemIndex = 0
	plvSearch->SelectedItemIndex = gSearchItemIndex
	If Down Then
		If bNotShowResults Then
			iStartChar = 1
			iStartLine = 0
		Else
			If CBool(SearchCount >= 0) AndAlso CBool(plvSearch->SelectedItemIndex = SearchCount) Then
				If mFormFind Then
					Item = plvSearch->ListItems.Item(SearchCount)
					gSearchItemIndex = 0
					plvSearch->SelectedItemIndex = 0
					Item = plvSearch->ListItems.Item(gSearchItemIndex)
					SelectSearchResult(Item->Text(3), Val(Item->Text(1)), -1, -1, Item->Tag, *gSearchSave)
					Return Val(Item->Text(2))
				End If
			Else
				Dim As Integer SelStartLine, SelEndLine, SelStartChar, SelEndChar
				txt->GetSelection SelStartLine, SelEndLine, SelStartChar, SelEndChar
				iStartChar = SelEndChar + 1
				iStartLine = SelEndLine
			End If
		End If
		For i = iStartLine To iSelEndLine
			buff = @txt->Lines(i)
			If bMatchCase Then
				Result = InStr(iStartChar, *buff, *gSearchSave)
			Else
				Result = InStr(iStartChar, LCase(*buff), LCase(*gSearchSave))
			End If
			If Result > 0 Then Exit For
			iStartChar = 1
		Next i
	Else
		If bNotShowResults Then
			iStartLine = txt->LinesCount - 1
			iStartChar = Len(txt->Lines(iStartLine))
		Else
			If SearchCount >= 0 AndAlso plvSearch->SelectedItemIndex = 0 Then
				gSearchItemIndex = SearchCount
				plvSearch->SelectedItemIndex = SearchCount
				Dim As Integer tIndex = Max(gSearchItemIndex, 0)
				Item = plvSearch->ListItems.Item(tIndex)
				SelectSearchResult(Item->Text(3), Val(Item->Text(1)), Val(Item->Text(2)), SearchLen, Item->Tag, *gSearchSave)
				Return Val(Item->Text(2))
			Else
				Dim As Integer SelStartLine, SelEndLine, SelStartChar, SelEndChar
				txt->GetSelection SelStartLine, SelEndLine, SelStartChar, SelEndChar
				iStartLine = SelStartLine
				iStartChar = SelStartChar
			End If
		End If
		For i = iStartLine To iSelStartLine Step -1
			buff = @txt->Lines(i)
			If i <> iStartLine Then iStartChar = Len(*buff)
			If bMatchCase Then
				Result = InStrRev(*buff, *gSearchSave, iStartChar)
			Else
				Result = InStrRev(LCase(*buff), LCase(*gSearchSave), iStartChar)
			End If
			If Result > 0 Then Exit For
		Next i
	End If
	If Result > 0 Then
		txt->SetSelection i, i, Result - 1, Result + Len(*gSearchSave) - 1
		If SearchCount >= 0 Then
			Dim As Integer jj, iPos, RowIndexFirst
			If Down Then
				For jj = gSearchItemIndex To 0 Step -1
					If CBool(Val(plvSearch->ListItems.Item(jj)->Text(1)) < i + 1) AndAlso CBool(plvSearch->ListItems.Item(jj)->Text(3) = tb->FileName) Then jj += 1 : Exit For
				Next
				RowIndexFirst = Max(jj, 0)
				For jj = RowIndexFirst To SearchCount
					If CBool(Val(plvSearch->ListItems.Item(jj)->Text(1)) >= i + 1) AndAlso CBool(plvSearch->ListItems.Item(jj)->Text(3) = tb->FileName) Then Exit For
				Next
				If jj > SearchCount Then
					For jj = RowIndexFirst To 0 Step -1
						If CBool(Val(plvSearch->ListItems.Item(jj)->Text(1)) < i + 1) AndAlso CBool(plvSearch->ListItems.Item(jj)->Text(3) = tb->FileName) Then jj += 1 : Exit For
					Next
				End If
			Else
				For jj = gSearchItemIndex To SearchCount
					If CBool(Val(plvSearch->ListItems.Item(jj)->Text(1)) >= i + 1) AndAlso CBool(plvSearch->ListItems.Item(jj)->Text(3) = tb->FileName) Then Exit For
				Next
				RowIndexFirst = Min(jj, SearchCount)
				For jj = RowIndexFirst To 0 Step -1
					If CBool(Val(plvSearch->ListItems.Item(jj)->Text(1)) < i + 1) AndAlso CBool(plvSearch->ListItems.Item(jj)->Text(3) = tb->FileName) Then jj += 1 : Exit For
				Next
				If jj < 0 Then
					RowIndexFirst = 0
					For jj = RowIndexFirst To SearchCount
						If CBool(Val(plvSearch->ListItems.Item(jj)->Text(1)) >= i + 1) AndAlso CBool(plvSearch->ListItems.Item(jj)->Text(3) = tb->FileName) Then Exit For
					Next
				End If
			End If
			If jj > SearchCount OrElse jj < 0 Then
				gSearchItemIndex = 0 : iPos = -1
				i = Val(plvSearch->ListItems.Item(gSearchItemIndex)->Text(1)) - 1
				Result = Val(plvSearch->ListItems.Item(gSearchItemIndex)->Text(2))
				txt->SetSelection i, i, Result - 1, Result + Len(*gSearchSave) - 1
			Else
				gSearchItemIndex = jj
			End If
			'Update the value of Row and Col in plvSearch whatever it was changed or not.
			'Continue find in the same line.
			Do While iPos >= 0
				If bMatchCase Then
					iPos = InStr(iPos + 1, txt->Lines(i), *gSearchSave)
				Else
					iPos = InStr(iPos + 1, LCase(txt->Lines(i)), LCase(*gSearchSave))
				End If
				If iPos > 0 Then
					If iPos = Result Then gSearchItemIndex = jj
					If CBool(jj <= SearchCount) AndAlso CBool(plvSearch->ListItems.Item(jj)->Text(1) = Str(i + 1)) AndAlso CBool(plvSearch->ListItems.Item(jj)->Text(3) = tb->FileName) Then
						plvSearch->ListItems.Item(jj)->Text(1) = Str(i + 1)
						plvSearch->ListItems.Item(jj)->Text(2) = Str(iPos)
						If CBool(Val(plvSearch->ListItems.Item(jj)->Text(1)) = i + 1) Then jj += 1 Else Exit Do
					Else
						If plvSearch->ListItems.Item(jj)->Text(1) <> Str(i + 1) Then
							plvSearch->ListItems.Insert(jj, txt->Lines(i)) 'Add the new finding
							SearchCount = plvSearch->ListItems.Count - 1
						End If
						plvSearch->ListItems.Item(jj)->Text(1) = Str(i + 1)
						plvSearch->ListItems.Item(jj)->Text(2) = Str(iPos)
						plvSearch->ListItems.Item(jj)->Text(3) = tb->FileName
						Exit Do
					End If
				Else
					'Remove the extra line if insert some line after searching
					If jj <= SearchCount AndAlso jj > 0 Then
						For ii As Integer  = jj To SearchCount
							If ii > plvSearch->ListItems.Count - 1 Or ii < 0 Then Exit For
							Item = plvSearch->ListItems.Item(ii)
							If CBool(Val(Item->Text(1)) - 1 < txt->LinesCount) AndAlso CBool(Mid(txt->Lines(Val(Item->Text(1)) - 1), Val(Item->Text(2)), SearchLen) <> *gSearchSave) AndAlso CBool(Item->Text(3) = tb->FileName) Then
								plvSearch->ListItems.Remove ii
								SearchCount = plvSearch->ListItems.Count - 1
							ElseIf CBool(Val(Item->Text(1)) <> i + 1) OrElse CBool(Item->Text(3) <> tb->FileName) Then
								Exit Do
							End If
						Next
					End If
					Exit Do
				End If
			Loop
			plvSearch->SelectedItemIndex = gSearchItemIndex
		End If
	Else
		gSearchItemIndex = plvSearch->SelectedItemIndex
		If plvSearch->ListItems.Count < 1 Then This.Caption = ML("Find: No Results") : Return -1
		If mFormFind Then gSearchItemIndex = IIf(Down, gSearchItemIndex + 1, gSearchItemIndex - 1)
		If gSearchItemIndex < 0 Then
			gSearchItemIndex = SearchCount
		ElseIf gSearchItemIndex > SearchCount Then
			gSearchItemIndex = 0
		End If
		plvSearch->SelectedItemIndex = gSearchItemIndex
		FFileName = plvSearch->ListItems.Item(gSearchItemIndex)->Text(3)
		Item = plvSearch->ListItems.Item(gSearchItemIndex)
		SelectSearchResult(Item->Text(3), Val(Item->Text(1)), -1, -1, Item->Tag, *gSearchSave)
		Return Val(Item->Text(2))
	End If
	Return Result
End Function

Sub frmFind.FindInProj(ByRef lvSearchResult As ListView Ptr, ByRef tSearch As WString="", ByRef tn As TreeNode Ptr)
	Dim As WString * MAX_PATH f
	Dim As WString Ptr Buffout
	Dim As Integer Result, Pos1, Pos2
	Dim As WString * 1024 Buff
	Dim As Integer iLine, iStart, Fn
	If tSearch = "" OrElse tn < 1 Then Exit Sub
	For i As Integer = 0 To tn->Nodes.Count - 1
		If FormClosing Then Exit For
		If tn->Nodes.Item(i)->ImageKey = "Opened" Then
			fFind.FindInProj lvSearchResult, tSearch, tn->Nodes.Item(i)
		Else
			If tn->Nodes.Item(i)->Tag <> 0 Then
				f = *Cast(ExplorerElement Ptr, tn->Nodes.Item(i)->Tag)->FileName
				If EndsWith(LCase(f), ".bas") OrElse EndsWith(LCase(f), ".bi") OrElse EndsWith(LCase(f), ".rc") OrElse EndsWith(LCase(f), ".inc") _
					OrElse EndsWith(LCase(f), ".txt") OrElse EndsWith(LCase(f), ".frm") OrElse EndsWith(LCase(f), ".html") _
					OrElse EndsWith(LCase(f), ".vfp") OrElse EndsWith(LCase(f), ".htm") OrElse EndsWith(LCase(f), ".xml") OrElse EndsWith(LCase(f), ".cs") OrElse EndsWith(LCase(f), ".vb")  _
					OrElse EndsWith(LCase(f), ".c") OrElse EndsWith(LCase(f), ".h") OrElse EndsWith(LCase(f), ".cpp") OrElse EndsWith(LCase(f), ".java") Then
					Result = -1: Fn = FreeFile_
					Result = Open(f For Input Encoding "utf-8" As #Fn)
					If Result <> 0 Then Result = Open(f For Input Encoding "utf-16" As #Fn)
					If Result <> 0 Then Result = Open(f For Input Encoding "utf-32" As #Fn)
					If Result <> 0 Then Result = Open(f For Input As #Fn)
					If Result = 0 Then
						iLine = 0
						Do Until EOF(Fn)
							Line Input #Fn, Buff
							iLine += 1
							If lvSearchResult = @lvToDo Then
								Pos1 = InStr(LCase(Buff), "'" + "todo")
								Pos2 = InStr(LCase(Buff), "'" + "fixme")
								If Pos1 > 0 OrElse Pos2 > 0 Then
									ThreadsEnter
									lvToDo.ListItems.Add Buff, IIf(Pos1 > 0, "Bookmark", "Fixme")
									lvToDo.ListItems.Item(lvSearchResult->ListItems.Count - 1)->Text(1) = WStr(iLine)
									lvToDo.ListItems.Item(lvSearchResult->ListItems.Count - 1)->Text(2) = WStr(Pos1)
									lvToDo.ListItems.Item(lvSearchResult->ListItems.Count - 1)->Text(3) = f
									pfrmMain->Update
									ThreadsLeave
								End If
							Else
								If chkMatchCase.Checked Then
									Pos1 = InStr(Buff, tSearch)
								Else
									Pos1 = InStr(LCase(Buff), LCase(tSearch))
								End If
								While Pos1 > 0
									ThreadsEnter
									lvSearchResult->ListItems.Add Buff, "Bookmark"
									lvSearchResult->ListItems.Item(lvSearchResult->ListItems.Count - 1)->Text(1) = WStr(iLine)
									lvSearchResult->ListItems.Item(lvSearchResult->ListItems.Count - 1)->Text(2) = WStr(Pos1)
									lvSearchResult->ListItems.Item(lvSearchResult->ListItems.Count - 1)->Text(3) = f
									pfrmMain->Update
									ThreadsLeave
									Pos1 = InStr(Pos1 + Len(tSearch), LCase(Buff), LCase(tSearch))
								Wend
							End If
						Loop
					Else
						'MsgBox ML("Open file failure!") &  " " & ML("in function") & " frmFindInFiles.Find"  & Chr(13,10) & "  " & Path & f
					End If
					CloseFile_(Fn)
				End If
			End If
		End If
	Next
End Sub

Private Sub frmFind.ReplaceInProj(ByRef tSearch As WString="", ByRef tReplace As WString="", ByRef tn As TreeNode Ptr)
	Dim BuffOut As WString Ptr
	Dim As WString * MAX_PATH FNameOpen, f
	Dim As Integer Result, Pos1
	Dim As WString * 1024 Buff
	Dim As Integer iLine, iStart
	Dim As Integer Fn
	Dim SubStr() As WString Ptr
	Dim As WString * 5 tML = WChr(77) & WChr(76) & WChr(40)& WChr(34)
	If tSearch = "" OrElse tn < 1 Then Exit Sub
	If LCase(tSearch) = LCase(tReplace) Then WLet(BuffOut, "File")
	For i As Integer = 0 To tn->Nodes.Count - 1
		If tn->Nodes.Item(i)->ImageKey = "Opened" Then
			fFind.ReplaceInProj tSearch, tReplace, tn->Nodes.Item(i)
		Else
			If tn->Nodes.Item(i)->Tag <> 0 Then
				f = *Cast(ExplorerElement Ptr, tn->Nodes.Item(i)->Tag)->FileName
				If EndsWith(LCase(f), ".bas") OrElse EndsWith(LCase(f), ".bi") OrElse EndsWith(LCase(f), ".rc") OrElse EndsWith(LCase(f), ".inc") _
					OrElse EndsWith(LCase(f), ".txt") OrElse EndsWith(LCase(f), ".frm") OrElse EndsWith(LCase(f), ".html") _
					OrElse EndsWith(LCase(f), ".vfp") OrElse EndsWith(LCase(f), ".htm") OrElse EndsWith(LCase(f), ".xml") OrElse EndsWith(LCase(f), ".cs") OrElse EndsWith(LCase(f), ".vb") _
					OrElse EndsWith(LCase(f), ".c") OrElse EndsWith(LCase(f), ".h") OrElse EndsWith(LCase(f), ".cpp") OrElse EndsWith(LCase(f), ".java") Then
					If LCase(tML) <> LCase(tReplace) Then
						FNameOpen = GetBakFileName(f)
						'David Change https://www.freebasic.net/forum/viewtopic.php?f=2&t=27370&p=257529&hilit=FileCopy#p257529
						#ifdef __USE_GTK__
							FileCopy  f, FNameOpen  'Function FileCopy suport unicode file name in Linux, but And FileExist Do Not working properly.
						#else
							CopyFileW f, FNameOpen, False
						#endif
					Else
						FNameOpen = f
					End If
					Result = -1: Fn = FreeFile_
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
										If InStr(*BuffOut, Chr(13,10) & *SubStr(i))<=0 Then
											WAdd BuffOut, Chr(13,10) & *SubStr(i)
											If InStr(*SubStr(i), "&")>0 Then WAdd BuffOut, Chr(13,10) & Replace(*SubStr(i),"&","")
										End If
										Deallocate SubStr(i): SubStr(i)=0
									Next
									Erase SubStr
								Else
									If *BuffOut="" Then
										WLet(BuffOut, Replace(Buff, tSearch, tReplace, , , chkMatchCase.Checked))
									Else
										WAdd BuffOut, Chr(13,10) & Replace(Buff, tSearch, tReplace,,, chkMatchCase.Checked)
									End If
								End If
							ElseIf LCase(tSearch) <> LCase(tReplace) Then
								If *BuffOut="" Then
									WLet(BuffOut, Buff)
								Else
									WAdd BuffOut, Chr(13,10) & Buff
								End If
							End If
							While Pos1 > 0
								ThreadsEnter
								plvSearch->ListItems.Add Buff
								plvSearch->ListItems.Item(plvSearch->ListItems.Count - 1)->Text(1) = WStr(iLine)
								plvSearch->ListItems.Item(plvSearch->ListItems.Count - 1)->Text(2) = WStr(Pos1)
								plvSearch->ListItems.Item(plvSearch->ListItems.Count - 1)->Text(3) =  f
								pfrmMain->Update
								ThreadsLeave
								Pos1 = InStr(Pos1 + Len(tSearch), LCase(Buff), LCase(tSearch))
							Wend
						Loop
						If LCase(tSearch) <> LCase(tReplace) Then
							Var Fn1 = FreeFile_
							If Open(f For Output Encoding "utf-8" As #Fn1) = 0 Then
								Print #Fn1, *BuffOut
							Else
								MsgBox ML("Open file failure!") & " " & ML("in function") & " frmFindInFiles.ReplaceInFile" & Chr(13,10) & "  " & f
							End If
							CloseFile_(Fn1)
						End If
					End If
					CloseFile_(Fn)
				End If
			End If
		End If
	Next
	
	If LCase(tML) = LCase(tReplace) Then
		Fn = FreeFile_
		If Open(ExePath & "\Languages.txt" For Output Encoding "utf-8" As #Fn) = 0 Then
			Print #Fn, *BuffOut
		End If
		CloseFile_(Fn)
	End If
	Deallocate BuffOut
End Sub

Sub FindSubProj(Param As Any Ptr)
	MutexLock tlockToDo
	ThreadsEnter
	StartProgress
	With fFind
		.btnFind.Enabled = False
		.btnFindPrev.Enabled = False
		.btnReplace.Enabled = False
		.btnReplaceAll.Enabled = False
		ThreadsLeave
		If *gSearchSave = WChr(39) + WChr(84) + "ODO" Then
			ThreadsEnter
			plvToDo->ListItems.Clear
			ThreadsLeave
			.FindInProj plvToDo, *gSearchSave, Cast(TreeNode Ptr,Param)
		Else
			ThreadsEnter
			plvSearch->ListItems.Clear
			ThreadsLeave
			.FindInProj plvSearch, .txtFind.Text, Cast(TreeNode Ptr,Param)
		End If
		ThreadsEnter
		.btnFind.Enabled = True
		.btnFindPrev.Enabled = True
		.btnReplace.Enabled = True
		.btnReplaceAll.Enabled = True
		StopProgress
		If *gSearchSave = WChr(39)+ WChr(84)+"ODO" Then
			tpToDo->Caption = ML("ToDo") & " (" & plvToDo->ListItems.Count & " " & ML("Pos") & ")"
			WLet(gSearchSave, "")
			.cboFindRange.ItemIndex = 2
		Else
			WLet(gSearchSave, .txtFind.Text)
			tpFind->Caption = ML("Find") & " (" & plvSearch->ListItems.Count & " " & ML("Pos") & ")"
		End If
		If .Visible Then 'David Change
			.Caption = ML("Find") + ": " + WStr(gSearchItemIndex + 1) + " of " + WStr(plvSearch->ListItems.Count)
		End If
	End With
	ThreadsLeave
	MutexUnlock tlockToDo
End Sub

Sub ReplaceSubProj(Param As Any Ptr)
	MutexLock tlockToDo
	ThreadsEnter
	plvSearch->ListItems.Clear
	StartProgress
	fFind.btnFind.Enabled = False
	fFind.btnFindPrev.Enabled = False
	fFind.btnReplace.Enabled = False
	fFind.btnReplaceAll.Enabled = False
	ThreadsLeave
	fFind.ReplaceInProj fFind.txtFind.Text, fFind.txtReplace.Text, Cast(TreeNode Ptr, Param)
	ThreadsEnter
	fFind.btnFind.Enabled = True
	fFind.btnFindPrev.Enabled = True
	fFind.btnReplace.Enabled = True
	fFind.btnReplaceAll.Enabled = True
	StopProgress
	WLet(gSearchSave, fFind.txtFind.Text)
	tpFind->Caption = ML("Replace") & " (" & plvSearch->ListItems.Count & " " & ML("Pos") & ")"
	If plvSearch->ListItems.Count = 0 Then
		fFind.Caption = ML("Find: No Results")
	Else
		If Not fFind.txtFind.Contains(fFind.txtFind.Text) Then fFind.txtFind.AddItem fFind.txtFind.Text
		If Len(fFind.txtReplace.Text) > 0 AndAlso (Not fFind.txtReplace.Contains(fFind.txtReplace.Text)) Then fFind.txtReplace.AddItem fFind.txtReplace.Text
		fFind.Caption = ML("Replace") + WStr(plvSearch->ListItems.Count) + " of " + WStr(plvSearch->ListItems.Count)
	End If
	ThreadsLeave
	MutexUnlock tlockToDo
End Sub

Private Sub frmFind.btnFind_Click(ByRef Sender As Control)
	If Trim(txtFind.Text) = "" Then Exit Sub
	btnFind.Enabled = False
	mFormFind = True
	Find True
	If plvSearch->ListItems.Count < 1 OrElse gSearchItemIndex < 0 OrElse gSearchItemIndex > plvSearch->ListItems.Count - 1 Then btnFind.Enabled = True : Exit Sub
	This.Caption = ML("Find") + ": " + WStr(gSearchItemIndex + 1) + " of " + WStr(plvSearch->ListItems.Count)
	btnFind.Enabled = True
End Sub

Private Sub frmFind.btnFindPrev_Click(ByRef Sender As Control)
	If Trim(txtFind.Text) = "" Then Exit Sub
	btnFindPrev.Enabled = False
	mFormFind = True
	Find False
	If plvSearch->ListItems.Count < 1 OrElse gSearchItemIndex < 0 OrElse gSearchItemIndex > plvSearch->ListItems.Count - 1 Then btnFindPrev.Enabled = True : Exit Sub
	This.Caption = ML("Find") + ": " + WStr(gSearchItemIndex + 1) + " of " + WStr(plvSearch->ListItems.Count)
	btnFindPrev.Enabled = True
End Sub

Function IsNotAlpha(Symbol As String) As Boolean
	Return Symbol < "A" OrElse Symbol > "z"
End Function

Private Function frmFind.FindAll(ByRef lvSearchResult As ListView Ptr, tTab As TabPage Ptr = tpFind, ByRef tSearch As WString = "", bNotShowResults As Boolean = False) As Integer
	If mTabSelChangeByError Then Return -1
	If Len(tSearch) > 0 Then txtFind.Text = tSearch
	Dim Search As WString Ptr = @txtFind.Text
	If tTab <> tpToDo AndAlso (Len(*Search) < 1) Then Return -1 ' OrElse CInt(*gSearchSave = *Search)
	If tTab = tpFind Then
		tTab->Caption = ML("Find")
	Else
		tTab->Caption = ML("ToDo")
	End If
	tTab->SelectTab
	Dim As TreeNode Ptr tn = MainNode
	Dim As Boolean bMatchCase = chkMatchCase.Checked
	Dim As Boolean bMatchWholeWords = chkMatchWholeWords.Checked
	Dim As Boolean bUsePatternMatching = chkUsePatternMatching.Checked
	Dim As WString Ptr buff
	Dim As Integer Pos1 = 0
	If cboFindRange.ItemIndex = 2 Then
		If tn > 0 Then
			Dim As ExplorerElement Ptr ee = tn->Tag
			If ee > 0 AndAlso *ee->FileName <> "" Then
				lvSearchResult->ListItems.Clear
				gSearchItemIndex = 0
				ThreadCreate_(@FindSubProj, tn)
				WLet(gSearchSave, *Search)
			End If
		End If
	Else
		Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb = 0 Then Return -1
		If cboFindRange.ItemIndex = 1 Then
			iSelStartLine = 0: iSelEndLine = tb->txtCode.LinesCount - 1: iSelStartChar = 0: iSelEndChar = Len(tb->txtCode.Lines(iSelEndLine))
		Else
			tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar, cboFindRange.ItemIndex = 0 OrElse cboFindRange.ItemIndex = 4
		End If
		If iSelStartLine = iSelEndLine AndAlso iSelStartChar = iSelEndChar Then Return -1
		
		lvSearchResult->ListItems.Clear
		gSearchItemIndex = 0
		WLet(gSearchSave, *Search)
		tb->txtCode.ModifiedLine = False
		Pos1 = iSelStartChar
		For i As Integer = iSelStartLine To iSelEndLine
			buff = @tb->txtCode.Lines(i)
			Do
				If bUsePatternMatching Then
					If bMatchCase Then
						Pos1 = InStrMatch(IIf(i = iSelEndLine, .Left(*buff, iSelEndChar + 1), *buff), *Search, Pos1 + 1)
					Else
						Pos1 = InStrMatch(LCase(IIf(i = iSelEndLine, .Left(*buff, iSelEndChar + 1), *buff)), LCase(*Search), Pos1 + 1)
					End If
				ElseIf bMatchCase Then
					Pos1 = InStr(Pos1 + 1, IIf(i = iSelEndLine, .Left(*buff, iSelEndChar + 1), *buff), *Search)
				Else
					Pos1 = InStr(Pos1 + 1, LCase(IIf(i = iSelEndLine, .Left(*buff, iSelEndChar + 1), *buff)), LCase(*Search))
				End If
				If bMatchWholeWords AndAlso Pos1 > 0 Then
					If IsNotAlpha(Mid(*buff, Pos1 - 1, 1)) AndAlso IsNotAlpha(Mid(*buff, Pos1 + Len(*Search), 1)) Then Exit Do
				Else
					Exit Do
				End If
			Loop
			While Pos1 > 0
				If Not bNotShowResults Then
					lvSearchResult->ListItems.Add *buff
					lvSearchResult->ListItems.Item(lvSearchResult->ListItems.Count - 1)->Text(1) = WStr(i + 1)
					lvSearchResult->ListItems.Item(lvSearchResult->ListItems.Count - 1)->Text(2) = WStr(Pos1)
					lvSearchResult->ListItems.Item(lvSearchResult->ListItems.Count - 1)->Text(3) = tb->FileName
					lvSearchResult->ListItems.Item(lvSearchResult->ListItems.Count - 1)->Tag = tb
				End If
				If i <= tb->txtCode.LineIndex Then gSearchItemIndex = lvSearchResult->ListItems.Count - 1
				Pos1 = Pos1 + Len(*Search) - 1
				Do
					If bUsePatternMatching Then
						If bMatchCase Then
							Pos1 = InStrMatch(IIf(i = iSelEndLine, .Left(*buff, iSelEndChar + 1), *buff), *Search, Pos1 + 1)
						Else
							Pos1 = InStrMatch(LCase(IIf(i = iSelEndLine, .Left(*buff, iSelEndChar + 1), *buff)), LCase(*Search), Pos1 + 1)
						End If
					ElseIf bMatchCase Then
						Pos1 = InStr(Pos1 + 1, IIf(i = iSelEndLine, .Left(*buff, iSelEndChar + 1), *buff), *Search)
					Else
						Pos1 = InStr(Pos1 + 1, LCase(IIf(i = iSelEndLine, .Left(*buff, iSelEndChar + 1), *buff)), LCase(*Search))
					End If
					If bMatchWholeWords AndAlso Pos1 > 0 Then
						If IsNotAlpha(Mid(*buff, Pos1 - 1, 1)) AndAlso IsNotAlpha(Mid(*buff, Pos1 + Len(*Search), 1)) Then Exit Do
					Else
						Exit Do
					End If
				Loop
			Wend
			Pos1 = 0
		Next
		If lvSearchResult->ListItems.Count > 0 AndAlso CInt(cboFindRange.ItemIndex = 3) Then
			Dim As ListViewItem Ptr Item = lvSearchResult->ListItems.Item(gSearchItemIndex)
			tb->txtCode.SetSelection Val(Item->Text(1)) - 1, Val(Item->Text(1)) - 1, Val(Item->Text(2)) - 1, Val(Item->Text(2)) - 1 + Len(*gSearchSave)
		End If
	End If
	If Not bNotShowResults Then
		tTab->SelectTab
		If lvSearchResult->ListItems.Count < 1 Then
			This.Caption = ML("Find: No Results")
		Else
			If Not txtFind.Contains(tSearch) Then txtFind.AddItem tSearch
		End If
		tTab->Caption = IIf(tTab = tpFind, ML("Find"), ML("ToDo")) & " (" & lvSearchResult->ListItems.Count & " " & ML("Pos") & ")"
	End If
End Function

Private Sub frmFind.btnReplace_Click(ByRef Sender As Control)
	If Len(txtFind.Text) < 1 Then Exit Sub
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	Dim txt As EditControl Ptr = @tb->txtCode
	Dim Item As ListViewItem Ptr
	mFormFind = False
	If CInt(*gSearchSave <> txtFind.Text OrElse plvSearch->ListItems.Count < 1) OrElse CInt(tb > 0 AndAlso tb->txtCode.ModifiedLine = True AndAlso cboFindRange.ItemIndex <> 2) Then FindAll plvSearch, tpFind, , False : WLet(gSearchSave, txtFind.Text): tb->txtCode.ModifiedLine = False
	If plvSearch->ListItems.Count < 1 Then This.Caption = ML("Find: No Results")  : Exit Sub
	btnReplace.Enabled = False: btnReplaceAll.Enabled = False
	Dim As Boolean bMatch = IIf(chkMatchCase.Checked, txt->SelText = txtFind.Text, LCase(txt->SelText) = LCase(txtFind.Text))
	If bMatch Then
		txt->SelText = txtReplace.Text
		If Len(txtReplace.Text) > 0 AndAlso (Not txtReplace.Contains(txtReplace.Text)) Then txtReplace.AddItem txtReplace.Text
		FFileName = plvSearch->ListItems.Item(gSearchItemIndex)->Text(3)
		plvSearch->ListItems.Remove gSearchItemIndex
		If plvSearch->ListItems.Count < 1 Then
			btnReplace.Enabled = True : btnReplaceAll.Enabled = True
			This.Caption = ML("Find: No Results")  : btnReplace.Enabled = True : btnReplaceAll.Enabled = True : Exit Sub
		End If
		If gSearchItemIndex >= plvSearch->ListItems.Count - 1 Then gSearchItemIndex = plvSearch->ListItems.Count - 1
	End If
	Find True
	This.Caption = ML("Replace") + ": " + WStr(gSearchItemIndex + 1) + " of " + WStr(plvSearch->ListItems.Count)
	btnReplace.Enabled = True : btnReplaceAll.Enabled = True
	btnFind.SetFocus
End Sub

Private Sub frmFind.btnReplaceAll_Click(ByRef Sender As Control)
	If Len(txtFind.Text)<1 Then Exit Sub
	Dim Result As Boolean
	Dim bMatchCase As Boolean = chkMatchCase.Checked
	Dim As WString Ptr buff
	Dim Search As WString Ptr =@txtFind.Text
	Dim tReplace As WString Ptr =@txtReplace.Text
	Dim As Integer Pos1 = 0, l = Len(*tReplace)
	mFormFind = False
	btnReplace.Enabled = False: btnReplaceAll.Enabled = False
	If cboFindRange.ItemIndex = 2  Then
		Dim As TreeNode Ptr Tn = MainNode
		If Tn > 0 Then
			Dim As ExplorerElement Ptr ee = Tn->Tag
			If ee > 0 AndAlso *ee->FileName <> "" Then
				Select Case MsgBox(ML("Are you sure you want to replace in the project?") + WChr(13, 10) + *Search + WChr(13, 10) + "  " + ML("To") &  ":" + WChr(13, 10) + *tReplace, "Visual FB Editor", mtWarning, btYesNo)
				Case mrYes:
				Case mrNo: Return
				End Select
				ThreadCreate_(@ReplaceSubProj,Tn)
			End If
		End If
	Else
		Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb = 0 Then
			btnReplace.Enabled = True : btnReplaceAll.Enabled = True
			Exit Sub
		End If
		Dim txt As EditControl Ptr = @tb->txtCode
		Dim As EditControlLine Ptr ECLine
		tb->txtCode.Changing "ReplaceAll"
		plvSearch->ListItems.Clear
		gSearchItemIndex = 0
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		If cboFindRange.ItemIndex = 1 Then
			iSelStartLine = 0: iSelEndLine = tb->txtCode.LinesCount - 1: iSelStartChar = 0: iSelEndChar = Len(tb->txtCode.Lines(iSelEndLine))
		Else
			tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar, cboFindRange.ItemIndex = 0
		End If
		For i As Integer = iSelStartLine To iSelEndLine
			buff = @tb->txtCode.Lines(i)
			ECLine = tb->txtCode.Content.Lines.Items[i]
			If bMatchCase Then
				Pos1 = InStr(*buff, *Search)
			Else
				Pos1 = InStr(LCase(*buff), LCase(*Search))
			End If
			While Pos1 > 0
				plvSearch->ListItems.Add *buff
				plvSearch->ListItems.Item(plvSearch->ListItems.Count - 1)->Text(1) = WStr(i + 1)
				plvSearch->ListItems.Item(plvSearch->ListItems.Count - 1)->Text(2) = WStr(Pos1)
				plvSearch->ListItems.Item(plvSearch->ListItems.Count - 1)->Text(3) = tb->FileName
				plvSearch->ListItems.Item(plvSearch->ListItems.Count - 1)->Tag = tb
				WLet(ECLine->Text, ..Left(*buff, Pos1 - 1) & *tReplace & Mid(*buff, Pos1 + Len(*Search)))
				ECLine->Ends.Clear
				ECLine->EndsCompleted = False
				buff = @tb->txtCode.Lines(i)
				If bMatchCase Then
					Pos1 = InStr(Pos1 + Len(*tReplace), *buff, *Search)
				Else
					Pos1 = InStr(Pos1 + Len(*tReplace), LCase(*buff), LCase(*Search))
				End If
			Wend
		Next i
		tb->txtCode.Changed "ReplaceAll"
		tb->txtCode.PaintControl(True)
		tpFind->SelectTab
		tpFind->Caption = ML("Replace") & " (" & plvSearch->ListItems.Count & " " & ML("Pos") & ")"
		If plvSearch->ListItems.Count = 0 Then
			This.Caption = ML("Find: No Results")
		Else
			If Not txtFind.Contains(*Search) Then txtFind.AddItem *Search
			If Len(*tReplace) > 0 AndAlso (Not txtReplace.Contains(*tReplace)) Then txtReplace.AddItem *tReplace
			This.Caption = ML("Replace") + ": " + WStr(plvSearch->ListItems.Count) + " of " + WStr(plvSearch->ListItems.Count)
		End If
	End If
	WLet(gSearchSave, "")
	btnReplace.Enabled = True : btnReplaceAll.Enabled = True
	btnFind.SetFocus
End Sub

Private Sub frmFind.btnReplaceShow_Click(ByRef Sender As Control)
	If Len(*gSearchSave) > 0 Then Clipboard.SetAsText *gSearchSave
	This.Caption = IIf(mFormFind, ML("Find"), ML("Replace"))
	btnReplaceShow.Caption = IIf(mFormFind, ">", "˅")
	btnReplaceShow.Hint = IIf(mFormFind, ML("Expand to Replace Mode"), ML("Narrowdown to Find mode"))
	btnReplace.Enabled = IIf(mFormFind, False, True)
	btnReplaceAll.Enabled = IIf(mFormFind, False, True)
	Height = IIf(mFormFind, 52, 82)
	btnFind.SetFocus
	mFormFind = Not mFormFind
End Sub

Private Sub frmFind.btnCancel_Click(ByRef Sender As Control)
	This.ModalResult = ModalResults.Cancel
	This.CloseForm
End Sub

Private Sub frmFind.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	Dim iCount As Integer=-1
	If txtFind.ItemCount>0 Then
		For i As Integer =txtFind.ItemCount-1 To 0 Step -1
			iCount+=1
			piniSettings->WriteString("Find", "Find_"+WStr(iCount), txtFind.Item(i))
			If iCount>=9 Then Exit For
		Next
	End If
	If txtReplace.ItemCount>0 Then
		iCount=-1
		For i As Integer =txtReplace.ItemCount-1 To 0 Step -1
			iCount+=1
			piniSettings->WriteString("Replace", "Replace_"+WStr(iCount), txtReplace.Item(i))
			If iCount>=9 Then Exit For
		Next
	End If
End Sub

Private Sub frmFind.Form_Create(ByRef Sender As Control)
	Dim tmpStr As WString Ptr
	txtFind.Clear
	txtReplace.Clear
	For i As Integer =0 To 9
		WLet(tmpStr, piniSettings->ReadString("Find", "Find_" + WStr(i), ""))
		If CInt(Trim(*tmpStr)<>"") Then txtFind.AddItem *tmpStr
	Next
	For i As Integer =0 To 9
		WLet(tmpStr, piniSettings->ReadString("Replace", "Replace_"+WStr(i), ""))
		If CInt(Trim(*tmpStr)<>"") Then txtReplace.AddItem *tmpStr
	Next
	cboFindRange.ItemIndex = 1
	btnReplace.Enabled = False
	btnReplaceAll.Enabled = False
	WDeAllocate(tmpStr)
	SetBounds pfrmMain->Left + pfrmMain->Width - This.Width - 10, pfrmMain->Top + 20, This.Width, This.Height
	#ifdef __USE_GTK__
		btnReplaceShow.Visible = False
		TrackBar1.Visible = False
		lblTrack.Visible = False
	#else
		btnReplaceShow.Width = 18
	#endif
	Opacity = 230
	TrackBar1.Position = 230
	lblTrack.Text = WStr(CUInt(TrackBar1.Position / 2.55))
	
	TrackBar1_Change(TrackBar1, TrackBar1.Position)
End Sub

Private Sub frmFind.Form_Show(ByRef Sender As Form)
	Dim As UString SelText
	If ptabCode Then
		Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb Then
			SelText = tb->txtCode.SelText
		End If
	End If
	If SelText = "" Then
		SelText = Clipboard.GetAsText
	End If
	If SelText = "" Then
		cboFindRange.ItemIndex = 1
	Else
		Var Posi = InStr(SelText, Chr(13)) - 1
		If Posi < 1 Then Posi = InStr(SelText, Chr(10)) - 1
		If Posi < 1 Then Posi = Len(SelText)
		txtFind.Text = ..Left(SelText, Posi)
	End If
	btnReplaceShow_Click(btnReplaceShow)
	txtFind.SetFocus
End Sub

Private Sub frmFind.TrackBar1_Change(ByRef Sender As TrackBar, Position As Integer)
	If Sender.Position < 20 Then Sender.Position = 20
	Opacity = Sender.Position
	lblTrack.Text = WStr(CUInt(Sender.Position/2.55))
End Sub

Private Sub frmFind.btnFindAll_Click(ByRef Sender As Control)
	FindAll plvSearch, tpFind, , False
End Sub

Private Sub frmFind.cboFindRange_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	Static As Integer ItemIndexSave
	If ItemIndexSave <> ItemIndex + 1 Then
		ItemIndexSave = ItemIndex + 1
		WLet(gSearchSave, "")
		plvSearch->ListItems.Clear
	End If
End Sub

Private Sub frmFind.chkBox_Click(ByRef Sender As CheckBox)
	WLet(gSearchSave, "")
End Sub
