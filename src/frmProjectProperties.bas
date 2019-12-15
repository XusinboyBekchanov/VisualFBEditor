'#########################################################
'#  frmProjectProperties.bas                             #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (2018-2019)              #
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
		This.Text = "Project Properties"
		This.BorderStyle = FormBorderStyle.Fixed3D
		This.MaximizeBox = False
		This.MinimizeBox = False
		This.Caption = "Project Properties"
		This.StartPosition = FormStartPosition.CenterScreen
		This.SetBounds 0, 0, 460, 378
		' tabProperties
		tabProperties.Name = "tabProperties"
		tabProperties.Text = "TabControl1"
		tabProperties.SetBounds 6, 6, 443, 307
		tabProperties.Parent = @This
		' tpGeneral
		tpGeneral.Name = "tpGeneral"
		tpGeneral.Text = "General"
		tpGeneral.SetBounds 2, 22, 445, 282
		tpGeneral.UseVisualStyleBackColor = True
		tpGeneral.Parent = @tabProperties
		' tpMake
		tpMake.Name = "tpMake"
		tpMake.Text = "Make"
		tpMake.SetBounds 0, 0, 405, 282
		tpMake.Visible = True
		tpMake.UseVisualStyleBackColor = True
		tpMake.Parent = @tabProperties
		' tpCompile
		tpCompile.Name = "tpCompile"
		tpCompile.Text = "Compile"
		tpCompile.SetBounds 0, 0, 405, 282
		tpCompile.Visible = True
		tpCompile.UseVisualStyleBackColor = True
		tpCompile.OnClick = @tpCompile_Click
		tpCompile.Parent = @tabProperties
		' cmdOK
		cmdOK.Name = "cmdOK"
		cmdOK.Text = "OK"
		cmdOK.SetBounds 218, 319, 73, 24
		cmdOK.Caption = "OK"
		cmdOK.OnClick = @cmdOK_Click
		cmdOK.Parent = @This
		' cmdCancel
		cmdCancel.Name = "cmdCancel"
		cmdCancel.Text = "Cancel"
		cmdCancel.SetBounds 296, 319, 73, 24
		cmdCancel.Caption = "Cancel"
		cmdCancel.OnClick = @cmdCancel_Click
		cmdCancel.Parent = @This
		' cmdHelp
		cmdHelp.Name = "cmdHelp"
		cmdHelp.Text = "Help"
		cmdHelp.SetBounds 374, 319, 73, 24
		cmdHelp.Caption = "Help"
		cmdHelp.Parent = @This
		' lblProjectType
		lblProjectType.Name = "lblProjectType"
		lblProjectType.Text = "Project Type:"
		lblProjectType.SetBounds 10, 8, 72, 18
		lblProjectType.Caption = "Project Type:"
		lblProjectType.Parent = @tpGeneral
		' cboProjectType
		cboProjectType.Name = "cboProjectType"
		cboProjectType.Text = "ComboBoxEdit1"
		cboProjectType.SetBounds 10, 26, 202, 21
		cboProjectType.Parent = @tpGeneral
		' lblMainFile
		lblMainFile.Name = "lblMainFile"
		lblMainFile.Text = "Main File:"
		lblMainFile.SetBounds 224, 8, 72, 18
		lblMainFile.Caption = "Main File:"
		lblMainFile.Parent = @tpGeneral
		' cboMainFile
		cboMainFile.Name = "cboMainFile"
		cboMainFile.Text = "ComboBoxEdit11"
		cboMainFile.Sort = False
		cboMainFile.SetBounds 224, 26, 202, 21
		cboMainFile.Parent = @tpGeneral
		' lblProjectName
		lblProjectName.Name = "lblProjectName"
		lblProjectName.Text = "Project Name:"
		lblProjectName.SetBounds 10, 56, 132, 18
		lblProjectName.Caption = "Project Name:"
		lblProjectName.Parent = @tpGeneral
		' txtProjectName
		txtProjectName.Name = "txtProjectName"
		txtProjectName.Text = ""
		txtProjectName.SetBounds 10, 74, 202, 21
		txtProjectName.Parent = @tpGeneral
		' lblProjectDescription
		lblProjectDescription.Name = "lblProjectDescription"
		lblProjectDescription.Text = "Project Description:"
		lblProjectDescription.SetBounds 10, 152, 132, 18
		lblProjectDescription.Caption = "Project Description:"
		lblProjectDescription.Parent = @tpGeneral
		' txtProjectDescription
		txtProjectDescription.Name = "txtProjectDescription"
		txtProjectDescription.Text = ""
		txtProjectDescription.SetBounds 10, 170, 416, 21
		txtProjectDescription.Parent = @tpGeneral
		' grbVersionNumber
		grbVersionNumber.Name = "grbVersionNumber"
		grbVersionNumber.Text = "Version Number"
		grbVersionNumber.SetBounds 10, 8, 202, 102
		grbVersionNumber.Parent = @tpMake
		' grbApplication
		grbApplication.Name = "grbApplication"
		grbApplication.Text = "Application"
		grbApplication.SetBounds 224, 8, 202, 102
		grbApplication.Parent = @tpMake
		' grbVersionInformation
		grbVersionInformation.Name = "grbVersionInformation"
		grbVersionInformation.Text = "Version Information"
		grbVersionInformation.SetBounds 9, 113, 419, 161
		grbVersionInformation.Parent = @tpMake
		' grbCompilationArguments
		grbCompilationArguments.Name = "grbCompilationArguments"
		grbCompilationArguments.Text = "Compilation Arguments"
		grbCompilationArguments.SetBounds 10, 138, 419, 136
		grbCompilationArguments.Parent = @tpCompile
		' lblCompilationArguments64
		lblCompilationArguments64.Name = "lblCompilationArguments64"
		lblCompilationArguments64.Text = "For Windows, 64-bit:"
		lblCompilationArguments64.SetBounds 29, 188, 120, 18
		lblCompilationArguments64.Caption = "For Windows, 64-bit:"
		lblCompilationArguments64.Parent = @tpCompile
		' lblIcon
		lblIcon.Name = "lblIcon"
		lblIcon.Text = "Icon:"
		lblIcon.SetBounds 238, 57, 34, 18
		lblIcon.Caption = "Icon:"
		lblIcon.Parent = @tpMake
		' lblTitle
		lblTitle.Name = "lblTitle"
		lblTitle.Text = "Title:"
		lblTitle.SetBounds 238, 33, 34, 18
		lblTitle.Caption = "Title:"
		lblTitle.Parent = @tpMake
		' chkAutoIncrementVersion
		chkAutoIncrementVersion.Name = "chkAutoIncrementVersion"
		chkAutoIncrementVersion.Text = "Auto Increment Version"
		chkAutoIncrementVersion.SetBounds 21, 77, 156, 18
		chkAutoIncrementVersion.Caption = "Auto Increment Version"
		chkAutoIncrementVersion.Parent = @tpMake
		' lblMajor
		lblMajor.Name = "lblMajor"
		lblMajor.Text = "Major:"
		lblMajor.SetBounds 23, 28, 42, 18
		lblMajor.Caption = "Major:"
		lblMajor.Parent = @tpMake
		' lblMinor
		lblMinor.Name = "lblMinor"
		lblMinor.Text = "Minor:"
		lblMinor.SetBounds 71, 28, 42, 18
		lblMinor.Caption = "Minor:"
		lblMinor.Parent = @tpMake
		' lblRevision
		lblRevision.Name = "lblRevision"
		lblRevision.Text = "Revision:"
		lblRevision.SetBounds 117, 28, 48, 18
		lblRevision.Caption = "Revision:"
		lblRevision.BorderStyle = BorderStyles.bsNone
		lblRevision.Parent = @tpMake
		' lblBuild
		lblBuild.Name = "lblBuild"
		lblBuild.Text = "Build:"
		lblBuild.SetBounds 174, 28, 36, 18
		lblBuild.Caption = "Build:"
		lblBuild.Parent = @tpMake
		' cboResourceFile
		cboResourceFile.Name = "cboResourceFile"
		cboResourceFile.Text = "cboMainFile1"
		cboResourceFile.Sort = False
		cboResourceFile.SetBounds 224, 74, 202, 21
		cboResourceFile.Parent = @tpGeneral
		' lblResourceFile
		lblResourceFile.Name = "lblResourceFile"
		lblResourceFile.Text = "Resource File (for Windows):"
		lblResourceFile.SetBounds 224, 56, 184, 18
		lblResourceFile.Caption = "Resource File (for Windows):"
		lblResourceFile.Parent = @tpGeneral
		' lblIconResourceFile
		lblIconResourceFile.Name = "lblIconResourceFile"
		lblIconResourceFile.Text = "Icon Resource File (for *nix/*bsd):"
		lblIconResourceFile.SetBounds 224, 104, 184, 18
		lblIconResourceFile.Caption = "Icon Resource File (for *nix/*bsd):"
		lblIconResourceFile.Parent = @tpGeneral
		' cboIconResourceFile
		cboIconResourceFile.Name = "cboIconResourceFile"
		cboIconResourceFile.Text = "cboResourceFile1"
		cboIconResourceFile.Sort = False
		cboIconResourceFile.SetBounds 224, 122, 202, 21
		cboIconResourceFile.Parent = @tpGeneral
		' lblCompilationArguments32Linux
		lblCompilationArguments32Linux.Name = "lblCompilationArguments32Linux"
		lblCompilationArguments32Linux.Text = "For *nix/*bsd, 32-bit:"
		lblCompilationArguments32Linux.SetBounds 29, 214, 120, 18
		lblCompilationArguments32Linux.Caption = "For *nix/*bsd, 32-bit:"
		lblCompilationArguments32Linux.Parent = @tpCompile
		' lblCompilationArguments64Linux
		lblCompilationArguments64Linux.Name = "lblCompilationArguments64Linux"
		lblCompilationArguments64Linux.Text = "For *nix/*bsd, 64-bit:"
		lblCompilationArguments64Linux.SetBounds 29, 242, 120, 18
		lblCompilationArguments64Linux.Caption = "For *nix/*bsd, 64-bit:"
		lblCompilationArguments64Linux.Parent = @tpCompile
		' lblCompilationArguments32
		lblCompilationArguments32.Name = "lblCompilationArguments32"
		lblCompilationArguments32.Text = "For Windows, 32-bit:"
		lblCompilationArguments32.Caption = "For Windows, 32-bit:"
		lblCompilationArguments32.SetBounds 29, 161, 124, 18
		lblCompilationArguments32.Parent = @tpCompile
		' lblType
		lblType.Name = "lblType"
		lblType.Text = "Type:"
		lblType.SetBounds 23, 129, 42, 18
		lblType.Caption = "Type:"
		lblType.Parent = @tpMake
		' lblValue
		lblValue.Name = "lblValue"
		lblValue.Text = "Value:"
		lblValue.SetBounds 223, 129, 42, 18
		lblValue.Caption = "Value:"
		lblValue.Parent = @tpMake
		' txtHelpFileName
		txtHelpFileName.Name = "txtHelpFileName"
		txtHelpFileName.SetBounds 10, 122, 202, 21
		txtHelpFileName.Text = ""
		txtHelpFileName.Parent = @tpGeneral
		' lblHelpFileName
		lblHelpFileName.Name = "lblHelpFileName"
		lblHelpFileName.Text = "Help File Name:"
		lblHelpFileName.SetBounds 10, 104, 132, 18
		lblHelpFileName.Caption = "Help File Name:"
		lblHelpFileName.Parent = @tpGeneral
		' grbCompileToGCC
		grbCompileToGCC.Name = "grbCompileToGCC"
		grbCompileToGCC.Text = ""
		grbCompileToGCC.SetBounds 10, 35, 419, 101
		grbCompileToGCC.Parent = @tpCompile
		' optCompileToGas
		optCompileToGas.Name = "optCompileToGas"
		optCompileToGas.Text = "Compile to GAS"
		optCompileToGas.SetBounds 16, 12, 160, 16
		optCompileToGas.Caption = "Compile to GAS"
		optCompileToGas.Parent = @tpCompile
		' optCompileToGcc
		optCompileToGcc.Name = "optCompileToGcc"
		optCompileToGcc.Text = "Compile to GCC"
		optCompileToGcc.SetBounds 16, 34, 96, 16
		optCompileToGcc.Caption = "Compile to GCC"
		optCompileToGcc.Parent = @tpCompile
		' tpDebugging
		tpDebugging.Name = "tpDebugging"
		tpDebugging.SetBounds 2, 22, 445, 282
		tpDebugging.UseVisualStyleBackColor = True
		tpDebugging.Visible = True
		tpDebugging.Text = "Debugging"
		tpDebugging.Parent = @tabProperties
		' lblCompilationArguments321
		lblCompilationArguments321.Name = "lblCompilationArguments321"
		lblCompilationArguments321.Text = "Command Line Arguments:"
		lblCompilationArguments321.SetBounds 21, 16, 172, 18
		lblCompilationArguments321.Caption = "Command Line Arguments:"
		lblCompilationArguments321.Parent = @tpDebugging
		' txtCommandLineArguments
		txtCommandLineArguments.Name = "txtCommandLineArguments"
		txtCommandLineArguments.SetBounds 211, 14, 216, 21
		txtCommandLineArguments.Text = ""
		txtCommandLineArguments.Parent = @tpDebugging
		' picCompileToGCC
		picCompileToGCC.Name = "picCompileToGCC"
		picCompileToGCC.SetBounds 22, 51, 402, 80
		picCompileToGCC.Parent = @tpCompile
		' optOptimizationFastCode
		optOptimizationFastCode.Name = "optOptimizationFastCode"
		optOptimizationFastCode.Text = "Optimize for Fast Code"
		optOptimizationFastCode.SetBounds 10, 3, 136, 24
		optOptimizationFastCode.Caption = "Optimize for Fast Code"
		optOptimizationFastCode.Parent = @picCompileToGCC
		' optOptimizationLevel
		optOptimizationLevel.Name = "optOptimizationLevel"
		optOptimizationLevel.Text = "Optimization level:"
		optOptimizationLevel.SetBounds 210, 9, 120, 16
		optOptimizationLevel.Caption = "Optimization level:"
		optOptimizationLevel.Parent = @picCompileToGCC
		' optOptimizationSmallCode
		optOptimizationSmallCode.Name = "optOptimizationSmallCode"
		optOptimizationSmallCode.Text = "Optimize for Small Code"
		optOptimizationSmallCode.SetBounds 10, 29, 136, 16
		optOptimizationSmallCode.Caption = "Optimize for Small Code"
		optOptimizationSmallCode.Parent = @picCompileToGCC
		' optNoOptimization
		optNoOptimization.Name = "optNoOptimization"
		optNoOptimization.Text = "No Optimization"
		optNoOptimization.SetBounds 10, 52, 128, 16
		optNoOptimization.Caption = "No Optimization"
		optNoOptimization.Parent = @picCompileToGCC
		' chkCreateDebugInfo
		chkCreateDebugInfo.Name = "chkCreateDebugInfo"
		chkCreateDebugInfo.Text = "Create Symbolic Debug Info"
		chkCreateDebugInfo.SetBounds 211, 35, 208, 32
		chkCreateDebugInfo.Caption = "Create Symbolic Debug Info"
		chkCreateDebugInfo.Parent = @tpDebugging
		' Initialization
		cboProjectType.AddItem "Executable"
		cboProjectType.AddItem "Dynamic library"
		cboProjectType.AddItem "Static library"
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
		cmdAdvancedOptions.Text = "Advanced Options ..."
		cmdAdvancedOptions.SetBounds 210, 46, 184, 24
		cmdAdvancedOptions.Caption = "Advanced Options ..."
		cmdAdvancedOptions.OnClick = @cmdAdvancedOptions_Click
		cmdAdvancedOptions.Parent = @picCompileToGCC
		' txtCompilationArguments64Linux
		With txtCompilationArguments64Linux
			.Name = "txtCompilationArguments64Linux"
			.SetBounds 187, 238, 228, 21
			.Parent = @tpCompile
		End With
		' txtCompilationArguments32Linux
		With txtCompilationArguments32Linux
			.Name = "txtCompilationArguments32Linux"
			.SetBounds 187, 211, 228, 21
			.Parent = @tpCompile
		End With
		' txtCompilationArguments64Windows
		With txtCompilationArguments64Windows
			.Name = "txtCompilationArguments64Windows"
			.SetBounds 187, 184, 228, 21
			.Parent = @tpCompile
		End With
		' txtCompilationArguments32Windows
		With txtCompilationArguments32Windows
			.Name = "txtCompilationArguments32Windows"
			.SetBounds 187, 157, 228, 21
			.Parent = @tpCompile
		End With
		' lstType
		With lstType
			.Name = "lstType"
			.Text = "lstType"
			.SetBounds 23, 147, 184, 112
			.OnChange = @lstType_Change
			.Parent = @tpMake
		End With
		' txtValue
		With txtValue
			.Name = "txtValue"
			.SetBounds 223, 147, 192, 112
			.OnLostFocus = @txtValue_LostFocus
			.Parent = @tpMake
		End With
		' txtTitle
		With txtTitle
			.Name = "txtTitle"
			.SetBounds 274, 32, 139, 18
			.Parent = @tpMake
		End With
		' txtIcon
		With txtIcon
			.Name = "txtIcon"
			.SetBounds 274, 56, 72, 18
			.Parent = @tpMake
		End With
		' txtBuild
		With txtBuild
			.Name = "txtBuild"
			.SetBounds 163, 48, 40, 21
			.Parent = @tpMake
		End With
		' txtRevision
		With txtRevision
			.Name = "txtRevision"
			.SetBounds 116, 48, 40, 21
			.Parent = @tpMake
		End With
		' txtMinor
		With txtMinor
			.Name = "txtMinor"
			.SetBounds 69, 48, 40, 21
			.Parent = @tpMake
		End With
		' txtMajor
		With txtMajor
			.Name = "txtMajor"
			.SetBounds 22, 48, 40, 21
			.Parent = @tpMake
		End With
		' Initialization
		lstType.AddItem "Company Name"
        lstType.AddItem "File Description"
        lstType.AddItem "Internal Name"
        lstType.AddItem "Legal Copyright"
        lstType.AddItem "Legal Trademarks"
        lstType.AddItem "Original Filename"
        lstType.AddItem "Product Name"
	End Constructor
	
	#ifndef _NOT_AUTORUN_FORMS_
		fProjectProperties.Show
		
		App.Run
	#endif
