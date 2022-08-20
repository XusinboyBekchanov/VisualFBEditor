'################################################################################
'#  SQLite3Component.bas                                                        #
'#  Based on:                                                                   #
'#   ClsSqlite3.inc                                                             #
'#   VisualFreeBasic Controls                                                   #
'#   Copyright (c) 2022 Yongfang Software Development Team www.yfvb.com         #
'#   Version 2.0.0.105                                                          #
'#  Adapted to Visual FB Editor ToolBox                                         #
'#  by Xusinboy Bekchanov (2022)                                                #
'################################################################################

#include once "SQLite3Component.bi"
Extern "C"
	Declare Function sqlite3_key Lib "sqlite3" Alias "sqlite3_key"(ByVal db As Any Ptr,ByVal pKey As Const ZString Ptr,ByVal nKey As Integer)     As Integer
	Declare Function sqlite3_rekey Lib "sqlite3" Alias "sqlite3_rekey"(ByVal db As Any Ptr,ByVal pKey As Const ZString Ptr,ByVal nKey As Integer) As Integer
End Extern

Private Function SQLite3Component.ReadProperty(PropertyName As String) As Any Ptr
	Select Case LCase(PropertyName)
	Case Else: Return Base.ReadProperty(PropertyName)
	End Select
	Return 0
End Function

Private Function SQLite3Component.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
	Select Case LCase(PropertyName)
	Case Else: Return Base.WriteProperty(PropertyName, Value)
	End Select
	Return True
End Function

Function SQLite3Component.Open(ByRef FileName As WString, ByRef Password As WString = "") As Boolean
	If FSQLite3 Then sqlite3_close(FSQLite3)
	FSQLite3 = 0
	If FSQLite3Mem Then sqlite3_close(FSQLite3Mem)
	FSQLite3Mem = 0
	If Len(FileName) = 0 Then
		ErrStr = "File name is empty": This.Event_Send(12, ErrStr)
		Return False
	End If
	Dim r As Long, sFileName_Utf8 As String = ToUtf8(FileName)
	r = sqlite3_open(StrPtr(sFileName_Utf8), @FSQLite3)
	If r Then
		ErrStr = *sqlite3_errmsg(FSQLite3)
		ErrStr = FromUtf8(Str(ErrStr)): This.Event_Send(12, ErrStr)
		sqlite3_close(FSQLite3)
		Return False
	End If
	If Len(Password) Then
		Dim Password_Utf8 As String = ToUtf8(Password)
		If sqlite3_key(FSQLite3, StrPtr(Password_Utf8), Len(Password_Utf8)) Then
			ErrStr =  *sqlite3_errmsg(FSQLite3)
			ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12, ErrStr)
			sqlite3_close(FSQLite3)
			Return False
		End If
	End If
	Dim rs() As String
	EventsEn = 1
	If SQLFind("PRAGMA database_list", rs()) Then
		If UBound(rs) = -1 Or UBound(rs, 2) = -1 Then
			ErrStr = "Not found base": This.Event_Send(12, ErrStr)
			sqlite3_close(FSQLite3)
			Return False
		End If
	Else
		ErrStr =  *sqlite3_errmsg(FSQLite3)
		ErrStr = FromUtf8(Str(ErrStr)): This.Event_Send(12, ErrStr)
		sqlite3_close(FSQLite3)
		Return False
	End If
	EventsEn = 0
	ErrStr   = ""
	
	Function = True
End Function

Function SQLite3Component.MemOpen(sFileName As UString, Password As UString = "", Synchronization As Boolean = 0) As Boolean
	If FSQLite3 Then sqlite3_close(FSQLite3)
	FSQLite3 = 0
	Dim r As Long, sFileName_Utf8 As String = ToUtf8(sFileName)
	r = sqlite3_open(":memory:", @FSQLite3)
	
	If r Then
		ErrStr = *sqlite3_errmsg(FSQLite3)
		ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12, ErrStr)
		sqlite3_close(FSQLite3)
		Return False
	End If
	Dim pFile As sqlite3 Ptr
	If Len(sFileName_Utf8) Then
		r = sqlite3_open(StrPtr(sFileName_Utf8), @FSQLite3Mem)
		If r Then
			ErrStr = *sqlite3_errmsg(FSQLite3Mem)
			ErrStr = FromUtf8(Str(ErrStr)): This.Event_Send(12, ErrStr)
			sqlite3_close(FSQLite3)
			sqlite3_close(FSQLite3Mem)
			Return False
		End If
		If Password Then 'УРГЬВл
			Dim Password_Utf8 As String = ToUtf8(Password)
			If sqlite3_key(FSQLite3Mem,StrPtr(Password_Utf8),Len(Password_Utf8)) Then
				ErrStr = *sqlite3_errmsg(FSQLite3Mem)
				ErrStr = FromUtf8(Str(ErrStr)): This.Event_Send(12, ErrStr)
				sqlite3_close(FSQLite3)
				sqlite3_close(FSQLite3Mem)
				Return False
			End If
		End If
		Dim rs() As String
		EventsEn = 1
		If SqlFind("PRAGMA database_list",rs()) Then
			If UBound(rs) = -1 Or UBound(rs,2) = -1 Then
				ErrStr = "Base not found": This.Event_Send(12, ErrStr)
				sqlite3_close(FSQLite3)
				sqlite3_close(FSQLite3Mem)
				Return False
			End If
		Else
			ErrStr = *sqlite3_errmsg(Cast(Any Ptr,FSQLite3))
			ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12,ErrStr)
			sqlite3_close(FSQLite3)
			sqlite3_close(FSQLite3Mem)
			Return False
		End If
		EventsEn = 0
		Dim pBackup As sqlite3_backup Ptr = sqlite3_backup_init(FSQLite3, "main", FSQLite3Mem, "main")
		If pBackup Then
			sqlite3_backup_step(pBackup, -1)
			sqlite3_backup_finish(pBackup)
		Else
			ErrStr = *sqlite3_errmsg(Cast(Any Ptr,FSQLite3))
			ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12,ErrStr)
			sqlite3_close(FSQLite3)
			sqlite3_close(FSQLite3Mem)
			Return False
		End If
		FSynchronization = Cast(Integer, Synchronization)
	End If
	
	ErrStr   = ""
	Function = True
End Function

Function SQLite3Component.MemSave() As Boolean
	If FSQLite3 = 0 Then ErrStr = "Base not opened": This.Event_Send(12, ErrStr)  : Return False
	If FSQLite3Mem = 0 Then ErrStr = "Memory base not opened": This.Event_Send(12, ErrStr) : Return False
	
	Dim r As Long
	Dim pBackup As sqlite3_backup Ptr = sqlite3_backup_init(FSQLite3Mem, "main", FSQLite3, "main")
	If pBackup Then
		sqlite3_backup_step(pBackup, -1)
		sqlite3_backup_finish(pBackup)
	Else
		ErrStr = *sqlite3_errmsg(FSQLite3Mem)
		ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12,ErrStr)
		Return False
	End If
	ErrStr = "" ' ОЮґнОу
	Function = True
End Function
Sub SQLite3Component.Close()
	ErrStr = ""
	If FSQLite3 Then
		sqlite3_close(FSQLite3)
		FSQLite3 = 0
	End If
	If FSQLite3Mem Then
		sqlite3_close(FSQLite3Mem)
		FSQLite3Mem = 0
	End If
End Sub
Function SQLite3Component.GetSQLitePtr(Index As Long = 0) As sqlite3 Ptr
	ErrStr = ""
	If Index < 0 Or Index > 1 Then ErrStr = "Index is invalid": This.Event_Send(12, ErrStr): Return 0
	Select Case Index
	Case 0
		Function = FSQLite3
	Case 1
		Function = FSQLite3Mem
	End Select
