'#########################################################
'#  DebugMI.bas                                          #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#########################################################

'The machine interface of gdb (gdb --interpreter=mi2) and of lldb-mi: Integrated GDB Debugger or Integrated LLDB
'Debugger with the interface MI (Options).
'Each command of the IDE has a number (token) before it, the answer of gdb begins with this number: 12^done,... or
'12^error,msg="...". The events of the program are without numbers: *stopped,reason="breakpoint-hit",frame={...},
'*running, =thread-group-started,pid="N". The texts of gdb (~"..."), of the program (@"...") and the log (&"...") are
'C strings. After a stop the IDE asks the frames (-stack-list-frames), selects the first frame with a line of the
'program and asks its variables with their values and then with their types (-stack-list-variables).

#include once "DebugCommon.bas"

Dim Shared As DbgProcessType GdbMiProcess
'lldb-mi: Restart ends lldb-mi and starts it again (GdbMiRunWithDebug)
Dim Shared As Boolean GdbMiRestartRequested
Dim Shared As Boolean GdbMiRunning, GdbMiIsLLDB, GdbMiStopAtStart, GdbMiRestarting, GdbMiUserPending, GdbMiExited
Dim Shared As Long GdbMiProgramPid, GdbMiToken, GdbMiExitCode
Dim Shared As String GdbMiThreadId, GdbMiFramesThread
'The purposes of the commands by their numbers: frames, locals, types, user, run, bp:File:Line
Dim Shared As String GdbMiPurposes(Any)
'The breakpoints of gdb: the places File:Line and their numbers
Dim Shared As String GdbMiBpPlaces(Any), GdbMiBpNumbers(Any)
Dim Shared As DbgRecord GdbMiLocals
'The reads of the memory of WString Ptr before the stop is shown
Dim Shared As Integer GdbMiStrPending

'The text of a C string of MI without its quotes: \n, \t, \", \\ and the bytes of UTF-8 in octal (\303\274)
Function GdbMiUnescape(ByRef s As String, ByRef i As Integer) As String
	Dim As String Result
	i += 1
	Do While i <= Len(s)
		Dim As String c = Mid(s, i, 1)
		If c = """" Then
			i += 1
			Exit Do
		ElseIf c = "\" AndAlso i < Len(s) Then
			Dim As String e = Mid(s, i + 1, 1)
			Select Case e
			Case "n": Result &= Chr(10): i += 2
			Case "t": Result &= Chr(9): i += 2
			Case "r": Result &= Chr(13): i += 2
			Case "e": Result &= Chr(27): i += 2
			Case "0" To "7"
				Dim As Integer Code, k = i + 1
				While k <= Len(s) AndAlso k <= i + 3 AndAlso Mid(s, k, 1) >= "0" AndAlso Mid(s, k, 1) <= "7"
					Code = Code * 8 + Val(Mid(s, k, 1))
					k += 1
				Wend
				Result &= Chr(Code And 255)
				i = k
			Case Else: Result &= e: i += 2
			End Select
		Else
			Result &= c
			i += 1
		End If
	Loop
	Return Result
End Function

Declare Sub GdbMiParseValue(ByRef s As String, ByRef i As Integer, ByRef Path As String, ByRef r As DbgRecord)

'name=value,name=value up to the end or up to } of a tuple
Sub GdbMiParseResults(ByRef s As String, ByRef i As Integer, ByRef Prefix As String, ByRef r As DbgRecord, ByRef Closing As String = "")
	Do While i <= Len(s)
		Dim As String c = Mid(s, i, 1)
		If c = "," Then i += 1: Continue Do
		If Closing <> "" AndAlso c = Closing Then i += 1: Exit Do
		Dim As Integer p = InStr(i, s, "=")
		If p = 0 Then i = Len(s) + 1: Exit Do
		Dim As String sName = Mid(s, i, p - i)
		i = p + 1
		GdbMiParseValue s, i, IIf(Prefix = "", sName, Prefix & "." & sName), r
	Loop
End Sub

Sub GdbMiParseValue(ByRef s As String, ByRef i As Integer, ByRef Path As String, ByRef r As DbgRecord)
	Dim As String c = Mid(s, i, 1)
	If c = """" Then
		r.Add Path, GdbMiUnescape(s, i)
	ElseIf c = "{" Then
		i += 1
		GdbMiParseResults s, i, Path, r, "}"
	ElseIf c = "[" Then
		'A list of values or of results (frame={...}): their paths are Path.0, Path.1
		i += 1
		Dim As Integer n
		Do While i <= Len(s)
			c = Mid(s, i, 1)
			If c = "]" Then i += 1: Exit Do
			If c = "," Then i += 1: Continue Do
			If c = """" OrElse c = "{" OrElse c = "[" Then
				GdbMiParseValue s, i, Path & "." & n, r
			Else
				Dim As Integer p = InStr(i, s, "=")
				If p = 0 Then i = Len(s) + 1: Exit Do
				i = p + 1
				GdbMiParseValue s, i, Path & "." & n, r
			End If
			n += 1
		Loop
		r.Add Path & "#", Str(n)
	Else
		i += 1
	End If
End Sub

Private Sub GdbMiWrite(ByRef sCommand As String, ByRef Purpose As String = "")
	MutexLock DbgWriteMutex
	If GdbMiRunning Then
		GdbMiToken += 1
		If GdbMiToken > UBound(GdbMiPurposes) Then ReDim Preserve GdbMiPurposes(GdbMiToken + 100)
		GdbMiPurposes(GdbMiToken) = Purpose
		DbgWriteInput GdbMiProcess, GdbMiToken & sCommand & Chr(10)
	End If
	MutexUnlock DbgWriteMutex
End Sub

Function GdbMiActive() As Boolean
	Return GdbMiRunning
End Function

Private Function GdbMiQuote(ByRef s As WString) As String
	Return """" & Replace(Replace(ToUtf8(s), "\", "\\"), """", "\""") & """"
