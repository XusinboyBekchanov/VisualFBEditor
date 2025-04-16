#pragma once
' AiAgent 人工智能
' Copyright (c) 2025 CM.Wang
' Freeware. Use at your own risk.


Constructor AiAgent()
	HTTPConnection1.Designer = @This
	HTTPConnection1.OnReceive = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As HTTPConnection, ByRef Request As HTTPRequest, ByRef Buffer As String), @HTTPReceive)
	HTTPConnection1.OnComplete = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As HTTPConnection, ByRef Request As HTTPRequest, ByRef Responce As HTTPResponce), @HTTPComplete)
	
	LoadDefault()
End Constructor

Destructor AiAgent()
	HistoryClear()
	If APIKey Then Deallocate(APIKey)
	If HTTPHost Then Deallocate(HTTPHost)
	If LocContentEnd Then Deallocate(LocContentEnd)
	If LocContentSplit Then Deallocate(LocContentSplit)
	If LocContentStart Then Deallocate(LocContentStart)
	If LocReasonEnd Then Deallocate(LocReasonEnd)
	If LocReasonSplit Then Deallocate(LocReasonSplit)
	If LocReasonStart Then Deallocate(LocReasonStart)
	If ModelName Then Deallocate(ModelName)
	If ProfileName Then Deallocate(ProfileName)
	If ResourceAddress Then Deallocate(ResourceAddress)
	If TemplateAssistant Then Deallocate(TemplateAssistant)
	If TemplateBody Then Deallocate(TemplateBody)
	If TemplateHeader Then Deallocate(TemplateHeader)
End Destructor

Private Sub AiAgent.HistoryClear()
	HistoryCount = -1
	ArrayDeallocate(HistoryA())
	ArrayDeallocate(HistoryAssistantA())
	ArrayDeallocate(HistoryContentA())
	ArrayDeallocate(HistoryQuestionA())
	ArrayDeallocate(HistoryReasonA())
	ArrayDeallocate(RequestBodyA())
	ArrayDeallocate(RequestHeaderA())
	ArrayDeallocate(ResponceBufferA())
End Sub

Private Sub AiAgent.RequestInit()
	ResponceCount = -1
	ResponceBuffer = ""
	Erase ResponceBufferStrA
End Sub

Private Sub AiAgent.HTTPReceive(ByRef Designer As My.Sys.Object, ByRef Sender As HTTPConnection, ByRef Request As HTTPRequest, ByRef Buffer As String)
	Dim As AiAgent Ptr a = Cast(AiAgent Ptr, @Designer)
	a->ResponceCount += 1
	ReDim Preserve a->ResponceBufferStrA(a->ResponceCount)
	a->ResponceBufferStrA(a->ResponceCount) = Buffer
	a->ResponceBuffer += Buffer
	
	Dim As WString Ptr WStrReason = NULL
	Dim As WString Ptr WStrContent = NULL
	
	a->StreamAnalyze(Buffer, WStrReason, WStrContent, True)
	If a->OnStream Then a->OnStream(a->Owner, a->ResponceCount, WStrReason, WStrContent)
	
	If WStrReason Then Deallocate(WStrReason)
	If WStrContent Then Deallocate(WStrContent)
End Sub

Private Sub AiAgent.HTTPComplete(ByRef Designer As My.Sys.Object, ByRef Sender As HTTPConnection, ByRef Request As HTTPRequest, ByRef Responce As HTTPResponce)
	Dim As AiAgent Ptr a = Cast(AiAgent Ptr, @Designer)
	Dim As WString Ptr WStrReason = NULL
	Dim As WString Ptr WStrContent = NULL
	
	a->StreamAnalyze(a->ResponceBuffer, WStrReason, WStrContent, True)
	a->HistoryAdd(WStrReason, WStrContent)
	If a->OnDone Then a->OnDone(a->Owner, WStrReason, WStrContent)
	
	If WStrReason Then Deallocate(WStrReason)
	If WStrContent Then Deallocate(WStrContent)
End Sub

