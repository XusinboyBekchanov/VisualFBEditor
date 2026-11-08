'#########################################################
'#  DebugLLDB.bas                                        #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#########################################################

'Integrated LLDB Debugger with the commands of lldb (the interface CLI). macOS: the integrated debuggers (Integrated IDE
'Debugger and Integrated GDB Debugger) are also lldb of Xcode or of the Command Line Tools, a custom debugger (a tool of
'Debuggers) runs in Terminal with the program.
'LLDBRunWithDebug starts lldb with pipes, writes it the commands and reads its answers until it ends (the thread of
'RunWithDebug waits there). The prompt is "(vfbe) " and lldb repeats each command after it, so the answer of a command is
'the text up to the next prompt. The frames begin with __VFBE_FRAME__ (frame-format). After a stop (Process N stopped)
'the IDE asks the backtrace (bt), selects the first frame with a line of the program and asks its variables; the end of
'these answers are the commands vfbe_bt_end and vfbe_vars_end (aliases of a setting). The program is compiled with -g
'(Use Debugger), mff/Cocoa/build.sh keeps its information for the debugger in Program.dSYM (MFF_DEBUG); on Windows and
'Linux with -gen gcc -g.
'The output of the program goes to a file which the Output shows after each stop, its input is the null device.

#include once "DebugCommon.bas"

#define LLDB_PROMPT "(vfbe) "
#define LLDB_LOCALS "frame variable -D 3"
#define LLDB_GLOBALS "frame variable --no-args --no-locals --show-globals -D 1"
'Variable Dump (LLDBMemoryDump): the section of its answer
#define LLDB_MEMORY "memory read --size 1 --format x --count "

Dim Shared As DbgProcessType LLDBProcess
Dim Shared As Long LLDBProgramPid
Dim Shared As Boolean LLDBRunning
'The command whose answer lldb writes, the command of the GDB Command window (its answer goes to the Output)
Dim Shared As String LLDBSection, LLDBUserCommand
Dim Shared As String LLDBLocalsText, LLDBGlobalsText, LLDBMemoryText
Dim Shared As UString LLDBOutputFile
Dim Shared As LongInt LLDBOutputRead
'Step Into / Step Over before the start: the program stops at its first line; Restart: the end of the program before
'its new start does not end lldb
Dim Shared As Boolean LLDBLaunched, LLDBStopAtStart, LLDBRestarting
'Break of Windows stops the program in a new thread: the frames of the first thread
Dim Shared As Boolean LLDBMainThreadAsked
'process launch with the file of the output of the program, its folder and its arguments
Dim Shared As UString LLDBLaunchCommand

'The commands which lldb did not repeat after its prompt yet: a text after the prompt which is not the next of them is
'an output (lldb writes the output of an event after the prompt)
Dim Shared As String LLDBCommands(Any)
Dim Shared As Integer LLDBCommandsCount

Private Sub LLDBWrite(ByRef sCommand As WString)
	MutexLock DbgWriteMutex
	If LLDBRunning Then
		Dim As String s = ToUtf8(sCommand)
		If LLDBCommandsCount > UBound(LLDBCommands) Then ReDim Preserve LLDBCommands(LLDBCommandsCount + 50)
		LLDBCommands(LLDBCommandsCount) = s
		LLDBCommandsCount += 1
		DbgWriteInput LLDBProcess, s & Chr(10)
	End If
	MutexUnlock DbgWriteMutex
End Sub

'The command after the prompt: it and the commands before it are repeated
Private Function LLDBRepeatedCommand(ByRef Text As String) As Boolean
	MutexLock DbgWriteMutex
	Dim As Integer Index = -1
	For i As Integer = 0 To LLDBCommandsCount - 1
		If LLDBCommands(i) = Text Then Index = i: Exit For
	Next
	If Index >= 0 Then
		For i As Integer = Index + 1 To LLDBCommandsCount - 1
			LLDBCommands(i - Index - 1) = LLDBCommands(i)
		Next
		LLDBCommandsCount -= Index + 1
	End If
	MutexUnlock DbgWriteMutex
	Return Index >= 0
End Function

Function LLDBActive() As Boolean
	Return LLDBRunning
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
		Dim As UString Text = DbgText(Buff)
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

#ifdef __USE_COCOA__
	Sub DeleteDebugCursor
		If CurEC <> 0 Then
			Var curEC2 = CurEC
			CurEC->CurExecutedLine = -1
			CurEC = 0
			curEC2->Repaint
		End If
	End Sub
