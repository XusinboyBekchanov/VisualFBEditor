#include once "inc/SimpleVariantPlus.bi"
Type Object_Excel
	V As tagVARIANT
	Declare Constructor()
	Declare Destructor()
	Declare Sub Clear()
	
	Declare Function VarType()  As vbVarType
	Declare Function TypeName() As String
	Declare Function IsEmpty()  As Boolean
	Declare Function IsArray()  As Boolean
	Declare Function IsObject() As Boolean
	
	Declare Constructor (ByVal RHS As Boolean)
	Declare Operator Let(ByVal RHS As Boolean)
	Declare Operator Cast() As Boolean
	
	Declare Constructor (ByVal RHS As UByte)
	Declare Operator Let(ByVal RHS As UByte)
	Declare Operator Cast() As UByte
	
	Declare Constructor (ByVal RHS As Short)
	Declare Operator Let(ByVal RHS As Short)
	Declare Operator Cast() As Short
	
	Declare Constructor (ByVal RHS As Long)
	Declare Operator Let(ByVal RHS As Long)
	Declare Operator Cast() As Long
	
	Declare Constructor (ByVal RHS As LongInt)
	Declare Operator Let(ByVal RHS As LongInt)
	Declare Operator Cast() As LongInt
	
	Declare Constructor (ByVal RHS As Single)
	Declare Operator Let(ByVal RHS As Single)
	Declare Operator Cast() As Single
	
	Declare Constructor (ByVal RHS As Double)
	Declare Operator Let(ByVal RHS As Double)
	Declare Operator Cast() As Double
	
	Declare Constructor (RHS As String)
	Declare Operator Let(RHS As String)
	Declare Operator Cast()  As String
	
	Declare Constructor (ByVal RHS As Const WString Ptr)
	Declare Operator Let(ByVal RHS As Const WString Ptr)
	Declare Operator Cast() As WString Ptr
	
	Declare Constructor (RHS As tagVARIANT)
	Declare Operator Let(RHS As tagVARIANT)
	Declare Operator Cast()  As tagVARIANT
	
	Declare Constructor (RHS As Object_Excel)
	Declare Operator Let(RHS As Object_Excel)
	
	#ifdef __FB_64BIT__
		Declare Function Call cdecl (ByVal MethodName As LPOLESTR, TypeChars As String = "", ByVal Arg0 As Any Ptr = 0, ByVal Arg1 As Any Ptr = 0, ByVal Arg2 As Any Ptr = 0, ByVal Arg3 As Any Ptr = 0, ByVal Arg4 As Any Ptr = 0, ByVal Arg5 As Any Ptr = 0, ByVal Arg6 As Any Ptr = 0, ByVal Arg7 As Any Ptr = 0, ByVal Arg8 As Any Ptr = 0, ByVal Arg9 As Any Ptr = 0, ByVal Arg10 As Any Ptr = 0, ByVal Arg11 As Any Ptr = 0, ByVal Arg12 As Any Ptr = 0, ByVal Arg13 As Any Ptr = 0, ByVal Arg14 As Any Ptr = 0, ByVal Arg15 As Any Ptr = 0, ByVal Arg16 As Any Ptr = 0, ByVal Arg17 As Any Ptr = 0, ByVal Arg18 As Any Ptr = 0, ByVal Arg19 As Any Ptr = 0, ByVal Arg20 As Any Ptr = 0, ByVal Arg21 As Any Ptr = 0, ByVal Arg22 As Any Ptr = 0, ByVal Arg23 As Any Ptr = 0, ByVal Arg24 As Any Ptr = 0, ByVal Arg25 As Any Ptr = 0, ByVal Arg26 As Any Ptr = 0, ByVal Arg27 As Any Ptr = 0, ByVal Arg28 As Any Ptr = 0, ByVal Arg29 As Any Ptr = 0, ByVal Arg30 As Any Ptr = 0, ByVal Arg31 As Any Ptr = 0) As Object_Excel
		Declare Function  Get cdecl (ByVal MethodName As LPOLESTR, TypeChars As String = "", ByVal Arg0 As Any Ptr = 0, ByVal Arg1 As Any Ptr = 0, ByVal Arg2 As Any Ptr = 0, ByVal Arg3 As Any Ptr = 0, ByVal Arg4 As Any Ptr = 0, ByVal Arg5 As Any Ptr = 0, ByVal Arg6 As Any Ptr = 0, ByVal Arg7 As Any Ptr = 0, ByVal Arg8 As Any Ptr = 0, ByVal Arg9 As Any Ptr = 0, ByVal Arg10 As Any Ptr = 0, ByVal Arg11 As Any Ptr = 0, ByVal Arg12 As Any Ptr = 0, ByVal Arg13 As Any Ptr = 0, ByVal Arg14 As Any Ptr = 0, ByVal Arg15 As Any Ptr = 0, ByVal Arg16 As Any Ptr = 0, ByVal Arg17 As Any Ptr = 0, ByVal Arg18 As Any Ptr = 0, ByVal Arg19 As Any Ptr = 0, ByVal Arg20 As Any Ptr = 0, ByVal Arg21 As Any Ptr = 0, ByVal Arg22 As Any Ptr = 0, ByVal Arg23 As Any Ptr = 0, ByVal Arg24 As Any Ptr = 0, ByVal Arg25 As Any Ptr = 0, ByVal Arg26 As Any Ptr = 0, ByVal Arg27 As Any Ptr = 0, ByVal Arg28 As Any Ptr = 0, ByVal Arg29 As Any Ptr = 0, ByVal Arg30 As Any Ptr = 0, ByVal Arg31 As Any Ptr = 0) As Object_Excel
		Declare Sub       Put cdecl (ByVal MethodName As LPOLESTR, TypeChars As String = "", ByVal Arg0 As Any Ptr = 0, ByVal Arg1 As Any Ptr = 0, ByVal Arg2 As Any Ptr = 0, ByVal Arg3 As Any Ptr = 0, ByVal Arg4 As Any Ptr = 0, ByVal Arg5 As Any Ptr = 0, ByVal Arg6 As Any Ptr = 0, ByVal Arg7 As Any Ptr = 0, ByVal Arg8 As Any Ptr = 0, ByVal Arg9 As Any Ptr = 0, ByVal Arg10 As Any Ptr = 0, ByVal Arg11 As Any Ptr = 0, ByVal Arg12 As Any Ptr = 0, ByVal Arg13 As Any Ptr = 0, ByVal Arg14 As Any Ptr = 0, ByVal Arg15 As Any Ptr = 0, ByVal Arg16 As Any Ptr = 0, ByVal Arg17 As Any Ptr = 0, ByVal Arg18 As Any Ptr = 0, ByVal Arg19 As Any Ptr = 0, ByVal Arg20 As Any Ptr = 0, ByVal Arg21 As Any Ptr = 0, ByVal Arg22 As Any Ptr = 0, ByVal Arg23 As Any Ptr = 0, ByVal Arg24 As Any Ptr = 0, ByVal Arg25 As Any Ptr = 0, ByVal Arg26 As Any Ptr = 0, ByVal Arg27 As Any Ptr = 0, ByVal Arg28 As Any Ptr = 0, ByVal Arg29 As Any Ptr = 0, ByVal Arg30 As Any Ptr = 0, ByVal Arg31 As Any Ptr = 0)
		'Declare Sub       Set cdecl (ByVal MethodName As LPOLESTR, TypeChars As String = "", ByVal Arg0 As Any Ptr = 0, ByVal Arg1 As Any Ptr = 0, ByVal Arg2 As Any Ptr = 0, ByVal Arg3 As Any Ptr = 0, ByVal Arg4 As Any Ptr = 0, ByVal Arg5 As Any Ptr = 0, ByVal Arg6 As Any Ptr = 0, ByVal Arg7 As Any Ptr = 0, ByVal Arg8 As Any Ptr = 0, ByVal Arg9 As Any Ptr = 0, ByVal Arg10 As Any Ptr = 0, ByVal Arg11 As Any Ptr = 0, ByVal Arg12 As Any Ptr = 0, ByVal Arg13 As Any Ptr = 0, ByVal Arg14 As Any Ptr = 0, ByVal Arg15 As Any Ptr = 0, ByVal Arg16 As Any Ptr = 0, ByVal Arg17 As Any Ptr = 0, ByVal Arg18 As Any Ptr = 0, ByVal Arg19 As Any Ptr = 0, ByVal Arg20 As Any Ptr = 0, ByVal Arg21 As Any Ptr = 0, ByVal Arg22 As Any Ptr = 0, ByVal Arg23 As Any Ptr = 0, ByVal Arg24 As Any Ptr = 0, ByVal Arg25 As Any Ptr = 0, ByVal Arg26 As Any Ptr = 0, ByVal Arg27 As Any Ptr = 0, ByVal Arg28 As Any Ptr = 0, ByVal Arg29 As Any Ptr = 0, ByVal Arg30 As Any Ptr = 0, ByVal Arg31 As Any Ptr = 0)
	#else
		Declare Function Call cdecl (ByVal MethodName As LPOLESTR, TypeChars As String = "", ...) As Object_Excel
		Declare Function  Get cdecl (ByVal MethodName As LPOLESTR, TypeChars As String = "", ...) As Object_Excel
		Declare Sub       Put cdecl (ByVal MethodName As LPOLESTR, TypeChars As String = "", ...)
		'Declare Sub       Set cdecl (ByVal MethodName As LPOLESTR, TypeChars As String = "", ...)
	#endif
	Declare Function  vbV() As Object_Excel

