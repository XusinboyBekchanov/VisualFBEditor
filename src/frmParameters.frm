'#########################################################
'#  frmParameters.bas                                    #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "frmParameters.bi"
#include once "Main.bi"
#include once "frmCompilerOptions.frm"

'#Region "Form"
	Constructor frmParameters
		' frmParameters
		This.Name = "frmParameters"
		This.Text = "Parameters"
		This.Caption = ML("Parameters")
		This.StartPosition = FormStartPosition.CenterParent
		This.CancelButton = @cmdCancel
		This.DefaultButton = @cmdOK
		This.OnCreate = @Form_Create
		This.OnShow = @Form_Show
		This.SetBounds 0, 0, 742, 411
		' grbCompile
		grbCompile.Name = "grbCompile"
		grbCompile.Text = ML("Compile")
		grbCompile.TabIndex = 0
		grbCompile.SetBounds 8, 8, 712, 88
		grbCompile.Parent = @This
		' grbMake
		grbMake.Name = "grbMake"
		grbMake.Text = ML("Make")
		grbMake.TabIndex = 7
		grbMake.SetBounds 8, 96, 712, 88
		grbMake.Parent = @This
		' grbRun
		grbRun.Name = "grbRun"
		grbRun.Text = ML("Run")
		grbRun.TabIndex = 14
		grbRun.SetBounds 8, 184, 712, 58
		grbRun.Parent = @This
		' cmdOK
		cmdOK.Name = "cmdOK"
		cmdOK.Default = True
		cmdOK.Text = ML("OK")
		cmdOK.TabIndex = 25
		cmdOK.SetBounds 528, 340, 96, 24
		cmdOK.OnClick = @cmdOK_Click
		cmdOK.Parent = @This
		' cmdCancel
		cmdCancel.Name = "cmdCancel"
		cmdCancel.Text = ML("Cancel")
		cmdCancel.TabIndex = 26
		cmdCancel.SetBounds 624, 340, 96, 24
		cmdCancel.OnClick = @cmdCancel_Click
		cmdCancel.Parent = @This
		' txtfbc32
		With txtfbc32
			.Name = "txtfbc32"
			.TabIndex = 3
			.RightMargin = 20
			.SetBounds 376, 24, 321, 21
			.Parent = @grbCompile
		End With
		' txtfbc64
		With txtfbc64
			.Name = "txtfbc64"
			.TabIndex = 6
			.RightMargin = 20
			.SetBounds 376, 48, 321, 21
			.Parent = @grbCompile
		End With
		' txtMake1
		With txtMake1
			.Name = "txtMake1"
			.TabIndex = 10
			.SetBounds 376, 24, 321, 21
			.Parent = @grbMake
		End With
		' txtMake2
		With txtMake2
			.Name = "txtMake2"
			.TabIndex = 13
			.SetBounds 376, 48, 321, 21
			.Parent = @grbMake
		End With
		' txtRun
		With txtRun
			.Name = "txtRun"
			.TabIndex = 17
			.SetBounds 376, 24, 321, 21
			.Parent = @grbRun
		End With
		' lblfbc32
		With lblfbc32
			.Name = "lblfbc32"
			.Text = "fbc" & " " & ML("32-bit") & ":"
			.TabIndex = 1
			.SetBounds 16, 24, 66, 16
			.Caption = "fbc" & " " & ML("32-bit") & ":"
			.Parent = @grbCompile
		End With
		' lblfbc64
		With lblfbc64
			.Name = "lblfbc64"
			.Text = "fbc" & " " & ML("64-bit") & ":"
			.TabIndex = 4
			.SetBounds 16, 48, 66, 16
			.Caption = "fbc" & " " & ML("64-bit") & ":"
			.Parent = @grbCompile
		End With
		' lblMake1
		With lblMake1
			.Name = "lblMake1"
			.Text = ML("make") & " 1:"
			.TabIndex = 8
			.SetBounds 16, 24, 76, 16
			.Parent = @grbMake
		End With
		' llblMake2
		With llblMake2
			.Name = "llblMake2"
			.Text = ML("make") & " 2:"
			.TabIndex = 11
			.SetBounds 16, 48, 76, 16
			.Parent = @grbMake
		End With
		' lblRun
		With lblRun
			.Name = "lblRun"
			.Text = ML("run") & ":"
			.TabIndex = 15
			.SetBounds 16, 24, 256, 16
			.Parent = @grbRun
		End With
		' cboCompiler32
		With cboCompiler32
			.Name = "cboCompiler32"
			.Text = "ComboBoxEdit1"
			.TabIndex = 2
			.SetBounds 90, 24, 278, 21
			.Parent = @grbCompile
		End With
		' cboCompiler64
		With cboCompiler64
			.Name = "cboCompiler64"
			.Text = "ComboBoxEdit11"
			.TabIndex = 5
			.SetBounds 90, 48, 278, 21
			.Parent = @grbCompile
		End With
		' cboMake1
		With cboMake1
			.Name = "cboMake1"
			.Text = "ComboBoxEdit12"
			.TabIndex = 9
			.SetBounds 90, 24, 278, 21
			.Parent = @grbMake
		End With
		' cboMake2
		With cboMake2
			.Name = "cboMake2"
			.Text = "ComboBoxEdit111"
			.TabIndex = 12
			.SetBounds 90, 48, 278, 21
			.Parent = @grbMake
		End With
		' cboRun
		With cboRun
			.Name = "cboRun"
			.Text = "ComboBoxEdit13"
			.TabIndex = 16
			.SetBounds 90, 24, 278, 21
			.Parent = @grbRun
		End With
		' cboDebug
		' grbDebug
		With grbDebug
			.Name = "grbDebug"
			.Text = ML("Debug")
			.TabIndex = 18
			.SetBounds 8, 244, 712, 88
			.Parent = @This
		End With
		' txtRun1
		With txtDebug32
			.Name = "txtDebug32"
			.Text = ""
			.TabIndex = 21
			.SetBounds 376, 24, 321, 21
			.Parent = @grbDebug
		End With
		' lblDebug32
		With lblDebug32
			.Name = "lblDebug32"
			.Text = ML("debug") & " " & ML("32-bit") & ":"
			.TabIndex = 19
			.SetBounds 16, 28, 236, 16
			.Parent = @grbDebug
		End With
		' lblDebug1
		With lblDebug64
			.Name = "lblDebug64"
			.Text = ML("debug") & " " & ML("64-bit") & ":"
			.TabIndex = 22
			.SetBounds 16, 51, 266, 17
			.Parent = @grbDebug
		End With
		' txtDebug64
		With txtDebug64
			.Name = "txtDebug64"
			.TabIndex = 24
			.SetBounds 376, 48, 321, 21
			.Parent = @grbDebug
		End With
		' cboDebug64
		With cboDebug64
			.Name = "cboDebug64"
			.TabIndex = 23
			.SetBounds 90, 48, 278, 21
			.Parent = @grbDebug
		End With
		With cboDebug32
			.Name = "cboDebug32"
			.Text = "ComboBoxEdit112"
			.TabIndex = 20
			.SetBounds 90, 24, 278, 21
			.Parent = @grbDebug
		End With
		' lblAddCompilerOption32
		With lblAddCompilerOption32
			.Name = "lblAddCompilerOption32"
			.Text = "+"
			.Graphic = "//Add"
			.ID = 1175
			.BorderStyle = BorderStyles.bsNone
			.Style = LabelStyle.lsText
			.Transparent = False
			.SetBounds 680, 28, 12, 12
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @lblAddCompilerOption32_Click)
			.Parent = @grbCompile
		End With
		' lblAddCompilerOption64
		With lblAddCompilerOption64
			.Name = "lblAddCompilerOption64"
			.Text = "+"
			.ControlIndex = 6
			.Graphic = "//Add"
			.Caption = "+"
			.Style = LabelStyle.lsText
			.ID = 1058
			.SetBounds 680, 51, 12, 12
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @lblAddCompilerOption64_Click)
			.Parent = @grbCompile
		End With
	End Constructor
	
	Dim Shared fParameters As frmParameters
	pfParameters = @fParameters
	
	#ifndef _NOT_AUTORUN_FORMS_
		fParameters.Show
		
		App.Run
	#endif
