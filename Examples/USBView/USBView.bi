'USBView.bi
' Copyright (c) 2025 CM.Wang
' Freeware. Use at your own risk.

'https://developer.microsoft.com/windows/downloads/windows-sdk/
'https://github.com/Microsoft/Windows-driver-samples/tree/main/usb/usbview
'https://learn.microsoft.com/en-us/windows-hardware/drivers/ddi/_image/#ioctls

'PowerBasic USB digger for Windows by Pierre Bellisle 2011-10-28 18h57

#include once "vbcompat.bi"
#include once "windows.bi"
#include once "crt.bi"
#include once "win/setupapi.bi"
#include once "win/basetyps.bi"
#include once "win/winioctl.bi"
#include once "win/ole2.bi"

#include once "usbioctl.bi"
#include once "usbiodef.bi"

#include once "mff/Form.bi"
#include once "mff/TreeView.bi"
#include once "mff/TextBox.bi"

Using My.Sys.Forms

Type HID_DESCRIPTOR_DESC_LIST
	bReportType   As UCHAR
	wReportLength As UShort
End Type

Type HID_DESCRIPTOR
	bLength             As UCHAR
	bDescriptorType     As UCHAR
	bcdHID              As UShort
	bCountry            As UCHAR
	bNumDescriptors     As UCHAR
	DescriptorList(0)   As HID_DESCRIPTOR_DESC_LIST
End Type

Const UsbIdTxtFile = "Usb-id.txt"
Dim Shared LanguageIdArray(Any) As WORD
Dim Shared usbMsgIndex As Integer = -1
Dim Shared usbMessage(Any) As WString Ptr
Dim Shared usbTempTxt(Any) As WString Ptr
Dim Shared usbTmpIndex As Integer = -1

#ifndef __USE_MAKE__
	#include once "USBView.bas"
#endif

