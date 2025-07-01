'WMI
' Copyright (c) 2025 CM.Wang
' Freeware. Use at your own risk.

#include once "vbcompat.bi"
#include once "win/wbemcli.bi"

#include once "mff/TextBox.bi"
#include once "mff/ComboBoxEdit.bi"

'Com
Const sCLSID_WbemLocator = "{4590F811-1D3A-11D0-891F-00AA004B2E24}"
Const sIID_IWbemLocator = "{DC12A687-737F-11CF-884D-00AA004B2E24}"

Using My.Sys.Forms

Private Function WStrArrayAdd(pstra() As WString Ptr, addstr As WString) As Integer
	Dim i As Integer = UBound(pstra) + 1
	ReDim Preserve pstra(i)
	WLet(pstra(i), addstr)
	Return i
End Function

Private Function VARIANT2Str(vResult As VARIANT, pType As CIMTYPE, pFlag As Long) As String
	If vResult.vt And CIM_FLAG_ARRAY Then
		Dim As SAFEARRAY Ptr pSafeArray = vResult.parray
		Dim As Long lowerBound, upperBound
		SafeArrayGetLBound(pSafeArray, 1, @lowerBound)
		SafeArrayGetUBound(pSafeArray, 1, @upperBound)
		Dim As WString Ptr wstrrtn()
		ReDim wstrrtn(lowerBound To upperBound)
		
		Dim As Long i
		Select Case vResult.vt And &h1fff
		Case CIM_STRING
			Dim As BSTR bstrName
			For i = lowerBound To upperBound
				SafeArrayGetElement(pSafeArray, @i, @bstrName)
				WLet(wstrrtn(i), *Cast(WString Ptr, bstrName))
				SysFreeString(bstrName)
			Next
		Case CIM_SINT32 ' VT_I4
			Dim As Long longvalue
			For i = lowerBound To upperBound
				SafeArrayGetElement(pSafeArray, @i, @longvalue)
				WLet(wstrrtn(i), Hex(longvalue, 2))
			Next
			'Case VT_BOOL
		Case Else
			Print "CIM_FLAG_ARRAY-" & Hex(vResult.vt)
		End Select
		Dim As WString Ptr rtnwstr
		JoinWStr(wstrrtn(), ", ", rtnwstr)
		Dim As String rtn = *rtnwstr
		ArrayDeallocate(wstrrtn())
		Deallocate(rtnwstr)
		Return  "" & rtn & ", " & lowerBound & ", " & upperBound
	Else
		Select Case vResult.vt And &h1fff
		Case VT_NULL
			Return "(NULL)"
		Case CIM_BOOLEAN
			Return "" & IIf(vResult.boolVal, "True", "False")
		Case CIM_CHAR16
			Return "" & vResult.uiVal
		Case CIM_DATETIME
			Return "" & vResult.date
		Case CIM_EMPTY
			Return "(EMPTY)"
		Case CIM_ILLEGAL
			Return "(ILLEGAL)"
		Case CIM_OBJECT
			Return "(OBJECT)"
		Case CIM_REAL32
			Return "" & vResult.fltVal
		Case CIM_REAL64
			Return "" & vResult.dblVal
		Case CIM_REFERENCE
			Return "" & *vResult.plVal
		Case CIM_SINT16
			Return "" & vResult.iVal
		Case CIM_SINT32
			Return "" & vResult.lVal
		Case CIM_SINT64
			Return "" & vResult.llVal
		Case CIM_SINT8
			Return "" & vResult.llVal
		Case CIM_STRING
			Return "" & *Cast(WString Ptr, vResult.pbstrVal)
		Case CIM_UINT16
			Return "" & vResult.iVal
		Case CIM_UINT32
			Return "" & vResult.ulVal
		Case CIM_UINT64
			Return "" & vResult.ullVal
		Case CIM_UINT8
			Return "" & vResult.bVal
		Case Else
			Return "(Invalid type)"
		End Select
	End If
End Function

