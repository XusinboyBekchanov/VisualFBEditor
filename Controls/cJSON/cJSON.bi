'   Copyright (c) 2009-2017 Dave Gamble and cJSON contributors

'   Permission is hereby granted, free of charge, to any person obtaining a copy
'   of this software and associated documentation files (the "Software"), to deal
'   in the Software without restriction, including without limitation the rights
'   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
'   copies of the Software, and to permit persons to whom the Software is
'   furnished to do so, subject to the following conditions:

'   The above copyright notice and this permission notice shall be included in
'   all copies or substantial portions of the Software.

'   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
'   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
'   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
'   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
'   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
'   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
'   THE SOFTWARE.

#pragma once

#include once "crt/stddef.bi"

#ifdef __FB_WIN32__
	Extern "Windows"
#else
	Extern "C"
#endif

#define cJSON__h

#ifdef __FB_WIN32__
	#define __WINDOWS__
	#define CJSON_CDECL __cdecl
	#define CJSON_STDCALL __stdcall
	#define CJSON_EXPORT_SYMBOLS
	'' TODO: #define CJSON_PUBLIC(type) __declspec(dllexport) type CJSON_STDCALL
#else
	#define CJSON_CDECL
	#define CJSON_STDCALL
	#define CJSON_PUBLIC(type) type
#endif

Const CJSON_VERSION_MAJOR = 1
Const CJSON_VERSION_MINOR = 7
Const CJSON_VERSION_PATCH = 15
Const cJSON_Invalid = 0
Const cJSON_False = 1 Shl 0
Const cJSON_True = 1 Shl 1
Const cJSON_NULL = 1 Shl 2
Const cJSON_Number = 1 Shl 3
Const cJSON_String = 1 Shl 4
Const cJSON_Array = 1 Shl 5
Const cJSON_Object = 1 Shl 6
Const cJSON_Raw = 1 Shl 7
Const cJSON_IsReference = 256
Const cJSON_StringIsConst = 512

Type cJSON
	next As cJSON Ptr
	prev As cJSON Ptr
	child As cJSON Ptr
	As Long type
	valuestring As ZString Ptr
	valueint As Long
	valuedouble As Double
	string As ZString Ptr
End Type

Type cJSON_Hooks
	malloc_fn As Function cdecl(ByVal sz As UInteger) As Any Ptr
	free_fn As Sub cdecl(ByVal Ptr As Any Ptr)
End Type

