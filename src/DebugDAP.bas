'#########################################################
'#  DebugDAP.bas                                         #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#########################################################

'The Debug Adapter Protocol: gdb --interpreter=dap (gdb 14+ with Python) and lldb-dap (lldb-vscode of the old
'versions of LLVM): Integrated GDB Debugger or Integrated LLDB Debugger with the interface DAP (Options).
'The messages are JSON after the header Content-Length: N. The IDE sends the requests (initialize, launch,
'setBreakpoints, configurationDone, continue, next, stackTrace, scopes, variables, evaluate, disconnect), the debugger
'answers them (response with request_seq) and sends the events (initialized, stopped, output, process, exited,
'terminated). After a stop the IDE asks the frames, the scopes of the first frame of the program and their variables
'(the fields of a structure are the variables of its variablesReference); the stop is shown after the last answer.

#include once "DebugCommon.bas"

Type DapRequestType
	Purpose As String
	lv As TreeListView Ptr
	Parent As TreeListViewItem Ptr
	Path As String
	Depth As Integer
	'readMemory of a WString Ptr: the index of its value in DbgValues
	ValueIndex As Integer
End Type

Dim Shared As DbgProcessType DapProcess
Dim Shared As Boolean DapRunning, DapIsLLDB, DapStopAtStart, DapInitialized, DapRestartRequested
'Step Into, Step Over before the start (lldb-dap): a breakpoint of main (its line is the first line of the main file)
Dim Shared As Boolean DapMainBreakpoint, DapDisconnecting
'Break of Windows stops the program in a new thread: the frames of the first thread (threads)
Dim Shared As Boolean DapMainThreadAsked
Dim Shared As Long DapProgramPid, DapSeq, DapThreadId, DapPending, DapExitCode
Dim Shared DapRequests(Any) As DapRequestType
Dim Shared DapFrameIds(Any) As Long
Dim Shared As UString DapExeFile, DapArguments
'A temporary breakpoint (Run To Cursor): it is removed after the stop
Dim Shared As UString DapTempFile
Dim Shared As Integer DapTempLine

'The values of JSON with their paths: body.stackFrames.0.source.path, the counts of the arrays at Path#
Declare Sub DapParseValue(ByRef s As String, ByRef i As Integer, ByRef Path As String, ByRef r As DbgRecord)

Private Sub DapSkipSpaces(ByRef s As String, ByRef i As Integer)
	While i <= Len(s) AndAlso InStr(!" \t\r\n", Mid(s, i, 1)) > 0
		i += 1
	Wend
End Sub

Function DapParseString(ByRef s As String, ByRef i As Integer) As String
	Dim As String Result
	i += 1
	Do While i <= Len(s)
		Dim As String c = Mid(s, i, 1)
		If c = """" Then
			i += 1
			Exit Do
		ElseIf c = "\" Then
			Dim As String e = Mid(s, i + 1, 1)
			Select Case e
			Case "n": Result &= Chr(10): i += 2
			Case "t": Result &= Chr(9): i += 2
			Case "r": Result &= Chr(13): i += 2
			Case "b": Result &= Chr(8): i += 2
			Case "f": Result &= Chr(12): i += 2
			Case "u"
				Dim As ULong Code = ValUInt("&H" & Mid(s, i + 2, 4))
				i += 6
				'A pair of UTF-16
				If Code >= &HD800 AndAlso Code <= &HDBFF AndAlso Mid(s, i, 2) = "\u" Then
					Dim As ULong Low = ValUInt("&H" & Mid(s, i + 2, 4))
					If Low >= &HDC00 AndAlso Low <= &HDFFF Then
						Code = &H10000 + ((Code - &HD800) Shl 10) + (Low - &HDC00)
						i += 6
					End If
				End If
				Result &= DbgUtf8Char(Code)
			Case Else: Result &= e: i += 2
			End Select
		Else
			Result &= c
			i += 1
		End If
	Loop
	Return Result
End Function

Sub DapParseValue(ByRef s As String, ByRef i As Integer, ByRef Path As String, ByRef r As DbgRecord)
	DapSkipSpaces s, i
	Dim As String c = Mid(s, i, 1)
	If c = """" Then
		r.Add Path, DapParseString(s, i)
	ElseIf c = "{" Then
		i += 1
		Do
			DapSkipSpaces s, i
			c = Mid(s, i, 1)
			If c = "}" OrElse i > Len(s) Then i += 1: Exit Do
			If c = "," Then i += 1: Continue Do
			Dim As String sKey = DapParseString(s, i)
			DapSkipSpaces s, i
			If Mid(s, i, 1) = ":" Then i += 1
			DapParseValue s, i, IIf(Path = "", sKey, Path & "." & sKey), r
		Loop
	ElseIf c = "[" Then
		i += 1
		Dim As Integer n
		Do
			DapSkipSpaces s, i
			c = Mid(s, i, 1)
			If c = "]" OrElse i > Len(s) Then i += 1: Exit Do
			If c = "," Then i += 1: Continue Do
			DapParseValue s, i, Path & "." & n, r
			n += 1
		Loop
		r.Add Path & "#", Str(n)
	Else
		'A number, true, false, null
		Dim As Integer iStart = i
		While i <= Len(s) AndAlso InStr(",}] " & Chr(9, 10, 13), Mid(s, i, 1)) = 0
			i += 1
		Wend
		r.Add Path, Mid(s, iStart, i - iStart)
	End If