Private Sub AiAgent.HistoryAdd(ByRef Reason As WString Ptr, ByRef Content As WString Ptr)
	HistoryCount += 1
	ReDim Preserve HistoryA(HistoryCount)
	ReDim Preserve HistoryAssistantA(HistoryCount)
	ReDim Preserve HistoryContentA(HistoryCount)
	ReDim Preserve HistoryQuestionA(HistoryCount)
	ReDim Preserve HistoryReasonA(HistoryCount)
	ReDim Preserve RequestBodyA(HistoryCount)
	ReDim Preserve RequestHeaderA(HistoryCount)
	ReDim Preserve ResponceBufferA(HistoryCount)
	
	WLet(HistoryA(HistoryCount), "Profile: " & *ProfileName)
	WAdd(HistoryA(HistoryCount), !"\r\nHost: " & *HTTPHost)
	WAdd(HistoryA(HistoryCount), !"\r\nAddress: " & *ResourceAddress)
	WAdd(HistoryA(HistoryCount), !"\r\nPort: " & HTTPPort)
	WAdd(HistoryA(HistoryCount), !"\r\n\r\n")
	TextFromUtf8(ResponceBuffer, ResponceBufferA(HistoryCount))
	WLet(RequestHeaderA(HistoryCount), *RequestHeader)
	WLet(RequestBodyA(HistoryCount), *RequestBody)
	WLet(HistoryQuestionA(HistoryCount), *AiQuestion)
	WLet(HistoryReasonA(HistoryCount), *Reason)
	WLet(HistoryContentA(HistoryCount), *Content)
	WLet(HistoryAssistantA(HistoryCount), Replace(Replace(*TemplateAssistant, "{content}", *AiQuestion), "{assistant}", WStr2Json(*Content)))
End Sub

Private Sub AiAgent.SetupInit()
	Dim i As Integer
	
	ArrayDeallocate(LocContentStartA())
	ArrayDeallocate(LocContentEndA())
	LocContentStartCount = SplitWStr(*LocContentStart, *LocContentSplit, LocContentStartA())
	LocContentEndCount = SplitWStr(*LocContentEnd, *LocContentSplit, LocContentEndA())
	ReDim LocContentStartLenA(LocContentStartCount)
	For i = 0 To LocContentStartCount
		LocContentStartLenA(i) = Len(*LocContentStartA(i))
	Next
	ReDim LocContentEndLenA(LocContentEndCount)
	For i = 0 To LocContentEndCount
		LocContentEndLenA(i) = Len(*LocContentEndA(i))
	Next
	
	ArrayDeallocate(LocReasonStartA())
	ArrayDeallocate(LocReasonEndA())
	LocReasonStartCount = SplitWStr(*LocReasonStart, *LocReasonSplit, LocReasonStartA())
	LocReasonEndCount = SplitWStr(*LocReasonEnd, *LocReasonSplit, LocReasonEndA())
	ReDim LocReasonStartLenA(LocReasonStartCount)
	For i = 0 To LocReasonStartCount
		LocReasonStartLenA(i) = Len(*LocReasonStartA(i))
	Next
	ReDim LocReasonEndLenA(LocReasonEndCount)
	For i = 0 To LocReasonEndCount
		LocReasonEndLenA(i) = Len(*LocReasonEndA(i))
	Next
End Sub

