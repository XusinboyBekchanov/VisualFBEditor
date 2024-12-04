'DeviceExplorer.bas
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.
' 通过windows api实现如device manager一样的update driver, uninstall device, eject device的功能
' 翻译了cfgmgr32, devguid, devpkey, devpropdef, newdev等相关头文件
' https://learn.microsoft.com/en-us/windows/win32/devinst/setupapi-h

' 参考了TwinBasic的样例
' https://github.com/fafalone/DeviceExplorer

#include once "DeviceExplorer.bi"

Private Sub pvRelase()
	Dim i As Integer
	
	For i = 0 To categoriesCount
		If categoriesName(i) Then Deallocate(categoriesName(i))
		If categoriesDescription(i) Then Deallocate(categoriesDescription(i))
	Next
	Erase categoriesHSet
	Erase categoriesDevInfo
	Erase categoriesGuid
	Erase categoriesName
	Erase categoriesDescription
	categoriesCount = -1
	
	For i = 0 To devicesCount
		If devicesFriendlyName(i) Then Deallocate(devicesFriendlyName(i))
		If devicesDescription(i) Then Deallocate(devicesDescription(i))
		If devicesInstanceId(i) Then Deallocate(devicesInstanceId(i))
		If devicesHardwareId(i) Then Deallocate(devicesHardwareId(i))
		If devicesDriver(i) Then Deallocate(devicesDriver(i))
	Next
	Erase devicesIndexCategories
	Erase devicesGUID
	Erase devicesCapabilities
	Erase devicesEnabled
	Erase devicesPresent
	Erase devicesProblem
	Erase devicesStatus
	Erase devicesFriendlyName
	Erase devicesHardwareId
	Erase devicesDriver
	Erase devicesDescription
	Erase devicesInstanceId
	devicesCount = -1
End Sub

Private Sub pvInit()
	Dim pIIDL As ITEMIDLIST Ptr
	Dim pFileInfo As SHFILEINFO
	
	SHGetSpecialFolderLocation(NULL, CSIDL_SYSTEMX86, @pIIDL)
	SHGetPathFromIDList(pIIDL, @SystemPath)
End Sub

Private Sub pvInitIcon(tv As TreeView Ptr)
	'初始化ImageList, 并从setupapi.dll文件获得Overlay Icon
	
	'清空ImageList Icon
	ImageList_Remove tv->Images->Handle, -1
	
	Dim hico As HANDLE
	Dim i As Integer
	Dim j As Integer = 1
	Dim k As Integer = ExtractIconEx(SystemPath & "\setupapi.dll", -1, 0, NULL, 0)
	k -= 1
	Dim o As Long
	'最后3个图标是Overlay icon.
	For i = k - 2 To k
		ExtractIconEx(SystemPath & "\setupapi.dll", i, 0, @hico, 1)
		o = ImageList_ReplaceIcon(tv->Images->Handle, -1, hico)
		ImageList_SetOverlayImage(tv->Images->Handle, o, j)
		DestroyIcon(hico)
		j += 1
	Next
End Sub

Private Function pvIndexBydevicesInstanceId(hwndParent As HWND, pGuid As GUID Ptr, pInstanceId As WString Ptr, ShowHide As Boolean, ByRef hSet As HDEVINFO, ByRef pDevInfo As PSP_DEVINFO_DATA) As BOOL
	Dim i As Long = 0
	Dim ret As BOOL
	Dim cchReq As DWORD = 0
	
	hSet = SetupDiGetClassDevs(pGuid, NULL, hwndParent, IIf(ShowHide, 0, DIGCF_PRESENT))
	If hSet = INVALID_HANDLE_VALUE Then Return False
	
	memset(pDevInfo, 0, SizeOf(SP_DEVINFO_DATA))
	pDevInfo->cbSize = SizeOf(SP_DEVINFO_DATA)
	
	Dim tInstanceId As WString Ptr
	Do While SetupDiEnumDeviceInfo(hSet, i, pDevInfo)
		ret = SetupDiGetDeviceInstanceId(hSet, pDevInfo, NULL, NULL, @cchReq)
		If cchReq Then
			tInstanceId = CAllocate(cchReq * 2, SizeOf(Byte))
			ret = SetupDiGetDeviceInstanceId(hSet, pDevInfo, tInstanceId, cchReq, @cchReq)
			
			If *tInstanceId = *pInstanceId Then
				If tInstanceId Then Deallocate(tInstanceId)
				Return True
			End If
		End If
		i += 1
		memset(pDevInfo, 0, SizeOf(SP_DEVINFO_DATA))
		pDevInfo->cbSize = SizeOf(SP_DEVINFO_DATA)
	Loop
	If tInstanceId Then Deallocate(tInstanceId)
	Return False