'#End Region

Sub frmParameters.LoadSettings()
	With fParameters
		.txtfbc32.Text = *Compiler32Arguments
		.txtfbc64.Text = *Compiler64Arguments
		.txtMake1.Text = *Make1Arguments
		.txtMake2.Text = *Make2Arguments
		.txtRun.Text = *RunArguments
		.txtDebug32.Text = *Debug32Arguments
		.txtDebug64.Text = *Debug64Arguments
		.cboCompiler32.Clear
		.cboCompiler64.Clear
		For i As Integer = 0 To pCompilers->Count - 1
			.cboCompiler32.AddItem pCompilers->Item(i)->Key
			.cboCompiler64.AddItem pCompilers->Item(i)->Key
		Next
		.cboCompiler32.ItemIndex = .cboCompiler32.IndexOf(*CurrentCompiler32)
		.cboCompiler64.ItemIndex = .cboCompiler64.IndexOf(*CurrentCompiler64)
		If .cboCompiler32.ItemIndex = -1 Then .cboCompiler32.ItemIndex = .cboCompiler32.IndexOf(*DefaultCompiler32)
		If .cboCompiler64.ItemIndex = -1 Then .cboCompiler64.ItemIndex = .cboCompiler64.IndexOf(*DefaultCompiler64)
		.cboMake1.Clear
		.cboMake2.Clear
		For i As Integer = 0 To pMakeTools->Count - 1
			.cboMake1.AddItem pMakeTools->Item(i)->Key
			.cboMake2.AddItem pMakeTools->Item(i)->Key
		Next
		.cboMake1.ItemIndex = .cboMake1.IndexOf(*CurrentMakeTool1)
		.cboMake2.ItemIndex = .cboMake2.IndexOf(*CurrentMakeTool2)
		If .cboMake1.ItemIndex = -1 Then .cboMake1.ItemIndex = .cboMake1.IndexOf(*DefaultMakeTool)
		If .cboMake2.ItemIndex = -1 Then .cboMake2.ItemIndex = .cboMake2.IndexOf(*DefaultMakeTool)
		.cboRun.Clear
		For i As Integer = 0 To pTerminals->Count - 1
			.cboRun.AddItem pTerminals->Item(i)->Key
		Next
		.cboRun.ItemIndex = .cboRun.IndexOf(*CurrentTerminal)
		If .cboRun.ItemIndex = -1 Then .cboRun.ItemIndex = .cboRun.IndexOf(*DefaultTerminal)
		.cboDebug32.Clear
		.cboDebug32.AddItem ML("Integrated IDE Debugger")
		.cboDebug32.AddItem ML("Integrated GDB Debugger")
		.cboDebug64.Clear
		.cboDebug64.AddItem ML("Integrated IDE Debugger")
		.cboDebug64.AddItem ML("Integrated GDB Debugger")
		For i As Integer = 0 To pDebuggers->Count - 1
			.cboDebug32.AddItem pDebuggers->Item(i)->Key
			.cboDebug64.AddItem pDebuggers->Item(i)->Key
		Next
		.cboDebug32.ItemIndex = IIf(CurrentDebuggerType32 = CustomDebugger, .cboDebug32.IndexOf(*CurrentDebugger32), CurrentDebuggerType32)
		.cboDebug64.ItemIndex = IIf(CurrentDebuggerType64 = CustomDebugger, .cboDebug64.IndexOf(*CurrentDebugger64), CurrentDebuggerType64)
		If .cboDebug32.ItemIndex = -1 Then .cboDebug32.ItemIndex = IIf(DefaultDebuggerType32 = CustomDebugger, .cboDebug32.IndexOf(ML(*DefaultDebugger32)), DefaultDebuggerType32)
		If .cboDebug64.ItemIndex = -1 Then .cboDebug64.ItemIndex = IIf(DefaultDebuggerType64 = CustomDebugger, .cboDebug64.IndexOf(ML(*DefaultDebugger64)), DefaultDebuggerType64)
		If .cboDebug32.ItemIndex = -1 Then .cboDebug32.ItemIndex = 0
		If .cboDebug64.ItemIndex = -1 Then .cboDebug64.ItemIndex = 0
	End With
