' FrmWLAN
' Copyright (c) 2025 CM.Wang
' Freeware. Use at your own risk.

#pragma once

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/Panel.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/ComboBoxEx.bi"
	#include once "mff/ListView.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/Splitter.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/ImageList.bi"
	
	#include once "wlanbase.bi"
	
	Using My.Sys.Forms
	
	Type frmWLANType Extends Form
		pScanEvent As .HANDLE= NULL
		hClient As .HANDLE= NULL
		pIfList As WLAN_INTERFACE_INFO_LIST Ptr
		pList As WLAN_AVAILABLE_NETWORK_LIST Ptr
		
		ret As ULong
		ver As ULong = 0
		
		Declare Static Sub WlanNotificationCallback(pData As L2_NOTIFICATION_DATA Ptr, pContext As Any Ptr)
		Declare Sub GetNetwork()
		Declare Sub Logmsg(msg As WString)
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Sub ComboBoxEx1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Sub ListView1_ItemClick(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Constructor
		
		Dim As Panel Panel1, Panel2
		Dim As CommandButton CommandButton1
		Dim As ComboBoxEx ComboBoxEx1
		Dim As ListView ListView1
		Dim As TextBox TextBox1
		Dim As Splitter Splitter1
		Dim As ImageList ImageList1
	End Type
	
	Constructor frmWLANType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = My.Sys.Language
			End With
		#endif
		' frmWLAN
		With This
			.Name = "frmWLAN"
			.Text = "WLAN"
			.Designer = @This
			.Caption = "WLAN"
			.StartPosition = FormStartPosition.CenterScreen
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnDestroy = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Destroy)
			.SetBounds 0, 0, 800, 600
		End With
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = "Panel1"
			.TabIndex = 0
			.Align = DockStyle.alTop
			.SetBounds 0, 0, 334, 40
			.Designer = @This
			.Parent = @This
		End With
		' Panel2
		With Panel2
			.Name = "Panel2"
			.Text = "Panel2"
			.TabIndex = 1
			.Align = DockStyle.alClient
			.SetBounds 0, 40, 334, 221
			.Designer = @This
			.Parent = @This
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "Refresh"
			.TabIndex = 2
			.Caption = "Refresh"
			.Enabled = False
			.SetBounds 10, 10, 80, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton1_Click)
			.Parent = @Panel1
		End With
		' ComboBoxEx1
		With ComboBoxEx1
			.Name = "ComboBoxEx1"
			.Text = "ComboBoxEx1"
			.TabIndex = 3
			.Style = ComboBoxEditStyle.cbDropDownList
			.Enabled = False
			.ImagesList = @ImageList1
			.SetBounds 100, 10, 680, 22
			.Designer = @This
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @ComboBoxEx1_Selected)
			.Parent = @Panel1
		End With
		' ListView1
		With ListView1
			.Name = "ListView1"
			.Text = "ListView1"
			.TabIndex = 4
			.Align = DockStyle.alClient
			.SmallImages = @ImageList1
			.Images = @ImageList1
			.SetBounds 0, 0, 621, 521
			.Designer = @This
			.OnItemClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer), @ListView1_ItemClick)
			.Parent = @Panel2
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = "TextBox1"
			.TabIndex = 5
			.Align = DockStyle.alBottom
			.Multiline = True
			.ID = 1008
			.ScrollBars = ScrollBarsType.Both
			.SetBounds 0, 350, 784, 171
			.Designer = @This
			.Parent = @Panel2
		End With
		' Splitter1
		With Splitter1
			.Name = "Splitter1"
			.Text = "Splitter1"
			.Align = SplitterAlignmentConstants.alBottom
			.SetBounds 0, 350, 784, 3
			.Designer = @This
			.Parent = @Panel2
		End With
		' ImageList1
		With ImageList1
			.Name = "ImageList1"
			.SetBounds 0, 0, 16, 16
			.Designer = @This
			.Parent = @Panel1
		End With
	End Constructor
	
	Dim Shared frmWLAN As frmWLANType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmWLAN.MainForm = True
		frmWLAN.Show
		App.Run
	#endif
