' IFileDialog Enhanced File Open Dialog
' Copyright (c) 2025 CM.Wang
' Freeware. Use at your own risk.

'该 FreeBASIC 代码实现了一个高级的文件打开对话框，主要功能包括：
'使用 Windows Com 接口 IFileOpenDialog 创建现代化的文件选择对话框
'支持多文件选择（FOS_ALLOWMULTISELECT）
'添加自定义控件组：
'换行符格式选择：Windows (CRLF)、Linux (LF)、Mac OS (CR)
'文本编码选择：ASCII、UTF-8、Unicode (UTF-16 LE)、Unicode Big Endian
'实现完整的 IFileDialogEvents 和 IFileDialogControlEvents 事件处理机制
'提供详细的事件日志输出，用于调试和监控对话框行为
'支持设置初始路径、文件类型过滤器等标准功能
'包含完整的资源管理和内存释放机制

'This FreeBASIC code implements an advanced file open dialog with the following main features:
'Utilizes the Windows COM interface IFileOpenDialog to create a modern file selection dialog
'Supports multiple file selection (FOS_ALLOWMULTISELECT)
'Adds custom control groups:
'Line ending format selection: Windows (CRLF), Linux (LF), Mac OS (CR)
'Text encoding selection: ASCII, UTF-8, Unicode (UTF-16 LE), Unicode Big Endian
'Implements complete IFileDialogEvents and IFileDialogControlEvents event handling mechanisms
'Provides detailed event logging output for debugging and monitoring dialog behavior
'Supports standard functions such as setting initial paths and file type filters
'Includes comprehensive resource management and memory release mechanisms

#pragma once
#ifndef UNICODE
	#define UNICODE
#endif
#ifndef _WIN32_WINNT
	#define _WIN32_WINNT &h0602
#endif

#include once "win/shlobj.bi"
#include once "win/shlwapi.bi"
#include once "win/ole2.bi"

#define SAFE_RELEASE(p) If (p <> NULL) Then Cast(IUnknown Ptr, p)->lpVtbl->Release(Cast(IUnknown Ptr, p)) : p = NULL

' ------------------------------------------------------------------------
'  Constant Definitions
' ------------------------------------------------------------------------

Private Const FILE_DIALOG_GROUP_NEWLINE As DWORD = 5000
Private Const FILE_DIALOG_COMBO_NEWLINE As DWORD = 5001
Private Const FILE_DIALOG_ITEM_WIN_CRLF As DWORD = 5010
Private Const FILE_DIALOG_ITEM_LINUX_LF As DWORD = 5011
Private Const FILE_DIALOG_ITEM_MAC_CR As DWORD = 5012

Private Const FILE_DIALOG_GROUP_ENCODING As DWORD = 6000
Private Const FILE_DIALOG_COMBO_ENCODING As DWORD = 6001
Private Const FILE_DIALOG_ITEM_ASCII As DWORD = 6010
Private Const FILE_DIALOG_ITEM_UTF8 As DWORD = 6011
Private Const FILE_DIALOG_ITEM_UNICODE_LE As DWORD = 6012
Private Const FILE_DIALOG_ITEM_UNICODE_BE As DWORD = 6013

' ------------------------------------------------------------------------
'  Custom Event Receiver Structure
' ------------------------------------------------------------------------

Type CustomFileDialogEvents
	' Virtual function table pointers
	lpVtblFileDialogEvents As IFileDialogEventsVtbl Ptr
	lpVtblFileDialogControlEvents As IFileDialogControlEventsVtbl Ptr
	refCount As Long
	isInitialized As BOOL
	' Dialog reference for event handling
	pFileDialog As IFileDialog Ptr
	pOwner As Any Ptr
End Type

' ------------------------------------------------------------------------
'  Forward Declarations
' ------------------------------------------------------------------------

Declare Function FileDialogControlEvents_AddRef(ByVal This As IFileDialogControlEvents Ptr) As ULong
Declare Function FileDialogControlEvents_Release(ByVal This As IFileDialogControlEvents Ptr) As ULong

' ------------------------------------------------------------------------
'  Helper Function: Get Dialog Option Text
' ------------------------------------------------------------------------

