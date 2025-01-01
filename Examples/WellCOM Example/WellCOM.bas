'#Compile -dll -export "WellCOM.rc"
#include once "windows.bi"
#include once "win/ocidl.bi"
#include once "win/shlwapi.bi"
#include once "crt.bi"

#define INITGUID

Static Shared OutstandingObjects As DWORD
Static Shared LockCount As DWORD
' Where I store a pointer to my type library's TYPEINFO
Static Shared As ITypeInfo Ptr MyTypeInfo

Dim Shared CLSID_TypeLib As GUID = Type(&h26a8002a, &h83d7, &h45eb, { &h98, &he1, &h9, &hcf, &h47, &ha4, &he, &he3})
Dim Shared CLSID_MyObject As GUID = Type(&hf2e0ac34, &h64ba, &h4871, { &hbb, &hfc, &hb9, &hde, &h5b, &hd9, &hc8, &hb})
Dim Shared IID_MyObject As GUID = Type(&h2a2af189, &hc5a1, &h4a4e, { &h92, &h77, &hb4, &hfd, &h87, &h1a, &h51, &h19})

Const CLSIDS_TypeLib  = "{26A8002A-83D7-45eb-98E1-09CF47A40EE3}"
Const CLSIDS_MyObject = "{F2E0AC34-64BA-4871-BBFC-B9DE5BD9C80B}"
Const IIDS_MyObject   = "{2A2AF189-C5A1-4a4e-9277-B4FD871A5119}"

'==========================================================
'Registry
'==========================================================
Dim Shared DllName As ZString * 128 => "WellCOM.dll"
Dim Shared ObjDescription As ZString * 128 => "Intermediary between DLL host and COM client"
Dim Shared FileDlgTitle As ZString * 128 => "Locate WellCOM.dll to register it"
Dim Shared FileDlgExt As ZString * 128 => "DLL files\000*.dll\000\000"
Dim Shared CLSID_Str As ZString * 128 => "CLSID"
Dim Shared ClassKeyName As ZString * 128 => "Software\\Classes"
Dim Shared InprocServer32Name As ZString * 128 => "InprocServer32"
Dim Shared ThreadingModel As ZString * 128 => "ThreadingModel"
Dim Shared BothStr As ZString * 128 => "both"
Dim Shared ProgID As ZString * 128 => "WellCOM.Object"
Dim Shared TypeLibName As WString * 128 => "WellCOM.dll"

Dim Shared Result As Long, ghDLLInst As HMODULE
Dim Shared FileName As ZString*MAX_PATH
Dim Shared RootKey As HKEY
Dim Shared hKey1 As HKEY
Dim Shared hKey2 As HKEY
Dim Shared hKExtra As HKEY
Dim Shared GUIDtxt As ZString * 39
Dim Shared Disposition As DWORD
Dim Shared sa As SECURITY_ATTRIBUTES

Declare Function SetKeyAndValue(ByRef szKey As String, ByRef szSubKey As String, ByRef szValue As String) As Long

#define W2Ansi(A, W)  WideCharToMultiByte(CP_ACP, 0, W, -1, A, 2047, 0, 0)
#define A2Wide(A, W, L)  MultiByteToWideChar(CP_ACP, 0, A, -1, W, L)

Function UnicodeToAnsi(ByVal szW As OLECHAR Ptr) As String
	Static szA As ZString * 256
	If szW = NULL Then Return ""
	WideCharToMultiByte(CP_ACP, 0, szW, -1, szA, 256, NULL, NULL)
	Return szA
End Function

Function AnsiToUnicode(A As String) As OLECHAR Ptr
	Dim W As OLECHAR Ptr
	Dim Length As Integer
	Length = (2 * Len(A)) + 1
	A2Wide(StrPtr(A), W, Length)
	Return W
End Function

'Convert String to BSTR
'Please follow with SysFreeString(BSTR) after use to avoid memory leak
Function StringToBSTR(cnv_string As String) As BSTR
	Dim sb As BSTR
	Dim As Integer n
	n = (MultiByteToWideChar(CP_ACP, MB_PRECOMPOSED, StrPtr(cnv_string), -1, NULL, 0)) - 1
	sb = SysAllocStringLen(sb, n)
	MultiByteToWideChar(CP_ACP, MB_PRECOMPOSED, StrPtr(cnv_string), -1, sb, n)
	Return sb
