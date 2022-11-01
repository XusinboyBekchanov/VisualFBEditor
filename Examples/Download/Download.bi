#pragma once
' Download 下载
' Copyright (c) 2022 CM.Wang
' Freeware. Use at your own risk.

#include once "win/wininet.bi"
#include once "win/urlmon.bi"
#include once "../MDINotepad/Text.bi"
#include once "../MDINotepad/TimeMeter.bi"

'https://forum.powerbasic.com/forum/user-to-user-discussions/programming/20626-using-the-urldownloadtofile-api
'https://learn.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/platform-apis/ms775123(v=vs.85)

Type IBindStatusCallback_CM
	lpVtbl   As IBindStatusCallbackVtbl Ptr  'lpVtbl
	pThis    As Any Ptr                      'This
	pOwner   As Any Ptr                      'Owner
	nValue   As Any Ptr                      'Any class private data
End Type

Type Download
Private:
	
	mBSC As IBindStatusCallback_CM Ptr
	URLDownloadToFile_Cm As Function(ByVal As LPUNKNOWN, ByVal As LPCWSTR, ByVal As LPCWSTR, ByVal As DWORD, ByVal As IBindStatusCallback_CM Ptr) As HRESULT
	hLib As Any Ptr = NULL
	mOwner As Any Ptr = NULL
	mThread As Any Ptr = NULL
	mUrl As WString Ptr = NULL
	mFileName As WString Ptr = NULL
	
	mDone As Boolean = False
	TiMtr As TimeMeter
	mElapsedTime As Double
	mTimeStart As Boolean
	mTimeStop As Boolean
	
Private:
	'IBindStatusCallback
	Declare Static Function QueryInterface(ByVal IBSCO As IBindStatusCallback_CM Ptr, ByVal riid As Const IID Const Ptr, ByVal ppvObject As Any Ptr Ptr) As HRESULT
	Declare Static Function AddRef(ByVal IBSCO As IBindStatusCallback_CM Ptr) As ULong
	Declare Static Function Release(ByVal IBSCO As IBindStatusCallback_CM Ptr) As ULong
	Declare Static Function OnStartBinding(ByVal IBSCO As IBindStatusCallback_CM Ptr, ByVal dwReserved As DWORD, ByVal pib As IBinding Ptr) As HRESULT
	Declare Static Function GetPriority(ByVal IBSCO As IBindStatusCallback_CM Ptr, ByVal pnPriority As Long Ptr) As HRESULT
	Declare Static Function OnLowResource(ByVal IBSCO As IBindStatusCallback_CM Ptr, ByVal reserved As DWORD) As HRESULT
	Declare Static Function OnProgress(ByVal IBSCO As IBindStatusCallback_CM Ptr, ByVal ulProgress As ULong, ByVal ulProgressMax As ULong, ByVal ulStatusCode As ULong, ByVal szStatusText As LPCWSTR) As HRESULT
	Declare Static Function GetBindInfo(ByVal IBSCO As IBindStatusCallback_CM Ptr, ByVal grfBINDF As DWORD Ptr, ByVal pbindinfo As BINDINFO Ptr) As HRESULT
	Declare Static Function OnStopBinding(ByVal IBSCO As IBindStatusCallback_CM Ptr, ByVal hhresult As HRESULT, ByVal szError As LPCWSTR) As HRESULT
	Declare Static Function OnDataAvailable(ByVal IBSCO As IBindStatusCallback_CM Ptr, ByVal grfBSCF As DWORD, ByVal dwSize As DWORD, ByVal pformatetc As FORMATETC Ptr, ByVal pstgmed As STGMEDIUM Ptr) As HRESULT
	Declare Static Function OnObjectAvailable(ByVal IBSCO As IBindStatusCallback_CM Ptr, ByVal riid As Const IID Const Ptr, ByVal punk As IUnknown Ptr) As HRESULT

	Declare Static Function DownloadThread(ByVal pParam As LPVOID) As DWORD
	
	Declare Function BindStatusString(tagBINDSTATUS As ULong) As String
	Declare Sub DownloadDoing()

Public:
	
	Cancel As Boolean
	Status As Integer
	SourceSize As ULong
	DownloadSize As ULong
	DonePercent As Double
	DownloadSpeed As Double
	DeleteCacheEntry As Boolean = False
	
Public:
	
	Declare Constructor
	Declare Destructor
	OnDone As Sub(Owner As Any Ptr) '枚举完成事件
	OnMsg As Sub(Owner As Any Ptr, ByRef MsgStr As Const WString)
	OnCacheFile As Sub(Owner As Any Ptr, ByRef CacheFile As Const WString)
	OnReDir As Sub(Owner As Any Ptr, ByRef Url As Const WString)
	Declare Property Done() As Integer
	Declare Property Done(ByVal nVal As Integer)
	Declare Property ElapsedTime() As Double
	Declare Sub DownloadUrl(ByVal Owner As Any Ptr, ByRef Url As Const WString, ByRef FileName As Const WString)
End Type

#ifndef __USE_MAKE__
	#include once "Download.bas"
#endif
