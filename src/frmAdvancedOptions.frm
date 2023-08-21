#include once "frmAdvancedOptions.bi"

'#Region "Form"
	Constructor frmAdvancedOptions
		' frmAdvancedOptions
		With This
			.Name = "frmAdvancedOptions"
			.Text = ML("Advanced Options")
			.Name = "frmAdvancedOptions"
			.StartPosition = FormStartPosition.CenterParent
			.BorderStyle = FormBorderStyle.FixedDialog
			.DefaultButton = @cmdOK
			.CancelButton = @cmdCancel
			.SetBounds 0, 0, 340, 468
		End With
		' Label1
		With Label1
			.Name = "Label1"
			.Text = ML("Warning: enabling the following optimizatons will help reduce unused code")
			.TabIndex = 0
			.SetBounds 10, 10, 320, 30
			.Parent = @This
		End With
		' chkShowUnusedLabelWarnings
		With chkShowUnusedLabelWarnings
			.Name = "chkShowUnusedLabelWarnings"
			.Text = ML("Show unused label warnings")
			.TabIndex = 1
			.SetBounds 10, 50, 240, 20
			.Parent = @This
		End With
		' chkShowUnusedFunctionWarnings
		With chkShowUnusedFunctionWarnings
			.Name = "chkShowUnusedFunctionWarnings"
			.Text = ML("Show unused function warnings")
			.TabIndex = 2
			.SetBounds 10, 70, 240, 20
			.Parent = @This
		End With
		' chkShowUnusedVariableWarnings
		With chkShowUnusedVariableWarnings
			.Name = "chkShowUnusedVariableWarnings"
			.Text = ML("Show unused variable warnings")
			.TabIndex = 3
			.SetBounds 10, 90, 240, 20
			.Parent = @This
		End With
		' chkShowUnusedButSetVariableWarnings
		With chkShowUnusedButSetVariableWarnings
			.Name = "chkShowUnusedButSetVariableWarnings"
			.Text = ML("Show unused but set variable warnings")
			.TabIndex = 4
			.SetBounds 10, 110, 240, 20
			.Parent = @This
		End With
		' chkShowMainWarnings
		With chkShowMainWarnings
			.Name = "chkShowMainWarnings"
			.Text = ML("Show main warnings")
			.TabIndex = 5
			.SetBounds 10, 130, 240, 20
			.Parent = @This
		End With
		' pnlCommands
		With pnlCommands
			.Name = "pnlCommands"
			.Text = "pnlCommands"
			.TabIndex = 6
			.SetBounds 0, 397, 334, 42
			.Align = DockStyle.alBottom
			.Parent = @This
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = ML("&Cancel")
			.Align = DockStyle.alRight
			.ExtraMargins.Bottom = 10
			.ExtraMargins.Right = 10
			.ExtraMargins.Top = 10
			.TabIndex = 8
			.SetBounds 244, 10, 80, 22
			.Designer = @This
			.OnClick = @cmdCancel_Click_
			.Parent = @pnlCommands
		End With
		' cmdOK
		With cmdOK
			.Name = "cmdOK"
			.Text = ML("&OK")
			.Align = DockStyle.alRight
			.ExtraMargins.Bottom = 10
			.ExtraMargins.Right = 10
			.ExtraMargins.Top = 10
			.TabIndex = 7
			.SetBounds 154, 10, 80, 22
			.Default = True
			.Designer = @This
			.OnClick = @cmdOK_Click_
			.Parent = @pnlCommands
		End With
	End Constructor
	
	Dim Shared fAdvancedOptions As frmAdvancedOptions
	pfAdvancedOptions = @fAdvancedOptions
	
	#ifndef _NOT_AUTORUN_FORMS_
		fAdvancedOptions.Show
		
		App.Run
	#endif
'#End Region

Private Sub frmAdvancedOptions.cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmAdvancedOptions Ptr, Sender.Designer)).cmdOK_Click(Sender)
End Sub
Private Sub frmAdvancedOptions.cmdOK_Click(ByRef Sender As Control)
	If ProjectTreeNode <> 0 Then
		Dim As ProjectElement Ptr ppe = ProjectTreeNode->Tag
		If ppe = 0 Then
			ppe = _New(ProjectElement)
			WLet(ppe->FileName, "")
		End If
		ProjectTreeNode->Tag = ppe
		ppe->ShowUnusedLabelWarnings = chkShowUnusedLabelWarnings.Checked
		ppe->ShowUnusedFunctionWarnings = chkShowUnusedFunctionWarnings.Checked
		ppe->ShowUnusedVariableWarnings = chkShowUnusedVariableWarnings.Checked
		ppe->ShowUnusedButSetVariableWarnings = chkShowUnusedButSetVariableWarnings.Checked
		ppe->ShowMainWarnings = chkShowMainWarnings.Checked
	End If
	Me.CloseForm
End Sub

Private Sub frmAdvancedOptions.cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmAdvancedOptions Ptr, Sender.Designer)).cmdCancel_Click(Sender)
End Sub
Private Sub frmAdvancedOptions.cmdCancel_Click(ByRef Sender As Control)
	Me.CloseForm
End Sub
