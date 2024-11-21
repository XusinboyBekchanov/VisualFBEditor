#pragma once

#include once "_mingw.bi"
#include once "winapifamily.bi"
#include once "specstrings.bi"
#include once "winnt.bi"

#if defined(__FB_WIN32__) or defined(__FB_CYGWIN__)
	extern "Windows"
#else
	extern "C"
#endif

#define _MINWINDEF_
const STRICT = 1

#if defined(__FB_DOS__) or defined(__FB_UNIX__)
	#define WIN32
#endif

#define BASETYPES
'' TODO: typedef unsigned __LONG32 ULONG;
type PULONG as ULONG ptr
type USHORT as ushort
type PUSHORT as USHORT ptr
type UCHAR as ubyte
type PUCHAR as UCHAR ptr
type PSZ as zstring ptr

const MAX_PATH = 260
const NULL = cptr(any ptr, 0)
const FALSE = 0
const TRUE = 1
#define IN
#define OUT
#define OPTIONAL

#undef far
#undef near
#undef pascal

#define far
#define near
#define pascal __stdcall
#define cdecl
#define CDECL
#define CALLBACK __stdcall
#define WINAPI __stdcall
#define WINAPIV __cdecl
#define APIENTRY WINAPI
#define APIPRIVATE __stdcall
#define PASCAL __stdcall
#define WINAPI_INLINE WINAPI
#undef FAR
#undef NEAR
#define FAR
#define NEAR
#define _DEF_WINBOOL_
type WINBOOL as long
#undef BOOL

type BOOL as long
type BOOL as WINBOOL
type PBOOL as WINBOOL ptr
type LPBOOL as WINBOOL ptr
type BYTE as ubyte
type WORD as ushort
'' TODO: typedef unsigned __LONG32 DWORD;
type FLOAT as single
type PFLOAT as FLOAT ptr
type PBYTE as BYTE ptr
type LPBYTE as BYTE ptr
type PINT as long ptr
type LPINT as long ptr
type PWORD as WORD ptr
type LPWORD as WORD ptr
type LPLONG as __LONG32 ptr
type PDWORD as DWORD ptr
type LPDWORD as DWORD ptr
type LPVOID as any ptr
#define _LPCVOID_DEFINED
type LPCVOID as const any ptr
type INT as long
type UINT as ulong
type PUINT as ulong ptr
type WPARAM as UINT_PTR
type LPARAM as LONG_PTR
type LRESULT as LONG_PTR

#define max(a, b) iif((a) > (b), (a), (b))
#define min(a, b) iif((a) < (b), (a), (b))
#define MAKEWORD(a, b) cast(WORD, cast(BYTE, DWORD_PTR(a) and &hff) or (cast(WORD, cast(BYTE, DWORD_PTR(b) and &hff)) shl 8))
#define MAKELONG(a, b) LONG(cast(WORD, DWORD_PTR(a) and &hffff) or (DWORD(cast(WORD, DWORD_PTR(b) and &hffff)) shl 16))
#define LOWORD(l) cast(WORD, DWORD_PTR(l) and &hffff)
#define HIWORD(l) cast(WORD, (DWORD_PTR(l) shr 16) and &hffff)
#define LOBYTE(w) cast(BYTE, DWORD_PTR(w) and &hff)
#define HIBYTE(w) cast(BYTE, (DWORD_PTR(w) shr 8) and &hff)

type SPHANDLE as HANDLE ptr
type LPHANDLE as HANDLE ptr
type HGLOBAL as HANDLE
type HLOCAL as HANDLE
type GLOBALHANDLE as HANDLE
type LOCALHANDLE as HANDLE

#if defined(__FB_DOS__) or defined(__FB_DARWIN__) or defined(__FB_LINUX__) or defined(__FB_FREEBSD__) or defined(__FB_OPENBSD__) or defined(__FB_NETBSD__)
	'' TODO: typedef int (__stdcall *FARPROC) ();
	'' TODO: typedef int (__stdcall *NEARPROC) ();
	'' TODO: typedef int (__stdcall *PROC) ();
#elseif (defined(__FB_CYGWIN__) and defined(__FB_64BIT__)) or ((not defined(__FB_64BIT__)) and (defined(__FB_WIN32__) or defined(__FB_CYGWIN__)))
	type FARPROC as function() as long
	type NEARPROC as function() as long
	type PROC as function() as long
#else
	type FARPROC as function() as INT_PTR
	type NEARPROC as function() as INT_PTR
	type PROC as function() as INT_PTR
#endif

type ATOM as WORD
type HFILE as long
extern     HINSTANCE as DECLARE_HANDLE
dim shared HINSTANCE as DECLARE_HANDLE
extern     HKEY as DECLARE_HANDLE
dim shared HKEY as DECLARE_HANDLE
type PHKEY as HKEY ptr
extern     HKL as DECLARE_HANDLE
dim shared HKL as DECLARE_HANDLE
extern     HLSURF as DECLARE_HANDLE
dim shared HLSURF as DECLARE_HANDLE
extern     HMETAFILE as DECLARE_HANDLE
dim shared HMETAFILE as DECLARE_HANDLE
type HMODULE as HINSTANCE
extern     HRGN as DECLARE_HANDLE
dim shared HRGN as DECLARE_HANDLE
extern     HRSRC as DECLARE_HANDLE
dim shared HRSRC as DECLARE_HANDLE
extern     HSPRITE as DECLARE_HANDLE
dim shared HSPRITE as DECLARE_HANDLE
extern     HSTR as DECLARE_HANDLE
dim shared HSTR as DECLARE_HANDLE
extern     HTASK as DECLARE_HANDLE
dim shared HTASK as DECLARE_HANDLE
extern     HWINSTA as DECLARE_HANDLE
dim shared HWINSTA as DECLARE_HANDLE

type _FILETIME
	dwLowDateTime as DWORD
	dwHighDateTime as DWORD
end type

type FILETIME as _FILETIME
type PFILETIME as _FILETIME ptr
type LPFILETIME as _FILETIME ptr
#define _FILETIME_

end extern
