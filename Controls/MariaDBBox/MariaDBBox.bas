'################################################################################
'#  MariaDBBox.bas                                                              #
'#  Author: Xusinboy Bekchanov                                                  #
'################################################################################

#include once "MariaDBBox.bi"

Private Function MariaDBBox.ReadProperty(PropertyName As String) As Any Ptr
	Select Case LCase(PropertyName)
	Case Else: Return Base.ReadProperty(PropertyName)
	End Select
	Return 0
End Function

Private Function MariaDBBox.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
	Select Case LCase(PropertyName)
	Case Else: Return Base.WriteProperty(PropertyName, Value)
	End Select
	Return True
End Function

#ifndef __EXPORT_PROCS__
	Function MariaDBBox.Open(ByRef DataBaseName As WString, ByRef UserName As WString, ByRef Password As WString = "", ByVal host As Const ZString Ptr = NULL, Port As ULong = MARIADB_PORT, ByVal unix_socket As Const ZString Ptr = NULL, ByVal clientflag As culong = 0) As Boolean
		If FMYSQL Then mysql_close(FMYSQL)
		FMYSQL = 0
		If Len(DataBaseName) = 0 Then
			ErrStr = "Database name is empty": This.Event_Send(12, ErrStr)
			Return False
		End If
		Dim r As Long, sFileName_Utf8 As String = ToUtf8(DataBaseName)
		FMYSQL = mysql_init(NULL)
		Var link = mysql_real_connect(FMYSQL, host, UserName, Password, NULL, Port, unix_socket, clientflag)
		If link = 0 Then
			ErrStr = "Can't connect to the mysql server on port " & Str(Port): This.Event_Send(12, ErrStr)
			mysql_close(FMYSQL)
			FMYSQL = 0
			Return False
		End If
		r = mysql_select_db(FMYSQL, sFileName_Utf8)
		If r <> 0 Then
			ErrStr = *mysql_error(FMYSQL)
			ErrStr = ErrStr & "Can't select the " & DataBaseName & " database!": This.Event_Send(12, ErrStr)
			mysql_close(FMYSQL)
			FMYSQL = 0
			Return False
		End If
		ErrStr   = ""
		Function = True
	End Function
	
	Sub MariaDBBox.Close()
		ErrStr = ""
		If FMYSQL Then
			mysql_close(FMYSQL)
			FMYSQL = 0
		End If
	End Sub
	Function MariaDBBox.GetMySQLPtr() As MYSQL Ptr
		ErrStr = ""
		Function = FMYSQL
	End Function
	Function MariaDBBox.ErrMsg() As String
		Function = ErrStr
	End Function
	Function MariaDBBox.Version() As String
		Function = MARIADB_CLIENT_VERSION_STR
	End Function
	
	Function MariaDBBox.SetKey(newkey As UString) As Boolean
		Dim m_DB As MYSQL Ptr = FMYSQL
		If m_DB = NULL Then ErrStr = "Base not opened": This.Event_Send(12, ErrStr)  : Return False
		ErrStr = ""
		Dim snewkey As String = ToUtf8(newkey)
		If This.Exec("SET PASSWORD FOR 'root'@'localhost' = PASSWORD('" & newkey & "');") = 0 Then
			ErrStr = *mysql_error(m_DB)
			ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12, ErrStr)
			Return False
		End If
	End Function
	
	Function MariaDBBox.SQLFind(Sql_Utf8 As String, rs() As String) As Long
		Dim m_DB As MYSQL Ptr = FMYSQL
		If m_DB = NULL Then ErrStr = "Base not opened": This.Event_Send(12, ErrStr)  : Return 0
		If This.Event_Send(11, Sql_Utf8) <> 0 Then Return 0
		
		mysql_query(m_DB, StrPtr(Sql_Utf8))
		Dim res As MYSQL_RES Ptr = mysql_store_result(m_DB)
		If res = 0 Then
			ErrStr = *mysql_error(m_DB)
			ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12, ErrStr)
			Return 0
		End If
		
		Dim nRows As Long = mysql_num_rows(res)
		Dim nColumns As Long = mysql_num_fields(res)
		Dim row As MYSQL_ROW
		
		If nColumns = 0 Then ErrStr = "Columns not found": This.Event_Send(12, ErrStr): Return 0
		If nRows = 0 Then ErrStr = "Not found": This.Event_Send(12, ErrStr): Return 0
		
		ReDim rs(nRows - 1, nColumns - 1)
		
		For i As Integer = 0 To nRows - 1
			row = mysql_fetch_row(res)
			If row = NULL Then
				ErrStr = *mysql_error(m_DB)
				ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12, ErrStr)
				Exit For
			End If
			For j As Integer = 0 To nColumns - 1
				rs(i, j) = *row[j]
			Next j
		Next i
		mysql_free_result(res)
		Function = nRows
	End Function
	
	Function MariaDBBox.SQLFindOne(Sql_Utf8 As String, rs() As String) As Long
		Dim m_DB As MYSQL Ptr = FMYSQL
		If m_DB = NULL Then ErrStr = "Base not opened": This.Event_Send(12, ErrStr)  : Return 0
		If This.Event_Send(11, Sql_Utf8) <> 0 Then Return 0
		
		mysql_query(m_DB, StrPtr(Sql_Utf8))
		Dim res As MYSQL_RES Ptr = mysql_store_result(m_DB)
		
		If res = 0 Then
			ErrStr = *mysql_error(m_DB)
			ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12, ErrStr)
			Return 0
		End If
		
		Dim nRows As Long = mysql_num_rows(res)
		Dim nColumns As Long = mysql_num_fields(res)
		Dim row As MYSQL_ROW
		
		If nColumns = 0 Then ErrStr = "Columns not found": This.Event_Send(12, ErrStr): Return 0
		If nRows = 0 Then ErrStr = "Not found": This.Event_Send(12, ErrStr): Return 0
		
		ReDim rs(nColumns - 1)
		
		row = mysql_fetch_row(res)
		If row = NULL Then
			ErrStr = *mysql_error(m_DB)
			ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12, ErrStr)
			Return 0
		End If
		For j As Integer = 0 To nColumns - 1
			rs(j) = *row[j]
		Next j
		mysql_free_result(res)
		Function = nColumns
	End Function
	
	Function MariaDBBox.Find(Table As UString, Cond As UString, rs() As String, Col As UString = "*", Orderby As UString = "", Page As Long = 1, Pagesize As Long = 0) As Long
		Dim m_DB As MYSQL Ptr = FMYSQL
		If m_DB = NULL    Then ErrStr = "Base not opened": This.Event_Send(12, ErrStr): Return 0
		If Len(Table) = 0 Then ErrStr = "Table name is empty": This.Event_Send(12, ErrStr): Return 0
		Dim Col_Utf8 As String = ToUtf8(Col)
		Dim Sql_Utf8 As String = "SELECT " & Col_Utf8 & " FROM " & ToUtf8(Table)
		
		If Len(Cond)    Then Sql_Utf8 &= " WHERE "    & ToUtf8(Cond)
		If Len(Orderby) Then Sql_Utf8 &= " ORDER BY " & ToUtf8(Orderby)
		If Pagesize > 0 Then
			Dim n As Long = (Page -1) * Pagesize
			Sql_Utf8 &= " LIMIT " & n & "," & Pagesize
		End If
		Function = SQLFind(Sql_Utf8, rs())
	End Function
	Function MariaDBBox.FindUtf(Table_Utf8 As String, Cond_Utf8 As String, rs_Utf8() As String, Col_Utf8 As String = "*", Orderby_Utf8 As String = "", Page As Long = 1, Pagesize As Long = 0) As Long
		Dim m_DB As MYSQL Ptr = FMYSQL
		If m_DB = NULL         Then ErrStr = "Base not opened": This.Event_Send(12, ErrStr): Return 0
		If Len(Table_Utf8) = 0 Then ErrStr = "Table name is empty" : This.Event_Send(12, ErrStr): Return 0
		Dim Sql_Utf8 As String = "SELECT " & Col_Utf8 & " FROM " & Table_Utf8
		
		If Len(Cond_Utf8)    Then Sql_Utf8 &= " WHERE "    & Cond_Utf8
		If Len(Orderby_Utf8) Then Sql_Utf8 &= " ORDER BY " & Orderby_Utf8
		If Pagesize > 0 Then
			Dim n As Long = (Page -1) * Pagesize
			Sql_Utf8 &= " LIMIT " & n & "," & Pagesize
		End If
		Function = SQLFind(Sql_Utf8,rs_Utf8())
	End Function
	Function MariaDBBox.FindByte(Table As UString, Cond As UString, rs() As String, Col As UString = "*", Orderby As UString = "", Page As Long = 1, Pagesize As Long = 0) As Long
		Function = This.FindByteUtf(ToUtf8(Table), ToUtf8(Cond), rs(), ToUtf8(Col), ToUtf8(Orderby), Page, Pagesize)
	End Function
	Function MariaDBBox.FindByteUtf(Table_Utf8 As String, Cond_Utf8 As String, rs_Utf8() As String, Col_Utf8 As String = "*", Orderby_Utf8 As String = "", Page As Long = 1, Pagesize As Long = 0) As Long
		Dim m_DB As MYSQL Ptr = FMYSQL
		If m_DB = NULL         Then ErrStr = "Base not opened": This.Event_Send(12, ErrStr): Return 0
		If Len(Table_Utf8) = 0 Then ErrStr = "Table name is empty": This.Event_Send(12, ErrStr): Return 0
		Dim Sql_Utf8 As String = "SELECT " & Col_Utf8 & " FROM " & Table_Utf8
		If Len(Cond_Utf8)    Then Sql_Utf8 &= " WHERE "    & Cond_Utf8
		If Len(Orderby_Utf8) Then Sql_Utf8 &= " ORDER BY " & Orderby_Utf8
		Dim n As Long = (Page -1) * Pagesize
		If Pagesize > 0 Then
			Sql_Utf8 &= " LIMIT " & n & "," & Pagesize
		End If
		mysql_real_query(m_DB, StrPtr(Sql_Utf8), n)
		Dim res As MYSQL_RES Ptr = mysql_store_result(m_DB)
		
		If res = 0 Then
			ErrStr = *mysql_error(m_DB)
			ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12, ErrStr)
			Return 0
		End If
		
		Var u = mysql_num_fields(res)
		Var yu = 0
		If u > 0 Then
			yu = mysql_num_rows(res)
			If yu = 0 Then ErrStr = "Not found": This.Event_Send(12, ErrStr): Return 0
			ReDim rs_Utf8(yu, u - 1)
			If UBound(rs_Utf8) = -1 Then
				ErrStr = "ReDim not works": This.Event_Send(12, ErrStr)
				Return 0
			End If
			Dim fd As MYSQL_FIELD Ptr
			Dim row As MYSQL_ROW
			For i As Integer = 1 To yu
				row = mysql_fetch_row( res )
				If row = NULL Then
					Exit For
				End If
				For j As Integer = 0 To u - 1
					fd = mysql_fetch_field(res)
					If fd = NULL Then
						Exit For, For
					End If
					rs_Utf8(0, i) = *fd->name
					Select Case fd->type
					Case MYSQL_TYPE_DECIMAL, MYSQL_TYPE_TINY, MYSQL_TYPE_SHORT, MYSQL_TYPE_LONG, MYSQL_TYPE_FLOAT, MYSQL_TYPE_DOUBLE, MYSQL_TYPE_TIMESTAMP, MYSQL_TYPE_LONGLONG, MYSQL_TYPE_INT24, MYSQL_TYPE_DATE, MYSQL_TYPE_TIME, MYSQL_TYPE_DATETIME, MYSQL_TYPE_YEAR, MYSQL_TYPE_NEWDATE, MYSQL_TYPE_BIT, MYSQL_TYPE_TIMESTAMP2, MYSQL_TYPE_DATETIME2, MYSQL_TYPE_TIME2, MYSQL_TYPE_NEWDECIMAL, MYSQL_TYPE_ENUM, MYSQL_TYPE_SET, MYSQL_TYPE_GEOMETRY
						rs_Utf8(i - 1, j) = *row[j]
					Case MYSQL_TYPE_VARCHAR, MYSQL_TYPE_JSON, MYSQL_TYPE_VAR_STRING, MYSQL_TYPE_STRING
						rs_Utf8(i - 1, j) = *row[j]
					Case MYSQL_TYPE_TINY_BLOB, MYSQL_TYPE_MEDIUM_BLOB, MYSQL_TYPE_LONG_BLOB, MYSQL_TYPE_BLOB
						rs_Utf8(i - 1, j) = *row[j]
					Case MYSQL_TYPE_NULL
					End Select
				Next
			Next
			If Transaction Then Transaction += 1
		End If
		ErrStr = ""
		mysql_free_result(res)
		Function = yu
	End Function
	Function MariaDBBox.FindOneByte(Table As UString, Cond As UString, rs_Utf8() As String, Col As UString = "*", Orderby As UString = "") As Long
		Function = This.FindOneByteUtf(ToUtf8(Table),ToUtf8(Cond),rs_Utf8(),ToUtf8(Col),ToUtf8(Orderby))
	End Function
	Function MariaDBBox.FindOneByteUtf(Table_Utf8 As String, Cond_Utf8 As String, rs_Utf8() As String, Col_Utf8 As String = "*", Orderby_Utf8 As String = "") As Long
		Dim m_DB As MYSQL Ptr = FMYSQL
		If m_DB = NULL         Then ErrStr = "Base not opened": This.Event_Send(12, ErrStr): Return 0
		If Len(Table_Utf8) = 0 Then ErrStr = "Table name is empty": This.Event_Send(12, ErrStr): Return 0
		Dim Sql_Utf8 As String = "SELECT " & Col_Utf8 & " FROM " & Table_Utf8
		If Len(Cond_Utf8)    Then Sql_Utf8 &= " WHERE "    & Cond_Utf8
		If Len(Orderby_Utf8) Then Sql_Utf8 &= " ORDER BY " & Orderby_Utf8
		Sql_Utf8 &= " LIMIT 1"
		
		mysql_query(m_DB, StrPtr(Sql_Utf8))
		Dim res As MYSQL_RES Ptr = mysql_store_result(m_DB)
		
		If res = 0 Then
			ErrStr = *mysql_error(m_DB)
			ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12, ErrStr)
			Return 0
		End If
		
		Var u = mysql_num_fields(res)
		Var yu = 0
		If u > 0 Then
			yu = mysql_num_rows(res)
			If yu = 0 Then ErrStr = "Not found": This.Event_Send(12, ErrStr): Return 0
			ReDim rs_Utf8(u - 1)
			If UBound(rs_Utf8) = -1 Then
				ErrStr = "ReDim not works": This.Event_Send(12, ErrStr)
				Return 0
			End If
			Dim fd As MYSQL_FIELD Ptr
			Dim row As MYSQL_ROW
			row = mysql_fetch_row( res )
			If row = NULL Then
				Return 0
			End If
			For j As Integer = 0 To u - 1
				fd = mysql_fetch_field(res)
				If fd = NULL Then
					Exit For
				End If
				Select Case fd->type
				Case MYSQL_TYPE_DECIMAL, MYSQL_TYPE_TINY, MYSQL_TYPE_SHORT, MYSQL_TYPE_LONG, MYSQL_TYPE_FLOAT, MYSQL_TYPE_DOUBLE, MYSQL_TYPE_TIMESTAMP, MYSQL_TYPE_LONGLONG, MYSQL_TYPE_INT24, MYSQL_TYPE_DATE, MYSQL_TYPE_TIME, MYSQL_TYPE_DATETIME, MYSQL_TYPE_YEAR, MYSQL_TYPE_NEWDATE, MYSQL_TYPE_BIT, MYSQL_TYPE_TIMESTAMP2, MYSQL_TYPE_DATETIME2, MYSQL_TYPE_TIME2, MYSQL_TYPE_NEWDECIMAL, MYSQL_TYPE_ENUM, MYSQL_TYPE_SET, MYSQL_TYPE_GEOMETRY
					rs_Utf8(j) = *row[j]
				Case MYSQL_TYPE_VARCHAR, MYSQL_TYPE_JSON, MYSQL_TYPE_VAR_STRING, MYSQL_TYPE_STRING
					rs_Utf8(j) = *row[j]
				Case MYSQL_TYPE_TINY_BLOB, MYSQL_TYPE_MEDIUM_BLOB, MYSQL_TYPE_LONG_BLOB, MYSQL_TYPE_BLOB
					Var iLen = *mysql_fetch_lengths(res)
					rs_Utf8(j) = String(iLen, 0)
					memcpy StrPtr(rs_Utf8(j)), row[j], iLen
				Case MYSQL_TYPE_NULL
				End Select
			Next
			If Transaction Then Transaction += 1
		End If
		ErrStr = ""
		mysql_free_result(res)
		Function = u
	End Function
	
	Function MariaDBBox.FindOne(Table As UString,Cond As UString,rs() As String,Col As UString = "*",Orderby As UString = "") As Long
		If FMYSQL = 0 Then ErrStr = "Base not opened": This.Event_Send(12, ErrStr): Return 0
		
		If Len(Table) = 0 Then ErrStr = "Table name is empty": This.Event_Send(12, ErrStr): Return 0
		Dim Col_Utf8 As String = "*"
		If Col Then Col_Utf8 = ToUtf8(Col)
		Dim Sql_Utf8 As String = "SELECT " & Col_Utf8 & " FROM " & ToUtf8(Table)
		If Len(Cond) > 0 Then Sql_Utf8 &= " WHERE "    & ToUtf8(Cond)
		If Len(Orderby)  Then Sql_Utf8 &= " ORDER BY " & ToUtf8(Orderby)
		Sql_Utf8 &= " LIMIT 1"
		Function = SQLFindOne(Sql_Utf8, rs())
	End Function
	Function MariaDBBox.FindOneUtf(Table_Utf8 As String,Cond_Utf8 As String,rs_Utf8() As String,Col_Utf8 As String = "*",Orderby_Utf8 As String = "") As Long
		If  FMYSQL = 0  Then ErrStr = "Base not opened": This.Event_Send(12, ErrStr): Return 0
		
		If Len(Table_Utf8) = 0 Then ErrStr = "Table name is empty" : This.Event_Send(12, ErrStr): Return 0
		Dim Sql_Utf8 As String = "SELECT " & Col_Utf8 & " FROM " & Table_Utf8
		If Len(Cond_Utf8) > 0 Then Sql_Utf8 &= " WHERE "    & Cond_Utf8
		If Len(Orderby_Utf8)  Then Sql_Utf8 &= " ORDER BY " & Orderby_Utf8
		Sql_Utf8 &= " LIMIT 1"
		Function = SQLFindOne(Sql_Utf8,rs_Utf8())
	End Function
	Function MariaDBBox.FindOnly(Table As UString, Cond As UString, Col As UString = "*", Orderby As UString = "") As String
		Dim rs() As String
		If This.FindOne(Table, Cond, rs(), Col, Orderby) Then
			Return rs(0)
		End If
	End Function
	Function MariaDBBox.FindOnlyUtf(Table_Utf8 As String, Cond_Utf8 As String, Col_Utf8 As String = "*", Orderby_Utf8 As String = "") As String
		Dim rs() As String
		If This.FindOneUtf(Table_Utf8, Cond_Utf8, rs(), Col_Utf8, Orderby_Utf8) Then
			Return rs(0)
		End If
	End Function
	Function MariaDBBox.Insert(Table As UString, nList As UString) As Long
		Dim Table_Utf8 As String = ToUtf8(Table)
		Dim nList_Utf8 As String = ToUtf8(nList)
		Function = This.InsertUtf(Table_Utf8, nList_Utf8)
	End Function
	Function MariaDBBox.InsertUtf(Table_Utf8 As String, nList_Utf8 As String) As Long
		Dim m_DB As MYSQL Ptr = FMYSQL
		If m_DB = NULL Then ErrStr = "Base not opened": This.Event_Send(12, ErrStr): Return 0
		If Len(Table_Utf8) = 0 Then ErrStr = "Table name is empty": This.Event_Send(12, ErrStr): Return 0
		If Len(nList_Utf8) = 0 Then ErrStr = "List is empty": This.Event_Send(12, ErrStr): Return 0
		Dim zd As String = nList_Utf8, vl As String = ")VALUES(" & nList_Utf8
		Dim i As Long, zdi As Long = 1, vli As Long = 8, zv As Long
		zd[0] = 40 ' "("
		Dim zz As Long
		For i = 0 To Len(nList_Utf8) - 1
			If zz <> 0 Then
				If zv = 0 Then ErrStr = "Field name cannot contain an apostrophe": This.Event_Send(12, ErrStr): Return 0
				If nList_Utf8[i] = 39 Then
					zz = 0
				End If
				vl[vli] = nList_Utf8[i]
				vli += 1
			Else
				Select Case nList_Utf8[i]
				Case 39 ' "'"
					zz = 1
					If zv = 0 Then ErrStr = "Field name cannot contain an apostrophe": This.Event_Send(12, ErrStr): Return 0
					vl[vli] = nList_Utf8[i]
					vli += 1
				Case 44 ' ","
					zv = 0
					zd[zdi] = 44
					zdi += 1
					vl[vli] = 44
					vli += 1
				Case 61 ' "="
					zv = 1
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
		vl[vli] = 41 ' ")"
		vli += 1
		Dim Sql_Utf8 As String = "INSERT INTO " & Table_Utf8 & ..Left(zd, zdi) & ..Left(vl, vli)
		
		If This.Exec(Sql_Utf8) = -1 Then
			ErrStr = "Request failed": This.Event_Send(12, ErrStr)
			Return 0
		End If
		'Function = MYSQL_last_insert_rowid(m_DB)
		If Transaction Then Transaction += 1
	End Function
	Function MariaDBBox.Exec(Sql_Utf8 As String) As Long
		Dim m_DB As MYSQL Ptr = FMYSQL
		If m_DB = NULL Then ErrStr = "Base not opened": This.Event_Send(12, ErrStr)  : Return -1
		If Len(Sql_Utf8) = 0 Then ErrStr = "SQL command is empty": This.Event_Send(12, ErrStr)  : Return -1   ' "
		If This.Event_Send(11, Sql_Utf8) <> 0 Then Return -1
		Dim r As Long = mysql_query(m_DB, StrPtr(Sql_Utf8))
		If r <> 0 Then
			ErrStr = *mysql_error(m_DB)
			ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12, ErrStr)
			Return -1
		End If
		ErrStr = ""
		If Transaction = 0 Then
			
		Else
			Transaction += 1
		End If
		Function = mysql_affected_rows(m_DB)
	End Function
	Function MariaDBBox.AddItem(Table As UString, nList As UString) As Long
		Function = This.Insert(Table, nList)
	End Function
	Function MariaDBBox.AddItemUtf(Table_Utf8 As String, nList_Utf8 As String) As Long
		Function = This.InsertUtf(Table_Utf8, nList_Utf8)
	End Function
	Function MariaDBBox.Update(Table As UString, Cond As UString, upList As UString) As Long
		Dim Table_Utf8  As String = ToUtf8(Table)
		Dim Cond_Utf8   As String = ToUtf8(Cond)
		Dim upList_Utf8 As String = ToUtf8(upList)
		Function = This.UpdateUtf(Table_Utf8, Cond_Utf8, upList_Utf8)
	End Function
	Function MariaDBBox.UpdateUtf(Table_Utf8 As String, Cond_Utf8 As String, upList_Utf8 As String) As Long
		If FMYSQL = 0   Then ErrStr = "Base not opened": This.Event_Send(12, ErrStr): Return -1
		If Len(Table_Utf8) = 0  Then ErrStr = "Table name is empty" : This.Event_Send(12, ErrStr): Return -1
		If Len(Cond_Utf8) = 0   Then ErrStr = "Condition is empty" : This.Event_Send(12, ErrStr): Return -1
		If Len(upList_Utf8) = 0 Then ErrStr = "List is empty" : This.Event_Send(12, ErrStr): Return -1
		Dim Sql_Utf8 As String = "UPDATE " & Table_Utf8 & " SET " & upList_Utf8 & " WHERE " & Cond_Utf8
		Function = This.Exec(Sql_Utf8)
	End Function
	Function MariaDBBox.UpdateByte(Table As UString, Cond As UString, ColName As UString, nByte As Any Ptr, nLen As Long) As Long
		Function = This.UpdateByteUtf(ToUtf8(Table), ToUtf8(Cond), ToUtf8(ColName), nByte, nLen)
	End Function
	Function MariaDBBox.UpdateByteUtf(Table_Utf8 As String, Cond_Utf8 As String, ColName_Utf8 As String, nByte As Any Ptr, nLen As Long) As Long
		Dim m_DB As MYSQL Ptr = FMYSQL
		If m_DB = NULL           Then ErrStr = "Base not opened": This.Event_Send(12, ErrStr): Return -1
		If Len(Table_Utf8) = 0   Then ErrStr = "Table name is empty"  : This.Event_Send(12, ErrStr): Return -1
		If Len(Cond_Utf8) = 0    Then ErrStr = "Condition is empty"  : This.Event_Send(12, ErrStr): Return -1
		If Len(ColName_Utf8) = 0 Then ErrStr = "List is empty" : This.Event_Send(12, ErrStr): Return -1
		Dim Sql_Utf8 As String = "UPDATE " & Table_Utf8 & " SET " & ColName_Utf8 & "=? WHERE " & Cond_Utf8
		Dim ppStmt As MYSQL_STMT Ptr = mysql_stmt_init(FMYSQL)
		If ppStmt = 0 Then
			ErrStr = *mysql_error(m_DB)
			ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12,ErrStr)
			Return -1
		End If
		Dim rr     As Long = mysql_stmt_prepare(ppStmt, StrPtr(Sql_Utf8), -1)
		Dim As Long u, i
		Dim As MYSQL_BIND Ptr b = CAllocate(1, SizeOf(MYSQL_BIND))
		b[0].buffer_type = MYSQL_TYPE_BLOB
		If mysql_stmt_bind_param(ppStmt, b) Then
			ErrStr = *mysql_stmt_error(ppStmt)
			ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12, ErrStr)
			Function = -1
		End If
		If mysql_stmt_send_long_data(ppStmt, 0, nByte, nLen) Then
			ErrStr = *mysql_stmt_error(ppStmt)
			ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12, ErrStr)
			Function = -1
		End If
		If mysql_stmt_execute(ppStmt) Then
			ErrStr = *mysql_stmt_error(ppStmt)
			ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12, ErrStr)
			Function = -1
		End If
		ErrStr = ""
		Function  = 0
	End Function
	
	Function MariaDBBox.UpdateText(Table As UString, Cond As UString, ColName As UString, Text_Utf8 As String) As Long
		Function = This.UpdateTextUtf(ToUtf8(Table), ToUtf8(Cond), ToUtf8(ColName), Text_Utf8)
	End Function
	
	Function MariaDBBox.UpdateTextUtf(Table_Utf8 As String, Cond_Utf8 As String, ColName_Utf8 As String, Text_Utf8 As String) As Long
		Dim m_DB As MYSQL Ptr = FMYSQL
		If m_DB = NULL           Then ErrStr = "Base not opened" : This.Event_Send(12, ErrStr): Return -1
		If Len(Table_Utf8) = 0   Then ErrStr = "Table name is empty" : This.Event_Send(12, ErrStr): Return -1
		If Len(Cond_Utf8) = 0    Then ErrStr = "Condition is empty"  : This.Event_Send(12, ErrStr): Return -1
		If Len(ColName_Utf8) = 0 Then ErrStr = "Column name is empty" : This.Event_Send(12, ErrStr): Return -1
		Dim Sql_Utf8 As String = "UPDATE " & Table_Utf8 & " SET " & ColName_Utf8 & "=? WHERE " & Cond_Utf8
		Dim ppStmt As MYSQL_STMT Ptr = mysql_stmt_init(FMYSQL)
		If ppStmt = 0 Then
			ErrStr = *mysql_error(m_DB)
			ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12, ErrStr)
			Return -1
		End If
		Dim rr     As Long = mysql_stmt_prepare(ppStmt, StrPtr(Sql_Utf8), -1)
		Dim As Long u, length = Len(Text_Utf8)
		Dim As MYSQL_BIND Ptr b = CAllocate(1, SizeOf(MYSQL_BIND))
		b[0].buffer_type = MYSQL_TYPE_STRING
		b[0].length = @length
	 	b[0].is_null = 0
		If mysql_stmt_bind_param(ppStmt, b) Then
			ErrStr = *mysql_stmt_error(ppStmt)
			ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12, ErrStr)
			Function = -1
		End If
		If mysql_stmt_send_long_data(ppStmt, 0, StrPtr(Text_Utf8), length) Then
			ErrStr = *mysql_stmt_error(ppStmt)
			ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12, ErrStr)
			Function = -1
		End If
		If mysql_stmt_execute(ppStmt) Then
			ErrStr = *mysql_stmt_error(ppStmt)
			ErrStr = FromUtf8(Str(ErrStr)) : This.Event_Send(12, ErrStr)
			Function = -1
		End If
		ErrStr = ""
		Function  = 0
	End Function
	
	Function MariaDBBox.DeleteItem(Table As UString, Cond As UString) As Long
		Function = This.DeleteItemUtf(ToUtf8(Table), ToUtf8(Cond))
	End Function
	
	Function MariaDBBox.DeleteItemUtf(Table_Utf8 As String,Cond_Utf8 As String) As Long
		If FMYSQL = 0  Then ErrStr = "Base not opened": This.Event_Send(12, ErrStr): Return -1
		If Len(Table_Utf8) = 0 Then ErrStr = "Table name is empty": This.Event_Send(12, ErrStr): Return -1
		If Len(Cond_Utf8) = 0  Then ErrStr = "Condition is empty": This.Event_Send(12, ErrStr): Return -1
		Dim Sql_Utf8 As String = "DELETE FROM  " & Table_Utf8 & " WHERE " & Cond_Utf8
		Function = This.Exec(Sql_Utf8)
	End Function
	Function MariaDBBox.Count(Table As UString, Cond As UString = "") As Long
		Function = This.CountUtf(ToUtf8(Table), ToUtf8(Cond))
	End Function
	Function MariaDBBox.CountUtf(Table_Utf8 As String, Cond_Utf8 As String = "") As Long
		If FMYSQL = 0  Then ErrStr = "Base not opened": This.Event_Send(12, ErrStr): Return 0
		If Len(Table_Utf8) = 0 Then ErrStr = "Table name is empty": This.Event_Send(12, ErrStr): Return 0
		Dim Sql_Utf8 As String = "SELECT count(*) As mcount FROM " & Table_Utf8
		If Len(Cond_Utf8) > 0 Then Sql_Utf8 &= " WHERE " & Cond_Utf8
		Dim rs_Utf8() As String
		EventsEn = 1
		If This.SQLFindOne(Sql_Utf8, rs_Utf8()) = 0 Then
			Function = 0
		Else
			Function = ValInt(rs_Utf8(0))
		End If
		EventsEn = 0
	End Function
	Function MariaDBBox.Sum(Table As UString, Cond As UString, ColName As UString) As LongInt
		Function = This.SumUtf(ToUtf8(Table), ToUtf8(Cond), ToUtf8(ColName))
	End Function
	Function MariaDBBox.SumUtf(Table_Utf8 As String, Cond_Utf8 As String, ColName_Utf8 As String) As LongInt
		If FMYSQL = 0  Then ErrStr = "Base not opened": This.Event_Send(12, ErrStr): Return 0
		If Len(Table_Utf8) = 0 Then ErrStr = "Table name is empty": This.Event_Send(12, ErrStr): Return 0
		Dim Sql_Utf8 As String = "SELECT sum(" & ColName_Utf8 & ") As mcount FROM " & Table_Utf8
		If Len(Cond_Utf8) > 0 Then Sql_Utf8 &= " WHERE " & Cond_Utf8
		Dim rs_Utf8() As String
		EventsEn = 1
		If This.SQLFindOne(Sql_Utf8,rs_Utf8()) = 0 Then
			Function = 0
		Else
			Function = ValLng(rs_Utf8(0))
		End If
		EventsEn = 0
	End Function
	Function MariaDBBox.INIGetKey(lSection As UString, lKeyName As UString, lDefault As UString = "") As UString
		If FMYSQL = 0 Then ErrStr = "Base not opened":This.Event_Send(12,ErrStr)  : Return ""
		Dim rs_Utf8() As String, ot As UString, Sql_Utf8 As String
		If Len(lSection) = 0 Then Return lDefault
		If Len(lKeyName) = 0 Then Return lDefault
		Dim tlKeyName As String = Replace(ToUtf8(lKeyName), "'", "''")
		Sql_Utf8 = ToUtf8("SELECT [Value] FROM [") & ToUtf8(lSection) & ToUtf8("] WHERE [Key]='") & tlKeyName & "' LIMIT 1"
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
	Function MariaDBBox.INISetKey(lSection As UString, lKeyName As UString, nValue As UString) As Boolean
		If FMYSQL = 0 Then ErrStr = "Base not opened" : This.Event_Send(12, ErrStr): Return False
		Dim rs_Utf8() As String, Sql_Utf8 As String
		If Len(lSection) = 0 Then Return False
		If Len(lKeyName) = 0 Then Return False
		Dim lSection_utf8 As String = ToUtf8(lSection)
		Dim tlKeyName As String     = Replace(ToUtf8(lKeyName), "'", "''")
		Dim tnValue   As String
		If Len(nValue) Then tnValue = Replace(ToUtf8(nValue), "'", "''")
		
		Sql_Utf8 = "select * from sqlite_master where name='" & lSection_utf8 & "'"
		EventsEn = 1
		If This.SQLFindOne(Sql_Utf8, rs_Utf8()) <= 0 Then
			Sql_Utf8 = "CREATE TABLE [" & lSection_utf8 & ToUtf8("] (ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,[Key] TEXT NOT NULL,[Value] TEXT NOT NULL) ")
			This.Exec(Sql_Utf8)
		End If
		Sql_Utf8 = "SELECT [ID] FROM [" & lSection_utf8 & ToUtf8("] WHERE [Key]='") & tlKeyName & "' LIMIT 1"
		If This.SQLFindOne(Sql_Utf8, rs_Utf8()) <= 0 Then
			Sql_Utf8 = "INSERT INTO [" & lSection_utf8 & ToUtf8("]([Key],[Value]) VALUES('") & tlKeyName & "','" & tnValue & "')"
		Else
			If tnValue = "" Then
				Sql_Utf8 = "DELETE FROM [" & lSection_utf8 & "] WHERE ID=" & rs_Utf8(0)
			Else
				Sql_Utf8 = "UPDATE [" & lSection_utf8 & ToUtf8("] SET [Value]='") & tnValue & "' WHERE ID=" & rs_Utf8(0)
			End If
		End If
		EventsEn = 0
		Function = This.Exec(Sql_Utf8)
		
	End Function
	Function MariaDBBox.MaxID(Table As UString, nField As UString, Cond As UString = "") As Long
		Function = This.MaxIDUtf(ToUtf8(Table), ToUtf8(nField), ToUtf8(Cond))
	End Function
	Function MariaDBBox.MaxIDUtf(Table_Utf8 As String, nField_Utf8 As String, Cond_Utf8 As String = "") As Long
		If FMYSQL = 0 Then ErrStr = "Base not opened" : This.Event_Send(12, ErrStr): Return False
		Dim rs_Utf8() As String
		If Len(Table_Utf8) = 0  Then ErrStr = "Table name is empty": This.Event_Send(12, ErrStr): Return 0
		If Len(nField_Utf8) = 0 Then ErrStr = "ОЮЧЦ¶О" : This.Event_Send(12, ErrStr): Return 0
		Dim Sql_Utf8 As String = "SELECT MAX(" & nField_Utf8 & ") As mid FROM " & Table_Utf8
		If Len(Cond_Utf8) > 0 Then Sql_Utf8 &= " WHERE " & Cond_Utf8
		EventsEn = 1
		If This.SQLFindOne(Sql_Utf8, rs_Utf8()) = 0 Then Return 0
		EventsEn = 0
		Function = ValInt(rs_Utf8(0))
	End Function
	
	Sub MariaDBBox.TransactionBegin()
		If FMYSQL = 0 Then ErrStr = "Base not opened": This.Event_Send(12, ErrStr): Return
		Transaction = 1
		This.Exec("BEGIN")
	End Sub
	Function MariaDBBox.TransactionEnd() As Long
		If FMYSQL = 0 Then ErrStr = "Base not opened": This.Event_Send(12, ErrStr): Return 0
		This.Exec("COMMIT")
		Function = Transaction - 3
		Transaction = 0
	End Function
	Function MariaDBBox.TransactionRollback() As Long
		If FMYSQL = 0 Then ErrStr = "Base not opened": This.Event_Send(12, ErrStr): Return 0
		This.Exec("ROLLBACK")
		Function = Transaction - 3
		Transaction = 0
	End Function
	Function MariaDBBox.CreateTable(Table As UString) As Long
		Function = This.CreateTableUtf(ToUtf8(Table))
	End Function
	Function MariaDBBox.CreateTableUtf(Table_Utf8 As String) As Long
		If FMYSQL = 0 Then ErrStr = "Base not opened": This.Event_Send(12, ErrStr): Return -1
		If Len(Table_Utf8) = 0 Then ErrStr = "Table name is empty": This.Event_Send(12, ErrStr): Return -1
		Dim Sql_Utf8 As String = "CREATE TABLE " & Table_Utf8 & " (ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL )"
		Function = This.Exec(Sql_Utf8)
	End Function
	Function MariaDBBox.AddField(Table As UString, nField As UString, nType As UString, default As UString = "", nNull As Boolean = 0) As Long
		If FMYSQL = 0 Then ErrStr = "Base not opened": This.Event_Send(12, ErrStr): Return -1
		If Len(Table) = 0     Then ErrStr = "Table name is empty"  : This.Event_Send(12, ErrStr): Return -1
		If Len(nField) = 0    Then ErrStr = "Column name is empty" : This.Event_Send(12, ErrStr): Return -1
		If Len(nType) = 0     Then ErrStr = "Type is empty": This.Event_Send(12, ErrStr): Return -1 ' "
		Dim Sql_Utf8 As String = "ALTER TABLE " & ToUtf8(Table) & " ADD " & ToUtf8(nField) & " " & ToUtf8(nType)
		Dim tdefault As String
		If Len(default) > 0 AndAlso Len(nType) > 0 Then tdefault = Replace(ToUtf8(default), "'", "''")
		If Len(tdefault) > 0 Then Sql_Utf8                       &= " DEFAULT " & tdefault
		If nNull = 0         Then Sql_Utf8                       &= " NOT NULL "
		Function = This.Exec(Sql_Utf8)
	End Function
	Function MariaDBBox.Vacuum() As Long
		Function = This.Exec("VACUUM")
	End Function
	Function MariaDBBox.CreateIndex(Table As UString, IndexName As UString, FieldList As UString, Unique As Boolean = 0) As Long
		Function = This.CreateIndexUtf(ToUtf8(Table), ToUtf8(IndexName), ToUtf8(FieldList), Unique)
	End Function
	Function MariaDBBox.CreateIndexUtf(Table_Utf8 As String, IndexName_Utf8 As String, FieldList_Utf8 As String, Unique As Boolean = 0) As Long
		If FMYSQL = 0      Then ErrStr = "Base not opened" : This.Event_Send(12, ErrStr): Return -1
		If Len(Table_Utf8) = 0     Then ErrStr = "Table name is empty"   : This.Event_Send(12, ErrStr): Return -1
		If Len(FieldList_Utf8) = 0 Then ErrStr = "Column name is empty" : This.Event_Send(12, ErrStr): Return -1
		Dim Sql_Utf8 As String
		If Unique Then
			Sql_Utf8 = "CREATE UNIQUE INDEX "
		Else
			Sql_Utf8 = "CREATE INDEX "
		End If
		Sql_Utf8 &= IndexName_Utf8 & " ON " & Table_Utf8 & " (" & FieldList_Utf8 & ")"
		Function = This.Exec(Sql_Utf8)
	End Function
	
	Private Function MariaDBBox.Event_Send(code As Long, ByRef Event_Data As WString) As Long
		Select Case code
		Case 11
			If OnSQLString Then Return OnSQLString(This, Event_Data)
		Case 12
			If OnErrorOut Then OnErrorOut(This, Event_Data)
		End Select
		Return 0
	End Function
#endif

Private Operator MariaDBBox.Cast As Any Ptr
	Return @This
End Operator

Private Constructor MariaDBBox
	WLet(FClassName, "MariaDBBox")
End Constructor

Private Destructor MariaDBBox
	
End Destructor
