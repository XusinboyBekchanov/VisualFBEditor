'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/RichTextBox.bi"
	#include once "mff/Splitter.bi"
	#include once "mff/HTTP.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Panel.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/ListControl.bi"
	#include once "mff/Menus.bi"
	#include once "../MDINotepad/Text.bi"
	
	#include once "vbcompat.bi"
	#include once "AiAgent.bi"
	
	Using My.Sys.Forms
	
	Dim Shared Ai As AiAgent
	
	Type frmAiAgentType Extends Form
		Declare Static Sub OnStream(ByRef mOwner As Any Ptr,ByRef Index As Integer, ByRef Reason As WString Ptr, ByRef Content As WString Ptr)
		Declare Static Sub OnDone(ByRef mOwner As Any Ptr, ByRef Reason As WString Ptr, ByRef Content As WString Ptr)
		
		Declare Sub ComboBoxEdit_DblClick(ByRef Sender As Control)
		Declare Sub ComboBoxEdit_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub CommandButton_Click(ByRef Sender As Control)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Menu_Click(ByRef Sender As MenuItem)
		Declare Sub txtHistory_Click(ByRef Sender As Control)
		Declare Sub txtHistory_KeyUp(ByRef Sender As Control, Key As Integer, Shift As Integer)
		Declare Constructor
		
		Dim As RichTextBox txtAIAgent
		Dim As TextBox txtAIRequest, txtLog, txtHistory
		Dim As Panel PanelLeftBottom, PanelRight, PanelLeft, PanelRightBottom
		Dim As CommandButton cmdOptions, cmdNew, cmdAI
		Dim As ComboBoxEdit cboQuestion
		Dim As Splitter Splitter1, Splitter2, Splitter3
		Dim As PopupMenu PopupMenu1
		Dim As MenuItem mnuDark, mnuLogRealTime
	End Type
	
	Constructor frmAiAgentType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = My.Sys.Language
			End With
		#endif
		' frmAiAgent
		With This
			.Name = "frmAiAgent"
			.Text = "Ai Agent Rich"
			.Designer = @This
			.Caption = "Ai Agent Rich"
			.StartPosition = FormStartPosition.CenterScreen
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.SetBounds 0, 0, 615, 500
		End With
		' PanelLeft
		With PanelLeft
			.Name = "PanelLeft"
			.Text = "Panel3"
			.TabIndex = 0
			.Align = DockStyle.alLeft
			.ExtraMargins.Left = 10
			.ExtraMargins.Right = 0
			.ExtraMargins.Top = 10
			.SetBounds 10, 10, 180, 451
			.Designer = @This
			.Parent = @This
		End With
		' txtHistory
		With txtHistory
			.Name = "txtHistory"
			.Text = "txtHistory"
			.TabIndex = 1
			.Multiline = True
			.ScrollBars = ScrollBarsType.Both
			.Align = DockStyle.alTop
			.WordWraps = True
			.ReadOnly = True
			.Hint = "History"
			.SetBounds 0, 0, 180, 91
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @txtHistory_Click)
			.OnKeyUp = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer), @txtHistory_KeyUp)
			.Parent = @PanelLeft
		End With
		' Splitter3
		With Splitter3
			.Name = "Splitter3"
			.Text = "Splitter3"
			.Align = SplitterAlignmentConstants.alTop
			.SetBounds 0, 161, 174, 10
			.Designer = @This
			.Parent = @PanelLeft
		End With
		' txtLog
		With txtLog
			.Name = "txtLog"
			.Text = "txtLog"
			.TabIndex = 3
			.Align = DockStyle.alClient
			.WordWraps = True
			.Multiline = True
			.ScrollBars = ScrollBarsType.Vertical
			.MaxLength = -1
			.Hint = "Log"
			.ID = 1925
			.ControlIndex = 3
			.ReadOnly = True
			.SetBounds 0, 101, 180, 310
			.Designer = @This
			.Parent = @PanelLeft
		End With
		' Splitter1
		With Splitter1
			.Name = "Splitter1"
			.Text = "Splitter1"
			.Align = SplitterAlignmentConstants.alLeft
			.SetBounds 184, 0, 10, 421
			.Designer = @This
			.Parent = @This
		End With
		' PanelLeftBottom
		With PanelLeftBottom
			.Name = "PanelLeftBottom"
			.Text = "Panel1"
			.TabIndex = 4
			.Align = DockStyle.alBottom
			.ContextMenu = @PopupMenu1
			.SetBounds 0, 411, 180, 40
			.Designer = @This
			.Parent = @PanelLeft
		End With
		' cmdNew
		With cmdNew
			.Name = "cmdNew"
			.Text = "New"
			.TabIndex = 5
			.Caption = "New"
			.SetBounds 0, 10, 50, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @PanelLeftBottom
		End With
		' cmdOptions
		With cmdOptions
			.Name = "cmdOptions"
			.Text = "OpenRouter"
			.TabIndex = 6
			.Caption = "OpenRouter"
			.Enabled = True
			.Hint = "Options"
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.SetBounds 60, 10, 120, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @PanelLeftBottom
		End With
		' PanelRight
		With PanelRight
			.Name = "PanelRight"
			.Text = "Panel2"
			.TabIndex = 7
			.Align = DockStyle.alClient
			.ExtraMargins.Left = 0
			.ExtraMargins.Right = 10
			.ExtraMargins.Top = 10
			.SetBounds 377, 0, 207, 421
			.Designer = @This
			.Parent = @This
		End With
		' txtAIAgent
		With txtAIAgent
			.Name = "txtAIAgent"
			.Text = "AI Agent"
			.TabIndex = 8
			.Align = DockStyle.alTop
			.Multiline = True
			.WordWraps = True
			.ScrollBars = ScrollBarsType.Vertical
			.ReadOnly = True
			.MaxLength = -1
			.Hint = "Concent"
			.ControlIndex = 3
			.SetBounds 0, 0, 384, 287
			.Designer = @This
			.Parent = @PanelRight
		End With
		' Splitter2
		With Splitter2
			.Name = "Splitter2"
			.Text = "Splitter2"
			.Align = SplitterAlignmentConstants.alTop
			.SetBounds 0, 247, 397, 10
			.Designer = @This
			.Parent = @PanelRight
		End With
		' txtAIRequest
		With txtAIRequest
			.Name = "txtAIRequest"
			.Text = "txtAIRequest"
			.TabIndex = 9
			.Align = DockStyle.alClient
			.Multiline = True
			.WordWraps = True
			.ScrollBars = ScrollBarsType.Vertical
			.MaxLength = -1
			.Hint = "Request"
			.SetBounds 220, -10, 354, 51
			.Designer = @This
			.Parent = @PanelRight
		End With
		' PanelRightBottom
		With PanelRightBottom
			.Name = "PanelRightBottom"
			.Text = "PanelRightBottom"
			.TabIndex = 10
			.Align = DockStyle.alBottom
			.ControlIndex = 3
			.ContextMenu = @PopupMenu1
			.SetBounds 0, 411, 389, 40
			.Designer = @This
			.Parent = @PanelRight
		End With
		' cboQuestion
		With cboQuestion
			.Name = "cboQuestion"
			.Text = ""
			.TabIndex = 11
			.Style = ComboBoxEditStyle.cbDropDown
			.Anchor.Right = AnchorStyle.asAnchor
			.Anchor.Left = AnchorStyle.asAnchor
			.SetBounds 0, 10, 260, 21
			.Designer = @This
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @ComboBoxEdit_Selected)
			.OnDblClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @ComboBoxEdit_DblClick)
			.Parent = @PanelRightBottom
		End With
		' cmdAI
		With cmdAI
			.Name = "cmdAI"
			.Text = "AI"
			.TabIndex = 12
			.Caption = "AI"
			.Anchor.Right = AnchorStyle.asAnchor
			.SetBounds 270, 10, 120, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @PanelRightBottom
		End With
		' PopupMenu1
		With PopupMenu1
			.Name = "PopupMenu1"
			.SetBounds 0, 390, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' mnuDark
		With mnuDark
			.Name = "mnuDark"
			.Designer = @This
			.Caption = "Dark"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @Menu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuLogRealTime
		With mnuLogRealTime
			.Name = "mnuLogRealTime"
			.Designer = @This
			.Caption = "Log real time"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @Menu_Click)
			.Parent = @PopupMenu1
		End With
	End Constructor
	
	Dim Shared frmAiAgent As frmAiAgentType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmAiAgent.MainForm = True
		frmAiAgent.Show
		App.Run
	#endif
