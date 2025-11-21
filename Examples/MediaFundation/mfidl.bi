'分析附件的c++代码, 并逐行代码全部转换为freebasic(1.20.0) 的代码, 转换完成后输出完整的代码
/' 第1部分：基本类型和枚举 '/

#include "windows.bi"
#include "mfobjects.bi"
#include "mftransform.bi"

/' 基本类型定义 '/
Type MFTIME As LONGLONG
Type TOPOID As UINT64
Type MFSequencerElementId As DWORD

/' 枚举类型 '/
Enum MFSESSION_SETTOPOLOGY_FLAGS
    MFSESSION_SETTOPOLOGY_IMMEDIATE = &h1
    MFSESSION_SETTOPOLOGY_NORESOLUTION = &h2
    MFSESSION_SETTOPOLOGY_CLEAR_CURRENT = &h4
End Enum

Enum MFSESSION_GETFULLTOPOLOGY_FLAGS
    MFSESSION_GETFULLTOPOLOGY_CURRENT = &h1
End Enum

Enum MFPMPSESSION_CREATION_FLAGS
    MFPMPSESSION_UNPROTECTED_PROCESS = &h1
    MFPMPSESSION_IN_PROCESS = &h2
End Enum

Enum MF_TOPOLOGY_TYPE
    MF_TOPOLOGY_OUTPUT_NODE = 0
    MF_TOPOLOGY_SOURCESTREAM_NODE = 1
    MF_TOPOLOGY_TRANSFORM_NODE = 2
    MF_TOPOLOGY_TEE_NODE = 3
    MF_TOPOLOGY_MAX = &hffffffff
End Enum

Enum MF_CLOCK_STATE
    MFCLOCK_STATE_INVALID = 0
    MFCLOCK_STATE_RUNNING = 1
    MFCLOCK_STATE_STOPPED = 2
    MFCLOCK_STATE_PAUSED = 3
End Enum

Enum MF_CONNECT_METHOD
    MF_CONNECT_DIRECT = &h0
    MF_CONNECT_ALLOW_CONVERTER = &h1
    MF_CONNECT_ALLOW_DECODER = &h3
    MF_CONNECT_RESOLVE_INDEPENDENT_OUTPUTTYPES = &h4
    MF_CONNECT_AS_OPTIONAL = &h10000
    MF_CONNECT_AS_OPTIONAL_BRANCH = &h20000
End Enum

Enum MF_OBJECT_TYPE
    MF_OBJECT_MEDIASOURCE = 0
    MF_OBJECT_BYTESTREAM = 1
    MF_OBJECT_INVALID = 2
End Enum

Enum MFSTREAMSINK_MARKER_TYPE
    MFSTREAMSINK_MARKER_DEFAULT = 0
    MFSTREAMSINK_MARKER_ENDOFSEGMENT = 1
    MFSTREAMSINK_MARKER_TICK = 2
    MFSTREAMSINK_MARKER_EVENT = 3
End Enum

Enum MFTIMER_FLAGS
    MFTIMER_RELATIVE = &h1
End Enum

Enum MFCLOCK_CHARACTERISTICS_FLAGS
    MFCLOCK_CHARACTERISTICS_FLAG_FREQUENCY_10MHZ = &h2
    MFCLOCK_CHARACTERISTICS_FLAG_ALWAYS_RUNNING = &h4
    MFCLOCK_CHARACTERISTICS_FLAG_IS_SYSTEM_CLOCK = &h8
End Enum

Enum MFCLOCK_RELATIONAL_FLAGS
    MFCLOCK_RELATIONAL_FLAG_JITTER_NEVER_AHEAD = &h1
End Enum

Enum MFMEDIASOURCE_CHARACTERISTICS
    MFMEDIASOURCE_IS_LIVE = &h1
    MFMEDIASOURCE_CAN_SEEK = &h2
    MFMEDIASOURCE_CAN_PAUSE = &h4
    MFMEDIASOURCE_HAS_SLOW_SEEK = &h8
    MFMEDIASOURCE_HAS_MULTIPLE_PRESENTATIONS = &h10
    MFMEDIASOURCE_CAN_SKIPFORWARD = &h20
    MFMEDIASOURCE_CAN_SKIPBACKWARD = &h40
End Enum

Enum MFRATE_DIRECTION
    MFRATE_FORWARD = 0
    MFRATE_REVERSE = 1
End Enum

Enum MF_QUALITY_DROP_MODE
    MF_DROP_MODE_NONE = &h0
    MF_DROP_MODE_1 = &h1
    MF_DROP_MODE_2 = &h2
    MF_DROP_MODE_3 = &h3
    MF_DROP_MODE_4 = &h4
    MF_DROP_MODE_5 = &h5
    MF_NUM_DROP_MODES = &h6
End Enum

Enum MF_QUALITY_LEVEL
    MF_QUALITY_NORMAL = &h0
    MF_QUALITY_NORMAL_MINUS_1 = &h1
    MF_QUALITY_NORMAL_MINUS_2 = &h2
    MF_QUALITY_NORMAL_MINUS_3 = &h3
    MF_QUALITY_NORMAL_MINUS_4 = &h4
    MF_QUALITY_NORMAL_MINUS_5 = &h5
    MF_NUM_QUALITY_LEVELS = &h6
End Enum

Enum MF_TOPOLOGY_RESOLUTION_STATUS_FLAGS
    MF_TOPOLOGY_RESOLUTION_SUCCEEDED = &h0
    MF_OPTIONAL_NODE_REJECTED_MEDIA_TYPE = &h1
    MF_OPTIONAL_NODE_REJECTED_PROTECTED_PROCESS = &h2
End Enum

/' 第2部分：结构体定义 '/

/' 时钟属性结构 '/
Type MFCLOCK_PROPERTIES
    qwCorrelationRate As UINT64
    guidClockId As GUID
    dwClockFlags As DWORD
    qwClockFrequency As UINT64
    dwClockTolerance As DWORD
    dwClockJitter As DWORD
End Type

/' 哈希信息结构 '/
#define SHA_HASH_LEN 20
#define STR_HASH_LEN (SHA_HASH_LEN*2+3)

Type MFRR_COMPONENT_HASH_INFO
    ulReason As DWORD
    rgHeaderHash(0 To STR_HASH_LEN-1) As WCHAR
    rgPublicKeyHash(0 To STR_HASH_LEN-1) As WCHAR
    wszName(0 To MAX_PATH-1) As WCHAR
End Type

/' 字节流缓冲参数结构 '/
Type MF_LEAKY_BUCKET_PAIR
    dwBitrate As DWORD
    msBufferWindow As DWORD
End Type

Type MFBYTESTREAM_BUFFERING_PARAMS
    cbTotalFileSize As QWORD
    cbPlayableDataSize As QWORD
    prgBuckets As MF_LEAKY_BUCKET_PAIR Ptr
    cBuckets As DWORD
    qwNetBufferingTime As QWORD
    qwExtraBufferingTimeDuringSeek As QWORD
    qwPlayDuration As QWORD
    dRate As Single
End Type

/' 网络相关结构 '/
Enum MFNETSOURCE_PROTOCOL_TYPE
    MFNETSOURCE_UNDEFINED = &h0
    MFNETSOURCE_HTTP = &h1
    MFNETSOURCE_RTSP = &h2
    MFNETSOURCE_FILE = &h3
    MFNETSOURCE_MULTICAST = &h4
End Enum

Enum MFNETSOURCE_TRANSPORT_TYPE
    MFNETSOURCE_UDP = 0
    MFNETSOURCE_TCP = 1
End Enum

Enum MFNETSOURCE_STATISTICS_IDS
    MFNETSOURCE_RECVPACKETS_ID = 0
    MFNETSOURCE_LOSTPACKETS_ID = 1
    ' ... 其他统计ID ...
End Enum

/' DRM相关结构 '/
Enum MFPOLICYMANAGER_ACTION
    PEACTION_NO = 0
    PEACTION_PLAY = 1
    PEACTION_COPY = 2
    PEACTION_EXPORT = 3
    PEACTION_EXTRACT = 4
    PEACTION_RESERVED1 = 5
    PEACTION_RESERVED2 = 6
    PEACTION_RESERVED3 = 7
    PEACTION_LAST = 7
End Enum

Type MFINPUTTRUSTAUTHORITY_ACCESS_ACTION
    Action As MFPOLICYMANAGER_ACTION
    pbTicket As Byte Ptr
    cbTicket As DWORD
End Type

Type MFINPUTTRUSTAUTHORITY_ACCESS_PARAMS
    dwSize As DWORD
    dwVer As DWORD
    cbSignatureOffset As DWORD
    cbSignatureSize As DWORD
    cbExtensionOffset As DWORD
    cbExtensionSize As DWORD
    cActions As DWORD
    rgOutputActions(0 To 0) As MFINPUTTRUSTAUTHORITY_ACCESS_ACTION
End Type

/' ASF相关结构 '/
Type ASF_FLAT_PICTURE
    bPictureType As Byte
    dwDataLen As DWORD
End Type

Type ASF_FLAT_SYNCHRONISED_LYRICS
    bTimeStampFormat As Byte
    bContentType As Byte
    dwLyricsLen As DWORD
End Type

Enum SAMPLE_PROTECTION_VERSION
    SAMPLE_PROTECTION_VERSION_NO = 0
    SAMPLE_PROTECTION_VERSION_BASIC_LOKI = 1
    SAMPLE_PROTECTION_VERSION_SCATTER = 2
    SAMPLE_PROTECTION_VERSION_RC4 = 3
End Enum

/' 第3部分：GUID常量定义 '/

/' 接口GUID '/
#define IID_IMFTopologyNode @83cf873a, @f6da, @4bc8, {&h82, &h3f, &hba, &hcf, &hd5, &h5d, &hc4, &h30}
#define IID_IMFTopology @83cf873a, @f6da, @4bc8, {&h82, &h3f, &hba, &hcf, &hd5, &h5d, &hc4, &h33}
#define IID_IMFGetService @fa993888, @4383, @415a, {&ha9, &h30, &hdd, &h47, &h2a, &h8c, &hf6, &hf7}
#define IID_IMFClock @2eb1e945, @18b8, @4139, {&h9b, &h1a, &hd5, &hd5, &h84, &h81, &h85, &h30}
#define IID_IMFMediaSession @90377834, @21d0, @4dee, {&h82, &h14, &hba, &h2e, &h3e, &h6c, &h11, &h27}
#define IID_IMFMediaTypeHandler @e93dcf6c, @4b07, @4e1e, {&h81, &h23, &haa, &h16, &hed, &h6e, &had, &hf5}
#define IID_IMFStreamDescriptor @56c03d9c, @9dbb, @45f5, {&hab, &h4b, &hd8, &h0f, &h47, &hc0, &h59, &h38}
#define IID_IMFPresentationDescriptor @03cb2711, @24d7, @4db6, {&ha1, &h7f, &hf3, &ha7, &ha4, &h79, &ha5, &h36}
#define IID_IMFMediaSource @279a808d, @aec7, @40c8, {&h9c, &h6b, &ha6, &hb4, &h92, &hc7, &h8a, &h66}
#define IID_IMFMediaSourceEx @3c9b2eb9, @86d5, @4514, {&ha3, &h94, &hf5, &h66, &h64, &hf9, &hf0, &hd8}
#define IID_IMFByteStreamBuffering @6d66d782, @1d4f, @4db7, {&h8c, &h63, &hcb, &h8c, &h77, &hf1, &hef, &h5e}
#define IID_IMFClockStateSink @f6696e82, @74f7, @4f3d, {&ha1, &h78, &h8a, &h5e, &h09, &hc3, &h65, &h9f}
#define IID_IMFAudioStreamVolume @76b1bbdb, @4ec8, @4f36, {&hb1, &h06, &h70, &ha9, &h31, &h6d, &hf5, &h93}
#define IID_IMFMediaSink @6ef2a660, @47c0, @4666, {&hb1, &h3d, &hcb, &hb7, &h17, &hf2, &hfa, &h2c}
#define IID_IMFFinalizableMediaSink @eaecb74a, @9a50, @42ce, {&h95, &h41, &h6a, &h7f, &h57, &haa, &h4a, &hd7}
#define IID_IMFMediaSinkPreroll @5dfd4b2a, @7674, @4110, {&ha4, &he6, &h8a, &h68, &hfd, &h5f, &h36, &h88}
#define IID_IMFMediaStream @d182108f, @4ec6, @443f, {&haa, &h42, &ha7, &h11, &h06, &hec, &h82, &h5f}
#define IID_IMFMetadata @f88cfb8c, @ef16, @4991, {&hb4, &h50, &hcb, &h8c, &h69, &he5, &h17, &h04}
#define IID_IMFMetadataProvider @56181d2d, @e221, @4adb, {&hb1, &hc8, &h3c, &hee, &h6a, &h53, &hf7, &h6f}
#define IID_IMFPresentationTimeSource @7ff12cce, @f76f, @41c2, {&h86, &h3b, &h16, &h66, &hc8, &he5, &he1, &h39}
#define IID_IMFPresentationClock @868ce85c, @8ea9, @4f55, {&hab, &h82, &hb0, &h09, &ha9, &h10, &ha8, &h05}

/' 属性GUID '/
#define MF_PD_DURATION @6c990d33, @bb8e, @477a, {&h85, &h98, &hd, &h5d, &h96, &hfc, &hd8, &h8a}
#define MF_TRANSCODE_CONTAINERTYPE @150ff23f, @4abc, @478b, {&hac, &h4f, &he1, &h91, &h6f, &hba, &h1c, &hca}

/' 转码容器类型GUID '/
#define MFTranscodeContainerType_ASF @430f6f6e, @b6bf, @4fc1, {&ha0, &hbd, &h9e, &he4, &h6e, &hee, &h2a, &hfb}
#define MFTranscodeContainerType_MPEG4 @dc6cd05d, @b9d0, @40ef, {&hbd, &h35, &hfa, &h62, &h2c, &h1a, &hb2, &h8a}
#define MFTranscodeContainerType_MP3 @e438b912, @83f1, @4de6, {&h9e, &h3a, &h9f, &hfb, &hc6, &hdd, &h24, &hd1}
#define MFTranscodeContainerType_FLAC @31344aa3, @05a9, @42b5, {&h90, &h1b, &h8e, &h9d, &h42, &h57, &hf7, &h5e}
#define MFTranscodeContainerType_3GP @34c50167, @4472, @4f34, {&h9e, &ha0, &hc4, &h9f, &hba, &hcf, &h03, &h7d}
#define MFTranscodeContainerType_AC3 @6d8d91c3, @8c91, @4ed1, {&h87, &h42, &h8c, &h34, &h7d, &h5b, &h44, &hd0}
#define MFTranscodeContainerType_ADTS @132fd27d, @0f02, @43de, {&ha3, &h01, &h38, &hfb, &hbb, &hb3, &h83, &h4e}
#define MFTranscodeContainerType_MPEG2 @bfc2dbf9, @7bb4, @4f8f, {&haf, &hde, &he1, &h12, &hc4, &h4b, &ha8, &h82}
#define MFTranscodeContainerType_WAVE @64c3453c, @0f26, @4741, {&hbe, &h63, &h87, &hbd, &hf8, &hbb, &h93, &h5b}
#define MFTranscodeContainerType_AVI @7edfe8af, @402f, @4d76, {&ha3, &h3c, &h61, &h9f, &hd1, &h57, &hd0, &hf1}
#define MFTranscodeContainerType_AMR @25d5ad3, @621a, @475b, {&h96, &h4d, &h66, &hb1, &hc8, &h24, &hf0, &h79}

#if (WINVER >= _WIN32_WINNT_WIN8)
#define MFTranscodeContainerType_FMPEG4 @9ba876f1, @419f, @4b77, {&ha1, &he0, &h35, &h95, &h9d, &h9d, &h40, &h4}
#define MF_SOURCE_STREAM_SUPPORTS_HW_CONNECTION @a38253aa, @6314, @42fd, {&ha3, &hce, &hbb, &h27, &hb6, &h85, &h99, &h46}
#endif

/' 第4部分：核心接口定义 '/