Private Function GetFileDialogOptionsText(ByVal options As DWORD) As String
	Dim result As String = ""
	
	If (options And FOS_OVERWRITEPROMPT) Then result &= "OVERWRITEPROMPT|"
	If (options And FOS_STRICTFILETYPES) Then result &= "STRICTFILETYPES|"
	If (options And FOS_NOCHANGEDIR) Then result &= "NOCHANGEDIR|"
	If (options And FOS_PICKFOLDERS) Then result &= "PICKFOLDERS|"
	If (options And FOS_FORCEFILESYSTEM) Then result &= "FORCEFILESYSTEM|"
	If (options And FOS_ALLNONSTORAGEITEMS) Then result &= "ALLNONSTORAGEITEMS|"
	If (options And FOS_NOVALIDATE) Then result &= "NOVALIDATE|"
	If (options And FOS_ALLOWMULTISELECT) Then result &= "ALLOWMULTISELECT|"
	If (options And FOS_PATHMUSTEXIST) Then result &= "PATHMUSTEXIST|"
	If (options And FOS_FILEMUSTEXIST) Then result &= "FILEMUSTEXIST|"
	If (options And FOS_CREATEPROMPT) Then result &= "CREATEPROMPT|"
	If (options And FOS_SHAREAWARE) Then result &= "SHAREAWARE|"
	If (options And FOS_NOREADONLYRETURN) Then result &= "NOREADONLYRETURN|"
	If (options And FOS_NOTESTFILECREATE) Then result &= "NOTESTFILECREATE|"
	If (options And FOS_HIDEMRUPLACES) Then result &= "HIDEMRUPLACES|"
	If (options And FOS_HIDEPINNEDPLACES) Then result &= "HIDEPINNEDPLACES|"
	If (options And FOS_NODEREFERENCELINKS) Then result &= "NODEREFERENCELINKS|"
	If (options And FOS_DONTADDTORECENT) Then result &= "DONTADDTORECENT|"
	If (options And FOS_FORCESHOWHIDDEN) Then result &= "FORCESHOWHIDDEN|"
	If (options And FOS_DEFAULTNOMINIMODE) Then result &= "DEFAULTNOMINIMODE|"
	If (options And FOS_FORCEPREVIEWPANEON) Then result &= "FORCEPREVIEWPANEON|"
	
	If Len(result) > 0 Then result = Left(result, Len(result) - 1)
	Return result
End Function

' ------------------------------------------------------------------------
'  IFileDialogEvents Interface Implementation
' ------------------------------------------------------------------------

Private Function FileDialogEvents_QueryInterface(ByVal This As IFileDialogEvents Ptr, ByVal riid As Const IID Const Ptr, ByVal ppvObject As Any Ptr Ptr) As HRESULT
	If ppvObject = NULL Then Return E_POINTER
	
	Dim pEvents As CustomFileDialogEvents Ptr = Cast(CustomFileDialogEvents Ptr, This)
	
	If IsEqualGUID(riid, @IID_IUnknown) OrElse IsEqualGUID(riid, @IID_IFileDialogEvents) Then
		*ppvObject = Cast(Any Ptr, This)
		This->lpVtbl->AddRef(This)
		Return S_OK
	ElseIf IsEqualGUID(riid, @IID_IFileDialogControlEvents) Then
		*ppvObject = Cast(Any Ptr, @pEvents->lpVtblFileDialogControlEvents)
		FileDialogControlEvents_AddRef(Cast(IFileDialogControlEvents Ptr, @pEvents->lpVtblFileDialogControlEvents))
		Return S_OK
	End If
	
	*ppvObject = NULL
	Return E_NOINTERFACE
End Function

Private Function FileDialogEvents_AddRef(ByVal This As IFileDialogEvents Ptr) As ULong
	Dim pEvents As CustomFileDialogEvents Ptr = Cast(CustomFileDialogEvents Ptr, This)
	pEvents->refCount += 1
	? "IFileDialogEvents::AddRef() -> " & pEvents->refCount
	Return pEvents->refCount
End Function

Private Function FileDialogEvents_Release(ByVal This As IFileDialogEvents Ptr) As ULong
	Dim pEvents As CustomFileDialogEvents Ptr = Cast(CustomFileDialogEvents Ptr, This)
	pEvents->refCount -= 1
	Dim refCount As Long = pEvents->refCount
	
	? "IFileDialogEvents::Release() -> " & refCount
	
	If refCount = 0 Then
		? "Releasing IFileDialogEvents object"
		
		If pEvents->lpVtblFileDialogEvents Then
			Delete pEvents->lpVtblFileDialogEvents
			pEvents->lpVtblFileDialogEvents = NULL
		End If
		
		If pEvents->lpVtblFileDialogControlEvents Then
			Delete pEvents->lpVtblFileDialogControlEvents
			pEvents->lpVtblFileDialogControlEvents = NULL
		End If
		
		SAFE_RELEASE(pEvents->pFileDialog)
		Delete pEvents
	End If
	
	Return refCount
End Function

' ------------------------------------------------------------------------
'  IFileDialogControlEvents Interface Implementation
' ------------------------------------------------------------------------