'#End Region


Private Sub frmProjectProperties.cmdOK_Click(ByRef Sender As Control)
	With fProjectProperties
		If .ProjectTreeNode = 0 Then Exit Sub
		Dim As ExplorerElement Ptr pee = .ProjectTreeNode->Tag
		If pee = 0 Then
			pee = New ExplorerElement
			WLet pee->FileName, ""
		End If
		Dim As ProjectElement Ptr ppe = pee->Project
		If ppe = 0 Then
			ppe = New ProjectElement
			pee->Project = ppe
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
		WLet ppe->CompanyName, .Types.Get("Company Name")
		WLet ppe->FileDescription, .Types.Get("File Description")
		WLet ppe->InternalName, .Types.Get("Internal Name")
		WLet ppe->LegalCopyright, .Types.Get("Legal Copyright")
		WLet ppe->LegalTrademarks, .Types.Get("Legal Trademarks")
		WLet ppe->OriginalFilename, .Types.Get("Original Filename")
		WLet ppe->ProductName, .Types.Get("Product Name")
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
		If EndsWith(tn->Text, ".rc") OrElse EndsWith(tn->Text, ".res") Then
			.cboResourceFile.AddItem tn->Text
			.ResourceFiles.Add tn->Text, IIf(ee, *ee->FileName, "")
		ElseIf EndsWith(tn->Text, ".xpm") Then
			.cboIconResourceFile.AddItem tn->Text
			.IconResourceFiles.Add tn->Text, IIf(ee, *ee->FileName, "")
		Else
			.cboMainFile.AddItem tn->Text
			.MainFiles.Add tn->Text, IIf(ee, *ee->FileName, "")
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
		If ptn->ImageKey = "Project" Then
			.ProjectTreeNode = ptn
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
			If ee AndAlso ee->Project Then
				ppe = ee->Project
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
				.Types.Set "Company Name", *ppe->CompanyName
				.Types.Set "File Description", *ppe->FileDescription
				.Types.Set "Internal Name", *ppe->InternalName
				.Types.Set "Legal Copyright", *ppe->LegalCopyright
				.Types.Set "Legal Trademarks", *ppe->LegalTrademarks
				.Types.Set "Original Filename", *ppe->OriginalFilename
				.Types.Set "Product Name", *ppe->ProductName
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