End Function

Private Function pvEnumClasses(hwndParent As HWND, tv As TreeView Ptr, ShowCategories As Boolean, ShowHide As Boolean) As Integer
	Dim ret As BOOL
	Dim cbReq As DWORD
	
	tv->Nodes.Clear
	pvRelase()
	
	cbReq = 0
	'SetupDiBuildClassInfoList返回本地计算机上安装的设备类别的 GUID 列表
	ret = SetupDiBuildClassInfoList(NULL, NULL, 0, @cbReq)
	categoriesCount = cbReq - 1
	EnumCCount = 0
	EnumDCount = 0
	If cbReq < 1 Then Return 0
	
	ReDim categoriesHSet(categoriesCount)
	ReDim categoriesDevInfo(categoriesCount)
	ReDim categoriesGuid(categoriesCount)
	ReDim categoriesName(categoriesCount)
	ReDim categoriesDescription(categoriesCount)
	
	Dim cchReq As DWORD = 0
	ret = SetupDiBuildClassInfoList(NULL, @categoriesGuid(0), cbReq, @cchReq)
	If ret = False Then Return 0
	
	Dim i As Long
	Dim j As Integer = 0
	
	Dim mIndex As DWORD
	Dim regType As DWORD = REGTYPES.REG_NONE
	Dim hicn As HICON
	Dim ico As Long
	
	Dim cbiReq As Integer
	Dim nPropType As DEVPROPTYPE = DEVPROP_TYPE_BOOLEAN
	
	For i = 0 To categoriesCount
		categoriesHSet(i) = SetupDiGetClassDevs(@categoriesGuid(i), NULL, hwndParent, IIf(ShowHide, 0, DIGCF_PRESENT))
		If categoriesHSet(i) = INVALID_HANDLE_VALUE Then Continue For
		
		cchReq = 0
		'SetupDiClassNameFromGuid根据设备类别 GUID 获取设备类名称
		ret = SetupDiClassNameFromGuid(@categoriesGuid(i), NULL, NULL, @cchReq)
		If cchReq Then
			categoriesName(i) = CAllocate(cchReq * 2, SizeOf(Byte))
			ret = SetupDiClassNameFromGuid(@categoriesGuid(i), categoriesName(i), cchReq, @cchReq)
		End If
		
		cchReq = 0
		'SetupDiGetClassDescription获取设备类的描述
		ret = SetupDiGetClassDescription(@categoriesGuid(i), NULL, NULL, @cchReq)
		If cchReq Then
			categoriesDescription(i) = CAllocate(cchReq * 2, SizeOf(Byte))
			ret = SetupDiGetClassDescription(@categoriesGuid(i), categoriesDescription(i), cchReq, @cchReq)
		End If
		
		Dim pTNode As TreeNode Ptr = NULL
		'显示所有设备类别
		If ShowCategories Then
			EnumCCount += 1
			ret = SetupDiLoadClassIcon(@categoriesGuid(i), @hicn, NULL)
			ico = ImageList_ReplaceIcon(tv->Images->Handle, -1, hicn)
			DestroyIcon(hicn)
			pTNode = tv->Nodes.Add(*categoriesDescription(i), WStr(i), WStr("Categories"), ico, ico)
		End If
		
		mIndex = 0
		memset(@categoriesDevInfo(i), 0, SizeOf(categoriesDevInfo(i)))
		categoriesDevInfo(i).cbSize = SizeOf(categoriesDevInfo(i))
		'SetupDiEnumDeviceInfo枚举设备信息集中的设备信息元素
		Do While SetupDiEnumDeviceInfo(categoriesHSet(i), mIndex, @categoriesDevInfo(i))
			
			'只显示有设备的设备类别
			If pTNode = NULL Then
				EnumCCount += 1
				ret = SetupDiLoadClassIcon(@categoriesGuid(i), @hicn, NULL)
				ico = ImageList_ReplaceIcon(tv->Images->Handle, -1, hicn)
				DestroyIcon(hicn)
				pTNode = tv->Nodes.Add(*categoriesDescription(i), WStr(i), WStr("Categories"), ico, ico)
			End If
			
			j += 1
			ReDim Preserve devicesIndexCategories(j)
			ReDim Preserve devicesGUID(j)
			ReDim Preserve devicesCapabilities(j)
			ReDim Preserve devicesStatus(j)
			ReDim Preserve devicesProblem(j)
			ReDim Preserve devicesPresent(j)
			ReDim Preserve devicesEnabled(j)
			ReDim Preserve devicesFriendlyName(j)
			ReDim Preserve devicesHardwareId(j)
			ReDim Preserve devicesDescription(j)
			ReDim Preserve devicesInstanceId(j)
			ReDim Preserve devicesDriver(j)
			
			devicesIndexCategories(j) = i
			
			'SetupDiGetDeviceInstanceId获取设备实例 ID。这个 ID 是一个唯一的字符串，用于标识系统中的每个设备实例。
			cchReq = 0
			ret = SetupDiGetDeviceInstanceId(categoriesHSet(i), @categoriesDevInfo(i), NULL, 0, @cchReq)
			If cchReq Then
				devicesInstanceId(j) = CAllocate(cchReq * 2, SizeOf(Byte))
				ret = SetupDiGetDeviceInstanceId(categoriesHSet(i), @categoriesDevInfo(i), devicesInstanceId(j), cchReq, @cchReq)
			End If
			
			'SetupDiGetDeviceRegistryProperty从设备的信息集中检索设备的注册表属性
			cchReq = 0
			regType= 0
			ret = SetupDiGetDeviceRegistryProperty(categoriesHSet(i), @categoriesDevInfo(i), SPDRP_CLASSGUID, @regType, NULL, 0, @cchReq)
			If cchReq Then
				ret = SetupDiGetDeviceRegistryProperty(categoriesHSet(i), @categoriesDevInfo(i), SPDRP_CLASSGUID, @regType, Cast(UByte Ptr, @devicesGUID(j)), SizeOf(devicesGUID(j)), @cchReq)
			End If
			
			cchReq = 0
			regType= 0
			ret = SetupDiGetDeviceRegistryProperty(categoriesHSet(i), @categoriesDevInfo(i), SPDRP_CAPABILITIES, @regType, NULL, 0, @cchReq)
			If cchReq Then
				ret = SetupDiGetDeviceRegistryProperty(categoriesHSet(i), @categoriesDevInfo(i), SPDRP_CAPABILITIES, @regType, Cast(UByte Ptr, @devicesCapabilities(j)), SizeOf(devicesCapabilities(j)), @cchReq)
			End If
			
			cchReq = 0
			regType= 0
			ret = SetupDiGetDeviceRegistryProperty(categoriesHSet(i), @categoriesDevInfo(i), SPDRP_HARDWAREID, @regType, NULL, 0, @cchReq)
			If cchReq Then
				devicesHardwareId(j) = CAllocate(cchReq * 2, SizeOf(Byte))
				ret = SetupDiGetDeviceRegistryProperty(categoriesHSet(i), @categoriesDevInfo(i), SPDRP_HARDWAREID, @regType, Cast(PBYTE, devicesHardwareId(j)), cchReq, @cchReq)
			End If
			
			cchReq = 0
			regType= 0
			ret = SetupDiGetDeviceRegistryProperty(categoriesHSet(i), @categoriesDevInfo(i), SPDRP_FRIENDLYNAME, @regType, NULL, 0, @cchReq)
			If cchReq Then
				devicesFriendlyName(j) = CAllocate(cchReq * 2, SizeOf(Byte))
				ret = SetupDiGetDeviceRegistryProperty(categoriesHSet(i), @categoriesDevInfo(i), SPDRP_FRIENDLYNAME, @regType, Cast(PBYTE, devicesFriendlyName(j)), cchReq, @cchReq)
			End If
			
			cchReq = 0
			regType= 0
			ret = SetupDiGetDeviceRegistryProperty(categoriesHSet(i), @categoriesDevInfo(i), SPDRP_DEVICEDESC, @regType, NULL, 0, @cchReq)
			If cchReq Then
				devicesDescription(j) = CAllocate(cchReq * 2, SizeOf(Byte))
				ret = SetupDiGetDeviceRegistryProperty(categoriesHSet(i), @categoriesDevInfo(i), SPDRP_DEVICEDESC, @regType, Cast(PBYTE, devicesDescription(j)), cchReq, @cchReq)
			End If
			
			cchReq = 0
			regType= 0
			ret = SetupDiGetDeviceRegistryProperty(categoriesHSet(i), @categoriesDevInfo(i), SPDRP_DRIVER, @regType, NULL, 0, @cchReq)
			If cchReq Then
				devicesDriver(j) = CAllocate(cchReq * 2, SizeOf(Byte))
				ret = SetupDiGetDeviceRegistryProperty(categoriesHSet(i), @categoriesDevInfo(i), SPDRP_DRIVER, @regType, Cast(PBYTE, devicesDriver(j)), cchReq, @cchReq)
			End If
			
			ret = SetupDiLoadDeviceIcon(categoriesHSet(i), @categoriesDevInfo(i), 16, 16, NULL, @hicn)
			ico = ImageList_ReplaceIcon(tv->Images->Handle, -1, hicn)
			DestroyIcon(hicn)
			
			Dim fPresent As Integer
			Dim dwStatus As CfgMgDevNodeStatus = 0
			Dim nProbCode As CfgMgrProblems = 0
			Dim bProblem As Boolean = False
			
			If CM_Get_DevNode_Status(@dwStatus, @nProbCode, categoriesDevInfo(i).DevInst, 0) = CR_SUCCESS Then
				If nProbCode<> 0 Then bProblem = True
				If dwStatus And DN_HAS_PROBLEM Then
					bProblem = True
					
					'Dim p As WString Ptr
					'Dim s As DWORD = 0
					's = DeviceProblemText(0, categoriesDevInfo(i).DevInst, nProbCode, NULL, NULL)
					'p = CAllocate(s * 4, SizeOf(Byte))
					'DeviceProblemText(0, categoriesDevInfo(i).DevInst, nProbCode, p, @s)
					'If p Then Deallocate(p)
				End If
				devicesProblem(j) = nProbCode
				devicesStatus(j) = dwStatus
			End If
			
			If ShowHide Then
				fPresent = False
				ret = SetupDiGetDeviceProperty(categoriesHSet(i), @categoriesDevInfo(i), @DEVPKEY_Device_IsPresent, nPropType, @fPresent, SizeOf(fPresent), @cbiReq, 0)
			Else
				fPresent = True
			End If
			
			Dim dwState As DWORD = 0
			Dim dwMask As DWORD = 0
			
			devicesEnabled(j) = True
			If bProblem Then
				Select Case nProbCode
				Case CM_PROB_DISABLED
					devicesEnabled(j) = False
					dwState = INDEXTOOVERLAYMASK(3)
				Case CM_PROB_DEVICE_NOT_THERE
					dwState = INDEXTOOVERLAYMASK(1)
					fPresent = False
				Case Else
					dwState = INDEXTOOVERLAYMASK(2)
				End Select
				dwMask = TVIS_OVERLAYMASK
			End If
			If fPresent = False Then
				dwState = dwState Or TVIS_CUT
				dwMask = dwMask Or TVIS_CUT
			End If
			devicesPresent(j) = fPresent
			
			'显示设备
			Dim sTNode As TreeNode Ptr
			If *devicesFriendlyName(j) = "" Then
				sTNode = pTNode->Nodes.Add(*devicesDescription(j), WStr(j), WStr("Devices"), ico, ico)
			Else
				sTNode = pTNode->Nodes.Add(*devicesFriendlyName(j), WStr(j), WStr("Devices"), ico, ico)
			End If
			If dwMask Then
				TreeView_SetItemState(tv->Handle, sTNode->Handle, dwState, dwMask)
			End If
			
			mIndex += 1
			memset(@categoriesDevInfo(i), 0, SizeOf(categoriesDevInfo(i)))
			categoriesDevInfo(i).cbSize = SizeOf(categoriesDevInfo(i))
		Loop
		
		If categoriesHSet(i) Then SetupDiDestroyDeviceInfoList(categoriesHSet(i))
	Next
	EnumDCount = j
	
	Return EnumCCount + EnumDCount
