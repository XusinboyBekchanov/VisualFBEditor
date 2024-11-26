'newdev.bi
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "cfgmgr32.bi"

'newdev.h, 100% coverage

#inclib "newdev"

Enum NewDevUpdatePnpFlags
	INSTALLFLAG_FORCE = &H00000001  ' Force the installation of the specified driver
	INSTALLFLAG_READONLY = &H00000002  ' Do a read-only install (no file copy)
	INSTALLFLAG_NONINTERACTIVE = &H00000004  ' No UI shown at all. API will fail if any UI must be shown.
	INSTALLFLAG_BITS = &H00000007
End Enum

Enum NewDevInstallFlags
	DIIDFLAG_SHOWSEARCHUI = &H00000001  ' Show search UI if no drivers can be found.
	DIIDFLAG_NOFINISHINSTALLUI = &H00000002  ' Do NOT show the finish install UI.
	DIIDFLAG_INSTALLNULLDRIVER = &H00000004  ' Install the NULL driver on this device.
	DIIDFLAG_INSTALLCOPYINFDRIVERS = &H00000008  ' Install any extra INFs specified via CopyInf directive.
	DIIDFLAG_BITS = &H0000000F
End Enum

Enum NewDevDrvInstallFlags
	DIIRFLAG_INF_ALREADY_COPIED = &H00000001  ' Don't copy inf, it has been published
	DIIRFLAG_FORCE_INF = &H00000002  ' use the inf as if users picked it.
	DIIRFLAG_HW_USING_THE_INF = &H00000004  ' limit installs on hw using the inf
	DIIRFLAG_HOTPATCH = &H00000008  ' Perform a hotpatch service pack install
	DIIRFLAG_NOBACKUP = &H00000010  ' install w/o backup and no rollback
	' #if (WINVER >= _WIN32_WINNT_WINBLUE)
	DIIRFLAG_PRE_CONFIGURE_INF = &H00000020  ' Pre-install inf, if possible
	DIIRFLAG_INSTALL_AS_SET = &H00000040
	DIIRFLAG_BITS = (DIIRFLAG_FORCE_INF Or DIIRFLAG_HOTPATCH Or DIIRFLAG_PRE_CONFIGURE_INF Or DIIRFLAG_INSTALL_AS_SET)
	DIIRFLAG_SYSTEM_BITS = (DIIRFLAG_INF_ALREADY_COPIED Or DIIRFLAG_FORCE_INF Or DIIRFLAG_HW_USING_THE_INF Or DIIRFLAG_HOTPATCH Or DIIRFLAG_NOBACKUP Or DIIRFLAG_PRE_CONFIGURE_INF Or DIIRFLAG_INSTALL_AS_SET)
	' #endif
End Enum

Enum NewDevUninstFlags
	DIURFLAG_NO_REMOVE_INF = (&H00000001)  ' Do not remove inf from the system
	DIURFLAG_RESERVED = (&H00000002)  ' DIURFLAG_UNCONFIGURE_INF is obsolete.
	DIURFLAG_VALID = (DIURFLAG_NO_REMOVE_INF Or DIURFLAG_RESERVED)
End Enum

Enum NewDevRollbackFlags
	ROLLBACK_FLAG_NO_UI = &H00000001  ' don't show any UI (this could cause failures if UI must be displayed)
	ROLLBACK_BITS = &H00000001
End Enum

Declare Function DiInstallDevice (ByVal hwndParent As HWND, ByVal DeviceInfoSet As HDEVINFO, DeviceInfoData As PSP_DEVINFO_DATA, DriverInfoData As PSP_DRVINFO_DATA, ByVal Flags As NewDevInstallFlags, NeedReboot As BOOL) As BOOL

Declare Function DiInstallDriverA (ByVal hwndParent As HWND, ByVal InfPath As ZString Ptr, ByVal Flags As NewDevDrvInstallFlags, NeedReboot As BOOL) As BOOL
Declare Function DiInstallDriverW (ByVal hwndParent As HWND, ByVal InfPath As WString Ptr, ByVal Flags As NewDevDrvInstallFlags, NeedReboot As BOOL) As BOOL