' 添加声明在以下位置 09:11:08, 06-15-2024
	Declare Function Open(ByRef Param1 As Object_Excel) As Object_Excel
	Declare Function Workbooks As Object_Excel
	Declare Property Visible As Object_Excel
	Declare Property Visible(ByRef Param1 As Object_Excel)
	Declare Function Worksheets(ByRef Param1 As Object_Excel) As Object_Excel
	Declare Property Value As Object_Excel
	Declare Property Value(ByRef Param1 As Object_Excel)
	Declare Function Range(ByRef Param1 As Object_Excel) As Object_Excel
	Declare Function Offset(ByRef Param1 As Object_Excel, ByRef Param2 As Object_Excel) As Object_Excel
	Declare Function Save(ByRef Param1 As Object_Excel) As Object_Excel
	Declare Property Saved As Object_Excel
	Declare Property Saved(ByRef Param1 As Object_Excel)
	Declare Function Parent As Object_Excel
	Declare Function Quit As Object_Excel

	'_Com_Declares

	
End Type

' 在以下位置添加函数 09:11:08, 06-15-2024
Function Object_Excel.Open(ByRef Param1 As Object_Excel) As Object_Excel
	Return This.Get("Open", "v", @Param1)
End Function
Function Object_Excel.Workbooks As Object_Excel
	Return This.Get("Workbooks")
