/' 
  MFPPlay FreeBASIC Header File
  deepseek converted from mfplay.h
  FreeBASIC version 1.20.0
  
  AI prompt: 分析附件的c++头文件代码, 并精确的转换为freebasic(1.20.0) 的头文件, 输出完整的代码
'/

#ifndef __MFPLAY_BI__
#define __MFPLAY_BI__

#inclib "mfplay"

#include "windows.bi"
#include "win\unknwn.bi"
#include "win\propsys.bi"
'#include "mfidl.bi"
'#include "evr.bi"

/' Forward declarations '/
#ifndef __IMFPMediaPlayer_FWD_DEFINED__
#define __IMFPMediaPlayer_FWD_DEFINED__
Type IMFPMediaPlayer As IMFPMediaPlayer_
#endif

#ifndef __IMFPMediaItem_FWD_DEFINED__
#define __IMFPMediaItem_FWD_DEFINED__
Type IMFPMediaItem As IMFPMediaItem_
#endif

#ifndef __IMFPMediaPlayerCallback_FWD_DEFINED__
#define __IMFPMediaPlayerCallback_FWD_DEFINED__
Type IMFPMediaPlayerCallback As IMFPMediaPlayerCallback_
#endif

'#if (WINVER >= &H0601)  ' _WIN32_WINNT_WIN7

/' Interface IDs '/
'DEFINE_GUID(IID_IMFPMediaPlayer, &Ha714590a, &H58af, &H430a, &H85, &Hbf, &H44, &Hf5, &Hec, &H83, &H8d, &H85)
'DEFINE_GUID(IID_IMFPMediaItem, &H90eb3e6b, &Hecbf, &H45cc, &Hb1, &Hda, &Hc6, &Hfe, &H3e, &Ha7, &H0d, &H57)
'DEFINE_GUID(IID_IMFPMediaPlayerCallback, &H766c8ffb, &H5fdb, &H4fea, &Ha2, &H8d, &Hb9, &H12, &H99, &H6f, &H51, &Hbd)
Dim Shared As GUID IID_IMFPMediaPlayer = Type<GUID>(&ha714590a, &h58af, &h430a, {&h85, &hbf, &h44, &hf5, &hec, &h83, &h8d, &h85})
Dim Shared As GUID IID_IMFPMediaItem = Type<GUID>(&h90eb3e6b, &hecbf, &h45cc, {&hb1, &hda, &hc6, &hfe, &h3e, &ha7, &h0d, &h57})
Dim Shared As GUID IID_IMFPMediaPlayerCallback = Type<GUID>(&h766c8ffb, &h5fdb, &h4fea, {&ha2, &h8d, &hb9, &h12, &h99, &h6f, &h51, &hbd})

/' Types and Enums '/
Type MFP_CREATION_OPTIONS As UINT

Enum _MFP_CREATION_OPTIONS
    MFP_OPTION_NONE = &H0
    MFP_OPTION_FREE_THREADED_CALLBACK = &H1
    MFP_OPTION_NO_MMCSS = &H2
    MFP_OPTION_NO_REMOTE_DESKTOP_OPTIMIZATION = &H4
End Enum

Enum MFP_MEDIAPLAYER_STATE
    MFP_MEDIAPLAYER_STATE_EMPTY = &H0
    MFP_MEDIAPLAYER_STATE_STOPPED = &H1
    MFP_MEDIAPLAYER_STATE_PLAYING = &H2
    MFP_MEDIAPLAYER_STATE_PAUSED = &H3
    MFP_MEDIAPLAYER_STATE_SHUTDOWN = &H4
End Enum

Type MFP_MEDIAITEM_CHARACTERISTICS As UINT

Enum _MFP_MEDIAITEM_CHARACTERISTICS
    MFP_MEDIAITEM_IS_LIVE = &H1
    MFP_MEDIAITEM_CAN_SEEK = &H2
    MFP_MEDIAITEM_CAN_PAUSE = &H4
    MFP_MEDIAITEM_HAS_SLOW_SEEK = &H8
End Enum

Type MFP_CREDENTIAL_FLAGS As UINT

