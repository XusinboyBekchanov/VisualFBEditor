'=================================================================
'===== Debug.bas =================================================
'===== Authors: Laurent GRAS, Xusinboy Bekchanov =================
'===== Based on: =================================================
'=================================================================
'===== DEBUGGER FOR FREEBASIC === (C) 2006-2018 Laurent GRAS =====
'=================================================================
'===== Modified to bundle with VisualFBEditor ====================
'===== by Xusinboy Bekchanov (2018-2019) =========================
'=================================================================

#Include Once "mff/TextBox.bi"
#Include Once "EditControl.bi"
#Include Once "TabWindow.bi"
#Include Once "Main.bi"

Declare Sub DeleteDebugCursor

Enum 'type of running
	RTRUN
	RTSTEP
	RTAUTO
	RTOFF
	RTFRUN
	RTFREE
	RTEND
End Enum

Common Shared As Byte runtype        'running type 07/12/2014

#IfNDef __USE_GTK__
	Declare Sub fastrun()
	Declare Sub thread_rsm()
	Declare Sub exe_mod()
	Declare sub var_tip(ope As Integer)
	Declare sub brk_set(t As Integer)
	Declare sub string_sh(tv As HWND)
	Declare sub shwexp_new(tview As HWND)
	
	Common Shared windmain As HWND
	Common Shared stopcode As Integer
	Common Shared dbghand As HANDLE 'debugged proc handle
	Common Shared As Integer linenb, rlineold 'numbers of lines, index of previous executed line (rline)
	Common Shared tviewcur As HWND  'TV1 ou TV2 ou TV3
	Common Shared tviewvar As HWND 'running proc/var
	Common Shared tviewprc As HWND 'all proc
	Common Shared tviewthd As HWND 'all threads
	Common Shared tviewwch As HWND 'watched variables
	
	'line ==============================================
	Type tline
		ad As UInteger
		nu As Integer
		sv As Byte
		px As UShort ''proc index
		sx As UShort ''source index 2018/08/02 need it now for lines from include and not inside proc
		hp As Integer
		hn As Integer
	End Type
	Common Shared As Integer linenbprev 'used for dll 
	Common Shared rline() As tline
	Common Shared As Integer fntab, fcurlig
	Common Shared source() As String    'source names
	Common Shared As HWND htab1, htab2
#EndIf

Declare Sub RunWithDebug(Param As Any Ptr)

#IfNDef __USE_MAKE__
	#Include Once "Debug.bas"
#EndIf
