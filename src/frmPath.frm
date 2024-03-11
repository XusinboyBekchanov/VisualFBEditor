'#########################################################
'#  frmPath.bas                                          #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#########################################################

#include once "frmPath.bi"
#include once "frmImageManager.bi"
#include once "frmCompilerOptions.frm"

'#Region "Form"
	Constructor frmPath
		' frmPath
		With This
			.Name = "frmPath"
			.Text = ML("Path")
			.StartPosition = FormStartPosition.CenterParent
			.BorderStyle = FormBorderStyle.FixedDialog
			.MaximizeBox = False
			.MinimizeBox = False
			.Designer = @This
			.OnShow = @Form_Show_
			.OnClose = @Form_Close_
			.OnCreate = @_Form_Create
			.SetBounds 0, 0, 462, 177
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = ML("Cancel")
			.TabIndex = 10
			.SetBounds 336, 116, 112, 24
			.Designer = @This
			.OnClick = @cmdCancel_Click_
			.Parent = @This
		End With
		' txtVersion
		With txtVersion
			.Name = "txtVersion"
			.Text = ""
			.TabIndex = 4
			.SetBounds 100, 48, 348, 24
			.Parent = @This
		End With
		' lblVersion
		With lblVersion
			.Name = "lblVersion"
			.Text = ML("Version") & ":"
			.TabIndex = 3
			.SetBounds 8, 50, 84, 24
			.Parent = @This
		End With
		' lblPath
		With lblPath
			.Name = "lblPath"
			.Text = ML("Path") & ":"
			.TabIndex = 0
			.SetBounds 8, 18, 84, 24
			.Parent = @This
		End With
		' txtPath
		With txtPath
			.Name = "txtPath"
			.Text = ""
			.TabIndex = 1
			.SetBounds 100, 16, 316, 24
			.Parent = @This
		End With
		' cmdPath
		With cmdPath
			.Name = "cmdPath"
			.Text = "..."
			.TabIndex = 2
			.SetBounds 416, 16, 32, 24
			.Caption = "..."
			.Designer = @This
			.OnClick = @cmdPath_Click_
			.Parent = @This
		End With
		' cmdOK
		With cmdOK
			.Name = "cmdOK"
			.Text = ML("OK")
			.TabIndex = 9
			.SetBounds 216, 116, 112, 24
			.Designer = @This
			.OnClick = @cmdOK_Click_
			.Parent = @This
		End With
		' lblCommandLine
		With lblCommandLine
			.Name = "lblCommandLine"
			.Text = ML("Command line") & ":"
			.TabIndex = 5
			.SetBounds 8, 82, 88, 24
			.Parent = @This
		End With
		' txtCommandLine
		With txtCommandLine
			.Name = "txtCommandLine"
			.TabIndex = 11
			.SetBounds 100, 80, 128, 24
			.Text = ""
			.Parent = @This
		End With
		' lblExtensions
		With lblExtensions
			.Name = "lblExtensions"
			.Text = ML("Extensions") & ":"
			.TabIndex = 7
			.SetBounds 238, 82, 88, 24
			.Caption = ML("Extensions") & ":"
			.Parent = @This
		End With
		' txtExtensions
		With txtExtensions
			.Name = "txtExtensions"
			.TabIndex = 8
			.SetBounds 320, 80, 128, 24
			.Text = ""
			.Parent = @This
		End With
		' cboType
		With cboType
			.Name = "cboType"
			.Text = ""
			.TabIndex = 6
			.SetBounds 100, 80, 130, 21
			.Visible = False
			.Parent = @This
		End With
		' BrowseD
		With BrowseD
			.Name = "BrowseD"
			.SetBounds 0, 0, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' OpenD
		With OpenD
			.Name = "OpenD"
			.SetBounds 0, 0, 16, 16
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Private Sub frmPath._Form_Create(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		(*Cast(frmPath Ptr, Sender.Designer)).Form_Create(Sender)
	End Sub
	
	Dim Shared frPath As frmPath
	Dim Shared frPathImageList As frmPath
	pfPath = @frPath
	pfPathImageList = @frPathImageList
'#End Region

Private Sub frmPath.cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmPath Ptr, Sender.Designer)).cmdOK_Click(Sender)
End Sub
Private Sub frmPath.cmdOK_Click(ByRef Sender As Control)
	If Not ChooseFolder AndAlso Trim(txtVersion.Text) = "" Then
		If ForConfiguration Then
			MsgBox ML("Enter name of configuration!")
		Else
			MsgBox ML("Enter version of program!")
		End If
		This.BringToFront()
		Exit Sub
	ElseIf Trim(This.txtPath.Text) = "" Then
		MsgBox ML("Select path of program!")
		This.BringToFront()
		Exit Sub
	End If
	txtCommandLineText = txtCommandLine.Text
	txtExtensionsText = txtExtensions.Text
	cboTypeText = cboType.Text
	This.ModalResult = ModalResults.OK
	This.CloseForm
End Sub

Private Sub frmPath.cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmPath Ptr, Sender.Designer)).cmdCancel_Click(Sender)
End Sub
Private Sub frmPath.cmdCancel_Click(ByRef Sender As Control)
	This.ModalResult = ModalResults.Cancel
	This.CloseForm
End Sub

