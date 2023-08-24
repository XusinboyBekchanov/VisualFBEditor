#pragma once
' Download 下载
' Copyright (c) 2022 CM.Wang
' Freeware. Use at your own risk.

#include once "Download.bi"

Constructor Download()
	hLib = DyLibLoad("urlmon.dll")
	If hLib Then URLDownloadToFile_Cm = DyLibSymbol(hLib, "URLDownloadToFileW")
	
	mBSC = New IBindStatusCallback_CM
	mBSC->lpVtbl = New IBindStatusCallbackVtbl
	mBSC->pThis = @This
	
	mBSC->lpVtbl->AddRef = Cast(Any Ptr, @AddRef)
	mBSC->lpVtbl->GetBindInfo = Cast(Any Ptr, @GetBindInfo)
	mBSC->lpVtbl->GetPriority = Cast(Any Ptr, @GetPriority)
	mBSC->lpVtbl->QueryInterface = Cast(Any Ptr, @QueryInterface)
	mBSC->lpVtbl->Release = Cast(Any Ptr, @Release)
	mBSC->lpVtbl->OnDataAvailable = Cast(Any Ptr, @OnDataAvailable)
	mBSC->lpVtbl->OnLowResource = Cast(Any Ptr, @OnLowResource)
	mBSC->lpVtbl->OnObjectAvailable = Cast(Any Ptr, @OnObjectAvailable)
	mBSC->lpVtbl->OnProgress = Cast(Any Ptr, @OnProgress)
	mBSC->lpVtbl->OnStartBinding = Cast(Any Ptr, @OnStartBinding)
	mBSC->lpVtbl->OnStopBinding = Cast(Any Ptr, @OnStopBinding)
	
End Constructor

Destructor Download()
	Delete mBSC->lpVtbl
	Delete mBSC
	If hLib Then DyLibFree(hLib)
End Destructor

Sub Download.DownloadUrl(ByVal Owner As Any Ptr, ByRef Url As Const WString, ByRef FileName As Const WString)
	mBSC->pOwner = Owner
	mOwner = Owner
	WStr2Ptr(Url, mUrl)
	WStr2Ptr(FileName, mFileName)
	mDone = False
	Cancel = False
	mTimeStart = False
	mTimeStop = False
	
	Status = 0
	SourceSize = 0
	DownloadSize = 0
	DonePercent = 0
	DownloadSpeed = 0
	
	If DeleteCacheEntry Then DeleteUrlCacheEntry(mUrl)
	mThread = ThreadCreate(Cast(Any Ptr, @DownloadThread), @This)
End Sub

Private Function Download.DownloadThread(ByVal pParam As LPVOID) As DWORD
	Dim cDL As Download Ptr = Cast(Download Ptr , pParam)
	cDL->DownloadDoing()
	Return 0
End Function

Private Sub Download.DownloadDoing()
	If URLDownloadToFile_Cm(0, mUrl, mFileName, 0, mBSC) Then
		
	Else
		
	End If
	Done = True
End Sub

Private Property Download.ElapsedTime() As Double
	If mTimeStart Then
		If mTimeStop = False Then
			mElapsedTime= TiMtr.Passed
		End If
		Return mElapsedTime
	Else
		Return 0
	End If
End Property

Private Property Download.Done() As Integer
	Return mDone
End Property

Private Property Download.Done(ByVal nVal As Integer)
	mDone = nVal
	If mDone<> NULL AndAlso OnDone<> NULL Then OnDone(mOwner)
End Property

Private Function Download.OnStartBinding(ByVal IBSCO As IBindStatusCallback_CM Ptr, ByVal dwReserved As DWORD, ByVal pib As IBinding Ptr) As HRESULT
	Dim d As Download Ptr = IBSCO->pThis
	If d->Cancel Then Return E_ABORT Else Function = E_NOTIMPL
End Function

Private Function Download.OnLowResource(ByVal IBSCO As IBindStatusCallback_CM Ptr, ByVal reserved As DWORD) As HRESULT
	Debug.Print "OnLowResource"
	Dim d As Download Ptr = IBSCO->pThis
	If d->Cancel Then Return E_ABORT Else Function = E_NOTIMPL
End Function

