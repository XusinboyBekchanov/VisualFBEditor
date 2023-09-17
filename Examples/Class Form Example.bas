'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/CommandButton.bi"
	
	RedefineClassKeyword
	
	Using My.Sys.Forms
	
	Class Form1Type Extends Form
		Declare Static Sub _CommandButton1_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Constructor
		
		Dim As CheckBox CheckBox1
		Dim As CommandButton CommandButton1
		__StartOfClassBody__
		
		Constructor Form1Type
			' Form1
			With This
				.Name = "Form1"
				.Text = "Form1"
				.Designer = @This
				.SetBounds 0, 0, 350, 300
			End With
			' CheckBox1
			With CheckBox1
				.Name = "CheckBox1"
				.Text = "CheckBox1"
				.TabIndex = 0
				.SetBounds 50, 80, 180, 30
				.Designer = @This
				.Parent = @This
			End With
			' CommandButton1
			With CommandButton1
				.Name = "CommandButton1"
				.Text = "CommandButton1"
				.TabIndex = 1
				.SetBounds 60, 180, 170, 50
				.Designer = @This
				.OnClick = @_CommandButton1_Click
				.Parent = @This
			End With
		End Constructor
		
		Private Sub Form1Type._CommandButton1_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
			(*Cast(Form1Type Ptr, Sender.Designer)).CommandButton1_Click(Sender)
		End Sub
		
		__EndOfClassBody__
	End Class
	
	Dim Shared Form1 As Form1Type
	
	#if _MAIN_FILE_ = __FILE__
		Form1.MainForm = True
		Form1.Show
		App.Run
	#endif
'#End Region

Private Sub Form1Type.CommandButton1_Click(ByRef Sender As Control)
	Dim i As String
	
End Sub