Private Sub frmPath.cmdPath_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmPath Ptr, Sender.Designer)).cmdPath_Click(Sender)
End Sub
Private Sub frmPath.cmdPath_Click(ByRef Sender As Control)
	With This
		If ForConfiguration Then
			If frmCompilerOptions.ShowModal(Me) = ModalResults.OK Then
				.txtPath.Text = ""
				For i As Integer = 0 To frmCompilerOptions.lvCompilerOptions.ListItems.Count - 1
					If frmCompilerOptions.lvCompilerOptions.ListItems.Item(i)->Checked Then
						.txtPath.Text = RTrim(.txtPath.Text) & " " & frmCompilerOptions.lvCompilerOptions.ListItems.Item(i)->Text(0)
					End If
				Next
				frmCompilerOptions.CloseForm
				Me.BringToFront
			End If
		ElseIf .WithKey AndAlso .cboType.ItemIndex = 0 Then
			If pfImageManager->ShowModal(Me) = ModalResults.OK Then
				If pfImageManager->SelectedItem <> 0 Then
					.txtPath.Text = pfImageManager->SelectedItem->Text(0)
					.txtVersion.Text = .txtPath.Text
				End If
			End If
		Else
			Dim As UString FolderName
			If .WithType Then
				FolderName = GetFolderName(.ExeFileName)
			Else
				FolderName = GetFolderName(pApp->FileName)
			End If
			If .ChooseFolder Then
				.BrowseD.InitialDir = GetFullPath(.txtPath.Text)
				If .BrowseD.Execute Then
					If FolderName <> "" AndAlso StartsWith(.BrowseD.Directory, FolderName) Then
						.txtPath.Text = "." & Slash & Mid(.BrowseD.Directory, Len(FolderName) + 1)
					Else
						.txtPath.Text = .BrowseD.Directory
					End If
				End If
			Else
				.OpenD.Filter = ML("All Files") & "|*.*;"
				If .OpenD.Execute Then
					If FolderName <> "" AndAlso StartsWith(.OpenD.FileName, FolderName) Then
						.txtPath.Text = "." & Slash & Mid(.OpenD.FileName, Len(FolderName) + 1)
					Else
						.txtPath.Text = .OpenD.FileName
					End If
					If EndsWith(.OpenD.FileName, ".chm") OrElse .SetFileNameToVersion Then
						.txtVersion.Text = ..Left(GetFileName(.OpenD.FileName), Len(GetFileName(.OpenD.FileName)) - 4)
					Else
						.txtVersion.Text = GetFileName(GetFolderName(.OpenD.FileName, False))
						If .txtVersion.Text = "bin" Then
							.txtVersion.Text = GetFileName(GetFolderName(GetFolderName(.OpenD.FileName, False), False))
						End If
					End If
					If .WithType Then
						If EndsWith(LCase(.OpenD.FileName), ".bmp") Then
							.cboType.ItemIndex = 0
						ElseIf EndsWith(LCase(.OpenD.FileName), ".cur") Then
							.cboType.ItemIndex = 1
						ElseIf EndsWith(LCase(.OpenD.FileName), ".ico") Then
							.cboType.ItemIndex = 2
						ElseIf EndsWith(LCase(.OpenD.FileName), ".png") Then
							.cboType.ItemIndex = 3
						Else
							.cboType.ItemIndex = 4
						End If
					End If
				End If
			End If
		End If
		.BringToFront()
	End With
End Sub

Private Sub frmPath.Form_Show_(ByRef Designer As My.Sys.Object, ByRef Sender As Form)
	(*Cast(frmPath Ptr, Sender.Designer)).Form_Show(Sender)
End Sub
Private Sub frmPath.Form_Show(ByRef Sender As Form)
	
End Sub

Private Sub frmPath.Form_Close_(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer)
	(*Cast(frmPath Ptr, Sender.Designer)).Form_Close(Sender, Action)
End Sub
Private Sub frmPath.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	ChooseFolder = False
	ForConfiguration = False
	WithoutVersion = False
	WithoutCommandLine = False
	WithExtensions = False
	WithType = False
End Sub

Private Sub frmPath.Form_Create(ByRef Sender As Control)
	Me.Caption = IIf(ForConfiguration, ML("Build Configurations"), ML("Path"))
	lblVersion.Visible = (Not WithoutVersion) AndAlso Not ChooseFolder
	txtVersion.Visible = (Not WithoutVersion) AndAlso Not ChooseFolder
	lblCommandLine.Visible = Not (WithoutCommandLine OrElse ChooseFolder)
	txtCommandLine.Visible = Not (WithoutCommandLine OrElse ChooseFolder OrElse WithType)
	lblExtensions.Visible = WithExtensions
	txtExtensions.Visible = WithExtensions
	cboType.Visible = WithType
	lblPath.Text = IIf(ForConfiguration, ML("Switches") & ":", IIf(WithKey, ML("Resource Name / Path") & ":", ML("Path") & ":"))
	lblVersion.Text = IIf(ForConfiguration, ML("Name") & ":", IIf(WithType, IIf(WithKey, ML("Key") & ":", ML("Resource Name") & ":"), ML("Version") & ":"))
	lblCommandLine.Text = IIf(WithType, ML("Type") & ":", ML("Command line") & ":")
	txtCommandLineText = ""
	txtExtensionsText = ""
	cboTypeText = ""
End Sub
