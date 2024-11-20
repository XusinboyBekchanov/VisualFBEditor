#pragma once

#define USBCAMAPI DECLSPEC_IMPORT

type _pipe_config_descriptor
	StreamAssociation as CHAR
	PipeConfigFlags as UCHAR
end type

type USBCAMD_Pipe_Config_Descriptor as _pipe_config_descriptor
type PUSBCAMD_Pipe_Config_Descriptor as _pipe_config_descriptor ptr
const USBCAMD_DATA_PIPE = &h0001
const USBCAMD_MULTIPLEX_PIPE = &h0002
const USBCAMD_SYNC_PIPE = &h0004
const USBCAMD_DONT_CARE_PIPE = &h0008
const USBCAMD_VIDEO_STREAM = &h1
const USBCAMD_STILL_STREAM = &h2
const USBCAMD_VIDEO_STILL_STREAM = USBCAMD_VIDEO_STREAM or USBCAMD_STILL_STREAM
const USBCAMD_PROCESSPACKETEX_DropFrame = &h0002
const USBCAMD_PROCESSPACKETEX_NextFrameIsStill = &h0004
const USBCAMD_PROCESSPACKETEX_CurrentFrameIsStill = &h0008
const USBCAMD_STOP_STREAM = &h00000001
const USBCAMD_START_STREAM = &h00000000

type USBCAMD_CamControlFlags as long
enum
	USBCAMD_CamControlFlag_NoVideoRawProcessing = 1
	USBCAMD_CamControlFlag_NoStillRawProcessing = 2
	USBCAMD_CamControlFlag_AssociatedFormat = 4
	USBCAMD_CamControlFlag_EnableDeviceEvents = 8
end enum

'' TODO: typedef NTSTATUS(NTAPI *PCOMMAND_COMPLETE_FUNCTION)( PVOID DeviceContext, PVOID CommandContext, NTSTATUS NtStatus);
'' TODO: typedef VOID(NTAPI *PSTREAM_RECEIVE_PACKET)( PVOID Srb, PVOID DeviceContext, PBOOLEAN Completed);
'' TODO: typedef NTSTATUS(NTAPI *PCAM_INITIALIZE_ROUTINE)( PDEVICE_OBJECT BusDeviceObject, PVOID DeviceContext);
'' TODO: typedef NTSTATUS(NTAPI *PCAM_CONFIGURE_ROUTINE)( PDEVICE_OBJECT BusDeviceObject, PVOID DeviceContext, PUSBD_INTERFACE_INFORMATION Interface, PUSB_CONFIGURATION_DESCRIPTOR ConfigurationDescriptor, PLONG DataPipeIndex, PLONG SyncPipeIndex);
'' TODO: typedef NTSTATUS(NTAPI *PCAM_CONFIGURE_ROUTINE_EX)( PDEVICE_OBJECT BusDeviceObject, PVOID DeviceContext, PUSBD_INTERFACE_INFORMATION Interface, PUSB_CONFIGURATION_DESCRIPTOR ConfigurationDescriptor, ULONG PipeConfigListSize, PUSBCAMD_Pipe_Config_Descriptor PipeConfig, PUSB_DEVICE_DESCRIPTOR DeviceDescriptor);
'' TODO: typedef NTSTATUS(NTAPI *PCAM_START_CAPTURE_ROUTINE)( PDEVICE_OBJECT BusDeviceObject, PVOID DeviceContext);
'' TODO: typedef NTSTATUS(NTAPI *PCAM_START_CAPTURE_ROUTINE_EX)( PDEVICE_OBJECT BusDeviceObject, PVOID DeviceContext, ULONG StreamNumber);
'' TODO: typedef NTSTATUS(NTAPI *PCAM_ALLOCATE_BW_ROUTINE)( PDEVICE_OBJECT BusDeviceObject, PVOID DeviceContext, PULONG RawFrameLength, PVOID Format);
'' TODO: typedef NTSTATUS(NTAPI *PCAM_ALLOCATE_BW_ROUTINE_EX)( PDEVICE_OBJECT BusDeviceObject, PVOID DeviceContext, PULONG RawFrameLength, PVOID Format, ULONG StreamNumber);
'' TODO: typedef NTSTATUS(NTAPI *PCAM_FREE_BW_ROUTINE)( PDEVICE_OBJECT BusDeviceObject, PVOID DeviceContext);
'' TODO: typedef NTSTATUS(NTAPI *PCAM_FREE_BW_ROUTINE_EX)( PDEVICE_OBJECT BusDeviceObject, PVOID DeviceContext, ULONG StreamNumber);
'' TODO: typedef VOID(NTAPI *PADAPTER_RECEIVE_PACKET_ROUTINE)( PHW_STREAM_REQUEST_BLOCK Srb);
'' TODO: typedef NTSTATUS(NTAPI *PCAM_STOP_CAPTURE_ROUTINE)( PDEVICE_OBJECT BusDeviceObject, PVOID DeviceContext);
'' TODO: typedef NTSTATUS(NTAPI *PCAM_STOP_CAPTURE_ROUTINE_EX)( PDEVICE_OBJECT BusDeviceObject, PVOID DeviceContext, ULONG StreamNumber);
'' TODO: typedef ULONG(NTAPI *PCAM_PROCESS_PACKET_ROUTINE)( PDEVICE_OBJECT BusDeviceObject, PVOID DeviceContext, PVOID CurrentFrameContext, PUSBD_ISO_PACKET_DESCRIPTOR SyncPacket, PVOID SyncBuffer, PUSBD_ISO_PACKET_DESCRIPTOR DataPacket, PVOID DataBuffer, PBOOLEAN FrameComplete, PBOOLEAN NextFrameIsStill);
'' TODO: typedef ULONG(NTAPI *PCAM_PROCESS_PACKET_ROUTINE_EX)( PDEVICE_OBJECT BusDeviceObject, PVOID DeviceContext, PVOID CurrentFrameContext, PUSBD_ISO_PACKET_DESCRIPTOR SyncPacket, PVOID SyncBuffer, PUSBD_ISO_PACKET_DESCRIPTOR DataPacket, PVOID DataBuffer, PBOOLEAN FrameComplete, PULONG PacketFlag, PULONG ValidDataOffset);
'' TODO: typedef VOID(NTAPI *PCAM_NEW_FRAME_ROUTINE)( PVOID DeviceContext, PVOID FrameContext);
'' TODO: typedef VOID(NTAPI *PCAM_NEW_FRAME_ROUTINE_EX)( PVOID DeviceContext, PVOID FrameContext, ULONG StreamNumber, PULONG FrameLength);
'' TODO: typedef NTSTATUS(NTAPI *PCAM_PROCESS_RAW_FRAME_ROUTINE)( PDEVICE_OBJECT BusDeviceObject, PVOID DeviceContext, PVOID FrameContext, PVOID FrameBuffer, ULONG FrameLength, PVOID RawFrameBuffer, ULONG RawFrameLength, ULONG NumberOfPackets, PULONG BytesReturned);
'' TODO: typedef NTSTATUS(NTAPI *PCAM_PROCESS_RAW_FRAME_ROUTINE_EX)( PDEVICE_OBJECT BusDeviceObject, PVOID DeviceContext, PVOID FrameContext, PVOID FrameBuffer, ULONG FrameLength, PVOID RawFrameBuffer, ULONG RawFrameLength, ULONG NumberOfPackets, PULONG BytesReturned, ULONG ActualRawFrameLength, ULONG StreamNumber);
'' TODO: typedef NTSTATUS(NTAPI *PCAM_STATE_ROUTINE)( PDEVICE_OBJECT BusDeviceObject, PVOID DeviceContext);
#define ILOGENTRY(sig, info1, info2, info3)