End Function
Function SQLite3Component.ErrMsg() As String
	Function = ErrStr
End Function
Function SQLite3Component.Version() As String                                             '°ж±ѕєЕ
	Function = *sqlite3_libversion()
End Function

Function SQLite3Component.SetKey(newkey As UString) As Boolean   'ЙиЦГГЬВлЈ¬Из№ыОЄїХЈ¬ИЎПыГЬВл
	Dim m_DB As sqlite3 Ptr = FSQLite3
	If m_DB = NULL Then ErrStr = "Base not opened": This.Event_Send(12, ErrStr)  : Return False
	ErrStr = "" ' ОЮґнОу"
	If Len(newkey) = 0 Then
		If sqlite3_rekey(m_DB, NULL, 0) Then
			ErrStr = *sqlite3_errmsg(m_DB)
			ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12,ErrStr)
			Return False
		Else
			If FSQLite3Mem <> 0 And FSynchronization <> 0 Then sqlite3_rekey(FSQLite3Mem, NULL, 0)
			Return True
		End If
	Else
		Dim snewkey  As String = ToUtf8(newkey)
		If sqlite3_rekey(m_DB, StrPtr(snewkey), Len(snewkey)) Then
			ErrStr = *sqlite3_errmsg(m_DB)
			ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12,ErrStr)
			Return False
		Else
			If FSQLite3Mem <> 0 And FSynchronization <> 0 Then sqlite3_rekey(FSQLite3Mem, StrPtr(snewkey), Len(snewkey))
			Return True
		End If
	End If
	
End Function

Function SQLite3Component.SQLFind(Sql_Utf8 As String, rs() As String) As Long
	Dim m_DB As sqlite3 Ptr = FSQLite3
	If m_DB = NULL Then ErrStr = "Base not opened": This.Event_Send(12, ErrStr)  : Return 0
	If This.Event_Send(11, Sql_Utf8) <> 0 Then Return 0
	Dim ppStmt As sqlite3_stmt Ptr, pzTail As ZString Ptr
	
	Dim rr As Long = sqlite3_prepare(m_DB, StrPtr(Sql_Utf8), -1, @ppStmt, @pzTail)
	
	Dim As Long u,i
	If ppStmt = 0 Then
		ErrStr = *sqlite3_errmsg(m_DB)
		ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12, ErrStr)
		Return 0
	End If
	u = sqlite3_column_count(ppStmt)
	If u = 0 Then ErrStr = "Columns not found": This.Event_Send(12, ErrStr)  : Return 0
	
	Dim lpTable As ZString Ptr Ptr
	Dim nRows As Long         
	Dim nColumns As Long       
	Dim iFields As Integer     
	Dim iRow As Integer
	Dim iCol As Integer
	Dim lpErrorSz As ZString Ptr
	
	If sqlite3_get_table(m_DB, StrPtr(Sql_Utf8), @lpTable, @nRows, @nColumns, @lpErrorSz) = 0 Then 'іЙ№¦
		
		If nRows = 0 Then
			ErrStr = "Not found": This.Event_Send(12, ErrStr)
		Else
			iFields = ((nRows + 1) * nColumns) -1
			ReDim rs(nRows, nColumns -1)
			
			If UBound(rs) > 0 Then
				Dim r As Long
				For i = 0 To iFields
					If iCol = 0 Then
						'If m_FindRsProc<>0 And EventsEn = 0 Then
						'   r = pp(iRow, iCol, lpTable[i], Len( *lpTable[i]), nRows, u, ppStmt)
						'Else
						r = 0
						'End If
					End If
					If r = 2 Then Exit For
					If r <> 1 Then
						rs(iRow, iCol) = *lpTable[i]  'ТтОЄОД±ѕКЗ UTF8 µД
					End If
					iCol += 1 : If iCol = nColumns Then iCol = 0
					If (i + 1) Mod nColumns = 0 Then iRow += 1
				Next i
				ErrStr = ""
				If Transaction Then Transaction += 1
			Else
				nRows = 0
				ErrStr = "ReDim not work": This.Event_Send(12, ErrStr)  ' "
			End If
			
		End If
	Else
		nRows = 0
		ErrStr = *sqlite3_errmsg(m_DB)
		ErrStr = FromUtf8(Str(ErrStr)): This.Event_Send(12, ErrStr)
	End If
	sqlite3_finalize(ppStmt)
	sqlite3_free_table lpTable
	Function = nRows
End Function
Function SQLite3Component.SQLFindOne(Sql_Utf8 As String, rs() As String) As Long
	Dim m_DB As sqlite3 Ptr = FSQLite3
	If m_DB = NULL Then ErrStr = "Base not opened": This.Event_Send(12, ErrStr)  : Return 0
	If This.Event_Send(11, Sql_Utf8) <> 0 Then Return 0
	Dim ppStmt As sqlite3_stmt Ptr, pzTail As ZString Ptr
	Dim rr As Long = sqlite3_prepare(m_DB, StrPtr(Sql_Utf8), -1, @ppStmt, @pzTail) ' Чј±ёЦґРРSQL
	Dim As Long i
	If ppStmt = 0 Then
		ErrStr = *sqlite3_errmsg(m_DB)
		ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12,ErrStr)
		Return 0
	End If
	
	'ІйСЇДЪИЭ----------------------------------------------------------------------------------------------
	Dim lpTable As ZString Ptr Ptr ' ·µ»Шёш¶Ё±нµДКэЧйЦёХлЈЁґУБРГыіЖЈ©
	Dim nRows As Long         ' ·µ»ШµДјЗВјјЇµДРРКэ
	Dim nColumns As Long         ' ·µ»ШµДјЗВјјЇµДБРКэ
	Dim iFields As Integer         ' ·µ»Ш±н·µ»ШµДЧЦ¶ОКэ
	Dim iRow As Integer
	Dim iCol As Integer
	Dim lpErrorSz As ZString Ptr         ' ґнОуРЕПў
	'Dim pp As Function(pi As Long, ci As Long, nData As ZString Ptr, siz As Long, Rows As Long, Columns As Long, ppStmt As sqlite3_stmt Ptr) As Long = m_FindRsProc
	If sqlite3_get_table(m_DB, StrPtr(Sql_Utf8), @lpTable, @nRows, @nColumns, @lpErrorSz) = 0 Then 'іЙ№¦
		If nColumns = 0 Then
			ErrStr = "ОЮјЗВј" :This.Event_Send(12,ErrStr)  ' "
		Else
			iFields = ((nRows + 1) * nColumns) -1
			ReDim rs(nColumns -1)
			If UBound(rs) > -1 Then
				Dim r As Long
				For i = nColumns To iFields
					'if m_FindRsProc<>0 and EventsEn = 0  Then
					'   r = pp(1, iCol, lpTable[i], Len( *lpTable[i]), 1, nColumns, ppStmt)
					'Else
					r = 0
					'End If
					If r = 2 Then Exit For
					If r <> 1 Then
						rs(iCol) = *lpTable[i]
					End If
					iCol += 1 : If iCol = nColumns Then iCol = 0
					If (i + 1) Mod nColumns = 0 Then iRow += 1
				Next i
				ErrStr = ""
				If Transaction Then Transaction += 1
			Else
				nColumns = 0
				ErrStr = "ReDim not work": This.Event_Send(12, ErrStr)   '
			End If
		End If
	Else
		nColumns = 0
		ErrStr = *sqlite3_errmsg(m_DB)
		ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12,ErrStr)
	End If
	sqlite3_finalize(ppStmt)
	sqlite3_free_table lpTable
	Function = nColumns
	
