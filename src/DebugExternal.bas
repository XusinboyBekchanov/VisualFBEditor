'#########################################################
'#  DebugExternal.bas                                    #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#########################################################

'Windows and Linux: the integrated debuggers which are other processes, besides Integrated IDE Debugger and the
'commands of gdb of Debug.bas (Integrated GDB Debugger with the interface CLI):
'Integrated LLDB Debugger with CLI (DebugLLDB.bas), Integrated GDB Debugger and Integrated LLDB Debugger with MI
'(DebugMI.bas) and with DAP (DebugDAP.bas). The interfaces are the settings GDB Interface and LLDB Interface (Options).
'The commands of the IDE (mClick of VisualFBEditor.bas) come here first (DbgCommand).

#include once "DebugCommon.bas"
#include once "DebugLLDB.bas"
#include once "DebugMI.bas"
#include once "DebugDAP.bas"

Function DbgSelectedBackend() As DbgBackends
	Dim As DebuggerTypes DebuggerType = IIf(tbt32Bit->Checked, CurrentDebuggerType32, CurrentDebuggerType64)
	If DebuggerType = IntegratedLLDBDebugger Then
		Select Case LLDBInterface
		Case DebuggerMI: Return DbgMI
		Case DebuggerDAP: Return DbgDAP
		Case Else: Return DbgLLDBCLI
		End Select
	ElseIf DebuggerType = IntegratedGDBDebugger Then
		Select Case GDBInterface
		Case DebuggerMI: Return DbgMI
		Case DebuggerDAP: Return DbgDAP
		End Select
	End If
	Return DbgNone
End Function

Function DbgActive() As Boolean
	Return DbgBackend <> DbgNone
End Function

'The start of the debugger in the thread of RunWithDebug, it waits for its end
Function DbgRunWithDebug(ByRef ExeFile As WString, ByRef Arguments As WString, ByRef CompileLine As WString) As Boolean
	Dim As DbgBackends Backend = DbgSelectedBackend
	If Backend = DbgNone Then Return False
	Dim As Boolean IsLLDB = IIf(tbt32Bit->Checked, CurrentDebuggerType32, CurrentDebuggerType64) = IntegratedLLDBDebugger
	ThreadsEnter
	If Not FileExists(ExeFile) Then
		ShowMessages ML("File not found") & ": " & ExeFile
		ChangeEnabledDebug True, False, False
		ThreadsLeave
		Return True
	End If
	DbgCheckCompileLine CompileLine
	DbgViewSetDebugger False
	tpLocals->SelectTab
	ThreadsLeave
	Dim As UString DebuggerPath = DbgDebuggerPath(IsLLDB)
	Select Case Backend
	Case DbgLLDBCLI: LLDBRunWithDebug ExeFile, Arguments, DebuggerPath
	Case DbgMI: GdbMiRunWithDebug ExeFile, Arguments, DebuggerPath, IsLLDB
	Case DbgDAP: DapRunWithDebug ExeFile, Arguments, DebuggerPath, IsLLDB
	End Select
	Return True
End Function

Private Sub DbgStartThread(Param As Any Ptr)
	RunProgramWithDebug(0)
End Sub

Private Sub DbgStartWithCompileThread(Param As Any Ptr)
	If Compile("RunWithDebug") = 0 Then ThreadsEnter: ChangeEnabledDebug True, False, False: ThreadsLeave
End Sub

Sub DbgContinue()
	Select Case DbgBackend
	Case DbgLLDBCLI: LLDBContinueDebug
	Case DbgMI: GdbMiContinueDebug
	Case DbgDAP: DapContinueDebug
	End Select
End Sub

Sub DbgStep(ByRef s As String)
	Select Case DbgBackend
	Case DbgLLDBCLI: LLDBStepDebug s
	Case DbgMI: GdbMiStepDebug s
	Case DbgDAP: DapStepDebug s
	End Select
End Sub

Sub DbgEnd()
	Select Case DbgBackend
	Case DbgLLDBCLI: LLDBKillDebug
	Case DbgMI: GdbMiEnd
	Case DbgDAP: DapEnd
	End Select
End Sub

'The commands of the GDB Command window and "print X" of Watches
Sub DbgCommandDebug(ByRef sCom As String)
	If StartsWith(sCom, "print ") Then
		If WatchIndex >= 0 AndAlso WatchIndex < lvWatches.Nodes.Count Then
			Dim As String sName = Mid(sCom, 7), sType, sValue = DbgFindValue(sName, sType)
			lvWatches.Nodes.Item(WatchIndex)->Text(1) = IIf(DbgHasValue(sName), DbgText(sValue), ML("No symbol in the current context"))
			lvWatches.Nodes.Item(WatchIndex)->Text(2) = sType
			DbgViewInvalidate
		End If
		Exit Sub
	End If
	Select Case DbgBackend
	Case DbgLLDBCLI: LLDBCommandDebug sCom
	Case DbgMI: GdbMiCommandDebug sCom
	Case DbgDAP: DapCommandDebug sCom
	End Select