End Sub

'A text in JSON
Function DapJson(ByRef s As String) As String
	Dim As String Result = """"
	For i As Integer = 1 To Len(s)
		Dim As UByte c = s[i - 1]
		Select Case c
		Case 34: Result &= "\"""
		Case 92: Result &= "\\"
		Case 10: Result &= "\n"
		Case 13: Result &= "\r"
		Case 9: Result &= "\t"
		Case Is < 32: Result &= "\u" & Right("000" & Hex(c), 4)
		Case Else: Result &= Chr(c)
		End Select
	Next
	Return Result & """"
End Function

Function DapJsonW(ByRef s As WString) As String
	Return DapJson(ToUtf8(s))
End Function

'A request: its arguments are a JSON object, its answer is of Purpose
Private Function DapSend(ByRef sRequest As String, ByRef Arguments As String = "{}", ByRef Purpose As String = "", lv As TreeListView Ptr = 0, Parent As TreeListViewItem Ptr = 0, ByRef Path As String = "", Depth As Integer = 0, ValueIndex As Integer = -1) As Long
	MutexLock DbgWriteMutex
	If DapRunning Then
		DapSeq += 1
		If DapSeq > UBound(DapRequests) Then ReDim Preserve DapRequests(DapSeq + 100)
		DapRequests(DapSeq).Purpose = IIf(Purpose = "", sRequest, Purpose)
		DapRequests(DapSeq).lv = lv
		DapRequests(DapSeq).Parent = Parent
		DapRequests(DapSeq).Path = Path
		DapRequests(DapSeq).Depth = Depth
		DapRequests(DapSeq).ValueIndex = ValueIndex
		Dim As String Body = "{""seq"":" & DapSeq & ",""type"":""request"",""command"":""" & sRequest & """,""arguments"":" & Arguments & "}"
		DbgWriteInput DapProcess, "Content-Length: " & Len(Body) & !"\r\n\r\n" & Body
		Function = DapSeq
	End If
	MutexUnlock DbgWriteMutex
End Function

Function DapActive() As Boolean
	Return DapRunning
End Function

Private Function DapThread() As String
	Return "{""threadId"":" & IIf(DapThreadId = 0, 1, DapThreadId) & "}"
End Function

'The breakpoints of a file: its lines and the line of Run To Cursor; Toggled: the line which changes now
Private Sub DapSetFileBreakpoints(ByRef FileName As WString, ByRef Lines As String, ByRef Purpose As String = "")
	Dim As String sBreakpoints
	Dim As WString Ptr Items()
	Split Lines, ",", Items()
	For j As Integer = 0 To UBound(Items)
		If *Items(j) <> "" Then
			'Breakpoint Hit Count: the stop on the N-th hit (hitCondition)
			Dim As Integer nCount = DbgBreakpointCount(FileName, Val(*Items(j)))
			Dim As String sCond = DbgBreakpointCondition(FileName, Val(*Items(j))), sCondArg
			If sCond <> "" Then sCondArg = ",""condition"":" & DapJson(sCond)
			sBreakpoints &= IIf(sBreakpoints = "", "", ",") & "{""line"":" & *Items(j) & IIf(nCount > 1, ",""hitCondition"":""" & nCount & """", "") & sCondArg & "}"
		End If
		_Deallocate(Items(j))
	Next
	Erase Items
	DapSend "setBreakpoints", "{""source"":{""path"":" & DapJsonW(Replace(FileName, "/", Slash)) & "},""breakpoints"":[" & sBreakpoints & "]}", Purpose
End Sub

'The lines of the breakpoints of a file of the editor
Private Function DapFileLines(ByRef FileName As WString) As String
	Dim As UString Files()
	Dim As String Lines()
	DbgBreakpoints Files(), Lines()
	For i As Integer = 0 To UBound(Files)
		If EqualPaths(Files(i), FileName) Then Return Lines(i)
	Next
	Return ""
End Function

Private Sub DapSendBreakpoints()
	Dim As UString Files()
	Dim As String Lines()
	DbgBreakpoints Files(), Lines()
	Dim As Boolean TempSent
	For i As Integer = 0 To UBound(Files)
		Dim As String sLines = Lines(i)
		If DapTempLine > 0 AndAlso EqualPaths(Files(i), DapTempFile) Then sLines &= "," & DapTempLine: TempSent = True
		DapSetFileBreakpoints Files(i), sLines, "breakpoints"
	Next
	If DapTempLine > 0 AndAlso Not TempSent Then DapSetFileBreakpoints DapTempFile, Str(DapTempLine), "breakpoints"
End Sub

Private Sub DapShowStop()
	DbgShowCaptions
	DbgShowFrames
	DbgUpdateWatches
	DbgShowCursor
	tpLocals->SelectTab
	Running = False
	ChangeEnabledDebug True, False, True
	If DapMainBreakpoint Then
		DapMainBreakpoint = False
		DapSend "setFunctionBreakpoints", "{""breakpoints"":[]}"
	End If
	'Run To Cursor: its breakpoint is removed
	If DapTempLine > 0 Then
		Dim As UString sFile = DapTempFile
		DapTempLine = 0
		DapSetFileBreakpoints sFile, DapFileLines(sFile), "breakpoints"
	End If
End Sub

Private Sub DapRequestDone()
	DapPending -= 1
	If DapPending <= 0 Then DapPending = 0: DapShowStop
End Sub

'The launch of the program after initialize
Private Sub DapLaunch()
	Dim As String sArgs
	Dim As String Args(Any)
	Dim As String sArguments = ToUtf8(DapArguments), sArg
	Dim As Boolean InQuotes
	For i As Integer = 1 To Len(sArguments) + 1
		Dim As String c = IIf(i > Len(sArguments), " ", Mid(sArguments, i, 1))
		If c = """" Then
			InQuotes = Not InQuotes
		ElseIf c = " " AndAlso Not InQuotes Then
			If sArg <> "" Then sArgs &= IIf(sArgs = "", "", ",") & DapJson(sArg)
			sArg = ""
		Else
			sArg &= c
		End If
	Next
	Dim As String sLaunch = "{""program"":" & DapJsonW(DapExeFile) & ",""args"":[" & sArgs & "],""cwd"":" & DapJsonW(GetFolderName(DapExeFile, False))
	If DapIsLLDB Then
		'The texts of String, the program stops at its start (Step Into, Step Over)
		sLaunch &= ",""stopOnEntry"":false,""initCommands"":[" & DapJson("type summary add -s ""${var.data%s}"" FBSTRING") & "]"
	Else
		If DapStopAtStart Then sLaunch &= ",""stopAtBeginningOfMainSubprogram"":true"
	End If
	sLaunch &= "}"
	If AttachPid <> 0 Then
		'Attach to Process
		DapSend "attach", "{""pid"":" & AttachPid & ",""program"":" & DapJsonW(DapExeFile) & "}", "launch"
		AttachPid = 0
	Else
		DapSend "launch", sLaunch
	End If
