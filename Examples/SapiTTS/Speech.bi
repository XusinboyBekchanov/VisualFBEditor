' ########################################################################################
' Microsoft Windows
' File: AfxSapi.bi
' Portions Copyright (c) Microsoft Corporation.
' Compiler: Free Basic 32 & 64 bit
' Copyright (c) 2017 José Roca. Freeware. Use at your own risk.
' THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
' EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF
' MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
' ########################################################################################

' ########################################################################################
' Library name: SpeechLib
' Documentation string: Microsoft Speech Object Library
' GUID: {C866CA3A-32F7-11D2-9602-00C04F8EE628}
' Version: 5.4, Locale ID = 0
' Path: C:\Windows\System32\Speech\Common\sapi.dll
' Attributes: 8 [&h00000008]  [HasDiskImage]
' ########################################################################################

' Modify by CM.Wang 2023/7/18

#pragma once

#include once "win/ole2.bi"
#include once "win/unknwnbase.bi"
#include once "win/ocidl.bi"

Namespace Speech
	
	#ifndef ___IUnknown_INTERFACE_DEFINED__
		#define ___IUnknown_INTERFACE_DEFINED__
		Type Afx_IUnknown As Afx_IUnknown_
		Type Afx_IUnknown_ Extends Object
			Declare Abstract Function QueryInterface (ByVal riid As REFIID, ByVal ppvObject As LPVOID Ptr) As HRESULT
			Declare Abstract Function AddRef () As ULong
			Declare Abstract Function Release () As ULong
		End Type
		Type AFX_LPUNKNOWN As Afx_IUnknown Ptr
	#endif
	
	#ifndef ___IDispatch_INTERFACE_DEFINED__
		#define ___IDispatch_INTERFACE_DEFINED__
		Type Afx_IDispatch As Afx_IDispatch_
		Type Afx_IDispatch_  Extends Afx_IUnknown
			Declare Abstract Function GetTypeInfoCount (ByVal pctinfo As UINT Ptr) As HRESULT
			Declare Abstract Function GetTypeInfo (ByVal iTInfo As UINT, ByVal lcid As LCID, ByVal ppTInfo As ITypeInfo Ptr Ptr) As HRESULT
			Declare Abstract Function GetIDsOfNames (ByVal riid As Const IID Const Ptr, ByVal rgszNames As LPOLESTR Ptr, ByVal cNames As UINT, ByVal lcid As LCID, ByVal rgDispId As DISPID Ptr) As HRESULT
			Declare Abstract Function Invoke (ByVal dispIdMember As DISPID, ByVal riid As Const IID Const Ptr, ByVal lcid As LCID, ByVal wFlags As WORD, ByVal pDispParams As DISPPARAMS Ptr, ByVal pVarResult As VARIANT Ptr, ByVal pExcepInfo As EXCEPINFO Ptr, ByVal puArgErr As UINT Ptr) As HRESULT
		End Type
		Type AFX_LPDISPATCH As Afx_IDispatch Ptr
	#endif
	
	' // The definition for BSTR in the FreeBASIC headers was inconveniently changed to WCHAR
	#ifndef AFX_BSTR
		#define AFX_BSTR WString Ptr
	#endif
	
	Const AFX_LIBID_SpeechLib = "{C866CA3A-32F7-11D2-9602-00C04F8EE628}"
	
	' ========================================================================================
	' ProgIDs (Program identifiers)
	' ========================================================================================
	
	' CLSID = {9EF96870-E160-4792-820D-48CF0649E4EC}
	Const AFX_PROGID_SAPI_SpAudioFormat_1 = "SAPI.SpAudioFormat.1"
	' CLSID = {90903716-2F42-11D3-9C26-00C04F8EF87C}
	Const AFX_PROGID_SAPI_SpCompressedLexicon_1 = "SAPI.SpCompressedLexicon.1"
	' CLSID = {8DBEF13F-1948-4AA8-8CF0-048EEBED95D8}
	Const AFX_PROGID_SAPI_SpCustomStream_1 = "SAPI.SpCustomStream.1"
	' CLSID = {947812B3-2AE1-4644-BA86-9E90DED7EC91}
	Const AFX_PROGID_SAPI_SpFileStream_1 = "SAPI.SpFileStream.1"
	' CLSID = {73AD6842-ACE0-45E8-A4DD-8795881A2C2A}
	Const AFX_PROGID_SAPI_SpInProcRecoContext_1 = "SAPI.SpInProcRecoContext.1"
	' CLSID = {41B89B6B-9399-11D2-9623-00C04F8EE628}
	Const AFX_PROGID_Sapi_SpInprocRecognizer_1 = "Sapi.SpInprocRecognizer.1"
	' CLSID = {0655E396-25D0-11D3-9C26-00C04F8EF87C}
	Const AFX_PROGID_SAPI_SpLexicon_1 = "SAPI.SpLexicon.1"
	' CLSID = {5FB7EF7D-DFF4-468A-B6B7-2FCBD188F994}
	Const AFX_PROGID_SAPI_SpMemoryStream_1 = "SAPI.SpMemoryStream.1"
	' CLSID = {AB1890A0-E91F-11D2-BB91-00C04F8EE6C0}
	Const AFX_PROGID_SAPI_SpMMAudioEnum_1 = "SAPI.SpMMAudioEnum.1"
	' CLSID = {CF3D2E50-53F2-11D2-960C-00C04F8EE628}
	Const AFX_PROGID_SAPI_SpMMAudioIn_1 = "SAPI.SpMMAudioIn.1"
	' CLSID = {A8C680EB-3D32-11D2-9EE7-00C04F797396}
	Const AFX_PROGID_SAPI_SpMMAudioOut_1 = "SAPI.SpMMAudioOut.1"
	' CLSID = {E2AE5372-5D40-11D2-960E-00C04F8EE628}
	Const AFX_PROGID_SAPI_SpNotifyTranslator_1 = "SAPI.SpNotifyTranslator.1"
	' CLSID = {455F24E9-7396-4A16-9715-7C0FDBE3EFE3}
	Const AFX_PROGID_SAPI_SpNullPhoneConverter_1 = "SAPI.SpNullPhoneConverter.1"
	' CLSID = {EF411752-3736-4CB4-9C8C-8EF4CCB58EFE}
	Const AFX_PROGID_SAPI_SpObjectToken_1 = "SAPI.SpObjectToken.1"
	' CLSID = {A910187F-0C7A-45AC-92CC-59EDAFB77B53}
	Const AFX_PROGID_SAPI_SpObjectTokenCategory_1 = "SAPI.SpObjectTokenCategory.1"
	' CLSID = {9185F743-1143-4C28-86B5-BFF14F20E5C8}
	Const AFX_PROGID_SAPI_SpPhoneConverter_1 = "SAPI.SpPhoneConverter.1"
	' CLSID = {C23FC28D-C55F-4720-8B32-91F73C2BD5D1}
	Const AFX_PROGID_SAPI_SpPhraseInfoBuilder_1 = "SAPI.SpPhraseInfoBuilder.1"
	' CLSID = {96749373-3391-11D2-9EE3-00C04F797396}
	Const AFX_PROGID_SAPI_SpResourceManager_1 = "SAPI.SpResourceManager.1"
	' CLSID = {47206204-5ECA-11D2-960F-00C04F8EE628}
	Const AFX_PROGID_SAPI_SpSharedRecoContext_1 = "SAPI.SpSharedRecoContext.1"
	' CLSID = {3BEE4890-4FE9-4A37-8C1E-5E7E12791C1F}
	Const AFX_PROGID_Sapi_SpSharedRecognizer_1 = "Sapi.SpSharedRecognizer.1"
	' CLSID = {0D722F1A-9FCF-4E62-96D8-6DF8F01A26AA}
	Const AFX_PROGID_SAPI_SpShortcut_1 = "SAPI.SpShortcut.1"
	' CLSID = {715D9C59-4442-11D2-9605-00C04F8EE628}
	Const AFX_PROGID_SAPI_SpStream_1 = "SAPI.SpStream.1"
	' CLSID = {7013943A-E2EC-11D2-A086-00C04F8EF9B5}
	Const AFX_PROGID_SAPI_SpStreamFormatConverter_1 = "SAPI.SpStreamFormatConverter.1"
	' CLSID = {0F92030A-CBFD-4AB8-A164-FF5985547FF6}
	Const AFX_PROGID_SAPI_SpTextSelectionInformation_1 = "SAPI.SpTextSelectionInformation.1"
	' CLSID = {C9E37C15-DF92-4727-85D6-72E5EEB6995A}
	Const AFX_PROGID_SAPI_SpUncompressedLexicon_1 = "SAPI.SpUncompressedLexicon.1"
	' CLSID = {96749377-3391-11D2-9EE3-00C04F797396}
	Const AFX_PROGID_SAPI_SpVoice_1 = "SAPI.SpVoice.1"
	' CLSID = {C79A574C-63BE-44B9-801F-283F87F898BE}
	Const AFX_PROGID_SAPI_SpWaveFormatEx_1 = "SAPI.SpWaveFormatEx.1"
	
	' ========================================================================================
	' Version Independent ProgIDs
	' ========================================================================================
	
	' CLSID = {9EF96870-E160-4792-820D-48CF0649E4EC}
	Const AFX_PROGID_SAPI_SpAudioFormat = "SAPI.SpAudioFormat"
	' CLSID = {90903716-2F42-11D3-9C26-00C04F8EF87C}
	Const AFX_PROGID_SAPI_SpCompressedLexicon = "SAPI.SpCompressedLexicon"
	' CLSID = {8DBEF13F-1948-4AA8-8CF0-048EEBED95D8}
	Const AFX_PROGID_SAPI_SpCustomStream = "SAPI.SpCustomStream"
	' CLSID = {947812B3-2AE1-4644-BA86-9E90DED7EC91}
	Const AFX_PROGID_SAPI_SpFileStream = "SAPI.SpFileStream"
	' CLSID = {73AD6842-ACE0-45E8-A4DD-8795881A2C2A}
	Const AFX_PROGID_SAPI_SpInProcRecoContext = "SAPI.SpInProcRecoContext"
	' CLSID = {41B89B6B-9399-11D2-9623-00C04F8EE628}
	Const AFX_PROGID_Sapi_SpInprocRecognizer = "Sapi.SpInprocRecognizer"
	' CLSID = {0655E396-25D0-11D3-9C26-00C04F8EF87C}
	Const AFX_PROGID_SAPI_SpLexicon = "SAPI.SpLexicon"
	' CLSID = {5FB7EF7D-DFF4-468A-B6B7-2FCBD188F994}
	Const AFX_PROGID_SAPI_SpMemoryStream = "SAPI.SpMemoryStream"
	' CLSID = {AB1890A0-E91F-11D2-BB91-00C04F8EE6C0}
	Const AFX_PROGID_SAPI_SpMMAudioEnum = "SAPI.SpMMAudioEnum"
	' CLSID = {CF3D2E50-53F2-11D2-960C-00C04F8EE628}
	Const AFX_PROGID_SAPI_SpMMAudioIn = "SAPI.SpMMAudioIn"
	' CLSID = {A8C680EB-3D32-11D2-9EE7-00C04F797396}
	Const AFX_PROGID_SAPI_SpMMAudioOut = "SAPI.SpMMAudioOut"
	' CLSID = {E2AE5372-5D40-11D2-960E-00C04F8EE628}
	Const AFX_PROGID_SAPI_SpNotifyTranslator = "SAPI.SpNotifyTranslator"
	' CLSID = {455F24E9-7396-4A16-9715-7C0FDBE3EFE3}
	Const AFX_PROGID_SAPI_SpNullPhoneConverter = "SAPI.SpNullPhoneConverter"
	' CLSID = {EF411752-3736-4CB4-9C8C-8EF4CCB58EFE}
	Const AFX_PROGID_SAPI_SpObjectToken = "SAPI.SpObjectToken"
	' CLSID = {A910187F-0C7A-45AC-92CC-59EDAFB77B53}
	Const AFX_PROGID_SAPI_SpObjectTokenCategory = "SAPI.SpObjectTokenCategory"
	' CLSID = {9185F743-1143-4C28-86B5-BFF14F20E5C8}
	CONST AFX_PROGID_SAPI_SpPhoneConverter = "SAPI.SpPhoneConverter"
	' CLSID = {C23FC28D-C55F-4720-8B32-91F73C2BD5D1}
	CONST AFX_PROGID_SAPI_SpPhraseInfoBuilder = "SAPI.SpPhraseInfoBuilder"
	' CLSID = {96749373-3391-11D2-9EE3-00C04F797396}
	CONST AFX_PROGID_SAPI_SpResourceManager = "SAPI.SpResourceManager"
	' CLSID = {47206204-5ECA-11D2-960F-00C04F8EE628}
	CONST AFX_PROGID_SAPI_SpSharedRecoContext = "SAPI.SpSharedRecoContext"
	' CLSID = {3BEE4890-4FE9-4A37-8C1E-5E7E12791C1F}
	CONST AFX_PROGID_Sapi_SpSharedRecognizer = "Sapi.SpSharedRecognizer"
	' CLSID = {0D722F1A-9FCF-4E62-96D8-6DF8F01A26AA}
	CONST AFX_PROGID_SAPI_SpShortcut = "SAPI.SpShortcut"
	' CLSID = {715D9C59-4442-11D2-9605-00C04F8EE628}
	CONST AFX_PROGID_SAPI_SpStream = "SAPI.SpStream"
	' CLSID = {7013943A-E2EC-11D2-A086-00C04F8EF9B5}
	CONST AFX_PROGID_SAPI_SpStreamFormatConverter = "SAPI.SpStreamFormatConverter"
	' CLSID = {0F92030A-CBFD-4AB8-A164-FF5985547FF6}
	CONST AFX_PROGID_SAPI_SpTextSelectionInformation = "SAPI.SpTextSelectionInformation"
	' CLSID = {C9E37C15-DF92-4727-85D6-72E5EEB6995A}
	CONST AFX_PROGID_SAPI_SpUncompressedLexicon = "SAPI.SpUncompressedLexicon"
	' CLSID = {96749377-3391-11D2-9EE3-00C04F797396}
	CONST AFX_PROGID_SAPI_SpVoice = "SAPI.SpVoice"
	' CLSID = {C79A574C-63BE-44B9-801F-283F87F898BE}
	CONST AFX_PROGID_SAPI_SpWaveFormatEx = "SAPI.SpWaveFormatEx"
	
	' ========================================================================================
	' ClsIDs (Class identifiers)
	' ========================================================================================
	
	CONST AFX_CLSID_SpAudioFormat = "{9EF96870-E160-4792-820D-48CF0649E4EC}"
	CONST AFX_CLSID_SpCompressedLexicon = "{90903716-2F42-11D3-9C26-00C04F8EF87C}"
	CONST AFX_CLSID_SpCustomStream = "{8DBEF13F-1948-4AA8-8CF0-048EEBED95D8}"
	CONST AFX_CLSID_SpFileStream = "{947812B3-2AE1-4644-BA86-9E90DED7EC91}"
	CONST AFX_CLSID_SpInProcRecoContext = "{73AD6842-ACE0-45E8-A4DD-8795881A2C2A}"
	Const AFX_CLSID_SpInprocRecognizer = "{41B89B6B-9399-11D2-9623-00C04F8EE628}"
	Const AFX_CLSID_SpLexicon = "{0655E396-25D0-11D3-9C26-00C04F8EF87C}"
	Const AFX_CLSID_SpMemoryStream = "{5FB7EF7D-DFF4-468A-B6B7-2FCBD188F994}"
	Const AFX_CLSID_SpMMAudioEnum = "{AB1890A0-E91F-11D2-BB91-00C04F8EE6C0}"
	Const AFX_CLSID_SpMMAudioIn = "{CF3D2E50-53F2-11D2-960C-00C04F8EE628}"
	Const AFX_CLSID_SpMMAudioOut = "{A8C680EB-3D32-11D2-9EE7-00C04F797396}"
	Const AFX_CLSID_SpNotifyTranslator = "{E2AE5372-5D40-11D2-960E-00C04F8EE628}"
	Const AFX_CLSID_SpNullPhoneConverter = "{455F24E9-7396-4A16-9715-7C0FDBE3EFE3}"
	Const AFX_CLSID_SpObjectToken = "{EF411752-3736-4CB4-9C8C-8EF4CCB58EFE}"
	Const AFX_CLSID_SpObjectTokenCategory = "{A910187F-0C7A-45AC-92CC-59EDAFB77B53}"
	Const AFX_CLSID_SpPhoneConverter = "{9185F743-1143-4C28-86B5-BFF14F20E5C8}"
	Const AFX_CLSID_SpPhoneticAlphabetConverter = "{4F414126-DFE3-4629-99EE-797978317EAD}"
	Const AFX_CLSID_SpPhraseInfoBuilder = "{C23FC28D-C55F-4720-8B32-91F73C2BD5D1}"
	Const AFX_CLSID_SpResourceManager = "{96749373-3391-11D2-9EE3-00C04F797396}"
	Const AFX_CLSID_SpSharedRecoContext = "{47206204-5ECA-11D2-960F-00C04F8EE628}"
	Const AFX_CLSID_SpSharedRecognizer = "{3BEE4890-4FE9-4A37-8C1E-5E7E12791C1F}"
	Const AFX_CLSID_SpShortcut = "{0D722F1A-9FCF-4E62-96D8-6DF8F01A26AA}"
	Const AFX_CLSID_SpStream = "{715D9C59-4442-11D2-9605-00C04F8EE628}"
	Const AFX_CLSID_SpStreamFormatConverter = "{7013943A-E2EC-11D2-A086-00C04F8EF9B5}"
	Const AFX_CLSID_SpTextSelectionInformation = "{0F92030A-CBFD-4AB8-A164-FF5985547FF6}"
	Const AFX_CLSID_SpUnCompressedLexicon = "{C9E37C15-DF92-4727-85D6-72E5EEB6995A}"
	Const AFX_CLSID_SpVoice = "{96749377-3391-11D2-9EE3-00C04F797396}"
	Const AFX_CLSID_SpWaveFormatEx = "{C79A574C-63BE-44B9-801F-283F87F898BE}"
	
	' ========================================================================================
	' IIDs (Interface identifiers)
	' ========================================================================================
	
	Const AFX_IID_IEnumSpObjectTokens = "{06B64F9E-7FDA-11D2-B4F2-00C04F797396}"
	Const AFX_IID_ISpAudio = "{C05C768F-FAE8-4EC2-8E07-338321C12452}"
	Const AFX_IID_ISpDataKey = "{14056581-E16C-11D2-BB90-00C04F8EE6C0}"
	Const AFX_IID_ISpeechAudio = "{CFF8E175-019E-11D3-A08E-00C04F8EF9B5}"
	Const AFX_IID_ISpeechAudioBufferInfo = "{11B103D8-1142-4EDF-A093-82FB3915F8CC}"
	Const AFX_IID_ISpeechAudioFormat = "{E6E9C590-3E18-40E3-8299-061F98BDE7C7}"
	Const AFX_IID_ISpeechAudioStatus = "{C62D9C91-7458-47F6-862D-1EF86FB0B278}"
	Const AFX_IID_ISpeechBaseStream = "{6450336F-7D49-4CED-8097-49D6DEE37294}"
	Const AFX_IID_ISpeechCustomStream = "{1A9E9F4F-104F-4DB8-A115-EFD7FD0C97AE}"
	Const AFX_IID_ISpeechDataKey = "{CE17C09B-4EFA-44D5-A4C9-59D9585AB0CD}"
	Const AFX_IID_ISpeechFileStream = "{AF67F125-AB39-4E93-B4A2-CC2E66E182A7}"
	Const AFX_IID_ISpeechGrammarRule = "{AFE719CF-5DD1-44F2-999C-7A399F1CFCCC}"
	Const AFX_IID_ISpeechGrammarRules = "{6FFA3B44-FC2D-40D1-8AFC-32911C7F1AD1}"
	Const AFX_IID_ISpeechGrammarRuleState = "{D4286F2C-EE67-45AE-B928-28D695362EDA}"
	Const AFX_IID_ISpeechGrammarRuleStateTransition = "{CAFD1DB1-41D1-4A06-9863-E2E81DA17A9A}"
	Const AFX_IID_ISpeechGrammarRuleStateTransitions = "{EABCE657-75BC-44A2-AA7F-C56476742963}"
	Const AFX_IID_ISpeechLexicon = "{3DA7627A-C7AE-4B23-8708-638C50362C25}"
	Const AFX_IID_ISpeechLexiconPronunciation = "{95252C5D-9E43-4F4A-9899-48EE73352F9F}"
	Const AFX_IID_ISpeechLexiconPronunciations = "{72829128-5682-4704-A0D4-3E2BB6F2EAD3}"
	Const AFX_IID_ISpeechLexiconWord = "{4E5B933C-C9BE-48ED-8842-1EE51BB1D4FF}"
	Const AFX_IID_ISpeechLexiconWords = "{8D199862-415E-47D5-AC4F-FAA608B424E6}"
	Const AFX_IID_ISpeechMemoryStream = "{EEB14B68-808B-4ABE-A5EA-B51DA7588008}"
	Const AFX_IID_ISpeechMMSysAudio = "{3C76AF6D-1FD7-4831-81D1-3B71D5A13C44}"
	Const AFX_IID_ISpeechObjectToken = "{C74A3ADC-B727-4500-A84A-B526721C8B8C}"
	Const AFX_IID_ISpeechObjectTokenCategory = "{CA7EAC50-2D01-4145-86D4-5AE7D70F4469}"
	Const AFX_IID_ISpeechObjectTokens = "{9285B776-2E7B-4BC0-B53E-580EB6FA967F}"
	Const AFX_IID_ISpeechPhoneConverter = "{C3E4F353-433F-43D6-89A1-6A62A7054C3D}"
	Const AFX_IID_ISpeechPhraseAlternate = "{27864A2A-2B9F-4CB8-92D3-0D2722FD1E73}"
	Const AFX_IID_ISpeechPhraseAlternates = "{B238B6D5-F276-4C3D-A6C1-2974801C3CC2}"
	Const AFX_IID_ISpeechPhraseElement = "{E6176F96-E373-4801-B223-3B62C068C0B4}"
	Const AFX_IID_ISpeechPhraseElements = "{0626B328-3478-467D-A0B3-D0853B93DDA3}"
	Const AFX_IID_ISpeechPhraseInfo = "{961559CF-4E67-4662-8BF0-D93F1FCD61B3}"
	Const AFX_IID_ISpeechPhraseInfoBuilder = "{3B151836-DF3A-4E0A-846C-D2ADC9334333}"
	Const AFX_IID_ISpeechPhraseProperties = "{08166B47-102E-4B23-A599-BDB98DBFD1F4}"
	Const AFX_IID_ISpeechPhraseProperty = "{CE563D48-961E-4732-A2E1-378A42B430BE}"
	Const AFX_IID_ISpeechPhraseReplacement = "{2890A410-53A7-4FB5-94EC-06D4998E3D02}"
	CONST AFX_IID_ISpeechPhraseReplacements = "{38BC662F-2257-4525-959E-2069D2596C05}"
	CONST AFX_IID_ISpeechPhraseRule = "{A7BFE112-A4A0-48D9-B602-C313843F6964}"
	CONST AFX_IID_ISpeechPhraseRules = "{9047D593-01DD-4B72-81A3-E4A0CA69F407}"
	CONST AFX_IID_ISpeechRecoContext = "{580AA49D-7E1E-4809-B8E2-57DA806104B8}"
	CONST AFX_IID_ISpeechRecognizer = "{2D5F1C0C-BD75-4B08-9478-3B11FEA2586C}"
	CONST AFX_IID_ISpeechRecognizerStatus = "{BFF9E781-53EC-484E-BB8A-0E1B5551E35C}"
	CONST AFX_IID_ISpeechRecoGrammar = "{B6D6F79F-2158-4E50-B5BC-9A9CCD852A09}"
	CONST AFX_IID_ISpeechRecoResult = "{ED2879CF-CED9-4EE6-A534-DE0191D5468D}"
	CONST AFX_IID_ISpeechRecoResult2 = "{8E0A246D-D3C8-45DE-8657-04290C458C3C}"
	CONST AFX_IID_ISpeechRecoResultDispatch = "{6D60EB64-ACED-40A6-BBF3-4E557F71DEE2}"
	CONST AFX_IID_ISpeechRecoResultTimes = "{62B3B8FB-F6E7-41BE-BDCB-056B1C29EFC0}"
	CONST AFX_IID_ISpeechResourceLoader = "{B9AC5783-FCD0-4B21-B119-B4F8DA8FD2C3}"
	CONST AFX_IID_ISpeechTextSelectionInformation = "{3B9C7E7A-6EEE-4DED-9092-11657279ADBE}"
	CONST AFX_IID_ISpeechVoice = "{269316D8-57BD-11D2-9EEE-00C04F797396}"
	CONST AFX_IID_ISpeechVoiceStatus = "{8BE47B07-57F6-11D2-9EEE-00C04F797396}"
	CONST AFX_IID_ISpeechWaveFormatEx = "{7A1EF0D5-1581-4741-88E4-209A49F11A10}"
	CONST AFX_IID_ISpeechXMLRecoResult = "{AAEC54AF-8F85-4924-944D-B79D39D72E19}"
	CONST AFX_IID_ISpEventSink = "{BE7A9CC9-5F9E-11D2-960F-00C04F8EE628}"
	CONST AFX_IID_ISpEventSource = "{BE7A9CCE-5F9E-11D2-960F-00C04F8EE628}"
	CONST AFX_IID_ISpGrammarBuilder = "{8137828F-591A-4A42-BE58-49EA7EBAAC68}"
	CONST AFX_IID_ISpLexicon = "{DA41A7C2-5383-4DB2-916B-6C1719E3DB58}"
	CONST AFX_IID_ISpMMSysAudio = "{15806F6E-1D70-4B48-98E6-3B1A007509AB}"
	CONST AFX_IID_ISpNotifySink = "{259684DC-37C3-11D2-9603-00C04F8EE628}"
	CONST AFX_IID_ISpNotifySource = "{5EFF4AEF-8487-11D2-961C-00C04F8EE628}"
	CONST AFX_IID_ISpNotifyTranslator = "{ACA16614-5D3D-11D2-960E-00C04F8EE628}"
	CONST AFX_IID_ISpObjectToken = "{14056589-E16C-11D2-BB90-00C04F8EE6C0}"
	CONST AFX_IID_ISpObjectTokenCategory = "{2D3D3845-39AF-4850-BBF9-40B49780011D}"
	CONST AFX_IID_ISpObjectWithToken = "{5B559F40-E952-11D2-BB91-00C04F8EE6C0}"
	CONST AFX_IID_ISpPhoneConverter = "{8445C581-0CAC-4A38-ABFE-9B2CE2826455}"
	CONST AFX_IID_ISpPhoneticAlphabetConverter = "{133ADCD4-19B4-4020-9FDC-842E78253B17}"
	CONST AFX_IID_ISpPhoneticAlphabetSelection = "{B2745EFD-42CE-48CA-81F1-A96E02538A90}"
	CONST AFX_IID_ISpPhrase = "{1A5C0354-B621-4B5A-8791-D306ED379E53}"
	CONST AFX_IID_ISpPhraseAlt = "{8FCEBC98-4E49-4067-9C6C-D86A0E092E3D}"
	CONST AFX_IID_ISpProperties = "{5B4FB971-B115-4DE1-AD97-E482E3BF6EE4}"
	CONST AFX_IID_ISpRecoCategory = "{DA0CD0F9-14A2-4F09-8C2A-85CC48979345}"
	CONST AFX_IID_ISpRecoContext = "{F740A62F-7C15-489E-8234-940A33D9272D}"
	CONST AFX_IID_ISpRecoContext2 = "{BEAD311C-52FF-437F-9464-6B21054CA73D}"
	CONST AFX_IID_ISpRecognizer = "{C2B5F241-DAA0-4507-9E16-5A1EAA2B7A5C}"
	CONST AFX_IID_ISpRecognizer2 = "{8FC6D974-C81E-4098-93C5-0147F61ED4D3}"
	CONST AFX_IID_ISpRecognizer3 = "{DF1B943C-5838-4AA2-8706-D7CD5B333499}"
	CONST AFX_IID_ISpRecoGrammar = "{2177DB29-7F45-47D0-8554-067E91C80502}"
	CONST AFX_IID_ISpRecoGrammar2 = "{4B37BC9E-9ED6-44A3-93D3-18F022B79EC3}"
	CONST AFX_IID_ISpRecoResult = "{20B053BE-E235-43CD-9A2A-8D17A48B7842}"
	CONST AFX_IID_ISpResourceManager = "{93384E18-5014-43D5-ADBB-A78E055926BD}"
	CONST AFX_IID_ISpSerializeState = "{21B501A0-0EC7-46C9-92C3-A2BC784C54B9}"
	CONST AFX_IID_ISpShortcut = "{3DF681E2-EA56-11D9-8BDE-F66BAD1E3F3A}"
	CONST AFX_IID_ISpStream = "{12E3CCA9-7518-44C5-A5E7-BA5A79CB929E}"
	CONST AFX_IID_ISpStreamFormat = "{BED530BE-2606-4F4D-A1C0-54C5CDA5566F}"
	CONST AFX_IID_ISpStreamFormatConverter = "{678A932C-EA71-4446-9B41-78FDA6280A29}"
	CONST AFX_IID_ISpVoice = "{6C44DF74-72B9-4992-A1EC-EF996E0422D4}"
	CONST AFX_IID_ISpXMLRecoResult = "{AE39362B-45A8-4074-9B9E-CCF49AA2D0B6}"
	CONST AFX_IID__Afx_ISpeechRecoContextEvents = "{7B8FCB42-0E9D-4F00-A048-7B04D6179D3D}"
	CONST AFX_IID__Afx_ISpeechVoiceEvents = "{A372ACD1-3BEF-4BBD-8FFB-CB3E2B416AF8}"
	
	' // Additional interfaces not included in the type library
	CONST AFX_IID_ISpContainerLexicon = "{8565572F-C094-41CC-B56E-10BD9C3FF044}"
	CONST AFX_IID_ISpEnginePronunciation = "{C360CE4B-76D1-4214-AD68-52657D5083DA}"
	CONST AFX_IID_ISpEventSource2 = "{2373A435-6A4B-429E-A6AC-D4231A61975B}"
	CONST AFX_IID_ISpGrammarBuilder2 = "{8AB10026-20CC-4B20-8C22-A49C9BA78F60}"
	CONST AFX_IID_ISpObjectTokenInit = "{B8AAB0CF-346F-49D8-9499-C8B03F161D51}"
	CONST AFX_IID_ISpPhrase2 = "{F264DA52-E457-4696-B856-A737B717AF79}"
	CONST AFX_IID_ISpRecoResult2 = "{27CAC6C4-88F2-41F2-8817-0C95E59F1E6E}"
	CONST AFX_IID_ISpRegDataKey = "{92A66E2B-C830-4149-83DF-6FC2BA1E7A5B}"
	CONST AFX_IID_ISpTranscript = "{10F63BCE-201A-11D3-AC70-00C04F8EE6C0}"
	
	' ========================================================================================
	' Aliases
	' ========================================================================================
	
	TYPE SPAUDIOSTATE AS _SPAUDIOSTATE
	TYPE SPPROPERTYINFO AS tagSPPROPERTYINFO
	TYPE SPSTREAMFORMATTYPE AS SPWAVEFORMATTYPE
	TYPE SPTEXTSELECTIONINFO AS tagSPTEXTSELECTIONINFO
	
	' ========================================================================================
	' Enumerations
	' ========================================================================================
	
	Enum _SPAUDIOSTATE
		' // Documentation string: Afx_ISpAudio Interface
		' // Number of constants: 4
		SPAS_CLOSED = 0   ' (&h00000000)
		SPAS_STOP = 1   ' (&h00000001)
		SPAS_PAUSE = 2   ' (&h00000002)
		SPAS_RUN = 3   ' (&h00000003)
	End Enum
	
	Enum DISPID_SpeechAudio
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 7
		DISPID_SAStatus = 200   ' (&h000000C8)
		DISPID_SABufferInfo = 201   ' (&h000000C9)
		DISPID_SADefaultFormat = 202   ' (&h000000CA)
		DISPID_SAVolume = 203   ' (&h000000CB)
		DISPID_SABufferNotifySize = 204   ' (&h000000CC)
		DISPID_SAEventHandle = 205   ' (&h000000CD)
		DISPID_SASetState = 206   ' (&h000000CE)
	End Enum
	
	Enum DISPID_SpeechAudioBufferInfo
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 3
		DISPID_SABIMinNotification = 1   ' (&h00000001)
		DISPID_SABIBufferSize = 2   ' (&h00000002)
		DISPID_SABIEventBias = 3   ' (&h00000003)
	End Enum
	
	Enum DISPID_SpeechAudioFormat
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 4
		DISPID_SAFType = 1   ' (&h00000001)
		DISPID_SAFGuid = 2   ' (&h00000002)
		DISPID_SAFGetWaveFormatEx = 3   ' (&h00000003)
		DISPID_SAFSetWaveFormatEx = 4   ' (&h00000004)
	End Enum
	
	ENUM DISPID_SpeechAudioStatus
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 5
		DISPID_SASFreeBufferSpace = 1   ' (&h00000001)
		DISPID_SASNonBlockingIO = 2   ' (&h00000002)
		DISPID_SASState = 3   ' (&h00000003)
		DISPID_SASCurrentSeekPosition = 4   ' (&h00000004)
		DISPID_SASCurrentDevicePosition = 5   ' (&h00000005)
	End Enum
	
	Enum DISPID_SpeechBaseStream
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 4
		DISPID_SBSFormat = 1   ' (&h00000001)
		DISPID_SBSRead = 2   ' (&h00000002)
		DISPID_SBSWrite = 3   ' (&h00000003)
		DISPID_SBSSeek = 4   ' (&h00000004)
	End Enum
	
	Enum DISPID_SpeechCustomStream
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 1
		DISPID_SCSBaseStream = 100   ' (&h00000064)
	End Enum
	
	'typedef long SpeechLanguageId;
	
	Enum DISPID_SpeechDataKey
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 12
		DISPID_SDKSetBinaryValue = 1   ' (&h00000001)
		DISPID_SDKGetBinaryValue = 2   ' (&h00000002)
		DISPID_SDKSetStringValue = 3   ' (&h00000003)
		DISPID_SDKGetStringValue = 4   ' (&h00000004)
		DISPID_SDKSetLongValue = 5   ' (&h00000005)
		DISPID_SDKGetlongValue = 6   ' (&h00000006)
		DISPID_SDKOpenKey = 7   ' (&h00000007)
		DISPID_SDKCreateKey = 8   ' (&h00000008)
		DISPID_SDKDeleteKey = 9   ' (&h00000009)
		DISPID_SDKDeleteValue = 10   ' (&h0000000A)
		DISPID_SDKEnumKeys = 11   ' (&h0000000B)
		DISPID_SDKEnumValues = 12   ' (&h0000000C)
	End Enum
	
	ENUM DISPID_SpeechFileStream
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 2
		DISPID_SFSOpen = 100   ' (&h00000064)
		DISPID_SFSClose = 101   ' (&h00000065)
	END ENUM
	
	ENUM DISPID_SpeechGrammarRule
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 7
		DISPID_SGRAttributes = 1   ' (&h00000001)
		DISPID_SGRInitialState = 2   ' (&h00000002)
		DISPID_SGRName = 3   ' (&h00000003)
		DISPID_SGRId = 4   ' (&h00000004)
		DISPID_SGRClear = 5   ' (&h00000005)
		DISPID_SGRAddResource = 6   ' (&h00000006)
		DISPID_SGRAddState = 7   ' (&h00000007)
	END ENUM
	
	ENUM DISPID_SpeechGrammarRules
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 8
		DISPID_SGRsCount = 1   ' (&h00000001)
		DISPID_SGRsDynamic = 2   ' (&h00000002)
		DISPID_SGRsAdd = 3   ' (&h00000003)
		DISPID_SGRsCommit = 4   ' (&h00000004)
		DISPID_SGRsCommitAndSave = 5   ' (&h00000005)
		DISPID_SGRsFindRule = 6   ' (&h00000006)
		DISPID_SGRsItem = 0   ' (&h00000000)
		DISPID_SGRs_NewEnum = -4   ' (&hFFFFFFFC)
	End Enum
	
	Enum DISPID_SpeechGrammarRuleState
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 5
		DISPID_SGRSRule = 1   ' (&h00000001)
		DISPID_SGRSTransitions = 2   ' (&h00000002)
		DISPID_SGRSAddWordTransition = 3   ' (&h00000003)
		DISPID_SGRSAddRuleTransition = 4   ' (&h00000004)
		DISPID_SGRSAddSpecialTransition = 5   ' (&h00000005)
	End Enum
	
	Enum DISPID_SpeechGrammarRuleStateTransition
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 8
		DISPID_SGRSTType = 1   ' (&h00000001)
		DISPID_SGRSTText = 2   ' (&h00000002)
		DISPID_SGRSTRule = 3   ' (&h00000003)
		DISPID_SGRSTWeight = 4   ' (&h00000004)
		DISPID_SGRSTPropertyName = 5   ' (&h00000005)
		DISPID_SGRSTPropertyId = 6   ' (&h00000006)
		DISPID_SGRSTPropertyValue = 7   ' (&h00000007)
		DISPID_SGRSTNextState = 8   ' (&h00000008)
	End Enum
	
	Enum DISPID_SpeechGrammarRuleStateTransitions
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 3
		DISPID_SGRSTsCount = 1   ' (&h00000001)
		DISPID_SGRSTsItem = 0   ' (&h00000000)
		DISPID_SGRSTs_NewEnum = -4   ' (&hFFFFFFFC)
	End Enum
	
	ENUM DISPID_SpeechLexicon
		' // Documentation string: Afx_ISpeechPhraseInfoBuilder Interface
		' // Number of constants: 8
		DISPID_SLGenerationId = 1   ' (&h00000001)
		DISPID_SLGetWords = 2   ' (&h00000002)
		DISPID_SLAddPronunciation = 3   ' (&h00000003)
		DISPID_SLAddPronunciationByPhoneIds = 4   ' (&h00000004)
		DISPID_SLRemovePronunciation = 5   ' (&h00000005)
		DISPID_SLRemovePronunciationByPhoneIds = 6   ' (&h00000006)
		DISPID_SLGetPronunciations = 7   ' (&h00000007)
		DISPID_SLGetGenerationChange = 8   ' (&h00000008)
	END ENUM
	
	ENUM DISPID_SpeechLexiconProns
		' // Documentation string: Afx_ISpeechPhraseInfoBuilder Interface
		' // Number of constants: 3
		DISPID_SLPsCount = 1   ' (&h00000001)
		DISPID_SLPsItem = 0   ' (&h00000000) DISPID_VALUE
		DISPID_SLPs_NewEnum = -4   ' (&hFFFFFFFC) DISPID_NEWENUM
	END ENUM
	
	ENUM DISPID_SpeechLexiconPronunciation
		' // Documentation string: Afx_ISpeechPhraseInfoBuilder Interface
		' // Number of constants: 5
		DISPID_SLPType = 1   ' (&h00000001)
		DISPID_SLPLangId = 2   ' (&h00000002)
		DISPID_SLPPartOfSpeech = 3   ' (&h00000003)
		DISPID_SLPPhoneIds = 4   ' (&h00000004)
		DISPID_SLPSymbolic = 5   ' (&h00000005)
	END ENUM
	
	ENUM DISPID_SpeechLexiconWord
		' // Documentation string: Afx_ISpeechPhraseInfoBuilder Interface
		' // Number of constants: 4
		DISPID_SLWLangId = 1   ' (&h00000001)
		DISPID_SLWType = 2   ' (&h00000002)
		DISPID_SLWWord = 3   ' (&h00000003)
		DISPID_SLWPronunciations = 4   ' (&h00000004)
	END ENUM
	
	ENUM DISPID_SpeechLexiconWords
		' // Documentation string: Afx_ISpeechPhraseInfoBuilder Interface
		' // Number of constants: 3
		DISPID_SLWsCount = 1   ' (&h00000001)
		DISPID_SLWsItem = 0   ' (&h00000000) DISPID_VALUE
		DISPID_SLWs_NewEnum = -4   ' (&hFFFFFFFC) DISPID_NEWENUM
	End Enum
	
	Enum DISPID_SpeechMemoryStream
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 2
		DISPID_SMSSetData = 100   ' (&h00000064)
		DISPID_SMSGetData = 101   ' (&h00000065)
	End Enum
	
	Enum DISPID_SpeechMMSysAudio
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 3
		DISPID_SMSADeviceId = 300   ' (&h0000012C)
		DISPID_SMSALineId = 301   ' (&h0000012D)
		DISPID_SMSAMMHandle = 302   ' (&h0000012E)
	End Enum
	
	Enum DISPID_SpeechObjectToken
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 13
		DISPID_SOTId = 1   ' (&h00000001)
		DISPID_SOTDataKey = 2   ' (&h00000002)
		DISPID_SOTCategory = 3   ' (&h00000003)
		DISPID_SOTGetDescription = 4   ' (&h00000004)
		DISPID_SOTSetId = 5   ' (&h00000005)
		DISPID_SOTGetAttribute = 6   ' (&h00000006)
		DISPID_SOTCreateInstance = 7   ' (&h00000007)
		DISPID_SOTRemove = 8   ' (&h00000008)
		DISPID_SOTGetStorageFileName = 9   ' (&h00000009)
		DISPID_SOTRemoveStorageFileName = 10   ' (&h0000000A)
		DISPID_SOTIsUISupported = 11   ' (&h0000000B)
		DISPID_SOTDisplayUI = 12   ' (&h0000000C)
		DISPID_SOTMatchesAttributes = 13   ' (&h0000000D)
	End Enum
	
	ENUM DISPID_SpeechObjectTokenCategory
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 5
		DISPID_SOTCId = 1   ' (&h00000001)
		DISPID_SOTCDefault = 2   ' (&h00000002)
		DISPID_SOTCSetId = 3   ' (&h00000003)
		DISPID_SOTCGetDataKey = 4   ' (&h00000004)
		DISPID_SOTCEnumerateTokens = 5   ' (&h00000005)
	END ENUM
	
	ENUM DISPID_SpeechObjectTokens
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 3
		DISPID_SOTsCount = 1   ' (&h00000001)
		DISPID_SOTsItem = 0   ' (&h00000000)
		DISPID_SOTs_NewEnum = -4   ' (&hFFFFFFFC)
	END ENUM
	
	ENUM DISPID_SpeechPhoneConverter
		' // Documentation string: Afx_ISpeechPhraseInfoBuilder Interface
		' // Number of constants: 3
		DISPID_SPCLangId = 1   ' (&h00000001)
		DISPID_SPCPhoneToId = 2   ' (&h00000002)
		DISPID_SPCIdToPhone = 3   ' (&h00000003)
	END ENUM
	
	ENUM DISPID_SpeechPhraseAlternate
		' // Documentation string: Afx_ISpeechPhraseInfoBuilder Interface
		' // Number of constants: 5
		DISPID_SPARecoResult = 1   ' (&h00000001)
		DISPID_SPAStartElementInResult = 2   ' (&h00000002)
		DISPID_SPANumberOfElementsInResult = 3   ' (&h00000003)
		DISPID_SPAPhraseInfo = 4   ' (&h00000004)
		DISPID_SPACommit = 5   ' (&h00000005)
	END ENUM
	
	ENUM DISPID_SpeechPhraseAlternates
		' // Documentation string: Afx_ISpeechPhraseInfoBuilder Interface
		' // Number of constants: 3
		DISPID_SPAsCount = 1   ' (&h00000001)
		DISPID_SPAsItem = 0   ' (&h00000000)
		DISPID_SPAs_NewEnum = -4   ' (&hFFFFFFFC)
	END ENUM
	
	ENUM DISPID_SpeechPhraseBuilder
		' // Documentation string: Afx_ISpeechRecoResultDispatch Interface
		' // Number of constants: 1
		DISPID_SPPBRestorePhraseFromMemory = 1   ' (&h00000001)
	END ENUM
	
	ENUM DISPID_SpeechPhraseElement
		' // Documentation string: Afx_ISpeechPhraseInfoBuilder Interface
		' // Number of constants: 13
		DISPID_SPEAudioTimeOffset = 1   ' (&h00000001)
		DISPID_SPEAudioSizeTime = 2   ' (&h00000002)
		DISPID_SPEAudioStreamOffset = 3   ' (&h00000003)
		DISPID_SPEAudioSizeBytes = 4   ' (&h00000004)
		DISPID_SPERetainedStreamOffset = 5   ' (&h00000005)
		DISPID_SPERetainedSizeBytes = 6   ' (&h00000006)
		DISPID_SPEDisplayText = 7   ' (&h00000007)
		DISPID_SPELexicalForm = 8   ' (&h00000008)
		DISPID_SPEPronunciation = 9   ' (&h00000009)
		DISPID_SPEDisplayAttributes = 10   ' (&h0000000A)
		DISPID_SPERequiredConfidence = 11   ' (&h0000000B)
		DISPID_SPEActualConfidence = 12   ' (&h0000000C)
		DISPID_SPEEngineConfidence = 13   ' (&h0000000D)
	END ENUM
	
	ENUM DISPID_SpeechPhraseElements
		' // Documentation string: Afx_ISpeechPhraseInfoBuilder Interface
		' // Number of constants: 3
		DISPID_SPEsCount = 1   ' (&h00000001)
		DISPID_SPEsItem = 0   ' (&h00000000)
		DISPID_SPEs_NewEnum = -4   ' (&hFFFFFFFC)
	END ENUM
	
	Enum DISPID_SpeechPhraseInfo
		' // Documentation string: Afx_ISpeechPhraseInfoBuilder Interface
		' // Number of constants: 16
		DISPID_SPILanguageId = 1   ' (&h00000001)
		DISPID_SPIGrammarId = 2   ' (&h00000002)
		DISPID_SPIStartTime = 3   ' (&h00000003)
		DISPID_SPIAudioStreamPosition = 4   ' (&h00000004)
		DISPID_SPIAudioSizeBytes = 5   ' (&h00000005)
		DISPID_SPIRetainedSizeBytes = 6   ' (&h00000006)
		DISPID_SPIAudioSizeTime = 7   ' (&h00000007)
		DISPID_SPIRule = 8   ' (&h00000008)
		DISPID_SPIProperties = 9   ' (&h00000009)
		DISPID_SPIElements = 10   ' (&h0000000A)
		DISPID_SPIReplacements = 11   ' (&h0000000B)
		DISPID_SPIEngineId = 12   ' (&h0000000C)
		DISPID_SPIEnginePrivateData = 13   ' (&h0000000D)
		DISPID_SPISaveToMemory = 14   ' (&h0000000E)
		DISPID_SPIGetText = 15   ' (&h0000000F)
		DISPID_SPIGetDisplayAttributes = 16   ' (&h00000010)
	End Enum
	
	Enum DISPID_SpeechPhraseProperties
		' // Documentation string: Afx_ISpeechPhraseInfoBuilder Interface
		' // Number of constants: 3
		DISPID_SPPsCount = 1   ' (&h00000001)
		DISPID_SPPsItem = 0   ' (&h00000000)
		DISPID_SPPs_NewEnum = -4   ' (&hFFFFFFFC)
	End Enum
	
	Enum DISPID_SpeechPhraseProperty
		' // Documentation string: Afx_ISpeechPhraseInfoBuilder Interface
		' // Number of constants: 9
		DISPID_SPPName = 1   ' (&h00000001)
		DISPID_SPPId = 2   ' (&h00000002)
		DISPID_SPPValue = 3   ' (&h00000003)
		DISPID_SPPFirstElement = 4   ' (&h00000004)
		DISPID_SPPNumberOfElements = 5   ' (&h00000005)
		DISPID_SPPEngineConfidence = 6   ' (&h00000006)
		DISPID_SPPConfidence = 7   ' (&h00000007)
		DISPID_SPPParent = 8   ' (&h00000008)
		DISPID_SPPChildren = 9   ' (&h00000009)
	END ENUM
	
	ENUM DISPID_SpeechPhraseReplacement
		' // Documentation string: Afx_ISpeechPhraseInfoBuilder Interface
		' // Number of constants: 4
		DISPID_SPRDisplayAttributes = 1   ' (&h00000001)
		DISPID_SPRText = 2   ' (&h00000002)
		DISPID_SPRFirstElement = 3   ' (&h00000003)
		DISPID_SPRNumberOfElements = 4   ' (&h00000004)
	End Enum
	
	Enum DISPID_SpeechPhraseReplacements
		' // Documentation string: Afx_ISpeechPhraseInfoBuilder Interface
		' // Number of constants: 3
		DISPID_SPRsCount = 1   ' (&h00000001)
		DISPID_SPRsItem = 0   ' (&h00000000)
		DISPID_SPRs_NewEnum = -4   ' (&hFFFFFFFC)
	End Enum
	
	Enum DISPID_SpeechPhraseRule
		' // Documentation string: Afx_ISpeechPhraseInfoBuilder Interface
		' // Number of constants: 8
		DISPID_SPRuleName = 1   ' (&h00000001)
		DISPID_SPRuleId = 2   ' (&h00000002)
		DISPID_SPRuleFirstElement = 3   ' (&h00000003)
		DISPID_SPRuleNumberOfElements = 4   ' (&h00000004)
		DISPID_SPRuleParent = 5   ' (&h00000005)
		DISPID_SPRuleChildren = 6   ' (&h00000006)
		DISPID_SPRuleConfidence = 7   ' (&h00000007)
		DISPID_SPRuleEngineConfidence = 8   ' (&h00000008)
	End Enum
	
	Enum DISPID_SpeechPhraseRules
		' // Documentation string: Afx_ISpeechPhraseInfoBuilder Interface
		' // Number of constants: 3
		DISPID_SPRulesCount = 1   ' (&h00000001)
		DISPID_SPRulesItem = 0   ' (&h00000000)
		DISPID_SPRules_NewEnum = -4   ' (&hFFFFFFFC)
	End Enum
	
	Enum DISPID_SpeechRecoContext
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 17
		DISPID_SRCRecognizer = 1   ' (&h00000001)
		DISPID_SRCAudioInInterferenceStatus = 2   ' (&h00000002)
		DISPID_SRCRequestedUIType = 3   ' (&h00000003)
		DISPID_SRCVoice = 4   ' (&h00000004)
		DISPID_SRAllowVoiceFormatMatchingOnNextSet = 5   ' (&h00000005)
		DISPID_SRCVoicePurgeEvent = 6   ' (&h00000006)
		DISPID_SRCEventInterests = 7   ' (&h00000007)
		DISPID_SRCCmdMaxAlternates = 8   ' (&h00000008)
		DISPID_SRCState = 9   ' (&h00000009)
		DISPID_SRCRetainedAudio = 10   ' (&h0000000A)
		DISPID_SRCRetainedAudioFormat = 11   ' (&h0000000B)
		DISPID_SRCPause = 12   ' (&h0000000C)
		DISPID_SRCResume = 13   ' (&h0000000D)
		DISPID_SRCCreateGrammar = 14   ' (&h0000000E)
		DISPID_SRCCreateResultFromMemory = 15   ' (&h0000000F)
		DISPID_SRCBookmark = 16   ' (&h00000010)
		DISPID_SRCSetAdaptationData = 17   ' (&h00000011)
	END ENUM
	
	ENUM DISPID_SpeechRecoContextEvents
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 18
		DISPID_SRCEStartStream = 1   ' (&h00000001)
		DISPID_SRCEEndStream = 2   ' (&h00000002)
		DISPID_SRCEBookmark = 3   ' (&h00000003)
		DISPID_SRCESoundStart = 4   ' (&h00000004)
		DISPID_SRCESoundEnd = 5   ' (&h00000005)
		DISPID_SRCEPhraseStart = 6   ' (&h00000006)
		DISPID_SRCERecognition = 7   ' (&h00000007)
		DISPID_SRCEHypothesis = 8   ' (&h00000008)
		DISPID_SRCEPropertyNumberChange = 9   ' (&h00000009)
		DISPID_SRCEPropertyStringChange = 10   ' (&h0000000A)
		DISPID_SRCEFalseRecognition = 11   ' (&h0000000B)
		DISPID_SRCEInterference = 12   ' (&h0000000C)
		DISPID_SRCERequestUI = 13   ' (&h0000000D)
		DISPID_SRCERecognizerStateChange = 14   ' (&h0000000E)
		DISPID_SRCEAdaptation = 15   ' (&h0000000F)
		DISPID_SRCERecognitionForOtherContext = 16   ' (&h00000010)
		DISPID_SRCEAudioLevel = 17   ' (&h00000011)
		DISPID_SRCEEnginePrivate = 18   ' (&h00000012)
	END ENUM
	
	ENUM DISPID_SpeechRecognizer
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 20
		DISPID_SRRecognizer = 1   ' (&h00000001)
		DISPID_SRAllowAudioInputFormatChangesOnNextSet = 2   ' (&h00000002)
		DISPID_SRAudioInput = 3   ' (&h00000003)
		DISPID_SRAudioInputStream = 4   ' (&h00000004)
		DISPID_SRIsShared = 5   ' (&h00000005)
		DISPID_SRState = 6   ' (&h00000006)
		DISPID_SRStatus = 7   ' (&h00000007)
		DISPID_SRProfile = 8   ' (&h00000008)
		DISPID_SREmulateRecognition = 9   ' (&h00000009)
		DISPID_SRCreateRecoContext = 10   ' (&h0000000A)
		DISPID_SRGetFormat = 11   ' (&h0000000B)
		DISPID_SRSetPropertyNumber = 12   ' (&h0000000C)
		DISPID_SRGetPropertyNumber = 13   ' (&h0000000D)
		DISPID_SRSetPropertyString = 14   ' (&h0000000E)
		DISPID_SRGetPropertyString = 15   ' (&h0000000F)
		DISPID_SRIsUISupported = 16   ' (&h00000010)
		DISPID_SRDisplayUI = 17   ' (&h00000011)
		DISPID_SRGetRecognizers = 18   ' (&h00000012)
		DISPID_SVGetAudioInputs = 19   ' (&h00000013)
		DISPID_SVGetProfiles = 20   ' (&h00000014)
	END ENUM
	
	ENUM DISPID_SpeechRecognizerStatus
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 6
		DISPID_SRSAudioStatus = 1   ' (&h00000001)
		DISPID_SRSCurrentStreamPosition = 2   ' (&h00000002)
		DISPID_SRSCurrentStreamNumber = 3   ' (&h00000003)
		DISPID_SRSNumberOfActiveRules = 4   ' (&h00000004)
		DISPID_SRSClsidEngine = 5   ' (&h00000005)
		DISPID_SRSSupportedLanguages = 6   ' (&h00000006)
	END ENUM
	
	ENUM DISPID_SpeechRecoResult
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 9
		DISPID_SRRRecoContext = 1   ' (&h00000001)
		DISPID_SRRTimes = 2   ' (&h00000002)
		DISPID_SRRAudioFormat = 3   ' (&h00000003)
		DISPID_SRRPhraseInfo = 4   ' (&h00000004)
		DISPID_SRRAlternates = 5   ' (&h00000005)
		DISPID_SRRAudio = 6   ' (&h00000006)
		DISPID_SRRSpeakAudio = 7   ' (&h00000007)
		DISPID_SRRSaveToMemory = 8   ' (&h00000008)
		DISPID_SRRDiscardResultInfo = 9   ' (&h00000009)
	END ENUM
	
	ENUM DISPID_SpeechRecoResult2
		' // Documentation string: Afx_ISpeechXMLRecoResult Interface
		' // Number of constants: 1
		DISPID_SRRSetTextFeedback = 12   ' (&h0000000C)
	END ENUM
	
	ENUM DISPID_SpeechRecoResultTimes
		' // Documentation string: Afx_ISpeechPhraseInfoBuilder Interface
		' // Number of constants: 4
		DISPID_SRRTStreamTime = 1   ' (&h00000001)
		DISPID_SRRTLength = 2   ' (&h00000002)
		DISPID_SRRTTickCount = 3   ' (&h00000003)
		DISPID_SRRTOffsetFromStart = 4   ' (&h00000004)
	END ENUM
	
	ENUM DISPID_SpeechVoice
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 22
		DISPID_SVStatus = 1   ' (&h00000001)
		DISPID_SVVoice = 2   ' (&h00000002)
		DISPID_SVAudioOutput = 3   ' (&h00000003)
		DISPID_SVAudioOutputStream = 4   ' (&h00000004)
		DISPID_SVRate = 5   ' (&h00000005)
		DISPID_SVVolume = 6   ' (&h00000006)
		DISPID_SVAllowAudioOuputFormatChangesOnNextSet = 7   ' (&h00000007)
		DISPID_SVEventInterests = 8   ' (&h00000008)
		DISPID_SVPriority = 9   ' (&h00000009)
		DISPID_SVAlertBoundary = 10   ' (&h0000000A)
		DISPID_SVSyncronousSpeakTimeout = 11   ' (&h0000000B)
		DISPID_SVSpeak = 12   ' (&h0000000C)
		DISPID_SVSpeakStream = 13   ' (&h0000000D)
		DISPID_SVPause = 14   ' (&h0000000E)
		DISPID_SVResume = 15   ' (&h0000000F)
		DISPID_SVSkip = 16   ' (&h00000010)
		DISPID_SVGetVoices = 17   ' (&h00000011)
		DISPID_SVGetAudioOutputs = 18   ' (&h00000012)
		DISPID_SVWaitUntilDone = 19   ' (&h00000013)
		DISPID_SVSpeakCompleteEvent = 20   ' (&h00000014)
		DISPID_SVIsUISupported = 21   ' (&h00000015)
		DISPID_SVDisplayUI = 22   ' (&h00000016)
	End Enum
	
	Enum DISPID_SpeechVoiceEvent
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 10
		DISPID_SVEStreamStart = 1   ' (&h00000001)
		DISPID_SVEStreamEnd = 2   ' (&h00000002)
		DISPID_SVEVoiceChange = 3   ' (&h00000003)
		DISPID_SVEBookmark = 4   ' (&h00000004)
		DISPID_SVEWord = 5   ' (&h00000005)
		DISPID_SVEPhoneme = 6   ' (&h00000006)
		DISPID_SVESentenceBoundary = 7   ' (&h00000007)
		DISPID_SVEViseme = 8   ' (&h00000008)
		DISPID_SVEAudioLevel = 9   ' (&h00000009)
		DISPID_SVEEnginePrivate = 10   ' (&h0000000A)
	End Enum
	
	Enum DISPID_SpeechVoiceStatus
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 12
		DISPID_SVSCurrentStreamNumber = 1   ' (&h00000001)
		DISPID_SVSLastStreamNumberQueued = 2   ' (&h00000002)
		DISPID_SVSLastResult = 3   ' (&h00000003)
		DISPID_SVSRunningState = 4   ' (&h00000004)
		DISPID_SVSInputWordPosition = 5   ' (&h00000005)
		DISPID_SVSInputWordLength = 6   ' (&h00000006)
		DISPID_SVSInputSentencePosition = 7   ' (&h00000007)
		DISPID_SVSInputSentenceLength = 8   ' (&h00000008)
		DISPID_SVSLastBookmark = 9   ' (&h00000009)
		DISPID_SVSLastBookmarkId = 10   ' (&h0000000A)
		DISPID_SVSPhonemeId = 11   ' (&h0000000B)
		DISPID_SVSVisemeId = 12   ' (&h0000000C)
	End Enum
	
	Enum DISPID_SpeechWaveFormatEx
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 7
		DISPID_SWFEFormatTag = 1   ' (&h00000001)
		DISPID_SWFEChannels = 2   ' (&h00000002)
		DISPID_SWFESamplesPerSec = 3   ' (&h00000003)
		DISPID_SWFEAvgBytesPerSec = 4   ' (&h00000004)
		DISPID_SWFEBlockAlign = 5   ' (&h00000005)
		DISPID_SWFEBitsPerSample = 6   ' (&h00000006)
		DISPID_SWFEExtraData = 7   ' (&h00000007)
	END ENUM
	
	ENUM DISPID_SpeechXMLRecoResult
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 2
		DISPID_SRRGetXMLResult = 10   ' (&h0000000A)
		DISPID_SRRGetXMLErrorInfo = 11   ' (&h0000000B)
	END ENUM
	
	ENUM DISPIDSPRG
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 19
		DISPID_SRGId = 1   ' (&h00000001)
		DISPID_SRGRecoContext = 2   ' (&h00000002)
		DISPID_SRGState = 3   ' (&h00000003)
		DISPID_SRGRules = 4   ' (&h00000004)
		DISPID_SRGReset = 5   ' (&h00000005)
		DISPID_SRGCommit = 6   ' (&h00000006)
		DISPID_SRGCmdLoadFromFile = 7   ' (&h00000007)
		DISPID_SRGCmdLoadFromObject = 8   ' (&h00000008)
		DISPID_SRGCmdLoadFromResource = 9   ' (&h00000009)
		DISPID_SRGCmdLoadFromMemory = 10   ' (&h0000000A)
		DISPID_SRGCmdLoadFromProprietaryGrammar = 11   ' (&h0000000B)
		DISPID_SRGCmdSetRuleState = 12   ' (&h0000000C)
		DISPID_SRGCmdSetRuleIdState = 13   ' (&h0000000D)
		DISPID_SRGDictationLoad = 14   ' (&h0000000E)
		DISPID_SRGDictationUnload = 15   ' (&h0000000F)
		DISPID_SRGDictationSetState = 16   ' (&h00000010)
		DISPID_SRGSetWordSequenceData = 17   ' (&h00000011)
		DISPID_SRGSetTextSelection = 18   ' (&h00000012)
		DISPID_SRGIsPronounceable = 19   ' (&h00000013)
	END ENUM
	
	ENUM DISPIDSPTSI
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 4
		DISPIDSPTSI_ActiveOffset = 1   ' (&h00000001)
		DISPIDSPTSI_ActiveLength = 2   ' (&h00000002)
		DISPIDSPTSI_SelectionOffset = 3   ' (&h00000003)
		DISPIDSPTSI_SelectionLength = 4   ' (&h00000004)
	END ENUM
	
	ENUM SPADAPTATIONRELEVANCE
		' // Documentation string: Afx_ISpRecoContext2 Interface
		' // Number of constants: 4
		SPAR_Unknown = 0   ' (&h00000000)
		SPAR_Low = 1   ' (&h00000001)
		SPAR_Medium = 2   ' (&h00000002)
		SPAR_High = 3   ' (&h00000003)
	END ENUM
	
	ENUM SPAUDIOOPTIONS
		' // Documentation string: Afx_ISpGrammarBuilder Interface
		' // Number of constants: 2
		SPAO_NONE = 0   ' (&h00000000)
		SPAO_RETAIN_AUDIO = 1   ' (&h00000001)
	END ENUM
	
	ENUM SPBOOKMARKOPTIONS
		' // Documentation string: Afx_ISpPhraseAlt Interface
		' // Number of constants: 4
		SPBO_NONE = 0   ' (&h00000000)
		SPBO_PAUSE = 1   ' (&h00000001)
		SPBO_AHEAD = 2   ' (&h00000002)
		SPBO_TIME_UNITS = 4   ' (&h00000004)
	END ENUM
	
	ENUM SPCATEGORYTYPE
		' // Documentation string: Afx_ISpRecognizer3 Interface
		' // Number of constants: 5
		SPCT_COMMAND = 0   ' (&h00000000)
		SPCT_DICTATION = 1   ' (&h00000001)
		SPCT_SLEEP = 2   ' (&h00000002)
		SPCT_SUB_COMMAND = 3   ' (&h00000003)
		SPCT_SUB_DICTATION = 4   ' (&h00000004)
	End Enum
	
	Enum SPCONTEXTSTATE
		' // Documentation string: Afx_ISpPhraseAlt Interface
		' // Number of constants: 2
		SPCS_DISABLED = 0   ' (&h00000000)
		SPCS_ENABLED = 1   ' (&h00000001)
	End Enum
	
	Enum SPDATAKEYLOCATION
		' // Documentation string: Afx_ISpDataKey Interface
		' // Number of constants: 4
		SPDKL_DefaultLocation = 0   ' (&h00000000)
		SPDKL_CurrentUser = 1   ' (&h00000001)
		SPDKL_LocalMachine = 2   ' (&h00000002)
		SPDKL_CurrentConfig = 5   ' (&h00000005)
	End Enum
	
	Enum SpeechAudioFormatType
		' // Documentation string: Afx_ISpeechAudioFormat Interface
		' // Number of constants: 70
		SAFTDefault = -1   ' (&hFFFFFFFF)
		SAFTNoAssignedFormat = 0   ' (&h00000000)
		SAFTText = 1   ' (&h00000001)
		SAFTNonStandardFormat = 2   ' (&h00000002)
		SAFTExtendedAudioFormat = 3   ' (&h00000003)
		SAFT8kHz8BitMono = 4   ' (&h00000004)
		SAFT8kHz8BitStereo = 5   ' (&h00000005)
		SAFT8kHz16BitMono = 6   ' (&h00000006)
		SAFT8kHz16BitStereo = 7   ' (&h00000007)
		SAFT11kHz8BitMono = 8   ' (&h00000008)
		SAFT11kHz8BitStereo = 9   ' (&h00000009)
		SAFT11kHz16BitMono = 10   ' (&h0000000A)
		SAFT11kHz16BitStereo = 11   ' (&h0000000B)
		SAFT12kHz8BitMono = 12   ' (&h0000000C)
		SAFT12kHz8BitStereo = 13   ' (&h0000000D)
		SAFT12kHz16BitMono = 14   ' (&h0000000E)
		SAFT12kHz16BitStereo = 15   ' (&h0000000F)
		SAFT16kHz8BitMono = 16   ' (&h00000010)
		SAFT16kHz8BitStereo = 17   ' (&h00000011)
		SAFT16kHz16BitMono = 18   ' (&h00000012)
		SAFT16kHz16BitStereo = 19   ' (&h00000013)
		SAFT22kHz8BitMono = 20   ' (&h00000014)
		SAFT22kHz8BitStereo = 21   ' (&h00000015)
		SAFT22kHz16BitMono = 22   ' (&h00000016)
		SAFT22kHz16BitStereo = 23   ' (&h00000017)
		SAFT24kHz8BitMono = 24   ' (&h00000018)
		SAFT24kHz8BitStereo = 25   ' (&h00000019)
		SAFT24kHz16BitMono = 26   ' (&h0000001A)
		SAFT24kHz16BitStereo = 27   ' (&h0000001B)
		SAFT32kHz8BitMono = 28   ' (&h0000001C)
		SAFT32kHz8BitStereo = 29   ' (&h0000001D)
		SAFT32kHz16BitMono = 30   ' (&h0000001E)
		SAFT32kHz16BitStereo = 31   ' (&h0000001F)
		SAFT44kHz8BitMono = 32   ' (&h00000020)
		SAFT44kHz8BitStereo = 33   ' (&h00000021)
		SAFT44kHz16BitMono = 34   ' (&h00000022)
		SAFT44kHz16BitStereo = 35   ' (&h00000023)
		SAFT48kHz8BitMono = 36   ' (&h00000024)
		SAFT48kHz8BitStereo = 37   ' (&h00000025)
		SAFT48kHz16BitMono = 38   ' (&h00000026)
		SAFT48kHz16BitStereo = 39   ' (&h00000027)
		SAFTTrueSpeech_8kHz1BitMono = 40   ' (&h00000028)
		SAFTCCITT_ALaw_8kHzMono = 41   ' (&h00000029)
		SAFTCCITT_ALaw_8kHzStereo = 42   ' (&h0000002A)
		SAFTCCITT_ALaw_11kHzMono = 43   ' (&h0000002B)
		SAFTCCITT_ALaw_11kHzStereo = 44   ' (&h0000002C)
		SAFTCCITT_ALaw_22kHzMono = 45   ' (&h0000002D)
		SAFTCCITT_ALaw_22kHzStereo = 46   ' (&h0000002E)
		SAFTCCITT_ALaw_44kHzMono = 47   ' (&h0000002F)
		SAFTCCITT_ALaw_44kHzStereo = 48   ' (&h00000030)
		SAFTCCITT_uLaw_8kHzMono = 49   ' (&h00000031)
		SAFTCCITT_uLaw_8kHzStereo = 50   ' (&h00000032)
		SAFTCCITT_uLaw_11kHzMono = 51   ' (&h00000033)
		SAFTCCITT_uLaw_11kHzStereo = 52   ' (&h00000034)
		SAFTCCITT_uLaw_22kHzMono = 53   ' (&h00000035)
		SAFTCCITT_uLaw_22kHzStereo = 54   ' (&h00000036)
		SAFTCCITT_uLaw_44kHzMono = 55   ' (&h00000037)
		SAFTCCITT_uLaw_44kHzStereo = 56   ' (&h00000038)
		SAFTADPCM_8kHzMono = 57   ' (&h00000039)
		SAFTADPCM_8kHzStereo = 58   ' (&h0000003A)
		SAFTADPCM_11kHzMono = 59   ' (&h0000003B)
		SAFTADPCM_11kHzStereo = 60   ' (&h0000003C)
		SAFTADPCM_22kHzMono = 61   ' (&h0000003D)
		SAFTADPCM_22kHzStereo = 62   ' (&h0000003E)
		SAFTADPCM_44kHzMono = 63   ' (&h0000003F)
		SAFTADPCM_44kHzStereo = 64   ' (&h00000040)
		SAFTGSM610_8kHzMono = 65   ' (&h00000041)
		SAFTGSM610_11kHzMono = 66   ' (&h00000042)
		SAFTGSM610_22kHzMono = 67   ' (&h00000043)
		SAFTGSM610_44kHzMono = 68   ' (&h00000044)
	End Enum
	
	Enum SpeechAudioState
		' // Documentation string: Afx_ISpeechAudioStatus Interface
		' // Number of constants: 4
		SASClosed = 0   ' (&h00000000)
		SASStop = 1   ' (&h00000001)
		SASPause = 2   ' (&h00000002)
		SASRun = 3   ' (&h00000003)
	END ENUM
	
	ENUM SpeechBookmarkOptions
		' // Documentation string: Afx_ISpeechPhraseAlternate Interface
		' // Number of constants: 2
		SBONone = 0   ' (&h00000000)
		SBOPause = 1   ' (&h00000001)
	END ENUM
	
	ENUM SpeechDataKeyLocation
		' // Documentation string: Afx_ISpeechObjectTokenCategory Interface
		' // Number of constants: 4
		SDKLDefaultLocation = 0   ' (&h00000000)
		SDKLCurrentUser = 1   ' (&h00000001)
		SDKLLocalMachine = 2   ' (&h00000002)
		SDKLCurrentConfig = 5   ' (&h00000005)
	END ENUM
	
	ENUM SpeechDiscardType
		' // Documentation string: Afx_ISpeechPhraseAlternate Interface
		' // Number of constants: 9
		SDTProperty = 1   ' (&h00000001)
		SDTReplacement = 2   ' (&h00000002)
		SDTRule = 4   ' (&h00000004)
		SDTDisplayText = 8   ' (&h00000008)
		SDTLexicalForm = 16   ' (&h00000010)
		SDTPronunciation = 32   ' (&h00000020)
		SDTAudio = 64   ' (&h00000040)
		SDTAlternates = 128   ' (&h00000080)
		SDTAll = 255   ' (&h000000FF)
	END ENUM
	
	ENUM SpeechDisplayAttributes
		' // Documentation string: Afx_ISpeechPhraseElement Interface
		' // Number of constants: 4
		SDA_No_Trailing_Space = 0   ' (&h00000000)
		SDA_One_Trailing_Space = 2   ' (&h00000002)
		SDA_Two_Trailing_Spaces = 4   ' (&h00000004)
		SDA_Consume_Leading_Spaces = 8   ' (&h00000008)
	END ENUM
	
	ENUM SpeechEmulationCompareFlags
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 6
		SECFIgnoreCase = 1   ' (&h00000001)
		SECFIgnoreKanaType = 65536   ' (&h00010000)
		SECFIgnoreWidth = 131072   ' (&h00020000)
		SECFNoSpecialChars = 536870912   ' (&h20000000)
		SECFEmulateResult = 1073741824   ' (&h40000000)
		SECFDefault = 196609   ' (&h00030001) ((SECFIgnoreCase OR SECFIgnoreKanaType) OR SECFIgnoreWidth)
	END ENUM
	
	ENUM SpeechEngineConfidence
		' // Documentation string: Afx_ISpeechPhraseRules Interface
		' // Number of constants: 3
		SECLowConfidence = -1   ' (&hFFFFFFFF)
		SECNormalConfidence = 0   ' (&h00000000)
		SECHighConfidence = 1   ' (&h00000001)
	END ENUM
	
	ENUM SpeechFormatType
		' // Documentation string: Afx_ISpeechPhraseAlternate Interface
		' // Number of constants: 2
		SFTInput = 0   ' (&h00000000) SPWF_INPUT
		SFTSREngine = 1   ' (&h00000001) SPWF_SRENGINE
	END ENUM
	
	ENUM SpeechGrammarRuleStateTransitionType
		' // Documentation string: Afx_ISpeechGrammarRuleStateTransition Interface
		' // Number of constants: 6
		SGRSTTEpsilon = 0   ' (&h00000000)
		SGRSTTWord = 1   ' (&h00000001)
		SGRSTTRule = 2   ' (&h00000002)
		SGRSTTDictation = 3   ' (&h00000003)
		SGRSTTWildcard = 4   ' (&h00000004)
		SGRSTTTextBuffer = 5   ' (&h00000005)
	END ENUM
	
	ENUM SpeechGrammarState
		' // Documentation string: Afx_ISpeechRecoGrammar Interface
		' // Number of constants: 3
		SGSEnabled = 1   ' (&h00000001) SPGS_ENABLED
		SGSDisabled = 0   ' (&h00000000) SPGS_DISABLED
		SGSExclusive = 3   ' (&h00000003) SPGS_EXCLUSIVE
	END ENUM
	
	ENUM SpeechGrammarWordType
		' // Documentation string: Afx_ISpeechGrammarRuleStateTransition Interface
		' // Number of constants: 4
		SGDisplay = 0   ' (&h00000000) SPWT_DISPLAY
		SGLexical = 1   ' (&h00000001) SPWT_LEXICAL
		SGPronounciation = 2   ' (&h00000002) SPWT_PRONUNCIATION
		SGLexicalNoSpecialChars = 3   ' (&h00000003) SPWT_LEXICAL_NO_SPECIAL_CHARS
	END ENUM
	
	ENUM SpeechInterference
		' // Documentation string: Afx_ISpeechRecoContext Interface
		' // Number of constants: 7
		SINone = 0   ' (&h00000000) SPINTERFERENCE_NONE
		SINoise = 1   ' (&h00000001) SPINTERFERENCE_NOISE
		SINoSignal = 2   ' (&h00000002) SPINTERFERENCE_NOSIGNAL
		SITooLoud = 3   ' (&h00000003) SPINTERFERENCE_TOOLOUD
		SITooQuiet = 4   ' (&h00000004) SPINTERFERENCE_TOOQUIET
		SITooFast = 5   ' (&h00000005) SPINTERFERENCE_TOOFAST
		SITooSlow = 6   ' (&h00000006) SPINTERFERENCE_TOOSLOW
	END ENUM
	
	ENUM SpeechLexiconType
		' // Documentation string: Afx_ISpeechLexicon Interface
		' // Number of constants: 2
		SLTUser = 1   ' (&h00000001) eLEXTYPE_USER
		SLTApp = 2   ' (&h00000002) eLEXTYPE_APP
	END ENUM
	
	ENUM SpeechLoadOption
		' // Documentation string: Afx_ISpeechGrammarRuleStateTransition Interface
		' // Number of constants: 2
		SLOStatic = 0   ' (&h00000000) SPLO_STATIC
		SLODynamic = 1   ' (&h00000001) SPLO_DYNAMIC
	END ENUM
	
	ENUM SpeechPartOfSpeech
		' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
		' // Number of constants: 9
		SPSNotOverriden = -1   ' (&hFFFFFFFF) SPPS_NotOverriden
		SPSUnknown = 0   ' (&h00000000) SPPS_Unknown
		SPSNoun = 4096   ' (&h00001000) SPPS_Noun
		SPSVerb = 8192   ' (&h00002000) SPPS_Verb
		SPSModifier = 12288   ' (&h00003000) SPPS_Modifier
		SPSFunction = 16384   ' (&h00004000) SPPS_Function
		SPSInterjection = 20480   ' (&h00005000) SPPS_Interjection
		SPSLMA = 28672   ' (&h00007000) SPPS_LMA
		SPSSuppressWord = 61440   ' (&h0000F000) SPPS_SuppressWord
	END ENUM
	
	ENUM SpeechRecoContextState
		' // Documentation string: Afx_ISpeechRecoContext Interface
		' // Number of constants: 2
		SRCS_Disabled = 0   ' (&h00000000) SPCS_DISABLED
		SRCS_Enabled = 1   ' (&h00000001) SPCS_ENABLED
	END ENUM
	
	ENUM SpeechRecoEvents
		' // Documentation string: Afx_ISpeechRecoContext Interface
		' // Number of constants: 19
		SREStreamEnd = 1   ' (&h00000001)
		SRESoundStart = 2   ' (&h00000002)
		SRESoundEnd = 4   ' (&h00000004)
		SREPhraseStart = 8   ' (&h00000008)
		SRERecognition = 16   ' (&h00000010)
		SREHypothesis = 32   ' (&h00000020)
		SREBookmark = 64   ' (&h00000040)
		SREPropertyNumChange = 128   ' (&h00000080)
		SREPropertyStringChange = 256   ' (&h00000100)
		SREFalseRecognition = 512   ' (&h00000200)
		SREInterference = 1024   ' (&h00000400)
		SRERequestUI = 2048   ' (&h00000800)
		SREStateChange = 4096   ' (&h00001000)
		SREAdaptation = 8192   ' (&h00002000)
		SREStreamStart = 16384   ' (&h00004000)
		SRERecoOtherContext = 32768   ' (&h00008000)
		SREAudioLevel = 65536   ' (&h00010000)
		SREPrivate = 262144   ' (&h00040000)
		SREAllEvents = 393215   ' (&h0005FFFF)
	End Enum
	
	Enum SpeechRecognitionType
		' // Documentation string: Afx_ISpeechPhraseAlternate Interface
		' // Number of constants: 6
		SRTStandard = 0   ' (&h00000000)
		SRTAutopause = 1   ' (&h00000001)
		SRTEmulated = 2   ' (&h00000002)
		SRTSMLTimeout = 4   ' (&h00000004)
		SRTExtendableParse = 8   ' (&h00000008)
		SRTReSent = 16   ' (&h00000010)
	End Enum
	
	Enum SpeechRecognizerState
		' // Documentation string: Afx_ISpeechRecognizer Interface
		' // Number of constants: 4
		SRSInactive = 0   ' (&h00000000)
		SRSActive = 1   ' (&h00000001)
		SRSActiveAlways = 2   ' (&h00000002)
		SRSInactiveWithPurge = 3   ' (&h00000003)
	End Enum
	
	Enum SpeechRetainedAudioOptions
		' // Documentation string: Afx_ISpeechRecoContext Interface
		' // Number of constants: 2
		SRAONone = 0   ' (&h00000000)
		SRAORetainAudio = 1   ' (&h00000001)
	END ENUM
	
	ENUM SpeechRuleAttributes
		' // Documentation string: Afx_ISpeechGrammarRule Interface
		' // Number of constants: 7
		SRATopLevel = 1   ' (&h00000001) SPRAF_TopLevel
		SRADefaultToActive = 2   ' (&h00000002) SPRAF_Active
		SRAExport = 4   ' (&h00000004) SPRAF_Export
		SRAImport = 8   ' (&h00000008) SPRAF_Import
		SRAInterpreter = 16   ' (&h00000010) SPRAF_Interpreter
		SRADynamic = 32   ' (&h00000020) SPRAF_Dynamic
		SRARoot = 64   ' (&h00000040) SPRAF_Root
	END ENUM
	
	ENUM SpeechRuleState
		' // Documentation string: Afx_ISpeechGrammarRuleStateTransition Interface
		' // Number of constants: 4
		SGDSInactive = 0   ' (&h00000000) SPRS_INACTIVE
		SGDSActive = 1   ' (&h00000001) SPRS_ACTIVE
		SGDSActiveWithAutoPause = 3   ' (&h00000003) SPRS_ACTIVE_WITH_AUTO_PAUSE
		SGDSActiveUserDelimited = 4   ' (&h00000004) SPRS_ACTIVE_USER_DELIMITED
	END ENUM
	
	ENUM SpeechRunState
		' // Documentation string: Afx_ISpeechVoiceStatus Interface
		' // Number of constants: 2
		SRSEDone = 1   ' (&h00000001) SPRS_DONE
		SRSEIsSpeaking = 2   ' (&h00000002) SPRS_IS_SPEAKING
	END ENUM
	
	ENUM SpeechSpecialTransitionType
		' // Documentation string: Afx_ISpeechGrammarRuleStateTransition Interface
		' // Number of constants: 3
		SSTTWildcard = 1   ' (&h00000001)
		SSTTDictation = 2   ' (&h00000002)
		SSTTTextBuffer = 3   ' (&h00000003)
	END ENUM
	
	ENUM SpeechStreamFileMode
		' // Documentation string: Afx_ISpeechFileStream Interface
		' // Number of constants: 4
		SSFMOpenForRead = 0   ' (&h00000000)
		SSFMOpenReadWrite = 1   ' (&h00000001)
		SSFMCreate = 2   ' (&h00000002)
		SSFMCreateForWrite = 3   ' (&h00000003)
	END ENUM
	
	ENUM SpeechStreamSeekPositionType
		' // Documentation string: Afx_ISpeechBaseStream Interface
		' // Number of constants: 3
		SSSPTRelativeToStart = 0   ' (&h00000000) STREAM_SEEK_SET
		SSSPTRelativeToCurrentPosition = 1   ' (&h00000001) STREAM_SEEK_CUR
		SSSPTRelativeToEnd = 2   ' (&h00000002) STREAM_SEEK_END
	END ENUM
	
	ENUM SpeechTokenContext
		' // Documentation string: Afx_ISpeechObjectTokens Interface
		' // Number of constants: 5
		STCInprocServer = 1   ' (&h00000001)
		STCInprocHandler = 2   ' (&h00000002)
		STCLocalServer = 4   ' (&h00000004)
		STCRemoteServer = 16   ' (&h00000010)
		STCAll = 23   ' (&h00000017)
	END ENUM
	
	ENUM SpeechTokenShellFolder
		' // Documentation string: Afx_ISpeechObjectTokens Interface
		' // Number of constants: 4
		STSF_AppData = 26   ' (&h0000001A)
		STSF_LocalAppData = 28   ' (&h0000001C)
		STSF_CommonAppData = 35   ' (&h00000023)
		STSF_FlagCreate = 32768   ' (&h00008000)
	END ENUM
	
	ENUM SpeechVisemeFeature
		' // Documentation string: Afx_ISpeechVoiceStatus Interface
		' // Number of constants: 3
		SVF_None = 0   ' (&h00000000)
		SVF_Stressed = 1   ' (&h00000001) SPVFEATURE_STRESSED
		SVF_Emphasis = 2   ' (&h00000002) SPVFEATURE_EMPHASIS
	END ENUM
	
	ENUM SpeechVisemeType
		' // Documentation string: Afx_ISpeechVoiceStatus Interface
		' // Number of constants: 22
		SVP_0 = 0   ' (&h00000000)
		SVP_1 = 1   ' (&h00000001)
		SVP_2 = 2   ' (&h00000002)
		SVP_3 = 3   ' (&h00000003)
		SVP_4 = 4   ' (&h00000004)
		SVP_5 = 5   ' (&h00000005)
		SVP_6 = 6   ' (&h00000006)
		SVP_7 = 7   ' (&h00000007)
		SVP_8 = 8   ' (&h00000008)
		SVP_9 = 9   ' (&h00000009)
		SVP_10 = 10   ' (&h0000000A)
		SVP_11 = 11   ' (&h0000000B)
		SVP_12 = 12   ' (&h0000000C)
		SVP_13 = 13   ' (&h0000000D)
		SVP_14 = 14   ' (&h0000000E)
		SVP_15 = 15   ' (&h0000000F)
		SVP_16 = 16   ' (&h00000010)
		SVP_17 = 17   ' (&h00000011)
		SVP_18 = 18   ' (&h00000012)
		SVP_19 = 19   ' (&h00000013)
		SVP_20 = 20   ' (&h00000014)
		SVP_21 = 21   ' (&h00000015)
	End Enum
	
	Enum SpeechVoiceEvents
		' // Documentation string: Afx_ISpeechVoiceStatus Interface
		' // Number of constants: 11
		SVEStartInputStream = 2   ' (&h00000002)
		SVEEndInputStream = 4   ' (&h00000004)
		SVEVoiceChange = 8   ' (&h00000008)
		SVEBookmark = 16   ' (&h00000010)
		SVEWordBoundary = 32   ' (&h00000020)
		SVEPhoneme = 64   ' (&h00000040)
		SVESentenceBoundary = 128   ' (&h00000080)
		SVEViseme = 256   ' (&h00000100)
		SVEAudioLevel = 512   ' (&h00000200)
		SVEPrivate = 32768   ' (&h00008000)
		SVEAllEvents = 33790   ' (&h000083FE)
	End Enum
	
	Enum SpeechVoicePriority
		' // Documentation string: Afx_ISpeechVoiceStatus Interface
		' // Number of constants: 3
		SVPNormal = 0   ' (&h00000000) SPVPRI_NORMAL
		SVPAlert = 1   ' (&h00000001) SPVPRI_ALERT
		SVPOver = 2   ' (&h00000002) SPVPRI_OVER
	End Enum
	
	Enum SpeechVoiceSpeakFlags
		' // Documentation string: Afx_ISpeechVoiceStatus Interface
		' // Number of constants: 15
		SVSFDefault = 0   ' (&h00000000) SPF_DEFAULT
		SVSFlagsAsync = 1   ' (&h00000001) SPF_ASYNC
		SVSFPurgeBeforeSpeak = 2   ' (&h00000002) SPF_PURGEBEFORESPEAK
		SVSFIsFilename = 4   ' (&h00000004) SPF_IS_FILENAME
		SVSFIsXML = 8   ' (&h00000008) SPF_IS_XML
		SVSFIsNotXML = 16   ' (&h00000010) SPF_IS_NOT_XML
		SVSFPersistXML = 32   ' (&h00000020) SPF_PERSIST_XML
		SVSFNLPSpeakPunc = 64   ' (&h00000040) SPF_NLP_SPEAK_PUNC
		SVSFParseSapi = 128   ' (&h00000080)
		SVSFParseSsml = 256   ' (&h00000100)
		SVSFParseAutodetect = 0   ' (&h00000000)
		SVSFNLPMask = 64   ' (&h00000040) SPF_NLP_MASK
		SVSFParseMask = 384   ' (&h00000180)
		SVSFVoiceMask = 511   ' (&h000001FF) SPF_VOICE_MASK
		SVSFUnusedFlags = -512   ' (&hFFFFFE00) SPF_UNUSED_FLAGS
	END ENUM
	
	ENUM SpeechWordPronounceable
		' // Documentation string: Afx_ISpeechTextSelectionInformation Interface
		' // Number of constants: 3
		SWPUnknownWordUnpronounceable = 0   ' (&h00000000)
		SWPUnknownWordPronounceable = 1   ' (&h00000001)
		SWPKnownWordPronounceable = 2   ' (&h00000002)
	END ENUM
	
	ENUM SpeechWordType
		' // Documentation string: Afx_ISpeechLexiconWord Interface
		' // Number of constants: 2
		SWTAdded = 1   ' (&h00000001) eWORDTYPE_ADDED
		SWTDeleted = 2   ' (&h00000002) eWORDTYPE_DELETED
	END ENUM
	
	ENUM SPEVENTENUM
		' // Documentation string: Afx_ISpVoice Interface
		' // Number of constants: 40
		SPEI_UNDEFINED = 0   ' (&h00000000)
		SPEI_START_INPUT_STREAM = 1   ' (&h00000001)
		SPEI_END_INPUT_STREAM = 2   ' (&h00000002)
		SPEI_VOICE_CHANGE = 3   ' (&h00000003)
		SPEI_TTS_BOOKMARK = 4   ' (&h00000004)
		SPEI_WORD_BOUNDARY = 5   ' (&h00000005)
		SPEI_PHONEME = 6   ' (&h00000006)
		SPEI_SENTENCE_BOUNDARY = 7   ' (&h00000007)
		SPEI_VISEME = 8   ' (&h00000008)
		SPEI_TTS_AUDIO_LEVEL = 9   ' (&h00000009)
		SPEI_TTS_PRIVATE = 15   ' (&h0000000F)
		SPEI_MIN_TTS = 1   ' (&h00000001)
		SPEI_MAX_TTS = 15   ' (&h0000000F)
		SPEI_END_SR_STREAM = 34   ' (&h00000022)
		SPEI_SOUND_START = 35   ' (&h00000023)
		SPEI_SOUND_END = 36   ' (&h00000024)
		SPEI_PHRASE_START = 37   ' (&h00000025)
		SPEI_RECOGNITION = 38   ' (&h00000026)
		SPEI_HYPOTHESIS = 39   ' (&h00000027)
		SPEI_SR_BOOKMARK = 40   ' (&h00000028)
		SPEI_PROPERTY_NUM_CHANGE = 41   ' (&h00000029)
		SPEI_PROPERTY_STRING_CHANGE = 42   ' (&h0000002A)
		SPEI_FALSE_RECOGNITION = 43   ' (&h0000002B)
		SPEI_INTERFERENCE = 44   ' (&h0000002C)
		SPEI_REQUEST_UI = 45   ' (&h0000002D)
		SPEI_RECO_STATE_CHANGE = 46   ' (&h0000002E)
		SPEI_ADAPTATION = 47   ' (&h0000002F)
		SPEI_START_SR_STREAM = 48   ' (&h00000030)
		SPEI_RECO_OTHER_CONTEXT = 49   ' (&h00000031)
		SPEI_SR_AUDIO_LEVEL = 50   ' (&h00000032)
		SPEI_SR_RETAINEDAUDIO = 51   ' (&h00000033)
		SPEI_SR_PRIVATE = 52   ' (&h00000034)
		SPEI_ACTIVE_CATEGORY_CHANGED = 53   ' (&h00000035)
		SPEI_RESERVED5 = 54   ' (&h00000036)
		SPEI_RESERVED6 = 55   ' (&h00000037)
		SPEI_MIN_SR = 34   ' (&h00000022)
		SPEI_MAX_SR = 55   ' (&h00000037)
		SPEI_RESERVED1 = 30   ' (&h0000001E)
		SPEI_RESERVED2 = 33   ' (&h00000021)
		SPEI_RESERVED3 = 63   ' (&h0000003F)
	END ENUM
	
	ENUM SPFILEMODE
		' // Documentation string: Afx_ISpStream Interface
		' // Number of constants: 5
		SPFM_OPEN_READONLY = 0   ' (&h00000000)
		SPFM_OPEN_READWRITE = 1   ' (&h00000001)
		SPFM_CREATE = 2   ' (&h00000002)
		SPFM_CREATE_ALWAYS = 3   ' (&h00000003)
		SPFM_NUM_MODES = 4   ' (&h00000004)
	END ENUM
	
	ENUM SPGRAMMARSTATE
		' // Documentation string: Afx_ISpGrammarBuilder Interface
		' // Number of constants: 3
		SPGS_DISABLED = 0   ' (&h00000000)
		SPGS_ENABLED = 1   ' (&h00000001)
		SPGS_EXCLUSIVE = 3   ' (&h00000003)
	END ENUM
	
	ENUM SPGRAMMARWORDTYPE
		' // Documentation string: Afx_ISpGrammarBuilder Interface
		' // Number of constants: 4
		SPWT_DISPLAY = 0   ' (&h00000000)
		SPWT_LEXICAL = 1   ' (&h00000001)
		SPWT_PRONUNCIATION = 2   ' (&h00000002)
		SPWT_LEXICAL_NO_SPECIAL_CHARS = 3   ' (&h00000003)
	END ENUM
	
	ENUM SPINTERFERENCE
		' // Documentation string: Afx_ISpGrammarBuilder Interface
		' // Number of constants: 7
		SPINTERFERENCE_NONE = 0   ' (&h00000000)
		SPINTERFERENCE_NOISE = 1   ' (&h00000001)
		SPINTERFERENCE_NOSIGNAL = 2   ' (&h00000002)
		SPINTERFERENCE_TOOLOUD = 3   ' (&h00000003)
		SPINTERFERENCE_TOOQUIET = 4   ' (&h00000004)
		SPINTERFERENCE_TOOFAST = 5   ' (&h00000005)
		SPINTERFERENCE_TOOSLOW = 6   ' (&h00000006)
	END ENUM
	
	ENUM SPLEXICONTYPE
		' // Documentation string: Afx_ISpLexicon Interface
		' // Number of constants: 32
		eLEXTYPE_USER = 1   ' (&h00000001)
		eLEXTYPE_APP = 2   ' (&h00000002)
		eLEXTYPE_VENDORLEXICON = 4   ' (&h00000004)
		eLEXTYPE_LETTERTOSOUND = 8   ' (&h00000008)
		eLEXTYPE_MORPHOLOGY = 16   ' (&h00000010)
		eLEXTYPE_RESERVED4 = 32   ' (&h00000020)
		eLEXTYPE_USER_SHORTCUT = 64   ' (&h00000040)
		eLEXTYPE_RESERVED6 = 128   ' (&h00000080)
		eLEXTYPE_RESERVED7 = 256   ' (&h00000100)
		eLEXTYPE_RESERVED8 = 512   ' (&h00000200)
		eLEXTYPE_RESERVED9 = 1024   ' (&h00000400)
		eLEXTYPE_RESERVED10 = 2048   ' (&h00000800)
		eLEXTYPE_PRIVATE1 = 4096   ' (&h00001000)
		eLEXTYPE_PRIVATE2 = 8192   ' (&h00002000)
		eLEXTYPE_PRIVATE3 = 16384   ' (&h00004000)
		eLEXTYPE_PRIVATE4 = 32768   ' (&h00008000)
		eLEXTYPE_PRIVATE5 = 65536   ' (&h00010000)
		eLEXTYPE_PRIVATE6 = 131072   ' (&h00020000)
		eLEXTYPE_PRIVATE7 = 262144   ' (&h00040000)
		eLEXTYPE_PRIVATE8 = 524288   ' (&h00080000)
		eLEXTYPE_PRIVATE9 = 1048576   ' (&h00100000)
		eLEXTYPE_PRIVATE10 = 2097152   ' (&h00200000)
		eLEXTYPE_PRIVATE11 = 4194304   ' (&h00400000)
		eLEXTYPE_PRIVATE12 = 8388608   ' (&h00800000)
		eLEXTYPE_PRIVATE13 = 16777216   ' (&h01000000)
		eLEXTYPE_PRIVATE14 = 33554432   ' (&h02000000)
		eLEXTYPE_PRIVATE15 = 67108864   ' (&h04000000)
		eLEXTYPE_PRIVATE16 = 134217728   ' (&h08000000)
		eLEXTYPE_PRIVATE17 = 268435456   ' (&h10000000)
		eLEXTYPE_PRIVATE18 = 536870912   ' (&h20000000)
		eLEXTYPE_PRIVATE19 = 1073741824   ' (&h40000000)
		eLEXTYPE_PRIVATE20 = -2147483648   ' (&h80000000)
	End Enum
	
	Enum SPLOADOPTIONS
		' // Documentation string: Afx_ISpGrammarBuilder Interface
		' // Number of constants: 2
		SPLO_STATIC = 0   ' (&h00000000)
		SPLO_DYNAMIC = 1   ' (&h00000001)
	End Enum
	
	Enum SPPARTOFSPEECH
		' // Documentation string: Afx_ISpLexicon Interface
		' // Number of constants: 10
		SPPS_NotOverriden = -1   ' (&hFFFFFFFF)
		SPPS_Unknown = 0   ' (&h00000000)
		SPPS_Noun = 4096   ' (&h00001000)
		SPPS_Verb = 8192   ' (&h00002000)
		SPPS_Modifier = 12288   ' (&h00003000)
		SPPS_Function = 16384   ' (&h00004000)
		SPPS_Interjection = 20480   ' (&h00005000)
		SPPS_Noncontent = 24576   ' (&h00006000)
		SPPS_LMA = 28672   ' (&h00007000)
		SPPS_SuppressWord = 61440   ' (&h0000F000)
	End Enum
	
	Enum SPRECOSTATE
		' // Documentation string: Afx_ISpProperties Interface
		' // Number of constants: 5
		SPRST_INACTIVE = 0   ' (&h00000000)
		SPRST_ACTIVE = 1   ' (&h00000001)
		SPRST_ACTIVE_ALWAYS = 2   ' (&h00000002)
		SPRST_INACTIVE_WITH_PURGE = 3   ' (&h00000003)
		SPRST_NUM_STATES = 4   ' (&h00000004)
	END ENUM
	
	ENUM SPRULESTATE
		' // Documentation string: Afx_ISpGrammarBuilder Interface
		' // Number of constants: 4
		SPRS_INACTIVE = 0   ' (&h00000000)
		SPRS_ACTIVE = 1   ' (&h00000001)
		SPRS_ACTIVE_WITH_AUTO_PAUSE = 3   ' (&h00000003)
		SPRS_ACTIVE_USER_DELIMITED = 4   ' (&h00000004)
	END ENUM
	
	ENUM SPSEMANTICFORMAT
		' // Documentation string: Afx_ISpPhrase Interface
		' // Number of constants: 5
		SPSMF_SAPI_PROPERTIES = 0   ' (&h00000000)
		SPSMF_SRGS_SEMANTICINTERPRETATION_MS = 1   ' (&h00000001)
		SPSMF_SRGS_SAPIPROPERTIES = 2   ' (&h00000002)
		SPSMF_UPS = 4   ' (&h00000004)
		SPSMF_SRGS_SEMANTICINTERPRETATION_W3C = 8   ' (&h00000008)
	END ENUM
	
	ENUM SPSHORTCUTTYPE
		' // Documentation string: Afx_ISpShortcut Interface
		' // Number of constants: 8
		SPSHT_NotOverriden = -1   ' (&hFFFFFFFF)
		SPSHT_Unknown = 0   ' (&h00000000)
		SPSHT_EMAIL = 4096   ' (&h00001000)
		SPSHT_OTHER = 8192   ' (&h00002000)
		SPPS_RESERVED1 = 12288   ' (&h00003000)
		SPPS_RESERVED2 = 16384   ' (&h00004000)
		SPPS_RESERVED3 = 20480   ' (&h00005000)
		SPPS_RESERVED4 = 61440   ' (&h0000F000)
	END ENUM
	
	ENUM SPVISEMES
		' // Documentation string: Afx_ISpVoice Interface
		' // Number of constants: 22
		SP_VISEME_0 = 0   ' (&h00000000)
		SP_VISEME_1 = 1   ' (&h00000001)
		SP_VISEME_2 = 2   ' (&h00000002)
		SP_VISEME_3 = 3   ' (&h00000003)
		SP_VISEME_4 = 4   ' (&h00000004)
		SP_VISEME_5 = 5   ' (&h00000005)
		SP_VISEME_6 = 6   ' (&h00000006)
		SP_VISEME_7 = 7   ' (&h00000007)
		SP_VISEME_8 = 8   ' (&h00000008)
		SP_VISEME_9 = 9   ' (&h00000009)
		SP_VISEME_10 = 10   ' (&h0000000A)
		SP_VISEME_11 = 11   ' (&h0000000B)
		SP_VISEME_12 = 12   ' (&h0000000C)
		SP_VISEME_13 = 13   ' (&h0000000D)
		SP_VISEME_14 = 14   ' (&h0000000E)
		SP_VISEME_15 = 15   ' (&h0000000F)
		SP_VISEME_16 = 16   ' (&h00000010)
		SP_VISEME_17 = 17   ' (&h00000011)
		SP_VISEME_18 = 18   ' (&h00000012)
		SP_VISEME_19 = 19   ' (&h00000013)
		SP_VISEME_20 = 20   ' (&h00000014)
		SP_VISEME_21 = 21   ' (&h00000015)
	END ENUM
	
	Enum SPVPRIORITY
		' // Documentation string: Afx_ISpVoice Interface
		' // Number of constants: 3
		SPVPRI_NORMAL = 0   ' (&h00000000)
		SPVPRI_ALERT = 1   ' (&h00000001)
		SPVPRI_OVER = 2   ' (&h00000002)
	End Enum
	
	Enum SPWAVEFORMATTYPE
		' // Documentation string: Afx_ISpProperties Interface
		' // Number of constants: 2
		SPWF_INPUT = 0   ' (&h00000000)
		SPWF_SRENGINE = 1   ' (&h00000001)
	End Enum
	
	Enum SPWORDPRONOUNCEABLE
		' // Documentation string: Afx_ISpGrammarBuilder Interface
		' // Number of constants: 3
		SPWP_UNKNOWN_WORD_UNPRONOUNCEABLE = 0   ' (&h00000000)
		SPWP_UNKNOWN_WORD_PRONOUNCEABLE = 1   ' (&h00000001)
		SPWP_KNOWN_WORD_PRONOUNCEABLE = 2   ' (&h00000002)
	End Enum
	
	Enum SPWORDTYPE
		' // Documentation string: Afx_ISpLexicon Interface
		' // Number of constants: 2
		eWORDTYPE_ADDED = 1   ' (&h00000001)
		eWORDTYPE_DELETED = 2   ' (&h00000002)
	End Enum
	
	Enum SPXMLRESULTOPTIONS
		' // Documentation string: Afx_ISpeechXMLRecoResult Interface
		' // Number of constants: 2
		SPXRO_SML = 0   ' (&h00000000)
		SPXRO_Alternates_SML = 1   ' (&h00000001)
	End Enum
	
	' enum SPSTREAMFORMAT
	TYPE SPSTREAMFORMAT AS LONG
	CONST SPSF_Default                 = -1
	CONST SPSF_NoAssignedFormat        = 0
	CONST SPSF_Text                    = SPSF_NoAssignedFormat        + 1
	CONST SPSF_NonStandardFormat       = SPSF_Text                    + 1
	CONST SPSF_ExtendedAudioFormat     = SPSF_NonStandardFormat       + 1
	CONST SPSF_8kHz8BitMono            = SPSF_ExtendedAudioFormat     + 1
	CONST SPSF_8kHz8BitStereo          = SPSF_8kHz8BitMono            + 1
	CONST SPSF_8kHz16BitMono           = SPSF_8kHz8BitStereo          + 1
	CONST SPSF_8kHz16BitStereo         = SPSF_8kHz16BitMono           + 1
	CONST SPSF_11kHz8BitMono           = SPSF_8kHz16BitStereo         + 1
	CONST SPSF_11kHz8BitStereo         = SPSF_11kHz8BitMono           + 1
	CONST SPSF_11kHz16BitMono          = SPSF_11kHz8BitStereo         + 1
	CONST SPSF_11kHz16BitStereo        = SPSF_11kHz16BitMono          + 1
	CONST SPSF_12kHz8BitMono           = SPSF_11kHz16BitStereo        + 1
	CONST SPSF_12kHz8BitStereo         = SPSF_12kHz8BitMono           + 1
	CONST SPSF_12kHz16BitMono          = SPSF_12kHz8BitStereo         + 1
	CONST SPSF_12kHz16BitStereo        = SPSF_12kHz16BitMono          + 1
	CONST SPSF_16kHz8BitMono           = SPSF_12kHz16BitStereo        + 1
	CONST SPSF_16kHz8BitStereo         = SPSF_16kHz8BitMono           + 1
	CONST SPSF_16kHz16BitMono          = SPSF_16kHz8BitStereo         + 1
	CONST SPSF_16kHz16BitStereo        = SPSF_16kHz16BitMono          + 1
	CONST SPSF_22kHz8BitMono           = SPSF_16kHz16BitStereo        + 1
	CONST SPSF_22kHz8BitStereo         = SPSF_22kHz8BitMono           + 1
	CONST SPSF_22kHz16BitMono          = SPSF_22kHz8BitStereo         + 1
	CONST SPSF_22kHz16BitStereo        = SPSF_22kHz16BitMono          + 1
	CONST SPSF_24kHz8BitMono           = SPSF_22kHz16BitStereo        + 1
	CONST SPSF_24kHz8BitStereo         = SPSF_24kHz8BitMono           + 1
	CONST SPSF_24kHz16BitMono          = SPSF_24kHz8BitStereo         + 1
	CONST SPSF_24kHz16BitStereo        = SPSF_24kHz16BitMono          + 1
	CONST SPSF_32kHz8BitMono           = SPSF_24kHz16BitStereo        + 1
	CONST SPSF_32kHz8BitStereo         = SPSF_32kHz8BitMono           + 1
	CONST SPSF_32kHz16BitMono          = SPSF_32kHz8BitStereo         + 1
	CONST SPSF_32kHz16BitStereo        = SPSF_32kHz16BitMono          + 1
	CONST SPSF_44kHz8BitMono           = SPSF_32kHz16BitStereo        + 1
	CONST SPSF_44kHz8BitStereo         = SPSF_44kHz8BitMono           + 1
	CONST SPSF_44kHz16BitMono          = SPSF_44kHz8BitStereo         + 1
	CONST SPSF_44kHz16BitStereo        = SPSF_44kHz16BitMono          + 1
	CONST SPSF_48kHz8BitMono           = SPSF_44kHz16BitStereo        + 1
	CONST SPSF_48kHz8BitStereo         = SPSF_48kHz8BitMono           + 1
	CONST SPSF_48kHz16BitMono          = SPSF_48kHz8BitStereo         + 1
	CONST SPSF_48kHz16BitStereo        = SPSF_48kHz16BitMono          + 1
	CONST SPSF_TrueSpeech_8kHz1BitMono = SPSF_48kHz16BitStereo        + 1
	CONST SPSF_CCITT_ALaw_8kHzMono     = SPSF_TrueSpeech_8kHz1BitMono + 1
	CONST SPSF_CCITT_ALaw_8kHzStereo   = SPSF_CCITT_ALaw_8kHzMono     + 1
	CONST SPSF_CCITT_ALaw_11kHzMono    = SPSF_CCITT_ALaw_8kHzStereo   + 1
	CONST SPSF_CCITT_ALaw_11kHzStereo  = SPSF_CCITT_ALaw_11kHzMono    + 1
	CONST SPSF_CCITT_ALaw_22kHzMono    = SPSF_CCITT_ALaw_11kHzStereo  + 1
	CONST SPSF_CCITT_ALaw_22kHzStereo  = SPSF_CCITT_ALaw_22kHzMono    + 1
	CONST SPSF_CCITT_ALaw_44kHzMono    = SPSF_CCITT_ALaw_22kHzStereo  + 1
	CONST SPSF_CCITT_ALaw_44kHzStereo  = SPSF_CCITT_ALaw_44kHzMono    + 1
	CONST SPSF_CCITT_uLaw_8kHzMono     = SPSF_CCITT_ALaw_44kHzStereo  + 1
	CONST SPSF_CCITT_uLaw_8kHzStereo   = SPSF_CCITT_uLaw_8kHzMono     + 1
	CONST SPSF_CCITT_uLaw_11kHzMono    = SPSF_CCITT_uLaw_8kHzStereo   + 1
	CONST SPSF_CCITT_uLaw_11kHzStereo  = SPSF_CCITT_uLaw_11kHzMono    + 1
	CONST SPSF_CCITT_uLaw_22kHzMono    = SPSF_CCITT_uLaw_11kHzStereo  + 1
	CONST SPSF_CCITT_uLaw_22kHzStereo  = SPSF_CCITT_uLaw_22kHzMono    + 1
	CONST SPSF_CCITT_uLaw_44kHzMono    = SPSF_CCITT_uLaw_22kHzStereo  + 1
	CONST SPSF_CCITT_uLaw_44kHzStereo  = SPSF_CCITT_uLaw_44kHzMono    + 1
	CONST SPSF_ADPCM_8kHzMono          = SPSF_CCITT_uLaw_44kHzStereo  + 1
	CONST SPSF_ADPCM_8kHzStereo        = SPSF_ADPCM_8kHzMono          + 1
	CONST SPSF_ADPCM_11kHzMono         = SPSF_ADPCM_8kHzStereo        + 1
	CONST SPSF_ADPCM_11kHzStereo       = SPSF_ADPCM_11kHzMono         + 1
	CONST SPSF_ADPCM_22kHzMono         = SPSF_ADPCM_11kHzStereo       + 1
	CONST SPSF_ADPCM_22kHzStereo       = SPSF_ADPCM_22kHzMono         + 1
	CONST SPSF_ADPCM_44kHzMono         = SPSF_ADPCM_22kHzStereo       + 1
	CONST SPSF_ADPCM_44kHzStereo       = SPSF_ADPCM_44kHzMono         + 1
	CONST SPSF_GSM610_8kHzMono         = SPSF_ADPCM_44kHzStereo       + 1
	CONST SPSF_GSM610_11kHzMono        = SPSF_GSM610_8kHzMono         + 1
	CONST SPSF_GSM610_22kHzMono        = SPSF_GSM610_11kHzMono        + 1
	CONST SPSF_GSM610_44kHzMono        = SPSF_GSM610_22kHzMono        + 1
	CONST SPSF_NUM_FORMATS             = SPSF_GSM610_44kHzMono        + 1
	
	'EXTERN_C const GUID SPDFID_Text;
	'EXTERN_C const GUID SPDFID_WaveFormatEx;
	' Defined in sapiut.idl
	CONST SPDFID_Text = "{7CEEF9F9-3D13-11D2-9EE7-00C04F797396}"
	CONST SPDFID_WaveFormatEx = "{C31ADBAE-527F-4FF5-A230-F62BB61FF70C}"
	
	CONST SPREG_USER_ROOT                            = WSTR("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech")
	CONST SPREG_LOCAL_MACHINE_ROOT                   = WSTR("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech")
	CONST SPCAT_AUDIOOUT                             = WSTR("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\AudioOutput")
	CONST SPCAT_AUDIOIN                              = WSTR("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\AudioInput")
	CONST SPCAT_VOICES                               = WSTR("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\Voices")
	CONST SPCAT_RECOGNIZERS                          = WSTR("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\Recognizers")
	CONST SPCAT_APPLEXICONS                          = WSTR("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\AppLexicons")
	CONST SPCAT_PHONECONVERTERS                      = WSTR("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\PhoneConverters")
	CONST SPCAT_RECOPROFILES                         = WSTR("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech\RecoProfiles")
	CONST SPMMSYS_AUDIO_IN_TOKEN_ID                  = WSTR("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\AudioInput\TokenEnums\MMAudioIn\")
	CONST SPMMSYS_AUDIO_OUT_TOKEN_ID                 = WSTR("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\AudioOutput\TokenEnums\MMAudioOut\")
	CONST SPCURRENT_USER_LEXICON_TOKEN_ID            = WSTR("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech\CurrentUserLexicon")
	CONST SPCURRENT_USER_SHORTCUT_TOKEN_ID           = WSTR("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech\CurrentUserShortcut")
	CONST SPTOKENVALUE_CLSID                         = WSTR("CLSID")
	CONST SPTOKENKEY_FILES                           = WSTR("Files")
	CONST SPTOKENKEY_UI                              = WSTR("UI")
	CONST SPTOKENKEY_ATTRIBUTES                      = WSTR("Attributes")
	CONST SPTOKENKEY_RETAINEDAUDIO                   = WSTR("SecondsPerRetainedAudioEvent")
	CONST SPVOICECATEGORY_TTSRATE                    = WSTR("DefaultTTSRate")
	CONST SPPROP_RESOURCE_USAGE                      = WSTR("ResourceUsage")
	CONST SPPROP_HIGH_CONFIDENCE_THRESHOLD           = WSTR("HighConfidenceThreshold")
	CONST SPPROP_NORMAL_CONFIDENCE_THRESHOLD         = WSTR("NormalConfidenceThreshold")
	CONST SPPROP_LOW_CONFIDENCE_THRESHOLD            = WSTR("LowConfidenceThreshold")
	CONST SPPROP_RESPONSE_SPEED                      = WSTR("ResponseSpeed")
	CONST SPPROP_COMPLEX_RESPONSE_SPEED              = WSTR("ComplexResponseSpeed")
	CONST SPPROP_ADAPTATION_ON                       = WSTR("AdaptationOn")
	CONST SPPROP_PERSISTED_BACKGROUND_ADAPTATION     = WSTR("PersistedBackgroundAdaptation")
	CONST SPPROP_PERSISTED_LANGUAGE_MODEL_ADAPTATION = WSTR("PersistedLanguageModelAdaptation")
	CONST SPPROP_UX_IS_LISTENING                     = WSTR("UXIsListening")
	CONST SPTOPIC_SPELLING                           = WSTR("Spelling")
	CONST SPWILDCARD                                 = WSTR("...")
	CONST SPDICTATION                                = WSTR("*")
	CONST SPINFDICTATION                             = WSTR("*+")
	CONST SPREG_SAFE_USER_TOKENS                     = WSTR($"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\UserTokens")
	
	CONST SP_LOW_CONFIDENCE    = -1
	CONST SP_NORMAL_CONFIDENCE = 0
	CONST SP_HIGH_CONFIDENCE   = +1
	CONST DEFAULT_WEIGHT       = 1
	CONST SP_MAX_WORD_LENGTH   = 128
	CONST SP_MAX_PRON_LENGTH   = 384
	CONST SP_EMULATE_RESULT    = &h40000000
	
	'typedef void __stdcall SPNOTIFYCALLBACK(WPARAM wParam, LPARAM lParam);
	'SUB SPNOTIFYCALLBACK (BYVAL wParam AS DWORD, BYVAL lParam AS LONG)
	
	' enum SPEVENTLPARAMTYPE
	TYPE SPEVENTLPARAMTYPE AS LONG
	CONST SPET_LPARAM_IS_UNDEFINED = 0
	CONST SPET_LPARAM_IS_TOKEN     = SPET_LPARAM_IS_UNDEFINED + 1
	CONST SPET_LPARAM_IS_OBJECT    = SPET_LPARAM_IS_TOKEN     + 1
	CONST SPET_LPARAM_IS_POINTER   = SPET_LPARAM_IS_OBJECT    + 1
	CONST SPET_LPARAM_IS_STRING    = SPET_LPARAM_IS_POINTER   + 1
	
	'#define SPFEI_FLAGCHECK ( (1ui64 << SPEI_RESERVED1) | (1ui64 << SPEI_RESERVED2) )
	'#define SPFEI_ALL_TTS_EVENTS (0x000000000000FFFEui64 | SPFEI_FLAGCHECK)
	'#define SPFEI_ALL_SR_EVENTS  (0x001FFFFC00000000ui64 | SPFEI_FLAGCHECK)
	'#define SPFEI_ALL_EVENTS      0xEFFFFFFFFFFFFFFFui64
	'#define SPFEI(SPEI_ord) ((1ui64 << SPEI_ord) | SPFEI_FLAGCHECK)
	
	CONST SPFEI_FLAGCHECK =  9663676416ull
	CONST SPFEI_ALL_TTS_EVENTS =  9663741950ull
	CONST SPFEI_ALL_SR_EVENTS =  9007191738548224ull
	CONST SPFEI_ALL_EVENTS = &HEFFFFFFFFFFFFFFFull
	#define SPFEI(SPEI_ord) ((1ull shl SPEI_ord) OR SPFEI_FLAGCHECK)
	
	' // Size = 24 bytes
	TYPE SPSERIALIZEDEVENT   ' Must be 8 byte aligned
		eEventId             AS WORD    ' SPEVENTENUM
		elParamType          AS WORD    ' SPEVENTLPARAMTYPE
		ulStreamNum          AS ULONG
		ullAudioStreamOffset AS ULONGLONG
		SerializedwParam     AS ULONG
		SerializedlParam     AS LONG
	END TYPE
	
	' // Size = 32 bytes
	TYPE SPSERIALIZEDEVENT64   ' Must be 8 byte aligned
		eEventId             AS WORD    ' SPEVENTENUM
		elParamType          AS WORD    ' SPEVENTLPARAMTYPE
		ulStreamNum          AS ULONG   ' ULONG
		ullAudioStreamOffset AS ULONGLONG
		SerializedwParam     AS ULONGLONG
		SerializedlParam     AS LONGLONG
	END TYPE
	
	' // Size = 32 bytes
	TYPE SPEVENTEX   ' Must be 8 byte aligned
		eEventId             AS WORD    ' SPEVENTENUM
		elParamType          AS WORD    ' SPEVENTLPARAMTYPE
		ulStreamNum          AS ULONG
		ullAudioStreamOffset AS ULONGLONG
		wParam               AS WPARAM
		lParam               AS LPARAM
		ullAudioTimeOffset   AS ULONGLONG
	END TYPE
	
	' enum SPENDSRSTREAMFLAGS
	TYPE SPENDSRSTREAMFLAGS AS LONG
	CONST SPESF_NONE            = 0
	CONST SPESF_STREAM_RELEASED = 1   ' 1 << 0
	CONST SPESF_EMULATED        =  2   ' 1 << 1
	
	' enum SPVFEATURE
	TYPE SPVFEATURE AS LONG
	CONST SPVFEATURE_STRESSED   = 1   ' 1L << 0
	CONST SPVFEATURE_EMPHASIS   = 2   ' 1L << 1
	
	' enum SPDISPLYATTRIBUTES
	TYPE SPDISPLYATTRIBUTES AS LONG
	CONST SPAF_ONE_TRAILING_SPACE     = &h2
	CONST SPAF_TWO_TRAILING_SPACES    = &h4
	CONST SPAF_CONSUME_LEADING_SPACES = &h8
	CONST SPAF_ALL                    = &hf
	CONST SPAF_USER_SPECIFIED         = &h80
	
	'typedef WCHAR SPPHONEID;
	'typedef LPWSTR PSPPHONEID;
	'typedef LPCWSTR PCSPPHONEID;
	TYPE SPPHONEID AS WCHAR
	TYPE PSPPHONEID AS LPWSTR
	TYPE PCSPPHONEID AS LPCWSTR
	
	' enum SPPHRASEPROPERTYUNIONTYPE
	TYPE SPPHRASEPROPERTYUNIONTYPE AS LONG
	CONST SPPPUT_UNUSED      = 0
	CONST SPPPUT_ARRAY_INDEX = SPPPUT_UNUSED + 1
	
	' enum SPVALUETYPE
	TYPE SPVALUETYPE AS LONG
	CONST SPDF_PROPERTY      = &h1
	CONST SPDF_REPLACEMENT   = &h2
	CONST SPDF_RULE          = &h4
	CONST SPDF_DISPLAYTEXT   = &h8
	CONST SPDF_LEXICALFORM   = &h10
	CONST SPDF_PRONUNCIATION = &h20
	CONST SPDF_AUDIO         = &h40
	CONST SPDF_ALTERNATES    = &h80
	CONST SPDF_ALL           = &hff
	
	' enum SPPHRASERNG
	Type SPPHRASERNG As Long
	Const SPPR_ALL_ELEMENTS  = -1
	Const SP_GETWHOLEPHRASE = SPPR_ALL_ELEMENTS
	Const SPRR_ALL_ELEMENTS = SPPR_ALL_ELEMENTS
	
	Type SPSTATEHANDLE As Any Ptr
	
	' enum SPRECOEVENTFLAGS
	Type SPRECOEVENTFLAGS As Long
	Const SPREF_AutoPause        = 1    ' 1 << 0
	Const SPREF_Emulated         = 2    ' 1 << 1
	Const SPREF_SMLTimeout       = 4    ' 1 << 2
	Const SPREF_ExtendableParse  = 8    ' 1 << 3
	Const SPREF_ReSent           = 16   ' 1 << 4
	Const SPREF_Hypothesis       = 32   ' 1 << 5
	Const SPREF_FalseRecognition = 64   ' 1 << 6
	
	' enum SPPRONUNCIATIONFLAGS
	Type SPPRONUNCIATIONFLAGS As Long
	Const ePRONFLAG_USED    = 1   '  1 << 0
	
	Type SPVPITCH
		MiddleAdj As Long
		RangeAdj  As Long
	End Type
	
	' enum SPVACTIONS
	Type SPVACTIONS As Long
	Const SPVA_Speak           = 0
	Const SPVA_Silence         = SPVA_Speak     + 1
	Const SPVA_Pronounce       = SPVA_Silence   + 1
	Const SPVA_Bookmark        = SPVA_Pronounce + 1
	Const SPVA_SpellOut        = SPVA_Bookmark  + 1
	Const SPVA_Section         = SPVA_SpellOut  + 1
	Const SPVA_ParseUnknownTag = SPVA_Section   + 1
	
	Type SPVCONTEXT
		pCategory AS LPCWSTR
		pBefore   AS LPCWSTR
		pAfter    AS LPCWSTR
	END TYPE
	
	TYPE SPVSTATE
		eAction       AS LONG           ' SPVACTIONS
		LangID        AS WORD           ' WORD
		wReserved     AS WORD           ' WORD
		EmphAdj       AS LONG           ' long
		RateAdj       AS LONG           ' long
		Volume        AS ULONG          ' ULONG
		PitchAdj      AS SPVPITCH       ' SPVPITCH
		SilenceMSecs  AS ULONG          ' ULONG
		pPhoneIds     AS WCHAR PTR      ' SPPHONEID *
		ePartOfSpeech AS LONG           ' SPPARTOFSPEECH enum
		Context       AS SPVCONTEXT     ' SPVCONTEXT
	END TYPE
	
	' enum SPRUNSTATE
	TYPE SPRUNSTATE AS LOG
	CONST SPRS_DONE        = 1   ' 1L << 0
	CONST SPRS_IS_SPEAKING = 2   ' 1L << 1
	
	' enum SPVLIMITS
	TYPE SPVLIMITS AS LONG
	CONST SPMIN_VOLUME = 0
	CONST SPMAX_VOLUME = 100
	CONST SPMIN_RATE   = -10
	CONST SPMAX_RATE   = 10
	
	' enum SPEAKFLAGS
	TYPE SPEAKFLAGS AS LONG
	CONST SPF_DEFAULT          = 0
	CONST SPF_ASYNC            = &h1                                                                                                                                                             ' 1L << 0
	CONST SPF_PURGEBEFORESPEAK = &h2                                                                                                                                                             ' 1L << 1
	CONST SPF_IS_FILENAME      = &h4                                                                                                                                                             ' 1L << 2
	CONST SPF_IS_XML           = &h8                                                                                                                                                             ' 1L << 3
	CONST SPF_IS_NOT_XML       = &h10                                                                                                                                                            ' 1L << 4
	CONST SPF_PERSIST_XML      = &h20                                                                                                                                                            ' 1L << 5
	CONST SPF_NLP_SPEAK_PUNC   = &h40                                                                                                                                                            ' 1L << 6
	CONST SPF_NLP_MASK         = SPF_NLP_SPEAK_PUNC
	CONST SPF_VOICE_MASK       = SPF_ASYNC OR SPF_PURGEBEFORESPEAK OR SPF_IS_FILENAME OR SPF_IS_XML OR SPF_IS_NOT_XML OR SPF_NLP_MASK OR SPF_PERSIST_XML
	CONST SPF_UNUSED_FLAGS     = NOT SPF_VOICE_MASK
	
	' enum SPCOMMITFLAGS
	TYPE SPCOMMITFLAGS AS LONG
	CONST SPCF_NONE                = 0
	CONST SPCF_ADD_TO_USER_LEXICON = 1   ' 1 << 0
	CONST SPCF_DEFINITE_CORRECTION = 2   ' 1 << 1
	
	CONST SP_STREAMPOS_ASAP = 0
	CONST SP_STREAMPOS_REALTIME = -1
	
	CONST SPRULETRANS_TEXTBUFFER = &hFFFFFFFF   ' (SPSTATEHANDLE)(-1)
	CONST SPRULETRANS_WILDCARD   = &hFFFFFFFE   ' (SPSTATEHANDLE)(-2)
	CONST SPRULETRANS_DICTATION  = &hFFFFFFFD   ' (SPSTATEHANDLE)(-3)
	
	' enum SPCFGRULEATTRIBUTES
	TYPE SPCFGRULEATTRIBUTES AS LONG
	CONST SPRAF_TopLevel      = &h1       ' 1 << 0
	CONST SPRAF_Active        = &h2       ' 1 << 1
	CONST SPRAF_Export        = &h4       ' 1 << 2
	CONST SPRAF_Import        = &h8       ' 1 << 3
	CONST SPRAF_Interpreter   = &h10      ' 1 << 4
	CONST SPRAF_Dynamic       = &h20      ' 1 << 5
	CONST SPRAF_Root          = &h40      ' 1 << 6
	CONST SPRAF_AutoPause     = &h10000   ' 1 << 16
	CONST SPRAF_UserDelimited = &h20000   ' 1 << 17
	
	' enum SPMATCHINGMODE
	TYPE SPMATCHINGMODE AS LONG
	CONST AllWords                     = 0
	CONST Subsequence                  = 1
	CONST OrderedSubset                = 3
	CONST SubsequenceContentRequired   = 5
	CONST OrderedSubsetContentRequired = 7
	
	' enum PHONETICALPHABET
	TYPE PHONETICALPHABET AS LONG
	CONST PA_Ipa   = 0
	CONST PA_Ups   = 1
	CONST PA_Sapi  = 2
	
	' enum SPGRAMMAROPTIONS
	TYPE SPGRAMMAROPTIONS AS LONG
	CONST SPGO_SAPI            = &h1
	CONST SPGO_SRGS            = &h2
	CONST SPGO_UPS             = &h4
	CONST SPGO_SRGS_MS_SCRIPT  = &h8
	CONST SPGO_SRGS_W3C_SCRIPT = &h100
	CONST SPGO_SRGS_STG_SCRIPT = &h200
	CONST SPGO_SRGS_SCRIPT     = (((SPGO_SRGS OR SPGO_SRGS_MS_SCRIPT) OR SPGO_SRGS_W3C_SCRIPT) OR SPGO_SRGS_STG_SCRIPT)
	CONST SPGO_FILE            = &h10
	CONST SPGO_HTTP            = &h20
	CONST SPGO_RES             = &h40
	CONST SPGO_OBJECT          = &h80
	CONST SPGO_DEFAULT         = &h3fb
	CONST SPGO_ALL             = &h3ff
	
	' enum SPADAPTATIONSETTINGS
	TYPE SPADAPTATIONSETTINGS AS LONG
	CONST SPADS_Default              = 0
	CONST SPADS_CurrentRecognizer    = &h1
	CONST SPADS_RecoProfile          = &h2
	CONST SPADS_Immediate            = &h4
	CONST SPADS_Reset                = &h8
	CONST SPADS_HighVolumeDataSource = &h10
	
	CONST SP_MAX_LANGIDS = 20
	
	TYPE SPNORMALIZATIONLIST
		ulSize              AS ULONG          ' ULONG
		ppszzNormalizedList AS WCHAR PTR PTR  ' WCHAR **
	END TYPE
	
	' // Modules
	
	' // Module: SpeechConstants
	' // IID: {F3E092B2-6BDC-410F-BCB2-4C5ED4424180}
	' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
	' // Number of constants: 6
	CONST Speech_Default_Weight = 1   ' DEFAULT_WEIGHT
	CONST Speech_Max_Word_Length = 128   ' (&h00000080) SP_MAX_WORD_LENGTH
	CONST Speech_Max_Pron_Length = 384   ' (&h00000180) SP_MAX_PRON_LENGTH
	CONST Speech_StreamPos_Asap = 0   ' (&h00000000) SP_STREAMPOS_ASAP
	CONST Speech_StreamPos_RealTime = -1   ' (&hFFFFFFFF) SP_STREAMPOS_REALTIME
	CONST SpeechAllElements = -1   ' (&hFFFFFFFF) SPPR_ALL_ELEMENTS
	
	' // Module: SpeechStringConstants
	' // IID: {E58442E4-0C80-402C-9559-867337A39765}
	' // Documentation string: Afx_ISpeechLexiconPronunciation Interface
	' // Number of constants: 36
	CONST SpeechRegistryUserRoot = WSTR("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech")
	CONST SpeechRegistryLocalMachineRoot = WSTR("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech")
	CONST SpeechCategoryAudioOut = WSTR("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\AudioOutput")
	CONST SpeechCategoryAudioIn = WSTR("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\AudioInput")
	CONST SpeechCategoryVoices = WSTR("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\Voices")
	CONST SpeechCategoryRecognizers = WSTR("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\Recognizers")
	CONST SpeechCategoryAppLexicons = WSTR("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\AppLexicons")
	CONST SpeechCategoryPhoneConverters = WSTR("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\PhoneConverters")
	CONST SpeechCategoryRecoProfiles = WSTR("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech\RecoProfiles")
	CONST SpeechTokenIdUserLexicon = WSTR("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech\CurrentUserLexicon")
	CONST SpeechTokenValueCLSID = WSTR("CLSID")
	CONST SpeechTokenKeyFiles = WSTR("Files")
	CONST SpeechTokenKeyUI = WSTR("UI")
	CONST SpeechTokenKeyAttributes = WSTR("Attributes")
	CONST SpeechVoiceCategoryTTSRate = WSTR("DefaultTTSRate")
	CONST SpeechPropertyResourceUsage = WSTR("ResourceUsage")
	CONST SpeechPropertyHighConfidenceThreshold = WSTR("HighConfidenceThreshold")
	CONST SpeechPropertyNormalConfidenceThreshold = WSTR("NormalConfidenceThreshold")
	CONST SpeechPropertyLowConfidenceThreshold = WSTR("LowConfidenceThreshold")
	CONST SpeechPropertyResponseSpeed = WSTR("ResponseSpeed")
	CONST SpeechPropertyComplexResponseSpeed = WSTR("ComplexResponseSpeed")
	CONST SpeechPropertyAdaptationOn = WSTR("AdaptationOn")
	CONST SpeechDictationTopicSpelling = WSTR("Spelling")
	CONST SpeechGrammarTagWildcard = WSTR("...")
	CONST SpeechGrammarTagDictation = WSTR("*")
	CONST SpeechGrammarTagUnlimitedDictation = WSTR("*+")
	CONST SpeechEngineProperties = WSTR("EngineProperties")
	CONST SpeechAddRemoveWord = WSTR("AddRemoveWord")
	CONST SpeechUserTraining = WSTR("UserTraining")
	CONST SpeechMicTraining = WSTR("MicTraining")
	CONST SpeechRecoProfileProperties = WSTR("RecoProfileProperties")
	CONST SpeechAudioProperties = WSTR("AudioProperties")
	CONST SpeechAudioVolume = WSTR("AudioVolume")
	CONST SpeechVoiceSkipTypeSentence = WSTR("Sentence")
	Const SpeechAudioFormatGUIDWave = WStr("{C31ADBAE-527F-4ff5-A230-F62BB61FF70C}")
	Const SpeechAudioFormatGUIDText = WStr("{7CEEF9F9-3D13-11d2-9EE7-00C04F797396}")
	
	Const SPDUI_EngineProperties      = WStr("EngineProperties")
	Const SPDUI_AddRemoveWord         = WStr("AddRemoveWord")
	Const SPDUI_UserTraining          = WStr("UserTraining")
	Const SPDUI_MicTraining           = WStr("MicTraining")
	Const SPDUI_RecoProfileProperties = WStr("RecoProfileProperties")
	Const SPDUI_AudioProperties       = WStr("AudioProperties")
	Const SPDUI_AudioVolume           = WStr("AudioVolume")
	Const SPDUI_UserEnrollment        = WStr("UserEnrollment")
	Const SPDUI_ShareData             = WStr("ShareData")
	Const SPDUI_Tutorial              = WStr("Tutorial")
	
	
	' // Structures and unions
	
	Type SPAUDIOBUFFERINFO
		' // Documentation string: Afx_ISpAudio Interface
		' // Number of members: 3
		ulMsMinNotification As ULong
		ulMsBufferSize As ULong
		ulMsEventBias As ULong
	End Type
	
	Type SPAUDIOSTATUS
		' // Documentation string: Afx_ISpAudio Interface
		' // Number of members: 7
		cbFreeBuffSpace As Long
		cbNonBlockingIO As ULong
		State As ULong
		CurSeekPos As ULongInt
		CurDevicePos As ULongInt
		dwAudioLevel As ULong
		dwReserved2 As ULong
	End Type
	
	Type SPBINARYGRAMMAR
		' // Documentation string: Afx_ISpGrammarBuilder Interface
		' // Number of members: 1
		ulTotalSerializedSize AS ULONG
	END TYPE
	
	TYPE SPEVENT
		' // Documentation string: Afx_ISpNotifySource Interface
		' // Number of members: 6
		eEventId AS USHORT
		elParamType AS USHORT
		ulStreamNum AS ULONG
		ullAudioStreamOffset AS ULONGINT
		wParam AS ULONGINT
		lParam AS ULONGINT
	END TYPE
	
	' // Size = 24 bytes
	TYPE SPEVENTSOURCEINFO
		' // Documentation string: Afx_ISpNotifySource Interface
		' // Number of members: 3
		ullEventInterest AS ULONGINT
		ullQueuedInterest AS ULONGINT
		ulCount AS ULONG
	END TYPE
	
	TYPE SPPHRASE
		' // Documentation string: Afx_ISpPhrase Interface
		' // Number of members: 20
		cbSize AS ULONG
		LangId AS USHORT
		wHomophoneGroupId AS USHORT
		ullGrammarID AS ULONGINT
		ftStartTime AS ULONGINT
		ullAudioStreamPosition AS ULONGINT
		ulAudioSizeBytes AS ULONG
		ulRetainedSizeBytes AS ULONG
		ulAudioSizeTime AS ULONG
		Rule AS ULONG
		pProperties AS ULONG PTR
		pElements AS ULONG PTR PTR
		cReplacements AS ULONG
		pReplacements AS ULONG PTR
		SREngineID AS ULONG PTR
		ulSREnginePrivateDataSize AS ULONG
		pSREnginePrivateData AS UBYTE PTR
		pSML AS WSTRING PTR
		pSemanticErrorInfo AS WSTRING PTR
		SemanticTagFormat AS SPSEMANTICFORMAT
	END TYPE
	
	' // Size = 44 bytes
	TYPE SPPHRASEELEMENT
		' // Documentation string: Afx_ISpPhrase Interface
		' // Number of members: 14
		ulAudioTimeOffset AS ULONG
		ulAudioSizeTime AS ULONG
		ulAudioStreamOffset AS ULONG
		ulAudioSizeBytes AS ULONG
		ulRetainedStreamOffset AS ULONG
		ulRetainedSizeBytes AS ULONG
		pszDisplayText AS WCHAR PTR   ' const WCHAR *
		pszLexicalForm AS WCHAR PTR   ' const WCHAR *
		pszPronunciation AS WCHAR PTR   ' const SPPHONEID *
		bDisplayAttributes AS UBYTE
		RequiredConfidence AS BYTE
		ActualConfidence AS BYTE
		reserved AS UBYTE
		SREngineConfidence AS SINGLE
	END TYPE
	
	' // Size = 56 bytes (in 32-bit)
	TYPE SPPHRASEPROPERTY   ' Must be 8 byte aligned
		' // Documentation string: Afx_ISpPhrase Interface
		' // Number of members: 10
		pszName AS WSTRING PTR
		UNION
			ulId AS ULONG
			TYPE
				bType AS UBYTE
				bReserved AS UBYTE
				usArrayIndex AS USHORT
			END TYPE
		END UNION
		pszValue AS WSTRING PTR
		vValue AS VARIANT
		ulFirstElement AS ULONG
		ulCountOfElements AS ULONG
		pNextSibling AS SPPHRASEPROPERTY PTR   ' const SPPHRASEPROPERTY *
		pFirstChild AS SPPHRASEPROPERTY PTR   ' const SPPHRASEPROPERTY *
		SREngineConfidence AS SINGLE
		Confidence AS BYTE
	END TYPE
	
	TYPE SPPHRASEREPLACEMENT
		' // Documentation string: Afx_ISpPhrase Interface
		' // Number of members: 4
		bDisplayAttributes As UByte
		pszReplacementText As WCHAR Ptr   ' const WCHAR *
		ulFirstElement As ULong
		ulCountOfElements As ULong
	End Type
	
	' // Size = 32 bytes
	Type SPPHRASERULE
		' // Documentation string: Afx_ISpPhrase Interface
		' // Number of members: 8
		pszName As WString Ptr
		ulId As ULong
		ulFirstElement As ULong
		ulCountOfElements As ULong
		pNextSibling As SPPHRASERULE Ptr
		pFirstChild As SPPHRASERULE Ptr
		SREngineConfidence As Single
		Confidence As Byte
	End Type
	
	Type SPRECOCONTEXTSTATUS
		' // Documentation string: Afx_ISpGrammarBuilder Interface
		' // Number of members: 4
		eInterference As SPINTERFERENCE
		szRequestTypeOfUI (0 To 254) As WCHAR
		dwReserved1 As DWORD
		dwReserved2 As DWORD
	End Type
	
	Type SPRECOGNIZERSTATUS
		' // Documentation string: Afx_ISpProperties Interface
		' // Number of members: 8
		AudioStatus As SPAUDIOSTATUS
		ullRecognitionStreamPos As ULONGLONG
		ulStreamNumber As ULong
		ulNumActive As ULong
		ClsidEngine As ULong
		cLangIDs AS ULONG
		aLangID (0 TO 19) AS LANGID
		ullRecognitionStreamTime AS ULONGLONG
	END TYPE
	
	TYPE SPRECORESULTTIMES
		' // Documentation string: Afx_ISpRecoResult Interface
		' // Number of members: 4
		ftStreamTime AS FILETIME
		ullLength AS ULONGINT
		dwTickCount AS ULONG
		ullStart AS ULONGINT
	END TYPE
	
	TYPE SPRULE
		' // Documentation string: Afx_ISpRecoGrammar2 Interface
		' // Number of members: 3
		pszRuleName AS WSTRING PTR
		ulRuleId AS ULONG
		dwAttributes AS ULONG
	END TYPE
	
	TYPE SPSEMANTICERRORINFO
		' // Documentation string: Afx_ISpPhrase Interface
		' // Number of members: 5
		ulLineNumber AS ULONG
		pszScriptLine AS WSTRING PTR
		pszSource AS WSTRING PTR
		pszDescription AS WSTRING PTR
		hrResultCode AS HRESULT
	END TYPE
	
	TYPE SPSERIALIZEDPHRASE
		' // Documentation string: Afx_ISpPhrase Interface
		' // Number of members: 1
		ulSerializedSize AS ULONG
	END TYPE
	
	TYPE SPSERIALIZEDRESULT
		' // Documentation string: Afx_ISpGrammarBuilder Interface
		' // Number of members: 1
		ulSerializedSize AS ULONG
	END TYPE
	
	TYPE SPSHORTCUTPAIR
		' // Documentation string: Afx_ISpShortcut Interface
		' // Number of members: 5
		pNextSHORTCUTPAIR AS SPSHORTCUTPAIR PTR
		LangId AS USHORT
		shType AS SPSHORTCUTTYPE
		pszDisplay AS WSTRING PTR
		pszSpoken AS WSTRING PTR
	END TYPE
	
	TYPE SPSHORTCUTPAIRLIST
		' // Documentation string: Afx_ISpShortcut Interface
		' // Number of members: 3
		ulSize AS ULONG
		pvBuffer AS UBYTE PTR
		pFirstShortcutPair AS SPSHORTCUTPAIR PTR
	END TYPE
	
	TYPE SPVOICESTATUS
		' // Documentation string: Afx_ISpVoice Interface
		' // Number of members: 13
		ulCurrentStream AS ULONG
		ulLastStreamQueued AS ULONG
		hrLastResult AS HRESULT
		dwRunningState AS ULONG
		ulInputWordPos AS ULONG
		ulInputWordLen AS ULONG
		ulInputSentPos AS ULONG
		ulInputSentLen AS ULONG
		lBookmarkId AS LONG
		PhonemeId AS USHORT   ' SPPHONEID
		VisemeId AS SPVISEMES
		dwReserved1 AS DWORD
		dwReserved2 AS DWORD
	END TYPE
	
	TYPE SPWORDPRONUNCIATION
		' // Documentation string: Afx_ISpLexicon Interface
		' // Number of members: 6
		pNextWordPronunciation AS SPWORDPRONUNCIATION PTR   ' struct SPWORDPRONUNCIATION *
		eLexiconType AS SPLEXICONTYPE   ' SPLEXICONTYPE enum
		LangId AS LANGID
		wPronunciationFlags AS WORD
		ePartOfSpeech AS SPPARTOFSPEECH   ' SPPARTOFSPEECH enum
		szPronunciation (0 TO 0) AS WCHAR   ' SPPHONEID szPronunciation[ 1 ]
	END TYPE
	
	TYPE SPWORD
		' // Documentation string: Afx_ISpLexicon Interface
		' // Number of members: 6
		pNextWord AS SPWORD PTR
		LangId AS USHORT
		wReserved AS USHORT
		eWordType AS SPWORDTYPE
		pszWord AS WSTRING PTR
		pFirstWordPronunciation AS SPWORDPRONUNCIATION PTR
	END TYPE
	
	TYPE SPWORDLIST
		' // Documentation string: Afx_ISpLexicon Interface
		' // Number of members: 3
		ulSize AS ULONG
		pvBuffer AS UBYTE PTR
		pFirstWord AS SPWORD PTR
	END TYPE
	
	TYPE SPWORDPRONUNCIATIONLIST
		' // Documentation string: Afx_ISpLexicon Interface
		' // Number of members: 3
		ulSize AS ULONG
		pvBuffer AS UBYTE PTR
		pFirstWordPronunciation AS SPWORDPRONUNCIATION PTR
	END TYPE
	
	TYPE tagSPPROPERTYINFO
		' // Documentation string: Afx_ISpGrammarBuilder Interface
		' // Number of members: 4
		pszName AS WCHAR PTR   ' const WCHAR *
		ulId AS ULONG
		pszValue AS WCHAR PTR   ' const WCHAR *
		vValue AS VARIANT
	END TYPE
	
	TYPE tagSPTEXTSELECTIONINFO
		' // Documentation string: Afx_ISpGrammarBuilder Interface
		' // Number of members: 4
		ulStartActiveOffset AS ULONG
		cchActiveChars AS ULONG
		ulStartSelection AS ULONG
		cchSelection AS ULONG
	END TYPE
	
	TYPE tagSTATSTG
		' // Documentation string: Afx_ISpStreamFormat Interface
		' // Number of members: 11
		pwcsName AS WSTRING PTR
		Type AS ULONG
		cbSize AS ULONG
		mtime AS ULONG
		ctime AS ULONG
		atime AS ULONG
		grfMode AS ULONG
		grfLocksSupported AS ULONG
		clsid AS ULONG
		grfStateBits AS ULONG
		reserved AS ULONG
	END TYPE
	
	TYPE WaveFormatEx
		' // Documentation string: Afx_ISpStreamFormat Interface
		' // Number of members: 7
		wFormatTag AS USHORT
		nChannels AS USHORT
		nSamplesPerSec AS ULONG
		nAvgBytesPerSec AS ULONG
		nBlockAlign AS USHORT
		wBitsPerSample AS USHORT
		cbSize AS USHORT
	END TYPE
	
	
	' // Interfaces - Forward references
	
	TYPE Afx_IEnumSpObjectTokens AS Afx_IEnumSpObjectTokens_
	TYPE Afx_ISpAudio AS Afx_ISpAudio_
	TYPE Afx_ISpDataKey AS Afx_ISpDataKey_
	TYPE Afx_ISpEventSink AS Afx_ISpEventSink_
	TYPE Afx_ISpEventSource AS Afx_ISpEventSource_
	TYPE Afx_ISpGrammarBuilder AS Afx_ISpGrammarBuilder_
	TYPE Afx_ISpLexicon AS Afx_ISpLexicon_
	TYPE Afx_ISpMMSysAudio AS Afx_ISpMMSysAudio_
	TYPE Afx_ISpNotifySink AS Afx_ISpNotifySink_
	TYPE Afx_ISpNotifySource AS Afx_ISpNotifySource_
	TYPE Afx_ISpNotifyTranslator AS Afx_ISpNotifyTranslator_
	TYPE Afx_ISpObjectToken AS Afx_ISpObjectToken_
	TYPE Afx_ISpObjectTokenCategory AS Afx_ISpObjectTokenCategory_
	TYPE Afx_ISpObjectWithToken AS Afx_ISpObjectWithToken_
	TYPE Afx_ISpPhoneConverter AS Afx_ISpPhoneConverter_
	TYPE Afx_ISpPhoneticAlphabetConverter AS Afx_ISpPhoneticAlphabetConverter_
	TYPE Afx_ISpPhoneticAlphabetSelection AS Afx_ISpPhoneticAlphabetSelection_
	TYPE Afx_ISpPhrase AS Afx_ISpPhrase_
	TYPE Afx_ISpPhraseAlt AS Afx_ISpPhraseAlt_
	TYPE Afx_ISpProperties AS Afx_ISpProperties_
	TYPE Afx_ISpRecoCategory AS Afx_ISpRecoCategory_
	TYPE Afx_ISpRecoContext AS Afx_ISpRecoContext_
	TYPE Afx_ISpRecoContext2 AS Afx_ISpRecoContext2_
	TYPE Afx_ISpRecognizer AS Afx_ISpRecognizer_
	TYPE Afx_ISpRecognizer2 AS Afx_ISpRecognizer2_
	TYPE Afx_ISpRecognizer3 AS Afx_ISpRecognizer3_
	TYPE Afx_ISpRecoGrammar AS Afx_ISpRecoGrammar_
	TYPE Afx_ISpRecoGrammar2 AS Afx_ISpRecoGrammar2_
	TYPE Afx_ISpRecoResult AS Afx_ISpRecoResult_
	TYPE Afx_ISpResourceManager AS Afx_ISpResourceManager_
	TYPE Afx_ISpSerializeState AS Afx_ISpSerializeState_
	TYPE Afx_ISpShortcut AS Afx_ISpShortcut_
	TYPE Afx_ISpStream AS Afx_ISpStream_
	TYPE Afx_ISpStreamFormat AS Afx_ISpStreamFormat_
	TYPE Afx_ISpStreamFormatConverter AS Afx_ISpStreamFormatConverter_
	TYPE Afx_ISpVoice AS Afx_ISpVoice_
	TYPE ISpXMLRecoResult AS ISpXMLRecoResult_
	
	' // Dual interfaces - Forward references
	
	TYPE Afx_ISpeechAudio AS Afx_ISpeechAudio_
	TYPE Afx_ISpeechAudioBufferInfo AS Afx_ISpeechAudioBufferInfo_
	TYPE Afx_ISpeechAudioFormat AS Afx_ISpeechAudioFormat_
	TYPE Afx_ISpeechAudioStatus AS Afx_ISpeechAudioStatus_
	Type Afx_ISpeechBaseStream As Afx_ISpeechBaseStream_
	Type Afx_ISpeechCustomStream As Afx_ISpeechCustomStream_
	Type Afx_ISpeechDataKey As Afx_ISpeechDataKey_
	Type Afx_ISpeechFileStream As Afx_ISpeechFileStream_
	Type Afx_ISpeechGrammarRule As Afx_ISpeechGrammarRule_
	Type Afx_ISpeechGrammarRules As Afx_ISpeechGrammarRules_
	Type Afx_ISpeechGrammarRuleState As Afx_ISpeechGrammarRuleState_
	Type Afx_ISpeechGrammarRuleStateTransition As Afx_ISpeechGrammarRuleStateTransition_
	Type Afx_ISpeechGrammarRuleStateTransitions As Afx_ISpeechGrammarRuleStateTransitions_
	Type Afx_ISpeechLexicon As Afx_ISpeechLexicon_
	Type Afx_ISpeechLexiconPronunciation As Afx_ISpeechLexiconPronunciation_
	Type Afx_ISpeechLexiconPronunciations As Afx_ISpeechLexiconPronunciations_
	Type Afx_ISpeechLexiconWord As Afx_ISpeechLexiconWord_
	Type Afx_ISpeechLexiconWords As Afx_ISpeechLexiconWords_
	Type Afx_ISpeechMemoryStream As Afx_ISpeechMemoryStream_
	Type Afx_ISpeechMMSysAudio As Afx_ISpeechMMSysAudio_
	Type Afx_ISpeechObjectToken As Afx_ISpeechObjectToken_
	Type Afx_ISpeechObjectTokenCategory As Afx_ISpeechObjectTokenCategory_
	Type Afx_ISpeechObjectTokens As Afx_ISpeechObjectTokens_
	Type Afx_ISpeechPhoneConverter As Afx_ISpeechPhoneConverter_
	Type Afx_ISpeechPhraseAlternate As Afx_ISpeechPhraseAlternate_
	Type Afx_ISpeechPhraseAlternates As Afx_ISpeechPhraseAlternates_
	Type Afx_ISpeechPhraseElement As Afx_ISpeechPhraseElement_
	Type Afx_ISpeechPhraseElements As Afx_ISpeechPhraseElements_
	Type Afx_ISpeechPhraseInfo As Afx_ISpeechPhraseInfo_
	Type Afx_ISpeechPhraseInfoBuilder As Afx_ISpeechPhraseInfoBuilder_
	Type Afx_ISpeechPhraseProperties As Afx_ISpeechPhraseProperties_
	Type Afx_ISpeechPhraseProperty As Afx_ISpeechPhraseProperty_
	Type Afx_ISpeechPhraseReplacement As Afx_ISpeechPhraseReplacement_
	Type Afx_ISpeechPhraseReplacements As Afx_ISpeechPhraseReplacements_
	Type Afx_ISpeechPhraseRule As Afx_ISpeechPhraseRule_
	Type Afx_ISpeechPhraseRules As Afx_ISpeechPhraseRules_
	Type Afx_ISpeechRecoContext As Afx_ISpeechRecoContext_
	Type Afx_ISpeechRecognizer As Afx_ISpeechRecognizer_
	Type Afx_ISpeechRecognizerStatus As Afx_ISpeechRecognizerStatus_
	Type Afx_ISpeechRecoGrammar As Afx_ISpeechRecoGrammar_
	Type Afx_ISpeechRecoResult As Afx_ISpeechRecoResult_
	Type Afx_ISpeechRecoResult2 As Afx_ISpeechRecoResult2_
	TYPE Afx_ISpeechRecoResultDispatch AS Afx_ISpeechRecoResultDispatch_
	TYPE Afx_ISpeechRecoResultTimes AS Afx_ISpeechRecoResultTimes_
	TYPE Afx_ISpeechResourceLoader AS Afx_ISpeechResourceLoader_
	TYPE Afx_ISpeechTextSelectionInformation AS Afx_ISpeechTextSelectionInformation_
	TYPE Afx_ISpeechVoice AS Afx_ISpeechVoice_
	TYPE Afx_ISpeechVoiceStatus AS Afx_ISpeechVoiceStatus_
	TYPE Afx_ISpeechWaveFormatEx AS Afx_ISpeechWaveFormatEx_
	TYPE Afx_ISpeechXMLRecoResult AS Afx_ISpeechXMLRecoResult_
	
	' // Interfaces
	
	' ########################################################################################
	' Interface name: Afx_IEnumSpObjectTokens
	' IID: {06B64F9E-7FDA-11D2-B4F2-00C04F797396}
	' Documentation string: Afx_IEnumSpObjectTokens Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 6
	' ########################################################################################
	
	#ifndef __Afx_IEnumSpObjectTokens_INTERFACE_DEFINED__
		#define __Afx_IEnumSpObjectTokens_INTERFACE_DEFINED__
		
		TYPE Afx_IEnumSpObjectTokens_ EXTENDS Afx_IUnknown
			DECLARE ABSTRACT FUNCTION Next_ (BYVAL celt AS ULONG, BYVAL pelt AS Afx_ISpObjectToken PTR PTR, BYVAL pceltFetched AS ULONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Skip (BYVAL celt AS ULONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION Reset () AS HRESULT
			DECLARE ABSTRACT FUNCTION Clone (BYVAL ppEnum AS Afx_IEnumSpObjectTokens PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Item (BYVAL Index AS ULONG, BYVAL ppToken AS Afx_ISpObjectToken PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetCount (BYVAL pCount AS ULONG PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpStreamFormat
	' IID: {BED530BE-2606-4F4D-A1C0-54C5CDA5566F}
	' Documentation string: Afx_ISpStreamFormat Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IStream
	' Number of methods = 1
	' ########################################################################################
	
	#ifndef __Afx_ISpStreamFormat_INTERFACE_DEFINED__
		#define __Afx_ISpStreamFormat_INTERFACE_DEFINED__
		
		TYPE Afx_ISpStreamFormat_ EXTENDS Afx_IUnknown
			' // ISequentialStream interface
			DECLARE ABSTRACT FUNCTION Read (BYVAL pv AS CONST ANY PTR, BYVAL cb AS ULONG, BYVAL pcbRead AS ULONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Write (BYVAL pv AS CONST ANY PTR, BYVAL cb AS ULONG, BYVAL pcbWritten AS ULONG PTR) AS HRESULT
			' // IStream interface
			DECLARE ABSTRACT FUNCTION Seek (BYVAL dlibMove AS _LARGE_INTEGER, BYVAL dwOrigin AS ULONG, BYVAL plibNewPosition AS _ULARGE_INTEGER PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetSize (BYVAL libNewSize AS _ULARGE_INTEGER) AS HRESULT
			DECLARE ABSTRACT FUNCTION CopyTo (BYVAL pstm AS IStream PTR, BYVAL cb AS _ULARGE_INTEGER, BYVAL pcbRead AS _ULARGE_INTEGER PTR, BYVAL pcbWritten AS _ULARGE_INTEGER PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Commit (BYVAL grfCommitFlags AS ULONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION Revert () AS HRESULT
			DECLARE ABSTRACT FUNCTION LockRegion (BYVAL libOffset AS _ULARGE_INTEGER, BYVAL cb AS _ULARGE_INTEGER, BYVAL dwLockType AS ULONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION UnlockRegion (BYVAL libOffset AS _ULARGE_INTEGER, BYVAL cb AS _ULARGE_INTEGER, BYVAL dwLockType AS ULONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION Stat (BYVAL pstatstg AS tagSTATSTG PTR, BYVAL grfStatFlag AS ULONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION Clone (BYVAL ppstm AS IStream PTR PTR) AS HRESULT
			' // ISpStreamFormat iterface
			DECLARE ABSTRACT FUNCTION GetFormat (BYVAL pguidFormatId AS GUID PTR, BYVAL ppCoMemWaveFormatEx AS WaveFormatEx PTR PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpAudio
	' IID: {C05C768F-FAE8-4EC2-8E07-338321C12452}
	' Documentation string: Afx_ISpAudio Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = Afx_ISpStreamFormat
	' Number of methods = 11
	' ########################################################################################
	
	#ifndef __Afx_ISpAudio_INTERFACE_DEFINED__
		#define __Afx_ISpAudio_INTERFACE_DEFINED__
		
		TYPE Afx_ISpAudio_ EXTENDS Afx_ISpStreamFormat
			DECLARE ABSTRACT FUNCTION SetState (BYVAL NewState AS SPAUDIOSTATE, BYVAL ullReserved AS ULONGINT) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetFormat (BYVAL rguidFmtId AS GUID PTR, BYVAL pWaveFormatEx AS WaveFormatEx PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetStatus (BYVAL pStatus AS SPAUDIOSTATUS PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetBufferInfo (BYVAL pBuffInfo AS SPAUDIOBUFFERINFO PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetBufferInfo (BYVAL pBuffInfo AS SPAUDIOBUFFERINFO PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetDefaultFormat (BYVAL pFormatId AS GUID PTR, BYVAL ppCoMemWaveFormatEx AS WaveFormatEx PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION EventHandle () AS HRESULT
			DECLARE ABSTRACT FUNCTION GetVolumeLevel (BYVAL pLevel AS ULONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetVolumeLevel (BYVAL Level AS ULONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetBufferNotifySize (BYVAL pcbSize AS ULONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetBufferNotifySize (BYVAL cbSize AS ULONG) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpDataKey
	' IID: {14056581-E16C-11D2-BB90-00C04F8EE6C0}
	' Documentation string: Afx_ISpDataKey Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 12
	' ########################################################################################
	
	#ifndef __Afx_ISpDataKey_INTERFACE_DEFINED__
		#define __Afx_ISpDataKey_INTERFACE_DEFINED__
		
		TYPE Afx_ISpDataKey_ EXTENDS Afx_IUnknown
			DECLARE ABSTRACT FUNCTION SetData (BYVAL pszValueName AS WSTRING PTR, BYVAL cbData AS ULONG, BYVAL pData AS UBYTE PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetData (BYVAL pszValueName AS WSTRING PTR, BYVAL pcbData AS ULONG PTR, BYVAL pData AS UBYTE PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetStringValue (BYVAL pszValueName AS WSTRING PTR, BYVAL pszValue AS WSTRING PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetStringValue (BYVAL pszValueName AS WSTRING PTR, BYVAL ppszValue AS WSTRING PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetDWORD (BYVAL pszValueName AS WSTRING PTR, BYVAL dwValue AS ULONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetDWORD (BYVAL pszValueName AS WSTRING PTR, BYVAL pdwValue AS ULONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION OpenKey (BYVAL pszSubKeyName AS WSTRING PTR, BYVAL ppSubKey AS Afx_ISpDataKey PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION CreateKey (BYVAL pszSubKey AS WSTRING PTR, BYVAL ppSubKey AS Afx_ISpDataKey PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION DeleteKey (BYVAL pszSubKey AS WSTRING PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION DeleteValue (BYVAL pszValueName AS WSTRING PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION EnumKeys (BYVAL Index AS ULONG, BYVAL ppszSubKeyName AS WSTRING PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION EnumValues (BYVAL Index AS ULONG, BYVAL ppszValueName AS WSTRING PTR PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpEventSink
	' IID: {BE7A9CC9-5F9E-11D2-960F-00C04F8EE628}
	' Documentation string: Afx_ISpEventSink Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __Afx_ISpEventSink_INTERFACE_DEFINED__
		#define __Afx_ISpEventSink_INTERFACE_DEFINED__
		
		TYPE Afx_ISpEventSink_ EXTENDS Afx_IUnknown
			DECLARE ABSTRACT FUNCTION AddEvents (BYVAL pEventArray AS SPEVENT PTR, BYVAL ulCount AS ULONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetEventInterest (BYVAL pullEventInterest AS ULONGINT PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	
	' ########################################################################################
	' Interface name: Afx_ISpNotifySource
	' IID: {5EFF4AEF-8487-11D2-961C-00C04F8EE628}
	' Documentation string: Afx_ISpNotifySource Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 7
	' ########################################################################################
	
	#ifndef __Afx_ISpNotifySource_INTERFACE_DEFINED__
		#define __Afx_ISpNotifySource_INTERFACE_DEFINED__
		
		TYPE Afx_ISpNotifySource_ EXTENDS Afx_IUnknown
			DECLARE ABSTRACT FUNCTION SetNotifySink (BYVAL pNotifySink AS Afx_ISpNotifySink PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetNotifyWindowMessage (BYVAL hWnd AS HWND, BYVAL Msg AS UINT, BYVAL wParam AS UINT_PTR, BYVAL lParam AS LONG_PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetNotifyCallbackFunction (BYVAL pfnCallback AS ANY PTR PTR, BYVAL wParam AS UINT_PTR, BYVAL lParam AS LONG_PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetNotifyCallbackInterface (BYVAL pSpCallback AS ANY PTR PTR, BYVAL wParam AS UINT_PTR, BYVAL lParam AS LONG_PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetNotifyWin32Event () AS HRESULT
			DECLARE ABSTRACT FUNCTION WaitForNotifyEvent (BYVAL dwMilliseconds AS ULONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetNotifyEventHandle () AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpEventSource
	' IID: {BE7A9CCE-5F9E-11D2-960F-00C04F8EE628}
	' Documentation string: Afx_ISpEventSource Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = Afx_ISpNotifySource
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __Afx_ISpEventSource_INTERFACE_DEFINED__
		#define __Afx_ISpEventSource_INTERFACE_DEFINED__
		
		TYPE Afx_ISpEventSource_ EXTENDS Afx_ISpNotifySource
			DECLARE ABSTRACT FUNCTION SetInterest (BYVAL ullEventInterest AS ULONGINT, BYVAL ullQueuedInterest AS ULONGINT) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetEvents (BYVAL ulCount AS ULONG, BYVAL pEventArray AS SPEVENT PTR, BYVAL pulFetched AS ULONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetInfo (BYVAL pInfo AS SPEVENTSOURCEINFO PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpGrammarBuilder
	' IID: {8137828F-591A-4A42-BE58-49EA7EBAAC68}
	' Documentation string: Afx_ISpGrammarBuilder Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 8
	' ########################################################################################
	
	#ifndef __Afx_ISpGrammarBuilder_INTERFACE_DEFINED__
		#define __Afx_ISpGrammarBuilder_INTERFACE_DEFINED__
		
		TYPE Afx_ISpGrammarBuilder_ EXTENDS Afx_IUnknown
			DECLARE ABSTRACT FUNCTION ResetGrammar (BYVAL NewLanguage AS USHORT) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetRule (BYVAL pszRuleName AS WSTRING PTR, BYVAL dwRuleId AS ULONG, BYVAL dwAttributes AS ULONG, BYVAL fCreateIfNotExist AS LONG, BYVAL phInitialState AS ANY PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION ClearRule (BYVAL hState AS ANY PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION CreateNewState (BYVAL hState AS ANY PTR, BYVAL phState AS ANY PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION AddWordTransition (BYVAL hFromState AS ANY PTR, BYVAL hToState AS ANY PTR, BYVAL psz AS WSTRING PTR, BYVAL pszSeparators AS WSTRING PTR, BYVAL eWordType AS SPGRAMMARWORDTYPE, BYVAL Weight AS SINGLE, BYVAL pPropInfo AS SPPROPERTYINFO PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION AddRuleTransition (BYVAL hFromState AS ANY PTR, BYVAL hToState AS ANY PTR, BYVAL hRule AS ANY PTR, BYVAL Weight AS SINGLE, BYVAL pPropInfo AS SPPROPERTYINFO PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION AddResource (BYVAL hRuleState AS ANY PTR, BYVAL pszResourceName AS WSTRING PTR, BYVAL pszResourceValue AS WSTRING PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Commit (BYVAL dwReserved AS ULONG) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpLexicon
	' IID: {DA41A7C2-5383-4DB2-916B-6C1719E3DB58}
	' Documentation string: Afx_ISpLexicon Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 6
	' ########################################################################################
	
	#ifndef __Afx_ISpLexicon_INTERFACE_DEFINED__
		#define __Afx_ISpLexicon_INTERFACE_DEFINED__
		
		TYPE Afx_ISpLexicon_ EXTENDS Afx_IUnknown
			DECLARE ABSTRACT FUNCTION GetPronunciations (BYVAL pszWord AS WSTRING PTR, BYVAL LangId AS USHORT, BYVAL dwFlags AS ULONG, BYVAL pWordPronunciationList AS SPWORDPRONUNCIATIONLIST PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION AddPronunciation (BYVAL pszWord AS WSTRING PTR, BYVAL LangId AS USHORT, BYVAL ePartOfSpeech AS SPPARTOFSPEECH, BYVAL pszPronunciation AS WSTRING PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION RemovePronunciation (BYVAL pszWord AS WSTRING PTR, BYVAL LangId AS USHORT, BYVAL ePartOfSpeech AS SPPARTOFSPEECH, BYVAL pszPronunciation AS WSTRING PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetGeneration (BYVAL pdwGeneration AS ULONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetGenerationChange (BYVAL dwFlags AS ULONG, BYVAL pdwGeneration AS ULONG PTR, BYVAL pWordList AS SPWORDLIST PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetWords (BYVAL dwFlags AS ULONG, BYVAL pdwGeneration AS ULONG PTR, BYVAL pdwCookie AS ULONG PTR, BYVAL pWordList AS SPWORDLIST PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpMMSysAudio
	' IID: {15806F6E-1D70-4B48-98E6-3B1A007509AB}
	' Documentation string: Afx_ISpMMSysAudio Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = Afx_ISpAudio
	' Number of methods = 5
	' ########################################################################################
	
	#ifndef __Afx_ISpMMSysAudio_INTERFACE_DEFINED__
		#define __Afx_ISpMMSysAudio_INTERFACE_DEFINED__
		
		Type Afx_ISpMMSysAudio_ Extends Afx_ISpAudio
			Declare Abstract Function GetDeviceId (ByVal puDeviceId As UINT Ptr) As HRESULT
			Declare Abstract Function SetDeviceId (ByVal uDeviceId As UINT) As HRESULT
			Declare Abstract Function GetMMHandle (ByVal pHandle As Any Ptr Ptr) As HRESULT
			Declare Abstract Function GetLineId (ByVal puLineId As UINT Ptr) As HRESULT
			Declare Abstract Function SetLineId (ByVal uLineId As UINT) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpNotifySink
	' IID: {259684DC-37C3-11D2-9603-00C04F8EE628}
	' Documentation string: Afx_ISpNotifySink Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 1
	' ########################################################################################
	
	#ifndef __Afx_ISpNotifySink_INTERFACE_DEFINED__
		#define __Afx_ISpNotifySink_INTERFACE_DEFINED__
		
		Type Afx_ISpNotifySink_ Extends Afx_IUnknown
			Declare Abstract Function Notify () As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpNotifyTranslator
	' IID: {ACA16614-5D3D-11D2-960E-00C04F8EE628}
	' Documentation string: Afx_ISpNotifyTranslator Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = Afx_ISpNotifySink
	' Number of methods = 6
	' ########################################################################################
	
	#ifndef __Afx_ISpNotifyTranslator_INTERFACE_DEFINED__
		#define __Afx_ISpNotifyTranslator_INTERFACE_DEFINED__
		
		TYPE Afx_ISpNotifyTranslator_ EXTENDS Afx_ISpNotifySink
			DECLARE ABSTRACT FUNCTION InitWindowMessage (BYVAL hWnd AS HWND, BYVAL Msg AS UINT, BYVAL wParam AS UINT_PTR, BYVAL lParam AS LONG_PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION InitCallback (BYVAL pfnCallback AS ANY PTR PTR, BYVAL wParam AS UINT_PTR, BYVAL lParam AS LONG_PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION InitSpNotifyCallback (BYVAL pSpCallback AS ANY PTR PTR, BYVAL wParam AS UINT_PTR, BYVAL lParam AS LONG_PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION InitWin32Event (BYVAL hEvent AS ANY PTR, BYVAL fCloseHandleOnRelease AS LONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION Wait (BYVAL dwMilliseconds AS ULONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetEventHandle () AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpObjectToken
	' IID: {14056589-E16C-11D2-BB90-00C04F8EE6C0}
	' Documentation string: Afx_ISpObjectToken Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = Afx_ISpDataKey
	' Number of methods = 10
	' ########################################################################################
	
	#ifndef __Afx_ISpObjectToken_INTERFACE_DEFINED__
		#define __Afx_ISpObjectToken_INTERFACE_DEFINED__
		
		TYPE Afx_ISpObjectToken_ EXTENDS Afx_ISpDataKey
			DECLARE ABSTRACT FUNCTION SetId (BYVAL pszCategoryId AS WSTRING PTR, BYVAL pszTokenId AS WSTRING PTR, BYVAL fCreateIfNotExist AS LONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetId (BYVAL ppszCoMemTokenId AS WSTRING PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetCategory (BYVAL ppTokenCategory AS Afx_ISpObjectTokenCategory PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION CreateInstance (BYVAL pUnkOuter AS Afx_IUnknown PTR, BYVAL dwClsContext AS ULONG, BYVAL riid AS GUID PTR, BYVAL ppvObject AS ANY PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetStorageFileName (BYVAL clsidCaller AS GUID PTR, BYVAL pszValueName AS WSTRING PTR, BYVAL pszFileNameSpecifier AS WSTRING PTR, BYVAL nFolder AS ULONG, BYVAL ppszFilePath AS WSTRING PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION RemoveStorageFileName (BYVAL clsidCaller AS GUID PTR, BYVAL pszKeyName AS WSTRING PTR, BYVAL fDeleteFile AS LONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION Remove (BYVAL pclsidCaller AS GUID PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION IsUISupported (BYVAL pszTypeOfUI AS WSTRING PTR, BYVAL pvExtraData AS ANY PTR, BYVAL cbExtraData AS ULONG, BYVAL punkObject AS Afx_IUnknown PTR, BYVAL pfSupported AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION DisplayUI (BYVAL hWndParent AS HWND, BYVAL pszTitle AS WSTRING PTR, BYVAL pszTypeOfUI AS WSTRING PTR, BYVAL pvExtraData AS ANY PTR, BYVAL cbExtraData AS ULONG, BYVAL punkObject AS Afx_IUnknown PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION MatchesAttributes (BYVAL pszAttributes AS WSTRING PTR, BYVAL pfMatches AS LONG PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpObjectTokenCategory
	' IID: {2D3D3845-39AF-4850-BBF9-40B49780011D}
	' Documentation string: Afx_ISpObjectTokenCategory
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = Afx_ISpDataKey
	' Number of methods = 6
	' ########################################################################################
	
	#ifndef __Afx_ISpObjectTokenCategory_INTERFACE_DEFINED__
		#define __Afx_ISpObjectTokenCategory_INTERFACE_DEFINED__
		
		TYPE Afx_ISpObjectTokenCategory_ EXTENDS Afx_ISpDataKey
			DECLARE ABSTRACT FUNCTION SetId (BYVAL pszCategoryId AS WSTRING PTR, BYVAL fCreateIfNotExist AS LONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetId (BYVAL ppszCoMemCategoryId AS WSTRING PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetDataKey (BYVAL spdkl AS SPDATAKEYLOCATION, BYVAL ppDataKey AS Afx_ISpDataKey PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION EnumTokens (BYVAL pzsReqAttribs AS WSTRING PTR, BYVAL pszOptAttribs AS WSTRING PTR, BYVAL ppEnum AS Afx_IEnumSpObjectTokens PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetDefaultTokenId (BYVAL pszTokenId AS WSTRING PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetDefaultTokenId (BYVAL ppszCoMemTokenId AS WSTRING PTR PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpObjectWithToken
	' IID: {5B559F40-E952-11D2-BB91-00C04F8EE6C0}
	' Documentation string: Afx_ISpObjectWithToken Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __Afx_ISpObjectWithToken_INTERFACE_DEFINED__
		#define __Afx_ISpObjectWithToken_INTERFACE_DEFINED__
		
		TYPE Afx_ISpObjectWithToken_ EXTENDS Afx_IUnknown
			DECLARE ABSTRACT FUNCTION SetObjectToken (BYVAL pToken AS Afx_ISpObjectToken PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetObjectToken (BYVAL ppToken AS Afx_ISpObjectToken PTR PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpPhoneConverter
	' IID: {8445C581-0CAC-4A38-ABFE-9B2CE2826455}
	' Documentation string: Afx_ISpPhoneConverter Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = Afx_ISpObjectWithToken
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __Afx_ISpPhoneConverter_INTERFACE_DEFINED__
		#define __Afx_ISpPhoneConverter_INTERFACE_DEFINED__
		
		TYPE Afx_ISpPhoneConverter_ EXTENDS Afx_ISpObjectWithToken
			DECLARE ABSTRACT FUNCTION PhoneToId (BYVAL pszPhone AS WSTRING PTR, BYVAL pId AS USHORT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION IdToPhone (BYVAL pId AS WSTRING PTR, BYVAL pszPhone AS USHORT PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpPhoneticAlphabetConverter
	' IID: {133ADCD4-19B4-4020-9FDC-842E78253B17}
	' Documentation string: Afx_ISpPhoneticAlphabetConverter Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 5
	' ########################################################################################
	
	#ifndef __Afx_ISpPhoneticAlphabetConverter_INTERFACE_DEFINED__
		#define __Afx_ISpPhoneticAlphabetConverter_INTERFACE_DEFINED__
		
		TYPE Afx_ISpPhoneticAlphabetConverter_ EXTENDS Afx_IUnknown
			DECLARE ABSTRACT FUNCTION GetLangId (BYVAL pLangID AS USHORT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetLangId (BYVAL LangId AS USHORT) AS HRESULT
			DECLARE ABSTRACT FUNCTION SAPI2UPS (BYVAL pszSAPIId AS USHORT PTR, BYVAL pszUPSId AS USHORT PTR, BYVAL cMaxLength AS ULONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION UPS2SAPI (BYVAL pszUPSId AS USHORT PTR, BYVAL pszSAPIId AS USHORT PTR, BYVAL cMaxLength AS ULONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetMaxConvertLength (BYVAL cSrcLength AS ULONG, BYVAL bSAPI2UPS AS LONG, BYVAL pcMaxDestLength AS ULONG PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpPhoneticAlphabetSelection
	' IID: {B2745EFD-42CE-48CA-81F1-A96E02538A90}
	' Documentation string: Afx_ISpPhoneticAlphabetSelection Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __Afx_ISpPhoneticAlphabetSelection_INTERFACE_DEFINED__
		#define __Afx_ISpPhoneticAlphabetSelection_INTERFACE_DEFINED__
		
		TYPE Afx_ISpPhoneticAlphabetSelection_ EXTENDS Afx_IUnknown
			DECLARE ABSTRACT FUNCTION IsAlphabetUPS (BYVAL pfIsUPS AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetAlphabetToUPS (BYVAL fForceUPS AS LONG) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpPhrase
	' IID: {1A5C0354-B621-4B5A-8791-D306ED379E53}
	' Documentation string: Afx_ISpPhrase Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 4
	' ########################################################################################
	
	#ifndef __Afx_ISpPhrase_INTERFACE_DEFINED__
		#define __Afx_ISpPhrase_INTERFACE_DEFINED__
		
		TYPE Afx_ISpPhrase_ EXTENDS Afx_IUnknown
			DECLARE ABSTRACT FUNCTION GetPhrase (BYVAL ppCoMemPhrase AS SPPHRASE PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetSerializedPhrase (BYVAL ppCoMemPhrase AS SPSERIALIZEDPHRASE PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetText (BYVAL ulStart AS ULONG, BYVAL ulCount AS ULONG, BYVAL fUseTextReplacements AS LONG, BYVAL ppszCoMemText AS WSTRING PTR PTR, BYVAL pbDisplayAttributes AS UBYTE PTR = NULL) AS HRESULT
			DECLARE ABSTRACT FUNCTION Discard (BYVAL dwValueTypes AS ULONG) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpPhraseAlt
	' IID: {8FCEBC98-4E49-4067-9C6C-D86A0E092E3D}
	' Documentation string: Afx_ISpPhraseAlt Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = Afx_ISpPhrase
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __Afx_ISpPhraseAlt_INTERFACE_DEFINED__
		#define __Afx_ISpPhraseAlt_INTERFACE_DEFINED__
		
		TYPE Afx_ISpPhraseAlt_ EXTENDS Afx_ISpPhrase
			DECLARE ABSTRACT FUNCTION GetAltInfo (BYVAL ppParent AS Afx_ISpPhrase PTR PTR, BYVAL pulStartElementInParent AS ULONG PTR, BYVAL pcElementsInParent AS ULONG PTR, BYVAL pcElementsInAlt AS ULONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Commit () AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpProperties
	' IID: {5B4FB971-B115-4DE1-AD97-E482E3BF6EE4}
	' Documentation string: Afx_ISpProperties Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 4
	' ########################################################################################
	
	#ifndef __Afx_ISpProperties_INTERFACE_DEFINED__
		#define __Afx_ISpProperties_INTERFACE_DEFINED__
		
		TYPE Afx_ISpProperties_ EXTENDS Afx_IUnknown
			DECLARE ABSTRACT FUNCTION SetPropertyNum (BYVAL pName AS WSTRING PTR, BYVAL lValue AS LONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetPropertyNum (BYVAL pName AS WSTRING PTR, BYVAL plValue AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetPropertyString (BYVAL pName AS WSTRING PTR, BYVAL pValue AS WSTRING PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetPropertyString (BYVAL pName AS WSTRING PTR, BYVAL ppCoMemValue AS WSTRING PTR PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpRecoCategory
	' IID: {DA0CD0F9-14A2-4F09-8C2A-85CC48979345}
	' Documentation string: Afx_ISpRecoCategory Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 1
	' ########################################################################################
	
	#ifndef __Afx_ISpRecoCategory_INTERFACE_DEFINED__
		#define __Afx_ISpRecoCategory_INTERFACE_DEFINED__
		
		TYPE Afx_ISpRecoCategory_ EXTENDS Afx_IUnknown
			DECLARE ABSTRACT FUNCTION GetType (BYVAL peCategoryType AS SPCATEGORYTYPE PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpRecoContext
	' IID: {F740A62F-7C15-489E-8234-940A33D9272D}
	' Documentation string: Afx_ISpRecoContext Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = Afx_ISpEventSource
	' Number of methods = 18
	' ########################################################################################
	
	#ifndef __Afx_ISpRecoContext_INTERFACE_DEFINED__
		#define __Afx_ISpRecoContext_INTERFACE_DEFINED__
		
		TYPE Afx_ISpRecoContext_ EXTENDS Afx_ISpEventSource
			DECLARE ABSTRACT FUNCTION GetRecognizer (BYVAL ppRecognizer AS Afx_ISpRecognizer PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION CreateGrammar (BYVAL ullGrammarID AS ULONGINT, BYVAL ppGrammar AS Afx_ISpRecoGrammar PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetStatus (BYVAL pStatus AS SPRECOCONTEXTSTATUS PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetMaxAlternates (BYVAL pcAlternates AS ULONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetMaxAlternates (BYVAL cAlternates AS ULONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetAudioOptions (BYVAL Options AS SPAUDIOOPTIONS, BYVAL pAudioFormatId AS GUID PTR, BYVAL pWaveFormatEx AS WaveFormatEx PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetAudioOptions (BYVAL pOptions AS SPAUDIOOPTIONS PTR, BYVAL pAudioFormatId AS GUID PTR, BYVAL ppCoMemWFEX AS WaveFormatEx PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION DeserializeResult (BYVAL pSerializedResult AS SPSERIALIZEDRESULT PTR, BYVAL ppResult AS Afx_ISpRecoResult PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Bookmark (BYVAL Options AS SPBOOKMARKOPTIONS, BYVAL ullStreamPosition AS ULONGINT, BYVAL lparamEvent AS LONG_PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetAdaptationData (BYVAL pAdaptationData AS WSTRING PTR, BYVAL cch AS ULONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION Pause (BYVAL dwReserved AS ULONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION Resume (BYVAL dwReserved AS ULONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetVoice (BYVAL pVoice AS Afx_ISpVoice PTR, BYVAL fAllowFormatChanges AS LONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetVoice (BYVAL ppVoice AS Afx_ISpVoice PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetVoicePurgeEvent (BYVAL ullEventInterest AS ULONGINT) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetVoicePurgeEvent (BYVAL pullEventInterest AS ULONGINT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetContextState (BYVAL eContextState AS SPCONTEXTSTATE) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetContextState (BYVAL peContextState AS SPCONTEXTSTATE PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpRecoContext2
	' IID: {BEAD311C-52FF-437F-9464-6B21054CA73D}
	' Documentation string: Afx_ISpRecoContext2 Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __Afx_ISpRecoContext2_INTERFACE_DEFINED__
		#define __Afx_ISpRecoContext2_INTERFACE_DEFINED__
		
		TYPE Afx_ISpRecoContext2_ EXTENDS Afx_IUnknown
			DECLARE ABSTRACT FUNCTION SetGrammarOptions (BYVAL eGrammarOptions AS ULONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetGrammarOptions (BYVAL peGrammarOptions AS ULONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetAdaptationData2 (BYVAL pAdaptationData AS WSTRING PTR, BYVAL cch AS ULONG, BYVAL pTopicName AS WSTRING PTR, BYVAL eAdaptationSettings AS ULONG, BYVAL eRelevance AS SPADAPTATIONRELEVANCE) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpRecognizer
	' IID: {C2B5F241-DAA0-4507-9E16-5A1EAA2B7A5C}
	' Documentation string: Afx_ISpRecognizer Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = Afx_ISpProperties
	' Number of methods = 16
	' ########################################################################################
	
	#ifndef __Afx_ISpRecognizer_INTERFACE_DEFINED__
		#define __Afx_ISpRecognizer_INTERFACE_DEFINED__
		
		TYPE Afx_ISpRecognizer_ EXTENDS Afx_ISpProperties
			DECLARE ABSTRACT FUNCTION SetRecognizer (BYVAL pRecognizer AS Afx_ISpObjectToken PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetRecognizer (BYVAL ppRecognizer AS Afx_ISpObjectToken PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetInput (BYVAL pUnkInput AS Afx_IUnknown PTR, BYVAL fAllowFormatChanges AS LONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetInputObjectToken (BYVAL ppToken AS Afx_ISpObjectToken PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetInputStream (BYVAL ppStream AS Afx_ISpStreamFormat PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION CreateRecoContext (BYVAL ppNewCtxt AS Afx_ISpRecoContext PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetRecoProfile (BYVAL ppToken AS Afx_ISpObjectToken PTR PTR) AS HRESULT
			Declare Abstract Function SetRecoProfile (ByVal pToken As Afx_ISpObjectToken Ptr) As HRESULT
			Declare Abstract Function IsSharedInstance () As HRESULT
			Declare Abstract Function GetRecoState (ByVal pState As SPRECOSTATE Ptr) As HRESULT
			Declare Abstract Function SetRecoState (ByVal NewState As SPRECOSTATE) As HRESULT
			Declare Abstract Function GetStatus (ByVal pStatus As SPRECOGNIZERSTATUS Ptr) As HRESULT
			Declare Abstract Function GetFormat (ByVal WaveFormatType As SPSTREAMFORMATTYPE, ByVal pFormatId As GUID Ptr, ByVal ppCoMemWFEX As WaveFormatEx Ptr Ptr) As HRESULT
			Declare Abstract Function IsUISupported (ByVal pszTypeOfUI As WString Ptr, ByVal pvExtraData As Any Ptr, ByVal cbExtraData As ULong, ByVal pfSupported As Long Ptr) As HRESULT
			Declare Abstract Function DisplayUI (ByVal hWndParent As HWND, ByVal pszTitle As WString Ptr, ByVal pszTypeOfUI As WString Ptr, ByVal pvExtraData As Any Ptr, ByVal cbExtraData As ULong) As HRESULT
			Declare Abstract Function EmulateRecognition (ByVal pPhrase As Afx_ISpPhrase Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpRecognizer2
	' IID: {8FC6D974-C81E-4098-93C5-0147F61ED4D3}
	' Documentation string: Afx_ISpRecognizer2 Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __Afx_ISpRecognizer2_INTERFACE_DEFINED__
		#define __Afx_ISpRecognizer2_INTERFACE_DEFINED__
		
		Type Afx_ISpRecognizer2_ Extends Afx_IUnknown
			Declare Abstract Function EmulateRecognitionEx (ByVal pPhrase As Afx_ISpPhrase Ptr, ByVal dwCompareFlags As ULong) As HRESULT
			Declare Abstract Function SetTrainingState (ByVal fDoingTraining As Long, ByVal fAdaptFromTrainingData As Long) As HRESULT
			Declare Abstract Function ResetAcousticModelAdaptation () As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpRecognizer3
	' IID: {DF1B943C-5838-4AA2-8706-D7CD5B333499}
	' Documentation string: Afx_ISpRecognizer3 Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __Afx_ISpRecognizer3_INTERFACE_DEFINED__
		#define __Afx_ISpRecognizer3_INTERFACE_DEFINED__
		
		TYPE Afx_ISpRecognizer3_ EXTENDS Afx_IUnknown
			DECLARE ABSTRACT FUNCTION GetCategory (BYVAL categoryType AS SPCATEGORYTYPE, BYVAL ppCategory AS Afx_ISpRecoCategory PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetActiveCategory (BYVAL pCategory AS Afx_ISpRecoCategory PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetActiveCategory (BYVAL ppCategory AS Afx_ISpRecoCategory PTR PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpRecoGrammar
	' IID: {2177DB29-7F45-47D0-8554-067E91C80502}
	' Documentation string: Afx_ISpRecoGrammar Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = Afx_ISpGrammarBuilder
	' Number of methods = 18
	' ########################################################################################
	
	#ifndef __Afx_ISpRecoGrammar_INTERFACE_DEFINED__
		#define __Afx_ISpRecoGrammar_INTERFACE_DEFINED__
		
		TYPE Afx_ISpRecoGrammar_ EXTENDS Afx_ISpGrammarBuilder
			DECLARE ABSTRACT FUNCTION GetGrammarId (BYVAL pullGrammarId AS ULONGINT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetRecoContext (BYVAL ppRecoCtxt AS Afx_ISpRecoContext PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION LoadCmdFromFile (BYVAL pszFileName AS WSTRING PTR, BYVAL Options AS SPLOADOPTIONS) AS HRESULT
			DECLARE ABSTRACT FUNCTION LoadCmdFromObject (BYVAL rcid AS GUID PTR, BYVAL pszGrammarName AS WSTRING PTR, BYVAL Options AS SPLOADOPTIONS) AS HRESULT
			DECLARE ABSTRACT FUNCTION LoadCmdFromResource (BYVAL hModule AS ANY PTR, BYVAL pszResourceName AS WSTRING PTR, BYVAL pszResourceType AS WSTRING PTR, BYVAL wLanguage AS USHORT, BYVAL Options AS SPLOADOPTIONS) AS HRESULT
			DECLARE ABSTRACT FUNCTION LoadCmdFromMemory (BYVAL pGrammar AS SPBINARYGRAMMAR PTR, BYVAL Options AS SPLOADOPTIONS) AS HRESULT
			DECLARE ABSTRACT FUNCTION LoadCmdFromProprietaryGrammar (BYVAL rguidParam AS GUID PTR, BYVAL pszStringParam AS WSTRING PTR, BYVAL pvDataPrarm AS ANY PTR, BYVAL cbDataSize AS ULONG, BYVAL Options AS SPLOADOPTIONS) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetRuleState (BYVAL pszName AS WSTRING PTR, BYVAL pReserved AS ANY PTR, BYVAL NewState AS SPRULESTATE) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetRuleIdState (BYVAL ulRuleId AS ULONG, BYVAL NewState AS SPRULESTATE) AS HRESULT
			DECLARE ABSTRACT FUNCTION LoadDictation (BYVAL pszTopicName AS WSTRING PTR, BYVAL Options AS SPLOADOPTIONS) AS HRESULT
			DECLARE ABSTRACT FUNCTION UnloadDictation () AS HRESULT
			DECLARE ABSTRACT FUNCTION SetDictationState (BYVAL NewState AS SPRULESTATE) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetWordSequenceData (BYVAL pText AS USHORT PTR, BYVAL cchText AS ULONG, BYVAL pInfo AS SPTEXTSELECTIONINFO PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetTextSelection (BYVAL pInfo AS SPTEXTSELECTIONINFO PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION IsPronounceable (BYVAL pszWord AS WSTRING PTR, BYVAL pWordPronounceable AS SPWORDPRONOUNCEABLE PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetGrammarState (BYVAL eGrammarState AS SPGRAMMARSTATE) AS HRESULT
			DECLARE ABSTRACT FUNCTION SaveCmd (BYVAL pStream AS IStream PTR, BYVAL ppszCoMemErrorText AS WSTRING PTR PTR = NULL) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetGrammarState (BYVAL peGrammarState AS SPGRAMMARSTATE PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpRecoGrammar2
	' IID: {4B37BC9E-9ED6-44A3-93D3-18F022B79EC3}
	' Documentation string: Afx_ISpRecoGrammar2 Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 8
	' ########################################################################################
	
	#ifndef __Afx_ISpRecoGrammar2_INTERFACE_DEFINED__
		#define __Afx_ISpRecoGrammar2_INTERFACE_DEFINED__
		
		TYPE Afx_ISpRecoGrammar2_ EXTENDS Afx_IUnknown
			DECLARE ABSTRACT FUNCTION GetRules (BYVAL ppCoMemRules AS SPRULE PTR PTR, BYVAL puNumRules AS UINT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION LoadCmdFromFile2 (BYVAL pszFileName AS WSTRING PTR, BYVAL Options AS SPLOADOPTIONS, BYVAL pszSharingUri AS WSTRING PTR, BYVAL pszBaseUri AS WSTRING PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION LoadCmdFromMemory2 (BYVAL pGrammar AS SPBINARYGRAMMAR PTR, BYVAL Options AS SPLOADOPTIONS, BYVAL pszSharingUri AS WSTRING PTR, BYVAL pszBaseUri AS WSTRING PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetRulePriority (BYVAL pszRuleName AS WSTRING PTR, BYVAL ulRuleId AS ULONG, BYVAL nRulePriority AS INT_) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetRuleWeight (BYVAL pszRuleName AS WSTRING PTR, BYVAL ulRuleId AS ULONG, BYVAL flWeight AS SINGLE) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetDictationWeight (BYVAL flWeight AS SINGLE) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetGrammarLoader (BYVAL pLoader AS Afx_ISpeechResourceLoader PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetSMLSecurityManager (BYVAL pSMLSecurityManager AS IInternetSecurityManager PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpRecoResult
	' IID: {20B053BE-E235-43CD-9A2A-8D17A48B7842}
	' Documentation string: Afx_ISpRecoResult Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = Afx_ISpPhrase
	' Number of methods = 7
	' ########################################################################################
	
	#ifndef __Afx_ISpRecoResult_INTERFACE_DEFINED__
		#define __Afx_ISpRecoResult_INTERFACE_DEFINED__
		
		TYPE Afx_ISpRecoResult_ EXTENDS Afx_ISpPhrase
			DECLARE ABSTRACT FUNCTION GetResultTimes (BYVAL pTimes AS SPRECORESULTTIMES PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetAlternates (BYVAL ulStartElement AS ULONG, BYVAL cElements AS ULONG, BYVAL ulRequestCount AS ULONG, BYVAL ppPhrases AS Afx_ISpPhraseAlt PTR PTR, BYVAL pcPhrasesReturned AS ULONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetAudio (BYVAL ulStartElement AS ULONG, BYVAL cElements AS ULONG, BYVAL ppStream AS Afx_ISpStreamFormat PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SpeakAudio (BYVAL ulStartElement AS ULONG, BYVAL cElements AS ULONG, BYVAL dwFlags AS ULONG, BYVAL pulStreamNumber AS ULONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Serialize (BYVAL ppCoMemSerializedResult AS SPSERIALIZEDRESULT PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION ScaleAudio (BYVAL pAudioFormatId AS GUID PTR, BYVAL pWaveFormatEx AS WaveFormatEx PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetRecoContext (BYVAL ppRecoContext AS Afx_ISpRecoContext PTR PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpResourceManager
	' IID: {93384E18-5014-43D5-ADBB-A78E055926BD}
	' Documentation string: Afx_ISpResourceManager Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IServiceProvider
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __Afx_ISpResourceManager_INTERFACE_DEFINED__
		#define __Afx_ISpResourceManager_INTERFACE_DEFINED__
		
		TYPE Afx_ISpResourceManager_ EXTENDS Afx_IUnknown
			' // IServiceProvider interface
			DECLARE ABSTRACT FUNCTION QueryService (BYVAL guidService AS GUID PTR, BYVAL riid AS GUID PTR, BYVAL ppvObject AS IUnknown PTR PTR) AS HRESULT
			' // ISpResourceManager interface
			DECLARE ABSTRACT FUNCTION SetObject (BYVAL guidServiceId AS GUID PTR, BYVAL punkObject AS Afx_IUnknown PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetObject (BYVAL guidServiceId AS GUID PTR, BYVAL ObjectCLSID AS GUID PTR, BYVAL ObjectIID AS GUID PTR, BYVAL fReleaseWhenLastExternalRefReleased AS LONG, BYVAL ppObject AS ANY PTR PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpSerializeState
	' IID: {21B501A0-0EC7-46C9-92C3-A2BC784C54B9}
	' Documentation string: Afx_ISpSerializeState Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __Afx_ISpSerializeState_INTERFACE_DEFINED__
		#define __Afx_ISpSerializeState_INTERFACE_DEFINED__
		
		TYPE Afx_ISpSerializeState_ EXTENDS Afx_IUnknown
			DECLARE ABSTRACT FUNCTION GetSerializedState (BYVAL ppbData AS UBYTE PTR PTR, BYVAL pulSize AS ULONG PTR, BYVAL dwReserved AS ULONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetSerializedState (BYVAL pbData AS UBYTE PTR, BYVAL ulSize AS ULONG, BYVAL dwReserved AS ULONG) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpShortcut
	' IID: {3DF681E2-EA56-11D9-8BDE-F66BAD1E3F3A}
	' Documentation string: Afx_ISpShortcut Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 8
	' ########################################################################################
	
	#ifndef __Afx_ISpShortcut_INTERFACE_DEFINED__
		#define __Afx_ISpShortcut_INTERFACE_DEFINED__
		
		TYPE Afx_ISpShortcut_ EXTENDS Afx_IUnknown
			DECLARE ABSTRACT FUNCTION AddShortcut (BYVAL pszDisplay AS WSTRING PTR, BYVAL LangId AS USHORT, BYVAL pszSpoken AS WSTRING PTR, BYVAL shType AS SPSHORTCUTTYPE) AS HRESULT
			DECLARE ABSTRACT FUNCTION RemoveShortcut (BYVAL pszDisplay AS WSTRING PTR, BYVAL LangId AS USHORT, BYVAL pszSpoken AS WSTRING PTR, BYVAL shType AS SPSHORTCUTTYPE) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetShortcuts (BYVAL LangId AS USHORT, BYVAL pShortcutpairList AS SPSHORTCUTPAIRLIST PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetGeneration (BYVAL pdwGeneration AS ULONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetWordsFromGenerationChange (BYVAL pdwGeneration AS ULONG PTR, BYVAL pWordList AS SPWORDLIST PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetWords (BYVAL pdwGeneration AS ULONG PTR, BYVAL pdwCookie AS ULONG PTR, BYVAL pWordList AS SPWORDLIST PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetShortcutsForGeneration (BYVAL pdwGeneration AS ULONG PTR, BYVAL pdwCookie AS ULONG PTR, BYVAL pShortcutpairList AS SPSHORTCUTPAIRLIST PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetGenerationChange (BYVAL pdwGeneration AS ULONG PTR, BYVAL pShortcutpairList AS SPSHORTCUTPAIRLIST PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpStream
	' IID: {12E3CCA9-7518-44C5-A5E7-BA5A79CB929E}
	' Documentation string: Afx_ISpStream Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = Afx_ISpStreamFormat
	' Number of methods = 4
	' ########################################################################################
	
	#ifndef __Afx_ISpStream_INTERFACE_DEFINED__
		#define __Afx_ISpStream_INTERFACE_DEFINED__
		
		TYPE Afx_ISpStream_ EXTENDS Afx_ISpStreamFormat
			DECLARE ABSTRACT FUNCTION SetBaseStream (BYVAL pStream AS IStream PTR, BYVAL rguidFormat AS GUID PTR, BYVAL pWaveFormatEx AS WaveFormatEx PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetBaseStream (BYVAL ppStream AS IStream PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION BindToFile (BYVAL pszFileName AS WSTRING PTR, BYVAL eMode AS SPFILEMODE, BYVAL pFormatId AS GUID PTR, BYVAL pWaveFormatEx AS WaveFormatEx PTR, BYVAL ullEventInterest AS ULONGINT) AS HRESULT
			DECLARE ABSTRACT FUNCTION Close () AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpStreamFormatConverter
	' IID: {678A932C-EA71-4446-9B41-78FDA6280A29}
	' Documentation string: Afx_ISpStreamFormatConverter Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = Afx_ISpStreamFormat
	' Number of methods = 6
	' ########################################################################################
	
	#ifndef __Afx_ISpStreamFormatConverter_INTERFACE_DEFINED__
		#define __Afx_ISpStreamFormatConverter_INTERFACE_DEFINED__
		
		TYPE Afx_ISpStreamFormatConverter_ EXTENDS Afx_ISpStreamFormat
			DECLARE ABSTRACT FUNCTION SetBaseStream (BYVAL pStream AS Afx_ISpStreamFormat PTR, BYVAL fSetFormatToBaseStreamFormat AS LONG, BYVAL fWriteToBaseStream AS LONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetBaseStream (BYVAL ppStream AS Afx_ISpStreamFormat PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetFormat (BYVAL rguidFormatIdOfConvertedStream AS GUID PTR, BYVAL pWaveFormatExOfConvertedStream AS WaveFormatEx PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION ResetSeekPosition () AS HRESULT
			DECLARE ABSTRACT FUNCTION ScaleConvertedToBaseOffset (BYVAL ullOffsetConvertedStream AS ULONGINT, BYVAL pullOffsetBaseStream AS ULONGINT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION ScaleBaseToConvertedOffset (BYVAL ullOffsetBaseStream AS ULONGINT, BYVAL pullOffsetConvertedStream AS ULONGINT PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpVoice
	' IID: {6C44DF74-72B9-4992-A1EC-EF996E0422D4}
	' Documentation string: Afx_ISpVoice Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = Afx_ISpEventSource
	' Number of methods = 25
	' ########################################################################################
	
	#ifndef __Afx_ISpVoice_INTERFACE_DEFINED__
		#define __Afx_ISpVoice_INTERFACE_DEFINED__
		
		TYPE Afx_ISpVoice_ EXTENDS Afx_ISpEventSource
			DECLARE ABSTRACT FUNCTION SetOutput (BYVAL pUnkOutput AS Afx_IUnknown PTR, BYVAL fAllowFormatChanges AS LONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetOutputObjectToken (BYVAL ppObjectToken AS Afx_ISpObjectToken PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetOutputStream (BYVAL ppStream AS Afx_ISpStreamFormat PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Pause () AS HRESULT
			DECLARE ABSTRACT FUNCTION Resume () AS HRESULT
			DECLARE ABSTRACT FUNCTION SetVoice (BYVAL pToken AS Afx_ISpObjectToken PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetVoice (BYVAL ppToken AS Afx_ISpObjectToken PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Speak (BYVAL pwcs AS WSTRING PTR, BYVAL dwFlags AS ULONG, BYVAL pulStreamNumber AS ULONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SpeakStream (BYVAL pStream AS IStream PTR, BYVAL dwFlags AS ULONG, BYVAL pulStreamNumber AS ULONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetStatus (BYVAL pStatus AS SPVOICESTATUS PTR, BYVAL ppszLastBookmark AS WSTRING PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Skip (BYVAL pItemType AS WSTRING PTR, BYVAL lNumItems AS LONG, BYVAL pulNumSkipped AS ULONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetPriority (BYVAL ePriority AS SPVPRIORITY) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetPriority (BYVAL pePriority AS SPVPRIORITY PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetAlertBoundary (BYVAL eBoundary AS SPEVENTENUM) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetAlertBoundary (BYVAL peBoundary AS SPEVENTENUM PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetRate (BYVAL RateAdjust AS LONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetRate (BYVAL pRateAdjust AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetVolume (BYVAL usVolume AS USHORT) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetVolume (BYVAL pusVolume AS USHORT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION WaitUntilDone (BYVAL msTimeout AS ULONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetSyncSpeakTimeout (BYVAL msTimeout AS ULONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetSyncSpeakTimeout (BYVAL pmsTimeout AS ULONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SpeakCompleteEvent () AS HRESULT
			DECLARE ABSTRACT FUNCTION IsUISupported (BYVAL pszTypeOfUI AS WSTRING PTR, BYVAL pvExtraData AS ANY PTR, BYVAL cbExtraData AS ULONG, BYVAL pfSupported AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION DisplayUI (BYVAL hWndParent AS HWND, BYVAL pszTitle AS WSTRING PTR, BYVAL pszTypeOfUI AS WSTRING PTR, BYVAL pvExtraData AS ANY PTR, BYVAL cbExtraData AS ULONG) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: ISpXMLRecoResult
	' IID: {AE39362B-45A8-4074-9B9E-CCF49AA2D0B6}
	' Documentation string: ISpXMLRecoResult Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = Afx_ISpRecoResult
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __ISpXMLRecoResult_INTERFACE_DEFINED__
		#define __ISpXMLRecoResult_INTERFACE_DEFINED__
		
		TYPE ISpXMLRecoResult_ EXTENDS Afx_ISpRecoResult
			DECLARE ABSTRACT FUNCTION GetXMLResult (BYVAL ppszCoMemXMLResult AS WSTRING PTR PTR, BYVAL Options AS SPXMLRESULTOPTIONS) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetXMLErrorInfo (BYVAL pSemanticErrorInfo AS SPSEMANTICERRORINFO PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' // Dual interfaces
	
	
	' ########################################################################################
	' Interface name: Afx_ISpeechBaseStream
	' IID: {6450336F-7D49-4CED-8097-49D6DEE37294}
	' Documentation string: Afx_ISpeechBaseStream Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 5
	' ########################################################################################
	
	#ifndef __Afx_ISpeechBaseStream_INTERFACE_DEFINED__
		#define __Afx_ISpeechBaseStream_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechBaseStream_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_Format (BYVAL AudioFormat AS Afx_ISpeechAudioFormat PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION putref_Format (BYVAL AudioFormat AS Afx_ISpeechAudioFormat PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Read (BYVAL Buffer AS VARIANT PTR, BYVAL NumberOfBytes AS LONG, BYVAL BytesRead AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Write (BYVAL Buffer AS VARIANT, BYVAL BytesWritten AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Seek (BYVAL Position AS VARIANT, BYVAL Origin AS SpeechStreamSeekPositionType = 0, BYVAL NewPosition AS VARIANT PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	' Interface name: Afx_ISpeechAudio
	' IID: {CFF8E175-019E-11D3-A08E-00C04F8EF9B5}
	' Documentation string: Afx_ISpeechAudio Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = Afx_ISpeechBaseStream
	' Number of methods = 9
	' ########################################################################################
	
	#ifndef __Afx_ISpeechAudio_INTERFACE_DEFINED__
		#define __Afx_ISpeechAudio_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechAudio_ EXTENDS Afx_ISpeechBaseStream
			DECLARE ABSTRACT FUNCTION get_Status (BYVAL Status AS Afx_ISpeechAudioStatus PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_BufferInfo (BYVAL BufferInfo AS Afx_ISpeechAudioBufferInfo PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_DefaultFormat (BYVAL StreamFormat AS Afx_ISpeechAudioFormat PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Volume (BYVAL Volume AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_Volume (BYVAL Volume AS LONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_BufferNotifySize (BYVAL BufferNotifySize AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_BufferNotifySize (BYVAL BufferNotifySize AS LONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_EventHandle (BYVAL EventHandle AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetState (BYVAL State AS SpeechAudioState) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechAudioBufferInfo
	' IID: {11B103D8-1142-4EDF-A093-82FB3915F8CC}
	' Documentation string: Afx_ISpeechAudioBufferInfo Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 6
	' ########################################################################################
	
	#ifndef __Afx_ISpeechAudioBufferInfo_INTERFACE_DEFINED__
		#define __Afx_ISpeechAudioBufferInfo_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechAudioBufferInfo_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_MinNotification (BYVAL MinNotification AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_MinNotification (BYVAL MinNotification AS LONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_BufferSize (BYVAL BufferSize AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_BufferSize (BYVAL BufferSize AS LONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_EventBias (BYVAL EventBias AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_EventBias (BYVAL EventBias AS LONG) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechAudioFormat
	' IID: {E6E9C590-3E18-40E3-8299-061F98BDE7C7}
	' Documentation string: Afx_ISpeechAudioFormat Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 6
	' ########################################################################################
	
	#ifndef __Afx_ISpeechAudioFormat_INTERFACE_DEFINED__
		#define __Afx_ISpeechAudioFormat_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechAudioFormat_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_Type (BYVAL AudioFormat AS SpeechAudioFormatType PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_Type (BYVAL AudioFormat AS SpeechAudioFormatType) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Guid (BYVAL Guid AS AFX_BSTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_Guid (BYVAL Guid AS AFX_BSTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetWaveFormatEx (BYVAL WaveFormatEx AS Afx_ISpeechWaveFormatEx PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetWaveFormatEx (BYVAL WaveFormatEx AS Afx_ISpeechWaveFormatEx PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechAudioStatus
	' IID: {C62D9C91-7458-47F6-862D-1EF86FB0B278}
	' Documentation string: Afx_ISpeechAudioStatus Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 5
	' ########################################################################################
	
	#ifndef __Afx_ISpeechAudioStatus_INTERFACE_DEFINED__
		#define __Afx_ISpeechAudioStatus_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechAudioStatus_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_FreeBufferSpace (BYVAL FreeBufferSpace AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_NonBlockingIO (BYVAL NonBlockingIO AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_State (BYVAL State AS SpeechAudioState PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_CurrentSeekPosition (BYVAL CurrentSeekPosition AS VARIANT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_CurrentDevicePosition (BYVAL CurrentDevicePosition AS VARIANT PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechCustomStream
	' IID: {1A9E9F4F-104F-4DB8-A115-EFD7FD0C97AE}
	' Documentation string: Afx_ISpeechCustomStream Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = Afx_ISpeechBaseStream
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __Afx_ISpeechCustomStream_INTERFACE_DEFINED__
		#define __Afx_ISpeechCustomStream_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechCustomStream_ EXTENDS Afx_ISpeechBaseStream
			DECLARE ABSTRACT FUNCTION get_BaseStream (BYVAL ppUnkStream AS Afx_IUnknown PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION putref_BaseStream (BYVAL ppUnkStream AS Afx_IUnknown PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechDataKey
	' IID: {CE17C09B-4EFA-44D5-A4C9-59D9585AB0CD}
	' Documentation string: Afx_ISpeechDataKey Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 12
	' ########################################################################################
	
	#ifndef __Afx_ISpeechDataKey_INTERFACE_DEFINED__
		#define __Afx_ISpeechDataKey_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechDataKey_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION SetBinaryValue (BYVAL ValueName AS AFX_BSTR, BYVAL Value AS VARIANT) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetBinaryValue (BYVAL ValueName AS AFX_BSTR, BYVAL Value AS VARIANT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetStringValue (BYVAL ValueName AS AFX_BSTR, BYVAL Value AS AFX_BSTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetStringValue (BYVAL ValueName AS AFX_BSTR, BYVAL Value AS AFX_BSTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetLongValue (BYVAL ValueName AS AFX_BSTR, BYVAL Value AS LONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetLongValue (BYVAL ValueName AS AFX_BSTR, BYVAL Value AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION OpenKey (BYVAL SubKeyName AS AFX_BSTR, BYVAL SubKey AS Afx_ISpeechDataKey PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION CreateKey (BYVAL SubKeyName AS AFX_BSTR, BYVAL SubKey AS Afx_ISpeechDataKey PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION DeleteKey (BYVAL SubKeyName AS AFX_BSTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION DeleteValue (BYVAL ValueName AS AFX_BSTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION EnumKeys (BYVAL Index AS LONG, BYVAL SubKeyName AS AFX_BSTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION EnumValues (BYVAL Index AS LONG, BYVAL ValueName AS AFX_BSTR PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechFileStream
	' IID: {AF67F125-AB39-4E93-B4A2-CC2E66E182A7}
	' Documentation string: Afx_ISpeechFileStream Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = Afx_ISpeechBaseStream
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __Afx_ISpeechFileStream_INTERFACE_DEFINED__
		#define __Afx_ISpeechFileStream_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechFileStream_ EXTENDS Afx_ISpeechBaseStream
			DECLARE ABSTRACT FUNCTION Open (BYVAL FileName AS AFX_BSTR, BYVAL FileMode AS SpeechStreamFileMode = 0, BYVAL DoEvents AS VARIANT_BOOL = 0) AS HRESULT
			DECLARE ABSTRACT FUNCTION Close () AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechGrammarRule
	' IID: {AFE719CF-5DD1-44F2-999C-7A399F1CFCCC}
	' Documentation string: Afx_ISpeechGrammarRule Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 7
	' ########################################################################################
	
	#ifndef __Afx_ISpeechGrammarRule_INTERFACE_DEFINED__
		#define __Afx_ISpeechGrammarRule_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechGrammarRule_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_Attributes (BYVAL Attributes AS SpeechRuleAttributes PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_InitialState (BYVAL State AS Afx_ISpeechGrammarRuleState PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Name (BYVAL Name AS AFX_BSTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Id (BYVAL Id AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Clear () AS HRESULT
			DECLARE ABSTRACT FUNCTION AddResource (BYVAL ResourceName AS AFX_BSTR, BYVAL ResourceValue AS AFX_BSTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION AddState (BYVAL State AS Afx_ISpeechGrammarRuleState PTR PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechGrammarRules
	' IID: {6FFA3B44-FC2D-40D1-8AFC-32911C7F1AD1}
	' Documentation string: Afx_ISpeechGrammarRules Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 8
	' ########################################################################################
	
	#ifndef __Afx_ISpeechGrammarRules_INTERFACE_DEFINED__
		#define __Afx_ISpeechGrammarRules_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechGrammarRules_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_Count (BYVAL Count AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION FindRule (BYVAL RuleNameOrId AS VARIANT, BYVAL Rule AS Afx_ISpeechGrammarRule PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Item (BYVAL Index AS LONG, BYVAL Rule AS Afx_ISpeechGrammarRule PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get__NewEnum (BYVAL EnumVARIANT AS Afx_IUnknown PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Dynamic (BYVAL Dynamic AS VARIANT_BOOL PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Add (BYVAL RuleName AS AFX_BSTR, BYVAL Attributes AS SpeechRuleAttributes, BYVAL RuleId AS LONG = 0, BYVAL Rule AS Afx_ISpeechGrammarRule PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Commit () AS HRESULT
			DECLARE ABSTRACT FUNCTION CommitAndSave (BYVAL ErrorText AS AFX_BSTR PTR, BYVAL SaveStream AS VARIANT PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechGrammarRuleState
	' IID: {D4286F2C-EE67-45AE-B928-28D695362EDA}
	' Documentation string: Afx_ISpeechGrammarRuleState Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 5
	' ########################################################################################
	
	#ifndef __Afx_ISpeechGrammarRuleState_INTERFACE_DEFINED__
		#define __Afx_ISpeechGrammarRuleState_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechGrammarRuleState_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_Rule (BYVAL Rule AS Afx_ISpeechGrammarRule PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Transitions (BYVAL Transitions AS Afx_ISpeechGrammarRuleStateTransitions PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION AddWordTransition (BYVAL DestState AS Afx_ISpeechGrammarRuleState PTR, BYVAL Words AS AFX_BSTR, BYVAL Separators AS AFX_BSTR, BYVAL Type AS SpeechGrammarWordType = 1, BYVAL PropertyName AS AFX_BSTR, BYVAL PropertyId AS LONG = 0, BYVAL PropertyValue AS VARIANT PTR, BYVAL Weight AS SINGLE = 1) AS HRESULT
			DECLARE ABSTRACT FUNCTION AddRuleTransition (BYVAL DestinationState AS Afx_ISpeechGrammarRuleState PTR, BYVAL Rule AS Afx_ISpeechGrammarRule PTR, BYVAL PropertyName AS AFX_BSTR, BYVAL PropertyId AS LONG = 0, BYVAL PropertyValue AS VARIANT PTR, BYVAL Weight AS SINGLE = 1) AS HRESULT
			DECLARE ABSTRACT FUNCTION AddSpecialTransition (BYVAL DestinationState AS Afx_ISpeechGrammarRuleState PTR, BYVAL Type AS SpeechSpecialTransitionType, BYVAL PropertyName AS AFX_BSTR, BYVAL PropertyId AS LONG = 0, BYVAL PropertyValue AS VARIANT PTR, BYVAL Weight AS SINGLE = 1) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechGrammarRuleStateTransition
	' IID: {CAFD1DB1-41D1-4A06-9863-E2E81DA17A9A}
	' Documentation string: Afx_ISpeechGrammarRuleStateTransition Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 8
	' ########################################################################################
	
	#ifndef __Afx_ISpeechGrammarRuleStateTransition_INTERFACE_DEFINED__
		#define __Afx_ISpeechGrammarRuleStateTransition_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechGrammarRuleStateTransition_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_Type (BYVAL Type AS SpeechGrammarRuleStateTransitionType PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Text (BYVAL Text AS AFX_BSTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Rule (BYVAL Rule AS Afx_ISpeechGrammarRule PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Weight (BYVAL Weight AS VARIANT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_PropertyName (BYVAL PropertyName AS AFX_BSTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_PropertyId (BYVAL PropertyId AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_PropertyValue (BYVAL PropertyValue AS VARIANT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_NextState (BYVAL NextState AS Afx_ISpeechGrammarRuleState PTR PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechGrammarRuleStateTransitions
	' IID: {EABCE657-75BC-44A2-AA7F-C56476742963}
	' Documentation string: Afx_ISpeechGrammarRuleStateTransitions Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __Afx_ISpeechGrammarRuleStateTransitions_INTERFACE_DEFINED__
		#define __Afx_ISpeechGrammarRuleStateTransitions_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechGrammarRuleStateTransitions_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_Count (BYVAL Count AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Item (BYVAL Index AS LONG, BYVAL Transition AS Afx_ISpeechGrammarRuleStateTransition PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get__NewEnum (BYVAL EnumVARIANT AS Afx_IUnknown PTR PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechLexicon
	' IID: {3DA7627A-C7AE-4B23-8708-638C50362C25}
	' Documentation string: Afx_ISpeechLexicon Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 8
	' ########################################################################################
	
	#ifndef __Afx_ISpeechLexicon_INTERFACE_DEFINED__
		#define __Afx_ISpeechLexicon_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechLexicon_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_GenerationId (BYVAL GenerationId AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetWords (BYVAL Flags AS SpeechLexiconType = 3, BYVAL GenerationId AS LONG PTR = 0, BYVAL Words AS Afx_ISpeechLexiconWords PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION AddPronunciation (BYVAL bstrWord AS AFX_BSTR, BYVAL LangId AS LONG, BYVAL PartOfSpeech AS SpeechPartOfSpeech = 0, BYVAL bstrPronunciation AS AFX_BSTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION AddPronunciationByPhoneIds (BYVAL bstrWord AS AFX_BSTR, BYVAL LangId AS LONG, BYVAL PartOfSpeech AS SpeechPartOfSpeech = 0, BYVAL PhoneIds AS VARIANT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION RemovePronunciation (BYVAL bstrWord AS AFX_BSTR, BYVAL LangId AS LONG, BYVAL PartOfSpeech AS SpeechPartOfSpeech = 0, BYVAL bstrPronunciation AS AFX_BSTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION RemovePronunciationByPhoneIds (BYVAL bstrWord AS AFX_BSTR, BYVAL LangId AS LONG, BYVAL PartOfSpeech AS SpeechPartOfSpeech = 0, BYVAL PhoneIds AS VARIANT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetPronunciations (BYVAL bstrWord AS AFX_BSTR, BYVAL LangId AS LONG = 0, BYVAL TypeFlags AS SpeechLexiconType = 3, BYVAL ppPronunciations AS Afx_ISpeechLexiconPronunciations PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetGenerationChange (BYVAL GenerationId AS LONG PTR, BYVAL ppWords AS Afx_ISpeechLexiconWords PTR PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechLexiconPronunciation
	' IID: {95252C5D-9E43-4F4A-9899-48EE73352F9F}
	' Documentation string: Afx_ISpeechLexiconPronunciation Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 5
	' ########################################################################################
	
	#ifndef __Afx_ISpeechLexiconPronunciation_INTERFACE_DEFINED__
		#define __Afx_ISpeechLexiconPronunciation_INTERFACE_DEFINED__
		
		Type Afx_ISpeechLexiconPronunciation_ Extends Afx_IDispatch
			Declare Abstract Function get_Type (ByVal LexiconType As SpeechLexiconType Ptr) As HRESULT
			Declare Abstract Function get_LangId (ByVal LangId As Long Ptr) As HRESULT
			Declare Abstract Function get_PartOfSpeech (ByVal PartOfSpeech As SpeechPartOfSpeech Ptr) As HRESULT
			Declare Abstract Function get_PhoneIds (ByVal PhoneIds As VARIANT Ptr) As HRESULT
			Declare Abstract Function get_Symbolic (ByVal Symbolic As AFX_BSTR Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechLexiconPronunciations
	' IID: {72829128-5682-4704-A0D4-3E2BB6F2EAD3}
	' Documentation string: Afx_ISpeechLexiconPronunciations Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __Afx_ISpeechLexiconPronunciations_INTERFACE_DEFINED__
		#define __Afx_ISpeechLexiconPronunciations_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechLexiconPronunciations_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_Count (BYVAL Count AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Item (BYVAL Index AS LONG, BYVAL Pronunciation AS Afx_ISpeechLexiconPronunciation PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get__NewEnum (BYVAL EnumVARIANT AS Afx_IUnknown PTR PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechLexiconWord
	' IID: {4E5B933C-C9BE-48ED-8842-1EE51BB1D4FF}
	' Documentation string: Afx_ISpeechLexiconWord Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 4
	' ########################################################################################
	
	#ifndef __Afx_ISpeechLexiconWord_INTERFACE_DEFINED__
		#define __Afx_ISpeechLexiconWord_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechLexiconWord_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_LangId (BYVAL LangId AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Type (BYVAL WordType AS SpeechWordType PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Word (BYVAL Word AS AFX_BSTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Pronunciations (BYVAL Pronunciations AS Afx_ISpeechLexiconPronunciations PTR PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechLexiconWords
	' IID: {8D199862-415E-47D5-AC4F-FAA608B424E6}
	' Documentation string: Afx_ISpeechLexiconWords Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __Afx_ISpeechLexiconWords_INTERFACE_DEFINED__
		#define __Afx_ISpeechLexiconWords_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechLexiconWords_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_Count (BYVAL Count AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Item (BYVAL Index AS LONG, BYVAL Word AS Afx_ISpeechLexiconWord PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get__NewEnum (BYVAL EnumVARIANT AS Afx_IUnknown PTR PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechMemoryStream
	' IID: {EEB14B68-808B-4ABE-A5EA-B51DA7588008}
	' Documentation string: Afx_ISpeechMemoryStream Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = Afx_ISpeechBaseStream
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __Afx_ISpeechMemoryStream_INTERFACE_DEFINED__
		#define __Afx_ISpeechMemoryStream_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechMemoryStream_ EXTENDS Afx_ISpeechBaseStream
			DECLARE ABSTRACT FUNCTION SetData (BYVAL Data AS VARIANT) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetData (BYVAL pData AS VARIANT PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechMMSysAudio
	' IID: {3C76AF6D-1FD7-4831-81D1-3B71D5A13C44}
	' Documentation string: Afx_ISpeechMMSysAudio Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = Afx_ISpeechAudio
	' Number of methods = 5
	' ########################################################################################
	
	#ifndef __Afx_ISpeechMMSysAudio_INTERFACE_DEFINED__
		#define __Afx_ISpeechMMSysAudio_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechMMSysAudio_ EXTENDS Afx_ISpeechAudio
			DECLARE ABSTRACT FUNCTION get_DeviceId (BYVAL DeviceId AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_DeviceId (BYVAL DeviceId AS LONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_LineId (BYVAL LineId AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_LineId (BYVAL LineId AS LONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_MMHandle (BYVAL Handle AS LONG PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechObjectToken
	' IID: {C74A3ADC-B727-4500-A84A-B526721C8B8C}
	' Documentation string: Afx_ISpeechObjectToken Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 13
	' ########################################################################################
	
	#ifndef __Afx_ISpeechObjectToken_INTERFACE_DEFINED__
		#define __Afx_ISpeechObjectToken_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechObjectToken_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_Id (BYVAL ObjectId AS AFX_BSTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_DataKey (BYVAL DataKey AS Afx_ISpeechDataKey PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Category (BYVAL Category AS Afx_ISpeechObjectTokenCategory PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetDescription (BYVAL Locale AS LONG = 0, BYVAL Description AS AFX_BSTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetId (BYVAL Id AS AFX_BSTR, BYVAL CategoryID AS AFX_BSTR, BYVAL CreateIfNotExist AS VARIANT_BOOL = 0) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetAttribute (BYVAL AttributeName AS AFX_BSTR, BYVAL AttributeValue AS AFX_BSTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION CreateInstance (BYVAL pUnkOuter AS Afx_IUnknown PTR, BYVAL ClsContext AS SpeechTokenContext = 23, BYVAL Object AS Afx_IUnknown PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Remove (BYVAL ObjectStorageCLSID AS AFX_BSTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetStorageFileName (BYVAL ObjectStorageCLSID AS AFX_BSTR, BYVAL KeyName AS AFX_BSTR, BYVAL FileName AS AFX_BSTR, BYVAL Folder AS SpeechTokenShellFolder, BYVAL FilePath AS AFX_BSTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION RemoveStorageFileName (BYVAL ObjectStorageCLSID AS AFX_BSTR, BYVAL KeyName AS AFX_BSTR, BYVAL DeleteFile AS VARIANT_BOOL) AS HRESULT
			DECLARE ABSTRACT FUNCTION IsUISupported (BYVAL TypeOfUI AS AFX_BSTR, BYVAL ExtraData AS VARIANT PTR, BYVAL Object AS Afx_IUnknown PTR, BYVAL Supported AS VARIANT_BOOL PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION DisplayUI (BYVAL hWnd AS LONG, BYVAL Title AS AFX_BSTR, BYVAL TypeOfUI AS AFX_BSTR, BYVAL ExtraData AS VARIANT PTR, BYVAL Object AS Afx_IUnknown PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION MatchesAttributes (BYVAL Attributes AS AFX_BSTR, BYVAL Matches AS VARIANT_BOOL PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechObjectTokenCategory
	' IID: {CA7EAC50-2D01-4145-86D4-5AE7D70F4469}
	' Documentation string: Afx_ISpeechObjectTokenCategory Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 6
	' ########################################################################################
	
	#ifndef __Afx_ISpeechObjectTokenCategory_INTERFACE_DEFINED__
		#define __Afx_ISpeechObjectTokenCategory_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechObjectTokenCategory_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_Id (BYVAL Id AS AFX_BSTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_Default (BYVAL TokenId AS AFX_BSTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Default (BYVAL TokenId AS AFX_BSTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetId (BYVAL Id AS AFX_BSTR, BYVAL CreateIfNotExist AS VARIANT_BOOL = 0) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetDataKey (BYVAL Location AS SpeechDataKeyLocation = 0, BYVAL DataKey AS Afx_ISpeechDataKey PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION EnumerateTokens (BYVAL RequiredAttributes AS AFX_BSTR, BYVAL OptionalAttributes AS AFX_BSTR, BYVAL Tokens AS Afx_ISpeechObjectTokens PTR PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechObjectTokens
	' IID: {9285B776-2E7B-4BC0-B53E-580EB6FA967F}
	' Documentation string: Afx_ISpeechObjectTokens Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __Afx_ISpeechObjectTokens_INTERFACE_DEFINED__
		#define __Afx_ISpeechObjectTokens_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechObjectTokens_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_Count (BYVAL Count AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Item (BYVAL Index AS LONG, BYVAL Token AS Afx_ISpeechObjectToken PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get__NewEnum (BYVAL ppEnumVARIANT AS Afx_IUnknown PTR PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechPhoneConverter
	' IID: {C3E4F353-433F-43D6-89A1-6A62A7054C3D}
	' Documentation string: Afx_ISpeechPhoneConverter Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 4
	' ########################################################################################
	
	#ifndef __Afx_ISpeechPhoneConverter_INTERFACE_DEFINED__
		#define __Afx_ISpeechPhoneConverter_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechPhoneConverter_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_LanguageId (BYVAL LanguageId AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_LanguageId (BYVAL LanguageId AS LONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION PhoneToId (BYVAL Phonemes AS AFX_BSTR, BYVAL IdArray AS VARIANT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION IdToPhone (BYVAL IdArray AS VARIANT, BYVAL Phonemes AS AFX_BSTR PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechPhraseAlternate
	' IID: {27864A2A-2B9F-4CB8-92D3-0D2722FD1E73}
	' Documentation string: Afx_ISpeechPhraseAlternate Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 5
	' ########################################################################################
	
	#ifndef __Afx_ISpeechPhraseAlternate_INTERFACE_DEFINED__
		#define __Afx_ISpeechPhraseAlternate_INTERFACE_DEFINED__
		
		Type Afx_ISpeechPhraseAlternate_ Extends Afx_IDispatch
			Declare Abstract Function get_RecoResult (ByVal RecoResult As Afx_ISpeechRecoResult Ptr Ptr) As HRESULT
			Declare Abstract Function get_StartElementInResult (ByVal StartElement As Long Ptr) As HRESULT
			Declare Abstract Function get_NumberOfElementsInResult (ByVal NumberOfElements As Long Ptr) As HRESULT
			Declare Abstract Function get_PhraseInfo (ByVal PhraseInfo As Afx_ISpeechPhraseInfo Ptr Ptr) As HRESULT
			Declare Abstract Function Commit () As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechPhraseAlternates
	' IID: {B238B6D5-F276-4C3D-A6C1-2974801C3CC2}
	' Documentation string: Afx_ISpeechPhraseAlternates Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __Afx_ISpeechPhraseAlternates_INTERFACE_DEFINED__
		#define __Afx_ISpeechPhraseAlternates_INTERFACE_DEFINED__
		
		Type Afx_ISpeechPhraseAlternates_ Extends Afx_IDispatch
			Declare Abstract Function get_Count (ByVal Count As Long Ptr) As HRESULT
			Declare Abstract Function Item (ByVal Index As Long, ByVal PhraseAlternate As Afx_ISpeechPhraseAlternate Ptr Ptr) As HRESULT
			Declare Abstract Function get__NewEnum (ByVal EnumVARIANT As Afx_IUnknown Ptr Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechPhraseElement
	' IID: {E6176F96-E373-4801-B223-3B62C068C0B4}
	' Documentation string: Afx_ISpeechPhraseElement Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 13
	' ########################################################################################
	
	#ifndef __Afx_ISpeechPhraseElement_INTERFACE_DEFINED__
		#define __Afx_ISpeechPhraseElement_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechPhraseElement_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_AudioTimeOffset (BYVAL AudioTimeOffset AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_AudioSizeTime (BYVAL AudioSizeTime AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_AudioStreamOffset (BYVAL AudioStreamOffset AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_AudioSizeBytes (BYVAL AudioSizeBytes AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_RetainedStreamOffset (BYVAL RetainedStreamOffset AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_RetainedSizeBytes (BYVAL RetainedSizeBytes AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_DisplayText (BYVAL DisplayText AS AFX_BSTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_LexicalForm (BYVAL LexicalForm AS AFX_BSTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Pronunciation (BYVAL Pronunciation AS VARIANT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_DisplayAttributes (BYVAL DisplayAttributes AS SpeechDisplayAttributes PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_RequiredConfidence (BYVAL RequiredConfidence AS SpeechEngineConfidence PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_ActualConfidence (BYVAL ActualConfidence AS SpeechEngineConfidence PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_EngineConfidence (BYVAL EngineConfidence AS SINGLE PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechPhraseElements
	' IID: {0626B328-3478-467D-A0B3-D0853B93DDA3}
	' Documentation string: Afx_ISpeechPhraseElements Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __Afx_ISpeechPhraseElements_INTERFACE_DEFINED__
		#define __Afx_ISpeechPhraseElements_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechPhraseElements_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_Count (BYVAL Count AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Item (BYVAL Index AS LONG, BYVAL Element AS Afx_ISpeechPhraseElement PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get__NewEnum (BYVAL EnumVARIANT AS Afx_IUnknown PTR PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechPhraseInfo
	' IID: {961559CF-4E67-4662-8BF0-D93F1FCD61B3}
	' Documentation string: Afx_ISpeechPhraseInfo Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 16
	' ########################################################################################
	
	#ifndef __Afx_ISpeechPhraseInfo_INTERFACE_DEFINED__
		#define __Afx_ISpeechPhraseInfo_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechPhraseInfo_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_LanguageId (BYVAL LanguageId AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_GrammarId (BYVAL GrammarId AS VARIANT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_StartTime (BYVAL StartTime AS VARIANT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_AudioStreamPosition (BYVAL AudioStreamPosition AS VARIANT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_AudioSizeBytes (BYVAL pAudioSizeBytes AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_RetainedSizeBytes (BYVAL RetainedSizeBytes AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_AudioSizeTime (BYVAL AudioSizeTime AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Rule (BYVAL Rule AS Afx_ISpeechPhraseRule PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Properties (BYVAL Properties AS Afx_ISpeechPhraseProperties PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Elements (BYVAL Elements AS Afx_ISpeechPhraseElements PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Replacements (BYVAL Replacements AS Afx_ISpeechPhraseReplacements PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_EngineId (BYVAL EngineIdGuid AS AFX_BSTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_EnginePrivateData (BYVAL PrivateData AS VARIANT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SaveToMemory (BYVAL PhraseBlock AS VARIANT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetText (BYVAL StartElement AS LONG = 0, BYVAL Elements AS LONG = -1, BYVAL UseReplacements AS VARIANT_BOOL = -1, BYVAL Text AS AFX_BSTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetDisplayAttributes (BYVAL StartElement AS LONG = 0, BYVAL Elements AS LONG = -1, BYVAL UseReplacements AS VARIANT_BOOL = -1, BYVAL DisplayAttributes AS SpeechDisplayAttributes PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechPhraseInfoBuilder
	' IID: {3B151836-DF3A-4E0A-846C-D2ADC9334333}
	' Documentation string: Afx_ISpeechPhraseInfoBuilder Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 1
	' ########################################################################################
	
	#ifndef __Afx_ISpeechPhraseInfoBuilder_INTERFACE_DEFINED__
		#define __Afx_ISpeechPhraseInfoBuilder_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechPhraseInfoBuilder_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION RestorePhraseFromMemory (BYVAL PhraseInMemory AS VARIANT PTR, BYVAL PhraseInfo AS Afx_ISpeechPhraseInfo PTR PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechPhraseProperties
	' IID: {08166B47-102E-4B23-A599-BDB98DBFD1F4}
	' Documentation string: Afx_ISpeechPhraseProperties Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __Afx_ISpeechPhraseProperties_INTERFACE_DEFINED__
		#define __Afx_ISpeechPhraseProperties_INTERFACE_DEFINED__
		
		Type Afx_ISpeechPhraseProperties_ Extends Afx_IDispatch
			Declare Abstract Function get_Count (ByVal Count As Long Ptr) As HRESULT
			Declare Abstract Function Item (ByVal Index As Long, ByVal Property As Afx_ISpeechPhraseProperty Ptr Ptr) As HRESULT
			Declare Abstract Function get__NewEnum (ByVal EnumVARIANT As Afx_IUnknown Ptr Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechPhraseProperty
	' IID: {CE563D48-961E-4732-A2E1-378A42B430BE}
	' Documentation string: Afx_ISpeechPhraseProperty Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 9
	' ########################################################################################
	
	#ifndef __Afx_ISpeechPhraseProperty_INTERFACE_DEFINED__
		#define __Afx_ISpeechPhraseProperty_INTERFACE_DEFINED__
		
		Type Afx_ISpeechPhraseProperty_ Extends Afx_IDispatch
			Declare Abstract Function get_Name (ByVal Name As AFX_BSTR Ptr) As HRESULT
			Declare Abstract Function get_Id (ByVal Id As Long Ptr) As HRESULT
			Declare Abstract Function get_Value (ByVal Value As VARIANT Ptr) As HRESULT
			Declare Abstract Function get_FirstElement (ByVal FirstElement As Long Ptr) As HRESULT
			Declare Abstract Function get_NumberOfElements (ByVal NumberOfElements As Long Ptr) As HRESULT
			Declare Abstract Function get_EngineConfidence (ByVal Confidence As Single Ptr) As HRESULT
			Declare Abstract Function get_Confidence (ByVal Confidence As SpeechEngineConfidence Ptr) As HRESULT
			Declare Abstract Function get_Parent (ByVal ParentProperty As Afx_ISpeechPhraseProperty Ptr Ptr) As HRESULT
			DECLARE ABSTRACT FUNCTION get_Children (BYVAL Children AS Afx_ISpeechPhraseProperties PTR PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechPhraseReplacement
	' IID: {2890A410-53A7-4FB5-94EC-06D4998E3D02}
	' Documentation string: Afx_ISpeechPhraseReplacement Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 4
	' ########################################################################################
	
	#ifndef __Afx_ISpeechPhraseReplacement_INTERFACE_DEFINED__
		#define __Afx_ISpeechPhraseReplacement_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechPhraseReplacement_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_DisplayAttributes (BYVAL DisplayAttributes AS SpeechDisplayAttributes PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Text (BYVAL Text AS AFX_BSTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_FirstElement (BYVAL FirstElement AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_NumberOfElements (BYVAL NumberOfElements AS LONG PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechPhraseReplacements
	' IID: {38BC662F-2257-4525-959E-2069D2596C05}
	' Documentation string: Afx_ISpeechPhraseReplacements Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __Afx_ISpeechPhraseReplacements_INTERFACE_DEFINED__
		#define __Afx_ISpeechPhraseReplacements_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechPhraseReplacements_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_Count (BYVAL Count AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Item (BYVAL Index AS LONG, BYVAL Reps AS Afx_ISpeechPhraseReplacement PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get__NewEnum (BYVAL EnumVARIANT AS Afx_IUnknown PTR PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechPhraseRule
	' IID: {A7BFE112-A4A0-48D9-B602-C313843F6964}
	' Documentation string: Afx_ISpeechPhraseRule Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 8
	' ########################################################################################
	
	#ifndef __Afx_ISpeechPhraseRule_INTERFACE_DEFINED__
		#define __Afx_ISpeechPhraseRule_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechPhraseRule_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_Name (BYVAL Name AS AFX_BSTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Id (BYVAL Id AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_FirstElement (BYVAL FirstElement AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_NumberOfElements (BYVAL NumberOfElements AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Parent (BYVAL Parent AS Afx_ISpeechPhraseRule PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Children (BYVAL Children AS Afx_ISpeechPhraseRules PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Confidence (BYVAL ActualConfidence AS SpeechEngineConfidence PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_EngineConfidence (BYVAL EngineConfidence AS SINGLE PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechPhraseRules
	' IID: {9047D593-01DD-4B72-81A3-E4A0CA69F407}
	' Documentation string: Afx_ISpeechPhraseRules Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __Afx_ISpeechPhraseRules_INTERFACE_DEFINED__
		#define __Afx_ISpeechPhraseRules_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechPhraseRules_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_Count (BYVAL Count AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Item (BYVAL Index AS LONG, BYVAL Rule AS Afx_ISpeechPhraseRule PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get__NewEnum (BYVAL EnumVARIANT AS Afx_IUnknown PTR PTR) AS HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechRecoContext
	' IID: {580AA49D-7E1E-4809-B8E2-57DA806104B8}
	' Documentation string: Afx_ISpeechRecoContext Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 25
	' ########################################################################################
	
	#ifndef __Afx_ISpeechRecoContext_INTERFACE_DEFINED__
		#define __Afx_ISpeechRecoContext_INTERFACE_DEFINED__
		
		Type Afx_ISpeechRecoContext_ Extends Afx_IDispatch
			Declare Abstract Function get_Recognizer (ByVal Recognizer As Afx_ISpeechRecognizer Ptr Ptr) As HRESULT
			Declare Abstract Function get_AudioInputInterferenceStatus (ByVal Interference As SpeechInterference Ptr) As HRESULT
			Declare Abstract Function get_RequestedUIType (ByVal UIType As AFX_BSTR Ptr) As HRESULT
			Declare Abstract Function putref_Voice (ByVal Voice As Afx_ISpeechVoice Ptr) As HRESULT
			Declare Abstract Function get_Voice (ByVal Voice As Afx_ISpeechVoice Ptr Ptr) As HRESULT
			Declare Abstract Function put_AllowVoiceFormatMatchingOnNextSet (ByVal pAllow As VARIANT_BOOL) As HRESULT
			Declare Abstract Function get_AllowVoiceFormatMatchingOnNextSet (ByVal pAllow As VARIANT_BOOL Ptr) As HRESULT
			Declare Abstract Function put_VoicePurgeEvent (ByVal EventInterest As SpeechRecoEvents) As HRESULT
			Declare Abstract Function get_VoicePurgeEvent (ByVal EventInterest As SpeechRecoEvents Ptr) As HRESULT
			Declare Abstract Function put_EventInterests (ByVal EventInterest As SpeechRecoEvents) As HRESULT
			Declare Abstract Function get_EventInterests (ByVal EventInterest As SpeechRecoEvents Ptr) As HRESULT
			Declare Abstract Function put_CmdMaxAlternates (ByVal MaxAlternates As Long) As HRESULT
			Declare Abstract Function get_CmdMaxAlternates (ByVal MaxAlternates As Long Ptr) As HRESULT
			Declare Abstract Function put_State (ByVal State As SpeechRecoContextState) As HRESULT
			Declare Abstract Function get_State (ByVal State As SpeechRecoContextState Ptr) As HRESULT
			Declare Abstract Function put_RetainedAudio (ByVal Option As SpeechRetainedAudioOptions) As HRESULT
			Declare Abstract Function get_RetainedAudio (ByVal Option As SpeechRetainedAudioOptions Ptr) As HRESULT
			Declare Abstract Function putref_RetainedAudioFormat (ByVal Format As Afx_ISpeechAudioFormat Ptr) As HRESULT
			Declare Abstract Function get_RetainedAudioFormat (ByVal Format As Afx_ISpeechAudioFormat Ptr Ptr) As HRESULT
			DECLARE ABSTRACT FUNCTION Pause () AS HRESULT
			DECLARE ABSTRACT FUNCTION Resume () AS HRESULT
			DECLARE ABSTRACT FUNCTION CreateGrammar (BYVAL GrammarId AS VARIANT = TYPE<VARIANT>(VT_ERROR,0,0,0,DISP_E_PARAMNOTFOUND), BYVAL Grammar AS Afx_ISpeechRecoGrammar PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION CreateResultFromMemory (BYVAL ResultBlock AS VARIANT PTR, BYVAL Result AS Afx_ISpeechRecoResult PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Bookmark (BYVAL Options AS SpeechBookmarkOptions, BYVAL StreamPos AS VARIANT, BYVAL BookmarkId AS VARIANT) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetAdaptationData (BYVAL AdaptationString AS AFX_BSTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechRecognizer
	' IID: {2D5F1C0C-BD75-4B08-9478-3B11FEA2586C}
	' Documentation string: Afx_ISpeechRecognizer Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 26
	' ########################################################################################
	
	#ifndef __Afx_ISpeechRecognizer_INTERFACE_DEFINED__
		#define __Afx_ISpeechRecognizer_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechRecognizer_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION putref_Recognizer (BYVAL Recognizer AS Afx_ISpeechObjectToken PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Recognizer (BYVAL Recognizer AS Afx_ISpeechObjectToken PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_AllowAudioInputFormatChangesOnNextSet (BYVAL Allow AS VARIANT_BOOL) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_AllowAudioInputFormatChangesOnNextSet (BYVAL Allow AS VARIANT_BOOL PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION putref_AudioInput (BYVAL AudioInput AS Afx_ISpeechObjectToken PTR = 0) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_AudioInput (BYVAL AudioInput AS Afx_ISpeechObjectToken PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION putref_AudioInputStream (BYVAL AudioInputStream AS Afx_ISpeechBaseStream PTR = 0) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_AudioInputStream (BYVAL AudioInputStream AS Afx_ISpeechBaseStream PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_IsShared (BYVAL Shared AS VARIANT_BOOL PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_State (BYVAL State AS SpeechRecognizerState) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_State (BYVAL State AS SpeechRecognizerState PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Status (BYVAL Status AS Afx_ISpeechRecognizerStatus PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION putref_Profile (BYVAL Profile AS Afx_ISpeechObjectToken PTR = 0) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Profile (BYVAL Profile AS Afx_ISpeechObjectToken PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION EmulateRecognition (BYVAL TextElements AS VARIANT, BYVAL ElementDisplayAttributes AS VARIANT PTR, BYVAL LanguageId AS LONG = 0) AS HRESULT
			DECLARE ABSTRACT FUNCTION CreateRecoContext (BYVAL NewContext AS Afx_ISpeechRecoContext PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetFormat (BYVAL Type AS SpeechFormatType, BYVAL Format AS Afx_ISpeechAudioFormat PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetPropertyNumber (BYVAL Name AS AFX_BSTR, BYVAL Value AS LONG, BYVAL Supported AS VARIANT_BOOL PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetPropertyNumber (BYVAL Name AS AFX_BSTR, BYVAL Value AS LONG PTR, BYVAL Supported AS VARIANT_BOOL PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetPropertyString (BYVAL Name AS AFX_BSTR, BYVAL Value AS AFX_BSTR, BYVAL Supported AS VARIANT_BOOL PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetPropertyString (BYVAL Name AS AFX_BSTR, BYVAL Value AS AFX_BSTR PTR, BYVAL Supported AS VARIANT_BOOL PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION IsUISupported (BYVAL TypeOfUI AS AFX_BSTR, BYVAL ExtraData AS VARIANT PTR, BYVAL Supported AS VARIANT_BOOL PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION DisplayUI (BYVAL hWndParent AS LONG, BYVAL Title AS AFX_BSTR, BYVAL TypeOfUI AS AFX_BSTR, BYVAL ExtraData AS VARIANT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetRecognizers (BYVAL RequiredAttributes AS AFX_BSTR, BYVAL OptionalAttributes AS AFX_BSTR, BYVAL ObjectTokens AS Afx_ISpeechObjectTokens PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetAudioInputs (BYVAL RequiredAttributes AS AFX_BSTR, BYVAL OptionalAttributes AS AFX_BSTR, BYVAL ObjectTokens AS Afx_ISpeechObjectTokens PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetProfiles (BYVAL RequiredAttributes AS AFX_BSTR, BYVAL OptionalAttributes AS AFX_BSTR, BYVAL ObjectTokens AS Afx_ISpeechObjectTokens PTR PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechRecognizerStatus
	' IID: {BFF9E781-53EC-484E-BB8A-0E1B5551E35C}
	' Documentation string: Afx_ISpeechRecognizerStatus Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 6
	' ########################################################################################
	
	#ifndef __Afx_ISpeechRecognizerStatus_INTERFACE_DEFINED__
		#define __Afx_ISpeechRecognizerStatus_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechRecognizerStatus_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_AudioStatus (BYVAL AudioStatus AS Afx_ISpeechAudioStatus PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_CurrentStreamPosition (BYVAL pCurrentStreamPos AS VARIANT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_CurrentStreamNumber (BYVAL StreamNumber AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_NumberOfActiveRules (BYVAL NumberOfActiveRules AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_ClsidEngine (BYVAL ClsidEngine AS AFX_BSTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_SupportedLanguages (BYVAL SupportedLanguages AS VARIANT PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechRecoGrammar
	' IID: {B6D6F79F-2158-4E50-B5BC-9A9CCD852A09}
	' Documentation string: Afx_ISpeechRecoGrammar Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 19
	' ########################################################################################
	
	#ifndef __Afx_ISpeechRecoGrammar_INTERFACE_DEFINED__
		#define __Afx_ISpeechRecoGrammar_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechRecoGrammar_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_Id (BYVAL Id AS VARIANT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_RecoContext (BYVAL RecoContext AS Afx_ISpeechRecoContext PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_State (BYVAL State AS SpeechGrammarState) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_State (BYVAL State AS SpeechGrammarState PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Rules (BYVAL Rules AS Afx_ISpeechGrammarRules PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Reset (BYVAL NewLanguage AS LONG = 0) AS HRESULT
			DECLARE ABSTRACT FUNCTION CmdLoadFromFile (BYVAL FileName AS AFX_BSTR, BYVAL LoadOption AS SpeechLoadOption = 0) AS HRESULT
			DECLARE ABSTRACT FUNCTION CmdLoadFromObject (BYVAL ClassId AS AFX_BSTR, BYVAL GrammarName AS AFX_BSTR, BYVAL LoadOption AS SpeechLoadOption = 0) AS HRESULT
			DECLARE ABSTRACT FUNCTION CmdLoadFromResource (BYVAL hModule AS LONG, BYVAL ResourceName AS VARIANT, BYVAL ResourceType AS VARIANT, BYVAL LanguageId AS LONG, BYVAL LoadOption AS SpeechLoadOption = 0) AS HRESULT
			DECLARE ABSTRACT FUNCTION CmdLoadFromMemory (BYVAL GrammarData AS VARIANT, BYVAL LoadOption AS SpeechLoadOption = 0) AS HRESULT
			DECLARE ABSTRACT FUNCTION CmdLoadFromProprietaryGrammar (BYVAL ProprietaryGuid AS AFX_BSTR, BYVAL ProprietaryString AS AFX_BSTR, BYVAL ProprietaryData AS VARIANT, BYVAL LoadOption AS SpeechLoadOption = 0) AS HRESULT
			DECLARE ABSTRACT FUNCTION CmdSetRuleState (BYVAL Name AS AFX_BSTR, BYVAL State AS SpeechRuleState) AS HRESULT
			DECLARE ABSTRACT FUNCTION CmdSetRuleIdState (BYVAL RuleId AS LONG, BYVAL State AS SpeechRuleState) AS HRESULT
			DECLARE ABSTRACT FUNCTION DictationLoad (BYVAL TopicName AS AFX_BSTR, BYVAL LoadOption AS SpeechLoadOption = 0) AS HRESULT
			DECLARE ABSTRACT FUNCTION DictationUnload () AS HRESULT
			DECLARE ABSTRACT FUNCTION DictationSetState (BYVAL State AS SpeechRuleState) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetWordSequenceData (BYVAL Text AS AFX_BSTR, BYVAL TextLength AS LONG, BYVAL Info AS Afx_ISpeechTextSelectionInformation PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetTextSelection (BYVAL Info AS Afx_ISpeechTextSelectionInformation PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION IsPronounceable (BYVAL Word AS AFX_BSTR, BYVAL WordPronounceable AS SpeechWordPronounceable PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechRecoResult
	' IID: {ED2879CF-CED9-4EE6-A534-DE0191D5468D}
	' Documentation string: Afx_ISpeechRecoResult Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 10
	' ########################################################################################
	
	#ifndef __Afx_ISpeechRecoResult_INTERFACE_DEFINED__
		#define __Afx_ISpeechRecoResult_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechRecoResult_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_RecoContext (BYVAL RecoContext AS Afx_ISpeechRecoContext PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Times (BYVAL Times AS Afx_ISpeechRecoResultTimes PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION putref_AudioFormat (BYVAL Format AS Afx_ISpeechAudioFormat PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_AudioFormat (BYVAL Format AS Afx_ISpeechAudioFormat PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_PhraseInfo (BYVAL PhraseInfo AS Afx_ISpeechPhraseInfo PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Alternates (BYVAL RequestCount AS LONG, BYVAL StartElement AS LONG = 0, BYVAL Elements AS LONG = -1, BYVAL Alternates AS Afx_ISpeechPhraseAlternates PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Audio (BYVAL StartElement AS LONG = 0, BYVAL Elements AS LONG = -1, BYVAL Stream AS Afx_ISpeechMemoryStream PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SpeakAudio (BYVAL StartElement AS LONG = 0, BYVAL Elements AS LONG = -1, BYVAL Flags AS SpeechVoiceSpeakFlags = 0, BYVAL StreamNumber AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SaveToMemory (BYVAL ResultBlock AS VARIANT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION DiscardResultInfo (BYVAL ValueTypes AS SpeechDiscardType) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechRecoResult2
	' IID: {8E0A246D-D3C8-45DE-8657-04290C458C3C}
	' Documentation string: Afx_ISpeechRecoResult2 Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = Afx_ISpeechRecoResult
	' Number of methods = 1
	' ########################################################################################
	
	#ifndef __Afx_ISpeechRecoResult2_INTERFACE_DEFINED__
		#define __Afx_ISpeechRecoResult2_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechRecoResult2_ EXTENDS Afx_ISpeechRecoResult
			DECLARE ABSTRACT FUNCTION SetTextFeedback (BYVAL Feedback AS AFX_BSTR, BYVAL WasSuccessful AS VARIANT_BOOL) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechRecoResultDispatch
	' IID: {6D60EB64-ACED-40A6-BBF3-4E557F71DEE2}
	' Documentation string: Afx_ISpeechRecoResultDispatch Interface
	' Attributes =  4432 [&h00001150] [Hidden] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 13
	' ########################################################################################
	
	#ifndef __Afx_ISpeechRecoResultDispatch_INTERFACE_DEFINED__
		#define __Afx_ISpeechRecoResultDispatch_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechRecoResultDispatch_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_RecoContext (BYVAL RecoContext AS Afx_ISpeechRecoContext PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Times (BYVAL Times AS Afx_ISpeechRecoResultTimes PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION putref_AudioFormat (BYVAL Format AS Afx_ISpeechAudioFormat PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_AudioFormat (BYVAL Format AS Afx_ISpeechAudioFormat PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_PhraseInfo (BYVAL PhraseInfo AS Afx_ISpeechPhraseInfo PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Alternates (BYVAL RequestCount AS LONG, BYVAL StartElement AS LONG = 0, BYVAL Elements AS LONG = -1, BYVAL Alternates AS Afx_ISpeechPhraseAlternates PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Audio (BYVAL StartElement AS LONG = 0, BYVAL Elements AS LONG = -1, BYVAL Stream AS Afx_ISpeechMemoryStream PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SpeakAudio (BYVAL StartElement AS LONG = 0, BYVAL Elements AS LONG = -1, BYVAL Flags AS SpeechVoiceSpeakFlags = 0, BYVAL StreamNumber AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SaveToMemory (BYVAL ResultBlock AS VARIANT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION DiscardResultInfo (BYVAL ValueTypes AS SpeechDiscardType) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetXMLResult (BYVAL Options AS SPXMLRESULTOPTIONS, BYVAL pResult AS AFX_BSTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetXMLErrorInfo (BYVAL LineNumber AS LONG PTR, BYVAL ScriptLine AS AFX_BSTR PTR, BYVAL Source AS AFX_BSTR PTR, BYVAL Description AS AFX_BSTR PTR, BYVAL ResultCode AS HRESULT PTR, BYVAL IsError AS VARIANT_BOOL PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetTextFeedback (BYVAL Feedback AS AFX_BSTR, BYVAL WasSuccessful AS VARIANT_BOOL) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechRecoResultTimes
	' IID: {62B3B8FB-F6E7-41BE-BDCB-056B1C29EFC0}
	' Documentation string: Afx_ISpeechRecoResultTimes Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 4
	' ########################################################################################
	
	#ifndef __Afx_ISpeechRecoResultTimes_INTERFACE_DEFINED__
		#define __Afx_ISpeechRecoResultTimes_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechRecoResultTimes_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_StreamTime (BYVAL Time AS VARIANT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Length (BYVAL Length AS VARIANT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_TickCount (BYVAL TickCount AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_OffsetFromStart (BYVAL OffsetFromStart AS VARIANT PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechResourceLoader
	' IID: {B9AC5783-FCD0-4B21-B119-B4F8DA8FD2C3}
	' Documentation string: Afx_ISpeechResourceLoader Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __Afx_ISpeechResourceLoader_INTERFACE_DEFINED__
		#define __Afx_ISpeechResourceLoader_INTERFACE_DEFINED__
		
		Type Afx_ISpeechResourceLoader_ Extends Afx_IDispatch
			Declare Abstract Function LoadResource (ByVal bstrResourceUri As AFX_BSTR, ByVal fAlwaysReload As VARIANT_BOOL, ByVal pStream As Afx_IUnknown Ptr Ptr, ByVal pbstrMIMEType As AFX_BSTR Ptr, ByVal pfModified As VARIANT_BOOL Ptr, ByVal pbstrRedirectUrl As AFX_BSTR Ptr) As HRESULT
			Declare Abstract Function GetLocalCopy (ByVal bstrResourceUri As AFX_BSTR, ByVal pbstrLocalPath As AFX_BSTR Ptr, ByVal pbstrMIMEType As AFX_BSTR Ptr, ByVal pbstrRedirectUrl As AFX_BSTR Ptr) As HRESULT
			Declare Abstract Function ReleaseLocalCopy (ByVal pbstrLocalPath As AFX_BSTR) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechTextSelectionInformation
	' IID: {3B9C7E7A-6EEE-4DED-9092-11657279ADBE}
	' Documentation string: Afx_ISpeechTextSelectionInformation Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 8
	' ########################################################################################
	
	#ifndef __Afx_ISpeechTextSelectionInformation_INTERFACE_DEFINED__
		#define __Afx_ISpeechTextSelectionInformation_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechTextSelectionInformation_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION put_ActiveOffset (BYVAL ActiveOffset AS LONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_ActiveOffset (BYVAL ActiveOffset AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_ActiveLength (BYVAL ActiveLength AS LONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_ActiveLength (BYVAL ActiveLength AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_SelectionOffset (BYVAL SelectionOffset AS LONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_SelectionOffset (BYVAL SelectionOffset AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_SelectionLength (BYVAL SelectionLength AS LONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_SelectionLength (BYVAL SelectionLength AS LONG PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechVoice
	' IID: {269316D8-57BD-11D2-9EEE-00C04F797396}
	' Documentation string: Afx_ISpeechVoice Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 32
	' ########################################################################################
	
	#ifndef __Afx_ISpeechVoice_INTERFACE_DEFINED__
		#define __Afx_ISpeechVoice_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechVoice_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_Status (BYVAL Status AS Afx_ISpeechVoiceStatus PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Voice (BYVAL Voice AS Afx_ISpeechObjectToken PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION putref_Voice (BYVAL Voice AS Afx_ISpeechObjectToken PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_AudioOutput (BYVAL AudioOutput AS Afx_ISpeechObjectToken PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION putref_AudioOutput (BYVAL AudioOutput AS Afx_ISpeechObjectToken PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_AudioOutputStream (BYVAL AudioOutputStream AS Afx_ISpeechBaseStream PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION putref_AudioOutputStream (BYVAL AudioOutputStream AS Afx_ISpeechBaseStream PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Rate (BYVAL Rate AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_Rate (BYVAL Rate AS LONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Volume (BYVAL Volume AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_Volume (BYVAL Volume AS LONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_AllowAudioOutputFormatChangesOnNextSet (BYVAL Allow AS VARIANT_BOOL) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_AllowAudioOutputFormatChangesOnNextSet (BYVAL Allow AS VARIANT_BOOL PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_EventInterests (BYVAL EventInterestFlags AS SpeechVoiceEvents PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_EventInterests (BYVAL EventInterestFlags AS SpeechVoiceEvents) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_Priority (BYVAL Priority AS SpeechVoicePriority) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Priority (BYVAL Priority AS SpeechVoicePriority PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_AlertBoundary (BYVAL Boundary AS SpeechVoiceEvents) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_AlertBoundary (BYVAL Boundary AS SpeechVoiceEvents PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_SynchronousSpeakTimeout (BYVAL msTimeout AS LONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_SynchronousSpeakTimeout (BYVAL msTimeout AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Speak (BYVAL Text AS AFX_BSTR, BYVAL Flags AS SpeechVoiceSpeakFlags = 0, BYVAL StreamNumber AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SpeakStream (BYVAL Stream AS Afx_ISpeechBaseStream PTR, BYVAL Flags AS SpeechVoiceSpeakFlags = 0, BYVAL StreamNumber AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION Pause () AS HRESULT
			DECLARE ABSTRACT FUNCTION Resume () AS HRESULT
			DECLARE ABSTRACT FUNCTION Skip (BYVAL Type AS AFX_BSTR, BYVAL NumItems AS LONG, BYVAL NumSkipped AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetVoices (BYVAL RequiredAttributes AS AFX_BSTR, BYVAL OptionalAttributes AS AFX_BSTR, BYVAL ObjectTokens AS Afx_ISpeechObjectTokens PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetAudioOutputs (BYVAL RequiredAttributes AS AFX_BSTR, BYVAL OptionalAttributes AS AFX_BSTR, BYVAL ObjectTokens AS Afx_ISpeechObjectTokens PTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION WaitUntilDone (BYVAL msTimeout AS LONG, BYVAL Done AS VARIANT_BOOL PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION SpeakCompleteEvent (BYVAL Handle AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION IsUISupported (BYVAL TypeOfUI AS AFX_BSTR, BYVAL ExtraData AS VARIANT PTR, BYVAL Supported AS VARIANT_BOOL PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION DisplayUI (BYVAL hWndParent AS LONG, BYVAL Title AS AFX_BSTR, BYVAL TypeOfUI AS AFX_BSTR, BYVAL ExtraData AS VARIANT PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechVoiceStatus
	' IID: {8BE47B07-57F6-11D2-9EEE-00C04F797396}
	' Documentation string: Afx_ISpeechVoiceStatus Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 12
	' ########################################################################################
	
	#ifndef __Afx_ISpeechVoiceStatus_INTERFACE_DEFINED__
		#define __Afx_ISpeechVoiceStatus_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechVoiceStatus_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_CurrentStreamNumber (BYVAL StreamNumber AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_LastStreamNumberQueued (BYVAL StreamNumber AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_LastHResult (BYVAL HResult AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_RunningState (BYVAL State AS SpeechRunState PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_InputWordPosition (BYVAL Position AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_InputWordLength (BYVAL Length AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_InputSentencePosition (BYVAL Position AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_InputSentenceLength (BYVAL Length AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_LastBookmark (BYVAL Bookmark AS AFX_BSTR PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_LastBookmarkId (BYVAL BookmarkId AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_PhonemeId (BYVAL PhoneId AS SHORT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_VisemeId (BYVAL VisemeId AS SHORT PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechWaveFormatEx
	' IID: {7A1EF0D5-1581-4741-88E4-209A49F11A10}
	' Documentation string: Afx_ISpeechWaveFormatEx Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 14
	' ########################################################################################
	
	#ifndef __Afx_ISpeechWaveFormatEx_INTERFACE_DEFINED__
		#define __Afx_ISpeechWaveFormatEx_INTERFACE_DEFINED__
		
		TYPE Afx_ISpeechWaveFormatEx_ EXTENDS Afx_IDispatch
			DECLARE ABSTRACT FUNCTION get_FormatTag (BYVAL FormatTag AS SHORT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_FormatTag (BYVAL FormatTag AS SHORT) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_Channels (BYVAL Channels AS SHORT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_Channels (BYVAL Channels AS SHORT) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_SamplesPerSec (BYVAL SamplesPerSec AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_SamplesPerSec (BYVAL SamplesPerSec AS LONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_AvgBytesPerSec (BYVAL AvgBytesPerSec AS LONG PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_AvgBytesPerSec (BYVAL AvgBytesPerSec AS LONG) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_BlockAlign (BYVAL BlockAlign AS SHORT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_BlockAlign (BYVAL BlockAlign AS SHORT) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_BitsPerSample (BYVAL BitsPerSample AS SHORT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_BitsPerSample (BYVAL BitsPerSample AS SHORT) AS HRESULT
			DECLARE ABSTRACT FUNCTION get_ExtraData (BYVAL ExtraData AS VARIANT PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION put_ExtraData (BYVAL ExtraData AS VARIANT) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpeechXMLRecoResult
	' IID: {AAEC54AF-8F85-4924-944D-B79D39D72E19}
	' Documentation string: Afx_ISpeechXMLRecoResult Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = Afx_ISpeechRecoResult
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __Afx_ISpeechXMLRecoResult_INTERFACE_DEFINED__
		#define __Afx_ISpeechXMLRecoResult_INTERFACE_DEFINED__
		
		Type Afx_ISpeechXMLRecoResult_ Extends Afx_ISpeechRecoResult
			Declare Abstract Function GetXMLResult (ByVal Options As SPXMLRESULTOPTIONS, ByVal pResult As AFX_BSTR Ptr) As HRESULT
			Declare Abstract Function GetXMLErrorInfo (ByVal LineNumber As Long Ptr, ByVal ScriptLine As AFX_BSTR Ptr, ByVal Source As AFX_BSTR Ptr, ByVal Description As AFX_BSTR Ptr, ByVal ResultCode As Long Ptr, ByVal IsError As VARIANT_BOOL Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpContainerLexicon
	' IID = {8565572F-C094-41CC-B56E-10BD9C3FF044}
	' Inherited interface = Afx_ISpLexicon
	' Number of methods = 1
	' ########################################################################################
	
	#ifndef __Afx_ISpContainerLexicon_INTERFACE_DEFINED__
		#define __Afx_ISpContainerLexicon_INTERFACE_DEFINED__
		
		Type Afx_ISpContainerLexicon_ Extends Afx_ISpLexicon
			Declare Abstract Function AddLexicon (ByVal pAddLexicon As Afx_ISpLexicon Ptr, ByVal dwFlags As DWORD) As HRESULT
		End Type
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name: Afx_ISpEnginePronunciation
	' IID = C360CE4B-76D1-4214-AD68-52657D5083DA
	' Inherited interface = IUnknown
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __Afx_ISpEnginePronunciation_INTERFACE_DEFINED__
		#define __Afx_ISpEnginePronunciation_INTERFACE_DEFINED__
		
		TYPE Afx_ISpEnginePronunciation_ EXTENDS Afx_IUnknown
			DECLARE ABSTRACT FUNCTION Normalize (BYVAL pszWord AS LPCWSTR, BYVAL pszLeftContext AS LPCWSTR, BYVAL LangID AS WORD, BYVAL pNormalizationList AS SPNORMALIZATIONLIST PTR) AS HRESULT
			DECLARE ABSTRACT FUNCTION GetPronunciations (BYVAL pszWord AS LPCWSTR, BYVAL pszLeftContext AS LPCWSTR, BYVAL LangID AS WORD, BYVAL pEnginePronunciationList AS SPWORDPRONUNCIATIONLIST PTR) AS HRESULT
		END TYPE
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name = Afx_ISpEventSource2
	' IID = 2373A435-6A4B-429E-A6AC-D4231A61975B
	' Inherited interface = Afx_ISpEventSource
	' Number of methods = 1
	' ########################################################################################
	
	#ifndef __Afx_ISpEventSource2_INTERFACE_DEFINED__
		#define __Afx_ISpEventSource2_INTERFACE_DEFINED__
		
		TYPE Afx_ISpEventSource2_ EXTENDS Afx_ISpEventSource
			DECLARE ABSTRACT FUNCTION GetEventsEx (BYVAL ulCount AS ULONG, BYVAL pEventArray AS SPEVENTEX PTR, BYVAL pulFetched AS ULONG PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name = Afx_ISpGrammarBuilder2
	' IID = 8AB10026-20CC-4B20-8C22-A49C9BA78F60
	' Inherited interface = IUnknown
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __Afx_ISpGrammarBuilder2_INTERFACE_DEFINED__
		#define __Afx_ISpGrammarBuilder2_INTERFACE_DEFINED__
		
		TYPE Afx_ISpGrammarBuilder2_ EXTENDS Afx_IUnknown
			DECLARE ABSTRACT FUNCTION AddTextSubset (BYVAL hFromState AS SPSTATEHANDLE, BYVAL hToState AS SPSTATEHANDLE, BYVAL psz AS LPCWSTR, BYVAL eMatchMode AS SPMATCHINGMODE) AS HRESULT
			DECLARE ABSTRACT FUNCTION SetPhoneticAlphabet (BYVAL phoneticALphabet AS PHONETICALPHABET) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name = Afx_ISpObjectTokenInit
	' IID = {B8AAB0CF-346F-49D8-9499-C8B03F161D51}
	' Attributes = 512 [&H200] [Restricted]
	' Inherited interface = Afx_ISpObjectToken
	' Number of methods = 1
	' ########################################################################################
	
	#ifndef __Afx_ISpObjectTokenInit_INTERFACE_DEFINED__
		#define __Afx_ISpObjectTokenInit_INTERFACE_DEFINED__
		
		TYPE Afx_ISpObjectTokenInit_ EXTENDS Afx_ISpObjectToken
			DECLARE ABSTRACT FUNCTION InitFromDataKey (BYVAL pszCategoryId AS LPCWSTR, BYVAL pszTokenId AS LPCWSTR, BYVAL pDataKey AS Afx_ISpDataKey PTR) AS HRESULT
		END TYPE
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name = Afx_ISpPhrase2
	' IID = F264DA52-E457-4696-B856-A737B717AF79
	' Inherited interface = Afx_ISpPhrase
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __Afx_ISpPhrase2_INTERFACE_DEFINED__
		#define __Afx_ISpPhrase2_INTERFACE_DEFINED__
		
		Type Afx_ISpPhrase2_ Extends Afx_ISpPhrase
			Declare Abstract Function GetXMLResult (ByVal ppszCoMemXMLResult As LPWSTR Ptr, ByVal Options As SPXMLRESULTOPTIONS) As HRESULT
			Declare Abstract Function GetXMLErrorInfo (ByVal pSemanticErrorInfo As SPSEMANTICERRORINFO Ptr) As HRESULT
			Declare Abstract Function GetAudio (ByVal ulStartElement As ULong, ByVal cElements As ULong, ByVal ppStream As Afx_ISpStreamFormat Ptr Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name = Afx_ISpRecoResult2
	' IID = 27CAC6C4-88F2-41F2-8817-0C95E59F1E6E
	' Inherited interface = Afx_ISpRecoResult
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __Afx_ISpRecoResult2_INTERFACE_DEFINED__
		#define __Afx_ISpRecoResult2_INTERFACE_DEFINED__
		
		Type Afx_ISpRecoResult2_ Extends Afx_ISpRecoResult
			Declare Abstract Function CommitAlternate (ByVal pPhraseAlt As Afx_ISpPhraseAlt Ptr, ByVal ppNewResult As Afx_ISpRecoResult Ptr Ptr) As HRESULT
			Declare Abstract Function CommitText (ByVal ulStartElement As ULong, ByVal cElements As ULong, ByVal pszCorrectedData As LPCWSTR, ByVal eCommitFlags As DWORD) As HRESULT
			Declare Abstract Function SetTextFeedback (ByVal pszFeedback As LPCWSTR, ByVal fSuccessful As WINBOOL) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name = Afx_ISpRegDataKey
	' IID = {92A66E2B-C830-4149-83DF-6FC2BA1E7A5B}
	' Attributes = 512 [&H200] [Restricted]
	' Inherited interface = Afx_ISpDataKey
	' Number of methods = 1
	' ########################################################################################
	
	#ifndef __Afx_ISpRegDataKey_INTERFACE_DEFINED__
		#define __Afx_ISpRegDataKey_INTERFACE_DEFINED__
		
		Type Afx_ISpRegDataKey_ Extends Afx_ISpDataKey
			Declare Abstract Function SetKey (ByVal hkey As HKEY, ByVal fReadOnly As WINBOOL) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	
	' ########################################################################################
	' Interface name = ISpTranscript
	' IID = {CE17C09B-4EFA-44D5-A4C9-59D9585AB0CD}
	' Inherited interface = IUnknown
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __Afx_ISpTranscript_INTERFACE_DEFINED__
		#define __Afx_ISpTranscript_INTERFACE_DEFINED__
		
		Type Afx_ISpTranscript_ Extends Afx_IUnknown
			Declare Abstract Function GetTranscript (ByVal ppszTranscript As LPWSTR Ptr) As HRESULT
			Declare Abstract Function AppendTranscript (ByVal pszTranscript As LPCWSTR) As HRESULT
		End Type
		
	#endif
	
End Namespace