End Function
Property Object_Excel.Visible As Object_Excel
	Return This.Get("Visible")
End Property
Property Object_Excel.Visible(ByRef Param1 As Object_Excel)
	This.Put("Visible", "v", @Param1)
End Property
Function Object_Excel.Worksheets(ByRef Param1 As Object_Excel) As Object_Excel
	Return This.Get("Worksheets", "v", @Param1)
End Function
Property Object_Excel.Value As Object_Excel
	Return This.Get("Value")
End Property
Property Object_Excel.Value(ByRef Param1 As Object_Excel)
	This.Put("Value", "v", @Param1)
End Property
Function Object_Excel.Range(ByRef Param1 As Object_Excel) As Object_Excel
	Return This.Get("Range", "v", @Param1)
End Function
Function Object_Excel.Offset(ByRef Param1 As Object_Excel, ByRef Param2 As Object_Excel) As Object_Excel
	Return This.Get("Offset", "vv", @Param1, @Param2)
End Function
Function Object_Excel.Save(ByRef Param1 As Object_Excel) As Object_Excel
	Return This.Get("Save", "v", @Param1)
End Function
Property Object_Excel.Saved As Object_Excel
	Return This.Get("Saved")
End Property
Property Object_Excel.Saved(ByRef Param1 As Object_Excel)
	This.Put("Saved", "v", @Param1)
