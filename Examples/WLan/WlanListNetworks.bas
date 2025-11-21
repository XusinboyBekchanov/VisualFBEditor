' Copyright (c) 2025 CM.Wang
' Freeware. Use at your own risk.

#pragma once

#include once "wlanbase.bi"

Dim Shared g_scanEvent As HANDLE

' ------------------------------------------------------------
' WLAN 通知回调
' ------------------------------------------------------------
Sub WlanNotificationCallback(pData As L2_NOTIFICATION_DATA Ptr, pContext As Any Ptr)
	If pData = 0 Then Exit Sub
	
	?"[=] WlanNotificationCallback", pData->NotificationSource, pData->NotificationCode
	If pData->NotificationSource = WLAN_NOTIFICATION_SOURCE_ACM Then
		Select Case pData->NotificationCode
		Case wlan_notification_acm_scan_complete
			?"[+] Scan complete notification"
			'设置事件为有信号状态
			SetEvent(g_scanEvent)
		Case wlan_notification_acm_scan_fail
			?"[!] Scan failed"
			
		Case Else
			?"[*] WlanNotificationCallback unknow event"
			
		End Select
		
	End If
End Sub

'' ----------------------------------------------------------
'' 主程序
'' ----------------------------------------------------------
Dim As HANDLE hClient = 0
Dim As ULong ver = 0
Dim As ULong ret = WlanOpenHandle(WLAN_API_VERSION_2_0, NULL, ver, hClient)

If ret <> 0 Then
	?"WlanOpenHandle failed, error code: "; ret
	Sleep : End
End If

?"WLAN API opened (ver "; ver; ")"
Print

g_scanEvent = CreateEvent(NULL, False, False, NULL)
If g_scanEvent = NULL Then
    ?"CreateEvent failed, error: "; GetLastError()
    WlanCloseHandle(hClient, NULL)
    Sleep : End
End If
?"CreateEvent "; g_scanEvent

' 注册通知
ret = WlanRegisterNotification(hClient, WLAN_NOTIFICATION_SOURCE_ACM, True, @WlanNotificationCallback, NULL, NULL, NULL)
?"WlanRegisterNotification "; ret
If ret <> ERROR_SUCCESS Then
	Select Case ret
	Case ERROR_INVALID_PARAMETER
		?"ERROR_INVALID_PARAMETER"
	Case ERROR_INVALID_HANDLE
		?"ERROR_INVALID_HANDLE"
	Case ERROR_NOT_ENOUGH_MEMORY
		?"ERROR_NOT_ENOUGH_MEMORY"
	Case ERROR_ACCESS_DENIED
		?"ERROR_ACCESS_DENIED"
	Case Else
		?"else"
	End Select
	?"WlanRegisterNotification failed = "; ret
	WlanCloseHandle(hClient, NULL)
	End 1
End If

Dim As WLAN_INTERFACE_INFO_LIST Ptr pIfList
ret = WlanEnumInterfaces(hClient, NULL, @pIfList)
If ret <> 0 Then
	?"WlanEnumInterfaces failed, error "; ret
	WlanCloseHandle(hClient, NULL)
	Sleep : End
End If

?"Interfaces found: "; pIfList->dwNumberOfItems
Print

' 检查是否有可用接口
If pIfList->dwNumberOfItems = 0 Then
    ?"No WiFi interfaces found"
    WlanFreeMemory(pIfList)
    WlanCloseHandle(hClient, NULL)
    Sleep
    End
End If

