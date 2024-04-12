#include once "inc/mariadb.bi"

Dim db As MYSQL Ptr
Dim dbname As String

db = mysql_init( NULL )

dbname = "test"
Var link = mysql_real_connect( db, NULL, "root", "111", NULL, MYSQL_PORT, NULL, 0 )
If link = 0 Then
	Print "Can't connect to the mysql server on port"; MYSQL_PORT
	mysql_close( db )
	End 1
End If
Dim res As MYSQL_RES Ptr
Dim fd As MYSQL_FIELD Ptr
Dim row As MYSQL_ROW

Dim fields(24) As String
Dim rowstr As String
Dim As Integer l, x, j, k
Var Result = mysql_select_db( db, dbname)
If Result <> 0 Then
	Print *mysql_error(db)
	Print "Can't select the "; dbname; " database !"
	mysql_close( db )
	End 1
End If

Print "Client info: "; *mysql_get_client_info()

Print "Host info: "; *mysql_get_host_info( db )

Print "Server info: "; *mysql_get_server_info( db )

res = mysql_list_tables( db, "%" )
l = 1
x = 0
Do:
	fd = mysql_fetch_field( res )
	If ( fd = NULL ) Then
		Exit Do
	End If
	
	fields(x) = *fd->name
	Do
		row = mysql_fetch_row( res )
		If ( row = NULL ) Then
			Exit Do, Do
		End If
		
		j = mysql_num_fields( res )
		Print "Table #"; l; " :-"
		l += 1
		For k = 0 To j-1
			Print "  Fld #"; k+1; "("+ fields(k) + "): ";
			If ( row[k] = NULL ) Then
				Print "NULL"
			Else
				rowstr = *row[k]
				Print rowstr
			End If
			Print "=============================="
		Next
	Loop
	
	mysql_free_result( res )
	x += 1
Loop

mysql_close( db )
 End 0