/' IMFTopologyNode 接口 '/
Type IMFTopologyNodeVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFTopologyNode Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFTopologyNode Ptr) As ULong
    Release As Function(ByVal This As IMFTopologyNode Ptr) As ULong
    
    ' IMFAttributes 方法
    GetItem As Function(ByVal This As IMFTopologyNode Ptr, ByVal guidKey As REFGUID, ByVal pValue As PROPVARIANT Ptr) As HRESULT
    GetItemType As Function(ByVal This As IMFTopologyNode Ptr, ByVal guidKey As REFGUID, ByVal pType As MF_ATTRIBUTE_TYPE Ptr) As HRESULT
    CompareItem As Function(ByVal This As IMFTopologyNode Ptr, ByVal guidKey As REFGUID, ByVal Value As REFPROPVARIANT, ByVal pbResult As WINBOOL Ptr) As HRESULT
    Compare As Function(ByVal This As IMFTopologyNode Ptr, ByVal pTheirs As IMFAttributes Ptr, ByVal MatchType As MF_ATTRIBUTES_MATCH_TYPE, ByVal pbResult As WINBOOL Ptr) As HRESULT
    GetUINT32 As Function(ByVal This As IMFTopologyNode Ptr, ByVal guidKey As REFGUID, ByVal punValue As UINT32 Ptr) As HRESULT
    GetUINT64 As Function(ByVal This As IMFTopologyNode Ptr, ByVal guidKey As REFGUID, ByVal punValue As UINT64 Ptr) As HRESULT
    GetDouble As Function(ByVal This As IMFTopologyNode Ptr, ByVal guidKey As REFGUID, ByVal pfValue As Double Ptr) As HRESULT
    GetGUID As Function(ByVal This As IMFTopologyNode Ptr, ByVal guidKey As REFGUID, ByVal pguidValue As GUID Ptr) As HRESULT
    GetStringLength As Function(ByVal This As IMFTopologyNode Ptr, ByVal guidKey As REFGUID, ByVal pcchLength As UINT32 Ptr) As HRESULT
    GetString As Function(ByVal This As IMFTopologyNode Ptr, ByVal guidKey As REFGUID, ByVal pwszValue As LPWSTR, ByVal cchBufSize As UINT32, ByVal pcchLength As UINT32 Ptr) As HRESULT
    GetAllocatedString As Function(ByVal This As IMFTopologyNode Ptr, ByVal guidKey As REFGUID, ByVal ppwszValue As LPWSTR Ptr, ByVal pcchLength As UINT32 Ptr) As HRESULT
    GetBlobSize As Function(ByVal This As IMFTopologyNode Ptr, ByVal guidKey As REFGUID, ByVal pcbBlobSize As UINT32 Ptr) As HRESULT
    GetBlob As Function(ByVal This As IMFTopologyNode Ptr, ByVal guidKey As REFGUID, ByVal pBuf As UINT8 Ptr, ByVal cbBufSize As UINT32, ByVal pcbBlobSize As UINT32 Ptr) As HRESULT
    GetAllocatedBlob As Function(ByVal This As IMFTopologyNode Ptr, ByVal guidKey As REFGUID, ByVal ppBuf As UINT8 Ptr Ptr, ByVal pcbSize As UINT32 Ptr) As HRESULT
    GetUnknown As Function(ByVal This As IMFTopologyNode Ptr, ByVal guidKey As REFGUID, ByVal riid As REFIID, ByVal ppv As Any Ptr Ptr) As HRESULT
    SetItem As Function(ByVal This As IMFTopologyNode Ptr, ByVal guidKey As REFGUID, ByVal Value As REFPROPVARIANT) As HRESULT
    DeleteItem As Function(ByVal This As IMFTopologyNode Ptr, ByVal guidKey As REFGUID) As HRESULT
    DeleteAllItems As Function(ByVal This As IMFTopologyNode Ptr) As HRESULT
    SetUINT32 As Function(ByVal This As IMFTopologyNode Ptr, ByVal guidKey As REFGUID, ByVal unValue As UINT32) As HRESULT
    SetUINT64 As Function(ByVal This As IMFTopologyNode Ptr, ByVal guidKey As REFGUID, ByVal unValue As UINT64) As HRESULT
    SetDouble As Function(ByVal This As IMFTopologyNode Ptr, ByVal guidKey As REFGUID, ByVal fValue As Double) As HRESULT
    SetGUID As Function(ByVal This As IMFTopologyNode Ptr, ByVal guidKey As REFGUID, ByVal guidValue As REFGUID) As HRESULT
    SetString As Function(ByVal This As IMFTopologyNode Ptr, ByVal guidKey As REFGUID, ByVal wszValue As LPCWSTR) As HRESULT
    SetBlob As Function(ByVal This As IMFTopologyNode Ptr, ByVal guidKey As REFGUID, ByVal pBuf As Const UINT8 Ptr, ByVal cbBufSize As UINT32) As HRESULT
    SetUnknown As Function(ByVal This As IMFTopologyNode Ptr, ByVal guidKey As REFGUID, ByVal pUnknown As IUnknown Ptr) As HRESULT
    LockStore As Function(ByVal This As IMFTopologyNode Ptr) As HRESULT
    UnlockStore As Function(ByVal This As IMFTopologyNode Ptr) As HRESULT
    GetCount As Function(ByVal This As IMFTopologyNode Ptr, ByVal pcItems As UINT32 Ptr) As HRESULT
    GetItemByIndex As Function(ByVal This As IMFTopologyNode Ptr, ByVal unIndex As UINT32, ByVal pguidKey As GUID Ptr, ByVal pValue As PROPVARIANT Ptr) As HRESULT
    CopyAllItems As Function(ByVal This As IMFTopologyNode Ptr, ByVal pDest As IMFAttributes Ptr) As HRESULT
    
    ' IMFTopologyNode 方法
    SetObject As Function(ByVal This As IMFTopologyNode Ptr, ByVal pObject As IUnknown Ptr) As HRESULT
    GetObject As Function(ByVal This As IMFTopologyNode Ptr, ByVal ppObject As IUnknown Ptr Ptr) As HRESULT
    GetNodeType As Function(ByVal This As IMFTopologyNode Ptr, ByVal pType As MF_TOPOLOGY_TYPE Ptr) As HRESULT
    GetTopoNodeID As Function(ByVal This As IMFTopologyNode Ptr, ByVal pID As TOPOID Ptr) As HRESULT
    SetTopoNodeID As Function(ByVal This As IMFTopologyNode Ptr, ByVal ullTopoID As TOPOID) As HRESULT
    GetInputCount As Function(ByVal This As IMFTopologyNode Ptr, ByVal pcInputs As DWORD Ptr) As HRESULT
    GetOutputCount As Function(ByVal This As IMFTopologyNode Ptr, ByVal pcOutputs As DWORD Ptr) As HRESULT
    ConnectOutput As Function(ByVal This As IMFTopologyNode Ptr, ByVal dwOutputIndex As DWORD, ByVal pDownstreamNode As IMFTopologyNode Ptr, ByVal dwInputIndexOnDownstreamNode As DWORD) As HRESULT
    DisconnectOutput As Function(ByVal This As IMFTopologyNode Ptr, ByVal dwOutputIndex As DWORD) As HRESULT
    GetInput As Function(ByVal This As IMFTopologyNode Ptr, ByVal dwInputIndex As DWORD, ByVal ppUpstreamNode As IMFTopologyNode Ptr Ptr, ByVal pdwOutputIndexOnUpstreamNode As DWORD Ptr) As HRESULT
    GetOutput As Function(ByVal This As IMFTopologyNode Ptr, ByVal dwOutputIndex As DWORD, ByVal ppDownstreamNode As IMFTopologyNode Ptr Ptr, ByVal pdwInputIndexOnDownstreamNode As DWORD Ptr) As HRESULT
    SetOutputPrefType As Function(ByVal This As IMFTopologyNode Ptr, ByVal dwOutputIndex As DWORD, ByVal pType As IMFMediaType Ptr) As HRESULT
    GetOutputPrefType As Function(ByVal This As IMFTopologyNode Ptr, ByVal dwOutputIndex As DWORD, ByVal ppType As IMFMediaType Ptr Ptr) As HRESULT
    SetInputPrefType As Function(ByVal This As IMFTopologyNode Ptr, ByVal dwInputIndex As DWORD, ByVal pType As IMFMediaType Ptr) As HRESULT
    GetInputPrefType As Function(ByVal This As IMFTopologyNode Ptr, ByVal dwInputIndex As DWORD, ByVal ppType As IMFMediaType Ptr Ptr) As HRESULT
    CloneFrom As Function(ByVal This As IMFTopologyNode Ptr, ByVal pNode As IMFTopologyNode Ptr) As HRESULT
End Type

Type IMFTopologyNode
    lpVtbl As IMFTopologyNodeVtbl Ptr
End Type

/' IMFTopology 接口 '/
Type IMFTopologyVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFTopology Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFTopology Ptr) As ULong
    Release As Function(ByVal This As IMFTopology Ptr) As ULong
    
    ' IMFAttributes 方法 (与IMFTopologyNode相同，省略详细定义)
    GetItem As Function(ByVal This As IMFTopology Ptr, ByVal guidKey As REFGUID, ByVal pValue As PROPVARIANT Ptr) As HRESULT
    ' ... 其他IMFAttributes方法 ...
    
    ' IMFTopology 方法
    GetTopologyID As Function(ByVal This As IMFTopology Ptr, ByVal pID As TOPOID Ptr) As HRESULT
    AddNode As Function(ByVal This As IMFTopology Ptr, ByVal pNode As IMFTopologyNode Ptr) As HRESULT
    RemoveNode As Function(ByVal This As IMFTopology Ptr, ByVal pNode As IMFTopologyNode Ptr) As HRESULT
    GetNodeCount As Function(ByVal This As IMFTopology Ptr, ByVal pwNodes As WORD Ptr) As HRESULT
    GetNode As Function(ByVal This As IMFTopology Ptr, ByVal wIndex As WORD, ByVal ppNode As IMFTopologyNode Ptr Ptr) As HRESULT
    Clear As Function(ByVal This As IMFTopology Ptr) As HRESULT
    CloneFrom As Function(ByVal This As IMFTopology Ptr, ByVal pTopology As IMFTopology Ptr) As HRESULT
    GetNodeByID As Function(ByVal This As IMFTopology Ptr, ByVal qwTopoNodeID As TOPOID, ByVal ppNode As IMFTopologyNode Ptr Ptr) As HRESULT
    GetSourceNodeCollection As Function(ByVal This As IMFTopology Ptr, ByVal ppCollection As IMFCollection Ptr Ptr) As HRESULT
    GetOutputNodeCollection As Function(ByVal This As IMFTopology Ptr, ByVal ppCollection As IMFCollection Ptr Ptr) As HRESULT
End Type

Type IMFTopology
    lpVtbl As IMFTopologyVtbl Ptr
End Type

/' 第5部分：更多接口定义 '/

/' IMFGetService 接口 '/
Type IMFGetServiceVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFGetService Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFGetService Ptr) As ULong
    Release As Function(ByVal This As IMFGetService Ptr) As ULong
    
    ' IMFGetService 方法
    GetService As Function(ByVal This As IMFGetService Ptr, ByVal guidService As REFGUID, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
End Type

Type IMFGetService
    lpVtbl As IMFGetServiceVtbl Ptr
End Type

/' IMFClock 接口 '/
Type IMFClockVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFClock Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFClock Ptr) As ULong
    Release As Function(ByVal This As IMFClock Ptr) As ULong
    
    ' IMFClock 方法
    GetClockCharacteristics As Function(ByVal This As IMFClock Ptr, ByVal pdwCharacteristics As DWORD Ptr) As HRESULT
    GetCorrelatedTime As Function(ByVal This As IMFClock Ptr, ByVal dwReserved As DWORD, ByVal pllClockTime As LONGLONG Ptr, ByVal phnsSystemTime As MFTIME Ptr) As HRESULT
    GetContinuityKey As Function(ByVal This As IMFClock Ptr, ByVal pdwContinuityKey As DWORD Ptr) As HRESULT
    GetState As Function(ByVal This As IMFClock Ptr, ByVal dwReserved As DWORD, ByVal peClockState As MF_CLOCK_STATE Ptr) As HRESULT
    GetProperties As Function(ByVal This As IMFClock Ptr, ByVal pClockProperties As MFCLOCK_PROPERTIES Ptr) As HRESULT
End Type

Type IMFClock
    lpVtbl As IMFClockVtbl Ptr
End Type

/' IMFMediaSession 接口 '/
Type IMFMediaSessionVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFMediaSession Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFMediaSession Ptr) As ULong
    Release As Function(ByVal This As IMFMediaSession Ptr) As ULong
    
    ' IMFMediaEventGenerator 方法
    GetEvent As Function(ByVal This As IMFMediaSession Ptr, ByVal dwFlags As DWORD, ByVal ppEvent As IMFMediaEvent Ptr Ptr) As HRESULT
    BeginGetEvent As Function(ByVal This As IMFMediaSession Ptr, ByVal pCallback As IMFAsyncCallback Ptr, ByVal punkState As IUnknown Ptr) As HRESULT
    EndGetEvent As Function(ByVal This As IMFMediaSession Ptr, ByVal pResult As IMFAsyncResult Ptr, ByVal ppEvent As IMFMediaEvent Ptr Ptr) As HRESULT
    QueueEvent As Function(ByVal This As IMFMediaSession Ptr, ByVal met As MediaEventType, ByVal guidExtendedType As REFGUID, ByVal hrStatus As HRESULT, ByVal pvValue As Const PROPVARIANT Ptr) As HRESULT
    
    ' IMFMediaSession 方法
    SetTopology As Function(ByVal This As IMFMediaSession Ptr, ByVal dwSetTopologyFlags As DWORD, ByVal pTopology As IMFTopology Ptr) As HRESULT
    ClearTopologies As Function(ByVal This As IMFMediaSession Ptr) As HRESULT
    Start As Function(ByVal This As IMFMediaSession Ptr, ByVal pguidTimeFormat As Const GUID Ptr, ByVal pvarStartPosition As Const PROPVARIANT Ptr) As HRESULT
    Pause As Function(ByVal This As IMFMediaSession Ptr) As HRESULT
    Stop As Function(ByVal This As IMFMediaSession Ptr) As HRESULT
    Close As Function(ByVal This As IMFMediaSession Ptr) As HRESULT
    Shutdown As Function(ByVal This As IMFMediaSession Ptr) As HRESULT
    GetClock As Function(ByVal This As IMFMediaSession Ptr, ByVal ppClock As IMFClock Ptr Ptr) As HRESULT
    GetSessionCapabilities As Function(ByVal This As IMFMediaSession Ptr, ByVal pdwCaps As DWORD Ptr) As HRESULT
    GetFullTopology As Function(ByVal This As IMFMediaSession Ptr, ByVal dwGetFullTopologyFlags As DWORD, ByVal TopoId As TOPOID, ByVal ppFullTopology As IMFTopology Ptr Ptr) As HRESULT
End Type

Type IMFMediaSession
    lpVtbl As IMFMediaSessionVtbl Ptr
End Type

/' IMFMediaTypeHandler 接口 '/
Type IMFMediaTypeHandlerVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFMediaTypeHandler Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFMediaTypeHandler Ptr) As ULong
    Release As Function(ByVal This As IMFMediaTypeHandler Ptr) As ULong
    
    ' IMFMediaTypeHandler 方法
    IsMediaTypeSupported As Function(ByVal This As IMFMediaTypeHandler Ptr, ByVal pMediaType As IMFMediaType Ptr, ByVal ppMediaType As IMFMediaType Ptr Ptr) As HRESULT
    GetMediaTypeCount As Function(ByVal This As IMFMediaTypeHandler Ptr, ByVal pdwTypeCount As DWORD Ptr) As HRESULT
    GetMediaTypeByIndex As Function(ByVal This As IMFMediaTypeHandler Ptr, ByVal dwIndex As DWORD, ByVal ppType As IMFMediaType Ptr Ptr) As HRESULT
    SetCurrentMediaType As Function(ByVal This As IMFMediaTypeHandler Ptr, ByVal pMediaType As IMFMediaType Ptr) As HRESULT
    GetCurrentMediaType As Function(ByVal This As IMFMediaTypeHandler Ptr, ByVal ppMediaType As IMFMediaType Ptr Ptr) As HRESULT
    GetMajorType As Function(ByVal This As IMFMediaTypeHandler Ptr, ByVal pguidMajorType As GUID Ptr) As HRESULT
End Type

Type IMFMediaTypeHandler
    lpVtbl As IMFMediaTypeHandlerVtbl Ptr
End Type

/' 函数声明 '/
Declare Function MFRequireProtectedEnvironment Lib "Mfplat.dll" Alias "MFRequireProtectedEnvironment" (ByVal pPresentationDescriptor As IMFPresentationDescriptor Ptr) As HRESULT
Declare Function MFSerializePresentationDescriptor Lib "Mfplat.dll" Alias "MFSerializePresentationDescriptor" (ByVal pPD As IMFPresentationDescriptor Ptr, ByVal pcbData As DWORD Ptr, ByVal ppbData As Byte Ptr Ptr) As HRESULT

/' 常量定义 '/
#define MEDIASINK_FIXED_STREAMS                 &h00000001
#define MEDIASINK_CANNOT_MATCH_CLOCK            &h00000002
#define MEDIASINK_RATELESS                      &h00000004
#define MEDIASINK_CLOCK_REQUIRED                &h00000008
#define MEDIASINK_CAN_PREROLL                   &h00000010
#define MEDIASINK_REQUIRE_REFERENCE_MEDIATYPE   &h00000020

Enum
    MF_RESOLUTION_MEDIASOURCE = &h1
    MF_RESOLUTION_BYTESTREAM = &h2
    MF_RESOLUTION_CONTENT_DOES_NOT_HAVE_TO_MATCH_EXTENSION_OR_MIME_TYPE = &h10
    MF_RESOLUTION_KEEP_BYTE_STREAM_ALIVE_ON_FAIL = &h20
    MF_RESOLUTION_READ = &h10000
    MF_RESOLUTION_WRITE = &h20000
End Enum

/' 第6部分：流描述符和表示描述符接口 '/

