'#########################################################
'#  DebugMac.bi                                          #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#########################################################

'macOS (x86_64, arm64): the Integrated IDE Debugger of Linux (Debug.bas) with the Mach calls.
'The program is started with ptrace(PT_TRACE_ME) and without ASLR (its addresses are the ones of its file, of .dbgdat),
'its stops are read with waitpid as on Linux. ptrace of macOS has no PEEK/POKE/GETREGS: ptrace() below makes the
'requests of Linux with the task of the program (task_for_pid): mach_vm_read/write for the memory, thread_get/set_state
'for the registers. A thread is its Mach port (thread().id), the first thread is the pid (thread(0).id = debugpid).
'macOS stops all the threads at a stop and continues them together (PT_CONTINUE): the continue of the other threads
'does nothing. A single step is the flag TF of the thread (the trap is SIGTRAP), waitpid finds the thread of a stop.
'task_for_pid needs the entitlement com.apple.security.cs.debugger of the IDE (codesign, mff/Cocoa/build.sh) and the
'Developer Mode of macOS (DevToolsSecurity -enable).
'arm64 (the IDE built for arm64 debugs the programs of arm64, -gen gcc -g: DebugDwarf.bas): Debug.bas works as on x86,
'the differences are here. A breakpoint of Debug.bas is the byte CC written at the address of a line: here it is the
'instruction BRK #0 (4 bytes) and the memory read by Debug.bas shows CC and the 3 other bytes of the instruction, so
'that the bytes saved and restored by Debug.bas are the ones of x86. After a BRK pc is at the BRK (x86: after the CC):
'the registers give pc + 1 for the thread stopped at a BRK, a pc set by Debug.bas is aligned to 4. A single step is the
'flag SS of MDSCR_EL1 (ARM_DEBUG_STATE64) instead of TF. The frame record {fp, lr} is at x29 like {rbp, return
'address} at rbp: the walk of the stack is the same.

Extern "C"
	Declare Function dbgmac_task_self Alias "mach_task_self" () As ULong 'the port of the IDE (mach_task_self_ is a variable of a dylib)
	Declare Function dbgmac_task_for_pid Alias "task_for_pid" (ByVal target As ULong, ByVal pid As Long, ByVal t As ULong Ptr) As Long
	Declare Function dbgmac_vm_read Alias "mach_vm_read_overwrite" (ByVal task As ULong, ByVal adr As ULongInt, ByVal size As ULongInt, ByVal dta As ULongInt, ByVal outsize As ULongInt Ptr) As Long
	Declare Function dbgmac_vm_write Alias "mach_vm_write" (ByVal task As ULong, ByVal adr As ULongInt, ByVal dta As Any Ptr, ByVal cnt As ULong) As Long
	Declare Function dbgmac_vm_protect Alias "mach_vm_protect" (ByVal task As ULong, ByVal adr As ULongInt, ByVal size As ULongInt, ByVal setmax As Long, ByVal prot As Long) As Long
	Declare Function dbgmac_vm_deallocate Alias "mach_vm_deallocate" (ByVal task As ULong, ByVal adr As ULongInt, ByVal size As ULongInt) As Long
	Declare Function dbgmac_port_deallocate Alias "mach_port_deallocate" (ByVal task As ULong, ByVal port As ULong) As Long
	Declare Function dbgmac_task_threads Alias "task_threads" (ByVal task As ULong, ByVal list As ULong Ptr Ptr, ByVal cnt As ULong Ptr) As Long
	Declare Function dbgmac_thread_get_state Alias "thread_get_state" (ByVal th As ULong, ByVal flavor As Long, ByVal state As Any Ptr, ByVal cnt As ULong Ptr) As Long
	Declare Function dbgmac_thread_set_state Alias "thread_set_state" (ByVal th As ULong, ByVal flavor As Long, ByVal state As Any Ptr, ByVal cnt As ULong) As Long
	Declare Function dbgmac_ptrace Alias "ptrace" (ByVal request As Long, ByVal pid As Long, ByVal addr As Any Ptr, ByVal dta As Long) As Long
	Declare Function dbgmac_waitpid Alias "waitpid" (ByVal pid As Long, ByVal status As Any Ptr, ByVal options As Long) As Long 'the C type of waitpid of Debug.bas (gcc)
	Declare Function dbgmac_fork Alias "fork" () As Long
	Declare Function dbgmac_exit Alias "_exit" (ByVal code As Long) As Long
	Declare Function dbgmac_spawnattr_init Alias "posix_spawnattr_init" (ByVal attr As Any Ptr Ptr) As Long
	Declare Function dbgmac_spawnattr_setflags Alias "posix_spawnattr_setflags" (ByVal attr As Any Ptr Ptr, ByVal flags As Short) As Long
	Declare Function dbgmac_spawn Alias "posix_spawn" (ByVal pid As Long Ptr, ByVal path As Const ZString Ptr, ByVal fa As Any Ptr, ByVal attr As Any Ptr Ptr, ByVal argv As ZString Ptr Ptr, ByVal envp As ZString Ptr Ptr) As Long
	Declare Function dbgmac_environ Alias "_NSGetEnviron" () As ZString Ptr Ptr Ptr
	Declare Function dbgmac_chdir Alias "chdir" (ByVal path As Const ZString Ptr) As Long
	#ifdef __FB_ARM__
		Declare Function dbgmac_vm_machine_attribute Alias "mach_vm_machine_attribute" (ByVal task As ULong, ByVal adr As ULongInt, ByVal size As ULongInt, ByVal attribute As ULong, ByVal value As Long Ptr) As Long
		Declare Function dbgmac_vm_region Alias "mach_vm_region" (ByVal task As ULong, ByVal adr As ULongInt Ptr, ByVal size As ULongInt Ptr, ByVal flavor As Long, ByVal info As Long Ptr, ByVal cnt As ULong Ptr, ByVal objname As ULong Ptr) As Long
	#endif