End Sub

Private Sub DapVariables(ByRef r As DbgRecord, ByRef Request As DapRequestType)
	Dim As Integer n = r.Count("body.variables")
	For i As Integer = 0 To n - 1
		Dim As String sPrefix = "body.variables." & i & "."
		Dim As String sName = r.Get(sPrefix & "name")
		If Request.Depth = 0 Then sName = DbgName(sName)
		If sName = "" Then Continue For
		Dim As String sValue = r.Get(sPrefix & "value"), sCType = r.Get(sPrefix & "type")
		Dim As String sType = DbgType(sCType, sValue)
		'lldb-dap: the value of a structure is the name of its type, its fields are its children
		If sValue = sCType AndAlso sValue <> "" Then sValue = "{...}"
		Dim As String sPath = IIf(Request.Depth = 0, sName, Request.Path & IIf(Left(sName, 1) = "[", "", ".") & sName)
		Dim As TreeListViewItem Ptr Item = DbgAddVariable(Request.lv, Request.Parent, sPath, sName, sValue, sType)
		Dim As Long Reference = Val(r.Get(sPrefix & "variablesReference"))
		Dim As String sAddress = DbgPointerAddress(sValue)
		If CBool(Item <> 0) AndAlso CBool(sAddress <> "") AndAlso DbgIsWideCType(sCType) Then
			'The text of a WString Ptr (ByRef WString): the debugger shows only its address
			'Its address (memoryReference of lldb-dap is the address of the pointer, not of the characters)
			Dim As String sReference = sAddress
			DapPending += 1
			DapSend "readMemory", "{""memoryReference"":" & DapJson(sReference) & ",""count"":512}", "readMemory", Request.lv, Item, sPath, Request.Depth, UBound(DbgValues)
		ElseIf Item <> 0 AndAlso Reference > 0 AndAlso Request.Depth < 3 AndAlso sType <> "String" AndAlso sType <> "ZString Ptr" Then
			DapPending += 1
			DapSend "variables", "{""variablesReference"":" & Reference & "}", "variables", Request.lv, Item, sPath, Request.Depth + 1
		ElseIf Item <> 0 AndAlso sType <> "String" Then
			DbgAddValueChildren Request.lv, Item, sPath, sValue
		End If
	Next
