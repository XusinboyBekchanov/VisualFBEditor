'cfgmgr32.bi
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "crt.bi"
#include once "win/basetyps.bi"
#include once "win/ole2.bi"

#inclib "cfgmgr32"

'cfgmgr32.h
Enum PNP_VETO_TYPE
	PNP_VetoTypeUnknown
	PNP_VetoLegacyDevice
	PNP_VetoPendingClose
	PNP_VetoWindowsApp
	PNP_VetoWindowsService
	PNP_VetoOutstandingOpen
	PNP_VetoDevice
	PNP_VetoDriver
	PNP_VetoIllegalDeviceRequest
	PNP_VetoInsufficientPower
	PNP_VetoNonDisableable
	PNP_VetoLegacyDriver
	PNP_VetoInsufficientRights
	PNP_VetoAlreadyRemoved
End Enum

Enum CONFIGRET
	CR_SUCCESS = (&H00000000)
	CR_DEFAULT = (&H00000001)
	CR_OUT_OF_MEMORY = (&H00000002)
	CR_INVALID_POINTER = (&H00000003)
	CR_INVALID_FLAG = (&H00000004)
	CR_INVALID_DEVNODE = (&H00000005)
	CR_INVALID_DEVINST = CR_INVALID_DEVNODE
	CR_INVALID_RES_DES = (&H00000006)
	CR_INVALID_LOG_CONF = (&H00000007)
	CR_INVALID_ARBITRATOR = (&H00000008)
	CR_INVALID_NODELIST = (&H00000009)
	CR_DEVNODE_HAS_REQS = (&H0000000A)
	CR_DEVINST_HAS_REQS = CR_DEVNODE_HAS_REQS
	CR_INVALID_RESOURCEID = (&H0000000B)
	CR_DLVXD_NOT_FOUND = (&H0000000C)  ' WIN 95 ONLY
	CR_NO_SUCH_DEVNODE = (&H0000000D)
	CR_NO_SUCH_DEVINST = CR_NO_SUCH_DEVNODE
	CR_NO_MORE_LOG_CONF = (&H0000000E)
	CR_NO_MORE_RES_DES = (&H0000000F)
	CR_ALREADY_SUCH_DEVNODE = (&H00000010)
	CR_ALREADY_SUCH_DEVINST = CR_ALREADY_SUCH_DEVNODE
	CR_INVALID_RANGE_LIST = (&H00000011)
	CR_INVALID_RANGE = (&H00000012)
	CR_FAILURE = (&H00000013)
	CR_NO_SUCH_LOGICAL_DEV = (&H00000014)
	CR_CREATE_BLOCKED = (&H00000015)
	CR_NOT_SYSTEM_VM = (&H00000016)  ' WIN 95 ONLY
	CR_REMOVE_VETOED = (&H00000017)
	CR_APM_VETOED = (&H00000018)
	CR_INVALID_LOAD_TYPE = (&H00000019)
	CR_BUFFER_SMALL = (&H0000001A)
	CR_NO_ARBITRATOR = (&H0000001B)
	CR_NO_REGISTRY_HANDLE = (&H0000001C)
	CR_REGISTRY_ERROR = (&H0000001D)
	CR_INVALID_DEVICE_ID = (&H0000001E)
	CR_INVALID_DATA = (&H0000001F)
	CR_INVALID_API = (&H00000020)
	CR_DEVLOADER_NOT_READY = (&H00000021)
	CR_NEED_RESTART = (&H00000022)
	CR_NO_MORE_HW_PROFILES = (&H00000023)
	CR_DEVICE_NOT_THERE = (&H00000024)
	CR_NO_SUCH_VALUE = (&H00000025)
	CR_WRONG_TYPE = (&H00000026)
	CR_INVALID_PRIORITY = (&H00000027)
	CR_NOT_DISABLEABLE = (&H00000028)
	CR_FREE_RESOURCES = (&H00000029)
	CR_QUERY_VETOED = (&H0000002A)
	CR_CANT_SHARE_IRQ = (&H0000002B)
	CR_NO_DEPENDENT = (&H0000002C)
	CR_SAME_RESOURCES = (&H0000002D)
	CR_NO_SUCH_REGISTRY_KEY = (&H0000002E)
	CR_INVALID_MACHINENAME = (&H0000002F)   ' NT ONLY
	CR_REMOTE_COMM_FAILURE = (&H00000030)   ' NT ONLY
	CR_MACHINE_UNAVAILABLE = (&H00000031)   ' NT ONLY
	CR_NO_CM_SERVICES = (&H00000032)        ' NT ONLY
	CR_ACCESS_DENIED = (&H00000033)         ' NT ONLY
	CR_CALL_NOT_IMPLEMENTED = (&H00000034)
	CR_INVALID_PROPERTY = (&H00000035)
	CR_DEVICE_INTERFACE_ACTIVE = (&H00000036)
	CR_NO_SUCH_DEVICE_INTERFACE = (&H00000037)
	CR_INVALID_REFERENCE_STRING = (&H00000038)
	CR_INVALID_CONFLICT_LIST = (&H00000039)
	CR_INVALID_INDEX = (&H0000003A)
	CR_INVALID_STRUCTURE_SIZE = (&H0000003B)
End Enum

Enum CfgMgDevNodeStatus
	DN_ROOT_ENUMERATED = (&H00000001)       ' Was enumerated by ROOT
	DN_DRIVER_LOADED = (&H00000002)         ' Has Register_Device_Driver
	DN_ENUM_LOADED = (&H00000004)           ' Has Register_Enumerator
	DN_STARTED = (&H00000008)               ' Is currently configured
	DN_MANUAL = (&H00000010)                ' Manually installed
	DN_NEED_TO_ENUM = (&H00000020)          ' May need reenumeration
	DN_NOT_FIRST_TIME = (&H00000040)        ' Has received a config
	DN_HARDWARE_ENUM = (&H00000080)         ' Enum generates hardware ID
	DN_LIAR = (&H00000100)                  ' Lied about can reconfig once
	DN_HAS_MARK = (&H00000200)              ' Not CM_Create_DevInst lately
	DN_HAS_PROBLEM = (&H00000400)           ' Need device installer
	DN_FILTERED = (&H00000800)              ' Is filtered
	DN_MOVED = (&H00001000)                 ' Has been moved
	DN_DISABLEABLE = (&H00002000)           ' Can be disabled
	DN_REMOVABLE = (&H00004000)             ' Can be removed
	DN_PRIVATE_PROBLEM = (&H00008000)       ' Has a private problem
	DN_MF_PARENT = (&H00010000)             ' Multi function parent
	DN_MF_CHILD = (&H00020000)              ' Multi function child
	DN_WILL_BE_REMOVED = (&H00040000)       ' DevInst is being removed
	'  Windows 4 OPK2 Flags
	DN_NOT_FIRST_TIMEE = &H00080000         ' S: Has received a config enumerate
	DN_STOP_FREE_RES = &H00100000           ' S: When child is stopped, free resources
	DN_REBAL_CANDIDATE = &H00200000         ' S: Don't skip during rebalance
	DN_BAD_PARTIAL = &H00400000             ' S: This devnode's log_confs do not have same resources
	DN_NT_ENUMERATOR = &H00800000           ' S: This devnode's is an NT enumerator
	DN_NT_DRIVER = &H01000000               ' S: This devnode's is an NT driver
	'  Windows 4.1 Flags
	DN_NEEDS_LOCKING = &H02000000           ' S: Devnode need lock resume processing
	DN_ARM_WAKEUP = &H04000000              ' S: Devnode can be the wakeup device
	DN_APM_ENUMERATOR = &H08000000          ' S: APM aware enumerator
	DN_APM_DRIVER = &H10000000              ' S: APM aware driver
	DN_SILENT_INSTALL = &H20000000          ' S: Silent install
	DN_NO_SHOW_IN_DM = &H40000000           ' S: No show in device manager
	DN_BOOT_LOG_PROB = &H80000000           ' S: Had a problem during preassignment of boot log conf
	DN_NEED_RESTART = DN_LIAR               ' System needs to be restarted for this Devnode to work properly
	DN_DRIVER_BLOCKED = DN_NOT_FIRST_TIME   ' One or more drivers are blocked from loading for this Devnode
	DN_LEGACY_DRIVER = DN_MOVED             ' This device is using a legacy driver
	DN_CHILD_WITH_INVALID_ID = DN_HAS_MARK  ' One or more children have invalid ID(s)
	DN_DEVICE_DISCONNECTED = DN_NEEDS_LOCKING   ' The function driver for a device reported that the device is not connected.  Typically this means a wireless device is out of range.
	DN_QUERY_REMOVE_PENDING = DN_MF_PARENT  ' Device is part of a set of related devices collectively pending query-removal
	DN_QUERY_REMOVE_ACTIVE = DN_MF_CHILD    ' Device is actively engaged in a query-remove IRP