End Extern

'ptrace of macOS (sys/ptrace.h)
#define DBGMAC_PT_TRACE_ME 0
#define DBGMAC_PT_CONTINUE 7
#define DBGMAC_PT_KILL 8
#define DBGMAC_PT_STEP 9
#define DBGMAC_PT_DETACH 11
#define DBGMAC_PT_ATTACH 10
'posix_spawn: exec in this process (after PT_TRACE_ME), without ASLR
#define DBGMAC_POSIX_SPAWN_SETEXEC &h40
#define DBGMAC_POSIX_SPAWN_DISABLE_ASLR &h100
'Mach
#define DBGMAC_VM_PROT_READ 1
#define DBGMAC_VM_PROT_WRITE 2
#define DBGMAC_VM_PROT_EXECUTE 4
#define DBGMAC_VM_PROT_COPY &h10
#ifdef __FB_ARM__
	#define DBGMAC_THREAD_STATE64 6 'ARM_THREAD_STATE64
	#define DBGMAC_THREAD_STATE64_COUNT 68
	#define DBGMAC_EXCEPTION_STATE64 7 'ARM_EXCEPTION_STATE64
	#define DBGMAC_EXCEPTION_STATE64_COUNT 4
	#define DBGMAC_DEBUG_STATE64 15 'ARM_DEBUG_STATE64
	#define DBGMAC_DEBUG_STATE64_COUNT 130
	#define DBGMAC_MDSCR_SS 1 'the software step of MDSCR_EL1 (single step)
	#define DBGMAC_BRK &hD4200000 'BRK #0
	#define DBGMAC_EC_BRK64 &h3C 'the class of the exception (ESR) of BRK
	#define DBGMAC_MATTR_CACHE 1
	#define DBGMAC_MATTR_VAL_CACHE_FLUSH 6
	#define DBGMAC_VM_REGION_BASIC_INFO_64 9

	Type dbgmac_state64
		As ULongInt x(28), fp, lr, sp, pc
		As ULong cpsr, pad
	End Type

	Type dbgmac_exception64
		As ULongInt far
		As ULong esr, exception
	End Type

	Type dbgmac_debug64
		As ULongInt bvr(15), bcr(15), wvr(15), wcr(15), mdscr_el1
	End Type

	'A breakpoint of Debug.bas: the instruction replaced by BRK
	Type dbgmac_bp
		As ULongInt ad
		As ULong orig
	End Type
	Dim Shared As dbgmac_bp dbgmac_bps(Any)
	Dim Shared As Integer dbgmac_bpnb
	Dim Shared As ULong dbgmac_brkthread 'the thread stopped at a BRK (its pc is given + 1)
	Dim Shared As ULongInt dbgmac_brkpc
	Dim Shared As ULong dbgmac_stepthread 'the thread of a single step
	Dim Shared As ULongInt dbgmac_codelo, dbgmac_codehi 'the last region of code (executable) found
#else
	#define DBGMAC_THREAD_STATE64 4 'x86_THREAD_STATE64
	#define DBGMAC_THREAD_STATE64_COUNT 42
	#define DBGMAC_EXCEPTION_STATE64 6 'x86_EXCEPTION_STATE64
	#define DBGMAC_EXCEPTION_STATE64_COUNT 4
	#define DBGMAC_TF &h100 'the trap flag of rflags (single step)

	Type dbgmac_state64
		As ULongInt rax, rbx, rcx, rdx, rdi, rsi, rbp, rsp, r8, r9, r10, r11, r12, r13, r14, r15, rip, rflags, cs, fs, gs
	End Type

	Type dbgmac_exception64
		As UShort trapno, cpu
		As ULong err
		As ULongInt faultvaddr
	End Type