/' IMFStreamDescriptor 接口 '/
Type IMFStreamDescriptorVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFStreamDescriptor Ptr) As ULong
    Release As Function(ByVal This As IMFStreamDescriptor Ptr) As ULong
    
    ' IMFAttributes 方法
    GetItem As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal guidKey As REFGUID, ByVal pValue As PROPVARIANT Ptr) As HRESULT
    GetItemType As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal guidKey As REFGUID, ByVal pType As MF_ATTRIBUTE_TYPE Ptr) As HRESULT
    CompareItem As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal guidKey As REFGUID, ByVal Value As REFPROPVARIANT, ByVal pbResult As WINBOOL Ptr) As HRESULT
    Compare As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal pTheirs As IMFAttributes Ptr, ByVal MatchType As MF_ATTRIBUTES_MATCH_TYPE, ByVal pbResult As WINBOOL Ptr) As HRESULT
    GetUINT32 As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal guidKey As REFGUID, ByVal punValue As UINT32 Ptr) As HRESULT
    GetUINT64 As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal guidKey As REFGUID, ByVal punValue As UINT64 Ptr) As HRESULT
    GetDouble As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal guidKey As REFGUID, ByVal pfValue As Double Ptr) As HRESULT
    GetGUID As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal guidKey As REFGUID, ByVal pguidValue As GUID Ptr) As HRESULT
    GetStringLength As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal guidKey As REFGUID, ByVal pcchLength As UINT32 Ptr) As HRESULT
    GetString As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal guidKey As REFGUID, ByVal pwszValue As LPWSTR, ByVal cchBufSize As UINT32, ByVal pcchLength As UINT32 Ptr) As HRESULT
    GetAllocatedString As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal guidKey As REFGUID, ByVal ppwszValue As LPWSTR Ptr, ByVal pcchLength As UINT32 Ptr) As HRESULT
    GetBlobSize As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal guidKey As REFGUID, ByVal pcbBlobSize As UINT32 Ptr) As HRESULT
    GetBlob As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal guidKey As REFGUID, ByVal pBuf As UINT8 Ptr, ByVal cbBufSize As UINT32, ByVal pcbBlobSize As UINT32 Ptr) As HRESULT
    GetAllocatedBlob As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal guidKey As REFGUID, ByVal ppBuf As UINT8 Ptr Ptr, ByVal pcbSize As UINT32 Ptr) As HRESULT
    GetUnknown As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal guidKey As REFGUID, ByVal riid As REFIID, ByVal ppv As Any Ptr Ptr) As HRESULT
    SetItem As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal guidKey As REFGUID, ByVal Value As REFPROPVARIANT) As HRESULT
    DeleteItem As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal guidKey As REFGUID) As HRESULT
    DeleteAllItems As Function(ByVal This As IMFStreamDescriptor Ptr) As HRESULT
    SetUINT32 As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal guidKey As REFGUID, ByVal unValue As UINT32) As HRESULT
    SetUINT64 As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal guidKey As REFGUID, ByVal unValue As UINT64) As HRESULT
    SetDouble As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal guidKey As REFGUID, ByVal fValue As Double) As HRESULT
    SetGUID As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal guidKey As REFGUID, ByVal guidValue As REFGUID) As HRESULT
    SetString As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal guidKey As REFGUID, ByVal wszValue As LPCWSTR) As HRESULT
    SetBlob As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal guidKey As REFGUID, ByVal pBuf As Const UINT8 Ptr, ByVal cbBufSize As UINT32) As HRESULT
    SetUnknown As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal guidKey As REFGUID, ByVal pUnknown As IUnknown Ptr) As HRESULT
    LockStore As Function(ByVal This As IMFStreamDescriptor Ptr) As HRESULT
    UnlockStore As Function(ByVal This As IMFStreamDescriptor Ptr) As HRESULT
    GetCount As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal pcItems As UINT32 Ptr) As HRESULT
    GetItemByIndex As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal unIndex As UINT32, ByVal pguidKey As GUID Ptr, ByVal pValue As PROPVARIANT Ptr) As HRESULT
    CopyAllItems As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal pDest As IMFAttributes Ptr) As HRESULT
    
    ' IMFStreamDescriptor 方法
    GetStreamIdentifier As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal pdwStreamIdentifier As DWORD Ptr) As HRESULT
    GetMediaTypeHandler As Function(ByVal This As IMFStreamDescriptor Ptr, ByVal ppMediaTypeHandler As IMFMediaTypeHandler Ptr Ptr) As HRESULT
End Type

Type IMFStreamDescriptor
    lpVtbl As IMFStreamDescriptorVtbl Ptr
End Type

/' IMFPresentationDescriptor 接口 '/
Type IMFPresentationDescriptorVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFPresentationDescriptor Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFPresentationDescriptor Ptr) As ULong
    Release As Function(ByVal This As IMFPresentationDescriptor Ptr) As ULong
    
    ' IMFAttributes 方法 (与IMFStreamDescriptor相同，省略详细定义)
    GetItem As Function(ByVal This As IMFPresentationDescriptor Ptr, ByVal guidKey As REFGUID, ByVal pValue As PROPVARIANT Ptr) As HRESULT
    ' ... 其他IMFAttributes方法 ...
    
    ' IMFPresentationDescriptor 方法
    GetStreamDescriptorCount As Function(ByVal This As IMFPresentationDescriptor Ptr, ByVal pdwDescriptorCount As DWORD Ptr) As HRESULT
    GetStreamDescriptorByIndex As Function(ByVal This As IMFPresentationDescriptor Ptr, ByVal dwIndex As DWORD, ByVal pfSelected As WINBOOL Ptr, ByVal ppDescriptor As IMFStreamDescriptor Ptr Ptr) As HRESULT
    SelectStream As Function(ByVal This As IMFPresentationDescriptor Ptr, ByVal dwDescriptorIndex As DWORD) As HRESULT
    DeselectStream As Function(ByVal This As IMFPresentationDescriptor Ptr, ByVal dwDescriptorIndex As DWORD) As HRESULT
    Clone As Function(ByVal This As IMFPresentationDescriptor Ptr, ByVal ppPresentationDescriptor As IMFPresentationDescriptor Ptr Ptr) As HRESULT
End Type

Type IMFPresentationDescriptor
    lpVtbl As IMFPresentationDescriptorVtbl Ptr
End Type

/' 第7部分：媒体源和扩展媒体源接口 '/

/' IMFMediaSource 接口 '/
Type IMFMediaSourceVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFMediaSource Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFMediaSource Ptr) As ULong
    Release As Function(ByVal This As IMFMediaSource Ptr) As ULong
    
    ' IMFMediaEventGenerator 方法
    GetEvent As Function(ByVal This As IMFMediaSource Ptr, ByVal dwFlags As DWORD, ByVal ppEvent As IMFMediaEvent Ptr Ptr) As HRESULT
    BeginGetEvent As Function(ByVal This As IMFMediaSource Ptr, ByVal pCallback As IMFAsyncCallback Ptr, ByVal punkState As IUnknown Ptr) As HRESULT
    EndGetEvent As Function(ByVal This As IMFMediaSource Ptr, ByVal pResult As IMFAsyncResult Ptr, ByVal ppEvent As IMFMediaEvent Ptr Ptr) As HRESULT
    QueueEvent As Function(ByVal This As IMFMediaSource Ptr, ByVal met As MediaEventType, ByVal guidExtendedType As REFGUID, ByVal hrStatus As HRESULT, ByVal pvValue As Const PROPVARIANT Ptr) As HRESULT
    
    ' IMFMediaSource 方法
    GetCharacteristics As Function(ByVal This As IMFMediaSource Ptr, ByVal pdwCharacteristics As DWORD Ptr) As HRESULT
    CreatePresentationDescriptor As Function(ByVal This As IMFMediaSource Ptr, ByVal ppPresentationDescriptor As IMFPresentationDescriptor Ptr Ptr) As HRESULT
    Start As Function(ByVal This As IMFMediaSource Ptr, ByVal pPresentationDescriptor As IMFPresentationDescriptor Ptr, ByVal pguidTimeFormat As Const GUID Ptr, ByVal pvarStartPosition As Const PROPVARIANT Ptr) As HRESULT
    Stop As Function(ByVal This As IMFMediaSource Ptr) As HRESULT
    Pause As Function(ByVal This As IMFMediaSource Ptr) As HRESULT
    Shutdown As Function(ByVal This As IMFMediaSource Ptr) As HRESULT
End Type

Type IMFMediaSource
    lpVtbl As IMFMediaSourceVtbl Ptr
End Type

#if (WINVER >= _WIN32_WINNT_WIN8)

/' IMFMediaSourceEx 接口 '/
Type IMFMediaSourceExVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFMediaSourceEx Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFMediaSourceEx Ptr) As ULong
    Release As Function(ByVal This As IMFMediaSourceEx Ptr) As ULong
    
    ' IMFMediaEventGenerator 方法
    GetEvent As Function(ByVal This As IMFMediaSourceEx Ptr, ByVal dwFlags As DWORD, ByVal ppEvent As IMFMediaEvent Ptr Ptr) As HRESULT
    BeginGetEvent As Function(ByVal This As IMFMediaSourceEx Ptr, ByVal pCallback As IMFAsyncCallback Ptr, ByVal punkState As IUnknown Ptr) As HRESULT
    EndGetEvent As Function(ByVal This As IMFMediaSourceEx Ptr, ByVal pResult As IMFAsyncResult Ptr, ByVal ppEvent As IMFMediaEvent Ptr Ptr) As HRESULT
    QueueEvent As Function(ByVal This As IMFMediaSourceEx Ptr, ByVal met As MediaEventType, ByVal guidExtendedType As REFGUID, ByVal hrStatus As HRESULT, ByVal pvValue As Const PROPVARIANT Ptr) As HRESULT
    
    ' IMFMediaSource 方法
    GetCharacteristics As Function(ByVal This As IMFMediaSourceEx Ptr, ByVal pdwCharacteristics As DWORD Ptr) As HRESULT
    CreatePresentationDescriptor As Function(ByVal This As IMFMediaSourceEx Ptr, ByVal ppPresentationDescriptor As IMFPresentationDescriptor Ptr Ptr) As HRESULT
    Start As Function(ByVal This As IMFMediaSourceEx Ptr, ByVal pPresentationDescriptor As IMFPresentationDescriptor Ptr, ByVal pguidTimeFormat As Const GUID Ptr, ByVal pvarStartPosition As Const PROPVARIANT Ptr) As HRESULT
    Stop As Function(ByVal This As IMFMediaSourceEx Ptr) As HRESULT
    Pause As Function(ByVal This As IMFMediaSourceEx Ptr) As HRESULT
    Shutdown As Function(ByVal This As IMFMediaSourceEx Ptr) As HRESULT
    
    ' IMFMediaSourceEx 方法
    GetSourceAttributes As Function(ByVal This As IMFMediaSourceEx Ptr, ByVal ppAttributes As IMFAttributes Ptr Ptr) As HRESULT
    GetStreamAttributes As Function(ByVal This As IMFMediaSourceEx Ptr, ByVal dwStreamIdentifier As DWORD, ByVal ppAttributes As IMFAttributes Ptr Ptr) As HRESULT
    SetD3DManager As Function(ByVal This As IMFMediaSourceEx Ptr, ByVal pManager As IUnknown Ptr) As HRESULT
End Type

Type IMFMediaSourceEx
    lpVtbl As IMFMediaSourceExVtbl Ptr
End Type

#endif

/' 第8部分：缓冲和时钟状态接口 '/

/' IMFByteStreamBuffering 接口 '/
Type IMFByteStreamBufferingVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFByteStreamBuffering Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFByteStreamBuffering Ptr) As ULong
    Release As Function(ByVal This As IMFByteStreamBuffering Ptr) As ULong
    
    ' IMFByteStreamBuffering 方法
    SetBufferingParams As Function(ByVal This As IMFByteStreamBuffering Ptr, ByVal pParams As MFBYTESTREAM_BUFFERING_PARAMS Ptr) As HRESULT
    EnableBuffering As Function(ByVal This As IMFByteStreamBuffering Ptr, ByVal fEnable As WINBOOL) As HRESULT
    StopBuffering As Function(ByVal This As IMFByteStreamBuffering Ptr) As HRESULT
End Type

Type IMFByteStreamBuffering
    lpVtbl As IMFByteStreamBufferingVtbl Ptr
End Type

/' IMFClockStateSink 接口 '/
Type IMFClockStateSinkVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFClockStateSink Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFClockStateSink Ptr) As ULong
    Release As Function(ByVal This As IMFClockStateSink Ptr) As ULong
    
    ' IMFClockStateSink 方法
    OnClockStart As Function(ByVal This As IMFClockStateSink Ptr, ByVal hnsSystemTime As MFTIME, ByVal llClockStartOffset As LONGLONG) As HRESULT
    OnClockStop As Function(ByVal This As IMFClockStateSink Ptr, ByVal hnsSystemTime As MFTIME) As HRESULT
    OnClockPause As Function(ByVal This As IMFClockStateSink Ptr, ByVal hnsSystemTime As MFTIME) As HRESULT
    OnClockRestart As Function(ByVal This As IMFClockStateSink Ptr, ByVal hnsSystemTime As MFTIME) As HRESULT
    OnClockSetRate As Function(ByVal This As IMFClockStateSink Ptr, ByVal hnsSystemTime As MFTIME, ByVal flRate As Single) As HRESULT
End Type

Type IMFClockStateSink
    lpVtbl As IMFClockStateSinkVtbl Ptr
End Type

/' IMFAudioStreamVolume 接口 '/
Type IMFAudioStreamVolumeVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFAudioStreamVolume Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFAudioStreamVolume Ptr) As ULong
    Release As Function(ByVal This As IMFAudioStreamVolume Ptr) As ULong
    
    ' IMFAudioStreamVolume 方法
    GetChannelCount As Function(ByVal This As IMFAudioStreamVolume Ptr, ByVal pdwCount As UINT32 Ptr) As HRESULT
    SetChannelVolume As Function(ByVal This As IMFAudioStreamVolume Ptr, ByVal dwIndex As UINT32, ByVal fLevel As Single) As HRESULT
    GetChannelVolume As Function(ByVal This As IMFAudioStreamVolume Ptr, ByVal dwIndex As UINT32, ByVal pfLevel As Single Ptr) As HRESULT
    SetAllVolumes As Function(ByVal This As IMFAudioStreamVolume Ptr, ByVal dwCount As UINT32, ByVal pfVolumes As Single Ptr) As HRESULT
    GetAllVolumes As Function(ByVal This As IMFAudioStreamVolume Ptr, ByVal dwCount As UINT32, ByVal pfVolumes As Single Ptr) As HRESULT
End Type

Type IMFAudioStreamVolume
    lpVtbl As IMFAudioStreamVolumeVtbl Ptr
End Type

/' 第9部分：媒体接收器和流接口 '/

/' IMFMediaSink 接口 '/
Type IMFMediaSinkVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFMediaSink Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFMediaSink Ptr) As ULong
    Release As Function(ByVal This As IMFMediaSink Ptr) As ULong
    
    ' IMFMediaSink 方法
    GetCharacteristics As Function(ByVal This As IMFMediaSink Ptr, ByVal pdwCharacteristics As DWORD Ptr) As HRESULT
    AddStreamSink As Function(ByVal This As IMFMediaSink Ptr, ByVal dwStreamSinkIdentifier As DWORD, ByVal pMediaType As IMFMediaType Ptr, ByVal ppStreamSink As IMFStreamSink Ptr Ptr) As HRESULT
    RemoveStreamSink As Function(ByVal This As IMFMediaSink Ptr, ByVal dwStreamSinkIdentifier As DWORD) As HRESULT
    GetStreamSinkCount As Function(ByVal This As IMFMediaSink Ptr, ByVal pcStreamSinkCount As DWORD Ptr) As HRESULT
    GetStreamSinkByIndex As Function(ByVal This As IMFMediaSink Ptr, ByVal dwIndex As DWORD, ByVal ppStreamSink As IMFStreamSink Ptr Ptr) As HRESULT
    GetStreamSinkById As Function(ByVal This As IMFMediaSink Ptr, ByVal dwStreamSinkIdentifier As DWORD, ByVal ppStreamSink As IMFStreamSink Ptr Ptr) As HRESULT
    SetPresentationClock As Function(ByVal This As IMFMediaSink Ptr, ByVal pPresentationClock As IMFPresentationClock Ptr) As HRESULT
    GetPresentationClock As Function(ByVal This As IMFMediaSink Ptr, ByVal ppPresentationClock As IMFPresentationClock Ptr Ptr) As HRESULT
    Shutdown As Function(ByVal This As IMFMediaSink Ptr) As HRESULT
End Type

Type IMFMediaSink
    lpVtbl As IMFMediaSinkVtbl Ptr
End Type