'#End Region

#include once "frmEdit.frm"
#include once "frmAIOptions.frm"

Private Sub frmAiAgentType.Form_Create(ByRef Sender As Control)
	Ai.Owner = @This
	Ai.OnStream = Cast(Sub(ByRef mOwner As Any Ptr, ByRef Index As Integer, ByRef Reason As WString Ptr, ByRef Content As WString Ptr), @OnStream)
	Ai.OnDone= Cast(Sub(ByRef mOwner As Any Ptr, ByRef Reason As WString Ptr, ByRef Content As WString Ptr), @OnDone)
	
	'load setting
	Dim As WString Ptr f
	Dim As WString Ptr t, tt()
	Dim As Integer i, j
	Dim As Boolean def = True
	WLet(f, ExePath & "\" & "AiAgent.ini")
	If Len(Dir(*f)) Then
		TextFromFile(*f, t)
		j = SplitWStr(*t, vbCrLf, tt())
		If j > -1 Then
			If Len(*tt(0)) Then WLet(Ai.ProfileName, *tt(0))
		End If
	End If
	
	WLet(f, ExePath & "\" & "AiQuestion.ini")
	With cboQuestion
		If Len(Dir(*f)) Then
			TextFromFile(*f, t)
			TextToComlst(cboQuestion, *t, vbCrLf, True)
			def = False
		End If
		If def Then
			.AddItem "介绍一下你自己"
			.AddItem "Introduce yourself"
			.AddItem "介绍国产CPU的发展历程和状态"
			.AddItem "详细介绍国产CPU的发展历程和现状"
			.AddItem "详细介绍国产CPU的技术类型, 支持的操作系统和具体应用场景"
			.AddItem "写一段freebasic代码,并解释其作用"
			.AddItem "写一段c++代码,并解释其作用"
			.AddItem "写一段windows的批处理脚本,并解释其作用"
			.AddItem "写一段linux的脚本,并解释其作用"
			.AddItem "介绍佛山顺德的美食"
			.AddItem "介绍云南的风景"
			.AddItem "介绍中国茶叶"
			.AddItem "介绍云南的茶叶"
			.AddItem "介绍安溪的铁观音"
			.AddItem "介绍龙井茶"
			.AddItem "介绍潮州凤凰单从茶"
			.AddItem "历史上" & Format(Now, "m") & "月" & Format(Now, "d") & "日这天发生过什么重大事情"
			.AddItem "今天" & Format(Now, "m") & "月" & Format(Now, "d") & "日是什么星座需要注意什么事情"
			.AddItem "佛山顺德今天的天气"
			.AddItem "把回答转换成简体中文"
			.AddItem "把回答转换成繁体中文"
			.AddItem "把回答翻译成中文"
			.AddItem "把回答翻译成英语"
			.AddItem "把回答翻译成越南语"
			.AddItem "将下面的中文翻译成越南语:\r\n"
			.AddItem "将下面的越南语翻译成中文:\r\n"
			.AddItem "将下面的文字转换成简体中文:\r\n"
			.AddItem "将下面的文字转换成繁体中文:\r\n"
		End If
	End With
	
	Deallocate(f)
	Deallocate(t)
	ArrayDeallocate(tt())

	cmdOptions.Caption = *Ai.ProfileName
	frmAiOptions.cboAIAgentProfile.Text = *Ai.ProfileName
	frmAiOptions.Form_Create(frmAiOptions)
	frmAiOptions.cboAIAgentProfile_Selected(frmAiOptions.cboAIAgentProfile, 0)
	frmAiOptions.CommandButton_Click(frmAiOptions.cmdOK)
	
	CommandButton_Click(cmdNew)
	txtAIAgent.SetFocus
End Sub

Private Sub frmAiAgentType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	Dim As WString Ptr f
	
	WLet(f, ExePath & "\" & "AiAgent.ini")
	If Len(Dir(*f)) Then Kill(*f)
	Dim As WString Ptr t, tt()
	Dim As Integer i, j
	ReDim tt(0)
	WLet(tt(0), *Ai.ProfileName)
	JoinWStr(tt(), vbCrLf, t)
	TextToFile(*f, *t)
	
	ArrayDeallocate(tt())
	
	WLet(f, ExePath & "\" & "AiQuestion.ini")
	If Len(Dir(*f)) Then Kill(*f)
	WLet(t, TextFromComlst(cboQuestion, vbCrLf, True))
	TextToFile(*f, *t)
	
	Deallocate(f)
	Deallocate(t)
	ArrayDeallocate(tt())
End Sub

Private Sub frmAiAgentType.OnDone(ByRef mOwner As Any Ptr, ByRef Reason As WString Ptr, ByRef Content As WString Ptr)
	Dim As frmAiAgentType Ptr a = Cast(frmAiAgentType Ptr, mOwner)
	a->cmdAI.Caption = "AI"
	
	a->txtAIAgent.Clear
	AIDisplayText(a->txtAIAgent, !"<AI Request>\r\n" & Json2WStr(*Ai.AiQuestion) & !"\r\n\r\n")
	If Reason Then
		AIDisplayText(a->txtAIAgent, !"<Reason>\r\n")
		AIDisplayText(a->txtAIAgent, *Reason)
	End If
	If Content Then
		AIDisplayText(a->txtAIAgent, !"\r\n\r\n<Content>\r\n")
		AIDisplayText(a->txtAIAgent, *Content)
	End If
	
	Dim As Integer i = 20, j = Len(*Ai.HistoryQuestionA(Ai.HistoryCount))
	If j > i Then
		a->txtHistory.AddLine(..Left(*Ai.HistoryQuestionA(Ai.HistoryCount), i) & "...")
	Else
		a->txtHistory.AddLine(*Ai.HistoryQuestionA(Ai.HistoryCount))
	End If
End Sub

Private Sub frmAiAgentType.OnStream(ByRef mOwner As Any Ptr, ByRef Index As Integer, ByRef Reason As WString Ptr, ByRef Content As WString Ptr)
	Dim As frmAiAgentType Ptr a = Cast(frmAiAgentType Ptr, mOwner)
	a->cmdAI.Caption = "Stream " & Index & " ..."
	Static As Integer ri, ci
	If Index = 0 Then
		ri = 0
		ci = 0
	End If
	
	'display stream
	If Reason Then
		If ri = 0 Then AIDisplayText(a->txtAIAgent, !"<Reason>\r\n")
		ri += 1
		AIDisplayText(a->txtAIAgent, *Reason)
	End If
	If Content Then
		If ci = 0 Then AIDisplayText(a->txtAIAgent, !"\r\n\r\n<Content>\r\n")
		ci += 1
		AIDisplayText(a->txtAIAgent, *Content)
	End If
	If a->mnuLogRealTime.Checked = False Then Exit Sub
	
	'log buffer real time
	Dim As Integer lenBuffer = Len(Ai.ResponceBufferStrA(Ai.ResponceCount))
	Dim As WString Ptr WStrBuffer = NULL
	TextFromUtf8(Ai.ResponceBufferStrA(Ai.ResponceCount), WStrBuffer)
	AIDisplayText(a->txtLog, *WStrBuffer)
	If WStrBuffer Then Deallocate WStrBuffer
End Sub

Private Sub frmAiAgentType.ComboBoxEdit_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	txtAIRequest.Text = Json2WStr(Sender.Text)
End Sub

Private Sub frmAiAgentType.CommandButton_Click(ByRef Sender As Control)
	Select Case Sender.Name
	Case cmdAI.Name
		If Ai.bThread Then Exit Sub
		If txtAIRequest.Text = "" Then Exit Sub
		
		Ai.RequestCreate(txtAIRequest.Text)
		txtLog.Clear
		txtAIAgent.Clear
		txtAIRequest.Clear
		AIDisplayText(txtAIAgent, !"<AI Request>\r\n" & Json2WStr(*Ai.AiQuestion) & !"\r\n\r\n")
		cmdAI.Caption = "Request..."
	Case cmdNew.Name
		Ai.RequestInit()
		Ai.HistoryClear()
		txtHistory.Clear
		txtAIAgent.Clear
		txtAIRequest.Clear
		txtLog.Clear
	Case cmdOptions.Name
		frmAiOptions.ShowModal(This)
		If frmAiOptions.ModalResult = ModalResults.OK Then cmdOptions.Caption = *Ai.ProfileName
	End Select
End Sub

Private Sub frmAiAgentType.txtHistory_Click(ByRef Sender As Control)
	Dim As Integer sy, sx, ey, ex
	txtHistory.GetSel(sy, sx, ey, ex)
	Dim As Integer i = sy
	If i < 0 Or i > Ai.HistoryCount Then Exit Sub
	
	'显示历史问题
	txtAIRequest.Text = Json2WStr(*Ai.HistoryQuestionA(i))
	
	'显示历史回答
	txtAIAgent.Clear
	AIDisplayText(txtAIAgent, !"<AI Request>\r\n" & Json2WStr(*Ai.HistoryQuestionA(i)) & !"\r\n\r\n")
	AIDisplayText(txtAIAgent, !"<Reason>\r\n")
	AIDisplayText(txtAIAgent, *Ai.HistoryReasonA(i))
	AIDisplayText(txtAIAgent, !"\r\n\r\n<Content>\r\n")
	AIDisplayText(txtAIAgent, *Ai.HistoryContentA(i))
	
	'显示历史log
	txtLog.Clear
	AIDisplayText(txtLog, *Ai.HistoryA(i))
	AIDisplayText(txtLog, !"<Header>\r\n" & *Ai.RequestHeaderA(i))
	AIDisplayText(txtLog, "\r\n<Body>\r\n" & *Ai.RequestBodyA(i))
	AIDisplayText(txtLog, !"\r\n<Buffer>\r\n" & *Ai.ResponceBufferA(i))
End Sub

Private Sub frmAiAgentType.txtHistory_KeyUp(ByRef Sender As Control, Key As Integer, Shift As Integer)
	txtHistory_Click(txtHistory)
End Sub

Private Sub frmAiAgentType.ComboBoxEdit_DblClick(ByRef Sender As Control)
	Dim As ComboBoxEdit Ptr a = Cast(ComboBoxEdit Ptr, @Sender)
	frmEdit.Caption = Sender.Name
	frmEdit.TextBox1.Text = TextFromComlst(*a, vbCrLf)
	frmEdit.ShowModal(This)
	If frmEdit.ModalResult = ModalResults.OK Then
		TextToComlst(*a, frmEdit.TextBox1.Text, vbCrLf)
	End If
End Sub

Private Sub frmAiAgentType.Menu_Click(ByRef Sender As MenuItem)
	Select Case Sender.Name
	Case "mnuLogRealTime"
		Sender.Checked = Not Sender.Checked
	Case "mnuDark"
		Sender.Checked = Not Sender.Checked
		App.DarkMode = Sender.Checked
		InvalidateRect(Handle, NULL, False)
	End Select
End Sub

