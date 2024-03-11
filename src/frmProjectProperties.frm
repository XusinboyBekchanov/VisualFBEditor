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
#include once "frmImageManager.bi"
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
		This.OnShow       = @Form_Show
		This.DefaultButton = @cmdOK
		This.CancelButton = @cmdCancel
		This.SetBounds 0, 0, 510, 458
		This.StartPosition = FormStartPosition.CenterParent
		#ifdef __USE_GTK__
			This.Icon.LoadFromFile(ExePath & "/Resources/VisualFBEditor.ico")
		#else
			This.Icon.LoadFromResourceID(1)
		#endif
		This.Designer = @This
		This.OnCreate = @_Form_Create
		' tpGeneral
		tpGeneral.Name = "tpGeneral"
		tpGeneral.Text = ML("General")
		tpGeneral.TabIndex = 1
		tpGeneral.SetBounds 2, 22, 487, 356
		tpGeneral.UseVisualStyleBackColor = True
		tpGeneral.Parent = @tabProperties
		' tpMake
		tpMake.Name = "tpMake"
		tpMake.Text = ML("Make")
		tpMake.TabIndex = 19
		tpMake.SetBounds 2, 22, 487, 316
		tpMake.Visible = True
		tpMake.UseVisualStyleBackColor = True
		tpMake.Parent = @tabProperties
		' tpCompile
		tpCompile.Name = "tpCompile"
		tpCompile.Text = ML("Compile")
		tpCompile.TabIndex = 44
		tpCompile.SetBounds 2, 22, 487, 346
		tpCompile.Visible = True
		tpCompile.UseVisualStyleBackColor = True
		tpCompile.OnClick = @tpCompile_Click
		tpCompile.Parent = @tabProperties
		' cmdOK
		cmdOK.Name = "cmdOK"
		cmdOK.Text = ML("OK")
		cmdOK.TabIndex = 84
		cmdOK.SetBounds 161, 389, 106, 34
		cmdOK.OnClick = @cmdOK_Click
		cmdOK.Default = True
		cmdOK.Parent = @This
		' cmdCancel
		cmdCancel.Name = "cmdCancel"
		cmdCancel.Text = ML("Cancel")
		cmdCancel.TabIndex = 85
		cmdCancel.SetBounds 269, 389, 120, 34
		cmdCancel.OnClick = @cmdCancel_Click
		cmdCancel.Parent = @This
		' cmdHelp
		cmdHelp.Name = "cmdHelp"
		cmdHelp.Text = ML("Help")
		cmdHelp.TabIndex = 86
		cmdHelp.SetBounds 391, 389, 106, 34
		cmdHelp.Parent = @This
		' tabProperties
		tabProperties.Name = "tabProperties"
		tabProperties.Text = "TabControl1"
		tabProperties.TabIndex = 0
		tabProperties.SetBounds 6, 6, 493, 381
		tabProperties.Parent = @This
		' lblProjectType
		lblProjectType.Name = "lblProjectType"
		lblProjectType.Text = ML("Project Type") & ":"
		lblProjectType.TabIndex = 2
		lblProjectType.SetBounds 10, 8, 144, 18
		lblProjectType.Parent = @tpGeneral
		' cboProjectType
		cboProjectType.Name = "cboProjectType"
		cboProjectType.Text = "ComboBoxEdit1"
		cboProjectType.TabIndex = 3
		cboProjectType.SetBounds 10, 26, 202, 21
		cboProjectType.Parent = @tpGeneral
		' lblMainFile
		lblMainFile.Name = "lblMainFile"
		lblMainFile.Text = ML("Main File") & ":"
		lblMainFile.TabIndex = 4
		lblMainFile.SetBounds 224, 8, 252, 18
		lblMainFile.Parent = @tpGeneral
		' cboMainFile
		cboMainFile.Name = "cboMainFile"
		cboMainFile.Text = "ComboBoxEdit11"
		cboMainFile.Sort = False
		cboMainFile.TabIndex = 5
		cboMainFile.SetBounds 224, 26, 252, 21
		cboMainFile.Parent = @tpGeneral
		' lblProjectName
		lblProjectName.Name = "lblProjectName"
		lblProjectName.Text = ML("Project Name") & ":"
		lblProjectName.TabIndex = 10
		lblProjectName.SetBounds 10, 182, 204, 18
		lblProjectName.Parent = @tpGeneral
		' txtProjectName
		txtProjectName.Name = "txtProjectName"
		txtProjectName.Text = ""
		txtProjectName.TabIndex = 11
		txtProjectName.SetBounds 10, 200, 202, 21
		txtProjectName.Parent = @tpGeneral
		' lblProjectDescription
		lblProjectDescription.Name = "lblProjectDescription"
		lblProjectDescription.Text = ML("Project Description") & ":"
		lblProjectDescription.TabIndex = 17
		lblProjectDescription.SetBounds 10, 298, 220, 18
		lblProjectDescription.Parent = @tpGeneral
		' txtProjectDescription
		txtProjectDescription.Name = "txtProjectDescription"
		txtProjectDescription.Text = ""
		txtProjectDescription.TabIndex = 18
		txtProjectDescription.SetBounds 10, 316, 466, 24
		txtProjectDescription.Parent = @tpGeneral
		' grbVersionNumber
		grbVersionNumber.Name = "grbVersionNumber"
		grbVersionNumber.Text = ML("Version Number")
		grbVersionNumber.TabIndex = 20
		grbVersionNumber.SetBounds 10, 8, 228, 122
		grbVersionNumber.Parent = @tpMake
		' grbApplication
		grbApplication.Name = "grbApplication"
		grbApplication.Text = ML("Application")
		grbApplication.TabIndex = 30
		grbApplication.SetBounds 253, 8, 225, 122
		grbApplication.Parent = @tpMake
		' grbVersionInformation
		grbVersionInformation.Name = "grbVersionInformation"
		grbVersionInformation.Text = ML("Version Information")
		grbVersionInformation.TabIndex = 38
		grbVersionInformation.SetBounds 9, 136, 469, 211
		grbVersionInformation.Parent = @tpMake
		' grbCompilationArguments
		grbCompilationArguments.Name = "grbCompilationArguments"
		grbCompilationArguments.Text = ML("Compilation Arguments")
		grbCompilationArguments.TabIndex = 56
		grbCompilationArguments.SetBounds 10, 138, 469, 138
		grbCompilationArguments.Parent = @tpCompile
		' lblCompilationArguments64
		lblCompilationArguments64.Name = "lblCompilationArguments64"
		lblCompilationArguments64.Text = ML("For Windows") & ", " & ML("64-bit") & ":"
		lblCompilationArguments64.TabIndex = 60
		lblCompilationArguments64.SetBounds 5, 30, 202, 18
		lblCompilationArguments64.Parent = @picCompilationArguments
		' lblIcon
		lblIcon.Name = "lblIcon"
		lblIcon.Text = ML("Icon") & ":"
		lblIcon.TabIndex = 33
		lblIcon.SetBounds 0, 37, 34, 18
		lblIcon.Parent = @picApplication
		' lblTitle
		lblTitle.Name = "lblTitle"
		lblTitle.Text = ML("Title") & ":"
		lblTitle.TabIndex = 31
		lblTitle.SetBounds 0, 11, 34, 18
		lblTitle.Parent = @picApplication
		' chkAutoIncrementVersion
		chkAutoIncrementVersion.Name = "chkAutoIncrementVersion"
		chkAutoIncrementVersion.Text = ML("Auto Increment Version")
		chkAutoIncrementVersion.TabIndex = 29
		chkAutoIncrementVersion.SetBounds 6, 70, 204, 18
		chkAutoIncrementVersion.Parent = @picVersionNumber
		' lblMajor
		lblMajor.Name = "lblMajor"
		lblMajor.Text = ML("Major") & ":"
		lblMajor.TabIndex = 21
		lblMajor.SetBounds 5, 12, 52, 18
		lblMajor.Parent = @picVersionNumber
		' lblMinor
		lblMinor.Name = "lblMinor"
		lblMinor.Text = ML("Minor") & ":"
		lblMinor.TabIndex = 23
		lblMinor.SetBounds 58, 12, 52, 18
		lblMinor.Parent = @picVersionNumber
		' lblRevision
		lblRevision.Name = "lblRevision"
		lblRevision.Text = ML("Revision") & ":"
		lblRevision.TabIndex = 25
		lblRevision.SetBounds 109, 12, 48, 18
		lblRevision.BorderStyle = BorderStyles.bsNone
		lblRevision.Parent = @picVersionNumber
		' lblBuild
		lblBuild.Name = "lblBuild"
		lblBuild.Text = ML("Build") & ":"
		lblBuild.TabIndex = 27
		lblBuild.SetBounds 171, 12, 36, 18
		lblBuild.Parent = @picVersionNumber
		' cboResourceFile
		cboResourceFile.Name = "cboResourceFile"
		cboResourceFile.Text = "cboMainFile1"
		cboResourceFile.Sort = False
		cboResourceFile.TabIndex = 9
		cboResourceFile.SetBounds 224, 84, 252, 21
		cboResourceFile.Parent = @tpGeneral
		' lblResourceFile
		lblResourceFile.Name = "lblResourceFile"
		lblResourceFile.Text = ML("Resource File") & " (" & ML("For Windows") & "):"
		lblResourceFile.TabIndex = 8
		lblResourceFile.SetBounds 224, 66, 262, 18
		lblResourceFile.Parent = @tpGeneral
		' lblIconResourceFile
		lblIconResourceFile.Name = "lblIconResourceFile"
		lblIconResourceFile.Text = ML("Icon Resource File") & " (" & ML("For *nix/*bsd") & "):"
		lblIconResourceFile.TabIndex = 12
		lblIconResourceFile.SetBounds 224, 124, 262, 18
		lblIconResourceFile.Parent = @tpGeneral
		' cboIconResourceFile
		cboIconResourceFile.Name = "cboIconResourceFile"
		cboIconResourceFile.Text = "cboResourceFile1"
		cboIconResourceFile.Sort = False
		cboIconResourceFile.TabIndex = 13
		cboIconResourceFile.SetBounds 224, 142, 252, 21
		cboIconResourceFile.Parent = @tpGeneral
		' lblCompilationArguments32Linux
		lblCompilationArguments32Linux.Name = "lblCompilationArguments32Linux"
		lblCompilationArguments32Linux.Text = ML("For *nix/*bsd") & ", " & ML("32-bit") & ":"
		lblCompilationArguments32Linux.TabIndex = 62
		lblCompilationArguments32Linux.SetBounds 5, 57, 202, 18
		lblCompilationArguments32Linux.Parent = @picCompilationArguments
		' lblCompilationArguments64Linux
		lblCompilationArguments64Linux.Name = "lblCompilationArguments64Linux"
		lblCompilationArguments64Linux.Text = ML("For *nix/*bsd") & ", " & ML("64-bit") & ":"
		lblCompilationArguments64Linux.TabIndex = 64
		lblCompilationArguments64Linux.SetBounds 5, 85, 212, 18
		lblCompilationArguments64Linux.Parent = @picCompilationArguments
		' lblCompilationArguments32
		lblCompilationArguments32.Name = "lblCompilationArguments32"
		lblCompilationArguments32.Text = ML("For Windows") & ", " & ML("32-bit") & ":"
		lblCompilationArguments32.TabIndex = 58
		lblCompilationArguments32.SetBounds 5, 4, 192, 18
		lblCompilationArguments32.Parent = @picCompilationArguments
		' lblType
		lblType.Name = "lblType"
		lblType.Text = ML("Type") & ":"
		lblType.TabIndex = 40
		lblType.SetBounds 7, 0, 82, 18
		lblType.Parent = @picVersionInformation
		' lblValue
		lblValue.Name = "lblValue"
		lblValue.Text = ML("Value") & ":"
		lblValue.TabIndex = 42
		lblValue.SetBounds 237, 0, 136, 18
		lblValue.Parent = @picVersionInformation
		' txtHelpFileName
		txtHelpFileName.Name = "txtHelpFileName"
		txtHelpFileName.TabIndex = 15
		txtHelpFileName.SetBounds 10, 258, 202, 21
		txtHelpFileName.Text = ""
		txtHelpFileName.Parent = @tpGeneral
		' lblHelpFileName
		lblHelpFileName.Name = "lblHelpFileName"
		lblHelpFileName.Text = ML("Help File") & ":"
		lblHelpFileName.TabIndex = 14
		lblHelpFileName.SetBounds 10, 240, 172, 18
		lblHelpFileName.Parent = @tpGeneral
		' grbCompileToGCC
		grbCompileToGCC.Name = "grbCompileToGCC"
		grbCompileToGCC.Text = ""
		grbCompileToGCC.Enabled = False
		grbCompileToGCC.TabIndex = 87
		grbCompileToGCC.SetBounds 10, 35, 469, 101
		grbCompileToGCC.Parent = @tpCompile
		' optCompileToGas
		optCompileToGas.Name = "optCompileToGas"
		optCompileToGas.Text = ML("Compile to GAS")
		optCompileToGas.TabIndex = 46
		optCompileToGas.SetBounds 180, 15, 140, 16
		optCompileToGas.OnClick = @optCompileToGas_Click
		optCompileToGas.Parent = @tpCompile
		' optCompileToGcc
		optCompileToGcc.Name = "optCompileToGcc"
		optCompileToGcc.Text = ML("Compile to GCC")
		optCompileToGcc.TabIndex = 48
		optCompileToGcc.SetBounds 16, 34, 132, 16
		optCompileToGcc.OnClick = @optCompileToGcc_Click
		optCompileToGcc.Parent = @tpCompile
		' tpIncludes
		With tpIncludes
			.Name = "tpIncludes"
			.Text = ML("Includes")
			.TabIndex = 95
			.Caption = ML("Includes")
			.UseVisualStyleBackColor = True
			.SetBounds 65182, 22, 487, 356
			.Designer = @This
			.Parent = @tabProperties
		End With
		' tpDebugging
		tpDebugging.Name = "tpDebugging"
		tpDebugging.TabIndex = 70
		tpDebugging.SetBounds 2, 22, 487, 316
		tpDebugging.UseVisualStyleBackColor = True
		tpDebugging.Visible = True
		tpDebugging.Text = ML("Debugging")
		tpDebugging.Designer = @This
		tpDebugging.OnClick = @tpDebugging_Click_
		tpDebugging.Parent = @tabProperties
		' lblCompilationArguments321
		lblCompilationArguments321.Name = "lblCompilationArguments321"
		lblCompilationArguments321.Text = ML("Command Line Arguments") & ":"
		lblCompilationArguments321.TabIndex = 71
		lblCompilationArguments321.SetBounds 21, 16, 172, 18
		lblCompilationArguments321.Parent = @tpDebugging
		' txtCommandLineArguments
		txtCommandLineArguments.Name = "txtCommandLineArguments"
		txtCommandLineArguments.TabIndex = 72
		txtCommandLineArguments.SetBounds 211, 14, 262, 21
		txtCommandLineArguments.Text = ""
		txtCommandLineArguments.Parent = @tpDebugging
		' picCompileToGCC
		picCompileToGCC.Name = "picCompileToGCC"
		picCompileToGCC.TabIndex = 49
		picCompileToGCC.SetBounds 22, 51, 445, 80
		picCompileToGCC.Text = ""
		picCompileToGCC.Parent = @tpCompile
		' optOptimizationFastCode
		optOptimizationFastCode.Name = "optOptimizationFastCode"
		optOptimizationFastCode.Text = ML("Optimize for Fast Code")
		optOptimizationFastCode.TabIndex = 50
		optOptimizationFastCode.SetBounds 10, 3, 184, 24
		optOptimizationFastCode.Parent = @picCompileToGCC
		' optOptimizationLevel
		optOptimizationLevel.Name = "optOptimizationLevel"
		optOptimizationLevel.Text = ML("Optimization level") & ":"
		optOptimizationLevel.TabIndex = 51
		optOptimizationLevel.SetBounds 220, 9, 160, 16
		optOptimizationLevel.Parent = @picCompileToGCC
		' optOptimizationSmallCode
		optOptimizationSmallCode.Name = "optOptimizationSmallCode"
		optOptimizationSmallCode.Text = ML("Optimize for Small Code")
		optOptimizationSmallCode.TabIndex = 53
		optOptimizationSmallCode.SetBounds 10, 29, 184, 16
		optOptimizationSmallCode.Parent = @picCompileToGCC
		' optNoOptimization
		optNoOptimization.Name = "optNoOptimization"
		optNoOptimization.Text = ML("No Optimization")
		optNoOptimization.TabIndex = 54
		optNoOptimization.SetBounds 10, 52, 192, 16
		optNoOptimization.Parent = @picCompileToGCC
		' chkCreateDebugInfo
		chkCreateDebugInfo.Name = "chkCreateDebugInfo"
		chkCreateDebugInfo.Text = ML("Create Symbolic Debug Info")
		chkCreateDebugInfo.TabIndex = 73
		chkCreateDebugInfo.SetBounds 211, 45, 254, 32
		chkCreateDebugInfo.Parent = @tpDebugging
		' Initialization
		cboProjectType.AddItem ML("Executable")
		cboProjectType.AddItem ML("Dynamic library")
		cboProjectType.AddItem ML("Static library")
		cboSubsystem.AddItem ML("(not selected)")
		cboSubsystem.AddItem ML("Console")
		cboSubsystem.AddItem ML("GUI")
		' cboOptimizationLevel
		cboOptimizationLevel.Name = "cboOptimizationLevel"
		cboOptimizationLevel.Text = "ComboBoxEdit1"
		cboOptimizationLevel.TabIndex = 52
		cboOptimizationLevel.SetBounds 386, 6, 56, 21
		cboOptimizationLevel.Parent = @picCompileToGCC
		cboOptimizationLevel.AddItem "0"
		cboOptimizationLevel.AddItem "1"
		cboOptimizationLevel.AddItem "2"
		cboOptimizationLevel.Designer = @This
		cboOptimizationLevel.OnSelected = @_cboOptimizationLevel_Selected
		cboOptimizationLevel.AddItem "3"
		' cmdAdvancedOptions
		cmdAdvancedOptions.Name = "cmdAdvancedOptions"
		cmdAdvancedOptions.Text = ML("Advanced Options") & " ..."
		cmdAdvancedOptions.TabIndex = 55
		cmdAdvancedOptions.SetBounds 220, 46, 224, 24
		cmdAdvancedOptions.OnClick = @cmdAdvancedOptions_Click
		cmdAdvancedOptions.Parent = @picCompileToGCC
		' txtCompilationArguments64Linux
		With txtCompilationArguments64Linux
			.Name = "txtCompilationArguments64Linux"
			.TabIndex = 65
			.SetBounds 213, 83, 228, 21
			.Parent = @picCompilationArguments
		End With
		' txtCompilationArguments32Linux
		With txtCompilationArguments32Linux
			.Name = "txtCompilationArguments32Linux"
			.TabIndex = 63
			.SetBounds 213, 56, 228, 21
			.Parent = @picCompilationArguments
		End With
		' txtCompilationArguments64Windows
		With txtCompilationArguments64Windows
			.Name = "txtCompilationArguments64Windows"
			.TabIndex = 61
			.SetBounds 213, 28, 228, 21
			.Parent = @picCompilationArguments
		End With
		' txtCompilationArguments32Windows
		With txtCompilationArguments32Windows
			.Name = "txtCompilationArguments32Windows"
			.TabIndex = 59
			.SetBounds 213, 0, 228, 21
			.Parent = @picCompilationArguments
		End With
		' lstType
		With lstType
			.Name = "lstType"
			.Text = "lstType"
		lstType.TabIndex = 41
			.SetBounds 7, 16, 214, 167
			.OnChange = @lstType_Change
			.Parent = @picVersionInformation
		End With
		' txtValue
		With txtValue
			.Name = "txtValue"
			.TabIndex = 43
			.SetBounds 237, 16, 212, 162
			.OnLostFocus = @txtValue_LostFocus
			.Parent = @picVersionInformation
		End With
		' txtTitle
		With txtTitle
			.Name = "txtTitle"
			.TabIndex = 32
			.SetBounds 40, 11, 159, 18
			.Parent = @picApplication
		End With
		' txtIcon
		With txtIcon
			.Name = "txtIcon"
			.TabIndex = 34
			.SetBounds 40, 37, 74, 18
			.ReadOnly = False
			.Parent = @picApplication
		End With
		' txtBuild
		With txtBuild
			.Name = "txtBuild"
			.TabIndex = 28
			.SetBounds 161, 32, 45, 21
			.Parent = @picVersionNumber
		End With
		' txtRevision
		With txtRevision
			.Name = "txtRevision"
			.TabIndex = 26
			.SetBounds 109, 32, 45, 21
			.Parent = @picVersionNumber
		End With
		' txtMinor
		With txtMinor
			.Name = "txtMinor"
			.TabIndex = 24
			.SetBounds 58, 32, 45, 21
			.Parent = @picVersionNumber
		End With
		' txtMajor
		With txtMajor
			.Name = "txtMajor"
			.TabIndex = 22
			.SetBounds 6, 32, 45, 21
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
			.TabIndex = 88
			.SetBounds 16, 20, 212, 90
			.Parent = @tpMake
		End With
		' picVersionInformation
		With picApplication
			.Name = "picApplication"
			.TabIndex = 89
			.SetBounds 262, 20, 202, 100
			.Parent = @tpMake
		End With
		' picVersionInformation
		With picVersionInformation
			.Name = "picVersionInformation"
			.TabIndex = 39
			.SetBounds 16, 155, 450, 181
			.Parent = @tpMake
		End With
		' picCompilationArguments
		With picCompilationArguments
			.Name = "picCompilationArguments"
			.TabIndex = 57
			.SetBounds 24, 156, 445, 113
			.Text = ""
			.Parent = @tpCompile
		End With
		' optCompileByDefault
		With optCompileByDefault
			.Name = "optCompileByDefault"
			.Text = ML("Compile by default")
			.TabIndex = 45
			.Checked = True
			.SetBounds 16, 15, 150, 16
			'.Caption = ML("Compile by default")
			.Designer = @This
			.OnClick = @optCompileByDefault_Click_
			.Parent = @tpCompile
		End With
		' optCompileToLLVM
		With optCompileToLLVM
			.Name = "optCompileToLLVM"
			.Text = ML("Compile to LLVM")
			.TabIndex = 47
			.SetBounds 330, 15, 140, 16
			'.Caption = ML("Compile to LLVM")
			.Designer = @This
			.OnClick = @optCompileToLLVM_Click_
			.Parent = @tpCompile
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "..."
			.TabIndex = 35
			.SetBounds 114, 36, 20, 20
			'.Caption = "..."
			.Designer = @This
			.OnClick = @CommandButton1_Click_
			.Parent = @picApplication
		End With
		' imgIcon
		With imgIcon
			.Name = "imgIcon"
			.Text = "lblIcon"
			.SetBounds 156, 41, 32, 32
			.Parent = @picApplication
		End With
		' chkPassAllModuleFilesToCompiler
		With chkPassAllModuleFilesToCompiler
			.Name = "chkPassAllModuleFilesToCompiler"
			.Text = ML("Pass All Module Files To Compiler")
			.TabIndex = 16
			.SetBounds 11, 120, 192, 22
			'.Caption = ML("Pass All Module Files To Compiler")
			.Parent = @tpGeneral
		End With
		' cboSubsystem
		With cboSubsystem
			.Name = "cboSubsystem"
			.Text = "cboSubsystem"
			.TabIndex = 7
			.SetBounds 10, 84, 202, 21
			.Parent = @tpGeneral
		End With
		' lblSubsystem
		With lblSubsystem
			.Name = "lblSubsystem"
			.Text = ML("Subsystem") & " (" & ML("For Windows") & "):"
			.TabIndex = 6
			.SetBounds 10, 66, 202, 18
			'.Caption = ML("Subsystem") & " (" & ML("For Windows") & "):"
			.Parent = @tpGeneral
		End With
		' tpAndroidSettings
		With tpAndroidSettings
			.Name = "tpAndroidSettings"
			.Text = ML("Android Settings")
			.TabIndex = 74
			.UseVisualStyleBackColor = True
			'.Caption = ML("Android Settings")
			.SetBounds 2, 22, 487, 316
			.Parent = @tabProperties
		End With
		' txtAndroidSDKLocation
		With txtAndroidSDKLocation
			.Name = "txtAndroidSDKLocation"
			.Text = ""
			.TabIndex = 76
			.SetBounds 12, 32, 430, 20
			.Parent = @tpAndroidSettings
		End With
		' cmdAndroidSDKLocation
		With cmdAndroidSDKLocation
			.Name = "cmdAndroidSDKLocation"
			.Text = "..."
			.TabIndex = 77
			.Caption = "..."
			.SetBounds 450, 31, 25, 22
			.Designer = @This
			.OnClick = @cmdAndroidSDKLocation_Click_
			.Parent = @tpAndroidSettings
		End With
		' lblAndroidSDKLocation
		With lblAndroidSDKLocation
			.Name = "lblAndroidSDKLocation"
			.Text = ML("Android SDK location")
			.TabIndex = 75
			'.Caption = ML("Android SDK location")
			.SetBounds 12, 12, 260, 20
			.Parent = @tpAndroidSettings
		End With
		' lblAndroidNDKLocation
		With lblAndroidNDKLocation
			.Name = "lblAndroidNDKLocation"
			.Text = ML("Android NDK location")
			.TabIndex = 78
			'.Caption = ML("Android NDK location")
			.SetBounds 12, 72, 260, 20
			.Parent = @tpAndroidSettings
		End With
		' txtAndroidNDKLocation
		With txtAndroidNDKLocation
			.Name = "txtAndroidNDKLocation"
			.TabIndex = 79
			.Text = ""
			.SetBounds 12, 92, 430, 20
			.Parent = @tpAndroidSettings
		End With
		' cmdAndroidNDKLocation
		With cmdAndroidNDKLocation
			.Name = "cmdAndroidNDKLocation"
			.Text = "..."
			.TabIndex = 80
			.SetBounds 450, 91, 25, 22
			.Designer = @This
			.OnClick = @cmdAndroidNDKLocation_Click_
			.Parent = @tpAndroidSettings
		End With
		' lblJDKLocation
		With lblJDKLocation
			.Name = "lblJDKLocation"
			.Text = ML("JDK location")
			.TabIndex = 81
			'.Caption = ML("JDK location")
			.SetBounds 12, 132, 260, 20
			.Parent = @tpAndroidSettings
		End With
		' txtJDKLocation
		With txtJDKLocation
			.Name = "txtJDKLocation"
			.TabIndex = 82
			.Text = ""
			.SetBounds 12, 152, 430, 20
			.Parent = @tpAndroidSettings
		End With
		' cmdJDKLocation
		With cmdJDKLocation
			.Name = "cmdJDKLocation"
			.Text = "..."
			.TabIndex = 83
			.SetBounds 450, 151, 25, 22
			.Designer = @This
			.OnClick = @cmdJDKLocation_Click_
			.Parent = @tpAndroidSettings
		End With
		' BrowseD
		With BrowseD
			.Name = "BrowseD"
			.SetBounds 60, 400, 16, 16
			.Parent = @This
		End With
		' OpenD
		With OpenD
			.Name = "OpenD"
			.SetBounds 80, 400, 16, 16
			.Parent = @This
		End With
		' lblCompiler
		With lblCompiler
			.Name = "lblCompiler"
			.Text = ML("Compiler") & ":"
			.TabIndex = 66
			'.Caption = ML("Compiler") & ":"
			.SetBounds 29, 288, 90, 20
			.Parent = @tpCompile
		End With
		' cboCompiler
		With cboCompiler
			.Name = "cboCompiler"
			.Text = "ComboBoxEdit1"
			.TabIndex = 67
			.SetBounds 102, 285, 126, 21
			.Designer = @This
			.OnSelected = @cboCompiler_Selected_
			.Parent = @tpCompile
		End With
		' txtCompilerPath
		With txtCompilerPath
			.Name = "txtCompilerPath"
			.Text = ""
			.TabIndex = 68
			.SetBounds 236, 285, 198, 20
			.Designer = @This
			.OnChange = @txtCompilerPath_Change_
			.Parent = @tpCompile
		End With
		' cmdCompiler
		With cmdCompiler
			.Name = "cmdCompiler"
			.Text = "..."
			.TabIndex = 69
			.SetBounds 441, 284, 25, 22
			.Designer = @This
			.OnClick = @cmdCompiler_Click_
			.Parent = @tpCompile
		End With
		' chkManifest
		With chkManifest
			.Name = "chkManifest"
			.Text = ML("Manifest")
			.TabIndex = 36
			'.Caption = ML("Manifest")
			.SetBounds 4, 59, 130, 20
			.Designer = @This
			.OnClick = @chkManifest_Click_
			.Parent = @picApplication
		End With
		' chkRunAsAdministrator
		With chkRunAsAdministrator
			.Name = "chkRunAsAdministrator"
			.Text = ML("Run as administrator")
			.TabIndex = 37
			'.Caption = ML("Run as administrator")
			.SetBounds 30, 80, 170, 20
			.Designer = @This
			.Parent = @picApplication
		End With
		' chkOpenProjectAsFolder
		With chkOpenProjectAsFolder
			.Name = "chkOpenProjectAsFolder"
			.Text = ML("Open Project As Folder")
			.TabIndex = 90
			.ControlIndex = 14
			'.Caption = ML("Open Project As Folder")
			.SetBounds 11, 147, 192, 22
			.Designer = @This
			.Parent = @tpGeneral
		End With
		' lblBatchCompilationFileWindows
		With lblBatchCompilationFileWindows
			.Name = "lblBatchCompilationFileWindows"
			.Text = ML("Batch Compilation File") & " (" & ML("For Windows") & "):"
			.TabIndex = 91
			.ControlIndex = 9
			'.Caption = ML("Batch Compilation File") & " (" & ML("For Windows") & "):"
			.SetBounds 224, 182, 262, 18
			.Designer = @This
			.Parent = @tpGeneral
		End With
		' cboBatchСompilationFileWindows
		With cboBatchCompilationFileWindows
			.Name = "cboBatchCompilationFileWindows"
			.Text = "cboMainFile1"
			.TabIndex = 92
			.ControlIndex = 8
			.SetBounds 224, 200, 252, 21
			.Designer = @This
			.Parent = @tpGeneral
		End With
		' lblBatchCompilationFileLinux
		With lblBatchCompilationFileLinux
			.Name = "lblBatchCompilationFileLinux"
			.Text = ML("Batch Compilation File") & " (" & ML("For *nix/*bsd") & "):"
			.TabIndex = 93
			.ControlIndex = 12
			.Caption = ML("Batch Compilation File") & " (" & ML("For *nix/*bsd") & "):"
			.SetBounds 224, 240, 262, 18
			.Designer = @This
			.Parent = @tpGeneral
		End With
		' cboBatchCompilationFileLinux
		With cboBatchCompilationFileLinux
			.Name = "cboBatchCompilationFileLinux"
			.Text = "cboResourceFile1"
			.TabIndex = 94
			.ControlIndex = 14
			.SetBounds 224, 258, 252, 21
			.Designer = @This
			.Parent = @tpGeneral
		End With
		' grbIncludePaths
		With grbIncludePaths
			.Name = "grbIncludePaths"
			.Text = ML("Include Paths")
			.TabIndex = 96
			.Caption = ML("Include Paths")
			.Margins.Top = 20
			.Margins.Right = 15
			.Margins.Left = 15
			.Margins.Bottom = 15
			.SetBounds 10, 8, 467, 225
			.Designer = @This
			.Parent = @tpIncludes
		End With
		' grbLibraryPaths
		With grbLibraryPaths
			.Name = "grbLibraryPaths"
			.Text = ML("Library Paths")
			.TabIndex = 97
			.Caption = ML("Library Paths")
			.Margins.Top = 22
			.Margins.Right = 15
			.Margins.Left = 15
			.Margins.Bottom = 15
			.SetBounds 10, 240, 467, 107
			.Designer = @This
			.Parent = @tpIncludes
		End With
		' lblComponents
		With lblComponents
			.Name = "lblComponents"
			.Text = ML("Components") & ":"
			.TabIndex = 101
			.Caption = ML("Components") & ":"
			.Align = DockStyle.alTop
			.SetBounds 0, 0, 440, 20
			.Designer = @This
			.Parent = @picComponents
		End With
		' lstComponents
		With lstComponents
			.Name = "lstComponents"
			.Text = "ListControl1"
			.TabIndex = 98
			.Align = DockStyle.alClient
			.ExtraMargins.Right = 25
			.SetBounds 0, 20, 425, 56
			.Designer = @This
			.Parent = @picComponents
		End With
		' lblOthers
		With lblOthers
			.Name = "lblOthers"
			.Text = ML("Others") & ":"
			.TabIndex = 102
			.Caption = ML("Others") & ":"
			.Align = DockStyle.alTop
			.ExtraMargins.Top = 0
			.SetBounds 0, 10, 437, 20
			.Designer = @This
			.Parent = @picOtherIncludes
		End With
		' lstOtherIncludes
		With lstOtherIncludes
			.Name = "lstOtherIncludes"
			.Text = "ListControl2"
			.TabIndex = 99
			.Align = DockStyle.alClient
			.ExtraMargins.Right = 25
			.SetBounds 0, 30, 412, 56
			.Designer = @This
			.Parent = @picOtherIncludes
		End With
		' lstLibraryPaths
		With lstLibraryPaths
			.Name = "lstLibraryPaths"
			.Text = "ListControl3"
			.TabIndex = 100
			.Align = DockStyle.alClient
			.ExtraMargins.Right = 25
			.SetBounds 15, 22, 412, 69
			.Designer = @This
			.Parent = @grbLibraryPaths
		End With
		' cmdAddComponent
		With cmdAddComponent
			.Name = "cmdAddComponent"
			.Text = "+"
			.TabIndex = 103
			.Caption = "+"
			.SetBounds 413, 19, 24, 22
			.Designer = @This
			.OnClick = @_cmdAddComponent_Click
			.Parent = @picComponents
		End With
		' cmdRemoveComponent
		With cmdRemoveComponent
			.Name = "cmdRemoveComponent"
			.Text = "-"
			.TabIndex = 104
			.ControlIndex = 4
			.Caption = "-"
			.SetBounds 413, 41, 24, 22
			.Designer = @This
			.OnClick = @_cmdRemoveComponent_Click
			.Parent = @picComponents
		End With
		' cmdAddOtherInclude
		With cmdAddOtherInclude
			.Name = "cmdAddOtherInclude"
			.Text = "+"
			.TabIndex = 105
			.ControlIndex = 5
			.SetBounds 413, 19, 24, 22
			.Designer = @This
			.OnClick = @_cmdAddOtherInclude_Click
			.Parent = @picOtherIncludes
		End With
		' cmdRemoveOtherInclude
		With cmdRemoveOtherInclude
			.Name = "cmdRemoveOtherInclude"
			.Text = "-"
			.TabIndex = 106
			.ControlIndex = 4
			.SetBounds 413, 41, 24, 22
			.Designer = @This
			.OnClick = @_cmdRemoveOtherInclude_Click
			.Parent = @picOtherIncludes
		End With
		' cmdAddLibrary
		With cmdAddLibrary
			.Name = "cmdAddLibrary"
			.Text = "+"
			.TabIndex = 107
			.ControlIndex = 1
			.SetBounds 428, 21, 24, 22
			.Designer = @This
			.OnClick = @_cmdAddLibrary_Click
			.Parent = @grbLibraryPaths
		End With
		' cmdRemoveLibrary
		With cmdRemoveLibrary
			.Name = "cmdRemoveLibrary"
			.Text = "-"
			.TabIndex = 108
			.ControlIndex = 2
			.SetBounds 428, 43, 24, 22
			.Designer = @This
			.OnClick = @_cmdRemoveLibrary_Click
			.Parent = @grbLibraryPaths
		End With
		' picComponents
		With picComponents
			.Name = "picComponents"
			.Text = ""
			.TabIndex = 109
			.ControlIndex = 2
			.SetBounds 25, 27, 437, 90
			.Designer = @This
			.Parent = @tpIncludes
		End With
		' picOtherIncludes
		With picOtherIncludes
			.Name = "picOtherIncludes"
			.Text = ""
			.TabIndex = 119
			.ControlIndex = 3
			.SetBounds 25, 127, 437, 90
			.Designer = @This
			.Parent = @tpIncludes
		End With
		' optCompileToClang
		With optCompileToClang
			.Name = "optCompileToClang"
			.Text = ML("Compile to CLANG")
			.TabIndex = 111
			.ControlIndex = 3
			.Caption = ML("Compile to CLANG")
			.SetBounds 180, 34, 142, 16
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton), @optCompileToClang_Click)
			.Parent = @tpCompile
		End With
	End Constructor
	
	Private Sub frmProjectProperties._cmdRemoveLibrary_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		(*Cast(frmProjectProperties Ptr, Sender.Designer)).cmdRemoveLibrary_Click(Sender)
	End Sub
	
	Private Sub frmProjectProperties._cmdAddLibrary_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		(*Cast(frmProjectProperties Ptr, Sender.Designer)).cmdAddLibrary_Click(Sender)
	End Sub
	
	Private Sub frmProjectProperties._cmdRemoveOtherInclude_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		(*Cast(frmProjectProperties Ptr, Sender.Designer)).cmdRemoveOtherInclude_Click(Sender)
	End Sub
	
	Private Sub frmProjectProperties._cmdAddOtherInclude_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		(*Cast(frmProjectProperties Ptr, Sender.Designer)).cmdAddOtherInclude_Click(Sender)
	End Sub
	
	Private Sub frmProjectProperties._cmdRemoveComponent_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		(*Cast(frmProjectProperties Ptr, Sender.Designer)).cmdRemoveComponent_Click(Sender)
	End Sub
	
	Private Sub frmProjectProperties._cmdAddComponent_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		(*Cast(frmProjectProperties Ptr, Sender.Designer)).cmdAddComponent_Click(Sender)
	End Sub
	
	Private Sub frmProjectProperties._Form_Create(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		(*Cast(frmProjectProperties Ptr, Sender.Designer)).Form_Create(Sender)
	End Sub
	
	Private Sub frmProjectProperties._cboOptimizationLevel_Selected(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		(*Cast(frmProjectProperties Ptr, Sender.Designer)).cboOptimizationLevel_Selected(Sender, ItemIndex)
	End Sub
	
	Private Sub frmProjectProperties.chkManifest_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
		(*Cast(frmProjectProperties Ptr, Sender.Designer)).chkManifest_Click(Sender)
	End Sub
	
	Private Sub frmProjectProperties.cboCompiler_Selected_(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		(*Cast(frmProjectProperties Ptr, Sender.Designer)).cboCompiler_Selected(Sender, ItemIndex)
	End Sub

	Private Sub frmProjectProperties.txtCompilerPath_Change_(ByRef Designer As My.Sys.Object, ByRef Sender As TextBox)
		(*Cast(frmProjectProperties Ptr, Sender.Designer)).txtCompilerPath_Change(Sender)
	End Sub
	
	Private Sub frmProjectProperties.cmdCompiler_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		(*Cast(frmProjectProperties Ptr, Sender.Designer)).cmdCompiler_Click(Sender)
	End Sub

	#ifndef _NOT_AUTORUN_FORMS_
		fProjectProperties.Show
		
		App.Run
	#endif
'#End Region


Private Sub frmProjectProperties.cmdOK_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fProjectProperties
		If .ProjectTreeNode = 0 Then Exit Sub
		Dim As ProjectElement Ptr ppe = .ProjectTreeNode->Tag
		If ppe = 0 Then
			ppe = _New( ProjectElement)
			WLet(ppe->FileName, "")
		End If
		WLet(ppe->MainFileName, .MainFiles.Get(.cboMainFile.Text))
		WLet(ppe->ResourceFileName, .ResourceFiles.Get(.cboResourceFile.Text))
		WLet(ppe->IconResourceFileName, .IconResourceFiles.Get(.cboIconResourceFile.Text))
		WLet(ppe->BatchCompilationFileNameWindows, .BatchCompilationFilesWindows.Get(.cboBatchCompilationFileWindows.Text))
		WLet(ppe->BatchCompilationFileNameLinux, .BatchCompilationFilesLinux.Get(.cboBatchCompilationFileLinux.Text))
		ppe->ProjectType = .cboProjectType.ItemIndex
		ppe->Subsystem = .cboSubsystem.ItemIndex
		WLet(ppe->ProjectName, .txtProjectName.Text)
		WLet(ppe->HelpFileName, .txtHelpFileName.Text)
		WLet(ppe->ProjectDescription, .txtProjectDescription.Text)
		ppe->PassAllModuleFilesToCompiler = .chkPassAllModuleFilesToCompiler.Checked
		ppe->OpenProjectAsFolder = .chkOpenProjectAsFolder.Checked
		ppe->MajorVersion = Val(.txtMajor.Text)
		ppe->MinorVersion = Val(.txtMinor.Text)
		ppe->RevisionVersion = Val(.txtRevision.Text)
		ppe->BuildVersion = Val(.txtBuild.Text)
		ppe->AutoIncrementVersion = .chkAutoIncrementVersion.Checked
		WLet(ppe->ApplicationTitle, .txtTitle.Text)
		WLet(ppe->ApplicationIcon, .txtIcon.Text)
		ppe->Manifest = .chkManifest.Checked 
		ppe->RunAsAdministrator = .chkRunAsAdministrator.Checked 
		WLet(ppe->CompanyName, .Types.Get(ML("Company Name")))
		WLet(ppe->FileDescription, .Types.Get(ML("File Description")))
		WLet(ppe->InternalName, .Types.Get(ML("Internal Name")))
		WLet(ppe->LegalCopyright, .Types.Get(ML("Legal Copyright")))
		WLet(ppe->LegalTrademarks, .Types.Get(ML("Legal Trademarks")))
		WLet(ppe->OriginalFilename, .Types.Get(ML("Original Filename")))
		WLet(ppe->ProductName, .Types.Get(ML("Product Name")))
		Select Case True
		Case .optCompileByDefault.Checked: ppe->CompileTo = ByDefault
		Case .optCompileToGas.Checked: ppe->CompileTo = ToGAS
		Case .optCompileToLLVM.Checked: ppe->CompileTo = ToLLVM
		Case .optCompileToGcc.Checked: ppe->CompileTo = ToGCC
		Case .optCompileToCLANG.Checked: ppe->CompileTo = ToCLANG
		End Select
		ppe->OptimizationFastCode = .optOptimizationFastCode.Checked
		ppe->OptimizationSmallCode = .optOptimizationSmallCode.Checked
		ppe->OptimizationLevel = IIf(.optOptimizationLevel.Checked, Val(.cboOptimizationLevel.Text), 0)
		WLet(ppe->CompilationArguments32Windows, .txtCompilationArguments32Windows.Text)
		WLet(ppe->CompilationArguments64Windows, .txtCompilationArguments64Windows.Text)
		WLet(ppe->CompilationArguments32Linux, .txtCompilationArguments32Linux.Text)
		WLet(ppe->CompilationArguments64Linux, .txtCompilationArguments64Linux.Text)
		WLet(ppe->CompilerPath, .txtCompilerPath.Text)
		ppe->Components.Clear
		For i As Integer = 0 To .lstComponents.ItemCount - 1
			ppe->Components.Add .lstComponents.Item(i)
		Next
		ppe->IncludePaths.Clear
		For i As Integer = 0 To .lstOtherIncludes.ItemCount - 1
			ppe->IncludePaths.Add .lstOtherIncludes.Item(i)
		Next
		ppe->LibraryPaths.Clear
		For i As Integer = 0 To .lstLibraryPaths.ItemCount - 1
			ppe->LibraryPaths.Add .lstLibraryPaths.Item(i)
		Next
		WLet(ppe->CommandLineArguments, .txtCommandLineArguments.Text)
		ppe->CreateDebugInfo = .chkCreateDebugInfo.Checked
		If CBool(*ppe->AndroidSDKLocation <> .txtAndroidSDKLocation.Text OrElse *ppe->AndroidNDKLocation <> .txtAndroidNDKLocation.Text) AndAlso _
			CBool(Not EndsWith(*ppe->FileName, ".vfp") AndAlso FileExists(*ppe->FileName & "/local.properties")) Then
			WLet(ppe->AndroidSDKLocation, .txtAndroidSDKLocation.Text)
			WLet(ppe->AndroidNDKLocation, .txtAndroidNDKLocation.Text)
			Dim As Integer Fn1 = FreeFile_
			Open *ppe->FileName & "/local.properties" For Input As #Fn1
			Dim pBuff As WString Ptr
			Dim As Integer FileSize
			Dim As WStringList Lines
			FileSize = LOF(Fn1)
			WReAllocate(pBuff, FileSize)
			Do Until EOF(Fn1)
				LineInputWstr Fn1, pBuff, FileSize
				Lines.Add *pBuff
			Loop
			CloseFile_(Fn1)
			Dim As Boolean bFindSDK, bFindNDK
			Dim As Integer Fn2 = FreeFile_
			Open *ppe->FileName & "/local.properties" For Output As #Fn2
			For i As Integer = 0 To Lines.Count - 1
				If StartsWith(Lines.Item(i), "sdk.dir=") Then
					Print #Fn2, "sdk.dir=" & Replace(Replace(*ppe->AndroidSDKLocation, "\", "\\"), ":", "\:")
					bFindSDK = True
				ElseIf StartsWith(Lines.Item(i), "ndk.dir=") Then
					Print #Fn2, "ndk.dir=" & Replace(Replace(*ppe->AndroidNDKLocation, "\", "\\"), ":", "\:")
					bFindNDK = True
				Else
					Print #Fn2, Lines.Item(i)
				End If
			Next i
			If *ppe->AndroidSDKLocation <> "" AndAlso Not bFindSDK Then
				Print #Fn2, "sdk.dir=" & Replace(Replace(*ppe->AndroidSDKLocation, "\", "\\"), ":", "\:")
			End If
			If *ppe->AndroidNDKLocation <> "" AndAlso Not bFindNDK Then
				Print #Fn2, "ndk.dir=" & Replace(Replace(*ppe->AndroidNDKLocation, "\", "\\"), ":", "\:")
			End If
			CloseFile_(Fn2)
		End If
		If CBool(Not EndsWith(*ppe->FileName, ".vfp") AndAlso FileExists(*ppe->FileName & "/gradle.properties")) AndAlso _
			(*ppe->JDKLocation <> .txtJDKLocation.Text) Then
			WLet(ppe->JDKLocation, .txtJDKLocation.Text)
			Dim As Integer Fn1 = FreeFile_
			Open *ppe->FileName & "/gradle.properties" For Input As #Fn1
			Dim pBuff As WString Ptr
			Dim As Integer FileSize
			Dim As WStringList Lines
			FileSize = LOF(Fn1)
			WReAllocate(pBuff, FileSize)
			Do Until EOF(Fn1)
				LineInputWstr Fn1, pBuff, FileSize
				Lines.Add *pBuff
			Loop
			CloseFile_(Fn1)
			Dim As Boolean bFindJDK
			Dim As Integer Fn2 = FreeFile_
			Open *ppe->FileName & "/gradle.properties" For Output As #Fn2
			For i As Integer = 0 To Lines.Count - 1
				If StartsWith(Lines.Item(i), "org.gradle.java.home=") Then
					Print #Fn2, "org.gradle.java.home=" & Replace(Replace(*ppe->JDKLocation, "\", "\\"), ":", "\:")
					bFindJDK = True
				Else
					Print #Fn2, Lines.Item(i)
				End If
			Next i
			If *ppe->JDKLocation <> "" AndAlso Not bFindJDK Then
				Print #Fn2, "org.gradle.java.home=" & Replace(Replace(*ppe->JDKLocation, "\", "\\"), ":", "\:")
			End If
			CloseFile_(Fn2)
		End If
		If Not EndsWith(.ProjectTreeNode->Text, "*") Then .ProjectTreeNode->Text &= "*"
		.CloseForm
	End With
End Sub

Private Sub frmProjectProperties.cmdCancel_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
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
		ElseIf LCase(tn->Text) = "makefile" Then
			.cboBatchCompilationFileWindows.AddItem tn->Text
			.BatchCompilationFilesWindows.Add tn->Text, IIf(ee, *ee->FileName, "")
			.cboBatchCompilationFileLinux.AddItem tn->Text
			.BatchCompilationFilesLinux.Add tn->Text, IIf(ee, *ee->FileName, "")
		ElseIf EndsWith(LCase(tn->Text), ".bat") Then
			.cboBatchCompilationFileWindows.AddItem tn->Text
			.BatchCompilationFilesWindows.Add tn->Text, IIf(ee, *ee->FileName, "")
		ElseIf EndsWith(LCase(tn->Text), ".sh") OrElse InStr(tn->Text, ".") = 0 Then
			.cboBatchCompilationFileLinux.AddItem tn->Text
			.BatchCompilationFilesLinux.Add tn->Text, IIf(ee, *ee->FileName, "")
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
		ElseIf LCase(Text) = "makefile" Then
			.cboBatchCompilationFileWindows.AddItem Text
			.BatchCompilationFilesWindows.Add Text, FileName
			.cboBatchCompilationFileLinux.AddItem Text
			.BatchCompilationFilesLinux.Add Text, FileName
		ElseIf EndsWith(LCase(Text), ".bat") Then
			.cboBatchCompilationFileWindows.AddItem Text
			.BatchCompilationFilesWindows.Add Text, FileName
		ElseIf EndsWith(LCase(Text), ".sh") OrElse InStr(Text, ".") = 0 Then
			.cboBatchCompilationFileLinux.AddItem Text
			.BatchCompilationFilesLinux.Add Text, FileName
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
		.lstComponents.Clear
		.lstOtherIncludes.Clear
		.lstLibraryPaths.Clear
		.cboMainFile.Clear
		.cboResourceFile.Clear
		.cboIconResourceFile.Clear
		.cboBatchCompilationFileWindows.Clear
		.cboBatchCompilationFileLinux.Clear
		.MainFiles.Clear
		.ResourceFiles.Clear
		.IconResourceFiles.Clear
		.BatchCompilationFilesWindows.Clear
		.BatchCompilationFilesLinux.Clear
		.cboMainFile.AddItem ML("(not selected)")
		.cboResourceFile.AddItem ML("(not selected)")
		.cboIconResourceFile.AddItem ML("(not selected)")
		.cboBatchCompilationFileWindows.AddItem ML("(not selected)")
		.cboBatchCompilationFileLinux.AddItem ML("(not selected)")
		Dim As Boolean bSetted = False
		If ptn->ImageKey = "Project" OrElse ee AndAlso *ee Is ProjectElement Then
			.ProjectTreeNode = ptn
			ppe = Cast(ProjectElement Ptr, ee)
			If ptn->ImageKey = "Project" AndAlso Not ppe->ProjectFolderType = ProjectFolderTypes.ShowAsFolder Then
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
				.cboSubsystem.ItemIndex = ppe->Subsystem
				If .MainFiles.IndexOf(*ppe->MainFileName) > -1 Then .cboMainFile.Text = .MainFiles.Item(.MainFiles.IndexOf(*ppe->MainFileName))->Key Else .cboMainFile.ItemIndex = 0
				If .ResourceFiles.IndexOf(*ppe->ResourceFileName) > -1 Then .cboResourceFile.Text = .ResourceFiles.Item(.ResourceFiles.IndexOf(*ppe->ResourceFileName))->Key Else .cboResourceFile.ItemIndex = 0
				If .IconResourceFiles.IndexOf(*ppe->IconResourceFileName) > -1 Then .cboIconResourceFile.Text = .IconResourceFiles.Item(.IconResourceFiles.IndexOf(*ppe->IconResourceFileName))->Key Else .cboIconResourceFile.ItemIndex = 0
				If .BatchCompilationFilesWindows.IndexOf(*ppe->BatchCompilationFileNameWindows) > -1 Then .cboBatchCompilationFileWindows.Text = .BatchCompilationFilesWindows.Item(.BatchCompilationFilesWindows.IndexOf(*ppe->BatchCompilationFileNameWindows))->Key Else .cboBatchCompilationFileWindows.ItemIndex = 0
				If .BatchCompilationFilesLinux.IndexOf(*ppe->BatchCompilationFileNameLinux) > -1 Then .cboBatchCompilationFileLinux.Text = .BatchCompilationFilesLinux.Item(.BatchCompilationFilesLinux.IndexOf(*ppe->BatchCompilationFileNameLinux))->Key Else .cboBatchCompilationFileLinux.ItemIndex = 0
				.txtProjectName.Text = *ppe->ProjectName
				.txtHelpFileName.Text = *ppe->HelpFileName
				.txtProjectDescription.Text = *ppe->ProjectDescription
				.chkPassAllModuleFilesToCompiler.Checked = ppe->PassAllModuleFilesToCompiler
				.chkOpenProjectAsFolder.Checked = ppe->OpenProjectAsFolder
				.txtMajor.Text = WStr(ppe->MajorVersion)
				.txtMinor.Text = WStr(ppe->MinorVersion)
				.txtRevision.Text = WStr(ppe->RevisionVersion)
				.txtBuild.Text = WStr(ppe->BuildVersion)
				.chkAutoIncrementVersion.Checked = ppe->AutoIncrementVersion
				.txtTitle.Text = *ppe->ApplicationTitle
				.txtIcon.Text = *ppe->ApplicationIcon
				If Trim(*ppe->ApplicationIcon) <> "" Then
					'#ifdef __USE_GTK__
						imgIcon.Graphic.Icon.LoadFromFile(GetResNamePath(*ppe->ApplicationIcon, GetResourceFile(True)), 32, 32)
					'#else
					'	DrawIconEx GetDC(picApplication.Handle), 0, 0, imgIcon.Graphic.Icon.Handle, 32, 32, 0, 0, DI_NORMAL
					'#endif
				End If
				.chkManifest.Checked = ppe->Manifest
				.chkManifest_Click(.chkManifest)
				.chkRunAsAdministrator.Checked = ppe->RunAsAdministrator
				.Types.Set ML("Company Name"), *ppe->CompanyName
				.Types.Set ML("File Description"), *ppe->FileDescription
				.Types.Set ML("Internal Name"), *ppe->InternalName
				.Types.Set ML("Legal Copyright"), *ppe->LegalCopyright
				.Types.Set ML("Legal Trademarks"), *ppe->LegalTrademarks
				.Types.Set ML("Original Filename"), *ppe->OriginalFilename
				.Types.Set ML("Product Name"), *ppe->ProductName
				.optCompileByDefault.Checked = False
				.optCompileToGas.Checked = False
				.optCompileToLLVM.Checked = False
				.optCompileToGcc.Checked = False
				.optCompileToClang.Checked = False
				Select Case ppe->CompileTo
				Case ByDefault: .optCompileByDefault.Checked = True
				Case ToGAS: .optCompileToGas.Checked = True
				Case ToLLVM: .optCompileToLLVM.Checked = True
				Case ToGCC: .optCompileToGcc.Checked = True
				Case ToCLANG: .optCompileToClang.Checked = True
				End Select
				.optCompileToGas_Click(*.optCompileToGas.Designer, .optCompileToGas)
				.optNoOptimization.Checked = ppe->OptimizationLevel = 0
				.optOptimizationLevel.Checked = ppe->OptimizationLevel > 0
				.cboOptimizationLevel.ItemIndex = ppe->OptimizationLevel
				.optOptimizationSmallCode.Checked = ppe->OptimizationSmallCode
				.optOptimizationFastCode.Checked = ppe->OptimizationFastCode
				.txtCompilationArguments32Windows.Text = *ppe->CompilationArguments32Windows
				.txtCompilationArguments64Windows.Text = *ppe->CompilationArguments64Windows
				.txtCompilationArguments32Linux.Text = *ppe->CompilationArguments32Linux
				.txtCompilationArguments64Linux.Text = *ppe->CompilationArguments64Linux
				.txtCompilerPath.Text = *ppe->CompilerPath
				For i As Integer = 0 To ppe->Components.Count - 1
					.lstComponents.AddItem ppe->Components.Item(i)
				Next
				For i As Integer = 0 To ppe->IncludePaths.Count - 1
					.lstOtherIncludes.AddItem ppe->IncludePaths.Item(i)
				Next
				For i As Integer = 0 To ppe->LibraryPaths.Count - 1
					.lstLibraryPaths.AddItem ppe->LibraryPaths.Item(i)
				Next
				.txtCommandLineArguments.Text = *ppe->CommandLineArguments
				.chkCreateDebugInfo.Checked = ppe->CreateDebugInfo
				If Not EndsWith(*ppe->FileName, ".vfp") AndAlso FileExists(*ppe->FileName & "/local.properties") Then
					Dim As Integer Fn = FreeFile_
					Open *ppe->FileName & "/local.properties" For Input As #Fn
					Dim SDKDir As UString
					Dim NDKDir As UString
					Dim pBuff As WString Ptr
					Dim As Integer FileSize
					FileSize = LOF(Fn)
					WReAllocate(pBuff, FileSize)
					Do Until EOF(Fn)
						LineInputWstr Fn, pBuff, FileSize
						If StartsWith(*pBuff, "sdk.dir=") Then
							SDKDir = Replace(Replace(Mid(*pBuff, 9), "\\", "\"), "\:", ":")
						End If
						If StartsWith(*pBuff, "ndk.dir=") Then
							NDKDir = Replace(Replace(Mid(*pBuff, 9), "\\", "\"), "\:", ":")
						End If
					Loop
					WLet(ppe->AndroidSDKLocation, SDKDir)
					WLet(ppe->AndroidNDKLocation, NDKDir)
					.txtAndroidSDKLocation.Text = SDKDir
					.txtAndroidNDKLocation.Text = NDKDir
					CloseFile_(Fn)
				End If
				If Not EndsWith(*ppe->FileName, ".vfp") AndAlso FileExists(*ppe->FileName & "/gradle.properties") Then
					Dim As Integer Fn = FreeFile_
					Open *ppe->FileName & "/gradle.properties" For Input As #Fn
					Dim JavaHome As UString
					Dim pBuff As WString Ptr
					Dim As Integer FileSize
					FileSize = LOF(Fn)
					WReAllocate(pBuff, FileSize)
					Do Until EOF(Fn)
						LineInputWstr Fn, pBuff, FileSize
						If StartsWith(*pBuff, "org.gradle.java.home=") Then
							JavaHome = Replace(Replace(Mid(*pBuff, 22), "\\", "\"), "\:", ":")
							Exit Do
						End If
					Loop
					WLet(ppe->JDKLocation, JavaHome)
					.txtJDKLocation.Text = JavaHome
					CloseFile_(Fn)
				End If
			End If
		Else
			.ProjectTreeNode = ptn
		End If
		If Not bSetted Then
			.cboProjectType.ItemIndex = -1
			.cboSubsystem.ItemIndex = -1
			.cboMainFile.ItemIndex = -1
			.cboResourceFile.ItemIndex = -1
			.cboIconResourceFile.ItemIndex = -1
			.cboBatchCompilationFileWindows.ItemIndex = -1
			.cboBatchCompilationFileLinux.ItemIndex = -1
			.txtProjectName.Text = ""
			.txtHelpFileName.Text = ""
			.txtProjectDescription.Text = ""
			.chkPassAllModuleFilesToCompiler.Checked = False
			.chkOpenProjectAsFolder.Checked = False
			.txtMajor.Text = ""
			.txtMinor.Text = ""
			.txtRevision.Text = ""
			.txtBuild.Text = ""
			.chkAutoIncrementVersion.Checked = False
			.txtTitle.Text = ""
			.txtIcon.Text = ""
			.chkManifest.Checked = True
			.chkRunAsAdministrator.Checked = False
			.chkManifest_Click(.chkManifest)
			.txtCompilationArguments32Windows.Text = ""
			.txtCompilationArguments64Windows.Text = ""
			.txtCompilationArguments32Linux.Text = ""
			.txtCompilationArguments64Linux.Text = ""
			.txtCompilerPath.Text = ""
			.txtAndroidSDKLocation.Text = ""
			.txtAndroidNDKLocation.Text = ""
			.txtJDKLocation.Text = ""
		End If
	End With
End Sub

Private Sub frmProjectProperties.tpCompile_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	
End Sub

Private Sub frmProjectProperties.lstType_Change(ByRef Designer As My.Sys.Object, ByRef Sender As ListControl)
	With fProjectProperties
		.txtValue.Text = .Types.Get(.lstType.Text)
	End With
End Sub

Private Sub frmProjectProperties.txtValue_LostFocus(ByRef Designer As My.Sys.Object, ByRef Sender As TextBox)
	With fProjectProperties
		.Types.Set .lstType.Text, .txtValue.Text
	End With
End Sub

Private Sub frmProjectProperties.cmdAdvancedOptions_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With *pfAdvancedOptions
		.ProjectTreeNode = fProjectProperties.ProjectTreeNode
		.chkShowUnusedLabelWarnings.Checked = False
		.chkShowUnusedFunctionWarnings.Checked = False
		.chkShowUnusedVariableWarnings.Checked = False
		.chkShowUnusedButSetVariableWarnings.Checked = False
		.chkShowMainWarnings.Checked = False
		If .ProjectTreeNode <> 0 Then
			Dim As ProjectElement Ptr ppe = .ProjectTreeNode->Tag
			If ppe <> 0 Then
				.chkShowUnusedLabelWarnings.Checked = ppe->ShowUnusedLabelWarnings
				.chkShowUnusedFunctionWarnings.Checked = ppe->ShowUnusedFunctionWarnings
				.chkShowUnusedVariableWarnings.Checked = ppe->ShowUnusedVariableWarnings
				.chkShowUnusedButSetVariableWarnings.Checked = ppe->ShowUnusedButSetVariableWarnings
				.chkShowMainWarnings.Checked = ppe->ShowMainWarnings
			End If
		End If
		.ShowModal fProjectProperties
	End With
End Sub

Private Sub frmProjectProperties.Form_Show(ByRef Designer As My.Sys.Object, ByRef Sender As Form)
	
End Sub

Private Sub frmProjectProperties.optCompileToGas_Click(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton)
	With fProjectProperties
		Dim As Boolean bEnabled = .optCompileToGcc.Checked OrElse .optCompileToClang.Checked
		.grbCompileToGCC.Enabled = bEnabled
		.optOptimizationLevel.Enabled = bEnabled
		.optOptimizationSmallCode.Enabled = bEnabled
		.optNoOptimization.Enabled = bEnabled
		.optOptimizationFastCode.Enabled = bEnabled
		.cboOptimizationLevel.Enabled = bEnabled
		.cmdAdvancedOptions.Enabled = bEnabled
	End With
End Sub

Private Sub frmProjectProperties.optCompileToGcc_Click(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton)
	frmProjectProperties.optCompileToGas_Click Designer, Sender
End Sub

Private Sub frmProjectProperties.optCompileByDefault_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton)
	(*Cast(frmProjectProperties Ptr, Sender.Designer)).optCompileByDefault_Click(Sender)
End Sub
Private Sub frmProjectProperties.optCompileByDefault_Click(ByRef Sender As RadioButton)
	frmProjectProperties.optCompileToGas_Click *Sender.Designer, Sender
End Sub

Private Sub frmProjectProperties.optCompileToLLVM_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton)
	(*Cast(frmProjectProperties Ptr, Sender.Designer)).optCompileToLLVM_Click(Sender)
End Sub
Private Sub frmProjectProperties.optCompileToLLVM_Click(ByRef Sender As RadioButton)
	frmProjectProperties.optCompileToGas_Click *Sender.Designer, Sender
End Sub

Private Sub frmProjectProperties.CommandButton1_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmProjectProperties Ptr, Sender.Designer)).CommandButton1_Click(Sender)
End Sub
Private Sub frmProjectProperties.CommandButton1_Click(ByRef Sender As Control)
	pfImageManager->OnlyIcons = True
	pfImageManager->WithoutMainNode = True
	If pfImageManager->ShowModal(Me) = ModalResults.OK Then
		If pfImageManager->SelectedItem <> 0 Then
			txtIcon.Text = pfImageManager->SelectedItem->Text(0)
			'#ifdef __USE_GTK__
				imgIcon.Graphic.Icon.LoadFromFile(GetRelativePath(pfImageManager->SelectedItem->Text(2), pfImageManager->ResourceFile), 32, 32)
			'#else
			'	DrawIconEx GetDC(picApplication.Handle), 0, 0, imgIcon.Graphic.Icon.Handle, 32, 32, 0, 0, DI_NORMAL
			'#endif
		End If
	End If
	pfImageManager->WithoutMainNode = False
End Sub

Private Sub frmProjectProperties.tpDebugging_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmProjectProperties Ptr, Sender.Designer)).tpDebugging_Click(Sender)
End Sub
Private Sub frmProjectProperties.tpDebugging_Click(ByRef Sender As Control)
	
End Sub

Private Sub frmProjectProperties.cmdAndroidSDKLocation_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmProjectProperties Ptr, Sender.Designer)).cmdAndroidSDKLocation_Click(Sender)
End Sub
Private Sub frmProjectProperties.cmdAndroidSDKLocation_Click(ByRef Sender As Control)
	BrowseD.InitialDir = txtAndroidSDKLocation.Text
	If BrowseD.Execute Then
		txtAndroidSDKLocation.Text = BrowseD.Directory
	End If
End Sub

Private Sub frmProjectProperties.cmdAndroidNDKLocation_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmProjectProperties Ptr, Sender.Designer)).cmdAndroidNDKLocation_Click(Sender)
End Sub
Private Sub frmProjectProperties.cmdAndroidNDKLocation_Click(ByRef Sender As Control)
	BrowseD.InitialDir = txtAndroidNDKLocation.Text
	If BrowseD.Execute Then
		txtAndroidNDKLocation.Text = BrowseD.Directory
	End If