Private Function GetIWbemServices(server As WString, ByRef pService As IWbemServices Ptr) As IWbemServices Ptr
	Dim As IWbemLocator Ptr pLocator
	Dim As GUID pCLSID_WbemLocator
	Dim As GUID pIID_IWbemLocator
	
	CLSIDFromString(sCLSID_WbemLocator, @pCLSID_WbemLocator)
	IIDFromString(sIID_IWbemLocator, @pIID_IWbemLocator)
	
	CoCreateInstance(@pCLSID_WbemLocator, NULL, CLSCTX_INPROC_SERVER, @pIID_IWbemLocator, @pLocator)
	If pLocator Then
		pLocator->lpVtbl->ConnectServer(pLocator, @server, NULL, NULL, 0, NULL, 0, 0, @pService)
		If pService Then
			CoSetProxyBlanket(Cast(IUnknown Ptr, pService), RPC_C_AUTHN_WINNT, RPC_C_AUTHZ_NONE, NULL, RPC_C_AUTHN_LEVEL_CALL, RPC_C_IMP_LEVEL_IMPERSONATE, NULL, EOAC_NONE)
		End If
		pLocator->lpVtbl->Release(pLocator)
	End If
	
	Return pService
End Function

Private Function ExecQuery(sql As WString, pService As IWbemServices Ptr, ByRef pEnum As IEnumWbemClassObject Ptr) As IEnumWbemClassObject Ptr
	If pService Then pService->lpVtbl->ExecQuery(pService, @"WQL", @sql, WBEM_FLAG_FORWARD_ONLY Or WBEM_FLAG_RETURN_IMMEDIATELY, NULL, @pEnum)
	Return pEnum
End Function

