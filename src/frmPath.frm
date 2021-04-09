'#########################################################
'#  frmPath.bas                                          #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#########################################################

#include once "frmPath.bi"

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
			.OnShow = @Form_Show
			.OnClose = @Form_Close
			.SetBounds 0, 0, 462, 177
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = ML("Cancel")
			.SetBounds 336, 116, 112, 24
			.OnClick = @cmdCancel_Click
			.Parent = @This
		End With
		' txtVersion
		With txtVersion
			.Name = "txtVersion"
			.Text = ""
			.SetBounds 100, 48, 348, 24
			.Parent = @This
		End With
		' lblVersion
		With lblVersion
			.Name = "lblVersion"
			.Text = ML("Version") & ":"
			.SetBounds 8, 50, 84, 24
			.Parent = @This
		End With
		' lblPath
		With lblPath
			.Name = "lblPath"
			.Text = ML("Path") & ":"
			.SetBounds 8, 18, 84, 24
			.Parent = @This
		End With
		' txtPath
		With txtPath
			.Name = "txtPath"
			.Text = ""
			.SetBounds 100, 16, 316, 24
			.Parent = @This
		End With
		' cmdPath
		With cmdPath
			.Name = "cmdPath"
			.Text = "..."
			.SetBounds 416, 16, 32, 24
			.Caption = "..."
			.OnClick = @cmdPath_Click
			.Parent = @This
		End With
		' cmdOK
		With cmdOK
			.Name = "cmdOK"
			.Text = ML("OK")
			.SetBounds 216, 116, 112, 24
			.OnClick = @cmdOK_Click
			.Parent = @This
		End With
		' lblCommandLine
		With lblCommandLine
			.Name = "lblCommandLine"
			.Text = ML("Command line") & ":"
			.SetBounds 8, 82, 88, 24
			.Parent = @This
		End With
		' txtCommandLine
		With txtCommandLine
			.Name = "txtCommandLine"
			.SetBounds 100, 80, 128, 24
			.Text = ""
			.Parent = @This
		End With
		' lblExtensions
		With lblExtensions
			.Name = "lblExtensions"
			.Text = ML("Extensions") & ":"
			.SetBounds 238, 82, 88, 24
			.Caption = ML("Extensions") & ":"
			.Parent = @This
		End With
		' txtExtensions
		With txtExtensions
			.Name = "txtExtensions"
			.SetBounds 320, 80, 128, 24
			.Text = ""
			.Parent = @This
		End With
		' cboType
		With cboType
			.Name = "cboType"
			.Text = ""
			.TabIndex = 11
			.SetBounds 100, 80, 130, 21
			.Visible = false
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frPath As frmPath
	pfPath = @frPath
'#End Region

Private Sub frmPath.cmdOK_Click(ByRef Sender As Control)
	If Not frPath.ChooseFolder AndAlso Trim(frPath.txtVersion.Text) = "" Then
		MsgBox ML("Enter version of program!")
		frPath.BringToFront()
		Exit Sub
	ElseIf Trim(frPath.txtPath.Text) = "" Then
		MsgBox ML("Select path of program!")
		frPath.BringToFront()
		Exit Sub
	End If
	frPath.ModalResult = ModalResults.OK
	frPath.CloseForm
End Sub

Private Sub frmPath.cmdCancel_Click(ByRef Sender As Control)
	frPath.ModalResult = ModalResults.Cancel
	frPath.CloseForm
End Sub

Private Sub frmPath.cmdPath_Click(ByRef Sender As Control)
	With frPath
		Dim As UString FolderName = GetFolderName(pApp->FileName)
		If .ChooseFolder Then
			If .BrowseD.Execute Then
				If StartsWith(.BrowseD.Directory, FolderName) Then
					.txtPath.Text = "." & Slash & Mid(.BrowseD.Directory, Len(FolderName) + 1)
				Else
					.txtPath.Text = .BrowseD.Directory
				End If
			End If
		Else
			.OpenD.Filter = ML("All Files") & "|*.*;"
			If .OpenD.Execute Then
				If StartsWith(.OpenD.FileName, FolderName) Then
					.txtPath.Text = "." & Slash & Mid(.OpenD.FileName, Len(FolderName) + 1)
				Else
					.txtPath.Text = .OpenD.FileName
				End If
				If EndsWith(.OpenD.FileName, ".chm") OrElse .SetFileNameToVersion Then
					.txtVersion.Text = Left(GetFileName(.OpenD.FileName), Len(GetFileName(.OpenD.FileName)) - 4)
				Else
					.txtVersion.Text = GetFileName(GetFolderName(.OpenD.FileName, False))
					If .txtVersion.Text = "bin" Then
						.txtVersion.Text = GetFileName(GetFolderName(GetFolderName(.OpenD.FileName, False), False))
					End If
				End If
			End If
		End If
		.BringToFront()
	End With
End Sub

Private Sub frmPath.Form_Show(ByRef Sender As Form)
	frPath.lblVersion.Visible = Not frPath.ChooseFolder
	frPath.txtVersion.Visible = Not frPath.ChooseFolder
	frPath.lblCommandLine.Visible = Not (frPath.WithoutCommandLine OrElse frPath.ChooseFolder)
	frPath.txtCommandLine.Visible = Not (frPath.WithoutCommandLine OrElse frPath.ChooseFolder)
	frPath.lblExtensions.Visible = frPath.WithExtensions
	frPath.txtExtensions.Visible = frPath.WithExtensions
End Sub

Private Sub frmPath.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	frPath.ChooseFolder = False
	frPath.WithoutCommandLine = False
	frPath.WithExtensions = False
End Sub
