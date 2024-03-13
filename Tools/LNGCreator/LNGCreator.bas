'################################################################################
'#  LNGCreator.frm                                                               #
'#  This file is an application of MyFBFramework.                                #
'#  Authors: Xusinboy Bekchanov, Liu XiaLin                                     #
'#################################################################################
'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/sys.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/Label.bi"
	#include once "mff/Dialogs.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/RadioButton.bi"
	#include once "mff/StatusBar.bi"
	#include once "mff/Label.bi"
	#include once "mff/CheckBox.bi"
	
	Using My.Sys.Forms
	
	Type Form1 Extends Form
		Declare Sub cmdExploreProj_Click(ByRef Sender As Control)
		Declare Sub cmdRun_Click(ByRef Sender As Control)
		Declare Sub cmdExploreLng_Click(ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Constructor
		
		Dim As TextBox txtPathProj, txtPathLng
		Dim As CommandButton cmdRun, cmdExploreProj, cmdExploreLng
		Dim As StatusBar StatusBar1
		Dim As Label lblNameProject, lblNameLng
		Dim As CheckBox chkOuputHtml,chkAllLNG
	End Type
	
	Constructor Form1
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = My.Sys.Language
			End With
		#endif
		' Form1
		With This
			.Name = "Form1"
			.Text = ML("Update language texts")
			#ifdef __USE_GTK__
				.Icon.LoadFromFile(ExePath & "../../Resources/VisualFBEditor.ico")
			#else
				.Icon.LoadFromResourceID(1)
			#endif
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.Designer = @This
			.SetBounds 0, 0, 460, 155
		End With
		
		' txtPathProj
		With txtPathProj
			.Name = "txtPathProj"
			.Text = ""
			.Anchor.Right = AnchorStyle.asAnchor
			.Anchor.Left = AnchorStyle.asAnchor
			.TabIndex = 4
			.SetBounds 100, 4, 290, 18
			.Designer = @This
			.Parent = @This
		End With
		
		' cmdRun
		With cmdRun
			.Name = "cmdRun"
			.Text = ML("Run")
			.SetBounds 6, 76, 420, 24
			.TabIndex = 6
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control),  @cmdRun_Click)
			.Designer = @This
			.Parent = @This
		End With
		
		' cmdExploreProj
		With cmdExploreProj
			.Name = "cmdExploreProj"
			.Text = "..."
			.SetBounds 392, 4, 34, 18
			.TabIndex = 2
			.Anchor.Right = AnchorStyle.asAnchor
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdExploreProj_Click)
			.Designer = @This
			.Parent = @This
		End With
		
		' lblNameLng
		With lblNameLng
			.Name = "lblNameLng"
			.Text = ML("language file")
			.SetBounds 10, 34, 108, 18
			.Designer = @This
			.Parent = @This
		End With
		
		' chkAllLNG
		With chkAllLNG
			.Name = "chkAllLNG"
			.Text = ML("Update all language file")
			.SetBounds 10, 56, 128, 18
			.Checked = True
			.Designer = @This
			.Parent = @This
		End With
		
		' txtPathLng
		With txtPathLng
			.Name = "txtPathLng"
			.Text = ""
			.Anchor.Left = asAnchor
			.Anchor.Right = asAnchor
			.SetBounds 100, 34, 290, 18
			.Designer = @This
			.Parent = @This
		End With
		
		' cmdExploreLng
		With cmdExploreLng
			.Name = "cmdExploreLng"
			.Text = "..."
			.SetBounds 392, 34, 34, 18
			.TabIndex = 3
			.Anchor.Right = AnchorStyle.asAnchor
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdExploreLng_Click)
			.Designer = @This
			.Parent = @This
		End With
		
		' StatusBar1
		With StatusBar1
			.Name = "StatusBar1"
			.Text = "StatusBar1"
			.Anchor.Right = AnchorStyle.asAnchor
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Bottom = AnchorStyle.asAnchor
			.SetBounds 0, 102, 340, 16
			.Designer = @This
			.Parent = @This
		End With
		' lblNameProject
		With lblNameProject
			.Name = "lblNameProject"
			.Text = ML("Project Name")
			.TabIndex = 7
			.ControlIndex = 4
			.SetBounds 10, 4, 86, 18
			.Designer = @This
			.Parent = @This
		End With
		
		' chkOuputHtml
		With chkOuputHtml
			.Name = "chkOuputHtml"
			.Text = ML("Save as HTML files for translation by Edge or Chrome.")
			.TabIndex = 8
			.Checked = True
			.SetBounds 145, 56, 310, 18
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frm As Form1
	
	#ifndef _NOT_AUTORUN_FORMS_
		App.DarkMode= True
		frm.MainForm = True
		frm.Show
		App.Run
	#endif
'#End Region