Enum _MFP_CREDENTIAL_FLAGS
    MFP_CREDENTIAL_PROMPT = &H1
    MFP_CREDENTIAL_SAVE = &H2
    MFP_CREDENTIAL_DO_NOT_CACHE = &H4
    MFP_CREDENTIAL_CLEAR_TEXT = &H8
    MFP_CREDENTIAL_PROXY = &H10
    MFP_CREDENTIAL_LOGGED_ON_USER = &H20
End Enum

'/' Function Declarations '/
'Declare Function MFPCreateMediaPlayer( _
'    ByVal pwszURL As LPCWSTR, _
'    ByVal fStartPlayback As WINBOOL, _
'    ByVal creationOptions As MFP_CREATION_OPTIONS, _
'    ByVal pCallback As IMFPMediaPlayerCallback Ptr, _
'    ByVal hWnd As HWND, _
'    ByVal ppMediaPlayer As IMFPMediaPlayer Ptr Ptr _
') As HRESULT

'' ============================================================================
'' MFPCreateMediaPlayer（来自 mfplay.dll）
'' ============================================================================
Declare Function MFPCreateMediaPlayer Lib "mfplay.dll" Alias "MFPCreateMediaPlayer" ( _
    ByVal pwszURL As LPCWSTR, _
    ByVal fStartPlayback As Long, _
    ByVal creationOptions As MFP_CREATION_OPTIONS, _
    ByVal pCallback As IMFPMediaPlayerCallback Ptr, _
    ByVal HWND As HWND, _
    ByRef ppMediaPlayer As IMFPMediaPlayer Ptr _
) As HRESULT

/' IMFPMediaPlayer Interface '/
#ifndef __IMFPMediaPlayer_INTERFACE_DEFINED__
#define __IMFPMediaPlayer_INTERFACE_DEFINED__

Type IMFPMediaPlayerVtbl
    /' IUnknown methods '/
    QueryInterface As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFPMediaPlayer Ptr) As ULong
    Release As Function(ByVal This As IMFPMediaPlayer Ptr) As ULong
    
    /' IMFPMediaPlayer methods '/
    Play As Function(ByVal This As IMFPMediaPlayer Ptr) As HRESULT
    Pause As Function(ByVal This As IMFPMediaPlayer Ptr) As HRESULT
    Stop As Function(ByVal This As IMFPMediaPlayer Ptr) As HRESULT
    FrameStep As Function(ByVal This As IMFPMediaPlayer Ptr) As HRESULT
    SetPosition As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal guidPositionType As REFGUID, ByVal pvPositionValue As Const PROPVARIANT Ptr) As HRESULT
    GetPosition As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal guidPositionType As REFGUID, ByVal pvPositionValue As PROPVARIANT Ptr) As HRESULT
    GetDuration As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal guidPositionType As REFGUID, ByVal pvDurationValue As PROPVARIANT Ptr) As HRESULT
    SetRate As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal flRate As Single) As HRESULT
    GetRate As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal pflRate As Single Ptr) As HRESULT
    GetSupportedRates As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal fForwardDirection As WINBOOL, ByVal pflSlowestRate As Single Ptr, ByVal pflFastestRate As Single Ptr) As HRESULT
    GetState As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal peState As MFP_MEDIAPLAYER_STATE Ptr) As HRESULT
    CreateMediaItemFromURL As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal pwszURL As LPCWSTR, ByVal fSync As WINBOOL, ByVal dwUserData As DWORD_PTR, ByVal ppMediaItem As IMFPMediaItem Ptr Ptr) As HRESULT
    CreateMediaItemFromObject As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal pIUnknownObj As IUnknown Ptr, ByVal fSync As WINBOOL, ByVal dwUserData As DWORD_PTR, ByVal ppMediaItem As IMFPMediaItem Ptr Ptr) As HRESULT
    SetMediaItem As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal pIMFPMediaItem As IMFPMediaItem Ptr) As HRESULT
    ClearMediaItem As Function(ByVal This As IMFPMediaPlayer Ptr) As HRESULT
    GetMediaItem As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal ppIMFPMediaItem As IMFPMediaItem Ptr Ptr) As HRESULT
    GetVolume As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal pflVolume As Single Ptr) As HRESULT
    SetVolume As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal flVolume As Single) As HRESULT
    GetBalance As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal pflBalance As Single Ptr) As HRESULT
    SetBalance As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal flBalance As Single) As HRESULT
    GetMute As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal pfMute As WINBOOL Ptr) As HRESULT
    SetMute As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal fMute As WINBOOL) As HRESULT
    GetNativeVideoSize As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal pszVideo As SIZE Ptr, ByVal pszARVideo As SIZE Ptr) As HRESULT
    GetIdealVideoSize As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal pszMin As SIZE Ptr, ByVal pszMax As SIZE Ptr) As HRESULT
    'SetVideoSourceRect As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal pnrcSource As Const MFVideoNormalizedRect Ptr) As HRESULT
    'GetVideoSourceRect As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal pnrcSource As MFVideoNormalizedRect Ptr) As HRESULT
    SetAspectRatioMode As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal dwAspectRatioMode As DWORD) As HRESULT
    GetAspectRatioMode As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal pdwAspectRatioMode As DWORD Ptr) As HRESULT
    GetVideoWindow As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal phwndVideo As HWND Ptr) As HRESULT
    UpdateVideo As Function(ByVal This As IMFPMediaPlayer Ptr) As HRESULT
    SetBorderColor As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal Clr As COLORREF) As HRESULT
    GetBorderColor As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal pClr As COLORREF Ptr) As HRESULT
    InsertEffect As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal pEffect As IUnknown Ptr, ByVal fOptional As WINBOOL) As HRESULT
    RemoveEffect As Function(ByVal This As IMFPMediaPlayer Ptr, ByVal pEffect As IUnknown Ptr) As HRESULT
    RemoveAllEffects As Function(ByVal This As IMFPMediaPlayer Ptr) As HRESULT
    Shutdown As Function(ByVal This As IMFPMediaPlayer Ptr) As HRESULT