Private Function FileDialogControlEvents_QueryInterface(ByVal This As IFileDialogControlEvents Ptr, ByVal riid As Const IID Const Ptr, ByVal ppvObject As Any Ptr Ptr) As HRESULT
	If ppvObject = NULL Then Return E_POINTER
	
	Dim pEvents As CustomFileDialogEvents Ptr = Cast(CustomFileDialogEvents Ptr, Cast(Byte Ptr, This) - SizeOf(IFileDialogEventsVtbl Ptr))
	
	If IsEqualGUID(riid, @IID_IUnknown) OrElse IsEqualGUID(riid, @IID_IFileDialogControlEvents) Then
		*ppvObject = Cast(Any Ptr, This)
		This->lpVtbl->AddRef(This)
		Return S_OK
	ElseIf IsEqualGUID(riid, @IID_IFileDialogEvents) Then
		*ppvObject = Cast(Any Ptr, @pEvents->lpVtblFileDialogEvents)
		FileDialogEvents_AddRef(Cast(IFileDialogEvents Ptr, @pEvents->lpVtblFileDialogEvents))
		Return S_OK
	End If
	
	*ppvObject = NULL
	Return E_NOINTERFACE
End Function

Private Function FileDialogControlEvents_AddRef(ByVal This As IFileDialogControlEvents Ptr) As ULong
	Dim pEvents As CustomFileDialogEvents Ptr = Cast(CustomFileDialogEvents Ptr, Cast(Byte Ptr, This) - SizeOf(IFileDialogEventsVtbl Ptr))
	pEvents->refCount += 1
	? "IFileDialogControlEvents::AddRef() -> " & pEvents->refCount
	Return pEvents->refCount
End Function

Private Function FileDialogControlEvents_Release(ByVal This As IFileDialogControlEvents Ptr) As ULong
	Dim pEvents As CustomFileDialogEvents Ptr = Cast(CustomFileDialogEvents Ptr, Cast(Byte Ptr, This) - SizeOf(IFileDialogEventsVtbl Ptr))
	pEvents->refCount -= 1
	Dim refCount As Long = pEvents->refCount
	
	? "IFileDialogControlEvents::Release() -> " & refCount
	
	If refCount = 0 Then
		? "Releasing IFileDialogControlEvents object"
		
		If pEvents->lpVtblFileDialogEvents Then
			Delete pEvents->lpVtblFileDialogEvents
			pEvents->lpVtblFileDialogEvents = NULL
		End If
		
		If pEvents->lpVtblFileDialogControlEvents Then
			Delete pEvents->lpVtblFileDialogControlEvents
			pEvents->lpVtblFileDialogControlEvents = NULL
		End If
		
		SAFE_RELEASE(pEvents->pFileDialog)
		Delete pEvents
	End If
	
	Return refCount
End Function

' ------------------------------------------------------------------------
'  Enhanced Event Handling Functions
' ------------------------------------------------------------------------

Private Function FileDialogEvents_OnFileOk(ByVal This As IFileDialogEvents Ptr, ByVal pfd As IFileDialog Ptr) As HRESULT
	? "=== OnFileOk ==="
	? "Event: User confirmed file selection"
	
	' Get current options
	Dim options As DWORD
	If SUCCEEDED(pfd->lpVtbl->GetOptions(pfd, @options)) Then
		? "Dialog Options: " & GetFileDialogOptionsText(options)
	End If
	
	' Get file name
	Dim psi As IShellItem Ptr = NULL
	If SUCCEEDED(pfd->lpVtbl->GetCurrentSelection(pfd, @psi)) AndAlso psi <> NULL Then
		Dim pwszName As WString Ptr = NULL
		If SUCCEEDED(psi->lpVtbl->GetDisplayName(psi, SIGDN_FILESYSPATH, @pwszName)) AndAlso pwszName <> NULL Then
			? "Current Selection: " & *pwszName
			CoTaskMemFree(pwszName)
		End If
		SAFE_RELEASE(psi)
	End If
	
	? "Return: S_OK (Allow operation to continue)"
	? "================="
	Return S_OK
End Function

Private Function FileDialogEvents_OnFolderChanging(ByVal This As IFileDialogEvents Ptr, ByVal pfd As IFileDialog Ptr, ByVal psiFolder As IShellItem Ptr) As HRESULT
	? "=== OnFolderChanging ==="
	? "Event: Folder is about to change"
	
	If psiFolder <> NULL Then
		Dim pwszName As WString Ptr = NULL
		If SUCCEEDED(psiFolder->lpVtbl->GetDisplayName(psiFolder, SIGDN_FILESYSPATH, @pwszName)) AndAlso pwszName <> NULL Then
			? "New Folder Path: " & *pwszName
			CoTaskMemFree(pwszName)
		End If
	Else
		? "Warning: psiFolder parameter is NULL"
	End If
	
	? "Return: S_OK (Allow folder change)"
	? "========================="
	Return S_OK
End Function

