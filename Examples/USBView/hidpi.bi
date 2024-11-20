#pragma once

#include once "winapifamily.bi"
#include once "pshpack4.bi"
#include once "poppack.bi"

extern "C"

#define __HIDPI_H__
#define HIDP_LINK_COLLECTION_ROOT (USHORT - 1)
'' TODO: #define HIDP_LINK_COLLECTION_UNSPECIFIED ((USHORT) 0)
#define HidP_IsSameUsageAndPage(u1, u2) ((*(PULONG and u1)) = (*(PULONG and u2)))
#define HidP_SetButtons(Rty, Up, Lco, ULi, ULe, Ppd, Rep, Rle) HidP_SetUsages(Rty, Up, Lco, ULi, ULe, Ppd, Rep, Rle)
#define HidP_UnsetButtons(Rty, Up, Lco, ULi, ULe, Ppd, Rep, Rle) HidP_UnsetUsages(Rty, Up, Lco, ULi, ULe, Ppd, Rep, Rle)
#define HidP_GetButtons(Rty, UPa, LCo, ULi, ULe, Ppd, Rep, RLe) HidP_GetUsages(Rty, UPa, LCo, ULi, ULe, Ppd, Rep, RLe)
#define HidP_GetButtonsEx(Rty, LCo, BLi, ULe, Ppd, Rep, RLe) HidP_GetUsagesEx(Rty, LCo, BLi, ULe, Ppd, Rep, RLe)
type PHIDP_REPORT_DESCRIPTOR as PUCHAR
type PHIDP_PREPARSED_DATA as _HIDP_PREPARSED_DATA ptr

type _HIDP_REPORT_TYPE as long
enum
	HidP_Input
	HidP_Output
	HidP_Feature
end enum

type HIDP_REPORT_TYPE as _HIDP_REPORT_TYPE

type _USAGE_AND_PAGE
	Usage as USAGE
	UsagePage as USAGE
end type

type USAGE_AND_PAGE as _USAGE_AND_PAGE
type PUSAGE_AND_PAGE as _USAGE_AND_PAGE ptr

type _HIDP_BUTTON_CAPS
	UsagePage as USAGE
	ReportID as UCHAR
	IsAlias as BOOLEAN
	BitField as USHORT
	LinkCollection as USHORT
	LinkUsage as USAGE
	LinkUsagePage as USAGE
	IsRange as BOOLEAN
	IsStringRange as BOOLEAN
	IsDesignatorRange as BOOLEAN
	IsAbsolute as BOOLEAN
	Reserved(0 to 9) as ULONG
	'' TODO: __C89_NAMELESS union { struct { USAGE UsageMin, UsageMax; USHORT StringMin, StringMax; USHORT DesignatorMin, DesignatorMax; USHORT DataIndexMin, DataIndexMax; } Range; struct { USAGE Usage, Reserved1; USHORT StringIndex, Reserved2; USHORT DesignatorIndex, Reserved3; USHORT DataIndex, Reserved4; } NotRange; };
end type

type HIDP_BUTTON_CAPS as _HIDP_BUTTON_CAPS
type PHIDP_BUTTON_CAPS as _HIDP_BUTTON_CAPS ptr

type _HIDP_VALUE_CAPS
	UsagePage as USAGE
	ReportID as UCHAR
	IsAlias as BOOLEAN
	BitField as USHORT
	LinkCollection as USHORT
	LinkUsage as USAGE
	LinkUsagePage as USAGE
	IsRange as BOOLEAN
	IsStringRange as BOOLEAN
	IsDesignatorRange as BOOLEAN
	IsAbsolute as BOOLEAN
	HasNull as BOOLEAN
	Reserved as UCHAR
	BitSize as USHORT
	ReportCount as USHORT
	Reserved2(0 to 4) as USHORT
	UnitsExp as ULONG
	Units as ULONG
	LogicalMin as LONG
	LogicalMax as LONG
	PhysicalMin as LONG
	PhysicalMax as LONG
	'' TODO: __C89_NAMELESS union { struct { USAGE UsageMin, UsageMax; USHORT StringMin, StringMax; USHORT DesignatorMin, DesignatorMax; USHORT DataIndexMin, DataIndexMax; } Range; struct { USAGE Usage, Reserved1; USHORT StringIndex, Reserved2; USHORT DesignatorIndex, Reserved3; USHORT DataIndex, Reserved4; } NotRange; };
end type

type HIDP_VALUE_CAPS as _HIDP_VALUE_CAPS
type PHIDP_VALUE_CAPS as _HIDP_VALUE_CAPS ptr

type _HIDP_LINK_COLLECTION_NODE
	LinkUsage as USAGE
	LinkUsagePage as USAGE
	Parent as USHORT
	NumberOfChildren as USHORT
	NextSibling as USHORT
	FirstChild as USHORT
	CollectionType : 8 as ULONG
	IsAlias : 1 as ULONG
	Reserved : 23 as ULONG
	UserContext as PVOID