End Sub

'A message of the debugger
Private Sub DapMessage(ByRef Json As String)
	Dim As DbgRecord r
	Dim As Integer i = 1
	DapParseValue Json, i, "", r
	Dim As String sType = r.Get("type")
	If sType = "event" Then
		Select Case r.Get("event")
		Case "initialized"
			DapInitialized = True
			DapSendBreakpoints
			If DapStopAtStart AndAlso DapIsLLDB Then
				DapMainBreakpoint = True
				DapSend "setFunctionBreakpoints", "{""breakpoints"":[{""name"":""main""}]}"
			End If
			DapStopAtStart = False
			DapSend "configurationDone"
		Case "process"
			DapProgramPid = Val(r.Get("body.systemProcessId"))
			ShowMessages Time & ": " & ML("Run") & ": " & DbgText(r.Get("body.name")) & IIf(DapProgramPid > 0, " (" & DapProgramPid & ")", ""), False
		Case "output"
			Dim As String sCategory = r.Get("body.category")
			If sCategory = "stdout" OrElse sCategory = "stderr" OrElse sCategory = "important" OrElse sCategory = "" Then
				DbgShowText r.Get("body.output")
			End If
		Case "stopped"
			DapMainThreadAsked = False
			If r.Has("body.threadId") Then DapThreadId = Val(r.Get("body.threadId"))
			DapSend "stackTrace", "{""threadId"":" & IIf(DapThreadId = 0, 1, DapThreadId) & ",""levels"":30}"
		Case "continued"
			Running = True
		Case "exited"
			DapExitCode = Val(r.Get("body.exitCode"))
			ShowMessages Time & ": " & ML("Application finished. Returned code") & ": " & DapExitCode & " - " & Err2Description(DapExitCode)
		Case "terminated"
			DapProgramPid = 0
			DeleteDebugCursor
			DapSend "disconnect", "{""terminateDebuggee"":true}"
		End Select
		Exit Sub
	End If
	If sType <> "response" Then Exit Sub
	Dim As Long RequestSeq = Val(r.Get("request_seq"))
	Dim As DapRequestType Request
	If RequestSeq > 0 AndAlso RequestSeq <= UBound(DapRequests) Then Request = DapRequests(RequestSeq)
	If r.Get("success") <> "true" Then
		Dim As String sMessage = r.Get("body.error.format")
		If sMessage = "" Then sMessage = r.Get("message")
		Select Case Request.Purpose
		Case "variables", "scopes", "readMemory"
			DapRequestDone
		Case "stackTrace"
			DapPending = 0
			DapShowStop
		Case "evaluate"
			ShowMessages DbgText(sMessage), False
		Case Else
			ShowMessages IIf(DapIsLLDB, "lldb-dap: ", "gdb: ") & Request.Purpose & ": " & DbgText(sMessage), False
			If Request.Purpose = "launch" OrElse Request.Purpose = "initialize" Then DapSend "disconnect", "{""terminateDebuggee"":true}"
		End Select
		Exit Sub
	End If
	Select Case Request.Purpose
	Case "disconnect"
		'The end of the input ends the debugger (lldb-dap)
		MutexLock DbgWriteMutex
		DbgCloseInput DapProcess
		MutexUnlock DbgWriteMutex
	Case "initialize"
		DapLaunch
	Case "stackTrace"
		Erase DbgFrames, DapFrameIds
		Dim As Integer n = r.Count("body.stackFrames")
		If n > 0 Then ReDim DbgFrames(n - 1), DapFrameIds(n - 1)
		For k As Integer = 0 To n - 1
			Dim As String sPrefix = "body.stackFrames." & k & "."
			DbgFrames(k).Func = r.Get(sPrefix & "name")
			DbgFrames(k).File = r.Get(sPrefix & "source.path")
			DbgFrames(k).LineNo = Val(r.Get(sPrefix & "line"))
			DapFrameIds(k) = Val(r.Get(sPrefix & "id"))
		Next
		DbgFrameIndex = DbgProgramFrame
		DbgClearVariables
		DbgViewDataChanging
		lvLocals.Nodes.Clear
		lvGlobals.Nodes.Clear
		If DbgFrameIndex < 0 AndAlso Not DapMainThreadAsked Then
			DapMainThreadAsked = True
			DapSend "threads"
		ElseIf DbgFrameIndex < 0 Then
			DapShowStop
		Else
			DapPending = 1
			DapSend "scopes", "{""frameId"":" & DapFrameIds(DbgFrameIndex) & "}"
		End If
	Case "scopes"
		Dim As Integer n = r.Count("body.scopes")
		For k As Integer = 0 To n - 1
			Dim As String sName = LCase(r.Get("body.scopes." & k & ".name"))
			Dim As Long Reference = Val(r.Get("body.scopes." & k & ".variablesReference"))
			If Reference <= 0 OrElse InStr(sName, "register") > 0 Then Continue For
			Dim As TreeListView Ptr lv = IIf(InStr(sName, "global") > 0 OrElse InStr(sName, "static") > 0, @lvGlobals, @lvLocals)
			DapPending += 1
			DapSend "variables", "{""variablesReference"":" & Reference & "}", "variables", lv, 0, "", 0
		Next
		DapRequestDone
	Case "variables"
		DapVariables r, Request
		DapRequestDone
	Case "readMemory"
		If Request.Parent <> 0 AndAlso Request.ValueIndex >= 0 AndAlso Request.ValueIndex <= UBound(DbgValues) Then
			Dim As String sValue = DbgPointerAddress(DbgValues(Request.ValueIndex)) & " " & DbgWideText(DbgBase64Bytes(r.Get("body.data")))
			DbgValues(Request.ValueIndex) = sValue
			Request.Parent->Text(1) = DbgText(sValue)
		End If
		DapRequestDone
	Case "threads"
		'The first thread: the thread with the smallest number of its name (Thread 1)
		Dim As Integer n = r.Count("body.threads"), Best = -1, BestNumber
		For k As Integer = 0 To n - 1
			Dim As String sName = r.Get("body.threads." & k & ".name")
			Dim As Integer Number = Val(Mid(sName, InStrRev(sName, " ") + 1))
			If Number > 0 AndAlso (Best = -1 OrElse Number < BestNumber) Then Best = k: BestNumber = Number
		Next
		If Best = -1 AndAlso n > 0 Then Best = 0
		If Best >= 0 Then
			DapThreadId = Val(r.Get("body.threads." & Best & ".id"))
			DapSend "stackTrace", "{""threadId"":" & DapThreadId & ",""levels"":30}"
		Else
			DapShowStop
		End If
	Case "evaluate"
		DbgShowText r.Get("body.result")
	Case "dumpaddr"
		'Variable Dump: the address of the variable, then its memory
		Dim As String sReference = r.Get("body.memoryReference")
		If sReference = "" Then
			Dim As String sResult = r.Get("body.result")
			Dim As Integer p = InStr(LCase(sResult), "0x")
			If p > 0 Then
				Dim As Integer e = p + 2
				While e <= Len(sResult) AndAlso InStr("0123456789abcdefABCDEF", Mid(sResult, e, 1)) > 0
					e += 1
				Wend
				sReference = Mid(sResult, p, e - p)
			End If
		End If
		If sReference = "" Then
			ShowMessages ML("The memory is not read") & ": " & DbgText(r.Get("body.result")), False
		Else
			DapSend "readMemory", "{""memoryReference"":" & DapJson(sReference) & ",""count"":" & (dumplines * 16) & "}", "dump"
		End If
	Case "dump"
		mem_show r.Get("body.address"), DbgBase64Bytes(r.Get("body.data"))
	Case "gotoTargets"
		If r.Count("body.targets") > 0 Then
			DeleteDebugCursor
			Running = True
			DapSend "goto", "{""threadId"":" & IIf(DapThreadId = 0, 1, DapThreadId) & ",""targetId"":" & r.Get("body.targets.0.id") & "}"
		Else
			ShowMessages ML("The line has no code."), False
		End If
	End Select
