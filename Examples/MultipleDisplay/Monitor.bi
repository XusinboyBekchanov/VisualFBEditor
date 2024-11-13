'Monitor显示器
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

'EnumDisplayDevices
'  https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-enumdisplaydevicesa
'
'EnumDisplaySettingsEx
'  https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-enumdisplaysettingsexa
'
'ChangeDisplaySettingsEx
'  https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-changedisplaysettingsexw
'
'SetDisplayConfig
'  https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setdisplayconfig
'
'QueryDisplayConfig
'  https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-querydisplayconfig
'
'GetDisplayConfigBufferSizes
'  https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getdisplayconfigbuffersizes
'
'GetMonitorInfo
'https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getmonitorinfoa

'C定义
'typedef struct tagMONITORINFO {
'  DWORD cbSize;
'  Rect  rcMonitor;
'  Rect  rcWork;
'  DWORD dwFlags;
'}
'
'typedef struct tagMONITORINFOEXW : Public tagMONITORINFO {
'  WCHAR szDevice[CCHDEVICENAME];
'} MONITORINFOEXW,*LPMONITORINFOEXW;

'转换成freebasic的定义
'Type tagMONITORINFO
'	cbSize As DWORD
'	rcMonitor As Rect
'	rcWork As Rect
'	dwFlags As DWORD
'End Type
'
'Type tagMONITORINFOEXW
'	Union
'		Type
'			cbSize As DWORD
'			rcMonitor As Rect
'			rcWork As Rect
'			dwFlags As DWORD
'		End Type
'	End Union
'
'	szDevice As WString * 32
'End Type

#include once "win\wingdi.bi"
#include once "win\winuser.bi"

Const EDS_ROTATEDMODE = &H00000004
Const QDC_VIRTUAL_MODE_AWARE= &h00000010
Const QDC_INCLUDE_HMD = &h00000020
Const QDC_VIRTUAL_REFRESH_RATE_AWARE= &h00000040

Using My.Sys.Forms

Type Monitor
	Dim mtrCount As Integer = -1
	Dim mtrMI(Any) As MONITORINFO
	Dim mtrMIEx(Any) As MONITORINFOEX
	Dim mtrHMtr(Any) As HMONITOR
	Dim mtrHDC(Any) As HDC
	Dim mtrRECT(Any) As tagRECT
	
	Declare Constructor
	Declare Destructor
	Declare Static Function EnumDisplayMonitorProc(ByVal hMtr As HMONITOR , ByVal hDCMonitor As HDC , ByVal lprcMonitor As LPRECT , ByVal dwData As LPARAM) As WINBOOL
	Declare Sub ChangeDisplaySettings(DiviceName As LPCWSTR, ByVal ModeNum As Integer, dwFlags As DWORD, dwFlags2 As DWORD, txt As TextBox Ptr)
	Declare Sub EnumDisplayDevice(dwFlags As DWORD, cob As ComboBoxEdit Ptr, lst As ListControl Ptr, txt As TextBox Ptr)
	Declare Sub EnumDisplayMode(DiviceName As LPCWSTR, dwFlags As DWORD, lst As ListControl Ptr, txt As TextBox Ptr)
	Declare Sub EnumDisplayMonitor(txt As TextBox Ptr)
	Declare Sub GetDisplayMode(DiviceName As LPCWSTR, ByVal FlagIndex As Integer, ByVal Index As Integer, lst As ListControl Ptr, txt As TextBox Ptr)
	Declare Sub QueryDisplayConfigs(cob As ComboBoxEdit Ptr, lst As ListControl Ptr, txt As TextBox Ptr)
	Declare Sub Release()
	Declare Sub SetDisplayConfigs(cob As ComboBoxEdit Ptr, txt As TextBox Ptr)
End Type

#ifndef __USE_MAKE__
	#include once "Monitor.bas"
#endif