End Sub

Private Sub frmProjectProperties.cmdJDKLocation_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmProjectProperties Ptr, Sender.Designer)).cmdJDKLocation_Click(Sender)
End Sub
Private Sub frmProjectProperties.cmdJDKLocation_Click(ByRef Sender As Control)
	BrowseD.InitialDir = txtJDKLocation.Text
	If BrowseD.Execute Then
		txtJDKLocation.Text = BrowseD.Directory
	End If
End Sub

Private Sub frmProjectProperties.cmdCompiler_Click(ByRef Sender As Control)
	OpenD.InitialDir = GetFolderName(txtCompilerPath.Text)
	If OpenD.Execute Then
		txtCompilerPath.Text = OpenD.FileName
	End If
End Sub

Private Sub frmProjectProperties.txtCompilerPath_Change(ByRef Sender As TextBox)
	If Trim(txtCompilerPath.Text) = "" Then
		cboCompiler.ItemIndex = 0
	Else
		Var Idx = pCompilers->IndexOf(Trim(txtCompilerPath.Text))
		If Idx = -1 Then
			cboCompiler.ItemIndex = cboCompiler.ItemCount - 1
		Else
			cboCompiler.ItemIndex = Idx + 1
		End If
	End If
End Sub

Private Sub frmProjectProperties.cboCompiler_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	If ItemIndex = 0 Then
		txtCompilerPath.Text = ""
	ElseIf ItemIndex > 0 AndAlso ItemIndex <= pCompilers->Count - 1 Then
		txtCompilerPath.Text = pCompilers->Item(ItemIndex - 1)->Text
	End If
