#pragma once
' AiAgent 人工智能
' Copyright (c) 2025 CM.Wang
' Freeware. Use at your own risk.

Using My.Sys.Forms

Private Function DirToComlst(ByRef cbo As ComboBoxEdit, ByRef path As WString, ByRef extname As Const WString = ".profile") As Integer
	Dim As Integer i, l, r = 0
	Dim As String s = cbo.Text, f, t
	cbo.Clear
	f = Dir(path & "\*" & extname)
	Do
		l = Len(f) - Len(extname)
		If l > 0 Then
			r += 1
			t = Mid(f, 1, l)
			cbo.AddItem(t)
		End If
		f = Dir()
	Loop While f <> ""
	If s <> "" Then
		i = cbo.IndexOf(s)
		If i < 0 Then
			cbo.Text = s
		Else
			cbo.ItemIndex = i
		End If
	End If
	Function = r
End Function

Private Function TextFromComlst(ByRef cob As ComboBoxEdit, ByRef spt As WString, ByVal withtext As Boolean = False) As UString
	Dim As Integer i, j = cob.ItemCount - 1, k
	Dim As WString Ptr s, ss()
	
	If withtext Then
		k = j + 1
	Else
		k = j
	End If
	
	If k < 0 Then
		WLet(s, "")
	Else
		ReDim ss(k)
		If withtext Then WLet(ss(k), cob.Text)
		For i = 0 To j
			WLet(ss(i), cob.Item(i))
		Next
		JoinWStr(ss(), vbCrLf, s)
	End If
	Function = *s
	Deallocate(s)
	ArrayDeallocate(ss())
End Function

Private Sub TextToComlst(ByRef cob As ComboBoxEdit, ByRef txt As WString, ByRef spt As WString, ByVal withtext As Boolean = False)
	Dim As WString Ptr ss(), s
	Dim As Integer i, j = SplitWStr(txt, spt, ss()), k
	
	WLet(s, cob.Text)
	If withtext Then
		k = j - 1
	Else
		k = j
	End If
	
	cob.Clear
	For i = 0 To k
		cob.AddItem *ss(i)
	Next
	
	If withtext Then
		If j >-1 Then cob.Text = *ss(j)
	Else
		cob.Text = *s
	End If
	
	Deallocate(s)
	ArrayDeallocate(ss())
End Sub

