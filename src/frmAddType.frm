'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/GroupBox.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/RadioButton.bi"
	#include once "mff/Label.bi"
	#include once "mff/NumericUpDown.bi"
	
	Using My.Sys.Forms
	
	Type frmAddTypeType Extends Form
		Declare Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Sub cmdOK_Click(ByRef Sender As Control)
		Declare Sub cboType_Change(ByRef Sender As ComboBoxEdit)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub optClass_Click(ByRef Sender As RadioButton)
		Declare Sub optType_Click(ByRef Sender As RadioButton)
		Declare Sub optUnion_Click(ByRef Sender As RadioButton)
		Declare Constructor
		
		Dim As Label lblName, lblField, lblType, lblDescription, lblAlias, lblExtends
		Dim As TextBox txtName, txtDescription, txtAlias
		Dim As CommandButton cmdOK, cmdCancel
		Dim As GroupBox grbType, grbScope, grbAccessControl
		Dim As RadioButton optClass, optType, optUnion, optPublicScope, optPrivateScope, optPublicAccess, optProtectedAccess, optPrivateAccess, optDefaultScope
		Dim As ComboBoxEdit cboType, cboExtends
		Dim As NumericUpDown txtField
		Dim As CheckBox chkRedefineClassKeyword
	End Type
	
	Constructor frmAddTypeType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = .Language
			End With
		#endif
		' frmAddType
		With This
			.Name = "frmAddType"
			.Text = ML("Add Type")
			.BorderStyle = FormBorderStyle.FixedDialog
			.MaximizeBox = False
			.MinimizeBox = False
			.Icon = "1"
			.Designer = @This
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.SetBounds 0, 0, 340, 450
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
			.TabIndex = 36
			.Caption = ML("OK")
			.SetBounds 150, 390, 80, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdOK_Click)
			.Parent = @This
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = ML("Cancel")
			.TabIndex = 37
			.ControlIndex = 2
			.Caption = ML("Cancel")
			.SetBounds 240, 390, 80, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdCancel_Click)
			.Parent = @This
		End With
		' grbType
		With grbType
			.Name = "grbType"
			.Text = ML("Type")
			.TabIndex = 20
			.Caption = ML("Type")
			.SetBounds 10, 270, 310, 50
			.Designer = @This
			.Parent = @This
		End With
		' optClass
		With optClass
			.Name = "optClass"
			.Text = ML("Class")
			.TabIndex = 21
			.Caption = ML("Class")
			.SetBounds 10, 20, 100, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton), @optClass_Click)
			.Parent = @grbType
		End With
		' optType
		With optType
			.Name = "optType"
			.Text = ML("Type")
			.TabIndex = 22
			.ControlIndex = 0
			.Caption = ML("Type")
			.SetBounds 110, 20, 100, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton), @optType_Click)
			.Parent = @grbType
		End With
		' optUnion
		With optUnion
			.Name = "optUnion"
			.Text = ML("Union")
			.TabIndex = 23
			.ControlIndex = 1
			.Caption = ML("Union")
			.SetBounds 210, 20, 90, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton), @optUnion_Click)
			.Parent = @grbType
		End With
		' grbScope
		With grbScope
			.Name = "grbScope"
			.Text = ML("Scope")
			.TabIndex = 27
			.Caption = ML("Scope")
			.SetBounds 10, 330, 310, 50
			.Designer = @This
			.Parent = @This
		End With
		' optPublicScope
		With optPublicScope
			.Name = "optPublicScope"
			.Text = ML("Public")
			.TabIndex = 28
			.Caption = ML("Public")
			.Hint = ML("With Public scope")
			.SetBounds 10, 20, 90, 20
			.Designer = @This
			.Parent = @grbScope
		End With
		' optPrivateScope
		With optPrivateScope
			.Name = "optPrivateScope"
			.Text = ML("Private")
			.TabIndex = 29
			.ControlIndex = 0
			.Caption = ML("Private")
			.Hint = ML("With Private scope")
			.SetBounds 110, 20, 80, 20
			.Designer = @This
			.Parent = @grbScope
		End With
		' lblField
		With lblField
			.Name = "lblField"
			.Text = ML("Field") & ":"
			.TabIndex = 4
			.ControlIndex = 0
			.Caption = ML("Field") & ":"
			.SetBounds 10, 70, 90, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtField
		With txtField
			.Name = "txtField"
			.TabIndex = 5
			.ControlIndex = 2
			.Text = ""
			.SetBounds 110, 70, 210, 20
			.Designer = @This
			.Parent = @This
		End With
		' lblType
		With lblType
			.Name = "lblType"
			.Text = ML("Type") & ":"
			.TabIndex = 8
			.ControlIndex = 0
			.Caption = ML("Type") & ":"
			.SetBounds 10, 180, 90, 20
			.Designer = @This
			.Parent = @This
		End With
		' cboType
		With cboType
			.Name = "cboType"
			.Text = ""
			.TabIndex = 9
			.SetBounds 110, 180, 210, 21
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit), @cboType_Change)
			.Parent = @This
		End With
		' grbAccessControl
		With grbAccessControl
			.Name = "grbAccessControl"
			.Text = ML("Access Control")
			.TabIndex = 10
			.ControlIndex = 7
			.Caption = ML("Access Control")
			.SetBounds 10, 210, 310, 50
			.Designer = @This
			.Parent = @This
		End With
		' optPublicAccess
		With optPublicAccess
			.Name = "optPublicAccess"
			.Text = ML("Public")
			.TabIndex = 11
			.Caption = ML("Public")
			.SetBounds 10, 20, 100, 20
			.Designer = @This
			.Parent = @grbAccessControl
		End With
		' optProtectedAccess
		With optProtectedAccess
			.Name = "optProtectedAccess"
			.Text = ML("Protected")
			.TabIndex = 12
			.Caption = ML("Protected")
			.SetBounds 110, 20, 100, 20
			.Designer = @This
			.Parent = @grbAccessControl
		End With
		' optPrivateAccess
		With optPrivateAccess
			.Name = "optPrivateAccess"
			.Text = ML("Private")
			.TabIndex = 13
			.Caption = ML("Private")
			.SetBounds 210, 20, 80, 20
			.Designer = @This
			.Parent = @grbAccessControl
		End With
		' lblDescription
		With lblDescription
			.Name = "lblDescription"
			.Text = ML("Description") & ":"
			.TabIndex = 6
			.ControlIndex = 7
			.Caption = ML("Description") & ":"
			.SetBounds 10, 100, 90, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtDescription
		With txtDescription
			.Name = "txtDescription"
			.TabIndex = 7
			.ControlIndex = 9
			.ScrollBars = ScrollBarsType.Vertical
			.WantReturn = True
			.Multiline = True
			.Text = ""
			.SetBounds 110, 100, 210, 40
			.Designer = @This
			.Parent = @This
		End With
		' lblAlias
		With lblAlias
			.Name = "lblAlias"
			.Text = ML("Alias") & ":"
			.TabIndex = 2
			.ControlIndex = 0
			.Caption = ML("Alias") & ":"
			.SetBounds 10, 40, 90, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtAlias
		With txtAlias
			.Name = "txtAlias"
			.TabIndex = 3
			.ControlIndex = 2
			.Text = ""
			.SetBounds 110, 40, 210, 20
			.Designer = @This
			.Parent = @This
		End With
		' optDefaultScope
		With optDefaultScope
			.Name = "optDefaultScope"
			.Text = ML("Default")
			.TabIndex = 30
			.ControlIndex = 1
			.Caption = ML("Default")
			.Hint = ML("Without Public or Private scope")
			.SetBounds 210, 20, 90, 20
			.Designer = @This
			.Parent = @grbScope
		End With
		' lblExtends
		With lblExtends
			.Name = "lblExtends"
			.Text = ML("Extends") & ":"
			.TabIndex = 24
			.ControlIndex = 8
			.Caption = ML("Extends") & ":"
			.SetBounds 10, 150, 90, 20
			.Designer = @This
			.Parent = @This
		End With
		' cboExtends
		With cboExtends
			.Name = "cboExtends"
			.TabIndex = 25
			.ControlIndex = 10
			.SetBounds 110, 150, 210, 21
			.Designer = @This
			.Parent = @This
		End With
		' chkRedefineClassKeyword
		With chkRedefineClassKeyword
			.Name = "chkRedefineClassKeyword"
			.Text = ML("Redefine Class keyword")
			.TabIndex = 27
			.Caption = ML("Redefine Class keyword")
			.Visible = False
			.Checked = True
			.SetBounds 10, 390, 140, 20
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frmAddType As frmAddTypeType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmAddType.MainForm = True
		frmAddType.Show
		App.Run
	#endif