Type cJSON_bool As Boolean
Const CJSON_NESTING_LIMIT = 1000
Declare Function cJSON_Version() As Const ZString Ptr
Declare Sub cJSON_InitHooks(ByVal hooks As cJSON_Hooks Ptr)
Declare Function cJSON_Parse(ByVal value As Const ZString Ptr) As cJSON Ptr
Declare Function cJSON_ParseWithLength(ByVal value As Const ZString Ptr, ByVal buffer_length As UInteger) As cJSON Ptr
Declare Function cJSON_ParseWithOpts(ByVal value As Const ZString Ptr, ByVal return_parse_end As Const ZString Ptr Ptr, ByVal require_null_terminated As cJSON_bool) As cJSON Ptr
Declare Function cJSON_ParseWithLengthOpts(ByVal value As Const ZString Ptr, ByVal buffer_length As UInteger, ByVal return_parse_end As Const ZString Ptr Ptr, ByVal require_null_terminated As cJSON_bool) As cJSON Ptr
Declare Function cJSON_Print(ByVal item As Const cJSON Ptr) As ZString Ptr
Declare Function cJSON_PrintUnformatted(ByVal item As Const cJSON Ptr) As ZString Ptr
Declare Function cJSON_PrintBuffered(ByVal item As Const cJSON Ptr, ByVal prebuffer As Long, ByVal fmt As cJSON_bool) As ZString Ptr
Declare Function cJSON_PrintPreallocated(ByVal item As cJSON Ptr, ByVal buffer As ZString Ptr, ByVal length As Const Long, ByVal format As Const cJSON_bool) As cJSON_bool
Declare Sub cJSON_Delete(ByVal item As cJSON Ptr)
Declare Function cJSON_GetArraySize(ByVal array As Const cJSON Ptr) As Long
Declare Function cJSON_GetArrayItem(ByVal array As Const cJSON Ptr, ByVal index As Long) As cJSON Ptr
Declare Function cJSON_GetObjectItem(ByVal object As Const cJSON Const Ptr, ByVal string As Const ZString Const Ptr) As cJSON Ptr
Declare Function cJSON_GetObjectItemCaseSensitive(ByVal object As Const cJSON Const Ptr, ByVal string As Const ZString Const Ptr) As cJSON Ptr
Declare Function cJSON_HasObjectItem(ByVal object As Const cJSON Ptr, ByVal string As Const ZString Ptr) As cJSON_bool
Declare Function cJSON_GetErrorPtr() As Const ZString Ptr
Declare Function cJSON_GetStringValue(ByVal item As Const cJSON Const Ptr) As ZString Ptr
Declare Function cJSON_GetNumberValue(ByVal item As Const cJSON Const Ptr) As Double
Declare Function cJSON_IsInvalid(ByVal item As Const cJSON Const Ptr) As cJSON_bool
Declare Function cJSON_IsFalse(ByVal item As Const cJSON Const Ptr) As cJSON_bool
Declare Function cJSON_IsTrue(ByVal item As Const cJSON Const Ptr) As cJSON_bool
Declare Function cJSON_IsBool(ByVal item As Const cJSON Const Ptr) As cJSON_bool
Declare Function cJSON_IsNull(ByVal item As Const cJSON Const Ptr) As cJSON_bool
Declare Function cJSON_IsNumber(ByVal item As Const cJSON Const Ptr) As cJSON_bool
Declare Function cJSON_IsString(ByVal item As Const cJSON Const Ptr) As cJSON_bool
Declare Function cJSON_IsArray(ByVal item As Const cJSON Const Ptr) As cJSON_bool
Declare Function cJSON_IsObject(ByVal item As Const cJSON Const Ptr) As cJSON_bool
Declare Function cJSON_IsRaw(ByVal item As Const cJSON Const Ptr) As cJSON_bool
Declare Function cJSON_CreateNull() As cJSON Ptr
Declare Function cJSON_CreateTrue() As cJSON Ptr
Declare Function cJSON_CreateFalse() As cJSON Ptr
Declare Function cJSON_CreateBool(ByVal boolean As cJSON_bool) As cJSON Ptr
Declare Function cJSON_CreateNumber(ByVal num As Double) As cJSON Ptr
Declare Function cJSON_CreateString(ByVal string As Const ZString Ptr) As cJSON Ptr
Declare Function cJSON_CreateRaw(ByVal raw As Const ZString Ptr) As cJSON Ptr
Declare Function cJSON_CreateArray() As cJSON Ptr
Declare Function cJSON_CreateObject() As cJSON Ptr
Declare Function cJSON_CreateStringReference(ByVal string As Const ZString Ptr) As cJSON Ptr
Declare Function cJSON_CreateObjectReference(ByVal child As Const cJSON Ptr) As cJSON Ptr
Declare Function cJSON_CreateArrayReference(ByVal child As Const cJSON Ptr) As cJSON Ptr
Declare Function cJSON_CreateIntArray(ByVal numbers As Const Long Ptr, ByVal count As Long) As cJSON Ptr
Declare Function cJSON_CreateFloatArray(ByVal numbers As Const Single Ptr, ByVal count As Long) As cJSON Ptr
Declare Function cJSON_CreateDoubleArray(ByVal numbers As Const Double Ptr, ByVal count As Long) As cJSON Ptr
Declare Function cJSON_CreateStringArray(ByVal strings As Const ZString Const Ptr Ptr, ByVal count As Long) As cJSON Ptr
Declare Function cJSON_AddItemToArray(ByVal array As cJSON Ptr, ByVal item As cJSON Ptr) As cJSON_bool
Declare Function cJSON_AddItemToObject(ByVal object As cJSON Ptr, ByVal string As Const ZString Ptr, ByVal item As cJSON Ptr) As cJSON_bool
Declare Function cJSON_AddItemToObjectCS(ByVal object As cJSON Ptr, ByVal string As Const ZString Ptr, ByVal item As cJSON Ptr) As cJSON_bool
Declare Function cJSON_AddItemReferenceToArray(ByVal array As cJSON Ptr, ByVal item As cJSON Ptr) As cJSON_bool
Declare Function cJSON_AddItemReferenceToObject(ByVal object As cJSON Ptr, ByVal string As Const ZString Ptr, ByVal item As cJSON Ptr) As cJSON_bool
Declare Function cJSON_DetachItemViaPointer(ByVal parent As cJSON Ptr, ByVal item As cJSON Const Ptr) As cJSON Ptr
Declare Function cJSON_DetachItemFromArray(ByVal array As cJSON Ptr, ByVal which As Long) As cJSON Ptr
Declare Sub cJSON_DeleteItemFromArray(ByVal array As cJSON Ptr, ByVal which As Long)
Declare Function cJSON_DetachItemFromObject(ByVal object As cJSON Ptr, ByVal string As Const ZString Ptr) As cJSON Ptr
Declare Function cJSON_DetachItemFromObjectCaseSensitive(ByVal object As cJSON Ptr, ByVal string As Const ZString Ptr) As cJSON Ptr
Declare Sub cJSON_DeleteItemFromObject(ByVal object As cJSON Ptr, ByVal string As Const ZString Ptr)
Declare Sub cJSON_DeleteItemFromObjectCaseSensitive(ByVal object As cJSON Ptr, ByVal string As Const ZString Ptr)
Declare Function cJSON_InsertItemInArray(ByVal array As cJSON Ptr, ByVal which As Long, ByVal newitem As cJSON Ptr) As cJSON_bool
Declare Function cJSON_ReplaceItemViaPointer(ByVal parent As cJSON Const Ptr, ByVal item As cJSON Const Ptr, ByVal replacement As cJSON Ptr) As cJSON_bool
Declare Function cJSON_ReplaceItemInArray(ByVal array As cJSON Ptr, ByVal which As Long, ByVal newitem As cJSON Ptr) As cJSON_bool
Declare Function cJSON_ReplaceItemInObject(ByVal object As cJSON Ptr, ByVal string As Const ZString Ptr, ByVal newitem As cJSON Ptr) As cJSON_bool
Declare Function cJSON_ReplaceItemInObjectCaseSensitive(ByVal object As cJSON Ptr, ByVal string As Const ZString Ptr, ByVal newitem As cJSON Ptr) As cJSON_bool
Declare Function cJSON_Duplicate(ByVal item As Const cJSON Ptr, ByVal recurse As cJSON_bool) As cJSON Ptr
Declare Function cJSON_Compare(ByVal a As Const cJSON Const Ptr, ByVal b As Const cJSON Const Ptr, ByVal case_sensitive As Const cJSON_bool) As cJSON_bool
Declare Sub cJSON_Minify(ByVal json As ZString Ptr)
Declare Function cJSON_AddNullToObject(ByVal object As cJSON Const Ptr, ByVal name As Const ZString Const Ptr) As cJSON Ptr
Declare Function cJSON_AddTrueToObject(ByVal object As cJSON Const Ptr, ByVal name As Const ZString Const Ptr) As cJSON Ptr
Declare Function cJSON_AddFalseToObject(ByVal object As cJSON Const Ptr, ByVal name As Const ZString Const Ptr) As cJSON Ptr
Declare Function cJSON_AddBoolToObject(ByVal object As cJSON Const Ptr, ByVal name As Const ZString Const Ptr, ByVal boolean As Const cJSON_bool) As cJSON Ptr
Declare Function cJSON_AddNumberToObject(ByVal object As cJSON Const Ptr, ByVal name As Const ZString Const Ptr, ByVal number As Const Double) As cJSON Ptr
Declare Function cJSON_AddStringToObject(ByVal object As cJSON Const Ptr, ByVal name As Const ZString Const Ptr, ByVal string As Const ZString Const Ptr) As cJSON Ptr
Declare Function cJSON_AddRawToObject(ByVal object As cJSON Const Ptr, ByVal name As Const ZString Const Ptr, ByVal raw As Const ZString Const Ptr) As cJSON Ptr
Declare Function cJSON_AddObjectToObject(ByVal object As cJSON Const Ptr, ByVal name As Const ZString Const Ptr) As cJSON Ptr
Declare Function cJSON_AddArrayToObject(ByVal object As cJSON Const Ptr, ByVal name As Const ZString Const Ptr) As cJSON Ptr
'' TODO: #define cJSON_SetIntValue(object, number) ((object) ? (object)->valueint = (object)->valuedouble = (number) : (number))
Declare Function cJSON_SetNumberHelper(ByVal object As cJSON Ptr, ByVal number As Double) As Double
#define cJSON_SetNumberValue(object, number) IIf(object <> NULL, cJSON_SetNumberHelper(object, CDbl(number)), (number))
Declare Function cJSON_SetValuestring(ByVal object As cJSON Ptr, ByVal valuestring As Const ZString Ptr) As ZString Ptr
'' TODO: #define cJSON_SetBoolValue(object, boolValue) ( (object != NULL && ((object)->type & (cJSON_False|cJSON_True))) ? (object)->type=((object)->type &(~(cJSON_False|cJSON_True)))|((boolValue)?cJSON_True:cJSON_False) : cJSON_Invalid )
'' TODO: #define cJSON_ArrayForEach(element, array) for(element = (array != NULL) ? (array)->child : NULL; element != NULL; element = element->next)
Declare Function cJSON_malloc(ByVal size As UInteger) As Any Ptr
Declare Sub cJSON_free(ByVal object As Any Ptr)

