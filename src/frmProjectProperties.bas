'#########################################################
'#  frmProjectProperties.bas                             #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "frmProjectProperties.bi"
#include once "frmAdvancedOptions.bi"
#include once "TabWindow.bi"
#include once "Main.bi"
#include once "mff/Dictionary.bi"

Dim Shared fProjectProperties As frmProjectProperties
pfProjectProperties = @fProjectProperties

'#Region "Form"
	Constructor frmProjectProperties
		' frmProjectProperties
		This.Name = "frmProjectProperties"
		This.Text = ML("Project Properties")
		This.BorderStyle = FormBorderStyle.Fixed3D
		This.MaximizeBox = False
		This.MinimizeBox = False
		This.StartPosition = FormStartPosition.CenterScreen
		This.OnShow       = @Form_Show
		This.DefaultButton = @cmdOK
		This.CancelButton = @cmdCancel
		This.SetBounds 0, 0, 460, 378
		' tabProperties
		tabProperties.Name = "tabProperties"
		tabProperties.Text = "TabControl1"
		tabProperties.SetBounds 6, 6, 443, 307
		tabProperties.Parent = @This
		' tpGeneral
		tpGeneral.Name = "tpGeneral"
		tpGeneral.Text = ML("General")
		tpGeneral.SetBounds 2, 22, 445, 282
		tpGeneral.UseVisualStyleBackColor = True
		tpGeneral.Parent = @tabProperties
		' tpMake
		tpMake.Name = "tpMake"
		tpMake.Text = ML("Make")
		tpMake.SetBounds 0, 0, 405, 282
		tpMake.Visible = True
		tpMake.UseVisualStyleBackColor = True
		tpMake.Parent = @tabProperties
		' tpCompile
		tpCompile.Name = "tpCompile"
		tpCompile.Text = ML("Compile")
		tpCompile.SetBounds 0, 0, 405, 282
		tpCompile.Visible = True
		tpCompile.UseVisualStyleBackColor = True
		tpCompile.OnClick = @tpCompile_Click
		tpCompile.Parent = @tabProperties
		' cmdOK
		cmdOK.Name = "cmdOK"
		cmdOK.Text = ML("OK")
		cmdOK.SetBounds 218, 319, 73, 24
		cmdOK.OnClick = @cmdOK_Click
		cmdOK.Default = True
		cmdOK.Parent = @This
		' cmdCancel
		cmdCancel.Name = "cmdCancel"
		cmdCancel.Text = ML("Cancel")
		cmdCancel.SetBounds 296, 319, 73, 24
		cmdCancel.OnClick = @cmdCancel_Click
		cmdCancel.Parent = @This
		' cmdHelp
		cmdHelp.Name = "cmdHelp"
		cmdHelp.Text = ML("Help")
		cmdHelp.SetBounds 374, 319, 73, 24
		cmdHelp.Parent = @This
		' lblProjectType
		lblProjectType.Name = "lblProjectType"
		lblProjectType.Text = ML("Project Type") & ":"
		lblProjectType.SetBounds 10, 8, 144, 18
		lblProjectType.Parent = @tpGeneral
		' cboProjectType
		cboProjectType.Name = "cboProjectType"
		cboProjectType.Text = "ComboBoxEdit1"
		cboProjectType.SetBounds 10, 26, 202, 21
		cboProjectType.Parent = @tpGeneral
		' lblMainFile
		lblMainFile.Name = "lblMainFile"
		lblMainFile.Text = ML("Main File") & ":"
		lblMainFile.SetBounds 224, 8, 192, 18
		lblMainFile.Parent = @tpGeneral
		' cboMainFile
		cboMainFile.Name = "cboMainFile"
		cboMainFile.Text = "ComboBoxEdit11"
		cboMainFile.Sort = False
		cboMainFile.SetBounds 224, 26, 202, 21
		cboMainFile.Parent = @tpGeneral
		' lblProjectName
		lblProjectName.Name = "lblProjectName"
		lblProjectName.Text = ML("Project Name") & ":"
		lblProjectName.SetBounds 10, 56, 164, 18
		lblProjectName.Parent = @tpGeneral
		' txtProjectName
		txtProjectName.Name = "txtProjectName"
		txtProjectName.Text = ""
		txtProjectName.SetBounds 10, 74, 202, 21
		txtProjectName.Parent = @tpGeneral
		' lblProjectDescription
		lblProjectDescription.Name = "lblProjectDescription"
		lblProjectDescription.Text = ML("Project Description") & ":"
		lblProjectDescription.SetBounds 10, 152, 220, 18
		lblProjectDescription.Parent = @tpGeneral
		' txtProjectDescription
		txtProjectDescription.Name = "txtProjectDescription"
		txtProjectDescription.Text = ""
		txtProjectDescription.SetBounds 10, 170, 416, 21
		txtProjectDescription.Parent = @tpGeneral
		' grbVersionNumber
		grbVersionNumber.Name = "grbVersionNumber"
		grbVersionNumber.Text = ML("Version Number")
		grbVersionNumber.SetBounds 10, 8, 202, 102
		grbVersionNumber.Parent = @tpMake
		' grbApplication
		grbApplication.Name = "grbApplication"
		grbApplication.Text = ML("Application")
		grbApplication.SetBounds 224, 8, 202, 102
		grbApplication.Parent = @tpMake
		' grbVersionInformation
		grbVersionInformation.Name = "grbVersionInformation"
		grbVersionInformation.Text = ML("Version Information")
		grbVersionInformation.SetBounds 9, 113, 419, 161
		grbVersionInformation.Parent = @tpMake
		' grbCompilationArguments
		grbCompilationArguments.Name = "grbCompilationArguments"
		grbCompilationArguments.Text = ML("Compilation Arguments")
		grbCompilationArguments.SetBounds 10, 138, 419, 136
		grbCompilationArguments.Parent = @tpCompile
		' lblCompilationArguments64
		lblCompilationArguments64.Name = "lblCompilationArguments64"
		lblCompilationArguments64.Text = ML("For Windows") & ", " & ML("64-bit") & ":"
		lblCompilationArguments64.SetBounds 5, 30, 152, 18
		lblCompilationArguments64.Parent = @picCompilationArguments
		' lblIcon
		lblIcon.Name = "lblIcon"
		lblIcon.Text = ML("Icon") & ":"
		lblIcon.SetBounds 0, 41, 34, 18
		lblIcon.Parent = @picApplication
		' lblTitle
		lblTitle.Name = "lblTitle"
		lblTitle.Text = ML("Title") & ":"
		lblTitle.SetBounds 0, 17, 34, 18
		lblTitle.Parent = @picApplication
		' chkAutoIncrementVersion
		chkAutoIncrementVersion.Name = "chkAutoIncrementVersion"
		chkAutoIncrementVersion.Text = ML("Auto Increment Version")
		chkAutoIncrementVersion.SetBounds 6, 58, 164, 18
		chkAutoIncrementVersion.Parent = @picVersionNumber
		' lblMajor
		lblMajor.Name = "lblMajor"
		lblMajor.Text = ML("Major") & ":"
		lblMajor.SetBounds 7, 12, 42, 18
		lblMajor.Parent = @picVersionNumber
		' lblMinor
		lblMinor.Name = "lblMinor"
		lblMinor.Text = ML("Minor") & ":"
		lblMinor.SetBounds 55, 12, 42, 18
		lblMinor.Parent = @picVersionNumber
		' lblRevision
		lblRevision.Name = "lblRevision"
		lblRevision.Text = ML("Revision") & ":"
		lblRevision.SetBounds 101, 12, 48, 18
		lblRevision.BorderStyle = BorderStyles.bsNone
		lblRevision.Parent = @picVersionNumber
		' lblBuild
		lblBuild.Name = "lblBuild"
		lblBuild.Text = ML("Build") & ":"
		lblBuild.SetBounds 150, 12, 36, 18
		lblBuild.Parent = @picVersionNumber
		' cboResourceFile
		cboResourceFile.Name = "cboResourceFile"
		cboResourceFile.Text = "cboMainFile1"
		cboResourceFile.Sort = False
		cboResourceFile.SetBounds 224, 74, 202, 21
		cboResourceFile.Parent = @tpGeneral
		' lblResourceFile
		lblResourceFile.Name = "lblResourceFile"
		lblResourceFile.Text = ML("Resource File") & " (" & ML("For Windows") & "):"
		lblResourceFile.SetBounds 224, 56, 192, 18
		lblResourceFile.Parent = @tpGeneral
		' lblIconResourceFile
		lblIconResourceFile.Name = "lblIconResourceFile"
		lblIconResourceFile.Text = ML("Icon Resource File") & " (" & ML("For *nix/*bsd") & "):"
		lblIconResourceFile.SetBounds 224, 104, 192, 18
		lblIconResourceFile.Parent = @tpGeneral
		' cboIconResourceFile
		cboIconResourceFile.Name = "cboIconResourceFile"
		cboIconResourceFile.Text = "cboResourceFile1"
		cboIconResourceFile.Sort = False
		cboIconResourceFile.SetBounds 224, 122, 202, 21
		cboIconResourceFile.Parent = @tpGeneral
		' lblCompilationArguments32Linux
		lblCompilationArguments32Linux.Name = "lblCompilationArguments32Linux"
		lblCompilationArguments32Linux.Text = ML("For *nix/*bsd") & ", " & ML("32-bit") & ":"
		lblCompilationArguments32Linux.SetBounds 5, 57, 152, 18
		lblCompilationArguments32Linux.Parent = @picCompilationArguments
		' lblCompilationArguments64Linux
		lblCompilationArguments64Linux.Name = "lblCompilationArguments64Linux"
		lblCompilationArguments64Linux.Text = ML("For *nix/*bsd") & ", " & ML("64-bit") & ":"
		lblCompilationArguments64Linux.SetBounds 5, 85, 152, 18
		lblCompilationArguments64Linux.Parent = @picCompilationArguments
		' lblCompilationArguments32
		lblCompilationArguments32.Name = "lblCompilationArguments32"
		lblCompilationArguments32.Text = ML("For Windows") & ", " & ML("32-bit") & ":"
		lblCompilationArguments32.SetBounds 5, 4, 152, 18
		lblCompilationArguments32.Parent = @picCompilationArguments
		' lblType
		lblType.Name = "lblType"
		lblType.Text = ML("Type") & ":"
		lblType.SetBounds 7, 0, 82, 18
		lblType.Parent = @picVersionInformation
		' lblValue
		lblValue.Name = "lblValue"
		lblValue.Text = ML("Value") & ":"
		lblValue.SetBounds 207, 0, 106, 18
		lblValue.Parent = @picVersionInformation
		' txtHelpFileName
		txtHelpFileName.Name = "txtHelpFileName"
		txtHelpFileName.SetBounds 10, 122, 202, 21
		txtHelpFileName.Text = ""
		txtHelpFileName.Parent = @tpGeneral
		' lblHelpFileName
		lblHelpFileName.Name = "lblHelpFileName"
		lblHelpFileName.Text = ML("Help File") & ":"
		lblHelpFileName.SetBounds 10, 104, 172, 18
		lblHelpFileName.Parent = @tpGeneral
		' grbCompileToGCC
		grbCompileToGCC.Name = "grbCompileToGCC"
		grbCompileToGCC.Text = ""
		grbCompileToGCC.SetBounds 10, 35, 419, 101
		grbCompileToGCC.Parent = @tpCompile
		' optCompileToGas
		optCompileToGas.Name = "optCompileToGas"
		optCompileToGas.Text = ML("Compile to GAS")
		optCompileToGas.SetBounds 0, 5, 160, 16
		optCompileToGas.OnClick = @optCompileToGas_Click
		optCompileToGas.Parent = @picCompileToGCCCaption
		' optCompileToGcc
		optCompileToGcc.Name = "optCompileToGcc"
		optCompileToGcc.Text = ML("Compile to GCC")
		optCompileToGcc.SetBounds 0, 24, 152, 16
		optCompileToGcc.OnClick = @optCompileToGcc_Click
		optCompileToGcc.Parent = @picCompileToGCCCaption
		' tpDebugging
		tpDebugging.Name = "tpDebugging"
		tpDebugging.SetBounds 2, 22, 445, 282
		tpDebugging.UseVisualStyleBackColor = True
		tpDebugging.Visible = True
		tpDebugging.Text = ML("Debugging")
		tpDebugging.Parent = @tabProperties
		' lblCompilationArguments321
		lblCompilationArguments321.Name = "lblCompilationArguments321"
		lblCompilationArguments321.Text = ML("Command Line Arguments") & ":"
		lblCompilationArguments321.SetBounds 21, 16, 172, 18
		lblCompilationArguments321.Parent = @tpDebugging
		' txtCommandLineArguments
		txtCommandLineArguments.Name = "txtCommandLineArguments"
		txtCommandLineArguments.SetBounds 211, 14, 216, 21
		txtCommandLineArguments.Text = ""
		txtCommandLineArguments.Parent = @tpDebugging
		' picCompileToGCC
		picCompileToGCC.Name = "picCompileToGCC"
		picCompileToGCC.SetBounds 22, 51, 402, 80
		picCompileToGCC.Text = ""
		picCompileToGCC.Parent = @tpCompile
		' optOptimizationFastCode
		optOptimizationFastCode.Name = "optOptimizationFastCode"
		optOptimizationFastCode.Text = ML("Optimize for Fast Code")
		optOptimizationFastCode.SetBounds 10, 3, 184, 24
		optOptimizationFastCode.Parent = @picCompileToGCC
		' optOptimizationLevel
		optOptimizationLevel.Name = "optOptimizationLevel"
		optOptimizationLevel.Text = ML("Optimization level") & ":"
		optOptimizationLevel.SetBounds 210, 9, 120, 16
		optOptimizationLevel.Parent = @picCompileToGCC
		' optOptimizationSmallCode
		optOptimizationSmallCode.Name = "optOptimizationSmallCode"
		optOptimizationSmallCode.Text = ML("Optimize for Small Code")
		optOptimizationSmallCode.SetBounds 10, 29, 184, 16
		optOptimizationSmallCode.Parent = @picCompileToGCC
		' optNoOptimization
		optNoOptimization.Name = "optNoOptimization"
		optNoOptimization.Text = ML("No Optimization")
		optNoOptimization.SetBounds 10, 52, 192, 16
		optNoOptimization.Parent = @picCompileToGCC
		' chkCreateDebugInfo
		chkCreateDebugInfo.Name = "chkCreateDebugInfo"
		chkCreateDebugInfo.Text = ML("Create Symbolic Debug Info")
		chkCreateDebugInfo.SetBounds 211, 35, 208, 32
		chkCreateDebugInfo.Parent = @tpDebugging
		' Initialization
		cboProjectType.AddItem ML("Executable")
		cboProjectType.AddItem ML("Dynamic library")
		cboProjectType.AddItem ML("Static library")
		' cboOptimizationLevel
		cboOptimizationLevel.Name = "cboOptimizationLevel"
		cboOptimizationLevel.Text = "ComboBoxEdit1"
		cboOptimizationLevel.SetBounds 336, 6, 56, 21
		cboOptimizationLevel.Parent = @picCompileToGCC
		cboOptimizationLevel.AddItem "0"
		cboOptimizationLevel.AddItem "1"
		cboOptimizationLevel.AddItem "2"
		cboOptimizationLevel.AddItem "3"
		' cmdAdvancedOptions
		cmdAdvancedOptions.Name = "cmdAdvancedOptions"
		cmdAdvancedOptions.Text = ML("Advanced Options") & " ..."
		cmdAdvancedOptions.SetBounds 210, 46, 184, 24
		cmdAdvancedOptions.OnClick = @cmdAdvancedOptions_Click
		cmdAdvancedOptions.Parent = @picCompileToGCC
		' txtCompilationArguments64Linux
		With txtCompilationArguments64Linux
			.Name = "txtCompilationArguments64Linux"
			.SetBounds 163, 83, 228, 21
			.Parent = @picCompilationArguments
		End With
		' txtCompilationArguments32Linux
		With txtCompilationArguments32Linux
			.Name = "txtCompilationArguments32Linux"
			.SetBounds 163, 56, 228, 21
			.Parent = @picCompilationArguments
		End With
		' txtCompilationArguments64Windows
		With txtCompilationArguments64Windows
			.Name = "txtCompilationArguments64Windows"
			.SetBounds 163, 28, 228, 21
			.Text = "txtCompilationArguments64Windows"
			.Parent = @picCompilationArguments
		End With
		' txtCompilationArguments32Windows
		With txtCompilationArguments32Windows
			.Name = "txtCompilationArguments32Windows"
			.SetBounds 163, 0, 228, 21
			.Text = "txtCompilationArguments32Windows"
			.Parent = @picCompilationArguments
		End With
		' lstType
		With lstType
			.Name = "lstType"
			.Text = "lstType"
			.SetBounds 7, 16, 184, 112
			.OnChange = @lstType_Change
			.Parent = @picVersionInformation
		End With
		' txtValue
		With txtValue
			.Name = "txtValue"
			.SetBounds 207, 16, 192, 112
			.OnLostFocus = @txtValue_LostFocus
			.Parent = @picVersionInformation
		End With
		' txtTitle
		With txtTitle
			.Name = "txtTitle"
			.SetBounds 40, 16, 139, 18
			.Parent = @picApplication
		End With
		' txtIcon
		With txtIcon
			.Name = "txtIcon"
			.SetBounds 40, 40, 72, 18
			.Parent = @picApplication
		End With
		' txtBuild
		With txtBuild
			.Name = "txtBuild"
			.SetBounds 147, 32, 40, 21
			.Parent = @picVersionNumber
		End With
		' txtRevision
		With txtRevision
			.Name = "txtRevision"
			.SetBounds 100, 32, 40, 21
			.Parent = @picVersionNumber
		End With
		' txtMinor
		With txtMinor
			.Name = "txtMinor"
			.SetBounds 53, 32, 40, 21
			.Parent = @picVersionNumber
		End With
		' txtMajor
		With txtMajor
			.Name = "txtMajor"
			.SetBounds 6, 32, 40, 21
			.Parent = @picVersionNumber
		End With
		' Initialization
		lstType.AddItem ML("Company Name")
		lstType.AddItem ML("File Description")
		lstType.AddItem ML("Internal Name")
		lstType.AddItem ML("Legal Copyright")
		lstType.AddItem ML("Legal Trademarks")
		lstType.AddItem ML("Original Filename")
		lstType.AddItem ML("Product Name")
		' pnlVersionNumber
		With picVersionNumber
			.Name = "picVersionNumber"
			.SetBounds 16, 20, 192, 80
			.Parent = @tpMake
		End With
		' picCompileToGCCCaption
		With picCompileToGCCCaption
			.Name = "picCompileToGCCCaption"
			.SetBounds 16, 10, 152, 40
			.Text = ""
			.Parent = @tpCompile
		End With
		' picVersionInformation
		With picApplication
			.Name = "picApplication"
			.SetBounds 232, 20, 192, 80
			.Parent = @tpMake
		End With
		' picVersionInformation
		With picVersionInformation
			.Name = "picVersionInformation"
			.SetBounds 16, 132, 400, 128
			.Parent = @tpMake
		End With
		' picCompilationArguments
		With picCompilationArguments
			.Name = "picCompilationArguments"
			.SetBounds 24, 156, 400, 112
			.Text = ""
			.Parent = @tpCompile
		End With
	End Constructor
	
	#ifndef _NOT_AUTORUN_FORMS_
		fProjectProperties.Show
		
		App.Run
	#endif
