'#Compile -exx "Form1.rc"
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
        Declare Static Sub pnlVersionNumber_Click(ByRef Sender As Control)
        Declare Static Sub lblTitle_Click(BYREF Sender As Label)
        Declare Static Sub grbVersionNumber_Click(BYREF Sender As GroupBox)
        Declare Constructor
        
        Dim As TabControl tabProperties
        Dim As TabPage tpGeneral, tpMake, tpCompile
        Dim As CommandButton cmdOK, cmdCancel, cmdHelp
        Dim As Label lblProjectType, lblMainFile, lblProjectName, lblProjectDescription, lblMajor, lblMinor, lblRevision, lblBuild, lblTitle, lblIcon, lblCompilationArguments32, lblCompilationArguments64
        Dim As ComboBoxEdit cboProjectType, cboMainFile
        Dim As TextBox txtProjectName, txtProjectDescription, txtMajor, txtMinor, txtRevision, txtBuild, txtTitle, txtIcon, txtCompilationArguments32, txtCompilationArguments64
        Dim As GroupBox grbVersionNumber, grbApplication, grbVersionInformation
        Dim As Panel pnlVersionNumber, pnlApplication
        Dim As CheckBox chkAutoIncrementVersion
        Dim As ImageBox imbIcon
    End Type
    
    Constructor frmProjectProperties
        ' frmProjectProperties
        This.Name = "frmProjectProperties"
        This.Text = "Project Properties"
        This.BorderStyle = FormBorderStyle.Fixed3D
        This.MaximizeBox = false
        This.MinimizeBox = false
        This.Caption = "Project Properties"
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
        tpGeneral.Parent = @tabProperties
        ' tpMake
        tpMake.Name = "tpMake"
        tpMake.Text = "Make"
        tpMake.SetBounds 0, 0, 327, 210
        tpMake.Visible = true
        tpMake.Parent = @tabProperties
        ' tpCompile
        tpCompile.Name = "tpCompile"
        tpCompile.Text = "Compile"
        tpCompile.SetBounds 20, 40, 405, 210
        tpCompile.Visible = true
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
        grbVersionNumber.OnClick = @grbVersionNumber_Click
        grbVersionNumber.Parent = @tpMake
        ' lblMajor
        lblMajor.Name = "lblMajor"
        lblMajor.Text = "Major:"
        lblMajor.SetBounds 0, 0, 42, 18
        lblMajor.Caption = "Major:"
        lblMajor.Parent = @pnlVersionNumber
        ' lblMinor
        lblMinor.Name = "lblMinor"
        lblMinor.Text = "Minor:"
        lblMinor.SetBounds 42, 0, 42, 18
        lblMinor.Caption = "Minor:"
        lblMinor.Parent = @pnlVersionNumber
        ' lblRevision
        lblRevision.Name = "lblRevision"
        lblRevision.Text = "Revision:"
        lblRevision.SetBounds 84, 0, 48, 18
        lblRevision.Caption = "Revision:"
        lblRevision.Parent = @pnlVersionNumber
        ' pnlVersionNumber
        pnlVersionNumber.Name = "pnlVersionNumber"
        pnlVersionNumber.Text = ""
        pnlVersionNumber.SetBounds 24, 30, 168, 72
        pnlVersionNumber.OnClick = @pnlVersionNumber_Click
        pnlVersionNumber.Parent = @tpMake
        ' lblBuild
        lblBuild.Name = "lblBuild"
        lblBuild.Text = "Build:"
        lblBuild.SetBounds 138, 0, 36, 18
        lblBuild.Caption = "Build:"
        lblBuild.Parent = @pnlVersionNumber
        ' txtMajor
        txtMajor.Name = "txtMajor"
        txtMajor.Text = "0"
        txtMajor.SetBounds 0, 20, 36, 21
        txtMajor.Parent = @pnlVersionNumber
        ' txtMinor
        txtMinor.Name = "txtMinor"
        txtMinor.Text = "0"
        txtMinor.SetBounds 42, 20, 36, 21
        txtMinor.Parent = @pnlVersionNumber
        ' txtRevision
        txtRevision.Name = "txtRevision"
        txtRevision.Text = "0"
        txtRevision.SetBounds 84, 20, 36, 21
        txtRevision.Parent = @pnlVersionNumber
        ' txtBuild
        txtBuild.Name = "txtBuild"
        txtBuild.Text = "0"
        txtBuild.SetBounds 126, 20, 36, 21
        txtBuild.Parent = @pnlVersionNumber
        ' chkAutoIncrementVersion
        chkAutoIncrementVersion.Name = "chkAutoIncrementVersion"
        chkAutoIncrementVersion.Text = "Auto Increment Version"
        chkAutoIncrementVersion.SetBounds 0, 49, 156, 18
        chkAutoIncrementVersion.Caption = "Auto Increment Version"
        chkAutoIncrementVersion.Parent = @pnlVersionNumber
        ' grbApplication
        grbApplication.Name = "grbApplication"
        grbApplication.Text = "Application"
        grbApplication.SetBounds 208, 8, 187, 102
        grbApplication.Parent = @tpMake
        ' lblTitle
        lblTitle.Name = "lblTitle"
        lblTitle.Text = "Title:"
        lblTitle.SetBounds 6, 6, 42, 18
        lblTitle.Caption = "Title:"
        lblTitle.OnClick = @lblTitle_Click
        lblTitle.Parent = @pnlApplication
        ' pnlApplication
        pnlApplication.Name = "pnlApplication"
        pnlApplication.SetBounds 216, 30, 168, 72
        pnlApplication.Parent = @tpMake
        ' txtTitle
        txtTitle.Name = "txtTitle"
        txtTitle.Text = ""
        txtTitle.SetBounds 40, 4, 126, 18
        txtTitle.Parent = @pnlApplication
        ' lblIcon
        lblIcon.Name = "lblIcon"
        lblIcon.Text = "Icon:"
        lblIcon.SetBounds 6, 30, 42, 18
        lblIcon.Caption = "Icon:"
        lblIcon.Parent = @pnlApplication
        ' txtIcon
        txtIcon.Name = "txtIcon"
        txtIcon.SetBounds 40, 28, 72, 18
        txtIcon.Text = ""
        txtIcon.Parent = @pnlApplication
        ' imbIcon
        imbIcon.Name = "imbIcon"
        imbIcon.Text = ""
        imbIcon.SetBounds 118, 26, 42, 36
        imbIcon.Graphic.Icon.ResName = "VisualFBEditor"
        imbIcon.Parent = @pnlApplication
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