Private Function FileDialogEvents_OnFolderChange(ByVal This As IFileDialogEvents Ptr, ByVal pfd As IFileDialog Ptr) As HRESULT
	? "=== OnFolderChange ==="
	? "Event: Folder has changed"
	
	' Get current folder
	Dim psiFolder As IShellItem Ptr = NULL
	If SUCCEEDED(pfd->lpVtbl->GetFolder(pfd, @psiFolder)) AndAlso psiFolder <> NULL Then
		Dim pwszName As WString Ptr = NULL
		If SUCCEEDED(psiFolder->lpVtbl->GetDisplayName(psiFolder, SIGDN_FILESYSPATH, @pwszName)) AndAlso pwszName <> NULL Then
			? "Current Folder: " & *pwszName
			CoTaskMemFree(pwszName)
		End If
		SAFE_RELEASE(psiFolder)
	End If
	
	? "Return: S_OK"
	? "========================"
	Return S_OK
End Function

Private Function FileDialogEvents_OnSelectionChange(ByVal This As IFileDialogEvents Ptr, ByVal pfd As IFileDialog Ptr) As HRESULT
	? "=== OnSelectionChange ==="
	? "Event: File selection has changed"
	
	Dim psi As IShellItem Ptr = NULL
	If SUCCEEDED(pfd->lpVtbl->GetCurrentSelection(pfd, @psi)) AndAlso psi <> NULL Then
		Dim pwszName As WString Ptr = NULL
		If SUCCEEDED(psi->lpVtbl->GetDisplayName(psi, SIGDN_FILESYSPATH, @pwszName)) AndAlso pwszName <> NULL Then
			? "New Selected File: " & *pwszName
			CoTaskMemFree(pwszName)
		End If
		
		' Get file attributes
		Dim sfgao As SFGAOF
		If SUCCEEDED(psi->lpVtbl->GetAttributes(psi, SFGAO_FOLDER Or SFGAO_READONLY, @sfgao)) Then
			If (sfgao And SFGAO_FOLDER) Then
				? "Type: Folder"
			Else
				? "Type: File"
			End If
			
			If (sfgao And SFGAO_READONLY) Then
				? "Attributes: Read-only"
			End If
		End If
		
		SAFE_RELEASE(psi)
	End If
	
	? "Return: S_OK"
	? "========================="
	Return S_OK
End Function

Private Function FileDialogEvents_OnTypeChange(ByVal This As IFileDialogEvents Ptr, ByVal pfd As IFileDialog Ptr) As HRESULT
	? "=== OnTypeChange ==="
	? "Event: File type filter has changed"
	
	Dim uIndex As UINT
	If SUCCEEDED(pfd->lpVtbl->GetFileTypeIndex(pfd, @uIndex)) Then
		? "New File Type Index: " & uIndex
	End If
	
	? "Return: S_OK"
	? "======================="
	Return S_OK
End Function

' Handle file sharing violations
Private Function FileDialogEvents_OnShareViolation(ByVal This As IFileDialogEvents Ptr, ByVal pfd As IFileDialog Ptr, ByVal psi As IShellItem Ptr, ByVal pResponse As FDE_SHAREVIOLATION_RESPONSE Ptr) As HRESULT
	? "=== OnShareViolation ==="
	? "Event: File sharing violation detected"
	
	If psi <> NULL Then
		Dim pwszName As WString Ptr = NULL
		If SUCCEEDED(psi->lpVtbl->GetDisplayName(psi, SIGDN_FILESYSPATH, @pwszName)) AndAlso pwszName <> NULL Then
			? "Conflicting File: " & *pwszName
			CoTaskMemFree(pwszName)
		End If
	End If
	
	If pResponse <> NULL Then
		*pResponse = FDESVR_DEFAULT
		? "Response: Use default handling"
	End If
	
	? "Return: S_OK"
	? "========================"
	Return S_OK
End Function

' Handle file overwrite
Private Function FileDialogEvents_OnOverwrite(ByVal This As IFileDialogEvents Ptr, ByVal pfd As IFileDialog Ptr, ByVal psi As IShellItem Ptr, ByVal pResponse As FDE_OVERWRITE_RESPONSE Ptr) As HRESULT
	? "=== OnOverwrite ==="
	? "Event: File overwrite confirmation"
	
	If psi <> NULL Then
		Dim pwszName As WString Ptr = NULL
		If SUCCEEDED(psi->lpVtbl->GetDisplayName(psi, SIGDN_FILESYSPATH, @pwszName)) AndAlso pwszName <> NULL Then
			? "File to be overwritten: " & *pwszName
			CoTaskMemFree(pwszName)
		End If
	End If
	
	If pResponse <> NULL Then
		*pResponse = FDEOR_DEFAULT
		? "Response: Use default handling"
	End If
	
	? "Return: S_OK"
	? "========================"
	Return S_OK
End Function

' ------------------------------------------------------------------------
'  Control Events Implementation
' ------------------------------------------------------------------------

