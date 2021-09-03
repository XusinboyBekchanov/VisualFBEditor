'#Region "Form"
	#include once "frmSave.bi"
	
	Constructor frmSave
		' frmSave
		With This
			.Name = "frmSave"
			.Text = "Visual FB Editor"
			.Caption = "Visual FB Editor"
			.BorderStyle = FormBorderStyle.FixedDialog
			.MaximizeBox = False
			.MinimizeBox = False
			.DefaultButton = @cmdYes
			.CancelButton = @cmdCancel
			.ModalResult = ModalResults.Cancel
			.StartPosition = FormStartPosition.CenterScreen
			.Designer = @This
			.OnShow = @Form_Show_
			.OnCreate = @Form_Create_
			.SetBounds 0, 0, 400, 300
		End With
		' lstFiles
		With lstFiles
			.Name = "lstFiles"
			.MultiSelect = True
			.TabIndex = 0
			.SetBounds 10, 30, 290, 230
			.Parent = @This
		End With
		' lblMessage
		With lblMessage
			.Name = "lblMessage"
			.Text = ML("Save changes to the following files?")
			.TabIndex = 1
			.SetBounds 10, 10, 240, 20
			.Parent = @This
		End With
		' cmdYes
		With cmdYes
			.Name = "cmdYes"
			.Text = ML("Yes")
			.TabIndex = 2
			.SetBounds 315, 10, 70, 24
			.Caption = ML("Yes")
			.Designer = @This
			.OnClick = @cmdYes_Click_
			.Default = True
			.Parent = @This
		End With
		' cmdNo
		With cmdNo
			.Name = "cmdNo"
			.Text = ML("No")
			.TabIndex = 3
			.SetBounds 315, 41, 70, 24
			.Caption = ML("No")
			.Designer = @This
			.OnClick = @cmdNo_Click_
			.Parent = @This
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = ML("Cancel")
			.TabIndex = 4
			.SetBounds 315, 73, 70, 24
			.Caption = ML("Cancel")
			.Designer = @This
			.OnClick = @cmdCancel_Click_
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared fSave As frmSave
	pfSave = @fSave
'#End Region

Private Sub frmSave.cmdYes_Click_(ByRef Sender As Control)
	*Cast(frmSave Ptr, Sender.Designer).cmdYes_Click(Sender)
End Sub
Private Sub frmSave.cmdYes_Click(ByRef Sender As Control)
	ModalResult = ModalResults.Yes
	Me.CloseForm
End Sub

Private Sub frmSave.cmdNo_Click_(ByRef Sender As Control)
	*Cast(frmSave Ptr, Sender.Designer).cmdNo_Click(Sender)
End Sub
Private Sub frmSave.cmdNo_Click(ByRef Sender As Control)
	ModalResult = ModalResults.No
	Me.CloseForm
End Sub

Private Sub frmSave.cmdCancel_Click_(ByRef Sender As Control)
	*Cast(frmSave Ptr, Sender.Designer).cmdCancel_Click(Sender)
End Sub
Private Sub frmSave.cmdCancel_Click(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	Me.CloseForm
End Sub

Private Sub frmSave.Form_Show_(ByRef Sender As Form)
	*Cast(frmSave Ptr, Sender.Designer).Form_Show(Sender)
End Sub
Private Sub frmSave.Form_Show(ByRef Sender As Form)
	
End Sub

Private Sub frmSave.Form_Create_(ByRef Sender As Control)
	*Cast(frmSave Ptr, Sender.Designer).Form_Create(Sender)
End Sub
Private Sub frmSave.Form_Create(ByRef Sender As Control)
	lstFiles.SelectAll
End Sub
