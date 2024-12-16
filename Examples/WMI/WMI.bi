'WMI
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "vbcompat.bi"
#include once "win/wbemcli.bi"

#include once "mff/TextBox.bi"
#include once "mff/ComboBoxEdit.bi"

'Com
Const sCLSID_WbemLocator = "{4590F811-1D3A-11D0-891F-00AA004B2E24}"
Const sIID_IWbemLocator = "{DC12A687-737F-11CF-884D-00AA004B2E24}"

Using My.Sys.Forms

Private Function WStrArrayRelease(pstra() As WString Ptr) As Integer
	Dim l As Integer = LBound(pstra)
	Dim u As Integer = UBound(pstra)
	Dim i As Integer
	
	For i = l To u
		If pstra(i) Then Deallocate(pstra(i))
	Next
	Erase pstra
	Return 0
End Function

Private Function WStrArrayAdd(pstra() As WString Ptr, addstr As WString) As Integer
	Dim i As Integer = UBound(pstra) + 1
	ReDim Preserve pstra(i)
	WLet(pstra(i), addstr)
	Return i
End Function

Private Function VARIANT2Str(vResult As VARIANT, pType As CIMTYPE, pFlag As Long) As String
	Select Case pType
	Case CIM_BOOLEAN
		Return " = " & IIf(vResult.boolVal, "True", "False")
	Case CIM_CHAR16
		Return " = " & vResult.uiVal
	Case CIM_DATETIME
		Return " = " & vResult.date
	Case CIM_EMPTY
		Return " = Null"
	Case CIM_FLAG_ARRAY
		Return " = CIM_FLAG_ARRAY: (complex type)"
		
		'If vResult.vt = (VT_ARRAY Or VT_BOOL) Then
		'	Dim As SAFEARRAY Ptr pSafeArray = vResult.parray
		'	Dim As Long lowerBound, upperBound
		'	
		'	SafeArrayGetLBound(pSafeArray, 1, @lowerBound)
		'	SafeArrayGetUBound(pSafeArray, 1, @upperBound)
		'	Dim As Long i
		'	For i = lowerBound To upperBound
		'		Dim As VARIANT element
		'		VariantInit(@element)
		'		SafeArrayGetElement(pSafeArray, @i, @element)
		'		If element.boolVal Then Print "True" Else Print "False"
		'		VariantClear(@element)
		'	Next
		'End If
	Case CIM_ILLEGAL
		Return " = (Undefined type)"
	Case CIM_OBJECT
		Return " = CIM_OBJECT: (complex type)"
	Case CIM_REAL32
		Return " = " & vResult.fltVal
	Case CIM_REAL64
		Return " = " & vResult.dblVal
	Case CIM_REFERENCE
		Return " = " & *vResult.plVal
	Case CIM_SINT16
		Return " = " & vResult.iVal
	Case CIM_SINT32
		Return " = " & vResult.lVal
	Case CIM_SINT64
		Return " = " & vResult.llVal
	Case CIM_SINT8
		Return " = " & vResult.llVal
	Case CIM_STRING
		Return " = " & *Cast(WString Ptr, vResult.pbstrVal)
	Case CIM_UINT16
		Return " = " & vResult.iVal
	Case CIM_UINT32
		Return " = " & vResult.ulVal
	Case CIM_UINT64
		Return " = " & vResult.ullVal
	Case CIM_UINT8
		Return " = " & vResult.bVal
	Case Else
		Return " = (Invalid type)"
	End Select
End Function

Private Function GetIWbemServices(server As WString, ByRef pService As IWbemServices Ptr) As Integer
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

Private Function ExecQuery(sql As WString, pService As IWbemServices Ptr, ByRef pEnum As IEnumWbemClassObject Ptr) As Integer
	If pService Then pService->lpVtbl->ExecQuery(pService, @"WQL", @sql, WBEM_FLAG_FORWARD_ONLY Or WBEM_FLAG_RETURN_IMMEDIATELY, NULL, @pEnum)
	Return pEnum
End Function