End Function

Private Function GdbMiPlace(ByRef FileName As WString, LineNo As Integer) As String
	Return GdbMiQuote(DbgPath(FileName) & ":" & LineNo)
End Function

Private Sub GdbMiShowText(ByRef Text As String)
	DbgShowText Text
End Sub

Declare Sub GdbMiShowStop()

'The memory of a WString Ptr (wstr:Index:Address): its text after the address
Private Sub GdbMiWideResult(ByRef Purpose As String, ByRef Contents As String)
	Dim As Integer p1 = InStr(6, Purpose, ":")
	Dim As Integer j = Val(Mid(Purpose, 6, p1 - 6))
	If Contents <> "" Then
		Dim As String sPrefix = "variables." & j & "."
		GdbMiLocals.Set sPrefix & "value", DbgPointerAddress(GdbMiLocals.Get(sPrefix & "value")) & " " & DbgWideText(DbgHexBytes(Contents))
	End If
	GdbMiStrPending -= 1
	If GdbMiStrPending <= 0 Then GdbMiStrPending = 0: GdbMiShowStop
End Sub

Sub GdbMiShowStop()
	DbgClearVariables
	lvLocals.Nodes.Clear
	lvGlobals.Nodes.Clear
	Dim As Integer n = GdbMiLocals.Count("variables")
	For i As Integer = 0 To n - 1
		Dim As String sCName = GdbMiLocals.Get("variables." & i & ".name")
		Dim As String sName = DbgName(sCName)
		If sName = "" Then Continue For
		Dim As String sValue = GdbMiLocals.Get("variables." & i & ".value")
		Dim As String sType = DbgType(GdbMiLocals.Get("variables." & i & ".ctype"), sValue)
		Var Item = DbgAddVariable(@lvLocals, 0, sName, sName, sValue, sType)
		If sType <> "String" Then DbgAddValueChildren @lvLocals, Item, sName, sValue
	Next
	DbgShowCaptions
	DbgShowFrames
	DbgUpdateWatches
	DbgShowCursor
	tpLocals->SelectTab
	Running = False
	ChangeEnabledDebug True, False, True
End Sub

