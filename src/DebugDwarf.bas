'' Integrated IDE Debugger: the programs compiled with -gen gcc -g
''
'' gas and gas64 write STABS (.stab/.stabstr, .dbgdat/.dbgstr), gcc writes DWARF 2-5 (.debug_info, .debug_abbrev,
'' .debug_line, .debug_str, .debug_line_str). The DWARF of the FreeBASIC modules is converted to the STABS strings
'' of gas64 and is given to the same handlers (dbg_include, dbg_proc, parse_var, dbg_line, dbg_epilog), so the rest
'' of the debugger works in the same way for both.
''
'' The C code of fbc -gen gcc (the differences with gas/gas64):
'' - the names have a suffix with the scope (A$1, GSTR$) and the UDTs a prefix with the length ($6TPOINT),
'' - Byref parameters are pointers: a pointer to a String or a UDT is shown as a Byref parameter, the other pointers
''   as pointers,
'' - the fixed-size arrays are C arrays: the lower bounds are 0,
'' - the enums are integers (typedef), WString is UShort (Windows) or ULong (Linux),
'' - only -O0 (default): with the optimizations the variables are in registers and location lists.

Type DwSect
	As UByte Ptr p 'start in dwbuf (0: not found)
	As Integer sz
End Type
Type DwMap 'a section of the file at its address (the code of the prologues)
	As ULongInt va
	As Integer fo, sz
End Type
Type DwAbbrev
	As ULong code, tag
	As Byte children
	As Long first, cnt 'the attributes in dwabat()
End Type
Type DwAbAttr
	As ULong at, frm
	As LongInt ic 'DW_FORM_implicit_const
End Type
Type DwDie
	As ULong ofs, tag
	As Long depth
	As String nm
	As ULongInt typofs 'the type: offset in .debug_info (0: none)
	As Long typ        'the type: index in dwdie (0: none / void)
	As LongInt bytesz, ub, lb, cnt, memloc
	As Long enc, bitsz, bitofs, databitofs, declfile, declline, stab
	As Byte hasub, haslb, hascnt, hasbytesz, hasbitofs, decl, ext, highrel
	As ULongInt lowpc, highpc
	As UByte Ptr locp, fbp 'DW_AT_location, DW_AT_frame_base (expressions)
	As Long locl, fbl
End Type
Type DwRow
	As ULongInt ad
	As Long fl, ln
	As Byte endseq
End Type

Dim Shared As UByte Ptr dwbuf
Dim Shared As Integer dwbufsz, dwerr
Dim Shared As DwSect dwsinfo, dwsabbrev, dwsline, dwsstr, dwslinestr
Dim Shared As DwMap dwmap(Any)
Dim Shared As Integer dwmapnb
Dim Shared As DwAbbrev dwab(Any)
Dim Shared As DwAbAttr dwabat(Any)
Dim Shared As Integer dwabnb, dwabatnb
Dim Shared As LongInt dwabofs = -1
Dim Shared As DwDie dwdie(Any)
Dim Shared As Integer dwdienb
Dim Shared As DwRow dwrow(Any)
Dim Shared As Integer dwrownb
Dim Shared As String dwfile(Any) 'the files of the line program of the CU (full names)
Dim Shared As Byte dwfilefb(Any) 'the file is a FreeBASIC source
Dim Shared As Integer dwfilelo, dwfilehi
Dim Shared As Integer dwasz, dwosz, dwversion, dwtypecnt
Dim Shared As ULongInt dwcuofs
Dim Shared As String dwcompdir 'DW_AT_comp_dir of the CU
Dim Shared As LongInt dwstmt 'DW_AT_stmt_list of the CU (-1: none)
Dim Shared As LongInt dwdelta 'address where the module is loaded - address where it is linked

'' ---------------------------------------------------------------------------------------------------------------
'' Reading
'' ---------------------------------------------------------------------------------------------------------------
Private Function dw_rd(ByRef p As UByte Ptr, ByVal n As Integer) As ULongInt
	Dim As ULongInt v
	For i As Integer = n - 1 To 0 Step -1
		v = (v Shl 8) Or p[i]
	Next
	p += n
	Return v
End Function

Private Function dw_uleb(ByRef p As UByte Ptr) As ULongInt
	Dim As ULongInt v
	Dim As Integer s
	Dim As UByte b
	Do
		b = *p: p += 1
		If s < 64 Then v Or= CULngInt(b And &h7F) Shl s
		s += 7
	Loop While b And &h80
	Return v
End Function

Private Function dw_sleb(ByRef p As UByte Ptr) As LongInt
	Dim As ULongInt v
	Dim As Integer s
	Dim As UByte b
	Do
		b = *p: p += 1
		If s < 64 Then v Or= CULngInt(b And &h7F) Shl s
		s += 7
	Loop While b And &h80
	If s < 64 AndAlso (b And &h40) <> 0 Then v Or= (Not 0ULL) Shl s
	Return Cast(LongInt, v)
End Function

Private Function dw_cstr(ByRef p As UByte Ptr) As String
	Dim As String s = *Cast(ZString Ptr, p)
	p += Len(s) + 1
	Return s
End Function

Private Function dw_strat(ByRef sect As DwSect, ByVal ofs As ULongInt) As String
	If sect.p = 0 OrElse ofs >= sect.sz Then Return ""
	Return *Cast(ZString Ptr, sect.p + ofs)
End Function

'' A value of the form frm. kind: 0 number, 1 string (s), 2 block (blk, blen), 3 reference (v: offset in
'' .debug_info), 4 signed number
Private Sub dw_form(ByRef p As UByte Ptr, ByVal frm As ULong, ByVal ic As LongInt, ByRef v As ULongInt, ByRef s As String, ByRef blk As UByte Ptr, ByRef blen As Long, ByRef kind As Long)
	kind = 0: v = 0
	Select Case As Const frm
	Case &h01: v = dw_rd(p, dwasz) 'addr
	Case &h03: blen = dw_rd(p, 2): blk = p: p += blen: kind = 2 'block2
	Case &h04: blen = dw_rd(p, 4): blk = p: p += blen: kind = 2 'block4
	Case &h09, &h18: blen = dw_uleb(p): blk = p: p += blen: kind = 2 'block, exprloc
	Case &h0a: blen = dw_rd(p, 1): blk = p: p += blen: kind = 2 'block1
	Case &h05: v = dw_rd(p, 2) 'data2
	Case &h06: v = dw_rd(p, 4) 'data4
	Case &h07: v = dw_rd(p, 8) 'data8
	Case &h0b, &h0c: v = dw_rd(p, 1) 'data1, flag
	Case &h0d: v = dw_sleb(p): kind = 4 'sdata
	Case &h0f: v = dw_uleb(p) 'udata
	Case &h08: s = dw_cstr(p): kind = 1 'string
	Case &h0e: s = dw_strat(dwsstr, dw_rd(p, dwosz)): kind = 1 'strp
	Case &h1f: s = dw_strat(dwslinestr, dw_rd(p, dwosz)): kind = 1 'line_strp
	Case &h10: v = dw_rd(p, IIf(dwversion <= 2, dwasz, dwosz)): kind = 3 'ref_addr
	Case &h11: v = dw_rd(p, 1) + dwcuofs: kind = 3 'ref1
	Case &h12: v = dw_rd(p, 2) + dwcuofs: kind = 3 'ref2
	Case &h13: v = dw_rd(p, 4) + dwcuofs: kind = 3 'ref4
	Case &h14: v = dw_rd(p, 8) + dwcuofs: kind = 3 'ref8
	Case &h15: v = dw_uleb(p) + dwcuofs: kind = 3 'ref_udata
	Case &h16: dw_form(p, dw_uleb(p), ic, v, s, blk, blen, kind) 'indirect
	Case &h17, &h1d, &h1f20, &h1f21: v = dw_rd(p, dwosz) 'sec_offset, strp_sup, GNU_ref_alt, GNU_strp_alt
	Case &h19: v = 1 'flag_present
	Case &h1a, &h1b, &h22, &h23, &h1f01, &h1f02: v = dw_uleb(p) 'strx, addrx, loclistx, rnglistx (not used by gcc)
	Case &h1c: v = dw_rd(p, 4) 'ref_sup4
	Case &h1e: p += 16 'data16
	Case &h20, &h24: v = dw_rd(p, 8) 'ref_sig8, ref_sup8
	Case &h21: v = ic: kind = 4 'implicit_const
	Case &h25, &h29: v = dw_rd(p, 1) 'strx1, addrx1
	Case &h26, &h2a: v = dw_rd(p, 2) 'strx2, addrx2
	Case &h27, &h2b: v = dw_rd(p, 3) 'strx3, addrx3
	Case &h28, &h2c: v = dw_rd(p, 4) 'strx4, addrx4
	Case Else: dwerr = 1 'unknown form: the rest of the CU can't be read
	End Select