Function GetFolderName(ByRef FileName As WString, WithSlash As Boolean = True) As UString
	Dim Pos1 As Long = InStrRev(FileName, "\", Len(FileName) - 1)
	Dim Pos2 As Long = InStrRev(FileName, "/", Len(FileName) - 1)
	If Pos1 = 0 OrElse Pos2 > Pos1 Then Pos1 = Pos2
	If Pos1 > 0 Then
		If Not WithSlash Then Pos1 -= 1
		Return Left(FileName, Pos1)
	End If
	Return ""
End Function

Private Sub Form1.cmdExploreProj_Click(ByRef Sender As Control)
	Dim OpenD As OpenFileDialog
	OpenD.Filter = "Visual FB Editor projects (.vfp)|*.vfp|Froms file (.frm)|*.frm|Modules file (.bas)|*.bas|"
	If OpenD.Execute Then 
		txtPathProj.Text = OpenD.FileName
		txtPathLng.Text = GetFolderName(txtPathProj.Text) & "Languages/"
	End If
End Sub

Private Sub Form1.cmdRun_Click(ByRef Sender As Control)
	If Dir(txtPathProj.Text) = "" Then
		StatusBar1.Panels[0]->Caption = "File not found! " & txtPathProj.Text
		Exit Sub
	End If
	Dim As WString * 1024 Buff, Buff1, Lang_Name, FileName, FileName1, PathLng, PathProj
	Dim As WStringList mlKeys, mlTexts, mlTextsOther, mlKeysNew
	Dim As Boolean EmptyLng, StartGeneral = True, StartOther
	Dim As String Key, f
	Dim As Integer p, p1, n, Result, FileCount, Fn1 = FreeFile, Fn2
	Lang_Name = "english"
	txtPathProj.Text = Trim(txtPathProj.Text)
	txtPathLng.Text = Trim(txtPathLng.Text)
	If LCase(Right(txtPathLng.Text, 4)) = ".lng" Then
		PathLng = GetFolderName(txtPathLng.Text) 
	Else
		If Right(Trim(txtPathLng.Text), 1) = "/" OrElse Right(Trim(txtPathLng.Text), 1) = "\" Then
			PathLng = txtPathLng.Text
		Else
			PathLng = txtPathLng.Text & "/"
		End If
	End If
	If Dir(PathLng) = "" Then MkDir PathLng
	PathProj = GetFolderName(txtPathProj.Text)
	Debug.Print "PathLng=" & PathLng
	If EndsWith(txtPathProj.Text, ".frm") OrElse EndsWith(txtPathProj.Text, ".bas") Then
		FileName= txtPathProj.Text
		Fn2 = FreeFile
		Result = Open(FileName For Input Encoding "utf-8" As #Fn2)
		If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-16" As #Fn2)
		If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-32" As #Fn2)
		If Result <> 0 Then Result = Open(FileName For Input As #Fn2)
		If Result = 0 Then
			Do Until EOF(Fn2)
				Line Input #Fn2, Buff1
				p = InStr(LCase(Buff1), "ml(""")
				Do While p > 0
					p1 = InStr(p + 1, Buff1, """)")
					If p1 > 0 Then
						Key = Trim(Mid(Buff1, p + 4, p1 - p - 4), Any !"\t ")
						If Key <> "" Then
							If Key <> """" AndAlso Not mlKeysNew.Contains(Key) Then
								mlKeysNew.Add Key
								Key = Replace(Key, "&", "")
								If Not mlKeysNew.Contains(Key) Then mlKeysNew.Add Key
							End If
						End If
					End If
					p = InStr(p + 1, LCase(Buff1), "ml(""")
				Loop
				p = InStr(LCase(Buff1), "ms(""")
				Do While p > 0
					p1 = InStr(p + 1, Buff1, """,")
					If p1 > 0 Then
						Key = Trim(Mid(Buff1, p + 4, p1 - p - 4), Any !"\t ")
						If Key <> "" Then
							If Key <> """" AndAlso Not mlKeysNew.Contains(Key) Then
								mlKeysNew.Add Key
								Key = Replace(Key, "&", "")
								If Not mlKeys.Contains(Key) Then mlKeys.Add Key
							End If
						End If
					End If
					p = InStr(p + 1, LCase(Buff1), "ms(""")
				Loop
				p = InStr(LCase(Buff1), ".curlanguage =")
				If p < 1 Then p = InStr(LCase(Buff1), ".curlanguage=")
				If p > 0 Then
					p = InStr(p + 1, LCase(Buff1), Chr(34))
					p1 = InStr(p + 1, Buff1, Chr(34))
					If p1 > 0 Then Lang_Name = Mid(Buff1, p + 1, p1 - p - 1)
					Debug.Print ".curlanguage =" & Lang_Name
				End If
			Loop
			FileCount += 1
			Close #Fn2
		Else
			StatusBar1.Panels[0]->Caption = ML("Can not open file!") & " " & FileName
		End If
	Else
		Result = Open(txtPathProj.Text For Input Encoding "utf-8" As #Fn1)
		If Result <> 0 Then Result = Open(txtPathProj.Text For Input Encoding "utf-16" As #Fn1)
		If Result <> 0 Then Result = Open(txtPathProj.Text For Input Encoding "utf-32" As #Fn1)
		If Result <> 0 Then Result = Open(txtPathProj.Text For Input As #Fn1)
		If Result = 0 Then
			Do Until EOF(Fn1)
				Line Input #Fn1, Buff
				If StartsWith(Buff, "File=") OrElse StartsWith(Buff, "*File=") Then
					Buff = Mid(Buff, InStr(Buff, "=") + 1)
					If InStr(Buff, ":") Then
						FileName= Buff
					Else
						FileName= GetFolderName(txtPathProj.Text) & Buff
					End If
					StatusBar1.Panels[0]->Caption = ML("now open file ") & " " & FileName
					App.DoEvents
					Fn2 = FreeFile
					Result = Open(FileName For Input Encoding "utf-8" As #Fn2)
					If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-16" As #Fn2)
					If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-32" As #Fn2)
					If Result <> 0 Then Result = Open(FileName For Input As #Fn2)
					If Result = 0 Then
						Do Until EOF(Fn2)
							Line Input #Fn2, Buff1
							p = InStr(LCase(Buff1), "ml(""")
							Do While p > 0
								p1 = InStr(p + 1, Buff1, """)")
								If p1 > 0 Then
									Key = Trim(Mid(Buff1, p + 4, p1 - p - 4), Any !"\t ")
									If Key <> "" Then
										If Key <> """" AndAlso Not mlKeysNew.Contains(Key) Then
											mlKeysNew.Add Key
											Key = Replace(Key, "&", "")
											If Not mlKeysNew.Contains(Key) Then mlKeysNew.Add Key
										End If
									End If
								End If
								p = InStr(p + 1, LCase(Buff1), "ml(""")
							Loop
							p = InStr(LCase(Buff1), "ms(""")
							Do While p > 0
								p1 = InStr(p + 1, Buff1, """,")
								If p1 > 0 Then
									Key = Trim(Mid(Buff1, p + 4, p1 - p - 4), Any !"\t ")
									If Key <> "" Then
										If Key <> """" AndAlso Not mlKeysNew.Contains(Key) Then
											mlKeysNew.Add Key
											Key = Replace(Key, "&", "")
											If Not mlKeys.Contains(Key) Then mlKeys.Add Key
										End If
									End If
								End If
								p = InStr(p + 1, LCase(Buff1), "ms(""")
							Loop
							p = InStr(LCase(Buff1), ".curlanguage =")
							If p < 1 Then p = InStr(LCase(Buff1), ".curlanguage=")
							If p > 0 Then
								p = InStr(p + 1, LCase(Buff1), Chr(34))
								p1 = InStr(p + 1, Buff1, Chr(34))
								If p1 > 0 Then Lang_Name = Mid(Buff1, p + 1, p1 - p - 1)
								Debug.Print ".curlanguage =" & Lang_Name
							End If
						Loop
						Close #Fn2
						FileCount += 1
					Else
						StatusBar1.Panels[0]->Caption = ML("Can not open file!") & " " & FileName
					End If
				End If
			Loop
			Close #Fn1
		Else
			StatusBar1.Panels[0]->Caption = ML("Can not open file!") & " " & txtPathProj.Text
		End If
	End If
	mlKeysNew.Sort
	If Dir(PathLng & Lang_Name & ".lng") = "" Then EmptyLng = True
	If chkAllLNG.Checked Then
		f = Dir(PathLng & "*.lng")
	Else
		f = Dir(txtPathLng.Text)
	End If
	If EmptyLng Then
		f = "english.lng"
		EmptyLng = False
	End If
	StatusBar1.Panels[0]->Caption = ML("Find language file.") & " " & f
	While f <> ""
		FileName1 = PathLng & f
		Fn1 = FreeFile
		Result = Open(FileName1 For Input Encoding "utf-8" As #Fn1)
		If Result <> 0 Then Result = Open(FileName1 For Input Encoding "utf-16" As #Fn1)
		If Result <> 0 Then Result = Open(FileName1 For Input Encoding "utf-32" As #Fn1)
		If Result <> 0 Then Result = Open(FileName1 For Input As #Fn1)
		If Result = 0 Then
			n = 0
			mlKeys.Clear
			mlTexts.Clear
			mlTextsOther.Clear
			Do Until EOF(Fn1)
				Line Input #Fn1, Buff
				If Trim(Buff) = "" Then Continue Do
				n = n + 1
				If n = 1 Then
					Lang_Name = Buff
				Else
					If StartsWith(LCase(Trim(Buff)), "[") AndAlso EndsWith(LCase(Trim(Buff)), "]") Then
						If LCase(Trim(Buff)) <> "[general]" Then
							StartOther = True
							StartGeneral = False
							mlTextsOther.Add Buff
						End If
					ElseIf LCase(Trim(Buff)) = "[general]" Then
						StartOther = False
						StartGeneral = True
					End If
					p = InStr(LCase(Buff), "=")
					If p > 0 Then
						Var Pos3 = InStr(Buff, "~")
						If Pos3 > 0 AndAlso Pos3 < p Then Buff = Replace(Buff, "~", "=")
						Key = Trim(Mid(Buff, 1, p - 1), Any !"\t ")
						If StartGeneral = True Then
							If Not mlKeys.Contains(Key) Then
								mlKeys.Add Key
								mlTexts.Add Trim(Mid(Buff, p + 1), Any !"\t ")
							End If
						ElseIf StartOther = True Then
							mlTextsOther.Add Buff
						End If
						
					End If
				End If
			Loop
			Close #Fn1
		End If
		Fn1 = FreeFile
		If Open(FileName1 For Output Encoding "utf-8" As #Fn1) = 0 Then
			Print #Fn1, Lang_Name
			For i As Integer = 0 To mlTextsOther.Count - 1
				Print #Fn1, mlTextsOther.Item(i)
			Next
			Print #Fn1, "[General]"
			For i As Integer = 0 To mlKeysNew.Count - 1
				Key = mlKeysNew.Item(i)
				Print #Fn1, Replace(Key, "=", "~")  & " = " & IIf(mlKeys.Contains(Key), mlTexts.Item(mlKeys.IndexOf(Key)), "")
			Next
			StatusBar1.Panels[0]->Caption = ML("Success save file!") & " " &  FileName1
			Close #Fn1
		Else
			StatusBar1.Panels[0]->Caption = ML("Can not save file!") & " " &  FileName1
		End If
		f = Dir()
	Wend
	If chkOuputHtml.Checked Then
		Fn1 = FreeFile
		If Open(PathLng & "english.html" For Output Encoding "utf-8" As #Fn1) = 0 Then
			Print #Fn1,  "<html dir=""ltr"" lang=""en-gb""><head><code><title>" + Lang_Name+ "</title></code>"
			Print #Fn1,  "<link rel=""stylesheet"" type=""text/css"" href=""style.css""><meta charset=""UTF-8""></head>"
			Print #Fn1,  "<body><div id=""fb_body_wrapper""><div id=""fb_tab""><code><div id=""fb_tab_l"">&nbsp;" + Lang_Name + "</div></code></div></div>"
			Print #Fn1,  "<div id=""fb_pg_wrapper""><div id=""fb_pg_body"">"
			Print #Fn1,  "<div class=""freebasic"">"
			
			For i As Integer = 0 To mlKeysNew.Count - 1
				Key = mlKeysNew.Item(i)
				Print #Fn1, "<li><code>" + Key & " &nbsp;=&nbsp; </code>" +  Replace(Key, "&", "") + "<br\>"
			Next
			Print #Fn1,  "</div>" + Chr(13, 10) + "</div>" + Chr(13, 10) + "</div>" + Chr(13, 10) + "</body>" + Chr(13, 10) + "</html>"
			Close #Fn1
			StatusBar1.Panels[0]->Caption = ML("Success save file!") & " " &  PathLng & "english.html"
		Else
			StatusBar1.Panels[0]->Caption = ML("Can not save file!") & " " &  PathLng & "english.html"
		End If
	End If
	StatusBar1.Panels[0]->Caption = ML("Success searching") & " " & FileCount & " " & ML("files")
End Sub

Private Sub Form1.cmdExploreLng_Click(ByRef Sender As Control)
	Dim OpenD As OpenFileDialog
	OpenD.Filter = ML("Language file (.lng)") & "|*.lng|"
	If OpenD.Execute Then
		txtPathLng.Text = OpenD.FileName
	End If
End Sub

Private Sub Form1.Form_Create(ByRef Sender As Control)
	Debug.Print "Command args =" & Command
	Debug.Print "App.Language =" & App.Language & " App.CurLanguage =" & App.CurLanguage
	'Debug.Print "App.Language =" & My.Sys.Language
	If Command <> "" Then
		txtPathProj.Text = Command
		txtPathLng.Text = GetFolderName(Command) & "english.lng"
	End If
	StatusBar1.Align = DockStyle.alBottom
	StatusBar1.Add ML("")
	StatusBar1.Panels[0]->Width = This.ClientWidth - 20
	StatusBar1.Add ""
End Sub

