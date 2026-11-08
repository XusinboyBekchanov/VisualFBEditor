'#########################################################
'#  DebugCommon.bas                                      #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#########################################################

'The common part of the debuggers which run as other processes and talk with the IDE through pipes:
'lldb with its commands (DebugLLDB.bas), gdb and lldb-mi with the machine interface (DebugMI.bas), gdb and lldb-dap with
'the Debug Adapter Protocol (DebugDAP.bas). Here: the start of such a debugger with pipes, the frames of a stop, the
'variables in Locals, Globals and Watches and the line of the stop in the editor.
'gdb and lldb read the information of the program in DWARF: the program is compiled with -gen gcc -g. gas and gas64
'write their own information (.dbgdat, .dbgstr) which only Integrated IDE Debugger reads.

#ifdef __FB_WIN32__
	#include once "windows.bi"
#else
	Extern "C"
		Declare Function dbg_pipe Alias "pipe" (ByVal fds As Long Ptr) As Long
		Declare Function dbg_close Alias "close" (ByVal fd As Long) As Long
		Declare Function dbg_read Alias "read" (ByVal fd As Long, ByVal buf As Any Ptr, ByVal n As UInteger) As Integer
		Declare Function dbg_write Alias "write" (ByVal fd As Long, ByVal buf As Const Any Ptr, ByVal n As UInteger) As Integer
		Declare Function dbg_waitpid Alias "waitpid" (ByVal pid As Long, ByVal status As Long Ptr, ByVal options As Long) As Long
		Declare Function dbg_signal Alias "signal" (ByVal sig As Long, ByVal handler As Any Ptr) As Any Ptr
		Declare Function dbg_kill Alias "kill" (ByVal pid As Long, ByVal sig As Long) As Long
		Declare Function dbg_setenv Alias "setenv" (ByVal name_ As Const ZString Ptr, ByVal value As Const ZString Ptr, ByVal overwrite As Long) As Long
		Declare Function dbg_spawn_init Alias "posix_spawn_file_actions_init" (ByVal fa As Any Ptr) As Long
		Declare Function dbg_spawn_dup2 Alias "posix_spawn_file_actions_adddup2" (ByVal fa As Any Ptr, ByVal fd As Long, ByVal newfd As Long) As Long
		Declare Function dbg_spawn_close Alias "posix_spawn_file_actions_addclose" (ByVal fa As Any Ptr, ByVal fd As Long) As Long
		Declare Function dbg_spawn_destroy Alias "posix_spawn_file_actions_destroy" (ByVal fa As Any Ptr) As Long
		Declare Function dbg_spawnp Alias "posix_spawnp" (ByVal pid As Long Ptr, ByVal file As Const ZString Ptr, ByVal fa As Any Ptr, ByVal attr As Any Ptr, ByVal argv As ZString Ptr Ptr, ByVal envp As ZString Ptr Ptr) As Long
		#ifdef __FB_DARWIN__
			Declare Function dbg_environ Alias "_NSGetEnviron" () As ZString Ptr Ptr Ptr
		#else
			Extern dbg_environ_ptr Alias "environ" As ZString Ptr Ptr
		#endif
	End Extern
#endif

'A debugger as a process: the IDE writes to its input and reads its output (with its errors)
Type DbgProcessType
	Pid As Long
	#ifdef __FB_WIN32__
		hProcess As HANDLE
		hInput As HANDLE
		hOutput As HANDLE
	#else
		FdIn As Long = -1
		FdOut As Long = -1
	#endif
End Type

Type DbgFrameType
	Func As String
	File As String
	LineNo As Integer
End Type

'The debugger which runs now (DbgBackend): its commands, its stops and its end are of its file
Enum DbgBackends
	DbgNone
	DbgLLDBCLI
	DbgMI
	DbgDAP
End Enum

Dim Shared As DbgBackends DbgBackend
Dim Shared As Any Ptr DbgWriteMutex
DbgWriteMutex = MutexCreate
Dim Shared DbgFrames(Any) As DbgFrameType
Dim Shared As Integer DbgFrameIndex = -1
'The values of the variables of the last stop (Watches, the hint of a variable): the names are like P.X
Dim Shared As String DbgNames(Any), DbgValues(Any), DbgTypes(Any)
Dim Shared As Integer DbgVariablesCount

Function DbgText(ByRef s As String) As UString
	If s = "" Then Return ""
	Dim As WString Ptr p = FromUtf8(StrPtr(s))
	If p = 0 Then Return s
	Dim As UString Result = *p
	WDeAllocate(p)
	Return Result
End Function

Function DbgQuote(ByRef s As WString) As UString
	Return """" & Replace(Replace(s, "\", "\\"), """", "\""") & """"
End Function

