'DeviceExplorer.bi
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.
' 通过windows api实现如device manager一样的update driver, uninstall device, eject device的功能
' 翻译了cfgmgr32, devguid, devpkey, devpropdef, newdev等相关头文件
' https://learn.microsoft.com/en-us/windows/win32/devinst/setupapi-h

' 参考了TwinBasic的样例
' https://github.com/fafalone/DeviceExplorer

#include once "mff/Form.bi"
#include once "mff/TreeView.bi"

#include once "windows.bi"
#include once "win/setupapi.bi"
#include once "vbcompat.bi"

#include once "cfgmgr32.bi"
#include once "newdev.bi"

#define DEFINE_GUID(n, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8) Dim Shared n As GUID = (l, w1, w2, {b1, b2, b3, b4, b5, b6, b7, b8})
#define DEFINE_PROPERTYKEY(n, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8, pid) Dim Shared n As PROPERTYKEY = (l, w1, w2, {b1, b2, b3, b4, b5, b6, b7, b8}, pid)

'#define DEFINE_GUID(n, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8) Extern n Alias #n As GUID : Dim n As GUID = (l, w1, w2, {b1, b2, b3, b4, b5, b6, b7, b8})
'#define DEFINE_PROPERTYKEY(n, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8, pid) Extern n Alias #n As PROPERTYKEY : Dim n As PROPERTYKEY = (l, w1, w2, {b1, b2, b3, b4, b5, b6, b7, b8}, pid)

#include once "devpkey.bi"
#include once "devguid.bi"

#include once "../USBView/USBView.bi"

Dim Shared SystemPath As WString * MAX_PATH

Dim Shared categoriesHSet(Any) As HDEVINFO
Dim Shared categoriesDevInfo(Any) As SP_DEVINFO_DATA
Dim Shared categoriesGuid(Any) As UUID
Dim Shared categoriesName(Any) As WString Ptr
Dim Shared categoriesDescription(Any) As WString Ptr
Dim Shared categoriesCount As Integer = -1

Dim Shared devicesIndexCategories(Any) As Integer
Dim Shared devicesCapabilities(Any) As SetupDevCap
Dim Shared devicesStatus(Any) As CfgMgDevNodeStatus
Dim Shared devicesProblem(Any) As CfgMgrProblems
Dim Shared devicesPresent(Any) As Boolean
Dim Shared devicesEnabled(Any) As Boolean
Dim Shared devicesGUID(Any) As UUID Ptr
Dim Shared devicesFriendlyName(Any) As WString Ptr
Dim Shared devicesDescription(Any) As WString Ptr
Dim Shared devicesHardwareId(Any) As WString Ptr
Dim Shared devicesInstanceId(Any) As WString Ptr
Dim Shared devicesDriver(Any) As WString Ptr
Dim Shared devicesCount As Integer = -1
Dim Shared devicesSelected As Integer = -1

Dim Shared EnumCCount As Integer = 0
Dim Shared EnumDCount As Integer = 0

Using My.Sys.Forms

Private Function Capabilities2Str(inpra As SetupDevCap) As String
	Dim strrtn As String
	If inpra And CM_DEVCAP_LOCKSUPPORTED Then       strrtn += !"(&H00000001) ' LOCKSUPPORTED\r\n"
	If inpra And CM_DEVCAP_EJECTSUPPORTED Then      strrtn += !"(&H00000002) ' EJECTSUPPORTED\r\n"
	If inpra And CM_DEVCAP_REMOVABLE Then           strrtn += !"(&H00000004) ' REMOVABLE\r\n"
	If inpra And CM_DEVCAP_DOCKDEVICE Then          strrtn += !"(&H00000008) ' DOCKDEVICE\r\n"
	If inpra And CM_DEVCAP_UNIQUEID Then            strrtn += !"(&H00000010) ' UNIQUEID\r\n"
	If inpra And CM_DEVCAP_SILENTINSTALL Then       strrtn += !"(&H00000020) ' SILENTINSTALL\r\n"
	If inpra And CM_DEVCAP_RAWDEVICEOK Then         strrtn += !"(&H00000040) ' RAWDEVICEOK\r\n"
	If inpra And CM_DEVCAP_SURPRISEREMOVALOK Then   strrtn += !"(&H00000080) ' SURPRISEREMOVALOK\r\n"
	If inpra And CM_DEVCAP_HARDWAREDISABLED Then    strrtn += !"(&H00000100) ' HARDWAREDISABLED\r\n"
	If inpra And CM_DEVCAP_NONDYNAMIC Then          strrtn += !"(&H00000200) ' NONDYNAMIC\r\n"
	If inpra And CM_DEVCAP_SECUREDEVICE Then        strrtn += !"(&H00000400) ' SECUREDEVICE\r\n"
	Return strrtn
