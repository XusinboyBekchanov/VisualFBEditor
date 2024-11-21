#pragma once

#include once "winapifamily.bi"
#include once "pshpack4.bi"
#include once "poppack.bi"

extern "C"

#define _HIDSDI_H
type NTSTATUS as LONG
#define __HIDUSAGE_H__
#define HID_USAGE_PAGE_UNDEFINED cast(USAGE, &h00)
#define HID_USAGE_PAGE_GENERIC cast(USAGE, &h01)
#define HID_USAGE_PAGE_SIMULATION cast(USAGE, &h02)
#define HID_USAGE_PAGE_VR cast(USAGE, &h03)
#define HID_USAGE_PAGE_SPORT cast(USAGE, &h04)
#define HID_USAGE_PAGE_GAME cast(USAGE, &h05)
#define HID_USAGE_PAGE_KEYBOARD cast(USAGE, &h07)
#define HID_USAGE_PAGE_LED cast(USAGE, &h08)
#define HID_USAGE_PAGE_BUTTON cast(USAGE, &h09)
#define HID_USAGE_PAGE_ORDINAL cast(USAGE, &h0a)
#define HID_USAGE_PAGE_TELEPHONY cast(USAGE, &h0b)
#define HID_USAGE_PAGE_CONSUMER cast(USAGE, &h0c)
#define HID_USAGE_PAGE_DIGITIZER cast(USAGE, &h0d)
#define HID_USAGE_PAGE_UNICODE cast(USAGE, &h10)
#define HID_USAGE_PAGE_ALPHANUMERIC cast(USAGE, &h14)
#define HID_USAGE_PAGE_MICROSOFT_BLUETOOTH_HANDSFREE cast(USAGE, &hfff3)
#define HID_USAGE_GENERIC_POINTER cast(USAGE, &h01)
#define HID_USAGE_GENERIC_MOUSE cast(USAGE, &h02)
#define HID_USAGE_GENERIC_JOYSTICK cast(USAGE, &h04)
#define HID_USAGE_GENERIC_GAMEPAD cast(USAGE, &h05)
#define HID_USAGE_GENERIC_KEYBOARD cast(USAGE, &h06)
#define HID_USAGE_GENERIC_KEYPAD cast(USAGE, &h07)
#define HID_USAGE_GENERIC_SYSTEM_CTL cast(USAGE, &h80)
#define HID_USAGE_GENERIC_X cast(USAGE, &h30)
#define HID_USAGE_GENERIC_Y cast(USAGE, &h31)
#define HID_USAGE_GENERIC_Z cast(USAGE, &h32)
#define HID_USAGE_GENERIC_RX cast(USAGE, &h33)
#define HID_USAGE_GENERIC_RY cast(USAGE, &h34)
#define HID_USAGE_GENERIC_RZ cast(USAGE, &h35)
#define HID_USAGE_GENERIC_SLIDER cast(USAGE, &h36)
#define HID_USAGE_GENERIC_DIAL cast(USAGE, &h37)
#define HID_USAGE_GENERIC_WHEEL cast(USAGE, &h38)
#define HID_USAGE_GENERIC_HATSWITCH cast(USAGE, &h39)
#define HID_USAGE_GENERIC_COUNTED_BUFFER cast(USAGE, &h3a)
#define HID_USAGE_GENERIC_BYTE_COUNT cast(USAGE, &h3b)
#define HID_USAGE_GENERIC_MOTION_WAKEUP cast(USAGE, &h3c)
#define HID_USAGE_GENERIC_VX cast(USAGE, &h40)
#define HID_USAGE_GENERIC_VY cast(USAGE, &h41)
#define HID_USAGE_GENERIC_VZ cast(USAGE, &h42)
#define HID_USAGE_GENERIC_VBRX cast(USAGE, &h43)
#define HID_USAGE_GENERIC_VBRY cast(USAGE, &h44)
#define HID_USAGE_GENERIC_VBRZ cast(USAGE, &h45)
#define HID_USAGE_GENERIC_VNO cast(USAGE, &h46)
#define HID_USAGE_GENERIC_SYSCTL_POWER cast(USAGE, &h81)
#define HID_USAGE_GENERIC_SYSCTL_SLEEP cast(USAGE, &h82)
#define HID_USAGE_GENERIC_SYSCTL_WAKE cast(USAGE, &h83)
#define HID_USAGE_GENERIC_SYSCTL_CONTEXT_MENU cast(USAGE, &h84)
#define HID_USAGE_GENERIC_SYSCTL_MAIN_MENU cast(USAGE, &h85)
#define HID_USAGE_GENERIC_SYSCTL_APP_MENU cast(USAGE, &h86)
#define HID_USAGE_GENERIC_SYSCTL_HELP_MENU cast(USAGE, &h87)
#define HID_USAGE_GENERIC_SYSCTL_MENU_EXIT cast(USAGE, &h88)
#define HID_USAGE_GENERIC_SYSCTL_MENU_SELECT cast(USAGE, &h89)
#define HID_USAGE_GENERIC_SYSCTL_MENU_RIGHT cast(USAGE, &h8a)
#define HID_USAGE_GENERIC_SYSCTL_MENU_LEFT cast(USAGE, &h8b)
#define HID_USAGE_GENERIC_SYSCTL_MENU_UP cast(USAGE, &h8c)
#define HID_USAGE_GENERIC_SYSCTL_MENU_DOWN cast(USAGE, &h8d)
#define HID_USAGE_SIMULATION_RUDDER cast(USAGE, &hba)
#define HID_USAGE_SIMULATION_THROTTLE cast(USAGE, &hbb)
#define HID_USAGE_KEYBOARD_NOEVENT cast(USAGE, &h00)
#define HID_USAGE_KEYBOARD_ROLLOVER cast(USAGE, &h01)
#define HID_USAGE_KEYBOARD_POSTFAIL cast(USAGE, &h02)
#define HID_USAGE_KEYBOARD_UNDEFINED cast(USAGE, &h03)
#define HID_USAGE_KEYBOARD_aA cast(USAGE, &h04)
#define HID_USAGE_KEYBOARD_zZ cast(USAGE, &h1d)
#define HID_USAGE_KEYBOARD_ONE cast(USAGE, &h1e)
#define HID_USAGE_KEYBOARD_ZERO cast(USAGE, &h27)
#define HID_USAGE_KEYBOARD_LCTRL cast(USAGE, &he0)
#define HID_USAGE_KEYBOARD_LSHFT cast(USAGE, &he1)
#define HID_USAGE_KEYBOARD_LALT cast(USAGE, &he2)
#define HID_USAGE_KEYBOARD_LGUI cast(USAGE, &he3)
#define HID_USAGE_KEYBOARD_RCTRL cast(USAGE, &he4)
#define HID_USAGE_KEYBOARD_RSHFT cast(USAGE, &he5)
#define HID_USAGE_KEYBOARD_RALT cast(USAGE, &he6)
#define HID_USAGE_KEYBOARD_RGUI cast(USAGE, &he7)
#define HID_USAGE_KEYBOARD_SCROLL_LOCK cast(USAGE, &h47)
#define HID_USAGE_KEYBOARD_NUM_LOCK cast(USAGE, &h53)
#define HID_USAGE_KEYBOARD_CAPS_LOCK cast(USAGE, &h39)
#define HID_USAGE_KEYBOARD_F1 cast(USAGE, &h3a)
#define HID_USAGE_KEYBOARD_F12 cast(USAGE, &h45)
#define HID_USAGE_KEYBOARD_RETURN cast(USAGE, &h28)
#define HID_USAGE_KEYBOARD_ESCAPE cast(USAGE, &h29)
#define HID_USAGE_KEYBOARD_DELETE cast(USAGE, &h2a)
#define HID_USAGE_KEYBOARD_PRINT_SCREEN cast(USAGE, &h46)
#define HID_USAGE_LED_NUM_LOCK cast(USAGE, &h01)
#define HID_USAGE_LED_CAPS_LOCK cast(USAGE, &h02)
#define HID_USAGE_LED_SCROLL_LOCK cast(USAGE, &h03)
#define HID_USAGE_LED_COMPOSE cast(USAGE, &h04)
#define HID_USAGE_LED_KANA cast(USAGE, &h05)
#define HID_USAGE_LED_POWER cast(USAGE, &h06)
#define HID_USAGE_LED_SHIFT cast(USAGE, &h07)
#define HID_USAGE_LED_DO_NOT_DISTURB cast(USAGE, &h08)
#define HID_USAGE_LED_MUTE cast(USAGE, &h09)
#define HID_USAGE_LED_TONE_ENABLE cast(USAGE, &h0a)
#define HID_USAGE_LED_HIGH_CUT_FILTER cast(USAGE, &h0b)
#define HID_USAGE_LED_LOW_CUT_FILTER cast(USAGE, &h0c)
#define HID_USAGE_LED_EQUALIZER_ENABLE cast(USAGE, &h0d)
#define HID_USAGE_LED_SOUND_FIELD_ON cast(USAGE, &h0e)
#define HID_USAGE_LED_SURROUND_FIELD_ON cast(USAGE, &h0f)
#define HID_USAGE_LED_REPEAT cast(USAGE, &h10)
#define HID_USAGE_LED_STEREO cast(USAGE, &h11)
#define HID_USAGE_LED_SAMPLING_RATE_DETECT cast(USAGE, &h12)
#define HID_USAGE_LED_SPINNING cast(USAGE, &h13)
#define HID_USAGE_LED_CAV cast(USAGE, &h14)
#define HID_USAGE_LED_CLV cast(USAGE, &h15)
#define HID_USAGE_LED_RECORDING_FORMAT_DET cast(USAGE, &h16)
#define HID_USAGE_LED_OFF_HOOK cast(USAGE, &h17)
#define HID_USAGE_LED_RING cast(USAGE, &h18)
#define HID_USAGE_LED_MESSAGE_WAITING cast(USAGE, &h19)
#define HID_USAGE_LED_DATA_MODE cast(USAGE, &h1a)
#define HID_USAGE_LED_BATTERY_OPERATION cast(USAGE, &h1b)
#define HID_USAGE_LED_BATTERY_OK cast(USAGE, &h1c)
#define HID_USAGE_LED_BATTERY_LOW cast(USAGE, &h1d)
#define HID_USAGE_LED_SPEAKER cast(USAGE, &h1e)
#define HID_USAGE_LED_HEAD_SET cast(USAGE, &h1f)
#define HID_USAGE_LED_HOLD cast(USAGE, &h20)
#define HID_USAGE_LED_MICROPHONE cast(USAGE, &h21)
#define HID_USAGE_LED_COVERAGE cast(USAGE, &h22)
#define HID_USAGE_LED_NIGHT_MODE cast(USAGE, &h23)
#define HID_USAGE_LED_SEND_CALLS cast(USAGE, &h24)
#define HID_USAGE_LED_CALL_PICKUP cast(USAGE, &h25)
#define HID_USAGE_LED_CONFERENCE cast(USAGE, &h26)
#define HID_USAGE_LED_STAND_BY cast(USAGE, &h27)
#define HID_USAGE_LED_CAMERA_ON cast(USAGE, &h28)
#define HID_USAGE_LED_CAMERA_OFF cast(USAGE, &h29)
#define HID_USAGE_LED_ON_LINE cast(USAGE, &h2a)
#define HID_USAGE_LED_OFF_LINE cast(USAGE, &h2b)
#define HID_USAGE_LED_BUSY cast(USAGE, &h2c)
#define HID_USAGE_LED_READY cast(USAGE, &h2d)
#define HID_USAGE_LED_PAPER_OUT cast(USAGE, &h2e)
#define HID_USAGE_LED_PAPER_JAM cast(USAGE, &h2f)
#define HID_USAGE_LED_REMOTE cast(USAGE, &h30)
#define HID_USAGE_LED_FORWARD cast(USAGE, &h31)
#define HID_USAGE_LED_REVERSE cast(USAGE, &h32)
#define HID_USAGE_LED_STOP cast(USAGE, &h33)
#define HID_USAGE_LED_REWIND cast(USAGE, &h34)
#define HID_USAGE_LED_FAST_FORWARD cast(USAGE, &h35)
#define HID_USAGE_LED_PLAY cast(USAGE, &h36)
#define HID_USAGE_LED_PAUSE cast(USAGE, &h37)
#define HID_USAGE_LED_RECORD cast(USAGE, &h38)
#define HID_USAGE_LED_ERROR cast(USAGE, &h39)
#define HID_USAGE_LED_SELECTED_INDICATOR cast(USAGE, &h3a)
#define HID_USAGE_LED_IN_USE_INDICATOR cast(USAGE, &h3b)
#define HID_USAGE_LED_MULTI_MODE_INDICATOR cast(USAGE, &h3c)
#define HID_USAGE_LED_INDICATOR_ON cast(USAGE, &h3d)
#define HID_USAGE_LED_INDICATOR_FLASH cast(USAGE, &h3e)
#define HID_USAGE_LED_INDICATOR_SLOW_BLINK cast(USAGE, &h3f)
#define HID_USAGE_LED_INDICATOR_FAST_BLINK cast(USAGE, &h40)
#define HID_USAGE_LED_INDICATOR_OFF cast(USAGE, &h41)
#define HID_USAGE_LED_FLASH_ON_TIME cast(USAGE, &h42)
#define HID_USAGE_LED_SLOW_BLINK_ON_TIME cast(USAGE, &h43)
#define HID_USAGE_LED_SLOW_BLINK_OFF_TIME cast(USAGE, &h44)
#define HID_USAGE_LED_FAST_BLINK_ON_TIME cast(USAGE, &h45)
#define HID_USAGE_LED_FAST_BLINK_OFF_TIME cast(USAGE, &h46)
#define HID_USAGE_LED_INDICATOR_COLOR cast(USAGE, &h47)
#define HID_USAGE_LED_RED cast(USAGE, &h48)
#define HID_USAGE_LED_GREEN cast(USAGE, &h49)
#define HID_USAGE_LED_AMBER cast(USAGE, &h4a)
#define HID_USAGE_LED_GENERIC_INDICATOR cast(USAGE, &h4b)
#define HID_USAGE_TELEPHONY_PHONE cast(USAGE, &h01)
#define HID_USAGE_TELEPHONY_ANSWERING_MACHINE cast(USAGE, &h02)
#define HID_USAGE_TELEPHONY_MESSAGE_CONTROLS cast(USAGE, &h03)
#define HID_USAGE_TELEPHONY_HANDSET cast(USAGE, &h04)
#define HID_USAGE_TELEPHONY_HEADSET cast(USAGE, &h05)
#define HID_USAGE_TELEPHONY_KEYPAD cast(USAGE, &h06)
#define HID_USAGE_TELEPHONY_PROGRAMMABLE_BUTTON cast(USAGE, &h07)
#define HID_USAGE_TELEPHONY_REDIAL cast(USAGE, &h24)
#define HID_USAGE_TELEPHONY_TRANSFER cast(USAGE, &h25)
#define HID_USAGE_TELEPHONY_DROP cast(USAGE, &h26)
#define HID_USAGE_TELEPHONY_LINE cast(USAGE, &h2a)
#define HID_USAGE_TELEPHONY_RING_ENABLE cast(USAGE, &h2d)
#define HID_USAGE_TELEPHONY_SEND cast(USAGE, &h31)
#define HID_USAGE_TELEPHONY_KEYPAD_0 cast(USAGE, &hb0)
#define HID_USAGE_TELEPHONY_KEYPAD_D cast(USAGE, &hbf)
#define HID_USAGE_TELEPHONY_HOST_AVAILABLE cast(USAGE, &hf1)
#define HID_USAGE_MS_BTH_HF_DIALNUMBER cast(USAGE, &h21)
#define HID_USAGE_MS_BTH_HF_DIALMEMORY cast(USAGE, &h22)
#define HID_USAGE_CONSUMERCTRL cast(USAGE, &h01)
#define HID_USAGE_DIGITIZER_PEN cast(USAGE, &h02)
#define HID_USAGE_DIGITIZER_IN_RANGE cast(USAGE, &h32)
#define HID_USAGE_DIGITIZER_TIP_SWITCH cast(USAGE, &h42)
#define HID_USAGE_DIGITIZER_BARREL_SWITCH cast(USAGE, &h44)
type USAGE as USHORT
type PUSAGE as USHORT ptr
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
#define HIDP_ERROR_CODES(SEV, CODE) cast(NTSTATUS, (((SEV) shl 28) or (FACILITY_HID_ERROR_CODE shl 16)) or (CODE))
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

