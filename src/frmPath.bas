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
			.Text = "Path"
			.Caption = "Path"
			.StartPosition = FormStartPosition.CenterParent
			.BorderStyle = FormBorderStyle.FixedDialog
			.MaximizeBox = False
			.MinimizeBox = False
			.SetBounds 0, 0, 462, 148
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = "Cancel"
			.SetBounds 336, 88, 112, 24
			.Caption = "Cancel"
			.OnClick = @cmdCancel_Click
			.Parent = @This
		End With
		' txtVersion
		With txtVersion
			.Name = "txtVersion"
			.Text = ""
			.SetBounds 80, 48, 368, 24
			.Parent = @This
		End With
		' lblVersion
		With lblVersion
			.Name = "lblVersion"
			.Text = "Version:"
			.SetBounds 8, 48, 64, 24
			.Caption = "Version:"
			.Parent = @This
		End With
		' lblPath
		With lblPath
			.Name = "lblPath"
			.Text = "Path:"
			.SetBounds 8, 16, 64, 24
			.Caption = "Path:"
			.Parent = @This
		End With
		' txtPath
		With txtPath
			.Name = "txtPath"
			.Text = ""
			.SetBounds 80, 16, 336, 24
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
			.Text = "OK"
			.SetBounds 216, 88, 112, 24
			.Caption = "OK"
			.OnClick = @cmdOK_Click
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frPath As frmPath
	pfPath = @frPath
'#End Region

Private Sub frmPath.cmdOK_Click(ByRef Sender As Control)
	If Trim(frPath.txtVersion.Text) = "" Then
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
		.OpenD.Filter = ML("All Files") & "|*.*;"
		If .OpenD.Execute Then
			.txtPath.Text = .OpenD.FileName
			If EndsWith(.OpenD.FileName, ".chm") Then
				.txtVersion.Text = Left(GetFileName(.OpenD.FileName), Len(GetFileName(.OpenD.FileName)) - 4)
			Else
				.txtVersion.Text = GetFileName(GetFolderName(.OpenD.FileName, False))
				If .txtVersion.Text = "bin" Then
					.txtVersion.Text = GetFileName(GetFolderName(GetFolderName(.OpenD.FileName, False), False))
				End If
			End If
		End If
		.BringToFront()
	End With
End Sub