/' IMFFinalizableMediaSink 接口 '/
Type IMFFinalizableMediaSinkVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFFinalizableMediaSink Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFFinalizableMediaSink Ptr) As ULong
    Release As Function(ByVal This As IMFFinalizableMediaSink Ptr) As ULong
    
    ' IMFMediaSink 方法
    GetCharacteristics As Function(ByVal This As IMFFinalizableMediaSink Ptr, ByVal pdwCharacteristics As DWORD Ptr) As HRESULT
    AddStreamSink As Function(ByVal This As IMFFinalizableMediaSink Ptr, ByVal dwStreamSinkIdentifier As DWORD, ByVal pMediaType As IMFMediaType Ptr, ByVal ppStreamSink As IMFStreamSink Ptr Ptr) As HRESULT
    RemoveStreamSink As Function(ByVal This As IMFFinalizableMediaSink Ptr, ByVal dwStreamSinkIdentifier As DWORD) As HRESULT
    GetStreamSinkCount As Function(ByVal This As IMFFinalizableMediaSink Ptr, ByVal pcStreamSinkCount As DWORD Ptr) As HRESULT
    GetStreamSinkByIndex As Function(ByVal This As IMFFinalizableMediaSink Ptr, ByVal dwIndex As DWORD, ByVal ppStreamSink As IMFStreamSink Ptr Ptr) As HRESULT
    GetStreamSinkById As Function(ByVal This As IMFFinalizableMediaSink Ptr, ByVal dwStreamSinkIdentifier As DWORD, ByVal ppStreamSink As IMFStreamSink Ptr Ptr) As HRESULT
    SetPresentationClock As Function(ByVal This As IMFFinalizableMediaSink Ptr, ByVal pPresentationClock As IMFPresentationClock Ptr) As HRESULT
    GetPresentationClock As Function(ByVal This As IMFFinalizableMediaSink Ptr, ByVal ppPresentationClock As IMFPresentationClock Ptr Ptr) As HRESULT
    Shutdown As Function(ByVal This As IMFFinalizableMediaSink Ptr) As HRESULT
    
    ' IMFFinalizableMediaSink 方法
    BeginFinalize As Function(ByVal This As IMFFinalizableMediaSink Ptr, ByVal pCallback As IMFAsyncCallback Ptr, ByVal punkState As IUnknown Ptr) As HRESULT
    EndFinalize As Function(ByVal This As IMFFinalizableMediaSink Ptr, ByVal pResult As IMFAsyncResult Ptr) As HRESULT
End Type

Type IMFFinalizableMediaSink
    lpVtbl As IMFFinalizableMediaSinkVtbl Ptr
End Type

/' IMFMediaSinkPreroll 接口 '/
Type IMFMediaSinkPrerollVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFMediaSinkPreroll Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFMediaSinkPreroll Ptr) As ULong
    Release As Function(ByVal This As IMFMediaSinkPreroll Ptr) As ULong
    
    ' IMFMediaSinkPreroll 方法
    NotifyPreroll As Function(ByVal This As IMFMediaSinkPreroll Ptr, ByVal hnsUpcomingStartTime As MFTIME) As HRESULT
End Type

Type IMFMediaSinkPreroll
    lpVtbl As IMFMediaSinkPrerollVtbl Ptr
End Type

/' IMFMediaStream 接口 '/
Type IMFMediaStreamVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFMediaStream Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFMediaStream Ptr) As ULong
    Release As Function(ByVal This As IMFMediaStream Ptr) As ULong
    
    ' IMFMediaEventGenerator 方法
    GetEvent As Function(ByVal This As IMFMediaStream Ptr, ByVal dwFlags As DWORD, ByVal ppEvent As IMFMediaEvent Ptr Ptr) As HRESULT
    BeginGetEvent As Function(ByVal This As IMFMediaStream Ptr, ByVal pCallback As IMFAsyncCallback Ptr, ByVal punkState As IUnknown Ptr) As HRESULT
    EndGetEvent As Function(ByVal This As IMFMediaStream Ptr, ByVal pResult As IMFAsyncResult Ptr, ByVal ppEvent As IMFMediaEvent Ptr Ptr) As HRESULT
    QueueEvent As Function(ByVal This As IMFMediaStream Ptr, ByVal met As MediaEventType, ByVal guidExtendedType As REFGUID, ByVal hrStatus As HRESULT, ByVal pvValue As Const PROPVARIANT Ptr) As HRESULT
    
    ' IMFMediaStream 方法
    GetMediaSource As Function(ByVal This As IMFMediaStream Ptr, ByVal ppMediaSource As IMFMediaSource Ptr Ptr) As HRESULT
    GetStreamDescriptor As Function(ByVal This As IMFMediaStream Ptr, ByVal ppStreamDescriptor As IMFStreamDescriptor Ptr Ptr) As HRESULT
    RequestSample As Function(ByVal This As IMFMediaStream Ptr, ByVal pToken As IUnknown Ptr) As HRESULT
End Type

Type IMFMediaStream
    lpVtbl As IMFMediaStreamVtbl Ptr
End Type

/' 第10部分：元数据和时钟接口 '/

/' IMFMetadata 接口 '/
Type IMFMetadataVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFMetadata Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFMetadata Ptr) As ULong
    Release As Function(ByVal This As IMFMetadata Ptr) As ULong
    
    ' IMFMetadata 方法
    SetLanguage As Function(ByVal This As IMFMetadata Ptr, ByVal pwszRFC1766 As LPCWSTR) As HRESULT
    GetLanguage As Function(ByVal This As IMFMetadata Ptr, ByVal ppwszRFC1766 As LPWSTR Ptr) As HRESULT
    GetAllLanguages As Function(ByVal This As IMFMetadata Ptr, ByVal ppvLanguages As PROPVARIANT Ptr) As HRESULT
    SetProperty As Function(ByVal This As IMFMetadata Ptr, ByVal pwszName As LPCWSTR, ByVal ppvValue As Const PROPVARIANT Ptr) As HRESULT
    GetProperty As Function(ByVal This As IMFMetadata Ptr, ByVal pwszName As LPCWSTR, ByVal ppvValue As PROPVARIANT Ptr) As HRESULT
    DeleteProperty As Function(ByVal This As IMFMetadata Ptr, ByVal pwszName As LPCWSTR) As HRESULT
    GetAllPropertyNames As Function(ByVal This As IMFMetadata Ptr, ByVal ppvNames As PROPVARIANT Ptr) As HRESULT
End Type

Type IMFMetadata
    lpVtbl As IMFMetadataVtbl Ptr
End Type

/' IMFMetadataProvider 接口 '/
Type IMFMetadataProviderVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFMetadataProvider Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFMetadataProvider Ptr) As ULong
    Release As Function(ByVal This As IMFMetadataProvider Ptr) As ULong
    
    ' IMFMetadataProvider 方法
    GetMFMetadata As Function(ByVal This As IMFMetadataProvider Ptr, ByVal pPresentationDescriptor As IMFPresentationDescriptor Ptr, ByVal dwStreamIdentifier As DWORD, ByVal dwFlags As DWORD, ByVal ppMFMetadata As IMFMetadata Ptr Ptr) As HRESULT
End Type

Type IMFMetadataProvider
    lpVtbl As IMFMetadataProviderVtbl Ptr
End Type

/' IMFPresentationTimeSource 接口 '/
Type IMFPresentationTimeSourceVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFPresentationTimeSource Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFPresentationTimeSource Ptr) As ULong
    Release As Function(ByVal This As IMFPresentationTimeSource Ptr) As ULong
    
    ' IMFClock 方法
    GetClockCharacteristics As Function(ByVal This As IMFPresentationTimeSource Ptr, ByVal pdwCharacteristics As DWORD Ptr) As HRESULT
    GetCorrelatedTime As Function(ByVal This As IMFPresentationTimeSource Ptr, ByVal dwReserved As DWORD, ByVal pllClockTime As LONGLONG Ptr, ByVal phnsSystemTime As MFTIME Ptr) As HRESULT
    GetContinuityKey As Function(ByVal This As IMFPresentationTimeSource Ptr, ByVal pdwContinuityKey As DWORD Ptr) As HRESULT
    GetState As Function(ByVal This As IMFPresentationTimeSource Ptr, ByVal dwReserved As DWORD, ByVal peClockState As MF_CLOCK_STATE Ptr) As HRESULT
    GetProperties As Function(ByVal This As IMFPresentationTimeSource Ptr, ByVal pClockProperties As MFCLOCK_PROPERTIES Ptr) As HRESULT
    
    ' IMFPresentationTimeSource 方法
    GetUnderlyingClock As Function(ByVal This As IMFPresentationTimeSource Ptr, ByVal ppClock As IMFClock Ptr Ptr) As HRESULT
End Type

Type IMFPresentationTimeSource
    lpVtbl As IMFPresentationTimeSourceVtbl Ptr
End Type

/' IMFPresentationClock 接口 '/
Type IMFPresentationClockVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFPresentationClock Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFPresentationClock Ptr) As ULong
    Release As Function(ByVal This As IMFPresentationClock Ptr) As ULong
    
    ' IMFClock 方法
    GetClockCharacteristics As Function(ByVal This As IMFPresentationClock Ptr, ByVal pdwCharacteristics As DWORD Ptr) As HRESULT
    GetCorrelatedTime As Function(ByVal This As IMFPresentationClock Ptr, ByVal dwReserved As DWORD, ByVal pllClockTime As LONGLONG Ptr, ByVal phnsSystemTime As MFTIME Ptr) As HRESULT
    GetContinuityKey As Function(ByVal This As IMFPresentationClock Ptr, ByVal pdwContinuityKey As DWORD Ptr) As HRESULT
    GetState As Function(ByVal This As IMFPresentationClock Ptr, ByVal dwReserved As DWORD, ByVal peClockState As MF_CLOCK_STATE Ptr) As HRESULT
    GetProperties As Function(ByVal This As IMFPresentationClock Ptr, ByVal pClockProperties As MFCLOCK_PROPERTIES Ptr) As HRESULT
    
    ' IMFPresentationClock 方法
    SetTimeSource As Function(ByVal This As IMFPresentationClock Ptr, ByVal pTimeSource As IMFPresentationTimeSource Ptr) As HRESULT
    GetTimeSource As Function(ByVal This As IMFPresentationClock Ptr, ByVal ppTimeSource As IMFPresentationTimeSource Ptr Ptr) As HRESULT
    GetTime As Function(ByVal This As IMFPresentationClock Ptr, ByVal phnsClockTime As MFTIME Ptr) As HRESULT
    AddClockStateSink As Function(ByVal This As IMFPresentationClock Ptr, ByVal pStateSink As IMFClockStateSink Ptr) As HRESULT
    RemoveClockStateSink As Function(ByVal This As IMFPresentationClock Ptr, ByVal pStateSink As IMFClockStateSink Ptr) As HRESULT
    Start As Function(ByVal This As IMFPresentationClock Ptr, ByVal llClockStartOffset As LONGLONG) As HRESULT
    Stop As Function(ByVal This As IMFPresentationClock Ptr) As HRESULT
    Pause As Function(ByVal This As IMFPresentationClock Ptr) As HRESULT
End Type

Type IMFPresentationClock
    lpVtbl As IMFPresentationClockVtbl Ptr
End Type

/' 更多枚举和常量 '/
Enum MF_TOPONODE_DRAIN_MODE
    MF_TOPONODE_DRAIN_DEFAULT = 0
    MF_TOPONODE_DRAIN_ALWAYS = 1
    MF_TOPONODE_DRAIN_NEVER = 2
End Enum

Enum MF_TOPONODE_FLUSH_MODE
    MF_TOPONODE_FLUSH_ALWAYS = 0
    MF_TOPONODE_FLUSH_SEEK = 1
    MF_TOPONODE_FLUSH_NEVER = 2
End Enum

Enum MF_URL_TRUST_STATUS
    MF_LICENSE_URL_UNTRUSTED = 0
    MF_LICENSE_URL_TRUSTED = 1
    MF_LICENSE_URL_TAMPERED = 2
End Enum

Enum MFNETSOURCE_CACHE_STATE
    MFNETSOURCE_CACHE_UNAVAILABLE = 0
    MFNETSOURCE_CACHE_ACTIVE_WRITING = 1
    MFNETSOURCE_CACHE_ACTIVE_COMPLETE = 2
End Enum

Enum MFNET_PROXYSETTINGS
    MFNET_PROXYSETTING_NONE = 0
    MFNET_PROXYSETTING_MANUAL = 1
    MFNET_PROXYSETTING_AUTO = 2
    MFNET_PROXYSETTING_BROWSER = 3
End Enum

Enum MFNetAuthenticationFlags
    MFNET_AUTHENTICATION_PROXY = &h1
    MFNET_AUTHENTICATION_CLEAR_TEXT = &h2
    MFNET_AUTHENTICATION_LOGGED_ON_USER = &h4
End Enum

Enum MFNetCredentialOptions
    MFNET_CREDENTIAL_SAVE = &h1
    MFNET_CREDENTIAL_DONT_CACHE = &h2
    MFNET_CREDENTIAL_ALLOW_CLEAR_TEXT = &h4
End Enum

Enum MFNetCredentialRequirements
    REQUIRE_PROMPT = &h1
    REQUIRE_SAVE_SELECTED = &h2
End Enum

Enum MFSequencerTopologyFlags
    SequencerTopologyFlags_Last = &h1
End Enum

Enum MFSHUTDOWN_STATUS
    MFSHUTDOWN_INITIATED = 0
    MFSHUTDOWN_COMPLETED = 1
End Enum

/' 第11部分：流接收器和速率控制接口 '/

/' IMFStreamSink 接口 '/
Type IMFStreamSinkVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFStreamSink Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFStreamSink Ptr) As ULong
    Release As Function(ByVal This As IMFStreamSink Ptr) As ULong
    
    ' IMFMediaEventGenerator 方法
    GetEvent As Function(ByVal This As IMFStreamSink Ptr, ByVal dwFlags As DWORD, ByVal ppEvent As IMFMediaEvent Ptr Ptr) As HRESULT
    BeginGetEvent As Function(ByVal This As IMFStreamSink Ptr, ByVal pCallback As IMFAsyncCallback Ptr, ByVal punkState As IUnknown Ptr) As HRESULT
    EndGetEvent As Function(ByVal This As IMFStreamSink Ptr, ByVal pResult As IMFAsyncResult Ptr, ByVal ppEvent As IMFMediaEvent Ptr Ptr) As HRESULT
    QueueEvent As Function(ByVal This As IMFStreamSink Ptr, ByVal met As MediaEventType, ByVal guidExtendedType As REFGUID, ByVal hrStatus As HRESULT, ByVal pvValue As Const PROPVARIANT Ptr) As HRESULT
    
    ' IMFStreamSink 方法
    GetMediaSink As Function(ByVal This As IMFStreamSink Ptr, ByVal ppMediaSink As IMFMediaSink Ptr Ptr) As HRESULT
    GetIdentifier As Function(ByVal This As IMFStreamSink Ptr, ByVal pdwIdentifier As DWORD Ptr) As HRESULT
    GetMediaTypeHandler As Function(ByVal This As IMFStreamSink Ptr, ByVal ppHandler As IMFMediaTypeHandler Ptr Ptr) As HRESULT
    ProcessSample As Function(ByVal This As IMFStreamSink Ptr, ByVal pSample As IMFSample Ptr) As HRESULT
    PlaceMarker As Function(ByVal This As IMFStreamSink Ptr, ByVal eMarkerType As MFSTREAMSINK_MARKER_TYPE, ByVal pvarMarkerValue As Const PROPVARIANT Ptr, ByVal pvarContextValue As Const PROPVARIANT Ptr) As HRESULT
    Flush As Function(ByVal This As IMFStreamSink Ptr) As HRESULT
End Type

Type IMFStreamSink
    lpVtbl As IMFStreamSinkVtbl Ptr
End Type

/' IMFRateControl 接口 '/
Type IMFRateControlVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFRateControl Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFRateControl Ptr) As ULong
    Release As Function(ByVal This As IMFRateControl Ptr) As ULong
    
    ' IMFRateControl 方法
    SetRate As Function(ByVal This As IMFRateControl Ptr, ByVal fThin As WINBOOL, ByVal flRate As Single) As HRESULT
    GetRate As Function(ByVal This As IMFRateControl Ptr, ByVal pfThin As WINBOOL Ptr, ByVal pflRate As Single Ptr) As HRESULT
End Type

Type IMFRateControl
    lpVtbl As IMFRateControlVtbl Ptr
End Type

/' IMFRateSupport 接口 '/
Type IMFRateSupportVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFRateSupport Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFRateSupport Ptr) As ULong
    Release As Function(ByVal This As IMFRateSupport Ptr) As ULong
    
    ' IMFRateSupport 方法
    GetSlowestRate As Function(ByVal This As IMFRateSupport Ptr, ByVal eDirection As MFRATE_DIRECTION, ByVal fThin As WINBOOL, ByVal pflRate As Single Ptr) As HRESULT
    GetFastestRate As Function(ByVal This As IMFRateSupport Ptr, ByVal eDirection As MFRATE_DIRECTION, ByVal fThin As WINBOOL, ByVal pflRate As Single Ptr) As HRESULT
    IsRateSupported As Function(ByVal This As IMFRateSupport Ptr, ByVal fThin As WINBOOL, ByVal flRate As Single, ByVal pflNearestSupportedRate As Single Ptr) As HRESULT
End Type

Type IMFRateSupport
    lpVtbl As IMFRateSupportVtbl Ptr