End Enum

Enum CfgMgrProblems
	CM_PROB_NOT_CONFIGURED = (&H00000001)       ' no config for device
	CM_PROB_DEVLOADER_FAILED = (&H00000002)     ' service load failed
	CM_PROB_OUT_OF_MEMORY = (&H00000003)        ' out of memory
	CM_PROB_ENTRY_IS_WRONG_TYPE = (&H00000004)  '
	CM_PROB_LACKED_ARBITRATOR = (&H00000005)    '
	CM_PROB_BOOT_CONFIG_CONFLICT = (&H00000006) ' boot config conflict
	CM_PROB_FAILED_FILTER = (&H00000007)        '
	CM_PROB_DEVLOADER_NOT_FOUND = (&H00000008)  ' Devloader not found
	CM_PROB_INVALID_DATA = (&H00000009)         ' Invalid ID
	CM_PROB_FAILED_START = (&H0000000A)         '
	CM_PROB_LIAR = (&H0000000B)                 '
	CM_PROB_NORMAL_CONFLICT = (&H0000000C)      ' config conflict
	CM_PROB_NOT_VERIFIED = (&H0000000D)         '
	CM_PROB_NEED_RESTART = (&H0000000E)         ' requires restart
	CM_PROB_REENUMERATION = (&H0000000F)        '
	CM_PROB_PARTIAL_LOG_CONF = (&H00000010)     '
	CM_PROB_UNKNOWN_RESOURCE = (&H00000011)     ' unknown res type
	CM_PROB_REINSTALL = (&H00000012)            '
	CM_PROB_REGISTRY = (&H00000013)             '
	CM_PROB_VXDLDR = (&H00000014)               ' WINDOWS 95 ONLY
	CM_PROB_WILL_BE_REMOVED = (&H00000015)      ' devinst will remove
	CM_PROB_DISABLED = (&H00000016)             ' devinst is disabled
	CM_PROB_DEVLOADER_NOT_READY = (&H00000017)  ' Devloader not ready
	CM_PROB_DEVICE_NOT_THERE = (&H00000018)     ' device doesn't exist
	CM_PROB_MOVED = (&H00000019)                '
	CM_PROB_TOO_EARLY = (&H0000001A)            '
	CM_PROB_NO_VALID_LOG_CONF = (&H0000001B)    ' no valid log config
	CM_PROB_FAILED_INSTALL = (&H0000001C)       ' install failed
	CM_PROB_HARDWARE_DISABLED = (&H0000001D)    ' device disabled
	CM_PROB_CANT_SHARE_IRQ = (&H0000001E)       ' can't share IRQ
	CM_PROB_FAILED_ADD = (&H0000001F)           ' driver failed add
	CM_PROB_DISABLED_SERVICE = (&H00000020)     ' service's Start = 4
	CM_PROB_TRANSLATION_FAILED = (&H00000021)   ' resource translation failed
	CM_PROB_NO_SOFTCONFIG = (&H00000022)        ' no soft config
	CM_PROB_BIOS_TABLE = (&H00000023)           ' device missing in BIOS table
	CM_PROB_IRQ_TRANSLATION_FAILED = (&H00000024)       ' IRQ translator failed
	CM_PROB_FAILED_DRIVER_ENTRY = (&H00000025)  ' DriverEntry() failed.
	CM_PROB_DRIVER_FAILED_PRIOR_UNLOAD = (&H00000026)   ' Driver should have unloaded.
	CM_PROB_DRIVER_FAILED_LOAD = (&H00000027)   ' Driver load unsuccessful.
	CM_PROB_DRIVER_SERVICE_KEY_INVALID = (&H00000028)   ' Error accessing driver's service key
	CM_PROB_LEGACY_SERVICE_NO_DEVICES = (&H00000029)    ' Loaded legacy service created no devices
	CM_PROB_DUPLICATE_DEVICE = (&H0000002A)     ' Two devices were discovered with the same name
	CM_PROB_FAILED_POST_START = (&H0000002B)    ' The drivers set the device state to failed
	CM_PROB_HALTED = (&H0000002C)               ' This device was failed post start via usermode
	CM_PROB_PHANTOM = (&H0000002D)              ' The devinst currently exists only in the registry
	CM_PROB_SYSTEM_SHUTDOWN = (&H0000002E)      ' The system is shutting down
	CM_PROB_HELD_FOR_EJECT = (&H0000002F)       ' The device is offline awaiting removal
	CM_PROB_DRIVER_BLOCKED = (&H00000030)       ' One or more drivers is blocked from loading
	CM_PROB_REGISTRY_TOO_LARGE = (&H00000031)   ' System hive has grown too large
	CM_PROB_SETPROPERTIES_FAILED = (&H00000032) ' Failed to apply one or more registry properties
	CM_PROB_WAITING_ON_DEPENDENCY = (&H00000033)        ' Device is stalled waiting on a dependency to start
	CM_PROB_UNSIGNED_DRIVER = (&H00000034)      ' Failed load driver due to unsigned image.
	CM_PROB_USED_BY_DEBUGGER = (&H00000035)     ' Device is being used by kernel debugger
	CM_PROB_DEVICE_RESET = (&H00000036)         ' Device is being reset
	CM_PROB_CONSOLE_LOCKED = (&H00000037)       ' Device is blocked while console is locked
	CM_PROB_NEED_CLASS_CONFIG = (&H00000038)    ' Device needs extended class configuration to start
	CM_PROB_GUEST_ASSIGNMENT_FAILED = (&H00000039)      ' Assignment to guest partition failed
End Enum

Enum CmGetIdListFlags
	CM_GETIDLIST_FILTER_NONE = (&H00000000)
	CM_GETIDLIST_FILTER_ENUMERATOR = (&H00000001)
	CM_GETIDLIST_FILTER_SERVICE = (&H00000002)
	CM_GETIDLIST_FILTER_EJECTRELATIONS = (&H00000004)
	CM_GETIDLIST_FILTER_REMOVALRELATIONS = (&H00000008)
	CM_GETIDLIST_FILTER_POWERRELATIONS = (&H00000010)
	CM_GETIDLIST_FILTER_BUSRELATIONS = (&H00000020)
	CM_GETIDLIST_DONOTGENERATE = (&H10000040)
	' #if (WINVER <= _WIN32_WINNT_LONGHORN)
	CM_GETIDLIST_FILTER_BITS_VISTA = (&H1000007F)
	' #endif // (WINVER <= _WIN32_WINNT_LONGHORN)
	' #if (WINVER >= _WIN32_WINNT_WIN7)
	CM_GETIDLIST_FILTER_TRANSPORTRELATIONS = (&H00000080)
	CM_GETIDLIST_FILTER_PRESENT = (&H00000100)
	CM_GETIDLIST_FILTER_CLASS = (&H00000200)
	CM_GETIDLIST_FILTER_BITS = (&H100003FF)
End Enum