End Extern

Type JSON_VERSIONPROC As Function cdecl () As ZString Ptr
Type JSON_PARSEPROC As Function cdecl (ByVal value As Const ZString Ptr) As cJSON Ptr
Type JSON_DELETEPROC As Sub cdecl (ByVal item As cJSON Ptr)
Type JSON_GETOBJECTITEMPROC As Function cdecl (ByVal Object As Const cJSON Ptr, ByVal String As Const ZString Ptr) As cJSON Ptr
Type JSON_ISSTRINGPROC As Function cdecl (ByVal item As Const cJSON Ptr) As cJSON_bool
Type JSON_ISNUMBERPROC As Function cdecl (ByVal item As Const cJSON Ptr) As cJSON_bool
Type JSON_ISBOOLPROC As Function cdecl (ByVal item As Const cJSON Ptr) As cJSON_bool
Type JSON_ISTRUEPROC As Function cdecl (ByVal item As Const cJSON Ptr) As cJSON_bool
Type JSON_ISFALSEPROC As Function cdecl (ByVal item As Const cJSON Ptr) As cJSON_bool
Type JSON_GETARRAYSIZEPROC As Function cdecl (ByVal item As Const cJSON Ptr) As Long
Type JSON_GETARRAYITEMPROC As Function cdecl (ByVal array As Const cJSON Ptr, ByVal index As Long) As cJSON Ptr