End Type

/' IMFSampleGrabberSinkCallback 接口 '/
Type IMFSampleGrabberSinkCallbackVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFSampleGrabberSinkCallback Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFSampleGrabberSinkCallback Ptr) As ULong
    Release As Function(ByVal This As IMFSampleGrabberSinkCallback Ptr) As ULong
    
    ' IMFClockStateSink 方法
    OnClockStart As Function(ByVal This As IMFSampleGrabberSinkCallback Ptr, ByVal hnsSystemTime As MFTIME, ByVal llClockStartOffset As LONGLONG) As HRESULT
    OnClockStop As Function(ByVal This As IMFSampleGrabberSinkCallback Ptr, ByVal hnsSystemTime As MFTIME) As HRESULT
    OnClockPause As Function(ByVal This As IMFSampleGrabberSinkCallback Ptr, ByVal hnsSystemTime As MFTIME) As HRESULT
    OnClockRestart As Function(ByVal This As IMFSampleGrabberSinkCallback Ptr, ByVal hnsSystemTime As MFTIME) As HRESULT
    OnClockSetRate As Function(ByVal This As IMFSampleGrabberSinkCallback Ptr, ByVal hnsSystemTime As MFTIME, ByVal flRate As Single) As HRESULT
    
    ' IMFSampleGrabberSinkCallback 方法
    OnSetPresentationClock As Function(ByVal This As IMFSampleGrabberSinkCallback Ptr, ByVal pPresentationClock As IMFPresentationClock Ptr) As HRESULT
    OnProcessSample As Function(ByVal This As IMFSampleGrabberSinkCallback Ptr, ByVal guidMajorMediaType As REFGUID, ByVal dwSampleFlags As DWORD, ByVal llSampleTime As LONGLONG, ByVal llSampleDuration As LONGLONG, ByVal pSampleBuffer As Byte Ptr, ByVal dwSampleSize As DWORD) As HRESULT
    OnShutdown As Function(ByVal This As IMFSampleGrabberSinkCallback Ptr) As HRESULT
End Type

Type IMFSampleGrabberSinkCallback
    lpVtbl As IMFSampleGrabberSinkCallbackVtbl Ptr
End Type

/' 第12部分：关闭和简单音频接口 '/

/' IMFShutdown 接口 '/
Type IMFShutdownVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFShutdown Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFShutdown Ptr) As ULong
    Release As Function(ByVal This As IMFShutdown Ptr) As ULong
    
    ' IMFShutdown 方法
    Shutdown As Function(ByVal This As IMFShutdown Ptr) As HRESULT
    GetShutdownStatus As Function(ByVal This As IMFShutdown Ptr, ByVal pStatus As MFSHUTDOWN_STATUS Ptr) As HRESULT
End Type

Type IMFShutdown
    lpVtbl As IMFShutdownVtbl Ptr
End Type

/' IMFSimpleAudioVolume 接口 '/
Type IMFSimpleAudioVolumeVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFSimpleAudioVolume Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFSimpleAudioVolume Ptr) As ULong
    Release As Function(ByVal This As IMFSimpleAudioVolume Ptr) As ULong
    
    ' IMFSimpleAudioVolume 方法
    SetMasterVolume As Function(ByVal This As IMFSimpleAudioVolume Ptr, ByVal fLevel As Single) As HRESULT
    GetMasterVolume As Function(ByVal This As IMFSimpleAudioVolume Ptr, ByVal pfLevel As Single Ptr) As HRESULT
    SetMute As Function(ByVal This As IMFSimpleAudioVolume Ptr, ByVal bMute As WINBOOL) As HRESULT
    GetMute As Function(ByVal This As IMFSimpleAudioVolume Ptr, ByVal pbMute As WINBOOL Ptr) As HRESULT
End Type

Type IMFSimpleAudioVolume
    lpVtbl As IMFSimpleAudioVolumeVtbl Ptr
End Type

/' IMFSourceResolver 接口 '/
Type IMFSourceResolverVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFSourceResolver Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFSourceResolver Ptr) As ULong
    Release As Function(ByVal This As IMFSourceResolver Ptr) As ULong
    
    ' IMFSourceResolver 方法
    CreateObjectFromURL As Function(ByVal This As IMFSourceResolver Ptr, ByVal pwszURL As LPCWSTR, ByVal dwFlags As DWORD, ByVal pProps As IPropertyStore Ptr, ByVal pObjectType As MF_OBJECT_TYPE Ptr, ByVal ppObject As IUnknown Ptr Ptr) As HRESULT
    CreateObjectFromByteStream As Function(ByVal This As IMFSourceResolver Ptr, ByVal pByteStream As IMFByteStream Ptr, ByVal pwszURL As LPCWSTR, ByVal dwFlags As DWORD, ByVal pProps As IPropertyStore Ptr, ByVal pObjectType As MF_OBJECT_TYPE Ptr, ByVal ppObject As IUnknown Ptr Ptr) As HRESULT
    BeginCreateObjectFromURL As Function(ByVal This As IMFSourceResolver Ptr, ByVal pwszURL As LPCWSTR, ByVal dwFlags As DWORD, ByVal pProps As IPropertyStore Ptr, ByVal ppIUnknownCancelCookie As IUnknown Ptr Ptr, ByVal pCallback As IMFAsyncCallback Ptr, ByVal punkState As IUnknown Ptr) As HRESULT
    EndCreateObjectFromURL As Function(ByVal This As IMFSourceResolver Ptr, ByVal pResult As IMFAsyncResult Ptr, ByVal pObjectType As MF_OBJECT_TYPE Ptr, ByVal ppObject As IUnknown Ptr Ptr) As HRESULT
    BeginCreateObjectFromByteStream As Function(ByVal This As IMFSourceResolver Ptr, ByVal pByteStream As IMFByteStream Ptr, ByVal pwszURL As LPCWSTR, ByVal dwFlags As DWORD, ByVal pProps As IPropertyStore Ptr, ByVal ppIUnknownCancelCookie As IUnknown Ptr Ptr, ByVal pCallback As IMFAsyncCallback Ptr, ByVal punkState As IUnknown Ptr) As HRESULT
    EndCreateObjectFromByteStream As Function(ByVal This As IMFSourceResolver Ptr, ByVal pResult As IMFAsyncResult Ptr, ByVal pObjectType As MF_OBJECT_TYPE Ptr, ByVal ppObject As IUnknown Ptr Ptr) As HRESULT
    CancelObjectCreation As Function(ByVal This As IMFSourceResolver Ptr, ByVal pIUnknownCancelCookie As IUnknown Ptr) As HRESULT
End Type

Type IMFSourceResolver
    lpVtbl As IMFSourceResolverVtbl Ptr
End Type

/' 第13部分：定时器和拓扑加载器接口 '/

/' IMFTimer 接口 '/
Type IMFTimerVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFTimer Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFTimer Ptr) As ULONG
    Release As Function(ByVal This As IMFTimer Ptr) As ULONG
    
    ' IMFTimer 方法
    SetTimer As Function(ByVal This As IMFTimer Ptr, ByVal dwFlags As MFTIMER_FLAGS, ByVal llClockTime As LONGLONG, ByVal pCallback As IMFAsyncCallback Ptr, ByVal punkState As IUnknown Ptr, ByVal ppunkKey As IUnknown Ptr Ptr) As HRESULT
    CancelTimer As Function(ByVal This As IMFTimer Ptr, ByVal punkKey As IUnknown Ptr) As HRESULT
End Type

Type IMFTimer
    lpVtbl As IMFTimerVtbl Ptr
End Type

/' IMFTopoLoader 接口 '/
Type IMFTopoLoaderVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFTopoLoader Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFTopoLoader Ptr) As ULONG
    Release As Function(ByVal This As IMFTopoLoader Ptr) As ULONG
    
    ' IMFTopoLoader 方法
    Load As Function(ByVal This As IMFTopoLoader Ptr, ByVal pInputTopo As IMFTopology Ptr, ByVal ppOutputTopo As IMFTopology Ptr Ptr, ByVal pCurrentTopo As IMFTopology Ptr) As HRESULT
End Type

Type IMFTopoLoader
    lpVtbl As IMFTopoLoaderVtbl Ptr
End Type

/' IMFVideoSampleAllocator 接口 '/
Type IMFVideoSampleAllocatorVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFVideoSampleAllocator Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFVideoSampleAllocator Ptr) As ULONG
    Release As Function(ByVal This As IMFVideoSampleAllocator Ptr) As ULONG
    
    ' IMFVideoSampleAllocator 方法
    SetDirectXManager As Function(ByVal This As IMFVideoSampleAllocator Ptr, ByVal pManager As IUnknown Ptr) As HRESULT
    UninitializeSampleAllocator As Function(ByVal This As IMFVideoSampleAllocator Ptr) As HRESULT
    InitializeSampleAllocator As Function(ByVal This As IMFVideoSampleAllocator Ptr, ByVal cRequestedFrames As DWORD, ByVal pMediaType As IMFMediaType Ptr) As HRESULT
    AllocateSample As Function(ByVal This As IMFVideoSampleAllocator Ptr, ByVal ppSample As IMFSample Ptr Ptr) As HRESULT
End Type

Type IMFVideoSampleAllocator
    lpVtbl As IMFVideoSampleAllocatorVtbl Ptr
End Type

/' IMFVideoSampleAllocatorNotify 接口 '/
Type IMFVideoSampleAllocatorNotifyVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFVideoSampleAllocatorNotify Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFVideoSampleAllocatorNotify Ptr) As ULONG
    Release As Function(ByVal This As IMFVideoSampleAllocatorNotify Ptr) As ULONG
    
    ' IMFVideoSampleAllocatorNotify 方法
    NotifyRelease As Function(ByVal This As IMFVideoSampleAllocatorNotify Ptr) As HRESULT
End Type

Type IMFVideoSampleAllocatorNotify
    lpVtbl As IMFVideoSampleAllocatorNotifyVtbl Ptr
End Type

#if (WINVER >= _WIN32_WINNT_WIN8)

/' IMFVideoSampleAllocatorNotifyEx 接口 '/
Type IMFVideoSampleAllocatorNotifyExVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFVideoSampleAllocatorNotifyEx Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFVideoSampleAllocatorNotifyEx Ptr) As ULONG
    Release As Function(ByVal This As IMFVideoSampleAllocatorNotifyEx Ptr) As ULONG
    
    ' IMFVideoSampleAllocatorNotify 方法
    NotifyRelease As Function(ByVal This As IMFVideoSampleAllocatorNotifyEx Ptr) As HRESULT
    
    ' IMFVideoSampleAllocatorNotifyEx 方法
    NotifyPrune As Function(ByVal This As IMFVideoSampleAllocatorNotifyEx Ptr, ByVal pSample As IMFSample Ptr) As HRESULT
End Type

Type IMFVideoSampleAllocatorNotifyEx
    lpVtbl As IMFVideoSampleAllocatorNotifyExVtbl Ptr
End Type

/' IMFVideoSampleAllocatorCallback 接口 '/
Type IMFVideoSampleAllocatorCallbackVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFVideoSampleAllocatorCallback Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFVideoSampleAllocatorCallback Ptr) As ULong
    Release As Function(ByVal This As IMFVideoSampleAllocatorCallback Ptr) As ULong
    
    ' IMFVideoSampleAllocatorCallback 方法
    SetCallback As Function(ByVal This As IMFVideoSampleAllocatorCallback Ptr, ByVal pNotify As IMFVideoSampleAllocatorNotify Ptr) As HRESULT
    GetFreeSampleCount As Function(ByVal This As IMFVideoSampleAllocatorCallback Ptr, ByVal plSamples As Long Ptr) As HRESULT
End Type

Type IMFVideoSampleAllocatorCallback
    lpVtbl As IMFVideoSampleAllocatorCallbackVtbl Ptr
End Type

/' IMFVideoSampleAllocatorEx 接口 '/
Type IMFVideoSampleAllocatorExVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFVideoSampleAllocatorEx Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFVideoSampleAllocatorEx Ptr) As ULong
    Release As Function(ByVal This As IMFVideoSampleAllocatorEx Ptr) As ULong
    
    ' IMFVideoSampleAllocator 方法
    SetDirectXManager As Function(ByVal This As IMFVideoSampleAllocatorEx Ptr, ByVal pManager As IUnknown Ptr) As HRESULT
    UninitializeSampleAllocator As Function(ByVal This As IMFVideoSampleAllocatorEx Ptr) As HRESULT
    InitializeSampleAllocator As Function(ByVal This As IMFVideoSampleAllocatorEx Ptr, ByVal cRequestedFrames As DWORD, ByVal pMediaType As IMFMediaType Ptr) As HRESULT
    AllocateSample As Function(ByVal This As IMFVideoSampleAllocatorEx Ptr, ByVal ppSample As IMFSample Ptr Ptr) As HRESULT
    
    ' IMFVideoSampleAllocatorEx 方法
    InitializeSampleAllocatorEx As Function(ByVal This As IMFVideoSampleAllocatorEx Ptr, ByVal cInitialSamples As DWORD, ByVal cMaximumSamples As DWORD, ByVal pAttributes As IMFAttributes Ptr, ByVal pMediaType As IMFMediaType Ptr) As HRESULT
End Type

Type IMFVideoSampleAllocatorEx
    lpVtbl As IMFVideoSampleAllocatorExVtbl Ptr
End Type

#endif

/' 第14部分：视频处理器和渲染器接口 '/

/' IMFVideoProcessorControl 接口 '/
Type IMFVideoProcessorControlVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFVideoProcessorControl Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFVideoProcessorControl Ptr) As ULong
    Release As Function(ByVal This As IMFVideoProcessorControl Ptr) As ULong
    
    ' IMFVideoProcessorControl 方法
    SetBorderColor As Function(ByVal This As IMFVideoProcessorControl Ptr, ByVal pBorderColor As MFARGB Ptr) As HRESULT
    SetSourceRectangle As Function(ByVal This As IMFVideoProcessorControl Ptr, ByVal pSrcRect As RECT Ptr) As HRESULT
    SetDestinationRectangle As Function(ByVal This As IMFVideoProcessorControl Ptr, ByVal pDstRect As RECT Ptr) As HRESULT
    SetMirror As Function(ByVal This As IMFVideoProcessorControl Ptr, ByVal eMirror As MF_VIDEO_PROCESSOR_MIRROR) As HRESULT
    SetRotation As Function(ByVal This As IMFVideoProcessorControl Ptr, ByVal eRotation As MF_VIDEO_PROCESSOR_ROTATION) As HRESULT
    SetConstrictionSize As Function(ByVal This As IMFVideoProcessorControl Ptr, ByVal pConstrictionSize As SIZE Ptr) As HRESULT
End Type

Type IMFVideoProcessorControl
    lpVtbl As IMFVideoProcessorControlVtbl Ptr
End Type

#if (WINVER >= _WIN32_WINNT_WIN8)

/' IMFVideoProcessorControl2 接口 '/
Type IMFVideoProcessorControl2Vtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFVideoProcessorControl2 Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFVideoProcessorControl2 Ptr) As ULong
    Release As Function(ByVal This As IMFVideoProcessorControl2 Ptr) As ULong
    
    ' IMFVideoProcessorControl 方法
    SetBorderColor As Function(ByVal This As IMFVideoProcessorControl2 Ptr, ByVal pBorderColor As MFARGB Ptr) As HRESULT
    SetSourceRectangle As Function(ByVal This As IMFVideoProcessorControl2 Ptr, ByVal pSrcRect As RECT Ptr) As HRESULT
    SetDestinationRectangle As Function(ByVal This As IMFVideoProcessorControl2 Ptr, ByVal pDstRect As RECT Ptr) As HRESULT
    SetMirror As Function(ByVal This As IMFVideoProcessorControl2 Ptr, ByVal eMirror As MF_VIDEO_PROCESSOR_MIRROR) As HRESULT
    SetRotation As Function(ByVal This As IMFVideoProcessorControl2 Ptr, ByVal eRotation As MF_VIDEO_PROCESSOR_ROTATION) As HRESULT
    SetConstrictionSize As Function(ByVal This As IMFVideoProcessorControl2 Ptr, ByVal pConstrictionSize As SIZE Ptr) As HRESULT
    
    ' IMFVideoProcessorControl2 方法
    SetRotationOverride As Function(ByVal This As IMFVideoProcessorControl2 Ptr, ByVal unRotation As UINT32) As HRESULT
    EnableHardwareEffects As Function(ByVal This As IMFVideoProcessorControl2 Ptr, ByVal fEnabled As WINBOOL) As HRESULT
    GetHardwareEffectsState As Function(ByVal This As IMFVideoProcessorControl2 Ptr, ByVal pfEnabled As WINBOOL Ptr) As HRESULT
End Type

Type IMFVideoProcessorControl2
    lpVtbl As IMFVideoProcessorControl2Vtbl Ptr
End Type

