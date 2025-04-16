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
	#include once "mff/CheckBox.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/ComboBoxEdit.bi"
	
	Using My.Sys.Forms
	
	#include once "frmEdit.frm"
	
	Type frmAiOptionsType Extends Form
		Declare Sub CommandButton_Click(ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub cmdProfile_Click(ByRef Sender As Control)
		Declare Sub cboAIAgentProfile_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub ComboBoxEdit_DblClick(ByRef Sender As Control)
		Declare Constructor
		
		Dim As Label lblModelName, lblHTTPHost, lblHTTPPort, lblAPIKey, lblTemperature, lblResourceAddress, lblAIAgentProfile, lblContent, lblReason, lblHeader, lblBody, lblAssistant
		Dim As TextBox txtContentStart, txtContentEnd, txtReasonStart, txtReasonEnd, txtHeader, txtBody, txtContentSplit, txtReasonSplit, txtAssistant, txtTemperature
		Dim As ComboBoxEdit cboAPIKey, cboModelName, cboAIAgentProfile, cboHTTPPort, cboResourceAddress, cboHTTPHost
		Dim As CheckBox chkStream
		Dim As CommandButton cmdOK, cmdCancel, cmdRefresh, cmdDelete, cmdSave
	End Type
	
	Constructor frmAiOptionsType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = My.Sys.Language
			End With
		#endif
		' frmAiOptions
		With This
			.Name = "frmAiOptions"
			.Text = "AI Agent Options"
			.Designer = @This
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.WindowState = WindowStates.wsNormal
			.StartPosition = FormStartPosition.CenterParent
			.BorderStyle = FormBorderStyle.FixedSingle
			.Caption = "AI Agent Options"
			.MinimizeBox = False
			.MaximizeBox = False
			.SetBounds 0, 0, 528, 639
		End With
		' lblAIAgentProfile
		With lblAIAgentProfile
			.Name = "lblAIAgentProfile"
			.Text = "Profile:"
			.TabIndex = 0
			.Alignment = AlignmentConstants.taRight
			.Caption = "Profile:"
			.SetBounds 10, 25, 80, 20
			.Designer = @This
			.Parent = @This
		End With
		' cboAIAgentProfile
		With cboAIAgentProfile
			.Name = "cboAIAgentProfile"
			.Text = "cboAIAgentProfile"
			.Style = cbDropDown
			'.ImagesList = pimgListAIProviders32
			.TabIndex = 1
			.SetBounds 100, 25, 221, 21
			.Designer = @This
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @cboAIAgentProfile_Selected)
			.Parent = @This
		End With
		' cmdRefresh
		With cmdRefresh
			.Name = "cmdRefresh"
			.Text = "Refresh"
			.TabIndex = 2
			.Caption = "Refresh"
			.SetBounds 330, 25, 60, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdProfile_Click)
			.Parent = @This
		End With
		' cmdDelete
		With cmdDelete
			.Name = "cmdDelete"
			.Text = "Delete"
			.TabIndex = 3
			.Caption = "Delete"
			.SetBounds 390, 25, 60, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdProfile_Click)
			.Parent = @This
		End With
		' cmdSave
		With cmdSave
			.Name = "cmdSave"
			.Text = "Save"
			.TabIndex = 4
			.Caption = "Save"
			.SetBounds 450, 25, 60, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdProfile_Click)
			.Parent = @This
		End With
		' lblHTTPHost
		With lblHTTPHost
			.Name = "lblHTTPHost"
			.Text = "Host:"
			.TabIndex = 5
			.Alignment = AlignmentConstants.taRight
			.SetBounds 10, 80, 80, 20
			.Designer = @This
			.Parent = @This
		End With
		' cboHTTPHost
		With cboHTTPHost
			.Name = "cboHTTPHost"
			.Text = "cboHTTPHost"
			.Style = cbDropDown
			.TabIndex = 6
			.SetBounds 100, 80, 130, 21
			.Designer = @This
			.OnDblClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @ComboBoxEdit_DblClick)
			.OnDblClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @ComboBoxEdit_DblClick)
			.Parent = @This
		End With
		' lblResourceAddress
		With lblResourceAddress
			.Name = "lblResourceAddress"
			.Text = "Address:"
			.TabIndex = 7
			.Alignment = AlignmentConstants.taRight
			.ID = 4129
			.SetBounds 240, 80, 80, 20
			.Designer = @This
			.Parent = @This
		End With
		' cboResourceAddress
		With cboResourceAddress
			.Name = "cboResourceAddress"
			.Text = "cboResourceAddress"
			.Style = cbDropDown
			.TabIndex = 8
			.SetBounds 330, 80, 181, 21
			.Designer = @This
			.OnDblClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @ComboBoxEdit_DblClick)
			.Parent = @This
		End With
		' lblHTTPPort
		With lblHTTPPort
			.Name = "lblHTTPPort"
			.Text = "Port:"
			.TabIndex = 9
			.Alignment = AlignmentConstants.taRight
			.SetBounds 10, 110, 80, 20
			.Designer = @This
			.Parent = @This
		End With
		' cboHTTPPort
		With cboHTTPPort
			.Name = "cboHTTPPort"
			.Style = cbDropDown
			.TabIndex = 10
			.Text = "443"
			.SetBounds 100, 110, 130, 21
			.Designer = @This
			.OnDblClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @ComboBoxEdit_DblClick)
			.Parent = @This
		End With
		' lblTemperature
		With lblTemperature
			.Name = "lblTemperature"
			.Text = "Temperature:"
			.TabIndex = 11
			.Alignment = AlignmentConstants.taRight
			.ID = 1021
			.SetBounds 240, 110, 80, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtTemperature
		With txtTemperature
			.Name = "txtTemperature"
			.Text = "0"
			.TabIndex = 12
			.SetBounds 330, 110, 60, 20
			.Designer = @This
			.Parent = @This
		End With
		' chkStream
		With chkStream
			.Name = "chkStream"
			.Text = "Stream"
			.TabIndex = 13
			.Checked = True
			.SetBounds 449, 110, 60, 20
			.Designer = @This
			.Parent = @This
		End With
		' lblModelName
		With lblModelName
			.Name = "lblModelName"
			.Text = "Model Name:"
			.TabIndex = 14
			.Alignment = AlignmentConstants.taRight
			.Caption = "Model Name:"
			.SetBounds 10, 140, 80, 20
			.Designer = @This
			.Parent = @This
		End With
		' cboModelName
		With cboModelName
			.Name = "cboModelName"
			.Text = "cboModelName"
			.Style = cbDropDown
			.TabIndex = 15
			.SetBounds 100, 140, 411, 21
			.Designer = @This
			.OnDblClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @ComboBoxEdit_DblClick)
			.Parent = @This
		End With
		' lblAPIKey
		With lblAPIKey
			.Name = "lblAPIKey"
			.Text = "API Key:"
			.TabIndex = 16
			.Alignment = AlignmentConstants.taRight
			.SetBounds 10, 170, 80, 20
			.Designer = @This
			.Parent = @This
		End With
		' cboAPIKey
		With cboAPIKey
			.Name = "cboAPIKey"
			.TabIndex = 17
			.Style = ComboBoxEditStyle.cbDropDown
			.Text = "cboAPIKey"
			.SetBounds 100, 170, 411, 21
			.Designer = @This
			.OnDblClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @ComboBoxEdit_DblClick)
			.Parent = @This
		End With
		' lblHeader
		With lblHeader
			.Name = "lblHeader"
			.Text = "Header:"
			.TabIndex = 18
			.Alignment = AlignmentConstants.taRight
			.Caption = "Header:"
			.SetBounds 10, 200, 80, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtHeader
		With txtHeader
			.Name = "txtHeader"
			.Text = "txtHeader"
			.TabIndex = 19
			.Multiline = True
			.ScrollBars = ScrollBarsType.Both
			.HideSelection = False
			.SetBounds 100, 200, 410, 70
			.Designer = @This
			.Parent = @This
		End With
		' lblBody
		With lblBody
			.Name = "lblBody"
			.Text = "Body:"
			.TabIndex = 20
			.Alignment = AlignmentConstants.taRight
			.Caption = "Body:"
			.SetBounds 10, 280, 80, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtBody
		With txtBody
			.Name = "txtBody"
			.Text = "txtBody"
			.TabIndex = 21
			.Multiline = True
			.ScrollBars = ScrollBarsType.Both
			.HideSelection = False
			.SetBounds 100, 280, 410, 140
			.Designer = @This
			.Parent = @This
		End With
		' lblAssistant
		With lblAssistant
			.Name = "lblAssistant"
			.Text = "Assistant:"
			.TabIndex = 22
			.Alignment = AlignmentConstants.taRight
			.Caption = "Assistant:"
			.SetBounds 10, 430, 80, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtAssistant
		With txtAssistant
			.Name = "txtAssistant"
			.Text = "txtAssistant"
			.TabIndex = 23
			.HideSelection = False
			.Multiline = True
			.ScrollBars = ScrollBarsType.Both
			.SetBounds 100, 430, 410, 60
			.Designer = @This
			.Parent = @This
		End With
		' lblContent
		With lblContent
			.Name = "lblContent"
			.Text = "Locate content:"
			.TabIndex = 24
			.Caption = "Locate content:"
			.Alignment = AlignmentConstants.taRight
			.SetBounds 10, 500, 80, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtContentStart
		With txtContentStart
			.Name = "txtContentStart"
			.Text = "txtContentStart"
			.TabIndex = 25
			.SetBounds 100, 500, 150, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtContentEnd
		With txtContentEnd
			.Name = "txtContentEnd"
			.Text = "txtContentEnd"
			.TabIndex = 26
			.SetBounds 260, 500, 150, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtContentSplit
		With txtContentSplit
			.Name = "txtContentSplit"
			.Text = "txtContentSplit"
			.TabIndex = 27
			.SetBounds 420, 500, 90, 20
			.Designer = @This
			.Parent = @This
		End With
		' lblReason
		With lblReason
			.Name = "lblReason"
			.Text = "Locate reason:"
			.TabIndex = 28
			.Caption = "Locate reason:"
			.Alignment = AlignmentConstants.taRight
			.SetBounds 10, 530, 80, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtReasonStart
		With txtReasonStart
			.Name = "txtReasonStart"
			.Text = "txtReasonStart"
			.TabIndex = 29
			.SetBounds 100, 530, 150, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtReasonEnd
		With txtReasonEnd
			.Name = "txtReasonEnd"
			.Text = "txtReasonEnd"
			.TabIndex = 30
			.SetBounds 260, 530, 150, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtReasonSplit
		With txtReasonSplit
			.Name = "txtReasonSplit"
			.Text = "txtReasonSplit"
			.TabIndex = 31
			.SetBounds 420, 530, 90, 20
			.Designer = @This
			.Parent = @This
		End With
		' cmdOK
		With cmdOK
			.Name = "cmdOK"
			.Text = "OK"
			.TabIndex = 32
			.SetBounds 269, 575, 112, 24
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @This
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = "Cancel"
			.TabIndex = 33
			.Cancel = True
			.SetBounds 399, 575, 112, 24
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frmAiOptions As frmAiOptionsType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmAiOptions.MainForm = True
		frmAiOptions.Show
		App.Run
	#endif
