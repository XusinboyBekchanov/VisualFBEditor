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
	
	Using My.Sys.Forms
	
	Type frmAIAgentType Extends Form
		Declare Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Sub cmdOK_Click(ByRef Sender As Control)
		Declare Constructor
		
		Dim As Label lblAIAgentName, lblAIAgentModelName, lblAIAgentHost, lblAIAgentPort, lblAIAgentAPIKey, lblAIAgentTemperature, lblAIAgentAddress
		Dim As TextBox txtAIAgentAPIKey, txtAIAgentPort, txtAIAgentAddress, txtAIAgentHost, txtAIAgentModelName, txtAIAgentName
		Dim As NumericUpDown txtAIAgentTemperature
		Dim As CheckBox chkAIAgentStream
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
			.Text = "AI Agent"
			.Designer = @This
			.Caption = "AI Agent"
			.SetBounds 0, 0, 440, 230
		End With
		' lblAIAgentName
		With lblAIAgentName
			.Name = "lblAIAgentName"
			.Text = ML("Name") & ":"
			.TabIndex = 0
			.Alignment = AlignmentConstants.taRight
			.ControlIndex = 0
			.SetBounds 9, 11, 84, 20
			.Designer = @This
			.Parent = @This
		End With
		' lblAIAgentModelName
		With lblAIAgentModelName
			.Name = "lblAIAgentModelName"
			.Text = "Model Name"
			.TabIndex = 1
			.Alignment = AlignmentConstants.taRight
			.ControlIndex = 1
			.SetBounds 9, 38, 84, 20
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
			.SetBounds 9, 65, 84, 20
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
			.SetBounds 9, 97, 84, 20
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
			.SetBounds 9, 122, 84, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtAIAgentAPIKey
		With txtAIAgentAPIKey
			.Name = "txtAIAgentAPIKey"
			.TabIndex = 5
			.ControlIndex = 5
			.SetBounds 100, 119, 305, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtAIAgentPort
		With txtAIAgentPort
			.Name = "txtAIAgentPort"
			.TabIndex = 6
			.ControlIndex = 5
			.SetBounds 101, 93, 44, 20
			.Designer = @This
			.Parent = @This
		End With
		' lblAIAgentTemperature
		With lblAIAgentTemperature
			.Name = "lblAIAgentTemperature"
			.Text = ML("Temperature") & ":"
			.TabIndex = 7
			.ControlIndex = 7
			.SetBounds 153, 94, 80, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtAIAgentTemperature
		With txtAIAgentTemperature
			.Name = "txtAIAgentTemperature"
			.Text = "0"
			.TabIndex = 9
			.ControlIndex = 8
			.SetBounds 242, 94, 41, 20
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
			.SetBounds 347, 94, 58, 17
			.Designer = @This
			.Parent = @This
		End With
		' txtAIAgentAddress
		With txtAIAgentAddress
			.Name = "txtAIAgentAddress"
			.Text = "txtAIAgentAddress"
			.TabIndex = 11
			.ControlIndex = 9
			.SetBounds 286, 65, 120, 20
			.Designer = @This
			.Parent = @This
		End With
		' lblAIAgentAddress
		With lblAIAgentAddress
			.Name = "lblAIAgentAddress"
			.Text = ML("Address") & ":"
			.TabIndex = 12
			.ControlIndex = 8
			.SetBounds 209, 65, 75, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtAIAgentHost
		With txtAIAgentHost
			.Name = "txtAIAgentHost"
			.Text = "txtAIAgentHost"
			.TabIndex = 13
			.ControlIndex = 12
			.SetBounds 100, 65, 103, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtAIAgentModelName
		With txtAIAgentModelName
			.Name = "txtAIAgentModelName"
			.Text = "txtAIAgentModelName"
			.TabIndex = 14
			.ControlIndex = 13
			.SetBounds 100, 38, 305, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtAIAgentName
		With txtAIAgentName
			.Name = "txtAIAgentName"
			.TabIndex = 15
			.ControlIndex = 3
			.SetBounds 100, 11, 305, 20
			.Designer = @This
			.Parent = @This
		End With
		' cmdOK
		With cmdOK
			.Name = "cmdOK"
			.Text = ML("OK")
			.TabIndex = 16
			.ControlIndex = 6
			.SetBounds 176, 156, 112, 24
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
			.SetBounds 296, 156, 112, 24
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdCancel_Click)
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
	ElseIf Trim(txtAIAgentModelName.Text) = "" Then
		MsgBox ML("Enter model name of AI Agent!")
		This.BringToFront()
		Exit Sub
	ElseIf Trim(txtAIAgentHost.Text) = "" Then
		MsgBox ML("Enter host of AI Agent!")
		This.BringToFront()
		Exit Sub
	ElseIf Trim(txtAIAgentAddress.Text) = "" Then
		MsgBox ML("Enter address of AI Agent!")
		This.BringToFront()
		Exit Sub
	ElseIf Trim(txtAIAgentPort.Text) = "" Then
		MsgBox ML("Enter port of AI Agent!")
		This.BringToFront()
		Exit Sub
	ElseIf Trim(txtAIAgentTemperature.Text) = "" Then
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
