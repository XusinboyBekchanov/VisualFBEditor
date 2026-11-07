'#########################################################
'#  DebugLLDB.bas                                        #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#########################################################

'macOS: the integrated debuggers (Integrated IDE Debugger and Integrated GDB Debugger) are lldb of Xcode or of the
'Command Line Tools, a custom debugger (a tool of Debuggers) runs in Terminal with the program.
'RunWithDebug starts lldb with pipes, writes it the commands and reads its answers until it ends (the thread of
'RunWithDebug waits there). The prompt is "(vfbe) " and lldb repeats each command after it, so the answer of a command is
'the text up to the next prompt. The frames begin with __VFBE_FRAME__ (frame-format). After a stop (Process N stopped)
'the IDE asks the backtrace (bt), selects the first frame with a line of the program and asks its variables; the end of
'these answers are the commands vfbe_bt_end and vfbe_vars_end (aliases of a setting). The program is compiled with -g
'(Use Debugger), mff/Cocoa/build.sh keeps its information for the debugger in Program.dSYM (MFF_DEBUG).
'The output of the program goes to a file which the Output shows after each stop, its input is /dev/null.

Extern "C"
	Declare Function lldb_pipe Alias "pipe" (ByVal fds As Long Ptr) As Long
	Declare Function lldb_close Alias "close" (ByVal fd As Long) As Long
	Declare Function lldb_read Alias "read" (ByVal fd As Long, ByVal buf As Any Ptr, ByVal n As UInteger) As Integer
	Declare Function lldb_write Alias "write" (ByVal fd As Long, ByVal buf As Const Any Ptr, ByVal n As UInteger) As Integer
	Declare Function lldb_waitpid Alias "waitpid" (ByVal pid As Long, ByVal status As Long Ptr, ByVal options As Long) As Long
	Declare Function lldb_signal Alias "signal" (ByVal sig As Long, ByVal handler As Any Ptr) As Any Ptr
	Declare Function lldb_spawn_init Alias "posix_spawn_file_actions_init" (ByVal fa As Any Ptr Ptr) As Long
	Declare Function lldb_spawn_dup2 Alias "posix_spawn_file_actions_adddup2" (ByVal fa As Any Ptr Ptr, ByVal fd As Long, ByVal newfd As Long) As Long
	Declare Function lldb_spawn_close Alias "posix_spawn_file_actions_addclose" (ByVal fa As Any Ptr Ptr, ByVal fd As Long) As Long
	Declare Function lldb_spawn_destroy Alias "posix_spawn_file_actions_destroy" (ByVal fa As Any Ptr Ptr) As Long
	Declare Function lldb_spawnp Alias "posix_spawnp" (ByVal pid As Long Ptr, ByVal file As Const ZString Ptr, ByVal fa As Any Ptr Ptr, ByVal attr As Any Ptr, ByVal argv As ZString Ptr Ptr, ByVal envp As ZString Ptr Ptr) As Long
	Declare Function lldb_environ Alias "_NSGetEnviron" () As ZString Ptr Ptr Ptr
End Extern

#define LLDB_PROMPT "(vfbe) "
#define LLDB_LOCALS "frame variable -D 3"
#define LLDB_GLOBALS "frame variable --no-args --no-locals --show-globals -D 1"

Type LLDBFrameType
	Func As String
	File As String
	LineNo As Integer
End Type

Dim Shared As Long LLDBPid, LLDBInput = -1, LLDBProgramPid
Dim Shared As Any Ptr LLDBMutex
LLDBMutex = MutexCreate
'The command whose answer lldb writes, the command of the GDB Command window (its answer goes to the Output)
Dim Shared As String LLDBSection, LLDBUserCommand
Dim Shared As String LLDBLocalsText, LLDBGlobalsText
Dim Shared As UString LLDBOutputFile
Dim Shared As LongInt LLDBOutputRead
'Step Into / Step Over before the start: the program stops at its first line; Restart: the end of the program before
'its new start does not end lldb
Dim Shared As Boolean LLDBLaunched, LLDBStopAtStart, LLDBRestarting
'process launch with the file of the output of the program, its folder and its arguments
Dim Shared As UString LLDBLaunchCommand
Dim Shared LLDBFrames(Any) As LLDBFrameType
Dim Shared As Integer LLDBFrameIndex = -1
'The values of the variables of the last stop (Watches, the hint of a variable): the names are like P.X
Dim Shared As String LLDBNames(Any), LLDBValues(Any), LLDBTypes(Any)

Private Function LLDBText(ByRef s As String) As UString
	If s = "" Then Return ""
	Dim As WString Ptr p = FromUtf8(StrPtr(s))
	If p = 0 Then Return s
	Dim As UString Result = *p
	WDeAllocate(p)
	Return Result
End Function

Private Function LLDBQuote(ByRef s As WString) As UString
	Return """" & Replace(Replace(s, "\", "\\"), """", "\""") & """"
End Function