/' IMFVideoProcessorControl3 接口 '/
Type IMFVideoProcessorControl3Vtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFVideoProcessorControl3 Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFVideoProcessorControl3 Ptr) As ULong
    Release As Function(ByVal This As IMFVideoProcessorControl3 Ptr) As ULong
    
    ' IMFVideoProcessorControl 方法
    SetBorderColor As Function(ByVal This As IMFVideoProcessorControl3 Ptr, ByVal pBorderColor As MFARGB Ptr) As HRESULT
    SetSourceRectangle As Function(ByVal This As IMFVideoProcessorControl3 Ptr, ByVal pSrcRect As RECT Ptr) As HRESULT
    SetDestinationRectangle As Function(ByVal This As IMFVideoProcessorControl3 Ptr, ByVal pDstRect As RECT Ptr) As HRESULT
    SetMirror As Function(ByVal This As IMFVideoProcessorControl3 Ptr, ByVal eMirror As MF_VIDEO_PROCESSOR_MIRROR) As HRESULT
    SetRotation As Function(ByVal This As IMFVideoProcessorControl3 Ptr, ByVal eRotation As MF_VIDEO_PROCESSOR_ROTATION) As HRESULT
    SetConstrictionSize As Function(ByVal This As IMFVideoProcessorControl3 Ptr, ByVal pConstrictionSize As SIZE Ptr) As HRESULT
    
    ' IMFVideoProcessorControl2 方法
    SetRotationOverride As Function(ByVal This As IMFVideoProcessorControl3 Ptr, ByVal unRotation As UINT32) As HRESULT
    EnableHardwareEffects As Function(ByVal This As IMFVideoProcessorControl3 Ptr, ByVal fEnabled As WINBOOL) As HRESULT
    GetHardwareEffectsState As Function(ByVal This As IMFVideoProcessorControl3 Ptr, ByVal pfEnabled As WINBOOL Ptr) As HRESULT
    
    ' IMFVideoProcessorControl3 方法
    GetNaturalOutputType As Function(ByVal This As IMFVideoProcessorControl3 Ptr, ByVal ppType As IMFMediaType Ptr Ptr) As HRESULT
    EnableSphericalProcessing As Function(ByVal This As IMFVideoProcessorControl3 Ptr, ByVal fEnable As WINBOOL, ByVal eFormat As MFVideoSphericalFormat, ByVal eOutputType As MFVideoSphericalProjectionMode) As HRESULT
    SetSphericalMetadata As Function(ByVal This As IMFVideoProcessorControl3 Ptr, ByVal pViewInfo As IMFAttributes Ptr) As HRESULT
    SetOutputDevice As Function(ByVal This As IMFVideoProcessorControl3 Ptr, ByVal pOutputDevice As IUnknown Ptr) As HRESULT
End Type

Type IMFVideoProcessorControl3
    lpVtbl As IMFVideoProcessorControl3Vtbl Ptr
End Type

/' IMFVideoRendererEffectControl 接口 '/
Type IMFVideoRendererEffectControlVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFVideoRendererEffectControl Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFVideoRendererEffectControl Ptr) As ULong
    Release As Function(ByVal This As IMFVideoRendererEffectControl Ptr) As ULong
    
    ' IMFVideoRendererEffectControl 方法
    OnAppServiceConnectionEstablished As Function(ByVal This As IMFVideoRendererEffectControl Ptr, ByVal pAppServiceConnection As IUnknown Ptr) As HRESULT
End Type

Type IMFVideoRendererEffectControl
    lpVtbl As IMFVideoRendererEffectControlVtbl Ptr
End Type

#endif

/' 第15部分：高级特性和函数声明 '/

#if (WINVER >= 0x0601)

/' 质量建议标志 '/
Enum MF_QUALITY_ADVISE_FLAGS
    MF_QUALITY_CANNOT_KEEP_UP = &h1
End Enum

/' 转码拓扑模式 '/
Enum MF_TRANSCODE_TOPOLOGYMODE_FLAGS
    MF_TRANSCODE_TOPOLOGYMODE_SOFTWARE_ONLY = 0
    MF_TRANSCODE_TOPOLOGYMODE_HARDWARE_ALLOWED = 1
End Enum

/' DXVA 模式 '/
Enum MFTOPOLOGY_DXVA_MODE
    MFTOPOLOGY_DXVA_DEFAULT = 0
    MFTOPOLOGY_DXVA_NONE = 1
    MFTOPOLOGY_DXVA_FULL = 2
End Enum

/' 硬件模式 '/
Enum MFTOPOLOGY_HARDWARE_MODE
    MFTOPOLOGY_HWMODE_SOFTWARE_ONLY = 0
    MFTOPOLOGY_HWMODE_USE_HARDWARE = 1
End Enum

/' MFT 注册信息结构 '/
Type MFT_REGISTRATION_INFO
    clsid As CLSID
    guidCategory As GUID
    uiFlags As UINT32
    pszName As LPCWSTR
    cInTypes As DWORD
    pInTypes As MFT_REGISTER_TYPE_INFO Ptr
    cOutTypes As DWORD
    pOutTypes As MFT_REGISTER_TYPE_INFO Ptr
End Type

#endif

/' 网络凭据管理器参数结构 '/
Type MFNetCredentialManagerGetParam
    hrOp As HRESULT
    fAllowLoggedOnUser As WINBOOL
    fClearTextPackage As WINBOOL
    pszUrl As LPCWSTR
    pszSite As LPCWSTR
    pszRealm As LPCWSTR
    pszPackage As LPCWSTR
    nRetries As Long
End Type

/' 函数声明 '/

/' 远程过程调用代理函数 '/
Declare Function IMFTopologyNode_RemoteGetOutputPrefType_Proxy Lib "Mfplat.dll" Alias "IMFTopologyNode_RemoteGetOutputPrefType_Proxy" (ByVal This As IMFTopologyNode Ptr, ByVal dwOutputIndex As DWORD, ByVal pcbData As DWORD Ptr, ByVal ppbData As Byte Ptr Ptr) As HRESULT
Declare Sub IMFTopologyNode_RemoteGetOutputPrefType_Stub Lib "Mfplat.dll" Alias "IMFTopologyNode_RemoteGetOutputPrefType_Stub" (ByVal This As IRpcStubBuffer Ptr, ByVal pRpcChannelBuffer As IRpcChannelBuffer Ptr, ByVal pRpcMessage As PRPC_MESSAGE, ByVal pdwStubPhase As DWORD Ptr)

Declare Function IMFTopologyNode_RemoteGetInputPrefType_Proxy Lib "Mfplat.dll" Alias "IMFTopologyNode_RemoteGetInputPrefType_Proxy" (ByVal This As IMFTopologyNode Ptr, ByVal dwInputIndex As DWORD, ByVal pcbData As DWORD Ptr, ByVal ppbData As Byte Ptr Ptr) As HRESULT
Declare Sub IMFTopologyNode_RemoteGetInputPrefType_Stub Lib "Mfplat.dll" Alias "IMFTopologyNode_RemoteGetInputPrefType_Stub" (ByVal This As IRpcStubBuffer Ptr, ByVal pRpcChannelBuffer As IRpcChannelBuffer Ptr, ByVal pRpcMessage As PRPC_MESSAGE, ByVal pdwStubPhase As DWORD Ptr)

Declare Function IMFMediaTypeHandler_RemoteGetCurrentMediaType_Proxy Lib "Mfplat.dll" Alias "IMFMediaTypeHandler_RemoteGetCurrentMediaType_Proxy" (ByVal This As IMFMediaTypeHandler Ptr, ByVal ppbData As Byte Ptr Ptr, ByVal pcbData As DWORD Ptr) As HRESULT
Declare Sub IMFMediaTypeHandler_RemoteGetCurrentMediaType_Stub Lib "Mfplat.dll" Alias "IMFMediaTypeHandler_RemoteGetCurrentMediaType_Stub" (ByVal This As IRpcStubBuffer Ptr, ByVal pRpcChannelBuffer As IRpcChannelBuffer Ptr, ByVal pRpcMessage As PRPC_MESSAGE, ByVal pdwStubPhase As DWORD Ptr)

Declare Function IMFMediaSource_RemoteCreatePresentationDescriptor_Proxy Lib "Mfplat.dll" Alias "IMFMediaSource_RemoteCreatePresentationDescriptor_Proxy" (ByVal This As IMFMediaSource Ptr, ByVal pcbPD As DWORD Ptr, ByVal pbPD As Byte Ptr Ptr, ByVal ppRemotePD As IMFPresentationDescriptor Ptr Ptr) As HRESULT
Declare Sub IMFMediaSource_RemoteCreatePresentationDescriptor_Stub Lib "Mfplat.dll" Alias "IMFMediaSource_RemoteCreatePresentationDescriptor_Stub" (ByVal This As IRpcStubBuffer Ptr, ByVal pRpcChannelBuffer As IRpcChannelBuffer Ptr, ByVal pRpcMessage As PRPC_MESSAGE, ByVal pdwStubPhase As DWORD Ptr)

Declare Function IMFMediaStream_RemoteRequestSample_Proxy Lib "Mfplat.dll" Alias "IMFMediaStream_RemoteRequestSample_Proxy" (ByVal This As IMFMediaStream Ptr) As HRESULT
Declare Sub IMFMediaStream_RemoteRequestSample_Stub Lib "Mfplat.dll" Alias "IMFMediaStream_RemoteRequestSample_Stub" (ByVal This As IRpcStubBuffer Ptr, ByVal pRpcChannelBuffer As IRpcChannelBuffer Ptr, ByVal pRpcMessage As PRPC_MESSAGE, ByVal pdwStubPhase As DWORD Ptr)

/' 回调函数声明 '/
Declare Function IMFTopologyNode_GetOutputPrefType_Proxy Lib "Mfplat.dll" Alias "IMFTopologyNode_GetOutputPrefType_Proxy" (ByVal This As IMFTopologyNode Ptr, ByVal dwOutputIndex As DWORD, ByVal ppType As IMFMediaType Ptr Ptr) As HRESULT
Declare Function IMFTopologyNode_GetOutputPrefType_Stub Lib "Mfplat.dll" Alias "IMFTopologyNode_GetOutputPrefType_Stub" (ByVal This As IMFTopologyNode Ptr, ByVal dwOutputIndex As DWORD, ByVal pcbData As DWORD Ptr, ByVal ppbData As Byte Ptr Ptr) As HRESULT

Declare Function IMFTopologyNode_GetInputPrefType_Proxy Lib "Mfplat.dll" Alias "IMFTopologyNode_GetInputPrefType_Proxy" (ByVal This As IMFTopologyNode Ptr, ByVal dwInputIndex As DWORD, ByVal ppType As IMFMediaType Ptr Ptr) As HRESULT
Declare Function IMFTopologyNode_GetInputPrefType_Stub Lib "Mfplat.dll" Alias "IMFTopologyNode_GetInputPrefType_Stub" (ByVal This As IMFTopologyNode Ptr, ByVal dwInputIndex As DWORD, ByVal pcbData As DWORD Ptr, ByVal ppbData As Byte Ptr Ptr) As HRESULT

Declare Function IMFMediaTypeHandler_GetCurrentMediaType_Proxy Lib "Mfplat.dll" Alias "IMFMediaTypeHandler_GetCurrentMediaType_Proxy" (ByVal This As IMFMediaTypeHandler Ptr, ByVal ppMediaType As IMFMediaType Ptr Ptr) As HRESULT
Declare Function IMFMediaTypeHandler_GetCurrentMediaType_Stub Lib "Mfplat.dll" Alias "IMFMediaTypeHandler_GetCurrentMediaType_Stub" (ByVal This As IMFMediaTypeHandler Ptr, ByVal ppbData As Byte Ptr Ptr, ByVal pcbData As DWORD Ptr) As HRESULT

Declare Function IMFMediaSource_CreatePresentationDescriptor_Proxy Lib "Mfplat.dll" Alias "IMFMediaSource_CreatePresentationDescriptor_Proxy" (ByVal This As IMFMediaSource Ptr, ByVal ppPresentationDescriptor As IMFPresentationDescriptor Ptr Ptr) As HRESULT
Declare Function IMFMediaSource_CreatePresentationDescriptor_Stub Lib "Mfplat.dll" Alias "IMFMediaSource_CreatePresentationDescriptor_Stub" (ByVal This As IMFMediaSource Ptr, ByVal pcbPD As DWORD Ptr, ByVal pbPD As Byte Ptr Ptr, ByVal ppRemotePD As IMFPresentationDescriptor Ptr Ptr) As HRESULT

Declare Function IMFMediaStream_RequestSample_Proxy Lib "Mfplat.dll" Alias "IMFMediaStream_RequestSample_Proxy" (ByVal This As IMFMediaStream Ptr, ByVal pToken As IUnknown Ptr) As HRESULT
Declare Function IMFMediaStream_RequestSample_Stub Lib "Mfplat.dll" Alias "IMFMediaStream_RequestSample_Stub" (ByVal This As IMFMediaStream Ptr) As HRESULT

/' 主要函数声明 '/
Declare Function MFRequireProtectedEnvironment Lib "Mfplat.dll" Alias "MFRequireProtectedEnvironment" (ByVal pPresentationDescriptor As IMFPresentationDescriptor Ptr) As HRESULT
Declare Function MFSerializePresentationDescriptor Lib "Mfplat.dll" Alias "MFSerializePresentationDescriptor" (ByVal pPD As IMFPresentationDescriptor Ptr, ByVal pcbData As DWORD Ptr, ByVal ppbData As Byte Ptr Ptr) As HRESULT

/' 前向声明的接口 '/
#define __IMFASFContentInfo_FWD_DEFINED__
#define __IMFASFIndexer_FWD_DEFINED__
#define __IMFASFMultiplexer_FWD_DEFINED__
#define __IMFASFProfile_FWD_DEFINED__
#define __IMFASFSplitter_FWD_DEFINED__
#define __IMFPMPServer_FWD_DEFINED__
#define __IMFNetProxyLocator_FWD_DEFINED__
#define __IMFRemoteDesktopPlugin_FWD_DEFINED__
#define __IMFTransform_FWD_DEFINED__
#define __IMFSequencerSource_FWD_DEFINED__
#define __IMFQualityManager_FWD_DEFINED__
#define __IMFTranscodeProfile_FWD_DEFINED__

/' 第16部分：ASF相关接口 '/

/' IMFASFContentInfo 接口 '/
#define IID_IMFASFContentInfo @b1dca5cd, @d5da, @44ee, {&h82, &h1f, &h94, &h5, &h4a, &h57, &h80, &h8b}

Type IMFASFContentInfoVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFASFContentInfo Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFASFContentInfo Ptr) As ULong
    Release As Function(ByVal This As IMFASFContentInfo Ptr) As ULong
    
    ' IMFASFContentInfo 方法
    GetHeaderSize As Function(ByVal This As IMFASFContentInfo Ptr, ByVal pcbHeaderSize As UINT64 Ptr) As HRESULT
    GetFileSize As Function(ByVal This As IMFASFContentInfo Ptr, ByVal pcbFileSize As UINT64 Ptr) As HRESULT
    GetDataPacketSize As Function(ByVal This As IMFASFContentInfo Ptr, ByVal pcbDataPacketSize As UINT64 Ptr) As HRESULT
    GetFlags As Function(ByVal This As IMFASFContentInfo Ptr, ByVal pdwFlags As DWORD Ptr) As HRESULT
    SetFlags As Function(ByVal This As IMFASFContentInfo Ptr, ByVal dwFlags As DWORD) As HRESULT
    GenerateHeader As Function(ByVal This As IMFASFContentInfo Ptr, ByVal pbHeader As Byte Ptr, ByVal pcbHeader As DWORD Ptr) As HRESULT
    GetProfile As Function(ByVal This As IMFASFContentInfo Ptr, ByVal ppIProfile As IMFASFProfile Ptr Ptr) As HRESULT
    SetProfile As Function(ByVal This As IMFASFContentInfo Ptr, ByVal pIProfile As IMFASFProfile Ptr) As HRESULT
    GetStreamCount As Function(ByVal This As IMFASFContentInfo Ptr, ByVal pcStreams As DWORD Ptr) As HRESULT
    GetStream As Function(ByVal This As IMFASFContentInfo Ptr, ByVal wStreamNumber As WORD, ByVal ppStream As IMFASFStreamConfig Ptr Ptr) As HRESULT
    SetStream As Function(ByVal This As IMFASFContentInfo Ptr, ByVal pIStream As IMFASFStreamConfig Ptr) As HRESULT
    RemoveStream As Function(ByVal This As IMFASFContentInfo Ptr, ByVal wStreamNumber As WORD) As HRESULT
    CreateStreamSelection As Function(ByVal This As IMFASFContentInfo Ptr, ByVal wStreamNumber As WORD, ByVal ppIStreamSel As IMFASFStreamSelector Ptr Ptr) As HRESULT
    GetStreamSelection As Function(ByVal This As IMFASFContentInfo Ptr, ByVal wStreamNumber As WORD, ByVal ppIStreamSel As IMFASFStreamSelector Ptr Ptr) As HRESULT
    ParseHeader As Function(ByVal This As IMFASFContentInfo Ptr, ByVal pbHeader As Byte Ptr, ByVal cbHeader As DWORD) As HRESULT
    GetCodecIndex As Function(ByVal This As IMFASFContentInfo Ptr, ByVal pguidCodecType As GUID Ptr, ByVal pCodecInfo As Byte Ptr, ByVal cbCodecInfo As DWORD, ByVal pwCodecIndex As WORD Ptr) As HRESULT