End Function
Function SQLite3Component.Find(Table As UString,Cond As UString,rs() As String,Col As UString = "*",Orderby As UString = "",Page As Long = 1,Pagesize As Long = 0) As Long
	Dim m_DB As sqlite3 Ptr = FSQLite3
	If m_DB = NULL    Then ErrStr = "Base not opened": This.Event_Send(12, ErrStr)  : Return 0
	If Len(Table) = 0 Then ErrStr = "ОЮ±нГы" :This.Event_Send(12,ErrStr)       : Return 0 ' ОЮ±нГы"
	Dim Col_Utf8 As String = ToUtf8(Col)
	Dim Sql_Utf8 As String = "SELECT " & Col_Utf8 & " FROM " & ToUtf8(Table)
	
	If Len(Cond)    Then Sql_Utf8 &= " WHERE "    & ToUtf8(Cond)
	If Len(Orderby) Then Sql_Utf8 &= " ORDER BY " & ToUtf8(Orderby)
	If Pagesize > 0 Then
		Dim n As Long = (Page -1) * Pagesize
		Sql_Utf8 &= " LIMIT " & n & "," & Pagesize
	End If
	'   Print "Find=" & Sql_Utf8
	
	Function = SQLFind(Sql_Utf8,rs())
End Function
Function SQLite3Component.FindUtf(Table_Utf8 As String, Cond_Utf8 As String, rs_Utf8() As String, Col_Utf8 As String = "*", Orderby_Utf8 As String = "", Page As Long = 1, Pagesize As Long = 0) As Long
	Dim m_DB As sqlite3 Ptr = FSQLite3
	If m_DB = NULL         Then ErrStr = "Base not opened":This.Event_Send(12,ErrStr)  : Return 0
	If Len(Table_Utf8) = 0 Then ErrStr = "ОЮ±нГы" : This.Event_Send(12, ErrStr)       : Return 0 ' ОЮ±нГы"
	Dim Sql_Utf8 As String = "SELECT " & Col_Utf8 & " FROM " & Table_Utf8
	
	If Len(Cond_Utf8)    Then Sql_Utf8 &= " WHERE "    & Cond_Utf8
	If Len(Orderby_Utf8) Then Sql_Utf8 &= " ORDER BY " & Orderby_Utf8
	If Pagesize > 0 Then
		Dim n As Long = (Page -1) * Pagesize
		Sql_Utf8 &= " LIMIT " & n & "," & Pagesize
	End If
	'   Print "Find=" & Sql_Utf8
	
	Function = SQLFind(Sql_Utf8,rs_Utf8())
End Function
Function SQLite3Component.FindByte(Table As UString,Cond As UString,rs() As String,Col As UString = "*",Orderby As UString = "",Page As Long = 1,Pagesize As Long = 0) As Long
	Function = This.FindByteUtf(ToUtf8(Table),ToUtf8(Cond),rs(),ToUtf8(Col),ToUtf8(Orderby),Page,Pagesize)
End Function
Function SQLite3Component.FindByteUtf(Table_Utf8 As String,Cond_Utf8 As String,rs_Utf8() As String,Col_Utf8 As String = "*",Orderby_Utf8 As String = "",Page As Long = 1,Pagesize As Long = 0) As Long
	Dim m_DB As sqlite3 Ptr = FSQLite3
	If m_DB = NULL         Then ErrStr = "Base not opened":This.Event_Send(12,ErrStr)  : Return 0
	If Len(Table_Utf8) = 0 Then ErrStr = "ОЮ±нГы": This.Event_Send(12, ErrStr)        : Return 0 ' ОЮ±нГы"
	Dim Sql_Utf8 As String = "SELECT " & Col_Utf8 & " FROM " & Table_Utf8
	If Len(Cond_Utf8)    Then Sql_Utf8 &= " WHERE "    & Cond_Utf8
	If Len(Orderby_Utf8) Then Sql_Utf8 &= " ORDER BY " & Orderby_Utf8
	If Pagesize > 0 Then
		Dim n As Long = (Page -1) * Pagesize
		Sql_Utf8 &= " LIMIT " & n & "," & Pagesize
	End If
	'   Print "Find=" & Sql_Utf8,m_DB
	Dim ppStmt As sqlite3_stmt Ptr,pzTail As ZString Ptr
	Dim rr     As Long = sqlite3_prepare(m_DB,StrPtr(Sql_Utf8), -1,@ppStmt,@pzTail) ' Чј±ёЦґРРSQL
	
	Dim As Long u,i,yu,yi
	If ppStmt = 0 Then
		ErrStr = *sqlite3_errmsg(m_DB)
		ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12,ErrStr)
		Return 0
	End If
	
	u = sqlite3_column_count(ppStmt) 'ёщѕЭselectУпѕдµД¶ФПуЈ¬»сИЎЅб№ыјЇЦРµДЧЦ¶ОКэБїЈ¬Ц»УРselectІЕУРЈ¬ЖдЛьОЄ0ЎЈ
	If u > 0 Then
		yu = This.CountUtf(Table_Utf8,Cond_Utf8)
		ReDim rs_Utf8(yu,u -1)
		If UBound(rs_Utf8) = -1 Then
			ErrStr = "·µ»ШКэЧй±»ЛшЈ¬ОЮ·ЁК№УГ ReDim":This.Event_Send(12,ErrStr)  ' "
			Return 0
		End If
		For i = 0 To u -1
			'·µ»ШЦµЛµГчКэѕЭАаРН
			'1ЈєSQLITE_INTEGER
			'2ЈєSQLITE_FLOAT
			'3ЈєSQLITE_TEXT
			'4ЈєSQLITE_BLOB
			'5ЈєSQLITE_NULL
			rs_Utf8(0,i) = *sqlite3_column_name(ppStmt,i) '»сИЎЧЦ¶ОГыіЖ
			''t=sqlite3_database_name( ppStmt, i )'»сИЎКэѕЭївГыіЖ
			''t=sqlite3_table_name( ppStmt, i )  '»сИЎ±нµДГыіЖ
		Next
		Dim value As Any Ptr
		Dim siz   As Long
		Dim r     As Long
		'Dim pp    As Function(pi As Long,ci As Long,nData As ZString Ptr,siz As Long,Rows As Long,Columns As Long,ppStmt As sqlite3_stmt Ptr) As Long = m_FindRsProc
		While (sqlite3_step(ppStmt) = SQLITE_ROW) 'НкіЙєуНЛіц
			yi += 1
			If yi > yu Then Exit While
			For i = 0 To u -1
				Select Case sqlite3_column_type(ppStmt,i) '»сИЎЖдЙщГчК±µДАаРНЎЈ
					'Case 1 'ЈєSQLITE_INTEGER
					'rs(yi, i) = Str(sqlite3_column_int(ppStmt, i))
					'if m_FindRsProc<>0 and EventsEn = 0 Then
					'r = pp(yi, i, yu, StrPtr(rs(yi, i)),Len(rs(yi, i)),yu,u,ppStmt)
					'Else
					'r = 0
					'End if
					'if r = 2 Then Exit While
					'Case 2 'ЈєSQLITE_FLOAT
				Case 1,2,3 'ЈєSQLITE_TEXT
					value = Cast(Any Ptr,sqlite3_column_text(ppStmt,i)) 'КэѕЭЦёХл
					siz   = sqlite3_column_bytes(ppStmt,i)               'КэѕЭі¤¶И
					'if m_FindRsProc <> 0 and EventsEn = 0 Then
					'   r = pp(yi,i,value,siz,yu,u,ppStmt)
					'Else
					r = 0
					'End if
					If r = 2 Then Exit While
					If siz And r <> 1 Then
						rs_Utf8(yi,i) = String(siz,0)
						memcpy StrPtr(rs_Utf8(yi,i)),value,siz
					End If
				Case 4 'ЈєSQLITE_BLOB
					value = Cast(Any Ptr,sqlite3_column_blob(ppStmt,i)) 'КэѕЭЦёХл
					siz   = sqlite3_column_bytes(ppStmt,i)               'КэѕЭі¤¶И
					'if m_FindRsProc <> 0 and EventsEn = 0 Then
					'   r = pp(yi,i,value,siz,yu,u,ppStmt)
					'Else
					r = 0
					'End if
					If r = 2 Then Exit While
					If siz And r <> 1 Then
						rs_Utf8(yi,i) = String(siz,0)
						memcpy StrPtr(rs_Utf8(yi,i)),value,siz
					End If
					
				Case 5 'ЈєSQLITE_NULL
				End Select
				
			Next
		Wend
		If Transaction Then Transaction += 1
	End If
	ErrStr = ""
	sqlite3_finalize(ppStmt) 'КН·Е
	Function = yu