type _HIDD_CONFIGURATION
	cookie as PVOID
	size as ULONG
	RingBufferSize as ULONG
end type

type HIDD_CONFIGURATION as _HIDD_CONFIGURATION
type PHIDD_CONFIGURATION as _HIDD_CONFIGURATION ptr

type _HIDD_ATTRIBUTES
	Size as ULONG
	VendorID as USHORT
	ProductID as USHORT
	VersionNumber as USHORT
end type

type HIDD_ATTRIBUTES as _HIDD_ATTRIBUTES
type PHIDD_ATTRIBUTES as _HIDD_ATTRIBUTES ptr
'' TODO: BOOLEAN NTAPI HidD_FlushQueue (HANDLE HidDeviceObject);
'' TODO: BOOLEAN NTAPI HidD_FreePreparsedData (PHIDP_PREPARSED_DATA PreparsedData);
'' TODO: BOOLEAN NTAPI HidD_GetAttributes (HANDLE HidDeviceObject, PHIDD_ATTRIBUTES Attributes);
'' TODO: BOOLEAN NTAPI HidD_GetConfiguration (HANDLE HidDeviceObject, PHIDD_CONFIGURATION Configuration, ULONG ConfigurationLength);
'' TODO: BOOLEAN NTAPI HidD_GetFeature (HANDLE HidDeviceObject, PVOID ReportBuffer, ULONG ReportBufferLength);
'' TODO: void NTAPI HidD_GetHidGuid (LPGUID HidGuid);
'' TODO: BOOLEAN NTAPI HidD_GetInputReport (HANDLE HidDeviceObject, PVOID ReportBuffer, ULONG ReportBufferLength);
'' TODO: BOOLEAN NTAPI HidD_GetIndexedString (HANDLE HidDeviceObject, ULONG StringIndex, PVOID Buffer, ULONG BufferLength);
'' TODO: BOOLEAN NTAPI HidD_GetManufacturerString (HANDLE HidDeviceObject, PVOID Buffer, ULONG BufferLength);
'' TODO: BOOLEAN NTAPI HidD_GetMsGenreDescriptor (HANDLE HidDeviceObject, PVOID Buffer, ULONG BufferLength);
'' TODO: BOOLEAN NTAPI HidD_GetNumInputBuffers (HANDLE HidDeviceObject, PULONG NumberBuffers);
'' TODO: BOOLEAN NTAPI HidD_GetPhysicalDescriptor (HANDLE HidDeviceObject, PVOID Buffer, ULONG BufferLength);
'' TODO: BOOLEAN NTAPI HidD_GetPreparsedData (HANDLE HidDeviceObject, PHIDP_PREPARSED_DATA *PreparsedData);
'' TODO: BOOLEAN NTAPI HidD_GetProductString (HANDLE HidDeviceObject, PVOID Buffer, ULONG BufferLength);
'' TODO: BOOLEAN NTAPI HidD_GetSerialNumberString (HANDLE HidDeviceObject, PVOID Buffer, ULONG BufferLength);
'' TODO: BOOLEAN NTAPI HidD_SetConfiguration (HANDLE HidDeviceObject, PHIDD_CONFIGURATION Configuration, ULONG ConfigurationLength);
'' TODO: BOOLEAN NTAPI HidD_SetFeature (HANDLE HidDeviceObject, PVOID ReportBuffer, ULONG ReportBufferLength);
'' TODO: BOOLEAN NTAPI HidD_SetNumInputBuffers (HANDLE HidDeviceObject, ULONG NumberBuffers);
'' TODO: BOOLEAN NTAPI HidD_SetOutputReport (HANDLE HidDeviceObject, PVOID ReportBuffer, ULONG ReportBufferLength);

end extern