Enum CmDisableDNFlags
	CM_DISABLE_POLITE = (&H00000000)    ' Ask the driver
	CM_DISABLE_ABSOLUTE = (&H00000001)  ' Don't ask the driver
	CM_DISABLE_HARDWARE = (&H00000002)  ' Don't ask the driver, and won't be restarteable
	CM_DISABLE_UI_NOT_OK = (&H00000004) ' Don't popup any veto API
	CM_DISABLE_PERSIST = (&H00000008)   ' Persists through restart by setting CONFIGFLAG_DISABLED in the registry
	CM_DISABLE_BITS = (&H0000000F)      ' The bits for the disable function
End Enum

Const MAX_DEVICE_ID_LEN = 200
Const MAX_DEVNODE_ID_LEN = MAX_DEVICE_ID_LEN
Const MAX_GUID_STRING_LEN = 39 ' 38 chars + terminator null

Enum ConfigMgrNotifyFilterFlags
	CM_NOTIFY_FILTER_FLAG_ALL_INTERFACE_CLASSES = &H00000001
	CM_NOTIFY_FILTER_FLAG_ALL_DEVICE_INSTANCES = &H00000002
	CM_NOTIFY_FILTER_VALID_FLAGS = (CM_NOTIFY_FILTER_FLAG_ALL_INTERFACE_CLASSES Or CM_NOTIFY_FILTER_FLAG_ALL_DEVICE_INSTANCES)
End Enum

Enum CM_NOTIFY_FILTER_TYPE
	CM_NOTIFY_FILTER_TYPE_DEVICEINTERFACE = 0
	CM_NOTIFY_FILTER_TYPE_DEVICEHANDLE
	CM_NOTIFY_FILTER_TYPE_DEVICEINSTANCE
	CM_NOTIFY_FILTER_TYPE_MAX
End Enum

Enum ConfigMgrRemoveSubtreeFlags
	CM_REMOVE_UI_OK = &H00000000
	CM_REMOVE_UI_NOT_OK = &H00000001
	CM_REMOVE_NO_RESTART = &H00000002
	'Windows 10
	CM_REMOVE_DISABLE = &H00000004
End Enum

Type CM_NOTIFY_FILTER
	cbSize As Integer
	Flags As ConfigMgrNotifyFilterFlags
	FilterType As CM_NOTIFY_FILTER_TYPE
	Reserved As Integer
	' union {
	' struct {
	' GUID    ClassGuid;
	' } DeviceInterface;
	
	' struct {
	' HANDLE  hTarget;
	' } DeviceHandle;
	
	' struct {
	' WCHAR   InstanceId[MAX_DEVICE_ID_LEN];
	' } DeviceInstance;
	
	' } u;
	u(399) As Byte
End Type

Type CM_NOTIFY_FILTER_DI
	cbSize As Integer
	Flags As ConfigMgrNotifyFilterFlags
	FilterType As CM_NOTIFY_FILTER_TYPE
	Reserved As Integer
	' union {
	' struct {
	' GUID    ClassGuid;
	' } DeviceInterface;
	
	' struct {
	' HANDLE  hTarget;
	' } DeviceHandle;
	
	' struct {
	' WCHAR   InstanceId[MAX_DEVICE_ID_LEN];
	' } DeviceInstance;
	
	' } u;
	InstanceId(0 To (MAX_DEVICE_ID_LEN - 1)) As Integer
End Type

Enum ConfigMgrRegistryProps
	CM_DRP_DEVICEDESC = (&H00000001)    ' DeviceDesc REG_SZ property (RW)
	CM_DRP_HARDWAREID = (&H00000002)    ' HardwareID REG_MULTI_SZ property (RW)
	CM_DRP_COMPATIBLEIDS = (&H00000003) ' CompatibleIDs REG_MULTI_SZ property (RW)
	CM_DRP_UNUSED0 = (&H00000004)       ' unused
	CM_DRP_SERVICE = (&H00000005)       ' Service REG_SZ property (RW)
	CM_DRP_UNUSED1 = (&H00000006)       ' unused
	CM_DRP_UNUSED2 = (&H00000007)       ' unused
	CM_DRP_CLASS = (&H00000008)         ' Class REG_SZ property (RW)
	CM_DRP_CLASSGUID = (&H00000009)     ' ClassGUID REG_SZ property (RW)
	CM_DRP_DRIVER = (&H0000000A)        ' Driver REG_SZ property (RW)
	CM_DRP_CONFIGFLAGS = (&H0000000B)   ' ConfigFlags REG_DWORD property (RW)
	CM_DRP_MFG = (&H0000000C)           ' Mfg REG_SZ property (RW)
	CM_DRP_FRIENDLYNAME = (&H0000000D)  ' FriendlyName REG_SZ property (RW)
	CM_DRP_LOCATION_INFORMATION = (&H0000000E)          ' LocationInformation REG_SZ property (RW)
	CM_DRP_PHYSICAL_DEVICE_OBJECT_NAME = (&H0000000F)   ' PhysicalDeviceObjectName REG_SZ property (R)
	CM_DRP_CAPABILITIES = (&H00000010)  ' Capabilities REG_DWORD property (R)
	CM_DRP_UI_NUMBER = (&H00000011)     ' UiNumber REG_DWORD property (R)
	CM_DRP_UPPERFILTERS = (&H00000012)  ' UpperFilters REG_MULTI_SZ property (RW)
	' #if (WINVER >= _WIN32_WINNT_LONGHORN)
	CM_CRP_UPPERFILTERS = CM_DRP_UPPERFILTERS   ' UpperFilters REG_MULTI_SZ property (RW)
	' #endif // (WINVER >= _WIN32_WINNT_LONGHORN)
	CM_DRP_LOWERFILTERS = (&H00000013)  ' LowerFilters REG_MULTI_SZ property (RW)
	' #if (WINVER >= _WIN32_WINNT_LONGHORN)
	CM_CRP_LOWERFILTERS = CM_DRP_LOWERFILTERS   ' LowerFilters REG_MULTI_SZ property (RW)
	' #endif // (WINVER >= _WIN32_WINNT_LONGHORN)
	CM_DRP_BUSTYPEGUID = (&H00000014)   ' Bus Type Guid, GUID, (R)
	CM_DRP_LEGACYBUSTYPE = (&H00000015) ' Legacy bus type, INTERFACE_TYPE, (R)
	CM_DRP_BUSNUMBER = (&H00000016)     ' Bus Number, DWORD, (R)
	CM_DRP_ENUMERATOR_NAME = (&H00000017)       ' Enumerator Name REG_SZ property (R)
	CM_DRP_SECURITY = (&H00000018)      ' Security - Device override (RW)
	CM_CRP_SECURITY = CM_DRP_SECURITY   ' Class default security (RW)
	CM_DRP_SECURITY_SDS = (&H00000019)  ' Security - Device override (RW)
	CM_CRP_SECURITY_SDS = CM_DRP_SECURITY_SDS   ' Class default security (RW)
	CM_DRP_DEVTYPE = (&H0000001A)       ' Device Type - Device override (RW)
	CM_CRP_DEVTYPE = CM_DRP_DEVTYPE     ' Class default Device-type (RW)
	CM_DRP_EXCLUSIVE = (&H0000001B)     ' Exclusivity - Device override (RW)
	CM_CRP_EXCLUSIVE = CM_DRP_EXCLUSIVE ' Class default (RW)
	CM_DRP_CHARACTERISTICS = (&H0000001C)       ' Characteristics - Device Override (RW)
	CM_CRP_CHARACTERISTICS = CM_DRP_CHARACTERISTICS     ' Class default (RW)
	CM_DRP_ADDRESS = (&H0000001D)       ' Device Address (R)
	CM_DRP_UI_NUMBER_DESC_FORMAT = (&H0000001E) ' UINumberDescFormat REG_SZ property (RW)
	' #if (WINVER >= _WIN32_WINNT_WINXP)
	CM_DRP_DEVICE_POWER_DATA = (&H0000001F)     ' CM_POWER_DATA REG_BINARY property (R)
	CM_DRP_REMOVAL_POLICY = (&H00000020)        ' CM_DEVICE_REMOVAL_POLICY REG_DWORD (R)
	CM_DRP_REMOVAL_POLICY_HW_DEFAULT = (&H00000021)     ' CM_DRP_REMOVAL_POLICY_HW_DEFAULT REG_DWORD (R)
	CM_DRP_REMOVAL_POLICY_OVERRIDE = (&H00000022)       ' CM_DRP_REMOVAL_POLICY_OVERRIDE REG_DWORD (RW)
	CM_DRP_INSTALL_STATE = (&H00000023) ' CM_DRP_INSTALL_STATE REG_DWORD (R)
	' #endif // (WINVER >= _WIN32_WINNT_WINXP)
	' #if (WINVER >= _WIN32_WINNT_WS03)
	CM_DRP_LOCATION_PATHS = (&H00000024)        ' CM_DRP_LOCATION_PATHS REG_MULTI_SZ (R)
	' #endif // (WINVER >= _WIN32_WINNT_WS03)
	' #if (WINVER >= _WIN32_WINNT_WIN7)
	CM_DRP_BASE_CONTAINERID = (&H00000025)      ' Base ContainerID REG_SZ property (R)
	' #endif // (WINVER >= _WIN32_WINNT_WIN7)
	CM_DRP_MIN = (&H00000001)           ' First device register
	CM_CRP_MIN = CM_DRP_MIN             ' First class register
	CM_DRP_MAX = (&H00000025)           ' Last device register
	CM_CRP_MAX = CM_DRP_MAX             ' Last class register
