#pragma once
' FileAct 文件处理
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "windows.bi"
#include once "Text.bi"
#include once "TimeMeter.bi"
#include once "win/shlwapi.bi"
#include once "win/bcrypt.bi"
#include once "win/wincrypt.bi"
#inclib "bcrypt"
#inclib "crypt32"

' https://www.freebasic.net/forum/viewtopic.php?t=29685
' https://en.wikipedia.org/wiki/SHA-1
' https://www.freebasic.net/forum/viewtopic.php?t=31389
' https://www.freebasic.net/forum/viewtopic.php?t=25849
' "The quick brown fox jumps over the lazy dog"
' MD5    = "9e107d9d372bb6826bd81d3542a419d6"
' SHA1   = "2fd4e1c67a2d28fced849ee1bb76e7391b93eb12"
' SHA256 = "d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592"
' SHA512 = "07e547d9586f6a73f73fbac0435ed76951218fb7d0c8d788a309d785436bbb642e93a252a954f23912547d1e8a3b5ed6e1bfd7097821233fa0538f3db854fee6"

'Hash算法
Enum HashAlgorithms
	MD2 = 0
	MD4
	MD5
	SHA1
	SHA256
	SHA512
End Enum

#ifndef __USE_MAKE__
	#include once "FileAct.bas"
#endif
