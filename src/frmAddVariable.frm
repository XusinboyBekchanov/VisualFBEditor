'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/GroupBox.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/RadioButton.bi"
	#include once "mff/Label.bi"

	Using My.Sys.Forms

	Type frmAddVariableType Extends Form
		Declare Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Sub cmdOK_Click(ByRef Sender As Control)
		Declare Sub cboType_Change(ByRef Sender As ComboBoxEdit)
		Declare Sub cboProcedure_Change(ByRef Sender As ComboBoxEdit)
		Declare Sub cboDataType_Change(ByRef Sender As ComboBoxEdit)
		Declare Function GetTargetKind(ptxtCode As EditControl Ptr, LineIndex As Integer) As Integer
		Declare Function GetParameterPlace(ByRef sLine As WString, iKind As Integer) As Integer
		Declare Function GetProcedureType(ByRef sDataType As WString, ByRef sParameters As WString) As UString
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub optDeclaration_Click(ByRef Sender As RadioButton)
		Declare Sub chkByRef_Click(ByRef Sender As CheckBox)
		Declare Sub chkByVal_Click(ByRef Sender As CheckBox)
		Declare Sub UpdateControls
		Declare Sub FillProcedures
		Declare Function InsertParameter(ptxtCode As EditControl Ptr, LineIndex As Integer, ByRef sParameter As WString, ByRef sComment As WString, iFrom As Integer = 1) As Integer
		Declare Function GetCode(ByRef sLine As WString) As UString
		Declare Sub FindDeclarations(ptxtCode As EditControl Ptr, ByRef sSignature As WString, ByRef sTypeName As WString, iLines() As Integer)
		Declare Function GetCommaItem(ByRef sLine As WString, ByRef sPrefix As WString, ByRef sDataType As WString, ByRef sAsItem As WString, ByRef sNamedItem As WString) As UString
		Declare Function GetSignature(ptxtCode As EditControl Ptr, LineIndex As Integer, ByRef sTypeName As UString) As UString
		Declare Constructor

		Dim As Label lblName, lblAlias, lblDataType, lblParameters, lblValue, lblDescription, lblType, lblProcedure
		Dim As TextBox txtName, txtAlias, txtParameters, txtValue, txtDescription
		Dim As CommandButton cmdOK, cmdCancel
		Dim As GroupBox grbAccessControl, grbDeclaration, grbModifiers
		Dim As RadioButton optPublicAccess, optProtectedAccess, optPrivateAccess, optDim, optReDim, optStatic, optVar, optConst, optCommon, optExtern, optParameter, optDefine
		Dim As CheckBox chkShared, chkByVal, chkByRef, chkPreserve, chkImport, chkNewLine
		Dim As Boolean bInProcedure
		'0 - procedure, 1 - #define or #macro, 2 - variable of the Sub or Function type
		Dim As Integer iTargetKind
		Dim As ComboBoxEdit cboDataType, cboType, cboProcedure
	End Type

	Constructor frmAddVariableType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = .Language
			End With
		#endif
		' frmAddVariable
		With This
			.Name = "frmAddVariable"
			.Text = ML("Add Variable")
			.BorderStyle = FormBorderStyle.FixedDialog
			.MaximizeBox = False
			.MinimizeBox = False
			.Icon = "1"
			.Designer = @This
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.SetBounds 0, 0, 340, 595
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
		' lblAlias
		With lblAlias
			.Name = "lblAlias"
			.Text = ML("Alias") & ":"
			.TabIndex = 2
			.Caption = ML("Alias") & ":"
			.SetBounds 10, 40, 90, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtAlias
		With txtAlias
			.Name = "txtAlias"
			.Text = ""
			.TabIndex = 3
			.SetBounds 110, 40, 210, 20
			.Designer = @This
			.Parent = @This
		End With
		' lblDataType
		With lblDataType
			.Name = "lblDataType"
			.Text = ML("Data Type") & ":"
			.TabIndex = 4
			.Caption = ML("Data Type") & ":"
			.SetBounds 10, 70, 90, 20
			.Designer = @This
			.Parent = @This
		End With
		' cboDataType
		With cboDataType
			.Name = "cboDataType"
			.Text = ""
			.TabIndex = 5
			.Style = cbDropDown
			.SetBounds 110, 70, 210, 21
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit), @cboDataType_Change)
			.Parent = @This
		End With
		' lblParameters
		With lblParameters
			.Name = "lblParameters"
			.Text = ML("Parameters") & ":"
			.TabIndex = 6
			.Caption = ML("Parameters") & ":"
			.SetBounds 10, 100, 90, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtParameters
		With txtParameters
			.Name = "txtParameters"
			.Text = ""
			.TabIndex = 7
			.SetBounds 110, 100, 210, 20
			.Designer = @This
			.Parent = @This
		End With
		' lblValue
		With lblValue
			.Name = "lblValue"
			.Text = ML("Initial Value") & ":"
			.TabIndex = 8
			.Caption = ML("Initial Value") & ":"
			.SetBounds 10, 130, 90, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtValue
		With txtValue
			.Name = "txtValue"
			.Text = ""
			.TabIndex = 9
			.SetBounds 110, 130, 210, 20
			.Designer = @This
			.Parent = @This
		End With
		' lblDescription
		With lblDescription
			.Name = "lblDescription"
			.Text = ML("Description") & ":"
			.TabIndex = 10
			.Caption = ML("Description") & ":"
			.SetBounds 10, 160, 90, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtDescription
		With txtDescription
			.Name = "txtDescription"
			.TabIndex = 11
			.ScrollBars = ScrollBarsType.Vertical
			.WantReturn = True
			.Multiline = True
			.Text = ""
			.SetBounds 110, 160, 210, 40
			.Designer = @This
			.Parent = @This
		End With
		' lblType
		With lblType
			.Name = "lblType"
			.Text = ML("Type") & ":"
			.TabIndex = 12
			.Caption = ML("Type") & ":"
			.SetBounds 10, 210, 90, 20
			.Designer = @This
			.Parent = @This
		End With
		' cboType
		With cboType
			.Name = "cboType"
			.Text = ""
			.TabIndex = 13
			.SetBounds 110, 210, 210, 21
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit), @cboType_Change)
			.Parent = @This
		End With
		' lblProcedure
		With lblProcedure
			.Name = "lblProcedure"
			.Text = ML("Procedure") & ":"
			.TabIndex = 14
			.Caption = ML("Procedure") & ":"
			.SetBounds 10, 240, 90, 20
			.Designer = @This
			.Parent = @This
		End With
		' cboProcedure
		With cboProcedure
			.Name = "cboProcedure"
			.Text = ""
			.TabIndex = 15
			.SetBounds 110, 240, 210, 21
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit), @cboProcedure_Change)
			.Parent = @This
		End With
		' grbAccessControl
		With grbAccessControl
			.Name = "grbAccessControl"
			.Text = ML("Access Control")
			.TabIndex = 16
			.Caption = ML("Access Control")
			.SetBounds 10, 270, 310, 50
			.Designer = @This
			.Parent = @This
		End With
		' optPublicAccess
		With optPublicAccess
			.Name = "optPublicAccess"
			.Text = ML("Public")
			.TabIndex = 17
			.Caption = ML("Public")
			.SetBounds 10, 20, 95, 20
			.Designer = @This
			.Parent = @grbAccessControl
		End With
		' optProtectedAccess
		With optProtectedAccess
			.Name = "optProtectedAccess"
			.Text = ML("Protected")
			.TabIndex = 18
			.Caption = ML("Protected")
			.SetBounds 110, 20, 95, 20
			.Designer = @This
			.Parent = @grbAccessControl
		End With
		' optPrivateAccess
		With optPrivateAccess
			.Name = "optPrivateAccess"
			.Text = ML("Private")
			.TabIndex = 19
			.Caption = ML("Private")
			.SetBounds 210, 20, 95, 20
			.Designer = @This
			.Parent = @grbAccessControl
		End With
		' grbDeclaration
		With grbDeclaration
			.Name = "grbDeclaration"
			.Text = ML("Declaration")
			.TabIndex = 20
			.Caption = ML("Declaration")
			.SetBounds 10, 330, 310, 95
			.Designer = @This
			.Parent = @This
		End With
		' optDim
		With optDim
			.Name = "optDim"
			.Text = "Dim"
			.TabIndex = 21
			.Caption = "Dim"
			.SetBounds 10, 20, 95, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton), @optDeclaration_Click)
			.Parent = @grbDeclaration
		End With
		' optReDim
		With optReDim
			.Name = "optReDim"
			.Text = "ReDim"
			.TabIndex = 22
			.Caption = "ReDim"
			.SetBounds 110, 20, 95, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton), @optDeclaration_Click)
			.Parent = @grbDeclaration
		End With
		' optStatic
		With optStatic
			.Name = "optStatic"
			.Text = "Static"
			.TabIndex = 23
			.Caption = "Static"
			.SetBounds 210, 20, 95, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton), @optDeclaration_Click)
			.Parent = @grbDeclaration
		End With
		' optVar
		With optVar
			.Name = "optVar"
			.Text = "Var"
			.TabIndex = 24
			.Caption = "Var"
			.SetBounds 10, 45, 95, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton), @optDeclaration_Click)
			.Parent = @grbDeclaration
		End With
		' optConst
		With optConst
			.Name = "optConst"
			.Text = "Const"
			.TabIndex = 25
			.Caption = "Const"
			.SetBounds 110, 45, 95, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton), @optDeclaration_Click)
			.Parent = @grbDeclaration
		End With
		' optCommon
		With optCommon
			.Name = "optCommon"
			.Text = "Common"
			.TabIndex = 26
			.Caption = "Common"
			.SetBounds 210, 45, 95, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton), @optDeclaration_Click)
			.Parent = @grbDeclaration
		End With
		' optExtern
		With optExtern
			.Name = "optExtern"
			.Text = "Extern"
			.TabIndex = 27
			.Caption = "Extern"
			.SetBounds 10, 70, 95, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton), @optDeclaration_Click)
			.Parent = @grbDeclaration
		End With
		' optParameter
		With optParameter
			.Name = "optParameter"
			.Text = "Parameter"
			.TabIndex = 29
			.Caption = "Parameter"
			.SetBounds 210, 70, 95, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton), @optDeclaration_Click)
			.Parent = @grbDeclaration
		End With
		' optDefine
		With optDefine
			.Name = "optDefine"
			.Text = "Define"
			.TabIndex = 28
			.Caption = "Define"
			.SetBounds 110, 70, 95, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton), @optDeclaration_Click)
			.Parent = @grbDeclaration
		End With
		' grbModifiers
		With grbModifiers
			.Name = "grbModifiers"
			.Text = ML("Modifiers")
			.TabIndex = 30
			.Caption = ML("Modifiers")
			.SetBounds 10, 435, 310, 75
			.Designer = @This
			.Parent = @This
		End With
		' chkShared
		With chkShared
			.Name = "chkShared"
			.Text = "Shared"
			.TabIndex = 31
			.Caption = "Shared"
			.SetBounds 10, 20, 95, 20
			.Designer = @This
			.Parent = @grbModifiers
		End With
		' chkByRef
		With chkByRef
			.Name = "chkByRef"
			.Text = "ByRef"
			.TabIndex = 33
			.Caption = "ByRef"
			.SetBounds 210, 20, 95, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox), @chkByRef_Click)
			.Parent = @grbModifiers
		End With
		' chkPreserve
		With chkPreserve
			.Name = "chkPreserve"
			.Text = "Preserve"
			.TabIndex = 34
			.Caption = "Preserve"
			.SetBounds 10, 45, 95, 20
			.Designer = @This
			.Parent = @grbModifiers
		End With
		' chkImport
		With chkImport
			.Name = "chkImport"
			.Text = "Import"
			.TabIndex = 35
			.Caption = "Import"
			.SetBounds 110, 45, 95, 20
			.Designer = @This
			.Parent = @grbModifiers
		End With
		' chkByVal
		With chkByVal
			.Name = "chkByVal"
			.Text = "ByVal"
			.TabIndex = 32
			.Caption = "ByVal"
			.SetBounds 110, 20, 95, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox), @chkByVal_Click)
			.Parent = @grbModifiers
		End With
		' chkNewLine
		With chkNewLine
			.Name = "chkNewLine"
			.Text = ML("New line")
			.TabIndex = 36
			.Caption = ML("New line")
			.SetBounds 10, 520, 130, 20
			.Designer = @This
			.Parent = @This
		End With
		' cmdOK
		With cmdOK
			.Name = "cmdOK"
			.Text = ML("OK")
			.TabIndex = 37
			.Caption = ML("OK")
			.SetBounds 150, 520, 80, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdOK_Click)
			.Parent = @This
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = ML("Cancel")
			.TabIndex = 38
			.Caption = ML("Cancel")
			.SetBounds 240, 520, 80, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdCancel_Click)
			.Parent = @This
		End With
	End Constructor

	Dim Shared frmAddVariable As frmAddVariableType

	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmAddVariable.MainForm = True
		frmAddVariable.Show
		App.Run
	#endif
