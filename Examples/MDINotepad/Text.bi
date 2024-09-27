#pragma once
' Text 文本处理
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "vbcompat.bi"
#include once "utf_conv.bi"

#define fbcVer "(fbc " & __FB_VER_MAJOR__ & "." & __FB_VER_MINOR__ & "." & __FB_VER_PATCH__ & ")"
#define CodePage_GB2312     936
#define CodePage_BIG5       950 
#define CodePage_UTF8       65001
#define CodePage_UTF16      1200
#define CodePage_UTF16BE    1201
#define CodePage_UTF32      12000
#define CodePage_UTF32BE    12001

#if defined (__FB_WIN32__)
	#define OsEol NewLineTypes.WindowsCRLF
#else
	#if defined (__FB_LINUX__)
		#define OsEol NewLineTypes.LinuxLF
	#else
		#define OsEol NewLineTypes.MacOSCR
	#endif
#endif

' 定义排序类型：升序或降序
Enum SortOrders
	Descending
	Ascending
End Enum

Declare Function TextConvert(ByRef pSource As Const WString, ByRef pConverted As WString Ptr, ByVal CnvCode As DWORD) As Long

#ifndef __USE_MAKE__
	#include once "Text.bas"
#endif