'#End Region

Private Sub frmWLANType.WlanNotificationCallback(pData As L2_NOTIFICATION_DATA Ptr, pContext As Any Ptr)
	If pData = 0 Then Exit Sub
	With *Cast(frmWLANType Ptr, pContext)
		.Logmsg("[=] WlanNotificationCallback " & pData->NotificationSource & ", " & pData->NotificationCode)
		If pData->NotificationSource = WLAN_NOTIFICATION_SOURCE_ACM Then
			Select Case pData->NotificationCode
			Case wlan_notification_acm_scan_complete
				.Logmsg("[+] Scan complete notification")
				.GetNetwork()
			Case wlan_notification_acm_scan_fail
				.Logmsg("[!] Scan failed")
				
			Case Else
				.Logmsg("[*] WlanNotificationCallback unknow event")
				
			End Select
			
		End If
		SetEvent(.pScanEvent)
	End With
End Sub

Private Sub frmWLANType.CommandButton1_Click(ByRef Sender As Control)
	If pIfList Then WlanFreeMemory(pIfList)
	pIfList = NULL
	
	ret = WlanEnumInterfaces(hClient, NULL, @pIfList)
	If ret <> 0 Then
		Logmsg("WlanEnumInterfaces failed, error " & ret)
		WlanCloseHandle(hClient, NULL)
		ComboBoxEx1.Enabled = False
	Else
		Logmsg("Interfaces found: " & pIfList->dwNumberOfItems)
		Dim As Integer i, j
		j = ComboBoxEx1.ItemIndex
		ComboBoxEx1.Clear

		For i = 0 To pIfList->dwNumberOfItems - 1
			With pIfList->InterfaceInfo(i)
				ComboBoxEx1.Items.Add(.strInterfaceDescription, , 15)
				ComboBoxEx1.ItemData(i) = @.InterfaceGuid
			End With
		Next
		ComboBoxEx1.Enabled = True
		
		If ComboBoxEx1.ItemCount = 0 Then Exit Sub
		If j < 0 Then j = 0
		If j > ComboBoxEx1.ItemCount - 1 Then j = ComboBoxEx1.ItemCount - 1
		ComboBoxEx1.ItemIndex = j
		ComboBoxEx1_Selected(ComboBoxEx1, j)
	End If
End Sub

Private Sub frmWLANType.ComboBoxEx1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	Dim As Integer i, j
	
	ListView1.ListItems.Clear
	
	i = Sender.ItemIndex
	If i < 0 Then Exit Sub
	
	With pIfList->InterfaceInfo(i)
		Logmsg("----------------------------------------------------")
		Logmsg("Interface #" & i)
		Logmsg("Name: " & .strInterfaceDescription)
		Logmsg("State: " & Hex(.isState))
		Logmsg("GUID: " & GUID2WStr(.InterfaceGuid))
		Logmsg("Requesting scan...")
		
		'' 启动扫描
		ret = WlanScan(hClient, .InterfaceGuid, NULL, NULL, NULL)
		If ret <> ERROR_SUCCESS Then
			Logmsg("WlanScan failed = " & ret)
		End If
	End With
End Sub

' 获取可用网络列表
Sub frmWLANType.GetNetwork()
	If pIfList = NULL Then Exit Sub
	Dim As Integer i, j
	i = ComboBoxEx1.ItemIndex
	If i < 0 Then Exit Sub
	
	If pList Then WlanFreeMemory(pList)
	pList = NULL
	
	ListView1.ListItems.Clear
	With pIfList->InterfaceInfo(i)
		ret = WlanGetAvailableNetworkList(hClient, .InterfaceGuid, 3, NULL, @pList)
		For j = 0 To pList->dwNumberOfItems - 1
			With pList->Network(j)
				ListView1.ListItems.Add(SSID2WStr(.dot11Ssid), 18)
				ListView1.ListItems.Item(j)->Text(1) = .wlanSignalQuality & "%"
				ListView1.ListItems.Item(j)->Text(2) = IIf(.bNetworkConnectable, "Yes", "No")
				ListView1.ListItems.Item(j)->Text(3) = GetAuthAlgorithmString(.dot11DefaultAuthAlgorithm) & "-" & .dot11DefaultAuthAlgorithm
				ListView1.ListItems.Item(j)->Text(4) = GetCipherAlgorithmString(.dot11DefaultCipherAlgorithm) & "-" & .dot11DefaultCipherAlgorithm
				ListView1.ListItems.Item(j)->Text(5) = IIf(.bSecurityEnabled, "YES", "NO")
				ListView1.ListItems.Item(j)->Text(6) = "" & .dot11BssType
				ListView1.ListItems.Item(j)->Text(7) = phy_type_to_string(.dot11PhyTypes(0))
			End With
		Next
	End With