End Sub

'Breakpoint of the editor while debugging: before the change of the line
Sub DbgSetBp()
	Select Case DbgBackend
	Case DbgLLDBCLI: LLDBSetBp
	Case DbgMI: GdbMiSetBp
	Case DbgDAP: DapSetBp
	End Select
End Sub

'A command of the IDE: True if it is of these debuggers
Function DbgCommand(ByRef sCommand As String) As Boolean
	Select Case sCommand
	Case "StartWithCompile", "Start", "Restart", "Break", "End", "StepInto", "StepOver", "StepOut", "RunToCursor", "SetNextStatement", "ShowVar", "AddWatch", _
		"VariableDump", "PointedDataDump", "MemoryDumpWatch"
	Case Else: Return False
	End Select
	If DbgBackend = DbgNone AndAlso DbgSelectedBackend = DbgNone Then Return False
	Dim As Boolean bActive = DbgBackend <> DbgNone
	Select Case sCommand
	Case "StartWithCompile", "Start"
		If bActive Then
			If Not Running Then DbgContinue
			Return True
		End If
		'Without Use Debugger the program runs without the debugger (the code of VisualFBEditor.bas)
		If Not UseDebugger Then Return False
		DbgViewDataChanging
		lvThreads.Nodes.Clear
		If sCommand = "StartWithCompile" Then
			If SaveAllBeforeCompile Then
				ChangeEnabledDebug False, True, True
				ThreadCounter(ThreadCreate_(@DbgStartWithCompileThread))
			End If
		Else
			ChangeEnabledDebug False, True, True
			ThreadCounter(ThreadCreate_(@DbgStartThread))
		End If
	Case "Restart"
		If Not bActive Then Return False
		Select Case DbgBackend
		Case DbgLLDBCLI: LLDBRestart
		Case DbgMI: GdbMiRestart
		Case DbgDAP: DapRestart
		End Select
	Case "Break"
		If Not bActive Then Return False
		Select Case DbgBackend
		Case DbgLLDBCLI: LLDBBreak
		Case DbgMI: GdbMiBreak
		Case DbgDAP: DapBreak
		End Select
	Case "End"
		'A compilation in progress: the code of VisualFBEditor.bas ends it
		If CompileRunning OrElse Not bActive Then Return False
		DbgEnd
	Case "StepInto", "StepOver", "StepOut", "RunToCursor"
		If bActive Then
			If Running Then Return True
			Select Case sCommand
			Case "StepInto": DbgStep "s"
			Case "StepOver": DbgStep "n"
			Case "StepOut": DbgStep "o"
			Case "RunToCursor"
				Select Case DbgBackend
				Case DbgLLDBCLI: LLDBRunToCursor
				Case DbgMI: GdbMiRunToCursor
				Case DbgDAP: DapRunToCursor
				End Select
			End Select
		ElseIf sCommand <> "StepOut" Then
			'The start of the program: it stops at its first line or at the line of the cursor
			Dim As Boolean StopAtStart = sCommand <> "RunToCursor"
			LLDBStopAtStart = StopAtStart
			GdbMiStopAtStart = StopAtStart
			DapStopAtStart = StopAtStart
			RunningToCursor = sCommand = "RunToCursor"
			DbgViewDataChanging
			lvThreads.Nodes.Clear
			ChangeEnabledDebug False, True, True
			ThreadCounter(ThreadCreate_(@DbgStartThread))
		End If
	Case "SetNextStatement"
		If Not bActive Then Return False
		If Not Running Then
			Select Case DbgBackend
			Case DbgLLDBCLI: LLDBSetNextStatement
			Case DbgMI: GdbMiSetNextStatement
			Case DbgDAP: DapSetNextStatement
			End Select
		End If
	Case "ShowVar", "AddWatch"
		If Not bActive Then Return False
		DbgShowWord sCommand
	Case "VariableDump", "PointedDataDump", "MemoryDumpWatch"
		'The memory of the selected variable in the Memory window (mem_show of Debug.bas)
		If Not bActive Then Return False
		If Running Then Return True
		Dim As String sExpression = mem_expression(sCommand)
		If sExpression = "" Then ShowMessages ML("Select a variable"): Return True
		Select Case DbgBackend
		Case DbgLLDBCLI: LLDBMemoryDump sExpression
		Case DbgMI: GdbMiMemoryDump sExpression
		Case DbgDAP: DapMemoryDump sExpression
		End Select
	End Select
	Return True
End Function