'The fields of a line of lldb separated by |
Private Function LLDBField(ByRef Text As String, Index As Integer) As String
	Dim As Integer iStart = 1, iEnd
	For i As Integer = 0 To Index - 1
		iStart = InStr(iStart, Text, "|")
		If iStart = 0 Then Return ""
		iStart += 1
	Next
	iEnd = InStr(iStart, Text, "|")
	If iEnd = 0 Then iEnd = Len(Text) + 1
	Return Mid(Text, iStart, iEnd - iStart)
End Function

Private Sub LLDBWrite(ByRef sCommand As WString)
	MutexLock LLDBMutex
	If LLDBInput >= 0 Then
		Dim As String s = ToUtf8(sCommand) & Chr(10)
		lldb_write(LLDBInput, StrPtr(s), Len(s))
	End If
	MutexUnlock LLDBMutex
End Sub

Private Function LLDBActive() As Boolean
	Return LLDBInput >= 0
End Function

'The name of a variable of the C code of fbc: I$0 -> I; the temporary variables (vr$5, tmp$1, fb$result$1) and the ones
'of the runtime (__FB_ARGC__) are not shown
Private Function LLDBName(ByRef CName As String) As String
	Dim As String s = CName
	Dim As Integer p = InStrRev(s, "$")
	If p > 1 AndAlso p < Len(s) AndAlso Val(Mid(s, p + 1)) >= 0 AndAlso Trim(Mid(s, p + 1), Any "0123456789") = "" Then s = Left(s, p - 1)
	If InStr(s, "$") > 0 OrElse StartsWith(s, "__FB_") Then Return ""
	If s <> UCase(s) Then Return ""
	Return s
End Function

'The type of the C code of fbc with the names of FreeBASIC
Private Function LLDBType(ByRef CType As String, ByRef Value As String = "") As String
	Dim As String s = Trim(CType), Suffix
	'WString * N, ZString * N: the arrays of C of their characters
	Dim As Integer iBracket = InStr(s, "[")
	If iBracket > 0 AndAlso Right(s, 1) = "]" Then
		Dim As String sCount = Mid(s, iBracket + 1, Len(s) - iBracket - 1)
		Select Case RTrim(Left(s, iBracket - 1))
		Case "uint32": Return "WString * " & sCount
		Case "char", "uint8": Return "ZString * " & sCount
		End Select
	End If
	'A WString Ptr is a uint32 * with the text of its summary (vfbe_lldb.py)
	If s = "uint32 *" AndAlso InStr(Value, " L""") > 0 Then Return "WString Ptr"
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

