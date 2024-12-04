' SerialPort 串口
' Copyright (c) 2022 CM.Wang
' Freeware. Use at your own risk.

#include once "SerialPort.bi"

Constructor SerialPort
	mHandle= NULL
	mCount = -1
End Constructor

Destructor SerialPort
	ArrayDeallocate(mName())
End Destructor

Private Property SerialPort.ComHandle() As HANDLE
	Return mHandle
End Property

Private Property SerialPort.Count() As Integer
	Return mCount
End Property

Private Property SerialPort.Name(Index As Integer) ByRef As WString
	Return *mName(Index)
End Property

Private Function SerialPort.Enumerate(ByVal PortMaxNumber As Long = 255) As Integer
	If PortMaxNumber < 1 Then Return -1
	
	Dim i As Integer
	Dim t As WString Ptr
	Dim nHand As HANDLE
	
	ArrayDeallocate(mName())
	mCount = -1
	
	Debug.Clear
	For i = 1 To PortMaxNumber
		WLet(t, "\\.\COM" & Format(i))
		nHand = CreateFile(t, GENERIC_WRITE Or GENERIC_READ, 0 , NULL, OPEN_EXISTING, FILE_FLAG_OVERLAPPED, @mOverlapped)
		If nHand = INVALID_HANDLE_VALUE Then
		Else
			mCount += 1
			ReDim Preserve mName(mCount)
			WLet(mName(mCount), *t)
		End If
		CloseHandle(nHand)
	Next
	Return mCount
End Function

Private Function SerialPort.Open(ByVal Index As Integer, ByVal Owner As Any Ptr) As HANDLE
	mHandle= CreateFile(mName(Index), GENERIC_READ Or GENERIC_WRITE, 0, NULL, OPEN_EXISTING, FILE_FLAG_OVERLAPPED, @mOverlapped)
	mIndex = Index
	mOwner = Owner
	mThread = ThreadCreate(Cast(Any Ptr, @ThreadProcedure), @This)
	Return mHandle
End Function

Private Function SerialPort.Close() As Boolean
	If mHandle Then CloseHandle(mHandle)
	mHandle= NULL
	Return True
End Function

Private Function SerialPort.ThreadProcedure(ByVal pParam As LPVOID) As DWORD
	Dim a As SerialPort Ptr = Cast(SerialPort Ptr, pParam)
	
	Dim recdata As ZString Ptr
	Dim recComState As COMSTAT
	Dim ErrorFlag As DWORD
	Dim lResult As Integer
	Dim lngSize As Integer
	Dim NumToRead As Integer
	Dim NumhaveRead As DWORD
	
	PurgeComm (a->mHandle, PURGE_RXCLEAR Or PURGE_TXCLEAR Or PURGE_RXABORT Or PURGE_TXABORT)
	While(a->mHandle)
		If ClearCommError(a->mHandle, @ErrorFlag, @recComState) <= 0 Then
		End If
		
		If recComState.cbInQue > 0 Then
			NumToRead = recComState.cbInQue
			If recdata Then Deallocate(recdata)
			recdata = CAllocate (NumToRead + 1)
			If ReadFile(a->mHandle, recdata, NumToRead, @NumhaveRead, @a->mOverlapped) Then
				If a->OndDtaArrive Then a->OndDtaArrive(a->mOwner, recdata, NumhaveRead)
			Else
			End If
		Else
		End If
	Wend
	Return 0
End Function

Private Function SerialPort.Write(ByVal WriteData As ZString Ptr, ByVal DataLength As Integer) As Integer
	Dim NumberWritten As DWORD   '用来记录写入的字节长度
	
	If WriteFile(mHandle, WriteData, DataLength, @NumberWritten, @mOverlapped) Then
		FlushFileBuffers(mHandle)
	Else
	End If
	Debug.Print DataLength & "," & *WriteData
	Return NumberWritten
End Function