Private Sub AiAgent.LoadDefault()
	WLet(ProfileName, "OpenRouter")
	WLet(ModelName, "deepseek/deepseek-r1:free")
	WLet(HTTPHost, "openrouter.ai")
	WLet(ResourceAddress, "api/v1/chat/completions")
	WLet(APIKey, "")
	
	Temperature = 1
	HTTPPort = 443
	Stream = True
	WLet(TemplateHeader, !"Content-Type: application/json; charset=utf-8\r\nAuthorization: Bearer {apikey}\r\n")
	WLet(TemplateBody, _
	!"{\r\n" & _
	!"    ""model"":""{model name}"",\r\n" & _
	!"    ""stream"":{stream},\r\n" & _
	!"    ""temperature"":{temperature},\r\n" & _
	!"    ""messages"":[\r\n" & _
	!"{assistant}       {""role"":""user"",""content"":""{content}""}\r\n" & _
	!"    ],\r\n" & _
	!"}")
	WLet(TemplateAssistant, _
	!"       {""role"":""user"",""content"":""{content}""},\r\n" & _
	!"       {""role"":""assistant"",""content"":""{assistant}""},\r\n")
	
	WLet(LocContentStart, """content"":""{}"",""refusal"":null,""reasoning"":""")
	WLet(LocContentEnd, """,""reasoning"":null}")
	WLet(LocContentSplit, "{}")
	WLet(LocReasonStart, """reasoning"":""")
	WLet(LocReasonEnd, """},""{}""}}],""usage""")
	WLet(LocReasonSplit, "{}")
	
	SetupInit()
End Sub

Private Sub AiAgent.StreamAnalyze(ByRef Buffer As String, ByRef Reason As WString Ptr, ByRef Content As WString Ptr, ByVal crlf As Boolean = False)
	Dim As WString Ptr WStrBuffer = NULL, fStartA(), fHitA()
	Dim As Integer lenBuffer = Len(Buffer)
	Dim As Integer i, j, k, l, fStartACount, fHitACount
	
	TextFromUtf8(Buffer, WStrBuffer)
	lenBuffer = Len(*WStrBuffer)
	
	For i = 0 To LocContentStartCount
		fStartACount = SplitWStr(*WStrBuffer, *LocContentStartA(i), fStartA())
		If fStartACount > 0 Then
			For k = 1 To fStartACount
				For j = 0 To LocContentEndCount
					fHitACount = SplitWStr(*fStartA(k), *LocContentEndA(j), fHitA())
					If fHitACount > 0 Then
						If Len(*fHitA(0)) Then WAdd(Content, *fHitA(0))
						Exit For
					End If
				Next
			Next
		End If
	Next i
	
	For i = 0 To LocReasonStartCount
		fStartACount = SplitWStr(*WStrBuffer, *LocReasonStartA(i), fStartA())
		If fStartACount > 0 Then
			For k = 1 To fStartACount
				For j = 0 To LocReasonEndCount
					fHitACount = SplitWStr(*fStartA(k), *LocReasonEndA(j), fHitA())
					If fHitACount > 0 Then
						If Len(*fHitA(0)) Then WAdd(Reason, *fHitA(0))
						Exit For
					End If
				Next
			Next
		End If
	Next i
	If crlf Then
		If Content Then
			WLet(Content, Json2WStr(*Content))
		End If
		If Reason Then
			WLet(Reason, Json2WStr(*Reason))
		End If
	End If
	If WStrBuffer Then Deallocate WStrBuffer
	ArrayDeallocate(fStartA())
	ArrayDeallocate(fHitA())
End Sub

Private Sub AiAgent.RequestCreate(ByRef Question As WString)
	RequestInit()
	WLet(AiQuestion, WStr2Json(Question))
	mThread = ThreadCreate(Cast(Any Ptr, @RquestThread), @This)
End Sub

Private Function AiAgent.RquestThread(ByVal pParam As LPVOID) As DWORD
	Dim a As AiAgent Ptr = Cast(AiAgent Ptr, pParam)
	
	a->bThread = True
	
	Dim As HTTPRequest Request
	Dim As HTTPResponce Responce
	'body
	WLet(a->RequestBody, *a->TemplateBody)
	WLet(a->RequestBody, Replace(*a->RequestBody, "{model name}", *a->ModelName))
	WLet(a->RequestBody, Replace(*a->RequestBody, "{stream}", IIf(a->Stream = True, "true", "false")))
	WLet(a->RequestBody, Replace(*a->RequestBody, "{content}", *a->AiQuestion))
	WLet(a->RequestBody, Replace(*a->RequestBody, "{temperature}", "" & a->Temperature))
	If a->HistoryCount < 0 Then
		WLet(a->RequestBody, Replace(*a->RequestBody, "{assistant}", ""))
	Else
		WLet(a->RequestBody, Replace(*a->RequestBody, "{assistant}", *Join(a->HistoryAssistantA(), !"")))
	End If
	
	'header
	WLet(a->RequestHeader, Replace(*a->TemplateHeader, "{apikey}", *a->APIKey))
	
	a->HTTPConnection1.Host = ToUtf8(*a->HTTPHost)
	a->HTTPConnection1.Port = a->HTTPPort
	Request.ResourceAddress = ToUtf8(*a->ResourceAddress)
	Request.Headers = ToUtf8(*a->RequestHeader)
	Request.Body = ToUtf8(*a->RequestBody)
	
	a->HTTPConnection1.CallMethod("POST", Request, Responce)
	a->bThread = False
	Return 0
End Function