End Sub

Private Sub frmParameters.Form_Create(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fParameters
		.LoadSettings
	End With
End Sub

Private Sub frmParameters.Form_Show(ByRef Designer As My.Sys.Object, ByRef Sender As Form)
	
End Sub

Private Sub frmParameters.cmdOK_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fParameters
		WLet(Compiler32Arguments, .txtfbc32.Text)
		WLet(Compiler64Arguments, .txtfbc64.Text)
		WLet(Make1Arguments, .txtMake1.Text)
		WLet(Make2Arguments, .txtMake2.Text)
		WLet(RunArguments, .txtRun.Text)
		WLet(CurrentCompiler32, .cboCompiler32.Text)
		WLet(Compiler32Path, pCompilers->Get(*CurrentCompiler32, pCompilers->Get(*DefaultCompiler32)))
		WLet(CurrentCompiler64, .cboCompiler64.Text)
		WLet(Compiler64Path, pCompilers->Get(*CurrentCompiler64, pCompilers->Get(*DefaultCompiler64)))
		WLet(CurrentMakeTool1, .cboMake1.Text)
		WLet(MakeToolPath1, pMakeTools->Get(*CurrentMakeTool1, pMakeTools->Get(*DefaultMakeTool)))
		WLet(CurrentMakeTool2, .cboMake2.Text)
		WLet(MakeToolPath2, pMakeTools->Get(*CurrentMakeTool2, pMakeTools->Get(*DefaultMakeTool)))
		WLet(CurrentTerminal, .cboRun.Text)
		WLet(TerminalPath, IIf(.cboRun.ItemIndex = 0, pTerminals->Get(*DefaultTerminal), pTerminals->Get(*CurrentTerminal)))
		WLet(CurrentDebugger32, IIf(.cboDebug32.ItemIndex = 0, "Integrated IDE Debugger", IIf(.cboDebug32.ItemIndex = 1, "Integrated GDB Debugger", .cboDebug32.Text)))
		WLet(CurrentDebugger64, IIf(.cboDebug64.ItemIndex = 0, "Integrated IDE Debugger", IIf(.cboDebug64.ItemIndex = 1, "Integrated GDB Debugger", .cboDebug64.Text)))
		CurrentDebuggerType32 = IIf(.cboDebug32.ItemIndex = 0, IntegratedIDEDebugger, IIf(.cboDebug32.ItemIndex = 1, IntegratedGDBDebugger, CustomDebugger))
		CurrentDebuggerType64 = IIf(.cboDebug64.ItemIndex = 0, IntegratedIDEDebugger, IIf(.cboDebug64.ItemIndex = 1, IntegratedGDBDebugger, CustomDebugger))
		WLet(Debugger32Path, IIf(.cboDebug32.ItemIndex = 0, pDebuggers->Get(*DefaultDebugger32), pDebuggers->Get(*CurrentDebugger32)))
		WLet(Debugger64Path, IIf(.cboDebug64.ItemIndex = 0, pDebuggers->Get(*DefaultDebugger64), pDebuggers->Get(*CurrentDebugger64)))
		piniSettings->WriteString "Parameters", "Compiler32Arguments", *Compiler32Arguments
		piniSettings->WriteString "Parameters", "Compiler64Arguments", *Compiler64Arguments
		piniSettings->WriteString "Parameters", "Make1Arguments", *Make1Arguments
		piniSettings->WriteString "Parameters", "Make2Arguments", *Make2Arguments
		piniSettings->WriteString "Parameters", "RunArguments", *RunArguments
		piniSettings->WriteString "Parameters", "Debug32Arguments", *Debug32Arguments
		piniSettings->WriteString "Parameters", "Debug64Arguments", *Debug64Arguments
		.CloseForm
	End With
End Sub

Private Sub frmParameters.cmdCancel_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	fParameters.CloseForm
End Sub

Private Sub frmParameters.lblAddCompilerOption32_Click(ByRef Sender As Label)
	If frmCompilerOptions.ShowModal(Me) = ModalResults.OK Then
		For i As Integer = 0 To frmCompilerOptions.lvCompilerOptions.ListItems.Count - 1
			If frmCompilerOptions.lvCompilerOptions.ListItems.Item(i)->Checked Then
				txtfbc32.Text = RTrim(txtfbc32.Text) & " " & frmCompilerOptions.lvCompilerOptions.ListItems.Item(i)->Text(0)
			End If
		Next
		frmCompilerOptions.CloseForm
		Me.BringToFront
	End If
End Sub

Private Sub frmParameters.lblAddCompilerOption64_Click(ByRef Sender As Label)
	If frmCompilerOptions.ShowModal(Me) = ModalResults.OK Then
		For i As Integer = 0 To frmCompilerOptions.lvCompilerOptions.ListItems.Count - 1
			If frmCompilerOptions.lvCompilerOptions.ListItems.Item(i)->Checked Then
				txtfbc64.Text = RTrim(txtfbc64.Text) & " " & frmCompilerOptions.lvCompilerOptions.ListItems.Item(i)->Text(0)
			End If
		Next
		frmCompilerOptions.CloseForm
		Me.BringToFront
	End If
	
End Sub