#endif

Dim Shared As ULong dbgmac_task      'the task of the program (0: not yet)
Dim Shared As Long dbgmac_pid        'the program
Dim Shared As ULong dbgmac_mainthread 'its first thread (thread(0).id is the pid)
Dim Shared As ULong dbgmac_curthread 'the thread of the last stop
Dim Shared As Boolean dbgmac_stopped 'the program is stopped (PT_CONTINUE is made once for all the threads)
Dim Shared As Long dbgmac_lastsig    'the signal of the last stop (PTRACE_GETSIGINFO)
Dim Shared As ULong dbgmac_known(Any) 'the threads already seen (one reference of their port is kept)

'The program is debugged from now: its task (the memory and the threads)
Private Function dbgmac_open(ByVal pid As Long) As Boolean
	If dbgmac_task <> 0 AndAlso dbgmac_pid = pid Then Return True
	dbgmac_pid = pid
	dbgmac_task = 0
	dbgmac_mainthread = 0
	dbgmac_curthread = 0
	Erase dbgmac_known
	Dim As Long kr = dbgmac_task_for_pid(dbgmac_task_self, pid, @dbgmac_task)
	If kr <> 0 Then
		dbgmac_task = 0
		dbg_prt2 "task_for_pid error=";kr
		Return False
	End If
	Return True
End Function

Private Sub dbgmac_close()
	If dbgmac_task <> 0 Then
		For i As Integer = 0 To UBound(dbgmac_known)
			dbgmac_port_deallocate(dbgmac_task_self, dbgmac_known(i))
		Next
		dbgmac_port_deallocate(dbgmac_task_self, dbgmac_task)
	End If
	Erase dbgmac_known
	dbgmac_task = 0
	dbgmac_pid = 0
	dbgmac_mainthread = 0
	dbgmac_curthread = 0
	dbgmac_stopped = False
	#ifdef __FB_ARM__
		Erase dbgmac_bps
		dbgmac_bpnb = 0
		dbgmac_brkthread = 0: dbgmac_brkpc = 0: dbgmac_stepthread = 0
		dbgmac_codelo = 0: dbgmac_codehi = 0
	#endif
End Sub

'thread().id -> the Mach port of the thread (the pid is the first thread)
Private Function dbgmac_thread(ByVal id As Long) As ULong
	If id = dbgmac_pid Then Return dbgmac_mainthread
	Return Cast(ULong, id)
End Function

'The Mach port of a thread -> thread().id
Private Function dbgmac_tid(ByVal th As ULong) As Long
	If th = dbgmac_mainthread Then Return dbgmac_pid
	Return Cast(Long, th)
End Function

'The threads of the program: the new ones are added to thread() (Debug.bas), the first one is the main thread
Private Function dbgmac_threads(thlist() As ULong) As Integer
	Erase thlist
	If dbgmac_task = 0 Then Return 0
	Dim As ULong Ptr pList
	Dim As ULong nb
	If dbgmac_task_threads(dbgmac_task, @pList, @nb) <> 0 OrElse pList = 0 Then Return 0
	ReDim thlist(nb - 1)
	For i As Integer = 0 To nb - 1
		thlist(i) = pList[i]
		Dim As Boolean bKnown
		For k As Integer = 0 To UBound(dbgmac_known)
			If dbgmac_known(k) = pList[i] Then bKnown = True: Exit For
		Next
		If bKnown Then
			dbgmac_port_deallocate(dbgmac_task_self, pList[i]) 'the reference of this call (one is kept)
		Else
			ReDim Preserve dbgmac_known(UBound(dbgmac_known) + 1)
			dbgmac_known(UBound(dbgmac_known)) = pList[i]
			If dbgmac_mainthread = 0 Then
				dbgmac_mainthread = pList[i]
			ElseIf threadnb >= 0 AndAlso thread(0).id = dbgmac_pid Then
				thread_new(Cast(Long, pList[i])) 'a new thread of the program
			End If
		End If
	Next
	dbgmac_vm_deallocate(dbgmac_task_self, Cast(ULongInt, pList), nb * SizeOf(ULong))
	Return nb
End Function

Private Function dbgmac_getstate(ByVal th As ULong, ByRef st As dbgmac_state64) As Boolean
	Dim As ULong cnt = DBGMAC_THREAD_STATE64_COUNT
	Return dbgmac_thread_get_state(th, DBGMAC_THREAD_STATE64, @st, @cnt) = 0
End Function

Private Function dbgmac_setstate(ByVal th As ULong, ByRef st As dbgmac_state64) As Boolean
	Return dbgmac_thread_set_state(th, DBGMAC_THREAD_STATE64, @st, DBGMAC_THREAD_STATE64_COUNT) = 0
