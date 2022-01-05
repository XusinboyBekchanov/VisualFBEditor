#ifdef __FB_WIN32__
	'#Compile -exx "Form1.rc"
#else
	'#Compile -exx
#endif
'#Region "Form"
	#include once "frmTemplates.bi"
	
	Constructor frmTemplates
		' frmTemplates
		With This
			.Name = "frmTemplates"
			.Text = ML("New") & "..."
			#ifdef __USE_GTK__
				.Icon.LoadFromFile(ExePath & "/Resources/VisualFBEditor.ico")
			#else
				.Icon.LoadFromResourceID(1)
			#endif
			.StartPosition = FormStartPosition.CenterParent
			.Designer = @This
			.BorderStyle = FormBorderStyle.Sizable
			.OnShow = @Form_Show_
			.OnClose = @Form_Close_
			.SetBounds 0, 0, 657, 440
		End With
		' TabControl1
		With TabControl1
			.Name = "TabControl1"
			.Text = "TabControl1"
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 10
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.ExtraMargins.Bottom = 10
			.SelectedTabIndex = 2
			.SetBounds 10, 10, 621, 351
			.Designer = @This
			.OnSelChange = @TabControl1_SelChange_
			.Parent = @This
		End With
		' tpNew
		With tpNew
			.Name = "tpNew"
			.SetBounds 2, 22, 498, 275
			.Text = ML("New")
			.UseVisualStyleBackColor = True
			.Parent = @TabControl1
		End With
		' tvTemplates
		With tvTemplates
			.Name = "tvTemplates"
			.Text = "TreeView1"
			.Align = DockStyle.alLeft
			.ExtraMargins.Top = 10
			.ExtraMargins.Left = 10
			.ExtraMargins.Bottom = 10
			.SetBounds 0, 10, 180, 206
			.Designer = @This
			.OnSelChanged = @tvTemplates_SelChanged_
			.Parent = @tpNew
		End With
		' lvTemplates
		With lvTemplates
			.Name = "lvTemplates"
			.Text = "ListView1"
			.View = ViewStyle.vsIcon
			.Images = @imgList
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 10
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.ExtraMargins.Bottom = 10
			.SetBounds 200, 10, 405, 306
			.Designer = @This
			.Columns.Add ML("Template"), , 500, cfLeft
			.OnItemActivate = @lvTemplates_ItemActivate_
			.OnSelectedItemChanged = @lvTemplates_SelectedItemChanged_
			.Parent = @tpNew
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = ML("Cancel")
			.Align = DockStyle.alRight
			.ExtraMargins.Bottom = 10
			.ExtraMargins.Top = 0
			.ExtraMargins.Right = 10
			.SetBounds 382, 274, 88, 21
			.Designer = @This
			.OnClick = @cmdCancel_Click_
			.Parent = @pnlBottom
		End With
		' cmdOK
		With cmdOK
			.Name = "cmdOK"
			.Text = ML("OK")
			.Align = DockStyle.alRight
			.ExtraMargins.Top = 0
			.ExtraMargins.Right = 10
			.ExtraMargins.Bottom = 10
			.SetBounds 290, 274, 88, 21
			'.Caption = ML("OK")
			.Designer = @This
			.OnClick = @cmdOK_Click_
			.Parent = @pnlBottom
		End With
		' tpExisting
		With tpExisting
			.Name = "tpExisting"
			.Text = ML("Existing")
			.TabIndex = 6
			.UseVisualStyleBackColor = True
			.SetBounds 0, -10, 496, 275
			.Parent = @TabControl1
		End With
		' tpRecent
		With tpRecent
			.Name = "tpRecent"
			.Text = ML("Recent")
			.TabIndex = 7
			.UseVisualStyleBackColor = True
			.SetBounds 0, 0, 446, 255
			.Parent = @TabControl1
		End With
		' lvRecent
		With lvRecent
			.Name = "lvRecent"
			.Text = "ListView1"
			.TabIndex = 8
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 10
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.ExtraMargins.Bottom = 10
			.Images = @imgList
			.SmallImages = @imgList
			.SetBounds 130, 10, 475, 306
			.Parent = @tpRecent
			.Columns.Add ML("File"), , 150
			.Designer = @This
			.OnItemActivate = @lvRecent_ItemActivate_
			.Columns.Add ML("Path"), , 300
		End With
		' OpenFileControl1
		With OpenFileControl1
			.Name = "OpenFileControl1"
			.Text = "OpenFileControl1"
			.Align = DockStyle.alClient
			.SetBounds 0, 0, 615, 326
			.Designer = @This
			.InitialDir = GetFullPath(*ProjectsPath)
			.Filter = ML("FreeBasic Files") & " (*.vfs, *.vfp, *.bas, *.frm, *.bi, *.inc, *.rc)|*.vfs;*.vfp;*.bas;*.frm;*.bi;*.inc;*.rc|" & ML("VisualFBEditor Project Group") & " (*.vfs)|*.vfs|" & ML("VisualFBEditor Project") & " (*.vfp)|*.vfp|" & ML("FreeBasic Module") & " (*.bas)|*.bas|" & ML("FreeBasic Form Module") & " (*.frm)|*.frm|" & ML("FreeBasic Include File") & " (*.bi)|*.bi|" & ML("Other Include File") & " (*.inc)|*.inc|" & ML("Resource File") & " (*.rc)|*.rc|" & ML("All Files") & "|*.*|"
			.OnFileActivate = @OpenFileControl1_FileActivate_
			.Parent = @tpExisting
		End With
		' pnlBottom
		With pnlBottom
			.Name = "pnlBottom"
			.Text = "Panel1"
			.TabIndex = 9
			.Align = DockStyle.alBottom
			.SetBounds 20, 290, 450, 30
			.Parent = @This
		End With
		' tvRecent
		With tvRecent
			.Name = "tvRecent"
			.Text = "tvRecent"
			.TabIndex = 10
			.Align = DockStyle.alLeft
			.ExtraMargins.Top = 10
			.ExtraMargins.Left = 10
			.ExtraMargins.Bottom = 10
			.HideSelection = False
			.SetBounds 10, 10, 110, 306
			.Parent = @tpRecent
			.Nodes.Add ML("Sessions")
			.Nodes.Add ML("Folders")
			.Nodes.Add ML("Projects")
			.Nodes.Add ML("Files")
			.Designer = @This
			.OnSelChanged = @tvRecent_SelChanged_
		End With
		' pnlSaveLocation
		With pnlSaveLocation
			.Name = "pnlSaveLocation"
			.Text = "Panel1"
			.TabIndex = 12
			.SetBounds 0, -1, 390, 30
			.Visible = False
			.Parent = @pnlBottom
		End With
		' lblSaveLocation
		With lblSaveLocation
			.Name = "lblSaveLocation"
			.Text = ML("Save location:")
			.TabIndex = 13
			.Caption = ML("Save location:")
			.SetBounds 10, 3, 110, 20
			.Parent = @pnlSaveLocation
		End With
		' txtSaveLocation
		With txtSaveLocation
			.Name = "txtSaveLocation"
			.Text = "./Projects/Project1"
			.TabIndex = 14
			.SetBounds 120, 1, 204, 20
			.Parent = @pnlSaveLocation
		End With
		' cmdSaveLocation
		With cmdSaveLocation
			.Name = "cmdSaveLocation"
			.Text = "..."
			.TabIndex = 15
			.Caption = "..."
			.SetBounds 325, 0, 30, 22
			.Designer = @This
			.OnClick = @cmdSaveLocation_Click_
			.Parent = @pnlSaveLocation
		End With
	End Constructor
	