Private Function EnumNameSpace(server As WString, sql As WString, rtnwstra() As WString Ptr) As Integer
	Dim As IWbemServices Ptr pService
	Dim As IEnumWbemClassObject Ptr pEnum
	Dim As IWbemClassObject Ptr pItem
	Dim As VARIANT vResult
	Dim As Long hr
	
	WStrArrayRelease(rtnwstra())
	
	If GetIWbemServices(server, pService) = 0 Then Return 0
	If ExecQuery(sql, pService, pEnum) = 0 Then Return 0
	
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
	
	WStrArrayRelease(rtnwstra())
	
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
	
	WStrArrayRelease(rtnwstra())
	
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
	Dim As BSTR bstrName
	Dim As Long pFlag
	Dim As CIMTYPE pType
	
	ReDim rtnwstra(lLBound To lUBound)
	For i = lLBound To lUBound
		hr = SafeArrayGetElement(pNames, @i, @bstrName)
		If hr <> 0 Then Exit For
		
		WLet(rtnwstra(i), *Cast(WString Ptr, bstrName))
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
	Dim As IEnumWbemClassObject Ptr pEnum
	Dim As IWbemClassObject Ptr pItem
	Dim As VARIANT vResult
	Dim As Long hr
	Dim As WString Ptr a
	
	If GetIWbemServices(wminame, pService) = 0 Then Return 0
	
	WLet(a, "SELECT * FROM " & classname)
	hr = pService->lpVtbl->ExecQuery(pService, @"WQL", a, WBEM_FLAG_FORWARD_ONLY Or WBEM_FLAG_RETURN_IMMEDIATELY, NULL, @pEnum)
	If a Then Deallocate(a)
	If hr <> 0 Then Return 0
	
	Dim As WString Ptr txts()
	Dim As ULong uReturn = 0
	Dim cItem As Long = 0
	Do
		hr = pEnum->lpVtbl->Next(pEnum, WBEM_INFINITE, 1, @pItem, @uReturn)
		If uReturn = 0 Then Exit Do
		
		Dim As SAFEARRAY Ptr pNames
		hr = pItem->lpVtbl->GetNames(pItem, NULL, WBEM_FLAG_NONSYSTEM_ONLY, NULL, @pNames)
		If hr <> 0 Then Exit Do
		
		Dim As Long lLBound, lUBound
		SafeArrayGetLBound(pNames, 1, @lLBound)
		SafeArrayGetUBound(pNames, 1, @lUBound)
		Dim As Long i
		Dim As BSTR bstrName
		Dim As Long pFlag
		Dim As CIMTYPE pType
		
		cItem += 1
		WStrArrayAdd(txts(), cItem & ". " & classname)
		For i = lLBound To lUBound
			hr = SafeArrayGetElement(pNames, @i, @bstrName)
			If hr = 0 Then
				WLet(a, *Cast(WString Ptr, bstrName))
				hr = pItem->lpVtbl->Get(pItem, a, WBEM_FLAG_ALWAYS, @vResult, @pType, @pFlag)
				If hr = 0 Then
					WStrArrayAdd(txts(), !"\t" & i + 1 & !".\t" & *a & VARIANT2Str(vResult, pType, pFlag))
				Else
					WStrArrayAdd(txts(), !"\t" & i + 1 & !".\t" & *a & !"\tinvalid")
				End If
				SysFreeString(bstrName)
			End If
		Next
		SafeArrayDestroy(pNames)
		If pItem Then pItem->lpVtbl->Release(pItem)
	Loop While True
	
	If pEnum Then pEnum->lpVtbl->Release(pEnum)
	If pService Then pService->lpVtbl->Release(pService)
	WLet(txt, Join(txts(), vbCrLf))
	WStrArrayRelease(txts())
	Return cItem
End Function

