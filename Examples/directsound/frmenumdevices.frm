'enumdevices设备枚举
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "frmenumdevices.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/Label.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/CommandButton.bi"

	#include once "enumdevices.bi"

	Using My.Sys.Forms
	
	Type Form1Type Extends Form
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Constructor
		
		Dim As Label Label1, Label2, Label3
		Dim As ComboBoxEdit ComboBoxEdit1, ComboBoxEdit2
		Dim As CommandButton CommandButton1, CommandButton2, CommandButton3
	End Type
	
	Constructor Form1Type
		' Form1
		With This
			.Name = "Form1"
			.Text = "DirectSound EnumDevices"
			.Designer = @This
			.StartPosition = FormStartPosition.CenterScreen
			.Caption = "DirectSound EnumDevices"
			.BorderStyle = FormBorderStyle.FixedDialog
			.MaximizeBox = False
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnDestroy = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Destroy)
			.SetBounds 0, 0, 450, 200
		End With
		' Label1
		With Label1
			.Name = "Label1"
			.Text = "This sample simply demonstrates how to enumerate devices."
			.TabIndex = 0
			.Caption = "This sample simply demonstrates how to enumerate devices."
			.SetBounds 20, 20, 310, 20
			.Designer = @This
			.Parent = @This
		End With
		' Label2
		With Label2
			.Name = "Label2"
			.Text = "Sound Device:"
			.TabIndex = 1
			.Caption = "Sound Device:"
			.SetBounds 20, 50, 90, 20
			.Designer = @This
			.Parent = @This
		End With
		' Label3
		With Label3
			.Name = "Label3"
			.Text = "Capture Device:"
			.TabIndex = 2
			.Caption = "Capture Device:"
			.SetBounds 20, 90, 90, 20
			.Designer = @This
			.Parent = @This
		End With
		' ComboBoxEdit1
		With ComboBoxEdit1
			.Name = "ComboBoxEdit1"
			.Text = "ComboBoxEdit1"
			.TabIndex = 3
			.SetBounds 110, 50, 310, 21
			.Designer = @This
			.Parent = @This
		End With
		' ComboBoxEdit2
		With ComboBoxEdit2
			.Name = "ComboBoxEdit2"
			.Text = "ComboBoxEdit2"
			.TabIndex = 4
			.SetBounds 110, 90, 310, 21
			.Designer = @This
			.Parent = @This
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "Refresh"
			.TabIndex = 5
			.Caption = "Refresh"
			.SetBounds 20, 130, 90, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton1_Click)
			.Parent = @This
		End With
		' CommandButton2
		With CommandButton2
			.Name = "CommandButton2"
			.Text = "Create"
			.TabIndex = 6
			.Caption = "Create"
			.SetBounds 120, 130, 90, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton1_Click)
			.Parent = @This
		End With
		' CommandButton3
		With CommandButton3
			.Name = "CommandButton3"
			.Text = "Exit"
			.TabIndex = 7
			.Caption = "Exit"
			.SetBounds 330, 130, 90, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton1_Click)
			.Parent = @This
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

Private Sub Form1Type.Form_Create(ByRef Sender As Control)
	CoInitialize(NULL)

	CommandButton1_Click(CommandButton1)
End Sub

Private Sub Form1Type.Form_Destroy(ByRef Sender As Control)
	CoUninitialize()
End Sub

Private Sub Form1Type.CommandButton1_Click(ByRef Sender As Control)
	Dim hr As HRESULT
	Select Case Sender.Text
	Case "Refresh"
		ComboBoxEdit1.Clear
		
		' Enumerate the sound devices And place them in the combo box
		hr = DirectSoundEnumerate(@DSoundEnumCallback, @ComboBoxEdit1)
		If FAILED(hr) Then Return
		
		ComboBoxEdit2.Clear
		
		' Enumerate the capture devices And place them in the combo box
		hr = DirectSoundCaptureEnumerate(@DSoundEnumCallback, @ComboBoxEdit2)
		If FAILED(hr) Then Return
		
		ComboBoxEdit1.ItemIndex = 0
		ComboBoxEdit2.ItemIndex = 0	
	Case "Create"
		hr = InitDirectSound(ComboBoxEdit1.ItemData(ComboBoxEdit1.ItemIndex), ComboBoxEdit2.ItemData(ComboBoxEdit2.ItemIndex))
		If hr Then
			MsgBox("DirectSound interface creatation failed", Caption, mtInfo, btOK)
		Else
			MsgBox("DirectSound interface created successfully", Caption, mtWarning, btOK)
		End If
	Case "Exit"
		This.CloseForm
	End Select
End Sub