Private Function FileDialogControlEvents_OnItemSelected(ByVal This As IFileDialogControlEvents Ptr, ByVal pfdc As IFileDialogCustomize Ptr, ByVal dwIDCtl As DWORD, ByVal dwIDItem As DWORD) As HRESULT
	? "=== OnItemSelected ==="
	? "Event: Control item selected"
	? "Control ID: " & dwIDCtl
	? "Item ID: " & dwIDItem
	
	' Provide detailed information based on control ID
	Select Case dwIDCtl
	Case FILE_DIALOG_COMBO_NEWLINE
		? "Control: Newline selection"
		Select Case dwIDItem
		Case FILE_DIALOG_ITEM_WIN_CRLF
			? "Selected: Windows (CRLF)"
		Case FILE_DIALOG_ITEM_LINUX_LF
			? "Selected: Linux (LF)"
		Case FILE_DIALOG_ITEM_MAC_CR
			? "Selected: Mac OS (CR)"
		End Select
		
	Case FILE_DIALOG_COMBO_ENCODING
		? "Control: Encoding selection"
		Select Case dwIDItem
		Case FILE_DIALOG_ITEM_ASCII
			? "Selected: ASCII"
		Case FILE_DIALOG_ITEM_UTF8
			? "Selected: UTF-8"
		Case FILE_DIALOG_ITEM_UNICODE_LE
			? "Selected: Unicode (UTF-16 LE)"
		Case FILE_DIALOG_ITEM_UNICODE_BE
			? "Selected: Unicode Big Endian (UTF-16 BE)"
		End Select
	End Select
	
	? "Return: S_OK"
	? "======================"
	Return S_OK
End Function

Private Function FileDialogControlEvents_OnButtonClicked(ByVal This As IFileDialogControlEvents Ptr, ByVal pfdc As IFileDialogCustomize Ptr, ByVal dwIDCtl As DWORD) As HRESULT
	? "=== OnButtonClicked ==="
	? "Event: Button clicked"
	? "Button ID: " & dwIDCtl
	? "Return: S_OK"
	? "======================"
	Return S_OK
End Function

Private Function FileDialogControlEvents_OnCheckButtonToggled(ByVal This As IFileDialogControlEvents Ptr, ByVal pfdc As IFileDialogCustomize Ptr, ByVal dwIDCtl As DWORD, ByVal bChecked As WINBOOL) As HRESULT
	? "=== OnCheckButtonToggled ==="
	? "Event: Check button toggled"
	? "Control ID: " & dwIDCtl
	? "New State: " & IIf(bChecked, "Checked", "Unchecked")
	? "Return: S_OK"
	? "=========================="
	Return S_OK
End Function

Private Function FileDialogControlEvents_OnControlActivating(ByVal This As IFileDialogControlEvents Ptr, ByVal pfdc As IFileDialogCustomize Ptr, ByVal dwIDCtl As DWORD) As HRESULT
	? "=== OnControlActivating ==="
	? "Event: Control activating"
	? "Control ID: " & dwIDCtl
	? "Return: S_OK"
	? "========================="
	Return S_OK
End Function

' ------------------------------------------------------------------------
'  Create Event Receiver
' ------------------------------------------------------------------------

Private Function CreateFileDialogEvents(ByVal pFileDialog As IFileDialog Ptr) As IFileDialogEvents Ptr
	Dim pEvents As CustomFileDialogEvents Ptr = New CustomFileDialogEvents
	
	If pEvents = NULL Then
		? "Error: Cannot allocate event receiver memory"
		Return NULL
	End If
	
	' Initialize structure
	ZeroMemory(pEvents, SizeOf(CustomFileDialogEvents))
	
	' Create and setup file dialog event vtable
	pEvents->lpVtblFileDialogEvents = New IFileDialogEventsVtbl
	If pEvents->lpVtblFileDialogEvents = NULL Then
		? "Error: Cannot allocate file dialog event vtable"
		Delete pEvents
		Return NULL
	End If
	
	' Create and setup control event vtable
	pEvents->lpVtblFileDialogControlEvents = New IFileDialogControlEventsVtbl
	If pEvents->lpVtblFileDialogControlEvents = NULL Then
		? "Error: Cannot allocate control event vtable"
		Delete pEvents->lpVtblFileDialogEvents
		Delete pEvents
		Return NULL
	End If
	
	' Setup file dialog event vtable
	With *pEvents->lpVtblFileDialogEvents
		.QueryInterface = @FileDialogEvents_QueryInterface
		.AddRef = @FileDialogEvents_AddRef
		.Release = @FileDialogEvents_Release
		.OnFileOk = @FileDialogEvents_OnFileOk
		.OnFolderChanging = @FileDialogEvents_OnFolderChanging
		.OnFolderChange = @FileDialogEvents_OnFolderChange
		.OnSelectionChange = @FileDialogEvents_OnSelectionChange
		.OnShareViolation = @FileDialogEvents_OnShareViolation
		.OnTypeChange = @FileDialogEvents_OnTypeChange
		.OnOverwrite = @FileDialogEvents_OnOverwrite
	End With
	
	' Setup control event vtable
	With *pEvents->lpVtblFileDialogControlEvents
		.QueryInterface = @FileDialogControlEvents_QueryInterface
		.AddRef = @FileDialogControlEvents_AddRef
		.Release = @FileDialogControlEvents_Release
		.OnItemSelected = @FileDialogControlEvents_OnItemSelected
		.OnButtonClicked = @FileDialogControlEvents_OnButtonClicked
		.OnCheckButtonToggled = @FileDialogControlEvents_OnCheckButtonToggled
		.OnControlActivating = @FileDialogControlEvents_OnControlActivating
	End With
	
	pEvents->refCount = 1
	pEvents->isInitialized = True
	
	' Save dialog reference
	If pFileDialog <> NULL Then
		pFileDialog->lpVtbl->AddRef(pFileDialog)
		pEvents->pFileDialog = pFileDialog
	End If
	
	? "Successfully created dialog event receiver"
	? "Event receiver address: " & Hex(@pEvents->lpVtblFileDialogEvents)
	
	Return Cast(IFileDialogEvents Ptr, @pEvents->lpVtblFileDialogEvents)