#endif

'Breakpoints of the open files
Private Sub LLDBSetBreakpoints()
	Dim As UString Files()
	Dim As String Lines()
	DbgBreakpoints Files(), Lines()
	For i As Integer = 0 To UBound(Files)
		Dim As WString Ptr Items()
		Split Lines(i), ",", Items()
		For j As Integer = 0 To UBound(Items)
			Dim As Integer nIgnore = DbgIgnoreCount(Files(i), Val(*Items(j)))
			Dim As String sCond = DbgBreakpointCondition(Files(i), Val(*Items(j)))
			LLDBWrite "breakpoint set" & IIf(nIgnore, " -i " & nIgnore, "") & IIf(sCond <> "", " -c '" & sCond & "'", "") & " -f " & DbgQuote(GetFileName(Files(i))) & " -l " & *Items(j)
			_Deallocate(Items(j))
		Next
		Erase Items
	Next
End Sub

'The variables of lldb: one variable or field on a line, the fields of a structure between { and }; a short structure
'is on one line: (X = 3, Y = 4)
Private Sub LLDBAddVariables(lv As TreeListView Ptr, ByRef Text As String)
	Dim As TreeListViewItem Ptr Parents(100)
	Dim As String Paths(100)
	Dim As Boolean Skipped(100)
	Dim As Integer Depth, p
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
		If Right(sValue, 1) = "," Then sValue = Left(sValue, Len(sValue) - 1)
		Dim As Boolean Opens = Right(sValue, 1) = "{"
		If Opens Then sValue = RTrim(Left(sValue, Len(sValue) - 1))
		If Depth = 0 Then sName = DbgName(sName)
		Dim As Boolean Skip = sName = "" OrElse (Depth > 0 AndAlso Skipped(Depth))
		Dim As TreeListViewItem Ptr Item
		If Not Skip Then
			If Depth = 0 Then
				sPath = sName
				Item = DbgAddVariable(lv, 0, sPath, sName, sValue, DbgType(sType, sValue))
			Else
				sPath = Paths(Depth) & IIf(Left(sName, 1) = "[", "", ".") & sName
				Item = DbgAddVariable(lv, Parents(Depth), sPath, sName, sValue, DbgType(sType, sValue))
			End If
			If Not Opens Then DbgAddValueChildren lv, Item, sPath, sValue
		End If
		If Opens AndAlso Depth < 99 Then
			Depth += 1
			Parents(Depth) = Item
			Paths(Depth) = sPath
			Skipped(Depth) = Skip OrElse Item = 0
		End If
	Loop
End Sub

'The place, the variables and the frames of the stop
Private Sub LLDBShowStop()
	LLDBShowProgramOutput
	DbgClearVariables
	DbgViewDataChanging
	lvLocals.Nodes.Clear
	LLDBAddVariables @lvLocals, LLDBLocalsText
	DbgViewDataChanging
	lvGlobals.Nodes.Clear
	LLDBAddVariables @lvGlobals, LLDBGlobalsText
	DbgShowCaptions
	DbgShowFrames
	DbgUpdateWatches
	DbgShowCursor
	tpLocals->SelectTab
	Running = False
	ChangeEnabledDebug True, False, True
End Sub