End Function

Private Function dbgmac_getexception(ByVal th As ULong, ByRef ex As dbgmac_exception64) As Boolean
	Dim As ULong cnt = DBGMAC_EXCEPTION_STATE64_COUNT
	Return dbgmac_thread_get_state(th, DBGMAC_EXCEPTION_STATE64, @ex, @cnt) = 0
End Function

'The single step of a thread: x86 the flag TF, arm64 the flag SS of MDSCR_EL1. Returns the previous state
Private Function dbgmac_step(ByVal th As ULong, ByVal onoff As Integer) As Boolean '1 on, 0 off, -1 only read
	#ifdef __FB_ARM__
		Dim As dbgmac_debug64 ds
		Dim As ULong cnt = DBGMAC_DEBUG_STATE64_COUNT
		If dbgmac_thread_get_state(th, DBGMAC_DEBUG_STATE64, @ds, @cnt) <> 0 Then Return False
		Dim As Boolean bOn = (ds.mdscr_el1 And DBGMAC_MDSCR_SS) <> 0
		If onoff = 1 AndAlso Not bOn Then
			ds.mdscr_el1 Or= DBGMAC_MDSCR_SS
			dbgmac_thread_set_state(th, DBGMAC_DEBUG_STATE64, @ds, DBGMAC_DEBUG_STATE64_COUNT)
		ElseIf onoff = 0 AndAlso bOn Then
			ds.mdscr_el1 And= Not CULngInt(DBGMAC_MDSCR_SS)
			dbgmac_thread_set_state(th, DBGMAC_DEBUG_STATE64, @ds, DBGMAC_DEBUG_STATE64_COUNT)
		End If
		Return bOn
	#else
		Dim As dbgmac_state64 st
		If Not dbgmac_getstate(th, st) Then Return False
		Dim As Boolean bOn = (st.rflags And DBGMAC_TF) <> 0
		If onoff = 1 AndAlso Not bOn Then
			st.rflags Or= DBGMAC_TF
			dbgmac_setstate(th, st)
		ElseIf onoff = 0 AndAlso bOn Then
			st.rflags And= Not CULngInt(DBGMAC_TF)
			dbgmac_setstate(th, st)
		End If
		Return bOn
	#endif
End Function

'Reads lg bytes of the program (a part at the end of the memory: the readable bytes, the others are 0)
#ifdef __FB_ARM__
Private Function dbgmac_rawread(ByVal adr As ULongInt, ByVal buf As Any Ptr, ByVal lg As Integer) As Boolean
#else
Private Function dbgmac_read(ByVal adr As ULongInt, ByVal buf As Any Ptr, ByVal lg As Integer) As Boolean
#endif
	If dbgmac_task = 0 OrElse lg <= 0 Then Return False
	Dim As ULongInt outsize
	If dbgmac_vm_read(dbgmac_task, adr, lg, Cast(ULongInt, buf), @outsize) = 0 Then Return True
	Dim As Boolean bRead
	For i As Integer = 0 To lg - 1
		If dbgmac_vm_read(dbgmac_task, adr + i, 1, Cast(ULongInt, buf) + i, @outsize) = 0 Then
			bRead = True
		Else
			Cast(UByte Ptr, buf)[i] = 0
		End If
	Next
	Return bRead
End Function

'Writes lg bytes in the program: the code (read and execute) is made writable (a copy of the page) for the write
#ifdef __FB_ARM__
Private Function dbgmac_rawwrite(ByVal adr As ULongInt, ByVal buf As Any Ptr, ByVal lg As Integer) As Boolean
#else
Private Function dbgmac_write(ByVal adr As ULongInt, ByVal buf As Any Ptr, ByVal lg As Integer) As Boolean
#endif
	If dbgmac_task = 0 OrElse lg <= 0 Then Return False
	If dbgmac_vm_write(dbgmac_task, adr, buf, lg) = 0 Then Return True
	#ifdef __FB_ARM__
		Dim As ULongInt pg = adr And Not &h3FFFULL, pgsize = ((adr + lg + &h3FFF) And Not &h3FFFULL) - pg 'pages of 16 KB
	#else
		Dim As ULongInt pg = adr And Not &hFFFULL, pgsize = ((adr + lg + &hFFF) And Not &hFFFULL) - pg
	#endif
	If dbgmac_vm_protect(dbgmac_task, pg, pgsize, 0, DBGMAC_VM_PROT_READ Or DBGMAC_VM_PROT_WRITE Or DBGMAC_VM_PROT_COPY) <> 0 Then Return False
	Dim As Boolean bWritten = dbgmac_vm_write(dbgmac_task, adr, buf, lg) = 0
	dbgmac_vm_protect(dbgmac_task, pg, pgsize, 0, DBGMAC_VM_PROT_READ Or DBGMAC_VM_PROT_EXECUTE)
	#ifdef __FB_ARM__
		'the instruction cache of arm64 is not coherent with the data written
		Dim As Long cacheval = DBGMAC_MATTR_VAL_CACHE_FLUSH
		dbgmac_vm_machine_attribute(dbgmac_task, adr, lg, DBGMAC_MATTR_CACHE, @cacheval)
	#endif
	Return bWritten