End Sub

Private Sub DapShowLog(ByRef sText As String)
	ShowMessages DbgText(sText), False
End Sub

'The messages of the debugger up to its end: Content-Length: N, an empty line, N bytes of JSON; other texts (the
'errors of gdb) go to the Output
Private Sub DapReadMessages()
	Dim As ZString * 8193 Buff
	Dim As String Pending
	Do
		Dim As Integer n = DbgReadOutput(DapProcess, @Buff, 8192)
		If n <= 0 Then Exit Do
		Buff[n] = 0
		Pending &= Left(Buff, n)
		Do
			Dim As Integer p = InStr(Pending, "Content-Length:")
			If p = 0 Then
				'A text without a message: up to its last line
				Dim As Integer q = InStrRev(Pending, Chr(10))
				If q > 0 Then
					Dim As String sText = RTrim(Left(Pending, q - 1), Chr(13))
					DbgCallInUIThread @DapShowLog, sText
					Pending = Mid(Pending, q + 1)
				End If
				Exit Do
			End If
			If p > 1 Then
				Dim As String sText = Trim(Left(Pending, p - 1), Any !"\r\n ")
				If sText <> "" Then DbgCallInUIThread @DapShowLog, sText
				Pending = Mid(Pending, p)
			End If
			Dim As Integer h = InStr(Pending, !"\r\n\r\n")
			If h = 0 Then Exit Do
			Dim As Integer Size = Val(Mid(Pending, 16, h - 16))
			If Len(Pending) < h + 3 + Size Then Exit Do
			Dim As String Json = Mid(Pending, h + 4, Size)
			Pending = Mid(Pending, h + 4 + Size)
			DbgCallInUIThread @DapMessage, Json
		Loop
	Loop