Function WStr2Json(ByRef iText As WString) As UString
	Dim As WString Ptr result
	
	WLet(result, iText)
	WLet(result, ReplaceWStr(*result, !"\r\n", "\r\n"))
	WLet(result, ReplaceWStr(*result, !"\n", "\r\n"))
	WLet(result, ReplaceWStr(*result, !"\r", "\r\n"))
	WLet(result, ReplaceWStr(*result, !"\t", "\t"))
	WLet(result, ReplaceWStr(*result, """", "\"""))
	
	Function = *result
	Deallocate result
End Function

Function Json2WStr(ByRef iText As WString) As UString
	Dim As WString Ptr result
	
	WLet(result, iText)
	WLet(result, ReplaceWStr(*result, !"\r\n", ""))
	WLet(result, ReplaceWStr(*result, !"\r", ""))
	WLet(result, ReplaceWStr(*result, !"\n", ""))
	WLet(result, ReplaceWStr(*result, "\\r\\n", !"\r\n"))
	WLet(result, ReplaceWStr(*result, "\\r\\n", !"\r\n"))
	WLet(result, ReplaceWStr(*result, "\\r", !"\r\n"))
	WLet(result, ReplaceWStr(*result, "\\n", !"\r\n"))
	WLet(result, ReplaceWStr(*result, "\\t", !"\t"))
	WLet(result, ReplaceWStr(*result, "\r\n", !"\r\n"))
	WLet(result, ReplaceWStr(*result, "\r", !"\r\n"))
	WLet(result, ReplaceWStr(*result, "\n", !"\r\n"))
	WLet(result, ReplaceWStr(*result, "\t", !"\t"))
	WLet(result, ReplaceWStr(*result, "\\""", """"))
	WLet(result, ReplaceWStr(*result, "\""", """"))
	
	Function = *result
	Deallocate result
End Function

Private Sub AIDisplayText(txtBox As TextBox, MSG As WString, ByVal DisplayType As Integer = 2)
	txtBox.SelStart = Len(txtBox.Text)
	txtBox.SelEnd = txtBox.SelStart
	txtBox.ScrollToCaret
	txtBox.SelText = MSG
	txtBox.ScrollToEnd
End Sub

Type AiAgent Extends My.Sys.Object
	'Ai设置
	TemplateHeader As WString Ptr
	TemplateBody As WString Ptr
	TemplateAssistant As WString Ptr
	ProfileName As WString Ptr
	HTTPHost As WString Ptr
	ResourceAddress As WString Ptr
	HTTPPort As Integer
	ModelName As WString Ptr
	APIKey As WString Ptr
	Temperature As Single
	Stream As Boolean
	
	'Ai内容提取
	LocContentStart As WString Ptr
	LocContentEnd As WString Ptr
	LocContentSplit As WString Ptr
	LocContentStartA(Any) As WString Ptr
	LocContentEndA(Any) As WString Ptr
	LocContentStartCount As Integer
	LocContentStartLenA(Any) As Integer
	LocContentEndCount As Integer
	LocContentEndLenA(Any) As Integer
	'Ai思考提取
	LocReasonStart As WString Ptr
	LocReasonEnd As WString Ptr
	LocReasonSplit As WString Ptr
	LocReasonStartA(Any) As WString Ptr
	LocReasonEndA(Any) As WString Ptr
	LocReasonStartCount As Integer
	LocReasonStartLenA(Any) As Integer
	LocReasonEndCount As Integer
	LocReasonEndLenA(Any) As Integer
	
	'Ai当前信息
	ResponceCount As Integer
	ResponceBuffer As String
	ResponceBufferStrA(Any) As String
	AiQuestion As WString Ptr
	RequestHeader As WString Ptr
	RequestBody As WString Ptr
	
	'Ai历史信息
	HistoryA(Any) As WString Ptr
	RequestHeaderA(Any) As WString Ptr
	RequestBodyA(Any) As WString Ptr
	ResponceBufferA(Any) As WString Ptr
	HistoryQuestionA(Any) As WString Ptr
	HistoryReasonA(Any) As WString Ptr
	HistoryContentA(Any) As WString Ptr
	HistoryAssistantA(Any) As WString Ptr
	HistoryCount As Integer
	
	mThread As Any Ptr
	bThread As Boolean
	
	HTTPConnection1 As HTTPConnection
	Owner As Any Ptr = NULL
	
	Declare Constructor
	Declare Destructor
	
	Declare Sub HistoryClear()
	Declare Sub RequestCreate(ByRef Question As WString)
	Declare Sub RequestInit()
	Declare Sub HistoryAdd(ByRef Reason As WString Ptr, ByRef Content As WString Ptr)
	Declare Sub SetupInit()
	Declare Sub LoadDefault()
	Declare Sub StreamAnalyze(ByRef Buffer As String, ByRef Reason As WString Ptr, ByRef Content As WString Ptr, ByVal crlf As Boolean = False)
	Declare Static Function RquestThread(ByVal pParam As LPVOID) As DWORD
	Declare Static Sub HTTPReceive(ByRef Designer As My.Sys.Object, ByRef Sender As HTTPConnection, ByRef Request As HTTPRequest, ByRef Buffer As String)
	Declare Static Sub HTTPComplete(ByRef Designer As My.Sys.Object, ByRef Sender As HTTPConnection, ByRef Request As HTTPRequest, ByRef Responce As HTTPResponce)
	OnStream As Sub(ByRef mOwner As Any Ptr, ByRef Index As Integer, ByRef Reason As WString Ptr, ByRef Content As WString Ptr)
	OnDone As Sub(ByRef mOwner As Any Ptr, ByRef Reason As WString Ptr, ByRef Content As WString Ptr)
End Type

#ifndef __USE_MAKE__
	#include once "AiAgent.bas"
#endif