'#End Region

Private Sub frmAddVariableType.cmdCancel_Click(ByRef Sender As Control)
	This.CloseForm
End Sub

Private Sub frmAddVariableType.cmdOK_Click(ByRef Sender As Control)
	Dim As UString sName = Trim(txtName.Text), sAlias = Trim(txtAlias.Text), sDataType = Trim(cboDataType.Text), sValue = Trim(txtValue.Text)
	If sName = "" Then
		MsgBox ML("Invalid variable name"), , mtError
		Exit Sub
	End If
	If sDataType = "" AndAlso Not (optConst.Checked OrElse optVar.Checked OrElse optDefine.Checked OrElse (optParameter.Checked AndAlso CBool(iTargetKind = 1))) Then
		MsgBox ML("Invalid data type"), , mtError
		Exit Sub
	End If
	If sValue = "" AndAlso (optConst.Checked OrElse optVar.Checked OrElse (chkByRef.Checked AndAlso Not (optExtern.Checked OrElse optParameter.Checked))) Then
		MsgBox ML("Invalid initial value"), , mtError
		Exit Sub
	End If
	'A variable of the Sub or Function type gets its parameters inside the type
	If txtParameters.Enabled AndAlso CBool(Trim(txtParameters.Text) <> "") AndAlso (Not optDefine.Checked) Then sDataType = GetProcedureType(sDataType, Trim(txtParameters.Text))
	If optReDim.Checked AndAlso InStr(sName, "(") = 0 Then
		MsgBox ML("ReDim requires array bounds in the name"), , mtError
		Exit Sub
	End If
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	If optParameter.Checked Then
		If cboProcedure.ItemIndex < 1 Then
			MsgBox ML("Select a procedure"), , mtError
			Exit Sub
		End If
		Dim As Integer iHeader = CInt(cboProcedure.ItemData(cboProcedure.ItemIndex))
		If iTargetKind <> 0 Then
			'#define and #macro take only names, a variable of the Sub or Function type takes the parameter into its type
			Dim As UString sTargetParameter = sName, sTargetLine = tb->txtCode.Lines(iHeader), sTargetComment
			If iTargetKind = 2 Then
				sTargetParameter = ""
				If chkByVal.Checked Then sTargetParameter = "ByVal "
				If chkByRef.Checked Then sTargetParameter = "ByRef "
				sTargetParameter &= sName & " As " & sDataType
				If sValue <> "" Then sTargetParameter &= " = " & sValue
			End If
			sTargetComment = Trim(Replace(txtDescription.Text, Chr(13) & Chr(10), " "))
			Dim As Integer iPlace = GetParameterPlace(sTargetLine, iTargetKind), iNext
			If iPlace = 0 Then Exit Sub
			iNext = iPlace + 1
			Do While iNext <= Len(sTargetLine) AndAlso (Mid(sTargetLine, iNext, 1) = " " OrElse Mid(sTargetLine, iNext, 1) = !"\t")
				iNext += 1
			Loop
			tb->txtCode.Changing "Insert parameter"
			If Mid(sTargetLine, iNext, 1) = "(" Then
				InsertParameter @tb->txtCode, iHeader, sTargetParameter, sTargetComment, iNext
			Else
				If sTargetComment <> "" Then sTargetParameter &= " /'" & Replace(sTargetComment, "'/", "' /") & "'/"
				tb->txtCode.ReplaceLine iHeader, .Left(sTargetLine, iPlace) & "(" & sTargetParameter & ")" & Mid(sTargetLine, iPlace + 1)
			End If
			tb->txtCode.SetSelection iHeader, iHeader, Len(tb->txtCode.Lines(iHeader)), Len(tb->txtCode.Lines(iHeader))
			tb->txtCode.SetFocus
			bNotDesignForms = True
			tb->txtCode.Changed "Insert parameter"
			bNotDesignForms = False
			This.CloseForm
			Exit Sub
		End If
		If Cast(EditControlLine Ptr, tb->txtCode.Content.Lines.Item(iHeader))->ConstructionIndex = C_Destructor Then
			MsgBox ML("A destructor cannot have parameters"), , mtError
			Exit Sub
		End If
		Dim As UString sParameter, sHeaderType, sSignature
		If chkByVal.Checked Then sParameter = "ByVal "
		If chkByRef.Checked Then sParameter = "ByRef "
		sParameter &= sName & " As " & sDataType
		If sValue <> "" Then sParameter &= " = " & sValue
		'The description of a parameter stays beside it, on one line
		Dim As UString sComment = Trim(Replace(txtDescription.Text, Chr(13) & Chr(10), " "))
		Dim As Integer iLines(Any), iHeaderShift
		sSignature = GetSignature(@tb->txtCode, iHeader, sHeaderType)
		tb->txtCode.Changing "Insert parameter"
		'The declarations have to stay the same as the procedure, also in the .bi file of this file
		Dim As EditControl Ptr ptxtCode, ptxtCodeBi
		Dim As EditControl txtCodeBi
		Dim As Integer iStart, iEnd, iBiLines(Any)
		Dim As Boolean bFind, IsBas = EndsWith(LCase(tb->FileName), ".bas") OrElse EndsWith(LCase(tb->FileName), ".frm") OrElse EndsWith(LCase(tb->FileName), ".rpt")
		For k As Integer = 0 To tb->txtCode.LinesCount - 1
			GetBiFile(ptxtCode, txtCodeBi, ptxtCodeBi, tb, IsBas, bFind, k, iStart, iEnd)
			If bFind Then
				FindDeclarations ptxtCode, sSignature, sHeaderType, iBiLines()
				If UBound(iBiLines) > -1 Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->Changing "Insert parameter"
					For n As Integer = UBound(iBiLines) To 0 Step -1
						InsertParameter ptxtCode, iBiLines(n), sParameter, sComment
					Next
					ptxtCode->Changed "Insert parameter"
				End If
				Exit For
			End If
		Next
		FindDeclarations @tb->txtCode, sSignature, sHeaderType, iLines()
		'From the last line to the first, the added lines do not move the others
		Dim As Boolean bHeaderDone
		For n As Integer = UBound(iLines) To -1 Step -1
			If (Not bHeaderDone) AndAlso (CBool(n < 0) OrElse CBool(iLines(n) < iHeader)) Then
				InsertParameter @tb->txtCode, iHeader, sParameter, sComment
				bHeaderDone = True
			End If
			If n >= 0 Then
				Var iAdded = InsertParameter(@tb->txtCode, iLines(n), sParameter, sComment)
				If iLines(n) < iHeader Then iHeaderShift += iAdded
			End If
		Next
		iHeader += iHeaderShift
		tb->txtCode.SetSelection iHeader, iHeader, Len(tb->txtCode.Lines(iHeader)), Len(tb->txtCode.Lines(iHeader))
		tb->txtCode.SetFocus
		bNotDesignForms = True
		tb->txtCode.Changed "Insert parameter"
		bNotDesignForms = False
		This.CloseForm
		Exit Sub
	End If
	Dim As Boolean bInsideType = cboType.ItemIndex > 0 AndAlso cboProcedure.ItemIndex < 1
	Dim As UString sLine, sDefinition, res(), sPrefix, sAsItem, sNamedItem
	If optDefine.Checked Then
		Dim As UString sDefineParameters = Trim(txtParameters.Text)
		If StartsWith(sDefineParameters, "(") AndAlso EndsWith(sDefineParameters, ")") Then sDefineParameters = Trim(Mid(sDefineParameters, 2, Len(sDefineParameters) - 2))
		sLine = "#define " & sName
		If sDefineParameters <> "" Then sLine &= "(" & sDefineParameters & ")"
		If sValue <> "" Then sLine &= " " & sValue
	ElseIf optConst.Checked Then
		sPrefix = "Const "
		sNamedItem = sName
		If sDataType <> "" Then sNamedItem &= " As " & sDataType
		sNamedItem &= " = " & sValue
		sLine = sPrefix & sNamedItem
	ElseIf optVar.Checked Then
		sPrefix = "Var "
		If chkShared.Checked Then sPrefix &= "Shared "
		If chkByRef.Checked Then sPrefix &= "ByRef "
		sNamedItem = sName & " = " & sValue
		sLine = sPrefix & sNamedItem
	Else
		Select Case True
		Case optReDim.Checked: sLine = "ReDim "
		Case optStatic.Checked: sLine = "Static "
		Case optCommon.Checked: sLine = "Common "
		Case optExtern.Checked: sLine = "Extern "
		Case Else: sLine = "Dim "
		End Select
		If chkPreserve.Checked Then sLine &= "Preserve "
		If chkImport.Checked Then sLine &= "Import "
		If chkShared.Checked Then sLine &= "Shared "
		If chkByRef.Checked Then sLine &= "ByRef "
		sPrefix = sLine
		sAsItem = sName
		If optExtern.Checked AndAlso sAlias <> "" Then sAsItem &= " Alias """ & sAlias & """"
		sNamedItem = sAsItem & " As " & sDataType
		If bInsideType AndAlso optStatic.Checked Then
			'A static member gets its value where it is defined, outside the type
			sDefinition = "Dim "
			If chkByRef.Checked Then sDefinition &= "ByRef "
			sDefinition &= "As " & sDataType & " " & cboType.Text & "." & sName
			If sValue <> "" Then sDefinition &= " = " & sValue
		ElseIf sValue <> "" AndAlso txtValue.Enabled Then
			sAsItem &= " = " & sValue
			sNamedItem &= " = " & sValue
		End If
		sLine = sPrefix & "As " & sDataType & " " & sAsItem
	End If
	Dim As Integer iDescription
	If txtDescription.Text <> "" Then
		Split(txtDescription.Text, Chr(13) & Chr(10), res())
		iDescription = UBound(res) + 1
	End If
	Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar, LineToAdd, j
	Dim As UString SpaceStr
	Dim As EditControl Ptr ptxtCode
	If Not bInsideType Then
		If cboProcedure.ItemIndex > 0 Then
			'The first line of the selected procedure, after a header continued with " _"
			LineToAdd = CInt(cboProcedure.ItemData(cboProcedure.ItemIndex))
			SpaceStr = .Left(tb->txtCode.Lines(LineToAdd), Len(tb->txtCode.Lines(LineToAdd)) - Len(LTrim(tb->txtCode.Lines(LineToAdd), Any !"\t "))) & !"\t"
			Do While EndsWith(GetCode(tb->txtCode.Lines(LineToAdd)), " _") AndAlso LineToAdd < tb->txtCode.LinesCount - 1
				LineToAdd += 1
			Loop
			LineToAdd += 1
		Else
			'Variables have to be declared before they are used, so the place is the current line
			tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
			LineToAdd = iSelStartLine
			If tb->txtCode.LinesCount > 0 Then
				SpaceStr = .Left(tb->txtCode.Lines(LineToAdd), Len(tb->txtCode.Lines(LineToAdd)) - Len(LTrim(tb->txtCode.Lines(LineToAdd), Any !"\t ")))
				If chkNewLine.Checked Then
					Dim As UString sCurrent = LCase(LTrim(GetCode(tb->txtCode.Lines(LineToAdd)), Any !"\t ")) & " "
					If StartsWith(sCurrent, "dim ") OrElse StartsWith(sCurrent, "redim ") OrElse StartsWith(sCurrent, "static ") OrElse StartsWith(sCurrent, "var ") OrElse StartsWith(sCurrent, "const ") OrElse StartsWith(sCurrent, "common ") OrElse StartsWith(sCurrent, "extern ") Then LineToAdd += 1
				End If
			End If
		End If
		tb->txtCode.Changing "Insert variable"
		ptxtCode = @tb->txtCode
	Else
		Dim As EditControl Ptr ptxtCodeBi, ptxtCodeType
		Dim As EditControl txtCodeBi
		Dim As Integer iStart, iEnd, LineEndPublic = -1, LineEndProtected = -1, LineEndPrivate = -1, LineEndType = -1, q2
		Dim As Boolean bFind, b, bAddSpaces = True, bPublic = True, bPrivate, bProtected, IsBas = EndsWith(LCase(tb->FileName), ".bas") OrElse EndsWith(LCase(tb->FileName), ".frm") OrElse EndsWith(LCase(tb->FileName), ".rpt")
		Dim As String sTypeName = LCase(cboType.Text), sCodeLine
		For i As Integer = 0 To tb->txtCode.LinesCount - 1
			GetBiFile(ptxtCode, txtCodeBi, ptxtCodeBi, tb, IsBas, bFind, i, iStart, iEnd)
			For k As Integer = iStart To iEnd
				sCodeLine = Trim(LCase(ptxtCode->Lines(k)), Any !"\t ") & " "
				If Not b Then
					If StartsWith(sCodeLine, "public ") Then
						sCodeLine = LTrim(Mid(sCodeLine, 8), Any !"\t ")
					ElseIf StartsWith(sCodeLine, "private ") Then
						sCodeLine = LTrim(Mid(sCodeLine, 9), Any !"\t ")
					End If
					If (StartsWith(sCodeLine, "type " & sTypeName & " ") AndAlso Not StartsWith(sCodeLine, "type " & sTypeName & " as ")) OrElse StartsWith(sCodeLine, "class " & sTypeName & " ") Then
						ptxtCodeType = ptxtCode
						b = True
					End If
				ElseIf StartsWith(sCodeLine, "end type ") OrElse StartsWith(sCodeLine, "end class ") OrElse StartsWith(sCodeLine, "__startofclassbody__ ") Then
					If bPrivate Then LineEndPrivate = k
					If bProtected Then LineEndProtected = k
					If bPublic Then LineEndPublic = k
					LineEndType = k
					SpaceStr = .Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t ")))
					If StartsWith(sCodeLine, "__startofclassbody__ ") Then bAddSpaces = False
					Exit For, For
				ElseIf StartsWith(sCodeLine, "public:") Then
					bPublic = True
					If bPrivate Then LineEndPrivate = k: bPrivate = False
					If bProtected Then LineEndProtected = k: bProtected = False
				ElseIf StartsWith(sCodeLine, "protected:") Then
					bProtected = True
					If bPrivate Then LineEndPrivate = k: bPrivate = False
					If bPublic Then LineEndPublic = k: bPublic = False
				ElseIf StartsWith(sCodeLine, "private:") Then
					bPrivate = True
					If bProtected Then LineEndProtected = k: bProtected = False
					If bPublic Then LineEndPublic = k: bPublic = False
				End If
			Next
		Next
		If LineEndType = -1 Then
			MsgBox ML("Type not found"), , mtError
			Exit Sub
		End If
		tb->txtCode.Changing "Insert variable"
		ptxtCode = ptxtCodeType
		CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
		If ptxtCode <> @tb->txtCode Then ptxtCode->Changing "Insert variable"
		If optPublicAccess.Checked Then
			LineToAdd = LineEndPublic
			If LineToAdd = -1 Then ptxtCode->InsertLine LineEndType, SpaceStr & "Public:": q2 = 1
		ElseIf optProtectedAccess.Checked Then
			LineToAdd = LineEndProtected
			If LineToAdd = -1 Then ptxtCode->InsertLine LineEndType, SpaceStr & "Protected:": q2 = 1
		Else
			LineToAdd = LineEndPrivate
			If LineToAdd = -1 Then ptxtCode->InsertLine LineEndType, SpaceStr & "Private:": q2 = 1
		End If
		If LineToAdd = -1 Then LineToAdd = LineEndType
		LineToAdd += q2
		If bAddSpaces Then SpaceStr &= !"\t"
	End If
	'Without New line the variable joins the declaration it stands on, when the compiler allows that
	Dim As Boolean bComma
	If (Not chkNewLine.Checked) AndAlso sDefinition = "" AndAlso sPrefix <> "" Then
		Dim As Integer iCommaLine = LineToAdd
		If bInsideType Then iCommaLine = LineToAdd - 1
		If iCommaLine >= 0 AndAlso iCommaLine < ptxtCode->LinesCount Then
			Dim As UString sCommaLine = ptxtCode->Lines(iCommaLine), sItem = GetCommaItem(sCommaLine, sPrefix, sDataType, sAsItem, sNamedItem)
			If sItem <> "" Then
				If txtDescription.Text <> "" Then sItem &= " /'" & Replace(Trim(Replace(txtDescription.Text, Chr(13) & Chr(10), " ")), "'/", "' /") & "'/"
				Dim As Integer iCodeLen = Len(GetCode(sCommaLine))
				sLine = .Left(sCommaLine, iCodeLen) & ", " & sItem
				ptxtCode->ReplaceLine iCommaLine, sLine & Mid(sCommaLine, iCodeLen + 1)
				LineToAdd = iCommaLine
				SpaceStr = ""
				iDescription = 0
				bComma = True
			End If
		End If
	End If
	If Not bComma Then
		For j = 0 To iDescription - 1
			ptxtCode->InsertLine LineToAdd + j, SpaceStr & "'" & res(j)
		Next
		ptxtCode->InsertLine LineToAdd + iDescription, SpaceStr & sLine
	End If
	If sDefinition <> "" Then
		tb->txtCode.InsertLine tb->txtCode.LinesCount, ""
		tb->txtCode.InsertLine tb->txtCode.LinesCount, sDefinition
	End If
	If ptxtCode = @tb->txtCode Then
		tb->txtCode.SetSelection LineToAdd + iDescription, LineToAdd + iDescription, Len(SpaceStr & sLine), Len(SpaceStr & sLine)
	Else
		ptxtCode->Changed "Insert variable"
	End If
	tb->txtCode.SetFocus
	bNotDesignForms = True
	tb->txtCode.Changed "Insert variable"
	bNotDesignForms = False
	This.CloseForm
End Sub

Private Function Choose_Keyword(Index As Integer) As String
	Select Case Index
	Case 0: Return "sub"
	Case 1: Return "function"
	Case 2: Return "property"
	Case 3: Return "operator"
	Case 4: Return "constructor"
	Case Else: Return "destructor"
	End Select
End Function

'Name and parameters of a procedure line in lower case and without spaces, the same for its declaration
Private Function frmAddVariableType.GetSignature(ptxtCode As EditControl Ptr, LineIndex As Integer, ByRef sTypeName As UString) As UString
	Dim As UString sCode, sPart
	Dim As Integer k = LineIndex, iPos, iKeyword, iDepth
	Do
		sPart = GetCode(ptxtCode->Lines(k))
		If Not EndsWith(sPart, " _") Then sCode &= sPart: Exit Do
		sCode &= .Left(sPart, Len(sPart) - 1)
		k += 1
	Loop While k < ptxtCode->LinesCount
	'Declare Constructor() has a parenthesis right after the keyword
	sCode = " " & Replace(LCase(Trim(sCode, Any !"\t ")), "(", " (") & " "
	Dim As Boolean bConstructor
	Dim As UString sKeywordName
	For j As Integer = 0 To 5
		Dim As String sKeyword = " " & Choose_Keyword(j) & " "
		iPos = InStr(sCode, sKeyword)
		If iPos > 0 AndAlso (iKeyword = 0 OrElse iPos < iKeyword) Then
			iKeyword = iPos
			bConstructor = j >= 4
			sKeywordName = Trim(sKeyword)
			iPos = iPos + Len(sKeyword)
			sPart = Mid(sCode, iPos)
		End If
	Next
	If iKeyword = 0 Then Return ""
	sPart = LTrim(sPart, Any !"\t ")
	'The parameter list is what stands between the first parentheses
	Dim As UString sName, sParameters
	iPos = InStr(sPart, "(")
	If iPos > 0 Then
		iDepth = 0
		For j As Integer = iPos To Len(sPart)
			If Mid(sPart, j, 1) = "(" Then iDepth += 1
			If Mid(sPart, j, 1) = ")" Then iDepth -= 1
			If iDepth = 0 Then sParameters = Mid(sPart, iPos + 1, j - iPos - 1): Exit For
		Next
		sName = .Left(sPart, iPos - 1)
	Else
		sName = sPart
	End If
	sName = Trim(sName, Any !"\t ")
	If InStr(sName, " ") > 0 Then sName = .Left(sName, InStr(sName, " ") - 1)
	If InStr(sName, ".") > 0 Then
		sTypeName = .Left(sName, InStrRev(sName, ".") - 1)
		sName = Mid(sName, InStrRev(sName, ".") + 1)
	ElseIf bConstructor Then
		'Constructor T in the code and Declare Constructor in the type
		sTypeName = sName
		sName = ""
	Else
		sTypeName = ""
	End If
	If bConstructor Then sName = sKeywordName
	Return sName & "|" & Replace(Replace(sParameters, " ", ""), !"\t", "")
End Function

'What to add after a comma to the declaration in the line, empty when it cannot go there
Private Function frmAddVariableType.GetCommaItem(ByRef sLine As WString, ByRef sPrefix As WString, ByRef sDataType As WString, ByRef sAsItem As WString, ByRef sNamedItem As WString) As UString
	If InStr(sLine, "/'") > 0 Then Return ""
	Dim As UString sCode = LCase(Trim(GetCode(sLine), Any !"\t ")), sRest
	If EndsWith(sCode, " _") OrElse CBool(InStr(sCode, ":") > 0) OrElse (Not StartsWith(sCode, LCase(sPrefix))) Then Return ""
	sRest = Mid(sCode, Len(sPrefix) + 1) & " "
	If StartsWith(sRest, "as ") Then
		If sAsItem <> "" AndAlso StartsWith(sRest, "as " & LCase(sDataType) & " ") Then Return sAsItem
		Return ""
	End If
	If StartsWith(sRest, "shared ") OrElse StartsWith(sRest, "byref ") OrElse StartsWith(sRest, "preserve ") OrElse StartsWith(sRest, "import ") Then Return ""
	Return sNamedItem
End Function

'What the parameter can be added to: 0 - a procedure, 1 - #define or #macro, 2 - a variable of the Sub or Function type
Private Function frmAddVariableType.GetTargetKind(ptxtCode As EditControl Ptr, LineIndex As Integer) As Integer
	If LineIndex < 0 OrElse LineIndex >= ptxtCode->LinesCount Then Return 0
	Dim As EditControlLine Ptr FLine = ptxtCode->Content.Lines.Item(LineIndex)
	If FLine->ConstructionIndex >= C_Sub AndAlso FLine->ConstructionIndex <= C_Destructor AndAlso FLine->ConstructionPart = 0 Then Return 0
	Dim As UString sCode = LCase(Trim(GetCode(ptxtCode->Lines(LineIndex)), Any !"\t ")) & " "
	If StartsWith(sCode, "#define ") OrElse StartsWith(sCode, "#macro ") Then Return 1
	If StartsWith(sCode, "declare ") OrElse StartsWith(sCode, "type ") Then Return 0
	If GetParameterPlace(ptxtCode->Lines(LineIndex), 2) > 0 Then Return 2
	Return 0
End Function

'The position after the name of the #define or #macro, or after Sub or Function of the type of a variable
Private Function frmAddVariableType.GetParameterPlace(ByRef sLine As WString, iKind As Integer) As Integer
	Dim As UString sLower = LCase(GetCode(sLine)) & " ", sChar
	Dim As Integer iPos
	If iKind = 1 Then
		iPos = InStr(sLower, "#define ")
		If iPos > 0 Then iPos += 8 Else iPos = InStr(sLower, "#macro "): If iPos > 0 Then iPos += 7
		If iPos = 0 Then Return 0
		Do While Mid(sLower, iPos, 1) = " " OrElse Mid(sLower, iPos, 1) = !"\t"
			iPos += 1
		Loop
		Do While iPos <= Len(sLower)
			sChar = Mid(sLower, iPos, 1)
			If Not ((sChar >= "a" AndAlso sChar <= "z") OrElse (sChar >= "0" AndAlso sChar <= "9") OrElse sChar = "_") Then Exit Do
			iPos += 1
		Loop
		Return iPos - 1
	End If
	Dim As String sKeywords(1) = {" as sub", " as function"}
	For n As Integer = 0 To 1
		iPos = InStr(sLower, sKeywords(n))
		Do While iPos > 0
			sChar = Mid(sLower, iPos + Len(sKeywords(n)), 1)
			If sChar = "(" OrElse sChar = " " OrElse sChar = !"\t" Then Return iPos + Len(sKeywords(n)) - 1
			iPos = InStr(iPos + 1, sLower, sKeywords(n))
		Loop
	Next
	Return 0
End Function

'Sub or Function as the type gets the parameters after the keyword: Sub(ByVal a As Integer), Function(ByVal a As Integer) As Long
Private Function frmAddVariableType.GetProcedureType(ByRef sDataType As WString, ByRef sParameters As WString) As UString
	Dim As UString sLower = LCase(Trim(sDataType)) & " ", sList = Trim(sParameters), sKeyword
	If StartsWith(sLower, "sub ") OrElse StartsWith(sLower, "sub(") Then
		sKeyword = ..Left(Trim(sDataType), 3)
	ElseIf StartsWith(sLower, "function ") OrElse StartsWith(sLower, "function(") Then
		sKeyword = ..Left(Trim(sDataType), 8)
	Else
		Return sDataType
	End If
	Dim As UString sRest = Mid(Trim(sDataType), Len(sKeyword) + 1)
	If StartsWith(LTrim(sRest), "(") Then Return sDataType
	If StartsWith(sList, "(") AndAlso EndsWith(sList, ")") Then sList = Trim(Mid(sList, 2, Len(sList) - 2))
	Return sKeyword & "(" & sList & ")" & sRest
End Function

'The Declare lines of a procedure with this signature
Private Sub frmAddVariableType.FindDeclarations(ptxtCode As EditControl Ptr, ByRef sSignature As WString, ByRef sTypeName As WString, iLines() As Integer)
	Dim As UString sCodeLine, sLineType, sIgnored
	For k As Integer = 0 To ptxtCode->LinesCount - 1
		sCodeLine = LCase(Trim(ptxtCode->Lines(k), Any !"\t ")) & " "
		If StartsWith(sCodeLine, "public ") Then sCodeLine = LTrim(Mid(sCodeLine, 8), Any !"\t ")
		If StartsWith(sCodeLine, "private ") Then sCodeLine = LTrim(Mid(sCodeLine, 9), Any !"\t ")
		If StartsWith(sCodeLine, "type ") OrElse StartsWith(sCodeLine, "class ") Then
			sLineType = LTrim(Mid(sCodeLine, InStr(sCodeLine, " ") + 1), Any !"\t ")
			sLineType = .Left(sLineType, InStr(sLineType, " ") - 1)
		ElseIf StartsWith(sCodeLine, "end type ") OrElse StartsWith(sCodeLine, "end class ") Then
			sLineType = ""
		ElseIf StartsWith(sCodeLine, "declare ") AndAlso sLineType = sTypeName Then
			If GetSignature(ptxtCode, k, sIgnored) = sSignature Then
				ReDim Preserve iLines(UBound(iLines) + 1)
				iLines(UBound(iLines)) = k
			End If
		End If
	Next
End Sub

'The line without its comments
Private Function frmAddVariableType.GetCode(ByRef sLine As WString) As UString
	Dim As UString sCode, sChar
	Dim As Boolean bString
	Dim As Integer j = 1, iEnd
	Do While j <= Len(sLine)
		sChar = Mid(sLine, j, 1)
		If sChar = Chr(34) Then bString = Not bString
		If Not bString Then
			If sChar = "'" Then Exit Do
			If Mid(sLine, j, 2) = "/'" Then
				iEnd = InStr(j + 2, sLine, "'/")
				If iEnd = 0 Then Exit Do
				j = iEnd + 2
				Continue Do
			End If
		End If
		sCode &= sChar
		j += 1
	Loop
	Return RTrim(sCode, Any !"\t ")
End Function

'Adds the parameter to the end of the list and returns the number of the added lines.
'A comment needs " _" before it to go on with the list on the next line.
Private Function frmAddVariableType.InsertParameter(ptxtCode As EditControl Ptr, LineIndex As Integer, ByRef sParameter As WString, ByRef sComment As WString, iFrom As Integer = 1) As Integer
	Dim As UString sLine, sChar, sBefore, sAfter, sInline = sParameter, sIndent, sOnLine = sParameter & " _"
	Dim As Integer k = LineIndex, iDepth, iClose, iEnd
	Dim As Boolean bString, bEmpty = True
	If sComment <> "" Then
		sInline &= " /'" & Replace(sComment, "'/", "' /") & "'/"
		sOnLine &= " '" & sComment
	End If
	sLine = ptxtCode->Lines(LineIndex)
	sIndent = .Left(sLine, Len(sLine) - Len(LTrim(sLine, Any !"\t ")))
	Do
		sLine = ptxtCode->Lines(k)
		Dim As Integer j = IIf(k = LineIndex, iFrom, 1)
		Do While j <= Len(sLine)
			sChar = Mid(sLine, j, 1)
			If sChar = Chr(34) Then
				bString = Not bString
			ElseIf bString Then
			ElseIf sChar = "'" Then
				Exit Do
			ElseIf Mid(sLine, j, 2) = "/'" Then
				iEnd = InStr(j + 2, sLine, "'/")
				If iEnd = 0 Then Exit Do
				j = iEnd + 2
				Continue Do
			ElseIf sChar = "(" Then
				iDepth += 1
				If iDepth = 1 Then j += 1: Continue Do
			ElseIf sChar = ")" Then
				iDepth -= 1
				If iDepth = 0 Then iClose = j: Exit Do, Do
			End If
			If iDepth > 0 AndAlso sChar <> " " AndAlso sChar <> !"\t" AndAlso sChar <> "_" Then bEmpty = False
			j += 1
		Loop
		If Not EndsWith(GetCode(sLine), " _") Then Exit Do
		k += 1
	Loop While k < ptxtCode->LinesCount
	If iClose > 0 Then
		sBefore = .Left(sLine, iClose - 1)
		sAfter = Mid(sLine, iClose + 1)
		If CBool(Trim(sBefore, Any !"\t ") = "") AndAlso CBool(k > LineIndex) AndAlso (Not bEmpty) Then
			'The parenthesis has its own line: the comma goes to the parameter before it
			sLine = ptxtCode->Lines(k - 1)
			iEnd = InStrRev(.Left(sLine, Len(GetCode(sLine))), " _")
			If iEnd > 0 Then ptxtCode->ReplaceLine k - 1, .Left(sLine, iEnd - 1) & "," & Mid(sLine, iEnd)
			ptxtCode->InsertLine k, sIndent & !"\t" & sOnLine
			Return 1
		End If
		If Not chkNewLine.Checked Then
			If bEmpty Then
				ptxtCode->ReplaceLine k, sBefore & sInline & ")" & sAfter
			Else
				ptxtCode->ReplaceLine k, RTrim(sBefore, Any !"\t ") & ", " & sInline & ")" & sAfter
			End If
			Return 0
		End If
		If bEmpty Then
			sBefore = RTrim(sBefore, Any !"\t ") & " _"
		Else
			sBefore = RTrim(sBefore, Any !"\t ") & ", _"
		End If
	Else
		'There are no parentheses, so they go after the name and its alias
		k = LineIndex
		sLine = ptxtCode->Lines(k)
		Dim As UString sLower = LCase(sLine) & " "
		For j As Integer = 0 To 5
			Dim As String sKeyword = Choose_Keyword(j) & " "
			Dim As Integer iPos = InStr(" " & Replace(sLower, !"\t", " "), " " & sKeyword)
			If iPos > 0 AndAlso (iEnd = 0 OrElse iPos < iEnd) Then iEnd = iPos + Len(sKeyword) - 1
		Next
		If iEnd = 0 Then Return 0
		Do While iEnd < Len(sLine) AndAlso Mid(sLine, iEnd + 1, 1) = " "
			iEnd += 1
		Loop
		Do While iEnd < Len(sLine) AndAlso Mid(sLine, iEnd + 1, 1) <> " " AndAlso Mid(sLine, iEnd + 1, 1) <> !"\t"
			iEnd += 1
		Loop
		If StartsWith(LTrim(Mid(sLower, iEnd + 1), Any !"\t "), "alias ") Then
			iEnd = InStr(iEnd + 1, sLine, Chr(34))
			If iEnd > 0 Then iEnd = InStr(iEnd + 1, sLine, Chr(34))
			If iEnd = 0 Then iEnd = Len(RTrim(sLine, Any !"\t "))
		End If
		sAfter = Mid(sLine, iEnd + 1)
		If Not chkNewLine.Checked Then
			ptxtCode->ReplaceLine k, .Left(sLine, iEnd) & "(" & sInline & ")" & sAfter
			Return 0
		End If
		sBefore = .Left(sLine, iEnd) & "( _"
	End If
	ptxtCode->ReplaceLine k, sBefore
	If sComment = "" Then
		ptxtCode->InsertLine k + 1, sIndent & !"\t" & sParameter & ")" & sAfter
		Return 1
	End If
	ptxtCode->InsertLine k + 1, sIndent & !"\t" & sOnLine
	ptxtCode->InsertLine k + 2, sIndent & !"\t)" & sAfter
	Return 2
End Function

Private Sub frmAddVariableType.chkByRef_Click(ByRef Sender As CheckBox)
	If chkByRef.Checked Then chkByVal.Checked = False
End Sub

Private Sub frmAddVariableType.chkByVal_Click(ByRef Sender As CheckBox)
	If chkByVal.Checked Then chkByRef.Checked = False
End Sub

Private Sub frmAddVariableType.UpdateControls
	Dim As Boolean bInsideType = cboType.ItemIndex > 0 AndAlso cboProcedure.ItemIndex < 1, bInProcedure = This.bInProcedure OrElse cboProcedure.ItemIndex > 0
	optPublicAccess.Enabled = bInsideType
	optProtectedAccess.Enabled = bInsideType
	optPrivateAccess.Enabled = bInsideType
	'What the compiler accepts depends on the place of the declaration
	'A #define, a #macro or a variable of the Sub or Function type takes only a parameter.
	'Each state is set once, a control set off and on again blinks.
	optVar.Enabled = (Not bInsideType) AndAlso iTargetKind = 0
	optParameter.Enabled = Not bInsideType
	optDefine.Enabled = (Not bInsideType) AndAlso iTargetKind = 0
	optDim.Enabled = iTargetKind = 0
	optReDim.Enabled = iTargetKind = 0
	optStatic.Enabled = iTargetKind = 0
	optConst.Enabled = iTargetKind = 0
	If iTargetKind <> 0 Then
		optDim.Checked = False
		optReDim.Checked = False
		optStatic.Checked = False
		optVar.Checked = False
		optConst.Checked = False
		optCommon.Checked = False
		optExtern.Checked = False
		optDefine.Checked = False
		optParameter.Checked = True
	End If
	optCommon.Enabled = Not (bInsideType OrElse bInProcedure OrElse iTargetKind <> 0)
	optExtern.Enabled = Not (bInsideType OrElse bInProcedure OrElse iTargetKind <> 0)
	If (optVar.Checked AndAlso Not optVar.Enabled) OrElse (optDefine.Checked AndAlso Not optDefine.Enabled) OrElse (optParameter.Checked AndAlso Not optParameter.Enabled) OrElse (optCommon.Checked AndAlso Not optCommon.Enabled) OrElse (optExtern.Checked AndAlso Not optExtern.Enabled) Then
		optVar.Checked = False
		optDefine.Checked = False
		optParameter.Checked = False
		optCommon.Checked = False
		optExtern.Checked = False
		optDim.Checked = True
	End If
	Dim As Boolean bNameOnly = optParameter.Checked AndAlso iTargetKind = 1
	chkShared.Enabled = Not (bInsideType OrElse bInProcedure OrElse optConst.Checked OrElse optExtern.Checked OrElse optParameter.Checked OrElse optDefine.Checked)
	chkByVal.Enabled = optParameter.Checked AndAlso Not bNameOnly
	chkByRef.Enabled = (optParameter.Checked AndAlso Not bNameOnly) OrElse optStatic.Checked OrElse optExtern.Checked OrElse ((optDim.Checked OrElse optVar.Checked) AndAlso Not bInsideType)
	chkPreserve.Enabled = optReDim.Checked AndAlso Not bInsideType
	chkImport.Enabled = optExtern.Checked
	If Not chkShared.Enabled Then chkShared.Checked = False
	If Not chkByVal.Enabled Then chkByVal.Checked = False
	If Not chkByRef.Enabled Then chkByRef.Checked = False
	If Not chkPreserve.Enabled Then chkPreserve.Checked = False
	If Not chkImport.Enabled Then chkImport.Checked = False
	txtAlias.Enabled = optExtern.Checked
	If Not txtAlias.Enabled Then txtAlias.Text = ""
	cboDataType.Enabled = Not (optVar.Checked OrElse optDefine.Checked OrElse bNameOnly)
	txtValue.Enabled = Not (optReDim.Checked OrElse optCommon.Checked OrElse optExtern.Checked OrElse bNameOnly)
	If Not txtValue.Enabled Then txtValue.Text = ""
	'The parameters of a #define or #macro can have comments and go on the next lines too
	txtDescription.Enabled = True
	chkNewLine.Enabled = True
	'While an item is being selected, the text of the box is still the old one
	Dim As UString sTypeLower = LCase(Trim(cboDataType.Text)) & " ", sItemLower
	If cboDataType.ItemIndex > -1 Then sItemLower = LCase(Trim(cboDataType.Item(cboDataType.ItemIndex))) & " "
	txtParameters.Enabled = optDefine.Checked OrElse (cboDataType.Enabled AndAlso (StartsWith(sTypeLower, "sub ") OrElse StartsWith(sTypeLower, "sub(") OrElse StartsWith(sTypeLower, "function ") OrElse StartsWith(sTypeLower, "function(") OrElse StartsWith(sItemLower, "sub ") OrElse StartsWith(sItemLower, "function ")))
End Sub

'All the procedures of the file, or only those of the selected type
Private Sub frmAddVariableType.FillProcedures
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	Dim As EditControlLine Ptr FLine
	Dim As UString sProcedure, sTypeName, sSelectedType, sLineCode, sLineType
	If cboType.ItemIndex > 0 Then sSelectedType = LCase(cboType.Text)
	cboProcedure.Clear
	cboProcedure.AddItem ML("(not selected)")
	For k As Integer = 0 To tb->txtCode.LinesCount - 1
		FLine = tb->txtCode.Content.Lines.Item(k)
		If FLine->ConstructionIndex >= C_Sub AndAlso FLine->ConstructionIndex <= C_Destructor AndAlso FLine->ConstructionPart = 0 Then
			If sSelectedType <> "" Then
				GetSignature @tb->txtCode, k, sTypeName
				If sTypeName <> sSelectedType Then Continue For
			End If
			sProcedure = Trim(tb->txtCode.Lines(k), Any !"\t ")
			If InStr(sProcedure, "(") > 0 Then sProcedure = RTrim(.Left(sProcedure, InStr(sProcedure, "(") - 1), Any !"\t ")
			cboProcedure.AddItem sProcedure
			cboProcedure.ItemData(cboProcedure.ItemCount - 1) = Cast(Any Ptr, k)
		Else
			'The type the line is in, for its fields of the Sub or Function type
			sLineCode = LCase(Trim(GetCode(tb->txtCode.Lines(k)), Any !"\t ")) & " "
			If StartsWith(sLineCode, "public ") Then sLineCode = LTrim(Mid(sLineCode, 8))
			If StartsWith(sLineCode, "private ") Then sLineCode = LTrim(Mid(sLineCode, 9))
			If (StartsWith(sLineCode, "type ") OrElse StartsWith(sLineCode, "class ")) AndAlso InStr(Mid(sLineCode, InStr(sLineCode, " ") + 1), " as ") <> InStr(LTrim(Mid(sLineCode, InStr(sLineCode, " ") + 1)), " ") Then
				sLineType = LTrim(Mid(sLineCode, InStr(sLineCode, " ") + 1))
				sLineType = .Left(sLineType, InStr(sLineType, " ") - 1)
				Continue For
			ElseIf StartsWith(sLineCode, "end type ") OrElse StartsWith(sLineCode, "end class ") Then
				sLineType = ""
				Continue For
			End If
			Select Case GetTargetKind(@tb->txtCode, k)
			Case 1
				If sSelectedType <> "" Then Continue For
				sProcedure = Trim(GetCode(tb->txtCode.Lines(k)), Any !"\t ")
				If GetParameterPlace(sProcedure, 1) > 0 Then sProcedure = .Left(sProcedure, GetParameterPlace(sProcedure, 1))
			Case 2
				If sLineType <> sSelectedType Then Continue For
				sProcedure = Trim(GetCode(tb->txtCode.Lines(k)), Any !"\t ")
			Case Else
				Continue For
			End Select
			cboProcedure.AddItem sProcedure
			cboProcedure.ItemData(cboProcedure.ItemCount - 1) = Cast(Any Ptr, k)
		End If
	Next
	cboProcedure.ItemIndex = 0
	iTargetKind = 0
End Sub

Private Sub frmAddVariableType.cboType_Change(ByRef Sender As ComboBoxEdit)
	FillProcedures
	UpdateControls
End Sub

Private Sub frmAddVariableType.cboProcedure_Change(ByRef Sender As ComboBoxEdit)
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	iTargetKind = 0
	If tb <> 0 AndAlso cboProcedure.ItemIndex > 0 Then iTargetKind = GetTargetKind(@tb->txtCode, CInt(cboProcedure.ItemData(cboProcedure.ItemIndex)))
	UpdateControls
End Sub

Private Sub frmAddVariableType.cboDataType_Change(ByRef Sender As ComboBoxEdit)
	UpdateControls
End Sub

Private Sub frmAddVariableType.optDeclaration_Click(ByRef Sender As RadioButton)
	UpdateControls
End Sub

Private Sub frmAddVariableType.Form_Create(ByRef Sender As Control)
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	txtName.Text = ""
	txtAlias.Text = ""
	txtParameters.Text = ""
	iTargetKind = 0
	txtValue.Text = ""
	txtDescription.Text = ""
	Dim te As TypeElement Ptr
	cboDataType.Clear
	Dim As String DataTypes(...) = {"Boolean", "Byte", "UByte", "Short", "UShort", "Long", "ULong", "Integer", "UInteger", "LongInt", "ULongInt", "Single", "Double", "String", "ZString Ptr", "WString Ptr", "UString", "Any Ptr", "Sub", "Function As Integer"}
	For i As Integer = 0 To UBound(DataTypes)
		cboDataType.AddItem DataTypes(i)
	Next
	cboType.Clear
	cboType.AddItem ML("(not selected)")
	For i As Integer = 0 To tb->txtCode.Content.Types.Count - 1
		te = tb->txtCode.Content.Types.Object(i)
		If te->ElementType <> ElementTypes.E_TypeCopy Then
			cboType.AddItem te->Name
			cboDataType.AddItem te->Name
		End If
	Next
	Dim As EditControl Ptr ptxtCode, ptxtCodeBi
	Dim As EditControl txtCodeBi
	Dim As Integer iStart, iEnd
	Dim As Boolean bFind, IsBas = EndsWith(LCase(tb->FileName), ".bas") OrElse EndsWith(LCase(tb->FileName), ".frm") OrElse EndsWith(LCase(tb->FileName), ".rpt")
	Dim As UString sTypeLine
	For k As Integer = 0 To tb->txtCode.LinesCount - 1
		GetBiFile(ptxtCode, txtCodeBi, ptxtCodeBi, tb, IsBas, bFind, k, iStart, iEnd)
		If bFind Then
			For n As Integer = 0 To ptxtCode->LinesCount - 1
				sTypeLine = Trim(ptxtCode->Lines(n), Any !"\t ") & " "
				If StartsWith(LCase(sTypeLine), "public ") Then sTypeLine = LTrim(Mid(sTypeLine, 8), Any !"\t ")
				If StartsWith(LCase(sTypeLine), "private ") Then sTypeLine = LTrim(Mid(sTypeLine, 9), Any !"\t ")
				If StartsWith(LCase(sTypeLine), "type ") OrElse StartsWith(LCase(sTypeLine), "class ") Then
					sTypeLine = LTrim(Mid(sTypeLine, InStr(sTypeLine, " ") + 1), Any !"\t ")
					If InStr(LCase(sTypeLine), " as ") <> InStr(sTypeLine, " ") AndAlso InStr(sTypeLine, " ") > 1 Then
						sTypeLine = .Left(sTypeLine, InStr(sTypeLine, " ") - 1)
						If cboType.IndexOf(sTypeLine) = -1 Then
							cboType.AddItem sTypeLine
							cboDataType.AddItem sTypeLine
						End If
					End If
				End If
			Next
			Exit For
		End If
	Next
	cboDataType.Text = "Integer"
	cboType.ItemIndex = 0
	FillProcedures
	optPublicAccess.Checked = True
	optProtectedAccess.Checked = False
	optPrivateAccess.Checked = False
	optDim.Checked = True
	optReDim.Checked = False
	optStatic.Checked = False
	optVar.Checked = False
	optConst.Checked = False
	optCommon.Checked = False
	optExtern.Checked = False
	optParameter.Checked = False
	optDefine.Checked = False
	chkByVal.Checked = False
	chkNewLine.Checked = False
	chkShared.Checked = False
	chkByRef.Checked = False
	chkPreserve.Checked = False
	chkImport.Checked = False
	'Shared, Common and Extern are illegal inside a procedure
	Dim As EditControlLine Ptr FLine
	Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	bInProcedure = False
	For k As Integer = iSelStartLine - 1 To 0 Step -1
		FLine = tb->txtCode.Content.Lines.Item(k)
		If FLine->ConstructionIndex >= C_Sub AndAlso FLine->ConstructionIndex <= C_Destructor Then
			If FLine->ConstructionPart = 0 Then bInProcedure = True: Exit For
			If FLine->ConstructionPart = 2 Then Exit For
		End If
	Next
	UpdateControls
End Sub