#ifdef __FB_64BIT__
   #define DECL_CJSON_DLL_NAME        "./cJSON64.dll"
   #define DECL_CJSON_VERSION         "cJSON_Version"
   #define DECL_CJSON_PARSE           "cJSON_Parse"
   #define DECL_CJSON_DELETE          "cJSON_Delete"
   #define DECL_CJSON_ISSTRING        "cJSON_IsString"
   #define DECL_CJSON_ISNUMBER        "cJSON_IsNumber"
   #define DECL_CJSON_ISBOOL          "cJSON_IsBool"
   #define DECL_CJSON_ISTRUE          "cJSON_IsTrue"
   #define DECL_CJSON_ISFALSE         "cJSON_IsFalse"
   #define DECL_CJSON_GETOBJECTITEM   "cJSON_GetObjectItem"
   #define DECL_CJSON_GETARRAYSIZE    "cJSON_GetArraySize"
   #define DECL_CJSON_GETARRAYITEM    "cJSON_GetArrayItem"
#else
   #define DECL_CJSON_DLL_NAME        "./cJSON32.dll"
   #define DECL_CJSON_VERSION         "_cJSON_Version@0"
   #define DECL_CJSON_PARSE           "_cJSON_Parse@4"
   #define DECL_CJSON_DELETE          "_cJSON_Delete@4"
   #define DECL_CJSON_ISSTRING        "_cJSON_IsString@4"
   #define DECL_CJSON_ISNUMBER        "_cJSON_IsNumber@4"
   #define DECL_CJSON_ISBOOL          "_cJSON_IsBool@4"
   #define DECL_CJSON_ISTRUE          "_cJSON_IsTrue@4"
   #define DECL_CJSON_ISFALSE         "_cJSON_IsFalse@4"
   #define DECL_CJSON_GETOBJECTITEM   "_cJSON_GetObjectItem@8"
   #define DECL_CJSON_GETARRAYSIZE    "_cJSON_GetArraySize@4"
   #define DECL_CJSON_GETARRAYITEM    "_cJSON_GetArrayItem@8"
#endif

#include once "mff/Component.bi"

Using My.Sys.ComponentModel