'A line of lldb
Private Sub LLDBLine(ByRef sLine As String)
	Dim As String Text = sLine
	If StartsWith(Text, LLDB_PROMPT) Then
		'The next command: its answer follows (lldb writes the prompt again after an event of the program)
		Do While StartsWith(Text, LLDB_PROMPT)
			Text = Mid(Text, Len(LLDB_PROMPT) + 1)
		Loop
		If Text = "" OrElse Not LLDBRepeatedCommand(Text) Then GoTo LLDBOutputLine
		LLDBSection = Text
		Select Case Text
		Case "vfbe_bt_end"
			'The first frame with a line of the program, then its variables
			DbgFrameIndex = DbgProgramFrame
			If DbgFrameIndex < 0 AndAlso Not LLDBMainThreadAsked Then
				LLDBMainThreadAsked = True
				LLDBWrite "thread select 1"
				LLDBWrite "bt"
				LLDBWrite "vfbe_bt_end"
				Exit Sub
			End If
			If DbgFrameIndex > 0 Then LLDBWrite "frame select " & WStr(DbgFrameIndex)
			LLDBLocalsText = ""
			LLDBGlobalsText = ""
			LLDBWrite LLDB_LOCALS
			LLDBWrite LLDB_GLOBALS
			LLDBWrite "vfbe_vars_end"
		Case "vfbe_vars_end"
			LLDBShowStop
		Case "vfbe_mem_end"
			'Variable Dump: the lines of memory read (mem_show_text of Debug.bas)
			mem_show_text LLDBMemoryText
			LLDBMemoryText = ""
		Case "bt"
			Erase DbgFrames
		End Select
		If Text = LLDBUserCommand AndAlso Text <> "" Then ShowMessages "(lldb) " & DbgText(Text), False
	End If
	LLDBOutputLine:
	If Text = "" Then Exit Sub
	'The events of the program, lldb writes them also between the answers of the commands
	If StartsWith(Text, "Process ") AndAlso Val(Mid(Text, 9)) > 0 Then
		Dim As Integer p = InStr(9, Text, " ")
		Dim As Long Pid = Val(Mid(Text, 9))
		Dim As String sEvent = Mid(Text, p + 1)
		If StartsWith(sEvent, "launched") Then
			LLDBProgramPid = Pid
			LLDBLaunched = True
			LLDBRestarting = False
			ShowMessages Time & ": " & DbgText(Text), False
		ElseIf StartsWith(sEvent, "stopped") Then
			LLDBMainThreadAsked = False
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
	If StartsWith(LLDBSection, LLDB_MEMORY) Then
		If InStr(Text, "error:") > 0 Then ShowMessages "lldb: " & DbgText(Text), False Else LLDBMemoryText &= Text & Chr(10)
		Exit Sub
	End If
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
			'thread select writes the frame 0 also: the frames begin again with the frame 0
			If Val(Frame) = 0 Then Erase DbgFrames
			Dim As Integer n = UBound(DbgFrames) + 1
			ReDim Preserve DbgFrames(n)
			'index|function|file|line
			Dim As Integer f1 = InStr(Frame, "|"), f2 = InStr(f1 + 1, Frame, "|"), f3 = InStr(f2 + 1, Frame, "|")
			If f1 > 0 AndAlso f2 > 0 AndAlso f3 > 0 Then
				DbgFrames(n).Func = Mid(Frame, f1 + 1, f2 - f1 - 1)
				DbgFrames(n).File = Mid(Frame, f2 + 1, f3 - f2 - 1)
				DbgFrames(n).LineNo = Val(Mid(Frame, f3 + 1))
			End If
		End If
		Exit Sub
	End Select
	If InStr(Text, "error:") > 0 Then
		ShowMessages "lldb: " & DbgText(Text), False
		If StartsWith(LLDBSection, "process launch") AndAlso Not LLDBLaunched Then
			#ifdef __USE_COCOA__
				ShowMessages ML("macOS allows the debugger after a confirmation (a password of an administrator) or after the command ""sudo DevToolsSecurity -enable"" in Terminal.")
			#endif
			LLDBWrite "quit"
		End If
		Exit Sub
	End If
	If CBool(LLDBSection = LLDBUserCommand) AndAlso CBool(LLDBSection <> "") AndAlso Not StartsWith(sLine, LLDB_PROMPT) Then ShowMessages DbgText(Text), False
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
	Print #Fn, "        r = _text(valobj, addr, 1000, " & SizeOf(WString) & ") if addr else None"
	Print #Fn, "    else:"
	Print #Fn, "        r = _text(valobj, valobj.GetLoadAddress(), t.GetByteSize() // " & SizeOf(WString) & ", " & SizeOf(WString) & ")"
	Print #Fn, "        if r is not None: r = (r[0], False)"
	Print #Fn, "    return None if r is None else _quote(r[0], 'L', r[1])"
	Print #Fn, "def zstr(valobj, d):"
	Print #Fn, "    r = _text(valobj, valobj.GetLoadAddress(), valobj.GetType().GetByteSize(), 1)"
	Print #Fn, "    return None if r is None else _quote(r[0], '', False)"
	CloseFile_(Fn)
	Return ScriptFile
End Function