'#End Region


Private Sub frmProjectProperties.cmdOK_Click(ByRef Sender As Control)
	With fProjectProperties
		If .ProjectTreeNode = 0 Then Exit Sub
		Dim As ProjectElement Ptr ppe = .ProjectTreeNode->Tag
		If ppe = 0 Then
			ppe = New ProjectElement
			WLet ppe->FileName, ""
		End If
		WLet ppe->MainFileName, .MainFiles.Get(.cboMainFile.Text)
		WLet ppe->ResourceFileName, .ResourceFiles.Get(.cboResourceFile.Text)
		WLet ppe->IconResourceFileName, .IconResourceFiles.Get(.cboIconResourceFile.Text)
		ppe->ProjectType = .cboProjectType.ItemIndex
		WLet ppe->ProjectName, .txtProjectName.Text
		WLet ppe->HelpFileName, .txtHelpFileName.Text
		WLet ppe->ProjectDescription, .txtProjectDescription.Text
		ppe->MajorVersion = Val(.txtMajor.Text)
		ppe->MinorVersion = Val(.txtMinor.Text)
		ppe->RevisionVersion = Val(.txtRevision.Text)
		ppe->BuildVersion = Val(.txtBuild.Text)
		ppe->AutoIncrementVersion = .chkAutoIncrementVersion.Checked
		WLet ppe->ApplicationTitle, .txtTitle.Text
		WLet ppe->ApplicationIcon, .txtIcon.Text
		WLet ppe->CompanyName, .Types.Get(ML("Company Name"))
		WLet ppe->FileDescription, .Types.Get(ML("File Description"))
		WLet ppe->InternalName, .Types.Get(ML("Internal Name"))
		WLet ppe->LegalCopyright, .Types.Get(ML("Legal Copyright"))
		WLet ppe->LegalTrademarks, .Types.Get(ML("Legal Trademarks"))
		WLet ppe->OriginalFilename, .Types.Get(ML("Original Filename"))
		WLet ppe->ProductName, .Types.Get(ML("Product Name"))
		ppe->CompileToGCC = .optCompileToGCC.Checked
		ppe->OptimizationFastCode = .optOptimizationFastCode.Checked
		ppe->OptimizationSmallCode = .optOptimizationSmallCode.Checked
		ppe->OptimizationLevel = IIf(.optOptimizationLevel.Checked, Val(.cboOptimizationLevel.Text), 0)
		WLet ppe->CompilationArguments32Windows, .txtCompilationArguments32Windows.Text
		WLet ppe->CompilationArguments64Windows, .txtCompilationArguments64Windows.Text
		WLet ppe->CompilationArguments32Linux, .txtCompilationArguments32Linux.Text
		WLet ppe->CompilationArguments64Linux, .txtCompilationArguments64Linux.Text
		WLet ppe->CommandLineArguments, .txtCommandLineArguments.Text
		ppe->CreateDebugInfo = .chkCreateDebugInfo.Checked
		If Not EndsWith(.ProjectTreeNode->Text, " *") Then .ProjectTreeNode->Text &= " *"
		.CloseForm
	End With