End Enum

Enum ConfigMgRemovalPolicies
	CM_REMOVAL_POLICY_EXPECT_NO_REMOVAL = 1
	CM_REMOVAL_POLICY_EXPECT_ORDERLY_REMOVAL = 2
	CM_REMOVAL_POLICY_EXPECT_SURPRISE_REMOVAL = 3
End Enum

Enum REGTYPES
	REG_NONE = 0
	REG_SZ = 1
	REG_EXPAND_SZ = 2
	REG_BINARY = 3
	REG_DWORD = 4
	REG_DWORD_BIG_ENDIAN = 5
	REG_DWORD_LITTLE_ENDIAN = 4
	REG_LINK = 6
	REG_MULTI_SZ = 7
	REG_RESOURCE_LIST = 8
	REG_FULL_RESOURCE_DESCRIPTOR = 9
	REG_RESOURCE_REQUIREMENTS_LIST = &HA
	REG_QWORD = &HB
	REG_QWORD_LITTLE_ENDIAN = &HB
End Enum

Enum CfgMgrReEnumFlags
	CM_REENUMERATE_NORMAL = &H00000000
	CM_REENUMERATE_SYNCHRONOUS = &H00000001
	CM_REENUMERATE_RETRY_INSTALLATION = &H00000002
	CM_REENUMERATE_ASYNCHRONOUS = &H00000004
	CM_REENUMERATE_BITS = &H00000007
End Enum

Enum CfgmgrLocateDevnodeFlags
	CM_LOCATE_DEVNODE_NORMAL = &H00000000
	CM_LOCATE_DEVNODE_PHANTOM = &H00000001
	CM_LOCATE_DEVNODE_CANCELREMOVE = &H00000002
	CM_LOCATE_DEVNODE_NOVALIDATION = &H00000004
	CM_LOCATE_DEVNODE_BITS = &H00000007
	CM_LOCATE_DEVINST_NORMAL = CM_LOCATE_DEVNODE_NORMAL
	CM_LOCATE_DEVINST_PHANTOM = CM_LOCATE_DEVNODE_PHANTOM
	CM_LOCATE_DEVINST_CANCELREMOVE = CM_LOCATE_DEVNODE_CANCELREMOVE
	CM_LOCATE_DEVINST_NOVALIDATION = CM_LOCATE_DEVNODE_NOVALIDATION
	CM_LOCATE_DEVINST_BITS = CM_LOCATE_DEVNODE_BITS
End Enum

Enum CfgmgrSetProblemFlags
	CM_SET_DEVNODE_PROBLEM_NORMAL = (&H00000000)    ' only set problem if currently no problem
	CM_SET_DEVNODE_PROBLEM_OVERRIDE = (&H00000001)  ' override current problem with new problem
	CM_SET_DEVNODE_PROBLEM_BITS = (&H00000001)
	CM_SET_DEVINST_PROBLEM_NORMAL = CM_SET_DEVNODE_PROBLEM_NORMAL
	CM_SET_DEVINST_PROBLEM_OVERRIDE = CM_SET_DEVNODE_PROBLEM_OVERRIDE
	CM_SET_DEVINST_PROBLEM_BITS = CM_SET_DEVNODE_PROBLEM_BITS
End Enum

Enum CfgmgrConfigFlags
	CONFIGFLAG_DISABLED = &H00000001    'Set if disabled
	CONFIGFLAG_REMOVED = &H00000002     'Set if a present hardware enum device deleted
	CONFIGFLAG_MANUAL_INSTALL = &H00000004  'Set if the devnode was manually installed
	CONFIGFLAG_IGNORE_BOOT_LC = &H00000008  'Set if skip the boot config
	CONFIGFLAG_NET_BOOT = &H00000010    'Load this devnode when in net boot
	CONFIGFLAG_REINSTALL = &H00000020   'Redo install
	CONFIGFLAG_FAILEDINSTALL = &H00000040   'Failed the install
	CONFIGFLAG_CANTSTOPACHILD = &H00000080  'Can't stop/remove a single child
	CONFIGFLAG_OKREMOVEROM = &H00000100     'Can remove even if rom.
	CONFIGFLAG_NOREMOVEEXIT = &H00000200    'Don't remove at exit.
	CONFIGFLAG_FINISH_INSTALL = &H00000400  'Complete install for devnode running 'raw'
	CONFIGFLAG_NEEDS_FORCED_CONFIG = &H00000800     'This devnode requires a forced config
End Enum

Enum CfgmgrCSConfigFlags
	CSCONFIGFLAG_BITS = &H00000007              'OR of below bits
	CSCONFIGFLAG_NONE = 0
	CSCONFIGFLAG_DISABLED = &H00000001          'Set if
	CSCONFIGFLAG_DO_NOT_CREATE = &H00000002     'Set if
	CSCONFIGFLAG_DO_NOT_START = &H00000004      'Set if
End Enum

Enum CfgmgrHwProfileFlags
	CM_HWPI_NOT_DOCKABLE = (&H00000000)     ' machine is not dockable
	CM_HWPI_UNDOCKED = (&H00000001)         ' hw profile for docked config
	CM_HWPI_DOCKED = (&H00000002)           ' hw profile for undocked config
End Enum

Type HWPROFILEINFO_A
	HWPI_ulHWProfile As Integer                             ' handle of hw profile
	HWPI_szFriendlyName(0 To (MAX_PROFILE_LEN - 1)) As Byte ' friendly name of hw profile
	HWPI_dwFlags As CfgmgrHwProfileFlags                    ' profile flags (CM_HWPI_*)
End Type

Type HWPROFILEINFO_W
	HWPI_ulHWProfile As Integer                                 ' handle of hw profile
	HWPI_szFriendlyName(0 To (MAX_PROFILE_LEN - 1)) As Integer  ' friendly name of hw profile
	HWPI_dwFlags As CfgmgrHwProfileFlags                        ' profile flags (CM_HWPI_*)
End Type

'Alias HWPROFILEINFO As HWPROFILEINFO_W
Type HWPROFILEINFO
	HWPI_ulHWProfile As Integer                                 ' handle of hw profile
	HWPI_szFriendlyName(0 To (MAX_PROFILE_LEN - 1)) As Integer  ' friendly name of hw profile
	HWPI_dwFlags As CfgmgrHwProfileFlags                        ' profile flags (CM_HWPI_*)
End Type