End Function

Private Function pvEjectDevice(hwndParent As HWND, idx As Integer) As BOOL
	Dim lpVeto As PNP_VETO_TYPE
	Dim lRet As CONFIGRET
	
	lRet = CM_Request_Device_Eject(categoriesDevInfo(devicesIndexCategories(idx)).DevInst, lpVeto, devicesInstanceId(idx), MAX_PATH, 0)
	Return IIf(lRet = CR_SUCCESS, True, False)
End Function

Private Function pvEnableDevice(hwndParent As HWND, idx As Integer, fEnable As BOOL, ShowHide As Boolean) As BOOL
	Dim ret As BOOL
	
	Dim hSet As HDEVINFO
	Dim cDevInfo As SP_DEVINFO_DATA
	
	ret = pvIndexBydevicesInstanceId(hwndParent, @categoriesGuid(devicesIndexCategories(idx)), devicesInstanceId(idx), ShowHide, hSet, @cDevInfo)
	If ret Then
		Dim tParams As SP_PROPCHANGE_PARAMS
		Dim ret As BOOL
		
		tParams.ClassInstallHeader.cbSize = SizeOf(SP_CLASSINSTALL_HEADER)
		tParams.ClassInstallHeader.InstallFunction = DIF_PROPERTYCHANGE
		tParams.StateChange = IIf(fEnable, DICS_ENABLE, DICS_DISABLE)
		tParams.Scope = DICS_FLAG_GLOBAL 'DICS_FLAG_CONFIGSPECIFIC
		'tParams.Scope = DICS_FLAG_GLOBAL
		
		ret = SetupDiSetClassInstallParams(hSet, @cDevInfo, @tParams.ClassInstallHeader, SizeOf(SP_PROPCHANGE_PARAMS))
		If ret Then
			ret = SetupDiCallClassInstaller(DIF_PROPERTYCHANGE, hSet, @cDevInfo)
		End If
	End If
	
	If hSet <> NULL Or hSet <> INVALID_HANDLE_VALUE Then SetupDiDestroyDeviceInfoList(hSet)
	Return ret