End Function

Function s2guid(txt As String) As GUID
	Static oGuid As GUID
	IIDFromString(WStr(txt), @oGuid)
	Return oGuid
End Function

Function guid2s(iguid As GUID) As String
	Dim oGuids As WString Ptr
	StringFromIID(@iguid, Cast(LPOLESTR Ptr, @oGuids))
	Return *oGuids
End Function

Function RegString (hKey As HKEY , RegPath As ZString Ptr, SubKey As ZString Ptr) As String
	Dim Result As ZString * 2048
	Dim As Integer BufferLen = 2048
	If (0 = RegOpenKeyEx(hKey, RegPath, 0, KEY_QUERY_VALUE, @hKey)) Then
		RegQueryValueEx(hKey, SubKey, 0, 0, Cast(LPBYTE, @Result), Cast(LPDWORD, @BufferLen))
	End If
	RegCloseKey(hKey)
	Return Result
End Function

Sub CreateRegString(HK As HKEY, Key As ZString Ptr, VarName As ZString Ptr, Value As ZString Ptr)
	Dim As HKEY HKEY
	Dim Buff As ZString * 100
	Dim As DWORD Result
	RegCreateKeyEx(HK, Key, 0, @Buff, REG_OPTION_NON_VOLATILE, KEY_ALL_ACCESS, 0, @HKEY, @Result)
	RegSetValueEx(HKEY, VarName, 0, REG_SZ, Cast(LPBYTE, Value), Cast(DWORD, lstrlen(Value)) + 1)
	RegCloseKey(HKEY)
End Sub

Sub DeleteRegKey (HK As HKEY, Key As ZString Ptr)
	RegDeleteKey(HK, Key)
End Sub

'==============================
'IObject function
'==============================
Type IObjectVTbl_ As IObjectVTbl
Type IObject
	lpVTbl As IObjectVTbl_ Ptr
End Type

Type IObjectVTbl
	' Functions for Unknown Interface
	QueryInterface As Function(ByVal pthis As IObject Ptr, ByVal vTableGuid As GUID Ptr, ByVal ppv As LPVOID Ptr) As HRESULT
	AddRef As Function(ByVal pthis As IObject Ptr) As HRESULT
	Release As Function(ByVal pthis As IObject Ptr) As HRESULT
	' IDispatch functions
	GetTypeInfoCount As Function(ByVal pthis As IObject Ptr, pCount As UINT Ptr) As HRESULT
	GetTypeInfo  As Function(ByVal pthis As IObject Ptr, itinfo As UINT, lcid As LCID, pTypeInfo As ITypeInfo Ptr Ptr) As HRESULT
	GetIDsOfNames  As Function(ByVal pthis As IObject Ptr, riid As REFIID, rgszNames As LPOLESTR Ptr, cNames As UINT, lcid As LCID, rgdispid As DISPID Ptr) As HRESULT
	Invoke  As Function(ByVal pthis As IObject Ptr, dispid As DISPID, riid As REFIID, lcid As  LCID, wFlags As WORD, params As DISPPARAMS Ptr, result As VARIANT Ptr, pexcepinfo As EXCEPINFO Ptr, puArgErr As UINT Ptr) As HRESULT
	' Our functions
	SetString As Function(ByVal pthis As IObject Ptr, ByVal  lpstr As BSTR) As HRESULT
	GetString As Function(ByVal pthis As IObject Ptr, ByVal buffer As BSTR Ptr) As HRESULT
End Type

Type LPOBJECT As OBJ_OBJECT Ptr

Type OBJECT_ClassFactory
	icf As IClassFactory
	cRef As Integer
End Type

Type OBJ_OBJECT
	Ib As IObject
	count As Integer
	tex As BSTR
End Type

Type CLASS_OBJECT
	Ib As IObject
	count As Integer
	tex As BSTR
End Type

Function IObject_AddRef(ByVal pthis As IObject Ptr) As HRESULT
	Cast(LPOBJECT, pthis)->count += 1
	Function = Cast(LPOBJECT, pthis)->count
End Function

