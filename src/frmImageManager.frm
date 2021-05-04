#ifdef __FB_WIN32__
	'#Compile -exx "Form1.rc"
#else
	'#Compile -exx
#endif
'#Region "Form"
	#include once "frmImageManager.bi"
	#include once "frmPath.bi"
	
	Constructor frmImageManager
		' frmImageManager
		With This
			.Name = "frmImageManager"
			.Text = ML("Image Manager")
			.Designer = @This
			.OnShow = @Form_Show_
			.Margins.Top = 0
			.Margins.Right = 0
			.Margins.Left = 0
			.Margins.Bottom = 0
			.BorderStyle = FormBorderStyle.Sizable
			.DefaultButton = @cmdOK
			.CancelButton = @cmdCancel
			.OnCreate = @Form_Create_
			.SetBounds 0, 0, 627, 510
		End With
		' tbToolbar
		With tbToolbar
			.Name = "tbToolbar"
			.Text = "ToolBar1"
			.SetBounds 0, 0, 611, 26
			.Align = DockStyle.alTop
			.ImagesList = @imgList
			.HotImagesList = @imgList
			.Buttons.Add , "Add", , , "Add"
			.Buttons.Add , "Project", , , "Change"
			.Buttons.Add , "Remove", , , "Remove"
			.Buttons.Add tbsSeparator
			.Buttons.Add , "Up", , , "Up"
			.Buttons.Add , "Down", , , "Down"
			.Buttons.Add , "Sort", , , "Sort"
			.Designer = @This
			.OnButtonClick = @tbToolbar_ButtonClick_
			.Parent = @This
		End With
		' lvImages
		With lvImages
			.Name = "lvImages"
			.Text = "lvImages"
			.TabIndex = 0
			.SetBounds 10, 26, 261, 403
			.Columns.Add ML("Name"), , 100
			.Columns.Add ML("Type"), , 80
			.Columns.Add ML("Path"), , 200
			.Anchor.Top = AnchorStyle.asNone
			.Anchor.Right = AnchorStyle.asNone
			.Anchor.Left = AnchorStyle.asNone
			.Anchor.Bottom = AnchorStyle.asNone
			.Align = DockStyle.alLeft
			.ExtraMargins.Left = 10
			.ExtraMargins.Bottom = 0
			.Images = @ImageList1
			.SmallImages = @ImageList1
			.Designer = @This
			.OnItemActivate = @lvImages_ItemActivate_
			.OnSelectedItemChanged = @lvImages_SelectedItemChanged_
			.Parent = @This
		End With
		' Splitter1
		With Splitter1
			.Name = "Splitter1"
			.Text = "Splitter1"
			.Align = 1
			.SetBounds 271, 26, 10, 403
			.Parent = @This
		End With
		' gbImagePreview
		With gbImagePreview
			.Name = "gbImagePreview"
			.Text = ML("Image Preview")
			.TabIndex = 1
			.SetBounds 281, 26, 320, 403
			.Caption = ML("Image Preview")
			.Anchor.Top = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Bottom = AnchorStyle.asAnchor
			.Align = DockStyle.alClient
			.ExtraMargins.Right = 10
			.Parent = @This
		End With
		' imgImage
		With imgImage
			.Name = "imgImage"
			.Text = "ImageBox1"
			.SetBounds 10, 10, 300, 383
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 15
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.ExtraMargins.Bottom = 10
			.CenterImage = True
			.Parent = @gbImagePreview
		End With
		' pnlCommands
		With pnlCommands
			.Name = "pnlCommands"
			.Text = "pnlCommands"
			.TabIndex = 4
			.SetBounds 0, 429, 611, 42
			.Align = DockStyle.alBottom
			.Parent = @This
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = ML("Cancel")
			.TabIndex = 3
			.SetBounds 521, 10, 80, 22
			.Align = DockStyle.alRight
			.ExtraMargins.Bottom = 10
			.ExtraMargins.Right = 10
			.Caption = ML("Cancel")
			.ExtraMargins.Top = 10
			.Designer = @This
			.OnClick = @cmdCancel_Click_
			.Default = False
			.Parent = @pnlCommands
		End With
		' cmdOK
		With cmdOK
			.Name = "cmdOK"
			.Text = ML("OK")
			.TabIndex = 2
			.SetBounds 431, 10, 80, 22
			.Align = DockStyle.alRight
			.ExtraMargins.Bottom = 10
			.ExtraMargins.Right = 10
			.Caption = ML("OK")
			.ExtraMargins.Top = 10
			.Designer = @This
			.OnClick = @cmdOK_Click_
			.Default = True
			.Parent = @pnlCommands
		End With
		' lblResourceFile
		With lblResourceFile
			.Name = "lblResourceFile"
			.Text = ML("File") & ":"
			.TabIndex = 5
			.SetBounds 10, 10, 411, 22
			.ExtraMargins.Top = 10
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.ExtraMargins.Bottom = 10
			.Align = DockStyle.alClient
			.CenterImage = True
			.Parent = @pnlCommands
		End With
		' ImageList1
		With ImageList1
			.Name = "ImageList1"
			.SetBounds 110, 11, 16, 16
			.Parent = @pnlCommands
		End With
	End Constructor
	
	Dim Shared fImageManager As frmImageManager
	Dim Shared fImageListEditor As frmImageManager
	pfImageManager = @fImageManager
	pfImageListEditor = @fImageListEditor