End Sub

Private Sub frmProjectProperties.chkManifest_Click(ByRef Sender As CheckBox)
	chkRunAsAdministrator.Enabled = chkManifest.Checked
End Sub

Private Sub frmProjectProperties.cboOptimizationLevel_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	optOptimizationLevel.Checked = True
End Sub

Private Sub frmProjectProperties.Form_Create(ByRef Sender As Control)
	fProjectProperties.cboCompiler.Clear
	fProjectProperties.cboCompiler.AddItem ML("Default")
	For i As Integer = 0 To pCompilers->Count - 1
		fProjectProperties.cboCompiler.AddItem pCompilers->Item(i)->Key
	Next
	fProjectProperties.cboCompiler.AddItem ML("Custom")
	fProjectProperties.RefreshProperties
End Sub

Private Sub frmProjectProperties.cmdAddComponent_Click(ByRef Sender As Control)
	pfPath->txtPath.Text = ""
	pfPath->ChooseFolder = True
	If pfPath->ShowModal(Me) = ModalResults.OK Then
		If Not lstComponents.Items.Contains(pfPath->txtPath.Text) Then
			lstComponents.AddItem pfPath->txtPath.Text
		Else
			MsgBox ML("This path is exists!")
		End If
	End If
End Sub

Private Sub frmProjectProperties.cmdRemoveComponent_Click(ByRef Sender As Control)
	Var Index = lstComponents.ItemIndex
	If Index <> -1 Then lstComponents.RemoveItem Index
