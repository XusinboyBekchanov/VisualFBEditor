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
		This.StartPosition = FormStartPosition.CenterScreen
		This.OnShow       = @Form_Show
		This.DefaultButton = @cmdOK
		This.CancelButton = @cmdCancel
		This.SetBounds 0, 0, 510, 428
		#ifdef __USE_GTK__
			This.Icon.LoadFromFile(ExePath & "/Resources/VisualFBEditor.ico")
		#else
			This.Icon.LoadFromResourceID(1)
		#endif
		' tabProperties
		tabProperties.Name = "tabProperties"
		tabProperties.Text = "TabControl1"
		tabProperties.SetBounds 6, 6, 493, 341
		tabProperties.Parent = @This
		' tpGeneral
		tpGeneral.Name = "tpGeneral"
		tpGeneral.Text = ML("General")
		tpGeneral.SetBounds -268, 22, 487, 316
		tpGeneral.UseVisualStyleBackColor = True
		tpGeneral.Parent = @tabProperties
		' tpMake
		tpMake.Name = "tpMake"
		tpMake.Text = ML("Make")
		tpMake.SetBounds 7, 44, 491, 282
		tpMake.Visible = True
		tpMake.UseVisualStyleBackColor = True
		tpMake.Parent = @tabProperties
		' tpCompile
		tpCompile.Name = "tpCompile"
		tpCompile.Text = ML("Compile")
		tpCompile.SetBounds 10, 0, 475, 312
		tpCompile.Visible = True
		tpCompile.UseVisualStyleBackColor = True
		tpCompile.OnClick = @tpCompile_Click
		tpCompile.Parent = @tabProperties
		' cmdOK
		cmdOK.Name = "cmdOK"
		cmdOK.Text = ML("OK")
		cmdOK.SetBounds 161, 359, 106, 34
		cmdOK.OnClick = @cmdOK_Click
		cmdOK.Default = True
		cmdOK.Parent = @This
		' cmdCancel
		cmdCancel.Name = "cmdCancel"
		cmdCancel.Text = ML("Cancel")
		cmdCancel.SetBounds 269, 359, 120, 34
		cmdCancel.OnClick = @cmdCancel_Click
		cmdCancel.Parent = @This
		' cmdHelp
		cmdHelp.Name = "cmdHelp"
		cmdHelp.Text = ML("Help")
		cmdHelp.SetBounds 391, 359, 106, 34
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
		lblMainFile.SetBounds 224, 8, 252, 18
		lblMainFile.Parent = @tpGeneral
		' cboMainFile
		cboMainFile.Name = "cboMainFile"
		cboMainFile.Text = "ComboBoxEdit11"
		cboMainFile.Sort = False
		cboMainFile.SetBounds 224, 26, 252, 21
		cboMainFile.Parent = @tpGeneral
		' lblProjectName
		lblProjectName.Name = "lblProjectName"
		lblProjectName.Text = ML("Project Name") & ":"
		lblProjectName.SetBounds 10, 124, 204, 18
		lblProjectName.Parent = @tpGeneral
		' txtProjectName
		txtProjectName.Name = "txtProjectName"
		txtProjectName.Text = ""
		txtProjectName.SetBounds 10, 142, 202, 21
		txtProjectName.Parent = @tpGeneral
		' lblProjectDescription
		lblProjectDescription.Name = "lblProjectDescription"
		lblProjectDescription.Text = ML("Project Description") & ":"
		lblProjectDescription.SetBounds 10, 240, 220, 18
		lblProjectDescription.Parent = @tpGeneral
		' txtProjectDescription
		txtProjectDescription.Name = "txtProjectDescription"
		txtProjectDescription.Text = ""
		txtProjectDescription.SetBounds 10, 258, 466, 24
		txtProjectDescription.Parent = @tpGeneral
		' grbVersionNumber
		grbVersionNumber.Name = "grbVersionNumber"
		grbVersionNumber.Text = ML("Version Number")
		grbVersionNumber.SetBounds 10, 8, 228, 122
		grbVersionNumber.Parent = @tpMake
		' grbApplication
		grbApplication.Name = "grbApplication"
		grbApplication.Text = ML("Application")
		grbApplication.SetBounds 253, 8, 225, 122
		grbApplication.Parent = @tpMake
		' grbVersionInformation
		grbVersionInformation.Name = "grbVersionInformation"
		grbVersionInformation.Text = ML("Version Information")
		grbVersionInformation.SetBounds 9, 136, 469, 171
		grbVersionInformation.Parent = @tpMake
		' grbCompilationArguments
		grbCompilationArguments.Name = "grbCompilationArguments"
		grbCompilationArguments.Text = ML("Compilation Arguments")
		grbCompilationArguments.SetBounds 10, 138, 469, 138
		grbCompilationArguments.Parent = @tpCompile
		' lblCompilationArguments64
		lblCompilationArguments64.Name = "lblCompilationArguments64"
		lblCompilationArguments64.Text = ML("For Windows") & ", " & ML("64-bit") & ":"
		lblCompilationArguments64.SetBounds 5, 30, 202, 18
		lblCompilationArguments64.Parent = @picCompilationArguments
		' lblIcon
		lblIcon.Name = "lblIcon"
		lblIcon.Text = ML("Icon") & ":"
		lblIcon.SetBounds 0, 37, 34, 18
		lblIcon.Parent = @picApplication
		' lblTitle
		lblTitle.Name = "lblTitle"
		lblTitle.Text = ML("Title") & ":"
		lblTitle.SetBounds 0, 11, 34, 18
		lblTitle.Parent = @picApplication
		' chkAutoIncrementVersion
		chkAutoIncrementVersion.Name = "chkAutoIncrementVersion"
		chkAutoIncrementVersion.Text = ML("Auto Increment Version")
		chkAutoIncrementVersion.SetBounds 6, 70, 204, 18
		chkAutoIncrementVersion.Parent = @picVersionNumber
		' lblMajor
		lblMajor.Name = "lblMajor"
		lblMajor.Text = ML("Major") & ":"
		lblMajor.SetBounds 5, 12, 52, 18
		lblMajor.Parent = @picVersionNumber
		' lblMinor
		lblMinor.Name = "lblMinor"
		lblMinor.Text = ML("Minor") & ":"
		lblMinor.SetBounds 58, 12, 52, 18
		lblMinor.Parent = @picVersionNumber
		' lblRevision
		lblRevision.Name = "lblRevision"
		lblRevision.Text = ML("Revision") & ":"
		lblRevision.SetBounds 109, 12, 48, 18
		lblRevision.BorderStyle = BorderStyles.bsNone
		lblRevision.Parent = @picVersionNumber
		' lblBuild
		lblBuild.Name = "lblBuild"
		lblBuild.Text = ML("Build") & ":"
		lblBuild.SetBounds 171, 12, 36, 18
		lblBuild.Parent = @picVersionNumber
		' cboResourceFile
		cboResourceFile.Name = "cboResourceFile"
		cboResourceFile.Text = "cboMainFile1"
		cboResourceFile.Sort = False
		cboResourceFile.SetBounds 224, 84, 252, 21
		cboResourceFile.Parent = @tpGeneral
		' lblResourceFile
		lblResourceFile.Name = "lblResourceFile"
		lblResourceFile.Text = ML("Resource File") & " (" & ML("For Windows") & "):"
		lblResourceFile.SetBounds 224, 66, 262, 18
		lblResourceFile.Parent = @tpGeneral
		' lblIconResourceFile
		lblIconResourceFile.Name = "lblIconResourceFile"
		lblIconResourceFile.Text = ML("Icon Resource File") & " (" & ML("For *nix/*bsd") & "):"
		lblIconResourceFile.SetBounds 224, 124, 262, 18
		lblIconResourceFile.Parent = @tpGeneral
		' cboIconResourceFile
		cboIconResourceFile.Name = "cboIconResourceFile"
		cboIconResourceFile.Text = "cboResourceFile1"
		cboIconResourceFile.Sort = False
		cboIconResourceFile.SetBounds 224, 142, 252, 21
		cboIconResourceFile.Parent = @tpGeneral
		' lblCompilationArguments32Linux
		lblCompilationArguments32Linux.Name = "lblCompilationArguments32Linux"
		lblCompilationArguments32Linux.Text = ML("For *nix/*bsd") & ", " & ML("32-bit") & ":"
		lblCompilationArguments32Linux.SetBounds 5, 57, 202, 18
		lblCompilationArguments32Linux.Parent = @picCompilationArguments
		' lblCompilationArguments64Linux
		lblCompilationArguments64Linux.Name = "lblCompilationArguments64Linux"
		lblCompilationArguments64Linux.Text = ML("For *nix/*bsd") & ", " & ML("64-bit") & ":"
		lblCompilationArguments64Linux.SetBounds 5, 85, 212, 18
		lblCompilationArguments64Linux.Parent = @picCompilationArguments
		' lblCompilationArguments32
		lblCompilationArguments32.Name = "lblCompilationArguments32"
		lblCompilationArguments32.Text = ML("For Windows") & ", " & ML("32-bit") & ":"
		lblCompilationArguments32.SetBounds 5, 4, 192, 18
		lblCompilationArguments32.Parent = @picCompilationArguments
		' lblType
		lblType.Name = "lblType"
		lblType.Text = ML("Type") & ":"
		lblType.SetBounds 7, 0, 82, 18
		lblType.Parent = @picVersionInformation
		' lblValue
		lblValue.Name = "lblValue"
		lblValue.Text = ML("Value") & ":"
		lblValue.SetBounds 237, 0, 136, 18
		lblValue.Parent = @picVersionInformation
		' txtHelpFileName
		txtHelpFileName.Name = "txtHelpFileName"
		txtHelpFileName.SetBounds 10, 200, 202, 21
		txtHelpFileName.Text = ""
		txtHelpFileName.Parent = @tpGeneral
		' lblHelpFileName
		lblHelpFileName.Name = "lblHelpFileName"
		lblHelpFileName.Text = ML("Help File") & ":"
		lblHelpFileName.SetBounds 10, 182, 172, 18
		lblHelpFileName.Parent = @tpGeneral
		' grbCompileToGCC
		grbCompileToGCC.Name = "grbCompileToGCC"
		grbCompileToGCC.Text = ""
		grbCompileToGCC.SetBounds 10, 35, 469, 101
		grbCompileToGCC.Parent = @tpCompile
		' optCompileToGas
		optCompileToGas.Name = "optCompileToGas"
		optCompileToGas.Text = ML("Compile to GAS")
		optCompileToGas.SetBounds 180, 15, 140, 16
		optCompileToGas.OnClick = @optCompileToGas_Click
		optCompileToGas.Parent = @tpCompile
		' optCompileToGcc
		optCompileToGcc.Name = "optCompileToGcc"
		optCompileToGcc.Text = ML("Compile to GCC")
		optCompileToGcc.SetBounds 16, 34, 132, 16
		optCompileToGcc.OnClick = @optCompileToGcc_Click
		optCompileToGcc.Parent = @tpCompile
		' tpDebugging
		tpDebugging.Name = "tpDebugging"
		tpDebugging.SetBounds 32, 22, 445, 282
		tpDebugging.UseVisualStyleBackColor = True
		tpDebugging.Visible = True
		tpDebugging.Text = ML("Debugging")
		tpDebugging.Designer = @This
		tpDebugging.OnClick = @tpDebugging_Click_
		tpDebugging.Parent = @tabProperties
		' lblCompilationArguments321
		lblCompilationArguments321.Name = "lblCompilationArguments321"
		lblCompilationArguments321.Text = ML("Command Line Arguments") & ":"
		lblCompilationArguments321.SetBounds 21, 16, 172, 18
		lblCompilationArguments321.Parent = @tpDebugging
		' txtCommandLineArguments
		txtCommandLineArguments.Name = "txtCommandLineArguments"
		txtCommandLineArguments.SetBounds 211, 14, 262, 21
		txtCommandLineArguments.Text = ""
		txtCommandLineArguments.Parent = @tpDebugging
		' picCompileToGCC
		picCompileToGCC.Name = "picCompileToGCC"
		picCompileToGCC.SetBounds 22, 51, 445, 80
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
		optOptimizationLevel.SetBounds 220, 9, 160, 16
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
		cboOptimizationLevel.SetBounds 386, 6, 56, 21
		cboOptimizationLevel.Parent = @picCompileToGCC
		cboOptimizationLevel.AddItem "0"
		cboOptimizationLevel.AddItem "1"
		cboOptimizationLevel.AddItem "2"
		cboOptimizationLevel.AddItem "3"
		' cmdAdvancedOptions
		cmdAdvancedOptions.Name = "cmdAdvancedOptions"
		cmdAdvancedOptions.Text = ML("Advanced Options") & " ..."
		cmdAdvancedOptions.SetBounds 220, 46, 224, 24
		cmdAdvancedOptions.OnClick = @cmdAdvancedOptions_Click
		cmdAdvancedOptions.Parent = @picCompileToGCC
		' txtCompilationArguments64Linux
		With txtCompilationArguments64Linux
			.Name = "txtCompilationArguments64Linux"
			.SetBounds 213, 83, 228, 21
			.Parent = @picCompilationArguments
		End With
		' txtCompilationArguments32Linux
		With txtCompilationArguments32Linux
			.Name = "txtCompilationArguments32Linux"
			.SetBounds 213, 56, 228, 21
			.Parent = @picCompilationArguments
		End With
		' txtCompilationArguments64Windows
		With txtCompilationArguments64Windows
			.Name = "txtCompilationArguments64Windows"
			.SetBounds 213, 28, 228, 21
			.Parent = @picCompilationArguments
		End With
		' txtCompilationArguments32Windows
		With txtCompilationArguments32Windows
			.Name = "txtCompilationArguments32Windows"
			.SetBounds 213, 0, 228, 21
			.Parent = @picCompilationArguments
		End With
		' lstType
		With lstType
			.Name = "lstType"
			.Text = "lstType"
			.SetBounds 7, 16, 214, 132
			.OnChange = @lstType_Change
			.Parent = @picVersionInformation
		End With
		' txtValue
		With txtValue
			.Name = "txtValue"
			.SetBounds 237, 16, 212, 122
			.OnLostFocus = @txtValue_LostFocus
			.Parent = @picVersionInformation
		End With
		' txtTitle
		With txtTitle
			.Name = "txtTitle"
			.SetBounds 40, 11, 159, 18
			.Parent = @picApplication
		End With
		' txtIcon
		With txtIcon
			.Name = "txtIcon"
			.SetBounds 40, 37, 74, 18
			.ReadOnly = False
			.Parent = @picApplication
		End With
		' txtBuild
		With txtBuild
			.Name = "txtBuild"
			.SetBounds 161, 32, 45, 21
			.Parent = @picVersionNumber
		End With
		' txtRevision
		With txtRevision
			.Name = "txtRevision"
			.SetBounds 109, 32, 45, 21
			.Parent = @picVersionNumber
		End With
		' txtMinor
		With txtMinor
			.Name = "txtMinor"
			.SetBounds 58, 32, 45, 21
			.Parent = @picVersionNumber
		End With
		' txtMajor
		With txtMajor
			.Name = "txtMajor"
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
			.SetBounds 16, 20, 212, 90
			.Parent = @tpMake
		End With
		' picVersionInformation
		With picApplication
			.Name = "picApplication"
			.SetBounds 262, 20, 202, 100
			.Parent = @tpMake
		End With
		' picVersionInformation
		With picVersionInformation
			.Name = "picVersionInformation"
			.SetBounds 16, 155, 450, 141
			.Parent = @tpMake
		End With
		' picCompilationArguments
		With picCompilationArguments
			.Name = "picCompilationArguments"
			.SetBounds 24, 156, 445, 113
			.Text = ""
			.Parent = @tpCompile
		End With
		' optCompileByDefault
		With optCompileByDefault
			.Name = "optCompileByDefault"
			.Text = ML("Compile by default")
			.TabIndex = 69
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
			.TabIndex = 70
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
			.TabIndex = 70
			.SetBounds 114, 36, 20, 20
			.Caption = "..."
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
			.TabIndex = 71
			.SetBounds 225, 200, 252, 22
			'.Caption = ML("Pass All Module Files To Compiler")
			.Parent = @tpGeneral
		End With
		' cboSubsystem
		With cboSubsystem
			.Name = "cboSubsystem"
			.Text = "cboSubsystem"
			.TabIndex = 72
			.SetBounds 10, 84, 202, 21
			.Parent = @tpGeneral
		End With
		' lblSubsystem
		With lblSubsystem
			.Name = "lblSubsystem"
			.Text = ML("Subsystem") & " (" & ML("For Windows") & "):"
			.TabIndex = 73
			.SetBounds 10, 66, 202, 18
			'.Caption = ML("Subsystem") & " (" & ML("For Windows") & "):"
			.Parent = @tpGeneral
		End With
		' tpAndroidSettings
		With tpAndroidSettings
			.Name = "tpAndroidSettings"
			.Text = ML("Android Settings")
			.TabIndex = 75
			.UseVisualStyleBackColor = True
			.Caption = ML("Android Settings")
			.SetBounds 0, 0, 487, 316
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
			.TabIndex = 78
			.Caption = ML("Android SDK location")
			.SetBounds 12, 12, 260, 20
			.Parent = @tpAndroidSettings
		End With
		' lblAndroidNDKLocation
		With lblAndroidNDKLocation
			.Name = "lblAndroidNDKLocation"
			.Text = ML("Android NDK location")
			.TabIndex = 79
			.Caption = ML("Android NDK location")
			.SetBounds 12, 72, 260, 20
			.Parent = @tpAndroidSettings
		End With
		' txtAndroidNDKLocation
		With txtAndroidNDKLocation
			.Name = "txtAndroidNDKLocation"
			.TabIndex = 80
			.Text = ""
			.SetBounds 12, 92, 430, 20
			.Parent = @tpAndroidSettings
		End With
		' cmdAndroidNDKLocation
		With cmdAndroidNDKLocation
			.Name = "cmdAndroidNDKLocation"
			.Text = "..."
			.TabIndex = 81
			.SetBounds 450, 91, 25, 22
			.Designer = @This
			.OnClick = @cmdAndroidNDKLocation_Click_
			.Parent = @tpAndroidSettings
		End With
		' lblJDKLocation
		With lblJDKLocation
			.Name = "lblJDKLocation"
			.Text = ML("JDK location")
			.TabIndex = 82
			.Caption = ML("JDK location")
			.SetBounds 12, 132, 260, 20
			.Parent = @tpAndroidSettings
		End With
		' txtJDKLocation
		With txtJDKLocation
			.Name = "txtJDKLocation"
			.TabIndex = 83
			.Text = ""
			.SetBounds 12, 152, 430, 20
			.Parent = @tpAndroidSettings
		End With
		' cmdJDKLocation
		With cmdJDKLocation
			.Name = "cmdJDKLocation"
			.Text = "..."
			.TabIndex = 84
			.SetBounds 450, 151, 25, 22
			.Designer = @This
			.OnClick = @cmdJDKLocation_Click_
			.Parent = @tpAndroidSettings
		End With
		' BrowseD
		With BrowseD
			.Name = "BrowseD"
			.SetBounds 60, 370, 16, 16
			.Parent = @This
		End With
		' OpenD
		With OpenD
			.Name = "OpenD"
			.SetBounds 80, 370, 16, 16
			.Parent = @This
		End With
		' lblCompiler
		With lblCompiler
			.Name = "lblCompiler"
			.Text = ML("Compiler") & ":"
			.TabIndex = 86
			.Caption = ML("Compiler") & ":"
			.SetBounds 29, 288, 90, 20
			.Parent = @tpCompile
		End With
		' cboCompiler
		With cboCompiler
			.Name = "cboCompiler"
			.Text = "ComboBoxEdit1"
			.TabIndex = 84
			.SetBounds 102, 285, 126, 21
			.Designer = @This
			.OnSelected = @cboCompiler_Selected_
			.Parent = @tpCompile
		End With
		' txtCompilerPath
		With txtCompilerPath
			.Name = "txtCompilerPath"
			.Text = ""
			.TabIndex = 85
			.SetBounds 236, 285, 198, 20
			.Designer = @This
			.OnChange = @txtCompilerPath_Change_
			.Parent = @tpCompile
		End With
		' cmdCompiler
		With cmdCompiler
			.Name = "cmdCompiler"
			.Text = "..."
			.TabIndex = 87
			.SetBounds 441, 284, 25, 22
			.Designer = @This
			.OnClick = @cmdCompiler_Click_
			.Parent = @tpCompile
		End With
		' chkManifest
		With chkManifest
			.Name = "chkManifest"
			.Text = ML("Manifest")
			.TabIndex = 88
			.Caption = ML("Manifest")
			.SetBounds 4, 59, 130, 20
			.Designer = @This
			.OnClick = @chkManifest_Click_
			.Parent = @picApplication
		End With
		' chkRunAsAdministrator
		With chkRunAsAdministrator
			.Name = "chkRunAsAdministrator"
			.Text = ML("Run as administrator")
			.TabIndex = 89
			.Caption = ML("Run as administrator")
			.SetBounds 30, 80, 170, 20
			.Designer = @This
			.Parent = @picApplication
		End With
	End Constructor
	
	Private Sub frmProjectProperties.chkManifest_Click_(ByRef Sender As CheckBox)
		*Cast(frmProjectProperties Ptr, Sender.Designer).chkManifest_Click(Sender)
	End Sub
	
