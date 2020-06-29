'#Compile "LNGCreator.rc" -x "LNGCreator.exe"

#include once "mff\Form.bi"
#include once "mff\TextBox.bi"
#include once "mff\Label.bi"
#include once "mff\Dialogs.bi"
#include once "mff\CommandButton.bi"
#include once "mff\RadioButton.bi"

Using My.Sys.Forms

'#Region "Form"
	Type Form1 Extends Form
		Declare Static Sub CommandButton2_Click(ByRef Sender As Control)
		Declare Static Sub CommandButton1_Create(ByRef Sender As Control)
		Declare Static Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Static Sub CommandButton3_Click(ByRef Sender As Control)
		Declare Static Sub Form_Create(ByRef Sender As Control)
		Declare Constructor
		
		Dim As TextBox TextBox1, TextBox2
		Dim As Label Label1
		Dim As RadioButton optLNGPath, optAllLNG
		Dim As CommandButton CommandButton1, CommandButton2, CommandButton3
	End Type
	
	Constructor Form1
		' Form1
		This.Name = "Form1"
		This.Text = "Update language texts in .lng"
		This.OnCreate = @Form_Create
		This.SetBounds 0, 0, 350, 196
		' TextBox1
		TextBox1.Name = "TextBox1"
		TextBox1.Text = ""
		TextBox1.SetBounds 90, 24, 210, 18
		TextBox1.Parent = @This
		' Label1
		Label1.Name = "Label1"
		Label1.Text = ".vfp path"
		Label1.SetBounds 12, 24, 78, 18
		Label1.Caption = "Path to .vfp"
		Label1.Parent = @This
		' CommandButton1
		CommandButton1.Name = "CommandButton1"
		CommandButton1.Text = "Run"
		CommandButton1.SetBounds 136, 116, 90, 30
		CommandButton1.Caption = "Run"
		CommandButton1.OnCreate = @CommandButton1_Create
		CommandButton1.OnClick = @CommandButton1_Click
		CommandButton1.Parent = @This
		' CommandButton2
		CommandButton2.Name = "CommandButton2"
		CommandButton2.Text = "..."
		CommandButton2.SetBounds 300, 24, 24, 18
		CommandButton2.Caption = "..."
		CommandButton2.OnClick = @CommandButton2_Click
		CommandButton2.Parent = @This
		' optLNGPath
		optLNGPath.Name = "optLNGPath"
		optLNGPath.Text = "Path to .lng"
		optLNGPath.SetBounds 12, 54, 78, 18
		optLNGPath.Caption = "Path to .lng"
		optLNGPath.Parent = @This
		' optAllLNG
		optAllLNG.Name = "optAllLNG"
		optAllLNG.Text = "All .lng"
		optAllLNG.SetBounds 12, 86, 78, 18
		optAllLNG.Caption = "All .lng"
		optAllLNG.Checked = True
		optAllLNG.Parent = @This
		' TextBox2
		TextBox2.Name = "TextBox2"
		TextBox2.Text = ""
		TextBox2.SetBounds 90, 54, 210, 18
		TextBox2.Parent = @This
		' CommandButton3
		CommandButton3.Name = "CommandButton3"
		CommandButton3.Text = "..."
		CommandButton3.SetBounds 300, 54, 24, 18
		CommandButton3.Caption = "..."
		CommandButton3.OnClick = @CommandButton3_Click
		CommandButton3.Parent = @This
	End Constructor
	
	Dim Shared frm As Form1
	
	#ifndef _NOT_AUTORUN_FORMS_
		frm.Show
		
		App.Run
	#endif
'#End Region


Private Sub Form1.CommandButton2_Click(ByRef Sender As Control)
	Dim OpenD As OpenFileDialog
	OpenD.Filter = "Visual FB Editor projects (.vfp)|*.vfp|"
	If OpenD.Execute Then
		Cast(Form1 Ptr, Sender.Parent)->TextBox1.Text = OpenD.FileName
	End If
End Sub

Private Sub Form1.CommandButton1_Create(ByRef Sender As Control)
	
End Sub