End Type

Type IMFPMediaPlayer_
    lpVtbl As IMFPMediaPlayerVtbl Ptr
End Type

/' IMFPMediaPlayer Method Macros '/
#define IMFPMediaPlayer_QueryInterface(This, riid, ppvObject) (This)->lpVtbl->QueryInterface(This, riid, ppvObject)
#define IMFPMediaPlayer_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IMFPMediaPlayer_Release(This) (This)->lpVtbl->Release(This)
#define IMFPMediaPlayer_Play(This) (This)->lpVtbl->Play(This)
#define IMFPMediaPlayer_Pause(This) (This)->lpVtbl->Pause(This)
#define IMFPMediaPlayer_Stop(This) (This)->lpVtbl->Stop(This)
#define IMFPMediaPlayer_FrameStep(This) (This)->lpVtbl->FrameStep(This)
#define IMFPMediaPlayer_SetPosition(This, guidPositionType, pvPositionValue) (This)->lpVtbl->SetPosition(This, guidPositionType, pvPositionValue)
#define IMFPMediaPlayer_GetPosition(This, guidPositionType, pvPositionValue) (This)->lpVtbl->GetPosition(This, guidPositionType, pvPositionValue)
#define IMFPMediaPlayer_GetDuration(This, guidPositionType, pvDurationValue) (This)->lpVtbl->GetDuration(This, guidPositionType, pvDurationValue)
#define IMFPMediaPlayer_SetRate(This, flRate) (This)->lpVtbl->SetRate(This, flRate)
#define IMFPMediaPlayer_GetRate(This, pflRate) (This)->lpVtbl->GetRate(This, pflRate)
#define IMFPMediaPlayer_GetSupportedRates(This, fForwardDirection, pflSlowestRate, pflFastestRate) (This)->lpVtbl->GetSupportedRates(This, fForwardDirection, pflSlowestRate, pflFastestRate)
#define IMFPMediaPlayer_GetState(This, peState) (This)->lpVtbl->GetState(This, peState)
#define IMFPMediaPlayer_CreateMediaItemFromURL(This, pwszURL, fSync, dwUserData, ppMediaItem) (This)->lpVtbl->CreateMediaItemFromURL(This, pwszURL, fSync, dwUserData, ppMediaItem)
#define IMFPMediaPlayer_CreateMediaItemFromObject(This, pIUnknownObj, fSync, dwUserData, ppMediaItem) (This)->lpVtbl->CreateMediaItemFromObject(This, pIUnknownObj, fSync, dwUserData, ppMediaItem)
#define IMFPMediaPlayer_SetMediaItem(This, pIMFPMediaItem) (This)->lpVtbl->SetMediaItem(This, pIMFPMediaItem)
#define IMFPMediaPlayer_ClearMediaItem(This) (This)->lpVtbl->ClearMediaItem(This)
#define IMFPMediaPlayer_GetMediaItem(This, ppIMFPMediaItem) (This)->lpVtbl->GetMediaItem(This, ppIMFPMediaItem)
#define IMFPMediaPlayer_GetVolume(This, pflVolume) (This)->lpVtbl->GetVolume(This, pflVolume)
#define IMFPMediaPlayer_SetVolume(This, flVolume) (This)->lpVtbl->SetVolume(This, flVolume)
#define IMFPMediaPlayer_GetBalance(This, pflBalance) (This)->lpVtbl->GetBalance(This, pflBalance)
#define IMFPMediaPlayer_SetBalance(This, flBalance) (This)->lpVtbl->SetBalance(This, flBalance)
#define IMFPMediaPlayer_GetMute(This, pfMute) (This)->lpVtbl->GetMute(This, pfMute)
#define IMFPMediaPlayer_SetMute(This, fMute) (This)->lpVtbl->SetMute(This, fMute)
#define IMFPMediaPlayer_GetNativeVideoSize(This, pszVideo, pszARVideo) (This)->lpVtbl->GetNativeVideoSize(This, pszVideo, pszARVideo)
#define IMFPMediaPlayer_GetIdealVideoSize(This, pszMin, pszMax) (This)->lpVtbl->GetIdealVideoSize(This, pszMin, pszMax)
#define IMFPMediaPlayer_SetVideoSourceRect(This, pnrcSource) (This)->lpVtbl->SetVideoSourceRect(This, pnrcSource)
#define IMFPMediaPlayer_GetVideoSourceRect(This, pnrcSource) (This)->lpVtbl->GetVideoSourceRect(This, pnrcSource)
#define IMFPMediaPlayer_SetAspectRatioMode(This, dwAspectRatioMode) (This)->lpVtbl->SetAspectRatioMode(This, dwAspectRatioMode)
#define IMFPMediaPlayer_GetAspectRatioMode(This, pdwAspectRatioMode) (This)->lpVtbl->GetAspectRatioMode(This, pdwAspectRatioMode)
#define IMFPMediaPlayer_GetVideoWindow(This, phwndVideo) (This)->lpVtbl->GetVideoWindow(This, phwndVideo)
#define IMFPMediaPlayer_UpdateVideo(This) (This)->lpVtbl->UpdateVideo(This)
#define IMFPMediaPlayer_SetBorderColor(This, Clr) (This)->lpVtbl->SetBorderColor(This, Clr)
#define IMFPMediaPlayer_GetBorderColor(This, pClr) (This)->lpVtbl->GetBorderColor(This, pClr)
#define IMFPMediaPlayer_InsertEffect(This, pEffect, fOptional) (This)->lpVtbl->InsertEffect(This, pEffect, fOptional)
#define IMFPMediaPlayer_RemoveEffect(This, pEffect) (This)->lpVtbl->RemoveEffect(This, pEffect)
#define IMFPMediaPlayer_RemoveAllEffects(This) (This)->lpVtbl->RemoveAllEffects(This)
#define IMFPMediaPlayer_Shutdown(This) (This)->lpVtbl->Shutdown(This)