'#End Region

Private Sub frmAiOptionsType.CommandButton_Click(ByRef Sender As Control)
	Select Case Sender.Name
	Case cmdOK.Name
		If Len (cboAIAgentProfile.Text) Then WLet(Ai.ProfileName, cboAIAgentProfile.Text)
		
		WLet(Ai.ModelName, cboModelName.Text)
		WLet(Ai.HTTPHost, cboHTTPHost.Text)
		WLet(Ai.ResourceAddress, cboResourceAddress.Text)
		Ai.HTTPPort = CLng(cboHTTPPort.Text)
		WLet(Ai.APIKey, cboAPIKey.Text)
		Ai.Stream = chkStream.Checked
		Ai.Temperature = CSng(txtTemperature.Text)
		
		WLet(Ai.LocContentStart, txtContentStart.Text)
		WLet(Ai.LocContentEnd, txtContentEnd.Text)
		WLet(Ai.LocContentSplit, txtContentSplit.Text)
		WLet(Ai.LocReasonStart, txtReasonStart.Text)
		WLet(Ai.LocReasonEnd, txtReasonEnd.Text)
		WLet(Ai.LocReasonSplit, txtReasonSplit.Text)
		
		WLet(Ai.TemplateHeader, txtHeader.Text)
		WLet(Ai.TemplateBody, txtBody.Text)
		WLet(Ai.TemplateAssistant, txtAssistant.Text)
		
		Ai.SetupInit()
		
		This.ModalResult = ModalResults.OK
	Case cmdCancel.Name
		This.ModalResult = ModalResults.Cancel
	End Select
	This.CloseForm
