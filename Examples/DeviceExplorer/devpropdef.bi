﻿#pragma once

#define _DEVPROPDEF_H_
Type DEVPROPTYPE As ULong
Type PDEVPROPTYPE As ULong Ptr
Const DEVPROP_TYPEMOD_ARRAY = &h00001000
Const DEVPROP_TYPEMOD_LIST = &h00002000
Const DEVPROP_TYPE_EMPTY = &h00000000
Const DEVPROP_TYPE_NULL = &h00000001
Const DEVPROP_TYPE_SBYTE = &h00000002
Const DEVPROP_TYPE_BYTE = &h00000003
Const DEVPROP_TYPE_INT16 = &h00000004
Const DEVPROP_TYPE_UINT16 = &h00000005
Const DEVPROP_TYPE_INT32 = &h00000006
Const DEVPROP_TYPE_UINT32 = &h00000007
Const DEVPROP_TYPE_INT64 = &h00000008
Const DEVPROP_TYPE_UINT64 = &h00000009
Const DEVPROP_TYPE_FLOAT = &h0000000A
Const DEVPROP_TYPE_DOUBLE = &h0000000B
Const DEVPROP_TYPE_DECIMAL = &h0000000C
Const DEVPROP_TYPE_GUID = &h0000000D
Const DEVPROP_TYPE_CURRENCY = &h0000000E
Const DEVPROP_TYPE_DATE = &h0000000F
Const DEVPROP_TYPE_FILETIME = &h00000010
Const DEVPROP_TYPE_BOOLEAN = &h00000011
Const DEVPROP_TYPE_STRING = &h00000012
Const DEVPROP_TYPE_STRING_LIST = DEVPROP_TYPE_STRING Or DEVPROP_TYPEMOD_LIST
Const DEVPROP_TYPE_SECURITY_DESCRIPTOR = &h00000013
Const DEVPROP_TYPE_SECURITY_DESCRIPTOR_STRING = &h00000014
Const DEVPROP_TYPE_DEVPROPKEY = &h00000015
Const DEVPROP_TYPE_DEVPROPTYPE = &h00000016
Const DEVPROP_TYPE_BINARY = DEVPROP_TYPE_BYTE Or DEVPROP_TYPEMOD_ARRAY
Const DEVPROP_TYPE_ERROR = &h00000017
Const DEVPROP_TYPE_NTSTATUS = &h00000018
Const DEVPROP_TYPE_STRING_INDIRECT = &h00000019
Const MAX_DEVPROP_TYPE = &h00000019
Const MAX_DEVPROP_TYPEMOD = &h00002000
Const DEVPROP_MASK_TYPE = &h00000FFF
Const DEVPROP_MASK_TYPEMOD = &h0000F000
Type DEVPROP_BOOLEAN As CHAR
Type PDEVPROP_BOOLEAN As CHAR Ptr
Const DEVPROP_TRUE = Cast(DEVPROP_BOOLEAN, -1)
Const DEVPROP_FALSE = Cast(DEVPROP_BOOLEAN, 0)
#define DEVPROPKEY_DEFINED

Type DEVPROPGUID As GUID
Type PDEVPROPGUID As GUID Ptr
Type DEVPROPID As ULong
Type PDEVPROPID As ULong Ptr

Type _DEVPROPKEY
	fmtid As DEVPROPGUID
	pid As DEVPROPID
End Type

Type DEVPROPKEY As _DEVPROPKEY
Type PDEVPROPKEY As _DEVPROPKEY Ptr
Const DEVPROPID_FIRST_USABLE = 2

#define DEFINE_DEVPROPKEY(n, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8, pid) Dim Shared n As DEVPROPKEY = (l, w1, w2, {b1, b2, b3, b4, b5, b6, b7, b8}, pid)
'#define DEFINE_DEVPROPKEY(n, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8, pid) Extern n Alias #n As DEVPROPKEY: Dim n As DEVPROPKEY = (l, w1, w2, {b1, b2, b3, b4, b5, b6, b7, b8}, pid)
'#define DEFINE_DEVPROPKEY(name, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8, pid) EXTERN_C Const DEVPROPKEY name
#define IsEqualDevPropKey(a, b) (((a).pid = (b).pid) AndAlso IsEqualIID(@(a).fmtid, @(b).fmtid))

