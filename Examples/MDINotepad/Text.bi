#pragma once
' Text 文本处理
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

#include once "vbcompat.bi"
#include once "mff/Application.bi"

Dim Shared fbcVer As String 
fbcVer = "(fbc " & __FB_VER_MAJOR__ & "." & __FB_VER_MINOR__ & "." & __FB_VER_PATCH__ & ")"

Const As Long CodePage_GB2312 = 936 '&h3A8 ANSI/OEM Simplified Chinese (PRC, Singapore); Chinese Simplified (GB2312)
Const As Long CodePage_BIG5 = 950 '&h3B6 ANSI/OEM Traditional Chinese (Taiwan; Hong Kong SAR, PRC); Chinese Traditional (Big5)

#ifndef __USE_MAKE__
	#include once "Text.bas"
#endif