End Function

#ifdef __FB_ARM__
	'The breakpoint at ad (an address of an instruction), -1: none
	Private Function dbgmac_bpfind(ByVal ad As ULongInt) As Integer
		For i As Integer = 0 To dbgmac_bpnb - 1
			If dbgmac_bps(i).ad = ad Then Return i
		Next
		Return -1
	End Function

	'The address is in the code (executable memory): a CC written there is a breakpoint (not the value of a variable)
	Private Function dbgmac_iscode(ByVal ad As ULongInt) As Boolean
		If ad >= dbgmac_codelo AndAlso ad < dbgmac_codehi Then Return True
		Dim As ULongInt radr = ad, rsize
		Dim As Long info(15)
		Dim As ULong cnt = 9, objname 'VM_REGION_BASIC_INFO_COUNT_64
		If dbgmac_vm_region(dbgmac_task, @radr, @rsize, DBGMAC_VM_REGION_BASIC_INFO_64, @info(0), @cnt, @objname) <> 0 Then Return False
		If ad < radr Then Return False 'not mapped: the next region
		If (info(0) And DBGMAC_VM_PROT_EXECUTE) = 0 Then Return False 'protection
		dbgmac_codelo = radr: dbgmac_codehi = radr + rsize
		Return True
	End Function

	'Reads the memory as Debug.bas knows it: at a breakpoint the byte CC and the 3 other bytes of the instruction
	Private Function dbgmac_read(ByVal adr As ULongInt, ByVal buf As Any Ptr, ByVal lg As Integer) As Boolean
		If Not dbgmac_rawread(adr, buf, lg) Then Return False
		For i As Integer = 0 To dbgmac_bpnb - 1
			If dbgmac_bps(i).ad + 4 > adr AndAlso dbgmac_bps(i).ad < adr + lg Then
				For k As Integer = 0 To 3
					Dim As LongInt p = CLngInt(dbgmac_bps(i).ad - adr) + k
					If p >= 0 AndAlso p < lg Then Cast(UByte Ptr, buf)[p] = IIf(k = 0, &hCC, (dbgmac_bps(i).orig Shr (8 * k)) And &hFF)
				Next
			End If
		Next
		Return True
	End Function

	'Writes the memory as Debug.bas knows it, for each instruction (4 bytes) changed: CC in the first byte of an
	'instruction of the code (the others not changed) is a breakpoint (BRK), the first byte restored removes it
	Private Function dbgmac_write(ByVal adr As ULongInt, ByVal buf As Any Ptr, ByVal lg As Integer) As Boolean
		If dbgmac_task = 0 OrElse lg <= 0 Then Return False
		Dim As Boolean bOk = True
		Dim As ULongInt w = adr And Not 3ULL
		Do While w < adr + lg
			Dim As ULong cur, des
			If Not dbgmac_read(w, @cur, 4) Then bOk = False: w += 4: Continue Do
			des = cur
			For k As Integer = 0 To 3
				Dim As LongInt p = CLngInt(w - adr) + k
				If p >= 0 AndAlso p < lg Then
					des = (des And Not (&hFFul Shl (8 * k))) Or (CULng(Cast(UByte Ptr, buf)[p]) Shl (8 * k))
				End If
			Next
			If des <> cur Then
				Dim As Integer ib = dbgmac_bpfind(w)
				Dim As ULong orig = IIf(ib >= 0, dbgmac_bps(ib).orig, cur)
				If (des And &hFF) = &hCC AndAlso (des Shr 8) = (orig Shr 8) AndAlso (orig And &hFF) <> &hCC AndAlso dbgmac_iscode(w) Then
					If ib < 0 Then 'a new breakpoint
						Dim As ULong brk = DBGMAC_BRK
						If dbgmac_rawwrite(w, @brk, 4) Then
							If dbgmac_bpnb > UBound(dbgmac_bps) Then ReDim Preserve dbgmac_bps(dbgmac_bpnb * 2 + 256)
							dbgmac_bps(dbgmac_bpnb).ad = w
							dbgmac_bps(dbgmac_bpnb).orig = orig
							dbgmac_bpnb += 1
						Else
							bOk = False
						End If
					End If
				Else
					If ib >= 0 Then 'the breakpoint is removed (the instruction restored or changed)
						dbgmac_bpnb -= 1
						dbgmac_bps(ib) = dbgmac_bps(dbgmac_bpnb)
					End If
					If Not dbgmac_rawwrite(w, @des, 4) Then bOk = False
				End If
			End If
			w += 4
		Loop
		Return bOk
	End Function
