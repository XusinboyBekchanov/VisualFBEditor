'#########################################################
'#  AIChatView.bas                                       #
'#  This file is part of VisualFBEditor                  #
'#########################################################

'The views of the chat of the AI Agent. The chat is the markdown text of AIChatMD (the questions and the answers as
'they come, AIChatFeed). One of the views shows it (the menu of the chat, View; Options, AIChatView of the ini file):
'  0 - RTF: the RichTextBox txtAIAgent, MarkdownStreamConverter makes RTF of the markdown (as before)
'  1 - WebBrowser: HTML in WebView2 of Edge, WebView2Loader.dll is loaded when the view is chosen (the IDE starts
'      without it)
'  2 - IE: HTML in the WebBrowser control of Internet Explorer
'  3 - The own control of the IDE: the chat is drawn with GDI+ (the shapes) and GDI (the texts), like the editor
'  4 - The own control drawn with Direct2D, the texts with DirectWrite (the emojis in their colors)
'The views 1-4 are drawn by a timer of the thread of the windows (AIChatTimerProc): the threads of the requests only
'add the text, the COM objects of WebView2 and IE can only be used by the thread which made them. A drawing replaces
'only the last message of the view (it grows while the answer comes) and adds the new ones.

#ifdef __USE_WINAPI__
	#define WEBVIEW2_DYNAMIC
	#include once "mff/WebView/WebView2.bi"
	#include once "mff/WebBrowser.bi"
	#include once "win/mshtml.bi"
	#include once "mff/D2D1/D2D1_MFF.bi"
#elseif defined(__USE_GTK__)
	'The scroll bar of the own control
	#include once "mff/VScrollBar.bi"
#endif

'Main.bas: Opus 5.5 of claude-opus-5-5 (and of the alias opus)
Declare Function AIClaudeModelTitle(ByRef ID As String) As String

Enum AIChatViewModes
	acvRTF = 0
	acvWebView2 = 1
	acvIE = 2
	acvCustom = 3
	acvD2D = 4
End Enum

Dim Shared As Integer AIChatViewMode
'The markdown of the chat, its mutex (the threads of the requests add to it)
Dim Shared As WString Ptr AIChatMD
Dim Shared As Integer AIChatMDCapacity
Dim Shared As Any Ptr AIChatMDMutex
'AIChatViewDirty: the text was added after the last drawing; AIChatNeedFull: the view is drawn again from the start
Dim Shared As Boolean AIChatViewDirty, AIChatNeedFull = True
'The messages of the view (the last one is replaced by the next drawing) and the start (1-based) of the last one in
'AIChatMD
Dim Shared As Integer AIChatShownMsgs, AIChatLastMsgPos = 1
'The selected text of the view when its menu was opened (the code block or the message under the mouse in the own
'control)
Dim Shared As UString AIChatViewSelection
Dim Shared As Panel pnlAIView, pnlAIWebView2
Dim Shared As MenuItem Ptr miAIChatView(4)

Type AIChatMessage
	IsUser As Boolean
	Header As UString
	Body As UString
	StartPos As Integer
End Type

'The colors of the views (&HRRGGBB)
Type AIChatColors
	Back As ULong
	Fore As ULong
	Muted As ULong
	Bubble As ULong
	CodeBack As ULong
	Border As ULong
	Link As ULong
End Type

Function AIChatIsDark() As Boolean
	#ifdef __USE_WINAPI__
		Return g_darkModeSupported AndAlso g_darkModeEnabled
	#elseif defined(__USE_GTK__) AndAlso Not defined(__USE_GTK2__)
		'A light text of the theme is a dark theme
		If frmMain.Handle = 0 Then Return g_darkModeEnabled
		Dim As GdkRGBA FgColor
		#ifdef __USE_GTK4__
			gtk4compat_widget_get_color(frmMain.Handle, @FgColor)
		#else
			gtk_style_context_get_color(gtk_widget_get_style_context(frmMain.Handle), GTK_STATE_FLAG_NORMAL, @FgColor)
		#endif
		Return FgColor.red * 0.299 + FgColor.green * 0.587 + FgColor.blue * 0.114 > 0.5
	#else
		Return False
	#endif
End Function

Function AIChatPalette() As AIChatColors
	Dim As AIChatColors C
	If AIChatIsDark() Then
		C.Back = &H262624: C.Fore = &HE8E6E3: C.Muted = &H9C9A94: C.Bubble = &H3A3A37
		C.CodeBack = &H1E1E1C: C.Border = &H46463F: C.Link = &H7AA7F0
	Else
		C.Back = &HFFFFFF: C.Fore = &H1F1F1F: C.Muted = &H6E6E6E: C.Bubble = &HF0EEE8
		C.CodeBack = &HF6F6F4: C.Border = &HDCDCD8: C.Link = &H1E64C8
	End If
	Return C
End Function

Function AIChatCssColor(C As ULong) As String
	Return "#" & Hex(C And &HFFFFFF, 6)
End Function

' ==========================================
' The text of the chat
' ==========================================

'Adds the text to the chat (from any thread)
Declare Function AIChatAgentTitle(ByRef Key As WString) As UString
Declare Function AIToolBlockRTF(ByRef Chunk As WString) As UString

'The text for the RTF view: the names of the agents of the answers as in the other views (Opus 5.5 · Claude Code)
Function AIChatRTFText(ByRef Text As WString) As UString
	Const AR = "[**AI Response:**]"
	If InStr(Text, AR) = 0 Then Return Text
	Dim As UString Result
	Dim As Integer P = 1, PM, LineEnd
	Do
		PM = InStr(P, Text, AR)
		If PM = 0 Then Exit Do
		LineEnd = InStr(PM, Text, !"\n")
		If LineEnd = 0 Then LineEnd = Len(Text) + 1
		If PM = 1 OrElse Text[PM - 2] = 10 Then
			Result &= Mid(Text, P, PM - P) & AR & " " & AIChatAgentTitle(Trim(Mid(Text, PM + Len(AR), LineEnd - PM - Len(AR)), Any !" \r\t"))
		Else
			Result &= Mid(Text, P, LineEnd - P)
		End If
		P = LineEnd
	Loop
	Return Result & Mid(Text, P)
End Function

Sub AIChatFeed(ByRef Chunk As WString)
	If Len(Chunk) = 0 Then Exit Sub
	MutexLock AIChatMDMutex
	WAdd(AIChatMD, Chunk, , AIChatMDCapacity)
	AIChatViewDirty = True
	MutexUnlock AIChatMDMutex
	If AIChatViewMode = acvRTF AndAlso AIMDtoRTFConverterPtr <> 0 Then
		If Left(Chunk, 8) = !"\n~~~vfb-" Then
			'The input or the result of a call of a tool: a code block
			Dim As UString RTFText = AIToolBlockRTF(Chunk)
			If RTFText <> "" Then AIMDtoRTFConverterPtr->FeedChunk(RTFText)
		Else
			AIMDtoRTFConverterPtr->FeedChunk(AIChatRTFText(Chunk))
		End If
	End If
End Sub

'The chat as it is shown (the questions, the answers with the calls of the tools and their results, thinking) is
'saved in <chat>.md.view: the file of the chat has only the questions and the answers (the context of the agents)
Sub AIChatSaveView(ByRef ChatFile As WString)
	Dim As UString MD
	MutexLock AIChatMDMutex
	If AIChatMD <> 0 Then MD = *AIChatMD
	MutexUnlock AIChatMDMutex
	If InStr(MD, WChr(8594) & " ") = 0 AndAlso InStr(MD, "<think>") = 0 Then Exit Sub
	SaveToFile(ChatFile & ".view", MD)
End Sub

'Shows the saved view of an opened chat (False: it has none, the chat is shown from its questions and answers)
Function AIChatLoadView(ByRef ChatFile As WString) As Boolean
	If AIChatViewMode = acvRTF OrElse Not FileExists(ChatFile & ".view") Then Return False
	Dim As WString Ptr pText = LoadFromFile(ChatFile & ".view")
	If pText = 0 Then Return False
	Dim As UString Text = Replace(*pText, Chr(13), "")
	_Deallocate(pText)
	If Trim(Text, Any !" \r\n\t") = "" Then Return False
	AIChatFeed(Text)
	Return True
End Function

'The chat becomes empty (a new chat, a chat opened from a file)
Sub AIChatReset()
	MutexLock AIChatMDMutex
	If AIChatMD Then _Deallocate(AIChatMD)
	AIChatMD = 0: AIChatMDCapacity = 0
	AIChatNeedFull = True: AIChatViewDirty = True
	MutexUnlock AIChatMDMutex
	If AIMDtoRTFConverterPtr <> 0 Then AIMDtoRTFConverterPtr->Initial(*EditorFontName, EditorFontSize, 9)
	txtAIAgent.TextRTF = ""
End Sub

'The text of the chat: the text of the RichTextBox (RTF view) or the markdown
Function AIChatText() As UString
	If AIChatViewMode = acvRTF Then Return txtAIAgent.Text
	Dim As UString Result
	MutexLock AIChatMDMutex
	If AIChatMD Then Result = *AIChatMD
	MutexUnlock AIChatMDMutex
	Return Result
End Function

'The start (1-based) of the marker at the start of a line from Start (0: none)
Function AIChatFindMarker(ByRef Text As WString, ByRef Marker As WString, Start As Integer) As Integer
	Dim As Integer P = Start
	Do
		P = InStr(P, Text, Marker)
		If P = 0 Then Return 0
		If P = 1 OrElse Text[P - 2] = 10 Then Return P
		P += 1
	Loop
End Function

'The name of the agent of an answer: "opus|Claude Code" -> "Opus 5.5 · Claude Code", "deepseek-v3|Silicon" -> "deepseek-v3 · Silicon"
Function AIChatAgentTitle(ByRef Key As WString) As UString
	Dim As Integer p = InStrRev(Key, "|")
	If p = 0 Then Return Key
	Dim As UString ModelPart = Trim(Left(Key, p - 1)), ProviderPart = Trim(Mid(Key, p + 1))
	Dim As String ModelID = ModelPart, LM = LCase(ModelID)
	If InStr(LCase(ProviderPart), "claude") > 0 OrElse Left(LM, 7) = "claude-" OrElse LM = "opus" OrElse LM = "sonnet" OrElse LM = "haiku" OrElse LM = "fable" Then
		Dim As UString Title = AIClaudeModelTitle(ModelID)
		If ProviderPart = "" Then Return Title
		Return Title & " " & WChr(183) & " " & ProviderPart
	End If
	Return AIAgentShortName(Key)
End Function

'The messages of Text (the questions and the answers by their markers); Offset is the start of Text in AIChatMD
Function AIChatSplitMessages(ByRef Text As WString, Offset As Integer, Msgs() As AIChatMessage) As Integer
	Const UQ = "[**User Question:**]", AR = "[**AI Response:**]"
	Dim As Integer Count, P = 1, TextLen = Len(Text), BodyStart = 1, CurStart = 1, PU, PA, PM, MarkerLen, LineEnd, BodyEnd
	Dim As Boolean CurUser, HasCur, NextUser
	Dim As UString CurHeader
	Erase Msgs
	Do
		PU = AIChatFindMarker(Text, UQ, P)
		PA = AIChatFindMarker(Text, AR, P)
		PM = 0
		If PU > 0 AndAlso (PA = 0 OrElse PU < PA) Then
			PM = PU: NextUser = True: MarkerLen = Len(UQ)
		ElseIf PA > 0 Then
			PM = PA: NextUser = False: MarkerLen = Len(AR)
		End If
		BodyEnd = IIf(PM > 0, PM - 1, TextLen)
		If HasCur OrElse Trim(Mid(Text, BodyStart, BodyEnd - BodyStart + 1), Any !" \r\n\t") <> "" Then
			ReDim Preserve Msgs(Count)
			Msgs(Count).IsUser = CurUser
			If CurUser Then Msgs(Count).Header = CurHeader Else Msgs(Count).Header = AIChatAgentTitle(CurHeader)
			Msgs(Count).Body = Mid(Text, BodyStart, BodyEnd - BodyStart + 1)
			Msgs(Count).StartPos = CurStart + Offset - 1
			Count += 1
		End If
		If PM = 0 Then Exit Do
		LineEnd = InStr(PM, Text, !"\n")
		If LineEnd = 0 Then LineEnd = TextLen + 1
		CurHeader = Trim(Mid(Text, PM + MarkerLen, LineEnd - PM - MarkerLen), Any !" \r\t")
		CurUser = NextUser: HasCur = True: CurStart = PM: BodyStart = LineEnd + 1
		P = LineEnd
	Loop
	Return Count
End Function

Dim Shared As Double AIChatBusyStart
Declare Function AITaskList(ByRef Body As WString) As UString
Declare Function AIRunningTool(ByRef Body As WString) As UString
Declare Function AIElapsedText(Seconds As Double) As UString
'The messages to draw: from the last message of the view or from the start (Full); returns the index of the first one
Function AIChatTakeMessages(Msgs() As AIChatMessage, ByRef Count As Integer, ByRef Full As Boolean) As Integer
	Dim As UString Part
	MutexLock AIChatMDMutex
	Full = AIChatNeedFull
	If Full Then AIChatShownMsgs = 0: AIChatLastMsgPos = 1
	If AIChatMD Then Part = Mid(*AIChatMD, AIChatLastMsgPos)
	AIChatViewDirty = False: AIChatNeedFull = False
	MutexUnlock AIChatMDMutex
	Count = AIChatSplitMessages(Part, AIChatLastMsgPos, Msgs())
	Dim As Integer First = IIf(Full, 0, Max(0, AIChatShownMsgs - 1))
	If Count > 0 Then
		AIChatLastMsgPos = Msgs(Count - 1).StartPos
		AIChatShownMsgs = First + Count
	End If
	'The tasks of the answers (as the list of Claude Code), the state of the answer which comes
	Dim As UString Tasks, Running
	For k As Integer = 0 To Count - 1
		If Msgs(k).IsUser Then Continue For
		Tasks = AITaskList(Msgs(k).Body)
		If Tasks <> "" Then Msgs(k).Body &= !"\n\n~~~vfb-tasks\n" & Tasks & !"~~~vfb-end tasks\n"
		If k = Count - 1 AndAlso bInAIThread Then
			If AIChatBusyStart = 0 Then AIChatBusyStart = Timer
			Running = ""
			'The task which runs, else the call of a tool which runs
			Dim As Integer P = InStr(Tasks, "in_progress|")
			If P = 1 OrElse (P > 1 AndAlso Tasks[P - 2] = 10) Then
				Running = Mid(Tasks, P + 12, InStr(P, Tasks, !"\n") - P - 12)
			Else
				Running = AIRunningTool(Msgs(k).Body)
			End If
			If Running = "" Then Running = ML("Working")
			Msgs(k).Body &= !"\n\n~~~vfb-status " & Running & " " & WChr(183) & " " & AIElapsedText(Timer - AIChatBusyStart) & !"\n"
		End If
	Next
	Return First
End Function

'The elapsed time: 45 s, 3 min 5 s, 1 h 2 min
Function AIElapsedText(Seconds As Double) As UString
	Dim As Integer S = Int(Max(Seconds, 0))
	If S < 60 Then Return Str(S) & " " & ML("s")
	If S < 3600 Then Return Str(S \ 60) & " " & ML("min") & " " & Str(S Mod 60) & " " & ML("s")
	Return Str(S \ 3600) & " " & ML("h") & " " & Str((S Mod 3600) \ 60) & " " & ML("min")
End Function


'True when the view is drawn again for the state of the answer (each second while it comes, once after it)
Function AIChatStatusTick() As Boolean
	Static As Integer LastSec = -1
	Static As Boolean WasBusy
	If bInAIThread Then
		WasBusy = True
		If Int(Timer) <> LastSec Then LastSec = Int(Timer): Return True
		Return False
	End If
	AIChatBusyStart = 0
	If WasBusy Then WasBusy = False: Return True
	Return False
End Function

'The last code block of the chat
Function AIChatLastCode() As UString
	Dim As UString Text = AIChatText()
	Dim As Integer P2 = InStrRev(Text, "```")
	If P2 < 2 Then Return ""
	Dim As Integer P1 = InStrRev(Text, "```", P2 - 1)
	If P1 < 1 Then Return ""
	Dim As Integer LineEnd = InStr(P1, Text, !"\n")
	If LineEnd = 0 OrElse LineEnd > P2 Then Return ""
	Return Mid(Text, LineEnd + 1, P2 - LineEnd - 1)
End Function

' ==========================================
' Markdown: the blocks and the styles of the texts
' ==========================================

Enum AIBlockKinds
	abPara = 1
	abHead
	abItem
	abCode
	abTable
	abQuote
	abRule
	abFold
	abImage
	'The tasks of Claude Code (the lines status|text), the state of the answer while it comes
	abTasks
	abStatus
End Enum

Type AIBlock
	Kind As Integer
	'The level of a heading, the indent of an item of a list, the number of the calls of the tools (FoldKind 2)
	Level As Integer
	'The marker of an item of a list, the text of a picture
	Marker As UString
	Text As UString
	Lang As UString
	'1 - thinking, 2 - the calls of the tools
	FoldKind As Integer
	Closed As Boolean
End Type

'The styles of a text
Const AIS_BOLD = 1, AIS_ITALIC = 2, AIS_CODE = 4, AIS_LINK = 8, AIS_STRIKE = 16

Type AIRun
	Text As UString
	Style As Integer
	Link As UString
End Type

Function AISplitLines(ByRef S As WString, Lns() As UString) As Integer
	Dim As Integer Count, P = 1, Q, L
	ReDim Lns(15)
	Do
		If Count > UBound(Lns) Then ReDim Preserve Lns(Count * 2)
		Q = InStr(P, S, !"\n")
		If Q = 0 Then
			Lns(Count) = Mid(S, P)
		Else
			Lns(Count) = Mid(S, P, Q - P)
		End If
		L = Len(Lns(Count))
		If L > 0 AndAlso Lns(Count)[L - 1] = 13 Then Lns(Count) = Left(Lns(Count), L - 1)
		Count += 1
		If Q = 0 Then Exit Do
		P = Q + 1
	Loop
	Return Count
End Function

Sub AIAddBlock(Blocks() As AIBlock, ByRef Count As Integer, Kind As Integer, ByRef Text As WString, Level As Integer = 0)
	If Count > UBound(Blocks) Then ReDim Preserve Blocks(Count * 2 + 7)
	Blocks(Count).Kind = Kind
	Blocks(Count).Text = Text
	Blocks(Count).Level = Level
	Blocks(Count).Marker = ""
	Blocks(Count).Lang = ""
	Blocks(Count).FoldKind = 0
	Blocks(Count).Closed = True
	Count += 1
End Sub

Sub AIFlushPara(Blocks() As AIBlock, ByRef Count As Integer, ByRef Para As UString, ByRef InPara As Boolean)
	If InPara Then AIAddBlock(Blocks(), Count, abPara, Para)
	Para = ""
	InPara = False
End Sub

Function AIIsTableSep(ByRef L As WString) As Boolean
	Dim As UString T = Trim(L, Any !" \t")
	If Len(T) < 3 OrElse InStr(T, "-") = 0 OrElse InStr(T, "|") = 0 Then Return False
	For i As Integer = 0 To Len(T) - 1
		Select Case T[i]
		Case 124, 45, 58, 32, 9 '| - : space tab
		Case Else
			Return False
		End Select
	Next
	Return True
End Function

Function AIAllChars(ByRef T As WString, C As Integer) As Boolean
	If Len(T) < 3 Then Return False
	For i As Integer = 0 To Len(T) - 1
		If T[i] <> C Then Return False
	Next
	Return True
End Function

'The item of a list: its indent, its marker and the position (1-based) of its text (0: not an item)
Function AIListItem(ByRef L As WString, ByRef Indent As Integer, ByRef Marker As UString, ByRef Ordered As Boolean) As Integer
	Dim As Integer i, j, n = Len(L)
	Indent = 0
	Do While i < n AndAlso (L[i] = 32 OrElse L[i] = 9)
		Indent += IIf(L[i] = 9, 4, 1)
		i += 1
	Loop
	If i >= n Then Return 0
	Select Case L[i]
	Case 45, 42, 43 '- * +
		If i + 1 < n AndAlso L[i + 1] = 32 Then
			Marker = WChr(8226): Ordered = False
			Return i + 3
		End If
	Case 48 To 57
		j = i
		Do While j < n AndAlso L[j] >= 48 AndAlso L[j] <= 57
			j += 1
		Loop
		If j - i <= 3 AndAlso j + 1 < n AndAlso (L[j] = 46 OrElse L[j] = 41) AndAlso L[j + 1] = 32 Then
			Marker = Mid(L, i + 1, j - i) & ".": Ordered = True
			Return j + 3
		End If
	End Select
	Return 0
End Function

Function AIIsToolLine(ByRef T As WString) As Boolean
	Return Len(T) > 2 AndAlso T[0] = 8594 AndAlso T[1] = 32
End Function

Declare Function AIIsToolBlockLine(ByRef T As WString) As Boolean
Declare Sub AIAddToolBlocks(ByRef Raw As WString, Blocks() As AIBlock, ByRef Count As Integer)

'The blocks of the markdown text (ToolsApart: the calls of the tools are not in one fold)
Function AIParseBlocks(ByRef MD As WString, Blocks() As AIBlock, ToolsApart As Boolean = False) As Integer
	Dim As UString Lns(Any), Para, L, T, LT, Content, Code, Lang, Rows, Tools, T2, Mk
	Dim As Integer LnCount = AISplitLines(MD, Lns()), Count, i, j, E, H, N, Ind, TP
	Dim As Boolean InPara, Closed, Ord
	Erase Blocks
	Do While i < LnCount
		L = Lns(i)
		T = Trim(L, Any !" \t")
		LT = LCase(T)
		'Thinking
		If Left(LT, 7) = "<think>" Then
			AIFlushPara(Blocks(), Count, Para, InPara)
			Content = Mid(T, 8)
			Closed = False
			E = InStr(LCase(Content), "</think>")
			If E > 0 Then Content = Left(Content, E - 1): Closed = True
			i += 1
			Do While (Not Closed) AndAlso i < LnCount
				E = InStr(LCase(Lns(i)), "</think>")
				If E > 0 Then
					Content &= !"\n" & Left(Lns(i), E - 1)
					Closed = True
				Else
					Content &= !"\n" & Lns(i)
				End If
				i += 1
			Loop
			If Trim(Content, Any !" \r\n\t") <> "" OrElse Not Closed Then
				AIAddBlock(Blocks(), Count, abFold, Content)
				Blocks(Count - 1).FoldKind = 1
				Blocks(Count - 1).Closed = Closed
			End If
			Continue Do
		End If
		'The end of thinking without its start
		If LT = "</think>" Then i += 1: Continue Do
		'The calls of the tools of Claude Code (-> Name), their inputs and results, the pictures and the blank lines
		'between them
		If AIIsToolLine(T) OrElse AIIsToolBlockLine(T) Then
			AIFlushPara(Blocks(), Count, Para, InPara)
			Dim As UString Raw, Names, BlockID
			N = 0
			Do While i < LnCount
				T2 = Trim(Lns(i), Any !" \t")
				If AIIsToolLine(T2) Then
					Raw &= T2 & !"\n": Names &= IIf(N > 0, !"\n", "") & T2: N += 1: i += 1
				ElseIf AIIsToolBlockLine(T2) Then
					'The block to its end
					BlockID = Trim(Mid(T2, IIf(Left(T2, 9) = "~~~vfb-in", 10, 11)))
					If Right(BlockID, 6) = " error" Then BlockID = Trim(Left(BlockID, Len(BlockID) - 6))
					Raw &= T2 & !"\n"
					i += 1
					Do While i < LnCount
						Raw &= Lns(i) & !"\n"
						i += 1
						If Left(Lns(i - 1), 11) = "~~~vfb-end " AndAlso Trim(Mid(Lns(i - 1), 12)) = BlockID Then Exit Do
					Loop
				ElseIf N > 0 AndAlso Left(T2, 2) = "![" AndAlso Right(T2, 1) = ")" AndAlso InStr(T2, "](") > 0 Then
					Raw &= T2 & !"\n": i += 1
				ElseIf T2 = "" Then
					j = i + 1
					Do While j < LnCount AndAlso Trim(Lns(j), Any !" \t") = ""
						j += 1
					Loop
					If j < LnCount AndAlso (AIIsToolLine(Trim(Lns(j), Any !" \t")) OrElse AIIsToolBlockLine(Trim(Lns(j), Any !" \t"))) Then i = j Else Exit Do
				Else
					Exit Do
				End If
			Loop
			If ToolsApart OrElse N <= 1 Then
				AIAddToolBlocks(Raw, Blocks(), Count)
			Else
				'The calls in one fold (it is open), each call is a fold in it
				AIAddBlock(Blocks(), Count, abFold, Raw, N)
				Blocks(Count - 1).FoldKind = 2
				Blocks(Count - 1).Lang = Names
			End If
			Continue Do
		End If
		'The tasks and the state of the answer (AIChatTakeMessages adds them)
		If Left(T, 12) = "~~~vfb-tasks" Then
			AIFlushPara(Blocks(), Count, Para, InPara)
			Content = ""
			i += 1
			Do While i < LnCount
				If Lns(i) = "~~~vfb-end tasks" Then i += 1: Exit Do
				Content &= Lns(i) & !"\n"
				i += 1
			Loop
			AIAddBlock(Blocks(), Count, abTasks, Content)
			Continue Do
		End If
		If Left(T, 14) = "~~~vfb-status " Then
			AIFlushPara(Blocks(), Count, Para, InPara)
			AIAddBlock(Blocks(), Count, abStatus, Mid(T, 15))
			i += 1
			Continue Do
		End If
		'Code
		If Left(T, 3) = "```" Then
			AIFlushPara(Blocks(), Count, Para, InPara)
			'The fence can be longer (the code has lines of backquotes): its end is a line of so many backquotes
			Dim As Integer FenceLen = 3
			Do While FenceLen < Len(T) AndAlso T[FenceLen] = 96
				FenceLen += 1
			Loop
			Lang = Trim(Mid(T, FenceLen + 1))
			Code = ""
			Closed = False
			j = 0
			i += 1
			Do While i < LnCount
				T2 = Trim(Lns(i), Any !" \t")
				If Len(T2) >= FenceLen AndAlso Left(T2, 3) = "```" AndAlso (FenceLen = 3 OrElse AIAllChars(T2, 96)) Then Closed = True: i += 1: Exit Do
				If j = 0 Then Code = Lns(i) Else Code &= !"\n" & Lns(i)
				j += 1
				i += 1
			Loop
			AIAddBlock(Blocks(), Count, abCode, Code)
			Blocks(Count - 1).Lang = Lang
			Blocks(Count - 1).Closed = Closed
			Continue Do
		End If
		'Table
		If Left(T, 1) = "|" AndAlso i + 1 < LnCount AndAlso AIIsTableSep(Lns(i + 1)) <> 0 Then
			AIFlushPara(Blocks(), Count, Para, InPara)
			Rows = T
			i += 2
			Do While i < LnCount AndAlso Left(Trim(Lns(i), Any !" \t"), 1) = "|"
				Rows &= !"\n" & Trim(Lns(i), Any !" \t")
				i += 1
			Loop
			AIAddBlock(Blocks(), Count, abTable, Rows)
			Continue Do
		End If
		If T = "" Then
			AIFlushPara(Blocks(), Count, Para, InPara)
			i += 1
			Continue Do
		End If
		'Heading
		If T[0] = 35 Then
			H = 0
			Do While H < Len(T) AndAlso T[H] = 35
				H += 1
			Loop
			If H <= 6 AndAlso H < Len(T) AndAlso T[H] = 32 Then
				AIFlushPara(Blocks(), Count, Para, InPara)
				AIAddBlock(Blocks(), Count, abHead, Trim(Mid(T, H + 2)), H)
				i += 1
				Continue Do
			End If
		End If
		'Line
		If AIAllChars(T, 45) OrElse AIAllChars(T, 42) OrElse AIAllChars(T, 95) Then
			AIFlushPara(Blocks(), Count, Para, InPara)
			AIAddBlock(Blocks(), Count, abRule, "")
			i += 1
			Continue Do
		End If
		'Quote
		If T[0] = 62 Then
			AIFlushPara(Blocks(), Count, Para, InPara)
			AIAddBlock(Blocks(), Count, abQuote, Trim(Mid(T, 2)))
			i += 1
			Continue Do
		End If
		'Picture: ![text](path)
		If Left(T, 2) = "![" AndAlso Right(T, 1) = ")" Then
			'One or more pictures: ![text](path) ![text](path) (a path can have brackets)
			Dim As Integer PS = 1, PC, PE, Pics
			Do
				PC = InStr(PS, T, "](")
				If PC = 0 Then Exit Do
				PE = InStr(PC + 2, T, ") ![")
				If PE = 0 Then PE = Len(T)
				If Pics = 0 Then AIFlushPara(Blocks(), Count, Para, InPara)
				AIAddBlock(Blocks(), Count, abImage, Mid(T, PC + 2, PE - PC - 2))
				Blocks(Count - 1).Marker = Mid(T, PS + 2, PC - PS - 2)
				Pics += 1
				If PE >= Len(T) Then Exit Do
				PS = PE + 2
			Loop
			If Pics > 0 Then
				i += 1
				Continue Do
			End If
		End If
		'Item of a list
		TP = AIListItem(L, Ind, Mk, Ord)
		If TP > 0 Then
			AIFlushPara(Blocks(), Count, Para, InPara)
			AIAddBlock(Blocks(), Count, abItem, Mid(L, TP), Ind \ 2)
			Blocks(Count - 1).Marker = Mk
			i += 1
			Continue Do
		End If
		'Paragraph (its lines stay lines)
		If InPara Then
			Para &= !"\n" & T
		Else
			Para = T: InPara = True
		End If
		i += 1
	Loop
	AIFlushPara(Blocks(), Count, Para, InPara)
	Return Count