End Property
Function Object_Excel.Parent As Object_Excel
	Return This.Get("Parent")
End Function
Function Object_Excel.Quit As Object_Excel
	Return This.Get("Quit")
End Function

'_Com_Functions


Function Object_Excel.vbV() As Object_Excel
	Return This
End Function
Constructor Object_Excel()
	'we dont't do anything here in the base constructor currently
End Constructor
Destructor Object_Excel()
	'MsgBox "Destructor of: " & TypeName
	If V.vt Then VariantClear @V
End Destructor
Sub Object_Excel.Clear() 'usable on the Outside, e.g. to dereference an Object "early"
	If V.vt Then VariantClear @V: VariantInit @V
End Sub

Function Object_Excel.VarType() As vbVarType
	Return V.vt
End Function
Function Object_Excel.TypeName() As String
	Dim T As String
	Select Case V.vt And Not (vbArray Or vbByRef)
	Case vbVarType.vbEmpty:    T = "Empty"
	Case vbVarType.vbNull:     T = "Null"
	Case vbVarType.vbInteger:  T = "Integer"
	Case vbVarType.vbLong:     T = "Long"
	Case vbVarType.vbSingle:   T = "Single"
	Case vbVarType.vbDouble:   T = "Double"
	Case vbVarType.vbCurrency: T = "Currency"
	Case vbVarType.vbDate:     T = "Date"
	Case vbVarType.vbString:   T = "String"
	Case vbVarType.vbObject:   T = "Object"
	Case vbVarType.vbError:    T = "Error"
	Case vbVarType.vbBoolean:  T = "Boolean"
	Case vbVarType.vbVariant:  T = "Variant"
	Case vbVarType.vbDecimal:  T = "Decimal"
	Case vbVarType.vbByte:     T = "Byte"
	Case Else:                 T = "UnsupportedType(" & Hex(V.vt) & ")"
	End Select
	If V.vt And vbArray Then Return T & "()"
	Return T
End Function
Function Object_Excel.IsEmpty() As Boolean
	Return V.vt = vbEmpty
End Function
Function Object_Excel.IsArray() As Boolean
	If V.vt And vbArray Then Return True
End Function
Function Object_Excel.IsObject() As Boolean
	Return V.vt = vbObject
End Function


Constructor Object_Excel(ByVal RHS As Boolean)
	This = RHS
End Constructor
Operator Object_Excel.Let(ByVal RHS As Boolean)
	If V.vt <> vbBoolean  And V.vt <> vbEmpty Then VariantClear @V
	V.vt =  vbBoolean: V.boolVal = CShort(RHS)
End Operator
Operator Object_Excel.Cast() As Boolean
	If V.vt = vbBoolean Then
		Return CBool(V.boolVal)
	Else
		Dim VV As tagVARIANT
		HandleCOMErr VariantChangeTypeEx(@VV, @V, DefaultLocale_VariantConv, VARIANT_NOVALUEPROP Or VARIANT_ALPHABOOL, vbBoolean), "SimpleVariant.Cast_Boolean"
		Return CBool(VV.boolVal)
	End If
End Operator


Constructor Object_Excel(ByVal RHS As UByte)
	This = RHS
End Constructor
Operator Object_Excel.Let(ByVal RHS As UByte)
	If V.vt <> vbByte  And V.vt <> vbEmpty Then VariantClear @V
	V.vt =  vbByte: V.bVal = RHS
End Operator
Operator Object_Excel.Cast() As UByte
	If V.vt = vbByte Then
		Return V.bVal
	Else
		Dim VV As tagVARIANT
		HandleCOMErr VariantChangeTypeEx(@VV, @V, DefaultLocale_VariantConv, VARIANT_NOVALUEPROP, vbByte), "SimpleVariant.Cast_UByte"
		Return VV.bVal
	End If
End Operator


Constructor Object_Excel(ByVal RHS As Short)
	This = RHS
