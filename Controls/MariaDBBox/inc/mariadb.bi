'' FreeBASIC binding for mariadb-connector-c-3.3.1
''
'' based on the C header files:
''   Copyright (C) 2000 MySQL AB & MySQL Finland AB & TCX DataKonsult AB
''                 2012 by MontyProgram AB
''
''   This library is free software; you can redistribute it and/or
''   modify it under the terms of the GNU Library General Public
''   License as published by the Free Software Foundation; either
''   version 2 of the License, or (at your option) any later version.
''
''   This library is distributed in the hope that it will be useful,
''   but WITHOUT ANY WARRANTY; without even the implied warranty of
''   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
''   Library General Public License for more details.
''
''   You should have received a copy of the GNU Library General Public
''   License along with this library; if not, write to the Free
''   Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
''   MA 02111-1301, USA 
''
'' translated to FreeBASIC by:
''   Copyright © 2021 FreeBASIC development team

#pragma once

#inclib "mariadb"

#ifdef __FB_WIN32__
	#inclib "kernel32"
#endif

#include once "crt/long.bi"
#include once "crt/stdarg.bi"
#include once "crt/sys/types.bi"
#include once "crt/ctype.bi"

'' The following symbols have been renamed:
''     #define CHARSET_DIR => CHARSET_DIR_
''     variable mysql_port => mysql_port_

#ifdef __FB_UNIX__
	Extern "C"
#else
	Extern "Windows"
#endif

#define _mysql_h
#define LIBMARIADB
#define MYSQL_CLIENT
Type my_bool As ZString
Type my_ulonglong As ULongInt
#define my_socket_defined

#ifdef __FB_UNIX__
	Type my_socket As Long
#elseif defined(__FB_WIN32__) And (Not defined(__FB_64BIT__))
	Type my_socket As ULong
#else
	Type my_socket As ULongInt
#endif

#define _mysql_com_h
Const NAME_CHAR_LEN = 64
Const NAME_LEN = 256
Const HOSTNAME_LENGTH = 255
Const SYSTEM_MB_MAX_CHAR_LENGTH = 4
Const USERNAME_CHAR_LENGTH = 128
Const USERNAME_LENGTH = USERNAME_CHAR_LENGTH * SYSTEM_MB_MAX_CHAR_LENGTH
Const SERVER_VERSION_LENGTH = 60
Const SQLSTATE_LENGTH = 5
Const SCRAMBLE_LENGTH = 20
Const SCRAMBLE_LENGTH_323 = 8
#define LOCAL_HOST "localhost"
#define LOCAL_HOST_NAMEDPIPE "."

#ifdef __FB_WIN32__
	#define MARIADB_NAMEDPIPE "MySQL"
	#define MYSQL_SERVICENAME "MySql"
#endif

#define MYSQL_AUTODETECT_CHARSET_NAME "auto"
Const BINCMP_FLAG = 131072

Type mysql_enum_shutdown_level As Long
Enum
	SHUTDOWN_DEFAULT = 0
	KILL_QUERY = 254
	KILL_CONNECTION = 255
end enum

Type enum_server_command As Long
Enum
	COM_SLEEP = 0
	COM_QUIT
	COM_INIT_DB
	COM_QUERY
	COM_FIELD_LIST
	COM_CREATE_DB
	COM_DROP_DB
	COM_REFRESH
	COM_SHUTDOWN
	COM_STATISTICS
	COM_PROCESS_INFO
	COM_CONNECT
	COM_PROCESS_KILL
	COM_DEBUG
	COM_PING
	COM_TIME = 15
	COM_DELAYED_INSERT
	COM_CHANGE_USER
	COM_BINLOG_DUMP
	COM_TABLE_DUMP
	COM_CONNECT_OUT = 20
	COM_REGISTER_SLAVE
	COM_STMT_PREPARE = 22
	COM_STMT_EXECUTE = 23
	COM_STMT_SEND_LONG_DATA = 24
	COM_STMT_CLOSE = 25
	COM_STMT_RESET = 26
	COM_SET_OPTION = 27
	COM_STMT_FETCH = 28
	COM_DAEMON = 29
	COM_UNSUPPORTED = 30
	COM_RESET_CONNECTION = 31
	COM_STMT_BULK_EXECUTE = 250
	COM_RESERVED_1 = 254
	COM_END
End Enum

Const NOT_NULL_FLAG = 1
Const PRI_KEY_FLAG = 2
Const UNIQUE_KEY_FLAG = 4
Const MULTIPLE_KEY_FLAG = 8
Const BLOB_FLAG = 16
Const UNSIGNED_FLAG = 32
Const ZEROFILL_FLAG = 64
Const BINARY_FLAG = 128
Const ENUM_FLAG = 256
Const AUTO_INCREMENT_FLAG = 512
Const TIMESTAMP_FLAG = 1024
Const SET_FLAG = 2048
Const NO_DEFAULT_VALUE_FLAG = 4096
Const ON_UPDATE_NOW_FLAG = 8192
Const NUM_FLAG = 32768
Const PART_KEY_FLAG = 16384
Const GROUP_FLAG = 32768
Const UNIQUE_FLAG = 65536
Const REFRESH_GRANT = 1
Const REFRESH_LOG = 2
Const REFRESH_TABLES = 4
Const REFRESH_HOSTS = 8
Const REFRESH_STATUS = 16
Const REFRESH_THREADS = 32
Const REFRESH_SLAVE = 64
Const REFRESH_MASTER = 128
Const REFRESH_READ_LOCK = 16384
Const REFRESH_FAST = 32768
Const CLIENT_MYSQL = 1
Const CLIENT_FOUND_ROWS = 2
Const CLIENT_LONG_FLAG = 4
Const CLIENT_CONNECT_WITH_DB = 8
Const CLIENT_NO_SCHEMA = 16
Const CLIENT_COMPRESS = 32
Const CLIENT_ODBC = 64
Const CLIENT_LOCAL_FILES = 128
Const CLIENT_IGNORE_SPACE = 256
Const CLIENT_INTERACTIVE = 1024
Const CLIENT_SSL = 2048
const CLIENT_IGNORE_SIGPIPE = 4096
Const CLIENT_TRANSACTIONS = 8192
Const CLIENT_PROTOCOL_41 = 512
Const CLIENT_RESERVED = 16384
Const CLIENT_SECURE_CONNECTION = 32768
Const CLIENT_MULTI_STATEMENTS = Cast(culong, 1) Shl 16
Const CLIENT_MULTI_RESULTS = Cast(culong, 1) Shl 17
Const CLIENT_PS_MULTI_RESULTS = Cast(culong, 1) Shl 18
Const CLIENT_PLUGIN_AUTH = Cast(culong, 1) Shl 19
Const CLIENT_CONNECT_ATTRS = Cast(culong, 1) Shl 20
Const CLIENT_PLUGIN_AUTH_LENENC_CLIENT_DATA = Cast(culong, 1) Shl 21
Const CLIENT_CAN_HANDLE_EXPIRED_PASSWORDS = Cast(culong, 1) Shl 22
Const CLIENT_SESSION_TRACKING = Cast(culong, 1) Shl 23
Const CLIENT_ZSTD_COMPRESSION = Cast(culong, 1) Shl 26
Const CLIENT_PROGRESS = Cast(culong, 1) Shl 29
Const CLIENT_PROGRESS_OBSOLETE = CLIENT_PROGRESS
Const CLIENT_SSL_VERIFY_SERVER_CERT = Cast(culong, 1) Shl 30
Const CLIENT_REMEMBER_OPTIONS = Cast(culong, 1) Shl 31
Const MARIADB_CLIENT_FLAGS = &hFFFFFFFF00000000ull
Const MARIADB_CLIENT_PROGRESS = 1ull Shl 32
Const MARIADB_CLIENT_RESERVED_1 = 1ull Shl 33
Const MARIADB_CLIENT_STMT_BULK_OPERATIONS = 1ull Shl 34
Const MARIADB_CLIENT_EXTENDED_METADATA = 1ull Shl 35
Const MARIADB_CLIENT_CACHE_METADATA = 1ull Shl 36
#define IS_MARIADB_EXTENDED_SERVER(MYSQL) ((MYSQL->server_capabilities And CLIENT_MYSQL) = 0)
Const MARIADB_CLIENT_SUPPORTED_FLAGS = ((MARIADB_CLIENT_PROGRESS Or MARIADB_CLIENT_STMT_BULK_OPERATIONS) Or MARIADB_CLIENT_EXTENDED_METADATA) Or MARIADB_CLIENT_CACHE_METADATA
Const CLIENT_SUPPORTED_FLAGS = ((((((((((((((((((((((CLIENT_MYSQL Or CLIENT_FOUND_ROWS) Or CLIENT_LONG_FLAG) Or CLIENT_CONNECT_WITH_DB) Or CLIENT_NO_SCHEMA) Or CLIENT_COMPRESS) Or CLIENT_ODBC) Or CLIENT_LOCAL_FILES) Or CLIENT_IGNORE_SPACE) Or CLIENT_INTERACTIVE) Or CLIENT_SSL) Or CLIENT_IGNORE_SIGPIPE) Or CLIENT_TRANSACTIONS) Or CLIENT_PROTOCOL_41) Or CLIENT_RESERVED) Or CLIENT_SECURE_CONNECTION) Or CLIENT_MULTI_STATEMENTS) Or CLIENT_MULTI_RESULTS) Or CLIENT_PROGRESS) Or CLIENT_SSL_VERIFY_SERVER_CERT) Or CLIENT_REMEMBER_OPTIONS) Or CLIENT_PLUGIN_AUTH) Or CLIENT_SESSION_TRACKING) Or CLIENT_CONNECT_ATTRS
Const CLIENT_CAPABILITIES = (((((((((CLIENT_MYSQL Or CLIENT_LONG_FLAG) Or CLIENT_TRANSACTIONS) Or CLIENT_SECURE_CONNECTION) Or CLIENT_MULTI_RESULTS) Or CLIENT_PS_MULTI_RESULTS) Or CLIENT_PROTOCOL_41) Or CLIENT_PLUGIN_AUTH) Or CLIENT_PLUGIN_AUTH_LENENC_CLIENT_DATA) Or CLIENT_SESSION_TRACKING) Or CLIENT_CONNECT_ATTRS
Const CLIENT_DEFAULT_FLAGS = (CLIENT_SUPPORTED_FLAGS And (Not CLIENT_COMPRESS)) And (Not CLIENT_SSL)
Const SERVER_STATUS_IN_TRANS = 1
Const SERVER_STATUS_AUTOCOMMIT = 2
Const SERVER_MORE_RESULTS_EXIST = 8
Const SERVER_QUERY_NO_GOOD_INDEX_USED = 16
Const SERVER_QUERY_NO_INDEX_USED = 32
Const SERVER_STATUS_CURSOR_EXISTS = 64
Const SERVER_STATUS_LAST_ROW_SENT = 128
Const SERVER_STATUS_DB_DROPPED = 256
Const SERVER_STATUS_NO_BACKSLASH_ESCAPES = 512
Const SERVER_STATUS_METADATA_CHANGED = 1024
Const SERVER_QUERY_WAS_SLOW = 2048
Const SERVER_PS_OUT_PARAMS = 4096
Const SERVER_STATUS_IN_TRANS_READONLY = 8192
Const SERVER_SESSION_STATE_CHANGED = 16384
Const SERVER_STATUS_ANSI_QUOTES = 32768
Const MYSQL_ERRMSG_SIZE = 512
Const NET_READ_TIMEOUT = 30
Const NET_WRITE_TIMEOUT = 60
Const NET_WAIT_TIMEOUT = (8 * 60) * 60
Const LIST_PROCESS_HOST_LEN = 64
#define MYSQL50_TABLE_NAME_PREFIX "#mysql50#"
#define MYSQL50_TABLE_NAME_PREFIX_LENGTH (SizeOf(MYSQL50_TABLE_NAME_PREFIX) - 1)
#define SAFE_NAME_LEN (NAME_LEN + MYSQL50_TABLE_NAME_PREFIX_LENGTH)
Type MARIADB_PVIO As st_ma_pvio
Const MAX_CHAR_WIDTH = 255
Const MAX_BLOB_WIDTH = 8192
Const MAX_TINYINT_WIDTH = 3
Const MAX_SMALLINT_WIDTH = 5
Const MAX_MEDIUMINT_WIDTH = 8
Const MAX_INT_WIDTH = 10
Const MAX_BIGINT_WIDTH = 20
Type st_mariadb_net_extension As st_mariadb_net_extension_