Private Function Download.OnProgress(ByVal IBSCO As IBindStatusCallback_CM Ptr, ByVal ulProgress As ULong, ByVal ulProgressMax As ULong, ByVal ulStatusCode As ULong, ByVal szStatusText As LPCWSTR) As HRESULT
	Dim d As Download Ptr = IBSCO->pThis
	
	Select Case ulStatusCode
	Case BINDSTATUS_DOWNLOADINGDATA
	Case Else
		Debug.Print "OnProgress"
		Debug.Print "ulProgress=" & ulProgress
		Debug.Print "ulProgressMax=" & ulProgressMax
		Debug.Print "ulStatusCode=" & d->BindStatusString(ulStatusCode)
		Debug.Print "szStatusText=" & *szStatusText + ""
	End Select
	
	Select Case ulStatusCode
	Case BINDSTATUS_CACHEFILENAMEAVAILABLE
		If d->OnCacheFile Then d->OnCacheFile(IBSCO->pOwner, *szStatusText + "")
	Case BINDSTATUS_REDIRECTING
		If d->OnReDir Then d->OnReDir(IBSCO->pOwner, *szStatusText + "")
	Case BINDSTATUS_BEGINDOWNLOADDATA
		d->mTimeStart = True
		d->TiMtr.Start
		If ulProgress <> ulProgressMax Then
			If d->SourceSize = 0 Then d->SourceSize = ulProgressMax
		End If
	Case BINDSTATUS_DOWNLOADINGDATA
		d->mElapsedTime = d->TiMtr.Passed
		If d->SourceSize Then
			d->DonePercent = ulProgress * 100 / ulProgressMax
		End If
		d->DownloadSize= ulProgress
		d->DownloadSpeed = ulProgress / d->mElapsedTime
	Case BINDSTATUS_ENDDOWNLOADDATA
		d->mTimeStop = True
		d->mElapsedTime = d->TiMtr.Passed
		If d->SourceSize Then
			d->DonePercent = ulProgress * 100 / ulProgressMax
		End If
		d->DownloadSize= ulProgress
		d->DownloadSpeed = ulProgress / d->mElapsedTime
		d->Status = 1
	End Select
	
	If d->Cancel Then Return E_ABORT Else Function = E_NOTIMPL
End Function

Private Function Download.OnStopBinding(ByVal IBSCO As IBindStatusCallback_CM Ptr, ByVal hhresult As HRESULT, ByVal szError As LPCWSTR) As HRESULT
	Debug.Print "OnStopBinding"
	Debug.Print "hhresult=" & hhresult
	Debug.Print "szError=" & *szError
	Dim d As Download Ptr = IBSCO->pThis
	If d->Cancel Then Return E_ABORT Else Function = E_NOTIMPL
End Function

Private Function Download.OnDataAvailable(ByVal IBSCO As IBindStatusCallback_CM Ptr, ByVal grfBSCF As DWORD, ByVal dwSize As DWORD, ByVal pformatetc As FORMATETC Ptr, ByVal pstgmed As STGMEDIUM Ptr) As HRESULT
	'URLDownloadToFile calls the OnProgress and OnDataAvailable methods as data is received.
	'The download operation can be canceled by returning E_ABORT from any callback.
	
	'grfBSCF    [in] An unsigned long integer value from the BSCF enumeration that indicates the kind of data available.
	'dwSize     [in] An unsigned long integer value that contains the size, in bytes, of the total data available from the current bind operation.
	'pformatetc [in] The address of the FORMATETC structure that indicates the format of the available data. This parameter is used when
	'                the bind operation results from the IMoniker::BindToStorage method. If there is no format associated with the available data,
	'                pformatetc might contain CF_NULL. Each different call to IBindStatusCallback::OnDataAvailable can pass in
	'                a new value for this parameter; every call always points to the same data.
	'pstgmed    [in] The address of the STGMEDIUM structure that contains pointers to the interfaces (such as IStream and IStorage) that
	'                can be used to access the data. In the asynchronous case, client applications might receive a second pointer to
	'                the IStream or IStorage interface from the IMoniker::BindToStorage method. The client application must call Release
	'                on the interfaces to avoid memory leaks.
	Debug.Print "OnDataAvailable"
	Debug.Print "grfBSCF=" & grfBSCF
	Debug.Print "dwSize=" & dwSize
	
	Debug.Print "pformatetc->cfFormat=" & pformatetc->cfFormat
	Debug.Print "pformatetc->dwAspect=" & pformatetc->dwAspect
	Debug.Print "pformatetc->lindex=" & pformatetc->lindex
	Debug.Print "pformatetc->ptd->tdData(0)=" & pformatetc->ptd->tdData(0)
	Debug.Print "pformatetc->ptd->tdDeviceNameOffset=" & pformatetc->ptd->tdDeviceNameOffset
	Debug.Print "pformatetc->ptd->tdDriverNameOffset=" & pformatetc->ptd->tdDriverNameOffset
	Debug.Print "pformatetc->ptd->tdExtDevmodeOffset=" & pformatetc->ptd->tdExtDevmodeOffset
	Debug.Print "pformatetc->ptd->tdPortNameOffset=" & pformatetc->ptd->tdPortNameOffset
	Debug.Print "pformatetc->ptd->tdSize=" & pformatetc->ptd->tdSize
	Debug.Print "pformatetc->tymed=" & pformatetc->tymed
	
	Debug.Print "pstgmed=" & pstgmed
	
	Dim d As Download Ptr = IBSCO->pThis
	If d->Cancel Then Return E_ABORT Else Function = E_NOTIMPL