End Constructor
Operator Object_Excel.Let(ByVal RHS As Short)
	If V.vt <> vbInteger  And V.vt <> vbEmpty Then VariantClear @V
	V.vt =  vbInteger: V.iVal = RHS
End Operator
Operator Object_Excel.Cast() As Short
	If V.vt = vbInteger Then
		Return V.iVal
	Else
		Dim VV As tagVARIANT
		HandleCOMErr VariantChangeTypeEx(@VV, @V, DefaultLocale_VariantConv, VARIANT_NOVALUEPROP, vbInteger), "SimpleVariant.Cast_Short"
		Return VV.iVal
	End If
End Operator


Constructor Object_Excel(ByVal RHS As Long)
	This = RHS
End Constructor
Operator Object_Excel.Let(ByVal RHS As Long)
	If V.VT <> vbLong  And V.VT <> vbEmpty Then VariantClear @V
	V.VT =  vbLong: V.lVal = RHS
End Operator
Operator Object_Excel.Cast() As Long
	If V.VT = vbLong Then
		Return V.lVal
	Else
		Dim VV As tagVariant
		HandleCOMErr VariantChangeTypeEx(@VV, @V, DefaultLocale_VariantConv, VARIANT_NOVALUEPROP, vbLong), "SimpleVariant.Cast_Long"
		Return VV.lVal
	End If
End Operator


Constructor Object_Excel(ByVal RHS As LongInt)
	This = RHS
End Constructor
Operator Object_Excel.Let(ByVal RHS As LongInt)
	If V.VT <> vbCurrency  And V.VT <> vbEmpty Then VariantClear @V
	V.VT =  vbCurrency: V.llVal = RHS * 10000
End Operator
Operator Object_Excel.Cast() As LongInt
	If V.VT = vbCurrency Then
		Return V.llVal / 10000
	Else
		Dim VV As tagVariant
		HandleCOMErr VariantChangeTypeEx(@VV, @V, DefaultLocale_VariantConv, VARIANT_NOVALUEPROP, VT_I8), "SimpleVariant.Cast_LongInt"
		Return VV.llVal
	End If
End Operator


Constructor Object_Excel(ByVal RHS As Single)
	This = RHS
End Constructor
Operator Object_Excel.Let(ByVal RHS As Single)
	If V.VT <> vbSingle  And V.VT <> vbEmpty Then VariantClear @V
	V.VT =  vbSingle: V.fltVal = RHS
End Operator
Operator Object_Excel.Cast() As Single
	If V.VT = vbSingle Then
		Return V.fltVal
	Else
		Dim VV As tagVariant
		HandleCOMErr VariantChangeTypeEx(@VV, @V, DefaultLocale_VariantConv, VARIANT_NOVALUEPROP, vbSingle), "SimpleVariant.Cast_Single"
		Return VV.fltVal
	End If
End Operator


Constructor Object_Excel(ByVal RHS As Double)
	This = RHS
End Constructor
Operator Object_Excel.Let(ByVal RHS As Double)
	If V.VT <> vbDouble  And V.VT <> vbEmpty Then VariantClear @V
	V.VT =  vbDouble: V.dblVal = RHS
End Operator
Operator Object_Excel.Cast() As Double
	If V.VT = vbDouble Then
		Return V.dblVal
	Else
		Dim VV As tagVariant
		HandleCOMErr VariantChangeTypeEx(@VV, @V, DefaultLocale_VariantConv, VARIANT_NOVALUEPROP, vbDouble), "SimpleVariant.Cast_Double"
		Return VV.dblVal
	End If
End Operator


Constructor Object_Excel(RHS As String)
	This = RHS
End Constructor
Operator Object_Excel.Let(RHS As String)
	If V.VT Then VariantClear @V
	V.VT = vbString: V.bstrVal = S2BSTR(RHS)
