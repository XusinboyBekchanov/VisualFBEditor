'#Region "Form"
	#include once "frmSave.bi"
	Dim Shared As Double SaveTime
	Constructor frmSave
		' frmSave
		With This
			.Name = "frmSave"
			.Text = "Visual FB Editor"
			'.Caption = "Visual FB Editor"
			.BorderStyle = FormBorderStyle.FixedDialog
			#ifdef __USE_GTK__
				This.Icon.LoadFromFile(ExePath & "/Resources/VisualFBEditor.ico")
			#else
				This.Icon.LoadFromResourceID(1)
			#endif
			.FormStyle = FormStyles.fsStayOnTop
			.MaximizeBox = False
			.MinimizeBox = False
			.DefaultButton = @cmdYes
			.CancelButton = @cmdCancel
			.ModalResult = ModalResults.Cancel
			.StartPosition = FormStartPosition.CenterParent
			.Designer = @This
			.OnShow = @Form_Show_
			.OnCreate = @Form_Create_
			.SetBounds 0, 0, 400, 300
		End With
		' lstFiles
		With lstFiles
			.Name = "lstFiles"
			.SelectionMode = SelectionModes.smMultiExtended
			.TabIndex = 1
			.SetBounds 10, 30, 290, 225
			.Parent = @This
		End With
		' lblMessage
		With lblMessage
			.Name = "lblMessage"
			.Text = ML("Save changes to the following files?")
			.TabIndex = 0
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
		' TimerComponent1
		With TimerComponent1
			.Name = "TimerComponent1"
			.Interval = 200
			.SetBounds 330, 120, 16, 16
			.Designer = @This
			.OnTimer = @_TimerComponent1_Timer
			.Parent = @This
		End With
	End Constructor
	
	Private Sub frmSave._TimerComponent1_Timer(ByRef Sender As TimerComponent)
		(*Cast(frmSave Ptr, Sender.Designer)).TimerComponent1_Timer(Sender)
	End Sub
	
	Dim Shared fSave As frmSave
	pfSave = @fSave
'#End Region

Private Sub frmSave.cmdYes_Click_(ByRef Sender As Control)
	(*Cast(frmSave Ptr, Sender.Designer)).cmdYes_Click(Sender)
End Sub
Private Sub frmSave.cmdYes_Click(ByRef Sender As Control)
	ModalResult = ModalResults.Yes
	SelectedItems.Clear
	For i As Integer = lstFiles.ItemCount - 1 To 0 Step -1
		If lstFiles.Selected(i) Then
			SelectedItems.Add lstFiles.ItemData(i)
		End If
	Next
	Me.CloseForm
End Sub

Private Sub frmSave.cmdNo_Click_(ByRef Sender As Control)
	(*Cast(frmSave Ptr, Sender.Designer)).cmdNo_Click(Sender)
End Sub
Private Sub frmSave.cmdNo_Click(ByRef Sender As Control)
	ModalResult = ModalResults.No
	Me.CloseForm
End Sub

Private Sub frmSave.cmdCancel_Click_(ByRef Sender As Control)
	(*Cast(frmSave Ptr, Sender.Designer)).cmdCancel_Click(Sender)
End Sub
Private Sub frmSave.cmdCancel_Click(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	Me.CloseForm
End Sub

Private Sub frmSave.Form_Show_(ByRef Sender As Form)
	(*Cast(frmSave Ptr, Sender.Designer)).Form_Show(Sender)
End Sub
Private Sub frmSave.Form_Show(ByRef Sender As Form)
	SaveTime = Timer
End Sub

Private Sub frmSave.Form_Create_(ByRef Sender As Control)
	(*Cast(frmSave Ptr, Sender.Designer)).Form_Create(Sender)
End Sub
Private Sub frmSave.Form_Create(ByRef Sender As Control)
	SelectedItems.Clear
	lstFiles.SelectAll
End Sub

Private Sub frmSave.TimerComponent1_Timer(ByRef Sender As TimerComponent)
	If Timer - SaveTime > 10 Then 
		cmdYes_Click(cmdYes)
		SaveTime = Timer
	Else
		This.Text = "Visual FB Editor - Count down" & Str(10 - Timer + SaveTime) 
	End If
	
End Sub
