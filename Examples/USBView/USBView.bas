'USBView.bi
' Copyright (c) 2025 CM.Wang
' Freeware. Use at your own risk.

#include once "USBView.bi"

Private Function MAK16(lowByte As UByte, highByte As UByte) As UShort
	Return (highByte Shl 8) Or lowByte
End Function

Private Function MAK32(lowWord As UShort, highWord As UShort) As ULong
	Return (highWord Shl 16) Or lowWord
End Function

Private Function GetRegData(hMainKey As HKEY, sKeyName As WString, sValueName As WString, dwRegType As DWORD, ByRef sData As Any Ptr) As BOOL
	Dim Retval As Long
	Dim dwSize As DWORD
	Dim hKey As HKEY
	
	dwRegType = 0
	
	Retval = RegOpenKeyEx(hMainKey, sKeyName, NULL, KEY_READ, @hKey)
	If Retval = ERROR_SUCCESS Then
		Retval = RegQueryValueEx(hKey, sValueName, NULL, NULL, ByVal NULL, @dwSize)
		If Retval = ERROR_SUCCESS Then
			sData = Reallocate (sData, dwSize)
			Retval = RegQueryValueEx(hKey, sValueName, NULL, @dwRegType, Cast(UByte Ptr, sData), @dwSize)
		End If
		RegCloseKey(hKey)
		Return True
	End If
	Return False
End Function

Private Sub usbTempRelease()
	Dim i As Integer
	For i = 0 To UBound(usbTempTxt)
		If usbTempTxt(i) Then Deallocate(usbTempTxt(i))
	Next
	Erase usbTempTxt
	usbTmpIndex = -1
End Sub

Private Sub usbTextRelease()
	usbTempRelease()
	Dim i As Integer
	For i = 0 To UBound(usbMessage)
		If usbMessage(i) Then Deallocate(usbMessage(i))
	Next
	Erase usbMessage
	usbMsgIndex = -1
End Sub

Private Sub usbTextPrint(txt As WString)
	usbTmpIndex += 1
	ReDim Preserve usbTempTxt(usbTmpIndex)
	WLet(usbTempTxt(usbTmpIndex), txt)
End Sub

Private Sub usbTextAdd()
	'Avoid due to runtime error 18 (array not dimensioned)
	If usbMsgIndex >-1 AndAlso UBound(usbTempTxt) > 0 Then
		ReDim Preserve usbMessage(usbMsgIndex)
		 usbMessage(usbMsgIndex) = Join(usbTempTxt(), WStr(vbCrLf))
	End If
	usbMsgIndex += 1
	usbTempRelease()
End Sub

Private Function usbTVNodeAdd(tv As TreeView Ptr, tn As PTreeNode, txt As WString, iconIndex As Integer, HasText As Boolean, CutEnabled As Boolean) As PTreeNode
	Dim rtnode As PTreeNode
	If HasText Then
		rtnode = tn->Nodes.Add(txt, "" & usbMsgIndex, txt, iconIndex, iconIndex)
	Else
		rtnode = tn->Nodes.Add(txt, "" , txt, iconIndex, iconIndex)
	End If
	If CutEnabled Then
		TreeView_SetItemState(tv->Handle, rtnode ->HANDLE, TVIS_CUT, TVIS_CUT)
	End If
	Return rtnode
End Function

Private Function GetUSBDeviceHandle(pDeviceName As WString Ptr) As HANDLE
	usbTextPrint(!"\r\n[GetUSBDeviceHandle] start" & vbTab & *pDeviceName)
	Dim hDevice As HANDLE
	Dim SecutityAttributes As SECURITY_ATTRIBUTES
	SecutityAttributes.nLength              = SizeOf(SECURITY_ATTRIBUTES)
	SecutityAttributes.lpSecurityDescriptor = 0
	SecutityAttributes.bInheritHandle       = False
	
	hDevice = CreateFile(pDeviceName , GENERIC_READ, FILE_SHARE_READ, @SecutityAttributes, OPEN_EXISTING, NULL, NULL)
	usbTextPrint("[GetUSBDeviceHandle] completed" & vbTab & hDevice)
	Return hDevice
End Function

Private Function GetDriverKeyName(hHub As HANDLE, ConnectionIndex As Long, ByRef pKeyName As WString Ptr) As BOOL
	usbTextPrint(!"\r\n[GetDriverKeyName] start" & vbTab & hHub & vbTab & ConnectionIndex)
	Dim As USB_NODE_CONNECTION_DRIVERKEY_NAME driverKeyName
	driverKeyName.ConnectionIndex = ConnectionIndex
	Dim success As BOOL
	Dim nBytes As DWORD
	usbTextPrint("[IOCTL_USB_GET_NODE_CONNECTION_DRIVERKEY_NAME]获取连接到 USB 集线器特定端口的设备的驱动程序注册表键名称")
	success = DeviceIoControl(hHub, IOCTL_USB_GET_NODE_CONNECTION_DRIVERKEY_NAME, @driverKeyName, SizeOf(USB_NODE_CONNECTION_DRIVERKEY_NAME), @driverKeyName, SizeOf(USB_NODE_CONNECTION_DRIVERKEY_NAME), @nBytes, NULL)
	If success Then
		WLet(pKeyName, Left(driverKeyName.DriverKeyName, driverKeyName.ActualLength))
	Else
		WLet(pKeyName, "")
	End If
	usbTextPrint("[GetDriverKeyName] completed " & success & vbTab & *pKeyName & vbTab & SizeOf(USB_NODE_CONNECTION_DRIVERKEY_NAME) & vbTab & nBytes)
	Return success