Function IObject_QueryInterface(ByVal pthis As IObject Ptr, ByVal riid As GUID Ptr, _
	ByVal ppv As LPVOID Ptr) As HRESULT
	If IsEqualIID(riid, @IID_IUnknown) Or IsEqualIID(riid, @IID_MyObject) Then
		*ppv = @Cast(LPOBJECT, pthis)->Ib
		Function = S_OK
	ElseIf IsEqualIID(riid, @IID_IDispatch) Then
		*ppv = pthis
		Function = S_OK
	Else
		*ppv = 0
		Function = E_NOINTERFACE: Exit Function
	End If
	pthis->lpVTbl->AddRef(pthis)
	Function = NOERROR
End Function

Function IObject_Release(ByVal pthis As IObject Ptr) As HRESULT
	Cast(LPOBJECT, pthis)->count -= 1
	
	If Cast(LPOBJECT, pthis)->tex Then SysFreeString(Cast(LPOBJECT, pthis)->tex) 'win32api
	
	If Cast(LPOBJECT, pthis)->count <= 0 Then
		InterlockedDecrement(@OutstandingObjects) 'win32api
		free(pthis) 'win32api
		Function = 0: Exit Function
	End If
	Function = Cast(LPOBJECT, pthis)->count
End Function

' ================== The standard IDispatch functions