#endif

#ifdef __FB_ARM__
'arm64 in pt_regs of x86: xip pc (+ 1 at a BRK), xbp x29 (fp), xsp sp, lr lr, eflags cpsr, the arguments x0-x5 in
'rdi, rsi, rdx, rcx, r8, r9 (rax x0), x6 x7 in r10 r11, x19-x23 in rbx r12-r15
Private Sub dbgmac_to_regs(ByVal th As ULong, ByRef st As dbgmac_state64, ByVal r As pt_regs Ptr)
	r->rax = st.x(0): r->rdi = st.x(0): r->rsi = st.x(1): r->rdx = st.x(2): r->rcx = st.x(3)
	r->r8 = st.x(4): r->r9 = st.x(5): r->r10 = st.x(6): r->r11 = st.x(7)
	r->rbx = st.x(19): r->r12 = st.x(20): r->r13 = st.x(21): r->r14 = st.x(22): r->r15 = st.x(23)
	r->orig_rax = st.x(0)
	r->xbp = st.fp: r->xsp = st.sp: r->lr = st.lr: r->eflags = st.cpsr
	r->xip = st.pc
	If th = dbgmac_brkthread AndAlso st.pc = dbgmac_brkpc AndAlso dbgmac_bpfind(st.pc) >= 0 Then r->xip = st.pc + 1 'as after CC
End Sub

Private Sub dbgmac_from_regs(ByVal th As ULong, ByRef st As dbgmac_state64, ByVal r As pt_regs Ptr)
	st.x(0) = r->rdi: st.x(1) = r->rsi: st.x(2) = r->rdx: st.x(3) = r->rcx
	st.x(4) = r->r8: st.x(5) = r->r9: st.x(6) = r->r10: st.x(7) = r->r11
	st.x(19) = r->rbx: st.x(20) = r->r12: st.x(21) = r->r13: st.x(22) = r->r14: st.x(23) = r->r15
	st.fp = r->xbp: st.sp = r->xsp: st.lr = r->lr
	st.pc = r->xip And Not 3ULL 'the pc + 1 of a BRK: the instructions are aligned
	If th = dbgmac_brkthread AndAlso st.pc <> dbgmac_brkpc Then dbgmac_brkthread = 0
End Sub
#else
Private Sub dbgmac_to_regs(ByVal th As ULong, ByRef st As dbgmac_state64, ByVal r As pt_regs Ptr)
	r->r15 = st.r15: r->r14 = st.r14: r->r13 = st.r13: r->r12 = st.r12
	r->xbp = st.rbp: r->rbx = st.rbx: r->r11 = st.r11: r->r10 = st.r10
	r->r9 = st.r9: r->r8 = st.r8: r->rax = st.rax: r->rcx = st.rcx
	r->rdx = st.rdx: r->rsi = st.rsi: r->rdi = st.rdi: r->orig_rax = st.rax
	r->xip = st.rip: r->cs = st.cs: r->eflags = st.rflags: r->xsp = st.rsp
	r->fs = st.fs: r->gs = st.gs
End Sub

Private Sub dbgmac_from_regs(ByVal th As ULong, ByRef st As dbgmac_state64, ByVal r As pt_regs Ptr)
	st.r15 = r->r15: st.r14 = r->r14: st.r13 = r->r13: st.r12 = r->r12
	st.rbp = r->xbp: st.rbx = r->rbx: st.r11 = r->r11: st.r10 = r->r10
	st.r9 = r->r9: st.r8 = r->r8: st.rax = r->rax: st.rcx = r->rcx
	st.rdx = r->rdx: st.rsi = r->rsi: st.rdi = r->rdi
	st.rip = r->xip: st.rflags = r->eflags: st.rsp = r->xsp
End Sub
#endif

'The program continues (all its threads), with the signal sig (0: none)
Private Function dbgmac_continue(ByVal sig As Long) As Integer
	If Not dbgmac_stopped Then Return 0
	dbgmac_stopped = False
	#ifdef __FB_ARM__
		dbgmac_brkthread = 0
	#endif
	Return dbgmac_ptrace(DBGMAC_PT_CONTINUE, dbgmac_pid, Cast(Any Ptr, 1), sig)
End Function