End Function
Function SQLite3Component.FindOneByte(Table As UString,Cond As UString,rs_Utf8() As String,Col As UString = "*",Orderby As UString = "") As Long
	Function = This.FindOneByteUtf(ToUtf8(Table),ToUtf8(Cond),rs_Utf8(),ToUtf8(Col),ToUtf8(Orderby))
End Function
Function SQLite3Component.FindOneByteUtf(Table_Utf8 As String,Cond_Utf8 As String,rs_Utf8() As String,Col_Utf8 As String = "*",Orderby_Utf8 As String = "") As Long
	Dim m_DB As sqlite3 Ptr = FSQLite3
	If m_DB = NULL         Then ErrStr = "Base not opened":This.Event_Send(12,ErrStr)  : Return 0
	If Len(Table_Utf8) = 0 Then ErrStr = "ОЮ±нГы"  : This.Event_Send(12, ErrStr)     : Return 0 ' ОЮ±нГы"
	Dim Sql_Utf8 As String = "SELECT " & Col_Utf8 & " FROM " & Table_Utf8
	If Len(Cond_Utf8)    Then Sql_Utf8 &= " WHERE "    & Cond_Utf8
	If Len(Orderby_Utf8) Then Sql_Utf8 &= " ORDER BY " & Orderby_Utf8
	Sql_Utf8 &= " LIMIT 1"
	
	Dim ppStmt As sqlite3_stmt Ptr,pzTail As ZString Ptr
	Dim rr     As Long = sqlite3_prepare(m_DB,StrPtr(Sql_Utf8), -1,@ppStmt,@pzTail) ' Чј±ёЦґРРSQL
	Dim As Long u,i
	If ppStmt = 0 Then
		ErrStr = *sqlite3_errmsg(m_DB)
		ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12,ErrStr)
		Return 0
	End If
	
	u = sqlite3_column_count(ppStmt) 'ёщѕЭselectУпѕдµД¶ФПуЈ¬»сИЎЅб№ыјЇЦРµДЧЦ¶ОКэБїЈ¬Ц»УРselectІЕУРЈ¬ЖдЛьОЄ0ЎЈ
	If u > 0 Then
		ReDim rs_Utf8(u -1)
		If UBound(rs_Utf8) = -1 Then
			ErrStr = "·µ»ШКэЧй±»ЛшЈ¬ОЮ·ЁК№УГ ReDim":This.Event_Send(12,ErrStr)  ' "
			Return 0
		End If
		
		Dim value As Any Ptr
		Dim siz   As Long
		Dim r     As Long
		'Dim pp    As Function(pi As Long,ci As Long,nData As ZString Ptr,siz As Long,Rows As Long,Columns As Long,ppStmt As sqlite3_stmt Ptr) As Long = m_FindRsProc
		If (sqlite3_step(ppStmt) = SQLITE_ROW) Then 'НкіЙєуНЛіц
			For i = 0 To u -1
				'Print "Type=" & sqlite3_column_type(ppStmt, i) , *CPtr(LongInt Ptr,sqlite3_column_value(ppStmt, i) )
				Select Case sqlite3_column_type(ppStmt,i) '»сИЎЖдЙщГчК±µДАаРНЎЈ
					'Case 1 'ЈєSQLITE_INTEGER
					'rs_Utf8(i) = Str(sqlite3_column_int(ppStmt, i))
					'if m_FindRsProc <> 0 and EventsEn = 0 Then
					'r = pp(1, i,StrPtr(rs_Utf8(i)), Len(rs_Utf8(i)), 1, u, ppStmt)
					'Else
					'r = 0
					'End if
					'if r = 2 Then Exit While
					'Case 2 'ЈєSQLITE_FLOAT
					'rs_Utf8(i) = Str(sqlite3_column_double(ppStmt, i))
					
				Case 1,2,3 'ЈєSQLITE_TEXT
					value = Cast(Any Ptr,sqlite3_column_text(ppStmt,i)) 'КэѕЭЦёХл
					siz   = sqlite3_column_bytes(ppStmt,i)               'КэѕЭі¤¶И
					'if m_FindRsProc <> 0 and EventsEn = 0 Then
					'   r = pp(1,i,value,siz,1,u,ppStmt)
					'Else
					r = 0
					'End if
					If r = 2 Then Exit For
					If siz And r <> 1 Then
						rs_Utf8(i) = String(siz,0)
						memcpy StrPtr(rs_Utf8(i)),value,siz
					End If
				Case 4 'ЈєSQLITE_BLOB
					value = Cast(Any Ptr,sqlite3_column_blob(ppStmt,i)) 'КэѕЭЦёХл
					siz   = sqlite3_column_bytes(ppStmt,i)               'КэѕЭі¤¶И
					'if m_FindRsProc <> 0 and EventsEn = 0 Then
					'   r = pp(1,i,value,siz,1,u,ppStmt)
					'Else
					r = 0
					'End if
					If r = 2 Then Exit For
					If siz And r <> 1 Then
						rs_Utf8(i) = String(siz,0)
						memcpy StrPtr(rs_Utf8(i)),value,siz
					End If
					
				Case 5 'ЈєSQLITE_NULL
				End Select
				
			Next
		Else
			u = 0
		End If
		If Transaction Then Transaction += 1
	End If
	ErrStr = ""
	sqlite3_finalize(ppStmt) 'КН·Е
	Function = u
End Function
Function SQLite3Component.FindOne(Table As UString,Cond As UString,rs() As String,Col As UString = "*",Orderby As UString = "") As Long
	If FSQLite3 = 0 Then ErrStr = "Base not opened":This.Event_Send(12,ErrStr)  : Return 0
	
	If Len(Table) = 0 Then ErrStr = "ОЮ±нГы": This.Event_Send(12, ErrStr)  : Return 0 ' ОЮ±нГы"
	Dim Col_Utf8 As String = "*"
	If Col Then Col_Utf8 = ToUtf8(Col)
	Dim Sql_Utf8 As String = "SELECT " & Col_Utf8 & " FROM " & ToUtf8(Table)
	If Len(Cond) > 0 Then Sql_Utf8 &= " WHERE "    & ToUtf8(Cond)
	If Len(Orderby)  Then Sql_Utf8 &= " ORDER BY " & ToUtf8(Orderby)
	Sql_Utf8 &= " LIMIT 1"
	'   Print FromUTF8(Sql_Utf8)
	Function = SQLFindOne(Sql_Utf8,rs())
End Function
Function SQLite3Component.FindOneUtf(Table_Utf8 As String,Cond_Utf8 As String,rs_Utf8() As String,Col_Utf8 As String = "*",Orderby_Utf8 As String = "") As Long
	If  FSQLite3 = 0  Then ErrStr = "Base not opened":This.Event_Send(12,ErrStr)  : Return 0
	
	If Len(Table_Utf8) = 0 Then ErrStr = "ОЮ±нГы" : This.Event_Send(12, ErrStr) : Return 0 ' ОЮ±нГы"
	Dim Sql_Utf8 As String = "SELECT " & Col_Utf8 & " FROM " & Table_Utf8
	If Len(Cond_Utf8) > 0 Then Sql_Utf8 &= " WHERE "    & Cond_Utf8
	If Len(Orderby_Utf8)  Then Sql_Utf8 &= " ORDER BY " & Orderby_Utf8
	Sql_Utf8 &= " LIMIT 1"
	Function = SQLFindOne(Sql_Utf8,rs_Utf8())