Function GetFolderName(ByRef FileName As WString) ByRef As WString
	Dim Pos1 As Long = InStrRev(FileName, "\")
	Dim s  As WString Ptr = CAllocate((Pos1 + 1) * SizeOf(WString))
	If Pos1 > 0 Then
		*s = Left(FileName, Pos1)
		Return *s
	End If
	Return ""
End Function

Private Sub Form1.CommandButton1_Click(ByRef Sender As Control)
	Dim As WString Ptr lang_name, fileName
	Dim Buff As WString * 1024
	Dim Buff1 As WString * 1024
	Dim As String Key, f
	Dim As Integer p, p1, n, Result, Fn1 = FreeFile, Fn2
	Dim As UString FileName1
	With *Cast(Form1 Ptr, Sender.Parent)
		If .optAllLNG.Checked Then
			f = Dir(ExePath & "/Settings/Languages/*.lng")
		Else
			f = Dir(.TextBox2.Text)
		End If
		While f <> ""
			FileName1 = ExePath & "/Settings/Languages/" & f
			Result = Open(FileName1 For Input Encoding "utf-8" As #Fn1)
			If Result <> 0 Then Result = Open(FileName1 For Input Encoding "utf-16" As #Fn1)
			If Result <> 0 Then Result = Open(FileName1 For Input Encoding "utf-32" As #Fn1)
			If Result <> 0 Then Result = Open(FileName1 For Input As #Fn1)
			If Result = 0 Then
				Dim As WStringList mlKeys, mlTexts, mlKeysNew
				n = 0
				Do Until EOF(Fn1)
					Line Input #Fn1, Buff
					n = n + 1
					If n = 1 Then
						WLet lang_name, Buff
					Else
						p = InStr(LCase(Buff), "=")
						If p > 0 Then
							Key = Trim(Left(Buff, p - 1))
							If Not mlKeys.Contains(Key) Then
								mlKeys.Add Key
								mlTexts.Add Mid(Buff, p + 1)
							End If
						End If
					End If
				Loop
				Close #Fn1
				Open .TextBox1.Text For Input Encoding "utf-8" As #Fn1
				Do Until EOF(Fn1)
					Line Input #Fn1, Buff
					If StartsWith(Buff, "File=") OrElse StartsWith(Buff, "*File=") Then
						Buff = Mid(Buff, InStr(Buff, "=") + 1)
						If InStr(Buff, ":") Then
							WLet fileName, Buff
						Else
							WLet fileName, GetFolderName(.TextBox1.Text) & Buff
						End If
						Fn2 = FreeFile
						Open *fileName For Input Encoding "utf-8" As #Fn2
						Do Until EOF(Fn2)
							Line Input #Fn2, Buff1
							p = InStr(LCase(Buff1), "ml(""")
							Do While p > 0
								p1 = InStr(p + 1, Buff1, """)")
								If p1 > 0 Then
									Key = Mid(Buff1, p + 4, p1 - p - 4)
									If Key <> """" Then
										If Not mlKeysNew.Contains(Key) Then mlKeysNew.Add Key
										'David Change for surport like "&F" in menuitem
										If InStr(key,"&") Then
											Key=replace(key,"&","")
											If Not mlKeysNew.Contains(Key) Then mlKeysNew.Add Key
										End If
									End If
								End If
								p = InStr(p1 + 1, LCase(Buff1), "ml(""")
							Loop
						Loop
						Close #Fn2
					End If
				Loop
				Close #Fn1
				Open FileName1 For Output Encoding "utf-8" As #Fn1
				Print #Fn1, *lang_name
				mlKeysNew.Sort
				For i As Integer = 0 To mlKeysNew.Count - 1
					Key = mlKeysNew.Item(i)
					If *lang_name = "tester" Then
						Print #Fn1, Key & " = #" & Key
					Else
						Print #Fn1, Key & " = " & IIf(mlKeys.Contains(Key), mlTexts.Item(mlKeys.IndexOf(Key)), "")
					End If
				Next
				Close #Fn1
			End If
			f = Dir()
		Wend
	End With
	MsgBox "Done!"
End Sub

Private Sub Form1.CommandButton3_Click(ByRef Sender As Control)
	Dim OpenD As OpenFileDialog
	OpenD.Filter = "Language file (.lng)|*.lng|"
	If OpenD.Execute Then
		Cast(Form1 Ptr, Sender.Parent)->TextBox2.Text = OpenD.FileName
	End If
End Sub

Private Sub Form1.Form_Create(ByRef Sender As Control)
	If Command <> "" Then
		frm.TextBox1.Text = Command
	End If
End Sub