Type CJSON_TYPE Extends Component
   Private:
      _hLib As HMODULE = NULL

   Public:
      Declare Constructor()
      Declare Destructor()
      Declare Property hLib( ByVal libHandle As HMODULE )
      Declare Property hLib() As HMODULE
      Declare Function version() As String
      Declare Function parse(ByVal jsonString As Const ZString Ptr) As cJSON Ptr
      Declare Sub deleteptr(ByVal jsonPtr As cJSON Ptr)
      Declare Function isString(ByVal jsonPtr As Const cJSON Ptr) As Boolean
      Declare Function isNumber(ByVal jsonPtr As Const cJSON Ptr) As Boolean
      Declare Function isBool(ByVal jsonPtr As Const cJSON Ptr) As Boolean
      Declare Function isTrue(ByVal jsonPtr As Const cJSON Ptr) As Boolean
      Declare Function isFalse(ByVal jsonPtr As Const cJSON Ptr) As Boolean
      Declare Function getptr(ByVal jsonPtr As Const cJSON Ptr, ByVal itemKey As Const ZString Ptr) As cJSON Ptr
      Declare Function gettext(ByVal jsonPtr As Const cJSON Ptr, ByVal itemKey As Const ZString Ptr) As String
      Declare Function getnumber(ByVal jsonPtr As Const cJSON Ptr, ByVal itemKey As Const ZString Ptr) As Double
      Declare Function getbool(ByVal jsonPtr As Const cJSON Ptr, ByVal itemKey As Const ZString Ptr) As Boolean
      Declare Function arraycount(ByVal jsonPtr As Const cJSON Ptr) As Long
      Declare Function arrayitem(ByVal jsonPtr As Const cJSON Ptr, ByVal index As Long) As cJSON Ptr
End Type

Constructor CJSON_TYPE
	WLet FClassName, "CJSON_TYPE"
   If _hLib = NULL Then
      _hLib = LoadLibrary(DECL_CJSON_DLL_NAME)
      If _hLib = NULL Then
         ? "Unable to load " & DECL_CJSON_DLL_NAME
      End If
   End If   
End Constructor

Destructor CJSON_TYPE
   If _hLib Then
      FreeLibrary(_hLib)
      _hLib = NULL
   End If   
End Destructor

Property CJSON_TYPE.hLib( ByVal libHandle As HMODULE )
   _hLib = libHandle
End Property

Property CJSON_TYPE.hLib() As HMODULE
   Property = _hLib
End Property

Function CJSON_TYPE.version() As String
   If This.hLib = NULL Then Exit Function
   Dim pProc As JSON_VERSIONPROC = _
   Cast(JSON_VERSIONPROC, GetProcAddress(This.hLib, DECL_CJSON_VERSION))
   If pProc Then
      Dim psz As Const ZString Ptr = pProc()
      If psz Then Function = *psz
   End If
End Function

Function CJSON_TYPE.parse(ByVal jsonString As Const ZString Ptr) As cJSON Ptr
   If This.hLib = NULL Then Exit Function
   Dim pProc As JSON_PARSEPROC = _
   Cast(JSON_PARSEPROC, GetProcAddress(This.hLib, DECL_CJSON_PARSE))
   If pProc Then
      Function = pProc(jsonString)
   End If
End Function

Sub CJSON_TYPE.deleteptr(ByVal jsonPtr As cJSON Ptr)
   If This.hLib = NULL Then Exit Sub
   Dim pProc As JSON_DELETEPROC = _
   Cast(JSON_DELETEPROC, GetProcAddress(This.hLib, DECL_CJSON_DELETE))
   If pProc Then pProc(jsonPtr)
End Sub

Function CJSON_TYPE.isString(ByVal jsonPtr As Const cJSON Ptr) As Boolean
   If This.hLib = NULL Then Exit Function
   Dim pProc As JSON_ISSTRINGPROC = _
   Cast(JSON_ISSTRINGPROC, GetProcAddress(This.hLib, DECL_CJSON_ISSTRING))
   If pProc Then
      Function = CBool(pProc(jsonPtr))
   End If
End Function

Function CJSON_TYPE.isNumber(ByVal jsonPtr As Const cJSON Ptr) As Boolean
   If This.hLib = NULL Then Exit Function
   Dim pProc As JSON_ISNUMBERPROC = _
   Cast(JSON_ISNUMBERPROC, GetProcAddress(This.hLib, DECL_CJSON_ISNUMBER))
   If pProc Then
      Function = CBool(pProc(jsonPtr))
   End If