End Sub

'' The offset of a member: a constant or DW_OP_plus_uconst / DW_OP_constu (DWARF 2/3)
Private Function dw_exprconst(ByVal p As UByte Ptr, ByVal l As Long) As LongInt
	If l < 1 Then Return 0
	Dim As UByte op = *p
	p += 1
	If op = &h23 OrElse op = &h10 Then Return dw_uleb(p)
	If op = &h11 Then Return dw_sleb(p)
	Return 0
End Function

'' ---------------------------------------------------------------------------------------------------------------
'' Abbreviations and DIEs of a CU
'' ---------------------------------------------------------------------------------------------------------------
Private Sub dw_abbrevs(ByVal ofs As ULongInt)
	If ofs = dwabofs Then Exit Sub
	dwabofs = ofs: dwabnb = 0: dwabatnb = 0
	If ofs >= dwsabbrev.sz Then Exit Sub
	Dim As UByte Ptr p = dwsabbrev.p + ofs, pe = dwsabbrev.p + dwsabbrev.sz
	Dim As ULong code, at, frm
	Do While p < pe
		code = dw_uleb(p)
		If code = 0 Then Exit Do
		dwabnb += 1
		If dwabnb > UBound(dwab) Then ReDim Preserve dwab(dwabnb * 2 + 64)
		dwab(dwabnb).code = code
		dwab(dwabnb).tag = dw_uleb(p)
		dwab(dwabnb).children = *p: p += 1
		dwab(dwabnb).first = dwabatnb + 1
		dwab(dwabnb).cnt = 0
		Do
			at = dw_uleb(p): frm = dw_uleb(p)
			If at = 0 AndAlso frm = 0 Then Exit Do
			dwabatnb += 1
			If dwabatnb > UBound(dwabat) Then ReDim Preserve dwabat(dwabatnb * 2 + 256)
			dwabat(dwabatnb).at = at
			dwabat(dwabatnb).frm = frm
			dwabat(dwabatnb).ic = 0
			If frm = &h21 Then dwabat(dwabatnb).ic = dw_sleb(p)
			dwab(dwabnb).cnt += 1
		Loop
	Loop
End Sub

Private Function dw_abfind(ByVal code As ULong) As Long
	If code <= dwabnb AndAlso dwab(code).code = code Then Return code
	For i As Long = 1 To dwabnb
		If dwab(i).code = code Then Return i
	Next
	Return 0
End Function

'' The DIEs of the CU (p after the header, pe the end), returns 0 if the CU can't be read
Private Function dw_dies(ByVal p As UByte Ptr, ByVal pe As UByte Ptr) As Long
	Static As DwDie blank
	Dim As Long depth, ia, kind, blen
	Dim As ULong code, at
	Dim As ULongInt v
	Dim As String s
	Dim As UByte Ptr blk
	dwdienb = 0: dwcompdir = "": dwstmt = -1
	Do While p < pe
		Dim As ULong dofs = p - dwsinfo.p
		code = dw_uleb(p)
		If code = 0 Then depth -= 1: Continue Do
		ia = dw_abfind(code)
		If ia = 0 Then Return 0
		dwdienb += 1
		If dwdienb > UBound(dwdie) Then ReDim Preserve dwdie(dwdienb * 2 + 256)
		dwdie(dwdienb) = blank
		With dwdie(dwdienb)
			.ofs = dofs
			.tag = dwab(ia).tag
			.depth = depth
			.databitofs = -1
			For iat As Long = dwab(ia).first To dwab(ia).first + dwab(ia).cnt - 1
				at = dwabat(iat).at
				s = "": blk = 0: blen = 0
				dw_form(p, dwabat(iat).frm, dwabat(iat).ic, v, s, blk, blen, kind)
				If dwerr Then Return 0
				Select Case As Const at
				Case &h03: .nm = s 'name
				Case &h49: If kind = 3 Then .typofs = v 'type
				Case &h0b: .bytesz = v: .hasbytesz = 1 'byte_size
				Case &h3e: .enc = v 'encoding
				Case &h2f: If kind = 0 OrElse kind = 4 Then .ub = v: .hasub = 1 'upper_bound
				Case &h22: If kind = 0 OrElse kind = 4 Then .lb = v: .haslb = 1 'lower_bound
				Case &h37: If kind = 0 OrElse kind = 4 Then .cnt = v: .hascnt = 1 'count
				Case &h38: .memloc = IIf(kind = 2, dw_exprconst(blk, blen), Cast(LongInt, v)) 'data_member_location
				Case &h0d: .bitsz = v 'bit_size
				Case &h0c: .bitofs = v: .hasbitofs = 1 'bit_offset
				Case &h6b: .databitofs = v 'data_bit_offset
				Case &h02: If kind = 2 Then .locp = blk: .locl = blen 'location (not the location lists)
				Case &h40: If kind = 2 Then .fbp = blk: .fbl = blen 'frame_base
				Case &h11: .lowpc = v 'low_pc
				Case &h12: .highpc = v: .highrel = IIf(dwabat(iat).frm = &h01, 0, 1) 'high_pc (DWARF 4: size)
				Case &h3a: .declfile = v 'decl_file
				Case &h3b: .declline = v 'decl_line
				Case &h3c: .decl = 1 'declaration
				Case &h20: If v <> 0 Then .decl = 1 'inline: abstract instance
				Case &h3f: .ext = v 'external
				Case &h10: If .depth = 0 Then dwstmt = v 'stmt_list (compile unit)
				Case &h1b: If .depth = 0 Then dwcompdir = s 'comp_dir (compile unit)
				End Select
			Next
		End With
		If dwab(ia).children Then depth += 1
	Loop
	'The references to the index of the DIE (the DIEs are sorted by offset)
	For i As Long = 1 To dwdienb
		If dwdie(i).typofs Then
			Dim As Long lo = 1, hi = dwdienb, md
			Do While lo <= hi
				md = (lo + hi) \ 2
				If dwdie(md).ofs = dwdie(i).typofs Then dwdie(i).typ = md: Exit Do
				If dwdie(md).ofs < dwdie(i).typofs Then lo = md + 1 Else hi = md - 1
			Loop
		End If
	Next
	Return 1
