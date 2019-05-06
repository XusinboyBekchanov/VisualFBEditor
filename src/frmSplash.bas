'#########################################################
'#  frmSplash.bas                                        #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (2018-2019)              #
'#########################################################

#Include Once "mff\Form.bi"
#Include Once "mff\Label.bi"
#Include Once "mff\ImageBox.bi"

Using My.Sys.Forms

'#Region "Form"
    Type frmSplash Extends Form
        Declare Static Sub Form_Size(ByRef Sender As Form)
        Declare Static Sub Form_Show(ByRef Sender As Form)
        Declare Static Sub Form_Create(ByRef Sender As Control)
        Declare Constructor
        
        Dim As ImageBox lblImage
        Dim As Label lblSplash, lblInfo
    End Type

    Constructor frmSplash
        ' lblImage
        lblImage.Name = "lblImage"
        'lblImage.Graphic.Bitmap.LoadFromResourceName("Logo")
        #IfDef __USE_GTK__
        	lblImage.Graphic.Bitmap.LoadFromFile(ExePath & "/Resources/Logo.png")
        #Else
        	lblImage.Graphic.Bitmap = "Logo"
        #EndIf
        lblImage.SetBounds 12, 24, 334, 262
        lblImage.Parent = @This
        ' lblSplash
        lblSplash.SetBounds 14, 6, 294, 36
        lblSplash.Text = "Visual FB Editor " & App.GetVerInfo("ProductVersion")
        lblSplash.Font.Name = "Times New Roman"
        lblSplash.Font.Size = 20
        lblSplash.Font.Bold = True
        lblSplash.Font.Italic = True
        lblSplash.BackColor = 0
        lblSplash.Font.Color = 16777215
        lblSplash.Parent = @This
        
        This.Text = "Visual FB Editor"
        This.OnCreate = @Form_Create
        This.BackColor = 0
        This.SetBounds 0, 0, 370, 346
        This.BorderStyle = 0
        This.Center
        'lblIcon.Graphic.Icon = 100
        ' lblInfo
        lblInfo.Name = "lblInfo"
        lblInfo.Text = "2018-2019"
        lblInfo.SetBounds 18, 282, 282, 18
        lblInfo.BackColor = 0
        lblInfo.Font.Color = 16777215
        lblInfo.Parent = @This
    End Constructor
    
    #IfnDef _NOT_AUTORUN_FORMS_
        Dim frm As frmSplash
        frm.Show
    
        App.Run
    #EndIf
'#End Region

Private Sub frmSplash.Form_Create(ByRef Sender As Control)
    With *Cast(frmSplash Ptr, @Sender)
        '.Panel1.SetBounds 6, 6, .Width - 12, .Height - 12
    End With
End Sub