End Sub
Sub frmWLANType.Logmsg(msg As WString)
	TextBox1.AddLine msg
End Sub

Private Sub frmWLANType.Form_Create(ByRef Sender As Control)
	'Dim pFileInfo As SHFILEINFO
	'ImageList1.Handle = Cast(Any Ptr, SHGetFileInfo("", 0, @pFileInfo, SizeOf(pFileInfo), SHGFI_SYSICONINDEX Or SHGFI_ICON Or SHGFI_SMALLICON Or SHGFI_LARGEICON Or SHGFI_PIDL Or SHGFI_DISPLAYNAME Or SHGFI_TYPENAME Or SHGFI_ATTRIBUTES))
	
	Dim i As Long
	Dim j As Long
	Dim Icon As HICON
	
	j = ExtractIconEx("C:\Windows\System32\shell32.dll", -1, 0, 0, 1)
	For i = 0 To j
		ExtractIconEx "C:\Windows\System32\shell32.dll", i, 0, @Icon, 1
		ImageList_ReplaceIcon(ImageList1.Handle, -1, Icon)
		DestroyIcon Icon
	Next
	
	TextBox1.Clear
	
	'init columns of listview
	ListView1.Columns.Add(ML("SSID"), , 250)
	ListView1.Columns.Add(ML("Signal"), , 50, cfRight)
	ListView1.Columns.Add(ML("Connectable"), , 80)
	ListView1.Columns.Add(ML("Auth"), , 80)
	ListView1.Columns.Add(ML("Cipher"), , 50)
	ListView1.Columns.Add(ML("Security"), , 60)
	ListView1.Columns.Add(ML("BSS"), , 60)
	ListView1.Columns.Add(ML("PHY"), , 120)
	
	ret = WlanOpenHandle(WLAN_API_VERSION_2_0, NULL, ver, hClient)
	If ret <> 0 Then
		Logmsg("WlanOpenHandle failed, error code: " & ret)
	Else
		' 重置事件状态
		Logmsg("ResetEvent " & ResetEvent(pScanEvent)) 
		
		Logmsg("WLAN API opened (ver " & ver & ")")
		
		pScanEvent = CreateEvent(NULL, False, False, NULL)
		Logmsg("CreateEvent " & pScanEvent)
		
		' 注册通知
		ret = WlanRegisterNotification(hClient, WLAN_NOTIFICATION_SOURCE_ACM, True, @WlanNotificationCallback, @This, NULL, NULL)
		If ret <> ERROR_SUCCESS Then
			Select Case ret
			Case ERROR_INVALID_PARAMETER
				Logmsg("ERROR_INVALID_PARAMETER")
			Case ERROR_INVALID_HANDLE
				Logmsg("ERROR_INVALID_HANDLE")
			Case ERROR_NOT_ENOUGH_MEMORY
				Logmsg("ERROR_NOT_ENOUGH_MEMORY")
			Case ERROR_ACCESS_DENIED
				Logmsg("ERROR_ACCESS_DENIED")
			Case Else
				Logmsg("else")
			End Select
			Logmsg("WlanRegisterNotification failed = " & ret)
		Else
			Logmsg("WlanRegisterNotification passed = " & ret)
			
			CommandButton1.Enabled = True
		End If
	End If
	
	CommandButton1_Click(CommandButton1)