'A path for the commands of the debuggers
Function DbgPath(ByRef FileName As WString) As UString
	Return Replace(FileName, "\", "/")
End Function

'The name of a variable of the C code of fbc: I$0 -> I; the temporary variables (vr$5, tmp$1, fb$result$1) and the ones
'of the runtime (__FB_ARGC__) are not shown
'The names shown (ARR) and their names in the C code (ARR$0, COUNTER$) for the commands of the debugger
Dim Shared As String DbgShownNames(Any), DbgCNames(Any)

Function DbgName(ByRef CName As String) As String
	Dim As String s = CName
	Dim As Integer p = InStrRev(s, "$")
	If p > 1 AndAlso p < Len(s) AndAlso Trim(Mid(s, p + 1), Any "0123456789") = "" Then s = Left(s, p - 1)
	If InStr(s, "$") > 0 OrElse StartsWith(s, "__FB_") Then Return ""
	If s <> UCase(s) Then Return ""
	If s <> CName Then
		Dim As Integer n = UBound(DbgShownNames) + 1
		For i As Integer = 0 To n - 1
			If DbgShownNames(i) = s Then DbgCNames(i) = CName: Return s
		Next
		ReDim Preserve DbgShownNames(n), DbgCNames(n)
		DbgShownNames(n) = s: DbgCNames(n) = CName
	End If
	Return s
End Function

'The expression of the C code of a shown expression (ARR(1) -> ARR$0[1], COUNTER -> COUNTER$): its first name
Function DbgCExpression(ByRef sExpr As String) As String
	Dim As Integer p = InStr(sExpr, Any ".[(")
	Dim As String sFirst = IIf(p, Left(sExpr, p - 1), sExpr)
	For i As Integer = 0 To UBound(DbgShownNames)
		If DbgShownNames(i) = sFirst Then Return DbgCNames(i) & IIf(p, Mid(sExpr, p), "")
	Next
	Return sExpr
End Function

'The type of the characters of WString in the C code of fbc: wchar_t of Windows has 2 bytes
#ifdef __FB_WIN32__
	#define WSTRING_CTYPE "uint16"
#else
	#define WSTRING_CTYPE "uint32"
#endif

'The type of the C code of fbc with the names of FreeBASIC
Function DbgType(ByRef CType As String, ByRef Value As String = "") As String
	Dim As String s = Trim(CType), Suffix
	'WString * N, ZString * N: the arrays of C of their characters
	Dim As Integer iBracket = InStr(s, "[")
	If iBracket > 0 AndAlso Right(s, 1) = "]" Then
		Dim As String sCount = Mid(s, iBracket + 1, Len(s) - iBracket - 1)
		Select Case RTrim(Left(s, iBracket - 1))
		Case WSTRING_CTYPE: Return "WString * " & sCount
		Case "char", "uint8": Return "ZString * " & sCount
		End Select
	End If
	'A WString Ptr is a uint32 * (uint16 * on Windows): its text is L"..." (vfbe_lldb.py, DbgWideText)
	If s = WSTRING_CTYPE & " *" OrElse s = "const " & WSTRING_CTYPE & " *" Then Return "WString Ptr"
	If s = "char *" OrElse s = "const char *" Then Return "ZString Ptr"
	While Right(s, 1) = "*"
		Suffix &= " Ptr"
		s = RTrim(Left(s, Len(s) - 1))
	Wend
	If StartsWith(s, "const ") Then s = Mid(s, 7)
	If StartsWith(s, "struct ") Then s = Mid(s, 8)
	If Left(s, 1) = "$" Then s = LTrim(Mid(s, 2), Any "0123456789")
	Select Case s
	Case "int8": s = "Byte"
	Case "uint8": s = "UByte"
	Case "int16": s = "Short"
	Case "uint16": s = "UShort"
	Case "int32": s = "Long"
	Case "uint32": s = "ULong"
	Case "int64"
		#ifdef __FB_64BIT__
			s = "Integer"
		#else
			s = "LongInt"
		#endif
	Case "uint64"
		#ifdef __FB_64BIT__
			s = "UInteger"
		#else
			s = "ULongInt"
		#endif
	Case "float": s = "Single"
	Case "double": s = "Double"
	Case "boolean": s = "Boolean"
	Case "FBSTRING": s = "String"
	Case "void": s = "Any"
	End Select
	Return s & Suffix
End Function

'The text of a String of gdb: {data = 0x4c2530 "Salom", len = 5, size = 32} -> "Salom"
Function DbgStringValue(ByRef Value As String) As String
	If Left(Value, 1) <> "{" OrElse InStr(Value, "data = ") = 0 OrElse InStr(Value, "len = ") = 0 Then Return Value
	Dim As Integer p = InStr(Value, "data = "), q
	p = InStr(p, Value, """")
	If p = 0 Then Return """"""
	q = p + 1
	Do While q <= Len(Value)
		If Mid(Value, q, 1) = "\" Then
			q += 2
		ElseIf Mid(Value, q, 1) = """" Then
			Exit Do
		Else
			q += 1
		End If
	Loop
	Return Mid(Value, p, q - p + 1)
End Function

'The parts of a value of gdb {X = 3, Y = 4}, {1, 2, 3} or of lldb (X = 3, Y = 4): the commas of the first level
Sub DbgSplitValue(ByRef Value As String, Parts() As String)
	Erase Parts
	Dim As String Inner = Mid(Value, 2, Len(Value) - 2)
	Dim As Integer Level, iStart = 1
	Dim As Boolean InQuotes
	For i As Integer = 1 To Len(Inner)
		Dim As String c = Mid(Inner, i, 1)
		If InQuotes Then
			If c = "\" Then
				i += 1
			ElseIf c = """" Then
				InQuotes = False
			End If
		ElseIf c = """" Then
			InQuotes = True
		ElseIf c = "{" OrElse c = "(" OrElse c = "[" Then
			Level += 1
		ElseIf c = "}" OrElse c = ")" OrElse c = "]" Then
			Level -= 1
		ElseIf c = "," AndAlso Level = 0 Then
			Dim As Integer n = UBound(Parts) + 1
			ReDim Preserve Parts(n)
			Parts(n) = Trim(Mid(Inner, iStart, i - iStart))
			iStart = i + 1
		End If
	Next
	If Trim(Mid(Inner, iStart)) <> "" Then
		Dim As Integer n = UBound(Parts) + 1
		ReDim Preserve Parts(n)
		Parts(n) = Trim(Mid(Inner, iStart))
	End If
End Sub

Function DbgIsCompound(ByRef Value As String) As Boolean
	If Len(Value) < 2 Then Return False
	If Left(Value, 1) = "{" AndAlso Right(Value, 1) = "}" Then Return True
	'lldb: (X = 3, Y = 4)
	Return Left(Value, 1) = "(" AndAlso Right(Value, 1) = ")" AndAlso InStr(Value, " = ") > 0
End Function

Declare Function DbgWideText(ByRef Bytes As String) As String

'gdb with -gen gas (stabs): wchar is a char, a WString is "T\000a\000h\000o\000m\000a\000": its text L"Tahoma"
'(every quoted text of the value, also the fields of {...})
Function DbgWideCharsValue(ByRef sValue As String, ByRef sType As String = "") As String
	Dim As String Result, Bytes
	Dim As Integer i = 1, p1, iCount
	Do While i <= Len(sValue)
		Dim As String c = Mid(sValue, i, 1)
		If c <> """" OrElse (i > 1 AndAlso Mid(sValue, i - 1, 1) = "L") Then
			'Not a text, or a text of wchar_t (L"...")
			If c = """" Then
				p1 = i
				i += 1
				Do While i <= Len(sValue) AndAlso Mid(sValue, i, 1) <> """"
					If Mid(sValue, i, 1) = "\" Then i += 1
					i += 1
				Loop
				Result &= Mid(sValue, p1, i - p1 + 1)
				i += 1
			Else
				Result &= c
				i += 1
			End If
			Continue Do
		End If
		'The bytes of the text
		p1 = i
		Bytes = ""
		i += 1
		Do While i <= Len(sValue)
			c = Mid(sValue, i, 1)
			If c = """" Then Exit Do
			If c = "\" AndAlso i < Len(sValue) Then
				Dim As String e = Mid(sValue, i + 1, 1)
				Select Case e
				Case "0" To "7"
					Dim As Integer Code, k = i + 1
					While k <= Len(sValue) AndAlso k <= i + 3 AndAlso Mid(sValue, k, 1) >= "0" AndAlso Mid(sValue, k, 1) <= "7"
						Code = Code * 8 + Val(Mid(sValue, k, 1))
						k += 1
					Wend
					Bytes &= Chr(Code And 255)
					i = k
				Case "n": Bytes &= Chr(10): i += 2
				Case "t": Bytes &= Chr(9): i += 2
				Case "r": Bytes &= Chr(13): i += 2
				Case Else: Bytes &= e: i += 2
				End Select
			Else
				Bytes &= c
				i += 1
			End If
		Loop
		iCount += 1
		'A WString: the bytes after the characters are 0 (or the type is wchar)
		Dim As Boolean bWide = Len(Bytes) >= 2
		If bWide AndAlso InStr(LCase(sType), "wchar") = 0 Then
			For j As Integer = 2 To Len(Bytes) Step 2
				If Bytes[j - 1] <> 0 Then bWide = False: Exit For
			Next
		End If
		If bWide Then
			Result &= DbgWideText(Bytes & Chr(0, 0, 0, 0))
		Else
			Result &= Mid(sValue, p1, i - p1 + 1)
		End If
		i += 1
	Loop
	Return Result
End Function

'A variable in Locals, Globals or a field of a variable; its name for Watches: Path
Function DbgAddVariable(lv As TreeListView Ptr, Parent As TreeListViewItem Ptr, ByRef Path As String, ByRef sName As String, ByRef sValue As String, ByRef sType As String) As TreeListViewItem Ptr
	If DbgVariablesCount >= 2000 Then Return 0
	Dim As TreeListViewItem Ptr Item
	Dim As String sShown = IIf(sType = "String" OrElse sType = "FBSTRING", DbgStringValue(sValue), sValue)
	sShown = DbgWideCharsValue(sShown, IIf(DbgIsCompound(sShown), "", sType))
	If Parent = 0 Then
		Item = lv->Nodes.Add(DbgText(sName))
	Else
		Item = Parent->Nodes.Add(DbgText(sName))
	End If
	If DbgIsCompound(sShown) Then
		Item->Text(1) = DbgText(IIf(Len(sShown) > 200, Left(sShown, 200) & "...", sShown))
	Else
		Item->Text(1) = DbgText(sShown)
	End If
	Item->Text(2) = sType
	DbgVariablesCount += 1
	Dim As Integer n = UBound(DbgNames) + 1
	ReDim Preserve DbgNames(n), DbgValues(n), DbgTypes(n)
	DbgNames(n) = UCase(Path): DbgValues(n) = sShown: DbgTypes(n) = sType
	Return Item
End Function

'The fields and the items of a value of gdb or lldb as its children
Sub DbgAddValueChildren(lv As TreeListView Ptr, Item As TreeListViewItem Ptr, ByRef Path As String, ByRef Value As String, Depth As Integer = 0)
	If CBool(Item = 0) OrElse CBool(Depth > 5) OrElse DbgIsCompound(Value) = False Then Exit Sub
	Dim As String Parts()
	DbgSplitValue Value, Parts()
	For i As Integer = 0 To UBound(Parts)
		Dim As String sName, sValue
		Dim As Integer p = InStr(Parts(i), " = ")
		'The names of the fields begin with a letter or _ (not the values like "a = b" of a text)
		If p > 0 AndAlso InStr(Left(Parts(i), p - 1), """") = 0 Then
			sName = Left(Parts(i), p - 1)
			sValue = Mid(Parts(i), p + 3)
		Else
			sName = "[" & i & "]"
			sValue = Parts(i)
		End If
		Dim As String sPath = Path & IIf(Left(sName, 1) = "[", "", ".") & sName
		Dim As String sType = IIf(InStr(sValue, "data = ") > 0 AndAlso InStr(sValue, "len = ") > 0, "String", "")
		Var Child = DbgAddVariable(lv, Item, sPath, sName, sValue, sType)
		If sType = "" Then DbgAddValueChildren lv, Child, sPath, sValue, Depth + 1
	Next
End Sub

Sub DbgClearVariables()
	Erase DbgNames, DbgValues, DbgTypes
	Erase DbgShownNames, DbgCNames
	DbgVariablesCount = 0
End Sub

Function DbgFindValue(ByRef VarName As String, ByRef VarType As String = "") As String
	Dim As String sName = UCase(Trim(VarName))
	For i As Integer = 0 To UBound(DbgNames)
		If DbgNames(i) = sName Then VarType = DbgTypes(i): Return DbgValues(i)
	Next
	VarType = ""
	Return ""
End Function

Function DbgShownValue(ByRef sValue As String, ByRef sType As String) As UString
	If sType = "" AndAlso sValue = "" Then Return ML("No symbol in the current context")
	Return DbgText(sValue)
End Function

Function DbgGetValue(ByRef VarName As String) As String
	Return DbgFindValue(VarName)
End Function

Function DbgHasValue(ByRef VarName As String) As Boolean
	Dim As String sName = UCase(Trim(VarName))
	For i As Integer = 0 To UBound(DbgNames)
		If DbgNames(i) = sName Then Return True
	Next
	Return False
End Function

Sub DbgUpdateWatches()
	For i As Integer = 0 To lvWatches.Nodes.Count - 1
		Dim As String sName = ToUtf8(lvWatches.Nodes.Item(i)->Text(0)), sType
		If Trim(sName) = "" Then Continue For
		Dim As String sValue = DbgFindValue(sName, sType)
		If DbgHasValue(sName) Then
			lvWatches.Nodes.Item(i)->Text(1) = DbgText(sValue)
		Else
			lvWatches.Nodes.Item(i)->Text(1) = ML("No symbol in the current context")
		End If
		lvWatches.Nodes.Item(i)->Text(2) = sType
	Next
End Sub

'The value of a word of the editor (the hint of a variable, Show Var, Add Watch)
Sub DbgShowWord(ByRef sCommand As String)
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	Dim As String sWord = Trim(ToUtf8(tb->txtCode.GetWordAtCursor))
	If sWord = "" Then Exit Sub
	Dim As String sType, sValue = DbgFindValue(sWord, sType)
	Dim As UString sShown = IIf(DbgHasValue(sWord), DbgText(sValue), ML("No symbol in the current context"))
	If sCommand = "ShowVar" Then
		ShowMessages DbgText(sWord) & " = " & sShown & IIf(sType = "", "", " (" & sType & ")")
	Else
		If lvWatches.Nodes.Count = 0 OrElse lvWatches.Nodes.Item(lvWatches.Nodes.Count - 1)->Text(0) <> "" Then lvWatches.Nodes.Add
		Var Item = lvWatches.Nodes.Item(lvWatches.Nodes.Count - 1)
		Item->Text(0) = DbgText(sWord)
		Item->Text(1) = sShown
		Item->Text(2) = sType
		lvWatches.Nodes.Add
		tpWatches->Caption = ML("Watches") & " (" & Str(lvWatches.Nodes.Count - 1) & " " & ML("Pos") & ")"
		DbgViewInvalidate
		tpWatches->SelectTab
	End If
End Sub

'A text of the debugger or of the program in the Output: its lines without the last line end
Sub DbgShowText(ByRef Text As String)
	Dim As String s = Replace(Text, Chr(13), "")
	'The codes of a terminal (ESC [ ... letter) which lldb-mi writes with the output of the program
	Dim As Integer e = InStr(s, Chr(27) & "[")
	While e > 0
		Dim As Integer k = e + 2
		While k <= Len(s) AndAlso InStr("0123456789;?", Mid(s, k, 1)) > 0
			k += 1
		Wend
		s = Left(s, e - 1) & Mid(s, k + 1)
		e = InStr(e, s, Chr(27) & "[")
	Wend
	If Right(s, 1) = Chr(10) Then s = Left(s, Len(s) - 1)
	If s = "" Then Exit Sub
	Dim As WString Ptr Lines()
	Split DbgText(s), Chr(10), Lines()
	For i As Integer = 0 To UBound(Lines)
		ShowMessages *Lines(i), False
		_Deallocate(Lines(i))
	Next
	Erase Lines
End Sub

#ifdef __FB_WIN32__
	'The names of the folders and of the file as they are on the disk: C:\A\FORM.BAS -> C:\Form.bas
	Function DbgDiskCase(ByRef Path As WString) As UString
		If Mid(Path, 2, 1) <> ":" Then Return Path
		Dim As UString Result = UCase(Left(Path, 2))
		Dim As WString Ptr Parts()
		Split Mid(Path, 3), "\", Parts()
		For i As Integer = 0 To UBound(Parts)
			If *Parts(i) = "" Then Continue For
			Dim As WIN32_FIND_DATAW fd
			Dim As HANDLE h = INVALID_HANDLE_VALUE
			If *Parts(i) <> "." AndAlso *Parts(i) <> ".." Then h = FindFirstFileW(Result & "\" & *Parts(i), @fd)
			If h <> INVALID_HANDLE_VALUE Then
				Result &= "\" & fd.cFileName
				FindClose h
			Else
				Result &= "\" & *Parts(i)
			End If
		Next
		For i As Integer = 0 To UBound(Parts)
			_Deallocate(Parts(i))
		Next
		Erase Parts
		Return Result
	End Function
#endif

'The full path of a source file of a frame: gcc of fbc gets the files without their folders, the debuggers give
'them as UNTITLED.BAS or as /UNTITLED.BAS (lldb-mi: the empty folder and the name): they are in the folder of the
'program; on Windows the names are written as on the disk (DWARF of fbc has them in capitals)
Function DbgSourcePath(ByRef File As String) As UString
	Dim As UString s = DbgText(File)
	If s = "" OrElse InStr(s, "`") > 0 Then Return s
	#ifdef __FB_WIN32__
		s = Replace(s, "/", "\")
		'lldb-mi: \C:\crossdev\...
		If Left(s, 1) = "\" AndAlso Mid(s, 3, 1) = ":" Then s = Mid(s, 2)
		If Mid(s, 2, 1) <> ":" AndAlso Left(s, 2) <> "\\" Then
			Dim As UString sName = LTrim(s, "\")
			Dim As UString sFolder = GetFolderName(exename)
			If sFolder <> "" AndAlso FileExists(sFolder & sName) Then
				s = sFolder & sName
			ElseIf FileExists(CurDir & "\" & sName) Then
				s = CurDir & "\" & sName
			End If
		End If
		If FileExists(s) Then s = DbgDiskCase(s)
	#else
		If Left(s, 1) <> "/" Then
			Dim As UString sFolder = GetFolderName(exename)
			If sFolder <> "" AndAlso FileExists(sFolder & s) Then s = sFolder & s
		End If
	#endif
	Return s
End Function

'The first frame with a line of a file of the program (the paths of the files of the frames become full paths)
Function DbgProgramFrame() As Integer
	Dim As Integer Result = -1
	For i As Integer = 0 To UBound(DbgFrames)
		Dim As String sFile = LCase(DbgFrames(i).File)
		If CBool(DbgFrames(i).LineNo <= 0) OrElse CBool(sFile = "") Then Continue For
		DbgFrames(i).File = ToUtf8(DbgSourcePath(DbgFrames(i).File))
		If CBool(Result >= 0) OrElse EndsWith(sFile, ".c") OrElse EndsWith(sFile, ".h") OrElse EndsWith(sFile, ".s") Then Continue For
		'lldb-dap: the disassembly of a function without lines has the path module`function
		If InStr(sFile, "`") > 0 OrElse Not FileExists(DbgText(DbgFrames(i).File)) Then Continue For
		Result = i
	Next
	Return Result
End Function

Sub DbgShowFrames()
	DbgViewDataChanging
	lvThreads.Nodes.Clear
	For i As Integer = 0 To UBound(DbgFrames)
		Var Item = lvThreads.Nodes.Add(DbgText(DbgFrames(i).Func))
		If DbgFrames(i).LineNo > 0 Then Item->Text(1) = WStr(DbgFrames(i).LineNo)
		Item->Text(2) = DbgText(DbgFrames(i).File)
	Next
	tpThreads->Caption = ML("Threads") & " (" & lvThreads.Nodes.Count & " " & ML("Pos") & ")"
End Sub

'The line of the stop in the editor
Sub DbgShowCursor()
	DeleteDebugCursor
	If DbgFrameIndex < 0 OrElse DbgFrameIndex > UBound(DbgFrames) Then Exit Sub
	Dim As UString FileName = DbgText(Replace(DbgFrames(DbgFrameIndex).File, "/", Slash))
	Dim As Integer LineNo = DbgFrames(DbgFrameIndex).LineNo
	If LineNo < 1 OrElse FileName = "" Then Exit Sub
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 OrElse Not EqualPaths(tb->FileName, FileName) Then tb = AddTab(FileName)
	If tb <> 0 Then
		CurEC = @tb->txtCode
		tb->txtCode.CurExecutedLine = LineNo - 1
		tb->txtCode.SetSelection LineNo - 1, LineNo - 1, 0, 0
		tb->txtCode.PaintControl
	End If
	#ifdef __USE_WINAPI__
		SetForegroundWindow pApp->MainForm->Handle
	#endif
End Sub

Sub DbgShowCaptions()
	tpLocals->Caption = ML("Locals") & " (" & lvLocals.Nodes.Count & " " & ML("Pos") & ")"
	tpGlobals->Caption = ML("Globals") & " (" & lvGlobals.Nodes.Count & " " & ML("Pos") & ")"
	DbgViewInvalidate
End Sub

'The current line of the editor: Breakpoint, Run To Cursor, Set Next Statement
Function DbgCursorPlace(ByRef FileName As UString, ByRef LineNo As Integer) As Boolean
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Return False
	Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	FileName = tb->FileName
	LineNo = iSelEndLine + 1
	Return True
End Function

'The files with breakpoints and their lines: Files(i), Lines(i) = "7,12"
'Breakpoint Hit Count of the line LineNo (from 1) of the open file FileName: 0 - every time
Function DbgBreakpointCount(ByRef FileName As WString, LineNo As Integer) As Integer
	For jj As Integer = 0 To TabPanels.Count - 1
		Var ptabCode_ = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
		For i As Integer = 0 To ptabCode_->TabCount - 1
			Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode_->Tabs[i])
			If EqualPaths(tb->FileName, FileName) Then
				If LineNo < 1 OrElse LineNo > tb->txtCode.Content.Lines.Count Then Return 0
				Return Cast(EditControlLine Ptr, tb->txtCode.Content.Lines.Items[LineNo - 1])->BreakpointCount
			End If
		Next
	Next
	Return 0
End Function

'The line LineNo (from 1) of the open file FileName
Function DbgBreakpointLine(ByRef FileName As WString, LineNo As Integer) As EditControlLine Ptr
	For jj As Integer = 0 To TabPanels.Count - 1
		Var ptabCode_ = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
		For i As Integer = 0 To ptabCode_->TabCount - 1
			Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode_->Tabs[i])
			If EqualPaths(tb->FileName, FileName) Then
				If LineNo < 1 OrElse LineNo > tb->txtCode.Content.Lines.Count Then Return 0
				Return tb->txtCode.Content.Lines.Items[LineNo - 1]
			End If
		Next
	Next
	Return 0
End Function

'A condition of FreeBASIC for gdb and lldb (the syntax of C): =, <>, AndAlso, OrElse, Not; the shown names of the
'variables become their names of the C code when they are known (DbgShownNames: ARR -> ARR$0)
Function DbgCCondition(ByRef sCondition As String) As String
	Dim As String s = Trim(sCondition), r, w
	Dim As Integer i = 1, n = Len(s)
	Do While i <= n
		Dim As String c = Mid(s, i, 1)
		If c = """" Then
			Dim As Integer e = InStr(i + 1, s, """")
			If e = 0 Then e = n
			r &= Mid(s, i, e - i + 1): i = e + 1
		ElseIf (c >= "A" AndAlso c <= "Z") OrElse (c >= "a" AndAlso c <= "z") OrElse c = "_" Then
			Dim As Integer e = i
			Do While e <= n AndAlso InStr("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_", Mid(s, e, 1)) > 0
				e += 1
			Loop
			w = Mid(s, i, e - i)
			Select Case UCase(w)
			Case "ANDALSO", "AND": r &= "&&"
			Case "ORELSE", "OR": r &= "||"
			Case "NOT": r &= "!"
			Case "MOD": r &= "%"
			Case "TRUE": r &= "1"
			Case "FALSE": r &= "0"
			Case Else
				Dim As String sC = UCase(w)
				For k As Integer = 0 To UBound(DbgShownNames)
					If DbgShownNames(k) = sC Then sC = DbgCNames(k): Exit For
				Next
				r &= sC
			End Select
			i = e
		ElseIf c = "<" AndAlso Mid(s, i + 1, 1) = ">" Then
			r &= "!=": i += 2
		ElseIf c = "=" AndAlso Mid(s, i - 1, 1) <> "<" AndAlso Mid(s, i - 1, 1) <> ">" AndAlso Mid(s, i - 1, 1) <> "!" AndAlso Mid(s, i - 1, 1) <> "=" AndAlso Mid(s, i + 1, 1) <> "=" Then
			r &= "==": i += 1
		ElseIf c = "&" AndAlso UCase(Mid(s, i + 1, 1)) = "H" Then
			r &= "0x": i += 2
		Else
			r &= c: i += 1
		End If
	Loop
	Return r
End Function

'The condition of the breakpoint of the line for gdb and lldb ("" - none)
Function DbgBreakpointCondition(ByRef FileName As WString, LineNo As Integer) As String
	Dim As EditControlLine Ptr ECLine = DbgBreakpointLine(FileName, LineNo)
	If ECLine = 0 OrElse Trim(ECLine->BreakpointCondition) = "" Then Return ""
	Return DbgCCondition(ECLine->BreakpointCondition)
End Function

'The ignore count of gdb and lldb for the hit count: the stops before the N-th one
Function DbgIgnoreCount(ByRef FileName As WString, LineNo As Integer) As Integer
	Dim As Integer n = DbgBreakpointCount(FileName, LineNo)
	Return IIf(n > 1, n - 1, 0)
End Function

Sub DbgBreakpoints(Files() As UString, Lines() As String)
	Erase Files, Lines
	Dim As TabWindow Ptr tb
	For jj As Integer = 0 To TabPanels.Count - 1
		Var ptabCode_ = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
		For i As Integer = 0 To ptabCode_->TabCount - 1
			tb = Cast(TabWindow Ptr, ptabCode_->Tabs[i])
			Dim As String sLines
			For j As Integer = 0 To tb->txtCode.Content.Lines.Count - 1
				If Cast(EditControlLine Ptr, tb->txtCode.Content.Lines.Items[j])->Breakpoint Then sLines &= IIf(sLines = "", "", ",") & WStr(j + 1)
			Next
			If sLines <> "" Then
				Dim As Integer n = UBound(Files) + 1
				ReDim Preserve Files(n), Lines(n)
				Files(n) = tb->FileName
				Lines(n) = sLines
			End If
		Next
	Next
End Sub

'The program has no information for gdb and lldb: gas/gas64 (the default of fbc 32-bit) write their own one
Sub DbgCheckCompileLine(ByRef CompileLine As WString)
	Dim As String s = LCase(" " & CompileLine & " ")
	If InStr(s, "-gen gas") > 0 OrElse (InStr(s, "-gen gcc") = 0 AndAlso InStr(s, "-gen llvm") = 0 AndAlso InStr(s, "-gen clang") = 0) Then
		#ifndef __FB_64BIT__
			ShowMessages ML("gdb and lldb read the information for debugging of the programs compiled with -gen gcc -g.")
			Exit Sub
		#endif
		If InStr(s, "-gen gas") > 0 Then ShowMessages ML("gdb and lldb read the information for debugging of the programs compiled with -gen gcc -g.")
	End If
End Sub

#ifdef __FB_WIN32__
	'The command line of a process: the quoted program and its arguments
	Function DbgStart(ByRef p As DbgProcessType, ByRef Program As WString, ByRef Arguments As WString, ByRef PythonHome As WString = "") As Boolean
		Dim As SECURITY_ATTRIBUTES sa
		sa.nLength = SizeOf(SECURITY_ATTRIBUTES)
		sa.bInheritHandle = True
		Dim As HANDLE hInRead, hInWrite, hOutRead, hOutWrite
		'Big buffers: the thread of the windows writes the commands while the debugger writes its answers
		If CreatePipe(@hInRead, @hInWrite, @sa, 1048576) = 0 Then Return False
		If CreatePipe(@hOutRead, @hOutWrite, @sa, 1048576) = 0 Then CloseHandle(hInRead): CloseHandle(hInWrite): Return False
		SetHandleInformation(hInWrite, HANDLE_FLAG_INHERIT, 0)
		SetHandleInformation(hOutRead, HANDLE_FLAG_INHERIT, 0)
		Dim As STARTUPINFOW si
		si.cb = SizeOf(STARTUPINFOW)
		si.dwFlags = STARTF_USESTDHANDLES Or STARTF_USESHOWWINDOW
		si.wShowWindow = SW_HIDE
		si.hStdInput = hInRead
		si.hStdOutput = hOutWrite
		si.hStdError = hOutWrite
		Dim As PROCESS_INFORMATION pi
		Dim As WString Ptr CommandLine
		Dim As UString sCommandLine = """" & Program & """"
		If Arguments <> "" Then sCommandLine &= " " & Arguments
		WLet(CommandLine, sCommandLine)
		'Python of lldb: PYTHONHOME of its folder (the Android NDK, llvm-mingw)
		Dim As WString * 2048 OldPythonHome
		Dim As Boolean HadPythonHome
		If PythonHome <> "" Then
			HadPythonHome = GetEnvironmentVariableW("PYTHONHOME", @OldPythonHome, 2047) > 0
			SetEnvironmentVariableW("PYTHONHOME", PythonHome)
		End If
		Dim As Boolean Result = CreateProcessW(NULL, CommandLine, NULL, NULL, True, CREATE_NO_WINDOW Or CREATE_NEW_PROCESS_GROUP, NULL, NULL, @si, @pi) <> 0
		If PythonHome <> "" Then
			If HadPythonHome Then SetEnvironmentVariableW("PYTHONHOME", OldPythonHome) Else SetEnvironmentVariableW("PYTHONHOME", NULL)
		End If
		WDeAllocate(CommandLine)
		CloseHandle(hInRead)
		CloseHandle(hOutWrite)
		If Not Result Then
			CloseHandle(hInWrite)
			CloseHandle(hOutRead)
			Return False
		End If
		CloseHandle(pi.hThread)
		p.Pid = pi.dwProcessId
		p.hProcess = pi.hProcess
		p.hInput = hInWrite
		p.hOutput = hOutRead
		Return True
	End Function

	Function DbgReadOutput(ByRef p As DbgProcessType, Buffer As Any Ptr, Size As Integer) As Integer
		Dim As DWORD BytesRead
		If ReadFile(p.hOutput, Buffer, Size, @BytesRead, NULL) = 0 Then Return 0
		Return BytesRead
	End Function

	Sub DbgWriteInput(ByRef p As DbgProcessType, ByRef s As String)
		If p.hInput = 0 OrElse Len(s) = 0 Then Exit Sub
		Dim As DWORD Written
		WriteFile(p.hInput, StrPtr(s), Len(s), @Written, NULL)
	End Sub

	Sub DbgCloseInput(ByRef p As DbgProcessType)
		If p.hInput <> 0 Then CloseHandle(p.hInput): p.hInput = 0
	End Sub

	'After the end of its output: its end
	Sub DbgFinish(ByRef p As DbgProcessType)
		DbgCloseInput p
		If p.hOutput <> 0 Then CloseHandle(p.hOutput): p.hOutput = 0
		If p.hProcess <> 0 Then
			If WaitForSingleObject(p.hProcess, 3000) <> WAIT_OBJECT_0 Then TerminateProcess(p.hProcess, 1)
			CloseHandle(p.hProcess)
			p.hProcess = 0
		End If
		p.Pid = 0
	End Sub

	Sub DbgKillProcess(Pid As Long)
		If Pid <= 0 Then Exit Sub
		Dim As HANDLE h = OpenProcess(PROCESS_TERMINATE, False, Pid)
		If h <> 0 Then TerminateProcess(h, 1): CloseHandle(h)
	End Sub

	'Break: the program stops in the debugger (a breakpoint of a new thread)
	Sub DbgInterruptProcess(Pid As Long)
		If Pid <= 0 Then Exit Sub
		Dim As HANDLE h = OpenProcess(PROCESS_ALL_ACCESS, False, Pid)
		If h <> 0 Then DebugBreakProcess(h): CloseHandle(h)
	End Sub
#else
	Function DbgStart(ByRef p As DbgProcessType, ByRef Program As WString, ByRef Arguments As WString, ByRef PythonHome As WString = "") As Boolean
		Dim As Long FdIn(1), FdOut(1)
		If dbg_pipe(@FdIn(0)) <> 0 Then Return False
		If dbg_pipe(@FdOut(0)) <> 0 Then dbg_close(FdIn(0)): dbg_close(FdIn(1)): Return False
		'The debugger ends: the writing to it does not end the IDE
		dbg_signal(13, Cast(Any Ptr, 1))
		'The arguments separated by spaces, the quoted ones as one argument
		Dim As String Args(Any)
		Dim As String sProgram = ToUtf8(Program), sArgs = ToUtf8(Arguments), sArg
		Dim As Boolean InQuotes, HasArg
		For i As Integer = 1 To Len(sArgs) + 1
			Dim As String c = IIf(i > Len(sArgs), " ", Mid(sArgs, i, 1))
			If c = """" Then
				InQuotes = Not InQuotes
				HasArg = True
			ElseIf c = " " AndAlso Not InQuotes Then
				If HasArg OrElse sArg <> "" Then
					Dim As Integer n = UBound(Args) + 1
					ReDim Preserve Args(n)
					Args(n) = sArg
				End If
				sArg = ""
				HasArg = False
			Else
				sArg &= c
			End If
		Next
		Dim As ZString Ptr Argv(UBound(Args) + 2)
		Argv(0) = StrPtr(sProgram)
		For i As Integer = 0 To UBound(Args)
			Argv(i + 1) = StrPtr(Args(i))
		Next
		Argv(UBound(Args) + 2) = 0
		If PythonHome <> "" Then dbg_setenv("PYTHONHOME", ToUtf8(PythonHome), 1)
		'posix_spawn_file_actions_t: 80 bytes on macOS and Linux (with a reserve)
		Dim As Any Ptr Actions = Allocate(256)
		Clear *Cast(UByte Ptr, Actions), 0, 256
		dbg_spawn_init(Actions)
		dbg_spawn_dup2(Actions, FdIn(0), 0)
		dbg_spawn_dup2(Actions, FdOut(1), 1)
		dbg_spawn_dup2(Actions, FdOut(1), 2)
		dbg_spawn_close(Actions, FdIn(1))
		dbg_spawn_close(Actions, FdOut(0))
		Dim As Long Pid
		#ifdef __FB_DARWIN__
			Dim As Long SpawnResult = dbg_spawnp(@Pid, StrPtr(sProgram), Actions, 0, @Argv(0), *dbg_environ())
		#else
			Dim As Long SpawnResult = dbg_spawnp(@Pid, StrPtr(sProgram), Actions, 0, @Argv(0), dbg_environ_ptr)
		#endif
		dbg_spawn_destroy(Actions)
		Deallocate(Actions)
		dbg_close(FdIn(0))
		dbg_close(FdOut(1))
		If SpawnResult <> 0 Then
			dbg_close(FdIn(1))
			dbg_close(FdOut(0))
			Return False
		End If
		p.Pid = Pid
		p.FdIn = FdIn(1)
		p.FdOut = FdOut(0)
		Return True
	End Function

	Function DbgReadOutput(ByRef p As DbgProcessType, Buffer As Any Ptr, Size As Integer) As Integer
		Dim As Integer n = dbg_read(p.FdOut, Buffer, Size)
		Return IIf(n < 0, 0, n)
	End Function

	Sub DbgWriteInput(ByRef p As DbgProcessType, ByRef s As String)
		If p.FdIn < 0 OrElse Len(s) = 0 Then Exit Sub
		dbg_write(p.FdIn, StrPtr(s), Len(s))
	End Sub

	Sub DbgCloseInput(ByRef p As DbgProcessType)
		If p.FdIn >= 0 Then dbg_close(p.FdIn): p.FdIn = -1
	End Sub

	Sub DbgFinish(ByRef p As DbgProcessType)
		DbgCloseInput p
		If p.FdOut >= 0 Then dbg_close(p.FdOut): p.FdOut = -1
		If p.Pid > 0 Then
			Dim As Long Status
			dbg_waitpid(p.Pid, @Status, 0)
		End If
		p.Pid = 0
	End Sub

	Sub DbgKillProcess(Pid As Long)
		If Pid > 0 Then dbg_kill(Pid, 9)
	End Sub

	Sub DbgInterruptProcess(Pid As Long)
		If Pid > 0 Then dbg_kill(Pid, 2)
	End Sub
#endif

#ifdef __USE_WINAPI__
	'A line or a message of a debugger is handled by the thread of the windows (frmMain_Message of Main.bas): the
	'windows which its handler creates (AddTab of the stop) belong to that thread. A window of the thread which reads
	'the debugger would not answer while it waits for the debugger (the IDE hangs when it is minimized).
	#define WM_DBGCALL (WM_APP + &H3D1)
	Type DbgCallType
		Proc As Sub(ByRef s As String)
		Text As String Ptr
	End Type
	
	Sub DbgHandleCall(lParam As LPARAM)
		Dim As DbgCallType Ptr pCall = Cast(DbgCallType Ptr, lParam)
		If pCall <> 0 AndAlso pCall->Proc <> 0 Then pCall->Proc(*pCall->Text)
	End Sub
#endif

'Proc(Text) in the thread of the windows
Sub DbgCallInUIThread(Proc As Sub(ByRef s As String), ByRef Text As String)
	#ifdef __USE_WINAPI__
		If pApp <> 0 AndAlso pApp->MainForm <> 0 AndAlso pApp->MainForm->Handle <> 0 AndAlso GetCurrentThreadId() <> GetWindowThreadProcessId(pApp->MainForm->Handle, NULL) Then
			Dim As DbgCallType DbgCall
			DbgCall.Proc = Proc
			DbgCall.Text = @Text
			SendMessage pApp->MainForm->Handle, WM_DBGCALL, 0, Cast(LPARAM, @DbgCall)
			Exit Sub
		End If
	#endif
	ThreadsEnter
	Proc(Text)
	ThreadsLeave
End Sub

'The lines of the output of a debugger up to its end: Proc is called for each line
Sub DbgReadLines(ByRef p As DbgProcessType, LineProc As Sub(ByRef sLine As String))
	Dim As ZString * 8193 Buff
	Dim As String Pending
	Do
		Dim As Integer n = DbgReadOutput(p, @Buff, 8192)
		If n <= 0 Then Exit Do
		Buff[n] = 0
		Pending &= Left(Buff, n)
		Dim As Integer q = InStr(Pending, Chr(10))
		While q > 0
			Dim As String sLine = RTrim(Left(Pending, q - 1), Chr(13))
			Pending = Mid(Pending, q + 1)
			DbgCallInUIThread LineProc, sLine
			q = InStr(Pending, Chr(10))
		Wend
	Loop
	If Pending <> "" Then
		Dim As String sLine = RTrim(Pending, Chr(13))
		DbgCallInUIThread LineProc, sLine
	End If
End Sub

'The program of the debugger of Integrated GDB Debugger or Integrated LLDB Debugger (Debugger Paths)
Function DbgDebuggerPath(LLDB As Boolean) As UString
	Dim As Boolean Bit32 = tbt32Bit->Checked
	Dim As UString sPath
	If LLDB Then
		sPath = WGet(IIf(Bit32, LLDBDebugger32Path, LLDBDebugger64Path))
		If sPath = "" Then sPath = "lldb"
	Else
		sPath = WGet(IIf(Bit32, GDBDebugger32Path, GDBDebugger64Path))
		If sPath = "" Then sPath = "gdb"
	End If
	If InStr(sPath, "/") > 0 OrElse InStr(sPath, "\") > 0 Then sPath = GetFullPath(sPath)
	Return sPath
End Function

'lldb-mi and lldb-dap are in the folder of lldb: lldb.exe -> lldb-dap.exe (or lldb-vscode.exe of the old versions)
Function DbgLLDBTool(ByRef LLDBPath As WString, ByRef ToolName As String, ByRef OldToolName As String = "") As UString
	Dim As UString sName = LCase(GetFileName(LLDBPath))
	If StartsWith(sName, ToolName) OrElse (CBool(OldToolName <> "") AndAlso StartsWith(sName, OldToolName)) Then Return LLDBPath
	Dim As UString sFolder = GetFolderName(LLDBPath)
	#ifdef __FB_WIN32__
		Dim As String Ext = ".exe"
	#else
		Dim As String Ext = ""
	#endif
	If sFolder = "" Then Return ToolName
	If FileExists(sFolder & ToolName & Ext) Then Return sFolder & ToolName & Ext
	If OldToolName <> "" AndAlso FileExists(sFolder & OldToolName & Ext) Then Return sFolder & OldToolName & Ext
	Return sFolder & ToolName & Ext
End Function

'Python of lldb on Windows: python of its folder (lldb.cmd of the Android NDK sets it)
Function DbgPythonHome(ByRef LLDBPath As WString) As UString
	#ifdef __FB_WIN32__
		Dim As UString sFolder = GetFolderName(LLDBPath)
		If sFolder = "" Then Return ""
		'llvm-mingw: lldb knows its python (../python)
		If FileExists(sFolder & "..\python3\python.exe") Then Return GetFullPath(sFolder & "..\python3")
	#endif
	Return ""
End Function

'An answer of MI or of DAP as the paths of its values: stack.0.line, body.variables.2.name; the count of the items of
'a list is at its path with #: variables#
Type DbgRecord
	Keys(Any) As String
	Values(Any) As String
	Declare Sub Add(ByRef Key As String, ByRef Value As String)
	Declare Function Get(ByRef Key As String) As String
	Declare Sub Set(ByRef Key As String, ByRef Value As String)
	Declare Function Has(ByRef Key As String) As Boolean
	Declare Function Count(ByRef Key As String) As Integer
	Declare Sub Clear()
End Type

Sub DbgRecord.Add(ByRef Key As String, ByRef Value As String)
	Dim As Integer n = UBound(Keys) + 1
	ReDim Preserve Keys(n), Values(n)
	Keys(n) = Key
	Values(n) = Value
End Sub

Function DbgRecord.Get(ByRef Key As String) As String
	For i As Integer = 0 To UBound(Keys)
		If Keys(i) = Key Then Return Values(i)
	Next
	Return ""
End Function

Sub DbgRecord.Set(ByRef Key As String, ByRef Value As String)
	For i As Integer = 0 To UBound(Keys)
		If Keys(i) = Key Then Values(i) = Value: Exit Sub
	Next
	Add Key, Value
End Sub

Function DbgRecord.Has(ByRef Key As String) As Boolean
	For i As Integer = 0 To UBound(Keys)
		If Keys(i) = Key Then Return True
	Next
	Return False
End Function

Function DbgRecord.Count(ByRef Key As String) As Integer
	Return Val(Get(Key & "#"))
End Function

Sub DbgRecord.Clear()
	Erase Keys, Values
End Sub

'The bytes of a character in UTF-8
Function DbgUtf8Char(Code As ULong) As String
	If Code < &H80 Then
		Return Chr(Code)
	ElseIf Code < &H800 Then
		Return Chr(&HC0 Or (Code Shr 6)) & Chr(&H80 Or (Code And &H3F))
	ElseIf Code < &H10000 Then
		Return Chr(&HE0 Or (Code Shr 12)) & Chr(&H80 Or ((Code Shr 6) And &H3F)) & Chr(&H80 Or (Code And &H3F))
	Else
		Return Chr(&HF0 Or (Code Shr 18)) & Chr(&H80 Or ((Code Shr 12) And &H3F)) & Chr(&H80 Or ((Code Shr 6) And &H3F)) & Chr(&H80 Or (Code And &H3F))
	End If
End Function

'The pointer of the characters of a WString in the C code of fbc (uint16 * on Windows, uint32 * on Linux)
Function DbgIsWideCType(ByRef CType As String) As Boolean
	Dim As String s = Trim(CType)
	If StartsWith(s, "const ") Then s = Mid(s, 7)
	Return s = WSTRING_CTYPE & " *" OrElse s = WSTRING_CTYPE & "*"
End Function

'The address of a value of a pointer: 0x65fe20 or 0x000000000065fe20 L"..." -> 0x65fe20; "" for 0
Function DbgPointerAddress(ByRef Value As String) As String
	Dim As String s = Trim(Value)
	If Not StartsWith(LCase(s), "0x") Then Return ""
	Dim As Integer p = InStr(s, " ")
	If p > 0 Then s = Left(s, p - 1)
	If ValULng("&H" & Mid(s, 3)) = 0 Then Return ""
	Return s
End Function

'The text of the characters of a WString in memory (the bytes from the debugger) up to Chr(0): L"..."
Function DbgWideText(ByRef Bytes As String) As String
	Dim As String Result
	Dim As Integer w = SizeOf(WString), i = 1
	While i + w - 1 <= Len(Bytes)
		Dim As ULong c = Bytes[i - 1] Or (CULng(Bytes[i]) Shl 8)
		If w = 4 Then c = c Or (CULng(Bytes[i + 1]) Shl 16) Or (CULng(Bytes[i + 2]) Shl 24)
		i += w
		If c = 0 Then Exit While
		'A pair of UTF-16
		If w = 2 AndAlso c >= &HD800 AndAlso c <= &HDBFF AndAlso i + 1 <= Len(Bytes) Then
			Dim As ULong Low = Bytes[i - 1] Or (CULng(Bytes[i]) Shl 8)
			If Low >= &HDC00 AndAlso Low <= &HDFFF Then c = &H10000 + ((c - &HD800) Shl 10) + (Low - &HDC00): i += 2
		End If
		Select Case c
		Case 34: Result &= "\"""
		Case 92: Result &= "\\"
		Case 10: Result &= "\n"
		Case 13: Result &= "\r"
		Case 9: Result &= "\t"
		Case Is < 32: Result &= "\x" & Hex(c, 2)
		Case Else: Result &= DbgUtf8Char(c)
		End Select
	Wend
	Return "L""" & Result & """"
End Function

'The bytes of a text of hexadecimal digits (MI: contents="530061006c00...")
Function DbgHexBytes(ByRef HexText As String) As String
	Dim As String Result = String(Len(HexText) \ 2, 0)
	For i As Integer = 0 To Len(HexText) \ 2 - 1
		Result[i] = ValInt("&H" & Mid(HexText, i * 2 + 1, 2))
	Next
	Return Result
End Function

'The bytes of a text of base64 (DAP: readMemory)
Function DbgBase64Bytes(ByRef Text As String) As String
	Dim As String Result
	Dim As ULong Acc
	Dim As Integer Bits
	For i As Integer = 1 To Len(Text)
		Dim As Integer v = InStr("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/", Mid(Text, i, 1)) - 1
		If v < 0 Then Continue For
		Acc = ((Acc Shl 6) Or v) And &HFFFFFF
		Bits += 6
		If Bits >= 8 Then
			Bits -= 8
			Result &= Chr((Acc Shr Bits) And 255)
		End If
	Next
	Return Result
End Function