End Function

' ------------------------------------------------------------------------
'  Optimized File Open Dialog Function
' ------------------------------------------------------------------------

Private Function ShowOpenFileDialog(ByVal hwndOwner As HWND, ByRef DefaultPath As Const WString = "") As IShellItemArray Ptr
	Dim hr As HRESULT
	Dim pFileOpenDialog As IFileOpenDialog Ptr = NULL
	Dim pFileDialogCustomize As IFileDialogCustomize Ptr = NULL
	Dim pFileDialogEvents As IFileDialogEvents Ptr = NULL
	Dim dwCookie As DWORD = 0
	Dim coInitialized As BOOL = False
	Static pItemArray As IShellItemArray Ptr = NULL
	
	? "Initializing file open dialog..."
	
	' Check if COM is initialized
	hr = CoInitialize(NULL)
	If SUCCEEDED(hr) Then
		coInitialized = True
		? "COM initialized"
	ElseIf hr = RPC_E_CHANGED_MODE Then
		? "COM already initialized with different mode"
	Else
		? "Error: COM initialization failed: " & Hex(hr)
		Return NULL
	End If
	
	' Create file open dialog instance
	hr = CoCreateInstance(@CLSID_FileOpenDialog, NULL, CLSCTX_INPROC_SERVER, @IID_IFileOpenDialog, @pFileOpenDialog)
	If FAILED(hr) Then
		? "Error: Failed to create file dialog: " & Hex(hr)
		If coInitialized Then CoUninitialize()
		Return NULL
	End If
	
	? "File dialog instance created successfully"
	
	' Get customization interface
	hr = pFileOpenDialog->lpVtbl->QueryInterface(pFileOpenDialog, @IID_IFileDialogCustomize, @pFileDialogCustomize)
	If FAILED(hr) Then
		? "Error: Failed to get customization interface: " & Hex(hr)
		SAFE_RELEASE(pFileOpenDialog)
		If coInitialized Then CoUninitialize()
		Return NULL
	End If
	
	? "Customization interface obtained"
	
	' Set file type filters
	Dim rgFileTypes(0 To 2) As COMDLG_FILTERSPEC
	rgFileTypes(0).pszName = @WStr("FB code files")
	rgFileTypes(0).pszSpec = @WStr("*.bas;*.inc;*.bi")
	rgFileTypes(1).pszName = @WStr("Executable files")
	rgFileTypes(1).pszSpec = @WStr("*.exe;*.dll")
	rgFileTypes(2).pszName = @WStr("All files")
	rgFileTypes(2).pszSpec = @WStr("*.*")
	
	hr = pFileOpenDialog->lpVtbl->SetFileTypes(pFileOpenDialog, 3, @rgFileTypes(0))
	If FAILED(hr) Then
		? "Warning: Failed to set file types: " & Hex(hr)
	Else
		? "File type filters set successfully"
	End If
	
	pFileOpenDialog->lpVtbl->SetFileTypeIndex(pFileOpenDialog, 1)
	
	' Set dialog options
	hr = pFileOpenDialog->lpVtbl->SetTitle(pFileOpenDialog, "Enhanced Multi-Selection File Dialog")
	If FAILED(hr) Then
		? "Warning: Failed to set title: " & Hex(hr)
	End If
	
	Dim options As DWORD
	hr = pFileOpenDialog->lpVtbl->GetOptions(pFileOpenDialog, @options)
	If SUCCEEDED(hr) Then
		options = options Or FOS_ALLOWMULTISELECT Or FOS_PATHMUSTEXIST Or FOS_FILEMUSTEXIST Or FOS_FORCEFILESYSTEM
		hr = pFileOpenDialog->lpVtbl->SetOptions(pFileOpenDialog, options)
		If SUCCEEDED(hr) Then
			? "Dialog options set successfully: " & GetFileDialogOptionsText(options)
		Else
			? "Warning: Failed to set options: " & Hex(hr)
		End If
	Else
		? "Warning: Failed to get options: " & Hex(hr)
	End If
	
	' Add custom controls
	? "Adding custom controls..."
	
	' Newline selection group
	pFileDialogCustomize->lpVtbl->StartVisualGroup(pFileDialogCustomize, FILE_DIALOG_GROUP_NEWLINE, "Newline Format:")
	pFileDialogCustomize->lpVtbl->AddComboBox(pFileDialogCustomize, FILE_DIALOG_COMBO_NEWLINE)
	pFileDialogCustomize->lpVtbl->AddControlItem(pFileDialogCustomize, FILE_DIALOG_COMBO_NEWLINE, FILE_DIALOG_ITEM_WIN_CRLF, "Windows (CRLF)")
	pFileDialogCustomize->lpVtbl->AddControlItem(pFileDialogCustomize, FILE_DIALOG_COMBO_NEWLINE, FILE_DIALOG_ITEM_LINUX_LF, "Linux (LF)")
	pFileDialogCustomize->lpVtbl->AddControlItem(pFileDialogCustomize, FILE_DIALOG_COMBO_NEWLINE, FILE_DIALOG_ITEM_MAC_CR, "Mac OS (CR)")
	pFileDialogCustomize->lpVtbl->SetSelectedControlItem(pFileDialogCustomize, FILE_DIALOG_COMBO_NEWLINE, FILE_DIALOG_ITEM_WIN_CRLF)
	pFileDialogCustomize->lpVtbl->MakeProminent(pFileDialogCustomize, FILE_DIALOG_GROUP_NEWLINE)
	pFileDialogCustomize->lpVtbl->EndVisualGroup(pFileDialogCustomize)
	? "Newline selection controls added"
	
	' Encoding selection group
	pFileDialogCustomize->lpVtbl->StartVisualGroup(pFileDialogCustomize, FILE_DIALOG_GROUP_ENCODING, "Text Encoding:")
	pFileDialogCustomize->lpVtbl->AddComboBox(pFileDialogCustomize, FILE_DIALOG_COMBO_ENCODING)
	pFileDialogCustomize->lpVtbl->AddControlItem(pFileDialogCustomize, FILE_DIALOG_COMBO_ENCODING, FILE_DIALOG_ITEM_ASCII, "ASCII")
	pFileDialogCustomize->lpVtbl->AddControlItem(pFileDialogCustomize, FILE_DIALOG_COMBO_ENCODING, FILE_DIALOG_ITEM_UTF8, "UTF-8")
	pFileDialogCustomize->lpVtbl->AddControlItem(pFileDialogCustomize, FILE_DIALOG_COMBO_ENCODING, FILE_DIALOG_ITEM_UNICODE_LE, "Unicode (UTF-16 LE)")
	pFileDialogCustomize->lpVtbl->AddControlItem(pFileDialogCustomize, FILE_DIALOG_COMBO_ENCODING, FILE_DIALOG_ITEM_UNICODE_BE, "Unicode Big Endian")
	pFileDialogCustomize->lpVtbl->SetSelectedControlItem(pFileDialogCustomize, FILE_DIALOG_COMBO_ENCODING, FILE_DIALOG_ITEM_ASCII)
	pFileDialogCustomize->lpVtbl->MakeProminent(pFileDialogCustomize, FILE_DIALOG_GROUP_ENCODING)
	pFileDialogCustomize->lpVtbl->EndVisualGroup(pFileDialogCustomize)
	? "Encoding selection controls added"
	
	' Set initial folder
	If DefaultPath <> "" Then
		Dim pFolder As IShellItem Ptr = NULL
		hr = SHCreateItemFromParsingName(DefaultPath, NULL, @IID_IShellItem, @pFolder)
		If SUCCEEDED(hr) AndAlso pFolder <> NULL Then
			hr = pFileOpenDialog->lpVtbl->SetFolder(pFileOpenDialog, pFolder)
			If SUCCEEDED(hr) Then
				? "Initial folder set successfully: " & DefaultPath
			Else
				? "Warning: Failed to set initial folder: " & Hex(hr)
			End If
			SAFE_RELEASE(pFolder)
		Else
			? "Warning: Failed to create folder item: " & Hex(hr)
		End If
	End If
	
	' Create and register event receiver
	pFileDialogEvents = CreateFileDialogEvents(Cast(Any Ptr, pFileOpenDialog))
	If pFileDialogEvents <> NULL Then
		hr = pFileOpenDialog->lpVtbl->Advise(pFileOpenDialog, pFileDialogEvents, @dwCookie)
		If SUCCEEDED(hr) Then
			? "Event receiver registered successfully"
			? "Cookie: " & dwCookie
		Else
			? "Warning: Failed to register event receiver: " & Hex(hr)
			dwCookie = 0
		End If
	Else
		? "Warning: Failed to create event receiver"
	End If
	
	? "Showing file dialog..."
	
	' Show dialog
	hr = pFileOpenDialog->lpVtbl->Show(pFileOpenDialog, hwndOwner)
	If SUCCEEDED(hr) Then
		? "User confirmed selection"
		
		' Get custom control selections
		Dim selectedItem As DWORD
		If SUCCEEDED(pFileDialogCustomize->lpVtbl->GetSelectedControlItem(pFileDialogCustomize, FILE_DIALOG_COMBO_NEWLINE, @selectedItem)) Then
			? "Selected newline option: " & selectedItem
		End If
		
		If SUCCEEDED(pFileDialogCustomize->lpVtbl->GetSelectedControlItem(pFileDialogCustomize, FILE_DIALOG_COMBO_ENCODING, @selectedItem)) Then
			? "Selected encoding option: " & selectedItem
		End If
		
		' Get selection results
		hr = pFileOpenDialog->lpVtbl->GetResults(pFileOpenDialog, @pItemArray)
		If SUCCEEDED(hr) Then
			? "Successfully obtained file selection results"
			Function = pItemArray
		Else
			? "Error: Failed to get results: " & Hex(hr)
		End If
	ElseIf hr = HRESULT_FROM_WIN32(ERROR_CANCELLED) Then
		? "User canceled the dialog"
	Else
		? "Error: Dialog show failed: " & Hex(hr)
	End If
	
	' Cleanup event receiver
	If (pFileDialogEvents <> NULL) And (dwCookie <> 0) Then
		pFileOpenDialog->lpVtbl->Unadvise(pFileOpenDialog, dwCookie)
		? "Event receiver unregistered"
	End If
	
	' Release event receiver
	SAFE_RELEASE(pFileDialogEvents)
	? "Event receiver released"
	
	' Release resources
	SAFE_RELEASE(pFileDialogCustomize)
	SAFE_RELEASE(pFileOpenDialog)
	
	If coInitialized Then
		CoUninitialize()
		? "COM uninitialized"
	End If
	
	? "File dialog operation completed"
