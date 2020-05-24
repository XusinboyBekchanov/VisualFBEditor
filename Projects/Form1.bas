#ifdef __FB_WIN32__
	'#Compile -exx "Form1.rc"
#else
	'#Compile -exx
#endif
#include once "mff/Form.bi"

Using My.Sys.Forms

'#Region "Form"
    Type Form1 Extends Form
       Declare Static Sub Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
       Declare Constructor
       
    End Type
   
    Constructor Form1
       ' Form1
       With This
          .Name = "Form1"
          .Text = "Form1"
          .OnPaint = @Form_Paint
          .SetBounds 0, 0, 350, 300
       End With
    End Constructor
   
    Dim Shared fForm1 As Form1
   
    #ifndef _NOT_AUTORUN_FORMS_
        fForm1.Show
       
        App.Run
    #endif
'#End Region

Private Sub Form1.Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
   Canvas.Line 15, 15, 25, 40
   Canvas.Rectangle 50, 50, 100, 150
   Canvas.TextOut 160, 160, "Hello World", 0, -1
End Sub