End Function

'' ---------------------------------------------------------------------------------------------------------------
'' Line program of a CU
'' ---------------------------------------------------------------------------------------------------------------
Private Function dw_isabs(ByRef s As String) As Boolean
	Return Left(s, 1) = "/" OrElse Left(s, 1) = "\" OrElse Mid(s, 2, 1) = ":"
End Function

Private Function dw_path(ByRef d As String, ByRef nm As String, ByRef compdir As String) As String
	Dim As String r
	If dw_isabs(nm) Then
		r = nm
	Else
		Dim As String dd = d
		If dd = "" Then
			dd = compdir
		ElseIf Not dw_isabs(dd) AndAlso compdir <> "" Then
			dd = compdir + "/" + dd
		End If
		If dd <> "" AndAlso Right(dd, 1) <> "/" AndAlso Right(dd, 1) <> "\" Then dd += "/"
		r = dd + nm
	End If
	#ifdef __FB_WIN32__
		For i As Integer = 0 To Len(r) - 1
			If r[i] = Asc("/") Then r[i] = Asc("\")
		Next
		Dim As Integer p = InStr(r, "\.\")
		While p
			r = Left(r, p) + Mid(r, p + 3)
			p = InStr(r, "\.\")
		Wend
	#else
		Dim As Integer p = InStr(r, "/./")
		While p
			r = Left(r, p) + Mid(r, p + 3)
			p = InStr(r, "/./")
		Wend
	#endif
	Return r
End Function

Private Function dw_isfb(ByRef s As String) As Boolean
	Dim As String e = LCase(Mid(s, InStrRev(s, ".")))
	Return e = ".bas" OrElse e = ".bi" OrElse e = ".inc" OrElse e = ".frm" OrElse e = ".rpt"
End Function

Private Sub dw_addrow(ByVal ad As ULongInt, ByVal fl As Long, ByVal ln As Long, ByVal endseq As Byte)
	dwrownb += 1
	If dwrownb > UBound(dwrow) Then ReDim Preserve dwrow(dwrownb * 2 + 256)
	dwrow(dwrownb).ad = ad
	dwrow(dwrownb).fl = fl
	dwrow(dwrownb).ln = ln
	dwrow(dwrownb).endseq = endseq
End Sub

'' The files and the rows (address, file, line) of the line program at ofs, returns True if a file is a FreeBASIC source
Private Function dw_lines(ByVal ofs As ULongInt, ByRef compdir As String) As Boolean
	Dim As ULongInt v
	Dim As String s
	Dim As UByte Ptr blk
	Dim As Long blen, kind
	Dim As Boolean isfb
	dwrownb = 0: dwfilelo = 1: dwfilehi = 0
	If dwsline.p = 0 OrElse ofs >= dwsline.sz Then Return False
	Dim As UByte Ptr p = dwsline.p + ofs
	Dim As ULongInt ulen = dw_rd(p, 4)
	Dim As Integer osz = 4, savosz = dwosz, savver = dwversion
	If ulen = &hFFFFFFFFull Then ulen = dw_rd(p, 8): osz = 8
	Dim As UByte Ptr pend = p + ulen
	If pend > dwsline.p + dwsline.sz Then pend = dwsline.p + dwsline.sz
	Dim As Integer ver = dw_rd(p, 2)
	If ver < 2 OrElse ver > 5 Then Return False
	dwosz = osz: dwversion = ver
	If ver >= 5 Then
		p += 2 'address_size, segment_selector_size
	End If
	Dim As ULongInt hlen = dw_rd(p, osz)
	Dim As UByte Ptr pprog = p + hlen
	Dim As Integer mininst = dw_rd(p, 1)
	If ver >= 4 Then p += 1 'maximum_operations_per_instruction
	Dim As Integer defstmt = dw_rd(p, 1)
	Dim As Integer linebase = CByte(dw_rd(p, 1)), linerange = dw_rd(p, 1), opbase = dw_rd(p, 1)
	Dim As Integer oplen(255)
	For i As Integer = 1 To opbase - 1
		oplen(i) = dw_rd(p, 1)
	Next
	If linerange = 0 Then linerange = 1
	Dim As String dirs(Any)
	If ver >= 5 Then
		Dim As ULong fct(255), ffr(255)
		Dim As Integer nfmt = dw_rd(p, 1)
		For i As Integer = 1 To nfmt
			fct(i) = dw_uleb(p): ffr(i) = dw_uleb(p)
		Next
		Dim As Integer nd = dw_uleb(p)
		ReDim dirs(nd)
		For i As Integer = 0 To nd - 1
			For j As Integer = 1 To nfmt
				s = ""
				dw_form(p, ffr(j), 0, v, s, blk, blen, kind)
				If fct(j) = 1 Then dirs(i) = s 'DW_LNCT_path
			Next
		Next
		nfmt = dw_rd(p, 1)
		For i As Integer = 1 To nfmt
			fct(i) = dw_uleb(p): ffr(i) = dw_uleb(p)
		Next
		Dim As Integer nf = dw_uleb(p)
		ReDim dwfile(nf), dwfilefb(nf)
		dwfilelo = 0: dwfilehi = nf - 1
		For i As Integer = 0 To nf - 1
			Dim As String fname
			Dim As Integer di
			For j As Integer = 1 To nfmt
				s = ""
				dw_form(p, ffr(j), 0, v, s, blk, blen, kind)
				If fct(j) = 1 Then
					fname = s 'DW_LNCT_path
				ElseIf fct(j) = 2 Then
					di = v 'DW_LNCT_directory_index
				End If
			Next
			Dim As String dname
			If di >= 0 AndAlso di < nd Then dname = dirs(di)
			dwfile(i) = dw_path(dname, fname, compdir)
		Next
	Else
		ReDim dirs(0)
		Dim As Integer nd
		Do
			s = dw_cstr(p)
			If s = "" Then Exit Do
			nd += 1
			ReDim Preserve dirs(nd)
			dirs(nd) = s
		Loop
		Dim As Integer nf
		ReDim dwfile(16), dwfilefb(16)
		Do
			s = dw_cstr(p)
			If s = "" Then Exit Do
			Dim As Integer di = dw_uleb(p)
			dw_uleb(p): dw_uleb(p) 'time, size
			nf += 1
			If nf > UBound(dwfile) Then
				ReDim Preserve dwfile(nf * 2)
				ReDim Preserve dwfilefb(nf * 2)
			End If
			Dim As String dname
			If di >= 1 AndAlso di <= nd Then dname = dirs(di)
			dwfile(nf) = dw_path(dname, s, compdir)
		Loop
		dwfilelo = 1: dwfilehi = nf
	End If
	dwosz = savosz: dwversion = savver
	If dwerr Then Return False
	For i As Integer = dwfilelo To dwfilehi
		dwfilefb(i) = dw_isfb(dwfile(i))
		If dwfilefb(i) Then isfb = True
	Next
	If Not isfb Then Return False
	'The program
	p = pprog
	Dim As ULongInt adr
	Dim As Long fl = 1, ln = 1, stmt = defstmt, adj
	Dim As UByte op, sop
	Do While p < pend
		op = *p: p += 1
		If op >= opbase Then 'special opcode
			adj = op - opbase
			adr += (adj \ linerange) * mininst
			ln += linebase + (adj Mod linerange)
			If stmt Then dw_addrow(adr, fl, ln, 0)
		ElseIf op = 0 Then 'extended opcode
			Dim As ULongInt elen = dw_uleb(p)
			Dim As UByte Ptr pnext = p + elen
			If elen = 0 Then Continue Do
			sop = *p: p += 1
			Select Case sop
			Case 1 'end_sequence
				dw_addrow(adr, fl, ln, 1)
				adr = 0: fl = 1: ln = 1: stmt = defstmt
			Case 2 'set_address
				adr = dw_rd(p, elen - 1)
			End Select
			p = pnext
		Else
			Select Case op
			Case 1: If stmt Then dw_addrow(adr, fl, ln, 0) 'copy
			Case 2: adr += dw_uleb(p) * mininst 'advance_pc
			Case 3: ln += dw_sleb(p) 'advance_line
			Case 4: fl = dw_uleb(p) 'set_file
			Case 5: dw_uleb(p) 'set_column
			Case 6: stmt = 1 - stmt 'negate_stmt
			Case 7, 10, 11 'set_basic_block, set_prologue_end, set_epilogue_begin
			Case 8: adr += ((255 - opbase) \ linerange) * mininst 'const_add_pc
			Case 9: adr += dw_rd(p, 2) 'fixed_advance_pc
			Case Else
				For i As Integer = 1 To oplen(op)
					dw_uleb(p)
				Next
			End Select
		End If
	Loop
	Return True
End Function

'' ---------------------------------------------------------------------------------------------------------------
'' Types -> STABS type strings (the numbers of gas64: 1 Long, 2 Byte, 3 UByte, 4 ZString, 5 Short, 6 UShort,
'' 7 Any, 8 ULong, 9 LongInt/Integer, 10 ULongInt/UInteger, 11 Single, 12 Double, 13 String, 16 Boolean),
'' "0=*" for a pointer, "0=ar1;lb;ub;" for each dimension of an array, the UDTs from TYPESTD + 1
'' ---------------------------------------------------------------------------------------------------------------
Private Function dw_fbtypedef(ByRef nm As String) As Long
	Select Case nm
	Case "int8": Return 2
	Case "uint8": Return 3
	Case "int16": Return 5
	Case "uint16": Return 6
	Case "int32": Return 1
	Case "uint32": Return 8
	Case "int64": Return 9
	Case "uint64": Return 10
	Case "FBSTRING": Return 13
	Case "boolean": Return 16
	End Select
	Return 0
End Function

'' The type without the qualifiers and the typedefs (except the typedefs of fbc), 0: void
Private Function dw_strip(ByVal i As Long) As Long
	For n As Integer = 1 To 50
		If i <= 0 Then Return 0
		Select Case dwdie(i).tag
		Case &h26, &h35, &h37, &h47 'const, volatile, restrict, atomic
			i = dwdie(i).typ
		Case &h16 'typedef
			If dw_fbtypedef(dwdie(i).nm) Then Return i
			i = dwdie(i).typ
		Case Else
			Return i
		End Select
	Next
	Return 0
End Function

Private Function dw_intsize(ByVal sz As LongInt, ByVal bsigned As Boolean) As Long
	Select Case sz
	Case 1: Return IIf(bsigned, 2, 3)
	Case 2: Return IIf(bsigned, 5, 6)
	Case 4: Return IIf(bsigned, 1, 8)
	End Select
	Return IIf(bsigned, 9, 10)
End Function

'' The number of a standard type, 0 if it is not
Private Function dw_stdtyp(ByVal i As Long) As Long
	Select Case dwdie(i).tag
	Case &h16 'typedef of fbc
		Return dw_fbtypedef(dwdie(i).nm)
	Case &h24 'base_type
		Select Case dwdie(i).enc
		Case 4: Return IIf(dwdie(i).bytesz = 4, 11, 12) 'float
		Case 2: Return 16 'boolean
		Case 6, 8 'signed_char, unsigned_char
			If dwdie(i).nm = "char" Then Return 4
			Return IIf(dwdie(i).enc = 6, 2, 3)
		Case 5, &hD: Return dw_intsize(dwdie(i).bytesz, True) 'signed, signed_fixed
		Case Else: Return dw_intsize(dwdie(i).bytesz, False)
		End Select
	Case &h04 'enumeration (C)
		Return dw_intsize(IIf(dwdie(i).hasbytesz, dwdie(i).bytesz, 4), True)
	End Select
	Return 0
End Function

'' The size of a type in bytes
Private Function dw_tsize(ByVal i As Long, ByVal nest As Long = 0) As LongInt
	If nest > 30 Then Return 0
	For n As Integer = 1 To 50
		If i <= 0 Then Return 0
		Select Case dwdie(i).tag
		Case &h26, &h35, &h37, &h47, &h16: i = dwdie(i).typ
		Case Else: Exit For
		End Select
	Next
	If i <= 0 Then Return 0
	If dwdie(i).hasbytesz Then Return dwdie(i).bytesz
	Select Case dwdie(i).tag
	Case &h0f, &h10, &h42: Return dwasz 'pointer, reference
	Case &h01 'array
		Dim As LongInt nb = 1
		For j As Long = i + 1 To dwdienb
			If dwdie(j).depth <= dwdie(i).depth Then Exit For
			If dwdie(j).tag = &h21 AndAlso dwdie(j).depth = dwdie(i).depth + 1 Then
				If dwdie(j).hascnt Then
					nb *= dwdie(j).cnt
				ElseIf dwdie(j).hasub Then
					nb *= dwdie(j).ub - IIf(dwdie(j).haslb, dwdie(j).lb, 0) + 1
				End If
			End If
		Next
		Return nb * dw_tsize(dwdie(i).typ, nest + 1)
	End Select
	Return 0
End Function

'' The names in a namespace or a UDT: <length><name>...E (from k, 1-based) -> NS.NAME
Private Function dw_nested(ByRef nm As String, ByVal k As Integer) As String
	Dim As String r, c
	Dim As Integer l, q
	While k <= Len(nm) AndAlso nm[k - 1] >= Asc("0") AndAlso nm[k - 1] <= Asc("9")
		l = 0
		While k <= Len(nm) AndAlso nm[k - 1] >= Asc("0") AndAlso nm[k - 1] <= Asc("9")
			l = l * 10 + nm[k - 1] - Asc("0"): k += 1
		Wend
		c = Mid(nm, k, l): k += l
		q = InStr(c, "$")
		If q > 1 Then c = Left(c, q - 1)
		r += IIf(r = "", "", ".") + c
	Wend
	Return r
End Function

'' The name of a variable or a member (without the suffix of fbc), "" for the variables of the compiler
Private Function dw_cleanname(ByRef nm As String) As String
	Dim As String s = nm
	If Left(s, 2) = "$N" Then Return dw_nested(s, 3) 'UDT in a namespace: $N2NS5TBASEE
	If Left(s, 1) = "$" Then 'UDT: $<length><name>
		Dim As Integer k = 2
		While k <= Len(s) AndAlso s[k - 1] >= Asc("0") AndAlso s[k - 1] <= Asc("9")
			k += 1
		Wend
		s = Mid(s, k)
	End If
	Dim As Integer p = InStr(s, "$")
	If p = 1 Then Return ""
	If p > 1 Then s = Left(s, p - 1)
	Return s
End Function

Private Function dw_varname(ByRef nm As String) As String
	If nm = "" Then Return ""
	If Left(nm, 4) = "TMP$" OrElse Left(nm, 4) = "tmp$" OrElse Left(nm, 3) = "vr$" OrElse Left(nm, 6) = "label$" _
		OrElse Left(nm, 10) = "fb$result$" OrElse Left(nm, 5) = "__FB_" OrElse Left(nm, 3) = "__$" OrElse Left(nm, 1) = "$" _
		OrElse InStr(nm, "$fb_RTTI") > 0 OrElse Left(nm, 4) = "_ZTS" OrElse Left(nm, 4) = "_ZTV" Then Return ""
	If Left(nm, 3) = "_ZN" Then Return dw_nested(nm, 4) 'namespace / static member: _ZN2NS6NSVAR$E -> NS.NSVAR
	Return dw_cleanname(nm)
End Function

Declare Function dw_tdesc(ByVal i As Long, ByVal nest As Long = 0) As String

'' The members of a struct/union (the members of the anonymous unions/structs are added at their offset)
Private Function dw_members(ByVal i As Long, ByVal baseofs As LongInt, ByVal nest As Long) As String
	Dim As String s, mnm
	Dim As Long t
	Dim As LongInt bofs, blen
	If nest > 30 Then Return ""
	For j As Long = i + 1 To dwdienb
		If dwdie(j).depth <= dwdie(i).depth Then Exit For
		If dwdie(j).depth <> dwdie(i).depth + 1 OrElse dwdie(j).tag <> &h0d Then Continue For
		t = dw_strip(dwdie(j).typ)
		If dwdie(j).nm = "" Then
			If t > 0 AndAlso (dwdie(t).tag = &h13 OrElse dwdie(t).tag = &h17) Then s += dw_members(t, baseofs + dwdie(j).memloc, nest + 1)
			Continue For
		End If
		mnm = dw_cleanname(dwdie(j).nm)
		If mnm = "" OrElse mnm[0] < 64 Then Continue For
		bofs = (baseofs + dwdie(j).memloc) * 8
		If dwdie(j).bitsz Then
			blen = dwdie(j).bitsz
			If dwdie(j).databitofs >= 0 Then
				bofs = baseofs * 8 + dwdie(j).databitofs
			ElseIf dwdie(j).hasbitofs Then
				Dim As LongInt bs = IIf(dwdie(j).hasbytesz, dwdie(j).bytesz, dw_tsize(dwdie(j).typ))
				bofs += bs * 8 - dwdie(j).bitofs - dwdie(j).bitsz
			End If
		Else
			blen = dw_tsize(dwdie(j).typ) * 8
		End If
		s += mnm + ":" + dw_tdesc(dwdie(j).typ, nest + 1) + "," + Str(bofs) + "," + Str(blen) + ";"
	Next
	Return s
End Function

'' The number of a UDT, it is declared to parse_var at the first use
Private Function dw_udt(ByVal i As Long, ByVal nest As Long) As String
	If dwdie(i).decl OrElse dwdie(i).stab < 0 Then Return "7"
	If dwdie(i).stab Then Return Str(dwdie(i).stab)
	dwtypecnt += 1
	dwdie(i).stab = dwtypecnt 'before the members: a member can be a pointer to this UDT
	Dim As String members = dw_members(i, 0, nest + 1)
	If members = "" Then dwdie(i).stab = -1: Return "7" 'parse_udt needs a member
	Dim As String nm = dw_cleanname(dwdie(i).nm)
	If nm = "" Then nm = "UDT"
	parse_var(nm + ":Tt" + Str(dwdie(i).stab) + "=s" + Str(dw_tsize(i)) + members + ";", 0)
	Return Str(dwdie(i).stab)
End Function

Private Function dw_tdesc(ByVal i As Long, ByVal nest As Long = 0) As String
	If nest > 30 Then Return "7"
	i = dw_strip(i)
	If i = 0 Then Return "7"
	Dim As Long n = dw_stdtyp(i)
	If n Then Return Str(n)
	Select Case dwdie(i).tag
	Case &h0f, &h10, &h42 'pointer, reference
		Dim As Long t = dw_strip(dwdie(i).typ)
		If t > 0 AndAlso dwdie(t).tag = &h15 Then Return "0=*0=f" + dw_tdesc(dwdie(t).typ, nest + 1) 'procedure pointer
		Return "0=*" + dw_tdesc(dwdie(i).typ, nest + 1)
	Case &h15 'subroutine
		Return "0=f" + dw_tdesc(dwdie(i).typ, nest + 1)
	Case &h01 'array
		Dim As String s
		Dim As LongInt lb, ub
		For j As Long = i + 1 To dwdienb
			If dwdie(j).depth <= dwdie(i).depth Then Exit For
			If dwdie(j).tag = &h21 AndAlso dwdie(j).depth = dwdie(i).depth + 1 Then
				lb = IIf(dwdie(j).haslb, dwdie(j).lb, 0)
				If dwdie(j).hasub Then
					ub = dwdie(j).ub
				ElseIf dwdie(j).hascnt Then
					ub = lb + dwdie(j).cnt - 1
				Else
					ub = lb
				End If
				s += "ar1;" + Str(lb) + ";" + Str(ub) + ";"
			End If
		Next
		If s = "" Then Return dw_tdesc(dwdie(i).typ, nest + 1)
		Return "0=" + s + dw_tdesc(dwdie(i).typ, nest + 1)
	Case &h13, &h17, &h02 'struct, union, class
		Return dw_udt(i, nest)
	End Select
	Return "7"
End Function

'' ---------------------------------------------------------------------------------------------------------------
'' Procedures
'' ---------------------------------------------------------------------------------------------------------------
'' The code at the address adr (in the file)
Private Function dw_code(ByVal adr As ULongInt, ByVal n As Integer) As UByte Ptr
	For i As Integer = 1 To dwmapnb
		If adr >= dwmap(i).va AndAlso adr + n <= dwmap(i).va + dwmap(i).sz Then
			Dim As Integer fo = dwmap(i).fo + (adr - dwmap(i).va)
			If fo >= 0 AndAlso fo + n <= dwbufsz Then Return dwbuf + fo
			Return 0
		End If
	Next
	Return 0
End Function

'' CFA - rbp/ebp after the prologue: DW_OP_fbreg is relative to the CFA (DW_OP_call_frame_cfa), the variables of
'' the debugger are relative to rbp/ebp
Private Function dw_cfa(ByVal adr As ULongInt) As LongInt
	Dim As LongInt dflt = 2 * dwasz, n
	Dim As UByte Ptr c = dw_code(adr, 48)
	If c = 0 Then Return dflt
	Dim As Integer i, k
	If c[0] = &hF3 AndAlso c[1] = &h0F AndAlso c[2] = &h1E AndAlso (c[3] = &hFA OrElse c[3] = &hFB) Then i = 4 'endbr64/32
	Do While i < 40
		If c[i] >= &h50 AndAlso c[i] <= &h57 Then 'push reg
			k += 1: i += 1
		ElseIf dwasz = 8 AndAlso c[i] = &h41 AndAlso c[i + 1] >= &h50 AndAlso c[i + 1] <= &h57 Then 'push r8-r15
			k += 1: i += 2
		ElseIf dwasz = 8 AndAlso c[i] = &h48 AndAlso ((c[i + 1] = &h89 AndAlso c[i + 2] = &hE5) OrElse (c[i + 1] = &h8B AndAlso c[i + 2] = &hEC)) Then
			Return 8 + 8 * k 'mov rbp, rsp
		ElseIf dwasz = 4 AndAlso ((c[i] = &h89 AndAlso c[i + 1] = &hE5) OrElse (c[i] = &h8B AndAlso c[i + 1] = &hEC)) Then
			Return 4 + 4 * k 'mov ebp, esp
		ElseIf dwasz = 8 AndAlso c[i] = &h48 AndAlso c[i + 1] = &h83 AndAlso c[i + 2] = &hEC Then 'sub rsp, imm8
			n += c[i + 3]: i += 4
		ElseIf dwasz = 8 AndAlso c[i] = &h48 AndAlso c[i + 1] = &h81 AndAlso c[i + 2] = &hEC Then 'sub rsp, imm32
			n += *Cast(Long Ptr, c + i + 3): i += 7
		ElseIf dwasz = 8 AndAlso c[i] = &h48 AndAlso c[i + 1] = &h8D AndAlso c[i + 2] = &h6C AndAlso c[i + 3] = &h24 Then
			Return 8 + 8 * k + n - CByte(c[i + 4]) 'lea rbp, [rsp+disp8]
		ElseIf dwasz = 8 AndAlso c[i] = &h48 AndAlso c[i + 1] = &h8D AndAlso c[i + 2] = &hAC AndAlso c[i + 3] = &h24 Then
			Return 8 + 8 * k + n - *Cast(Long Ptr, c + i + 4) 'lea rbp, [rsp+disp32]
		Else
			Exit Do
		End If
	Loop
	Return dflt
End Function

'' The place of a variable: 1 in the frame (v: offset from rbp/ebp), 2 static (v: address), 0 unknown
Private Function dw_loc(ByVal p As UByte Ptr, ByVal l As Long, ByVal fbofs As LongInt, ByRef v As LongInt) As Long
	If p = 0 OrElse l < 1 Then Return 0
	Dim As UByte Ptr q = p + 1
	Dim As UByte op = p[0]
	Dim As Long r
	If op = &h91 Then 'DW_OP_fbreg
		v = fbofs + dw_sleb(q): r = 1
	ElseIf op = &h70 + IIf(dwasz = 8, 6, 5) Then 'DW_OP_breg6 (rbp) / DW_OP_breg5 (ebp)
		v = dw_sleb(q): r = 1
	ElseIf op = &h03 Then 'DW_OP_addr
		v = dw_rd(q, dwasz): r = 2
	End If
	If q - p <> l Then Return 0 'more operations (thread local, ...)
	Return r
End Function

Private Sub dw_procs()
	Dim As Long prc(Any), nprc, rr(Any), nr
	Dim As ULongInt lo, hi
	For i As Long = 2 To dwdienb
		If dwdie(i).tag = &h2e AndAlso dwdie(i).depth = 1 AndAlso dwdie(i).decl = 0 AndAlso dwdie(i).lowpc <> 0 AndAlso dwdie(i).nm <> "" Then
			nprc += 1
			ReDim Preserve prc(nprc)
			prc(nprc) = i
			'sorted by address
			For j As Long = nprc To 2 Step -1
				If dwdie(prc(j)).lowpc >= dwdie(prc(j - 1)).lowpc Then Exit For
				Swap prc(j), prc(j - 1)
			Next
		End If
	Next
	For iprc As Long = 1 To nprc
		Dim As Long ip = prc(iprc)
		lo = dwdie(ip).lowpc
		hi = IIf(dwdie(ip).highrel, lo + dwdie(ip).highpc, dwdie(ip).highpc)
		If hi <= lo Then Continue For
		'The rows of the lines of the procedure (in the sources)
		nr = 0
		For i As Long = 1 To dwrownb
			If dwrow(i).endseq = 0 AndAlso dwrow(i).ad >= lo AndAlso dwrow(i).ad < hi AndAlso dwrow(i).ln > 0 Then
				If dwrow(i).fl >= dwfilelo AndAlso dwrow(i).fl <= dwfilehi AndAlso dwfilefb(dwrow(i).fl) Then
					nr += 1
					If nr > UBound(rr) Then ReDim Preserve rr(nr * 2 + 64)
					rr(nr) = i
					For j As Long = nr To 2 Step -1
						If dwrow(rr(j)).ad >= dwrow(rr(j - 1)).ad Then Exit For
						Swap rr(j), rr(j - 1)
					Next
				End If
			End If
		Next
		If nr = 0 Then Continue For
		Dim As Long df = dwdie(ip).declfile
		If df < dwfilelo OrElse df > dwfilehi OrElse dwfilefb(df) = 0 Then df = dwrow(rr(1)).fl
		Dim As String pnm = dwdie(ip).nm
		Dim As Long declline = IIf(dwdie(ip).declline > 0, dwdie(ip).declline, 1)
		dbg_include(dwfile(df))
		If CBool(Not T64) AndAlso CBool(pnm = "main") AndAlso flagmain Then linenb += 1 'dbg_proc removes the line of the stabd of gas
		dbg_proc(pnm + IIf(dwdie(ip).ext, ":F", ":f") + dw_tdesc(dwdie(ip).typ), declline, lo + dwdelta)
		If skipline Then Continue For
		'The parameters and the variables
		Dim As LongInt cfa = dw_cfa(lo), fbofs = cfa, v
		proc(procnb).frofs = cfa - 2 * dwasz 'lea rbp, [rsp+n]: the previous rbp is not at [rbp]
		If dwdie(ip).fbp <> 0 AndAlso dwdie(ip).fbl > 0 Then
			Dim As UByte Ptr q = dwdie(ip).fbp + 1
			Dim As UByte op = dwdie(ip).fbp[0]
			If op = &h70 + IIf(dwasz = 8, 6, 5) Then
				fbofs = dw_sleb(q) 'DW_OP_bregN
			ElseIf op = &h50 + IIf(dwasz = 8, 6, 5) Then
				fbofs = 0 'DW_OP_regN
			End If
		End If
		For j As Long = ip + 1 To dwdienb
			If dwdie(j).depth <= dwdie(ip).depth Then Exit For
			Dim As ULong tag = dwdie(j).tag
			If tag <> &h05 AndAlso tag <> &h34 Then Continue For
			Dim As Long k = dw_loc(dwdie(j).locp, dwdie(j).locl, fbofs, v)
			If k = 0 Then Continue For
			If tag = &h34 AndAlso Left(dwdie(j).nm, 10) = "fb$result$" Then
				If k = 1 AndAlso v <> 0 Then proc(procnb).rvadr = v 'the return value
				Continue For
			End If
			Dim As String vnm = dw_varname(dwdie(j).nm)
			If vnm = "" Then Continue For
			If tag = &h05 Then 'parameter
				If k <> 1 Then Continue For
				Dim As Long t = dw_strip(dwdie(j).typ), t2
				If t > 0 AndAlso (dwdie(t).tag = &h0f OrElse dwdie(t).tag = &h10) Then
					t2 = dw_strip(dwdie(t).typ)
					If t2 > 0 AndAlso (dwdie(t2).tag = &h13 OrElse dwdie(t2).tag = &h17 OrElse dw_stdtyp(t2) = 13) Then
						parse_var(vnm + ":v" + dw_tdesc(dwdie(t).typ), v) 'Byref String / UDT
						Continue For
					End If
				End If
				parse_var(vnm + ":p" + dw_tdesc(dwdie(j).typ), v)
			ElseIf k = 2 Then 'static
				parse_var(vnm + ":V" + dw_tdesc(dwdie(j).typ), v + dwdelta)
			Else
				parse_var(vnm + ":" + dw_tdesc(dwdie(j).typ), v)
			End If
		Next
		'The lines: line 1 at the beginning like gas64, the first row (the prologue) is in it
		dbg_line(1, 0)
		Dim As Long cf = df, pl = 1, pf = df, nlines
		Dim As ULongInt lastad = lo
		Dim As Boolean allsame = True
		For i As Long = 1 To nr
			Dim As Long ir = rr(i)
			If dwrow(ir).ad = lo Then Continue For
			If dwrow(ir).ln = pl AndAlso dwrow(ir).fl = pf Then Continue For
			If dwrow(ir).fl <> cf Then cf = dwrow(ir).fl: dbg_include(dwfile(cf))
			dbg_line(dwrow(ir).ln, dwrow(ir).ad - lo)
			pl = dwrow(ir).ln: pf = dwrow(ir).fl: lastad = dwrow(ir).ad: nlines += 1
			If pl <> declline Then allsame = False
		Next
		dbg_epilog(lastad - lo) 'the last line (End Sub/Function) is the last instruction of the procedure
		If cf <> df Then dbg_include(dwfile(df))
		dbg_proc("", 0, hi - lo)
		'The procedures added by the compiler (constructor, destructor, Let of a Type) have only the line of the Type
		If procnb <> procmain AndAlso Left(pnm, 2) = "_Z" AndAlso (nlines = 0 OrElse allsame) Then
			proc(procnb).nu = -1
			While linenb > 0 AndAlso rline(linenb).px = procnb
				linenb -= 1
			Wend
		End If
	Next
End Sub

'' ---------------------------------------------------------------------------------------------------------------
'' A compile unit: the variables, the types and the procedures of a FreeBASIC module
'' ---------------------------------------------------------------------------------------------------------------
Private Function dw_cu() As Long
	If dwdienb < 1 OrElse (dwdie(1).tag <> &h11 AndAlso dwdie(1).tag <> &h3c) Then Return 0
	Dim As String cuname = dwdie(1).nm, compdir = dwcompdir
	If dwstmt < 0 OrElse dw_lines(dwstmt, compdir) = False Then Return 0
	'The main source: <name of the C file>.bas or the first source
	Dim As Integer imain = -1
	Dim As String basnm = LCase(dw_path("", cuname, compdir))
	If InStrRev(basnm, ".") Then basnm = Left(basnm, InStrRev(basnm, ".") - 1) + ".bas"
	For i As Integer = dwfilelo To dwfilehi
		If dwfilefb(i) Then
			If imain = -1 Then imain = i
			If LCase(dwfile(i)) = basnm Then imain = i: Exit For
		End If
	Next
	If imain = -1 Then Return 0
	dbg_include(dwfile(imain))
	stabstdlast = TYPESTD
	dwtypecnt = TYPESTD
	'The global variables
	Dim As LongInt v
	For i As Long = 2 To dwdienb
		If dwdie(i).tag = &h34 AndAlso dwdie(i).depth = 1 AndAlso dwdie(i).decl = 0 Then
			If dw_loc(dwdie(i).locp, dwdie(i).locl, 0, v) = 2 Then
				Dim As String vnm = dw_varname(dwdie(i).nm)
				If vnm <> "" Then parse_var(vnm + ":S" + dw_tdesc(dwdie(i).typ), v + dwdelta)
			End If
		End If
	Next
	dw_procs()
	dbg_file("", 0) 'end of the module: the next UDTs after these ones
	Return 1
End Function

'' ---------------------------------------------------------------------------------------------------------------
'' The sections of the file (PE or ELF)
'' ---------------------------------------------------------------------------------------------------------------
Private Sub dw_setsect(ByRef nm As String, ByVal fo As ULongInt, ByVal sz As ULongInt, ByVal va As ULongInt)
	If fo >= dwbufsz Then Exit Sub
	If fo + sz > dwbufsz Then sz = dwbufsz - fo
	Dim As DwSect Ptr ps
	Select Case nm
	Case ".debug_info": ps = @dwsinfo
	Case ".debug_abbrev": ps = @dwsabbrev
	Case ".debug_line": ps = @dwsline
	Case ".debug_str": ps = @dwsstr
	Case ".debug_line_str": ps = @dwslinestr
	End Select
	If ps Then
		ps->p = dwbuf + fo
		ps->sz = sz
	ElseIf va <> 0 AndAlso sz <> 0 Then
		dwmapnb += 1
		ReDim Preserve dwmap(dwmapnb)
		dwmap(dwmapnb).va = va
		dwmap(dwmapnb).fo = fo
		dwmap(dwmapnb).sz = sz
	End If
End Sub

'' Returns the address where the file is linked (PE: ImageBase, ELF: 0), -1 if it is not a PE or an ELF file
Private Function dw_sections() As LongInt
	Dim As UByte Ptr p
	If dwbuf[0] = &h7F AndAlso dwbuf[1] = Asc("E") AndAlso dwbuf[2] = Asc("L") AndAlso dwbuf[3] = Asc("F") Then
		Dim As Boolean e64 = dwbuf[4] = 2
		Dim As ULongInt shoff
		Dim As Integer shentsize, shnum, shstrndx
		p = dwbuf + IIf(e64, &h28, &h20): shoff = dw_rd(p, IIf(e64, 8, 4))
		p = dwbuf + IIf(e64, &h3A, &h2E): shentsize = dw_rd(p, 2): shnum = dw_rd(p, 2): shstrndx = dw_rd(p, 2)
		If shoff = 0 OrElse shoff + shnum * shentsize > dwbufsz OrElse shstrndx >= shnum Then Return -1
		p = dwbuf + shoff + shstrndx * shentsize + IIf(e64, &h18, &h10)
		Dim As ULongInt stroff = dw_rd(p, IIf(e64, 8, 4))
		For i As Integer = 1 To shnum - 1
			Dim As UByte Ptr sh = dwbuf + shoff + i * shentsize
			p = sh
			Dim As ULong nmo = dw_rd(p, 4), typ = dw_rd(p, 4)
			Dim As ULongInt flags = dw_rd(p, IIf(e64, 8, 4)), va = dw_rd(p, IIf(e64, 8, 4))
			Dim As ULongInt fo = dw_rd(p, IIf(e64, 8, 4)), sz = dw_rd(p, IIf(e64, 8, 4))
			If typ = 8 OrElse (flags And &h800) <> 0 Then Continue For 'NOBITS, compressed
			If stroff + nmo >= dwbufsz Then Continue For
			dw_setsect(*Cast(ZString Ptr, dwbuf + stroff + nmo), fo, sz, va)
		Next
		Return 0
	End If
	If dwbuf[0] <> Asc("M") OrElse dwbuf[1] <> Asc("Z") Then Return -1
	p = dwbuf + &h3C
	Dim As ULong pe = dw_rd(p, 4)
	If pe + 24 > dwbufsz OrElse dwbuf[pe] <> Asc("P") OrElse dwbuf[pe + 1] <> Asc("E") Then Return -1
	p = dwbuf + pe + 6
	Dim As Integer nsec = dw_rd(p, 2)
	p = dwbuf + pe + 12
	Dim As ULong symtab = dw_rd(p, 4), nsym = dw_rd(p, 4)
	Dim As Integer optsz = dw_rd(p, 2)
	Dim As UByte Ptr opt = dwbuf + pe + 24
	p = opt
	Dim As Integer magic = dw_rd(p, 2)
	Dim As ULongInt imgbase
	If magic = &h20B Then
		p = opt + 24: imgbase = dw_rd(p, 8)
	Else
		p = opt + 28: imgbase = dw_rd(p, 4)
	End If
	Dim As UByte Ptr sec = opt + optsz
	For i As Integer = 0 To nsec - 1
		Dim As UByte Ptr sh = sec + i * 40
		If sh + 40 - dwbuf > dwbufsz Then Exit For
		Dim As String nm = Left(*Cast(ZString Ptr, sh), 8)
		If InStr(nm, Chr(0)) Then nm = Left(nm, InStr(nm, Chr(0)) - 1)
		If Left(nm, 1) = "/" AndAlso symtab <> 0 Then 'long name: in the string table after the symbols
			Dim As ULongInt so = symtab + CULngInt(nsym) * 18 + Val(Mid(nm, 2))
			If so < dwbufsz Then nm = *Cast(ZString Ptr, dwbuf + so)
		End If
		p = sh + 8
		Dim As ULong vsz = dw_rd(p, 4), va = dw_rd(p, 4), rawsz = dw_rd(p, 4), rawptr = dw_rd(p, 4)
		If rawptr = 0 OrElse rawsz = 0 Then Continue For
		dw_setsect(nm, rawptr, IIf(vsz <> 0 AndAlso vsz < rawsz, vsz, rawsz), imgbase + va)
	Next
	Return imgbase
End Function

'' ---------------------------------------------------------------------------------------------------------------
'' Loads the DWARF of the FreeBASIC modules of nfile (the program or a DLL loaded at loadbase, 0: not moved)
'' Returns the number of FreeBASIC modules
'' ---------------------------------------------------------------------------------------------------------------
Private Function dwarf_extract(ByRef nfile As String, ByVal loadbase As ULongInt = 0) As Long
	Dim As Long nb
	Dim As Long ff = FreeFile_
	If Open(nfile For Binary Access Read As #ff) <> 0 Then Return 0
	dwbufsz = LOF(ff)
	If dwbufsz < 256 Then CloseFile_(ff): Return 0
	dwbuf = Allocate(dwbufsz + 16)
	If dwbuf = 0 Then CloseFile_(ff): Return 0
	Get #ff, 1, *dwbuf, dwbufsz
	CloseFile_(ff)
	dwbuf[dwbufsz] = 0
	dwsinfo.p = 0: dwsabbrev.p = 0: dwsline.p = 0: dwsstr.p = 0: dwslinestr.p = 0
	dwmapnb = 0: dwabofs = -1: dwerr = 0
	Dim As LongInt imgbase = dw_sections()
	If imgbase <> -1 AndAlso dwsinfo.p <> 0 AndAlso dwsabbrev.p <> 0 AndAlso dwsline.p <> 0 Then
		dwdelta = IIf(loadbase <> 0 AndAlso imgbase > 0, loadbase - imgbase, 0)
		Dim As UByte Ptr p = dwsinfo.p, pe = dwsinfo.p + dwsinfo.sz
		Do While p + 11 < pe
			Dim As UByte Ptr pcu = p
			Dim As ULongInt ulen = dw_rd(p, 4)
			dwosz = 4
			If ulen = &hFFFFFFFFull Then ulen = dw_rd(p, 8): dwosz = 8
			Dim As UByte Ptr pnext = p + ulen
			If ulen = 0 OrElse pnext > pe Then Exit Do
			dwcuofs = pcu - dwsinfo.p
			dwversion = dw_rd(p, 2)
			Dim As ULongInt abofs
			Dim As Boolean cuok = dwversion >= 2 AndAlso dwversion <= 5
			If cuok Then
				If dwversion >= 5 Then
					Dim As Integer utype = dw_rd(p, 1)
					dwasz = dw_rd(p, 1)
					abofs = dw_rd(p, dwosz)
					If utype = 4 OrElse utype = 5 Then p += 8 'skeleton, split_compile: dwo_id
					cuok = utype = 1 OrElse utype = 3 'compile, partial (not the type units)
				Else
					abofs = dw_rd(p, dwosz)
					dwasz = dw_rd(p, 1)
				End If
				cuok = cuok AndAlso (Cbool(dwasz = 4) OrElse Cbool(dwasz = 8))
			End If
			If cuok Then
				dwerr = 0
				dw_abbrevs(abofs)
				If dw_dies(p, pnext) Then nb += dw_cu()
				dwerr = 0
			End If
			p = pnext
		Loop
	End If
	Deallocate dwbuf: dwbuf = 0: dwbufsz = 0
	Erase dwdie, dwrow, dwfile, dwfilefb, dwab, dwabat, dwmap
	dwdienb = 0: dwrownb = 0: dwabnb = 0: dwabatnb = 0: dwmapnb = 0: dwabofs = -1
	Return nb
End Function