#endif  /' __IMFPMediaPlayer_INTERFACE_DEFINED__ '/

/' Position Type GUID '/
'Extern Const GUID MFP_POSITIONTYPE_100NS
Dim Shared As GUID MFP_POSITIONTYPE_100NS = Type<GUID>(&h0, &h0, &h0, {&h0, &h0, &h0, &h0, &h0, &h0, &h0, &h0})

/' IMFPMediaItem Interface '/
#ifndef __IMFPMediaItem_INTERFACE_DEFINED__
#define __IMFPMediaItem_INTERFACE_DEFINED__

Type IMFPMediaItemVtbl
    /' IUnknown methods '/
    QueryInterface As Function(ByVal This As IMFPMediaItem Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFPMediaItem Ptr) As ULong
    Release As Function(ByVal This As IMFPMediaItem Ptr) As ULong
    
    /' IMFPMediaItem methods '/
    GetMediaPlayer As Function(ByVal This As IMFPMediaItem Ptr, ByVal ppMediaPlayer As IMFPMediaPlayer Ptr Ptr) As HRESULT
    GetURL As Function(ByVal This As IMFPMediaItem Ptr, ByVal ppwszURL As LPWSTR Ptr) As HRESULT
    GetObject As Function(ByVal This As IMFPMediaItem Ptr, ByVal ppIUnknown As IUnknown Ptr Ptr) As HRESULT
    GetUserData As Function(ByVal This As IMFPMediaItem Ptr, ByVal pdwUserData As DWORD_PTR Ptr) As HRESULT
    SetUserData As Function(ByVal This As IMFPMediaItem Ptr, ByVal dwUserData As DWORD_PTR) As HRESULT
    GetStartStopPosition As Function(ByVal This As IMFPMediaItem Ptr, ByVal pguidStartPositionType As GUID Ptr, ByVal pvStartValue As PROPVARIANT Ptr, ByVal pguidStopPositionType As GUID Ptr, ByVal pvStopValue As PROPVARIANT Ptr) As HRESULT
    SetStartStopPosition As Function(ByVal This As IMFPMediaItem Ptr, ByVal pguidStartPositionType As Const GUID Ptr, ByVal pvStartValue As Const PROPVARIANT Ptr, ByVal pguidStopPositionType As Const GUID Ptr, ByVal pvStopValue As Const PROPVARIANT Ptr) As HRESULT
    HasVideo As Function(ByVal This As IMFPMediaItem Ptr, ByVal pfHasVideo As WINBOOL Ptr, ByVal pfSelected As WINBOOL Ptr) As HRESULT
    HasAudio As Function(ByVal This As IMFPMediaItem Ptr, ByVal pfHasAudio As WINBOOL Ptr, ByVal pfSelected As WINBOOL Ptr) As HRESULT
    IsProtected As Function(ByVal This As IMFPMediaItem Ptr, ByVal pfProtected As WINBOOL Ptr) As HRESULT
    GetDuration As Function(ByVal This As IMFPMediaItem Ptr, ByVal guidPositionType As REFGUID, ByVal pvDurationValue As PROPVARIANT Ptr) As HRESULT
    GetNumberOfStreams As Function(ByVal This As IMFPMediaItem Ptr, ByVal pdwStreamCount As DWORD Ptr) As HRESULT
    GetStreamSelection As Function(ByVal This As IMFPMediaItem Ptr, ByVal dwStreamIndex As DWORD, ByVal pfEnabled As WINBOOL Ptr) As HRESULT
    SetStreamSelection As Function(ByVal This As IMFPMediaItem Ptr, ByVal dwStreamIndex As DWORD, ByVal fEnabled As WINBOOL) As HRESULT
    GetStreamAttribute As Function(ByVal This As IMFPMediaItem Ptr, ByVal dwStreamIndex As DWORD, ByVal guidMFAttribute As REFGUID, ByVal pvValue As PROPVARIANT Ptr) As HRESULT
    GetPresentationAttribute As Function(ByVal This As IMFPMediaItem Ptr, ByVal guidMFAttribute As REFGUID, ByVal pvValue As PROPVARIANT Ptr) As HRESULT
    GetCharacteristics As Function(ByVal This As IMFPMediaItem Ptr, ByVal pCharacteristics As MFP_MEDIAITEM_CHARACTERISTICS Ptr) As HRESULT
    SetStreamSink As Function(ByVal This As IMFPMediaItem Ptr, ByVal dwStreamIndex As DWORD, ByVal pMediaSink As IUnknown Ptr) As HRESULT
    GetMetadata As Function(ByVal This As IMFPMediaItem Ptr, ByVal ppMetadataStore As IPropertyStore Ptr Ptr) As HRESULT
