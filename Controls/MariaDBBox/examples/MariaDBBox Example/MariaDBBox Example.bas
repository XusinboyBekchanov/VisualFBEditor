'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "MariaDBBox.bi"
	#include once "mff/CommandButton.bi"
	
	Using My.Sys.Forms
	
	Type Form1Type Extends Form
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Static Sub _MariaDBBox1_ErrorOut(ByRef Sender As MariaDBBox, ErrorTxt As String)
		Declare Sub MariaDBBox1_ErrorOut(ByRef Sender As MariaDBBox, ErrorTxt As String)
		Declare Constructor
		
		Dim As MariaDBBox MariaDBBox1
		Dim As CommandButton CommandButton1
	End Type
	
	Constructor Form1Type
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = .Language
			End With
		#endif
		' Form1
		With This
			.Name = "Form1"
			.Text = "Form1"
			.Designer = @This
			.SetBounds 0, 0, 350, 300
		End With
		' MariaDBBox1
		With MariaDBBox1
			.Name = "MariaDBBox1"
			.SetBounds 160, 40, 16, 16
			.Designer = @This
			.OnErrorOut = @_MariaDBBox1_ErrorOut
			.Parent = @This
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "CommandButton1"
			.TabIndex = 0
			.SetBounds 60, 200, 200, 40
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton1_Click)
			.Parent = @This
		End With
	End Constructor
	
	Private Sub Form1Type._MariaDBBox1_ErrorOut(ByRef Sender As MariaDBBox, ErrorTxt As String)
		(*Cast(Form1Type Ptr, Sender.Designer)).MariaDBBox1_ErrorOut(Sender, ErrorTxt)
	End Sub
	
	Dim Shared Form1 As Form1Type
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		Form1.MainForm = True
		Form1.Show
		App.Run
	#endif
'#End Region

Private Sub Form1Type.CommandButton1_Click(ByRef Sender As Control)
	Dim As String rs()
	MariaDBBox1.Open("test", "root", "111")
	MariaDBBox1.SQLFind("Select * From myguests", rs())
	For i As Integer = 0 To UBound(rs)
		?rs(i, 0), rs(i, 1), rs(i, 2)
	Next
End Sub

Private Sub Form1Type.MariaDBBox1_ErrorOut(ByRef Sender As MariaDBBox, ErrorTxt As String)
	?ErrorTxt
End Sub