type _USBCAMD_DEVICE_DATA
	Sig as ULONG
	CamInitialize as PCAM_INITIALIZE_ROUTINE
	CamUnInitialize as PCAM_INITIALIZE_ROUTINE
	CamProcessUSBPacket as PCAM_PROCESS_PACKET_ROUTINE
	CamNewVideoFrame as PCAM_NEW_FRAME_ROUTINE
	CamProcessRawVideoFrame as PCAM_PROCESS_RAW_FRAME_ROUTINE
	CamStartCapture as PCAM_START_CAPTURE_ROUTINE
	CamStopCapture as PCAM_STOP_CAPTURE_ROUTINE
	CamConfigure as PCAM_CONFIGURE_ROUTINE
	CamSaveState as PCAM_STATE_ROUTINE
	CamRestoreState as PCAM_STATE_ROUTINE
	CamAllocateBandwidth as PCAM_ALLOCATE_BW_ROUTINE
	CamFreeBandwidth as PCAM_FREE_BW_ROUTINE
end type

type USBCAMD_DEVICE_DATA as _USBCAMD_DEVICE_DATA
type PUSBCAMD_DEVICE_DATA as _USBCAMD_DEVICE_DATA ptr

type _USBCAMD_DEVICE_DATA2
	Sig as ULONG
	CamInitialize as PCAM_INITIALIZE_ROUTINE
	CamUnInitialize as PCAM_INITIALIZE_ROUTINE
	CamProcessUSBPacketEx as PCAM_PROCESS_PACKET_ROUTINE_EX
	CamNewVideoFrameEx as PCAM_NEW_FRAME_ROUTINE_EX
	CamProcessRawVideoFrameEx as PCAM_PROCESS_RAW_FRAME_ROUTINE_EX
	CamStartCaptureEx as PCAM_START_CAPTURE_ROUTINE_EX
	CamStopCaptureEx as PCAM_STOP_CAPTURE_ROUTINE_EX
	CamConfigureEx as PCAM_CONFIGURE_ROUTINE_EX
	CamSaveState as PCAM_STATE_ROUTINE
	CamRestoreState as PCAM_STATE_ROUTINE
	CamAllocateBandwidthEx as PCAM_ALLOCATE_BW_ROUTINE_EX
	CamFreeBandwidthEx as PCAM_FREE_BW_ROUTINE_EX
