'SimpleVariant.bi: a "lean and mean" (not library-dependent) LateBound-Helper-Module for FreeBasic
'Author:      Olaf Schmidt (June 2016)
'The Vartype-Letters, as used for the ByName...-Methods are as follows:
'    u: 8BitU-Integer(FB UByte)
'    i: 16Bit-Integer(FB Short)
'    l: 32Bit-Integer(FB Long)
'    c: 64Bit-Integer(FB LongInt, mapped between 64Bit-FB-Int and -OLEVariant-Currency)
'    b: 16Bit-Boolean(FB Boolean, mapped between 8Bit-FB and 16Bit-OLEVariant-Booleans)
'    f: 32Bit-FlPoint(FB Single)
'    d: 64Bit-FlPoint(FB Double)
'    t: 64BitDateTime(FB Double)
'    s: 8Bit-per-Char(FB String)  !!! note, that only in normal ANSI-FB-Source-Modules, String-Literals can be passed as "s"...
'    w: 16Bit-per-Chr(FB WString) !!! ...in FB-Source-Modules that are Unicode, String-Literals need to be passed as "w" instead
'    v: OleVariant (which always need to be passed with their VarPtr -> @VariantVariable
'When used in the TypeChars-Param of the CallByName-Func, an UpperCase-Letter signifies
'"ByRef"-passing (the FB-Variable needs to be prefixed by an @ in these cases)

#include once "vbcompat.bi"
#include once "windows.bi"
#include once "win/ole2.bi"
#include once "crt/string.bi"

#ifdef __FB_WIN32__ 'this is necessary, because FB maps the original FB-Long-Def to Boolean somehow (remove when Fix is available in the Compiler)
	#undef  Long
	#define Long Integer '...though it should not do any harm to leave it as is... on Win32 it's the same BitLength (+ we filtered with the #IfDef)
	#undef  CLng
	#define CLng CInt 'same thing here - a redefinition is necessary to work around the FB-Win32-Compiler-Bug
	#undef Call 'to allow usage of that KeyWord as an UDT-Method (it's not used anyways in lang -fb)
#endif

'the following Const is used in the (Variant)Conversions from BSTRs to FB-Strings
Dim Shared DefaultCodePage_StringConv As UINT
#ifdef UNICODE
	DefaultCodePage_StringConv = CP_UTF8 'an 8Bit-FB-String will hold an UTF8-Stream when a vbVariant is casted to it
#else
	DefaultCodePage_StringConv = CP_ACP 'that conforms to the normal ANSI-Conversion
#endif

'the Const below is relevant for the Variant-Conversions (Strings <-> Numbers or DateValues) - we avoid LOCALE_USER_DEFAULT,
'since that would convert e.g. a DoubleValue of 1.1 to a String-Representation of 1,1 on a german system, instead LOCALE_INVARIANT ...
Const DefaultLocale_VariantConv As Long = LOCALE_INVARIANT '...conforms to FB-StringConv-Representations of Dates and rational Numbers

Type tCOMErr
	Number As UINT
	Description As String
End Type
Dim Shared COMErr As tCOMErr, EInfo As tagEXCEPINFO, ShowCOMErrors As Boolean = True

Dim Shared Done As Boolean 'anything COM-related needs to CoInitialize... (shell32 and comctl32 are preloaded, to play nicely with Manifested Apps)
If Not Done Then Done = True: CoInitializeEx(0, 2): DyLibLoad("shell32.dll"): DyLibLoad("comctl32.dll")