End Sub

Private Sub frmProjectProperties.cmdCancel_Click(ByRef Sender As Control)
	fProjectProperties.CloseForm
End Sub

Sub AddToCombo(ByRef tn As TreeNode Ptr)
	With fProjectProperties
		Dim As ExplorerElement Ptr ee = tn->Tag
		If EndsWith(LCase(tn->Text), ".rc") OrElse EndsWith(LCase(tn->Text), ".res") Then
			.cboResourceFile.AddItem tn->Text
			.ResourceFiles.Add tn->Text, IIf(ee, *ee->FileName, "")
		ElseIf EndsWith(LCase(tn->Text), ".xpm") Then
			.cboIconResourceFile.AddItem tn->Text
			.IconResourceFiles.Add tn->Text, IIf(ee, *ee->FileName, "")
		Else
			.cboMainFile.AddItem tn->Text
			.MainFiles.Add tn->Text, IIf(ee, *ee->FileName, "")
		End If
	End With
End Sub

Sub AddToComboFileName(ByRef FileName As WString)
	With fProjectProperties
		Dim As UString Text = GetFileName(FileName)
		If EndsWith(LCase(Text), ".rc") OrElse EndsWith(LCase(Text), ".res") Then
			.cboResourceFile.AddItem Text
			.ResourceFiles.Add Text, FileName
		ElseIf EndsWith(LCase(Text), ".xpm") Then
			.cboIconResourceFile.AddItem Text
			.IconResourceFiles.Add Text, FileName
		Else
			.cboMainFile.AddItem Text
			.MainFiles.Add Text, FileName
		End If
	End With