End Sub

Private Sub frmWLANType.Form_Destroy(ByRef Sender As Control)
	If pScanEvent Then CloseHandle(pScanEvent)
	If pIfList Then WlanFreeMemory(pIfList)
	If hClient Then WlanCloseHandle(hClient, NULL)
End Sub

Private Sub frmWLANType.ListView1_ItemClick(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	If pIfList = NULL Then Exit Sub
	If pList = NULL Then Exit Sub
	
	Dim As Integer i, j, k
	i = ComboBoxEx1.ItemIndex
	j = ListView1.SelectedItemIndex
	
	If j < 0 Or i < 0 Then Exit Sub
	TextBox1.Clear
	
	With pList->Network(j)
		Logmsg("SSID: " & SSID2WStr(.dot11Ssid))
		Logmsg("Single: " &.wlanSignalQuality & "%")
		Logmsg("Connectable: " & IIf(.bNetworkConnectable, "Yes", "No"))
		Logmsg("Auth: " & GetAuthAlgorithmString(.dot11DefaultAuthAlgorithm) & "-" & .dot11DefaultAuthAlgorithm)
		Logmsg("Cipher: " & GetCipherAlgorithmString(.dot11DefaultCipherAlgorithm) & "-" & .dot11DefaultCipherAlgorithm)
		Logmsg("Security: " & IIf(.bSecurityEnabled, "Yes", "No"))
		Logmsg("PHY: " & phy_type_to_string(.dot11PhyTypes(0)))
		Logmsg("BSS: " & .dot11BssType)
		
		For k As Integer = 0 To WLAN_MAX_PHY_TYPE_NUMBER - 1
			If .dot11PhyTypes(k) Then
				Logmsg("PHY Type: " & phy_type_to_string(.dot11PhyTypes(k)) & ", "  & k & ", " & .dot11PhyTypes(k))
			End If
		Next
		
		' -------- 调用 BSS 列表 --------
		Dim pBssList As PWLAN_BSS_LIST
		
		ret = WlanGetNetworkBssList(hClient, pIfList->InterfaceInfo(i).InterfaceGuid, @.dot11Ssid, .dot11BssType, False, NULL, @pBssList)
		
		If ret <> ERROR_SUCCESS Then
			Logmsg("(No BSS list error = " & ret & ")")
			Exit Sub
		End If
		
		Logmsg("    BSS entries: " & pBssList->dwNumberOfItems)
		
		For k = 0 To pBssList->dwNumberOfItems - 1
			With pBssList->wlanBssEntries(k)
				Logmsg("    -- BSS[" & k + 1 & "]")
				
				' MAC
				Logmsg("       BSSID = " & _
				Hex(.dot11Bssid.ucDot11MacAddress(0), 2) & ":" & _
				Hex(.dot11Bssid.ucDot11MacAddress(1), 2) & ":" & _
				Hex(.dot11Bssid.ucDot11MacAddress(2), 2) & ":" & _
				Hex(.dot11Bssid.ucDot11MacAddress(3), 2) & ":" & _
				Hex(.dot11Bssid.ucDot11MacAddress(4), 2) & ":" & _
				Hex(.dot11Bssid.ucDot11MacAddress(5), 2))
				
				' 信道
				Dim freq As ULong = .ulChCenterFrequency
				Dim channel As Integer = 0
				If freq >= 2412000 AndAlso freq <= 2484000 Then
					channel = (freq - 2412000) \ 5000 + 1
				ElseIf freq >= 5000000 AndAlso freq <= 5900000 Then
					channel = (freq - 5000000) \ 5000
				End If
				
				Logmsg("       Frequency = " & freq & "kHz  (Channel " & channel & ")")
				Logmsg("       RSSI = " & .lRssi & "dBm")
				Logmsg("       PHY Type = " & phy_type_to_string(.dot11BssPhyType) & ", " & .dot11BssPhyType)
			End With
		Next
		If pBssList Then WlanFreeMemory(pBssList)
		pBssList = NULL
	End With
End Sub