'The requests of ptrace of Linux (Debug.bi)
Function ptrace(request As PTRACE_REQUEST, pid As Long, addr As Any Ptr, uData As Any Ptr) As Integer
	Select Case request
	Case PTRACE_TRACEME
		Return dbgmac_ptrace(DBGMAC_PT_TRACE_ME, 0, 0, 0)
	Case PTRACE_PEEKTEXT, PTRACE_PEEKDATA
		Dim As Integer dta
		dbgmac_read(Cast(ULongInt, addr), @dta, SizeOf(Integer))
		Return dta
	Case PTRACE_POKETEXT, PTRACE_POKEDATA
		Dim As Integer dta = Cast(Integer, uData)
		Return IIf(dbgmac_write(Cast(ULongInt, addr), @dta, SizeOf(Integer)), 0, -1)
	Case PTRACE_GETREGS
		Dim As dbgmac_state64 st
		Dim As ULong th = dbgmac_thread(pid)
		If Not dbgmac_getstate(th, st) Then Return -1
		dbgmac_to_regs(th, st, uData)
		Return 0
	Case PTRACE_SETREGS
		Dim As ULong th = dbgmac_thread(pid)
		Dim As dbgmac_state64 st
		If Not dbgmac_getstate(th, st) Then Return -1
		dbgmac_from_regs(th, st, uData)
		Return IIf(dbgmac_setstate(th, st), 0, -1)
	Case PTRACE_CONT
		Return dbgmac_continue(CInt(uData))
	Case PTRACE_SINGLESTEP
		'The first thread: PT_STEP (PT_CONTINUE removes its TF/SS). Another thread: its TF (x86) or SS (arm64) and
		'PT_CONTINUE. The thread stops after one instruction, the other threads run too
		Dim As ULong th = dbgmac_thread(pid)
		#ifdef __FB_ARM__
			dbgmac_stepthread = th
		#endif
		If th = dbgmac_mainthread Then
			If Not dbgmac_stopped Then Return 0
			dbgmac_stopped = False
			#ifdef __FB_ARM__
				dbgmac_brkthread = 0
			#endif
			Return dbgmac_ptrace(DBGMAC_PT_STEP, dbgmac_pid, Cast(Any Ptr, 1), 0)
		End If
		dbgmac_step(th, 1)
		Return dbgmac_continue(0)
	Case PTRACE_KILL
		Return dbgmac_ptrace(DBGMAC_PT_KILL, dbgmac_pid, 0, 0)
	Case PTRACE_ATTACH
		Return dbgmac_ptrace(DBGMAC_PT_ATTACH, pid, 0, 0)
	Case PTRACE_DETACH
		Return dbgmac_ptrace(DBGMAC_PT_DETACH, pid, Cast(Any Ptr, 1), 0)
	Case PTRACE_GETSIGINFO
		'The signal of the last stop and the address of the fault (the exception of the thread)
		Dim As tsiginfo Ptr si = uData
		If si = 0 Then Return -1
		Clear *si, 0, SizeOf(tsiginfo)
		si->si_signo = dbgmac_lastsig
		Dim As dbgmac_exception64 ex
		If dbgmac_getexception(dbgmac_thread(pid), ex) Then
			#ifdef __FB_ARM__
				si->si_addr = Cast(Any Ptr, ex.far)
			#else
				si->si_addr = Cast(Any Ptr, ex.faultvaddr)
			#endif
		End If
		Return 0
	Case Else 'PTRACE_SETOPTIONS, PTRACE_GETEVENTMSG: no clone events (the new threads are found at the stops)
		Return 0
	End Select
End Function