Type st_net
	pvio As MARIADB_PVIO Ptr
	buff As UByte Ptr
	buff_end As UByte Ptr
	write_pos As UByte Ptr
	read_pos As UByte Ptr

	#ifdef __FB_UNIX__
		fd As my_socket
	#elseif defined(__FB_WIN32__) And (Not defined(__FB_64BIT__))
		fd As ULong
	#else
		fd As ULongInt
	#endif

	remain_in_buf As culong
	length As culong
	buf_length As culong
	where_b as culong
	max_packet As culong
	max_packet_size As culong
	pkt_nr As ULong
	compress_pkt_nr As ULong
	write_timeout As ULong
	read_timeout As ULong
	retry_count As ULong
	fcntl As Long
	return_status As ULong Ptr
	reading_or_writing As UByte
	save_char As Byte
	unused_1 As Byte
	unused_2 As Byte
	compress As Byte
	unused_3 As Byte
	unused_4 As Any Ptr
	last_errno As ULong
	error As UByte
	unused_5 As Byte
	unused_6 As Byte
	last_error As ZString * 512
	sqlstate As ZString * 5 + 1
	extension As st_mariadb_net_extension Ptr
End Type

Type NET As st_net
Const packet_error = CULng(-1)

Type enum_mysql_set_option As Long
Enum
	MYSQL_OPTION_MULTI_STATEMENTS_ON
	MYSQL_OPTION_MULTI_STATEMENTS_OFF
End Enum

Type enum_session_state_type As Long
Enum
	SESSION_TRACK_SYSTEM_VARIABLES = 0
	SESSION_TRACK_SCHEMA
	SESSION_TRACK_STATE_CHANGE
	SESSION_TRACK_GTIDS
	SESSION_TRACK_TRANSACTION_CHARACTERISTICS
	SESSION_TRACK_TRANSACTION_STATE
End Enum

Const SESSION_TRACK_BEGIN = 0
Const SESSION_TRACK_END = SESSION_TRACK_TRANSACTION_STATE
Const SESSION_TRACK_TYPES = SESSION_TRACK_END + 1
Const SESSION_TRACK_TRANSACTION_TYPE = SESSION_TRACK_TRANSACTION_STATE

Type enum_field_types As Long
Enum
	MYSQL_TYPE_DECIMAL
	MYSQL_TYPE_TINY
	MYSQL_TYPE_SHORT
	MYSQL_TYPE_LONG
	MYSQL_TYPE_FLOAT
	MYSQL_TYPE_DOUBLE
	MYSQL_TYPE_NULL
	MYSQL_TYPE_TIMESTAMP
	MYSQL_TYPE_LONGLONG
	MYSQL_TYPE_INT24
	MYSQL_TYPE_DATE
	MYSQL_TYPE_TIME
	MYSQL_TYPE_DATETIME
	MYSQL_TYPE_YEAR
	MYSQL_TYPE_NEWDATE
	MYSQL_TYPE_VARCHAR
	MYSQL_TYPE_BIT
	MYSQL_TYPE_TIMESTAMP2
	MYSQL_TYPE_DATETIME2
	MYSQL_TYPE_TIME2
	MYSQL_TYPE_JSON = 245
	MYSQL_TYPE_NEWDECIMAL = 246
	MYSQL_TYPE_ENUM = 247
	MYSQL_TYPE_SET = 248
	MYSQL_TYPE_TINY_BLOB = 249
	MYSQL_TYPE_MEDIUM_BLOB = 250
	MYSQL_TYPE_LONG_BLOB = 251
	MYSQL_TYPE_BLOB = 252
	MYSQL_TYPE_VAR_STRING = 253
	MYSQL_TYPE_STRING = 254
	MYSQL_TYPE_GEOMETRY = 255
	MAX_NO_FIELD_TYPES
End Enum

Const FIELD_TYPE_DECIMAL = MYSQL_TYPE_DECIMAL
Const FIELD_TYPE_NEWDECIMAL = MYSQL_TYPE_NEWDECIMAL
Const FIELD_TYPE_TINY = MYSQL_TYPE_TINY
Const FIELD_TYPE_CHAR = FIELD_TYPE_TINY
Const FIELD_TYPE_SHORT = MYSQL_TYPE_SHORT
Const FIELD_TYPE_LONG = MYSQL_TYPE_LONG
Const FIELD_TYPE_FLOAT = MYSQL_TYPE_FLOAT
Const FIELD_TYPE_DOUBLE = MYSQL_TYPE_DOUBLE
Const FIELD_TYPE_NULL = MYSQL_TYPE_NULL
Const FIELD_TYPE_TIMESTAMP = MYSQL_TYPE_TIMESTAMP
const FIELD_TYPE_LONGLONG = MYSQL_TYPE_LONGLONG
Const FIELD_TYPE_INT24 = MYSQL_TYPE_INT24
Const FIELD_TYPE_DATE = MYSQL_TYPE_DATE
Const FIELD_TYPE_TIME = MYSQL_TYPE_TIME
Const FIELD_TYPE_DATETIME = MYSQL_TYPE_DATETIME
Const FIELD_TYPE_YEAR = MYSQL_TYPE_YEAR
Const FIELD_TYPE_NEWDATE = MYSQL_TYPE_NEWDATE
Const FIELD_TYPE_ENUM = MYSQL_TYPE_ENUM
Const FIELD_TYPE_INTERVAL = FIELD_TYPE_ENUM
Const FIELD_TYPE_SET = MYSQL_TYPE_SET
Const FIELD_TYPE_TINY_BLOB = MYSQL_TYPE_TINY_BLOB
Const FIELD_TYPE_MEDIUM_BLOB = MYSQL_TYPE_MEDIUM_BLOB
Const FIELD_TYPE_LONG_BLOB = MYSQL_TYPE_LONG_BLOB
Const FIELD_TYPE_BLOB = MYSQL_TYPE_BLOB
Const FIELD_TYPE_VAR_STRING = MYSQL_TYPE_VAR_STRING
Const FIELD_TYPE_STRING = MYSQL_TYPE_STRING
Const FIELD_TYPE_GEOMETRY = MYSQL_TYPE_GEOMETRY
Const FIELD_TYPE_BIT = MYSQL_TYPE_BIT
Extern max_allowed_packet As culong
Extern net_buffer_length As culong
#define net_new_transaction(NET) Scope : (NET)->pkt_nr = 0 : End Scope

Declare Function ma_net_init cdecl(ByVal net As NET Ptr, ByVal pvio As MARIADB_PVIO Ptr) As Long
Declare Sub ma_net_end cdecl(ByVal net As NET Ptr)
Declare Sub ma_net_clear cdecl(ByVal net As NET Ptr)
Declare Function ma_net_flush cdecl(ByVal net As NET Ptr) As Long
Declare Function ma_net_write cdecl(ByVal net As NET Ptr, ByVal packet As Const UByte Ptr, ByVal len As UInteger) As Long
Declare Function ma_net_write_command cdecl(ByVal net As NET Ptr, ByVal command As UByte, ByVal packet As Const ZString Ptr, ByVal len As UInteger, ByVal disable_flush As Byte) As Long
Declare Function ma_net_real_write cdecl(ByVal net As NET Ptr, ByVal packet As Const ZString Ptr, ByVal len As UInteger) As Long
Declare Function ma_net_read cdecl(ByVal net As NET Ptr) As culong

Type rand_struct
	seed1 As culong
	seed2 As culong
	max_value As culong
	max_value_dbl As Double
End Type

Type Item_result As Long
Enum
	STRING_RESULT
	REAL_RESULT
	INT_RESULT
	ROW_RESULT
	DECIMAL_RESULT
End Enum

Type st_udf_args
	arg_count As ULong
	arg_type As Item_result Ptr
	args As ZString Ptr Ptr
	lengths As culong Ptr
	maybe_null As ZString Ptr
End Type

Type UDF_ARGS As st_udf_args

Type st_udf_init
	maybe_null As Byte
	decimals As ULong
	max_length As ULong
	ptr As ZString ptr
	const_item As Byte
End Type

Type UDF_INIT As st_udf_init
Const MARIADB_CONNECTION_UNIXSOCKET = 0
Const MARIADB_CONNECTION_TCP = 1
Const MARIADB_CONNECTION_NAMEDPIPE = 2
Const MARIADB_CONNECTION_SHAREDMEM = 3
Const NET_HEADER_SIZE = 4
Const COMP_HEADER_SIZE = 3
#define native_password_plugin_name "mysql_native_password"
#define old_password_plugin_name "mysql_old_password"

Declare Function ma_scramble_323 cdecl(ByVal to As ZString Ptr, ByVal message As Const ZString Ptr, ByVal password As Const ZString Ptr) As ZString Ptr
Declare Sub ma_scramble_41 cdecl(ByVal buffer As Const UByte Ptr, ByVal scramble As Const ZString Ptr, ByVal password As Const ZString Ptr)
Declare Sub ma_hash_password cdecl(ByVal result As culong Ptr, ByVal password As Const ZString Ptr, ByVal len As UInteger)
Declare Sub ma_make_scrambled_password cdecl(ByVal to As ZString Ptr, ByVal password As Const ZString Ptr)
Declare Sub mariadb_load_defaults cdecl(ByVal conf_file As Const ZString Ptr, ByVal groups As Const ZString Ptr Ptr, ByVal argc As Long Ptr, ByVal argv As ZString Ptr Ptr Ptr)
Declare Function ma_thread_init cdecl() As Byte
Declare Sub ma_thread_end cdecl()

Const NULL_LENGTH = Cast(culong, Not 0)
#define _mariadb_version_h_
Const PROTOCOL_VERSION = 10
#define MARIADB_CLIENT_VERSION_STR "10.6.8"
#define MARIADB_BASE_VERSION "mariadb-10.6"
Const MARIADB_VERSION_ID = 100608
Const MARIADB_PORT = 3306
#define MARIADB_UNIX_ADDR "/tmp/mysql.sock"
#define MYSQL_UNIX_ADDR MARIADB_UNIX_ADDR
Const MYSQL_PORT = MARIADB_PORT
#define MYSQL_CONFIG_NAME "my"
Const MYSQL_VERSION_ID = 100608
#define MYSQL_SERVER_VERSION "10.6.8-MariaDB"
#define MARIADB_PACKAGE_VERSION "3.3.1"
Const MARIADB_PACKAGE_VERSION_ID = 30301
#define MARIADB_SYSTEM_TYPE "Linux"
#define MARIADB_MACHINE_TYPE "x86_64"
#define MARIADB_PLUGINDIR "/usr/local/lib/mariadb/plugin"
#define MYSQL_CHARSET ""
#define CC_SOURCE_REVISION "5e94e7c27ffad7e76665b1333a67975316b9c3c2"
#define _list_h_

Type st_list
	prev As st_list Ptr
	next As st_list Ptr
	data As Any Ptr
End Type

Type _LIST As st_list
Type list_walk_action As Function cdecl(ByVal As Any Ptr, ByVal As Any Ptr) As Long
Declare Function list_add cdecl(ByVal root As _LIST Ptr, ByVal element As _LIST Ptr) As _LIST Ptr
Declare Function list_delete cdecl(ByVal root As _LIST Ptr, ByVal element As _LIST Ptr) As _LIST Ptr
Declare Function list_cons cdecl(ByVal data As Any Ptr, ByVal root As _LIST Ptr) As _LIST Ptr
Declare Function list_reverse cdecl(ByVal root As _LIST Ptr) As _LIST Ptr
Declare Sub list_free cdecl(ByVal root As _LIST Ptr, ByVal free_data As ULong)
Declare Function list_length cdecl(ByVal _LIST As _LIST Ptr) As ULong
Declare Function list_walk cdecl(ByVal _LIST As _LIST Ptr, ByVal action As list_walk_action, ByVal argument As ZString Ptr) As Long

#define list_rest(a) (a)->next
#define list_push(a, b) Scope : (a) = list_cons((b), (a)) : End Scope
#macro list_pop(A)
	Scope
		Dim old As _LIST Ptr = (A)
		(A) = list_delete(old, old)
		ma_free(CPtr(ZString Ptr, old), MYF(MY_FAE))
	End Scope
#endmacro
#define _mariadb_ctype_h
#define CHARSET_DIR_ "charsets/"
Const MY_CS_NAME_SIZE = 32
#define MADB_DEFAULT_CHARSET_NAME "latin1"
#define MADB_DEFAULT_COLLATION_NAME "latin1_swedish_ci"
#define MADB_AUTODETECT_CHARSET_NAME "auto"