'#End Region

Private Sub frmImageManager.Form_Show_(ByRef Sender As Form)
	*Cast(frmImageManager Ptr, Sender.Designer).Form_Show(Sender)
End Sub
Private Sub frmImageManager.Form_Show(ByRef Sender As Form)
	Dim As ProjectElement Ptr Project
	Dim As TreeNode Ptr ProjectNode
	Dim As UString MainFile = GetMainFile(, Project, ProjectNode, WithoutMainNode), FolderName
	Dim sFirstLine As UString = GetFirstCompileLine(MainFile, Project)
	lvImages.ListItems.Clear
	ResourceFile = GetResourceFile(WithoutMainNode)
	ExeFileName = GetFullPath(GetExeFileName(MainFile, sFirstLine), MainFile)
	FolderName = GetFolderName(ExeFileName)
	If FolderName = "" Then ExeFileName = IIf(FolderName = "", ExePath & Slash & "Projects" & Slash, FolderName) & ExeFileName
	Var Fn = FreeFile, Pos1 = 0
	If Open(ResourceFile For Input Encoding "utf-8" As #Fn) = 0 Then
		Dim As WString * 1024 FilePath
		Dim As WString * 1024 sLine
		Dim As String Image
		Do Until EOF(Fn)
			Line Input #Fn, sLine
			Pos1 = InStr(sLine, " BITMAP "): Image = "BITMAP"
			If Pos1 = 0 Then Pos1 = InStr(sLine, " PNG "): Image = "PNG"
			If Pos1 = 0 Then Pos1 = InStr(sLine, " RCDATA "): Image = "RCDATA"
			If Pos1 = 0 Then Pos1 = InStr(sLine, " ICON "): Image = "ICON"
			If Pos1 = 0 Then Pos1 = InStr(sLine, " CURSOR "): Image = "CURSOR"
			If Pos1 > 0 Then
				FilePath = Trim(Mid(sLine, Pos1 + 2 + Len(Image)))
				If EndsWith(FilePath, """") Then FilePath = Left(FilePath, Len(FilePath) - 1)
				If StartsWith(FilePath, """") Then FilePath = Mid(FilePath, 2)
				ImageList1.AddFromFile GetRelativePath(FilePath, ResourceFile), Trim(Left(sLine, Pos1 - 1))
				lvImages.ListItems.Add Trim(Left(sLine, Pos1 - 1))
				lvImages.ListItems.Item(lvImages.ListItems.Count - 1)->ImageIndex = lvImages.ListItems.Count - 1
				lvImages.ListItems.Item(lvImages.ListItems.Count - 1)->Text(1) = Image
				lvImages.ListItems.Item(lvImages.ListItems.Count - 1)->Text(2) = FilePath
			End If
		Loop
		Close #Fn
	End If
	lblResourceFile.Text = ML("File") & ": " & ResourceFile
End Sub

Private Sub frmImageManager.cmdCancel_Click_(ByRef Sender As Control)
	*Cast(frmImageManager Ptr, Sender.Designer).cmdCancel_Click(Sender)
End Sub
Private Sub frmImageManager.cmdCancel_Click(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	Me.CloseForm
End Sub

Private Sub frmImageManager.cmdOK_Click_(ByRef Sender As Control)
	*Cast(frmImageManager Ptr, Sender.Designer).cmdOK_Click(Sender)
End Sub
Private Sub frmImageManager.cmdOK_Click(ByRef Sender As Control)
	If WithoutMainNode AndAlso lvImages.SelectedItemIndex = -1 Then
		MsgBox ML("Nothing has been chosen"), pApp->Title
		Exit Sub
	End If
	Dim As WStringList Lines
	Dim As Integer Result
	Var Fn = FreeFile
	If Not FileExists(ResourceFile) Then
		If AutoCreateRC Then
			FileCopy ExePath & "/Templates/Files/Resource.rc", *ResourceFile.vptr
			If Not FileExists(GetFolderName(ResourceFile) & "Manifest.xml") Then
				FileCopy ExePath & "/Templates/Files/Manifest.xml", *GetFolderName(ResourceFile).vptr & "Manifest.xml"
			End If
		End If
	End If
	Result = Open(ResourceFile For Input Encoding "utf-8" As #Fn)
	If Result <> 0 Then Result = Open(ResourceFile For Input Encoding "utf-32" As #Fn)
	If Result <> 0 Then Result = Open(ResourceFile For Input Encoding "utf-16" As #Fn)
	If Result <> 0 Then Result = Open(ResourceFile For Input As #Fn)
	If Result = 0 Then
		Dim As WString * 1024 sLine
		Dim As String Image
		Do Until EOF(Fn)
			Line Input #Fn, sLine
			Lines.Add sLine
		Loop
		Close #Fn
	End If
	Fn = FreeFile
	Dim As Boolean bFinded
	Dim As Integer Pos1
	Open ResourceFile For Output Encoding "utf-8" As #Fn
	For i As Integer = 0 To Lines.Count - 1
		Pos1 = InStr(Lines.Item(i), " BITMAP ")
		If Pos1 = 0 Then Pos1 = InStr(Lines.Item(i), " PNG ")
		If Pos1 = 0 Then Pos1 = InStr(Lines.Item(i), " RCDATA ")
		If Pos1 = 0 Then Pos1 = InStr(Lines.Item(i), " ICON ")
		If Pos1 = 0 Then Pos1 = InStr(Lines.Item(i), " CURSOR ")
		If Pos1 > 0 Then
			If bFinded Then
				Continue For
			Else
				With lvImages.ListItems
					For j As Integer = 0 To lvImages.ListItems.Count - 1
						Print #Fn, .Item(j)->Text(0) & " " & .Item(j)->Text(1) & " """ & .Item(j)->Text(2) & """"
					Next
				End With
				bFinded = True
			End If
		Else
			Print #Fn, Lines.Item(i)
		End If
	Next
	If Not bFinded Then
		With lvImages.ListItems
			For j As Integer = 0 To lvImages.ListItems.Count - 1
				Print #Fn, .Item(j)->Text(0) & " " & .Item(j)->Text(1) & " """ & .Item(j)->Text(2) & """"
			Next
		End With
	End If
	Close #Fn
'	If tb = 0 AndAlso MainFile <> ML("Untitled") Then tb = AddTab(MainFile)
'	If tb <> 0 AndAlso ptabCode->IndexOfTab(tb) > -1 Then
'		tb->txtCode.Changing "Adding #Compile"
'		tb->txtCode.InsertLine 0, "#ifdef __FB_WIN32__"
'		tb->txtCode.InsertLine 1, !"\t'#Compile -exx """ & ResourceFileName & """"
'		tb->txtCode.InsertLine 2, "#else"
'		tb->txtCode.InsertLine 3, !"\t'#Compile -exx"
'		tb->txtCode.InsertLine 4, "#endif"
'		tb->txtCode.Changed "Adding #Compile"
'	End If
	ModalResult = ModalResults.OK
	Me.CloseForm
End Sub

Private Sub frmImageManager.lvImages_ItemActivate_(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	*Cast(frmImageManager Ptr, Sender.Designer).lvImages_ItemActivate(Sender, ItemIndex)
End Sub
Private Sub frmImageManager.lvImages_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	If lvImages.SelectedItem = 0 Then Exit Sub
	pfPath->txtVersion.Text = lvImages.SelectedItem->Text(0)
	pfPath->txtPath.Text = lvImages.SelectedItem->Text(2)
	pfPath->lblCommandLine.Text = ML("Type") & ":"
	pfPath->cboType.ItemIndex = pfPath->cboType.IndexOf(lvImages.SelectedItem->Text(1))
	pfPath->WithType = True
	pfPath->SetFileNameToVersion = True
	pfPath->ExeFileName = ExeFileName
	If pfPath->ShowModal() = ModalResults.OK Then
		If lvImages.SelectedItem->Text(0) = pfPath->txtVersion.Text OrElse lvImages.ListItems.IndexOf(pfPath->txtVersion.Text) = -1 Then
			lvImages.SelectedItem->Text(0) = pfPath->txtVersion.Text
			lvImages.SelectedItem->Text(1) = pfPath->cboType.Text
			lvImages.SelectedItem->Text(2) = pfPath->txtPath.Text
		Else
			MsgBox ML("This version is exists!")
		End If
	End If
End Sub

Private Sub frmImageManager.lvImages_SelectedItemChanged_(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	*Cast(frmImageManager Ptr, Sender.Designer).lvImages_SelectedItemChanged(Sender, ItemIndex)
End Sub
Private Sub frmImageManager.lvImages_SelectedItemChanged(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	If ItemIndex < 0 Then Exit Sub
	Dim As UString Path = GetRelativePath(lvImages.ListItems.Item(ItemIndex)->Text(2), ResourceFile)
	Select Case lvImages.ListItems.Item(ItemIndex)->Text(1)
	Case "BITMAP": imgImage.Graphic.Bitmap.LoadFromFile(Path)
	Case "PNG", "RCDATA": imgImage.Graphic.Bitmap.LoadFromFile(Path)
	Case "ICON": imgImage.Graphic.Icon.LoadFromFile(Path)
	Case "CURSOR": imgImage.Graphic.Cursor.LoadFromFile(Path)
	End Select
End Sub

Private Sub frmImageManager.tbToolbar_ButtonClick_(ByRef Sender As ToolBar,ByRef Button As ToolButton)
	*Cast(frmImageManager Ptr, Sender.Designer).tbToolbar_ButtonClick(Sender, Button)
End Sub
Private Sub frmImageManager.tbToolbar_ButtonClick(ByRef Sender As ToolBar,ByRef Button As ToolButton)
	Select Case Button.Name
	Case "Add"
		pfPath->txtVersion.Text = ""
		pfPath->txtPath.Text = ""
		pfPath->lblCommandLine.Text = ML("Type") & ":"
		pfPath->cboType.ItemIndex = 0
		pfPath->WithType = True
		pfPath->SetFileNameToVersion = True
		pfPath->ExeFileName = ExeFileName
		If pfPath->ShowModal() = ModalResults.OK Then
			If lvImages.ListItems.IndexOf(pfPath->txtVersion.Text) = -1 Then
				lvImages.ListItems.Add pfPath->txtVersion.Text
				lvImages.ListItems.Item(lvImages.ListItems.Count - 1)->Text(1) = pfPath->cboType.Text
				lvImages.ListItems.Item(lvImages.ListItems.Count - 1)->Text(2) = pfPath->txtPath.Text
				lvImages.SelectedItemIndex = lvImages.ListItems.Count - 1
			Else
				MsgBox ML("This version is exists!")
			End If
		End If
	Case "Change": lvImages_ItemActivate(lvImages, lvImages.SelectedItemIndex)
	Case "Remove": If lvImages.SelectedItem <> 0 Then lvImages.ListItems.Remove lvImages.SelectedItemIndex
	Case "Up"
		Dim i As Integer = lvImages.SelectedItemIndex
		If i < 1 Then Exit Sub
		Dim As ListViewItem Ptr ItemCurr = lvImages.SelectedItem, ItemPrev = lvImages.ListItems.Item(i - 1)
		Dim As UString Temp0 = ItemPrev->Text(0), Temp1 = ItemPrev->Text(1), Temp2 = ItemPrev->Text(2)
		ItemPrev->Text(0) = ItemCurr->Text(0)
		ItemPrev->Text(1) = ItemCurr->Text(1)
		ItemPrev->Text(2) = ItemCurr->Text(2)
		ItemCurr->Text(0) = Temp0
		ItemCurr->Text(1) = Temp1
		ItemCurr->Text(2) = Temp2
		lvImages.SelectedItemIndex = i - 1
	Case "Down"
		Dim i As Integer = lvImages.SelectedItemIndex
		If i < 0 OrElse i >= lvImages.ListItems.Count - 1 Then Exit Sub
		Dim As ListViewItem Ptr ItemCurr = lvImages.SelectedItem, ItemNext = lvImages.ListItems.Item(i + 1)
		Dim As UString Temp0 = ItemNext->Text(0), Temp1 = ItemNext->Text(1), Temp2 = ItemNext->Text(2)
		ItemNext->Text(0) = ItemCurr->Text(0)
		ItemNext->Text(1) = ItemCurr->Text(1)
		ItemNext->Text(2) = ItemCurr->Text(2)
		ItemCurr->Text(0) = Temp0
		ItemCurr->Text(1) = Temp1
		ItemCurr->Text(2) = Temp2
		lvImages.SelectedItemIndex = i + 1
	Case "Sort": lvImages.ListItems.Sort
	End Select
End Sub

Private Sub frmImageManager.Form_Create_(ByRef Sender As Control)
	*Cast(frmImageManager Ptr, Sender.Designer).Form_Create(Sender)
End Sub
Private Sub frmImageManager.Form_Create(ByRef Sender As Control)
	pfPath->cboType.Clear
	pfPath->cboType.AddItem "BITMAP"
	pfPath->cboType.AddItem "CURSOR"
	pfPath->cboType.AddItem "ICON"
	pfPath->cboType.AddItem "PNG"
	pfPath->cboType.AddItem "RCDATA"
End Sub
