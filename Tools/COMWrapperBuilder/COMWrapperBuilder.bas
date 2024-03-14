'#############################################################
'#  COMWrapperBuilder.bas                                    #
'#  Author: Xusinboy Bekchanov (bxusinboy@mail.ru) (2020)    #
'#############################################################

'A FreeBasic module that generates including files (not dependent on libraries) on the fly can be used to write  the code normally according to the COM and VBA syntax. Before compiling the code
'Click On COMWrapperBuilder in the Menu "Settings" To automatically generate a reference header FILE that calls Com. Add "#include once 'Com_xxx.bi" in the code including area.

'一个即时翻译生成头文件（不依赖于库）的 FreeBasic 调用Com的模块，你可以先按照COM和VBA语法正常输入代码。在编译代码前
'点击菜单”设置”里的COMWrapperBuilder,将自动生成调用com的引用头文件。在代码引用区加入”#include once "Com_xxx.bi"即可

#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
	#define __MAIN_FILE__
	#ifdef __FB_WIN32__
		#cmdline "COMWrapperBuilder.rc -x COMWrapperBuilder.exe"
	#endif
	Const _MAIN_FILE_ = __FILE__
#endif
#include once "mff/Form.bi"
#include once "mff/sys.bi"
#include once "mff/TextBox.bi"
#include once "mff/Label.bi"
#include once "mff/Dialogs.bi"
#include once "mff/CommandButton.bi"
#include once "mff/Label.bi"
#include once "mff/TextBox.bi"

Using My.Sys.Forms
'#Region "Form"
	Type frmCOMWrapperBuilder Extends Form
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub cmdPath_Click(ByRef Sender As Control)
		Declare Sub cmdPathSource_Click(ByRef Sender As Control)
		Declare Sub cmdExplore_Click(ByRef Sender As Control)
		Declare Sub cmdRun_Click(ByRef Sender As Control)
		Declare Sub cmdExit_Click(ByRef Sender As Control)
		Declare Constructor
		
		Dim As Label lblPath, lblPathMainFile, lblPathToSVP, lblPathSVP
		Dim As CommandButton cmdPath, cmdPathSource, cmdExplore, cmdRun, cmdExit
		Dim As TextBox txtPath, txtPathSource, txtMsg
	End Type
	
	Constructor frmCOMWrapperBuilder
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = My.Sys.Language
			End With
		#endif
		' Form
		With This
			.Name = "frmCOMWrapperBuilder"
			.Text = ML("COM Wrapper Builder")
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.Icon.LoadFromResourceID(1)
			.BorderStyle = FormBorderStyle.FixedSingle
			.DoubleBuffered = False
			.Designer = @This
			.ID = 0
			.MaximizeBox = False
			.ModalResult = ModalResults.OK
			.SetBounds 0, 0, 500, 222
		End With
		
		' txtPath
		With txtPath
			.Name = "txtPath"
			.Text = ""
			.SetBounds 135, 4, 300, 18
			.Designer = @This
			.Parent = @This
		End With
		
		' lblPath
		With lblPath
			.Name = "lblPath"
			.Text = ML("Path to project (optional)")
			.SetBounds 12, -1, 120, 28
			.Designer = @This
			.Parent = @This
		End With
		
		' cmdPath
		With cmdPath
			.Name = "cmdPath"
			.Text = "..."
			.SetBounds 440, 3, 44, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdPath_Click)
			.Parent = @This
		End With
		
		' cmdPathSource
		With cmdPathSource
			.Name = "cmdPathSource"
			.Text = "..."
			.SetBounds 440, 33, 44, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdPathSource_Click)
			.Parent = @This
		End With
		
		' cmdRun
		With cmdRun
			.Name = "cmdRun"
			.Text = ML("Run")
			.SetBounds 371, 107, 110, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdRun_Click)
			.Parent = @This
		End With
		
		' lblPathMainFile
		With lblPathMainFile
			.Name = "lblPathMainFile"
			.Text = ML("Path to Main File (optional)")
			.SetBounds 12, 30, 120, 28
			.Designer = @This
			.Parent = @This
		End With
		
		' txtPathSource
		With txtPathSource
			.Name = "txtPathSource"
			.Text = ""
			.Designer = @This
			.SetBounds 135, 34, 300, 18
			.Parent = @This
		End With
		
		' cmdExit
		With cmdExit
			.Name = "cmdExit"
			.Text = ML("Exit")
			.SetBounds 371, 137, 110, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdExit_Click)
			.Parent = @This
		End With
		
		' lblPathToSVP
		With lblPathToSVP
			.Name = "lblPathToSVP"
			.Text = ML("Path to SimpleVariantPlus.bi:")
			.SetBounds 12, 60, 265, 17
			.Designer = @This
			.Parent = @This
		End With
		
		' lblPathSVP
		With lblPathSVP
			.Name = "lblPathSVP"
			.Text = ""
			.SetBounds 23, 81, 462, 21
			.Designer = @This
			.Parent = @This
		End With
		
		' cmdExplore
		With cmdExplore
			.Name = "cmdExplore"
			.Text = ML("Change")
			.SetBounds 440, 60, 44, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdExplore_Click)
			.Parent = @This
		End With
		
		' txtMsg
		With txtMsg
			.Name = "txtMsg"
			.Text = ML("A FreeBasic module that generates including files (Not dependent On libraries) On the fly can be used To Write the code normally according To the Com And VBA syntax.")
			.Text = .Text + Chr(13, 10) + ML("Before compiling the code, Click On COMWrapperBuilder in the Menu 'Settings' To automatically generate a reference header FILE that calls Com. Add '#include once 'Com_xxx.bi' in the code including area.")
			.TabIndex = 11
			.Multiline = True
			.ID = 1202
			.ScrollBars = ScrollBarsType.Vertical
			.WordWraps = True
			.SetBounds 11, 107, 350, 90
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared As WString * 255 comName
	Dim Shared frm As frmCOMWrapperBuilder
	App.DarkMode = True
	frm.MainForm = True
	frm.Show
	App.Run