'The answer of a command with a number
Private Sub GdbMiResult(Token As Long, ByRef sClass As String, ByRef r As DbgRecord)
	Dim As String Purpose
	If Token > 0 AndAlso Token <= UBound(GdbMiPurposes) Then Purpose = GdbMiPurposes(Token)
	If sClass = "error" Then
		Select Case Purpose
		Case "", "init"
		Case "user"
			GdbMiUserPending = False
			ShowMessages DbgText(r.Get("msg")), False
		Case "frames", "locals", "types"
			'The program did not stop at a line of it: the stop is shown without its variables
			If Purpose <> "types" Then GdbMiLocals.Clear
			GdbMiShowStop
		Case Else
			If StartsWith(Purpose, "wstr:") Then
				'The memory ends before 512 bytes: 64 bytes, else the address only (wstr:Index:Address:64)
				Dim As Integer p1 = InStr(6, Purpose, ":")
				If InStr(p1 + 1, Purpose, ":") = 0 Then
					GdbMiWrite "-data-read-memory-bytes " & Mid(Purpose, p1 + 1) & " 64", Purpose & ":64"
				Else
					GdbMiWideResult Purpose, ""
				End If
				Exit Sub
			End If
			ShowMessages IIf(GdbMiIsLLDB, "lldb-mi: ", "gdb: ") & DbgText(r.Get("msg")), False
			If Purpose = "run" OrElse Purpose = "file" Then GdbMiWrite "-gdb-exit"
		End Select
		Exit Sub
	End If
	Select Case Purpose
	Case "frames"
		Erase DbgFrames
		Dim As Integer n = r.Count("stack")
		If n > 0 Then ReDim DbgFrames(n - 1)
		For i As Integer = 0 To n - 1
			DbgFrames(i).Func = r.Get("stack." & i & ".func")
			DbgFrames(i).File = r.Get("stack." & i & ".fullname")
			If DbgFrames(i).File = "" Then DbgFrames(i).File = r.Get("stack." & i & ".file")
			'lldb-mi: /C:/crossdev/... of the files of the C runtime
			If Mid(DbgFrames(i).File, 1, 1) = "/" AndAlso Mid(DbgFrames(i).File, 3, 1) = ":" Then DbgFrames(i).File = Mid(DbgFrames(i).File, 2)
			DbgFrames(i).LineNo = Val(r.Get("stack." & i & ".line"))
		Next
		DbgFrameIndex = DbgProgramFrame
		GdbMiLocals.Clear
		If DbgFrameIndex < 0 AndAlso GdbMiFramesThread <> "1" Then
			'Break of Windows stops the program in a new thread: the frames of the first thread
			GdbMiFramesThread = "1"
			GdbMiWrite "-thread-select 1"
			GdbMiWrite "-stack-list-frames --thread 1", "frames"
		ElseIf DbgFrameIndex < 0 Then
			GdbMiShowStop
		Else
			GdbMiWrite "-stack-select-frame " & DbgFrameIndex
			GdbMiWrite "-stack-list-variables --thread " & GdbMiFramesThread & " --frame " & DbgFrameIndex & " --all-values", "locals"
		End If
	Case "locals"
		GdbMiLocals = r
		GdbMiWrite "-stack-list-variables --thread " & GdbMiFramesThread & " --frame " & DbgFrameIndex & " --simple-values", "types"
	Case "types"
		'The types of the variables of the list of their values
		Dim As Integer n = r.Count("variables")
		For i As Integer = 0 To n - 1
			Dim As String sName = r.Get("variables." & i & ".name")
			For j As Integer = 0 To GdbMiLocals.Count("variables") - 1
				If GdbMiLocals.Get("variables." & j & ".name") = sName Then GdbMiLocals.Add "variables." & j & ".ctype", r.Get("variables." & i & ".type"): Exit For
			Next
		Next
		'The texts of WString Ptr (ByRef WString): gdb and lldb-mi show only their addresses
		GdbMiStrPending = 0
		For j As Integer = 0 To GdbMiLocals.Count("variables") - 1
			Dim As String sAddress = DbgPointerAddress(GdbMiLocals.Get("variables." & j & ".value"))
			If sAddress <> "" AndAlso DbgIsWideCType(GdbMiLocals.Get("variables." & j & ".ctype")) Then
				GdbMiStrPending += 1
				GdbMiWrite "-data-read-memory-bytes " & sAddress & " 512", "wstr:" & j & ":" & sAddress
			End If
		Next
		If GdbMiStrPending = 0 Then GdbMiShowStop
	Case "user"
		GdbMiUserPending = False
		If r.Has("value") Then ShowMessages DbgText(r.Get("value")), False
	Case Else
		If StartsWith(Purpose, "wstr:") Then
			GdbMiWideResult Purpose, r.Get("memory.0.contents")
			Exit Sub
		End If
		If StartsWith(Purpose, "bp:") AndAlso r.Has("bkpt.number") Then
			Dim As Integer n = UBound(GdbMiBpPlaces) + 1
			ReDim Preserve GdbMiBpPlaces(n), GdbMiBpNumbers(n)
			GdbMiBpPlaces(n) = LCase(Mid(Purpose, 4))
			GdbMiBpNumbers(n) = r.Get("bkpt.number")
		End If
	End Select
