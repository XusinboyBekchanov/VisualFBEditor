'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			'#cmdline "Form1.rc"
		#endif
		'Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/Label.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/NumericUpDown.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/ComboBoxEdit.bi"
	
	Using My.Sys.Forms
	
	Type frmAIAgentType Extends Form
		Declare Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Sub cmdOK_Click(ByRef Sender As Control)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Sub chkAIAgentAuto_Click(ByRef Sender As CheckBox)
		Declare Sub cboAIAgentProvider_Change(ByRef Sender As ComboBoxEdit)
		Declare Sub cboAIAgentModelName_Change(ByRef Sender As ComboBoxEdit)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Constructor
		
		Dim As Label lblAIAgentName, lblAIAgentModelName, lblAIAgentHost, lblAIAgentPort, lblAIAgentAPIKey, lblAIAgentTemperature, lblAIAgentAddress, lblAIAgentprovider
		Dim As TextBox txtAIAgentAPIKey, txtAIAgentName
		Dim As ComboBoxEdit cboAIAgentModelName, cboAIAgentProvider, cboAIAgentPort, cboAIAgentAddress, cboAIAgentHost
		Dim As NumericUpDown updnAIAgentTemperature
		Dim As CheckBox chkAIAgentStream, chkAIAgentAuto
		Dim As CommandButton cmdOK, cmdCancel
	End Type
	
	Constructor frmAIAgentType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = My.Sys.Language
			End With
		#endif
		' frmAIAgent
		With This
			.Name = "frmAIAgent"
			.Text = ML("AI Agent")
			.Designer = @This
			.OnShow = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form), @Form_Show)
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.WindowState = WindowStates.wsNormal
			.StartPosition = FormStartPosition.CenterParent
			.BorderStyle = FormBorderStyle.FixedSingle
			.SetBounds 0, 0, 518, 259
		End With
		' lblAIAgentName
		With lblAIAgentName
			.Name = "lblAIAgentName"
			.Text = ML("Name") & ":"
			.TabIndex = 0
			.Alignment = AlignmentConstants.taRight
			.ControlIndex = 0
			.SetBounds 3, 11, 80, 20
			.Designer = @This
			.Parent = @This
		End With
		' lblAIAgentModelName
		With lblAIAgentModelName
			.Name = "lblAIAgentModelName"
			.Text = ML("Model Name")
			.TabIndex = 1
			.Alignment = AlignmentConstants.taRight
			.ControlIndex = 1
			.SetBounds 3, 68, 80, 20
			.Designer = @This
			.Parent = @This
		End With
		' lblAIAgentHost
		With lblAIAgentHost
			.Name = "lblAIAgentHost"
			.Text = ML("Host") & ":"
			.TabIndex = 2
			.Alignment = AlignmentConstants.taRight
			.ControlIndex = 2
			.SetBounds 3, 95, 80, 20
			.Designer = @This
			.Parent = @This
		End With
		' lblAIAgentPort
		With lblAIAgentPort
			.Name = "lblAIAgentPort"
			.Text = ML("Port") & ":"
			.TabIndex = 3
			.Alignment = AlignmentConstants.taRight
			.ControlIndex = 3
			.SetBounds 3, 127, 80, 20
			.Designer = @This
			.Parent = @This
		End With
		' lblAIAgentAPIKey
		With lblAIAgentAPIKey
			.Name = "lblAIAgentAPIKey"
			.Text = ML("API Key") & ":"
			.TabIndex = 4
			.Alignment = AlignmentConstants.taRight
			.ControlIndex = 4
			.SetBounds 3, 152, 80, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtAIAgentAPIKey
		With txtAIAgentAPIKey
			.Name = "txtAIAgentAPIKey"
			.TabIndex = 5
			.ControlIndex = 5
			.SetBounds 90, 149, 405, 20
			.Designer = @This
			.Parent = @This
		End With
		' cboAIAgentPort
		With cboAIAgentPort
			.Name = "cboAIAgentPort"
			.Style = cbDropDown
			.TabIndex = 6
			.ControlIndex = 5
			.Text = "443"
			.SetBounds 91, 123, 44, 18
			.Designer = @This
			.Parent = @This
		End With
		' lblAIAgentTemperature
		With lblAIAgentTemperature
			.Name = "lblAIAgentTemperature"
			.Text = ML("Temperature") & ":"
			.TabIndex = 7
			.ControlIndex = 7
			.SetBounds 143, 124, 80, 20
			.Designer = @This
			.Parent = @This
		End With
		' updnAIAgentTemperature
		With updnAIAgentTemperature
			.Name = "updnAIAgentTemperature"
			.Text = "0.6"
			.TabIndex = 9
			.ControlIndex = 8
			.DecimalPlaces = 1
			.MaxValue = 0
			.SetBounds 232, 124, 49, 20
			.Designer = @This
			.Parent = @This
		End With
		' chkAIAgentStream
		With chkAIAgentStream
			.Name = "chkAIAgentStream"
			.Text = "Stream"
			.TabIndex = 10
			.Checked = True
			.ControlIndex = 9
			.SetBounds 339, 124, 58, 17
			.Designer = @This
			.Parent = @This
		End With
		' cboAIAgentAddress
		With cboAIAgentAddress
			.Name = "cboAIAgentAddress"
			.Text = "cboAIAgentAddress"
			.Style = cbDropDown
			.TabIndex = 11
			.ControlIndex = 9
			.SetBounds 309, 96, 185, 20
			.Designer = @This
			.Parent = @This
		End With
		' lblAIAgentAddress
		With lblAIAgentAddress
			.Name = "lblAIAgentAddress"
			.Text = ML("Address") & ":"
			.TabIndex = 12
			.ControlIndex = 8
			.Alignment = AlignmentConstants.taRight
			.ID = 4129
			.SetBounds 233, 95, 71, 20
			.Designer = @This
			.Parent = @This
		End With
		' cboAIAgentHost
		With cboAIAgentHost
			.Name = "cboAIAgentHost"
			.Text = "cboAIAgentHost"
			.Style = cbDropDown
			.TabIndex = 13
			.ControlIndex = 12
			.SetBounds 90, 95, 132, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtAIAgentName
		With txtAIAgentName
			.Name = "txtAIAgentName"
			.TabIndex = 15
			.ControlIndex = 3
			.Enabled = False
			.SetBounds 91, 11, 336, 20
			.Designer = @This
			.Parent = @This
		End With
		' cmdOK
		With cmdOK
			.Name = "cmdOK"
			.Text = ML("OK")
			.TabIndex = 16
			.ControlIndex = 6
			.SetBounds 240, 185, 112, 24
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdOK_Click)
			.Parent = @This
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = ML("Cancel")
			.TabIndex = 17
			.ControlIndex = 0
			.SetBounds 370, 185, 112, 24
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdCancel_Click)
			.Parent = @This
		End With
		' lblAIAgentprovider
		With lblAIAgentprovider
			.Name = "lblAIAgentprovider"
			.Text = ML("Provider")
			.TabIndex = 18
			.Alignment = AlignmentConstants.taRight
			.ControlIndex = 1
			.SetBounds 3, 40, 80, 20
			.Designer = @This
			.Parent = @This
		End With
		' cboAIAgentModelName
		With cboAIAgentModelName
			.Name = "cboAIAgentModelName"
			.Text = "cboAIAgentModelName"
			.Style = cbDropDown
			.TabIndex = 21
			'.ImagesList = pimgListAIModels32
			.ControlIndex = 15
			.SetBounds 91, 68, 405, 18
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit), @cboAIAgentModelName_Change)
			.Parent = @This
		End With
		' cboAIAgentProvider
		With cboAIAgentProvider
			.Name = "cboAIAgentProvider"
			.Text = "cboAIAgentProvider"
			.Style = cbDropDown
			'.ImagesList = pimgListAIProviders32
			.TabIndex = 19
			.SetBounds 91, 40, 405, 18
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit), @cboAIAgentProvider_Change)
			.Parent = @This
		End With
		
		'Dim As FileListBox imgAIAgentFile
		'Dim As WString * 1028 tmpFileName
		'Dim As Integer Posi
		'imgAIAgentFile.Pattern = "*_dark.png"
		'imgAIAgentFile.Path = ExePath & "/" & "Resources/AIAgent/models"
		'For i As Integer = 0 To imgAIAgentFile.ListCount - 1
		'	tmpFileName = imgAIAgentFile.FileList.Item(i)
		'	Posi = InStrRev(tmpFileName, Any "\/:")
		'	If Posi > 0 Then
		'		tmpFileName = Mid(tmpFileName, Posi + 1, Len(tmpFileName) - 4)
		'		pimgListAIModels32->Add tmpFileName, tmpFileName
		'		cboAIAgentModelName.AddItem tmpFileName
		'	End If
		'Next
		'imgAIAgentFile.Pattern = "*_dark.png"
		'imgAIAgentFile.Path = ExePath & "/" & "Resources/AIAgent/providers"
		'For i As Integer = 0 To imgAIAgentFile.ListCount - 1
		'	tmpFileName = imgAIAgentFile.FileList.Item(i)
		'	Posi = InStrRev(tmpFileName, Any "\/:")
		'	If Posi > 0 Then
		'		tmpFileName = Mid(tmpFileName, Posi + 1, Len(tmpFileName) - 9)
		'		pimgListAIModels32->Add tmpFileName, tmpFileName
		'		cboAIAgentProvider.AddItem tmpFileName
		'	End If
		'Next
		' chkAIAgentAuto
		With chkAIAgentAuto
			.Name = "chkAIAgentAuto"
			.Text = "Auto"
			.TabIndex = 20
			.Checked = True
			.ControlIndex = 9
			.Caption = "Auto"
			.SetBounds 436, 11, 58, 17
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox), @chkAIAgentAuto_Click)
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frmAIAgent As frmAIAgentType
	
	'#if _MAIN_FILE_ = __FILE__
	'	App.DarkMode = True
	'	frmAIAgent.MainForm = True
	'	frmAIAgent.Show
	'	App.Run
	'#endif