Type ma_charset_info_st
	nr As ULong
	state As ULong
	csname As Const ZString Ptr
	name As Const ZString Ptr
	dir As Const ZString Ptr
	codepage As ULong
	encoding As Const ZString Ptr
	char_minlen As ULong
	char_maxlen As ULong
	mb_charlen As Function cdecl(ByVal c As ULong) As ULong
	mb_valid As Function cdecl(ByVal start As Const ZString Ptr, ByVal End As Const ZString Ptr) As ULong
End Type

Type MARIADB_CHARSET_INFO As ma_charset_info_st
Extern mariadb_compiled_charsets As Const MARIADB_CHARSET_INFO Ptr
Extern ma_default_charset_info As MARIADB_CHARSET_INFO Ptr
Extern ma_charset_bin As MARIADB_CHARSET_INFO Ptr
Extern ma_charset_latin1 As MARIADB_CHARSET_INFO Ptr
Extern ma_charset_utf8_general_ci As MARIADB_CHARSET_INFO Ptr
Extern ma_charset_utf16le_general_ci As MARIADB_CHARSET_INFO Ptr

Declare Function find_compiled_charset cdecl(ByVal cs_number As ULong) As MARIADB_CHARSET_INFO Ptr
Declare Function find_compiled_charset_by_name cdecl(ByVal name As Const ZString Ptr) As MARIADB_CHARSET_INFO Ptr
Declare Function mysql_cset_escape_quotes cdecl(ByVal cset As Const MARIADB_CHARSET_INFO Ptr, ByVal newstr As ZString Ptr, ByVal escapestr As Const ZString Ptr, ByVal escapestr_len As UInteger) As UInteger
Declare Function mysql_cset_escape_slashes cdecl(ByVal cset As Const MARIADB_CHARSET_INFO Ptr, ByVal newstr As ZString Ptr, ByVal escapestr As Const ZString Ptr, ByVal escapestr_len As UInteger) As UInteger
Declare Function madb_get_os_character_set cdecl() As Const ZString Ptr

#ifdef __FB_WIN32__
	Declare Function madb_get_windows_cp cdecl(ByVal charset As Const ZString Ptr) As Long
#endif

Type st_ma_const_string
	str As Const ZString Ptr
	length As UInteger
End Type

Type MARIADB_CONST_STRING As st_ma_const_string
#define ST_MA_USED_MEM_DEFINED

Type st_ma_used_mem
	next As st_ma_used_mem Ptr
	left As UInteger
	size As UInteger
End Type

Type MA_USED_MEM As st_ma_used_mem

Type st_ma_mem_root
	free As MA_USED_MEM Ptr
	used As MA_USED_MEM Ptr
	pre_alloc As MA_USED_MEM Ptr
	min_malloc As UInteger
	block_size As UInteger
	block_num As ULong
	first_block_usage As ULong
	error_handler As Sub cdecl()
End Type

Type MA_MEM_ROOT As st_ma_mem_root
Extern mysql_port_ Alias "mysql_port" As ULong
Extern mysql_unix_port As ZString Ptr
Extern mariadb_deinitialize_ssl As ULong

#define IS_PRI_KEY(n) ((n) And PRI_KEY_FLAG)
#define IS_NOT_NULL(n) ((n) And NOT_NULL_FLAG)
#define IS_BLOB(n) ((n) And BLOB_FLAG)
#define IS_NUM(t) (((((t) <= MYSQL_TYPE_INT24) AndAlso ((t) <> MYSQL_TYPE_TIMESTAMP)) OrElse ((t) = MYSQL_TYPE_YEAR)) OrElse ((t) = MYSQL_TYPE_NEWDECIMAL))
#define IS_NUM_FIELD(f) ((f)->flags And NUM_FLAG)
#define INTERNAL_NUM_FIELD(f) ((((((f)->type <= MYSQL_TYPE_INT24) AndAlso ((((f)->type <> MYSQL_TYPE_TIMESTAMP) OrElse ((f)->length = 14)) OrElse ((f)->length = 8))) OrElse ((f)->type = MYSQL_TYPE_YEAR)) OrElse ((f)->type = MYSQL_TYPE_NEWDECIMAL)) OrElse ((f)->type = MYSQL_TYPE_DECIMAL))

type st_mysql_field
	name As ZString Ptr
	org_name As ZString Ptr
	table As ZString Ptr
	org_table As ZString Ptr
	db As ZString Ptr
	catalog As ZString Ptr
	def As ZString Ptr
	length As culong
	max_length As culong
	name_length As ULong
	org_name_length As ULong
	table_length As ULong
	org_table_length As ULong
	db_length As ULong
	catalog_length As ULong
	def_length As ULong
	flags As ULong
	decimals As ULong
	charsetnr As ULong
	As enum_field_types type
	extension As Any Ptr
End Type

Type MYSQL_FIELD As st_mysql_field
Type MYSQL_ROW As ZString Ptr Ptr
Type MYSQL_FIELD_OFFSET As ULong
#macro SET_CLIENT_ERROR(a, b, c, d)
	Scope
		(a)->net.last_errno = (b)
		StrNCpy((a)->net.sqlstate, (c), SQLSTATE_LENGTH)
		(a)->net.sqlstate[SQLSTATE_LENGTH] = 0
		StrNCpy((a)->net.last_error, IIf((d), (d), ER((b))), MYSQL_ERRMSG_SIZE - 1)
		(a)->net.last_error[(MYSQL_ERRMSG_SIZE - 1)] = 0
	End Scope
#endmacro
#define set_mariadb_error(A, B, C) SET_CLIENT_ERROR((A), (B), (C), 0)
Extern SQLSTATE_UNKNOWN As Const ZString Ptr
Extern unknown_sqlstate Alias "SQLSTATE_UNKNOWN" As Const ZString Ptr
#macro CLEAR_CLIENT_ERROR(a)
	Scope
		(a)->net.last_errno = 0
		StrCpy((a)->net.sqlstate, "00000")
		(a)->net.last_error[0] = Asc(!"\0")
		If (a)->net.extension Then
			(a)->net.extension->extended_errno = 0
		End If
	End Scope
#endmacro
Const MYSQL_COUNT_ERROR = Not CULngInt(0)

Type st_mysql_rows
	next As st_mysql_rows Ptr
	data As MYSQL_ROW
	length As culong
End Type

Type MYSQL_ROWS As st_mysql_rows
Type MYSQL_ROW_OFFSET As MYSQL_ROWS Ptr

Type st_mysql_data
	data As MYSQL_ROWS Ptr
	embedded_info As Any Ptr
	alloc As MA_MEM_ROOT
	rows As ULongInt
	fields As ULong
	extension As Any Ptr
End Type

Type MYSQL_DATA As st_mysql_data

Type mysql_option As Long
Enum
	MYSQL_OPT_CONNECT_TIMEOUT
	MYSQL_OPT_COMPRESS
	MYSQL_OPT_NAMED_PIPE
	MYSQL_INIT_COMMAND
	MYSQL_READ_DEFAULT_FILE
	MYSQL_READ_DEFAULT_GROUP
	MYSQL_SET_CHARSET_DIR
	MYSQL_SET_CHARSET_NAME
	MYSQL_OPT_LOCAL_INFILE
	MYSQL_OPT_PROTOCOL
	MYSQL_SHARED_MEMORY_BASE_NAME
	MYSQL_OPT_READ_TIMEOUT
	MYSQL_OPT_WRITE_TIMEOUT
	MYSQL_OPT_USE_RESULT
	MYSQL_OPT_USE_REMOTE_CONNECTION
	MYSQL_OPT_USE_EMBEDDED_CONNECTION
	MYSQL_OPT_GUESS_CONNECTION
	MYSQL_SET_CLIENT_IP
	MYSQL_SECURE_AUTH
	MYSQL_REPORT_DATA_TRUNCATION
	MYSQL_OPT_RECONNECT
	MYSQL_OPT_SSL_VERIFY_SERVER_CERT
	MYSQL_PLUGIN_DIR
	MYSQL_DEFAULT_AUTH
	MYSQL_OPT_BIND
	MYSQL_OPT_SSL_KEY
	MYSQL_OPT_SSL_CERT
	MYSQL_OPT_SSL_CA
	MYSQL_OPT_SSL_CAPATH
	MYSQL_OPT_SSL_CIPHER
	MYSQL_OPT_SSL_CRL
	MYSQL_OPT_SSL_CRLPATH
	MYSQL_OPT_CONNECT_ATTR_RESET
	MYSQL_OPT_CONNECT_ATTR_ADD
	MYSQL_OPT_CONNECT_ATTR_DELETE
	MYSQL_SERVER_PUBLIC_KEY
	MYSQL_ENABLE_CLEARTEXT_PLUGIN
	MYSQL_OPT_CAN_HANDLE_EXPIRED_PASSWORDS
	MYSQL_OPT_SSL_ENFORCE
	MYSQL_OPT_MAX_ALLOWED_PACKET
	MYSQL_OPT_NET_BUFFER_LENGTH
	MYSQL_OPT_TLS_VERSION
	MYSQL_PROGRESS_CALLBACK = 5999
	MYSQL_OPT_NONBLOCK
	MYSQL_DATABASE_DRIVER = 7000
	MARIADB_OPT_SSL_FP
	MARIADB_OPT_SSL_FP_LIST
	MARIADB_OPT_TLS_PASSPHRASE
	MARIADB_OPT_TLS_CIPHER_STRENGTH
	MARIADB_OPT_TLS_VERSION
	MARIADB_OPT_TLS_PEER_FP
	MARIADB_OPT_TLS_PEER_FP_LIST
	MARIADB_OPT_CONNECTION_READ_ONLY
	MYSQL_OPT_CONNECT_ATTRS
	MARIADB_OPT_USERDATA
	MARIADB_OPT_CONNECTION_HANDLER
	MARIADB_OPT_PORT
	MARIADB_OPT_UNIXSOCKET
	MARIADB_OPT_PASSWORD
	MARIADB_OPT_HOST
	MARIADB_OPT_USER
	MARIADB_OPT_SCHEMA
	MARIADB_OPT_DEBUG
	MARIADB_OPT_FOUND_ROWS
	MARIADB_OPT_MULTI_RESULTS
	MARIADB_OPT_MULTI_STATEMENTS
	MARIADB_OPT_INTERACTIVE
	MARIADB_OPT_PROXY_HEADER
	MARIADB_OPT_IO_WAIT
	MARIADB_OPT_SKIP_READ_RESPONSE
	MARIADB_OPT_RESTRICTED_AUTH
End Enum

Type mariadb_value As Long
Enum
	MARIADB_CHARSET_ID
	MARIADB_CHARSET_NAME
	MARIADB_CLIENT_ERRORS
	MARIADB_CLIENT_VERSION
	MARIADB_CLIENT_VERSION_ID
	MARIADB_CONNECTION_ASYNC_TIMEOUT
	MARIADB_CONNECTION_ASYNC_TIMEOUT_MS
	MARIADB_CONNECTION_MARIADB_CHARSET_INFO
	MARIADB_CONNECTION_ERROR
	MARIADB_CONNECTION_ERROR_ID
	MARIADB_CONNECTION_HOST
	MARIADB_CONNECTION_INFO
	MARIADB_CONNECTION_PORT
	MARIADB_CONNECTION_PROTOCOL_VERSION_ID
	MARIADB_CONNECTION_PVIO_TYPE
	MARIADB_CONNECTION_SCHEMA
	MARIADB_CONNECTION_SERVER_TYPE
	MARIADB_CONNECTION_SERVER_VERSION
	MARIADB_CONNECTION_SERVER_VERSION_ID
	MARIADB_CONNECTION_SOCKET
	MARIADB_CONNECTION_SQLSTATE
	MARIADB_CONNECTION_SSL_CIPHER
	MARIADB_TLS_LIBRARY
	MARIADB_CONNECTION_TLS_VERSION
	MARIADB_CONNECTION_TLS_VERSION_ID
	MARIADB_CONNECTION_TYPE
	MARIADB_CONNECTION_UNIX_SOCKET
	MARIADB_CONNECTION_USER
	MARIADB_MAX_ALLOWED_PACKET
	MARIADB_NET_BUFFER_LENGTH
	MARIADB_CONNECTION_SERVER_STATUS
	MARIADB_CONNECTION_SERVER_CAPABILITIES
	MARIADB_CONNECTION_EXTENDED_SERVER_CAPABILITIES
	MARIADB_CONNECTION_CLIENT_CAPABILITIES
	MARIADB_CONNECTION_BYTES_READ
	MARIADB_CONNECTION_BYTES_SENT
End Enum