Private Sub frmProjectProperties.cboCompiler_Selected_(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	*Cast(frmProjectProperties Ptr, Sender.Designer).cboCompiler_Selected(Sender, ItemIndex)
End Sub

Private Sub frmProjectProperties.txtCompilerPath_Change_(ByRef Sender As TextBox)
	*Cast(frmProjectProperties Ptr, Sender.Designer).txtCompilerPath_Change(Sender)
End Sub

Private Sub frmProjectProperties.cmdCompiler_Click_(ByRef Sender As Control)
	*Cast(frmProjectProperties Ptr, Sender.Designer).cmdCompiler_Click(Sender)
End Sub

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
			ppe = New_( ProjectElement)
			WLet(ppe->FileName, "")
		End If
		WLet(ppe->MainFileName, .MainFiles.Get(.cboMainFile.Text))
		WLet(ppe->ResourceFileName, .ResourceFiles.Get(.cboResourceFile.Text))
		WLet(ppe->IconResourceFileName, .IconResourceFiles.Get(.cboIconResourceFile.Text))
		ppe->ProjectType = .cboProjectType.ItemIndex
		ppe->Subsystem = .cboSubsystem.ItemIndex
		WLet(ppe->ProjectName, .txtProjectName.Text)
		WLet(ppe->HelpFileName, .txtHelpFileName.Text)
		WLet(ppe->ProjectDescription, .txtProjectDescription.Text)
		ppe->PassAllModuleFilesToCompiler = .chkPassAllModuleFilesToCompiler.Checked
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
		Case .optCompileToGAS.Checked: ppe->CompileTo = ToGAS
		Case .optCompileToLLVM.Checked: ppe->CompileTo = ToLLVM
		Case .optCompileToGCC.Checked: ppe->CompileTo = ToGCC
		End Select
		ppe->OptimizationFastCode = .optOptimizationFastCode.Checked
		ppe->OptimizationSmallCode = .optOptimizationSmallCode.Checked
		ppe->OptimizationLevel = IIf(.optOptimizationLevel.Checked, Val(.cboOptimizationLevel.Text), 0)
		WLet(ppe->CompilationArguments32Windows, .txtCompilationArguments32Windows.Text)
		WLet(ppe->CompilationArguments64Windows, .txtCompilationArguments64Windows.Text)
		WLet(ppe->CompilationArguments32Linux, .txtCompilationArguments32Linux.Text)
		WLet(ppe->CompilationArguments64Linux, .txtCompilationArguments64Linux.Text)
		WLet(ppe->CompilerPath, .txtCompilerPath.Text)
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
			WReallocate(pBuff, FileSize)
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
			WReallocate(pBuff, FileSize)
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
			If ptn->ImageKey = "Project" AndAlso (EndsWith(ptn->Text, ".vfp") OrElse EndsWith(ptn->Text, "*")) Then
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
				.txtProjectName.Text = *ppe->ProjectName
				.txtHelpFileName.Text = *ppe->HelpFileName
				.txtProjectDescription.Text = *ppe->ProjectDescription
				.chkPassAllModuleFilesToCompiler.Checked = ppe->PassAllModuleFilesToCompiler
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
				.optCompileToGAS.Checked = False
				.optCompileToLLVM.Checked = False
				.optCompileToGCC.Checked = False
				Select Case ppe->CompileTo
				Case ByDefault: .optCompileByDefault.Checked = True
				Case ToGAS: .optCompileToGAS.Checked = True
				Case ToLLVM: .optCompileToLLVM.Checked = True
				Case ToGCC: .optCompileToGCC.Checked = True
				End Select
				.optCompileToGas_Click(.optCompileToGas)
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
					WReallocate(pBuff, FileSize)
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
					WReallocate(pBuff, FileSize)
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
			.txtProjectName.Text = ""
			.txtHelpFileName.Text = ""
			.txtProjectDescription.Text = ""
			.chkPassAllModuleFilesToCompiler.Checked = False
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
		.ShowModal *pfrmMain
	End With
End Sub

Private Sub frmProjectProperties.Form_Show(ByRef Sender As Form)
	fProjectProperties.cboCompiler.Clear
	fProjectProperties.cboCompiler.AddItem ML("Default")
	For i As Integer = 0 To pCompilers->Count - 1
		fProjectProperties.cboCompiler.AddItem pCompilers->Item(i)->Key
	Next
	fProjectProperties.cboCompiler.AddItem ML("Custom")
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
		.cmdAdvancedOptions.Enabled = .optCompileToGcc.Checked
	End With
End Sub

Private Sub frmProjectProperties.optCompileToGcc_Click(ByRef Sender As RadioButton)
	frmProjectProperties.optCompileToGas_Click Sender
End Sub


Private Sub frmProjectProperties.optCompileByDefault_Click_(ByRef Sender As RadioButton)
	*Cast(frmProjectProperties Ptr, Sender.Designer).optCompileByDefault_Click(Sender)
End Sub
Private Sub frmProjectProperties.optCompileByDefault_Click(ByRef Sender As RadioButton)
	frmProjectProperties.optCompileToGas_Click Sender
End Sub

Private Sub frmProjectProperties.optCompileToLLVM_Click_(ByRef Sender As RadioButton)
	*Cast(frmProjectProperties Ptr, Sender.Designer).optCompileToLLVM_Click(Sender)
End Sub
Private Sub frmProjectProperties.optCompileToLLVM_Click(ByRef Sender As RadioButton)
	frmProjectProperties.optCompileToGas_Click Sender
End Sub

Private Sub frmProjectProperties.CommandButton1_Click_(ByRef Sender As Control)
	*Cast(frmProjectProperties Ptr, Sender.Designer).CommandButton1_Click(Sender)
End Sub
Private Sub frmProjectProperties.CommandButton1_Click(ByRef Sender As Control)
	pfImageManager->OnlyIcons = True
	pfImageManager->WithoutMainNode = True
	If pfImageManager->ShowModal(*pfrmMain) = ModalResults.OK Then
		If pfImageManager->lvImages.SelectedItem <> 0 Then
			txtIcon.Text = pfImageManager->lvImages.SelectedItem->Text(0)
			'#ifdef __USE_GTK__
				imgIcon.Graphic.Icon.LoadFromFile(GetRelativePath(pfImageManager->lvImages.SelectedItem->Text(2), pfImageManager->ResourceFile), 32, 32)
			'#else
			'	DrawIconEx GetDC(picApplication.Handle), 0, 0, imgIcon.Graphic.Icon.Handle, 32, 32, 0, 0, DI_NORMAL
			'#endif
		End If
	End If
	pfImageManager->WithoutMainNode = False
End Sub

Private Sub frmProjectProperties.tpDebugging_Click_(ByRef Sender As Control)
	*Cast(frmProjectProperties Ptr, Sender.Designer).tpDebugging_Click(Sender)
End Sub
Private Sub frmProjectProperties.tpDebugging_Click(ByRef Sender As Control)
	
End Sub

Private Sub frmProjectProperties.cmdAndroidSDKLocation_Click_(ByRef Sender As Control)
	*Cast(frmProjectProperties Ptr, Sender.Designer).cmdAndroidSDKLocation_Click(Sender)
End Sub
Private Sub frmProjectProperties.cmdAndroidSDKLocation_Click(ByRef Sender As Control)
	BrowseD.InitialDir = txtAndroidSDKLocation.Text
	If BrowseD.Execute Then
		txtAndroidSDKLocation.Text = BrowseD.Directory
	End If
End Sub

Private Sub frmProjectProperties.cmdAndroidNDKLocation_Click_(ByRef Sender As Control)
	*Cast(frmProjectProperties Ptr, Sender.Designer).cmdAndroidNDKLocation_Click(Sender)
End Sub
Private Sub frmProjectProperties.cmdAndroidNDKLocation_Click(ByRef Sender As Control)
	BrowseD.InitialDir = txtAndroidNDKLocation.Text
	If BrowseD.Execute Then
		txtAndroidNDKLocation.Text = BrowseD.Directory
	End If
End Sub

Private Sub frmProjectProperties.cmdJDKLocation_Click_(ByRef Sender As Control)
	*Cast(frmProjectProperties Ptr, Sender.Designer).cmdJDKLocation_Click(Sender)
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