End Function

Private Function Download.OnObjectAvailable(ByVal IBSCO As IBindStatusCallback_CM Ptr, ByVal riid As Const IID Const Ptr, ByVal punk As IUnknown Ptr) As HRESULT
	Debug.Print "OnObjectAvailable"
	Dim d As Download Ptr = IBSCO->pThis
	If d->Cancel Then Return E_ABORT Else Function = E_NOTIMPL
End Function

Private Function Download.QueryInterface(ByVal IBSCO As IBindStatusCallback_CM Ptr, ByVal riid As Const IID Const Ptr, ByVal ppvObject As Any Ptr Ptr) As HRESULT
	Debug.Print "QueryInterface"
	Dim d As Download Ptr = IBSCO->pThis
	If d->Cancel Then Return E_ABORT Else Function = E_NOTIMPL
End Function

Private Function Download.AddRef(ByVal IBSCO As IBindStatusCallback_CM Ptr) As ULong
	Debug.Print "AddRef"
	Dim d As Download Ptr = IBSCO->pThis
	If d->Cancel Then Return E_ABORT Else Function = E_NOTIMPL
End Function

Private Function Download.Release(ByVal IBSCO As IBindStatusCallback_CM Ptr) As ULong
	Debug.Print "Release"
	Dim d As Download Ptr = IBSCO->pThis
	If d->Cancel Then Return E_ABORT Else Function = E_NOTIMPL
End Function

Private Function Download.GetPriority(ByVal IBSCO As IBindStatusCallback_CM Ptr, ByVal pnPriority As Long Ptr) As HRESULT
	Debug.Print "GetPriority"
	Dim d As Download Ptr = IBSCO->pThis
	If d->Cancel Then Return E_ABORT Else Function = E_NOTIMPL
End Function

Private Function Download.GetBindInfo(ByVal IBSCO As IBindStatusCallback_CM Ptr, ByVal grfBINDF As DWORD Ptr, ByVal pbindinfo As BINDINFO Ptr) As HRESULT
	Debug.Print "GetBindInfo"
	Dim d As Download Ptr = IBSCO->pThis
	If d->Cancel Then Return E_ABORT Else Function = E_NOTIMPL
End Function