Type mysql_status As Long
Enum
	MYSQL_STATUS_READY
	MYSQL_STATUS_GET_RESULT
	MYSQL_STATUS_USE_RESULT
	MYSQL_STATUS_QUERY_SENT
	MYSQL_STATUS_SENDING_LOAD_DATA
	MYSQL_STATUS_FETCHING_DATA
	MYSQL_STATUS_NEXT_RESULT_PENDING
	MYSQL_STATUS_QUIT_SENT
	MYSQL_STATUS_STMT_RESULT
End Enum

Type mysql_protocol_type As Long
Enum
	MYSQL_PROTOCOL_DEFAULT
	MYSQL_PROTOCOL_TCP
	MYSQL_PROTOCOL_SOCKET
	MYSQL_PROTOCOL_PIPE
	MYSQL_PROTOCOL_MEMORY
End Enum

Type st_dynamic_array As st_dynamic_array_
Type st_mysql_options_extension As st_mysql_options_extension_

Type st_mysql_options
	connect_timeout As ULong
	read_timeout As ULong
	write_timeout As ULong
	port As ULong
	protocol As ULong
	client_flag As culong
	host As ZString Ptr
	user As ZString Ptr
	password As ZString Ptr
	unix_socket As ZString Ptr
	db As ZString Ptr
	init_command As st_dynamic_array Ptr
	my_cnf_file As ZString Ptr
	my_cnf_group As ZString Ptr
	charset_dir As ZString Ptr
	charset_name As ZString Ptr
	ssl_key As ZString Ptr
	ssl_cert As ZString Ptr
	ssl_ca As ZString Ptr
	ssl_capath As ZString Ptr
	ssl_cipher As ZString Ptr
	shared_memory_base_name As ZString Ptr
	max_allowed_packet As culong
	use_ssl As Byte
	compress As Byte
	named_pipe As Byte
	reconnect As Byte
	unused_1 As Byte
	unused_2 As Byte
	unused_3 As Byte
	methods_to_use As mysql_option
	bind_address As ZString Ptr
	secure_auth As Byte
	report_data_truncation As Byte
	local_infile_init As Function cdecl(ByVal As Any Ptr Ptr, ByVal As Const ZString Ptr, ByVal As Any Ptr) As Long
	local_infile_read As Function cdecl(ByVal As Any Ptr, ByVal As ZString Ptr, ByVal As ULong) As Long
	local_infile_end As Sub cdecl(ByVal As Any Ptr)
	local_infile_error As Function cdecl(ByVal As Any Ptr, ByVal As ZString Ptr, ByVal As ULong) As Long
	local_infile_userdata As Any Ptr
	extension As st_mysql_options_extension Ptr
End Type

Type st_mariadb_methods As st_mariadb_methods_
Type st_mariadb_extension As st_mariadb_extension_

Type st_mysql
	net As NET
	unused_0 As Any Ptr
	host As ZString Ptr
	user As ZString Ptr
	passwd As ZString Ptr
	unix_socket As ZString Ptr
	server_version As ZString Ptr
	host_info As ZString Ptr
	info As ZString Ptr
	db As ZString Ptr
	charset As Const ma_charset_info_st Ptr
	fields As MYSQL_FIELD Ptr
	field_alloc As MA_MEM_ROOT
	affected_rows As ULongInt
	insert_id As ULongInt
	extra_info As ULongInt
	thread_id As culong
	packet_length As culong
	port As ULong
	client_flag As culong
	server_capabilities As culong
	protocol_version As ULong
	field_count As ULong
	server_status As ULong
	server_language As ULong
	warning_count As ULong
	options As st_mysql_options
	status As mysql_status
	free_me As Byte
	unused_1 As Byte
	scramble_buff As ZString * 20 + 1
	unused_2 As Byte
	unused_3 As Any Ptr
	unused_4 As Any Ptr
	unused_5 As Any Ptr
	unused_6 As Any Ptr
	stmts As _LIST Ptr
	methods As Const st_mariadb_methods Ptr
	thd As Any Ptr
	unbuffered_fetch_owner As my_bool Ptr
	info_buffer As ZString Ptr
	extension As st_mariadb_extension Ptr
End Type

Type MYSQL As st_mysql

Type st_mysql_res
	row_count As ULongInt
	field_count As ULong
	current_field As ULong
	fields As MYSQL_FIELD Ptr
	data As MYSQL_DATA Ptr
	data_cursor As MYSQL_ROWS Ptr
	field_alloc As MA_MEM_ROOT
	row As MYSQL_ROW
	current_row As MYSQL_ROW
	lengths As culong Ptr
	handle As MYSQL Ptr
	eof As Byte
	is_ps As Byte
End Type

Type MYSQL_RES As st_mysql_res

Type MYSQL_PARAMETERS
	p_max_allowed_packet As culong Ptr
	p_net_buffer_length As culong Ptr
	extension As Any Ptr
End Type

Type mariadb_field_attr_t As Long
Enum
	MARIADB_FIELD_ATTR_DATA_TYPE_NAME = 0
	MARIADB_FIELD_ATTR_FORMAT_NAME = 1
End Enum

Const MARIADB_FIELD_ATTR_LAST = MARIADB_FIELD_ATTR_FORMAT_NAME
Declare Function mariadb_field_attr(ByVal attr As MARIADB_CONST_STRING Ptr, ByVal field As Const MYSQL_FIELD Ptr, ByVal type As mariadb_field_attr_t) As Long

Type enum_mysql_timestamp_type As Long
Enum
	MYSQL_TIMESTAMP_NONE = -2
	MYSQL_TIMESTAMP_ERROR = -1
	MYSQL_TIMESTAMP_DATE = 0
	MYSQL_TIMESTAMP_DATETIME = 1
	MYSQL_TIMESTAMP_TIME = 2
End Enum

Type st_mysql_time
	year As ULong
	month As ULong
	day As ULong
	hour As ULong
	minute As ULong
	second As ULong
	second_part As culong
	neg As Byte
	time_type As enum_mysql_timestamp_type
End Type

Type MYSQL_TIME As st_mysql_time
Const AUTO_SEC_PART_DIGITS = 39
Const SEC_PART_DIGITS = 6
Const MARIADB_INVALID_SOCKET = -1
Const MYSQL_WAIT_READ = 1
Const MYSQL_WAIT_WRITE = 2
Const MYSQL_WAIT_EXCEPT = 4
Const MYSQL_WAIT_TIMEOUT = 8

Type character_set
	number As ULong
	state As ULong
	csname As Const ZString Ptr
	name As Const ZString Ptr
	comment As Const ZString Ptr
	dir As Const ZString Ptr
	mbminlen As ULong
	mbmaxlen As ULong
End Type

Type MY_CHARSET_INFO As character_set
Const LOCAL_INFILE_ERROR_LEN = 512
Const MYSQL_NO_DATA = 100
Const MYSQL_DATA_TRUNCATED = 101
Const MYSQL_DEFAULT_PREFETCH_ROWS = Cast(culong, 1)
Const MADB_BIND_DUMMY = 1
#define MARIADB_STMT_BULK_SUPPORTED(stmt) ((stmt)->mysql AndAlso ((((stmt)->mysql->server_capabilities And CLIENT_MYSQL) = 0) AndAlso ((stmt)->mysql->extension->mariadb_server_capabilities And (MARIADB_CLIENT_STMT_BULK_OPERATIONS Shr 32))))
#macro SET_CLIENT_STMT_ERROR(a, b, c, d)
	Scope
		(a)->last_errno = (b)
		StrNCpy((a)->sqlstate, (c), SQLSTATE_LENGTH)
		(a)->sqlstate[SQLSTATE_LENGTH] = 0
		StrNCpy((a)->last_error, IIf((d), (d), ER((b))), MYSQL_ERRMSG_SIZE)
		(a)->last_error[(MYSQL_ERRMSG_SIZE - 1)] = 0
	End Scope
#endmacro
#macro CLEAR_CLIENT_STMT_ERROR(a)
	Scope
		(a)->last_errno = 0
		StrCpy((a)->sqlstate, "00000")
		(a)->last_error[0] = 0
	End Scope
#endmacro
Const MYSQL_PS_SKIP_RESULT_W_LEN = -1
Const MYSQL_PS_SKIP_RESULT_STR = -2
Const STMT_ID_LENGTH = 4
Type MYSQL_STMT As st_mysql_stmt
Type mysql_stmt_use_or_store_func As Function cdecl(ByVal As MYSQL_STMT Ptr) As MYSQL_RES Ptr

Type enum_stmt_attr_type As Long
Enum
	STMT_ATTR_UPDATE_MAX_LENGTH
	STMT_ATTR_CURSOR_TYPE
	STMT_ATTR_PREFETCH_ROWS
	STMT_ATTR_PREBIND_PARAMS = 200
	STMT_ATTR_ARRAY_SIZE
	STMT_ATTR_ROW_SIZE
	STMT_ATTR_STATE
	STMT_ATTR_CB_USER_DATA
	STMT_ATTR_CB_PARAM
	STMT_ATTR_CB_RESULT
End Enum

Type enum_cursor_type As Long
Enum
	CURSOR_TYPE_NO_CURSOR = 0
	CURSOR_TYPE_READ_ONLY = 1
	CURSOR_TYPE_FOR_UPDATE = 2
	CURSOR_TYPE_SCROLLABLE = 4
End Enum

Type enum_indicator_type As Long
Enum
	STMT_INDICATOR_NTS = -1
	STMT_INDICATOR_NONE = 0
	STMT_INDICATOR_NULL = 1
	STMT_INDICATOR_DEFAULT = 2
	STMT_INDICATOR_IGNORE = 3
	STMT_INDICATOR_IGNORE_ROW = 4
End Enum

Const STMT_BULK_FLAG_CLIENT_SEND_TYPES = 128
Const STMT_BULK_FLAG_INSERT_ID_REQUEST = 64

Type mysql_stmt_state As Long
Enum
	MYSQL_STMT_INITTED = 0
	MYSQL_STMT_PREPARED
	MYSQL_STMT_EXECUTED
	MYSQL_STMT_WAITING_USE_OR_STORE
	MYSQL_STMT_USE_OR_STORE_CALLED
	MYSQL_STMT_USER_FETCHING
	MYSQL_STMT_FETCH_DONE
End Enum

Type enum_mysqlnd_stmt_state As mysql_stmt_state

Union st_mysql_bind_u
	row_ptr As UByte Ptr
	indicator As ZString Ptr
End Union

Type st_mysql_bind
	length As culong Ptr
	is_null As my_bool Ptr
	buffer As Any Ptr
	error As my_bool Ptr
	u As st_mysql_bind_u
	store_param_func As Sub cdecl(ByVal NET As NET Ptr, ByVal param As st_mysql_bind Ptr)
	fetch_result As Sub cdecl(ByVal As st_mysql_bind Ptr, ByVal As MYSQL_FIELD Ptr, ByVal row As UByte Ptr Ptr)
	skip_result As Sub cdecl(ByVal As st_mysql_bind Ptr, ByVal As MYSQL_FIELD Ptr, ByVal row As UByte Ptr Ptr)
	buffer_length As culong
	offset As culong
	length_value As culong
	flags As ULong
	pack_length As ULong
	buffer_type As enum_field_types
	error_value As Byte
	is_unsigned As Byte
	long_data_used As Byte
	is_null_value As Byte
	extension As Any Ptr
End Type

Type MYSQL_BIND As st_mysql_bind

Type st_mysqlnd_upsert_result
	warning_count As ULong
	server_status As ULong
	affected_rows As ULongInt
	last_insert_id As ULongInt
End Type

Type mysql_upsert_status As st_mysqlnd_upsert_result

Type st_mysql_cmd_buffer
	buffer As UByte Ptr
	length As UInteger
End Type

Type MYSQL_CMD_BUFFER As st_mysql_cmd_buffer

Type st_mysql_error_info
	error_no As ULong
	error As ZString * 512 + 1
	sqlstate As ZString * 5 + 1
End Type

Type mysql_error_info As st_mysql_error_info
Type mysql_stmt_fetch_row_func As Function cdecl(ByVal stmt As MYSQL_STMT Ptr, ByVal row As UByte Ptr Ptr) As Long
Type ps_result_callback As Sub cdecl(ByVal Data As Any Ptr, ByVal column As ULong, ByVal row As UByte Ptr Ptr)
Type ps_param_callback As Function cdecl(ByVal Data As Any Ptr, ByVal bind As MYSQL_BIND Ptr, ByVal row_nr As ULong) As my_bool Ptr

