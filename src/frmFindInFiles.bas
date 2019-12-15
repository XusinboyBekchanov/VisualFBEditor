'#########################################################
'#  frmFindInFiles.bas                                   #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (2018-2019)              #
'#########################################################

#include once "frmFindInFiles.bi"

Dim Shared As frmFindInFiles fFindFile
pfFindFile = @fFindFile

'#Region "Form"
	Private Sub frmFindInFiles._btnFind_Click_(ByRef Sender As Control)
		With fFindFile
			.btnFind_Click(Sender)
		End With
	End Sub
	
	Private Sub frmFindInFiles._btnCancel_Click_(ByRef Sender As Control)
		fFindFile.btnCancel_Click(Sender)
	End Sub
	
	Private Sub frmFindInFiles._Form_Show_(ByRef Sender As Form)
		fFindFile.Form_Show(Sender)
	End Sub
	
	Private Sub frmFindInFiles._Form_Close_(ByRef Sender As Form, ByRef Action As Integer)
		fFindFile.Form_Close(Sender, Action) 
	End Sub
	
	Constructor frmFindInFiles
		This.StartPosition = FormStartPosition.CenterParent
		This.SetBounds 0, 0, 415, 188
		Caption = ML("Find In Files")
		lblFind.Caption = ML("Find") & ":"
		lblFind.SetBounds 10, 10, 80, 20
		lblFind.Parent = @This
		txtFind.SetBounds 90, 10, 300, 20
		txtFind.Anchor.Left = asAnchor
		txtFind.Anchor.Right = asAnchor
		txtFind.Parent = @This
		lblPath.Caption = ML("Path") & ":"
		lblPath.SetBounds 10, 35, 80, 20
		lblPath.Parent = @This
		txtPath.SetBounds 90, 35, 280, 20
		txtPath.Anchor.Left = asAnchor
		txtPath.Anchor.Right = asAnchor
		txtPath.Parent = @This
		btnBrowse.Caption = ML("...")
		btnBrowse.Anchor.Right = asAnchor
		btnBrowse.SetBounds 370, 35, 20, 20
		btnBrowse.Parent = @This
		chkRegistr.Caption = ML("Match Case")
		chkRegistr.SetBounds 90, 60, 140, 20
		chkRegistr.Parent = @This
		chkRecursive.Caption = ML("Recursively in subdirectories")
		chkRecursive.SetBounds 90, 85, 200, 20
		chkRecursive.Checked = True
		chkRecursive.Parent = @This
		btnFind.Caption = ML("&Find")
		btnFind.Default = True
		btnFind.SetBounds 90, 110, 138, 28
		btnFind.Anchor.Right = asAnchor
		btnFind.Parent = @This
		btnCancel.Caption = ML("&Cancel")
		btnCancel.Anchor.Right = asAnchor
		btnCancel.SetBounds 252, 110, 138, 28
		btnCancel.Parent = @This
		OnShow = @_Form_Show_
		OnClose = @_Form_Close_
		btnFind.OnClick = @_btnFind_Click_
		btnCancel.OnClick = @_btnCancel_Click_
		btnBrowse.OnClick = @btnBrowse_Click
		DefaultButton = @btnFind
		CancelButton = @btnCancel
		'This.BorderStyle = 2
	End Constructor
	
	Destructor frmFindInFiles
		
	End Destructor
'#End Region

