#pragma once
' FileAct 文件处理
' Copyright (c) 2022 CM.Wang
' Freeware. Use at your own risk.

#include once "FileAct.bi"

' https://www.freebasic.net/forum/viewtopic.php?t=29685
' https://en.wikipedia.org/wiki/SHA-1
' https://www.freebasic.net/forum/viewtopic.php?t=31389
' https://www.freebasic.net/forum/viewtopic.php?t=25849
' "The quick brown fox jumps over the lazy dog"
' MD5    = "9e107d9d372bb6826bd81d3542a419d6"
' SHA1   = "2fd4e1c67a2d28fced849ee1bb76e7391b93eb12"
' SHA256 = "d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592"
' SHA512 = "07e547d9586f6a73f73fbac0435ed76951218fb7d0c8d788a309d785436bbb642e93a252a954f23912547d1e8a3b5ed6e1bfd7097821233fa0538f3db854fee6"

Private Function AlgWStr(ByVal Algorithm As Long = 2) ByRef As WString
	Static pAlgId As WString Ptr
	Select Case Algorithm
	Case 0
		WStr2Ptr(WStr("MD2"), pAlgId)
	Case 1
		WStr2Ptr(WStr("MD4"), pAlgId)
	Case 2
		WStr2Ptr(WStr("MD5"), pAlgId)
	Case 3
		WStr2Ptr(WStr("SHA1"), pAlgId)
	Case 4
		WStr2Ptr(WStr("SHA256"), pAlgId)
	Case 5
		WStr2Ptr(WStr("SHA512"), pAlgId)
	End Select
	Return *pAlgId
End Function

Private Function GetHash(src As Any Ptr, nsize As Integer, ByVal Algorithm As Long = 2, ByVal bLCase As Boolean = False) As String
	Dim As Byte Ptr phalg, phhash
	Dim As ULong lhashlength, LRESULT, nlength
	Dim As String sbinhash, shex
	
	BCryptOpenAlgorithmProvider VarPtr(phalg), AlgWStr(Algorithm), 0, 0 ' we want phalg
	BCryptCreateHash phalg, @phhash, NULL, 0, 0, 0, 0 ' we want phhash
	BCryptHashData(phhash, src, nsize, 0 )
	BCryptGetProperty phalg, BCRYPT_HASH_LENGTH, Cast(PUCHAR, @lhashlength), 4, @LRESULT, 0
	sbinhash = String(lhashlength, 0)
	BCryptFinishHash phhash, StrPtr(sbinhash), lhashlength, 0
	BCryptDestroyHash phhash
	BCryptCloseAlgorithmProvider phalg, 0
	nlength = Len(sbinhash)*2 + 1 ' + 1 to accomodate a null terminator
	shex = Space(nlength)
	CryptBinaryToStringA StrPtr(sbinhash), Len(sbinhash), CRYPT_STRING_HEXRAW + CRYPT_STRING_NOCRLF, StrPtr(shex), @nlength
	
	If bLCase Then
		Return Left(shex, nlength)
	Else
		Return UCase(Left(shex, nlength))
	End If
End Function