End Sub

Private Sub GdbMiStopped(ByRef r As DbgRecord)
	Dim As String Reason = r.Get("reason")
	If StartsWith(Reason, "exited") Then
		GdbMiProgramPid = 0
		Dim As Integer Result = IIf(r.Has("exit-code"), ValInt("&O" & r.Get("exit-code")), GdbMiExitCode)
		ShowMessages Time & ": " & ML("Application finished. Returned code") & ": " & Result & " - " & Err2Description(Result)
		DeleteDebugCursor
		If GdbMiRestarting Then
			GdbMiRestarting = False
			Running = True
			GdbMiWrite "-exec-run", "run"
		Else
			GdbMiWrite "-gdb-exit"
		End If
		Exit Sub
	End If
	'Break (a breakpoint of a new thread of Windows) and the signals: the frames of the main thread
	GdbMiThreadId = r.Get("thread-id")
	If Reason = "signal-received" OrElse GdbMiThreadId = "" Then GdbMiThreadId = "1"
	GdbMiFramesThread = GdbMiThreadId
	If GdbMiThreadId = "1" Then GdbMiWrite "-thread-select 1"
	GdbMiWrite "-stack-list-frames --thread " & GdbMiThreadId, "frames"
End Sub

'A line of gdb or lldb-mi
Private Sub GdbMiLine(ByRef sLine As String)
	Dim As String s = sLine
	If s = "" OrElse StartsWith(s, "(gdb)") Then Exit Sub
	Dim As Integer i = 1
	While i <= Len(s) AndAlso Mid(s, i, 1) >= "0" AndAlso Mid(s, i, 1) <= "9"
		i += 1
	Wend
	Dim As Long Token = Val(Left(s, i - 1))
	Dim As String c = Mid(s, i, 1)
	Dim As DbgRecord r
	Select Case c
	Case "^", "*", "="
		Dim As Integer p = InStr(i, s, ",")
		Dim As String sClass = IIf(p = 0, Mid(s, i + 1), Mid(s, i + 1, p - i - 1))
		If p > 0 Then
			Dim As Integer k = p + 1
			GdbMiParseResults s, k, "", r
		End If
		If c = "^" Then
			If sClass = "exit" Then Exit Sub
			GdbMiResult Token, sClass, r
		ElseIf c = "*" Then
			If sClass = "stopped" Then
				GdbMiStopped r
			ElseIf sClass = "running" Then
				Running = True
			End If
		Else
			Select Case sClass
			Case "thread-group-started"
				GdbMiProgramPid = Val(r.Get("pid"))
				GdbMiExited = False
				ShowMessages Time & ": " & ML("Run") & ": " & exename & " (" & GdbMiProgramPid & ")", False
			Case "thread-group-exited"
				If r.Has("exit-code") Then GdbMiExitCode = ValInt("&O" & r.Get("exit-code"))
			End Select
		End If
	Case "~", "&"
		'The texts of gdb: only the answers of the commands of the GDB Command window
		Dim As Integer k = i + 1
		Dim As String Text = GdbMiUnescape(s, k)
		If GdbMiUserPending Then GdbMiShowText Text
	Case "@"
		'The output of the program (lldb-mi)
		Dim As Integer k = i + 1
		GdbMiShowText GdbMiUnescape(s, k)
	Case Else
		'The output of the program on Linux: it is in the output of gdb
		ShowMessages DbgText(sLine), False
	End Select
End Sub