'waitpid of Linux: a stop of the program gives its thread (the thread with TF, of the breakpoint before rip, or the first one)
Function dbgmac_wait(ByVal pid As Long, ByVal status As Long Ptr, ByVal options As Long) As Long
	Dim As Long r = dbgmac_waitpid(IIf(pid = -1 AndAlso dbgmac_pid <> 0, dbgmac_pid, pid), status, options And 1) 'WNOHANG only (not __WALL)
	If r <= 0 Then Return r
	If (*status And &hFF) <> &h7F Then 'the end of the program
		If r = dbgmac_pid Then dbgmac_close
		Return r
	End If
	dbgmac_stopped = True
	dbgmac_lastsig = (*status Shr 8) And &hFF
	If Not dbgmac_open(r) Then
		ThreadsEnter
		MsgBox ML("Integrated IDE Debugger") & ": task_for_pid " & ML("error") & Chr(10) & _
			"VisualFBEditor needs the entitlement com.apple.security.cs.debugger (codesign) and the Developer Mode (DevToolsSecurity -enable)." & Chr(10) & _
			"codesign -s - -f --entitlements src/VisualFBEditor.entitlements VisualFBEditor64"
		ThreadsLeave
		dbgmac_ptrace(DBGMAC_PT_KILL, r, 0, 0)
		Return r
	End If
	Dim As ULong thlist(Any), found
	Dim As Integer nb = dbgmac_threads(thlist())
	Dim As dbgmac_state64 st
	'A single step: the thread with TF/SS (removed)
	For i As Integer = 0 To nb - 1
		If dbgmac_step(thlist(i), 0) Then
			If found = 0 Then found = thlist(i)
		End If
	Next
	#ifdef __FB_ARM__
		'PT_STEP of the first thread: its SS can be already removed
		If found = 0 AndAlso dbgmac_stepthread <> 0 AndAlso dbgmac_lastsig = 5 Then found = dbgmac_stepthread
		dbgmac_stepthread = 0
		dbgmac_brkthread = 0
		'A breakpoint: the thread at a BRK of Debug.bas (its pc is given + 1 as after a CC)
		If found = 0 AndAlso dbgmac_lastsig = 5 Then
			'the thread with the exception of BRK, else the first thread at a BRK
			Dim As ULong cand
			Dim As ULongInt candpc
			For i As Integer = 0 To nb - 1
				If dbgmac_getstate(thlist(i), st) AndAlso dbgmac_bpfind(st.pc) >= 0 Then
					Dim As dbgmac_exception64 ex
					If dbgmac_getexception(thlist(i), ex) AndAlso (ex.esr Shr 26) = DBGMAC_EC_BRK64 Then
						found = thlist(i): dbgmac_brkpc = st.pc
						Exit For
					End If
					If cand = 0 Then cand = thlist(i): candpc = st.pc
				End If
			Next
			If found = 0 AndAlso cand <> 0 Then found = cand: dbgmac_brkpc = candpc
			dbgmac_brkthread = found
		End If
		'A fault: the thread with an exception (not BRK, not a single step)
		If found = 0 AndAlso dbgmac_lastsig <> 5 Then
			For i As Integer = 0 To nb - 1
				Dim As dbgmac_exception64 ex
				If dbgmac_getexception(thlist(i), ex) AndAlso ex.esr <> 0 Then
					Select Case ex.esr Shr 26
					Case DBGMAC_EC_BRK64, &h32, &h33 'BRK, software step
					Case Else: found = thlist(i): Exit For
					End Select
				End If
			Next
		End If
	#else
		'A breakpoint: the thread after a CC
		If found = 0 AndAlso dbgmac_lastsig = 5 Then
			For i As Integer = 0 To nb - 1
				If dbgmac_getstate(thlist(i), st) Then
					Dim As UByte b
					If dbgmac_read(st.rip - 1, @b, 1) AndAlso b = &hCC Then found = thlist(i): Exit For
				End If
			Next
		End If
		'A fault: the thread with an exception
		If found = 0 AndAlso dbgmac_lastsig <> 5 Then
			For i As Integer = 0 To nb - 1
				Dim As dbgmac_exception64 ex
				If dbgmac_getexception(thlist(i), ex) AndAlso ex.trapno <> 0 AndAlso ex.trapno <> 3 AndAlso ex.trapno <> 1 Then found = thlist(i): Exit For
			Next
		End If
	#endif
	If found = 0 Then found = dbgmac_mainthread
	dbgmac_curthread = found
	Return dbgmac_tid(found)
End Function

'Starts the program for the debugger (child of fork, after PT_TRACE_ME): exec without ASLR. Returns only on an error
Sub dbgmac_exec(ByRef sExe As String, ByRef sArgs As String, ByRef sDir As String)
	If sDir <> "" Then dbgmac_chdir(StrPtr(sDir))
	Dim As Any Ptr attr
	dbgmac_spawnattr_init(@attr)
	dbgmac_spawnattr_setflags(@attr, DBGMAC_POSIX_SPAWN_SETEXEC Or DBGMAC_POSIX_SPAWN_DISABLE_ASLR)
	'The arguments: separated by spaces, "..." keeps the spaces
	Dim As String args(Any)
	ReDim args(0): args(0) = sExe
	Dim As String s
	Dim As Boolean q, inArg
	For i As Integer = 1 To Len(sArgs)
		Dim As String c = Mid(sArgs, i, 1)
		If c = """" Then
			q = Not q: inArg = True
		ElseIf c = " " AndAlso Not q Then
			If inArg Then ReDim Preserve args(UBound(args) + 1): args(UBound(args)) = s
			s = "": inArg = False
		Else
			s &= c: inArg = True
		End If
	Next
	If inArg Then ReDim Preserve args(UBound(args) + 1): args(UBound(args)) = s
	Dim As ZString Ptr argv(UBound(args) + 1)
	For i As Integer = 0 To UBound(args)
		argv(i) = StrPtr(args(i))
	Next
	argv(UBound(args) + 1) = 0
	Dim As Long p
	dbgmac_spawn(@p, StrPtr(sExe), 0, @attr, @argv(0), *dbgmac_environ())
	dbgmac_exit(127)
End Sub