Enum SetupDevCap
	CM_DEVCAP_LOCKSUPPORTED = (&H00000001)
	CM_DEVCAP_EJECTSUPPORTED = (&H00000002)
	CM_DEVCAP_REMOVABLE = (&H00000004)
	CM_DEVCAP_DOCKDEVICE = (&H00000008)
	CM_DEVCAP_UNIQUEID = (&H00000010)
	CM_DEVCAP_SILENTINSTALL = (&H00000020)
	CM_DEVCAP_RAWDEVICEOK = (&H00000040)
	CM_DEVCAP_SURPRISEREMOVALOK = (&H00000080)
	CM_DEVCAP_HARDWAREDISABLED = (&H00000100)
	CM_DEVCAP_NONDYNAMIC = (&H00000200)
	CM_DEVCAP_SECUREDEVICE = (&H00000400)
End Enum

'Use RegisterDeviceNotification instead of CM_Register_Notification if your code targets Windows 7 or earlier versions of Windows.

Declare Function CM_Detect_Resource_Conflict Alias "CM_Detect_Resource_Conflict" (ByVal dnDevInst As Integer, ByVal ResourceID As Integer, ResourceData As Any Ptr, ByVal ResourceLen As Integer, pbConflictDetected As BOOL, ByVal ulFlags As Integer) As CONFIGRET
Declare Function CM_Disable_DevNode Alias "CM_Disable_DevNode" (ByVal dnDevInst As Integer, ByVal ulFlags As CmDisableDNFlags) As CONFIGRET
Declare Function CM_Get_Child Alias "CM_Get_Child" (pdnDevInst As Integer Ptr, ByVal dnDevInst As Integer, ByVal ulFlags As Integer) As CONFIGRET
Declare Function CM_Get_Device_ID_List_SizeA Alias "CM_Get_Device_ID_List_SizeA" (pulLength As Integer, ByVal pszFilter As Integer Ptr, ByVal ulFlags As CmGetIdListFlags) As CONFIGRET
Declare Function CM_Get_Device_ID_List_SizeW Alias "CM_Get_Device_ID_List_SizeW" (pulLength As Integer, ByVal pszFilter As Integer Ptr, ByVal ulFlags As CmGetIdListFlags) As CONFIGRET
Declare Function CM_Get_Device_ID_ListA Alias "CM_Get_Device_ID_ListA" (ByVal pszFilter As Integer Ptr, ByVal Buffer As Integer Ptr, ByVal BufferLen As Integer, ByVal ulFlags As CmGetIdListFlags) As CONFIGRET
Declare Function CM_Get_Device_ID_ListW Alias "CM_Get_Device_ID_ListW" (ByVal pszFilter As Integer Ptr, ByVal Buffer As Integer Ptr, ByVal BufferLen As Integer, ByVal ulFlags As CmGetIdListFlags) As CONFIGRET
Declare Function CM_Get_Device_ID_Size Alias "CM_Get_Device_ID_Size" (ByRef pulLen As Integer, ByVal dnDevInst As Integer, ByVal ulFlags As Integer) As CONFIGRET
Declare Function CM_Get_Device_IDA Alias "CM_Get_Device_IDA" (ByVal dnDevInst As Integer, ByVal Buffer As ZString Ptr, ByVal BufferLen As Integer, ByVal ulFlags As Integer) As CONFIGRET
Declare Function CM_Get_Device_IDW Alias "CM_Get_Device_IDW" (ByVal dnDevInst As Integer, ByVal Buffer As WString Ptr, ByVal BufferLen As Integer, ByVal ulFlags As Integer) As CONFIGRET
Declare Function CM_Get_DevNode_Registry_PropertyA Alias "CM_Get_DevNode_Registry_PropertyA" (ByVal dnDevInst As Integer, ByVal ulProperty As ConfigMgrRegistryProps, pulRegDataType As REGTYPES, Buffer As Any Ptr, pulLength As Integer, ByVal ulFlags As Integer) As CONFIGRET
Declare Function CM_Get_DevNode_Registry_PropertyW Alias "CM_Get_DevNode_Registry_PropertyW" (ByVal dnDevInst As Integer, ByVal ulProperty As ConfigMgrRegistryProps, pulRegDataType As REGTYPES, Buffer As Any Ptr, pulLength As Integer, ByVal ulFlags As Integer) As CONFIGRET
Declare Function CM_Get_DevNode_Status Alias "CM_Get_DevNode_Status" (pulStatus As CfgMgDevNodeStatus Ptr, pulProblemNumber As CfgMgrProblems Ptr, ByVal dnDevInst As Integer, ByVal ulFlags As Integer) As CONFIGRET
Declare Function CM_Get_Hardware_Profile_InfoA Alias "CM_Get_Hardware_Profile_InfoA" (ByVal ulIndex As Integer, pHWProfileInfo As HWPROFILEINFO_A, ByVal ulFlags As Integer) As CONFIGRET
Declare Function CM_Get_Hardware_Profile_InfoW Alias "CM_Get_Hardware_Profile_InfoW" (ByVal ulIndex As Integer, pHWProfileInfo As HWPROFILEINFO_W, ByVal ulFlags As Integer) As CONFIGRET
Declare Function CM_Get_HW_Prof_FlagsA Alias "CM_Get_HW_Prof_FlagsA" (ByVal pDeviceID As ZString Ptr, ByVal ulHardwareProfile As Integer, pulValue As CfgmgrCSConfigFlags, ByVal ulFlags As Integer) As CONFIGRET
Declare Function CM_Get_HW_Prof_FlagsW Alias "CM_Get_HW_Prof_FlagsW" (ByVal pDeviceID As WString Ptr, ByVal ulHardwareProfile As Integer, pulValue As CfgmgrCSConfigFlags, ByVal ulFlags As Integer) As CONFIGRET
Declare Function CM_Get_Parent Alias "CM_Get_Parent" (pdnDevInst As Integer Ptr, ByVal dnDevInst As Integer, ByVal ulFlags As Integer) As CONFIGRET
Declare Function CM_Get_Sibling Alias "CM_Get_Sibling" (pdnDevInst As Integer Ptr, ByVal dnDevInst As Integer, ByVal ulFlags As Integer) As CONFIGRET
Declare Function CM_Is_Dock_Station_Present Alias "CM_Is_Dock_Station_Present" (pbPresent As BOOL) As CONFIGRET
Declare Function CM_Locate_DevNodeA Alias "CM_Locate_DevNodeA" (pdnDevInst As Integer Ptr, ByVal pDeviceID As ZString Ptr, ByVal ulFlags As CfgmgrLocateDevnodeFlags) As CONFIGRET
Declare Function CM_Locate_DevNodeW Alias "CM_Locate_DevNodeW" (pdnDevInst As Integer Ptr, ByVal pDeviceID As WString Ptr, ByVal ulFlags As CfgmgrLocateDevnodeFlags) As CONFIGRET
Declare Function CM_MapCrToWin32Err Alias "CM_MapCrToWin32Err" (ByVal CmReturnCode As CONFIGRET, ByVal DefaultErr As Integer) As Integer
Declare Function CM_Query_And_Remove_SubTree_A Alias "CM_Query_And_Remove_SubTree_A" (ByVal dnAncestor As Integer, pVetoType As PNP_VETO_TYPE, ByVal pszVetoName As ZString Ptr, ByVal ulNameLength As Integer, ByVal ulFlags As ConfigMgrRemoveSubtreeFlags) As CONFIGRET
Declare Function CM_Query_And_Remove_SubTree_W Alias "CM_Query_And_Remove_SubTree_W" (ByVal dnAncestor As Integer, pVetoType As PNP_VETO_TYPE, ByVal pszVetoName As WString Ptr, ByVal ulNameLength As Integer, ByVal ulFlags As ConfigMgrRemoveSubtreeFlags) As CONFIGRET
Declare Function CM_Reenumerate_DevNode Alias "CM_Reenumerate_DevNode" (ByVal dnDevInst As Integer, ByVal ulFlags As CfgMgrReEnumFlags) As CONFIGRET
Declare Function CM_Register_Notification Alias "CM_Register_Notification" (pFilter As CM_NOTIFY_FILTER, ByVal PCONTEXT As Integer Ptr, ByVal pCallback As Integer Ptr, pNotifyContext As Integer Ptr) As CONFIGRET
Declare Function CM_Request_Device_EjectA Lib "setupapi" Alias "CM_Request_Device_EjectA" (ByVal dnDevInst As Integer, pVetoType As PNP_VETO_TYPE, ByVal pszVetoName As ZString Ptr, ByVal ulNameLength As Integer, ByVal ulFlags As Integer) As CONFIGRET
Declare Function CM_Request_Device_EjectW Lib "setupapi" Alias "CM_Request_Device_EjectW" (ByVal dnDevInst As Integer, pVetoType As PNP_VETO_TYPE, ByVal pszVetoName As WString Ptr, ByVal ulNameLength As Integer, ByVal ulFlags As Integer) As CONFIGRET
Declare Function CM_Request_Eject_PC Alias "CM_Request_Eject_PC" () As CONFIGRET
Declare Function CM_Set_DevNode_Problem Alias "CM_Set_DevNode_Problem" (ByVal dnDevInst As Integer, ByVal ulProblem As CfgMgrProblems, ByVal ulFlags As CfgmgrSetProblemFlags) As CONFIGRET
Declare Function CM_Set_DevNode_Registry_PropertyA Alias "CM_Set_DevNode_Registry_PropertyA" (ByVal dnDevInst As Integer, ByVal ulProperty As ConfigMgrRegistryProps, Buffer As Any Ptr, ByVal ulLength As Integer, ByVal ulFlags As Integer) As CONFIGRET
Declare Function CM_Set_DevNode_Registry_PropertyW Alias "CM_Set_DevNode_Registry_PropertyW" (ByVal dnDevInst As Integer, ByVal ulProperty As ConfigMgrRegistryProps, Buffer As Any Ptr, ByVal ulLength As Integer, ByVal ulFlags As Integer) As CONFIGRET
Declare Function CM_Set_HW_Prof_FlagsA Alias "CM_Set_HW_Prof_FlagsA" (ByVal pDeviceID As ZString Ptr, ByVal ulHardwareProfile As Integer, ByVal ulValue As CfgmgrCSConfigFlags, ByVal ulFlags As Integer) As CONFIGRET
Declare Function CM_Set_HW_Prof_FlagsW Alias "CM_Set_HW_Prof_FlagsW" (ByVal pDeviceID As WString Ptr, ByVal ulHardwareProfile As Integer, ByVal ulValue As CfgmgrCSConfigFlags, ByVal ulFlags As Integer) As CONFIGRET
Declare Function CM_Uninstall_DevNode Alias "CM_Uninstall_DevNode" (ByVal dnDevInst As Integer, ByVal ulFlags As Integer) As CONFIGRET
Declare Function CM_Unregister_Notification Alias "CM_Unregister_Notification" (ByVal NotifyContext As Integer Ptr) As CONFIGRET

