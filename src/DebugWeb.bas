'#########################################################
'#  DebugWeb.bas                                         #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#########################################################

'Web and Android: the program has no other processes to debug (Debug.bas reads and writes their memory).
'The procedures of the debugger which the IDE calls do nothing here; RunWithDebug says that debugging is not available.
'The variables of Debug.bas which the IDE uses keep their names.

Enum DebuggerTypes
	IntegratedIDEDebugger
	IntegratedGDBDebugger
	CustomDebugger
End Enum

Dim Shared As DebuggerTypes DefaultDebuggerType32, DefaultDebuggerType64, CurrentDebuggerType32, CurrentDebuggerType64
Dim Shared As String  source(SRCMAX)
Dim Shared As String  srcname(SRCMAX)
Dim Shared As Integer sourcenb = -1
Dim Shared shwtab As UShort = 0
Dim Shared dbghand As Any Ptr
Dim Shared As Boolean prun = False
Dim Shared exename As WString * 300
Dim Shared mainfolder As WString * 300
Dim Shared As Long iCounterUpdateVariables, iFlagStartDebug, iStateMenu = 1
Dim Shared As Integer iPosStartLast, iPosEndLast, iCurselLast, TimerID, WatchIndex
Dim Shared As String CurrentFile, NewCommand
Dim Shared As Boolean Running, ShowResult

Sub RunWithDebug(Debugger As String = "", ByRef ProjectFileName As WString, ByRef ProjectCommandLineArguments As WString, ByRef MainFile As WString, ByRef CompileLine As WString, ByRef FirstLine As WString)
	MsgBox ML("Debugging is not available on this platform.")
End Sub

Sub RunProgramWithDebug(Param As Any Ptr)
End Sub

Sub DeleteDebugCursor
End Sub

Function WriteProcessMemory(child As Long, addrdbge As Any Ptr, addrdbgr As Any Ptr, lg As Long, rd As Any Ptr = 0) As Integer
	Return 0
End Function

Sub brk_set(t As Integer)
End Sub

Sub exe_mod()
End Sub

Sub exec_order(order As Integer)
End Sub

Sub fastrun()
End Sub

Function kill_process(text As String) As Integer
	Return 0
End Function

Function proc_find(thid As Integer, t As Byte) As Integer
	Return 0
End Function

Sub proc_sh()
End Sub

Sub set_cc()
End Sub

Sub shwexp_new(tview As Any Ptr)
End Sub

Sub string_sh(tv As Any Ptr)
End Sub

Sub thread_resume(thd As Integer = -1)
End Sub

Sub thread_rsm()
End Sub

Sub var_tip(ope As Integer)
End Sub

Sub UpdateItems(root As Any Ptr)
End Sub

Sub command_debug(sCom As String)
End Sub

Sub continue_debug()
End Sub

Function get_var_value(VarName As String, LineIndex As Integer) As String
	Return ""
End Function

Sub info_all_variables_debug(iFlagUpdate As Long = 0)
End Sub

Sub kill_debug()
End Sub

Sub proc_enable()
End Sub

Sub proc_loc()
End Sub

Sub set_bp(Temporary As Boolean = False)
End Sub

Sub step_debug(s As String)
End Sub

Sub thread_set()
End Sub

Sub var_dump(tv As Any Ptr, ptd As Long = 0)
End Sub