End Sub

Public Sub frmProjectProperties.RefreshProperties()
	With fProjectProperties
		Dim As TreeNode Ptr ptn = ptvExplorer->SelectedNode
		Dim As TreeNode Ptr tn1, tn2
		If ptn = 0 Then Exit Sub
		ptn = GetParentNode(ptn)
		Dim As ExplorerElement Ptr ee = ptn->Tag
		Dim As ProjectElement Ptr ppe
		.cboMainFile.Clear
		.cboResourceFile.Clear
		.cboIconResourceFile.Clear
		.MainFiles.Clear
		.ResourceFiles.Clear
		.IconResourceFiles.Clear
		.cboMainFile.AddItem ML("(not selected)")
		.cboResourceFile.AddItem ML("(not selected)")
		.cboIconResourceFile.AddItem ML("(not selected)")
		Dim As Boolean bSetted = False
		If ptn->ImageKey = "Project" OrElse ee AndAlso *ee Is ProjectElement Then
			.ProjectTreeNode = ptn
			ppe = Cast(ProjectElement Ptr, ee)
			If ptn->ImageKey = "Project" Then
				For i As Integer = 0 To ptn->Nodes.Count - 1
					tn1 = ptn->Nodes.Item(i)
					If tn1->Tag <> 0 Then
						AddToCombo tn1
					ElseIf tn1->Nodes.Count > 0 Then
						For j As Integer = 0 To tn1->Nodes.Count - 1
							tn2 = tn1->Nodes.Item(j)
							AddToCombo tn2
						Next
					End If
				Next
			Else
				For i As Integer = 0 To ppe->Files.Count - 1
					AddToComboFileName ppe->Files.Item(i)
				Next
			End If
			If ppe Then
				bSetted = True
				.cboProjectType.ItemIndex = ppe->ProjectType
				If .MainFiles.IndexOf(*ppe->MainFileName) > -1 Then .cboMainFile.Text = .MainFiles.Item(.MainFiles.IndexOf(*ppe->MainFileName))->Key Else .cboMainFile.ItemIndex = 0
				If .ResourceFiles.IndexOf(*ppe->ResourceFileName) > -1 Then .cboResourceFile.Text = .ResourceFiles.Item(.ResourceFiles.IndexOf(*ppe->ResourceFileName))->Key Else .cboResourceFile.ItemIndex = 0
				If .IconResourceFiles.IndexOf(*ppe->IconResourceFileName) > -1 Then .cboIconResourceFile.Text = .IconResourceFiles.Item(.IconResourceFiles.IndexOf(*ppe->IconResourceFileName))->Key Else .cboIconResourceFile.ItemIndex = 0
				.txtProjectName.Text = *ppe->ProjectName
				.txtHelpFileName.Text = *ppe->HelpFileName
				.txtProjectDescription.Text = *ppe->ProjectDescription
				.txtMajor.Text = WStr(ppe->MajorVersion)
				.txtMinor.Text = WStr(ppe->MinorVersion)
				.txtRevision.Text = WStr(ppe->RevisionVersion)
				.txtBuild.Text = WStr(ppe->BuildVersion)
				.chkAutoIncrementVersion.Checked = ppe->AutoIncrementVersion
				.txtTitle.Text = *ppe->ApplicationTitle
				.txtIcon.Text = *ppe->ApplicationIcon
				.Types.Set ML("Company Name"), *ppe->CompanyName
				.Types.Set ML("File Description"), *ppe->FileDescription
				.Types.Set ML("Internal Name"), *ppe->InternalName
				.Types.Set ML("Legal Copyright"), *ppe->LegalCopyright
				.Types.Set ML("Legal Trademarks"), *ppe->LegalTrademarks
				.Types.Set ML("Original Filename"), *ppe->OriginalFilename
				.Types.Set ML("Product Name"), *ppe->ProductName
				If ppe->CompileToGCC Then
					.optCompileToGCC.Checked = True
					.optCompileToGAS.Checked = False
				Else
					.optCompileToGAS.Checked = True
					.optCompileToGCC.Checked = False
				End If
				.optNoOptimization.Checked = ppe->OptimizationLevel = 0
				.optOptimizationLevel.Checked = ppe->OptimizationLevel > 0
				.cboOptimizationLevel.ItemIndex = ppe->OptimizationLevel
				.optOptimizationSmallCode.Checked = ppe->OptimizationSmallCode
				.optOptimizationFastCode.Checked = ppe->OptimizationFastCode
				.txtCompilationArguments32Windows.Text = *ppe->CompilationArguments32Windows
				.txtCompilationArguments64Windows.Text = *ppe->CompilationArguments64Windows
				.txtCompilationArguments32Linux.Text = *ppe->CompilationArguments32Linux
				.txtCompilationArguments64Linux.Text = *ppe->CompilationArguments64Linux
				.txtCommandLineArguments.Text = *ppe->CommandLineArguments
				.chkCreateDebugInfo.Checked = ppe->CreateDebugInfo
			End If
		Else
			.ProjectTreeNode = ptn
		End If
		If Not bSetted Then
			.cboProjectType.ItemIndex = -1
			.cboMainFile.ItemIndex = -1
			.cboResourceFile.ItemIndex = -1
			.cboIconResourceFile.ItemIndex = -1
			.txtProjectName.Text = ""
			.txtHelpFileName.Text = ""
			.txtProjectDescription.Text = ""
			.txtMajor.Text = ""
			.txtMinor.Text = ""
			.txtRevision.Text = ""
			.txtBuild.Text = ""
			.chkAutoIncrementVersion.Checked = False
			.txtTitle.Text = ""
			.txtIcon.Text = ""
			.txtCompilationArguments32Windows.Text = ""
			.txtCompilationArguments64Windows.Text = ""
			.txtCompilationArguments32Linux.Text = ""
			.txtCompilationArguments64Linux.Text = ""
		End If
	End With
