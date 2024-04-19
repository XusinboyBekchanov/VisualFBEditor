'Speech.bi
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "Speech.bi"
#include once "mff/ComboBoxEdit.bi"

Using My.Sys.Forms
Using Speech

Private Sub CreateInstance(sCLSID As String, sIID As String, rtn As Any Ptr)
	
	'创建识别器实例
	Dim classID As GUID, riid As GUID
	CLSIDFromString(sCLSID, @classID)
	IIDFromString(sIID, @riid)
	
	Debug.Print "CoCreateInstance:          " & CoCreateInstance(@classID, NULL, CLSCTX_ALL, @riid, @rtn)
End Sub

Private Sub TokenCategory2Cob(ByVal pszCategoryId As WString Ptr, ByRef cob As ComboBoxEdit)
	Debug.Print *pszCategoryId
	Dim ClassID As GUID, RIid As GUID
	CLSIDFromString(CLSID_SpObjectTokenCategory, @classID)
	IIDFromString(IID_ISpObjectTokenCategory, @RIid)
	Dim As ISpObjectTokenCategory Ptr pSpObjectTokenCategory
	Debug.Print "CoCreateInstance:          " & CoCreateInstance(@ClassID, NULL, CLSCTX_ALL, @RIid, @pSpObjectTokenCategory)
	Debug.Print "pSpObjectTokenCategory:    " & pSpObjectTokenCategory
	Debug.Print "SetId:                     " & pSpObjectTokenCategory->SetId(pszCategoryId, False)
	
	Dim As IEnumSpObjectTokens Ptr pEnumTokens
	Debug.Print "EnumTokens:                " & pSpObjectTokenCategory->EnumTokens(NULL, NULL, @pEnumTokens)
	Dim pCount As ULong
	Dim mwstr As WString Ptr
	Debug.Print "GetCount:                  " & pEnumTokens->GetCount(@pCount)
	cob.Clear
	
	If pCount > 0 Then
		cob.Enabled = True
		Dim pToken As ISpObjectToken Ptr
		Dim i As Integer
		For i = 0 To pCount-1
			pEnumTokens->Item(i, @pToken)
			pToken->GetStringValue(NULL, @mwstr)
			cob.AddItem *mwstr
			cob.ItemData(cob.ItemCount - 1) = pToken
		Next
		cob.ItemIndex = 0
	Else
		cob.Enabled = False
	End If
	pEnumTokens->Release()
	pSpObjectTokenCategory->Release()
End Sub

Private Sub ObjectToken2Cob(pToken As ISpObjectToken Ptr, ByRef cob As ComboBoxEdit)
	cob.Clear
	If pToken Then
		Dim mWStr As WString Ptr
		Dim pTokenCategory As ISpObjectTokenCategory Ptr
		Dim pTokenEnum As IEnumSpObjectTokens Ptr
		Dim pTokenItem As ISpObjectToken Ptr
		Dim pCount As Long
		Dim i As Integer
		
		cob.Enabled = True
		pToken->GetCategory(@pTokenCategory)
		pTokenCategory->EnumTokens(NULL, NULL, @pTokenEnum)
		pTokenEnum->GetCount(@pCount)
		For i = 0 To pCount - 1
			pTokenEnum->Item(i, @pTokenItem)
			pTokenItem->GetStringValue(NULL, @mWStr)
			cob.AddItem (*mWStr)
			cob.ItemData(i) = pTokenItem
		Next
		pTokenEnum->Release()
		pTokenCategory->Release()
	Else
		cob.Enabled = False
	End If
End Sub