End Sub

'gdb or lldb-dap debugs the program: this thread reads the messages up to the end of the debugger
Sub DapRunWithDebug(ByRef ExeFile As WString, ByRef Arguments As WString, ByRef DebuggerPath As WString, IsLLDB As Boolean)
	If DapActive Then Exit Sub
	DapIsLLDB = IsLLDB
	Dim As UString sProgram = DebuggerPath, sArguments = "--interpreter=dap -q --nx", sPythonHome
	If IsLLDB Then
		sProgram = DbgLLDBTool(DebuggerPath, "lldb-dap", "lldb-vscode")
		sArguments = ""
		sPythonHome = DbgPythonHome(DebuggerPath)
	End If
	Do
		DapRestartRequested = False
		If Not DbgStart(DapProcess, sProgram, sArguments, sPythonHome) Then
			ThreadsEnter
			ShowMessages ML("File not found") & ": " & sProgram
			ChangeEnabledDebug True, False, False
			ThreadsLeave
			Exit Sub
		End If
		ThreadsEnter
		MutexLock DbgWriteMutex
		DapRunning = True
		DapSeq = 0
		Erase DapRequests
		MutexUnlock DbgWriteMutex
		DbgBackend = DbgDAP
		DapExeFile = ExeFile
		DapArguments = Arguments
		DapProgramPid = 0
		DapThreadId = 0
		DapPending = 0
		DapInitialized = False
		DapDisconnecting = False
		Erase DbgFrames
		DbgClearVariables
		DapTempLine = 0
		If RunningToCursor Then
			RunningToCursor = False
			Dim As UString CursorFile
			Dim As Integer CursorLine
			If DbgCursorPlace(CursorFile, CursorLine) Then DapTempFile = CursorFile: DapTempLine = CursorLine
		End If
		Running = True
		DbgViewDataChanging
		lvLocals.Nodes.Clear
		lvGlobals.Nodes.Clear
		ChangeEnabledDebug False, True, True
		ShowMessages Time & ": " & ML("Run") & ": " & sProgram & " " & sArguments & " " & ExeFile & " ...", False
		DapSend "initialize", "{""clientID"":""vfbe"",""clientName"":""VisualFBEditor"",""adapterID"":""" & IIf(IsLLDB, "lldb-dap", "gdb") & """,""linesStartAt1"":true,""columnsStartAt1"":true,""pathFormat"":""path"",""supportsVariableType"":true,""supportsRunInTerminalRequest"":false}"
		ThreadsLeave
		DapReadMessages
		MutexLock DbgWriteMutex
		DapRunning = False
		MutexUnlock DbgWriteMutex
		DbgFinish DapProcess
		ThreadsEnter
		If DapProgramPid > 0 Then DbgKillProcess DapProgramPid
		DapProgramPid = 0
		DbgBackend = DbgNone
		Running = False
		DeleteDebugCursor
		If Not DapRestartRequested Then
			ShowMessages Time & ": " & ML("Debugging finished."), False
			ChangeEnabledDebug True, False, False
		End If
		ThreadsLeave
	Loop While DapRestartRequested
	DapStopAtStart = False
	DapMainBreakpoint = False
End Sub

Private Sub DapContinue(ByRef sRequest As String)
	If Not DapActive Then Exit Sub
	DeleteDebugCursor
	Running = True
	ChangeEnabledDebug False, True, True
	DapSend sRequest, DapThread
End Sub

Sub DapContinueDebug()
	DapContinue "continue"
End Sub

Sub DapStepDebug(s As String)
	Select Case s
	Case "s": DapContinue "stepIn"
	Case "n": DapContinue "next"
	Case "o": DapContinue "stepOut"
	End Select
End Sub

Sub DapRunToCursor()
	Dim As UString FileName
	Dim As Integer LineNo
	If DbgCursorPlace(FileName, LineNo) Then
		DapTempFile = FileName
		DapTempLine = LineNo
		DapSetFileBreakpoints FileName, DapFileLines(FileName) & "," & LineNo, "breakpoints"
	End If
	DapContinueDebug
End Sub

'goto: the next line of the program, if the debugger can it (lldb-dap)
Sub DapSetNextStatement()
	Dim As UString FileName
	Dim As Integer LineNo
	If Not DbgCursorPlace(FileName, LineNo) Then Exit Sub
	DapSend "gotoTargets", "{""source"":{""path"":" & DapJsonW(FileName) & "},""line"":" & LineNo & "}"
End Sub

Sub DapBreak()
	If Not DapActive OrElse Not Running Then Exit Sub
	DapSend "pause", DapThread
End Sub

Sub DapEnd()
	If Not DapActive Then Exit Sub
	If DapDisconnecting Then
		'The debugger does not end: End again ends it
		DbgKillProcess DapProgramPid
		DbgKillProcess DapProcess.Pid
		Exit Sub
	End If
	DapDisconnecting = True
	DapSend "disconnect", "{""terminateDebuggee"":true}"
End Sub

Sub DapRestart()
	If Not DapActive Then Exit Sub
	'The debugger ends and starts again with the program (DapRunWithDebug)
	DapRestartRequested = True
	DeleteDebugCursor
	Running = True
	ChangeEnabledDebug False, True, True
	DapSend "disconnect", "{""terminateDebuggee"":true}"
End Sub

'The command of the GDB sRequest window: evaluate in the console of the debugger
'Variable Dump, Pointed data Dump: the address of sExpression (evaluate), then readMemory
Sub DapMemoryDump(ByRef sExpression As String)
	Dim As String sFrame
	If DbgFrameIndex >= 0 AndAlso DbgFrameIndex <= UBound(DapFrameIds) Then sFrame = ",""frameId"":" & DapFrameIds(DbgFrameIndex)
	DapSend "evaluate", "{""expression"":" & DapJson(sExpression) & ",""context"":""watch""" & sFrame & "}", "dumpaddr"
