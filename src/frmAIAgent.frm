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
	#include once "mff/VerticalBox.bi"
	#include once "mff/HorizontalBox.bi"
	
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
		Dim As VerticalBox VerticalBox1
		Dim As HorizontalBox HorizontalBox1, HorizontalBox2, HorizontalBox3, HorizontalBox4, HorizontalBox5, HorizontalBox6, HorizontalBox7
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
			.AutoSize = true
			.SetBounds 0, 0, 528, 269
		End With
		' lblAIAgentName
		With lblAIAgentName
			.Name = "lblAIAgentName"
			.Text = ML("Name") & ":"
			.TabIndex = 0
			.Alignment = AlignmentConstants.taRight
			.ControlIndex = 0
			.Align = DockStyle.alLeft
			.CenterImage = true
			.ID = 1887
			.WordWraps = true
			.SetBounds 0, 0, 80, 20
			.Designer = @This
			.Parent = @HorizontalBox1
		End With
		' lblAIAgentModelName
		With lblAIAgentModelName
			.Name = "lblAIAgentModelName"
			.Text = ML("Model Name") & ":"
			.TabIndex = 1
			.Alignment = AlignmentConstants.taRight
			.ControlIndex = 1
			.Align = DockStyle.alLeft
			.CenterImage = true
			.ID = 1918
			.Caption = ML("Model Name") & ":"
			.SetBounds 0, 0, 80, 21
			.Designer = @This
			.Parent = @HorizontalBox3
		End With
		' lblAIAgentHost
		With lblAIAgentHost
			.Name = "lblAIAgentHost"
			.Text = ML("Host") & ":"
			.TabIndex = 2
			.Alignment = AlignmentConstants.taRight
			.ControlIndex = 2
			.Align = DockStyle.alLeft
			.CenterImage = true
			.ID = 1919
			.SetBounds 0, 0, 80, 21
			.Designer = @This
			.Parent = @HorizontalBox4
		End With
		' lblAIAgentPort
		With lblAIAgentPort
			.Name = "lblAIAgentPort"
			.Text = ML("Port") & ":"
			.TabIndex = 3
			.Alignment = AlignmentConstants.taRight
			.ControlIndex = 3
			.Align = DockStyle.alLeft
			.CenterImage = true
			.ID = 1920
			.SetBounds 0, 0, 80, 21
			.Designer = @This
			.Parent = @HorizontalBox5
		End With
		' lblAIAgentAPIKey
		With lblAIAgentAPIKey
			.Name = "lblAIAgentAPIKey"
			.Text = ML("API Key") & ":"
			.TabIndex = 4
			.Alignment = AlignmentConstants.taRight
			.ControlIndex = 4
			.CenterImage = true
			.ID = 1923
			.SetBounds 0, 0, 80, 21
			.Designer = @This
			.Parent = @HorizontalBox6
		End With
		' txtAIAgentAPIKey
		With txtAIAgentAPIKey
			.Name = "txtAIAgentAPIKey"
			.TabIndex = 5
			.ControlIndex = 5
			.SetBounds 90, 0, 411, 10
			.Designer = @This
			.Parent = @HorizontalBox6
		End With
		' cboAIAgentPort
		With cboAIAgentPort
			.Name = "cboAIAgentPort"
			.Style = cbDropDown
			.TabIndex = 6
			.ControlIndex = 5
			.Text = "443"
			.SetBounds 80, 0, 54, 21
			.Designer = @This
			.Parent = @HorizontalBox5
		End With
		' lblAIAgentTemperature
		With lblAIAgentTemperature
			.Name = "lblAIAgentTemperature"
			.Text = ML("Temperature") & ":"
			.TabIndex = 7
			.ControlIndex = 7
			.Alignment = AlignmentConstants.taRight
			.ID = 1922
			.CenterImage = true
			.SetBounds 154, 0, 80, 21
			.Designer = @This
			.Parent = @HorizontalBox5
		End With
		' updnAIAgentTemperature
		With updnAIAgentTemperature
			.Name = "updnAIAgentTemperature"
			.Text = "0.6"
			.TabIndex = 9
			.ControlIndex = 8
			.DecimalPlaces = 1
			.MaxValue = 0
			.SetBounds 134, 0, 49, 21
			.Designer = @This
			.Parent = @HorizontalBox5
		End With
		' chkAIAgentStream
		With chkAIAgentStream
			.Name = "chkAIAgentStream"
			.Text = "Stream"
			.TabIndex = 10
			.Checked = True
			.ControlIndex = 9
			.SetBounds 263, 0, 58, 21
			.Designer = @This
			.Parent = @HorizontalBox5
		End With
		' cboAIAgentAddress
		With cboAIAgentAddress
			.Name = "cboAIAgentAddress"
			.Text = "cboAIAgentAddress"
			.Style = cbDropDown
			.TabIndex = 11
			.ControlIndex = 9
			.SetBounds 283, 0, 191, 21
			.Designer = @This
			.Parent = @HorizontalBox4
		End With
		' lblAIAgentAddress
		With lblAIAgentAddress
			.Name = "lblAIAgentAddress"
			.Text = ML("Address") & ":"
			.TabIndex = 12
			.ControlIndex = 8
			.Alignment = AlignmentConstants.taRight
			.ID = 1921
			.CenterImage = true
			.SetBounds 291, 0, 71, 21
			.Designer = @This
			.Parent = @HorizontalBox4
		End With
		' cboAIAgentHost
		With cboAIAgentHost
			.Name = "cboAIAgentHost"
			.Text = "cboAIAgentHost"
			.Style = cbDropDown
			.TabIndex = 13
			.ControlIndex = 12
			.SetBounds 372, 0, 129, 21
			.Designer = @This
			.Parent = @HorizontalBox4
		End With
		' txtAIAgentName
		With txtAIAgentName
			.Name = "txtAIAgentName"
			.TabIndex = 15
			.ControlIndex = 3
			.Enabled = False
			.Align = DockStyle.alLeft
			.SetBounds 90, 0, 356, 20
			.Designer = @This
			.Parent = @HorizontalBox1
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = ML("Cancel")
			.TabIndex = 17
			.ControlIndex = 0
			.Anchor.Right = AnchorStyle.asAnchor
			.Anchor.Bottom = AnchorStyle.asAnchor
			.Align = DockStyle.alRight
			.SetBounds 112, 0, 112, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdCancel_Click)
			.Parent = @HorizontalBox7
		End With
		' cmdOK
		With cmdOK
			.Name = "cmdOK"
			.Text = ML("OK")
			.TabIndex = 16
			.ControlIndex = 1
			.Anchor.Right = AnchorStyle.asAnchor
			.Anchor.Bottom = AnchorStyle.asAnchor
			.Align = DockStyle.alRight
			.SetBounds 112, 0, 112, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdOK_Click)
			.Parent = @HorizontalBox7
		End With
		' lblAIAgentprovider
		With lblAIAgentprovider
			.Name = "lblAIAgentprovider"
			.Text = ML("Provider") & ":"
			.TabIndex = 18
			.Alignment = AlignmentConstants.taRight
			.ControlIndex = 1
			.Align = DockStyle.alLeft
			.CenterImage = true
			.ID = 1917
			.Caption = ML("Provider") & ":"
			.SetBounds 0, 0, 80, 21
			.Designer = @This
			.Parent = @HorizontalBox2
		End With
		' cboAIAgentModelName
		With cboAIAgentModelName
			.Name = "cboAIAgentModelName"
			.Text = "cboAIAgentModelName"
			.Style = cbDropDown
			.TabIndex = 21
			'.ImagesList = pimgListAIModels32
			.ControlIndex = 0
			.SetBounds 0, 0, 411, 21
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit), @cboAIAgentModelName_Change)
			.Parent = @HorizontalBox3
		End With
		' cboAIAgentProvider
		With cboAIAgentProvider
			.Name = "cboAIAgentProvider"
			.Text = "cboAIAgentProvider"
			.Style = cbDropDown
			'.ImagesList = pimgListAIProviders32
			.TabIndex = 19
			.SetBounds 90, 0, 411, 21
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit), @cboAIAgentProvider_Change)
			.Parent = @HorizontalBox2
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
			.Align = DockStyle.alLeft
			.SetBounds 456, 0, 53, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox), @chkAIAgentAuto_Click)
			.Parent = @HorizontalBox1
		End With
		' VerticalBox1
		With VerticalBox1
			.Name = "VerticalBox1"
			.Text = "VerticalBox1"
			.TabIndex = 21
			.Spacing = 10
			.Align = DockStyle.alClient
			.Margins.Bottom = 10
			.Margins.Left = 10
			.Margins.Right = 10
			.Margins.Top = 10
			.SetBounds 0, 0, 529, 225
			.Designer = @This
			.Parent = @This
		End With
		' HorizontalBox1
		With HorizontalBox1
			.Name = "HorizontalBox1"
			.Text = "HorizontalBox1"
			.TabIndex = 22
			.Align = DockStyle.alTop
			.Spacing = 10
			.SetBounds 0, 0, 499, 20
			.Designer = @This
			.Parent = @VerticalBox1
		End With
		' HorizontalBox2
		With HorizontalBox2
			.Name = "HorizontalBox2"
			.Text = "HorizontalBox2"
			.TabIndex = 26
			.Align = DockStyle.alTop
			.Spacing = 10
			.SetBounds 0, 30, 501, 21
			.Designer = @This
			.Parent = @VerticalBox1
		End With
		' HorizontalBox3
		With HorizontalBox3
			.Name = "HorizontalBox3"
			.Text = "HorizontalBox3"
			.TabIndex = 24
			.Align = DockStyle.alTop
			.Spacing = 10
			.SetBounds 0, 61, 501, 21
			.Designer = @This
			.Parent = @VerticalBox1
		End With
		' HorizontalBox4
		With HorizontalBox4
			.Name = "HorizontalBox4"
			.Text = "HorizontalBox4"
			.TabIndex = 25
			.Spacing = 10
			.Align = DockStyle.alTop
			.SetBounds 10, 102, 501, 21
			.Designer = @This
			.Parent = @VerticalBox1
		End With
		' HorizontalBox5
		With HorizontalBox5
			.Name = "HorizontalBox5"
			.Text = "HorizontalBox5"
			.TabIndex = 26
			.Spacing = 10
			.Align = DockStyle.alTop
			.SetBounds 10, 133, 361, 21
			.Designer = @This
			.Parent = @VerticalBox1
		End With
		' HorizontalBox6
		With HorizontalBox6
			.Name = "HorizontalBox6"
			.Text = "HorizontalBox6"
			.TabIndex = 27
			.Spacing = 10
			.Align = DockStyle.alTop
			.SetBounds 10, 164, 501, 21
			.Designer = @This
			.Parent = @VerticalBox1
		End With
		' HorizontalBox7
		With HorizontalBox7
			.Name = "HorizontalBox7"
			.Text = "HorizontalBox7"
			.TabIndex = 28
			.Align = DockStyle.alBottom
			.Margins.Bottom = 0
			.SetBounds 0, 134, 501, 30
			.Designer = @This
			.Parent = @VerticalBox1
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
	If Not cboAIAgentProvider.Contains(cboAIAgentProvider.Text) Then cboAIAgentProvider.AddItem cboAIAgentProvider.Text
	If Not cboAIAgentModelName.Contains(cboAIAgentModelName.Text) Then cboAIAgentModelName.AddItem cboAIAgentModelName.Text
	If Not cboAIAgentAddress.Contains(cboAIAgentModelName.Text) Then cboAIAgentAddress.AddItem cboAIAgentAddress.Text
	Dim As WString * 260 tmpName = ExePath & "/Resources/AIAgent"
	If Dir(tmpName) = "" Then MkDir tmpName
	cboAIAgentModelName.SaveToFile(ExePath & "/Resources/AIAgent/ModelName.ini")
	cboAIAgentHost.SaveToFile(ExePath & "/Resources/AIAgent/Host.ini")
	cboAIAgentAddress.SaveToFile(ExePath & "/Resources/AIAgent/Address.ini")
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
	txtAIAgentName.Enabled = chkAIAgentAuto.Checked
	Dim As UString Temp = cboAIAgentPort.Text
	cboAIAgentPort.Clear
	cboAIAgentPort.AddItem "80"
	cboAIAgentPort.AddItem "443"
	cboAIAgentPort.Text = Temp
	Temp = cboAIAgentModelName.Text
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
	cboAIAgentModelName.Text = Temp
	Temp = cboAIAgentHost.Text
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
	cboAIAgentHost.Text = Temp
	Temp = cboAIAgentAddress.Text
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
	cboAIAgentAddress.Text = Temp
	Temp = cboAIAgentProvider.Text
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
	cboAIAgentProvider.Text = Temp
End Sub