Function AppName() As String
	Static S As String
	If Len(S) = 0 Then S = Command(0):S = Mid(S, InStrRev(S, "\") + 1): S = Left(S, Len(S) - 4)
	Return S
End Function

Function MsgBox cdecl Overload (ByVal Msg As LPCWSTR, ByVal Flags As Long = MB_ICONINFORMATION) As Long
	Return MessageBoxW(GetActiveWindow, Msg, AppName, Flags)
End Function

Private Function HandleCOMErr(ByVal HRes As HResult, ByVal MethodName As LPOLESTR) As HResult
	Static Msg As WString Ptr: If Msg = NULL Then Msg = CAllocate(8192 + 2)
	
	Function = HRes
	If HRes = DISP_E_EXCEPTION Then
		COMErr.Number = EInfo.sCode
		COMErr.Description= "Err(&H" & Hex(HRes) & ") in " & *Cast(WString Ptr, EInfo.bstrSource) & ", whilst calling: " & *Cast(WString Ptr, MethodName) & Chr(10) & *Cast(WString Ptr, EInfo.bstrDescription)
	ElseIf HRes Then
		FormatMessageW FORMAT_MESSAGE_FROM_SYSTEM Or FORMAT_MESSAGE_IGNORE_INSERTS, NULL, HRes, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), Msg, 4096, NULL
		COMErr.Number = HRes
		COMErr.Description= "Err(&H" & Hex(HRes) & ") in SimpleVariant.bi, whilst calling: " & *Cast(WString Ptr, MethodName) & Chr(10) & *Msg
	End If
	If CBool(HRes) And ShowCOMErrors Then MsgBox COMErr.Description
End Function

'the usual Instantiation-Helper for COM-Objects which are known in the Win-Registry (e.g. CreateObject("Scripting.Dictionary")
Function CreateObject(ByVal ProgID As LPCOLESTR) As tagVariant
	If Not Done Then Done = True: CoInitializeEx(0, 2): DyLibLoad("shell32.dll"): DyLibLoad("comctl32.dll")
	
	COMErr.Number = 0
	Dim CLSID As CLSID, RetVal As tagVariant
	If HandleCOMErr(CLSIDFromProgID(ProgID, @ClsID), "CLSIDFromProgID") Then Return RetVal
	If HandleCOMErr(CoCreateInstance(@ClsID, NULL, CLSCTX_SERVER, @IID_IDispatch, @RetVal.pDispVal), "CreateObject") Then Return RetVal
	RetVal.VT = VT_DISPATCH
	Return RetVal
End Function

'but here's a helper-function to create COM-Objects regfree, in case the user provided a *.manifest-File (and placed it beside the COM-Dll-File)
Function CreateObjectRegFree(ProgID As WString Ptr, ManifestFileName As WString Ptr) As tagVariant
	Static ACW As ACTCTXW
	ACW.cbSize = Len(ACW)
	ACW.lpSource = ManifestFileName
	
	COMErr.Number = 0
	
	Dim hActCtx As HANDLE, Cookie As ULONG_PTR
	hActCtx = CreateActCtxW(@ACW)
	If (hActCtx = INVALID_HANDLE_VALUE) Then
		COMErr.Number = &H80020009
		COMErr.Description = "Couldn't create ActCtx from Manifest: " & *ManifestFileName
		If ShowCOMErrors Then MsgBox COMErr.Description
		Exit Function
	End If
	
	If ActivateActCtx(hActCtx, @Cookie) Then
		Dim OrigDir As String, DllPath As String = Left(*ManifestFileName, InStrRev(*ManifestFileName, "\"))
		OrigDir = CurDir()
		ChDir DllPath
		Function = CreateObject(ProgID)
		ChDir OrigDir
		DeactivateActCtx 0, Cookie
	Else
		COMErr.Number = &H80020009
		COMErr.Description = "Couldn't activate ActCtx from Manifest: " & *ManifestFileName
		If ShowCOMErrors Then MsgBox COMErr.Description
	End If
	
	ReleaseActCtx hActCtx
End Function

Function BSTR2S cdecl (ByVal BS As Const BSTR, ByVal CodePage As UINT = DefaultCodePage_StringConv) As String
	Dim BytesNeeded As UINT, S As String
	BytesNeeded = WideCharToMultiByte(CodePage, 0, BS, SysStringLen(BS), 0, 0, 0, 0)
	S = String(BytesNeeded, 0)
	WideCharToMultiByte CodePage, 0, BS, SysStringLen(BS), StrPtr(S), BytesNeeded, 0, 0
	Return S
End Function
Function S2BSTR cdecl (S As Const String, ByVal CodePage As UINT = DefaultCodePage_StringConv) As BSTR 'the caller is responsible for freeing the returned BSTR per SysFreeString
	Dim WCharsNeeded As UINT, BS As BSTR
	WCharsNeeded = MultiByteToWideChar(CodePage, 0, StrPtr(S), Len(S), 0, 0)
	BS = SysAllocStringLen(BS, WCharsNeeded)
	MultiByteToWideChar CodePage, 0, StrPtr(S), Len(S), BS, WCharsNeeded
	Return BS
End Function

Function BSTR2W(ByVal BS As Const BSTR) As WString Ptr 'the caller is responsible for freeing the returned WString per DeAllocate
	Dim W As WString Ptr
	W = CAllocate(SysStringByteLen(BS) + 2)
	If BS Then memcpy W, BS, SysStringByteLen(BS)
	Return W
End Function
Function W2BSTR(ByVal W As Const WString Ptr) As BSTR 'the caller is responsible for freeing the returned BSTR per SysFreeString
	Return SysAllocString(W)
End Function

'well, this is the workhorse for all the Dispatch-Calls (IDispatch::Invoke)... there's easier Wrapper-Methods around this at the end of this module)
Dim Shared LastDispID As Long = 0, UseDispId As Long = 0
Function CallByName cdecl (vDisp As tagVariant, ByVal MethodName As LPOLESTR, ByVal CallFlag As Word, TypeChars As String = "", ByVal Args As Any Ptr) As tagVariant
	Static DispParams As DISPPARAMS, DispidNamed As DISPID = DISPID_PROPERTYPUT
	Static VParams(31) As tagVariant, SArr(31) As BSTR, ArgsArr(31) As Any Ptr
	Const As UByte l=108,i=105,b=98,d=100,f=102,t=116,v=118,w=119,s=115,c=99,u=117,sR=83,wR=87 'to make the Type-Selects more readable
	Dim TypeChar As UByte, IsByRef As Boolean, VRes As tagVariant, DispId As DISPID
	
	If UseDispID Then DispID = UseDispID: UseDispID = 0
	COMErr.Number = 0
	If DispID = 0 Then
		LastDispID = 0
		If HandleCOMErr(vDisp.pDispVal->lpVtbl->GetIDsOfNames(vDisp.pDispVal, @IID_NULL, @MethodName, 1, LOCALE_USER_DEFAULT, @DispId), MethodName) Then Return VRes
		LastDispID = DispId
	End If
	
	DispParams.cArgs = Len(TypeChars)
	DispParams.rgVarg = @VParams(0)
	DispParams.cNamedArgs = IIf(CallFlag >= DISPATCH_PROPERTYPUT, 1, 0)
	DispParams.rgdispidNamedArgs = IIf(CallFlag >= DISPATCH_PROPERTYPUT, @DispidNamed, 0)
	
	For j As Integer = DispParams.cArgs - 1 To 0 Step -1
		TypeChar = TypeChars[DispParams.cArgs - j - 1]
		IsByRef  = TypeChar < 97
		If IsByRef Then TypeChar += 32 'since the ByRef-Info is now retrieved, we work further with just the lower-case letter
		
		'in a first pass, we set only the proper Variant-Type-Members
		Select Case TypeChar
		Case s,w: VParams(j).VT = VT_BSTR    Or VT_BYREF
		Case u:   VParams(j).VT = VT_UI1     Or VT_BYREF
		Case i:   VParams(j).VT = VT_I2      Or VT_BYREF
		Case l:   VParams(j).VT = VT_I4      Or VT_BYREF
		Case c:   VParams(j).VT = VT_CY      Or IIf(IsByRef, VT_BYREF, 0)
		Case b:   VParams(j).VT = VT_BOOL    Or IIf(IsByRef, VT_BYREF, 0)
		Case f:   VParams(j).VT = VT_R4      Or IIf(IsByRef, VT_BYREF, 0)
		Case d:   VParams(j).VT = VT_R8      Or VT_BYREF
		Case t:   VParams(j).VT = VT_DATE    Or VT_BYREF
		Case v:   VParams(j).VT = VT_VARIANT Or VT_BYREF
		End Select
		
		'in a second pass, we set the Variant-Value-Members of our (static) VParams-Array
		Select Case TypeChar
		Case s,w:  If IsByRef Then ArgsArr(j) = Args
			If SArr(j) Then SysFreeString SArr(j): SArr(j) = 0 'destroy the previous allocation from our static BSTR-Cache
			Select Case TypeChar
			Case s: If IsByRef Then SArr(j) = S2BSTR(*va_arg(Args, String Ptr))      Else SArr(j) = S2BSTR(*va_arg(Args, ZString Ptr))
			Case w: If IsByRef Then SArr(j) = W2BSTR(*va_arg(Args, WString Ptr Ptr)) Else SArr(j) = W2BSTR(*va_arg(Args, WString Ptr))
			End Select
			VParams(j).pbstrVal = @SArr(j)
		Case v:    VParams(j) = *va_arg(Args, tagVARIANT Ptr)
		Case f:    If IsByRef Then VParams(j).pbVal = va_arg(Args, Any Ptr) Else VParams(j).fltVal = CSng(va_arg(Args, Double))
		Case b:    If IsByRef Then VParams(j).pbVal = va_arg(Args, Any Ptr) Else VParams(j).boolVal = CShort(va_arg(Args, Boolean))
		Case c:    If IsByRef Then VParams(j).pbVal = va_arg(Args, Any Ptr) Else VParams(j).llVal = va_arg(Args, LongInt) * 10000
		Case Else: If IsByRef Then VParams(j).pbVal = va_arg(Args, Any Ptr) Else VParams(j).pbVal  = Args
		End Select
		
		'what remains is the type-based Args-Shift
		Select Case TypeChar
		Case s,w,v: Args = va_next(Args, Any Ptr)
		Case f,d,t: If IsByRef Then Args = va_next(Args, Any Ptr) Else Args = va_next(Args, Double)
		Case i:     If IsByRef Then Args = va_next(Args, Any Ptr) Else Args = va_next(Args, Short)
		Case l:     If IsByRef Then Args = va_next(Args, Any Ptr) Else Args = va_next(Args, Long)
		Case b:     If IsByRef Then Args = va_next(Args, Any Ptr) Else Args = va_next(Args, Boolean)
		Case u:     If IsByRef Then Args = va_next(Args, Any Ptr) Else Args = va_next(Args, UByte)
		Case c:     If IsByRef Then Args = va_next(Args, Any Ptr) Else Args = va_next(Args, LongInt)
		End Select
	Next
	
	HandleCOMErr vDisp.pDispVal->lpVtbl->Invoke(VDisp.pDispVal, DispId, @IID_NULL, LOCALE_USER_DEFAULT, CallFlag, @DispParams, @VRes, @EInfo, NULL), MethodName
	
	'this is needed, to pass back any StringValues from our SArr-BSTR-Cache into the FB-StringVariables (in the ByRef-case)
	For j As Integer = DispParams.cArgs - 1 To 0 Step -1
		If VParams(j).VT = (VT_BSTR Or VT_BYREF) Then
			Select Case TypeChars[DispParams.cArgs - j - 1]
			Case sR: *va_arg(ArgsArr(j), String Ptr)      = BSTR2S(SArr(j)) 'pass back, in case it was a FB-ByRef-String
			Case wR: *va_arg(ArgsArr(j), WString Ptr Ptr) = BSTR2W(SArr(j)) 'pass back, in case it was a FB-ByRef-WString
			End Select
		End If
	Next
	
	Return VRes
End Function

'*************************** Begin of the Variant-Wrapper-Section *******************************

Enum vbVarType
	vbEmpty    = &H0000
	vbNull     = &H0001
	vbInteger  = &H0002
	vbLong     = &H0003
	vbSingle   = &H0004
	vbDouble   = &H0005
	vbCurrency = &H0006
	vbDate     = &H0007
	vbString   = &H0008
	vbObject   = &H0009
	vbError    = &H000A
	vbBoolean  = &H000B
	vbVariant  = &H000C
	vbDecimal  = &H000E
	vbByte     = &H0011
	vbArray    = &H2000
	vbByRef    = &H4000
End Enum

Type vbVariant
	V As tagVariant
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
	
	Declare Constructor (RHS As tagVariant)
	Declare Operator Let(RHS As tagVariant)
	Declare Operator Cast()  As tagVariant
	
	Declare Constructor (RHS As vbVariant)
	Declare Operator Let(RHS As vbVariant)
	
	Declare Function Call cdecl (ByVal MethodName As LPOLESTR, TypeChars As String = "", ...) As vbVariant
	Declare Function  Get cdecl (ByVal MethodName As LPOLESTR, TypeChars As String = "", ...) As vbVariant
	Declare Sub       Put cdecl (ByVal MethodName As LPOLESTR, TypeChars As String = "", ...)
	Declare Sub       Set cdecl (ByVal MethodName As LPOLESTR, TypeChars As String = "", ...)
	Declare Function  vbV() As vbVariant
	'Declares
End Type
'Functions
Function vbVariant.vbV() As vbVariant
	Return This
End Function
Constructor vbVariant()
	'we dont't do anything here in the base constructor currently
End Constructor
Destructor vbVariant()
	'MsgBox "Destructor of: " & TypeName
	If V.VT Then VariantClear @V
End Destructor
Sub vbVariant.Clear() 'usable on the Outside, e.g. to dereference an Object "early"
	If V.VT Then VariantClear @V: VariantInit @V
End Sub

Function WCacheValue(BSTR2Copy As BSTR) As WString Ptr 'a little Helper, to avoid leaking with the WString-DataType (in the User-Code)
	Const  CacheSize As Integer = 1024
	Static Cache(0 To CacheSize-1) As WString Ptr, NxtIdx As Integer
	NxtIdx= (NxtIdx + 1) Mod CacheSize
	If Cache(NxtIdx) Then Deallocate Cache(NxtIdx)
	Cache(NxtIdx) = BSTR2W(BSTR2Copy)
	Return Cache(NxtIdx)
End Function

Function vbVariant.VarType() As vbVarType
	Return V.VT
End Function
Function vbVariant.TypeName() As String
	Dim T As String
	Select Case V.VT And Not (vbArray Or vbByRef)
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
	Case Else:                 T = "UnsupportedType(" & Hex(V.VT) & ")"
	End Select
	If V.VT And vbArray Then Return T & "()"
	Return T
End Function
Function vbVariant.IsEmpty() As Boolean
	Return V.VT = vbEmpty
End Function
Function vbVariant.IsArray() As Boolean
	If V.VT And vbArray Then Return True
End Function
Function vbVariant.IsObject() As Boolean
	Return V.VT = vbObject
End Function


Constructor vbVariant(ByVal RHS As Boolean)
	This = RHS
End Constructor
Operator vbVariant.Let(ByVal RHS As Boolean)
	If V.VT <> vbBoolean  And V.VT <> vbEmpty Then VariantClear @V
	V.VT =  vbBoolean: V.boolVal = CShort(RHS)
End Operator
Operator vbVariant.Cast() As Boolean
	If V.VT = vbBoolean Then
		Return CBool(V.boolVal)
	Else
		Dim VV As tagVariant
		HandleCOMErr VariantChangeTypeEx(@VV, @V, DefaultLocale_VariantConv, VARIANT_NOVALUEPROP Or VARIANT_ALPHABOOL, vbBoolean), "SimpleVariant.Cast_Boolean"
		Return CBool(VV.boolVal)
	End If
End Operator


Constructor vbVariant(ByVal RHS As UByte)
	This = RHS
End Constructor
Operator vbVariant.Let(ByVal RHS As UByte)
	If V.VT <> vbByte  And V.VT <> vbEmpty Then VariantClear @V
	V.VT =  vbByte: V.bVal = RHS
End Operator
Operator vbVariant.Cast() As UByte
	If V.VT = vbByte Then
		Return V.bVal
	Else
		Dim VV As tagVariant
		HandleCOMErr VariantChangeTypeEx(@VV, @V, DefaultLocale_VariantConv, VARIANT_NOVALUEPROP, vbByte), "SimpleVariant.Cast_UByte"
		Return VV.bVal
	End If
End Operator


Constructor vbVariant(ByVal RHS As Short)
	This = RHS
End Constructor
Operator vbVariant.Let(ByVal RHS As Short)
	If V.VT <> vbInteger  And V.VT <> vbEmpty Then VariantClear @V
	V.VT =  vbInteger: V.iVal = RHS
End Operator
Operator vbVariant.Cast() As Short
	If V.VT = vbInteger Then
		Return V.iVal
	Else
		Dim VV As tagVariant
		HandleCOMErr VariantChangeTypeEx(@VV, @V, DefaultLocale_VariantConv, VARIANT_NOVALUEPROP, vbInteger), "SimpleVariant.Cast_Short"
		Return VV.iVal
	End If
End Operator


Constructor vbVariant(ByVal RHS As Long)
	This = RHS
End Constructor
Operator vbVariant.Let(ByVal RHS As Long)
	If V.VT <> vbLong  And V.VT <> vbEmpty Then VariantClear @V
	V.VT =  vbLong: V.lVal = RHS
End Operator
Operator vbVariant.Cast() As Long
	If V.VT = vbLong Then
		Return V.lVal
	Else
		Dim VV As tagVariant
		HandleCOMErr VariantChangeTypeEx(@VV, @V, DefaultLocale_VariantConv, VARIANT_NOVALUEPROP, vbLong), "SimpleVariant.Cast_Long"
		Return VV.lVal
	End If
End Operator


Constructor vbVariant(ByVal RHS As LongInt)
	This = RHS
End Constructor
Operator vbVariant.Let(ByVal RHS As LongInt)
	If V.VT <> vbCurrency  And V.VT <> vbEmpty Then VariantClear @V
	V.VT =  vbCurrency: V.llVal = RHS * 10000
End Operator
Operator vbVariant.Cast() As LongInt
	If V.VT = vbCurrency Then
		Return V.llVal / 10000
	Else
		Dim VV As tagVariant
		HandleCOMErr VariantChangeTypeEx(@VV, @V, DefaultLocale_VariantConv, VARIANT_NOVALUEPROP, VT_I8), "SimpleVariant.Cast_LongInt"
		Return VV.llVal
	End If
End Operator


Constructor vbVariant(ByVal RHS As Single)
	This = RHS
End Constructor
Operator vbVariant.Let(ByVal RHS As Single)
	If V.VT <> vbSingle  And V.VT <> vbEmpty Then VariantClear @V
	V.VT =  vbSingle: V.fltVal = RHS
End Operator
Operator vbVariant.Cast() As Single
	If V.VT = vbSingle Then
		Return V.fltVal
	Else
		Dim VV As tagVariant
		HandleCOMErr VariantChangeTypeEx(@VV, @V, DefaultLocale_VariantConv, VARIANT_NOVALUEPROP, vbSingle), "SimpleVariant.Cast_Single"
		Return VV.fltVal
	End If
End Operator


Constructor vbVariant(ByVal RHS As Double)
	This = RHS
End Constructor
Operator vbVariant.Let(ByVal RHS As Double)
	If V.VT <> vbDouble  And V.VT <> vbEmpty Then VariantClear @V
	V.VT =  vbDouble: V.dblVal = RHS
End Operator
Operator vbVariant.Cast() As Double
	If V.VT = vbDouble Then
		Return V.dblVal
	Else
		Dim VV As tagVariant
		HandleCOMErr VariantChangeTypeEx(@VV, @V, DefaultLocale_VariantConv, VARIANT_NOVALUEPROP, vbDouble), "SimpleVariant.Cast_Double"
		Return VV.dblVal
	End If
End Operator


Constructor vbVariant(RHS As String)
	This = RHS
End Constructor
Operator vbVariant.Let(RHS As String)
	If V.VT Then VariantClear @V
	V.VT = vbString: V.bstrVal = S2BSTR(RHS)
End Operator
Operator vbVariant.Cast() As String
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


Constructor vbVariant(ByVal RHS As Const WString Ptr)
	This = RHS
End Constructor
Operator vbVariant.Let(ByVal RHS As Const WString Ptr)
	If V.VT Then VariantClear @V
	V.VT = vbString: V.bstrVal = W2BSTR(RHS)
End Operator
Operator vbVariant.Cast() As WString Ptr
	If V.VT = vbString Then
		Return WCacheValue(V.bstrVal)
	Else
		Dim VV As tagVariant
		HandleCOMErr VariantChangeTypeEx(@VV, @V, DefaultLocale_VariantConv, VARIANT_NOVALUEPROP Or VARIANT_ALPHABOOL, vbString), "SimpleVariant.Cast_WString"
		Operator = WCacheValue(VV.bstrVal)
		VariantClear @VV
	End If
End Operator


Constructor vbVariant(RHS As tagVariant)
	If @This = @RHS Then Exit Constructor
	If V.VT Then VariantClear @V
	V=RHS '<- we go with a shallow copy here (to not mess-up RefCounts - e.g. when normal tagVariants come in from Function-Results)
End Constructor
Operator vbVariant.Let(RHS As tagVariant)
	If @This = @RHS Then Exit Operator
	If V.VT Then VariantClear @V
	VariantCopy @V, @RHS
End Operator
Operator vbVariant.Cast() As tagVariant
	Dim Dst As tagVariant
	VariantCopy @Dst, @V
	Return Dst
End Operator


Constructor vbVariant(RHS As vbVariant)
	If @This = @RHS Then Exit Constructor
	If V.VT Then VariantClear @V
	VariantCopy @V, @RHS.V
End Constructor
Operator vbVariant.Let(RHS As vbVariant)
	If @This = @RHS Then Exit Operator
	If V.VT Then VariantClear @V
	VariantCopy @V, @RHS.V
End Operator


Function vbVariant.Call cdecl (ByVal MethodName As LPOLESTR, TypeChars As String = "", ...) As vbVariant
	Dim tv As tagVariant
	tv = CallByName(V, MethodName, DISPATCH_METHOD Or DISPATCH_PROPERTYGET, TypeChars, va_first)
	Function = tv
End Function
Function vbVariant.Get cdecl (ByVal MethodName As LPOLESTR, TypeChars As String = "", ...) As vbVariant
	Return CallByName(V, MethodName, DISPATCH_METHOD Or DISPATCH_PROPERTYGET, TypeChars, va_first)
End Function
Sub vbVariant.Put cdecl (ByVal MethodName As LPOLESTR, TypeChars As String = "", ...)
	CallByName(V, MethodName, DISPATCH_PROPERTYPUT, TypeChars, va_first)
End Sub
Sub vbVariant.Set cdecl (ByVal MethodName As LPOLESTR, TypeChars As String = "", ...)
	CallByName(V, MethodName, DISPATCH_PROPERTYPUTREF,  TypeChars, va_first)
End Sub

'finally a MsgBox-OverLoad, which accepts a vbVariant as the Msg-Parameter
Function MsgBox cdecl (ByVal Msg As vbVariant, ByVal Flags As Long = MB_ICONINFORMATION) As Long
	If Msg.V.VT = vbString Then
		Return MessageBoxW(GetActiveWindow, Msg.V.bstrVal, AppName, Flags)
	Else
		Dim VV As tagVariant
		HandleCOMErr VariantChangeTypeEx(@VV, @Msg.V, DefaultLocale_VariantConv, VARIANT_NOVALUEPROP Or VARIANT_ALPHABOOL, vbString), "SimpleVariant.MsgBox"
		Function = MessageBoxW(GetActiveWindow, VV.bstrVal, AppName, Flags)
		VariantClear @VV
	End If
End Function

#define Set
#define Nothing 0
