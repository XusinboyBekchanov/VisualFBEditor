'#Compile -exx "Form1.rc"
#Include Once "mff/Form.bi"

Using My.Sys.Forms

'#Region "Form"
    Type Form1 Extends Form
        
    End Type
    
    Dim Shared fForm1 As Form1
    
    #IfnDef _NOT_AUTORUN_FORMS_
        fForm1.Show
        
        App.Run
    #EndIf
'#End Region