End Function

Private Function pvRemoveDevice(hwndParent As HWND, idx As Integer, ShowHide As Boolean) As BOOL
	Dim ret As BOOL
	
	Dim hSet As HDEVINFO
	Dim cDevInfo As SP_DEVINFO_DATA
	
	ret = pvIndexBydevicesInstanceId(hwndParent, @categoriesGuid(devicesIndexCategories(idx)), devicesInstanceId(idx), ShowHide, hSet, @cDevInfo)
	If ret Then
		Dim tParams As SP_REMOVEDEVICE_PARAMS
		
		tParams.ClassInstallHeader.cbSize = SizeOf(SP_CLASSINSTALL_HEADER)
		tParams.ClassInstallHeader.InstallFunction = DIF_REMOVE
		tParams.Scope = DI_REMOVEDEVICE_GLOBAL
		
		ret = SetupDiSetClassInstallParams(hSet, @cDevInfo, @tParams.ClassInstallHeader, SizeOf(SP_REMOVEDEVICE_PARAMS))
		If ret Then
			ret = SetupDiCallClassInstaller(DIF_REMOVE, hSet, @cDevInfo)
		End If
	End If
	If hSet <> NULL Or hSet <> INVALID_HANDLE_VALUE Then SetupDiDestroyDeviceInfoList(hSet)
	Return ret