end type

type HIDP_LINK_COLLECTION_NODE as _HIDP_LINK_COLLECTION_NODE
type PHIDP_LINK_COLLECTION_NODE as _HIDP_LINK_COLLECTION_NODE ptr

type _HIDP_CAPS
	Usage as USAGE
	UsagePage as USAGE
	InputReportByteLength as USHORT
	OutputReportByteLength as USHORT
	FeatureReportByteLength as USHORT
	Reserved(0 to 16) as USHORT
	NumberLinkCollectionNodes as USHORT
	NumberInputButtonCaps as USHORT
	NumberInputValueCaps as USHORT
	NumberInputDataIndices as USHORT
	NumberOutputButtonCaps as USHORT
	NumberOutputValueCaps as USHORT
	NumberOutputDataIndices as USHORT
	NumberFeatureButtonCaps as USHORT
	NumberFeatureValueCaps as USHORT
	NumberFeatureDataIndices as USHORT
end type

type HIDP_CAPS as _HIDP_CAPS
type PHIDP_CAPS as _HIDP_CAPS ptr

type _HIDP_DATA
	DataIndex as USHORT
	Reserved as USHORT
	'' TODO: __C89_NAMELESS union { ULONG RawValue; BOOLEAN On; };
end type

type HIDP_DATA as _HIDP_DATA
type PHIDP_DATA as _HIDP_DATA ptr

type _HIDP_UNKNOWN_TOKEN
	Token as UCHAR
	Reserved(0 to 2) as UCHAR
	BitField as ULONG
end type

type HIDP_UNKNOWN_TOKEN as _HIDP_UNKNOWN_TOKEN
type PHIDP_UNKNOWN_TOKEN as _HIDP_UNKNOWN_TOKEN ptr

type _HIDP_EXTENDED_ATTRIBUTES
	NumGlobalUnknowns as UCHAR
	Reserved(0 to 2) as UCHAR
	GlobalUnknowns as PHIDP_UNKNOWN_TOKEN
	Data(0 to 0) as ULONG
end type

type HIDP_EXTENDED_ATTRIBUTES as _HIDP_EXTENDED_ATTRIBUTES
type PHIDP_EXTENDED_ATTRIBUTES as _HIDP_EXTENDED_ATTRIBUTES ptr

type _HIDP_KEYBOARD_DIRECTION as long
enum
	HidP_Keyboard_Break
	HidP_Keyboard_Make
end enum

type HIDP_KEYBOARD_DIRECTION as _HIDP_KEYBOARD_DIRECTION

type _HIDP_KEYBOARD_MODIFIER_STATE
	'' TODO: __C89_NAMELESS union { struct { ULONG LeftControl: 1; ULONG LeftShift: 1; ULONG LeftAlt: 1; ULONG LeftGUI: 1; ULONG RightControl: 1; ULONG RightShift: 1; ULONG RightAlt: 1; ULONG RigthGUI: 1; ULONG CapsLock: 1; ULONG ScollLock: 1; ULONG NumLock: 1; ULONG Reserved: 21; }; ULONG ul; };
end type

type HIDP_KEYBOARD_MODIFIER_STATE as _HIDP_KEYBOARD_MODIFIER_STATE
type PHIDP_KEYBOARD_MODIFIER_STATE as _HIDP_KEYBOARD_MODIFIER_STATE ptr
type PHIDP_INSERT_SCANCODES as function(byval Context as PVOID, byval NewScanCodes as PCHAR, byval Length as ULONG) as BOOLEAN