'gdb or lldb-mi debugs the program: this thread reads the answers up to its end
Private Sub GdbMiRunOnce(ByRef ExeFile As WString, ByRef Arguments As WString, ByRef DebuggerPath As WString, IsLLDB As Boolean)
	If GdbMiActive Then Exit Sub
	GdbMiIsLLDB = IsLLDB
	Dim As UString sProgram = DebuggerPath, sArguments = "--interpreter=mi2 -q --nx", sPythonHome
	If IsLLDB Then
		sProgram = DbgLLDBTool(DebuggerPath, "lldb-mi")
		sArguments = "--interpreter"
		sPythonHome = DbgPythonHome(DebuggerPath)
	End If
	If Not DbgStart(GdbMiProcess, sProgram, sArguments, sPythonHome) Then
		ThreadsEnter
		ShowMessages ML("File not found") & ": " & sProgram
		ChangeEnabledDebug True, False, False
		ThreadsLeave
		Exit Sub
	End If
	ThreadsEnter
	MutexLock DbgWriteMutex
	GdbMiRunning = True
	GdbMiToken = 0
	Erase GdbMiPurposes
	MutexUnlock DbgWriteMutex
	DbgBackend = DbgMI
	GdbMiProgramPid = 0
	GdbMiExitCode = 0
	GdbMiUserPending = False
	GdbMiRestarting = False
	Erase GdbMiBpPlaces, GdbMiBpNumbers
	Erase DbgFrames
	DbgClearVariables
	Running = True
	lvLocals.Nodes.Clear
	lvGlobals.Nodes.Clear
	ChangeEnabledDebug False, True, True
	ShowMessages Time & ": " & ML("Run") & ": " & sProgram & " " & sArguments & " " & ExeFile & " ...", False
	GdbMiWrite "-gdb-set confirm off", "init"
	If Not IsLLDB Then
		GdbMiWrite "-gdb-set pagination off", "init"
		GdbMiWrite "-gdb-set print elements 1000", "init"
		#ifdef __FB_WIN32__
			'The program has its console: its output and its input
			GdbMiWrite "-gdb-set new-console on", "init"
		#endif
	End If
	GdbMiWrite "-file-exec-and-symbols " & GdbMiQuote(DbgPath(ExeFile)), "file"
	GdbMiWrite "-environment-cd " & GdbMiQuote(DbgPath(GetFolderName(ExeFile, False))), "init"
	If Trim(Arguments) <> "" Then GdbMiWrite "-exec-arguments " & ToUtf8(Arguments), "init"
	Dim As UString Files()
	Dim As String Lines()
	DbgBreakpoints Files(), Lines()
	For i As Integer = 0 To UBound(Files)
		Dim As WString Ptr Items()
		Split Lines(i), ",", Items()
		For j As Integer = 0 To UBound(Items)
			GdbMiWrite "-break-insert " & GdbMiPlace(Files(i), Val(*Items(j))), "bp:" & ToUtf8(DbgPath(Files(i))) & ":" & *Items(j)
			_Deallocate(Items(j))
		Next
		Erase Items
	Next
	Dim As UString CursorFile
	Dim As Integer CursorLine
	If RunningToCursor Then
		RunningToCursor = False
		If DbgCursorPlace(CursorFile, CursorLine) Then GdbMiWrite "-break-insert -t " & GdbMiPlace(CursorFile, CursorLine)
	ElseIf GdbMiStopAtStart Then
		GdbMiWrite "-break-insert -t main"
	End If
	GdbMiStopAtStart = False
	GdbMiWrite "-exec-run", "run"
	ThreadsLeave
	DbgReadLines GdbMiProcess, @GdbMiLine
	MutexLock DbgWriteMutex
	GdbMiRunning = False
	MutexUnlock DbgWriteMutex
	DbgFinish GdbMiProcess
	ThreadsEnter
	If GdbMiProgramPid > 0 Then DbgKillProcess GdbMiProgramPid
	DbgBackend = DbgNone
	GdbMiProgramPid = 0
	Running = False
	DeleteDebugCursor
	If Not GdbMiRestartRequested Then
		ShowMessages Time & ": " & ML("Debugging finished."), False
		ChangeEnabledDebug True, False, False
	End If
	ThreadsLeave
End Sub

Sub GdbMiRunWithDebug(ByRef ExeFile As WString, ByRef Arguments As WString, ByRef DebuggerPath As WString, IsLLDB As Boolean)
	Do
		GdbMiRestartRequested = False
		GdbMiRunOnce ExeFile, Arguments, DebuggerPath, IsLLDB
	Loop While GdbMiRestartRequested
End Sub

Private Sub GdbMiContinue(ByRef sCommand As String)
	If Not GdbMiActive Then Exit Sub
	DeleteDebugCursor
	Running = True
	ChangeEnabledDebug False, True, True
	GdbMiWrite sCommand
