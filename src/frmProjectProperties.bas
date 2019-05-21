'#########################################################
'#  frmProjectProperties.bas                             #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (2018-2019)              #
'#########################################################

#Include Once "mff/Form.bi"
#Include Once "mff/TabControl.bi"
#Include Once "mff/CommandButton.bi"
#Include Once "mff/Label.bi"
#Include Once "mff/ComboBoxEdit.bi"
#Include Once "mff/TextBox.bi"
#Include Once "mff/GroupBox.bi"
#Include Once "mff/Panel.bi"
#Include Once "mff/CheckBox.bi"
#Include Once "mff/ImageBox.bi"

Using My.Sys.Forms

'#Region "Form"
    Type frmProjectProperties Extends Form
        Declare Static Sub cmdOK_Click(ByRef Sender As Control)
        Declare Static Sub cmdCancel_Click(ByRef Sender As Control)
        Declare Static Sub pnlApplication_Click(ByRef Sender As Control)
        Declare Static Sub Form_Create(ByRef Sender As Control)
        Declare Static Sub Form_Show(ByRef Sender As Form)
        Declare Static Sub cboMainFile_Change(BYREF Sender As ComboBoxEdit)
        Declare Constructor
        
        Dim As TabControl tabProperties
        Dim As TabPage tpGeneral, tpMake, tpCompile
        Dim As CommandButton cmdOK, cmdCancel, cmdHelp
        Dim As Label lblProjectType, lblMainFile, lblProjectName, lblProjectDescription, lblCompilationArguments32, lblCompilationArguments64, lblIcon, lblTitle, lblMajor, lblMinor, lblRevision, lblBuild, lblResourceFile
        Dim As ComboBoxEdit cboProjectType, cboMainFile, cboResourceFile
        Dim As TextBox txtProjectName, txtProjectDescription, txtCompilationArguments32, txtCompilationArguments64, txtIcon, txtTitle, txtMajor, txtMinor, txtRevision, txtBuild
        Dim As GroupBox grbVersionNumber, grbApplication, grbVersionInformation
        Dim As CheckBox chkAutoIncrementVersion
    End Type
    
    Constructor frmProjectProperties
        ' frmProjectProperties
        This.Name = "frmProjectProperties"
        This.Text = "Project Properties"
        This.BorderStyle = FormBorderStyle.Fixed3D
        This.MaximizeBox = false
        This.MinimizeBox = false
        This.Caption = "Project Properties"
        This.OnCreate = @Form_Create
        This.OnShow = @Form_Show
        This.SetBounds 0, 0, 428, 306
        ' tabProperties
        tabProperties.Name = "tabProperties"
        tabProperties.Text = "TabControl1"
        tabProperties.SetBounds 6, 6, 411, 235
        tabProperties.Parent = @This
        ' tpGeneral
        tpGeneral.Name = "tpGeneral"
        tpGeneral.Text = "General"
        tpGeneral.SetBounds 0, 0, 327, 210
        tpGeneral.UseVisualStyleBackColor = True
        tpGeneral.Parent = @tabProperties
        ' tpMake
        tpMake.Name = "tpMake"
        tpMake.Text = "Make"
        tpMake.SetBounds 0, 0, 327, 210
        tpMake.Visible = true
        tpMake.UseVisualStyleBackColor = True
        tpMake.Parent = @tabProperties
        ' tpCompile
        tpCompile.Name = "tpCompile"
        tpCompile.Text = "Compile"
        tpCompile.SetBounds 104, 40, 405, 210
        tpCompile.Visible = true
        tpCompile.UseVisualStyleBackColor = True
        tpCompile.Parent = @tabProperties
        ' cmdOK
        cmdOK.Name = "cmdOK"
        cmdOK.Text = "OK"
        cmdOK.SetBounds 186, 246, 73, 24
        cmdOK.Caption = "OK"
        cmdOK.OnClick = @cmdOK_Click
        cmdOK.Parent = @This
        ' cmdCancel
        cmdCancel.Name = "cmdCancel"
        cmdCancel.Text = "Cancel"
        cmdCancel.SetBounds 264, 246, 73, 24
        cmdCancel.Caption = "Cancel"
        cmdCancel.OnClick = @cmdCancel_Click
        cmdCancel.Parent = @This
        ' cmdHelp
        cmdHelp.Name = "cmdHelp"
        cmdHelp.Text = "Help"
        cmdHelp.SetBounds 342, 246, 73, 24
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
        cboProjectType.SetBounds 10, 26, 186, 21
        cboProjectType.Parent = @tpGeneral
        ' lblMainFile
        lblMainFile.Name = "lblMainFile"
        lblMainFile.Text = "Main File:"
        lblMainFile.SetBounds 208, 8, 72, 18
        lblMainFile.Caption = "Main File:"
        lblMainFile.Parent = @tpGeneral
        ' cboMainFile
        cboMainFile.Name = "cboMainFile"
        cboMainFile.Text = "ComboBoxEdit11"
        cboMainFile.SetBounds 208, 26, 186, 21
        cboMainFile.OnChange = @cboMainFile_Change
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
        txtProjectName.SetBounds 10, 74, 186, 21
        txtProjectName.Parent = @tpGeneral
        ' lblProjectDescription
        lblProjectDescription.Name = "lblProjectDescription"
        lblProjectDescription.Text = "Project Description:"
        lblProjectDescription.SetBounds 10, 104, 132, 18
        lblProjectDescription.Caption = "Project Description:"
        lblProjectDescription.Parent = @tpGeneral
        ' txtProjectDescription
        txtProjectDescription.Name = "txtProjectDescription"
        txtProjectDescription.Text = ""
        txtProjectDescription.SetBounds 10, 122, 384, 21
        txtProjectDescription.Parent = @tpGeneral
        ' grbVersionNumber
        grbVersionNumber.Name = "grbVersionNumber"
        grbVersionNumber.Text = "Version Number"
        grbVersionNumber.SetBounds 10, 8, 189, 102
        grbVersionNumber.Parent = @tpMake
        ' grbApplication
        grbApplication.Name = "grbApplication"
        grbApplication.Text = "Application"
        grbApplication.SetBounds 208, 8, 187, 102
        grbApplication.Parent = @tpMake
        ' grbVersionInformation
        grbVersionInformation.Name = "grbVersionInformation"
        grbVersionInformation.Text = "Version Information"
        grbVersionInformation.SetBounds 9, 113, 387, 89
        grbVersionInformation.Parent = @tpMake
        ' lblCompilationArguments32
        lblCompilationArguments32.Name = "lblCompilationArguments32"
        lblCompilationArguments32.Caption = "Compilation Arguments (32-bit)"
        lblCompilationArguments32.SetBounds 13, 14, 168, 18
        lblCompilationArguments32.Text = "Compilation Arguments (32-bit)"
        lblCompilationArguments32.Parent = @tpCompile
        ' txtCompilationArguments32
        txtCompilationArguments32.Name = "txtCompilationArguments32"
        txtCompilationArguments32.Text = ""
        txtCompilationArguments32.SetBounds 189, 11, 204, 21
        txtCompilationArguments32.Parent = @tpCompile
        ' lblCompilationArguments64
        lblCompilationArguments64.Name = "lblCompilationArguments64"
        lblCompilationArguments64.Text = "Compilation Arguments (64-bit)"
        lblCompilationArguments64.SetBounds 14, 44, 168, 18
        lblCompilationArguments64.Caption = "Compilation Arguments (64-bit)"
        lblCompilationArguments64.Parent = @tpCompile
        ' txtCompilationArguments64
        txtCompilationArguments64.Name = "txtCompilationArguments64"
        txtCompilationArguments64.SetBounds 189, 41, 204, 21
        txtCompilationArguments64.Text = ""
        txtCompilationArguments64.Parent = @tpCompile
        ' txtIcon
        txtIcon.Name = "txtIcon"
        txtIcon.SetBounds 50, 48, 72, 18
        txtIcon.Parent = @grbApplication
        ' txtTitle
        txtTitle.Name = "txtTitle"
        txtTitle.SetBounds 50, 24, 126, 18
        txtTitle.Parent = @grbApplication
        ' lblIcon
        lblIcon.Name = "lblIcon"
        lblIcon.Text = "Icon:"
        lblIcon.SetBounds 6, 50, 42, 18
        lblIcon.Caption = "Icon:"
        lblIcon.Parent = @grbApplication
        ' lblTitle
        lblTitle.Name = "lblTitle"
        lblTitle.Text = "Title:"
        lblTitle.SetBounds 6, 26, 42, 18
        lblTitle.Caption = "Title:"
        lblTitle.Parent = @grbApplication
        ' chkAutoIncrementVersion
        chkAutoIncrementVersion.Name = "chkAutoIncrementVersion"
        chkAutoIncrementVersion.Text = "Auto Increment Version"
        chkAutoIncrementVersion.SetBounds 10, 69, 156, 18
        chkAutoIncrementVersion.Caption = "Auto Increment Version"
        chkAutoIncrementVersion.Parent = @grbVersionNumber
        ' txtMajor
        txtMajor.Name = "txtMajor"
        txtMajor.Text = "txtMajor"
        txtMajor.SetBounds 10, 40, 36, 21
        txtMajor.Parent = @grbVersionNumber
        ' txtMinor
        txtMinor.Name = "txtMinor"
        txtMinor.Text = "txtMinor"
        txtMinor.SetBounds 52, 40, 36, 21
        txtMinor.Parent = @grbVersionNumber
        ' txtRevision
        txtRevision.Name = "txtRevision"
        txtRevision.Text = "txtRevision"
        txtRevision.SetBounds 94, 40, 36, 21
        txtRevision.Parent = @grbVersionNumber
        ' txtBuild
        txtBuild.Name = "txtBuild"
        txtBuild.Text = "txtBuild"
        txtBuild.SetBounds 136, 40, 36, 21
        txtBuild.Parent = @grbVersionNumber
        ' lblMajor
        lblMajor.Name = "lblMajor"
        lblMajor.Text = "Major:"
        lblMajor.SetBounds 10, 20, 42, 18
        lblMajor.Caption = "Major:"
        lblMajor.Parent = @grbVersionNumber
        ' lblMinor
        lblMinor.Name = "lblMinor"
        lblMinor.Text = "Minor:"
        lblMinor.SetBounds 52, 20, 42, 18
        lblMinor.Caption = "Minor:"
        lblMinor.Parent = @grbVersionNumber
        ' lblRevision
        lblRevision.Name = "lblRevision"
        lblRevision.Text = "Revision:"
        lblRevision.SetBounds 94, 20, 48, 18
        lblRevision.Caption = "Revision:"
        lblRevision.Parent = @grbVersionNumber
        ' lblBuild
        lblBuild.Name = "lblBuild"
        lblBuild.Text = "Build:"
        lblBuild.SetBounds 148, 20, 36, 18
        lblBuild.Caption = "Build:"
        lblBuild.Parent = @grbVersionNumber
        ' cboResourceFile
        cboResourceFile.Name = "cboResourceFile"
        cboResourceFile.Text = "cboMainFile1"
        cboResourceFile.SetBounds 208, 74, 186, 21
        cboResourceFile.Parent = @tpGeneral
        ' lblResourceFile
        lblResourceFile.Name = "lblResourceFile"
        lblResourceFile.Text = "Resource File:"
        lblResourceFile.SetBounds 208, 56, 96, 18
        lblResourceFile.Caption = "Resource File:"
        lblResourceFile.Parent = @tpGeneral
    End Constructor
    
    Dim Shared fProjectProperties As frmProjectProperties
    
    #IfnDef _NOT_AUTORUN_FORMS_
        fForm1.Show
        
        App.Run
    #EndIf
'#End Region


Private Sub frmProjectProperties.cmdOK_Click(ByRef Sender As Control)
	fProjectProperties.CloseForm
End Sub

Private Sub frmProjectProperties.cmdCancel_Click(ByRef Sender As Control)
	fProjectProperties.CloseForm
End Sub

Private Sub frmProjectProperties.pnlApplication_Click(ByRef Sender As Control)
	
End Sub

Private Sub frmProjectProperties.Form_Create(ByRef Sender As Control)
	With fProjectProperties
		.cboProjectType.AddItem "Executable"
		.cboProjectType.AddItem "Dynamic library"
		.cboProjectType.AddItem "Static library"
	End With
End Sub

Private Sub frmProjectProperties.Form_Show(ByRef Sender As Form)
	With fProjectProperties
		.cboMainFile.Items.Add "Executable"
		.cboProjectType.Items.Add "Dynamic library"
		.cboProjectType.Items.Add "Static library"
	End With
End Sub

Private Sub frmProjectProperties.cboMainFile_Change(BYREF Sender As ComboBoxEdit)
	
End Sub