End Function
Function SQLite3Component.FindOnly(Table As UString,Cond As UString,Col As UString = "*",Orderby As UString = "") As String
	Dim rs() As String
	If This.FindOne(Table,Cond,rs(),Col,Orderby) Then
		Return rs(0)
	End If
End Function
Function SQLite3Component.FindOnlyUtf(Table_Utf8 As String,Cond_Utf8 As String,Col_Utf8 As String = "*",Orderby_Utf8 As String = "") As String
	Dim rs() As String
	If This.FindOneUtf(Table_Utf8,Cond_Utf8,rs(),Col_Utf8,Orderby_Utf8) Then
		Return rs(0)
	End If
End Function
Function SQLite3Component.Insert(Table As UString, nList As UString) As Long    'ІеИлТ»МхјЗВјЈ¬іЙ№¦·µ»ШІеИлµД IDЈ¬К§°Ь·µ»Ш FALSEЎЈ
	'nList   ТЄРВФцµДБР±нЈ¬ЧЦ¶ОГы=Цµ Ј¬ИзЈє  ЧЦ¶ОГы1=1,ЧЦ¶ОГы2= 'dd'  ЧЦ·ыУГµҐТэєЕЈ¬2ёцµҐТэєЕ±нКѕ 1ёцµҐТэєЕЧЦ·ы
	Dim Table_Utf8 As String = ToUtf8(Table)
	Dim nList_Utf8 As String = ToUtf8(nList)
	Function = This.InsertUtf(Table_Utf8,nList_Utf8)
End Function
Function SQLite3Component.InsertUtf(Table_Utf8 As String,nList_Utf8 As String)                                       As Long    'ІеИлТ»МхјЗВјЈ¬іЙ№¦·µ»ШІеИлµД IDЈ¬К§°Ь·µ»Ш FALSEЎЈ
	Dim m_DB As sqlite3 Ptr = FSQLite3
	If m_DB = NULL Then ErrStr = "Base not opened":This.Event_Send(12,ErrStr)  : Return 0
	If Len(Table_Utf8) = 0 Then ErrStr = "ОЮ±нГы":This.Event_Send(12,ErrStr)  : Return 0   ' ОЮ±нГы"
	If Len(nList_Utf8) = 0 Then ErrStr = "ОЮДЪИЭ": This.Event_Send(12, ErrStr)  : Return 0
	Dim zd As String = nList_Utf8, vl As String = ")VALUES(" & nList_Utf8
	Dim i As Long, zdi As Long = 1, vli As Long = 8, zv As Long
	zd[0] = 40 ' (
	Dim zz As Long 'ЧЦ·ыЧґМ¬
	For i = 0 To Len(nList_Utf8) -1
		If zz <> 0 Then 'ЧЦ·ыЧґМ¬
			If zv = 0 Then ErrStr = "КэѕЭіцґн":This.Event_Send(12,ErrStr)  : Return 0 ' "
			If nList_Utf8[i] = 39 Then
				zz = 0 'НЛіцЧЦ·ыЧґМ¬
			End If
			vl[vli] = nList_Utf8[i]
			vli += 1
		Else
			Select Case nList_Utf8[i]
			Case 39 ' µҐТэєЕ
				zz = 1 'ЅшИлЧЦ·ыЧґМ¬
				If zv = 0 Then ErrStr = "КэѕЭіцґн":This.Event_Send(12,ErrStr)  : Return 0   ' КэѕЭіцґн"
				vl[vli] = nList_Utf8[i]
				vli += 1
			Case 44 ',
				zv = 0 'ЅшИлПВТ»ЧЦ¶О
				zd[zdi] = 44
				zdi += 1
				vl[vli] = 44
				vli += 1
			Case 61 ' =
				zv = 1 'ЅшИлЦµДЈКЅ
			Case Else
				If zv = 0 Then
					zd[zdi] = nList_Utf8[i]
					zdi += 1
				Else
					vl[vli] = nList_Utf8[i]
					vli += 1
				End If
			End Select
		End If
	Next
	vl[vli] = 41 ' )
	vli += 1
	Dim Sql_Utf8 As String = "INSERT INTO " & Table_Utf8 & ..Left(zd, zdi) & ..Left(vl, vli)
	
	If This.Exec(Sql_Utf8 ) = -1 Then
		ErrStr = "КэѕЭіцґн" :This.Event_Send(12,ErrStr) ' КэѕЭіцґн"
		Return 0
	End If
	Function = sqlite3_last_insert_rowid(m_DB) ' »сИЎРВІеИлКэѕЭЧФФці¤µДIDЦµ  ValInt(rs_Utf8(0))
	If Transaction Then Transaction += 1
End Function
Function SQLite3Component.Exec(Sql_Utf8 As String) As Long
	Dim m_DB As sqlite3 Ptr = FSQLite3
	If m_DB = NULL Then ErrStr = "Base not opened": This.Event_Send(12, ErrStr)  : Return -1
	If Len(Sql_Utf8) = 0 Then ErrStr = "ОЮSql":This.Event_Send(12,ErrStr)  : Return -1   ' "
	If This.Event_Send(11,Sql_Utf8) <> 0 Then Return -1
	Dim r As Long = sqlite3_exec(m_DB, StrPtr(Sql_Utf8), 0, 0, 0)
	'¶ФУЪёьРВЎўЙѕіэЎўІеИлµИІ»РиТЄ»ШµчєЇКэµДІЩЧчЈ¬sqlite3_execµДµЪИэЎўµЪЛДёцІОКэїЙТФґ«Ил0»тХЯNullЎЈ
	'НЁіЈЗйїцПВsqlite3_exec·µ»ШSQLITE_OK=0µДЅб№ыЈ¬·З0Ѕб№ыїЙТФНЁ№эerrmsgАґ»сИЎ¶ФУ¦µДґнОуГиКцЎЈ
	If r <> 0 Then
		ErrStr = *sqlite3_errmsg(m_DB)
		ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12, ErrStr)
		Return -1
	End If
	If FSynchronization <> 0 And FSQLite3Mem <> 0 Then 'µ±К№УГДЪґжКэѕЭївК±Ј¬РЮёДОДјюЅшРРН¬ІЅРЮёДЎЈ
		sqlite3_exec(FSQLite3Mem, StrPtr(Sql_Utf8), 0, 0, 0)
	End If
	ErrStr = ""
	If Transaction = 0 Then
		'Dim rr As Long =
		''Print "У°ПмРРКэ=" & rr
		'Function = rr
	Else
		Transaction += 1
		
	End If
	Function = sqlite3_changes(m_DB)
End Function
Function SQLite3Component.AddItem(Table As UString,nList As UString) As Long   'РВФцТ»МхјЗВј(Улinsert()ПаН¬)Ј¬іЙ№¦·µ»ШІеИлµД ID
	Function = This.Insert(Table,nList)
End Function
Function SQLite3Component.AddItemUtf(Table_Utf8 As String,nList_Utf8 As String) As Long   'РВФцТ»МхјЗВј(Улinsert()ПаН¬)Ј¬іЙ№¦·µ»ШІеИлµД ID
	Function = This.InsertUtf(Table_Utf8,nList_Utf8)
