'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/Label.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/GroupBox.bi"
	#include once "mff/RadioButton.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/UpDown.bi"
	
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
		Declare Static Sub optConstructor_Click_(ByRef Sender As RadioButton)
		Declare Sub optConstructor_Click(ByRef Sender As RadioButton)
		Declare Static Sub optSub_Click_(ByRef Sender As RadioButton)
		Declare Sub optSub_Click(ByRef Sender As RadioButton)
		Declare Static Sub optFunction_Click_(ByRef Sender As RadioButton)
		Declare Sub optFunction_Click(ByRef Sender As RadioButton)
		Declare Static Sub optProperty_Click_(ByRef Sender As RadioButton)
		Declare Sub optProperty_Click(ByRef Sender As RadioButton)
		Declare Static Sub optOperator_Click_(ByRef Sender As RadioButton)
		Declare Sub optOperator_Click(ByRef Sender As RadioButton)
		Declare Static Sub optDestructor_Click_(ByRef Sender As RadioButton)
		Declare Sub optDestructor_Click(ByRef Sender As RadioButton)
		Declare Static Sub txtParameters_Change_(ByRef Sender As TextBox)
		Declare Sub txtParameters_Change(ByRef Sender As TextBox)
		Declare Static Sub optPublicScope_Click_(ByRef Sender As RadioButton)
		Declare Sub optPublicScope_Click(ByRef Sender As RadioButton)
		Declare Static Sub optPrivateScope_Click_(ByRef Sender As RadioButton)
		Declare Sub optPrivateScope_Click(ByRef Sender As RadioButton)
		Declare Static Sub optDefaultScope_Click_(ByRef Sender As RadioButton)
		Declare Sub optDefaultScope_Click(ByRef Sender As RadioButton)
		Declare Static Sub chkStaticMember_Click_(ByRef Sender As CheckBox)
		Declare Sub chkStaticMember_Click(ByRef Sender As CheckBox)
		Declare Constructor
		
		Dim As Label lblName, lblParameters, lblType, lblParameters1, lblPriority, lblAlias
		Dim As TextBox txtName, txtParameters, txtDescription, txtPriority, txtAlias
		Dim As CommandButton cmdOK, cmdCancel
		Dim As GroupBox grbType, grbScope, grbAccessControl
		Dim As RadioButton optSub, optFunction, optProperty, optPublicScope, optPrivateScope, optOperator, optPublicAccess, optProtectedAccess, optPrivateAccess, optConstructor, optDestructor, optDefaultScope
		Dim As CheckBox chkStatic, chkStaticMember, chkExport, chkProcedureAlso
		Dim As ComboBoxEdit cboType
		Dim As UpDown updPriority
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
			.SetBounds 0, 0, 340, 510
		End With
		' lblName
		With lblName
			.Name = "lblName"
			.Text = ML("Name") & ":"
			.TabIndex = 22
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
			.TabIndex = 20
			.Caption = ML("OK")
			.SetBounds 150, 450, 80, 20
			.Designer = @This
			.OnClick = @cmdOK_Click_
			.Parent = @This
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = ML("Cancel")
			.TabIndex = 21
			.ControlIndex = 2
			.Caption = ML("Cancel")
			.SetBounds 240, 450, 80, 20
			.Designer = @This
			.OnClick = @cmdCancel_Click_
			.Parent = @This
		End With
		' grbType
		With grbType
			.Name = "grbType"
			.Text = ML("Type")
			.TabIndex = 23
			.Caption = ML("Type")
			.SetBounds 10, 240, 310, 80
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
			.OnClick = @optSub_Click_
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
			.OnClick = @optFunction_Click_
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
			.OnClick = @optProperty_Click_
			.Parent = @grbType
		End With
		' grbScope
		With grbScope
			.Name = "grbScope"
			.Text = ML("Scope")
			.TabIndex = 24
			.Caption = ML("Scope")
			.SetBounds 10, 330, 310, 50
			.Designer = @This
			.Parent = @This
		End With
		' optPublicScope
		With optPublicScope
			.Name = "optPublicScope"
			.Text = ML("Public")
			.TabIndex = 14
			.Caption = ML("Public")
			.SetBounds 10, 20, 90, 20
			.Designer = @This
			.OnClick = @optPublicScope_Click_
			.Parent = @grbScope
		End With
		' optPrivateScope
		With optPrivateScope
			.Name = "optPrivateScope"
			.Text = ML("Private")
			.TabIndex = 15
			.ControlIndex = 0
			.Caption = ML("Private")
			.SetBounds 110, 20, 80, 20
			.Designer = @This
			.OnClick = @optPrivateScope_Click_
			.Parent = @grbScope
		End With
		' chkStatic
		With chkStatic
			.Name = "chkStatic"
			.Text = ML("All Local variables as Statics")
			.TabIndex = 17
			.SetBounds 10, 420, 170, 20
			.Designer = @This
			.Parent = @This
		End With
		' optOperator
		With optOperator
			.Name = "optOperator"
			.Text = ML("Operator")
			.TabIndex = 11
			.ControlIndex = 1
			.Caption = ML("Operator")
			.SetBounds 10, 50, 100, 20
			.Designer = @This
			.OnClick = @optOperator_Click_
			.Parent = @grbType
		End With
		' lblParameters
		With lblParameters
			.Name = "lblParameters"
			.Text = ML("Parameters") & ":"
			.TabIndex = 25
			.ControlIndex = 0
			.Caption = ML("Parameters") & ":"
			.SetBounds 10, 70, 90, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtParameters
		With txtParameters
			.Name = "txtParameters"
			.TabIndex = 2
			.ControlIndex = 2
			.Text = ""
			.SetBounds 110, 70, 210, 20
			.Designer = @This
			.OnChange = @txtParameters_Change_
			.Parent = @This
		End With
		' lblType
		With lblType
			.Name = "lblType"
			.Text = ML("Type") & ":"
			.TabIndex = 26
			.ControlIndex = 0
			.Caption = ML("Type") & ":"
			.SetBounds 10, 150, 90, 20
			.Designer = @This
			.Parent = @This
		End With
		' cboType
		With cboType
			.Name = "cboType"
			.Text = ""
			.TabIndex = 4
			.SetBounds 110, 150, 210, 21
			.Designer = @This
			.OnChange = @cboType_Change_
			.Parent = @This
		End With
		' grbAccessControl
		With grbAccessControl
			.Name = "grbAccessControl"
			.Text = ML("Access Control")
			.TabIndex = 27
			.ControlIndex = 7
			.Caption = ML("Access Control")
			.SetBounds 10, 180, 310, 50
			.Designer = @This
			.Parent = @This
		End With
		' optPublicAccess
		With optPublicAccess
			.Name = "optPublicAccess"
			.Text = ML("Public")
			.TabIndex = 5
			.Caption = ML("Public")
			.SetBounds 10, 20, 100, 20
			.Designer = @This
			.Parent = @grbAccessControl
		End With
		' optProtectedAccess
		With optProtectedAccess
			.Name = "optProtectedAccess"
			.Text = ML("Protected")
			.TabIndex = 6
			.Caption = ML("Protected")
			.SetBounds 110, 20, 100, 20
			.Designer = @This
			.Parent = @grbAccessControl
		End With
		' optPrivateAccess
		With optPrivateAccess
			.Name = "optPrivateAccess"
			.Text = ML("Private")
			.TabIndex = 7
			.Caption = ML("Private")
			.SetBounds 210, 20, 80, 20
			.Designer = @This
			.Parent = @grbAccessControl
		End With
		' optConstructor
		With optConstructor
			.Name = "optConstructor"
			.Text = ML("Constructor")
			.TabIndex = 12
			.ControlIndex = 3
			.Caption = ML("Constructor")
			.SetBounds 110, 50, 100, 20
			.Designer = @This
			.OnClick = @optConstructor_Click_
			.Parent = @grbType
		End With
		' optDestructor
		With optDestructor
			.Name = "optDestructor"
			.Text = ML("Destructor")
			.TabIndex = 13
			.ControlIndex = 3
			.Caption = ML("Destructor")
			.SetBounds 210, 50, 90, 20
			.Designer = @This
			.OnClick = @optDestructor_Click_
			.Parent = @grbType
		End With
		' lblParameters1
		With lblParameters1
			.Name = "lblParameters1"
			.Text = ML("Description") & ":"
			.TabIndex = 28
			.ControlIndex = 7
			.Caption = ML("Description") & ":"
			.SetBounds 10, 100, 90, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtDescription
		With txtDescription
			.Name = "txtDescription"
			.TabIndex = 3
			.ControlIndex = 9
			.ScrollBars = ScrollBarsType.Vertical
			.WantReturn = True
			.Multiline = True
			.Text = ""
			.SetBounds 110, 100, 210, 40
			.Designer = @This
			.Parent = @This
		End With
		' lblPriority
		With lblPriority
			.Name = "lblPriority"
			.Text = ML("Priority") & ":"
			.TabIndex = 29
			.ControlIndex = 0
			.Caption = ML("Priority") & ":"
			.SetBounds 190, 423, 60, 20
			.Designer = @This
			.Parent = @This
		End With
		' updPriority
		With updPriority
			.Name = "updPriority"
			.Text = "UpDown1"
			.TabIndex = 19
			.Associate = @txtPriority
			.SetBounds 300, 420, 17, 20
			.Designer = @This
			.MinValue = 101
			.MaxValue = 65535
			.Parent = @This
		End With
		' txtPriority
		With txtPriority
			.Name = "txtPriority"
			.Text = "101"
			.TabIndex = 18
			.NumbersOnly = True
			.Alignment = AlignmentConstants.taRight
			.SetBounds 260, 420, 40, 20
			.Designer = @This
			.Parent = @This
		End With
		' chkStaticMember
		With chkStaticMember
			.Name = "chkStaticMember"
			.Text = ML("Static member")
			.TabIndex = 16
			.ControlIndex = 6
			.Caption = ML("Static member")
			.SetBounds 10, 390, 100, 20
			.Designer = @This
			.OnClick = @chkStaticMember_Click_
			.Parent = @This
		End With
		' lblAlias
		With lblAlias
			.Name = "lblAlias"
			.Text = ML("Alias") & ":"
			.TabIndex = 30
			.ControlIndex = 0
			.Caption = ML("Alias") & ":"
			.SetBounds 10, 40, 90, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtAlias
		With txtAlias
			.Name = "txtAlias"
			.TabIndex = 1
			.ControlIndex = 2
			.Text = ""
			.SetBounds 110, 40, 210, 20
			.Designer = @This
			.Parent = @This
		End With
		' chkExport
		With chkExport
			.Name = "chkExport"
			.Text = ML("Export")
			.TabIndex = 31
			.ControlIndex = 17
			.Caption = ML("Export")
			.SetBounds 220, 390, 100, 20
			.Designer = @This
			.Parent = @This
		End With
		' optDefaultScope
		With optDefaultScope
			.Name = "optDefaultScope"
			.Text = ML("Default")
			.TabIndex = 32
			.ControlIndex = 1
			.Caption = ML("Default")
			.SetBounds 210, 20, 90, 20
			.Designer = @This
			.OnClick = @optDefaultScope_Click_
			.Parent = @grbScope
		End With
		' chkProcedureAlso
		With chkProcedureAlso
			.Name = "chkProcedureAlso"
			.Text = ML("Procedure also")
			.TabIndex = 33
			.ControlIndex = 17
			.Caption = ML("Procedure also")
			.Hint = ML("Procedure also with Static keyword")
			.SetBounds 120, 390, 100, 20
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Private Sub frmAddProcedureType.chkStaticMember_Click_(ByRef Sender As CheckBox)
		*Cast(frmAddProcedureType Ptr, Sender.Designer).chkStaticMember_Click(Sender)
	End Sub
	
	Private Sub frmAddProcedureType.optDefaultScope_Click_(ByRef Sender As RadioButton)
		*Cast(frmAddProcedureType Ptr, Sender.Designer).optDefaultScope_Click(Sender)
	End Sub
	
	Private Sub frmAddProcedureType.optPrivateScope_Click_(ByRef Sender As RadioButton)
		*Cast(frmAddProcedureType Ptr, Sender.Designer).optPrivateScope_Click(Sender)
	End Sub
	
	Private Sub frmAddProcedureType.optPublicScope_Click_(ByRef Sender As RadioButton)
		*Cast(frmAddProcedureType Ptr, Sender.Designer).optPublicScope_Click(Sender)
	End Sub
	
	Private Sub frmAddProcedureType.txtParameters_Change_(ByRef Sender As TextBox)
		*Cast(frmAddProcedureType Ptr, Sender.Designer).txtParameters_Change(Sender)
	End Sub
	
	Private Sub frmAddProcedureType.optDestructor_Click_(ByRef Sender As RadioButton)
		*Cast(frmAddProcedureType Ptr, Sender.Designer).optDestructor_Click(Sender)
	End Sub
	
	Private Sub frmAddProcedureType.optOperator_Click_(ByRef Sender As RadioButton)
		*Cast(frmAddProcedureType Ptr, Sender.Designer).optOperator_Click(Sender)
	End Sub
	
	Private Sub frmAddProcedureType.optProperty_Click_(ByRef Sender As RadioButton)
		*Cast(frmAddProcedureType Ptr, Sender.Designer).optProperty_Click(Sender)
	End Sub
	
	Private Sub frmAddProcedureType.optFunction_Click_(ByRef Sender As RadioButton)
		*Cast(frmAddProcedureType Ptr, Sender.Designer).optFunction_Click(Sender)
	End Sub
	
	Private Sub frmAddProcedureType.optSub_Click_(ByRef Sender As RadioButton)
		*Cast(frmAddProcedureType Ptr, Sender.Designer).optSub_Click(Sender)
	End Sub
	
	Private Sub frmAddProcedureType.optConstructor_Click_(ByRef Sender As RadioButton)
		*Cast(frmAddProcedureType Ptr, Sender.Designer).optConstructor_Click(Sender)
	End Sub
	
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
	Dim As String sType, sTypeName, sTypeNameDot, sConstructorDestructor
	Dim As Boolean bInsideType = cboType.ItemIndex <> 0
	Select Case True
	Case optSub.Checked: sType = "Sub"
	Case optFunction.Checked: sType = "Function"
	Case optProperty.Checked: sType = "Property"
	Case optOperator.Checked: sType = "Operator"
	Case Else
		If bInsideType Then
			Select Case True
			Case optConstructor.Checked: sType = "Constructor"
			Case optDestructor.Checked: sType = "Destructor"
			End Select
		Else
			Select Case True
			Case optConstructor.Checked: sType = "Sub": sConstructorDestructor = " Constructor" & IIf(txtPriority.Text = "0", "", " " & Trim(txtPriority.Text))
			Case optDestructor.Checked: sType = "Sub": sConstructorDestructor = " Destructor" & IIf(txtPriority.Text = "0", "", " " & Trim(txtPriority.Text))
			End Select
		End If
	End Select
	Dim As Integer i = tb->txtCode.LinesCount, q1, q2
	tb->txtCode.Changing "Insert procedure"
	If Not bInsideType Then
		tb->txtCode.InsertLine i, ""
		If txtDescription.Text <> "" Then
			Dim As UString res()
			Split(txtDescription.Text, Chr(13) & Chr(10), res())
			q1 = UBound(res) + 1
			For j As Integer = 0 To UBound(res)
				tb->txtCode.InsertLine i + j + 1, "'" & res(j)
			Next
		End If
	Else
		sTypeName = cboType.Text
		sTypeNameDot = sTypeName & "."
		Dim As String SpaceStr
		Dim As Integer iStart, iEnd, LineToAdd, LineEndPublic = -1, LineEndProtected = -1, LineEndPrivate = -1, LineEndType = -1
		Dim As EditControl Ptr ptxtCode, ptxtCodeBi, ptxtCodeType
		Dim As EditControl txtCodeBi
		Dim As Boolean bFind, b, bPublic = True, bPrivate, bProtected, IsBas = EndsWith(LCase(tb->FileName), ".bas") OrElse EndsWith(LCase(tb->FileName), ".frm")
		For i As Integer = 0 To tb->txtCode.LinesCount - 1
			GetBiFile(ptxtCode, txtCodeBi, ptxtCodeBi, tb, IsBas, bFind, i, iStart, iEnd)
			For k As Integer = iStart To iEnd
				If (Not b) AndAlso StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t ") & " ", "type " & LCase(sTypeName) & " ") Then
					ptxtCodeType = ptxtCode
					b = True
				ElseIf b Then
					If StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t ") & " ", "end type ") Then
						If bPrivate Then LineEndPrivate = k
						If bProtected Then LineEndProtected = k
						If bPublic Then LineEndPublic = k
						LineEndType = k
						SpaceStr = .Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t ")))
						Exit For
					ElseIf StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t ") & " ", "public:") Then
						bPublic = True
						If bPrivate Then LineEndPrivate = k: bPrivate = False
						If bProtected Then LineEndProtected = k: bProtected = False
					ElseIf StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t ") & " ", "protected:") Then
						bProtected = True
						If bPrivate Then LineEndPrivate = k: bPrivate = False
						If bPublic Then LineEndPublic = k: bPublic = False
					ElseIf StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t ") & " ", "private:") Then
						bPrivate = True
						If bProtected Then LineEndProtected = k: bProtected = False
						If bPublic Then LineEndPublic = k: bPublic = False
					End If
				End If
			Next
			ptxtCode = @tb->txtCode
			iStart = i + 1
			iEnd = i + 1
		Next
		If LineEndType > -1 Then
			If optPublicAccess.Checked Then
				If LineEndPublic = -1 Then
					ptxtCode->InsertLine LineEndType, SpaceStr & "Public:"
					q2 += 1
					If ptxtCode = @tb->txtCode Then q1 += 1
					LineToAdd = LineEndType
				Else
					LineToAdd = LineEndPublic
				End If
			ElseIf optProtectedAccess.Checked Then
				If LineEndProtected = -1 Then
					ptxtCode->InsertLine LineEndType, SpaceStr & "Protected:"
					q2 += 1
					If ptxtCode = @tb->txtCode Then q1 += 1
					LineToAdd = LineEndType
				Else
					LineToAdd = LineEndProtected
				End If
			ElseIf optPrivateAccess.Checked Then
				If LineEndPrivate = -1 Then
					ptxtCode->InsertLine LineEndType, SpaceStr & "Private:"
					q2 += 1
					If ptxtCode = @tb->txtCode Then q1 += 1
					LineToAdd = LineEndType
				Else
					LineToAdd = LineEndPrivate
				End If
			End If
			If txtDescription.Text <> "" Then
				Dim As UString res()
				Split(txtDescription.Text, Chr(13) & Chr(10), res())
				For j As Integer = 0 To UBound(res)
					ptxtCode->InsertLine LineToAdd + q2 + j, SpaceStr & !"\t'" & res(j)
				Next
				q2 += UBound(res) + 1
				If ptxtCode = @tb->txtCode Then q1 += UBound(res) + 1
			End If
			ptxtCode = ptxtCodeType
			CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
			ptxtCode->InsertLine LineToAdd + q2, SpaceStr & !"\tDeclare" & IIf(chkStaticMember.Checked, " Static", "") & " " & sType & IIf(optConstructor.Checked OrElse optDestructor.Checked, "", " " & txtName.Text) & IIf(txtAlias.Text = "", "", " Alias """ & txtAlias.Text & """") & IIf(StartsWith(txtParameters.Text, "(") OrElse Trim(txtParameters.Text) = "", txtParameters.Text, "(" & txtParameters.Text & ")")
			If ptxtCode = @tb->txtCode Then q1 += 1
		End If
		tb->txtCode.InsertLine i + q1, ""
	End If
	tb->txtCode.InsertLine i + q1 + 1, IIf(optPublicScope.Checked, "Public ", IIf(optPrivateScope.Checked, "Private ", "")) & IIf(chkProcedureAlso.Checked, "Static ", "") & sType & " " & IIf(bInsideType AndAlso (optConstructor.Checked OrElse optDestructor.Checked), txtName.Text, sTypeNameDot & txtName.Text) & IIf(txtAlias.Text = "", "", " Alias """ & txtAlias.Text & """") & IIf(StartsWith(txtParameters.Text, "(") OrElse Trim(txtParameters.Text) = "", txtParameters.Text, "(" & txtParameters.Text & ")") & sConstructorDestructor & IIf(chkStatic.Checked, " Static", "") & IIf(chkExport.Checked, " Export", "")
	tb->txtCode.InsertLine i + q1 + 2, !"\t"
	tb->txtCode.InsertLine i + q1 + 3, "End " & sType
	tb->txtCode.Changed "Insert procedure"
	tb->txtCode.SetSelection i + q1 + 2, i + q1 + 2, 1, 1
	tb->txtCode.TopLine = i + q1 + 1
	tb->txtCode.SetFocus
	OnLineChangeEdit tb->txtCode, i + q1 + 2, i + q1 + 2
	This.CloseForm
End Sub

Private Sub frmAddProcedureType.Form_Show(ByRef Sender As Form)
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	txtName.Text = ""
	txtAlias.Text = ""
	txtDescription.Text = ""
	txtParameters.Text = ""
	cboType.Clear
	cboType.AddItem "(not selected)"
	For i As Integer = 0 To tb->txtCode.Types.Count - 1
		cboType.AddItem tb->txtCode.Types.Item(i)
	Next
	cboType.ItemIndex = 0
	optPublicAccess.Checked = True
	optProtectedAccess.Checked = False
	optPrivateAccess.Checked = False
	optSub.Checked = True
	optFunction.Checked = False
	optProperty.Checked = False
	optOperator.Checked = False
	optConstructor.Checked = False
	optDestructor.Checked = False
	optPublicScope.Checked = True
	optPrivateScope.Checked = False
	chkStatic.Checked = False
	chkStaticMember.Checked = False
	chkProcedureAlso.Checked = False
	txtPriority.Text = "0"
End Sub

Private Sub frmAddProcedureType.cboType_Change(ByRef Sender As ComboBoxEdit)
	Dim As Boolean bEnabled = cboType.ItemIndex <> 0
	optPublicAccess.Enabled = bEnabled
	optProtectedAccess.Enabled = bEnabled
	optPrivateAccess.Enabled = bEnabled
	optProperty.Enabled = bEnabled
	If optProperty.Checked AndAlso Not bEnabled Then
		optProperty.Checked = False
		optSub.Checked = True
	End If
	chkStaticMember.Enabled = bEnabled
	optConstructor_Click(optConstructor)
	chkStaticMember_Click(chkStaticMember)
End Sub

Private Sub frmAddProcedureType.optConstructor_Click(ByRef Sender As RadioButton)
	Dim As Boolean bVisible = (optConstructor.Checked OrElse optDestructor.Checked) AndAlso cboType.ItemIndex = 0
	lblPriority.Visible = bVisible
	txtPriority.Visible = bVisible
	updPriority.Visible = bVisible
	If (optConstructor.Checked OrElse optDestructor.Checked) AndAlso cboType.ItemIndex <> 0 Then
		txtName.Text = cboType.Text
		txtName.Enabled = False
	Else
		txtName.Enabled = True
	End If
	If bVisible Then
		txtParameters.Text = ""
		txtParameters.Enabled = False
	Else
		txtParameters.Enabled = True
	End If
	txtParameters_Change(txtParameters)
End Sub

Private Sub frmAddProcedureType.optSub_Click(ByRef Sender As RadioButton)
	optConstructor_Click(Sender)
End Sub

Private Sub frmAddProcedureType.optFunction_Click(ByRef Sender As RadioButton)
	optConstructor_Click(Sender)
End Sub

Private Sub frmAddProcedureType.optProperty_Click(ByRef Sender As RadioButton)
	optConstructor_Click(Sender)
End Sub

Private Sub frmAddProcedureType.optOperator_Click(ByRef Sender As RadioButton)
	optConstructor_Click(Sender)
End Sub

Private Sub frmAddProcedureType.optDestructor_Click(ByRef Sender As RadioButton)
	optConstructor_Click(Sender)
End Sub

Private Sub frmAddProcedureType.txtParameters_Change(ByRef Sender As TextBox)
	If cboType.ItemIndex <> 0 Then
		Dim As UString Parameters = Trim(txtParameters.Text)
		If StartsWith(Parameters, "(") AndAlso EndsWith(Parameters, ")") Then
			Parameters = Trim(Mid(Parameters, 2, Len(Parameters) - 2))
		End If
		If Parameters = "" AndAlso (optConstructor.Checked OrElse optDestructor.Checked) Then
			optProtectedAccess.Enabled = False
			optPrivateAccess.Enabled = False
			If optProtectedAccess.Checked Then
				optProtectedAccess.Checked = False
				optPublicAccess.Checked = True
			End If
			If optPrivateAccess.Checked Then
				optPrivateAccess.Checked = False
				optPublicAccess.Checked = True
			End If
		Else
			optProtectedAccess.Enabled = True
			optPrivateAccess.Enabled = True
		End If
	End If
End Sub

Private Sub frmAddProcedureType.optPublicScope_Click(ByRef Sender As RadioButton)
	chkExport.Enabled = Not optPrivateScope.Checked
	If chkExport.Enabled = False Then chkExport.Checked = False
End Sub

Private Sub frmAddProcedureType.optPrivateScope_Click(ByRef Sender As RadioButton)
	optPublicScope_Click(Sender)
End Sub

Private Sub frmAddProcedureType.optDefaultScope_Click(ByRef Sender As RadioButton)
	optPublicScope_Click(Sender)
End Sub

Private Sub frmAddProcedureType.chkStaticMember_Click(ByRef Sender As CheckBox)
	chkProcedureAlso.Enabled = chkStaticMember.Checked AndAlso chkStaticMember.Enabled
	If Not chkProcedureAlso.Enabled Then
		chkProcedureAlso.Checked = False
	End If
End Sub