End Sub

Private Sub frmAiOptionsType.Form_Create(ByRef Sender As Control)
	cboAIAgentProfile.Text = *Ai.ProfileName
	cboModelName.Text = *Ai.ModelName
	cboHTTPHost.Text = *Ai.HTTPHost
	cboResourceAddress.Text = *Ai.ResourceAddress
	cboHTTPPort.Text = "" & Ai.HTTPPort
	cboAPIKey.Text = *Ai.APIKey
	txtTemperature.Text = Format(Ai.Temperature, "0.0")
	chkStream.Checked = Ai.Stream
	
	txtContentStart.Text = *Ai.LocContentStart
	txtContentEnd.Text = *Ai.LocContentEnd
	txtContentSplit.Text = *Ai.LocContentSplit
	txtReasonStart.Text = *Ai.LocReasonStart
	txtReasonEnd.Text = *Ai.LocReasonEnd
	txtReasonSplit.Text = *Ai.LocReasonSplit
	
	txtHeader.Text = *Ai.TemplateHeader
	txtBody.Text = *Ai.TemplateBody
	txtAssistant.Text = *Ai.TemplateAssistant
	
	cmdProfile_Click(cmdRefresh)
	cboAIAgentProfile_Selected(cboAIAgentProfile, 0)
End Sub