End Sub

Private Sub frmProjectProperties.cmdAddOtherInclude_Click(ByRef Sender As Control)
	pfPath->txtPath.Text = ""
	pfPath->ChooseFolder = True
	If pfPath->ShowModal(Me) = ModalResults.OK Then
		If Not lstOtherIncludes.Items.Contains(pfPath->txtPath.Text) Then
			lstOtherIncludes.AddItem pfPath->txtPath.Text
		Else
			MsgBox ML("This path is exists!")
		End If
	End If
End Sub

Private Sub frmProjectProperties.cmdRemoveOtherInclude_Click(ByRef Sender As Control)
	Var Index = lstOtherIncludes.ItemIndex
	If Index <> -1 Then lstOtherIncludes.RemoveItem Index
End Sub

Private Sub frmProjectProperties.cmdAddLibrary_Click(ByRef Sender As Control)
	pfPath->txtPath.Text = ""
	pfPath->ChooseFolder = True
	If pfPath->ShowModal(Me) = ModalResults.OK Then
		If Not lstLibraryPaths.Items.Contains(pfPath->txtPath.Text) Then
			lstLibraryPaths.AddItem pfPath->txtPath.Text
		Else
			MsgBox ML("This path is exists!")
		End If
	End If
End Sub

Private Sub frmProjectProperties.cmdRemoveLibrary_Click(ByRef Sender As Control)
	Var Index = lstLibraryPaths.ItemIndex
	If Index <> -1 Then lstLibraryPaths.RemoveItem Index
End Sub

Private Sub frmProjectProperties.optCompileToClang_Click(ByRef Sender As RadioButton)
	frmProjectProperties.optCompileToGas_Click *Sender.Designer, Sender
End Sub