End Function

Sub AIAddRun(Runs() As AIRun, ByRef Count As Integer, ByRef Text As WString, Style As Integer, ByRef LinkTo As WString = "")
	If Len(Text) = 0 Then Exit Sub
	If Count > 0 AndAlso Runs(Count - 1).Style = Style AndAlso (Style And AIS_LINK) = 0 Then
		Runs(Count - 1).Text &= Text
		Exit Sub
	End If
	If Count > UBound(Runs) Then ReDim Preserve Runs(Count * 2 + 7)
	Runs(Count).Text = Text
	Runs(Count).Style = Style
	Runs(Count).Link = LinkTo
	Count += 1
End Sub

Function AIIsWordChar(C As Integer) As Boolean
	Return (C >= 48 AndAlso C <= 57) OrElse (C >= 65 AndAlso C <= 90) OrElse (C >= 97 AndAlso C <= 122) OrElse C = 95 OrElse C > 127
End Function

'The texts of a line of markdown with their styles: **bold**, *italic*, `code`, ~~strike~~, [text](link), http://...
Function AIParseInline(ByRef S As WString, Runs() As AIRun) As Integer
	Dim As Integer Count, i, n = Len(S), Style, SegStart, j, C, CloseB, CloseP
	Erase Runs
	Do While i < n
		C = S[i]
		If C = 92 AndAlso i + 1 < n AndAlso InStr("\`*_[]()#+-.!|~<>", WChr(S[i + 1])) > 0 Then
			If i > SegStart Then AIAddRun(Runs(), Count, Mid(S, SegStart + 1, i - SegStart), Style)
			SegStart = i + 1
			i += 2
			Continue Do
		ElseIf C = 96 Then '`
			j = InStr(i + 2, S, "`")
			If j > 0 Then
				If i > SegStart Then AIAddRun(Runs(), Count, Mid(S, SegStart + 1, i - SegStart), Style)
				AIAddRun(Runs(), Count, Mid(S, i + 2, j - i - 2), Style Or AIS_CODE)
				i = j: SegStart = i
				Continue Do
			End If
		ElseIf (C = 42 AndAlso i + 1 < n AndAlso S[i + 1] = 42) OrElse (C = 126 AndAlso i + 1 < n AndAlso S[i + 1] = 126) Then '** ~~
			If i > SegStart Then AIAddRun(Runs(), Count, Mid(S, SegStart + 1, i - SegStart), Style)
			Style Xor= IIf(C = 42, AIS_BOLD, AIS_STRIKE)
			i += 2: SegStart = i
			Continue Do
		ElseIf C = 42 Then '*
			If ((Style And AIS_ITALIC) = 0 AndAlso i + 1 < n AndAlso S[i + 1] <> 32) OrElse ((Style And AIS_ITALIC) <> 0 AndAlso i > 0 AndAlso S[i - 1] <> 32) Then
				If i > SegStart Then AIAddRun(Runs(), Count, Mid(S, SegStart + 1, i - SegStart), Style)
				Style Xor= AIS_ITALIC
				i += 1: SegStart = i
				Continue Do
			End If
		ElseIf C = 91 Then '[text](link)
			CloseB = InStr(i + 2, S, "](")
			If CloseB > 0 Then
				CloseP = InStr(CloseB + 2, S, ")")
				If CloseP > 0 AndAlso InStr(Mid(S, i + 2, CloseB - i - 2), "]") = 0 AndAlso InStr(Mid(S, CloseB + 2, CloseP - CloseB - 2), " ") = 0 Then
					If i > SegStart Then AIAddRun(Runs(), Count, Mid(S, SegStart + 1, i - SegStart), Style)
					AIAddRun(Runs(), Count, Mid(S, i + 2, CloseB - i - 2), Style Or AIS_LINK, Mid(S, CloseB + 2, CloseP - CloseB - 2))
					i = CloseP: SegStart = i
					Continue Do
				End If
			End If
		ElseIf C = 104 AndAlso (Mid(S, i + 1, 7) = "http://" OrElse Mid(S, i + 1, 8) = "https://") AndAlso (i = 0 OrElse Not AIIsWordChar(S[i - 1])) Then
			j = i
			Do While j < n AndAlso S[j] > 32 AndAlso S[j] <> 41 AndAlso S[j] <> 93 AndAlso S[j] <> 62 AndAlso S[j] <> 34 AndAlso S[j] <> 39 AndAlso S[j] <> 96
				j += 1
			Loop
			Do While j > i AndAlso InStr(".,;:!?", WChr(S[j - 1])) > 0
				j -= 1
			Loop
			If i > SegStart Then AIAddRun(Runs(), Count, Mid(S, SegStart + 1, i - SegStart), Style)
			AIAddRun(Runs(), Count, Mid(S, i + 1, j - i), Style Or AIS_LINK, Mid(S, i + 1, j - i))
			i = j: SegStart = i
			Continue Do
		End If
		i += 1
	Loop
	If n > SegStart Then AIAddRun(Runs(), Count, Mid(S, SegStart + 1, n - SegStart), Style)
	Return Count
End Function

'The cells of a row of a table
Function AITableCells(ByRef Row As WString, Cells() As UString) As Integer
	Dim As UString R = Trim(Row, Any !" \t")
	If Left(R, 1) = "|" Then R = Mid(R, 2)
	If Right(R, 1) = "|" Then R = Left(R, Len(R) - 1)
	Return Split(R, "|", Cells())
End Function

'The title of the calls of the tools: their number and names (Bash x3, Read)
Function AIToolsTitle(ByRef Tools As WString, Count As Integer) As UString
	Dim As UString Lns(Any), Names(Any), Nm
	Dim As Integer Counts(Any), NC, n = AISplitLines(Tools, Lns()), P, k
	For i As Integer = 0 To n - 1
		Nm = Trim(Mid(Lns(i), 3))
		P = InStr(Nm, ":")
		If P > 0 Then Nm = Trim(Left(Nm, P - 1))
		For k = 0 To NC - 1
			If Names(k) = Nm Then Exit For
		Next
		If k < NC Then
			Counts(k) += 1
		Else
			ReDim Preserve Names(NC): ReDim Preserve Counts(NC)
			Names(NC) = Nm: Counts(NC) = 1
			NC += 1
		End If
	Next
	Dim As UString R = Str(Count) & " " & ML("tool calls") & ": "
	For k = 0 To Min(NC, 4) - 1
		If k > 0 Then R &= ", "
		R &= Names(k)
		If Counts(k) > 1 Then R &= " " & WChr(215) & Str(Counts(k))
	Next
	If NC > 4 Then R &= ", ..."
	Return R
End Function

Function AIThinkTitle(Closed As Boolean) As UString
	If Closed Then Return ML("Thinking")
	Return ML("Thinking") & "..."
End Function

' ==========================================
' JSON (the calls of the tools of Claude Code and their results)
' ==========================================

Function AIJSkipWS(ByRef S As WString, ByVal i As Integer, n As Integer) As Integer
	Do While i < n AndAlso (S[i] = 32 OrElse S[i] = 9 OrElse S[i] = 10 OrElse S[i] = 13)
		i += 1
	Loop
	Return i
End Function

'The end (0-based, after it) of the JSON value at i
Function AIJSkip(ByRef S As WString, ByVal i As Integer, n As Integer) As Integer
	If i >= n Then Return n
	Dim As Integer Level, C
	Dim As Boolean InString
	Select Case S[i]
	Case 34 '"
		i += 1
		Do While i < n
			If S[i] = 92 Then
				i += 2
				Continue Do
			End If
			If S[i] = 34 Then Return i + 1
			i += 1
		Loop
		Return n
	Case 123, 91 '{ [
		Do While i < n
			C = S[i]
			If InString Then
				If C = 92 Then
					i += 1
				ElseIf C = 34 Then
					InString = False
				End If
			ElseIf C = 34 Then
				InString = True
			ElseIf C = 123 OrElse C = 91 Then
				Level += 1
			ElseIf C = 125 OrElse C = 93 Then
				Level -= 1
				If Level = 0 Then Return i + 1
			End If
			i += 1
		Loop
		Return n
	Case Else
		Do While i < n
			Select Case S[i]
			Case 44, 125, 93, 32, 9, 10, 13
				Exit Do
			End Select
			i += 1
		Loop
		Return i
	End Select
End Function

'The members of a JSON object: their names and their values as they are
Function AIJMembers(ByRef Obj As WString, JKeys() As UString, JValues() As UString) As Integer
	Dim As Integer n = Len(Obj), i, KE, VE, Count
	Erase JKeys, JValues
	i = AIJSkipWS(Obj, 0, n)
	If i >= n OrElse Obj[i] <> 123 Then Return 0
	i += 1
	Do
		i = AIJSkipWS(Obj, i, n)
		If i >= n OrElse Obj[i] <> 34 Then Exit Do
		KE = AIJSkip(Obj, i, n)
		ReDim Preserve JKeys(Count), JValues(Count)
		JKeys(Count) = Mid(Obj, i + 2, KE - i - 2)
		i = AIJSkipWS(Obj, KE, n)
		If i < n AndAlso Obj[i] = 58 Then i = AIJSkipWS(Obj, i + 1, n)
		VE = AIJSkip(Obj, i, n)
		JValues(Count) = Mid(Obj, i + 1, VE - i)
		Count += 1
		i = AIJSkipWS(Obj, VE, n)
		If i < n AndAlso Obj[i] = 44 Then i += 1 Else Exit Do
	Loop
	Return Count
End Function

'The value (as it is) of the member Key of a JSON object ("" if there is none)
Function AIJMember(ByRef Obj As WString, ByRef Key As WString) As UString
	Dim As Integer n = Len(Obj), i, KE, VE
	i = AIJSkipWS(Obj, 0, n)
	If i >= n OrElse Obj[i] <> 123 Then Return ""
	i += 1
	Do
		i = AIJSkipWS(Obj, i, n)
		If i >= n OrElse Obj[i] <> 34 Then Exit Do
		KE = AIJSkip(Obj, i, n)
		Dim As Boolean Found = (KE - i - 2 = Len(Key)) AndAlso Mid(Obj, i + 2, KE - i - 2) = Key
		i = AIJSkipWS(Obj, KE, n)
		If i < n AndAlso Obj[i] = 58 Then i = AIJSkipWS(Obj, i + 1, n)
		VE = AIJSkip(Obj, i, n)
		If Found Then Return Mid(Obj, i + 1, VE - i)
		i = AIJSkipWS(Obj, VE, n)
		If i < n AndAlso Obj[i] = 44 Then i += 1 Else Exit Do
	Loop
	Return ""
End Function

'The items of a JSON array (as they are)
Function AIJItems(ByRef Arr As WString, Items() As UString) As Integer
	Dim As Integer n = Len(Arr), i, VE, Count
	Erase Items
	i = AIJSkipWS(Arr, 0, n)
	If i >= n OrElse Arr[i] <> 91 Then Return 0
	i += 1
	Do
		i = AIJSkipWS(Arr, i, n)
		If i >= n OrElse Arr[i] = 93 Then Exit Do
		VE = AIJSkip(Arr, i, n)
		ReDim Preserve Items(Count)
		Items(Count) = Mid(Arr, i + 1, VE - i)
		Count += 1
		i = AIJSkipWS(Arr, VE, n)
		If i < n AndAlso Arr[i] = 44 Then i += 1 Else Exit Do
	Loop
	Return Count
End Function

'The text of a JSON value: a string without its quotes and escapes, the others as they are
Function AIJText(ByRef Raw As WString) As UString
	Dim As Integer n = Len(Raw)
	If n < 2 OrElse Raw[0] <> 34 Then Return Raw
	If n = 2 Then Return ""
	Dim As WString Ptr Text = EscapeFromJson(Mid(Raw, 2, n - 2))
	If Text = 0 Then Return ""
	Dim As UString Result = *Text
	_Deallocate(Text)
	Return Result
End Function

' ==========================================
' The calls of the tools of Claude Code
' ==========================================
'In the chat a call is the line "-> Name", its input and its result come after it (the results of the calls which ran
'together come after all of them):
'  ~~~vfb-in <id>             ~~~vfb-out <id>[ error]
'  {the input, JSON}          the text of the result
'  ~~~vfb-end <id>            ~~~vfb-end <id>

Const AITOOL_RUNNING = 0, AITOOL_DONE = 1, AITOOL_ERROR = 2, AITOOL_NODETAILS = 3

Function AIIsToolBlockLine(ByRef T As WString) As Boolean
	Return Left(T, 8) = "~~~vfb-i" OrElse Left(T, 8) = "~~~vfb-o"
End Function

'A code block whose fence is longer than the lines of backquotes in the text
Function AIFence(ByRef Lang As WString, ByRef Content As WString) As UString
	Dim As UString Lns(Any), T
	Dim As Integer n = AISplitLines(Content, Lns()), FenceLen = 3
	For i As Integer = 0 To n - 1
		T = Trim(Lns(i), Any !" \t")
		If Len(T) >= FenceLen AndAlso AIAllChars(T, 96) Then FenceLen = Len(T) + 1
	Next
	Dim As UString Fence = WString(FenceLen, 96)
	Return Fence & Lang & !"\n" & Content & !"\n" & Fence & !"\n"
End Function

'The first line of a text, not longer than MaxLen
Function AIFirstLine(ByRef S As WString, MaxLen As Integer = 200) As UString
	Dim As UString R = Trim(S, Any !" \t\r\n")
	Dim As Integer P = InStr(R, !"\n")
	If P > 0 Then R = RTrim(Left(R, P - 1), Any !" \r") & " ..."
	If Len(R) > MaxLen Then R = Left(R, MaxLen) & "..."
	Return R
End Function

