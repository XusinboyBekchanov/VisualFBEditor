#pragma once

#ifndef UNICODE
	#define UNICODE
#endif

#ifndef _WIN32_WINNT
	#define _WIN32_WINNT &h0602
#endif

#ifdef __FB_64BIT__
	#libpath "./lib/win64"
#else
	#libpath "./lib/win32"
#endif

' --- Required headers (assumed present) ---
#include once "windows.bi"
#include once "win/shlobj.bi"
#include once "win/shlwapi.bi"
#include once "win/ole2.bi"
#include once "vbcompat.bi"
#include once "win/ocidl.bi"
#include once "win/objbase.bi"
#include once "win/strmif.bi"
#include once "win/dshow.bi"
#include once "crt.bi"
#include once "win/commdlg.bi"
#include once "crt/string.bi"

#include once "wlanapi.bi"

'' ----------------------------------------------------------
'' 辅助函数
'' ----------------------------------------------------------

' 转换GUID为WString
Function GUID2WStr(ByRef g As GUID) ByRef As WString
	Static As WString * 64 guidStr
	StringFromGUID2(@g, @guidStr, 64)
	Function = guidStr
End Function

' 转换SSID(utf8)为WString
Function SSID2WStr(ByRef ssid As DOT11_SSID) ByRef As WString
	Dim wideCharCount As Long
	Dim result As Long
	Dim error_code As Long
	Static finalWString As WString * 129
	finalWString = "(hidden)"
	If ssid.uSSIDLength Then
		wideCharCount = MultiByteToWideChar(CP_UTF8, 0, @ssid.ucSSID, CInt(ssid.uSSIDLength), ByVal 0, 0)
		If wideCharCount Then
			Dim wstrBuffer As WString * 129
			result = MultiByteToWideChar(CP_UTF8, 0, @ssid.ucSSID, CInt(ssid.uSSIDLength), wstrBuffer, wideCharCount)
			If result > 0 Then
				' --- 成功转换 ---
				finalWString = Left(wstrBuffer, result)
				Return finalWString
			End If ' If result > 0
		End If
	End If
	Return finalWString
End Function

' 获取接口状态描述
Function GetInterfaceStateString(state As WLAN_INTERFACE_STATE) As String
	Select Case state
	Case wlan_interface_state_not_ready: Return "Not ready"
	Case wlan_interface_state_connected: Return "Connected"
	Case wlan_interface_state_ad_hoc_network_formed: Return "Ad hoc formed"
	Case wlan_interface_state_disconnecting: Return "Disconnecting"
	Case wlan_interface_state_disconnected: Return "Disconnected"
	Case wlan_interface_state_associating: Return "Associating"
	Case wlan_interface_state_discovering: Return "Discovering"
	Case wlan_interface_state_authenticating: Return "Authenticating"
	Case Else: Return "Unknown"
	End Select
End Function

' 获取认证算法描述
Function GetAuthAlgorithmString(algo As DOT11_AUTH_ALGORITHM) As String
	Select Case algo
	Case DOT11_AUTH_ALGO_80211_OPEN: Return "Open"
	Case DOT11_AUTH_ALGO_80211_SHARED_KEY: Return "Shared key"
	Case DOT11_AUTH_ALGO_WPA: Return "WPA"
	Case DOT11_AUTH_ALGO_WPA_PSK: Return "WPA-PSK"
	Case DOT11_AUTH_ALGO_WPA_NONE: Return "WPA-None"
	Case DOT11_AUTH_ALGO_RSNA: Return "RSNA"
	Case DOT11_AUTH_ALGO_RSNA_PSK: Return "RSNA-PSK"
	Case DOT11_AUTH_ALGO_WPA3: Return "WPA3"
	Case DOT11_AUTH_ALGO_WPA3_SAE: Return "WPA3-SAE"
	Case DOT11_AUTH_ALGO_OWE: Return "OWE"
	Case DOT11_AUTH_ALGO_IHV_START: Return "IHV start"
	Case DOT11_AUTH_ALGO_IHV_END: Return "IHV end"
	Case Else: Return "Unknown (" & algo & ")"
	End Select
End Function

' 获取加密算法描述
Function GetCipherAlgorithmString(algo As DOT11_CIPHER_ALGORITHM) As String
	Select Case algo
	Case DOT11_CIPHER_ALGO_NONE: Return "None"
	Case DOT11_CIPHER_ALGO_WEP40: Return "WEP40"
	Case DOT11_CIPHER_ALGO_TKIP: Return "TKIP"
	Case DOT11_CIPHER_ALGO_CCMP: Return "CCMP"
	Case DOT11_CIPHER_ALGO_WEP104: Return "WEP104"
	Case DOT11_CIPHER_ALGO_BIP: Return "BIP"
	Case DOT11_CIPHER_ALGO_GCMP: Return "GCMP"
	Case DOT11_CIPHER_ALGO_GCMP_256: Return "GCMP-256"
	Case DOT11_CIPHER_ALGO_CCMP_256: Return "CCMP-256"
	Case DOT11_CIPHER_ALGO_BIP_GMAC_128: Return "BIP-GMAC-128"
	Case DOT11_CIPHER_ALGO_BIP_GMAC_256: Return "BIP-GMAC-256"
	Case DOT11_CIPHER_ALGO_BIP_CMAC_256: Return "BIP-CMAC-256"
	Case DOT11_CIPHER_ALGO_WEP: Return "WEP"
	Case Else: Return "Unknown (" & algo & ")"
	End Select
End Function

' PHY 类型描述
Function phy_type_to_string(t As DOT11_PHY_TYPE) As String
	Select Case t
	Case dot11_phy_type_any         : Return "Any" '未初始化"
	Case dot11_phy_type_fhss        : Return "FHSS" '指定频率跳跃分布光谱"
	Case dot11_phy_type_dsss        : Return "DSSS" '指定直接序列分布范围 "
	Case dot11_phy_type_irbaseband  : Return "IR" '指定红外（IR）基带"
	Case dot11_phy_type_ofdm        : Return "802.11a OFDM" '指定正交频率除法"
	Case dot11_phy_type_hrdsss      : Return "802.11b HRDSSS" '指定高速率"
	Case dot11_phy_type_erp         : Return "802.11g ERP" '指定扩展速率"
	Case dot11_phy_type_ht          : Return "802.11n (HT)" '指定高吞吐量"
	Case dot11_phy_type_vht         : Return "802.11ac (VHT)" '非常高的吞吐量 PHY 类型"
	Case dot11_phy_type_dmg         : Return "802.11ad (DMG)" '指定方向多千兆位"
	Case dot11_phy_type_he          : Return "802.11ax (Wi-Fi 6)" '非常高的吞吐量 PHY 类型"
	Case dot11_phy_type_eht         : Return "802.11be (Wi-Fi 7)" '指定非常高的吞吐量 PHY 类型"
	Case dot11_phy_type_IHV_start   : Return "IHV_start"
	Case dot11_phy_type_IHV_end     : Return "IHV_end"
	Case Else : Return "Unknown"
	End Select
End Function
