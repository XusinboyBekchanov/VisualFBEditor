#pragma once
' PipeProcess 管道处理
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

#include once "PipeProcess.bi"

Constructor PipeProcess
End Constructor

Destructor PipeProcess
	PipeClosed()
End Destructor

Function PipeProcess.ThreadPipeRead(ByVal pParam As LPVOID) As DWORD
	Dim cPp As PipeProcess Ptr = Cast(PipeProcess Ptr ,pParam) '将空指针转换成类指针
	cPp->mThreadAlive = True
	cPp->PipeRead
	cPp->mThreadAlive = False
	If cPp->OnPipeClosed Then cPp->OnPipeClosed(cPp->mOwner, cPp->mErrorLevel)
	Return 0
End Function

Function PipeProcess.PipeCreate(Owner As Any Ptr, cmdStr As WString, rtnmsg As WString) As WINBOOL
	mOwner = Owner
	
	Dim InAttr As SECURITY_ATTRIBUTES
	InAttr.bInheritHandle = True
	InAttr.lpSecurityDescriptor = NULL
	InAttr.nLength = SizeOf(InAttr)
	
	Dim OutAttr As SECURITY_ATTRIBUTES
	OutAttr.bInheritHandle = True
	OutAttr.lpSecurityDescriptor = NULL
	OutAttr.nLength = SizeOf(OutAttr)
	
	Dim ErrAttr As SECURITY_ATTRIBUTES
	ErrAttr.bInheritHandle = True
	ErrAttr.lpSecurityDescriptor = NULL
	ErrAttr.nLength = SizeOf(ErrAttr)
	
	Dim rtn As WINBOOL
	'https://docs.microsoft.com/en-us/windows/win32/api/namedpipeapi/nf-namedpipeapi-createpipe
	rtn	 = CreatePipe(@hPipeInRead ,@hPipeInWrite ,@InAttr ,ByVal 0& )
	If rtn Then
	Else
		rtnmsg = "1.0 CreatePipe(@hPipeInRead, @hPipeInWrite, @InAttr, ByVal 0&) FAILED!"
		Return rtn
	End If
	
	rtn	 = CreatePipe(@hPipeOutRead ,@hPipeOutWrite ,@OutAttr ,ByVal 0& )
	If rtn Then
	Else
		rtnMsg = "1.1 CreatePipe(@hPipeOutRead, @hPipeOutWrite, @OutAttr, ByVal 0&) FAILED!"
		Return rtn
	End If
	
	rtn	 = CreatePipe(@hPipeErrRead ,@hPipeErrWrite ,@ErrAttr ,ByVal 0& )
	If rtn Then
	Else
		rtnMsg = "1.2 CreatePipe(@hPipeErrRead, @hPipeErrWrite, @ErrAttr, ByVal 0&) FAILED!"
		Return rtn
	End If
	
	'https://docs.microsoft.com/en-us/windows/win32/api/namedpipeapi/nf-namedpipeapi-setnamedpipehandlestate
	dwMode = PIPE_NOWAIT '启用非阻塞模式
	rtn	 = SetNamedPipeHandleState(hPipeOutRead ,@dwMode ,ByVal 0& ,ByVal 0& )
	If rtn Then
	Else
		rtnMsg = "2. SetNamedPipeHandleState (hPipeOutRead, @dwMode, ByVal 0&, ByVal 0&) FAILED!"
		Return rtn
	End If
	
	'https://docs.microsoft.com/en-us/windows/win32/api/handleapi/nf-handleapi-sethandleinformation
	rtn	 = SetHandleInformation(hPipeInWrite ,HANDLE_FLAG_INHERIT ,HANDLE_FLAG_INHERIT)
	If rtn Then
	Else
		rtnMsg = "3.0 SetHandleInformation(hPipeInWrite, HANDLE_FLAG_INHERIT, HANDLE_FLAG_INHERIT) FAILED!"
		Return rtn
	End If
	
	rtn	 = SetHandleInformation(hPipeOutRead ,HANDLE_FLAG_INHERIT ,HANDLE_FLAG_INHERIT)
	If rtn Then
	Else
		Return rtn
		rtnMsg = "3.1 SetHandleInformation(hPipeOutRead, HANDLE_FLAG_INHERIT, HANDLE_FLAG_INHERIT) FAILED!"
	End If
	
	rtn	 = SetHandleInformation(hPipeErrRead ,HANDLE_FLAG_INHERIT ,HANDLE_FLAG_INHERIT)
	If rtn Then
	Else
		rtnMsg = "3.2 SetHandleInformation(hPipeErrRead, HANDLE_FLAG_INHERIT, HANDLE_FLAG_INHERIT) FAILED!"
		Return rtn
	End If
	
	stStartInfo.dwFlags	 = STARTF_USESTDHANDLES
	stStartInfo.hStdInput = hPipeInRead
	stStartInfo.hStdOutput = hPipeOutWrite
	stStartInfo.hStdError = hPipeErrWrite
	stStartInfo.wShowWindow = 0
	stStartInfo.cb = SizeOf(stStartInfo)
	
	'https://docs.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-createprocessa
	rtn	 = CreateProcess(ByVal 0 , cmdStr , ByVal 0 , ByVal 0 , True , DETACHED_PROCESS , ByVal 0 , ByVal 0 , @stStartInfo , @stProcessInfo)
	If rtn Then
	Else
		rtnMsg = "4. CreateProcess(ByVal 0, cmdStr ,ByVal 0 ,ByVal 0 ,True ,CREATE_NO_WINDOW Or DETACHED_PROCESS ,ByVal 0 ,ByVal 0 ,@stStartInfo ,@stProcessInfo) FAILED!"
		Return rtn
	End If
	
	mThread = ThreadCreate(Cast(Any Ptr ,@ThreadPipeRead) ,@This)
	If mThread = NULL Then
		rtn = False
	Else
		rtnMsg = "5. mThread = ThreadCreate(Cast(Any Ptr ,@ThreadPipeRead) ,@This) FAILED!"
		rtn = True
	End If
	
	rtnMsg = "PipeProcess.Create PASSED!"
	Function = rtn
