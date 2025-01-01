#define INITGUID

#include once "windows.bi"
#include once "win/ocidl.bi"

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

Function BstrToStr(ByVal szW As BSTR) As String
	Static szA As ZString * 256
	If szW = NULL Then Return ""
	WideCharToMultiByte(CP_ACP, 0, szW, -1, szA, 256, NULL, NULL)
	Return szA
End Function

#define W2Ansi(A, W)  WideCharToMultiByte(CP_ACP, 0, W, -1, A, 2047, 0, 0)
#define A2Wide(A, W, L)  MultiByteToWideChar(CP_ACP, 0, A, -1, W, L)

Function UnicodeToAnsi(ByVal szW As OLECHAR Ptr) As String
	Static szA As ZString * 256
	If szW = NULL Then Return ""
	WideCharToMultiByte(CP_ACP, 0, szW, -1, szA, 256, NULL, NULL)
	Return szA
End Function

Function AnsiToUnicode(A As String) As OLECHAR Ptr
	Dim W As  OLECHAR Ptr
	Dim length As Integer
	length = (2 * Len(A)) + 1
	A2Wide(StrPtr(A), W, length)
	Return W
End Function

/' Convert a string to a GUID '/

Function StringToGUID(S As Const String) As GUID
	Dim Result As GUID
	CLSIDFromString(WStr(S), @Result)
	Return Result
End Function

/' Convert a GUID to a string '/

Function GUIDToString(ClassID As GUID) As String
	Dim P As WString Ptr
	StringFromCLSID(@ClassID, Cast(LPOLESTR Ptr, @P))
	GUIDToString = *P
	CoTaskMemFree(P)
End Function

/' Convert a programmatic ID to a class ID '/

Function ProgIDToClassID( ProgID As Const String) As GUID
	Dim Result As GUID
	CLSIDFromProgID(WStr(ProgID), @Result)
	Return Result
End Function

/' Convert a class ID to a programmatic ID '/

Function ClassIDToProgID(ClassID As GUID) As String
	Dim P As WString Ptr
	
	ProgIDFromCLSID(@ClassID, Cast(LPOLESTR Ptr, @P))
	ClassIDToProgID = *P
	CoTaskMemFree(P)
End Function

Function CreateComObject(ClassID As GUID) As IUnknown Ptr
	Dim Result As IUnknown
	CoCreateInstance(@ClassID, NULL, CLSCTX_INPROC_SERVER Or CLSCTX_LOCAL_SERVER, @IID_IUnknown, @Result)
	Return @Result
End Function

Function CreateOleObject(ClassName As Const  String) As IDispatch Ptr
	Dim Result As IDispatch
	Dim ClassID As CLSID
	ClassID = ProgIDToClassID(ClassName)
	CoCreateInstance(@ClassID, NULL, CLSCTX_INPROC_SERVER Or CLSCTX_LOCAL_SERVER, @IID_IDispatch, @Result)
	Return  @Result
End Function

Sub CreateObject Overload(ByVal strProgID As String, ByRef ppv As LPVOID, ByVal clsctx As Integer = CLSCTX_INPROC_SERVER Or CLSCTX_LOCAL_SERVER Or CLSCTX_REMOTE_SERVER)
	Dim pDispatch As IDispatch Ptr
	Dim pUnknown As IUnknown Ptr
	Dim hr As HRESULT
	Dim ClassID As CLSID
	ClassID = ProgIDToClassID(strProgID)
	
	hr = CoCreateInstance(@ClassID, NULL, clsctx, @IID_IUnknown, @pUnknown)
	If hr <> 0 Or pUnknown = 0 Then Exit Sub
	
	' Ask for the dispatch interface
	hr = IUnknown_QueryInterface(pUnknown, @IID_IDispatch, @pDispatch)
	' If it fails, return the Iunknown interface
	If hr <> 0 Or pDispatch = 0 Then
		ppv = pUnknown
		Exit Sub
	End If
	' Release the IUnknown interface
	IUnknown_Release(pUnknown)
	' Return a pointer to the dispatch interface
	ppv = pDispatch
	
End Sub

Function CreateObject (ByVal strProgID As String, ByVal clsctx As Integer = CLSCTX_INPROC_SERVER Or CLSCTX_LOCAL_SERVER Or CLSCTX_REMOTE_SERVER) As LPVOID
	Dim pDispatch As IDispatch Ptr
	Dim pUnknown As IUnknown Ptr
	Dim ppv As LPVOID
	Dim hr As HRESULT
	Dim ClassID As CLSID
	ClassID = ProgIDToClassID(strProgID)
	
	hr = CoCreateInstance(@ClassID, NULL, clsctx, @IID_IUnknown, @pUnknown)
	If hr <> 0 Or pUnknown = 0 Then Return NULL
	
	' Ask for the dispatch interface
	hr = IUnknown_QueryInterface(pUnknown, @IID_IDispatch, @pDispatch)
	' If it fails, return the Iunknown interface
	If hr <> 0 Or pDispatch = 0 Then
		Return pUnknown
	End If

	' Release the IUnknown interface
	IUnknown_Release(pUnknown)
	
	' Return a pointer to the dispatch interface
	Return pDispatch
	
End Function

#include once "WellCOM_Constant.bi"
#include once "WellCOM2.0_vtable.bi"

Dim g As IObject

CoInitialize(NULL)
g = CreateObject("WellCOM.Object")

If (g <> NULL) Then
	
	Dim As LPOLESTR bStrSet = StringToBSTR("AYELMA 2012")
	Dim As LPOLESTR bStrGet = NULL
	
	g->lpvtbl->putstring(g, bStrSet)
	g->lpvtbl->getstring(g, @bStrGet)
	
	Print "Getting a string from COM: "; BstrToStr(bStrGet)
	
	SysFreeString(bStrSet)
	SysFreeString(bStrGet)
	
	g->lpvtbl->Release(g)
	
Else
	
	Print "UNABLE TO LAUNCH THE DLL OBJECT"
	
End If

CoUninitialize()
Sleep