'' TODO: NTSTATUS NTAPI HidP_GetCaps (PHIDP_PREPARSED_DATA PreparsedData, PHIDP_CAPS Capabilities);
'' TODO: NTSTATUS NTAPI HidP_GetLinkCollectionNodes (PHIDP_LINK_COLLECTION_NODE LinkCollectionNodes, PULONG LinkCollectionNodesLength, PHIDP_PREPARSED_DATA PreparsedData);
'' TODO: NTSTATUS NTAPI HidP_GetSpecificButtonCaps (HIDP_REPORT_TYPE ReportType, USAGE UsagePage, USHORT LinkCollection, USAGE Usage, PHIDP_BUTTON_CAPS ButtonCaps, PUSHORT ButtonCapsLength, PHIDP_PREPARSED_DATA PreparsedData);
'' TODO: NTSTATUS NTAPI HidP_GetButtonCaps (HIDP_REPORT_TYPE ReportType, PHIDP_BUTTON_CAPS ButtonCaps, PUSHORT ButtonCapsLength, PHIDP_PREPARSED_DATA PreparsedData);
'' TODO: NTSTATUS NTAPI HidP_GetSpecificValueCaps (HIDP_REPORT_TYPE ReportType, USAGE UsagePage, USHORT LinkCollection, USAGE Usage, PHIDP_VALUE_CAPS ValueCaps, PUSHORT ValueCapsLength, PHIDP_PREPARSED_DATA PreparsedData);
'' TODO: NTSTATUS NTAPI HidP_GetValueCaps (HIDP_REPORT_TYPE ReportType, PHIDP_VALUE_CAPS ValueCaps, PUSHORT ValueCapsLength, PHIDP_PREPARSED_DATA PreparsedData);
'' TODO: NTSTATUS NTAPI HidP_GetExtendedAttributes (HIDP_REPORT_TYPE ReportType, USHORT DataIndex, PHIDP_PREPARSED_DATA PreparsedData, PHIDP_EXTENDED_ATTRIBUTES Attributes, PULONG LengthAttributes);
'' TODO: NTSTATUS NTAPI HidP_InitializeReportForID (HIDP_REPORT_TYPE ReportType, UCHAR ReportID, PHIDP_PREPARSED_DATA PreparsedData, PCHAR Report, ULONG ReportLength);
'' TODO: NTSTATUS NTAPI HidP_SetData (HIDP_REPORT_TYPE ReportType, PHIDP_DATA DataList, PULONG DataLength, PHIDP_PREPARSED_DATA PreparsedData, PCHAR Report, ULONG ReportLength);
'' TODO: NTSTATUS NTAPI HidP_GetData (HIDP_REPORT_TYPE ReportType, PHIDP_DATA DataList, PULONG DataLength, PHIDP_PREPARSED_DATA PreparsedData, PCHAR Report, ULONG ReportLength);
'' TODO: ULONG NTAPI HidP_MaxDataListLength (HIDP_REPORT_TYPE ReportType, PHIDP_PREPARSED_DATA PreparsedData);
'' TODO: NTSTATUS NTAPI HidP_SetUsages (HIDP_REPORT_TYPE ReportType, USAGE UsagePage, USHORT LinkCollection, PUSAGE UsageList, PULONG UsageLength, PHIDP_PREPARSED_DATA PreparsedData, PCHAR Report, ULONG ReportLength);
'' TODO: NTSTATUS NTAPI HidP_UnsetUsages (HIDP_REPORT_TYPE ReportType, USAGE UsagePage, USHORT LinkCollection, PUSAGE UsageList, PULONG UsageLength, PHIDP_PREPARSED_DATA PreparsedData, PCHAR Report, ULONG ReportLength);
'' TODO: NTSTATUS NTAPI HidP_GetUsages (HIDP_REPORT_TYPE ReportType, USAGE UsagePage, USHORT LinkCollection, PUSAGE UsageList, PULONG UsageLength, PHIDP_PREPARSED_DATA PreparsedData, PCHAR Report, ULONG ReportLength);
'' TODO: NTSTATUS NTAPI HidP_GetUsagesEx (HIDP_REPORT_TYPE ReportType, USHORT LinkCollection, PUSAGE_AND_PAGE ButtonList, ULONG *UsageLength, PHIDP_PREPARSED_DATA PreparsedData, PCHAR Report, ULONG ReportLength);
'' TODO: ULONG NTAPI HidP_MaxUsageListLength (HIDP_REPORT_TYPE ReportType, USAGE UsagePage, PHIDP_PREPARSED_DATA PreparsedData);
'' TODO: NTSTATUS NTAPI HidP_SetUsageValue (HIDP_REPORT_TYPE ReportType, USAGE UsagePage, USHORT LinkCollection, USAGE Usage, ULONG UsageValue, PHIDP_PREPARSED_DATA PreparsedData, PCHAR Report, ULONG ReportLength);
'' TODO: NTSTATUS NTAPI HidP_SetScaledUsageValue (HIDP_REPORT_TYPE ReportType, USAGE UsagePage, USHORT LinkCollection, USAGE Usage, LONG UsageValue, PHIDP_PREPARSED_DATA PreparsedData, PCHAR Report, ULONG ReportLength);
'' TODO: NTSTATUS NTAPI HidP_SetUsageValueArray (HIDP_REPORT_TYPE ReportType, USAGE UsagePage, USHORT LinkCollection, USAGE Usage, PCHAR UsageValue, USHORT UsageValueByteLength, PHIDP_PREPARSED_DATA PreparsedData, PCHAR Report, ULONG ReportLength);
'' TODO: NTSTATUS NTAPI HidP_GetUsageValue (HIDP_REPORT_TYPE ReportType, USAGE UsagePage, USHORT LinkCollection, USAGE Usage, PULONG UsageValue, PHIDP_PREPARSED_DATA PreparsedData, PCHAR Report, ULONG ReportLength);
'' TODO: NTSTATUS NTAPI HidP_GetScaledUsageValue (HIDP_REPORT_TYPE ReportType, USAGE UsagePage, USHORT LinkCollection, USAGE Usage, PLONG UsageValue, PHIDP_PREPARSED_DATA PreparsedData, PCHAR Report, ULONG ReportLength);
'' TODO: NTSTATUS NTAPI HidP_GetUsageValueArray (HIDP_REPORT_TYPE ReportType, USAGE UsagePage, USHORT LinkCollection, USAGE Usage, PCHAR UsageValue, USHORT UsageValueByteLength, PHIDP_PREPARSED_DATA PreparsedData, PCHAR Report, ULONG ReportLength);
'' TODO: NTSTATUS NTAPI HidP_UsageListDifference (PUSAGE PreviousUsageList, PUSAGE CurrentUsageList, PUSAGE BreakUsageList, PUSAGE MakeUsageList, ULONG UsageListLength);
'' TODO: NTSTATUS NTAPI HidP_UsageAndPageListDifference (PUSAGE_AND_PAGE PreviousUsageList, PUSAGE_AND_PAGE CurrentUsageList, PUSAGE_AND_PAGE BreakUsageList, PUSAGE_AND_PAGE MakeUsageList, ULONG UsageListLength);
'' TODO: NTSTATUS NTAPI HidP_TranslateUsageAndPagesToI8042ScanCodes (PUSAGE_AND_PAGE ChangedUsageList, ULONG UsageListLength, HIDP_KEYBOARD_DIRECTION KeyAction, PHIDP_KEYBOARD_MODIFIER_STATE ModifierState, PHIDP_INSERT_SCANCODES InsertCodesProcedure, PVOID InsertCodesContext);
'' TODO: NTSTATUS NTAPI HidP_TranslateUsagesToI8042ScanCodes (PUSAGE ChangedUsageList, ULONG UsageListLength, HIDP_KEYBOARD_DIRECTION KeyAction, PHIDP_KEYBOARD_MODIFIER_STATE ModifierState, PHIDP_INSERT_SCANCODES InsertCodesProcedure, PVOID InsertCodesContext);