End Sub

Sub GdbMiContinueDebug()
	GdbMiContinue "-exec-continue"
End Sub

Sub GdbMiStepDebug(s As String)
	Select Case s
	Case "s": GdbMiContinue "-exec-step"
	Case "n": GdbMiContinue "-exec-next"
	Case "o": GdbMiContinue "-exec-finish"
	End Select
End Sub

Sub GdbMiRunToCursor()
	Dim As UString FileName
	Dim As Integer LineNo
	If DbgCursorPlace(FileName, LineNo) Then GdbMiWrite "-break-insert -t " & GdbMiPlace(FileName, LineNo)
	GdbMiContinueDebug
End Sub

'gdb: jump continues the program, it stops at the line with a temporary breakpoint
Sub GdbMiSetNextStatement()
	Dim As UString FileName
	Dim As Integer LineNo
	If Not DbgCursorPlace(FileName, LineNo) Then Exit Sub
	GdbMiWrite "-break-insert -t " & GdbMiPlace(FileName, LineNo)
	GdbMiContinue "-exec-jump " & GdbMiPlace(FileName, LineNo)
End Sub

Sub GdbMiBreak()
	If GdbMiProgramPid > 0 AndAlso Running Then DbgInterruptProcess GdbMiProgramPid
End Sub

Sub GdbMiEnd()
	If Not GdbMiActive Then Exit Sub
	If GdbMiProgramPid > 0 AndAlso Running Then
		DbgKillProcess GdbMiProgramPid
	Else
		GdbMiWrite "-gdb-exit"
	End If
End Sub

Sub GdbMiRestart()
	If Not GdbMiActive Then Exit Sub
	If GdbMiIsLLDB Then
		'lldb-mi does not set the breakpoints again in time for a new process: lldb-mi starts again
		Dim As Boolean WasRunning = Running
		GdbMiRestartRequested = True
		DeleteDebugCursor
		Running = True
		ChangeEnabledDebug False, True, True
		If GdbMiProgramPid > 0 AndAlso WasRunning Then DbgKillProcess GdbMiProgramPid
		GdbMiWrite "-gdb-exit"
		Exit Sub
	End If
	If GdbMiProgramPid > 0 AndAlso Running Then
		'The end of the program starts it again (GdbMiStopped)
		GdbMiRestarting = True
		DbgKillProcess GdbMiProgramPid
	Else
		'confirm off: gdb ends the stopped program and starts it again
		GdbMiContinue "-exec-run"
	End If
End Sub

'The command of the GDB Command window
Sub GdbMiCommandDebug(ByRef sCom As String)
	If Not GdbMiActive Then
		ShowMessages ML("The debugger is not started.")
		Exit Sub
	End If
	If Trim(sCom) = "" Then Exit Sub
	ShowMessages "(" & IIf(GdbMiIsLLDB, "lldb", "gdb") & ") " & DbgText(Trim(sCom)), False
	GdbMiUserPending = True
	If Left(Trim(sCom), 1) = "-" Then
		GdbMiWrite Trim(sCom), "user"
	Else
		GdbMiWrite "-interpreter-exec console " & """" & Replace(Replace(Trim(sCom), "\", "\\"), """", "\""") & """", "user"
	End If
End Sub

'Breakpoint of the editor while debugging: before the change of the line
Sub GdbMiSetBp()
	If Not GdbMiActive Then Exit Sub
	Dim As UString FileName
	Dim As Integer LineNo
	If Not DbgCursorPlace(FileName, LineNo) Then Exit Sub
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	Dim As String sPlace = ToUtf8(DbgPath(FileName)) & ":" & LineNo
	If Cast(EditControlLine Ptr, tb->txtCode.Content.Lines.Items[LineNo - 1])->Breakpoint Then
		For i As Integer = 0 To UBound(GdbMiBpPlaces)
			If GdbMiBpPlaces(i) = LCase(sPlace) AndAlso GdbMiBpNumbers(i) <> "" Then
				GdbMiWrite "-break-delete " & GdbMiBpNumbers(i)
				GdbMiBpNumbers(i) = ""
			End If
		Next
	Else
		GdbMiWrite "-break-insert " & GdbMiPlace(FileName, LineNo), "bp:" & sPlace
	End If
End Sub