#ifdef __USE_COCOA__
	'A custom debugger: its command in a window of Terminal
	Private Sub LLDBRunInTerminal(Tool As ToolType Ptr, ByRef ExeFile As WString, ByRef Arguments As WString)
		Dim As UString sCommand = Tool->GetCommand(ExeFile)
		If InStr(Tool->Parameters, "{E}") = 0 Then sCommand &= " " & DbgQuote(ExeFile)
		If Trim(Arguments) <> "" Then sCommand &= " -- " & Arguments
		Dim As UString ScriptFile = GetUserTempPath("VFBEDebugger.command")
		Dim As Integer Fn = FreeFile_
		If Open(ScriptFile For Output As #Fn) <> 0 Then
			ShowMessages ML("File not found") & ": " & ScriptFile
			Exit Sub
		End If
		Print #Fn, "#!/bin/sh"
		Print #Fn, "cd " & ToUtf8(DbgQuote(GetFolderName(ExeFile)))
		Print #Fn, ToUtf8(sCommand)
		CloseFile_(Fn)
		Shell "chmod +x " & ToUtf8(DbgQuote(ScriptFile))
		ShowMessages Time & ": " & ML("Run") & ": " & sCommand
		Shell "open -a Terminal " & ToUtf8(DbgQuote(ScriptFile))
	End Sub
#endif

'lldb debugs the program: this thread reads the answers of lldb up to its end
Sub LLDBRunWithDebug(ByRef ExeFile As WString, ByRef Arguments As WString, ByRef LLDBPath As WString)
	If LLDBActive Then Exit Sub
	Dim As UString sPythonHome = DbgPythonHome(LLDBPath)
	If Not DbgStart(LLDBProcess, LLDBPath, "--no-use-colors --no-lldbinit", sPythonHome) Then
		ThreadsEnter
		#ifdef __USE_COCOA__
			ShowMessages ML("File not found") & ": " & LLDBPath & " (" & ML("Command Line Tools for Xcode") & ": xcode-select --install)"
		#else
			ShowMessages ML("File not found") & ": " & LLDBPath
		#endif
		ChangeEnabledDebug True, False, False
		ThreadsLeave
		Exit Sub
	End If
	ThreadsEnter
	MutexLock DbgWriteMutex
	LLDBRunning = True
	MutexUnlock DbgWriteMutex
	DbgBackend = DbgLLDBCLI
	LLDBProgramPid = 0
	LLDBLaunched = False
	LLDBSection = ""
	LLDBCommandsCount = 0
	LLDBUserCommand = ""
	Erase DbgFrames
	DbgClearVariables
	LLDBOutputFile = GetUserTempPath("VFBEProgramOutput.txt")
	If FileExists(LLDBOutputFile) Then Kill LLDBOutputFile
	LLDBOutputRead = 0
	#ifdef __USE_COCOA__
		InDebug = True
		iFlagStartDebug = 1
	#endif
	Running = True
	DbgViewDataChanging
	lvLocals.Nodes.Clear
	lvGlobals.Nodes.Clear
	ChangeEnabledDebug False, True, True
	ShowMessages Time & ": " & ML("Run") & ": " & LLDBPath & " " & ExeFile & " ..."
	LLDBWrite "settings set prompt " & DbgQuote(LLDB_PROMPT)
	LLDBWrite "settings set auto-confirm true"
	LLDBWrite "settings set stop-line-count-before 0"
	LLDBWrite "settings set stop-line-count-after 0"
	LLDBWrite "settings set stop-disassembly-display never"
	LLDBWrite "settings set target.max-children-count 256"
	LLDBWrite "settings set frame-format ""__VFBE_FRAME__|${frame.index}|{${function.name}}|{${line.file.fullpath}}|{${line.number}}\n"""
	LLDBWrite "command alias vfbe_bt_end settings show auto-confirm"
	LLDBWrite "command alias vfbe_vars_end settings show auto-confirm"
	LLDBWrite "command alias vfbe_mem_end settings show auto-confirm"
	LLDBWrite "type summary add -s ""${var.data%s}"" FBSTRING"
	'WString (uint32 of C) and ZString * N as their texts
	Dim As UString ScriptFile = LLDBScript
	If ScriptFile <> "" Then
		LLDBWrite "command script import " & DbgQuote(ScriptFile)
		LLDBWrite "type summary add -F vfbe_lldb.wstr -x ""^(const )?uint" & SizeOf(WString) * 8 & " ?\[[0-9]+\]$"""
		LLDBWrite "type summary add -F vfbe_lldb.wstr ""uint" & SizeOf(WString) * 8 & " *"""
		LLDBWrite "type summary add -F vfbe_lldb.zstr -x ""^(const )?(char|uint8) ?\[[0-9]+\]$"""
	End If
	LLDBWrite "target create " & DbgQuote(ExeFile)
	LLDBSetBreakpoints
	Dim As UString CursorFile
	Dim As Integer CursorLine
	If RunningToCursor Then
		RunningToCursor = False
		If DbgCursorPlace(CursorFile, CursorLine) Then LLDBWrite "breakpoint set -o true -f " & DbgQuote(GetFileName(CursorFile)) & " -l " & WStr(CursorLine)
	ElseIf LLDBStopAtStart Then
		LLDBWrite "breakpoint set -o true -n main"
	End If
	LLDBStopAtStart = False
	LLDBRestarting = False
	#ifdef __FB_WIN32__
		Dim As String NullDevice = "nul"
	#else
		Dim As String NullDevice = "/dev/null"
		'Break stops the program with SIGINT, which it does not get
		LLDBWrite "process handle SIGINT --pass false --stop true --notify true"
	#endif
	LLDBLaunchCommand = "process launch -i " & NullDevice & " -o " & DbgQuote(LLDBOutputFile) & " -e " & DbgQuote(LLDBOutputFile) & " -w " & DbgQuote(GetFolderName(ExeFile))
	If Trim(Arguments) <> "" Then LLDBLaunchCommand &= " -- " & Arguments
	If AttachPid <> 0 Then LLDBLaunchCommand = "process attach --pid " & AttachPid: AttachPid = 0 'Attach to Process
	LLDBWrite LLDBLaunchCommand
	ThreadsLeave
	'The answers of lldb up to its end
	DbgReadLines LLDBProcess, @LLDBLine
	MutexLock DbgWriteMutex
	LLDBRunning = False
	MutexUnlock DbgWriteMutex
	DbgFinish LLDBProcess
	ThreadsEnter
	DbgBackend = DbgNone
	LLDBProgramPid = 0
	LLDBShowProgramOutput
	#ifdef __USE_COCOA__
		InDebug = False
		iFlagStartDebug = 0
	#endif
	Running = False
	DeleteDebugCursor
	ShowMessages Time & ": " & ML("Debugging finished."), False
	ChangeEnabledDebug True, False, False
	ThreadsLeave
End Sub

Private Sub LLDBContinue(ByRef sCommand As WString)
	If Not LLDBActive Then Exit Sub
	DeleteDebugCursor
	Running = True
	ChangeEnabledDebug False, True, True
	LLDBWrite sCommand
End Sub

Sub LLDBContinueDebug()
	LLDBContinue "process continue"
End Sub

Sub LLDBStepDebug(s As String)
	Select Case s
	Case "s": LLDBContinue "thread step-in"
	Case "n": LLDBContinue "thread step-over"
	Case "o": LLDBContinue "thread step-out"
	Case Else: LLDBContinue s
	End Select
End Sub

Sub LLDBKillDebug()
	If LLDBProgramPid > 0 AndAlso Not Running Then
		'A stopped program: lldb ends it, its exit ends lldb
		LLDBWrite "process kill"
	ElseIf LLDBProgramPid > 0 Then
		DbgKillProcess LLDBProgramPid
	ElseIf LLDBProcess.Pid > 0 Then
		'The program did not start (lldb waits for the permission of macOS)
		DbgKillProcess LLDBProcess.Pid
	End If
End Sub

'The command of the GDB Command window, "print X" of Watches
'Variable Dump, Pointed data Dump: the memory at the address sExpression, its lines up to vfbe_mem_end
Sub LLDBMemoryDump(ByRef sExpression As String)
	If Not LLDBActive Then ShowMessages ML("The debugger is not started."): Exit Sub
	LLDBMemoryText = ""
	LLDBWrite LLDB_MEMORY & (dumplines * 16) & " -- " & sExpression
	LLDBWrite "vfbe_mem_end"
End Sub

Sub LLDBCommandDebug(sCom As String)
	If StartsWith(sCom, "print ") Then
		If WatchIndex >= 0 AndAlso WatchIndex < lvWatches.Nodes.Count Then
			Dim As String sType, sValue = DbgFindValue(Mid(sCom, 7), sType)
			lvWatches.Nodes.Item(WatchIndex)->Text(1) = IIf(DbgHasValue(Mid(sCom, 7)), DbgText(sValue), ML("No symbol in the current context"))
			lvWatches.Nodes.Item(WatchIndex)->Text(2) = sType
			DbgViewInvalidate
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

'Breakpoint of the editor while debugging: before the change of the line
Sub LLDBSetBp(Temporary As Boolean = False)
	If Not LLDBActive Then Exit Sub
	Dim As UString FileName
	Dim As Integer LineNo
	If Not DbgCursorPlace(FileName, LineNo) Then Exit Sub
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	Dim As UString Place = " -f " & DbgQuote(GetFileName(FileName)) & " -l " & WStr(LineNo)
	If Temporary Then
		LLDBWrite "breakpoint set -o true" & Place
	ElseIf Cast(EditControlLine Ptr, tb->txtCode.Content.Lines.Items[LineNo - 1])->Breakpoint Then
		LLDBWrite "breakpoint clear" & Place
	Else
		Dim As Integer nIgnore = DbgIgnoreCount(FileName, LineNo)
		Dim As String sCond = DbgBreakpointCondition(FileName, LineNo)
		LLDBWrite "breakpoint set" & IIf(nIgnore, " -i " & nIgnore, "") & IIf(sCond <> "", " -c '" & sCond & "'", "") & Place
	End If
End Sub

Sub LLDBRestart()
	If Not LLDBActive Then Exit Sub
	LLDBRestarting = True
	LLDBContinue LLDBLaunchCommand
End Sub

Sub LLDBBreak()
	If LLDBProgramPid > 0 AndAlso Running Then DbgInterruptProcess LLDBProgramPid
End Sub

Sub LLDBRunToCursor()
	Dim As UString FileName
	Dim As Integer LineNo
	If DbgCursorPlace(FileName, LineNo) Then LLDBWrite "breakpoint set -o true -f " & DbgQuote(GetFileName(FileName)) & " -l " & WStr(LineNo)
	LLDBContinueDebug
End Sub

Sub LLDBSetNextStatement()
	Dim As UString FileName
	Dim As Integer LineNo
	If DbgCursorPlace(FileName, LineNo) Then
		LLDBWrite "thread jump -f " & DbgQuote(GetFileName(FileName)) & " -l " & WStr(LineNo)
		LLDBWrite "bt"
		LLDBWrite "vfbe_bt_end"
	End If
End Sub

#ifdef __USE_COCOA__
	'macOS: lldb is the only debugger, the procedures of the debugger which the IDE calls are of lldb
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
		'lldb of the setting of Integrated LLDB Debugger, or of the GDB debugger if it is lldb, else lldb of Xcode
		Dim As UString LLDBPath = "lldb"
		If CurrentDebuggerType = IntegratedLLDBDebugger AndAlso WGet(IIf(Bit32, LLDBDebugger32Path, LLDBDebugger64Path)) <> "" Then
			LLDBPath = GetFullPath(WGet(IIf(Bit32, LLDBDebugger32Path, LLDBDebugger64Path)))
		ElseIf CurrentDebuggerType = IntegratedGDBDebugger Then
			Dim As WString Ptr GDBDebuggerPath = IIf(Bit32, GDBDebugger32Path, GDBDebugger64Path)
			If InStr(LCase(GetFileName(WGet(GDBDebuggerPath))), "lldb") > 0 Then LLDBPath = GetFullPath(WGet(GDBDebuggerPath))
		End If
		LLDBRunWithDebug ExeFile, Arguments, LLDBPath
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

	Sub continue_debug()
		LLDBContinueDebug
	End Sub

	Sub step_debug(s As String)
		LLDBStepDebug s
	End Sub

	Sub kill_debug()
		LLDBKillDebug
	End Sub

	Sub command_debug(sCom As String)
		LLDBCommandDebug sCom
	End Sub

	Function get_var_value(VarName As String, LineIndex As Integer) As String
		Return DbgFindValue(VarName)
	End Function

	Sub info_all_variables_debug(iFlagUpdate As Long = 0)
	End Sub

	Sub set_bp(Temporary As Boolean = False)
		LLDBSetBp Temporary
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
				LLDBRestart
			ElseIf SaveAllBeforeCompile Then
				ThreadCounter(ThreadCreate_(@CompileAndRun))
			End If
		Case "Break"
			LLDBBreak
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
				Case "RunToCursor": LLDBRunToCursor
				End Select
			ElseIf sCommand <> "StepOut" Then
				LLDBStopAtStart = sCommand <> "RunToCursor"
				RunningToCursor = sCommand = "RunToCursor"
				ChangeEnabledDebug False, True, True
				ThreadCounter(ThreadCreate_(@LLDBStart))
			End If
		Case "SetNextStatement"
			If LLDBActive AndAlso Not Running Then LLDBSetNextStatement
		Case "ShowVar", "AddWatch"
			DbgShowWord sCommand
		End Select
	End Sub
#endif
