'AMCap摄像头捕捉
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "frmamcap.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/Panel.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/TimerComponent.bi"
	#include once "mff/Dialogs.bi"
	#include once "mff/StatusBar.bi"
	
	#include once "win/mmreg.bi"
	#include once "win/mmsystem.bi"
	#include once "crt/fcntl.bi"
	#include once "win/dbt.bi"
	#include once "win/msacm.bi"
	#include once "win/mmsystem.bi"
	#include once "win/d3d9types.bi"
	#include once "win/dsound.bi"
	#include once "win/dshow.bi"
	#include once "win/winbase.bi"
	#include once "win/winnt.bi"
	#include once "win/windowsx.bi"
	#include once "vbcompat.bi"
	
	#include once "amcap.bi"
	
	Using My.Sys.Forms
	
	Type frmamcapType Extends Form
		Declare Sub ControlEnable(e As Boolean)
		
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub ComboBoxEdit_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub CheckBox_Click(ByRef Sender As CheckBox)
		Declare Sub CommandButton_Click(ByRef Sender As Control)
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Sub TimerComponent_Timer(ByRef Sender As TimerComponent)
		Declare Constructor
		
		Dim As ComboBoxEdit ComboBoxEdit1, ComboBoxEdit2, ComboBoxEdit3
		Dim As Panel Panel1, Panel2
		Dim As CheckBox CheckBox1, CheckBox2
		Dim As TextBox TextBox1, TextBox2, TextBox3, TextBox4
		Dim As CommandButton CommandButton1, CommandButton2, CommandButton3, CommandButton4, CommandButton5, CommandButton6, CommandButton7, CommandButton8, CommandButton9
		Dim As TimerComponent TimerComponent1
		Dim As SaveFileDialog SaveFileDialog1
		Dim As StatusBar StatusBar1
		Dim As StatusPanel StatusPanel1
	End Type
	
	Constructor frmamcapType
		'Form1
		With This
			.Name = "frmamcap"
			.Text = "Audio/Video Capture sample For DirectShow"
			.Designer = @This
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Form_Resize)
			.Caption = "Audio/Video Capture sample For DirectShow"
			.StartPosition = FormStartPosition.CenterScreen
			.OnDestroy = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Destroy)
			.SetBounds 0, 0, 630, 490
		End With
		'Panel1
		With Panel1
			.Name = "Panel1"
			.Text = "Panel1"
			.TabIndex = 0
			.Align = DockStyle.alTop
			.SetBounds 0, 0, 474, 100
			.Designer = @This
			.Parent = @This
		End With
		'Panel2
		With Panel2
			.Name = "Panel2"
			.Text = "Panel2"
			.TabIndex = 1
			.Align = DockStyle.alClient
			.BackColor = 8421504
			.SetBounds 65130, 100, 614, 329
			.Designer = @This
			.Parent = @This
		End With
		'ComboBoxEdit1
		With ComboBoxEdit1
			.Name = "ComboBoxEdit1"
			.Text = "ComboBoxEdit1"
			.TabIndex = 2
			.Style = ComboBoxEditStyle.cbDropDown
			.SetBounds 10, 10, 200, 21
			.Designer = @This
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @ComboBoxEdit_Selected)
			.Parent = @Panel1
		End With
		'ComboBoxEdit2
		With ComboBoxEdit2
			.Name = "ComboBoxEdit2"
			.Text = "ComboBoxEdit2"
			.TabIndex = 3
			.Style = ComboBoxEditStyle.cbDropDown
			.SetBounds 10, 40, 200, 21
			.Designer = @This
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @ComboBoxEdit_Selected)
			.Parent = @Panel1
		End With
		'TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = "TextBox1"
			.TabIndex = 4
			.SetBounds 10, 70, 200, 20
			.Designer = @This
			.Parent = @Panel1
			.Text = CurDir & "\rec.avi"
		End With
		'TextBox2
		With TextBox2
			.Name = "TextBox2"
			.Text = "0"
			.TabIndex = 5
			.Hint = "Frame rate"
			.Visible = True
			.Enabled = False
			.SetBounds 220, 10, 90, 20
			.Designer = @This
			.Parent = @Panel1
		End With
		'TextBox3
		With TextBox3
			.Name = "TextBox3"
			.Text = "0"
			.TabIndex = 6
			.Hint = "Time limite"
			.Visible = True
			.Enabled = False
			.SetBounds 220, 30, 90, 20
			.Designer = @This
			.Parent = @Panel1
		End With
		'TextBox4
		With TextBox4
			.Name = "TextBox4"
			.Text = "0"
			.TabIndex = 7
			.Hint = "File Space"
			.Visible = True
			.Enabled = False
			.SetBounds 220, 50, 90, 20
			.Designer = @This
			.Parent = @Panel1
		End With
		'CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "Select file..."
			.TabIndex = 8
			.Caption = "Select file..."
			.SetBounds 220, 70, 90, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel1
		End With
		'CheckBox1
		With CheckBox1
			.Name = "CheckBox1"
			.Text = "Preview"
			.TabIndex = 9
			.Caption = "Preview"
			.Enabled = True
			.SetBounds 320, 10, 90, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CheckBox_Click)
			.Parent = @Panel1
		End With
		'CheckBox2
		With CheckBox2
			.Name = "CheckBox2"
			.Text = "Capture Audio"
			.TabIndex = 10
			.Caption = "Capture Audio"
			.Enabled = True
			.Checked = True
			.SetBounds 320, 30, 90, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CheckBox_Click)
			.Parent = @Panel1
		End With
		'ComboBoxEdit3
		With ComboBoxEdit3
			.Name = "ComboBoxEdit3"
			.Text = "ComboBoxEdit3"
			.TabIndex = 11
			.Hint = "Master Stream"
			.Enabled = True
			.SetBounds 320, 50, 90, 21
			.Designer = @This
			.Parent = @Panel1
			.AddItem "None"
			.AddItem "Audio"
			.AddItem "Video"
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @ComboBoxEdit_Selected)
			.ItemIndex = 0
		End With
		'CommandButton2
		With CommandButton2
			.Name = "CommandButton2"
			.Text = "Audio format..."
			.TabIndex = 12
			.Caption = "Audio format..."
			.Enabled = False
			.SetBounds 420, 10, 90, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel1
		End With
		'CommandButton3
		With CommandButton3
			.Name = "CommandButton3"
			.Text = "Audio filter..."
			.TabIndex = 13
			.Caption = "Audio filter..."
			.Enabled = False
			.SetBounds 420, 30, 90, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel1
		End With
		'CommandButton4
		With CommandButton4
			.Name = "CommandButton4"
			.Text = "Video filter..."
			.TabIndex = 14
			.Caption = "Video filter..."
			.Enabled = False
			.SetBounds 420, 50, 90, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel1
		End With
		'CommandButton5
		With CommandButton5
			.Name = "CommandButton5"
			.Text = "Video pin..."
			.TabIndex = 15
			.Caption = "Video pin..."
			.Enabled = False
			.SetBounds 420, 70, 90, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel1
		End With
		'CommandButton6
		With CommandButton6
			.Name = "CommandButton6"
			.Text = "1/4"
			.TabIndex = 16
			.Caption = "1/4"
			.Enabled = False
			.SetBounds 520, 10, 90, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel1
		End With
		'CommandButton7
		With CommandButton7
			.Name = "CommandButton7"
			.Text = "1/2"
			.TabIndex = 17
			.Caption = "1/2"
			.Enabled = False
			.SetBounds 520, 30, 90, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel1
		End With
		'CommandButton8
		With CommandButton8
			.Name = "CommandButton8"
			.Text = "1/1"
			.TabIndex = 18
			.ControlIndex = 16
			.Caption = "1/1"
			.Enabled = False
			.SetBounds 520, 50, 90, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel1
		End With
		'CommandButton9
		With CommandButton9
			.Name = "CommandButton9"
			.Text = "Capture"
			.TabIndex = 19
			.Caption = "Capture"
			.SetBounds 520, 70, 90, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel1
		End With
		'TimerComponent1
		With TimerComponent1
			.Name = "TimerComponent1"
			.Interval = 100
			.SetBounds 390, 10, 16, 16
			.Designer = @This
			.OnTimer = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent), @TimerComponent_Timer)
			.Parent = @Panel1
		End With
		' SaveFileDialog1
		With SaveFileDialog1
			.Name = "SaveFileDialog1"
			.Filter = "*.avi|*.avi"
			.SetBounds 370, 10, 16, 16
			.Designer = @This
			.Parent = @Panel1
		End With
		' StatusBar1
		With StatusBar1
			.Name = "StatusBar1"
			.Text = "StatusBar1"
			.Align = DockStyle.alBottom
			.SetBounds 0, 429, 614, 22
			.Designer = @This
			.Parent = @This
		End With
		' StatusPanel1
		With StatusPanel1
			.Name = "StatusPanel1"
			.Designer = @This
			.Parent = @StatusBar1
		End With
	End Constructor
	
	Dim Shared frmamcap As frmamcapType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmamcap.MainForm = True
		frmamcap.Show
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
		pMoniker->lpVtbl->GetDisplayName(pMoniker, 0, 0, @dpname)
		
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
		ComBox->ItemData(i) = pBaseFilter
		
		Debug.Print "GetDisplayName: " & *dpname
		Debug.Print "pMoniker      : " & pMoniker
		Debug.Print "pBaseFilter   : " & pBaseFilter
		Debug.Print "FriendlyName  : " & *Cast(WString Ptr, pFName.bstrVal)
		Debug.Print "CLSID         : " & *Cast(WString Ptr, pClsidStr.bstrVal)
		
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