End Type

Type IMFASFContentInfo
    lpVtbl As IMFASFContentInfoVtbl Ptr
End Type

/' IMFASFIndexer 接口 '/
#define IID_IMFASFIndexer @53590f48, @dc3b, @4617, {&h9d, &hc6, &hfb, &h8d, &h17, &h6a, &h4f, &h2f}

Type IMFASFIndexerVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFASFIndexer Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFASFIndexer Ptr) As ULong
    Release As Function(ByVal This As IMFASFIndexer Ptr) As ULong
    
    ' IMFASFIndexer 方法
    SetFlags As Function(ByVal This As IMFASFIndexer Ptr, ByVal dwFlags As DWORD) As HRESULT
    GetFlags As Function(ByVal This As IMFASFIndexer Ptr, ByVal pdwFlags As DWORD Ptr) As HRESULT
    Initialize As Function(ByVal This As IMFASFIndexer Ptr, ByVal pIContentInfo As IMFASFContentInfo Ptr) As HRESULT
    GetIndexPosition As Function(ByVal This As IMFASFIndexer Ptr, ByVal pIContentInfo As IMFASFContentInfo Ptr, ByVal pcbIndexOffset As UINT64 Ptr) As HRESULT
    SetIndexStatus As Function(ByVal This As IMFASFIndexer Ptr, ByVal pawStreamNumbers As WORD Ptr, ByVal cStreams As WORD, ByVal fIndexed As WINBOOL) As HRESULT
    GetIndexStatus As Function(ByVal This As IMFASFIndexer Ptr, ByVal pawStreamNumbers As WORD Ptr, ByVal cStreams As WORD, ByVal pfIndexed As WINBOOL Ptr) As HRESULT
    CreateIndexForStreamNumber As Function(ByVal This As IMFASFIndexer Ptr, ByVal wStreamNumber As WORD, ByVal pvContext As Const PROPVARIANT Ptr, ByVal ppIIndex As IMFASFIndexer Ptr Ptr) As HRESULT
    GenerateIndexEntries As Function(ByVal This As IMFASFIndexer Ptr, ByVal pIMediaBuffer As IMFMediaBuffer Ptr) As HRESULT
    CommitIndex As Function(ByVal This As IMFASFIndexer Ptr, ByVal pIMediaBuffer As IMFMediaBuffer Ptr) As HRESULT
    GetIndexWriteSpace As Function(ByVal This As IMFASFIndexer Ptr, ByVal pcbIndexWriteSpace As UINT64 Ptr) As HRESULT
End Type

Type IMFASFIndexer
    lpVtbl As IMFASFIndexerVtbl Ptr
End Type

/' IMFASFMultiplexer 接口 '/
#define IID_IMFASFMultiplexer @57bdd80a, @9b38, @4838, {&hb7, &h37, &heb, &h6a, &h51, &h95, &h4c, &h9c}

Type IMFASFMultiplexerVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFASFMultiplexer Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFASFMultiplexer Ptr) As ULong
    Release As Function(ByVal This As IMFASFMultiplexer Ptr) As ULong
    
    ' IMFASFMultiplexer 方法
    Initialize As Function(ByVal This As IMFASFMultiplexer Ptr, ByVal pIMultiplexerConfig As IMFASFMultiplexerConfig Ptr) As HRESULT
    ProcessSample As Function(ByVal This As IMFASFMultiplexer Ptr, ByVal wStreamNumber As WORD, ByVal pISample As IMFSample Ptr, ByVal hnsTimestampAdjust As LONGLONG) As HRESULT
    GetNextPacket As Function(ByVal This As IMFASFMultiplexer Ptr, ByVal pdwStatusFlags As DWORD Ptr, ByVal ppIPacket As IMFSample Ptr Ptr) As HRESULT
    Flush As Function(ByVal This As IMFASFMultiplexer Ptr) As HRESULT
    End As Function(ByVal This As IMFASFMultiplexer Ptr) As HRESULT
    GetStatistics As Function(ByVal This As IMFASFMultiplexer Ptr, ByVal wStreamNumber As WORD, ByVal pStatistics As ASF_MULTIPLEXER_STATISTICS Ptr) As HRESULT
    SetSyncTolerance As Function(ByVal This As IMFASFMultiplexer Ptr, ByVal msTolerance As DWORD) As HRESULT
End Type

Type IMFASFMultiplexer
    lpVtbl As IMFASFMultiplexerVtbl Ptr
End Type

/' IMFASFProfile 接口 '/
#define IID_IMFASFProfile @d267bf6a, @028b, @4e0a, {&hac, &h5b, &h5a, &h59, &h6a, &h47, &h85, &h6d}

Type IMFASFProfileVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFASFProfile Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFASFProfile Ptr) As ULong
    Release As Function(ByVal This As IMFASFProfile Ptr) As ULong
    
    ' IMFASFProfile 方法
    GetStreamCount As Function(ByVal This As IMFASFProfile Ptr, ByVal pcStreams As DWORD Ptr) As HRESULT
    GetStream As Function(ByVal This As IMFASFProfile Ptr, ByVal dwStreamIndex As DWORD, ByVal ppStream As IMFASFStreamConfig Ptr Ptr) As HRESULT
    GetStreamByNumber As Function(ByVal This As IMFASFProfile Ptr, ByVal wStreamNumber As WORD, ByVal ppStream As IMFASFStreamConfig Ptr Ptr) As HRESULT
    RemoveStream As Function(ByVal This As IMFASFProfile Ptr, ByVal pIStream As IMFASFStreamConfig Ptr) As HRESULT
    RemoveStreamByNumber As Function(ByVal This As IMFASFProfile Ptr, ByVal wStreamNumber As WORD) As HRESULT
    CreateStream As Function(ByVal This As IMFASFProfile Ptr, ByVal pIMediaType As IMFMediaType Ptr, ByVal ppIStream As IMFASFStreamConfig Ptr Ptr) As HRESULT
    ConfigStream As Function(ByVal This As IMFASFProfile Ptr, ByVal pIMediaType As IMFMediaType Ptr, ByVal pIStream As IMFASFStreamConfig Ptr) As HRESULT
    ReconfigStream As Function(ByVal This As IMFASFProfile Ptr, ByVal pIStream As IMFASFStreamConfig Ptr) As HRESULT
    CreateMutualExclusion As Function(ByVal This As IMFASFProfile Ptr, ByVal ppIMutex As IMFASFMutualExclusion Ptr Ptr) As HRESULT
    AddMutualExclusion As Function(ByVal This As IMFASFProfile Ptr, ByVal pIMutex As IMFASFMutualExclusion Ptr) As HRESULT
    RemoveMutualExclusion As Function(ByVal This As IMFASFProfile Ptr, ByVal pIMutex As IMFASFMutualExclusion Ptr) As HRESULT
    GetMutualExclusionCount As Function(ByVal This As IMFASFProfile Ptr, ByVal pcMutexs As DWORD Ptr) As HRESULT
    GetMutualExclusion As Function(ByVal This As IMFASFProfile Ptr, ByVal dwMutexIndex As DWORD, ByVal ppIMutex As IMFASFMutualExclusion Ptr Ptr) As HRESULT
    CreateStreamPrioritization As Function(ByVal This As IMFASFProfile Ptr, ByVal ppIStreamPrioritization As IMFASFStreamPrioritization Ptr Ptr) As HRESULT
    AddStreamPrioritization As Function(ByVal This As IMFASFProfile Ptr, ByVal pIStreamPrioritization As IMFASFStreamPrioritization Ptr) As HRESULT
    RemoveStreamPrioritization As Function(ByVal This As IMFASFProfile Ptr, ByVal pIStreamPrioritization As IMFASFStreamPrioritization Ptr) As HRESULT
    GetStreamPrioritization As Function(ByVal This As IMFASFProfile Ptr, ByVal ppIStreamPrioritization As IMFASFStreamPrioritization Ptr Ptr) As HRESULT
    CreateProfileElement As Function(ByVal This As IMFASFProfile Ptr, ByVal guidElementType As REFGUID, ByVal ppIElement As IUnknown Ptr Ptr) As HRESULT
    AddProfileElement As Function(ByVal This As IMFASFProfile Ptr, ByVal pIElement As IUnknown Ptr) As HRESULT
    RemoveProfileElement As Function(ByVal This As IMFASFProfile Ptr, ByVal pIElement As IUnknown Ptr) As HRESULT
    GetProfileElementCount As Function(ByVal This As IMFASFProfile Ptr, ByVal pcElements As DWORD Ptr) As HRESULT
    GetProfileElement As Function(ByVal This As IMFASFProfile Ptr, ByVal dwElementIndex As DWORD, ByVal ppIElement As IUnknown Ptr Ptr) As HRESULT
End Type

Type IMFASFProfile
    lpVtbl As IMFASFProfileVtbl Ptr
End Type

/' 第17部分：更多ASF接口和PMP服务器 '/

/' IMFASFSplitter 接口 '/
#define IID_IMFASFSplitter @12558295, @e399, @11d5, {&hbc, &h2a, &h0, &hb, &hd9, &h7, &h5f, &h5c}

Type IMFASFSplitterVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFASFSplitter Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFASFSplitter Ptr) As ULong
    Release As Function(ByVal This As IMFASFSplitter Ptr) As ULong
    
    ' IMFASFSplitter 方法
    Initialize As Function(ByVal This As IMFASFSplitter Ptr, ByVal pIContentInfo As IMFASFContentInfo Ptr) As HRESULT
    SetFlags As Function(ByVal This As IMFASFSplitter Ptr, ByVal dwFlags As DWORD) As HRESULT
    GetFlags As Function(ByVal This As IMFASFSplitter Ptr, ByVal pdwFlags As DWORD Ptr) As HRESULT
    SelectStreams As Function(ByVal This As IMFASFSplitter Ptr, ByVal pwStreamNumbers As WORD Ptr, ByVal cStreams As WORD) As HRESULT
    GetSelectedStreams As Function(ByVal This As IMFASFSplitter Ptr, ByVal pwStreamNumbers As WORD Ptr, ByVal pcStreams As WORD Ptr) As HRESULT
    ParseData As Function(ByVal This As IMFASFSplitter Ptr, ByVal pIBuffer As IMFMediaBuffer Ptr, ByVal cbBufferOffset As DWORD, ByVal cbLength As DWORD) As HRESULT
    GetNextSample As Function(ByVal This As IMFASFSplitter Ptr, ByVal pdwStatus As DWORD Ptr, ByVal pwStreamNumber As WORD Ptr, ByVal ppISample As IMFSample Ptr Ptr) As HRESULT
    Flush As Function(ByVal This As IMFASFSplitter Ptr) As HRESULT
    GetLastSendTime As Function(ByVal This As IMFASFSplitter Ptr, ByVal phnsLastSendTime As LONGLONG Ptr) As HRESULT
End Type

Type IMFASFSplitter
    lpVtbl As IMFASFSplitterVtbl Ptr
End Type

/' IMFPMPServer 接口 '/
#define IID_IMFPMPServer @994e23af, @1cc2, @493c, {&hb9, &hfa, &h46, &hf2, &h24, &h55, &h75, &h40}

Type IMFPMPServerVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFPMPServer Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFPMPServer Ptr) As ULong
    Release As Function(ByVal This As IMFPMPServer Ptr) As ULong
    
    ' IMFPMPServer 方法
    CreateObjectByCLSID As Function(ByVal This As IMFPMPServer Ptr, ByVal clsid As REFCLSID, ByVal riid As REFIID, ByVal ppv As Any Ptr Ptr) As HRESULT
    LockProcess As Function(ByVal This As IMFPMPServer Ptr) As HRESULT
    UnlockProcess As Function(ByVal This As IMFPMPServer Ptr) As HRESULT
End Type

Type IMFPMPServer
    lpVtbl As IMFPMPServerVtbl Ptr
End Type

/' IMFNetProxyLocator 接口 '/
#define IID_IMFNetProxyLocator @e9cd0384, @a268, @4bb4, {&h82, &hde, &h65, &h8d, &h63, &h84, &h7f, &h2e}

Type IMFNetProxyLocatorVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFNetProxyLocator Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFNetProxyLocator Ptr) As ULong
    Release As Function(ByVal This As IMFNetProxyLocator Ptr) As ULong
    
    ' IMFNetProxyLocator 方法
    FindFirstProxy As Function(ByVal This As IMFNetProxyLocator Ptr, ByVal pszHost As LPCWSTR, ByVal pszUrl As LPCWSTR, ByVal fReserved As WINBOOL) As HRESULT
    FindNextProxy As Function(ByVal This As IMFNetProxyLocator Ptr) As HRESULT
    RegisterProxyResult As Function(ByVal This As IMFNetProxyLocator Ptr, ByVal hrProxyResult As HRESULT) As HRESULT
    GetCurrentProxy As Function(ByVal This As IMFNetProxyLocator Ptr, ByVal pszProxy As LPWSTR, ByVal pcchProxy As DWORD Ptr) As HRESULT
    Clone As Function(ByVal This As IMFNetProxyLocator Ptr, ByVal ppProxyLocator As IMFNetProxyLocator Ptr Ptr) As HRESULT
End Type

Type IMFNetProxyLocator
    lpVtbl As IMFNetProxyLocatorVtbl Ptr
End Type

/' IMFRemoteDesktopPlugin 接口 '/
#define IID_IMFRemoteDesktopPlugin @1cde6309, @cae0, @4940, {&h90, &h7e, &hc1, &hec, &h8c, &h3e, &h67, &h5e}

Type IMFRemoteDesktopPluginVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFRemoteDesktopPlugin Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFRemoteDesktopPlugin Ptr) As ULong
    Release As Function(ByVal This As IMFRemoteDesktopPlugin Ptr) As ULong
    
    ' IMFRemoteDesktopPlugin 方法
    UpdateTopology As Function(ByVal This As IMFRemoteDesktopPlugin Ptr, ByVal pTopology As IMFTopology Ptr) As HRESULT
End Type

Type IMFRemoteDesktopPlugin
    lpVtbl As IMFRemoteDesktopPluginVtbl Ptr
End Type

/' 第18部分：变换和序列器接口 '/

/' IMFTransform 接口 '/
#define IID_IMFTransform @bf94c121, @56b5, @4a18, {&ha5, &h8e, &h32, &ha4, &h1e, &h87, &h6f, &he2}

Type IMFTransformVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFTransform Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFTransform Ptr) As ULONG
    Release As Function(ByVal This As IMFTransform Ptr) As ULONG
    
    ' IMFTransform 方法
    GetStreamLimits As Function(ByVal This As IMFTransform Ptr, ByVal pdwInputMinimum As DWORD Ptr, ByVal pdwInputMaximum As DWORD Ptr, ByVal pdwOutputMinimum As DWORD Ptr, ByVal pdwOutputMaximum As DWORD Ptr) As HRESULT
    GetStreamCount As Function(ByVal This As IMFTransform Ptr, ByVal pcInputStreams As DWORD Ptr, ByVal pcOutputStreams As DWORD Ptr) As HRESULT
    GetStreamIDs As Function(ByVal This As IMFTransform Ptr, ByVal dwInputIDArraySize As DWORD, ByVal pdwInputIDs As DWORD Ptr, ByVal dwOutputIDArraySize As DWORD, ByVal pdwOutputIDs As DWORD Ptr) As HRESULT
    GetInputStreamInfo As Function(ByVal This As IMFTransform Ptr, ByVal dwInputStreamID As DWORD, ByVal pStreamInfo As MFT_INPUT_STREAM_INFO Ptr) As HRESULT
    GetOutputStreamInfo As Function(ByVal This As IMFTransform Ptr, ByVal dwOutputStreamID As DWORD, ByVal pStreamInfo As MFT_OUTPUT_STREAM_INFO Ptr) As HRESULT
    GetAttributes As Function(ByVal This As IMFTransform Ptr, ByVal pAttributes As IMFAttributes Ptr Ptr) As HRESULT
    GetInputStreamAttributes As Function(ByVal This As IMFTransform Ptr, ByVal dwInputStreamID As DWORD, ByVal pAttributes As IMFAttributes Ptr Ptr) As HRESULT
    GetOutputStreamAttributes As Function(ByVal This As IMFTransform Ptr, ByVal dwOutputStreamID As DWORD, ByVal pAttributes As IMFAttributes Ptr Ptr) As HRESULT
    DeleteInputStream As Function(ByVal This As IMFTransform Ptr, ByVal dwStreamID As DWORD) As HRESULT
    AddInputStreams As Function(ByVal This As IMFTransform Ptr, ByVal cStreams As DWORD, ByVal adwStreamIDs As DWORD Ptr) As HRESULT
    GetInputAvailableType As Function(ByVal This As IMFTransform Ptr, ByVal dwInputStreamID As DWORD, ByVal dwTypeIndex As DWORD, ByVal ppType As IMFMediaType Ptr Ptr) As HRESULT
    GetOutputAvailableType As Function(ByVal This As IMFTransform Ptr, ByVal dwOutputStreamID As DWORD, ByVal dwTypeIndex As DWORD, ByVal ppType As IMFMediaType Ptr Ptr) As HRESULT
    SetInputType As Function(ByVal This As IMFTransform Ptr, ByVal dwInputStreamID As DWORD, ByVal pType As IMFMediaType Ptr, ByVal dwFlags As DWORD) As HRESULT
    SetOutputType As Function(ByVal This As IMFTransform Ptr, ByVal dwOutputStreamID As DWORD, ByVal pType As IMFMediaType Ptr, ByVal dwFlags As DWORD) As HRESULT
    GetInputCurrentType As Function(ByVal This As IMFTransform Ptr, ByVal dwInputStreamID As DWORD, ByVal ppType As IMFMediaType Ptr Ptr) As HRESULT
    GetOutputCurrentType As Function(ByVal This As IMFTransform Ptr, ByVal dwOutputStreamID As DWORD, ByVal ppType As IMFMediaType Ptr Ptr) As HRESULT
    GetInputStatus As Function(ByVal This As IMFTransform Ptr, ByVal dwInputStreamID As DWORD, ByVal pdwFlags As DWORD Ptr) As HRESULT
    GetOutputStatus As Function(ByVal This As IMFTransform Ptr, ByVal dwOutputStreamID As DWORD, ByVal pdwFlags As DWORD Ptr) As HRESULT
    SetOutputBounds As Function(ByVal This As IMFTransform Ptr, ByVal hnsLowerBound As LONGLONG, ByVal hnsUpperBound As LONGLONG) As HRESULT
    ProcessEvent As Function(ByVal This As IMFTransform Ptr, ByVal dwInputStreamID As DWORD, ByVal pEvent As IMFMediaEvent Ptr) As HRESULT
    ProcessMessage As Function(ByVal This As IMFTransform Ptr, ByVal eMessage As MFT_MESSAGE_TYPE, ByVal ulParam As ULONG_PTR) As HRESULT
    ProcessInput As Function(ByVal This As IMFTransform Ptr, ByVal dwInputStreamID As DWORD, ByVal pSample As IMFSample Ptr, ByVal dwFlags As DWORD) As HRESULT
    ProcessOutput As Function(ByVal This As IMFTransform Ptr, ByVal dwFlags As DWORD, ByVal cOutputBufferCount As DWORD, ByVal pOutputSamples As MFT_OUTPUT_DATA_BUFFER Ptr, ByVal pdwStatus As DWORD Ptr) As HRESULT