End Function

Private Function NodeStatus2Str(inpra As CfgMgDevNodeStatus) As String
	Dim strrtn As String
	If inpra And DN_ROOT_ENUMERATED Then        strrtn += !"(&H00000001) ' Was enumerated by ROOT\r\n"
	If inpra And DN_DRIVER_LOADED Then          strrtn += !"(&H00000002) ' Has Register_Device_Driver\r\n"
	If inpra And DN_ENUM_LOADED Then            strrtn += !"(&H00000004) ' Has Register_Enumerator\r\n"
	If inpra And DN_STARTED Then                strrtn += !"(&H00000008) ' Is currently configured\r\n"
	If inpra And DN_MANUAL Then                 strrtn += !"(&H00000010) ' Manually installed\r\n"
	If inpra And DN_NEED_TO_ENUM Then           strrtn += !"(&H00000020) ' May need reenumeration\r\n"
	If inpra And DN_NOT_FIRST_TIME Then         strrtn += !"(&H00000040) ' Has received a config\r\n"
	If inpra And DN_HARDWARE_ENUM Then          strrtn += !"(&H00000080) ' Enum generates hardware ID\r\n"
	If inpra And DN_LIAR Then                   strrtn += !"(&H00000100) ' Lied about can reconfig once\r\n"
	If inpra And DN_HAS_MARK Then               strrtn += !"(&H00000200) ' Not CM_Create_DevInst lately\r\n"
	If inpra And DN_HAS_PROBLEM Then            strrtn += !"(&H00000400) ' Need device installer\r\n"
	If inpra And DN_FILTERED Then               strrtn += !"(&H00000800) ' Is filtered\r\n"
	If inpra And DN_MOVED Then                  strrtn += !"(&H00001000) ' Has been moved\r\n"
	If inpra And DN_DISABLEABLE Then            strrtn += !"(&H00002000) ' Can be disabled\r\n"
	If inpra And DN_REMOVABLE Then              strrtn += !"(&H00004000) ' Can be removed\r\n"
	If inpra And DN_PRIVATE_PROBLEM Then        strrtn += !"(&H00008000) ' Has a private problem\r\n"
	If inpra And DN_MF_PARENT Then              strrtn += !"(&H00010000) ' Multi function parent\r\n"
	If inpra And DN_MF_CHILD Then               strrtn += !"(&H00020000) ' Multi function child\r\n"
	If inpra And DN_WILL_BE_REMOVED Then        strrtn += !"(&H00040000) ' DevInst is being removed\r\n"
	'  Windows 4 OPK2 Flags\r\n"
	If inpra And DN_NOT_FIRST_TIMEE Then        strrtn += !"(&H00080000) ' S: Has received a config enumerate\r\n"
	If inpra And DN_STOP_FREE_RES Then          strrtn += !"(&H00100000) ' S: When child is stopped, free resources\r\n"
	If inpra And DN_REBAL_CANDIDATE Then        strrtn += !"(&H00200000) ' S: Don't skip during rebalance\r\n"
	If inpra And DN_BAD_PARTIAL Then            strrtn += !"(&H00400000) ' S: This devnode's log_confs do not have same resources\r\n"
	If inpra And DN_NT_ENUMERATOR Then          strrtn += !"(&H00800000) ' S: This devnode's is an NT enumerator\r\n"
	If inpra And DN_NT_DRIVER Then              strrtn += !"(&H01000000) ' S: This devnode's is an NT driver\r\n"
	'  Windows 4.1 Flags\r\n"
	If inpra And DN_NEEDS_LOCKING Then          strrtn += !"(&H02000000) ' S: Devnode need lock resume processing\r\n"
	If inpra And DN_ARM_WAKEUP Then             strrtn += !"(&H04000000) ' S: Devnode can be the wakeup device\r\n"
	If inpra And DN_APM_ENUMERATOR Then         strrtn += !"(&H08000000) ' S: APM aware enumerator\r\n"
	If inpra And DN_APM_DRIVER Then             strrtn += !"(&H10000000) ' S: APM aware driver\r\n"
	If inpra And DN_SILENT_INSTALL Then         strrtn += !"(&H20000000) ' S: Silent install\r\n"
	If inpra And DN_NO_SHOW_IN_DM Then          strrtn += !"(&H40000000) ' S: No show in device manager\r\n"
	If inpra And DN_BOOT_LOG_PROB Then          strrtn += !"(&H80000000) ' S: Had a problem during preassignment of boot log conf\r\n"
	If inpra And DN_NEED_RESTART Then           strrtn += !"DN_LIAR ' System needs to be restarted for this Devnode to work properly\r\n"
	If inpra And DN_DRIVER_BLOCKED Then         strrtn += !"DN_NOT_FIRST_TIME ' One or more drivers are blocked from loading for this Devnode\r\n"
	If inpra And DN_LEGACY_DRIVER Then          strrtn += !"DN_MOVED ' This device is using a legacy driver\r\n"
	If inpra And DN_CHILD_WITH_INVALID_ID Then  strrtn += !"DN_HAS_MARK ' One or more children have invalid ID(s)\r\n"
	If inpra And DN_DEVICE_DISCONNECTED Then    strrtn += !"DN_NEEDS_LOCKING ' The function driver for a device reported that the device is not connected.  Typically this means a wireless device is out of range.\r\n"
	If inpra And DN_QUERY_REMOVE_PENDING Then   strrtn += !"DN_MF_PARENT ' Device is part of a set of related devices collectively pending query-removal\r\n"
	If inpra And DN_QUERY_REMOVE_ACTIVE Then    strrtn += !"DN_MF_CHILD ' Device is actively engaged in a query-remove IRPl\r\n"
	Return strrtn