Private Sub frmamcapType.ControlEnable(e As Boolean)
	ComboBoxEdit1.Enabled = e
	ComboBoxEdit2.Enabled = e
	'ComboBoxEdit3.Enabled = e
	TextBox1.Enabled = e
	'TextBox2.Enabled = e
	'TextBox3.Enabled = e
	'TextBox4.Enabled = e
	'CheckBox1.Enabled = e
	'CheckBox2.Enabled = e
	CommandButton1.Enabled = e
	CommandButton2.Enabled = e
	CommandButton3.Enabled = e
	CommandButton4.Enabled = e
	CommandButton5.Enabled = e
	
	TimerComponent1.Enabled = IIf(e , False, True)
	
	StatusPanel1.Caption = ""
End Sub

Private Sub frmamcapType.Form_Create(ByRef Sender As Control)
	Debug.Clear
	CoInitialize(NULL)
	
	'enumerate all video capture devices
	EnumDev(@ComboBoxEdit1, @CLSID_VideoInputDeviceCategory)
	'enumerate all audio capture devices
	EnumDev(@ComboBoxEdit2, @CLSID_AudioInputDeviceCategory)
	hPreviewhWnd = Panel2.Handle
End Sub

Private Sub frmamcapType.Form_Destroy(ByRef Sender As Control)
	AVStop()
	Terminate()
	CoUninitialize()
