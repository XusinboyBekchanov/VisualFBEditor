'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/Label.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/GroupBox.bi"
	#include once "mff/RadioButton.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/ComboBoxEdit.bi"
	
	Using My.Sys.Forms
	
	Type frmAddProcedureType Extends Form
		Declare Static Sub cmdCancel_Click_(ByRef Sender As Control)
		Declare Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Static Sub cmdOK_Click_(ByRef Sender As Control)
		Declare Sub cmdOK_Click(ByRef Sender As Control)
		Declare Constructor
		
		Dim As Label lblName, lblParameters, lblType
		Dim As TextBox txtName, txtName1
		Dim As CommandButton cmdOK, cmdCancel
		Dim As GroupBox grbType, grbScope, grbAccessControl
		Dim As RadioButton optSub, optFunction, optProperty, optPublicScope, optPrivateScope, optOperator, optPublicAccess, optProtectedAccess, optPrivateAccess, optConstructor, optOperator11
		Dim As CheckBox chkStatic
		Dim As ComboBoxEdit cboType
	End Type
	
	Constructor frmAddProcedureType
		' frmAddProcedure
		With This
			.Name = "frmAddProcedure"
			.Text = ML("Add Procedure")
			.Designer = @This
			.Caption = ML("Add Procedure")
			.BorderStyle = FormBorderStyle.FixedDialog
			.MaximizeBox = False
			.MinimizeBox = False
			.Icon = "1"
			.SetBounds 0, 0, 340, 400
		End With
		' lblName
		With lblName
			.Name = "lblName"
			.Text = ML("Name") & ":"
			.TabIndex = 0
			.Caption = ML("Name") & ":"
			.SetBounds 10, 10, 90, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtName
		With txtName
			.Name = "txtName"
			.Text = ""
			.TabIndex = 1
			.SetBounds 110, 10, 210, 20
			.Designer = @This
			.Parent = @This
		End With
		' cmdOK
		With cmdOK
			.Name = "cmdOK"
			.Text = ML("OK")
			.TabIndex = 2
			.Caption = ML("OK")
			.SetBounds 150, 340, 80, 20
			.Designer = @This
			.OnClick = @cmdOK_Click_
			.Parent = @This
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = ML("Cancel")
			.TabIndex = 3
			.ControlIndex = 2
			.Caption = ML("Cancel")
			.SetBounds 240, 340, 80, 20
			.Designer = @This
			.OnClick = @cmdCancel_Click_
			.Parent = @This
		End With
		' grbType
		With grbType
			.Name = "grbType"
			.Text = ML("Type")
			.TabIndex = 4
			.Caption = ML("Type")
			.SetBounds 10, 160, 310, 80
			.Designer = @This
			.Parent = @This
		End With
		' optSub
		With optSub
			.Name = "optSub"
			.Text = ML("Sub")
			.TabIndex = 5
			.Caption = ML("Sub")
			.SetBounds 10, 20, 100, 20
			.Designer = @This
			.Parent = @grbType
		End With
		' optFunction
		With optFunction
			.Name = "optFunction"
			.Text = ML("Function")
			.TabIndex = 6
			.ControlIndex = 0
			.Caption = ML("Function")
			.SetBounds 110, 20, 100, 20
			.Designer = @This
			.Parent = @grbType
		End With
		' optProperty
		With optProperty
			.Name = "optProperty"
			.Text = ML("Property")
			.TabIndex = 7
			.ControlIndex = 1
			.Caption = ML("Property")
			.SetBounds 210, 20, 90, 20
			.Designer = @This
			.Parent = @grbType
		End With
		' grbScope
		With grbScope
			.Name = "grbScope"
			.Text = ML("Scope")
			.TabIndex = 8
			.Caption = ML("Scope")
			.SetBounds 10, 250, 310, 50
			.Designer = @This
			.Parent = @This
		End With
		' optPublicScope
		With optPublicScope
			.Name = "optPublicScope"
			.Text = ML("Public")
			.TabIndex = 9
			.Caption = ML("Public")
			.SetBounds 10, 20, 90, 20
			.Designer = @This
			.Parent = @grbScope
		End With
		' optPrivateScope
		With optPrivateScope
			.Name = "optPrivateScope"
			.Text = ML("Private")
			.TabIndex = 10
			.ControlIndex = 0
			.Caption = ML("Private")
			.SetBounds 110, 20, 90, 20
			.Designer = @This
			.Parent = @grbScope
		End With
		' chkStatic
		With chkStatic
			.Name = "chkStatic"
			.Text = ML("Static")
			.TabIndex = 11
			.Caption = ML("Static")
			.SetBounds 10, 310, 140, 20
			.Designer = @This
			.Parent = @This
		End With
		' optOperator
		With optOperator
			.Name = "optOperator"
			.Text = ML("Operator")
			.TabIndex = 12
			.ControlIndex = 1
			.Caption = ML("Operator")
			.SetBounds 10, 50, 100, 20
			.Designer = @This
			.Parent = @grbType
		End With
		' lblParameters
		With lblParameters
			.Name = "lblParameters"
			.Text = ML("Parameters") & ":"
			.TabIndex = 13
			.ControlIndex = 0
			.Caption = ML("Parameters") & ":"
			.SetBounds 10, 40, 90, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtName1
		With txtName1
			.Name = "txtName1"
			.TabIndex = 14
			.ControlIndex = 2
			.Text = ""
			.SetBounds 110, 40, 210, 20
			.Designer = @This
			.Parent = @This
		End With
		' lblType
		With lblType
			.Name = "lblType"
			.Text = ML("Type") & ":"
			.TabIndex = 15
			.ControlIndex = 0
			.Caption = ML("Type") & ":"
			.SetBounds 10, 70, 90, 20
			.Designer = @This
			.Parent = @This
		End With
		' cboType
		With cboType
			.Name = "cboType"
			.Text = ""
			.TabIndex = 16
			.SetBounds 110, 70, 210, 21
			.Designer = @This
			.Parent = @This
		End With
		' grbAccessControl
		With grbAccessControl
			.Name = "grbAccessControl"
			.Text = ML("Access Control")
			.TabIndex = 17
			.ControlIndex = 7
			.Caption = ML("Access Control")
			.SetBounds 10, 100, 310, 50
			.Designer = @This
			.Parent = @This
		End With
		' optPublicAccess
		With optPublicAccess
			.Name = "optPublicAccess"
			.Text = ML("Public")
			.TabIndex = 18
			.Caption = ML("Public")
			.SetBounds 10, 20, 100, 20
			.Designer = @This
			.Parent = @grbAccessControl
		End With
		' optProtectedAccess
		With optProtectedAccess
			.Name = "optProtectedAccess"
			.Text = ML("Protected")
			.TabIndex = 19
			.Caption = ML("Protected")
			.SetBounds 110, 20, 100, 20
			.Designer = @This
			.Parent = @grbAccessControl
		End With
		' optPrivateAccess
		With optPrivateAccess
			.Name = "optPrivateAccess"
			.Text = ML("Private")
			.TabIndex = 20
			.Caption = ML("Private")
			.SetBounds 210, 20, 80, 20
			.Designer = @This
			.Parent = @grbAccessControl
		End With
		' optConstructor
		With optConstructor
			.Name = "optConstructor"
			.Text = ML("Constructor")
			.TabIndex = 21
			.ControlIndex = 3
			.Caption = ML("Constructor")
			.SetBounds 110, 50, 100, 20
			.Designer = @This
			.Parent = @grbType
		End With
		' optOperator11
		With optOperator11
			.Name = "optOperator11"
			.Text = ML("Destructor")
			.TabIndex = 22
			.ControlIndex = 3
			.Caption = ML("Destructor")
			.SetBounds 210, 50, 90, 20
			.Designer = @This
			.Parent = @grbType
		End With
	End Constructor
	
	Private Sub frmAddProcedureType.cmdOK_Click_(ByRef Sender As Control)
		*Cast(frmAddProcedureType Ptr, Sender.Designer).cmdOK_Click(Sender)
	End Sub
	
	Private Sub frmAddProcedureType.cmdCancel_Click_(ByRef Sender As Control)
		*Cast(frmAddProcedureType Ptr, Sender.Designer).cmdCancel_Click(Sender)
	End Sub
	
	Dim Shared frmAddProcedure As frmAddProcedureType
	
	#ifndef _NOT_AUTORUN_FORMS_
		#define _NOT_AUTORUN_FORMS_
		
		frmAddProcedure.Show
		
		App.Run
	#endif
'#End Region

Private Sub frmAddProcedureType.cmdCancel_Click(ByRef Sender As Control)
	This.CloseForm
End Sub

Private Sub frmAddProcedureType.cmdOK_Click(ByRef Sender As Control)
	This.CloseForm
End Sub