Private Sub frmAiOptionsType.cmdProfile_Click(ByRef Sender As Control)
	Select Case Sender.Name
	Case "cmdRefresh"
		DirToComlst(cboAIAgentProfile, ExePath, ".profile")
	Case "cmdSave"
		If Len(cboAIAgentProfile.Text) = 0 Then Exit Sub
		Dim As WString Ptr tt(), ss(), t, f
		WLet(f, ExePath & "\" & cboAIAgentProfile.Text & ".profile")
		
		If Len(Dir(*f)) > 0 And Sender.Tag = NULL Then
			If MsgBox(!"The file already exists, do you want to overwrite it?\r\n" & *f, "Overwrite confirm", MessageType.mtQuestion, ButtonsTypes.btYesNo) <> MessageResult.mrYes Then
				Deallocate(f)
				Exit Sub
			End If
		End If
		
		ReDim tt(11), ss(2)
		
		WLet(tt(0), TextFromComlst(cboModelName, !"\r\n", True))
		WLet(tt(1), TextFromComlst(cboHTTPHost, !"\r\n", True))
		WLet(tt(2), TextFromComlst(cboResourceAddress, !"\r\n", True))
		WLet(tt(3), TextFromComlst(cboHTTPPort, !"\r\n", True))
		
		WLet(tt(4), txtTemperature.Text)
		WLet(tt(5), "" & chkStream.Checked)
		
		WLet(tt(6), TextFromComlst(cboAPIKey, !"\r\n", True))
		
		WLet(tt(7), txtHeader.Text)
		WLet(tt(8), txtBody.Text)
		WLet(tt(9), txtAssistant.Text)
		
		WLet(ss(0), txtContentStart.Text)
		WLet(ss(1), txtContentEnd.Text)
		WLet(ss(2), txtContentSplit.Text)
		JoinWStr(ss(), !"\r\n", tt(10))
		
		WLet(ss(0), txtReasonStart.Text)
		WLet(ss(1), txtReasonEnd.Text)
		WLet(ss(2), txtReasonSplit.Text)
		JoinWStr(ss(), !"\r\n", tt(11))
		
		JoinWStr(tt(), !"\r\n{split}\r\n", t)
		TextToFile(*f, *t)
		
		ArrayDeallocate(tt())
		ArrayDeallocate(ss())
		Deallocate(t)
		Deallocate(f)
		
		cmdProfile_Click(cmdRefresh)
	Case "cmdDelete"
		If Len(cboAIAgentProfile.Text) = 0 Then Exit Sub
		Dim As WString Ptr f
		WLet(f, ExePath & "\" & cboAIAgentProfile.Text & ".profile")
		If Len(Dir(*f)) And Sender.Tag = NULL Then
			If MsgBox(!"Are you sure to delete the file?\r\n" & *f, "Delete confirm", MessageType.mtQuestion, ButtonsTypes.btYesNo) <> MessageResult.mrYes Then
				Deallocate(f)
				Exit Sub
			End If
		End If
		Kill(*f)
		Deallocate(f)
		cmdProfile_Click(cmdRefresh)
	End Select
End Sub

Private Sub frmAiOptionsType.cboAIAgentProfile_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	Dim As WString Ptr f
	WLet(f, ExePath & "\" & cboAIAgentProfile.Text & ".profile")
	If Len(Dir(*f)) = 0 Then
		Deallocate(f)
		Exit Sub
	End If
	
	Dim As WString Ptr t
	TextFromFile(*f, t)
	
	Dim As WString Ptr tt(), ss()
	Dim As Integer i, j, k
	j = SplitWStr(*t, !"\r\n{split}\r\n", tt())
	
	If j < 11 Then ReDim Preserve tt(11)
	
	TextToComlst(cboModelName, *tt(0), !"\r\n", True)
	TextToComlst(cboHTTPHost, *tt(1), !"\r\n", True)
	TextToComlst(cboResourceAddress, *tt(2), !"\r\n", True)
	TextToComlst(cboHTTPPort, *tt(3), !"\r\n", True)
	
	txtTemperature.Text = *tt(4)
	chkStream.Checked = CBool(*tt(5))
	
	TextToComlst(cboAPIKey, *tt(6), !"\r\n", True)
	
	txtHeader.Text = *tt(7)
	txtBody.Text = *tt(8)
	txtAssistant.Text = *tt(9)
	
	k = SplitWStr(*tt(10), !"\r\n", ss())
	txtContentStart.Text = *ss(0)
	txtContentEnd.Text = *ss(1)
	txtContentSplit.Text = *ss(2)
	k = SplitWStr(*tt(11), !"\r\n", ss())
	txtReasonStart.Text = *ss(0)
	txtReasonEnd.Text = *ss(1)
	txtReasonSplit.Text = *ss(2)
	
	ArrayDeallocate(tt())
	ArrayDeallocate(ss())
	Deallocate(t)
	Deallocate(f)
End Sub

Private Sub frmAiOptionsType.ComboBoxEdit_DblClick(ByRef Sender As Control)
	Dim As ComboBoxEdit Ptr a = Cast(ComboBoxEdit Ptr, @Sender)
	frmEdit.Caption = Sender.Name
	frmEdit.TextBox1.Text = TextFromComlst(*a, vbCrLf)
	frmEdit.ShowModal(This)
	If frmEdit.ModalResult = ModalResults.OK Then
		TextToComlst(*a, frmEdit.TextBox1.Text, vbCrLf)
	End If
End Sub