End Function

Private Function GetDriverDesc(hHub As HANDLE, ConnectionIndex As Long, ByRef pDriverDesc As WString Ptr) As BOOL
	usbTextPrint(!"\r\n[GetDriverDesc] start" & vbTab & hHub & vbTab & ConnectionIndex)
	Dim pKeyName As WString Ptr
	Dim success As BOOL = GetDriverKeyName(hHub, ConnectionIndex, pKeyName)
	If success Then
		success = GetRegData(HKEY_LOCAL_MACHINE, WStr("SYSTEM\CurrentControlSet\Control\Class\") & *pKeyName, WStr("DriverDesc"), NULL, pDriverDesc)
	End If
	If pKeyName Then Deallocate pKeyName
	If success = False Then WLet(pDriverDesc, "")
	usbTextPrint("[GetDriverDesc] completed" & vbTab & *pDriverDesc)
	Return success
End Function

Private Function GetDriverInformation(pDriverName As WString, pValName As WString, ByRef pDriverInfo As WString Ptr) As BOOL
	usbTextPrint(!"\r\n[GetDriverInformation] start " & vbTab & pDriverName & vbTab & pValName)
	Dim success As BOOL = GetRegData(HKEY_LOCAL_MACHINE, WStr("SYSTEM\CurrentControlSet\Control\Class\") & pDriverName, pValName, NULL, pDriverInfo)
	If success = False Then WLet(pDriverInfo, "")
	usbTextPrint("[GetDriverInformation] completed" & vbTab & *pDriverInfo)
	Return success
End Function

Private Function GetDriverAllInformation(pDriverName As WString, ByRef pDriverInfo As WString Ptr) As BOOL
	usbTextPrint(!"\r\n[GetDriverAllInformation] start" & vbTab & pDriverName)
	Const ValueCount As Long = 7
	Dim pValName(ValueCount) As WString Ptr = { _
	@WStr("DriverDate           "), _
	@WStr("DriverVersion        "), _
	@WStr("IncludedInfs         "), _
	@WStr("InfPath              "), _
	@WStr("InfSection           "), _
	@WStr("MatchingDeviceId     "), _
	@WStr("ProviderName         "), _
	@WStr("DriverDesc           ") _
	}
	Dim pValStr(ValueCount) As WString Ptr
	Dim pTemp As WString Ptr
	Dim i As Integer
	For i = 0 To ValueCount
		If GetRegData(HKEY_LOCAL_MACHINE, WStr("SYSTEM\CurrentControlSet\Control\Class\") & pDriverName, Trim(*pValName(i)), NULL, pTemp) Then
			WLet(pValStr(i), *pValName(i) & *pTemp)
		End If
	Next
	pDriverInfo = Join(pValStr(), WStr(vbCrLf))
	If pTemp Then Deallocate(pTemp)
	For i = 0 To ValueCount
		If pValStr(i) Then Deallocate(pValStr(i))
	Next
	usbTextPrint("[GetDriverAllInformation] completed")
	Return True
End Function

Private Function usbNoteConnInfoDisp(ConnectionInformation As USB_NODE_CONNECTION_INFORMATION Ptr) As String
	usbTextPrint(!"\r\n[usbNoteConnInfoDisp] start")
	Dim Looper As Long
	Dim sBuffer As WString Ptr
	usbTextPrint("Connection index     0x" & Hex(ConnectionInformation->ConnectionIndex))
	usbTextPrint("Device descriptor    0x" & Hex(ConnectionInformation->DeviceDescriptor.bDescriptorType))
	usbTextPrint("Current config       0x" & Hex(ConnectionInformation->CurrentConfigurationValue))
	usbTextPrint("Low speed            0x" & Hex(ConnectionInformation->LowSpeed))
	usbTextPrint("Device is hub        0x" & Hex(ConnectionInformation->DeviceIsHub))
	usbTextPrint("Device address       0x" & Hex(ConnectionInformation->DeviceAddress))
	usbTextPrint("Connection status    0x" & Hex(ConnectionInformation->ConnectionStatus))
	usbTextPrint("Open pipes count     0x" & Hex(ConnectionInformation->NumberOfOpenPipes))
	If ConnectionInformation->NumberOfOpenPipes < 32 Then
		For Looper = 1 To ConnectionInformation->NumberOfOpenPipes
			WLet(sBuffer, "Pipe" & Looper & " : ")
			usbTextPrint(*sBuffer & "Lenght    0x" & Hex(ConnectionInformation->PipeList(Looper).EndpointDescriptor.bLength, 2))
			usbTextPrint(*sBuffer & "Type      0x" & Hex(ConnectionInformation->PipeList(Looper).EndpointDescriptor.bDescriptorType, 2))
			usbTextPrint(*sBuffer & "End addr. 0x" & Hex(ConnectionInformation->PipeList(Looper).EndpointDescriptor.bEndpointAddress, 2))
			usbTextPrint(*sBuffer & "Attribute 0x" & Hex(ConnectionInformation->PipeList(Looper).EndpointDescriptor.bmAttributes, 2))
			usbTextPrint(*sBuffer & "Size      0x" & Hex(ConnectionInformation->PipeList(Looper).EndpointDescriptor.wMaxPacketSize, 4))
			usbTextPrint(*sBuffer & "Interval  0x" & Hex(ConnectionInformation->PipeList(Looper).EndpointDescriptor.bInterval, 2))
			usbTextPrint(*sBuffer & "Schedule  0x" & Hex(ConnectionInformation->PipeList(Looper).ScheduleOffset, 4))
		Next
	End If
	usbTextPrint("[usbNoteConnInfoDisp] completed")
	If sBuffer Then Deallocate(sBuffer)
	Return ""
End Function

Private Function usbNoteInfoDisp(NodeInformation As USB_NODE_INFORMATION Ptr) As String
	usbTextPrint(!"\r\n[usbNoteInfoDisp] start")
	usbTextPrint("Number of ports          0x" & Hex(NodeInformation->u.HubInformation.HubDescriptor.bNumberOfPorts, 2))
	usbTextPrint("Descriptor length        0x" & Hex(NodeInformation->u.HubInformation.HubDescriptor.bDescriptorLength, 2))
	usbTextPrint("Descriptor type          0x" & Hex(NodeInformation->u.HubInformation.HubDescriptor.bDescriptorType, 2))
	usbTextPrint("Hub characteristics      0x" & Hex(NodeInformation->u.HubInformation.HubDescriptor.wHubCharacteristics, 4))
	usbTextPrint("Power On/Good            0x" & Hex(NodeInformation->u.HubInformation.HubDescriptor.bPowerOnToPowerGood, 2))
	usbTextPrint("Hub control current      0x" & Hex(NodeInformation->u.HubInformation.HubDescriptor.bHubControlCurrent, 2))
	Dim i As Integer
	For i = 0 To 63
		usbTextPrint("Remove and power mask " & Format(i, "00") & " 0x" & Hex(NodeInformation->u.HubInformation.HubDescriptor.bRemoveAndPowerMask(i)))
	Next
	usbTextPrint("Hub Is Bus Powered       0x" & Hex(NodeInformation->u.HubInformation.HubIsBusPowered))
	usbTextPrint("Number Of Interfaces     0x" & Hex(NodeInformation->u.MiParentInformation.NumberOfInterfaces))
	usbTextPrint("Node Type                0x" & Hex(NodeInformation->NodeType))
	usbTextPrint("[usbNoteInfoDisp] completed")
	Return ""
End Function

Private Sub usbDeviceStringLinux(VendorIdHex As String, ByRef sVendorId As String, DeviceIdHex As String, ByRef sDeviceId As String)
	usbTextPrint(!"\r\n[usbDeviceStringLinux] start" & vbTab & VendorIdHex & vbTab & DeviceIdHex)
	Dim  FileNo As ULong
	Dim  Looper As Long
	Dim  VendorIdHexLowerCase As String
	Dim  DeviceIdHexLowerCase As String
	Static WarningDone As Long
	Static InitDone As Long
	Static TextLine() As String
	Static LineCount As Integer
	If InitDone = False Then
		InitDone = True
		'Download from http://www.linux-usb.org/usb.ids and save as "Usb-id.txt"
		If Len(Dir(UsbIdTxtFile)) = 0 Then
			If WarningDone = False Then
				MessageBox(HWND_DESKTOP, _
				UsbIdTxtFile & !" file not found !\r\n" & _
				!"Please download fom http://www.linux-usb.org/usb.ids\r\n" & _
				!"and save as " & UsbIdTxtFile & _
				!"\r\nSo vendor name and product name can be aviaiable.", _
				UsbIdTxtFile & " file not found", MB_OK)
				WarningDone = True
			End If
		Else
			FileNo = FreeFile
			
			Open UsbIdTxtFile For Input Encoding "ascii" As FileNo
			Do While Not EOF(FileNo)
				ReDim Preserve TextLine(LineCount)
				Line Input #FileNo, TextLine(LineCount)
				LineCount  += 1
			Loop
			Close FileNo
		End If
	End If
	
	sDeviceId = ""
	sVendorId = ""
	If WarningDone Then
	Else
		Dim exitflag As Boolean = False
		DeviceIdHexLowerCase = LCase(DeviceIdHex)
		VendorIdHexLowerCase = LCase(VendorIdHex)
		For Looper = 1 To LineCount - 1
			If Left(TextLine(Looper), 1) <> "#" Then '#
				If Left(TextLine(Looper), 1) <> vbTab Then  'TAB Then
					If VendorIdHexLowerCase = Left(TextLine(Looper), 4) Then
						sVendorId = Trim(Mid(TextLine(Looper), 5))
						For Looper = Looper + 1 To LineCount - 1
							If Left(TextLine(Looper), 1) <> vbTab Then  'TAB
								exitflag = True
								Exit For
							Else
								If vbTab & DeviceIdHexLowerCase = Left(TextLine(Looper), 5) Then
									sDeviceId = Trim(Mid(TextLine(Looper), 6))
									exitflag = True
									Exit For
								End If
							End If
						Next
					End If
				End If
			End If
			If exitflag Then Exit For
		Next
	End If
	usbTextPrint("[usbDeviceStringLinux] completed" & vbTab & sVendorId & vbTab & sDeviceId)
End Sub

Private Function usbDeviceLanguageId(hHub As HANDLE, PortIndex As ULong) As Long
	usbTextPrint(!"\r\n[usbDeviceLanguageId] start" & vbTab & hHub & vbTab & PortIndex)
	
	Dim Request As USB_DESCRIPTOR_REQUEST
	Dim pUsbLanguageId As USB_COMMON_DESCRIPTOR Ptr
	Dim zLanguage As WString * MAX_PATH
	Dim sBuffer As String
	Dim BytesReturned As ULong
	Dim Success As Long
	Dim Looper As Long
	
	memset(@Request, 0, SizeOf(USB_DESCRIPTOR_REQUEST))
	Request.ConnectionIndex = PortIndex
	Request.SetupPacket.bmRequest       = &H80
	Request.SetupPacket.bRequest        = USB_REQUEST_GET_DESCRIPTOR
	Request.SetupPacket.wValue          = MAK16(0, USB_STRING_DESCRIPTOR_TYPE)
	Request.SetupPacket.wLength         = MAXIMUM_USB_STRING_LENGTH
	
	usbTextPrint("[IOCTL_USB_GET_DESCRIPTOR_FROM_NODE_CONNECTION]从 USB 集线器的特定端口连接的设备获取描述符")
	Success = DeviceIoControl(hHub, IOCTL_USB_GET_DESCRIPTOR_FROM_NODE_CONNECTION, @Request, SizeOf(USB_DESCRIPTOR_REQUEST), @Request, SizeOf(USB_DESCRIPTOR_REQUEST), @BytesReturned, NULL)
	If Success = 0 Then
		usbTextPrint("Language id " & Format(Looper, "00") & vbTab & "Error")
	Else
		pUsbLanguageId = Cast(USB_COMMON_DESCRIPTOR Ptr, @Request.Data)
		If pUsbLanguageId->bDescriptorType = 3 Then
			Dim lia As WORD Ptr = @Request.Data + 2
			Dim i As WORD
			Dim j As WORD = (pUsbLanguageId->bLength \ 2) - 1
			ReDim LanguageIdArray(j)
			For Looper = 1 To j
				LanguageIdArray(Looper) = * (lia + Looper - SizeOf(WORD))
				sBuffer = "0x" & Hex(LanguageIdArray(Looper), 4) & " (" & Format(LanguageIdArray(Looper)) & ") "
				GetLocaleInfo(MAK32(LanguageIdArray(Looper), SORT_DEFAULT), LOCALE_SENGLANGUAGE, zLanguage, MAX_PATH)
				sBuffer = sBuffer & zLanguage & " ("
				GetLocaleInfo(MAK32(LanguageIdArray(Looper), SORT_DEFAULT), LOCALE_SENGCOUNTRY, zLanguage, MAX_PATH)
				sBuffer = sBuffer & zLanguage &  "), "
				GetLocaleInfo(MAK32(LanguageIdArray(Looper), SORT_DEFAULT), LOCALE_SLANGUAGE, zLanguage, MAX_PATH)
				sBuffer = sBuffer & zLanguage
				usbTextPrint("Language id " & Format(Looper, "00") & vbTab &  sBuffer)
			Next
		End If
	End If
	usbTextPrint("[usbDeviceLanguageId] completed" & vbTab & Success)
	Return Success
End Function

Private Function usbDeviceString(hHub As HANDLE, PortIndex As ULong, Index As UCHAR) As String
	usbTextPrint(!"\r\n[usbDeviceString] start" & vbTab & hHub & vbTab & PortIndex & vbTab & Index)
	
	Dim Request As USB_DESCRIPTOR_REQUEST
	Dim pBuffer As USB_COMMON_DESCRIPTOR Ptr
	Dim sBuffer As String
	Dim BytesReturned As ULong
	Dim StringLen As Long
	Dim Success As Long
	
	If usbDeviceLanguageId(hHub, PortIndex) Then
		memset(@Request, 0, SizeOf(USB_DESCRIPTOR_REQUEST))
		Request.ConnectionIndex             = PortIndex
		Request.SetupPacket.bmRequest       = &H80
		Request.SetupPacket.bRequest        = USB_REQUEST_GET_DESCRIPTOR
		Request.SetupPacket.wValue          = MAK16(Index, USB_STRING_DESCRIPTOR_TYPE)
		Request.SetupPacket.wIndex          = LanguageIdArray(1)
		Request.SetupPacket.wLength         = MAXIMUM_USB_STRING_LENGTH '255
		usbTextPrint("[IOCTL_USB_GET_DESCRIPTOR_FROM_NODE_CONNECTION]检索与指定端口索引关联的 USB 设备的一个或多个描述符")
		Success = DeviceIoControl(hHub, IOCTL_USB_GET_DESCRIPTOR_FROM_NODE_CONNECTION, @Request, SizeOf(USB_DESCRIPTOR_REQUEST), @Request, SizeOf(USB_DESCRIPTOR_REQUEST), @BytesReturned, NULL)
		If Success Then
			pBuffer   = Cast(USB_COMMON_DESCRIPTOR Ptr, @Request.Data)
			StringLen = pBuffer->bLength
			sBuffer = Trim(Mid(Request.Data, 2, StringLen - 1))
		End If
	End If
	
	usbTextPrint("[usbDeviceString] completed" & vbTab & sBuffer)
	Return sBuffer
End Function

Private Function usbDeviceDesc(hHub As HANDLE, PortIndex As ULong) As Long
	usbTextPrint(!"\r\n[usbDeviceDesc] start" & vbTab & hHub & vbTab & PortIndex)
	
	Dim pUsbDeviceDescriptor As USB_DEVICE_DESCRIPTOR Ptr
	Dim pUsbConfigurationDescriptor As USB_CONFIGURATION_DESCRIPTOR Ptr
	Dim pUsbInterfaceDescriptor As USB_INTERFACE_DESCRIPTOR Ptr
	Dim pUsbEndPointDescriptor As USB_ENDPOINT_DESCRIPTOR Ptr
	Dim pHidDeviceDescriptor As HID_DESCRIPTOR Ptr
	Dim pUsbHeaderDescriptor As USB_COMMON_DESCRIPTOR Ptr
	Dim Request As USB_DESCRIPTOR_REQUEST
	'Dim sBuffer As String
	Dim BytesReturned As ULong
	Dim Success As Long
	Dim TmpByte As UCHAR
	
	memset(@Request, 0, SizeOf(USB_DESCRIPTOR_REQUEST))
	Request.ConnectionIndex             = PortIndex
	Request.SetupPacket.bmRequest       = &H80
	Request.SetupPacket.bRequest        = USB_REQUEST_GET_DESCRIPTOR
	Request.SetupPacket.wValue          = MAK16(0, USB_CONFIGURATION_DESCRIPTOR_TYPE) 'No Index
	Request.SetupPacket.wLength         = MAXIMUM_USB_STRING_LENGTH
	Request.SetupPacket.wIndex          = 0
	
	usbTextPrint("[IOCTL_USB_GET_DESCRIPTOR_FROM_NODE_CONNECTION]检索与指定端口索引关联的 USB 设备的一个或多个描述符")
	Success = DeviceIoControl(hHub, IOCTL_USB_GET_DESCRIPTOR_FROM_NODE_CONNECTION, @Request, SizeOf(USB_DESCRIPTOR_REQUEST), @Request, SizeOf(USB_DESCRIPTOR_REQUEST), @BytesReturned, NULL)
	If Success = 0 Then
		usbTextPrint("Configuration descriptor not returned.")
	Else
		pUsbHeaderDescriptor = Cast(USB_COMMON_DESCRIPTOR Ptr, @Request.Data)
		Do While pUsbHeaderDescriptor->bLength
			usbTextPrint("DescriptorType*******" & pUsbHeaderDescriptor->bDescriptorType)
			Select Case pUsbHeaderDescriptor->bDescriptorType
				
			Case 1
				usbTextPrint("Type                 USB device descriptor")
				
				pUsbDeviceDescriptor = Cast(USB_DEVICE_DESCRIPTOR Ptr, pUsbHeaderDescriptor)
				usbTextPrint("bcd USB              0x" & Hex(pUsbDeviceDescriptor->bcdUSB))
				usbTextPrint("Device class         0x" & Hex(pUsbDeviceDescriptor->bDeviceClass))
				usbTextPrint("Device sub class     0x" & Hex(pUsbDeviceDescriptor->bDeviceSubClass))
				usbTextPrint("Device protocol      0x" & Hex(pUsbDeviceDescriptor->bDeviceProtocol))
				usbTextPrint("Max packet size 0    0x" & Hex(pUsbDeviceDescriptor->bMaxPacketSize0))
				usbTextPrint("id Vendor            0x" & Hex(pUsbDeviceDescriptor->idVendor))
				usbTextPrint("id Product           0x" & Hex(pUsbDeviceDescriptor->idProduct))
				usbTextPrint("bcd Device           0x" & Hex(pUsbDeviceDescriptor->bcdDevice))
				usbTextPrint("iManufacturer        0x" & Hex(pUsbDeviceDescriptor->iManufacturer))
				usbTextPrint("iProduct             0x" & Hex(pUsbDeviceDescriptor->iProduct))
				usbTextPrint("iSerial number       0x" & Hex(pUsbDeviceDescriptor->iSerialNumber))
				usbTextPrint("Num configurations   0x" & Hex(pUsbDeviceDescriptor->bNumConfigurations))
			Case 2
				usbTextPrint("Type                 USB configuration descriptor")
				pUsbConfigurationDescriptor = Cast(USB_CONFIGURATION_DESCRIPTOR Ptr, pUsbHeaderDescriptor)
				usbTextPrint("Total length         0x" & Hex(pUsbConfigurationDescriptor->wTotalLength))
				usbTextPrint("Num interfaces       0x" & Hex(pUsbConfigurationDescriptor->bNumInterfaces))
				usbTextPrint("Config value         0x" & Hex(pUsbConfigurationDescriptor->bConfigurationValue))
				usbTextPrint("iConfiguration       0x" & Hex(pUsbConfigurationDescriptor->iConfiguration))
				If pUsbConfigurationDescriptor->iConfiguration Then
					usbTextPrint("Configuration--------" & usbDeviceString(hHub, PortIndex, TmpByte))
				End If
				usbTextPrint("Attributes           0x" & Hex(pUsbConfigurationDescriptor->bmAttributes))
				usbTextPrint("Max power ma         0x" & Hex(pUsbConfigurationDescriptor->MaxPower) & " (" & 2 * pUsbConfigurationDescriptor->MaxPower & " ma)")
			Case 4
				usbTextPrint("Type                 USB interface descriptor")
				pUsbInterfaceDescriptor = Cast(USB_INTERFACE_DESCRIPTOR Ptr, pUsbHeaderDescriptor)
				usbTextPrint("Interface number     0x" & Hex(pUsbInterfaceDescriptor->bInterfaceNumber))
				usbTextPrint("Alternate setting    0x" & Hex(pUsbInterfaceDescriptor->bAlternateSetting))
				usbTextPrint("Num end points       0x" & Hex(pUsbInterfaceDescriptor->bNumEndpoints))
				TmpByte = pUsbInterfaceDescriptor->bInterfaceClass
				usbTextPrint("Interface class      0x" & Hex(TmpByte))
				If (TmpByte > 9) And (TmpByte < 255) Then TmpByte = 11
				If TmpByte = 255 Then TmpByte = 10
				usbTextPrint("Interface subclass   0x" & Hex(pUsbInterfaceDescriptor->bInterfaceSubClass))
				usbTextPrint("Interface protocol   0x" & Hex(pUsbInterfaceDescriptor->bInterfaceProtocol))
				usbTextPrint("Interface            0x" & Hex(pUsbInterfaceDescriptor->iInterface))
				If pUsbInterfaceDescriptor->iInterface Then
					usbTextPrint("Interface------------" & usbDeviceString(hHub, PortIndex, TmpByte))
				End If
			Case 5
				usbTextPrint("Type                 USB end point descriptor")
				pUsbEndPointDescriptor = Cast(USB_ENDPOINT_DESCRIPTOR Ptr, pUsbHeaderDescriptor)
				usbTextPrint("End point address    0x" & Hex(pUsbEndPointDescriptor->bEndpointAddress))
				usbTextPrint("Attributes           0x" & Hex(pUsbEndPointDescriptor->bmAttributes))
				usbTextPrint("Max packet size      0x" & Hex(pUsbEndPointDescriptor->wMaxPacketSize))
				usbTextPrint("Interval             0x" & Hex(pUsbEndPointDescriptor->bInterval))
			Case 33 '0x21
				usbTextPrint("Type                 HID device descriptor")
				pHidDeviceDescriptor = Cast(HID_DESCRIPTOR Ptr, pUsbHeaderDescriptor)
				usbTextPrint("bcd HID              0x" & Hex(pHidDeviceDescriptor->bcdHID))
				usbTextPrint("Country              0x" & Hex(pHidDeviceDescriptor->bCountry))
				usbTextPrint("Num descriptors      0x" & Hex(pHidDeviceDescriptor->bNumDescriptors))
				usbTextPrint("Report type          0x" & Hex(pHidDeviceDescriptor->DescriptorList(0).bReportType))
				usbTextPrint("Report length        0x" & Hex(pHidDeviceDescriptor->DescriptorList(0).wReportLength))
			Case Else
				usbTextPrint("Type                 Unknown descriptor")
			End Select
			pUsbHeaderDescriptor = pUsbHeaderDescriptor + pUsbHeaderDescriptor->bLength
		Loop
	End If
	usbTextPrint("[usbDeviceDesc] completed")
	Return 0
End Function

Private Function usbDeviceInfo(hHub As HANDLE, PortIndex As ULong, ByVal pBuffer As USB_DEVICE_DESCRIPTOR Ptr) As String
	usbTextPrint(!"\r\n[usbDeviceInfo] start" & vbTab & hHub & vbTab & PortIndex)
	
	Dim sManufacturerLinux As String
	Dim sProductLinux As String
	Dim sManufacturer As String
	Dim sProduct As String
	Dim sSerial As String
	Dim sReturn As String
	
	usbDeviceStringLinux(Hex(pBuffer->idVendor, 4), sManufacturerLinux, Hex(pBuffer->idProduct, 4), sProductLinux)
	
	usbTextPrint("Descriptor type     0x" & Hex(pBuffer->bDescriptorType))
	usbTextPrint("bcd USB             0x" & Hex(pBuffer->bcdUSB))
	usbTextPrint("Device class        0x" & Hex(pBuffer->bDeviceClass))
	usbTextPrint("Device sub class    0x" & Hex(pBuffer->bDeviceSubClass))
	usbTextPrint("Device protocol     0x" & Hex(pBuffer->bDeviceProtocol))
	usbTextPrint("Max packet size     0x" & Hex(pBuffer->bMaxPacketSize0))
	
	usbTextPrint("id Vendor           0x" & Hex(pBuffer->idVendor))
	usbTextPrint("id Product          0x" & Hex(pBuffer->idProduct))
	usbTextPrint("Vendor  (Linux id)  " & sManufacturerLinux)
	usbTextPrint("Product (Linux id)  " & sProductLinux)
	usbTextPrint("bcd Device          0x" & Hex(pBuffer->bcdDevice))
	usbTextPrint("iManufacturer       0x" & Hex(pBuffer->iManufacturer))
	
	sManufacturer = usbDeviceString(hHub, PortIndex, pBuffer->iManufacturer)
	usbTextPrint("Manufacturer--------" & sManufacturer)
	usbTextPrint("iProduct            0x" & Hex(pBuffer->iProduct))
	
	sProduct = usbDeviceString(hHub, PortIndex, pBuffer->iProduct)
	usbTextPrint("Product-------------" & sProduct)
	
	usbTextPrint("iSerial number      0x" & Hex(pBuffer->iSerialNumber))
	sSerial = usbDeviceString(hHub, PortIndex, pBuffer->iSerialNumber)
	usbTextPrint("Serial number-------" & sSerial)
	usbTextPrint("Num configurations0x" & Hex(pBuffer->bNumConfigurations))
	
	If sProduct = "" Then
		If sProductLinux = "" Or sManufacturerLinux = "" Then
			sReturn = ""
		Else
			sReturn = "+" & sProductLinux & " (" & sManufacturerLinux & ")"
		End If
	Else
		If sManufacturer = "" Then
			sReturn = sProduct
		Else
			sReturn = sProduct & " (" & sManufacturer & ")"
		End If
	End If
	usbTextPrint("[usbDeviceInfo] completed" & vbTab & sReturn)
	Return sReturn
End Function

Private Function usbPortEnum(hHub As HANDLE, PortCount As UCHAR, tv As TreeView Ptr, tn As PTreeNode, tx As TextBox Ptr, ByVal isRoot As Boolean = False) As Long
	Static UsbLevel As Long
	If isRoot Then UsbLevel = 0
	usbTextPrint(!"\r\n[usbPortEnum] start" & vbTab & UsbLevel)
	
	Dim ConnectionInformation As USB_NODE_CONNECTION_INFORMATION
	Dim NodeInformation As USB_NODE_INFORMATION
	Dim NodeConnection As USB_NODE_CONNECTION_NAME
	Dim NodeConnectionName As WString * MAXIMUM_USB_STRING_LENGTH
	Dim hNodeConnection As HANDLE
	Dim BytesReturned As ULong
	Dim dwRegType As ULong
	Dim Success As Long
	
	Dim PortIndex As ULong
	Dim nBytes As ULong
	Dim subtn As PTreeNode
	
	Dim pKey As WString Ptr
	Dim pDrvInfo As WString Ptr
	Dim pDrvDesc As WString Ptr
	Dim pStatus As BOOL
	
	Dim portStr As String
	
	UsbLevel += 1
	
	For PortIndex = 1 To PortCount 'Iterate each ports
		usbTextAdd()
		
		usbTextPrint(!"\r\n" & String(UsbLevel * 4, Asc("+")) & "Port " & PortIndex)
		pStatus = GetDriverKeyName(hHub, PortIndex, pKey)
		If pStatus Then
			GetDriverAllInformation(*pKey, pDrvInfo)
			usbTextPrint(*pDrvInfo)
			GetDriverDesc(hHub, PortIndex, pDrvDesc)
		End If
		portStr = "Port-" & Format(PortIndex, "00") & " "
		
		memset(@ConnectionInformation, 0, SizeOf(USB_NODE_CONNECTION_INFORMATION))
		ConnectionInformation.ConnectionIndex = PortIndex
		usbTextPrint("[IOCTL_USB_GET_NODE_CONNECTION_INFORMATION]检索有关特定 USB 端口以及连接到该端口的设备（如果有）的信息的 I/O 控制请求")
		nBytes = SizeOf(USB_NODE_CONNECTION_INFORMATION)
		Success = DeviceIoControl(hHub, IOCTL_USB_GET_NODE_CONNECTION_INFORMATION, @ConnectionInformation, SizeOf(USB_NODE_CONNECTION_INFORMATION), @ConnectionInformation, SizeOf(USB_NODE_CONNECTION_INFORMATION), @BytesReturned, 0)
		If Success = 0 Then
			usbTextPrint("Error F, node connection information not returned.")
		Else
			usbNoteConnInfoDisp(@ConnectionInformation)
			'If ConnectionInformation.ConnectionStatus <> DeviceConnected Then
			If ConnectionInformation.ConnectionStatus = NoDeviceConnected Then
				'没有连接设备
				usbTextPrint("No connected device  " & vbTab & PortIndex)
				If pStatus Then portStr += "*" & *pDrvDesc
				subtn = usbTVNodeAdd(tv, tn, portStr, 19, True, True)
				'subtn = tn->Nodes.Add(portStr, portStr, portStr, 19, 19)
				'TreeView_SetItemState(tv->Handle, subtn->Handle, TVIS_CUT, TVIS_CUT)
			Else
				'连接了设备
				
				usbDeviceDesc(hHub, PortIndex)
				Dim temp As String = usbDeviceInfo(hHub, PortIndex, @ConnectionInformation.DeviceDescriptor)
				If temp = "" Then
					portStr += "*" & *pDrvDesc
				Else
					portStr += temp
				End If
				subtn = usbTVNodeAdd(tv, tn, portStr, 19, True, False)
				'subtn = tn ->Nodes.Add(portStr, portStr, portStr, 19, 19)
				
				If ConnectionInformation.DeviceIsHub = 0 Then
					'连接了设备
				Else
					'连接了HUB
					memset(@NodeConnection, 0, SizeOf(USB_NODE_CONNECTION_NAME))
					NodeConnection.ConnectionIndex = PortIndex
					usbTextPrint("[IOCTL_USB_GET_NODE_CONNECTION_NAME]检索连接到 USB 集线器特定端口的设备的符号链接名称")
					Success = DeviceIoControl(hHub, IOCTL_USB_GET_NODE_CONNECTION_NAME, @NodeConnection, SizeOf(USB_NODE_CONNECTION_NAME), @NodeConnection, SizeOf(USB_NODE_CONNECTION_NAME), @BytesReturned, NULL)
					If Success = 0 Then
						usbTextPrint("Error G, node connection name not returned.")
					Else
						NodeConnectionName = WStr("\\.\") & Left(NodeConnection.NodeName, NodeConnection.ActualLength)
						usbTextPrint("NodeConnectionName=" & NodeConnectionName)
						hNodeConnection = GetUSBDeviceHandle(@NodeConnectionName)
						If hNodeConnection <> INVALID_HANDLE_VALUE Then
							memset(@NodeInformation, 0, SizeOf(USB_NODE_INFORMATION))
							usbTextPrint("[IOCTL_USB_GET_NODE_INFORMATION]检索有关 USB 集线器的信息")
							Success = DeviceIoControl(hNodeConnection, IOCTL_USB_GET_NODE_INFORMATION, @NodeInformation, SizeOf(USB_NODE_INFORMATION), @NodeInformation, SizeOf(USB_NODE_INFORMATION), @BytesReturned, NULL)
							If Success Then
								usbNoteInfoDisp(@NodeInformation)
								usbPortEnum(hNodeConnection, NodeInformation.u.HubInformation.HubDescriptor.bNumberOfPorts, tv, subtn, tx)
							End If
							CloseHandle(hNodeConnection)
						End If
					End If
				End If
			End If
		End If
	Next
	
	If pKey Then Deallocate(pKey)
	If pDrvDesc Then Deallocate(pDrvDesc)
	If pDrvInfo Then Deallocate(pDrvInfo)
	UsbLevel -= 1
	
	usbTextPrint("[usbPortEnum] completed " & UsbLevel)
	Return 0
End Function

Private Function usbHostControllerInfo(hHostController As HANDLE, tv As TreeView Ptr, tn As PTreeNode, tx As TextBox Ptr) As BOOL
	usbTextPrint(!"\r\n[usbHostControllerInfo] start" & vbTab & hHostController)
	
	Dim DriverKeyName As USB_HCD_DRIVERKEY_NAME
	Dim NodeInformation As USB_NODE_INFORMATION
	Dim RootHubName As WString * MAXIMUM_USB_STRING_LENGTH  'RootHubName must start with "\\.\"
	
	Dim hRootHub As HANDLE
	'Dim dwRegType As ULong
	Dim BytesReturned As ULong
	Dim Success As BOOL
	
	Dim iidName As WString Ptr
	
	memset(@DriverKeyName, 0, SizeOf(USB_HCD_DRIVERKEY_NAME))
	usbTextPrint("[IOCTL_GET_HCD_DRIVERKEY_NAME]检索 USB 主机控制器驱动程序在注册表中的驱动程序键名（Driver Key Name）")
	Success = DeviceIoControl(hHostController, IOCTL_GET_HCD_DRIVERKEY_NAME, @DriverKeyName, SizeOf(USB_HCD_DRIVERKEY_NAME), @DriverKeyName, SizeOf(USB_HCD_DRIVERKEY_NAME), @BytesReturned, NULL)
	If Success Then
		GetDriverAllInformation(Left(DriverKeyName.DriverKeyName, DriverKeyName.ActualLength), iidName)
		usbTextPrint(*iidName)
		GetDriverInformation(Left(DriverKeyName.DriverKeyName, DriverKeyName.ActualLength), WStr("DriverDesc"), iidName)
		
		'Root Host
		Dim subtn As PTreeNode = usbTVNodeAdd(tv, tn, *iidName, 19, True, False)
		
		memset(@DriverKeyName, 0, SizeOf(USB_HCD_DRIVERKEY_NAME))
		usbTextPrint("[IOCTL_USB_GET_ROOT_HUB_NAME]获取与 USB 主机控制器设备关联的 USB 根集线器的名称")
		Success = DeviceIoControl(hHostController, IOCTL_USB_GET_ROOT_HUB_NAME, @DriverKeyName, SizeOf(USB_HCD_DRIVERKEY_NAME), @DriverKeyName, SizeOf(USB_HCD_DRIVERKEY_NAME), @BytesReturned, NULL)
		If Success Then
			RootHubName = WStr("\\.\") & Left(DriverKeyName.DriverKeyName, DriverKeyName.ActualLength)
			usbTextPrint("RootHubName           " & vbTab & RootHubName)
			hRootHub = GetUSBDeviceHandle(@RootHubName)
			If hRootHub Then
				usbTextPrint(WStr("[IOCTL_USB_GET_NODE_INFORMATION]检索 USB 集线器的信息"))
				memset(@NodeInformation, 0, SizeOf(USB_NODE_INFORMATION))
				Success = DeviceIoControl(hRootHub, IOCTL_USB_GET_NODE_INFORMATION, @NodeInformation, SizeOf(USB_NODE_INFORMATION), @NodeInformation, SizeOf(USB_NODE_INFORMATION), @BytesReturned, NULL)
				If Success Then
					usbNoteInfoDisp(@NodeInformation)
					usbPortEnum(hRootHub, NodeInformation.u.HubInformation.HubDescriptor.bNumberOfPorts, tv, subtn, tx, True)
				End If
				CloseHandle(hRootHub)
			End If
		End If
	End If
	
	If iidName Then Deallocate(iidName)
	usbTextPrint("[usbHostControllerInfo] completed" & vbTab & Success)
	Return Success
End Function

Private Sub usbHostControllerEnum(tv As TreeView Ptr, tx As TextBox Ptr)
	usbTextPrint(!"\r\n[usbHostControllerEnum] start" & vbTab & tx)
	
	'我的电脑
	tv->Nodes.Clear
	Dim tn As PTreeNode
	'tn = usbTVNodeAdd(tv, tv->Nodes, "My Computer", 12, True, True)
	tn = tv->Nodes.Add("My Computer", "", "My Computer", 12, 12)
	usbTextRelease()
	usbTextAdd()
	Dim hHostController As HANDLE
	Dim i As Integer
	For i = 0 To 25
		usbTextAdd()
		hHostController = GetUSBDeviceHandle(WStr("\\.\HCD" & i))
		If hHostController <> INVALID_HANDLE_VALUE Then
			usbHostControllerInfo(hHostController, tv, tn, tx)
			CloseHandle(hHostController)
		Else
		End If
	Next
	usbTextPrint("[usbHostControllerEnum] completed")
End Sub