'#End Region

Function WithoutQuotes(ByRef Path As WString) As UString
	Dim As UString NewPath = Path
	If NewPath.StartsWith("""") Then NewPath = Mid(Path, 2)
	If NewPath.EndsWith("""") Then NewPath = Left(NewPath, Len(NewPath) - 1)
	Return NewPath
End Function

Private Sub frmCOMWrapperBuilder.Form_Create(ByRef Sender As Control)
	comName = "vbVariant"
	If Command <> "" Then
		Var PosP = InStr(Command, "-p ")
		Var PosS = InStr(Command, "-s ")
		If PosP > 0 Then
			If EndsWith(Command, "-s") Then PosS = Len(Command) - 1
			If PosS > PosP Then
				txtPath.Text = WithoutQuotes(Mid(Command, PosP + 3, PosS - PosP - 3))
			Else
				txtPath.Text = WithoutQuotes(Mid(Command, PosP + 3))
			End If
		End If
		If PosS > 0 Then
			If PosP > PosS Then
				txtPathSource.Text = WithoutQuotes(Mid(Command, PosS + 3, PosP - PosS - 3))
			Else
				txtPathSource.Text = WithoutQuotes(Mid(Command, PosS + 3))
			End If
		End If
		'cmdRun_Click(Sender)
	End If
End Sub

Private Sub frmCOMWrapperBuilder.cmdPath_Click(ByRef Sender As Control)
	Dim OpenD As OpenFileDialog
	OpenD.Filter = ML("Project Files") & " (*.*)|*.*|"
	If OpenD.Execute Then
		txtPath.Text = OpenD.FileName
	End If
End Sub

Private Sub frmCOMWrapperBuilder.cmdPathSource_Click(ByRef Sender As Control)
	Dim OpenD As OpenFileDialog
	OpenD.Filter = ML("Source Files") & " (*.* )|*.*|"
	If OpenD.Execute Then
		txtPathSource.Text = OpenD.FileName
	End If
End Sub

Function GetFolderName(ByRef FileName As WString) As UString
	Dim Pos1 As Long = InStrRev(FileName, "\")
	If Pos1 > 0 Then
		Return Left(FileName, Pos1)
	End If
	Return ""
End Function

Enum MethodTypes
	IsFunction
	IsProperty
End Enum

Type Method
	Name As WString * 100
	MethodType As MethodTypes
	ParamsCount As Integer
	ParamsText As UString
End Type

Declare Sub AddFunctions(ByRef Functions As WStringList, ByRef FLine As WString, bFirst As Boolean)

Function GetParams(ByRef Functions As WStringList, ByRef FLine As WString, ByRef bSet As Boolean, ByRef bFirst As Boolean, ByRef pCount As Integer) As UString
	Dim As Boolean bBracket = StartsWith(FLine, "("), bQuote
	Dim As UString Params
	Dim As Integer t, bCount
	pCount = 0
	bSet = False
	For i As Integer = 1 To Len(FLine) + 1
		t = Asc(Mid(FLine, i, 1))
		If t = Asc("""") Then
			bQuote = Not bQuote
		ElseIf Not bQuote Then
			If t = Asc("(") Then
				If i > 1 Then bCount += 1
			ElseIf t = Asc(")") Then
				If bCount = 0 Then
					If bBracket Then
						If Mid(FLine, i + 1, 1) = "." Then
							AddFunctions Functions, Mid(FLine, i + 2), bFirst
						End If
						If Trim(Mid(FLine, 2, i - 2), Any !"\t ") <> "" Then
							pCount += 1
							Params &= IIf(pCount = 1, "", ", ") & "ByRef Param" & Trim(WStr(pCount)) & " As " & "Object_" & comName
						End If
						If StartsWith(Trim(Mid(FLine, i + 1), Any !"\t "), "=") Then
							bSet = True
						End If
						Exit For
					End If
				Else
					bCount = -1
				End If
			ElseIf t = Asc("'") Then
				Exit For
			ElseIf bCount = 0 Then
				If bBracket OrElse bFirst Then
					If t = Asc(",") Then
						pCount += 1
						Params &= IIf(pCount = 1, "", ", ") & "ByRef Param" & Trim(WStr(pCount)) & " As " & "Object_" & comName
					ElseIf t = Asc("=") Then
						bSet = True
						Exit For
					ElseIf CInt(Not bBracket) AndAlso CInt(t = Asc(":") OrElse Mid(FLine, i, 1) = "") Then
						If Trim(Mid(FLine, 1, i - 1), Any !"\t ") <> "" Then
							pCount += 1
							Params &= IIf(pCount = 1, "", ", ") & "ByRef Param" & Trim(WStr(pCount)) & " As " & "Object_" & comName
						End If
						Exit For
					End If
				Else
					Exit For
				End If
			End If
		End If
	Next
	Return Params
End Function

Sub AddFunctions(ByRef Functions As WStringList, ByRef FLine As WString, bFirst As Boolean)
	Dim As Integer t, ParamCount
	Dim As WString Ptr SLine, Params
	Dim As WString * 255 MethodName
	Dim As Boolean bSet
	For i As Integer = 1 To Len(FLine) + 1
		t = Asc(Mid(FLine, i, 1))
		If t >= 48 AndAlso t <= 57 OrElse t >= 65 AndAlso t <= 90 OrElse t >= 97 AndAlso t <= 122 OrElse t = Asc("_") Then
			WAdd(SLine, Chr(t))
		Else
			If *SLine <> "" Then
				MethodName = *SLine
				ParamCount = 0
				bSet = False
				If t = Asc(".") Then
					AddFunctions(Functions, Mid(FLine, i + 1), bFirst)
				Else
					WLet(Params, GetParams(Functions, Trim(Mid(FLine, i), Any !"\t "), bSet, bFirst, ParamCount))
					If *Params <> "" Then WAdd(SLine, "(" & *Params & ")")
				End If
				Dim As Method Ptr m
				If Functions.Contains(*SLine) Then
					If bSet Then
						m = Functions.Object(Functions.IndexOf(*SLine))
						If m->MethodType = IsFunction Then
							m->MethodType = IsProperty
						End If
					End If
				ElseIf LCase(MethodName) <> "clear" AndAlso LCase(MethodName) <> "get" AndAlso _
					LCase(MethodName) <> "put" AndAlso LCase(MethodName) <> "set" Then
					m = New Method
					m->Name = MethodName
					m->MethodType = IIf(bSet, IsProperty, IsFunction)
					m->ParamsCount = ParamCount
					m->ParamsText = *Params
					Functions.Add *SLine, m
				End If
			End If
			Exit For
		End If
	Next
	Deallocate Params
	Deallocate SLine
End Sub

Function GetParamsByCount(iCount As Integer) As String
	Dim As String Params = """" & String(iCount, Asc("v")) & """"
	For i As Integer = 1 To iCount
		Params &= ", @Param" & Trim(WStr(i))
	Next
	Return Params
End Function

Private Sub frmCOMWrapperBuilder.cmdRun_Click(ByRef Sender As Control)
	Dim As String f, ComArg
	Dim As WString * 4096 Buff
	Dim As WString Ptr fileName, FLine, FoldName
	Dim As WString * 4096 SLine, FirstArg, TmpStr, TmpStr1
	Dim As WString Ptr DeclaresText, FunctionsText, DeclaresTextAll, FunctionsTextAll
	Dim As WStringList ComList, Files, Lines, Lines2, Args, WithArgs, Functions, Properties
	Dim As Integer Fn1 = FreeFile, Fn2, Pos1, Pos2, t, Result = -1
	Dim As Boolean bFlag, bNext, bWith, bComArg, bFirst
	txtMsg.Text = ""
	If txtPath.Text <> "" Then
		Result = Open(txtPath.Text For Input Encoding "utf-8" As #Fn1)
		If Result <> 0 Then Result = Open(txtPath.Text For Input Encoding "utf-16" As #Fn1)
		If Result <> 0 Then Result = Open(txtPath.Text For Input Encoding "utf-32" As #Fn1)
		If Result <> 0 Then Result = Open(txtPath.Text For Input As #Fn1)
		If Result = 0 Then
			Do Until EOF(Fn1)
				Line Input #Fn1, Buff
				If StartsWith(Buff, "File=") OrElse StartsWith(Buff, "*File=") Then
					Buff = Mid(Buff, InStr(Buff, "=") + 1)
					If InStr(Buff, ":") Then
						WLet fileName, Buff
					Else
						WLet fileName, GetFolderName(txtPath.Text) & Buff
					End If
					Files.Add *fileName
				End If
			Loop
			Close #Fn1
		End If
	ElseIf txtPathSource.Text <> "" Then
		Files.Add txtPathSource.Text
	Else
		MsgBox ML("File not selected!")
		txtMsg.Text = txtMsg.Text & Chr(13, 10) & ML("File not selected!")
		Deallocate fileName
		Deallocate FLine
		Deallocate FoldName
		Deallocate DeclaresText
		
		Deallocate FunctionsText
		Deallocate DeclaresTextAll
		Deallocate FunctionsTextAll
		Exit Sub
	End If
	For i As Integer = 0 To Files.Count - 1
		Fn1 = FreeFile
		Result = Open(Files.Item(i) For Input Encoding "utf-8" As #Fn1)
		If Result <> 0 Then Result = Open(Files.Item(i) For Input Encoding "utf-16" As #Fn1)
		If Result <> 0 Then Result = Open(Files.Item(i) For Input Encoding "utf-32" As #Fn1)
		If Result <> 0 Then Result = Open(Files.Item(i) For Input As #Fn1)
		If Result = 0 Then
			Do Until EOF(Fn1)
				Line Input #Fn1, Buff
				If bNext Then
					SLine = Lines.Item(Lines.Count - 1) & Buff
					Lines.Item(Lines.Count - 1) = SLine
				ElseIf EndsWith(Buff, " _") Then
					Lines.Add Mid(Buff, 1, Len(Buff) - 1)
				Else
					Lines.Add Buff
				End If
				bNext = EndsWith(Buff, " _")
				'If StartsWith(LCase(Trim(Buff, Any !"\t ")), "#include ") AndAlso _
				Pos2 = InStr(LCase(Buff), " createobject(")
				If Pos2 > 0 Then
					WLet fileName, Files.Item(i)
					bFlag = True
					Pos2 += Len(" createobject(") + 1
					Pos1 = InStr(Pos2, Buff, ".")
					If Pos1 < 1 Then Pos1 = InStr(Pos2, Buff, Chr(34))
					If Pos1 < 1 Then Pos1 = Len(Buff)
					'Debug.Print "Com Name=" & Trim(Mid(Buff, Pos2, Pos1 - Pos2))
					TmpStr = Trim(Mid(Buff, Pos2, Pos1 - Pos2))
					If TmpStr <> "" AndAlso Not ComList.Contains(TmpStr) Then ComList.Add TmpStr
				End If
			Loop
			Close #Fn1
		Else
			MsgBox "File """ & Files.Item(i) & """ not opened!"
			txtMsg.Text = txtMsg.Text & Chr(13, 10) & "File """ & Files.Item(i) & """ not opened!"
		End If
	Next
	
	If bFlag Then
		WLet(DeclaresTextAll, "") : WLet(FunctionsTextAll, "")
		WLet(FoldName, GetFolderName(*fileName))
		For jj As Integer = 0 To ComList.Count - 1
			comName = ComList.Item(jj)
			If Dir(*FoldName & "Com_" & comName & ".bi") <> "" Then Kill *FoldName & "Com_" & comName & ".bi"
		Next
		For jj As Integer = 0 To ComList.Count - 1
			comName = ComList.Item(jj)
			'WLet(FoldName, GetFolderName(*fileName))
			WLet(DeclaresText, ML("' Add Declares at")  + " " + Str(Time) + ", " + Str(Date))
			WLet(FunctionsText, ML("' Add Functions at") + " " + Str(Time) + ", " + Str(Date))
			TmpStr = "" : TmpStr1 = ""
			Properties.Clear : Functions.Clear : Args.Clear
			For i As Integer = 0 To Lines.Count - 1
				FLine = @Lines.Item(i)
				If StartsWith(LCase(Trim(*FLine, Any !"\t ")), "dim ") Then
					Dim As UString res(Any)
					SLine = Trim(LCase(Mid(Trim(*FLine, Any !"\t "), 5)), Any !"\t ")
					If StartsWith(SLine, "as ") Then
						SLine = Trim(Mid(SLine, 4), Any !"\t ")
						If StartsWith(LCase(SLine), LCase("Object_" & comName & " ")) Then
							Split(Mid(SLine, Len("Object_" & comName & " ")), ",", res())
							For j As Integer = 0 To UBound(res)
								Pos1 = InStr(res(j), "=")
								If Pos1 > 0 Then
									res(j) = ..Left(res(j), Pos1 - 1)
								End If
								Pos1 = InStr(res(j), "'")
								If Pos1 > 0 Then
									res(j) = ..Left(res(j), Pos1 - 1)
								End If
								res(j) = Trim(res(j), Any !"\t ")
								Args.Add res(j)
							Next
						End If
					Else
						Split(SLine, ",", res())
						For j As Integer = 0 To UBound(res)
							Pos1 = InStr(res(j), "=")
							If Pos1 > 0 Then
								res(j) = ..Left(res(j), Pos1 - 1)
							End If
							Pos1 = InStr(res(j), "'")
							If Pos1 > 0 Then
								res(j) = ..Left(res(j), Pos1 - 1)
							End If
							Pos1 = InStr(LCase(res(j)), " as ")
							If Pos1 > 0 Then
								If Trim(Mid(LCase(res(j)), Pos1 + 4), Any !"\t ") = LCase("Object_" & comName) Then
									res(j) = ..Left(res(j), Pos1 - 1)
									res(j) = Trim(res(j), Any !"\t ")
									Args.Add res(j)
								End If
							End If
						Next
					End If
				End If
			Next
			For i As Integer = 0 To Lines.Count - 1
				FLine = @Lines.Item(i)
				SLine = ""
				FirstArg = "0"
				bFirst = True
				For j As Integer = 1 To Len(*FLine) + 1
					t = Asc(Mid(*FLine, j, 1))
					If t >= 48 AndAlso t <= 57 OrElse t >= 65 AndAlso t <= 90 OrElse t >= 97 AndAlso t <= 122 OrElse t > 127 OrElse t = Asc("_") Then
						SLine &= Chr(t)
					ElseIf t = Asc(".") Then
						If SLine = "" Then
							If bComArg Then
								AddFunctions Functions, Mid(*FLine, j + 1), bFirst
							End If
						Else
							If FirstArg = "0" AndAlso LCase(SLine) <> "with" Then FirstArg = SLine
							If Args.Contains(SLine) Then
								AddFunctions Functions, Mid(*FLine, j + 1), bFirst
							End If
						End If
						bFirst = False
						SLine = ""
					ElseIf t = Asc("'") Then
						Exit For
					Else
						If SLine <> "" Then
							If FirstArg = "0" AndAlso LCase(SLine) <> "with" Then FirstArg = SLine
							bFirst = False
						End If
						SLine = ""
					End If
				Next
				bWith = StartsWith(Trim(LCase(*FLine), Any !"\t "), "with ")
				If bWith Then
					ComArg = ""
					If FirstArg <> "0" AndAlso Args.Contains(FirstArg) Then ComArg = "1": bComArg = True
					WithArgs.Add ComArg
				ElseIf StartsWith(Trim(LCase(*FLine), Any !"\t "), "end with") Then
					If WithArgs.Count > 0 Then
						If WithArgs.Item(WithArgs.Count - 1) = "1" Then bComArg = False
						WithArgs.Remove WithArgs.Count - 1
					End If
				End If
			Next i
			Dim As Method Ptr m
			For i As Integer = 0 To Functions.Count - 1
				m = Functions.Object(i)
				If m->MethodType = IsProperty Then
					Properties.Add m->Name, m
				End If
			Next
			For i As Integer = 0 To Functions.Count - 1
				m = Functions.Object(i)
				If m->MethodType = IsFunction AndAlso Properties.Contains(m->Name) Then m->MethodType = IsProperty
				If m->MethodType = IsProperty Then
					TmpStr = !"\r\n\tDeclare Property " & m->Name & IIf(m->ParamsText = "", "", "(" & m->ParamsText & ")") & " As " & "Object_" & comName & _
					!"\r\n\tDeclare Property " & m->Name & "(" & m->ParamsText & IIf(m->ParamsText = "", "", ", ") & "ByRef Param" & Trim(WStr(m->ParamsCount + 1)) & " As " & "Object_" & comName & ")"
					TmpStr1 = !"\r\nProperty " & "Object_" & comName & "." & m->Name & IIf(m->ParamsText = "", "", "(" & m->ParamsText & ")") & " As " & "Object_" & comName & _
					!"\r\n\tReturn This.Get(""" & m->Name & """" & IIf(m->ParamsCount = 0, "", ", " & GetParamsByCount(m->ParamsCount)) & !")\r\n" & _
					!"End Property\r\n" & _
					"Property " & "Object_" & comName & "." & m->Name & "(" & m->ParamsText & IIf(m->ParamsText = "", "", ", ") & "ByRef Param" & Trim(WStr(m->ParamsCount + 1)) & " As " & "Object_" & comName & ")" & _
					!"\r\n\tThis.Put(""" & m->Name & """, " & GetParamsByCount(m->ParamsCount + 1) & !")\r\n" & _
					"End Property"
					If InStr(*DeclaresTextAll, TmpStr) < 1 Then WAdd(DeclaresText, TmpStr)
					If InStr(*FunctionsTextAll, TmpStr1) < 1 Then WAdd(FunctionsText, TmpStr1)
				Else
					TmpStr = !"\r\n\tDeclare Function " & Functions.Item(i) & " As " & "Object_" & comName
					TmpStr1 = !"\r\nFunction " & "Object_" & comName & "." & Functions.Item(i) & " As " & "Object_" & comName & _
					!"\r\n\tReturn This.Get(""" & m->Name & """" & IIf(m->ParamsCount = 0, "", ", " & GetParamsByCount(m->ParamsCount)) & !")\r\n" & _
					"End Function"
					If InStr(*DeclaresTextAll, TmpStr) < 1 Then WAdd(DeclaresText, TmpStr)
					If InStr(*FunctionsTextAll, TmpStr1) < 1 Then WAdd(FunctionsText, TmpStr1)
				End If
			Next
			WAdd(DeclaresTextAll, *DeclaresText) : WAdd(FunctionsTextAll, *FunctionsText)
			Dim As Boolean FileEx = Dir(*FoldName & "Com_" & comName & ".bi") <> ""
			Fn1 = FreeFile
			If FileEx Then
				WLet(fileName, *FoldName & "Com_" & comName & ".bi")
			Else
				WLet(fileName, ExePath & "\SimpleVariantPlusTemplate.bi")
			End If
			Result = Open(*fileName For Input Encoding "utf-8" As #Fn1)
			If Result <> 0 Then Result = Open(*fileName For Input Encoding "utf-16" As #Fn1)
			If Result <> 0 Then Result = Open(*fileName For Input Encoding "utf-32" As #Fn1)
			If Result <> 0 Then Result = Open(*fileName For Input As #Fn1)
			If Result = 0 Then
				Lines2.Clear
				Do Until EOF(Fn1)
					Line Input #Fn1, Buff
					Lines2.Add Buff
				Loop
				Close #Fn1
			Else
				MsgBox ML("File not opened!") & " " & *fileName
				txtMsg.Text = txtMsg.Text & Chr(13, 10) & ML("File not opened!") & " " & *fileName
				Deallocate fileName
				Deallocate FLine
				Deallocate FoldName
				Deallocate DeclaresText
				Deallocate FunctionsText
				Deallocate DeclaresTextAll
				Deallocate FunctionsTextAll
				Exit Sub
			End If
			Fn1 = FreeFile
			WLet(fileName, *FoldName & "Com_" & comName & ".bi")
			If Open(*fileName For Output Encoding "utf-8" As #Fn1) = 0 Then
				For i As Integer = 0 To Lines2.Count - 1
					If Trim(LCase(Lines2.Item(i)), Any !"\t ") = "'_com_declares" AndAlso Trim(*DeclaresText) <> "" Then
						Print #Fn1, *DeclaresText
						Print #Fn1, ""
						Print #Fn1, Lines2.Item(i)
						Print #Fn1, ""
					ElseIf Trim(LCase(Lines2.Item(i)), Any !"\t ") = "'_com_functions"  AndAlso Trim(*FunctionsText) <> ""  Then
						Print #Fn1, *FunctionsText
						Print #Fn1, ""
						Print #Fn1, Lines2.Item(i)
						Print #Fn1, ""
					Else
						Print #Fn1, Replace(Lines2.Item(i), "Object_Com_", "Object_" & comName)
					End If
				Next
			Else
				MsgBox ML("File not saved!") & " " & *fileName
				txtMsg.Text = txtMsg.Text & Chr(13, 10) & ML("File not saved!") & " " & *fileName
			End If
			Close #Fn1
			lblPathSVP.Caption = *fileName
			txtMsg.Text = txtMsg.Text & Chr(13, 10) & "-----------------------------------"
			txtMsg.Text = txtMsg.Text & Chr(13, 10) & *fileName & " " & IIf(FileEx, ML("is changed"), ML("is created")) & "!" & Chr(13, 10) _
			& " " & ML("Please add the following code in modules!") & Chr(13, 10) & "#include once " & Chr(34) & "Com_" & comName & ".bi"  & Chr(34)
			txtMsg.Text = txtMsg.Text & Chr(13, 10)
		Next
	Else
		MsgBox ML("Not find the code 'CreateObject' in modules!")
		
	End If
	Deallocate fileName
	Deallocate FLine
	Deallocate FoldName
	Deallocate DeclaresText
	Deallocate FunctionsText
	Deallocate DeclaresTextAll
	Deallocate FunctionsTextAll
End Sub

Private Sub frmCOMWrapperBuilder.cmdExit_Click(ByRef Sender As Control)
	frm.CloseForm
End Sub

Sub RunPr(Param As Any Ptr)
	Shell "notepad.exe " & frm.lblPathSVP.Caption
End Sub

Private Sub frmCOMWrapperBuilder.cmdExplore_Click(ByRef Sender As Control)
	ThreadCreate(@RunPr)
End Sub