End Function

Private Function Problems2Str(inpra As CfgMgrProblems) As String
	Dim strrtn As String
	Select Case inpra
	Case CM_PROB_NOT_CONFIGURED
		strrtn = !"(&H00000001) ' no config for device"
	Case CM_PROB_DEVLOADER_FAILED
		strrtn = !"(&H00000002) ' service load failed"
	Case CM_PROB_OUT_OF_MEMORY
		strrtn = !"(&H00000003) ' out of memory"
	Case CM_PROB_ENTRY_IS_WRONG_TYPE
		strrtn = !"(&H00000004) ' CM_PROB_ENTRY_IS_WRONG_TYPE"
	Case CM_PROB_LACKED_ARBITRATOR
		strrtn = !"(&H00000005) ' CM_PROB_LACKED_ARBITRATOR"
	Case CM_PROB_BOOT_CONFIG_CONFLICT
		strrtn = !"(&H00000006) ' boot config conflict"
	Case CM_PROB_FAILED_FILTER
		strrtn = !"(&H00000007) ' CM_PROB_FAILED_FILTER"
	Case CM_PROB_DEVLOADER_NOT_FOUND
		strrtn = !"(&H00000008) ' Devloader not found"
	Case CM_PROB_INVALID_DATA
		strrtn = !"(&H00000009) ' Invalid ID"
	Case CM_PROB_FAILED_START
		strrtn = !"(&H0000000A) ' CM_PROB_FAILED_START"
	Case CM_PROB_LIAR
		strrtn = !"(&H0000000B) ' CM_PROB_LIAR"
	Case CM_PROB_NORMAL_CONFLICT
		strrtn = !"(&H0000000C) ' config conflict"
	Case CM_PROB_NOT_VERIFIED
		strrtn = !"(&H0000000D) ' CM_PROB_NOT_VERIFIED"
	Case CM_PROB_NEED_RESTART
		strrtn = !"(&H0000000E) ' requires restart"
	Case CM_PROB_REENUMERATION
		strrtn = !"(&H0000000F) ' CM_PROB_REENUMERATION"
	Case CM_PROB_PARTIAL_LOG_CONF
		strrtn = !"(&H00000010) ' CM_PROB_PARTIAL_LOG_CONF"
	Case CM_PROB_UNKNOWN_RESOURCE
		strrtn = !"(&H00000011) ' unknown res type"
	Case CM_PROB_REINSTALL
		strrtn = !"(&H00000012) ' CM_PROB_REINSTALL"
	Case CM_PROB_REGISTRY
		strrtn = !"(&H00000013) ' CM_PROB_REGISTRY"
	Case CM_PROB_VXDLDR
		strrtn = !"(&H00000014) ' WINDOWS 95 ONLY"
	Case CM_PROB_WILL_BE_REMOVED
		strrtn = !"(&H00000015) ' devinst will remove"
	Case CM_PROB_DISABLED
		strrtn = !"(&H00000016) ' devinst is disabled"
	Case CM_PROB_DEVLOADER_NOT_READY
		strrtn = !"(&H00000017) ' Devloader not ready"
	Case CM_PROB_DEVICE_NOT_THERE
		strrtn = !"(&H00000018) ' device doesn't exist"
	Case CM_PROB_MOVED
		strrtn = !"(&H00000019) ' CM_PROB_MOVED"
	Case CM_PROB_TOO_EARLY
		strrtn = !"(&H0000001A) ' CM_PROB_TOO_EARLY"
	Case CM_PROB_NO_VALID_LOG_CONF
		strrtn = !"(&H0000001B) ' no valid log config"
	Case CM_PROB_FAILED_INSTALL
		strrtn = !"(&H0000001C) ' install failed"
	Case CM_PROB_HARDWARE_DISABLED
		strrtn = !"(&H0000001D) ' device disabled"
	Case CM_PROB_CANT_SHARE_IRQ
		strrtn = !"(&H0000001E) ' can't share IRQ"
	Case CM_PROB_FAILED_ADD
		strrtn = !"(&H0000001F) ' driver failed add"
	Case CM_PROB_DISABLED_SERVICE
		strrtn = !"(&H00000020) ' service's Start"
	Case CM_PROB_TRANSLATION_FAILED
		strrtn = !"(&H00000021) ' resource translation failed"
	Case CM_PROB_NO_SOFTCONFIG
		strrtn = !"(&H00000022) ' no soft config"
	Case CM_PROB_BIOS_TABLE
		strrtn = !"(&H00000023) ' device missing in BIOS table"
	Case CM_PROB_IRQ_TRANSLATION_FAILED
		strrtn = !"(&H00000024) ' IRQ translator failed"
	Case CM_PROB_FAILED_DRIVER_ENTRY
		strrtn = !"(&H00000025) ' DriverEntry() failed."
	Case CM_PROB_DRIVER_FAILED_PRIOR_UNLOAD
		strrtn = !"(&H00000026) ' Driver should have unloaded."
	Case CM_PROB_DRIVER_FAILED_LOAD
		strrtn = !"(&H00000027) ' Driver load unsuccessful."
	Case CM_PROB_DRIVER_SERVICE_KEY_INVALID
		strrtn = !"(&H00000028) ' Error accessing driver's service key"
	Case CM_PROB_LEGACY_SERVICE_NO_DEVICES
		strrtn = !"(&H00000029) ' Loaded legacy service created no devices"
	Case CM_PROB_DUPLICATE_DEVICE
		strrtn = !"(&H0000002A) ' Two devices were discovered with the same name"
	Case CM_PROB_FAILED_POST_START
		strrtn = !"(&H0000002B) ' The drivers set the device state to failed"
	Case CM_PROB_HALTED
		strrtn = !"(&H0000002C) ' This device was failed post start via usermode"
	Case CM_PROB_PHANTOM
		strrtn = !"(&H0000002D) ' The devinst currently exists only in the registry"
	Case CM_PROB_SYSTEM_SHUTDOWN
		strrtn = !"(&H0000002E) ' The system is shutting down"
	Case CM_PROB_HELD_FOR_EJECT
		strrtn = !"(&H0000002F) ' The device is offline awaiting removal"
	Case CM_PROB_DRIVER_BLOCKED
		strrtn = !"(&H00000030) ' One or more drivers is blocked from loading"
	Case CM_PROB_REGISTRY_TOO_LARGE
		strrtn = !"(&H00000031) ' System hive has grown too large"
	Case CM_PROB_SETPROPERTIES_FAILED
		strrtn = !"(&H00000032) ' Failed to apply one or more registry properties"
	Case CM_PROB_WAITING_ON_DEPENDENCY
		strrtn = !"(&H00000033) ' Device is stalled waiting on a dependency to start"
	Case CM_PROB_UNSIGNED_DRIVER
		strrtn = !"(&H00000034) ' Failed load driver due to unsigned image."
	Case CM_PROB_USED_BY_DEBUGGER
		strrtn = !"(&H00000035) ' Device is being used by kernel debugger"
	Case CM_PROB_DEVICE_RESET
		strrtn = !"(&H00000036) ' Device is being reset"
	Case CM_PROB_CONSOLE_LOCKED
		strrtn = !"(&H00000037) ' Device is blocked while console is locked"
	Case CM_PROB_NEED_CLASS_CONFIG
		strrtn = !"(&H00000038) ' Device needs extended class configuration to start"
	Case CM_PROB_GUEST_ASSIGNMENT_FAILED
		strrtn = !"(&H00000039) ' Assignment to guest partition failed"
	End Select
	Return strrtn
End Function

#ifndef __USE_MAKE__
	#include once "DeviceExplorer.bas"
#endif