Private Function Download.BindStatusString(tagBINDSTATUS As ULong) As String
	Select Case tagBINDSTATUS
	Case 01 : Function = "BINDSTATUS_FINDINGRESOURCE"
	Case 02 : Function = "BINDSTATUS_CONNECTING"
	Case 03 : Function = "BINDSTATUS_REDIRECTING"
	Case 04 : Function = "BINDSTATUS_BEGINDOWNLOADDATA"
	Case 05 : Function = "BINDSTATUS_DOWNLOADINGDATA"
	Case 06 : Function = "BINDSTATUS_ENDDOWNLOADDATA"
	Case 07 : Function = "BINDSTATUS_BEGINDOWNLOADCOMPONENTS"
	Case 08 : Function = "BINDSTATUS_INSTALLINGCOMPONENTS"
	Case 09 : Function = "BINDSTATUS_ENDDOWNLOADCOMPONENTS"
	Case 10 : Function = "BINDSTATUS_USINGCACHEDCOPY"
	Case 11 : Function = "BINDSTATUS_SENDINGREQUEST"
	Case 12 : Function = "BINDSTATUS_CLASSIDAVAILABLE"
	Case 13 : Function = "BINDSTATUS_MIMETYPEAVAILABLE"
	Case 14 : Function = "BINDSTATUS_CACHEFILENAMEAVAILABLE"
	Case 15 : Function = "BINDSTATUS_BEGINSYNCOPERATION"
	Case 16 : Function = "BINDSTATUS_ENDSYNCOPERATION"
	Case 17 : Function = "BINDSTATUS_BEGINUPLOADDATA"
	Case 18 : Function = "BINDSTATUS_UPLOADINGDATA"
	Case 19 : Function = "BINDSTATUS_ENDUPLOADINGDATA"
	Case 20 : Function = "BINDSTATUS_PROTOCOLCLASSID"
	Case 21 : Function = "BINDSTATUS_ENCODING"
	Case 22 : Function = "BINDSTATUS_VERFIEDMIMETYPEAVAILABLE"
	Case 23 : Function = "BINDSTATUS_CLASSINSTALLLOCATION"
	Case 24 : Function = "BINDSTATUS_DECODING"
	Case 25 : Function = "BINDSTATUS_LOADINGMIMEHANDLER"
	Case 26 : Function = "BINDSTATUS_CONTENTDISPOSITIONATTACH"
	Case 27 : Function = "BINDSTATUS_FILTERREPORTMIMETYPE"
	Case 28 : Function = "BINDSTATUS_CLSIDCANINSTANTIATE"
	Case 29 : Function = "BINDSTATUS_IUNKNOWNAVAILABLE"
	Case 30 : Function = "BINDSTATUS_DIRECTBIND"
	Case 31 : Function = "BINDSTATUS_RAWMIMETYPE"
	Case 32 : Function = "BINDSTATUS_PROXYDETECTING"
	Case 33 : Function = "BINDSTATUS_ACCEPTRANGES"
	Case 34 : Function = "BINDSTATUS_COOKIE_SENT"
	Case 35 : Function = "BINDSTATUS_COMPACT_POLICY_RECEIVED"
	Case 36 : Function = "BINDSTATUS_COOKIE_SUPPRESSED"
	Case 37 : Function = "BINDSTATUS_COOKIE_STATE_UNKNOWN"
	Case 38 : Function = "BINDSTATUS_COOKIE_STATE_ACCEPT"
	Case 39 : Function = "BINDSTATUS_COOKIE_STATE_REJECT"
	Case 40 : Function = "BINDSTATUS_COOKIE_STATE_PROMPT"
	Case 41 : Function = "BINDSTATUS_COOKIE_STATE_LEASH"
	Case 42 : Function = "BINDSTATUS_COOKIE_STATE_DOWNGRADE"
	Case 43 : Function = "BINDSTATUS_POLICY_HREF"
	Case 44 : Function = "BINDSTATUS_P3P_HEADER"
	Case 45 : Function = "BINDSTATUS_SESSION_COOKIE_RECEIVED"
	Case 46 : Function = "BINDSTATUS_PERSISTENT_COOKIE_RECEIVED"
	Case 47 : Function = "BINDSTATUS_SESSION_COOKIES_ALLOWED"
	Case 48 : Function = "BINDSTATUS_CACHECONTROL"
	Case 49 : Function = "BINDSTATUS_CONTENTDISPOSITIONFILENAME"
	Case 50 : Function = "BINDSTATUS_MIMETEXTPLAINMISMATCH"
	Case 51 : Function = "BINDSTATUS_PUBLISHERAVAILABLE"
	Case 52 : Function = "BINDSTATUS_DISPLAYNAMEAVAILABLE"
	Case 53 : Function = "BINDSTATUS_SSLUX_NAVBLOCKED"
	Case 54 : Function = "BINDSTATUS_SERVER_MIMETYPEAVAILABLE"
	Case 55 : Function = "BINDSTATUS_SNIFFED_CLASSIDAVAILABLE"
	Case 56 : Function = "BINDSTATUS_64BIT_PROGRESS"
	Case 57 : Function = "BINDSTATUS_LAST = BINDSTATUS_64BIT_PROGRESS"
	Case 58 : Function = "BINDSTATUS_RESERVED_0"
	Case 59 : Function = "BINDSTATUS_RESERVED_1"
	Case 60 : Function = "BINDSTATUS_RESERVED_2"
	Case 61 : Function = "BINDSTATUS_RESERVED_3"
	Case 62 : Function = "BINDSTATUS_RESERVED_4"
	Case 63 : Function = "BINDSTATUS_RESERVED_5"
	Case 64 : Function = "BINDSTATUS_RESERVED_6"
	Case 65 : Function = "BINDSTATUS_RESERVED_7"
	Case 66 : Function = "BINDSTATUS_RESERVED_8"
	Case 67 : Function = "BINDSTATUS_RESERVED_9"
	Case 68 : Function = "BINDSTATUS_LAST_PRIVATE = BINDSTATUS_RESERVED_9"
	Case Else : Function = "Unknow=" & tagBINDSTATUS
	End Select
End Function