#ifndef UNICODE
	Declare Function CM_Get_Device_ID Alias "CM_Get_Device_IDA" (ByVal dnDevInst As Integer, ByVal Buffer As ZString Ptr, ByVal BufferLen As Integer, ByVal ulFlags As Integer) As CONFIGRET
	Declare Function CM_Get_Device_ID_List Alias "CM_Get_Device_ID_ListA" (ByVal pszFilter As ZString Ptr, ByVal Buffer As ZString Ptr, ByVal BufferLen As Integer, ByVal ulFlags As CmGetIdListFlags) As CONFIGRET
	Declare Function CM_Get_Device_ID_List_Size Alias "CM_Get_Device_ID_List_SizeA" (pulLength As Integer, ByVal pszFilter As ZString Ptr, ByVal ulFlags As CmGetIdListFlags) As CONFIGRET
	Declare Function CM_Get_DevNode_Registry_Property Alias "CM_Get_DevNode_Registry_PropertyA" (ByVal dnDevInst As Integer, ByVal ulProperty As ConfigMgrRegistryProps, pulRegDataType As REGTYPES, Buffer As Any Ptr, pulLength As Integer, ByVal ulFlags As Integer) As CONFIGRET
	Declare Function CM_Get_Hardware_Profile_Info Alias "CM_Get_Hardware_Profile_InfoA" (ByVal ulIndex As Integer, pHWProfileInfo As HWPROFILEINFO, ByVal ulFlags As Integer) As CONFIGRET
	Declare Function CM_Get_HW_Prof_Flags Alias "CM_Get_HW_Prof_FlagsA" (ByVal pDeviceID As ZString Ptr, ByVal ulHardwareProfile As Integer, pulValue As CfgmgrCSConfigFlags, ByVal ulFlags As Integer) As CONFIGRET
	Declare Function CM_Locate_DevNode Alias "CM_Locate_DevNodeA" (pdnDevInst As Integer Ptr, ByVal pDeviceID As ZString Ptr, ByVal ulFlags As CfgmgrLocateDevnodeFlags) As CONFIGRET
	Declare Function CM_Query_And_Remove_SubTree Alias "CM_Query_And_Remove_SubTree_A" (ByVal dnAncestor As Integer, pVetoType As PNP_VETO_TYPE, ByVal pszVetoName As ZString Ptr, ByVal ulNameLength As Integer, ByVal ulFlags As ConfigMgrRemoveSubtreeFlags) As CONFIGRET
	Declare Function CM_Request_Device_Eject Lib "setupapi" Alias "CM_Request_Device_EjectA" (ByVal dnDevInst As Integer, pVetoType As PNP_VETO_TYPE, ByVal pszVetoName As ZString Ptr, ByVal ulNameLength As Integer, ByVal ulFlags As Integer) As CONFIGRET
	Declare Function CM_Set_DevNode_Registry_Property Alias "CM_Set_DevNode_Registry_PropertyA" (ByVal dnDevInst As Integer, ByVal ulProperty As ConfigMgrRegistryProps, Buffer As Any Ptr, ByVal ulLength As Integer, ByVal ulFlags As Integer) As CONFIGRET
	Declare Function CM_Set_HW_Prof_Flags Alias "CM_Set_HW_Prof_FlagsA" (ByVal pDeviceID As ZString Ptr, ByVal ulHardwareProfile As Integer, ByVal ulValue As CfgmgrCSConfigFlags, ByVal ulFlags As Integer) As CONFIGRET
#endif
#ifdef UNICODE
	Declare Function CM_Get_Device_ID Alias "CM_Get_Device_IDW" (ByVal dnDevInst As Integer, ByVal Buffer As WString Ptr, ByVal BufferLen As Integer, ByVal ulFlags As Integer) As CONFIGRET
	Declare Function CM_Get_Device_ID_List Alias "CM_Get_Device_ID_ListW" (ByVal pszFilter As WString Ptr, ByVal Buffer As WString Ptr, ByVal BufferLen As Integer, ByVal ulFlags As CmGetIdListFlags) As CONFIGRET
	Declare Function CM_Get_Device_ID_List_Size Alias "CM_Get_Device_ID_List_SizeW" (pulLength As Integer, ByVal pszFilter As WString Ptr, ByVal ulFlags As CmGetIdListFlags) As CONFIGRET
	Declare Function CM_Get_DevNode_Registry_Property Alias "CM_Get_DevNode_Registry_PropertyW" (ByVal dnDevInst As Integer, ByVal ulProperty As ConfigMgrRegistryProps, pulRegDataType As REGTYPES, Buffer As Any Ptr, pulLength As Integer, ByVal ulFlags As Integer) As CONFIGRET
	Declare Function CM_Get_Hardware_Profile_Info Alias "CM_Get_Hardware_Profile_InfoW" (ByVal ulIndex As Integer, pHWProfileInfo As HWPROFILEINFO, ByVal ulFlags As Integer) As CONFIGRET
	Declare Function CM_Get_HW_Prof_Flags Alias "CM_Get_HW_Prof_FlagsW" (ByVal pDeviceID As WString Ptr, ByVal ulHardwareProfile As Integer, pulValue As CfgmgrCSConfigFlags, ByVal ulFlags As Integer) As CONFIGRET
	Declare Function CM_Locate_DevNode Alias "CM_Locate_DevNodeW" (pdnDevInst As Integer Ptr, ByVal pDeviceID As WString Ptr, ByVal ulFlags As CfgmgrLocateDevnodeFlags) As CONFIGRET
	Declare Function CM_Query_And_Remove_SubTree Alias "CM_Query_And_Remove_SubTree_W" (ByVal dnAncestor As Integer, pVetoType As PNP_VETO_TYPE, ByVal pszVetoName As WString Ptr, ByVal ulNameLength As Integer, ByVal ulFlags As ConfigMgrRemoveSubtreeFlags) As CONFIGRET
	Declare Function CM_Request_Device_Eject Lib "setupapi" Alias "CM_Request_Device_EjectW" (ByVal dnDevInst As Integer, pVetoType As PNP_VETO_TYPE, ByVal pszVetoName As WString Ptr, ByVal ulNameLength As Integer, ByVal ulFlags As Integer) As CONFIGRET
	Declare Function CM_Set_DevNode_Registry_Property Alias "CM_Set_DevNode_Registry_PropertyW" (ByVal dnDevInst As Integer, ByVal ulProperty As ConfigMgrRegistryProps, Buffer As Any Ptr, ByVal ulLength As Integer, ByVal ulFlags As Integer) As CONFIGRET
	Declare Function CM_Set_HW_Prof_Flags Alias "CM_Set_HW_Prof_FlagsW" (ByVal pDeviceID As WString Ptr, ByVal ulHardwareProfile As Integer, ByVal ulValue As CfgmgrCSConfigFlags, ByVal ulFlags As Integer) As CONFIGRET
