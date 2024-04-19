'Speech.bi
' Copyright (c) 2024 CM.Wang. Freeware. Use at your own risk.
' Copyright (c) 2017 José Roca. Freeware. Use at your own risk.

' https://learn.microsoft.com/en-us/previous-versions/windows/desktop/ee125663(v=vs.85)

#pragma once

Namespace Speech
	
	#include once "win/ole2.bi"
	#include once "win/unknwnbase.bi"
	#include once "win/ocidl.bi"
	
	#ifndef ___IUnknown_INTERFACE_DEFINED__
		#define ___IUnknown_INTERFACE_DEFINED__
		Type Afx_IUnknown As Afx_IUnknown_
		Type Afx_IUnknown_ Extends Object
			Declare Abstract Function QueryInterface (ByVal riid As REFIID, ByVal ppvObject As LPVOID Ptr) As HRESULT
			Declare Abstract Function AddRef () As ULong
			Declare Abstract Function Release () As ULong
		End Type
		Type Afx_LpIUnknown As Afx_IUnknown Ptr
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
		Type Afx_LpIDispatch As Afx_IDispatch Ptr
	#endif
	
	Const LIBID_SpeechLib = "{C866CA3A-32F7-11D2-9602-00C04F8EE628}"
	
	' ========================================================================================
	' ProgIDs (Program identifiers)
	' ========================================================================================
	
	' CLSID = {9EF96870-E160-4792-820D-48CF0649E4EC}
	Const PROGID_SAPI_SpAudioFormat_1 = "SAPI.SpAudioFormat.1"
	' CLSID = {90903716-2F42-11D3-9C26-00C04F8EF87C}
	Const PROGID_SAPI_SpCompressedLexicon_1 = "SAPI.SpCompressedLexicon.1"
	' CLSID = {8DBEF13F-1948-4AA8-8CF0-048EEBED95D8}
	Const PROGID_SAPI_SpCustomStream_1 = "SAPI.SpCustomStream.1"
	' CLSID = {947812B3-2AE1-4644-BA86-9E90DED7EC91}
	Const PROGID_SAPI_SpFileStream_1 = "SAPI.SpFileStream.1"
	' CLSID = {73AD6842-ACE0-45E8-A4DD-8795881A2C2A}
	Const PROGID_SAPI_SpInProcRecoContext_1 = "SAPI.SpInProcRecoContext.1"
	' CLSID = {41B89B6B-9399-11D2-9623-00C04F8EE628}
	Const PROGID_SAPI_SpInprocRecognizer_1 = "SAPI.SpInprocRecognizer.1"
	' CLSID = {0655E396-25D0-11D3-9C26-00C04F8EF87C}
	Const PROGID_SAPI_SpLexicon_1 = "SAPI.SpLexicon.1"
	' CLSID = {5FB7EF7D-DFF4-468A-B6B7-2FCBD188F994}
	Const PROGID_SAPI_SpMemoryStream_1 = "SAPI.SpMemoryStream.1"
	' CLSID = {AB1890A0-E91F-11D2-BB91-00C04F8EE6C0}
	Const PROGID_SAPI_SpMMAudioEnum_1 = "SAPI.SpMMAudioEnum.1"
	' CLSID = {CF3D2E50-53F2-11D2-960C-00C04F8EE628}
	Const PROGID_SAPI_SpMMAudioIn_1 = "SAPI.SpMMAudioIn.1"
	' CLSID = {A8C680EB-3D32-11D2-9EE7-00C04F797396}
	Const PROGID_SAPI_SpMMAudioOut_1 = "SAPI.SpMMAudioOut.1"
	' CLSID = {E2AE5372-5D40-11D2-960E-00C04F8EE628}
	Const PROGID_SAPI_SpNotifyTranslator_1 = "SAPI.SpNotifyTranslator.1"
	' CLSID = {455F24E9-7396-4A16-9715-7C0FDBE3EFE3}
	Const PROGID_SAPI_SpNullPhoneConverter_1 = "SAPI.SpNullPhoneConverter.1"
	' CLSID = {EF411752-3736-4CB4-9C8C-8EF4CCB58EFE}
	Const PROGID_SAPI_SpObjectToken_1 = "SAPI.SpObjectToken.1"
	' CLSID = {A910187F-0C7A-45AC-92CC-59EDAFB77B53}
	Const PROGID_SAPI_SpObjectTokenCategory_1 = "SAPI.SpObjectTokenCategory.1"
	' CLSID = {9185F743-1143-4C28-86B5-BFF14F20E5C8}
	Const PROGID_SAPI_SpPhoneConverter_1 = "SAPI.SpPhoneConverter.1"
	' CLSID = {C23FC28D-C55F-4720-8B32-91F73C2BD5D1}
	Const PROGID_SAPI_SpPhraseInfoBuilder_1 = "SAPI.SpPhraseInfoBuilder.1"
	' CLSID = {96749373-3391-11D2-9EE3-00C04F797396}
	Const PROGID_SAPI_SpResourceManager_1 = "SAPI.SpResourceManager.1"
	' CLSID = {47206204-5ECA-11D2-960F-00C04F8EE628}
	Const PROGID_SAPI_SpSharedRecoContext_1 = "SAPI.SpSharedRecoContext.1"
	' CLSID = {3BEE4890-4FE9-4A37-8C1E-5E7E12791C1F}
	Const PROGID_SAPI_SpSharedRecognizer_1 = "SAPI.SpSharedRecognizer.1"
	' CLSID = {0D722F1A-9FCF-4E62-96D8-6DF8F01A26AA}
	Const PROGID_SAPI_SpShortcut_1 = "SAPI.SpShortcut.1"
	' CLSID = {715D9C59-4442-11D2-9605-00C04F8EE628}
	Const PROGID_SAPI_SpStream_1 = "SAPI.SpStream.1"
	' CLSID = {7013943A-E2EC-11D2-A086-00C04F8EF9B5}
	Const PROGID_SAPI_SpStreamFormatConverter_1 = "SAPI.SpStreamFormatConverter.1"
	' CLSID = {0F92030A-CBFD-4AB8-A164-FF5985547FF6}
	Const PROGID_SAPI_SpTextSelectionInformation_1 = "SAPI.SpTextSelectionInformation.1"
	' CLSID = {C9E37C15-DF92-4727-85D6-72E5EEB6995A}
	Const PROGID_SAPI_SpUncompressedLexicon_1 = "SAPI.SpUncompressedLexicon.1"
	' CLSID = {96749377-3391-11D2-9EE3-00C04F797396}
	Const PROGID_SAPI_SpVoice_1 = "SAPI.SpVoice.1"
	' CLSID = {C79A574C-63BE-44B9-801F-283F87F898BE}
	Const PROGID_SAPI_SpWaveFormatEx_1 = "SAPI.SpWaveFormatEx.1"
	
	' ========================================================================================
	' Version Independent ProgIDs
	' ========================================================================================
	
	' CLSID = {9EF96870-E160-4792-820D-48CF0649E4EC}
	Const PROGID_SAPI_SpAudioFormat = "SAPI.SpAudioFormat"
	' CLSID = {90903716-2F42-11D3-9C26-00C04F8EF87C}
	Const PROGID_SAPI_SpCompressedLexicon = "SAPI.SpCompressedLexicon"
	' CLSID = {8DBEF13F-1948-4AA8-8CF0-048EEBED95D8}
	Const PROGID_SAPI_SpCustomStream = "SAPI.SpCustomStream"
	' CLSID = {947812B3-2AE1-4644-BA86-9E90DED7EC91}
	Const PROGID_SAPI_SpFileStream = "SAPI.SpFileStream"
	' CLSID = {73AD6842-ACE0-45E8-A4DD-8795881A2C2A}
	Const PROGID_SAPI_SpInProcRecoContext = "SAPI.SpInProcRecoContext"
	' CLSID = {41B89B6B-9399-11D2-9623-00C04F8EE628}
	Const PROGID_SAPI_SpInprocRecognizer = "SAPI.SpInprocRecognizer"
	' CLSID = {0655E396-25D0-11D3-9C26-00C04F8EF87C}
	Const PROGID_SAPI_SpLexicon = "SAPI.SpLexicon"
	' CLSID = {5FB7EF7D-DFF4-468A-B6B7-2FCBD188F994}
	Const PROGID_SAPI_SpMemoryStream = "SAPI.SpMemoryStream"
	' CLSID = {AB1890A0-E91F-11D2-BB91-00C04F8EE6C0}
	Const PROGID_SAPI_SpMMAudioEnum = "SAPI.SpMMAudioEnum"
	' CLSID = {CF3D2E50-53F2-11D2-960C-00C04F8EE628}
	Const PROGID_SAPI_SpMMAudioIn = "SAPI.SpMMAudioIn"
	' CLSID = {A8C680EB-3D32-11D2-9EE7-00C04F797396}
	Const PROGID_SAPI_SpMMAudioOut = "SAPI.SpMMAudioOut"
	' CLSID = {E2AE5372-5D40-11D2-960E-00C04F8EE628}
	Const PROGID_SAPI_SpNotifyTranslator = "SAPI.SpNotifyTranslator"
	' CLSID = {455F24E9-7396-4A16-9715-7C0FDBE3EFE3}
	Const PROGID_SAPI_SpNullPhoneConverter = "SAPI.SpNullPhoneConverter"
	' CLSID = {EF411752-3736-4CB4-9C8C-8EF4CCB58EFE}
	Const PROGID_SAPI_SpObjectToken = "SAPI.SpObjectToken"
	' CLSID = {A910187F-0C7A-45AC-92CC-59EDAFB77B53}
	Const PROGID_SAPI_SpObjectTokenCategory = "SAPI.SpObjectTokenCategory"
	' CLSID = {9185F743-1143-4C28-86B5-BFF14F20E5C8}
	Const PROGID_SAPI_SpPhoneConverter = "SAPI.SpPhoneConverter"
	' CLSID = {C23FC28D-C55F-4720-8B32-91F73C2BD5D1}
	Const PROGID_SAPI_SpPhraseInfoBuilder = "SAPI.SpPhraseInfoBuilder"
	' CLSID = {96749373-3391-11D2-9EE3-00C04F797396}
	Const PROGID_SAPI_SpResourceManager = "SAPI.SpResourceManager"
	' CLSID = {47206204-5ECA-11D2-960F-00C04F8EE628}
	Const PROGID_SAPI_SpSharedRecoContext = "SAPI.SpSharedRecoContext"
	' CLSID = {3BEE4890-4FE9-4A37-8C1E-5E7E12791C1F}
	Const PROGID_SAPI_SpSharedRecognizer = "SAPI.SpSharedRecognizer"
	' CLSID = {0D722F1A-9FCF-4E62-96D8-6DF8F01A26AA}
	Const PROGID_SAPI_SpShortcut = "SAPI.SpShortcut"
	' CLSID = {715D9C59-4442-11D2-9605-00C04F8EE628}
	Const PROGID_SAPI_SpStream = "SAPI.SpStream"
	' CLSID = {7013943A-E2EC-11D2-A086-00C04F8EF9B5}
	Const PROGID_SAPI_SpStreamFormatConverter = "SAPI.SpStreamFormatConverter"
	' CLSID = {0F92030A-CBFD-4AB8-A164-FF5985547FF6}
	Const PROGID_SAPI_SpTextSelectionInformation = "SAPI.SpTextSelectionInformation"
	' CLSID = {C9E37C15-DF92-4727-85D6-72E5EEB6995A}
	Const PROGID_SAPI_SpUncompressedLexicon = "SAPI.SpUncompressedLexicon"
	' CLSID = {96749377-3391-11D2-9EE3-00C04F797396}
	Const PROGID_SAPI_SpVoice = "SAPI.SpVoice"
	' CLSID = {C79A574C-63BE-44B9-801F-283F87F898BE}
	Const PROGID_SAPI_SpWaveFormatEx = "SAPI.SpWaveFormatEx"
	
	' ========================================================================================
	' ClsIDs (Class identifiers)
	' ========================================================================================
	
	Const CLSID_SpAudioFormat = "{9EF96870-E160-4792-820D-48CF0649E4EC}"
	Const CLSID_SpCompressedLexicon = "{90903716-2F42-11D3-9C26-00C04F8EF87C}"
	Const CLSID_SpCustomStream = "{8DBEF13F-1948-4AA8-8CF0-048EEBED95D8}"
	Const CLSID_SpFileStream = "{947812B3-2AE1-4644-BA86-9E90DED7EC91}"
	Const CLSID_SpInProcRecoContext = "{73AD6842-ACE0-45E8-A4DD-8795881A2C2A}"
	Const CLSID_SpInprocRecognizer = "{41B89B6B-9399-11D2-9623-00C04F8EE628}"
	Const CLSID_SpLexicon = "{0655E396-25D0-11D3-9C26-00C04F8EF87C}"
	Const CLSID_SpMemoryStream = "{5FB7EF7D-DFF4-468A-B6B7-2FCBD188F994}"
	Const CLSID_SpMMAudioEnum = "{AB1890A0-E91F-11D2-BB91-00C04F8EE6C0}"
	Const CLSID_SpMMAudioIn = "{CF3D2E50-53F2-11D2-960C-00C04F8EE628}"
	Const CLSID_SpMMAudioOut = "{A8C680EB-3D32-11D2-9EE7-00C04F797396}"
	Const CLSID_SpNotifyTranslator = "{E2AE5372-5D40-11D2-960E-00C04F8EE628}"
	Const CLSID_SpNullPhoneConverter = "{455F24E9-7396-4A16-9715-7C0FDBE3EFE3}"
	Const CLSID_SpObjectToken = "{EF411752-3736-4CB4-9C8C-8EF4CCB58EFE}"
	Const CLSID_SpObjectTokenCategory = "{A910187F-0C7A-45AC-92CC-59EDAFB77B53}"
	Const CLSID_SpPhoneConverter = "{9185F743-1143-4C28-86B5-BFF14F20E5C8}"
	Const CLSID_SpPhoneticAlphabetConverter = "{4F414126-DFE3-4629-99EE-797978317EAD}"
	Const CLSID_SpPhraseInfoBuilder = "{C23FC28D-C55F-4720-8B32-91F73C2BD5D1}"
	Const CLSID_SpResourceManager = "{96749373-3391-11D2-9EE3-00C04F797396}"
	Const CLSID_SpSharedRecoContext = "{47206204-5ECA-11D2-960F-00C04F8EE628}"
	Const CLSID_SpSharedRecognizer = "{3BEE4890-4FE9-4A37-8C1E-5E7E12791C1F}"
	Const CLSID_SpShortcut = "{0D722F1A-9FCF-4E62-96D8-6DF8F01A26AA}"
	Const CLSID_SpStream = "{715D9C59-4442-11D2-9605-00C04F8EE628}"
	Const CLSID_SpStreamFormatConverter = "{7013943A-E2EC-11D2-A086-00C04F8EF9B5}"
	Const CLSID_SpTextSelectionInformation = "{0F92030A-CBFD-4AB8-A164-FF5985547FF6}"
	Const CLSID_SpUnCompressedLexicon = "{C9E37C15-DF92-4727-85D6-72E5EEB6995A}"
	Const CLSID_SpVoice = "{96749377-3391-11D2-9EE3-00C04F797396}"
	Const CLSID_SpWaveFormatEx = "{C79A574C-63BE-44B9-801F-283F87F898BE}"
	
	' ========================================================================================
	' IIDs (Interface identifiers)
	' ========================================================================================
	
	Const IID_IEnumSpObjectTokens = "{06B64F9E-7FDA-11D2-B4F2-00C04F797396}"
	Const IID_ISpAudio = "{C05C768F-FAE8-4EC2-8E07-338321C12452}"
	Const IID_ISpDataKey = "{14056581-E16C-11D2-BB90-00C04F8EE6C0}"
	Const IID_ISpeechAudio = "{CFF8E175-019E-11D3-A08E-00C04F8EF9B5}"
	Const IID_ISpeechAudioBufferInfo = "{11B103D8-1142-4EDF-A093-82FB3915F8CC}"
	Const IID_ISpeechAudioFormat = "{E6E9C590-3E18-40E3-8299-061F98BDE7C7}"
	Const IID_ISpeechAudioStatus = "{C62D9C91-7458-47F6-862D-1EF86FB0B278}"
	Const IID_ISpeechBaseStream = "{6450336F-7D49-4CED-8097-49D6DEE37294}"
	Const IID_ISpeechCustomStream = "{1A9E9F4F-104F-4DB8-A115-EFD7FD0C97AE}"
	Const IID_ISpeechDataKey = "{CE17C09B-4EFA-44D5-A4C9-59D9585AB0CD}"
	Const IID_ISpeechFileStream = "{AF67F125-AB39-4E93-B4A2-CC2E66E182A7}"
	Const IID_ISpeechGrammarRule = "{AFE719CF-5DD1-44F2-999C-7A399F1CFCCC}"
	Const IID_ISpeechGrammarRules = "{6FFA3B44-FC2D-40D1-8AFC-32911C7F1AD1}"
	Const IID_ISpeechGrammarRuleState = "{D4286F2C-EE67-45AE-B928-28D695362EDA}"
	Const IID_ISpeechGrammarRuleStateTransition = "{CAFD1DB1-41D1-4A06-9863-E2E81DA17A9A}"
	Const IID_ISpeechGrammarRuleStateTransitions = "{EABCE657-75BC-44A2-AA7F-C56476742963}"
	Const IID_ISpeechLexicon = "{3DA7627A-C7AE-4B23-8708-638C50362C25}"
	Const IID_ISpeechLexiconPronunciation = "{95252C5D-9E43-4F4A-9899-48EE73352F9F}"
	Const IID_ISpeechLexiconPronunciations = "{72829128-5682-4704-A0D4-3E2BB6F2EAD3}"
	Const IID_ISpeechLexiconWord = "{4E5B933C-C9BE-48ED-8842-1EE51BB1D4FF}"
	Const IID_ISpeechLexiconWords = "{8D199862-415E-47D5-AC4F-FAA608B424E6}"
	Const IID_ISpeechMemoryStream = "{EEB14B68-808B-4ABE-A5EA-B51DA7588008}"
	Const IID_ISpeechMMSysAudio = "{3C76AF6D-1FD7-4831-81D1-3B71D5A13C44}"
	Const IID_ISpeechObjectToken = "{C74A3ADC-B727-4500-A84A-B526721C8B8C}"
	Const IID_ISpeechObjectTokenCategory = "{CA7EAC50-2D01-4145-86D4-5AE7D70F4469}"
	Const IID_ISpeechObjectTokens = "{9285B776-2E7B-4BC0-B53E-580EB6FA967F}"
	Const IID_ISpeechPhoneConverter = "{C3E4F353-433F-43D6-89A1-6A62A7054C3D}"
	Const IID_ISpeechPhraseAlternate = "{27864A2A-2B9F-4CB8-92D3-0D2722FD1E73}"
	Const IID_ISpeechPhraseAlternates = "{B238B6D5-F276-4C3D-A6C1-2974801C3CC2}"
	Const IID_ISpeechPhraseElement = "{E6176F96-E373-4801-B223-3B62C068C0B4}"
	Const IID_ISpeechPhraseElements = "{0626B328-3478-467D-A0B3-D0853B93DDA3}"
	Const IID_ISpeechPhraseInfo = "{961559CF-4E67-4662-8BF0-D93F1FCD61B3}"
	Const IID_ISpeechPhraseInfoBuilder = "{3B151836-DF3A-4E0A-846C-D2ADC9334333}"
	Const IID_ISpeechPhraseProperties = "{08166B47-102E-4B23-A599-BDB98DBFD1F4}"
	Const IID_ISpeechPhraseProperty = "{CE563D48-961E-4732-A2E1-378A42B430BE}"
	Const IID_ISpeechPhraseReplacement = "{2890A410-53A7-4FB5-94EC-06D4998E3D02}"
	Const IID_ISpeechPhraseReplacements = "{38BC662F-2257-4525-959E-2069D2596C05}"
	Const IID_ISpeechPhraseRule = "{A7BFE112-A4A0-48D9-B602-C313843F6964}"
	Const IID_ISpeechPhraseRules = "{9047D593-01DD-4B72-81A3-E4A0CA69F407}"
	Const IID_ISpeechRecoContext = "{580AA49D-7E1E-4809-B8E2-57DA806104B8}"
	Const IID_ISpeechRecognizer = "{2D5F1C0C-BD75-4B08-9478-3B11FEA2586C}"
	Const IID_ISpeechRecognizerStatus = "{BFF9E781-53EC-484E-BB8A-0E1B5551E35C}"
	Const IID_ISpeechRecoGrammar = "{B6D6F79F-2158-4E50-B5BC-9A9CCD852A09}"
	Const IID_ISpeechRecoResult = "{ED2879CF-CED9-4EE6-A534-DE0191D5468D}"
	Const IID_ISpeechRecoResult2 = "{8E0A246D-D3C8-45DE-8657-04290C458C3C}"
	Const IID_ISpeechRecoResultDispatch = "{6D60EB64-ACED-40A6-BBF3-4E557F71DEE2}"
	Const IID_ISpeechRecoResultTimes = "{62B3B8FB-F6E7-41BE-BDCB-056B1C29EFC0}"
	Const IID_ISpeechResourceLoader = "{B9AC5783-FCD0-4B21-B119-B4F8DA8FD2C3}"
	Const IID_ISpeechTextSelectionInformation = "{3B9C7E7A-6EEE-4DED-9092-11657279ADBE}"
	Const IID_ISpeechVoice = "{269316D8-57BD-11D2-9EEE-00C04F797396}"
	Const IID_ISpeechVoiceStatus = "{8BE47B07-57F6-11D2-9EEE-00C04F797396}"
	Const IID_ISpeechWaveFormatEx = "{7A1EF0D5-1581-4741-88E4-209A49F11A10}"
	Const IID_ISpeechXMLRecoResult = "{AAEC54AF-8F85-4924-944D-B79D39D72E19}"
	Const IID_ISpEventSink = "{BE7A9CC9-5F9E-11D2-960F-00C04F8EE628}"
	Const IID_ISpEventSource = "{BE7A9CCE-5F9E-11D2-960F-00C04F8EE628}"
	Const IID_ISpGrammarBuilder = "{8137828F-591A-4A42-BE58-49EA7EBAAC68}"
	Const IID_ISpLexicon = "{DA41A7C2-5383-4DB2-916B-6C1719E3DB58}"
	Const IID_ISpMMSysAudio = "{15806F6E-1D70-4B48-98E6-3B1A007509AB}"
	Const IID_ISpNotifySink = "{259684DC-37C3-11D2-9603-00C04F8EE628}"
	Const IID_ISpNotifySource = "{5EFF4AEF-8487-11D2-961C-00C04F8EE628}"
	Const IID_ISpNotifyTranslator = "{ACA16614-5D3D-11D2-960E-00C04F8EE628}"
	Const IID_ISpObjectToken = "{14056589-E16C-11D2-BB90-00C04F8EE6C0}"
	Const IID_ISpObjectTokenCategory = "{2D3D3845-39AF-4850-BBF9-40B49780011D}"
	Const IID_ISpObjectWithToken = "{5B559F40-E952-11D2-BB91-00C04F8EE6C0}"
	Const IID_ISpPhoneConverter = "{8445C581-0CAC-4A38-ABFE-9B2CE2826455}"
	Const IID_ISpPhoneticAlphabetConverter = "{133ADCD4-19B4-4020-9FDC-842E78253B17}"
	Const IID_ISpPhoneticAlphabetSelection = "{B2745EFD-42CE-48CA-81F1-A96E02538A90}"
	Const IID_ISpPhrase = "{1A5C0354-B621-4B5A-8791-D306ED379E53}"
	Const IID_ISpPhraseAlt = "{8FCEBC98-4E49-4067-9C6C-D86A0E092E3D}"
	Const IID_ISpProperties = "{5B4FB971-B115-4DE1-AD97-E482E3BF6EE4}"
	Const IID_ISpRecoCategory = "{DA0CD0F9-14A2-4F09-8C2A-85CC48979345}"
	Const IID_ISpRecoContext = "{F740A62F-7C15-489E-8234-940A33D9272D}"
	Const IID_ISpRecoContext2 = "{BEAD311C-52FF-437F-9464-6B21054CA73D}"
	Const IID_ISpRecognizer = "{C2B5F241-DAA0-4507-9E16-5A1EAA2B7A5C}"
	Const IID_ISpRecognizer2 = "{8FC6D974-C81E-4098-93C5-0147F61ED4D3}"
	Const IID_ISpRecognizer3 = "{DF1B943C-5838-4AA2-8706-D7CD5B333499}"
	Const IID_ISpRecoGrammar = "{2177DB29-7F45-47D0-8554-067E91C80502}"
	Const IID_ISpRecoGrammar2 = "{4B37BC9E-9ED6-44A3-93D3-18F022B79EC3}"
	Const IID_ISpRecoResult = "{20B053BE-E235-43CD-9A2A-8D17A48B7842}"
	Const IID_ISpResourceManager = "{93384E18-5014-43D5-ADBB-A78E055926BD}"
	Const IID_ISpSerializeState = "{21B501A0-0EC7-46C9-92C3-A2BC784C54B9}"
	Const IID_ISpShortcut = "{3DF681E2-EA56-11D9-8BDE-F66BAD1E3F3A}"
	Const IID_ISpStream = "{12E3CCA9-7518-44C5-A5E7-BA5A79CB929E}"
	Const IID_ISpStreamFormat = "{BED530BE-2606-4F4D-A1C0-54C5CDA5566F}"
	Const IID_ISpStreamFormatConverter = "{678A932C-EA71-4446-9B41-78FDA6280A29}"
	Const IID_ISpVoice = "{6C44DF74-72B9-4992-A1EC-EF996E0422D4}"
	Const IID_ISpXMLRecoResult = "{AE39362B-45A8-4074-9B9E-CCF49AA2D0B6}"
	Const IID__ISpeechRecoContextEvents = "{7B8FCB42-0E9D-4F00-A048-7B04D6179D3D}"
	Const IID__ISpeechVoiceEvents = "{A372ACD1-3BEF-4BBD-8FFB-CB3E2B416AF8}"
	
	' Additional interfaces not included in the Type library
	Const IID_ISpContainerLexicon = "{8565572F-C094-41CC-B56E-10BD9C3FF044}"
	Const IID_ISpEnginePronunciation = "{C360CE4B-76D1-4214-AD68-52657D5083DA}"
	Const IID_ISpEventSource2 = "{2373A435-6A4B-429E-A6AC-D4231A61975B}"
	Const IID_ISpGrammarBuilder2 = "{8AB10026-20CC-4B20-8C22-A49C9BA78F60}"
	Const IID_ISpObjectTokenInit = "{B8AAB0CF-346F-49D8-9499-C8B03F161D51}"
	Const IID_ISpPhrase2 = "{F264DA52-E457-4696-B856-A737B717AF79}"
	Const IID_ISpRecoResult2 = "{27CAC6C4-88F2-41F2-8817-0C95E59F1E6E}"
	Const IID_ISpRegDataKey = "{92A66E2B-C830-4149-83DF-6FC2BA1E7A5B}"
	Const IID_ISPtranscript = "{10F63BCE-201A-11D3-AC70-00C04F8EE6C0}"
	
	' ========================================================================================
	' Aliases
	' ========================================================================================
	
	Type SPAUDIOSTATE As _SPAUDIOSTATE
	Type SPPROPERTYINFO As tagSPPROPERTYINFO
	Type SPSTREAMFORMATType As SPWAVEFORMATType
	Type SPTEXTSELECTIONINFO As tagSPTEXTSELECTIONINFO
	
	' ========================================================================================
	' Enumerations
	' ========================================================================================
	
	Enum _SPAUDIOSTATE
		' Documentation string: ISpAudio Interface
		' Number of Constants: 4
		SPAS_CLOSED = 0   ' (&h00000000)
		SPAS_STOP = 1   ' (&h00000001)
		SPAS_PAUSE = 2   ' (&h00000002)
		SPAS_RUN = 3   ' (&h00000003)
	End Enum
	
	Enum DISPID_SpeechAudio
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 7
		DISPID_SAStatus = 200   ' (&h000000C8)
		DISPID_SABufferInfo = 201   ' (&h000000C9)
		DISPID_SADefaultFormat = 202   ' (&h000000CA)
		DISPID_SAVolume = 203   ' (&h000000CB)
		DISPID_SABufferNotifySize = 204   ' (&h000000CC)
		DISPID_SAEventHandle = 205   ' (&h000000CD)
		DISPID_SASetState = 206   ' (&h000000CE)
	End Enum
	
	Enum DISPID_SpeechAudioBufferInfo
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 3
		DISPID_SABIMinNotification = 1   ' (&h00000001)
		DISPID_SABIBufferSize = 2   ' (&h00000002)
		DISPID_SABIEventBias = 3   ' (&h00000003)
	End Enum
	
	Enum DISPID_SpeechAudioFormat
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 4
		DISPID_SAFType = 1   ' (&h00000001)
		DISPID_SAFGuid = 2   ' (&h00000002)
		DISPID_SAFGetWaveFormatEx = 3   ' (&h00000003)
		DISPID_SAFSetWaveFormatEx = 4   ' (&h00000004)
	End Enum
	
	Enum DISPID_SpeechAudioStatus
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 5
		DISPID_SASFreeBufferSpace = 1   ' (&h00000001)
		DISPID_SASNonBlockingIO = 2   ' (&h00000002)
		DISPID_SASState = 3   ' (&h00000003)
		DISPID_SASCurrentSeekPosition = 4   ' (&h00000004)
		DISPID_SASCurrentDevicePosition = 5   ' (&h00000005)
	End Enum
	
	Enum DISPID_SpeechBaseStream
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 4
		DISPID_SBSFormat = 1   ' (&h00000001)
		DISPID_SBSRead = 2   ' (&h00000002)
		DISPID_SBSWrite = 3   ' (&h00000003)
		DISPID_SBSSeek = 4   ' (&h00000004)
	End Enum
	
	Enum DISPID_SpeechCustomStream
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 1
		DISPID_SCSBaseStream = 100   ' (&h00000064)
	End Enum
	
	'Typedef Long SpeechLanguageId;
	
	Enum DISPID_SpeechDataKey
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 12
		DISPID_SDKSetBinaryValue = 1   ' (&h00000001)
		DISPID_SDKGetBinaryValue = 2   ' (&h00000002)
		DISPID_SDKSetStringValue = 3   ' (&h00000003)
		DISPID_SDKGetStringValue = 4   ' (&h00000004)
		DISPID_SDKSetLongValue = 5   ' (&h00000005)
		DISPID_SDKGetLongValue = 6   ' (&h00000006)
		DISPID_SDKOpenKey = 7   ' (&h00000007)
		DISPID_SDKCreateKey = 8   ' (&h00000008)
		DISPID_SDKDeleteKey = 9   ' (&h00000009)
		DISPID_SDKDeleteValue = 10   ' (&h0000000A)
		DISPID_SDKEnumKeys = 11   ' (&h0000000B)
		DISPID_SDKEnumValues = 12   ' (&h0000000C)
	End Enum
	
	Enum DISPID_SpeechFileStream
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 2
		DISPID_SFSOpen = 100   ' (&h00000064)
		DISPID_SFSClose = 101   ' (&h00000065)
	End Enum
	
	Enum DISPID_SpeechGrammarRule
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 7
		DISPID_SGRAttributes = 1   ' (&h00000001)
		DISPID_SGRInitialState = 2   ' (&h00000002)
		DISPID_SGRName = 3   ' (&h00000003)
		DISPID_SGRId = 4   ' (&h00000004)
		DISPID_SGRClear = 5   ' (&h00000005)
		DISPID_SGRAddResource = 6   ' (&h00000006)
		DISPID_SGRAddState = 7   ' (&h00000007)
	End Enum
	
	Enum DISPID_SpeechGrammarRules
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 8
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
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 5
		DISPID_SGRSRule = 1   ' (&h00000001)
		DISPID_SGRSTransitions = 2   ' (&h00000002)
		DISPID_SGRSAddWordTransition = 3   ' (&h00000003)
		DISPID_SGRSAddRuleTransition = 4   ' (&h00000004)
		DISPID_SGRSAddSpecialTransition = 5   ' (&h00000005)
	End Enum
	
	Enum DISPID_SpeechGrammarRuleStateTransition
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 8
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
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 3
		DISPID_SGRSTsCount = 1   ' (&h00000001)
		DISPID_SGRSTsItem = 0   ' (&h00000000)
		DISPID_SGRSTs_NewEnum = -4   ' (&hFFFFFFFC)
	End Enum
	
	Enum DISPID_SpeechLexicon
		' Documentation string: ISpeechPhraseInfoBuilder Interface
		' Number of Constants: 8
		DISPID_SLGenerationId = 1   ' (&h00000001)
		DISPID_SLGetWords = 2   ' (&h00000002)
		DISPID_SLAddPronunciation = 3   ' (&h00000003)
		DISPID_SLAddPronunciationByPhoneIds = 4   ' (&h00000004)
		DISPID_SLRemovePronunciation = 5   ' (&h00000005)
		DISPID_SLRemovePronunciationByPhoneIds = 6   ' (&h00000006)
		DISPID_SLGetPronunciations = 7   ' (&h00000007)
		DISPID_SLGetGenerationChange = 8   ' (&h00000008)
	End Enum
	
	Enum DISPID_SpeechLexiconProns
		' Documentation string: ISpeechPhraseInfoBuilder Interface
		' Number of Constants: 3
		DISPID_SLPsCount = 1   ' (&h00000001)
		DISPID_SLPsItem = 0   ' (&h00000000) DISPID_VALUE
		DISPID_SLPs_NewEnum = -4   ' (&hFFFFFFFC) DISPID_NEWENUM
	End Enum
	
	Enum DISPID_SpeechLexiconPronunciation
		' Documentation string: ISpeechPhraseInfoBuilder Interface
		' Number of Constants: 5
		DISPID_SLPType = 1   ' (&h00000001)
		DISPID_SLPLangId = 2   ' (&h00000002)
		DISPID_SLPPartOfSpeech = 3   ' (&h00000003)
		DISPID_SLPPhoneIds = 4   ' (&h00000004)
		DISPID_SLPSymbolic = 5   ' (&h00000005)
	End Enum
	
	Enum DISPID_SpeechLexiconWord
		' Documentation string: ISpeechPhraseInfoBuilder Interface
		' Number of Constants: 4
		DISPID_SLWLangId = 1   ' (&h00000001)
		DISPID_SLWType = 2   ' (&h00000002)
		DISPID_SLWWord = 3   ' (&h00000003)
		DISPID_SLWPronunciations = 4   ' (&h00000004)
	End Enum
	
	Enum DISPID_SpeechLexiconWords
		' Documentation string: ISpeechPhraseInfoBuilder Interface
		' Number of Constants: 3
		DISPID_SLWsCount = 1   ' (&h00000001)
		DISPID_SLWsItem = 0   ' (&h00000000) DISPID_VALUE
		DISPID_SLWs_NewEnum = -4   ' (&hFFFFFFFC) DISPID_NEWENUM
	End Enum
	
	Enum DISPID_SpeechMemoryStream
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 2
		DISPID_SMSSetData = 100   ' (&h00000064)
		DISPID_SMSGetData = 101   ' (&h00000065)
	End Enum
	
	Enum DISPID_SpeechMMSysAudio
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 3
		DISPID_SMSADeviceId = 300   ' (&h0000012C)
		DISPID_SMSALineId = 301   ' (&h0000012D)
		DISPID_SMSAMMHandle = 302   ' (&h0000012E)
	End Enum
	
	Enum DISPID_SpeechObjectToken
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 13
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
	
	Enum DISPID_SpeechObjectTokenCategory
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 5
		DISPID_SOTCId = 1   ' (&h00000001)
		DISPID_SOTCDefault = 2   ' (&h00000002)
		DISPID_SOTCSetId = 3   ' (&h00000003)
		DISPID_SOTCGetDataKey = 4   ' (&h00000004)
		DISPID_SOTCEnumerateTokens = 5   ' (&h00000005)
	End Enum
	
	Enum DISPID_SpeechObjectTokens
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 3
		DISPID_SOTsCount = 1   ' (&h00000001)
		DISPID_SOTsItem = 0   ' (&h00000000)
		DISPID_SOTs_NewEnum = -4   ' (&hFFFFFFFC)
	End Enum
	
	Enum DISPID_SpeechPhoneConverter
		' Documentation string: ISpeechPhraseInfoBuilder Interface
		' Number of Constants: 3
		DISPID_SPCLangId = 1   ' (&h00000001)
		DISPID_SPCPhoneToId = 2   ' (&h00000002)
		DISPID_SPCIdToPhone = 3   ' (&h00000003)
	End Enum
	
	Enum DISPID_SpeechPhraseAlternate
		' Documentation string: ISpeechPhraseInfoBuilder Interface
		' Number of Constants: 5
		DISPID_SPARecoResult = 1   ' (&h00000001)
		DISPID_SPAStartElementInResult = 2   ' (&h00000002)
		DISPID_SPANumberOfElementsInResult = 3   ' (&h00000003)
		DISPID_SPAPhraseInfo = 4   ' (&h00000004)
		DISPID_SPACommit = 5   ' (&h00000005)
	End Enum
	
	Enum DISPID_SpeechPhraseAlternates
		' Documentation string: ISpeechPhraseInfoBuilder Interface
		' Number of Constants: 3
		DISPID_SPAsCount = 1   ' (&h00000001)
		DISPID_SPAsItem = 0   ' (&h00000000)
		DISPID_SPAs_NewEnum = -4   ' (&hFFFFFFFC)
	End Enum
	
	Enum DISPID_SpeechPhraseBuilder
		' Documentation string: ISpeechRecoResultDispatch Interface
		' Number of Constants: 1
		DISPID_SPPBRestorePhraseFromMemory = 1   ' (&h00000001)
	End Enum
	
	Enum DISPID_SpeechPhraseElement
		' Documentation string: ISpeechPhraseInfoBuilder Interface
		' Number of Constants: 13
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
	End Enum
	
	Enum DISPID_SpeechPhraseElements
		' Documentation string: ISpeechPhraseInfoBuilder Interface
		' Number of Constants: 3
		DISPID_SPEsCount = 1   ' (&h00000001)
		DISPID_SPEsItem = 0   ' (&h00000000)
		DISPID_SPEs_NewEnum = -4   ' (&hFFFFFFFC)
	End Enum
	
	Enum DISPID_SpeechPhraseInfo
		' Documentation string: ISpeechPhraseInfoBuilder Interface
		' Number of Constants: 16
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
		' Documentation string: ISpeechPhraseInfoBuilder Interface
		' Number of Constants: 3
		DISPID_SPPsCount = 1   ' (&h00000001)
		DISPID_SPPsItem = 0   ' (&h00000000)
		DISPID_SPPs_NewEnum = -4   ' (&hFFFFFFFC)
	End Enum
	
	Enum DISPID_SpeechPhraseProperty
		' Documentation string: ISpeechPhraseInfoBuilder Interface
		' Number of Constants: 9
		DISPID_SPPName = 1   ' (&h00000001)
		DISPID_SPPId = 2   ' (&h00000002)
		DISPID_SPPValue = 3   ' (&h00000003)
		DISPID_SPPFirstElement = 4   ' (&h00000004)
		DISPID_SPPNumberOfElements = 5   ' (&h00000005)
		DISPID_SPPEngineConfidence = 6   ' (&h00000006)
		DISPID_SPPConfidence = 7   ' (&h00000007)
		DISPID_SPPParent = 8   ' (&h00000008)
		DISPID_SPPChildren = 9   ' (&h00000009)
	End Enum
	
	Enum DISPID_SpeechPhraseReplacement
		' Documentation string: ISpeechPhraseInfoBuilder Interface
		' Number of Constants: 4
		DISPID_SPRDisplayAttributes = 1   ' (&h00000001)
		DISPID_SPRText = 2   ' (&h00000002)
		DISPID_SPRFirstElement = 3   ' (&h00000003)
		DISPID_SPRNumberOfElements = 4   ' (&h00000004)
	End Enum
	
	Enum DISPID_SpeechPhraseReplacements
		' Documentation string: ISpeechPhraseInfoBuilder Interface
		' Number of Constants: 3
		DISPID_SPRsCount = 1   ' (&h00000001)
		DISPID_SPRsItem = 0   ' (&h00000000)
		DISPID_SPRs_NewEnum = -4   ' (&hFFFFFFFC)
	End Enum
	
	Enum DISPID_SpeechPhraseRule
		' Documentation string: ISpeechPhraseInfoBuilder Interface
		' Number of Constants: 8
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
		' Documentation string: ISpeechPhraseInfoBuilder Interface
		' Number of Constants: 3
		DISPID_SPRulesCount = 1   ' (&h00000001)
		DISPID_SPRulesItem = 0   ' (&h00000000)
		DISPID_SPRules_NewEnum = -4   ' (&hFFFFFFFC)
	End Enum
	
	Enum DISPID_SpeechRecoContext
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 17
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
	End Enum
	
	Enum DISPID_SpeechRecoContextEvents
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 18
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
	
	Enum DISPID_SpeechRecognizer
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 20
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
	End Enum
	
	Enum DISPID_SpeechRecognizerStatus
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 6
		DISPID_SRSAudioStatus = 1   ' (&h00000001)
		DISPID_SRSCurrentStreamPosition = 2   ' (&h00000002)
		DISPID_SRSCurrentStreamNumber = 3   ' (&h00000003)
		DISPID_SRSNumberOfActiveRules = 4   ' (&h00000004)
		DISPID_SRSClsidEngine = 5   ' (&h00000005)
		DISPID_SRSSupportedLanguages = 6   ' (&h00000006)
	End Enum
	
	Enum DISPID_SpeechRecoResult
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 9
		DISPID_SRRRecoContext = 1   ' (&h00000001)
		DISPID_SRRTimes = 2   ' (&h00000002)
		DISPID_SRRAudioFormat = 3   ' (&h00000003)
		DISPID_SRRPhraseInfo = 4   ' (&h00000004)
		DISPID_SRRAlternates = 5   ' (&h00000005)
		DISPID_SRRAudio = 6   ' (&h00000006)
		DISPID_SRRSpeakAudio = 7   ' (&h00000007)
		DISPID_SRRSaveToMemory = 8   ' (&h00000008)
		DISPID_SRRDiscardResultInfo = 9   ' (&h00000009)
	End Enum
	
	Enum DISPID_SpeechRecoResult2
		' Documentation string: ISpeechXMLRecoResult Interface
		' Number of Constants: 1
		DISPID_SRRSetTextFeedback = 12   ' (&h0000000C)
	End Enum
	
	Enum DISPID_SpeechRecoResultTimes
		' Documentation string: ISpeechPhraseInfoBuilder Interface
		' Number of Constants: 4
		DISPID_SRRTStreamTime = 1   ' (&h00000001)
		DISPID_SRRTLength = 2   ' (&h00000002)
		DISPID_SRRTTickCount = 3   ' (&h00000003)
		DISPID_SRRTOffsetFromStart = 4   ' (&h00000004)
	End Enum
	
	Enum DISPID_SpeechVoice
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 22
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
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 10
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
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 12
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
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 7
		DISPID_SWFEFormatTag = 1   ' (&h00000001)
		DISPID_SWFEChannels = 2   ' (&h00000002)
		DISPID_SWFESamplesPerSec = 3   ' (&h00000003)
		DISPID_SWFEAvgBytesPerSec = 4   ' (&h00000004)
		DISPID_SWFEBlockAlign = 5   ' (&h00000005)
		DISPID_SWFEBitsPerSample = 6   ' (&h00000006)
		DISPID_SWFEExtraData = 7   ' (&h00000007)
	End Enum
	
	Enum DISPID_SpeechXMLRecoResult
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 2
		DISPID_SRRGetXMLResult = 10   ' (&h0000000A)
		DISPID_SRRGetXMLErrorInfo = 11   ' (&h0000000B)
	End Enum
	
	Enum DISPIDSPRG
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 19
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
	End Enum
	
	Enum DISPIDSPTSI
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 4
		DISPIDSPTSI_ActiveOffset = 1   ' (&h00000001)
		DISPIDSPTSI_ActiveLength = 2   ' (&h00000002)
		DISPIDSPTSI_SelectionOffset = 3   ' (&h00000003)
		DISPIDSPTSI_SelectionLength = 4   ' (&h00000004)
	End Enum
	
	Enum SPADAPTATIONRELEVANCE
		' Documentation string: ISpRecoContext2 Interface
		' Number of Constants: 4
		SPAR_Unknown = 0   ' (&h00000000)
		SPAR_Low = 1   ' (&h00000001)
		SPAR_Medium = 2   ' (&h00000002)
		SPAR_High = 3   ' (&h00000003)
	End Enum
	
	Enum SPAUDIOOPTIONS
		' Documentation string: ISpGrammarBuilder Interface
		' Number of Constants: 2
		SPAO_NONE = 0   ' (&h00000000)
		SPAO_RETAIN_AUDIO = 1   ' (&h00000001)
	End Enum
	
	Enum SPBOOKMARKOPTIONS
		' Documentation string: ISpPhraseAlt Interface
		' Number of Constants: 4
		SPBO_NONE = 0   ' (&h00000000)
		SPBO_PAUSE = 1   ' (&h00000001)
		SPBO_AHEAD = 2   ' (&h00000002)
		SPBO_TIME_UNITS = 4   ' (&h00000004)
	End Enum
	
	Enum SPCATEGORYType
		' Documentation string: ISpRecognizer3 Interface
		' Number of Constants: 5
		SPCT_COMMAND = 0   ' (&h00000000)
		SPCT_DICTATION = 1   ' (&h00000001)
		SPCT_SLEEP = 2   ' (&h00000002)
		SPCT_SUB_COMMAND = 3   ' (&h00000003)
		SPCT_SUB_DICTATION = 4   ' (&h00000004)
	End Enum
	
	Enum SPCONTEXTSTATE
		' Documentation string: ISpPhraseAlt Interface
		' Number of Constants: 2
		SPCS_DISABLED = 0   ' (&h00000000)
		SPCS_ENABLED = 1   ' (&h00000001)
	End Enum
	
	Enum SPDATAKEYLOCATION
		' Documentation string: ISpDataKey Interface
		' Number of Constants: 4
		SPDKL_DefaultLocation = 0   ' (&h00000000)
		SPDKL_CurrentUser = 1   ' (&h00000001)
		SPDKL_LocalMachine = 2   ' (&h00000002)
		SPDKL_CurrentConfig = 5   ' (&h00000005)
	End Enum
	
	Enum SpeechAudioFormatType
		' Documentation string: ISpeechAudioFormat Interface
		' Number of Constants: 70
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
		' Documentation string: ISpeechAudioStatus Interface
		' Number of Constants: 4
		SASClosed = 0   ' (&h00000000)
		SASStop = 1   ' (&h00000001)
		SASPause = 2   ' (&h00000002)
		SASRun = 3   ' (&h00000003)
	End Enum
	
	Enum SpeechBookmarkOptions
		' Documentation string: ISpeechPhraseAlternate Interface
		' Number of Constants: 2
		SBONone = 0   ' (&h00000000)
		SBOPause = 1   ' (&h00000001)
	End Enum
	
	Enum SpeechDataKeyLocation
		' Documentation string: ISpeechObjectTokenCategory Interface
		' Number of Constants: 4
		SDKLDefaultLocation = 0   ' (&h00000000)
		SDKLCurrentUser = 1   ' (&h00000001)
		SDKLLocalMachine = 2   ' (&h00000002)
		SDKLCurrentConfig = 5   ' (&h00000005)
	End Enum
	
	Enum SpeechDiscardType
		' Documentation string: ISpeechPhraseAlternate Interface
		' Number of Constants: 9
		SDTProperty = 1   ' (&h00000001)
		SDTReplacement = 2   ' (&h00000002)
		SDTRule = 4   ' (&h00000004)
		SDTDisplayText = 8   ' (&h00000008)
		SDTLexicalForm = 16   ' (&h00000010)
		SDTPronunciation = 32   ' (&h00000020)
		SDTAudio = 64   ' (&h00000040)
		SDTAlternates = 128   ' (&h00000080)
		SDTAll = 255   ' (&h000000FF)
	End Enum
	
	Enum SpeechDisplayAttributes
		' Documentation string: ISpeechPhraseElement Interface
		' Number of Constants: 4
		SDA_No_Trailing_Space = 0   ' (&h00000000)
		SDA_One_Trailing_Space = 2   ' (&h00000002)
		SDA_Two_Trailing_Spaces = 4   ' (&h00000004)
		SDA_Consume_Leading_Spaces = 8   ' (&h00000008)
	End Enum
	
	Enum SpeechEmulationCompareFlags
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 6
		SECFIgnoreCase = 1   ' (&h00000001)
		SECFIgnoreKanaType = 65536   ' (&h00010000)
		SECFIgnoreWidth = 131072   ' (&h00020000)
		SECFNoSpecialChars = 536870912   ' (&h20000000)
		SECFEmulateResult = 1073741824   ' (&h40000000)
		SECFDefault = 196609   ' (&h00030001) ((SECFIgnoreCase OR SECFIgnoreKanaType) OR SECFIgnoreWidth)
	End Enum
	
	Enum SpeechEngineConfidence
		' Documentation string: ISpeechPhraseRules Interface
		' Number of Constants: 3
		SECLowConfidence = -1   ' (&hFFFFFFFF)
		SECNormalConfidence = 0   ' (&h00000000)
		SECHighConfidence = 1   ' (&h00000001)
	End Enum
	
	Enum SpeechFormatType
		' Documentation string: ISpeechPhraseAlternate Interface
		' Number of Constants: 2
		SFTInput = 0   ' (&h00000000) SPWF_INPUT
		SFTSREngine = 1   ' (&h00000001) SPWF_SRENGINE
	End Enum
	
	Enum SpeechGrammarRuleStateTransitionType
		' Documentation string: ISpeechGrammarRuleStateTransition Interface
		' Number of Constants: 6
		SGRSTTEpsilon = 0   ' (&h00000000)
		SGRSTTWord = 1   ' (&h00000001)
		SGRSTTRule = 2   ' (&h00000002)
		SGRSTTDictation = 3   ' (&h00000003)
		SGRSTTWildcard = 4   ' (&h00000004)
		SGRSTTTextBuffer = 5   ' (&h00000005)
	End Enum
	
	Enum SpeechGrammarState
		' Documentation string: ISpeechRecoGrammar Interface
		' Number of Constants: 3
		SGSEnabled = 1   ' (&h00000001) SPGS_ENABLED
		SGSDisabled = 0   ' (&h00000000) SPGS_DISABLED
		SGSExclusive = 3   ' (&h00000003) SPGS_EXCLUSIVE
	End Enum
	
	Enum SpeechGrammarWordType
		' Documentation string: ISpeechGrammarRuleStateTransition Interface
		' Number of Constants: 4
		SGDisplay = 0   ' (&h00000000) SPWT_DISPLAY
		SGLexical = 1   ' (&h00000001) SPWT_LEXICAL
		SGPronounciation = 2   ' (&h00000002) SPWT_PRONUNCIATION
		SGLexicalNoSpecialChars = 3   ' (&h00000003) SPWT_LEXICAL_NO_SPECIAL_CHARS
	End Enum
	
	Enum SpeechInterference
		' Documentation string: ISpeechRecoContext Interface
		' Number of Constants: 7
		SINone = 0   ' (&h00000000) SPINTERFERENCE_NONE
		SINoise = 1   ' (&h00000001) SPINTERFERENCE_NOISE
		SINoSignal = 2   ' (&h00000002) SPINTERFERENCE_NOSIGNAL
		SITooLoud = 3   ' (&h00000003) SPINTERFERENCE_TOOLOUD
		SITooQuiet = 4   ' (&h00000004) SPINTERFERENCE_TOOQUIET
		SITooFast = 5   ' (&h00000005) SPINTERFERENCE_TOOFAST
		SITooSlow = 6   ' (&h00000006) SPINTERFERENCE_TOOSLOW
	End Enum
	
	Enum SpeechLexiconType
		' Documentation string: ISpeechLexicon Interface
		' Number of Constants: 2
		SLTUser = 1   ' (&h00000001) eLEXType_USER
		SLTApp = 2   ' (&h00000002) eLEXType_APP
	End Enum
	
	Enum SpeechLoadOption
		' Documentation string: ISpeechGrammarRuleStateTransition Interface
		' Number of Constants: 2
		SLOStatic = 0   ' (&h00000000) SPLO_STATIC
		SLODynamic = 1   ' (&h00000001) SPLO_DYNAMIC
	End Enum
	
	Enum SpeechPartOfSpeech
		' Documentation string: ISpeechLexiconPronunciation Interface
		' Number of Constants: 9
		SPSNotOverriden = -1   ' (&hFFFFFFFF) SPPS_NotOverriden
		SPSUnknown = 0   ' (&h00000000) SPPS_Unknown
		SPSNoun = 4096   ' (&h00001000) SPPS_Noun
		SPSVerb = 8192   ' (&h00002000) SPPS_Verb
		SPSModifier = 12288   ' (&h00003000) SPPS_Modifier
		SPSFunction = 16384   ' (&h00004000) SPPS_Function
		SPSInterjection = 20480   ' (&h00005000) SPPS_Interjection
		SPSLMA = 28672   ' (&h00007000) SPPS_LMA
		SPSSuppressWord = 61440   ' (&h0000F000) SPPS_SuppressWord
	End Enum
	
	Enum SpeechRecoContextState
		' Documentation string: ISpeechRecoContext Interface
		' Number of Constants: 2
		SRCS_Disabled = 0   ' (&h00000000) SPCS_DISABLED
		SRCS_Enabled = 1   ' (&h00000001) SPCS_ENABLED
	End Enum
	
	Enum SpeechRecoEvents
		' Documentation string: ISpeechRecoContext Interface
		' Number of Constants: 19
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
		' Documentation string: ISpeechPhraseAlternate Interface
		' Number of Constants: 6
		SRTStandard = 0   ' (&h00000000)
		SRTAutopause = 1   ' (&h00000001)
		SRTEmulated = 2   ' (&h00000002)
		SRTSMLTimeout = 4   ' (&h00000004)
		SRTExtendableParse = 8   ' (&h00000008)
		SRTReSent = 16   ' (&h00000010)
	End Enum
	
	Enum SpeechRecognizerState
		' Documentation string: ISpeechRecognizer Interface
		' Number of Constants: 4
		SRSInactive = 0   ' (&h00000000)
		SRSActive = 1   ' (&h00000001)
		SRSActiveAlways = 2   ' (&h00000002)
		SRSInactiveWithPurge = 3   ' (&h00000003)
	End Enum
	
	Enum SpeechRetainedAudioOptions
		' Documentation string: ISpeechRecoContext Interface
		' Number of Constants: 2
		SRAONone = 0   ' (&h00000000)
		SRAORetainAudio = 1   ' (&h00000001)
	End Enum
	
	Enum SpeechRuleAttributes
		' Documentation string: ISpeechGrammarRule Interface
		' Number of Constants: 7
		SRATopLevel = 1   ' (&h00000001) SPRAF_TopLevel
		SRADefaultToActive = 2   ' (&h00000002) SPRAF_Active
		SRAExport = 4   ' (&h00000004) SPRAF_Export
		SRAImport = 8   ' (&h00000008) SPRAF_Import
		SRAInterpreter = 16   ' (&h00000010) SPRAF_Interpreter
		SRADynamic = 32   ' (&h00000020) SPRAF_Dynamic
		SRARoot = 64   ' (&h00000040) SPRAF_Root
	End Enum
	
	Enum SpeechRuleState
		' Documentation string: ISpeechGrammarRuleStateTransition Interface
		' Number of Constants: 4
		SGDSInactive = 0   ' (&h00000000) SPRS_INACTIVE
		SGDSActive = 1   ' (&h00000001) SPRS_ACTIVE
		SGDSActiveWithAutoPause = 3   ' (&h00000003) SPRS_ACTIVE_WITH_AUTO_PAUSE
		SGDSActiveUserDelimited = 4   ' (&h00000004) SPRS_ACTIVE_USER_DELIMITED
	End Enum
	
	Enum SpeechRunState
		' Documentation string: ISpeechVoiceStatus Interface
		' Number of Constants: 2
		SRSEDone = 1   ' (&h00000001) SPRS_DONE
		SRSEIsSpeaking = 2   ' (&h00000002) SPRS_IS_SPEAKING
	End Enum
	
	Enum SpeechSpecialTransitionType
		' Documentation string: ISpeechGrammarRuleStateTransition Interface
		' Number of Constants: 3
		SSTTWildcard = 1   ' (&h00000001)
		SSTTDictation = 2   ' (&h00000002)
		SSTTTextBuffer = 3   ' (&h00000003)
	End Enum
	
	Enum SpeechStreamFileMode
		' Documentation string: ISpeechFileStream Interface
		' Number of Constants: 4
		SSFMOpenForRead = 0   ' (&h00000000)
		SSFMOpenReadWrite = 1   ' (&h00000001)
		SSFMCreate = 2   ' (&h00000002)
		SSFMCreateForWrite = 3   ' (&h00000003)
	End Enum
	
	Enum SpeechStreamSeekPositionType
		' Documentation string: ISpeechBaseStream Interface
		' Number of Constants: 3
		SSSPtrelativeToStart = 0   ' (&h00000000) STREAM_SEEK_SET
		SSSPtrelativeToCurrentPosition = 1   ' (&h00000001) STREAM_SEEK_CUR
		SSSPtrelativeToEnd = 2   ' (&h00000002) STREAM_SEEK_END
	End Enum
	
	Enum SpeechTokenContext
		' Documentation string: ISpeechObjectTokens Interface
		' Number of Constants: 5
		STCInprocServer = 1   ' (&h00000001)
		STCInprocHandler = 2   ' (&h00000002)
		STCLocalServer = 4   ' (&h00000004)
		STCRemoteServer = 16   ' (&h00000010)
		STCAll = 23   ' (&h00000017)
	End Enum
	
	Enum SpeechTokenShellFolder
		' Documentation string: ISpeechObjectTokens Interface
		' Number of Constants: 4
		STSF_AppData = 26   ' (&h0000001A)
		STSF_LocalAppData = 28   ' (&h0000001C)
		STSF_CommonAppData = 35   ' (&h00000023)
		STSF_FlagCreate = 32768   ' (&h00008000)
	End Enum
	
	Enum SpeechVisemeFeature
		' Documentation string: ISpeechVoiceStatus Interface
		' Number of Constants: 3
		SVF_None = 0   ' (&h00000000)
		SVF_Stressed = 1   ' (&h00000001) SPVFEATURE_STRESSED
		SVF_Emphasis = 2   ' (&h00000002) SPVFEATURE_EMPHASIS
	End Enum
	
	Enum SpeechVisemeType
		' Documentation string: ISpeechVoiceStatus Interface
		' Number of Constants: 22
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
		' Documentation string: ISpeechVoiceStatus Interface
		' Number of Constants: 11
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
		' Documentation string: ISpeechVoiceStatus Interface
		' Number of Constants: 3
		SVPNormal = 0   ' (&h00000000) SPVPRI_NORMAL
		SVPAlert = 1   ' (&h00000001) SPVPRI_ALERT
		SVPOver = 2   ' (&h00000002) SPVPRI_OVER
	End Enum
	
	Enum SpeechVoiceSpeakFlags
		' Documentation string: ISpeechVoiceStatus Interface
		' Number of Constants: 15
		SVSFDefault = 0   ' (&h00000000) SPF_DEFAULT
		SVSFlagsAsync = 1   ' (&h00000001) SPF_ASYNC
		SVSFPurgeBeforeSpeak = 2   ' (&h00000002) SPF_PURGEBEFORESPEAK
		SVSFIsFilename = 4   ' (&h00000004) SPF_IS_FILENAME
		SVSFIsXML = 8   ' (&h00000008) SPF_IS_XML
		SVSFIsNotXML = 16   ' (&h00000010) SPF_IS_NOT_XML
		SVSFPersistXML = 32   ' (&h00000020) SPF_PERSIST_XML
		SVSFNLPSpeakPunc = 64   ' (&h00000040) SPF_NLP_SPEAK_PUNC
		SVSFParseSAPI = 128   ' (&h00000080)
		SVSFParseSsml = 256   ' (&h00000100)
		SVSFParseAutodetect = 0   ' (&h00000000)
		SVSFNLPMask = 64   ' (&h00000040) SPF_NLP_MASK
		SVSFParseMask = 384   ' (&h00000180)
		SVSFVoiceMask = 511   ' (&h000001FF) SPF_VOICE_MASK
		SVSFUnusedFlags = -512   ' (&hFFFFFE00) SPF_UNUSED_FLAGS
	End Enum
	
	Enum SpeechWordPronounceable
		' Documentation string: ISpeechTextSelectionInformation Interface
		' Number of Constants: 3
		SWPUnknownWordUnpronounceable = 0   ' (&h00000000)
		SWPUnknownWordPronounceable = 1   ' (&h00000001)
		SWPKnownWordPronounceable = 2   ' (&h00000002)
	End Enum
	
	Enum SpeechWordType
		' Documentation string: ISpeechLexiconWord Interface
		' Number of Constants: 2
		SWTAdded = 1   ' (&h00000001) eWORDType_ADDED
		SWTDeleted = 2   ' (&h00000002) eWORDType_DELETED
	End Enum
	
	Enum SPEVENTENUM
		' Documentation string: ISpVoice Interface
		' Number of Constants: 40
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
	End Enum
	
	Enum SPFILEMODE
		' Documentation string: ISpStream Interface
		' Number of Constants: 5
		SPFM_OPEN_READONLY = 0   ' (&h00000000)
		SPFM_OPEN_READWRITE = 1   ' (&h00000001)
		SPFM_CREATE = 2   ' (&h00000002)
		SPFM_CREATE_ALWAYS = 3   ' (&h00000003)
		SPFM_NUM_MODES = 4   ' (&h00000004)
	End Enum
	
	Enum SPGRAMMARSTATE
		' Documentation string: ISpGrammarBuilder Interface
		' Number of Constants: 3
		SPGS_DISABLED = 0   ' (&h00000000)
		SPGS_ENABLED = 1   ' (&h00000001)
		SPGS_EXCLUSIVE = 3   ' (&h00000003)
	End Enum
	
	Enum SPGRAMMARWORDType
		' Documentation string: ISpGrammarBuilder Interface
		' Number of Constants: 4
		SPWT_DISPLAY = 0   ' (&h00000000)
		SPWT_LEXICAL = 1   ' (&h00000001)
		SPWT_PRONUNCIATION = 2   ' (&h00000002)
		SPWT_LEXICAL_NO_SPECIAL_CHARS = 3   ' (&h00000003)
	End Enum
	
	Enum SPINTERFERENCE
		' Documentation string: ISpGrammarBuilder Interface
		' Number of Constants: 7
		SPINTERFERENCE_NONE = 0   ' (&h00000000)
		SPINTERFERENCE_NOISE = 1   ' (&h00000001)
		SPINTERFERENCE_NOSIGNAL = 2   ' (&h00000002)
		SPINTERFERENCE_TOOLOUD = 3   ' (&h00000003)
		SPINTERFERENCE_TOOQUIET = 4   ' (&h00000004)
		SPINTERFERENCE_TOOFAST = 5   ' (&h00000005)
		SPINTERFERENCE_TOOSLOW = 6   ' (&h00000006)
	End Enum
	
	Enum SPLEXICONType
		' Documentation string: ISpLexicon Interface
		' Number of Constants: 32
		eLEXType_USER = 1   ' (&h00000001)
		eLEXType_APP = 2   ' (&h00000002)
		eLEXType_VENDORLEXICON = 4   ' (&h00000004)
		eLEXType_LETTERTOSOUND = 8   ' (&h00000008)
		eLEXType_MORPHOLOGY = 16   ' (&h00000010)
		eLEXType_RESERVED4 = 32   ' (&h00000020)
		eLEXType_USER_SHORTCUT = 64   ' (&h00000040)
		eLEXType_RESERVED6 = 128   ' (&h00000080)
		eLEXType_RESERVED7 = 256   ' (&h00000100)
		eLEXType_RESERVED8 = 512   ' (&h00000200)
		eLEXType_RESERVED9 = 1024   ' (&h00000400)
		eLEXType_RESERVED10 = 2048   ' (&h00000800)
		eLEXType_PRIVATE1 = 4096   ' (&h00001000)
		eLEXType_PRIVATE2 = 8192   ' (&h00002000)
		eLEXType_PRIVATE3 = 16384   ' (&h00004000)
		eLEXType_PRIVATE4 = 32768   ' (&h00008000)
		eLEXType_PRIVATE5 = 65536   ' (&h00010000)
		eLEXType_PRIVATE6 = 131072   ' (&h00020000)
		eLEXType_PRIVATE7 = 262144   ' (&h00040000)
		eLEXType_PRIVATE8 = 524288   ' (&h00080000)
		eLEXType_PRIVATE9 = 1048576   ' (&h00100000)
		eLEXType_PRIVATE10 = 2097152   ' (&h00200000)
		eLEXType_PRIVATE11 = 4194304   ' (&h00400000)
		eLEXType_PRIVATE12 = 8388608   ' (&h00800000)
		eLEXType_PRIVATE13 = 16777216   ' (&h01000000)
		eLEXType_PRIVATE14 = 33554432   ' (&h02000000)
		eLEXType_PRIVATE15 = 67108864   ' (&h04000000)
		eLEXType_PRIVATE16 = 134217728   ' (&h08000000)
		eLEXType_PRIVATE17 = 268435456   ' (&h10000000)
		eLEXType_PRIVATE18 = 536870912   ' (&h20000000)
		eLEXType_PRIVATE19 = 1073741824   ' (&h40000000)
		eLEXType_PRIVATE20 = -2147483648   ' (&h80000000)
	End Enum
	
	Enum SPLOADOPTIONS
		' Documentation string: ISpGrammarBuilder Interface
		' Number of Constants: 2
		SPLO_STATIC = 0   ' (&h00000000)
		SPLO_DYNAMIC = 1   ' (&h00000001)
	End Enum
	
	Enum SPPARTOFSPEECH
		' Documentation string: ISpLexicon Interface
		' Number of Constants: 10
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
		' Documentation string: ISpProperties Interface
		' Number of Constants: 5
		SPRST_INACTIVE = 0   ' (&h00000000)
		SPRST_ACTIVE = 1   ' (&h00000001)
		SPRST_ACTIVE_ALWAYS = 2   ' (&h00000002)
		SPRST_INACTIVE_WITH_PURGE = 3   ' (&h00000003)
		SPRST_NUM_STATES = 4   ' (&h00000004)
	End Enum
	
	Enum SPRULESTATE
		' Documentation string: ISpGrammarBuilder Interface
		' Number of Constants: 4
		SPRS_INACTIVE = 0   ' (&h00000000)
		SPRS_ACTIVE = 1   ' (&h00000001)
		SPRS_ACTIVE_WITH_AUTO_PAUSE = 3   ' (&h00000003)
		SPRS_ACTIVE_USER_DELIMITED = 4   ' (&h00000004)
	End Enum
	
	Enum SPSEMANTICFORMAT
		' Documentation string: ISpPhrase Interface
		' Number of Constants: 5
		SPSMF_SAPI_PROPERTIES = 0   ' (&h00000000)
		SPSMF_SRGS_SEMANTICINTERPRETATION_MS = 1   ' (&h00000001)
		SPSMF_SRGS_SAPIPROPERTIES = 2   ' (&h00000002)
		SPSMF_UPS = 4   ' (&h00000004)
		SPSMF_SRGS_SEMANTICINTERPRETATION_W3C = 8   ' (&h00000008)
	End Enum
	
	Enum SPSHORTCUTType
		' Documentation string: ISpShortcut Interface
		' Number of Constants: 8
		SPSHT_NotOverriden = -1   ' (&hFFFFFFFF)
		SPSHT_Unknown = 0   ' (&h00000000)
		SPSHT_EMAIL = 4096   ' (&h00001000)
		SPSHT_OTHER = 8192   ' (&h00002000)
		SPPS_RESERVED1 = 12288   ' (&h00003000)
		SPPS_RESERVED2 = 16384   ' (&h00004000)
		SPPS_RESERVED3 = 20480   ' (&h00005000)
		SPPS_RESERVED4 = 61440   ' (&h0000F000)
	End Enum
	
	Enum SPVISEMES
		' Documentation string: ISpVoice Interface
		' Number of Constants: 22
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
	End Enum
	
	Enum SPVPRIORITY
		' Documentation string: ISpVoice Interface
		' Number of Constants: 3
		SPVPRI_NORMAL = 0   ' (&h00000000)
		SPVPRI_ALERT = 1   ' (&h00000001)
		SPVPRI_OVER = 2   ' (&h00000002)
	End Enum
	
	Enum SPWAVEFORMATType
		' Documentation string: ISpProperties Interface
		' Number of Constants: 2
		SPWF_INPUT = 0   ' (&h00000000)
		SPWF_SRENGINE = 1   ' (&h00000001)
	End Enum
	
	Enum SPWORDPRONOUNCEABLE
		' Documentation string: ISpGrammarBuilder Interface
		' Number of Constants: 3
		SPWP_UNKNOWN_WORD_UNPRONOUNCEABLE = 0   ' (&h00000000)
		SPWP_UNKNOWN_WORD_PRONOUNCEABLE = 1   ' (&h00000001)
		SPWP_KNOWN_WORD_PRONOUNCEABLE = 2   ' (&h00000002)
	End Enum
	
	Enum SPWORDType
		' Documentation string: ISpLexicon Interface
		' Number of Constants: 2
		eWORDType_ADDED = 1   ' (&h00000001)
		eWORDType_DELETED = 2   ' (&h00000002)
	End Enum
	
	Enum SPXMLRESULTOPTIONS
		' Documentation string: ISpeechXMLRecoResult Interface
		' Number of Constants: 2
		SPXRO_SML = 0   ' (&h00000000)
		SPXRO_Alternates_SML = 1   ' (&h00000001)
	End Enum
	
	' enum SPSTREAMFORMAT
	Type SPSTREAMFORMAT As Long
	Const SPSF_Default                 = -1
	Const SPSF_NoAssignedFormat        = 0
	Const SPSF_Text                    = SPSF_NoAssignedFormat        + 1
	Const SPSF_NonStandardFormat       = SPSF_Text                    + 1
	Const SPSF_ExtendedAudioFormat     = SPSF_NonStandardFormat       + 1
	Const SPSF_8kHz8BitMono            = SPSF_ExtendedAudioFormat     + 1
	Const SPSF_8kHz8BitStereo          = SPSF_8kHz8BitMono            + 1
	Const SPSF_8kHz16BitMono           = SPSF_8kHz8BitStereo          + 1
	Const SPSF_8kHz16BitStereo         = SPSF_8kHz16BitMono           + 1
	Const SPSF_11kHz8BitMono           = SPSF_8kHz16BitStereo         + 1
	Const SPSF_11kHz8BitStereo         = SPSF_11kHz8BitMono           + 1
	Const SPSF_11kHz16BitMono          = SPSF_11kHz8BitStereo         + 1
	Const SPSF_11kHz16BitStereo        = SPSF_11kHz16BitMono          + 1
	Const SPSF_12kHz8BitMono           = SPSF_11kHz16BitStereo        + 1
	Const SPSF_12kHz8BitStereo         = SPSF_12kHz8BitMono           + 1
	Const SPSF_12kHz16BitMono          = SPSF_12kHz8BitStereo         + 1
	Const SPSF_12kHz16BitStereo        = SPSF_12kHz16BitMono          + 1
	Const SPSF_16kHz8BitMono           = SPSF_12kHz16BitStereo        + 1
	Const SPSF_16kHz8BitStereo         = SPSF_16kHz8BitMono           + 1
	Const SPSF_16kHz16BitMono          = SPSF_16kHz8BitStereo         + 1
	Const SPSF_16kHz16BitStereo        = SPSF_16kHz16BitMono          + 1
	Const SPSF_22kHz8BitMono           = SPSF_16kHz16BitStereo        + 1
	Const SPSF_22kHz8BitStereo         = SPSF_22kHz8BitMono           + 1
	Const SPSF_22kHz16BitMono          = SPSF_22kHz8BitStereo         + 1
	Const SPSF_22kHz16BitStereo        = SPSF_22kHz16BitMono          + 1
	Const SPSF_24kHz8BitMono           = SPSF_22kHz16BitStereo        + 1
	Const SPSF_24kHz8BitStereo         = SPSF_24kHz8BitMono           + 1
	Const SPSF_24kHz16BitMono          = SPSF_24kHz8BitStereo         + 1
	Const SPSF_24kHz16BitStereo        = SPSF_24kHz16BitMono          + 1
	Const SPSF_32kHz8BitMono           = SPSF_24kHz16BitStereo        + 1
	Const SPSF_32kHz8BitStereo         = SPSF_32kHz8BitMono           + 1
	Const SPSF_32kHz16BitMono          = SPSF_32kHz8BitStereo         + 1
	Const SPSF_32kHz16BitStereo        = SPSF_32kHz16BitMono          + 1
	Const SPSF_44kHz8BitMono           = SPSF_32kHz16BitStereo        + 1
	Const SPSF_44kHz8BitStereo         = SPSF_44kHz8BitMono           + 1
	Const SPSF_44kHz16BitMono          = SPSF_44kHz8BitStereo         + 1
	Const SPSF_44kHz16BitStereo        = SPSF_44kHz16BitMono          + 1
	Const SPSF_48kHz8BitMono           = SPSF_44kHz16BitStereo        + 1
	Const SPSF_48kHz8BitStereo         = SPSF_48kHz8BitMono           + 1
	Const SPSF_48kHz16BitMono          = SPSF_48kHz8BitStereo         + 1
	Const SPSF_48kHz16BitStereo        = SPSF_48kHz16BitMono          + 1
	Const SPSF_TrueSpeech_8kHz1BitMono = SPSF_48kHz16BitStereo        + 1
	Const SPSF_CCITT_ALaw_8kHzMono     = SPSF_TrueSpeech_8kHz1BitMono + 1
	Const SPSF_CCITT_ALaw_8kHzStereo   = SPSF_CCITT_ALaw_8kHzMono     + 1
	Const SPSF_CCITT_ALaw_11kHzMono    = SPSF_CCITT_ALaw_8kHzStereo   + 1
	Const SPSF_CCITT_ALaw_11kHzStereo  = SPSF_CCITT_ALaw_11kHzMono    + 1
	Const SPSF_CCITT_ALaw_22kHzMono    = SPSF_CCITT_ALaw_11kHzStereo  + 1
	Const SPSF_CCITT_ALaw_22kHzStereo  = SPSF_CCITT_ALaw_22kHzMono    + 1
	Const SPSF_CCITT_ALaw_44kHzMono    = SPSF_CCITT_ALaw_22kHzStereo  + 1
	Const SPSF_CCITT_ALaw_44kHzStereo  = SPSF_CCITT_ALaw_44kHzMono    + 1
	Const SPSF_CCITT_uLaw_8kHzMono     = SPSF_CCITT_ALaw_44kHzStereo  + 1
	Const SPSF_CCITT_uLaw_8kHzStereo   = SPSF_CCITT_uLaw_8kHzMono     + 1
	Const SPSF_CCITT_uLaw_11kHzMono    = SPSF_CCITT_uLaw_8kHzStereo   + 1
	Const SPSF_CCITT_uLaw_11kHzStereo  = SPSF_CCITT_uLaw_11kHzMono    + 1
	Const SPSF_CCITT_uLaw_22kHzMono    = SPSF_CCITT_uLaw_11kHzStereo  + 1
	Const SPSF_CCITT_uLaw_22kHzStereo  = SPSF_CCITT_uLaw_22kHzMono    + 1
	Const SPSF_CCITT_uLaw_44kHzMono    = SPSF_CCITT_uLaw_22kHzStereo  + 1
	Const SPSF_CCITT_uLaw_44kHzStereo  = SPSF_CCITT_uLaw_44kHzMono    + 1
	Const SPSF_ADPCM_8kHzMono          = SPSF_CCITT_uLaw_44kHzStereo  + 1
	Const SPSF_ADPCM_8kHzStereo        = SPSF_ADPCM_8kHzMono          + 1
	Const SPSF_ADPCM_11kHzMono         = SPSF_ADPCM_8kHzStereo        + 1
	Const SPSF_ADPCM_11kHzStereo       = SPSF_ADPCM_11kHzMono         + 1
	Const SPSF_ADPCM_22kHzMono         = SPSF_ADPCM_11kHzStereo       + 1
	Const SPSF_ADPCM_22kHzStereo       = SPSF_ADPCM_22kHzMono         + 1
	Const SPSF_ADPCM_44kHzMono         = SPSF_ADPCM_22kHzStereo       + 1
	Const SPSF_ADPCM_44kHzStereo       = SPSF_ADPCM_44kHzMono         + 1
	Const SPSF_GSM610_8kHzMono         = SPSF_ADPCM_44kHzStereo       + 1
	Const SPSF_GSM610_11kHzMono        = SPSF_GSM610_8kHzMono         + 1
	Const SPSF_GSM610_22kHzMono        = SPSF_GSM610_11kHzMono        + 1
	Const SPSF_GSM610_44kHzMono        = SPSF_GSM610_22kHzMono        + 1
	Const SPSF_NUM_FORMATS             = SPSF_GSM610_44kHzMono        + 1
	
	'EXTERN_C Const GUID SPDFID_Text;
	'EXTERN_C Const GUID SPDFID_WaveFormatEx;
	' Defined in SAPIut.idl
	Const SPDFID_Text = "{7CEEF9F9-3D13-11D2-9EE7-00C04F797396}"
	Const SPDFID_WaveFormatEx = "{C31ADBAE-527F-4FF5-A230-F62BB61FF70C}"
	
	Const SPREG_USER_ROOT                            = WStr("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech")
	Const SPREG_LOCAL_MACHINE_ROOT                   = WStr("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech")
	Const SPCAT_AUDIOOUT                             = WStr("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\AudioOutput")
	Const SPCAT_AUDIOIN                              = WStr("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\AudioInput")
	Const SPCAT_VOICES                               = WStr("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\Voices")
	Const SPCAT_RECOGNIZERS                          = WStr("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\Recognizers")
	Const SPCAT_APPLEXICONS                          = WStr("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\AppLexicons")
	Const SPCAT_PHONECONVERTERS                      = WStr("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\PhoneConverters")
	Const SPCAT_RECOPROFILES                         = WStr("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech\RecoProfiles")
	Const SPMMSYS_AUDIO_IN_TOKEN_ID                  = WStr("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\AudioInput\TokenEnums\MMAudioIn\")
	Const SPMMSYS_AUDIO_OUT_TOKEN_ID                 = WStr("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\AudioOutput\TokenEnums\MMAudioOut\")
	Const SPCURRENT_USER_LEXICON_TOKEN_ID            = WStr("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech\CurrentUserLexicon")
	Const SPCURRENT_USER_SHORTCUT_TOKEN_ID           = WStr("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech\CurrentUserShortcut")
	Const SPTOKENVALUE_CLSID                         = WStr("CLSID")
	Const SPTOKENKEY_FILES                           = WStr("Files")
	Const SPTOKENKEY_UI                              = WStr("UI")
	Const SPTOKENKEY_ATTRIBUTES                      = WStr("Attributes")
	Const SPTOKENKEY_RETAINEDAUDIO                   = WStr("SecondsPerRetainedAudioEvent")
	Const SPVOICECATEGORY_TTSRATE                    = WStr("DefaultTTSRate")
	Const SPPROP_RESOURCE_USAGE                      = WStr("ResourceUsage")
	Const SPPROP_HIGH_CONFIDENCE_THRESHOLD           = WStr("HighConfidenceThreshold")
	Const SPPROP_NORMAL_CONFIDENCE_THRESHOLD         = WStr("NormalConfidenceThreshold")
	Const SPPROP_LOW_CONFIDENCE_THRESHOLD            = WStr("LowConfidenceThreshold")
	Const SPPROP_RESPONSE_SPEED                      = WStr("ResponseSpeed")
	Const SPPROP_COMPLEX_RESPONSE_SPEED              = WStr("ComplexResponseSpeed")
	Const SPPROP_ADAPTATION_ON                       = WStr("AdaptationOn")
	Const SPPROP_PERSISTED_BACKGROUND_ADAPTATION     = WStr("PersistedBackgroundAdaptation")
	Const SPPROP_PERSISTED_LANGUAGE_MODEL_ADAPTATION = WStr("PersistedLanguageModelAdaptation")
	Const SPPROP_UX_IS_LISTENING                     = WStr("UXIsListening")
	Const SPTOPIC_SPELLING                           = WStr("Spelling")
	Const SPWILDCARD                                 = WStr("...")
	Const SPDICTATION                                = WStr("*")
	Const SPINFDICTATION                             = WStr("*+")
	Const SPREG_SAFE_USER_TOKENS                     = WStr($"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\UserTokens")
	
	Const SP_LOW_CONFIDENCE    = -1
	Const SP_NORMAL_CONFIDENCE = 0
	Const SP_HIGH_CONFIDENCE   = +1
	Const DEFAULT_WEIGHT       = 1
	Const SP_MAX_WORD_LENGTH   = 128
	Const SP_MAX_PRON_LENGTH   = 384
	Const SP_EMULATE_RESULT    = &h40000000
	
	'Typedef void __stdcall SPNOTIFYCALLBACK(WPARAM wParam, LPARAM lParam);
	'SUB SPNOTIFYCALLBACK (ByVal wParam AS DWORD, ByVal lParam AS Long)
	
	' enum SPEVENTLPARAMType
	Type SPEVENTLPARAMType As Long
	Const SPET_LPARAM_IS_UNDEFINED = 0
	Const SPET_LPARAM_IS_TOKEN     = SPET_LPARAM_IS_UNDEFINED + 1
	Const SPET_LPARAM_IS_OBJECT    = SPET_LPARAM_IS_TOKEN     + 1
	Const SPET_LPARAM_IS_POINTER   = SPET_LPARAM_IS_OBJECT    + 1
	Const SPET_LPARAM_IS_STRING    = SPET_LPARAM_IS_POINTER   + 1
	
	'#define SPFEI_FLAGCHECK ( (1ui64 << SPEI_RESERVED1) | (1ui64 << SPEI_RESERVED2) )
	'#define SPFEI_ALL_TTS_EVENTS (0x000000000000FFFEui64 | SPFEI_FLAGCHECK)
	'#define SPFEI_ALL_SR_EVENTS  (0x001FFFFC00000000ui64 | SPFEI_FLAGCHECK)
	'#define SPFEI_ALL_EVENTS      0xEFFFFFFFFFFFFFFFui64
	'#define SPFEI(SPEI_ord) ((1ui64 << SPEI_ord) | SPFEI_FLAGCHECK)
	
	Const SPFEI_FLAGCHECK =  9663676416ull
	Const SPFEI_ALL_TTS_EVENTS =  9663741950ull
	Const SPFEI_ALL_SR_EVENTS =  9007191738548224ull
	Const SPFEI_ALL_EVENTS = &HEFFFFFFFFFFFFFFFull
	#define SPFEI(SPEI_ord) ((1ull Shl SPEI_ord) Or SPFEI_FLAGCHECK)
	
	' Size = 24 bytes
	Type SPSERIALIZEDEVENT   ' Must be 8 byte aligned
		eEventId             As WORD    ' SPEVENTENUM
		elParamType          As WORD    ' SPEVENTLPARAMType
		ulStreamNum          As ULong
		ullAudioStreamOffset As ULONGLONG
		SerializedwParam     As ULong
		SerializedlParam     As Long
	End Type
	
	' Size = 32 bytes
	Type SPSERIALIZEDEVENT64   ' Must be 8 byte aligned
		eEventId             As WORD    ' SPEVENTENUM
		elParamType          As WORD    ' SPEVENTLPARAMType
		ulStreamNum          As ULong   ' ULong
		ullAudioStreamOffset As ULONGLONG
		SerializedwParam     As ULONGLONG
		SerializedlParam     As LONGLONG
	End Type
	
	' Size = 32 bytes
	Type SPEVENTEX   ' Must be 8 byte aligned
		eEventId             As WORD    ' SPEVENTENUM
		elParamType          As WORD    ' SPEVENTLPARAMType
		ulStreamNum          As ULong
		ullAudioStreamOffset As ULONGLONG
		wParam               As WPARAM
		lParam               As LPARAM
		ullAudioTimeOffset   As ULONGLONG
	End Type
	
	' enum SPENDSRSTREAMFLAGS
	Type SPENDSRSTREAMFLAGS As Long
	Const SPESF_NONE            = 0
	Const SPESF_STREAM_RELEASED = 1   ' 1 << 0
	Const SPESF_EMULATED        =  2   ' 1 << 1
	
	' enum SPVFEATURE
	Type SPVFEATURE As Long
	Const SPVFEATURE_STRESSED   = 1   ' 1L << 0
	Const SPVFEATURE_EMPHASIS   = 2   ' 1L << 1
	
	' enum SPDISPLYATTRIBUTES
	Type SPDISPLYATTRIBUTES As Long
	Const SPAF_ONE_TRAILING_SPACE     = &h2
	Const SPAF_TWO_TRAILING_SPACES    = &h4
	Const SPAF_CONSUME_LEADING_SPACES = &h8
	Const SPAF_ALL                    = &hf
	Const SPAF_USER_SPECIFIED         = &h80
	
	'Typedef WCHAR SPPHONEID;
	'Typedef LPWStr PSPPHONEID;
	'Typedef LPCWStr PCSPPHONEID;
	Type SPPHONEID As WCHAR
	Type PSPPHONEID As LPWSTR
	Type PCSPPHONEID As LPCWSTR
	
	' enum SPPHRASEPROPERTYUNIONType
	Type SPPHRASEPROPERTYUNIONType As Long
	Const SPPPUT_UNUSED      = 0
	Const SPPPUT_ARRAY_INDEX = SPPPUT_UNUSED + 1
	
	' enum SPVALUEType
	Type SPVALUEType As Long
	Const SPDF_PROPERTY      = &h1
	Const SPDF_REPLACEMENT   = &h2
	Const SPDF_RULE          = &h4
	Const SPDF_DISPLAYTEXT   = &h8
	Const SPDF_LEXICALFORM   = &h10
	Const SPDF_PRONUNCIATION = &h20
	Const SPDF_AUDIO         = &h40
	Const SPDF_ALTERNATES    = &h80
	Const SPDF_ALL           = &hff
	
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
		pCategory As LPCWStr
		pBefore   As LPCWStr
		pAfter    As LPCWStr
	End Type
	
	Type SPVSTATE
		eAction       As Long           ' SPVACTIONS
		LangID        As WORD           ' WORD
		wReserved     As WORD           ' WORD
		EmphAdj       As Long           ' Long
		RateAdj       As Long           ' Long
		Volume        As ULong          ' ULong
		PitchAdj      As SPVPITCH       ' SPVPITCH
		SilenceMSecs  As ULong          ' ULong
		pPhoneIds     As WCHAR Ptr      ' SPPHONEID *
		ePartOfSpeech As Long           ' SPPARTOFSPEECH enum
		Context       As SPVCONTEXT     ' SPVCONTEXT
	End Type
	
	' enum SPRUNSTATE
	Type SPRUNSTATE As Log
	Const SPRS_DONE        = 1   ' 1L << 0
	Const SPRS_IS_SPEAKING = 2   ' 1L << 1
	
	' enum SPVLIMITS
	Type SPVLIMITS As Long
	Const SPMIN_VOLUME = 0
	Const SPMAX_VOLUME = 100
	Const SPMIN_RATE   = -10
	Const SPMAX_RATE   = 10
	
	' enum SPEAKFLAGS
	Type SPEAKFLAGS As Long
	Const SPF_DEFAULT          = 0
	Const SPF_ASYNC            = &h1                                                                                                                                                             ' 1L << 0
	Const SPF_PURGEBEFORESPEAK = &h2                                                                                                                                                             ' 1L << 1
	Const SPF_IS_FILENAME      = &h4                                                                                                                                                             ' 1L << 2
	Const SPF_IS_XML           = &h8                                                                                                                                                             ' 1L << 3
	Const SPF_IS_NOT_XML       = &h10                                                                                                                                                            ' 1L << 4
	Const SPF_PERSIST_XML      = &h20                                                                                                                                                            ' 1L << 5
	Const SPF_NLP_SPEAK_PUNC   = &h40                                                                                                                                                            ' 1L << 6
	Const SPF_NLP_MASK         = SPF_NLP_SPEAK_PUNC
	Const SPF_VOICE_MASK       = SPF_ASYNC Or SPF_PURGEBEFORESPEAK Or SPF_IS_FILENAME Or SPF_IS_XML Or SPF_IS_NOT_XML Or SPF_NLP_MASK Or SPF_PERSIST_XML
	Const SPF_UNUSED_FLAGS     = Not SPF_VOICE_MASK
	
	' enum SPCOMMITFLAGS
	Type SPCOMMITFLAGS As Long
	Const SPCF_NONE                = 0
	Const SPCF_ADD_TO_USER_LEXICON = 1   ' 1 << 0
	Const SPCF_DEFINITE_CORRECTION = 2   ' 1 << 1
	
	Const SP_STREAMPOS_ASAP = 0
	Const SP_STREAMPOS_REALTIME = -1
	
	Const SPRULETRANS_TEXTBUFFER = &hFFFFFFFF   ' (SPSTATEHANDLE)(-1)
	Const SPRULETRANS_WILDCARD   = &hFFFFFFFE   ' (SPSTATEHANDLE)(-2)
	Const SPRULETRANS_DICTATION  = &hFFFFFFFD   ' (SPSTATEHANDLE)(-3)
	
	' enum SPCFGRULEATTRIBUTES
	Type SPCFGRULEATTRIBUTES As Long
	Const SPRAF_TopLevel      = &h1       ' 1 << 0
	Const SPRAF_Active        = &h2       ' 1 << 1
	Const SPRAF_Export        = &h4       ' 1 << 2
	Const SPRAF_Import        = &h8       ' 1 << 3
	Const SPRAF_Interpreter   = &h10      ' 1 << 4
	Const SPRAF_Dynamic       = &h20      ' 1 << 5
	Const SPRAF_Root          = &h40      ' 1 << 6
	Const SPRAF_AutoPause     = &h10000   ' 1 << 16
	Const SPRAF_UserDelimited = &h20000   ' 1 << 17
	
	' enum SPMATCHINGMODE
	Type SPMATCHINGMODE AS Long
	Const AllWords                     = 0
	Const Subsequence                  = 1
	Const OrderedSubset                = 3
	Const SubsequenceContentRequired   = 5
	Const OrderedSubsetContentRequired = 7
	
	' enum PHONETICALPHABET
	Type PHONETICALPHABET As Long
	Const PA_Ipa   = 0
	Const PA_Ups   = 1
	Const PA_SAPI  = 2
	
	' enum SPGRAMMAROPTIONS
	Type SPGRAMMAROPTIONS As Long
	Const SPGO_SAPI            = &h1
	Const SPGO_SRGS            = &h2
	Const SPGO_UPS             = &h4
	Const SPGO_SRGS_MS_SCRIPT  = &h8
	Const SPGO_SRGS_W3C_SCRIPT = &h100
	Const SPGO_SRGS_STG_SCRIPT = &h200
	Const SPGO_SRGS_SCRIPT     = (((SPGO_SRGS Or SPGO_SRGS_MS_SCRIPT) Or SPGO_SRGS_W3C_SCRIPT) Or SPGO_SRGS_STG_SCRIPT)
	Const SPGO_FILE            = &h10
	Const SPGO_HTTP            = &h20
	Const SPGO_RES             = &h40
	Const SPGO_OBJECT          = &h80
	Const SPGO_DEFAULT         = &h3fb
	Const SPGO_ALL             = &h3ff
	
	' enum SPADAPTATIONSETTINGS
	Type SPADAPTATIONSETTINGS As Long
	Const SPADS_Default              = 0
	Const SPADS_CurrentRecognizer    = &h1
	Const SPADS_RecoProfile          = &h2
	Const SPADS_Immediate            = &h4
	Const SPADS_Reset                = &h8
	Const SPADS_HighVolumeDataSource = &h10
	
	Const SP_MAX_LANGIDS = 20
	
	Type SPNORMALIZATIONLIST
		ulSize              As ULong          ' ULong
		ppszzNormalizedList As WCHAR Ptr Ptr  ' WCHAR **
	End Type
	
	' Modules
	
	' Module: SpeechConstants
	' IID: {F3E092B2-6BDC-410F-BCB2-4C5ED4424180}
	' Documentation string: ISpeechLexiconPronunciation Interface
	' Number of Constants: 6
	Const Speech_Default_Weight = 1   ' DEFAULT_WEIGHT
	Const Speech_Max_Word_Length = 128   ' (&h00000080) SP_MAX_WORD_LENGTH
	Const Speech_Max_Pron_Length = 384   ' (&h00000180) SP_MAX_PRON_LENGTH
	Const Speech_StreamPos_Asap = 0   ' (&h00000000) SP_STREAMPOS_ASAP
	Const Speech_StreamPos_RealTime = -1   ' (&hFFFFFFFF) SP_STREAMPOS_REALTIME
	Const SpeechAllElements = -1   ' (&hFFFFFFFF) SPPR_ALL_ELEMENTS
	
	' Module: SpeechStringConstants
	' IID: {E58442E4-0C80-402C-9559-867337A39765}
	' Documentation string: ISpeechLexiconPronunciation Interface
	' Number of Constants: 36
	Const SpeechRegistryUserRoot = WStr("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech")
	Const SpeechRegistryLocalMachineRoot = WStr("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech")
	Const SpeechCategoryAudioOut = WStr("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\AudioOutput")
	Const SpeechCategoryAudioIn = WStr("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\AudioInput")
	Const SpeechCategoryVoices = WStr("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\Voices")
	Const SpeechCategoryRecognizers = WStr("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\Recognizers")
	Const SpeechCategoryAppLexicons = WStr("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\AppLexicons")
	Const SpeechCategoryPhoneConverters = WStr("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\PhoneConverters")
	Const SpeechCategoryRecoProfiles = WStr("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech\RecoProfiles")
	Const SpeechTokenIdUserLexicon = WStr("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech\CurrentUserLexicon")
	Const SpeechTokenValueCLSID = WStr("CLSID")
	Const SpeechTokenKeyFiles = WStr("Files")
	Const SpeechTokenKeyUI = WStr("UI")
	Const SpeechTokenKeyAttributes = WStr("Attributes")
	Const SpeechVoiceCategoryTTSRate = WStr("DefaultTTSRate")
	Const SpeechPropertyResourceUsage = WStr("ResourceUsage")
	Const SpeechPropertyHighConfidenceThreshold = WStr("HighConfidenceThreshold")
	Const SpeechPropertyNormalConfidenceThreshold = WStr("NormalConfidenceThreshold")
	Const SpeechPropertyLowConfidenceThreshold = WStr("LowConfidenceThreshold")
	Const SpeechPropertyResponseSpeed = WStr("ResponseSpeed")
	Const SpeechPropertyComplexResponseSpeed = WStr("ComplexResponseSpeed")
	Const SpeechPropertyAdaptationOn = WStr("AdaptationOn")
	Const SpeechDictationTopicSpelling = WStr("Spelling")
	Const SpeechGrammarTagWildcard = WStr("...")
	Const SpeechGrammarTagDictation = WStr("*")
	Const SpeechGrammarTagUnlimitedDictation = WStr("*+")
	Const SpeechEngineProperties = WStr("EngineProperties")
	Const SpeechAddRemoveWord = WStr("AddRemoveWord")
	Const SpeechUserTraining = WStr("UserTraining")
	Const SpeechMicTraining = WStr("MicTraining")
	Const SpeechRecoProfileProperties = WStr("RecoProfileProperties")
	Const SpeechAudioProperties = WStr("AudioProperties")
	Const SpeechAudioVolume = WStr("AudioVolume")
	Const SpeechVoiceSkipTypeSentence = WStr("Sentence")
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
	
	
	' Structures and unions
	
	Type SPAUDIOBUFFERINFO
		' Documentation string: ISpAudio Interface
		' Number of members: 3
		ulMsMinNotification As ULong
		ulMsBufferSize As ULong
		ulMsEventBias As ULong
	End Type
	
	Type SPAUDIOSTATUS
		' Documentation string: ISpAudio Interface
		' Number of members: 7
		cbFreeBuffSpace As Long
		cbNonBlockingIO As ULong
		State As ULong
		CurSeekPos As ULongInt
		CurDevicePos As ULongInt
		dwAudioLevel As ULong
		dwReserved2 As ULong
	End Type
	
	Type SPBINARYGRAMMAR
		' Documentation string: ISpGrammarBuilder Interface
		' Number of members: 1
		ulTotalSerializedSize As ULong
	End Type
	
	Type SPEVENT
		' Documentation string: ISpNotifySource Interface
		' Number of members: 6
		eEventId As UShort
		elParamType As UShort
		ulStreamNum As ULong
		ullAudioStreamOffset As ULongInt
		wParam As ULongInt
		lParam As ULongInt
	End Type
	
	' Size = 24 bytes
	Type SPEVENTSOURCEINFO
		' Documentation string: ISpNotifySource Interface
		' Number of members: 3
		ullEventInterest As ULongInt
		ullQueuedInterest As ULongInt
		ulCount As ULong
	End Type
	
	Type SPPHRASE
		' Documentation string: ISpPhrase Interface
		' Number of members: 20
		cbSize As ULong
		LangId As UShort
		wHomophoneGroupId As UShort
		ullGrammarID As ULongInt
		ftStartTime As ULongInt
		ullAudioStreamPosition As ULongInt
		ulAudioSizeBytes As ULong
		ulRetainedSizeBytes As ULong
		ulAudioSizeTime As ULong
		Rule As ULong
		pProperties As ULong Ptr
		pElements As ULong Ptr Ptr
		cReplacements As ULong
		pReplacements As ULong Ptr
		SREngineID As ULong Ptr
		ulSREnginePrivateDataSize As ULong
		pSREnginePrivateData As UByte Ptr
		pSML As WString Ptr
		pSemanticErrorInfo As WString Ptr
		SemanticTagFormat As SPSEMANTICFORMAT
	End Type
	
	' Size = 44 bytes
	Type SPPHRASEELEMENT
		' Documentation string: ISpPhrase Interface
		' Number of members: 14
		ulAudioTimeOffset As ULong
		ulAudioSizeTime As ULong
		ulAudioStreamOffset As ULong
		ulAudioSizeBytes As ULong
		ulRetainedStreamOffset As ULong
		ulRetainedSizeBytes As ULong
		pszDisplayText As WCHAR Ptr   ' Const WCHAR *
		pszLexicalForm As WCHAR Ptr   ' Const WCHAR *
		pszPronunciation As WCHAR Ptr ' Const SPPHONEID *
		bDisplayAttributes As UByte
		RequiredConfidence As Byte
		ActualConfidence As Byte
		reserved As UByte
		SREngineConfidence As Single
	End Type
	
	' Size = 56 bytes (in 32-bit)
	Type SPPHRASEPROPERTY   ' Must be 8 byte aligned
		' Documentation string: ISpPhrase Interface
		' Number of members: 10
		pszName As WString Ptr
		Union
			ulId As ULong
			Type
				bType As UByte
				bReserved As UByte
				usArrayIndex As UShort
			End Type
		End Union
		pszValue As WString Ptr
		vValue As VARIANT
		ulFirstElement As ULong
		ulCountOfElements As ULong
		pNextSibling As SPPHRASEPROPERTY Ptr   ' Const SPPHRASEPROPERTY *
		pFirstChild As SPPHRASEPROPERTY Ptr   ' Const SPPHRASEPROPERTY *
		SREngineConfidence As Single
		Confidence As Byte
	End Type
	
	Type SPPHRASEREPLACEMENT
		' Documentation string: ISpPhrase Interface
		' Number of members: 4
		bDisplayAttributes As UByte
		pszReplacementText As WCHAR Ptr   ' Const WCHAR *
		ulFirstElement As ULong
		ulCountOfElements As ULong
	End Type
	
	' Size = 32 bytes
	Type SPPHRASERULE
		' Documentation string: ISpPhrase Interface
		' Number of members: 8
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
		' Documentation string: ISpGrammarBuilder Interface
		' Number of members: 4
		eInterference As SPINTERFERENCE
		szRequestTypeOfUI (0 To 254) As WCHAR
		dwReserved1 As DWORD
		dwReserved2 As DWORD
	End Type
	
	Type SPRECOGNIZERSTATUS
		' Documentation string: ISpProperties Interface
		' Number of members: 8
		AudioStatus As SPAUDIOSTATUS
		ullRecognitionStreamPos As ULONGLONG
		ulStreamNumber As ULong
		ulNumActive As ULong
		ClsidEngine As ULong
		cLangIDs As ULong
		aLangID (0 To 19) As LANGID
		ullRecognitionStreamTime As ULONGLONG
	End Type
	
	Type SPRECORESULTTIMES
		' Documentation string: ISpRecoResult Interface
		' Number of members: 4
		ftStreamTime As FILETIME
		ullLength As ULongInt
		dwTickCount As ULong
		ullStart As ULongInt
	End Type
	
	Type SPRULE
		' Documentation string: ISpRecoGrammar2 Interface
		' Number of members: 3
		pszRuleName As WString Ptr
		ulRuleId As ULong
		dwAttributes As ULong
	End Type
	
	Type SPSEMANTICERRORINFO
		' Documentation string: ISpPhrase Interface
		' Number of members: 5
		ulLineNumber As ULong
		pszScriptLine As WString Ptr
		pszSource As WString Ptr
		pszDescription As WString Ptr
		hrResultCode As HRESULT
	End Type
	
	Type SPSERIALIZEDPHRASE
		' Documentation string: ISpPhrase Interface
		' Number of members: 1
		ulSerializedSize As ULong
	End Type
	
	Type SPSERIALIZEDRESULT
		' Documentation string: ISpGrammarBuilder Interface
		' Number of members: 1
		ulSerializedSize As ULong
	End Type
	
	Type SPSHORTCUTPAIR
		' Documentation string: ISpShortcut Interface
		' Number of members: 5
		pNextSHORTCUTPAIR As SPSHORTCUTPAIR Ptr
		LangId As UShort
		shType As SPSHORTCUTType
		pszDisplay As WString Ptr
		pszSpoken As WString Ptr
	End Type
	
	Type SPSHORTCUTPAIRLIST
		' Documentation string: ISpShortcut Interface
		' Number of members: 3
		ulSize As ULong
		pvBuffer As UByte Ptr
		pFirstShortcutPair As SPSHORTCUTPAIR Ptr
	End Type
	
	Type SPVOICESTATUS
		' Documentation string: ISpVoice Interface
		' Number of members: 13
		ulCurrentStream As ULong
		ulLastStreamQueued As ULong
		hrLastResult As HRESULT
		dwRunningState As ULong
		ulInputWordPos As ULong
		ulInputWordLen As ULong
		ulInputSentPos As ULong
		ulInputSentLen As ULong
		lBookmarkId As Long
		PhonemeId As UShort   ' SPPHONEID
		VisemeId As SPVISEMES
		dwReserved1 As DWORD
		dwReserved2 As DWORD
	End Type
	
	Type SPWORDPRONUNCIATION
		' Documentation string: ISpLexicon Interface
		' Number of members: 6
		pNextWordPronunciation As SPWORDPRONUNCIATION Ptr   ' struct SPWORDPRONUNCIATION *
		eLexiconType As SPLEXICONType   ' SPLEXICONType enum
		LangId As LANGID
		wPronunciationFlags As WORD
		ePartOfSpeech As SPPARTOFSPEECH   ' SPPARTOFSPEECH enum
		szPronunciation (0 To 0) As WCHAR   ' SPPHONEID szPronunciation[ 1 ]
	End Type
	
	Type SPWORD
		' Documentation string: ISpLexicon Interface
		' Number of members: 6
		pNextWord As SPWORD Ptr
		LangId As UShort
		wReserved As UShort
		eWordType As SPWORDType
		pszWord As WString Ptr
		pFirstWordPronunciation As SPWORDPRONUNCIATION Ptr
	End Type
	
	Type SPWORDLIST
		' Documentation string: ISpLexicon Interface
		' Number of members: 3
		ulSize As ULong
		pvBuffer As UByte Ptr
		pFirstWord As SPWORD Ptr
	End Type
	
	Type SPWORDPRONUNCIATIONLIST
		' Documentation string: ISpLexicon Interface
		' Number of members: 3
		ulSize As ULong
		pvBuffer As UByte Ptr
		pFirstWordPronunciation As SPWORDPRONUNCIATION Ptr
	End Type
	
	Type tagSPPROPERTYINFO
		' Documentation string: ISpGrammarBuilder Interface
		' Number of members: 4
		pszName As WCHAR Ptr   ' Const WCHAR *
		ulId As ULong
		pszValue As WCHAR Ptr   ' Const WCHAR *
		vValue As VARIANT
	End Type
	
	Type tagSPTEXTSELECTIONINFO
		' Documentation string: ISpGrammarBuilder Interface
		' Number of members: 4
		ulStartActiveOffset As ULong
		cchActiveChars As ULong
		ulStartSelection As ULong
		cchSelection As ULong
	End Type
	
	Type tagSTATSTG
		' Documentation string: ISpStreamFormat Interface
		' Number of members: 11
		pwcsName As WString Ptr
		Type As ULong
		cbSize As ULong
		mtime As ULong
		ctime As ULong
		atime As ULong
		grfMode As ULong
		grfLocksSupported As ULong
		clsid As ULong
		grfStateBits As ULong
		reserved As ULong
	End Type
	
	Type WaveFormatEx
		' Documentation string: ISpStreamFormat Interface
		' Number of members: 7
		wFormatTag As UShort
		nChannels As UShort
		nSamplesPerSec As ULong
		nAvgBytesPerSec As ULong
		nBlockAlign As UShort
		wBitsPerSample As UShort
		cbSize As UShort
	End Type
	
	
	' Interfaces - Forward references
	
	Type IEnumSpObjectTokens As IEnumSpObjectTokens_
	Type ISpAudio As ISpAudio_
	Type ISpDataKey As ISpDataKey_
	Type ISpEventSink As ISpEventSink_
	Type ISpEventSource As ISpEventSource_
	Type ISpGrammarBuilder As ISpGrammarBuilder_
	Type ISpLexicon As ISpLexicon_
	Type ISpMMSysAudio As ISpMMSysAudio_
	Type ISpNotifySink As ISpNotifySink_
	Type ISpNotifySource As ISpNotifySource_
	Type ISpNotifyTranslator As ISpNotifyTranslator_
	Type ISpObjectToken As ISpObjectToken_
	Type ISpObjectTokenCategory As ISpObjectTokenCategory_
	Type ISpObjectWithToken As ISpObjectWithToken_
	Type ISpPhoneConverter As ISpPhoneConverter_
	Type ISpPhoneticAlphabetConverter As ISpPhoneticAlphabetConverter_
	Type ISpPhoneticAlphabetSelection As ISpPhoneticAlphabetSelection_
	Type ISpPhrase As ISpPhrase_
	Type ISpPhraseAlt As ISpPhraseAlt_
	Type ISpProperties As ISpProperties_
	Type ISpRecoCategory As ISpRecoCategory_
	Type ISpRecoContext As ISpRecoContext_
	Type ISpRecoContext2 As ISpRecoContext2_
	Type ISpRecognizer As ISpRecognizer_
	Type ISpRecognizer2 As ISpRecognizer2_
	Type ISpRecognizer3 As ISpRecognizer3_
	Type ISpRecoGrammar As ISpRecoGrammar_
	Type ISpRecoGrammar2 As ISpRecoGrammar2_
	Type ISpRecoResult As ISpRecoResult_
	Type ISpResourceManager As ISpResourceManager_
	Type ISpSerializeState As ISpSerializeState_
	Type ISpShortcut As ISpShortcut_
	Type ISpStream As ISpStream_
	Type ISpStreamFormat As ISpStreamFormat_
	Type ISpStreamFormatConverter As ISpStreamFormatConverter_
	Type ISpVoice As ISpVoice_
	Type ISpXMLRecoResult As ISpXMLRecoResult_
	
	' Dual interfaces - Forward references
	
	Type ISpeechAudio As ISpeechAudio_
	Type ISpeechAudioBufferInfo As ISpeechAudioBufferInfo_
	Type ISpeechAudioFormat As ISpeechAudioFormat_
	Type ISpeechAudioStatus As ISpeechAudioStatus_
	Type ISpeechBaseStream As ISpeechBaseStream_
	Type ISpeechCustomStream As ISpeechCustomStream_
	Type ISpeechDataKey As ISpeechDataKey_
	Type ISpeechFileStream As ISpeechFileStream_
	Type ISpeechGrammarRule As ISpeechGrammarRule_
	Type ISpeechGrammarRules As ISpeechGrammarRules_
	Type ISpeechGrammarRuleState As ISpeechGrammarRuleState_
	Type ISpeechGrammarRuleStateTransition As ISpeechGrammarRuleStateTransition_
	Type ISpeechGrammarRuleStateTransitions As ISpeechGrammarRuleStateTransitions_
	Type ISpeechLexicon As ISpeechLexicon_
	Type ISpeechLexiconPronunciation As ISpeechLexiconPronunciation_
	Type ISpeechLexiconPronunciations As ISpeechLexiconPronunciations_
	Type ISpeechLexiconWord As ISpeechLexiconWord_
	Type ISpeechLexiconWords As ISpeechLexiconWords_
	Type ISpeechMemoryStream As ISpeechMemoryStream_
	Type ISpeechMMSysAudio As ISpeechMMSysAudio_
	Type ISpeechObjectToken As ISpeechObjectToken_
	Type ISpeechObjectTokenCategory As ISpeechObjectTokenCategory_
	Type ISpeechObjectTokens As ISpeechObjectTokens_
	Type ISpeechPhoneConverter As ISpeechPhoneConverter_
	Type ISpeechPhraseAlternate As ISpeechPhraseAlternate_
	Type ISpeechPhraseAlternates As ISpeechPhraseAlternates_
	Type ISpeechPhraseElement As ISpeechPhraseElement_
	Type ISpeechPhraseElements As ISpeechPhraseElements_
	Type ISpeechPhraseInfo As ISpeechPhraseInfo_
	Type ISpeechPhraseInfoBuilder As ISpeechPhraseInfoBuilder_
	Type ISpeechPhraseProperties As ISpeechPhraseProperties_
	Type ISpeechPhraseProperty As ISpeechPhraseProperty_
	Type ISpeechPhraseReplacement As ISpeechPhraseReplacement_
	Type ISpeechPhraseReplacements As ISpeechPhraseReplacements_
	Type ISpeechPhraseRule As ISpeechPhraseRule_
	Type ISpeechPhraseRules As ISpeechPhraseRules_
	Type ISpeechRecoContext As ISpeechRecoContext_
	Type ISpeechRecognizer As ISpeechRecognizer_
	Type ISpeechRecognizerStatus As ISpeechRecognizerStatus_
	Type ISpeechRecoGrammar As ISpeechRecoGrammar_
	Type ISpeechRecoResult As ISpeechRecoResult_
	Type ISpeechRecoResult2 As ISpeechRecoResult2_
	Type ISpeechRecoResultDispatch As ISpeechRecoResultDispatch_
	Type ISpeechRecoResultTimes As ISpeechRecoResultTimes_
	Type ISpeechResourceLoader As ISpeechResourceLoader_
	Type ISpeechTextSelectionInformation As ISpeechTextSelectionInformation_
	Type ISpeechVoice As ISpeechVoice_
	Type ISpeechVoiceStatus As ISpeechVoiceStatus_
	Type ISpeechWaveFormatEx As ISpeechWaveFormatEx_
	Type ISpeechXMLRecoResult As ISpeechXMLRecoResult_
	
	' Interfaces
	
	' ########################################################################################
	' Interface name: IEnumSpObjectTokens
	' IID: {06B64F9E-7FDA-11D2-B4F2-00C04F797396}
	' Documentation string: IEnumSpObjectTokens Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 6
	' ########################################################################################
	
	#ifndef __IEnumSpObjectTokens_INTERFACE_DEFINED__
		#define __IEnumSpObjectTokens_INTERFACE_DEFINED__
		
		Type IEnumSpObjectTokens_ Extends Afx_IUnknown
			Declare Abstract Function Next_ (ByVal celt As ULong, ByVal pelt As ISpObjectToken Ptr Ptr, ByVal pceltFetched As ULong Ptr) As HRESULT
			Declare Abstract Function Skip (ByVal celt As ULong) As HRESULT
			Declare Abstract Function Reset () As HRESULT
			Declare Abstract Function Clone (ByVal ppEnum As IEnumSpObjectTokens Ptr Ptr) As HRESULT
			Declare Abstract Function Item (ByVal Index As ULong, ByVal ppToken As ISpObjectToken Ptr Ptr) As HRESULT
			Declare Abstract Function GetCount (ByVal pCount As ULong Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpStreamFormat
	' IID: {BED530BE-2606-4F4D-A1C0-54C5CDA5566F}
	' Documentation string: ISpStreamFormat Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IStream
	' Number of methods = 1
	' ########################################################################################
	
	#ifndef __ISpStreamFormat_INTERFACE_DEFINED__
		#define __ISpStreamFormat_INTERFACE_DEFINED__
		
		Type ISpStreamFormat_ Extends Afx_IUnknown
			' ISequentialStream interface
			Declare Abstract Function Read (ByVal pv As Const Any Ptr, ByVal cb As ULong, ByVal pcbRead As ULong Ptr) As HRESULT
			Declare Abstract Function Write (ByVal pv As Const Any Ptr, ByVal cb As ULong, ByVal pcbWritten As ULong Ptr) As HRESULT
			' IStream interface
			Declare Abstract Function Seek (ByVal dlibMove As _LARGE_INTEGER, ByVal dwOrigin As ULong, ByVal plibNewPosition As _ULARGE_INTEGER Ptr) As HRESULT
			Declare Abstract Function SetSize (ByVal libNewSize As _ULARGE_INTEGER) As HRESULT
			Declare Abstract Function CopyTo (ByVal pstm As IStream Ptr, ByVal cb As _ULARGE_INTEGER, ByVal pcbRead As _ULARGE_INTEGER Ptr, ByVal pcbWritten As _ULARGE_INTEGER Ptr) As HRESULT
			Declare Abstract Function Commit (ByVal grfCommitFlags As ULong) As HRESULT
			Declare Abstract Function Revert () As HRESULT
			Declare Abstract Function LockRegion (ByVal libOffset As _ULARGE_INTEGER, ByVal cb As _ULARGE_INTEGER, ByVal dwLockType As ULong) As HRESULT
			Declare Abstract Function UnlockRegion (ByVal libOffset As _ULARGE_INTEGER, ByVal cb As _ULARGE_INTEGER, ByVal dwLockType As ULong) As HRESULT
			Declare Abstract Function Stat (ByVal pstatstg As tagSTATSTG Ptr, ByVal grfStatFlag As ULong) As HRESULT
			Declare Abstract Function Clone (ByVal ppstm As IStream Ptr Ptr) As HRESULT
			' ISpStreamFormat iterface
			Declare Abstract Function GetFormat (ByVal pguidFormatId As GUID Ptr, ByVal ppCoMemWaveFormatEx As WaveFormatEx Ptr Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpAudio
	' IID: {C05C768F-FAE8-4EC2-8E07-338321C12452}
	' Documentation string: ISpAudio Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = ISpStreamFormat
	' Number of methods = 11
	' ########################################################################################
	
	#ifndef __ISpAudio_INTERFACE_DEFINED__
		#define __ISpAudio_INTERFACE_DEFINED__
		
		Type ISpAudio_ Extends ISpStreamFormat
			Declare Abstract Function SetState (ByVal NewState As SPAUDIOSTATE, ByVal ullReserved As ULongInt) As HRESULT
			Declare Abstract Function SetFormat (ByVal rguidFmtId As GUID Ptr, ByVal pWaveFormatEx As WaveFormatEx Ptr) As HRESULT
			Declare Abstract Function GetStatus (ByVal pStatus As SPAUDIOSTATUS Ptr) As HRESULT
			Declare Abstract Function SetBufferInfo (ByVal pBuffInfo As SPAUDIOBUFFERINFO Ptr) As HRESULT
			Declare Abstract Function GetBufferInfo (ByVal pBuffInfo As SPAUDIOBUFFERINFO Ptr) As HRESULT
			Declare Abstract Function GetDefaultFormat (ByVal pFormatId As GUID Ptr, ByVal ppCoMemWaveFormatEx As WaveFormatEx Ptr Ptr) As HRESULT
			Declare Abstract Function EventHandle () As HRESULT
			Declare Abstract Function GetVolumeLevel (ByVal pLevel As ULong Ptr) As HRESULT
			Declare Abstract Function SetVolumeLevel (ByVal Level As ULong) As HRESULT
			Declare Abstract Function GetBufferNotifySize (ByVal pcbSize As ULong Ptr) As HRESULT
			Declare Abstract Function SetBufferNotifySize (ByVal cbSize As ULong) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpDataKey
	' IID: {14056581-E16C-11D2-BB90-00C04F8EE6C0}
	' Documentation string: ISpDataKey Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 12
	' ########################################################################################
	
	#ifndef __ISpDataKey_INTERFACE_DEFINED__
		#define __ISpDataKey_INTERFACE_DEFINED__
		
		Type ISpDataKey_ Extends Afx_IUnknown
			Declare Abstract Function SetData (ByVal pszValueName As WString Ptr, ByVal cbData As ULong, ByVal pData As UByte Ptr) As HRESULT
			Declare Abstract Function GetData (ByVal pszValueName As WString Ptr, ByVal pcbData As ULong Ptr, ByVal pData As UByte Ptr) As HRESULT
			Declare Abstract Function SetStringValue (ByVal pszValueName As WString Ptr, ByVal pszValue As WString Ptr) As HRESULT
			Declare Abstract Function GetStringValue (ByVal pszValueName As WString Ptr, ByVal ppszValue As WString Ptr Ptr) As HRESULT
			Declare Abstract Function SetDWORD (ByVal pszValueName As WString Ptr, ByVal dwValue As ULong) As HRESULT
			Declare Abstract Function GetDWORD (ByVal pszValueName As WString Ptr, ByVal pdwValue As ULong Ptr) As HRESULT
			Declare Abstract Function OpenKey (ByVal pszSubKeyName As WString Ptr, ByVal ppSubKey As ISpDataKey Ptr Ptr) As HRESULT
			Declare Abstract Function CreateKey (ByVal pszSubKey As WString Ptr, ByVal ppSubKey As ISpDataKey Ptr Ptr) As HRESULT
			Declare Abstract Function DeleteKey (ByVal pszSubKey As WString Ptr) As HRESULT
			Declare Abstract Function DeleteValue (ByVal pszValueName As WString Ptr) As HRESULT
			Declare Abstract Function EnumKeys (ByVal Index As ULong, ByVal ppszSubKeyName As WString Ptr Ptr) As HRESULT
			Declare Abstract Function EnumValues (ByVal Index As ULong, ByVal ppszValueName As WString Ptr Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpEventSink
	' IID: {BE7A9CC9-5F9E-11D2-960F-00C04F8EE628}
	' Documentation string: ISpEventSink Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __ISpEventSink_INTERFACE_DEFINED__
		#define __ISpEventSink_INTERFACE_DEFINED__
		
		Type ISpEventSink_ Extends Afx_IUnknown
			Declare Abstract Function AddEvents (ByVal pEventArray As SPEVENT Ptr, ByVal ulCount As ULong) As HRESULT
			Declare Abstract Function GetEventInterest (ByVal pullEventInterest As ULongInt Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	
	
	' ########################################################################################
	' Interface name: ISpNotifySource
	' IID: {5EFF4AEF-8487-11D2-961C-00C04F8EE628}
	' Documentation string: ISpNotifySource Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 7
	' ########################################################################################
	
	#ifndef __ISpNotifySource_INTERFACE_DEFINED__
		#define __ISpNotifySource_INTERFACE_DEFINED__
		
		Type ISpNotifySource_ Extends Afx_IUnknown
			Declare Abstract Function SetNotifySink (ByVal pNotifySink AS ISpNotifySink Ptr) AS HRESULT
			Declare Abstract Function SetNotifyWindowMessage (ByVal hWnd AS HWND, ByVal Msg AS UINT, ByVal wParam AS UINT_Ptr, ByVal lParam AS Long_Ptr) AS HRESULT
			Declare Abstract Function SetNotifyCallbackFunction (ByVal pfnCallback AS ANY Ptr Ptr, ByVal wParam AS UINT_Ptr, ByVal lParam AS Long_Ptr) AS HRESULT
			Declare Abstract Function SetNotifyCallbackInterface (ByVal pSpCallback AS ANY Ptr Ptr, ByVal wParam AS UINT_Ptr, ByVal lParam AS Long_Ptr) AS HRESULT
			Declare Abstract Function SetNotifyWin32Event () AS HRESULT
			Declare Abstract Function WaitForNotifyEvent (ByVal dwMilliseconds AS ULong) AS HRESULT
			Declare Abstract Function GetNotifyEventHandle () AS HRESULT
		END Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpEventSource
	' IID: {BE7A9CCE-5F9E-11D2-960F-00C04F8EE628}
	' Documentation string: ISpEventSource Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = ISpNotifySource
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __ISpEventSource_INTERFACE_DEFINED__
		#define __ISpEventSource_INTERFACE_DEFINED__
		
		Type ISpEventSource_ Extends ISpNotifySource
			Declare Abstract Function SetInterest (ByVal ullEventInterest As ULongInt, ByVal ullQueuedInterest As ULongInt) As HRESULT
			Declare Abstract Function GetEvents (ByVal ulCount As ULong, ByVal pEventArray As SPEVENT Ptr, ByVal pulFetched As ULong Ptr) As HRESULT
			Declare Abstract Function GetInfo (ByVal pInfo As SPEVENTSOURCEINFO Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpGrammarBuilder
	' IID: {8137828F-591A-4A42-BE58-49EA7EBAAC68}
	' Documentation string: ISpGrammarBuilder Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 8
	' ########################################################################################
	
	#ifndef __ISpGrammarBuilder_INTERFACE_DEFINED__
		#define __ISpGrammarBuilder_INTERFACE_DEFINED__
		
		Type ISpGrammarBuilder_ Extends Afx_IUnknown
			Declare Abstract Function ResetGrammar (ByVal NewLanguage As UShort) As HRESULT
			Declare Abstract Function GetRule (ByVal pszRuleName As WString Ptr, ByVal dwRuleId As ULong, ByVal dwAttributes As ULong, ByVal fCreateIfNotExist As Long, ByVal phInitialState As Any Ptr Ptr) As HRESULT
			Declare Abstract Function ClearRule (ByVal hState As Any Ptr) As HRESULT
			Declare Abstract Function CreateNewState (ByVal hState As Any Ptr, ByVal phState As Any Ptr Ptr) As HRESULT
			Declare Abstract Function AddWordTransition (ByVal hFromState As Any Ptr, ByVal hToState As Any Ptr, ByVal psz As WString Ptr, ByVal pszSeparators As WString Ptr, ByVal eWordType As SPGRAMMARWORDType, ByVal Weight As Single, ByVal pPropInfo As SPPROPERTYINFO Ptr) As HRESULT
			Declare Abstract Function AddRuleTransition (ByVal hFromState As Any Ptr, ByVal hToState As Any Ptr, ByVal hRule As Any Ptr, ByVal Weight As Single, ByVal pPropInfo As SPPROPERTYINFO Ptr) As HRESULT
			Declare Abstract Function AddResource (ByVal hRuleState As Any Ptr, ByVal pszResourceName As WString Ptr, ByVal pszResourceValue As WString Ptr) As HRESULT
			Declare Abstract Function Commit (ByVal dwReserved As ULong) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpLexicon
	' IID: {DA41A7C2-5383-4DB2-916B-6C1719E3DB58}
	' Documentation string: ISpLexicon Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 6
	' ########################################################################################
	
	#ifndef __ISpLexicon_INTERFACE_DEFINED__
		#define __ISpLexicon_INTERFACE_DEFINED__
		
		Type ISpLexicon_ Extends Afx_IUnknown
			Declare Abstract Function GetPronunciations (ByVal pszWord AS WString Ptr, ByVal LangId AS UShort, ByVal dwFlags AS ULong, ByVal pWordPronunciationList AS SPWORDPRONUNCIATIONLIST Ptr) AS HRESULT
			Declare Abstract Function AddPronunciation (ByVal pszWord AS WString Ptr, ByVal LangId AS UShort, ByVal ePartOfSpeech AS SPPARTOFSPEECH, ByVal pszPronunciation AS WString Ptr) AS HRESULT
			Declare Abstract Function RemovePronunciation (ByVal pszWord AS WString Ptr, ByVal LangId AS UShort, ByVal ePartOfSpeech AS SPPARTOFSPEECH, ByVal pszPronunciation AS WString Ptr) AS HRESULT
			Declare Abstract Function GetGeneration (ByVal pdwGeneration AS ULong Ptr) AS HRESULT
			Declare Abstract Function GetGenerationChange (ByVal dwFlags AS ULong, ByVal pdwGeneration AS ULong Ptr, ByVal pWordList AS SPWORDLIST Ptr) AS HRESULT
			Declare Abstract Function GetWords (ByVal dwFlags AS ULong, ByVal pdwGeneration AS ULong Ptr, ByVal pdwCookie AS ULong Ptr, ByVal pWordList AS SPWORDLIST Ptr) AS HRESULT
		END Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpMMSysAudio
	' IID: {15806F6E-1D70-4B48-98E6-3B1A007509AB}
	' Documentation string: ISpMMSysAudio Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = ISpAudio
	' Number of methods = 5
	' ########################################################################################
	
	#ifndef __ISpMMSysAudio_INTERFACE_DEFINED__
		#define __ISpMMSysAudio_INTERFACE_DEFINED__
		
		Type ISpMMSysAudio_ Extends ISpAudio
			Declare Abstract Function GetDeviceId (ByVal puDeviceId As UINT Ptr) As HRESULT
			Declare Abstract Function SetDeviceId (ByVal uDeviceId As UINT) As HRESULT
			Declare Abstract Function GetMMHandle (ByVal pHandle As Any Ptr Ptr) As HRESULT
			Declare Abstract Function GetLineId (ByVal puLineId As UINT Ptr) As HRESULT
			Declare Abstract Function SetLineId (ByVal uLineId As UINT) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpNotifySink
	' IID: {259684DC-37C3-11D2-9603-00C04F8EE628}
	' Documentation string: ISpNotifySink Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 1
	' ########################################################################################
	
	#ifndef __ISpNotifySink_INTERFACE_DEFINED__
		#define __ISpNotifySink_INTERFACE_DEFINED__
		
		Type ISpNotifySink_ Extends Afx_IUnknown
			Declare Abstract Function Notify () As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpNotifyTranslator
	' IID: {ACA16614-5D3D-11D2-960E-00C04F8EE628}
	' Documentation string: ISpNotifyTranslator Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = ISpNotifySink
	' Number of methods = 6
	' ########################################################################################
	
	#ifndef __ISpNotifyTranslator_INTERFACE_DEFINED__
		#define __ISpNotifyTranslator_INTERFACE_DEFINED__
		
		Type ISpNotifyTranslator_ Extends ISpNotifySink
			Declare Abstract Function InitWindowMessage (ByVal hWnd As HWND, ByVal Msg As UINT, ByVal wParam As UINT_PTR, ByVal lParam As LONG_PTR) As HRESULT
			Declare Abstract Function InitCallback (ByVal pfnCallback As Any Ptr Ptr, ByVal wParam As UINT_PTR, ByVal lParam As LONG_PTR) As HRESULT
			Declare Abstract Function InitSpNotifyCallback (ByVal pSpCallback As Any Ptr Ptr, ByVal wParam As UINT_PTR, ByVal lParam As LONG_PTR) As HRESULT
			Declare Abstract Function InitWin32Event (ByVal hEvent As Any Ptr, ByVal fCloseHandleOnRelease As Long) As HRESULT
			Declare Abstract Function Wait (ByVal dwMilliseconds As ULong) As HRESULT
			Declare Abstract Function GetEventHandle () As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpObjectToken
	' IID: {14056589-E16C-11D2-BB90-00C04F8EE6C0}
	' Documentation string: ISpObjectToken Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = ISpDataKey
	' Number of methods = 10
	' ########################################################################################
	
	#ifndef __ISpObjectToken_INTERFACE_DEFINED__
		#define __ISpObjectToken_INTERFACE_DEFINED__
		
		Type ISpObjectToken_ Extends ISpDataKey
			Declare Abstract Function SetId (ByVal pszCategoryId As WString Ptr, ByVal pszTokenId As WString Ptr, ByVal fCreateIfNotExist As Long) As HRESULT
			Declare Abstract Function GetId (ByVal ppszCoMemTokenId As WString Ptr Ptr) As HRESULT
			Declare Abstract Function GetCategory (ByVal ppTokenCategory As ISpObjectTokenCategory Ptr Ptr) As HRESULT
			Declare Abstract Function CreateInstance (ByVal pUnkOuter As Afx_IUnknown Ptr, ByVal dwClsContext As ULong, ByVal riid As GUID Ptr, ByVal ppvObject As Any Ptr Ptr) As HRESULT
			Declare Abstract Function GetStorageFileName (ByVal clsidCaller As GUID Ptr, ByVal pszValueName As WString Ptr, ByVal pszFileNameSpecifier As WString Ptr, ByVal nFolder As ULong, ByVal ppszFilePath As WString Ptr Ptr) As HRESULT
			Declare Abstract Function RemoveStorageFileName (ByVal clsidCaller As GUID Ptr, ByVal pszKeyName As WString Ptr, ByVal fDeleteFile As Long) As HRESULT
			Declare Abstract Function Remove (ByVal pclsidCaller As GUID Ptr) As HRESULT
			Declare Abstract Function IsUISupported (ByVal pszTypeOfUI As WString Ptr, ByVal pvExtraData As Any Ptr, ByVal cbExtraData As ULong, ByVal punkObject As Afx_IUnknown Ptr, ByVal pfSupported As Long Ptr) As HRESULT
			Declare Abstract Function DisplayUI (ByVal hWndParent As HWND, ByVal pszTitle As WString Ptr, ByVal pszTypeOfUI As WString Ptr, ByVal pvExtraData As Any Ptr, ByVal cbExtraData As ULong, ByVal punkObject As Afx_IUnknown Ptr) As HRESULT
			Declare Abstract Function MatchesAttributes (ByVal pszAttributes As WString Ptr, ByVal pfMatches As Long Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpObjectTokenCategory
	' IID: {2D3D3845-39AF-4850-BBF9-40B49780011D}
	' Documentation string: ISpObjectTokenCategory
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = ISpDataKey
	' Number of methods = 6
	' ########################################################################################
	
	#ifndef __ISpObjectTokenCategory_INTERFACE_DEFINED__
		#define __ISpObjectTokenCategory_INTERFACE_DEFINED__
		
		Type ISpObjectTokenCategory_ Extends ISpDataKey
			Declare Abstract Function SetId (ByVal pszCategoryId As WString Ptr, ByVal fCreateIfNotExist As Long) As HRESULT
			Declare Abstract Function GetId (ByVal ppszCoMemCategoryId As WString Ptr Ptr) As HRESULT
			Declare Abstract Function GetDataKey (ByVal spdkl As SPDATAKEYLOCATION, ByVal ppDataKey As ISpDataKey Ptr Ptr) As HRESULT
			Declare Abstract Function EnumTokens (ByVal pzsReqAttribs As WString Ptr, ByVal pszOptAttribs As WString Ptr, ByVal ppEnum As IEnumSpObjectTokens Ptr Ptr) As HRESULT
			Declare Abstract Function SetDefaultTokenId (ByVal pszTokenId As WString Ptr) As HRESULT
			Declare Abstract Function GetDefaultTokenId (ByVal ppszCoMemTokenId As WString Ptr Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpObjectWithToken
	' IID: {5B559F40-E952-11D2-BB91-00C04F8EE6C0}
	' Documentation string: ISpObjectWithToken Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __ISpObjectWithToken_INTERFACE_DEFINED__
		#define __ISpObjectWithToken_INTERFACE_DEFINED__
		
		Type ISpObjectWithToken_ Extends Afx_IUnknown
			Declare Abstract Function SetObjectToken (ByVal pToken As ISpObjectToken Ptr) As HRESULT
			Declare Abstract Function GetObjectToken (ByVal ppToken As ISpObjectToken Ptr Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpPhoneConverter
	' IID: {8445C581-0CAC-4A38-ABFE-9B2CE2826455}
	' Documentation string: ISpPhoneConverter Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = ISpObjectWithToken
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __ISpPhoneConverter_INTERFACE_DEFINED__
		#define __ISpPhoneConverter_INTERFACE_DEFINED__
		
		Type ISpPhoneConverter_ Extends ISpObjectWithToken
			Declare Abstract Function PhoneToId (ByVal pszPhone As WString Ptr, ByVal pId As UShort Ptr) As HRESULT
			Declare Abstract Function IdToPhone (ByVal pId As WString Ptr, ByVal pszPhone As UShort Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpPhoneticAlphabetConverter
	' IID: {133ADCD4-19B4-4020-9FDC-842E78253B17}
	' Documentation string: ISpPhoneticAlphabetConverter Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 5
	' ########################################################################################
	
	#ifndef __ISpPhoneticAlphabetConverter_INTERFACE_DEFINED__
		#define __ISpPhoneticAlphabetConverter_INTERFACE_DEFINED__
		
		Type ISpPhoneticAlphabetConverter_ Extends Afx_IUnknown
			Declare Abstract Function GetLangId (ByVal pLangID As UShort Ptr) As HRESULT
			Declare Abstract Function SetLangId (ByVal LangId As UShort) As HRESULT
			Declare Abstract Function SAPI2UPS (ByVal pszSAPIId As UShort Ptr, ByVal pszUPSId As UShort Ptr, ByVal cMaxLength As ULong) As HRESULT
			Declare Abstract Function UPS2SAPI (ByVal pszUPSId As UShort Ptr, ByVal pszSAPIId As UShort Ptr, ByVal cMaxLength As ULong) As HRESULT
			Declare Abstract Function GetMaxConvertLength (ByVal cSrcLength As ULong, ByVal bSAPI2UPS As Long, ByVal pcMaxDestLength As ULong Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpPhoneticAlphabetSelection
	' IID: {B2745EFD-42CE-48CA-81F1-A96E02538A90}
	' Documentation string: ISpPhoneticAlphabetSelection Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __ISpPhoneticAlphabetSelection_INTERFACE_DEFINED__
		#define __ISpPhoneticAlphabetSelection_INTERFACE_DEFINED__
		
		Type ISpPhoneticAlphabetSelection_ Extends Afx_IUnknown
			Declare Abstract Function IsAlphabetUPS (ByVal pfIsUPS As Long Ptr) As HRESULT
			Declare Abstract Function SetAlphabetToUPS (ByVal fForceUPS As Long) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpPhrase
	' IID: {1A5C0354-B621-4B5A-8791-D306ED379E53}
	' Documentation string: ISpPhrase Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 4
	' ########################################################################################
	
	#ifndef __ISpPhrase_INTERFACE_DEFINED__
		#define __ISpPhrase_INTERFACE_DEFINED__
		
		Type ISpPhrase_ Extends Afx_IUnknown
			Declare Abstract Function GetPhrase (ByVal ppCoMemPhrase AS SPPHRASE Ptr Ptr) AS HRESULT
			Declare Abstract Function GetSerializedPhrase (ByVal ppCoMemPhrase AS SPSERIALIZEDPHRASE Ptr Ptr) AS HRESULT
			Declare Abstract Function GetText (ByVal ulStart AS ULong, ByVal ulCount AS ULong, ByVal fUseTextReplacements AS Long, ByVal ppszCoMemText AS WString Ptr Ptr, ByVal pbDisplayAttributes AS UBYTE Ptr = NULL) AS HRESULT
			Declare Abstract Function Discard (ByVal dwValueTypes AS ULong) AS HRESULT
		END Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpPhraseAlt
	' IID: {8FCEBC98-4E49-4067-9C6C-D86A0E092E3D}
	' Documentation string: ISpPhraseAlt Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = ISpPhrase
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __ISpPhraseAlt_INTERFACE_DEFINED__
		#define __ISpPhraseAlt_INTERFACE_DEFINED__
		
		Type ISpPhraseAlt_ Extends ISpPhrase
			Declare Abstract Function GetAltInfo (ByVal ppParent AS ISpPhrase Ptr Ptr, ByVal pulStartElementInParent AS ULong Ptr, ByVal pcElementsInParent AS ULong Ptr, ByVal pcElementsInAlt AS ULong Ptr) AS HRESULT
			Declare Abstract Function Commit () AS HRESULT
		END Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpProperties
	' IID: {5B4FB971-B115-4DE1-AD97-E482E3BF6EE4}
	' Documentation string: ISpProperties Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 4
	' ########################################################################################
	
	#ifndef __ISpProperties_INTERFACE_DEFINED__
		#define __ISpProperties_INTERFACE_DEFINED__
		
		Type ISpProperties_ Extends Afx_IUnknown
			Declare Abstract Function SetPropertyNum (ByVal pName As WString Ptr, ByVal lValue As Long) As HRESULT
			Declare Abstract Function GetPropertyNum (ByVal pName As WString Ptr, ByVal plValue As Long Ptr) As HRESULT
			Declare Abstract Function SetPropertyString (ByVal pName As WString Ptr, ByVal pValue As WString Ptr) As HRESULT
			Declare Abstract Function GetPropertyString (ByVal pName As WString Ptr, ByVal ppCoMemValue As WString Ptr Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpRecoCategory
	' IID: {DA0CD0F9-14A2-4F09-8C2A-85CC48979345}
	' Documentation string: ISpRecoCategory Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 1
	' ########################################################################################
	
	#ifndef __ISpRecoCategory_INTERFACE_DEFINED__
		#define __ISpRecoCategory_INTERFACE_DEFINED__
		
		Type ISpRecoCategory_ Extends Afx_IUnknown
			Declare Abstract Function GetType (ByVal peCategoryType As SPCATEGORYType Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpRecoContext
	' IID: {F740A62F-7C15-489E-8234-940A33D9272D}
	' Documentation string: ISpRecoContext Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = ISpEventSource
	' Number of methods = 18
	' ########################################################################################
	
	#ifndef __ISpRecoContext_INTERFACE_DEFINED__
		#define __ISpRecoContext_INTERFACE_DEFINED__
		
		Type ISpRecoContext_ Extends ISpEventSource
			Declare Abstract Function GetRecognizer (ByVal ppRecognizer As ISpRecognizer Ptr Ptr) As HRESULT
			Declare Abstract Function CreateGrammar (ByVal ullGrammarID As ULongInt, ByVal ppGrammar As ISpRecoGrammar Ptr Ptr) As HRESULT
			Declare Abstract Function GetStatus (ByVal pStatus As SPRECOCONTEXTSTATUS Ptr) As HRESULT
			Declare Abstract Function GetMaxAlternates (ByVal pcAlternates As ULong Ptr) As HRESULT
			Declare Abstract Function SetMaxAlternates (ByVal cAlternates As ULong) As HRESULT
			Declare Abstract Function SetAudioOptions (ByVal Options As SPAUDIOOPTIONS, ByVal pAudioFormatId As GUID Ptr, ByVal pWaveFormatEx As WaveFormatEx Ptr) As HRESULT
			Declare Abstract Function GetAudioOptions (ByVal pOptions As SPAUDIOOPTIONS Ptr, ByVal pAudioFormatId As GUID Ptr, ByVal ppCoMemWFEX As WaveFormatEx Ptr Ptr) As HRESULT
			Declare Abstract Function DeserializeResult (ByVal pSerializedResult As SPSERIALIZEDRESULT Ptr, ByVal ppResult As ISpRecoResult Ptr Ptr) As HRESULT
			Declare Abstract Function Bookmark (ByVal Options As SPBOOKMARKOPTIONS, ByVal ullStreamPosition As ULongInt, ByVal lparamEvent As Long_Ptr) As HRESULT
			Declare Abstract Function SetAdaptationData (ByVal pAdaptationData As WString Ptr, ByVal cch As ULong) As HRESULT
			Declare Abstract Function Pause (ByVal dwReserved As ULong) As HRESULT
			Declare Abstract Function Resume (ByVal dwReserved As ULong) As HRESULT
			Declare Abstract Function SetVoice (ByVal pVoice As ISpVoice Ptr, ByVal fAllowFormatChanges As Long) As HRESULT
			Declare Abstract Function GetVoice (ByVal ppVoice As ISpVoice Ptr Ptr) As HRESULT
			Declare Abstract Function SetVoicePurgeEvent (ByVal ullEventInterest As ULongInt) As HRESULT
			Declare Abstract Function GetVoicePurgeEvent (ByVal pullEventInterest As ULongInt Ptr) As HRESULT
			Declare Abstract Function SetContextState (ByVal eContextState As SPCONTEXTSTATE) As HRESULT
			Declare Abstract Function GetContextState (ByVal peContextState As SPCONTEXTSTATE Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpRecoContext2
	' IID: {BEAD311C-52FF-437F-9464-6B21054CA73D}
	' Documentation string: ISpRecoContext2 Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __ISpRecoContext2_INTERFACE_DEFINED__
		#define __ISpRecoContext2_INTERFACE_DEFINED__
		
		Type ISpRecoContext2_ Extends Afx_IUnknown
			Declare Abstract Function SetGrammarOptions (ByVal eGrammarOptions As ULong) As HRESULT
			Declare Abstract Function GetGrammarOptions (ByVal peGrammarOptions As ULong Ptr) As HRESULT
			Declare Abstract Function SetAdaptationData2 (ByVal pAdaptationData As WString Ptr, ByVal cch As ULong, ByVal pTopicName As WString Ptr, ByVal eAdaptationSettings As ULong, ByVal eRelevance As SPADAPTATIONRELEVANCE) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpRecognizer
	' IID: {C2B5F241-DAA0-4507-9E16-5A1EAA2B7A5C}
	' Documentation string: ISpRecognizer Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = ISpProperties
	' Number of methods = 16
	' ########################################################################################
	
	#ifndef __ISpRecognizer_INTERFACE_DEFINED__
		#define __ISpRecognizer_INTERFACE_DEFINED__
		
		Type ISpRecognizer_ Extends ISpProperties
			Declare Abstract Function SetRecognizer (ByVal pRecognizer As ISpObjectToken Ptr) As HRESULT
			Declare Abstract Function GetRecognizer (ByVal ppRecognizer As ISpObjectToken Ptr Ptr) As HRESULT
			Declare Abstract Function SetInput (ByVal pUnkInput As Afx_IUnknown Ptr, ByVal fAllowFormatChanges As Long) As HRESULT
			Declare Abstract Function GetInputObjectToken (ByVal ppToken As ISpObjectToken Ptr Ptr) As HRESULT
			Declare Abstract Function GetInputStream (ByVal ppStream As ISpStreamFormat Ptr Ptr) As HRESULT
			Declare Abstract Function CreateRecoContext (ByVal ppNewCtxt As ISpRecoContext Ptr Ptr) As HRESULT
			Declare Abstract Function GetRecoProfile (ByVal ppToken As ISpObjectToken Ptr Ptr) As HRESULT
			Declare Abstract Function SetRecoProfile (ByVal pToken As ISpObjectToken Ptr) As HRESULT
			Declare Abstract Function IsSharedInstance () As HRESULT
			Declare Abstract Function GetRecoState (ByVal pState As SPRECOSTATE Ptr) As HRESULT
			Declare Abstract Function SetRecoState (ByVal NewState As SPRECOSTATE) As HRESULT
			Declare Abstract Function GetStatus (ByVal pStatus As SPRECOGNIZERSTATUS Ptr) As HRESULT
			Declare Abstract Function GetFormat (ByVal WaveFormatType As SPSTREAMFORMATType, ByVal pFormatId As GUID Ptr, ByVal ppCoMemWFEX As WaveFormatEx Ptr Ptr) As HRESULT
			Declare Abstract Function IsUISupported (ByVal pszTypeOfUI As WString Ptr, ByVal pvExtraData As Any Ptr, ByVal cbExtraData As ULong, ByVal pfSupported As Long Ptr) As HRESULT
			Declare Abstract Function DisplayUI (ByVal hWndParent As HWND, ByVal pszTitle As WString Ptr, ByVal pszTypeOfUI As WString Ptr, ByVal pvExtraData As Any Ptr, ByVal cbExtraData As ULong) As HRESULT
			Declare Abstract Function EmulateRecognition (ByVal pPhrase As ISpPhrase Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpRecognizer2
	' IID: {8FC6D974-C81E-4098-93C5-0147F61ED4D3}
	' Documentation string: ISpRecognizer2 Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __ISpRecognizer2_INTERFACE_DEFINED__
		#define __ISpRecognizer2_INTERFACE_DEFINED__
		
		Type ISpRecognizer2_ Extends Afx_IUnknown
			Declare Abstract Function EmulateRecognitionEx (ByVal pPhrase As ISpPhrase Ptr, ByVal dwCompareFlags As ULong) As HRESULT
			Declare Abstract Function SetTrainingState (ByVal fDoingTraining As Long, ByVal fAdaptFromTrainingData As Long) As HRESULT
			Declare Abstract Function ResetAcousticModelAdaptation () As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpRecognizer3
	' IID: {DF1B943C-5838-4AA2-8706-D7CD5B333499}
	' Documentation string: ISpRecognizer3 Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __ISpRecognizer3_INTERFACE_DEFINED__
		#define __ISpRecognizer3_INTERFACE_DEFINED__
		
		Type ISpRecognizer3_ Extends Afx_IUnknown
			Declare Abstract Function GetCategory (ByVal categoryType As SPCATEGORYType, ByVal ppCategory As ISpRecoCategory Ptr Ptr) As HRESULT
			Declare Abstract Function SetActiveCategory (ByVal pCategory As ISpRecoCategory Ptr) As HRESULT
			Declare Abstract Function GetActiveCategory (ByVal ppCategory As ISpRecoCategory Ptr Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpRecoGrammar
	' IID: {2177DB29-7F45-47D0-8554-067E91C80502}
	' Documentation string: ISpRecoGrammar Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = ISpGrammarBuilder
	' Number of methods = 18
	' ########################################################################################
	
	#ifndef __ISpRecoGrammar_INTERFACE_DEFINED__
		#define __ISpRecoGrammar_INTERFACE_DEFINED__
		
		Type ISpRecoGrammar_ Extends ISpGrammarBuilder
			Declare Abstract Function GetGrammarId (ByVal pullGrammarId As ULongInt Ptr) As HRESULT
			Declare Abstract Function GetRecoContext (ByVal ppRecoCtxt As ISpRecoContext Ptr Ptr) As HRESULT
			Declare Abstract Function LoadCmdFromFile (ByVal pszFileName As WString Ptr, ByVal Options As SPLOADOPTIONS) As HRESULT
			Declare Abstract Function LoadCmdFromObject (ByVal rcid As GUID Ptr, ByVal pszGrammarName As WString Ptr, ByVal Options As SPLOADOPTIONS) As HRESULT
			Declare Abstract Function LoadCmdFromResource (ByVal hModule As Any Ptr, ByVal pszResourceName As WString Ptr, ByVal pszResourceType As WString Ptr, ByVal wLanguage As UShort, ByVal Options As SPLOADOPTIONS) As HRESULT
			Declare Abstract Function LoadCmdFromMemory (ByVal pGrammar As SPBINARYGRAMMAR Ptr, ByVal Options As SPLOADOPTIONS) As HRESULT
			Declare Abstract Function LoadCmdFromProprietaryGrammar (ByVal rguidParam As GUID Ptr, ByVal pszStringParam As WString Ptr, ByVal pvDataPrarm As Any Ptr, ByVal cbDataSize As ULong, ByVal Options As SPLOADOPTIONS) As HRESULT
			Declare Abstract Function SetRuleState (ByVal pszName As WString Ptr, ByVal pReserved As Any Ptr, ByVal NewState As SPRULESTATE) As HRESULT
			Declare Abstract Function SetRuleIdState (ByVal ulRuleId As ULong, ByVal NewState As SPRULESTATE) As HRESULT
			Declare Abstract Function LoadDictation (ByVal pszTopicName As WString Ptr, ByVal Options As SPLOADOPTIONS) As HRESULT
			Declare Abstract Function UnloadDictation () As HRESULT
			Declare Abstract Function SetDictationState (ByVal NewState As SPRULESTATE) As HRESULT
			Declare Abstract Function SetWordSequenceData (ByVal pText As UShort Ptr, ByVal cchText As ULong, ByVal pInfo As SPTEXTSELECTIONINFO Ptr) As HRESULT
			Declare Abstract Function SetTextSelection (ByVal pInfo As SPTEXTSELECTIONINFO Ptr) As HRESULT
			Declare Abstract Function IsPronounceable (ByVal pszWord As WString Ptr, ByVal pWordPronounceable As SPWORDPRONOUNCEABLE Ptr) As HRESULT
			Declare Abstract Function SetGrammarState (ByVal eGrammarState As SPGRAMMARSTATE) As HRESULT
			Declare Abstract Function SaveCmd (ByVal pStream As IStream Ptr, ByVal ppszCoMemErrorText As WString Ptr Ptr = NULL) As HRESULT
			Declare Abstract Function GetGrammarState (ByVal peGrammarState As SPGRAMMARSTATE Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpRecoGrammar2
	' IID: {4B37BC9E-9ED6-44A3-93D3-18F022B79EC3}
	' Documentation string: ISpRecoGrammar2 Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 8
	' ########################################################################################
	
	#ifndef __ISpRecoGrammar2_INTERFACE_DEFINED__
		#define __ISpRecoGrammar2_INTERFACE_DEFINED__
		
		Type ISpRecoGrammar2_ Extends Afx_IUnknown
			Declare Abstract Function GetRules (ByVal ppCoMemRules As SPRULE Ptr Ptr, ByVal puNumRules As UINT Ptr) As HRESULT
			Declare Abstract Function LoadCmdFromFile2 (ByVal pszFileName As WString Ptr, ByVal Options As SPLOADOPTIONS, ByVal pszSharingUri As WString Ptr, ByVal pszBaseUri As WString Ptr) As HRESULT
			Declare Abstract Function LoadCmdFromMemory2 (ByVal pGrammar As SPBINARYGRAMMAR Ptr, ByVal Options As SPLOADOPTIONS, ByVal pszSharingUri As WString Ptr, ByVal pszBaseUri As WString Ptr) As HRESULT
			Declare Abstract Function SetRulePriority (ByVal pszRuleName As WString Ptr, ByVal ulRuleId As ULong, ByVal nRulePriority As INT_) As HRESULT
			Declare Abstract Function SetRuleWeight (ByVal pszRuleName As WString Ptr, ByVal ulRuleId As ULong, ByVal flWeight As Single) As HRESULT
			Declare Abstract Function SetDictationWeight (ByVal flWeight As Single) As HRESULT
			Declare Abstract Function SetGrammarLoader (ByVal pLoader As ISpeechResourceLoader Ptr) As HRESULT
			Declare Abstract Function SetSMLSecurityManager (ByVal pSMLSecurityManager As IInternetSecurityManager Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpRecoResult
	' IID: {20B053BE-E235-43CD-9A2A-8D17A48B7842}
	' Documentation string: ISpRecoResult Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = ISpPhrase
	' Number of methods = 7
	' ########################################################################################
	
	#ifndef __ISpRecoResult_INTERFACE_DEFINED__
		#define __ISpRecoResult_INTERFACE_DEFINED__
		
		Type ISpRecoResult_ Extends ISpPhrase
			Declare Abstract Function GetResultTimes (ByVal pTimes AS SPRECORESULTTIMES Ptr) AS HRESULT
			Declare Abstract Function GetAlternates (ByVal ulStartElement AS ULong, ByVal cElements AS ULong, ByVal ulRequestCount AS ULong, ByVal ppPhrases AS ISpPhraseAlt Ptr Ptr, ByVal pcPhrasesReturned AS ULong Ptr) AS HRESULT
			Declare Abstract Function GetAudio (ByVal ulStartElement AS ULong, ByVal cElements AS ULong, ByVal ppStream AS ISpStreamFormat Ptr Ptr) AS HRESULT
			Declare Abstract Function SpeakAudio (ByVal ulStartElement AS ULong, ByVal cElements AS ULong, ByVal dwFlags AS ULong, ByVal pulStreamNumber AS ULong Ptr) AS HRESULT
			Declare Abstract Function Serialize (ByVal ppCoMemSerializedResult AS SPSERIALIZEDRESULT Ptr Ptr) AS HRESULT
			Declare Abstract Function ScaleAudio (ByVal pAudioFormatId AS GUID Ptr, ByVal pWaveFormatEx AS WaveFormatEx Ptr) AS HRESULT
			Declare Abstract Function GetRecoContext (ByVal ppRecoContext AS ISpRecoContext Ptr Ptr) AS HRESULT
		END Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpResourceManager
	' IID: {93384E18-5014-43D5-ADBB-A78E055926BD}
	' Documentation string: ISpResourceManager Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IServiceProvider
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __ISpResourceManager_INTERFACE_DEFINED__
		#define __ISpResourceManager_INTERFACE_DEFINED__
		
		Type ISpResourceManager_ Extends Afx_IUnknown
			' IServiceProvider interface
			Declare Abstract Function QueryService (ByVal guidService As GUID Ptr, ByVal riid As GUID Ptr, ByVal ppvObject As IUnknown Ptr Ptr) As HRESULT
			' ISpResourceManager interface
			Declare Abstract Function SetObject (ByVal guidServiceId As GUID Ptr, ByVal punkObject As Afx_IUnknown Ptr) As HRESULT
			Declare Abstract Function GetObject (ByVal guidServiceId As GUID Ptr, ByVal ObjectCLSID As GUID Ptr, ByVal ObjectIID As GUID Ptr, ByVal fReleaseWhenLastExternalRefReleased As Long, ByVal ppObject As Any Ptr Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpSerializeState
	' IID: {21B501A0-0EC7-46C9-92C3-A2BC784C54B9}
	' Documentation string: ISpSerializeState Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __ISpSerializeState_INTERFACE_DEFINED__
		#define __ISpSerializeState_INTERFACE_DEFINED__
		
		Type ISpSerializeState_ Extends Afx_IUnknown
			Declare Abstract Function GetSerializedState (ByVal ppbData As UByte Ptr Ptr, ByVal pulSize As ULong Ptr, ByVal dwReserved As ULong) As HRESULT
			Declare Abstract Function SetSerializedState (ByVal pbData As UByte Ptr, ByVal ulSize As ULong, ByVal dwReserved As ULong) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpShortcut
	' IID: {3DF681E2-EA56-11D9-8BDE-F66BAD1E3F3A}
	' Documentation string: ISpShortcut Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = IUnknown
	' Number of methods = 8
	' ########################################################################################
	
	#ifndef __ISpShortcut_INTERFACE_DEFINED__
		#define __ISpShortcut_INTERFACE_DEFINED__
		
		Type ISpShortcut_ Extends Afx_IUnknown
			Declare Abstract Function AddShortcut (ByVal pszDisplay As WString Ptr, ByVal LangId As UShort, ByVal pszSpoken As WString Ptr, ByVal shType As SPSHORTCUTType) As HRESULT
			Declare Abstract Function RemoveShortcut (ByVal pszDisplay As WString Ptr, ByVal LangId As UShort, ByVal pszSpoken As WString Ptr, ByVal shType As SPSHORTCUTType) As HRESULT
			Declare Abstract Function GetShortcuts (ByVal LangId As UShort, ByVal pShortcutpairList As SPSHORTCUTPAIRLIST Ptr) As HRESULT
			Declare Abstract Function GetGeneration (ByVal pdwGeneration As ULong Ptr) As HRESULT
			Declare Abstract Function GetWordsFromGenerationChange (ByVal pdwGeneration As ULong Ptr, ByVal pWordList As SPWORDLIST Ptr) As HRESULT
			Declare Abstract Function GetWords (ByVal pdwGeneration As ULong Ptr, ByVal pdwCookie As ULong Ptr, ByVal pWordList As SPWORDLIST Ptr) As HRESULT
			Declare Abstract Function GetShortcutsForGeneration (ByVal pdwGeneration As ULong Ptr, ByVal pdwCookie As ULong Ptr, ByVal pShortcutpairList As SPSHORTCUTPAIRLIST Ptr) As HRESULT
			Declare Abstract Function GetGenerationChange (ByVal pdwGeneration As ULong Ptr, ByVal pShortcutpairList As SPSHORTCUTPAIRLIST Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpStream
	' IID: {12E3CCA9-7518-44C5-A5E7-BA5A79CB929E}
	' Documentation string: ISpStream Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = ISpStreamFormat
	' Number of methods = 4
	' ########################################################################################
	
	#ifndef __ISpStream_INTERFACE_DEFINED__
		#define __ISpStream_INTERFACE_DEFINED__
		
		Type ISpStream_ Extends ISpStreamFormat
			Declare Abstract Function SetBaseStream (ByVal pStream As IStream Ptr, ByVal rguidFormat As GUID Ptr, ByVal pWaveFormatEx As WaveFormatEx Ptr) As HRESULT
			Declare Abstract Function GetBaseStream (ByVal ppStream As IStream Ptr Ptr) As HRESULT
			Declare Abstract Function BindToFile (ByVal pszFileName As WString Ptr, ByVal eMode As SPFILEMODE, ByVal pFormatId As GUID Ptr, ByVal pWaveFormatEx As WaveFormatEx Ptr, ByVal ullEventInterest As ULongInt) As HRESULT
			Declare Abstract Function Close () As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpStreamFormatConverter
	' IID: {678A932C-EA71-4446-9B41-78FDA6280A29}
	' Documentation string: ISpStreamFormatConverter Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = ISpStreamFormat
	' Number of methods = 6
	' ########################################################################################
	
	#ifndef __ISpStreamFormatConverter_INTERFACE_DEFINED__
		#define __ISpStreamFormatConverter_INTERFACE_DEFINED__
		
		Type ISpStreamFormatConverter_ Extends ISpStreamFormat
			Declare Abstract Function SetBaseStream (ByVal pStream AS ISpStreamFormat Ptr, ByVal fSetFormatToBaseStreamFormat AS Long, ByVal fWriteToBaseStream AS Long) AS HRESULT
			Declare Abstract Function GetBaseStream (ByVal ppStream AS ISpStreamFormat Ptr Ptr) AS HRESULT
			Declare Abstract Function SetFormat (ByVal rguidFormatIdOfConvertedStream AS GUID Ptr, ByVal pWaveFormatExOfConvertedStream AS WaveFormatEx Ptr) AS HRESULT
			Declare Abstract Function ResetSeekPosition () AS HRESULT
			Declare Abstract Function ScaleConvertedToBaseOffset (ByVal ullOffsetConvertedStream AS ULongINT, ByVal pullOffsetBaseStream AS ULongINT Ptr) AS HRESULT
			Declare Abstract Function ScaleBaseToConvertedOffset (ByVal ullOffsetBaseStream AS ULongINT, ByVal pullOffsetConvertedStream AS ULongINT Ptr) AS HRESULT
		END Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpVoice
	' IID: {6C44DF74-72B9-4992-A1EC-EF996E0422D4}
	' Documentation string: ISpVoice Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = ISpEventSource
	' Number of methods = 25
	' ########################################################################################
	
	#ifndef __ISpVoice_INTERFACE_DEFINED__
		#define __ISpVoice_INTERFACE_DEFINED__
		
		Type ISpVoice_ Extends ISpEventSource
			Declare Abstract Function SetOutput (ByVal pUnkOutput As Afx_IUnknown Ptr, ByVal fAllowFormatChanges As Long) As HRESULT
			Declare Abstract Function GetOutputObjectToken (ByVal ppObjectToken AS ISpObjectToken Ptr Ptr) AS HRESULT
			Declare Abstract Function GetOutputStream (ByVal ppStream As ISpStreamFormat Ptr Ptr) As HRESULT
			Declare Abstract Function Pause () As HRESULT
			Declare Abstract Function Resume () As HRESULT
			Declare Abstract Function SetVoice (ByVal pToken As ISpObjectToken Ptr) As HRESULT
			Declare Abstract Function GetVoice (ByVal ppToken As ISpObjectToken Ptr Ptr) As HRESULT
			Declare Abstract Function Speak (ByVal pwcs As WString Ptr, ByVal dwFlags As ULong, ByVal pulStreamNumber As ULong Ptr) As HRESULT
			Declare Abstract Function SpeakStream (ByVal pStream As IStream Ptr, ByVal dwFlags As ULong, ByVal pulStreamNumber As ULong Ptr) As HRESULT
			Declare Abstract Function GetStatus (ByVal pStatus As SPVOICESTATUS Ptr, ByVal ppszLastBookmark As WString Ptr Ptr) As HRESULT
			Declare Abstract Function Skip (ByVal pItemType As WString Ptr, ByVal lNumItems As Long, ByVal pulNumSkipped As ULong Ptr) As HRESULT
			Declare Abstract Function SetPriority (ByVal ePriority As SPVPRIORITY) As HRESULT
			Declare Abstract Function GetPriority (ByVal pePriority As SPVPRIORITY Ptr) As HRESULT
			Declare Abstract Function SetAlertBoundary (ByVal eBoundary As SPEVENTENUM) As HRESULT
			Declare Abstract Function GetAlertBoundary (ByVal peBoundary As SPEVENTENUM Ptr) As HRESULT
			Declare Abstract Function SetRate (ByVal RateAdjust As Long) As HRESULT
			Declare Abstract Function GetRate (ByVal pRateAdjust As Long Ptr) As HRESULT
			Declare Abstract Function SetVolume (ByVal usVolume As UShort) As HRESULT
			Declare Abstract Function GetVolume (ByVal pusVolume As UShort Ptr) As HRESULT
			Declare Abstract Function WaitUntilDone (ByVal msTimeout As ULong) As HRESULT
			Declare Abstract Function SetSyncSpeakTimeout (ByVal msTimeout As ULong) As HRESULT
			Declare Abstract Function GetSyncSpeakTimeout (ByVal pmsTimeout As ULong Ptr) As HRESULT
			Declare Abstract Function SpeakCompleteEvent () As HRESULT
			Declare Abstract Function IsUISupported (ByVal pszTypeOfUI As WString Ptr, ByVal pvExtraData As Any Ptr, ByVal cbExtraData As ULong, ByVal pfSupported As Long Ptr) As HRESULT
			Declare Abstract Function DisplayUI (ByVal hWndParent As HWND, ByVal pszTitle As WString Ptr, ByVal pszTypeOfUI As WString Ptr, ByVal pvExtraData As Any Ptr, ByVal cbExtraData As ULong) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpXMLRecoResult
	' IID: {AE39362B-45A8-4074-9B9E-CCF49AA2D0B6}
	' Documentation string: ISpXMLRecoResult Interface
	' Attributes =  512 [&h00000200] [Restricted]
	' Inherited interface = ISpRecoResult
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __ISpXMLRecoResult_INTERFACE_DEFINED__
		#define __ISpXMLRecoResult_INTERFACE_DEFINED__
		
		Type ISpXMLRecoResult_ Extends ISpRecoResult
			Declare Abstract Function GetXMLResult (ByVal ppszCoMemXMLResult As WString Ptr Ptr, ByVal Options As SPXMLRESULTOPTIONS) As HRESULT
			Declare Abstract Function GetXMLErrorInfo (ByVal pSemanticErrorInfo As SPSEMANTICERRORINFO Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	
	' Dual interfaces
	
	
	' ########################################################################################
	' Interface name: ISpeechBaseStream
	' IID: {6450336F-7D49-4CED-8097-49D6DEE37294}
	' Documentation string: ISpeechBaseStream Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 5
	' ########################################################################################
	
	#ifndef __ISpeechBaseStream_INTERFACE_DEFINED__
		#define __ISpeechBaseStream_INTERFACE_DEFINED__
		
		Type ISpeechBaseStream_ Extends Afx_IDispatch
			Declare Abstract Function get_Format (ByVal AudioFormat As ISpeechAudioFormat Ptr Ptr) As HRESULT
			Declare Abstract Function putref_Format (ByVal AudioFormat As ISpeechAudioFormat Ptr) As HRESULT
			Declare Abstract Function Read (ByVal Buffer As VARIANT Ptr, ByVal NumberOfBytes As Long, ByVal BytesRead As Long Ptr) As HRESULT
			Declare Abstract Function Write (ByVal Buffer As VARIANT, ByVal BytesWritten As Long Ptr) As HRESULT
			Declare Abstract Function Seek (ByVal Position As VARIANT, ByVal Origin As SpeechStreamSeekPositionType = 0, ByVal NewPosition As VARIANT Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechAudio
	' IID: {CFF8E175-019E-11D3-A08E-00C04F8EF9B5}
	' Documentation string: ISpeechAudio Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = ISpeechBaseStream
	' Number of methods = 9
	' ########################################################################################
	
	#ifndef __ISpeechAudio_INTERFACE_DEFINED__
		#define __ISpeechAudio_INTERFACE_DEFINED__
		
		Type ISpeechAudio_ Extends ISpeechBaseStream
			Declare Abstract Function get_Status (ByVal Status As ISpeechAudioStatus Ptr Ptr) As HRESULT
			Declare Abstract Function get_BufferInfo (ByVal BufferInfo As ISpeechAudioBufferInfo Ptr Ptr) As HRESULT
			Declare Abstract Function get_DefaultFormat (ByVal StreamFormat As ISpeechAudioFormat Ptr Ptr) As HRESULT
			Declare Abstract Function get_Volume (ByVal Volume As Long Ptr) As HRESULT
			Declare Abstract Function put_Volume (ByVal Volume As Long) As HRESULT
			Declare Abstract Function get_BufferNotifySize (ByVal BufferNotifySize As Long Ptr) As HRESULT
			Declare Abstract Function put_BufferNotifySize (ByVal BufferNotifySize As Long) As HRESULT
			Declare Abstract Function get_EventHandle (ByVal EventHandle As Long Ptr) As HRESULT
			Declare Abstract Function SetState (ByVal State As SpeechAudioState) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechAudioBufferInfo
	' IID: {11B103D8-1142-4EDF-A093-82FB3915F8CC}
	' Documentation string: ISpeechAudioBufferInfo Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 6
	' ########################################################################################
	
	#ifndef __ISpeechAudioBufferInfo_INTERFACE_DEFINED__
		#define __ISpeechAudioBufferInfo_INTERFACE_DEFINED__
		
		Type ISpeechAudioBufferInfo_ Extends Afx_IDispatch
			Declare Abstract Function get_MinNotification (ByVal MinNotification As Long Ptr) As HRESULT
			Declare Abstract Function put_MinNotification (ByVal MinNotification As Long) As HRESULT
			Declare Abstract Function get_BufferSize (ByVal BufferSize As Long Ptr) As HRESULT
			Declare Abstract Function put_BufferSize (ByVal BufferSize As Long) As HRESULT
			Declare Abstract Function get_EventBias (ByVal EventBias As Long Ptr) As HRESULT
			Declare Abstract Function put_EventBias (ByVal EventBias As Long) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechAudioFormat
	' IID: {E6E9C590-3E18-40E3-8299-061F98BDE7C7}
	' Documentation string: ISpeechAudioFormat Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 6
	' ########################################################################################
	
	#ifndef __ISpeechAudioFormat_INTERFACE_DEFINED__
		#define __ISpeechAudioFormat_INTERFACE_DEFINED__
		
		Type ISpeechAudioFormat_ Extends Afx_IDispatch
			Declare Abstract Function get_Type (ByVal AudioFormat As SpeechAudioFormatType Ptr) As HRESULT
			Declare Abstract Function put_Type (ByVal AudioFormat As SpeechAudioFormatType) As HRESULT
			Declare Abstract Function get_Guid (ByVal Guid As WString Ptr Ptr) As HRESULT
			Declare Abstract Function put_Guid (ByVal Guid As WString Ptr) As HRESULT
			Declare Abstract Function GetWaveFormatEx (ByVal WaveFormatEx As ISpeechWaveFormatEx Ptr Ptr) As HRESULT
			Declare Abstract Function SetWaveFormatEx (ByVal WaveFormatEx As ISpeechWaveFormatEx Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechAudioStatus
	' IID: {C62D9C91-7458-47F6-862D-1EF86FB0B278}
	' Documentation string: ISpeechAudioStatus Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 5
	' ########################################################################################
	
	#ifndef __ISpeechAudioStatus_INTERFACE_DEFINED__
		#define __ISpeechAudioStatus_INTERFACE_DEFINED__
		
		Type ISpeechAudioStatus_ Extends Afx_IDispatch
			Declare Abstract Function get_FreeBufferSpace (ByVal FreeBufferSpace As Long Ptr) As HRESULT
			Declare Abstract Function get_NonBlockingIO (ByVal NonBlockingIO As Long Ptr) As HRESULT
			Declare Abstract Function get_State (ByVal State As SpeechAudioState Ptr) As HRESULT
			Declare Abstract Function get_CurrentSeekPosition (ByVal CurrentSeekPosition As VARIANT Ptr) As HRESULT
			Declare Abstract Function get_CurrentDevicePosition (ByVal CurrentDevicePosition As VARIANT Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechCustomStream
	' IID: {1A9E9F4F-104F-4DB8-A115-EFD7FD0C97AE}
	' Documentation string: ISpeechCustomStream Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = ISpeechBaseStream
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __ISpeechCustomStream_INTERFACE_DEFINED__
		#define __ISpeechCustomStream_INTERFACE_DEFINED__
		
		Type ISpeechCustomStream_ Extends ISpeechBaseStream
			Declare Abstract Function get_BaseStream (ByVal ppUnkStream As Afx_IUnknown Ptr Ptr) As HRESULT
			Declare Abstract Function putref_BaseStream (ByVal ppUnkStream As Afx_IUnknown Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechDataKey
	' IID: {CE17C09B-4EFA-44D5-A4C9-59D9585AB0CD}
	' Documentation string: ISpeechDataKey Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 12
	' ########################################################################################
	
	#ifndef __ISpeechDataKey_INTERFACE_DEFINED__
		#define __ISpeechDataKey_INTERFACE_DEFINED__
		
		Type ISpeechDataKey_ Extends Afx_IDispatch
			Declare Abstract Function SetBinaryValue (ByVal ValueName As WString Ptr, ByVal Value As VARIANT) As HRESULT
			Declare Abstract Function GetBinaryValue (ByVal ValueName As WString Ptr, ByVal Value As VARIANT Ptr) As HRESULT
			Declare Abstract Function SetStringValue (ByVal ValueName As WString Ptr, ByVal Value As WString Ptr) As HRESULT
			Declare Abstract Function GetStringValue (ByVal ValueName As WString Ptr, ByVal Value As WString Ptr Ptr) As HRESULT
			Declare Abstract Function SetLongValue (ByVal ValueName As WString Ptr, ByVal Value As Long) As HRESULT
			Declare Abstract Function GetLongValue (ByVal ValueName As WString Ptr, ByVal Value As Long Ptr) As HRESULT
			Declare Abstract Function OpenKey (ByVal SubKeyName As WString Ptr, ByVal SubKey As ISpeechDataKey Ptr Ptr) As HRESULT
			Declare Abstract Function CreateKey (ByVal SubKeyName As WString Ptr, ByVal SubKey As ISpeechDataKey Ptr Ptr) As HRESULT
			Declare Abstract Function DeleteKey (ByVal SubKeyName As WString Ptr) As HRESULT
			Declare Abstract Function DeleteValue (ByVal ValueName As WString Ptr) As HRESULT
			Declare Abstract Function EnumKeys (ByVal Index As Long, ByVal SubKeyName As WString Ptr Ptr) As HRESULT
			Declare Abstract Function EnumValues (ByVal Index As Long, ByVal ValueName As WString Ptr Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechFileStream
	' IID: {AF67F125-AB39-4E93-B4A2-CC2E66E182A7}
	' Documentation string: ISpeechFileStream Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = ISpeechBaseStream
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __ISpeechFileStream_INTERFACE_DEFINED__
		#define __ISpeechFileStream_INTERFACE_DEFINED__
		
		Type ISpeechFileStream_ Extends ISpeechBaseStream
			Declare Abstract Function Open (ByVal FileName As WString Ptr, ByVal FileMode As SpeechStreamFileMode = 0, ByVal DoEvents As VARIANT_BOOL = 0) As HRESULT
			Declare Abstract Function Close () As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechGrammarRule
	' IID: {AFE719CF-5DD1-44F2-999C-7A399F1CFCCC}
	' Documentation string: ISpeechGrammarRule Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 7
	' ########################################################################################
	
	#ifndef __ISpeechGrammarRule_INTERFACE_DEFINED__
		#define __ISpeechGrammarRule_INTERFACE_DEFINED__
		
		Type ISpeechGrammarRule_ Extends Afx_IDispatch
			Declare Abstract Function get_Attributes (ByVal Attributes As SpeechRuleAttributes Ptr) As HRESULT
			Declare Abstract Function get_InitialState (ByVal State AS ISpeechGrammarRuleState Ptr Ptr) AS HRESULT
			Declare Abstract Function get_Name (ByVal Name AS WString Ptr Ptr) AS HRESULT
			Declare Abstract Function get_Id (ByVal Id AS Long Ptr) AS HRESULT
			Declare Abstract Function Clear () AS HRESULT
			Declare Abstract Function AddResource (ByVal ResourceName AS WString Ptr, ByVal ResourceValue AS WString Ptr) AS HRESULT
			Declare Abstract Function AddState (ByVal State AS ISpeechGrammarRuleState Ptr Ptr) AS HRESULT
		END Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechGrammarRules
	' IID: {6FFA3B44-FC2D-40D1-8AFC-32911C7F1AD1}
	' Documentation string: ISpeechGrammarRules Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 8
	' ########################################################################################
	
	#ifndef __ISpeechGrammarRules_INTERFACE_DEFINED__
		#define __ISpeechGrammarRules_INTERFACE_DEFINED__
		
		Type ISpeechGrammarRules_ Extends Afx_IDispatch
			Declare Abstract Function get_Count (ByVal Count AS Long Ptr) AS HRESULT
			Declare Abstract Function FindRule (ByVal RuleNameOrId AS VARIANT, ByVal Rule AS ISpeechGrammarRule Ptr Ptr) AS HRESULT
			Declare Abstract Function Item (ByVal Index AS Long, ByVal Rule AS ISpeechGrammarRule Ptr Ptr) AS HRESULT
			Declare Abstract Function get__NewEnum (ByVal EnumVARIANT AS Afx_IUnknown Ptr Ptr) AS HRESULT
			Declare Abstract Function get_Dynamic (ByVal Dynamic AS VARIANT_BOOL Ptr) AS HRESULT
			Declare Abstract Function Add (ByVal RuleName AS WString Ptr, ByVal Attributes AS SpeechRuleAttributes, ByVal RuleId AS Long = 0, ByVal Rule AS ISpeechGrammarRule Ptr Ptr) AS HRESULT
			Declare Abstract Function Commit () AS HRESULT
			Declare Abstract Function CommitAndSave (ByVal ErrorText AS WString Ptr Ptr, ByVal SaveStream AS VARIANT Ptr) AS HRESULT
		END Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechGrammarRuleState
	' IID: {D4286F2C-EE67-45AE-B928-28D695362EDA}
	' Documentation string: ISpeechGrammarRuleState Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 5
	' ########################################################################################
	
	#ifndef __ISpeechGrammarRuleState_INTERFACE_DEFINED__
		#define __ISpeechGrammarRuleState_INTERFACE_DEFINED__
		
		Type ISpeechGrammarRuleState_ Extends Afx_IDispatch
			Declare Abstract Function get_Rule (ByVal Rule As ISpeechGrammarRule Ptr Ptr) As HRESULT
			Declare Abstract Function get_Transitions (ByVal Transitions As ISpeechGrammarRuleStateTransitions Ptr Ptr) As HRESULT
			Declare Abstract Function AddWordTransition (ByVal DestState As ISpeechGrammarRuleState Ptr, ByVal Words As WString Ptr, ByVal Separators As WString Ptr, ByVal Type As SpeechGrammarWordType = 1, ByVal PropertyName As WString Ptr, ByVal PropertyId As Long = 0, ByVal PropertyValue As VARIANT Ptr, ByVal Weight As Single = 1) As HRESULT
			Declare Abstract Function AddRuleTransition (ByVal DestinationState As ISpeechGrammarRuleState Ptr, ByVal Rule As ISpeechGrammarRule Ptr, ByVal PropertyName As WString Ptr, ByVal PropertyId As Long = 0, ByVal PropertyValue As VARIANT Ptr, ByVal Weight As Single = 1) As HRESULT
			Declare Abstract Function AddSpecialTransition (ByVal DestinationState As ISpeechGrammarRuleState Ptr, ByVal Type As SpeechSpecialTransitionType, ByVal PropertyName As WString Ptr, ByVal PropertyId As Long = 0, ByVal PropertyValue As VARIANT Ptr, ByVal Weight As Single = 1) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechGrammarRuleStateTransition
	' IID: {CAFD1DB1-41D1-4A06-9863-E2E81DA17A9A}
	' Documentation string: ISpeechGrammarRuleStateTransition Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 8
	' ########################################################################################
	
	#ifndef __ISpeechGrammarRuleStateTransition_INTERFACE_DEFINED__
		#define __ISpeechGrammarRuleStateTransition_INTERFACE_DEFINED__
		
		Type ISpeechGrammarRuleStateTransition_ Extends Afx_IDispatch
			Declare Abstract Function get_Type (ByVal Type As SpeechGrammarRuleStateTransitionType Ptr) As HRESULT
			Declare Abstract Function get_Text (ByVal Text As WString Ptr Ptr) As HRESULT
			Declare Abstract Function get_Rule (ByVal Rule As ISpeechGrammarRule Ptr Ptr) As HRESULT
			Declare Abstract Function get_Weight (ByVal Weight As VARIANT Ptr) As HRESULT
			Declare Abstract Function get_PropertyName (ByVal PropertyName As WString Ptr Ptr) As HRESULT
			Declare Abstract Function get_PropertyId (ByVal PropertyId As Long Ptr) As HRESULT
			Declare Abstract Function get_PropertyValue (ByVal PropertyValue As VARIANT Ptr) As HRESULT
			Declare Abstract Function get_NextState (ByVal NextState As ISpeechGrammarRuleState Ptr Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechGrammarRuleStateTransitions
	' IID: {EABCE657-75BC-44A2-AA7F-C56476742963}
	' Documentation string: ISpeechGrammarRuleStateTransitions Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __ISpeechGrammarRuleStateTransitions_INTERFACE_DEFINED__
		#define __ISpeechGrammarRuleStateTransitions_INTERFACE_DEFINED__
		
		Type ISpeechGrammarRuleStateTransitions_ Extends Afx_IDispatch
			Declare Abstract Function get_Count (ByVal Count AS Long Ptr) AS HRESULT
			Declare Abstract Function Item (ByVal Index AS Long, ByVal Transition AS ISpeechGrammarRuleStateTransition Ptr Ptr) AS HRESULT
			Declare Abstract Function get__NewEnum (ByVal EnumVARIANT AS Afx_IUnknown Ptr Ptr) AS HRESULT
		END Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechLexicon
	' IID: {3DA7627A-C7AE-4B23-8708-638C50362C25}
	' Documentation string: ISpeechLexicon Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 8
	' ########################################################################################
	
	#ifndef __ISpeechLexicon_INTERFACE_DEFINED__
		#define __ISpeechLexicon_INTERFACE_DEFINED__
		
		Type ISpeechLexicon_ Extends Afx_IDispatch
			Declare Abstract Function get_GenerationId (ByVal GenerationId As Long Ptr) As HRESULT
			Declare Abstract Function GetWords (ByVal Flags As SpeechLexiconType = 3, ByVal GenerationId As Long Ptr = 0, ByVal Words As ISpeechLexiconWords Ptr Ptr) As HRESULT
			Declare Abstract Function AddPronunciation (ByVal bstrWord As WString Ptr, ByVal LangId As Long, ByVal PartOfSpeech As SpeechPartOfSpeech = 0, ByVal bstrPronunciation As WString Ptr) As HRESULT
			Declare Abstract Function AddPronunciationByPhoneIds (ByVal bstrWord As WString Ptr, ByVal LangId As Long, ByVal PartOfSpeech As SpeechPartOfSpeech = 0, ByVal PhoneIds As VARIANT Ptr) As HRESULT
			Declare Abstract Function RemovePronunciation (ByVal bstrWord As WString Ptr, ByVal LangId As Long, ByVal PartOfSpeech As SpeechPartOfSpeech = 0, ByVal bstrPronunciation As WString Ptr) As HRESULT
			Declare Abstract Function RemovePronunciationByPhoneIds (ByVal bstrWord As WString Ptr, ByVal LangId As Long, ByVal PartOfSpeech As SpeechPartOfSpeech = 0, ByVal PhoneIds As VARIANT Ptr) As HRESULT
			Declare Abstract Function GetPronunciations (ByVal bstrWord As WString Ptr, ByVal LangId As Long = 0, ByVal TypeFlags As SpeechLexiconType = 3, ByVal ppPronunciations As ISpeechLexiconPronunciations Ptr Ptr) As HRESULT
			Declare Abstract Function GetGenerationChange (ByVal GenerationId As Long Ptr, ByVal ppWords As ISpeechLexiconWords Ptr Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechLexiconPronunciation
	' IID: {95252C5D-9E43-4F4A-9899-48EE73352F9F}
	' Documentation string: ISpeechLexiconPronunciation Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 5
	' ########################################################################################
	
	#ifndef __ISpeechLexiconPronunciation_INTERFACE_DEFINED__
		#define __ISpeechLexiconPronunciation_INTERFACE_DEFINED__
		
		Type ISpeechLexiconPronunciation_ Extends Afx_IDispatch
			Declare Abstract Function get_Type (ByVal LexiconType As SpeechLexiconType Ptr) As HRESULT
			Declare Abstract Function get_LangId (ByVal LangId As Long Ptr) As HRESULT
			Declare Abstract Function get_PartOfSpeech (ByVal PartOfSpeech As SpeechPartOfSpeech Ptr) As HRESULT
			Declare Abstract Function get_PhoneIds (ByVal PhoneIds As VARIANT Ptr) As HRESULT
			Declare Abstract Function get_Symbolic (ByVal Symbolic As WString Ptr Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechLexiconPronunciations
	' IID: {72829128-5682-4704-A0D4-3E2BB6F2EAD3}
	' Documentation string: ISpeechLexiconPronunciations Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __ISpeechLexiconPronunciations_INTERFACE_DEFINED__
		#define __ISpeechLexiconPronunciations_INTERFACE_DEFINED__
		
		Type ISpeechLexiconPronunciations_ Extends Afx_IDispatch
			Declare Abstract Function get_Count (ByVal Count As Long Ptr) As HRESULT
			Declare Abstract Function Item (ByVal Index As Long, ByVal Pronunciation As ISpeechLexiconPronunciation Ptr Ptr) As HRESULT
			Declare Abstract Function get__NewEnum (ByVal EnumVARIANT As Afx_IUnknown Ptr Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechLexiconWord
	' IID: {4E5B933C-C9BE-48ED-8842-1EE51BB1D4FF}
	' Documentation string: ISpeechLexiconWord Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 4
	' ########################################################################################
	
	#ifndef __ISpeechLexiconWord_INTERFACE_DEFINED__
		#define __ISpeechLexiconWord_INTERFACE_DEFINED__
		
		Type ISpeechLexiconWord_ Extends Afx_IDispatch
			Declare Abstract Function get_LangId (ByVal LangId As Long Ptr) As HRESULT
			Declare Abstract Function get_Type (ByVal WordType As SpeechWordType Ptr) As HRESULT
			Declare Abstract Function get_Word (ByVal Word As WString Ptr Ptr) As HRESULT
			Declare Abstract Function get_Pronunciations (ByVal Pronunciations As ISpeechLexiconPronunciations Ptr Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechLexiconWords
	' IID: {8D199862-415E-47D5-AC4F-FAA608B424E6}
	' Documentation string: ISpeechLexiconWords Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __ISpeechLexiconWords_INTERFACE_DEFINED__
		#define __ISpeechLexiconWords_INTERFACE_DEFINED__
		
		Type ISpeechLexiconWords_ Extends Afx_IDispatch
			Declare Abstract Function get_Count (ByVal Count AS Long Ptr) AS HRESULT
			Declare Abstract Function Item (ByVal Index AS Long, ByVal Word AS ISpeechLexiconWord Ptr Ptr) AS HRESULT
			Declare Abstract Function get__NewEnum (ByVal EnumVARIANT AS Afx_IUnknown Ptr Ptr) AS HRESULT
		END Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechMemoryStream
	' IID: {EEB14B68-808B-4ABE-A5EA-B51DA7588008}
	' Documentation string: ISpeechMemoryStream Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = ISpeechBaseStream
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __ISpeechMemoryStream_INTERFACE_DEFINED__
		#define __ISpeechMemoryStream_INTERFACE_DEFINED__
		
		Type ISpeechMemoryStream_ Extends ISpeechBaseStream
			Declare Abstract Function SetData (ByVal Data AS VARIANT) AS HRESULT
			Declare Abstract Function GetData (ByVal pData As VARIANT Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechMMSysAudio
	' IID: {3C76AF6D-1FD7-4831-81D1-3B71D5A13C44}
	' Documentation string: ISpeechMMSysAudio Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = ISpeechAudio
	' Number of methods = 5
	' ########################################################################################
	
	#ifndef __ISpeechMMSysAudio_INTERFACE_DEFINED__
		#define __ISpeechMMSysAudio_INTERFACE_DEFINED__
		
		Type ISpeechMMSysAudio_ Extends ISpeechAudio
			Declare Abstract Function get_DeviceId (ByVal DeviceId As Long Ptr) As HRESULT
			Declare Abstract Function put_DeviceId (ByVal DeviceId As Long) As HRESULT
			Declare Abstract Function get_LineId (ByVal LineId As Long Ptr) As HRESULT
			Declare Abstract Function put_LineId (ByVal LineId As Long) As HRESULT
			Declare Abstract Function get_MMHandle (ByVal Handle As Long Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechObjectToken
	' IID: {C74A3ADC-B727-4500-A84A-B526721C8B8C}
	' Documentation string: ISpeechObjectToken Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 13
	' ########################################################################################
	
	#ifndef __ISpeechObjectToken_INTERFACE_DEFINED__
		#define __ISpeechObjectToken_INTERFACE_DEFINED__
		
		Type ISpeechObjectToken_ Extends Afx_IDispatch
			Declare Abstract Function get_Id (ByVal ObjectId As WString Ptr Ptr) As HRESULT
			Declare Abstract Function get_DataKey (ByVal DataKey As ISpeechDataKey Ptr Ptr) As HRESULT
			Declare Abstract Function get_Category (ByVal Category As ISpeechObjectTokenCategory Ptr Ptr) As HRESULT
			Declare Abstract Function GetDescription (ByVal Locale As Long = 0, ByVal Description As WString Ptr Ptr) As HRESULT
			Declare Abstract Function SetId (ByVal Id As WString Ptr, ByVal CategoryID As WString Ptr, ByVal CreateIfNotExist As VARIANT_BOOL = 0) As HRESULT
			Declare Abstract Function GetAttribute (ByVal AttributeName As WString Ptr, ByVal AttributeValue As WString Ptr Ptr) As HRESULT
			Declare Abstract Function CreateInstance (ByVal pUnkOuter As Afx_IUnknown Ptr, ByVal ClsContext As SpeechTokenContext = 23, ByVal Object As Afx_IUnknown Ptr Ptr) As HRESULT
			Declare Abstract Function Remove (ByVal ObjectStorageCLSID As WString Ptr) As HRESULT
			Declare Abstract Function GetStorageFileName (ByVal ObjectStorageCLSID As WString Ptr, ByVal KeyName As WString Ptr, ByVal FileName As WString Ptr, ByVal Folder As SpeechTokenShellFolder, ByVal FilePath As WString Ptr Ptr) As HRESULT
			Declare Abstract Function RemoveStorageFileName (ByVal ObjectStorageCLSID As WString Ptr, ByVal KeyName As WString Ptr, ByVal DeleteFile As VARIANT_BOOL) As HRESULT
			Declare Abstract Function IsUISupported (ByVal TypeOfUI As WString Ptr, ByVal ExtraData As VARIANT Ptr, ByVal Object As Afx_IUnknown Ptr, ByVal Supported As VARIANT_BOOL Ptr) As HRESULT
			Declare Abstract Function DisplayUI (ByVal hWnd AS Long, ByVal Title AS WString Ptr, ByVal TypeOfUI AS WString Ptr, ByVal ExtraData AS VARIANT Ptr, ByVal Object AS Afx_IUnknown Ptr) AS HRESULT
			Declare Abstract Function MatchesAttributes (ByVal Attributes AS WString Ptr, ByVal Matches AS VARIANT_BOOL Ptr) AS HRESULT
		END Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechObjectTokenCategory
	' IID: {CA7EAC50-2D01-4145-86D4-5AE7D70F4469}
	' Documentation string: ISpeechObjectTokenCategory Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 6
	' ########################################################################################
	
	#ifndef __ISpeechObjectTokenCategory_INTERFACE_DEFINED__
		#define __ISpeechObjectTokenCategory_INTERFACE_DEFINED__
		
		Type ISpeechObjectTokenCategory_ Extends Afx_IDispatch
			Declare Abstract Function get_Id (ByVal Id AS WString Ptr Ptr) AS HRESULT
			Declare Abstract Function put_Default (ByVal TokenId AS WString Ptr) AS HRESULT
			Declare Abstract Function get_Default (ByVal TokenId As WString Ptr Ptr) As HRESULT
			Declare Abstract Function SetId (ByVal Id As WString Ptr, ByVal CreateIfNotExist As VARIANT_BOOL = 0) As HRESULT
			Declare Abstract Function GetDataKey (ByVal Location As SpeechDataKeyLocation = 0, ByVal DataKey As ISpeechDataKey Ptr Ptr) As HRESULT
			Declare Abstract Function EnumerateTokens (ByVal RequiredAttributes As WString Ptr, ByVal OptionalAttributes As WString Ptr, ByVal Tokens As ISpeechObjectTokens Ptr Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechObjectTokens
	' IID: {9285B776-2E7B-4BC0-B53E-580EB6FA967F}
	' Documentation string: ISpeechObjectTokens Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __ISpeechObjectTokens_INTERFACE_DEFINED__
		#define __ISpeechObjectTokens_INTERFACE_DEFINED__
		
		Type ISpeechObjectTokens_ Extends Afx_IDispatch
			Declare Abstract Function get_Count (ByVal Count As Long Ptr) As HRESULT
			Declare Abstract Function Item (ByVal Index As Long, ByVal Token As ISpeechObjectToken Ptr Ptr) As HRESULT
			Declare Abstract Function get__NewEnum (ByVal ppEnumVARIANT As Afx_IUnknown Ptr Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechPhoneConverter
	' IID: {C3E4F353-433F-43D6-89A1-6A62A7054C3D}
	' Documentation string: ISpeechPhoneConverter Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 4
	' ########################################################################################
	
	#ifndef __ISpeechPhoneConverter_INTERFACE_DEFINED__
		#define __ISpeechPhoneConverter_INTERFACE_DEFINED__
		
		Type ISpeechPhoneConverter_ Extends Afx_IDispatch
			Declare Abstract Function get_LanguageId (ByVal LanguageId As Long Ptr) As HRESULT
			Declare Abstract Function put_LanguageId (ByVal LanguageId As Long) As HRESULT
			Declare Abstract Function PhoneToId (ByVal Phonemes AS WString Ptr, ByVal IdArray AS VARIANT Ptr) AS HRESULT
			Declare Abstract Function IdToPhone (ByVal IdArray As VARIANT, ByVal Phonemes As WString Ptr Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechPhraseAlternate
	' IID: {27864A2A-2B9F-4CB8-92D3-0D2722FD1E73}
	' Documentation string: ISpeechPhraseAlternate Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 5
	' ########################################################################################
	
	#ifndef __ISpeechPhraseAlternate_INTERFACE_DEFINED__
		#define __ISpeechPhraseAlternate_INTERFACE_DEFINED__
		
		Type ISpeechPhraseAlternate_ Extends Afx_IDispatch
			Declare Abstract Function get_RecoResult (ByVal RecoResult As ISpeechRecoResult Ptr Ptr) As HRESULT
			Declare Abstract Function get_StartElementInResult (ByVal StartElement As Long Ptr) As HRESULT
			Declare Abstract Function get_NumberOfElementsInResult (ByVal NumberOfElements As Long Ptr) As HRESULT
			Declare Abstract Function get_PhraseInfo (ByVal PhraseInfo As ISpeechPhraseInfo Ptr Ptr) As HRESULT
			Declare Abstract Function Commit () As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechPhraseAlternates
	' IID: {B238B6D5-F276-4C3D-A6C1-2974801C3CC2}
	' Documentation string: ISpeechPhraseAlternates Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __ISpeechPhraseAlternates_INTERFACE_DEFINED__
		#define __ISpeechPhraseAlternates_INTERFACE_DEFINED__
		
		Type ISpeechPhraseAlternates_ Extends Afx_IDispatch
			Declare Abstract Function get_Count (ByVal Count As Long Ptr) As HRESULT
			Declare Abstract Function Item (ByVal Index As Long, ByVal PhraseAlternate As ISpeechPhraseAlternate Ptr Ptr) As HRESULT
			Declare Abstract Function get__NewEnum (ByVal EnumVARIANT As Afx_IUnknown Ptr Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechPhraseElement
	' IID: {E6176F96-E373-4801-B223-3B62C068C0B4}
	' Documentation string: ISpeechPhraseElement Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 13
	' ########################################################################################
	
	#ifndef __ISpeechPhraseElement_INTERFACE_DEFINED__
		#define __ISpeechPhraseElement_INTERFACE_DEFINED__
		
		Type ISpeechPhraseElement_ Extends Afx_IDispatch
			Declare Abstract Function get_AudioTimeOffset (ByVal AudioTimeOffset AS Long Ptr) AS HRESULT
			Declare Abstract Function get_AudioSizeTime (ByVal AudioSizeTime AS Long Ptr) AS HRESULT
			Declare Abstract Function get_AudioStreamOffset (ByVal AudioStreamOffset AS Long Ptr) AS HRESULT
			Declare Abstract Function get_AudioSizeBytes (ByVal AudioSizeBytes AS Long Ptr) AS HRESULT
			Declare Abstract Function get_RetainedStreamOffset (ByVal RetainedStreamOffset AS Long Ptr) AS HRESULT
			Declare Abstract Function get_RetainedSizeBytes (ByVal RetainedSizeBytes AS Long Ptr) AS HRESULT
			Declare Abstract Function get_DisplayText (ByVal DisplayText AS WString Ptr Ptr) AS HRESULT
			Declare Abstract Function get_LexicalForm (ByVal LexicalForm AS WString Ptr Ptr) AS HRESULT
			Declare Abstract Function get_Pronunciation (ByVal Pronunciation AS VARIANT Ptr) AS HRESULT
			Declare Abstract Function get_DisplayAttributes (ByVal DisplayAttributes AS SpeechDisplayAttributes Ptr) AS HRESULT
			Declare Abstract Function get_RequiredConfidence (ByVal RequiredConfidence AS SpeechEngineConfidence Ptr) AS HRESULT
			Declare Abstract Function get_ActualConfidence (ByVal ActualConfidence AS SpeechEngineConfidence Ptr) AS HRESULT
			Declare Abstract Function get_EngineConfidence (ByVal EngineConfidence AS SINGLE Ptr) AS HRESULT
		END Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechPhraseElements
	' IID: {0626B328-3478-467D-A0B3-D0853B93DDA3}
	' Documentation string: ISpeechPhraseElements Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __ISpeechPhraseElements_INTERFACE_DEFINED__
		#define __ISpeechPhraseElements_INTERFACE_DEFINED__
		
		Type ISpeechPhraseElements_ Extends Afx_IDispatch
			Declare Abstract Function get_Count (ByVal Count As Long Ptr) As HRESULT
			Declare Abstract Function Item (ByVal Index As Long, ByVal Element As ISpeechPhraseElement Ptr Ptr) As HRESULT
			Declare Abstract Function get__NewEnum (ByVal EnumVARIANT As Afx_IUnknown Ptr Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechPhraseInfo
	' IID: {961559CF-4E67-4662-8BF0-D93F1FCD61B3}
	' Documentation string: ISpeechPhraseInfo Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 16
	' ########################################################################################
	
	#ifndef __ISpeechPhraseInfo_INTERFACE_DEFINED__
		#define __ISpeechPhraseInfo_INTERFACE_DEFINED__
		
		Type ISpeechPhraseInfo_ Extends Afx_IDispatch
			Declare Abstract Function get_LanguageId (ByVal LanguageId As Long Ptr) As HRESULT
			Declare Abstract Function get_GrammarId (ByVal GrammarId As VARIANT Ptr) As HRESULT
			Declare Abstract Function get_StartTime (ByVal StartTime As VARIANT Ptr) As HRESULT
			Declare Abstract Function get_AudioStreamPosition (ByVal AudioStreamPosition As VARIANT Ptr) As HRESULT
			Declare Abstract Function get_AudioSizeBytes (ByVal pAudioSizeBytes As Long Ptr) As HRESULT
			Declare Abstract Function get_RetainedSizeBytes (ByVal RetainedSizeBytes As Long Ptr) As HRESULT
			Declare Abstract Function get_AudioSizeTime (ByVal AudioSizeTime As Long Ptr) As HRESULT
			Declare Abstract Function get_Rule (ByVal Rule As ISpeechPhraseRule Ptr Ptr) As HRESULT
			Declare Abstract Function get_Properties (ByVal Properties As ISpeechPhraseProperties Ptr Ptr) As HRESULT
			Declare Abstract Function get_Elements (ByVal Elements As ISpeechPhraseElements Ptr Ptr) As HRESULT
			Declare Abstract Function get_Replacements (ByVal Replacements As ISpeechPhraseReplacements Ptr Ptr) As HRESULT
			Declare Abstract Function get_EngineId (ByVal EngineIdGuid As WString Ptr Ptr) As HRESULT
			Declare Abstract Function get_EnginePrivateData (ByVal PrivateData As VARIANT Ptr) As HRESULT
			Declare Abstract Function SaveToMemory (ByVal PhraseBlock As VARIANT Ptr) As HRESULT
			Declare Abstract Function GetText (ByVal StartElement As Long = 0, ByVal Elements As Long = -1, ByVal UseReplacements As VARIANT_BOOL = -1, ByVal Text As WString Ptr Ptr) As HRESULT
			Declare Abstract Function GetDisplayAttributes (ByVal StartElement As Long = 0, ByVal Elements As Long = -1, ByVal UseReplacements As VARIANT_BOOL = -1, ByVal DisplayAttributes As SpeechDisplayAttributes Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechPhraseInfoBuilder
	' IID: {3B151836-DF3A-4E0A-846C-D2ADC9334333}
	' Documentation string: ISpeechPhraseInfoBuilder Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 1
	' ########################################################################################
	
	#ifndef __ISpeechPhraseInfoBuilder_INTERFACE_DEFINED__
		#define __ISpeechPhraseInfoBuilder_INTERFACE_DEFINED__
		
		Type ISpeechPhraseInfoBuilder_ Extends Afx_IDispatch
			Declare Abstract Function RestorePhraseFromMemory (ByVal PhraseInMemory As VARIANT Ptr, ByVal PhraseInfo As ISpeechPhraseInfo Ptr Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechPhraseProperties
	' IID: {08166B47-102E-4B23-A599-BDB98DBFD1F4}
	' Documentation string: ISpeechPhraseProperties Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __ISpeechPhraseProperties_INTERFACE_DEFINED__
		#define __ISpeechPhraseProperties_INTERFACE_DEFINED__
		
		Type ISpeechPhraseProperties_ Extends Afx_IDispatch
			Declare Abstract Function get_Count (ByVal Count As Long Ptr) As HRESULT
			Declare Abstract Function Item (ByVal Index As Long, ByVal Property As ISpeechPhraseProperty Ptr Ptr) As HRESULT
			Declare Abstract Function get__NewEnum (ByVal EnumVARIANT As Afx_IUnknown Ptr Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechPhraseProperty
	' IID: {CE563D48-961E-4732-A2E1-378A42B430BE}
	' Documentation string: ISpeechPhraseProperty Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 9
	' ########################################################################################
	
	#ifndef __ISpeechPhraseProperty_INTERFACE_DEFINED__
		#define __ISpeechPhraseProperty_INTERFACE_DEFINED__
		
		Type ISpeechPhraseProperty_ Extends Afx_IDispatch
			Declare Abstract Function get_Name (ByVal Name As WString Ptr Ptr) As HRESULT
			Declare Abstract Function get_Id (ByVal Id As Long Ptr) As HRESULT
			Declare Abstract Function get_Value (ByVal Value As VARIANT Ptr) As HRESULT
			Declare Abstract Function get_FirstElement (ByVal FirstElement As Long Ptr) As HRESULT
			Declare Abstract Function get_NumberOfElements (ByVal NumberOfElements As Long Ptr) As HRESULT
			Declare Abstract Function get_EngineConfidence (ByVal Confidence As Single Ptr) As HRESULT
			Declare Abstract Function get_Confidence (ByVal Confidence As SpeechEngineConfidence Ptr) As HRESULT
			Declare Abstract Function get_Parent (ByVal ParentProperty As ISpeechPhraseProperty Ptr Ptr) As HRESULT
			Declare Abstract Function get_Children (ByVal Children As ISpeechPhraseProperties Ptr Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechPhraseReplacement
	' IID: {2890A410-53A7-4FB5-94EC-06D4998E3D02}
	' Documentation string: ISpeechPhraseReplacement Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 4
	' ########################################################################################
	
	#ifndef __ISpeechPhraseReplacement_INTERFACE_DEFINED__
		#define __ISpeechPhraseReplacement_INTERFACE_DEFINED__
		
		Type ISpeechPhraseReplacement_ Extends Afx_IDispatch
			Declare Abstract Function get_DisplayAttributes (ByVal DisplayAttributes AS SpeechDisplayAttributes Ptr) AS HRESULT
			Declare Abstract Function get_Text (ByVal Text AS WString Ptr Ptr) AS HRESULT
			Declare Abstract Function get_FirstElement (ByVal FirstElement AS Long Ptr) AS HRESULT
			Declare Abstract Function get_NumberOfElements (ByVal NumberOfElements AS Long Ptr) AS HRESULT
		END Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechPhraseReplacements
	' IID: {38BC662F-2257-4525-959E-2069D2596C05}
	' Documentation string: ISpeechPhraseReplacements Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __ISpeechPhraseReplacements_INTERFACE_DEFINED__
		#define __ISpeechPhraseReplacements_INTERFACE_DEFINED__
		
		Type ISpeechPhraseReplacements_ Extends Afx_IDispatch
			Declare Abstract Function get_Count (ByVal Count AS Long Ptr) AS HRESULT
			Declare Abstract Function Item (ByVal Index AS Long, ByVal Reps AS ISpeechPhraseReplacement Ptr Ptr) AS HRESULT
			Declare Abstract Function get__NewEnum (ByVal EnumVARIANT AS Afx_IUnknown Ptr Ptr) AS HRESULT
		END Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechPhraseRule
	' IID: {A7BFE112-A4A0-48D9-B602-C313843F6964}
	' Documentation string: ISpeechPhraseRule Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 8
	' ########################################################################################
	
	#ifndef __ISpeechPhraseRule_INTERFACE_DEFINED__
		#define __ISpeechPhraseRule_INTERFACE_DEFINED__
		
		Type ISpeechPhraseRule_ Extends Afx_IDispatch
			Declare Abstract Function get_Name (ByVal Name As WString Ptr Ptr) As HRESULT
			Declare Abstract Function get_Id (ByVal Id As Long Ptr) As HRESULT
			Declare Abstract Function get_FirstElement (ByVal FirstElement As Long Ptr) As HRESULT
			Declare Abstract Function get_NumberOfElements (ByVal NumberOfElements As Long Ptr) As HRESULT
			Declare Abstract Function get_Parent (ByVal Parent As ISpeechPhraseRule Ptr Ptr) As HRESULT
			Declare Abstract Function get_Children (ByVal Children As ISpeechPhraseRules Ptr Ptr) As HRESULT
			Declare Abstract Function get_Confidence (ByVal ActualConfidence As SpeechEngineConfidence Ptr) As HRESULT
			Declare Abstract Function get_EngineConfidence (ByVal EngineConfidence As Single Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechPhraseRules
	' IID: {9047D593-01DD-4B72-81A3-E4A0CA69F407}
	' Documentation string: ISpeechPhraseRules Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __ISpeechPhraseRules_INTERFACE_DEFINED__
		#define __ISpeechPhraseRules_INTERFACE_DEFINED__
		
		Type ISpeechPhraseRules_ Extends Afx_IDispatch
			Declare Abstract Function get_Count (ByVal Count As Long Ptr) As HRESULT
			Declare Abstract Function Item (ByVal Index As Long, ByVal Rule As ISpeechPhraseRule Ptr Ptr) As HRESULT
			Declare Abstract Function get__NewEnum (ByVal EnumVARIANT As Afx_IUnknown Ptr Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechRecoContext
	' IID: {580AA49D-7E1E-4809-B8E2-57DA806104B8}
	' Documentation string: ISpeechRecoContext Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 25
	' ########################################################################################
	
	#ifndef __ISpeechRecoContext_INTERFACE_DEFINED__
		#define __ISpeechRecoContext_INTERFACE_DEFINED__
		
		Type ISpeechRecoContext_ Extends Afx_IDispatch
			Declare Abstract Function get_Recognizer (ByVal Recognizer As ISpeechRecognizer Ptr Ptr) As HRESULT
			Declare Abstract Function get_AudioInputInterferenceStatus (ByVal Interference As SpeechInterference Ptr) As HRESULT
			Declare Abstract Function get_RequestedUIType (ByVal UIType As WString Ptr Ptr) As HRESULT
			Declare Abstract Function putref_Voice (ByVal Voice As ISpeechVoice Ptr) As HRESULT
			Declare Abstract Function get_Voice (ByVal Voice As ISpeechVoice Ptr Ptr) As HRESULT
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
			Declare Abstract Function putref_RetainedAudioFormat (ByVal Format As ISpeechAudioFormat Ptr) As HRESULT
			Declare Abstract Function get_RetainedAudioFormat (ByVal Format As ISpeechAudioFormat Ptr Ptr) As HRESULT
			Declare Abstract Function Pause () As HRESULT
			Declare Abstract Function Resume () As HRESULT
			Declare Abstract Function CreateGrammar (ByVal GrammarId As VARIANT = Type<VARIANT>(VT_ERROR,0,0,0,DISP_E_PARAMNOTFOUND), ByVal Grammar As ISpeechRecoGrammar Ptr Ptr) As HRESULT
			Declare Abstract Function CreateResultFromMemory (ByVal ResultBlock As VARIANT Ptr, ByVal Result As ISpeechRecoResult Ptr Ptr) As HRESULT
			Declare Abstract Function Bookmark (ByVal Options As SpeechBookmarkOptions, ByVal StreamPos As VARIANT, ByVal BookmarkId As VARIANT) As HRESULT
			Declare Abstract Function SetAdaptationData (ByVal AdaptationString As WString Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechRecognizer
	' IID: {2D5F1C0C-BD75-4B08-9478-3B11FEA2586C}
	' Documentation string: ISpeechRecognizer Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 26
	' ########################################################################################
	
	#ifndef __ISpeechRecognizer_INTERFACE_DEFINED__
		#define __ISpeechRecognizer_INTERFACE_DEFINED__
		
		Type ISpeechRecognizer_ Extends Afx_IDispatch
			Declare Abstract Function putref_Recognizer (ByVal Recognizer As ISpeechObjectToken Ptr) As HRESULT
			Declare Abstract Function get_Recognizer (ByVal Recognizer As ISpeechObjectToken Ptr Ptr) As HRESULT
			Declare Abstract Function put_AllowAudioInputFormatChangesOnNextSet (ByVal Allow As VARIANT_BOOL) As HRESULT
			Declare Abstract Function get_AllowAudioInputFormatChangesOnNextSet (ByVal Allow As VARIANT_BOOL Ptr) As HRESULT
			Declare Abstract Function putref_AudioInput (ByVal AudioInput As ISpeechObjectToken Ptr = 0) As HRESULT
			Declare Abstract Function get_AudioInput (ByVal AudioInput As ISpeechObjectToken Ptr Ptr) As HRESULT
			Declare Abstract Function putref_AudioInputStream (ByVal AudioInputStream As ISpeechBaseStream Ptr = 0) As HRESULT
			Declare Abstract Function get_AudioInputStream (ByVal AudioInputStream As ISpeechBaseStream Ptr Ptr) As HRESULT
			Declare Abstract Function get_IsShared (ByVal Shared As VARIANT_BOOL Ptr) As HRESULT
			Declare Abstract Function put_State (ByVal State As SpeechRecognizerState) As HRESULT
			Declare Abstract Function get_State (ByVal State AS SpeechRecognizerState Ptr) AS HRESULT
			Declare Abstract Function get_Status (ByVal Status AS ISpeechRecognizerStatus Ptr Ptr) AS HRESULT
			Declare Abstract Function putref_Profile (ByVal Profile AS ISpeechObjectToken Ptr = 0) AS HRESULT
			Declare Abstract Function get_Profile (ByVal Profile AS ISpeechObjectToken Ptr Ptr) AS HRESULT
			Declare Abstract Function EmulateRecognition (ByVal TextElements As VARIANT, ByVal ElementDisplayAttributes As VARIANT Ptr, ByVal LanguageId As Long = 0) As HRESULT
			Declare Abstract Function CreateRecoContext (ByVal NewContext As ISpeechRecoContext Ptr Ptr) As HRESULT
			Declare Abstract Function GetFormat (ByVal Type As SpeechFormatType, ByVal Format As ISpeechAudioFormat Ptr Ptr) As HRESULT
			Declare Abstract Function SetPropertyNumber (ByVal Name As WString Ptr, ByVal Value As Long, ByVal Supported As VARIANT_BOOL Ptr) As HRESULT
			Declare Abstract Function GetPropertyNumber (ByVal Name As WString Ptr, ByVal Value As Long Ptr, ByVal Supported As VARIANT_BOOL Ptr) As HRESULT
			Declare Abstract Function SetPropertyString (ByVal Name As WString Ptr, ByVal Value As WString Ptr, ByVal Supported As VARIANT_BOOL Ptr) As HRESULT
			Declare Abstract Function GetPropertyString (ByVal Name As WString Ptr, ByVal Value As WString Ptr Ptr, ByVal Supported As VARIANT_BOOL Ptr) As HRESULT
			Declare Abstract Function IsUISupported (ByVal TypeOfUI As WString Ptr, ByVal ExtraData As VARIANT Ptr, ByVal Supported As VARIANT_BOOL Ptr) As HRESULT
			Declare Abstract Function DisplayUI (ByVal hWndParent As Long, ByVal Title As WString Ptr, ByVal TypeOfUI As WString Ptr, ByVal ExtraData As VARIANT Ptr) As HRESULT
			Declare Abstract Function GetRecognizers (ByVal RequiredAttributes As WString Ptr, ByVal OptionalAttributes As WString Ptr, ByVal ObjectTokens As ISpeechObjectTokens Ptr Ptr) As HRESULT
			Declare Abstract Function GetAudioInputs (ByVal RequiredAttributes As WString Ptr, ByVal OptionalAttributes As WString Ptr, ByVal ObjectTokens As ISpeechObjectTokens Ptr Ptr) As HRESULT
			Declare Abstract Function GetProfiles (ByVal RequiredAttributes As WString Ptr, ByVal OptionalAttributes As WString Ptr, ByVal ObjectTokens As ISpeechObjectTokens Ptr Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechRecognizerStatus
	' IID: {BFF9E781-53EC-484E-BB8A-0E1B5551E35C}
	' Documentation string: ISpeechRecognizerStatus Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 6
	' ########################################################################################
	
	#ifndef __ISpeechRecognizerStatus_INTERFACE_DEFINED__
		#define __ISpeechRecognizerStatus_INTERFACE_DEFINED__
		
		Type ISpeechRecognizerStatus_ Extends Afx_IDispatch
			Declare Abstract Function get_AudioStatus (ByVal AudioStatus As ISpeechAudioStatus Ptr Ptr) As HRESULT
			Declare Abstract Function get_CurrentStreamPosition (ByVal pCurrentStreamPos As VARIANT Ptr) As HRESULT
			Declare Abstract Function get_CurrentStreamNumber (ByVal StreamNumber As Long Ptr) As HRESULT
			Declare Abstract Function get_NumberOfActiveRules (ByVal NumberOfActiveRules As Long Ptr) As HRESULT
			Declare Abstract Function get_ClsidEngine (ByVal ClsidEngine As WString Ptr Ptr) As HRESULT
			Declare Abstract Function get_SupportedLanguages (ByVal SupportedLanguages As VARIANT Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechRecoGrammar
	' IID: {B6D6F79F-2158-4E50-B5BC-9A9CCD852A09}
	' Documentation string: ISpeechRecoGrammar Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 19
	' ########################################################################################
	
	#ifndef __ISpeechRecoGrammar_INTERFACE_DEFINED__
		#define __ISpeechRecoGrammar_INTERFACE_DEFINED__
		
		Type ISpeechRecoGrammar_ Extends Afx_IDispatch
			Declare Abstract Function get_Id (ByVal Id As VARIANT Ptr) As HRESULT
			Declare Abstract Function get_RecoContext (ByVal RecoContext As ISpeechRecoContext Ptr Ptr) As HRESULT
			Declare Abstract Function put_State (ByVal State As SpeechGrammarState) As HRESULT
			Declare Abstract Function get_State (ByVal State As SpeechGrammarState Ptr) As HRESULT
			Declare Abstract Function get_Rules (ByVal Rules As ISpeechGrammarRules Ptr Ptr) As HRESULT
			Declare Abstract Function Reset (ByVal NewLanguage As Long = 0) As HRESULT
			Declare Abstract Function CmdLoadFromFile (ByVal FileName As WString Ptr, ByVal LoadOption As SpeechLoadOption = 0) As HRESULT
			Declare Abstract Function CmdLoadFromObject (ByVal ClassId As WString Ptr, ByVal GrammarName As WString Ptr, ByVal LoadOption As SpeechLoadOption = 0) As HRESULT
			Declare Abstract Function CmdLoadFromResource (ByVal hModule As Long, ByVal ResourceName As VARIANT, ByVal ResourceType As VARIANT, ByVal LanguageId As Long, ByVal LoadOption As SpeechLoadOption = 0) As HRESULT
			Declare Abstract Function CmdLoadFromMemory (ByVal GrammarData As VARIANT, ByVal LoadOption As SpeechLoadOption = 0) As HRESULT
			Declare Abstract Function CmdLoadFromProprietaryGrammar (ByVal ProprietaryGuid As WString Ptr, ByVal ProprietaryString As WString Ptr, ByVal ProprietaryData As VARIANT, ByVal LoadOption As SpeechLoadOption = 0) As HRESULT
			Declare Abstract Function CmdSetRuleState (ByVal Name As WString Ptr, ByVal State As SpeechRuleState) As HRESULT
			Declare Abstract Function CmdSetRuleIdState (ByVal RuleId As Long, ByVal State As SpeechRuleState) As HRESULT
			Declare Abstract Function DictationLoad (ByVal TopicName As WString Ptr, ByVal LoadOption As SpeechLoadOption = 0) As HRESULT
			Declare Abstract Function DictationUnload () As HRESULT
			Declare Abstract Function DictationSetState (ByVal State As SpeechRuleState) As HRESULT
			Declare Abstract Function SetWordSequenceData (ByVal Text As WString Ptr, ByVal TextLength As Long, ByVal Info As ISpeechTextSelectionInformation Ptr) As HRESULT
			Declare Abstract Function SetTextSelection (ByVal Info As ISpeechTextSelectionInformation Ptr) As HRESULT
			Declare Abstract Function IsPronounceable (ByVal Word As WString Ptr, ByVal WordPronounceable As SpeechWordPronounceable Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechRecoResult
	' IID: {ED2879CF-CED9-4EE6-A534-DE0191D5468D}
	' Documentation string: ISpeechRecoResult Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 10
	' ########################################################################################
	
	#ifndef __ISpeechRecoResult_INTERFACE_DEFINED__
		#define __ISpeechRecoResult_INTERFACE_DEFINED__
		
		Type ISpeechRecoResult_ Extends Afx_IDispatch
			Declare Abstract Function get_RecoContext (ByVal RecoContext As ISpeechRecoContext Ptr Ptr) As HRESULT
			Declare Abstract Function get_Times (ByVal Times As ISpeechRecoResultTimes Ptr Ptr) As HRESULT
			Declare Abstract Function putref_AudioFormat (ByVal Format As ISpeechAudioFormat Ptr) As HRESULT
			Declare Abstract Function get_AudioFormat (ByVal Format As ISpeechAudioFormat Ptr Ptr) As HRESULT
			Declare Abstract Function get_PhraseInfo (ByVal PhraseInfo As ISpeechPhraseInfo Ptr Ptr) As HRESULT
			Declare Abstract Function Alternates (ByVal RequestCount As Long, ByVal StartElement As Long = 0, ByVal Elements As Long = -1, ByVal Alternates As ISpeechPhraseAlternates Ptr Ptr) As HRESULT
			Declare Abstract Function Audio (ByVal StartElement As Long = 0, ByVal Elements As Long = -1, ByVal Stream As ISpeechMemoryStream Ptr Ptr) As HRESULT
			Declare Abstract Function SpeakAudio (ByVal StartElement As Long = 0, ByVal Elements As Long = -1, ByVal Flags As SpeechVoiceSpeakFlags = 0, ByVal StreamNumber As Long Ptr) As HRESULT
			Declare Abstract Function SaveToMemory (ByVal ResultBlock As VARIANT Ptr) As HRESULT
			Declare Abstract Function DiscardResultInfo (ByVal ValueTypes As SpeechDiscardType) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechRecoResult2
	' IID: {8E0A246D-D3C8-45DE-8657-04290C458C3C}
	' Documentation string: ISpeechRecoResult2 Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = ISpeechRecoResult
	' Number of methods = 1
	' ########################################################################################
	
	#ifndef __ISpeechRecoResult2_INTERFACE_DEFINED__
		#define __ISpeechRecoResult2_INTERFACE_DEFINED__
		
		Type ISpeechRecoResult2_ Extends ISpeechRecoResult
			Declare Abstract Function SetTextFeedback (ByVal Feedback AS WString Ptr, ByVal WasSuccessful AS VARIANT_BOOL) AS HRESULT
		END Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechRecoResultDispatch
	' IID: {6D60EB64-ACED-40A6-BBF3-4E557F71DEE2}
	' Documentation string: ISpeechRecoResultDispatch Interface
	' Attributes =  4432 [&h00001150] [Hidden] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 13
	' ########################################################################################
	
	#ifndef __ISpeechRecoResultDispatch_INTERFACE_DEFINED__
		#define __ISpeechRecoResultDispatch_INTERFACE_DEFINED__
		
		Type ISpeechRecoResultDispatch_ Extends Afx_IDispatch
			Declare Abstract Function get_RecoContext (ByVal RecoContext AS ISpeechRecoContext Ptr Ptr) AS HRESULT
			Declare Abstract Function get_Times (ByVal Times AS ISpeechRecoResultTimes Ptr Ptr) AS HRESULT
			Declare Abstract Function putref_AudioFormat (ByVal Format AS ISpeechAudioFormat Ptr) AS HRESULT
			Declare Abstract Function get_AudioFormat (ByVal Format AS ISpeechAudioFormat Ptr Ptr) AS HRESULT
			Declare Abstract Function get_PhraseInfo (ByVal PhraseInfo AS ISpeechPhraseInfo Ptr Ptr) AS HRESULT
			Declare Abstract Function Alternates (ByVal RequestCount AS Long, ByVal StartElement AS Long = 0, ByVal Elements AS Long = -1, ByVal Alternates AS ISpeechPhraseAlternates Ptr Ptr) AS HRESULT
			Declare Abstract Function Audio (ByVal StartElement AS Long = 0, ByVal Elements AS Long = -1, ByVal Stream AS ISpeechMemoryStream Ptr Ptr) AS HRESULT
			Declare Abstract Function SpeakAudio (ByVal StartElement AS Long = 0, ByVal Elements AS Long = -1, ByVal Flags AS SpeechVoiceSpeakFlags = 0, ByVal StreamNumber AS Long Ptr) AS HRESULT
			Declare Abstract Function SaveToMemory (ByVal ResultBlock AS VARIANT Ptr) AS HRESULT
			Declare Abstract Function DiscardResultInfo (ByVal ValueTypes AS SpeechDiscardType) AS HRESULT
			Declare Abstract Function GetXMLResult (ByVal Options AS SPXMLRESULTOPTIONS, ByVal pResult AS WString Ptr Ptr) AS HRESULT
			Declare Abstract Function GetXMLErrorInfo (ByVal LineNumber AS Long Ptr, ByVal ScriptLine AS WString Ptr Ptr, ByVal Source AS WString Ptr Ptr, ByVal Description AS WString Ptr Ptr, ByVal ResultCode AS HRESULT Ptr, ByVal IsError AS VARIANT_BOOL Ptr) AS HRESULT
			Declare Abstract Function SetTextFeedback (ByVal Feedback AS WString Ptr, ByVal WasSuccessful AS VARIANT_BOOL) AS HRESULT
		END Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechRecoResultTimes
	' IID: {62B3B8FB-F6E7-41BE-BDCB-056B1C29EFC0}
	' Documentation string: ISpeechRecoResultTimes Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 4
	' ########################################################################################
	
	#ifndef __ISpeechRecoResultTimes_INTERFACE_DEFINED__
		#define __ISpeechRecoResultTimes_INTERFACE_DEFINED__
		
		Type ISpeechRecoResultTimes_ Extends Afx_IDispatch
			Declare Abstract Function get_StreamTime (ByVal Time AS VARIANT Ptr) AS HRESULT
			Declare Abstract Function get_Length (ByVal Length AS VARIANT Ptr) AS HRESULT
			Declare Abstract Function get_TickCount (ByVal TickCount AS Long Ptr) AS HRESULT
			Declare Abstract Function get_OffsetFromStart (ByVal OffsetFromStart AS VARIANT Ptr) AS HRESULT
		END Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechResourceLoader
	' IID: {B9AC5783-FCD0-4B21-B119-B4F8DA8FD2C3}
	' Documentation string: ISpeechResourceLoader Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __ISpeechResourceLoader_INTERFACE_DEFINED__
		#define __ISpeechResourceLoader_INTERFACE_DEFINED__
		
		Type ISpeechResourceLoader_ Extends Afx_IDispatch
			Declare Abstract Function LoadResource (ByVal bstrResourceUri As WString Ptr, ByVal fAlwaysReload As VARIANT_BOOL, ByVal pStream As Afx_IUnknown Ptr Ptr, ByVal pbstrMIMEType As WString Ptr Ptr, ByVal pfModified As VARIANT_BOOL Ptr, ByVal pbstrRedirectUrl As WString Ptr Ptr) As HRESULT
			Declare Abstract Function GetLocalCopy (ByVal bstrResourceUri As WString Ptr, ByVal pbstrLocalPath As WString Ptr Ptr, ByVal pbstrMIMEType As WString Ptr Ptr, ByVal pbstrRedirectUrl As WString Ptr Ptr) As HRESULT
			Declare Abstract Function ReleaseLocalCopy (ByVal pbstrLocalPath As WString Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechTextSelectionInformation
	' IID: {3B9C7E7A-6EEE-4DED-9092-11657279ADBE}
	' Documentation string: ISpeechTextSelectionInformation Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 8
	' ########################################################################################
	
	#ifndef __ISpeechTextSelectionInformation_INTERFACE_DEFINED__
		#define __ISpeechTextSelectionInformation_INTERFACE_DEFINED__
		
		Type ISpeechTextSelectionInformation_ Extends Afx_IDispatch
			Declare Abstract Function put_ActiveOffset (ByVal ActiveOffset As Long) As HRESULT
			Declare Abstract Function get_ActiveOffset (ByVal ActiveOffset As Long Ptr) As HRESULT
			Declare Abstract Function put_ActiveLength (ByVal ActiveLength As Long) As HRESULT
			Declare Abstract Function get_ActiveLength (ByVal ActiveLength As Long Ptr) As HRESULT
			Declare Abstract Function put_SelectionOffset (ByVal SelectionOffset As Long) As HRESULT
			Declare Abstract Function get_SelectionOffset (ByVal SelectionOffset As Long Ptr) As HRESULT
			Declare Abstract Function put_SelectionLength (ByVal SelectionLength As Long) As HRESULT
			Declare Abstract Function get_SelectionLength (ByVal SelectionLength As Long Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechVoice
	' IID: {269316D8-57BD-11D2-9EEE-00C04F797396}
	' Documentation string: ISpeechVoice Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 32
	' ########################################################################################
	
	#ifndef __ISpeechVoice_INTERFACE_DEFINED__
		#define __ISpeechVoice_INTERFACE_DEFINED__
		
		Type ISpeechVoice_ Extends Afx_IDispatch
			Declare Abstract Function get_Status (ByVal Status As ISpeechVoiceStatus Ptr Ptr) As HRESULT
			Declare Abstract Function get_Voice (ByVal Voice As ISpeechObjectToken Ptr Ptr) As HRESULT
			Declare Abstract Function putref_Voice (ByVal Voice As ISpeechObjectToken Ptr) As HRESULT
			Declare Abstract Function get_AudioOutput (ByVal AudioOutput As ISpeechObjectToken Ptr Ptr) As HRESULT
			Declare Abstract Function putref_AudioOutput (ByVal AudioOutput As ISpeechObjectToken Ptr) As HRESULT
			Declare Abstract Function get_AudioOutputStream (ByVal AudioOutputStream As ISpeechBaseStream Ptr Ptr) As HRESULT
			Declare Abstract Function putref_AudioOutputStream (ByVal AudioOutputStream As ISpeechBaseStream Ptr) As HRESULT
			Declare Abstract Function get_Rate (ByVal Rate As Long Ptr) As HRESULT
			Declare Abstract Function put_Rate (ByVal Rate As Long) As HRESULT
			Declare Abstract Function get_Volume (ByVal Volume As Long Ptr) As HRESULT
			Declare Abstract Function put_Volume (ByVal Volume As Long) As HRESULT
			Declare Abstract Function put_AllowAudioOutputFormatChangesOnNextSet (ByVal Allow As VARIANT_BOOL) As HRESULT
			Declare Abstract Function get_AllowAudioOutputFormatChangesOnNextSet (ByVal Allow As VARIANT_BOOL Ptr) As HRESULT
			Declare Abstract Function get_EventInterests (ByVal EventInterestFlags As SpeechVoiceEvents Ptr) As HRESULT
			Declare Abstract Function put_EventInterests (ByVal EventInterestFlags As SpeechVoiceEvents) As HRESULT
			Declare Abstract Function put_Priority (ByVal Priority As SpeechVoicePriority) As HRESULT
			Declare Abstract Function get_Priority (ByVal Priority As SpeechVoicePriority Ptr) As HRESULT
			Declare Abstract Function put_AlertBoundary (ByVal Boundary As SpeechVoiceEvents) As HRESULT
			Declare Abstract Function get_AlertBoundary (ByVal Boundary As SpeechVoiceEvents Ptr) As HRESULT
			Declare Abstract Function put_SynchronousSpeakTimeout (ByVal msTimeout As Long) As HRESULT
			Declare Abstract Function get_SynchronousSpeakTimeout (ByVal msTimeout As Long Ptr) As HRESULT
			Declare Abstract Function Speak (ByVal Text As WString Ptr, ByVal Flags As SpeechVoiceSpeakFlags = 0, ByVal StreamNumber As Long Ptr) As HRESULT
			Declare Abstract Function SpeakStream (ByVal Stream As ISpeechBaseStream Ptr, ByVal Flags As SpeechVoiceSpeakFlags = 0, ByVal StreamNumber As Long Ptr) As HRESULT
			Declare Abstract Function Pause () As HRESULT
			Declare Abstract Function Resume () As HRESULT
			Declare Abstract Function Skip (ByVal Type As WString Ptr, ByVal NumItems As Long, ByVal NumSkipped As Long Ptr) As HRESULT
			Declare Abstract Function GetVoices (ByVal RequiredAttributes As WString Ptr, ByVal OptionalAttributes As WString Ptr, ByVal ObjectTokens As ISpeechObjectTokens Ptr Ptr) As HRESULT
			Declare Abstract Function GetAudioOutputs (ByVal RequiredAttributes As WString Ptr, ByVal OptionalAttributes As WString Ptr, ByVal ObjectTokens As ISpeechObjectTokens Ptr Ptr) As HRESULT
			Declare Abstract Function WaitUntilDone (ByVal msTimeout As Long, ByVal Done As VARIANT_BOOL Ptr) As HRESULT
			Declare Abstract Function SpeakCompleteEvent (ByVal Handle As Long Ptr) As HRESULT
			Declare Abstract Function IsUISupported (ByVal TypeOfUI As WString Ptr, ByVal ExtraData As VARIANT Ptr, ByVal Supported As VARIANT_BOOL Ptr) As HRESULT
			Declare Abstract Function DisplayUI (ByVal hWndParent As Long, ByVal Title As WString Ptr, ByVal TypeOfUI As WString Ptr, ByVal ExtraData As VARIANT Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechVoiceStatus
	' IID: {8BE47B07-57F6-11D2-9EEE-00C04F797396}
	' Documentation string: ISpeechVoiceStatus Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 12
	' ########################################################################################
	
	#ifndef __ISpeechVoiceStatus_INTERFACE_DEFINED__
		#define __ISpeechVoiceStatus_INTERFACE_DEFINED__
		
		Type ISpeechVoiceStatus_ Extends Afx_IDispatch
			Declare Abstract Function get_CurrentStreamNumber (ByVal StreamNumber As Long Ptr) As HRESULT
			Declare Abstract Function get_LastStreamNumberQueued (ByVal StreamNumber As Long Ptr) As HRESULT
			Declare Abstract Function get_LastHResult (ByVal HResult As Long Ptr) As HRESULT
			Declare Abstract Function get_RunningState (ByVal State As SpeechRunState Ptr) As HRESULT
			Declare Abstract Function get_InputWordPosition (ByVal Position As Long Ptr) As HRESULT
			Declare Abstract Function get_InputWordLength (ByVal Length As Long Ptr) As HRESULT
			Declare Abstract Function get_InputSentencePosition (ByVal Position As Long Ptr) As HRESULT
			Declare Abstract Function get_InputSentenceLength (ByVal Length As Long Ptr) As HRESULT
			Declare Abstract Function get_LastBookmark (ByVal Bookmark As WString Ptr Ptr) As HRESULT
			Declare Abstract Function get_LastBookmarkId (ByVal BookmarkId As Long Ptr) As HRESULT
			Declare Abstract Function get_PhonemeId (ByVal PhoneId As Short Ptr) As HRESULT
			Declare Abstract Function get_VisemeId (ByVal VisemeId As Short Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechWaveFormatEx
	' IID: {7A1EF0D5-1581-4741-88E4-209A49F11A10}
	' Documentation string: ISpeechWaveFormatEx Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = IDispatch
	' Number of methods = 14
	' ########################################################################################
	
	#ifndef __ISpeechWaveFormatEx_INTERFACE_DEFINED__
		#define __ISpeechWaveFormatEx_INTERFACE_DEFINED__
		
		Type ISpeechWaveFormatEx_ Extends Afx_IDispatch
			Declare Abstract Function get_FormatTag (ByVal FormatTag As Short Ptr) As HRESULT
			Declare Abstract Function put_FormatTag (ByVal FormatTag As Short) As HRESULT
			Declare Abstract Function get_Channels (ByVal Channels As Short Ptr) As HRESULT
			Declare Abstract Function put_Channels (ByVal Channels As Short) As HRESULT
			Declare Abstract Function get_SamplesPerSec (ByVal SamplesPerSec As Long Ptr) As HRESULT
			Declare Abstract Function put_SamplesPerSec (ByVal SamplesPerSec As Long) As HRESULT
			Declare Abstract Function get_AvgBytesPerSec (ByVal AvgBytesPerSec As Long Ptr) As HRESULT
			Declare Abstract Function put_AvgBytesPerSec (ByVal AvgBytesPerSec As Long) As HRESULT
			Declare Abstract Function get_BlockAlign (ByVal BlockAlign As Short Ptr) As HRESULT
			Declare Abstract Function put_BlockAlign (ByVal BlockAlign As Short) As HRESULT
			Declare Abstract Function get_BitsPerSample (ByVal BitsPerSample As Short Ptr) As HRESULT
			Declare Abstract Function put_BitsPerSample (ByVal BitsPerSample As Short) As HRESULT
			Declare Abstract Function get_ExtraData (ByVal ExtraData As VARIANT Ptr) As HRESULT
			Declare Abstract Function put_ExtraData (ByVal ExtraData As VARIANT) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpeechXMLRecoResult
	' IID: {AAEC54AF-8F85-4924-944D-B79D39D72E19}
	' Documentation string: ISpeechXMLRecoResult Interface
	' Attributes =  4416 [&h00001140] [Dual] [Oleautomation] [Dispatchable]
	' Inherited interface = ISpeechRecoResult
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __ISpeechXMLRecoResult_INTERFACE_DEFINED__
		#define __ISpeechXMLRecoResult_INTERFACE_DEFINED__
		
		Type ISpeechXMLRecoResult_ Extends ISpeechRecoResult
			Declare Abstract Function GetXMLResult (ByVal Options As SPXMLRESULTOPTIONS, ByVal pResult As WString Ptr Ptr) As HRESULT
			Declare Abstract Function GetXMLErrorInfo (ByVal LineNumber As Long Ptr, ByVal ScriptLine As WString Ptr Ptr, ByVal Source As WString Ptr Ptr, ByVal Description As WString Ptr Ptr, ByVal ResultCode As Long Ptr, ByVal IsError As VARIANT_BOOL Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name: ISpContainerLexicon
	' IID = {8565572F-C094-41CC-B56E-10BD9C3FF044}
	' Inherited interface = ISpLexicon
	' Number of methods = 1
	' ########################################################################################
	
	#ifndef __ISpContainerLexicon_INTERFACE_DEFINED__
		#define __ISpContainerLexicon_INTERFACE_DEFINED__
		
		Type ISpContainerLexicon_ Extends ISpLexicon
			Declare Abstract Function AddLexicon (ByVal pAddLexicon As ISpLexicon Ptr, ByVal dwFlags As DWORD) As HRESULT
		End Type
	#endif
	
	' ########################################################################################
	' Interface name: ISpEnginePronunciation
	' IID = C360CE4B-76D1-4214-AD68-52657D5083DA
	' Inherited interface = IUnknown
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __ISpEnginePronunciation_INTERFACE_DEFINED__
		#define __ISpEnginePronunciation_INTERFACE_DEFINED__
		
		Type ISpEnginePronunciation_ Extends Afx_IUnknown
			Declare Abstract Function Normalize (ByVal pszWord As LPCWSTR, ByVal pszLeftContext As LPCWSTR, ByVal LangID As WORD, ByVal pNormalizationList As SPNORMALIZATIONLIST Ptr) As HRESULT
			Declare Abstract Function GetPronunciations (ByVal pszWord As LPCWSTR, ByVal pszLeftContext As LPCWSTR, ByVal LangID As WORD, ByVal pEnginePronunciationList As SPWORDPRONUNCIATIONLIST Ptr) As HRESULT
		End Type
	#endif
	
	' ########################################################################################
	' Interface name = ISpEventSource2
	' IID = 2373A435-6A4B-429E-A6AC-D4231A61975B
	' Inherited interface = ISpEventSource
	' Number of methods = 1
	' ########################################################################################
	
	#ifndef __ISpEventSource2_INTERFACE_DEFINED__
		#define __ISpEventSource2_INTERFACE_DEFINED__
		
		Type ISpEventSource2_ Extends ISpEventSource
			Declare Abstract Function GetEventsEx (ByVal ulCount As ULong, ByVal pEventArray As SPEVENTEX Ptr, ByVal pulFetched As ULong Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name = ISpGrammarBuilder2
	' IID = 8AB10026-20CC-4B20-8C22-A49C9BA78F60
	' Inherited interface = IUnknown
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __ISpGrammarBuilder2_INTERFACE_DEFINED__
		#define __ISpGrammarBuilder2_INTERFACE_DEFINED__
		
		Type ISpGrammarBuilder2_ Extends Afx_IUnknown
			Declare Abstract Function AddTextSubset (ByVal hFromState As SPSTATEHANDLE, ByVal hToState As SPSTATEHANDLE, ByVal psz As LPCWSTR, ByVal eMatchMode As SPMATCHINGMODE) As HRESULT
			Declare Abstract Function SetPhoneticAlphabet (ByVal phoneticALphabet As PHONETICALPHABET) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name = ISpObjectTokenInit
	' IID = {B8AAB0CF-346F-49D8-9499-C8B03F161D51}
	' Attributes = 512 [&H200] [Restricted]
	' Inherited interface = ISpObjectToken
	' Number of methods = 1
	' ########################################################################################
	
	#ifndef __ISpObjectTokenInit_INTERFACE_DEFINED__
		#define __ISpObjectTokenInit_INTERFACE_DEFINED__
		
		Type ISpObjectTokenInit_ Extends ISpObjectToken
			Declare Abstract Function InitFromDataKey (ByVal pszCategoryId As LPCWSTR, ByVal pszTokenId As LPCWSTR, ByVal pDataKey As ISpDataKey Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name = ISpPhrase2
	' IID = F264DA52-E457-4696-B856-A737B717AF79
	' Inherited interface = ISpPhrase
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __ISpPhrase2_INTERFACE_DEFINED__
		#define __ISpPhrase2_INTERFACE_DEFINED__
		
		Type ISpPhrase2_ Extends ISpPhrase
			Declare Abstract Function GetXMLResult (ByVal ppszCoMemXMLResult As LPWSTR Ptr, ByVal Options As SPXMLRESULTOPTIONS) As HRESULT
			Declare Abstract Function GetXMLErrorInfo (ByVal pSemanticErrorInfo As SPSEMANTICERRORINFO Ptr) As HRESULT
			Declare Abstract Function GetAudio (ByVal ulStartElement As ULong, ByVal cElements As ULong, ByVal ppStream As ISpStreamFormat Ptr Ptr) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name = ISpRecoResult2
	' IID = 27CAC6C4-88F2-41F2-8817-0C95E59F1E6E
	' Inherited interface = ISpRecoResult
	' Number of methods = 3
	' ########################################################################################
	
	#ifndef __ISpRecoResult2_INTERFACE_DEFINED__
		#define __ISpRecoResult2_INTERFACE_DEFINED__
		
		Type ISpRecoResult2_ Extends ISpRecoResult
			Declare Abstract Function CommitAlternate (ByVal pPhraseAlt As ISpPhraseAlt Ptr, ByVal ppNewResult As ISpRecoResult Ptr Ptr) As HRESULT
			Declare Abstract Function CommitText (ByVal ulStartElement As ULong, ByVal cElements As ULong, ByVal pszCorrectedData As LPCWSTR, ByVal eCommitFlags As DWORD) As HRESULT
			Declare Abstract Function SetTextFeedback (ByVal pszFeedback As LPCWSTR, ByVal fSuccessful As WINBOOL) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name = ISpRegDataKey
	' IID = {92A66E2B-C830-4149-83DF-6FC2BA1E7A5B}
	' Attributes = 512 [&H200] [Restricted]
	' Inherited interface = ISpDataKey
	' Number of methods = 1
	' ########################################################################################
	
	#ifndef __ISpRegDataKey_INTERFACE_DEFINED__
		#define __ISpRegDataKey_INTERFACE_DEFINED__
		
		Type ISpRegDataKey_ Extends ISpDataKey
			Declare Abstract Function SetKey (ByVal hkey As HKEY, ByVal fReadOnly As WINBOOL) As HRESULT
		End Type
		
	#endif
	
	' ########################################################################################
	' Interface name = ISPtranscript
	' IID = {CE17C09B-4EFA-44D5-A4C9-59D9585AB0CD}
	' Inherited interface = IUnknown
	' Number of methods = 2
	' ########################################################################################
	
	#ifndef __ISptranscript_INTERFACE_DEFINED__
		#define __ISptranscript_INTERFACE_DEFINED__
		
		Type ISptranscript_ Extends Afx_IUnknown
			Declare Abstract Function GetTranscript (ByVal ppszTranscript As LPWSTR Ptr) As HRESULT
			Declare Abstract Function AppendTranscript (ByVal pszTranscript As LPCWSTR) As HRESULT
		End Type
		
	#endif
	
	#ifndef __USE_MAKE__
		#include once "Speech.bas"
	#endif
	
End Namespace
