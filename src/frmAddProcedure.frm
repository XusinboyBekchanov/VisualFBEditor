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
		Declare Static Sub Form_Show_(ByRef Sender As Form)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Static Sub cboType_Change_(ByRef Sender As ComboBoxEdit)
		Declare Sub cboType_Change(ByRef Sender As ComboBoxEdit)
		Declare Constructor
		
		Dim As Label lblName, lblParameters, lblType, lblParameters1
		Dim As TextBox txtName, txtParameters, txtDescription
		Dim As CommandButton cmdOK, cmdCancel
		Dim As GroupBox grbType, grbScope, grbAccessControl
		Dim As RadioButton optSub, optFunction, optProperty, optPublicScope, optPrivateScope, optOperator, optPublicAccess, optProtectedAccess, optPrivateAccess, optConstructor, optDestructor
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
			.OnShow = @Form_Show_
			.SetBounds 0, 0, 340, 450
		End With
		' lblName
		With lblName
			.Name = "lblName"
			.Text = ML("Name") & ":"
			.TabIndex = 4
			.Caption = ML("Name") & ":"
			.SetBounds 10, 10, 90, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtName
		With txtName
			.Name = "txtName"
			.Text = ""
			.TabIndex = 0
			.SetBounds 110, 10, 210, 20
			.Designer = @This
			.Parent = @This
		End With
		' cmdOK
		With cmdOK
			.Name = "cmdOK"
			.Text = ML("OK")
			.TabIndex = 5
			.Caption = ML("OK")
			.SetBounds 150, 390, 80, 20
			.Designer = @This
			.OnClick = @cmdOK_Click_
			.Parent = @This
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = ML("Cancel")
			.TabIndex = 6
			.ControlIndex = 2
			.Caption = ML("Cancel")
			.SetBounds 240, 390, 80, 20
			.Designer = @This
			.OnClick = @cmdCancel_Click_
			.Parent = @This
		End With
		' grbType
		With grbType
			.Name = "grbType"
			.Text = ML("Type")
			.TabIndex = 7
			.Caption = ML("Type")
			.SetBounds 10, 210, 310, 80
			.Designer = @This
			.Parent = @This
		End With
		' optSub
		With optSub
			.Name = "optSub"
			.Text = ML("Sub")
			.TabIndex = 8
			.Caption = ML("Sub")
			.SetBounds 10, 20, 100, 20
			.Designer = @This
			.Parent = @grbType
		End With
		' optFunction
		With optFunction
			.Name = "optFunction"
			.Text = ML("Function")
			.TabIndex = 9
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
			.TabIndex = 10
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
			.TabIndex = 11
			.Caption = ML("Scope")
			.SetBounds 10, 300, 310, 50
			.Designer = @This
			.Parent = @This
		End With
		' optPublicScope
		With optPublicScope
			.Name = "optPublicScope"
			.Text = ML("Public")
			.TabIndex = 12
			.Caption = ML("Public")
			.SetBounds 10, 20, 90, 20
			.Designer = @This
			.Parent = @grbScope
		End With
		' optPrivateScope
		With optPrivateScope
			.Name = "optPrivateScope"
			.Text = ML("Private")
			.TabIndex = 13
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
			.TabIndex = 14
			.Caption = ML("Static")
			.SetBounds 10, 360, 140, 20
			.Designer = @This
			.Parent = @This
		End With
		' optOperator
		With optOperator
			.Name = "optOperator"
			.Text = ML("Operator")
			.TabIndex = 15
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
			.TabIndex = 16
			.ControlIndex = 0
			.Caption = ML("Parameters") & ":"
			.SetBounds 10, 40, 90, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtParameters
		With txtParameters
			.Name = "txtParameters"
			.TabIndex = 1
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
			.TabIndex = 17
			.ControlIndex = 0
			.Caption = ML("Type") & ":"
			.SetBounds 10, 120, 90, 20
			.Designer = @This
			.Parent = @This
		End With
		' cboType
		With cboType
			.Name = "cboType"
			.Text = ""
			.TabIndex = 3
			.SetBounds 110, 120, 210, 21
			.Designer = @This
			.OnChange = @cboType_Change_
			.Parent = @This
		End With
		' grbAccessControl
		With grbAccessControl
			.Name = "grbAccessControl"
			.Text = ML("Access Control")
			.TabIndex = 18
			.ControlIndex = 7
			.Caption = ML("Access Control")
			.SetBounds 10, 150, 310, 50
			.Designer = @This
			.Parent = @This
		End With
		' optPublicAccess
		With optPublicAccess
			.Name = "optPublicAccess"
			.Text = ML("Public")
			.TabIndex = 19
			.Caption = ML("Public")
			.SetBounds 10, 20, 100, 20
			.Designer = @This
			.Parent = @grbAccessControl
		End With
		' optProtectedAccess
		With optProtectedAccess
			.Name = "optProtectedAccess"
			.Text = ML("Protected")
			.TabIndex = 20
			.Caption = ML("Protected")
			.SetBounds 110, 20, 100, 20
			.Designer = @This
			.Parent = @grbAccessControl
		End With
		' optPrivateAccess
		With optPrivateAccess
			.Name = "optPrivateAccess"
			.Text = ML("Private")
			.TabIndex = 21
			.Caption = ML("Private")
			.SetBounds 210, 20, 80, 20
			.Designer = @This
			.Parent = @grbAccessControl
		End With
		' optConstructor
		With optConstructor
			.Name = "optConstructor"
			.Text = ML("Constructor")
			.TabIndex = 22
			.ControlIndex = 3
			.Caption = ML("Constructor")
			.SetBounds 110, 50, 100, 20
			.Designer = @This
			.Parent = @grbType
		End With
		' optDestructor
		With optDestructor
			.Name = "optDestructor"
			.Text = ML("Destructor")
			.TabIndex = 23
			.ControlIndex = 3
			.Caption = ML("Destructor")
			.SetBounds 210, 50, 90, 20
			.Designer = @This
			.Parent = @grbType
		End With
		' lblParameters1
		With lblParameters1
			.Name = "lblParameters1"
			.Text = ML("Description") & ":"
			.TabIndex = 24
			.ControlIndex = 7
			.Caption = ML("Description") & ":"
			.SetBounds 10, 70, 90, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtDescription
		With txtDescription
			.Name = "txtDescription"
			.TabIndex = 2
			.ControlIndex = 9
			.ScrollBars = ScrollBarsType.Vertical
			.WantReturn = True
			.Multiline = True
			.SetBounds 110, 70, 210, 40
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Private Sub frmAddProcedureType.cboType_Change_(ByRef Sender As ComboBoxEdit)
		*Cast(frmAddProcedureType Ptr, Sender.Designer).cboType_Change(Sender)
	End Sub
	
	Private Sub frmAddProcedureType.Form_Show_(ByRef Sender As Form)
		*Cast(frmAddProcedureType Ptr, Sender.Designer).Form_Show(Sender)
	End Sub
	
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
	If Trim(txtName.Text) = "" Then
		MsgBox ML("Invalid procedure name"), , mtError
		Exit Sub
	End If
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	Dim As String sType
	Select Case True
	Case optSub.Checked: sType = "Sub"
	Case optFunction.Checked: sType = "Function"
	Case optProperty.Checked: sType = "Property"
	Case optOperator.Checked: sType = "Operator"
	Case Else
		Select Case True
		Case optConstructor.Checked: sType = "Constructor"
		Case optDestructor.Checked: sType = "Destructor"
		End Select
	End Select
	Dim As Integer i = tb->txtCode.LinesCount, q
	If cboType.ItemIndex = 0 Then
		tb->txtCode.Changing "Insert procedure"
		tb->txtCode.InsertLine i, ""
		If txtDescription.Text <> "" Then
			Dim As UString res()
			Split(txtDescription.Text, Chr(13) & Chr(10), res())
			q = UBound(res) + 1
			For j As Integer = 0 To UBound(res)
				tb->txtCode.InsertLine i + j + 1, "'" & res(j)
			Next
		End If
		tb->txtCode.InsertLine i + q + 1, IIf(optPublicScope.Checked, "Public", "Private") & " " & sType & " " & txtName.Text & txtParameters.Text
		tb->txtCode.InsertLine i + q + 2, !"\t"
		tb->txtCode.InsertLine i + q + 3, "End " & sType
		tb->txtCode.Changed "Insert procedure"
		tb->txtCode.SetSelection i + q + 2, i + q + 2, 1, 1
		tb->txtCode.TopLine = i + q + 1
		tb->txtCode.SetFocus
		OnLineChangeEdit tb->txtCode, i + q + 3, i + q + 3
	End If
	This.CloseForm
End Sub

Private Sub frmAddProcedureType.Form_Show(ByRef Sender As Form)
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	cboType.Clear
	cboType.AddItem "(not selected)"
	For i As Integer = 0 To tb->txtCode.Types.Count - 1
		cboType.AddItem tb->txtCode.Types.Item(i)
	Next
	cboType.ItemIndex = 0
	optPublicAccess.Checked = True
	optSub.Checked = True
	optPublicScope.Checked = True
End Sub

Private Sub frmAddProcedureType.cboType_Change(ByRef Sender As ComboBoxEdit)
	Dim As Boolean bEnabled = cboType.ItemIndex <> 0
	optPublicAccess.Enabled = bEnabled
	optProtectedAccess.Enabled = bEnabled
	optPrivateAccess.Enabled = bEnabled
	optProperty.Enabled = bEnabled
End Sub