'#End Region

Private Sub frmAddTypeType.cmdCancel_Click(ByRef Sender As Control)
	This.CloseForm
End Sub

Private Sub frmAddTypeType.cmdOK_Click(ByRef Sender As Control)
	If Trim(txtName.Text) = "" Then
		MsgBox ML("Invalid type name"), , mtError
		Exit Sub
	End If
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	Dim As String sType, sTypeName, sTypeNameDot, sConstructorDestructor
	Dim As Boolean bInsideType = cboType.ItemIndex <> 0
	Select Case True
	Case optClass.Checked: sType = "Class"
	Case optType.Checked: sType = "Type"
	Case optUnion.Checked: sType = "Union"
	End Select
	Dim As EditControl Ptr ptxtCode, ptxtCodeBi, ptxtCodeType
	Dim As EditControl txtCodeBi
	Dim As Integer iStart, iEnd, j
	Dim As Boolean t, b, bFind, bAddSpaces = True, IsBas = EndsWith(LCase(tb->FileName), ".bas") OrElse EndsWith(LCase(tb->FileName), ".frm")
	tb->txtCode.Changing "Insert procedure"
	If cboExtends.ItemIndex <> 0 Then
		Dim te As TypeElement Ptr = cboExtends.ItemData(cboExtends.ItemIndex)
		If te <> 0 AndAlso te->FileName <> tb->FileName Then
			For i As Integer = 0 To tb->txtCode.LinesCount - 1
				GetBiFile(ptxtCode, txtCodeBi, ptxtCodeBi, tb, IsBas, bFind, i, iStart, iEnd)
				For k As Integer = iStart To iEnd
					If StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "#include ") Then
						b = True
						If InStr(LCase(ptxtCode->Lines(k)), """" & LCase(te->IncludeFile & """")) Then
							t = True
							Exit For, For
						End If
					ElseIf b Then
						j = k
						Exit For, For
					End If
				Next
			Next
			Var InsLineCount = 0
			If Not t Then
				CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
				ptxtCode->InsertLine j, ..Left(ptxtCode->Lines(j - 1), Len(ptxtCode->Lines(j - 1)) - Len(LTrim(ptxtCode->Lines(j - 1), Any !"\t "))) & "#include once """ & te->IncludeFile & """"
				InsLineCount += 1
			End If
		End If
	End If
	If optClass.Checked AndAlso chkRedefineClassKeyword.Checked Then
		t = False
		For i As Integer = 0 To tb->txtCode.LinesCount - 1
			GetBiFile(ptxtCode, txtCodeBi, ptxtCodeBi, tb, IsBas, bFind, i, iStart, iEnd)
			For k As Integer = iStart To iEnd
				If StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "#include ") Then
					j = k + 1
				ElseIf StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "redefineclasskeyword") Then
					t = True
					Exit For, For
				End If
			Next
		Next
		Var InsLineCount = 0
		If Not t Then
			CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
			ptxtCode->InsertLine j, ..Left(ptxtCode->Lines(j - 1), Len(ptxtCode->Lines(j - 1)) - Len(LTrim(ptxtCode->Lines(j - 1), Any !"\t "))) & "RedefineClassKeyword"
			InsLineCount += 1
		End If
	End If
	Dim As Integer i = tb->txtCode.LinesCount, q1, q2
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
		tb->txtCode.InsertLine i + q1 + 1, IIf(optPublicScope.Checked, "Public ", IIf(optPrivateScope.Checked, "Private ", "")) & sType & " " & txtName.Text & IIf(txtAlias.Text = "", "", " Alias """ & txtAlias.Text & """") & IIf(cboExtends.ItemIndex = 0, "", " Extends " & cboExtends.Text) & IIf(txtField.Position = 0, "", " Field = " & txtField.Text)
		If optClass.Checked AndAlso chkRedefineClassKeyword.Checked Then
			tb->txtCode.InsertLine i + q1 + 2, !"\t"
			tb->txtCode.InsertLine i + q1 + 3, !"\t__StartOfClassBody__"
			tb->txtCode.InsertLine i + q1 + 4, !"\t"
			tb->txtCode.InsertLine i + q1 + 5, !"\t__EndOfClassBody__"
			tb->txtCode.InsertLine i + q1 + 6, !"\t"
			tb->txtCode.InsertLine i + q1 + 7, "End " & sType
		Else
			tb->txtCode.InsertLine i + q1 + 2, !"\t"
			tb->txtCode.InsertLine i + q1 + 3, "End " & sType
		End If
	Else
		sTypeName = cboType.Text
		sTypeNameDot = sTypeName & "."
		Dim As TypeElement Ptr te = cboType.ItemData(cboType.ItemIndex)
		Dim As String SpaceStr
		Dim As Integer iStart, iEnd, LineToAdd, LineEndPublic = -1, LineEndProtected = -1, LineEndPrivate = -1, LineEndType = -1
		Dim As Boolean bFind, b, bPublic = True, bPrivate, bProtected, IsBas = EndsWith(LCase(tb->FileName), ".bas") OrElse EndsWith(LCase(tb->FileName), ".frm")
		Dim As EditControlLine Ptr FLine
		For i As Integer = 0 To tb->txtCode.LinesCount - 1
			GetBiFile(ptxtCode, txtCodeBi, ptxtCodeBi, tb, IsBas, bFind, i, iStart, iEnd)
			For k As Integer = iStart To iEnd
				FLine = ptxtCode->Content.Lines.Item(k)
				If (Not b) AndAlso Cbool(FLine->ConstructionIndex = C_Class OrElse FLine->ConstructionIndex = C_Type) AndAlso Cbool(FLine->ConstructionPart = 0) AndAlso CBool(FLine->InConstruction = te) Then '(StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t ") & " ", "type " & LCase(sTypeName) & " ") OrElse StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t ") & " ", "class " & LCase(sTypeName) & " ")) Then
					ptxtCodeType = ptxtCode
					b = True
				ElseIf b Then
					If StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t ") & " ", "end type ") OrElse StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t ") & " ", "end class ") OrElse StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t ") & " ", "__startofclassbody__ ") Then
						If bPrivate Then LineEndPrivate = k
						If bProtected Then LineEndProtected = k
						If bPublic Then LineEndPublic = k
						LineEndType = k
						SpaceStr = .Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t ")))
						If StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t ") & " ", "__startofclassbody__ ") Then bAddSpaces = False
						Exit For, For
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
					ptxtCode->InsertLine LineToAdd + q2 + j, SpaceStr & IIf(bAddSpaces, !"\t", "") & "'" & res(j)
				Next
				q2 += UBound(res) + 1
				If ptxtCode = @tb->txtCode Then q1 += UBound(res) + 1
			End If
			ptxtCode = ptxtCodeType
			CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
			ptxtCode->InsertLine LineToAdd + q2, SpaceStr & IIf(bAddSpaces, !"\t", "") & IIf(optPublicScope.Checked, "Public ", IIf(optPrivateScope.Checked, "Private ", "")) & sType & " " & txtName.Text & IIf(txtAlias.Text = "", "", " Alias """ & txtAlias.Text & """") & IIf(cboExtends.ItemIndex = 0, "", " Extends " & cboExtends.Text) & IIf(txtField.Position = 0, "", " Field = " & txtField.Text)
			ptxtCode->InsertLine LineToAdd + q2 + 1, SpaceStr & IIf(bAddSpaces, !"\t", "") & !"\t"
			ptxtCode->InsertLine LineToAdd + q2 + 2, SpaceStr & IIf(bAddSpaces, !"\t", "") & "End " & sType
			i = LineToAdd - 2
			If ptxtCode = @tb->txtCode Then q1 += 1
		End If
	End If
	tb->txtCode.Changed "Insert type"
	tb->txtCode.SetSelection i + q1 + 2, i + q1 + 2, 1, 1
	tb->txtCode.TopLine = i + q1 + 1
	tb->txtCode.SetFocus
	bNotDesignForms = True
	tb->txtCode.Changed "Insert type"
	'OnLineChangeEdit tb->txtCode, i + q1 + 2, i + q1 + 2
	bNotDesignForms = False
	This.CloseForm
End Sub

Private Sub frmAddTypeType.cboType_Change(ByRef Sender As ComboBoxEdit)
	Dim As Boolean bEnabled = cboType.ItemIndex <> 0
	optPublicAccess.Enabled = bEnabled
	optProtectedAccess.Enabled = bEnabled
	optPrivateAccess.Enabled = bEnabled
	optPublicScope.Enabled = Not bEnabled
	optPrivateScope.Enabled = Not bEnabled
	optDefaultScope.Enabled = Not bEnabled
End Sub

Private Sub frmAddTypeType.Form_Create(ByRef Sender As Control)
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	txtName.Text = ""
	txtAlias.Text = ""
	txtDescription.Text = ""
	txtField.Position = 0
	Dim te As TypeElement Ptr
	cboType.Clear
	cboType.AddItem ML("(not selected)")
	For i As Integer = 0 To tb->txtCode.Content.Types.Count - 1
		te = tb->txtCode.Content.Types.Object(i)
		cboType.AddItem te->Name
		cboType.ItemData(cboType.ItemCount - 1) = te
	Next
	cboType.ItemIndex = 0
	cboExtends.Clear
	cboExtends.AddItem ML("(not selected)")
	For i As Integer = 0 To tb->txtCode.Content.Types.Count - 1
		te = tb->txtCode.Content.Types.Object(i)
		If te->TypeName <> "" AndAlso te->ElementType <> ElementTypes.E_TypeCopy Then 
			cboExtends.AddItem te->Name
			cboExtends.ItemData(cboExtends.ItemCount - 1) = te
		End If
	Next
	For i As Integer = 0 To Comps.Count - 1
		te = Comps.Object(i)
		If te->TypeName <> "" AndAlso te->ElementType <> ElementTypes.E_TypeCopy Then 
			cboExtends.AddItem te->Name
			cboExtends.ItemData(cboExtends.ItemCount - 1) = te
		End If
	Next
	For i As Integer = 0 To Globals.Types.Count - 1
		te = Globals.Types.Object(i)
		If te->TypeName <> "" AndAlso te->ElementType <> ElementTypes.E_TypeCopy Then 
			cboExtends.AddItem te->Name
			cboExtends.ItemData(cboExtends.ItemCount - 1) = te
		End If
	Next
	cboExtends.ItemIndex = 0
	optPublicAccess.Checked = True
	optProtectedAccess.Checked = False
	optPrivateAccess.Checked = False
	optType.Checked = True
	optClass.Checked = False
	optUnion.Checked = False
	optPublicScope.Checked = False
	optPrivateScope.Checked = False
	optDefaultScope.Checked = True
	chkRedefineClassKeyword.Visible = False
End Sub

Private Sub frmAddTypeType.optClass_Click(ByRef Sender As RadioButton)
	Dim As Boolean bVisible = optClass.Checked
	chkRedefineClassKeyword.Visible = bVisible
End Sub

Private Sub frmAddTypeType.optType_Click(ByRef Sender As RadioButton)
	optClass_Click(Sender)
End Sub

Private Sub frmAddTypeType.optUnion_Click(ByRef Sender As RadioButton)
	optClass_Click(Sender)
End Sub