Function AIFileNameOf(ByRef Path As WString) As UString
	Dim As Integer P = InStrRev(Path, "\"), P2 = InStrRev(Path, "/")
	If P2 > P Then P = P2
	Return Mid(Path, P + 1)
End Function

'What a call does in one line: the command, the file, the pattern ...
Function AIToolSummary(ByRef Name_ As WString, ByRef InputJson As WString) As UString
	Dim As UString S, Path
	Select Case Name_
	Case "Bash", "PowerShell"
		S = AIJText(AIJMember(InputJson, "command"))
	Case "Read", "Write", "Edit", "MultiEdit"
		S = AIJText(AIJMember(InputJson, "file_path"))
		If Name_ = "Read" Then
			Dim As UString Offset = AIJMember(InputJson, "offset"), Limit = AIJMember(InputJson, "limit")
			If Offset <> "" OrElse Limit <> "" Then
				S &= " (" & IIf(Offset <> "", ML("from") & " " & Offset, "") & IIf(Offset <> "" AndAlso Limit <> "", ", ", "") & IIf(Limit <> "", Limit & " " & ML("lines"), "") & ")"
			End If
		End If
	Case "NotebookEdit"
		S = AIJText(AIJMember(InputJson, "notebook_path"))
	Case "Grep", "Glob"
		S = AIJText(AIJMember(InputJson, "pattern"))
		Path = AIJText(AIJMember(InputJson, "path"))
		If Path <> "" Then S &= "  " & ML("in") & " " & Path
		If Name_ = "Grep" Then
			Path = AIJText(AIJMember(InputJson, "glob"))
			If Path <> "" Then S &= "  (" & Path & ")"
		End If
	Case "WebFetch"
		S = AIJText(AIJMember(InputJson, "url"))
	Case "WebSearch", "ToolSearch"
		S = AIJText(AIJMember(InputJson, "query"))
	Case "Task", "Agent"
		S = AIJText(AIJMember(InputJson, "description"))
	Case "Skill"
		S = AIJText(AIJMember(InputJson, "skill"))
	Case "TodoWrite"
		Dim As UString Todos(Any)
		S = Str(AIJItems(AIJMember(InputJson, "todos"), Todos())) & " " & ML("tasks")
	End Select
	If S = "" Then
		'The first string of the input
		Dim As UString JKeys(Any), JValues(Any)
		Dim As Integer n = AIJMembers(InputJson, JKeys(), JValues())
		For i As Integer = 0 To n - 1
			If Left(JValues(i), 1) = """" Then S = AIJText(JValues(i)): Exit For
		Next
	End If
	Return AIFirstLine(S)
End Function

'The lines of the change of Edit: - the old lines, + the new ones
Function AIToolDiff(ByRef OldText As WString, ByRef NewText As WString) As UString
	Dim As UString Lns(Any), R
	Dim As Integer n
	If Len(OldText) > 0 Then
		n = AISplitLines(OldText, Lns())
		For i As Integer = 0 To n - 1
			R &= "- " & Lns(i) & !"\n"
		Next
	End If
	If Len(NewText) > 0 Then
		n = AISplitLines(NewText, Lns())
		For i As Integer = 0 To n - 1
			R &= "+ " & Lns(i) & !"\n"
		Next
	End If
	If Right(R, 1) = !"\n" Then R = Left(R, Len(R) - 1)
	Return R
End Function

'The details of a call (markdown): its input as it is shown in Claude Code (the command, the change, the text of the
'file) and the other members of it, then its result
Function AIToolBodyMD(ByRef Name_ As WString, ByRef InputJson As WString, ByRef Result As WString, State As Integer) As UString
	Dim As UString R, Shown = "|", JKeys(Any), JValues(Any), Rest, V, Items(Any)
	Dim As Integer n
	Select Case Name_
	Case "Bash", "PowerShell"
		V = AIJText(AIJMember(InputJson, "description"))
		If V <> "" Then
			'The description as a text (its characters of markdown escaped)
			Dim As UString Esc
			For c As Integer = 0 To Len(V) - 1
				If V[c] = 10 OrElse V[c] = 13 Then
					Esc &= " "
				ElseIf InStr("\`*_[]()#+-.!|~<>", WChr(V[c])) > 0 Then
					Esc &= "\" & WChr(V[c])
				Else
					Esc &= WChr(V[c])
				End If
			Next
			R &= "*" & Esc & !"*\n\n"
		End If
		R &= AIFence(Name_, AIJText(AIJMember(InputJson, "command")))
		Shown &= "description|command|"
	Case "Edit"
		R &= AIFence(AIFileNameOf(AIJText(AIJMember(InputJson, "file_path"))), AIToolDiff(AIJText(AIJMember(InputJson, "old_string")), AIJText(AIJMember(InputJson, "new_string"))))
		Shown &= "file_path|old_string|new_string|"
	Case "MultiEdit"
		n = AIJItems(AIJMember(InputJson, "edits"), Items())
		For k As Integer = 0 To n - 1
			R &= AIFence(AIFileNameOf(AIJText(AIJMember(InputJson, "file_path"))) & " (" & Str(k + 1) & "/" & Str(n) & ")", AIToolDiff(AIJText(AIJMember(Items(k), "old_string")), AIJText(AIJMember(Items(k), "new_string"))))
		Next
		Shown &= "file_path|edits|"
	Case "Write"
		R &= AIFence(AIFileNameOf(AIJText(AIJMember(InputJson, "file_path"))), AIJText(AIJMember(InputJson, "content")))
		Shown &= "file_path|content|"
	Case "Read"
		Shown &= "file_path|"
	Case "TodoWrite"
		n = AIJItems(AIJMember(InputJson, "todos"), Items())
		For k As Integer = 0 To n - 1
			Select Case AIJText(AIJMember(Items(k), "status"))
			Case "completed": V = WChr(9745)
			Case "in_progress": V = WChr(9680)
			Case Else: V = WChr(9744)
			End Select
			R &= "- " & V & " " & AIJText(AIJMember(Items(k), "content")) & !"\n"
		Next
		If n > 0 Then R &= !"\n"
		Shown &= "todos|"
	End Select
	'The other members of the input
	n = AIJMembers(InputJson, JKeys(), JValues())
	For i As Integer = 0 To n - 1
		If InStr(Shown, "|" & JKeys(i) & "|") > 0 Then Continue For
		If Rest <> "" Then Rest &= !"\n"
		Rest &= JKeys(i) & ": " & AIJText(JValues(i))
	Next
	If Rest <> "" Then R &= AIFence(ML("Input"), Rest)
	Select Case State
	Case AITOOL_RUNNING
		R &= ML("Running") & "..." & !"\n"
	Case AITOOL_DONE, AITOOL_ERROR
		If Trim(Result, Any !" \t\r\n") = "" Then
			R &= IIf(State = AITOOL_ERROR, ML("Error"), ML("No output")) & !"\n"
		Else
			R &= AIFence(IIf(State = AITOOL_ERROR, ML("Error"), ML("Output")), Result)
		End If
	End Select
	Return R
End Function

'The text of a block of a call for the RTF view (a code block)
Function AIToolBlockRTF(ByRef Chunk As WString) As UString
	Dim As UString EndMark = !"\n~~~vfb-end", NL = !"\n"
	Dim As Integer P1 = InStr(2, Chunk, NL), P2 = InStrRev(Chunk, EndMark)
	If P1 = 0 OrElse P2 <= P1 Then Return ""
	Dim As UString Head = Mid(Chunk, 2, P1 - 2), Body = Mid(Chunk, P1 + 1, P2 - P1 - 1)
	If Left(Head, 9) = "~~~vfb-in" Then
		Dim As UString JKeys(Any), JValues(Any), Rest
		Dim As Integer n = AIJMembers(Body, JKeys(), JValues())
		For i As Integer = 0 To n - 1
			If Rest <> "" Then Rest &= !"\n"
			Rest &= JKeys(i) & ": " & AIJText(JValues(i))
		Next
		Return !"\n```\n" & Rest & !"\n```\n"
	End If
	If Trim(Body, Any !" \t\r\n") = "" Then Return ""
	Return !"\n```\n" & Body & !"\n```\n"
End Function

'Adds the blocks of the calls of a part of the chat (the lines "-> Name", their inputs and results, the pictures):
'a fold for each call (FoldKind 3: Marker the name, Lang the input, Text the result, Level the state)
Sub AIAddToolBlocks(ByRef Raw As WString, Blocks() As AIBlock, ByRef Count As Integer)
	Dim As UString Lns(Any), T, ID, Body, IDs(Any)
	Dim As Integer n = AISplitLines(Raw, Lns()), i, First = Count, k, Found
	Dim As Boolean IsIn, IsError
	ReDim IDs(n)
	Do While i < n
		T = Trim(Lns(i), Any !" \t")
		If AIIsToolLine(T) Then
			AIAddBlock(Blocks(), Count, abFold, "")
			Blocks(Count - 1).FoldKind = 3
			Blocks(Count - 1).Marker = Trim(Mid(T, 3))
			Blocks(Count - 1).Level = AITOOL_NODETAILS
			i += 1
		ElseIf AIIsToolBlockLine(T) Then
			IsIn = Left(T, 9) = "~~~vfb-in"
			ID = Trim(Mid(T, IIf(IsIn, 10, 11)))
			IsError = Right(ID, 6) = " error"
			If IsError Then ID = Trim(Left(ID, Len(ID) - 6))
			Body = ""
			i += 1
			Do While i < n
				If Left(Lns(i), 11) = "~~~vfb-end " AndAlso Trim(Mid(Lns(i), 12)) = ID Then i += 1: Exit Do
				If Body = "" AndAlso k = 0 Then Body = Lns(i) Else Body &= !"\n" & Lns(i)
				k += 1
				i += 1
			Loop
			k = 0
			Found = -1
			If IsIn Then
				'The first call without its input
				For b As Integer = First To Count - 1
					If Blocks(b).Kind = abFold AndAlso Blocks(b).FoldKind = 3 AndAlso Blocks(b).Level = AITOOL_NODETAILS Then Found = b: Exit For
				Next
				If Found < 0 Then
					AIAddBlock(Blocks(), Count, abFold, "")
					Blocks(Count - 1).FoldKind = 3
					Found = Count - 1
				End If
				Blocks(Found).Lang = Body
				Blocks(Found).Level = AITOOL_RUNNING
				IDs(Found - First) = ID
			Else
				For b As Integer = First To Count - 1
					If Blocks(b).Kind = abFold AndAlso Blocks(b).FoldKind = 3 AndAlso IDs(b - First) = ID Then Found = b: Exit For
				Next
				If Found < 0 Then
					AIAddBlock(Blocks(), Count, abFold, "")
					Blocks(Count - 1).FoldKind = 3
					Blocks(Count - 1).Marker = ML("Result")
					Found = Count - 1
				End If
				Blocks(Found).Text = Body
				Blocks(Found).Level = IIf(IsError, AITOOL_ERROR, AITOOL_DONE)
			End If
			If Count - First > UBound(IDs) Then ReDim Preserve IDs(Count - First + n)
		ElseIf Left(T, 2) = "![" AndAlso InStr(T, "](") > 0 Then
			AIAddBlock(Blocks(), Count, abImage, Mid(T, InStr(T, "](") + 2, Len(T) - InStr(T, "](") - 2))
			Blocks(Count - 1).Marker = Mid(T, 3, InStr(T, "](") - 3)
			i += 1
		Else
			i += 1
		End If
		If Count - First > UBound(IDs) Then ReDim Preserve IDs(Count - First + n)
	Loop
End Sub

Function AILineCount(ByRef S As WString) As Integer
	If Len(S) = 0 Then Return 0
	Dim As Integer n = 1, P = InStr(S, !"\n")
	Do While P > 0
		If P < Len(S) Then n += 1
		P = InStr(P + 1, S, !"\n")
	Loop
	Return n
End Function

'The lines added and removed by a call (Edit, MultiEdit, Write)
Sub AIToolDiffCount(ByRef Name_ As WString, ByRef InputJson As WString, ByRef Added As Integer, ByRef Removed As Integer)
	Dim As UString Items(Any)
	Select Case Name_
	Case "Edit"
		Removed += AILineCount(AIJText(AIJMember(InputJson, "old_string")))
		Added += AILineCount(AIJText(AIJMember(InputJson, "new_string")))
	Case "MultiEdit"
		Dim As Integer n = AIJItems(AIJMember(InputJson, "edits"), Items())
		For k As Integer = 0 To n - 1
			Removed += AILineCount(AIJText(AIJMember(Items(k), "old_string")))
			Added += AILineCount(AIJText(AIJMember(Items(k), "new_string")))
		Next
	Case "Write"
		Added += AILineCount(AIJText(AIJMember(InputJson, "content")))
	End Select
End Sub

Function AICountText(n As Integer, ByRef One As WString, ByRef Many As WString) As UString
	Return Str(n) & " " & IIf(n = 1, ML(One), ML(Many))
End Function

'The title of the calls of a part of the chat as in Claude Code: Ran 6 commands, edited 2 files (and the lines added
'and removed by them), read 3 files ...
Function AIToolsGroupTitle(ByRef Raw As WString, ByRef Added As Integer, ByRef Removed As Integer) As UString
	Dim As AIBlock Blocks(Any)
	Dim As Integer Count = AIParseBlocks(Raw, Blocks(), True)
	Dim As Integer Cmds, Reads, Searches, Webs, Agents, Others, Edited
	Dim As Boolean Tasks
	Dim As UString Files = "|", Path, R
	Added = 0: Removed = 0
	For b As Integer = 0 To Count - 1
		If Blocks(b).Kind <> abFold OrElse Blocks(b).FoldKind <> 3 Then Continue For
		Select Case Blocks(b).Marker
		Case "Bash", "PowerShell": Cmds += 1
		Case "Read": Reads += 1
		Case "Grep", "Glob": Searches += 1
		Case "WebFetch", "WebSearch": Webs += 1
		Case "Task", "Agent": Agents += 1
		Case "TodoWrite", "TaskCreate", "TaskUpdate", "TaskList", "TaskGet": Tasks = True
		Case "Edit", "MultiEdit", "Write", "NotebookEdit"
			Path = LCase(AIJText(AIJMember(Blocks(b).Lang, IIf(Blocks(b).Marker = "NotebookEdit", "notebook_path", "file_path"))))
			If InStr(Files, "|" & Path & "|") = 0 Then Files &= Path & "|": Edited += 1
			AIToolDiffCount(Blocks(b).Marker, Blocks(b).Lang, Added, Removed)
		Case Else: Others += 1
		End Select
	Next
	If Cmds > 0 Then R &= ", " & ML("ran") & " " & AICountText(Cmds, "command", "commands")
	If Edited > 0 Then R &= ", " & ML("edited") & " " & AICountText(Edited, "file", "files")
	If Reads > 0 Then R &= ", " & ML("read") & " " & AICountText(Reads, "file", "files")
	If Searches > 0 Then R &= ", " & ML("searched") & " " & AICountText(Searches, "time", "times")
	If Webs > 0 Then R &= ", " & ML("opened") & " " & AICountText(Webs, "web page", "web pages")
	If Agents > 0 Then R &= ", " & ML("ran") & " " & AICountText(Agents, "agent", "agents")
	If Tasks Then R &= ", " & ML("updated the tasks")
	If Others > 0 Then R &= ", " & ML("used") & " " & AICountText(Others, "tool", "tools")
	R = Mid(R, 3)
	If Len(R) > 0 Then R = UCase(Left(R, 1)) & Mid(R, 2)
	Return R
End Function

'The task list of a message (TodoWrite, TaskCreate and TaskUpdate of Claude Code): the lines "status|text"
Function AITaskList(ByRef Body As WString) As UString
	Dim As AIBlock Blocks(Any), Inner(Any)
	Dim As Integer Count = AIParseBlocks(Body, Blocks()), IC, n, P
	Dim As UString IDs(Any), Texts(Any), States(Any), Items(Any), ID, St
	Dim As Integer TC
	Dim As Boolean Found
	For b As Integer = 0 To Count - 1
		If Blocks(b).Kind <> abFold Then Continue For
		If Blocks(b).FoldKind = 2 Then
			IC = AIParseBlocks(Blocks(b).Text, Inner(), True)
		ElseIf Blocks(b).FoldKind = 3 Then
			IC = 1: ReDim Inner(0): Inner(0) = Blocks(b)
		Else
			Continue For
		End If
		For i As Integer = 0 To IC - 1
			If Inner(i).Kind <> abFold OrElse Inner(i).FoldKind <> 3 OrElse Inner(i).Lang = "" Then Continue For
			Found = True
			Select Case Inner(i).Marker
			Case "TodoWrite"
				n = AIJItems(AIJMember(Inner(i).Lang, "todos"), Items())
				TC = n
				ReDim IDs(n), Texts(n), States(n)
				For k As Integer = 0 To n - 1
					States(k) = AIJText(AIJMember(Items(k), "status"))
					Texts(k) = AIJText(AIJMember(Items(k), IIf(States(k) = "in_progress" AndAlso AIJMember(Items(k), "activeForm") <> "", "activeForm", "content")))
					IDs(k) = Str(k + 1)
				Next
			Case "TaskCreate"
				'The number of the task is in the result: Task #3 created ...
				P = InStr(Inner(i).Text, "#")
				If P > 0 Then ID = Str(Val(Mid(Inner(i).Text, P + 1))) Else ID = Str(TC + 1)
				ReDim Preserve IDs(TC), Texts(TC), States(TC)
				IDs(TC) = ID: Texts(TC) = AIJText(AIJMember(Inner(i).Lang, "subject")): States(TC) = "pending"
				TC += 1
			Case "TaskUpdate"
				ID = AIJText(AIJMember(Inner(i).Lang, "taskId"))
				St = AIJText(AIJMember(Inner(i).Lang, "status"))
				For k As Integer = 0 To TC - 1
					If IDs(k) = ID Then
						If St <> "" Then States(k) = St
						If AIJMember(Inner(i).Lang, "subject") <> "" Then Texts(k) = AIJText(AIJMember(Inner(i).Lang, "subject"))
						Exit For
					End If
				Next
			Case Else
				Found = False
			End Select
		Next
	Next
	Dim As UString R
	For k As Integer = 0 To TC - 1
		If States(k) = "deleted" Then Continue For
		R &= States(k) & "|" & Texts(k) & !"\n"
	Next
	Return R
End Function

'The call of a tool which runs (its name and what it does)
Function AIRunningTool(ByRef Body As WString) As UString
	Dim As AIBlock Blocks(Any), Inner(Any)
	Dim As Integer Count = AIParseBlocks(Body, Blocks()), IC
	Dim As UString R
	For b As Integer = 0 To Count - 1
		If Blocks(b).Kind <> abFold Then Continue For
		If Blocks(b).FoldKind = 2 Then
			IC = AIParseBlocks(Blocks(b).Text, Inner(), True)
			For i As Integer = 0 To IC - 1
				If Inner(i).Kind = abFold AndAlso Inner(i).FoldKind = 3 AndAlso Inner(i).Level = AITOOL_RUNNING Then R = Inner(i).Marker & "  " & AIToolSummary(Inner(i).Marker, Inner(i).Lang)
			Next
		ElseIf Blocks(b).FoldKind = 3 AndAlso Blocks(b).Level = AITOOL_RUNNING Then
			R = Blocks(b).Marker & "  " & AIToolSummary(Blocks(b).Marker, Blocks(b).Lang)
		End If
	Next
	Return R
End Function

'The title of a call: its name and what it does, ... while it runs
Function AIToolTitleText(ByRef B As AIBlock) As UString
	Dim As UString S = IIf(B.Lang <> "", AIToolSummary(B.Marker, B.Lang), "")
	If B.Level = AITOOL_RUNNING Then S &= IIf(S <> "", "  ", "") & "..."
	Return S
End Function

' ==========================================
' HTML (WebView2, IE)
' ==========================================

Function AIHtmlEscape(ByRef S As WString) As UString
	Dim As UString R
	Dim As Integer n = Len(S), Start
	For i As Integer = 0 To n - 1
		Select Case S[i]
		Case 38, 60, 62, 34
			If i > Start Then R &= Mid(S, Start + 1, i - Start)
			Select Case S[i]
			Case 38
				R &= "&amp;"
			Case 60
				R &= "&lt;"
			Case 62
				R &= "&gt;"
			Case Else
				R &= "&quot;"
			End Select
			Start = i + 1
		End Select
	Next
	If n > Start Then R &= Mid(S, Start + 1)
	Return R
End Function

Function AIJSString(ByRef S As WString) As UString
	Dim As UString R = """"
	Dim As Integer n = Len(S), Start, C
	For i As Integer = 0 To n - 1
		C = S[i]
		If C = 92 OrElse C = 34 OrElse C < 32 OrElse C = 8232 OrElse C = 8233 Then
			If i > Start Then R &= Mid(S, Start + 1, i - Start)
			Select Case C
			Case 92
				R &= "\\"
			Case 34
				R &= "\"""
			Case 10
				R &= "\n"
			Case 13
				R &= "\r"
			Case 9
				R &= "\t"
			Case Else
				R &= "\u" & Hex(C, 4)
			End Select
			Start = i + 1
		End If
	Next
	If n > Start Then R &= Mid(S, Start + 1)
	R &= """"
	Return R
End Function

Function AIInlineHtml(ByRef S As WString) As UString
	Dim As AIRun Runs(Any)
	Dim As Integer n = AIParseInline(S, Runs())
	Dim As UString R, T
	For i As Integer = 0 To n - 1
		T = Replace(AIHtmlEscape(Runs(i).Text), !"\n", "<br>")
		If Runs(i).Style And AIS_CODE Then T = "<code>" & T & "</code>"
		If Runs(i).Style And AIS_BOLD Then T = "<b>" & T & "</b>"
		If Runs(i).Style And AIS_ITALIC Then T = "<i>" & T & "</i>"
		If Runs(i).Style And AIS_STRIKE Then T = "<s>" & T & "</s>"
		If Runs(i).Style And AIS_LINK Then T = "<a href=""#"" data-u=""" & AIHtmlEscape(Runs(i).Link) & """ title=""" & AIHtmlEscape(Runs(i).Link) & """>" & T & "</a>"
		R &= T
	Next
	Return R
End Function

Function AITableHtml(ByRef Rows As WString) As UString
	Dim As UString Lns(Any), Cells(Any), H = "<table>"
	Dim As Integer n = AISplitLines(Rows, Lns()), C
	For r As Integer = 0 To n - 1
		C = AITableCells(Lns(r), Cells())
		H &= "<tr>"
		For k As Integer = 0 To C - 1
			H &= IIf(r = 0, "<th>", "<td>") & AIInlineHtml(Trim(Cells(k))) & IIf(r = 0, "</th>", "</td>")
		Next
		H &= "</tr>"
	Next
	Return H & "</table>"
End Function

Declare Function AIBase64(ByRef Bytes As String) As String

Function AIFileUrl(ByRef Path As WString) As UString
	If InStr(Path, "://") > 0 Then Return Path
	'WebView2: the page of NavigateToString does not open the files, a picture is in the page (data:)
	If AIChatViewMode = acvWebView2 Then
		Dim As Integer F = FreeFile
		If Open(Path For Binary Access Read As #F) = 0 Then
			Dim As String Bytes = String(LOF(F), 0)
			If Len(Bytes) > 0 Then Get #F, , Bytes
			Close #F
			If Len(Bytes) > 0 Then
				Dim As String Mime, Ext = LCase(Mid(Path, InStrRev(Path, ".") + 1))
				Select Case Ext
				Case "jpg", "jpeg": Mime = "image/jpeg"
				Case "gif": Mime = "image/gif"
				Case "bmp": Mime = "image/bmp"
				Case "webp": Mime = "image/webp"
				Case "svg": Mime = "image/svg+xml"
				Case Else: Mime = "image/png"
				End Select
				Return "data:" & Mime & ";base64," & AIBase64(Bytes)
			End If
		End If
	End If
	#ifdef __USE_WINAPI__
		Return "file:///" & Replace(Path, "\", "/")
	#else
		'The path begins with /
		Return "file://" & Path
	#endif
End Function

Function AIDiffHtml(Added As Integer, Removed As Integer) As UString
	Dim As UString R
	If Added > 0 Then R &= "<span class=""ad"">+" & Str(Added) & "</span>"
	If Removed > 0 Then R &= "<span class=""rm"">" & WChr(8722) & Str(Removed) & "</span>"
	Return R
End Function

'The lines status|text of the tasks: their states and texts, the number of the done ones
Function AITaskCounts(ByRef Tasks As WString, St() As UString, Tx() As UString, ByRef Done As Integer) As Integer
	Dim As UString Lns(Any)
	Dim As Integer n = AISplitLines(Tasks, Lns()), Count, P
	Erase St, Tx
	Done = 0
	For i As Integer = 0 To n - 1
		P = InStr(Lns(i), "|")
		If P = 0 Then Continue For
		ReDim Preserve St(Count), Tx(Count)
		St(Count) = Left(Lns(i), P - 1): Tx(Count) = Mid(Lns(i), P + 1)
		If St(Count) = "completed" Then Done += 1
		Count += 1
	Next
	Return Count
End Function

'The mark of the state of a task: done, running (it turns each second), waiting
Function AITaskMark(ByRef St As WString) As UString
	Select Case St
	Case "completed": Return WChr(10003)
	Case "in_progress": Return WChr(9680 + (Int(Timer) Mod 4))
	Case Else: Return WChr(9675)
	End Select
End Function

Function AITasksHtml(ByRef Tasks As WString) As UString
	Dim As UString St(Any), Tx(Any), H, CssClass
	Dim As Integer Done, n = AITaskCounts(Tasks, St(), Tx(), Done)
	If n = 0 Then Return ""
	H = "<div class=""tasks""><div class=""tt"">" & AIHtmlEscape(ML("Tasks")) & " " & Str(Done) & "/" & Str(n) & "</div>"
	For i As Integer = 0 To n - 1
		CssClass = IIf(St(i) = "completed", "ti done", IIf(St(i) = "in_progress", "ti now", "ti"))
		H &= "<div class=""" & CssClass & """><span class=""tk"">" & AITaskMark(St(i)) & "</span>" & AIHtmlEscape(Tx(i)) & "</div>"
	Next
	Return H & "</div>"
End Function

'The HTML of the blocks of a markdown text; KeyPrefix makes the keys of the folds (thinking, tools) of a message
Function AIBlocksHtml(ByRef MD As WString, ByRef KeyPrefix As WString = "", ToolsApart As Boolean = False) As UString
	Dim As AIBlock Blocks(Any)
	Dim As Integer Count = AIParseBlocks(MD, Blocks(), ToolsApart), FoldNo
	Dim As UString H, Key, Title, Body, Caption
	For b As Integer = 0 To Count - 1
		Select Case Blocks(b).Kind
		Case abPara
			H &= "<p>" & AIInlineHtml(Blocks(b).Text) & "</p>"
		Case abHead
			H &= "<h" & Str(Blocks(b).Level) & ">" & AIInlineHtml(Blocks(b).Text) & "</h" & Str(Blocks(b).Level) & ">"
		Case abItem
			H &= "<div class=""li"" style=""margin-left:" & Str(Blocks(b).Level * 1.2) & "em""><span class=""lm"">" & AIHtmlEscape(Blocks(b).Marker) & "</span>" & AIInlineHtml(Blocks(b).Text) & "</div>"
		Case abCode
			H &= "<div class=""code""><div class=""cb""><span>" & AIHtmlEscape(Blocks(b).Lang) & "&nbsp;</span><a href=""#"" data-a=""edit"">" & AIHtmlEscape(ML("Edit")) & "</a><a href=""#"" data-a=""copy"">" & AIHtmlEscape(ML("Copy")) & "</a></div><pre>" & AIHtmlEscape(Blocks(b).Text) & "</pre></div>"
		Case abTable
			H &= AITableHtml(Blocks(b).Text)
		Case abQuote
			H &= "<blockquote>" & AIInlineHtml(Blocks(b).Text) & "</blockquote>"
		Case abRule
			H &= "<hr>"
		Case abImage
			Caption = Blocks(b).Marker
			If Caption = "" Then Caption = Blocks(b).Text
			H &= "<div class=""img""><a href=""#"" data-u=""" & AIHtmlEscape(Blocks(b).Text) & """><img src=""" & AIHtmlEscape(AIFileUrl(Blocks(b).Text)) & """ alt="""" onerror=""this.style.display='none'""><br>" & AIHtmlEscape(Caption) & "</a></div>"
		Case abTasks
			H &= AITasksHtml(Blocks(b).Text)
		Case abStatus
			H &= "<div class=""st""><span class=""sp"">" & WChr(9680 + (Int(Timer) Mod 4)) & "</span> " & AIHtmlEscape(Blocks(b).Text) & "</div>"
		Case abFold
			Select Case Blocks(b).FoldKind
			Case 1
				Key = KeyPrefix & Str(FoldNo)
				Title = AIThinkTitle(Blocks(b).Closed)
				Body = AIBlocksHtml(Blocks(b).Text, Key & ".")
				H &= "<div class=""fold"" data-k=""" & Key & """><div class=""fh"" data-f=""1"">" & AIHtmlEscape(Title) & "</div><div class=""fb"">" & Body & "</div></div>"
			Case 2
				'The calls of the tools: the fold is open, the key is of its closing
				Key = KeyPrefix & "g" & Str(FoldNo)
				Dim As Integer Added, Removed
				'The numbers of the lines are known after the title is made
				Title = "<span class=""el"">" & AIHtmlEscape(AIToolsGroupTitle(Blocks(b).Text, Added, Removed)) & "</span>"
				Title &= AIDiffHtml(Added, Removed)
				Body = AIBlocksHtml(Blocks(b).Text, Key & ".", True)
				H &= "<div class=""fold open"" data-k=""" & Key & """ data-d=""1""><div class=""fh fx"" data-f=""1"">" & Title & "</div><div class=""fb"">" & Body & "</div></div>"
			Case 3
				'A call: its name and what it does, in it its input and its result
				If ToolsApart Then Key = KeyPrefix & Str(FoldNo) Else Key = KeyPrefix & "g" & Str(FoldNo) & ".0"
				Title = "<b>" & AIHtmlEscape(Blocks(b).Marker) & "</b>"
				Caption = AIToolTitleText(Blocks(b))
				If Caption <> "" Then Title &= "<span class=""ts el"">" & AIHtmlEscape(Caption) & "</span>"
				If Blocks(b).Lang <> "" Then
					Dim As Integer TA, TR
					AIToolDiffCount(Blocks(b).Marker, Blocks(b).Lang, TA, TR)
					Title &= AIDiffHtml(TA, TR)
				End If
				If Blocks(b).Level = AITOOL_ERROR Then Title &= "<span class=""te"">" & WChr(10007) & "</span>"
				If Blocks(b).Level = AITOOL_NODETAILS Then
					H &= "<div class=""tl"">" & Title & "</div>"
				Else
					Body = AIBlocksHtml(AIToolBodyMD(Blocks(b).Marker, Blocks(b).Lang, Blocks(b).Text, Blocks(b).Level), Key & ".")
					H &= "<div class=""fold tool"" data-k=""" & Key & """><div class=""fh fx"" data-f=""1"">" & Title & "</div><div class=""fb"">" & Body & "</div></div>"
				End If
			End Select
			FoldNo += 1
		End Select
	Next
	Return H
End Function

'The page of the chat: the styles and the scripts, the messages are added by vfbSet
Function AIChatHtmlShell() As UString
	Dim As AIChatColors C = AIChatPalette()
	Dim As String BG = AIChatCssColor(C.Back), FG = AIChatCssColor(C.Fore), MU = AIChatCssColor(C.Muted), BU = AIChatCssColor(C.Bubble)
	Dim As String CB = AIChatCssColor(C.CodeBack), BO = AIChatCssColor(C.Border), LI = AIChatCssColor(C.Link)
	Dim As UString CodeFont = "'" & *EditorFontName & "',Consolas,monospace"
	Dim As String Sz = Str(EditorFontSize) & "pt"
	Dim As UString H
	H = "<!DOCTYPE html><html><head><meta charset=""utf-8""><meta http-equiv=""X-UA-Compatible"" content=""IE=edge""><title>VFBAIChat</title><style>"
	'IE: the scroll bar is always seen (not the hiding one of IE 11)
	H &= "html{-ms-overflow-style:scrollbar;overflow-y:scroll}"
	If AIChatIsDark() Then
		'The thumb between the border and the grey of the texts
		Dim As ULong Thumb = ((((C.Border Shr 16) And &HFF) + ((C.Muted Shr 16) And &HFF)) \ 2) Shl 16 Or ((((C.Border Shr 8) And &HFF) + ((C.Muted Shr 8) And &HFF)) \ 2) Shl 8 Or (((C.Border And &HFF) + (C.Muted And &HFF)) \ 2)
		H &= ":root{color-scheme:dark}html{scrollbar-base-color:" & CB & ";scrollbar-face-color:" & AIChatCssColor(Thumb) & ";scrollbar-track-color:" & BG & ";scrollbar-arrow-color:" & MU & ";scrollbar-shadow-color:" & BG & ";scrollbar-highlight-color:" & BG & ";scrollbar-3dlight-color:" & BG & ";scrollbar-darkshadow-color:" & BG & "}"
	End If
	H &= "html,body{margin:0;padding:0;background:" & BG & ";color:" & FG & "}" & _
	"body{font-family:'Segoe UI',Tahoma,sans-serif,'Noto Color Emoji';font-size:" & Sz & ";line-height:1.5;padding:10px 14px 20px 14px;word-wrap:break-word;overflow-wrap:break-word}" & _
	".msg{margin:0 0 14px 0}" & _
	".hdr{font-size:85%;color:" & MU & ";margin:0 0 3px 0}" & _
	".user{text-align:right}" & _
	".user .bubble{display:inline-block;text-align:left;max-width:85%;background:" & BU & ";border-radius:12px;padding:6px 12px}" & _
	"p{margin:0 0 8px 0}.bubble p:last-child{margin-bottom:0}" & _
	"h1,h2,h3,h4,h5,h6{margin:12px 0 6px 0;line-height:1.25}h1{font-size:150%}h2{font-size:130%}h3{font-size:115%}h4,h5,h6{font-size:100%}" & _
	".li{margin-bottom:3px;padding-left:1.4em;text-indent:-1.4em}.lm{display:inline-block;min-width:1.4em;text-indent:0}" & _
	"code{font-family:" & CodeFont & ";font-size:92%;background:" & CB & ";border:1px solid " & BO & ";border-radius:4px;padding:0 4px}" & _
	".code{margin:6px 0 10px 0;border:1px solid " & BO & ";border-radius:8px;background:" & CB & ";overflow:hidden}" & _
	".cb{font-size:80%;color:" & MU & ";padding:3px 10px;border-bottom:1px solid " & BO & ";text-align:right}" & _
	".cb span{float:left}.cb a{color:" & MU & ";margin-left:14px}.cb a:hover{color:" & FG & ";text-decoration:none}" & _
	"pre{margin:0;padding:8px 10px;overflow-x:auto;font-family:" & CodeFont & ";font-size:" & Sz & ";line-height:1.35;white-space:pre}" & _
	"table{border-collapse:collapse;margin:6px 0 10px 0}th,td{border:1px solid " & BO & ";padding:4px 8px;text-align:left;vertical-align:top}th{background:" & CB & "}" & _
	"blockquote{margin:4px 0 8px 0;padding:0 0 0 10px;border-left:3px solid " & BO & ";color:" & MU & "}" & _
	"hr{border:0;border-top:1px solid " & BO & ";margin:10px 0}" & _
	"a{color:" & LI & ";text-decoration:none;cursor:pointer}a:hover{text-decoration:underline}" & _
	".fold{margin:2px 0 8px 0}.fh{color:" & MU & ";cursor:pointer;display:inline-block;padding:1px 0}.fh:hover{color:" & FG & "}" & _
	".fh:before{content:'\25B8\00a0\00a0'}.fold.open>.fh:before{content:'\25BE\00a0\00a0'}" & _
	".fb{display:none;margin:4px 0 0 5px;padding:2px 0 2px 12px;border-left:2px solid " & BO & "}.fold.open>.fb{display:block}" & _
	".tl{color:" & MU & ";padding:1px 0}" & _
	".tool{margin:1px 0 3px 0}.fh.fx{display:flex;white-space:nowrap}.fx>*{flex:none;margin-right:.45em}.fx>.el{flex:0 1 auto;min-width:0;overflow:hidden;text-overflow:ellipsis}" & _
	".ts{font-family:" & CodeFont & ";font-size:92%}.te{color:#d04040}.ad{color:#3fa34d}.rm{color:#d04040}" & _
	".tasks{margin:6px 0 10px 0;border:1px solid " & BO & ";border-radius:8px;padding:6px 10px}.tt{font-size:85%;color:" & MU & ";margin-bottom:3px}" & _
	".ti{padding:1px 0 1px 1.5em;text-indent:-1.5em}.tk{display:inline-block;width:1.5em;text-indent:0;color:" & MU & "}.ti.done{color:" & MU & "}.ti.now{font-weight:600}" & _
	".st{color:" & MU & ";margin:4px 0 8px 0}.sp{display:inline-block;width:1.2em}" & _
	".img img{max-width:100%;border-radius:6px}" & _
	"#vfbq{position:absolute;left:-10000px;top:0;width:10px;height:10px;overflow:hidden}" & _
	"</style><script>" & _
	"var openF={},q=[],wasB=true;" & _
	"function $(i){return document.getElementById(i);}" & _
	"function atBottom(){var d=document.documentElement,b=document.body,st=d.scrollTop||b.scrollTop,h=Math.max(d.scrollHeight,b.scrollHeight),c=window.innerHeight||d.clientHeight;return st+c>=h-40;}" & _
	"function post(s){s=encodeURIComponent(s);try{if(window.chrome&&window.chrome.webview){window.chrome.webview.postMessage(s);return;}" & _
	"if(window.webkit&&window.webkit.messageHandlers&&window.webkit.messageHandlers.vfb){window.webkit.messageHandlers.vfb.postMessage(s);return;}" & _
	"if(window.vfbConsole){console.log('vfb:'+s);return;}}catch(e){}q.push(s);$('vfbq').innerText=q.join(' ');}" & _
	"function vfbQClear(){q=[];$('vfbq').innerText='';}" & _
	"function vfbBegin(){wasB=atBottom();}" & _
	"function vfbEnd(f){if(wasB||f)window.scrollTo(0,1e9);}" & _
	"function vfbClear(){$('chat').innerHTML='';openF={};}" & _
	"function vfbSet(i,u,h,html){var c=$('chat'),m=$('m'+i);" & _
	"while(c.childNodes.length>i+1)c.removeChild(c.lastChild);" & _
	"if(!m){m=document.createElement('div');m.id='m'+i;c.appendChild(m);}" & _
	"m.className='msg '+(u?'user':'ai');" & _
	"m.innerHTML=(h?'<div class=""hdr"">'+h+'</div>':'')+(u?'<div class=""bubble"">'+html+'</div>':html);" & _
	"var d=m.getElementsByTagName('div');for(var k=0;k<d.length;k++){var key=d[k].getAttribute('data-k');if(!key)continue;var v=openF[i+':'+key];" & _
	"if(v===true&&!/\bopen\b/.test(d[k].className))d[k].className+=' open';else if(v===false)d[k].className=d[k].className.replace(/\s*\bopen\b/,'');}}" & _
	"function msgIndex(t){while(t&&!(t.id&&t.id.charAt(0)=='m'))t=t.parentNode;return t?t.id.substring(1):'';}" & _
	"function sel(){try{return window.getSelection?String(window.getSelection()):document.selection.createRange().text;}catch(e){return '';}}" & _
	"document.onclick=function(e){e=e||window.event;var t=e.target||e.srcElement;" & _
	"while(t&&t.getAttribute){var a=t.getAttribute('data-a');" & _
	"if(a){var p=t.parentNode.parentNode.getElementsByTagName('pre')[0];post(a+':'+(p.innerText||p.textContent));if(a=='copy')t.innerHTML='&#10003;';return false;}" & _
	"var u=t.getAttribute('data-u');if(u){post('link:'+u);return false;}" & _
	"if(t.getAttribute('data-f')){var f=t.parentNode,o=/\bopen\b/.test(f.className);f.className=o?f.className.replace(/\s*\bopen\b/,''):f.className+' open';openF[msgIndex(f)+':'+f.getAttribute('data-k')]=!o;return false;}" & _
	"t=t.parentNode;}};" & _
	"document.oncontextmenu=function(e){post('menu:'+sel());return false;};" & _
	"</script></head><body><div id=""chat""></div><div id=""vfbq""></div></body></html>"
	Return H
End Function

Function AIChatMessageHtml(ByRef Msg As AIChatMessage) As UString
	Return AIBlocksHtml(Msg.Body)
End Function

'Decodes a message of the page (encodeURIComponent)
Function AIUrlDecode(ByRef S As WString) As UString
	Dim As String B
	Dim As Integer i = 1, n = Len(S)
	Do While i <= n
		If S[i - 1] = 37 AndAlso i + 2 <= n Then
			B &= Chr(ValInt("&H" & Mid(S, i + 1, 2)))
			i += 3
		Else
			B &= Chr(S[i - 1] And 255)
			i += 1
		End If
	Loop
	Dim As UString R
	Dim As WString Ptr W = FromUtf8(StrPtr(B))
	If W Then R = *W: _Deallocate(W)
	Return R
End Function

'The script of the page for the new messages (WebView2, IE, WebKitGTK)
Function AIChatRenderScript() As UString
	Dim As AIChatMessage Msgs(Any)
	Dim As Integer Count
	Dim As Boolean Full
	Dim As Integer First = AIChatTakeMessages(Msgs(), Count, Full)
	Dim As UString Js = "vfbBegin();"
	If Full Then Js &= "vfbClear();"
	For k As Integer = 0 To Count - 1
		Js &= "vfbSet(" & Str(First + k) & "," & IIf(Msgs(k).IsUser, "1", "0") & "," & AIJSString(AIHtmlEscape(Msgs(k).Header)) & "," & AIJSString(AIChatMessageHtml(Msgs(k))) & ");"
	Next
	Js &= "vfbEnd(" & IIf(Full, "1", "0") & ");"
	Return Js
End Function

' ==========================================
' The actions of the views
' ==========================================

Sub AIChatOpenCode(ByRef Code As WString)
	If Trim(Code, Any !" \r\n\t") = "" Then Exit Sub
	Dim As UString FileName = GetUserTempPath(ML("Untitled") & ".bas")
	If FileName = "" Then Exit Sub
	SaveToFile(FileName, Code)
	AddTab FileName, True
End Sub

'A link of the chat: a web page in the browser, a file (path or path:line) in the editor
Sub AIChatOpenLink(ByRef LinkTo As WString)
	Dim As UString L = Trim(LinkTo)
	If L = "" Then Exit Sub
	Dim As UString LL = LCase(L)
	If StartsWith(LL, "http://") OrElse StartsWith(LL, "https://") OrElse StartsWith(LL, "mailto:") Then
		#ifdef __USE_WINAPI__
			ShellExecuteW(0, "open", L.vptr, 0, 0, SW_SHOWNORMAL)
		#elseif defined(__USE_GTK__)
			g_app_info_launch_default_for_uri(ToUtf8(L), NULL, NULL)
		#endif
		Exit Sub
	End If
	If StartsWith(LL, "file:///") Then L = Mid(L, 9)
	L = Replace(L, "%20", " ")
	Dim As UString FileName = L
	If Not FileExists(FileName) Then
		'path:line
		Dim As Integer P = InStrRev(L, ":")
		If P > 2 Then FileName = Left(L, P - 1)
	End If
	If FileExists(FileName) Then
		Select Case LCase(Right(FileName, 4))
		Case ".png", ".jpg", ".gif", ".bmp", "jpeg", "webp"
			#ifdef __USE_WINAPI__
				ShellExecuteW(0, "open", FileName.vptr, 0, 0, SW_SHOWNORMAL)
			#elseif defined(__USE_GTK__)
				Dim As gchar Ptr Uri = g_filename_to_uri(ToUtf8(FileName), NULL, NULL)
				If Uri Then g_app_info_launch_default_for_uri(Uri, NULL, NULL): g_free(Uri)
			#endif
		Case Else
			AddTab FileName
		End Select
	Else
		ShowMessages(ML("File not found") & ": " & L)
	End If
End Sub

#if defined(__USE_GTK__) AndAlso Not defined(__USE_GTK4__)
	'The press of the right button in the web view (GTK3 opens a menu only with the event which began it)
	Dim Shared As GdkEvent Ptr AIChatMenuEvent
#endif

Sub AIChatShowMenu()
	#ifdef __USE_WINAPI__
		Dim As ..POINT Pt
		GetCursorPos(@Pt)
		'From the page of WebView2 (its process has the focus) the WM_COMMAND of TrackPopupMenuEx is lost:
		'the command is taken from the menu and sent to the window of the menu
		Dim As Component Ptr Owner = mnuAIChat.ParentWindow
		If Owner = 0 OrElse Owner->Handle = 0 Then mnuAIChat.Popup Pt.x, Pt.y: Exit Sub
		SetForegroundWindow(Owner->Handle)
		Dim As Long Cmd = TrackPopupMenuEx(mnuAIChat.Handle, TPM_RETURNCMD, Pt.x, Pt.y, Owner->Handle, 0)
		PostMessage(Owner->Handle, WM_NULL, 0, 0)
		If Cmd <> 0 Then PostMessage(Owner->Handle, WM_COMMAND, MAKEWPARAM(Cmd, 0), 0)
	#elseif defined(__USE_GTK__)
		'The page of WebKitGTK: the menu at the mouse
		#ifndef __USE_GTK4__
			If AIChatMenuEvent <> 0 AndAlso mnuAIChat.Handle <> 0 Then
				gtk_menu_popup(GTK_MENU(mnuAIChat.Handle), NULL, NULL, NULL, NULL, AIChatMenuEvent->button.button, AIChatMenuEvent->button.time)
				Exit Sub
			End If
		#endif
		mnuAIChat.Popup 0, 0
	#endif
End Sub

'A message of a view: copy:text, edit:code, link:link, menu:selected text
Sub AIChatViewMessage(ByRef Msg As WString)
	Dim As Integer P = InStr(Msg, ":")
	If P = 0 Then Exit Sub
	Dim As UString Act = Left(Msg, P - 1), Arg = Mid(Msg, P + 1)
	Select Case Act
	Case "copy"
		Clipboard.SetAsText Arg
	Case "edit"
		AIChatOpenCode Arg
	Case "link"
		AIChatOpenLink Arg
	Case "menu"
		AIChatViewSelection = Arg
		AIChatShowMenu
	End Select
End Sub

Declare Sub AIChatSetViewMode(Mode As Integer, SaveMode As Boolean = True)

#ifdef __USE_WINAPI__
	' ==========================================
	' WebView2
	' ==========================================

	'The handlers of the events of WebView2: COM objects of the IDE (AddRef and Release do nothing, they are not freed)
	Type AIWV2HandlerVtbl
		QueryInterface As Any Ptr
		AddRef As Any Ptr
		Release As Any Ptr
		Invoke As Any Ptr
	End Type

	Type AIWV2Handler
		lpVtbl As AIWV2HandlerVtbl Ptr
	End Type

	Type AIWV2CreateEnvFn As Function stdcall(ByVal BrowserFolder As LPCWSTR, ByVal UserDataFolder As LPCWSTR, ByVal Options As Any Ptr, ByVal Handler As ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler Ptr) As HRESULT

	Dim Shared As HMODULE AIWV2Lib
	Dim Shared As ICoreWebView2Environment Ptr AIWV2Env
	Dim Shared As ICoreWebView2Controller Ptr AIWV2Controller
	Dim Shared As ICoreWebView2 Ptr AIWV2
	Dim Shared As Boolean AIWV2Started, AIWV2Ready
	Dim Shared As AIWV2HandlerVtbl AIWV2EnvVtbl, AIWV2CtlVtbl, AIWV2MsgVtbl, AIWV2NavVtbl, AIWV2ScriptVtbl
	Dim Shared As AIWV2Handler AIWV2EnvHandler, AIWV2CtlHandler, AIWV2MsgHandler, AIWV2NavHandler, AIWV2ScriptHandler


	Function AIWV2QueryInterface stdcall(ByVal This As Any Ptr, ByVal riid As REFIID, ByVal ppv As Any Ptr Ptr) As HRESULT
		If ppv = 0 Then Return E_POINTER
		*ppv = This
		Return S_OK
	End Function

	Function AIWV2AddRef stdcall(ByVal This As Any Ptr) As ULong
		Return 1
	End Function

	Function AIWV2Release stdcall(ByVal This As Any Ptr) As ULong
		Return 1
	End Function

	'WebView2 can not be used: the message and the RTF view
	Sub AIWV2Fail(ByRef Reason As WString)
		ShowMessages("AI Agent, WebView2: " & Reason)
		AIWV2Started = False
		If AIChatViewMode = acvWebView2 Then AIChatSetViewMode(acvRTF, False)
	End Sub

	Sub AIWV2Resize()
		If AIWV2Controller = 0 OrElse pnlAIWebView2.Handle = 0 Then Exit Sub
		Dim As ..RECT R
		GetClientRect(pnlAIWebView2.Handle, @R)
		AIWV2Controller->lpVtbl->put_Bounds(AIWV2Controller, R)
	End Sub

	Function AIWV2EnvCompleted stdcall(ByVal This As Any Ptr, ByVal Result As HRESULT, ByVal Env As ICoreWebView2Environment Ptr) As HRESULT
		If Result <> S_OK OrElse Env = 0 Then
			AIWV2Fail(ML("The WebView2 runtime is not installed") & " (0x" & Hex(Result, 8) & ")")
			Return S_OK
		End If
		AIWV2Env = Env
		Env->lpVtbl->AddRef(Env)
		Env->lpVtbl->CreateCoreWebView2Controller(Env, pnlAIWebView2.Handle, Cast(ICoreWebView2CreateCoreWebView2ControllerCompletedHandler Ptr, @AIWV2CtlHandler))
		Return S_OK
	End Function

	Function AIWV2CtlCompleted stdcall(ByVal This As Any Ptr, ByVal Result As HRESULT, ByVal Ctl As ICoreWebView2Controller Ptr) As HRESULT
		If Result <> S_OK OrElse Ctl = 0 Then
			AIWV2Fail("CreateCoreWebView2Controller (0x" & Hex(Result, 8) & ")")
			Return S_OK
		End If
		AIWV2Controller = Ctl
		Ctl->lpVtbl->AddRef(Ctl)
		Ctl->lpVtbl->get_CoreWebView2(Ctl, @AIWV2)
		If AIWV2 = 0 Then AIWV2Fail("get_CoreWebView2"): Return S_OK
		Dim As ICoreWebView2Settings Ptr Settings
		If AIWV2->lpVtbl->get_Settings(AIWV2, @Settings) = S_OK AndAlso Settings <> 0 Then
			Settings->lpVtbl->put_AreDefaultContextMenusEnabled(Settings, False)
			Settings->lpVtbl->put_IsStatusBarEnabled(Settings, False)
			Settings->lpVtbl->Release(Settings)
		End If
		Dim As EventRegistrationToken Token
		AIWV2->lpVtbl->add_WebMessageReceived(AIWV2, Cast(ICoreWebView2WebMessageReceivedEventHandler Ptr, @AIWV2MsgHandler), @Token)
		AIWV2->lpVtbl->add_NavigationCompleted(AIWV2, Cast(ICoreWebView2NavigationCompletedEventHandler Ptr, @AIWV2NavHandler), @Token)
		AIWV2Resize
		Ctl->lpVtbl->put_IsVisible(Ctl, AIChatViewMode = acvWebView2)
		Dim As UString Html = AIChatHtmlShell()
		AIWV2->lpVtbl->NavigateToString(AIWV2, Html.vptr)
		Return S_OK
	End Function

	Function AIWV2NavCompleted stdcall(ByVal This As Any Ptr, ByVal Sender As ICoreWebView2 Ptr, ByVal Args As ICoreWebView2NavigationCompletedEventArgs Ptr) As HRESULT
		AIWV2Ready = True
		AIChatNeedFull = True
		Return S_OK
	End Function

	Function AIWV2MsgReceived stdcall(ByVal This As Any Ptr, ByVal Sender As ICoreWebView2 Ptr, ByVal Args As ICoreWebView2WebMessageReceivedEventArgs Ptr) As HRESULT
		Dim As LPWSTR Msg
		If Args <> 0 AndAlso Args->lpVtbl->TryGetWebMessageAsString(Args, @Msg) = S_OK AndAlso Msg <> 0 Then
			Dim As UString Text = AIUrlDecode(*Msg)
			CoTaskMemFree(Msg)
			AIChatViewMessage Text
		End If
		Return S_OK
	End Function

	Function AIWV2ScriptCompleted stdcall(ByVal This As Any Ptr, ByVal ErrorCode As HRESULT, ByVal ResultJson As LPCWSTR) As HRESULT
		Return S_OK
	End Function

	Sub AIWV2InitHandler(ByRef Handler As AIWV2Handler, ByRef Vtbl As AIWV2HandlerVtbl, Invoke As Any Ptr)
		Vtbl.QueryInterface = @AIWV2QueryInterface
		Vtbl.AddRef = @AIWV2AddRef
		Vtbl.Release = @AIWV2Release
		Vtbl.Invoke = Invoke
		Handler.lpVtbl = @Vtbl
	End Sub

	'Loads WebView2Loader.dll (by the IDE, in WebView2\<cpu> of the IDE, in the example of MyFbFramework) and makes the
	'WebView2 in pnlAIWebView2
	Sub AIWV2Start()
		If AIWV2Started OrElse pnlAIWebView2.Handle = 0 Then Exit Sub
		AIWV2Started = True
		#ifdef __FB_64BIT__
			Dim As String Cpu = "win-x64"
		#else
			Dim As String Cpu = "win-x86"
		#endif
		If AIWV2Lib = 0 Then
			Dim As UString Paths(2)
			Paths(0) = ExePath & "\WebView2Loader.dll"
			Paths(1) = ExePath & "\WebView2\" & Cpu & "\WebView2Loader.dll"
			Paths(2) = ExePath & "\Controls\MyFbFramework\examples\WebBrowser\Release\" & Cpu & "\WebView2Loader.dll"
			For i As Integer = 0 To 2
				If FileExists(Paths(i)) Then AIWV2Lib = LoadLibraryW(Paths(i).vptr)
				If AIWV2Lib Then Exit For
			Next
		End If
		If AIWV2Lib = 0 Then AIWV2Fail(ML("WebView2Loader.dll not found") & ": " & ExePath & "\WebView2\" & Cpu): Exit Sub
		Dim As AIWV2CreateEnvFn CreateEnv = Cast(AIWV2CreateEnvFn, GetProcAddress(AIWV2Lib, "CreateCoreWebView2EnvironmentWithOptions"))
		If CreateEnv = 0 Then AIWV2Fail("CreateCoreWebView2EnvironmentWithOptions"): Exit Sub
		AIWV2InitHandler(AIWV2EnvHandler, AIWV2EnvVtbl, @AIWV2EnvCompleted)
		AIWV2InitHandler(AIWV2CtlHandler, AIWV2CtlVtbl, @AIWV2CtlCompleted)
		AIWV2InitHandler(AIWV2MsgHandler, AIWV2MsgVtbl, @AIWV2MsgReceived)
		AIWV2InitHandler(AIWV2NavHandler, AIWV2NavVtbl, @AIWV2NavCompleted)
		AIWV2InitHandler(AIWV2ScriptHandler, AIWV2ScriptVtbl, @AIWV2ScriptCompleted)
		'The data of WebView2 are in the folder of the user (the folder of the IDE can be read only)
		Dim As WString * MAX_PATH DataDir
		GetEnvironmentVariableW("LOCALAPPDATA", @DataDir, MAX_PATH)
		If DataDir = "" Then DataDir = ExePath
		DataDir &= "\VisualFBEditor"
		CreateDirectoryW(@DataDir, 0)
		DataDir &= "\WebView2"
		CreateDirectoryW(@DataDir, 0)
		CoInitializeEx(0, COINIT_APARTMENTTHREADED)
		Dim As HRESULT hr = CreateEnv(0, @DataDir, 0, Cast(ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler Ptr, @AIWV2EnvHandler))
		If hr <> S_OK Then AIWV2Fail(ML("The WebView2 runtime is not installed") & " (0x" & Hex(hr, 8) & ")")
	End Sub

	Sub AIWV2Exec(ByRef Script As WString)
		If AIWV2 = 0 Then Exit Sub
		AIWV2->lpVtbl->ExecuteScript(AIWV2, @Script, Cast(ICoreWebView2ExecuteScriptCompletedHandler Ptr, @AIWV2ScriptHandler))
	End Sub

	Sub pnlAIWebView2_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		AIWV2Resize
	End Sub

	' ==========================================
	' IE (the WebBrowser control of MyFbFramework without WebView2)
	' ==========================================

	Type AIIEBrowser Extends WebBrowser
		Declare Function IsCreated() As Boolean
		Declare Function Document2() As IHTMLDocument2 Ptr
	End Type

	'The browser object of the AtlAxWin window (it is taken here, if WebBrowser did not take it when the handle was created)
	Function AIIEBrowser.IsCreated() As Boolean
		If g_IWebBrowser = 0 AndAlso FHandle <> 0 Then
			Dim As HMODULE hAtl = hWebBrowser
			If hAtl = 0 Then hAtl = GetModuleHandle("atl.dll")
			If hAtl = 0 Then Return False
			Dim AtlAxGetControl As Function stdcall(ByVal hWin As HWND, ByVal pp As IUnknown Ptr Ptr) As HRESULT
			AtlAxGetControl = Cast(Any Ptr, GetProcAddress(hAtl, "AtlAxGetControl"))
			If AtlAxGetControl = 0 Then Return False
			Dim As IUnknown Ptr Unk
			If AtlAxGetControl(FHandle, @Unk) <> S_OK OrElse Unk = 0 Then
				'AtlAxWin did not create the browser (OLE was not initialized when the window was created): it is created here
				Static As Boolean Tried
				If Tried Then Return False
				Tried = True
				OleInitialize(0)
				Dim AtlAxCreateControl As Function stdcall(ByVal lpszName As WString Ptr, ByVal hWin As HWND, ByVal pStream As Any Ptr, ByVal ppUnkContainer As IUnknown Ptr Ptr) As HRESULT
				AtlAxCreateControl = Cast(Any Ptr, GetProcAddress(hAtl, "AtlAxCreateControl"))
				If AtlAxCreateControl = 0 Then Return False
				Dim As WString * 16 ProgID = "Shell.Explorer.2"
				If AtlAxCreateControl(@ProgID, FHandle, 0, 0) <> S_OK Then Return False
				If AtlAxGetControl(FHandle, @Unk) <> S_OK OrElse Unk = 0 Then Return False
			End If
			Dim As Any Ptr WB
			If Unk->lpVtbl->QueryInterface(Unk, @IID_IWebBrowser2, @WB) = S_OK AndAlso WB <> 0 Then
				pIWebBrowser = WB
				g_IWebBrowser = Cast(IWebBrowser2Vtbl Ptr, *pIWebBrowser)
			End If
			Unk->lpVtbl->Release(Unk)
		End If
		Return g_IWebBrowser <> 0 AndAlso pIWebBrowser <> 0
	End Function

	'The document of the page (Release by the caller)
	Function AIIEBrowser.Document2() As IHTMLDocument2 Ptr
		If g_IWebBrowser = 0 OrElse pIWebBrowser = 0 Then Return 0
		Dim As IDispatch Ptr Doc
		Dim As IHTMLDocument2 Ptr Doc2
		g_IWebBrowser->get_Document(Cast(IWebBrowser2 Ptr, pIWebBrowser), @Doc)
		If Doc = 0 Then Return 0
		Doc->lpVtbl->QueryInterface(Doc, @IID_IHTMLDocument2, Cast(Any Ptr Ptr, @Doc2))
		Doc->lpVtbl->Release(Doc)
		Return Doc2
	End Function

	Dim Shared As AIIEBrowser Ptr AIIE

	'The scroll bars of the page: the flags of the host of ATL (DOCHOSTUIFLAG_SCROLL_NO off), before the page is opened
	Sub AIIEHostFlags(hWin As HWND)
		Dim As HMODULE hAtl = GetModuleHandle("atl.dll")
		If hAtl = 0 Then Exit Sub
		Dim AtlAxGetHost As Function stdcall(ByVal h As HWND, ByVal pp As IUnknown Ptr Ptr) As HRESULT
		AtlAxGetHost = Cast(Any Ptr, GetProcAddress(hAtl, "AtlAxGetHost"))
		If AtlAxGetHost = 0 Then Exit Sub
		Dim As IUnknown Ptr Unk
		If AtlAxGetHost(hWin, @Unk) <> S_OK OrElse Unk = 0 Then Exit Sub
		'IAxWinAmbientDispatch
		Static As GUID IID_IAxWinAmbientDispatch = Type<GUID>(&HB6EA2051, &H048A, &H11D1, {&H82, &HB9, &H00, &HC0, &H4F, &HB9, &H94, &H2E})
		Dim As Any Ptr Amb
		If Unk->lpVtbl->QueryInterface(Unk, @IID_IAxWinAmbientDispatch, @Amb) = S_OK AndAlso Amb <> 0 Then
			Dim As Any Ptr Ptr VT = *Cast(Any Ptr Ptr Ptr, Amb)
			Dim PutFlags As Function stdcall(ByVal This As Any Ptr, ByVal Flags As ULong) As HRESULT = VT[25]
			Dim GetFlags As Function stdcall(ByVal This As Any Ptr, ByVal Flags As ULong Ptr) As HRESULT = VT[26]
			Dim As ULong Flags
			GetFlags(Amb, @Flags)
			PutFlags(Amb, (Flags And Not &H8) Or &H4)
			Dim Release As Function stdcall(ByVal This As Any Ptr) As ULong = VT[2]
			Release(Amb)
		End If
		Unk->lpVtbl->Release(Unk)
	End Sub
	Dim Shared As Boolean AIIENavigated, AIIEReady

	Sub AIIEExec(ByRef Script As WString)
		If AIIE = 0 Then Exit Sub
		Dim As IHTMLDocument2 Ptr Doc = AIIE->Document2()
		If Doc = 0 Then Exit Sub
		Dim As IHTMLWindow2 Ptr Win
		Doc->lpVtbl->get_parentWindow(Doc, @Win)
		If Win Then
			Dim As WString * 10 LangName = "JScript"
			Dim As BSTR Code = SysAllocString(@Script), Lang = SysAllocString(@LangName)
			Dim As VARIANT V
			VariantInit(@V)
			Win->lpVtbl->execScript(Win, Code, Lang, @V)
			VariantClear(@V)
			SysFreeString(Code): SysFreeString(Lang)
			Win->lpVtbl->Release(Win)
		End If
		Doc->lpVtbl->Release(Doc)
	End Sub

	'The page of the chat is loaded
	Function AIIEPageReady() As Boolean
		Dim As IHTMLDocument2 Ptr Doc = AIIE->Document2()
		If Doc = 0 Then Return False
		Dim As BSTR State, Title
		Dim As Boolean Ready
		Doc->lpVtbl->get_readyState(Doc, @State)
		Doc->lpVtbl->get_title(Doc, @Title)
		If State <> 0 AndAlso Title <> 0 Then Ready = (*Cast(WString Ptr, State) = "complete") AndAlso (*Cast(WString Ptr, Title) = "VFBAIChat")
		If State Then SysFreeString(State)
		If Title Then SysFreeString(Title)
		Doc->lpVtbl->Release(Doc)
		Return Ready
	End Function

	'The messages of the page (the element vfbq, encoded and separated by spaces)
	Sub AIIEPoll()
		Dim As IHTMLDocument2 Ptr Doc = AIIE->Document2()
		If Doc = 0 Then Exit Sub
		Dim As IHTMLDocument3 Ptr Doc3
		Dim As UString Queue
		If Doc->lpVtbl->QueryInterface(Doc, @IID_IHTMLDocument3, Cast(Any Ptr Ptr, @Doc3)) = S_OK AndAlso Doc3 <> 0 Then
			Dim As WString * 10 ID = "vfbq"
			Dim As BSTR bID = SysAllocString(@ID), Text
			Dim As IHTMLElement Ptr El
			Doc3->lpVtbl->getElementById(Doc3, bID, @El)
			If El Then
				El->lpVtbl->get_innerText(El, @Text)
				If Text Then Queue = *Cast(WString Ptr, Text): SysFreeString(Text)
				El->lpVtbl->Release(El)
			End If
			SysFreeString(bID)
			Doc3->lpVtbl->Release(Doc3)
		End If
		Doc->lpVtbl->Release(Doc)
		If Trim(Queue) = "" Then Exit Sub
		AIIEExec "vfbQClear()"
		Dim As UString Items(Any)
		Dim As Integer n = Split(Trim(Queue), " ", Items())
		For i As Integer = 0 To n - 1
			If Items(i) <> "" Then AIChatViewMessage AIUrlDecode(Items(i))
		Next
	End Sub

#endif

#if defined(__USE_WINAPI__) OrElse defined(__USE_GTK__)
	' ==========================================
	' The own control (GDI+ the shapes, GDI the texts; or Direct2D and DirectWrite; on GTK cairo and pango)
	' ==========================================

	Type AIDrawOp
		'1 - text (Clr2: 1 - not joined with the next text, 2 - not selected), 2 - rectangle, 3 - rounded rectangle
		'(Clr2: its border), 4 - picture (Font: its index in the pictures), 6 - hot spot (Action)
		Kind As Integer
		X As Long
		Y As Long
		W As Long
		H As Long
		Font As Integer
		Clr As ULong
		Clr2 As ULong
		Text As UString
		Action As UString
		'The line of a text (the selection is drawn in the whole height of the line, like in the browser)
		SY As Long
		SH As Long
	End Type

	Type AICMessage
		IsUser As Boolean
		Header As UString
		Body As UString
		Y As Long
		H As Long
		Ops(Any) As AIDrawOp
		OpCount As Long
	End Type

	'The fonts: 0 normal, 1 bold, 2 italic, 3 bold italic, 4 code, 5-7 headings, 8 small
	Const AIC_FONTS = 9
	Dim Shared As Long AICFontH(AIC_FONTS - 1)
	'The sizes of the fonts in pixels (the em of CSS): the lines are measured from them like in the browser
	Dim Shared As Single AICEm(AIC_FONTS - 1)
	Dim Shared As Long AICScroll, AICTotalH, AICClientW, AICClientH, AICDpi = 96, AICMaxX
	Dim Shared As AICMessage AICMsgs(Any)
	Dim Shared As Integer AICMsgCount, AICCur
	'The opened folds: |message:key|
	Dim Shared As UString AICOpenFolds
	Dim Shared As AIChatColors AICColors
	'The color under the pictures (their rounded corners)
	Dim Shared As ULong AICPicBack
	'The pictures of the chat (loaded once)
	Dim Shared As UString AICImgPath(Any)
	Dim Shared As Long AICImgW(Any), AICImgH(Any)
	Dim Shared As Integer AICImgCount
	#ifdef __USE_WINAPI__
		Dim Shared As HFONT AICFonts(AIC_FONTS - 1)
		Dim Shared As HDC AICDC
		Dim Shared As HWND AICWnd
		Dim Shared As ULONG_PTR AICGdipToken
		'Direct2D: the texts are measured and drawn by DirectWrite
		Dim Shared As Boolean AICUseD2D
		Dim Shared As IDWriteTextFormat Ptr AICFormats(AIC_FONTS - 1)
		'The baselines of DirectWrite on the baselines of GDI (the places of the texts are of GDI)
		Dim Shared As Single AICD2DDY(AIC_FONTS - 1)
		Dim Shared As Long AICAscent(AIC_FONTS - 1)
		Dim Shared As ID2D1HwndRenderTarget Ptr AICRT
		Dim Shared As ID2D1SolidColorBrush Ptr AICBrush
		'The pictures by GDI+ (the bitmaps of Direct2D are made of them)
		Dim Shared As GpImage Ptr AICImgGp(Any)
		Dim Shared As Any Ptr AICImgD2D(Any)
	#else
		'GTK: the panel of the drawing (its widget is AICWnd) and its scroll bar; the texts are measured and drawn by
		'pango (a layout for every font), the pictures are pixbufs
		Dim Shared As Panel pnlAICCanvas
		Dim Shared As VScrollBar scrAIC
		Dim Shared As GtkWidget Ptr AICWnd
		Dim Shared As PangoContext Ptr AICPango
		Dim Shared As PangoLayout Ptr AICLayouts(AIC_FONTS - 1)
		Dim Shared As GdkPixbuf Ptr AICImgPix(Any)
		Dim Shared As Boolean AICScrollSetting
		Dim Shared As String AICCursorName
	#endif
	'The selection: the message, the text (the index of its operation) and the character
	Type AICPos
		Msg As Integer
		Op As Integer
		Ch As Integer
	End Type
	Dim Shared As AICPos AICSelA, AICSelB
	Dim Shared As Boolean AICSelecting, AICDragged
	Dim Shared As Long AICDownX, AICDownY

	Function AICScale(V As Long) As Long
		Return V * AICDpi \ 96
	End Function

	'The height of a line like in the browser: line-height 1.5 (1.25 of the titles) of the size of the font
	Function AICLineH(F As Integer) As Long
		If F >= 5 AndAlso F <= 7 Then Return CLng(AICEm(F) * 1.25)
		Return CLng(AICEm(F) * 1.5)
	End Function

	'One character from Pos0 (2 for the halves of an emoji)
	Function AICOneChar(ByRef S As WString, Pos0 As Integer) As Integer
		If Pos0 + 1 < Len(S) AndAlso S[Pos0 + 1] >= &HDC00 AndAlso S[Pos0 + 1] <= &HDFFF Then Return 2
		Return 1
	End Function

	#ifndef __USE_WINAPI__
	'The family of the font of the system (gtk-font-name, "Sans" if it is not known)
	Function AICUIFamily() As String
		Dim As String Family = "Sans"
		#ifndef __USE_GTK4__
			Dim As gchar Ptr SettingsFont
			Dim As GtkSettings Ptr Settings = gtk_settings_get_default()
			If Settings <> 0 Then g_object_get(Settings, "gtk-font-name", @SettingsFont, NULL)
			If SettingsFont <> 0 Then
				Dim As PangoFontDescription Ptr Desc = pango_font_description_from_string(SettingsFont)
				If Desc <> 0 Then
					Dim As Const gchar Ptr F = pango_font_description_get_family(Desc)
					If F <> 0 AndAlso *F <> "" Then Family = *F
					pango_font_description_free(Desc)
				End If
				g_free(SettingsFont)
			End If
		#endif
		Return Family
	End Function

	Sub AICCreateFonts()
		If AICWnd = 0 Then Exit Sub
		If AICPango = 0 Then AICPango = gtk_widget_create_pango_context(AICWnd)
		If AICPango = 0 Then Exit Sub
		Dim As String UIFont = AICUIFamily(), CodeFont = Replace(*EditorFontName, ";", ",")
		If Trim(CodeFont) = "" Then CodeFont = "Monospace"
		Dim As Single Sz = EditorFontSize
		If Sz <= 0 Then Sz = 10
		Dim As Single EmK(AIC_FONTS - 1) = {1, 1, 1, 1, 0.95, 1.5, 1.3, 1.15, 0.85}
		Dim As Long Weights(AIC_FONTS - 1) = {400, 600, 400, 600, 400, 600, 600, 600, 400}
		Dim As PangoRectangle LR
		For i As Integer = 0 To AIC_FONTS - 1
			If AICLayouts(i) = 0 Then AICLayouts(i) = pango_layout_new(AICPango)
			Dim As PangoFontDescription Ptr Desc = pango_font_description_new()
			pango_font_description_set_family(Desc, IIf(i = 4, CodeFont, UIFont))
			pango_font_description_set_size(Desc, CInt(Sz * EmK(i) * PANGO_SCALE))
			pango_font_description_set_weight(Desc, Weights(i))
			If i = 2 OrElse i = 3 Then pango_font_description_set_style(Desc, PANGO_STYLE_ITALIC)
			pango_layout_set_font_description(AICLayouts(i), Desc)
			pango_font_description_free(Desc)
			pango_layout_set_text(AICLayouts(i), "Xg", 2)
			pango_layout_get_pixel_extents(AICLayouts(i), NULL, @LR)
			AICFontH(i) = LR.height
			'pango has 96 points per inch
			AICEm(i) = Sz * 96 / 72 * EmK(i)
		Next
	End Sub

	Function AICTextW(ByRef S As WString, F As Integer) As Long
		If Len(S) = 0 OrElse AICLayouts(F) = 0 Then Return 0
		Dim As String U = ToUtf8(S)
		Dim As PangoRectangle LR
		pango_layout_set_text(AICLayouts(F), StrPtr(U), Len(U))
		pango_layout_get_pixel_extents(AICLayouts(F), NULL, @LR)
		Return LR.width
	End Function

	'How many characters of S from Pos0 (from 0) fit in MaxW (0 if none)
	Function AICFitChars(ByRef S As WString, Pos0 As Integer, F As Integer, MaxW As Long) As Integer
		Dim As Integer L = Len(S) - Pos0
		If L <= 0 Then Return 0
		If AICTextW(Mid(S, Pos0 + 1), F) <= MaxW Then Return L
		Dim As Integer Lo = 0, Hi = L, Md
		Do While Lo < Hi
			Md = (Lo + Hi + 1) \ 2
			If AICTextW(Mid(S, Pos0 + 1, Md), F) <= MaxW Then Lo = Md Else Hi = Md - 1
		Loop
		If Lo > 0 AndAlso Lo < L AndAlso S[Pos0 + Lo] >= &HDC00 AndAlso S[Pos0 + Lo] <= &HDFFF Then Lo -= 1
		Return Lo
	End Function
	#else
	Function AICColorRef(C As ULong) As COLORREF
		Return ((C And &HFF) Shl 16) Or (C And &HFF00) Or ((C Shr 16) And &HFF)
	End Function

	Sub AICCreateFonts()
		For i As Integer = 0 To AIC_FONTS - 1
			If AICFonts(i) Then DeleteObject(AICFonts(i)): AICFonts(i) = 0
		Next
		If AICDC = 0 Then AICDC = CreateCompatibleDC(0)
		Dim As Long H = -MulDiv(EditorFontSize, AICDpi, 72)
		Dim As WString * 64 UIFont = "Segoe UI", CodeFont = *EditorFontName
		AICFonts(0) = CreateFontW(H, 0, 0, 0, FW_NORMAL, 0, 0, 0, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, CLEARTYPE_QUALITY, DEFAULT_PITCH, @UIFont)
		AICFonts(1) = CreateFontW(H, 0, 0, 0, FW_SEMIBOLD, 0, 0, 0, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, CLEARTYPE_QUALITY, DEFAULT_PITCH, @UIFont)
		AICFonts(2) = CreateFontW(H, 0, 0, 0, FW_NORMAL, 1, 0, 0, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, CLEARTYPE_QUALITY, DEFAULT_PITCH, @UIFont)
		AICFonts(3) = CreateFontW(H, 0, 0, 0, FW_SEMIBOLD, 1, 0, 0, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, CLEARTYPE_QUALITY, DEFAULT_PITCH, @UIFont)
		AICFonts(4) = CreateFontW(H * 95 \ 100, 0, 0, 0, FW_NORMAL, 0, 0, 0, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, CLEARTYPE_QUALITY, FIXED_PITCH, @CodeFont)
		AICFonts(5) = CreateFontW(H * 150 \ 100, 0, 0, 0, FW_SEMIBOLD, 0, 0, 0, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, CLEARTYPE_QUALITY, DEFAULT_PITCH, @UIFont)
		AICFonts(6) = CreateFontW(H * 130 \ 100, 0, 0, 0, FW_SEMIBOLD, 0, 0, 0, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, CLEARTYPE_QUALITY, DEFAULT_PITCH, @UIFont)
		AICFonts(7) = CreateFontW(H * 115 \ 100, 0, 0, 0, FW_SEMIBOLD, 0, 0, 0, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, CLEARTYPE_QUALITY, DEFAULT_PITCH, @UIFont)
		AICFonts(8) = CreateFontW(H * 85 \ 100, 0, 0, 0, FW_NORMAL, 0, 0, 0, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, CLEARTYPE_QUALITY, DEFAULT_PITCH, @UIFont)
		Dim As TEXTMETRICW TM
		For i As Integer = 0 To AIC_FONTS - 1
			SelectObject(AICDC, AICFonts(i))
			GetTextMetricsW(AICDC, @TM)
			AICFontH(i) = TM.tmHeight + TM.tmExternalLeading
			AICAscent(i) = TM.tmAscent
		Next
		Dim As Single Em = EditorFontSize * AICDpi / 72
		Dim As Single EmK(AIC_FONTS - 1) = {1, 1, 1, 1, 0.95, 1.5, 1.3, 1.15, 0.85}
		For i As Integer = 0 To AIC_FONTS - 1
			AICEm(i) = Em * EmK(i)
		Next
		'The same fonts for DirectWrite (the size in pixels: the render target has 96 DPI)
		For i As Integer = 0 To AIC_FONTS - 1
			If AICFormats(i) Then AICFormats(i)->lpVtbl->Release(AICFormats(i)): AICFormats(i) = 0
		Next
		If pDWriteFactory = 0 Then Exit Sub
		Dim As Single Sz = MulDiv(EditorFontSize, AICDpi, 72)
		Dim As Single Sizes(AIC_FONTS - 1) = {Sz, Sz, Sz, Sz, Sz * 0.95, Sz * 1.5, Sz * 1.3, Sz * 1.15, Sz * 0.85}
		Dim As Long Weights(AIC_FONTS - 1) = {400, 600, 400, 600, 400, 600, 600, 600, 400}
		Dim As Long Styles(AIC_FONTS - 1) = {0, 0, 2, 2, 0, 0, 0, 0, 0}
		Dim As WString * 8 Locale = "en-us"
		Dim As IDWriteTextFormat Ptr TxtFmt
		For i As Integer = 0 To AIC_FONTS - 1
			TxtFmt = 0
			If i = 4 Then
				pDWriteFactory->lpVtbl->CreateTextFormat(pDWriteFactory, @CodeFont, 0, Weights(i), Styles(i), 5, Sizes(i), @Locale, @TxtFmt)
			Else
				pDWriteFactory->lpVtbl->CreateTextFormat(pDWriteFactory, @UIFont, 0, Weights(i), Styles(i), 5, Sizes(i), @Locale, @TxtFmt)
			End If
			If TxtFmt Then TxtFmt->lpVtbl->SetWordWrapping(TxtFmt, 1)
			AICFormats(i) = TxtFmt
			AICD2DDY(i) = 0
			If TxtFmt Then
				Dim As WString * 4 Probe = "Xg"
				Dim As IDWriteTextLayout Ptr L
				pDWriteFactory->lpVtbl->CreateTextLayout(pDWriteFactory, @Probe, 2, TxtFmt, 1000, 1000, @L)
				If L Then
					Dim As DWRITE_LINE_METRICS LM
					Dim As ULong LC
					If L->lpVtbl->GetLineMetrics(L, @LM, 1, @LC) = S_OK Then AICD2DDY(i) = AICAscent(i) - LM.baseline
					L->lpVtbl->Release(L)
				End If
			End If
		Next
	End Sub

	Function AICTextW(ByRef S As WString, F As Integer) As Long
		If Len(S) = 0 Then Return 0
		If AICUseD2D AndAlso AICFormats(F) <> 0 Then
			Dim As IDWriteTextLayout Ptr L
			pDWriteFactory->lpVtbl->CreateTextLayout(pDWriteFactory, @S, Len(S), AICFormats(F), 100000, 100000, @L)
			If L Then
				Dim As DWRITE_TEXT_METRICS TM
				L->lpVtbl->GetMetrics(L, Cast(Any Ptr, @TM))
				L->lpVtbl->Release(L)
				Return CLng(TM.widthIncludingTrailingWhitespace)
			End If
		End If
		Dim As SIZE Sz
		SelectObject(AICDC, AICFonts(F))
		GetTextExtentPoint32W(AICDC, @S, Len(S), @Sz)
		Return Sz.cx
	End Function

	'How many characters of S from Pos0 (from 0) fit in MaxW (0 if none)
	Function AICFitChars(ByRef S As WString, Pos0 As Integer, F As Integer, MaxW As Long) As Integer
		Dim As Integer L = Len(S) - Pos0, Fit
		If L <= 0 Then Return 0
		If AICUseD2D Then
			If AICTextW(*(@S + Pos0), F) <= MaxW Then Return L
			Dim As Integer Lo = 0, Hi = L, Md
			Do While Lo < Hi
				Md = (Lo + Hi + 1) \ 2
				If AICTextW(Mid(S, Pos0 + 1, Md), F) <= MaxW Then Lo = Md Else Hi = Md - 1
			Loop
			Fit = Lo
		Else
			Dim As Long LFit
			Dim As SIZE Sz
			SelectObject(AICDC, AICFonts(F))
			GetTextExtentExPointW(AICDC, @S + Pos0, L, MaxW, @LFit, 0, @Sz)
			Fit = LFit
		End If
		'Not between the halves of a character (an emoji)
		If Fit > 0 AndAlso Fit < L AndAlso S[Pos0 + Fit] >= &HDC00 AndAlso S[Pos0 + Fit] <= &HDFFF Then Fit -= 1
		Return Fit
	End Function
	#endif

	Sub AICAddOp(Kind As Integer, X As Long, Y As Long, W As Long, H As Long, F As Integer, Clr As ULong, Clr2 As ULong = 0, ByRef Text As WString = "", ByRef Action As WString = "")
		With AICMsgs(AICCur)
			If .OpCount > UBound(.Ops) Then ReDim Preserve .Ops(.OpCount * 2 + 31)
			.Ops(.OpCount).Kind = Kind
			.Ops(.OpCount).X = X
			.Ops(.OpCount).Y = Y
			.Ops(.OpCount).W = W
			.Ops(.OpCount).H = H
			.Ops(.OpCount).Font = F
			.Ops(.OpCount).Clr = Clr
			.Ops(.OpCount).Clr2 = Clr2
			.Ops(.OpCount).Text = Text
			.Ops(.OpCount).Action = Action
			.Ops(.OpCount).SY = Y
			.Ops(.OpCount).SH = H
			.OpCount += 1
		End With
	End Sub

	'The line of the last text (its selection)
	Sub AICLineBand(Y As Long, LineH As Long)
		With AICMsgs(AICCur)
			If .OpCount = 0 Then Exit Sub
			.Ops(.OpCount - 1).SY = Y
			.Ops(.OpCount - 1).SH = LineH
		End With
	End Sub

	'A text of a line (the texts of the same style on a line are one text)
	Sub AICEmitText(X As Long, Y As Long, LineH As Long, ByRef Text As WString, F As Integer, Clr As ULong, Style As Integer, ByRef LinkTo As WString, W As Long)
		Dim As Long TY = Y + (LineH - AICFontH(F)) \ 2
		Dim As Boolean Merged
		If Style And AIS_CODE Then
			'The words of a code on the same line: one background
			With AICMsgs(AICCur)
				If .OpCount > 1 AndAlso (Style And AIS_LINK) = 0 Then
					If .Ops(.OpCount - 1).Kind = 1 AndAlso .Ops(.OpCount - 1).Font = F AndAlso .Ops(.OpCount - 1).Y = TY AndAlso .Ops(.OpCount - 1).X + .Ops(.OpCount - 1).W = X AndAlso .Ops(.OpCount - 2).Kind = 3 AndAlso .Ops(.OpCount - 2).Y = TY Then
						.Ops(.OpCount - 2).W += W
						.Ops(.OpCount - 1).Text &= Text
						.Ops(.OpCount - 1).W += W
						Exit Sub
					End If
				End If
			End With
			AICAddOp(3, X - 2, TY, W + 4, AICFontH(F), 0, AICColors.CodeBack, AICColors.Border)
		End If
		With AICMsgs(AICCur)
			If .OpCount > 0 AndAlso (Style And AIS_LINK) = 0 AndAlso (Style And AIS_CODE) = 0 Then
				With .Ops(.OpCount - 1)
					'Clr2 <> 0: a text that is not joined (the marker of a list)
					If .Kind = 1 AndAlso .Clr2 = 0 AndAlso .Y = TY AndAlso .Font = F AndAlso .Clr = Clr AndAlso .X + .W = X Then
						.Text &= Text
						.W += W
						Merged = True
					End If
				End With
			End If
		End With
		If Not Merged Then
			AICAddOp(1, X, TY, W, AICFontH(F), F, Clr, 0, Text)
			AICLineBand Y, LineH
		End If
		If Style And AIS_LINK Then AICAddOp(6, X, Y, W, LineH, 0, 0, 0, "", "link:" & LinkTo)
	End Sub

	'The words of a markdown text from X0 (the width W) and Y; returns the Y under the last line
	Function AICFlow(ByRef MD As WString, X0 As Long, ByVal W As Long, ByVal Y As Long, BaseFont As Integer, Clr As ULong) As Long
		Dim As AIRun Runs(Any)
		Dim As Integer n = AIParseInline(MD, Runs()), F, i, j, WordEnd, L, Pos0
		Dim As Long Fit
		Dim As Long LineH = AICLineH(BaseFont), X = X0, WW, PW, SW
		Dim As ULong C
		Dim As UString S, Word, Piece, Part
		If W < AICScale(24) Then W = AICScale(24)
		For r As Integer = 0 To n - 1
			F = BaseFont
			If Runs(r).Style And AIS_CODE Then
				F = 4
			ElseIf BaseFont = 0 Then
				F = Runs(r).Style And 3
			End If
			C = IIf(Runs(r).Style And AIS_LINK, AICColors.Link, Clr)
			S = Runs(r).Text
			L = Len(S)
			i = 0
			Do While i < L
				If S[i] = 10 Then
					X = X0: Y += LineH: i += 1
					Continue Do
				End If
				j = i
				Do While j < L AndAlso S[j] <> 32 AndAlso S[j] <> 10
					j += 1
				Loop
				WordEnd = j
				Do While j < L AndAlso S[j] = 32
					j += 1
				Loop
				Word = Mid(S, i + 1, WordEnd - i)
				Piece = Mid(S, i + 1, j - i)
				WW = AICTextW(Word, F)
				PW = AICTextW(Piece, F)
				If X > X0 AndAlso X + WW > X0 + W Then
					X = X0: Y += LineH
				End If
				If WW > W Then
					'A word longer than the line: its characters on the lines
					Pos0 = 0
					Do While Pos0 < Len(Piece)
						Fit = AICFitChars(*Piece.vptr, Pos0, F, X0 + W - X)
						If Fit < 1 Then
							If X > X0 Then
								X = X0: Y += LineH
								Continue Do
							End If
							Fit = AICOneChar(*Piece.vptr, Pos0)
						End If
						Part = Mid(Piece, Pos0 + 1, Fit)
						SW = AICTextW(Part, F)
						AICEmitText(X, Y, LineH, Part, F, C, Runs(r).Style, Runs(r).Link, SW)
						X += SW
						If X > AICMaxX Then AICMaxX = X
						Pos0 += Fit
						If Pos0 < Len(Piece) Then X = X0: Y += LineH
					Loop
				Else
					AICEmitText(X, Y, LineH, Piece, F, C, Runs(r).Style, Runs(r).Link, PW)
					If X + WW > AICMaxX Then AICMaxX = X + WW
					X += PW
				End If
				i = j
			Loop
		Next
		Return Y + LineH
	End Function

	#ifndef __USE_WINAPI__
	'The index of the picture of the file (-1: it is not a picture or not a file)
	Function AICImage(ByRef Path As WString) As Integer
		For i As Integer = 0 To AICImgCount - 1
			If AICImgPath(i) = Path Then Return IIf(AICImgPix(i) <> 0, i, -1)
		Next
		Dim As GdkPixbuf Ptr Img
		If InStr(Path, "://") = 0 AndAlso FileExists(Path) Then Img = gdk_pixbuf_new_from_file(ToUtf8(Path), NULL)
		Dim As Integer n = AICImgCount
		ReDim Preserve AICImgPath(n), AICImgPix(n), AICImgW(n), AICImgH(n)
		AICImgPath(n) = Path
		AICImgPix(n) = Img
		If Img Then
			AICImgW(n) = gdk_pixbuf_get_width(Img): AICImgH(n) = gdk_pixbuf_get_height(Img)
			If AICImgW(n) = 0 OrElse AICImgH(n) = 0 Then g_object_unref(Img): AICImgPix(n) = 0
		End If
		AICImgCount += 1
		Return IIf(AICImgPix(n) <> 0, n, -1)
	End Function

	Sub AICInvalidate()
		If AICWnd Then gtk_widget_queue_draw(AICWnd)
	End Sub
	#else
	Sub AICInvalidate()
		If AICWnd Then InvalidateRect(AICWnd, 0, False)
	End Sub

	'The index of the picture of the file (-1: it is not a picture or not a file)
	Function AICImage(ByRef Path As WString) As Integer
		For i As Integer = 0 To AICImgCount - 1
			If AICImgPath(i) = Path Then Return IIf(AICImgGp(i) <> 0, i, -1)
		Next
		Dim As GpImage Ptr Img
		If InStr(Path, "://") = 0 AndAlso AICGdipToken <> 0 Then
			If GdipLoadImageFromFile(@Path, @Img) <> 0 Then Img = 0
		End If
		Dim As Integer n = AICImgCount
		ReDim Preserve AICImgPath(n), AICImgGp(n), AICImgD2D(n), AICImgW(n), AICImgH(n)
		AICImgPath(n) = Path
		AICImgGp(n) = Img
		AICImgD2D(n) = 0
		If Img Then
			Dim As UINT IW, IH
			GdipGetImageWidth(Img, @IW)
			GdipGetImageHeight(Img, @IH)
			AICImgW(n) = IW: AICImgH(n) = IH
			If IW = 0 OrElse IH = 0 Then GdipDisposeImage(Img): AICImgGp(n) = 0
		End If
		AICImgCount += 1
		Return IIf(AICImgGp(n) <> 0, n, -1)
	End Function

	'The bitmap of Direct2D of the picture (made in the render target once)
	Function AICImageD2D(Index As Integer) As ID2D1Bitmap Ptr
		If AICImgD2D(Index) <> 0 OrElse AICRT = 0 Then Return AICImgD2D(Index)
		Dim As GpBitmap Ptr Bmp = Cast(GpBitmap Ptr, AICImgGp(Index))
		Dim As GpRect R
		R.X = 0: R.Y = 0: R.Width = AICImgW(Index): R.Height = AICImgH(Index)
		Dim As BitmapData BD
		'PixelFormat32bppPARGB, ImageLockModeRead
		If GdipBitmapLockBits(Bmp, @R, 1, &HE200B, @BD) <> 0 Then Return 0
		Dim As D2D1_BITMAP_PROPERTIES BP
		BP.pixelFormat.format = 87 'DXGI_FORMAT_B8G8R8A8_UNORM
		BP.pixelFormat.alphaMode = 1 'D2D1_ALPHA_MODE_PREMULTIPLIED
		BP.dpiX = 96: BP.dpiY = 96
		Dim As D2D1_SIZE_U Sz
		Sz.Width = BD.Width: Sz.height = BD.Height
		Dim As ID2D1Bitmap Ptr D2Bmp
		Cast(ID2D1RenderTarget Ptr, AICRT)->lpVtbl->CreateBitmap(Cast(ID2D1RenderTarget Ptr, AICRT), Sz, BD.Scan0, BD.Stride, @BP, @D2Bmp)
		GdipBitmapUnlockBits(Bmp, @BD)
		AICImgD2D(Index) = D2Bmp
		Return D2Bmp
	End Function
	#endif

	Function AICIsOpen(ByRef Key As WString) As Boolean
		Return InStr(AICOpenFolds, "|" & Str(AICCur) & ":" & Key & "|") > 0
	End Function

	Function AICLayoutCode(ByRef Code As WString, ByRef Lang As WString, X0 As Long, W As Long, ByVal Y As Long) As Long
		Dim As Long Top = Y, Pad = AICScale(8), SmallH = AICFontH(8), HeadH = SmallH + AICScale(8), CodeLH = Max(AICFontH(4), CLng(AICEm(0) * 1.35))
		Dim As UString TCopy = ML("Copy"), TEdit = ML("Edit"), Lns(Any), Ln, Part
		Dim As Long WCopy = AICTextW(TCopy, 8), WEdit = AICTextW(TEdit, 8), BX, PartW
		Dim As Integer n, P
		Dim As Long Fit
		'The language and the buttons
		If Lang <> "" Then AICAddOp(1, X0 + Pad, Y + AICScale(4), AICTextW(Lang, 8), SmallH, 8, AICColors.Muted, 2, Lang)
		BX = X0 + W - Pad - WCopy
		AICAddOp(1, BX, Y + AICScale(4), WCopy, SmallH, 8, AICColors.Muted, 2, TCopy)
		AICAddOp(6, BX - AICScale(4), Y, WCopy + AICScale(8), HeadH, 0, 0, 0, "", "copy:" & Code)
		BX -= AICScale(16) + WEdit
		AICAddOp(1, BX, Y + AICScale(4), WEdit, SmallH, 8, AICColors.Muted, 2, TEdit)
		AICAddOp(6, BX - AICScale(4), Y, WEdit + AICScale(8), HeadH, 0, 0, 0, "", "edit:" & Code)
		Y += HeadH
		AICAddOp(2, X0, Y, W, 1, 0, AICColors.Border)
		Y += Pad \ 2
		'The lines, the long ones wrap
		n = AISplitLines(Code, Lns())
		For k As Integer = 0 To n - 1
			Ln = Replace(Lns(k), WChr(9), "    ")
			If Len(Ln) = 0 Then Y += CodeLH: Continue For
			P = 0
			Do While P < Len(Ln)
				Fit = AICFitChars(*Ln.vptr, P, 4, Max(W - 2 * Pad, AICScale(20)))
				If Fit < 1 Then Fit = AICOneChar(*Ln.vptr, P)
				Part = Mid(Ln, P + 1, Fit)
				PartW = AICTextW(Part, 4)
				AICAddOp(1, X0 + Pad, Y + (CodeLH - AICFontH(4)) \ 2, PartW, AICFontH(4), 4, AICColors.Fore, 0, Part)
				P += Fit
				Y += CodeLH
			Loop
		Next
		Y += Pad \ 2
		'The frame (the right click: its code)
		AICAddOp(3, X0, Top, W, Y - Top, 0, AICColors.CodeBack, AICColors.Border, "", "code:" & Code)
		If X0 + W > AICMaxX Then AICMaxX = X0 + W
		Return Y
	End Function

	Function AICLayoutTable(ByRef Rows As WString, X0 As Long, W As Long, ByVal Y As Long) As Long
		Dim As UString Lns(Any), RowCells(Any), Cells(Any, Any)
		Dim As Integer RC = AISplitLines(Rows, Lns()), Cols, C
		For r As Integer = 0 To RC - 1
			C = AITableCells(Lns(r), RowCells())
			If C > Cols Then Cols = C
		Next
		If Cols = 0 OrElse RC = 0 Then Return Y
		ReDim Cells(RC - 1, Cols - 1)
		For r As Integer = 0 To RC - 1
			C = AITableCells(Lns(r), RowCells())
			For k As Integer = 0 To C - 1
				Cells(r, k) = Trim(RowCells(k))
			Next
		Next
		'The widths: the natural widths, the wide columns are narrowed to the width of the panel
		Dim As Long CW(Cols - 1), Pad = AICScale(6), Total, Fair, Narrow, WideTotal, Nat
		For k As Integer = 0 To Cols - 1
			For r As Integer = 0 To RC - 1
				Nat = AICTextW(Cells(r, k), IIf(r = 0, 1, 0)) + 2 * Pad
				If Nat > CW(k) Then CW(k) = Nat
			Next
			Total += CW(k)
		Next
		If Total > W Then
			Fair = W \ Cols
			For k As Integer = 0 To Cols - 1
				If CW(k) <= Fair Then Narrow += CW(k) Else WideTotal += CW(k)
			Next
			Total = 0
			For k As Integer = 0 To Cols - 1
				If CW(k) > Fair AndAlso WideTotal > 0 Then CW(k) = Max(AICScale(40), CLng(CDbl(CW(k)) * (W - Narrow) / WideTotal))
				Total += CW(k)
			Next
		End If
		Dim As Long Top = Y, X, Bottom, B
		For r As Integer = 0 To RC - 1
			X = X0: Bottom = Y
			For k As Integer = 0 To Cols - 1
				B = AICFlow(Cells(r, k), X + Pad, CW(k) - 2 * Pad, Y + Pad \ 2, IIf(r = 0, 1, 0), AICColors.Fore) + Pad \ 2
				If B > Bottom Then Bottom = B
				X += CW(k)
			Next
			If r = 0 Then AICAddOp(2, X0, Y, Total, Bottom - Y, 0, AICColors.CodeBack)
			AICAddOp(2, X0, Y, Total, 1, 0, AICColors.Border)
			Y = Bottom
		Next
		AICAddOp(2, X0, Y, Total, 1, 0, AICColors.Border)
		X = X0
		For k As Integer = 0 To Cols
			AICAddOp(2, X, Top, 1, Y - Top + 1, 0, AICColors.Border)
			If k < Cols Then X += CW(k)
		Next
		If X0 + Total > AICMaxX Then AICMaxX = X0 + Total
		Return Y + 1
	End Function

	'The lines added (green) and removed (red) after a title: the width of them
	Function AICDiffOps(X As Long, Y As Long, LineH As Long, Added As Integer, Removed As Integer) As Long
		Dim As Long W0, TW
		Dim As UString T
		If Added > 0 Then
			T = "  +" & Str(Added)
			TW = AICTextW(T, 0)
			AICAddOp(1, X + W0, Y + (LineH - AICFontH(0)) \ 2, TW, AICFontH(0), 0, IIf(AIChatIsDark(), &H5BC46A, &H2E8B3E), 0, T)
			W0 += TW
		End If
		If Removed > 0 Then
			T = "  " & WChr(8722) & Str(Removed)
			TW = AICTextW(T, 0)
			AICAddOp(1, X + W0, Y + (LineH - AICFontH(0)) \ 2, TW, AICFontH(0), 0, IIf(AIChatIsDark(), &HF07272, &HC83232), 0, T)
			W0 += TW
		End If
		If X + W0 > AICMaxX Then AICMaxX = X + W0
		Return W0
	End Function

	'The tasks of Claude Code in a frame: Tasks 2/6, the mark of the state and the text of each of them
	Function AICLayoutTasks(ByRef Tasks As WString, X0 As Long, W As Long, ByVal Y As Long) As Long
		Dim As UString St(Any), Tx(Any), Head, Mark
		Dim As Integer Done, n = AITaskCounts(Tasks, St(), Tx(), Done)
		If n = 0 Then Return Y
		Dim As Long Top = Y, Pad = AICScale(10), SmallH = AICFontH(8), LineH = AICLineH(0), MW = AICScale(20), First
		'The frame first (its texts are drawn over it)
		First = AICMsgs(AICCur).OpCount
		AICAddOp(3, X0, Top, W, 0, 0, AICColors.Back, AICColors.Border)
		Y += AICScale(6)
		Head = ML("Tasks") & " " & Str(Done) & "/" & Str(n)
		AICAddOp(1, X0 + Pad, Y, AICTextW(Head, 8), SmallH, 8, AICColors.Muted, 0, Head)
		Y += SmallH + AICScale(4)
		For i As Integer = 0 To n - 1
			Mark = AITaskMark(St(i))
			AICAddOp(1, X0 + Pad, Y + (LineH - AICFontH(0)) \ 2, AICTextW(Mark, 0), AICFontH(0), 0, AICColors.Muted, 0, Mark)
			Y = AICFlow(Tx(i), X0 + Pad + MW, W - 2 * Pad - MW, Y, IIf(St(i) = "in_progress", 1, 0), IIf(St(i) = "completed", AICColors.Muted, AICColors.Fore))
		Next
		Y += AICScale(6)
		AICMsgs(AICCur).Ops(First).H = Y - Top
		If X0 + W > AICMaxX Then AICMaxX = X0 + W
		Return Y
	End Function

	Function AICLayoutBlocks(ByRef MD As WString, X0 As Long, W As Long, ByVal Y As Long, ByRef KeyPrefix As WString, ToolsApart As Boolean = False) As Long
		Dim As AIBlock Blocks(Any)
		Dim As Integer Count = AIParseBlocks(MD, Blocks(), ToolsApart), FoldNo
		Dim As Integer DiffAdded, DiffRemoved
		'The margins of the browser: p 8px, li 3px, h 12px over and 6px under
		Dim As Long Gap = AICScale(8), Ind, MW, LineH = AICLineH(0), Top, TW
		Dim As UString Key, Title, Caption
		Dim As Boolean IsOpen
		For b As Integer = 0 To Count - 1
			Select Case Blocks(b).Kind
			Case abPara
				Y = AICFlow(Blocks(b).Text, X0, W, Y, 0, AICColors.Fore) + Gap
			Case abHead
				If b > 0 Then Y += AICScale(4)
				Y = AICFlow(Blocks(b).Text, X0, W, Y, IIf(Blocks(b).Level <= 1, 5, IIf(Blocks(b).Level = 2, 6, 7)), AICColors.Fore) + AICScale(6)
			Case abItem
				Ind = Blocks(b).Level * AICScale(16)
				MW = Max(AICTextW(Blocks(b).Marker & " ", 0), AICScale(16))
				AICAddOp(1, X0 + Ind, Y + (LineH - AICFontH(0)) \ 2, MW, AICFontH(0), 0, AICColors.Fore, 1, Blocks(b).Marker)
				AICLineBand Y, LineH
				Y = AICFlow(Blocks(b).Text, X0 + Ind + MW, W - Ind - MW, Y, 0, AICColors.Fore) + AICScale(3)
			Case abCode
				Y = AICLayoutCode(Blocks(b).Text, Blocks(b).Lang, X0, W, Y) + Gap
			Case abTable
				Y = AICLayoutTable(Blocks(b).Text, X0, W, Y) + Gap
			Case abQuote
				Top = Y
				Y = AICFlow(Blocks(b).Text, X0 + AICScale(12), W - AICScale(12), Y, 0, AICColors.Muted)
				AICAddOp(2, X0 + AICScale(2), Top, AICScale(3), Y - Top, 0, AICColors.Border)
				Y += Gap
			Case abRule
				AICAddOp(2, X0, Y + Gap, W, 1, 0, AICColors.Border)
				Y += Gap * 2 + 1
			Case abImage
				Caption = Blocks(b).Marker
				If Caption = "" Then Caption = Blocks(b).Text
				Dim As Integer Img = AICImage(Blocks(b).Text)
				If Img >= 0 Then
					'Like in the browser: the picture in its size (not wider than the text) with rounded corners,
					'under it its name as a link; a click opens it
					Dim As Double Sc = AICDpi / 96
					Dim As Long DW, DH, CapY
					If AICImgW(Img) * Sc > W Then Sc = W / AICImgW(Img)
					DW = Max(1, CLng(AICImgW(Img) * Sc)): DH = Max(1, CLng(AICImgH(Img) * Sc))
					AICAddOp(4, X0, Y, DW, DH, Img, AICPicBack)
					AICAddOp(6, X0, Y, DW, DH, 0, 0, 0, "", "link:" & Blocks(b).Text)
					If X0 + DW > AICMaxX Then AICMaxX = X0 + DW
					Y += DH + AICScale(4)
					CapY = Y
					Y = AICFlow(Caption, X0, W, Y, 0, AICColors.Link)
					AICAddOp(6, X0, CapY, Min(W, AICTextW(Caption, 0)), Y - CapY, 0, 0, 0, "", "link:" & Blocks(b).Text)
					Y += Gap
				Else
					Y = AICFlow("[" & ML("Image") & ": " & Caption & "](" & Blocks(b).Text & ")", X0, W, Y, 0, AICColors.Fore) + Gap
				End If
			Case abTasks
				Y = AICLayoutTasks(Blocks(b).Text, X0, W, Y) + Gap
			Case abStatus
				Dim As UString StatusText = AITaskMark("in_progress") & "  " & Blocks(b).Text
				Dim As Integer StatusFit = AICFitChars(StatusText, 0, 0, W)
				If StatusFit < Len(StatusText) Then StatusText = Left(StatusText, Max(StatusFit - 3, 1)) & "..."
				AICAddOp(1, X0, Y + (LineH - AICFontH(0)) \ 2, AICTextW(StatusText, 0), AICFontH(0), 0, AICColors.Muted, 0, StatusText)
				Y += LineH + Gap
			Case abFold
				Select Case Blocks(b).FoldKind
				Case 1
					Key = KeyPrefix & Str(FoldNo)
					IsOpen = AICIsOpen(Key)
					Title = AIThinkTitle(Blocks(b).Closed)
				Case 2
					'The calls of the tools: the fold is open, the key is of its closing
					Key = KeyPrefix & "g" & Str(FoldNo)
					IsOpen = Not AICIsOpen(Key)
					Title = AIToolsGroupTitle(Blocks(b).Text, DiffAdded, DiffRemoved)
				Case Else
					If ToolsApart Then Key = KeyPrefix & Str(FoldNo) Else Key = KeyPrefix & "g" & Str(FoldNo) & ".0"
					IsOpen = AICIsOpen(Key) AndAlso Blocks(b).Level <> AITOOL_NODETAILS
					Title = ""
				End Select
				FoldNo += 1
				If Blocks(b).FoldKind = 3 Then
					'A call: the name (bold) and what it does (code), the cross of an error
					Dim As UString Head = IIf(Blocks(b).Level = AITOOL_NODETAILS, "", IIf(IsOpen, WChr(9662), WChr(9656)) & "  ") & Blocks(b).Marker
					Dim As UString Summary = AIToolTitleText(Blocks(b))
					Dim As Long HW = AICTextW(Head, 1), SX, SW, Avail
					Dim As ULong ErrClr = IIf(AIChatIsDark(), &HF07272, &HC83232)
					AICAddOp(1, X0, Y + (LineH - AICFontH(1)) \ 2, HW, AICFontH(1), 1, AICColors.Muted, 0, Head)
					TW = HW
					If Blocks(b).Level = AITOOL_ERROR Then
						Dim As UString Cross = "  " & WChr(10007)
						Dim As Long CW = AICTextW(Cross, 0)
						AICAddOp(1, X0 + TW, Y + (LineH - AICFontH(0)) \ 2, CW, AICFontH(0), 0, ErrClr, 0, Cross)
						TW += CW
					End If
					If Summary <> "" Then
						SX = X0 + TW + AICTextW("  ", 0)
						Avail = W - (SX - X0)
						'The numbers of the lines of Edit and Write stay seen
						If Blocks(b).Lang <> "" Then
							Dim As Integer SA, SR
							AIToolDiffCount(Blocks(b).Marker, Blocks(b).Lang, SA, SR)
							Avail -= AICTextW(IIf(SA > 0, "  +" & Str(SA), "") & IIf(SR > 0, "  " & WChr(8722) & Str(SR), ""), 0)
						End If
						If Avail > AICScale(30) Then
							SW = AICTextW(Summary, 4)
							If SW > Avail Then
								Dim As Integer Fit = AICFitChars(Summary, 0, 4, Avail - AICTextW("...", 4))
								Summary = Left(Summary, Max(Fit, 1)) & "..."
								SW = AICTextW(Summary, 4)
							End If
							AICAddOp(1, SX, Y + (LineH - AICFontH(4)) \ 2, SW, AICFontH(4), 4, IIf(Blocks(b).Level = AITOOL_ERROR, ErrClr, AICColors.Muted), 0, Summary)
							TW = SX - X0 + SW
						End If
					End If
					If Blocks(b).Lang <> "" Then
						DiffAdded = 0: DiffRemoved = 0
						AIToolDiffCount(Blocks(b).Marker, Blocks(b).Lang, DiffAdded, DiffRemoved)
						TW += AICDiffOps(X0 + TW, Y, LineH, DiffAdded, DiffRemoved)
					End If
					If Blocks(b).Level <> AITOOL_NODETAILS Then AICAddOp(6, X0, Y, TW, LineH, 0, 0, 0, "", "fold:" & Key)
					If X0 + TW > AICMaxX Then AICMaxX = X0 + TW
					Y += LineH
					If IsOpen Then
						Top = Y + AICScale(2)
						Y = AICLayoutBlocks(AIToolBodyMD(Blocks(b).Marker, Blocks(b).Lang, Blocks(b).Text, Blocks(b).Level), X0 + AICScale(16), W - AICScale(16), Top, Key & ".")
						AICAddOp(2, X0 + AICScale(5), Top, AICScale(2), Y - Top, 0, AICColors.Border)
					End If
					Y += AICScale(2)
				Else
					Title = IIf(IsOpen, WChr(9662), WChr(9656)) & "  " & Title
					TW = AICTextW(Title, 0)
					If Blocks(b).FoldKind = 2 AndAlso (DiffAdded > 0 OrElse DiffRemoved > 0) Then
						'The numbers of the lines stay seen: the title is shortened
						Dim As Long DW = AICTextW(IIf(DiffAdded > 0, "  +" & Str(DiffAdded), "") & IIf(DiffRemoved > 0, "  " & WChr(8722) & Str(DiffRemoved), ""), 0)
						If TW + DW > W Then
							Dim As Integer TitleFit = AICFitChars(Title, 0, 0, Max(W - DW - AICTextW("...", 0), AICScale(30)))
							Title = Left(Title, Max(TitleFit, 1)) & "..."
							TW = AICTextW(Title, 0)
						End If
					End If
					AICAddOp(1, X0, Y + (LineH - AICFontH(0)) \ 2, TW, AICFontH(0), 0, AICColors.Muted, 0, Title)
					If Blocks(b).FoldKind = 2 Then TW += AICDiffOps(X0 + TW, Y, LineH, DiffAdded, DiffRemoved)
					AICAddOp(6, X0, Y, TW, LineH, 0, 0, 0, "", "fold:" & Key)
					If X0 + TW > AICMaxX Then AICMaxX = X0 + TW
					Y += LineH
					If IsOpen Then
						Top = Y
						Y = AICLayoutBlocks(Blocks(b).Text, X0 + AICScale(16), W - AICScale(16), Y, Key & ".", Blocks(b).FoldKind = 2)
						AICAddOp(2, X0 + AICScale(5), Top, AICScale(2), Y - Top, 0, AICColors.Border)
					End If
					Y += Gap \ 2
				End If
			End Select
		Next
		Return Y
	End Function

	Sub AICLayoutMessage(Index As Integer)
		AICCur = Index
		AICPicBack = AICColors.Back
		Dim As Long Pad = AICScale(14), W = Max(AICClientW - 2 * Pad, AICScale(60)), Y = AICScale(6), SmallH = AICFontH(8)
		Dim As Long BP = AICScale(10), VP = AICScale(6), BW, First, Top, CB, BubbleW, DX, HW
		AICMsgs(Index).OpCount = 0
		If AICMsgs(Index).IsUser Then
			'The question: on the right in a bubble
			If AICMsgs(Index).Header <> "" Then
				HW = AICTextW(AICMsgs(Index).Header, 8)
				AICAddOp(1, Pad + W - HW, Y, HW, SmallH, 8, AICColors.Muted, 0, AICMsgs(Index).Header)
				Y += SmallH + AICScale(3)
			End If
			BW = W * 85 \ 100 - 2 * BP
			First = AICMsgs(Index).OpCount
			Top = Y
			AICMaxX = 0
			AICPicBack = AICColors.Bubble
			AICLayoutBlocks(AICMsgs(Index).Body, 0, BW, Y + VP, "")
			AICPicBack = AICColors.Back
			CB = Top + VP
			For k As Integer = First To AICMsgs(Index).OpCount - 1
				If AICMsgs(Index).Ops(k).Kind <> 6 AndAlso AICMsgs(Index).Ops(k).Y + AICMsgs(Index).Ops(k).H > CB Then CB = AICMsgs(Index).Ops(k).Y + AICMsgs(Index).Ops(k).H
			Next
			BubbleW = Min(BW, Max(AICMaxX, AICScale(10))) + 2 * BP
			DX = Pad + W - BubbleW + BP
			For k As Integer = First To AICMsgs(Index).OpCount - 1
				AICMsgs(Index).Ops(k).X += DX
			Next
			AICAddOp(3, Pad + W - BubbleW, Top, BubbleW, CB + VP - Top, 0, AICColors.Bubble, AICColors.Bubble, "", "msg:")
			Y = CB + VP
		Else
			If AICMsgs(Index).Header <> "" Then
				AICAddOp(1, Pad, Y, AICTextW(AICMsgs(Index).Header, 8), SmallH, 8, AICColors.Muted, 0, AICMsgs(Index).Header)
				Y += SmallH + AICScale(3)
			End If
			AICMaxX = 0
			Y = AICLayoutBlocks(AICMsgs(Index).Body, Pad, W, Y, "")
		End If
		AICMsgs(Index).H = Y + AICScale(8)
	End Sub

	Sub AICPositions()
		Dim As Long Y = AICScale(4)
		For i As Integer = 0 To AICMsgCount - 1
			AICMsgs(i).Y = Y
			Y += AICMsgs(i).H
		Next
		AICTotalH = Y + AICScale(12)
	End Sub

	Function AICAtBottom() As Boolean
		Return AICScroll >= AICTotalH - AICClientH - AICScale(40)
	End Function

	Sub AICUpdateScroll(ToBottom As Boolean)
		If AICWnd = 0 Then Exit Sub
		Dim As Long MaxS = Max(0, AICTotalH - AICClientH)
		If ToBottom Then AICScroll = MaxS
		AICScroll = Max(0, Min(AICScroll, MaxS))
		#ifndef __USE_WINAPI__
			'The adjustment of the scroll bar: the page is the height of the panel
			Dim As GtkAdjustment Ptr Adj
			#ifdef __USE_GTK4__
				Adj = gtk4compat_range_adjustment(scrAIC.Handle)
			#else
				Adj = gtk_range_get_adjustment(GTK_RANGE(scrAIC.Handle))
			#endif
			If Adj = 0 Then Exit Sub
			AICScrollSetting = True
			gtk_adjustment_configure(Adj, AICScroll, 0, Max(AICTotalH, AICClientH), AICLineH(0) * 3, Max(1, AICClientH - AICLineH(0)), Max(1, AICClientH))
			AICScrollSetting = False
		#else
		Dim As SCROLLINFO SI
		SI.cbSize = SizeOf(SI)
		SI.fMask = SIF_RANGE Or SIF_PAGE Or SIF_POS Or SIF_DISABLENOSCROLL
		SI.nMin = 0
		SI.nMax = Max(0, AICTotalH - 1)
		SI.nPage = Max(0, AICClientH)
		SI.nPos = AICScroll
		SetScrollInfo(AICWnd, SB_VERT, @SI, True)
		#endif
	End Sub

	Sub AICScrollTo(NewPos As Long)
		AICScroll = NewPos
		AICUpdateScroll(False)
		AICInvalidate
	End Sub

	Sub AICRelayoutAll()
		AICSelA = Type<AICPos>(0, 0, 0): AICSelB = AICSelA
		For i As Integer = 0 To AICMsgCount - 1
			AICLayoutMessage(i)
		Next
		AICPositions
	End Sub

	'The new text of the chat: the last message of the view is made again, the new ones are added
	Sub AICUpdate()
		If AICWnd = 0 Then Exit Sub
		Dim As AIChatMessage Msgs(Any)
		Dim As Integer Count
		Dim As Boolean Full
		Dim As Integer First = AIChatTakeMessages(Msgs(), Count, Full)
		Dim As Boolean WasBottom = AICAtBottom()
		If Full Then AICMsgCount = 0: AICOpenFolds = "": AICScroll = 0: AICColors = AIChatPalette(): AICSelB = AICSelA
		Dim As Integer NewCount = IIf(Count > 0, First + Count, AICMsgCount)
		If NewCount > UBound(AICMsgs) + 1 Then ReDim Preserve AICMsgs(NewCount + 15)
		For k As Integer = 0 To Count - 1
			AICMsgs(First + k).IsUser = Msgs(k).IsUser
			AICMsgs(First + k).Header = Msgs(k).Header
			AICMsgs(First + k).Body = Msgs(k).Body
			AICLayoutMessage(First + k)
		Next
		AICMsgCount = NewCount
		AICPositions
		AICUpdateScroll(WasBottom OrElse Full)
		AICInvalidate
	End Sub

	#ifdef __USE_WINAPI__
	Sub AICFillShape(G As GpGraphics Ptr, ByRef Op As AIDrawOp, Y As Long)
		Dim As GpSolidFill Ptr Brush
		GdipCreateSolidFill(&HFF000000 Or Op.Clr, @Brush)
		If Op.Kind = 2 Then
			GdipFillRectangleI(G, Cast(GpBrush Ptr, Brush), Op.X, Y, Op.W, Op.H)
		Else
			Dim As Single R = Min(CSng(AICScale(12)), CSng(Min(Op.W, Op.H)))
			Dim As Single X = Op.X + 0.5, YY = Y + 0.5, W = Op.W - 1, H = Op.H - 1
			Dim As GpPath Ptr Path
			GdipCreatePath(FillModeAlternate, @Path)
			GdipAddPathArc(Path, X, YY, R, R, 180, 90)
			GdipAddPathArc(Path, X + W - R, YY, R, R, 270, 90)
			GdipAddPathArc(Path, X + W - R, YY + H - R, R, R, 0, 90)
			GdipAddPathArc(Path, X, YY + H - R, R, R, 90, 90)
			GdipClosePathFigure(Path)
			GdipFillPath(G, Cast(GpBrush Ptr, Brush), Path)
			If Op.Clr2 <> Op.Clr Then
				Dim As GpPen Ptr Pen
				GdipCreatePen1(&HFF000000 Or Op.Clr2, 1, UnitPixel, @Pen)
				GdipDrawPath(G, Pen, Path)
				GdipDeletePen(Pen)
			End If
			GdipDeletePath(Path)
		End If
		GdipDeleteBrush(Cast(GpBrush Ptr, Brush))
	End Sub

	'The rounded corners of a picture (6 points, like in the browser): the corners get the color under the picture
	Sub AICPicCorners(G As GpGraphics Ptr, ByRef Op As AIDrawOp, Y As Long)
		Dim As Single D = Min(CSng(AICScale(12)), CSng(Min(Op.W, Op.H)))
		If D < 2 Then Exit Sub
		Dim As Single X = Op.X, W = Op.W, H = Op.H, YY = Y
		Dim As GpPath Ptr Path
		GdipCreatePath(FillModeAlternate, @Path)
		GdipAddPathRectangle(Path, X - 1, YY - 1, W + 2, H + 2)
		GdipStartPathFigure(Path)
		GdipAddPathArc(Path, X, YY, D, D, 180, 90)
		GdipAddPathArc(Path, X + W - D, YY, D, D, 270, 90)
		GdipAddPathArc(Path, X + W - D, YY + H - D, D, D, 0, 90)
		GdipAddPathArc(Path, X, YY + H - D, D, D, 90, 90)
		GdipClosePathFigure(Path)
		Dim As GpSolidFill Ptr Brush
		GdipCreateSolidFill(&HFF000000 Or Op.Clr, @Brush)
		GdipFillPath(G, Cast(GpBrush Ptr, Brush), Path)
		GdipDeleteBrush(Cast(GpBrush Ptr, Brush))
		GdipDeletePath(Path)
	End Sub

	#endif

	' The selection

	Function AICPosLess(ByRef A As AICPos, ByRef B As AICPos) As Boolean
		If A.Msg <> B.Msg Then Return A.Msg < B.Msg
		If A.Op <> B.Op Then Return A.Op < B.Op
		Return A.Ch < B.Ch
	End Function

	Function AICHasSel() As Boolean
		Return AICSelA.Msg <> AICSelB.Msg OrElse AICSelA.Op <> AICSelB.Op OrElse AICSelA.Ch <> AICSelB.Ch
	End Function

	'The start and the end of the selection
	Sub AICSelOrder(ByRef S1 As AICPos, ByRef S2 As AICPos)
		If AICPosLess(AICSelB, AICSelA) Then
			S1 = AICSelB: S2 = AICSelA
		Else
			S1 = AICSelA: S2 = AICSelB
		End If
	End Sub

	Function AICSelectable(ByRef Op As AIDrawOp) As Boolean
		Return Op.Kind = 1 AndAlso Op.Clr2 <> 2
	End Function

	Function AICSelColor() As ULong
		Return IIf(AIChatIsDark(), &H264F78, &HADD6FF)
	End Function

	'The character of the text at X (the nearest border of the characters)
	Function AICCharAt(ByRef Op As AIDrawOp, X As Long) As Integer
		Dim As Integer L = Len(Op.Text), Lo, Hi = L, Md, F = Op.Font
		If X <= Op.X Then Return 0
		If X >= Op.X + Op.W Then Return L
		Dim As Long DX = X - Op.X
		Do While Lo < Hi
			Md = (Lo + Hi + 1) \ 2
			If AICTextW(Left(Op.Text, Md), F) <= DX Then Lo = Md Else Hi = Md - 1
		Loop
		If Lo < L Then
			If DX - AICTextW(Left(Op.Text, Lo), F) > AICTextW(Left(Op.Text, Lo + 1), F) - DX Then Lo += 1
		End If
		If Lo > 0 AndAlso Lo < L AndAlso Op.Text[Lo] >= &HDC00 AndAlso Op.Text[Lo] <= &HDFFF Then Lo += 1
		Return Lo
	End Function

	'The place of the text at the point of the window (the nearest text)
	Function AICPosAt(X As Long, Y As Long) As AICPos
		Dim As AICPos P
		If AICMsgCount = 0 Then Return P
		Dim As Long DocY = Y + AICScroll, RelY, DY, DX
		Dim As Integer i
		For i = 0 To AICMsgCount - 1
			If DocY < AICMsgs(i).Y + AICMsgs(i).H Then Exit For
		Next
		If i >= AICMsgCount Then i = AICMsgCount - 1
		P.Msg = i
		RelY = DocY - AICMsgs(i).Y
		Dim As LongInt Best = &H7FFFFFFFFFFF, Score
		Dim As Integer BestK = -1
		Dim As Boolean Below
		For k As Integer = 0 To AICMsgs(i).OpCount - 1
			If Not AICSelectable(AICMsgs(i).Ops(k)) Then Continue For
			With AICMsgs(i).Ops(k)
				If RelY < .Y Then
					DY = .Y - RelY
				ElseIf RelY >= .Y + .H Then
					DY = RelY - (.Y + .H) + 1
				Else
					DY = 0
				End If
				If X < .X Then
					DX = .X - X
				ElseIf X > .X + .W Then
					DX = X - (.X + .W)
				Else
					DX = 0
				End If
				Score = CLngInt(DY) * 100000 + DX
				If Score < Best Then Best = Score: BestK = k: Below = (DY > 0 AndAlso RelY >= .Y + .H)
			End With
		Next
		If BestK < 0 Then Return P
		P.Op = BestK
		Dim As Long DYBest = Best \ 100000
		If DYBest > 0 Then
			P.Ch = IIf(Below, Len(AICMsgs(i).Ops(BestK).Text), 0)
		Else
			P.Ch = AICCharAt(AICMsgs(i).Ops(BestK), X)
		End If
		Return P
	End Function

	'The selected characters of the text k of the message i (C1 to C2)
	Function AICSelRange(i As Integer, k As Integer, ByRef S1 As AICPos, ByRef S2 As AICPos, ByRef C1 As Integer, ByRef C2 As Integer) As Boolean
		If i < S1.Msg OrElse i > S2.Msg Then Return False
		If i = S1.Msg AndAlso k < S1.Op Then Return False
		If i = S2.Msg AndAlso k > S2.Op Then Return False
		If Not AICSelectable(AICMsgs(i).Ops(k)) Then Return False
		Dim As Integer L = Len(AICMsgs(i).Ops(k).Text)
		C1 = 0: C2 = L
		If i = S1.Msg AndAlso k = S1.Op Then C1 = Min(S1.Ch, L)
		If i = S2.Msg AndAlso k = S2.Op Then C2 = Min(S2.Ch, L)
		Return C2 > C1
	End Function

	'The selected part of the text k of the message i (from X1 to X2)
	Function AICSelPart(i As Integer, k As Integer, ByRef S1 As AICPos, ByRef S2 As AICPos, ByRef X1 As Long, ByRef X2 As Long) As Boolean
		Dim As Integer C1, C2
		If Not AICSelRange(i, k, S1, S2, C1, C2) Then Return False
		Dim As Integer F = AICMsgs(i).Ops(k).Font
		X1 = AICMsgs(i).Ops(k).X + AICTextW(Left(AICMsgs(i).Ops(k).Text, C1), F)
		X2 = AICMsgs(i).Ops(k).X + AICTextW(Left(AICMsgs(i).Ops(k).Text, C2), F)
		Return X2 > X1
	End Function

	'The selected text (the lines of the view: a wrapped line goes on, the others are new lines)
	Function AICSelText() As UString
		If Not AICHasSel() Then Return ""
		Dim As AICPos S1, S2
		AICSelOrder S1, S2
		Dim As UString R
		Dim As Integer C1, C2, PrevMsg = -1
		Dim As Long PrevY, PrevH, PrevEnd, CY
		For i As Integer = Max(S1.Msg, 0) To Min(S2.Msg, AICMsgCount - 1)
			For k As Integer = 0 To AICMsgs(i).OpCount - 1
				If Not AICSelRange(i, k, S1, S2, C1, C2) Then Continue For
				With AICMsgs(i).Ops(k)
					If PrevMsg >= 0 Then
						CY = .Y + .H \ 2
						If i <> PrevMsg Then
							R &= !"\r\n\r\n"
						ElseIf CY < PrevY OrElse CY >= PrevY + PrevH Then
							If Right(R, 1) <> " " Then R &= !"\r\n"
						ElseIf .X > PrevEnd + 1 AndAlso Right(R, 1) <> " " Then
							R &= " "
						End If
					End If
					R &= Mid(.Text, C1 + 1, C2 - C1)
					PrevMsg = i: PrevY = .Y: PrevH = .H: PrevEnd = .X + .W
				End With
			Next
		Next
		Return R
	End Function

	Sub AICSelectAll()
		If AICMsgCount = 0 Then Exit Sub
		AICSelA = Type<AICPos>(0, 0, 0)
		Dim As Integer n = AICMsgCount - 1, k = Max(AICMsgs(n).OpCount - 1, 0)
		AICSelB.Msg = n: AICSelB.Op = k
		AICSelB.Ch = IIf(AICMsgs(n).OpCount > 0, Len(AICMsgs(n).Ops(k).Text), 0)
		AICInvalidate
	End Sub

	'The word at the place
	Sub AICSelectWord(ByRef P As AICPos)
		If P.Msg < 0 OrElse P.Msg >= AICMsgCount OrElse P.Op >= AICMsgs(P.Msg).OpCount Then Exit Sub
		If Not AICSelectable(AICMsgs(P.Msg).Ops(P.Op)) Then Exit Sub
		Dim As UString T = AICMsgs(P.Msg).Ops(P.Op).Text
		Dim As Integer A = Min(P.Ch, Len(T)), B = A
		Do While A > 0 AndAlso T[A - 1] <> 32
			A -= 1
		Loop
		Do While B < Len(T) AndAlso T[B] <> 32
			B += 1
		Loop
		AICSelA = P: AICSelA.Ch = A
		AICSelB = P: AICSelB.Ch = B
		AICInvalidate
	End Sub

	'Is a text at the point (the cursor of the text)
	Function AICOverText(X As Long, Y As Long) As Boolean
		Dim As Long DocY = Y + AICScroll, OY
		For i As Integer = 0 To AICMsgCount - 1
			If DocY < AICMsgs(i).Y OrElse DocY >= AICMsgs(i).Y + AICMsgs(i).H Then Continue For
			For k As Integer = 0 To AICMsgs(i).OpCount - 1
				If Not AICSelectable(AICMsgs(i).Ops(k)) Then Continue For
				OY = AICMsgs(i).Y + AICMsgs(i).Ops(k).Y
				If X >= AICMsgs(i).Ops(k).X AndAlso X < AICMsgs(i).Ops(k).X + AICMsgs(i).Ops(k).W AndAlso DocY >= OY AndAlso DocY < OY + AICMsgs(i).Ops(k).H Then Return True
			Next
			Exit For
		Next
		Return False
	End Function

	#ifdef __USE_WINAPI__
	' Direct2D

	Sub AICReleaseRT()
		For i As Integer = 0 To AICImgCount - 1
			If AICImgD2D(i) Then Cast(ID2D1Bitmap Ptr, AICImgD2D(i))->lpVtbl->Release(AICImgD2D(i)): AICImgD2D(i) = 0
		Next
		If AICBrush Then AICBrush->lpVtbl->Release(AICBrush): AICBrush = 0
		If AICRT Then AICRT->lpVtbl->Release(AICRT): AICRT = 0
	End Sub

	Function AICD2DColor(C As ULong) As D2D1_COLOR_F
		Return Type<D2D1_COLOR_F>(((C Shr 16) And &HFF) / 255, ((C Shr 8) And &HFF) / 255, (C And &HFF) / 255, 1)
	End Function

	Sub AICPaintD2D(hWnd As HWND)
		Dim As PAINTSTRUCT PS
		BeginPaint(hWnd, @PS)
		Dim As ..RECT R
		GetClientRect(hWnd, @R)
		If AICRT = 0 AndAlso pD2D1Factory <> 0 Then
			Dim As D2D1_RENDER_TARGET_PROPERTIES RP
			RP.dpiX = 96: RP.dpiY = 96
			Dim As D2D1_HWND_RENDER_TARGET_PROPERTIES HP
			HP.hwnd = hWnd
			HP.pixelSize.Width = Max(1, R.right)
			HP.pixelSize.height = Max(1, R.bottom)
			pD2D1Factory->lpVtbl->CreateHwndRenderTarget(pD2D1Factory, @RP, @HP, @AICRT)
			If AICRT Then
				Dim As D2D1_COLOR_F C = AICD2DColor(AICColors.Fore)
				Cast(ID2D1RenderTarget Ptr, AICRT)->lpVtbl->CreateSolidColorBrush(Cast(ID2D1RenderTarget Ptr, AICRT), @C, 0, @AICBrush)
			End If
		End If
		If AICRT = 0 OrElse AICBrush = 0 Then EndPaint(hWnd, @PS): Exit Sub
		Dim As ID2D1RenderTarget Ptr RT = Cast(ID2D1RenderTarget Ptr, AICRT)
		Dim As ID2D1Brush Ptr B = Cast(ID2D1Brush Ptr, AICBrush)
		Dim As D2D1_COLOR_F C = AICD2DColor(AICColors.Back)
		Dim As D2D1_RECT_F RF
		Dim As D2D1_ROUNDED_RECT RR
		Dim As Long MsgY, OY, X1, X2
		Dim As Single Rad
		RT->lpVtbl->BeginDraw(RT)
		RT->lpVtbl->Clear(RT, @C)
		'The shapes
		For i As Integer = 0 To AICMsgCount - 1
			MsgY = AICMsgs(i).Y - AICScroll
			If MsgY > R.bottom OrElse MsgY + AICMsgs(i).H < 0 Then Continue For
			For k As Integer = 0 To AICMsgs(i).OpCount - 1
				With AICMsgs(i).Ops(k)
					If .Kind <> 2 AndAlso .Kind <> 3 Then Continue For
					OY = MsgY + .Y
					If OY > R.bottom OrElse OY + .H < 0 Then Continue For
					C = AICD2DColor(.Clr)
					AICBrush->lpVtbl->SetColor(AICBrush, @C)
					If .Kind = 2 Then
						RF = Type<D2D1_RECT_F>(.X, OY, .X + .W, OY + .H)
						RT->lpVtbl->FillRectangle(RT, @RF, B)
					Else
						Rad = Min(CSng(AICScale(12)), CSng(Min(.W, .H))) / 2
						RR.rect = Type<D2D1_RECT_F>(.X + 0.5, OY + 0.5, .X + .W - 0.5, OY + .H - 0.5)
						RR.radiusX = Rad: RR.radiusY = Rad
						RT->lpVtbl->FillRoundedRectangle(RT, @RR, B)
						If .Clr2 <> .Clr Then
							C = AICD2DColor(.Clr2)
							AICBrush->lpVtbl->SetColor(AICBrush, @C)
							RT->lpVtbl->DrawRoundedRectangle(RT, @RR, B, 1, 0)
						End If
					End If
				End With
			Next
		Next
		'The pictures
		Dim As ID2D1Bitmap Ptr PicBmp
		Dim As Integer PI_
		For i As Integer = 0 To AICMsgCount - 1
			MsgY = AICMsgs(i).Y - AICScroll
			If MsgY > R.bottom OrElse MsgY + AICMsgs(i).H < 0 Then Continue For
			For k As Integer = 0 To AICMsgs(i).OpCount - 1
				With AICMsgs(i).Ops(k)
					If .Kind <> 4 Then Continue For
					OY = MsgY + .Y
					If OY > R.bottom OrElse OY + .H < 0 Then Continue For
					PI_ = .Font
					PicBmp = AICImageD2D(PI_)
					If PicBmp = 0 Then Continue For
					'Rounded corners (6 points), like in the browser
					Dim As ID2D1BitmapBrush Ptr BB
					Dim As D2D1_BITMAP_BRUSH_PROPERTIES BBP = Type(0, 0, 1)
					RT->lpVtbl->CreateBitmapBrush(RT, PicBmp, @BBP, 0, @BB)
					If BB Then
						Dim As D2D1_MATRIX_3X2_F Mx
						Mx.m11 = .W / AICImgW(PI_): Mx.m22 = .H / AICImgH(PI_): Mx.dx = .X: Mx.dy = OY
						BB->lpVtbl->SetTransform(BB, @Mx)
						Dim As D2D1_ROUNDED_RECT PR
						PR.rect = Type<D2D1_RECT_F>(.X, OY, .X + .W, OY + .H)
						PR.radiusX = Min(CSng(AICScale(6)), CSng(Min(.W, .H)) / 2): PR.radiusY = PR.radiusX
						RT->lpVtbl->FillRoundedRectangle(RT, @PR, Cast(Any Ptr, BB))
						BB->lpVtbl->Release(BB)
					Else
						RF = Type<D2D1_RECT_F>(.X, OY, .X + .W, OY + .H)
						RT->lpVtbl->DrawBitmap(RT, PicBmp, @RF, 1, 1, 0)
					End If
				End With
			Next
		Next
		'The selection
		If AICHasSel() Then
			Dim As AICPos S1, S2
			AICSelOrder S1, S2
			C = AICD2DColor(AICSelColor())
			AICBrush->lpVtbl->SetColor(AICBrush, @C)
			For i As Integer = Max(S1.Msg, 0) To Min(S2.Msg, AICMsgCount - 1)
				MsgY = AICMsgs(i).Y - AICScroll
				If MsgY > R.bottom OrElse MsgY + AICMsgs(i).H < 0 Then Continue For
				For k As Integer = 0 To AICMsgs(i).OpCount - 1
					If AICSelPart(i, k, S1, S2, X1, X2) Then
						OY = MsgY + AICMsgs(i).Ops(k).SY
						RF =Type<D2D1_RECT_F>(X1, OY, X2, OY + AICMsgs(i).Ops(k).SH)
						RT->lpVtbl->FillRectangle(RT, @RF, B)
					End If
				Next
			Next
		End If
		'The texts (the emojis in their colors)
		Dim As IDWriteTextLayout Ptr L
		Dim As Integer FI
		For i As Integer = 0 To AICMsgCount - 1
			MsgY = AICMsgs(i).Y - AICScroll
			If MsgY > R.bottom OrElse MsgY + AICMsgs(i).H < 0 Then Continue For
			For k As Integer = 0 To AICMsgs(i).OpCount - 1
				With AICMsgs(i).Ops(k)
					If .Kind <> 1 OrElse Len(.Text) = 0 Then Continue For
					OY = MsgY + .Y
					If OY > R.bottom OrElse OY + .H < 0 Then Continue For
					FI = .Font
					If AICFormats(FI) = 0 Then Continue For
					L = 0
					pDWriteFactory->lpVtbl->CreateTextLayout(pDWriteFactory, .Text.vptr, Len(.Text), AICFormats(FI), 100000, 100000, @L)
					If L = 0 Then Continue For
					C = AICD2DColor(.Clr)
					AICBrush->lpVtbl->SetColor(AICBrush, @C)
					RT->lpVtbl->DrawTextLayout(RT, Type<D2D1_POINT_2F>(.X, OY + AICD2DDY(FI)), L, B, D2D1_DRAW_TEXT_OPTIONS_ENABLE_COLOR_FONT)
					L->lpVtbl->Release(L)
				End With
			Next
		Next
		If RT->lpVtbl->EndDraw(RT, 0, 0) = &H8899000C Then AICReleaseRT 'D2DERR_RECREATE_TARGET
		EndPaint(hWnd, @PS)
	End Sub

	Sub AICPaint(hWnd As HWND)
		Dim As PAINTSTRUCT PS
		Dim As HDC DC = BeginPaint(hWnd, @PS)
		Dim As ..RECT R
		GetClientRect(hWnd, @R)
		Dim As HDC MemDC = CreateCompatibleDC(DC)
		Dim As HBITMAP Bmp = CreateCompatibleBitmap(DC, Max(1, R.right), Max(1, R.bottom))
		Dim As HGDIOBJ OldBmp = SelectObject(MemDC, Bmp), OldFont = SelectObject(MemDC, AICFonts(0))
		Dim As Long MsgY, OY
		SetDCBrushColor(MemDC, AICColorRef(AICColors.Back))
		FillRect(MemDC, @R, GetStockObject(DC_BRUSH))
		'The shapes by GDI+ (smooth), the texts by GDI (ClearType)
		Dim As GpGraphics Ptr G
		If GdipCreateFromHDC(MemDC, @G) = 0 Then
			GdipSetSmoothingMode(G, SmoothingModeAntiAlias)
			For i As Integer = 0 To AICMsgCount - 1
				MsgY = AICMsgs(i).Y - AICScroll
				If MsgY > R.bottom OrElse MsgY + AICMsgs(i).H < 0 Then Continue For
				For k As Integer = 0 To AICMsgs(i).OpCount - 1
					If AICMsgs(i).Ops(k).Kind <> 2 AndAlso AICMsgs(i).Ops(k).Kind <> 3 Then Continue For
					OY = MsgY + AICMsgs(i).Ops(k).Y
					If OY > R.bottom OrElse OY + AICMsgs(i).Ops(k).H < 0 Then Continue For
					AICFillShape(G, AICMsgs(i).Ops(k), OY)
				Next
			Next
			'The pictures
			GdipSetInterpolationMode(G, 7) 'InterpolationModeHighQualityBicubic
			Dim As Integer PI_
			For i As Integer = 0 To AICMsgCount - 1
				MsgY = AICMsgs(i).Y - AICScroll
				If MsgY > R.bottom OrElse MsgY + AICMsgs(i).H < 0 Then Continue For
				For k As Integer = 0 To AICMsgs(i).OpCount - 1
					If AICMsgs(i).Ops(k).Kind <> 4 Then Continue For
					OY = MsgY + AICMsgs(i).Ops(k).Y
					If OY > R.bottom OrElse OY + AICMsgs(i).Ops(k).H < 0 Then Continue For
					PI_ = AICMsgs(i).Ops(k).Font
					GdipDrawImageRectI(G, AICImgGp(PI_), AICMsgs(i).Ops(k).X, OY, AICMsgs(i).Ops(k).W, AICMsgs(i).Ops(k).H)
					AICPicCorners(G, AICMsgs(i).Ops(k), OY)
				Next
			Next
			GdipDeleteGraphics(G)
		End If
		If AICHasSel() Then
			Dim As AICPos S1, S2
			Dim As Long X1, X2
			Dim As ..RECT SR
			AICSelOrder S1, S2
			SetDCBrushColor(MemDC, AICColorRef(AICSelColor()))
			For i As Integer = Max(S1.Msg, 0) To Min(S2.Msg, AICMsgCount - 1)
				MsgY = AICMsgs(i).Y - AICScroll
				If MsgY > R.bottom OrElse MsgY + AICMsgs(i).H < 0 Then Continue For
				For k As Integer = 0 To AICMsgs(i).OpCount - 1
					If AICSelPart(i, k, S1, S2, X1, X2) Then
						OY = MsgY + AICMsgs(i).Ops(k).SY
						SR.left = X1: SR.top = OY: SR.right = X2: SR.bottom = OY + AICMsgs(i).Ops(k).SH
						FillRect(MemDC, @SR, GetStockObject(DC_BRUSH))
					End If
				Next
			Next
		End If
		SetBkMode(MemDC, TRANSPARENT)
		For i As Integer = 0 To AICMsgCount - 1
			MsgY = AICMsgs(i).Y - AICScroll
			If MsgY > R.bottom OrElse MsgY + AICMsgs(i).H < 0 Then Continue For
			For k As Integer = 0 To AICMsgs(i).OpCount - 1
				If AICMsgs(i).Ops(k).Kind <> 1 Then Continue For
				OY = MsgY + AICMsgs(i).Ops(k).Y
				If OY > R.bottom OrElse OY + AICMsgs(i).Ops(k).H < 0 Then Continue For
				'The index is read into a variable first (gas64 gave a wrong element for AICFonts(AICMsgs(i).Ops(k).Font))
				Dim As Integer FI = AICMsgs(i).Ops(k).Font
				SelectObject(MemDC, AICFonts(FI))
				SetTextColor(MemDC, AICColorRef(AICMsgs(i).Ops(k).Clr))
				TextOutW(MemDC, AICMsgs(i).Ops(k).X, OY, AICMsgs(i).Ops(k).Text.vptr, Len(AICMsgs(i).Ops(k).Text))
			Next
		Next
		BitBlt(DC, 0, 0, R.right, R.bottom, MemDC, 0, 0, SRCCOPY)
		SelectObject(MemDC, OldFont)
		SelectObject(MemDC, OldBmp)
		DeleteObject(Bmp)
		DeleteDC(MemDC)
		EndPaint(hWnd, @PS)
	End Sub
	#else
	' cairo (the shapes, the pictures) and pango (the texts)

	Sub AICSetColor(cr As cairo_t Ptr, C As ULong)
		cairo_set_source_rgb(cr, ((C Shr 16) And &HFF) / 255, ((C Shr 8) And &HFF) / 255, (C And &HFF) / 255)
	End Sub

	Sub AICRoundPath(cr As cairo_t Ptr, X As Double, Y As Double, W As Double, H As Double, R As Double)
		cairo_new_sub_path(cr)
		cairo_arc(cr, X + W - R, Y + R, R, -G_PI / 2, 0)
		cairo_arc(cr, X + W - R, Y + H - R, R, 0, G_PI / 2)
		cairo_arc(cr, X + R, Y + H - R, R, G_PI / 2, G_PI)
		cairo_arc(cr, X + R, Y + R, R, G_PI, 3 * G_PI / 2)
		cairo_close_path(cr)
	End Sub

	Sub pnlAICCanvas_Paint(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Dim As cairo_t Ptr cr = Cast(cairo_t Ptr, Canvas.Handle)
		If cr = 0 Then Exit Sub
		If AICLayouts(0) = 0 Then AICCreateFonts
		Dim As Long CH = Max(AICClientH, 1), MsgY, OY
		Dim As Double R
		cairo_save(cr)
		AICSetColor(cr, AICColors.Back)
		cairo_rectangle(cr, 0, 0, Max(AICClientW, 1) + 1, CH + 1)
		cairo_fill(cr)
		'The shapes and the pictures (like the GDI+ of Windows)
		cairo_set_line_width(cr, 1)
		For i As Integer = 0 To AICMsgCount - 1
			MsgY = AICMsgs(i).Y - AICScroll
			If MsgY > CH OrElse MsgY + AICMsgs(i).H < 0 Then Continue For
			For k As Integer = 0 To AICMsgs(i).OpCount - 1
				With AICMsgs(i).Ops(k)
					If .Kind <> 2 AndAlso .Kind <> 3 AndAlso .Kind <> 4 Then Continue For
					OY = MsgY + .Y
					If OY > CH OrElse OY + .H < 0 Then Continue For
					Select Case .Kind
					Case 2
						AICSetColor(cr, .Clr)
						cairo_rectangle(cr, .X, OY, .W, .H)
						cairo_fill(cr)
					Case 3
						R = Min(CDbl(AICScale(12)), CDbl(Min(.W, .H))) / 2
						AICRoundPath(cr, .X + 0.5, OY + 0.5, .W - 1, .H - 1, R)
						AICSetColor(cr, .Clr)
						If .Clr2 <> .Clr Then
							cairo_fill_preserve(cr)
							AICSetColor(cr, .Clr2)
							cairo_stroke(cr)
						Else
							cairo_fill(cr)
						End If
					Case 4
						Dim As Integer PI_ = .Font
						If PI_ >= 0 AndAlso PI_ < AICImgCount AndAlso AICImgPix(PI_) <> 0 Then
							cairo_save(cr)
							R = Min(CDbl(AICScale(12)), CDbl(Min(.W, .H))) / 2
							AICRoundPath(cr, .X, OY, .W, .H, R)
							cairo_clip(cr)
							cairo_translate(cr, .X, OY)
							cairo_scale(cr, .W / AICImgW(PI_), .H / AICImgH(PI_))
							gdk_cairo_set_source_pixbuf(cr, AICImgPix(PI_), 0, 0)
							cairo_pattern_set_filter(cairo_get_source(cr), CAIRO_FILTER_GOOD)
							cairo_paint(cr)
							cairo_restore(cr)
						End If
					End Select
				End With
			Next
		Next
		'The selection (in the whole height of the line)
		If AICHasSel() Then
			Dim As AICPos S1, S2
			Dim As Long X1, X2
			AICSelOrder S1, S2
			AICSetColor(cr, AICSelColor())
			For i As Integer = Max(S1.Msg, 0) To Min(S2.Msg, AICMsgCount - 1)
				MsgY = AICMsgs(i).Y - AICScroll
				If MsgY > CH OrElse MsgY + AICMsgs(i).H < 0 Then Continue For
				For k As Integer = 0 To AICMsgs(i).OpCount - 1
					If AICSelPart(i, k, S1, S2, X1, X2) Then
						OY = MsgY + AICMsgs(i).Ops(k).SY
						cairo_rectangle(cr, X1, OY, X2 - X1, AICMsgs(i).Ops(k).SH)
					End If
				Next
			Next
			cairo_fill(cr)
		End If
		'The texts
		Dim As String U
		For i As Integer = 0 To AICMsgCount - 1
			MsgY = AICMsgs(i).Y - AICScroll
			If MsgY > CH OrElse MsgY + AICMsgs(i).H < 0 Then Continue For
			For k As Integer = 0 To AICMsgs(i).OpCount - 1
				If AICMsgs(i).Ops(k).Kind <> 1 Then Continue For
				OY = MsgY + AICMsgs(i).Ops(k).Y
				If OY > CH OrElse OY + AICMsgs(i).Ops(k).H < 0 Then Continue For
				Dim As Integer FI = AICMsgs(i).Ops(k).Font
				If AICLayouts(FI) = 0 Then Continue For
				U = ToUtf8(AICMsgs(i).Ops(k).Text)
				pango_layout_set_text(AICLayouts(FI), StrPtr(U), Len(U))
				AICSetColor(cr, AICMsgs(i).Ops(k).Clr)
				cairo_move_to(cr, AICMsgs(i).Ops(k).X, OY)
				pango_cairo_show_layout(cr, AICLayouts(FI))
			Next
		Next
		cairo_restore(cr)
	End Sub
	#endif

	'The action of the operation of the kind at the point of the window ("" if none); MsgIndex: the message there
	Function AICHitTest(X As Long, Y As Long, Kind As Integer, ByRef MsgIndex As Integer) As UString
		Dim As Long DocY = Y + AICScroll, OY
		MsgIndex = -1
		For i As Integer = 0 To AICMsgCount - 1
			If DocY < AICMsgs(i).Y OrElse DocY >= AICMsgs(i).Y + AICMsgs(i).H Then Continue For
			MsgIndex = i
			For k As Integer = AICMsgs(i).OpCount - 1 To 0 Step -1
				If AICMsgs(i).Ops(k).Kind <> Kind OrElse AICMsgs(i).Ops(k).Action = "" Then Continue For
				OY = AICMsgs(i).Y + AICMsgs(i).Ops(k).Y
				If X >= AICMsgs(i).Ops(k).X AndAlso X < AICMsgs(i).Ops(k).X + AICMsgs(i).Ops(k).W AndAlso DocY >= OY AndAlso DocY < OY + AICMsgs(i).Ops(k).H Then Return AICMsgs(i).Ops(k).Action
			Next
			Exit For
		Next
		Return ""
	End Function

	Sub AICAction(ByRef Action As WString, MsgIndex As Integer)
		If StartsWith(Action, "fold:") Then
			Dim As UString Item = "|" & Str(MsgIndex) & ":" & Mid(Action, 6) & "|"
			If InStr(AICOpenFolds, Item) Then AICOpenFolds = Replace(AICOpenFolds, Item, "") Else AICOpenFolds &= Item
			AICSelB = AICSelA
			AICLayoutMessage(MsgIndex)
			AICPositions
			AICUpdateScroll(False)
			AICInvalidate
		Else
			AIChatViewMessage Action
		End If
	End Sub

	#ifdef __USE_WINAPI__
	Function AICWndProc(ByVal hWnd As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
		Dim As Integer MsgIndex
		Select Case uMsg
		Case WM_ERASEBKGND
			Return 1
		Case WM_PAINT
			If AICUseD2D Then AICPaintD2D(hWnd) Else AICPaint(hWnd)
			Return 0
		Case WM_SIZE
			Dim As ..RECT R
			GetClientRect(hWnd, @R)
			If AICRT Then
				Dim As D2D1_SIZE_U SzU
				SzU.Width = Max(1, R.right): SzU.height = Max(1, R.bottom)
				AICRT->lpVtbl->Resize(AICRT, @SzU)
			End If
			Dim As Boolean WasBottom = AICAtBottom()
			AICClientH = R.bottom
			If R.right <> AICClientW Then
				AICClientW = R.right
				AICRelayoutAll
			End If
			AICUpdateScroll(WasBottom)
			InvalidateRect(hWnd, 0, False)
			Return 0
		Case WM_VSCROLL
			Dim As SCROLLINFO SI
			SI.cbSize = SizeOf(SI)
			SI.fMask = SIF_ALL
			GetScrollInfo(hWnd, SB_VERT, @SI)
			Dim As Long P = AICScroll, LH = AICLineH(0) * 3
			Select Case LoWord(wParam)
			Case SB_LINEUP: P -= LH
			Case SB_LINEDOWN: P += LH
			Case SB_PAGEUP: P -= AICClientH
			Case SB_PAGEDOWN: P += AICClientH
			Case SB_THUMBTRACK, SB_THUMBPOSITION: P = SI.nTrackPos
			Case SB_TOP: P = 0
			Case SB_BOTTOM: P = AICTotalH
			End Select
			AICScrollTo(P)
			Return 0
		Case WM_MOUSEWHEEL
			Dim As Short Delta = HiWord(wParam)
			AICScrollTo(AICScroll - CLng(Delta) * AICLineH(0) * 3 \ 120)
			Return 0
		Case WM_KEYDOWN
			If GetKeyState(VK_CONTROL) < 0 Then
				Select Case wParam
				Case Asc("C"), VK_INSERT
					If AICHasSel() Then Clipboard.SetAsText AICSelText()
					Return 0
				Case Asc("A")
					AICSelectAll
					Return 0
				End Select
			End If
			Select Case wParam
			Case VK_UP: AICScrollTo(AICScroll - AICLineH(0))
			Case VK_DOWN: AICScrollTo(AICScroll + AICLineH(0))
			Case VK_PRIOR: AICScrollTo(AICScroll - AICClientH)
			Case VK_NEXT: AICScrollTo(AICScroll + AICClientH)
			Case VK_HOME: AICScrollTo(0)
			Case VK_END: AICScrollTo(AICTotalH)
			End Select
			Return 0
		Case WM_GETDLGCODE
			Return DLGC_WANTARROWS
		Case WM_LBUTTONDOWN
			SetFocus(hWnd)
			SetCapture(hWnd)
			Dim As AICPos P = AICPosAt(CShort(LoWord(lParam)), CShort(HiWord(lParam)))
			If (wParam And MK_SHIFT) <> 0 AndAlso AICMsgCount > 0 Then
				AICSelB = P
				AICDragged = True
			Else
				AICSelA = P: AICSelB = P
				AICDragged = False
			End If
			AICSelecting = True
			AICDownX = CShort(LoWord(lParam)): AICDownY = CShort(HiWord(lParam))
			InvalidateRect(hWnd, 0, False)
			Return 0
		Case WM_MOUSEMOVE
			If AICSelecting Then
				Dim As Long X = CShort(LoWord(lParam)), Y = CShort(HiWord(lParam))
				If Abs(X - AICDownX) > 3 OrElse Abs(Y - AICDownY) > 3 Then AICDragged = True
				If AICDragged Then
					'Out of the window: it scrolls
					If Y < 0 Then
						AICScrollTo(AICScroll + Y)
					ElseIf Y > AICClientH Then
						AICScrollTo(AICScroll + Y - AICClientH)
					End If
					AICSelB = AICPosAt(X, Max(0, Min(Y, AICClientH - 1)))
					InvalidateRect(hWnd, 0, False)
				End If
			End If
			Return 0
		Case WM_LBUTTONUP
			'ReleaseCapture sends WM_CAPTURECHANGED (it clears AICSelecting): the state is taken first
			Dim As Boolean WasSelecting = AICSelecting
			AICSelecting = False
			If GetCapture() = hWnd Then ReleaseCapture
			If WasSelecting Then
				If Not AICDragged Then
					'A click: no selection, the action of the place
					AICSelB = AICSelA
					InvalidateRect(hWnd, 0, False)
					Dim As UString Action = AICHitTest(CShort(LoWord(lParam)), CShort(HiWord(lParam)), 6, MsgIndex)
					If Action <> "" Then AICAction(Action, MsgIndex)
				End If
			End If
			Return 0
		Case WM_LBUTTONDBLCLK
			If AICHitTest(CShort(LoWord(lParam)), CShort(HiWord(lParam)), 6, MsgIndex) = "" Then
				Dim As AICPos P = AICPosAt(CShort(LoWord(lParam)), CShort(HiWord(lParam)))
				AICSelectWord(P)
			End If
			Return 0
		Case WM_CAPTURECHANGED
			AICSelecting = False
		Case WM_SETCURSOR
			If LoWord(lParam) = HTCLIENT Then
				Dim As ..POINT Pt
				GetCursorPos(@Pt)
				ScreenToClient(hWnd, @Pt)
				If AICHitTest(Pt.x, Pt.y, 6, MsgIndex) <> "" Then
					SetCursor(LoadCursor(0, IDC_HAND))
				ElseIf AICOverText(Pt.x, Pt.y) Then
					SetCursor(LoadCursor(0, IDC_IBEAM))
				Else
					SetCursor(LoadCursor(0, IDC_ARROW))
				End If
				Return 1
			End If
		Case WM_CONTEXTMENU
			'The selection of the menu: the code block or the message under the mouse
			Dim As ..POINT Pt
			GetCursorPos(@Pt)
			ScreenToClient(hWnd, @Pt)
			Dim As UString Action = AICHitTest(Pt.x, Pt.y, 3, MsgIndex)
			If AICHasSel() Then
				AIChatViewSelection = AICSelText()
			ElseIf StartsWith(Action, "code:") Then
				AIChatViewSelection = Mid(Action, 6)
			ElseIf MsgIndex >= 0 Then
				AIChatViewSelection = AICMsgs(MsgIndex).Body
			Else
				AIChatViewSelection = ""
			End If
			AIChatShowMenu
			Return 0
		End Select
		Return DefWindowProcW(hWnd, uMsg, wParam, lParam)
	End Function

	Sub AICCreate()
		If AICWnd <> 0 OrElse pnlAIView.Handle = 0 Then Exit Sub
		Static As Boolean Registered
		Dim As WString * 32 ClassName = "VFBAIChatView"
		If Not Registered Then
			Dim As WNDCLASSEXW WC
			WC.cbSize = SizeOf(WC)
			WC.style = CS_DBLCLKS
			WC.lpfnWndProc = @AICWndProc
			WC.hInstance = GetModuleHandle(0)
			WC.hCursor = LoadCursor(0, IDC_ARROW)
			WC.lpszClassName = @ClassName
			RegisterClassExW(@WC)
			Registered = True
		End If
		If AICGdipToken = 0 Then
			Dim As GdiplusStartupInput StartupInput
			StartupInput.GdiplusVersion = 1
			GdiplusStartup(@AICGdipToken, @StartupInput, NULL)
		End If
		'The texts are measured in a DC like the DC of the window (GDI scaling of the program scales the texts of both)
		Dim As HDC DC = GetDC(pnlAIView.Handle)
		AICDpi = GetDeviceCaps(DC, LOGPIXELSY)
		If AICDC = 0 Then AICDC = CreateCompatibleDC(DC)
		ReleaseDC(pnlAIView.Handle, DC)
		AICColors = AIChatPalette()
		AICCreateFonts
		Dim As ..RECT R
		GetClientRect(pnlAIView.Handle, @R)
		AICWnd = CreateWindowExW(0, @ClassName, "", WS_CHILD Or WS_VSCROLL Or WS_CLIPSIBLINGS Or WS_TABSTOP Or IIf(AIChatViewMode = acvCustom OrElse AIChatViewMode = acvD2D, WS_VISIBLE, 0), 0, 0, R.right, R.bottom, pnlAIView.Handle, 0, GetModuleHandle(0), 0)
		'The dark scroll bar
		If AICWnd <> 0 AndAlso AIChatIsDark() Then
			AllowDarkModeForWindow(AICWnd, True)
			SetWindowTheme(AICWnd, "DarkMode_Explorer", nullptr)
		End If
		AIChatNeedFull = True
	End Sub

	' ==========================================
	' The timer of the views
	' ==========================================

	Sub AIChatRenderHtml()
		Dim As UString Js = AIChatRenderScript()
		If AIChatViewMode = acvWebView2 Then AIWV2Exec Js Else AIIEExec Js
	End Sub

	Sub AIIETick()
		If AIIE = 0 Then Exit Sub
		If Not AIIENavigated Then
			If AIIE->Handle = 0 OrElse Not AIIE->IsCreated() Then Exit Sub
			Dim As WString * MAX_PATH FileName = GetUserTempPath("AIChatView.html")
			If FileName = "" Then Exit Sub
			AIIEHostFlags(AIIE->Handle)
			SaveToFile(FileName, AIChatHtmlShell(), FileEncodings.Utf8BOM)
			AIIE->Navigate(@FileName)
			AIIENavigated = True
			Exit Sub
		End If
		If Not AIIEReady Then
			If Not AIIEPageReady() Then Exit Sub
			AIIEReady = True
			AIChatNeedFull = True
		End If
		AIIEPoll
		If AIChatViewDirty OrElse AIChatNeedFull Then AIChatRenderHtml
	End Sub

	Sub AIChatTimerProc(ByVal hWnd As HWND, ByVal uMsg As UINT, ByVal idEvent As UINT_PTR, ByVal dwTime As DWORD)
		Static As Boolean Busy
		If Busy OrElse AIChatViewMode = acvRTF Then Exit Sub
		Busy = True
		If AIChatStatusTick() Then AIChatViewDirty = True
		Select Case AIChatViewMode
		Case acvWebView2
			If Not AIWV2Started Then AIWV2Start
			If AIWV2Ready AndAlso (AIChatViewDirty OrElse AIChatNeedFull) Then AIChatRenderHtml
		Case acvIE
			AIIETick
		Case acvCustom, acvD2D
			If AICWnd = 0 Then AICCreate
			If AICWnd <> 0 AndAlso (AIChatViewDirty OrElse AIChatNeedFull) Then AICUpdate
		End Select
		Busy = False
	End Sub

	'The own control fills the panel of the views
	Sub AICFit()
		If AICWnd <> 0 AndAlso pnlAIView.Handle <> 0 Then
			Dim As ..RECT R
			GetClientRect(pnlAIView.Handle, @R)
			MoveWindow(AICWnd, 0, 0, R.right, R.bottom, True)
		End If
	End Sub
	
	Sub pnlAIView_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		AICFit
	End Sub
	#else
	' The events of the panel of the drawing (GTK)

	Dim Shared As Long AICLastX, AICLastY

	Sub AICSetCursor(ByRef CursorName As String)
		If AICWnd = 0 OrElse AICCursorName = CursorName Then Exit Sub
		AICCursorName = CursorName
		#ifdef __USE_GTK4__
			gtk_widget_set_cursor_from_name(AICWnd, CursorName)
		#else
			Dim As GdkWindow Ptr Win
			If GTK_IS_LAYOUT(AICWnd) Then Win = gtk_layout_get_bin_window(GTK_LAYOUT(AICWnd))
			If Win = 0 Then Win = gtk_widget_get_window(AICWnd)
			If Win = 0 Then AICCursorName = "": Exit Sub
			Dim As GdkCursor Ptr Cur = gdk_cursor_new_from_name(gtk_widget_get_display(AICWnd), CursorName)
			gdk_window_set_cursor(Win, Cur)
			If Cur Then g_object_unref(Cur)
		#endif
	End Sub

	'The size of the panel of the drawing (the texts are laid out again for a new width)
	Sub AICUpdateSize()
		If AICWnd = 0 Then Exit Sub
		Dim As Long W, H
		#ifdef __USE_GTK4__
			W = gtk_widget_get_width(AICWnd): H = gtk_widget_get_height(AICWnd)
		#elseif defined(__USE_GTK2__)
			W = AICWnd->allocation.width: H = AICWnd->allocation.height
		#else
			W = gtk_widget_get_allocated_width(AICWnd): H = gtk_widget_get_allocated_height(AICWnd)
		#endif
		If W <= 1 OrElse H <= 1 Then Exit Sub
		If W = AICClientW AndAlso H = AICClientH Then Exit Sub
		Dim As Boolean WasBottom = AICAtBottom()
		AICClientH = H
		If W <> AICClientW Then
			AICClientW = W
			If AICLayouts(0) = 0 Then AICCreateFonts
			AICRelayoutAll
		End If
		AICUpdateScroll(WasBottom)
		AICInvalidate
	End Sub

	Sub pnlAICCanvas_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		AICUpdateSize
	End Sub

	Sub scrAIC_Scroll(ByRef Designer As My.Sys.Object, ByRef Sender As VScrollBar, ByRef NewPos As UInteger)
		If AICScrollSetting Then Exit Sub
		AICScroll = Max(0, Min(CLng(NewPos), Max(0, AICTotalH - AICClientH)))
		AICInvalidate
	End Sub

	Sub pnlAICCanvas_MouseDown(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		AICLastX = x: AICLastY = y
		If AICWnd Then gtk_widget_grab_focus(AICWnd)
		If MouseButton = 2 Then
			'The selection of the menu (it is opened when the button is released): the code block or the message under
			'the mouse
			Dim As Integer MsgIndex
			Dim As UString Action = AICHitTest(x, y, 3, MsgIndex)
			If AICHasSel() Then
				AIChatViewSelection = AICSelText()
			ElseIf StartsWith(Action, "code:") Then
				AIChatViewSelection = Mid(Action, 6)
			ElseIf MsgIndex >= 0 Then
				AIChatViewSelection = AICMsgs(MsgIndex).Body
			Else
				AIChatViewSelection = ""
			End If
			Exit Sub
		End If
		If MouseButton <> 0 Then Exit Sub
		Dim As AICPos P = AICPosAt(x, y)
		If (Shift And GDK_SHIFT_MASK) <> 0 AndAlso AICMsgCount > 0 Then
			AICSelB = P
			AICDragged = True
		Else
			AICSelA = P: AICSelB = P
			AICDragged = False
		End If
		AICSelecting = True
		AICDownX = x: AICDownY = y
		AICInvalidate
	End Sub

	Sub pnlAICCanvas_MouseMove(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Dim As Integer MsgIndex
		If AICSelecting Then
			If Abs(x - AICDownX) > 3 OrElse Abs(y - AICDownY) > 3 Then AICDragged = True
			If AICDragged Then
				'Out of the panel: it scrolls
				If y < 0 Then
					AICScrollTo(AICScroll + y)
				ElseIf y > AICClientH Then
					AICScrollTo(AICScroll + y - AICClientH)
				End If
				AICSelB = AICPosAt(x, Max(0, Min(y, AICClientH - 1)))
				AICInvalidate
			End If
			Exit Sub
		End If
		If AICHitTest(x, y, 6, MsgIndex) <> "" Then
			AICSetCursor "pointer"
		ElseIf AICOverText(x, y) Then
			AICSetCursor "text"
		Else
			AICSetCursor "default"
		End If
	End Sub

	Sub pnlAICCanvas_MouseUp(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		If MouseButton <> 0 Then Exit Sub
		Dim As Boolean WasSelecting = AICSelecting
		AICSelecting = False
		If WasSelecting AndAlso Not AICDragged Then
			'A click: no selection, the action of the place
			AICSelB = AICSelA
			AICInvalidate
			Dim As Integer MsgIndex
			Dim As UString Action = AICHitTest(x, y, 6, MsgIndex)
			If Action <> "" Then AICAction(Action, MsgIndex)
		End If
	End Sub

	'The word at the place (the second press of the double click came first: its release does nothing)
	Sub pnlAICCanvas_DblClick(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As Integer MsgIndex
		AICSelecting = False
		If AICHitTest(AICLastX, AICLastY, 6, MsgIndex) = "" Then
			Dim As AICPos P = AICPosAt(AICLastX, AICLastY)
			AICSelectWord(P)
		End If
	End Sub

	Sub pnlAICCanvas_MouseWheel(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Direction As Integer, x As Integer, y As Integer, Shift As Integer)
		If Direction = 0 Then Exit Sub
		AICScrollTo(AICScroll + Sgn(Direction) * AICLineH(0) * 3)
	End Sub

	Sub pnlAICCanvas_KeyDown(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer)
		If (Shift And GDK_CONTROL_MASK) <> 0 Then
			Select Case Key
			Case GDK_KEY_c, GDK_KEY_C, GDK_KEY_Insert
				If AICHasSel() Then Clipboard.SetAsText AICSelText()
				Exit Sub
			Case GDK_KEY_a, GDK_KEY_A
				AICSelectAll
				Exit Sub
			End Select
		End If
		Select Case Key
		Case GDK_KEY_Up: AICScrollTo(AICScroll - AICLineH(0))
		Case GDK_KEY_Down: AICScrollTo(AICScroll + AICLineH(0))
		Case GDK_KEY_Page_Up: AICScrollTo(AICScroll - AICClientH)
		Case GDK_KEY_Page_Down: AICScrollTo(AICScroll + AICClientH)
		Case GDK_KEY_Home: AICScrollTo(0)
		Case GDK_KEY_End: AICScrollTo(AICTotalH)
		End Select
	End Sub

	'The panel of the drawing and its scroll bar in the panel of the views
	Sub AICCreate()
		If AICWnd <> 0 Then Exit Sub
		scrAIC.Name = "scrAIC"
		scrAIC.Align = DockStyle.alRight
		scrAIC.OnScroll = @scrAIC_Scroll
		scrAIC.Parent = @pnlAIView
		pnlAICCanvas.Name = "pnlAICCanvas"
		pnlAICCanvas.Align = DockStyle.alClient
		pnlAICCanvas.OnPaint = @pnlAICCanvas_Paint
		pnlAICCanvas.OnResize = @pnlAICCanvas_Resize
		pnlAICCanvas.OnMouseDown = @pnlAICCanvas_MouseDown
		pnlAICCanvas.OnMouseMove = @pnlAICCanvas_MouseMove
		pnlAICCanvas.OnMouseUp = @pnlAICCanvas_MouseUp
		pnlAICCanvas.OnDblClick = @pnlAICCanvas_DblClick
		pnlAICCanvas.OnMouseWheel = @pnlAICCanvas_MouseWheel
		pnlAICCanvas.OnKeyDown = @pnlAICCanvas_KeyDown
		pnlAICCanvas.ContextMenu = @mnuAIChat
		pnlAICCanvas.Parent = @pnlAIView
		AICWnd = pnlAICCanvas.Handle
		If AICWnd Then
			#ifdef __USE_GTK4__
				gtk_widget_set_focusable(AICWnd, True)
			#else
				gtk_widget_set_can_focus(AICWnd, True)
			#endif
		End If
		AICColors = AIChatPalette()
		AIChatNeedFull = True
	End Sub

	' ==========================================
	' WebKitGTK (loaded when it is chosen: webkit2gtk-4.1 or 4.0 for GTK3, webkitgtk-6.0 for GTK4, webkitgtk-1.0 (WebKit1)
	' for GTK2; the IDE does not need it to start)
	' ==========================================

	Dim Shared As Any Ptr AIWKLib
	'AIWKHost: the widget in the panel (the web view, in a scrolled window for WebKit1)
	Dim Shared As GtkWidget Ptr AIWKView, AIWKHost
	Dim Shared As Boolean AIWKStarted, AIWKReady
	Dim Shared AIWKEvaluate As Sub cdecl(ByVal WebView As Any Ptr, ByVal Script As ZString Ptr, ByVal Length As gssize, ByVal WorldName As ZString Ptr, ByVal SourceUri As ZString Ptr, ByVal Cancellable As Any Ptr, ByVal Callback As Any Ptr, ByVal UserData As Any Ptr)
	Dim Shared AIWKRunScript As Sub cdecl(ByVal WebView As Any Ptr, ByVal Script As ZString Ptr, ByVal Cancellable As Any Ptr, ByVal Callback As Any Ptr, ByVal UserData As Any Ptr)
	Dim Shared AIWKResultValue As Function cdecl(ByVal Result As Any Ptr) As Any Ptr
	Dim Shared AIWKValueToString As Function cdecl(ByVal Value As Any Ptr) As ZString Ptr
	#ifdef __USE_GTK2__
		Dim Shared AIWK1Execute As Sub cdecl(ByVal WebView As Any Ptr, ByVal Script As ZString Ptr)
		Dim Shared AIWK1LoadStatus As Function cdecl(ByVal WebView As Any Ptr) As Long
	#endif

	Dim Shared As UString AIWKFailReason

	'The message is shown by an idle function with the lock of GDK (like the events): ShowMessages runs the main loop,
	'from a timer of GLib (without the lock) it locked GTK2
	Function AIWKFailIdle cdecl(ByVal UserData As gpointer) As gboolean
		ShowMessages("AI Agent, WebKitGTK: " & AIWKFailReason)
		Return False
	End Function

	'WebKitGTK can not be used: the message and the own control
	Sub AIWKFail(ByRef Reason As WString)
		AIWKFailReason = Reason
		gdk_threads_add_idle(Cast(GSourceFunc, @AIWKFailIdle), NULL)
		If AIChatViewMode = acvWebView2 Then AIChatSetViewMode(acvCustom, False)
	End Sub

	'A message of the page (window.webkit.messageHandlers.vfb.postMessage): GTK3 gives a WebKitJavascriptResult, GTK4
	'the JSCValue
	Sub AIWKMessage cdecl(ByVal Manager As Any Ptr, ByVal Value As Any Ptr, ByVal UserData As Any Ptr)
		If Value = 0 OrElse AIWKValueToString = 0 Then Exit Sub
		If AIWKResultValue Then Value = AIWKResultValue(Value)
		If Value = 0 Then Exit Sub
		Dim As ZString Ptr S = AIWKValueToString(Value)
		If S = 0 Then Exit Sub
		'The text is encoded by encodeURIComponent (ASCII)
		Dim As UString Encoded = WStr(*S)
		g_free(S)
		AIChatViewMessage AIUrlDecode(Encoded)
	End Sub

	Sub AIWKLoadChanged cdecl(ByVal WebView As Any Ptr, ByVal LoadEvent As Long, ByVal UserData As Any Ptr)
		'WEBKIT_LOAD_FINISHED
		If LoadEvent = 3 Then
			AIWKReady = True
			AIChatNeedFull = True
		End If
	End Sub

	#ifdef __USE_GTK2__
		'WebKit1 has no message handlers: the page sends its messages by console.log("vfb:" & message)
		Function AIWK1Console cdecl(ByVal WebView As Any Ptr, ByVal Message As ZString Ptr, ByVal LineNo As Long, ByVal SourceId As ZString Ptr, ByVal UserData As Any Ptr) As gboolean
			If Message = 0 OrElse Left(*Message, 4) <> "vfb:" Then Return False
			Dim As UString Encoded = WStr(Mid(*Message, 5))
			AIChatViewMessage AIUrlDecode(Encoded)
			Return True
		End Function

		'The property load-status of WebKit1: the page is loaded (WEBKIT_LOAD_FINISHED), its messages go to the console
		Sub AIWK1LoadNotify cdecl(ByVal Obj As Any Ptr, ByVal Spec As Any Ptr, ByVal UserData As Any Ptr)
			If AIWK1LoadStatus = 0 OrElse AIWKView = 0 Then Exit Sub
			If AIWK1LoadStatus(AIWKView) = 2 Then
				If AIWK1Execute Then AIWK1Execute(AIWKView, "window.vfbConsole=1;")
				AIWKReady = True
				AIChatNeedFull = True
			End If
		End Sub
	#endif

	'The menu of WebKit is not shown (the page sends menu: for the menu of the chat)
	Function AIWKContextMenu cdecl(ByVal WebView As Any Ptr) As gboolean
		Return True
	End Function

	#ifndef __USE_GTK4__
		'The press of the right button is kept for the menu which the page asks after it
		Function AIWKButtonPress cdecl(ByVal Widget As GtkWidget Ptr, ByVal Event As GdkEvent Ptr, ByVal UserData As Any Ptr) As gboolean
			If Event <> 0 AndAlso Event->button.button = 3 Then
				If AIChatMenuEvent Then gdk_event_free(AIChatMenuEvent)
				AIChatMenuEvent = gdk_event_copy(Event)
			End If
			Return False
		End Function
	#endif

	'The web view fills its panel
	Sub AIWKResize()
		If AIWKHost = 0 OrElse pnlAIWebView2.Handle = 0 Then Exit Sub
		Dim As Long W, H
		#ifdef __USE_GTK4__
			W = gtk_widget_get_width(pnlAIWebView2.Handle): H = gtk_widget_get_height(pnlAIWebView2.Handle)
		#elseif defined(__USE_GTK2__)
			W = pnlAIWebView2.Handle->allocation.width: H = pnlAIWebView2.Handle->allocation.height
		#else
			W = gtk_widget_get_allocated_width(pnlAIWebView2.Handle): H = gtk_widget_get_allocated_height(pnlAIWebView2.Handle)
		#endif
		If W <= 1 OrElse H <= 1 Then Exit Sub
		Dim As Long OldW, OldH
		gtk_widget_get_size_request(AIWKHost, @OldW, @OldH)
		If OldW <> W OrElse OldH <> H Then gtk_widget_set_size_request(AIWKHost, W, H)
	End Sub

	Sub pnlAIWebView2_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		AIWKResize
	End Sub

	'Loads WebKitGTK and makes its web view in pnlAIWebView2
	Sub AIWKStart()
		If AIWKStarted OrElse pnlAIWebView2.Handle = 0 Then Exit Sub
		AIWKStarted = True
		#ifdef __USE_GTK2__
			'WebKit1 (webkitgtk-1.0): another API, the view in a scrolled window
			Dim As String LibName = "libwebkitgtk-1.0.so.0"
			AIWKLib = DyLibLoad(LibName)
			If AIWKLib = 0 Then AIWKLib = DyLibLoad("libwebkitgtk-1.0.so")
			If AIWKLib = 0 Then AIWKFail(ML("WebKitGTK is not installed") & " (" & LibName & ")"): Exit Sub
			Dim ViewNew As Function cdecl() As GtkWidget Ptr = DyLibSymbol(AIWKLib, "webkit_web_view_new")
			Dim LoadString As Sub cdecl(ByVal WebView As Any Ptr, ByVal Content As ZString Ptr, ByVal MimeType As ZString Ptr, ByVal Encoding As ZString Ptr, ByVal BaseUri As ZString Ptr) = DyLibSymbol(AIWKLib, "webkit_web_view_load_string")
			AIWK1Execute = DyLibSymbol(AIWKLib, "webkit_web_view_execute_script")
			AIWK1LoadStatus = DyLibSymbol(AIWKLib, "webkit_web_view_get_load_status")
			If ViewNew = 0 OrElse LoadString = 0 OrElse AIWK1Execute = 0 OrElse AIWK1LoadStatus = 0 Then
				AIWKFail(ML("The functions of WebKitGTK are not found") & " (" & LibName & ")")
				Exit Sub
			End If
			AIWKView = ViewNew()
			If AIWKView = 0 Then AIWKFail("webkit_web_view_new"): Exit Sub
			g_signal_connect(AIWKView, "console-message", G_CALLBACK(@AIWK1Console), NULL)
			g_signal_connect(AIWKView, "notify::load-status", G_CALLBACK(@AIWK1LoadNotify), NULL)
			'The signal context-menu is in WebKit1 from 1.10
			If g_signal_lookup("context-menu", G_OBJECT_TYPE(AIWKView)) <> 0 Then g_signal_connect(AIWKView, "context-menu", G_CALLBACK(@AIWKContextMenu), NULL)
			g_signal_connect(AIWKView, "button-press-event", G_CALLBACK(@AIWKButtonPress), NULL)
			AIWKHost = gtk_scrolled_window_new(NULL, NULL)
			gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(AIWKHost), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC)
			gtk_container_add(GTK_CONTAINER(AIWKHost), AIWKView)
			gtk_layout_put(GTK_LAYOUT(pnlAIWebView2.Handle), AIWKHost, 0, 0)
			gtk_widget_show_all(AIWKHost)
			AIWKResize
			LoadString(AIWKView, ToUtf8(AIChatHtmlShell()), "text/html", "UTF-8", "file:///")
		#else
		'Without the compositing and the DMA-BUF renderer of the GPU (an empty page with some drivers, WSLg without DRI3;
		'GTK4 has always the compositing): the user can set them
		g_setenv("WEBKIT_DISABLE_COMPOSITING_MODE", "1", False)
		g_setenv("WEBKIT_DISABLE_DMABUF_RENDERER", "1", False)
		#ifdef __USE_GTK4__
			Dim As String LibName = "libwebkitgtk-6.0.so.4"
			AIWKLib = DyLibLoad(LibName)
		#else
			Dim As String LibName = "libwebkit2gtk-4.1.so.0"
			AIWKLib = DyLibLoad(LibName)
			If AIWKLib = 0 Then AIWKLib = DyLibLoad("libwebkit2gtk-4.0.so.37")
		#endif
		If AIWKLib = 0 Then AIWKFail(ML("WebKitGTK is not installed") & " (" & LibName & ")"): Exit Sub
		Dim ViewNew As Function cdecl() As GtkWidget Ptr = DyLibSymbol(AIWKLib, "webkit_web_view_new")
		Dim GetContentManager As Function cdecl(ByVal WebView As Any Ptr) As Any Ptr = DyLibSymbol(AIWKLib, "webkit_web_view_get_user_content_manager")
		'GTK3: (manager, name), GTK4: (manager, name, world_name)
		Dim RegisterHandler As Function cdecl(ByVal Manager As Any Ptr, ByVal HandlerName As ZString Ptr, ByVal WorldName As ZString Ptr) As gboolean = DyLibSymbol(AIWKLib, "webkit_user_content_manager_register_script_message_handler")
		Dim LoadHtml As Sub cdecl(ByVal WebView As Any Ptr, ByVal Content As ZString Ptr, ByVal BaseUri As ZString Ptr) = DyLibSymbol(AIWKLib, "webkit_web_view_load_html")
		AIWKEvaluate = DyLibSymbol(AIWKLib, "webkit_web_view_evaluate_javascript")
		If AIWKEvaluate = 0 Then AIWKRunScript = DyLibSymbol(AIWKLib, "webkit_web_view_run_javascript")
		AIWKValueToString = DyLibSymbol(AIWKLib, "jsc_value_to_string")
		#ifndef __USE_GTK4__
			AIWKResultValue = DyLibSymbol(AIWKLib, "webkit_javascript_result_get_js_value")
		#endif
		If ViewNew = 0 OrElse GetContentManager = 0 OrElse RegisterHandler = 0 OrElse LoadHtml = 0 OrElse (AIWKEvaluate = 0 AndAlso AIWKRunScript = 0) Then
			AIWKFail(ML("The functions of WebKitGTK are not found") & " (" & LibName & ")")
			Exit Sub
		End If
		AIWKView = ViewNew()
		If AIWKView = 0 Then AIWKFail("webkit_web_view_new"): Exit Sub
		Dim As Any Ptr Manager = GetContentManager(AIWKView)
		If Manager Then
			g_signal_connect(Manager, "script-message-received::vfb", G_CALLBACK(@AIWKMessage), NULL)
			RegisterHandler(Manager, "vfb", NULL)
		End If
		g_signal_connect(AIWKView, "load-changed", G_CALLBACK(@AIWKLoadChanged), NULL)
		g_signal_connect(AIWKView, "context-menu", G_CALLBACK(@AIWKContextMenu), NULL)
		#ifndef __USE_GTK4__
			g_signal_connect(AIWKView, "button-press-event", G_CALLBACK(@AIWKButtonPress), NULL)
		#endif
		AIWKHost = AIWKView
		gtk_layout_put(GTK_LAYOUT(pnlAIWebView2.Handle), AIWKHost, 0, 0)
		gtk_widget_show(AIWKHost)
		AIWKResize
		'The base file:/// lets the page show the pictures of the files
		LoadHtml(AIWKView, ToUtf8(AIChatHtmlShell()), "file:///")
		#endif
	End Sub

	Sub AIWKExec(ByRef Script As WString)
		If AIWKView = 0 Then Exit Sub
		Dim As String S = ToUtf8(Script)
		#ifdef __USE_GTK2__
			If AIWK1Execute Then AIWK1Execute(AIWKView, StrPtr(S))
			Exit Sub
		#endif
		If AIWKEvaluate Then
			AIWKEvaluate(AIWKView, StrPtr(S), Len(S), NULL, NULL, NULL, NULL, NULL)
		ElseIf AIWKRunScript Then
			AIWKRunScript(AIWKView, StrPtr(S), NULL, NULL, NULL)
		End If
	End Sub

	'The views are drawn by a timer of the main loop (the threads of the requests only add the text)
	Function AIChatTimerGtk(ByVal user_data As gpointer) As gboolean
		Static As Boolean Busy
		If Busy Then Return True
		Busy = True
		If AIChatStatusTick() Then AIChatViewDirty = True
		Select Case AIChatViewMode
		Case acvWebView2
			If Not AIWKStarted Then AIWKStart
			AIWKResize
			If AIWKReady AndAlso (AIChatViewDirty OrElse AIChatNeedFull) Then AIWKExec AIChatRenderScript()
		Case acvCustom
			If AICWnd = 0 Then AICCreate
			If AICWnd <> 0 Then
				If AICLayouts(0) = 0 Then AICCreateFonts
				AICUpdateSize
				If AIChatViewDirty OrElse AIChatNeedFull Then AICUpdate
			End If
		End Select
		Busy = False
		Return True
	End Function
	#endif
#endif

'Chooses the view of the chat (Save: it is the view of the next starts too)
Sub AIChatSetViewMode(Mode As Integer, SaveMode As Boolean)
	If Mode < acvRTF OrElse Mode > acvD2D Then Mode = acvRTF
	#ifndef __USE_WINAPI__
		'GTK: the RTF view, WebKitGTK or the own control (cairo)
		#ifdef __USE_GTK__
			If Mode <> acvRTF AndAlso Mode <> acvWebView2 Then Mode = acvCustom
		#else
			Mode = acvRTF
		#endif
	#endif
	#ifdef __USE_WINAPI__
		If Mode = acvD2D AndAlso (pD2D1Factory = 0 OrElse pDWriteFactory = 0) Then
			ShowMessages ML("Direct2D is not available") & ": " & ML("Own control") & " (GDI+)"
			Mode = acvCustom
		End If
	#endif
	Dim As Integer OldMode = AIChatViewMode
	AIChatViewMode = Mode
	If SaveMode Then iniSettings.WriteInteger("Options", "AIChatView", Mode)
	For i As Integer = 0 To 4
		If miAIChatView(i) Then miAIChatView(i)->Checked = (i = Mode)
	Next
	txtAIAgent.Visible = (Mode = acvRTF)
	pnlAIView.Visible = (Mode <> acvRTF)
	#ifdef __USE_WINAPI__
		pnlAIWebView2.Visible = (Mode = acvWebView2)
		If AIWV2Controller Then AIWV2Controller->lpVtbl->put_IsVisible(AIWV2Controller, Mode = acvWebView2)
		If Mode = acvIE AndAlso AIIE = 0 Then
			AIIE = New AIIEBrowser
			AIIE->Align = DockStyle.alClient
			AIIE->Parent = @pnlAIView
		End If
		If AIIE Then AIIE->Visible = (Mode = acvIE)
		If AICWnd Then ShowWindow(AICWnd, IIf(Mode = acvCustom OrElse Mode = acvD2D, SW_SHOW, SW_HIDE))
		'GDI or Direct2D: the texts are measured again (the whole chat is laid out again)
		AICUseD2D = (Mode = acvD2D)
		If AICWnd Then InvalidateRect(AICWnd, 0, False)
	#endif
	pnlAIChat.RequestAlign
	If Mode = acvRTF Then
		'The RTF of the whole chat
		If OldMode <> acvRTF AndAlso AIMDtoRTFConverterPtr <> 0 Then
			'The markdown (AIChatText gives the text of the RichTextBox in this view)
			Dim As UString Text
			MutexLock AIChatMDMutex
			If AIChatMD Then Text = *AIChatMD
			MutexUnlock AIChatMDMutex
			AIMDtoRTFConverterPtr->Initial(*EditorFontName, EditorFontSize, 9)
			txtAIAgent.TextRTF = ""
			If Text <> "" Then AIMDtoRTFConverterPtr->FeedChunk(AIChatRTFText(Text))
		End If
	Else
		MutexLock AIChatMDMutex
		AIChatNeedFull = True
		MutexUnlock AIChatMDMutex
		#ifdef __USE_WINAPI__
			If Mode = acvCustom OrElse Mode = acvD2D Then
				AICCreate
				If AICWnd Then
					AICFit
					ShowWindow(AICWnd, SW_SHOW)
				End If
			End If
		#elseif defined(__USE_GTK__)
			AICCreate
			AICColors = AIChatPalette()
			AICInvalidate
		#endif
	End If
	#ifdef __USE_GTK__
		'The web view or the own control in the panel of the views
		pnlAIWebView2.Visible = (Mode = acvWebView2)
		pnlAICCanvas.Visible = (Mode = acvCustom)
		scrAIC.Visible = (Mode = acvCustom)
		pnlAIView.RequestAlign
		If Mode = acvWebView2 Then
			AIWKStart
			'WebKitGTK could not be loaded: AIWKFail has chosen the own control already
			If AIChatViewMode <> acvWebView2 Then Exit Sub
			AIWKResize
		End If
	#endif
End Sub

'The commands of the menu Edit (Copy, Select All) when the own control has the focus: True if the view did them
Function AIChatViewCommand(ByRef Cmd As WString) As Boolean
	#ifdef __USE_WINAPI__
		If AICWnd = 0 OrElse GetFocus() <> AICWnd Then Return False
		Select Case Cmd
		Case "Copy": If AICHasSel() Then Clipboard.SetAsText AICSelText()
		Case "SelectAll": AICSelectAll
		End Select
		Return True
	#elseif defined(__USE_GTK__)
		If AICWnd = 0 OrElse AIChatViewMode <> acvCustom OrElse gtk_widget_has_focus(AICWnd) = 0 Then Return False
		Select Case Cmd
		Case "Copy": If AICHasSel() Then Clipboard.SetAsText AICSelText()
		Case "SelectAll": AICSelectAll
		End Select
		Return True
	#else
		Return False
	#endif
End Function

'The text for the menu of the chat: the selection of the view
Function AIChatSelectedText() As UString
	If AIChatViewMode = acvRTF Then Return txtAIAgent.SelText
	Return AIChatViewSelection
End Function

Sub mClickAIChatView(ByRef Designer As My.Sys.Object, Sender As My.Sys.Object)
	Select Case Sender.ToString
	Case "AIChatView0": AIChatSetViewMode(acvRTF)
	Case "AIChatView1": AIChatSetViewMode(acvWebView2)
	Case "AIChatView2": AIChatSetViewMode(acvIE)
	Case "AIChatView3": AIChatSetViewMode(acvCustom)
	Case "AIChatView4": AIChatSetViewMode(acvD2D)
	Case "AIChatCopy"
		If AIChatViewMode = acvRTF Then
			If txtAIAgent.SelText <> "" Then Clipboard.SetAsText txtAIAgent.SelText
		ElseIf AIChatViewSelection <> "" Then
			Clipboard.SetAsText AIChatViewSelection
		#if defined(__USE_WINAPI__) OrElse defined(__USE_GTK__)
		ElseIf CBool(AIChatViewMode = acvCustom OrElse AIChatViewMode = acvD2D) AndAlso AICHasSel() Then
			Clipboard.SetAsText AICSelText()
		#endif
		End If
	End Select
End Sub

Sub AIChatAddViewMenu()
	mnuAIChat.Add("-")
	mnuAIChat.Add(ML("&Copy"), "Copy", "AIChatCopy", @mClickAIChatView)
	Var miView = mnuAIChat.Add(ML("View"), "", "AIChatViewMenu")
	'The names: the control (the engine which shows the chat)
	#ifdef __USE_WINAPI__
		miAIChatView(0) = miView->Add("RichTextBox (RichEdit)", "", "AIChatView0", @mClickAIChatView, True)
		miAIChatView(1) = miView->Add("WebBrowser (WebView2)", "", "AIChatView1", @mClickAIChatView, True)
		miAIChatView(2) = miView->Add("WebBrowser (IE)", "", "AIChatView2", @mClickAIChatView, True)
		miAIChatView(3) = miView->Add(ML("Own control") & " (GDI+)", "", "AIChatView3", @mClickAIChatView, True)
		miAIChatView(4) = miView->Add(ML("Own control") & " (Direct2D)", "", "AIChatView4", @mClickAIChatView, True)
	#elseif defined(__USE_GTK__)
		miAIChatView(0) = miView->Add("RichTextBox (GtkTextView)", "", "AIChatView0", @mClickAIChatView, True)
		miAIChatView(1) = miView->Add("WebBrowser (WebKitGTK)", "", "AIChatView1", @mClickAIChatView, True)
		miAIChatView(3) = miView->Add(ML("Own control") & " (cairo)", "", "AIChatView3", @mClickAIChatView, True)
	#else
		miAIChatView(0) = miView->Add("RichTextBox", "", "AIChatView0", @mClickAIChatView, True)
	#endif
	For i As Integer = 0 To 4
		If miAIChatView(i) Then miAIChatView(i)->Checked = (i = AIChatViewMode)
	Next
End Sub

'The panel of the views 1-3 (on the place of txtAIAgent)
AIChatMDMutex = MutexCreate
pnlAIView.Name = "pnlAIView"
pnlAIView.Align = DockStyle.alClient
pnlAIView.Visible = False
pnlAIView.Parent = @pnlAIChat
#ifdef __USE_WINAPI__
	pnlAIView.OnResize = @pnlAIView_Resize
	pnlAIWebView2.Name = "pnlAIWebView2"
	pnlAIWebView2.Align = DockStyle.alClient
	pnlAIWebView2.Visible = False
	pnlAIWebView2.OnResize = @pnlAIWebView2_Resize
	pnlAIWebView2.Parent = @pnlAIView
	AIChatViewMode = iniSettings.ReadInteger("Options", "AIChatView", acvRTF)
	If AIChatViewMode < acvRTF OrElse AIChatViewMode > acvD2D Then AIChatViewMode = acvRTF
	SetTimer(0, 0, 100, Cast(TIMERPROC, @AIChatTimerProc))
#elseif defined(__USE_GTK__)
	pnlAIWebView2.Name = "pnlAIWebView2"
	pnlAIWebView2.Align = DockStyle.alClient
	pnlAIWebView2.Visible = False
	pnlAIWebView2.OnResize = @pnlAIWebView2_Resize
	pnlAIWebView2.Parent = @pnlAIView
	AIChatViewMode = iniSettings.ReadInteger("Options", "AIChatView", acvRTF)
	AICCreate
	g_timeout_add(100, Cast(GSourceFunc, @AIChatTimerGtk), NULL)
#endif
AIChatSetViewMode(AIChatViewMode, False)
