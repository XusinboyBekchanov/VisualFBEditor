#ifdef __FB_WIN32__
	'#Compile -exx "Form1.rc"
#else
	'#Compile -exx
#endif
#include once "mff/Form.bi"
#include once "mff/CheckBox.bi"

Using My.Sys.Forms

'#Region "Form"
    Type Form1 Extends Form
    	Declare Constructor
        
    	Dim As CheckBox CheckBox1
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
    		.SetBounds 136, 40, 96, 64
    		.Parent = @This
    	End With
    End Constructor
    
    Dim Shared fForm1 As Form1
    
    #ifndef _NOT_AUTORUN_FORMS_
        fForm1.Show
        
        App.Run
    #endif
'#End Region