For i As Integer = 0 To pIfList->dwNumberOfItems - 1
	Dim As WLAN_AVAILABLE_NETWORK_LIST Ptr pList
	
	With pIfList->InterfaceInfo(i)
		?"===================================================="
		?"Interface #"; i
		?"Name: "; .strInterfaceDescription
		?"State: "; Hex(.isState)
		?"GUID: "; GUID2WStr(.InterfaceGuid)
		?"Requesting scan..."
		
		' 重置事件状态
		ResetEvent(g_scanEvent)
		
		'' 启动扫描
		ret = WlanScan(hClient, .InterfaceGuid, NULL, NULL, NULL)
		If ret <> ERROR_SUCCESS Then
			?"WlanScan failed = "; ret
			Continue For
		End If
		
		' 等待扫描完成（设置超时时间，避免无限等待）
		?"(0) Waiting for scan completion..."
		Dim As ULong waitResult = WaitForSingleObject(g_scanEvent, 10000) ' 10秒超时
		Select Case waitResult
		Case WAIT_OBJECT_0
			?"(1) Scan completed successfully"
		Case WAIT_TIMEOUT
			?"(2) Scan timed out after 10 seconds"
			Continue For
		Case WAIT_FAILED
			?"(3) WaitForSingleObject failed, error: "; GetLastError()
			Continue For
		Case Else
			?"(4) WaitForSingleObject unknown result: "; waitResult
			Continue For
		End Select
		
		'' 获取可用网络列表
		' 参数3对应WLAN_AVAILABLE_NETWORK_INCLUDE_ALL_ADHOC_PROFILES
		ret = WlanGetAvailableNetworkList(hClient, .InterfaceGuid, 3, NULL, @pList)
	End With
	
	If ret <> 0 Then
		?"  WlanGetAvailableNetworkList failed, error "; ret
		Continue For
	End If
	
	?"  Available networks: "; pList->dwNumberOfItems
	Print
	
	For j As Integer = 0 To pList->dwNumberOfItems - 1
		?"["; j; "]"
		With pList->Network(j)
			?"    SSID: "; SSID2WStr(.dot11Ssid)
			?"    Signal: "; .wlanSignalQuality; "%"
			?"    Connectable: "; IIf(.bNetworkConnectable, "Yes", "No")
			?"    Auth: "; GetAuthAlgorithmString(.dot11DefaultAuthAlgorithm), .dot11DefaultAuthAlgorithm
			?"    Cipher: "; GetCipherAlgorithmString(.dot11DefaultCipherAlgorithm), .dot11DefaultCipherAlgorithm
			?"    Security: "; IIf(.bSecurityEnabled, "YES", "NO")
			
			' 显示PHY类型
			Dim hasPhyType As Boolean = False
			For k As Integer = 0 To WLAN_MAX_PHY_TYPE_NUMBER - 1
				If .dot11PhyTypes(k) <> dot11_phy_type_unknown Then
					If Not hasPhyType Then
					    ?"    PHY Types: ";
					    hasPhyType = True
					End If
					?"      - "; phy_type_to_string(.dot11PhyTypes(k))
				End If
			Next
			If Not hasPhyType Then
			    ?"    PHY Types: Unknown"
			End If
			
			?"    BSS Type: "; .dot11BssType
			
			' -------- 调用 BSS 列表 --------
			Dim pBssList As PWLAN_BSS_LIST
			
			ret = WlanGetNetworkBssList(hClient, pIfList->InterfaceInfo(i).InterfaceGuid, @.dot11Ssid, .dot11BssType, False, NULL, @pBssList)
			
			If ret <> ERROR_SUCCESS Then
				?"    (No BSS list available, error = "; ret; ")"
				Continue For
			End If
			
			?"    BSS entries: "; pBssList->dwNumberOfItems
			
			For k As Integer = 0 To pBssList->dwNumberOfItems - 1
				With pBssList->wlanBssEntries(k)
					?"      -- BSS["; k + 1; "]"
					
					' MAC地址
					Dim As String macAddr = _
					LCase(Hex(.dot11Bssid.ucDot11MacAddress(0), 2)) & ":" & _
					LCase(Hex(.dot11Bssid.ucDot11MacAddress(1), 2)) & ":" & _
					LCase(Hex(.dot11Bssid.ucDot11MacAddress(2), 2)) & ":" & _
					LCase(Hex(.dot11Bssid.ucDot11MacAddress(3), 2)) & ":" & _
					LCase(Hex(.dot11Bssid.ucDot11MacAddress(4), 2)) & ":" & _
					LCase(Hex(.dot11Bssid.ucDot11MacAddress(5), 2))
					
					?"         BSSID: "; macAddr
					
					' 信道和频率
					Dim As ULong freq = .ulChCenterFrequency
					Dim As Integer channel = 0
					If freq >= 2412000 AndAlso freq <= 2484000 Then
						channel = (freq - 2412000) \ 5000 + 1
					ElseIf freq >= 5000000 AndAlso freq <= 5900000 Then
						channel = (freq - 5000000) \ 5000
					ElseIf freq >= 5905000 AndAlso freq <= 7115000 Then
						channel = (freq - 5905000) \ 5000 + 1
					End If
					
					?"         Frequency: "; freq; " kHz (Channel "; channel; ")"
					?"         RSSI: "; .lRssi; " dBm"
					?"         PHY Type: "; phy_type_to_string(.dot11BssPhyType)
				End With
			Next
			
			' 释放BSS列表内存
			If pBssList <> NULL Then 
			    WlanFreeMemory(pBssList)
			    pBssList = NULL
			End If
			Print
		End With
	Next
	
	' 释放网络列表内存
	WlanFreeMemory(pList)
	pList = NULL
Next

' 清理资源
CloseHandle(g_scanEvent)
WlanFreeMemory(pIfList)
WlanCloseHandle(hClient, NULL)

?"Scan completed. Press any key to exit..."
Sleep
?"Done."