Private Function EnumNameSpace(server As WString, sql As WString, rtnwstra() As WString Ptr) As Integer
	Dim As IWbemServices Ptr pService
	Dim As IEnumWbemClassObject Ptr pEnum
	Dim As IWbemClassObject Ptr pItem
	Dim As VARIANT vResult
	Dim As Long hr
	
	ArrayDeallocate(rtnwstra())
	
	If GetIWbemServices(server, pService) = NULL Then Return 0
	If ExecQuery(sql, pService, pEnum) = NULL Then Return 0
	
	Dim As ULong uReturn = 0
	Dim cItem As Long = 0
	Do
		hr = pEnum->lpVtbl->Next(pEnum, WBEM_INFINITE, 1, @pItem, @uReturn)
		If uReturn = 0 Then Exit Do
		
		hr = pItem->lpVtbl->Get(pItem, @"Name", 0, @vResult, NULL, NULL)
		If hr <> 0 Then Return 0
		
		cItem += 1
		WStrArrayAdd(rtnwstra(), server & "\" & *Cast(WString Ptr, vResult.pbstrVal))
		If pItem Then pItem->lpVtbl->Release(pItem)
	Loop While True
	
	If pEnum Then pEnum->lpVtbl->Release(pEnum)
	If pService Then pService->lpVtbl->Release(pService)
	Return cItem
End Function

Private Function EnumClasses(wminame As WString, sql As WString, rtnwstra() As WString Ptr) As Integer
	Dim As IWbemServices Ptr pService
	Dim As IEnumWbemClassObject Ptr pEnum
	Dim As IWbemClassObject Ptr pItem
	Dim As VARIANT vResult
	Dim As Long hr
	
	ArrayDeallocate(rtnwstra())
	
	If GetIWbemServices(wminame, pService) = 0 Then Return 0
	If ExecQuery(sql, pService, pEnum) = 0 Then Return 0
	
	Dim As ULong uReturn = 0
	Dim cItem As Long = 0
	Do
		hr = pEnum->lpVtbl->Next(pEnum, WBEM_INFINITE, 1, @pItem, @uReturn)
		If uReturn = 0 Then Exit Do
		
		hr = pItem->lpVtbl->Get(pItem, @"__CLASS", 0, @vResult, NULL, NULL)
		If hr <> 0 Then Return 0
		
		cItem += 1
		WStrArrayAdd(rtnwstra(), *Cast(WString Ptr, vResult.pbstrVal))
		If pItem Then pItem->lpVtbl->Release(pItem)
	Loop While True
	
	If pEnum Then pEnum->lpVtbl->Release(pEnum)
	If pService Then pService->lpVtbl->Release(pService)
	Return cItem
End Function

Private Function EnumPropreties(wminame As WString, classname As WString, rtnwstra() As WString Ptr) As Integer
	Dim As IWbemServices Ptr pService
	Dim As IEnumWbemClassObject Ptr pEnum
	Dim As IWbemClassObject Ptr pItem
	Dim As VARIANT vResult
	Dim As Long hr
	Dim As WString Ptr a
	
	ArrayDeallocate(rtnwstra())
	
	If GetIWbemServices(wminame, pService) = 0 Then Return 0
	
	WLet(a, "SELECT * FROM " & classname)
	hr = pService->lpVtbl->ExecQuery(pService, @"WQL", a, WBEM_FLAG_FORWARD_ONLY Or WBEM_FLAG_RETURN_IMMEDIATELY, NULL, @pEnum)
	If a Then Deallocate(a)
	If hr <> 0 Then Return 0
	
	Dim As ULong uReturn = 0
	hr = pEnum->lpVtbl->Next(pEnum, WBEM_INFINITE, 1, @pItem, @uReturn)
	If uReturn = 0 Then Return 0
	
	Dim As SAFEARRAY Ptr pNames
	hr = pItem->lpVtbl->GetNames(pItem, NULL, WBEM_FLAG_NONSYSTEM_ONLY, NULL, @pNames)
	If hr <> 0 Then Return 0
	
	Dim As Long lLBound, lUBound
	SafeArrayGetLBound(pNames, 1, @lLBound)
	SafeArrayGetUBound(pNames, 1, @lUBound)
	Dim As Long i
	Dim As WString Ptr bstrName
	Dim As Long pFlag
	Dim As CIMTYPE pType
	
	ReDim rtnwstra(lLBound To lUBound)
	For i = lLBound To lUBound
		hr = SafeArrayGetElement(pNames, @i, @bstrName)
		WLet(rtnwstra(i), *bstrName)
		SysFreeString(bstrName)
	Next
	SafeArrayDestroy(pNames)
	If pItem Then pItem->lpVtbl->Release(pItem)
	
	If pEnum Then pEnum->lpVtbl->Release(pEnum)
	If pService Then pService->lpVtbl->Release(pService)
	Return lUBound - lLBound
End Function

Private Function EnumPropretiesValues(wminame As WString, classname As WString, ByRef txt As WString Ptr) As Integer
	Dim As IWbemServices Ptr pService
	Dim As IEnumWbemClassObject Ptr pEnum = NULL
	Dim As IWbemClassObject Ptr pItem = NULL
	Dim As VARIANT vResult
	Dim As Long hr
	
	If GetIWbemServices(wminame, pService) = 0 Then Return 0
	
	Dim As WString Ptr a = NULL
	WLet(a, "SELECT * FROM " & classname)
	hr = pService->lpVtbl->ExecQuery(pService, @"WQL", a, WBEM_FLAG_FORWARD_ONLY Or WBEM_FLAG_RETURN_IMMEDIATELY, NULL, @pEnum)
	Dim As WString Ptr txts()
	Dim As ULong uReturn = 0
	Dim cItem As Long = 0
	If hr <> 0 Or pEnum = NULL Then
	Else
		Do
			hr = pEnum->lpVtbl->Next(pEnum, WBEM_INFINITE, 1, @pItem, @uReturn)
			If uReturn = 0 Or pItem = NULL Then Exit Do
			
			Dim As SAFEARRAY Ptr pNames = NULL
			hr = pItem->lpVtbl->GetNames(pItem, NULL, WBEM_FLAG_NONSYSTEM_ONLY, NULL, @pNames)
			If hr <> 0 Then Exit Do
			
			Dim As Long lLBound, lUBound
			hr = SafeArrayGetLBound(pNames, 1, @lLBound)
			hr = SafeArrayGetUBound(pNames, 1, @lUBound)
			
			Dim As Long i
			Dim As WString Ptr bstrName
			Dim As Long pFlag
			Dim As CIMTYPE pType
			
			cItem += 1
			
			WStrArrayAdd(txts(), cItem & !".\t" & classname)
			For i = lLBound To lUBound
				hr = SafeArrayGetElement(pNames, @i, @bstrName)
				If hr <> 0 Then Exit For
				hr = pItem->lpVtbl->Get(pItem, bstrName, WBEM_FLAG_ALWAYS, @vResult, @pType, @pFlag)
				If hr = 0 Then
					WStrArrayAdd(txts(), !"\t" & i + 1 & !".\t" & *bstrName & " = " & VARIANT2Str(vResult, pType, pFlag)) '& " (0x" & Hex(pType) & ", " & pType & ", 0x" & Hex(vResult.vt) & ")")
				Else
					WStrArrayAdd(txts(), !"\t" & i + 1 & !".\t" & *bstrName & " = Invalid")
				End If
				SysFreeString(bstrName)
			Next
			hr = SafeArrayDestroy(pNames)
			
			If pItem Then pItem->lpVtbl->Release(pItem)
		Loop While True
	End If
	If pEnum Then pEnum->lpVtbl->Release(pEnum)
	If pService Then pService->lpVtbl->Release(pService)
	JoinWStr(txts(), vbCrLf, txt)
	ArrayDeallocate(txts())
	If a Then Deallocate(a)
	Return cItem
End Function