End Function

Function CJSON_TYPE.isBool(ByVal jsonPtr As Const cJSON Ptr) As Boolean
   If This.hLib = NULL Then Exit Function
   Dim pProc As JSON_ISBOOLPROC = _
   Cast(JSON_ISBOOLPROC, GetProcAddress(This.hLib, DECL_CJSON_ISBOOL))
   If pProc Then
      Function = CBool(pProc(jsonPtr))
   End If
End Function

Function CJSON_TYPE.isTrue(ByVal jsonPtr As Const cJSON Ptr) As Boolean
   If This.hLib = NULL Then Exit Function
   Dim pProc As JSON_ISTRUEPROC = _
   Cast(JSON_ISTRUEPROC, GetProcAddress(This.hLib, DECL_CJSON_ISTRUE))
   If pProc Then
      Function = CBool(pProc(jsonPtr))
   End If
End Function

Function CJSON_TYPE.isFalse(ByVal jsonPtr As Const cJSON Ptr) As Boolean
   If This.hLib = NULL Then Exit Function
   Dim pProc As JSON_ISFALSEPROC = _
   Cast(JSON_ISFALSEPROC, GetProcAddress(This.hLib, DECL_CJSON_ISFALSE))
   If pProc Then
      Function = CBool(pProc(jsonPtr))
   End If
End Function

Function CJSON_TYPE.getptr(ByVal jsonPtr As Const cJSON Ptr, ByVal itemKey As Const ZString Ptr) As cJSON Ptr
   If This.hLib = NULL Then Exit Function
   Dim pProc As JSON_GETOBJECTITEMPROC = _
   Cast(JSON_GETOBJECTITEMPROC, GetProcAddress(This.hLib, DECL_CJSON_GETOBJECTITEM))
   If pProc Then
      Function = pProc(jsonPtr, itemKey)
   End If
End Function

Function CJSON_TYPE.gettext(ByVal jsonPtr As Const cJSON Ptr, ByVal itemKey As Const ZString Ptr) As String
   If This.hLib = NULL Then Exit Function
   Dim As cJSON Ptr jsonPtr2 = This.getptr(jsonPtr, itemKey)
   If jsonPtr2 Then 
      If (This.isString(jsonPtr2) AndAlso (jsonPtr2->valuestring <> NULL)) Then
         Function = *jsonPtr2->valuestring
      End If   
   End If
End Function

Function CJSON_TYPE.getnumber(ByVal jsonPtr As Const cJSON Ptr, ByVal itemKey As Const ZString Ptr) As Double
   If This.hLib = NULL Then Exit Function
   Dim As cJSON Ptr jsonPtr2 = This.getptr(jsonPtr, itemKey)
   If jsonPtr2 Then 
      If (This.isNumber(jsonPtr2)) Then
         Function = jsonPtr2->valuedouble
      End If   
   End If
End Function

Function CJSON_TYPE.getbool(ByVal jsonPtr As Const cJSON Ptr, ByVal itemKey As Const ZString Ptr) As Boolean
   If This.hLib = NULL Then Exit Function
   Dim As cJSON Ptr jsonPtr2 = This.getptr(jsonPtr, itemKey)
   If jsonPtr2 Then 
      If (This.isBool(jsonPtr2)) Then
         Function = CBool(This.isTrue(jsonPtr2))
      End If   
   End If
End Function

Function CJSON_TYPE.arraycount(ByVal jsonPtr As Const cJSON Ptr) As Long
   If This.hLib = NULL Then Exit Function
   Dim pProc As JSON_GETARRAYSIZEPROC = _
   Cast(JSON_GETARRAYSIZEPROC, GetProcAddress(This.hLib, DECL_CJSON_GETARRAYSIZE))
   If pProc Then
      Function = pProc(jsonPtr)
   End If
End Function

Function CJSON_TYPE.arrayitem(ByVal jsonPtr As Const cJSON Ptr, ByVal index As Long) As cJSON Ptr
   If This.hLib = NULL Then Exit Function
   Dim pProc As JSON_GETARRAYITEMPROC = _
   Cast(JSON_GETARRAYITEMPROC, GetProcAddress(This.hLib, DECL_CJSON_GETARRAYITEM))
   If pProc Then
      Function = pProc(jsonPtr, index)
   End If
End Function