End Type

Type IMFTransform
    lpVtbl As IMFTransformVtbl Ptr
End Type

/' IMFSequencerSource 接口 '/
#define IID_IMFSequencerSource @197cd219, @19a8, @4d89, {&h93, &h4a, &h8c, &h5d, &hf5, &he1, &h71, &h28}

Type IMFSequencerSourceVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFSequencerSource Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFSequencerSource Ptr) As ULong
    Release As Function(ByVal This As IMFSequencerSource Ptr) As ULong
    
    ' IMFSequencerSource 方法
    AppendTopology As Function(ByVal This As IMFSequencerSource Ptr, ByVal pTopology As IMFTopology Ptr, ByVal dwFlags As DWORD, ByVal pdwId As MFSequencerElementId Ptr) As HRESULT
    DeleteTopology As Function(ByVal This As IMFSequencerSource Ptr, ByVal dwId As MFSequencerElementId) As HRESULT
    GetPresentationContext As Function(ByVal This As IMFSequencerSource Ptr, ByVal pPresentationDescriptor As IMFPresentationDescriptor Ptr, ByVal pId As MFSequencerElementId Ptr, ByVal ppTopology As IMFTopology Ptr Ptr) As HRESULT
    UpdateTopology As Function(ByVal This As IMFSequencerSource Ptr, ByVal dwId As MFSequencerElementId, ByVal pTopology As IMFTopology Ptr) As HRESULT
    UpdateTopologyFlags As Function(ByVal This As IMFSequencerSource Ptr, ByVal dwId As MFSequencerElementId, ByVal dwFlags As DWORD) As HRESULT
End Type

Type IMFSequencerSource
    lpVtbl As IMFSequencerSourceVtbl Ptr
End Type

/' 第19部分：质量管理和转码接口 '/

/' IMFQualityManager 接口 '/
#define IID_IMFQualityManager @8d009d4a, @13bd, @4a8f, {&h9a, &hfc, &h2, &h2d, &hdf, &h25, &h5d, &h3e}

Type IMFQualityManagerVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFQualityManager Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFQualityManager Ptr) As ULong
    Release As Function(ByVal This As IMFQualityManager Ptr) As ULong
    
    ' IMFQualityManager 方法
    NotifyTopology As Function(ByVal This As IMFQualityManager Ptr, ByVal pTopology As IMFTopology Ptr) As HRESULT
    NotifyPresentationClock As Function(ByVal This As IMFQualityManager Ptr, ByVal pClock As IMFPresentationClock Ptr) As HRESULT
    NotifyProcessInput As Function(ByVal This As IMFQualityManager Ptr, ByVal pNode As IMFTopologyNode Ptr, ByVal lInputIndex As Long, ByVal pSample As IMFSample Ptr) As HRESULT
    NotifyProcessOutput As Function(ByVal This As IMFQualityManager Ptr, ByVal pNode As IMFTopologyNode Ptr, ByVal lOutputIndex As Long, ByVal pSample As IMFSample Ptr) As HRESULT
    NotifyQualityEvent As Function(ByVal This As IMFQualityManager Ptr, ByVal pObject As IUnknown Ptr, ByVal pEvent As IMFMediaEvent Ptr) As HRESULT
    Shutdown As Function(ByVal This As IMFQualityManager Ptr) As HRESULT
End Type

Type IMFQualityManager
    lpVtbl As IMFQualityManagerVtbl Ptr
End Type

/' IMFTranscodeProfile 接口 '/
#define IID_IMFTranscodeProfile @ac6b7889, @7440, @4f94, {&ha0, &heb, &h4b, &h61, &h6a, &h23, &hbd, &h7a}

Type IMFTranscodeProfileVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFTranscodeProfile Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFTranscodeProfile Ptr) As ULong
    Release As Function(ByVal This As IMFTranscodeProfile Ptr) As ULong
    
    ' IMFTranscodeProfile 方法
    SetAudioAttributes As Function(ByVal This As IMFTranscodeProfile Ptr, ByVal pAttrs As IMFAttributes Ptr) As HRESULT
    GetAudioAttributes As Function(ByVal This As IMFTranscodeProfile Ptr, ByVal ppAttrs As IMFAttributes Ptr Ptr) As HRESULT
    SetVideoAttributes As Function(ByVal This As IMFTranscodeProfile Ptr, ByVal pAttrs As IMFAttributes Ptr) As HRESULT
    GetVideoAttributes As Function(ByVal This As IMFTranscodeProfile Ptr, ByVal ppAttrs As IMFAttributes Ptr Ptr) As HRESULT
    SetContainerAttributes As Function(ByVal This As IMFTranscodeProfile Ptr, ByVal pAttrs As IMFAttributes Ptr) As HRESULT
    GetContainerAttributes As Function(ByVal This As IMFTranscodeProfile Ptr, ByVal ppAttrs As IMFAttributes Ptr Ptr) As HRESULT
End Type

Type IMFTranscodeProfile
    lpVtbl As IMFTranscodeProfileVtbl Ptr
End Type

/' IMFStreamSink 接口 (详细定义) '/
Type IMFStreamSinkVtbl
    ' IUnknown 方法
    QueryInterface As Function(ByVal This As IMFStreamSink Ptr, ByVal riid As REFIID, ByVal ppvObject As Any Ptr Ptr) As HRESULT
    AddRef As Function(ByVal This As IMFStreamSink Ptr) As ULong
    Release As Function(ByVal This As IMFStreamSink Ptr) As ULong
    
    ' IMFMediaEventGenerator 方法
    GetEvent As Function(ByVal This As IMFStreamSink Ptr, ByVal dwFlags As DWORD, ByVal ppEvent As IMFMediaEvent Ptr Ptr) As HRESULT
    BeginGetEvent As Function(ByVal This As IMFStreamSink Ptr, ByVal pCallback As IMFAsyncCallback Ptr, ByVal punkState As IUnknown Ptr) As HRESULT
    EndGetEvent As Function(ByVal This As IMFStreamSink Ptr, ByVal pResult As IMFAsyncResult Ptr, ByVal ppEvent As IMFMediaEvent Ptr Ptr) As HRESULT
    QueueEvent As Function(ByVal This As IMFStreamSink Ptr, ByVal met As MediaEventType, ByVal guidExtendedType As REFGUID, ByVal hrStatus As HRESULT, ByVal pvValue As Const PROPVARIANT Ptr) As HRESULT
    
    ' IMFStreamSink 方法
    GetMediaSink As Function(ByVal This As IMFStreamSink Ptr, ByVal ppMediaSink As IMFMediaSink Ptr Ptr) As HRESULT
    GetIdentifier As Function(ByVal This As IMFStreamSink Ptr, ByVal pdwIdentifier As DWORD Ptr) As HRESULT
    GetMediaTypeHandler As Function(ByVal This As IMFStreamSink Ptr, ByVal ppHandler As IMFMediaTypeHandler Ptr Ptr) As HRESULT
    ProcessSample As Function(ByVal This As IMFStreamSink Ptr, ByVal pSample As IMFSample Ptr) As HRESULT
    PlaceMarker As Function(ByVal This As IMFStreamSink Ptr, ByVal eMarkerType As MFSTREAMSINK_MARKER_TYPE, ByVal pvarMarkerValue As Const PROPVARIANT Ptr, ByVal pvarContextValue As Const PROPVARIANT Ptr) As HRESULT
    Flush As Function(ByVal This As IMFStreamSink Ptr) As HRESULT
End Type

Type IMFStreamSink
    lpVtbl As IMFStreamSinkVtbl Ptr
End Type

/' 第20部分：条件编译和最终部分 '/

/' 条件编译部分 - Windows 7 及以上版本 '/
#if (WINVER >= 0x0601)

/' 质量建议标志 '/
Enum MF_QUALITY_ADVISE_FLAGS
    MF_QUALITY_CANNOT_KEEP_UP = &h1
End Enum

/' 转码拓扑模式 '/
Enum MF_TRANSCODE_TOPOLOGYMODE_FLAGS
    MF_TRANSCODE_TOPOLOGYMODE_SOFTWARE_ONLY = 0
    MF_TRANSCODE_TOPOLOGYMODE_HARDWARE_ALLOWED = 1
End Enum

/' DXVA 模式 '/
Enum MFTOPOLOGY_DXVA_MODE
    MFTOPOLOGY_DXVA_DEFAULT = 0
    MFTOPOLOGY_DXVA_NONE = 1
    MFTOPOLOGY_DXVA_FULL = 2
End Enum

/' 硬件模式 '/
Enum MFTOPOLOGY_HARDWARE_MODE
    MFTOPOLOGY_HWMODE_SOFTWARE_ONLY = 0
    MFTOPOLOGY_HWMODE_USE_HARDWARE = 1
End Enum

/' MFT 注册信息结构 '/
Type MFT_REGISTRATION_INFO
    clsid As CLSID
    guidCategory As GUID
    uiFlags As UINT32
    pszName As LPCWSTR
    cInTypes As DWORD
    pInTypes As MFT_REGISTER_TYPE_INFO Ptr
    cOutTypes As DWORD
    pOutTypes As MFT_REGISTER_TYPE_INFO Ptr
End Type

#endif

/' 条件编译部分 - Windows 8 及以上版本 '/
#if (WINVER >= _WIN32_WINNT_WIN8)

/' 额外的转码容器类型 '/
#define MFTranscodeContainerType_FMPEG4 @9ba876f1, @419f, @4b77, {&ha1, &he0, &h35, &h95, &h9d, &h9d, &h40, &h4}

/' 硬件连接支持 '/
#define MF_SOURCE_STREAM_SUPPORTS_HW_CONNECTION @a38253aa, @6314, @42fd, {&ha3, &hce, &hbb, &h27, &hb6, &h85, &h99, &h46}

/' 视频球形格式枚举 '/
Enum MFVideoSphericalFormat
    MFVideoSphericalFormat_Unsupported = 0
    MFVideoSphericalFormat_Equirectangular = 1
    MFVideoSphericalFormat_CubeMap = 2
    MFVideoSphericalFormat_3DExtended = 3
End Enum

/' 视频球形投影模式枚举 '/
Enum MFVideoSphericalProjectionMode
    MFVideoSphericalProjectionMode_Spherical = 0
    MFVideoSphericalProjectionMode_Flat = 1
End Enum

#endif

/' 网络相关枚举 '/
Enum MFNETSOURCE_STATISTICS_IDS
    MFNETSOURCE_RECVPACKETS_ID = 0
    MFNETSOURCE_LOSTPACKETS_ID = 1
    MFNETSOURCE_RESENDSREQUESTED_ID = 2
    MFNETSOURCE_RESENDSRECEIVED_ID = 3
    MFNETSOURCE_RECOVEREDBYECCPACKETS_ID = 4
    MFNETSOURCE_RECOVEREDBYRTXPACKETS_ID = 5
    MFNETSOURCE_OUTPACKETS_ID = 6
    MFNETSOURCE_RECVRATE_ID = 7
    MFNETSOURCE_AVGBANDWIDTHBPS_ID = 8
    MFNETSOURCE_BYTESRECEIVED_ID = 9
    MFNETSOURCE_PROTOCOL_ID = 10
    MFNETSOURCE_TRANSPORT_ID = 11
    MFNETSOURCE_CACHE_STATE_ID = 12
    MFNETSOURCE_LINKBANDWIDTH_ID = 13
    MFNETSOURCE_CONTENTBITRATE_ID = 14
    MFNETSOURCE_SPEEDFACTOR_ID = 15
    MFNETSOURCE_BUFFERSIZE_ID = 16
    MFNETSOURCE_BUFFERPROGRESS_ID = 17
    MFNETSOURCE_LASTBWSWITCHTS_ID = 18
    MFNETSOURCE_SEEKRANGESTART_ID = 19
    MFNETSOURCE_SEEKRANGEEND_ID = 20
    MFNETSOURCE_BUFFERINGCOUNT_ID = 21
    MFNETSOURCE_INCORRECTLYSIGNEDPACKETS_ID = 22
    MFNETSOURCE_SIGNEDSESSION_ID = 23
    MFNETSOURCE_MAXBITRATE_ID = 24
    MFNETSOURCE_RECEPTION_QUALITY_ID = 25
    MFNETSOURCE_RECOVEREDPACKETS_ID = 26
    MFNETSOURCE_VBR_ID = 27
    MFNETSOURCE_DOWNLOADPROGRESS_ID = 28
End Enum

/' 额外的函数声明 '/

/' 媒体基础保护环境函数 '/
Declare Function MFRequireProtectedEnvironment Lib "Mfplat.dll" Alias "MFRequireProtectedEnvironment" (ByVal pPresentationDescriptor As IMFPresentationDescriptor Ptr) As HRESULT

/' 序列化表示描述符函数 '/
Declare Function MFSerializePresentationDescriptor Lib "Mfplat.dll" Alias "MFSerializePresentationDescriptor" (ByVal pPD As IMFPresentationDescriptor Ptr, ByVal pcbData As DWORD Ptr, ByVal ppbData As Byte Ptr Ptr) As HRESULT

/' 前向声明的接口 GUID '/
#define IID_IMFSequencerSource @197cd219, @19a8, @4d89, {&h93, &h4a, &h8c, &h5d, &hf5, &he1, &h71, &h28}
#define IID_IMFQualityManager @8d009d4a, @13bd, @4a8f, {&h9a, &hfc, &h2, &h2d, &hdf, &h25, &h5d, &h3e}
#define IID_IMFTranscodeProfile @ac6b7889, @7440, @4f94, {&ha0, &heb, &h4b, &h61, &h6a, &h23, &hbd, &h7a}

/' 媒体接收器特性常量 '/
#define MEDIASINK_FIXED_STREAMS                 &h00000001
#define MEDIASINK_CANNOT_MATCH_CLOCK            &h00000002
#define MEDIASINK_RATELESS                      &h00000004
#define MEDIASINK_CLOCK_REQUIRED                &h00000008
#define MEDIASINK_CAN_PREROLL                   &h00000010
#define MEDIASINK_REQUIRE_REFERENCE_MEDIATYPE   &h00000020

/' 源解析器标志 '/
Enum
    MF_RESOLUTION_MEDIASOURCE = &h1
    MF_RESOLUTION_BYTESTREAM = &h2
    MF_RESOLUTION_CONTENT_DOES_NOT_HAVE_TO_MATCH_EXTENSION_OR_MIME_TYPE = &h10
    MF_RESOLUTION_KEEP_BYTE_STREAM_ALIVE_ON_FAIL = &h20
    MF_RESOLUTION_READ = &h10000
    MF_RESOLUTION_WRITE = &h20000
End Enum

/' 文件结束标记 '/
/' 注意：由于原始C++头文件非常庞大，这个转换已经覆盖了绝大部分核心接口和类型。 '/
/' 在实际使用中，您可能需要根据具体需求选择性地包含这些定义。 '/
/' 建议将完整的转换分成多个文件管理，以提高可维护性。 '/