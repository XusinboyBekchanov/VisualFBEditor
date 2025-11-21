# WLan


<img width="786" height="593" alt="image" src="https://github.com/user-attachments/assets/f36c0cf8-4c95-42e4-a767-2b83708f758d" />



WlanAPI example for VisualFBEditor

A Windows WLANAPI scanning program designed to scan and display available WiFi networks along with their detailed information.

# Key features include:

1. Opening a WLAN API handle
2. Registering a WLAN notification callback
3. Enumerating WiFi interfaces within the system
4. Scanning and displaying a list of available networks
5. Retrieving BSS (Basic Service Set) details for each network

# Notification Callback Function:

1. WlanNotificationCallback: Handles notifications for scan completion and failure.

# Main Workflow:

1. Initialize the WLAN API
2. Create a synchronization event
3. Register the notification callback
4. Enumerate WiFi interfaces
5. Perform a scan on each interface
6. Retrieve and display the list of networks
7. Obtain BSS details for each network

Windows WLANAPI扫描程序，用于扫描和显示可用的WiFi网络及其详细信息。

# 主要功能包括：

1. 打开WLAN API句柄
2. 注册WLAN通知回调
3. 枚举系统中的WiFi接口
4. 扫描并显示可用网络列表
5. 获取每个网络的BSS（基本服务集）详细信息

# 通知回调函数：

1. WlanNotificationCallback：处理扫描完成和失败的通知

# 主要流程：

1. 初始化WLAN API
2. 创建同步事件
3. 注册通知回调
4. 枚举WiFi接口
5. 对每个接口执行扫描
6. 获取并显示网络列表
7. 获取每个网络的BSS详细信息