End Sub

Private Sub frmamcapType.ComboBoxEdit_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	Select Case Sender.Name
	Case "ComboBoxEdit1"
		pVCap = ComboBoxEdit1.ItemData(ComboBoxEdit1.ItemIndex)
		CheckBox_Click CheckBox1
	Case "ComboBoxEdit2"
		If CheckBox2.Checked Then
			pACap = ComboBoxEdit2.ItemData(ComboBoxEdit2.ItemIndex)
			CheckBox_Click CheckBox1
		Else
			SAFE_RELEASE(pASC)
			pACap = NULL
		End If
	Case "ComboBoxEdit3"
		mStream = ComboBoxEdit3.ItemIndex - 1
	End Select
End Sub

Private Sub frmamcapType.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	StatusPanel1.Width = NewWidth
	PreviewResize
End Sub

Private Sub frmamcapType.CheckBox_Click(ByRef Sender As CheckBox)
	Select Case Sender.Name
	Case "CheckBox1"
		Terminate()
		If CheckBox2.Checked = False Then
		End If
		Initial(Sender.Checked, False)
		CommandButton2.Enabled = IIf(pASC, True, False)
		CommandButton3.Enabled = IIf(pACap, True, False)
		CommandButton4.Enabled = IIf(pVCap, True, False)
		CommandButton5.Enabled = IIf(pVSC, True, False)
		If Sender.Checked Then AVRun
	Case "CheckBox2"
		ComboBoxEdit2.Enabled = Sender.Checked
		ComboBoxEdit3.Enabled = ComboBoxEdit2.Enabled 
		ComboBoxEdit_Selected ComboBoxEdit2, ComboBoxEdit2.ItemIndex
		CheckBox_Click CheckBox1
	End Select
End Sub

Private Sub frmamcapType.CommandButton_Click(ByRef Sender As Control)
	Dim As HRESULT hr
	Select Case Sender.Text
	Case "Audio format..."
		DialogAudioFormat(This.Handle)
	Case "Audio filter..."
		DialogAudioFilter(This.Handle)
	Case "Video filter..."
		DialogVideoFilter(This.Handle)
	Case "Video pin..."
		If CheckBox1.Checked Then
			Terminate()
			Initial(False, False)
		End If
		DialogVideoPin(This.Handle)
		If CheckBox1.Checked Then CheckBox_Click CheckBox1
	Case "1/4"
	Case "1/2"
	Case "1/1"
	Case "Select file..."
		SaveFileDialog1.FileName = TextBox1.Text
		If SaveFileDialog1.Execute() Then
			TextBox1.Text = SaveFileDialog1.FileName
		End If
	Case "Capture"
		Sender.Text = "Stop"
		pAviFile = @TextBox1.Text
		Terminate()
		Initial(CheckBox1.Checked, True)
		ControlEnable False
		
		AVRun()
	Case "Stop"
		Sender.Text = "Capture"
		ControlEnable True
		
		AVStop()
		CheckBox_Click(CheckBox1)
	End Select
End Sub

Private Sub frmamcapType.TimerComponent_Timer(ByRef Sender As TimerComponent)
	StatusPanel1.Caption = AVStatus()
End Sub