End Function
Function SQLite3Component.Update(Table As UString,Cond As UString,upList As UString) As Long    'ёьРВјЗВјЈ¬іЙ№¦·µ»ШКЬУ°ПмµДРРКэЈ¬К§°Ь·µ»Ш -1ЎЈ
	Dim Table_Utf8  As String = ToUtf8(Table)
	Dim Cond_Utf8   As String = ToUtf8(Cond)
	Dim upList_Utf8 As String = ToUtf8(upList)
	Function = This.UpdateUtf(Table_Utf8,Cond_Utf8,upList_Utf8)
End Function
Function SQLite3Component.UpdateUtf(Table_Utf8 As String,Cond_Utf8 As String,upList_Utf8 As String) As Long 'ёьРВјЗВјЈ¬іЙ№¦·µ»ШКЬУ°ПмµДРРКэЈ¬К§°Ь·µ»Ш -1ЎЈ
	If FSQLite3 = 0   Then ErrStr = "Base not opened":This.Event_Send(12,ErrStr)  : Return -1
	If Len(Table_Utf8) = 0  Then ErrStr = "ОЮ±нГы" :This.Event_Send(12,ErrStr)       : Return -1 ' ОЮ±нГы"
	If Len(Cond_Utf8) = 0   Then ErrStr = "ОЮМхјю" : This.Event_Send(12, ErrStr)       : Return -1 ' "
	If Len(upList_Utf8) = 0 Then ErrStr = "ОЮДЪИЭ" :This.Event_Send(12,ErrStr)       : Return -1 ' "
	Dim Sql_Utf8 As String = "UPDATE " & Table_Utf8 & " SET " & upList_Utf8 & " WHERE " & Cond_Utf8
	Function = This.Exec(Sql_Utf8)
End Function
Function SQLite3Component.UpdateByte(Table As UString, Cond As UString, ColName As UString, nByte As Any Ptr, nLen As Long) As Long    'РґИл2ЅшЦЖКэѕЭЈ¬іЙ№¦·µ»ШКЬУ°ПмµДРРКэЈ¬К§°Ь·µ»Ш -1ЎЈ
	Function = This.UpdateByteUtf(ToUtf8(Table),ToUtf8(Cond),ToUtf8(ColName),nByte,nLen)
End Function
Function SQLite3Component.UpdateByteUtf(Table_Utf8 As String,Cond_Utf8 As String,ColName_Utf8 As String,nByte As Any Ptr,nLen As Long) As Long 'РґИл2ЅшЦЖКэѕЭЈ¬іЙ№¦·µ»ШКЬУ°ПмµДРРКэЈ¬К§°Ь·µ»Ш -1ЎЈ
	Dim m_DB As sqlite3 Ptr = FSQLite3
	If m_DB = NULL           Then ErrStr = "Base not opened":This.Event_Send(12,ErrStr)  : Return -1
	If Len(Table_Utf8) = 0   Then ErrStr = "ОЮ±нГы"  : This.Event_Send(12, ErrStr)      : Return -1 ' ОЮ±нГы"
	If Len(Cond_Utf8) = 0    Then ErrStr = "ОЮМхјю"  :This.Event_Send(12,ErrStr)      : Return -1 ' "
	If Len(ColName_Utf8) = 0 Then ErrStr = "ОЮЧЦ¶ОГы" :This.Event_Send(12,ErrStr)     : Return -1 ' ОЮЧЦ¶ОГы"
	Dim Sql_Utf8 As String = "UPDATE " & Table_Utf8 & " SET " & ColName_Utf8 & "=? WHERE " & Cond_Utf8
	Dim ppStmt As sqlite3_stmt Ptr,pzTail As ZString Ptr
	Dim rr     As Long = sqlite3_prepare(m_DB,StrPtr(Sql_Utf8), -1,@ppStmt,@pzTail) ' Чј±ёЦґРРSQL
	Dim As Long u,i
	If ppStmt = 0 Then
		ErrStr = *sqlite3_errmsg(m_DB)
		ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12,ErrStr)
		Return -1
	End If
	If sqlite3_bind_blob(ppStmt,1,nByte,nLen,NULL) = 0 Then
		sqlite3_step(ppStmt) 'ЦґРР
		ErrStr = ""
		If FSQLite3Mem <> 0 And FSynchronization <> 0 Then
			sqlite3_finalize(ppStmt) 'КН·Е
			sqlite3_prepare(FSQLite3Mem,StrPtr(Sql_Utf8), -1,@ppStmt,@pzTail)
			If ppStmt Then
				If sqlite3_bind_blob(ppStmt, 1, nByte, nLen, NULL) = 0 Then sqlite3_step(ppStmt) 'ЦґРР
			End If
		End If
		If Transaction = 0 Then
			Function = sqlite3_changes(m_DB)
		Else
			Transaction += 1
			Function    = 0
		End If
	Else
		ErrStr = *sqlite3_errmsg(m_DB)
		ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12,ErrStr)
		Function = -1
	End If
	sqlite3_finalize(ppStmt) 'КН·Е
End Function
Function SQLite3Component.UpdateText(Table As UString,Cond As UString,ColName As UString,Text_Utf8 As String) As Long
	Function = This.UpdateTextUtf(ToUtf8(Table),ToUtf8(Cond),ToUtf8(ColName),Text_Utf8)
End Function
Function SQLite3Component.UpdateTextUtf(Table_Utf8 As String,Cond_Utf8 As String,ColName_Utf8 As String,Text_Utf8 As String) As Long
	Dim m_DB As sqlite3 Ptr = FSQLite3
	If m_DB = NULL           Then ErrStr = "Base not opened" :This.Event_Send(12,ErrStr) : Return -1
	If Len(Table_Utf8) = 0   Then ErrStr = "ОЮ±нГы" : This.Event_Send(12, ErrStr)       : Return -1 ' ОЮ±нГы"
	If Len(Cond_Utf8) = 0    Then ErrStr = "ОЮМхјю"  :This.Event_Send(12,ErrStr)      : Return -1 ' "
	If Len(ColName_Utf8) = 0 Then ErrStr = "ОЮЧЦ¶ОГы" :This.Event_Send(12,ErrStr)     : Return -1 ' ОЮЧЦ¶ОГы"
	Dim Sql_Utf8 As String = "UPDATE " & Table_Utf8 & " SET " & ColName_Utf8 & "=? WHERE " & Cond_Utf8
	Dim ppStmt As sqlite3_stmt Ptr,pzTail As ZString Ptr
	Dim rr     As Long = sqlite3_prepare(m_DB,StrPtr(Sql_Utf8), -1,@ppStmt,@pzTail) ' Чј±ёЦґРРSQL
	Dim As Long u,i
	If ppStmt = 0 Then
		ErrStr = *sqlite3_errmsg(m_DB)
		ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12,ErrStr)
		Return -1
	End If
	If sqlite3_bind_text(ppStmt,1,StrPtr(Text_Utf8),Len(Text_Utf8),NULL) = 0 Then
		sqlite3_step(ppStmt) 'ЦґРР
		ErrStr = ""
		If FSQLite3Mem <> 0 And FSynchronization <> 0 Then
			sqlite3_finalize(ppStmt) 'КН·Е
			sqlite3_prepare(FSQLite3Mem,StrPtr(Sql_Utf8), -1,@ppStmt,@pzTail)
			If ppStmt Then
				If sqlite3_bind_text(ppStmt,1,StrPtr(Text_Utf8),Len(Text_Utf8),NULL) = 0 Then sqlite3_step(ppStmt) 'ЦґРР
			End If
		End If
		If Transaction = 0 Then
			Function = sqlite3_changes(m_DB)
		Else
			Transaction += 1
			Function    = 0
		End If
	Else
		ErrStr = *sqlite3_errmsg(m_DB)
		ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12,ErrStr)
		Function = -1
	End If
	sqlite3_finalize(ppStmt) 'КН·Е