End Type

Type IMFPMediaItem_
    lpVtbl As IMFPMediaItemVtbl Ptr
End Type

/' IMFPMediaItem Method Macros '/
#define IMFPMediaItem_QueryInterface(This, riid, ppvObject) (This)->lpVtbl->QueryInterface(This, riid, ppvObject)
#define IMFPMediaItem_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IMFPMediaItem_Release(This) (This)->lpVtbl->Release(This)
#define IMFPMediaItem_GetMediaPlayer(This, ppMediaPlayer) (This)->lpVtbl->GetMediaPlayer(This, ppMediaPlayer)
#define IMFPMediaItem_GetURL(This, ppwszURL) (This)->lpVtbl->GetURL(This, ppwszURL)
#define IMFPMediaItem_GetObject(This, ppIUnknown) (This)->lpVtbl->GetObject(This, ppIUnknown)
#define IMFPMediaItem_GetUserData(This, pdwUserData) (This)->lpVtbl->GetUserData(This, pdwUserData)
#define IMFPMediaItem_SetUserData(This, dwUserData) (This)->lpVtbl->SetUserData(This, dwUserData)
#define IMFPMediaItem_GetStartStopPosition(This, pguidStartPositionType, pvStartValue, pguidStopPositionType, pvStopValue) (This)->lpVtbl->GetStartStopPosition(This, pguidStartPositionType, pvStartValue, pguidStopPositionType, pvStopValue)
#define IMFPMediaItem_SetStartStopPosition(This, pguidStartPositionType, pvStartValue, pguidStopPositionType, pvStopValue) (This)->lpVtbl->SetStartStopPosition(This, pguidStartPositionType, pvStartValue, pguidStopPositionType, pvStopValue)
#define IMFPMediaItem_HasVideo(This, pfHasVideo, pfSelected) (This)->lpVtbl->HasVideo(This, pfHasVideo, pfSelected)
#define IMFPMediaItem_HasAudio(This, pfHasAudio, pfSelected) (This)->lpVtbl->HasAudio(This, pfHasAudio, pfSelected)
#define IMFPMediaItem_IsProtected(This, pfProtected) (This)->lpVtbl->IsProtected(This, pfProtected)
#define IMFPMediaItem_GetDuration(This, guidPositionType, pvDurationValue) (This)->lpVtbl->GetDuration(This, guidPositionType, pvDurationValue)
#define IMFPMediaItem_GetNumberOfStreams(This, pdwStreamCount) (This)->lpVtbl->GetNumberOfStreams(This, pdwStreamCount)
#define IMFPMediaItem_GetStreamSelection(This, dwStreamIndex, pfEnabled) (This)->lpVtbl->GetStreamSelection(This, dwStreamIndex, pfEnabled)
#define IMFPMediaItem_SetStreamSelection(This, dwStreamIndex, fEnabled) (This)->lpVtbl->SetStreamSelection(This, dwStreamIndex, fEnabled)
#define IMFPMediaItem_GetStreamAttribute(This, dwStreamIndex, guidMFAttribute, pvValue) (This)->lpVtbl->GetStreamAttribute(This, dwStreamIndex, guidMFAttribute, pvValue)
#define IMFPMediaItem_GetPresentationAttribute(This, guidMFAttribute, pvValue) (This)->lpVtbl->GetPresentationAttribute(This, guidMFAttribute, pvValue)
#define IMFPMediaItem_GetCharacteristics(This, pCharacteristics) (This)->lpVtbl->GetCharacteristics(This, pCharacteristics)
#define IMFPMediaItem_SetStreamSink(This, dwStreamIndex, pMediaSink) (This)->lpVtbl->SetStreamSink(This, dwStreamIndex, pMediaSink)
#define IMFPMediaItem_GetMetadata(This, ppMetadataStore) (This)->lpVtbl->GetMetadata(This, ppMetadataStore)