Type st_mysql_stmt
	mem_root As MA_MEM_ROOT
	mysql As MYSQL Ptr
	stmt_id As culong
	flags As culong
	state As enum_mysqlnd_stmt_state
	fields As MYSQL_FIELD Ptr
	field_count As ULong
	param_count As ULong
	send_types_to_server As UByte
	params As MYSQL_BIND Ptr
	bind As MYSQL_BIND Ptr
	result As MYSQL_DATA
	result_cursor As MYSQL_ROWS Ptr
	bind_result_done As Byte
	bind_param_done As Byte
	upsert_status As mysql_upsert_status
	last_errno As ULong
	last_error As ZString * 512 + 1
	sqlstate As ZString * 5 + 1
	update_max_length As Byte
	prefetch_rows As culong
	list As _LIST
	cursor_exists As Byte
	extension As Any Ptr
	fetch_row_func As mysql_stmt_fetch_row_func
	execute_count As ULong
	default_rset_handler As mysql_stmt_use_or_store_func
	request_buffer As UByte Ptr
	array_size As ULong
	row_size As UInteger
	prebind_params As ULong
	user_data As Any Ptr
	result_callback As ps_result_callback
	param_callback As ps_param_callback
	request_length As UInteger
End Type

Type ps_field_fetch_func As Sub cdecl(ByVal r_param As MYSQL_BIND Ptr, ByVal Field As Const MYSQL_FIELD Ptr, ByVal row As UByte Ptr Ptr)

Type st_mysql_perm_bind
	func As ps_field_fetch_func
	pack_len As Long
	max_len As culong
End Type

Type MYSQL_PS_CONVERSION As st_mysql_perm_bind
Extern mysql_ps_fetch_functions(0 To (MYSQL_TYPE_GEOMETRY + 1) - 1) As MYSQL_PS_CONVERSION
Declare Function ma_net_safe_read cdecl(ByVal mysql As MYSQL Ptr) As culong
Declare Sub mysql_init_ps_subsystem cdecl()
Declare Function net_field_length cdecl(ByVal packet As UByte Ptr Ptr) As culong
Declare Function ma_simple_command cdecl(ByVal mysql As MYSQL Ptr, ByVal command As enum_server_command, ByVal arg As Const ZString Ptr, ByVal length As UInteger, ByVal skipp_check As Byte, ByVal opt_arg As Any Ptr) As Long
Declare Function mysql_stmt_init(ByVal mysql As MYSQL Ptr) As MYSQL_STMT Ptr
Declare Function mysql_stmt_prepare(ByVal stmt As MYSQL_STMT Ptr, ByVal query As Const ZString Ptr, ByVal length As culong) As Long
Declare Function mysql_stmt_execute(ByVal stmt As MYSQL_STMT Ptr) As Long
Declare Function mysql_stmt_fetch(ByVal stmt As MYSQL_STMT Ptr) As Long
declare function mysql_stmt_fetch_column(byval stmt as MYSQL_STMT ptr, byval bind_arg as MYSQL_BIND ptr, byval column as ulong, byval offset as culong) as long
Declare Function mysql_stmt_store_result(ByVal stmt As MYSQL_STMT Ptr) As Long
Declare Function mysql_stmt_param_count(ByVal stmt As MYSQL_STMT Ptr) As culong
Declare Function mysql_stmt_attr_set(ByVal stmt As MYSQL_STMT Ptr, ByVal attr_type As enum_stmt_attr_type, ByVal attr As Const Any Ptr) As Byte
Declare Function mysql_stmt_attr_get(ByVal stmt As MYSQL_STMT Ptr, ByVal attr_type As enum_stmt_attr_type, ByVal attr As Any Ptr) As Byte
Declare Function mysql_stmt_bind_param(ByVal stmt As MYSQL_STMT Ptr, ByVal bnd As MYSQL_BIND Ptr) As Byte
Declare Function mysql_stmt_bind_result(ByVal stmt As MYSQL_STMT Ptr, ByVal bnd As MYSQL_BIND Ptr) As Byte
Declare Function mysql_stmt_close(ByVal stmt As MYSQL_STMT Ptr) As Byte
Declare Function mysql_stmt_reset(ByVal stmt As MYSQL_STMT Ptr) As Byte
Declare Function mysql_stmt_free_result(ByVal stmt As MYSQL_STMT Ptr) As Byte
Declare Function mysql_stmt_send_long_data(ByVal stmt As MYSQL_STMT Ptr, ByVal param_number As ULong, ByVal data As Const ZString Ptr, ByVal length As culong) As Byte
Declare Function mysql_stmt_result_metadata(ByVal stmt As MYSQL_STMT Ptr) As MYSQL_RES Ptr
Declare Function mysql_stmt_param_metadata(ByVal stmt As MYSQL_STMT Ptr) As MYSQL_RES Ptr
Declare Function mysql_stmt_errno(ByVal stmt As MYSQL_STMT Ptr) As ULong
Declare Function mysql_stmt_error(ByVal stmt As MYSQL_STMT Ptr) As Const ZString Ptr
Declare Function mysql_stmt_sqlstate(ByVal stmt As MYSQL_STMT Ptr) As Const ZString Ptr
Declare Function mysql_stmt_row_seek(ByVal stmt As MYSQL_STMT Ptr, ByVal offset As MYSQL_ROW_OFFSET) As MYSQL_ROW_OFFSET
Declare Function mysql_stmt_row_tell(ByVal stmt As MYSQL_STMT Ptr) As MYSQL_ROW_OFFSET
Declare Sub mysql_stmt_data_seek(ByVal stmt As MYSQL_STMT Ptr, ByVal offset As ULongInt)
Declare Function mysql_stmt_num_rows(ByVal stmt As MYSQL_STMT Ptr) As ULongInt
Declare Function mysql_stmt_affected_rows(ByVal stmt As MYSQL_STMT Ptr) As ULongInt
Declare Function mysql_stmt_insert_id(ByVal stmt As MYSQL_STMT Ptr) As ULongInt
Declare Function mysql_stmt_field_count(ByVal stmt As MYSQL_STMT Ptr) As ULong
Declare Function mysql_stmt_next_result(ByVal stmt As MYSQL_STMT Ptr) As Long
Declare Function mysql_stmt_more_results(ByVal stmt As MYSQL_STMT Ptr) As Byte
Declare Function mariadb_stmt_execute_direct(ByVal stmt As MYSQL_STMT Ptr, ByVal stmt_str As Const ZString Ptr, ByVal length As UInteger) As Long
Declare Function mariadb_stmt_fetch_fields(ByVal stmt As MYSQL_STMT Ptr) As MYSQL_FIELD Ptr

type st_mysql_client_plugin
	As Long type
	interface_version As ULong
	name As Const ZString Ptr
	author As Const ZString Ptr
	desc As Const ZString Ptr
	version(0 To 2) As ULong
	license As Const ZString Ptr
	mysql_api As Any Ptr
	init As Function cdecl(ByVal As ZString Ptr, ByVal As UInteger, ByVal As Long, ByVal As va_list) As Long
	deinit As Function cdecl() As Long
	options As Function cdecl(ByVal Option As Const ZString Ptr, ByVal As Const Any Ptr) As Long
end type

