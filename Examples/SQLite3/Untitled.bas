'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#ifdef __FB_64BIT__
				#cmdline "Form1.rc -x ./release/win64/Untitled.exe"
			#else
				#cmdline "Form1.rc -x ./release/win32/Untitled.exe"
			#endif
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#ifdef __FB_64BIT__
		#libpath "./lib/win64"
	#else
		#libpath "./lib/win32"
	#endif
	#include once "mff/Form.bi"
	#include once "mff/Picture.bi"
	#include once "mff/CommandButton.bi"
	#include once "SQLite3Component.bi"

	Using My.Sys.Forms
	
	Type Form1Type Extends Form
		Declare Static Sub CommandButton1_Click_(ByRef Sender As Control)
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Static Sub SQLite3Component1_ErrorOut_(ByRef Sender As SQLite3Component, ErrorTxt As String)
		Declare Sub SQLite3Component1_ErrorOut(ByRef Sender As SQLite3Component, ErrorTxt As String)
		Declare Static Function SQLite3Component1_SQLString_(ByRef Sender As SQLite3Component, Sql_Utf8 As String) As Long
		Declare Function SQLite3Component1_SQLString(ByRef Sender As SQLite3Component, Sql_Utf8 As String) As Long
		Declare Constructor
		
		Dim As Picture Picture1
		Dim As CommandButton CommandButton1
		Dim As SQLite3Component SQLite3Component1
	End Type
	
	Constructor Form1Type
		' Form1
		With This
			.Name = "Form1"
			.Text = "Form1"
			.Designer = @This
			.SetBounds 0, 0, 350, 300
		End With
		' Picture1
		With Picture1
			.Name = "Picture1"
			.Text = "Picture1"
			.TabIndex = 0
			.SetBounds 160, 30, 130, 90
			.Designer = @This
			.Parent = @This
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "CommandButton1"
			.TabIndex = 1
			.SetBounds 100, 170, 130, 40
			.Designer = @This
			.OnClick = @CommandButton1_Click_
			.Parent = @This
		End With
		' SQLite3Component1
		With SQLite3Component1
			.Name = "SQLite3Component1"
			.SetBounds 20, 60, 16, 16
			.Designer = @This
			.OnErrorOut = @SQLite3Component1_ErrorOut_
			.OnSQLString = @SQLite3Component1_SQLString_
			.Parent = @This
		End With
	End Constructor
	
	Private Function Form1Type.SQLite3Component1_SQLString_(ByRef Sender As SQLite3Component, Sql_Utf8 As String) As Long
		Return (*Cast(Form1Type Ptr, Sender.Designer)).SQLite3Component1_SQLString(Sender, Sql_Utf8)
	End Function
	
	Private Sub Form1Type.SQLite3Component1_ErrorOut_(ByRef Sender As SQLite3Component, ErrorTxt As String)
		(*Cast(Form1Type Ptr, Sender.Designer)).SQLite3Component1_ErrorOut(Sender, ErrorTxt)
	End Sub
	
	Private Sub Form1Type.CommandButton1_Click_(ByRef Sender As Control)
		(*Cast(Form1Type Ptr, Sender.Designer)).CommandButton1_Click(Sender)
	End Sub
	
	Dim Shared Form1 As Form1Type
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		Form1.MainForm = True
		Form1.Show
		App.Run
	#endif
'#End Region

Sub SaveFile(FileName As String, p As String)
	Dim As Integer n
	n = FreeFile
	If Open (FileName For Binary Access Write As #n) = 0 Then
		Put #n, , p
		Close
	Else
		Print "Unable to save " + FileName
	End If
End Sub

Function LoadFile(File As String) As String
	Var f = FreeFile
	Open File For Binary Access Read As #f
	Dim As String Text
	If LOF(f) > 0 Then
		Text = String(LOF(f), 0)
		Get #f, , Text
	End If
	Close #f
	Return Text
End Function

Private Sub Form1Type.CommandButton1_Click(ByRef Sender As Control)
	SQLite3Component1.Open("../../sqlite3_test.db")
	SQLite3Component1.AddField "features", "image", "BLOB", "0"
	SQLite3Component1.AddField "features", "imagetype", "TEXT", "PNG"
	SQLite3Component1.AddItemUtf "features", "id = 6, title = 'New title', description = 'New title description'"
	Dim As String ImageBinary = LoadFile("../../Add.png")
	SQLite3Component1.UpdateByteUtf "features", "id = 6", "image", StrPtr(ImageBinary), Len(ImageBinary)
	Dim As String rs()
	Dim As Long rs_Types()
	SQLite3Component1.FindOneByteUtf("features", "id = 6", rs(), rs_Types(), "image")
	If UBound(rs) > -1 Then
		SaveFile "AddCopy.png", rs(0)
		Picture1.Graphic = "AddCopy.png"
	End If
	SQLite3Component1.Close
End Sub

Private Sub Form1Type.SQLite3Component1_ErrorOut(ByRef Sender As SQLite3Component, ErrorTxt As String)
	?"e", ErrorTxt
End Sub

Private Function Form1Type.SQLite3Component1_SQLString(ByRef Sender As SQLite3Component, Sql_Utf8 As String) As Long
	?"s", Sql_Utf8
	Return 0
End Function