#endif  /' __IMFPMediaItem_INTERFACE_DEFINED__ '/

/' Event Types and Structures '/
Enum MFP_EVENT_TYPE
    MFP_EVENT_TYPE_PLAY = 0
    MFP_EVENT_TYPE_PAUSE = 1
    MFP_EVENT_TYPE_STOP = 2
    MFP_EVENT_TYPE_POSITION_SET = 3
    MFP_EVENT_TYPE_RATE_SET = 4
    MFP_EVENT_TYPE_MEDIAITEM_CREATED = 5
    MFP_EVENT_TYPE_MEDIAITEM_SET = 6
    MFP_EVENT_TYPE_FRAME_STEP = 7
    MFP_EVENT_TYPE_MEDIAITEM_CLEARED = 8
    MFP_EVENT_TYPE_MF = 9
    MFP_EVENT_TYPE_ERROR = 10
    MFP_EVENT_TYPE_PLAYBACK_ENDED = 11
    MFP_EVENT_TYPE_ACQUIRE_USER_CREDENTIAL = 12
End Enum

Type MFP_EVENT_HEADER
    eEventType As MFP_EVENT_TYPE
    hrEvent As HRESULT
    pMediaPlayer As IMFPMediaPlayer Ptr
    eState As MFP_MEDIAPLAYER_STATE
    pPropertyStore As IPropertyStore Ptr