Declare Function mysql_load_plugin cdecl(ByVal mysql As st_mysql Ptr, ByVal name As Const ZString Ptr, ByVal type As Long, ByVal argc As Long, ...) As st_mysql_client_plugin Ptr
Declare Function mysql_load_plugin_v(ByVal mysql As st_mysql Ptr, ByVal name As Const ZString Ptr, ByVal type As Long, ByVal argc As Long, ByVal args As va_list) As st_mysql_client_plugin Ptr
Declare Function mysql_client_find_plugin(ByVal mysql As st_mysql Ptr, ByVal name As Const ZString Ptr, ByVal type As Long) As st_mysql_client_plugin Ptr
Declare Function mysql_client_register_plugin(ByVal mysql As st_mysql Ptr, ByVal plugin As st_mysql_client_plugin Ptr) As st_mysql_client_plugin Ptr
Declare Sub mysql_set_local_infile_handler(ByVal mysql As MYSQL Ptr, ByVal local_infile_init As Function cdecl(ByVal As Any Ptr Ptr, ByVal As Const ZString Ptr, ByVal As Any Ptr) As Long, ByVal local_infile_read As Function cdecl(ByVal As Any Ptr, ByVal As ZString Ptr, ByVal As ULong) As Long, ByVal local_infile_end As Sub cdecl(ByVal As Any Ptr), ByVal local_infile_error As Function cdecl(ByVal As Any Ptr, ByVal As ZString Ptr, ByVal As ULong) As Long, ByVal As Any Ptr)
Declare Sub mysql_set_local_infile_default cdecl(ByVal mysql As MYSQL Ptr)
Declare Sub my_set_error cdecl(ByVal mysql As MYSQL Ptr, ByVal error_nr As ULong, ByVal sqlstate As Const ZString Ptr, ByVal format As Const ZString Ptr, ...)
Declare Function mysql_num_rows(ByVal res As MYSQL_RES Ptr) As my_ulonglong
Declare Function mysql_num_fields(ByVal res As MYSQL_RES Ptr) As ULong
Declare Function mysql_eof(ByVal res As MYSQL_RES Ptr) As Byte
Declare Function mysql_fetch_field_direct(ByVal res As MYSQL_RES Ptr, ByVal fieldnr As ULong) As MYSQL_FIELD Ptr
Declare Function mysql_fetch_fields(ByVal res As MYSQL_RES Ptr) As MYSQL_FIELD Ptr
Declare Function mysql_row_tell(ByVal res As MYSQL_RES Ptr) As MYSQL_ROWS Ptr
Declare Function mysql_field_tell(ByVal res As MYSQL_RES Ptr) As ULong
Declare Function mysql_field_count(ByVal mysql As MYSQL Ptr) As ULong
Declare Function mysql_more_results(ByVal mysql As MYSQL Ptr) As Byte
Declare Function mysql_next_result(ByVal mysql As MYSQL Ptr) As Long
Declare Function mysql_affected_rows(ByVal mysql As MYSQL Ptr) As my_ulonglong
Declare Function mysql_autocommit(ByVal mysql As MYSQL Ptr, ByVal mode As Byte) As Byte
Declare Function mysql_commit(ByVal mysql As MYSQL Ptr) As Byte
Declare Function mysql_rollback(ByVal mysql As MYSQL Ptr) As Byte
Declare Function mysql_insert_id(ByVal mysql As MYSQL Ptr) As my_ulonglong
Declare Function mysql_errno(ByVal mysql As MYSQL Ptr) As ULong
Declare Function mysql_error(ByVal mysql As MYSQL Ptr) As Const ZString Ptr
Declare Function mysql_info(ByVal mysql As MYSQL Ptr) As Const ZString Ptr
Declare Function mysql_thread_id(ByVal mysql As MYSQL Ptr) As culong
Declare Function mysql_character_set_name(ByVal mysql As MYSQL Ptr) As Const ZString Ptr
Declare Sub mysql_get_character_set_info(ByVal mysql As MYSQL Ptr, ByVal cs As MY_CHARSET_INFO Ptr)
Declare Function mysql_set_character_set(ByVal mysql As MYSQL Ptr, ByVal csname As Const ZString Ptr) As Long
Declare Function mariadb_get_infov cdecl(ByVal mysql As MYSQL Ptr, ByVal value As mariadb_value, ByVal arg As Any Ptr, ...) As Byte
Declare Function mariadb_get_info(ByVal mysql As MYSQL Ptr, ByVal value As mariadb_value, ByVal arg As Any Ptr) As Byte
Declare Function mysql_init(ByVal mysql As MYSQL Ptr) As MYSQL Ptr
Declare Function mysql_ssl_set(ByVal mysql As MYSQL Ptr, ByVal key As Const ZString Ptr, ByVal cert As Const ZString Ptr, ByVal ca As Const ZString Ptr, ByVal capath As Const ZString Ptr, ByVal cipher As Const ZString Ptr) As Long
Declare Function mysql_get_ssl_cipher(ByVal mysql As MYSQL Ptr) As Const ZString Ptr
Declare Function mysql_change_user(ByVal mysql As MYSQL Ptr, ByVal user As Const ZString Ptr, ByVal passwd As Const ZString Ptr, ByVal db As Const ZString Ptr) As Byte
Declare Function mysql_real_connect(ByVal mysql As MYSQL Ptr, ByVal host As Const ZString Ptr, ByVal user As Const ZString Ptr, ByVal passwd As Const ZString Ptr, ByVal db As Const ZString Ptr, ByVal port As ULong, ByVal unix_socket As Const ZString Ptr, ByVal clientflag As culong) As MYSQL Ptr
Declare Sub mysql_close(ByVal sock As MYSQL Ptr)
Declare Function mysql_select_db(ByVal mysql As MYSQL Ptr, ByVal db As Const ZString Ptr) As Long
Declare Function mysql_query(ByVal mysql As MYSQL Ptr, ByVal q As Const ZString Ptr) As Long
Declare Function mysql_send_query(ByVal mysql As MYSQL Ptr, ByVal q As Const ZString Ptr, ByVal length As culong) As Long
Declare Function mysql_read_query_result(ByVal mysql As MYSQL Ptr) As Byte
Declare Function mysql_real_query(ByVal mysql As MYSQL Ptr, ByVal q As Const ZString Ptr, ByVal length As culong) As Long
Declare Function mysql_shutdown(ByVal mysql As MYSQL Ptr, ByVal shutdown_level As mysql_enum_shutdown_level) As Long
Declare Function mysql_dump_debug_info(ByVal mysql As MYSQL Ptr) As Long
Declare Function mysql_refresh(ByVal mysql As MYSQL Ptr, ByVal refresh_options As ULong) As Long
Declare Function mysql_kill(ByVal mysql As MYSQL Ptr, ByVal pid As culong) As Long
Declare Function mysql_ping(ByVal mysql As MYSQL Ptr) As Long
Declare Function mysql_stat(ByVal mysql As MYSQL Ptr) As ZString Ptr
Declare Function mysql_get_server_info(ByVal mysql As MYSQL Ptr) As ZString Ptr
Declare Function mysql_get_server_version(ByVal mysql As MYSQL Ptr) As culong
Declare Function mysql_get_host_info(ByVal mysql As MYSQL Ptr) As ZString Ptr
Declare Function mysql_get_proto_info(ByVal mysql As MYSQL Ptr) As ULong
Declare Function mysql_list_dbs(ByVal mysql As MYSQL Ptr, ByVal wild As Const ZString Ptr) As MYSQL_RES Ptr
Declare Function mysql_list_tables(ByVal mysql As MYSQL Ptr, ByVal wild As Const ZString Ptr) As MYSQL_RES Ptr
Declare Function mysql_list_fields(ByVal mysql As MYSQL Ptr, ByVal table As Const ZString Ptr, ByVal wild As Const ZString Ptr) As MYSQL_RES Ptr
Declare Function mysql_list_processes(ByVal mysql As MYSQL Ptr) As MYSQL_RES Ptr
Declare Function mysql_store_result(ByVal mysql As MYSQL Ptr) As MYSQL_RES Ptr
Declare Function mysql_use_result(ByVal mysql As MYSQL Ptr) As MYSQL_RES Ptr
Declare Function mysql_options(ByVal mysql As MYSQL Ptr, ByVal option As mysql_option, ByVal arg As Const Any Ptr) As Long
Declare Function mysql_options4(ByVal mysql As MYSQL Ptr, ByVal option As mysql_option, ByVal arg1 As Const Any Ptr, ByVal arg2 As Const Any Ptr) As Long
Declare Sub mysql_free_result(ByVal result As MYSQL_RES Ptr)
Declare Sub mysql_data_seek(ByVal result As MYSQL_RES Ptr, ByVal offset As ULongInt)
Declare Function mysql_row_seek(ByVal result As MYSQL_RES Ptr, ByVal As MYSQL_ROW_OFFSET) As MYSQL_ROW_OFFSET
Declare Function mysql_field_seek(ByVal result As MYSQL_RES Ptr, ByVal offset As MYSQL_FIELD_OFFSET) As MYSQL_FIELD_OFFSET
Declare Function mysql_fetch_row(ByVal result As MYSQL_RES Ptr) As MYSQL_ROW
Declare Function mysql_fetch_lengths(ByVal result As MYSQL_RES Ptr) As culong Ptr
Declare Function mysql_fetch_field(ByVal result As MYSQL_RES Ptr) As MYSQL_FIELD Ptr
Declare Function mysql_escape_string(ByVal to As ZString Ptr, ByVal from As Const ZString Ptr, ByVal from_length As culong) As culong
Declare Function mysql_real_escape_string(ByVal mysql As MYSQL Ptr, ByVal to As ZString Ptr, ByVal from As Const ZString Ptr, ByVal length As culong) As culong
Declare Function mysql_thread_safe() As ULong
Declare Function mysql_warning_count(ByVal mysql As MYSQL Ptr) As ULong
Declare Function mysql_sqlstate(ByVal mysql As MYSQL Ptr) As Const ZString Ptr
Declare Function mysql_server_init(ByVal argc As Long, ByVal argv As ZString Ptr Ptr, ByVal groups As ZString Ptr Ptr) As Long
Declare Sub mysql_server_end()
Declare Sub mysql_thread_end()
Declare Function mysql_thread_init() As Byte
Declare Function mysql_set_server_option(ByVal mysql As MYSQL Ptr, ByVal option As enum_mysql_set_option) As Long
Declare Function mysql_get_client_info() As Const ZString Ptr
Declare Function mysql_get_client_version() As culong
Declare Function mariadb_connection(ByVal mysql As MYSQL Ptr) As Byte
Declare Function mysql_get_server_name(ByVal mysql As MYSQL Ptr) As Const ZString Ptr
Declare Function mariadb_get_charset_by_name(ByVal csname As Const ZString Ptr) As MARIADB_CHARSET_INFO Ptr
Declare Function mariadb_get_charset_by_nr(ByVal csnr As ULong) As MARIADB_CHARSET_INFO Ptr
Declare Function mariadb_convert_string(ByVal from As Const ZString Ptr, ByVal from_len As UInteger Ptr, ByVal from_cs As MARIADB_CHARSET_INFO Ptr, ByVal to As ZString Ptr, ByVal to_len As UInteger Ptr, ByVal to_cs As MARIADB_CHARSET_INFO Ptr, ByVal errorcode As Long Ptr) As UInteger
Declare Function mysql_optionsv cdecl(ByVal mysql As MYSQL Ptr, ByVal option As mysql_option, ...) As Long
Declare Function mysql_get_optionv cdecl(ByVal mysql As MYSQL Ptr, ByVal option As mysql_option, ByVal arg As Any Ptr, ...) As Long
Declare Function mysql_get_option(ByVal mysql As MYSQL Ptr, ByVal option As mysql_option, ByVal arg As Any Ptr) As Long
Declare Function mysql_hex_string(ByVal to As ZString Ptr, ByVal from As Const ZString Ptr, ByVal len As culong) As culong

#ifdef __FB_UNIX__
	Declare Function mysql_get_socket(ByVal mysql As MYSQL Ptr) As my_socket
#elseif defined(__FB_WIN32__) And (Not defined(__FB_64BIT__))
	Declare Function mysql_get_socket(ByVal mysql As MYSQL Ptr) As ULong
#else
	Declare Function mysql_get_socket(ByVal mysql As MYSQL Ptr) As ULongInt
#endif