Function GetFileData(ByRef FileName As Const WString, ByRef rtnData As Any Ptr) As Integer
	Dim h As Integer = FreeFile
	Dim fsize As Integer = 0
	
	If Open(FileName For Binary Access Read As #h) <> 0 Then Return fsize
	fsize= LOF(h)
	
	If fsize Then
		If rtnData Then
			rtnData = Reallocate(rtnData, fsize + 1)
		Else
			rtnData = CAllocate(fsize + 1)
		End If
		If Get(#h, , *Cast(UByte Ptr, rtnData), fsize) Then fsize = 0
	End If
	Close #h
	Return fsize
End Function

Function SetFileData(ByRef FileName As Const WString, sizeData As Integer, ByRef setData As Any Ptr) As Integer
	Dim h As Integer = FreeFile
	If Open(FileName For Binary Access Write As #h) <> 0 Then Return False
	If Put(#h, , *Cast(UByte Ptr, setData), sizeData) Then Return False
	Close #h
	Return True
End Function

Private Function Sec2Time(Sec As Single, hfmt As String = "#,#0", mfmt As String = "#00", sfmt As String = "#00") ByRef As String
	Dim h As Long
	Dim m As Long
	Dim s As Single
	Static r As String
	h = Sec \ 3600
	m = (Sec - h * 3600) \ 60
	s = Sec - h * 3600 - m * 60
	r = Format(h, hfmt) & ":" & Format(m, mfmt) & ":" & Format(s, sfmt)
	Return r
End Function

Private Function Number2Str(Num As Double, ifmt As String = "#,#0", sfmt As String = "#0.00") ByRef As String
	Dim dbb As Double
	Dim dba As Double
	Dim i As Long
	Dim u As String
	Static r As String
	
	dbb = Num
	
	Do
		dba = dbb / 1024
		If dba < 1 Then Exit Do
		i = i + 1
		dbb = dba
	Loop While True
	
	Select Case i
	Case 0
		u = " B"
	Case 1
		u = " KB"
	Case 2
		u = " MB"
	Case 3
		u = " GB"
	Case 4
		u = " TB"
	End Select
	If i Then
		r = Format(dbb, sfmt) & u
	Else
		r = Format(dbb, ifmt) & u
	End If
	Return r
End Function

Private Function WFD2Size(wfd As WIN32_FIND_DATA Ptr) As ULongInt
	Dim i As ULongInt = wfd->nFileSizeHigh
	Dim j As ULongInt = wfd->nFileSizeLow
	Dim k As ULongInt = i * (MAXDWORD + 1) + j
	Return k
End Function

Private Function WFD2TimeSerial(ftp As FILETIME Ptr) As Double
	Dim st As SYSTEMTIME
	Dim ft As FILETIME
	FileTimeToLocalFileTime(ftp, @ft)
	FileTimeToSystemTime(@ft, @st)
	Return DateSerial(st.wYear, st.wMonth, st.wDay) + TimeSerial(st.wHour, st.wMinute, st.wSecond)
End Function

Private Function WFD2TimeStr(ByVal ft As FILETIME, tf As WString = "yyyy/mm/dd hh:mm:ss") As String
	Dim st As SYSTEMTIME
	FileTimeToLocalFileTime(@ft, @ft)
	FileTimeToSystemTime(@ft, @st)
	Dim dt As Double = DateSerial(st.wYear, st.wMonth, st.wDay) + TimeSerial(st.wHour, st.wMinute, st.wSecond)
	Return Format(dt, tf)
End Function

Private Function WFD2TimeWStr(ByVal ft As FILETIME, ByRef tf As Const WString, ByRef RtnPtr As WString Ptr) As Integer
	Dim st As SYSTEMTIME
	FileTimeToLocalFileTime(@ft, @ft)
	FileTimeToSystemTime(@ft, @st)
	Dim dt As Double = DateSerial(st.wYear, st.wMonth, st.wDay) + TimeSerial(st.wHour, st.wMinute, st.wSecond)
	WStr2Ptr(Format(dt, tf), RtnPtr)
	Return Len(*RtnPtr)
End Function

Private Function WFDCompare(ByVal swfd As WIN32_FIND_DATA Ptr, ByVal twfd As WIN32_FIND_DATA Ptr, ByVal cData As Long = 0, ByVal cMode As Long = 0) As Long
	Dim st As Double
	Dim tt As Double
	Dim suli As ULongInt
	Dim tuli As ULongInt
	
	Select Case cData
	Case 0 'size
		suli = WFD2Size(swfd)
		tuli = WFD2Size(twfd)
	Case 1 'lastwritetime
		st = WFD2TimeSerial(@swfd->ftLastWriteTime)
		tt = WFD2TimeSerial(@twfd->ftLastWriteTime)
	Case 2 'creationtime
		st = WFD2TimeSerial(@swfd->ftCreationTime)
		tt = WFD2TimeSerial(@twfd->ftCreationTime)
	Case 3 'lastaccesstime
		st = WFD2TimeSerial(@swfd->ftLastAccessTime)
		tt = WFD2TimeSerial(@twfd->ftLastAccessTime)
	End Select
	
	Select Case cData
	Case 0
		Select Case cMode
		Case 0 '>
			If suli > tuli Then
				Return True
			Else
				Return False
			End If
		Case 1 '<
			If suli < tuli Then
				Return True
			Else
				Return False
			End If
		Case 2 '<>
			If suli <> tuli Then
				Return True
			Else
				Return False
			End If
		Case 3 '=
			If suli = tuli Then
				Return True
			Else
				Return False
			End If
		End Select
	Case Else
		Select Case cMode
		Case 0 '>
			If st > tt Then
				Return True
			Else
				Return False
			End If
		Case 1 '<
			If st < tt Then
				Return True
			Else
				Return False
			End If
		Case 2 '<>
			If st <> tt Then
				Return True
			Else
				Return False
			End If
		Case 3 '=
			If st = tt Then
				Return True
			Else
				Return False
			End If
		End Select
	End Select
	Return True
End Function

Private Function WFDGet Overload (FileName As Const WString, ByRef wfd As WIN32_FIND_DATA Ptr) As Integer
	Dim hFind As HANDLE = FindFirstFile(FileName, wfd)
	If hFind = INVALID_HANDLE_VALUE Then
		hFind = FindFirstFile(FileName & "\?", wfd)
		If hFind = INVALID_HANDLE_VALUE Then Return False
	End If
	FindClose(hFind)
	Return True
End Function

Private Function WFDGet Overload (FileName As WString Ptr, ByRef wfd As WIN32_FIND_DATA Ptr) As Integer
	Dim hFind As HANDLE = FindFirstFile(*FileName, wfd)
	If hFind = INVALID_HANDLE_VALUE Then
		hFind = FindFirstFile(*FileName & "\?", wfd)
		If hFind = INVALID_HANDLE_VALUE Then Return False
	End If
	FindClose(hFind)
	Return True
End Function

'Private Function FileExist(PathStr As WString Ptr) As Long
'	Dim wfd As WIN32_FIND_DATA
'	Dim hFind As HANDLE = FindFirstFile(*PathStr, @wfd)
'	If hFind = INVALID_HANDLE_VALUE Then
'		hFind = FindFirstFile(*PathStr & "\?", @wfd)
'		If hFind = INVALID_HANDLE_VALUE Then Return False
'	End If
'	FindClose(hFind)
'	'If wfd.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY Then
'	'	Return 2
'	'Else
'	'	Return 1
'	'End If
'	'PathFileExists
'	Return True
'End Function

Destructor FilesFind
	Clear(True)
End Destructor

Private Function FilesFind.Paths(ByRef SplitStr As Const WString) ByRef As WString
	If mPathCount < 0 Then
	Else
		JoinWStr(mPaths(), SplitStr, mTmpPaths)
		Return *mTmpPaths
	End If
End Function

Private Function FilesFind.Files(ByRef SplitStr As Const WString) ByRef As WString
	If mFileCount < 0 Then
	Else
		JoinWStr(mFiles(), SplitStr, mTmpFiles)
		Return *mTmpFiles
	End If
End Function

Private Sub FilesFind.ListFile(ByRef pathroot As Const WString, ByVal FilterIndex As Integer)
	Dim wfd As WIN32_FIND_DATA
	Dim hFind As HANDLE
	Dim hNext As WINBOOL
	Dim tIndex As Long
	
	If mCancel Then Exit Sub
	
	hFind = FindFirstFile(pathroot & "\" & *mFilter(FilterIndex) , @wfd)
	If hFind <> INVALID_HANDLE_VALUE Then
		Do
			If wfd.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY Then
			Else
				tIndex = mFileCount + 1
				If ((tIndex Mod mFileInc) = 0) Or (tIndex = 0) Then
					ReDim Preserve mFiles(mFileCount + mFileInc)
				EndIf
				WStr2Ptr(pathroot & "\" & wfd.cFileName, mFiles(tIndex))
				mFileSize += WFD2Size(@wfd)
				mFileCount += 1
			End If
			If mCancel Then Exit Do
			hNext = FindNextFile(hFind , @wfd)
		Loop While (hNext)
		FindClose(hFind)
	End If
	
	If mCancel Then Exit Sub
	
	hFind = FindFirstFile(pathroot & "\*.*" , @wfd)
	If hFind = INVALID_HANDLE_VALUE Then Exit Sub
	Do
		If wfd.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY Then
			If wfd.cFileName <> "." And wfd.cFileName <> ".." Then
				If mSubDir Then ListFile(pathroot & "\" & wfd.cFileName, FilterIndex)
			End If
		End If
		If mCancel Then Exit Do
		hNext = FindNextFile(hFind , @wfd)
	Loop While (hNext)
	FindClose(hFind)
End Sub

Private Sub FilesFind.ListPath(ByRef pathroot As Const WString, ByVal FilterIndex As Integer)
	Dim wfd As WIN32_FIND_DATA
	Dim hFind As HANDLE
	Dim hNext As WINBOOL
	Dim tIndex As Long
	
	If mCancel Then Exit Sub
	
	hFind = FindFirstFile(pathroot & "\" & *mFilter(FilterIndex) , @wfd)
	If hFind <> INVALID_HANDLE_VALUE Then
		Do
			If wfd.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY Then
				If wfd.cFileName <> "." And wfd.cFileName <> ".." Then
					tIndex = mPathCount + 1
					If ((tIndex Mod mFileInc) = 0) Or (tIndex = 0) Then
						ReDim Preserve mPaths(mPathCount + mFileInc)
					EndIf
					WStr2Ptr(pathroot & "\" & wfd.cFileName, mPaths(tIndex))
					mPathCount += 1
				End If
			End If
			If mCancel Then Exit Do
			hNext = FindNextFile(hFind , @wfd)
		Loop While (hNext)
		FindClose(hFind)
	End If
	
	If mCancel Then Exit Sub
	
	hFind = FindFirstFile(pathroot & "\*.*" , @wfd)
	If hFind = INVALID_HANDLE_VALUE Then Exit Sub
	Do
		If wfd.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY Then
			If wfd.cFileName <> "." And wfd.cFileName <> ".." Then
				If mSubDir Then ListPath(pathroot & "\" & wfd.cFileName, FilterIndex)
			End If
		End If
		If mCancel Then Exit Do
		hNext = FindNextFile(hFind , @wfd)
	Loop While (hNext)
	FindClose(hFind)
End Sub

Private Sub FilesFind.ListFilePath(ByRef pathroot As Const WString, ByVal FilterIndex As Integer)
	Dim wfd As WIN32_FIND_DATA
	Dim hFind As HANDLE
	Dim hNext As WINBOOL
	Dim tIndex As Long
	
	If mCancel Then Exit Sub
	
	hFind = FindFirstFile(pathroot & "\" & *mFilter(FilterIndex) , @wfd)
	If hFind <> INVALID_HANDLE_VALUE Then
		Do
			If wfd.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY Then
				If wfd.cFileName <> "." And wfd.cFileName <> ".." Then
					tIndex = mPathCount + 1
					If ((tIndex Mod mFileInc) = 0) Or (tIndex = 0) Then
						ReDim Preserve mPaths(mPathCount + mFileInc)
					EndIf
					WStr2Ptr(pathroot & "\" & wfd.cFileName, mPaths(tIndex))
					mPathCount += 1
				End If
			Else
				tIndex = mFileCount + 1
				If ((tIndex Mod mFileInc) = 0) Or (tIndex = 0) Then
					ReDim Preserve mFiles(mFileCount + mFileInc)
				EndIf
				WStr2Ptr(pathroot & "\" & wfd.cFileName, mFiles(tIndex))
				mFileSize += WFD2Size(@wfd)
				mFileCount += 1
			End If
			If mCancel Then Exit Do
			hNext = FindNextFile(hFind , @wfd)
		Loop While (hNext)
		FindClose(hFind)
	End If
	
	If mCancel Then Exit Sub
	
	hFind = FindFirstFile(pathroot & "\*.*" , @wfd)
	If hFind = INVALID_HANDLE_VALUE Then Exit Sub
	Do
		If wfd.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY Then
			If wfd.cFileName <> "." And wfd.cFileName <> ".." Then
				If mSubDir Then ListFilePath(pathroot & "\" & wfd.cFileName, FilterIndex)
			End If
		End If
		If mCancel Then Exit Do
		hNext = FindNextFile(hFind , @wfd)
	Loop While (hNext)
	FindClose(hFind)
End Sub

Private Function FilesFind.ThreadProcedure(ByVal pParam As LPVOID) As DWORD
	Dim cFF As FilesFind Ptr = Cast(FilesFind Ptr , pParam) '将空指针转换成类指针
	cFF->ThreadDoing()
	Return 0
End Function

Private Function FilesFind.FindFile(Owner As Any Ptr, ByRef rootpaths As Const WString, ByRef filters As Const WString, ByVal subDir As Integer = False, ByVal FindType As Integer = 0) As Integer
	mOwner = Owner
	mFindType = FindType
	WStr2Ptr (rootpaths, mRootPaths)
	WStr2Ptr (filters, mFilters)
	mSubDir = subDir
	mThread = ThreadCreate(Cast(Any Ptr , @ThreadProcedure) , @This)
	If mThread = NULL Then
		Return False
	Else
		Return True
	End If
End Function

Private Sub FilesFind.ThreadDoing()
	Clear(False)
	mRootPathCount = SplitWStr (*mRootPaths, ";", mRootPath())
	mFilterCount = SplitWStr (*mFilters, ";", mFilter())
	
	Dim i As Integer
	Dim j As Integer
	Select Case mFindType
	Case 0 'file
		For i = 0 To mRootPathCount
			For j = 0 To mFilterCount
				ListFile(*mRootPath(i), j)
			Next
		Next
	Case 1 'path
		For i = 0 To mRootPathCount
			For j = 0 To mFilterCount
				ListPath(*mRootPath(i), j)
			Next
		Next
	Case Else 'both
		For i = 0 To mRootPathCount
			For j = 0 To mFilterCount
				ListFilePath(*mRootPath(i), j)
			Next
		Next
	End Select
	
	If mFileCount < 0 Then Erase mFiles Else ReDim Preserve mFiles(mFileCount)
	If mPathCount < 0 Then Erase mPaths Else ReDim Preserve mPaths(mPathCount)
	mDone = True
	If OnFindDone Then OnFindDone(mOwner, mPathCount, mFileCount, mFileSize)
End Sub

Private Sub FilesFind.Clear(ByVal Index As Integer = False)
	Dim i As Integer
	For i = 0 To mPathCount
		If mPaths(i) Then Deallocate(mPaths(i))
	Next
	Erase mPaths
	For i = 0 To mFileCount
		If mFiles(i) Then Deallocate(mFiles(i))
	Next
	Erase mFiles
	
	If mTmpFiles Then Deallocate(mTmpFiles)
	mTmpFiles = 0
	If mTmpPaths Then Deallocate(mTmpPaths)
	mTmpPaths = 0
	
	mFileCount = -1
	mPathCount = -1
	mFileSize = 0
	mDone = False
	mCancel = False
	
	If Index = False Then Exit Sub
	
	If mRootPaths Then Deallocate(mRootPaths)
	mRootPaths = 0
	If mFilters Then Deallocate(mFilters)
	mFilters = 0
End Sub

Private Property FilesFind.FileCount() As Integer
	Return mFileCount
End Property

Private Property FilesFind.PathCount() As Integer
	Return mPathCount
End Property

Private Property FilesFind.FileSize() As LongInt
	Return mFileSize
End Property

Private Property FilesFind.File(Index As Integer) ByRef As WString
	If mFileCount < 0 Then Return ""
	If mFileCount < Index Then Return ""
	Return *mFiles(Index)
End Property

Private Property FilesFind.Path(Index As Integer) ByRef As WString
	If mPathCount < 0 Then Return ""
	If mPathCount < Index Then Return ""
	Return *mPaths(Index)
End Property

Private Property FilesFind.Cancel() As Integer
	Return mCancel
End Property

Private Property FilesFind.Cancel(ByVal nVal As Integer)
	mCancel = True
End Property

Private Property FilesFind.Done() As Integer
	Return mDone
End Property

Private Function FilesSync.Remove(Owner As Any Ptr, PathStr As WString) As Integer
	mOwner = Owner
	WStr2Ptr(PathStr , mPathA)
	mThreadMode = FilesSyncMode.FSM_PathRemove
	
	mSyncThread = ThreadCreate(Cast(Any Ptr, @SyncThread), @This)
	If mSyncThread = NULL Then
		Return False
	Else
		Return True
	End If
End Function

Private Function FilesSync.Create(Owner As Any Ptr, PathStr As WString) As Integer
	mOwner = Owner
	WStr2Ptr(PathStr , mPathA)
	mThreadMode = FilesSyncMode.FSM_PathCreate
	
	mSyncThread = ThreadCreate(Cast(Any Ptr, @SyncThread), @This)
	If mSyncThread = NULL Then
		Return False
	Else
		Return True
	End If
End Function

Private Function FilesSync.Sync(Owner As Any Ptr, SourceStr As WString, TargetStr As WString) As Integer ', ByVal cData As Long = 0, ByVal cMode As Long = 0) As Integer
	mOwner = Owner
	WStr2Ptr(SourceStr, mPathA)
	WStr2Ptr(TargetStr, mPathB)
	mThreadMode = FilesSyncMode.FSM_PathSync
	
	mSyncThread = ThreadCreate(Cast(Any Ptr, @SyncThread), @This)
	If mSyncThread = NULL Then
		Return False
	Else
		Return True
	End If
End Function

Private Sub FilesSync.SyncDoing()
	SyncInit()
	
	Select Case mThreadMode
	Case FilesSyncMode.FSM_PathCreate
		StepInit(1, "Path Create")
		PathCreate(mPathA)
	Case FilesSyncMode.FSM_PathRemove
		StepInit(1, "Path Remove")
		PathRemove(mPathA)
	Case FilesSyncMode.FSM_PathSync
		PathSync()
	End Select
	
	If mLogMode = 1 Then
		If mFileCopyCount >-1 Then ReDim Preserve mFileCopy(mFileCopyCount)
		If mFileOverwriteCount >-1 Then ReDim Preserve mFileOverwrite(mFileOverwriteCount)
		If mFileSkipCount >-1 Then ReDim Preserve mFileSkip(mFileSkipCount)
		If mFileDeleteCount >-1 Then ReDim Preserve mFileDelete(mFileDeleteCount)
		If mFileDeleteBNotInACount >-1 Then ReDim Preserve mFileDeleteBNotInA(mFileDeleteBNotInACount)
		If mPathCreateCount >-1 Then ReDim Preserve mPathCreate(mPathCreateCount)
		If mPathRemoveCount >-1 Then ReDim Preserve mPathRemove(mPathRemoveCount)
		If mPathRemoveBNotInACount >-1 Then ReDim Preserve mPathRemoveBNotInA(mPathRemoveBNotInACount)
		If mErrorMessageCount >-1 Then ReDim Preserve mErrorMessage(mErrorMessageCount )
	End If
	
	Done = True
End Sub

Private Function FilesSync.SyncThread(ByVal pParam As LPVOID) As DWORD
	Dim cFS As FilesSync Ptr = Cast(FilesSync Ptr , pParam)
	cFS->SyncDoing()
	Return 0
End Function

Private Function FilesSync.PercentThread(ByVal pParam As LPVOID) As DWORD
	Dim cFS As FilesSync Ptr = Cast(FilesSync Ptr , pParam)
	
	cFS->PercentDoing(cFS->mPercentPath)
	
	Return 0
End Function

Private Constructor FilesSync
	SyncInit()
End Constructor

Private Destructor FilesSync
	mLogMode= 0
	SyncInit()
	
	If mPathA Then Deallocate(mPathA)
	If mPathB Then Deallocate(mPathB)
	If mSyncSource Then Deallocate(mSyncSource)
	If mSyncTarget Then Deallocate(mSyncTarget)
	If mPercentPath Then Deallocate(mPercentPath)
	If mLogFile Then Deallocate(mLogFile)
	If WStrTmpPtr Then Deallocate(WStrTmpPtr)
End Destructor

Private Sub FilesSync.SyncInit()
	Erase mStepTime
	
	ArrayDeallocate(mFileCopy())
	ArrayDeallocate(mFileOverwrite())
	ArrayDeallocate(mFileSkip())
	ArrayDeallocate(mFileDelete())
	ArrayDeallocate(mFileDeleteBNotInA())
	ArrayDeallocate(mPathCreate())
	ArrayDeallocate(mPathRemove())
	ArrayDeallocate(mPathRemoveBNotInA())
	ArrayDeallocate(mErrorMessage())
	ArrayDeallocate(mStepMessage())
	
	mCopyTime= 0
	mDeleteTime= 0
	
	mPercentReady = False
	mPercentCount = 0
	mPercentStep = 0
	
	mPathCreateCount = -1
	mFileCopyCount = -1
	mFileCopySize = 0
	
	mFileDeleteSize = 0
	mFileDeleteCount = -1
	mPathRemoveCount = -1
	mFileDeleteBNotInASize = 0
	mFileDeleteBNotInACount = -1
	mPathRemoveBNotInACount = -1
	
	mFileOverwriteSize = 0
	mFileOverwriteCount = -1
	
	mFileSkipCount = -1
	mFileSkipSize= 0
	
	mErrorMessageCount = -1
	
	mCancel = False
	mDone= False
	
	If mLogMode= 2 Then LogFileOpen()
End Sub

Private Sub FilesSync.StepInit(StepCount As LongInt, StepMsg As Const WString)
	ArrayDeallocate(mStepMessage())
	ReDim mStepMessage(StepCount)
	ReDim mStepTime(StepCount)
	
	mStepCount = StepCount
	mStepDoing = 0
	WStr2Ptr(StepMsg, mStepMessage(mStepDoing))
	mStepTimeAdd=0
	mTiMr.Start
End Sub

Private Property FilesSync.TimePass() As Double
	If mDone Or mCancel Then
		Return mStepTime(mStepDoing)
	Else
		If mStepCount < 0 Then
			Return 0
		Else
			Return mTiMr.Passed
		End If
	End If
End Property

Private Sub FilesSync.StepInc(StepMsg As Const WString)
	Dim t As Double
	
	t = mTiMr.Passed
	mStepTime(mStepDoing) = t - mStepTimeAdd
	mStepTimeAdd = t
	mStepDoing += 1
	WStr2Ptr(StepMsg, mStepMessage(mStepDoing))
	If mStepDoing = mStepCount Then mStepTime(mStepDoing) = t
End Sub

Private Sub FilesSync.ErrorInc(ErrorTitle As WString, ErrorMsg As WString Ptr)
	Dim tIndex As LongInt
	Select Case mLogMode
	Case 1
		tIndex = mErrorMessageCount + 1
		If ((tIndex Mod mFileInc) = 0) Or (tIndex = 0) Then
			ReDim Preserve mErrorMessage(mErrorMessageCount + mFileInc)
		EndIf
		WStr2Ptr("Error: " & ErrorTitle & *ErrorMsg, mErrorMessage(tIndex))
	Case 2
		LogFile("Error: " & ErrorTitle & vbTab & *ErrorMsg)
	End Select
	mErrorMessageCount += 1
End Sub

Private Sub FilesSync.CountInc(CntIdx As PathFileCountEnum, IncMsg As WString Ptr)
	Dim tIndex As LongInt
	Select Case mLogMode
	Case 1
		Select Case CntIdx
		Case Count_FileCopy
			tIndex = mFileCopyCount + 1
			If ((tIndex Mod mFileInc) = 0) Or (tIndex = 0) Then
				ReDim Preserve mFileCopy(mFileCopyCount + mFileInc)
			EndIf
			WStr2Ptr(IncMsg, mFileCopy(tIndex))
		Case Count_FileOverwrite
			tIndex = mFileOverwriteCount + 1
			If ((tIndex Mod mFileInc) = 0) Or (tIndex = 0) Then
				ReDim Preserve mFileOverwrite(mFileOverwriteCount + mFileInc)
			EndIf
			WStr2Ptr(IncMsg, mFileOverwrite(tIndex))
		Case Count_FileSkip
			tIndex = mFileSkipCount + 1
			If ((tIndex Mod mFileInc) = 0) Or (tIndex = 0) Then
				ReDim Preserve mFileSkip(mFileSkipCount + mFileInc)
			EndIf
			WStr2Ptr(IncMsg, mFileSkip(tIndex))
		Case Count_FileDelete
			tIndex = mFileDeleteCount + 1
			If ((tIndex Mod mFileInc) = 0) Or (tIndex = 0) Then
				ReDim Preserve mFileDelete(mFileDeleteCount + mFileInc)
			EndIf
			WStr2Ptr(IncMsg, mFileDelete(tIndex))
		Case Count_PathCreate
			tIndex = mPathCreateCount + 1
			If ((tIndex Mod mFileInc) = 0) Or (tIndex = 0) Then
				ReDim Preserve mPathCreate(mPathCreateCount + mFileInc)
			EndIf
			WStr2Ptr(IncMsg, mPathCreate(tIndex))
		Case Count_PathRemove
			tIndex = mPathRemoveCount + 1
			If ((tIndex Mod mFileInc) = 0) Or (tIndex = 0) Then
				ReDim Preserve mPathRemove(mPathRemoveCount + mFileInc)
			EndIf
			WStr2Ptr(IncMsg, mPathRemove(tIndex))
		Case Count_PathRemoveBNotInA
			tIndex = mPathRemoveBNotInACount + 1
			If ((tIndex Mod mFileInc) = 0) Or (tIndex = 0) Then
				ReDim Preserve mPathRemoveBNotInA(mPathRemoveBNotInACount + mFileInc)
			EndIf
			WStr2Ptr(IncMsg, mPathRemoveBNotInA(tIndex))
		Case Count_FileDeleteBNotInA
			tIndex = mFileDeleteBNotInACount + 1
			If ((tIndex Mod mFileInc) = 0) Or (tIndex = 0) Then
				ReDim Preserve mFileDeleteBNotInA(mFileDeleteBNotInACount + mFileInc)
			EndIf
			WStr2Ptr(IncMsg, mFileDeleteBNotInA(tIndex))
		End Select
	Case 2
		LogFile(LogStr(CntIdx ) & *IncMsg)
	End Select
	Select Case CntIdx
	Case Count_FileCopy
		mFileCopyCount += 1
	Case Count_FileOverwrite
		mFileOverwriteCount += 1
	Case Count_FileSkip
		mFileSkipCount += 1
	Case Count_FileDelete
		mFileDeleteCount += 1
	Case Count_PathCreate
		mPathCreateCount += 1
	Case Count_PathRemove
		mPathRemoveCount += 1
	Case Count_PathRemoveBNotInA
		mPathRemoveBNotInACount += 1
	Case Count_FileDeleteBNotInA
		mFileDeleteBNotInACount += 1
	End Select
End Sub

Private Function FilesSync.LogStr(Index As Long) ByRef As WString
	Select Case Index
	Case Count_FileCopy
		WStr2Ptr("FileCopy: " & Index & vbTab, WStrTmpPtr)
	Case Count_FileOverwrite
		WStr2Ptr("FileOverwrite: " & Index & vbTab, WStrTmpPtr)
	Case Count_FileSkip
		WStr2Ptr("FileSkip: " & Index & vbTab, WStrTmpPtr)
	Case Count_FileDelete
		WStr2Ptr("FileDelete: " & Index & vbTab, WStrTmpPtr)
	Case Count_PathCreate
		WStr2Ptr("PathCreate: " & Index & vbTab, WStrTmpPtr)
	Case Count_PathRemove
		WStr2Ptr("PathRemove: " & Index & vbTab, WStrTmpPtr)
	Case Count_PathRemoveBNotInA
		WStr2Ptr("PathRemoveBNotInA: " & Index & vbTab, WStrTmpPtr)
	Case Count_FileDeleteBNotInA
		WStr2Ptr("FileDeleteBNotInA: " & Index & vbTab, WStrTmpPtr)
	End Select
	
	Return *WStrTmpPtr
End Function

Private Sub FilesSync.ActFile(aType As PathFileActEnum, SourceStr As WString Ptr, TargetStr As WString Ptr, wfd As WIN32_FIND_DATA Ptr)
	'https://docs.microsoft.com/zh-cn/windows/win32/api/winbase/nf-winbase-copyfile
	Dim st As Double = mTiMr.Passed
	Select Case aType
	Case Act_FileOverwrite
		SetFileAttributes(*SourceStr, FILE_ATTRIBUTE_NORMAL)
		If CopyFile(*SourceStr, *TargetStr, False) Then
			CountInc(Count_FileOverwrite, TargetStr)
			mFileOverwriteSize += WFD2Size(wfd)
			mCopyTime+= mTiMr.Passed - st
		Else
			ErrorInc("Act_FileOverwrite: ", TargetStr)
		End If
	Case Act_FileCopy
		If CopyFile(*SourceStr, *TargetStr, False) Then
			CountInc(Count_FileCopy, SourceStr)
			mFileCopySize += WFD2Size(wfd)
			mCopyTime+= mTiMr.Passed - st
		Else
			ErrorInc("Act_FileCopy: ", SourceStr)
		End If
	Case Act_FileDelete
		SetFileAttributes(*SourceStr, FILE_ATTRIBUTE_NORMAL)
		If DeleteFile(*SourceStr) Then
			CountInc(Count_FileDelete, SourceStr)
			mFileDeleteSize += WFD2Size(wfd)
			mDeleteTime+= mTiMr.Passed - st
		Else
			ErrorInc("Act_FileDelete: ", SourceStr)
		End If
	Case Act_FileDeleteBNotInA
		SetFileAttributes(*SourceStr, FILE_ATTRIBUTE_NORMAL)
		If DeleteFile(*SourceStr) Then
			CountInc(Count_FileDeleteBNotInA, SourceStr)
			mFileDeleteBNotInASize += WFD2Size(wfd)
			mDeleteTime+= mTiMr.Passed - st
		Else
			ErrorInc("Act_FileDeleteBNotInA: ", SourceStr)
		End If
	End Select
End Sub

Private Function FilesSync.ActPath(aType As PathFileActEnum, SourceStr As WString Ptr) As Long
	Dim st As Double = mTiMr.Passed
	Select Case aType
	Case Act_PathCreate
		Dim n As SECURITY_ATTRIBUTES
		If CreateDirectory(*SourceStr, @n) Then
			CountInc(Count_PathCreate, SourceStr)
			mCopyTime+= mTiMr.Passed - st
			Return True
		Else
			ErrorInc("Act_PathCreate: ", SourceStr)
		End If
	Case Act_PathRemove
		If RemoveDirectory(*SourceStr) Then
			CountInc(Count_PathRemove, SourceStr)
			mDeleteTime+= mTiMr.Passed - st
			Return True
		Else
			ErrorInc("Act_PathRemove: ", SourceStr)
		End If
	Case Act_PathRemoveBNotInA
		If RemoveDirectory(*SourceStr) Then
			CountInc(Count_PathRemoveBNotInA, SourceStr)
			mDeleteTime+= mTiMr.Passed - st
			Return True
		Else
			ErrorInc("Act_PathRemoveBNotInA: ", SourceStr)
		End If
	End Select
	Return False
End Function

Private Sub FilesSync.PathCreate(PathStr As WString Ptr)
	If PathFileExists(PathStr) Then Return
	
	Dim i As Long
	Dim j As Long
	Dim k As Long = 0
	Dim l As Long = Len("\")
	Dim dirs() As WString Ptr
	Dim t As WString Ptr
	ReDim Preserve dirs(k)
	WStr2Ptr(PathStr, dirs(k))
	
	j = -1
	Do
		i = InStrRev(*PathStr, "\", j)
		If i Then
			j = i - l
			If j Then
				WStr2Ptr(Left(*PathStr, j), t)
				
				If Right(*t, 1) = ":" Then Exit Do
				If Right(*t, 1) = "\" Then
					k -= 1
					Exit Do
				End If
				If PathFileExists(t) Then Exit Do
				k = k + 1
				ReDim Preserve dirs(k)
				WStr2Ptr(*t, dirs(k))
			Else
			End If
		End If
	Loop While i
	For i = k To 0 Step -1
		If ActPath(Act_PathCreate, dirs(i)) = False Then
			mCancel = True
			Exit For
		End If
	Next
	ArrayDeallocate(dirs())
	If t Then Deallocate(t)
End Sub

Private Sub FilesSync.FileCopyAct(PathStr As WString Ptr, wfd As WIN32_FIND_DATA Ptr)
	Dim twfd As WIN32_FIND_DATA
	Dim i As Integer
	
	If WFDGet(*mSyncTarget + *PathStr, @twfd) Then
		If WFDCompare(wfd, @twfd, mCompareData, mCompareMode) Then
			ActFile(Act_FileOverwrite, *mSyncSource & *PathStr, *mSyncTarget & *PathStr, wfd)
		Else
			CountInc(Count_FileSkip, *mSyncTarget + *PathStr)
			mFileSkipSize += WFD2Size(wfd)
		End If
	Else
		i = InStrRev(*PathStr, "\")
		If i Then PathCreate(*mSyncTarget + Left(*PathStr, i - 1))
		ActFile(Act_FileCopy, *mSyncSource & *PathStr, *mSyncTarget & *PathStr, wfd)
	End If
End Sub

Private Sub FilesSync.DeleteBNotInA(PathStr As Const WString)
	Dim wfd As WIN32_FIND_DATA
	Dim hFind As HANDLE
	Dim hNext As WINBOOL
	
	If mCancel Then Exit Sub
	
	hFind = FindFirstFile(*mSyncTarget + PathStr + "\*.*", @wfd)
	If hFind = INVALID_HANDLE_VALUE Then Exit Sub
	Do
		If wfd.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY Then
			If wfd.cFileName <> "." And wfd.cFileName <> ".." Then
				DeleteBNotInA(PathStr + "\" + wfd.cFileName)
			End If
		Else
			If PathFileExists(*mSyncSource + PathStr + "\" + wfd.cFileName) = False Then
				ActFile(Act_FileDeleteBNotInA, *mSyncTarget + PathStr + "\" + wfd.cFileName, NULL, @wfd)
			End If
			mPercentStep += 1
		End If
		If mCancel Then Exit Do
		hNext = FindNextFile(hFind , @wfd)
	Loop While (hNext)
	FindClose(hFind)
	
	If mCancel Then Exit Sub
	
	If PathFileExists(*mSyncSource + PathStr) = False Then
		ActPath(Act_PathRemoveBNotInA, *mSyncTarget + PathStr)
	End If
End Sub

Private Sub FilesSync.PercentSub(PathStr As WString)
	Dim wfd As WIN32_FIND_DATA
	Dim hFind As HANDLE
	Dim hNext As WINBOOL
	
	If mCancel Or mDone Then Exit Sub
	
	hFind = FindFirstFile(PathStr & "\*.*" , @wfd)
	If hFind = INVALID_HANDLE_VALUE Then Exit Sub
	Do
		If wfd.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY Then
			If wfd.cFileName <> "." And wfd.cFileName <> ".." Then
				PercentSub(PathStr & "\" & wfd.cFileName)
			End If
		Else
			mPercentCount += 1
		End If
		If mCancel Or mDone Then Exit Do
		hNext = FindNextFile(hFind , @wfd)
	Loop While (hNext)
	FindClose(hFind)
End Sub

Private Sub FilesSync.PercentDoing(PathStr As WString Ptr)
	If PathFileExists(PathStr) Then
		mPercentReady = False
		mPercentCount = 0
		mPercentStep = 0
		PercentSub(*PathStr)
	End If
	mPercentReady = True
End Sub

Private Sub FilesSync.ListFile()
	mListFileCount = -1
	mListPathCount = -1
	ArrayDeallocate(mListFile())
	ArrayDeallocate(mListPath())
	Erase mListWFD
	
	ListFileSub("")
	
	If mListFileCount >-1 Then
		ReDim Preserve mListFile(mListFileCount)
		ReDim Preserve mListWFD(mListFileCount)
	End If
	If mListPathCount >-1 Then ReDim Preserve mListPath(mListPathCount)
End Sub

Private Sub FilesSync.ListFileSub(PathStr As WString)
	Dim wfd As WIN32_FIND_DATA
	Dim hFind As HANDLE
	Dim hNext As WINBOOL
	Dim tIndex As LongInt
	
	If mCancel Then Exit Sub
	
	hFind = FindFirstFile(*mSyncSource + PathStr & "\*.*" , @wfd)
	If hFind = INVALID_HANDLE_VALUE Then Exit Sub
	Do
		If wfd.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY Then
			If wfd.cFileName <> "." And wfd.cFileName <> ".." Then
				ListFileSub(PathStr + "\" + wfd.cFileName)
				tIndex = mListPathCount + 1
				If ((tIndex Mod mFileInc) = 0) Or (tIndex = 0) Then
					ReDim Preserve mListPath(mListPathCount + mFileInc)
				EndIf
				WStr2Ptr(PathStr + "\" + wfd.cFileName, mListPath(tIndex))
				mListPathCount = tIndex
			End If
		Else
			tIndex = mListFileCount + 1
			If ((tIndex Mod mFileInc) = 0) Or (tIndex = 0) Then
				ReDim Preserve mListFile(mListFileCount + mFileInc)
				ReDim Preserve mListWFD(mListFileCount + mFileInc)
			EndIf
			WStr2Ptr(PathStr + "\" + wfd.cFileName, mListFile(tIndex))
			memcpy(@mListWFD(tIndex), @wfd, SizeOf(wfd))
			mListFileCount = tIndex
		End If
		If mCancel Then Exit Do
		hNext = FindNextFile(hFind , @wfd)
	Loop While (hNext)
	FindClose(hFind)
	If mCancel Then Exit Sub
	
	'	ListFileSub(PathStr + "\" + wfd.cFileName)
	'
	'	tIndex = mListPathCount + 1
	'	If ((tIndex Mod mFileInc) = 0) Or (tIndex = 0) Then
	'		ReDim Preserve mListPath(mListPathCount + mFileInc)
	'	EndIf
	'	WStr2Ptr(PathStr + "\" + wfd.cFileName, mListPath(tIndex))
	'	mListPathCount = tIndex
End Sub

Private Sub FilesSync.PathSyncSub(PathStr As Const WString)
	Dim wfd As WIN32_FIND_DATA
	Dim hFind As HANDLE
	Dim hNext As WINBOOL
	
	If mCancel Then Exit Sub
	
	hFind = FindFirstFile(*mSyncSource + PathStr & "\*.*" , @wfd)
	If hFind = INVALID_HANDLE_VALUE Then Exit Sub
	Do
		If wfd.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY Then
			If wfd.cFileName <> "." And wfd.cFileName <> ".." Then
				PathSyncSub(PathStr + "\" + wfd.cFileName)
			End If
		Else
			FileCopyAct(PathStr + "\" + wfd.cFileName, @wfd)
			mPercentStep += 1
		End If
		If mCancel Then Exit Do
		hNext = FindNextFile(hFind , @wfd)
	Loop While (hNext)
	FindClose(hFind)
	If mCancel Then Exit Sub
	
	If mCopyEmptyPath Then PathCreate(*mSyncTarget + PathStr)
End Sub

Private Sub FilesSync.PathSync()
	StepInit(1, "File Copy")
	If mSyncMode Then StepInit(2, "File Copy")
	If mDuplicat Then StepInit(2, "File Copy")
	
	WStr2Ptr(mPathA, mPercentPath)
	mPercentThread = ThreadCreate(Cast(Any Ptr, @PercentThread), @This)
	
	WStr2Ptr(mPathA, mSyncSource)
	WStr2Ptr(mPathB, mSyncTarget)
	PathSyncSub("")
	
	If mSyncMode Then
		StepInc("File Sync")
		WStr2Ptr(mPathB, mPercentPath)
		mPercentThread = ThreadCreate(Cast(Any Ptr, @PercentThread), @This)
		
		WStr2Ptr(mPathA, mSyncTarget)
		WStr2Ptr(mPathB, mSyncSource)
		PathSyncSub("")
	End If
	
	If mDuplicat Then
		StepInc("Delete B not in A")
		
		WStr2Ptr(mSyncTarget, mPercentPath)
		mPercentThread = ThreadCreate(Cast(Any Ptr, @PercentThread), @This)
		
		mFileDeleteBNotInACount = -1
		DeleteBNotInA("")
	End If
End Sub

Private Sub FilesSync.PathRemoveSub(PathStr As WString)
	Dim wfd As WIN32_FIND_DATA
	Dim hFind As HANDLE
	Dim hNext As WINBOOL
	
	If mCancel Then Exit Sub
	
	hFind = FindFirstFile(PathStr & "\*.*" , @wfd)
	If hFind = INVALID_HANDLE_VALUE Then Exit Sub
	Do
		If wfd.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY Then
			If wfd.cFileName <> "." And wfd.cFileName <> ".." Then
				PathRemoveSub(PathStr & "\" & wfd.cFileName)
			End If
		Else
			ActFile(Act_FileDelete, PathStr & "\" & wfd.cFileName, NULL, @wfd)
			mPercentStep += 1
		End If
		If mCancel Then Exit Do
		hNext = FindNextFile(hFind , @wfd)
	Loop While (hNext)
	FindClose(hFind)
	
	If mCancel Then Exit Sub
	
	ActPath(Act_PathRemove, PathStr)
End Sub

Private Sub FilesSync.PathRemove(PathStr As WString Ptr)
	If PathFileExists(PathStr) = False Then Return
	
	WStr2Ptr(PathStr, mPercentPath)
	mPercentThread = ThreadCreate(Cast(Any Ptr, @PercentThread), @This)
	
	PathRemoveSub(*PathStr)
End Sub

Private Property FilesSync.Cancel() As Integer
	Return mCancel
End Property

Private Property FilesSync.Cancel(ByVal nVal As Integer)
	mCancel = True
End Property

Private Property FilesSync.ErrorCount() As Integer
	If mErrorMessageCount < 0 Then Return False Else Return True
End Property

Private Property FilesSync.Done() As Integer
	Return mDone
End Property

Private Property FilesSync.Done(ByVal nVal As Integer)
	StepInc("Completed")
	
	If mLogMode= 2 Then
		LogFile(Information)
		LogFileClose()
	End If
	
	If mPercentThread Then
		Do While mPercentReady = False
		Loop 'wait for thread done
	End If
	
	mPercentStep = mPercentCount
	mPercentThread = NULL
	mDone = True
	If OnDone Then OnDone(mOwner)
End Property

Private Function FilesSync.ReportData(x As Long, y As Long) ByRef As WString
	Select Case x
	Case 0 'Description
		Select Case y
		Case 0 'Copy
			WStr2Ptr("File Copy", WStrTmpPtr)
		Case 1 'Overwrite
			WStr2Ptr("File Overwrite", WStrTmpPtr)
		Case 2 'Skip
			WStr2Ptr("File Skip", WStrTmpPtr)
		Case 3 'Delete
			WStr2Ptr("File Delete", WStrTmpPtr)
		Case 4 'Delete B not in A
			WStr2Ptr("File Delete B not in A", WStrTmpPtr)
		Case 5 'Create
			WStr2Ptr("Path Create", WStrTmpPtr)
		Case 6 'Remove
			WStr2Ptr("Path Remove", WStrTmpPtr)
		Case 7 'Remove B not in A
			WStr2Ptr("Path Remove B not in A", WStrTmpPtr)
		Case 8 'Time
			WStr2Ptr("Time Use", WStrTmpPtr)
		Case 9 'Step
			WStr2Ptr("Step", WStrTmpPtr)
		Case 10 'Progress
			WStr2Ptr("Progress", WStrTmpPtr)
		Case 11 'Information
			WStr2Ptr("Information", WStrTmpPtr)
		Case 12 'Error
			WStr2Ptr("Error", WStrTmpPtr)
		Case Else 'Description
			WStr2Ptr("Description", WStrTmpPtr)
		End Select
	Case 1 'count
		Select Case y
		Case 0 'Copy
			WStr2Ptr(Format(mFileCopyCount + 1, "#,#0"), WStrTmpPtr)
		Case 1 'Overwrite
			WStr2Ptr(Format(mFileOverwriteCount + 1, "#,#0"), WStrTmpPtr)
		Case 2 'Skip
			WStr2Ptr(Format(mFileSkipCount + 1, "#,#0"), WStrTmpPtr)
		Case 3 'Delete
			WStr2Ptr(Format(mFileDeleteCount + 1, "#,#0"), WStrTmpPtr)
		Case 4 'Delete B not in A
			WStr2Ptr(Format(mFileDeleteBNotInACount + 1, "#,#0"), WStrTmpPtr)
		Case 5 'Create
			WStr2Ptr(Format(mPathCreateCount + 1, "#,#0"), WStrTmpPtr)
		Case 6 'Remove
			WStr2Ptr(Format(mPathRemoveCount + 1, "#,#0"), WStrTmpPtr)
		Case 7 'Remove B not in A
			WStr2Ptr(Format(mPathRemoveBNotInACount + 1, "#,#0"), WStrTmpPtr)
		Case 8 'Time
			WStr2Ptr(Format(TimePass, "#,#0.000"), WStrTmpPtr)
		Case 9 'Step
			If mStepCount < 0 Then
				WStr2Ptr("Idle", WStrTmpPtr)
			ElseIf PercentTotal < 0 Then
				WStr2Ptr("Calculating", WStrTmpPtr)
			Else
				WStr2Ptr(Format(mPercentStep, "#,#0") & "/" & Format(mPercentCount, "#,#0"), WStrTmpPtr)
			End If
		Case 10 'Progress
			If mStepCount < 0 Then
				WStr2Ptr("Idle", WStrTmpPtr)
			Else
				WStr2Ptr(IIf(mStepDoing < mStepCount, mStepDoing + 1 , mStepCount) & "/" & mStepCount, WStrTmpPtr)
			End If
		Case 11 'Information
			If mStepCount < 0 Then
				WStr2Ptr("Idle", WStrTmpPtr)
			ElseIf Cancel Then
				WStr2Ptr("Cancel", WStrTmpPtr)
			ElseIf Done Then
				WStr2Ptr("Done", WStrTmpPtr)
			Else
				WStr2Ptr("", WStrTmpPtr)
			End If
		Case 12 'Error
			WStr2Ptr(Format(mErrorMessageCount + 1, "#,#0"), WStrTmpPtr)
		Case Else 'count
			WStr2Ptr("Count", WStrTmpPtr)
		End Select
	Case 2 'size
		Select Case y
		Case 0 'Copy
			WStr2Ptr(Format(mFileCopySize, "#,#0") & " | " & Number2Str(mFileCopySize), WStrTmpPtr)
		Case 1 'Overwrite
			WStr2Ptr(Format(mFileOverwriteSize, "#,#0") & " | " & Number2Str(mFileOverwriteSize), WStrTmpPtr)
		Case 2 'Skip
			WStr2Ptr(Format(mFileSkipSize, "#,#0") & " | " & Number2Str(mFileSkipSize), WStrTmpPtr)
		Case 3 'Delete
			WStr2Ptr(Format(mFileDeleteSize, "#,#0") & " | " & Number2Str(mFileDeleteSize), WStrTmpPtr)
		Case 4 'Delete B not in A
			WStr2Ptr(Format(mFileDeleteBNotInASize, "#,#0") & " | " & Number2Str(mFileDeleteBNotInASize), WStrTmpPtr)
		Case 5 'Create
			WStr2Ptr("", WStrTmpPtr)
		Case 6 'Remove
			WStr2Ptr("", WStrTmpPtr)
		Case 7 'Remove B not in A
			WStr2Ptr("", WStrTmpPtr)
		Case 8 'Time
			WStr2Ptr(Sec2Time(TimePass, , , "#00.000"), WStrTmpPtr)
		Case 9 'Step
			If mStepCount < 0 Then
				WStr2Ptr("Idle", WStrTmpPtr)
			ElseIf PercentTotal < 0 Then
				WStr2Ptr("Calculating", WStrTmpPtr)
			Else
				If PercentStep < 0 Then
					WStr2Ptr(Format(100, "0.00") & "%", WStrTmpPtr)
				Else
					WStr2Ptr(Format(PercentStep, "0.00") & "%", WStrTmpPtr)
				End If
			End If
		Case 10 'Progress
			If mStepCount < 0 Then
				WStr2Ptr("Idle", WStrTmpPtr)
			ElseIf PercentTotal < 0 Then
				WStr2Ptr("Calculating", WStrTmpPtr)
			Else
				WStr2Ptr(Format(PercentTotal, "0.00") & "%", WStrTmpPtr)
			End If
		Case 11 'Information
			If mStepCount < 0 Then
				WStr2Ptr("Idle", WStrTmpPtr)
			Else
				WStr2Ptr(*mStepMessage(mStepDoing), WStrTmpPtr)
			End If
		Case 12 'Error
			If mStepCount < 0 Then
				WStr2Ptr("Idle", WStrTmpPtr)
			ElseIf mErrorMessageCount < 0 Then
				WStr2Ptr("Passed", WStrTmpPtr)
			Else
				WStr2Ptr("Failed", WStrTmpPtr)
			End If
		Case Else 'size
			WStr2Ptr("Size", WStrTmpPtr)
		End Select
	End Select
	Return *WStrTmpPtr
End Function

Private Property FilesSync.Summary() ByRef As WString
	Dim a() As WString Ptr
	ReDim a(13)
	Dim b() As WString Ptr
	ReDim b(2)
	
	Dim y As Long
	Dim x As Long
	
	For x = 0 To 2
		WStr2Ptr(ReportData(x, -1), b(x))
	Next
	
	WStrTitle(70, "-", *b(0), *b(1), *b(2), a(0))
	For y = 0 To 12
		For x = 0 To 2
			WStr2Ptr(ReportData(x, y), b(x))
		Next
		WStrTitle(70, " ", *b(0), *b(1), *b(2), a(y + 1))
	Next y
	
	JoinWStr(a(), vbCrLf, WStrTmpPtr)
	ArrayDeallocate(a())
	ArrayDeallocate(b())
	Return *WStrTmpPtr
End Property

Private Property FilesSync.Setting() ByRef As WString
	Dim a() As WString Ptr
	ReDim a(7)
	Dim b As String
	WStrTitle(70, "-", "Setting Item", , "Set", a(0))
	
	Select Case mThreadMode
	Case 1
		b = "Sync "
	Case 2
		b = "Remove "
	Case 3
		b = "Create "
	Case Else
		b = "Not Set "
	End Select
	WStrTitle(70, " ", "Work Mode", , b & mThreadMode, a(1))
	
	If mSyncMode Then b = "Synchronization " Else b = "Duplication "
	WStrTitle(70, " ", "Sync Mode", , b & mSyncMode, a(2))
	
	If mCopyEmptyPath Then b = "True " Else b = "False "
	WStrTitle(70, " ", "Copy Empty Path", , b & mCopyEmptyPath, a(3))
	
	If mDuplicat Then b = "True " Else b = "False "
	WStrTitle(70, " ", "Delete B Not In A", , b & mDuplicat, a(4))
	
	Select Case mCompareData
	Case 0
		b = "Size "
	Case 1
		b = "Write Time "
	Case 2
		b = "Creation Time "
	Case 3
		b = "Access Time "
	End Select
	
	WStrTitle(70, " ", "Overwrite Compare Data", , b & mCompareData, a(5))
	Select Case mCompareData
	Case 0
		Select Case mCompareMode
		Case 0
			b = "Larger "
		Case 1
			b = "Smaller "
		Case 2
			b = "Not Equal "
		Case 3
			b = "Equal "
		End Select
	Case Else
		Select Case mCompareMode
		Case 0
			b = "Newer "
		Case 1
			b = "Older "
		Case 2
			b = "Not Equal "
		Case 3
			b = "Equal "
		End Select
	End Select
	
	WStrTitle(70, " ", "Overwrite Compare Mode", , b & mCompareMode, a(6))
	
	Select Case mLogMode
	Case 0
		b = "None "
	Case 1
		b = "Memory "
	Case 2
		b = "File "
	End Select
	WStrTitle(70, " ", "Log Mode", , b & mLogMode, a(7))
	
	JoinWStr(a(), vbCrLf, WStrTmpPtr)
	ArrayDeallocate(a())
	Return *WStrTmpPtr
End Property

Private Property FilesSync.Speed() ByRef As WString
	If mStepCount < 0 Then Return "NA"
	Dim i As Long
	Dim d As Double
	Dim d2 As Double = TimePass
	
	Dim a() As WString Ptr
	Dim s() As LongInt
	
	ReDim a(mStepDoing + 8)
	ReDim s(8)
	
	s(0) = (mFileCopySize + mFileOverwriteSize + mFileSkipSize) / d2
	s(1) = (mFileCopyCount + mFileOverwriteCount + mFileSkipCount + mPathCreateCount) / d2
	s(2) = (mFileDeleteSize + mFileDeleteBNotInASize) / d2
	s(3) = (mFileDeleteCount + mFileDeleteBNotInACount + mPathRemoveCount + mPathRemoveBNotInACount) / d2
	
	If mCopyTime Then
		s(4) = (mFileCopySize + mFileOverwriteSize) / mCopyTime
		s(5) = ((mFileCopyCount + mFileOverwriteCount + mPathCreateCount)) / mCopyTime
	End If
	If mDeleteTime Then
		s(6) = (mFileDeleteSize + mFileDeleteBNotInASize) / mDeleteTime
		s(7) = (mFileDeleteCount + mFileDeleteBNotInACount + mPathRemoveCount + mPathRemoveBNotInACount) / mDeleteTime
	End If
	If s(1) < 0 Then s(1) = 0
	If s(3) < 0 Then s(3) = 0
	If s(5) < 0 Then s(5) = 0
	If s(7) < 0 Then s(7) = 0
	
	WStrTitle(70, "-", "Step" , "Seconds", "Times", a(0))
	For i = 0 To mStepDoing
		If i = mStepDoing Then
			If mStepDoing = mStepCount Then
				d = mStepTime(i)
			Else
				d = d2 - mStepTimeAdd
			End If
		Else
			d = mStepTime(i)
		End If
		WStrTitle(70, " ", *mStepMessage(i), Format(d, "#,#0.000"), Sec2Time(d, , , "#00.000"), a(i + 1))
	Next
	
	WStrTitle(70, "-", "Description", "Size/Sec.", "Count/Sec.", a(mStepDoing + 3))
	
	WStrTitle(70, " ", "Copy Speed", Number2Str(s(4)), Format(s(5), "#,#0"), a(mStepDoing + 4))
	WStrTitle(70, " ", "Delete Speed", Number2Str(s(6)), Format(s(7), "#,#0"), a(mStepDoing + 5))
	
	WStrTitle(70, " ", "Total Copy Speed", Number2Str(s(0)), Format(s(1), "#,#0"), a(mStepDoing + 7))
	WStrTitle(70, " ", "Total Delete Speed", Number2Str(s(2)), Format(s(3), "#,#0"), a(mStepDoing + 8))
	
	JoinWStr(a(), vbCrLf, WStrTmpPtr)
	ArrayDeallocate(a())
	Erase s
	Return *WStrTmpPtr
End Property

Private Property FilesSync.DetialInfo() ByRef As WString
	If mLogMode<> 1 Then Return "NA"
	
	Dim a() As WString Ptr
	ReDim a(25)
	
	Dim b() As WString Ptr
	ReDim b(2)
	
	Dim y As Long
	For y = 0 To 7
		WStr2Ptr(ReportData(0, y), b(0))
		WStr2Ptr(ReportData(1, y), b(1))
		WStr2Ptr(ReportData(2, y), b(2))
		WStrTitle(70, "-", *b(0), *b(1), *b(2), a(y * 3))
	Next
	y = 12
	WStr2Ptr(ReportData(0, y), b(0))
	WStr2Ptr(ReportData(1, y), b(1))
	WStr2Ptr(ReportData(2, y), b(2))
	WStrTitle(70, "-", *b(0), *b(1), *b(2), a(24))
	
	If mDone Then
		JoinWStr(mFileCopy(), vbCrLf, a(1), , mFileCopyCount)
		JoinWStr(mFileOverwrite(), vbCrLf, a(4), , mFileOverwriteCount)
		JoinWStr(mFileSkip(), vbCrLf, a(7), , mFileSkipCount)
		JoinWStr(mFileDelete(), vbCrLf, a(10), , mFileDeleteCount)
		JoinWStr(mFileDeleteBNotInA(), vbCrLf, a(13), , mFileDeleteBNotInACount)
		JoinWStr(mPathCreate(), vbCrLf, a(16), , mPathCreateCount)
		JoinWStr(mPathRemove(), vbCrLf, a(19), , mPathRemoveCount)
		JoinWStr(mPathRemoveBNotInA(), vbCrLf, a(22), , mPathRemoveBNotInACount)
		JoinWStr(mErrorMessage(), vbCrLf, a(25), , mErrorMessageCount)
	Else
		For y = 0 To 7
			WStr2Ptr(WStr("Ongoing..."), a(y * 3 + 1))
		Next
		WStr2Ptr(WStr("Ongoing..."), a(25))
	End If
	
	Static rtnWstr As WString Ptr
	JoinWStr(a(), vbCrLf, rtnWstr)
	ArrayDeallocate(a())
	ArrayDeallocate(b())
	Return *rtnWstr
End Property

Private Property FilesSync.Report(Index As Integer) ByRef As WString
	Select Case Index
	Case 0 'copy
		If mFileCopyCount < 0 Or mLogMode<> 1 Then Return "NA"
		JoinWStr(mFileCopy(), vbCrLf, WStrTmpPtr, , mFileCopyCount)
	Case 1 'overwrite
		If mFileOverwriteCount < 0 Or mLogMode<> 1 Then Return "NA"
		JoinWStr(mFileOverwrite(), vbCrLf, WStrTmpPtr, , mFileOverwriteCount)
	Case 2 'skip
		If mFileSkipCount < 0 Or mLogMode<> 1 Then Return "NA"
		JoinWStr(mFileSkip(), vbCrLf, WStrTmpPtr, , mFileSkipCount)
	Case 3 'delete
		If mFileDeleteCount < 0 Or mLogMode<> 1 Then Return "NA"
		JoinWStr(mFileDelete(), vbCrLf, WStrTmpPtr, , mFileDeleteCount)
	Case 4 'deletebnotina
		If mFileDeleteBNotInACount < 0 Or mLogMode<> 1 Then Return "NA"
		JoinWStr(mFileDeleteBNotInA(), vbCrLf, WStrTmpPtr, , mFileDeleteBNotInACount)
	Case 5 'create
		If mPathCreateCount < 0 Or mLogMode<> 1 Then Return "NA"
		JoinWStr(mPathCreate(), vbCrLf, WStrTmpPtr, , mPathCreateCount)
	Case 6 'remove
		If mPathRemoveCount < 0 Or mLogMode<> 1 Then Return "NA"
		JoinWStr(mPathRemove(), vbCrLf, WStrTmpPtr, , mPathRemoveCount)
	Case 7 'removebnotina
		If mPathRemoveBNotInACount < 0 Or mLogMode<> 1 Then Return "NA"
		JoinWStr(mPathRemoveBNotInA(), vbCrLf, WStrTmpPtr, , mPathRemoveBNotInACount)
	Case 8 'time use
		Return Speed
	Case 9 'step
		Return Setting
	Case 10 'progress
		Return Summary
	Case 11 'information
		Return Information
	Case 12 'error
		If mErrorMessageCount < 0 Or mLogMode<> 1 Then Return "NA"
		JoinWStr(mErrorMessage(), vbCrLf, WStrTmpPtr)
	Case Else
		Return "Unknow"
	End Select
	Return *WStrTmpPtr
End Property

Private Property FilesSync.Information() ByRef As WString
	Dim a() As WString Ptr
	ReDim a(10)
	
	WStrTitle(80, "=", "Setting", , , a(0))
	WStrTitle(80, "=", "Speed", , , a(3))
	WStrTitle(80, "=", "Summary", , , a(6))
	WStrTitle(80, "=", "Detials", , , a(9))
	WStr2Ptr(Setting, a(1))
	WStr2Ptr(Speed, a(4))
	WStr2Ptr(Summary, a(7))
	WStr2Ptr(DetialInfo, a(10))
	
	JoinWStr(a(), vbCrLf, WStrTmpPtr)
	ArrayDeallocate(a())
	Return *WStrTmpPtr
End Property

Private Property FilesSync.PercentTotal() As Double
	Static s As Double
	Static t As Double
	If mStepCount < 0 Then Return - 3
	If mCancel Then Return t
	If mDone Then Return 100
	If mPercentCount = 0 Then Return -1
	If mPercentReady = False Then Return - 2
	s = mPercentStep / mPercentCount
	t = (mStepDoing + s) / mStepCount * 100
	Return t
End Property

Private Property FilesSync.PercentStep() As Double
	If mPercentReady = False Then Return - 1
	Return mPercentStep / mPercentCount * 100
End Property

Private Sub FilesSync.LogFile(LogMsg As Const WString)
	Print #mLogFileNum, LogMsg
End Sub

Private Sub FilesSync.LogFileOpen()
	If PathFileExists(mLogFile) Then Kill(*mLogFile)
	mLogFileNum = FreeFile
	Open *mLogFile For Append As #mLogFileNum
End Sub

Private Sub FilesSync.LogFileClose()
	Close #mLogFileNum
End Sub


