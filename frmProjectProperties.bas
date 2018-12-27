'#Compile -exx "Form1.rc"
#Include Once "mff\Form.bi"
#Include Once "mff\TabControl.bi"

Using My.Sys.Forms

'#Region "Form"
    Type frmProjectProperties Extends Form
        Declare Constructor
        
        Dim As TabControl TabControl1
    End Type
    
    Constructor frmProjectProperties
        ' frmProjectProperties
        This.Name = "frmProjectProperties"
        This.Text = "Project properties"
        This.BorderStyle = FormBorderStyle.Fixed3D
        This.MaximizeBox = false
        This.MinimizeBox = false
        This.SetBounds 0, 0, 350, 300
        ' TabControl1
        TabControl1.Name = "TabControl1"
        TabControl1.Text = "TabControl1"
        TabControl1.SetBounds 6, 6, 336, 234
        TabControl1.Parent = @This
    End Constructor
    
    Dim Shared fForm1 As frmProjectProperties
    
    #IfnDef _NOT_AUTORUN_FORMS_
        fForm1.Show
        
        App.Run
    #EndIf
'#End Region