'#End Region

Private Sub frmAIAgentType.cmdCancel_Click(ByRef Sender As Control)
	This.ModalResult = ModalResults.Cancel
	This.CloseForm
End Sub

Private Sub frmAIAgentType.cmdOK_Click(ByRef Sender As Control)
	If Trim(txtAIAgentName.Text) = "" Then
		MsgBox ML("Enter name of AI Agent!")
		This.BringToFront()
		Exit Sub
	ElseIf Trim(cboAIAgentModelName.Text) = "" Then
		MsgBox ML("Enter model name of AI Agent!")
		This.BringToFront()
		Exit Sub
	ElseIf Trim(cboAIAgentProvider.Text) = "" Then
		MsgBox ML("Enter provider of AI Agent!")
		This.BringToFront()
		Exit Sub
	ElseIf Trim(cboAIAgentHost.Text) = "" Then
		MsgBox ML("Enter host of AI Agent!")
		This.BringToFront()
		Exit Sub
	ElseIf Trim(cboAIAgentAddress.Text) = "" Then
		MsgBox ML("Enter address of AI Agent!")
		This.BringToFront()
		Exit Sub
	ElseIf Trim(cboAIAgentPort.Text) = "" Then
		MsgBox ML("Enter port of AI Agent!")
		This.BringToFront()
		Exit Sub
	ElseIf Trim(updnAIAgentTemperature.Text) = "" Then
		MsgBox ML("Enter temperature of AI Agent!")
		This.BringToFront()
		Exit Sub
	ElseIf Trim(txtAIAgentAPIKey.Text) = "" Then
		MsgBox ML("Enter API key of AI Agent!")
		This.BringToFront()
		Exit Sub
	End If
	This.ModalResult = ModalResults.OK
	This.CloseForm