const FACILITY_HID_ERROR_CODE = &h11
#define HIDP_ERROR_CODES(SEV, CODE) NTSTATUS((((SEV) shl 28) or (FACILITY_HID_ERROR_CODE shl 16)) or (CODE))
#define HIDP_STATUS_SUCCESS HIDP_ERROR_CODES(&h0, 0)
#define HIDP_STATUS_NULL HIDP_ERROR_CODES(&h8, 1)
#define HIDP_STATUS_INVALID_PREPARSED_DATA HIDP_ERROR_CODES(&hc, 1)
#define HIDP_STATUS_INVALID_REPORT_TYPE HIDP_ERROR_CODES(&hc, 2)
#define HIDP_STATUS_INVALID_REPORT_LENGTH HIDP_ERROR_CODES(&hc, 3)
#define HIDP_STATUS_USAGE_NOT_FOUND HIDP_ERROR_CODES(&hc, 4)
#define HIDP_STATUS_VALUE_OUT_OF_RANGE HIDP_ERROR_CODES(&hc, 5)
#define HIDP_STATUS_BAD_LOG_PHY_VALUES HIDP_ERROR_CODES(&hc, 6)
#define HIDP_STATUS_BUFFER_TOO_SMALL HIDP_ERROR_CODES(&hc, 7)
#define HIDP_STATUS_INTERNAL_ERROR HIDP_ERROR_CODES(&hc, 8)
#define HIDP_STATUS_I8042_TRANS_UNKNOWN HIDP_ERROR_CODES(&hc, 9)
#define HIDP_STATUS_INCOMPATIBLE_REPORT_ID HIDP_ERROR_CODES(&hc, &ha)
#define HIDP_STATUS_NOT_VALUE_ARRAY HIDP_ERROR_CODES(&hc, &hb)
#define HIDP_STATUS_IS_VALUE_ARRAY HIDP_ERROR_CODES(&hc, &hc)
#define HIDP_STATUS_DATA_INDEX_NOT_FOUND HIDP_ERROR_CODES(&hc, &hd)
#define HIDP_STATUS_DATA_INDEX_OUT_OF_RANGE HIDP_ERROR_CODES(&hc, &he)
#define HIDP_STATUS_BUTTON_NOT_PRESSED HIDP_ERROR_CODES(&hc, &hf)
#define HIDP_STATUS_REPORT_DOES_NOT_EXIST HIDP_ERROR_CODES(&hc, &h10)
#define HIDP_STATUS_NOT_IMPLEMENTED HIDP_ERROR_CODES(&hc, &h20)
#define HIDP_STATUS_I8242_TRANS_UNKNOWN HIDP_STATUS_I8042_TRANS_UNKNOWN

end extern
