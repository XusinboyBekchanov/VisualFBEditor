#pragma once
' NTPClient 网路时间协议
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

#include once "win/winsock2.bi"
#include once "vbcompat.bi"
#include once "crt/time.bi"

#define SecsSince1970 2208988800
#define NTP_PORT 123                ' NTP服务器端口
#define NTP_PACKET_SIZE 48          ' NTP数据包大小

'https://learn.microsoft.com/en-us/windows/win32/winsock/winsock-functions

Dim Shared ntpCancel As Boolean 

'获取NTP服务器时间戳
Function NTP_sec(NtpServ As ZString) As time_t
	
	If Len(NtpServ) < 1 Then
		NtpServ = "time.nist.gov"
	End If
	
	Print NtpServ
	
	Dim wsa_ptr As WSADATA
	
	' 初始化Winsock库
	If WSAStartup(MAKEWORD(2, 0), @wsa_ptr) = SOCKET_ERROR Then
		Print "Failed to initialize Winsock"
		Return 0
	End If
	
	' 检查Winsock版本
	If (wsa_ptr.wVersion <> MAKEWORD(2, 0)) Then
		Print "Failed version of Winsock"
		WSACleanup()
		Return 0
	End If
	
	' 打开Winsock
	Dim sock As SOCKET
	sock = opensocket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
	If (sock = INVALID_SOCKET) Then
		Print "Failed to open Winsock"
		WSACleanup()
		Return 0
	End If
	
	' 设置Winsock
	Dim Bcast As BOOL = True
	Print setsockopt(sock, SOL_SOCKET, SO_BROADCAST, Cast(ZString Ptr, @Bcast), SizeOf(BOOL))
	
	'设置Client地址和端口
	'Dim local_addr As SOCKADDR_IN
	'local_addr.sin_family = AF_INET
	'local_addr.sin_port = htons(NTP_PORT)
	'local_addr.sin_addr.s_addr = INADDR_ANY
	'Print bind(sock, Cast(PSOCKADDR, @local_addr), SizeOf(local_addr))
	
	'设置NTP服务器地址和端口
	Dim ia As IN_ADDR
	Dim hostentry As HOSTENT Ptr
	Dim ip_iaddr As u_long
	
	ia.s_addr = inet_addr(StrPtr(NtpServ))
	
	If (ia.s_addr = INADDR_NONE Or ia.s_addr = 0) Then
		hostentry = gethostbyname(NtpServ)
		If (hostentry = 0) Then
			WSACleanup()
			Return 0
		End If
		ip_iaddr = *Cast(UInteger Ptr, *hostentry->h_addr_list)
	Else
		ip_iaddr = ia.s_addr
	End If
	
	Dim saddr As SOCKADDR_IN
	saddr.sin_family = AF_INET
	saddr.sin_port    = htons(NTP_PORT)
	saddr.sin_addr.s_addr =  ip_iaddr
	
	' 连接NTP服务器
	If (connect(sock, Cast(PSOCKADDR, @saddr), Len(saddr)) = SOCKET_ERROR) Then
		closesocket(sock)
		WSACleanup()
		Return 0
	End If
	
	' 10/27 将套接字设置为非阻塞模式
	Dim nonBlocking As u_long = 1
	ioctlsocket(sock, FIONBIO, @nonBlocking)
	
	' 组装发送的NTP数据包
	Dim ps_buff As UByte Ptr = CAllocate(NTP_PACKET_SIZE, SizeOf(Byte))
	ps_buff[0] = &h1B
	
	' 发送NTP数据包
	'If (sendto(sock, ps_buff, NTP_PACKET_SIZE, 0, Cast(PSOCKADDR, @saddr), SizeOf(saddr)) <= 0) Then
	If (send(sock, ps_buff, NTP_PACKET_SIZE, 0) <= 0) Then
		Print "Failed to send NTP request"
		Deallocate(ps_buff)
		closesocket(sock)
		WSACleanup()
		Return 0
	End If
	
	' 10/27 接收NTP数据包(阻塞)
	'Dim pr_buff As UByte Ptr = CAllocate(NTP_PACKET_SIZE, SizeOf(Byte))
	''Dim rcv_bytes As Integer = recvfrom(sock, pr_buff, NTP_PACKET_SIZE, MSG_PEEK, Cast(PSOCKADDR, @saddr), SizeOf(saddr))
	'Dim rcv_bytes As Integer = recv(sock, pr_buff, NTP_PACKET_SIZE, MSG_PEEK)
	'If (rcv_bytes < NTP_PACKET_SIZE Or Cast(UByte, pr_buff[40]) < 127) Then
	'	Print "Failed to receive NTP response"
	'	Deallocate(pr_buff)
	'	closesocket(sock)
	'	WSACleanup()
	'	Return 0
	'End If
	
	' 10/27 接收NTP数据包（非阻塞）
	Dim pr_buff As UByte Ptr = CAllocate(NTP_PACKET_SIZE, SizeOf(Byte))
	Dim rcv_bytes As Integer
	ntpCancel = False
	Do
		'rcv_bytes = recvfrom(sock, pr_buff, NTP_PACKET_SIZE, MSG_PEEK, Cast(PSOCKADDR, @saddr), SizeOf(saddr))
		rcv_bytes = recv(sock, pr_buff, NTP_PACKET_SIZE, 0)
		App.DoEvents
		If ntpCancel Then Exit Do
	Loop While(rcv_bytes <> NTP_PACKET_SIZE)
	
	' 将NTP时间戳转换为本地时间戳
	Dim res_sec As time_t = 0
	res_sec  = pr_buff[40] Shl 24
	res_sec += pr_buff[41] Shl 16
	res_sec += pr_buff[42] Shl 8
	res_sec += pr_buff[43] Shl 0
	
	Deallocate(ps_buff)
	Deallocate(pr_buff)

	'关闭清理winsocke
	closesocket(sock)
	WSACleanup()
	
	If (res_sec <= SecsSince1970) Then Return 0
	Return (res_sec - SecsSince1970)
End Function

'时间类型转换time_t为Double
Function NTP_dbl(GMT_sec As time_t, timezonebias As Integer = -480) As Double
	Print GMT_sec
	
	Dim gmttime As Double
	Dim exacttime As Double
	
	If (GMT_sec > 0) Then
		Dim As tm Ptr GMT_tm = gmtime(@GMT_sec)
		
		gmttime = DateSerial(GMT_tm->tm_year + 1900, GMT_tm->tm_mon + 1, GMT_tm->tm_mday)
		gmttime += TimeSerial(GMT_tm->tm_hour, GMT_tm->tm_min, GMT_tm->tm_sec)
		
		Print "Greenwich mean time: " & Format(gmttime, "yyyy/mm/dd hh:mm:ss")
		
		Dim As time_t Exact_sec = GMT_sec - (60 * timezonebias)
		GMT_tm = gmtime(@Exact_sec)
		
		exacttime = DateSerial(GMT_tm->tm_year + 1900, GMT_tm->tm_mon + 1, GMT_tm->tm_mday)
		exacttime += TimeSerial(GMT_tm->tm_hour, GMT_tm->tm_min, GMT_tm->tm_sec)
		Print "Exact time:          " & Format(exacttime, "yyyy/mm/dd hh:mm:ss")
	Else
		Print "Wrong time stamp..."
	End If
	
	Return exacttime
End Function