' This is just a helper function for the IDispatch functions below
Function LoadMyTypeInfo() As HRESULT
	
	Dim As HRESULT   hr
	Dim As LPTYPELIB pTypeLib
	
	' Load our type library and get a ptr to its TYPELIB. Note: This does an
	' implicit pTypeLib->lpVtbl->AddRef(pTypeLib)
	Dim TypeLibraryFullFilePath As WString * (MAX_PATH + 1) = Any
	
	TypeLibraryFullFilePath = RegString(HKEY_CLASSES_ROOT, "CLSID\" & CLSIDS_MyObject & "\InprocServer32", NULL)
	
	hr = LoadTypeLib(@TypeLibraryFullFilePath, @pTypeLib)
	'hr = LoadRegTypeLib(@CLSID_TypeLib, 1, 0, 409, @pTypeLib)
	
	If  hr = 0 Then
		
		' Get Microsoft's generic ITypeInfo, giving it our loaded type library. We only
		' need one of these, and we'll store it in a global Tell Microsoft this is for
		' our IExample2's VTable, by passing that VTable's GUID
		
		hr = pTypeLib->lpVtbl->GetTypeInfoOfGuid(pTypeLib, @IID_MyObject, @MyTypeInfo)
		If hr = 0 Then
			
			' We no longer need the ptr to the TYPELIB now that we've given it
			' to Microsoft's generic ITypeInfo. Note: The generic ITypeInfo has done
			' a pTypeLib->lpVtbl->AddRef(pTypeLib), so this TYPELIB ain't going away
			' until the generic ITypeInfo does a pTypeLib->lpVtbl->Release too
			pTypeLib->lpVtbl->Release(pTypeLib)
			
			' Since caller wants us to return our ITypeInfo pointer,
			' we need to increment its reference count. Caller is
			' expected to Release() it when done
			MyTypeInfo->lpVtbl->AddRef(MyTypeInfo)
		End If
	End If
	
	Return(hr)
End Function

Function IObject_GetTypeInfoCount(ByVal pthis As IObject Ptr, pCount As UINT Ptr) As HRESULT
	*pCount = 1
	Return(S_OK)
End Function

Function IObject_GetTypeInfo(ByVal pthis As IObject Ptr, itinfo As UINT, lcid As LCID, pTypeInfo As ITypeInfo Ptr Ptr) As HRESULT
	Static As HRESULT   hr
	
	' Assume an error
	*pTypeInfo = 0
	
	If (itinfo)Then
		hr = ResultFromScode(DISP_E_BADINDEX)
		
		' If our ITypeInfo is already created, just increment its ref count. NOTE: We really should
		' store the LCID of the currently created TYPEINFO and compare it to what the caller wants.
		' If no match, unloaded the currently created TYPEINFO, and create the correct one. But since
		' we support only one language in our IDL file anyway, we'll ignore this
	ElseIf (MyTypeInfo)Then
		
		MyTypeInfo->lpVtbl->AddRef(MyTypeInfo)
		hr = 0
		
	Else
		
		' Load our type library and get Microsoft's generic ITypeInfo object. NOTE: We really
		' should pass the LCID to match, but since we support only one language in our IDL
		' file anyway, we'll ignore this
		hr = LoadMyTypeInfo()
	End If
	
	If (0 = hr) Then *pTypeInfo = MyTypeInfo
	
	Return(hr)
End Function

' IExample2's GetIDsOfNames()
Function IObject_GetIDsOfNames(ByVal pthis As IObject Ptr, riid As REFIID, rgszNames As LPOLESTR Ptr, cNames As UINT, lcid As LCID, rgdispid As DISPID Ptr) As HRESULT
	
	If (0 = MyTypeInfo) Then
		Dim As HRESULT   hr
		LoadMyTypeInfo()
		'If ((hr = loadMyTypeInfo())) Then Return(hr)
	End If
	
	' Let OLE32.DLL's DispGetIDsOfNames() do all the real work of using our type
	' library to look up the DISPID of the requested function in our object
	Return(DispGetIDsOfNames(MyTypeInfo, rgszNames, cNames, rgdispid))
End Function

Function IObject_Invoke(ByVal pthis As IObject Ptr, dispid As DISPID, riid As REFIID, lcid As LCID, wFlags As WORD, params As DISPPARAMS Ptr, result As VARIANT Ptr, pexcepinfo As EXCEPINFO Ptr, puArgErr As UINT Ptr) As HRESULT
	
	' We implement only a "default" interface
	If (0 = IsEqualIID(riid, @IID_NULL)) Then Return(DISP_E_UNKNOWNINTERFACE)
	
	' We need our type lib's TYPEINFO (to pass to DispInvoke)
	If (0 = MyTypeInfo) Then
		
		Dim As HRESULT hr
		
		If ((hr = LoadMyTypeInfo())) Then Return(hr)
	End If
	
	' Let OLE32.DLL's DispInvoke() do all the real work of calling the appropriate
	' function in our object, and massaging the passed args into the correct format
	Dim As HRESULT hr = S_OK
	hr = (DispInvoke(pthis, MyTypeInfo, dispid, wFlags, params, result, pexcepinfo, puArgErr))
	Return hr
	'	Dim As IDispatch Ptr pDisp = NULL
	'    Dim As HRESULT    hr = S_OK
	'    hr = m_pOuterUnknown->QueryInterface( IID_IDispatch, (void * * ) @pDisp )
	'    If ( SUCCEEDED(hr) ) Then
	'        hr = pDisp->Invoke( dispidMember, riid, lcid, wFlags, pdispparams, pvarResult, pexcepinfo, puArgErr)
	'        pDisp->Release()
	'    End If
	'
	'    Return hr
End Function


Function IObject_SetString(ByVal pthis As IObject Ptr, ByVal lpstr As BSTR) As HRESULT
	If Cast(LPOBJECT, pthis)->tex Then SysFreeString(Cast(LPOBJECT, pthis)->tex)
	Cast(LPOBJECT, pthis)->tex = SysAllocString(lpstr) ' store a copy of the string
	If Cast(LPOBJECT, pthis)->tex = 0 Then Return E_OUTOFMEMORY Else Return NOERROR
End Function

Function IObject_GetString(ByVal pthis As IObject Ptr, ByVal buffer As BSTR Ptr) As HRESULT
	'If buffer=0 Then Return E_POINTER
	*buffer = SysAllocString(Cast(LPOBJECT, pthis)->tex)
	If *buffer = 0 Then Return E_OUTOFMEMORY Else Return NOERROR
End Function

Static Shared MyObjectVTbl As IObjectVTbl = (@IObject_QueryInterface, _
@IObject_AddRef, _
@IObject_Release, _
@IObject_GetTypeInfoCount, _
@IObject_GetTypeInfo, _
@IObject_GetIDsOfNames, _
@IObject_Invoke, _
@IObject_SetString, _
@IObject_GetString)

'===============================
' Class Factory Functions
'===============================
Static Shared MyClassFactory As IClassFactory

Function ClassAddRef(ByVal pcF As IClassFactory Ptr) As ULong
	InterlockedIncrement(@OutstandingObjects)
	Function=1
End Function

Function ClassQueryInterface (pcF As IClassFactory Ptr, riid As REFIID, ByVal ppv As PVOID Ptr) As Long
	
	If (IsEqualIID( riid, @IID_IUnknown) Or IsEqualIID( riid, @IID_IClassFactory)) Then
		*ppv = Cast(OBJECT_ClassFactory Ptr, pcF)
		Cast(OBJECT_ClassFactory Ptr, pcF)->icf.lpVtbl->AddRef(pcF)
		
		Return S_OK
	End If
	*ppv = 0
	Return  E_NOINTERFACE
	
	'Cast(LPUNKNOWN,*ppv)->lpvtbl->AddRef(Cast(LPUNKNOWN,*ppv))
	'Return NOERROR
End Function

Function ClassRelease(pcF As IClassFactory Ptr) As ULong
	Dim pthis As OBJECT_ClassFactory Ptr = Cast(OBJECT_ClassFactory Ptr, pcF)
	Dim pcc As CLASS_OBJECT Ptr
	pthis->cRef -= 1
	If pthis->cRef = 0 Then
		free(pthis)
		Return 0
	End If
	Return pthis->cRef
	'Return  InterlockedDecRement(@OutstandingObjects)
End Function

Function ClassCreateInstance(pcF As IClassFactory Ptr, punkOuter As LPUNKNOWN, ByVal vTableGuid As REFIID, ByVal objHandle As PVOID Ptr) As HRESULT
	Dim hr As HRESULT
	Dim pthis As OBJECT_ClassFactory Ptr = Cast(OBJECT_ClassFactory Ptr, pcF)
	Dim thisobj As CLASS_OBJECT Ptr
	*objHandle = 0
	If punkOuter Then
		Return CLASS_E_NOAGGREGATION
	Else
		thisobj = Cast(CLASS_OBJECT Ptr, malloc(SizeOf(CLASS_OBJECT)))
		If thisobj = 0 Then
			Return E_OUTOFMEMORY
		Else
			'intialise object properties
			thisobj->Ib.lpVTbl = @MyObjectVTbl
			thisobj->count = 1
			thisobj->tex = 0
			If S_OK <> thisobj->Ib.lpVTbl->QueryInterface(@(thisobj->Ib), Cast(GUID Ptr, vTableGuid), objHandle) Then
				free(thisobj)
				Return E_NOINTERFACE
			End If
			thisobj->Ib.lpVTbl->Release(@(thisobj->Ib))
			OutstandingObjects += 1
			'If hr = 0 Then InterlockedIncRement(@OutstandingObjects)
		End If
	End If
	Return S_OK
End Function

Function ClassLockServer(pcF As IClassFactory Ptr, flock As BOOL) As HRESULT
	If flock Then
		OutstandingObjects += 1
		'InterlockedIncRement(@LockCount)
	Else
		OutstandingObjects -= 1
		'InterlockedDecRement(@LockCount)
	End If
	Return  NOERROR
End Function

Static Shared  As IClassFactoryVtbl MyClassFactoryVTbl = (@ClassQueryInterface, @ClassAddRef, @ClassRelease, @ClassCreateInstance, @ClassLockServer)

'============================================
'dll function
'============================================
'Dim shared MyTypeInfo As ITypeInfo PTR

Extern "windows-ms"
	
	#undef DllGetClassObject
	Function DllGetClassObject  Alias "DllGetClassObject" (objGuid As GUID Ptr, factoryGuid As GUID Ptr, ByVal factoryHandle As LPVOID Ptr) As HRESULT Export
		Static pcF As OBJECT_ClassFactory Ptr = NULL
		
		*factoryHandle = 0
		If IsEqualCLSID(@CLSID_MyObject, objGuid) Then
			If pcF = NULL Then
				pcF = malloc(SizeOf(pcF))
				If pcF = NULL Then
					Return E_OUTOFMEMORY
				End If
			End If
			pcF->icf.lpVtbl = @MyClassFactoryVTbl
			pcF->cRef = 0
			Return ClassQueryInterface(Cast(IClassFactory Ptr, pcF), factoryGuid, factoryHandle)
			
		End If
		
		*factoryHandle = 0
		Return  CLASS_E_CLASSNOTAVAILABLE
		
	End Function
	
	#undef DllCanUnloadNow
	Function DllCanUnloadNow Alias "DllCanUnloadNow" () As HRESULT Export
		Return  IIf(OutstandingObjects Or LockCount, S_FALSE, S_OK)
	End Function
	
	Function DllMain(ByVal hModule As HMODULE, ByVal ul_reason_for_call As DWORD, ByVal lpReserved As LPVOID) As Boolean
		Select Case ul_reason_for_call
		Case DLL_PROCESS_ATTACH
		Case DLL_THREAD_ATTACH
		Case DLL_THREAD_DETACH
		Case DLL_PROCESS_DETACH
		End Select
		Return True
	End Function
	
	#undef DllRegisterServer
	Function DllRegisterServer Alias "DllRegisterServer" () As HRESULT Export
		Dim lv_temp_str As ZString * 2048
		Dim lv_varstr As ZString * 2048
		
		CreateRegString(HKEY_CLASSES_ROOT, ProgID, NULL, ProgID)
		CreateRegString(HKEY_CLASSES_ROOT, ProgID & "\CLSID", NULL, CLSIDS_MyObject)
		' prepare entery for HKEY_CLASSES_ROOT
		lv_varstr = ProgID
		lv_temp_str = "CLSID\" & CLSIDS_MyObject
		CreateRegString(HKEY_CLASSES_ROOT, lv_temp_str, NULL, lv_varstr)
		CreateRegString(HKEY_CLASSES_ROOT, lv_temp_str, "AppID", CLSIDS_MyObject) ' aa
		' define localtion of dll in system32
		lv_temp_str = "CLSID\" & CLSIDS_MyObject & "\InprocServer32"
		
		lv_varstr = SPACE$(1024)
		GetModuleFileName(GetModuleHandle("WellCOM.dll"), lv_varstr, Len(lv_varstr))
		
		lv_varstr = TRIM$(lv_varstr)
		CreateRegString(HKEY_CLASSES_ROOT, lv_temp_str, NULL, lv_varstr)
		
		lv_temp_str = TRIM$(RegString(HKEY_CLASSES_ROOT, lv_temp_str, NULL))
		
		If lv_temp_str <> lv_varstr Then ' VERIFY THAT CORRECT VALUE IS WRITTEN IN REGISTRY
			Return S_FALSE
		End If
		
		lv_temp_str = "CLSID\" & CLSIDS_MyObject & "\ProgID"
		CreateRegString(HKEY_CLASSES_ROOT, lv_temp_str, NULL, ProgID)
		
		CreateRegString(HKEY_CLASSES_ROOT, "TypeLib\", NULL, CLSIDS_TypeLib)
		CreateRegString(HKEY_CLASSES_ROOT, "TypeLib\" & CLSIDS_TypeLib & "\2.0" , NULL, "WellCOM 2.0 type library")
		CreateRegString(HKEY_CLASSES_ROOT, "TypeLib\" & CLSIDS_TypeLib & "\2.0\HELPDIR" , NULL, lv_varstr)
		CreateRegString(HKEY_CLASSES_ROOT, "TypeLib\" & CLSIDS_TypeLib & "\2.0\409\win32" , NULL, "wellcom.tlb")
		Return S_OK
	End Function
	
	#undef DllUnregisterServer
	Function DllUnregisterServer Alias "DllUnregisterServer" () As HRESULT  Export
		Dim lv_temp_str As ZString * 2048
		
		DeleteRegKey(HKEY_CLASSES_ROOT, ProgID & "\CLSID")
		DeleteRegKey(HKEY_CLASSES_ROOT, "\" & ProgID)
		
		lv_temp_str  = "CLSID\" & CLSIDS_MyObject & "\InprocServer32"
		DeleteRegKey (HKEY_CLASSES_ROOT, lv_temp_str)
		
		lv_temp_str = "CLSID\" & CLSIDS_MyObject & "\ProgID"
		DeleteRegKey (HKEY_CLASSES_ROOT, lv_temp_str)
		
		lv_temp_str = "CLSID\" & CLSIDS_MyObject
		DeleteRegKey (HKEY_CLASSES_ROOT, lv_temp_str)
		
		lv_temp_str ="TypeLib\" & CLSIDS_TypeLib
		DeleteRegKey (HKEY_CLASSES_ROOT, lv_temp_str)
		
		Function = S_OK
	End Function
	
End Extern