End Sub

Private Sub frmAIAgentType.Form_Show(ByRef Sender As Form)
	
End Sub

Private Sub frmAIAgentType.chkAIAgentAuto_Click(ByRef Sender As CheckBox)
	txtAIAgentName.Enabled = Not chkAIAgentAuto.Checked
End Sub

Private Sub frmAIAgentType.cboAIAgentProvider_Change(ByRef Sender As ComboBoxEdit)
	If chkAIAgentAuto.Checked Then
		txtAIAgentName.Text = cboAIAgentModelName.Text & "|" & cboAIAgentProvider.Text
	End If
End Sub

Private Sub frmAIAgentType.cboAIAgentModelName_Change(ByRef Sender As ComboBoxEdit)
	If chkAIAgentAuto.Checked Then
		txtAIAgentName.Text = cboAIAgentModelName.Text & "|" & cboAIAgentProvider.Text
	End If
End Sub

Private Sub frmAIAgentType.Form_Create(ByRef Sender As Control)
	txtAIAgentAPIKey.Enabled = chkAIAgentAuto.Checked
	cboAIAgentPort.AddItem "80"
	cboAIAgentPort.AddItem "443"
	Dim As WString * 260 tmpName = ExePath & "/Resources/AIAgent"
	If Dir(tmpName) = "" Then MkDir tmpName
	tmpName = ExePath & "/Resources/AIAgent/ModelName.ini"
	If Dir(tmpName) <> "" Then
		cboAIAgentModelName.LoadFromFile(tmpName)
	Else
		With cboAIAgentModelName
			.AddItem "qwen/qwq-32b:free"
			.AddItem "google/gemini-2.0-flash-thinking-exp:free"
			.AddItem "deepseek/deepseek-r1:free"
			.AddItem "deepseek/deepseek-chat-v3-0324:free"
			.AddItem "deepseek-ai/deepseek-r1"
		End With
		cboAIAgentModelName.SaveToFile(tmpName)
	End If
	
	tmpName = ExePath & "/Resources/AIAgent/Host.ini"
	If Dir(tmpName) <> "" Then
		cboAIAgentHost.LoadFromFile(tmpName)
	Else
		With cboAIAgentHost
			.AddItem "openrouter.ai"
			.AddItem "integrate.api.nvidia.com"
			.AddItem "api.siliconflow.cn"
			.AddItem "api.deepseek.com"
			.AddItem "api.openai.com"
			.AddItem "integrate.api.nvidia.com"
			.AddItem "ai.baidu.com"
			.AddItem "aai.tencentcloudapi.com"
			.AddItem "api.anthropic.com"
			.AddItem "dashscope.aliyuncs.com"
			.AddItem "api.google.com"
			.AddItem "cn-beijing.azure.com"
		End With
		cboAIAgentHost.SaveToFile(tmpName)
	End If
	
	tmpName = ExePath & "/Resources/AIAgent/Address.ini"
	If Dir(tmpName) <> "" Then
		cboAIAgentAddress.LoadFromFile(tmpName)
	Else
		With  cboAIAgentAddress
			.AddItem "api/v1/chat/completions"
			.AddItem "v1/chat/completions"
			.AddItem "v1/completions"
			.AddItem "compatible-mode/v1/"
		End With
		cboAIAgentAddress.SaveToFile(tmpName)
	End If
	tmpName = ExePath & "/Resources/AIAgent/Provider.ini"
	If Dir(tmpName) <> "" Then
		cboAIAgentProvider.LoadFromFile(tmpName)
	Else
		With cboAIAgentProvider
			.AddItem "DeepSeek"
			.AddItem "Google"
			.AddItem "openai"
			.AddItem "Silicon"
			.AddItem "ChatGPT"
			.AddItem "OpenRouter"
			.AddItem "Nvidia"
			.AddItem "TencentCloud"
			.AddItem "AliYun"
			.AddItem "Baidu"
			.AddItem "Azure"
			.AddItem "Bytedance"
		End With
		cboAIAgentProvider.SaveToFile(tmpName)
	End If
End Sub