End Type

Type MFP_PLAY_EVENT
    header As MFP_EVENT_HEADER
    pMediaItem As IMFPMediaItem Ptr
End Type

Type MFP_PAUSE_EVENT
    header As MFP_EVENT_HEADER
    pMediaItem As IMFPMediaItem Ptr
End Type

Type MFP_STOP_EVENT
    header As MFP_EVENT_HEADER
    pMediaItem As IMFPMediaItem Ptr
End Type

Type MFP_POSITION_SET_EVENT
    header As MFP_EVENT_HEADER
    pMediaItem As IMFPMediaItem Ptr
End Type

Type MFP_RATE_SET_EVENT
    header As MFP_EVENT_HEADER
    pMediaItem As IMFPMediaItem Ptr
    flRate As Single
End Type

Type MFP_MEDIAITEM_CREATED_EVENT
    header As MFP_EVENT_HEADER
    pMediaItem As IMFPMediaItem Ptr
    dwUserData As DWORD_PTR
End Type

Type MFP_MEDIAITEM_SET_EVENT
    header As MFP_EVENT_HEADER
    pMediaItem As IMFPMediaItem Ptr
End Type

Type MFP_FRAME_STEP_EVENT
    header As MFP_EVENT_HEADER
    pMediaItem As IMFPMediaItem Ptr
End Type

Type MFP_MEDIAITEM_CLEARED_EVENT
    header As MFP_EVENT_HEADER
    pMediaItem As IMFPMediaItem Ptr
End Type

Type MFP_MF_EVENT
    header As MFP_EVENT_HEADER
    'MFEventType As MediaEventType
    'pMFMediaEvent As IMFMediaEvent Ptr
    pMediaItem As IMFPMediaItem Ptr
End Type

Type MFP_ERROR_EVENT
    header As MFP_EVENT_HEADER
End Type

Type MFP_PLAYBACK_ENDED_EVENT
    header As MFP_EVENT_HEADER
    pMediaItem As IMFPMediaItem Ptr
End Type

Type MFP_ACQUIRE_USER_CREDENTIAL_EVENT
    header As MFP_EVENT_HEADER
    dwUserData As DWORD_PTR
    fProceedWithAuthentication As WINBOOL
    hrAuthenticationStatus As HRESULT
    pwszURL As LPCWSTR
    pwszSite As LPCWSTR
    pwszRealm As LPCWSTR
    pwszPackage As LPCWSTR
    nRetries As Long
    flags As MFP_CREDENTIAL_FLAGS
    'pCredential As IMFNetCredential Ptr
End Type

/' Property Keys '/
'Extern Const PROPERTYKEY MFP_PKEY_StreamIndex
'Extern Const PROPERTYKEY MFP_PKEY_StreamRenderingResults
Dim Shared As PROPERTYKEY MFP_PKEY_StreamIndex = Type<PROPERTYKEY>(&ha7cf9740, &he8d9, &h4a87, { &hbd, &h8e, &h29, &h67, &h0, &h1f, &hd3, &had}, &h00)
Dim Shared As PROPERTYKEY MFP_PKEY_StreamRenderingResults = Type<PROPERTYKEY>(&ha7cf9740, &he8d9, &h4a87, { &hbd, &h8e, &h29, &h67, &h0, &h1f, &hd3, &had}, &h01)

