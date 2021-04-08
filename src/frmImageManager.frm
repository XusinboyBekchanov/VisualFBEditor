#ifdef __FB_WIN32__
	'#Compile -exx "Form1.rc"
#else
	'#Compile -exx
#endif
'#Region "Form"
	#include once "frmImageManager.bi"
	
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
			.Buttons.Add , "Add"
			.Buttons.Add , "Change"
			.Buttons.Add , "Remove"
			.Buttons.Add tbsSeparator
			.Buttons.Add , "Up"
			.Buttons.Add , "Down"
			.Buttons.Add , "Sort"
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
			'.CenterImage = True
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
		' cmdOK
		With cmdOK
			.Name = "cmdOK"
			.Text = ML("Cancel")
			.TabIndex = 3
			.SetBounds 521, 10, 80, 22
			.Align = DockStyle.alRight
			.ExtraMargins.Bottom = 10
			.ExtraMargins.Right = 10
			.Caption = ML("Cancel")
			.ExtraMargins.Top = 10
			.Designer = @This
			.OnClick = @cmdOK_Click_
			.Parent = @pnlCommands
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = ML("OK")
			.TabIndex = 2
			.SetBounds 431, 10, 80, 22
			.Align = DockStyle.alRight
			.ExtraMargins.Bottom = 10
			.ExtraMargins.Right = 10
			.Caption = ML("OK")
			.ExtraMargins.Top = 10
			.Designer = @This
			.OnClick = @cmdCancel_Click_
			.Default = True
			.Parent = @pnlCommands
		End With
	End Constructor
	
	Dim Shared fImageManager As frmImageManager
	pfImageManager = @fImageManager
	
'#End Region

Private Sub frmImageManager.Form_Show_(ByRef Sender As Form)
	*Cast(frmImageManager Ptr, Sender.Designer).Form_Show(Sender)
End Sub
Private Sub frmImageManager.Form_Show(ByRef Sender As Form)
	Dim As ProjectElement Ptr Project
	Dim As TreeNode Ptr ProjectNode
	Dim FileName As UString = GetMainFile(, Project, ProjectNode)
	Dim sFirstLine As UString = GetFirstCompileLine(FileName, Project)
	Dim As WString Ptr Buff, File, sLines
	ResourceFile = ""
	WLet(Buff, LTrim(sFirstLine, Any !"\t "))
	Var Pos1 = InStr(*Buff, """"), Pos2 = 1
	Dim QavsBoshi As Boolean
	Do While Pos1 > 0
		QavsBoshi = Not QavsBoshi
		If QavsBoshi Then
			Pos2 = Pos1
		Else
			WLet(File, Mid(*Buff, Pos2 + 1, Pos1 - Pos2 - 1))
			If EndsWith(LCase(*File), ".rc") Then
				ResourceFile = GetFolderName(FileName) & *File
				Exit Do
			End If
		End If
		Pos1 = InStr(Pos1 + 1, *Buff, """")
	Loop
	WDeallocate Buff
	WDeallocate File
	If ResourceFile <> "" Then
		Var Fn = FreeFile
		If Open(ResourceFile For Input Encoding "utf-8" As #Fn) = 0 Then
			Dim As UString FilePath
			Dim As WString * 1024 sLine
			Dim As String Image
			Do Until EOF(Fn)
				Line Input #Fn, sLine
				Pos1 = InStr(sLine, " BITMAP "): Image = "BITMAP"
				If Pos1 = 0 Then Pos1 = InStr(sLine, " PNG "): Image = "PNG"
				If Pos1 = 0 Then Pos1 = InStr(sLine, " ICON "): Image = "ICON"
				If Pos1 = 0 Then Pos1 = InStr(sLine, " CURSOR "): Image = "CURSOR"
				If Pos1 > 0 Then
					FilePath = Trim(Mid(sLine, Pos1 + 2 + Len(Image)))
					If StartsWith(FilePath, """") Then FilePath = Mid(FilePath, 2)
					If EndsWith(FilePath, """") Then
						?11
						FilePath = Left(FilePath, Len(FilePath) - 1)
					End If
					?FilePath
					lvImages.ListItems.Add Trim(Left(sLine, Pos1 - 1))
					lvImages.ListItems.Item(lvImages.ListItems.Count - 1)->Text(1) = Image
					lvImages.ListItems.Item(lvImages.ListItems.Count - 1)->Text(2) = FilePath
				End If
			Loop
			Close #Fn
		End If
	End If
End Sub

Private Sub frmImageManager.cmdCancel_Click_(ByRef Sender As Control)
	*Cast(frmImageManager Ptr, Sender.Designer).cmdCancel_Click(Sender)
End Sub
Private Sub frmImageManager.cmdCancel_Click(ByRef Sender As Control)
	Me.CloseForm
End Sub

Private Sub frmImageManager.cmdOK_Click_(ByRef Sender As Control)
	*Cast(frmImageManager Ptr, Sender.Designer).cmdOK_Click(Sender)
End Sub
Private Sub frmImageManager.cmdOK_Click(ByRef Sender As Control)
	Me.CloseForm
End Sub

Private Sub frmImageManager.lvImages_ItemActivate_(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	*Cast(frmImageManager Ptr, Sender.Designer).lvImages_ItemActivate(Sender, ItemIndex)
End Sub
Private Sub frmImageManager.lvImages_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	
End Sub

Private Sub frmImageManager.lvImages_SelectedItemChanged_(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	*Cast(frmImageManager Ptr, Sender.Designer).lvImages_SelectedItemChanged(Sender, ItemIndex)
End Sub
Private Sub frmImageManager.lvImages_SelectedItemChanged(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	If ItemIndex < 0 Then Exit Sub
	Dim As UString Path = GetRelativePath(lvImages.ListItems.Item(ItemIndex)->Text(2), ResourceFile)
	Select Case lvImages.ListItems.Item(ItemIndex)->Text(1)
	Case "BITMAP", "PNG": imgImage.Graphic.Bitmap.LoadFromFile(Path)
	Case "ICON": imgImage.Graphic.Icon.LoadFromFile(Path)
	Case "CURSOR": imgImage.Graphic.Cursor.LoadFromFile(Path)
	End Select
	?imgImage.Width, imgImage.Height
End Sub
