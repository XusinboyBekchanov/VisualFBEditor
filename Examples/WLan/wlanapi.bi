'' wlanapi.bi
'' Targets: FreeBASIC on Windows, links to wlanapi.dll

' Copyright (c) 2025 CM.Wang
' Freeware. Use at your own risk.

#inclib "wlanapi"

#include once "windows.bi"
#include once "win/windef.bi"
#include once "win/winnt.bi"
#include once "win/guiddef.bi"

#ifndef _WLANAPI_BI_ADV_
	#define _WLANAPI_BI_ADV_
	
	'' ---------------------------
	'' Basic constants / versions
	'' ---------------------------
	#define WLAN_API_VERSION_1_0        &h00000001
	#define WLAN_API_VERSION_2_0        &h00000002
	#define WLAN_API_VERSION_2_1        &h00000003
	
	#define DOT11_SSID_MAX_LENGTH      32
	#define DOT11_MAC_ADDRESS_LENGTH   6
	#define WLAN_MAX_PHY_TYPE_NUMBER   8
	#define WLAN_MAX_NAME_LENGTH       256
	#define WLAN_AVAILABLE_NETWORK_CONNECTED &h00000001
	
	'' ---------------------------
	'' Enums (core)
	'' ---------------------------
	Enum '' DOT11_BSS_TYPE
		dot11_BSS_type_infrastructure = 1,
		dot11_BSS_type_independent = 2,
		dot11_BSS_type_any = 3
	End Enum '' DOT11_BSS_TYPE
	Type DOT11_BSS_TYPE As ULong
	
	'' DOT11_PHY_TYPE documentation at https://learn.microsoft.com/windows/win32/NativeWiFi/dot11-phy-type
	Enum '' DOT11_PHY_TYPE
		dot11_phy_type_IHV_start = -2147483648,
		dot11_phy_type_IHV_end = -1,
		dot11_phy_type_unknown = 0,
		dot11_phy_type_any = 0,
		dot11_phy_type_fhss = 1,
		dot11_phy_type_dsss = 2,
		dot11_phy_type_irbaseband = 3,
		dot11_phy_type_ofdm = 4,
		dot11_phy_type_hrdsss = 5,
		dot11_phy_type_erp = 6,
		dot11_phy_type_ht = 7,
		dot11_phy_type_vht = 8,
		dot11_phy_type_dmg = 9,
		dot11_phy_type_he = 10,
		dot11_phy_type_eht = 11
	End Enum '' DOT11_PHY_TYPE
	Type DOT11_PHY_TYPE As ULong
	
	'' WLAN_INTERFACE_STATE documentation at https://learn.microsoft.com/windows/win32/api/wlanapi/ne-wlanapi-wlan_interface_state~r1
	Enum '' WLAN_INTERFACE_STATE
		wlan_interface_state_not_ready = 0,
		wlan_interface_state_connected = 1,
		wlan_interface_state_ad_hoc_network_formed = 2,
		wlan_interface_state_disconnecting = 3,
		wlan_interface_state_disconnected = 4,
		wlan_interface_state_associating = 5,
		wlan_interface_state_discovering = 6,
		wlan_interface_state_authenticating = 7
	End Enum '' WLAN_INTERFACE_STATE
	Type WLAN_INTERFACE_STATE As ULong
	
	'' WLAN_CONNECTION_MODE documentation at https://learn.microsoft.com/windows/win32/api/wlanapi/ne-wlanapi-wlan_connection_mode
	Enum '' WLAN_CONNECTION_MODE
		wlan_connection_mode_profile = 0,
		wlan_connection_mode_temporary_profile = 1,
		wlan_connection_mode_discovery_secure = 2,
		wlan_connection_mode_discovery_unsecure = 3,
		wlan_connection_mode_auto = 4,
		wlan_connection_mode_invalid = 5
	End Enum '' WLAN_CONNECTION_MODE
	Type WLAN_CONNECTION_MODE As ULong
	
	Enum WLAN_REASON_CODE
		wlan_reason_code_success = 0
		wlan_reason_code_unknown = 1
	End Enum
	
	'' DOT11_AUTH_ALGORITHM documentation at https://learn.microsoft.com/windows/win32/NativeWiFi/dot11-auth-algorithm
	Enum '' DOT11_AUTH_ALGORITHM
		DOT11_AUTH_ALGO_IHV_START = -2147483648,
		DOT11_AUTH_ALGO_IHV_END = -1,
		DOT11_AUTH_ALGO_80211_OPEN = 1,
		DOT11_AUTH_ALGO_80211_SHARED_KEY = 2,
		DOT11_AUTH_ALGO_WPA = 3,
		DOT11_AUTH_ALGO_WPA_PSK = 4,
		DOT11_AUTH_ALGO_WPA_NONE = 5,
		DOT11_AUTH_ALGO_RSNA = 6,
		DOT11_AUTH_ALGO_RSNA_PSK = 7,
		DOT11_AUTH_ALGO_WPA3 = 8,
		DOT11_AUTH_ALGO_WPA3_ENT_192 = 8,
		DOT11_AUTH_ALGO_WPA3_SAE = 9,
		DOT11_AUTH_ALGO_OWE = 10,
		DOT11_AUTH_ALGO_WPA3_ENT = 11
	End Enum '' DOT11_AUTH_ALGORITHM
	Type DOT11_AUTH_ALGORITHM As ULong
	
	'' DOT11_CIPHER_ALGORITHM documentation at https://learn.microsoft.com/windows/win32/NativeWiFi/dot11-cipher-algorithm
	Enum '' DOT11_CIPHER_ALGORITHM
		DOT11_CIPHER_ALGO_IHV_START = -2147483648,
		DOT11_CIPHER_ALGO_IHV_END = -1,
		DOT11_CIPHER_ALGO_NONE = 0,
		DOT11_CIPHER_ALGO_WEP40 = 1,
		DOT11_CIPHER_ALGO_TKIP = 2,
		DOT11_CIPHER_ALGO_CCMP = 4,
		DOT11_CIPHER_ALGO_WEP104 = 5,
		DOT11_CIPHER_ALGO_BIP = 6,
		DOT11_CIPHER_ALGO_GCMP = 8,
		DOT11_CIPHER_ALGO_GCMP_256 = 9,
		DOT11_CIPHER_ALGO_CCMP_256 = 10,
		DOT11_CIPHER_ALGO_BIP_GMAC_128 = 11,
		DOT11_CIPHER_ALGO_BIP_GMAC_256 = 12,
		DOT11_CIPHER_ALGO_BIP_CMAC_256 = 13,
		DOT11_CIPHER_ALGO_WPA_USE_GROUP = 256,
		DOT11_CIPHER_ALGO_RSN_USE_GROUP = 256,
		DOT11_CIPHER_ALGO_WEP = 257
	End Enum '' DOT11_CIPHER_ALGORITHM
	Type DOT11_CIPHER_ALGORITHM As ULong
	
	'' WLAN_NOTIFICATION_ACM documentation at https://learn.microsoft.com/windows/win32/api/wlanapi/ne-wlanapi-wlan_notification_acm~r1
	Enum '' WLAN_NOTIFICATION_ACM
		wlan_notification_acm_start = 0,
		wlan_notification_acm_autoconf_enabled = 1,
		wlan_notification_acm_autoconf_disabled = 2,
		wlan_notification_acm_background_scan_enabled = 3,
		wlan_notification_acm_background_scan_disabled = 4,
		wlan_notification_acm_bss_type_change = 5,
		wlan_notification_acm_power_setting_change = 6,
		wlan_notification_acm_scan_complete = 7,
		wlan_notification_acm_scan_fail = 8,
		wlan_notification_acm_connection_start = 9,
		wlan_notification_acm_connection_complete = 10,
		wlan_notification_acm_connection_attempt_fail = 11,
		wlan_notification_acm_filter_list_change = 12,
		wlan_notification_acm_interface_arrival = 13,
		wlan_notification_acm_interface_removal = 14,
		wlan_notification_acm_profile_change = 15,
		wlan_notification_acm_profile_name_change = 16,
		wlan_notification_acm_profiles_exhausted = 17,
		wlan_notification_acm_network_not_available = 18,
		wlan_notification_acm_network_available = 19,
		wlan_notification_acm_disconnecting = 20,
		wlan_notification_acm_disconnected = 21,
		wlan_notification_acm_adhoc_network_state_change = 22,
		wlan_notification_acm_profile_unblocked = 23,
		wlan_notification_acm_screen_power_change = 24,
		wlan_notification_acm_profile_blocked = 25,
		wlan_notification_acm_scan_list_refresh = 26,
		wlan_notification_acm_operational_state_change = 27,
		wlan_notification_acm_end = 28
	End Enum '' WLAN_NOTIFICATION_ACM
	Type WLAN_NOTIFICATION_ACM As ULong
	
	Enum '' WLAN_NOTIFICATION_SOURCES
		WLAN_NOTIFICATION_SOURCE_NONE = &h0,
		WLAN_NOTIFICATION_SOURCE_ONEX = &h4,
		WLAN_NOTIFICATION_SOURCE_ACM = &h8,
		WLAN_NOTIFICATION_SOURCE_MSM = &h10,
		WLAN_NOTIFICATION_SOURCE_SECURITY = &h20,
		WLAN_NOTIFICATION_SOURCE_IHV = &h40,
		WLAN_NOTIFICATION_SOURCE_HNWK = &h80,
		WLAN_NOTIFICATION_SOURCE_DEVICE_SERVICE = &h800,
		WLAN_NOTIFICATION_SOURCE_ALL = &hFFFF
	End Enum '' WLAN_NOTIFICATION_SOURCES
	Type WLAN_NOTIFICATION_SOURCES As ULong
	'Type WLAN_NOTIFICATION_SOURCES As ULong
	
	'' ---------------------------
	'' Basic structures
	'' ---------------------------
	
	'' DOT11_SSID documentation at https://learn.microsoft.com/windows/win32/NativeWiFi/dot11-ssid
	Type DOT11_SSID Field = 1
		uSSIDLength As DWORD 'ULong
		ucSSID As ZString * DOT11_SSID_MAX_LENGTH ' (DOT11_SSID_MAX_LENGTH - 1) As UByte
	End Type
	Type PDOT11_SSID As DOT11_SSID Ptr
	
	Type _DOT11_MAC_ADDRESS Field = 1
		ucDot11MacAddress(0 To 5) As UByte
	End Type
	Type DOT11_MAC_ADDRESS As _DOT11_MAC_ADDRESS
	Type PDOT11_MAC_ADDRESS As DOT11_MAC_ADDRESS Ptr
	
	Type _NDIS_OBJECT_HEADER Field = 1
		As UCHAR Type
		Revision As UCHAR
		Size As UShort
	End Type
	Type NDIS_OBJECT_HEADER As _NDIS_OBJECT_HEADER
	Type PNDIS_OBJECT_HEADER As NDIS_OBJECT_HEADER Ptr
	
	Type DOT11_BSSID_LIST Field = 1
		Header As NDIS_OBJECT_HEADER
		uNumOfEntries As ULong
		uTotalNumOfEntries As ULong
		BSSIDs(0 To 0, 0 To 5) As UCHAR
	End Type
	Type PDOT11_BSSID_LIST As DOT11_BSSID_LIST Ptr
	
	Type WLAN_INTERFACE_INFO Field = 1
		InterfaceGuid As GUID
		strInterfaceDescription As WString * WLAN_MAX_NAME_LENGTH
		isState As Long 'WLAN_INTERFACE_STATE
	End Type
	Type PWLAN_INTERFACE_INFO As WLAN_INTERFACE_INFO Ptr
	
	Type WLAN_INTERFACE_INFO_LIST Field = 1
		dwNumberOfItems As ULong
		dwIndex As ULong
		InterfaceInfo(0 To 63) As WLAN_INTERFACE_INFO  '' variable length
	End Type
	Type PWLAN_INTERFACE_INFO_LIST As WLAN_INTERFACE_INFO_LIST Ptr
	
	#define DOT11_RATE_SET_MAX_LENGTH 126
	
	Type WLAN_RATE_SET
		uRateSetLength As ULong
		usRateSet(0 To DOT11_RATE_SET_MAX_LENGTH-1) As UShort
	End Type
	Type PWLAN_RATE_SET As WLAN_RATE_SET Ptr
	
	' // Size = 360 bytes
	Type WLAN_BSS_ENTRY
		dot11Ssid               As DOT11_SSID
		uPhyId                  As DWORD   ' ULONG
		dot11Bssid              As DOT11_MAC_ADDRESS
		dot11BssType            As DOT11_BSS_TYPE
		dot11BssPhyType         As DOT11_PHY_TYPE
		lRssi                   As Long    ' LONG
		uLinkQuality            As DWORD   ' ULONG
		bInRegDomain            As Byte    ' BOOLEAN
		usBeaconPeriod          As WORD    ' USHORT
		ullTimestamp            As ULONGLONG    ' ULONGLONG
		ullHostTimestamp        As ULONGLONG    ' ULONGLONG
		usCapabilityInformation As WORD    ' ULONG
		ulChCenterFrequency     As DWORD   ' ULONG
		wlanRateSet             As WLAN_RATE_SET
		' // the beginning of the IE blob
		' // the offset is w.r.t. the beginning of the entry
		ulIeOffset              As DWORD   ' ULONG
		' // size of the IE blob
		ulIeSize                As DWORD   ' ULONG
	End Type
	Type PWLAN_BSS_ENTRY As WLAN_BSS_ENTRY Ptr
	
	#define WLAN_MAX_PHY_TYPE_NUMBER 8
	
	Type WLAN_SIGNAL_QUALITY As ULong
	Type PWLAN_SIGNAL_QUALITY As WLAN_SIGNAL_QUALITY Ptr
	
	Type WLAN_AVAILABLE_NETWORK Field = 1
		strProfileName As WString *WLAN_MAX_NAME_LENGTH
		dot11Ssid As DOT11_SSID
		dot11BssType As Long 'DOT11_BSS_TYPE
		uNumberOfBssids As DWORD 'ULong
		bNetworkConnectable As Long 'WINBOOL
		wlanNotConnectableReason As DWORD ' WLAN_REASON_CODE
		uNumberOfPhyTypes As DWORD 'ULong
		dot11PhyTypes(WLAN_MAX_PHY_TYPE_NUMBER - 1) As DWORD 'DOT11_PHY_TYPE
		bMorePhyTypes As Long 'WINBOOL
		wlanSignalQuality As DWORD 'WLAN_SIGNAL_QUALITY
		bSecurityEnabled As Long 'WINBOOL
		dot11DefaultAuthAlgorithm As Long 'DOT11_AUTH_ALGORITHM
		dot11DefaultCipherAlgorithm As Long 'DOT11_CIPHER_ALGORITHM
		dwFlags As DWORD
		dwReserved As DWORD
	End Type
	Type PWLAN_AVAILABLE_NETWORK As WLAN_AVAILABLE_NETWORK Ptr
	
	Type WLAN_AVAILABLE_NETWORK_LIST Field = 1
		dwNumberOfItems As DWORD
		dwIndex As DWORD
		Network(0 To 63) As WLAN_AVAILABLE_NETWORK
	End Type
	Type PWLAN_AVAILABLE_NETWORK_LIST As WLAN_AVAILABLE_NETWORK_LIST Ptr
	
	'Not test
	
	Type PWLAN_BSS_ENTRY As WLAN_BSS_ENTRY Ptr
	Type WLAN_BSS_LIST Field = 1
		dwTotalSize As DWORD
		dwNumberOfItems As DWORD
		wlanBssEntries(0 To 24) As WLAN_BSS_ENTRY
	End Type
	Type PWLAN_BSS_LIST As WLAN_BSS_LIST Ptr
	
	Type WLAN_CONNECTION_PARAMETERS Field = 1
		wlanConnectionMode As WLAN_CONNECTION_MODE
		strProfile As LPCWSTR
		pDot11Ssid As PDOT11_SSID
		pDesiredBssidList As PDOT11_BSSID_LIST
		dot11BssType As DOT11_BSS_TYPE
		dwFlags As DWORD
	End Type
	Type PWLAN_CONNECTION_PARAMETERS As WLAN_CONNECTION_PARAMETERS Ptr
	
	Type WLAN_ASSOCIATION_ATTRIBUTES Field = 1
		dot11Ssid As DOT11_SSID
		dot11BssType As DOT11_BSS_TYPE
		dot11Bssid As DOT11_MAC_ADDRESS
		dot11PhyType As DOT11_PHY_TYPE
		uDot11PhyIndex As ULong
		wlanSignalQuality As WLAN_SIGNAL_QUALITY
		ulRxRate As ULong
		ulTxRate As ULong
	End Type
	Type PWLAN_ASSOCIATION_ATTRIBUTES As WLAN_ASSOCIATION_ATTRIBUTES Ptr
	
	Type WLAN_SECURITY_ATTRIBUTES Field = 1
		bSecurityEnabled As WINBOOL
		bOneXEnabled As WINBOOL
		dot11AuthAlgorithm As DOT11_AUTH_ALGORITHM
		dot11CipherAlgorithm As DOT11_CIPHER_ALGORITHM
	End Type
	Type PWLAN_SECURITY_ATTRIBUTES As WLAN_SECURITY_ATTRIBUTES Ptr
	
	Type WLAN_CONNECTION_ATTRIBUTES Field = 1
		isState As WLAN_INTERFACE_STATE
		wlanConnectionMode As WLAN_CONNECTION_MODE
		strProfileName(0 To 255) As WCHAR
		wlanAssociationAttributes As WLAN_ASSOCIATION_ATTRIBUTES
		wlanSecurityAttributes As WLAN_SECURITY_ATTRIBUTES
	End Type
	Type PWLAN_CONNECTION_ATTRIBUTES As WLAN_CONNECTION_ATTRIBUTES Ptr
	
	Type L2_NOTIFICATION_DATA
		NotificationSource As WLAN_NOTIFICATION_SOURCES
		NotificationCode As ULong
		InterfaceGuid As GUID
		dwDataSize As ULong
		pData As Any Ptr
	End Type
	
	Type WLAN_NOTIFICATION_DATA As L2_NOTIFICATION_DATA
	
	Type PWLAN_NOTIFICATION_DATA As WLAN_NOTIFICATION_DATA Ptr
	
	Type WLAN_NOTIFICATION_CALLBACK As Sub( _
	ByVal param0_ As L2_NOTIFICATION_DATA Ptr,  _ '' In & Out
	ByVal param1_ As Any Ptr _ '' In & Out
	)
	
	Type WLAN_PROFILE_INFO Field = 1
		strProfileName As WString * WLAN_MAX_NAME_LENGTH
		dwFlags As ULong
	End Type
	Type PWLAN_PROFILE_INFO As WLAN_PROFILE_INFO Ptr
	
	Type WLAN_PROFILE_INFO_LIST Field = 1
		dwNumberOfItems As ULong
		dwIndex As ULong
		ProfileInfo(Any) As WLAN_PROFILE_INFO
	End Type
	Type PWLAN_PROFILE_INFO_LIST As WLAN_PROFILE_INFO_LIST Ptr
	
	Declare Function WlanOpenHandle Alias "WlanOpenHandle" (ByVal dwClientVersion As ULong, ByVal pReserved As Any Ptr, ByRef pdwNegotiatedVersion As ULong, ByRef phClientHandle As HANDLE) As ULong
	Declare Function WlanCloseHandle Alias "WlanCloseHandle" (ByVal hClientHandle As HANDLE, ByVal pReserved As Any Ptr) As ULong
	Declare Function WlanEnumInterfaces Alias "WlanEnumInterfaces" (ByVal hClientHandle As HANDLE, ByVal pReserved As Any Ptr, ByVal ppInterfaceList As Any Ptr Ptr) As ULong
	Declare Function WlanGetAvailableNetworkList Alias "WlanGetAvailableNetworkList" (ByVal hClientHandle As HANDLE, ByRef pInterfaceGuid As GUID, ByVal dwFlags As ULong, ByVal pReserved As Any Ptr, ByVal ppAvailableNetworkList As Any Ptr Ptr) As ULong
	Declare Function WlanGetNetworkBssList Alias "WlanGetNetworkBssList" (ByVal hClientHandle As HANDLE, ByRef pInterfaceGuid As GUID, ByVal pDot11Ssid As DOT11_SSID Ptr, ByVal dot11BssType As DOT11_BSS_TYPE, ByVal bSecurityEnabled As BOOL, ByVal pReserved As Any Ptr, ByVal ppWlanBssList As Any Ptr Ptr) As ULong
	Declare Function WlanScan Alias "WlanScan" (ByVal hClientHandle As HANDLE, ByRef pInterfaceGuid As GUID, ByVal pDot11Ssid As DOT11_SSID Ptr, ByVal pIeData As Any Ptr, ByVal pReserved As Any Ptr) As ULong
	Declare Function WlanConnect Alias "WlanConnect" (ByVal hClientHandle As HANDLE, ByRef pInterfaceGuid As GUID, ByVal pConnectionParameters As WLAN_CONNECTION_PARAMETERS Ptr, ByVal pReserved As Any Ptr) As ULong
	Declare Function WlanDisconnect Alias "WlanDisconnect" (ByVal hClientHandle As HANDLE, ByRef pInterfaceGuid As GUID, ByVal pReserved As Any Ptr) As ULong
	Declare Function WlanRegisterNotification Alias "WlanRegisterNotification" (ByVal hClientHandle As HANDLE, ByVal dwNotifSource As ULong, ByVal bIgnoreDuplicate As BOOL, ByVal funcCallback As Any Ptr, ByVal pCallbackContext As Any Ptr, ByVal pReserved As Any Ptr, ByVal pdwPrevNotifSource As ULong Ptr) As ULong
	Declare Function WlanQueryInterface Alias "WlanQueryInterface" (ByVal hClient As HANDLE, ByRef pInterfaceGuid As GUID, ByVal OpCode As ULong, ByVal pReserved As Any Ptr, ByRef pdwDataSize As ULong, ByVal ppData As Any Ptr Ptr, ByVal pWlanOpcodeValueType As ULong Ptr) As ULong
	Declare Function WlanSetInterface Alias "WlanSetInterface" (ByVal hClient As HANDLE, ByRef pInterfaceGuid As GUID, ByVal OpCode As ULong, ByVal dwDataSize As ULong, ByVal pData As Any Ptr, ByVal pReserved As Any Ptr) As ULong
	Declare Function WlanSetProfile Alias "WlanSetProfile" (ByVal hClientHandle As HANDLE, ByRef pInterfaceGuid As GUID, ByVal dwFlags As ULong, ByVal strProfileXml As LPCWSTR, ByVal strAllUserProfileSecurity As LPCWSTR, ByVal bOverwrite As BOOL, ByVal pReserved As Any Ptr, ByVal pdwReason As ULong Ptr) As ULong
	Declare Function WlanGetProfileList Alias "WlanGetProfileList" (ByVal hClientHandle As HANDLE, ByRef pInterfaceGuid As GUID, ByVal pReserved As Any Ptr, ByVal ppProfileList As Any Ptr Ptr) As ULong
	Declare Function WlanGetProfile Alias "WlanGetProfile" (ByVal hClientHandle As HANDLE, ByRef pInterfaceGuid As GUID, ByVal pszProfileName As LPCWSTR, ByVal pReserved As Any Ptr, ByVal pstrProfileXml As LPCWSTR Ptr, ByVal pdwFlags As ULong Ptr, ByVal pdwGrantedAccess As ULong Ptr) As ULong
	Declare Function WlanDeleteProfile Alias "WlanDeleteProfile" (ByVal hClientHandle As HANDLE, ByRef pInterfaceGuid As GUID, ByVal strProfileName As LPCWSTR, ByVal pReserved As Any Ptr) As ULong
	Declare Sub WlanFreeMemory Alias "WlanFreeMemory" (ByVal pMemory As Any Ptr)
	
#endif '' _WLANAPI_BI_ADV_
