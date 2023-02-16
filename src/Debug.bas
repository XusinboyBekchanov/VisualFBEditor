'#########################################################
'#  Debug.bas                                            #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Laurent GRAS                                #
'#           Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "Debug.bi"

'mutex for blocking second thread before continue
Dim Shared As Any Ptr blocker
blocker = MutexCreate

''state of cc on each line can be KCC_ALL / KCC_NONE
''could be partially true but should be the main state
Dim Shared As KCC_STATE ccstate

Dim Shared As Integer debugevent
Dim Shared As Integer debugdata ''index of bp or address of BP (case BP on mem)
Dim Shared As String  libelexception
Dim Shared As Integer ssadr ''address of line for restoring breakcpu when singlestepping
Dim Shared As Integer firsttime
Dim Shared As Integer srcstart

''codes when debuggee stopped and corresponding texts
Dim Shared stopcode As Integer
Dim Shared stoplibel(20) As String*17 =>{"","BP On line","BP perm/tempo","BP cond","BP var","BP mem"_
,"BP count","Halt by user","Access violation","thread created","Exception"}

''source files
Dim Shared As String  source(SRCMAX)        ''source names with path
Dim Shared As String  srcname(SRCMAX)       ''source names without path
Dim Shared As tlist   srclist(SRCMAX)       ''to sort
Dim Shared As Integer srclistfirst          ''first sorted element
Dim Shared As Integer srccombocur           ''current combo choice
Dim Shared As Any Ptr sourceptr(SRCMAX)     ''pointer doc scintilla
Dim Shared As Any Ptr oldscintilla          ''last pointer for scintilla
Dim Shared As UByte   sourcebuf(SRCSIZEMAX) ''buffer for loading source file
Dim Shared As Integer sourcenb =-1          ''number of src, 0 based
Dim Shared As Integer sourceix              ''source index when loading data
Dim Shared As Any Ptr currentdoc            ''current doc pointer

Dim Shared As Integer srcdisplayed			''index displayed source

''lines
Dim Shared As Integer linenb, rlineprev ''numbers of lines, index of previous executed line (rline)
Dim Shared As Integer linenbprev ''used for dll
Dim Shared As Integer lastline
Dim Shared As tline rline(LINEMAX) ''1 based

''current tab:line
Dim Shared As Integer srccur   ''index source line to be executed
Dim Shared As Integer linecur  ''line to be executed (inside source)
Dim Shared As Integer rlinecur ''line to be executed

''procedures
Dim Shared As tproc proc(PROCMAX) ''list of procs in code
Dim Shared As Integer procnb
Dim Shared As Integer procnew ''used for finding address of first fbc line
Dim Shared As Integer procmain
Dim Shared As tlist   proclist(PROCMAX)
Dim Shared As Integer proclistfirst ''first sorted element

Dim Shared As Integer procsv,procsk,proccurad,procfn,procsort
Dim Shared As tprocr procr(PROCRMAX) ''list of running proc
Dim Shared As Integer procrnb
Dim Shared As Integer prolog ''it's in the prologue (if 1)

''arrays
Dim Shared  As tarr arr(ARRMAX)
Dim Shared As Integer arrnb

''variables
Dim Shared vrbloc      As Integer ''pointer of loc variables or components (init VGBLMAX+1)
Dim Shared vrbgbl      As Integer ''pointer of globals or components
Dim Shared vrbgblprev  As Integer ''for dll, previous value of vrbgbl, initial 1
Dim Shared vrbptr      As Integer Ptr ''equal @vrbloc or @vrbgbl
Dim Shared vrb(VARMAX) As tvrb ''1 based

''running variables
Dim Shared vrr(VRRMAX) As tvrr
Dim Shared vrrnb As Integer

''tracking arrays
Dim Shared As ttrckarr trckarr(TRCKARRMAX)

''udt/structures
Dim Shared udt(TYPEMAX) As tudt,udtidx As Integer
Dim Shared cudt(CTYPEMAX) As tcudt,cudtnb As Integer,cudtnbsav As Integer
'in case of module or DLL the udt number is initialized each time
Dim Shared As Integer udtcpt,udtmax 'current, max cpt

''excluded lines
Dim Shared As Integer excldnb
Dim Shared As texcld excldlines(EXCLDMAX)

''log
Dim Shared As Any Ptr hlogbx
Dim Shared As String vlog
Dim Shared As Integer logtyp

Dim Shared As Any Ptr heditorbx
Dim Shared As Integer afterkilled ''what doing after debuggee killed
''attach running exe
Dim Shared As Any Ptr hattachbx

Dim Shared As Integer threadlistidx ''used with multi action
Dim Shared As Integer multiaction

#ifdef __FB_WIN32__
	''Threads
	Dim Shared thread(THREADMAX) As tthread  ''zero based
	Dim Shared threadlist(THREADMAX) As Integer
	Dim Shared threadnb As Integer
	Dim Shared threadcur As Integer
	Dim Shared threadprv As Integer     'previous thread used when mutexunlock released thread or after thread create
	Dim Shared threadcontext As HANDLE
	Dim Shared threadhs As HANDLE       'handle thread to resume
	Dim Shared dbgprocid As Integer     'pinfo.dwProcessId : debugged process id
	Dim Shared dbgthreadID As Integer   'pinfo.dwThreadId : debugged thread id
	Dim Shared dbghand As HANDLE  		'debugged proc handle
	Dim Shared dbghthread As HANDLE     'debuggee thread handle
	Dim Shared dbghfile  As HANDLE   	'debugged file handle
	Dim Shared pinfo As PROCESS_INFORMATION
	
	''DLL
	Dim Shared As tdll dlldata(DLLMAX) ''base 1
	Dim Shared As Integer dllnb
	
	'dbg_prt2 "MutexLock00"
	MutexLock blocker
#else ''linux
	Dim Shared dbgprocid As Long
	Dim Shared As Long dbgpid '' debugger pid
	Dim Shared As Long dbghand '' in code defined dgbhand
	Dim Shared As Long thread2 ''second thread
	Dim Shared As Long threadhs '' in code defined dgbhand
	Dim Shared As Long threadcur '' index
	Dim Shared As Long threadnewid '' new thread tid
	Dim Shared As Integer threadnewidcount '' count for new thread (needed for accessing first basic line)
	
	Dim Shared As Long statussaved
	Dim Shared As Long threadsaved
	
	Dim Shared As pt_regs regs
	Dim Shared As tthread thread(THREADMAX) ''zero based
	Dim Shared As Integer threadnb
	Dim Shared threadlist(THREADMAX) As Long
	Dim Shared As GtkWidget Ptr wsci
	''DLL = .so
	Dim Shared As tdll dlldata(DLLMAX) ''base 1
	Dim Shared As Integer dllnb
	Dim Shared As Integer msgcmd
	Dim Shared As Integer msgad
	Dim Shared As Integer msgad2
	Dim Shared As Integer msgdata
	Dim Shared As Integer msgdata2
	Dim Shared As Any Ptr condid
	condid=CondCreate()
	Dim Shared As Boolean bool1,bool2 ''predicate for each thread of the debugger
	
	
	Dim Shared errorlibel(...) As String*35=>{"","Operation not permitted","No such file or directory","No such process","Interrupted system call" _
	,"I/O error","No such device or address","Argument list too long","Exec format error","Bad file number","No child processes","Try again" _
	,"Out of memory","Permission denied","Bad address","Block device required","Device or resource busy","File exists","Cross-device link" _
	,"No such device","Not a directory","Is a directory","Invalid argument","File table overflow","Too many open files","Not a typewriter" _
	,"Text file busy","File too large","No space left on device","Illegal seek","Read-only file system","Too many links","Broken pipe" _
	,"Math argument out of domain of func","Math result not representable"}
	
#endif

''miscellanous data
Dim Shared As Boolean prun=False    ''debuggee running
Dim Shared As Integer runtype = RTOFF ''running type
Dim Shared As Integer breakcpu=&hCC ''asm code for breakpoint
Dim Shared As Integer breakadr ''address of last ABP kept in case of exception (RTCRASH)
Dim Shared As Integer dsptyp=0      ''type of display : 0 normal/ 1 source/ 2 var/ 3 memory

''put in a ctx with type ??
Dim Shared As Boolean procnodll
Dim Shared As Boolean flagmain
Dim Shared As Boolean flagkill =False 'flag if killing process to avoid freeze in thread_del
Dim Shared As Integer flagrestart=-1  'flag to indicate restart in fact number of bas files to avoid to reload those files
Dim Shared As Integer flagwtch  =0     'flag =0 clean watched / 1 no cleaning in case of restart
Dim Shared As Byte flaglog =0         ' flag for dbg_prt 0 --> no output / 1--> only screen / 2-->only file / 3 --> both
Dim Shared As Byte flagtrace          ' flag for trace mode : 1 proc / +2 line
Dim Shared As Byte flagverbose        ' flag for verbose mode
Dim Shared As Byte flagascii          ' flag for dump displays only code ascii <128 by default just >32
Dim Shared As Boolean flagupdate = True ''if true proc/var, dump and watched displayed
Dim Shared As Boolean flagattach      ' flag for attach

Dim Shared As Any Ptr hmain

''for autostepping
Dim Shared As Integer autostep = 50
Dim Shared As Integer flaghalt

''watched
Dim Shared wtch(WTCHMAX) As twtch  ''zero based
Dim Shared wtchcpt As Integer 'counter of watched value, used for the menu
Dim Shared hwtchbx As Any Ptr    'handle
Dim Shared wtchidx As Integer 'index for delete
Dim Shared wtchexe(9,WTCHMAX) As String 'watched var (no memory for next execution)
Dim Shared wtchnew As Integer 'to keep index after creating new watched

''breakpoint on line
Dim Shared As tbrkol brkol(BRKMAX)
Dim Shared As Integer brknb
Dim Shared As String brkexe(9,BRKMAX) 'to save breakpoints by session
Dim Shared As Any Ptr hbrkbx ''window for managing breakpoints
Dim Shared As Boolean bpbox
Dim Shared As Integer brkidx1 ''index for BP mem or cond
Dim Shared As Integer brkidx2
Dim Shared As Integer brkadr1 ''address for BP mem or cond
Dim Shared As Integer brkadr2
Dim Shared As Integer brkdatatype
Dim Shared As Integer brkttb
Dim Shared As valeurs brkdata2
Dim Shared As Integer brktyp  ''type of BP mem/const or mem/mem
Dim Shared As Any Ptr hbpcondbx ''dialog box for managing var/const cond BP
Dim Shared As tbrclist listitem(VRRMAX)
Dim Shared As Integer listcpt ''used when filling array for cond BP
Dim Shared As Integer brkline(BRKMAX) ''used when deleting the BP one by one

''breakpoint on variable/memory (when there is a change)
Dim Shared As tbrkv brkv
Dim Shared As Any Ptr hbrkvbx ''handle

''call chain
Dim Shared As Any Ptr hcchainbx
Dim Shared As Any Ptr hlviewcchain
Dim Shared As Integer procrsav(PROCRMAX) ''index of procr
Dim Shared As Integer cchainthid

''edit box
Dim Shared As Any Ptr heditbx
Dim Shared As tedit edit ''data when editing var or mem

''find text box
Dim Shared As Any Ptr hfindtextbx
Dim Shared As tftext ftext

''dump memory
Dim Shared As Any Ptr hdumpbx ''window for handling dump
Dim Shared dumplines As Integer =20 'nb lines(default 20)
Dim Shared dumpadr   As Integer    'address for dump
Dim Shared dumpbase  As Integer =0 'value dump dec=0 or hexa=50
Dim Shared dumpadrbase   As Integer =1 'address display in dec (1) or hex (0)
Dim Shared dumpnbcol As Integer
Dim Shared dumptyp   As Integer =2

Dim Shared htviewvar As Any Ptr 'running proc/var
Dim Shared htviewprc As Any Ptr 'all proc
Dim Shared htviewthd As Any Ptr 'all threads
Dim Shared htviewwch As Any Ptr 'watched variables
Dim Shared hlviewdmp As Any Ptr 'dump

''variable find
Dim Shared As tvarfind varfind

''show/expand
Dim Shared As tshwexp shwexp
Dim Shared As Any Ptr hshwexpbx
Dim Shared As Any Ptr htviewshw
Dim Shared As tvrp vrp(VRPMAX)

'' index selection
#define KCOLMAX 30
#define KLINEMAX 50

Dim Shared As Any Ptr hindexbx
Dim Shared As tindexdata indexdata

''slash for file WDS<>LNX
'Dim Shared As ZString *2 slash
'#Ifdef __FB_WIN32__
'	slash="\"
'#else
'	slash="/"
'#endif

udt(0).nm="Unknown"

#Ifdef __FB_64BIT__
	udt(1).nm="long":udt(1).lg=Len(Long)
#Else
	udt(1).nm="Integer":udt(1).lg=Len(Integer)
#EndIf
udt(2).nm="Byte":udt(2).lg=Len(Byte)
udt(3).nm="Ubyte":udt(3).lg=Len(UByte)
udt(4).nm="Zstring":udt(4).lg=Len(Integer)
udt(5).nm="Short":udt(5).lg=Len(Short)
udt(6).nm="Ushort":udt(6).lg=Len(UShort)
udt(7).nm="Void":udt(7).lg=Len(Integer)

#Ifdef __FB_64BIT__
	udt(8).nm="Ulong":udt(8).lg=Len(ULong)
#Else
	udt(8).nm="Uinteger":udt(8).lg=Len(UInteger)
#EndIf

#Ifdef __FB_64BIT__
	udt(9).nm="Integer":udt(9).lg=Len(Integer)
#Else
	udt(9).nm="Longint":udt(9).lg=Len(LongInt)
#EndIf

#Ifdef __FB_64BIT__
	udt(10).nm="Uinteger":udt(10).lg=Len(UInteger)
#Else
	udt(10).nm="Ulongint":udt(10).lg=Len(ULongInt)
#EndIf

udt(11).nm="Single":udt(11).lg=Len(Single)
udt(12).nm="Double":udt(12).lg=Len(Double)
udt(13).nm="String":udt(13).lg=Len(String)
udt(14).nm="Fstring":udt(14).lg=Len(Integer)
udt(15).nm="fb_Object":udt(15).lg=Len(UInteger)
udt(16).nm="Boolean":udt(16).lg=Len(Boolean)

reinit()

Dim Shared exename As WString * 300
Dim Shared mainfolder As WString * 300 'debuggee main folder
Dim Shared exedate As Double 'serial date
Dim Shared As String compilerversion ''compiler version retrieved stabs code = 255
Dim Shared As String cmdlimmediat

'===================================================
'' set/unset breakpoint markers
'===================================================
Private Sub brk_marker(brkidx As Integer)
	Dim As Integer src,lline=brkol(brkidx).nline-1,typ
	
	If brkol(brkidx).typ>50 Then
		typ=6 ''disabled --> grey marker
	Else
		If brkidx=0 Then
			If brkol(brkidx).typ<>0 Then
				typ=7 ''red circle
				'messbox("red circle on line=",str(lline+1))
			End If
		Else
			typ=brkol(brkidx).typ  ''permanent cond tempo --> marker 1 or 2 or 3
		End If
	End If
	
	src=srcdisplayed
	'source_change(brkol(brkidx).isrc)
	If typ Then
		'send_sci(SCI_MARKERDELETE, lline, -1)
		'send_sci(SCI_MARKERADD, lline, typ)
		If bpbox=True Then
			'hidewindow(hbrkbx,KHIDE)
			brk_manage("Breakpoint management")
		End If
	Else
		'send_sci(SCI_MARKERDELETE, lline, -1)
	End If
	
	'source_change(src)
End Sub
'========================================
''
'========================================
Private Function brk_comp(tst As Integer) As WString Ptr
	Select Case tst
	Case 32
		Return @"="
	Case 16
		Return @"<>"
	Case 8
		Return @">"
	Case 4
		Return @"<"
	Case 2
		Return @">="
	Case 0
		Return @"<="
	End Select
End Function

#ifdef __USE_GTK__
	Sub SetWindowText Overload(Wind As Any Ptr, ByRef text As WString)
		
	End Sub
#endif
'========================================
'' updates break on var/mem
'========================================
Private Sub brkv_update()
	
	Dim As String txt = "" 'getgadgettext(GBRKVALUE)
	Dim As Integer vflag=1
	Dim As Double vald
	
	'brkv.ttb=32 Shr GetItemComboBox(GBRKVCOND)
	
	vald=Val(txt)
	Select Case brkv.typ
	Case 2
		If vald<-128 Or vald>127 Then SetWindowText(hbrkvbx,"min -128,max 127"):vflag=0
	Case 3
		If vald<0 Or vald>255 Then SetWindowText(hbrkvbx,"min 0,max 255"):vflag=0
	Case 5
		If vald<-32768 Or vald>32767 Then SetWindowText(hbrkvbx,"min -32768,max 32767"):vflag=0
	Case 6
		If vald<0 Or vald>65535 Then SetWindowText(hbrkvbx,"min 0,max 65535"):vflag=0
	Case 1
		If vald<-2147483648 Or vald>2147483648 Then SetWindowText(hbrkvbx,"min -2147483648,max +2147483647"):vflag=0
	Case 7,8
		If vald<0 Or vald>4294967395 Then SetWindowText(hbrkvbx,"min 0,max 4294967395"):vflag=0
	Case 9
		If vald<-9223372036854775808 Or vald>9223372036854775807 Then SetWindowText(hbrkvbx,"min -9223372036854775808,max 9223372036854775807"):vflag=0
	Case 10
		If vald<0 Or vald>18446744073709551615 Then SetWindowText(hbrkvbx,"min 0,max 18446744073709551615"):vflag=0
	End Select
	If vflag=1 Then
		Select Case brkv.typ
		Case 2
			brkv.Val.vbyte=ValInt(txt)
			brkv.vst=Str(brkv.Val.vbyte)
		Case 3
			brkv.Val.vubyte=ValUInt(txt)
			brkv.vst=Str(brkv.Val.vubyte)
		Case 5
			brkv.Val.vshort=ValInt(txt)
			brkv.vst=Str(brkv.Val.vshort)
		Case 6
			brkv.Val.vushort=ValUInt(txt)
			brkv.vst=Str(brkv.Val.vushort)
		Case 1
			brkv.Val.vinteger=ValInt(txt)
			brkv.vst=Str(brkv.Val.vinteger)
		Case 7,8
			brkv.Val.vuinteger=ValUInt(txt)
			brkv.vst=Str(brkv.Val.vuinteger)
		Case 9
			brkv.Val.vlongint=ValLng(txt)
			brkv.vst=Str(brkv.Val.vlongint)
		Case 10
			brkv.Val.vulongint=ValULng(txt)
			brkv.vst=Str(brkv.Val.vulongint)
		Case Else
			brkv.vst=Left(txt,26)'str(brkv.val.vuinteger)
		End Select
		
		Select Case brkv.ttb
		Case 1
			brkv.txt+="="
		Case 2
			brkv.txt+="<>"
		Case 3
			brkv.txt+=">"
		Case 4
			brkv.txt+="<"
		Case 5
			brkv.txt+=">="
		Case 6
			brkv.txt+="<="
		End Select
		'Modify_Menu(MNBRKVC,HMenuvar,brkv.txt+brkv.vst)
		'hidewindow(hbrkvbx ,KHIDE)
	End If
End Sub
'========================================================================
''
'========================================================================
'Private Sub brkv_set(a As Integer) ''break on variable change
'	Dim As String txt
'	If a=0 Then 'cancel break
'		brkv.adr1=0
'		brkv.adr2=0
'		brkv.ivr1=0
'		brkv.ivr2=0
'		'Modify_Menu(MNBRKVS,HMenuvar2,"Show BP if any")
'		'statusbar_text(KSTBBPM,"")
'		'SetStateMenu(HMenuvar2,MNBRKVS,1)
'		'hidewindow(hbrkvbx ,KHIDE)
'		Exit Sub
'
'	ElseIf a=1 Then ''mem/const
'		var_fill(brkidx1)
'		brkv.typ=brkdatatype
'		brkv.adr1=varfind.ad
'		brkv.vst=""
'		'brkv.ttb=32 Shr GetItemComboBox(GBRKVCOND)
'		brkv.ivr1=brkidx1
'		txt=varfind.nm+" "+*brk_comp(brkv.ttb)+" "
'		If brkdatatype=11 Then
'			'brkv.Val.vsingle=Val(getgadgettext(GBRKVALUE))
'			txt+=Str(brkv.Val.vsingle)
'		ElseIf brkdatatype=12 Then
'			'brkv.Val.vdouble=Val(getgadgettext(GBRKVALUE))
'			txt+=Str(brkv.Val.vdouble)
'		Else
'			'brkv.Val.vlongint=ValLng(getgadgettext(GBRKVALUE))
'			txt+=Str(brkv.Val.vlongint)
'		EndIf
'
'	ElseIf a=2 Then ''mem/mem
'		var_fill(brkidx1)
'		brkv.typ=brkdatatype
'		brkv.adr1=varfind.ad
'		txt=varfind.nm
'		var_fill(brkidx2)
'		brkv.adr2=varfind.ad
'		'brkv.ttb=32 Shr GetItemComboBox(GBRKVCOND)
'		brkv.ivr1=brkidx1
'		brkv.ivr2=brkidx2
'		txt+=*brk_comp(brkv.ttb)+" "+varfind.nm
'	End If
'
'	'modify_menu(MNBRKVS,HMenuvar2,txt)
'	'SetStateMenu(HMenuvar2,MNBRKVS,0)
'	'statusbar_text(KSTBBPM,"BPM-> "+txt)
'		'' if dyn array store real adr
'		'If Cast(Integer,vrb(varfind.pr).arr)=-1 Then
'			'ReadProcessMemory(dbghand,Cast(LPCVOID,vrr(varfind.iv).ini),@brkv.arr,sizeof(integer),0)
'		'Else
'			'brkv.arr=0
'		'End If
'
'		'If vrb(varfind.pr).mem=3 Then
'			'brkv.psk=-2 'static
'		'Else
'			'For j As UInteger = 1  To procrnb 'find proc to delete watching
'				'If varfind.iv>=procr(j).vr And varfind.iv<procr(j+1).vr Then
'					'brkv.psk=procr(j).sk
'					'Exit For
'				'EndIf
'			'Next
'		'End If
'		'ztxt=GetTextTreeView(GTVIEWVAR,vrr(varfind.iv).tv)
'	'Else 'update
'		'ztxt=GetTextTreeView(GTVIEWVAR,vrr(varfind.iv).tv)
'	'End If
'	'brkv.txt=Left(ztxt,InStr(ztxt,"<"))+var_sh2(brkv.typ,brkv.adr,p)
'
'
'
'	'If brkv.vst="" Then
'	  'brkv.vst=Mid(brkv.txt,InStr(brkv.txt,"=")+1,25)
'	'End If
'	'brkv.txt+=" Stop if it becomes "
'	'ShowListComboBox(GBRKVCOND,1)
'	'SetGadgetText(GBRKVAR1,brkv.txt)
'	'setgadgettext(GBRKVALUE,brkv.vst)
'	'hidewindow(hbrkvbx,KSHOW)
'End Sub
'================================
'Private Sub brk_apply()
''brkexe = <name>,<#line>,<typ>
'Dim f As Boolean =False
'For i As Integer =1 To BRKMAX
'	Dim As String brks,fn
'	Dim As Integer p,p2,ln,ty
'	Dim As UInteger cntr
'	If brknb=BRKMAX Then Exit For 'no more breakpoint possible
'
'	If brkexe(0,i)<>"" Then 'not empty
'		brks=brkexe(0,i)
'		p=InStr(brks,",") 'parsing
'		fn=Left(brks,p-1) 'file name
'		p2=p+1
'		p=InStr(p2,brks,",")
'		ln=ValInt(Mid(brks,p2,p-p2)) 'number line
'		p2=p+1
'		p=InStr(p2,brks,",")
'		cntr=ValUInt(Mid(brks,p2,p-p2)) 'counter
'		ty=ValInt(Right(brks,1)) 'type
'		For j As Integer =0 To sourcenb
'			If source_name(source(j))=fn Then 'name matching
'				For k As Integer= 1 To linenb
'					If rline(k).nu=ln AndAlso rline(k).sx=j Then 'searching index in rline
'						brknb+=1
'						brkol(brknb).isrc =j
'						brkol(brknb).nline=ln
'						brkol(brknb).index=k
'						brkol(brknb).ad   =rline(k).ad
'						brkol(brknb).typ  =ty
'						brkol(brknb).cntrsav=cntr
'						brkol(brknb).counter=cntr
'						brk_marker(brknb)
'						f=True 'flag for managing breakpoint
'						Exit For
'					EndIf
'				Next
'				brkexe(0,i)="" 'used one time
'				Exit For
'			EndIf
'		Next
'	EndIf
'
'Next
'If f Then
'	brk_manage("Restart debuggee, managing breakpoints")
'	'SetStateMenu(HMenusource,MNMNGBRK,0)
'	'DisableGadget(IDBUTBRKB,0)
'EndIf
'End Sub
'============================================
Private Sub brk_sav()
	For i As Integer =1 To BRKMAX
		If i<=brknb Then
			If brkol(i).typ=1 Or brkol(i).typ=5 Or brkol(i).typ=4 Or brkol(i).typ=51 Or brkol(i).typ=55 Or brkol(i).typ=54 Then ''only permanent/tempo/counter
				brkexe(0,i)=source_name(source(brkol(i).isrc))+","+Str(brkol(i).nline)+","+Str(brkol(i).cntrsav)+","+Str(brkol(i).typ)
			Else
				brkol(i).typ=0
				brk_marker(i)
			End If
		End If
	Next
End Sub
'================================================
'' deletes one breakpoint and compresses data
'================================================
'Private Sub brk_del(n As Integer)
'brkol(n).typ=0
'brkol(n).cntrsav=0
'brk_marker(n)
'If n=0 Then ''run
'	Exit Sub
'EndIf
'brknb-=1
'For i As Integer =n To brknb
'	brkol(i)=brkol(i+1)
'Next
'If brknb=0 Then
'	'SetStateMenu(HMenusource,MNMNGBRK,1)
'	'DisableGadget(IDBUTBRKB,1)
'	'hidewindow(hbrkbx,KHIDE) ''even if not show
'	bpbox=False
'Else
'	If bpbox=True Then
'		'hidewindow(hbrkbx,KHIDE)
'		brk_manage("Breakpoint management")
'	End If
'EndIf
'End Sub
'================================================================================
'' tests the values for breakpoint on var/mem or conditionnal
'================================================================================
Private Function brk_test Overload (adr1 As Integer, adr2 As Integer = 0, datatype As Integer, data2 As valeurs, comptype As Byte) As Integer
	
	'Dim As Integer adr,temp2,temp3
	'Dim As String strg1,strg2,strg3
	'dim ptrs As pointeurs
	'ptrs.pxxx=@recup(0)
	Dim As Integer flag=0
	'dim as integer recup(20)
	Dim As valeurs recup1,recup2
	'dbg_prt2 adr1,adr2,datatype,data2.vlongint,data2.vdouble,comptype
	'If brkv.arr Then 'watching dyn array element ?
	'adr=vrr(brkv.ivr).ini
	'ReadProcessMemory(dbghand,Cast(LPCVOID,adr),@adr,4,0)
	'If adr<>brkv.arr Then brkv.adr+=brkv.arr-adr:brkv.arr=adr 'compute delta then add it if needed
	'temp2=vrr(brkv.ivr).ini+2*SizeOf(Integer) 'adr global size
	'ReadProcessMemory(dbghand,Cast(LPCVOID,temp2),@temp3,SizeOf(Integer),0)
	'If brkv.adr>adr+temp3 Then 'out of limit ?
	'brkv_set(0) 'erase
	'Return FALSE
	'End If
	'End If
	''recup2 recup1
	''21 --> <> or > or >=
	''26 --> <> or < or <=
	''35 --> = or >= or <=
	''16 --> <>
	
	#Ifdef __FB_WIN32__
		ReadProcessMemory(dbghand,Cast(LPCVOID,adr1),@recup1,8,0)
	#else
		recup1.vlongint=ReadMemLongInt(thread(threadcur).id, adr1)
	#endif
	If adr2 Then
		#Ifdef __FB_WIN32__
			ReadProcessMemory(dbghand,Cast(LPCVOID,adr2),@recup2,8,0)
		#else
			recup2.vlongint=ReadMemLongInt(thread(threadcur).id, adr2)
		#endif
	Else
		recup2=data2
	End If
	
	Select Case datatype
	Case 2 'byte
		If recup2.vbyte>recup1.vbyte Then
			If 21 And comptype Then
				flag=1
			End If
		ElseIf recup2.vbyte<recup1.vbyte Then
			If 26 And comptype Then
				flag=1
			End If
		ElseIf recup2.vbyte=recup1.vbyte Then
			If 35 And comptype Then
				flag=1
			End If
		End If
		
	Case 3 'ubyte
		If recup2.vubyte>recup1.vubyte Then
			If 21 And comptype Then
				flag=1
			End If
		ElseIf recup2.vubyte<recup1.vubyte Then
			If 26 And comptype Then
				flag=1
			End If
		ElseIf recup2.vubyte=recup1.vubyte Then
			If 35 And comptype Then
				flag=1
			End If
		End If
		
	Case 5 'short
		If recup2.vshort>recup1.vshort Then
			If 21 And comptype Then
				flag=1
			End If
		ElseIf recup2.vshort<recup1.vshort Then
			If 26 And comptype Then
				flag=1
			End If
		ElseIf recup2.vshort=recup1.vshort Then
			If 35 And comptype Then
				flag=1
			End If
		End If
		
	Case 6 'ushort
		If recup2.vushort>recup1.vushort Then
			If 21 And comptype Then
				flag=1
			End If
		ElseIf recup2.vushort<recup1.vushort Then
			If 26 And comptype Then
				flag=1
			End If
		ElseIf recup2.vushort=recup1.vushort Then
			If 35 And comptype Then
				flag=1
			End If
		End If
		
	Case 1 'integer32/long
		If recup2.vinteger>recup1.vinteger Then
			If 21 And comptype Then
				flag=1
			End If
		ElseIf recup2.vinteger<recup1.vinteger Then
			If 26 And comptype Then
				flag=1
			End If
		ElseIf recup2.vinteger=recup1.vinteger Then
			If 35 And comptype Then
				flag=1
			End If
		End If
		
	Case 8 'uinteger32/ulong
		If recup2.vuinteger>recup1.vuinteger Then
			If 21 And comptype Then
				flag=1
			End If
		ElseIf recup2.vuinteger<recup1.vuinteger Then
			If 26 And comptype Then
				flag=1
			End If
		ElseIf recup2.vuinteger=recup1.vuinteger Then
			If 35 And comptype Then
				flag=1
			End If
		End If
		
	Case 9 'integer64/longint
		If recup2.vlongint>recup1.vlongint Then
			If 21 And comptype Then
				flag=1
			End If
		ElseIf recup2.vlongint<recup1.vlongint Then
			If 26 And comptype Then
				flag=1
			End If
		ElseIf recup2.vlongint=recup1.vlongint Then
			If 35 And comptype Then
				flag=1
			End If
		End If
	Case 10 'uinteger64/ulonginit
		If recup2.vulongint>recup1.vulongint Then
			If 21 And comptype Then
				flag=1
			End If
		ElseIf recup2.vulongint<recup1.vulongint Then
			If 26 And comptype Then
				flag=1
			End If
		ElseIf recup2.vulongint=recup1.vulongint Then
			If 35 And comptype Then
				flag=1
			End If
		End If
	Case 11 'single
		If recup2.vsingle>recup1.vsingle Then
			If 21 And comptype Then
				flag=1
			End If
		ElseIf recup2.vsingle<recup1.vsingle Then
			If 26 And comptype Then
				flag=1
			End If
		ElseIf recup2.vsingle=recup1.vsingle Then
			If 35 And comptype Then
				flag=1
			End If
		End If
		
	Case 12 'double
		If recup2.vdouble>recup1.vdouble Then
			If 21 And comptype Then
				flag=1
			End If
		ElseIf recup2.vdouble<recup1.vdouble Then
			If 26 And comptype Then
				flag=1
			End If
		ElseIf recup2.vdouble=recup1.vdouble Then
			If 35 And comptype Then
				flag=1
			End If
		End If
		''strings not yet handled
		'Case 4,13,14
		'If brkv.typ=13 Then  ' normal string
		'ReadProcessMemory(dbghand,Cast(LPCVOID,brkv.adr),@adr,SizeOf(Integer),0) 'address ptr 25/07/2015 64bit
		'Else
		'adr=brkv.adr
		'End If
		'Clear recup(0),0,26 'max 25 char
		'ReadProcessMemory(dbghand,Cast(LPCVOID,adr),@recup(0),25,0) 'value
		'strg1=*ptrs.pzstring
		'If brkv.ttb=16 Then
		'If brkv.vst<>strg1 Then
		'flag=1
		'EndIf
		'Else
		'If brkv.vst=strg1
		'Then flag=1
		'EndIf
		
	End Select
	Return flag ''0 test false / 1 test true
End Function
'=======================================================================
'' removes all ABP / disables all UBP if necessary
'=======================================================================
Private Sub brk_unset(ubpon As Integer=False)
	If brkv.adr1 Then ''restore by default ABP on all line
		#ifdef __FB_WIN32__
			set_cc()
		#else
			If ccstate=KCC_NONE Then
				msgdata=1 ''restore breakcpu everywhere
				exec_order(KPT_CCALL)
			End If
		#endif
	Else
		'dbg_prt2 "in brk_unset restoring all instructions"
		
		#ifdef __FB_WIN32__
			For j As Integer = 1 To linenb 'restore all instructions
				'If proc(rline(j).px).nu=-1 Then dbg_prt2 "brk_unset =-1"
				'If proc(rline(j).px).nm="main" or proc(rline(j).px).nm="MAIN" then
				'dbg_prt2 "set only main=";hex(rline(j).ad)
				WriteProcessMemory(dbghand,Cast(LPVOID,rline(j).ad),@rline(j).sv,1,0)
				'sleep 500
				'EndIf
				
			Next
			ccstate=KCC_NONE
		#else
			If ccstate=KCC_ALL Then
				msgdata=0 ''restore sv everywhere
				exec_order(KPT_CCALL)
			End If
		#EndIf
		
		
		
		
		For jbrk As Integer = 1 To brknb ''restore if needed the UBP
			If brkol(jbrk).typ<50 Then
				If ubpon=True Then
					WriteProcessMemory(dbghand,Cast(LPVOID,brkol(jbrk).ad),@breakcpu,1,0) ''only BP enabled
				Else
					brkol(jbrk).typ+=50 ''disable all UBP
					brk_marker(jbrk)
				End If
			End If
		Next
		If brkol(0).typ<>0 Then
			'dbg_prt2 "put CC on line ad=";hex(brkol(0).ad)
			WriteProcessMemory(dbghand,Cast(LPVOID,brkol(0).ad),@breakcpu,1,0)
		End If
	End If
End Sub
'============================================================================
''fills array listitem()
'============================================================================
Private Sub brc_fill(parent As Integer,hitem As Integer)
	Dim As Integer child
	'While hitem<>0
	'	listcpt+=1
	'	listitem(listcpt).items=hitem
	'	listitem(listcpt).itemc=AddTreeViewItem(GTVIEWBRC,GetTextTreeView(GTVIEWVAR,hitem),Cast (HICON, 0),0,TVI_LAST,parent)
	'	child=GetChildItemTreeView(GTVIEWVAR,hitem)
	'	If child<>0 Then
	'		brc_fill(listitem(listcpt).itemc,child)
	'	EndIf
	'    hitem=GetNextItemTreeView(GTVIEWVAR,hitem)
	'Wend
End Sub
'============================================================================
''prepares for listing all the existing variables/fields for cond BP
'============================================================================
Private Sub brc_fillinit()
	Dim As Integer hitem
	'DeleteTreeViewItemAll(GTVIEWBRC)
	'hitem=getfirstitemtreeview(GTVIEWVAR)
	listcpt=-1
	brc_fill(0,hitem)
End Sub
'====================================================
'' handles cond BP
'====================================================
Private Sub brc_choice()
	'Dim As Integer cln=line_cursor() 'get line
	'Dim As Integer rln=line_exec(cln,"Break point Not possible")
	'Dim As Integer ibrk,typ
	'For ibrk=1 To brknb 'search if still put on this line
	'	If brkol(ibrk).nline=cln And brkol(ibrk).isrc=srcdisplayed Then Exit For
	'Next
	'If ibrk<=brknb Then ''existing
	'	typ=brkol(ibrk).typ
	'	brk_del(ibrk)
	'	If typ=2 Or typ=3 Then
	'		Exit Sub
	'	EndIf
	'End If
	'brc_fillinit()
	'varfind.ad=0
	'setgadgettext(GBRCVAR1,"?")
	'setgadgettext(GBRCVALUE,"0")
	'SetItemComboBox(GBRKVCOND,0)
	'hidewindow(hbpcondbx,KSHOW)
End Sub
'====================================================
'' checks if variable selected for cond BP is ok
'====================================================
Private Sub brc_check()
	'Dim As Integer hitem=getitemtreeview(GTVIEWBRC),items
	'For ilist As Integer = 0 To listcpt
	'	If hitem=listitem(ilist).itemc Then
	'		items=listitem(ilist).items
	'		For ivrr As Integer = 1 To vrrnb
	'			If vrr(ivrr).tv=items Then
	'				If vrr(ivrr).vr=0 Then Exit Sub
	'				brkidx1=ivrr
	'				brkidx2=0
	'				var_fill(brkidx1)
	'				#Ifdef __FB_64BIT__
	'				If varfind.pt Then varfind.ty=9 ''pointer integer64 (longint)
	'				#Else
	'				If varfind.pt Then varfind.ty=1 ''pointer integer32 (long)
	'				#EndIf
	'				If varfind.ty>12 Then
	'					messbox("Break on var selection error","Only [unsigned] Byte, Short, integer, longint, single, double")
	'					brkidx1=0
	'					brkidx2=0
	'					Exit Sub
	'				End If
	'				SetGadgetText(GBRCVAR1,varfind.nm)
	'			EndIf
	'		Next
	'		Exit For
	'	EndIf
	'Next
End Sub
'=======================================================================
'' t 1=permanent breakpoint / 2(var/const)-3(var-var)=conditionnal (on a line + condition) / 4=breakpoint with counter /
''   5=tempo / 6=disable-enable / 7=change value counter / 8 reset to initial value / 9=cursor line / over =10 / 11=end of proc / 12=end of prog
'=======================================================================
'Private Sub brk_set(t As Integer)
'	Dim As Integer cln,rln,ibrk
'	Dim As String inputval
'
'	'cln=line_cursor() 'get line
'
'	Select Case t
'
'	Case 9 ''to cursor
'		rln=line_exec(cln,"Run to cursor not possible, select an executable line")
'		If rln=-1 Then Exit Sub
'		For ibrk As Integer	=1 To brknb
'			If rline(rln).ad=brkol(ibrk).ad Then
'				messbox("Run to cursor","Impossible as a breakpoint is already set on this line")
'				Exit Sub
'			EndIf
'		Next
'		If linecur=cln And srcdisplayed=srccur Then
'			If messbox("Run to cursor","Same line, continue ?",MB_YESNO)=IDNO Then Exit Sub
'		End If
'		If brkol(0).typ<>0 Then ''cancel previous run to xxx (eg run to cursor stopped by a BPP then run to end of prog)
'			brk_del(0)
'		EndIf
'		brkol(0).ad=rline(rln).ad
'		brkol(0).typ=9
'		brkol(0).index=rln
'		brkol(0).isrc=srcdisplayed
'		runtype=RTRUN
'		but_enable()
'		brkol(0).nline=cln
'		brk_marker(0)
'		brk_unset(True) ''remove ABP + keep UBP or disable them ?
'		resume_exec()
'
'	Case 10 ''Skip current line / step over
'		rln=rlinecur
'		For j As Integer =1 To procnb
'			If rline(rln).ad=proc(j).fn Then
'				messbox("Skip line not possible","Last line of proc")
'				Exit Sub
'			End If
'		Next
'		If brkol(0).typ<>0 Then
'			brk_del(0)
'		End If
'		rln+=1
'		brkol(0).ad=rline(rln).ad ''address of next line
'		brkol(0).index=rln
'		brkol(0).isrc=srcdisplayed
'		brkol(0).typ=10
'		runtype=RTRUN
'		but_enable()
'		brkol(0).nline=rline(rln).nu
'		'dbg_prt2 "skipping line=";rline(rln).nu,rline(rln).ad
'		brk_marker(0)
'		brk_unset(True) ''remove ABP + keep UBP or disable them ?
'		resume_exec()
'
'	Case 11 '' run until end of proc  = EOP
'		''todo add test if proc is disabled then messbox("End of proc","procedure disabled":exit sub
'		If brkol(0).typ<>0 Then
'			brk_del(0)
'		End If
'		rln=rlinecur
'		brkol(0).ad=proc(rline(rln).px).fn ''last executable line of proc
'		For rln=1 To linenb
'			If rline(rln).ad=brkol(0).ad Then Exit For ''find correponding line
'		Next
'		brkol(0).index=rln
'		brkol(0).isrc=srcdisplayed
'		brkol(0).typ=11
'		runtype=RTRUN
'		but_enable()
'		brkol(0).nline=rline(rln).nu
'		brk_marker(0)
'		brk_unset(True) ''remove ABP + keep UBP or disable them ?
'		resume_exec()
'
'	Case 12 '' run until exit of prog  = XOP
'		If brkol(0).typ<>0 Then
'			brk_del(0)
'		End If
'		 ''BP on ret never reached as there is call to fb_end that doesn't return (a call to Exit)
'		brkol(0).ad=proc(procmain).ed-1
'		brkol(0).typ=12
'		runtype=RTRUN
'		but_enable()
'		brk_unset(True) ''remove ABP + keep UBP
'		resume_exec() ''prepare single step then resume
'
'	Case Else
'		rln=line_exec(cln,"Break point Not possible")
'		If rln=-1 Then Exit Sub
'
'		For ibrk=1 To brknb 'search if still put on this line
'			If brkol(ibrk).nline=cln And brkol(ibrk).isrc=srcdisplayed Then Exit For
'		Next
'		If ibrk>brknb Then 'not put
'			If brknb=BRKMAX Then messbox("Max of brk reached ("+Str(BRKMAX)+")","Delete one and retry"):Exit Sub
'			If t=6 Then Exit Sub
'			brknb+=1
'			brkol(brknb).nline=cln
'			brkol(brknb).typ=t
'			brkol(brknb).index=rln
'			brkol(brknb).isrc=srcdisplayed
'			brkol(brknb).ad=rline(rln).ad
'			brkol(brknb).cntrsav=0
'			brkol(brknb).counter=0
'
'			Select Case t
'				Case 2
'					brkol(brknb).adrvar1=brkadr1
'					brkol(brknb).ivar1=brkidx1
'					If brkdatatype=11 Then
'						brkol(brknb).val.vsingle=brkdata2.vsingle
'					Else
'						'' integer (whole) or double number
'						brkol(brknb).val.vlongint=brkdata2.vlongint
'					End If
'					brkol(brknb).ttb=brkttb
'					brkol(brknb).datatype=brkdatatype
'					brktyp=0
'					modify_menu(MNSETBRKC,HMenusource,"Set/Clear [Ctrl + C]onditionnal Breakpoint")
'					brkidx1=0
'				Case 3
'					brkol(brknb).adrvar1=brkadr1
'					brkol(brknb).ivar1=brkidx1
'					brkol(brknb).adrvar2=brkadr2
'					brkol(brknb).ivar2=brkidx2
'					brkol(brknb).ttb=brkttb
'					brkol(brknb).datatype=brkdatatype
'					brktyp=0
'					modify_menu(MNSETBRKC,HMenusource,"Set/Clear [Ctrl + C]onditionnal Breakpoint")
'					brkidx1=0
'				Case 4 'define value counter
'					inputval=input_bx("breakpoint with a counter","Set value counter for a breakpoint","0",7)
'					brkol(brknb).counter=ValUInt(inputval)
'					If brkol(brknb).counter=0 Then
'						messbox("Counter BP","Value = zero --> not created")
'						brknb-=1
'						Exit Sub
'					EndIf
'					brkol(brknb).cntrsav=brkol(brknb).counter
'			End Select
'		Else 'still put
'			If t=7 Then 'change value counter
'				If  brkol(ibrk).cntrsav Then
'					inputval=input_bx("Change value counter, remaining = "+Str(brkol(ibrk).counter)," initial = "+Str(brkol(ibrk).cntrsav),,7)
'					brkol(ibrk).counter=ValUInt(inputval)
'					If brkol(brknb).counter=0 Then
'						brkol(ibrk).counter=brkol(ibrk).cntrsav
'						messbox("Change counter","Value = zero, enter another value or delete BP")
'						Exit Sub
'					EndIf
'					brkol(ibrk).cntrsav=brkol(ibrk).counter
'				Else
'					messbox("Change counter","No counter for this breakpoint")
'				End If
'			ElseIf t=8 Then 'reset to initial value
'				If brkol(ibrk).cntrsav Then
'					brkol(ibrk).counter=brkol(ibrk).cntrsav
'				Else
'					messbox("Reset counter","No counter for this breakpoint")
'				EndIf
'			ElseIf t=6 Then 'toggle enabled/disabled
'				If brkol(ibrk).typ>50 Then
'					brkol(ibrk).typ-=50
'				Else
'					brkol(ibrk).typ+=50
'				EndIf
'			ElseIf t=brkol(ibrk).typ OrElse (t<>1 And t<>6) Then 'brkol(i).typ>1 Then 'cancel breakpoint
'				brk_del(ibrk)
'				Exit Sub
'			Else 'change type of breakpoint to only permanent/temporary
'				brkol(ibrk).typ=t
'				brkol(ibrk).cntrsav=0
'			End If
'		End If
'
'		brk_marker(ibrk)
'
'	   If brknb=1 Then
'			'SetStateMenu(HMenusource,MNMNGBRK,0)
'			'DisableGadget(IDBUTBRKB,0)
'	   EndIf
'	'End If
'	End Select
'End Sub
'========================================================
'' displays the breakpoint data
'========================================================
Private Sub brk_manage(title As String)
	Dim As String text
	Dim As Integer srcprev=srcdisplayed,typ,cpt
	
	For ibrk As Integer =1 To brknb
		'source_change(brkol(ibrk).isrc)
		'text=line_text(brkol(ibrk).nline-1)
		
		text=" "+source_name(source(brkol(ibrk).isrc))+" ["+Str(brkol(ibrk).nline)+"]"
		If brkol(ibrk).typ=4 Then
			text+=" cntr="+Str(brkol(ibrk).counter)+"/"+Str(brkol(ibrk).cntrsav)
			'hidegadget(GBRKRST01+ibrk-1,KSHOW)
			'hidegadget(GBRKCHG01+ibrk-1,KSHOW)
		Else
			'hidegadget(GBRKRST01+ibrk-1,KHIDE)
			'hidegadget(GBRKCHG01+ibrk-1,KHIDE)
		End If
		'text+=" >> "+Left(Trim(line_text(brkol(ibrk).nline-1),Any Chr(9)+" "),65)
		cpt+=1
		brkline(cpt)=brkol(ibrk).index
		'SetGadgetText(GBRKLINE01+ibrk-1,text)
		'hidegadget(GBRKLINE01+ibrk-1,KSHOW)
		
		'hidegadget(GBRKDEL01+ibrk-1,KSHOW)
		
		typ=brkol(ibrk).typ
		If typ>50 Then
			text="ENB"
			typ-=50
		Else
			text="DSB"
		End If
		'SetGadgetText(GBRKDSB01+ibrk-1,text)
		'hidegadget(GBRKDSB01+ibrk-1,KSHOW)
		Select Case typ
		Case 1
			'SetImageGadget(GBRKIMG01+ibrk-1,catch_image(butBRKP))
		Case 2,3
			'SetImageGadget(GBRKIMG01+ibrk-1,catch_image(butBRKC))
		Case 4
			'SetImageGadget(GBRKIMG01+ibrk-1,catch_image(butBRKN))
		Case 5
			'SetImageGadget(GBRKIMG01+ibrk-1,catch_image(butBRKT))
		End Select
		'hidegadget(GBRKIMG01+ibrk-1,KSHOW)
	Next
	''hides the last lines
	For ibrk As Integer =brknb+1 To 10
		'hidegadget(GBRKIMG01+ibrk-1,KHIDE)
		'hidegadget(GBRKLINE01+ibrk-1,KHIDE)
		'hidegadget(GBRKDSB01+ibrk-1,KHIDE)
		'hidegadget(GBRKDEL01+ibrk-1,KHIDE)
		'hidegadget(GBRKRST01+ibrk-1,KHIDE)
		'hidegadget(GBRKCHG01+ibrk-1,KHIDE)
	Next
	'SetWindowText(hbrkbx,StrPtr(title))
	'hidewindow(hbrkbx,KSHOW)
	bpbox=True
End Sub

'=======================================================================
'' puts the intruction breakcpu at the beginning of every executable line
'=======================================================================
Private Sub put_breakcpu(beginline As Integer=1)
	For iline As Integer=beginline To linenb
		ReadProcessMemory(dbghand,Cast(LPCVOID,rline(iline).ad),@rline(iline).sv,1,0) 'sav 1 byte before writing breakcpu
		WriteProcessMemory(dbghand,Cast(LPVOID,rline(iline).ad),@breakcpu,1,0)
	Next
	ccstate=KCC_ALL
End Sub
'===================================================
'' initializes for the current debuggee
'===================================================
Private Sub init_debuggee(srcstart As Integer)
	''end of extraction ''todo add that for linux when the exe is running
	'dbg_prt2 "in init_debuggee"
	Dim As Integer listidx
	globals_load()
	If procrnb=0 Then
		If flagwtch=0 AndAlso wtchexe(0,0)<>"" Then watch_check(wtchexe())
		flagwtch=0
	End If
	'list_all() ''list all the debug data
	
	'listidx = srclistfirst
	'While listidx <>-1
	'	'AddComboBoxItem(GFILELIST,srcname(listidx-1),-1)
	'	listidx = srclist(listidx).child
	'Wend
	
	
	#Ifdef __FB_WIN32__
		put_breakcpu()
	#endif
	''srcstart contains the index for starting the loading of source codes
	'sources_load(srcstart,FileDateTime(exename))
	'activate buttons/menu after real start
	'but_enable()
	'menu_enable()
	'shortcut_enable()
	'apply previous breakpoints
	brk_apply()
End Sub
'===================================================
'' Unloads dll elements
'===================================================
Private Sub dll_unload(idll As Integer)
	Dim As Integer ibr=1
	For ipr As Integer =2 To procrnb
		If procr(ipr).tv=dlldata(idll).tv Then
			proc_del(ipr,2) ' 'delete procr().tv
			Exit For
		End If
	Next
	
	''delete brkpoint but before trying to save it in brkexe
	While ibr<=brknb
		If brkol(ibr).index>=dlldata(idll).lnb AndAlso brkol(ibr).index<=dlldata(idll).lnn Then 'inside rline of dll
			'create in brkexe for use in next dll loading
			For n As Integer = BRKMAX To 1 Step-1 'search by the last slot, later if there are BRKMAX brkpt this one will be lost
				If brkexe(0,n)="" Then 'find an empty slot if not data is lost
					brkexe(0,n)=source_name(source(brkol(ibr).isrc))+","+Str(brkol(ibr).nline)+","+Str(brkol(ibr).typ)
				End If
				Exit For
			Next
			brk_del(ibr)
		End If
		ibr+=1
	Wend
End Sub
'===========================================
''handles other exceptions than breakpoint
'===========================================
Private Sub exception_handle(adr As Integer)
	Dim As String linetext
	'gest_brk(rline(thread(threadcur).sv).ad)
	gest_brk(adr)
	'source_change(rline(thread(threadcur).sv).sx) 'display source
	'line_display(rline(thread(threadcur).sv).nu)
	'linetext=line_text(rline(thread(threadcur).sv).nu-1)
	'case error inside proc initialisation (e.g. stack over flow)
	If adr>rline(thread(threadcur).sv).ad And _
		adr<rline(thread(threadcur).sv+1).ad And _
		rline(thread(threadcur).sv+1).nu=rline(thread(threadcur).sv).nu Then
		libelexception+="ERROR AT BEGINNING OF PROC NOT REALLY ON THIS LINE"+Chr(13)+ _
		"CHECK DIM (e.g. width array to big), Preferably don't continue"+Chr(13)+Chr(13)
	Else
		libelexception+="Possible error on this line but not SURE"+Chr(13)+Chr(13)
	End If
	
	libelexception+="File  : "+source(rline(thread(threadcur).sv).sx)+Chr(13)+ _
	"Proc  : "+proc(rline(thread(threadcur).sv).px).nm+Chr(13)+ _
	"Line  : "+Str(rline(thread(threadcur).sv).nu)+" (selected and put in red)"+Chr(13)+ _
	linetext+Chr(13)+Chr(13)+"Try To continue ? (if yes change values and/or use [M]odify execution)"
	debugdata = MsgBox("EXCEPTION: " & libelexception)  ''used in thread2
End Sub
'===================================================
'' handles the debug events  (triggered by timer)
'===================================================
Private Function debug_event() As Integer
	Dim As Integer dbgevent=debugevent
	Static As Integer thprev
	debugevent=KDBGNOTHING
	If dbgevent = KDBGNOTHING And multiaction = KMULTINOTHING Then Return True
	'dbg_prt2 "************ debug_event ";time;" ";dbgevent;" ";hex(debugdata);" stopcode=";stoplibel(stopcode)
	Select case As Const dbgevent
	case KDBGRKPOINT
		
		'dbg_prt2 "KDBGRKPOINT=";stopcode,"csline=";CSLINE,hex(debugdata)
		If stopcode=CSSTEP OrElse stopcode=CSMEM OrElse stopcode=CSVAR OrElse stopcode=CSUSER OrElse stopcode=CSNEWTHRD Then
			gest_brk(debugdata)
		Else
			gest_brk(brkol(debugdata).ad,brkol(debugdata).index) ''address and line index
		End If
		
	case KDBGCREATEPROCESS
		srcstart=sourcenb+1
		#Ifdef __FB_WIN32__
			If debug_extract(debugdata,exename)=0 Then ''otherwise there is a problem (no debug data or when reading debuggee memory)
				init_debuggee(srcstart)
			Else
				TerminateProcess(dbghand,89)
			End If
		#else
			If elf_extract(exename) = -1 Then
				MsgBox("Loading error","Killing process")
				exec_order(KPT_KILL)
			End If
			
			MutexLock blocker
			bool2=True
			CondSignal(condid)
			MutexUnlock blocker
		#endif
		
	case KDBGCREATETHREAD
		#Ifdef __FB_LINUX__
			''Linux creation fo a new thread
			Var ret = MsgBox("New Thread", "Thread created = " + Str(thread(threadnb).id) + " / current = " + Str(thread(threadcur).id) _
			+ Chr(10) + Chr(13) + " Continue with new one or with current ?" , btYesNo)
			If ret = mrYes Then
				msgdata=1
				'thread_change(threadnb)
			ElseIf ret=mrNo Then
				msgdata=0
			Else
				msgdata=2
			End If
			MutexLock blocker
			bool2=True
			CondSignal(condid)
			MutexUnlock blocker
		#endif
		
	case KDBGEXITPROCESS
		process_terminated()
		
	case KDBGEXITTHREAD
		thread_del(debugdata)
		#Ifdef __FB_LINUX__
			msgcmd=0 ''no action
			MutexLock blocker
			bool2=True
			CondSignal(condid)
			MutexUnlock blocker
		#endif
		
	case KDBGDLL
		#Ifdef __FB_WIN32__
			dll_load()
		#else
			MsgBox("Linux dll", "nedd to be coded")
		#endif
	case KDBGDLLUNLOAD
		dll_unload(debugdata)
		
	case KDBGEXCEPT
		exception_handle(debugdata)
		
		''Case KDBGSTRING not used
		
		'Case else
		'messbox("Handling debug event","Debug event unkown, not handled ="+str(debugevent))
	End Select
	#Ifdef __FB_WIN32__
		'dbg_prt2 "MutexunLock DBGEVENT"
		MutexUnlock blocker ''release second thread
		'dbg_prt2 "MutexLock DBGEVENT"
		MutexLock   blocker ''lock for next event
	#endif
	If multiaction=KMULTISTEP Then
		If prolog=1 Then
			dbg_prt2 "waiting next" ':sleep 1000
			Return True
		End If
		
		dbg_prt2 "multiaction";threadlistidx,thread_index(threadlist(threadlistidx))
		thread_resume(thread_index(threadlist(threadlistidx)))
		threadlistidx-=1
		If threadlistidx=-1 Then ''or zero ??
			multiaction=KMULTINOTHING
		End If
	End If
	Return True
End Function
'==================================================================
Private Sub attach_ok()
	If dbgprocid<>0 Then
		reinit()
		SetTimer(hmain,GTIMER001,100,Cast(Any Ptr,@debug_event))
		ThreadCreate(@attach_debuggee)
	End If
	'freegadget(GATTCHEDIT)
	'freegadget(GATTCHTXT)
	'freegadget(GATTCHGET)
	'freegadget(GATTCHOK)
	'close_window(hattachbx)
End Sub
'===================================================
''launch by command line
'===================================================
Private Sub external_launch()
	
	Dim As String debuggee=Command(1)
	Dim As String cmdline=Mid(Command(),Len(debuggee)+2)
	
	If debuggee="" Then Exit Sub ''no debuggee
	
	If InStr(debuggee,Slash)=0 Then debuggee=ExePath+Slash+debuggee ''debugge without path so exepath added
	If Dir(debuggee)="" Then
		MsgBox("File as parameter", "File =" + debuggee+ " doesn't exist")
		Exit Sub
	End If
	
	If check_bitness(debuggee)=0 Then Exit Sub ''bitness of debuggee and fbdebugger not corresponding
	
	exename=debuggee
	'exe_sav(exename,cmdline)
	SetTimer(hmain,GTIMER001,100,Cast(Any Ptr,@debug_event))
	
	If ThreadCreate(@start_pgm)=0 Then
		KillTimer(hmain,GTIMER001)
		MsgBox("Debuggee not running", "ERROR unable to start the thread managing the debuggee")
	End If
End Sub
'===================================================================================
''real restart after killing debuggee if needed
'===================================================================================
Private Sub restart_exe(ByVal idx As Integer)
	''todo maybe cmdline changed so need to be saved
	If idx=0 Then
		Dim As Double dtempo=FileDateTime(exename)
		If exedate=0 Then
			exedate=dtempo
		ElseIf exedate=dtempo Then
			flagrestart=sourcenb ''exe not changed so no need to reload sources
		Else
			flagrestart=-1 ''need to reload sources
		End If
		If wtchcpt Then flagwtch=1
	Else
		'exename=savexe(idx)
		'exe_sav(exename,cmdexe(idx))
	End If
	
	''todo make a sub and call also in sub external_launch, in select_file
	If check_bitness(exename)=0 Then Exit Sub ''bitness of debuggee and fbdebugger not corresponding
	
	reinit() ''all except GUI parts
	'settitle()
	
	SetTimer(hmain,GTIMER001,100,Cast(Any Ptr,@debug_event))
	
	If ThreadCreate(@start_pgm)=0 Then
		KillTimer(hmain,GTIMER001)
		MsgBox("Debuggee not running", "ERROR unable to start the thread managing the debuggee")
	End If
	
End Sub
'==================================================================================
'' Debuggee restarted, last debugged (using IDBUTRERUN) or one of the 9/10 others
'==================================================================================
Private Sub restart(ByVal idx As Integer=0)
	If prun Then
		#Ifndef __FB_WIN32__
			afterkilled = KRESTART + idx
		#EndIf
		If kill_process("Trying to launch but debuggee still running")=False Then
			dbg_prt2 "in restart false ?????"
			Exit Sub
		End If
		'else
		'restart_exe(idx)
		brk_sav()
	End If
	restart_exe(idx)
End Sub
'============================================
''changes the displayed source
'============================================
Private Sub source_change(numb As Integer)
	Static As Integer numbold = -1
	If numb = -1 Then
		numbold=-1 ''reinit
		Exit Sub
	EndIf
	If numb = numbold Then Exit Sub
	numbold = numb
	'ptrdoc=Cast(Any Ptr,send_sci(SCI_GETDOCPOINTER,0,0))
	'send_sci(SCI_ADDREFDOCUMENT,0,ptrdoc)
	'send_sci(SCI_SETDOCPOINTER,0,sourceptr(numb))
	srcdisplayed = numb
	'SetGadgetText(GSRCCURRENT,">> "+srcname(srcdisplayed))
	'Var cpt=0
	'Var idx=srclistfirst
	'Do Until idx=numb+1
	'	idx=srclist(idx).child
	'	cpt+=1
	'	If cpt>sourcenb Then Exit Do
	'Loop
	'SetItemComboBox(GFILELIST,cpt)
	'srccombocur=cpt
End Sub
'=======================================================================================
'' return line where is the cursor  scintilla first line=0 --> rline=1 so 1 is added
'=======================================================================================
Private Function line_cursor() As Integer
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	Dim As Integer FSelStartLine, FSelEndLine, FSelStartChar, FSelEndChar
	If tb <> 0 Then
		tb->txtCode.GetSelection FSelStartLine, FSelEndLine, FSelStartChar, FSelEndChar
	End If
	Return FSelEndLine
End Function
'===================================================================================
'' check if the line is executable return -1 if false otherwise the rline index
'===================================================================================
Private Function line_exec(pline As Integer,msg As String)As Integer
	For iline As Integer =1 To linenb
		If rline(iline).nu=pline AndAlso rline(iline).sx=srcdisplayed Then
			For jproc As Integer =1 To procnb
				If rline(iline).ad=proc(jproc).db Then
					MsgBox(msg, "Line not executable")
					Return -1
				End If
			Next
			Return iline
		End If
	Next
	MsgBox(msg, "Line not executable")
	Return -1
End Function
'==========================================================
'' displays line
'==========================================================
Private Sub line_display(pline As Integer,highlight As Integer=0)
	SelectError source(srcdisplayed), pline
	'send_sci(SCI_SETFIRSTVISIBLELINE, pline-1,0)
	'If pline-send_sci(SCI_GETFIRSTVISIBLELINE,0,0)+5>send_sci(SCI_LINESONSCREEN,0,0) Then
	'	send_sci(SCI_LINESCROLL,0,+5)
	'Else
	'	send_sci(SCI_LINESCROLL,0,-5)
	'End If
	'If highlight=1 Then
	'	send_sci( SCI_SETSEL, send_sci( SCI_POSITIONFROMLINE, pline-1 , 0 ), send_sci( SCI_GETLINEENDPOSITION, pline-1 , 0 ) )
	'EndIf
End Sub
'==========================================================
'' displays line current
'==========================================================
Private Sub linecur_display()
	source_change(srccur)
	line_display(linecur)
End Sub
'=========================================================
'' selects the text of line
'=========================================================
Private Function line_text(pline As Integer)As String
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	Dim As Integer FSelStartLine, FSelEndLine, FSelStartChar, FSelEndChar
	If tb <> 0 Then
		tb->txtCode.GetSelection FSelStartLine, FSelEndLine, FSelStartChar, FSelEndChar
		tb->txtCode.Lines(FSelEndLine)
	End If
	Return ""
End Function
'==========================================================
'' changes current line after restoring previous one
'==========================================================
Private Sub linecur_change(linenew As Integer)
	If srccur<>srcdisplayed Then
		'send_sci(SCI_ADDREFDOCUMENT,0,sourceptr(srcdisplayed))
		'send_sci(SCI_SETDOCPOINTER,0,sourceptr(srccur))
		srcdisplayed=srccur
	End If
	'line_color(linecur,KSTYLENONE)
	If rline(linenew).sx<>srcdisplayed Then
		srccur=rline(linenew).sx
		'send_sci(SCI_ADDREFDOCUMENT,0,sourceptr(srcdisplayed))
		'send_sci(SCI_SETDOCPOINTER,0,sourceptr(srccur))
		srcdisplayed=srccur
	End If
	linecur=rline(linenew).nu
	linecur_display()
	'line_color(linecur,KSTYLECUR)
	
	'' display in current line gadget removing all left spaces/tabs
	'setgadgettext(GCURRENTLINE,"Current line : "+Left(Trim(line_text(linecur-1),Any " "+Chr(9)),50))
End Sub
'=================================================================================
'' changes address of execution (forward or backward) only in the same procedure
'==================================================================================
Private Sub exec_mod() 'execution from cursor
	#Ifdef __FB_WIN32__
		Dim As Integer dummy ''used to align vcontext on 16 bytes
		Dim vcontext As CONTEXT
		vcontext.ContextFlags=CONTEXT_CONTROL
	#endif
	Dim cln As Integer,rln As Integer',b As Integer
	
	cln=line_cursor() 'get line
	rln=line_exec(cln,"Changing next executed line not possible, select an executable line")
	'dbg_prt2 "cln rln=";cln,rln,rline(rln).nu
	If rln=-1 Then Exit Sub
	
	'If rline(rln+1).nu=cln+1 And rline(rln+1).sx=srcdisplayed Then rln+=1 ''weird case : first line main proc
	
	If rln=rlinecur Then Exit Sub ''same line
	
	'If linecur=l+1 And srcdisplayed=srccur Then
	'If messbox("Execution on cursor","Same line, continue ?",MB_YESNO)=IDNO Then
	'Exit Sub
	'EndIf
	'End If
	
	'check inside same proc if not msg
	If rline(rln).ad>proc(procsv).fn Or rline(rln).ad<=proc(procsv).db Then
		MsgBox("Changing next executed line", "Not possible : only inside the current procedure")
		Exit Sub
	End If
	If rline(rln).ad=proc(procsv).fn Then
		thread(threadcur).pe=True        'is last instruction
	End If
	'WriteProcessMemory(dbghand,Cast(LPVOID,rLine(thread(threadcur).sv).ad),@breakcpu,1,0) 'restore CC previous line
	'WriteProcessMemory(dbghand,Cast(LPVOID,rLine(i).ad),@rLine(i).sv,1,0) 'restore old value for execution
	thread(threadcur).od=thread(threadcur).sv:thread(threadcur).sv=rln
	'get and update registers
	#Ifdef __FB_WIN32__
		GetThreadContext(threadhs,@vcontext)
		vcontext.regip=rline(rln).ad
		SetThreadContext(threadhs,@vcontext)
	#else
		'dbg_prt2 "changing exec=";hex(rline(rln).ad),rline(rln).nu
		MutexLock blocker
		msgad=rline(rln).ad
		msgcmd=KPT_XIP
		bool2=True
		CondSignal(condid)
		While bool1<>True
			CondWait(condid,blocker)
		Wend
		bool1=False
		MutexUnlock blocker
	#endif
	'dsp_change(rln)
	linecur_change(rln)
	rlinecur=rln
End Sub
'=========================================================================
'' display variable, field in treeviewvar based on word under the cursor
'=========================================================================
Private Sub var_tip(ope As Integer)
	Dim As Integer i,j,l,d,p
	Dim As String text
	text = line_text(line_cursor()) ''get the text where is the cursor
	text=Space(201)
	Dim As Integer pcursor = 0 'send_sci(SCI_GETCURLINE,200,StrPtr(text))
	
	
	'select only var name characters
	For i =pcursor-1 To 1 Step-1
		Dim c As Integer
		c=Asc(text,i)
		If ( c>=Asc("0") And c<=Asc("9") ) OrElse ( c>=Asc("a") And c<=Asc("z") ) OrElse ( c>=Asc("A") And c<=Asc("Z") ) OrElse c=Asc("_") OrElse c=Asc(".") Then Continue For
		Exit For
	Next
	i+=1
	For j=pcursor To Len(text)
		Dim c As Integer
		c=Asc(text,j)
		If ( c>=Asc("0") And c<=Asc("9") ) OrElse ( c>=Asc("a") And c<=Asc("z") ) OrElse ( c>=Asc("A") And c<=Asc("Z") ) OrElse c=Asc("_") OrElse c=Asc(".") Then Continue For
		Exit For
	Next
	
	If Asc(text,j)<>Asc("(") Then j-=1 'if last character is  a '(' take it in account (case array)
	
	
	If i>j Then
		text=""
	Else
		text=Mid(text,i,j-i+1) 'extract from text
	End If
	
	If text="" Or Left(text,1)="." Then
		MsgBox("Selection variable error", """" + text + """ : Empty string or incomplete name (udt components)")
		Exit Sub
	End If
	text=UCase(text)
	
	'parsing
	Dim vname(10) As String,varray As Integer,vnb As Integer =0
	text+=".":l=Len(text):d=1
	
	While d<l
		vnb+=1
		p=InStr(d,text,".")
		vname(vnb)=Mid(text,d,p-d)
		If Right(vname(vnb),1)="(" Then
			varray=1:vname(vnb)=Mid(text,d,p-d-1):d=p+2 'array
		Else
			varray=0:d=p+1
		End If
	Wend
	
	Dim As Integer nline=line_cursor()+1,lclproc=0,lclprocr=0,idx=-1
	
	For i As Integer =1 To linenb
		If rline(i).nu=nline AndAlso rline(i).sx=srcdisplayed Then 'is executable (known) line ?
			lclproc=rline(i).px
			Exit For ' with known line we know also the proc...
		End If
	Next
	
	'search inside
	'if no lclproc --> should be in main
	If lclproc Then
		For i As Integer =procrnb To 1 Step -1
			If procr(i).idx=lclproc Then
				lclprocr=i
				Exit For ' proc running
			End If
		Next
		'search the variable taking in account name and array or not
		If lclprocr Then
			idx=var_search(lclprocr,vname(),vnb,varray) 'inside proc ?
		End If
	End If
	
	If idx=-1 Then
		idx=var_search(1,vname(),vnb,varray) 'inside main ?
		
		If idx=-1 Then
			'namespace ?
			If vnb>1 Then
				vname(1)+="."+vname(2)
				vnb-=1
				For i As Long =2 To vnb
					vname(i)=vname(i+1)
				Next
				idx=var_search(1,vname(),vnb,varray)
			End If
			If idx=-1 Then
				MsgBox("Selection variable error", """" + Left(text, Len(text) - 1) + """ is not a running variable")
				Exit Sub
			End If
		End If
	End If
	
	'PanelGadgetSetCursel(GRIGHTTABS,TABIDXVAR)
	'SetSelectTreeViewItem(GTVIEWVAR,vrr(idx).tv)
	'ExpandTreeViewItem( GTVIEWVAR , vrr(idx).tv , 0)
End Sub

#ifndef __FB_WIN32__
	#INCLUDE once "crt.bi"
	#INCLUDE once "crt/linux/unistd.bi"
	#INCLUDE once "crt/linux/fcntl.bi"
	
	#define SIGINT 2
	#define SIGILL 4
	#define SIGTRAP 5
	#define SIGABRT 6
	#define SIGKILL 9
	#define SIGSEGV 11
	#define SIGUSR1 10
	#define SIGUSR2 12
	#define SIGTERM 15
	#define SIGCHLD 17
	#define SIGCONT 18
	#define SIGSTOP 19
	'SIGHUP 1
	'SIGINT	     2	Term	Interruption depuis le clavier.
	'SIGQUIT	 3	Core	Demande « Quitter » depuis le clavier.
	'SIGILL	     4	Core	Instruction illégale.
	'SIGABRT	 6	Core	Signal d'arrêt depuis abort(3).
	'SIGFPE	     8	Core	Erreur mathématique virgule flottante.
	'SIGKILL	 9	Term	Signal « KILL ».
	'SIGSEGV	11	Core	Référence mémoire invalide.
	'SIGPIPE	13	Term	Écriture dans un tube sans lecteur.
	'SIGALRM	14	Term	Temporisation alarm(2) écoulée.
	'SIGTERM	15	Term	Signal de fin.
	'Signal	Code	Reason
	'SIGILL	ILL_ILLOPC	Illegal opcode
	'ILL_ILLOPN	Illegal operand (not currently used)
	'ILL_ILLADR	Illegal addressing mode (not currently used)
	'ILL_ILLTRP	Illegal trap (not currently used)
	'ILL_PRVOPC	Privileged opcode; instruction requires privileged CPU mode
	'ILL_PRVREG	Privileged register (not currently used)
	'ILL_COPROC	Coprocessor instruction error
	'ILL_BADSTK	Internal stack error
	'
	'SIGSEGV	SEGV_MAPERR	Address isn't mapped to an object
	'SEGV_ACCERR	The mapping doesn't allow the attempted access
	'
	'SIGTRAP	TRAP_BRKPT	Process breakpoint trap
	'TRAP_TRACE	Process trace trap
	'
	'SIGCHLD
	'CLD_EXITED	   1 Child has exited
	'CLD_KILLED	   2 Child has terminated abnormally and did not create a core file
	'CLD_DUMPED	   3 Child has terminated abnormally and created a core file
	'CLD_TRAPPED   4 Traced child has trapped
	'CLD_STOPPED   5 Child has stopped
	'CLD_CONTINUED 6 Stopped child has continued
	'
	'Signal	Member	Value
	'SIGILL, SIGFPE	void *si_addr	The address of the faulting instruction
	'SIGSEGV, SIGBUS	void *si_addr	The address of the faulting memory reference
	'SIGCHLD	pid_t si_pid	The child process ID
	'int si_status	The exit value or signal
	'uid_t si_uid	The real user ID of the process that sent the signal
	
	#define __WNOHANG		&h00000001
	'#define WUNTRACED	0x00000002
	'#define WSTOPPED	WUNTRACED
	'#define WEXITED		0x00000004
	'#define WCONTINUED	0x00000008
	'#define WNOWAIT		0x01000000	'/* Don't reap, just poll status.  */
	
	'#define __WNOTHREAD	0x20000000	'/* Don't wait on children of other threads in this group */
	#define __WALL		&h40000000	'/* Wait on all children, regardless of type */
	'#define __WCLONE	0x80000000	'/* Wait only on non-SIGCHLD children */
	
	#define SIG_BLOCK 0
	#define SIG_UNBLOCK 1
	#define SIG_SETMASK 2
	
	''todo checking
	''TKILL 64 bit = 200 32bit = 238
	''TGKILL         234         270
	''GETTID		 186         224
	
	#ifdef __FB_64BIT__
		#define SYS_TKILL   238 '?? 200
		#define SYS_TGKILL  234'270
		#define SYS_GETTID  186'224
		#define SYS_SIGPEND 127
	#else
		#define SYS_TKILL  200
		#define SYS_TGKILL 234
		#define SYS_GETTID 186
	#endif
	
	#define SA_SIGINFO	4
	#define   PTRACE_O_TRACESYSGOOD	  &h00000001
	#define   PTRACE_O_TRACEFORK	  &h00000002
	#define   PTRACE_O_TRACEVFORK     &h00000004
	#define   PTRACE_O_TRACECLONE	  &h00000008
	#define   PTRACE_O_TRACEEXEC	  &h00000010
	#define   PTRACE_O_TRACEVFORKDONE &h00000020
	#define   PTRACE_O_TRACEEXIT	  &h00000040
	#define   PTRACE_O_TRACESECCOMP   &h00000080
	#define   PTRACE_O_EXITKILL	      &h00100000
	#define   PTRACE_O_MASK		      &h001000ff
	
	#define   PTRACE_EVENT_CLONE      &h3
	Type tsiginfo
		As Long si_signo, si_code, si_errno
		As Any Ptr si_addr
		'as short si_addr_lsb
		As Long dummy(50)
	End Type
	
	'Type tsiginfo
	'si_signo As long
	'si_errno As long
	'si_code As long
	'Union
	'as byte pad(112)
	'/' kill() '/
	'si_pid As long		/' sender s pid '/
	'si_uid As long		/' sender s uid '/
	'/' SIGCHLD '/
	'_pid As long		/' which child '/
	'_uid As long		/' sender s uid '/
	'_status As long		/' exit code '/
	'_utime As Integer
	'_stime As Integer
	'
	'
	'/' SIGILL, SIGFPE, SIGSEGV, SIGBUS SIGTRAP'/
	'Type
	'_addr As Integer /' faulting insn/memory ref. '/
	'End Type
	''_pad(29) As long '32bit -->29 / 64bit --> 28
	'End Union
	'
	'End Type
	'===============
	'type siginfo
	'
	'as long si_signo, si_code, si_errno
	'union 'si_fields
	'as byte pd(112) ''116 if 32bit
	'union 'first
	'type _piduid
	'as long si_pid,si_uid
	'end type
	'type '_timer
	'as long si_timerid,si_overrun
	'end type
	'end union
	'
	'union 'second
	'union sigval
	'as long sival_int
	'as any ptr sival_ptr
	'end union
	'type
	'as long si_status
	'as longint si_utime,si_stime
	'end type
	'end union
	'
	'type _sigfault
	'as any ptr si_addr
	'as short si_addr_lsb
	'union first
	'type addr_bnd
	'as any ptr si_lower
	'as any ptr si_upper
	'end type
	'as long si_pkey
	'end union
	'end type
	'
	'type sigpoll
	'as clong si_band
	'as long si_fd
	'end type
	'
	'type sigsys
	'as any ptr si_call_addr
	'as long si_syscall
	'as long si_arch
	'end type
	'end union
	'dummy(20) as integer
	'end type
	''=====
	
	'union sigval {
	'int sival_int;
	'void *sival_ptr;
	'};
	'typedef struct {
	'
	'union {
	'char __pad[128 - 2*sizeof(int) - sizeof(long)]; 128 - 8 -8
	'
	'struct {
	'void *si_addr;
	'short si_addr_lsb;
	'union {
	'struct {
	'void *si_lower;
	'void *si_upper;
	'} __addr_bnd;
	'unsigned si_pkey;
	'} __first;
	'} __sigfault;
	'struct {
	'long si_band;
	'int si_fd;
	'} __sigpoll;
	'struct {
	'void *si_call_addr;
	'int si_syscall;
	'unsigned si_arch;
	'} __sigsys;
	'} __si_fields;
	'} siginfo_t;
	
	
	'===============
	Type sigset
		As Long dum(32)
	End Type
	
	Type tsigaction
		Union
			sa_handler As Sub (As Long)
			sa_sigaction As Sub (As Long,As tsiginfo Ptr,As Any Ptr)
		End Union
		sa_mask As sigset'128 bytes long
		sa_flags As Long
		sa_restorer As Sub()
	End Type
	'dbg_prt2 sizeof(sigaction)
	'declare function getpid alias "getpid"() as Integer
	'declare sub execve alias "execve"(as zstring ptr,as zstring ptr,as zstring ptr)
	#undef Wait
	'#undef Kill
	'declare function fork alias "fork"() as Integer
	Declare Function Wait Alias "wait"(As Any Ptr) As Long
	Declare Function waitpid Alias "waitpid"(As Long,As Any Ptr,As Long) As Long
	'declare function pause alias "pause"() as Integer
	
	Declare Function tkill Alias "tkill"(As Integer,As Integer) As Integer
	'declare function syscall cdecl  alias "syscall"(as integer,...) as Integer
	Declare Function signal Alias "signal"(As Integer,As Integer Ptr) As Integer
	
	'declare function perror alias "perror"(as integer)as zstring Ptr
	Declare Sub putbreaks
	'declare function sigpending alias "sigpending" (as any ptr) as Integer
	Declare Function sigprocmask Alias "sigprocmask"(As Integer,As Any Ptr,As Any Ptr) As Integer
	Declare Function sigaction Alias "sigaction"(As Long, As tsigaction Ptr, As tsigaction Ptr) As Integer
	Declare Function sigemptyset   Alias "sigemptyset"(As sigset Ptr) As Long
	Declare Function sigpending  Alias "sigpending"(As sigset Ptr) As Long
	Declare Sub putremove_breaks(ByVal pid As Long,ByVal typ As Integer=1)
	
	Private Sub sig_handler(signum As Long,siginfo As tsiginfo Ptr,dummy As Any Ptr)
		Dim As Integer dta,restall
		dbg_prt2 "stop running debuggee"
		linux_kill(thread(threadcur).id,SIGSTOP)
		Sleep 500 'waiting to be sure debuggee is stopped
		dbg_prt2 "restoring saved byte on every line=",thread(threadcur).id
		putremove_breaks(thread(threadcur).id)
	End Sub
	
	Private Sub sig_init()
		Dim As tsigaction act
		sigemptyset(@act.sa_mask)
		act.sa_flags=SA_SIGINFO
		act.sa_sigaction=@sig_handler()
		dbg_prt2 "sigaction USR";
		sigaction(SIGUSR1,@act,NULL)
		dbg_prt2 "errno=";errno
	End Sub
	
	Const ORIG_RAX =15
	Const RAX   =10
	Const RBX   =5
	Const RCX   =11
	Const RDX   =12
	Const RSI   =13
	Const RDI   =14
	Const SYS_write =1
	/'
	siginfo_t {
	int      si_signo;    /* NumÃ©ro de signal*/
	int      si_errno;    /* NumÃ©ro d'erreur */
	int      si_code;     /* Code du signal  */
	int      si_trapno;   /* NumÃ©ro de trappe qui a causÃ©
	le signal gÃ©nÃ©rÃ© par le
	matÃ©riel (pas utilisÃ© sur la
	plupart des architectures) */
	pid_t    si_pid;      /* PID de l'Ã©metteur          */
	uid_t    si_uid;      /* UID rÃ©el de l'Ã©metteur     */
	int      si_status;   /* Valeur de sortie ou signal */
	clock_t  si_utime;    /* Temps utilisateur Ã©coulÃ©   */
	clock_t  si_stime;    /* Temps systÃ¨me Ã©coulÃ©       */
	sigval_t si_value;    /* Valeur de signal*/
	int      si_int;      /* Signal POSIX.1b */
	void    *si_ptr;      /* Signal POSIX.1b */
	int      si_overrun;  /* DÃ©compte de dÃ©passement des
	horloges (POSIX.1b)        */
	int      si_timerid;  /* ID d'horloge (POSIX.1b)    */
	void    *si_addr;     /* Emplacement mÃ©moire ayant
	causÃ© l'erreur  */
	long     si_band;     /* Band event (Ã©tait int dans
	glibc 2.3.2 et antÃ©rieures */
	int      si_fd;       /* Descripteur de fichier     */
	short    si_addr_lsb; /* Bit le moins significatif de l'adresse
	(depuis Linux 2.6.32)   */
	=============================
	wait() et waitpid()
	L'appel  systÃ¨me  wait()  suspend l'exÃ©cution du processus appelant jusqu'Ã  ce que l'un de
	ses enfants se termine. L'appel wait(&status) est Ã©quivalent Ã  :
	
	waitpid(-1, &status, 0);
	
	L'appel systÃ¨me waitpid() suspend l'exÃ©cution du processus appelant jusqu'Ã  ce qu'un  fils
	spÃ©cifiÃ©  par  l'argument  pid  change d'Ã©tat. Par dÃ©faut, waitpid() n'attend que les fils
	terminÃ©s, mais ce comportement peut Ãªtre modifiÃ©  par  l'argument  options,  de  la  faÃ§on
	dÃ©crite ci-dessous.
	
	La valeur de pid peut Ãªtre l'une des suivantes :
	
	< -1   Attendre la fin de n'importe quel processus fils appartenant au groupe de processus
	d'ID -pid.
	
	-1     Attendre n'importe lequel des processus fils.
	
	0      Attendre la fin de n'importe quel processus fils du mÃªme groupe que l'appelant.
	
	> 0    Attendre la fin du processus numÃ©ro pid.
	
	La valeur de l'argument option options est un OU binaire entre les constantes suivantes :
	
	WNOHANG     Ne pas bloquer si aucun fils ne s'est terminÃ©.
	
	WUNTRACED   Recevoir l'information concernant Ã©galement les fils bloquÃ©s (mais non  suivis
	par  ptrace(2))  si  on  ne  l'a  pas encore reÃ§ue. L'Ã©tat des fils suivis est
	fourni mÃªme sans cette option.
	
	WCONTINUED (Depuis Linux 2.6.10)
	Renvoyer Ã©galement si un processus fils stoppÃ© a Ã©tÃ©  relancÃ©  par  le  signal
	SIGCONT.
	
	(Pour les options spÃ©cifiques Ã  Linux, voir plus bas.)
	
	Si  status n'est pas NULL, wait() et waitpid() stockent l'Ã©tat du fils dans la variable de
	type int pointÃ©e. Cet entier peut Ãªtre Ã©valuÃ© avec  les  macros  suivantes  (qui  prennent
	l'entier  lui-mÃªme  comme argument, et pas un pointeur vers celui-ci, comme le font wait()
	et waitpid() !) :
	
	WIFEXITED(status)
	Vrai si le fils s'est terminÃ© normalement, c'est-Ã -dire par un appel Ã   exit(3)  ou
	_exit(2), ou par un return depuis main().
	
	WEXITSTATUS(status)
	Donne  le  code  de  retour, consistant en les 8 bits de poids faibles du paramÃ¨tre
	status fourni Ã  exit(3) ou _exit(2) ou dans le return de la routine  main().  Cette
	macro ne peut Ãªtre Ã©valuÃ©e que si WIFEXITED est non nul.
	
	WIFSIGNALED(status)
	Vrai si le fils s'est terminÃ© Ã  cause d'un signal non interceptÃ©.
	
	WTERMSIG(status)
	Donne  le  numÃ©ro  du  signal  qui a causÃ© la fin du fils. Cette macro ne peut Ãªtre
	Ã©valuÃ©e que si WIFSIGNALED est non nul.
	
	WCOREDUMP(status)
	Vrai si le processus fils a produit une image mÃ©moire (Â« core dump Â»). Cette  macro
	ne doit Ãªtre Ã©valuÃ©e que si WIFSIGNALED a renvoyÃ© une valeur non nulle.
	
	WIFSTOPPED(status)
	Vrai si le fils est actuellement arrÃªtÃ©. Cela n'est possible que si l'on a effectuÃ©
	l'appel avec l'option WUNTRACED ou si le fils est suivi (voir ptrace(2)).
	
	WSTOPSIG(status)
	Donne  le  numÃ©ro  du  signal qui a causÃ© l'arrÃªt du fils. Cette macro ne peut Ãªtre
	Ã©valuÃ©e que si WIFSTOPPED est non nul.
	
	WIFCONTINUED(status)
	(Depuis Linux 2.6.10) Vrai si le processus fils a Ã©tÃ© relancÃ© par SIGCONT.
	=============================
	* The conditions WIFEXITED, WIFSIGNALED, WIFSTOPPED
	* are mutually exclusive:
	* WIFEXITED:  (status & 0x7f) == 0, WEXITSTATUS: top 8 bits
	* and now WCOREDUMP:  (status & 0x80) != 0
	* WIFSTOPPED: (status & 0xff) == 0x7f, WSTOPSIG: top 8 bits
	* WIFSIGNALED: all other cases, (status & 0x7f) is signal.
	'/
	'#define WEXITSTATUS(status) (((status)  & 0xff00) >> 8) Return exit status.
	#define WEXITSTATUS(status) (((status)  And &hff00) Shr 8)
	
	'#define WTERMSIG(status) ((status) & 0x7f) Return signal number that caused process to terminate.
	#define WTERMSIG(status) ((status) And &h7f)
	
	'#define WIFEXITED(status) (WTERMSIG(status) == 0) True if child exited normally.
	#define WIFEXITED(status) (WTERMSIG(status) = 0)
	
	'#define WIFSTOPPED(status) (((status) & 0xff) == 0x7f) True if child is currently stopped.
	#define WIFSTOPPED(status) (((status) And &hff) = &h7f)
	
	'#define WIFSIGNALED(status) (!WIFSTOPPED(status) && !WIFEXITED(status)) True if child exited due to uncaught signal.
	#define WIFSIGNALED(status) (Not WIFSTOPPED(status) AndAlso Not WIFEXITED(status))
	
	'#define WSTOPSIG(status) WEXITSTATUS(status) Return signal number that caused process to stop.
	#define WSTOPSIG(status) WEXITSTATUS(status)
	
	'#define WCOREDUMP(status) ((status) & 0x80) syscall
	#define WCOREDUMP(status) ((status) And &h80)
	
	
	
	
	''===============END OF TO BE MOVED ===============================
	'' for memory or use :
	''  ptrace(PTRACE_POKEUSER, pid, sizeof(long)*REGISTER_IP, bp->addr);
	'' long v = ptrace(PTRACE_PEEKUSER, pid, sizeof(long)*REGISTER_IP);
	
	
	Dim Shared As pid_t debugpid,order,threadchild,retsegv,addr
	
	
	Dim Shared As String sigcode(20)
	sigcode(SIGINT)="SIGINT"
	sigcode(SIGTRAP)="SIGTRAP"
	sigcode(SIGABRT)="SIGABRT"
	sigcode(SIGKILL)="SIGKILL"
	sigcode(SIGSEGV)="SIGSEGV"
	sigcode(SIGUSR1)="SIGUSR1"
	sigcode(SIGUSR2)="SIGUSR2"
	sigcode(SIGTERM)="SIGTERM"
	sigcode(SIGCHLD)="SIGCHLD"
	sigcode(SIGCONT)="SIGCONT"
	sigcode(SIGSTOP)="SIGSTOP"
	
	Private Sub sigusr_send()
		dbg_prt2 "sigusr1 to be sent=";SYS_TGKILL,dbgpid,thread2,SIGUSR1
		dbg_prt2 "sigusr1 sent with return code=";
		syscall(SYS_TGKILL,dbgpid,thread2,SIGUSR1)
	End Sub
	
	'===============================
	''reads proc/maps-mem
	'===============================
	Private Sub read_proc(filesyst As String)
		Dim filein As Integer,lineread As String
		filein = FreeFile
		Open filesyst For Input As #Filein
		dbg_prt2 "reading =";filesyst
		Do While Not EOF(filein)
			Line Input #filein,lineread
			dbg_prt2 lineread
		Loop
		dbg_prt2 "end of reading"
		Close #filein
	End Sub
	
	'========================
	'' open/close a console
	'========================
	'flaglog=0 --> no output / 1--> only screen / 2-->only file / 3 --> both
	Private Sub output_lnx(txt As String)
		'messbox("Feature missing","open/close console : ouput_lnx")
		dbg_prt2 txt
	End Sub
	
	'=============================================================
	Private Function findadr() As Integer
		''-------------
		Dim As Integer xip
		ptrace(PTRACE_GETREGS, thread(threadcur).id, NULL, @regs)
		''address where really stopped, current was pointed to next instruction
		xip=regs.xip-1
		For jline As Long=1 To linenb
			'dbg_prt2"searching ",rline(jline).ad
			If rline(jline).ad=xip Then
				addr=rline(jline).ad
				dbg_prt2 "line found idx,number,addr = ";jline,rline(jline).nu,Hex(addr)
				Return jline
			End If
		Next
		dbg_prt2 "line not found"
		Return -1
	End Function
	'======================================
	''show all the registers
	'======================================
	Private Sub show_regs()
		Dim As String reg_values(),text
		exec_order(KPT_GETREGS)
		text+="Current Thread Id="+Str(thread(threadcur).id)+" / "+Hex(thread(threadcur).id)+Chr(13)
		#Ifdef __FB_64BIT__
			ReDim reg_values(15)
			reg_values(0)="Rax="+fmt(Str(regs.rax),20)+"/ "+Hex(regs.rax)
			reg_values(1)="Rcx="+fmt(Str(regs.rcx),20)+"/ "+Hex(regs.rcx)
			reg_values(2)="Rdx="+fmt(Str(regs.rdx),20)+"/ "+Hex(regs.rdx)
			reg_values(3)="Rbx="+fmt(Str(regs.rbx),20)+"/ "+Hex(regs.rbx)
			reg_values(4)="Rsp="+fmt(Str(regs.xsp),20)+"/ "+Hex(regs.xsp)
			reg_values(5)="Rbp="+fmt(Str(regs.xbp),20)+"/ "+Hex(regs.xbp)
			reg_values(6)="Rsi="+fmt(Str(regs.rsi),20)+"/ "+Hex(regs.rsi)
			reg_values(7)="R8 ="+fmt(Str(regs.r8),20) +"/ "+Hex(regs.r8)
			reg_values(8)="R9 ="+fmt(Str(regs.r9),20) +"/ "+Hex(regs.r9)
			reg_values(9)="R10="+fmt(Str(regs.r10),20)+"/ "+Hex(regs.r10)
			reg_values(10)="R11="+fmt(Str(regs.r11),20)+"/ "+Hex(regs.r11)
			reg_values(11)="R12="+fmt(Str(regs.r12),20)+"/ "+Hex(regs.r12)
			reg_values(12)="R13="+fmt(Str(regs.r13),20)+"/ "+Hex(regs.r13)
			reg_values(13)="R14="+fmt(Str(regs.r14),20)+"/ "+Hex(regs.r14)
			reg_values(14)="R15="+fmt(Str(regs.r15),20)+"/ "+Hex(regs.r15)
			reg_values(15)="Rip="+fmt(Str(regs.xip),20)+"/ "+Hex(regs.xip)
			
			For i As Long =0 To 15
		#Else
			ReDim reg_values(8)
			reg_values(0)="Edi="+fmt(Str(regs.edi),11)+"/ "+Hex(regs.edi)
			reg_values(1)="Esi="+fmt(Str(regs.esi),11)+"/ "+Hex(regs.esi)
			reg_values(2)="Ebx="+fmt(Str(regs.ebx),11)+"/ "+Hex(regs.ebx)
			reg_values(3)="Edx="+fmt(Str(regs.edx),11)+"/ "+Hex(regs.edx)
			reg_values(4)="Ecx="+fmt(Str(regs.ecx),11)+"/ "+Hex(regs.ecx)
			reg_values(5)="Eax="+fmt(Str(regs.eax),11)+"/ "+Hex(regs.eax)
			reg_values(6)="Ebp="+fmt(Str(regs.xbp),11)+"/ "+Hex(regs.xbp)
			reg_values(7)="Eip="+fmt(Str(regs.xip),11)+"/ "+Hex(regs.xip)
			reg_values(8)="Esp="+fmt(Str(regs.xsp),11)+"/ "+Hex(regs.xsp)
			
			For i As Long =0 To 8
		#EndIf
			text+=Chr(13)+reg_values(i)
		Next
		text+=Chr(13)+Chr(13)
		
		'readonlyeditor(GEDITOR,0)
		'setgadgettext(GEDITOR,text)
		'readonlyeditor(GEDITOR,1)
		'hidewindow(heditorbx,KSHOW)
	End Sub
	'=================================================================
	'' Executes order from first thread in second thread using ptrace
	'=================================================================
	Private Sub exec_order(order As Integer)
		MutexLock blocker
		msgcmd=order
		bool2=True
		CondSignal(condid)
		While bool1<>True
			CondWait(condid,blocker)
		Wend
		bool1=False
		MutexUnlock blocker
	End Sub
	'=========================================
	Private Function ReadProcessMemory(child As Long,addrdbge As Any Ptr,addrdbgr As Any Ptr,lg As Long,rd As Any Ptr=0) As Integer
		msgad=Cast(Integer,addrdbge)
		msgad2=Cast(Integer,addrdbgr)
		msgdata=lg
		exec_order(KPT_READMEM)
		Return 1
	End Function
	'=========================================
	Private Function WriteProcessMemory(child As Long, addrdbge As Any Ptr, addrdbgr As Any Ptr, lg As Long, rd As Any Ptr = 0) As Integer
		msgad=Cast(Integer,addrdbge)
		msgad2=Cast(Integer,addrdbgr)
		msgdata=lg
		exec_order(KPT_WRITEMEM)
		Return 1
	End Function
	'===============================================================
	Private Function writeprocessmemory_th2(child As Long,addrdbge As Any Ptr,addrdbgr As Any Ptr,lg As Long,rd As Any Ptr=0)As Integer
		Dim As Integer integersize=SizeOf(Integer),i,j=lg\integersize
		Dim As Integer buf,errn
		If addrdbge=0 Or addrdbgr=0 Then
			dbg_prt2 "write addrdbge=";Hex(addrdbge),"addrdbgr=";Hex(addrdbgr)
			Return 1
		End If
		If lg<=integersize Then
			buf=ptrace(PTRACE_PEEKDATA,child, addrdbge,NULL) 'read current value
			'dbg_prt2 "buf0=";hex(buf)
			memcpy(@buf,addrdbgr,lg) 'copy just bytes needed
			errn=ptrace(PTRACE_POKEDATA,child, addrdbge,Cast(Any Ptr,buf)) 'write all
			If errn<>0 Then Print "in write peek errno=";errno,Hex(addrdbge)
			Return 1
		End If
		
		While i<j
			buf=ptrace(PTRACE_PEEKDATA,child, addrdbge,NULL) 'read current value
			memcpy(@buf,addrdbgr,integersize)
			errn=ptrace(PTRACE_POKEDATA,child, addrdbge,Cast(Any Ptr,buf))
			i+=1
			addrdbge+=integersize
			addrdbgr+=integersize
		Wend
		
		j=lg Mod integersize
		If j Then
			buf=ptrace(PTRACE_PEEKDATA,child, addrdbge,NULL) 'read current value
			memcpy(@buf,addrdbgr,j) 'copy just bytes needed
			errn=ptrace(PTRACE_POKEDATA,child, addrdbge,Cast(Any Ptr,buf)) 'write all
		End If
		Return 1
	End Function
	Private Function readmemlongint(child As Long,addrdbge As Integer)As LongInt
		#ifdef __FB_64BIT__
			Return ptrace(PTRACE_PEEKDATA,child, Cast(Any Ptr,addrdbge),NULL)
		#else
			Dim As LongInt lgint,lgint2
			Dim As Integer value
			value=ptrace(PTRACE_PEEKDATA,child, Cast(Any Ptr,addrdbge),NULL)
			lgint=value
			addrdbge+=SizeOf(Integer)
			value=ptrace(PTRACE_PEEKDATA,child, Cast(Any Ptr,addrdbge),NULL)
			lgint2=value
			lgint+=lgint2 Shl 32
			Return lgint
		#endif
	End Function
	'==========================================
	Private Function ReadProcessMemory_th2(child As Long,addrdbge As Any Ptr,addrdbgr As Any Ptr,lg As Long,rd As Any Ptr=0) As Integer
		Dim As Integer integersize=SizeOf(Integer),i,j=lg\integersize
		Dim As Integer buf(j)
		If addrdbge=0 Or addrdbgr=0 Then
			'dbg_prt2 "read addrdbge=";hex(addrdbge),"addrdbgr=";hex(addrdbgr)
			Return 1
		End If
		If lg<=integersize Then
			buf(0)=ptrace(PTRACE_PEEKDATA,child, addrdbge,NULL)
			memcpy(addrdbgr,@buf(0),lg)
			'*rd=lg
			Return 1 ''return 0 if error
		End If
		While i<j
			buf(i)=ptrace(PTRACE_PEEKDATA,child, addrdbge,NULL)
			i+=1
			addrdbge+=integersize 'next pointed value (add 4 or 8 bytes)
		Wend
		j=lg Mod integersize
		If j Then
			buf(i)=ptrace(PTRACE_PEEKDATA,child, addrdbge,NULL)
		End If
		
		memcpy(addrdbgr,@buf(0),lg)
		'*rd=lg
		Return 1 ''return 0 if error
	End Function
	'========================================================
	''puts the breakpoints on all lines saving previous value
	'========================================================
	Private Sub putbreaks()
		''-------------
		Dim dta As Integer 'ALWAYS INTEGER 4 or 8 bytes
		dbg_prt2 "in put breaks",linenb,"pid";debugpid
		errno=0
		For j As Long=1 To linenb
			With rline(j)
				'dbg_prt2 "j=";j;" nu=";.nu;" ad=";.ad;"/";hex(.ad);" px-nu=";proc(.px).nu
				If proc(.px).nu=-1 Then
					dbg_prt2 " never reached added by compiler=";Hex(rline(j).ad),rline(j).nu
				Else
					dta = ptrace(PTRACE_PEEKTEXT,debugpid,Cast(Any Ptr,.ad),NULL)
					If errno<>0 Then Print "error=";errno
					.sv=dta And &hFF
					dta = (dta And FIRSTBYTE ) Or &hCC
					ptrace(PTRACE_POKETEXT,debugpid,Cast(Any Ptr,.ad),Cast(Any Ptr,dta))
				End If
			End With
		Next
		ccstate=KCC_ALL
	End Sub
	'=========================================================
	''puts(default=1)/removes(0) the breakpoints for all lines
	'=========================================================
	Private Sub putremove_breaks(ByVal pid As Long,ByVal typ As Integer=1)
		''-------------
		Dim dta As Integer 'ALWAYS INTEGER 4 or 8 bytes
		dbg_prt2"in put/remove breaks",linenb,"pid=";pid
		If typ Then
			''puts breakpoints
			For j As Long=1 To linenb
				With rline(j)
					If proc(.px).nu=-1 Then
						'dbg_prt2 " never reached added by compiler"
					Else
						If proc(.px).enab = True Then
							dta = ptrace(PTRACE_PEEKTEXT,pid,Cast(Any Ptr,.ad),NULL)
							dta = (dta And FIRSTBYTE ) Or &hCC
							If ptrace(PTRACE_POKETEXT,pid,Cast(Any Ptr,.ad),Cast(Any Ptr,dta))=-1 Then
								dbg_prt2 "impossible to poketext, errno=";errorlibel(errno)
								Exit For
							End If
						End If
					End If
				End With
			Next
			ccstate=KCC_ALL
		Else
			''restores intructions
			For j As Long=1 To linenb
				With rline(j)
					If proc(.px).nu=-1 Then
						'dbg_prt2 " never reached added by compiler"
					Else
						dta = ptrace(PTRACE_PEEKTEXT,pid,Cast(Any Ptr,.ad),NULL)
						dta = (dta And FIRSTBYTE ) Or rline(j).sv
						ptrace(PTRACE_POKETEXT,pid,Cast(Any Ptr,.ad),Cast(Any Ptr,dta))
					End If
				End With
			Next
			ccstate=KCC_NONE
		End If
	End Sub
	'===========
	Private Sub thread_new(pid As Long)
		If threadnb<THREADMAX Then
			threadnb+=1
			thread(threadnb).id=pid
			thread(threadnb).pe=False
			thread(threadnb).sv=-1 'used for thread not debugged
			thread(threadnb).plt=0 'used for first proc of thread then keep the last proc
			thread(threadnb).st=thread(threadcur).od 'used to keep line origin
			thread(threadnb).tv=0
			thread(threadnb).sts=KTHD_INIT
			dbg_prt2 "new thread nb=";threadnb,"pid=";pid
		Else
			hard_closing("Number of threads ("+Str(THREADMAX+1)+") exceeded , change the THREADMAX value."+Chr(10)+Chr(10)+"CLOSING FBDEBUGGER, SORRY" )
		End If
	End Sub
	'=====================================================
	Private Sub thread_rsm_one()
		dbg_prt2 "in thread_rsm restore=";threadcur,thread(threadcur).sv,rline(thread(threadcur).sv).nu,Hex(rline(thread(threadcur).sv).sv)
		If rline(thread(threadcur).sv).sv=-1 Then Exit Sub
		
		msgad=rline(thread(threadcur).sv).ad
		msgdata=rline(thread(threadcur).sv).sv And &hFF
		exec_order(KPT_RESTORE)
	End Sub
	'=====================================================
	Private Sub thread_rsm()
		dbg_prt2 "in thread_rsm executing KPT_CONTALL"
		exec_order(KPT_CONTALL)
	End Sub
	'=====================================================
	Private Sub singlestep_rsm(rln As Integer)
		msgad=rline(rln).ad
		msgdata=rline(rln).sv
		dbg_prt2 "in singlestep_rsm=";rln,Hex(msgad),rline(rln).nu,msgdata
		exec_order(KPT_SSTEP)
	End Sub
	'=====================================
	Private Sub resume_exec()
		For jbrk As Integer = 1 To brknb ''restore if needed the UBP
			If brkol(jbrk).typ<50 Then
				If rlinecur=brkol(jbrk).index Then ''if current line is a BP (permanent/cond/counter)
					singlestep_rsm(rlinecur)
					Exit Sub
				End If
			End If
		Next
		thread_rsm()
	End Sub
	'====================================================================
	'' Executes all commands from main thread
	'====================================================================
	Private Sub brp_stop(tidx As Integer,bptype As Integer,ddata As Integer,dbgevent As Integer = KDBGRKPOINT)
		Dim As Integer dta
		threadcur=tidx''only useful case when exiting thread replaced by first thread
		dbg_prt2 "brp_stop=";tidx,thread(tidx).id,bptype,Hex(ddata)
		stopcode=bptype
		debugdata=ddata
		debugevent=dbgevent
		'===========
		While 1
			MutexLock blocker
			While bool2<>True
				CondWait(condid,blocker)
			Wend
			'dbg_prt2 "in brp_stop after condwait";msgcmd,hex(msgad),hex(msgad2),hex(msgdata)
			bool2=False
			Select case As Const msgcmd
				
			case KPT_CONT
				dbg_prt2 "cont"
				'bool1=true
				'condsignal(condid)
				'mutexunlock blocker
				ptrace(PTRACE_CONT,thread(threadcur).id,0,0)
				'exit while
				
			case KPT_CONTALL
				For ith As Integer =0 To threadnb
					dbg_prt2 "KPT_CONTALL idx,sts=";ith,thread(ith).sts
					If thread(ith).sts=KTHD_STOP Then ' and rLine(thread(threadcur).sv).sv<>-1 then
						If thread(ith).sv>0 Then ''if attachment no saved line
							dta = ptrace(PTRACE_PEEKTEXT,thread(ith).id,Cast(Any Ptr,rline(thread(ith).sv).ad),NULL)
							dta = (dta And FIRSTBYTE ) Or (rline(thread(ith).sv).sv And &hFF)
							dbg_prt2 "KPT_CONTALL=";" ";Hex(rline(thread(ith).sv).ad);" ";,Hex(dta)
							ptrace(PTRACE_POKETEXT,thread(ith).id,Cast(Any Ptr,rline(thread(ith).sv).ad),Cast(Any Ptr,dta))
						End If
						thread(ith).sts=KTHD_RUN
						thread(ith).rtype=runtype
						ptrace(PTRACE_CONT,thread(ith).id,0,0)
					End If
				Next
				bool1=True
				CondSignal(condid)
				MutexUnlock blocker
				Exit While
				
			case KPT_XIP ''update EIP or RIP
				ptrace(PTRACE_GETREGS, thread(threadcur).id, NULL, @regs)
				dbg_prt2 "update xip=";Hex(regs.xip),Hex(msgad)
				regs.xip=msgad
				ptrace(PTRACE_SETREGS, thread(threadcur).id, NULL, @regs)
				
			case KPT_CCALL
				putremove_breaks(thread(threadcur).id,msgdata)
				
			case KPT_CC
				dta = ptrace(PTRACE_PEEKTEXT,thread(threadcur).id,Cast(Any Ptr,msgad),NULL)
				dta = (dta And FIRSTBYTE ) Or &hCC
				ptrace(PTRACE_POKETEXT,thread(threadcur).id,Cast(Any Ptr,msgad),Cast(Any Ptr,dta))
				
			case KPT_SSTEP
				dta = ptrace(PTRACE_PEEKTEXT,thread(threadcur).id,Cast(Any Ptr,msgad),NULL)
				dta = (dta And FIRSTBYTE ) Or msgdata
				ptrace(PTRACE_POKETEXT,thread(threadcur).id,Cast(Any Ptr,msgad),Cast(Any Ptr,dta))
				ssadr=msgad
				dbg_prt2 "single step defined by KPT_SSTEP threadcur=";threadcur,Hex(ssadr)
				bool1=True
				CondSignal(condid)
				MutexUnlock blocker
				thread(threadcur).sts=KTHD_RUN
				ptrace(PTRACE_SINGLESTEP, thread(threadcur).id, NULL, NULL)
				Exit While
				
			case KPT_GETREGS
				If ptrace(PTRACE_GETREGS, thread(threadcur).id, NULL, @regs) Then
					dbg_prt2 "error in getregs=";errno
				End If
				
			case KPT_SETREGS
				If ptrace(PTRACE_SETREGS, thread(threadcur).id, NULL, @regs)=-1 Then
					dbg_prt2 "error in setregs=";errno
				End If
				
			case KPT_READMEM
				ReadProcessMemory_th2(thread(threadcur).id,Cast(Any Ptr,msgad),Cast(Any Ptr,msgad2),msgdata)
				
			case KPT_WRITEMEM
				writeprocessmemory_th2(thread(threadcur).id,Cast(Any Ptr,msgad),Cast(Any Ptr,msgad2),msgdata)
				
			case KPT_RESTORE
				dta = ptrace(PTRACE_PEEKTEXT,thread(threadcur).id,Cast(Any Ptr,msgad),NULL)
				'dbg_prt2 "data read=";hex(dta),hex((dta and FIRSTBYTE )),hex(msgdata)
				dta = (dta And FIRSTBYTE ) Or msgdata
				dbg_prt2 "KPT_RESTORE=";" ";Hex(msgad);" ";,Hex(dta)
				ptrace(PTRACE_POKETEXT,thread(threadcur).id,Cast(Any Ptr,msgad),Cast(Any Ptr,dta))
				ptrace( PTRACE_CONT, thread(threadcur).id, NULL, NULL )
				
				bool1=True
				CondSignal(condid)
				MutexUnlock blocker
				
				Exit While
				
			case KPT_KILL
				dbg_prt2 "sending sigkill"
				linux_kill(debugpid,9) ''send SIGKILL
				bool1=True
				CondSignal(condid)
				MutexUnlock blocker
				prun=False
				Exit While
				
			case KPT_SIGNAL
				''get pending signal no stop but signal is removed so need to be saved
				threadsaved=waitpid(-1,@statussaved,__WNOHANG)
				dbg_prt2 "KPT_SIGNAL thread=";threadsaved,"status=";Hex(statussaved)
				
				bool1=True
				CondSignal(condid)
				MutexUnlock blocker
				
			case Else ''can be used for exiting the loop
				dbg_prt2 "msgcmd not handled exiting loop=";msgcmd
				bool1=True
				CondSignal(condid)
				MutexUnlock blocker
				Exit While
			End Select
			bool1=True
			CondSignal(condid)
			MutexUnlock blocker
		Wend
		'===========
		dbg_prt2 "in br_stop exit while"
		
		
	End Sub
	'=============================================
	'' Executed when the first SIGTRAP is received
	'=============================================
	Private Sub first_sigtrap()
		threadcur=0
		thread(threadcur).id=debugpid
		dbg_prt2 "thread(threadcur).id=";thread(threadcur).id
		dbg_prt2 "get regs in first=";
		ptrace(PTRACE_GETREGS, thread(threadcur).id, NULL, @regs)
		dbg_prt2 "xip=";Hex(regs.xip)
		'debugdata=Cast(Integer,.lpBaseOfImage)
		debugevent=KDBGCREATEPROCESS
		MutexLock blocker
		While bool2<>True
			CondWait(condid,blocker)
		Wend
		bool2=False
		MutexUnlock blocker
		'read_proc("/proc/"+ltrim(str(pid))+"/maps")
		'read_proc("/proc/"+ltrim(str(pid))+"/status")
		putbreaks()
		firsttime=1
		prun=True
		runtype=RTSTEP
		ptrace(PTRACE_SETOPTIONS, thread(threadcur).id, 0, Cast(Any Ptr,(PTRACE_O_TRACECLONE)))
		ptrace(PTRACE_CONT,thread(threadcur).id,0,0)
	End Sub
	'===============================
	'' wait and handle all signals
	'===============================
	Private Sub wait_signal()
		Dim As Long threadSig
		Static As Long newpid
		Dim As Long status
		Dim As Integer dta,bptyp
		
		sig_init()
		debugpid = dbghand
		threadnb=0
		thread(threadcur).id = dbghand
		thread(threadcur).sv=-1
		dbg_prt2 "debugpid in scope debugger =";pid
		dbg_prt2 "Debugger pid (+thread) = ";getpid,syscall(SYS_GETTID)
		Wait(0)
		
		first_sigtrap()
		
		dbg_prt2 "entering in loop"
		While 1
			''waiting loop, exit when debuggee terminated
			If statussaved Then
				status=statussaved
				threadSig=threadsaved
				statussaved=0
				threadsaved=0
				dbg_prt2 "Using saved data thread=";threadSig,"status=";Hex(status)
			Else
				threadSig=waitpid(-1,@status,__WALL)
			End If
			dbg_prt2 "======================================== pid=";threadSig;" ======== status=";Hex(status)
			If threadSig=-1 Then
				dbg_prt2 "thread =-1 so errno=";errno
				ptrace(PTRACE_CONT,thread(threadcur).id,0,0)
				Continue While
			End If
			''handle status
			If WIFEXITED(status) Then
				If threadSig=debugpid Then
					dbg_prt2 "normal exit with status=";WEXITSTATUS(status)
					prun=False
					afterkilled=KDONOTHING
					debugdata=WEXITSTATUS(status)
					debugevent=KDBGEXITPROCESS
					Exit While
				Else
					dbg_prt2 "thread=";threadSig;" exit with status=";WEXITSTATUS(status)
					brp_stop(0,0,threadSig,KDBGEXITTHREAD) ''for waiting command
				End If
				
			ElseIf WIFSIGNALED(status) Then
				prun=False
				dbg_prt2 "Killed by=";WTERMSIG(status)
				debugdata=WTERMSIG(status)
				debugevent=KDBGEXITPROCESS
				Exit While
				
			ElseIf WIFSTOPPED(status) Then
				dbg_prt2 "signal stop=";WSTOPSIG(status)
				
				If threadSig<>thread(threadcur).id Then ''other thread than the current ?
					dbg_prt2 "Thread signal <> current thread=";threadcur," sig=";threadSig
					If WSTOPSIG(status)<>SIGSTOP Then ''maybe SIGSTOP for new thread so DON'T change threadcur
						For ith As Integer = 0 To threadnb
							If threadSig=thread(ith).id Then
								threadcur=ith
								dbg_prt2 "thread changed index, pid=",threadcur,threadSig
								Exit For
							End If
						Next
					End If
				End If
				
				Select Case WSTOPSIG(status)
					
				Case SIGTRAP
					
					If (((status Shr 16) And &hffff) = PTRACE_EVENT_CLONE) Then  ''checks new thread ?
						Dim As Integer eventmsg
						ptrace(PTRACE_GETEVENTMSG,thread(threadcur).id,NULL,@eventmsg)
						ptrace(PTRACE_GETREGS, thread(threadcur).id, NULL, @regs)
						newpid=eventmsg
						''to handle cases where 3057F arrives after 137F
						For ithd As Integer =0 To threadnb
							If thread(ithd).id=eventmsg Then
								newpid=0
								dbg_prt2 "NEW thread already created current xip=";eventmsg
								Exit For
							End If
						Next
						If newpid Then
							dbg_prt2 "NEW thread created current xip=";newpid
							thread_new(newpid)
						End If
						ptrace(PTRACE_CONT,thread(threadcur).id,0,0)
						Continue While
					End If
					
					dbg_prt2 "-------------  EXCEPTION_BREAKPOINT   ------------------------------"
					If ssadr<>0 Then ''a single step has been executed
						dbg_prt2 "handling single step=";Hex(ssadr),threadcur,thread(threadcur).id
						dta = ptrace(PTRACE_PEEKTEXT,thread(threadcur).id,Cast(Any Ptr,ssadr),NULL)
						'dbg_prt2 "data read=";hex(dta),hex((dta and FIRSTBYTE )),hex(msgdata)
						dta = (dta And FIRSTBYTE ) Or &hCC
						ptrace(PTRACE_POKETEXT,thread(threadcur).id,Cast(Any Ptr,ssadr),Cast(Any Ptr,dta))
						ssadr=0
						ptrace(PTRACE_CONT,thread(threadcur).id,0,0)
					Else
						Dim As Integer xip, bpidx=-1
						ptrace(PTRACE_GETREGS, thread(threadcur).id, NULL, @regs)
						''address where really stopped, current was pointed to next instruction
						'if findadr() <> -1 then
						xip=regs.xip-1
						'end if
						dbg_prt2 "xip=";Hex(xip),"runtype=";runtype,"RTRUN=";RTRUN,"RTSTEP=";RTSTEP
						If runtype=RTCRASH Then
							''don't stop as running until a crash
							breakadr=xip
							For irln As Integer =1 To linenb
								If rline(irln).ad=xip Then ''need to find where we are
									singlestep_on(thread(threadcur).id,irln)
									'ptrace(PTRACE_SINGLESTEP, thread(threadcur).id, NULL, NULL)
									'exit for
									Continue While
								End If
							Next
						ElseIf runtype=RTRUN Or runtype=RTAUTO Then
							If brkv.adr1<>0 Then
								If brk_test(brkv.adr1,brkv.adr2,brkv.typ,brkv.Val,brkv.ttb) Then
									If brkv.ivr1=0 Then
										brp_stop(threadcur,CSMEM,xip)
									Else
										brp_stop(threadcur,CSVAR,xip)
									End If
									Continue While
								Else
									For irln As Integer =1 To linenb
										If rline(irln).ad=xip Then ''need to find where we are
											singlestep_on(thread(threadcur).id,irln)
											'ptrace(PTRACE_SINGLESTEP, thread(threadcur).id, NULL, NULL)
											'exit for
											Continue While
										End If
									Next
								End If
								
							End If
							''retrieves BP corresponding at address (loop) -->bpidx
							For ibrk As Integer =0 To brknb
								If brkol(ibrk).typ>50 Then Continue For ''BP disabled
								If brkol(ibrk).ad=xip Then
									bpidx=ibrk
									dbg_prt2 "BP found idx=";bpidx,"typ=";brkol(ibrk).typ
									runtype=RTRUN ''forcing only useful if RTAUTO
									Exit For
								End If
							Next
							If bpidx<>-1 Then
								If bpidx=0 Then ''BP on LINE (line, cursor, over,eop,xop)
									dbg_prt2 "BP on line"
									brp_stop(threadcur,CSLINE,bpidx)
									Continue While
								End If
								bptyp=brkol(bpidx).typ
								If bptyp=2 Or bptyp=3 Then  ''BP conditional
									If brk_test(brkol(bpidx).adrvar1,brkol(bpidx).adrvar2,brkol(bpidx).datatype,brkol(bpidx).val,brkol(bpidx).ttb) Then
										brp_stop(threadcur,CSCOND,bpidx)
									Else
										singlestep_on(thread(threadcur).id,brkol(bpidx).index)
										'ptrace(PTRACE_SINGLESTEP, thread(threadcur).id, NULL, NULL)
									End If
									Continue While
								ElseIf bptyp=4 Then ''BP counter
									dbg_prt2 "counter=";bpidx,brkol(bpidx).counter
									If brkol(bpidx).counter>0 Then
										brkol(bpidx).counter-=1'decrement counter
										dbg_prt2 "decrement counter=";brkol(bpidx).counter
										singlestep_on(thread(threadcur).id,brkol(bpidx).index)
										'ptrace(PTRACE_SINGLESTEP, thread(threadcur).id, NULL, NULL)
									Else
										brp_stop(threadcur,CSCOUNT,bpidx)
									End If
									Continue While
								Else
									''simple BP (perm/tempo)
									brp_stop(threadcur,CSBRKPT,bpidx)
									Continue While
								End If
								If stopcode=CSUSER Then
									brp_stop(threadcur,stopcode,xip)
									Continue While
								End If
							Else
								''case halt by user so no breakpoint and stopcode should be CSUSER
								''continue waiting to a normal breakpoint
								'ptrace(PTRACE_CONT,thread(threadcur).id,0,0)
								'for irln as integer =1 to linenb
								'if rline(irln).ad=xip then ''need to find where we are
								'dbg_prt2 "Breakpoint not a User BP, line found, executing single step on ";hex(xip)
								'singlestep_on(thread(threadcur).id,irln)
								'runtype=RTSTEP
								'
								'continue while
								'EndIf
								'Next
								If stopcode<>CSUSER Then
									''could be a hard case if when running auto a new thread is started
									If runtype=RTAUTO Then
										brp_stop(threadcur,CSSTEP,xip)
									Else
										dbg_prt2 "STOPPED without UBP CSNEWTHRD=";thread(threadcur).id,Hex(xip)
										brp_stop(threadcur,CSNEWTHRD,xip)
									End If
								Else
									brp_stop(threadcur,CSUSER,xip)
								End If
							End If
							
						Else ''RTSTEP
							If stopcode=CSUSER Then ''CSUSER : user halts the debuggee
								brp_stop(threadcur,stopcode,xip)
								
							Else
								dbg_prt2 "CSSTEP"
								brp_stop(threadcur,CSSTEP,xip)
							End If
							Continue While
						End If
					End If
					
				Case SIGSEGV
					ptrace(PTRACE_GETREGS, thread(threadcur).id, NULL, @regs)
					dbg_prt2 "sigsegv=";Hex(regs.xip)
					Dim As tsiginfo siginfo
					ptrace(PTRACE_GETSIGINFO, thread(threadcur).id, NULL, @siginfo)
					dbg_prt2 "siginfo=";siginfo.si_signo, siginfo.si_code, siginfo.si_errno,Hex(siginfo.si_addr)
					
				Case SIGILL
					ptrace(PTRACE_GETREGS, thread(threadcur).id, NULL, @regs)
					dbg_prt2 "sigill=";Hex(regs.xip)
					Dim As tsiginfo siginfo
					ptrace(PTRACE_GETSIGINFO, thread(threadcur).id, NULL, @siginfo)
					dbg_prt2 "siginfo=";siginfo.si_signo, siginfo.si_code, siginfo.si_errno,Hex(siginfo.si_addr)
					
				Case SIGCHLD
					ptrace(PTRACE_GETREGS, thread(threadcur).id, NULL, @regs)
					dbg_prt2 "sigchld="; Hex(regs.xip)
					Dim As tsiginfo siginfo
					ptrace(PTRACE_GETSIGINFO, thread(threadcur).id, NULL, @siginfo)
					dbg_prt2 "siginfo=";siginfo.si_signo, siginfo.si_code, siginfo.si_errno,Hex(siginfo.si_addr),siginfo.dummy(0),siginfo.dummy(1)
					ptrace(PTRACE_CONT,thread(threadcur).id,0,0)
				Case Else
					
					'dbg_prt2 "other Signals=";WSTOPSIG(status)
					If WSTOPSIG(status)=SIGSTOP Then
						dbg_prt2 "SIGSTOP"
					ElseIf WSTOPSIG(status)=SIGCONT Then
						dbg_prt2 "SIGCONT"
					End If
					
					If thread(threadcur).id <> threadSig Then ''new thread ready to start
						dbg_prt2 "threadcur, id, sig=";threadcur,thread(threadcur).id , threadSig
						dbg_prt2 "ptrace get bis regs=";thread(threadnb).id,ptrace(PTRACE_GETREGS, thread(threadnb).id, NULL, @regs)
						dbg_prt2 "xip=";Hex(regs.xip)
						If newpid=0 Then ''special case signal 3057F missing so only 137F for new thread
							dbg_prt2 "executing thread_new as signal 3057F missing for =";threadSig
							thread_new(threadSig)
						Else
							newpid=0
						End If
						threadnewid=threadSig
						threadnewidcount=2
						putremove_breaks(thread(threadnb).id)
						ptrace(PTRACE_CONT,thread(threadnb).id,0,0)
					End If
				End Select
			Else
				dbg_prt2 "Status not handled=";status
			End If
		Wend
	End Sub
	'================================================
	'' starts debuggee for linux
	'================================================
	Private Sub start_pgm(p As Any Ptr)
		
		thread2=syscall(SYS_GETTID)
		If thread2=-1 Then Print "errno=";errno
		dbg_prt2 "current pid=";thread2
		Dim As pid_t lpid=fork()
		
		dbg_prt2 "lpid=";lpid
		
		Select Case lpid
		Case -1 'error child not created
			dbg_prt2 "error child not created"'"errno = ";errno 'use perror("fork") ?
			Exit Sub
			
		Case 0 'child created now the debuggee is going to be started
			debugpid=getpid
			dbg_prt2 "Debuggee pid = ";debugpid,syscall(SYS_GETTID)
			dbghand = debugpid
			If ptrace(PTRACE_TRACEME, 0, 0,0) Then
				dbg_prt2 "error traceme"'"errno = ";errno 'use perror("ptrace")
				Exit Sub
			End If
			dbg_prt2 "name=";exename
			Dim As String exename_ = exename
			If execv(StrPtr(exename_), NULL) Then
				dbg_prt2 "error on starting debuggee=";errno ' argv, envp)=-1
				Exit Sub
			End If
			
		Case Else ''parent
			dbghand = lpid
			wait_signal()
		End Select
	End Sub
	'================================================
	'' attachs debuggee for linux
	'================================================
	Private Sub attach_debuggee(p As Any Ptr)
		Dim As String textcommand
		dbghand = dbgprocid
		If ptrace(PTRACE_ATTACH, dbghand, 0, 0) Then
			dbg_prt2 "error attach =";errno
			perror("Attachment error = ") ''text error
			Exit Sub
		End If
		''retrieve the full name of exe
		textcommand = "readlink /proc/" + LTrim(Str(dbghand)) + "/exe -v"
		Open Pipe textcommand For Input As #1
		Line Input #1, exename
		Close #1
		
		'exe_sav(exename,"")
		runtype=RTSTEP
		flagattach=True
		wait_signal()
	End Sub
	'==================================
	'' lists all the processes
	'==================================
	Private Sub process_list()
		MsgBox("For Linux process list not yet implemented")
	End Sub
	'=======================================================
	'' displays the input box and check value
	'=======================================================
	Private Function input_bx(title As String,text1 As String,text2 As String="",inputtyp As Integer) As String
		Dim As Boolean vflag=True
		Dim As Double vald
		Dim As String inputval
		Do
			inputval=InputBox(title,text1,text2)
			If inputtyp=99 Then
				vald=Val(inputval)
				Select Case inputtyp
				Case 2
					If vald<-128 Or vald>127 Then text1="min -128,max 127":vflag=False
				Case 3
					If vald<0 Or vald>255 Then text1="min 0,max 255":vflag=False
				Case 5
					If vald<-32768 Or vald>32767 Then text1="min -32768,max 32767":vflag=False
				Case 6
					If vald<0 Or vald>65535 Then text1="min 0,max 65535":vflag=False
				Case 1
					If vald<-2147483648 Or vald>2147483648 Then text1="min -2147483648,max +2147483647":vflag=False
				Case 7,8
					If vald<0 Or vald>4294967395 Then text1="min 0,max 4294967395":vflag=False
				End Select
			End If
		Loop Until vflag=True
		Return inputval
	End Function
	'===============================
	'' shows value in dec/hex/bin
	'===============================
	Private Sub dechexbin()
		Var inputval=input_bx("Display value in dec/hex/bin","Input value HEX("+KAMPERSAND+"h) or DEC",,99)
		MsgBox("Value in dec, hex and bin", "Dec= " + Str(Val(inputval)) + Chr(10) + "Hex=" + Hex(Val(inputval)) + Chr(10) + "Bin=" + Bin(Val(inputval)))
	End Sub
	'======================================
	'' translates code error to the text
	'======================================
	Private Sub linmsg()
		Dim As Integer code
		code=ValInt(input_bx("Linux error text","Enter the code",,5))
		If code<>0 And code<=UBound(errorlibel) Then
			MsgBox("Linux message: Code :" + Str(code) + Chr(10) + "Text : " + errorlibel(code))
		Else
			MsgBox("Linux error code: Sorry unkown in debugger list")
		End If
	End Sub
	'==================================
	Private Function dll_name(FileHandle As Any Ptr, t As Integer = 1) As String ' t=1 --> full name, t=2 --> short name
		Return "name of dll..."
	End Function
	'====================================================================
	'' prepares singlestepping for restoring BP
	'====================================================================
	Private Sub singlestep_on(tid As Integer,rln As Integer,running As Integer =1)
		Dim As Integer dta
		For i As Integer =0 To threadnb
			If tid=thread(i).id Then
				threadcur=i
				If running Then ''when not running initial code is already restored and no need to decrease EIP
					ptrace(PTRACE_GETREGS, thread(threadcur).id, NULL, @regs)
					''restore initial code
					dta = ptrace(PTRACE_PEEKTEXT,thread(threadcur).id,Cast(Any Ptr,rline(rln).ad),NULL)
					'dbg_prt2 "data read=";hex(dta),hex((dta and FIRSTBYTE )),hex(msgdata)
					dta = (dta And FIRSTBYTE ) Or rline(rln).sv
					ptrace(PTRACE_POKETEXT,thread(threadcur).id,Cast(Any Ptr,rline(rln).ad),Cast(Any Ptr,dta))
					''change EIP go back 1 byte
					regs.xip-=1
					ptrace(PTRACE_SETREGS, thread(threadcur).id, NULL, @regs)
					dbg_prt2 "single step restoring old value on=";Hex(rline(rln).ad),"new xip=";Hex(regs.xip)
				End If
				''rline for restoring BP
				ssadr=rline(rln).ad
				dbg_prt2 "single step defined=";Hex(ssadr)
				ptrace(PTRACE_SINGLESTEP, thread(threadcur).id, NULL, NULL)
				Exit Sub
			End If
		Next
	End Sub
	'========================================================
	''  handles breakpoints
	'========================================================
	Private Sub gest_brk(ad As Integer,ByVal rln As Integer =-1)
		Dim As Integer i,debut=1,fin=linenb+1,adr,iold
		'egality added in case attach (example access violation) without -g option, ad=procfn=0....
		If ad>=procfn Then
			thread_resume()
			Exit Sub
		End If
		
		
		'' when there are dynamic arrays it's necessary to change a value in their descriptor
		'' so access to the memory and thread must be waiting orders.....
		If firsttime=1 Then
			dbg_prt2 "try to change for dynamic arrays"
			firsttime=2
			init_debuggee(srcstart)
		End If
		
		dbg_prt2("")
		dbg_prt2("AD gest brk="+Hex(ad)+" th="+Str(threadcur))+" runtype="+Str(runtype)
		'show_context
		
		proccurad=ad
		dbg_prt2 "rln=";rln,thread(threadcur).sv+1,Hex(rline(thread(threadcur).sv+1).ad)
		If rln=-1 Then ''search the line using address
			i=thread(threadcur).sv+1
			If rline(i).ad<>ad Then 'hope next source line is next executed line (optimization)
				While 1
					iold=i
					i=(debut+fin)\2 'first consider that the addresses are sorted increasing order
					If i=iold Then 'loop
						For j As Integer =1 To linenb
							If rline(j).ad=ad Then i=j:Exit While
						Next
					End If
					If ad>rline(i).ad Then
						debut=i
					ElseIf ad<rline(i).ad Then
						fin=i
					Else
						Exit While
					End If
				Wend
			End If
			rln=i
		End If
		rlinecur=rln
		thread(threadcur).od=thread(threadcur).sv
		thread(threadcur).sv=rln
		
		'dbg_prt2 "in gest brk sv=";thread(threadcur).sv
		
		procsv=rline(rln).px
		'dbg_prt2("proc ="+Str(procsv)+" "+proc(procsv).nm+" "+hex(proc(procsv).db)+" "+source(proc(procsv).sr)+" "+hex(proccurad))
		'dbg_prt2("line="+Str(rline(i).nu))
		
		'get registers
		exec_order(KPT_GETREGS)
		dbg_prt2 "gest_brk xip=";Hex(regs.xip),Hex(regs.xsp),Time
		
		dbg_prt2 "test proccurad=proc(procsv).db",Hex(proccurad),Hex(proc(procsv).db)
		If proccurad=proc(procsv).db Then 'is first proc instruction
			thread(threadcur).cl=thread(threadcur).od ''done here to avoid a wrong assignment
			If rline(rln).sv=85 Then'check if the first instruction is push ebp opcode=85 / push rbp opcode=&h55=85dec
				'in this case there is a prologue
				'at the beginning of proc EBP not updated so use ESP
				procsk=regs.xsp-SizeOf(Integer)
			Else
				If procrnb<>0 Then  'no main and no prologue so naked proc, procrnb not yet updated
					procsk=regs.xsp
					thread(threadcur).nk=procsk
				Else
					MsgBox("Main procedure problem", "No standard prologue --> random behaviour")
					procsk=regs.xsp-SizeOf(Integer)
				End If
			End If
		Else
			'only for naked, check if return by comparing top of stack because no epilog
			If thread(threadcur).nk Then
				If regs.xsp>thread(threadcur).nk Then
					thread(threadcur).pe=True
					thread(threadcur).nk=0
				End If
			End If
		End If
		regs.xip=ad
		dbg_prt2 "in gest_brk setregs xip=",Hex(regs.xip)
		exec_order(KPT_SETREGS)
		
		'dbg_prt2("PE"+Str(thread(threadcur).pe)+" "+Str(proccurad)+" "+Str(proc(procsv).fn))
		If thread(threadcur).pe Then 'if previous instruction was the last of proc
			If proccurad<>proc(procsv).db Then 'reload procsk with rbp/ebp test added for case constructor on shared
				procsk=regs.xbp
			End If
			proc_end():thread(threadcur).pe=False
		End If
		
		If proccurad=proc(procsv).db Then 'is first proc instruction
			If threadnewid<>0 Then
				dbg_prt2 "new thread beginning of proc"
				threadnewidcount-=1
			End If
			thread_rsm_one() ''should reach first basic line before stopping
			Exit Sub
		End If
		thread(threadcur).sts=KTHD_STOP ''doing that here because can exit just above and still running
		thread_status()
		''=========== end of code to move ========================================================
		If runtype=RTRUN Then
			'''''''==== useful ?? ===============
			'''''dbg_prt2 "restoring all CC after RTRUN"
			'''''For i As Integer = 1 To linenb 'restore CC
			'''''WriteProcessMemory(dbghand,Cast(LPVOID,rline(i).ad),@breakcpu,1,0)
			'''''Next
			'''''''==== end of code ===============
			'WriteProcessMemory(dbghand,Cast(LPVOID,rLine(rln).ad),@rLine(rln).sv,1,0) 'restore old value for execution
			'if rln<>rLine(brkol(0).index then ''case BP cond/etc and run to cursor/EOP/XOP
			'WriteProcessMemory(dbghand,Cast(LPVOID,rLine(brkol(0).index).ad),@rLine(brkol(0).index).sv,1,0) 'restore old value for execution
			'end if
			''?????	brk_test(proccurad) ' cancel breakpoint on line, if command halt not really used
			
			If brkol(0).typ<>10 Then ''for skip over always in same proc, if different thread ???
				dbg_prt2 "in gest_brk runnew"
				proc_runnew   'creating running proc tree
			End If
			var_sh			'updating information about variables
			
			runtype=RTSTEP   'now done when there is not anymore signal
			
			dsp_change(rln)
			If stopcode=CSLINE Then
				brk_del(0)
			ElseIf stopcode=CSBRKPT Then
				For ibrk As Integer	= 1 To brknb
					If brkol(ibrk).index=rln Then
						If brkol(ibrk).typ=5 Then
							brk_del(ibrk) ''remove tempo BP
							Exit For
						End If
					End If
				Next
			End If
			
		Else 'RTSTEP or RTAUTO
			If flagattach Then
				proc_runnew
				flagattach=False
			Else
				If proccurad=proc(procsv).first Then 'is first fbc instruction ?
					If procsk<>thread(threadcur).stack Then ''check if not in the current proc
						dbg_prt2 "going to proc_new",Hex(proccurad),Hex(proc(procsv).first)
						proc_new()
					End If
				ElseIf proccurad=proc(procsv).fn Then
					thread(threadcur).pe=True        'is last instruction ?
				End If
			End If
			'NOTA If rline(i).nu=-1 Then
			'fb_message("No line for this proc","Code added by compiler (constructor,...)")
			'Else
			dsp_change(rln)
			'EndIf
			
			
			''restore CC previous line
			If thread(threadcur).od<>-1 Then
				msgad=rline(thread(threadcur).od).ad
				dbg_prt2 "restoring 01 CC01 ad=";Hex(msgad)
				exec_order(KPT_CC)
			End If
			
			If runtype=RTAUTO Then
				Sleep(autostep)
				'thread_resume()
			End If
		End If
		
		If threadnewid Then
			If threadcur<>thread_index(threadnewid) Then
				dbg_prt2 "in gest brk exiting loop br_stop cur/new?";threadcur,threadnewid
				If threadnewidcount=1 Then
					dbg_prt2 "count=1 so exit br_stop"
					threadnewid=0
					threadnewidcount=0
					runtype=RTSTEP
					thread(threadcur).sts=KTHD_STOP
					thread_status()
					exec_order(KPT_EXIT)
				Else
					'' check if a signal is pending (maybe  a SIGTRAP for the new thread)
					dbg_prt2 "count=";threadnewidcount,"check signal pending"
					exec_order(KPT_SIGNAL)
					If statussaved Then ''exit br_stop for allowing waitpid
						dbg_prt2 "signal pending exit br_stop"
						exec_order(KPT_EXIT)
					Else
						dbg_prt2 "no signal pending so new thread out of scope"
						threadnewid=0 ''no signal pending so new thread out of scope
						threadnewidcount=0
						thread(threadnb).sts=KTHD_INIT
						If runtype=RTAUTO Then
							dbg_prt2 "auto resume all 00"
							thread_resume()
						End If
					End If
				End If
			Else
				dbg_prt2 "new thread threadnewidcount=";threadnewidcount
				exec_order(KPT_SIGNAL)
				If statussaved Then ''exit br_stop for allowing waitpid
					dbg_prt2 "signal pending exit br_stop"
					exec_order(KPT_EXIT)
				Else
					If runtype=RTAUTO Then
						dbg_prt2 "auto resume all 01"
						thread_resume()
					End If
				End If
				threadnewid=0
				threadnewidcount=0
				thread(threadnb).sts=KTHD_STOP
				thread_status()
			End If
		Else
			''when there are many signals from different threads
			
			exec_order(KPT_SIGNAL)
			If statussaved Then ''exit br_stop for allowing waitpid
				dbg_prt2 "OTHER signal pending exit br_stop=";Hex(statussaved)
				exec_order(KPT_EXIT)
			Else
				If runtype=RTAUTO Then
					dbg_prt2 "auto resume all 02"
					thread_resume()
				ElseIf runtype=RTSTEP And flaghalt Then
					flaghalt=False
					dbg_prt2 "step resume all"
					thread_resume()
				ElseIf runtype=RTRUN Then
					dbg_prt2 "rtrun changed in rtstep (no more signal)"
					runtype=RTSTEP
				End If
			End If
		End If
	End Sub
#endif
''====================== end for linux =========================

' when select a var for proc/var or set watched
Const PROCVAR=1
Const WATCHED=2

'Dim Shared dbgprocid As Integer     'pinfo.dwProcessId : debugged process id
'Dim Shared dbgthreadID As Integer   'pinfo.dwThreadId : debugged thread id
'Dim Shared dbghthread As HANDLE     'debuggee thread handle
'Dim Shared dbghfile  As HANDLE   	'debugged file handle

'Dim Shared flagmain As Byte     ' flag for first main
'Dim Shared flagverbose As Byte  ' flag for verbose mode
'Dim Shared flagtrace As Byte    ' flag for trace mode : 1 proc / +2 line
Dim Shared flagfollow As Integer =False 'flag to follow next executed line on focus window
'Dim Shared flagattach As Byte   ' flag for attach
'Dim Shared flagrestart As Integer=-1  'flag to indicate restart in fact number of bas files to avoid to reload those files
Dim Shared As Integer flagmodule,flagunion 'flag for dwarf
Dim Shared As Long dwlastprc,dwlastlnb 'to manage end of proc

'Dim Shared prun As Integer        	'indicateur process running
Dim Shared curlig As Integer  		'current line
Dim Shared curtab As UShort =0 		'associated wih curlig
Dim Shared shwtab As UShort =0 		'tab showed could be different of curtab

'Dim Shared flagkill   As Integer =False 'flag if killing process to avoid freeze in thread_del

Dim Shared inputval As ZString *25
Dim Shared inputtyp As Byte

'Dim Shared flagwtch As Integer =0 'flag =0 clean watched / 1 no cleaning in case of restart
'WATCH
Const WTCHMAIN=3
'Const WTCHMAX=9
Const WTCHALL=9999999
'Type twtch
'	hnd As HWND     'handle
'	tvl  As HTREEITEM 'tview handle
'	adr As UInteger 'memory address
'	typ As Integer  'type for var_sh2
'	pnt As Integer  'nb pointer
'	ivr As Integer  'index vrr
'	psk As Integer  'stk procr or -1 (empty)/-2 (memory)/-3 (non-existent local var)/-4 (session)
'	lbl As String   'name & type,etc
'	arr As UInteger 'ini for dyn arr
'	tad As Integer  'additionnal type
'	old As String   'keep previous value for tracing
'	idx As Integer  'index proc only for local var
'	dlt As Integer  'delta on stack only for local var
'	vnb As Integer  'number of level
'	vnm(10) As String   'name of var or component
'	vty(10) As String   'type
'	Var     As Integer  'array=1 / no array=0
'End Type
'Dim Shared wtch(WTCHMAX) As twtch
'Dim Shared wtchcpt As Integer 'counter of watched value, used for the menu
'Dim Shared hwtchbx As HWND    'handle
'Dim Shared wtchidx As Integer 'index for delete
'Dim Shared wtchexe(9,WTCHMAX) As String 'watched var (no memory for next execution)
'Dim Shared wtchnew As Integer 'to keep index after creating new watched

'Const LINEMAX = 100000
'ReDim rline(LINEMAX) As tline

'DIM ARRAY =========================================
'Const ARRMAX=1500
'Type tnlu
'	lb As UInteger
'	ub As UInteger
'End Type
'Type tarr 'five dimensions max
'	dm As UInteger
'	nlu(5) As tnlu
'End Type
'Dim Shared arr(ARRMAX) As tarr,arrnb As Integer
'var =============================
'Const VARMAX=20000 'CAUTION 3000 elements taken for globals
Const VGBLMAX=3000 'max globals
Const KBLOCKIDX=100 'max displayed lines inside index selection
'Type tvrb
'	nm As String    'name
'	typ As Integer  'type
'	adr As Integer  'address or offset
'	mem As UByte    'scope
'	arr As tarr Ptr 'pointer to array def
'	pt As Long      'pointer
'End Type
'Dim Shared vrbloc      As Integer 'pointer of loc variables or components (init VGBLMAX+1)
'Dim Shared vrbgbl      As Integer 'pointer of globals or components
'Dim Shared vrbgblprev  As Integer 'for dll, previous value of vrbgbl, initial 1
'Dim Shared vrbptr      As Integer Ptr 'equal @vrbloc or @vrbgbl
'Dim Shared vrb(VARMAX) As tvrb

'THREAD
'Type tthread
'	hd  As HANDLE    'handle
'	id  As UInteger  'ident
'	pe  As Integer   'flag if true indicates proc end
'	sv  As Integer   'sav line
'	od  As Integer   'previous line
'	nk  As UInteger  'for naked proc, stack and used as flag
'	st  As Integer   'to keep starting line
'	tv  As HTREEITEM 'to keep handle of thread item
'	plt As HTREEITEM 'to keep handle of last proc of thread in proc/var tview
'	ptv As HTREEITEM 'to keep handle of last proc of thread in thread tview
'	exc As Integer   'to indicate execution in case of auto 1=yes, 0=no
'End Type
'Const THREADMAX=500
'Dim Shared thread(THREADMAX) As tthread
'Dim Shared threadnb As Integer =-1
'Dim Shared threadcur As Integer
'Dim Shared threadprv As Integer     'previous thread used when mutexunlock released thread or after thread create
Dim Shared threadsel As Integer     'thread selected by user, used to send a message if not equal current
Dim Shared threadaut As Integer     'number of threads for change when  auto executing
'Dim Shared threadcontext As HANDLE
'Dim Shared threadhs As HANDLE       'handle thread to resume

' DATA STAB
'Type udtstab
'	stabs As Integer
'	code As UShort
'	nline As UShort
'	ad As UInteger
'End Type
'Enum 'type udt/redim/dim
'	TYUDT
'	TYRDM
'	TYDIM
'End Enum
'Enum
'	NODLL
'	DLL
'End Enum

#define MAXSRCSIZE 500000 'max source size
#define MAX_STAB_SZ 60000 'max stabs string '20/07/2014

'SOURCES
'Const MAXSRC=1000 							   'max 1000 sources
Dim Shared dbgsrc As String 			   'current source
Dim Shared dbgmaster As Integer 		   'index master source if include
Dim Shared dbgmain As Integer 		   'index main source proc entry point, to update dbgsrc see load_sources
Dim Shared srccomp(SRCMAX) As Long     'flag to keep the used compil option (gas=0, gcc=1, gcc+dwarf=2)
'Dim Shared sourcenb As Integer  =-1    'number of src
'ReDim source(MAXSRC) As String

Dim Shared As String compdir           'compil directory (dwarf)
Dim Shared compinfo As String   'information about compilation

'===== DLL
'Const DLLMAX=300
'Type tdll
'	As HANDLE   hdl 'handle to close
'	As UInteger bse 'base address
'	As HTREEITEM tv 'item treeview to delete
'	As Integer gblb 'index/number in global var table
'	As Integer gbln
'	As Integer  lnb 'index/number in line
'	As Integer  lnn
'	As String   fnm 'full name
'End Type
'Dim Shared As tdll dlldata(DLLMAX)
'Dim Shared As Integer dllnb 'use index base 1

'Dim Shared As Integer autostep=200 'delay for auto step
'Enum 'code stop
'	CSSTEP=0
'	CSCURSOR
'	CSBRKTEMPO
'	CSBRK
'	CSBRKV
'	CSBRKM
'	CSHALTBU
'	CSACCVIOL
'	CSNEWTHRD
'	CSEXCEP '19/05/2014
'End Enum
'Dim Shared stoplibel(20) As String*17 =>{"","cursor","tempo break","break","Break var","Break mem"_
',"Halt by user","Access violation","New thread","Exception"} '19/05/2014
Dim Shared stringadr As Integer
'#EndIf

runtype = RTOFF

#ifdef __FB_WIN32__
	'====================================================
	'' starts debuggee for windows
	'====================================================
	Private Sub start_pgm(p As Any Ptr)
		Dim  As Integer pclass,st
		Dim  As WString * 300 workdir, cmdl
		Dim sinfo As STARTUPINFO
		'directory
		st=0
		While InStr(st+1,exename,"\")
			st=InStr(st+1,exename,"\")
		Wend
		workdir=Left(exename,st)
		
		If cmdlimmediat<>"" Then
			cmdl=""""+exename+""" "+cmdlimmediat
			cmdlimmediat=""
		Else
			cmdl = """" + exename+ """ " '+cmdexe(0)
		End If
		
		#Ifdef fulldbg_prt
			dbg_prt (Date+" "+Time+"Start Debug with "+cmdl)
		#EndIf
		sinfo.cb = Len(sinfo)
		'Set the flags
		sinfo.dwFlags = STARTF_USESHOWWINDOW
		'Set the window's startup position
		sinfo.wShowWindow = SW_NORMAL
		'Set the priority class
		pclass = NORMAL_PRIORITY_CLASS Or CREATE_NEW_CONSOLE Or DEBUG_PROCESS Or DEBUG_ONLY_THIS_PROCESS
		'Start the program
		If CreateProcess(exename, @cmdl, ByVal NULL, ByVal NULL, False, pclass, _
			NULL, @workdir, @sinfo, @pinfo) Then
			'Wait
			WaitForSingleObject pinfo.hProcess, 10
			dbgprocid=pinfo.dwProcessId
			dbgthreadID=pinfo.dwThreadId
			dbghand=pinfo.hProcess
			dbghthread=pinfo.hThread
			#Ifdef fulldbg_prt
				dbg_prt ("Create process")
				dbg_prt ("pinfo.hThread "+Str(pinfo.hThread))
				dbg_prt ("pinfo.dwThreadId "+Str(pinfo.dwThreadId))
				dbg_prt ("hand "+Str(dbghand)+" Pid "+Str(dbgprocid))
			#EndIf
			prun=True
			'runtype=RTSTEP
			wait_debug()
		Else
			MsgBox("PROBLEM", "no debugged pgm -->" + exename+ Chr(10) + "error :" + Str(GetLastError()), MB_SYSTEMMODAL)
		End If
	End Sub
	'===================================================
	'' Loads dll elements
	'===================================================
	Private Sub dll_load()
		Dim loaddll As LOAD_DLL_DEBUG_INFO=*Cast(LOAD_DLL_DEBUG_INFO Ptr,debugdata) '' copy of data from thread 2
		Dim As String dllfn
		Dim As Integer d,delta,srcstart
		
		dllfn=dll_name(loaddll.hFile)
		'check yet loaded
		For i As Integer= 1 To dllnb
			If dllfn=dlldata(i).fnm Then d=i:Exit For
		Next
		
		If d=0 Then 'not found
			If dllnb>=DLLMAX Then 'limit reached
				hard_closing("New dll, Number of dll ("+Str(DLLMAX)+") exceeded , change the DLLMAX value."+Chr(10)+Chr(10)+"CLOSING FBDEBUGGER, SORRY")
			End If
			dllnb+=1
			dlldata(dllnb).hdl=loaddll.hFile
			dlldata(dllnb).bse=Cast(UInteger,loaddll.lpBaseOfDll)
			srcstart=sourcenb+1
			If debug_extract(Cast(UInteger,loaddll.lpBaseOfDll),dllfn,DLL)=-1 Then
				dllnb-=1
				'statusbar_text(KSTBSTS,"Running")
				Exit Sub
			End If
			If (linenb-linenbprev)=0 Then 'not debugged so not taking in account
				dllnb-=1
			Else
				'ResetAllComboBox(GFILELIST) ''as combobox completely refilled in init_debuggee
				init_debuggee(srcstart)
				
				dlldata(dllnb).fnm=dllfn
				dlldata(dllnb).gbln=vrbgbl-vrbgblprev
				dlldata(dllnb).gblb=vrbgblprev+1
				dlldata(dllnb).lnb=linenbprev+1
				dlldata(dllnb).lnn=linenb
			End If
		Else
			dlldata(d).hdl=loaddll.hFile
			delta=Cast(Integer,loaddll.lpBaseOfDll-dlldata(d).bse)
			If delta<>0 Then ''different address so need to change some thing
				''lines
				For i As Integer=dlldata(dllnb).lnb To dlldata(dllnb).lnb+dlldata(dllnb).lnb-1
					rline(i).ad+=delta
				Next
				''globals
				For i As Integer=dlldata(dllnb).gblb To dlldata(dllnb).gblb+dlldata(dllnb).gbln-1
					vrb(i).adr+=delta
				Next
			End If
			''normally done during debug_extract
			For i As Integer=dlldata(dllnb).lnb To dlldata(dllnb).lnb+dlldata(dllnb).lnb-1
				ReadProcessMemory(dbghand,Cast(LPCVOID,rline(i).ad),@rline(i).sv,1,0) 'sav 1 byte before writing breakcpu
				WriteProcessMemory(dbghand,Cast(LPVOID,rline(i).ad),@breakcpu,1,0)
			Next
			globals_load(d)
			brk_apply()
		End If
		'statusbar_text(KSTBSTS,"Running")
	End Sub
	'=====================================================================
	''finds the dll name
	'=====================================================================
	'Private Function dll_name(FileHandle As HANDLE,t As Integer =1 )As String ' t=1 --> full name, t=2 --> short name
	'	Dim As WString * 251 fileName
	'	Dim As ZString*512 zstr,dn,tzstr=" :"
	'	Dim As HANDLE hfileMap
	'	Dim As Long fileSizeHi,fileSizeLo,p
	'	Dim As Any Ptr pmem
	'	Dim As String tstring
	'	fileSizeLo = GetFileSize(FileHandle, @fileSizeHi)
	'	If fileSizeLo = 0 And fileSizeHi=0 Then Return "Empty file." ' cannot map an 0 byte file
	'	hfileMap = CreateFileMapping(FileHandle,0,PAGE_READONLY, 0, 1, NULL)
	'	If hfileMap Then
	'		pmem = MapViewOfFile(hfileMap,FILE_MAP_READ, 0, 0, 1)
	'		If pmem Then
	'			GetMappedFileName(GetCurrentProcess(), pmem, @fileName, 250)
	'			UnmapViewOfFile(pmem)
	'			CloseHandle(hfileMap)
	'			If Len(fileName) > 0 Then
	'				GetLogicalDriveStrings(511,zstr)'get all the device letters c:\ d:\ etc separate by null
	'				While zstr[p]
	'					tzstr[0]=zstr[p]'replace space by letter
	'					QueryDosDevice(tzstr,dn,511)'get corresponding device name
	'					If InStr(fileName,dn) Then
	'						tstring=fileName
	'						str_replace(tstring,dn,tzstr)
	'						If t=1 Then
	'							Return tstring 'full name
	'						Else
	'							Return source_name(tstring) ''extract only name without path
	'						End If
	'					End If
	'					p+=4'next letter skip ":\<null>"
	'				Wend
	'			Else
	'				Return "Empty filename."
	'			End If
	'		End If
	'	End If
	'	Return "Empty filemap handle."
	'End Function
	'===============================
	'' used with dbg_prt
	'================================
	Private Function CtrlHandler(fdwCtrlType As Integer) As Integer
		'PostMessage(windmain,WM_CLOSE,0,0)
		Return True
	End Function
	'========================
	'' open/close a console
	'========================
	'flaglog=0 --> no output / 1--> only screen / 2-->only file / 3 --> both
	Private Sub output_wds(t As String)
		Static As HANDLE scrnnumber
		Static As Integer filenumber
		Dim cpt As Long,libel As String
		Dim As COORD maxcoord
		Dim As CONSOLE_SCREEN_BUFFER_INFO csbi
		Dim As SMALL_RECT disparea=Type(0,0,0,0)
		Dim As Short maxcoordysav
		If t=" $$$$___CLOSE ALL___$$$$ " Then
			If scrnnumber<>0 And (flaglog And 1)=0 Then FreeConsole():scrnnumber=0
			If filenumber And (flaglog And 2)=0 Then Close filenumber:filenumber=0
			Exit Sub
		End If
		
		If scrnnumber=0 And (flaglog And 1) Then
			libel=Chr(13)+Chr(10)+Date+" "+Time+Chr(13)+Chr(10)
			AllocConsole()
			scrnnumber=GetStdHandle(STD_OUTPUT_HANDLE)
			SetConsoleTitle(StrPtr("FBdebugger trace/log"))
			maxcoord=GetLargestConsoleWindowSize(scrnnumber) 'max values displayed on screen
			maxcoordysav=maxcoord.Y
			GetConsoleScreenBufferInfo(scrnnumber,@csbi) 'max values using buffer/screen/font
			
			'change buffer size, only width
			maxcoord.X*=.5 'reducing by 50% of max possible
			maxcoord.Y=csbi.dwSize.Y 'no change
			SetConsoleScreenBufferSize(scrnnumber,maxcoord)
			
			'change display,
			disparea.Left=0
			disparea.Top=0
			disparea.Right=maxcoord.X-1
			disparea.Bottom=maxcoordysav*.8 '80% of height max possible
			SetConsoleWindowInfo(scrnnumber,True,@disparea)
			
			'align window on the left/top corner of screen
			SetWindowPos(GetConsoleWindow, 0, 10,10, 0, 0, SWP_NOSIZE Or SWP_NOZORDER)
			
			SetConsoleCtrlHandler(Cast(PHANDLER_ROUTINE,@CtrlHandler),True)
			WriteConsole(scrnnumber, StrPtr(libel),Len(libel),@cpt,0)
		End If
		
		If filenumber=0 And (flaglog And 2) Then
			filenumber=FreeFile:Open ExePath+"\dbg_log_file.txt"  For Append As filenumber
			Print #filenumber,Date,Time
		End If
		
		If (flaglog And 1) Then libel=t+Chr(13)+Chr(10):WriteConsole(scrnnumber, StrPtr(libel),Len(libel),@cpt,0)
		If (flaglog And 2) Then Print # filenumber,t
		
	End Sub
	
	'#IfNDef __USE_GTK__
	Private Function excep_lib(e As Integer) As String 'not managed exception
		Select Case e
		Case EXCEPTION_GUARD_PAGE_VIOLATION
			Return "EXCEPTION_GUARD_PAGE_VIOLATION"  '&H80000001
		Case EXCEPTION_DATATYPE_MISALIGNMENT
			Return "EXCEPTION_DATATYPE_MISALIGNMENT" '&H80000002
		Case EXCEPTION_SINGLE_STEP
			Return "EXCEPTION_SINGLE_STEP" '&H80000004
		Case EXCEPTION_ACCESS_VIOLATION '07/10/2014
			Return "EXCEPTION_ACCESS_VIOLATION" '&HC0000005
		Case EXCEPTION_IN_PAGE_ERROR
			Return "EXCEPTION_IN_PAGE_ERROR" '&HC0000006
		Case EXCEPTION_INVALID_HANDLE
			Return "EXCEPTION_INVALID_HANDLE" '&HC0000008
		Case EXCEPTION_NO_MEMORY
			Return "EXCEPTION_NO_MEMORY" '&HC0000017
		Case EXCEPTION_ILLEGAL_INSTRUCTION
			Return "EXCEPTION_ILLEGAL_INSTRUCTION" '&HC000001D
		Case EXCEPTION_NONCONTINUABLE_EXCEPTION
			Return "EXCEPTION_NONCONTINUABLE_EXCEPTION" '&HC0000025
		Case EXCEPTION_INVALID_DISPOSITION
			Return "EXCEPTION_INVALID_DISPOSITION" '&HC0000026
		Case EXCEPTION_ARRAY_BOUNDS_EXCEEDED
			Return "EXCEPTION_ARRAY_BOUNDS_EXCEEDED" '&HC000008C
		Case EXCEPTION_FLOAT_DENORMAL_OPERAND
			Return "EXCEPTION_FLOAT_DENORMAL_OPERAND" '&HC000008D
		Case EXCEPTION_FLOAT_DIVIDE_BY_ZERO
			Return "EXCEPTION_FLOAT_DIVIDE_BY_ZERO" '&HC000008E
		Case EXCEPTION_FLOAT_INEXACT_RESULT
			Return "EXCEPTION_FLOAT_INEXACT_RESULT" '&HC000008F
		Case EXCEPTION_FLOAT_INVALID_OPERATION
			Return "EXCEPTION_FLOAT_INVALID_OPERATION" '&HC0000090
		Case EXCEPTION_FLOAT_OVERFLOW
			Return "EXCEPTION_FLOAT_OVERFLOW" '&HC0000091
		Case EXCEPTION_FLOAT_STACK_CHECK
			Return "EXCEPTION_FLOAT_STACK_CHECK" '&HC0000092
		Case EXCEPTION_FLOAT_UNDERFLOW
			Return "EXCEPTION_FLOAT_UNDERFLOW" '&HC0000093
		Case EXCEPTION_INTEGER_DIVIDE_BY_ZERO
			Return "EXCEPTION_INTEGER_DIVIDE_BY_ZERO" '&HC0000094
		Case EXCEPTION_INTEGER_OVERFLOW
			Return "EXCEPTION_INTEGER_OVERFLOW" '&HC0000095
		Case EXCEPTION_PRIVILEGED_INSTRUCTION
			Return "EXCEPTION_PRIVILEGED_INSTRUCTION" '&HC0000096
		Case EXCEPTION_STACK_OVERFLOW
			Return "EXCEPTION_STACK_OVERFLOW" '&HC00000FD
		Case EXCEPTION_CONTROL_C_EXIT
			Return "EXCEPTION_CONTROL_C_EXIT" '&HC000013A
		Case DBG_CONTROL_C
			Return "DBG_CONTROL_C" '&h40010005
		Case DBG_TERMINATE_PROCESS
			Return "DBG_TERMINATE_PROCESS" '&h40010004
		Case DBG_TERMINATE_THREAD
			Return "DBG_TERMINATE_THREAD"  '&h40010003
		Case DBG_CONTROL_BREAK
			Return "DBG_CONTROL_BREAK"  '&h40010008
		Case Else
			Return "Unknown Exception code (D/H)= "+Str(e)+" / "+Hex(e) '07/10/2014
		End Select
	End Function
	
	Private Sub str_replace(strg As String,srch As String, repl As String)
		Dim As Integer p,lgr=Len(repl),lgs=Len(srch)
		p=InStr(strg,srch)
		While p
			strg=Left(strg,p-1)+repl+Mid(strg,p+lgs)
			p=InStr(p+lgr,strg,srch)
		Wend
	End Sub
	
	Private Function name_extract(a As String) As String 'extract file name for full name
		Dim i As Integer
		For i=Len(a) To 1 Step -1
			If a[i-1]=Asc(":") Or a[i-1]=Asc("\") Or a[i-1]=Asc("/") Then Exit For
		Next
		Return Mid(a,i+1)
	End Function
	
	Private Function dll_name(FileHandle As HANDLE, t As Integer = 1) As String ' t=1 --> full name, t=2 --> short name
		Dim As WString * 251 fileName
		Dim As WString * 512 zstr, dn, tzstr = " :"
		Dim As HANDLE hfileMap
		Dim As Long fileSizeHi, fileSizeLo, p
		Dim As Any Ptr pmem
		Dim As String tstring
		fileSizeLo = GetFileSize(FileHandle, @fileSizeHi)
		If fileSizeLo = 0 And fileSizeHi=0 Then Return "Empty file." ' cannot map an 0 byte file
		hfileMap = CreateFileMapping(FileHandle,0,PAGE_READONLY, 0, 1, NULL)
		If hfileMap Then
			pmem = MapViewOfFile(hfileMap,FILE_MAP_READ, 0, 0, 1)
			If pmem Then
				GetMappedFileName(GetCurrentProcess(), pmem, @fileName, 250)
				UnmapViewOfFile(pmem)
				CloseHandle(hfileMap)
				If Len(fileName) > 0 Then
					GetLogicalDriveStrings(511,zstr)'get all the device letters c:\ d:\ etc separate by null
					While zstr[p]
						tzstr[0]=zstr[p]'replace space by letter
						QueryDosDevice(tzstr,dn,511)'get corresponding device name
						If InStr(fileName,dn) Then
							tstring=fileName
							str_replace(tstring,dn,tzstr)
							If t=1 Then
								Return tstring 'full name
							Else
								Return name_extract(tstring)'extract only name without path
							End If
						End If
						p+=4'next letter skip ":\<null>"
					Wend
				Else
					Return "Empty filename."
				End If
			End If
		End If
		Return "Empty filemap handle."
	End Function
	
	Private Sub compinfo_load(basedata As UInteger, sizedata As UInteger)
		ReDim As Byte buffer(sizedata)
		Dim  As UInteger idx=0,find,limit
		Dim As String strg="$$__COMPILINFO__$$"
		Dim As String wstrg="$$__COMPILINFO__$$"
		Dim As WString Ptr wsptr
		Dim As ZString Ptr pzstrg
		
		ReadProcessMemory(dbghand,Cast(LPCVOID,basedata),@buffer(0),sizedata,0)
		
		While idx<sizedata-17
			find=True
			For i As Integer =0 To Len(strg)-1
				If buffer(idx+i)<>strg[i] Then find=False:Exit For
			Next
			If find Then
				pzstrg=@buffer(idx)
				compinfo=*pzstrg
				Exit While
			End If
			idx+=1
		Wend
		idx=Cast(UInteger,@buffer(0))
		'unicode search
		limit=Cast(UInteger,idx)+sizedata-32
		While idx<limit
			wsptr=Cast(WString Ptr,idx)
			If Left(*wsptr,18)=wstrg Then
				compinfo=*wsptr
				Exit While
			End If
			idx+=1
		Wend
		
		ReDim As Byte recup(0)'reduce size of buffer
	End Sub
	'UDT ==============================
	'Type tudt
	'	nm As String  'name of udt
	'	lb As Integer 'lower limit for components
	'	ub As Integer 'upper
	'	lg As Integer 'lenght
	'	en As Integer 'flag if enum 1 or 0
	'	index As Integer 'dwarf
	'	what As Integer 'dwarf udt/pointer/array
	'	typ As Integer 'dwarf
	'	dimnb As Long 'dwarf
	'	bounds(5) As UInteger 'dwarf
	'End Type
	'Type tcudt
	'	nm As String    'name of components or text for enum
	'	Union
	'		typ As Integer  'type
	'		Val As Integer  'value for enum
	'	End Union
	'	ofs As UInteger 'offset
	'	ofb As UInteger 'rest offset bits
	'	lg As UInteger  'lenght
	'	arr As tarr Ptr 'arr ptr
	'	pt As Long
	'End Type
	'Const TYPEMAX=80000,CTYPEMAX=100000
	'CAUTION : TYPEMAX is the type for bitfield so the real limit is typemax-1
	'Dim Shared udt(TYPEMAX) As tudt,udtidx As Integer
	'Dim Shared cudt(CTYPEMAX) As tcudt,cudtnb As Integer,cudtnbsav As Integer
	'in case of module or DLL the udt number is initialized each time
	'Dim Shared As Integer udtcpt,udtmax 'current, max cpt
	
	'for use show char at a given position
	#define AFFMAX 40
	#define AFFMAX2 AFFMAX*2
	#define RECUPMAX 1000
	
	'#define TYPESTD 16 ''upper limit for standard type, now 16 for boolean 20/08/2015
	
	'GCC
	Dim Shared As Byte    gengcc       ' flag for compiled with gcc
	ReDim Shared As String Trans()
	Dim   Shared As String stringarray
	'END GCC
	
	Private Function cutup_op (op As String) As String
		Select Case  op
		Case "aS"
			Function = "Let"
		Case "pl"
			Function = "+"
		Case "pL"
			Function = "+="
		Case "mi"
			Function = "-"
		Case "mI"
			Function = "-="
		Case "ml"
			Function = "*"
		Case "mL"
			Function = "*="
		Case "dv"
			Function = "/"
		Case "dV"
			Function = "/="
		Case "Dv"
			Function = "\"
		Case "DV"
			Function = "\="
		Case "rm"
			Function = "mod"
		Case "rM"
			Function = "mod="
		Case "an"
			Function = "and"
		Case "aN"
			Function = "and="
		Case "or"
			Function = "or"
		Case "oR"
			Function = "or="
		Case "aa"
			Function = "andalso"
		Case "aA"
			Function = "andalso="
		Case "oe"
			Function = "orelse"
		Case "oE"
			Function = "orelse="
		Case "eo"
			Function = "xor"
		Case "eO"
			Function = "xor="
		Case "ev"
			Function = "eqv"
		Case "eV"
			Function = "eqv="
		Case "im"
			Function = "imp"
		Case "iM"
			Function = "imp="
		Case "ls"
			Function = "shl"
		Case "lS"
			Function = "shl="
		Case "rs"
			Function = "shr"
		Case "rS"
			Function = "shr="
		Case "po"
			Function = "^"
		Case "pO"
			Function = "^="
		Case "ct"
			Function = "&"
		Case "cT"
			Function = "&="
		Case "eq"
			Function = "eq"
		Case "gt"
			Function = "gt"
		Case "lt"
			Function = "lt"
		Case "ne"
			Function = "ne"
		Case "ge"
			Function = "ge"
		Case "le"
			Function = "le"
		Case "nt"
			Function = "not"
		Case "ng"
			Function = "neg"
		Case"ps"
			Function = "ps"
		Case "ab"
			Function = "ab"
		Case "fx"
			Function = "fix"
		Case "fc"
			Function = "frac"
		Case "sg"
			Function = "sgn"
		Case "fl"
			Function = "floor"
		Case "nw"
			Function = "new"
		Case "na"
			Function = "new []?"
		Case "dl"
			Function = "del"
		Case "da"
			Function = "del[]?"
		Case "de"
			Function = "."
		Case "pt"
			Function = "->"
		Case "ad"
			Function = "@"
		Case "fR"
			Function = "for"
		Case "sT"
			Function = "step"
		Case "nX"
			Function = "next"
		Case "cv"
			Function = "Cast"
		Case "C1"
			Function = "(Constructor)" '02/11/2014
		Case "D1"
			Function = "(Destructor)"
		Case Else
			Function = "Unknow"
		End Select
	End Function
#endif

'#ifdef  __fb_linux__
#define of_entry &h18
#ifdef __FB_64BIT__
	#define of_section &h28
	#define of_section_size &h3A
	#define of_section_num &h3C
	#define of_section_str &h3E
	#define sect_size &h40
	#define of_offset_infile &h18
	#define of_size_infile &h20
	Union ustab
		full As LongInt
		Type
			offst As Long
			cod As Short
			desc As Short
		End Type
	End Union
#else
	#define of_section &h20 ''section header table
	#define of_section_size &h2E ''size of a section header table entry
	#define of_section_num &h30 ''number of entries in SHT
	#define of_section_str &h32 ''
	#define sect_size &h28  '' size of section header
	#define of_offset_infile &h10 ''offset of the section in file image
	#define of_size_infile &h14 ''size in bytes
	Type ustab
		offst As Long
		cod As Short
		desc As Short
	End Type
#endif
'#endif
'--------------------------------------
'' check if local var already stored
'--------------------------------------
Private Function local_exist() As Long
	Dim ad As UInteger=vrb(vrbloc).adr
	For i As Integer = proc(procnb).vr To proc(procnb+1).vr-2
		If vrb(i).adr=ad AndAlso vrb(i).nm=vrb(vrbloc).nm Then
			vrbloc-=1
			proc(procnb+1).vr-=1
			Return True 'return true if variable local already stored
		End If
	Next
	Return False
End Function
'------------------------------------
'' check if common already stored
'------------------------------------
Private Function Common_exist(ad As UInteger) As Integer
	For i As Integer = 1 To vrbgbl
		If vrb(i).adr=ad Then Return True 'return true if common already stored
	Next
	Return False
End Function
'---------------------------------
'' check if enum already stored
'---------------------------------
Private Sub enum_check(idx As Integer)
	For i As Integer =1 To udtmax-1
		If udt(i).en Then 'enum
			If udt(idx).nm=udt(i).nm Then 'same name
				If udt(idx).ub-udt(idx).lb=udt(i).ub-udt(i).lb Then 'same number of elements
					If cudt(udt(idx).ub).nm=cudt(udt(i).ub).nm Then 'same name for last element
						If cudt(udt(idx).lb).nm=cudt(udt(i).lb).nm Then 'same name for first element
							'enum are considered same
							udt(idx).lb=udt(i).lb:udt(idx).ub=udt(i).ub
							udt(idx).en=i
							cudtnb=cudtnbsav
							Exit Sub
						End If
					End If
				End If
			End If
		End If
	Next
End Sub
'------------------------
'' parse variable names
'------------------------
Private Function parse_name(strg As String) As String
	'"__ZN9TESTNAMES2XXE:S1
	Dim As Integer p,d
	Dim As String nm,strg2,nm2
	p=InStr(strg,"_ZN")
	strg2=Mid(strg,p+3,999)
	p=Val(strg2)
	If p>9 Then d=3 Else d=2
	nm=Mid(strg2,d,p)
	strg2=Mid(strg2,d+p)
	p=Val(strg2)
	If p>9 Then d=3 Else d=2
	nm2=Mid(strg2,d,p)
	Return nm+"."+nm2
End Function
'----------------
'' parse arrays
'----------------
Private Function parse_array(gv As String,d As Integer,f As Byte) As Integer
	Dim As Integer p=d,q,c
	
	If arrnb>ARRMAX Then hard_closing("Max array reached limit="+Str(ARRMAX))
	arrnb+=1
	
	'While gv[p-1]=Asc("a")
	While InStr(p,gv,"ar")
		'GCC todo remove
		'p+=4
		
		If InStr(gv,"=r(")Then
			p=InStr(p,gv,";;")+2 'skip range =r(n,n);n;n;;
		Else
			p=InStr(p,gv,";")+1 'skip ar1;
		End If
		
		q=InStr(p,gv,";")
		'END GCC
		arr(arrnb).nlu(c).lb=Val(Mid(gv,p,q-p)) 'lbound
		
		p=q+1
		q=InStr(p,gv,";")
		arr(arrnb).nlu(c).ub=Val(Mid(gv,p,q-p))'ubound
		'''arr(arrnb).nlu(c).nb=arr(arrnb).nlu(c).ub-arr(arrnb).nlu(c).lb+1 'dim
		p=q+1
		c+=1
	Wend
	arr(arrnb).dm=c 'nb dim
	If f=TYDIM Then
		vrb(*vrbptr).arr=@arr(arrnb)
	Else
		cudt(cudtnb).arr=@arr(arrnb)
	End If
	Return p
End Function
'--------------------------
'' parse returned value
'--------------------------
Private Sub parse_retval(prcnb As Integer,gv2 As String)
	'example :f7 --> private sub /  :F18=*19=f7" --> public sub ptr / :f18=*19=*1 --> private integer ptr ptr
	Dim p As Integer,c As Integer,e As Integer
	For p=0 To Len(gv2)-1
		If gv2[p]=Asc("*") Then c+=1
		If gv2[p]=Asc("=") Then e=p+1
	Next
	If c Then 'pointer
		If InStr(gv2,"=f") OrElse InStr(gv2,"=F") Then
			If InStr(gv2,"=f7") OrElse InStr(gv2,"=F7") Then
				p=200+c 'sub
			Else
				p=220+c 'function
			End If
		Else
			If gv2[e]=Asc("*")Then e+=1
			p=c
		End If
	Else
		p=0
	End If
	c=Val(Mid(gv2,e+1))
	'workaround with gas boolean are not correctly defined type value 15 instead 16 so change the value as pchar (15) is not used
	'done also with simple and array var
	'dbg_prt2("cut up=2"+vrb(*vrbptr).nm+" value c="+Str(c))
	If c=15 Then c=16
	'========================================================
	
	If c>TYPESTD Then c+=udtcpt
	proc(prcnb).pt=p
	proc(prcnb).rv=c
End Sub
'------------------
'' parse scopes
'------------------
Private Function parse_scope(gv As Byte, ad As UInteger,dlldelta As Integer=0) As Integer
	Select Case gv
	Case Asc("S"),Asc("G")     'shared/common
		If gv=Asc("G") Then If Common_exist(ad) Then Return 0 'to indicate that no needed to continue
		If vrbgbl=VGBLMAX Then hard_closing("Init Globals reached limit "+Str(VGBLMAX))
		vrbgbl+=1
		vrb(vrbgbl).adr=ad
		vrbptr=@vrbgbl
		Select Case gv
		Case Asc("S")		'shared
			vrb(vrbgbl).mem=2
			vrb(vrbgbl).adr+=dlldelta 'in case of relocation dll, all shared addresses are relocated
		Case Asc("G")     'common
			vrb(vrbgbl).mem=6
		End Select
		Return 2
	Case Else
		If vrbloc=VARMAX Then hard_closing("Init locals reached limit="+Str(VARMAX-3000))
		vrbloc+=1
		vrb(vrbloc).adr=ad
		vrbptr=@vrbloc
		proc(procnb+1).vr=vrbloc+1 'just to have the next beginning
		Select Case gv
		Case Asc("V")     'static
			vrb(vrbloc).mem=3
			Return 2
		Case Asc("v")     'byref parameter
			vrb(vrbloc).mem=4
			Return 2
		Case Asc("p")     'byval parameter
			vrb(vrbloc).mem=5
			Return 2
		Case Else         'local
			vrb(vrbloc).mem=1
			Return 1
		End Select
	End Select
End Function
'--------------------------------------------
'' parse
'--------------------------------------------
Private Sub parse_var2(gv As String,f As Byte)
	Dim p As Integer=1,c As Integer,e As Integer,gv2 As String,pp As Integer
	If InStr(gv,"=")=0 Then
		c=Val(Mid(gv,p,9))
		'workaround with gas boolean are not correctly defined type value 15 instead 16 so change the value as pchar (15) is not used
		'done also with array just below and param
		'dbg_prt2("cut up=2"+vrb(*vrbptr).nm+" value c="+Str(c))
		If c=15 Then c=16
		'==================================
		
		If c>TYPESTD Then c+=udtcpt 'udt type so adding the decal
		pp=0
		If f=TYUDT Then
			cudt(cudtnb).typ=c
			cudt(cudtnb).pt=pp
			cudt(cudtnb).arr=0 'by default not an array
		Else
			vrb(*vrbptr).typ=c
			vrb(*vrbptr).pt=pp
			vrb(*vrbptr).arr=0 'by default not an array
		End If
	Else
		If InStr(gv,"=ar1") Then p=parse_array(gv,InStr(gv,"=ar1")+1,f)
		gv2=Mid(gv,p)
		For p=0 To Len(gv2)-1
			If gv2[p]=Asc("*") Then c+=1
			If gv2[p]=Asc("=") Then e=p+1
		Next
		If c Then 'pointer
			If InStr(gv2,"=f") Then 'proc
				If InStr(gv2,"=f7") Then
					pp=200+c 'sub
				Else
					pp=220+c 'function
				End If
			Else
				pp=c
				If gv2[e]=Asc("*")Then e+=1
			End If
		Else
			pp=0
		End If
		c=Val(Mid(gv2,e+1))
		
		'workaround with gas boolean are not correctly defined type value 15 instead 16 so change the value as pchar (15) is not used
		'done also with simple var and param
		'dbg_prt2("cut up=2"+vrb(*vrbptr).nm+" value c="+Str(c))
		If c=15 Then c=16
		'========================================================
		
		If c>TYPESTD Then c+=udtcpt 'udt type so adding the decal 20/08/2015
		If f=TYUDT Then
			cudt(cudtnb).pt=pp
			cudt(cudtnb).typ=c
		Else
			vrb(*vrbptr).pt=pp
			vrb(*vrbptr).typ=c
		End If
	End If
End Sub

'------------
'' parse udt
'------------
Private Sub parse_udt(readl As String)
	Dim As Integer p,q,lgbits
	Dim As String tnm
	p=InStr(readl,":")
	
	tnm=Left(readl,p-1)
	If InStr(readl,":Tt") Then
		p+=3 'skip :Tt
	Else
		p+=2 'skip :T  GCC
	End If
	'dbg_prt2 "parse_udt=";readl
	q=InStr(readl,"=")
	
	udtidx=Val(Mid(readl,p,q-p))
	
	udtidx+=udtcpt:If udtidx>udtmax Then udtmax=udtidx
	If udtmax > TYPEMAX-1 Then hard_closing("Storing UDT limit reached "+Str(TYPEMAX))
	udt(udtidx).nm=tnm
	If Left(tnm,4)="TMP$" Then Exit Sub 'gcc redim
	p=q+2
	q=p-1
	While readl[q]<64
		q+=1
	Wend
	q+=1
	udt(udtidx).lg=Val(Mid(readl,p,q-p))
	p=q
	udt(udtidx).lb=cudtnb+1
	While readl[p-1]<>Asc(";")
		'dbg_prt("STORING CUDT "+readl)
		If cudtnb = CTYPEMAX Then hard_closing("Storing CUDT limit reached "+Str(CTYPEMAX))
		cudtnb+=1
		
		q=InStr(p,readl,":")
		cudt(cudtnb).nm=Mid(readl,p,q-p) 'variable name
		p=q+1
		q=InStr(p,readl,",")
		
		parse_var2(Mid(readl,p,q-p),TYUDT) 'variable type
		
		''new way for redim
		If Left(udt(cudt(cudtnb).typ).nm,7)="FBARRAY" Then
			
			'.stabs "__FBARRAY1:Tt25=s32DATA:26=*1,0,32;PTR:27=*7,32,32;SIZE:1,64,32;ELEMENT_LEN:1,96,32;DIMENSIONS:1,128,32;DIMTB:28=ar1;0;0;29,160,96;;",128,0,0,0
			'.stabs "TTEST2:Tt23=s40VVV:24=ar1;0;1;2,0,16;XXX:1,32,32;ZZZ:25,64,256;;",128,0,0,0
			'.stabs "__FBARRAY1:Tt21=s32DATA:22=*23,0,32;PTR:30=*7,32,32;SIZE:1,64,32;ELEMENT_LEN:1,96,32;DIMENSIONS:1,128,32;DIMTB:31=ar1;0;0;29,160,96;;",128,0,0,0
			'.stabs "TTEST:Tt20=s56AAA:3,0,8;BBB:21,32,256;CCC:32=ar1;1;2;10,320,128;;",128,0,0,0
			'.stabs "__FBARRAY8:Tt18=s116DATA:19=*20,0,32;PTR:33=*7,32,32;SIZE:1,64,32;ELEMENT_LEN:1,96,32;DIMENSIONS:1,128,32;DIMTB:34=ar1;0;0;29,160,768;;",128,0,0,0
			'.stabs "VTEST:18",128,0,0,-176
			cudt(cudtnb).pt=cudt(udt(cudt(cudtnb).typ).lb).pt-1 'pointer always al least 1 so reduce by one
			cudt(cudtnb).typ=cudt(udt(cudt(cudtnb).typ).lb).typ 'real type
			cudt(cudtnb).arr=Cast(tarr Ptr,-1) 'defined as dyn arr
			
			'dbg_prt2("dyn array="+cudt(cudtnb).nm+" "+Str(cudt(cudtnb).typ)+" "+Str(cudt(cudtnb).pt)+" "+cudt(udt(cudt(cudtnb).typ).lb).nm)
		End If
		'end new redim
		
		p=q+1
		q=InStr(p,readl,",")
		cudt(cudtnb).ofs=Val(Mid(readl,p,q-p))  'bits offset / beginning
		p=q+1
		q=InStr(p,readl,";")
		lgbits=Val(Mid(readl,p,q-p))	'length in bits
		
		If cudt(cudtnb).typ<>4 And cudt(cudtnb).pt=0 And cudt(cudtnb).arr=0 Then 'not zstring, pointer,array !!!
			If lgbits<>udt(cudt(cudtnb).typ).lg*8 Then 'bitfield
				cudt(cudtnb).typ=TYPEMAX 'special type for bitfield
				cudt(cudtnb).ofb=cudt(cudtnb).ofs-(cudt(cudtnb).ofs\8) * 8 ' bits mod byte
				cudt(cudtnb).lg=lgbits  'length in bits
			End If
		End If
		''''''''''''''''''EndIf 'end change 17/04/2014
		p=q+1
		cudt(cudtnb).ofs=cudt(cudtnb).ofs\8 'offset bytes
	Wend
	udt(udtidx).ub=cudtnb
End Sub

'----------------
'' parse enum
'----------------
Private Sub parse_enum(readl As String)
	'.stabs "TENUM:T26=eESSAI:5,TEST08:8,TEST09:9,TEST10:10,FIN:99,;",128,0,0,0
	Dim As Integer p,q
	Dim As String tnm
	p=InStr(readl,":")
	tnm=Left(readl,p-1)
	p+=2 'skip :T
	q=InStr(readl,"=")
	udtidx=Val(Mid(readl,p,q-p))
	udtidx+=udtcpt:If udtidx>udtmax Then udtmax=udtidx
	If udtmax > TYPEMAX Then hard_closing("Storing ENUM="+tnm+" limit reached "+Str(TYPEMAX))
	udt(udtidx).nm=tnm 'enum name
	
	udt(udtidx).en=udtidx 'flag enum, in case of already treated use same previous cudt
	udt(udtidx).lg=Len(Integer) 'same size as integer
	'each cudt contains the value (typ) and the associated text (nm)
	udt(udtidx).lb=cudtnb+1
	p=q+2
	cudtnbsav=cudtnb 'save value for restoring see enum_check
	If InStr(readl,";")=0 Then
		cudtnb+=1
		cudt(cudtnb).nm="DUMMY"
		cudt(cudtnb).Val=0
		MsgBox("Storing ENUM=" + tnm & ": Data not correctly formated "): Exit Sub
	Else
		While readl[p-1]<>Asc(";")
			q=InStr(p,readl,":") 'text
			If cudtnb>=CTYPEMAX Then hard_closing("Storing ENUM="+tnm+" limit reached "+Str(CTYPEMAX))
			cudtnb+=1
			cudt(cudtnb).nm=Mid(readl,p,q-p)
			
			p=q+1
			q=InStr(p,readl,",") 'value
			cudt(cudtnb).Val=Val(Mid(readl,p,q-p))
			p=q+1
			
		Wend
	End If
	udt(udtidx).ub=cudtnb
	enum_check(udtidx) 'eliminate duplicates
End Sub
'-------------------
'' parse variables
'-------------------
Private Sub parse_var(gv As String,ad As UInteger, dlldelta As Integer=0)
	Dim p As Integer
	Static defaulttype As Integer
	Dim As String vname
	
	If InStr(gv,"va_list:t") Then 'last default type
		defaulttype=0
	ElseIf InStr(gv,"integer:t") Then
		defaulttype=1
	End If
	
	If defaulttype Then Exit Sub
	
	'=====================================================
	vname=Left(gv,InStr(gv,":")+1)
	
	p=InStr(vname,"$")
	If p=0 Then 'no $ in the string
		If InStr(vname,":t")<>0 Then
			If UCase(Left(vname,InStr(vname,":")))<>Left(vname,InStr(vname,":")) Then
				Exit Sub 'don't keep  <lower case name>:t, keep <upper case name>:t  => enum
			End If
		ElseIf InStr(vname,"_ZTSN")<>0  OrElse InStr(vname,"_ZTVN")<>0 Then
			Exit Sub 'don't keep _ZTSN or _ZTVN (extra data for class) or with double underscore  __Z
		End If
		'dbg_prt2 "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ VNAME=";vname
		If Left(vname,3)="LT_" Then 'LT_xxxx
			Exit Sub
		ElseIf Left(vname,2)="_{" Then '_{fbdata}_<label name>
			Exit Sub
		ElseIf Left(vname,3)=".Lt" Then '.Ltxxxx used with data
			Exit Sub
		ElseIf Left(vname,3)="Lt_" Then 'Lt_xxxx used with extern and array
			Exit Sub
		End If
		'dbg_prt2 "parse_var=";gv
	Else '$ in the string
		If InStr(p+1,vname,"$") <>0 AndAlso InStr(vname,"$fb_Object")=0 Then
			Exit Sub 'don't keep TMP$xx$xx:
		End If
		'''''''''''''If InStr(vname,":T")<>0 OrElse InStr(vname,":t")<>0 Then
		'$9CABRIOLET:T(0,51)=s16$BASE:(0,48),0,128;;
		If InStr(vname,":t")<>0 Then 'InStr(vname,":T")<>0 OrElse InStr(vname,":t")<>0 Then
			If Left(vname,5)<>"$fb_O" AndAlso Left(vname,4)<>"TMP$" Then  'redim
				Exit Sub 'don't keep
			End If
		End If
		If InStr(vname,"$fb_RTTI") OrElse InStr(vname,"fb$result$") Then
			Exit Sub 'don't keep
		End If
		If Left(vname,3)="vr$" OrElse Left(vname,4)="tmp$" Then
			Exit Sub 'don't keep  vr$xx: or tmp$xx$xx:
		End If
		'eliminate $ and eventually the number at the end of name ex udt$1 --> udt
		If Left(vname,4)<>"TMP$" Then ' use with redim
			If p<>1 Then gv=Left(gv,p-1)+Mid(gv,InStr(gv,":"))
		End If
	End If
	'======================================================
	If InStr(gv,";;") Then 'defined type or redim var
		If InStr(gv,":T") Then 'GCC change ":Tt" in just ":T"
			'UDT
			parse_udt(gv)
		Else
			'REDIM
			If parse_scope(gv[InStr(gv,":")],ad,dlldelta)=0 Then Exit Sub 'Scope / increase number and put adr
			'if common exists return 0 so exit sub
			vrb(*vrbptr).nm=Left(gv,InStr(gv,":")-1) 'var or parameter
			
			'.stabs "VTEST:22=s32DATA:25=*23=24=*1,0,32;PTR:26=*23=24=*1,32,32;SIZE:1,64,32;ELEMENT_LEN:1,96,32;DIMENSIONS:1,128,32;dim1_ELEMENTS:1,160,32;dim1_LBOUND:1,192,32;
			'dim1_UBOUND:1,224,32;;
			'DATA:27=*dim1_20=*21,0,32;PTR:28=*dim1_20=*21,32,32;SIZE:1,64,32;ELEMENT_LEN:1,96,32;DIMENSIONS:1,128,32;dim1_ELEMENTS:1,160,32;
			'dim1_LBOUND:1,192,32;dim1_UBOUND:1,224,32;;21",128,0,0,-168
			
			p=InStr(gv,";;")+2 ' case dyn var including dyn array field...... 21/04/2014 to be removed when 0.91 is released
			While InStr(p,gv,";;")<>0 '29/04/2014
				p=InStr(p,gv,";;")+2
			Wend
			
			parse_var2(Mid(gv,p),TYRDM) 'datatype
			vrb(*vrbptr).arr=Cast(tarr Ptr,-1) 'redim array
		End If
	ElseIf InStr(gv,"=e") Then
		'ENUM
		parse_enum(gv)
	Else
		'DIM
		If InStr(gv,"FDBG_COMPIL_INFO") Then Exit Sub
		If gv[0]=Asc(":") Then Exit Sub 'no name, added by compiler don't take it
		p=parse_scope(gv[InStr(gv,":")],ad,dlldelta)'Scope / increase number and put adr
		If p=0 Then Exit Sub 'see redim
		If InStr(gv,"_ZN") AndAlso InStr(gv,":") Then
			vrb(*vrbptr).nm=parse_name(gv) 'namespace
		Else
			vrb(*vrbptr).nm=Left(gv,InStr(gv,":")-1) 'var or parameter
			'to avoid two lines in proc/var tree, case dim shared array and use of erase or u/lbound
			If vrb(*vrbptr).mem=2 AndAlso vrb(*vrbptr).nm=vrb(*vrbptr-1).nm Then 'check also if shared
				*vrbptr-=1 'decrement pointed value, vrbgbl in this case
				Exit Sub
			End If
			If vrb(*vrbptr).mem=1 Then ''local var ''2016/08/12
				If local_exist Then Exit Sub'' check if same adr and name exist (case several for loops repeated with the same iterator)
			End If
		End If
		parse_var2(Mid(gv,InStr(gv,":")+p),TYDIM)
		'11/05/2014 'new way for redim
		If Left(udt(vrb(*vrbptr).typ).nm,7)="FBARRAY" Then 'new way for redim array
			
			'.stabs "__FBARRAY2:Tt23=s44DATA:24=*10,0,32;PTR:25=*7,32,32;SIZE:1,64,32;ELEMENT_LEN:1,96,32;DIMENSIONS:1,128,32;DIMTB:26=ar1;0;1;22,160,192;;",128,0,0,0
			'.stabs "MYARRAY2:S23",38,0,0,_MYARRAY2
			vrb(*vrbptr).pt=cudt(udt(vrb(*vrbptr).typ).lb).pt-1 'pointer always al least 1 so reduce by one
			vrb(*vrbptr).typ=cudt(udt(vrb(*vrbptr).typ).lb).typ 'real type
			vrb(*vrbptr).arr=Cast(tarr Ptr,-1) 'defined as dyn arr
			
			'dbg_prt2("dyn array="+vrb(*vrbptr).nm+" "+Str(vrb(*vrbptr).typ)+" "+Str(vrb(*vrbptr).pt)+" "+cudt(udt(vrb(*vrbptr).typ).lb).nm)
		End If
		'end new redim
	End If
End Sub

Private Function parse_typeope(vchar As Long) As String
	'RPiR8vector2D or R8vector2DS0_ or R8FBSTRINGR8VECTOR2D
	Dim As Long typ
	
	If vchar=Asc("P") Then
		Return "*" 'pointer
	Else
		'l=long/m=unsigned long/n=__int128/o=unsigned __int128/e=long double, __float80
		Select Case vchar
		Case Asc("i")
			typ=1
		Case Asc("a")
			typ=2
		Case Asc("h")
			typ=3
			'Case Asc("") 'Zstring
			'	typ=4
		Case Asc("s")
			typ=5
		Case Asc("t")
			typ=6
		Case Asc("v")
			typ=7
		Case Asc("j")
			typ=8
		Case Asc("x")
			typ=9
		Case Asc("y")
			typ=10
		Case Asc("f")
			typ=11
		Case Asc("d")
			typ=12
		Case Asc("b")
			typ=16
		Case Asc("w") ''wString
			Return "wstring"
		Case Else
			typ=0
		End Select
		Return udt(typ).nm
	End If
End Function

'-----------------
'' parse operator
'-----------------
Private Function parse_op (op As String) As String
	Select Case  op
	Case "aS"
		Function = "Let"
	Case "pl"
		Function = "+"
	Case "pL"
		Function = "+="
	Case "mi"
		Function = "-"
	Case "mI"
		Function = "-="
	Case "ml"
		Function = "*"
	Case "mL"
		Function = "*="
	Case "dv"
		Function = "/"
	Case "dV"
		Function = "/="
	Case "Dv"
		Function = "\"
	Case "DV"
		Function = "\="
	Case "rm"
		Function = "mod"
	Case "rM"
		Function = "mod="
	Case "an"
		Function = "and"
	Case "aN"
		Function = "and="
	Case "or"
		Function = "or"
	Case "oR"
		Function = "or="
	Case "aa"
		Function = "andalso"
	Case "aA"
		Function = "andalso="
	Case "oe"
		Function = "orelse"
	Case "oE"
		Function = "orelse="
	Case "eo"
		Function = "xor"
	Case "eO"
		Function = "xor="
	Case "ev"
		Function = "eqv"
	Case "eV"
		Function = "eqv="
	Case "im"
		Function = "imp"
	Case "iM"
		Function = "imp="
	Case "ls"
		Function = "shl"
	Case "lS"
		Function = "shl="
	Case "rs"
		Function = "shr"
	Case "rS"
		Function = "shr="
	Case "po"
		Function = "^"
	Case "pO"
		Function = "^="
	Case "ct"
		Function = "&"
	Case "cT"
		Function = "&="
	Case "eq"
		Function = "eq"
	Case "gt"
		Function = "gt"
	Case "lt"
		Function = "lt"
	Case "ne"
		Function = "ne"
	Case "ge"
		Function = "ge"
	Case "le"
		Function = "le"
	Case "nt"
		Function = "not"
	Case "ng"
		Function = "neg"
	Case"ps"
		Function = "ps"
	Case "ab"
		Function = "ab"
	Case "fx"
		Function = "fix"
	Case "fc"
		Function = "frac"
	Case "sg"
		Function = "sgn"
	Case "fl"
		Function = "floor"
	Case "nw"
		Function = "new"
	Case "na"
		Function = "new []?"
	Case "dl"
		Function = "del"
	Case "da"
		Function = "del[]?"
	Case "de"
		Function = "operator *"
	Case "pt"
		Function = "->"
	Case "ad"
		Function = "@"
	Case "fR"
		Function = "for"
	Case "sT"
		Function = "step"
	Case "nX"
		Function = "next"
	Case "cv"
		Function = "Cast"
	Case "C1"
		Function = "(Constructor)"
	Case "D1"
		Function = "(Destructor)"
	Case Else
		Function = "Unknow"
	End Select
End Function
'--------------------
'' parse procedure
'--------------------
Private Function parse_proc(fullname As String) As String
	Dim As Long p=3,lg,namecpt,ps
	Dim As String strg,strg2,names(20),mainname,strg3
	lg=InStr(fullname,"@")
	If lg=0 Then lg=InStr(fullname,":")
	strg=Left(fullname,lg-1)
	
	If Left(strg,2)<>"_Z" And Left(strg,3)<>"__Z" Then Return strg
	
	If strg[2]=Asc("Z") Then p+=1 'add 1 case _ _ Z
	If strg[p-1]=Asc("N") Then 'nested waiting "E"
		mainname=""
		p+=1
		While strg[p-1]<>Asc("E")
			lg=ValInt(Mid(strg,p,2)) 'evaluate possible lenght of name eg 7NAMESPC
			If lg Then 'name of namespace or udt
				If lg>9 Then p+=1 '>9 --> 2 characters
				strg3=Mid(strg,p+1,lg) 'extract name and keep it for later
				ps=InStr(strg3,"__get__")
				If ps Then
					strg3=Left(strg3,ps-1)+" (Get property)"
				Else
					ps=InStr(strg3,"__set__")
					If ps Then
						strg3=Left(strg3,ps-1)+" (Set property)"
					End If
				End If
				If mainname="" Then
					mainname=strg3
					strg2+=strg3
				Else
					mainname+="."+strg3
					strg2+="."+strg3
				End If
				namecpt+=1
				names(namecpt)=mainname
				p+=1+lg'next name
			Else 'operator
				strg2+=" "+parse_op(Mid(strg,p,2))+" " 'extract name of operator
				p+=2
				mainname=""
				While strg[p-1]<>Asc("E") 'more data eg FBSTRING,
					lg=ValInt(Mid(strg,p,2))
					If lg Then
						If lg>9 Then p+=1
						strg3=Mid(strg,p+1,lg) 'extract name and keep it for later
						If strg3="FBSTRING" Then strg3="string"
						If mainname="" Then
							mainname=strg3
							strg2+=strg3
						Else
							mainname+="."+strg3
							strg2+="."+strg3
						End If
						namecpt+=1
						names(namecpt)=mainname
						p+=1+lg
					Else
						strg2+=parse_typeope(Asc(Mid(strg,p,1)))
						p+=1
					End If
				Wend
				
			End If
		Wend
	Else
		lg=ValInt(Mid(strg,p,2)) 'overloaded proc eg. for sub testme overload (as string) --> __ZN6TESTMER8FBSTRING@4
		If lg Then
			If lg>9 Then p+=1
			strg2=Mid(strg,p+1,lg) 'extract name
			p+=1+lg'next
		Else
			strg2=parse_op(Mid(strg,p,2))+" "
			p+=2
		End If
	End If
	
	If strg[p-1]=Asc("E") Then p+=1 'skip "E"
	
	'parameters
	mainname=""
	strg2+="("
	While p<=Len(strg)
		lg=ValInt(Mid(strg,p,2))
		If lg Then
			If lg>9 Then p+=1
			strg3=Mid(strg,p+1,lg) 'extract name and keep it for later
			If strg3="FBSTRING" Then strg3="String"
			If mainname="" Then
				mainname=strg3
				strg2+=strg3
			Else
				mainname+="."+strg3
				strg2+="."+strg3
			End If
			namecpt+=1
			names(namecpt)=strg3'mainname
			p+=1+lg
		ElseIf strg[p-1]=Asc("R") Then
			If Right(strg2,1)<>"(" AndAlso Right(strg2,1)<>"," Then
				strg2+=","
			End If
			strg2+="@"
			p+=1
		ElseIf strg[p-1]=Asc("N") Then
			If Right(strg2,1)<>"(" AndAlso Right(strg2,1)<>"," Then strg2+=","
			mainname=""
			p+=1
		ElseIf strg[p-1]=Asc("K") Then
			If Right(strg2,1)<>"(" AndAlso Right(strg2,1)<>"," Then
				strg2+=",const."
			Else
				strg2+="const."
			End If
			p+=1
		ElseIf strg[p-1]=Asc("E") Then
			p+=1
		ElseIf strg[p-1]=Asc("S") Then 'S_ = 1 S0_=2 S1_=3 -->	'repeating a previous type
			If Right(strg2,1)<>"(" AndAlso Right(strg2,1)<>"," AndAlso Right(strg2,2)<>"* " Then
				strg2+=",":mainname=""
			End If
			p+=1
			If strg[p-1]=Asc("_") Then
				strg3=names(1)
				If strg[p-3]=Asc("P") Then
					namecpt+=1
					names(namecpt)="* "+strg3
				End If
				p+=1
			Else
				strg3=names(strg[p-1]-46)
				If strg[p-3]=Asc("P") Then
					namecpt+=1
					names(namecpt)=strg3
				End If
				p+=2
			End If
			If mainname="" Then
				strg2+=strg3
			Else
				strg2+="."+strg3
			End If
		ElseIf strg[p-1]=Asc("P") Then ''pointer followed by datatype
			p+=1
			If Right(strg2,1)="(" Then
				strg2+="* "
			Else
				strg2+=",* "
			End If
		ElseIf strg[p-1]=Asc("u") Then  ''extended type ex : u7INTEGER
			p+=1
			lg=ValInt(Mid(strg,p,2))
			If lg>9 Then p+=1 ''lenght>9
			strg3=Mid(strg,p+1,lg) 'extract name and keep it for later
			strg3=UCase(Left(strg3,1))+LCase(Mid(strg3,2)) ''first char upper/ others lower case
			If mainname="" Then
				mainname=strg3
				strg2+=strg3
			Else
				mainname+="."+strg3
				strg2+="."+strg3
			End If
			namecpt+=1
			names(namecpt)=strg3
			p+=1+lg
		Else
			strg3=parse_typeope(Asc(Mid(strg,p,1)))
			If strg[p-2]=Asc("P") Then
				namecpt+=1
				names(namecpt)="* "+strg3
				strg2+=strg3
			Else
				If Right(strg2,1)="(" Then
					strg2+=strg3
				Else
					strg2+=","+strg3
				End If
			End If
			p+=1
		End If
	Wend
	
	strg2+=")"
	If Right(strg2,6)="(Void)" Then
		strg2=Left(strg2,Len(strg2)-6)
	End If
	Return strg2
End Function

#ifdef __FB_WIN32__
	Private Sub translate_part(strg As String,masterindex As Integer)
		Dim As String sav,modif
		Dim As Integer p,q,index,indexbis,limit
		sav=strg
		While InStr(sav,")=")
			q=1
			p=InStr(q,sav,"(")
			q=InStr(p+1,sav,")")
			indexbis=Val(Mid(sav,InStr(p,sav,",")+1,9))
			modif=Mid(sav,q+2)
			sav=Mid(sav,InStr(q+2,sav,"("))
			p=InStr(modif,"(")
			While p
				q=InStr(p+1,modif,")")
				index=Val(Mid(modif,InStr(p,modif,",")+1,9))
				If Trans(index)<>"" Then
					str_replace(modif,Mid(modif,p,q-p+1),Trans(index))
				Else
					str_replace(modif,Mid(modif,p,q-p+1),Str(index))
				End If
				p=InStr(p+1,modif,"(")
			Wend
			Trans(indexbis)=Str(indexbis)+"="+modif
		Wend
		strg=Trans(masterindex)
	End Sub
	
	Private Sub translate_gcc(strg As String)
		Dim As Integer p,q,index
		Dim As String part
		Static As Integer flagarray,flagstring,flagvoid
		If flagarray=0 Then
			p=InStr(strg,"00;003777") 'searching for the string used for array. Depending on the version of gcc
			If p Then
				p-=31
			Else
				p=InStr(strg,";0;03777")
				If p Then p-=20
			End If
			If p Then 'TCD:T(0,34)=s32VALUE:(0,35)=ar(0,36)=r(0,36);0000000000000;0037777777777;;0;31;(0,23),0,256;;
				'TCD:T(0,31)=s32VALUE:(0,32)=ar(0,33)=r(0,33);0;037777777777;;0;31;(0,20),0,256;;
				q=InStr(p,strg,"=ar(")
				stringarray=Mid(strg,q,InStr(q+4,strg,")")-q+1) 'ar(0,xx) equivalent ar1
				str_replace(strg,Mid(strg,q,InStr(strg,"777;;")+5-q),"=ar1;") 'replace
				flagarray=1
			End If
		Else
			If InStr(strg,stringarray) Then str_replace(strg,stringarray,"=ar1")
		End If
		p=InStr(strg,"(")
		q=InStr(p+1,strg,")")
		'index=val(mid(strg,instr(p,strg,",")+1,9))
		index=Val(Mid(strg,InStr(p,strg,",")+1,9))
		
		If flagvoid=0 AndAlso Left(strg,6)="void:t" Then
			Trans(index)="7" 'void:t(0,xx)
			str_replace(strg,Mid(strg,p,q-p+1),Str(index))
			flagvoid=1
			Return
		End If
		If flagstring=0 AndAlso ( Left(strg,10)="FBSTRING:t" OrElse Left(strg,9)="_string:T" ) Then '_string:T(0,xx) or FBSTRING:t(0,xx)
			Trans(index)="13"
			flagstring=1
			Return
		End If
		'"_TMP$3:T(0,25)=s44DATA:(0,26)=*(0,27)=*(0,1),0,32;PTR:(0,26),32,32;SIZE:(0,1),64,
		'_TUDT:T(0,38)=s8VINT:(0,1),0,32;VBYTE:(0,2),32,8;;
		If strg[p-2]=Asc("T") Then	'Trans(masterindex)=""
			str_replace(strg,Mid(strg,p,q-p+1),Str(index)) 'replace master index
			p=InStr(strg,"(")'find begin and end of type (with array if needed) of component
			
			While p
				q=InStr(p+1,strg,"),")
				part=Mid(strg,p,q-p+1)
				translate_part(part,Val(Mid(strg,InStr(p,strg,",")+1,9)))
				str_replace(strg,Mid(strg,p,q-p+1),part)
				p=InStr(p,strg,"(")
			Wend
			'remove  $N or $NN at beginning $Nudt
			If strg[0]=Asc("$") AndAlso Left(strg,10)<>"$fb_Object" Then '$4UDT1:T(0,58)=s128A:(0,23),0,32;B:(0,54),64,896;C:(0,22),960,16;;
				If  strg[2]>Asc("9") OrElse strg[2]=Asc("$") Then strg=Mid(strg,3) Else strg=Mid(strg,4)
			End If
			
			If Left(strg,4)="TMP$" Then 'description for dynamic array
				p=InStr(strg,"DATA:")
				p=InStr(p,strg,"*") 'skip first *
				p=InStr(p,strg,"=")+1 'extract data
				q=InStr(p,strg,",")
				Trans(index)="=;;"+Mid(strg,p,q-p) 'extract some data to trans()="=s44;;<type>"
				Exit Sub
			End If
			
			Trans(index)=Str(index)
			
		Else
			If Trans(index)<>"" Then
				str_replace(strg,Mid(strg,p,q-p+1),Trans(index)) 'replace by the corresponding string
			Else
				'replace master index
				part=Mid(strg,p)
				translate_part(part,index)
				str_replace(strg,Mid(strg,p),part)
			End If
		End If
	End Sub
#endif

Function String_to_ZString_Ptr(ByRef s_ZString_Ptr As ZString Ptr) As ZString Ptr
	Return s_ZString_Ptr
End Function

Private Function cutup_names(strg As String) As String
	'"__ZN9TESTNAMES2XXE:S1
	Dim As Integer Pos1 = InStr(strg, ":")
	Dim As String s, strg1 = strg
	Dim As ZString Ptr pz
	If Pos1 > 0 Then strg1 = Left(strg, Pos1 - 2)
	pz = String_to_ZString_Ptr(strg1)
	Do
		Do While (*pz)[0] > Asc("9") OrElse (*pz)[0] < Asc("0")
			If (*pz)[0] = 0 Then Return s
			pz += 1
		Loop
		Dim As Integer N = Val(*pz)
		Do
			pz += 1
		Loop Until (*pz)[0] > Asc("9") OrElse (*pz)[0] < Asc("0")
		If s <> "" Then s &= "."
		s &= Left(*pz, N)
		pz += N
	Loop
	Return s
	'		Dim As Integer p,d
	'		Dim As String nm,strg2,nm2
	'		p=InStr(strg,"_ZN")
	'		strg2=Mid(strg,p+3,999)
	'		p=Val(strg2)
	'		If p>9 Then d=3 Else d=2
	'		nm=Mid(strg2,d,p)
	'		strg2=Mid(strg2,d+p)
	'		p=Val(strg2)
	'		If p>9 Then d=3 Else d=2
	'		nm2=Mid(strg2,d,p)
	'		'Return "NS : "+nm+"."+nm2
	'		Return nm+"."+nm2 '17/01/2015
End Function

#ifndef __USE_GTK__
	Private Function cutup_array(gv As String,d As Integer,f As Byte) As Integer
		Dim As Integer p=d,q,c
		
		If arrnb > ARRMAX Then MsgBox(ML("Max array reached: can't store")): Exit Function
		arrnb+=1
		
		'While gv[p-1]=Asc("a")
		While InStr(p,gv,"ar")
			'GCC
			'p+=4
			
			If InStr(gv,"=r(")Then
				p=InStr(p,gv,";;")+2 'skip range =r(n,n);n;n;;
			Else
				p=InStr(p,gv,";")+1 'skip ar1;
			End If
			
			
			q=InStr(p,gv,";")
			'END GCC
			arr(arrnb).nlu(c).lb=Val(Mid(gv,p,q-p)) 'lbound
			
			p=q+1
			q=InStr(p,gv,";")
			arr(arrnb).nlu(c).ub=Val(Mid(gv,p,q-p))'ubound
			'''arr(arrnb).nlu(c).nb=arr(arrnb).nlu(c).ub-arr(arrnb).nlu(c).lb+1 'dim
			p=q+1
			c+=1
		Wend
		arr(arrnb).dm=c 'nb dim
		If f=TYDIM Then
			vrb(*vrbptr).arr=@arr(arrnb)
		Else
			cudt(cudtnb).arr=@arr(arrnb)
		End If
		Return p
	End Function
	
	Private Sub cutup_2(gv As String,f As Byte)
		Dim p As Integer=1,c As Integer,e As Integer,gv2 As String,pp As Integer
		If InStr(gv,"=")=0 Then
			c=Val(Mid(gv,p,9))
			'workaround with gas boolean are not correctly defined type value 15 instead 16 so change the value as pchar (15) is not used
			'done also with array just below and param
			'dbg_prt2("cut up=2"+vrb(*vrbptr).nm+" value c="+Str(c))
			If c=15 Then c=16
			'==================================
			
			If c=udt(15).index Then c=15
			If c>TYPESTD Then c+=udtcpt 'udt type so adding the decal 20/08/2015
			pp=0
			If f=TYUDT Then
				cudt(cudtnb).typ=c
				cudt(cudtnb).pt=pp
				cudt(cudtnb).arr=0 'by default not an array
			Else
				vrb(*vrbptr).typ=c
				vrb(*vrbptr).pt=pp
				vrb(*vrbptr).arr=0 'by default not an array
			End If
		Else
			If InStr(gv,"=ar1") Then p=cutup_array(gv,InStr(gv,"=ar1")+1,f)
			gv2=Mid(gv,p)
			For p=0 To Len(gv2)-1
				If gv2[p]=Asc("*") Then c+=1
				If gv2[p]=Asc("=") Then e=p+1
			Next
			If c Then 'pointer
				If InStr(gv2,"=f") Then 'proc
					If InStr(gv2,"=f7") Then
						pp=200+c 'sub
					Else
						pp=220+c 'function
					End If
				Else
					pp=c
					If gv2[e]=Asc("*")Then e+=1
				End If
			Else
				pp=0
			End If
			c=Val(Mid(gv2,e+1))
			
			'workaround with gas boolean are not correctly defined type value 15 instead 16 so change the value as pchar (15) is not used
			'done also with simple var and param
			'dbg_prt2("cut up=2"+vrb(*vrbptr).nm+" value c="+Str(c))
			If c=15 Then c=16
			'========================================================
			If c=udt(15).index Then c=15
			If c>TYPESTD Then c+=udtcpt 'udt type so adding the decal 20/08/2015
			If f=TYUDT Then
				cudt(cudtnb).pt=pp
				cudt(cudtnb).typ=c
			Else
				vrb(*vrbptr).pt=pp
				vrb(*vrbptr).typ=c
			End If
		End If
	End Sub
	
	'===================== proc (sub or function) ============================
	'Const PROCMAX=20000 'in sources
	'Enum
	'	KMODULE=0 'used with IDSORTPRC
	'	KPROCNM
	'End Enum
	
	'Type tproc
	'	nm As String   'name
	'	db As UInteger 'lower address
	'	fn As UInteger 'upper line address
	'	ed As UInteger 'upper proc end 18/08/2015
	'	sr As UShort   'source index
	'	nu As Long     'line number to quick access
	'	lastline As Long 'last line of proc (use when dwarf data) ''2016/03/24
	'	vr As UInteger 'lower index variable upper (next proc) -1
	'	rv As Integer  'return value type
	'	pt As Long     'counter pointer for return value (** -> 2)
	'	rvadr As Integer 'offset for return value adr (for now only dwarf) 19/08/2015
	'	tv As HTREEITEM 'in tview2
	'	st As Byte     'state followed = not checked
	'End Type
	'Dim Shared proc(PROCMAX) As tproc
	'Dim Shared procnb As Integer
	'Dim Shared As UInteger procsv,procad,procin,procsk,proccurad,procregsp,procfn,procbot,proctop,procsort
	Dim Shared As UInteger procad, procin, procregsp, procbot, proctop
	
	'Const PROCRMAX=50000 'Running proc
	'Type tprocr
	'	sk   As UInteger  'stack
	'	idx  As UInteger  'index for proc
	'	tv   As HTREEITEM 'index for treeview
	'	'lst as uinteger 'future array in LIST
	'	cl   As Integer   'calling line
	'	thid As Integer   'idx thread
	'	vr   As Integer   'lower index running variable upper (next proc) -1
	'End Type
	'Dim Shared procr(PROCRMAX) As tprocr,procrnb As Integer 'list of running proc
	
	Private Sub cutup_udt(readl As String)
		Dim As Integer p,q,lgbits,flagdouble
		Dim As String tnm
		p=InStr(readl,":")
		
		tnm=Left(readl,p-1)
		If InStr(readl,":Tt") Then
			p+=3 'skip :Tt
		Else
			p+=2 'skip :T GCC
		End If
		
		q=InStr(readl,"=")
		
		udtidx=Val(Mid(readl,p,q-p))
		If tnm="OBJECT" OrElse tnm="$fb_Object" Then udt(15).index=udtidx:Exit Sub
		udtidx+=udtcpt:If udtidx>udtmax Then udtmax=udtidx
		If udtmax > TYPEMAX-1 Then MsgBox(ML("Storing UDT: Max limit reached")+" "+Str(TYPEMAX)):Exit Sub
		udt(udtidx).nm=tnm
		If Left(tnm,4)="TMP$" Then Exit Sub 'gcc redim
		p=q+2
		q=p-1
		While readl[q]<64
			q+=1
		Wend
		q+=1
		udt(udtidx).lg=Val(Mid(readl,p,q-p))
		p=q
		udt(udtidx).lb=cudtnb+1
		While readl[p-1]<>Asc(";")
			'dbg_prt("STORING CUDT "+readl)
			If cudtnb = CTYPEMAX Then MsgBox (ML("Storing CUDT: Max limit reached")+" "+Str(CTYPEMAX)):Exit Sub
			cudtnb+=1
			
			
			
			q=InStr(p,readl,":")
			cudt(cudtnb).nm=Mid(readl,p,q-p) 'variable name
			p=q+1
			q=InStr(p,readl,",")
			
			cutup_2(Mid(readl,p,q-p),TYUDT) 'variable type
			
			'11/05/2014 'new way for redim
			If Left(udt(cudt(cudtnb).typ).nm,7)="FBARRAY" Then 'new way for redim array
				
				'.stabs "__FBARRAY1:Tt25=s32DATA:26=*1,0,32;PTR:27=*7,32,32;SIZE:1,64,32;ELEMENT_LEN:1,96,32;DIMENSIONS:1,128,32;DIMTB:28=ar1;0;0;29,160,96;;",128,0,0,0
				'.stabs "TTEST2:Tt23=s40VVV:24=ar1;0;1;2,0,16;XXX:1,32,32;ZZZ:25,64,256;;",128,0,0,0
				'.stabs "__FBARRAY1:Tt21=s32DATA:22=*23,0,32;PTR:30=*7,32,32;SIZE:1,64,32;ELEMENT_LEN:1,96,32;DIMENSIONS:1,128,32;DIMTB:31=ar1;0;0;29,160,96;;",128,0,0,0
				'.stabs "TTEST:Tt20=s56AAA:3,0,8;BBB:21,32,256;CCC:32=ar1;1;2;10,320,128;;",128,0,0,0
				'.stabs "__FBARRAY8:Tt18=s116DATA:19=*20,0,32;PTR:33=*7,32,32;SIZE:1,64,32;ELEMENT_LEN:1,96,32;DIMENSIONS:1,128,32;DIMTB:34=ar1;0;0;29,160,768;;",128,0,0,0
				'.stabs "VTEST:18",128,0,0,-176
				cudt(cudtnb).pt=cudt(udt(cudt(cudtnb).typ).lb).pt-1 'pointer always al least 1 so reduce by one
				cudt(cudtnb).typ=cudt(udt(cudt(cudtnb).typ).lb).typ 'real type
				cudt(cudtnb).arr=Cast(tarr Ptr,-1) 'defined as dyn arr
				
				'dbg_prt2("dyn array="+cudt(cudtnb).nm+" "+Str(cudt(cudtnb).typ)+" "+Str(cudt(cudtnb).pt)+" "+cudt(udt(cudt(cudtnb).typ).lb).nm)
			End If
			'end new redim
			
			
			p=q+1
			q=InStr(p,readl,",")
			cudt(cudtnb).ofs=Val(Mid(readl,p,q-p))  'bits offset / beginning
			p=q+1
			q=InStr(p,readl,";")
			lgbits=Val(Mid(readl,p,q-p))	'length in bits
			
			If cudt(cudtnb).typ<>4 And cudt(cudtnb).pt=0 And cudt(cudtnb).arr=0 Then 'not zstring, pointer,array !!!
				If lgbits<>udt(cudt(cudtnb).typ).lg*8 Then 'bitfield
					cudt(cudtnb).typ=TYPEMAX 'special type for bitfield
					cudt(cudtnb).ofb=cudt(cudtnb).ofs-(cudt(cudtnb).ofs\8) * 8 ' bits mod byte
					cudt(cudtnb).lg=lgbits  'length in bits
				End If
			End If
			''''''''''''''''''EndIf 'end change 17/04/2014
			p=q+1
			cudt(cudtnb).ofs=cudt(cudtnb).ofs\8 'offset bytes
		Wend
		udt(udtidx).ub=cudtnb
	End Sub
	
	Private Function cutup_scp(gv As Byte, ad As UInteger,dlldelta As Integer=0) As Integer
		Select Case gv
		Case Asc("S"),Asc("G")     'shared/common
			If gv=Asc("G") Then If Common_exist(ad) Then Return 0 'to indicate that no needed to continue
			If vrbgbl=VGBLMAX Then MsgBox (ML("Init Globals: Reached limit")+" "+Str(VGBLMAX)):Exit Function
			vrbgbl+=1
			vrb(vrbgbl).adr=ad
			vrbptr=@vrbgbl
			Select Case gv
			Case Asc("S")		'shared
				vrb(vrbgbl).mem=2
				vrb(vrbgbl).adr+=dlldelta 'in case of relocation dll, all shared addresses are relocated
			Case Asc("G")     'common
				vrb(vrbgbl).mem=6
			End Select
			Return 2
		Case Else
			If vrbloc=VARMAX Then MsgBox(ML("Init locals: Reached limit")+" "+Str(VARMAX-3000)):Exit Function
			vrbloc+=1
			vrb(vrbloc).adr=ad
			vrbptr=@vrbloc
			proc(procnb+1).vr=vrbloc+1 'just to have the next beginning
			Select Case gv
			Case Asc("V")     'static
				vrb(vrbloc).mem=3
				Return 2
			Case Asc("v")     'byref parameter
				vrb(vrbloc).mem=4
				Return 2
			Case Asc("p")     'byval parameter
				vrb(vrbloc).mem=5
				Return 2
			Case Else         'local
				vrb(vrbloc).mem=1
				Return 1
			End Select
		End Select
	End Function
	
	Private Sub enum_show(hwnd As HWND)
		'Dim lvCol   As LVCOLUMN,lvI  As LVITEM,il As Integer, tmp As String
		'Dim As HWND listview=fb_listview(hwnd,0,3,4,490,488)
		'
		'
		'  lvCol.mask      =  LVCF_FMT Or LVCF_WIDTH Or LVCF_TEXT Or LVCF_SUBITEM
		'  lvCol.fmt       =  LVCFMT_LEFT
		'  lvcol.cx=0
		'  lvI.mask     =  LVIF_TEXT
		'
		'  lvCol.pszText   = StrPtr("ENUM NAME")
		'  lvCol.iSubItem  = 0
		'  sendmessage(listview,LVM_INSERTCOLUMN,0,Cast(LPARAM,@lvCol))
		'  'LVSCW_AUTOSIZE_USEHEADER = -2 ou AUTOSIZE= -1)
		'  sendmessage(listview,LVM_SETCOLUMNWIDTH,0,150)  '?????
		'
		' lvCol.pszText   = StrPtr("ITEM")
		' lvCol.iSubItem  =  1
		' sendmessage(listview,LVM_INSERTCOLUMN,1,Cast(LPARAM,@lvCol))
		' sendmessage(listview,LVM_SETCOLUMNWIDTH,1,250)
		' lvCol.pszText   = StrPtr("VALUE")
		' lvCol.iSubItem  =  2
		' sendmessage(listview,LVM_INSERTCOLUMN,2,Cast(LPARAM,@lvCol))
		' sendmessage(listview,LVM_SETCOLUMNWIDTH,2,90)
		'''''to avoid display update every update
		'  'SendMessage(listview, WM_SETREDRAW, FALSE, 0)
		''   sendmessage(listview,LVM_SETCOLUMNWIDTH,lvnbcol+1,LVSCW_AUTOSIZE)'_USEHEADER)
		' sendmessage(listview,LVM_SETTEXTCOLOR,0,RGB(128,0,0))
		'lvI.mask     = LVIF_TEXT
		'
		'For i As Integer = 1 To udtmax
		'    If udt(i).en=i Then ' to avoid duplicate
		'        lvi.iitem    = il 'index line
		'        lvi.isubitem = 0 'index column
		'        lvi.pszText  = StrPtr(udt(i).nm)
		'        sendmessage(listview,LVM_INSERTITEM,0,Cast(LPARAM,@lvi))
		'        For j As Integer = udt(i).lb To udt(i).ub
		'            lvi.iitem    = il 'index line
		'            lvi.isubitem = 1
		'            lvi.pszText  = StrPtr(cudt(j).nm)
		'            sendmessage(listview,LVM_SETITEMTEXT,il,Cast(LPARAM,@lvi))
		'            'sendmessage(listview,LVM_SETCOLUMNWIDTH,lvnbcol,LVSCW_AUTOSIZE)
		'            lvi.isubitem = 2
		'            tmp=Str(cudt(j).val)
		'            lvi.pszText  = StrPtr(tmp)
		'            sendmessage(listview,LVM_SETITEMTEXT,il,Cast(LPARAM,@lvi))
		'            il+=1
		'            lvi.iitem    = il 'index line
		'            lvi.isubitem = 0 'index column
		'            lvi.pszText  = 0 'empty line
		'            sendmessage(listview,LVM_INSERTITEM,0,Cast(LPARAM,@lvi))
		'        Next
		'        il+=1
		'    End If
		'Next
	End Sub
	
	Private Sub cutup_enum(readl As String)
		'.stabs "TENUM:T26=eESSAI:5,TEST08:8,TEST09:9,TEST10:10,FIN:99,;",128,0,0,0
		Dim As Integer p,q
		Dim As String tnm
		p=InStr(readl,":")
		tnm=Left(readl,p-1)
		p+=2 'skip :T
		q=InStr(readl,"=")
		udtidx=Val(Mid(readl,p,q-p))
		udtidx+=udtcpt:If udtidx>udtmax Then udtmax=udtidx
		If udtmax > TYPEMAX Then MsgBox(ML("Storing ENUM") & "="+tnm & ": " & ML("Max limit reached")+" "+Str(TYPEMAX)):Exit Sub
		udt(udtidx).nm=tnm 'enum name
		
		udt(udtidx).en=udtidx 'flag enum, in case of already treated use same previous cudt
		udt(udtidx).lg=Len(Integer) 'same size as integer
		'each cudt contains the value (typ) and the associated text (nm)
		udt(udtidx).lb=cudtnb+1
		p=q+2
		cudtnbsav=cudtnb 'save value for restoring see enum_check
		If InStr(readl,";")=0 Then
			cudtnb+=1
			cudt(cudtnb).nm="DUMMY"
			cudt(cudtnb).Val=0
			MsgBox(ML("Storing ENUM") & "="+tnm &": " & ML("Data not correctly formated")):Exit Sub '28/04/2014
		Else
			While readl[p-1]<>Asc(";")
				q=InStr(p,readl,":") 'text
				If cudtnb>=CTYPEMAX Then MsgBox(ML("Storing ENUM") & "="+tnm & ": " & ML("Max limit reached")+" "+Str(CTYPEMAX)):Exit Sub '28/04/2014
				cudtnb+=1
				cudt(cudtnb).nm=Mid(readl,p,q-p)
				
				p=q+1
				q=InStr(p,readl,",") 'value
				cudt(cudtnb).Val=Val(Mid(readl,p,q-p))
				p=q+1
				
			Wend
		End If
		udt(udtidx).ub=cudtnb
		enum_check(udtidx) 'eliminate duplicates
	End Sub
	
	Private Sub cutup_1(gv As String,ad As UInteger, dlldelta As Integer=0)
		Dim p As Integer
		Static defaulttype As Integer
		Dim As String vname
		If gengcc Then
			If InStr(gv,"long double:t")<>0 OrElse InStr(gv,"FBSTRING:t")<>0 Then
				defaulttype=0
			ElseIf Left(gv,5)="int:t" OrElse InStr(gv,"_Decimal32:t")<>0 Then
				defaulttype=1
			End If
		Else
			If InStr(gv,"boolean:t") OrElse InStr(gv,"pchar:t") Then 'last default type 20/08/2015
				defaulttype=0
			ElseIf InStr(gv,"integer:t") Then
				defaulttype=1
			End If
		End If
		If defaulttype Then Exit Sub
		
		If gengcc Then translate_gcc(gv)
		
		'=====================================================
		vname=Left(gv,InStr(gv,":")+1)
		
		p=InStr(vname,"$")
		If p=0 Then 'no $ in the string
			If InStr(vname,":t")<>0 Then
				If UCase(Left(vname,InStr(vname,":")))<>Left(vname,InStr(vname,":")) Then
					Exit Sub 'don't keep  <lower case name>:t, keep <upper case name>:t  => enum
				End If
			ElseIf InStr(vname,"_ZTSN")<>0  OrElse InStr(vname,"_ZTVN")<>0 Then
				Exit Sub 'don't keep _ZTSN or _ZTVN (extra data for class) or with double underscore  __Z
			End If
			If Left(vname,2)="_{" Then Exit Sub '_{fbdata}_<label name>  07/04/2014
			If Left(vname,3)=".Lt" Then Exit Sub '.Ltxxxx used with data 07/04/2014
			If Left(vname,3)="Lt_" Then Exit Sub 'Lt_xxxx used with extern and array 2018/07/27
		Else '$ in the string
			If InStr(p+1,vname,"$") <>0 AndAlso InStr(vname,"$fb_Object")=0 Then
				Exit Sub 'don't keep TMP$xx$xx:
			End If
			'''''''''''''If InStr(vname,":T")<>0 OrElse InStr(vname,":t")<>0 Then
			'$9CABRIOLET:T(0,51)=s16:BASE:(0,48),0,128;;
			If InStr(vname,":t")<>0 Then 'InStr(vname,":T")<>0 OrElse InStr(vname,":t")<>0 Then
				If Left(vname,5)<>"$fb_O" AndAlso Left(vname,4)<>"TMP$" Then  'redim
					Exit Sub 'don't keep
				End If
			End If
			If InStr(vname,"$fb_RTTI") OrElse InStr(vname,"fb$result$") Then
				Exit Sub 'don't keep
			End If
			If Left(vname,3)="vr$" OrElse Left(vname,4)="tmp$" Then
				Exit Sub 'don't keep  vr$xx: or tmp$xx$xx:
			End If
			'eliminate $ and eventually the number at the end of name ex udt$1 --> udt
			If Left(vname,4)<>"TMP$" Then ' use with redim
				If p<>1 Then gv=Left(gv,p-1)+Mid(gv,InStr(gv,":"))
			End If
		End If
		'======================================================
		If InStr(gv,";;") Then 'defined type or redim var
			If InStr(gv,":T") Then 'GCC change ":Tt" in just ":T"
				'UDT
				cutup_udt(gv)
			Else
				'REDIM
				If cutup_scp(gv[InStr(gv,":")],ad,dlldelta)=0 Then Exit Sub 'Scope / increase number and put adr
				'if common exists return 0 so exit sub
				vrb(*vrbptr).nm=Left(gv,InStr(gv,":")-1) 'var or parameter
				
				'.stabs "VTEST:22=s32DATA:25=*23=24=*1,0,32;PTR:26=*23=24=*1,32,32;SIZE:1,64,32;ELEMENT_LEN:1,96,32;DIMENSIONS:1,128,32;dim1_ELEMENTS:1,160,32;dim1_LBOUND:1,192,32;
				'dim1_UBOUND:1,224,32;;
				'DATA:27=*dim1_20=*21,0,32;PTR:28=*dim1_20=*21,32,32;SIZE:1,64,32;ELEMENT_LEN:1,96,32;DIMENSIONS:1,128,32;dim1_ELEMENTS:1,160,32;
				'dim1_LBOUND:1,192,32;dim1_UBOUND:1,224,32;;21",128,0,0,-168
				
				
				p=InStr(gv,";;")+2 ' case dyn var including dyn array field...... 21/04/2014 to be removed when 0.91 is released
				While InStr(p,gv,";;")<>0 '29/04/2014
					p=InStr(p,gv,";;")+2
				Wend
				
				cutup_2(Mid(gv,p),TYRDM) 'datatype
				vrb(*vrbptr).arr=Cast(tarr Ptr,-1) 'redim array
			End If
		ElseIf InStr(gv,"=e") Then
			'ENUM
			cutup_enum(gv)
		Else
			'DIM
			If InStr(gv,"FDBG_COMPIL_INFO") Then Exit Sub
			If gv[0]=Asc(":") Then Exit Sub 'no name, added by compiler don't take it
			p=cutup_scp(gv[InStr(gv,":")],ad,dlldelta)'Scope / increase number and put adr
			If p=0 Then Exit Sub 'see redim
			If InStr(gv,"_ZN") AndAlso InStr(gv,":") Then
				vrb(*vrbptr).nm=cutup_names(gv) 'namespace
			Else
				vrb(*vrbptr).nm=Left(gv,InStr(gv,":")-1) 'var or parameter
				'to avoid two lines in proc/var tree, case dim shared array and use of erase or u/lbound
				If vrb(*vrbptr).mem=2 AndAlso vrb(*vrbptr).nm=vrb(*vrbptr-1).nm Then 'check also if shared
					*vrbptr-=1 'decrement pointed value, vrbgbl in this case
					Exit Sub
				End If
				If vrb(*vrbptr).mem=1 Then ''local var ''2016/08/12
					If local_exist Then Exit Sub'' check if same adr and name exist (case several for loops repeated with the same iterator)
				End If
			End If
			cutup_2(Mid(gv,InStr(gv,":")+p),TYDIM)
			'11/05/2014 'new way for redim
			If Left(udt(vrb(*vrbptr).typ).nm,7)="FBARRAY" Then 'new way for redim array
				
				'.stabs "__FBARRAY2:Tt23=s44DATA:24=*10,0,32;PTR:25=*7,32,32;SIZE:1,64,32;ELEMENT_LEN:1,96,32;DIMENSIONS:1,128,32;DIMTB:26=ar1;0;1;22,160,192;;",128,0,0,0
				'.stabs "MYARRAY2:S23",38,0,0,_MYARRAY2
				vrb(*vrbptr).pt=cudt(udt(vrb(*vrbptr).typ).lb).pt-1 'pointer always al least 1 so reduce by one
				vrb(*vrbptr).typ=cudt(udt(vrb(*vrbptr).typ).lb).typ 'real type
				vrb(*vrbptr).arr=Cast(tarr Ptr,-1) 'defined as dyn arr
				
				'dbg_prt2("dyn array="+vrb(*vrbptr).nm+" "+Str(vrb(*vrbptr).typ)+" "+Str(vrb(*vrbptr).pt)+" "+cudt(udt(vrb(*vrbptr).typ).lb).nm)
			End If
			'end new redim
		End If
	End Sub
	
	
	Private Sub cutup_retval(prcnb As Integer,gv2 As String)
		'example :f7 --> private sub /  :F18=*19=f7" --> public sub ptr / :f18=*19=*1 --> private integer ptr ptr
		Dim p As Integer,c As Integer,e As Integer
		For p=0 To Len(gv2)-1
			If gv2[p]=Asc("*") Then c+=1
			If gv2[p]=Asc("=") Then e=p+1
		Next
		If c Then 'pointer
			If InStr(gv2,"=f") OrElse InStr(gv2,"=F") Then
				If InStr(gv2,"=f7") OrElse InStr(gv2,"=F7") Then
					p=200+c 'sub
				Else
					p=220+c 'function
				End If
			Else
				If gv2[e]=Asc("*")Then e+=1
				p=c
			End If
		Else
			p=0
		End If
		c=Val(Mid(gv2,e+1))
		'workaround with gas boolean are not correctly defined type value 15 instead 16 so change the value as pchar (15) is not used
		'done also with simple and array var
		'dbg_prt2("cut up=2"+vrb(*vrbptr).nm+" value c="+Str(c))
		If c=15 Then c=16
		'========================================================
		If c=udt(15).index Then c=15
		If c>TYPESTD Then c+=udtcpt '20/08/2015
		proc(prcnb).pt=p
		proc(prcnb).rv=c
	End Sub
	
	Private Function cutup_proc(fullname As String) As String '02/11/2014
		Dim As Long p=3,lg,namecpt,ps
		Dim As String strg,strg2,names(100),mainname,strg3
		lg=InStr(fullname,"@")
		If lg=0 Then lg=InStr(fullname,":")
		strg=Left(fullname,lg-1)
		
		If InStr(strg,"_Z")=0 Then Return strg
		
		If strg[2]=Asc("Z") Then p+=1 'add 1 case _ _ Z
		If strg[p-1]=Asc("N") Then 'nested waiting "E"
			mainname=""
			p+=1
			While strg[p-1]<>Asc("E")
				lg=ValInt(Mid(strg,p,2)) 'evaluate possible lenght of name eg 7NAMESPC
				If lg Then 'name of namespace or udt
					If lg>9 Then p+=1 '>9 --> 2 characters
					strg3=Mid(strg,p+1,lg) 'extract name and keep it for later
					ps=InStr(strg3,"__get__")
					If ps Then
						strg3=Left(strg3,ps-1)+" (Get property)"
					Else
						ps=InStr(strg3,"__set__")
						If ps Then
							strg3=Left(strg3,ps-1)+" (Set property)"
						End If
					End If
					If mainname="" Then
						mainname=strg3
						strg2+=strg3
					Else
						mainname+="."+strg3
						strg2+="."+strg3
					End If
					namecpt+=1
					names(namecpt)=mainname
					p+=1+lg'next name
				Else 'operator
					strg2+=" "+cutup_op(Mid(strg,p,2))+" " 'extract name of operator
					p+=2
					mainname=""
					While strg[p-1]<>Asc("E") 'more data eg FBSTRING,
						lg=ValInt(Mid(strg,p,2))
						If lg Then
							If lg>9 Then p+=1
							strg3=Mid(strg,p+1,lg) 'extract name and keep it for later
							If strg3="FBSTRING" Then strg3="string"
							If mainname="" Then
								mainname=strg3
								strg2+=strg3
							Else
								mainname+="."+strg3
								strg2+="."+strg3
							End If
							namecpt+=1
							names(namecpt)=mainname
							p+=1+lg
						Else
							strg2+=parse_typeope(Asc(Mid(strg,p,1)))'mymodif
							p+=1
						End If
					Wend
					
				End If
			Wend
		Else
			lg=ValInt(Mid(strg,p,2)) 'overloaded proc eg. for sub testme overload (as string) --> __ZN6TESTMER8FBSTRING@4 07/11/2015
			If lg Then
				If lg>9 Then p+=1
				strg2=Mid(strg,p+1,lg) 'extract name
				p+=1+lg'next
			Else
				strg2=cutup_op(Mid(strg,p,2))+" "
				p+=2
			End If
		End If
		
		If strg[p-1]=Asc("E") Then p+=1 'skip "E"
		
		'parameters
		mainname=""
		strg2+="("
		While p<=Len(strg)
			lg=ValInt(Mid(strg,p,2))
			If lg Then
				If lg>9 Then p+=1
				strg3=Mid(strg,p+1,lg) 'extract name and keep it for later
				If strg3="FBSTRING" Then strg3="String"
				If mainname="" Then
					mainname=strg3
					strg2+=strg3
				Else
					mainname+="."+strg3
					strg2+="."+strg3
				End If
				namecpt+=1
				names(namecpt)=mainname
				p+=1+lg
			ElseIf strg[p-1]=Asc("R") Then
				If Right(strg2,1)<>"(" AndAlso Right(strg2,1)<>"," Then strg2+=","
				p+=1
			ElseIf strg[p-1]=Asc("N") Then
				If Right(strg2,1)<>"(" AndAlso Right(strg2,1)<>"," Then strg2+=","
				mainname=""
				p+=1
			ElseIf strg[p-1]=Asc("K") Then
				If Right(strg2,1)<>"(" AndAlso Right(strg2,1)<>"," Then
					strg2+=",const."
				Else
					strg2+="const."
				End If
				p+=1
			ElseIf strg[p-1]=Asc("E") Then
				'If Right(strg2,1)<>"," Then strg2+=","
				p+=1
			ElseIf strg[p-1]=Asc("S") Then 'S0_ -->	'repeating the previous type
				If Right(strg2,1)<>"(" AndAlso Right(strg2,1)<>"," Then strg2+=",":mainname=""
				p+=1
				If strg[p-1]=Asc("_") Then
					strg3=names(1)
					p+=1
				Else
					strg3=names(strg[p-1]-46)
					p+=2
				End If
				If mainname="" Then
					mainname=strg3
					strg2+=strg3
				Else
					mainname+="."+strg3
					strg2+="."+strg3
				End If
				namecpt+=1
				names(namecpt)=mainname
			Else
				If Right(strg2,1)="(" Then
					strg2+=parse_typeope(Asc(Mid(strg,p,1)))
				Else
					strg2+=","+parse_typeope(Asc(Mid(strg,p,1)))
				End If
				p+=1
			End If
		Wend
		
		strg2+=")"
		If Right(strg2,6)="(Void)" Then
			strg2=Left(strg2,Len(strg2)-6)
		End If
		
		Return strg2
	End Function
#endif

Private Function check_source(sourcenm As String) As Integer ' check if source yet stored
	For i As Integer=0 To sourcenb
		If EqualPaths(source(i), sourcenm) Then Return i 'found
	Next
	Return -1 'not found
End Function

'========================================
'' Insert in alphanumeric order (CAUTION 1 based)
'========================================
Sub list_insert(list1() As tlist, zstrg As ZString Ptr, prnb As Integer, ByRef listbegin As Integer)
	Dim As Integer listidx
	If prnb=1 Then
		list1(1).parent = -1
		list1(1).child = -1
		list1(1).nm = zstrg
		listbegin=1
	Else
		listidx=listbegin
		While 1
			If *zstrg > *list1(listidx).nm Then
				If list1(listidx).child = -1 Then ''last element of the list
					''insert after last element
					list1(listidx).child = prnb
					list1(prnb).parent = listidx
					list1(prnb).child = -1
					list1(prnb).nm = zstrg
					Exit While
				Else
					listidx = list1(listidx).child
				End If
			Else
				If list1(listidx).parent = -1 Then ''first element of the list
					''insert before first element
					list1(prnb).parent = -1
					list1(prnb).child = listidx
					list1(listidx).parent = prnb
					list1(prnb).nm = zstrg
					listbegin=prnb
					Exit While
				Else ''insert in the middle
					list1(prnb).parent = list1(listidx).parent
					list1(prnb).child = listidx
					list1(list1(listidx).parent).child = prnb
					list1(listidx).parent = prnb
					list1(prnb).nm = zstrg
					Exit While
				End If
			End If
		Wend
	End If
End Sub

'' -------------------------------
'' Handling main source code=100
'' -------------------------------
Private Sub dbg_file(strg As String, value As Integer)
	Static As String path
	Dim As String fullname
	If strg="" Then ''end of main ?
		udtcpt=udtmax-TYPESTD
		'dbg_prt2 "---------------- end of current debug data -------------------"
	Else
		If Right(strg,4)<>".bas" And Right(strg,3)<>".bi" Then
			path=strg
		Else
			#ifdef __FB_WIN32__
				fullname=LCase(path+strg)
			#else
				fullname=path+strg ''file names are sensitive on linux
			#endif
			path=""
			
			'dbg_prt2 "full source name=";fullname
			If check_source(fullname)=-1 Then ''useful check_source ???
				sourcenb+=1
				source(sourcenb)=fullname
				srcname(sourcenb)=source_name(source(sourcenb))
				list_insert(srclist(),StrPtr(srcname(sourcenb)),sourcenb+1,srclistfirst) ''zero based so add 1
				sourceix=sourcenb
				'dbg_prt2 "new source=";fullname
			Else
				'dbg_prt2 "keep current source with code 100 check that =";strg
			End If
		End If
	End If
End Sub
'' --------------------------------------------------------
'' Handling include or return in previous source code=132
'' --------------------------------------------------------
Private Sub dbg_include(strg As String)
	Dim As Integer temp
	If InStr(strg, Any "/\") = 0 Then ''just the name no path Then
		Dim As ProjectElement Ptr Project
		Dim As TreeNode Ptr ProjectNode
		Dim As UString MainFile = GetMainFile(False, Project, ProjectNode)
		strg = Left(MainFile, InStrRev(MainFile, Any "/\")) + strg ''adding path
		'strg=Left(source(0),InStrRev(source(0),Any "/\"))+strg ''adding path
	End If
	#ifdef __FB_WIN32__
		strg=LCase(strg) ''only WDS file names are sensitive on LNX
	#endif
	
	temp=check_source(strg)
	If temp=-1 Then
		sourcenb+=1
		source(sourcenb)=strg
		sourceix=sourcenb
		srcname(sourcenb)=source_name(source(sourcenb))
		list_insert(srclist(),StrPtr(srcname(sourcenb)),sourcenb+1,srclistfirst) ''zero based so add 1
		'dbg_prt2 "new source=";sourcenb,strg
	Else
		sourceix=temp
		'dbg_prt2 "keep current source=";sourceix,strg
	End If
End Sub
'' -----------------------
'' Handling line code=68
'' -----------------------
Private Sub dbg_line(linenum As Integer, ofset As Integer)
	If linenum Then
		#Ifndef __FB_64BIT__
			''to skip stabd
			If linenum<rline(linenb).nu Then
				If procnb=rline(linenb).px Then
					Exit Sub
				End If
			End If
		#endif
		If ofset+proc(procnb).db<>rline(linenb).ad Then ''checking to avoid asm with just comment line
			linenb+=1
		End If
		rline(linenb).ad=ofset+proc(procnb).db
		rline(linenb).nu=linenum
		rline(linenb).px=procnb
		
		If procnew <> procnb Then ''find the address for first fbc line of the proc
			If ofset<>0 Then
				procnew=procnb
				proc(procnb).first=rline(linenb).ad
			End If
		End If
		''to be checked maybe fixed so useless
		rline(linenb).sx=sourceix ''for line in include and not in a proc
		'dbg_prt2 "linenum=";linenum,hex(rline(linenb).ad)
	Else
		'dbg_prt2 "line number=0"
	End If
End Sub
'' ---------------------------------------------
'' Handling procedure sub/function/etc code=36
'' ---------------------------------------------
Private Sub dbg_proc(strg As String, linenum As Integer, adr As Integer)
	Dim As String procname
	If linenum Then
		procnodll=False
		procname=parse_proc(strg)
		
		'procname=left(strg,instr(strg,":")-1)
		If procname<>"" And (flagmain=True Or procname<>"main") Then
			'If InStr(procname,".LT")=0 then  ''to be checked if useful
			If flagmain=True And procname="main" Then
				procmain=procnb+1
				flagmain=False
				'flagstabd=TRUE'first main ok but not the others
				'dbg_prt2 "main found=";procnb+1
			End If
			procnodll=True
			
			procnb+=1
			'dbg_prt2 "in proc=";procname,procnb,sourceix
			proc(procnb).sr=sourceix
			proc(procnb).nm=procname
			list_insert(proclist(),StrPtr(proc(procnb).nm),procnb,proclistfirst)
			
			proc(procnb).db=adr'+exebase-baseimg 'only when <> exebase and baseimg (DLL)
			''to be added
			parse_retval(procnb,Mid(strg,InStr(strg,":")+2,99)) 'return value .rv + pointer .pt
			proc(procnb).enab=True
			proc(procnb).nu=linenum
			lastline=0
			proc(procnb+1).vr=proc(procnb).vr 'in case there is not param nor local var
			proc(procnb).rvadr=0 'for now only used in gcc case
			
			'dbg_prt2 "proc =";proc(procnb).nm;" in source=";source(proc(procnb).sr)
		End If
	Else
		proc(procnb).ed=proc(procnb).db+adr
		'dbg_prt2 "end of proc=";proc(procnb).ed,hex(proc(procnb).ed)
		proc(procnb).sr=sourceix
		If proc(procnb).fn>procfn Then procfn=proc(procnb).fn+1 ' just to be sure to be above see gest_brk
		
		''todo be checked ??????
		'for proc added by fbc (constructor, operator, ...) ''adding >2 to avoid case only one line ...
		'dbg_prt2 "Checking procedure added by compiler =";proc(procnb).nm,proc(procnb).nu,rline(linenb).nu,hex(proc(procnb).db),hex(proc(procnb).fn)
		'If proc(procnb).nu=rline(linenb).nu AndAlso linenb>2 then
		If rline(linenb).nu=1 Then
			
			proc(procnb).nu=-1
			linenb-=1
			dbg_prt2 "Procedure added by compiler (constructor, etc) =";proc(procnb).nm
			'For i As Integer =1 To linenb
			'dbg_prt2("Proc db/fn inside for stab="+Hex(proc(procnb).db)+" "+Hex(proc(procnb).fn))
			'dbg_prt2("Line Adr="+Hex(rline(i).ad)+" "+Str(rline(i).ad))
			'If rline(i).ad>=proc(procnb).db AndAlso rline(i).ad<=proc(procnb).fn Then
			'#Ifdef __fb_win32__
			'dbg_prt2 "Cancel breakpoint adr="+Hex(rline(i).ad)+" "+Str(rline(i).ad))
			'WriteProcessMemory(dbghand,Cast(LPVOID,rline(i).ad),@rLine(i).sv,1,0)
			'#else
			'dbg_prt2 "Procedure added by compiler (constructor, etc) line number should be -1=";proc(procnb).nm,rline(i).nu
			'#endif
			''nota rline(linenb).nu=-1
			'EndIf
			'next
		End If
		
		''removing {modlevel empty just prolog and epilog
		If proc(procnb).nm="{MODLEVEL}" And proc(procnb).fn-proc(procnb).db <8 Then
			''removing lines
			For iline As Long = linenb To 1 Step -1
				If rline(iline).px=procnb Then
					'writeProcessMemory(dbghand,Cast(LPVOID,rline(iline).ad),@rLine(iline).sv,1,0) 'restore to avoid stop
					linenb-=1
				Else
					Exit For
				End If
			Next
			'dbg_prt2 "remove modlevel in"+source(proc(procnb).sr)
			procnb-=1 ''removing proc
		End If
		
	End If
End Sub
'' ------------------------------------
'' Handling procedure epilog code=224
'' ------------------------------------
Private Sub dbg_epilog(ofset As Integer)
	proc(procnb).fn=proc(procnb).db+ofset
	If proc(procnb).fn<>rline(linenb).ad Then
		If proc(procnb).nm<>"main" And proc(procnb).nm<>"{MODLEVEL}" Then
			'' this test is useless as for sub it is ok  .fn = .ad  --> mov rsp, rbp
			'' for function the last line ('end function' is not given by 224)
			'' so forcing it except for main
			'dbg_prt2 "EPILOG=";hex(rline(linenb).ad),hex(proc(procnb).fn),"##";proc(procnb).nm;"##"
			rline(linenb).ad=proc(procnb).fn ''KEEP this line even if test is removed
			'else
			'proc(procnb).fn=rline(linenb).ad
		End If
	End If
	If procnb=procmain Then
		For iline As Integer =1 To linenb
			If rline(iline).px=procmain Then
				rline(iline).nu=99999999 ''to avoid unexecutable line if first fbc line is 1 in main
				proc(procmain).nu=rline(iline+1).nu
				Exit For
			End If
		Next
		''in case there are procedures after the last line of main
		For iline As Integer = linenb To 1 Step -1
			If rline(iline).px=procmain Then
				For iproc As Integer = 1 To procnb
					If proc(iproc).nu=rline(iline).nu Then
						If proc(iproc).sr=proc(procmain).sr Then
							linenb-=1
							Exit For,For
						End If
					End If
				Next
				Exit For
			End If
		Next
	End If
End Sub

#ifdef __FB_WIN32__
	'Dim Shared breakcpu As Integer =&hCC
	Dim Shared As String  dwln '(dwarf) line read
	Dim Shared As Integer dwff '(dwarf) freefile
	
	'dwarf management
	Dim Shared As Long udtbeg,cudtbeg,locbeg,vrbbeg,prcbeg
	'excluded lines for procs added in dll (DllMain and tmp$x)
	'Const EXCLDMAX=10
	'Type texcld
	'	db As UInteger
	'	fn As UInteger
	'End Type
	'Dim Shared As Long excldnb
	'Dim Shared As texcld	excldlines(EXCLDMAX)
	
	'udt(0).nm="Unknown"
	''12/07/2015
	'#ifdef __FB_64BIT__
	'	udt(1).nm="long":udt(1).lg=Len(Long)
	'#else
	'	udt(1).nm="Integer":udt(1).lg=Len(Integer)
	'#endif
	'udt(2).nm="Byte":udt(2).lg=Len(Byte)
	'udt(3).nm="Ubyte":udt(3).lg=Len(UByte)
	'udt(4).nm="Zstring":udt(4).lg=Len(Integer)'4 12/07/2015
	'udt(5).nm="Short":udt(5).lg=Len(Short)
	'udt(6).nm="Ushort":udt(6).lg=Len(UShort)
	'udt(7).nm="Void":udt(7).lg=Len(Integer)'4 12/07/2015
	'udt(7).index=7'dwarf
	''12/07/2015
	'#ifdef __FB_64BIT__
	'	udt(8).nm="Ulong":udt(8).lg=Len(ULong)
	'#else
	'	udt(8).nm="Uinteger":udt(8).lg=Len(UInteger)
	'#endif
	''12/07/2015
	'#ifdef __FB_64BIT__
	'	udt(9).nm="Integer":udt(9).lg=Len(Integer)
	'#else
	'	udt(9).nm="Longint":udt(9).lg=Len(LongInt)
	'#endif
	''12/07/2015
	'#ifdef __FB_64BIT__
	'	udt(10).nm="Uinteger":udt(10).lg=Len(UInteger)
	'#else
	'	udt(10).nm="Ulongint":udt(10).lg=Len(ULongInt)
	'#endif
	'
	'udt(11).nm="Single":udt(11).lg=Len(Single)
	'udt(12).nm="Double":udt(12).lg=Len(Double)
	'udt(13).nm="String":udt(13).lg=Len(String)
	'udt(14).nm="Fstring":udt(14).lg=Len(Integer)'4 12/07/2015
	'udt(15).nm="fb_Object":udt(15).lg=Len(UInteger)
	'udt(16).nm="Boolean": '20/082015 boolean
	For i As Integer =0 To TYPESTD:udt(i).what=1:Next '(dwarf) 20/08/2015 boolean
#endif

'Private Function Tree_AddItem(hParent As HTREEITEM, ByRef Text As WString, hInsAfter As HTREEITEM, hTV As HWND, Param As Integer) As HTREEITEM
Private Function Tree_AddItem(hParent As Any Ptr, ByRef Text As WString, hInsAfter As Any Ptr, hTV As Any Ptr, Param As Integer) As Any Ptr
	#ifdef __FB_WIN32__
		Dim hItem As HTREEITEM
		Dim tvIns As TVINSERTSTRUCT
		Dim tvI   As TV_ITEM
		tvI.mask = TVIF_TEXT Or TVIF_IMAGE Or TVIF_SELECTEDIMAGE Or TVIF_PARAM
		tvI.pszText         =  @Text
		tvI.cchTextMax      =  Len(Text)
		tvI.lParam          =  Param
		tvIns.item          =  tvI
		tvIns.hInsertAfter  =  hInsAfter
		tvIns.hParent       =  hParent
		'Pour hinsertafter soit hitem soit :
		'TVI_FIRST	Inserts the item at the beginning of the list.
		'TVI_LAST	Inserts the item at the end of the list.
		'TVI_SORT	Inserts the item into the list in alphabetical order.
		
		hItem = Cast(HTREEITEM,SendMessage(hTV,TVM_INSERTITEM,0,Cast(LPARAM,@tvIns)))
		' SendMessage(htv,TVM_SORTCHILDREN ,0,byval hparent) 'Activate to sort elements
		SendMessage(hTV,TVM_EXPAND,TVE_COLLAPSE,Cast(LPARAM,hParent))
		' SendMessage(htv,TVM_EXPAND,TVE_EXPAND,hparent)
	#else
		Dim hItem As TreeNode Ptr
		ThreadsEnter
		If hParent = 0 Then
			hItem = Cast(TreeView Ptr, hTV)->Nodes.Add(Text)
		Else
			hItem = Cast(TreeNode Ptr, hParent)->Nodes.Add(Text)
		End If
		ThreadsLeave
		hItem->Tag = Cast(Any Ptr, Param)
	#endif
	Return hItem
End Function


'Union pointeurs
'	pxxx As Any Ptr
'	pinteger As Integer Ptr
'	puinteger As UInteger Ptr
'	psingle As Single Ptr
'	pdouble As Double Ptr
'	plinteger As LongInt Ptr
'	pulinteger As ULongInt Ptr
'	pbyte As Byte Ptr
'	pubyte As UByte Ptr
'	pshort As Short Ptr
'	pushort As UShort Ptr
'	pstring As String Ptr
'	pzstring As ZString Ptr
'	pwstring As WString Ptr
'End Union
'Union valeurs
'	vinteger As Integer
'	vuinteger As UInteger
'	vsingle As Single
'	vdouble As Double
'	vlinteger As LongInt
'	vulinteger As ULongInt
'	vbyte As Byte
'	vubyte As UByte
'	vshort As Short
'	vushort As UShort
'	'vstring as string
'	'vzstring as zstring
'	'vwstring as wstring
'End Union

''BREAK ON LINE
'Const BRKMAX=10 'breakpoint index zero for "run to cursor"
'Type breakol
'	isrc    As UShort   'source index
'	nline   As UInteger 'num line for display
'	index   As Integer  'index for rline
'	ad      As UInteger 'address
'	typ     As Byte	  'type normal=1 /temporary=0, 3 or 4 =disabled
'	counter As UInteger 'counter to control the number of times the line should be executed before stopping 02/09/2015
'	cntrsav As UInteger 'to reset if needed the initial value of the counter '03/09/2015
'End Type
'Dim Shared brkol(BRKMAX) As breakol, brknb As Byte
'Dim Shared As String brkexe(9,BRKMAX) 'to save breakpoints by session
'break on var
'Type tbrkv
'
'	typ As Integer   'type of variable
'	adr As UInteger  'address
'	arr As UInteger  'adr if dyn array
'	ivr As Integer   'variable index
'	psk As Integer   'stack proc
'	Val As valeurs   'value
'	vst As String    'value as string
'	tst As Byte=1    'type of comparison (1 to 6)
'	ttb As Byte      'type of comparison (16 to 0)
'	txt As String	  'name and value just for brkv_box
'End Type
'Dim Shared brkv As tbrkv
Dim Shared brkv2 As tbrkv 'copie for use inside brkv_box
Dim Shared brkvhnd As Any Ptr   'handle

'Const VRRMAX=200000
'Type tvrr
'	ad    As UInteger 'address
'	tv    As HTREEITEM 'tview handle
'	vr    As Integer  'variable if >0 or component if <0
'	ini   As UInteger 'dyn array address (structure) or initial address in array
'	gofs  As UInteger 'global offset to optimise access
'	ix(4) As Integer  '5 index max in case of array
'	arrid As Integer  'index in array tracking for automatic tracking ''2016/06/02
'End Type
'Dim Shared vrr(VRRMAX) As tvrr
'Dim Shared vrrnb As UInteger

'VAR FIND
'Type tvarfind
'	ty As Integer
'	pt As Integer
'	nm As String    'var name or description when not a variable
'	pr As Integer   'index of running var parent (if no parent same as ivr)
'	ad As UInteger
'	iv As Integer   'index of running var
'	tv As HWND      'handle treeview
'	tl As HTREEITEM 'handle line
'End Type
'Dim Shared As tvarfind varfind

Private Sub var_iniudt(Vrbe As UInteger, adr As UInteger, tv As TreeNode Ptr, voffset As UInteger, mem As UByte) 'store udt components '05/05/2014 '09/07/2015 scope added
	Dim ad As UInteger,text As String,vadr As UInteger
	For i As Integer =udt(Vrbe).lb To udt(Vrbe).ub
		vadr=adr
		With cudt(i)
			'dbg_prt2("var ini="+.nm+" "+Str(.ofs)+" "+Str(voffset)+" "+Str(adr))
			vrrnb+=1
			If vrrnb > VRRMAX Then MsgBox ML("Max number of vars reached"): vrrnb = VRRMAX: Exit Sub
			vrr(vrrnb).vr=-i
			ad=.ofs+voffset 'offset of current element + offset all levels above
			vrr(vrrnb).gofs=ad 'however keep (global) offset
			
			If adr=0 Then 'dyn array not defined
				vrr(vrrnb).ad=0 'element in dyn array not defined  so also for the field
			Else
				vrr(vrrnb).ad=adr+ad 'real address
				vrr(vrrnb).ini=adr+ad 'used when changing index
			End If
			
			If .arr Then
				If Cast(Integer,.arr)<>-1 Then '17/04/2014
					For k As Integer =0 To 4 'set index by puting ubound
						vrr(vrrnb).ix(k)=.arr->nlu(k).lb
					Next
				Else '16/05/2014
					ad=0 'next sub field (if any) offsets are defined from this level
					vadr=0
					
					vrr(vrrnb).ini=0 'when starting again without leaving fbdebugger '19/05/2014
					If vrr(vrrnb).ad<>0 Then
						vrr(vrrnb).ini=vrr(vrrnb).ad
						'dbg_prt2("reset for dyn arr cudt="+Str(vrr(vrrnb).ini+4))
						If mem<>4 Then
							WriteProcessMemory(dbghand,Cast(LPVOID,vrr(vrrnb).ini+SizeOf(Integer)),@ad,SizeOf(Integer),0) 'reset area ptr 25/07/2015 64bit
						End If
					End If
					vrr(vrrnb).ad=0
				End If
			End If
			'dbg_prt2("variniudt final ="+.nm+" "+Str(vrr(vrrnb).ad)+" "+Str(vrr(vrrnb).gofs)+" "+Str(.ofs)+" "+Str(vrr(vrrnb).ini)+" "+Str(1))
			vrr(vrrnb).tv = Tree_AddItem(tv, "L", 0, tviewvar, vrrnb) 'Tree_AddItem(tv, "L", TVI_LAST, tviewvar, vrrnb)
			If .pt=0 AndAlso .typ>TYPESTD AndAlso .typ<>TYPEMAX  AndAlso udt(.typ).en=0 Then 'show components for bitfield 20/08/2015
				var_iniudt(.typ,vadr,vrr(vrrnb).tv,ad,mem)'09/07/2015 scope added
			End If
		End With
	Next
End Sub

Private Sub var_ini(j As UInteger ,bg As Integer ,ed As Integer) 'store information For master var
	Dim adr As UInteger
	For i As Integer = bg To ed
		With vrb(i)
			If .mem<>2 AndAlso .mem<>3 AndAlso .mem<>6 Then
				adr=.adr+procr(j).sk 'real adr
			Else
				adr=.adr
			End If
			vrrnb+=1
			If vrrnb >= VRRMAX Then MsgBox(ML("Too many variables: --> lost")):Exit Sub
			vrr(vrrnb).vr=i
			vrr(vrrnb).ad=adr
			If .arr Then
				vrr(vrrnb).ini=adr 'keep adr for [0] or structure for dyn
				'dynamic array not yet known so initialise address with null
				If Cast(Integer,.arr)=-1 Then
					vrr(vrrnb).ad=0
					If .mem <>4 Then adr=0:WriteProcessMemory(dbghand,Cast(LPVOID,vrr(vrrnb).ini+SizeOf(Integer)),@adr,SizeOf(Integer),0) '05/05/2014 25/07/2015 64bit
				Else
					For k As Integer =0 To 4 'clear index puting lbound
						vrr(vrrnb).ix(k)=.arr->nlu(k).lb
					Next
				End If
			End If
			If .mem =4 Then 'modif for byref only real address
				vrr(vrrnb).ini=adr
				ReadProcessMemory(dbghand,Cast(LPCVOID,adr),@adr,SizeOf(Integer),0)'05/05/2014 25/07/2015 64bit
				If Cast(Integer,.arr)=-1 Then vrr(vrrnb).ini=adr Else vrr(vrrnb).ad=adr
			End If
			vrr(vrrnb).tv = Tree_AddItem(procr(j).tv, "Not filled", 0, tviewvar, vrrnb) 'Tree_AddItem(procr(j).tv,"Not filled", TVI_LAST, tviewvar, vrrnb)
			If .pt=0 And .typ>TYPESTD AndAlso .typ<>TYPEMAX AndAlso udt(.typ).en=0 Then 'show components for bitfield 20/08/2015
				var_iniudt(.typ,adr,vrr(vrrnb).tv,0,.mem) '09/07/2015 scope added
			End If
		End With
	Next
End Sub

Private Function var_search(pproc As Integer,text() As String,vnb As Integer,varr As Integer,vpnt As Integer=0) As Integer
	Dim As Integer begv=procr(pproc).vr,endv=procr(pproc+1).vr,tvar=1,flagvar
	'dbg_prt2("searching="+text(1)+"__"+text(2)+"***"+Str(vnb))'18/01/2015
	flagvar=True 'either only a var either var then its components
	While begv<endv And tvar<=vnb 'inside the local vars and all the elements (see parsing)
		If flagvar Then
			If vrr(begv).vr>0 Then 'var ok
				If vrb(vrr(begv).vr).nm=text(tvar) Then 'name ok
					'testing array or not
					flagvar=0 'only one time
					If tvar=vnb Then
						If (varr=1 AndAlso vrb(vrr(begv).vr).arr<>0 ) OrElse (varr=0 And vrb(vrr(begv).vr).arr=0) Then
							Return begv 'main level
						End If
						
					End If
					tvar+=1 'next element, a component
				End If
			End If
		Else
			'component level
			If vrr(begv).vr<0 Then
				If cudt(Abs(vrr(begv).vr)).nm=text(tvar) Then
					If tvar=vnb Then
						If (varr=1 AndAlso cudt(Abs(vrr(begv).vr)).arr<>0 ) OrElse (varr=0 And cudt(Abs(vrr(begv).vr)).arr=0) Then
							Return begv'happy found !!!
						End If
					End If
					tvar+=1 'next element
				End If
			Else
				Exit While 'not found inside the UDT
			End If
		End If
		begv+=1 'next running  var or component
	Wend
	Return -1
End Function
'=======================================================
Private Sub dump_set()
    Dim tmp As String
	Dim As Integer lg,delta,combo
	For icol As Integer=1 To dumpnbcol+1
		lvMemory.Columns.Remove(1) ''delete each time column 1 keep address/ascii
	Next
	If dumptyp>=100 Then ''change number of bytes
		combo=dumptyp-100
		Select Case combo
			Case 0
				dumpnbcol=16 :lg=40
			Case 1
				dumpnbcol=8 :lg=60
			Case 2
				dumpnbcol=4 :lg=120
			Case 3
				dumpnbcol=2 :lg=160
		End Select
	Else
		Select Case dumptyp
			Case 2,3,16  'byte/ubyte/boolean    dec/hex
				dumpnbcol=16 :lg=40:combo=0
			Case 5,6  'short/ushort
				dumpnbcol=8 :lg=60:combo=1
			Case 1,8,7  'integer/uinteger
				dumpnbcol=4 :lg=90:combo=2
			Case 9,10  'longinteger/ulonginteger
				dumpnbcol=2 :lg=160:combo=3
			Case 11 'single
				dumpnbcol=4 :lg=120:combo=2
				dumpbase=0
				'SetGadgettext(GDUMPDECHEX,">Hex")
			Case 12 'double
				dumpnbcol=2 :lg=200:combo=3
				dumpbase=0
				'SetGadgettext(GDUMPDECHEX,">Hex")
		End Select
	EndIf
	delta=16/dumpnbcol
	If dumpbase=50 Then
		lg*=1.25 ''increase size if hex
	EndIf
	For icol As Integer =1 To dumpnbcol 'nb columns except address and ascii
		tmp=Right("0"+Str(delta*(icol-1)),2)
		'AddListViewColumn(GDUMPMEM, tmp, icol, icol, lg)
		lvMemory.Columns.Insert icol, tmp, , lg
	Next
	lvMemory.Columns.Insert dumpnbcol + 1, "Ascii", , 150
	'AddListViewColumn(GDUMPMEM,"Ascii",dumpnbcol+1 ,dumpnbcol+1 ,150)
	'SetItemListBox(GDUMPSIZE,combo)
	'SetGadgetText(GDUMPADR,Str(dumpadr))
	'setgadgettext(GDUMPTYPE,"Current type="+udt(dumptyp).nm)
End Sub
'==========================================
'' dumps variable memory
'==========================================
Private Sub var_dump(tv As Any Ptr, ptd As Long = 0)

	If var_find2(tv)=-1 Then Exit Sub 'search index variable under cursor

	dumpadr=varfind.ad

	If ptd Then 'dumping pointed data
		If varfind.pt = 0 Then MsgBox("Dumping pointed data", "The selected variable is not a pointer"): Exit Sub
		ReadProcessMemory(dbghand,Cast(LPCVOID,dumpadr),@dumpadr,SizeOf(Integer),0)
	EndIf

	If udt(varfind.ty).en Then
	   dumptyp=1 'if enum then as integer
	Else
	   dumptyp=varfind.ty
	End If
	If varfind.pt Then
	   dumptyp=8
	Else
	   Select Case dumptyp
		Case 13 'string
			 dumptyp=2 'default for string
			 ReadProcessMemory(dbghand,Cast(LPCVOID,dumpadr),@dumpadr,SizeOf(Integer),0) ''string address
		Case 4,14 'f or zstring
			dumptyp=2
		Case Is>TYPESTD
			 dumptyp=8 'default for pudt and any
	   End Select
	End If

	dump_set()
	dump_sh()
	tpMemory->SelectTab
End Sub

Private Function var_parent(child As Any Ptr) As Integer 'find var master parent
	Dim As Any Ptr temp, temp2, hitemp
	temp=child
	Do
		hitemp=temp2
		temp2=temp
		#ifdef __FB_WIN32__
			temp = Cast(HTREEITEM, SendMessage(tviewvar, TVM_GETNEXTITEM, TVGN_PARENT, Cast(LPARAM, temp)))
		#else
			temp = Cast(TreeNode Ptr, temp)->ParentNode
		#endif
	Loop While temp
	For i As Integer =1 To vrrnb
		If vrr(i).tv=hitemp Then Return i
	Next
End Function

Private Sub var_fill(i As Integer)
	If vrr(i).vr<0 Then
		varfind.ty=cudt(-vrr(i).vr).typ
		varfind.pt=cudt(-vrr(i).vr).pt
		varfind.nm=cudt(-vrr(i).vr).nm
		varfind.pr=vrr(var_parent(vrr(i).tv)).vr'index of the vrb
	Else
		varfind.ty=vrb(vrr(i).vr).typ
		varfind.pt=vrb(vrr(i).vr).pt
		varfind.nm=vrb(vrr(i).vr).nm
		varfind.pr=vrr(i).vr 'no parent so himself, index of the vrb
	End If
	varfind.ad=vrr(i).ad
	varfind.iv=i
	varfind.tv=tviewvar  'handle treeview
	varfind.tl=vrr(i).tv 'handle line
End Sub

Private Function proc_name(ad As UInteger) As String 'find name proc about address
	For i As Integer = 1 To procnb
		If proc(i).db=ad Then Return Str(ad)+" >> "+proc(i).nm
	Next
	Return Str(ad)
End Function

'show/expand
Const SHWEXPMAX=10 'max shwexp boxes
Const VRPMAX=5000  'max elements in each treeview
'Type tshwexp
'	Dim bx As HWND     'handle pointed value box
'	Dim tv As HWND     'corresponding tree view
'	Dim nb As Integer  'number of elements tvrp
'	Dim dl As Integer  'delta x size of type
'	Dim lb As HWND     'handle of the delta label
'End Type
'Type tvrp
'	nm As String    'name
'	ty As Integer   'type
'	pt As Integer   'is pointer
'	ad As UInteger  'address
'	tl As HTREEITEM 'line in treeview
'	'iv As Integer   'index of variables
'End Type
Dim Shared As Integer shwexpnb 'current number of show/expand box
Dim Shared As tshwexp shwexp1(1 To SHWEXPMAX) 'data for show/expand

Dim Shared As tvrp vrp1(SHWEXPMAX, VRPMAX)

Private Function watch_find() As Integer
	Dim hitem As Any Ptr
	'get current hitem in tree
	#ifdef __FB_WIN32__
		hitem = Cast(HTREEITEM, SendMessage(tviewwch, TVM_GETNEXTITEM, TVGN_CARET, 0))
	#else
		hitem = tviewwch->SelectedNode
	#endif
	For k As Integer =0 To WTCHMAX
		If wtch(k).tvl=hitem Then Return k 'found
	Next
End Function

Private Function var_find2(tv As Any Ptr) As Integer 'return -1 if error
	Dim hitem As Any Ptr, idx As Integer
	If tv=tviewvar Then
		'get current hitem in tree
		#ifdef __FB_WIN32__
			hitem=Cast(HTREEITEM,SendMessage(tviewvar,TVM_GETNEXTITEM,TVGN_CARET,0))
		#else
			hitem = tviewvar->SelectedNode
		#endif
		For i As Integer = 1 To vrrnb 'search index variable
			If vrr(i).tv=hitem Then
				If vrr(i).ad=0 Then MsgBox(ML("Variable selection error: Dynamic array not yet sized!")):Return -1
				var_fill(i)
				Return i
			End If
		Next
		MsgBox(ML("Variable selection error2: Select only a variable"))
		Return -1
	ElseIf tv=tviewwch Then
		idx=watch_find()
		If wtch(idx).psk=-3 OrElse wtch(idx).psk=-4 Then Return -1 'case non-existent local
		If wtch(idx).adr=0 Then Return -1 'dyn array
		varfind.nm=Left(wtch(idx).lbl,Len(wtch(idx).lbl)-1)
		varfind.ty=wtch(idx).typ
		varfind.pt=wtch(idx).pnt
		varfind.ad=wtch(idx).adr
		varfind.tv=tviewwch 'handle treeview
		varfind.tl=wtch(idx).tvl 'handle line
		varfind.iv=wtch(idx).ivr
	Else'shw/expand tree
		For idx =1 To SHWEXPMAX
			If shwexp1(idx).tv = tv Then Exit For 'found index matching tview
		Next
		'get current hitem in tree
		#ifdef __FB_WIN32__
			hitem = Cast(HTREEITEM, SendMessage(tv, TVM_GETNEXTITEM, TVGN_CARET, 0))
		#else
			hitem = Cast(TreeView Ptr, tv)->SelectedNode
		#endif
		For i As Integer = 1 To shwexp1(idx).nb 'search index variable
			If vrp1(idx, i).tl = hitem Then
				varfind.nm = vrp1(idx, i).nm
				If varfind.nm="" Then varfind.nm="<Memory>"
				varfind.ty = vrp1(idx, i).Ty
				varfind.pt = vrp1(idx, i).pt
				varfind.ad = vrp1(idx, i).ad
				varfind.tv=tv 'handle treeview
				varfind.tl=hitem 'handle line
				varfind.iv=-1
				Return i
			End If
		Next
	End If
End Function

#ifdef __FB_WIN32__
	Dim Shared frm As Form, txt As TextBox
	frm.SetBounds 2,2,400,260
	txt.Align = DockStyle.alClient
	frm.Add @txt
	
	Sub string_sh(tv As Any Ptr)
		Static As Byte wrapflag,buf(32004)
		If var_find2(tv)=-1 Then Exit Sub 'search index variable under cursor
		
		If varfind.ty<>4 And varfind.ty<>13 And varfind.ty<>14 And varfind.ty <>6 Then 'or ty<>15
			MsgBox("Show string error: Select only a string variable")
			Exit Sub
		End If
		stringadr=varfind.ad
		If varfind.pt Then
			ReadProcessMemory(dbghand,Cast(LPCVOID,stringadr),@stringadr,SizeOf(Integer),0) 'string ptr 27/07/2015 64bit
			If varfind.pt=2 Then ReadProcessMemory(dbghand,Cast(LPCVOID,stringadr),@stringadr,SizeOf(Integer),0) 'if two levels
		End If
		Dim f As Integer,inc As Integer=32000,wstrg As WString *32001,bufw As UShort
		If varfind.ty <>6 Then
			If varfind.ty=13 Then 'string
				ReadProcessMemory(dbghand,Cast(LPCVOID,stringadr),@stringadr,SizeOf(Integer),0)'string address
			End If
			
			
			f=stringadr
			While inc<>0
				If ReadProcessMemory(dbghand,Cast(LPCVOID,f+inc),@buf(0),4,0) Then
					f+=inc
					Exit While
				Else
					inc\=2
				End If
			Wend
			ReadProcessMemory(dbghand,Cast(LPCVOID,stringadr),@buf(0),f-stringadr,0)
			buf(f-stringadr+1)=0 'end of string if length >32000
			
			frm.Show *pfrmMain
			SetWindowTextA(txt.Handle,@buf(0))
			'txt.Text = *Cast(String Ptr, @buf(0))
			'If helpbx=0 Then helptyp=4:fb_Dialog(@help_box,"String : "+varfind.nm+"       (To change value use dump)" ,windmain,2,2,400,260)
		Else
			inc=0:wstrg=""
			ReadProcessMemory(dbghand,Cast(LPCVOID,stringadr),@bufw,2,0)
			While bufw
				wstrg[inc]=bufw
				inc+=1
				If inc=32000 Then Exit While 'limit if wstring >32000
				ReadProcessMemory(dbghand,Cast(LPCVOID,stringadr+inc*2),@bufw,2,0)
			Wend
			wstrg[inc]=0 'end of wstring
			txt.Text = wstrg
			frm.Show *pfrmMain
			'SendMessage (hedit1,WM_SETFONT,Cast(WPARAM,fonthdl),0)
			'setwindowtextw(hedit1,wstrg)
			'If helpbx=0 Then helptyp=5:fb_Dialog(@help_box,"WString (ushort) : "+varfind.nm+"       (To change value use dump)" ,windmain,2,2,400,250)
		End If
	End Sub
	
	Sub shwexp_new(tview As Any Ptr) '24/11/2014
		Dim As Integer hitem,temp,typ,pt,rvadr
		Dim As UInteger addr
		
		If tview=tviewvar Then 'if not called from tviewvar not usefull to search return value
			'get current hitem in tree
			hitem=SendMessage(tviewcur,TVM_GETNEXTITEM,TVGN_CARET,0)
			'search procr index
			For i As Integer =1 To procrnb
				If procr(i).tv=hitem Then
					temp=procr(i).idx
					addr=procr(i).sk
					rvadr=proc(procr(i).idx).rvadr
					Exit For
				End If
			Next
		End If
		If temp<>0 Then
			typ=proc(temp).rv
			pt=proc(temp).pt
			#ifdef dbg_prt2
				dbg_prt2("show ret="+proc(temp).nm+" "+Str(typ)+" "+Str(pt))
			#endif
			If typ=7 AndAlso pt=0 Then MsgBox(ML("Return value: Select a function not a sub!")):Exit Sub
			If rvadr<>0 Then 'gcc/dwarf 19/08/2015
				'addr+=rvadr
				#ifdef dbg_prt2
					dbg_prt2("show ret gcc="+proc(temp).nm+" "+Str(rvadr))
				#endif
				'If pt AndAlso (typ=13 OrElse typ>TYPESTD) Then pt-=1 'string and udt pointer unuseful here
				If typ=13 Then pt-=1
				If typ>TYPESTD Then '20/08/2015
					addr+=8
				Else
					addr+=rvadr
				End If
			Else 'gas or gcc/stabs
				If pt Then 'pointer : type doesn't matter
					addr-=4
				Else
					If typ=13 Then 'string
						addr-=12
					Else 'other type without pointer
						If typ>TYPESTD Then 'udt 20/08/2015
							'typ=7
							addr+=8
							pt=1
						Else
							If udt(proc(temp).rv).lg>4 Then
								addr-=8
							Else
								addr-=4
							End If
						End If
					End If
				End If
			End If
			'fill data to simulate var_find
			varfind.nm="Proc="+proc(temp).nm+" Return value address="+Str(addr)
			varfind.ty=proc(temp).rv
			varfind.ad=addr
			varfind.pt=pt
		ElseIf tview<>0 Then 'not coming from dump 27/11/2014
			If var_find2(tview)=-1 Then Exit Sub 'found the variable ? no if -1
		End If
		If shwexpnb<SHWEXPMAX Then  'is there a free slot ?
			
			'fb_Dialog(@shwexp_box,"Show/expand : "+varfind.nm,windmain,283,25,350,200)
		Else
			'no free slot
			MsgBox(ML("Show/Expand variable or memory: Max number of windows reached") & " ("+Str(SHWEXPMAX)+Chr(13)+ML("Close one window and try again"))
		End If
	End Sub
#endif

Private Function enum_find(t As Integer,v As Integer) As String
	'find the text associated with an enum value
	For i As Integer =udt(t).lb To udt(t).ub
		If cudt(i).Val=v Then  Return cudt(i).nm
	Next
	Return "Unknown Enum value"
End Function

Private Function var_sh2(t As Integer,pany As UInteger,p As UByte = 0,sOffset As String = "") As String
	Dim adr As UInteger,varlib As String
	Union pointers
		#ifdef __FB_64BIT__  '25/07/2015
			pinteger As Long Ptr
			puinteger As ULong Ptr
		#else
			pinteger As Integer Ptr
			puinteger As UInteger Ptr
		#endif
		pbyte As Byte Ptr
		pubyte As UByte Ptr
		pzstring As ZString Ptr
		pshort As Short Ptr
		pushort As UShort Ptr
		pvoid As Integer Ptr '25/07/2015
		pLongint As LongInt Ptr
		puLongint As ULongInt Ptr
		psingle As Single Ptr
		pdouble As Double Ptr
		pstring As String Ptr
		pfstring As ZString Ptr
		pany As Any Ptr
	End Union
	Dim Ptrs As pointers,recup(71) As Byte
	Ptrs.pany=@recup(0)
	If p Then
		If p>220 Then
			varlib=String(p-220, Str("*"))+" Function>"
		ElseIf p>200 Then
			varlib=String(p-200,Str("*"))+" Sub>"
		Else
			varlib=String(p,Str("*"))+" "+udt(t).nm+">"
		End If
		
		If flagverbose Then varlib+="[sz"+Str(SizeOf(Integer))+" / "+sOffset+Str(pany)+"]" '25/07/2015
		If pany Then
			ReadProcessMemory(dbghand,Cast(LPCVOID,pany),@recup(0),SizeOf(Integer),0) '25/07/2015
			If p>200 Then
				varlib+="="+proc_name(*Ptrs.puinteger) 'proc name
			Else
				varlib+="="+Str(*Ptrs.puinteger) 'just the value
			End If
		Else
			varlib+=" No valid value"
		End If
	Else
		varlib=udt(t).nm+">"
		If flagverbose Then varlib+="[sz "+Str(udt(t).lg)+" / "+sOffset+Str(pany)+"]"
		If pany Then
			If t>0 And t<=TYPESTD Then '20/08/2015
				varlib+="="
				Select Case t
				Case 1 'integer32/long
					ReadProcessMemory(dbghand,Cast(LPCVOID,pany),@recup(0),4,0)
					varlib+=Str(*Ptrs.pinteger)
				Case 2 'byte
					ReadProcessMemory(dbghand,Cast(LPCVOID,pany),@recup(0),1,0)
					varlib+=Str(*Ptrs.pbyte)
				Case 3 'ubyte
					ReadProcessMemory(dbghand,Cast(LPCVOID,pany),@recup(0),1,0)
					varlib+=Str(*Ptrs.pubyte)
				Case 4,13,14 'stringSSSS
					If t=13 Then  ' normal string
						ReadProcessMemory(dbghand,Cast(LPCVOID,pany),@adr,SizeOf(Integer),0) 'address ptr 25/07/2015
					Else
						adr=pany
					End If
					Clear recup(0),0,71 'max 70 char
					ReadProcessMemory(dbghand,Cast(LPCVOID,adr),@recup(0),70,0) 'value
					varlib+=*Ptrs.pzstring
				Case 5 'short
					ReadProcessMemory(dbghand,Cast(LPCVOID,pany),@recup(0),2,0)
					varlib+=Str(*Ptrs.pshort)
				Case 6 'ushort
					ReadProcessMemory(dbghand,Cast(LPCVOID,pany),@recup(0),2,0)
					varlib+=Str(*Ptrs.pushort)
				Case 7 'void  '25/07/2015
					ReadProcessMemory(dbghand,Cast(LPCVOID,pany),@recup(0),SizeOf(Integer),0)
					varlib+=Str(*Ptrs.pvoid)
				Case 8 'uinteger/ulong
					ReadProcessMemory(dbghand,Cast(LPCVOID,pany),@recup(0),4,0)
					varlib+=Str(*Ptrs.puinteger)
				Case 9 'longint/integer64
					ReadProcessMemory(dbghand,Cast(LPCVOID,pany),@recup(0),8,0)
					varlib+=Str(*Ptrs.pLongint)
				Case 10 'ulongint/uinteger64
					ReadProcessMemory(dbghand,Cast(LPCVOID,pany),@recup(0),8,0)
					varlib+=Str(*Ptrs.puLongint)
				Case 11 'single
					ReadProcessMemory(dbghand,Cast(LPCVOID,pany),@recup(0),4,0)
					varlib+=Str(*Ptrs.psingle)
				Case 12 'double
					ReadProcessMemory(dbghand,Cast(LPCVOID,pany),@recup(0),8,0)
					varlib+=Str(*Ptrs.pdouble)
				Case 16 'boolean '20/082015 boolean
					ReadProcessMemory(dbghand,Cast(LPCVOID,pany),@recup(0),1,0)
					''varlib+=Cast(boolean,*ptrs.pbyte)
					varlib+=IIf(*Ptrs.pbyte,"True","False")
					'Case Else
					'Return "Unmanaged Type>"
				End Select
			Else
				If udt(t).en Then
					If pany Then ReadProcessMemory(dbghand,Cast(LPCVOID,pany),@recup(0),4,0)
					varlib+="="+Str(*Ptrs.pinteger)+" >> "+enum_find(t,*Ptrs.pinteger) 'value/enum text
				End If
			End If
		Else
			varlib+=" No valid value"
		End If
	End If
	Return varlib
End Function

Private Function Val_string(strg As String)As String
	Dim strg2 As String,vl As Integer
	For i As Integer=1 To Len(strg) Step 2
		vl=ValInt("&h"+Mid(strg,i,2))
		If vl>31 Then
			strg2+=Chr(vl)
		Else
			strg2+="."
		End If
	Next
	Return strg2
End Function
Private Function Val_byte(strg As String)As String
	Dim strg2 As String,vl As Integer
	For i As Integer=1 To Len(strg) Step 2
		vl=ValInt("&h"+Mid(strg,i,2))
		strg2+=Str(vl)+","
	Next
	Return Left(strg2,Len(strg2)-1)
End Function
Private Function Val_word(strg As String)As String
	Dim strg2 As String,vl As Integer
	For i As Integer=1 To Len(strg) Step 4
		vl=ValInt("&h"+Mid(strg,i,4))
		strg2+=Str(vl)+","
	Next
	Return Left(strg2,Len(strg2)-1)
End Function

Private Function var_add(strg As String,t As Integer,d As Integer)As String
	Dim As Integer ValueInt
	Dim As LongInt valuelng
	
	Select Case As Const t
	Case 2,3 'byte,ubyte
		ValueInt=ValInt(strg)
		Select Case  As Const d
		Case 1'hex
			Return Hex(ValueInt,2)
		Case 2'binary
			Return Bin(ValueInt,8)
		Case 3'ascii
			Return Val_string(Hex(ValueInt,2))
		End Select
	Case 5,6 'Short,ushort
		ValueInt=ValInt(strg)
		Select Case  As Const d
		Case 1'hex
			Return Hex(ValueInt,4)
		Case 2'binary
			Return Bin(ValueInt,16)
		Case 3'ascii
			Return Val_string(Hex(ValueInt,4))
		Case 4'byte
			Return Val_byte(Hex(ValueInt,4))
		End Select
	Case 1,7,8 'integer,void,uinteger
		ValueInt=ValInt(strg)
		Select Case  As Const d
		Case 1'hex
			Return Hex(ValueInt)
		Case 2'binary
			Return Bin(ValueInt)
		Case 3'ascii
			Return Val_string(Hex(ValueInt))
		Case 4'byte
			Return Val_byte(Hex(ValueInt))
		Case 5'word
			Return Val_word(Hex(ValueInt))
		End Select
	Case 9,10 'longint,ulongint
		valuelng=ValInt(strg)
		Select Case  As Const d
		Case 1'hex
			Return Hex(valuelng)
		Case 2'binary
			Return Bin(valuelng)
		Case 3'ascii
			Return Val_string(Hex(valuelng))
		Case 4'byte
			Return Val_byte(Hex(valuelng))
		Case 5'word
			Return Val_word(Hex(valuelng))
		End Select
	End Select
End Function

'Private Function Tree_upditem(hitem As HTREEITEM,ByRef text As WString,hTV As HWND) As Integer ' UPDATE TEXT ITEM
Private Function Tree_upditem(hitem As Any Ptr, ByRef text As WString, hTV As Any Ptr) As Integer ' UPDATE TEXT ITEM
	#ifdef __FB_WIN32__
		Dim tvI As TVITEM
		tvI.mask = TVIF_TEXT
		tvI.pszText         =  @text
		tvI.cchTextMax      =  Len(text)
		tvI.hItem=hitem
		Tree_upditem = SendMessage(hTV, TVM_SETITEM, 0, Cast(LPARAM, @tvI)) 'Returns true if successful or false otherwise
	#else
		ThreadsEnter
		If hitem <> 0 Then Cast(TreeNode Ptr, hitem)->Text = text
		ThreadsLeave
		Tree_upditem = 0
	#endif
End Function

Private Sub watch_sh(aff As Integer = 0) 'default all watched
	Dim As Integer vbeg,vend
	Dim As String libel,value
	If aff=WTCHALL Then vbeg=0:vend=WTCHMAX Else vbeg=aff:vend=aff
	For i As Integer= vbeg To vend
		If wtch(i).psk<>-1 Then
			libel=wtch(i).lbl
			If wtch(i).psk=-3 Then
				value=libel
				libel+=udt(wtch(i).typ).nm
				If wtch(i).idx Then
					libel+=">=LOCAL NON-EXISTENT"
				Else
					libel+=">=Dll not loaded"
				End If
			ElseIf wtch(i).psk=-4 Then
				value=libel
			Else
				value=var_sh2(wtch(i).typ,wtch(i).adr,wtch(i).pnt)
				libel+=value '2 spaces for trace T
			End If
			'trace
			If Len(wtch(i).old)<>0 Then
				If wtch(i).old<>value Then wtch(i).old=value
				Mid(libel,1, 1) = "T"
			End If
			'additionnal data
			If wtch(i).tad Then libel+=" "+var_add(Mid(value,InStr(value,"=")+1),wtch(i).typ,wtch(i).tad)'additionnal info
			'main display
			If i<=WTCHMAIN Then SetWindowText(wtch(i).hnd,libel)
			'watched tab
			Tree_upditem(wtch(i).tvl,libel,tviewwch)
		End If
	Next
End Sub

Private Sub watch_add(f As Integer, r As Integer = -1) 'if r<>-1 session watched, return index
	Dim As Integer t
	Dim As String temps,temps2
	Dim text As WString * 100
	If r=-1 Then
		'Find first free slot
		For i As Integer =0 To WTCHMAX
			If wtch(i).psk=-1 Then t=i:Exit For 'found
		Next
		wtchcpt+=1
		'If wtchcpt=1 Then menu_enable 'enable the context menu for the watched window
	Else
		t=r
	End If
	
	wtch(t).typ=varfind.ty
	wtch(t).pnt=varfind.pt
	wtch(t).adr=varfind.ad
	wtch(t).arr=0
	wtch(t).tad=f
	
	If varfind.iv=-1 Then 'memory from dump_box or shw/expand
		wtch(t).lbl=varfind.nm
		wtch(t).psk=-2
		wtch(t).ivr=0
	Else 'variable
		wtch(t).ivr=varfind.iv
		' if dyn array store real adr
		If Cast(Integer,vrb(varfind.pr).arr)=-1 Then
			ReadProcessMemory(dbghand,Cast(LPCVOID,vrr(varfind.iv).ini),@wtch(t).arr,4,0)
		End If
		
		If varfind.iv<procr(1).vr Then'shared 04/02/2014
			wtch(t).psk=0
			For j As Long =1 To procnb
				If proc(j).nm="main" Then
					wtch(t).idx=j 'data for reactivating watch
					Exit For
				End If
			Next
			wtch(t).dlt=wtch(t).adr
			temps2="main"
		Else
			For j As UInteger = 1  To procrnb 'find proc to delete watching 'index 0 instead 1 03/02/2014
				If varfind.iv>=procr(j).vr And varfind.iv<procr(j+1).vr Then
					wtch(t).psk=procr(j).sk
					wtch(t).idx=procr(j).idx 'data for reactivating watch
					wtch(t).dlt=varfind.iv-procr(j).vr '06/02/2014 wtch(t).dlt=wtch(t).adr-wtch(t).psk
					
					If procr(j).idx=0 Then 'dll
						For k As Integer =1 To dllnb
							If dlldata(k).bse=procr(j).sk Then
								temps2=dll_name(dlldata(k).hdl,2)
								Exit For
							End If
						Next
					Else
						temps2=proc(procr(j).idx).nm
					End If
					Exit For
				End If
			Next
		End If
		'temps=var_sh1(varfind.iv) replaced by lines below 08/05/2014
		#ifdef __FB_WIN32__
			Dim tvi As TVITEM
			tvi.mask       = TVIF_TEXT
			tvi.hItem      = vrr(varfind.iv).tv
			tvi.pszText    = @(text)
			tvi.cchTextMax = 99
			SendMessage(tviewthd, TVM_GETITEM, 0, Cast(LPARAM, @tvi))
		#else
			text = Cast(TreeNode Ptr, vrr(varfind.iv).tv)->Text
		#endif
		temps=text
		'05/02/2014
		If temps="Not filled" Then temps=Mid(wtch(t).lbl,InStr(wtch(t).lbl,"/")+1)
		If InStr(temps,"/") Then 'not cudt
			temps=Left(temps,InStr(temps,"/"))
		Else
			temps=Left(temps,InStr(temps,"<"))
		End If
		wtch(t).lbl="  "+temps2+"/"+temps+" "
		
		If vrb(varfind.pr).mem=3 Then
			wtch(t).psk=0'procr(1).sk 'static
		End If
		'fill wtch vnm, vty, var - component/var bottom to top
		Dim As Any Ptr temp, temp2, hitemp
		Dim As Integer iparent,c=0
		iparent=wtch(t).ivr
		Do
			If vrr(iparent).vr>0 Then
				c+=1
				wtch(t).vnm(c)=vrb(vrr(iparent).vr).nm
				wtch(t).vty(c)=udt(vrb(vrr(iparent).vr).typ).nm
				If vrb(vrr(iparent).vr).arr Then wtch(t).Var=1 Else wtch(t).Var=0
				Exit Do
			Else
				c+=1
				wtch(t).vnm(c)=cudt(Abs(vrr(iparent).vr)).nm
				wtch(t).vty(c)=udt(cudt(Abs(vrr(iparent).vr)).typ).nm
				If cudt(Abs(vrr(iparent).vr)).arr Then wtch(t).Var=1:Exit Do Else wtch(t).Var=0
			End If
			#ifdef __FB_WIN32__
				temp=Cast(HTREEITEM,SendMessage(tviewvar,TVM_GETNEXTITEM,TVGN_PARENT,Cast(LPARAM,vrr(iparent).tv)))
			#else
				temp = Cast(TreeNode Ptr, vrr(iparent).tv)->ParentNode
			#endif
			
			For i As Integer =1 To vrrnb
				If vrr(i).tv=temp Then iparent=i
			Next
		Loop While 1
		wtch(t).vnb=c
		
	End If
	If r=-1 Then wtch(t).tvl=Tree_AddItem(NULL,"To fill", 0, tviewwch, 0) 'create an empty line in treeview
	watch_sh(t)
	wtchnew=t
End Sub

#ifdef __FB_WIN32__
	Private Sub watch_set()
		If wtchcpt>WTCHMAX Then ' free slot not found
			' change focus
			ShowWindow(tviewcur,SW_HIDE)
			tviewcur=tviewwch
			ShowWindow(tviewcur,SW_SHOW)
			SetFocus(tviewcur)
			SendMessage(htab2,TCM_SETCURSEL,3,0)
			MsgBox(ML("Add watched variable: No free slot, delete one"))
			Exit Sub
		End If
		'Already set ?
		For i As Integer =0 To WTCHMAX
			If wtch(i).psk<>-1 AndAlso wtch(i).adr=varfind.ad AndAlso wtch(i).typ=varfind.ty AndAlso _
				wtch(i).pnt=varfind.pt Then'found
				'If fb_message("Set watched variable/memory","Already existing"+Chr(13)+"Continue ?", _
				'MB_YESNO or MB_ICONQUESTION or MB_DEFBUTTON1) = IDNO Then exit sub
				wtchidx=i'for delete
				'fb_MDialog(@watch_box,"Adding watched : "+Left(wtch(i).lbl,Len(wtch(i).lbl)-1)+" already existing",windmain,50,25,180,90)
				Exit Sub
			End If
		Next
		watch_add(0)'first create no additional type
	End Sub
	
	'Sub var_tip(ope As Integer)
	'	Dim As Integer nline,lclproc,lclprocr,p,n,i,j,d,l,idx=-1
	'	Dim text As ZString *200
	'	Dim range As CHARRANGE
	'	Dim tv As HTREEITEM
	'	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	'	If tb = 0 Then Exit Sub
	'	Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	'	tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	'	'n = SendMessage(dbgrichedit,EM_LINEINDEX,-1,0) 'nb char until current line
	'	'sendmessage(dbgrichedit,EM_EXGETSEL,0, Cast(LPARAM,@range)) 'get pos cursor
	'	nline= iSelEndLine 'sendmessage(dbgrichedit,EM_EXLINEFROMCHAR,0,-1)
	'	text= tb->txtCode.Lines(iSelEndLine) 'Chr(150)+Chr(0)
	'	'sendmessage(dbgrichedit,EM_GETLINE,nline,Cast(LPARAM,@text)) 'get line text
	'	If Right(text,1)=Chr(13) Then text=Left(text,Len(text)-1) 'suppress chr$(13) at the end
	'	text=UCase(text)
	'	p=iSelEndChar + 1 'range.cpmin-n+1
	'	'select only var name characters
	'	For i =p-1 To 1 Step-1
	'		Dim c As Integer
	'		c=Asc(text,i)
	'		If ( c>=Asc("0") And c<=Asc("9") ) OrElse ( c>=Asc("A") And c<=Asc("Z") ) OrElse c=Asc("_") OrElse c=Asc(".") Then Continue For
	'		Exit For
	'	Next
	'	i+=1
	'	For j=p To Len(text)
	'		Dim c As Integer
	'		c=Asc(text,j)
	'		If ( c>=Asc("0") And c<=Asc("9") ) OrElse ( c>=Asc("A") And c<=Asc("Z") ) OrElse c=Asc("_") OrElse c=Asc(".") Then Continue For
	'		Exit For
	'	Next
	'
	'	If Asc(text,j)<>Asc("(") Then j-=1 'if last character is  a '(' take it in account (case array)
	'
	'
	'	If i>j Then
	'		text=""
	'	Else
	'		text=Mid(text,i,j-i+1) 'extract from text
	'	End If
	'
	'	If text="" Or Left(text,1)="." Then
	'		MsgBox(ML("Selection variable error") & ": """+text+""" : " & ML("Empty string or incomplete name (udt components)"))
	'		Exit Sub
	'	End If
	'
	'	'parsing
	'	Dim vname(10) As String,varray As Integer,vnb As Integer =0
	'	text+=".":l=Len(text):d=1
	'
	'	While d<l
	'		vnb+=1
	'		p=InStr(d,text,".")
	'		vname(vnb)=Mid(text,d,p-d)
	'		If Right(vname(vnb),1)="(" Then
	'			varray=1:vname(vnb)=Mid(text,d,p-d-1):d=p+2 'array
	'		Else
	'			varray=0:d=p+1
	'		End If
	'	Wend
	'
	'
	'
	'	nline+=1'in source 1 to n <> inside richedit 0 to n-1
	'	lclproc=0
	'	For i As Integer =1 To linenb
	'		If rline(i).nu=nline AndAlso rline(i).sx=shwtab Then 'is executable (known) line ?
	'			lclproc=rline(i).px:Exit For ' with known line we know also the proc...
	'		End If
	'	Next
	'
	'
	'
	'	'search inside
	'	'if no lclproc --> should be in main
	'	If lclproc Then
	'		For i As Integer =procrnb To 1 Step -1
	'			If procr(i).idx=lclproc Then lclprocr=i:Exit For ' proc running
	'		Next
	'
	'		'search the variable taking in account name and array or not
	'
	'		If lclprocr Then idx=var_search(lclprocr,vname(),vnb,varray) 'inside proc ?
	'	End If
	'	If idx=-1 Then
	'		idx=var_search(1,vname(),vnb,varray) 'inside main ?
	'		'=========== mod begin ================
	'		If idx=-1 Then '18/01/2015
	'			'namespace ?
	'			If vnb>1 Then
	'				vname(1)+="."+vname(2)
	'				vnb-=1
	'				For i As Long =2 To vnb
	'					vname(i)=vname(i+1)
	'				Next
	'				idx=var_search(1,vname(),vnb,varray)
	'			End If
	'			If idx=-1 Then	MsgBox(ML("Selection variable error") & ": """+Left(text,Len(text)-1)+""" " & ML("is not a running variable")):Exit Sub
	'		End If
	'	End If
	'	'============== end of mod ==============
	'	tv=vrr(idx).tv
	'	If ope=PROCVAR Then
	'		If tviewcur<>tviewvar Then
	'			ShowWindow(tviewcur,SW_HIDE)
	'			tviewcur=tviewvar
	'			ShowWindow(tviewcur,SW_SHOW)
	'			SendMessage(htab2,TCM_SETCURSEL,0,0)
	'		End If
	'		SendMessage(tviewvar,TVM_SELECTITEM,TVGN_CARET,Cast(LPARAM,tv))
	'		SetFocus(tviewcur)
	'	ElseIf ope=WATCHED Then
	'		If tviewcur<>tviewwch Then
	'			ShowWindow(tviewcur,SW_HIDE)
	'			tviewcur=tviewwch
	'			ShowWindow(tviewcur,SW_SHOW)
	'			SendMessage(htab2,TCM_SETCURSEL,3,0)
	'		End If
	'		'TRICK !! select the var for varfind2 like if user did that
	'		SendMessage(tviewvar,TVM_SELECTITEM,TVGN_CARET,Cast(LPARAM,tv))
	'		If var_find2(tviewvar)<>-1 Then watch_set()
	'	End If
	'End Sub
#endif

Private Sub globals_load(d As Integer = 0) 'load shared and common variables, input default=no dll number
	Dim temp As Any Ptr
	Dim As Integer vb,ve 'begin/end index global vars
	Dim As Integer vridx
	If vrbgblprev <> vrbgbl Then 'need to do ?
		If vrbgblprev=0 Then
			procr(procrnb).tv = Tree_AddItem(NULL, "Globals (shared/common) in : main ", 0, tviewvar, 0) 'only first time
			var_ini(procrnb,1,vrbgbl)'add vrbgblprev instead 1
			'dbg_prt2("procrnb="+Str(procrnb))
			procr(procrnb+1).vr=vrrnb+1 'to avoid removal of global vars when the first executed proc is not the main one reactivate line 08/06/2014
		Else
			If procrnb = PROCRMAX Then MsgBox(ML("CLOSING DEBUGGER: Max number of sub/func reached")): Exit Sub
			procrnb+=1
			#ifdef __FB_WIN32__
				temp = Cast(HTREEITEM, SendMessage(tviewvar, TVM_GETNEXTITEM, TVGN_PREVIOUS, Cast(LPARAM, procr(1).tv)))
			#else
				Var Idx = Cast(TreeNode Ptr, procr(1).tv)->Index
				If Idx > 0 Then
					If Cast(TreeNode Ptr, procr(1).tv)->ParentNode = 0 Then
						temp = tviewvar->Nodes.Item(Idx - 1)
					Else
						temp = Cast(TreeNode Ptr, procr(1).tv)->ParentNode->Nodes.Item(Idx - 1)
					End If
				End If
			#endif
			If temp=0 Then 'no item before main Then
				#ifdef __FB_WIN32__
					temp=TVI_FIRST
				#endif
			End If
			If d=0 Then 'called from extract stabs
				d=dllnb
				vb=vrbgblprev+1
				ve=vrbgbl
			Else
				vb=dlldata(d).gblb
				ve=dlldata(d).gblb+dlldata(d).gbln-1
			End If
			procr(procrnb).tv = Tree_AddItem(NULL, "Globals in : " + dll_name(dlldata(d).hdl, 2), temp, tviewvar, 0)
			procr(procrnb).sk=dlldata(d).bse
			dlldata(d).tv=procr(procrnb).tv
			var_ini(procrnb,vb,ve)
			procr(procrnb+1).vr=vrrnb+1 'put lower limit for next procr
			procr(procrnb).idx=0
			
			If wtchcpt Then
				For i As Integer= 0 To WTCHMAX
					If wtch(i).psk=-3 Then 'restart
						If wtch(i).idx=0 Then 'shared dll
							wtch(i).adr=vrr(procr(procrnb).vr+wtch(i).dlt).ad'06/02/2014  wtch(i).dlt+procr(procrnb).sk
							wtch(i).psk=procr(procrnb).sk
						End If
					ElseIf wtch(i).psk=-4 Then 'session watch
						If wtch(i).idx=0 Then 'shared dll
							vridx=var_search(procrnb,wtch(i).vnm(),wtch(i).vnb,wtch(i).Var,wtch(i).pnt)
							If vridx=-1 Then MsgBox(ML("Proc watch: Running var not found")):Continue For
							var_fill(vridx)
							watch_add(wtch(i).tad,i)
						End If
					End If
				Next
			End If
			
		End If
		'RedrawWindow tviewvar, 0, 0, 1
	End If
End Sub

Private Sub watch_check(wname() As String)
	Dim As Integer dlt,bg,ed,pidx,vidx,tidx,index,p,q,vnb,varb,ispnt,tad
	Dim As String pname,vname,vtype
	
	While wname(index)<>""
		pidx=-1:vidx=-1:p=0:vnb=1
		
		p=InStr(wname(index),"/")
		pname=Mid(wname(index),1,p-1)
		If InStr(pname,".dll") Then 'shared in dll
			pidx=0
		Else
			'check proc existing ?
			For i As Integer=1 To procnb
				If proc(i).nm=pname Then pidx=i:Exit For
			Next
		End If
		'var name : vname,vtype/ and so on then pointer number
		q=p+1
		p=InStr(q,wname(index),",")
		vname=Mid(wname(index),q,p-q)
		
		q=p+1
		p=InStr(q,wname(index),"/")
		vtype=Mid(wname(index),q,p-q)
		
		If pidx=-1 Then
			MsgBox(ML("Watched variables") & ": Proc <" + pname+ "> for <" + vname+ "> " & ML("removed, canceled")) ',, MB_SYSTEMMODAL)
			index+=1
			Continue While 'proc has been removed
		End If
		'check var existing ?
		bg=proc(pidx).vr:ed=proc(pidx+1).vr-1
		If pname="main" Then
			For i As Integer = 1 To vrbgbl
				If vrb(i).nm=vname AndAlso udt(vrb(i).typ).nm=vtype AndAlso vrb(i).arr=0 Then
					vidx=i
					tidx=vrb(i).typ
					ispnt=vrb(i).pt
					Exit For
				End If
			Next
		Else
			If pidx=0 Then 'DLL [WTC]=dll.dll/B,Integer/0/0
				For i As Integer= 1 To TYPESTD '20/08/2015
					If udt(i).nm=vtype Then tidx=i:Exit For
				Next
				wtch(index).typ=tidx
				wtch(index).psk=-4
				wtch(index).vnb=1 'only basic type or pointer
				wtch(index).idx=pidx
				wtch(index).pnt=ValInt(Right(wname(index),1))
				wtch(index).tad=0 'unknown address
				wtch(index).vnm(vnb)=vname
				wtch(index).Var=0 'not an array
				wtch(index).vty(vnb)=vtype
				wtch(index).tvl=Tree_AddItem(NULL,"", 0, tviewwch, 0)
				wtch(index).lbl=pname+"/"+vname+" <"+String(wtch(index).pnt, Str("*"))+" "+udt(tidx).nm+">=Dll not loaded"
				wtchcpt+=1
				index+=1
				Continue While
			End If
		End If
		If vidx=-1 Then
			'local
			For i As Integer = bg To ed
				If vrb(i).nm=vname AndAlso udt(vrb(i).typ).nm=vtype AndAlso vrb(i).arr=0 Then
					vidx=i
					tidx=vrb(i).typ
					ispnt=vrb(i).pt
					Exit For
				End If
			Next
		End If
		If vidx=-1 Then
			'var has been removed
			MsgBox(ML("Applying watched variables") & ": <" + vname+ "> " & ML("removed, canceled")) ',, MB_SYSTEMMODAL)
			index+=1
			Continue While
		End If
		'store value for var_search
		wtch(index).vnm(vnb)=vname
		wtch(index).Var=0
		wtch(index).vty(vnb)=vtype
		varb=vidx
		'check component
		q=p+1
		p=InStr(q,wname(index),",")
		While p
			vidx=-1
			vname=Mid(wname(index),q,p-q)
			q=p+1
			p=InStr(q,wname(index),"/")
			vtype=Mid(wname(index),q,p-q)
			For i As Integer =udt(tidx).lb To udt(tidx).ub
				With cudt(i)
					If .nm=vname AndAlso udt(.typ).nm=vtype AndAlso .arr=0 Then
						vidx=i:tidx=.typ
						ispnt=cudt(i).pt
						Exit For
					End If
				End With
			Next
			If vidx=-1 Then
				'udt has been removed
				MsgBox(ML("Applying watched variables") & ": udt <"+vname+"> " & ML("removed, canceled"))
				index+=1
				Continue While,While
			End If
			vnb+=1
			wtch(index).vnm(vnb)=vname
			wtch(index).vty(vnb)=vtype
			If tidx<=TYPESTD Then Exit While '20/08/215
			q=p+1
			p=InStr(q,wname(index),",")
		Wend
		tad=ValInt(Mid(wname(index),q,1)) 'tad
		q+=2
		If ispnt<>ValInt(Mid(wname(index),q,1)) Then 'pnt
			'pointer doesn't match
			MsgBox(ML("Applying watched variables") & ": " & Left(wname(index),Len(wname(index))-2)+" " & ML("not a pointer or pointer, canceled"))
			index+=1
			Continue While
		End If
		
		wtch(index).tvl=Tree_AddItem(NULL,"", 0, tviewwch, 0)
		wtch(index).lbl=proc(pidx).nm+"/"+vname+" <"+String(ispnt,Str("*"))+" "+udt(tidx).nm+">=" & ML("LOCAL NON-EXISTENT")
		wtch(index).typ=tidx
		wtch(index).psk=-4
		wtch(index).vnb=vnb
		wtch(index).idx=pidx
		wtch(index).pnt=ispnt
		wtch(index).tad=tad
		wtchcpt+=1
		index+=1
	Wend
	'If wtchcpt Then menu_enable
End Sub

Sub brk_apply
	Dim tb As TabWindow Ptr
	Dim curtb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	Dim As Integer FSelStartLine, FSelEndLine, FSelStartChar, FSelEndChar
	If RunningToCursor Then
		If curtb <> 0 Then
			curtb->txtCode.GetSelection FSelStartLine, FSelEndLine, FSelStartChar, FSelEndChar
		End If
	End If
	Dim f As Boolean, brknumber As UInteger
	For jj As Integer = 0 To TabPanels.Count - 1
		Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
		For i As Integer = 0 To ptabCode->TabCount - 1
			tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
			For j As Integer = 0 To sourcenb
				If EqualPaths(source(j), tb->FileName) Then
					For s As Integer = 0 To tb->txtCode.Content.Lines.Count - 1
						If Not (CInt(RunningToCursor AndAlso curtb = tb AndAlso s = FSelEndLine) OrElse CInt(Cast(EditControlLine Ptr, tb->txtCode.Content.Lines.Items[s])->Breakpoint)) Then Continue For
						For k As Integer = 1 To linenb
							If rline(k).nu=s+1 AndAlso rline(k).sx=j Then 'searching index in rline Then
								If RunningToCursor Then
									brknumber = 0
									RunningToCursor = False
								Else
									If brknb = BRKMAX Then MsgBox ML("Max number of breakpoints reached"): Exit Sub
									brknb += 1
									brknumber = brknb
								End If
								brkol(brknumber).isrc =j
								brkol(brknumber).nline=s + 1
								brkol(brknumber).index=k
								brkol(brknumber).ad   =rline(k).ad
								brkol(brknumber).typ  =1
								'brkol(brknb).cntrsav=cntr
								'brkol(brknb).counter=cntr
								'brk_color(brknb)
								f = True 'flag for managing breakpoint
								Exit For
							End If
						Next
					Next s
					Exit For
				End If
			Next
		Next
	Next
End Sub

#ifdef __FB_WIN32__
	'=== FOR DWARF ===
	Private Function remove_gcc(vname As String) As Long 'return 1 if don't keep and clean '$x' 09/01/2014 a utiliser aussi avec gen gas
		Dim As Long p
		p=InStr(vname,"$")
		If p=0 Then Return 1 'no $ in the string
		'$ in the string
		If p=1 Then '6TMP:31 or 3UDT or 8FB_rtti or 10fb_object
			If vname[2]>Asc("9") OrElse vname[2]=Asc("$") Then vname=Mid(vname,3) Else vname=Mid(vname,4)
		End If
		If Left(vname,4)="tmp$" Then Return 0 'keep tmp$xx$ for its adresse, case of simple dim arrays
		'don't keep  vr$xx: or tmp$:
		If Left(vname,3)="vr$" Then '18/07/2015 OrElse Left(vname,4)="tmp$" Then
			Return 1
		End If
		If Left(vname,10)="fb$result$" Then Return 0 'just keep it to fill rvadr
		p=InStr(vname,"$")
		'don't keep fb$result$ and TMP$xx$xx: but keep udt TMP$xx for redim
		If InStr(p+1,vname,"$") Then
			Return 1
		End If
		
		'eliminate $ and eventually the number at the end of name ex udt$1 --> udt
		'but let inchanged TMP$xx for redim array, $fb_Oject and $fb_RTTI
		If p>1 AndAlso Left(vname,4)<>"TMP$" Then vname=Left(vname,p-1)
	End Function
	
	Private Sub dw_lastline_procs(reinit1 As Long = 0) ''Retrieveing the last line number for each proc to avoid added lines by the compiler (in fact as.exe) 2016/03/24
		Static As Long prevline=-1  '' reinit in dw_module_parse
		Static As Long loopstart=1  ''
		Dim As Long prcidx
		If reinit1 = 1 Then prevline= -1: Exit Sub
		Dim As Long p=InStr(dwln,".b"),ladr,linenu
		If p=0 Then p=InStr(dwln,".B")
		linenu=ValInt(Mid(dwln,p+4))
		
		If prevline=linenu Then Exit Sub
		
		ladr=ValInt("&h"+Mid(dwln,InStr(dwln,"0x")+2))''+adrdiff
		For prcidx =loopstart To procnb
			'dbg_prt2(hex(ladr)+" "+Str(linenu)+" "+hex(proc(prcidx).db)+" "+hex(proc(prcidx).fn))
			If ladr>=proc(prcidx).db Then
				If ladr<proc(prcidx).fn Then
					proc(prcidx).lastline=linenu
					'dbg_prt2(proc(prcidx).nm+" "+hex(ladr)+" "+Str(linenu))
					loopstart=prcidx
					Exit For
				End If
			End If
		Next
		prevline=linenu
	End Sub
	
	'<0><23f9>: Abbrev Number: 1 (DW_TAG_compile_unit)
	'   <23fa>   DW_AT_producer    : GNU C 4.5.2
	'   <2406>   DW_AT_language    : 1        (ANSI C)
	'   <2407>   DW_AT_name        : testgcc2.c
	'   <2412>   DW_AT_comp_dir    : D:\laurent divers\fb dev\En-cours\FBDEBUG NEW\Tests fbdebugger
	
	''could be also :
	'  <b6>   DW_AT_language    : 1	(ANSI C)
	'  <b7>   DW_AT_name        : D:\laurent divers\freebasic64bit\soberango\generador.c
	'  <ee>   DW_AT_low_pc      : 0x4015d0
	
	'   <2451>   DW_AT_low_pc      : 0x401520
	'   <2455>   DW_AT_high_pc     : 0x40222c  or just size dwarf4
	'   <2459>   DW_AT_stmt_list   : 0x2f6
	Private Sub dw_module_parse(compname As String)
		Dim As String strg=compname,fname,comptyp,tempcompdir
		Dim As UInteger tempo
		If Right(strg,4)=".exe" Then
			str_replace(strg,".exe",".c")
		Else
			str_replace(strg,".dll",".c")''TODO .so file
		End If
		Line Input #dwff, dwln  ''ex GNU C 4.9.2
		comptyp=Mid(dwln,InStr(dwln,":")+2,InStr(dwln,"-")-InStr(dwln,":"))
		
		Line Input #dwff, dwln ''skip at_language
		
		Line Input #dwff, dwln ''short name or full name (path+name)
		If InStr(dwln,"\")=0 Then ''just name
			fname=RTrim(Mid(dwln,InStr(dwln,":")+2), Any" "+Chr(9))
			Line Input #dwff, dwln
			tempcompdir=RTrim(Mid(dwln,InStr(dwln,":")+2), Any" "+Chr(9))+"\"
		Else
			fname=RTrim(Mid(dwln,InStrRev(dwln,"\")+1), Any" "+Chr(9))
			tempcompdir=RTrim(Mid(dwln,InStr(dwln,":")+2), Any" "+Chr(9))
			tempcompdir=Mid(tempcompdir,1,InStrRev(tempcompdir,"\"))
		End If
		''If tempcompdir+fname<>strg Then flagmodule=0:exit Sub ' 29/02/2016 23/07/2015
		''dbg_prt2(tempcompdir+"----"+fname+" <?> "+strg):dbg_prt2("")
		If fname<>name_extract(strg) Then flagmodule=0:Exit Sub ' 29/02/2016
		If Right(compname,4)=".exe" Then	flagmain=False' no main proc after (case of dll with stabs)
		compdir=tempcompdir
		str_replace(compdir,"\","/") 'in dwarf lines all slashes are in linux format
		
		#ifdef fulldbg_prt
			dbg_prt ("Module : "+fname+" Gcc Version : "+comptyp)
		#endif
		Line Input #dwff, dwln  'low_pc
		tempo=ValInt("&h"+Mid(dwln,InStr(dwln,":")+4)) '14/08/2015 dwarf4
		Line Input #dwff, dwln  'high_pc
		procfn=ValInt("&h"+Mid(dwln,InStr(dwln,":")+4)) 'to be used when first breakpoint (see gest_brk)
		If procfn<tempo Then procfn+=tempo '14/08/2015 dwarf4
		Line Input #dwff, dwln
		dw_lastline_procs(1)''only done to reinit prevline value
	End Sub
	'<1><2839>: Abbrev Number: 15 (DW_TAG_union_type) idem  4 (DW_TAG_structure_type)
	'   <283a>   DW_AT_name        : POINTERS
	'   <2843>   DW_AT_byte_size   : 4
	'   <2844>   DW_AT_decl_file   : 1
	'   <2845>   DW_AT_decl_line   : 91
	'   <2846>   DW_AT_sibling     : <0x2874>
	Private Sub dw_type_parse 'DW_TAG_structure_type '09/01/2014
		If udtmax > TYPEMAX-1 Then MsgBox(ML("Storing UDT: Max limit reached ")+Str(TYPEMAX)):Exit Sub
		udtmax+=1
		udt(udtmax).what=1
		udt(udtmax).index=ValInt("&h"+Mid(dwln,6))
		Line Input #dwff, dwln
		udt(udtmax).nm=RTrim(Mid(dwln,InStr(dwln,":")+2),Any" "+Chr(9))
		If udt(udtmax).nm<>"12" Then 'no name so take lenght as name.....
			remove_gcc(udt(udtmax).nm)
			Line Input #dwff, dwln
		End If
		udt(udtmax).lg=ValInt(Mid(dwln,InStr(dwln,":")+2))
		udt(udtmax).lb=cudtnb+1
		Line Input #dwff, dwln
		Line Input #dwff, dwln
		If udt(udtmax).nm="_string" OrElse udt(udtmax).nm="12" Then  'string after _string or FBSTRING after nothing
			udtmax-=1
			'For i As Integer =1 To 27:Line Input #dwff, dwln:Next '16/07/2015
			'udt(13).index=Valint("&h"+Mid(dwln,6))
			'dbg_prt2("STRING INDEX="+Hex(udt(13).index))
		ElseIf udt(udtmax).nm="$fb_Object" Then  'fb_object is taken as a datatype
			udt(15).index=udt(udtmax).index
			udtmax-=1
			'dbg_prt2("FB_OBJECT="+Hex(udt(15).index))
			Line Input #dwff, dwln 'skip member $VPTR
			Line Input #dwff, dwln
			Line Input #dwff, dwln
			Line Input #dwff, dwln
			Line Input #dwff, dwln
			Line Input #dwff, dwln
		Else
			'dbg_prt2("UDT="+udt(udtmax).nm+" "+Hex(udt(udtmax).index))
		End If
	End Sub
	'========= UNION MEMBER =======================
	'<2><284a>: Abbrev Number: 16 (DW_TAG_member)
	'   <284b>   DW_AT_name        : PBYTE
	'   <2851>   DW_AT_decl_file   : 1
	'   <2852>   DW_AT_decl_line   : 92
	'   <2853>   DW_AT_type        : <0x2874>
	'========= STRUCTURE MEMBER ====================
	'<2><2814>: Abbrev Number: 5 (DW_TAG_member)
	'   <2815>   DW_AT_name        : A
	'or <25f>    DW_AT_name        : (indirect string, offset: 0xb): ELEMENT_LEN
	'   <2817>   DW_AT_decl_file   : 1
	'   <2818>   DW_AT_decl_line   : 87
	'   <2819>   DW_AT_type        : <0x2487>
	'   <281d>   DW_AT_data_member_location: 2 byte block: 23 0         (DW_OP_plus_uconst: 0) (-->dwarf 2)
	'      or    DW_AT_data_member_location: 0	 (--> dwarf 4)
	
	Private Sub dw_member_parse 'structure or union
		Dim As Long p
		If cudtnb = CTYPEMAX Then MsgBox(ML("Storing CUDT: Max limit reached") & " "+Str(CTYPEMAX)):Exit Sub
		cudtnb+=1
		Line Input #dwff, dwln
		p=InStr(dwln,"):") 'case indirect string
		If p Then
			cudt(cudtnb).nm=RTrim(Mid(dwln,p+3),Any" "+Chr(9))
		Else
			cudt(cudtnb).nm=RTrim(Mid(dwln,InStr(dwln,":")+2),Any" "+Chr(9))
		End If
		'cudt(cudtnb).nm=RTrim(Mid(dwln,p+1),Any" "+Chr(9))
		Line Input #dwff, dwln
		Line Input #dwff, dwln
		Line Input #dwff, dwln
		cudt(cudtnb).typ=ValInt("&h"+Mid(dwln,InStr(dwln,":")+5))
		If flagunion Then
			cudt(cudtnb).ofs=0
		Else
			Line Input #dwff, dwln
			If Len(dwln)<60 Then 'dwarf 4..... 14/08/2015
				cudt(cudtnb).ofs=ValInt( Mid(dwln,InStr(dwln,":")+2) )
			Else
				cudt(cudtnb).ofs=ValInt( Mid(dwln,InStr(60,dwln,":")+2) )
			End If
		End If
		udt(udtmax).ub=cudtnb
		'dbg_prt2("CUDT="+cudt(cudtnb).nm)
	End Sub
	'<1><24c2>: Abbrev Number: 2 (DW_TAG_typedef)
	'   <24c3>   DW_AT_name        : uinteger
	'   <24cc>   DW_AT_decl_file   : 3
	'   <24cd>   DW_AT_decl_line   : 7
	'   <24ce>   DW_AT_type        : <0x24d2>
	Private Sub dw_basic_type(nm As String,index As Integer,typ As Integer=-1)
		Select Case nm
		Case "integer","int32"
			udt(1).index=index:udt(1).typ=typ
		Case "byte","int8"
			udt(2).index=index:udt(2).typ=typ
			'dbg_prt2("type def=byte "+nm+" "+hex(index)+" "+hex(typ))
		Case "ubyte","uint8"
			udt(3).index=index:udt(3).typ=typ
		Case "uinteger","uint32"
			udt(8).index=index:udt(8).typ=typ
		Case "longint","int64"
			udt(9).index=index:udt(9).typ=typ
		Case "ulongint","uint64"
			udt(10).index=index:udt(10).typ=typ
		Case "int16"
			udt(5).index=index:udt(5).typ=typ
			'dbg_prt2("type def=int16 "+nm+" "+hex(typ))
		Case "ushort","uint16"
			udt(6).index=index:udt(6).typ=typ
			'dbg_prt2("type def=uint16 "+nm+" "+hex(typ))
		Case "single","float"
			udt(11).index=index:udt(11).typ=typ
		Case "double"
			udt(12).index=index
		Case "FBSTRING" '16/07/2015
			udt(13).index=index
		Case "boolean" '20/08/2015
			udt(16).index=index
		Case "signed char","unsigned char","short unsigned int","unsigned int","int","long unsigned int","long long int","long long unsigned int","float","short int"
			Exit Sub
		Case Else
			If udtmax > TYPEMAX-1 Then MsgBox(ML("Storing UDT basictype: Max limit reached") & " "+Str(TYPEMAX)):Exit Sub
			udtmax+=1
			udt(udtmax).what=5 'typedef
			udt(udtmax).nm=nm
			udt(udtmax).index=index
			If nm="sizetype" Then'16/07/2015
				udt(udtmax).typ=udt(1).typ 'integer
			ElseIf nm="char" Then
				udt(udtmax).typ=udt(2).typ 'byte
			Else
				udt(udtmax).typ=ValInt("&h"+Mid(dwln,InStr(dwln,":")+5))
			End If
		End Select
	End Sub
	Private Sub dw_typedef_parse
		Dim As String nm
		Dim As Long index,typ
		index=ValInt("&h"+Mid(dwln,6))
		Line Input #dwff, dwln
		nm=RTrim(Mid(dwln,InStr(dwln,":")+2),Any" "+Chr(9))
		Line Input #dwff, dwln 'skip file
		Line Input #dwff, dwln 'skip line
		Line Input #dwff, dwln 'type
		typ=ValInt("&h"+Mid(dwln,InStr(dwln,":")+5))
		dw_basic_type(nm,index,typ)
	End Sub
	'<1><279c>: Abbrev Number: 3 (DW_TAG_base_type)
	'   <279d>   DW_AT_byte_size   : 8
	'   <279e>   DW_AT_encoding    : 4        (float)
	'   <279f>   DW_AT_name        : Double
	Private Sub dw_base_parse
		Dim As String nm
		Dim As Long index
		index=ValInt("&h"+Mid(dwln,6))
		Line Input #dwff, dwln
		Line Input #dwff, dwln
		Line Input #dwff, dwln
		nm=RTrim(Mid(dwln,InStr(dwln,":")+2),Any" "+Chr(9))
		dw_basic_type(nm,index)
	End Sub
	'<1><2786>: Abbrev Number: 6 (DW_TAG_pointer_type)
	'   <2787>   DW_AT_byte_size   : 4
	'   <2788>   DW_AT_type        : <0x26dc>   NOT ALWAYS : inexisting if void
	Private Function dw_pointer_parse() As Long
		If udtmax > TYPEMAX-1 Then MsgBox(ML("Storing UDT pointer: Max limit reached") & " "+Str(TYPEMAX)):Exit Function
		udtmax+=1
		udt(udtmax).what=2
		udt(udtmax).index=ValInt("&h"+Mid(dwln,6))
		Line Input #dwff, dwln 'skip size
		Line Input #dwff, dwln
		If InStr(dwln,"DW_AT_type") Then
			udt(udtmax).typ=ValInt("&h"+Mid(dwln,InStr(dwln,":")+5))
		Else
			udt(udtmax).typ=7'void
			Return 1 'dont read
		End If
	End Function
	'<1><28b>: Abbrev Number: 8 (DW_TAG_array_type)
	'   <28c>   DW_AT_type        : <0x1a6>
	'   <290>   DW_AT_sibling     : <0x29b>
	Private Sub dw_array_parse
		If udtmax > TYPEMAX-1 Then MsgBox(ML("Storing UDT array: Max limit reached ")+Str(TYPEMAX)):Exit Sub
		udtmax+=1
		udt(udtmax).what=3
		udt(udtmax).index=ValInt("&h"+Mid(dwln,6))
		Line Input #dwff, dwln
		udt(udtmax).typ=ValInt("&h"+Mid(dwln,InStr(dwln,":")+5))
		udt(udtmax).dimnb=0
	End Sub
	'<2><294>: Abbrev Number: 9 (DW_TAG_subrange_type)
	'   <295>   DW_AT_type        : <0xe4>
	'   <299>   DW_AT_upper_bound : 7
	Private Sub dw_bound_parse
		Line Input #dwff, dwln 'skip type uinteger
		Line Input #dwff, dwln
		If udt(udtmax).dimnb=5 Then MsgBox(ML("Dwarf Parsing: Number of dim reached (5) for") & " "+udt(udtmax).nm):Exit Sub
		udt(udtmax).dimnb+=1
		udt(udtmax).bounds(udt(udtmax).dimnb)=ValInt( Mid(dwln,InStr(dwln,":")+2) )
	End Sub
	'<2><2d9>: Abbrev Number: 13 (DW_TAG_variable) if <1> then global
	'   <2da>   DW_AT_name        : vr$0        or     <2975>   DW_AT_name        : (indirect string, offset: 0x265): $BASE
	'   <2df>   DW_AT_decl_file   : 1
	'   <2e0>   DW_AT_decl_line   : 3
	'   <2e1>   DW_AT_type        : <0x2f8>
	'   <2e5>   DW_AT_location    : 2 byte block: 91 6c         (DW_OP_fbreg: -20) /         (DW_OP_breg5 (ebp): -120) / (DW_OP_addr: 0)
	
	'<2><6ca>: Abbrev Number: 17 (DW_TAG_variable)
	'  <6cb>   DW_AT_name        : (indirect string, offset: 0x17): fb$result$1
	'  <6cf>   DW_AT_decl_file   : 1
	'  <6d0>   DW_AT_decl_line   : 8
	'  <6d1>   DW_AT_type        : <0x12b>
	
	Private Sub dw_var_parse(adrdiff As UInteger)
		Dim As String pref,vrnm
		Dim As Long scp,vrtyp,vrmem,p
		Dim As Integer vradr
		If InStr(dwln,"<1>") Then vrmem=2 Else vrmem=3 'global or static
		Line Input #dwff, dwln
		p=InStr(dwln,"):") 'case indirect string
		If p Then
			vrnm=RTrim(Mid(dwln,p+3),Any" "+Chr(9))
		Else
			vrnm=RTrim(Mid(dwln,InStr(dwln,":")+2),Any" "+Chr(9))
		End If
		If remove_gcc(vrnm) Then Exit Sub
		Line Input #dwff, dwln
		Line Input #dwff, dwln
		Line Input #dwff, dwln
		
		vrtyp=ValInt("&h"+Mid(dwln,InStr(dwln,":")+5))
		
		Line Input #dwff, dwln
		If InStr(dwln,"exter") Then Line Input #dwff, dwln '<4dfa>   DW_AT_external    : 1
		If InStr(dwln,"decl") Then Exit Sub            '<4deb>   DW_AT_declaration : 1
		If InStr(dwln,"OP_addr") Then 'direct address 'global 2 static 3 NOTA COMMON ?
			vradr=adrdiff 'in case of dll relocated address
			pref="&h"
		Else
			vrmem=1 'local
			If InStr(dwln,"OP_fbreg") Then 'ESP/RSP ?
				'OLD 32 BIT Version -->>>>    vradr=8 'by default ebp=esp+8
				vradr=2*SizeOf(Integer) 'by default ebp=esp+8 or rbp=rsp+16 ?????
			ElseIf InStr(dwln,"OP_breg5") Then 'EBP/RBP
				vradr=0 'local direct adr
			Else
				m(ML("Unknown") & " DW_OP " & dwln)
			End If
		End If
		vradr+=ValInt(pref+Mid(dwln,InStr(InStr(dwln,"DW_OP_"),dwln,":")+2))
		
		If Left(vrnm,10)="fb$result$" Then 'return value
			proc(procnb).rvadr=vradr
			Exit Sub
		End If
		
		If InStr(vrnm,"_ZN") Then vrnm=cutup_names(vrnm)
		'dbg_prt2("var (name,type,adr,mem) "+vrnm+" "+Hex(Cast(Integer,vrtyp))+" "+Str(vradr)+" "+Str(vrmem))
		If vrmem=1 OrElse vrmem=3 Then
			If Left(vrnm,4)="tmp$" Then '18/07/2015 replace previous variable adr by the next one
				'dbg_prt2(vrnm+" >> "+ vrb(vrbloc).nm+" "+Str(vrb(vrbloc).adr)+" "+Str(vradr))
				vrb(vrbloc).adr=vradr
				vrb(vrbloc).typ=vrtyp
			Else
				
				If vrbloc=VARMAX Then MsgBox(ML("Init locals: Reached limit") & " "+Str(VARMAX-3000)):Exit Sub
				vrbloc+=1
				proc(procnb+1).vr=vrbloc+1 'just to have the next beginning
				vrb(vrbloc).nm=vrnm:vrb(vrbloc).typ=vrtyp:vrb(vrbloc).adr=vradr:vrb(vrbloc).mem=vrmem
				local_exist ''2016/08/12
			End If
		Else
			If vrbgbl=VGBLMAX Then MsgBox(ML("Init Globals: Reached limit") & " "+Str(VGBLMAX)):Exit Sub
			vrbgbl+=1
			vrb(vrbgbl).nm=vrnm:vrb(vrbgbl).typ=vrtyp:vrb(vrbgbl).adr=vradr:vrb(vrbgbl).mem=vrmem
		End If
	End Sub
	'<1><29b>: Abbrev Number: 10 (DW_TAG_subprogram)
	'  -->  not always existing <29c>   DW_AT_external    : 1
	'   <29d>   DW_AT_name        : TEST
	'   <2a2>   DW_AT_decl_file   : 1
	'   <2a3>   DW_AT_decl_line   : 82
	'   <2a4>   DW_AT_MIPS_linkage_name: TEST@4
	'   <2ab>   DW_AT_prototyped  : 1
	' if function -->    <2701>   DW_AT_type        : <0x279c>
	'   <2ac>   DW_AT_low_pc      : 0x0
	'   <2b0>   DW_AT_high_pc     : 0x68
	'   <2b4>   DW_AT_frame_base  : 0x0        (location list)
	'   <873>   DW_AT_GNU_all_tail_call_sites: 1
	'   <2b8>   DW_AT_sibling     : <0x2f8>
	Private Function dw_prc_parse(adrdiff As UInteger) As Long
		Line Input #dwff, dwln 'skip external
		If InStr(dwln,"DW_AT_external    : 1") Then Line Input #dwff, dwln
		procnb+=1
		proc(procnb).nm=RTrim(Mid(dwln,InStr(dwln,":")+2),Any" "+Chr(9))
		proc(procnb).nm=cutup_proc(proc(procnb).nm+":") ''23/07/2015
		'dbg_prt2 ("PRC==="+proc(procnb).nm+"xx")'23/07/2015
		remove_gcc(udt(udtmax).nm)
		Line Input #dwff, dwln 'skip file
		Line Input #dwff, dwln
		proc(procnb).nu=ValInt(Mid(dwln,InStr(dwln,":")+2))
		Line Input #dwff, dwln 'skip linkage or/and skip proto
		If InStr(dwln,"linkage_name") Then         Line Input #dwff, dwln
		Line Input #dwff, dwln
		If InStr(dwln,"AT_type") Then 'function return type
			proc(procnb).rv=ValInt("&h"+Mid(dwln,InStr(dwln,":")+5))
			Line Input #dwff, dwln
		Else
			proc(procnb).rv=7
		End If
		proc(procnb).db=ValInt("&h"+Mid(dwln,InStr(dwln,":")+4))+adrdiff
		Line Input #dwff, dwln
		proc(procnb).fn=ValInt("&h"+Mid(dwln,InStr(dwln,":")+4))+adrdiff
		If proc(procnb).fn<proc(procnb).db Then proc(procnb).fn+=proc(procnb).db '12/08/2015 dwarf 4
		'dbg_prt2 ("proc parse="+Str(procnb)+" "+hex(proc(procnb).db)+" "+Hex(proc(procnb).fn)) '23/07/2015
		proc(procnb).st=1 'state no checked
		If proc(procnb).nm="DllMain" OrElse InStr(proc(procnb).nm,"$") Then 'skip these procs, dll case
			'dbg_prt2("PRC "+proc(procnb).nm+" skipped "+hex(proc(procnb).db)+" "+Hex(proc(procnb).fn))
			Do
				Line Input #dwff, dwln
			Loop Until InStr(dwln,"<1>")
			If excldnb=EXCLDMAX Then
				MsgBox(ML("Excluding lines (Dll case): Limit reached") & " EXCLDMAX="+Str(EXCLDMAX)+Chr(10)+ML("No problem to continue but the error message below could be displayed several times") & "."+Chr(10)+"""" & ML("Line adr doesn't match proc") & """")
			Else
				excldnb+=1
				excldlines(excldnb).db=proc(procnb).db
				excldlines(excldnb).fn=proc(procnb).fn
			End If
			procnb-=1
			Return 1 'don't read
		Else
			'dbg_prt2("PRC "+proc(procnb).nm+" "+str(proc(procnb).nu)+" "+hex(proc(procnb).db)+" "+Hex(proc(procnb).fn))
		End If
		proc(procnb+1).vr=vrbloc+1 'by default even there is no local var. Otherwise error when displaying proc/var
	End Function
	
	'<2><2bc>: Abbrev Number: 11 (DW_TAG_formal_parameter)
	'   <2bd>   DW_AT_name        : B$1
	'   <2c1>   DW_AT_decl_file   : 1
	'   <2c2>   DW_AT_decl_line   : 82
	'   <2c3>   DW_AT_type        : <0x6f>
	'   <2c7>   DW_AT_location    : 2 byte block: 91 5c         (DW_OP_fbreg: -36)
	Private Sub dw_prm_parse
		Dim As Long p
		If vrbloc=VARMAX Then MsgBox(ML("Init locals: Reached limit") & " "+Str(VARMAX-3000)):Exit Sub
		vrbloc+=1
		proc(procnb+1).vr=vrbloc+1 'just to have the next beginning
		Line Input #dwff, dwln
		p=InStr(dwln,"):") 'case indirect string
		If p Then
			vrb(vrbloc).nm=RTrim(Mid(dwln,p+3),Any" "+Chr(9))
		Else
			vrb(vrbloc).nm=RTrim(Mid(dwln,InStr(dwln,":")+2),Any" "+Chr(9))
		End If
		remove_gcc(vrb(vrbloc).nm) 'to remove the '$x'
		
		Line Input #dwff, dwln
		Line Input #dwff, dwln
		Line Input #dwff, dwln
		vrb(vrbloc).typ=ValInt("&h"+Mid(dwln,InStr(dwln,":")+5))
		Line Input #dwff, dwln
		'vrb(vrbloc).adr=ValInt(Mid(dwln,InStr(InStr(dwln,"DW_OP_"),dwln,":")+2))+8'by default ebp=esp+8
		vrb(vrbloc).adr=ValInt(Mid(dwln,InStr(InStr(dwln,"DW_OP_"),dwln,":")+2))+2*SizeOf(Integer)'by default ebp=esp+8 or rbp=rsp+16 ?????
		If Left(vrb(vrbloc).nm,4)="tmp$" Then vrbloc-=1:Exit Sub 'not removed before cause could be used for var array
		vrb(vrbloc).mem=5 'by default param byval see load_debug for change value
	End Sub
	Private Sub dw_procend 'End of proc
		
		'dbg_prt2("PROCEND 1 "+Str(dwlastprc)+" "+Str(dwlastlnb)+" "+Str(proc(dwlastprc).nu)+" "+Str(rline(dwlastlnb).nu))
		If proc(dwlastprc).nu=rline(dwlastlnb).nu Then 'for proc added by fbc (constructor, operator, ...)
			proc(dwlastprc).nu=-1
			'''''''''''''rline(linenb).nu=-1
			'dbg_prt2("PROCEND 2")
			For i As Integer =1 To linenb
				'dbg_prt2("Proc db/fn inside for stab="+Hex(proc(procnb).db)+" "+Hex(proc(procnb).fn))
				'dbg_prt2("Line Adr="+Hex(rline(i).ad)+" "+Str(rline(i).ad))
				If rline(i).ad>=proc(dwlastprc).db AndAlso rline(i).ad<=proc(dwlastprc).fn Then
					'dbg_prt2("Cancel breakpoint adr="+Hex(rline(i).ad)+" "+Str(rline(i).ad))
					writeprocessmemory(dbghand,Cast(LPVOID,rline(i).ad),@rline(i).sv,1,0)
					'nota rline(linenb).nu=-1
				End If
			Next
			Exit Sub
		End If
		
		proc(dwlastprc).ed=proc(dwlastprc).fn 'for dissassembling
		proc(dwlastprc).fn=rline(dwlastlnb).ad 'for checking end of proc
		
		#ifdef dbg_prt2
			dbg_prt2("limit proc var "+proc(dwlastprc).nm+" "+Str(proc(dwlastprc).vr)+" "+Str(proc(dwlastprc+1).vr))
		#endif
	End Sub
	'File name                            Line number    Starting address
	'testgcc2.bas                         422            0x401000
	'D:/laurent divers/fb dev/En-cours/FBDEBUG NEW/Tests fbdebugger/testinc.bas: or CU: testgcc.bas: or CU: ./testgcc.bas:
	'testinc.bas                                    2            0x4017b8
	'testinc.bas                                    2            0x4017d3
	'testinc.bas                                    2            0x4017f1
	'testinc.bas                                    3            0x40180f
	Private Sub dw_lines_parse(adrdiff As UInteger, reinit1 As Long = 0)
		Dim As String fullname
		Static As Long lastline,sourceidx,linepr,flagprc
		
		Dim As Integer p=InStr(dwln,".b"),ladr,linenu
		If p=0 Then p=InStr(dwln,".B")
		If reinit1 Then 'if not doing that a next debugee's execution doesn't work  : no valid lines  14/08/2015
			lastline=0:sourceidx=0:linepr=0:flagprc=0
			Exit Sub
		End If
		
		'full name --> source
		If Right(dwln,1)=":" OrElse Right(dwln,2)="+]" Then './testgcc2.bas:[++] Then
			fullname=Left(dwln,p+3)'remove ':' or :[++] at the end
			If Left(fullname,6)="CU: ./" Then
				fullname=Mid(fullname,7)
			ElseIf Left(fullname,3)="CU:" Then
				fullname=Mid(fullname,5)
			ElseIf Left(fullname,2)="./" Then
				fullname=Mid(fullname,3)
			End If
			If InStr(fullname,":/")=0 Then
				fullname=compdir+fullname 'add current dir
			End If
			
			sourceidx=-1
			fullname=LCase(fullname)'warning for linux sensitive cas
			For i As Integer=0 To sourcenb
				If EqualPaths(source(i), fullname) Then sourceidx=i:Exit For
			Next
			If sourceidx=-1 Then
				sourcenb+=1:source(sourcenb)=fullname:srccomp(sourcenb)=2 '2=gencc+dwarf
				sourceidx=sourcenb
				#ifdef dbg_prt2
					dbg_prt2("fullname "+Str(sourcenb)+" "+fullname) '23/07/2015
				#endif
			End If
			Exit Sub
		End If
		
		linenu=ValInt(Mid(dwln,p+4))
		ladr=ValInt("&h"+Mid(dwln,InStr(dwln,"0x")+2))+adrdiff
		
		If ladr<proc(linepr).db OrElse ladr>=proc(linepr).fn Then 'out of current proc
			linepr=0
			For j As Integer=1 To procnb
				If ladr<proc(j).db Then Continue For
				If ladr>=proc(j).fn Then Continue For
				If ladr=proc(j).db Then
					If dwlastprc<>0 Then dw_procend
					lastline=0'NOTA to be removed when bug fixed, fbc 0.91 NOTA
					'''linenu=-1 NOTA
					proc(j).sr=sourceidx 'could be wrong
				End If
				linepr=j
				Exit For
			Next
		End If
		If linepr=0 Then
			p=0
			For i As Long =1 To excldnb
				If ladr>=excldlines(i).db AndAlso ladr<excldlines(i).fn Then p=1:Exit For
			Next
			If p=0 Then m "Dwarf loading: Line adr doesn't match proc "+Hex(ladr)+" "+Str(linenu) ':dbg_prt2("Line adr doesn't match proc "+Hex(ladr)+" "+Str(linenu))
			Exit Sub
		End If
		If linenu>proc(linepr).lastline Then Exit Sub ''dbg_prt2 ("NUM LINE > maxi for this proc "+hex(ladr)+" "+Str(linenu)):Exit Sub ''line added by the compiler
		If linenu>lastline Then
			'asm with just comment
			If ladr<>rline(linenb).ad Then
				linenb+=1
			Else
				writeprocessmemory(dbghand,Cast(LPVOID,rline(linenb).ad),@rline(linenb).sv,1,0)
			End If
			'
			rline(linenb).ad=ladr
			ReadProcessMemory(dbghand,Cast(LPCVOID,rline(linenb).ad),@rline(linenb).sv,1,0) 'sav 1 byte before writing &CC
			If rline(linenb).sv=CUByte("&h90") Then 'nop, address of looping (eg in a for/next loop corresponding to the instruction next) ''2016/04/01
				''commented 2016/04/01 linenb-=1
				''dbg_prt2 ("Instruction LINE = NOP, nothing done "+hex(ladr)+" "+Str(linenu))'gcc only
				''exit sub
			EndIf ''2016/04/01
			If rline(linenb).sv=CUByte("&hEB") Then
				linenb-=1
				''dbg_prt2 ("Instruction LINE = JUMP value EB, exit sub "+hex(ladr)+" "+Str(linenu))'gcc only
				Exit Sub
			End If
			
			If flagprc=1 Then
				flagprc=0:proc(linepr).sr=sourceidx 'workaround as the source file is wrong for the first proc line
			End If
			rline(linenb).nu=linenu:rline(linenb).px=linepr:dwlastlnb=linenb:rline(linenb).sx=sourceidx
			If lastline=0 Then dwlastprc=linepr:flagprc=1
			lastline=linenu
			writeprocessmemory(dbghand,Cast(LPVOID,rline(linenb).ad),@breakcpu,1,0)
			
			#ifdef fulldbg_prt
				dbg_prt("Line / adr : "+Str(rline(linenb).nu)+" "+Hex(rline(linenb).ad)+" >> "+proc(linepr).nm+" >> "+source(proc(linepr).sr))
			#endif
			
			If linenb=1 AndAlso proc(linepr).nm="main" Then 'if first executed line is in main proc, direct resume in gest_brk so adding a 'dummy' breakpoint to stop on that line  15/08/2015
				rline(linenb).nu=0
				linenb+=1
				rline(linenb).nu=linenu
				rline(linenb).ad=rline(linenb-1).ad+1 '1= to skip some code in the prologue
				rline(linenb).px=linepr
				ReadProcessMemory(dbghand,Cast(LPCVOID,rline(linenb).ad),@rline(linenb).sv,1,0) 'sav 1 byte before writing &CC
				writeprocessmemory(dbghand,Cast(LPVOID,rline(linenb).ad),@breakcpu,1,0)
			End If
		End If
	End Sub
	'<1><4796>: Abbrev Number: 34 (DW_TAG_const_type)
	Private Sub dw_const_parse
		If udtmax > TYPEMAX-1 Then MsgBox(ML("Storing UDT const: Max limit reached") & " "+Str(TYPEMAX)):Exit Sub
		udtmax+=1
		udt(udtmax).what=5
		udt(udtmax).index=ValInt("&h"+Mid(dwln,6))
		udt(udtmax).lg=4
		udt(udtmax).nm="CONST"
	End Sub
	'<1><288f>: Abbrev Number: 17 (DW_TAG_subroutine_type)
	'   <2890>   DW_AT_prototyped  : 1
	'   <2891>   DW_AT_type        : <0x2720>            warning NOT ALWAYS
	Private Function dw_prctyp_parse() As Long 'sub or function return datatype void or type
		If udtmax > TYPEMAX-1 Then MsgBox(ML("Storing UDT prctype: Max limit reached") & " "+Str(TYPEMAX)):Exit Function
		udtmax+=1
		udt(udtmax).what=4
		udt(udtmax).index=ValInt("&h"+Mid(dwln,6))
		Line Input #dwff, dwln 'skip proto
		Line Input #dwff, dwln
		If InStr(dwln,"DW_AT_type") Then
			udt(udtmax).nm="Function"
			udt(udtmax).typ=ValInt("&h"+Mid(dwln,InStr(dwln,":")+5)) 'return value
		Else
			udt(udtmax).nm="Sub"
			udt(udtmax).typ=7'void sub
			Return 1
		End If
	End Function
	Private Sub dw_replace_index 'replacing offset in memory by index in arrays
		Dim As Long idx
		For i As Integer =1 To udtmax
			'dbg_prt2("Replace Udt  "+Str(i)+" "+Str(udt(i).what)+" "+Hex(udt(i).index)+" "+Hex(udt(i).typ))'12/07/2015
		Next
		For i As Integer =udtbeg To udtmax
			If udt(i).typ Then
				idx=0
				For j As Integer =1 To TYPESTD '20/08/2015
					If udt(i).typ=udt(j).index Then idx=j:Exit For
					'basic type 2 possibilities
					If udt(i).typ=udt(j).typ   Then idx=j:Exit For
				Next
				If idx=0 Then
					For j As Integer =udtbeg To udtmax
						If udt(i).typ=udt(j).index Then idx=j:Exit For
					Next
				End If
				If idx Then
					udt(i).typ=idx
					'dbg_prt2("replace udt ok "+Str(i)+" "+Str(udt(i).what)+" "+Hex(udt(i).index)+" "+Str(udt(i).typ)+" "+udt(udt(i).typ).nm)
				Else
					'dbg_prt2("Replace Udt nok "+Str(i)+" "+Str(udt(i).what)+" "+Hex(udt(i).index)+" "+Hex(udt(i).typ))
					m("Replace dwarf: Udt nok "+Str(i)+" "+Str(udt(i).what)+" "+Hex(udt(i).index)+" "+Hex(udt(i).typ), True)
				End If
			End If
		Next
		
		For i As Integer =cudtbeg To cudtnb
			idx=0
			For j As Integer =1 To TYPESTD '20/08/2015
				If cudt(i).typ=udt(j).index Then idx=j:Exit For
				If cudt(i).typ=udt(j).typ   Then idx=j:Exit For
			Next
			If idx=0 Then
				For j As Integer =udtbeg To udtmax
					If cudt(i).typ=udt(j).index Then idx=j:Exit For
				Next
			End If
			If idx Then
				cudt(i).typ=idx
			Else
				m("Replace dwarf: Cudt not ok "+cudt(i).nm, True)
			End If
		Next
		
		For i As Integer = locbeg To vrbloc
			'dbg_prt2("Local var "+vrb(i).nm)
			idx=0
			For j As Integer =1 To TYPESTD '20/08/2015
				If vrb(i).typ=udt(j).index Then idx=j:Exit For
				If vrb(i).typ=udt(j).typ   Then idx=j:Exit For
			Next
			If idx=0 Then
				For j As Integer =udtbeg To udtmax
					If vrb(i).typ=udt(j).index Then idx=j:Exit For
				Next
			End If
			If idx Then
				vrb(i).typ=idx
			Else
				m("Replace dwarf: Vrbloc not ok "+vrb(i).nm, True)
			End If
		Next
		
		For i As Integer = vrbbeg To vrbgbl
			idx=0
			For j As Integer =1 To TYPESTD '20/08/2015
				If vrb(i).typ=udt(j).index Then idx=j:Exit For
				If vrb(i).typ=udt(j).typ   Then idx=j:Exit For
			Next
			If idx=0 Then
				For j As Integer =udtbeg To udtmax
					If vrb(i).typ=udt(j).index Then idx=j:Exit For
				Next
			End If
			If idx Then
				vrb(i).typ=idx
			Else
				m("Replace dwarf: Vrbgbl not ok "+vrb(i).nm, True)
			End If
		Next
		
		For i As Integer =prcbeg To procnb
			'dbg_prt2("Current Prc "+proc(i).nm)
			If proc(i).rv Then
				idx=0
				For j As Integer =1 To TYPESTD '20/08/2015
					If proc(i).rv=udt(j).index Then idx=j:Exit For
					If proc(i).rv=udt(j).typ   Then idx=j:Exit For
				Next
				If idx=0 Then
					For j As Integer =udtbeg To udtmax
						If proc(i).rv=udt(j).index Then idx=j:Exit For
					Next
				End If
				If idx Then
					proc(i).rv=idx
				Else
					m("Replace dwarf: Prc not ok "+proc(i).nm+" "+Hex(proc(i).rv), True)
				End If
			End If
		Next
	End Sub
	Private Function dw_udt_loop(t As Integer,arrptr As tarr Ptr Ptr=0,ptrptr As Long Ptr) As Long 'arrptr=@vrb().arr or @cudt().arr  "compress" in fbdebugger format
		Dim As Long ptrcpt
		Dim As Integer typ=t
		While 1
			If typ=0 Then Return typ
			If typ>udtmax Then m("Dwarf parsing error: No reference for index ="+Str(typ), True):Return 0
			If udt(typ).what=1 Then 'udt
				*ptrptr=ptrcpt
				Return typ
			ElseIf udt(typ).what=2 Then 'pointer
				ptrcpt+=1
				typ=udt(typ).typ
			ElseIf udt(typ).what=3 Then
				If arrnb>ARRMAX Then m("Dwarf parsing error: Max array reached "+Str(arrnb)+" can't store", True):Exit Function
				arrnb+=1
				arr(arrnb).dm=udt(typ).dimnb 'nb dim
				For i As Integer=1 To udt(typ).dimnb
					'dbg_prt2("udt loop="+Str(udt(typ).dimnb)+" "+Str(udt(typ).bounds(i)))'19/07/2015
					arr(arrnb).nlu(i-1).lb=0 'lbound always zero based
					arr(arrnb).nlu(i-1).ub=udt(typ).bounds(i)'ubound
				Next
				*arrptr=@arr(arrnb)
				typ=udt(typ).typ
			ElseIf udt(typ).what=4 Then
				typ=udt(typ).typ
				If typ=7 Then
					ptrcpt+=200
				Else
					ptrcpt+=220
				End If
			ElseIf udt(typ).what=5 Then
				' txt+="<NOT TAKEN> "+udt(typ).nm+" "
				typ=udt(typ).typ
			End If
		Wend
	End Function
	Private Sub dw_load_fbdebug
		For i As Integer =udtbeg To udtmax
			If udt(i).what=1 Then
				If udt(i).ub Then
					For j As Integer=udt(i).lb To udt(i).ub
						cudt(j).typ=dw_udt_loop(cudt(j).typ,@cudt(j).arr,@cudt(j).pt)
						If InStr(udt(cudt(j).typ).nm,"FBARRAY") Then '20/05/2014
							cudt(j).pt=cudt(udt(cudt(j).typ).lb).pt-1
							cudt(j).typ=cudt(udt(cudt(j).typ).lb).typ
							cudt(j).arr=Cast(tarr Ptr,-1) 'redim array not yet filled
						End If
					Next
				End If
			End If
		Next
		For i As Integer =prcbeg To procnb
			proc(i).rv=dw_udt_loop(proc(i).rv,,@proc(i).pt)
			If proc(i).vr<=proc(i+1).vr-1 Then
				For j As Integer =proc(i).vr To proc(i+1).vr-1
					vrb(j).typ=dw_udt_loop(vrb(j).typ,@vrb(j).arr,@vrb(j).pt)
					If vrb(j).mem=5 Then
						If vrb(j).pt Then vrb(j).mem=4 'byref if pointer WARNING : byval integer ptr equal byref integer
					End If
					If Left(udt(vrb(j).typ).nm,4)="TMP$" Then 'ReDim
						vrb(j).pt=cudt(udt(vrb(j).typ).lb).pt-1
						vrb(j).typ=cudt(udt(vrb(j).typ).lb).typ
						vrb(j).arr=Cast(tarr Ptr,-1) 'redim array not yet filled
					ElseIf InStr(udt(vrb(j).typ).nm,"FBARRAY") Then '20/05/2014
						vrb(j).pt=cudt(udt(vrb(j).typ).lb).pt-1
						vrb(j).typ=cudt(udt(vrb(j).typ).lb).typ
						vrb(j).arr=Cast(tarr Ptr,-1) 'redim array not yet filled
					ElseIf Left(udt(vrb(j).typ).nm,4)="tmp$" Then '19/07/2015
						vrb(j).pt=cudt(udt(vrb(j).typ).lb).pt-1
						vrb(j).typ=cudt(udt(vrb(j).typ).lb).typ
						vrb(j).arr=Cast(tarr Ptr,-2) 'simulate special redim
					End If
				Next
			End If
		Next
		For j As Integer =vrbbeg To vrbgbl
			vrb(j).typ=dw_udt_loop(vrb(j).typ,@vrb(j).arr,@vrb(j).pt)
			If Left(udt(vrb(j).typ).nm,4)="TMP$"  Then 'ReDim
				
				vrb(j).pt=cudt(udt(vrb(j).typ).lb).pt-1
				vrb(j).typ=cudt(udt(vrb(j).typ).lb).typ
				vrb(j).arr=Cast(tarr Ptr,-1) 'redim array not yet filled
			ElseIf InStr(udt(vrb(j).typ).nm,"FBARRAY") Then '20/05/2014
				vrb(j).pt=cudt(udt(vrb(j).typ).lb).pt-1
				vrb(j).typ=cudt(udt(vrb(j).typ).lb).typ
				vrb(j).arr=Cast(tarr Ptr,-1) 'redim array not yet filled
				
			End If
		Next
	End Sub
	
	Function GetDWFileName(ByRef dwln As WString) As UString
		Dim As WString * 300 fullname
		Dim As Integer p = InStr(dwln, ".b"), ladr, linenu
		If p = 0 Then p = InStr(dwln, ".B")
		fullname=Left(dwln,p+3)'remove ':' or :[++] at the end
		If Left(fullname,6)="CU: ./" Then
			fullname=Mid(fullname,7)
		ElseIf Left(fullname,3)="CU:" Then
			fullname=Mid(fullname,5)
		ElseIf Left(fullname,2)="./" Then
			fullname=Mid(fullname,3)
		End If
		If InStr(fullname,":/")=0 Then
			fullname=compdir+fullname 'add current dir
		End If
		Return fullname
	End Function
	
	Private Function dw_extract(nfile As String,adrdiff As UInteger) As Long 'return 1 if dwarf data for debuggee is found, if not return 0
		Dim As Integer counter
		Dim As String dissas_command
		Dim As Long flagnoread,flagline=0 '' 2016/03/24
		Dim As Long srcprevnb=sourcenb
		
		'If Dir(ExePath+"\objdump.exe")="" Then fb_message("Dwarf extract","Error : objdump.exe must be in the same directory as fbdebugger"_
		'+Chr(13)+"Only usefull in case of option -gcc, in case -gas option don't take it in account"_
		'+Chr(13)+"Objdump is also needed if case -gcc and -gas mixed code"):Return 0
		If Dir(ExePath+"\objdump.exe")="" Then Return 0 '11/01/2015
		
		dwff = FreeFile_
		'dissas_command=""""""+ExePath+"\objdump.exe"""+" --dwarf=info " """"+nfile+""""""
		dissas_command=""""""+ExePath+"\objdump.exe"" --dwarf=info """+nfile+"""""" '19/04/2015  (by marpon)
		counter=Open Pipe( dissas_command For Input As #dwff)
		Do Until EOF(dwff)
			If flagnoread=0 Then
				Line Input #dwff, dwln
			Else
				flagnoread=0
			End If
			
			'
			'<exe name>.exe:     file format pei-i386 DWARF2
			'
			'Contents of the .debug_info section:
			'
			'  Compilation Unit @ offset 0x0:
			'   Length:        0x4ba (32-bit)
			'   Version:       2              <------------ info version dwarf 2 ou 4
			'   Abbrev Offset: 0
			'   Pointer Size:  4
			' <0><b>: Abbrev Number: 1 (DW_TAG_compile_unit)
			
			If InStr(dwln,"<0>") Then flagmodule=1:dw_module_parse(nfile)
			If flagmodule=0 Then Continue Do
			If InStr(dwln,"(DW_TAG_subro") Then flagnoread=dw_prctyp_parse:Continue Do  'DW_TAG_subroutine_type
			If InStr(dwln,"(DW_TAG_stru") Then flagunion=0:dw_type_parse:Continue Do
			If InStr(dwln,"(DW_TAG_unio") Then flagunion=1:dw_type_parse:Continue Do
			If InStr(dwln,"(DW_TAG_memb") Then dw_member_parse:Continue Do
			If InStr(dwln,"(DW_TAG_poin") Then flagnoread=dw_pointer_parse:Continue Do
			If InStr(dwln,"(DW_TAG_type") Then dw_typedef_parse:Continue Do
			If InStr(dwln,"(DW_TAG_base") Then dw_base_parse:Continue Do
			If InStr(dwln,"(DW_TAG_labe") Then Continue Do 'label nothing to keep
			' NOT REALLY MANAGED ===============================
			'<2><2774>: Abbrev Number: 17 (DW_TAG_lexical_block)
			'   <2775>   DW_AT_low_pc      : 0x401600
			'   <2779>   DW_AT_high_pc     : 0x401672
			'===================================================
			If InStr(dwln,"(DW_TAG_lexi") Then Continue Do 'for now not used but could be in future for scope
			If InStr(dwln,"(DW_TAG_arra") Then dw_array_parse:Continue Do      'DW_TAG_array_type
			If InStr(dwln,"(DW_TAG_subra") Then dw_bound_parse:Continue Do    'DW_TAG_subrange_type
			If InStr(dwln,"(DW_TAG_vari") Then dw_var_parse(adrdiff):Continue Do      '(DW_TAG_variable)
			If InStr(dwln,"(DW_TAG_subp") Then flagnoread=dw_prc_parse(adrdiff):Continue Do '(DW_TAG_subprogram)
			If InStr(dwln,"(DW_TAG_form") Then dw_prm_parse:Continue Do     '(DW_TAG_formal_parameter)
			If InStr(dwln,"(DW_TAG_cons") Then dw_const_parse:Continue Do
			If InStr(dwln,": Abbrev Number: 0") Then Continue Do 'I don't what that is
			If InStr(dwln,"><") Then MsgBox(ML("Dwarf parsing: Not managed") & " "+dwln+Chr(10)+Chr(13)+ML("Please report"))
		Loop
		CloseFile_(dwff)
		'lines
		''=================== 2016/03/24
		''first pass for retrieving  the last line of each proc
		dissas_command=""""""+ExePath+"\objdump.exe"" --dwarf=decodedline """+nfile+"""""" '19/04/2015  (by marpon)
		dwff = FreeFile_
		counter=Open Pipe( dissas_command For Input As #dwff)
		Dim As UString LastPath, LastFolder
		Do Until EOF(dwff)
			Line Input #dwff, dwln
			If flagline=0 Then
				If InStr(dwln,"Starting address") Then flagline=1
				Continue Do
			End If
			If Trim(dwln) = "" Then Continue Do
			If EndsWith(dwln, ":") OrElse EndsWith(dwln, ":[++]") Then
				LastPath = GetDWFileName(dwln)
			Else
				LastPath = dwln
			End If
			LastFolder = GetFolderName(LastPath)
			If InStr(LCase(dwln), ".bas") OrElse InStr(LCase(dwln), ".bi") OrElse InStr(LCase(dwln), ".frm") OrElse InStr(LCase(dwln), ".inc") Then
				If CInt(LimitDebug) AndAlso CInt(LastFolder <> "./") AndAlso CInt(Not EqualPaths(LastFolder, mainfolder)) Then Continue Do
				dw_lastline_procs()
			End If
		Loop
		CloseFile_(dwff)
		''===================
		'lines
		'dissas_command=""""""+ExePath+"\objdump.exe"""+" --dwarf=decodedline " """"+nfile+""""""
		dissas_command=""""""+ExePath+"\objdump.exe"" --dwarf=decodedline """+nfile+"""""" '19/04/2015  (by marpon)
		dwff = FreeFile_
		counter=Open Pipe( dissas_command For Input As #dwff)
		dw_lines_parse(adrdiff,1) 'reset some values 14/08/2015
		Do Until EOF(dwff)
			Line Input #dwff, dwln
			If Trim(dwln) = "" Then Continue Do
			If EndsWith(dwln, ":") OrElse EndsWith(dwln, ":[++]") Then
				LastPath = GetDWFileName(dwln)
			Else
				LastPath = dwln
			End If
			LastFolder = GetFolderName(LastPath)
			If InStr(LCase(dwln), ".bas") OrElse InStr(LCase(dwln), ".bi") OrElse InStr(LCase(dwln), ".frm") OrElse InStr(LCase(dwln), ".inc") Then
				If CInt(LimitDebug) AndAlso CInt(LastFolder <> "./") AndAlso CInt(Not EqualPaths(LastFolder, mainfolder)) Then Continue Do
				dw_lines_parse(adrdiff)
			End If
		Loop
		CloseFile_(dwff)
		If srcprevnb=sourcenb Then Return 0 'if module not found so sourecnb is equal otherwise return 1
		dw_procend():dwlastprc=0
		dw_replace_index 'replacing all dwarf index by array index
		dw_load_fbdebug
		Return 1
	End Function
#endif
'' -------------------------------
'' Extracting debug data for elf
'' -------------------------------
Private Sub load_dat(ByVal ofset As Integer,ByVal size As Integer,ByVal ofstr As Integer)
	Dim As ustab stab
	Dim As Integer value
	Dim As String strg
	ofstr+=1 ''1 based
	#Ifdef __FB_64BIT__
		Dim As LongInt buf(1) ''16 bytes
	#else
		Dim As Long buf(2) ''12 bytes
	#endif
	Dim As Integer ofsmax,ofstemp
	#Ifdef __FB_64BIT__
		For ibuf As Integer =1 To size/16
	#else
		For ibuf As Integer =1 To size/12
	#endif
		Get #1,ofset+1,buf()
		#Ifdef __FB_64BIT__
			stab.full=buf(0)
		#else
			stab.offst=buf(0)
			stab.cod=buf(1)  And &hffff
			stab.desc=buf(1) Shr 16
		#endif
		'dbg_prt2 "C="+str(stab.cod)+" D="+str(stab.desc)+" O="+str(stab.offst);" ";
		strg=Space(2000)
		Get #1,ofstr+stab.offst,strg
		strg=""+*StrPtr(strg)
		ofstemp=ofstr+stab.offst+Len(strg)+1
		If ofstemp>ofsmax Then
			ofsmax=ofstemp
		End If
		'dbg_prt2 strg,ofstr,stab.offst,ofsmax
		#Ifdef __FB_64BIT__
			value=buf(1)
		#else
			value=buf(2)
		#endif
		'dbg_prt2 "D="+str(value)+" H="+hex(value)
		
		Select case As Const stab.cod
		case 100 '' file name
			dbg_file(strg,value)
		case 255 ''not as standard stab freebasic version and maybe other information
			'dbg_prt2 "compiled with=";strg
		case 32,38,40,128,160 'init common/ var / uninit var / local / parameter
			parse_var(strg,value)',exebase-baseimg) ''todo
		case 132 '' file name
			'dbg_prt2 "dbg include=";strg
			dbg_include(strg)
		case 36 ''procedure
			dbg_proc(strg,stab.desc,value)
		case 68 ''line
			dbg_line(stab.desc,value)
		case 224 ''address epilog
			dbg_epilog(value)
		case 42 ''main entry point
			'not used
		case 0
			#Ifdef __FB_64BIT__
				If ofsmax<>ofstr+7 Then
					ofstr=ofsmax
				End If
			#endif
		case Else
			dbg_prt2 "Unknow stab cod=";stab.cod
		End Select
		#Ifdef __FB_64BIT__
			ofset+=16
		#else
			ofset+=12
		#endif
	Next
	'dbg_prt2
End Sub
'' ------------------------------------------------------------------------------------
'' Retrieving sections .dbgdat (offset and size) and .dbgdat (offset) in the elf file
'' return 0 if an error (wrong bitness) otherwise -1
'' ------------------------------------------------------------------------------------
Private Function elf_extract(filename As String) As Integer
	Dim lgf As Integer,ulgt As Integer,ulg As ULong,usht As UShort,ofset As ULongInt,ubyt As UByte
	Dim As Integer start_section,str_section,sect_num,walk_section,dbg_dat_of,dbg_dat_size,dbg_str_of
	Dim As String sect_name= Space(40)
	
	Open filename For binary As #1
	lgf=LOF(1)
	'dbg_prt2 "lenght=";lgf
	
	ofset=of_entry
	Get #1,ofset+1,ulgt
	'dbg_prt2 "entry=";hex(ulgt)
	
	ofset=of_section
	Get #1,ofset+1,ulgt
	'dbg_prt2 "start section header=";hex(ulgt)
	start_section=ulgt
	
	ofset=of_section_size
	Get #1,ofset+1,usht
	'dbg_prt2 "section size=";usht
	
	
	ofset=of_section_num
	Get #1,ofset+1,usht
	'dbg_prt2 "section number=";usht
	sect_num=usht
	
	ofset=of_section_str
	Get #1,ofset+1,usht
	'dbg_prt2 "section string=";usht
	ofset=start_section+(usht)*sect_size+of_offset_infile
	Get #1,ofset+1,ulgt
	'dbg_prt2 "start offset string=";hex(ulgt)
	str_section=ulgt
	
	''sections
	
	walk_section=start_section
	For isec As Integer = 1 To sect_num
		'dbg_prt2 "section=";isec;" ";
		
		ofset=walk_section
		Get #1,ofset+1,ulg ''offset in str table
		'dbg_prt2 "offset string=";ulg;" ";
		ofset=str_section+ulg
		sect_name=Space(40)
		Get #1,ofset+1,sect_name
		sect_name=""+*StrPtr(sect_name)
		'dbg_prt2 "name=";sect_name
		
		ofset=walk_section+of_offset_infile
		Get #1,ofset+1,ulgt
		'dbg_prt2 "offset in file= ";hex(ulgt);" ";
		#Ifdef __FB_64BIT__
			If sect_name=".dbgdat" Then
		#else
			If sect_name=".stab" Then
		#endif
			'dbg_prt2 "name=";sect_name
			dbg_dat_of=ulgt
			#Ifdef __FB_64BIT__
			ElseIf sect_name=".dbgstr" Then
			#else
			ElseIf sect_name=".stabstr" Then
			#endif
			'dbg_prt2 "name=";sect_name
			dbg_str_of=ulgt
			Exit For ''not anymore section to retrieve
		End If
		
		ofset=walk_section+of_size_infile
		Get #1,ofset+1,ulgt
		'dbg_prt2 "size= ";hex(ulgt);" ";ulgt
		#Ifdef __FB_64BIT__
			If sect_name=".dbgdat" Then
		#else
			If sect_name=".stab" Then
		#endif
			dbg_dat_size=ulgt
		End If
		
		walk_section+=sect_size
	Next
	If dbg_dat_of=0 Then
		MsgBox(ML("Loading error: Debug data not found, compile with -gen gas/gas64 and -g"))
		Close #1
		Return -1
	Else
		load_dat(dbg_dat_of,dbg_dat_size,dbg_str_of)
	End If
	Close #1
	Return 0
End Function
'============================================================================
'' PE_extract inside memory from loaded sections (when debuggee is running)
'' return -1 if any problem
'============================================================================
Private Function debug_extract(exebase As UInteger, nfile As String, dllflag As Long = NODLL) As Integer
	Dim recup As ZString *MAX_STAB_SZ '20/07/2014
	Dim recupstab As udtstab,secnb As UShort,secnm As String *8,lastline As UShort=0,firstline As Integer=0
	Dim As UInteger basestab=0,basestabs=0,pe,baseimg,sizemax,sizestabs,proc1,proc2
	Dim sourceix As Integer,sourceixs As Integer
	Dim As Byte procfg,flag=0,procnodll=True,flagstabd=True 'flags  (flagstabd to skip stabd 68,0,1)
	Dim As Integer n=sourcenb+1,temp
	Dim procnmt As String
	Dim As Long flagdll,flagdwarf=-1
	
	flagdll=dllflag '19/09/2014
	'If Right(nfile,4)=".dll" Then lines could be removed 19/09/2014
	'	flagdll=DLL
	'Else
	'	flagdll=NODLL
	'EndIf
	
	vrbgblprev=vrbgbl
	linenbprev = linenb ''used for dll
	
	pstBar->Panels[0]->Caption = ML("Loading debug data ...")
	
	ReadProcessMemory(dbghand,Cast(LPCVOID,exebase+&h3C),@pe,4,0)
	pe+=exebase+6 'adr nb section
	ReadProcessMemory(dbghand,Cast(LPCVOID,pe),@secnb,2,0)
	#ifdef __FB_64BIT__ '22/07/2015
		pe+=42
	#else
		pe+=46 'adr compiled baseimage
	#endif
	ReadProcessMemory(dbghand,Cast(LPCVOID,pe),@baseimg,SizeOf(Integer),0) '22/07/2015
	#ifdef __FB_64BIT__ '22/07/2015
		pe+=&hD8
	#else
		pe+=&hC4 'adr sections
	#endif
	For i As UShort =1 To secnb
		Dim As UInteger basedata,sizedata
		secnm=String(8,0) 'Init var
		ReadProcessMemory(dbghand,Cast(LPCVOID,pe),@secnm,8,0) 'read 8 bytes max name size
		#Ifdef __FB_64BIT__
			If secnm = ".dbgdat" Then
		#else
			If secnm = ".stab" Then
		#endif
			ReadProcessMemory(dbghand,Cast(LPCVOID,pe+12),@basestab,4,0)
			#Ifdef __FB_64BIT__
			ElseIf secnm = ".dbgstr" Then
			#else
			ElseIf secnm = ".stabstr" Then
			#endif
			ReadProcessMemory(dbghand,Cast(LPCVOID,pe+12),@basestabs,4,0)
			ReadProcessMemory(dbghand,Cast(LPCVOID,pe+8),@sizestabs,4,0)
			'ElseIf secnm=".data" AndAlso flagdll=NODLL Then 'compinfo
			'	ReadProcessMemory(dbghand,Cast(LPCVOID,pe+12),@basedata,4,0)
			'	ReadProcessMemory(dbghand,Cast(LPCVOID,pe+8),@sizedata,4,0)
			'	compinfo_load(basedata+exebase,sizedata)
			'ElseIf secnm[0]=Asc("/") Then
			'	If flagdwarf=-1 Then 'to done only one time
			'		If udtmax<TYPESTD Then udtmax=TYPESTD '20/08/2015
			'		#ifdef __FB_WIN32__
			'			flagdwarf=dw_extract(nfile,exebase-baseimg) 'return =0 or =1 if dwarf data found
			'		#endif
			'	End If
		End If
		
		pe+=40
	Next
	If basestab=0 OrElse basestabs=0 Then
		If flagdwarf = 0 OrElse flagdwarf = -1 Then
			If flagdll=NODLL Then
				If flagattach = False Then
					MsgBox (ML("No information for Debugging. Compile with -gen gas/gas64 and -g. Killing the debuggee"), "VisualFBEditor") ', MB_TOPMOST) ' + Chr(13) + Chr(10) + ML("and -gen gas/gas64 or '-Wc -gstabs+' or '-Wc -gdwarf-2'"
				Else
					hard_closing("Attaching running program" + Chr(10) + "No information for Debugging")
				End If
			End If
			RestoreStatusText
			Return -1
		End If
	Else
		basestab += exebase + SizeOf(udtstab) ''12 for 32bit / 16 for 64bit could be greater if udtstab is changed
		basestabs += exebase
		#ifdef __FB_WIN32__
			gengcc = 0 'by default
		#endif
		While 1
			If ReadProcessMemory(dbghand,Cast(LPCVOID,basestab),@recupstab,SizeOf(udtstab),0)=0 Then
				#ifdef fulldbg_prt
					#ifdef __FB_WIN32__
						dbg_prt ("error reading memory " + GetErrorString(GetLastError))
					#else
						dbg_prt ("error reading memory")
					#EndIf
				#endif
				MsgBox (ML("Loading stabs: ERROR When reading memory"), "VisualFBEditor"): Return -1
			End If
			
			#ifdef fulldbg_prt
				dbg_prt (Str(recupstab.stabs)+" "+Str(recupstab.code)+" "+Str(recupstab.nline)+" "+Str(recupstab.ad))
			#endif
			
			If recupstab.code=0 Then Exit While
			'If recupstab.stabs Then
				If sizestabs-recupstab.stabs>MAX_STAB_SZ Then '20/07/2014
					'fb_message("Loading stabs","ERROR not enough space to load stabs string (" + Str(MAX_STAB_SZ) + "), change MAX_STAB_SZ"):Exit Sub 11/01/2015
					sizemax=MAX_STAB_SZ
				Else
					sizemax=sizestabs-recupstab.stabs
				End If
				
				If ReadProcessMemory(dbghand,Cast(LPCVOID,recupstab.stabs+basestabs),@recup,sizemax,0)=0 Then
					#Ifdef fulldbg_prt
						#ifdef __FB_WIN32__
							dbg_prt ("error reading memory "+Str(GetLastError))
						#else
							dbg_prt ("error reading memory")
						#EndIf
					#EndIf
					MsgBox (ML("Loading stabs: ERROR When reading memory") + Chr(10) + ML("Exit loading"), "VisualFBEditor"): Return -1
				End If
				
				'?recup
				#ifdef fulldbg_prt
					dbg_prt (recup)
				#endif
				
				'#ifndef __FB_WIN32__
					Select Case As Const recupstab.code
					Case 100 '' file name
						dbg_file(recup,recupstab.ad)
					Case 255 ''not as standard stab freebasic version and maybe other information
						compilerversion=recup
					Case 32,38,40,128,160 'init common/ var / uninit var / local / parameter
						parse_var(recup,recupstab.ad)',exebase-baseimg) ''todo
					Case 132 '' file name
						dbg_include(recup)
					Case 36 ''procedure
						dbg_proc(recup,recupstab.nline,recupstab.ad)
					Case 68 ''line
						dbg_line(recupstab.nline,recupstab.ad)
					Case 224 ''address epilog
						dbg_epilog(recupstab.ad)
					Case 42 ''main entry point
						'not used
					Case Else
						'dbg_prt2 "Unknow stab cod=";recupstab.code
					End Select
					'=========================================
					basestab += SizeOf(udtstab)
				'#else
				'	Select Case recupstab.code
				'	Case 36 'proc
				'		procnodll=False
				'		' procnmt=cutup_proc(Left(recup,InStr(recup,":")-1))
				'		procnmt=cutup_proc(recup) '02/11/2014
				'		If procnmt="main" Then flagstabd=True ' + A FAIRE supp l'йquivalent cidessous
				'		'If procnmt<>"" And procnmt<>"{MODLEVEL}" And(flagmain=TRUE Or procnmt<>"main") Then '' mike's bug 02/12/2015
				'		If procnmt<>"" And(flagmain=True Or procnmt<>"main") Then  '' mike's bug 02/12/2015
				'			'If InStr(procnmt,"structor : IRHLCCTX")=0 And InStr(procnmt,".LT")=0 Then
				'			If InStr(procnmt,".LT")=0 Then
				'				#ifdef fulldbg_prt
				'					dbg_prt ("Proc : "+procnmt)
				'				#endif
				'				If flagmain=True And procnmt="main" Then
				'					flagmain=False:flagstabd=True'first main ok but not the others
				'					#ifdef fulldbg_prt
				'						dbg_prt("MAIN main "+source(sourceix))
				'					#endif
				'				End If
				'				procnodll=True:proc2=recupstab.ad+exebase-baseimg 'only when <> exebase and baseimg (DLL)
				'				procfg=1:procnb+=1:proc(procnb).sr=sourceix
				'				proc(procnb).nm=procnmt 'proc(procnb).ad=proc2 keep it if needed
				'				'GCC to remove @ in proc name ex test@0: --> test:
				'				If InStr(procnmt,"@") Then
				'					procnmt=Left(procnmt,InStr(procnmt,"@")-1)
				'				End If
				'				proc(procnb).nm = procnmt
				'				' :F --> public / :f --> private then return value
				'				Dim As String recupbis
				'				If gengcc=1 Then recupbis=recup:translate_gcc(recupbis):recup=recupbis
				'				cutup_retval(procnb,Mid(recup,InStr(recup,":")+2,99))'return value .rv + pointer .pt
				'				proc(procnb).st=1 'state no checked
				'				proc(procnb).nu=recupstab.nline:lastline=0
				'				proc(procnb+1).vr=proc(procnb).vr 'in case there is not param nor local var
				'				proc(procnb).rvadr = 0 'for now only used in gcc case 19/08/2015
				'			End If
				'		End If
				'	Case 32,38,40,128,160 'init common/ var / uninit var / local / parameter
				'		cutup_1(recup,recupstab.ad,exebase-baseimg)
				'		'GCC
				'	Case 60
				'		If recup="gcc2_compiled." Then
				'			'fb_message("Compiled with option -gen gcc","     Expect few strange behaviours   ")
				'			gengcc=1
				'			srccomp(sourcenb)=gengcc 'stabs 60 arrives just after stabs 100 ....
				'		End If
				'		'END GCC
				'	Case 100
				'		If flag=0 Then
				'			If InStr(recup,":")=0  Then Exit Select ' case just name in excess then new path
				'			flag=1
				'			recup=LCase(recup)
				'			If InStr(recup,".") Then 'full name so can check
				'				temp=check_source(recup)
				'			Else
				'				temp=-1
				'			End If
				'			If temp=-1 Then
				'				sourcenb+=1:source(sourcenb)=recup:sourceix=sourcenb:sourceixs=sourceix
				'			Else
				'				sourceix=temp:sourceixs=sourceix
				'			End If
				'			dbgmaster=sourcenb 'master bas not the include files
				'			'reinit when new module (main, lib or dll)
				'			gengcc=0:procnodll=True
				'			srccomp(sourcenb)=gengcc 'could be changed after by case60 10/01/2014
				'		Else
				'			flag=0 'case path then full name or path then name
				'			'GCC
				'			If Right(recup,2)=".c" Then
				'				recup=Left(recup,Len(recup)-2)+".bas"
				'				dbgmain=sourcenb 'considering that entry point is inside this source
				'			End If
				'			'END GCC
				'			If InStr(recup,":")=0 Then recup=source(sourcenb)+recup 'path + name
				'			temp=check_source(recup)
				'			If temp<>-1 Then
				'				sourceix=temp:sourceixs=sourceix:sourcenb-=1
				'			Else
				'				source(sourcenb)=recup
				'			End If
				'		End If
				'	Case 130 'include RAS
				'	Case 132 'include
				'		#ifdef fulldbg_prt
				'			dbg_prt ("Include : "+recup)
				'		#endif
				'		'GCC
				'		' 	               If InStr(recup,":") Then 'new include file path name with file name
				'		'                     temp=check_source(recup)
				'		'                     If temp=-1 Then
				'		'                        sourcenb+=1:source(sourcenb)=recup:sourceix=sourcenb
				'		'                        srccomp(sourcenb)=gengcc
				'		'                     Else
				'		'                 	      sourceix=temp
				'		'                     End If
				'		' 	               Else
				'		'               	   sourceix=0
				'		' 	               EndIf
				'		If InStr(recup,":")=0 Then 'new include file no path only file name
				'			recup=Left(source(0),InStrRev(source(0),"\"))+recup ''add path
				'		End If
				'		recup=LCase(recup)
				'		temp=check_source(recup)
				'		If temp=-1 Then
				'			sourcenb+=1:source(sourcenb)=recup:sourceix=sourcenb
				'			srccomp(sourcenb)=gengcc
				'		Else
				'			sourceix=temp
				'		End If
				'		lastline=0 ''2018/08/03
				'		' ==
				'		'If InStr(recup,":") Then 'new include file path name with file name
				'		'	sourcenb+=1:source(sourcenb)=recup:sourceix=sourcenb' ????? Utilitй :sourcead(sourcenb)=recupstab.ad
				'		'Else 'return in main source because no path name
				'		'	sourceix=0
				'		'EndIf
				'		'just usefull if GCC because the information for include is arriving after the proc !!!
				'		If gengcc Then proc(procnb).sr=sourceix':dbg_prt("include ahah "+source(sourceix)+" "+proc(procnb).nm)
				'		'END GCC
				'	Case 42 'main proc  = entry point
				'		flagstabd=False ' order : code 42 / stabd / code 36 main
				'		dbgmain=dbgmaster
				'	Case Else
				'		#ifdef fulldbg_prt
				'			dbg_prt ("UNKNOWN stabs "+Str(recupstab.code)+" "+Str(recupstab.stabs)+" "+Str(recupstab.nline)+" "+Str(recupstab.ad)+" "+recup)
				'		#endif
				'	End Select
				'#endif
			'Else
				'#ifdef __FB_WIN32__
				'	Select Case recupstab.code
				'	Case 68
				'		'dbg_prt2("code 68 "+Str(procnodll)+" "+Str(flagstabd)+" "+Str(recupstab.nline)+" "+Str(lastline))
				'		'And recupstab.nline>lastline    : To avoid very last line see next comment about lastline
				'		'recupstab.nline<>65535 And
				'		If procnodll And flagstabd Then 'And recupstab.nline>lastline Then
				'			''''''''''''''''==
				'			'12/01/2014''''''''''''If recupstab.nline<>firstline Then
				'			If recupstab.nline Then
				'				
				'				If recupstab.nline>lastline Then
				'					'asm with just comment
				'					If recupstab.ad+proc2<>rline(linenb).ad Then
				'						linenb+=1
				'					Else
				'						WriteProcessMemory(dbghand,Cast(LPVOID,rline(linenb).ad),@rline(linenb).sv,1,0)
				'					End If
				'					rline(linenb).ad=recupstab.ad+proc2
				'					ReadProcessMemory(dbghand,Cast(LPCVOID,rline(linenb).ad),@rline(linenb).sv,1,0) 'sav 1 byte before writing &CC
				'					If rline(linenb).sv=-112 Then 'nop, address of looping (eg in a for/next loop correponding to the command next)
				'						linenb-=1
				'						'''	dbg_prt2("NUM LINE = NOP "+Str(recupstab.nline))'gcc only
				'					Else
				'						rline(linenb).nu=recupstab.nline:rline(linenb).px=procnb:rline(linenb).sx=sourceix
				'						If runtype = RTSTEP Then
				'							If LimitDebug AndAlso Not EqualPaths(GetFolderName(source(sourceix)), mainfolder) Then
				'							Else
				'								WriteProcessMemory(dbghand,Cast(LPVOID,rline(linenb).ad),@breakcpu,1,0)
				'							End If
				'						End If
				'						#ifdef fulldbg_prt
				'							dbg_prt("Line / adr : "+Str(recupstab.nline)+" "+Hex(rline(linenb).ad))
				'							dbg_prt("")
				'						#endif
				'						If recupstab.ad<>0 Then lastline=recupstab.nline 'first proc line always coded 1 but ad=0
				'						'12/01/2014'''''''''''''If recupstab.ad=0 AndAlso gengcc=1 Then
				'						''''''''''''''	firstline=recupstab.nline 'in case of gcc the line could be anything
				'						''''''''''''''	rLine(linenb).nu=-1
				'						''''''''''''''Else
				'						''''''''''''''	firstline=-1
				'						''''''''''''''EndIf
				'					End If
				'				Else
				'					'dbg_prt2("NUM LINE NOT > LAST LINE")
				'				End If
				'			Else
				'				'dbg_prt2("NUM LINE = 0")
				'			End If
				'			'12/01/2014''''''''''''''''Else
				'			''''''''''''''''dbg_prt2("STILL VERY FIRST LINE = "+Str(firstline))
				'			'12/01/2014'''''''''''EndIf
				'		End If
				'	Case 192
				'		'' if procfg And procnodll then
				'		''Begin.block proc, real first program ligne for every proc not use now
				'		''procfg=0:proc(procnb).db=recupstab.ad+proc2
				'		''else
				'		''Begin. of block
				'		''end if
				'	Case 224
				'		''End of block
				'		If procnodll Then proc1=recupstab.ad+proc2
				'	Case 36
				'		''End of proc
				'		If procnodll Then
				'			If gengcc=1 Then
				'				proc1=recupstab.ad+proc2 'under gcc 36=224 or 224 not use 10/01/2014
				'				proc(procnb).ed=recupstab.ad+proc2
				'			Else
				'				proc(procnb).ed=recupstab.ad+proc2 '18/08/2015 for gcc it's done below
				'			End If
				'			proc(procnb).fn=proc1:proc(procnb).db=proc2
				'			
				'			If proc1>procfn Then procfn=proc1+1 ' just to be sure to be above see gest_brk
				'			'dbg_prt2("Procfn stab="+Hex(procfn))
				'		End If
				'		
				'		If proc(procnb).nu=rline(linenb).nu AndAlso linenb>2 Then 'for proc added by fbc (constructor, operator, ...) '11/05/2014 adding >2 to avoid case only one line ...
				'			proc(procnb).nu=-1
				'			For i As Integer =1 To linenb
				'				'dbg_prt2("Proc db/fn inside for stab="+Hex(proc(procnb).db)+" "+Hex(proc(procnb).fn))
				'				'dbg_prt2("Line Adr="+Hex(rline(i).ad)+" "+Str(rline(i).ad))
				'				If rline(i).ad>=proc(procnb).db AndAlso rline(i).ad<=proc(procnb).fn Then
				'					'dbg_prt2("Cancel breakpoint adr="+Hex(rline(i).ad)+" "+Str(rline(i).ad))
				'					WriteProcessMemory(dbghand,Cast(LPVOID,rline(i).ad),@rline(i).sv,1,0)
				'					'nota rline(linenb).nu=-1
				'				End If
				'			Next
				'		Else
				'			'for GCC ''''''''''
				'			If gengcc Then
				'				If proc(procnb).rv=7 Then 'sub return void
				'					rline(linenb).nu-=1 'decrement the number of the last line of the proc
				'					proc(procnb).fn=rline(linenb).ad    'replace address because = next proc address
				'					''' dbg_prt2("SPECIAL GCC1 "+proc(procnb).nm+" "+Str(rline(linenb).nu)+" "+Str(rline(linenb).ad))
				'				Else 'function
				'					linenb-=1 'remove the last line (added by gcc but unexist)
				'					If proc(procnb).nm<>"main" Then 'main = NO CHANGE
				'						WriteProcessMemory(dbghand,Cast(LPVOID,rline(linenb).ad),@rline(linenb).sv,1,0) 'restore to avoid stop
				'						rline(linenb).ad=rline(linenb+1).ad 'replace the address by these of the next one
				'						rline(linenb).sv=rline(linenb+1).sv
				'						proc(procnb).fn=rline(linenb).ad    'replace address because = next proc address
				'						''' dbg_prt2("SPECIAL GCC2 "+proc(procnb).nm+" "+Str(rline(linenb).ad))
				'					Else
				'						''' dbg_prt2("SPECIAL GCC3")
				'					End If
				'				End If
				'			End If
				'		End If
				'		'''''''''''''''''''''''''''''
				'		
				'		''removing {modlevel empty just prolog and epilog
				'		If proc(procnb).nm="{MODLEVEL}" And proc(procnb).fn-proc(procnb).db <8 Then
				'			''removing lines
				'			For iline As Long = linenb To 1 Step -1
				'				If rline(iline).px=procnb Then
				'					WriteProcessMemory(dbghand,Cast(LPVOID,rline(iline).ad),@rline(iline).sv,1,0) 'restore to avoid stop
				'					linenb-=1
				'				Else
				'					Exit For
				'				End If
				'			Next
				'			'dbg_prt2("remove modlevel in"+source(proc(procnb).sr))
				'			procnb-=1 ''removing proc
				'		End If
				'	Case 162
				'		''End include
				'		sourceix=sourceixs
				'	Case 100
				'		flag=0
				'		'as the definitions for integer, ushort etc are repeated keep only the 15 first ones
				'		udtcpt=udtmax-TYPESTD '20/08/2015
				'	Case 46,78 'beginning/end of a relocatable function block, not used
				'	Case Else   ''should not happen but in this case (reported by luis) terminating the loading.... 2016/08/14
				'		#ifdef fulldbg_prt
				'			dbg_prt ("UNKNOWN "+Str(recupstab.code)+" "+Str(recupstab.stabs)+" "+Str(recupstab.nline)+" "+Str(recupstab.ad))
				'		#endif
				'		Exit While
				'	End Select
				'#endif
			'End If
			'basestab += SizeOf(udtstab)
		Wend
	End If
	'
	'#ifdef __FB_WIN32__
	'	udtbeg=udtmax+1 'to avoid replacing data already treated
	'	cudtbeg=cudtnb+1
	'	locbeg=vrbloc+1
	'	vrbbeg=vrbgbl+1
	'	prcbeg=procnb+1
	'	globals_load()
	'	
	'	If procrnb=0 Then '05/02/2014
	'		If flagwtch=0 AndAlso wtchexe(0,0)<>"" Then watch_check(wtchexe())'19/04/2014
	'		flagwtch=0
	'	End If
	'	
	'	
	'	'SendMessage(dbgstatus,SB_SETTEXT,0,Cast(LPARAM,@"Loading sources"))
	'	'load_sources(n)
	'	'activate buttons/menu after real start
	'	'but_enable()
	'	'menu_enable()
	'	brk_apply 'apply previous breakpoints
	'	If runtype = RTFRUN Then
	'		For j As Integer = 0 To brknb 'breakpoint
	'			If brkol(j).typ<3 Then WriteProcessMemory(dbghand,Cast(LPVOID,brkol(j).ad),@breakcpu,1,0) 'only enabled
	'		Next
	'	End If
	'#endif
	'
	RestoreStatusText
	
End Function

'===================================================
'' list all extracted data
'===================================================
Private Sub list_all()
	Dim scopelabel(1 To ...) As Const WString Ptr = {@"local", @"global", @"static", @"byref param", @"byval param", @"common"}
	Print "sources ------------------------------------------------------- ";"total=";sourcenb+1
	For isrc As Integer =0 To sourcenb
		Print "isrc=";isrc;" ";source(isrc)
	Next
	Print "procedures ------------------------------------------------------- ";procnb
	For iprc As Integer =1 To procnb
		Print "iprc=";iprc;" ";source(proc(iprc).sr);" ";proc(iprc).nm;" ";proc(iprc).nu;" ";udt(proc(iprc).rv).nm
		Print "lower/upper/end ad=";Hex(proc(iprc).db);" ";Hex(proc(iprc).fn);" ";Hex(proc(iprc).ed)
	Next
	Print "Lines ---------------------------------------------------------- ";linenb
	For iline As Integer = 1 To linenb
		Print "iline=";iline;" proc=";proc(rline(iline).px).nm;" ";rline(iline).nu;" ";Hex(rline(iline).ad)
	Next
	Print
	Print "types ----------------------------------------------------------- ";udtmax
	For iudt As Integer=1 To udtmax
		If udt(iudt).nm<>"" Then
			Print "iudt=";iudt;" ";udt(iudt).nm;" ";udt(iudt).lg
			If udt(iudt).ub<>0 Then
				For icudt As Integer =udt(iudt).lb To udt(iudt).ub
					Print "icudt=";cudt(icudt).nm
				Next
			End If
		End If
	Next
	Print "global variables ---------------------------------------------------------- ";vrbgbl
	For ivrb As Integer=1 To vrbgbl
		Print "ivrb=";ivrb;" ";vrb(ivrb).nm;" ";udt(vrb(ivrb).typ).nm;" ";vrb(ivrb).adr;" ";*scopelabel(vrb(ivrb).mem)
	Next
	Print "local variables ----------------------------------------------------------- ";vrbloc-VGBLMAX
	For ivrb As Integer=VGBLMAX+1 To vrbloc
		Print "ivrb=";ivrb;" ";vrb(ivrb).nm;" ";udt(vrb(ivrb).typ).nm;" ";vrb(ivrb).adr;" ";*scopelabel(vrb(ivrb).mem)
	Next
	Print "end of list all"
End Sub

#ifdef __FB_WIN32__
	Sub thread_rsm()
		WriteProcessMemory(dbghand,Cast(LPVOID,rline(thread(threadcur).sv).ad),@rline(thread(threadcur).sv).sv,1,0) 'restore old value for execution
		ResumeThread(threadhs)
	End Sub
#endif
'===========================================
'' update status bar with thread state
'===========================================
Private Sub thread_status()
	Dim As Integer thrun,thstop,thblk,thidle
	Dim As String text
	For ith As Integer=0 To threadnb
		dbg_prt2  "ith=",ith,thread(ith).id,thread(ith).sts
		Select Case thread(ith).sts
		Case KTHD_RUN
			thrun+=1
		Case KTHD_STOP
			thstop+=1
		Case KTHD_BLKD
			thblk+=1
		Case KTHD_IDLE
			thidle+=1
		End Select
	Next
	text="RSBI="+Right("0"+LTrim(Str(thrun)),2)+"/"+Right("0"+LTrim(Str(thstop)),2)+"/"+Right("0"+LTrim(Str(thblk)),2)+"/"+Right("0"+LTrim(Str(thidle)),2)
	'statusbar_text(KSTBTHS, text)
End Sub
'===========================================
'' restore instruction and resume thread
'===========================================
Private Sub thread_resume(thd As Integer=-1)
	Dim As Integer thdbeg=0,thdend=threadnb
	#ifdef __FB_WIN32__
		''todo move to dbg_windows.bas
		
		If thd<>-1 Then
			thdbeg=thd
			thdend=thd
		End If
		For ith As Integer = thdbeg To thdend
			'dbg_prt2 "in thread resume 1=";ith,thread(ith).id,thread(ith).sts,thread(ith).rtype,rLine(thread(ith).sv).nu
			'if thread(ith).sts<>KTHD_BLKD and thread(ith).sts<>KTHD_INIT  then
			If thread(ith).sts=KTHD_STOP Then ''not those BLKD or INIT and useless those RUN
				''restore old value for execution
				If thread(ith).sv>0 Then ''if attachment no saved line
					writeprocessmemory(dbghand,Cast(LPVOID,rline(thread(ith).sv).ad),@rline(thread(ith).sv).sv,1,0)
				End If
				thread(ith).sts=KTHD_RUN
				thread(ith).rtype=runtype
				dbg_prt2 "in thread resume 2=";ith,thread(ith).id,thread(ith).sts,thread(ith).rtype,rline(thread(ith).sv).nu
				thread_status()
				thread_text(ith)
				ResumeThread(thread(ith).hd)
			End If
		Next
	#else
		''LINUX, maybe moved in dbg_linux.bas
		thread_rsm()
	#endif
End Sub
'================================================
'' blocks/unblocks the selected thread
'================================================
Private Sub thread_block()
	Var th=thread_select()
	If thread(th).sts=KTHD_BLKD Then
		thread(th).sts=KTHD_STOP
	ElseIf thread(th).sts=KTHD_STOP Then
		thread(th).sts=KTHD_BLKD
	Else
		MsgBox("Trying to block thread", "Only if stopped")
	End If
	thread_text(th)
	thread_status()
End Sub
'====================================
'' returns index using thread().id
'====================================
Private Function thread_index(tid As Long) As Integer
	For ith As Integer =0 To threadnb
		If tid=thread(ith).id Then
			Return ith
		End If
	Next
End Function
'=========================================
''
'=========================================
Private Sub thread_set()
	If (runtype=RTSTEP Or runtype=RTAUTO) And threadnb > 0 Then
		threadlistidx=-1
		For idx As Integer = threadnb To 0 Step -1
			If thread(idx).sts=KTHD_STOP Then
				dbg_prt2 "idx for multiaction=";idx
				threadlistidx+=1
				threadlist(threadlistidx)=thread(idx).id
				thread(threadlistidx).rtype=runtype
			ElseIf thread(idx).sts=KTHD_RUN Then
				threadlistidx=-1
				Exit Sub
			End If
		Next
	End If
	If threadlistidx>0 Then
		multiaction=KMULTISTEP
	Else
		multiaction=KMULTINOTHING
		thread(0).rtype=runtype
		threadlistidx=-1
		thread_resume(0)
	End If
End Sub
'===========================================================================================
'' In auto/step mode force to continue threads when one is waiting (sleep, input, condwait)
'===========================================================================================
Private Sub thread_idle()
	Dim t As Integer
	t=thread_select()
	If thread(t).sts<>KTHD_RUN Then
		MsgBox("Marking Thread Idle", "Only thread running can be marked idle")
	End If
	thread(t).sts=KTHD_IDLE
	If threadlistidx=-1 Then
		dbg_prt2 "continuing new list of threads"
		thread_set()
	Else
		dbg_prt2 "continuing current list of threads=";threadlistidx
		thread_resume(thread_index(threadlist(threadlistidx)))
		threadlistidx-=1
		If threadlistidx=-1 Then
			multiaction=KMULTINOTHING
		End If
	End If
End Sub
'===============================================================================
Private Sub close_all()
	'dbg_prt2 "destroy mutex and condvar"
	MutexDestroy blocker
	#ifndef __FB_WIN32__
		CondSignal(condid)
		CondDestroy(condid)
	#endif
	'dbg_prt2 "release doc"
	'release_doc ''releases scintilla docs
	''todo free all the objects menus, etc
	If sourcenb<>-1 Then
		'watch_sav()
		brk_sav()
	End If
	'ini_write()
	'End
End Sub
'================================
''
'================================
Private Sub process_terminated()
	KillTimer(hmain,GTIMER001)
	'watch_sav()
	brk_sav()
	runtype=RTEND
	KillTimer 0, 0
	InDebug = False
	DeleteDebugCursor
	Dim As Unsigned Long ExitCode
	#ifdef __FB_WIN32__
		GetExitCodeProcess(pinfo.hProcess, @ExitCode)
	#Endif
	Var Result = ExitCode
	ShowMessages(Time & ": " & ML("Application finished. Returned code") & ": " & Result & " - " & Err2Description(Result))
	ChangeEnabledDebug True, False, False
	#ifndef __USE_GTK__
		If CurrentTimer <> 0 Then KillTimer 0, CurrentTimer
		CurrentTimer = 0
	#endif
	'but_enable()
	'menu_enable()
	'shortcut_enable()
	
	#ifdef __FB_WIN32__
		MsgBox(ML("END OF DEBUGGED PROCESS"), App.Title)
		MutexUnlock blocker
		MutexLock blocker
	#else
		MsgBox(ML("END OF DEBUGGED PROCESS") + " " + ML("afterkilled code=") + Str(afterkilled), App.Title)
		Select case As Const afterkilled
		case KDONOTHING
			Exit Sub
		case KENDALL
			close_all()
		case KRESTART To KRESTART9
			restart_exe(afterkilled-KRESTART)
		case Else
			MsgBox("", "Afterkilled not handled")
		End Select
		afterkilled=KDONOTHING
	#endif
End Sub

Private Function kill_process(text As String) As Integer
	Dim As Long retcode,lasterr
	If prun Then ''debuggee waiting or running
		If MsgBox(ML("Kill current running Program?") & text + Chr(10)+Chr(10) + _
			ML("USE CARREFULLY SYSTEM CAN BECOME UNSTABLE, LOSS OF DATA, MEMORY LEAK")+Chr(10)+ _
			ML("Try to close your program first"), , mtWarning, btYesNo) = mrYes Then
			flagkill=True
			#ifdef __FB_WIN32__
				retcode=TerminateProcess(dbghand,999)
				lasterr=GetLastError
				#ifdef fulldbg_prt
					dbg_prt ("return code terminate process ="+Str(retcode)+" lasterror="+GetErrorString(lasterr))
				#endif
				Dim As WString Ptr CurrentDebugger = IIf(tbt32Bit->Checked, CurrentDebugger32, CurrentDebugger64)
				If *CurrentDebugger = ML("Integrated IDE Debugger") Then
					thread_rsm()
				End If
				While prun:Sleep 500:Wend
			#else
				'dbg_prt2 "Killing process=";pid
				If runtype=RTSTEP Then ''waiting
					MutexLock blocker
					msgcmd=KPT_KILL
					bool2=True
					CondSignal(condid)
					While bool1<>True
						CondWait(condid,blocker)
					Wend
					bool1=False
					MutexUnlock blocker
				Else ''running
					linux_kill(thread(0).id,9)
				End If
				'dbg_prt2"end of cmd exit"
			#endif
			Return True
		Else
			Return False
		End If
	Else
		Return True
	End If
End Function

'======================================================================
''extracts the file name from full name
'======================================================================
Private Function source_name(fullname As String)As String
	Dim As Integer cpos=InStrRev(fullname,Any "/\")
	Return Mid(fullname,cpos+1)
End Function

'==========================================

' for proc_find / thread
Const KFIRST=1
Const KLAST=2
' when select a var for proc/var or set watched
Const PROCVAR=1
Const WATCHED=2
'for dissassembly
'Const KLINE=1
'Const KPROC=2
Const KPROG=3
'Const KSPROC=3

Private Function proc_find(thid As Integer,t As Byte) As Integer 'find first/last proc for thread
	If t=KFIRST Then
		For i As Integer =1 To procrnb
			If procr(i).thid = thid Then Return i
		Next
	Else
		For i As Integer = procrnb To 1 Step -1
			If procr(i).thid = thid Then Return i
		Next
	End If
End Function

Private Sub thread_text(th As Integer=-1)'update text of thread(s)
	Dim libel As String
	Dim As Integer thid,p,lo,hi
	If th=-1 Then
		lo=0:hi=threadnb
	Else
		lo=th:hi=th
	End If
	For i As Integer=lo To hi
		thid=thread(i).id
		p=proc_find(thid,KLAST)
		Select Case thread(i).sts
		Case KTHD_RUN
			libel="R> "
		Case KTHD_STOP
			libel="S> "
		Case KTHD_BLKD
			libel="B> "
		Case KTHD_IDLE
			libel="I> "
		Case Else
			libel="?> "
		End Select
		libel += "threadID=" + fmt2(Str(thid), 4) + " : " + proc(procr(p).idx).nm
		If flagverbose Then libel+=" HD: "+Str(thread(i).hd)
		If threadhs=thread(i).hd Then libel+=" (next execution)"
		Tree_upditem(thread(i).tv,libel,tviewthd)
		'ExpandTreeViewItem(GTVIEWTHD , thread(i).tv, 1)
	Next
End Sub

Private Sub brkv_set(a As Integer) 'breakon variable
	Dim As Integer t,p
	Dim Title As String, j As UInteger, ztxt As WString * 301
	If a=0 Then 'cancel break
		brkv.adr=0
		'setWindowText(brkvhnd,"Break on var")
		'menu_chg(menuvar,idvarbrk,"Break on var")
		Exit Sub
	ElseIf a=1 Then 'new
		If var_find2(tviewvar)=-1 Then Exit Sub 'search index variable under cursor
		'search master variable
		
		t=varfind.ty
		p=varfind.pt
		
		#ifdef __FB_64BIT__ ''2017/12/14
			If p Then t=9 ''pointer integer64 (ulongint)
		#else
			If p Then t=1 ''pointer integer32 (long)
		#endif
		'If p Then t=8
		If t>8 AndAlso p=0 AndAlso t<>4 AndAlso t<>13 AndAlso t<>14 Then
			MsgBox(ML("Break on var selection error: Only [unsigned] Byte, Short, integer or z/f/string"))
			Exit Sub
		End If
		
		
		brkv2.typ=t           'change in brkv_box if pointed value
		brkv2.adr=varfind.ad   'idem
		brkv2.vst=""          'idem
		brkv2.tst=1           'type of test
		brkv2.ivr=varfind.iv
		' if dyn array store real adr
		If Cast(Integer,vrb(varfind.pr).arr)=-1 Then
			ReadProcessMemory(dbghand,Cast(LPCVOID,vrr(varfind.iv).ini),@brkv2.arr,4,0)
		Else
			brkv2.arr=0
		End If
		
		If vrb(varfind.pr).mem=3 Then
			brkv2.psk=-2 'static
		Else
			For j As UInteger = 1  To procrnb 'find proc to delete watching
				If varfind.iv>=procr(j).vr And varfind.iv<procr(j+1).vr Then brkv2.psk=procr(j).sk:Exit For
			Next
		End If
		#ifdef __FB_WIN32__
			Dim tvi As TVITEM
			tvi.mask       = TVIF_TEXT
			tvi.pszText    = @(ztxt)
			tvi.hItem      = vrr(varfind.iv).tv
			tvi.cchTextMax = 300
			SendMessage(tviewvar, TVM_GETITEM, 0, Cast(LPARAM, @tvi))
		#else
			ztxt = Cast(TreeNode Ptr, vrr(varfind.iv).tv)->Text
		#endif
		'' ??? treat verbose to reduce width ???
		
		ztxt="Stop if  "+ztxt
		
	Else 'update
		brkv2=brkv
		#ifdef __FB_WIN32__
			GetWindowText(brkvhnd,ztxt,150)
		#endif
	End If
	brkv2.txt=Left(ztxt,InStr(ztxt,"<"))+var_sh2(brkv2.typ,brkv2.adr,p)
	
	'fb_MDialog(@brkv_box,"Test for break on value",windmain,283,25,350,50)
	
End Sub

'Type ttrckarr
'	typ    As UByte     ''type or lenght ???
'	memadr As UInteger  ''adress in memory
'	iv     As UInteger  ''vrr index used when deleting proc
'	idx    As Integer   ''array variable index in vrr
'	''bname as string
'End Type
'Const TRCKARRMAX=4 ''2016/07/26
'Dim Shared As ttrckarr trckarr(TRCKARRMAX)

Private Sub array_tracking_remove '2016/07/26
	
	If trckarr(0).idx<>0 Then
		vrr(trckarr(0).idx).arrid=0 ''tracking off
		trckarr(0).idx=0
		'menu_update(IDTRCKARR,"Assign vars to an array")
	End If
	
	For i As Long =0 To 4 ''resetting
		'menu_update(i+IDTRCKIDX0,"Set Variable for index "+Str(i+1))
		trckarr(i).memadr=0
	Next
End Sub

Private Function thread_select(id As Integer =0) As Integer 'find thread index based on cursor or threadid
	Dim text As WString * 100, pr As Integer, thid As Integer
	Dim As Any Ptr hitem, temp
	
	If id =0 Then  'take on cursor
		'get current hitem in tree
		#ifdef __FB_WIN32__
			temp = Cast(HWND, SendMessage(tviewthd, TVM_GETNEXTITEM, TVGN_CARET, 0))
			
			Do 'search thread item
				hitem=temp
				temp = Cast(HWND, SendMessage(tviewcur, TVM_GETNEXTITEM, TVGN_PARENT, Cast(LPARAM, hitem)))
			Loop While temp
			Dim tvi As TVITEM
			tvi.mask       = TVIF_TEXT Or TVIF_STATE
			tvi.hItem      = Cast(HTREEITEM,hitem)
			tvi.pszText    = @(text)
			tvi.cchTextMax = 99
			SendMessage(tviewthd,TVM_GETITEM,0,Cast(LPARAM,@tvi))
			thid = ValInt(Mid(text, 10, 6))
		#else
			'get current hitem in tree
			If tpThreads->IsSelected Then
				
				temp = tvThd.SelectedNode
				Do 'search thread item
					hitem=temp
					temp = Cast(TreeNode Ptr, hitem)->ParentNode
				Loop While temp
				
				text = Cast(TreeNode Ptr, hitem)->Text
				thid=ValInt(Mid(text,13,6))
			Else
				temp = tvVar.SelectedNode
				text = Cast(TreeNode Ptr, temp)->Text
				If Left(text,5)<>"ThID=" Then
					MsgBox("Thread selection", "Select a line with the thread ID")
					Return -1
				Else
					thid=ValInt(Mid(text,6,5))
				End If
			End If
		#endif
	Else
		thid=id
	End If
	For p As Integer =0 To threadnb
		If thid=thread(p).id Then Return p 'find index number
	Next
End Function
Private Sub proc_del(j As Integer,t As Integer=1)
	Dim  As Integer tempo,th
	Dim parent As Any Ptr
	Dim As String text
	' delete procr in treeview
	#ifdef __FB_WIN32__
		If SendMessage(tviewvar,TVM_DELETEITEM,0,Cast(LPARAM,procr(j).tv))=0 Then
			MsgBox(ML("DELETE TREEVIEW ITEM") & ": " & ML("Not ok (not blocking) for proc") & " "+proc(procr(j).idx).nm)
		End If
	#else
		With *Cast(TreeNode Ptr, procr(j).tv)
			If .ParentNode = 0 Then
				tviewvar->Nodes.Remove .Index
			Else
				.ParentNode->Nodes.Remove .Index
			End If
		End With
	#endif
	
	'delete watch
	For i As Integer =0 To WTCHMAX
		'keep the watched var for reusing !!!
		If wtch(i).psk=procr(j).sk Then
			wtch(i).psk=-3
		End If
	Next
	'delete breakvar
	If brkv.psk=procr(j).sk Then brkv_set(0)
	
	'' remove array tracking : either suppressed array or one of the variable used as index 2016/08/10
	If procr(j+1).vr>trckarr(0).idx AndAlso trckarr(0).idx>=procr(j).vr Then
		array_tracking_remove
	Else
		For i As Long =0 To 4
			If trckarr(i).memadr Then
				If procr(j+1).vr>trckarr(i).iv AndAlso trckarr(i).iv>=procr(j).vr Then
					array_tracking_remove
					Exit For
				End If
			End If
		Next
	End If
	
	
	' compress running variables
	tempo = procr(j + 1).vr - procr(j).vr
	vrrnb -= tempo
	For i As Integer = procr(j).vr To vrrnb
		vrr(i)=vrr(i+tempo)
	Next
	
	
	If t=1 Then 'not dll
		th=thread_select(procr(j).thid) 'find thread index
		#ifdef __FB_WIN32__
			parent = Cast(HTREEITEM, SendMessage(tviewthd, TVM_GETNEXTITEM, TVGN_PARENT, Cast(LPARAM, thread(th).ptv))) 'find parent of last proc item
			SendMessage(tviewthd,TVM_DELETEITEM,0,Cast(LPARAM,thread(th).ptv)) 'delete item
		#else
			parent = Cast(TreeNode Ptr, thread(th).ptv)->ParentNode 'find parent of last proc item
			With *Cast(TreeNode Ptr, thread(th).ptv)
				If .ParentNode = 0 Then
					tviewthd->Nodes.Remove .Index
				Else
					.ParentNode->Nodes.Remove .Index
				End If
			End With
		#endif
		thread(th).ptv = parent 'parent becomes the last
		thread_text(th) 'update thread text
	End If
	
	' compress procr and update vrr index
	procrnb -= 1
	For i As Integer =j To procrnb
		procr(i)=procr(i+1)
		procr(i).vr-=tempo
	Next
	
End Sub

Private Sub proc_end() '07/12/2015
	Dim As Long limit=-1
	Var thid=thread(threadcur).id
	'find the limit for deleting proc (see blow different cases)
	For j As Long =procrnb To 1 Step -1
		If procr(j).thid =thid  Then
			If limit=-1 Then limit=j
			If procr(j).idx=procsv Then
				If j <> limit Then limit = j + 1
				Exit For
			End If
		End If
	Next
	''delete all elements (treeview, varr, ) until the limit
	For j As Long =procrnb To Max(0, limit) Step -1
		If procr(j).thid = thid Then
			proc_del(j)
		End If
	Next
	
	'' The removing of procs is done after the end is eached AND when a next line is executed. It could be a simple line or a call to a new proc.
	'' in this last case it's a bit complicated.
	
	'10/07/2015 handle case multiple returns in a recursive proc, breakcpu not restored between each execution....
	'see example below, the first test data would not be deleted
	'function test(a As integer) As integer
	'	If a=2 Then
	'		Return test(1)
	'	EndIf
	'End function
	'test(2)
	
	''4 cases :
	'' index    1         2            3                       also 3       limit
	''normal   main --> mysub                                               >> 2
	''recursif main --> test -->      test                                     2
	''         main --> mysub --> constructor then immediatly destructor       3
	''         main --> destructor then immediatly       same destructor       3
	
End Sub

Dim Shared fasttimer As Double

'Dim Shared richedit(MAXSRC) As HWND    'one for each tab
Dim Shared clrrichedit As Integer=&hFFFFFF    'background color
Dim Shared clrcurline As Integer=&hFF0000    'current line color, default blue
Dim Shared clrkeyword As Integer=&hFF8040       'keyword color (highlight), default
Dim Shared clrtmpbrk As Integer=&h04A0FB    'current line color, default orange
Dim Shared clrperbrk As Integer=&hFF 'permanent breakpoint default red (used also when access violation)

Private Sub watch_del(i As Integer=WTCHALL)
	Dim As Integer bg,ed
	
	If i=WTCHALL Then
		bg=0:ed=WTCHMAX
	Else
		bg=i:ed=i
	End If
	For j As Integer=bg To ed
		If wtch(j).psk=-1 Then Continue For
		wtch(j).psk=-1
		wtch(j).old=""
		wtch(j).tad=0
		wtchcpt-=1
		'If wtchcpt=0 Then menu_enable
		#ifdef __FB_WIN32__
			If j <= WTCHMAIN Then SetWindowText(wtch(j).hnd, "Watch " + Str(j + 1))
			SendMessage(tviewwch, TVM_DELETEITEM, 0, Cast(LPARAM, wtch(j).tvl))
		#else
			With *Cast(TreeNode Ptr, wtch(j).tvl)
				If .ParentNode = 0 Then
					tviewwch->Nodes.Remove .Index
				Else
					.ParentNode->Nodes.Remove .Index
				End If
			End With
		#endif
	Next
End Sub
Private Sub watch_array()
	'compute watch for dyn array
	Dim As UInteger adr,temp2,temp3
	For k As Integer = 0 To WTCHMAX
		If wtch(k).psk=-1 OrElse wtch(k).psk=-3 OrElse wtch(k).psk=-4 Then Continue For
		If wtch(k).arr Then 'watching dyn array element ?
			adr=vrr(wtch(k).ivr).ini
			ReadProcessMemory(dbghand,Cast(LPCVOID,adr),@adr,SizeOf(Integer),0) '25/07/2015
			If adr<>wtch(k).arr Then wtch(k).adr+=wtch(k).arr-adr:wtch(k).arr=adr 'compute delta then add it if needed
			temp2=vrr(wtch(k).ivr).ini+2*SizeOf(Integer) 'adr global size '25/07/2015
			ReadProcessMemory(dbghand,Cast(LPCVOID,temp2),@temp3,SizeOf(Integer),0) '25/072015
			If wtch(k).adr>adr+temp3 Then 'out of limit ?
				watch_del(k) ' then erase
			End If
		End If
	Next
End Sub

Private Sub update_address(midx As Long) ''to propagate address dynamaic array or after changing index  or erase 22/07/2014
	Dim As Any Ptr child
	Dim As Integer arradr=vrr(midx).ad
	
	#ifdef __FB_WIN32__
		child = Cast(HTREEITEM, SendMessage(tviewvar, TVM_GETNEXTITEM, TVGN_CHILD, Cast(LPARAM, vrr(midx).tv))) 'first child (at least one as it's an udt)
	#else
		If Cast(TreeNode Ptr, vrr(midx).tv)->Nodes.Count Then
			child = Cast(TreeNode Ptr, vrr(midx).tv)->Nodes.Item(0)
		End If
		Dim As Integer ChildNumber
	#endif
	
	For i As Long = midx+1 To vrrnb
		If vrr(i).tv=child Then ''only done with direct child not with the childs of a child
			If arradr=0 Then ''case array erased
				vrr(i).ini=0
				vrr(i).ad=0
			Else
				vrr(i).ad=vrr(i).gofs+arradr
				If Cast(Integer,cudt(Abs(vrr(i).vr)).arr) Then
					vrr(i).ini=vrr(i).ad
					''vrr(i).ad=0
				End If
			End If
			#ifdef __FB_WIN32__
				child = Cast(HTREEITEM, SendMessage(tviewvar, TVM_GETNEXTITEM, TVGN_NEXT, Cast(LPARAM, child)))
			#else
				child = 0
				If ChildNumber < Cast(TreeNode Ptr, vrr(midx).tv)->Nodes.Count Then
					child = Cast(TreeNode Ptr, vrr(midx).tv)->Nodes.Item(ChildNumber)
				End If
				ChildNumber += 1
			#endif
			If child=0 Then Exit For ''no more child
		End If
	Next
End Sub

Private Function var_sh1(i As Integer) As String '23/04/2014
	Dim adr As Integer,text As String,soffset As String
	Dim As Integer temp1,temp2,temp3,vlbound(4),vubound(4)
	Dim As tarr Ptr arradr
	Dim As Long vflong,udtlg,nbdim,typ
	If vrr(i).vr < 0 Then ''field
		text=cudt(Abs(vrr(i).vr)).nm+" "
		arradr=cudt(Abs(vrr(i).vr)).arr
		udtlg=udt(cudt(Abs(vrr(i).vr)).typ).lg
		If Cast(Integer,cudt(Abs(vrr(i).vr)).arr)>0 Then nbdim=cudt(Abs(vrr(i).vr)).arr->dm-1 ''only used in case of fixed-lenght array
		typ = cudt(Abs(vrr(i).vr)).typ
	Else
		text=vrb(vrr(i).vr).nm+" "
		arradr=vrb(vrr(i).vr).arr
		udtlg=udt(vrb(vrr(i).vr).typ).lg
		If Cast(Integer,vrb(vrr(i).vr).arr)>0 Then nbdim=vrb(vrr(i).vr).arr->dm-1 ''only used in case of fixed-lenght array
		typ = vrb(vrr(i).vr).typ
	End If
	If arradr Then ''fixed lenght or dynamic array
		If Cast(Integer, arradr)=-1 Then ''dynamic
			If vrr(i).ini Then 'initialized so it's possible to get data, otherwise adr=0 only usefull for cudt array, var always true
				adr=vrr(i).ini+SizeOf(Integer)  'ptr not data
				ReadProcessMemory(dbghand,Cast(LPCVOID,adr),@adr,SizeOf(Integer),0)
			End If
			If adr Then 'sized ?
				text+="[ Dyn "
				temp2=vrr(i).ini+4*SizeOf(Integer) ''adr nb dim
				ReadProcessMemory(dbghand,Cast(LPCVOID,temp2),@temp3,SizeOf(Integer),0)
				
				temp3-=1
				For k As Integer =0 To temp3
					If vrr(i).arrid Then ''array tracked ?
						''Read the value need to be done here as the value could not be retrieved too late after the display of the array
						If trckarr(k).memadr<>0 Then
							Dim As String libel=var_sh2(trckarr(k).typ,trckarr(k).memadr,0,"")
							vflong=ValInt(Mid(libel,InStr(libel,"=")+1))
							vrr(i).ix(k)=vflong
						End If
					End If
					
					temp2+=2*SizeOf(Integer) ' 'lbound
					ReadProcessMemory(dbghand,Cast(LPCVOID,temp2),@temp1,SizeOf(Integer),0)
					If vrr(i).ad=0 Then 'init index lbound
						vrr(i).ix(k)=temp1
					Else
						If vrr(i).ix(k)<temp1 Then vrr(i).ix(k)=temp1 'index can't be <lbound
					End If
					text+=Str(temp1)+"-"
					vlbound(k)=temp1
					
					temp2+=SizeOf(Integer)' 'ubound
					ReadProcessMemory(dbghand,Cast(LPCVOID,temp2),@temp1,SizeOf(Integer),0)
					If vrr(i).ix(k)>temp1 Then vrr(i).ix(k)=temp1 'index can't be >ubound
					text+=Str(temp1)+":"+Str(vrr(i).ix(k))+" "
					vubound(k)=temp1
					
				Next
				text+="]"
				''calculate the new adress for the array value depending on the new indexes, LIMIT 5 DIMS
				temp1=0:temp2=1
				For k As Integer = temp3 To 0 Step -1
					temp1+=(vrr(i).ix(k)-vlbound(k))*temp2
					temp2*=(vubound(k)-vlbound(k)+1)
				Next
				
				vrr(i).ad=adr+temp1*udtlg
				If typ>TYPESTD Then update_address(i) 'update new address of udt components
				
			Else
				text+="[ Dyn array not defined]"
				If vrr(i).ad<>0 Then vrr(i).ad=0:update_address(i) 'weird case erase array() so defined then not defined..... not sure for cudt
			End If
		Else '' fixed lenght array
			text+="[ "
			For k As Integer =0 To nbdim
				vubound(k)=arradr->nlu(k).ub
				vlbound(k)=arradr->nlu(k).lb
				If vrr(i).arrid Then ''array tracked ?
					''Read the value need to be done here as the value could not be retrieved too late after the display of the array
					If trckarr(k).memadr<>0 Then
						Dim As String libel=var_sh2(trckarr(k).typ,trckarr(k).memadr,0,"")
						vflong=ValInt(Mid(libel,InStr(libel,"=")+1))
						
						''Check If the value Is inside the bounds, If Not the Case set LBound/UBound
						If vflong>vubound(k) Then
							vrr(i).ix(k)=vubound(k)
						Else
							If vflong<vlbound(k) Then
								vrr(i).ix(k)=vlbound(k)
							Else
								vrr(i).ix(k)=vflong
							End If
						End If
					End If
				End If
				text+=Str(vlbound(k))+"-"+Str(vubound(k))+":"+Str(vrr(i).ix(k))+" "
			Next
			text+="]"
			
			''calculate the new adress for the array value depending on the new indexes, LIMIT 5 DIMS
			temp1=0:temp2=1
			For k As Integer = nbdim To 0 Step -1
				temp1+=(vrr(i).ix(k)-vlbound(k))*temp2
				temp2*=(vubound(k)-vlbound(k)+1)
			Next
			vrr(i).ad=vrr(i).ini+temp1*udtlg
			If typ > TYPESTD Then update_address(i) ''udt case
		End If
	End If
	
	
	If vrr(i).vr<0 Then ''field
		With cudt(Abs(vrr(i).vr))
			If .typ=TYPEMAX Then 'bitfield
				text+="<BITF"+var_sh2(2,vrr(i).ad,.pt,Str(.ofs)+" / ")
				temp1=ValInt(Right(text,1)) 'byte value
				temp1=temp1 Shr .ofb        'shifts to get the concerned bit on the right
				temp1=temp1 And ((2*.lg)-1) 'clear others bits
				Mid(text,Len(text)) =Str(temp1) 'exchange byte value by bit value
				Mid(text,InStr(text,"<BITF")+5)="IELD"  'exchange 'byte' by IELD
			Else
				soffset=Str(.ofs)+" / "
				If Cast(Integer,.arr)=-1 Then soffset+=Str(vrr(i).ini)+" >> "  '19/05/2014
				text+="<"+var_sh2(.typ,vrr(i).ad,.pt,soffset)
			End If
			Return text
		End With
	Else
		With vrb(vrr(i).vr) ''variable
			adr=vrr(i).ad
			
			Select Case .mem
			Case 1
				'text+="<Local / " 'remove "Local / " as it's not a very usefull information
				text+="<"
				soffset=Str(.adr)+" / " 'offset
			Case 2
				text+="<Shared / "
			Case 3
				text+="<Static / "
			Case 4 'use *adr
				text+="<Byref param / "
				' ini keep the stack adr but not for param array() in this case always dyn so structure
				If Cast(Integer,.arr)<>-1 Then soffset=Str(.adr)+" / "+Str(vrr(i).gofs)+" / " 'to be checked
			Case 5
				text+="<Byval param / "
				soffset=Str(.adr)+" / "
			Case 6
				text+="<Common / "
			End Select
			If Cast(Integer,.arr)=-1 Then soffset+=Str(vrr(i).ini+SizeOf(Integer))+" >> "  '25/07/2015
			text+=var_sh2(.typ,adr,.pt,soffset)
			Return text
		End With
	End If
End Function

#ifdef __FB_WIN32__
	Function get_var_value(VarName As String, LineIndex As Integer) As String
		Dim As Integer nline, lclproc, lclprocr, p, n, i, j, d, l, idx = -1
		Dim text As ZString * 200
		nline = LineIndex 'sendmessage(dbgrichedit,EM_EXLINEFROMCHAR,0,-1)
		text = UCase(VarName)
		If text="" Or Left(text, 1) = "." Then
			Return ""
		End If
		
		'parsing
		Dim vname(10) As String, varray As Integer, vnb As Integer = 0
		text += ".": l = Len(text): d = 1
		While d < l
			vnb += 1
			p = InStr(d, text, ".")
			vname(vnb) = Mid(text, d, p - d)
			If Right(vname(vnb), 1) = "(" Then
				varray = 1: vname(vnb) = Mid(text, d, p - d -1): d = p + 2 'array
			Else
				varray = 0: d = p + 1
			End If
		Wend
		
		nline += 1 'in source 1 to n <> inside richedit 0 to n-1
		lclproc = 0
		For i As Integer = 1 To linenb
			If rline(i).nu = nline AndAlso rline(i).sx = shwtab Then 'is executable (known) line ?
				lclproc = rline(i).px: Exit For ' with known line we know also the proc...
			End If
		Next
		
		'search inside
		'if no lclproc --> should be in main
		If lclproc Then
			For i As Integer = procrnb To 1 Step -1
				If procr(i).idx = lclproc Then lclprocr = i: Exit For ' proc running
			Next
			
			'search the variable taking in account name and array or not
			
			If lclprocr Then idx = var_search(lclprocr, vname(), vnb, varray) 'inside proc ?
		End If
		If idx = -1 Then
			idx = var_search(1, vname(), vnb, varray) 'inside main ?
			'=========== mod begin ================
			If idx = -1 Then '18/01/2015
				'namespace ?
				If vnb > 1 Then
					vname(1) += "." + vname(2)
					vnb-=1
					For i As Long = 2 To vnb
						vname(i) = vname(i+1)
					Next
					idx = var_search(1, vname(), vnb, varray)
				End If
				If idx = -1 Then Return ""
			End If
		End If
		'============== end of mod ==============
		Return var_sh1(idx)
		
	End Function
	
	Sub UpdateItems(root As HTREEITEM)
		Dim As HTREEITEM node = root
		While node <> NULL
			Dim tvi As TVITEM
			tvi.mask = TVIF_PARAM Or TVIF_STATE
			tvi.hItem = node
			TreeView_GetItem(tviewvar, @tvi)
			If tvi.lParam <> 0 Then Tree_upditem(node, var_sh1(tvi.lParam), tviewvar)
			If tvi.state = 96 OrElse tvi.state = 98 Then UpdateItems(TreeView_GetNextItem(tviewvar, node, TVGN_CHILD))
			node = TreeView_GetNextItem(tviewvar, node, TVGN_NEXT)
		Wend
	End Sub
#endif

Private Sub var_sh() 'show master var
	#ifdef __FB_WIN32__
		UpdateItems(TreeView_GetNextItem(tviewvar, NULL, TVGN_ROOT))
	#else
		For i As Integer = 1 To vrrnb
			Tree_upditem(vrr(i).tv, var_sh1(i), tviewvar)
		Next
	#endif
	watch_array()
	watch_sh
End Sub
'============================================
'' splits a string in parts of 2 characters
'============================================
Private Function split_hex(strg As String)As String
	Dim As String temp=Left(strg,2)
	If Len(strg)=2 Then Return temp
	For i As Integer=1 To Len(strg)\2-1
		temp+=" "+Mid(strg,i*2+1,2)
	Next
	Return temp
End Function
'======================================
'' displays updated dumpmem
'======================================
Private Sub dump_sh()
	Dim As String tmp
	Dim buf(16) As UByte,r As Integer,ad As Integer
	Dim ascii As String
	Dim ptrs As pointeurs
	If dumpnbcol=0 Then Exit Sub
	lvMemory.ListItems.Clear ''delete all items
	ad=dumpadr
	For jline As Integer =0 To dumplines-1
		If dumpadrbase=1 Then
			lvMemory.ListItems.Add Str(ad), , , , jline
			'AddListViewItem(GDUMPMEM,Str(ad),0,jline,0) ''adress
		Else
			lvMemory.ListItems.Add Hex(ad), , , , jline
			'AddListViewItem(GDUMPMEM,Hex(ad),0,jline,0) ''adress
		End If
		ReadProcessMemory(dbghand,Cast(LPCVOID,ad),@buf(0),16,@r)
		#ifdef __FB_WIN32__
			ad+=r
		#else
			ad+=16
		#endif
		ptrs.pxxx=@buf(0)
		For icol As Integer =1 To dumpnbcol
		  Select Case dumptyp+dumpbase
			 Case 2,16,66 'byte/dec/sng - boolean hex or dec
				tmp=Str(*ptrs.pbyte)
				ptrs.pbyte+=1
			 Case 3 'byte/dec/usng
				tmp=Str(*ptrs.pubyte)
				ptrs.pubyte+=1
			 Case 5 'short/dec/sng
				tmp=Str(*ptrs.pshort)
				ptrs.pshort+=1
			 Case 6 'short/dec/usng
				tmp=Str(*ptrs.pushort)
				ptrs.pushort+=1
			 Case 1 'integer/dec/sng
				tmp=Str(*ptrs.pinteger)
				ptrs.pinteger+=1
			 Case 7,8 'integer/dec/usng
				tmp=Str(*ptrs.puinteger)
				ptrs.puinteger+=1
			 Case 9 'longinteger/dec/sng
				tmp=Str(*ptrs.plongint)
				ptrs.plongint+=1
			 Case 10 'longinteger/dec/usng
				tmp=Str(*ptrs.pulongint)
				ptrs.pulongint+=1
			 Case 11 'single
				tmp=Str(*ptrs.psingle)
				ptrs.psingle+=1
			 Case 12 'double
				tmp=Str(*ptrs.pdouble)
				ptrs.pdouble+=1
			 Case 52,53 'byte/hex
				tmp=split_hex(Right("0"+Hex(*ptrs.pbyte),2))
				ptrs.pbyte+=1
			 Case 55,56 'short/hex
				tmp=split_hex(Right("000"+Hex(*ptrs.pshort),4))
				ptrs.pshort+=1
			 Case 51,58,61 'integer/hex
				tmp=split_hex(Right("0000000"+Hex(*ptrs.pinteger),8))
				ptrs.pinteger+=1
			Case 59,60,62 'longinteger/hex
				tmp=split_hex(Right("000000000000000"+Hex(*ptrs.plongint),16))
				ptrs.pulongint+=1
		  End Select
		  lvMemory.ListItems.Item(jline)->Text(icol) = tmp
		  
		  'AddListViewItem(GDUMPMEM,tmp,0,jline,icol)
		Next
		ascii=""
		#ifdef __FB_LINUX__
			For ibuf As Integer=1 To 16
				ascii+=Chr(buf(ibuf-1))
			Next

			If g_utf8_validate(StrPtr(ascii),-1,0)<>True Then
				For ibuf As Integer=0 To 15
					If ascii[ibuf]<32 Or ascii[ibuf]>126 Then
						ascii[ibuf]=Asc(".")
					EndIf
				Next
			EndIf
		#else
			For ibuf As Integer=1 To 16
				If buf(ibuf-1)<32 OrElse (flagascii=1 And buf(ibuf-1)>126) Then
					ascii+="."
				Else
					ascii+=Chr(buf(ibuf-1))
				End If
			Next
		#endif
		lvMemory.ListItems.Item(jline)->Text(dumpnbcol + 1) = ascii
		'AddListViewItem(GDUMPMEM,ascii,0,jline,dumpnbcol+1)
	Next
End Sub

Private Function proc_retval(prcnb As Integer) As String
	Dim p As Integer = proc(prcnb).pt
	If p Then
		If p>220 Then
			Return String(p-220,Str("*"))+" Function"
		ElseIf p>200 Then
			Return String(p-200,Str("*"))+" Sub"
		Else
			Return String(p,Str("*"))+" "+udt(proc(prcnb).rv).nm
		End If
	End If
	Return udt(proc(prcnb).rv).nm
End Function
'====================================================================
'' locates a proc in sources from selected line in current treeview
'====================================================================
Private Sub proc_loc()
	Dim As Any Ptr hitem, htemp
	Dim As Integer temp, th
	'get current hitem in tree
	Select Case tabBottom.SelectedTab
		Case tpLocals
			htemp = tvVar.SelectedNode
			Do 'search index proc
				hitem = htemp
				If hitem Then htemp = Cast(TreeNode Ptr, hitem)->Parent
			Loop While htemp
			temp=0
			For i As Integer =1 To procrnb
				If procr(i).tv=hitem Then
					temp=procr(i).idx
				 Exit For
				EndIf
			Next
			If temp=0 Then
				MsgBox("Global variables no proc associated !!", "Locate proc")
				Exit Sub
			EndIf

		Case tpProcedures
			htemp = tvPrc.SelectedNode
			hitem = htemp
			For i As Integer =1 To procnb
				If proc(i).tv=hitem Then
					temp=i
				 Exit For
				EndIf
			Next
		Case Else
			th = thread_select()
			If th=0 Then ''main, select first line
				temp=procr(1).idx
			Else
				temp=procr(proc_find(thread(th).id,KFIRST)).idx
			EndIf
	End Select

	If proc(temp).nu=-1 Then
		MsgBox("Not possible perhaps add by compiler (ie default constructor, let, etc)", "Locate proc")
		Exit Sub
	EndIf

	source_change(proc(temp).sr) ''display source
	line_display(proc(temp).nu,1)  ''Select Line
End Sub
'===============================================================
'' calling line
'===============================================================
Private Sub proc_loccall()
	'Dim As Integer hitem,temp
	'temp = tvVar.SelectedNode
'
	'If temp=procr(1).tv Then
	'		MsgBox("      Main so no call !!", "Locate calling line")
	'	Exit Sub
	'EndIf
'
	'Do 'search index proc
	'	hitem=temp
	'	temp=GetParentItemTreeView(GTVIEWVAR,hitem)
	'Loop While temp
'
	'For i As Integer =1 To procrnb
	'	If procr(i).tv=hitem Then
	'		If procr(i).cl=-1 Then
	'			'fb_message("Locate calling line","First proc of thread so no call !!"):Exit Sub
	'			thread_execline(2):Exit Sub
	'		EndIf
	'		temp=procr(i).cl 'calling line
	'		source_change(rline(temp).sx) ''display source
	'		line_display(rline(temp).nu,1)'Select Line
	'		Exit Sub
 ' 		EndIf
	'Next
	'MsgBox("Impossible to find with Global shared", "Locate calling line")
End Sub
'=================================================================================================
'' changes the status of the procedure enabled / disabled = doesn't be handled in running proc
'=================================================================================================
Private Sub proc_enable() ''enab=true-> enabled / false -> disabled

	Dim As Integer prc
	Dim As String text
	Var item = tvPrc.SelectedNode
	'var item=getitemtree(GTVIEWPRC)
	If item=0 Then
		Exit Sub
	EndIf
    Do
        prc+=1
    Loop While proc(prc).tv<>item Or prc>procnb

    If proc(prc).enab=True Then
    	If proc_verif(prc) Then
			MsgBox("Proc " + proc(prc).nm + " is running", "Can't be disabled")
    	Else
			proc(prc).enab=False
			text = Cast(TreeNode Ptr, proc(prc).tv)->Text
			text[InStr(text,"<E>")]=Asc("D")
			Cast(TreeNode Ptr, proc(prc).tv)->Text = text
			For i As Integer =1 To linenb
				If rline(i).px=prc Then
					WriteProcessMemory(dbghand,Cast(LPVOID,rline(i).ad),@rline(i).sv,1,0)
				EndIf
			Next
        End If
    Else
		If MsgBox("Enable Proc " + proc(prc).nm, "If running --> big problem", , btYesNo) = mrYes Then
			proc(prc).enab=True
			For i As Integer =1 To linenb
				If rline(i).px=prc Then
					WriteProcessMemory(dbghand,Cast(LPVOID,rline(i).ad),@breakcpu,1,0)
				End If
			Next
			text = Cast(TreeNode Ptr, proc(prc).tv)->Text
			text[InStr(text,"<D>")]=Asc("E")
			Cast(TreeNode Ptr, proc(prc).tv)->Text = text
		End If
    End If
End Sub
'===========================================================
Private Sub proc_sh()
	Dim libel As String
	Dim As Integer listidx
	tvPrc.Nodes.Clear
	
	If procsort = KMODULE Then 'sorted by module
		MsgBox("feature not coded", "sort by module for procs so forcing by name")
		procsort = KPROCNM
	End If
	
	'Dim tvi As TVITEM
	'SendMessage(tviewprc,TVM_DELETEITEM,0,Cast(LPARAM,TVI_ROOT)) 'zone proc
	'tvi.mask      = TVIF_STATE
	'tvi.stateMask = TVIS_STATEIMAGEMASK
	'For j As Integer =1 To procnb
	'	With proc(j)
	'		If procsort=KMODULE Then 'sorted by module
	'			libel=name_extract(source(.sr))+">> "+.nm+":"+proc_retval(j)
	'		Else 'sorted by proc name
	'			libel=.nm+":"+proc_retval(j)+"   << "+name_extract(source(.sr))
	'		End If
	'		If flagverbose Then libel+=" ["+Str(.db)+"]"
	'		.tv=Tree_AddItem(NULL,libel, 0, tviewprc, 0)
	'		tvi.hItem= .tv
	'		tvi.state= INDEXTOSTATEIMAGEMASK(.st)
	'		SendMessage(tviewprc,TVM_SETITEM,0,Cast(LPARAM,@tvi))
	'	End With
	'Next
	'SendMessage(tviewprc,TVM_SORTCHILDREN ,0,0) 'Activate to sort elements
	listidx=proclistfirst
	While listidx<>-1
		With proc(listidx)
			libel = .nm + ":" + proc_retval(listidx) + "   in : " + source_name(source(.sr))
			If .enab = True Then
				libel += " <E> " '' for indicating if the proc is enabled : followed
			Else
				libel += " <D> " ''disabled
			EndIf

			If flagverbose Then libel+=" ["+Str(.db)+"/"+Hex(.db)+"]"

			.tv = tvPrc.Nodes.Add(libel) 'AddTreeViewItem(GTVIEWPRC,libel,Cast (HICON, 0),0,TVI_LAST,0)
			listidx = proclist(listidx).child
		End With
	Wend
	
End Sub

'focus box
Dim Shared focusbx   As Any Ptr

Private Sub dsp_change(index As Integer)
	Dim As Integer icurold,icurlig,curold,decal,clrold,clrcur
	Dim ntab As Integer = rline(index).sx
	'Var tb = AddTab(source(ntab))
	fntab = ntab
	'''unicode 10/05/2015
	'Dim As GETTEXTEX gtx
	'Dim As WString *104 wstrg
	'Clear *@wstrg,0,200+2
	'gtx.cb=200
	'gtx.flags=GT_SELECTION
	'gtx.codepage=1200
	'gtx.lpDefaultChar=0
	'gtx.lpUsedDefChar=0
	''
	curold=curlig
	curlig=rline(index).nu
	fcurlig = curlig
	icurold=False :icurlig=False
	For i As Integer =1 To brknb
		If brkol(i).nline=curold And brkol(i).isrc=shwtab Then
			icurold=True
			If brkol(i).typ=1 Then
				clrold=clrperbrk
			ElseIf brkol(i).typ=2 Then
				clrold=clrtmpbrk
			Else
				clrold=&hB0B0B0
			End If
		End If
		If brkol(i).nline=curlig And brkol(i).isrc=ntab Then
			icurlig=True
			If brkol(i).typ=1 Then
				clrcur=clrperbrk Xor clrcurline
			ElseIf brkol(i).typ=2 Then
				clrcur=clrtmpbrk Xor clrcurline
			Else
				clrcur=&hB0B0B0 Xor clrcurline
			End If
		End If
	Next
	If icurold Then
		'sel_line(curold-1,clrold,2,richedit(curtab),FALSE) 'restore breakpoint red
	Else
		'sel_line(curold-1,0,1,richedit(curtab),FALSE) 'default color
	End If
	'If ntab<>shwtab Then exrichedit(ntab)
	curtab=shwtab
	If icurlig Then
		'sel_line(curlig-1,clrcur,2) 'current line + brk purple
	Else
		'sel_line(curlig-1,clrcurline,2) 'current line in blue
	End If
	'tb->txtCode.CurExecutedLine = curlig
	'tb->txtCode.SetSelection curlig, curlig, 0, 0
	'App.DoEvents
	'??? sendmessage(dbgrichedit ,WM_HSCROLL,SB_PAGELEFT,0)
	rlineold = index
	''10/05/2015
	'sendmessage(dbgrichedit,EM_GETSELTEXT,0,Cast(LPARAM,@l))
	''SetWindowTextW(hcurline,"Current line ["+Str(curlig)+"]:"+LTrim(l,Any " "+Chr(9)))
	''
	'' use of gettextex to unicode
	'SendMessage(dbgrichedit,EM_GETTEXTEX,Cast(WPARAM,@gtx),Cast(LPARAM,@wstrg))
	'SetWindowTextW(hcurline,WStr("Current line ["+Str(curlig)+"]:")+LTrim(wstrg,Any WStr(" "+Chr(9))))
	
	''
	'If flagtrace And 2 Then dbg_prt(LTrim(wstrg,Any WStr(" "+Chr(9))))
	thread_text
	If runtype=RTAUTO Then
		watch_array 'update adr watched dyn array
		watch_sh    'update watched but not all the variables
		'If tviewcur = tviewthd Then thread_text 'update
	ElseIf runtype=RTSTEP Then
		
		var_sh()
		dump_sh()
		'but_enable()
		
		If tviewcur = tviewprc Then
			proc_sh
		'ElseIf tviewcur = tviewthd Then '25/01/2015
		'	thread_text
		End If
		'      If flagfollow=TRUE AndAlso focusbx<>0 Then
		'      	sendmessage(focusbx,UM_FOCUSSRC,0,0)
		'      EndIf
		
		''=== Update select index windows ================== 2016/02/09
		'      For i As Long =0 To INDEXBOXMAX
		'         If hindexbx(i)<>0 Then
		'            If autoupd(i)=TRUE Then SendMessage(hindexbx(i),WM_COMMAND,333,0) ''simulate click on button update 2016/03/16
		'         EndIf
		'      Next
		''==================================================
	End If
End Sub

#ifdef __FB_WIN32__
	Sub exe_mod() 'execution from cursor
		Dim l As Integer,i As Integer, b As Integer
		'Dim range As CHARRANGE
		Dim vcontext As CONTEXT
		Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb = 0 Then Exit Sub
		'range.cpmin=-1 :range.cpmax=0
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		'sendmessage(dbgrichedit,EM_exsetsel,0,Cast(LPARAM,@range)) 'deselect
		l = iSelEndLine 'sendmessage(dbgrichedit,EM_EXLINEFROMCHAR,0,-1) 'get line
		
		For i=1 To linenb  'check nline
			If rline(i).nu=l+1 And rline(i).sx=shwtab Then
				If rline(i+1).nu=l+1 And rline(i+1).sx=shwtab Then i+=1 'weird case : first line main proc
				Exit For
			End If
		Next
		
		If i>linenb Then MsgBox(ML("Execution on cursor: Inaccessible line (not executable)")) :Exit Sub
		
		If curlig=l+1 And shwtab=curtab Then
			If MsgBox(ML("Execution on cursor: Same line, continue?"),,mtQuestion, btYesNo) = mrNo Then Exit Sub
		End If
		
		'check inside same proc if not msg
		If rline(i).ad>proc(procsv).fn Or rline(i).ad<=proc(procsv).db Then
			MsgBox(ML("Execution on cursor: Only inside current proc!")) :Exit Sub
		End If
		If rline(i).ad=proc(procsv).fn Then
			thread(threadcur).pe=True        'is last instruction
		End If
		'WriteProcessMemory(dbghand,Cast(LPVOID,rLine(thread(threadcur).sv).ad),@breakcpu,1,0) 'restore CC previous line
		'WriteProcessMemory(dbghand,Cast(LPVOID,rLine(i).ad),@rLine(i).sv,1,0) 'restore old value for execution
		thread(threadcur).od=thread(threadcur).sv:thread(threadcur).sv=i
		'get and update registers
		vcontext.ContextFlags=CONTEXT_CONTROL
		GetThreadContext(threadhs,@vcontext)
		vcontext.regip=rline(i).ad
		SetThreadContext(threadhs,@vcontext)
		
		dsp_change(i)
	End Sub
#endif
'=========================================
'' returns true if proc running
'=========================================
Private Function proc_verif(p As Integer) As Boolean
	For i As UShort =1 To procrnb
		If procr(i).idx = p Then Return True
	Next
	Return False
End Function

Private Sub proc_watch(procridx As Integer) 'called with running proc index
	Dim As Integer prcidx=procr(procridx).idx,vridx
	
	'If procridx=1 Then 06/02/2014
	'   If flagwtch=0 AndAlso wtchexe(0,0)<>"" Then watch_check(wtchexe(0,0))
	'   flagwtch=0
	'EndIf
	If wtchcpt=0 Then Exit Sub
	For i As Integer= 0 To WTCHMAX
		If wtch(i).psk=-3 Then 'local var
			If wtch(i).idx=prcidx Then
				wtch(i).adr=vrr(procr(procridx).vr+wtch(i).dlt).ad'06/02/2014 wtch(i).dlt+procr(procridx).sk
				wtch(i).psk=procr(procridx).sk
			End If
		ElseIf wtch(i).psk=-4 Then 'session watch
			If wtch(i).idx=prcidx Then
				vridx=var_search(procridx,wtch(i).vnm(),wtch(i).vnb,wtch(i).Var,wtch(i).pnt)
				If vridx=-1 Then MsgBox(ML("Proc watch: Running var not found")):Continue For
				var_fill(vridx)
				watch_add(wtch(i).tad,i)
			End If
		End If
	Next
End Sub
Private Sub proc_new()
	Dim libel As String
	Dim tv As Any Ptr
	If procrnb = PROCRMAX Then MsgBox(ML("CLOSING DEBUGGER: Max number of sub/func reached")): Exit Sub 'DestroyWindow (windmain):
	procrnb+=1'new proc ADD A POSSIBILITY TO INCREASE THIS ARRAY
	procr(procrnb).sk=procsk
	procr(procrnb).thid=thread(threadcur).id
	procr(procrnb).idx=procsv
	
	'test if first proc of thread
	If thread(threadcur).plt=0 Then
		procr(procrnb).cl=-1  ' no real calling line
		libel="ThID="+Str(procr(procrnb).thid)+" "
		tv = 0 'TVI_LAST 'insert in last position
		thread(threadcur).tv= Tree_AddItem(NULL,"Not filled", 0, tviewthd, 0)'create item
		thread(threadcur).ptv=thread(threadcur).tv 'last proc
		thread_text()'put text not only current but all to reset previous thread text
	Else
		procr(procrnb).cl=thread(threadcur).od
		tv=thread(threadcur).plt 'insert after the last item of thread
	End If
	
	'add manage LIST
	libel+=proc(procsv).nm+":"+proc_retval(procsv)
	If flagverbose Then libel+=" ["+Str(proc(procsv).db)+"]"
	
	procr(procrnb).tv=Tree_AddItem(0,libel,tv,tviewvar, 0)
	thread(threadcur).plt=procr(procrnb).tv 'keep handle last item
	
	'add new proc to thread treeview
	#ifdef __FB_WIN32__
		thread(threadcur).ptv=Tree_AddItem(thread(threadcur).ptv,"Proc : "+proc(procsv).nm,TVI_FIRST,tviewthd, 0)
	#else
		thread(threadcur).ptv = Tree_AddItem(thread(threadcur).ptv, "Proc : " + proc(procsv).nm, 0, tviewthd, 0)
	#endif
	thread_text(threadcur)
	'RedrawWindow tviewthd, 0, 0, 1
	var_ini(procrnb,proc(procr(procrnb).idx).vr,proc(procr(procrnb).idx+1).vr-1)
	procr(procrnb+1).vr=vrrnb+1
	If proc(procsv).nm="main" Then
		'procr(procrnb).vr=1 'constructors for shared are executed before main so reset index for first variable of main 04/02/2014
	End If
	proc_watch(procrnb) 'reactivate watched var
	'RedrawWindow tviewvar, 0, 0, 1
End Sub
'=======================================================
'' after stopping run  retrieves all procedures
'=======================================================
Private Sub proc_runnew()
	
	#ifdef __FB_WIN32__
		Dim As Integer dummy
		Dim vcontext As CONTEXT
		
		'if cast(integer,@vcontext) mod 16 <>0 then
		'messbox("PRBM","Context not 16byte aligned")
		'EndIf
		vcontext.ContextFlags=CONTEXT_CONTROL Or CONTEXT_INTEGER
	#endif
	Dim libel As String
	Dim As Integer regbp,regip,regbpnb,regbpp(PROCRMAX),ret(PROCRMAX),retadr
	Dim As ULong j,k,pridx(PROCRMAX)
	Dim tv As Any Ptr
	
	
	
	''loading with rbp/ebp and proc index
	'For ithd As Integer =0 To threadnb
	Var ithd=threadcur ''2022/01/21
	
	dbg_prt2 "in proc run new ithd=";ithd," plt=";thread(ithd).plt,"sv=";thread(ithd).sv
	
	'if thread(ithd).sv=-1 then continue for ''2022/01/21
	regbpnb=0
	#ifdef __FB_WIN32__
		GetThreadContext(thread(ithd).hd, @vcontext)
		regbp=vcontext.regbp
		regip=vcontext.regip 'current proc
	#else
		Var threadprev=threadcur
		threadcur=ithd
		regs.xip=0
		MutexLock blocker
		msgcmd=KPT_GETREGS
		bool2=True
		CondSignal(condid)
		While bool1<>True
			CondWait(condid,blocker)
		Wend
		bool1=False
		MutexUnlock blocker
		threadcur=threadprev
		If regs.xip=0 Then
			'dbg_prt2 "not stopped=";thread(ithd).id
			'continue for ''2022/01/21
		End If
		
		regbp=regs.xbp
		regip=regs.xip
		'dbg_prt2 "in proc new run xip=";hex(regip),hex(regbp)
	#endif
	While 1
		For j =1 To procnb
			If regip>=proc(j).db And regip<=proc(j).fn Then
				regbpnb+=1
				regbpp(regbpnb)=regbp
				ReadProcessMemory(dbghand,Cast(LPCVOID,regbp+SizeOf(Integer)),@regip,SizeOf(Integer),0) 'return EIP/RIP
				ret(regbpnb)=regip
				pridx(regbpnb)=j
				Exit For
			End If
		Next
		If j>procnb Then Exit While
		ReadProcessMemory(dbghand,Cast(LPCVOID,regbp),@regbp,SizeOf(Integer),0) 'previous RBP/EBP
	Wend
	'dbg_prt2 "in proc new run 01 regbpnb=";regbpnb
	''skip still existing procedures or delete them
	For iprc As Integer	=1 To procrnb
		dbg_prt2 "procr(iprc).thid,ithd="; procr(iprc).thid,ithd,thread(ithd).id
		If procr(iprc).thid<>thread(ithd).id Then
			dbg_prt2 "in run new proc not in this thread=";ithd,iprc
			Continue For
		End If
		ReadProcessMemory(dbghand,Cast(LPCVOID,procr(iprc).sk+SizeOf(Integer)),@retadr,SizeOf(Integer),0) ''current value should be return address
		If procr(iprc).ret<>retadr Then
			dbg_prt2 "in run new deleting proc=";iprc
			proc_del(iprc) ''return address not any more valid
		Else
			If procr(iprc).sk=regbpp(regbpnb) And procr(iprc).ret=ret(regbpnb) Then
				regbpnb-=1
			End If
		End If
	Next
	'dbg_prt2 "in proc new run 02 regbpnb=";regbpnb
	''create new procrs
	For k As Integer =regbpnb To 1 Step -1
		If procrnb=PROCRMAX Then
			hard_closing("Max number of sub/func reached")
			Exit Sub
		End If
		If proc(pridx(k)).enab=False Then Continue For 'proc state don't follow
		procrnb+=1
		procr(procrnb).sk=regbpp(k)
		procr(procrnb).thid=thread(ithd).id
		thread(ithd).stack=procr(procrnb).sk
		procr(procrnb).idx=pridx(k)
		
		'test if first proc of thread
		dbg_prt2 "in proc run new 02 ithd=";ithd," plt=";thread(ithd).plt
		If thread(ithd).plt=0 Then
			thread(ithd).tv = Tree_AddItem(0, "test000", 0, tviewthd, 0) ' AddTreeViewItem(GTVIEWTHD,"test000",Cast (HICON, 0),0,TVI_LAST,0)
			thread(ithd).ptv=thread(ithd).tv 'last proc
			thread_text(ithd) 'put text
			thread(ithd).st=0 'with fast no starting line could be gotten
			procr(procrnb).cl=-1  ' no real calling line
			libel="ThID="+Str(procr(procrnb).thid)+" "
			tv=thread(ithd).tv 'insert in last position
			dbg_prt2 "in proc run new=";thread(ithd).tv
			thread_status()
		Else
			tv=thread(ithd).plt 'insert after the last item of thread
			procr(procrnb).ret=ret(k)
			libel=""
			procr(procrnb).cl=line_call(ret(k))
		End If
		'add manage LIST
		If flagtrace Then dbg_prt ("NEW proc "+proc(pridx(k)).nm)
		libel+=proc(pridx(k)).nm+":"+proc_retval(pridx(k))
		If flagverbose Then libel+=" ["+Str(proc(pridx(k)).db)+"]"
		
		'vrr(vrrnb).tv=AddTreeViewItem(GTVIEWVAR,"Not yet filled",cast (hicon, 0),0,TVI_LAST,0)
		procr(procrnb).tv = Tree_AddItem(tv, libel, 0, tviewvar, 0) ' AddTreeViewItem(GTVIEWVAR,libel,Cast (HICON, 0),0,tv,0)
		
		thread(ithd).plt=procr(procrnb).tv 'keep handle last item
		thread(ithd).ptv =  Tree_AddItem(thread(ithd).ptv, proc(pridx(k)).nm, 0, tviewthd, 0) 'AddTreeViewItem(GTVIEWTHD,proc(pridx(k)).nm,Cast (HICON, 0),0,TVI_FIRST,thread(ithd).ptv)
		var_ini(procrnb,proc(procr(procrnb).idx).vr,proc(procr(procrnb).idx+1).vr-1)
		procr(procrnb+1).vr=vrrnb+1
		If proc(procsv).nm="main" Then procr(procrnb).vr=1 'constructors for shared they are executed before main so reset index for first variable of main
		proc_watch(procrnb) 'reactivate watched var
	Next
	
	'Next
End Sub

Private Sub brk_color(brk1 As Integer)
	'	Dim h As hwnd=richedit(brkol(brk).isrc),l As Integer=brkol(brk).nline-1,t As Integer=brkol(brk).typ
	'	Dim colr As Integer,range As charrange,b As Integer
	'    If t Then 'set
	'      If t=1 Then
	'			colr=clrperbrk'permanent breakpoint
	'      ElseIf t=2 Then
	'      	colr=clrtmpbrk'tempo breakpoint
	'      Else
	'      	colr=&hB0B0B0 'disabled
	'      EndIf
	'      If l+1=curlig And brkol(brk).isrc=curtab Then colr=colr Xor clrcurline
	'      sel_line(l,colr,2,h,FALSE) 'purple brk+current
	'    Else 'reset
	'		If l+1=curlig And  brkol(brk).isrc=curtab Then
	'		   sel_line(l,clrcurline,2,h,FALSE) 'blue
	'		Else
	'			b=rlineold:rlineold=brkol(brk).index 'hack to correctly color line
	'		   sel_line(l,0,1,h,FALSE) 'grey
	'		   rlineold=b
	'		End If
	'    End If
	'   b=sendmessage(h,EM_LINEINDEX,-1,0)'char index for line with caret
	'   range.cpmin=b :range.cpmax=b 'caret at begining of line
	'   sendmessage(h,EM_exsetsel,0,Cast(LPARAM,@range))
End Sub

Private Sub brk_del(n As Integer) 'delete one breakpoint
	brkol(n).typ=0
	brkol(n).cntrsav = 0
	brk_color(n)
	brknb-=1
	If n=0 Then ''run
		Exit Sub
	End If
	For i As Integer =n To brknb
		brkol(i)=brkol(i+1)
	Next
	If brknb = 0 Then
		bpbox = False
		'EnableMenuItem(menuedit,IDMNGBRK,MF_GRAYED)
	Else
		If bpbox=True Then
			'hidewindow(hbrkbx,KHIDE)
			brk_manage("Breakpoint management")
		End If
	End If
End Sub

#ifdef __FB_WIN32__
	Sub brk_set(t As Integer)
		Dim l As Integer,i As Integer,range As CHARRANGE,b As Integer,ln As Integer
		range.cpMin=-1 :range.cpMax=0
		Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb = 0 Then Exit Sub
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		'sendmessage(dbgrichedit,EM_exsetsel,0,Cast(LPARAM,@range)) 'deselect
		l = iSelEndLine 'sendmessage(dbgrichedit,EM_EXLINEFROMCHAR,0,-1) 'get line
		
		For i=1 To linenb
			'?rline(i).nu, l+1, proc(rline(i).pr).sr, shwtab
			If rline(i).nu=l+1 And rline(i).sx=shwtab Then Exit For 'check nline
		Next
		If i>linenb Then MsgBox(ML("Break point Not possible: Inaccessible line (not executable)")) :Exit Sub
		For j As Integer =1 To procnb
			If rline(i).ad=proc(j).db Then MsgBox(ML("Break point Not possible: Inaccessible line (not executable)")) :Exit Sub
		Next
		ln=i
		If t=9 Then 'run to cursor
			'l N°line/by 0
			If curlig=l+1 And shwtab=curtab Then
				If MsgBox(ML("Run to cursor: Same line, continue?"),, mtQuestion, btYesNo) = mrNo Then Exit Sub
			End If
			brkol(0).ad=rline(ln).ad
			brkol(0).typ=2 'to clear when reached
			fastrun
		Else
			For i=1 To brknb 'search if still put on this line
				If brkol(i).nline=l+1 And brkol(i).isrc=shwtab Then Exit For
			Next
			If i>brknb Then 'not put
				If brknb=BRKMAX Then MsgBox(ML("Max of brk reached") & " ("+Str(BRKMAX)+"): " & ML("Delete one and retry")): Exit Sub
				brknb+=1
				brkol(brknb).nline=l+1
				brkol(brknb).typ=t
				brkol(brknb).index=ln
				brkol(brknb).isrc=shwtab
				brkol(brknb).ad=rline(ln).ad
				brkol(brknb).cntrsav=0
				brkol(brknb).counter=0
				If t=3 Then 'change value counter
					inputval="0"
					inputtyp=7 'ulong
					'fb_MDialog(@input_box,"Set value counter for a breakpoint",windmain,283,25,120,30)
					brkol(i).counter=ValUInt(inputval)
					brkol(i).cntrsav=brkol(i).counter
					brkol(brknb).typ=1 'forced permanent
				End If
			Else 'still put
				If t=7 Then 'change value counter
					inputval=Str(brkol(i).cntrsav)
					inputtyp=7 'ulong
					'fb_MDialog(@input_box,"Change value counter, remaining= "+Str(brkol(i).counter)+" initial below",windmain,283,25,140,30)
					If inputval="" Then inputval=Str(brkol(i).cntrsav) 'cancel button selected so no value
					brkol(i).counter=ValUInt(inputval)
					brkol(i).cntrsav=brkol(i).counter
				ElseIf t=8 Then 'reset to initial value
					If brkol(i).cntrsav Then
						brkol(i).counter=brkol(i).cntrsav
					Else
						MsgBox(ML("Reset counter: No counter for this breakpoint"))
					End If
				ElseIf t=4 Then 'toggle enabled/disabled 03/09/2015
					If brkol(i).typ>2 Then
						brkol(i).typ-=2
					Else
						brkol(i).typ+=2
					End If
				ElseIf t=brkol(i).typ OrElse brkol(i).typ>2 Then 'cancel breakpoint
					brk_del(i)
					Exit Sub
				Else 'change type of breakpoint
					brkol(i).typ=t
				End If
			End If
			brk_color(i)
			'If brknb=1 Then EnableMenuItem(menuedit,IDMNGBRK,MF_ENABLED)
		End If
	End Sub
	
	Private Function brk_test Overload(ad As UInteger) As Byte 'check on breakpoint ?
		For i As Integer=0 To brknb
			If brkol(i).typ>2 Then Continue For 'disabled
			If ad=brkol(i).ad Then 'reached line = breakpoint
				If brkol(i).counter>0 Then brkol(i).counter-=1:Return False 'decrement counter 02/09/2015
				stopcode=CSBRK
				If i=0 Then
					brkol(0).ad=0 'delete continue to cursor
					stopcode=CSCURSOR
				Else
					If brkol(i).typ=2 Then brk_del(i):stopcode=CSBRKTEMPO 'tempo breakpoint
				End If
				Return True
			End If
		Next
		Return False
	End Function
#endif

Private Sub thread_change(th As Integer =-1)
	Dim As Integer t, s
	If th=-1 Then t=thread_select() Else t=th
	
	If thread(t).sts=KTHD_RUN Then
		'messbox("Changing thread","Not possible as current thread is running"+chr(10)+"If the thread is waiting (sleep, input, etc) try to quit this state")
		MsgBox("Changing thread", "Caution : current thread is running")
		'exit sub
	End If
	
	s=threadcur
	'WriteProcessMemory(dbghand,Cast(LPVOID,rLine(thread(threadcur).sv).ad),@breakcpu,1,0) 'restore CC previous line current thread
	threadcur=t
	#ifdef __FB_WIN32__
		threadprv=t
	#endif
	'WriteProcessMemory(dbghand,Cast(LPVOID,rLine(thread(threadcur).sv).ad),@rLine(thread(threadcur).sv).sv,1,0) 'restore old value for execution selected thread
	threadhs=thread(threadcur).hd
	procsv=rline(thread(threadcur).sv).px
	thread_text(t)
	thread_text(s)
	threadsel=threadcur
	dsp_change(thread(threadcur).sv)
End Sub

Private Sub thread_del(thid As UInteger)
	Dim As Integer k=1,threadsup,threadold=threadcur
	For i As Integer =1 To threadnb
		If thid<>thread(i).id Then
			If i<>k Then thread(k)=thread(i):If i=threadcur Then threadcur=k 'optimization
			k+=1
		Else
			threadsup=i
			thread(threadsup).plt=0
			thread(threadsup).pe=0
			If thread(i).sv<>-1 Then
				'delete thread item and child
				
				#ifdef __FB_WIN32__
					SendMessage(tviewthd, TVM_DELETEITEM, 0, Cast(LPARAM, thread(i).tv))
				#else
					With *Cast(TreeNode Ptr, thread(i).tv)
						If .ParentNode = 0 Then
							tviewthd->Nodes.Remove .Index
						Else
							.ParentNode->Nodes.Remove .Index
						End If
					End With
				#endif
				'proc delete
				For j As Integer = procrnb To 2 Step -1 'always keep procr(1)=main
					If procr(j).thid=thid Then
						proc_del(j)
					End If
				Next
			End If
		End If
	Next
	threadnb-=1
	If threadsup<>threadold Then Exit Sub 'if deleted thread was the current, replace by first thread
	
	If runtype=RTAUTO AndAlso threadaut>1 Then 'searching next thread
		threadaut-=1
		k=threadcur
		Do
			k+=1:If k>threadnb Then k=0
		Loop Until thread(k).exc
		thread_change(k)
		thread_rsm()
	Else
		threadcur=0 'first thread
		#ifdef __FB_WIN32__
			threadprv=0 'no change
		#endif
		threadsel=0
		threadhs=thread(0).hd
		thread_text(0)
		runtype=RTSTEP
		dsp_change(thread(0).sv)
	End If
End Sub

#ifdef __FB_WIN32__
	Private Function brkv_test() As Byte
		Dim recup(20) As Integer,ptrs As pointeurs,flag As Integer=0
		Dim As Integer adr,temp2,temp3
		Dim As String strg
		ptrs.pxxx=@recup(0)
		
		If brkv.arr Then 'watching dyn array element ?
			adr=vrr(brkv.ivr).ini
			ReadProcessMemory(dbghand,Cast(LPCVOID,adr),@adr,4,0)
			If adr<>brkv.arr Then brkv.adr+=brkv.arr-adr:brkv.arr=adr 'compute delta then add it if needed
			temp2=vrr(brkv.ivr).ini+2*SizeOf(Integer) 'adr global size 25/07/2015 64bit
			ReadProcessMemory(dbghand,Cast(LPCVOID,temp2),@temp3,SizeOf(Integer),0)
			If brkv.adr>adr+temp3 Then 'out of limit ?
				brkv_set(0) 'erase
				Return False
			End If
		End If
		
		Select Case brkv.typ
		Case 2 'byte
			ReadProcessMemory(dbghand,Cast(LPCVOID,brkv.adr),@recup(0),1,0)
			If brkv.Val.vbyte>*ptrs.pbyte Then
				If 42 And brkv.ttb Then flag=1
			ElseIf brkv.Val.vbyte<*ptrs.pbyte Then
				If 37 And brkv.ttb Then flag=1
			ElseIf brkv.Val.vbyte=*ptrs.pbyte Then
				If 19 And brkv.ttb Then flag=1
			End If
		Case 3 'ubyte
			ReadProcessMemory(dbghand,Cast(LPCVOID,brkv.adr),@recup(0),1,0)
			If brkv.Val.vubyte<*ptrs.pubyte Then
				If 42 And brkv.ttb Then flag=1
			ElseIf brkv.Val.vubyte>*ptrs.pubyte Then
				If 37 And brkv.ttb Then flag=1
			ElseIf brkv.Val.vubyte=*ptrs.pubyte Then
				If 19 And brkv.ttb Then flag=1
			End If
		Case 5 'short
			ReadProcessMemory(dbghand,Cast(LPCVOID,brkv.adr),@recup(0),2,0)
			If brkv.Val.vshort<*ptrs.pshort Then
				If 42 And brkv.ttb Then flag=1
			ElseIf brkv.Val.vshort>*ptrs.pshort Then
				If 37 And brkv.ttb Then flag=1
			ElseIf brkv.Val.vshort=*ptrs.pshort Then
				If 19 And brkv.ttb Then flag=1
			End If
		Case 6 'ushort
			ReadProcessMemory(dbghand,Cast(LPCVOID,brkv.adr),@recup(0),2,0)
			If brkv.Val.vushort<*ptrs.pushort Then
				If 42 And brkv.ttb Then flag=1
			ElseIf brkv.Val.vushort>*ptrs.pushort Then
				If 37 And brkv.ttb Then flag=1
			ElseIf brkv.Val.vushort=*ptrs.pushort Then
				If 19 And brkv.ttb Then flag=1
			End If
		Case 1 'integer32/long
			ReadProcessMemory(dbghand,Cast(LPCVOID,brkv.adr),@recup(0),4,0)
			If brkv.Val.vinteger<*ptrs.pinteger Then
				If 42 And brkv.ttb Then flag=1
			ElseIf brkv.Val.vinteger>*ptrs.pinteger Then
				If 37 And brkv.ttb Then flag=1
			ElseIf brkv.Val.vinteger=*ptrs.pinteger Then
				If 19 And brkv.ttb Then flag=1
			End If
		Case 8 'uinteger32/ulong       pointer
			ReadProcessMemory(dbghand,Cast(LPCVOID,brkv.adr),@recup(0),4,0)
			If brkv.Val.vuinteger<*ptrs.puinteger Then
				If 42 And brkv.ttb Then flag=1
			ElseIf brkv.Val.vuinteger>*ptrs.puinteger Then
				If 37 And brkv.ttb Then flag=1
			ElseIf brkv.Val.vuinteger=*ptrs.puinteger Then
				If 19 And brkv.ttb Then flag=1
			End If
		Case 4,13,14
			If brkv.typ=13 Then  ' normal string
				ReadProcessMemory(dbghand,Cast(LPCVOID,brkv.adr),@adr,SizeOf(Integer),0) 'address ptr 25/07/2015 64bit
			Else
				adr=brkv.adr
			End If
			Clear recup(0),0,26 'max 25 char
			ReadProcessMemory(dbghand,Cast(LPCVOID,adr),@recup(0),25,0) 'value
			strg=*ptrs.pzstring
			If brkv.ttb=32 Then
				If brkv.vst<>strg Then flag=1
			Else
				If brkv.vst=strg Then flag=1
			End If
		End Select
		If flag Then
			If brkv.ivr=0 Then stopcode=CSBRKM Else stopcode=CSBRKV
			brkv_set(0)
			Return True
		End If
		Return False
	End Function
#endif

Private Function line_call(regip As UInteger) As Integer 'find the calling line for proc
	For i As Integer=1 To linenb
		If regip<=rline(i).ad Then
			If regip = rline(i).ad Then
				Return i - 1
			Else
				Return i
			End If
		End If
	Next
	Return linenb
End Function

#ifdef __FB_WIN32__
	Private Sub proc_newfast()
		Dim vcontext As CONTEXT
		Dim libel As String
		Dim As UInteger regbp,regip,regbpnb,regbpp(PROCRMAX)
		Dim As ULong j,k,pridx(PROCRMAX),calin(PROCRMAX)
		Dim tv As HTREEITEM
		vcontext.ContextFlags=CONTEXT_CONTROL Or CONTEXT_INTEGER
		'loading with rbp/ebp and proc index
		For i As Integer =0 To threadnb
			regbpnb=0
			GetThreadContext(thread(i).hd,@vcontext)
			regbp=vcontext.regbp:regip=vcontext.regip 'current proc
			j = 0
			While 1
				For j =j + 1 To procnb
					If regip>=proc(j).db And regip<=proc(j).fn Then
						If regbpnb = 50000 Then Exit While
						regbpnb+=1:regbpp(regbpnb)=regbp:pridx(regbpnb)=j
						Exit For
					End If
				Next
				If j>procnb Then Exit While
				ReadProcessMemory(dbghand,Cast(LPCVOID,regbp+SizeOf(Integer)),@regip,SizeOf(Integer),0) 'return EIP/RIP    12/07/2015 4 replaced by sizeof(integer)
				ReadProcessMemory(dbghand,Cast(LPCVOID,regbp)                ,@regbp,SizeOf(Integer),0) 'previous RBP/EBP
				
				calin(regbpnb)=line_call(regip)
			Wend
			'delete only if needed
			j=regbpnb:k=0
			While k<procrnb
				k+=1
				If procr(k).thid <> thread(i).id Then Continue While
				If procr(k).idx=pridx(j) Then
					j-=1 'running proc still existing so kept
				Else
					proc_del(k) 'delete procr
					k-=1 'to take in account that a procr has been deleted
				End If
			Wend
			'create new procrs
			For k As Integer =j To 1 Step -1
				If procrnb=PROCRMAX Then MsgBox(ML("CLOSING DEBUGGER: Max number of sub/func reached")): DestroyWindow (windmain):Exit Sub
				If proc(pridx(k)).st=2 Then Continue For 'proc state don't follow
				procrnb+=1
				procr(procrnb).sk=regbpp(k)
				procr(procrnb).thid=thread(i).id
				procr(procrnb).idx=pridx(k)
				
				'test if first proc of thread
				If thread(i).plt=0 Then
					thread(i).tv= Tree_AddItem(NULL,"", 0, tviewthd, 0)'create item
					thread(i).ptv=thread(i).tv 'last proc
					thread_text(i)'put text
					thread(i).st=0 'with fast no starting line could be gotten
					procr(procrnb).cl=-1  ' no real calling line
					libel="ThID="+Str(procr(procrnb).thid)+" "
					tv=TVI_LAST 'insert in last position
				Else
					tv=thread(i).plt 'insert after the last item of thread
					procr(procrnb).cl=calin(k)
					libel=""
				End If
				'add manage LIST
				'If flagtrace Then dbg_prt ("NEW proc "+proc(pridx(k)).nm)
				libel+=proc(pridx(k)).nm+":"+proc_retval(pridx(k))
				If flagverbose Then libel+=" ["+Str(proc(pridx(k)).db)+"]"
				
				procr(procrnb).tv=Tree_AddItem(0,libel,tv,tviewvar, 0)
				thread(i).plt=procr(procrnb).tv 'keep handle last item
				
				thread(i).ptv=Tree_AddItem(thread(i).ptv,proc(pridx(k)).nm,TVI_FIRST,tviewthd, 0)
				var_ini(procrnb,proc(procr(procrnb).idx).vr,proc(procr(procrnb).idx+1).vr-1)
				procr(procrnb+1).vr=vrrnb+1
				'If proc(procsv).nm="main" Then procr(procrnb).vr=1 'constructors for shared they are executed before main so reset index for first variable of main 04/02/2014
				proc_watch(procrnb) 'reactivate watched var
			Next
			RedrawWindow tviewthd, 0, 0, 1
			RedrawWindow tviewvar, 0, 0, 1
		Next
	End Sub
	'====================================================================
'' prepares singlestepping for restoring BP
'====================================================================
Private Sub singlestep_on(tid As Integer,rln As Integer,running As Integer =1)
	Dim As Integer dummy ''used to align vcontext on 16bit
	Dim vcontext As CONTEXT
    For i As Integer =0 To threadnb
		If tid=thread(i).id Then
			threadcontext=thread(i).hd

			'get context
			vcontext.ContextFlags=CONTEXT_CONTROL
			GetThreadContext(threadcontext,@vcontext)

			If running Then ''when not running initial code is already restored and no need to decrease EIP
				''restore initial code
				writeprocessmemory(dbghand,Cast(LPVOID,rline(rln).ad),@rline(rln).sv,1,0)
				''change EIP go back 1 byte
				vcontext.regip-=1
			End If

			''set Trace flag on
			vcontext.EFlags=BitSet(vcontext.EFlags,8)
			''update context
			SetThreadContext(threadcontext,@vcontext)
			''rline for restoring BP
			ssadr=rline(rln).ad
			Exit Sub
		End If
	Next
End Sub
'=====================================
Private Sub resume_exec()
	For jbrk As Integer = 1 To brknb ''restore if needed the UBP
		If brkol(jbrk).typ<50 Then
			If rlinecur=brkol(jbrk).index Then ''if current line is a BP (permanent/cond/counter)
				singlestep_on(thread(threadcur).id,rlinecur,0)
				Exit For
			EndIf
		End If
	Next
	thread_resume()
End Sub
'====================================================================
Private Sub thread_search(tid As Integer,bptype As Integer,ddata As Integer)
	For i As Integer =0 To threadnb
		If tid=thread(i).id Then
			threadcontext=thread(i).hd
			threadhs=threadcontext
			SuspendThread(threadcontext)
			threadcur=i
			stopcode=bptype
			debugdata=ddata
			debugevent=KDBGRKPOINT
			If stopcode<>CSSTEP And thread(i).rtype=RTAUTO Then
				dbg_prt2 "RTSTEP forced"
				'thread(i).rtype=RTSTEP ''in case user's BP and RTAUTO
				runtype=RTSTEP
			End If
			MutexLock blocker
			MutexUnlock blocker
			Exit Sub
		End If
	Next
End Sub
'=====================================
'' Set breakpoint (CC) for every line
'=====================================
Private Sub set_cc()
	If ccstate=KCC_NONE Then ''only done if needed
		For iline As Integer = 1 To linenb
			If proc(rline(iline).px).enab = True Then
				WriteProcessMemory(dbghand,Cast(LPVOID,rline(iline).ad),@breakcpu,1,0)
			End If
		Next
		ccstate=KCC_ALL
	EndIf
End Sub
'========================================================
''  handles breakpoints
'========================================================
	Private Sub gest_brk(ad As Integer, ByVal rln As Integer = -1)
	
			Dim As Integer dummy
		Dim vcontext As CONTEXT
			vcontext.ContextFlags = CONTEXT_CONTROL Or CONTEXT_INTEGER
			Dim As UInteger i, debut = 1, fin = linenb + 1, adr, iold
		'egality added in case attach (example access violation) without -g option, ad=procfn=0....
		If ad>=procfn Then
				thread_resume()
				Exit Sub 'out of normal area, the first exception breakpoint is dummy or in case of use of debugbreak
			End If
			proccurad = ad
			If rln = -1 Then
		i=thread(threadcur).sv+1
		
		If rline(i).ad<>ad Then 'hope next source line is next executed line (optimization)
			While 1
				iold=i
				i=(debut+fin)\2 'first consider that the addresses are sorted increasing order
				If i=iold Then 'loop
					For j As Integer =1 To linenb
						If rline(j).ad=ad Then i=j:Exit While
					Next
					Exit While
				End If
				If ad>rline(i).ad Then
					debut=i
				ElseIf ad<rline(i).ad Then
					fin=i
				Else
					Exit While
				End If
			Wend
		End If
			rln = i
			End If
		rlinecur=rln
		''restore CC previous line
		'If thread(threadcur).sv<>-1 Then WriteProcessMemory(dbghand,Cast(LPVOID,rline(thread(threadcur).sv).ad),@breakcpu,1,0)
		''thread changed by threadcreate or by mutexunlock
		'If threadcur<>threadprv Then
		'	If thread(threadprv).sv<>i Then 'don't do it if same line otherwise all is blocked.....not sure it's usefull
		'		WriteProcessMemory(dbghand,Cast(LPVOID,rline(thread(threadprv).sv).ad),@breakcpu,1,0) 'restore CC
		'	End If
		'	stopcode=CSNEWTHRD  'status HALT NEW THREAD
		'	runtype=RTSTEP
		'	thread_text(threadprv) 'not next executed
		'	thread_text(threadcur) 'next executed
		'	threadprv=threadcur
		'End If
		
		thread(threadcur).od = thread(threadcur).sv: thread(threadcur).sv = rln
		procsv = rline(rln).px
		'get and update registers
		'vcontext.ContextFlags = CONTEXT_CONTROL Or CONTEXT_INTEGER
		GetThreadContext(threadcontext,@vcontext)
		
		If proccurad=proc(procsv).db Then 'is first proc instruction
			thread(threadcur).cl = thread(threadcur).od ''done here to avoid a wrong assignment
			If rline(rln).sv = 85 Then 'check if the first instruction is push ebp opcode=85 / push rbp opcode=&h55=85dec
				
				'in this case there is a prologue
				'at the beginning of proc EBP not updated so use ESP
				procsk=vcontext.regsp-SizeOf(Integer) 'ESP-4 for respecting prologue : push EBP then mov ebp,esp / 64bit push rbp then mov rbp,rsp
			Else
				If procrnb<>0 Then  'no main and no prologue so naked proc, procrnb not yet updated
					procsk=vcontext.regsp
					thread(threadcur).nk=procsk
				Else
						MsgBox("Main procedure problem", "No standard prologue --> random behaviour")
					procsk=vcontext.regsp-SizeOf(Integer) 'if gcc>3 for main prologue is different
				End If
			End If
		Else
			'only for naked, check if return by comparing top of stack because no epilog
			If thread(threadcur).nk Then
				If vcontext.regsp>thread(threadcur).nk Then
					thread(threadcur).pe=True
					thread(threadcur).nk=0
				End If
			End If
		End If
		vcontext.regip=ad
		
		SetThreadContext(threadcontext,@vcontext)
		
		'		If runtype = RTRUN Then
		'			For i As Integer = 1 To linenb 'restore CC
		'				If proc(rline(i).px).nu = i Then
		'					WriteProcessMemory(dbghand, Cast(LPVOID, rline(i).ad), @breakcpu, 1, 0)
		'				Else
		'					WriteProcessMemory(dbghand, Cast(LPVOID, rline(i).ad), @rLine(i).sv, 1, 0)
		'				End If
		'			Next
		'			thread_rsm
		'			Exit Sub
		'		End If
		
		If FastRunning Then
			FastRunning = False
			Dim As Integer ad = rline(thread(threadcur).sv).ad
			Dim As Boolean bInBreakPoint
			For j As Integer = 0 To brknb 'breakpoint
				If brkol(j).typ<3 AndAlso brkol(j).ad = ad Then
					bInBreakPoint = True
					Exit For
				End If
			Next
			If Not bInBreakPoint Then
				For j As Integer = 0 To linenb 'restore all instructions
					WriteProcessMemory(dbghand, Cast(LPVOID, rline(j).ad), @rline(j).sv, 1, 0)
				Next
				For j As Integer = 0 To brknb 'breakpoint
					If brkol(j).typ < 3 Then WriteProcessMemory(dbghand, Cast(LPVOID, brkol(j).ad), @breakcpu, 1, 0) 'only enabled
				Next
				thread_rsm()
				Exit Sub
			End If
		End If
		
		'dbg_prt2("PE"+Str(thread(threadcur).pe)+" "+Str(proccurad)+" "+Str(proc(procsv).fn))'07/07/2015
		If thread(threadcur).pe Then 'if previous instruction was the last of proc
			If proccurad<>proc(procsv).db Then procsk=vcontext.regbp 'reload procsk with rbp/ebp 04/02/2014 test added for case constructor on shared
			proc_end():thread(threadcur).pe=False
		End If
		
		If proccurad=proc(procsv).db Then 'is first instruction ?
			'If proctop Then runtype=RTSTEP:procad=0:procin=0:proctop=False:procbot=0' step call execute one step to reach first line
			'proc_new
			'thread_rsm:Exit Sub
				If thread(threadcur).od <>-1 Then
					dbg_prt2 "restore CC 00 ad="; Hex(rline(thread(threadcur).od).ad)
					WriteProcessMemory(dbghand, Cast(LPVOID, rline(thread(threadcur).od).ad), @breakcpu, 1, 0)
				End If
				dbg_prt2 "first instruc so exit"
				thread(threadcur).sts = KTHD_STOP ''threads not followed stay in init status
				prolog = 1 ''only used when multithread to avoid release next thread too quickly
				thread_resume(threadcur)
				Exit Sub
		End If

	If thread(threadcur).sts = KTHD_INIT Then ''case create thread when RTRUNning
		dbg_prt2 "rtype=";threadcur,thread(threadcur).rtype
		thread(threadcur).rtype=RTRUN
	EndIf
	dbg_prt2 "threadcur, rtype=";threadcur,thread(threadcur).rtype,vcontext.regbp
	thread(threadcur).sts=KTHD_STOP
	thread_status()

	If thread(threadcur).rtype=RTRUN Then

		If brkol(0).typ<>10 Then ''for skip over always in same proc, if different thread ???
			proc_runnew   ''fill running proc tree
		End If

			'var_sh			'updating information about variables
		runtype=RTSTEP ''another threads could be still running but allows display (buttons, etc)

   		dsp_change(rln)
		If stopcode=CSLINE Then
			brk_del(0)
		ElseIf stopcode=CSBRKPT Then
			For ibrk As Integer	= 1 To brknb
				If brkol(ibrk).index=rln Then
					If brkol(ibrk).typ=5 Then
						brk_del(ibrk) ''remove tempo BP
						Exit For
					EndIf
				EndIf
			Next
		EndIf

   Else 'RTSTEP or RTAUTO
		If flagattach Then
			proc_runnew
			flagattach=False
		Else
			dbg_prt2 "in mode step runtype=";runtype,threadlistidx
			If proccurad=proc(procsv).first Then 'is first fbc instruction ?
				''check if not in the current proc, if used set 0 to .stack() when creation of thread????
				'if procsk<>thread(threadcur).stack then
				prolog=0
				dbg_prt2 "check stack=";vcontext.regbp,procsk,thread(threadcur).stack
				If vcontext.regbp<>thread(threadcur).stack Then
					proc_new()
				EndIf
				'thread_resume():Exit Sub
			ElseIf proccurad=proc(procsv).fn Then
				thread(threadcur).pe=True        'is last instruction ?
			EndIf

		EndIf
		'NOTA If rline(i).nu=-1 Then
			'fb_message("No line for this proc","Code added by compiler (constructor,...)")

		If runtype=RTSTEP Then
			thread(threadcur).rtype=RTSTEP ''case RTAUTO but halted
		End If
dbg_prt2 "rLine(thread(threadcur).sv).nu=";rline(thread(threadcur).sv).nu
		dsp_change(rln)

		''restore CC previous line
		If thread(threadcur).od<>-1 Then
			dbg_prt2 "restore CC 01 ad=";Hex(rline(thread(threadcur).od).ad)
			WriteProcessMemory(dbghand,Cast(LPVOID,rline(thread(threadcur).od).ad),@breakcpu,1,0)
		End If

		If runtype=RTAUTO Then
			Sleep(autostep)
			dbg_prt2 "auto thread=";threadnb,threadlistidx
			If threadnb=0 Then
				dbg_prt2 "auto 1 thread"
				thread_resume(threadcur)
			Else
				If threadlistidx=-1 Then
					dbg_prt2 "auto x threads"
					thread_set()
				End If
			End If
		End If
	End If
	If runtype=RTFRUN Then
	'	fasttimer=Timer-fasttimer
		For i As Integer = 1 To linenb 'restore CC
			If LimitDebug AndAlso Not EqualPaths(GetFolderName(source(rline(i).sx)), mainfolder) Then
			Else
				WriteProcessMemory(dbghand, Cast(LPVOID, rline(i).ad), @breakcpu, 1, 0)
			End If
		Next
	End If
		'ElseIf proccurad=proc(procsv).fn Then
		'	thread(threadcur).pe=True        'is last instruction ?
		'End If
		'
		'If runtype=RTRUN Then
		'	' test breakpoint on line
		'	If brk_test(proccurad) Then fasttimer = Timer - fasttimer: runtype= RTSTEP: procad = 0: procin = 0: proctop = False: procbot = 0: dsp_change(i): Exit Sub
		'	'test beakpoint on var
		'	If brkv.adr<>0 Then
		'		If brkv_test() Then runtype=RTSTEP:procad=0:procin=0:proctop=False:procbot=0:dsp_change(i):Exit Sub
		'	End If
		'	If procad Then 	'test out
		'		If proc(procad).fn=proccurad Then procad=0:procin=0:proctop=False:procbot=0:runtype=RTSTEP 'still running ONE step before stopping
		'	ElseIf procin Then 'test over
		'		If procsk>=procin Then procad=0:procin=0:proctop=False:procbot=0:runtype=RTSTEP:dsp_change(i):Exit Sub
		'	ElseIf procbot Then 'test end of proc
		'		If proc(procbot).fn=proccurad Then procad=0:procin=0:proctop=False:procbot=0:runtype=RTSTEP:dsp_change(i):Exit Sub 'stop on end of proc STEPRETURN
		'	End If
		'	thread_rsm()
		'ElseIf runtype=RTFRUN Then
		'	fasttimer=Timer-fasttimer
		'	For i As Integer = 1 To linenb 'restore CC
		'		If LimitDebug AndAlso Not EqualPaths(GetFolderName(source(rline(i).sx)), mainfolder) Then
		'		Else
		'			WriteProcessMemory(dbghand, Cast(LPVOID, rline(i).ad), @breakcpu, 1, 0)
		'		End If
		'	Next
		'	'WriteProcessMemory(dbghand,Cast(LPVOID,rLine(i).ad),@rLine(i).sv,1,0) 'restore old value for execution
		'	brk_test(proccurad) ' cancel breakpoint on line, if command halt not really used
		'	proc_newfast   'creating running proc tree
		'	var_sh			'updating information about variables
		'	runtype=RTSTEP:dsp_change(i)
		'Else 'RTSTEP or RTAUTO
		'	If flagattach Then proc_newfast:flagattach=False
		'	'NOTA If rline(i).nu=-1 Then
		'	'fb_message("No line for this proc","Code added by compiler (constructor,...)")
		'	'Else
		'	dsp_change(i)
		'	
		'	'EndIf
		'	If runtype=RTAUTO Then
		'		Sleep(autostep)
		'		If threadaut>1 Then 'at least 2 threads
		'			Dim As Integer c=threadcur
		'			Do
		'				c+=1:If c>threadnb Then c=0
		'			Loop Until thread(c).exc
		'			thread_change(c)
		'		End If
		'		thread_rsm
		'	End If
		'	'			If threadsel<>threadcur AndAlso msgbox(ML("New Thread: Previous thread") & " "+Str(thread(threadsel).id)+" " & ML("changed by") & " "+Str(thread(threadcur).id) _
		'	'				+Chr(10)+Chr(13)+" " & ML("Keep new one?"),, mtQuestion, btYesNo) = mrNo Then
		'	'				thread_change(threadsel)
		'	'			Else
		'	threadsel=threadcur
		'	'			End If
		'End If
		
	End Sub
#endif
	
Sub fastrun() 'running until cursor or breakpoint !!! Be carefull
	Dim As Integer ad = rline(thread(threadcur).sv).ad
	Dim As Boolean bInBreakPoint
	For j As Integer = 0 To brknb 'breakpoint
		If brkol(j).typ<3 AndAlso brkol(j).ad = ad Then
			bInBreakPoint = True
			Exit For
		End If
	Next
	DeleteDebugCursor
	If bInBreakPoint Then
		FastRunning = True
	Else
		Dim i As Integer, b As Integer
		For j As Integer = 0 To linenb 'restore all instructions
			WriteProcessMemory(dbghand,Cast(LPVOID,rline(j).ad),@rline(j).sv,1,0)
		Next
		For j As Integer = 0 To brknb 'breakpoint
			If brkol(j).typ<3 Then WriteProcessMemory(dbghand,Cast(LPVOID,brkol(j).ad),@breakcpu,1,0) 'only enabled
		Next
	End If
	runtype=RTFRUN
	fasttimer=Timer
	thread_rsm()
End Sub

#ifdef __FB_WIN32__
	Private Sub debugstring_read(debugev As debug_event)
		Dim As WString *400 wstrg
		Dim As ZString *400 sstrg
		Dim leng As Integer
		If debugev.u.DebugString.nDebugStringLength<400 Then
			leng=debugev.u.DebugString.nDebugStringLength
		Else
			leng=400
		End If
		If debugev.u.DebugString.fUnicode Then
			ReadProcessMemory(dbghand,Cast(LPCVOID,debugev.u.DebugString.lpDebugStringData),_
			@wstrg,leng,0)
			m wstrg 'messageboxW(0,wstrg,WStr("debug wstring"),MB_OK)
		Else
			ReadProcessMemory(dbghand,Cast(LPCVOID,debugev.u.DebugString.lpDebugStringData),_
			@sstrg,leng,0)
			m sstrg 'messageboxA(0,sstrg,@Str("debug string"),MB_OK)
		End If
	End Sub
	
	Function wait_debug() As Integer
		Dim DebugEv As debug_event    ' debugging event information
		Dim dwContinueStatus As Long = DBG_CONTINUE ' exception continuation
		Dim As Integer FirstChance, FlagSecond, bptyp, cpt
		Dim As UInteger adr
		Dim As String Accviolstr(1) = {"TRYING TO READ", "TRYING TO WRITE"}
		Dim recup As String * 300, libel As String
		Dim ErrNumber As Long
		'If hAttach Then SetEvent(hAttach): hAttach = 0
		' Wait for a debugging event to occur. The second parameter indicates
		' that the function does not return until a debugging event occurs.
		Do
			If WaitForDebugEvent(@DebugEv, INFINITE) = 0 Then
				ErrNumber = GetLastError
				ContinueDebugEvent(DebugEv.dwProcessId, DebugEv.dwThreadId, dwContinueStatus)
				Exit Function
			End If
			' Process the debugging event code.
			Select Case (DebugEv.dwDebugEventCode)
			Case EXCEPTION_DEBUG_EVENT
				FirstChance = DebugEv.u.Exception.dwFirstChance
				adr = Cast(UInteger, DebugEv.u.Exception.ExceptionRecord.ExceptionAddress)
				If FirstChance = 0 Then 'second try
					If FlagSecond = 0 Then
						FlagSecond = 1
						FirstChance = 1
						For i As Integer = 0 To threadnb
							If DebugEv.dwThreadId = thread(i).id Then
								threadcontext = thread(i).hd
								threadhs = threadcontext
								threadcur = i
								Exit For
							End If
						Next
						For i As Integer = 1 To linenb 'debugbreak or access violation could be in the middle of line
							If rline(i).ad <= adr And rline(i + 1).ad > adr Then
								thread(threadcur).od = thread(threadcur).sv
								thread(threadcur).sv = i
								Exit For
							End If
						Next
					End If
				Else
					FlagSecond = 0
				End If
				If FirstChance Then 'if =0 second try so no compute code
					Select Case (DebugEv.u.Exception.ExceptionRecord.ExceptionCode)
					Case EXCEPTION_SINGLE_STEP
						WriteProcessMemory(dbghand, Cast(LPVOID, ssadr), @breakcpu, 1, 0)
						ContinueDebugEvent(DebugEv.dwProcessId, DebugEv.dwThreadId, dwContinueStatus)
					Case EXCEPTION_BREAKPOINT:
						'For i As Integer = 0 To threadnb 'if msg from thread then flag off
						'	If DebugEv.dwThreadId = thread(i).id Then
						'		threadcur = i
						'		threadcontext = thread(i).hd: threadhs = threadcontext
						'		SuspendThread(threadcontext)
						'		Exit For
						'	End If
						'Next
						'gest_brk(adr)
						'ContinueDebugEvent(DebugEv.dwProcessId,DebugEv.dwThreadId, dwContinueStatus)
						'=========================
						While 1
							'dbg_prt2 "------------------------------------------------------------------------------------------"
							'dbg_prt2 "EXCEPTION_BREAKPOINT",adr
							Dim As Integer bpidx=-1
							If runtype=RTCRASH Then
								''don't stop as running until a crash
								breakadr=adr
								For irln As Integer =1 To linenb
									If rline(irln).ad=adr Then
										singlestep_on(DebugEv.dwThreadId,irln)
										Exit For
									EndIf
								Next
								Exit While
							End If
							If runtype=RTRUN Or runtype=RTAUTO Then
								If brkv.adr1<>0 Then
									If brk_test(brkv.adr1,brkv.adr2,brkv.typ,brkv.Val,brkv.ttb) Then
										If brkv.ivr1=0 Then
											thread_search(DebugEv.dwThreadId,CSMEM,adr)
										Else
											thread_search(DebugEv.dwThreadId,CSVAR,adr)
										End If
										Exit While
									Else
										For irln As Integer =1 To linenb
											If rline(irln).ad=adr Then
												singlestep_on(DebugEv.dwThreadId,irln)
												Exit For
											EndIf
										Next
									End If
									'exit while
								End If
								''retrieves BP corresponding at address (loop) -->bpidx
								For ibrk As Integer =0 To brknb
									If brkol(ibrk).typ>50 Then Continue For 'disabled
									If brkol(ibrk).ad=adr Then
										bpidx=ibrk
										runtype=RTRUN ''forcing by default RTRUN usefull only if RTAUTO
										Exit For
									EndIf
								Next
								If bpidx<>-1 Then
									If bpidx=0 Then ''BP on LINE (line, cursor, over,eop,xop)
										thread_search(DebugEv.dwThreadId,CSLINE,bpidx)
										Exit While
									End If
									bptyp=brkol(bpidx).typ
									If bptyp=2 Or bptyp=3 Then  ''BP conditional
										If brk_test(brkol(bpidx).adrvar1,brkol(bpidx).adrvar2,brkol(bpidx).datatype,brkol(bpidx).val,brkol(bpidx).ttb) Then
											thread_search(DebugEv.dwThreadId,CSCOND,bpidx)
										Else
											singlestep_on(DebugEv.dwThreadId,brkol(bpidx).index)
										End If
										Exit While
									ElseIf bptyp=4 Then ''BP counter
										If brkol(bpidx).counter>0 Then
											brkol(bpidx).counter-=1'decrement counter
											singlestep_on(DebugEv.dwThreadId,brkol(bpidx).index)
										Else
											thread_search(DebugEv.dwThreadId,CSCOUNT,bpidx)
										End If
										Exit While
									Else
										''simple BP (perm/tempo)
										thread_search(DebugEv.dwThreadId,CSBRKPT,bpidx)
										Exit While
									End If
									If stopcode=CSUSER Then
										thread_search(DebugEv.dwThreadId,stopcode,adr)
										Exit While
									End If
								Else
									thread_search(DebugEv.dwThreadId,CSSTEP,adr)
									Exit While
								End If

							Else ''RTSTEP
								If stopcode=CSUSER Then ''CSUSER
									thread_search(DebugEv.dwThreadId,stopcode,adr)
								Else
									thread_search(DebugEv.dwThreadId,CSSTEP,adr)
								End If
								Exit While
							End If
						Wend

						ContinueDebugEvent(DebugEv.dwProcessId,DebugEv.dwThreadId, dwContinueStatus)
					Case Else 'Exception
						With DebugEv.u.Exception.ExceptionRecord
							For i As Integer = 0 To threadnb 'if msg from thread then flag off
								If DebugEv.dwThreadId=thread(i).id Then
									If thread(i).sv=-1 Then 'the exception is not in an handled thread, it's going to be ignored, hoping to no other effect ;-) 25/01/2015
										''	        							                    For j As Integer=0 To threadnb
										''		        							                       If thread(j).sv=-1 Then
										''		        								                          ContinueDebugEvent(DebugEv.dwProcessId,thread(j).id, dwContinueStatus)
										''		        								                      EndIf
										''	        							                    Next
										'ContinueDebugEvent(DebugEv.dwProcessId,DebugEv.dwThreadId, DBG_EXCEPTION_NOT_HANDLED)
										'libel=excep_lib(DebugEv.u.Exception.ExceptionRecord.ExceptionCode)+Chr(13)+Chr(10) 'need chr(10) to dbg_prt otherwise bad print
										'If DebugEv.u.Exception.ExceptionRecord.ExceptionCode=EXCEPTION_ACCESS_VIOLATION Then
										'	libel+=Accviolstr(.ExceptionInformation(0))+" AT ADR (dec/hex) : "+Str(.ExceptionInformation(1))+" / "+Hex(.ExceptionInformation(1))+Chr(13)+Chr(10)
										'End If
										'
										'If flagverbose Then
										'	libel+=Chr(13)+Chr(10)+"Thread ID "+Str(DebugEv.dwThreadId)+" adr : "+Str(adr)+" / "+Hex(adr)+Chr(13)+Chr(10)
										'End If
										'm libel
										For j As Integer=0 To threadnb
		        							If  thread(j).sv=-1 Then
		        								'continuedebugevent(DebugEv.dwProcessId,thread(j).id, dwContinueStatus)
		        								'dbg_prt2(Str(GetLastError))
		        								ContinueDebugEvent(DebugEv.dwProcessId,thread(j).id, DBG_EXCEPTION_NOT_HANDLED)
		        							EndIf
	        							Next
	        							'ContinueDebugEvent(DebugEv.dwProcessId,thread(i).id, dwContinueStatus)
	        							'Exit function
										Continue Do
									End If
									threadcontext = thread(i).hd
									threadhs = threadcontext
									threadcur = i
									Exit For
								End If
							Next
							
							'07/10/2014
							libel=excep_lib(DebugEv.u.Exception.ExceptionRecord.ExceptionCode)+Chr(13)+Chr(10) 'need chr(10) to dbg_prt otherwise bad print
							If DebugEv.u.Exception.ExceptionRecord.ExceptionCode=EXCEPTION_ACCESS_VIOLATION Then
								libel += Accviolstr(.ExceptionInformation(0)) + " AT ADR (dec/hex) : " + Str(.ExceptionInformation(1)) + " / " + Hex(.ExceptionInformation(1)) + Chr(13) + Chr(10)
							End If
							
							If flagverbose Then
								libel+=Chr(13)+Chr(10)+"Thread ID "+Str(DebugEv.dwThreadId)+" adr : "+Str(adr)+" / "+Hex(adr)+Chr(13)+Chr(10)
							End If
							
							If runtype=RTFRUN OrElse runtype=RTFREE Then
								runtype=RTFRUN
								For i As Integer =1 To linenb
									'WriteProcessMemory(dbghand,Cast(LPVOID,rline(i).ad),@breakcpu,1,0)'restore CC
									If rline(i).ad<=adr AndAlso rline(i+1).ad>adr Then
										thread(threadcur).od=thread(threadcur).sv:thread(threadcur).sv=i
										Exit For ''2016/02/04 move "exit for" inside test
									End If
								Next
							Else
								runtype=RTSTEP
							End If
							If DebugEv.dwDebugEventCode Then '19/05/2014
								stopcode=CSACCVIOL
							Else
								stopcode=CSEXCEP 'excep_lib(DebugEv.u.Exception.ExceptionRecord.ExceptionCode)
							End If
							
							debugdata=adr
							debugevent=KDBGEXCEPT
							MutexLock blocker ''waiting the Go from main thread
							MutexUnlock blocker

							If debugdata=IDYES Then
								SuspendThread(threadcontext)
								ContinueDebugEvent(DebugEv.dwProcessId,DebugEv.dwThreadId, dwContinueStatus)
							Else
								ContinueDebugEvent(DebugEv.dwProcessId,DebugEv.dwThreadId, DBG_EXCEPTION_NOT_HANDLED)
							End If
							
							'gest_brk(rline(thread(threadcur).sv).ad)
							''exrichedit(proc(rline(thread(threadcur).sv).pr).sr) 'display source
							''sel_line(rline(thread(threadcur).sv).nu-1,clrperbrk,2)'Select Line in red
							''SendMessage(dbgrichedit,EM_GETSELTEXT,0,Cast(LPARAM,@recup))
							''SendMessage(dbgrichedit,EM_HIDESELECTION,1,0)'hide selection
							''case error inside proc initialisation (e.g. stack over flow)
							'If adr>rline(thread(threadcur).sv).ad And _
							'	adr<rline(thread(threadcur).sv+1).ad And _
							'	rline(thread(threadcur).sv+1).nu=rline(thread(threadcur).sv).nu Then
							'	libel+=ML("ERROR AT BEGINNING OF PROC NOT REALLY ON THIS LINE")+Chr(13)+ _
							'	ML("CHECK DIM (e.g. width array to big), Preferably don't continue")+Chr(13)+Chr(13)
							'Else
							'	libel+=ML("Possible error on this line but not SURE")+Chr(13)+Chr(13)
							'End If
							'
							'libel+=ML("File") & " : "+source(rline(thread(threadcur).sv).sx)+Chr(13)+ _
							'ML("Proc") & " : "+proc(rline(thread(threadcur).sv).px).nm+Chr(13)+ _
							'ML("Line") & " : "+Str(rline(thread(threadcur).sv).nu)+" " & ML("(selected and put in red)")+Chr(13)+ _
							'recup+Chr(13)+Chr(13)+ML("Try To continue? (if yes change values and/or use [M]odify execution)")
							'If MsgBox(libel, "Visual FB Editor", mtError, btYesNo) = mrYes Then
							'	SuspendThread(threadcontext)
							'	ContinueDebugEvent(DebugEv.dwProcessId,DebugEv.dwThreadId, dwContinueStatus)
							'Else
							'	ContinueDebugEvent(DebugEv.dwProcessId,DebugEv.dwThreadId, DBG_EXCEPTION_NOT_HANDLED)
							'End If
							'SendMessage(dbgrichedit,EM_HIDESELECTION,0,0)'show selection
						End With
						'Case Else
						'fb_message("EXCEPTION_DEBUG_EVENT ","Code :"+excep_lib(DebugEv.u.Exception.ExceptionRecord.ExceptionCode),MB_SYSTEMMODAL Or MB_ICONSTOP)
						'#Ifdef fulldbg_prt
						'dbg_prt("EXCEPTION_DEBUG_EVENT : "+excep_lib(DebugEv.u.Exception.ExceptionRecord.ExceptionCode))
						'#EndIf
						'ContinueDebugEvent(DebugEv.dwProcessId,DebugEv.dwThreadId, DBG_EXCEPTION_NOT_HANDLED)
					End Select
				Else'second chance
					ContinueDebugEvent(DebugEv.dwProcessId,DebugEv.dwThreadId, DBG_EXCEPTION_NOT_HANDLED)
					
				End If
			Case CREATE_THREAD_DEBUG_EVENT:
				With DebugEv.u.CreateThread
					If threadnb < THREADMAX Then
						threadnb += 1
						thread(threadnb).hd = .hThread
						thread(threadnb).id = DebugEv.dwThreadId
						threadcontext = .hThread
						thread(threadnb).pe = False
						thread(threadnb).sv=-1 'used for thread not debugged
						thread(threadnb).plt=0 'used for first proc of thread then keep the last proc
						thread(threadnb).st=thread(threadcur).od 'used to keep line origin
						thread(threadnb).tv=0
						thread(threadnb).exc=0 'no exec auto
						thread(threadnb).sts=KTHD_INIT
					    thread(threadnb).rtype= runtype
					Else
						MsgBox ML("Threads limit") & ": " & WStr(threadnb) & " > " & WStr(THREADMAX)
						Exit Do
					End If
				End With
				ContinueDebugEvent(DebugEv.dwProcessId, DebugEv.dwThreadId, dwContinueStatus)
			Case CREATE_PROCESS_DEBUG_EVENT
				With DebugEv.u.CreateProcessInfo
					dbghfile=.HFILE' to close the handle and liberate the file .exe
					threadnb = 0:
					thread(0).hd = .hThread
					thread(0).id = DebugEv.dwThreadId
					threadcontext = .hThread
					thread(0).pe = False
					thread(0).sv = -1  'used for thread not debugged
					thread(0).plt=0 'used for first proc of thread then keep the last proc
					thread(0).tv=0  'handle of thread
					thread(0).exc=0 'no exec auto
					thread(0).rtype=RTSTEP
					thread(0).sts = KTHD_STOP
					debugdata=Cast(Integer,.lpBaseOfImage)
					debugevent = KDBGCREATEPROCESS
					MutexLock blocker ''waiting the Go from main thread
					MutexUnlock blocker
					''show_context
					'debug_extract(Cast(UInteger,.lpBaseOfImage),exename)
				End With
				ContinueDebugEvent(DebugEv.dwProcessId, DebugEv.dwThreadId, dwContinueStatus)
			Case EXIT_THREAD_DEBUG_EVENT:
				If flagkill = False Then
					debugdata=DebugEv.dwThreadId
					debugevent = KDBGEXITTHREAD
					MutexLock blocker ''waiting the Go from main thread
					MutexUnlock blocker
					'thread_del(DebugEv.dwThreadId)
				End If
				ContinueDebugEvent(DebugEv.dwProcessId, DebugEv.dwThreadId, dwContinueStatus)
			Case EXIT_PROCESS_DEBUG_EVENT:
				'MsgBox(ML("END OF DEBUGGED PROCESS"), "Visual FB Editor")
				CloseHandle(dbghand)
				CloseHandle(dbghfile)
				CloseHandle(dbghthread)
				For i As Integer = 1 To dllnb
					CloseHandle dlldata(i).hdl 'close all the dll handles
				Next
				debugdata=DebugEv.u.ExitProcess.dwExitCode
				debugevent = KDBGEXITPROCESS
				MutexLock blocker
				MutexUnlock blocker
				ContinueDebugEvent(DebugEv.dwProcessId, DebugEv.dwThreadId, dwContinueStatus)
				prun = False
				runtype = RTEND
				Exit Do
			Case LOAD_DLL_DEBUG_EVENT:
				Dim loaddll As LOAD_DLL_DEBUG_INFO = DebugEv.u.LoadDll
				
				debugdata=Cast(Integer,@loaddll)
			debugevent=KDBGDLL
			MutexLock blocker ''waiting the Go from main thread
			MutexUnlock blocker
			ContinueDebugEvent(DebugEv.dwProcessId,DebugEv.dwThreadId, dwContinueStatus)
			
				'Dim As String dllfn
				'Dim As Integer d, delta
				'dllfn = dll_name(loaddll.hFile)
				''check yet loaded
				'For i As Integer = 1 To dllnb
				'	If dllfn = dlldata(i).fnm Then d = i: Exit For
				'Next
				'
				'If d = 0 Then 'not found
				'	If dllnb >= DLLMAX Then 'limit reached
				'		MsgBox ML("Dll limit reached")
				'		Exit Do
				'	End If
				'	dllnb += 1
				'	dlldata(dllnb).hdl = loaddll.hFile
				'	dlldata(dllnb).bse = Cast(UInteger, loaddll.lpBaseOfDll)
				'	'debug_extract(Cast(UInteger,loaddll.lpBaseOfDll),dllfn,DLL)
				'	If (linenb-linenbprev)=0 Then 'not debugged so not taking in account
				'		dllnb-=1
				'	Else
				'		dlldata(dllnb).fnm=dllfn
				'		dlldata(dllnb).gbln=vrbgbl-vrbgblprev
				'		dlldata(dllnb).gblb=vrbgblprev+1
				'		dlldata(dllnb).lnb=linenbprev+1
				'		dlldata(dllnb).lnn=linenb
				'	End If
				'Else
				'	dlldata(d).hdl=loaddll.hFile
				'	delta = Cast(Integer, loaddll.lpBaseOfDll - dlldata(d).bse)
				'	If delta <> 0 Then 'different address so need to change some thing
				'		'                    'lines
				'		'                			 For i As Integer=dlldata(dllnb).lnb To dlldata(dllnb).lnb+dlldata(dllnb).lnb-1
				'		'            						      rline(i).ad+=delta
				'		'                			 Next
				'		'            					   'globals
				'		'                			 For i As Integer=dlldata(dllnb).gblb To dlldata(dllnb).gblb+dlldata(dllnb).gbln-1
				'		'                			     vrb(i).adr+=delta
				'		'                			 Next
				'	End If
				'End If
				'ContinueDebugEvent(DebugEv.dwProcessId, DebugEv.dwThreadId, dwContinueStatus)
			Case UNLOAD_DLL_DEBUG_EVENT:
				Dim unloaddll As UNLOAD_DLL_DEBUG_INFO = DebugEv.u.UnloadDll
				For i As Integer = 1 To dllnb
					If dlldata(i).bse = unloaddll.lpBaseOfDll Then
						CloseHandle dlldata(i).hdl
						dlldata(i).hdl = 0
						debugdata = i
						debugevent = KDBGDLLUNLOAD ''only for handled dll
						MutexLock blocker ''waiting the Go from main thread
						MutexUnlock blocker
						Exit For
					End If
				Next i
				ContinueDebugEvent(DebugEv.dwProcessId, DebugEv.dwThreadId, dwContinueStatus)
			Case OUTPUT_DEBUG_STRING_EVENT:
				debugstring_read(DebugEv)
				ContinueDebugEvent(DebugEv.dwProcessId, DebugEv.dwThreadId, dwContinueStatus)
			Case RIP_EVENT
				ContinueDebugEvent(DebugEv.dwProcessId, DebugEv.dwThreadId, dwContinueStatus)
			Case Else
				ContinueDebugEvent(DebugEv.dwProcessId, DebugEv.dwThreadId, dwContinueStatus)
			End Select
		Loop
		Return 0
	End Function
	
	'excluded lines for procs added in dll (DllMain and tmp$x)
	Const EXCLDMAX=10
	' or dump
	'Dim Shared hdumpbx As HWND       'hwnd dump zone
	Dim Shared dumplig As Integer =1 'nb lines(1 or xx)
	'Dim Shared dumpadr As UInteger   'address for dump
	Dim Shared dumpdec As Integer =0 'value dump dec=0 or hexa=50
	Dim Shared copybeg As Integer   'address beginning/end for copying to clipboard
	Dim Shared copyend As Integer
	Dim Shared copycol As Integer   'column for copying to clipboard
	
	Private Sub re_ini()
		prun=False
		'runtype=RTOFF
		brkv.adr=0 'no break on var
		brknb=0 'no break on line
		brkol(0).ad=0   'no break on cursor
		
		SendMessage(tviewvar, TVM_DELETEITEM, 0, Cast(LPARAM, TVI_ROOT)) 'procs/vars
		SendMessage(tviewprc, TVM_DELETEITEM, 0, Cast(LPARAM, TVI_ROOT)) 'procs
		SendMessage(tviewthd, TVM_DELETEITEM, 0, Cast(LPARAM, TVI_ROOT)) 'threads
		
		'ShowWindow(tviewcur,SW_HIDE):tviewcur=tviewvar:ShowWindow(tviewcur,SW_SHOW)
		'SendMessage(htab2,TCM_SETCURSEL,0,0)
		'If dsptyp Then dsp_hide(dsptyp)
		'dsp_sizecalc
		threadnb=-1
		If flagrestart=-1 Then 'add test for restart without loading again all the files
			'setwindowtext(dbgrichedit,"Your source")
			'sendmessage(htab1,TCM_DELETEALLITEMS ,0,0) 'zone tab
			'For i As Integer=0 To MAXSRC:setWindowText(richedit(i),""):ShowWindow(richedit(i),SW_HIDE):Next
		Else
			'sel_line(curlig-1,0,1,richedit(curtab),FALSE) 'default color
		End If
		curlig=0
		sourcenb=-1:dllnb=0
		vrrnb=0:procnb=0:procrnb=0:linenb=0:cudtnb=0:arrnb=0:procr(1).vr=1:procin=0:procfn=0:procbot=0:proctop=False
		proc(1).vr=VGBLMAX+1 'for the first stored proc
		excldnb=0
		dumpadr=0:copybeg=-99:copyend=-99:copycol=-99 '23/11/2014
		'flaglog=0:dbg_prt(" $$$$___CLOSE ALL___$$$$ "):flagtrace=0
		flagmain=True:flagattach=False:flagkill=False
		udtcpt=0:udtmax=0
		'For i As Integer = 0 To 4 :SendMessage(dbgstatus,SB_SETTEXT,i,Cast(LPARAM,@"")) : Next '08/04/2014 3-->4
		vrbgbl=0:vrbloc=VGBLMAX:vrbgblprev=0
		udtbeg=TYPESTD+1:cudtbeg=1:locbeg=VGBLMAX+1:vrbbeg=1:prcbeg=1 'dwarf 20/08/2015 boolean
		'bx_closing
		array_tracking_remove
		'reset bookmarks
		'sendmessage(bmkh,CB_RESETCONTENT,0,0)
		'bmkcpt=0:For i As Integer =1 To BMKMAX:bmk(i).ntab=-1:Next
		'EnableMenuItem(menuedit,IDNXTBMK,MF_GRAYED)
		'EnableMenuItem(menuedit,IDPRVBMK,MF_GRAYED)
		'EnableMenuItem(menutools,IDHIDLOG,MF_GRAYED)
		compinfo="" 'information about compilation
		threadprv=0
		threadsel=0
		'hgltmax=20000 'for highlighting keywords
		'hgltpt=0
		'ReDim hgltdata(hgltmax) As tmodif
		ReDim Trans(70000)
		Trans(1)="1"
		Trans(2)="2"
		Trans(3)="1"
		Trans(4)="8"
		Trans(5)="8"
		Trans(6)="9"
		Trans(7)="10"
		Trans(8)="5"
		Trans(9)="6"
		Trans(10)="2"
		Trans(11)="3"
		Trans(12)="11"
		Trans(13)="12"
		Trans(18)="7"
		Trans(19)="2"
		Trans(20)="3"
		Trans(21)="5"
		Trans(22)="6"
		Trans(23)="1"
		Trans(24)="8"
		Trans(25)="9"
		Trans(26)="10"
		
		For i As Long =TYPESTD+1 To TYPEMAX 'reinit index to avoid message udt nok when executing an other debuggee, only gcc 16/08/2015 20/08/2015 boolean
			udt(i).typ=0
		Next
	End Sub
#endif
'==============================
'' Reinitialisation
'==============================
Private Sub reinit()
	vrbgbl=0:vrbloc=VGBLMAX:vrbgblprev=0
	prun=False
	runtype=RTOFF
	stopcode=0
	firsttime=0
	flagmain=True
	compilerversion=""
	If flagrestart=-1 Then
		'If currentdoc Then ''removes all previous docs
		'	release_doc()
		'	oldscintilla=Cast(Any Ptr,send_sci(SCI_GETDOCPOINTER,0,0)) ''keep for release later
		'End If
	End If
	'ResetAllComboBox(GFILELIST)
	srccombocur=-1
	If sourcenb<>-1 Then
		brk_del(0) ''no break on cursor/etc
	End If
	sourcenb=-1:dllnb=0
	vrrnb=0:procnb=0:procrnb=0:linenb=0:cudtnb=0:arrnb=0:procr(1).vr=1
	procfn=0
	procnew=-1
	proc(1).vr=VGBLMAX+1 'for the first stored proc
	udtcpt=0:udtmax=0
	procsort=KPROCNM
	flagtrace=0
	flagattach=False
	flagkill=False
	shwexp.free=True
	For ith As Integer =0 To threadnb
		thread(ith).plt=0
		thread(ith).pe=False
	Next
	threadnb=-1
	dumpadr=0
	brkv_set(0) ''no break on var
	brknb=0
	'for ibrk as integer = 1 to brknb
	'if brkol(ibrk).typ<>1 and brkol(ibrk).typ<>4 and brkol(ibrk).typ<>6 and brkol(ibrk).typ<>51 and brkol(ibrk).typ<>54 and brkol(ibrk).typ<>56 then ''keep only perm/temp/counter BP
	'brk_del(ibrk)
	'EndIf
	'Next
	'DeleteTreeViewItemAll(GTVIEWVAR)
	'PanelGadgetSetCursel(GRIGHTTABS,TABIDXVAR)
	'DeleteTreeViewItemAll(GTVIEWTHD)
	'todo DeleteTreeViewItem(GTVIEWWCH,0) 'watched   needed ????
	'hidewindow(hshwexpbx,KHIDE)
	For icol As Integer= 1 To dumpnbcol
		'DeleteListViewColumn(GDUMPMEM,1)
	Next
	dumpnbcol=0
	'DeleteListViewItemsAll(GDUMPMEM)
	''todo 'array_tracking_remove
	'source_change(-1) ''reinit to avoid a potential problem
	'menu_enable()
	proclistfirst=-1
	threadlistidx=-1
	prolog=0
End Sub
'================================================================
'' check if exe bitness if not wrong 32bit<>64bit windows only
'================================================================
Private Function check_bitness(ByRef fullname As WString) As Integer
	#Ifdef __FB_WIN32__
		Dim As Long bintype
		GetBinaryType(@fullname, @bintype) ''a control to prevent 32bit<>64bit
		#Ifdef __FB_64BIT__
			If bintype=SCS_32BIT_BINARY Then
				MsgBox(ML("Can not be used for debugging 32bit exe..."), App.Title & ": " & ML("Integrated IDE Debugger"))
				Return 0
			End If
		#else
			If bintype=SCS_64BIT_BINARY Then
				MsgBox(ML("Can not be used for debugging 64bit exe..."), App.Title & ": " & ML("Integrated IDE Debugger"))
				Return 0
			End If
		#endif
	#else
		Dim As UByte ubyt
		Open fullname For binary As #1
		Get #1,5,ubyt ''offset=4 32bit or 64bit
		Close #1
		#Ifdef __FB_64BIT__
			If ubyt<>2 Then
				MsgBox(ML("Can not be used for debugging 32bit exe..."), App.Title & ": " & ML("Integrated IDE Debugger"))
				'close #1
				Return 0
			End If
		#else
			If ubyt<>1 Then
				MsgBox(ML("Can not be used for debugging 64bit exe..."), App.Title & ": " & ML("Integrated IDE Debugger"))
				'close #1
				Return 0
			End If
		#endif
	#endif
	Return -1
End Function

#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
	Dim Shared As Long pIn, pOut
	
	Declare Function readpipe(WithoutAnswer As Boolean = False) As String
	Declare Function CreatePipeD(szCmd As WString Ptr , szCmdParam As WString Ptr = 0 , szCmdParam2 As WString Ptr = 0) As Long
	
	#ifdef __FB_WIN32__
		Declare Sub writepipe(ByRef szBuf As ZString, iTime As Long = 30)
		#define writepipefast writepipe
	#else
		Declare Sub writepipefast(ByRef szBuf As ZString, iTime As Long = 1)
		Declare Sub writepipe(ByRef szBuf As ZString, iTime As Long = 1)
	#endif
	Declare Function fill_locals_variables(sBuf As String , iFlagAutoUpdate As Long = 0) As Long
	Declare Sub fill_all_variables(sBuf As String , iFlagUpdate As Long = 0)
	Declare Sub info_all_variables_debug(iFlagUpdate As Long = 0)
	Declare Sub info_loc_variables_debug(iFlagAutoUpdate As Long = 0)
	Declare Sub info_threads_debug(iFlagAutoUpdate As Long = 0)
	Declare Sub deinit()
	
	Dim Shared As Boolean Running, ShowResult
	
	Dim Shared As ZString * 200000 szDataForPipe
	
	Dim Shared As Long iVersionGdb
	
	Dim Shared As String CurrentFile, NewCommand
	
	Dim Shared As Integer iPosStartLast, iPosEndLast, iCurselLast, TimerID, WatchIndex
	
	Declare Function timer_data() As Integer
	
	Declare Sub continue_debug()
	
	#ifndef __USE_WINAPI__
		#include once "crt/unistd.bi"
		
		Extern "C"
			
			Declare Function fdopen(fildes As Long, mode As ZString Ptr) As FILE Ptr
			'Declare Function kill_ Alias "kill" ( pid As pid_t, sig As Integer) As Integer
			Declare Function poll(ufds As Any Ptr, nfds As ULong, timeout As Long) As Long
			Declare Function ioctl Alias "ioctl" (fd As Integer, request As ULong, ...) As Integer
			Declare Function _access Alias "access" (ByVal As ZString Ptr, ByVal As Long) As Long
		End Extern
		
		#define SIGKILL 9
		#define FIONREAD    &h541B
		
		Type pollfd
			
			As Long fd          '/* РѕРїРёСЃР°С‚РµР»СЊ С„Р°Р№Р»Р° */
			As Short events     '/* Р·Р°РїСЂРѕС€РµРЅРЅС‹Рµ СЃРѕР±С‹С‚РёСЏ */
			As Short revents    '/* РІРѕР·РІСЂР°С‰РµРЅРЅС‹Рµ СЃРѕР±С‹С‚РёСЏ */
			
		End Type
		
		Dim Shared As pid_t pid
		
		Dim Shared As Long 	iReadPipe(1), iWritePipe(1)
	#else
		Dim Shared As HANDLE hReadPipe, hWritePipe
		
		#ifndef pid_t
			#define pid_t Long
		#endif
	#endif
	
	#ifdef __FB_WIN32__
		Dim Shared As Integer iGlPid
	#else
		Dim Shared As Long iGlPid
	#endif
	
	Dim Shared As Long iFlagThreadSignal, iFlagUpdateVariables
	
	Dim Shared As Long iCounterUpdateVariables, iFlagStartDebug, iStateMenu = 1
	
	#ifdef __USE_GTK__
		Dim Shared As guint w9T(50000)
		
		Sub KillTimer(hwnd As Any Ptr = 0, idTimer As Long)
			
			g_source_remove_ (w9T(idTimer))
			
			w9T(idTimer) = 0
			
		End Sub
		
		Function SetTimer(hwnd As Any Ptr = 0, ByRef idTimer As Long, iElapse As Long, pTimerProc As Any Ptr) As Long
			
			Dim As guint pTimer
			
			Dim As Long IDTimer_ = idTimer
			If idTimer = 0 Then IDTimer_ = 1
			
			If w9T(IDTimer_) <> 0 Then
				
				'KillTimer(0, IDTimer_)
				
			End If
			
			'		If pTimerProc = 0 Then
			'
			'			pTimer = g_timeout_add(iElapse , @timersfunc, @idTimer)
			'
			'		Else
			
			pTimer = g_timeout_add(iElapse, pTimerProc, @IDTimer_)
			
			'EndIf
			
			w9T(IDTimer_) = pTimer
			
			Return IDTimer_
			
		End Function
	#endif
	
	Sub DeleteDebugCursor
		If CurEC <> 0 Then
			Var curEC2 = CurEC
			fcurlig = -1
			CurEC->CurExecutedLine = -1
			CurEC = 0
			curEC2->Repaint
		End If
	End Sub
	
	Function GetPartPath(sPath As String) As String
		
		Dim As Long iPos = InStrRev(sPath , "/")
		
		Return Left(sPath , iPos - 1)
		
	End Function
	
	Function CreatePipeD(szCmd As WString Ptr, szCmdParam As WString Ptr = 0 , szCmdParam2 As WString Ptr = 0) As pid_t
		
		#ifdef __FB_WIN32__
			
			Dim As STARTUPINFO si
			Dim As PROCESS_INFORMATION pi
			Dim As SECURITY_ATTRIBUTES sa
			Dim As HANDLE hReadChildPipe,hWriteChildPipe
			sa.nLength = Len(sa)
			sa.lpSecurityDescriptor = NULL
			sa.bInheritHandle = True
			
			If CreatePipe(@hReadChildPipe, @hWritePipe, @sa, 0) = 0 Then
				MessageBox(0, "Error creation pipe 1", "", MB_ICONERROR)
			End If
			
			If SetHandleInformation(hWritePipe,HANDLE_FLAG_INHERIT,0) = 0 Then
				MessageBox(0, "Error installing the right not inheritance descriptors for 1 PIPE", "", MB_ICONERROR)
			End If
			
			If CreatePipe(@hReadPipe,@hWriteChildPipe,@sa,0) = 0 Then
				MessageBox(0, "Error creation pipe 2", "", MB_ICONERROR)
			End If
			
			If SetHandleInformation(hReadPipe,HANDLE_FLAG_INHERIT,0) = 0 Then
				MessageBox(0, "Error installing the right not inheritance descriptors for 2 PIPE", "", MB_ICONERROR)
			End If
			
			GetStartupInfo(@si)
			si.dwFlags = STARTF_USESTDHANDLES Or STARTF_USESHOWWINDOW
			si.wShowWindow = SW_SHOW
			si.hStdOutput  = hWriteChildPipe
			si.hStdError   = hWriteChildPipe
			si.hStdInput   = hReadChildPipe
			
			If CreateProcess(0, *szCmd & " " & *szCmdParam & " " & *szCmdParam2, 0, 0, True, DETACHED_PROCESS, 0, 0, @si, @pi) = 0 Then
				MessageBox(0,"Error creating a child process","",MB_ICONERROR)
			End If
			CloseHandle(hWriteChildPipe)
			CloseHandle(hReadChildPipe)
			'Sleep(300)
			Return pi.dwProcessId
			
		#else
			
			If szCmdParam2 AndAlso Len(*szCmdParam2) Then
				
				Dim As String sPath = Replace(*szCmdParam2 , " ", "\ ", , , 1)
				
				ChDir(GetPartPath(sPath))
				
			End If
			
			If pipe_(@iReadPipe(0)) < 0 OrElse pipe_(@iWritePipe(0)) < 0 Then Return 0
			
			If fcntl(iReadPipe(0), F_SETFL, O_NONBLOCK) < 0 Then Return 0
			
			pid = fork()
			
			If pid = 0 Then
				
				close_(iWritePipe(1))
				
				close_(iReadPipe(0))
				
				If dup2(iWritePipe(0), STDIN_FILENO) = -1 Then Return 0
				
				close_(iWritePipe(0))
				
				If dup2(iReadPipe(1), STDOUT_FILENO) = -1 Then Return 0
				
				close_(iReadPipe(1))
				
				Dim As ZString * 1000 szCmd_ = *szCmd, szCmdParam_ = *szCmdParam, szCmdParam2_ = *szCmdParam2
				
				If LCase(szCmd_) = "gdb" Then szCmd_ = "usr/bin/gdb"
				
				If szCmdParam  Then
					
					execl(@szCmd_, @szCmd_, @szCmdParam_, @szCmdParam2_, NULL)
					
				Else
					
					execl(@szCmd_, @szCmd_, NULL)
					
				End If
				
			ElseIf pid > 0 Then
				
				Function = pid
				
				close_(iWritePipe(0))
				
				close_(iReadPipe(1))
				
				pIn = iReadPipe(0)
				
				pOut = iWritePipe(1)
				
			End If
			
			Sleep(300)
			
		#endif
		
	End Function
	
	Function readpipe(WithoutAnswer As Boolean = False) As String
		
		Dim As String sRet
		
		#ifdef __FB_WIN32__
			
			#define BufferSize 2048
			Dim As Integer Count
			Dim sBuffer As ZString * BufferSize
			Dim sOutput As UString
			Dim bytesRead As DWORD
			Dim result_ As Integer
			Dim s As String = ""
			Dim As Integer iNumberOfBytesWritten
			Do
				result_ = ReadFile(hReadPipe, @sBuffer, BufferSize, @bytesRead, ByVal 0)
				sBuffer = Left(sBuffer, bytesRead)
				sOutput += sBuffer
				Count = Count + 1
				If sBuffer = "--Type <RET> for more, q to quit, c to continue without paging--" Then
					writepipe !"\n"
				End If
				ShowMessages sBuffer, False
				'?sBuffer
			Loop While Not (CBool(InStr(sOutput, Chr(10) & "(gdb) ")) OrElse CBool(InStr(sOutput, "~*~(gdb) ")) OrElse IIf(WithoutAnswer, CBool(sOutput = "(gdb) "), StartsWith(sOutput, "(gdb) ") AndAlso CBool(Len(sOutput) > 6 OrElse Count > 1)))
			'WriteFile(hWritePipe, @s, Len(s), Cast(Any Ptr, @iNumberOfBytesWritten), NULL) =  '
			sRet = sOutput
			
			'		Dim As Integer iTotalBytesAvail,iNumberOfBytesWritten
			'		Dim As String sRet
			'		Static As ZString * 50000 sBuf
			'		For i As Long = 0 To 10000
			'			PeekNamedPipe(hReadPipe, NULL, NULL, NULL, Cast(Any Ptr, @iTotalBytesAvail), NULL)
			'			If iTotalBytesAvail > 0 Then
			'				While iTotalBytesAvail > 0
			'					iTotalBytesAvail = IIf(iTotalBytesAvail > 49999, 49999, iTotalBytesAvail)
			'					memset(@sBuf, 0, 50000)
			'					ReadFile(hReadPipe, @sBuf, iTotalBytesAvail, Cast(Any Ptr, @iNumberOfBytesWritten), NULL)
			'					sRet &= Left(sBuf, iNumberOfBytesWritten)
			'					For i As Long = 0 To 10000
			'						PeekNamedPipe(hReadPipe, NULL, NULL, NULL, Cast(Any Ptr, @iTotalBytesAvail), NULL)
			'						If iTotalBytesAvail Then Exit For
			'					Next
			'				Wend
			'				Return Trim(sRet)
			'			End If
			'		Next
			
		#else
			
			Dim As Integer Count
			
			Dim As Integer iTotalBytesAvail
			
			Dim As ZString Ptr pszTempBuf
			
			Dim As pollfd pfds(0)
			
			Dim sOutput As String
			
			Do
				
				pfds(0).fd = pIn
				
				pfds(0).events = 1
				
				poll(@pfds(0), 1, 30)
				
				If pfds(0).revents And 1 Then
					
					ioctl(pIn, FIONREAD, @iTotalBytesAvail)
					
					If iTotalBytesAvail>0 Then
						
						pszTempBuf = CAllocate(iTotalBytesAvail+1)
						
						read_(pIn, pszTempBuf, iTotalBytesAvail)
						
						If Len(*pszTempBuf) Then
							
							sOutput &= *pszTempBuf
							
							If *pszTempBuf = "--Type <RET> for more, q to quit, c to continue without paging--" Then
								
								writepipe !"\n"
								
							ElseIf *pszTempBuf <> "" Then
								
								'?*pszTempBuf
								
							End If
							
						End If
						
						Deallocate(pszTempBuf)
						
					End If
					
				End If
				
				Count = Count + 1
				
			Loop While Not (CBool(InStr(sOutput, Chr(10) & "(gdb) ")) OrElse CBool(InStr(sOutput, "~*~(gdb) ")) OrElse IIf(WithoutAnswer, CBool(sOutput = "(gdb) "), StartsWith(sOutput, "(gdb) ") AndAlso CBool(Len(sOutput) > 6 OrElse Count > 1)))
			
			sRet = sOutput
			
		#endif
		
		Return sRet
		
	End Function
	
	#ifdef __FB_WIN32__
		
		Sub Writepipe(ByRef s As ZString, iTime As Long = 30)
			Dim As Integer iNumberOfBytesWritten
			WriteFile(hWritePipe, @s, Len(s), Cast(Any Ptr, @iNumberOfBytesWritten), NULL)
			'Sleep (iTime)
		End Sub
		
	#else
		
		Sub writepipe(ByRef szBuf As ZString, iTime As Long = 1)
			
			write_(pOut, @szBuf, Len(szBuf))
			
			'Updateinfoxserver
			
			'Sleep(iTime)
			
		End Sub
		
		Sub writepipefast(ByRef szBuf As ZString, iTime As Long = 1)
			
			write_(pOut , @szBuf , Len(szBuf))
			
			'Sleep(iTime)
			
		End Sub
		
	#endif
	
	#ifdef __FB_WIN32__
		
		#undef Updateinfoxserver
		Declare Sub Updateinfoxserver(ic As Long=100)
		Sub Updateinfoxserver(ic As Long=100)
			
			For i As Long = 0 To ic
				
				pApp->DoEvents
				
				If ic <= 100 Then
					
					Sleep 1
					
				End If
				
			Next
			
		End Sub
		
	#endif
	
	Sub run_pipe_write(ByRef s As WString , iTime As Long = 1)
		
		'killtimer(0, TimerID)
		
		Writepipe(s, iTime)
		
		'TimerID = settimer(0, 0, 20, Cast(Any Ptr, @timer_data))
		
	End Sub
	
	Sub paste_updatevar(iFlagStepParam As Long , iFupd As Long)
		
		If iFlagStepParam = 1 Then
			
			Dim As Long iF1 = InStr(szDataForPipe , "~*~")
			
			If iF1 Then
				
				'Pasteeditor(E_EDITOR, Mid(szDataForPipe , 1 , iF1-1))
				
				ThreadsEnter
				
				ShowMessages Replace(Mid(szDataForPipe, 1, iF1 - 1), Chr(26), "→"), False
				
				fill_locals_variables(Mid(szDataForPipe, iF1 + 3), 1)
				
				ThreadsLeave
				
			Else
				
				ThreadsEnter
				'Pasteeditor(E_EDITOR, szDataForPipe)
				If Len(Trim(szDataForPipe)) Then ShowMessages szDataForPipe, False
				
				ThreadsLeave
				
			End If
			
		ElseIf iFlagStepParam = 2 Then
			
			Dim As Long iF1 = InStr(szDataForPipe , "~*~")
			
			Dim As Long iF2 = InStr(szDataForPipe , "~^~")
			
			If iF1 Then
				
				ThreadsEnter
				'Pasteeditor(E_EDITOR, Mid(szDataForPipe , 1 , iF1-1))
				ShowMessages Mid(szDataForPipe , 1 , iF1 - 1), False
				
				fill_all_variables(Mid(szDataForPipe, iF1))
				
				ThreadsLeave
				
			ElseIf iF2 Then
				
				ThreadsEnter
				'Pasteeditor(E_EDITOR, Mid(szDataForPipe , 1 , iF2-1))
				ShowMessages Mid(szDataForPipe , 1 , iF2 - 1), False
				
				fill_all_variables(Mid(szDataForPipe , iF2 + 3))
				
				ThreadsLeave
				
			Else
				
				ThreadsEnter
				'Pasteeditor(E_EDITOR, szDataForPipe)
				If Len(Trim(szDataForPipe)) Then ShowMessages szDataForPipe, False
				
				ThreadsLeave
				
			End If
			
		Else
			
			If iStateMenu = 1 Then
				
				Dim As Long iF1 = InStr(szDataForPipe , "~*~")
				
				If iF1 Then
					
					ThreadsEnter
					'Pasteeditor(E_EDITOR, Mid(szDataForPipe , 1 , iF1-1))
					ShowMessages Replace(Mid(szDataForPipe, 1, iF1 - 1), Chr(26), "→"), False
					
					fill_locals_variables(Mid(szDataForPipe, iF1 + 3), 1)
					
					ThreadsLeave
					
				Else
					
					ThreadsEnter
					'Pasteeditor(E_EDITOR, szDataForPipe)
					If Len(Trim(szDataForPipe)) Then ShowMessages szDataForPipe, False
					
					ThreadsLeave
					
					If iFupd Then
						
						iFlagUpdateVariables = 1
						
						iCounterUpdateVariables = 0
						
					End If
					
				End If
				
			ElseIf iStateMenu = 2 Then
				
				Dim As Long iF1 = InStr(szDataForPipe , "~*~")
				
				Dim As Long iF2 = InStr(szDataForPipe , "~^~")
				
				If iF1 Then
					
					ThreadsEnter
					'Pasteeditor(E_EDITOR, Mid(szDataForPipe , 1 , iF1 - 1))
					ShowMessages Mid(szDataForPipe , 1 , iF1 - 1), False
					
					fill_all_variables(Mid(szDataForPipe , iF1))
					
					ThreadsLeave
					
				ElseIf iF2 Then
					
					ThreadsEnter
					'Pasteeditor(E_EDITOR, Mid(szDataForPipe , 1 , iF2-1))
					ShowMessages Mid(szDataForPipe , 1 , iF2 - 1), False
					
					fill_all_variables(Mid(szDataForPipe , iF2 + 3))
					
					ThreadsLeave
					
				Else
					
					ThreadsEnter
					'Pasteeditor(E_EDITOR, szDataForPipe)
					If Len(Trim(szDataForPipe)) Then ShowMessages szDataForPipe, False
					
					ThreadsLeave
					
					If iFupd Then
						
						iFlagUpdateVariables = 1
						
						iCounterUpdateVariables = 0
						
					End If
					
				End If
				
			Else
				
				ThreadsEnter
				'Pasteeditor(E_EDITOR, szDataForPipe)
				If Len(Trim(szDataForPipe)) Then ShowMessages szDataForPipe, False
				
				ThreadsLeave
				
				If iFupd Then
					
					iFlagUpdateVariables = 1
					
					iCounterUpdateVariables = 0
					
				End If
				
			End If
			
		End If
		
	End Sub
	
	Function line_highlight(iFlagStepParam As Long = 0) As Long
		
		Dim As Long iFind = InStr(szDataForPipe, Chr(26, 26))
		
		If iFind Then
			
			#ifdef __FB_WIN32__
				
				Dim As Long iFindColon = InStr(iFind , szDataForPipe , ":\")
				
				If iFindColon Then
					iFindColon = InStr(iFindColon+1 , szDataForPipe , ":")
					
				Else
					iFindColon = InStr(iFind , szDataForPipe , ":")
					
				End If
				
			#else
				
				Dim As Long iFindColon = InStr(iFind , szDataForPipe , ":")
				
			#endif
			
			If iFindColon Then
				
				Dim As String sFile = Mid(szDataForPipe , iFind+2 , iFindColon - (iFind+2))
				
				Dim As String sPos , sLine
				
				Dim As Long iFindColon2 = InStr(iFindColon+1 , szDataForPipe , ":")
				
				If iFindColon2 Then
					
					sLine = Mid(szDataForPipe , iFindColon+1 , iFindColon2 - (iFindColon+1))
					
					Dim As Long iFindColon3 = InStr(iFindColon2+1 , szDataForPipe , ":")
					
					If iFindColon3 Then
						
						sPos = Mid(szDataForPipe , iFindColon2 + 1 , iFindColon3 - (iFindColon2 + 1))
						
					End If
					
				End If
				
				If Len(sFile) AndAlso Len(sPos) AndAlso Len(sLine) Then
					'				If LimitDebug Then
					'					?sFile
					'				End If
					CurrentFile = sFile
					fcurlig = Val(sLine)
					'				Dim As TabWindow Ptr tb = AddTab(sFile)
					'				If tb Then
					'					ChangeEnabledDebug True, False, True
					'					CurEC = @tb->txtCode
					'					tb->txtCode.CurExecutedLine = Val(sLine) - 1
					'					tb->txtCode.SetSelection Val(sLine) - 1, Val(sLine) - 1, 0, 0
					'					tb->txtCode.PaintControl
					'					info_all_variables_debug()
					'					#ifdef __FB_WIN32__
					'						SetForegroundWindow pApp->MainForm->Handle
					'					#endif
					'				End If
					
					'				For i As Long = 0 To UBound(sfiles_array)
					'
					'					If sfiles_array(i) = sFile Then
					'
					'						Panelgadgetsetcursel(E_PANEL , i)
					'
					'						selection_line(i , Val(sPos) , Val(sLine))
					'
					'						Setselecttexteditorgadget(E_EDITOR, -1 ,-1)
					
					paste_updatevar(iFlagStepParam , 1)
					'
					'						Linescrolleditor(E_EDITOR,10000000)
					'
					Return 1
					'
					'					EndIf
					'
					'				Next
					
				End If
				
			End If
			
		Else
			
			Dim As String s = Trim(szDataForPipe)
			
			If Len(s) Then
				
				If s <> "(gdb)" AndAlso s <> "Continuing." _
					AndAlso InStr(s , "[Inferior 1") = 0 _
					AndAlso InStr(s , "Using the running image of child") = 0  Then
					
					'				Setselecttexteditorgadget(E_EDITOR, -1 ,-1)
					'
					paste_updatevar(0 , 0)
					'
					'				Linescrolleditor(E_EDITOR,10000000)
					
					Return 1
					
				Else
					
					If InStr(s , "[Inferior 1") Then
						
						'					Setselecttexteditorgadget(E_EDITOR, -1 ,-1)
						'
						paste_updatevar(iFlagStepParam , 0)
						'
						'					Linescrolleditor(E_EDITOR,10000000)
						'
						ThreadsEnter
						
						deinit
						
						'ShowMessages(Time & ": " & ML("Application finished. Returned code") & ": 0 - " & Err2Description(0))
						
						ThreadsLeave()
						
						Return 1
						
					End If
					
				End If
				
			End If
			
		End If
		
	End Function
	
	Dim Shared As ZString * 3 sEndOfLine
	
	#ifdef __FB_WIN32__
		sEndOfLine = Chr(13) & Chr(10)
	#else
		sEndOfLine  = Chr(10)
	#endif
	
	Declare Sub kill_debug()
	Declare Sub get_read_data(iFlag As Long , iFlagAutoUpdate As Long = 0)
	
	Function timer_data() As Integer
		
		Static As Long iReset , iReset2
		
		'?iFlagThreadSignal
		
		'If szDataForPipe <> "" Then ?szDataForPipe
		
		If iFlagThreadSignal = 10 Then
			
			iFlagThreadSignal = 4
			
			Dim As Long iFind = InStr(szDataForPipe , "[Inferior 1")
			
			Dim As Long iFind2 = InStr(szDataForPipe , "The program being debugged is not being run.")
			
			If iFind Then
				
				Dim As Long iFind10 = InStr(iFind , szDataForPipe , sEndOfLine)
				
				Dim As String s
				
				If iFind10 Then
					
					s = Mid(szDataForPipe , iFind , iFind10-iFind)
					
				Else
					
					s = Mid(szDataForPipe , iFind)
					
				End If
				
				kill_debug()
				
				'killtimer(0, TimerID)
				
				'			Setselecttexteditorgadget(E_EDITOR, -1 ,-1)
				'
				'			Pasteeditor(E_EDITOR, s)
				ShowMessages s
				'
				'			Linescrolleditor(E_EDITOR,10000000)
				
			ElseIf iFind2 Then
				
				kill_debug()
				
				'killtimer(0, TimerID)
				
			Else
				
				line_highlight()
				
				If Len(szDataForPipe) AndAlso InStr(szDataForPipe , "Using the running image of child") = 0 Then
					
					'				Setselecttexteditorgadget(E_EDITOR, -1 ,-1)
					'
					'				Pasteeditor(E_EDITOR, szDataForPipe)
					ShowMessages szDataForPipe
					'
					'				Linescrolleditor(E_EDITOR, 10000000)
					
				End If
				
			End If
			
			iReset = 0
			
		ElseIf iFlagThreadSignal = 11 Then
			
			iFlagThreadSignal = 0
			
			If Len(szDataForPipe) Then
				
				Dim As Long iFind2 = InStr(szDataForPipe , "The program being debugged is not being run.")
				
				If iFind2 Then
					
					kill_debug()
					
					'killtimer(0, TimerID)
					
				Else
					
					If line_highlight() = 0 Then
						
						'Setselecttexteditorgadget(E_EDITOR, -1 , -1)
						
						'Pasteeditor(E_EDITOR, szDataForPipe)
						ShowMessages szDataForPipe
						
						'Linescrolleditor(E_EDITOR,10000000)
						
					End If
					
				End If
				
			End If
			
		ElseIf iFlagThreadSignal = 13 Then
			
			If iReset2 >= 10 Then
				
				memset(@szDataForPipe , 0 , 200000)
				
				get_read_data(11)
				
				iReset2 = 0
				
			Else
				
				iReset2+=1
				
			End If
			
		Else
			
			If iFlagThreadSignal Then Return True
			
			If iReset >= 20 Then
				
				iFlagThreadSignal = 0
				
				memset(@szDataForPipe , 0 , 200000)
				
				run_pipe_write(!"info program\n")
				
				get_read_data(10)
				
				iReset = 0
				
			Else
				
				iFlagThreadSignal = 0
				
				memset(@szDataForPipe , 0 , 200000)
				
				get_read_data(11)
				
				iReset+=1
				
			End If
			
		End If
		
		Select Case iFlagThreadSignal
			
		Case 4
			
			iFlagThreadSignal = 0
			
		End Select
		
		'Return True
		
	End Function
	
	Type TGLOBALSVAR
		
		As ZString*1024 szPath
		
		As ZString*256 szVar
		
	End Type
	ReDim Shared As TGLOBALSVAR tgl_var_array(2000)
	
	Sub set_macroses()
		
		Dim As String sMacroGLB
		
		For i As Long = 0 To UBound(tgl_var_array)
			
			If Len(tgl_var_array(i).szVar) Then
				
				iFlagThreadSignal = 0
				
				Dim As Long iF1 = InStrRev(tgl_var_array(i).szVar , " ")
				
				Dim As Long iF2 = InStr(iF1 , tgl_var_array(i).szVar , "[")
				
				If iF2 = 0 Then
					
					iF2 = InStr(iF1 , tgl_var_array(i).szVar , ";")
					
				End If
				
				If iF1 AndAlso iF2 Then
					
					Dim As String sVarTemp = Mid(tgl_var_array(i).szVar , iF1+1 , iF2 - (iF1+1))
					
					sVarTemp = Trim(sVarTemp , Any "* ")
					
					If Len(sVarTemp) Then
						
						sMacroGLB &= !"printf ""~*~""\np " & sVarTemp & !"\n"
						
					End If
					
				End If
				
			Else
				
				Exit For
				
			End If
			
		Next
		
		If Len(sMacroGLB) Then
			
			sMacroGLB &= !"printf ""~*~globalends~*~""\ninfo args\ninfo locals\n"
			
		Else
			
			sMacroGLB = !"printf ""~^~""\ninfo args\ninfo locals\n"
			
		End If
		
		Dim As String s = !"define _g_\n" & sMacroGLB & !"end\n"
		
		Writepipe(s, 100)
		
		'readpipe()
		
		'Updateinfoxserver(10)
		
		s = !"define _l_\ninfo args\ninfo locals\nend\n"
		
		Writepipe(s, 100)
		
		'readpipe()
		
		'Updateinfoxserver(10)
		
		s = !"define _sg_\ns\n_g_\nend\n"
		
		Writepipe(s, 100)
		
		'readpipe()
		
		'Updateinfoxserver(10)
		
		s = !"define _sl_\ns\nprintf ""~*~""\n_l_\nend\n"
		
		writepipe(s, 100)
		
		'readpipe()
		
		'Updateinfoxserver(10)
		
		s = !"define _ng_\nn\n_g_\nend\n"
		
		writepipe(s, 100)
		
		'readpipe()
		
		'Updateinfoxserver(10)
		
		s = !"define _nl_\nn\nprintf ""~*~""\n_l_\nend\n"
		
		writepipe(s, 100)
		
		'readpipe()
		
		'Updateinfoxserver(10)
		
	End Sub
	
	Function get_global_variables_from_exe(sBuf As String) As Long
		
		Dim As Long iBegin = 1 , iVarFlag , iIndex
		
		Dim As String sFile
		
		Do
			
			Dim As String sLine
			
			Dim As Long iFind = InStr(iBegin , sBuf , Chr(10))
			
			If iFind Then
				
				sLine = Mid(sBuf , iBegin , iFind - iBegin)
				
				If Left(sLine , 5) = "File " Then
					
					sFile = Trim(Mid(sBuf , iBegin+5 , iFind - (iBegin+5)) , Any sEndOfLine & " :")
					
					If LCase(Right(sFile , 4)) = ".bas" OrElse LCase(Right(sFile , 3)) = ".bi" Then
					Else
						sFile = ""
					End If
					
					iVarFlag = 1
					
				ElseIf InStr(sLine , "Non-debugging symbols:") Then
					
					Exit Do
					
				ElseIf iVarFlag = 1 AndAlso Len(sLine) AndAlso Len(sFile) AndAlso sLine <> Chr(13) AndAlso sLine <> Chr(10) Then
					
					If iIndex > UBound(tgl_var_array) Then
						
						ReDim Preserve As TGLOBALSVAR tgl_var_array(iIndex+1000)
						
					End If
					
					If iVersionGdb >= 10 Then
						
						Dim As Long iF1 = InStr(sLine , ":" & Chr(9))
						
						If iF1 Then
							
							sLine = Mid(sLine , iF1+2)
							
						End If
						
					End If
					
					tgl_var_array(iIndex).szPath = sFile
					
					tgl_var_array(iIndex).szVar = sLine
					
					If StartsWith(sLine, "static ") Then sLine = Mid(sLine, 8)
					Var Pos0 = InStr(sLine, ";")
					If Pos0 > 0 Then sLine = Left(sLine, Pos0 - 1)
					Var Pos1 = InStr(sLine, " ")
					Var Pos2 = InStr(sLine, " *")
					If Pos2 > 0 Then Pos1 = Pos2 + 1
					Dim As String VarName = Mid(sLine, Pos1 + 1)
					If StartsWith(VarName, "__Z") Then
						Var Pos3 = InStr(VarName, "[")
						If Pos3 > 0 Then
							VarName = cutup_names(Left(VarName, Pos3 - 1)) & Mid(VarName, Pos3)
						Else
							VarName = cutup_names(VarName)
						End If
					End If
					Var tn = lvGlobals.Nodes.Add(VarName)
					If Pos2 = 0 Then
						tn->Text(2) = Trim(Left(sLine, Pos1 - 1))
					Else
						tn->Text(2) = Trim(Left(sLine, Pos1 - 1)) & " Ptr"
					End If
					
					iIndex+=1
					
				End If
				
				iBegin = iFind+1
				
			Else
				
				Exit Do
				
			End If
			
		Loop
		
		tpGlobals->Caption = ML("Globals") & " (" & lvGlobals.Nodes.Count & " " & ML("Pos") & ")"
		
		Return iIndex
		
	End Function
	
	Function get_str(sBuf As String , ByRef iBegin As Long) As String
		
		Dim As Long iFind = InStr(iBegin , sBuf , sEndOfLine)
		
		If iFind Then
			
			Function = Mid(sBuf , iBegin , iFind - iBegin)
			
			iBegin = iFind + Len(sEndOfLine)
			
		Else
			
			iBegin = iFind
			
		End If
		
	End Function
	
	Function get_type_str(sLine As String) As Long
		
		#ifdef __FB_64BIT__
			
			Dim As Long iFindSpace = InStr(sLine , " ")
			
			If InStr(Mid(sLine , 1 , iFindSpace) , "$") Then
				
				Return 1
				
			ElseIf InStr(sLine , "(gdb)") OrElse InStr(sLine , "No locals.") Then
				
				Return 0
				
			Else
				
				Return 2
				
			End If
			
		#else
			
			Dim As Long iFindSpace = InStr(sLine , " ")
			
			If iFindSpace > 1 Then
				
				Return 1
				
			ElseIf InStr(sLine , "(gdb)") OrElse InStr(sLine , "No locals.") Then
				
				Return 0
				
			Else
				
				Return 2
				
			End If
			
		#endif
	End Function
	
	Function fill_threads(sBuf As String, iFlagAutoUpdate As Long = 0) As Long
		
		lvThreads.Nodes.Clear
		
		Dim As UString res()
		
		#ifdef __USE_GTK__
			Split(sBuf, Chr(10), res())
		#else
			Split(sBuf, Chr(13, 10), res())
		#endif
		
		For i As Integer = 0 To UBound(res)
			
			If StartsWith(res(i), "Thread") Then
				lvThreads.Nodes.Insert 0, res(i)
			ElseIf StartsWith(res(i), "#") Then
				Var Pos0 = InStr(res(i), " ")
				Var Pos1 = InStr(res(i), " at ")
				If Pos1 > 0 Then
					Var Pos2 = InStrRev(res(i), ":")
					Var tn = lvThreads.Nodes.Item(0)->Nodes.Add(Mid(Left(res(i), Pos1 - 1), Pos0 + 1))
					tn->Text(1) = Mid(res(i), Pos2 + 1)
					tn->Text(2) = GetFullPath(Mid(res(i), Pos1 + 4, Pos2 - Pos1 - 4))
				Else
					lvThreads.Nodes.Item(0)->Nodes.Add Mid(res(i), Pos0 + 1)
				End If
			End If
			
		Next
		
		lvThreads.ExpandAll
		tpThreads->Caption = ML("Threads") & " (" & lvThreads.Nodes.Count & " " & ML("Pos") & ")"
		
		Return 1
		
	End Function
	
	Function fill_locals_variables(sBuf As String , iFlagAutoUpdate As Long = 0) As Long
		
		Dim As Long iBegin = 1 , iBegLast , iType , iFlagStart
		
		Dim As String sNameVar , sValueVar , sBackup , sBufTemp
		
		Static As String sPrevBuf
		
		If iFlagAutoUpdate Then
			
			Dim As Long iLen1 = Len(sBuf) , iLen2 = Len(sPrevBuf)
			
			If iLen1 = iLen2 Then
				
				If memcmp(StrPtr(sBuf) , StrPtr(sPrevBuf) , iLen1) = 0 Then
					
					Return 0
					
				End If
				
			End If
			
			'Deletelistviewitemsall(E_LISTVIEW)
			
			sPrevBuf = sBuf
			
		End If
		
		lvLocals.Nodes.Clear
		
		Dim As Long iCountItems = lvLocals.Nodes.Count, iItem 'Getitemcountlistview(E_LISTVIEW)
		
		If Len(sBuf) = 0 Then Return 0
		
		If Left(sBuf , 13) = "No arguments." Then
			
			sBufTemp = LTrim(Mid(sBuf , 14) , Any Chr(13) & Chr(10) & Chr(9) & " ")
			
		Else
			
			sBufTemp = sBuf
			
		End If
		
		If iCountItems Then
			
			iItem = iCountItems
			
		End If
		
		Do
			
			Dim As String sLine , sNextLine
			
			Do
				
				If iFlagStart Then
					
					If Len(sLine) AndAlso Len(sNextLine) AndAlso iType = 2 Then
						
						sLine &= (sEndOfLine & sNextLine)
						
					ElseIf Len(sLine) = 0 AndAlso Len(sBackup) AndAlso iType = 1 Then
						
						sLine = sBackup
						
					ElseIf iType = 1 Then
						
						sBackup = sNextLine
						
						Exit Do
						
					Else
						
						Exit Do
						
					End If
					
				Else
					
					iFlagStart = 1
					
				End If
				
				sNextLine = get_str(sBufTemp , iBegin)
				
				If Len(sNextLine) Then
					
					iType = get_type_str(sNextLine)
					
				End If
				
				If iBegin = 0 Then
					
					Exit Do
					
				End If
				
			Loop
			
			If iBegLast <> iBegin Then
				
				If Len(sLine) Then
					
					Dim As Long iFindEQ = InStr(sLine , " = ")
					
					sNameVar = Mid(sLine , 1 , iFindEQ - 1)
					
					sValueVar = Mid(sLine , iFindEQ+3)
					
					If iFindEQ Then
						
						Dim As TreeListViewItem Ptr tn
						
						Var Idx = lvLocals.Nodes.IndexOf(sNameVar)
						
						If Idx = -1 Then
							
							tn = lvLocals.Nodes.Add(sNameVar)
							
						Else
							
							tn = lvLocals.Nodes.Item(Idx)
							
						End If
						
						tn->Text(1) = sValueVar
						
						Var Pos1 = InStr(sValueVar, "<vtable for ")
						
						Var Pos2 = InStr(sValueVar, "+")
						
						If Pos1 > 0 AndAlso Pos2 > 0 Then
							
							tn->Text(2) = Replace(Mid(sValueVar, Pos1 + 12, Pos2 - Pos1 - 12), "::", ".")
							
						End If
						
						If StartsWith(sValueVar, "{") AndAlso tn->Nodes.Count = 0 Then
							
							tn->Nodes.Add ""
							
						End If
						
						'					Addlistviewitem(E_LISTVIEW , sNameVar , 0 , iItem , 0)
						'
						'					Addlistviewitem(E_LISTVIEW , sValueVar , 0 , iItem , 1)
						
						iItem+=1
						
					End If
					
				End If
				
				If iBegin Then
					
					iBegLast = iBegin
					
					If iType = 0 Then
						
						Exit Do
						
					End If
					
				Else
					
					Exit Do
					
				End If
				
			Else
				
				Exit Do
				
			End If
			
		Loop
		
		tpLocals->Caption = ML("Locals") & " (" & lvLocals.Nodes.Count & " " & ML("Pos") & ")"
		
		Return 1
		
	End Function
	
	Sub fill_all_variables(sBuf As String , iFlagUpdate As Long = 0)
		
		Static As String sPrevBuf
		
		If iFlagUpdate Then
			
			'lvVar.Nodes.Clear
			
		Else
			
			If lvGlobals.Nodes.Count Then
				'If Getitemcountlistview(E_LISTVIEW) Then
				
				Dim As Long iLen1 = Len(sBuf) , iLen2 = Len(sPrevBuf)
				
				If iLen1 = iLen2 Then
					
					If memcmp(StrPtr(sBuf) , StrPtr(sPrevBuf) , iLen1) = 0 Then
						
						Exit Sub
						
					End If
					
				End If
				
				'lvVar.Nodes.Clear
				
			End If
			
		End If
		
		Dim As Long iF0 = InStr(sBuf , "~*~globalends~*~")
		
		Dim iItem As Long
		
		'If iF0 Then
		
		Dim As Long iF1 = 4 , iF2
		
		Do
			
			iF2 = InStr(iF1 , sBuf , "~*~")
			
			If iF2 Then
				
				Dim As String sTemp = Mid(sBuf , iF1 , iF2-iF1)
				
				iF1 = iF2+3
				
				Dim As Long iFindEQ = InStr(sTemp , " = ")
				
				If iFindEQ Then
					
					Dim As String sValueVar = Trim(Mid(sTemp , iFindEQ + 3) , Any Chr(13) & Chr(10) & " ")
					
					If iItem <= UBound(tgl_var_array) Then
						
						'						Addlistviewitem(E_LISTVIEW , tgl_var_array(iItem).szVar , 0 , iItem , 0)
						
						'Var Idx = lvGlobals.Nodes.IndexOf(tgl_var_array(iItem).szVar)
						
						'If Idx = -1 Then
						
						'	tn = lvGlobals.Nodes.Add(tgl_var_array(iItem).szVar)
						
						'Else
						
						'	tn = lvGlobals.Nodes.Item(Idx)
						
						'End If
						'
						'						Addlistviewitem(E_LISTVIEW , sValueVar , 0 , iItem , 1)
						
						If iItem < lvGlobals.Nodes.Count Then
							
							Var tn = lvGlobals.Nodes.Item(iItem)
							
							tn->Text(1) = sValueVar
							
							If StartsWith(sValueVar, "{") AndAlso tn->Nodes.Count = 0 Then
								
								tn->Nodes.Add ""
								
							End If
							
						Else
							
							Exit Do
							
						End If
						
						iItem +=1
						
					Else
						
						Exit Do
						
					End If
					
				Else
					
					Exit Do
					
				End If
				
			Else
				
				Exit Do
				
			End If
			
		Loop
		
		'		Dim As String s = Mid(sBuf , iF0+16)
		'
		'		ThreadsEnter
		'
		'		fill_locals_variables(s)
		'
		'		ThreadsLeave
		
		'	Else
		'
		'		If Left(sBuf , 3) = "~^~" Then
		'
		'			Dim As String s = Mid(sBuf , 4)
		'
		'			ThreadsEnter
		'
		'			fill_locals_variables(s)
		'
		'			ThreadsLeave
		'
		'		Else
		'
		'			ThreadsEnter
		'
		'			fill_locals_variables(sBuf)
		'
		'			ThreadsLeave
		'
		'		EndIf
		'
		'	EndIf
		
		sPrevBuf = sBuf
		
	End Sub
	
	'Function get_name_files_from_exe(sBuf As String) As Long
	'
	'	Dim As Long iBegin = 1 , iFlag , iIndex
	'
	'	Dim As String sMarker , sMarker0
	'
	'	#ifdef __FB_WIN32__
	'		If InStr(sBuf , Chr(13) & Chr(10)) Then
	'			sEndOfLine = Chr(13) & Chr(10)
	'		Else
	'			sEndOfLine = Chr(10)
	'		EndIf
	'	#endif
	'
	'	If iVersionGdb < 11 Then
	'
	'		sMarker = "Source files for which symbols will be read in on demand:"
	'
	'		sMarker0 = "Source files for which symbols have been read in:"
	'
	'	Else
	'
	'		sMarker = "(Full debug information has not yet been read for this file.)"
	'
	'	EndIf
	'
	'	Do
	'
	'		Dim As String sLine
	'
	'		Dim As Long iFind = InStr(iBegin , sBuf , sEndOfLine)
	'
	'		If iFind Then
	'
	'			sLine = Trim(Mid(sBuf , iBegin , iFind - iBegin), Any sEndOfLine & " ")
	'
	'			If sLine = sMarker0 Then
	'
	'				iFlag = 2
	'
	'			ElseIf sLine = sMarker Then
	'
	'				If Len(sfiles_array(0)) Then Exit Do
	'
	'				iFlag = 1
	'
	'			ElseIf iFlag AndAlso Len(sLine) Then
	'
	'				Dim As Long iB = 1 , iFC
	'
	'				Do
	'
	'					If iIndex > UBound(sfiles_array) Then
	'
	'						ReDim Preserve As String sfiles_array(iIndex+10)
	'
	'					EndIf
	'
	'					iFC = InStr(iB , sLine , ",")
	'
	'					If iFC Then
	'
	'						Dim As String s = Trim(Mid(sLine , iB , iFC - iB) ,Any ", " & sEndOfLine)
	'
	'						Dim As String sExt = LCase(Getextensionpart(s))
	'
	'						If Len(s) AndAlso (sExt = "bas" OrElse sExt = "bi") Then
	'
	'							sfiles_array(iIndex) = s
	'
	'							iIndex+=1
	'
	'						EndIf
	'
	'						iB = iFC+1
	'
	'					Else
	'
	'						Dim As String s = Trim(Mid(sLine , iB), Any ", " & sEndOfLine)
	'
	'						Dim As String sExt = LCase(Getextensionpart(s))
	'
	'						If Len(s) AndAlso (sExt = "bas" OrElse sExt = "bi") Then
	'
	'							sfiles_array(iIndex) = s
	'
	'						EndIf
	'
	'						Exit Do
	'
	'					EndIf
	'
	'				Loop
	'
	'			EndIf
	'
	'			iBegin = iFind+1
	'
	'		Else
	'
	'			Exit Do
	'
	'		EndIf
	'
	'	Loop
	'
	'	Return iIndex
	'
	'End Function
	
	'Function get_main_file_from_exe(sBuf As String) As Long
	'
	'	#ifdef __FB_64BIT__
	'		Dim As Long iFind = InStr(sBuf , "int32 main(int32, char **);")
	'	#else
	'		Dim As Long iFind = InStr(sBuf , "integer main(integer, char **);")
	'	#endif
	'
	'	If iFind Then
	'
	'		Dim As Long iFindMain = InStrRev(sBuf , "File " , iFind)
	'
	'		Dim As Long iFindchr10 = InStr(iFindMain , sBuf , sEndOfLine )
	'
	'		Dim As String sTemp = Trim(Mid(sBuf , iFindMain+5 , iFindchr10 - (iFindMain+5)) , Any ":" & sEndOfLine)
	'
	'		Dim As String sTemp2
	'
	'		#ifdef __FB_WIN32__
	'
	'			sTemp2 = Replace(sTemp , "/" , "\" , , 1)
	'
	'		#endif
	'
	'		If Len(sTemp) Then
	'
	'			For i As Long = 0 To UBound(sfiles_array)
	'
	'				If Len(sfiles_array(i)) AndAlso (sfiles_array(i) = sTemp OrElse sfiles_array(i) = sTemp2 OrElse Getfilepart(sfiles_array(i)) = sTemp) Then
	'
	'					iIndexMainFile = i
	'
	'					Function = 1
	'
	'					Exit For
	'
	'				EndIf
	'
	'			Next
	'
	'		EndIf
	'
	'	EndIf
	'
	'End Function
	
	Function get_version_gdb(s As String) As Long
		
		Dim As Long iF1 = InStr(s , "Copyright (C)")
		
		If iF1 Then
			
			Dim As Long iF2 = InStrRev(s , " " , iF1)
			
			If iF2 Then
				
				Dim As Long iF3 = InStr(iF2 , s , ".")
				
				If iF3 Then
					
					Dim As Long iVer = Val(Mid(s , iF2+1 , iF3 - (iF2+1)))
					
					Return iVer
					
				End If
				
			End If
			
		End If
		
	End Function
	
	Function load_file(ByRef sCurentFileExe As UString, ByRef sPathGDB As UString) As Long
		
		#ifdef __USE_GTK__
			If g_find_program_in_path(ToUtf8(sPathGDB)) = NULL Then
		#else
			If FileExists(sPathGDB) = 0 Then
		#endif
			
			ThreadsEnter
			
			MsgBox("File gdb not found or is not executable.", "Error!")
			
			ThreadsLeave
			
			Return -1
			
		End If
		
		If FileExists(sCurentFileExe) = 0 Then
			
			ThreadsEnter
			
			MsgBox("Source file is not executable.", "Error!")
			
			ThreadsLeave
			
			Return -1
			
		End If
		
		ThreadsEnter
		
		ShowMessages(ML("Wait, process loading..."))
		
		lvLocals.Nodes.Clear
		
		lvGlobals.Nodes.Clear
		
		ThreadsLeave
		
		'Updateinfoxserver(10)
		
		iGlPid = CreatePipeD(sPathGDB,  "-f" , sCurentFileExe )
		
		'Updateinfoxserver(150)
		
		Dim As String sTemp = readpipe()
		
		If Len(sTemp) Then
			
			iVersionGdb = get_version_gdb(sTemp)
			
		End If
		
		'Updateinfoxserver(30)
		
		Writepipe(!"set confirm off\n" , 100)
		
		'Updateinfoxserver(10)
		
		readpipe(True)
		
		'Updateinfoxserver(30)
		
		writepipe(!"set lang c\n" , 100)
		
		'Updateinfoxserver(10)
		
		readpipe(True)
		
		writepipe(!"set width 0\n" , 100)
		
		readpipe(True)
		
		writepipe(!"set height 0\n" , 100)
		
		readpipe(True)
		
		'Updateinfoxserver(10)
		
		'writepipe(!"info sources\n" , 100)
		
		'Updateinfoxserver(30)
		
		'sTemp = readpipe()
		
		'If Len(sTemp) Then
		
		'get_name_files_from_exe(sTemp)
		
		'EndIf
		
		'Updateinfoxserver(10)
		
		writepipe(!"info variables\n" , 100)
		
		'Updateinfoxserver(30)
		
		sTemp = readpipe()
		
		If Len(sTemp) Then
			
			get_global_variables_from_exe(sTemp)
			
		End If
		
		set_macroses()
		
		'Updateinfoxserver(60)
		
		'	writepipe(!"info functions\n" , 100)
		'
		'	Updateinfoxserver(10)
		'
		'	sTemp = readpipe()
		'
		'	If Len(sTemp) Then
		'
		'		get_main_file_from_exe(sTemp)
		'
		'		If iIndexMainFile <> 0 Then
		'
		'			Dim As String sTemp = sfiles_array(iIndexMainFile)
		'
		'			Dim As String sTemp2 = sfiles_array(0)
		'
		'			sfiles_array(0) = sTemp
		'
		'			sfiles_array(iIndexMainFile) = sTemp2
		'
		'			iIndexMainFile = 0
		'
		'		EndIf
		'
		'	EndIf
		
		'Setwindowtext(pd.mDLG , sFileTemp)
		
		'	Updateinfoxserver(5)
		
	End Function
	
	Sub set_bp(Temporary As Boolean = False)
		
		Dim As Long iFlagSetup
		
		Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		'	Dim As Long iCursel = Panelgadgetgetcursel(E_PANEL)
		
		If tb = 0 Then Exit Sub
		'	If iCursel > UBound(pd.sci) OrElse iCursel < 0 OrElse  iCursel > UBound(sfiles_array) Then Exit Sub
		
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		'	Dim As Integer iPos = sendmessage ( Cast(Any Ptr , pd.sci(iCursel)) ,  SCI_GETCURRENTPOS , 0 , 0)
		'
		'	Dim As Integer iLine = sendmessage ( Cast(Any Ptr , pd.sci(iCursel)) ,  SCI_LINEFROMPOSITION , iPos , 0)
		'
		Dim As String sTemp = """" & Replace(tb->FileName, "\", "/") & """:" & iSelEndLine + 1
		
		'	For i As Long = 0 To UBound(sBP)
		'
		'		If iFlagSetup = 0 AndAlso sBP(i) = sTemp Then
		'
		'			iFlagSetup = 1
		'
		'		EndIf
		'
		'		If iFlagSetup Then
		'
		'			If i <> UBound(sBP) Then sBP(i) = sBP(i+1)
		'
		'		EndIf
		'
		'	Next
		
		If Cast(EditControlLine Ptr, tb->txtCode.Content.Lines.Items[iSelEndLine])->Breakpoint Then
			
			If Not Temporary Then
				
				run_pipe_write(!"clear " & sTemp & !"\n")
				
				readpipe()
				
			End If
			
			'sendmessage ( Cast(Any Ptr , pd.sci(iCursel)) ,  SCI_MARKERDELETE , iLine , 0)
			
		ElseIf Temporary Then
			
			run_pipe_write(!"tbreak " & sTemp & !"\n")
			
			readpipe()
			
		Else
			
			run_pipe_write(!"break " & sTemp & !"\n")
			
			readpipe()
			
			'sendmessage ( Cast(Any Ptr , pd.sci(iCursel)) ,  SCI_MARKERADD , iLine , 0)
			
			'		For i As Long = 0 To UBound(sBP)
			'
			'			If Len(sBP(i)) = 0 Then
			'
			'				sBP(i) = sTemp
			'
			'				Exit For
			'
			'			EndIf
			'
			'		Next
			'
		End If
		
	End Sub
	
	'Sub selection_line(iCursel As Integer , iPos As Integer , iLine As Integer)
	'
	'	If iCursel > UBound(pd.sci) OrElse iCursel < 0 Then Exit Sub
	'
	'	sendmessage ( Cast(Any Ptr , pd.sci(iCurselLast)) ,  SCI_INDICATORCLEARRANGE , iPosStartLast , iPosEndLast - iPosStartLast)
	'
	'	Dim As Integer iEndPos = sendmessage ( Cast(Any Ptr , pd.sci(iCursel)) ,  SCI_GETLINEENDPOSITION , iLine-1 , 0)
	'
	'	iPosEndLast = iEndPos
	'
	'	iPosStartLast = iPos
	'
	'	iCurselLast = iCursel
	'
	'	sendmessage ( Cast(Any Ptr , pd.sci(iCursel)) ,  SCI_INDICATORFILLRANGE , iPos , iEndPos - iPos)
	'
	'	SendMessage(Cast(Any Ptr , pd.sci(iCursel)), SCI_SETFIRSTVISIBLELINE, iLine, 0)
	'
	'	If (iLine - Cast(Integer , SendMessage(Cast(Any Ptr , pd.sci(iCursel)), SCI_GETFIRSTVISIBLELINE, 0, 0)) + 5) >= (SendMessage(Cast(Any Ptr , pd.sci(iCursel)), SCI_LINESONSCREEN, 0, 0)) Then
	'
	'		SendMessage(Cast(Any Ptr , pd.sci(iCursel)), SCI_LINESCROLL, 0, Cast(Integer , 5))
	'
	'	Else
	'
	'		SendMessage(Cast(Any Ptr , pd.sci(iCursel)), SCI_LINESCROLL, 0, Cast(Integer ,-5))
	'
	'	End If
	'
	'End Sub
	
	Sub get_read_data(iFlag As Long , iFlagAutoUpdate As Long = 0)
		
		szDataForPipe = readpipe()
		
		If Len(szDataForPipe) Then
			
			Select Case iFlag
				
			Case 1
				
				line_highlight(iFlagAutoUpdate)
				
			Case 2
				
				ThreadsEnter
				
				fill_all_variables(szDataForPipe , iFlagAutoUpdate)
				
				ThreadsLeave
				
			Case 3
				
				ThreadsEnter
				
				fill_locals_variables(szDataForPipe , iFlagAutoUpdate)
				
				ThreadsLeave
				
			Case 4
				
				ThreadsEnter
				
				fill_threads(szDataForPipe , iFlagAutoUpdate)
				
				ThreadsLeave
				
			Case Else
				
				iFlagThreadSignal = iFlag
				
			End Select
			
		Else
			
			iFlagThreadSignal = 13
			
		End If
		
	End Sub
	
	Sub UpdateWatch(WatchIndex As Integer, Text As String)
		Dim As String Result = Text
		Var Pos1 = InStr(Result, "=")
		If Pos1 > 0 Then Result = Trim(Mid(Result, Pos1 + 1))
		If StartsWith(Result, "(gdb)") Then Result = Trim(Mid(Result, 6))
		#ifdef __USE_GTK__
			If StartsWith(Result, Chr(10)) Then Result = Trim(Mid(Result, 2))
		#else
			If StartsWith(Result, Chr(13, 10)) Then Result = Trim(Mid(Result, 3))
		#endif
		If EndsWith(Result, "(gdb)") Then Result = Trim(Left(Result, Len(Result) - 5))
		If EndsWith(Result, "(gdb) ") Then Result = Trim(Left(Result, Len(Result) - 6))
		#ifdef __USE_GTK__
			If EndsWith(Result, Chr(10)) Then Result = Trim(Left(Result, Len(Result) - 1))
		#else
			If EndsWith(Result, Chr(13, 10)) Then Result = Trim(Left(Result, Len(Result) - 2))
		#endif
		If Result = "" Then Result = "No symbol """ & UCase(lvWatches.Nodes.Item(WatchIndex)->Text(0)) & """ in current context."
		lvWatches.Nodes.Item(WatchIndex)->Text(1) = Result
		If StartsWith(Result, "{") Then lvWatches.Nodes.Item(WatchIndex)->Nodes.Add Else lvWatches.Nodes.Item(WatchIndex)->Nodes.Clear
	End Sub
	
	Sub run_debug(iFlag As Long)
		
		iFlagThreadSignal = 0
		
		If iFlag Then
			
			'#ifdef __FB_WIN32__
			
			iGlPid = 0
			
			'killtimer(0, TimerID)
			
			'If runtype = RTSTEP Then
			
			writepipe(!"b 1\n")
			
			readpipe()
			
			'End If
			
			If RunningToCursor Then
				Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
				If tb <> 0 Then
					Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
					tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
					writepipe("tbreak """ & Replace(tb->FileName, "\", "/") & """:" & Str(iSelEndLine + 1) & !"\n")
					readpipe()
				End If
				RunningToCursor = False
			End If
			
			Dim As TabWindow Ptr tb
			For jj As Integer = 0 To TabPanels.Count - 1
				Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
				For i As Integer = 0 To ptabCode->TabCount - 1
					tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
					For j As Integer = 0 To tb->txtCode.Content.Lines.Count - 1
						If Not Cast(EditControlLine Ptr, tb->txtCode.Content.Lines.Items[j])->Breakpoint Then Continue For
						
						writepipe(!"break """ & Replace(tb->FileName, "\", "/") & """:" & WStr(j + 1) & !"\n")
						readpipe()
					Next
				Next i
			Next jj
			'TimerID = settimer(0, 0, 20, Cast(Any Ptr, @timer_data))
			
			'#else
			
			'			Disablegadget(E_BUT_STEP_IN , 0)
			'
			'			Disablegadget(E_BUT_STEP_OUT , 0)
			'
			'			Disablegadget(E_BUT_CONTINUE , 0)
			'
			'			Disablegadget(E_BUT_KILL , 0)
			'
			'			Disablegadget(E_BUT_UPDATEL , 0)
			'
			'			Disablegadget(E_BUT_UPDATEGL , 0)
			'
			'			Disablegadget(E_BUT_COMMAND , 0)
			
			'#endif
			
			'run_pipe_write(!"r\n" , 300)
			Writepipe !"r\n"
			
			MutexLock tlockGDB
			Dim As String Result
			Dim As Boolean bGetPid = True
			Var Pos1 = 0
			Running = True
			Do
				'memset(@szDataForPipe , 0 , 200000)
				
				'get_read_data(1)
				
				If Running Then
					Result = readpipe(True)
					If bGetPid Then
						#ifdef __FB_WIN32__
							
							'Updateinfoxserver(10)
							
							'killtimer(0, TimerID)
							
							Writepipe(!"info inferiors\n")
							
							'Updateinfoxserver(10)
							
							Dim As String s = readpipe()
							Result = Result & s
							
							If Len(s) Then
								
								Dim As Long iF1 = InStr(s, " process ")
								
								If iF1 Then
									
									s = Trim(Mid(s , iF1+9))
									
									Dim As Long iF1 = InStr(s, " ")
									
									If iF1 Then
										
										s = Trim(Mid(s , 1 ,  iF1-1))
										
										iGlPid =  Val(s)
										
									End If
									
								End If
								
							End If
						#endif
						bGetPid = False
						If runtype <> RTSTEP Then
							writepipe(!"c\n")
							Running = True
							Continue Do
							'					Else
							'						Result = readpipe
						End If
					End If
					If ShowResult Then
						ShowMessages Result
						ShowResult = False
					End If
					szDataForPipe = Result
					Running = False
					If WatchIndex <> -1 Then
						ThreadsEnter
						UpdateWatch WatchIndex, Result
						ThreadsLeave
						WatchIndex = -1
					Else
						line_highlight iStateMenu
						If iFlagStartDebug = 0 Then Exit Do
						info_loc_variables_debug
						If iStateMenu = 2 Then
							info_all_variables_debug
						End If
						info_threads_debug
						ThreadsEnter
						For i As Integer = 0 To lvWatches.Nodes.Count - 1
							If Trim(lvWatches.Nodes.Item(i)->Text(0)) = "" Then Continue For
							writepipe "print " & UCase(lvWatches.Nodes.Item(i)->Text(0)) & !"\n"
							Result = readpipe
							UpdateWatch i, Result
						Next
						ThreadsLeave
					End If
					MutexLock tlockGDB
				ElseIf NewCommand <> "" Then
					If NewCommand = !"q\n" Then
						ThreadsEnter
						ShowMessages ML("Debugging finished.")
						deinit
						ThreadsLeave
						Exit Do
					Else
						writepipe(NewCommand)
					End If
					NewCommand = ""
					Running = True
				End If
			Loop
			
			Running = False
			bGetPid = False
			
		Else
			'		#ifdef __FB_WIN32__
			'
			'			MsgBox("In Windows, this feature does not work. If the debugging application is a console, press it Ctrl + C to suspend the process.", "Warning!")
			'
			'		#else
			'
			'			kill_(iGlPid , 2)
			'
			'			Updateinfoxserver(10000)
			'
			'		#endif
			
		End If
		
	End Sub
	
	Sub continue_debug()
		
		'	iFlagThreadSignal = 0
		'
		'	memset(@szDataForPipe , 0 , 200000)
		
		DeleteDebugCursor
		
		NewCommand = !"c\n"
		
		MutexUnlock tlockGDB
		
		'	run_pipe_write(!"continue\n")
		'
		'	get_read_data(1)
		
	End Sub
	
	Sub setvalue_debug(sNewValue As String)
		
		iFlagThreadSignal = 0
		
		memset(@szDataForPipe , 0 , 200000)
		
		run_pipe_write(sNewValue)
		
		readpipe()
		
		iFlagUpdateVariables = 1
		
	End Sub
	
	Sub command_debug(sCom As String)
		
		'iFlagThreadSignal = 0
		
		'run_pipe_write(sCom & !"\n")
		
		NewCommand = sCom & !"\n"
		
		'memset(@szDataForPipe , 0 , 200000)
		
		'get_read_data(1)
		
		MutexUnlock tlockGDB
		
	End Sub
	
	Sub step_debug(s As String)
		
		'	iFlagThreadSignal = 0
		'
		'	Dim As Long iSleep
		
		'	#ifdef __FB_WIN32__
		'		iSleep = 100
		'	#else
		'		iSleep = 1
		'	#endif
		
		'	If iStateMenu = 1 Then
		'
		'		NewCommand = "_" & s & !"l_\n"
		'		'run_pipe_write("_" & s & !"l_\n" , iSleep)
		'
		'	ElseIf iStateMenu = 2 Then
		'
		'		NewCommand = "_" & s & !"g_\n"
		'		'run_pipe_write("_" & s & !"g_\n" , iSleep)
		'
		'	Else
		
		NewCommand = s & !"\n"
		'writepipefast(s & !"\n" , iSleep)
		
		'EndIf
		
		'	memset(@szDataForPipe , 0 , 200000)
		'
		'	get_read_data(1 , iStateMenu)
		
		MutexUnlock tlockGDB
		
	End Sub
	
	Sub kill_debug()
		
		iFlagThreadSignal = 0
		
		iFlagUpdateVariables = 0
		
		iCounterUpdateVariables = 0
		
		iFlagStartDebug = 0
		
		'	Setimagegadget(E_BUT_RUN , bmp(0))
		'
		'	Disablegadget(E_BUT_STEP_IN , 1)
		'
		'	Disablegadget(E_BUT_STEP_OUT , 1)
		'
		'	Disablegadget(E_BUT_CONTINUE , 1)
		'
		'	Disablegadget(E_BUT_KILL , 1)
		'
		'	Disablegadget(E_BUT_UPDATEL , 1)
		'
		'	Disablegadget(E_BUT_UPDATEGL , 1)
		'
		'	Disablegadget(E_BUT_COMMAND , 1)
		
		#ifdef __FB_WIN32__
			
			If iGlPid Then
				
				'killtimer(0, TimerID)
				
				readpipe()
				
				Var h = OpenProcess(PROCESS_ALL_ACCESS , 0 , iGlPid)
				
				TerminateProcess(h , 1)
				
				CloseHandle(h)
				
			End If
			
			'Updateinfoxserver(300)
			
		#else
			
			kill_(iGlPid , 2)
			
			'Updateinfoxserver(10000)
			
			run_pipe_write(!"kill\n")
			
			'Sleep(1000)
			
			'killtimer(0, TimerID)
			
		#endif
		
		'	Setselecttexteditorgadget(E_EDITOR, -1 , -1)
		'
		'	Pasteeditor(E_EDITOR, "Kill Program.")
		ShowMessages "Kill Program."
		'
		'	Linescrolleditor(E_EDITOR,10000000)
		
		deinit
		
	End Sub
	
	Sub info_threads_debug(iFlagAutoUpdate As Long = 0)
		
		iFlagThreadSignal = 0
		
		run_pipe_write(!"thread apply all bt\n" , 100)
		
		'memset(@szDataForPipe , 0 , 200000)
		
		get_read_data(4, iFlagAutoUpdate)
		
	End Sub
	
	Sub info_loc_variables_debug(iFlagAutoUpdate As Long = 0)
		
		iFlagThreadSignal = 0
		
		run_pipe_write(!"_l_\n" , 100)
		
		'memset(@szDataForPipe , 0 , 200000)
		
		get_read_data(3 , iFlagAutoUpdate)
		
	End Sub
	
	Sub info_all_variables_debug(iFlagUpdate As Long = 0)
		
		iFlagThreadSignal = 0
		
		run_pipe_write(!"_g_\n" , 100)
		
		'memset(@szDataForPipe , 0 , 200000)
		
		get_read_data(2 , iFlagUpdate)
		
	End Sub
	
	Sub deinit()
		
		'	Disablegadget(E_BUT_STEP_IN , 1)
		'
		'	Disablegadget(E_BUT_STEP_OUT , 1)
		'
		'	Disablegadget(E_BUT_CONTINUE , 1)
		'
		'	Disablegadget(E_BUT_KILL , 1)
		'
		'	Disablegadget(E_BUT_UPDATEL , 1)
		'
		'	Disablegadget(E_BUT_UPDATEGL , 1)
		'
		'	Disablegadget(E_BUT_COMMAND , 1)
		
		'If Len(sfiles_array(0)) Then
		
		writepipe(!"q\n")
		
		#ifdef __FB_WIN32__
			CloseHandle(hReadPipe)
			CloseHandle(hWritePipe)
		#else
			'readpipe()
			close_(iWritePipe(1))
			close_(iReadPipe(0))
		#endif
		
		'EndIf
		MutexUnlock tlockGDB
		
		iFlagStartDebug = 0
		
		iFlagUpdateVariables = 0
		
		iCounterUpdateVariables = 0
		
		DeleteDebugCursor
		
		ChangeEnabledDebug True, False, False
		
		'sCurentFileExe = ""
		
		ReDim As TGLOBALSVAR tgl_var_array(2000)
		
		'ReDim As String sloc_var_array(2000)
		
		'ReDim As String sfiles_array(10)
		
		'	iIndexMainFile = 0
		'
		'	ReDim As HWND hPan()
		'
		'	For i As Long = 500 To 0 Step -1
		'
		'		If pd.sci(i) Then
		'
		'			Deleteitempanelgadget(E_PANEL , i)
		'
		'		EndIf
		'
		'		pd.sci(i) = 0
		'
		'	Next
		
		'	For i As Long = 0 To 200
		'
		'		sBP(i) = ""
		'
		'	Next
		
		'	iFlagThreadSignal = 0
		'
		'	iPosStartLast = 0
		'
		'	iPosEndLast = 0
		'
		'	iCurselLast = 0
		
		memset(@szDataForPipe , 0 , 200000)
		
	End Sub
#endif

Private Sub hard_closing(errormsg As String)
	MsgBox("Sorry an unrecoverable problem occurs :" + Chr(13) + errormsg + Chr(13) + Chr(13) + "Report to dev please")
End Sub

Sub RunWithDebug(Param As Any Ptr)
	On Error Goto ErrorHandler
	'Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	'If tb = 0 Then Exit Sub
	Dim Result As Integer
	Dim As Integer pClass
	Dim As WString Ptr Workdir, CmdL
	#ifndef __USE_GTK__
		Dim SInfo As STARTUPINFO
		Dim PInfo As PROCESS_INFORMATION
	#endif
	ThreadsEnter()
	Dim As ProjectElement Ptr Project
	Dim As TreeNode Ptr ProjectNode
	Dim As UString CompileLine, MainFile = GetMainFile(, Project, ProjectNode)
	Dim As UString FirstLine = GetFirstCompileLine(MainFile, Project, CompileLine)
	ThreadsLeave()
	If Not Restarting Then
		'#IfNDef __USE_GTK__
		exename = GetExeFileName(MainFile, FirstLine & CompileLine)
		mainfolder = GetFolderName(MainFile)
		'#EndIf
	Else
		Restarting = False
	End If
	ThreadsEnter()
	Dim As Boolean Bit32 = tbt32Bit->Checked
	Dim As WString Ptr CurrentDebugger = IIf(Bit32, CurrentDebugger32, CurrentDebugger64)
	Dim As WString Ptr DebuggerPath = IIf(Bit32, Debugger32Path, Debugger64Path)
	Dim As WString Ptr GDBDebuggerPath = IIf(Bit32, GDBDebugger32Path, GDBDebugger64Path)
	ThreadsLeave()
	Dim As Integer Idx = -1
	If WGet(DebuggerPath) <> "" Then
		Idx = pDebuggers->IndexOfKey(*CurrentDebugger)
		If Idx <> -1 Then
			Dim As ToolType Ptr Tool = pDebuggers->Item(Idx)->Object
			WLet(CmdL, Tool->GetCommand(IIf(InStr(LCase(WGet(DebuggerPath)), "gdb"), "", GetFileName(exename))))
		End If
	End If
	#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
		WatchIndex = -1
	#endif
	'#ifdef __USE_GTK__
	'	If WGet(DebuggerPath) = "" AndAlso *CurrentDebugger <> ML("Integrated GDB Debugger") OrElse InStr(LCase(WGet(DebuggerPath)), "gdb") > 0 Then
	'#else
		If WGet(DebuggerPath) <> "" AndAlso runtype <> RTSTEP AndAlso InStr(LCase(WGet(DebuggerPath)), "gdb") > 0 Then
	'#endif
		Dim As Integer Fn = FreeFile_
		Open ExePath & "/Temp/GDBCommands.txt" For Output As #Fn
		Print #Fn, "file """ & Replace(exename, "\", "/") & """"
		Dim As TabWindow Ptr tb
		For jj As Integer = 0 To TabPanels.Count - 1
			Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
			For i As Integer = 0 To ptabCode->TabCount - 1
				tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
				For j As Integer = 0 To tb->txtCode.Content.Lines.Count - 1
					If Not Cast(EditControlLine Ptr, tb->txtCode.Content.Lines.Items[j])->Breakpoint Then Continue For
					Print #Fn, "b """ & Replace(tb->FileName, "\", "/") & """:" & WStr(j + 1)
				Next
			Next i
		Next jj
		Print #Fn, "r"
		CloseFile_(Fn)
		WAdd(CmdL, IIf(WGet(DebuggerPath) = "", "gdb", "") & " -x """ & ExePath & "/Temp/GDBCommands.txt""")
	Else
		If Idx = -1 Then
			WAdd(CmdL, " """ & GetFileName(exename) & """ " & *RunArguments)
		Else
			WAdd(CmdL, " " & *RunArguments)
		End If
		If Project Then WLetEx(CmdL, *CmdL & " " & WGet(Project->CommandLineArguments), True)
	End If
	#ifndef __USE_GTK__
		exename = Replace(exename, BackSlash, Slash)
		re_ini
	#endif
	ThreadsEnter()
	tpLocals->SelectTab
	ThreadsLeave()
	Var Pos1 = 0
	While InStr(Pos1 + 1, exename, "\")
		Pos1 = InStr(Pos1 + 1, exename, "\")
	Wend
	If Pos1 = 0 Then Pos1 = Len(exename)
	WLet(Workdir, Left(exename, Pos1))
	#ifdef __USE_GTK__
		Dim As GPid pid = 0
		'		Dim As GtkWidget Ptr win, vte
		'		win = gtk_window_new(gtk_window_toplevel)
		'		vte = vf->vte_terminal_new()
		'		g_signal_connect(vte, "button-press-event", G_CALLBACK(@vte_button_pressed), NULL)
		'		gtk_container_add(gtk_container(win), vte)
		'		'Dim As gint i_retcode = 0, i_exitcode = 0
		'		Dim As gchar Ptr Ptr argv = g_strsplit(ToUTF8(build_create_shellscript(GetFolderName(exename), exename, False, True)), " ", -1)
		'		gtk_widget_show_all(win)
		'		Dim As GError Ptr error1
		'		vf->vte_terminal_spawn_sync(vte_terminal(vte), VTE_PTY_DEFAULT, ToUTF8(GetFolderName(exename)), argv, NULL, G_SPAWN_SEARCH_PATH Or G_SPAWN_DO_NOT_REAP_CHILD, NULL, NULL, @pid, NULL, @error1)
		'    	If pid > 0 Then
		'    		g_child_watch_add(pid, @run_exit_cb, win)
		'    	Else
		'			m *error1->message
		'    		run_exit_cb(pid, 0, win)
		'    	End If
		Dim As WString Ptr Arguments
		WLet(Arguments, *RunArguments)
		If Project Then WLet(Arguments, *Arguments & " " & WGet(Project->CommandLineArguments))
		If 0 Then
			Shell """" & WGet(TerminalPath) & """ --wait -- """ & build_create_shellscript(GetFolderName(exename), exename, False, True) & """"
		Else
			ChDir(GetFolderName(exename))
			Dim As UString CommandLine
			Dim As ToolType Ptr Tool
			Dim As Integer Idx = pTerminals->IndexOfKey(*CurrentTerminal)
			If Idx <> - 1 Then
				Tool = pTerminals->Item(Idx)->Object
				CommandLine = Tool->GetCommand()
				If Tool->Parameters = "" Then CommandLine &= " --wait -- "
				CommandLine &= " " & *CmdL
			Else
				CommandLine &= *CmdL
			End If
			If TurnOnEnvironmentVariables AndAlso *EnvironmentVariables <> "" Then CommandLine = *EnvironmentVariables & " " & CommandLine
			'IIf(WGet(DebuggerPath) = "", "gdb", Trim(WGet(DebuggerPath)) & """ """ & Replace(ExeName, "\", "/") & IIf(*Arguments = "", "", " " & *Arguments)) & """"
			If *CurrentDebugger = ML("Integrated GDB Debugger") Then
				#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
					ThreadsEnter()
					ShowMessages(Time & ": " & ML("Run") & ": " & exename + " ...")
					tvVar.Visible = False
					lvLocals.Visible = True
					tvThd.Visible = False
					lvThreads.Visible = True
					tvWch.Visible = False
					lvWatches.Visible = True
					'				gtk_widget_show_all(lvGlobals.Handle)
					'				lvGlobals.Parent->RequestAlign
					ThreadsLeave()
					If load_file(exename, GetFullPath(*GDBDebuggerPath)) Then
						ThreadsEnter()
						ShowMessages(Time & ": " & ML("Debugging finished."))
						ChangeEnabledDebug True, False, False
						ThreadsLeave()
						Exit Sub
					End If
					ThreadsEnter()
					tpLocals->SelectTab
					ThreadsLeave()
					iFlagStartDebug = 1
					run_debug(1)
				#endif
				ThreadsEnter()
				ShowMessages(Time & ": " & ML("Application finished. Returned code") & ": " & Result & " - " & Err2Description(Result))
				ChangeEnabledDebug True, False, False
				ThreadsLeave()
			Else
				If check_bitness(exename) = 0 Then Exit Sub ''bitness of debuggee and Integrated IDE Debugger not corresponding
				If kill_process(ML("Trying to launch but debuggee still running")) = False Then Exit Sub
				flagrestart = -1
				ThreadsEnter()
				lvLocals.Visible = False
				tvVar.Visible = True
				lvThreads.Visible = False
				tvThd.Visible = True
				lvWatches.Visible = False
				tvWch.Visible = True
				InDebug = True
				tpLocals->SelectTab
				ThreadsLeave()
				
				If ThreadCreate(@start_pgm) = 0 Then
					KillTimer(0, GTIMER001)
					MsgBox("Debuggee not running", "ERROR unable to start the thread managing the debuggee")
				EndIf
				'ThreadsEnter()
				'ShowMessages(Time & ": " & ML("Run") & ": " & CommandLine + " ...")
				'ThreadsLeave()
				'Result = Shell(CommandLine)
			End If
		End If
		WDeAllocate Arguments
		'Shell "gdb " & CmdL
	#else
		ShowMessages(Time & ": " & ML("Run") & ": " & *CmdL + " ...")
		SInfo.cb = Len(SInfo)
		SInfo.dwFlags = STARTF_USESHOWWINDOW
		SInfo.wShowWindow = SW_NORMAL
		If WGet(DebuggerPath) <> "" AndAlso runtype <> RTSTEP Then
			Dim As Unsigned Long ExitCode
			exename = GetFullPath(WGet(DebuggerPath))
			pClass = CREATE_UNICODE_ENVIRONMENT Or CREATE_NEW_CONSOLE
			If CreateProcessW(@exename, CmdL, ByVal NULL, ByVal NULL, False, pClass, NULL, Workdir, @SInfo, @PInfo) Then
				WaitForSingleObject PInfo.hProcess, INFINITE
				GetExitCodeProcess(PInfo.hProcess, @ExitCode)
				CloseHandle(PInfo.hProcess)
				CloseHandle(PInfo.hThread)
			End If
			Result = ExitCode
			ShowMessages(Time & ": " & ML("Application finished. Returned code") & ": " & Result & " - " & Err2Description(Result))
			ChangeEnabledDebug True, False, False
			'Shell """" & WGet(Debugger) & """ """ & exename & """"
		Else
			If *CurrentDebugger = ML("Integrated GDB Debugger") Then
				tvVar.Visible = False
				lvLocals.Visible = True
				tvThd.Visible = False
				lvThreads.Visible = True
				tvWch.Visible = False
				lvWatches.Visible = True
				If load_file(exename, GetFullPath(*GDBDebuggerPath)) Then
					ShowMessages(Time & ": " & ML("Debugging finished."))
					ChangeEnabledDebug True, False, False
					Exit Sub
				End If
				tpLocals->SelectTab
				iFlagStartDebug = 1
				run_debug(1)
				ShowMessages(Time & ": " & ML("Application finished. Returned code") & ": " & Result & " - " & Err2Description(Result))
				ChangeEnabledDebug True, False, False
			Else
				If check_bitness(exename) = 0 Then Exit Sub ''bitness of debuggee and Integrated IDE Debugger not corresponding
				If kill_process(ML("Trying to launch but debuggee still running")) = False Then Exit Sub
				flagrestart = -1
				lvLocals.Visible = False
				tvVar.Visible = True
				lvThreads.Visible = False
				tvThd.Visible = True
				lvWatches.Visible = False
				tvWch.Visible = True
				InDebug = True
				tpLocals->SelectTab
				
				If ThreadCreate(@start_pgm) = 0 Then
					KillTimer(0, GTIMER001)
					MsgBox("Debuggee not running", "ERROR unable to start the thread managing the debuggee")
				EndIf
				'pClass = NORMAL_PRIORITY_CLASS Or CREATE_UNICODE_ENVIRONMENT Or CREATE_NEW_CONSOLE Or DEBUG_PROCESS Or DEBUG_ONLY_THIS_PROCESS
				'If CreateProcessW(@exename, CmdL, ByVal NULL, ByVal NULL, False, pClass, NULL, Workdir, @SInfo, @PInfo) Then
				'	WaitForSingleObject PInfo.hProcess, 10
				'	dbgprocid = PInfo.dwProcessId
				'	dbgthreadID = PInfo.dwThreadId
				'	dbghand = PInfo.hProcess
				'	dbghthread = PInfo.hThread
				'	prun = True
				'	wait_debug
				'End If
				'KillTimer 0, 0
				'InDebug = False
				'DeleteDebugCursor
				'Dim As Unsigned Long ExitCode
				'GetExitCodeProcess(PInfo.hProcess, @ExitCode)
				'Result = ExitCode
				'ShowMessages(Time & ": " & ML("Application finished. Returned code") & ": " & Result & " - " & Err2Description(Result))
				'ChangeEnabledDebug True, False, False
				'#ifndef __USE_GTK__
				'	If CurrentTimer <> 0 Then KillTimer 0, CurrentTimer
				'	CurrentTimer = 0
				'#endif
			End If
		End If
	#endif
	If Workdir <> 0 Then Deallocate_( Workdir)
	If CmdL <> 0 Then Deallocate_( CmdL)
	Exit Sub
	ErrorHandler:
	ThreadsEnter()
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " " & _
	"in function " & ZGet(Erfn()) & " " & _
	"in module " & ZGet(Ermn())
	ThreadsLeave()
End Sub