End Function

' ------------------------------------------------------------------------
'  Show Selected Files
' ------------------------------------------------------------------------

Private Sub DisplaySelectedFiles(ByVal hwndOwner As HWND)
	? "Starting file selection process..."
	
	Dim pItems As IShellItemArray Ptr = ShowOpenFileDialog(hwndOwner)
	If pItems = NULL Then
		? "No files selected"
		Sleep()
		Exit Sub
	End If
	
	Dim dwItemCount As DWORD = 0
	Dim hr As HRESULT = pItems->lpVtbl->GetCount(pItems, @dwItemCount)
	
	If SUCCEEDED(hr) Then
		? "Selected " & dwItemCount & " files:"
		
		For idx As DWORD = 0 To dwItemCount - 1
			Dim pItem As IShellItem Ptr = NULL
			hr = pItems->lpVtbl->GetItemAt(pItems, idx, @pItem)
			
			If SUCCEEDED(hr) AndAlso pItem <> NULL Then
				Dim pwszName As WString Ptr = NULL
				hr = pItem->lpVtbl->GetDisplayName(pItem, SIGDN_FILESYSPATH, @pwszName)
				
				If SUCCEEDED(hr) AndAlso pwszName <> NULL Then
					? "File " & (idx + 1) & ": " & *pwszName
					CoTaskMemFree(pwszName)
				Else
					? "File " & (idx + 1) & ": [Cannot get file name]"
				End If
				
				SAFE_RELEASE(pItem)
			Else
				? "File " & (idx + 1) & ": [Cannot get file item]"
			End If
		Next
	Else
		? "Error: Cannot get file count: " & Hex(hr) & ", " & dwItemCount
	End If
	
	SAFE_RELEASE(pItems)
	? "File list display completed"
End Sub

' Version with initial path
Private Sub DisplaySelectedFilesWithPath(ByVal hwndOwner As HWND, ByRef initialPath As Const WString)
	Dim pItems As IShellItemArray Ptr = ShowOpenFileDialog(hwndOwner, initialPath)
	SAFE_RELEASE(pItems)
End Sub

' ------------------------------------------------------------------------
'  Test Function
' ------------------------------------------------------------------------

Private Sub RunFileDialogTest()
	? "=== FreeBASIC IFileDialog Test Started ==="
	CoInitialize(NULL)
	
	' Test 1: Basic file selection
	? "Test 1: Basic file selection"
	DisplaySelectedFiles(NULL)
	DisplaySelectedFilesWithPath(NULL, ExePath)
	
	CoUninitialize()
	Sleep()
	? "=== FreeBASIC IFileDialog Test Completed ==="
End Sub

' ------------------------------------------------------------------------
'  Main Program Entry
' ------------------------------------------------------------------------
#ifndef __FB_MAIN__
	RunFileDialogTest()
#endif