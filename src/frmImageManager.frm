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
			.FormStyle = FormStyles.fsStayOnTop
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
			.Align = SplitterAlignmentConstants.alLeft
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
		' pnlOptions
		With pnlOptions
			.Name = "pnlOptions"
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 15
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.ExtraMargins.Bottom = 10
			.TabIndex = 6
			.SetBounds -1, 9, 20, 20
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
			.TabIndex = 