End Sub

Private Sub frmProjectProperties.tpCompile_Click(ByRef Sender As Control)
	
End Sub

Private Sub frmProjectProperties.lstType_Change(ByRef Sender As ListControl)
	With fProjectProperties
		.txtValue.Text = .Types.Get(.lstType.Text)
	End With
End Sub

Private Sub frmProjectProperties.txtValue_LostFocus(ByRef Sender As TextBox)
	With fProjectProperties
		.Types.Set .lstType.Text, .txtValue.Text
	End With
End Sub

Private Sub frmProjectProperties.cmdAdvancedOptions_Click(ByRef Sender As Control)
	pfAdvancedOptions->Show *pfrmMain
End Sub

Private Sub frmProjectProperties.Form_Show(ByRef Sender As Form)
	fProjectProperties.RefreshProperties
End Sub

Private Sub frmProjectProperties.optCompileToGas_Click(ByRef Sender As RadioButton)
	With fProjectProperties
		.grbCompileToGCC.Enabled = .optCompileToGcc.Checked
		.optOptimizationLevel.Enabled = .optCompileToGcc.Checked
		.optOptimizationSmallCode.Enabled = .optCompileToGcc.Checked
		.optNoOptimization.Enabled = .optCompileToGcc.Checked
		.optOptimizationFastCode.Enabled = .optCompileToGcc.Checked
		.cboOptimizationLevel.Enabled = .optCompileToGcc.Checked
	End With
End Sub

Private Sub frmProjectProperties.optCompileToGcc_Click(ByRef Sender As RadioButton)
	With fProjectProperties
		.grbCompileToGCC.Enabled = .optCompileToGcc.Checked
		.optOptimizationLevel.Enabled = .optCompileToGcc.Checked
		.optOptimizationSmallCode.Enabled = .optCompileToGcc.Checked
		.optNoOptimization.Enabled = .optCompileToGcc.Checked
		.optOptimizationFastCode.Enabled = .optCompileToGcc.Checked
		.cboOptimizationLevel.Enabled = .optCompileToGcc.Checked
	End With
End Sub