Declare Function DiRollbackDriver (ByVal DeviceInfoSet As HDEVINFO, DeviceInfoData As PSP_DEVINFO_DATA, ByVal hwndParent As HWND, ByVal Flags As NewDevRollbackFlags, NeedReboot As BOOL) As BOOL
Declare Function DiShowUpdateDevice (ByVal hwndParent As HWND, ByVal DeviceInfoSet As HDEVINFO, DeviceInfoData As PSP_DEVINFO_DATA, ByVal Flags As Long, NeedReboot As BOOL) As BOOL
Declare Function DiShowUpdateDriver (ByVal hwndParent As HWND, ByVal FilePath As ZString Ptr, ByVal Flags As Long, NeedReboot As BOOL) As BOOL
Declare Function DiUninstallDevice (ByVal hwndParent As HWND, ByVal DeviceInfoSet As HDEVINFO, DeviceInfoData As PSP_DEVINFO_DATA, ByVal Flags As Long, NeedReboot As BOOL) As BOOL

Declare Function DiUninstallDriverA (ByVal hwndParent As HWND, ByVal InfPath As ZString Ptr, ByVal Flags As NewDevUninstFlags, NeedReboot As BOOL) As BOOL
Declare Function DiUninstallDriverW (ByVal hwndParent As HWND, ByVal InfPath As WString Ptr, ByVal Flags As NewDevUninstFlags, NeedReboot As BOOL) As BOOL

Declare Function UpdateDriverForPlugAndPlayDevicesA (ByVal hwndParent As HWND, ByVal HardwareId As ZString Ptr, ByVal FullInfPath As ZString Ptr, ByVal InstallFlags As NewDevUpdatePnpFlags, bRebootRequired As BOOL) As BOOL
Declare Function UpdateDriverForPlugAndPlayDevicesW (ByVal hwndParent As HWND, ByVal HardwareId As WString Ptr, ByVal FullInfPath As WString Ptr, ByVal InstallFlags As NewDevUpdatePnpFlags, bRebootRequired As BOOL) As BOOL

#ifndef UNICODE
	Declare Function DiInstallDriver Alias "DiInstallDriverA" (ByVal hwndParent As HWND, ByVal InfPath As ZString Ptr, ByVal Flags As NewDevDrvInstallFlags, NeedReboot As BOOL) As BOOL
	Declare Function DiUninstallDriver Alias "DiUninstallDriverA" (ByVal hwndParent As HWND, ByVal InfPath As ZString Ptr, ByVal Flags As NewDevUninstFlags, NeedReboot As BOOL) As BOOL
	Declare Function UpdateDriverForPlugAndPlayDevices Alias "UpdateDriverForPlugAndPlayDevicesA" (ByVal hwndParent As HWND, ByVal HardwareId As ZString Ptr, ByVal FullInfPath As ZString Ptr, ByVal InstallFlags As NewDevUpdatePnpFlags, bRebootRequired As BOOL) As BOOL
#endif

#ifdef UNICODE
	Declare Function DiInstallDriver Alias "DiInstallDriverW" (ByVal hwndParent As HWND, ByVal InfPath As WString Ptr, ByVal Flags As NewDevDrvInstallFlags, NeedReboot As BOOL) As BOOL
	Declare Function DiUninstallDriver Alias "DiUninstallDriverW" (ByVal hwndParent As HWND, ByVal InfPath As WString Ptr, ByVal Flags As NewDevUninstFlags, NeedReboot As BOOL) As BOOL
	Declare Function UpdateDriverForPlugAndPlayDevices Alias "UpdateDriverForPlugAndPlayDevicesW" (ByVal hwndParent As HWND, ByVal HardwareId As WString Ptr, ByVal FullInfPath As ZString Ptr, ByVal InstallFlags As NewDevUpdatePnpFlags, bRebootRequired As BOOL) As BOOL
#endif
