'################################################################################
'#  MariaDBBox.bi                                                               #
'#  Author: Xusinboy Bekchanov                                                  #
'################################################################################

#include once "mff/Component.bi"
#ifndef __EXPORT_PROCS__
	#include once "inc/mariadb.bi"
#endif

Using My.Sys.ComponentModel

Type MariaDBBox Extends Component
Private:
	ErrStr          As UString
	Transaction     As Long
	EventsEn        As Long
Protected:
	#ifndef __EXPORT_PROCS__
		FMYSQL As MYSQL Ptr
	#endif
	FSynchronization As Integer
	Declare Function Event_Send(code As Long, ByRef Event_Data As WString) As Long
Public:
	Declare Function ReadProperty(PropertyName As String) As Any Ptr
	Declare Function WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
	#ifndef __EXPORT_PROCS__
		Declare Function Open(ByRef FileName As WString, ByRef UserName As WString, ByRef Password As WString = "", ByVal host As Const ZString Ptr = NULL, Port As ULong = MARIADB_PORT, ByVal unix_socket As Const ZString Ptr = NULL, ByVal clientflag As culong = 0) As Boolean
		Declare Function Find(Table As UString, Cond As UString, rs_Utf8() As String, Col As UString = "*", Orderby As UString = "", Page As Long = 1, Pagesize As Long = 0) As Long
		Declare Function FindUtf(Table_Utf8 As String, Cond_Utf8 As String, rs_Utf8() As String, Col_Utf8 As String = "*", Orderby_Utf8 As String = "", Page As Long = 1, Pagesize As Long = 0) As Long
		Declare Function FindByte(Table As UString, Cond As UString, rs_Utf8() As String, rs_Types() As Long, Col As UString = "*", Orderby As UString = "", Page As Long = 1, Pagesize As Long = 0)                        As Long
		Declare Function FindByteUtf(Table_Utf8 As String, Cond_Utf8 As String, rs_Utf8() As String, rs_Types() As Long, Col_Utf8 As String = "*", Orderby_Utf8 As String = "", Page As Long = 1, Pagesize As Long = 0) As Long
		Declare Function FindOne(Table As UString, Cond As UString, rs_Utf8() As String, Col As UString = "*", Orderby As UString = "") As Long
		Declare Function FindOneUtf(Table_Utf8 As String, Cond_Utf8 As String, rs_Utf8() As String, Col_Utf8 As String = "*", Orderby_Utf8 As String = "") As Long
		Declare Function FindOneByte(Table As UString, Cond As UString, rs_Utf8() As String, rs_Types() As Long, Col As UString = "*", Orderby As UString = "")                        As Long
		Declare Function FindOneByteUtf(Table_Utf8 As String, Cond_Utf8 As String, rs_Utf8() As String, rs_Types() As Long, Col_Utf8 As String = "*", Orderby_Utf8 As String = "") As Long
		Declare Function FindOnly(Table As UString, Cond As UString, Col As UString = "*", Orderby As UString = "") As String
		Declare Function FindOnlyUtf(Table_Utf8 As String, Cond_Utf8 As String, Col_Utf8 As String = "*", Orderby_Utf8 As String = "") As String
		Declare Function Insert(Table As UString, nList As UString)                                                                           As Long
		Declare Function InsertUtf(Table_Utf8 As String, nList_Utf8 As String)                                                            As Long
		Declare Function AddItem(Table As UString, nList As UString)                                                                          As Long
		Declare Function AddItemUtf(Table_Utf8 As String, nList_Utf8 As String)                                                           As Long
		Declare Function Update(Table As UString, Cond As UString, upList As UString)                                                           As Long
		Declare Function UpdateUtf(Table_Utf8 As String, Cond_Utf8 As String, upList_Utf8 As String)                                      As Long
		Declare Function UpdateText(Table As UString, Cond As UString, ColName As UString, Text_Utf8 As String)                                 As Long
		Declare Function UpdateTextUtf(Table_Utf8 As String, Cond_Utf8 As String, ColName_Utf8 As String, Text_Utf8 As String)            As Long
		Declare Function UpdateByte(Table As UString, Cond As UString, ColName As UString, nByte As Any Ptr, nLen As Long)                      As Long
		Declare Function UpdateByteUtf(Table_Utf8 As String, Cond_Utf8 As String, ColName_Utf8 As String, nByte As Any Ptr, nLen As Long) As Long
		Declare Function DeleteItem(Table As UString, Cond As UString)                                       As Long
		Declare Function DeleteItemUtf(Table_Utf8 As String, Cond_Utf8 As String)                        As Long
		Declare Function Count(Table As UString, Cond As UString = "")                                       As Long
		Declare Function CountUtf(Table_Utf8 As String, Cond_Utf8 As String = "")                        As Long
		Declare Function Sum(Table As UString, Cond As UString, ColName As UString)                            As LongInt
		Declare Function SumUtf(Table_Utf8 As String, Cond_Utf8 As String, ColName_Utf8 As String)       As LongInt
		Declare Function MaxID(Table As UString, nField As UString, Cond As UString = "")                      As Long
		Declare Function MaxIDUtf(Table_Utf8 As String, nField_Utf8 As String, Cond_Utf8 As String = "") As Long
		
		Declare Function INIGetKey(lSection As UString, lKeyName As UString, lDefault As UString = "") As UString
		Declare Function INISetKey(lSection As UString, lKeyName As UString, nValue As UString)        As Boolean
		
		Declare Function Exec(Sql_Utf8 As String) As Long
		
		Declare Function SQLFind(Sql_Utf8 As String, rs_Utf8() As String)    As Long
		Declare Function SQLFindOne(Sql_Utf8 As String, rs_Utf8() As String) As Long
		Declare Function CreateTable(Table As UString)                         As Long
		Declare Function CreateTableUtf(Table_Utf8 As String)                As Long
		Declare Function CreateIndex(Table As UString, IndexName As UString, FieldList As UString, Unique As Boolean = 0)                      As Long
		Declare Function CreateIndexUtf(Table_Utf8 As String, IndexName_Utf8 As String, FieldList_Utf8 As String, Unique As Boolean = 0) As Long
		Declare Function AddField(Table As UString, nField As UString, nType As UString, Default As UString = "", nNull As Boolean = 0)          As Long
		
		Declare Function Vacuum()                        As Long
		Declare Function GetMySQLPtr() As MYSQL Ptr
	#endif
	
	Declare Sub TransactionBegin()
	Declare Function TransactionEnd()        As Long
	Declare Function TransactionRollback()   As Long
	Declare Function Version()               As String
	Declare Function ErrMsg()                As String
	Declare Function SetKey(newkey As UString) As Boolean
	Declare Sub Close()
	Declare Operator Cast As Any Ptr
	Declare Constructor
	Declare Destructor
	OnSQLString As Function(ByRef Sender As MariaDBBox, Sql_Utf8 As String) As Long
	OnErrorOut As Sub(ByRef Sender As MariaDBBox, ErrorTxt As String)
End Type

#ifndef __USE_MAKE__
	#include once "MariaDBBox.bas"
#endif