End Sub

Sub DapCommandDebug(ByRef sCom As String)
	If Not DapActive Then
		ShowMessages ML("The debugger is not started.")
		Exit Sub
	End If
	If Trim(sCom) = "" Then Exit Sub
	ShowMessages "(" & IIf(DapIsLLDB, "lldb", "gdb") & ") " & DbgText(Trim(sCom)), False
	Dim As String sFrame
	If DbgFrameIndex >= 0 AndAlso DbgFrameIndex <= UBound(DapFrameIds) Then sFrame = ",""frameId"":" & DapFrameIds(DbgFrameIndex)
	DapSend "evaluate", "{""expression"":" & DapJson(Trim(sCom)) & ",""context"":""repl""" & sFrame & "}"
End Sub

'Breakpoint of the editor while debugging: before the change of the line, all breakpoints of the file are sent
Sub DapSetBp()
	If Not DapActive Then Exit Sub
	Dim As UString FileName
	Dim As Integer LineNo
	If Not DbgCursorPlace(FileName, LineNo) Then Exit Sub
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	Dim As String sLines = "," & DapFileLines(FileName) & ",", sNew
	If Cast(EditControlLine Ptr, tb->txtCode.Content.Lines.Items[LineNo - 1])->Breakpoint Then
		sNew = Replace(sLines, "," & LineNo & ",", ",")
	Else
		sNew = sLines & LineNo & ","
	End If
	sNew = Trim(sNew, ",")
	While InStr(sNew, ",,") > 0
		sNew = Replace(sNew, ",,", ",")
	Wend
	DapSetFileBreakpoints FileName, sNew, "breakpoints"
End Sub
