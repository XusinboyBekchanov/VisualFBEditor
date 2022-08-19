''
'' SQLite test, translated by Nex/marzec
''



#include once "sqlite3.bi" 

Const DEFAULT_DATABASE = "sqlite3_test.db"
Const DEFAULT_QUERY	   = "select * from features"

Declare Sub showusage( )

Declare Function callback cdecl _
	( _
		ByVal NotUsed As Any Ptr, _
		ByVal argc As Long, _
		ByVal argv As ZString Ptr Ptr, _
		ByVal colName As ZString Ptr Ptr _
	) As Long

	Dim As sqlite3 Ptr db
	Dim As ZString Ptr ErrMsg 
	Dim As String database_name, query

	If( __FB_ARGC__ > 3 ) Then
		showusage
		End 1
	End If
	
	If( __FB_ARGC__ = 2 ) Then
		database_name = Command( 1 )
	Else
		database_name = DEFAULT_DATABASE
	End If
	
	If( __FB_ARGC__ = 3 ) Then
		query = Command( 2 )
	Else
		query = DEFAULT_QUERY
	End If
	
	If sqlite3_open( database_name, @db ) Then 
  		Print "Can't open database: "; *sqlite3_errmsg( db )
  		sqlite3_close( db ) 
  		End 1
	End If 
	
	Print "Using database: "; database_name
	Print

	If sqlite3_exec( db, query, @callback, 0, @ErrMsg ) <> SQLITE_OK Then 
  		Print "SQL error: "; *ErrMsg
	End If 

	sqlite3_close(db) 

'':::::
Function callback cdecl _
	( _
		ByVal NotUsed As Any Ptr, _
		ByVal argc As Long, _
		ByVal argv As ZString Ptr Ptr, _
		ByVal colName As ZString Ptr Ptr _
	) As Long
  
	Dim As Integer i 
	Dim As String text

	For i = 0 To argc - 1
		text = "NULL"
		If( argv[i] <> 0 ) Then
			If *argv[i] <> 0 Then 
				text = *argv[i]
			End If
		End If
			
		Print *colName[i], " = '"; text; "'"
	Next 
	
	Print

	Function = 0
   
End Function 

'':::::
Sub showusage( )
	Print "Usage: "; Command( 0 ); " database ""query"""
End Sub