End Function

Private Function pvUninstallDevice(hwndParent As HWND, idx As Integer, ShowHide As Boolean) As BOOL
	Dim ret As WINBOOL
	
	Dim hSet As HDEVINFO
	Dim cDevInfo As SP_DEVINFO_DATA
	
	ret = pvIndexBydevicesInstanceId(hwndParent, @categoriesGuid(devicesIndexCategories(idx)), devicesInstanceId(idx), ShowHide, hSet, @cDevInfo)
	If ret Then
		ret = SetupDiRemoveDevice(hSet, @cDevInfo)
	End If
	If hSet <> NULL Or hSet <> INVALID_HANDLE_VALUE Then SetupDiDestroyDeviceInfoList(hSet)
	Return ret
End Function

Private Function pvUpdateDevice(hwndParent As HWND, idx As Integer, ShowHide As Boolean) As BOOL
	Dim ret As WINBOOL
	
	Dim hSet As HDEVINFO
	Dim cDevInfo As SP_DEVINFO_DATA
	
	ret = pvIndexBydevicesInstanceId(hwndParent, @categoriesGuid(devicesIndexCategories(idx)), devicesInstanceId(idx), ShowHide, hSet, @cDevInfo)
	If ret Then
		ret = SetupDiInstallDevice(hSet, @cDevInfo)
	End If
	If hSet <> NULL Or hSet <> INVALID_HANDLE_VALUE Then SetupDiDestroyDeviceInfoList(hSet)
	Return ret
End Function

Private Function pvShowPropPage(hwndParent As HWND, idx As Integer) As BOOL
	Return DevicePropertiesEx(hwndParent, NULL, devicesInstanceId(idx), DEVPROP_SHOW_RESOURCE_TAB, False)
End Function


