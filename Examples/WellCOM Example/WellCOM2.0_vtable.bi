'================================================================================
'vTable - WellCOM 2.0 type library
'GUID={26A8002A-83D7-45EB-98E1-09CF47A40EE3}
'================================================================================
'================================================================================
'CLSID - WellCOM 2.0 type library
'================================================================================
Const CLSID_CoObject="{F2E0AC34-64BA-4871-BBFC-B9DE5BD9C80B}"     'IObject object.
'================================================================================
'ProgID - WellCOM 2.0 type library
'================================================================================
Const ProgID_CoObject="WellCOM.Object"

'================================================================================
'Interface IObject     ?
Const IID_IObject="{2A2AF189-C5A1-4A4E-9277-B4FD871A5119}"
'================================================================================
Type IObjectvTbl
   QueryInterface As Function (ByVal pThis As Any Ptr,ByRef riid As GUID,ByRef ppvObj As Dword) As hResult
   AddRef As Function (ByVal pThis As Any Ptr) As hResult
   Release As Function (ByVal pThis As Any Ptr) As hResult
   GetTypeInfoCount As Function (ByVal pThis As Any Ptr,ByRef pctinfo As UInteger) As hResult
   GetTypeInfo As Function (ByVal pThis As Any Ptr,ByVal itinfo As UInteger,ByVal lcid As UInteger,ByRef pptinfo As Any Ptr) As hResult
   GetIDsOfNames As Function (ByVal pThis As Any Ptr,ByVal riid As GUID,ByVal rgszNames As Byte,ByVal cNames As UInteger,ByVal lcid As UInteger,ByRef rgdispid As Integer) As hResult
   Invoke As Function (ByVal pThis As Any Ptr,ByVal dispidMember As Integer,ByVal riid As GUID,ByVal lcid As UInteger,ByVal wFlags As UShort,ByVal pdispparams As DISPPARAMS,ByRef pvarResult As Variant,ByRef pexcepinfo As EXCEPINFO,ByRef puArgErr As UInteger) As hResult
   putstring As Function(pThis As Any Ptr,Val As BSTR) As HRESULT     'Sets the test string.
   getstring As Function(pThis As Any Ptr,Val As BSTR Ptr) As HRESULT     'Sets the test string.
End Type

Type IObject_
   lpvtbl As IObjectvTbl Ptr
End Type