/' Event Casting Macros '/
#define __MFP_CAST_EVENT(pHdr, Tag) CPtr(MFP_##Tag##_EVENT Ptr, pHdr)
#define MFP_GET_PLAY_EVENT(pHdr)                     IIf((pHdr)->eEventType = MFP_EVENT_TYPE_PLAY, __MFP_CAST_EVENT(pHdr, PLAY), NULL)
#define MFP_GET_PAUSE_EVENT(pHdr)                    IIf((pHdr)->eEventType = MFP_EVENT_TYPE_PAUSE, __MFP_CAST_EVENT(pHdr, PAUSE), NULL)
#define MFP_GET_STOP_EVENT(pHdr)                     IIf((pHdr)->eEventType = MFP_EVENT_TYPE_STOP, __MFP_CAST_EVENT(pHdr, Stop), NULL)
#define MFP_GET_POSITION_SET_EVENT(pHdr)             IIf((pHdr)->eEventType = MFP_EVENT_TYPE_POSITION_SET, __MFP_CAST_EVENT(pHdr, POSITION_SET), NULL)
#define MFP_GET_RATE_SET_EVENT(pHdr)                 IIf((pHdr)->eEventType = MFP_EVENT_TYPE_RATE_SET, __MFP_CAST_EVENT(pHdr, RATE_SET), NULL)
#define MFP_GET_MEDIAITEM_CREATED_EVENT(pHdr)        IIf((pHdr)->eEventType = MFP_EVENT_TYPE_MEDIAITEM_CREATED, __MFP_CAST_EVENT(pHdr, MEDIAITEM_CREATED), NULL)
#define MFP_GET_MEDIAITEM_SET_EVENT(pHdr)            IIf((pHdr)->eEventType = MFP_EVENT_TYPE_MEDIAITEM_SET, __MFP_CAST_EVENT(pHdr, MEDIAITEM_SET), NULL)
#define MFP_GET_FRAME_STEP_EVENT(pHdr)               IIf((pHdr)->eEventType = MFP_EVENT_TYPE_FRAME_STEP, __MFP_CAST_EVENT(pHdr, FRAME_STEP), NULL)
#define MFP_GET_MEDIAITEM_CLEARED_EVENT(pHdr)        IIf((pHdr)->eEventType = MFP_EVENT_TYPE_MEDIAITEM_CLEARED, __MFP_CAST_EVENT(pHdr, MEDIAITEM_CLEARED), NULL)
#define MFP_GET_MF_EVENT(pHdr)                       IIf((pHdr)->eEventType = MFP_EVENT_TYPE_MF, __MFP_CAST_EVENT(pHdr, MF), NULL)
#define MFP_GET_ERROR_EVENT(pHdr)                    IIf((pHdr)->eEventType = MFP_EVENT_TYPE_ERROR, __MFP_CAST_EVENT(pHdr, Error), NULL)
#define MFP_GET_PLAYBACK_ENDED_EVENT(pHdr)           IIf((pHdr)->eEventType = MFP_EVENT_TYPE_PLAYBACK_ENDED, __MFP_CAST_EVENT(pHdr, PLAYBACK_ENDED), NULL)
#define MFP_GET_ACQUIRE_USER_CREDENTIAL_EVENT(pHdr)  IIf((pHdr)->eEventType = MFP_EVENT_TYPE_ACQUIRE_USER_CREDENTIAL, __MFP_CAST_EVENT(pHdr, ACQUIRE_USER_CREDENTIAL), NULL)

/' IMFPMediaPlayerCallback Interface '/
#ifndef __IMFPMediaPlayerCallback_INTERFACE_DEFINED__
#define __IMFPMediaPlayerCallback_INTERFACE_DEFINED__

Type IMFPMediaPlayerCallbackVtbl
    /' IUnknown methods '/
    QueryInterface As Function(ByVal This As IMFPMediaPlayerCallback Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFPMediaPlayerCallback Ptr) As ULong
    Release As Function(ByVal This As IMFPMediaPlayerCallback Ptr) As ULong
    
    /' IMFPMediaPlayerCallback methods '/
    OnMediaPlayerEvent As Sub(ByVal This As IMFPMediaPlayerCallback Ptr, ByVal pEventHeader As MFP_EVENT_HEADER Ptr)
End Type

Type IMFPMediaPlayerCallback_
    lpVtbl As IMFPMediaPlayerCallbackVtbl Ptr
End Type

/' IMFPMediaPlayerCallback Method Macros '/
#define IMFPMediaPlayerCallback_QueryInterface(This, riid, ppvObject) (This)->lpVtbl->QueryInterface(This, riid, ppvObject)
#define IMFPMediaPlayerCallback_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IMFPMediaPlayerCallback_Release(This) (This)->lpVtbl->Release(This)
#define IMFPMediaPlayerCallback_OnMediaPlayerEvent(This, pEventHeader) (This)->lpVtbl->OnMediaPlayerEvent(This, pEventHeader)

#endif  /' __IMFPMediaPlayerCallback_INTERFACE_DEFINED__ '/

'#endif  /' WINVER >= _WIN32_WINNT_WIN7 '/

#endif  /' __MFPLAY_BI__ '/