End Function

Function PipeProcess.PipeWrite(a As String) As Long
	Dim nWritten As Long
'	Dim a As String = aStr(cmd) '多字节Unicode字符串转换为单字节Ansi字符串
	WriteFile(hPipeInWrite, StrPtr(a), Len(a), @nWritten, NULL)
	Return nWritten
End Function

Sub PipeProcess.PipeRead()
	Dim nBufferLen As Long = 1024
	Dim nRead As Long = -1
	Dim dwAvail As Long
	Dim dwRead As Long
	Do
		Do
			If hPipeOutRead Then
				nRead = -1
				If (PeekNamedPipe(hPipeOutRead , 0, 0, @dwRead, @dwAvail, 0) = 0) Or (dwAvail <= 0) Then
				Else
					Dim by As Any Ptr = Allocate (nBufferLen ) '*SizeOf(UByte))
					If ReadFile(hPipeOutRead , by , nBufferLen , @nRead , NULL) Then
						If nRead > 0 Then If OnPipeRead Then OnPipeRead(mOwner, Left(*Cast(ZString Ptr , by), nRead), nRead)
					End If
					Deallocate(by)
				End If
			End If
			App.DoEvents()
		Loop While (nRead > 0)
		If stProcessInfo.hProcess Then
			If GetExitCodeProcess(stProcessInfo.hProcess ,@mErrorLevel) Then
				If mErrorLevel <> STILL_ACTIVE Then
					Exit Do
				End If
			End If
		End If
		App.DoEvents()
	Loop
End Sub

Function PipeProcess.PipeClosed() As WINBOOL
	If stProcessInfo.hProcess Then TerminateProcess stProcessInfo.hProcess, 256
	
	Do
		App.DoEvents()
	Loop While mThreadAlive
	
	If stProcessInfo.hThread Then CloseHandle stProcessInfo.hThread
	If stProcessInfo.hProcess Then CloseHandle stProcessInfo.hProcess
	If hPipeInRead Then CloseHandle hPipeInRead
	If hPipeInWrite Then CloseHandle hPipeInWrite
	If hPipeOutRead Then CloseHandle hPipeOutRead
	If hPipeOutWrite Then CloseHandle hPipeOutWrite
	If hPipeErrRead Then CloseHandle hPipeErrRead
	If hPipeErrWrite Then CloseHandle hPipeErrWrite
	
	hPipeInRead	= 0
	hPipeInWrite = 0
	hPipeOutRead = 0
	hPipeOutWrite = 0
	hPipeErrRead = 0
	hPipeErrWrite = 0
	stProcessInfo.hThread = 0
	stProcessInfo.hProcess = 0
	RtlZeroMemory(@stProcessInfo, SizeOf(stProcessInfo))
	RtlZeroMemory(@stStartInfo, SizeOf(stStartInfo))
	Return True
End Function