end type

type USBCAMD_DEVICE_DATA2 as _USBCAMD_DEVICE_DATA2
type PUSBCAMD_DEVICE_DATA2 as _USBCAMD_DEVICE_DATA2 ptr
'' TODO: DEFINE_GUID(GUID_USBCAMD_INTERFACE, 0x2bcb75c0, 0xb27f, 0x11d1, 0xba, 0x41, 0x0, 0xa0, 0xc9, 0xd, 0x2b, 0x5);
'' TODO: typedef NTSTATUS(NTAPI *PFNUSBCAMD_SetVideoFormat)( PVOID DeviceContext, PHW_STREAM_REQUEST_BLOCK pSrb);
'' TODO: typedef NTSTATUS(NTAPI *PFNUSBCAMD_WaitOnDeviceEvent)( PVOID DeviceContext, ULONG PipeIndex, PVOID Buffer, ULONG BufferLength, PCOMMAND_COMPLETE_FUNCTION EventComplete, PVOID EventContext, BOOLEAN LoopBack);
'' TODO: typedef NTSTATUS(NTAPI *PFNUSBCAMD_CancelBulkReadWrite)( PVOID DeviceContext, ULONG PipeIndex);
'' TODO: typedef NTSTATUS(NTAPI *PFNUSBCAMD_SetIsoPipeState)( PVOID DeviceContext, ULONG PipeStateFlags);
'' TODO: typedef NTSTATUS(NTAPI *PFNUSBCAMD_BulkReadWrite)( PVOID DeviceContext, USHORT PipeIndex, PVOID Buffer, ULONG BufferLength, PCOMMAND_COMPLETE_FUNCTION CommandComplete, PVOID CommandContext);
const USBCAMD_VERSION_200 = &h200

type _USBCAMD_INTERFACE
	Interface as INTERFACE
	USBCAMD_WaitOnDeviceEvent as PFNUSBCAMD_WaitOnDeviceEvent
	USBCAMD_BulkReadWrite as PFNUSBCAMD_BulkReadWrite
	USBCAMD_SetVideoFormat as PFNUSBCAMD_SetVideoFormat
	USBCAMD_SetIsoPipeState as PFNUSBCAMD_SetIsoPipeState
	USBCAMD_CancelBulkReadWrite as PFNUSBCAMD_CancelBulkReadWrite
end type

type USBCAMD_INTERFACE as _USBCAMD_INTERFACE
type PUSBCAMD_INTERFACE as _USBCAMD_INTERFACE ptr
'' TODO: DECLSPEC_IMPORT ULONG NTAPI USBCAMD_DriverEntry( PVOID Context1, PVOID Context2, ULONG DeviceContextSize, ULONG FrameContextSize, PADAPTER_RECEIVE_PACKET_ROUTINE ReceivePacket);
'' TODO: DECLSPEC_IMPORT PVOID NTAPI USBCAMD_AdapterReceivePacket( PHW_STREAM_REQUEST_BLOCK Srb, PUSBCAMD_DEVICE_DATA DeviceData, PDEVICE_OBJECT *DeviceObject, BOOLEAN NeedsCompletion);
'' TODO: DECLSPEC_IMPORT NTSTATUS NTAPI USBCAMD_ControlVendorCommand( PVOID DeviceContext, UCHAR Request, USHORT Value, USHORT Index, PVOID Buffer, PULONG BufferLength, BOOLEAN GetData, PCOMMAND_COMPLETE_FUNCTION CommandComplete, PVOID CommandContext);
'' TODO: DECLSPEC_IMPORT NTSTATUS NTAPI USBCAMD_SelectAlternateInterface( PVOID DeviceContext, PUSBD_INTERFACE_INFORMATION RequestInterface);
'' TODO: DECLSPEC_IMPORT NTSTATUS NTAPI USBCAMD_GetRegistryKeyValue( HANDLE Handle, PWCHAR KeyNameString, ULONG KeyNameStringLength, PVOID Data, ULONG DataLength);
'' TODO: DECLSPEC_IMPORT ULONG NTAPI USBCAMD_InitializeNewInterface( PVOID DeviceContext, PVOID DeviceData, ULONG Version, ULONG CamControlFlag);