End Function
Function SQLite3Component.DeleteItem(Table As UString, Cond As UString) As Long    'ЙѕіэјЗВјЈ¬іЙ№¦·µ»ШКЬУ°ПмµДРРКэЈ¬К§°Ь·µ»Ш -1ЎЈ
	Function = This.DeleteItemUtf(ToUtf8(Table),ToUtf8(Cond))
End Function
Function SQLite3Component.DeleteItemUtf(Table_Utf8 As String,Cond_Utf8 As String) As Long
	If FSQLite3 = 0  Then ErrStr = "Base not opened" :This.Event_Send(12,ErrStr) : Return -1
	If Len(Table_Utf8) = 0 Then ErrStr = "ОЮ±нГы" :This.Event_Send(12,ErrStr)       : Return -1 ' ОЮ±нГы"
	If Len(Cond_Utf8) = 0  Then ErrStr = "ОЮМхјю" : This.Event_Send(12, ErrStr)       : Return -1 ' "
	Dim Sql_Utf8 As String = "DELETE FROM  " & Table_Utf8 & " WHERE " & Cond_Utf8
	Function = This.Exec(Sql_Utf8)
	'("DELETE FROM test WHERE name='Jerry'")
	'("DELETE FROM test WHERE id IN('003','005'")
End Function
Function SQLite3Component.Count(Table As UString,Cond As UString = "") As Long '
	Function = This.CountUtf(ToUtf8(Table),ToUtf8(Cond))
End Function
Function SQLite3Component.CountUtf(Table_Utf8 As String,Cond_Utf8 As String = "") As Long
	If FSQLite3 = 0  Then ErrStr = "Base not opened":This.Event_Send(12,ErrStr)  : Return 0
	If Len(Table_Utf8) = 0 Then ErrStr = "ОЮ±нГы"    :This.Event_Send(12,ErrStr)    : Return 0 ' ОЮ±нГы"
	Dim Sql_Utf8 As String = "SELECT count(*) As mcount FROM " & Table_Utf8
	If Len(Cond_Utf8) > 0 Then Sql_Utf8 &= " WHERE " & Cond_Utf8
	Dim rs_Utf8() As String
	EventsEn = 1
	If This.SQLFindOne(Sql_Utf8,rs_Utf8()) = 0 Then
		Function = 0
	Else
		Function = ValInt(rs_Utf8(0))
	End If
	EventsEn = 0
End Function
Function SQLite3Component.Sum(Table As UString,Cond As UString,ColName As UString) As LongInt
	Function = This.SumUtf(ToUtf8(Table),ToUtf8(Cond),ToUtf8(ColName))
End Function
Function SQLite3Component.SumUtf(Table_Utf8 As String,Cond_Utf8 As String,ColName_Utf8 As String) As LongInt
	If FSQLite3 = 0  Then ErrStr = "Base not opened" :This.Event_Send(12,ErrStr) : Return 0
	If Len(Table_Utf8) = 0 Then ErrStr = "ОЮ±нГы"    :This.Event_Send(12,ErrStr)    : Return 0 ' ОЮ±нГы"
	Dim Sql_Utf8 As String = "SELECT sum(" & ColName_Utf8 & ") As mcount FROM " & Table_Utf8
	If Len(Cond_Utf8) > 0 Then Sql_Utf8 &= " WHERE " & Cond_Utf8
	Dim rs_Utf8() As String
	EventsEn = 1
	If This.SQLFindOne(Sql_Utf8,rs_Utf8()) = 0 Then
		Function = 0
	Else
		Function = ValLng (rs_Utf8(0))
	End If
	EventsEn = 0
End Function
Function SQLite3Component.INIGetKey(lSection As UString,lKeyName As UString,lDefault As UString = "") As UString '¶БИЎЕдЦГЈ¬УГКэѕЭїв±ЈґжИнјюЕдЦГЈ¬АаЛЖINIОДјю¶БИЎЕдЦГЦµЎЈ
	If FSQLite3 = 0 Then ErrStr = "Base not opened":This.Event_Send(12,ErrStr)  : Return ""
	Dim rs_Utf8() As String,ot As UString,Sql_Utf8 As String
	If Len(lSection) = 0 Then Return lDefault
	If Len(lKeyName) = 0 Then Return lDefault
	Dim tlKeyName As String = Replace(ToUtf8(lKeyName), "'", "''")
	Sql_Utf8 = ToUtf8("SELECT [Цµ] FROM [") & ToUtf8(lSection) & ToUtf8("] WHERE [ПоДї]='") & tlKeyName & "' LIMIT 1"
	EventsEn = 1
	If This.SQLFindOne(Sql_Utf8,rs_Utf8()) > 0 Then
		ot = FromUtf8(rs_Utf8(0))
	End If
	EventsEn = 0
	If Len(ot) Then
		Return ot
	Else
		Return lDefault
	End If
	
End Function
Function SQLite3Component.INISetKey(lSection As UString,lKeyName As UString,nValue As UString) As Boolean 'РґЕдЦГЈ¬УГКэѕЭїв±ЈґжИнјюЕдЦГЈ¬АаЛЖINIОДјю±ЈґжЕдЦГЦµ іЙ№¦·µ»Ш·З0 Ј¬К§°Ь·µ»Ш FALSEЎЈ
	If FSQLite3 = 0 Then ErrStr = "Base not opened" :This.Event_Send(12,ErrStr) : Return False
	Dim rs_Utf8() As String,Sql_Utf8 As String
	If Len(lSection) = 0 Then Return False
	If Len(lKeyName) = 0 Then Return False
	Dim lSection_utf8 As String = ToUtf8(lSection)
	Dim tlKeyName As String     = Replace(ToUtf8(lKeyName), "'", "''")
	Dim tnValue   As String
	If Len(nValue) Then tnValue = Replace(ToUtf8(nValue), "'", "''")
	
	'ЕР¶ПµД±нГыКЗІ»КЗґжФЪ ---------
	'select * from sqlite_master where name='ІОКэ'
	Sql_Utf8 = "select * from sqlite_master where name='" & lSection_utf8 & "'"
	EventsEn = 1
	If This.SQLFindOne(Sql_Utf8,rs_Utf8()) <= 0 Then '±нІ»ґжФЪЈ¬ґґФмёц±н
		'CREATE TABLE [ІОКэ] (ID INTEGER PRIMARY KEY AUTOINCREMENT,[ПоДї] TEXT NOT NULL,[Цµ] TEXT NOT NULL)
		Sql_Utf8 = "CREATE TABLE [" & lSection_utf8 & ToUtf8("] (ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,[ПоДї] TEXT NOT NULL,[Цµ] TEXT NOT NULL) ")
		This.Exec(Sql_Utf8)
	End If
	'ЕР¶ПµДПоДїКЗІ»КЗґжФЪ ---------
	Sql_Utf8 = "SELECT [ID] FROM [" & lSection_utf8 & ToUTF8("] WHERE [ПоДї]='") & tlKeyName & "' LIMIT 1"
	If This.SQLFindOne(Sql_Utf8,rs_Utf8()) <= 0 Then 'І»ґжФЪЈ¬
		'INSERT INTO [ІОКэ]([ПоДї],[Цµ]) VALUES('µҐО»','ОЄ¶шИЛ')
		Sql_Utf8 = "INSERT INTO [" & lSection_utf8 & ToUTF8("]([ПоДї],[Цµ]) VALUES('") & tlKeyName & "','" & tnValue & "')"
	Else
		If tnValue = "" Then
			Sql_Utf8 = "DELETE FROM [" & lSection_utf8 & "] WHERE ID=" & rs_Utf8(0)
		Else
			'UPDATE [ІОКэ] SET [Цµ]='"µДОпЖ·' WHERE ID=1
			Sql_Utf8 = "UPDATE [" & lSection_utf8 & ToUTF8("] SET [Цµ]='") & tnValue & "' WHERE ID=" & rs_Utf8(0)
		End If
	End If
	EventsEn = 0
	Function = This.Exec(Sql_Utf8)
	