Declare Function mysql_get_timeout_value(ByVal mysql As Const mysql Ptr) As ULong
Declare Function mysql_get_timeout_value_ms(ByVal mysql As Const mysql Ptr) As ULong
Declare Function mariadb_reconnect(ByVal mysql As MYSQL Ptr) As Byte
Declare Function mariadb_cancel(ByVal mysql As MYSQL Ptr) As Long
Declare Sub mysql_debug(ByVal debug As Const ZString Ptr)
Declare Function mysql_net_read_packet(ByVal mysql As MYSQL Ptr) As culong
Declare Function mysql_net_field_length(ByVal packet As UByte Ptr Ptr) As culong
Declare Function mysql_embedded() As Byte
Declare Function mysql_get_parameters() As MYSQL_PARAMETERS Ptr
Declare Function mysql_close_start(ByVal sock As MYSQL Ptr) As Long
Declare Function mysql_close_cont(ByVal sock As MYSQL Ptr, ByVal status As Long) As Long
Declare Function mysql_commit_start(ByVal ret As my_bool Ptr, ByVal mysql As MYSQL Ptr) As Long
Declare Function mysql_commit_cont(ByVal ret As my_bool Ptr, ByVal mysql As MYSQL Ptr, ByVal status As Long) As Long
Declare Function mysql_dump_debug_info_cont(ByVal ret As Long Ptr, ByVal mysql As MYSQL Ptr, ByVal ready_status As Long) As Long
Declare Function mysql_dump_debug_info_start(ByVal ret As Long Ptr, ByVal mysql As MYSQL Ptr) As Long
Declare Function mysql_rollback_start(ByVal ret As my_bool Ptr, ByVal mysql As MYSQL Ptr) As Long
Declare Function mysql_rollback_cont(ByVal ret As my_bool Ptr, ByVal mysql As MYSQL Ptr, ByVal status As Long) As Long
Declare Function mysql_autocommit_start(ByVal ret As my_bool Ptr, ByVal mysql As MYSQL Ptr, ByVal auto_mode As Byte) As Long
Declare Function mysql_list_fields_cont(ByVal ret As MYSQL_RES Ptr Ptr, ByVal mysql As MYSQL Ptr, ByVal ready_status As Long) As Long
Declare Function mysql_list_fields_start(ByVal ret As MYSQL_RES Ptr Ptr, ByVal mysql As MYSQL Ptr, ByVal table As Const ZString Ptr, ByVal wild As Const ZString Ptr) As Long
Declare Function mysql_autocommit_cont(ByVal ret As my_bool Ptr, ByVal mysql As MYSQL Ptr, ByVal status As Long) As Long
Declare Function mysql_next_result_start(ByVal ret As Long Ptr, ByVal mysql As MYSQL Ptr) As Long
Declare Function mysql_next_result_cont(ByVal ret As Long Ptr, ByVal mysql As MYSQL Ptr, ByVal status As Long) As Long
Declare Function mysql_select_db_start(ByVal ret As Long Ptr, ByVal mysql As MYSQL Ptr, ByVal db As Const ZString Ptr) As Long
Declare Function mysql_select_db_cont(ByVal ret As Long Ptr, ByVal mysql As MYSQL Ptr, ByVal ready_status As Long) As Long
Declare Function mysql_stmt_warning_count(ByVal stmt As MYSQL_STMT Ptr) As Long
Declare Function mysql_stmt_next_result_start(ByVal ret As Long Ptr, ByVal stmt As MYSQL_STMT Ptr) As Long
Declare Function mysql_stmt_next_result_cont(ByVal ret As Long Ptr, ByVal stmt As MYSQL_STMT Ptr, ByVal status As Long) As Long
Declare Function mysql_set_character_set_start(ByVal ret As Long Ptr, ByVal mysql As MYSQL Ptr, ByVal csname As Const ZString Ptr) As Long
Declare Function mysql_set_character_set_cont(ByVal ret As Long Ptr, ByVal mysql As MYSQL Ptr, ByVal status As Long) As Long
Declare Function mysql_change_user_start(ByVal ret As my_bool Ptr, ByVal mysql As MYSQL Ptr, ByVal user As Const ZString Ptr, ByVal passwd As Const ZString Ptr, ByVal db As Const ZString Ptr) As Long
Declare Function mysql_change_user_cont(ByVal ret As my_bool Ptr, ByVal mysql As MYSQL Ptr, ByVal status As Long) As Long
Declare Function mysql_real_connect_start(ByVal ret As MYSQL Ptr Ptr, ByVal mysql As MYSQL Ptr, ByVal host As Const ZString Ptr, ByVal user As Const ZString Ptr, ByVal passwd As Const ZString Ptr, ByVal db As Const ZString Ptr, ByVal port As ULong, ByVal unix_socket As Const ZString Ptr, ByVal clientflag As culong) As Long
Declare Function mysql_real_connect_cont(ByVal ret As MYSQL Ptr Ptr, ByVal mysql As MYSQL Ptr, ByVal status As Long) As Long
Declare Function mysql_query_start(ByVal ret As Long Ptr, ByVal mysql As MYSQL Ptr, ByVal q As Const ZString Ptr) As Long
Declare Function mysql_query_cont(ByVal ret As Long Ptr, ByVal mysql As MYSQL Ptr, ByVal status As Long) As Long
Declare Function mysql_send_query_start(ByVal ret As Long Ptr, ByVal mysql As MYSQL Ptr, ByVal q As Const ZString Ptr, ByVal length As culong) As Long
Declare Function mysql_send_query_cont(ByVal ret As Long Ptr, ByVal mysql As MYSQL Ptr, ByVal status As Long) As Long
Declare Function mysql_real_query_start(ByVal ret As Long Ptr, ByVal mysql As MYSQL Ptr, ByVal q As Const ZString Ptr, ByVal length As culong) As Long
Declare Function mysql_real_query_cont(ByVal ret As Long Ptr, ByVal mysql As MYSQL Ptr, ByVal status As Long) As Long
Declare Function mysql_store_result_start(ByVal ret As MYSQL_RES Ptr Ptr, ByVal mysql As MYSQL Ptr) As Long
Declare Function mysql_store_result_cont(ByVal ret As MYSQL_RES Ptr Ptr, ByVal mysql As MYSQL Ptr, ByVal status As Long) As Long
Declare Function mysql_shutdown_start(ByVal ret As Long Ptr, ByVal mysql As MYSQL Ptr, ByVal shutdown_level As mysql_enum_shutdown_level) As Long
Declare Function mysql_shutdown_cont(ByVal ret As Long Ptr, ByVal mysql As MYSQL Ptr, ByVal status As Long) As Long
Declare Function mysql_refresh_start(ByVal ret As Long Ptr, ByVal mysql As MYSQL Ptr, ByVal refresh_options As ULong) As Long
Declare Function mysql_refresh_cont(ByVal ret As Long Ptr, ByVal mysql As MYSQL Ptr, ByVal status As Long) As Long
Declare Function mysql_kill_start(ByVal ret As Long Ptr, ByVal mysql As MYSQL Ptr, ByVal pid As culong) As Long
Declare Function mysql_kill_cont(ByVal ret As Long Ptr, ByVal mysql As MYSQL Ptr, ByVal status As Long) As Long
Declare Function mysql_set_server_option_start(ByVal ret As Long Ptr, ByVal mysql As MYSQL Ptr, ByVal option As enum_mysql_set_option) As Long
Declare Function mysql_set_server_option_cont(ByVal ret As Long Ptr, ByVal mysql As MYSQL Ptr, ByVal status As Long) As Long
Declare Function mysql_ping_start(ByVal ret As Long Ptr, ByVal mysql As MYSQL Ptr) As Long
Declare Function mysql_ping_cont(ByVal ret As Long Ptr, ByVal mysql As MYSQL Ptr, ByVal status As Long) As Long
Declare Function mysql_stat_start(ByVal ret As Const ZString Ptr Ptr, ByVal mysql As MYSQL Ptr) As Long
Declare Function mysql_stat_cont(ByVal ret As Const ZString Ptr Ptr, ByVal mysql As MYSQL Ptr, ByVal status As Long) As Long
Declare Function mysql_free_result_start(ByVal result As MYSQL_RES Ptr) As Long
Declare Function mysql_free_result_cont(ByVal result As MYSQL_RES Ptr, ByVal status As Long) As Long
Declare Function mysql_fetch_row_start(ByVal ret As MYSQL_ROW Ptr, ByVal result As MYSQL_RES Ptr) As Long
Declare Function mysql_fetch_row_cont(ByVal ret As MYSQL_ROW Ptr, ByVal result As MYSQL_RES Ptr, ByVal status As Long) As Long
Declare Function mysql_read_query_result_start(ByVal ret As my_bool Ptr, ByVal mysql As MYSQL Ptr) As Long
Declare Function mysql_read_query_result_cont(ByVal ret As my_bool Ptr, ByVal mysql As MYSQL Ptr, ByVal status As Long) As Long
Declare Function mysql_reset_connection_start(ByVal ret As Long Ptr, ByVal mysql As MYSQL Ptr) As Long
Declare Function mysql_reset_connection_cont(ByVal ret As Long Ptr, ByVal mysql As MYSQL Ptr, ByVal status As Long) As Long
Declare Function mysql_session_track_get_next(ByVal mysql As MYSQL Ptr, ByVal type As enum_session_state_type, ByVal data As Const ZString Ptr Ptr, ByVal length As UInteger Ptr) As Long
Declare Function mysql_session_track_get_first(ByVal mysql As MYSQL Ptr, ByVal type As enum_session_state_type, ByVal data As Const ZString Ptr Ptr, ByVal length As UInteger Ptr) As Long
Declare Function mysql_stmt_prepare_start(ByVal ret As Long Ptr, ByVal stmt As MYSQL_STMT Ptr, ByVal query As Const ZString Ptr, ByVal length As culong) As Long
Declare Function mysql_stmt_prepare_cont(ByVal ret As Long Ptr, ByVal stmt As MYSQL_STMT Ptr, ByVal status As Long) As Long
Declare Function mysql_stmt_execute_start(ByVal ret As Long Ptr, ByVal stmt As MYSQL_STMT Ptr) As Long
Declare Function mysql_stmt_execute_cont(ByVal ret As Long Ptr, ByVal stmt As MYSQL_STMT Ptr, ByVal status As Long) As Long
Declare Function mysql_stmt_fetch_start(ByVal ret As Long Ptr, ByVal stmt As MYSQL_STMT Ptr) As Long
Declare Function mysql_stmt_fetch_cont(ByVal ret As Long Ptr, ByVal stmt As MYSQL_STMT Ptr, ByVal status As Long) As Long
Declare Function mysql_stmt_store_result_start(ByVal ret As Long Ptr, ByVal stmt As MYSQL_STMT Ptr) As Long
Declare Function mysql_stmt_store_result_cont(ByVal ret As Long Ptr, ByVal stmt As MYSQL_STMT Ptr, ByVal status As Long) As Long
Declare Function mysql_stmt_close_start(ByVal ret As my_bool Ptr, ByVal stmt As MYSQL_STMT Ptr) As Long
Declare Function mysql_stmt_close_cont(ByVal ret As my_bool Ptr, ByVal stmt As MYSQL_STMT Ptr, ByVal status As Long) As Long
Declare Function mysql_stmt_reset_start(ByVal ret As my_bool Ptr, ByVal stmt As MYSQL_STMT Ptr) As Long
Declare Function mysql_stmt_reset_cont(ByVal ret As my_bool Ptr, ByVal stmt As MYSQL_STMT Ptr, ByVal status As Long) As Long
Declare Function mysql_stmt_free_result_start(ByVal ret As my_bool Ptr, ByVal stmt As MYSQL_STMT Ptr) As Long
Declare Function mysql_stmt_free_result_cont(ByVal ret As my_bool Ptr, ByVal stmt As MYSQL_STMT Ptr, ByVal status As Long) As Long
Declare Function mysql_stmt_send_long_data_start(ByVal ret As my_bool Ptr, ByVal stmt As MYSQL_STMT Ptr, ByVal param_number As ULong, ByVal data As Const ZString Ptr, ByVal len As culong) As Long
Declare Function mysql_stmt_send_long_data_cont(ByVal ret As my_bool Ptr, ByVal stmt As MYSQL_STMT Ptr, ByVal status As Long) As Long
Declare Function mysql_reset_connection(ByVal mysql As MYSQL Ptr) As Long