End Operator
Operator Object_Excel.Cast() As String
	If V.VT = vbString Then
		Return BSTR2S(V.bstrVal)
	Else
		Dim VV As tagVariant
		HandleCOMErr VariantChangeTypeEx(@VV, @V, DefaultLocale_VariantConv, VARIANT_NOVALUEPROP Or VARIANT_ALPHABOOL, vbString), "SimpleVariant.Cast_String"
		If V.VT = (vbArray Or vbByte) Then
			Dim S As String = String(SysStringByteLen(VV.bstrVal), 0)
			memcpy StrPtr(S), VV.bstrVal, Len(S)
			Operator = S
		Else
			Operator = BSTR2S(VV.bstrVal)
		End If
		VariantClear @VV
	End If
End Operator


Constructor Object_Excel(ByVal RHS As Const WString Ptr)
	This = RHS
End Constructor
Operator Object_Excel.Let(ByVal RHS As Const WString Ptr)
	If V.VT Then VariantClear @V
	V.VT = vbString: V.bstrVal = W2BSTR(RHS)
End Operator
Operator Object_Excel.Cast() As WString Ptr
	If V.VT = vbString Then
		Return WCacheValue(V.bstrVal)
	Else
		Dim VV As tagVariant
		HandleCOMErr VariantChangeTypeEx(@VV, @V, DefaultLocale_VariantConv, VARIANT_NOVALUEPROP Or VARIANT_ALPHABOOL, vbString), "SimpleVariant.Cast_WString"
		Operator = WCacheValue(VV.bstrVal)
		VariantClear @VV
	End If
End Operator


Constructor Object_Excel(RHS As tagVariant)
	If @This = @RHS Then Exit Constructor
	If V.VT Then VariantClear @V
	V=RHS '<- we go with a shallow copy here (to not mess-up RefCounts - e.g. when normal tagVariants come in from Function-Results)
End Constructor
Operator Object_Excel.Let(RHS As tagVariant)
	If @This = @RHS Then Exit Operator
	If V.VT Then VariantClear @V
	VariantCopy @V, @RHS
End Operator
Operator Object_Excel.Cast() As tagVariant
	Dim Dst As tagVariant
	VariantCopy @Dst, @V
	Return Dst
End Operator


Constructor Object_Excel(RHS As Object_Excel)
	If @This = @RHS Then Exit Constructor
	If V.VT Then VariantClear @V
	VariantCopy @V, @RHS.V
End Constructor
Operator Object_Excel.Let(RHS As Object_Excel)
	If @This = @RHS Then Exit Operator
	If V.VT Then VariantClear @V
	VariantCopy @V, @RHS.V
End Operator