#endif

Enum SHOWWINDOW
	SW_HIDE = 0
	SW_SHOWNORMAL = 1
	SW_NORMAL = 1
	SW_SHOWMINIMIZED = 2
	SW_SHOWMAXIMIZED = 3
	SW_MAXIMIZE = 3
	SW_SHOWNOACTIVATE = 4
	SW_SHOW = 5
	SW_MINIMIZE = 6
	SW_SHOWMINNOACTIVE = 7
	SW_SHOWNA = 8
	SW_RESTORE = 9
	SW_SHOWDEFAULT = 10
	SW_FORCEMINIMIZE = 11
	SW_MAX = 11
End Enum

Enum DevPropUIFlags
	DEVPROP_SHOW_RESOURCE_TAB = &H00000001
	DEVPROP_LAUNCH_TROUBLESHOOTER = &H00000002
End Enum

#inclib "devmgr"

Declare Function DeviceAdvancedPropertiesA Alias "DeviceAdvancedPropertiesA" (ByVal hwndParent As HWND, ByVal MachineName As ZString Ptr, ByVal DeviceID As ZString Ptr) As Integer
Declare Function DeviceAdvancedPropertiesW Alias "DeviceAdvancedPropertiesW" (ByVal hwndParent As HWND, ByVal MachineName As WString Ptr, ByVal DeviceID As WString Ptr) As Integer
Declare Function DeviceManager_ExecuteA Alias "DeviceManager_ExecuteA" (ByVal hwndStub As Integer, ByVal hAppInstance As Integer, ByVal lpCmdLine As ZString Ptr, ByVal nCmdShow As SHOWWINDOW) As BOOL
Declare Function DeviceManager_ExecuteW Alias "DeviceManager_ExecuteW" (ByVal hwndStub As Integer, ByVal hAppInstance As Integer, ByVal lpCmdLine As WString Ptr, ByVal nCmdShow As SHOWWINDOW) As BOOL
Declare Function DeviceProblemTextA Alias "DeviceProblemTextA" (ByVal hMachine As Integer, ByVal DevNode As Integer, ByVal ProblemNumber As CfgMgrProblems, ByVal Buffer As ZString Ptr, ByVal BufferSize As PDWORD) As Integer
Declare Function DeviceProblemTextW Alias "DeviceProblemTextA" (ByVal hMachine As Integer, ByVal DevNode As Integer, ByVal ProblemNumber As CfgMgrProblems, ByVal Buffer As WString Ptr, ByVal BufferSize As PDWORD) As Integer
Declare Function DeviceProblemWizardA Alias "DeviceProblemWizardA" (ByVal hwndParent As HWND, ByVal MachineName As ZString Ptr, ByVal DeviceID As ZString Ptr) As Integer
Declare Function DeviceProblemWizardW Alias "DeviceProblemWizardW" (ByVal hwndParent As HWND, ByVal MachineName As WString Ptr, ByVal DeviceID As WString Ptr) As Integer
Declare Function DevicePropertiesA Alias "DevicePropertiesA" (ByVal hwndParent As HWND, ByVal MachineName As ZString Ptr, ByVal DeviceID As ZString Ptr, ByVal ShowDeviceTree As BOOL) As Integer
Declare Function DevicePropertiesW Alias "DevicePropertiesW" (ByVal hwndParent As HWND, ByVal MachineName As WString Ptr, ByVal DeviceID As WString Ptr, ByVal ShowDeviceTree As BOOL) As Integer
Declare Function DevicePropertiesExA Alias "DevicePropertiesExA" (ByVal hwndParent As HWND, ByVal MachineName As ZString Ptr, ByVal DeviceID As ZString Ptr, ByVal Flags As DevPropUIFlags, ByVal ShowDeviceTree As BOOL) As Integer
Declare Function DevicePropertiesExW Alias "DevicePropertiesExW" (ByVal hwndParent As HWND, ByVal MachineName As WString Ptr, ByVal DeviceID As WString Ptr, ByVal Flags As DevPropUIFlags, ByVal ShowDeviceTree As BOOL) As Integer
Declare Sub DeviceProblenWizard_RunDLLA Alias "DeviceProblenWizard_RunDLLA" (ByVal hwndStub As Integer, ByVal hAppInstance As Integer, ByVal lpCmdLine As ZString Ptr, ByVal nCmdShow As SHOWWINDOW)
Declare Sub DeviceProblenWizard_RunDLLW Alias "DeviceProblenWizard_RunDLLW" (ByVal hwndStub As Integer, ByVal hAppInstance As Integer, ByVal lpCmdLine As WString Ptr, ByVal nCmdShow As SHOWWINDOW)
Declare Sub DeviceProperties_RunDLLA Alias "DeviceProperties_RunDLLA" (ByVal hwndStub As Integer, ByVal hAppInstance As Integer, ByVal lpCmdLine As ZString Ptr, ByVal nCmdShow As SHOWWINDOW)
Declare Sub DeviceProperties_RunDLLW Alias "DeviceProperties_RunDLLW" (ByVal hwndStub As Integer, ByVal hAppInstance As Integer, ByVal lpCmdLine As WString Ptr, ByVal nCmdShow As SHOWWINDOW)

#ifndef UNICODE
	Declare Function DeviceAdvancedProperties Alias "DeviceAdvancedPropertiesA" (ByVal hwndParent As HWND, ByVal MachineName As ZString Ptr, ByVal DeviceID As ZString Ptr) As Integer
	Declare Function DeviceManager_Execute Alias "DeviceManager_ExecuteA" (ByVal hwndStub As Integer, ByVal hAppInstance As Integer, ByVal lpCmdLine As ZString Ptr, ByVal nCmdShow As SHOWWINDOW) As BOOL
	Declare Function DeviceProblemText Alias "DeviceProblemTextA" (ByVal hMachine As Integer, ByVal DevNode As Integer, ByVal ProblemNumber As CfgMgrProblems, ByVal Buffer As ZString Ptr, ByVal BufferSize As PDWORD) As Integer
	Declare Function DeviceProblemWizard Alias "DeviceProblemWizardA" (ByVal hwndParent As HWND, ByVal MachineName As ZString Ptr, ByVal DeviceID As ZString Ptr) As Integer
	Declare Function DeviceProperties Alias "DevicePropertiesA" (ByVal hwndParent As HWND, ByVal MachineName As ZString Ptr, ByVal DeviceID As ZString Ptr, ByVal ShowDeviceTree As BOOL) As Integer
	Declare Function DevicePropertiesEx Alias "DevicePropertiesExA" (ByVal hwndParent As HWND, ByVal MachineName As ZString Ptr, ByVal DeviceID As ZString Ptr, ByVal Flags As DevPropUIFlags, ByVal ShowDeviceTree As BOOL) As Integer
	Declare Sub DeviceProblenWizard_RunDLL Alias "DeviceProblenWizard_RunDLLA" (ByVal hwndStub As Integer, ByVal hAppInstance As Integer, ByVal lpCmdLine As ZString Ptr, ByVal nCmdShow As SHOWWINDOW)
	Declare Sub DeviceProperties_RunDLL Alias "DeviceProperties_RunDLLA" (ByVal hwndStub As Integer, ByVal hAppInstance As Integer, ByVal lpCmdLine As ZString Ptr, ByVal nCmdShow As SHOWWINDOW)
