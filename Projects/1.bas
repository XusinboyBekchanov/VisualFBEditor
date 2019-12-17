'#Compile -exx "Form1.rc"
#include once "mff/Form.bi"
#include once "mff/CheckBox.bi"
#Include Once "mff/CommandButton.bi"

Using My.Sys.Forms

'#Region "Form"
    Type Form1 Extends Form
    	Declare Static Sub CommandButton1_Click(ByRef Sender As Control)
    	Declare Constructor
        
    	Dim As CheckBox CheckBox1
    	Dim As CommandButton CommandButton1
    End Type
    
    Constructor Form1
    	' Form1
    	With This
    		.Name = "Form1"
    		.Text = "Fo1545rm1"
    		.SetBounds 0, 0, 350, 300
    	End With
    	' CheckBox1
    	With CheckBox1
    		.Name = "CheckBox1"
    		.Text = "CheckB5454ox1"
    		.SetBounds 48, 24, 176, 128
    		.Parent = @This
    	End With
    	' CommandButton1
    	With CommandButton1
    		.Name = "CommandButton1"
    		.Text = "CommandButton1"
    		.SetBounds 40, 192, 184, 32
    		.OnClick = @CommandButton1_Click
    		.Parent = @This
    	End With
    End Constructor
    
    Dim Shared fForm1 As Form1
    
    #ifndef _NOT_AUTORUN_FORMS_
        fForm1.Show
        
        App.Run
    #endif
'#End Region


Private Sub Form1.CommandButton1_Click(ByRef Sender As Control)
	MsgBox "dsdsd"
End Sub