'The text of the program in the file of its output since the last time
Private Sub LLDBShowProgramOutput()
	If LLDBOutputFile = "" Then Exit Sub
	Dim As Integer Fn = FreeFile_
	If Open(LLDBOutputFile For Binary Access Read As #Fn) <> 0 Then Exit Sub
	Dim As LongInt Size = LOF(Fn)
	If Size > LLDBOutputRead Then
		Dim As String Buff = String(Size - LLDBOutputRead, 0)
		Get #Fn, LLDBOutputRead + 1, Buff
		LLDBOutputRead = Size
		Dim As Integer p = InStrRev(Buff, Chr(10))
		If p > 0 AndAlso p < Len(Buff) Then
			'The last line without its end is shown with the next text
			LLDBOutputRead -= Len(Buff) - p
			Buff = Left(Buff, p)
		End If
		Dim As UString Text = LLDBText(Buff)
		Dim As WString Ptr Lines()
		Split Replace(Text, Chr(13), ""), Chr(10), Lines()
		For i As Integer = 0 To UBound(Lines)
			If i < UBound(Lines) OrElse *Lines(i) <> "" Then ShowMessages *Lines(i), False
			_Deallocate(Lines(i))
		Next
		Erase Lines
	End If
	CloseFile_(Fn)
End Sub

Sub DeleteDebugCursor
	If CurEC <> 0 Then
		Var curEC2 = CurEC
		CurEC->CurExecutedLine = -1
		CurEC = 0
		curEC2->Repaint
	End If
End Sub

'Breakpoints of the open files
Private Sub LLDBSetBreakpoints()
	Dim As TabWindow Ptr tb
	For jj As Integer = 0 To TabPanels.Count - 1
		Var ptabCode_ = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
		For i As Integer = 0 To ptabCode_->TabCount - 1
			tb = Cast(TabWindow Ptr, ptabCode_->Tabs[i])
			For j As Integer = 0 To tb->txtCode.Content.Lines.Count - 1
				If Cast(EditControlLine Ptr, tb->txtCode.Content.Lines.Items[j])->Breakpoint Then
					LLDBWrite "breakpoint set -f " & LLDBQuote(GetFileName(tb->FileName)) & " -l " & WStr(j + 1)
				End If
			Next
		Next
	Next
End Sub

'The current line: Breakpoint and Run To Cursor of the editor
Private Function LLDBCursorPlace(ByRef FileName As UString, ByRef LineNo As Integer) As Boolean
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Return False
	Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	FileName = tb->FileName
	LineNo = iSelEndLine + 1
	Return True
End Function

Private Sub LLDBAddVariables(lv As TreeListView Ptr, ByRef Text As String)
	Dim As TreeListViewItem Ptr Parents(100)
	Dim As String Paths(100)
	Dim As Boolean Skipped(100)
	Dim As Integer Depth, p, Count
	Dim As String sLine, sType, sName, sValue, sPath
	Dim As Integer iStart = 1, iEnd
	Do While iStart <= Len(Text)
		iEnd = InStr(iStart, Text, Chr(10))
		If iEnd = 0 Then iEnd = Len(Text) + 1
		sLine = Trim(Mid(Text, iStart, iEnd - iStart), Any !" \t\r")
		iStart = iEnd + 1
		If sLine = "" Then Continue Do
		If sLine = "}" OrElse sLine = "}," Then
			If Depth > 0 Then Depth -= 1
			Continue Do
		End If
		sType = ""
		If Left(sLine, 1) = "(" Then
			'The type can have brackets: (int64 (*)(int64))
			Dim As Integer Level
			For p = 1 To Len(sLine)
				If Mid(sLine, p, 1) = "(" Then Level += 1
				If Mid(sLine, p, 1) = ")" Then
					Level -= 1
					If Level = 0 Then Exit For
				End If
			Next
			sType = Mid(sLine, 2, p - 2)
			sLine = LTrim(Mid(sLine, p + 1))
		End If
		p = InStr(sLine, " = ")
		If p > 0 Then
			sName = Left(sLine, p - 1)
			sValue = Mid(sLine, p + 3)
		Else
			sName = sLine
			sValue = ""
		End If
		Dim As Boolean Opens = Right(sValue, 1) = "{"
		If Opens Then sValue = RTrim(Left(sValue, Len(sValue) - 1))
		If Depth = 0 Then sName = LLDBName(sName)
		Dim As Boolean Skip = sName = "" OrElse (Depth > 0 AndAlso Skipped(Depth))
		Dim As TreeListViewItem Ptr Item
		If Not Skip AndAlso Count < 1000 Then
			If Depth = 0 Then
				Item = lv->Nodes.Add(LLDBText(sName))
				sPath = sName
			Else
				Item = Parents(Depth)->Nodes.Add(LLDBText(sName))
				sPath = Paths(Depth) & IIf(Left(sName, 1) = "[", "", ".") & sName
			End If
			Item->Text(1) = LLDBText(sValue)
			Item->Text(2) = LLDBType(sType, sValue)
			Count += 1
			Dim As Integer n = UBound(LLDBNames) + 1
			ReDim Preserve LLDBNames(n), LLDBValues(n), LLDBTypes(n)
			LLDBNames(n) = UCase(sPath): LLDBValues(n) = sValue: LLDBTypes(n) = LLDBType(sType, sValue)
		End If
		If Opens AndAlso Depth < 99 Then
			Depth += 1
			Parents(Depth) = Item
			Paths(Depth) = sPath
			Skipped(Depth) = Skip OrElse Item = 0
		End If
	Loop
End Sub

Private Function LLDBFindValue(ByRef VarName As String, ByRef VarType As String = "") As String
	Dim As String sName = UCase(Trim(VarName))
	For i As Integer = 0 To UBound(LLDBNames)
		If LLDBNames(i) = sName Then VarType = LLDBTypes(i): Return LLDBValues(i)
	Next
	Return ""
End Function

Private Function LLDBShownValue(ByRef sValue As String, ByRef sType As String) As UString
	If sType = "" Then Return ML("No symbol in the current context")
	Return LLDBText(sValue)
End Function

Private Sub LLDBUpdateWatches()
	For i As Integer = 0 To lvWatches.Nodes.Count - 1
		Dim As String sName = ToUtf8(lvWatches.Nodes.Item(i)->Text(0)), sType
		If Trim(sName) = "" Then Continue For
		Dim As String sValue = LLDBFindValue(sName, sType)
		lvWatches.Nodes.Item(i)->Text(1) = LLDBShownValue(sValue, sType)
		lvWatches.Nodes.Item(i)->Text(2) = sType
	Next
End Sub

'The place, the variables and the frames of the stop
Private Sub LLDBShowStop()
	LLDBShowProgramOutput
	Erase LLDBNames, LLDBValues, LLDBTypes
	lvLocals.Nodes.Clear
	LLDBAddVariables @lvLocals, LLDBLocalsText
	tpLocals->Caption = ML("Locals") & " (" & lvLocals.Nodes.Count & " " & ML("Pos") & ")"
	lvGlobals.Nodes.Clear
	LLDBAddVariables @lvGlobals, LLDBGlobalsText
	tpGlobals->Caption = ML("Globals") & " (" & lvGlobals.Nodes.Count & " " & ML("Pos") & ")"
	lvThreads.Nodes.Clear
	For i As Integer = 0 To UBound(LLDBFrames)
		Var Item = lvThreads.Nodes.Add(LLDBText(LLDBFrames(i).Func))
		If LLDBFrames(i).LineNo > 0 Then Item->Text(1) = WStr(LLDBFrames(i).LineNo)
		Item->Text(2) = LLDBText(LLDBFrames(i).File)
	Next
	tpThreads->Caption = ML("Threads") & " (" & lvThreads.Nodes.Count & " " & ML("Pos") & ")"
	LLDBUpdateWatches
	DeleteDebugCursor
	If LLDBFrameIndex >= 0 Then
		Dim As UString FileName = LLDBText(LLDBFrames(LLDBFrameIndex).File)
		Dim As Integer LineNo = LLDBFrames(LLDBFrameIndex).LineNo
		Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb = 0 OrElse Not EqualPaths(tb->FileName, FileName) Then tb = AddTab(FileName)
		If tb <> 0 Then
			CurEC = @tb->txtCode
			tb->txtCode.CurExecutedLine = LineNo - 1
			tb->txtCode.SetSelection LineNo - 1, LineNo - 1, 0, 0
			tb->txtCode.PaintControl
		End If
	End If
	tpLocals->SelectTab
	Running = False
	ChangeEnabledDebug True, False, True
End Sub

'A line of lldb
Private Sub LLDBLine(ByRef sLine As String)
	Dim As String Text = sLine
	If StartsWith(Text, LLDB_PROMPT) Then
		'The next command: its answer follows
		Text = Mid(Text, Len(LLDB_PROMPT) + 1)
		LLDBSection = Text
		Select Case Text
		Case "vfbe_bt_end"
			'The first frame with a line of the program, then its variables
			LLDBFrameIndex = -1
			For i As Integer = 0 To UBound(LLDBFrames)
				If CBool(LLDBFrames(i).LineNo > 0) AndAlso CBool(LLDBFrames(i).File <> "") AndAlso Not EndsWith(LCase(LLDBFrames(i).File), ".c") Then LLDBFrameIndex = i: Exit For
			Next
			If LLDBFrameIndex > 0 Then LLDBWrite "frame select " & WStr(LLDBFrameIndex)
			LLDBLocalsText = ""
			LLDBGlobalsText = ""
			LLDBWrite LLDB_LOCALS
			LLDBWrite LLDB_GLOBALS
			LLDBWrite "vfbe_vars_end"
		Case "vfbe_vars_end"
			LLDBShowStop
		Case "bt"
			Erase LLDBFrames
		End Select
		If Text = LLDBUserCommand AndAlso Text <> "" Then ShowMessages "(lldb) " & LLDBText(Text), False
	End If
	'The events of the program, lldb writes them also between the answers of the commands
	If StartsWith(Text, "Process ") AndAlso Val(Mid(Text, 9)) > 0 Then
		Dim As Integer p = InStr(9, Text, " ")
		Dim As Long Pid = Val(Mid(Text, 9))
		Dim As String sEvent = Mid(Text, p + 1)
		If StartsWith(sEvent, "launched") Then
			LLDBProgramPid = Pid
			LLDBLaunched = True
			LLDBRestarting = False
			ShowMessages Time & ": " & LLDBText(Text), False
		ElseIf StartsWith(sEvent, "stopped") Then
			LLDBWrite "bt"
			LLDBWrite "vfbe_bt_end"
		ElseIf StartsWith(sEvent, "exited") Then
			LLDBProgramPid = 0
			LLDBShowProgramOutput
			Dim As Integer Result = Val(Mid(sEvent, InStr(sEvent, "=") + 1))
			ShowMessages Time & ": " & ML("Application finished. Returned code") & ": " & Result & " - " & Err2Description(Result)
			If Not LLDBRestarting Then LLDBWrite "quit"
		End If
		Exit Sub
	End If
	'The answers of the commands
	Select Case LLDBSection
	Case LLDB_LOCALS
		If Text <> LLDB_LOCALS Then LLDBLocalsText &= Text & Chr(10)
		Exit Sub
	Case LLDB_GLOBALS
		If Text <> LLDB_GLOBALS Then LLDBGlobalsText &= Text & Chr(10)
		Exit Sub
	Case "bt"
		Dim As Integer p = InStr(Text, "__VFBE_FRAME__|")
		If p > 0 Then
			Dim As String Frame = Mid(Text, p + 15)
			Dim As Integer n = UBound(LLDBFrames) + 1
			ReDim Preserve LLDBFrames(n)
			LLDBFrames(n).Func = LLDBField(Frame, 1)
			LLDBFrames(n).File = LLDBField(Frame, 2)
			LLDBFrames(n).LineNo = Val(LLDBField(Frame, 3))
		End If
		Exit Sub
	End Select
	If InStr(Text, "error:") > 0 Then
		ShowMessages "lldb: " & LLDBText(Text), False
		If StartsWith(LLDBSection, "process launch") AndAlso Not LLDBLaunched Then
			ShowMessages ML("macOS allows the debugger after a confirmation (a password of an administrator) or after the command ""sudo DevToolsSecurity -enable"" in Terminal.")
			LLDBWrite "quit"
		End If
		Exit Sub
	End If
	If CBool(LLDBSection = LLDBUserCommand) AndAlso CBool(LLDBSection <> "") AndAlso Not StartsWith(sLine, LLDB_PROMPT) Then ShowMessages LLDBText(Text), False
End Sub

'The summaries of lldb for WString (uint32 of C) and ZString * N: the text up to Chr(0), nothing if it is not a text
Private Function LLDBScript() As UString
	Dim As UString ScriptFile = GetUserTempPath("vfbe_lldb.py")
	Dim As Integer Fn = FreeFile_
	If Open(ScriptFile For Output As #Fn) <> 0 Then Return ""
	Print #Fn, "import lldb"
	Print #Fn, "def _text(valobj, addr, count, width):"
	Print #Fn, "    chars = []"
	Print #Fn, "    i = 0"
	Print #Fn, "    while i < count:"
	Print #Fn, "        n = min(count - i, 64)"
	Print #Fn, "        err = lldb.SBError()"
	Print #Fn, "        data = valobj.GetProcess().ReadMemory(addr + i * width, n * width, err)"
	Print #Fn, "        if not err.Success():"
	Print #Fn, "            return None if i == 0 else (chars, True)"
	Print #Fn, "        for k in range(n):"
	Print #Fn, "            c = int.from_bytes(data[k * width:(k + 1) * width], 'little')"
	Print #Fn, "            if c == 0:"
	Print #Fn, "                return chars, False"
	Print #Fn, "            if (c < 32 and c not in (9, 10, 13)) or c > 0x10FFFF or 0xD800 <= c <= 0xDFFF:"
	Print #Fn, "                return None"
	Print #Fn, "            chars.append(c)"
	Print #Fn, "        i += n"
	Print #Fn, "    return chars, True"
	Print #Fn, "def _quote(chars, prefix, more):"
	Print #Fn, "    s = ''.join(chr(c) for c in chars).replace('\\', '\\\\').replace('""', '\\""').replace('\t', '\\t').replace('\n', '\\n').replace('\r', '\\r')"
	Print #Fn, "    return prefix + '""' + s + ('...""' if more else '""')"
	Print #Fn, "def wstr(valobj, d):"
	Print #Fn, "    t = valobj.GetType()"
	Print #Fn, "    if t.IsPointerType():"
	Print #Fn, "        addr = valobj.GetValueAsUnsigned(0)"
	Print #Fn, "        r = _text(valobj, addr, 1000, 4) if addr else None"
	Print #Fn, "    else:"
	Print #Fn, "        r = _text(valobj, valobj.GetLoadAddress(), t.GetByteSize() // 4, 4)"
	Print #Fn, "        if r is not None: r = (r[0], False)"
	Print #Fn, "    return None if r is None else _quote(r[0], 'L', r[1])"
	Print #Fn, "def zstr(valobj, d):"
	Print #Fn, "    r = _text(valobj, valobj.GetLoadAddress(), valobj.GetType().GetByteSize(), 1)"
	Print #Fn, "    return None if r is None else _quote(r[0], '', False)"
	CloseFile_(Fn)
	Return ScriptFile
End Function

'A custom debugger: its command in a window of Terminal
Private Sub LLDBRunInTerminal(Tool As ToolType Ptr, ByRef ExeFile As WString, ByRef Arguments As WString)
	Dim As UString sCommand = Tool->GetCommand(ExeFile)
	If InStr(Tool->Parameters, "{E}") = 0 Then sCommand &= " " & LLDBQuote(ExeFile)
	If Trim(Arguments) <> "" Then sCommand &= " -- " & Arguments
	Dim As UString ScriptFile = GetUserTempPath("VFBEDebugger.command")
	Dim As Integer Fn = FreeFile_
	If Open(ScriptFile For Output As #Fn) <> 0 Then
		ShowMessages ML("File not found") & ": " & ScriptFile
		Exit Sub
	End If
	Print #Fn, "#!/bin/sh"
	Print #Fn, "cd " & ToUtf8(LLDBQuote(GetFolderName(ExeFile)))
	Print #Fn, ToUtf8(sCommand)
	CloseFile_(Fn)
	Shell "chmod +x " & ToUtf8(LLDBQuote(ScriptFile))
	ShowMessages Time & ": " & ML("Run") & ": " & sCommand
	Shell "open -a Terminal " & ToUtf8(LLDBQuote(ScriptFile))
End Sub

Sub RunWithDebug(Debugger As String = "", ByRef ProjectFileName As WString, ByRef ProjectCommandLineArguments As WString, ByRef MainFile As WString, ByRef CompileLine As WString, ByRef FirstLine As WString)
	Dim As UString ExeFile = Replace(GetExeFileName(MainFile, CompileLine & " " & FirstLine), "\", "/")
	Dim As UString Arguments = *RunArguments
	If ProjectCommandLineArguments <> "" Then Arguments &= " " & ProjectCommandLineArguments
	If Not FileExists(ExeFile) Then
		ShowMessages ML("File not found") & ": " & ExeFile
		ChangeEnabledDebug True, False, False
		Exit Sub
	End If
	Dim As Boolean Bit32 = tbt32Bit->Checked
	Dim As DebuggerTypes CurrentDebuggerType = IIf(Bit32, CurrentDebuggerType32, CurrentDebuggerType64)
	If CurrentDebuggerType = CustomDebugger Then
		Dim As Integer Idx = pDebuggers->IndexOfKey(*IIf(Bit32, CurrentDebugger32, CurrentDebugger64))
		If Idx <> -1 Then
			LLDBRunInTerminal pDebuggers->Item(Idx)->Object, ExeFile, Arguments
			ChangeEnabledDebug True, False, False
			Exit Sub
		End If
	End If
	If LLDBActive Then Exit Sub
	'lldb of the setting of the GDB debugger (Integrated GDB Debugger) if it is lldb, else lldb of Xcode
	Dim As UString LLDBPath = "lldb"
	If CurrentDebuggerType = IntegratedGDBDebugger Then
		Dim As WString Ptr GDBDebuggerPath = IIf(Bit32, GDBDebugger32Path, GDBDebugger64Path)
		If InStr(LCase(GetFileName(WGet(GDBDebuggerPath))), "lldb") > 0 Then LLDBPath = GetFullPath(WGet(GDBDebuggerPath))
	End If
	Dim As Long FdIn(1), FdOut(1)
	If lldb_pipe(@FdIn(0)) <> 0 Then ShowMessages ML("Error: Couldn't Create Pipe"): Exit Sub
	If lldb_pipe(@FdOut(0)) <> 0 Then lldb_close(FdIn(0)): lldb_close(FdIn(1)): ShowMessages ML("Error: Couldn't Create Pipe"): Exit Sub
	'lldb ends: the writing to it does not end the IDE
	lldb_signal(13, Cast(Any Ptr, 1))
	Dim As Any Ptr Actions
	lldb_spawn_init(@Actions)
	lldb_spawn_dup2(@Actions, FdIn(0), 0)
	lldb_spawn_dup2(@Actions, FdOut(1), 1)
	lldb_spawn_dup2(@Actions, FdOut(1), 2)
	lldb_spawn_close(@Actions, FdIn(1))
	lldb_spawn_close(@Actions, FdOut(0))
	Dim As String sPath = ToUtf8(LLDBPath), sNoColors = "--no-use-colors", sNoInit = "--no-lldbinit"
	Dim As ZString Ptr Argv(3) = {StrPtr(sPath), StrPtr(sNoColors), StrPtr(sNoInit), 0}
	Dim As Long Pid
	Dim As Long SpawnResult = lldb_spawnp(@Pid, StrPtr(sPath), @Actions, 0, @Argv(0), *lldb_environ())
	lldb_spawn_destroy(@Actions)
	lldb_close(FdIn(0))
	lldb_close(FdOut(1))
	If SpawnResult <> 0 Then
		lldb_close(FdIn(1))
		lldb_close(FdOut(0))
		ShowMessages ML("File not found") & ": " & LLDBPath & " (" & ML("Command Line Tools for Xcode") & ": xcode-select --install)"
		ChangeEnabledDebug True, False, False
		Exit Sub
	End If
	MutexLock LLDBMutex
	LLDBPid = Pid
	LLDBInput = FdIn(1)
	MutexUnlock LLDBMutex
	LLDBProgramPid = 0
	LLDBLaunched = False
	LLDBSection = ""
	LLDBUserCommand = ""
	Erase LLDBFrames, LLDBNames, LLDBValues, LLDBTypes
	LLDBOutputFile = GetUserTempPath("VFBEProgramOutput.txt")
	If FileExists(LLDBOutputFile) Then Kill LLDBOutputFile
	LLDBOutputRead = 0
	InDebug = True
	iFlagStartDebug = 1
	Running = True
	lvLocals.Nodes.Clear
	lvGlobals.Nodes.Clear
	ChangeEnabledDebug False, True, True
	ShowMessages Time & ": " & ML("Run") & ": " & LLDBPath & " " & ExeFile & " ..."
	LLDBWrite "settings set prompt " & LLDBQuote(LLDB_PROMPT)
	LLDBWrite "settings set auto-confirm true"
	LLDBWrite "settings set stop-line-count-before 0"
	LLDBWrite "settings set stop-line-count-after 0"
	LLDBWrite "settings set stop-disassembly-display never"
	LLDBWrite "settings set target.max-children-count 256"
	LLDBWrite "settings set frame-format ""__VFBE_FRAME__|${frame.index}|{${function.name}}|{${line.file.fullpath}}|{${line.number}}\n"""
	LLDBWrite "command alias vfbe_bt_end settings show auto-confirm"
	LLDBWrite "command alias vfbe_vars_end settings show auto-confirm"
	LLDBWrite "type summary add -s ""${var.data%s}"" FBSTRING"
	'WString (uint32 of C) and ZString * N as their texts
	Dim As UString ScriptFile = LLDBScript
	If ScriptFile <> "" Then
		LLDBWrite "command script import " & LLDBQuote(ScriptFile)
		LLDBWrite "type summary add -F vfbe_lldb.wstr -x ""^(const )?uint32 ?\[[0-9]+\]$"""
		LLDBWrite "type summary add -F vfbe_lldb.wstr ""uint32 *"""
		LLDBWrite "type summary add -F vfbe_lldb.zstr -x ""^(const )?(char|uint8) ?\[[0-9]+\]$"""
	End If
	LLDBWrite "target create " & LLDBQuote(ExeFile)
	LLDBSetBreakpoints
	Dim As UString CursorFile
	Dim As Integer CursorLine
	If RunningToCursor Then
		RunningToCursor = False
		If LLDBCursorPlace(CursorFile, CursorLine) Then LLDBWrite "breakpoint set -o true -f " & LLDBQuote(GetFileName(CursorFile)) & " -l " & WStr(CursorLine)
	ElseIf LLDBStopAtStart Then
		LLDBWrite "breakpoint set -o true -n main"
	End If
	LLDBStopAtStart = False
	LLDBRestarting = False
	'Break stops the program with SIGINT, which it does not get
	LLDBWrite "process handle SIGINT --pass false --stop true --notify true"
	LLDBLaunchCommand = "process launch -i /dev/null -o " & LLDBQuote(LLDBOutputFile) & " -e " & LLDBQuote(LLDBOutputFile) & " -w " & LLDBQuote(GetFolderName(ExeFile))
	If Trim(Arguments) <> "" Then LLDBLaunchCommand &= " -- " & Arguments
	LLDBWrite LLDBLaunchCommand
	'The answers of lldb up to its end
	Dim As ZString * 4097 Buff
	Dim As String Pending
	Do
		Dim As Integer n = lldb_read(FdOut(0), @Buff, 4096)
		If n <= 0 Then Exit Do
		Buff[n] = 0
		Pending &= Left(Buff, n)
		Dim As Integer p = InStr(Pending, Chr(10))
		While p > 0
			Dim As String sLine = RTrim(Left(Pending, p - 1), Chr(13))
			Pending = Mid(Pending, p + 1)
			LLDBLine sLine
			p = InStr(Pending, Chr(10))
		Wend
	Loop
	If Pending <> "" Then LLDBLine Pending
	MutexLock LLDBMutex
	lldb_close(LLDBInput)
	LLDBInput = -1
	MutexUnlock LLDBMutex
	lldb_close(FdOut(0))
	Dim As Long Status
	lldb_waitpid(LLDBPid, @Status, 0)
	LLDBPid = 0
	LLDBProgramPid = 0
	LLDBShowProgramOutput
	InDebug = False
	iFlagStartDebug = 0
	Running = False
	DeleteDebugCursor
	ShowMessages Time & ": " & ML("Debugging finished."), False
	ChangeEnabledDebug True, False, False
End Sub

Sub RunProgramWithDebug(Param As Any Ptr)
	Dim As ProjectElement Ptr Project
	Dim As TreeNode Ptr ProjectNode
	Dim As UString CompileLine, MainFile = GetMainFile(, Project, ProjectNode)
	Dim As UString FirstLine = GetFirstCompileLine(MainFile, Project, CompileLine)
	If Project <> 0 Then
		RunWithDebug , *Project->FileName, *Project->CommandLineArguments, MainFile, CompileLine, FirstLine
	Else
		RunWithDebug , "", "", MainFile, CompileLine, FirstLine
	End If
End Sub

Private Sub LLDBStartWithCompile(Param As Any Ptr)
	If Compile("RunWithDebug") = 0 Then ChangeEnabledDebug True, False, False
End Sub

Private Sub LLDBStart(Param As Any Ptr)
	RunProgramWithDebug(0)
End Sub

Private Sub LLDBContinue(ByRef sCommand As WString)
	If Not LLDBActive Then Exit Sub
	DeleteDebugCursor
	Running = True
	ChangeEnabledDebug False, True, True
	LLDBWrite sCommand
End Sub

Sub continue_debug()
	LLDBContinue "process continue"
End Sub

Sub step_debug(s As String)
	Select Case s
	Case "s": LLDBContinue "thread step-in"
	Case "n": LLDBContinue "thread step-over"
	Case "o": LLDBContinue "thread step-out"
	Case Else: LLDBContinue s
	End Select
End Sub

Sub kill_debug()
	If LLDBProgramPid > 0 Then
		kill_(LLDBProgramPid, 9)
	ElseIf LLDBPid > 0 Then
		'The program did not start (lldb waits for the permission of macOS)
		kill_(LLDBPid, 9)
	End If
End Sub

'The command of the GDB Command window, "print X" of Watches
Sub command_debug(sCom As String)
	If StartsWith(sCom, "print ") Then
		If WatchIndex >= 0 AndAlso WatchIndex < lvWatches.Nodes.Count Then
			Dim As String sType, sValue = LLDBFindValue(Mid(sCom, 7), sType)
			lvWatches.Nodes.Item(WatchIndex)->Text(1) = LLDBShownValue(sValue, sType)
			lvWatches.Nodes.Item(WatchIndex)->Text(2) = sType
		End If
		Exit Sub
	End If
	If Not LLDBActive Then
		ShowMessages ML("The debugger is not started.")
		Exit Sub
	End If
	LLDBUserCommand = Trim(sCom)
	LLDBWrite LLDBUserCommand
End Sub

Function get_var_value(VarName As String, LineIndex As Integer) As String
	Return LLDBFindValue(VarName)
End Function

Sub info_all_variables_debug(iFlagUpdate As Long = 0)
End Sub

'Breakpoint of the editor while debugging: before the change of the line
Sub set_bp(Temporary As Boolean = False)
	If Not LLDBActive Then Exit Sub
	Dim As UString FileName
	Dim As Integer LineNo
	If Not LLDBCursorPlace(FileName, LineNo) Then Exit Sub
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	Dim As UString Place = " -f " & LLDBQuote(GetFileName(FileName)) & " -l " & WStr(LineNo)
	If Temporary Then
		LLDBWrite "breakpoint set -o true" & Place
	ElseIf Cast(EditControlLine Ptr, tb->txtCode.Content.Lines.Items[LineNo - 1])->Breakpoint Then
		LLDBWrite "breakpoint clear" & Place
	Else
		LLDBWrite "breakpoint set" & Place
	End If
End Sub

Sub brk_set(t As Integer)
	set_bp
End Sub

Function kill_process(text As String) As Integer
	Return 0
End Function

'The commands of the debugger of the IDE (mClick of VisualFBEditor.bas)
Sub LLDBCommand(ByRef sCommand As String)
	Dim As Boolean UseLLDB = UseDebugger
	Select Case sCommand
	Case "StartWithCompile"
		If LLDBActive Then
			If Not Running Then continue_debug
		ElseIf SaveAllBeforeCompile Then
			ChangeEnabledDebug False, True, True
			If UseLLDB Then
				ThreadCounter(ThreadCreate_(@LLDBStartWithCompile))
			Else
				ThreadCounter(ThreadCreate_(@CompileAndRun))
			End If
		End If
	Case "Start"
		If LLDBActive Then
			If Not Running Then continue_debug
		ElseIf UseLLDB Then
			ChangeEnabledDebug False, True, True
			ThreadCounter(ThreadCreate_(@LLDBStart))
		Else
			ThreadCounter(ThreadCreate_(@RunProgram))
		End If
	Case "Restart"
		If LLDBActive Then
			LLDBRestarting = True
			LLDBContinue LLDBLaunchCommand
		ElseIf SaveAllBeforeCompile Then
			ThreadCounter(ThreadCreate_(@CompileAndRun))
		End If
	Case "Break"
		If LLDBProgramPid > 0 AndAlso Running Then kill_(LLDBProgramPid, 2)
	Case "End"
		'A compilation in progress: its processes are terminated, Compile ends after them
		If CompileRunning Then
			CompileStopped = True
			If CompilePid > 0 Then kill_(-CompilePid, 15)
		ElseIf LLDBActive Then
			kill_debug
		End If
	Case "StepInto", "StepOver", "StepOut", "RunToCursor"
		If LLDBActive Then
			If Running Then Exit Sub
			Select Case sCommand
			Case "StepInto": step_debug "s"
			Case "StepOver": step_debug "n"
			Case "StepOut": step_debug "o"
			Case "RunToCursor"
				Dim As UString FileName
				Dim As Integer LineNo
				If LLDBCursorPlace(FileName, LineNo) Then LLDBWrite "breakpoint set -o true -f " & LLDBQuote(GetFileName(FileName)) & " -l " & WStr(LineNo)
				continue_debug
			End Select
		ElseIf sCommand <> "StepOut" Then
			LLDBStopAtStart = sCommand <> "RunToCursor"
			RunningToCursor = sCommand = "RunToCursor"
			ChangeEnabledDebug False, True, True
			ThreadCounter(ThreadCreate_(@LLDBStart))
		End If
	Case "SetNextStatement"
		If LLDBActive AndAlso Not Running Then
			Dim As UString FileName
			Dim As Integer LineNo
			If LLDBCursorPlace(FileName, LineNo) Then
				LLDBWrite "thread jump -f " & LLDBQuote(GetFileName(FileName)) & " -l " & WStr(LineNo)
				LLDBWrite "bt"
				LLDBWrite "vfbe_bt_end"
			End If
		End If
	Case "ShowVar", "AddWatch"
		Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb = 0 Then Exit Sub
		Dim As String sWord = Trim(ToUtf8(tb->txtCode.GetWordAtCursor))
		If sWord = "" Then Exit Sub
		Dim As String sType, sValue = LLDBFindValue(sWord, sType)
		If sCommand = "ShowVar" Then
			ShowMessages LLDBText(sWord) & " = " & LLDBShownValue(sValue, sType) & IIf(sType = "", "", " (" & sType & ")")
		Else
			If lvWatches.Nodes.Count = 0 OrElse lvWatches.Nodes.Item(lvWatches.Nodes.Count - 1)->Text(0) <> "" Then lvWatches.Nodes.Add
			Var Item = lvWatches.Nodes.Item(lvWatches.Nodes.Count - 1)
			Item->Text(0) = LLDBText(sWord)
			Item->Text(1) = LLDBShownValue(sValue, sType)
			Item->Text(2) = sType
			lvWatches.Nodes.Add
			tpWatches->Caption = ML("Watches") & " (" & Str(lvWatches.Nodes.Count - 1) & " " & ML("Pos") & ")"
			tpWatches->SelectTab
		End If
	End Select
End Sub