#endif

#ifdef UNICODE
	Declare Function DeviceAdvancedProperties Alias "DeviceAdvancedPropertiesW" (ByVal hwndParent As HWND, ByVal MachineName As WString Ptr, ByVal DeviceID As WString Ptr) As Integer
	Declare Function DeviceManager_Execute Alias "DeviceManager_ExecuteW" (ByVal hwndStub As Integer, ByVal hAppInstance As Integer, ByVal lpCmdLine As WString Ptr, ByVal nCmdShow As SHOWWINDOW) As BOOL
	Declare Function DeviceProblemText Alias "DeviceProblemTextW" (ByVal hMachine As Integer, ByVal DevNode As Integer, ByVal ProblemNumber As CfgMgrProblems, ByVal Buffer As WString Ptr, ByVal BufferSize As PDWORD) As Integer
	Declare Function DeviceProblemWizard Alias "DeviceProblemWizardW" (ByVal hwndParent As HWND, ByVal MachineName As WString Ptr, ByVal DeviceID As WString Ptr) As Integer
	Declare Function DeviceProperties Alias "DevicePropertiesW" (ByVal hwndParent As HWND, ByVal MachineName As WString Ptr, ByVal DeviceID As WString Ptr, ByVal ShowDeviceTree As BOOL) As Integer
	Declare Function DevicePropertiesEx Alias "DevicePropertiesExW" (ByVal hwndParent As HWND, ByVal MachineName As WString Ptr, ByVal DeviceID As WString Ptr, ByVal Flags As DevPropUIFlags, ByVal ShowDeviceTree As BOOL) As Integer
	Declare Sub DeviceProblenWizard_RunDLL Alias "DeviceProblenWizard_RunDLLW" (ByVal hwndStub As Integer, ByVal hAppInstance As Integer, ByVal lpCmdLine As WString Ptr, ByVal nCmdShow As SHOWWINDOW)
	Declare Sub DeviceProperties_RunDLL Alias "DeviceProperties_RunDLLW" (ByVal hwndStub As Integer, ByVal hAppInstance As Integer, ByVal lpCmdLine As WString Ptr, ByVal nCmdShow As SHOWWINDOW)
#endif

Enum DEVPROPTYPE
	DEVPROP_TYPE_EMPTY = &H00000000 ' nothing, no property data
	DEVPROP_TYPE_NULL = &H00000001 ' null property data
	DEVPROP_TYPE_SBYTE = &H00000002 ' 8-bit signed int (SBYTE)
	DEVPROP_TYPE_BYTE = &H00000003 ' 8-bit unsigned int (BYTE)
	DEVPROP_TYPE_INT16 = &H00000004 ' 16-bit signed int (SHORT)
	DEVPROP_TYPE_UINT16 = &H00000005 ' 16-bit unsigned int (USHORT)
	DEVPROP_TYPE_INT32 = &H00000006 ' 32-bit signed int (LONG)
	DEVPROP_TYPE_UINT32 = &H00000007 ' 32-bit unsigned int (ULONG)
	DEVPROP_TYPE_INT64 = &H00000008 ' 64-bit signed int (LONG64)
	DEVPROP_TYPE_UINT64 = &H00000009 ' 64-bit unsigned int (ULONG64)
	DEVPROP_TYPE_FLOAT = &H0000000A ' 32-bit floating-point (FLOAT)
	DEVPROP_TYPE_DOUBLE = &H0000000B ' 64-bit floating-point (DOUBLE)
	DEVPROP_TYPE_DECIMAL = &H0000000C ' 128-bit data (DECIMAL)
	DEVPROP_TYPE_GUID = &H0000000D ' 128-bit unique identifier (GUID)
	DEVPROP_TYPE_LongLong = &H0000000E ' 64 bit signed int LongLong value (LongLong)
	DEVPROP_TYPE_DATE = &H0000000F ' date (DATE)
	DEVPROP_TYPE_FILETIME = &H00000010 ' file time (FILETIME)
	DEVPROP_TYPE_BOOLEAN = &H00000011 ' 8-bit boolean (DEVPROP_BOOLEAN)
	DEVPROP_TYPE_STRING = &H00000012 ' null-terminated string
	DEVPROP_TYPE_STRING_LIST = &H00002012 '(DEVPROP_TYPE_STRING|DEVPROP_TYPEMOD_LIST), // multi-sz string list
	DEVPROP_TYPE_SECURITY_DESCRIPTOR = &H00000013 ' self-relative binary SECURITY_DESCRIPTOR
	DEVPROP_TYPE_SECURITY_DESCRIPTOR_STRING = &H00000014 ' security descriptor string (SDDL format)
	DEVPROP_TYPE_DEVPROPKEY = &H00000015 ' device property key (DEVPROPKEY)
	DEVPROP_TYPE_DEVPROPTYPE = &H00000016 ' device property type (DEVPROPTYPE)
	DEVPROP_TYPE_BINARY = &H000010016 ' (DEVPROP_TYPE_BYTE|DEVPROP_TYPEMOD_ARRAY), // custom binary data
	DEVPROP_TYPE_ERROR = &H00000017 ' 32-bit Win32 system error code
	DEVPROP_TYPE_NTSTATUS = &H00000018 ' 32-bit NTSTATUS code
	DEVPROP_TYPE_STRING_INDIRECT = &H00000019 ' string resource (@[path\]<dllname>,-<strId>)
	DEVPROP_TYPEMOD_ARRAY = &H00001000 ' array of fixed-sized data elements
	DEVPROP_TYPEMOD_LIST = &H00002000 ' list of variable-sized data elements
	MAX_DEVPROP_TYPE = &H00000019  ' max valid DEVPROP_TYPE_ value
	MAX_DEVPROP_TYPEMOD = &H00002000  ' max valid DEVPROP_TYPEMOD_ value
	'  Bitmasks for extracting DEVPROP_TYPE_ and DEVPROP_TYPEMOD_ values.
	DEVPROP_MASK_TYPE = &H00000FFF  ' range for base DEVPROP_TYPE_ values
	DEVPROP_MASK_TYPEMOD = &H0000F000&  ' mask for DEVPROP_TYPEMOD_ type modifiers
End Enum

Declare Function SetupDiGetDeviceProperty Lib "setupapi" Alias "SetupDiGetDevicePropertyW" (ByVal DeviceInfoSet As HDEVINFO, DeviceInfoData As PSP_DEVINFO_DATA, PROPERTYKEY As PROPERTYKEY Ptr, PropertyType As DEVPROPTYPE, PropertyBuffer As Any Ptr, ByVal PropertyBufferSize As Integer, RequiredSize As Integer Ptr, ByVal Flags As Integer) As BOOL
Declare Function SetupDiLoadDeviceIcon Lib "setupapi" Alias "SetupDiLoadDeviceIcon" (ByVal DeviceInfoSet As HDEVINFO, DeviceInfoData As PSP_DEVINFO_DATA, ByVal cxIcon As Integer, ByVal cyIcon As Integer, ByVal Flags As Integer, HICON As HICON Ptr) As BOOL