#ifdef __FB_64BIT__
	Function Object_Excel.Call cdecl (ByVal MethodName As LPOLESTR, TypeChars As String = "", ByVal Arg0 As Any Ptr = 0, ByVal Arg1 As Any Ptr = 0, ByVal Arg2 As Any Ptr = 0, ByVal Arg3 As Any Ptr = 0, ByVal Arg4 As Any Ptr = 0, ByVal Arg5 As Any Ptr = 0, ByVal Arg6 As Any Ptr = 0, ByVal Arg7 As Any Ptr = 0, ByVal Arg8 As Any Ptr = 0, ByVal Arg9 As Any Ptr = 0, ByVal Arg10 As Any Ptr = 0, ByVal Arg11 As Any Ptr = 0, ByVal Arg12 As Any Ptr = 0, ByVal Arg13 As Any Ptr = 0, ByVal Arg14 As Any Ptr = 0, ByVal Arg15 As Any Ptr = 0, ByVal Arg16 As Any Ptr = 0, ByVal Arg17 As Any Ptr = 0, ByVal Arg18 As Any Ptr = 0, ByVal Arg19 As Any Ptr = 0, ByVal Arg20 As Any Ptr = 0, ByVal Arg21 As Any Ptr = 0, ByVal Arg22 As Any Ptr = 0, ByVal Arg23 As Any Ptr = 0, ByVal Arg24 As Any Ptr = 0, ByVal Arg25 As Any Ptr = 0, ByVal Arg26 As Any Ptr = 0, ByVal Arg27 As Any Ptr = 0, ByVal Arg28 As Any Ptr = 0, ByVal Arg29 As Any Ptr = 0, ByVal Arg30 As Any Ptr = 0, ByVal Arg31 As Any Ptr = 0) As Object_Excel
		Dim tv As tagVariant
		tv = CallByName(V, MethodName, DISPATCH_METHOD Or DISPATCH_PROPERTYGET, TypeChars, Arg0, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10, Arg11, Arg12, Arg13, Arg14, Arg15, Arg16, Arg17, Arg18, Arg19, Arg20, Arg21, Arg22, Arg23, Arg24, Arg25, Arg26, Arg27, Arg28, Arg29, Arg30, Arg31)
		Function = tv
	End Function
	Function Object_Excel.Get cdecl (ByVal MethodName As LPOLESTR, TypeChars As String = "", ByVal Arg0 As Any Ptr = 0, ByVal Arg1 As Any Ptr = 0, ByVal Arg2 As Any Ptr = 0, ByVal Arg3 As Any Ptr = 0, ByVal Arg4 As Any Ptr = 0, ByVal Arg5 As Any Ptr = 0, ByVal Arg6 As Any Ptr = 0, ByVal Arg7 As Any Ptr = 0, ByVal Arg8 As Any Ptr = 0, ByVal Arg9 As Any Ptr = 0, ByVal Arg10 As Any Ptr = 0, ByVal Arg11 As Any Ptr = 0, ByVal Arg12 As Any Ptr = 0, ByVal Arg13 As Any Ptr = 0, ByVal Arg14 As Any Ptr = 0, ByVal Arg15 As Any Ptr = 0, ByVal Arg16 As Any Ptr = 0, ByVal Arg17 As Any Ptr = 0, ByVal Arg18 As Any Ptr = 0, ByVal Arg19 As Any Ptr = 0, ByVal Arg20 As Any Ptr = 0, ByVal Arg21 As Any Ptr = 0, ByVal Arg22 As Any Ptr = 0, ByVal Arg23 As Any Ptr = 0, ByVal Arg24 As Any Ptr = 0, ByVal Arg25 As Any Ptr = 0, ByVal Arg26 As Any Ptr = 0, ByVal Arg27 As Any Ptr = 0, ByVal Arg28 As Any Ptr = 0, ByVal Arg29 As Any Ptr = 0, ByVal Arg30 As Any Ptr = 0, ByVal Arg31 As Any Ptr = 0) As Object_Excel
		Return CallByName(V, MethodName, DISPATCH_METHOD Or DISPATCH_PROPERTYGET, TypeChars, Arg0, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10, Arg11, Arg12, Arg13, Arg14, Arg15, Arg16, Arg17, Arg18, Arg19, Arg20, Arg21, Arg22, Arg23, Arg24, Arg25, Arg26, Arg27, Arg28, Arg29, Arg30, Arg31)
	End Function
	Sub Object_Excel.Put cdecl (ByVal MethodName As LPOLESTR, TypeChars As String = "", ByVal Arg0 As Any Ptr = 0, ByVal Arg1 As Any Ptr = 0, ByVal Arg2 As Any Ptr = 0, ByVal Arg3 As Any Ptr = 0, ByVal Arg4 As Any Ptr = 0, ByVal Arg5 As Any Ptr = 0, ByVal Arg6 As Any Ptr = 0, ByVal Arg7 As Any Ptr = 0, ByVal Arg8 As Any Ptr = 0, ByVal Arg9 As Any Ptr = 0, ByVal Arg10 As Any Ptr = 0, ByVal Arg11 As Any Ptr = 0, ByVal Arg12 As Any Ptr = 0, ByVal Arg13 As Any Ptr = 0, ByVal Arg14 As Any Ptr = 0, ByVal Arg15 As Any Ptr = 0, ByVal Arg16 As Any Ptr = 0, ByVal Arg17 As Any Ptr = 0, ByVal Arg18 As Any Ptr = 0, ByVal Arg19 As Any Ptr = 0, ByVal Arg20 As Any Ptr = 0, ByVal Arg21 As Any Ptr = 0, ByVal Arg22 As Any Ptr = 0, ByVal Arg23 As Any Ptr = 0, ByVal Arg24 As Any Ptr = 0, ByVal Arg25 As Any Ptr = 0, ByVal Arg26 As Any Ptr = 0, ByVal Arg27 As Any Ptr = 0, ByVal Arg28 As Any Ptr = 0, ByVal Arg29 As Any Ptr = 0, ByVal Arg30 As Any Ptr = 0, ByVal Arg31 As Any Ptr = 0)
		CallByName(V, MethodName, DISPATCH_PROPERTYPUT, TypeChars, Arg0, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10, Arg11, Arg12, Arg13, Arg14, Arg15, Arg16, Arg17, Arg18, Arg19, Arg20, Arg21, Arg22, Arg23, Arg24, Arg25, Arg26, Arg27, Arg28, Arg29, Arg30, Arg31)
	End Sub
	'Sub Object_Excel.Set cdecl (ByVal MethodName As LPOLESTR, TypeChars As String = "", ByVal Arg0 As Any Ptr = 0, ByVal Arg1 As Any Ptr = 0, ByVal Arg2 As Any Ptr = 0, ByVal Arg3 As Any Ptr = 0, ByVal Arg4 As Any Ptr = 0, ByVal Arg5 As Any Ptr = 0, ByVal Arg6 As Any Ptr = 0, ByVal Arg7 As Any Ptr = 0, ByVal Arg8 As Any Ptr = 0, ByVal Arg9 As Any Ptr = 0, ByVal Arg10 As Any Ptr = 0, ByVal Arg11 As Any Ptr = 0, ByVal Arg12 As Any Ptr = 0, ByVal Arg13 As Any Ptr = 0, ByVal Arg14 As Any Ptr = 0, ByVal Arg15 As Any Ptr = 0, ByVal Arg16 As Any Ptr = 0, ByVal Arg17 As Any Ptr = 0, ByVal Arg18 As Any Ptr = 0, ByVal Arg19 As Any Ptr = 0, ByVal Arg20 As Any Ptr = 0, ByVal Arg21 As Any Ptr = 0, ByVal Arg22 As Any Ptr = 0, ByVal Arg23 As Any Ptr = 0, ByVal Arg24 As Any Ptr = 0, ByVal Arg25 As Any Ptr = 0, ByVal Arg26 As Any Ptr = 0, ByVal Arg27 As Any Ptr = 0, ByVal Arg28 As Any Ptr = 0, ByVal Arg29 As Any Ptr = 0, ByVal Arg30 As Any Ptr = 0, ByVal Arg31 As Any Ptr = 0)
	'	CallByName(V, MethodName, DISPATCH_PROPERTYPUTREF,  TypeChars, Arg0, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10, Arg11, Arg12, Arg13, Arg14, Arg15, Arg16, Arg17, Arg18, Arg19, Arg20, Arg21, Arg22, Arg23, Arg24, Arg25, Arg26, Arg27, Arg28, Arg29, Arg30, Arg31)
	'End Sub
#else
	Function Object_Excel.Call cdecl (ByVal MethodName As LPOLESTR, TypeChars As String = "", ...) As Object_Excel
		Dim tv As tagVARIANT
		tv = CallByName(V, MethodName, DISPATCH_METHOD Or DISPATCH_PROPERTYGET, TypeChars, va_first)
		Function = tv
	End Function
	Function Object_Excel.Get cdecl (ByVal MethodName As LPOLESTR, TypeChars As String = "", ...) As Object_Excel
		Return CallByName(V, MethodName, DISPATCH_METHOD Or DISPATCH_PROPERTYGET, TypeChars, va_first)
	End Function
	Sub Object_Excel.Put cdecl (ByVal MethodName As LPOLESTR, TypeChars As String = "", ...)
		CallByName(V, MethodName, DISPATCH_PROPERTYPUT, TypeChars, va_first)
	End Sub
	'Sub Object_Excel.Set cdecl (ByVal MethodName As LPOLESTR, TypeChars As String = "", ...)
	'	CallByName(V, MethodName, DISPATCH_PROPERTYPUTREF,  TypeChars, va_first)
	'End Sub
#endif

