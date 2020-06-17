#ifdef __FB_WIN32__
	'#Compile -exx "Form1.rc"
#else
	'#Compile -exx
#endif
#include once "mff/Form.bi"
#include once "mff/CheckBox.bi"
#include once "mff/CommandButton.bi"
#include once "mff/GroupBox.bi"

Using My.Sys.Forms

'#Region "Form"
    Type Form1 Extends Form
    	Declare Static Sub CommandButton1_Click(ByRef Sender As Control)
    	Declare Constructor
        
    	Dim As CheckBox CheckBox1
    	Dim As CommandButton CommandButton1
    	Dim As GroupBox GroupBox1
    End Type
    
    Constructor Form1
    	' Form1
    	With This
    		.Name = "Form1"
    		.Text = "Form1"
    		.SetBounds 0, 0, 350, 300
    	End With
    	' CheckBox1
    	With CheckBox1
    		.Name = "CheckBox1"
    		.Text = "CheckBox1"
    		.SetBounds 80, 200, 128, 72
    		.Parent = @This
    	End With
    	' CommandButton1
    	With CommandButton1
    		.Name = "CommandButton1"
    		.Text = "CommandButton1"
    		.SetBounds 72, 144, 144, 40
    		.OnClick = @CommandButton1_Click
    		.Parent = @This
    	End With
    	' GroupBox1
    	With GroupBox1
    		.Name = "GroupBox1"
    		.Text = "GroupBox1"
    		.SetBounds 32, 8, 256, 128
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
	MsgBox "fdfdd"
End Sub