Type st_mariadb_api
	mysql_num_rows As Function(ByVal res As MYSQL_RES Ptr) As ULongInt
	mysql_num_fields As Function(ByVal res As MYSQL_RES Ptr) As ULong
	mysql_eof As Function(ByVal res As MYSQL_RES Ptr) As Byte
	mysql_fetch_field_direct As Function(ByVal res As MYSQL_RES Ptr, ByVal fieldnr As ULong) As MYSQL_FIELD Ptr
	mysql_fetch_fields As Function(ByVal res As MYSQL_RES Ptr) As MYSQL_FIELD Ptr
	mysql_row_tell As Function(ByVal res As MYSQL_RES Ptr) As MYSQL_ROWS Ptr
	mysql_field_tell As Function(ByVal res As MYSQL_RES Ptr) As ULong
	mysql_field_count As Function(ByVal MYSQL As MYSQL Ptr) As ULong
	mysql_more_results As Function(ByVal MYSQL As MYSQL Ptr) As Byte
	mysql_next_result As Function(ByVal MYSQL As MYSQL Ptr) As Long
	mysql_affected_rows As Function(ByVal MYSQL As MYSQL Ptr) As ULongInt
	mysql_autocommit As Function(ByVal MYSQL As MYSQL Ptr, ByVal mode As Byte) As Byte
	mysql_commit As Function(ByVal MYSQL As MYSQL Ptr) As Byte
	mysql_rollback As Function(ByVal MYSQL As MYSQL Ptr) As Byte
	mysql_insert_id As Function(ByVal MYSQL As MYSQL Ptr) As ULongInt
	mysql_errno As Function(ByVal MYSQL As MYSQL Ptr) As ULong
	mysql_error As Function(ByVal MYSQL As MYSQL Ptr) As Const ZString Ptr
	mysql_info As Function(ByVal MYSQL As MYSQL Ptr) As Const ZString Ptr
	mysql_thread_id As Function(ByVal MYSQL As MYSQL Ptr) As culong
	mysql_character_set_name As Function(ByVal MYSQL As MYSQL Ptr) As Const ZString Ptr
	mysql_get_character_set_info As Sub(ByVal MYSQL As MYSQL Ptr, ByVal cs As MY_CHARSET_INFO Ptr)
	mysql_set_character_set As Function(ByVal MYSQL As MYSQL Ptr, ByVal csname As Const ZString Ptr) As Long
	mariadb_get_infov As Function cdecl(ByVal MYSQL As MYSQL Ptr, ByVal value As mariadb_value, ByVal arg As Any Ptr, ...) As Byte
	mariadb_get_info As Function(ByVal MYSQL As MYSQL Ptr, ByVal value As mariadb_value, ByVal arg As Any Ptr) As Byte
	mysql_init As Function(ByVal MYSQL As MYSQL Ptr) As MYSQL Ptr
	mysql_ssl_set As Function(ByVal MYSQL As MYSQL Ptr, ByVal key As Const ZString Ptr, ByVal cert As Const ZString Ptr, ByVal ca As Const ZString Ptr, ByVal capath As Const ZString Ptr, ByVal cipher As Const ZString Ptr) As Long
	mysql_get_ssl_cipher As Function(ByVal MYSQL As MYSQL Ptr) As Const ZString Ptr
	mysql_change_user As Function(ByVal MYSQL As MYSQL Ptr, ByVal user As Const ZString Ptr, ByVal passwd As Const ZString Ptr, ByVal db As Const ZString Ptr) As Byte
	mysql_real_connect As Function(ByVal MYSQL As MYSQL Ptr, ByVal host As Const ZString Ptr, ByVal user As Const ZString Ptr, ByVal passwd As Const ZString Ptr, ByVal db As Const ZString Ptr, ByVal port As ULong, ByVal unix_socket As Const ZString Ptr, ByVal clientflag As culong) As MYSQL Ptr
	mysql_close As Sub(ByVal sock As MYSQL Ptr)
	mysql_select_db As Function(ByVal MYSQL As MYSQL Ptr, ByVal db As Const ZString Ptr) As Long
	mysql_query As Function(ByVal MYSQL As MYSQL Ptr, ByVal q As Const ZString Ptr) As Long
	mysql_send_query As Function(ByVal MYSQL As MYSQL Ptr, ByVal q As Const ZString Ptr, ByVal length As culong) As Long
	mysql_read_query_result As Function(ByVal MYSQL As MYSQL Ptr) As Byte
	mysql_real_query As Function(ByVal MYSQL As MYSQL Ptr, ByVal q As Const ZString Ptr, ByVal length As culong) As Long
	mysql_shutdown As Function(ByVal MYSQL As MYSQL Ptr, ByVal shutdown_level As mysql_enum_shutdown_level) As Long
	mysql_dump_debug_info As Function(ByVal MYSQL As MYSQL Ptr) As Long
	mysql_refresh As Function(ByVal MYSQL As MYSQL Ptr, ByVal refresh_options As ULong) As Long
	mysql_kill As Function(ByVal MYSQL As MYSQL Ptr, ByVal pid As culong) As Long
	mysql_ping As Function(ByVal MYSQL As MYSQL Ptr) As Long
	mysql_stat As Function(ByVal MYSQL As MYSQL Ptr) As ZString Ptr
	mysql_get_server_info As Function(ByVal MYSQL As MYSQL Ptr) As ZString Ptr
	mysql_get_server_version As Function(ByVal MYSQL As MYSQL Ptr) As culong
	mysql_get_host_info As Function(ByVal MYSQL As MYSQL Ptr) As ZString Ptr
	mysql_get_proto_info As Function(ByVal MYSQL As MYSQL Ptr) As ULong
	mysql_list_dbs As Function(ByVal MYSQL As MYSQL Ptr, ByVal wild As Const ZString Ptr) As MYSQL_RES Ptr
	mysql_list_tables As Function(ByVal MYSQL As MYSQL Ptr, ByVal wild As Const ZString Ptr) As MYSQL_RES Ptr
	mysql_list_fields As Function(ByVal MYSQL As MYSQL Ptr, ByVal table As Const ZString Ptr, ByVal wild As Const ZString Ptr) As MYSQL_RES Ptr
	mysql_list_processes As Function(ByVal MYSQL As MYSQL Ptr) As MYSQL_RES Ptr
	mysql_store_result As Function(ByVal MYSQL As MYSQL Ptr) As MYSQL_RES Ptr
	mysql_use_result As Function(ByVal MYSQL As MYSQL Ptr) As MYSQL_RES Ptr
	mysql_options As Function(ByVal MYSQL As MYSQL Ptr, ByVal Option As mysql_option, ByVal arg As Const Any Ptr) As Long
	mysql_free_result As Sub(ByVal Result As MYSQL_RES Ptr)
	mysql_data_seek As Sub(ByVal Result As MYSQL_RES Ptr, ByVal offset As ULongInt)
	mysql_row_seek As Function(ByVal Result As MYSQL_RES Ptr, ByVal As MYSQL_ROW_OFFSET) As MYSQL_ROW_OFFSET
	mysql_field_seek As Function(ByVal Result As MYSQL_RES Ptr, ByVal offset As MYSQL_FIELD_OFFSET) As MYSQL_FIELD_OFFSET
	mysql_fetch_row As Function(ByVal Result As MYSQL_RES Ptr) As MYSQL_ROW
	mysql_fetch_lengths as function(byval result as MYSQL_RES ptr) as culong ptr
	mysql_fetch_field As Function(ByVal Result As MYSQL_RES Ptr) As MYSQL_FIELD Ptr
	mysql_escape_string As Function(ByVal To As ZString Ptr, ByVal from As Const ZString Ptr, ByVal from_length As culong) As culong
	mysql_real_escape_string As Function(ByVal MYSQL As MYSQL Ptr, ByVal To As ZString Ptr, ByVal from As Const ZString Ptr, ByVal length As culong) As culong
	mysql_thread_safe As Function() As ULong
	mysql_warning_count As Function(ByVal MYSQL As MYSQL Ptr) As ULong
	mysql_sqlstate As Function(ByVal MYSQL As MYSQL Ptr) As Const ZString Ptr
	mysql_server_init As Function(ByVal argc As Long, ByVal argv As ZString Ptr Ptr, ByVal groups As ZString Ptr Ptr) As Long
	mysql_server_end As Sub()
	mysql_thread_end As Sub()
	mysql_thread_init As Function() As Byte
	mysql_set_server_option As Function(ByVal MYSQL As MYSQL Ptr, ByVal Option As enum_mysql_set_option) As Long
	mysql_get_client_info As Function() As Const ZString Ptr
	mysql_get_client_version As Function() As culong
	mariadb_connection As Function(ByVal MYSQL As MYSQL Ptr) As Byte
	mysql_get_server_name As Function(ByVal MYSQL As MYSQL Ptr) As Const ZString Ptr
	mariadb_get_charset_by_name As Function(ByVal csname As Const ZString Ptr) As MARIADB_CHARSET_INFO Ptr
	mariadb_get_charset_by_nr As Function(ByVal csnr As ULong) As MARIADB_CHARSET_INFO Ptr
	mariadb_convert_string As Function(ByVal from As Const ZString Ptr, ByVal from_len As UInteger Ptr, ByVal from_cs As MARIADB_CHARSET_INFO Ptr, ByVal To As ZString Ptr, ByVal to_len As UInteger Ptr, ByVal to_cs As MARIADB_CHARSET_INFO Ptr, ByVal errorcode As Long Ptr) As UInteger
	mysql_optionsv As Function cdecl(ByVal MYSQL As MYSQL Ptr, ByVal Option As mysql_option, ...) As Long
	mysql_get_optionv As Function cdecl(ByVal MYSQL As MYSQL Ptr, ByVal Option As mysql_option, ByVal arg As Any Ptr, ...) As Long
	mysql_get_option As Function(ByVal MYSQL As MYSQL Ptr, ByVal Option As mysql_option, ByVal arg As Any Ptr) As Long
	mysql_hex_string As Function(ByVal To As ZString Ptr, ByVal from As Const ZString Ptr, ByVal Len As culong) As culong

	#ifdef __FB_UNIX__
		mysql_get_socket As Function(ByVal MYSQL As MYSQL Ptr) As my_socket
	#elseif defined(__FB_WIN32__) And (Not defined(__FB_64BIT__))
		mysql_get_socket As Function(ByVal MYSQL As MYSQL Ptr) As ULong
	#else
		mysql_get_socket As Function(ByVal MYSQL As MYSQL Ptr) As ULongInt
	#endif

	mysql_get_timeout_value As Function(ByVal MYSQL As Const MYSQL Ptr) As ULong
	mysql_get_timeout_value_ms As Function(ByVal MYSQL As Const MYSQL Ptr) As ULong
	mariadb_reconnect As Function(ByVal MYSQL As MYSQL Ptr) As Byte
	mysql_stmt_init As Function(ByVal MYSQL As MYSQL Ptr) As MYSQL_STMT Ptr
	mysql_stmt_prepare As Function(ByVal stmt As MYSQL_STMT Ptr, ByVal query As Const ZString Ptr, ByVal length As culong) As Long
	mysql_stmt_execute As Function(ByVal stmt As MYSQL_STMT Ptr) As Long
	mysql_stmt_fetch As Function(ByVal stmt As MYSQL_STMT Ptr) As Long
	mysql_stmt_fetch_column As Function(ByVal stmt As MYSQL_STMT Ptr, ByVal bind_arg As MYSQL_BIND Ptr, ByVal column As ULong, ByVal offset As culong) As Long
	mysql_stmt_store_result as function(byval stmt as MYSQL_STMT ptr) as long
	mysql_stmt_param_count As Function(ByVal stmt As MYSQL_STMT Ptr) As culong
	mysql_stmt_attr_set As Function(ByVal stmt As MYSQL_STMT Ptr, ByVal attr_type As enum_stmt_attr_type, ByVal attr As Const Any Ptr) As Byte
	mysql_stmt_attr_get As Function(ByVal stmt As MYSQL_STMT Ptr, ByVal attr_type As enum_stmt_attr_type, ByVal attr As Any Ptr) As Byte
	mysql_stmt_bind_param As Function(ByVal stmt As MYSQL_STMT Ptr, ByVal bnd As MYSQL_BIND Ptr) As Byte
	mysql_stmt_bind_result As Function(ByVal stmt As MYSQL_STMT Ptr, ByVal bnd As MYSQL_BIND Ptr) As Byte
	mysql_stmt_close As Function(ByVal stmt As MYSQL_STMT Ptr) As Byte
	mysql_stmt_reset As Function(ByVal stmt As MYSQL_STMT Ptr) As Byte
	mysql_stmt_free_result As Function(ByVal stmt As MYSQL_STMT Ptr) As Byte
	mysql_stmt_send_long_data As Function(ByVal stmt As MYSQL_STMT Ptr, ByVal param_number As ULong, ByVal Data As Const ZString Ptr, ByVal length As culong) As Byte
	mysql_stmt_result_metadata As Function(ByVal stmt As MYSQL_STMT Ptr) As MYSQL_RES Ptr
	mysql_stmt_param_metadata As Function(ByVal stmt As MYSQL_STMT Ptr) As MYSQL_RES Ptr
	mysql_stmt_errno As Function(ByVal stmt As MYSQL_STMT Ptr) As ULong
	mysql_stmt_error As Function(ByVal stmt As MYSQL_STMT Ptr) As Const ZString Ptr
	mysql_stmt_sqlstate As Function(ByVal stmt As MYSQL_STMT Ptr) As Const ZString Ptr
	mysql_stmt_row_seek As Function(ByVal stmt As MYSQL_STMT Ptr, ByVal offset As MYSQL_ROW_OFFSET) As MYSQL_ROW_OFFSET
	mysql_stmt_row_tell As Function(ByVal stmt As MYSQL_STMT Ptr) As MYSQL_ROW_OFFSET
	mysql_stmt_data_seek As Sub(ByVal stmt As MYSQL_STMT Ptr, ByVal offset As ULongInt)
	mysql_stmt_num_rows As Function(ByVal stmt As MYSQL_STMT Ptr) As ULongInt
	mysql_stmt_affected_rows As Function(ByVal stmt As MYSQL_STMT Ptr) As ULongInt
	mysql_stmt_insert_id As Function(ByVal stmt As MYSQL_STMT Ptr) As ULongInt
	mysql_stmt_field_count As Function(ByVal stmt As MYSQL_STMT Ptr) As ULong
	mysql_stmt_next_result As Function(ByVal stmt As MYSQL_STMT Ptr) As Long
	mysql_stmt_more_results As Function(ByVal stmt As MYSQL_STMT Ptr) As Byte
	mariadb_stmt_execute_direct As Function(ByVal stmt As MYSQL_STMT Ptr, ByVal stmtstr As Const ZString Ptr, ByVal length As UInteger) As Long
	mysql_reset_connection As Function(ByVal MYSQL As MYSQL Ptr) As Long
End Type

Type st_mariadb_methods_
	db_connect As Function cdecl(ByVal MYSQL As MYSQL Ptr, ByVal host As Const ZString Ptr, ByVal user As Const ZString Ptr, ByVal passwd As Const ZString Ptr, ByVal db As Const ZString Ptr, ByVal port As ULong, ByVal unix_socket As Const ZString Ptr, ByVal clientflag As culong) As MYSQL Ptr
	db_close As Sub cdecl(ByVal MYSQL As MYSQL Ptr)
	db_command As Function cdecl(ByVal MYSQL As MYSQL Ptr, ByVal Command As enum_server_command, ByVal arg As Const ZString Ptr, ByVal length As UInteger, ByVal skipp_check As Byte, ByVal opt_arg As Any Ptr) As Long
	db_skip_result As Sub cdecl(ByVal MYSQL As MYSQL Ptr)
	db_read_query_result As Function cdecl(ByVal MYSQL As MYSQL Ptr) As Long
	db_read_rows As Function cdecl(ByVal MYSQL As MYSQL Ptr, ByVal fields As MYSQL_FIELD Ptr, ByVal field_count As ULong) As MYSQL_DATA Ptr
	db_read_one_row As Function cdecl(ByVal MYSQL As MYSQL Ptr, ByVal fields As ULong, ByVal row As MYSQL_ROW, ByVal lengths As culong Ptr) As Long
	db_supported_buffer_type As Function cdecl(ByVal Type As enum_field_types) As Byte
	db_read_prepare_response As Function cdecl(ByVal stmt As MYSQL_STMT Ptr) As Byte
	db_read_stmt_result As Function cdecl(ByVal MYSQL As MYSQL Ptr) As Long
	db_stmt_get_result_metadata As Function cdecl(ByVal stmt As MYSQL_STMT Ptr) As Byte
	db_stmt_get_param_metadata as function cdecl(byval stmt as MYSQL_STMT ptr) as byte
	db_stmt_read_all_rows As Function cdecl(ByVal stmt As MYSQL_STMT Ptr) As Long
	db_stmt_fetch As Function cdecl(ByVal stmt As MYSQL_STMT Ptr, ByVal row As UByte Ptr Ptr) As Long
	db_stmt_fetch_to_bind As Function cdecl(ByVal stmt As MYSQL_STMT Ptr, ByVal row As UByte Ptr) As Long
	db_stmt_flush_unbuffered As Sub cdecl(ByVal stmt As MYSQL_STMT Ptr)
	set_error As Sub cdecl(ByVal MYSQL As MYSQL Ptr, ByVal error_nr As ULong, ByVal sqlstate As Const ZString Ptr, ByVal Format As Const ZString Ptr, ...)
	invalidate_stmts As Sub cdecl(ByVal MYSQL As MYSQL Ptr, ByVal function_name As Const ZString Ptr)
	api As st_mariadb_api Ptr
	db_read_execute_response As Function cdecl(ByVal stmt As MYSQL_STMT Ptr) As Long
	db_execute_generate_request As Function cdecl(ByVal stmt As MYSQL_STMT Ptr, ByVal request_len As UInteger Ptr, ByVal internal As Byte) As UByte Ptr
End Type

#define mysql_reload(MYSQL) mysql_refresh((MYSQL), REFRESH_GRANT)
Declare Function mysql_library_init Alias "mysql_server_init"(ByVal argc As Long, ByVal argv As ZString Ptr Ptr, ByVal groups As ZString Ptr Ptr) As Long
Declare Sub mysql_library_end Alias "mysql_server_end"()
#define mariadb_connect(hdl, conn_str) mysql_real_connect((hdl), (conn_str), NULL, NULL, NULL, 0, NULL, 0)
#define HAVE_MYSQL_REAL_CONNECT

end extern