'
'' 声明需要使用的COM接口
'Dim As IWbemLocator Ptr pLocator
'Dim As IWbemServices Ptr pService
'Dim As IEnumWbemClassObject Ptr pEnum
'Dim As IWbemClassObject Ptr pItem
'Dim As VARIANT vResult
'Dim As Long hr
'
'Dim As GUID pCLSID_WbemLocator
'Dim As GUID pIID_IWbemLocator
'
'CLSIDFromString(sCLSID_WbemLocator, @pCLSID_WbemLocator)
'IIDFromString(sIID_IWbemLocator, @pIID_IWbemLocator)
'
'TextBox2.Clear
''初始化 COM
'hr = CoInitialize(NULL)
'TextBox2.AddLine("0. 初始化 COM:           " & hr)
'
'' 创建WMI定位器对象
'hr = CoCreateInstance(@pCLSID_WbemLocator, NULL, CLSCTX_INPROC_SERVER, @pIID_IWbemLocator, @pLocator)
'TextBox2.AddLine("1. 创建WMI定位器对象:    " & hr)
'If hr <> 0 Then Exit Sub
'
'Dim As WString Ptr a, b, c
'
'' 连接到WMI服务
'WLet(a, ComboBoxEdit1.Text)   '命名空间
'WLet(b, "")             '用户名
'WLet(c, "")             '密码
'hr = pLocator->lpVtbl->ConnectServer(pLocator, a, NULL, NULL, 0, NULL, 0, 0, @pService)
'TextBox2.AddLine("2. 连接到WMI服务:        " & *a & ", " & hr)
'If hr <> 0 Then Exit Sub
'
'' 设置安全级别
'hr = CoSetProxyBlanket(Cast(IUnknown Ptr, pService), RPC_C_AUTHN_WINNT, RPC_C_AUTHZ_NONE, NULL, RPC_C_AUTHN_LEVEL_CALL, RPC_C_IMP_LEVEL_IMPERSONATE, NULL, EOAC_NONE)
'TextBox2.AddLine("3. 设置安全级别:         " & hr)
'If hr <> 0 Then Exit Sub
'
'' 类的所有属性名称
'Dim As IWbemClassObject Ptr pClassObject
'WLet(a, ComboBoxEdit2.Text)
'hr = pService->lpVtbl->GetObject(pService, a, 0, NULL, @pClassObject, NULL)
'TextBox2.AddLine("3.1 类的所有属性名称:    " & *a & ", " & hr)
'
'hr = pClassObject->lpVtbl->BeginEnumeration(pClassObject, WBEM_FLAG_FORWARD_ONLY Or WBEM_FLAG_RETURN_IMMEDIATELY)
'TextBox2.AddLine("3.2 类的所有属性名称:    " & hr)
'Dim As BSTR propName
'Dim As VARIANT pVal
'Dim As CIMTYPE propType
'Dim As ULong propFlavor
'Do
'	hr = pClassObject->lpVtbl->Next(pClassObject, 0, @propName, @pVal, @propType, @propFlavor)
'	If hr = 0 Then
'		TextBox2.AddLine("3.3 类的所有属性名称:    " & hr)
'		TextBox2.AddLine("3.4 类的所有属性名称:    " & *Cast(WString Ptr, propName))
'		SysFreeString(propName)
'	Else
'		Exit Do
'	End If
'Loop While True
'If pClassObject Then pClassObject->lpVtbl->Release(pClassObject)
'
'' 查询操作系统信息
'WLet(a, "WQL")
'WLet(b, "SELECT * FROM " & ComboBoxEdit2.Text)
''WLet(b, "SELECT * FROM __PATH")
'hr = pService->lpVtbl->ExecQuery(pService, a, b, WBEM_FLAG_FORWARD_ONLY Or WBEM_FLAG_RETURN_IMMEDIATELY, NULL, @pEnum)
'TextBox2.AddLine("4. 执行查询:             " & *b & ", " & hr)
'If hr <> 0 Then Exit Sub
'
'' 获取查询结果
'Dim As ULong uReturn = 0
'Dim cItem As Long = 0
'ComboBoxEdit3.Clear
'Do
'	hr = pEnum->lpVtbl->Next(pEnum, WBEM_INFINITE, 1, @pItem, @uReturn)
'	Print "pEnum->lpVtbl->Next", hr, pItem, uReturn
'	If uReturn = 0 Then Exit Do
'
'	'检索类中所有属性名称
'	Dim As SAFEARRAY Ptr pNames
'	hr = pItem->lpVtbl->GetNames(pItem, NULL, WBEM_FLAG_NONSYSTEM_ONLY, NULL, @pNames)
'	Print "pItem->lpVtbl->GetNames" , hr
'	TextBox2.AddLine("5. 检索类中所有属性名称: " & hr)
'	If hr <> 0 Then Exit Sub
'	Dim As Long lLBound, lUBound
'	SafeArrayGetLBound(pNames, 1, @lLBound)
'	SafeArrayGetUBound(pNames, 1, @lUBound)
'	Dim As Long i
'	Dim As BSTR bstrName
'	Dim As Long pFlag
'	Dim As CIMTYPE pType
'	For i = lLBound To lUBound
'		hr = SafeArrayGetElement(pNames, @i, @bstrName)
'		If hr = 0 Then
'			WLet(a, *Cast(WString Ptr, bstrName))
'			If cItem = 0 Then ComboBoxEdit3.AddItem(*a)
'			TextBox2.AddLine(cItem & "." & i & " -> " & *a)
'			hr = pItem->lpVtbl->Get(pItem, a, 0, @vResult, @pType, @pFlag)
'			If hr = 0 Then
'				Select Case pType
'				Case 8
'					TextBox2.AddLine(" = Data type: " & pType & ", Flag: " & pFlag & " = " &  *Cast(WString Ptr, vResult.pbstrVal))
'				Case Else
'					TextBox2.AddLine(" = Data type: " & pType & ", Flag: " & pFlag)
'				End Select
'			Else
'				TextBox2.AddLine(" = null")
'			End If
'			SysFreeString(bstrName)
'		End If
'	Next
'	SafeArrayDestroy(pNames)
'	If pItem Then pItem->lpVtbl->Release(pItem)
'	cItem += 1
'Loop While True
'
'' 清理
'If pEnum Then pEnum->lpVtbl->Release(pEnum)
'If pService Then pService->lpVtbl->Release(pService)
'If pLocator Then pLocator->lpVtbl->Release(pLocator)
'If a Then Deallocate(a)
'If b Then Deallocate(b)
'If c Then Deallocate(c)
'
'CoUninitialize()