Private Sub frmTemplates.TabControl1_SelChange_(ByRef Sender As TabControl, NewIndex As Integer)
	*Cast(frmTemplates Ptr, Sender.Designer).TabControl1_SelChange(Sender, NewIndex)
End Sub

	Dim Shared fTemplates As frmTemplates
	pfTemplates = @fTemplates
	
	#ifndef _NOT_AUTORUN_FORMS_
		fForm1.Show
		
		App.Run
	#endif
'#End Region

Private Sub frmTemplates.cmdCancel_Click_(ByRef Sender As Control)
	*Cast(frmTemplates Ptr, Sender.Designer).cmdCancel_Click(Sender)
End Sub
Private Sub frmTemplates.cmdCancel_Click(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	Me.CloseForm
End Sub

Private Sub frmTemplates.cmdOK_Click_(ByRef Sender As Control)
	*Cast(frmTemplates Ptr, Sender.Designer).cmdOK_Click(Sender)
End Sub
Private Sub frmTemplates.cmdOK_Click(ByRef Sender As Control)
	SelectedTemplate = ""
	SelectedFile = ""
	Select Case TabControl1.SelectedTabIndex
	Case 0
		If lvTemplates.SelectedItemIndex > -1 Then
			If pnlSaveLocation.Visible Then
				If FolderExists(GetFullPath(txtSaveLocation.Text)) Then
					MsgBox ML("Selected folder exists, change the project folder!")
					Me.BringToFront
				ElseIf Not FolderExists(GetFolderName(GetFullPath(txtSaveLocation.Text), False)) Then
					MsgBox ML("Parent folder not exists, change the parent folder!")
					Me.BringToFront
				Else
					SelectedTemplate = ExePath & Slash & "Templates" & Slash & Templates.Item(lvTemplates.SelectedItemIndex)
					Dim As UString TemplateFolderName = ..Left(SelectedTemplate, Len(SelectedTemplate) - 4)
					SelectedFolder = GetFullPath(txtSaveLocation.Text)
					FolderCopy TemplateFolderName, SelectedFolder
					Dim As WString * MAX_PATH SrcPath, DestPath
					SrcPath = SelectedFolder & Slash & GetFileName(SelectedTemplate)
					DestPath = SelectedFolder & Slash & GetFileName(SelectedFolder) & ".vfp"
					#ifdef __USE_GTK__
						.Name(SrcPath, DestPath)
					#else
						MoveFile @SrcPath, @DestPath
					#endif
					ModalResult = ModalResults.OK
					Me.CloseForm
				End If
			Else
				SelectedTemplate = ExePath & Slash & "Templates" & Slash & Templates.Item(lvTemplates.SelectedItemIndex)
				ModalResult = ModalResults.OK
				Me.CloseForm
			End If
		Else
			MsgBox ML("Select template!")
			Me.BringToFront
		End If
	Case 1
		If OpenFileControl1.FileName <> "" Then
			SelectedFile = OpenFileControl1.FileName
			ModalResult = ModalResults.OK
			Me.CloseForm
		Else
			MsgBox ML("Select file!")
			Me.BringToFront
		End If
	Case 2
		If lvRecent.SelectedItemIndex > -1 Then
			SelectedFile = lvRecent.ListItems.Item(lvRecent.SelectedItemIndex)->Text(1)
			ModalResult = ModalResults.OK
			Me.CloseForm
		Else
			MsgBox ML("Select recent file!")
			Me.BringToFront
		End If
	End Select
End Sub

Private Sub frmTemplates.tvTemplates_SelChanged_(ByRef Sender As TreeView, ByRef Item As TreeNode)
	*Cast(frmTemplates Ptr, Sender.Designer).tvTemplates_SelChanged(Sender, Item)
End Sub
Private Sub frmTemplates.tvTemplates_SelChanged(ByRef Sender As TreeView, ByRef Item As TreeNode)
	If FormClosing Then Exit Sub
	lvTemplates.ListItems.Clear
	Templates.Clear
	Dim As String f, TemplateName
	If Item.Name = "Projects" Then
		f = Dir(ExePath & "/Templates/Projects/*.vfp")
		While f <> ""
			TemplateName = ..Left(f, IfNegative(InStr(f, ".") - 1, Len(f)))
			lvTemplates.ListItems.Add ML(TemplateName), "Project"
			If FileExists(ExePath & "/Templates/Projects/" & TemplateName & "/" & f) Then
				Templates.Add "Projects" & Slash & f, lvTemplates.ListItems.Item(lvTemplates.ListItems.Count - 1)
			Else
				Templates.Add "Projects" & Slash & f
			End If
			f = Dir()
		Wend
	Else
		Dim As String IconName
		f = Dir(ExePath & "/Templates/Files/*")
		While f <> ""
			TemplateName = ..Left(f, IfNegative(InStr(f, ".") - 1, Len(f)))
			If EndsWith(LCase(f), ".frm") Then
				IconName = "Form"
			ElseIf f = "User Control.bas" Then
				IconName = "UserControl"
			ElseIf EndsWith(LCase(f), ".bas") Then
				IconName = "Module"
			ElseIf EndsWith(LCase(f), ".rc") Then
				IconName = "Resource"
			Else
				IconName = "File"
			End If
			lvTemplates.ListItems.Add TemplateName, IconName
			Templates.Add "Files" & Slash & f
			f = Dir()
		Wend
	End If
End Sub

Private Sub frmTemplates.lvTemplates_ItemActivate_(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	*Cast(frmTemplates Ptr, Sender.Designer).lvTemplates_ItemActivate(Sender, ItemIndex)
End Sub
Private Sub frmTemplates.lvTemplates_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	cmdOK_Click cmdOK
End Sub

Private Sub frmTemplates.Form_Show_(ByRef Sender As Form)
	*Cast(frmTemplates Ptr, Sender.Designer).Form_Show(Sender)
End Sub
Private Sub frmTemplates.Form_Show(ByRef Sender As Form)
	ModalResult = ModalResults.Cancel
	tvTemplates.Nodes.Clear
	If OnlyFiles = False Then
		tvTemplates.Nodes.Add ML("Projects"), "Projects"
	End If
	tvTemplates.Nodes.Add ML("Files"), "Files"
	tvTemplates_SelChanged tvTemplates, *tvTemplates.Nodes.Item(0)
	tvRecent_SelChanged tvRecent, *tvRecent.Nodes.Item(0)
	TabControl1.SelectedTabIndex = 0
	'This.Width = This.Width + 1
	Var n = 0
	Dim As String ProjectName = "Project"
	Dim NewName As String
	Do
		n = n + 1
		NewName = ProjectName & Str(n)
	Loop While FolderExists(*ProjectsPath & Slash & NewName)
	txtSaveLocation.Text = Replace(*ProjectsPath, BackSlash, Slash) & Slash & NewName
End Sub

Private Sub frmTemplates.Form_Close_(ByRef Sender As Form, ByRef Action As Integer)
	*Cast(frmTemplates Ptr, Sender.Designer).Form_Close(Sender, Action)
End Sub
Private Sub frmTemplates.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	OnlyFiles = False
End Sub

Private Sub frmTemplates.tvRecent_SelChanged_(ByRef Sender As TreeView, ByRef Item As TreeNode)
	*Cast(frmTemplates Ptr, Sender.Designer).tvRecent_SelChanged(Sender, Item)
End Sub
Private Sub frmTemplates.tvRecent_SelChanged(ByRef Sender As TreeView, ByRef Item As TreeNode)
	Dim As String MRUName
	lvRecent.ListItems.Clear
	Select Case Item.Index
	Case 0: MRUName = "Session"
	Case 1: MRUName = "Folder"
	Case 2: MRUName = "Project"
	Case 3: MRUName = "File"
	End Select
	Dim sTmp As WString * 1024
	For i As Integer = 0 To miRecentMax
		sTmp = iniSettings.ReadString("MRU" & MRUName & "s", "MRU" & MRUName & "_0" & WStr(i), "")
		If Trim(sTmp) <> "" Then
			lvRecent.ListItems.Add GetFileName(sTmp), GetIconName(sTmp)
			lvRecent.ListItems.Item(i)->Text(1) = sTmp
		End If
	Next
End Sub

Private Sub frmTemplates.lvRecent_ItemActivate_(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	*Cast(frmTemplates Ptr, Sender.Designer).lvRecent_ItemActivate(Sender, ItemIndex)
End Sub
Private Sub frmTemplates.lvRecent_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	cmdOK_Click cmdOK
End Sub

Private Sub frmTemplates.OpenFileControl1_FileActivate_(ByRef Sender As OpenFileControl)
	*Cast(frmTemplates Ptr, Sender.Designer).OpenFileControl1_FileActivate(Sender)
End Sub
Private Sub frmTemplates.OpenFileControl1_FileActivate(ByRef Sender As OpenFileControl)
	cmdOK_Click cmdOK
End Sub

Private Sub frmTemplates.TabControl1_SelChange(ByRef Sender As TabControl, NewIndex As Integer)
	'If  NewIndex = 1 Then 
		'OpenFileControl1.SetBounds TabControl1.Left, TabControl1.Top, TabControl1.Width, TabControl1.Height
		'TabControl1.RequestAlign
	'End If 
End Sub

Private Sub frmTemplates.cmdSaveLocation_Click_(ByRef Sender As Control)
	*Cast(frmTemplates Ptr, Sender.Designer).cmdSaveLocation_Click(Sender)
End Sub
Private Sub frmTemplates.cmdSaveLocation_Click(ByRef Sender As Control)
	Dim BrowseD As FolderBrowserDialog
	BrowseD.InitialDir = GetFullPath(Replace(GetFolderName(txtSaveLocation.Text), BackSlash, Slash))
	If BrowseD.Execute Then
		txtSaveLocation.Text = BrowseD.Directory & Slash & Mid(txtSaveLocation.Text, InStrRev(Replace(txtSaveLocation.Text, BackSlash, Slash), Slash) + 1)
	End If
End Sub

Private Sub frmTemplates.lvTemplates_SelectedItemChanged_(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	*Cast(frmTemplates Ptr, Sender.Designer).lvTemplates_SelectedItemChanged(Sender, ItemIndex)
End Sub
Private Sub frmTemplates.lvTemplates_SelectedItemChanged(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	If lvTemplates.SelectedItemIndex > -1 Then
		pnlSaveLocation.Visible = Templates.Object(lvTemplates.SelectedItemIndex) > 0
	End If
End Sub
