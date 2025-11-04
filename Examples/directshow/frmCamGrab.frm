' Copyright (c) 2025 CM.Wang
' Freeware. Use at your own risk.

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
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/TimerComponent.bi"
	#include once "mff/Picture.bi"
	
	#include once "CamGrab.bi"
	
	Using My.Sys.Forms
	
	Type Form1Type Extends Form
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Sub ComboBoxEdit1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Constructor
		
		Dim As Panel Panel1, Panel2
		Dim As ComboBoxEdit ComboBoxEdit1
		Dim As CommandButton CommandButton1
	End Type
	
	Constructor Form1Type
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = My.Sys.Language
			End With
		#endif
		' Form1
		With This
			.Name = "Form1"
			.Text = "Camera Grab"
			.Designer = @This
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnDestroy = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Destroy)
			.Caption = "Camera Grab"
			.SetBounds 0, 0, 410, 300
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
			.SetBounds 0, 40, 394, 221
			.Designer = @This
			.Parent = @This
		End With
		' ComboBoxEdit1
		With ComboBoxEdit1
			.Name = "ComboBoxEdit1"
			.Text = "ComboBoxEdit1"
			.TabIndex = 2
			.SetBounds 10, 10, 190, 21
			.Designer = @This
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @ComboBoxEdit1_Selected)
			.Parent = @Panel1
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "Capture"
			.TabIndex = 3
			.Caption = "Capture"
			.SetBounds 270, 10, 100, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton1_Click)
			.Parent = @Panel1
		End With
	End Constructor
	
	Dim Shared Form1 As Form1Type
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		Form1.MainForm = True
		Form1.Show
		App.Run
	#endif
'#End Region

Private Function EnumDev(ComBox As ComboBoxEdit Ptr, ByVal IidDev As Const IID Const Ptr, ByVal SelIdx As Integer = -1) As Integer
	Dim hr As HRESULT
	Dim pCreateDevEnum As ICreateDevEnum Ptr
	hr = CoCreateInstance(@CLSID_SystemDeviceEnum, NULL, CLSCTX_INPROC, @IID_ICreateDevEnum, @pCreateDevEnum)
	If hr <> NOERROR Then Return -1
	
	Dim pEnumMoniker As IEnumMoniker Ptr
	Dim pMoniker As IMoniker Ptr
	
	hr = pCreateDevEnum->lpVtbl->CreateClassEnumerator(pCreateDevEnum, IidDev, @pEnumMoniker, 0)
	If hr <> S_OK Then Return -2
	
	Dim pBaseFilter As IBaseFilter Ptr
	Dim pPropertyBag As IPropertyBag Ptr
	Dim cFetched As ULong
	Dim pFName As VARIANT
	Dim pClsidStr As VARIANT
	
	Dim i As Integer = 0
	Dim idx As Integer = ComBox->ItemIndex
	ComBox->Clear
	
	Do
		hr = pEnumMoniker->lpVtbl->Next(pEnumMoniker, 1, @pMoniker, @cFetched)
		If hr <> S_OK Then Exit Do
		hr = pMoniker->lpVtbl->BindToObject(pMoniker, 0, 0, @IID_IBaseFilter, @pBaseFilter)
		
		Dim dpname As WString Ptr
		hr = pMoniker->lpVtbl->GetDisplayName(pMoniker, 0, 0, @dpname)
		
		If hr <> S_OK Then Exit Do
		hr = pMoniker->lpVtbl->BindToStorage(pMoniker, 0, 0, @IID_IPropertyBag, @pPropertyBag)
		If hr <> S_OK Then Exit Do
		hr = pPropertyBag->lpVtbl->Read(pPropertyBag, "FriendlyName", @pFName, 0)
		If hr <> S_OK Then Exit Do
		hr = pPropertyBag->lpVtbl->Read(pPropertyBag, "CLSID", @pClsidStr, 0)
		If hr <> S_OK Then Exit Do
		Dim pClsid As CLSID Ptr = New CLSID
		hr = CLSIDFromString(pClsidStr.bstrVal, pClsid)
		If hr <> S_OK Then Exit Do
		ComBox->AddItem(i & " - " & *Cast(WString Ptr, pFName.bstrVal))
		ComBox->ItemData(i) = pMoniker 'pBaseFilter
		
		? "GetDisplayName: " & *dpname
		? "pMoniker      : " & pMoniker
		? "pBaseFilter   : " & pBaseFilter
		? "FriendlyName  : " & *Cast(WString Ptr, pFName.bstrVal)
		? "CLSID         : " & *Cast(WString Ptr, pClsidStr.bstrVal)
		
		'ComBox->ItemData(i) = pClsid
		SysFreeString(pFName.bstrVal)
		SysFreeString(pClsidStr.bstrVal)
		CoTaskMemFree(dpname)
		pPropertyBag->lpVtbl->Release(pPropertyBag)
		'pBaseFilter->lpVtbl->Release(pBaseFilter)
		'pMoniker->lpVtbl->Release(pMoniker)
		i += 1
	Loop
	pEnumMoniker->lpVtbl->Release(pEnumMoniker)
	pCreateDevEnum->lpVtbl->Release(pCreateDevEnum)
	Select Case SelIdx
	Case -2
		ComBox->ItemIndex = idx
	Case Else
		ComBox->ItemIndex = SelIdx
	End Select
	Return i
End Function

Private Sub Form1Type.Form_Create(ByRef Sender As Control)
	' 初始化 COM
	Dim hr As HRESULT = CoInitialize(NULL)
	If FAILED(hr) Then
		MessageBox(NULL, "CoInitialize failed!", "Error", MB_ICONERROR)
		End -1
	End If
	
	'enumerate all video capture devices
	EnumDev(@ComboBoxEdit1, @CLSID_VideoInputDeviceCategory, 0)
	
	ComboBoxEdit1_Selected(ComboBoxEdit1, 0)
End Sub

Private Sub Form1Type.Form_Destroy(ByRef Sender As Control)
	CleanupDirectShow()
	CoUninitialize()
End Sub

Private Sub Form1Type.CommandButton1_Click(ByRef Sender As Control)
	g_captureRequested = 1
End Sub

Private Sub Form1Type.ComboBoxEdit1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	CleanupDirectShow()
	
	PreviewHandle(Panel2.Handle)
	
	InitializeDirectShow(ComboBoxEdit1.ItemData(ComboBoxEdit1.ItemIndex))
End Sub