End Function
Function SQLite3Component.MaxID(Table As UString,nField As UString,Cond As UString = "") As Long 'ІйХТ±нЦРДіБРЧоґуЦµЈ¬іЙ№¦·µ»ШЧоґуЦµЈ¬К§°Ь·µ»Ш FALSEЎЈ
	Function = This.MaxIDUtf(ToUtf8(Table),ToUtf8(nField),ToUtf8(Cond))
End Function
Function SQLite3Component.MaxIDUtf(Table_Utf8 As String,nField_Utf8 As String,Cond_Utf8 As String = "") As Long
	If FSQLite3 = 0 Then ErrStr = "Base not opened" :This.Event_Send(12,ErrStr) : Return False
	Dim rs_Utf8() As String
	If Len(Table_Utf8) = 0  Then ErrStr = "ОЮ±нГы": This.Event_Send(12, ErrStr)  : Return 0 ' ОЮ±нГы"
	If Len(nField_Utf8) = 0 Then ErrStr = "ОЮЧЦ¶О" :This.Event_Send(12,ErrStr) : Return 0 ' "
	Dim Sql_Utf8 As String = "SELECT MAX(" & nField_Utf8 & ") As mid FROM " & Table_Utf8
	If Len(Cond_Utf8) > 0 Then Sql_Utf8 &= " WHERE " & Cond_Utf8
	EventsEn = 1
	If This.SQLFindOne(Sql_Utf8,rs_Utf8()) = 0 Then Return 0
	EventsEn = 0
	Function = ValInt(rs_Utf8(0))
End Function

Sub SQLite3Component.TransactionBegin() 'КВОсїЄКјЈЁУГУЪЕъБїЦґРРSQLЈ¬МбёЯSQLР§ВКЈ©
	If FSQLite3 = 0 Then ErrStr = "Base not opened" :This.Event_Send(12,ErrStr) : Return
	Transaction = 1
	This.Exec("BEGIN TRANSACTION")
End Sub
Function SQLite3Component.TransactionEnd() As Long 'КВОсЦґРРІўЗТЅбКш
	If FSQLite3 = 0 Then ErrStr = "Base not opened" :This.Event_Send(12,ErrStr) : Return 0
	'This.Exec("COMMIT TRANSACTION") ' ЦґРРКВОс
	This.Exec("END TRANSACTION")    ' ЅбКшКВОс
	Function    = Transaction -3
	Transaction = 0
End Function
Function SQLite3Component.CreateTable(Table As UString) As Long 'ґґЅЁ1ХЕ±нЈЁД¬ИПМнјУ ID ЦчјьЧЦ¶ОЈ©
	Function = This.CreateTableUtf(ToUtf8(Table))
End Function
Function SQLite3Component.CreateTableUtf(Table_Utf8 As String) As Long
	If FSQLite3 = 0  Then ErrStr = "Base not opened":This.Event_Send(12,ErrStr)  : Return -1
	If Len(Table_Utf8) = 0 Then ErrStr = "ОЮ±нГы"   :This.Event_Send(12,ErrStr)     : Return -1 ' ОЮ±нГы"
	Dim Sql_Utf8 As String = "CREATE TABLE " & Table_Utf8 & " (ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL )"
	Function = This.Exec(Sql_Utf8)
End Function
Function SQLite3Component.AddField(Table As UString,nField As UString,nType As UString,default As UString = "",nNull As Boolean = 0) As Long 'РВФцЧЦ¶О
	If FSQLite3 = 0 Then ErrStr = "Base not opened":This.Event_Send(12,ErrStr)  : Return -1
	If Len(Table) = 0     Then ErrStr = "ОЮ±нГы"  :This.Event_Send(12,ErrStr)      : Return -1 ' ОЮ±нГы"
	If Len(nField) = 0    Then ErrStr = "ОЮЧЦ¶ОГы" : This.Event_Send(12, ErrStr)     : Return -1 ' ОЮЧЦ¶ОГы"
	If Len(nType) = 0     Then ErrStr = "ОЮАаРНГы" :This.Event_Send(12,ErrStr)     : Return -1 ' "
	Dim Sql_Utf8 As String = "ALTER TABLE " & ToUtf8(Table) & " ADD " & ToUtf8(nField) & " " & ToUtf8(nType)
	Dim tdefault As String
	If Len(default) > 0 AndAlso Len(nType) > 0 Then tdefault = Replace(ToUtf8(default),"'","''")
	If Len(tdefault) > 0 Then Sql_Utf8                       &= " DEFAULT " & tdefault
	If nNull = 0         Then Sql_Utf8                       &= " NOT NULL "
	'Print Sql_Utf8
	Function = This.Exec(Sql_Utf8)
End Function
Function SQLite3Component.Vacuum() As Long   '¶ФКэѕЭївОДјюЦШРВХыАнЈ¬јхЙЩОДјюіЯґзЈ¬±ЬГвКэѕЭУ·ЦЧЈ¬У°ПмР§ВКЎЈК§°Ь·µ»Ш -1
	Function = This.Exec("VACUUM")
End Function
Function SQLite3Component.CreateIndex(Table As UString,IndexName As UString,FieldList As UString,Unique As Boolean = 0)As Long  'ґґЅЁЛчТэЈ¬ЛчТэМбёЯІйСЇЛЩ¶И·ЗіЈГчПФЈ¬Н¬К±ЅµµНБЛёьРВУлІеИлКэѕЭЛЩ¶ИЎЈ К§°Ь·µ»Ш -1
	Function = This.CreateIndexUtf(ToUtf8(Table),ToUtf8(IndexName),ToUtf8(FieldList),Unique)
End Function
Function SQLite3Component.CreateIndexUtf(Table_Utf8 As String,IndexName_Utf8 As String,FieldList_Utf8 As String,Unique As Boolean = 0) As Long 'ґґЅЁЛчТэЈ¬ЛчТэМбёЯІйСЇЛЩ¶И·ЗіЈГчПФЈ¬Н¬К±ЅµµНБЛёьРВУлІеИлКэѕЭЛЩ¶ИЎЈ К§°Ь·µ»Ш -1
	If FSQLite3 = 0      Then ErrStr = "Base not opened" :This.Event_Send(12,ErrStr) : Return -1
	If Len(Table_Utf8) = 0     Then ErrStr = "ОЮ±нГы"   :This.Event_Send(12,ErrStr)     : Return -1 ' ОЮ±нГы"
	If Len(FieldList_Utf8) = 0 Then ErrStr = "ОЮЧЦ¶ОГы" : This.Event_Send(12, ErrStr)     : Return -1 ' ОЮЧЦ¶ОГы"
	Dim Sql_Utf8 As String
	If Unique Then
		Sql_Utf8 = "CREATE UNIQUE INDEX "
	Else
		Sql_Utf8 = "CREATE INDEX "
	End If
	Sql_Utf8 &= IndexName_Utf8 & " ON " & Table_Utf8 & " (" & FieldList_Utf8 & ")"
	Function = This.Exec(Sql_Utf8)
End Function

Private Function SQLite3Component.Event_Send(code As Long, ByRef Event_Data As WString) As Long
	Select Case code
	Case 11
		If OnSQLString Then Return OnSQLString(This, Event_Data)
	Case 12
		If OnErrorOut Then OnErrorOut(This, Event_Data)
	End Select
	Return 0
End Function

Private Operator SQLite3Component.Cast As Any Ptr
	Return @This
End Operator

Private Constructor SQLite3Component
	WLet(FClassName, "SQLite3Component")
End Constructor

Private Destructor SQLite3Component
	
End Destructor