Sub frmFindInFiles.Find(ByRef Path As WString)
	Dim As String f
	Dim As Integer Result, Pos1
	Dim buff As WString Ptr
	Dim search As WString Ptr = @txtFind.Text
	Dim As Integer iLine, iStart
	Dim As Integer Attr
	Dim As WStringList Folders
	If chkRecursive.Checked Then
		f = Dir(Path & "/*", fbReadOnly Or fbHidden Or fbSystem Or fbDirectory Or fbArchive, Attr)
	Else
		f = Dir(Path & "/*", fbReadOnly Or fbHidden Or fbSystem Or fbArchive, Attr)
	End If
	While f <> ""
		If (Attr And fbDirectory) <> 0 Then
			If f <> "." AndAlso f <> ".." Then Folders.Add Path & "/" & f
		ElseIf EndsWith(f, ".bas") OrElse EndsWith(f, ".bi") OrElse EndsWith(f, ".rc") OrElse EndsWith(f, ".inc") _
			OrElse EndsWith(f, ".txt") OrElse EndsWith(f, ".log") OrElse EndsWith(f, ".lng") _
			OrElse EndsWith(f, ".vfp") OrElse EndsWith(f, ".vfs") OrElse EndsWith(f, ".xml") _
			OrElse EndsWith(f, ".c") OrElse EndsWith(f, ".h") OrElse EndsWith(f, ".cpp") Then
			'App.DoEvents
			Result = Open(Path & "/" & f For Input Encoding "utf-32" As #1)
			If Result <> 0 Then Result = Open(Path & "/" & f For Input Encoding "utf-16" As #1)
			If Result <> 0 Then Result = Open(Path & "/" & f For Input Encoding "utf-8" As #1)
			If Result <> 0 Then Result = Open(Path & "/" & f For Input As #1)
			If Result = 0 Then
				WReallocate buff, LOF(1)
				iLine = 0
				Do Until EOF(1)
					Line Input #1, *buff
					iLine += 1
					Pos1 = InStr(LCase(*buff), LCase(*search))
					While Pos1 > 0
						ThreadsEnter
						plvSearch->ListItems.Add *buff
						plvSearch->ListItems.Item(plvSearch->ListItems.Count - 1)->Text(1) = WStr(iLine)
						plvSearch->ListItems.Item(plvSearch->ListItems.Count - 1)->Text(2) = WStr(Pos1)
						plvSearch->ListItems.Item(plvSearch->ListItems.Count - 1)->Text(3) = Path & IIf(EndsWith(Path, "/") OrElse EndsWith(Path, "\"), "", "/") & f
						pfrmMain->Update
						ThreadsLeave
						Pos1 = InStr(Pos1 + 1, LCase(*buff), LCase(*search))
					Wend
				Loop
				Close #1
			End If
		End If
		f = Dir(Attr)
	Wend
	For i As Integer = 0 To Folders.Count - 1
		Find Folders.Item(i)
	Next
End Sub

Sub FindSub(Param As Any Ptr)
	ThreadsEnter
	plvSearch->ListItems.Clear
	pTabBottom->Tabs[2]->SelectTab
	StartProgress
	With fFindFile
		.btnFind.Enabled = False
		ThreadsLeave
		.Find Replace(.txtPath.Text, "\", "/")
		ThreadsEnter
		.btnFind.Enabled = True
	End With
	StopProgress
	ptabBottom->Tabs[2]->Caption = ML("Find") & " (" & plvSearch->ListItems.Count & " " & ML("Pos") & ")"
	ThreadsLeave
End Sub

Private Sub frmFindInFiles.btnFind_Click(ByRef Sender As Control)
	FindInFiles
End Sub

Private Sub frmFindInFiles.btnCancel_Click(ByRef Sender As Control)
	This.CloseForm
End Sub

Private Sub frmFindInFiles.btnBrowse_Click(ByRef Sender As Control)
	If fFindFile.FolderDialog.Execute Then
		fFindFile.txtPath.Text = fFindFile.FolderDialog.Directory
	End If
End Sub

Private Sub frmFindInFiles.Form_Show(ByRef Sender As Form)
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	txtFind.Text = pClipboard->GetAsText
	If tb <> 0 AndAlso tb->FileName <> "" Then
		txtPath.Text = GetFolderName(tb->FileName)
	Else
		txtPath.Text = exepath
	End If
	txtFind.SelectAll
	txtFind.SetFocus
End Sub

Private Sub frmFindInFiles.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	if 1 then
		
	End If
End Sub
