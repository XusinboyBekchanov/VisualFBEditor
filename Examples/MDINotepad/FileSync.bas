' FileAct 文件处理
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#pragma once
#include once "FileSync.bi"

Private Function FilesSync.Remove(Owner As Any Ptr, PathStr As WString) As Integer
	mOwner = Owner
	WLet(mPathA, PathStr)
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
	WLet(mPathA, PathStr)
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
	WLet(mPathA, SourceStr)
	WLet(mPathB, TargetStr)
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

Private Function FilesSync.SyncThread(ByVal pParam As Any Ptr) As Any Ptr
	Dim cFS As FilesSync Ptr = Cast(FilesSync Ptr , pParam)
	cFS->SyncDoing()
	Return 0
End Function

Private Function FilesSync.PercentThread(ByVal pParam As Any Ptr) As Any Ptr
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
	'If WStrTmpPtr Then Deallocate(WStrTmpPtr)
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
	mFileSkipSize = 0
	
	mErrorMessageCount = -1
	
	mCancel = False
	mDone = False
	
	If mLogMode = 2 Then LogFileOpen()
End Sub

Private Sub FilesSync.StepInit(StepCount As LongInt, StepMsg As WString)
	ArrayDeallocate(mStepMessage())
	ReDim mStepMessage(StepCount)
	ReDim mStepTime(StepCount)
	
	mStepCount = StepCount
	mStepDoing = 0
	WLet(mStepMessage(mStepDoing), StepMsg)
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

Private Sub FilesSync.StepInc(StepMsg As WString)
	Dim t As Double
	
	t = mTiMr.Passed
	mStepTime(mStepDoing) = t - mStepTimeAdd
	mStepTimeAdd = t
	mStepDoing += 1
	WLet(mStepMessage(mStepDoing), StepMsg)
	If mStepDoing = mStepCount Then mStepTime(mStepDoing) = t
End Sub

Private Sub FilesSync.ErrorInc(ErrorTitle As WString, ErrorMsg As WString Ptr)
	Dim tIndex As LongInt
	Select Case mLogMode
	Case 1
		tIndex = mErrorMessageCount + 1
		If ((tIndex Mod mFileInc) = 0) Or (tIndex = 0) Then
			ReDim Preserve mErrorMessage(mErrorMessageCount + mFileInc)
		End If
		WLet(mErrorMessage(tIndex), "Error: " & ErrorTitle & *ErrorMsg)
	Case 2
		LogFile("Error: " & ErrorTitle & vbTab & *ErrorMsg)
	End Select
	mErrorMessageCount += 1
End Sub

Private Sub FilesSync.CountInc(CntIdx As PathFileCountEnum, IncMsg As WString = "")
	Dim tIndex As LongInt
	Select Case mLogMode
	Case 1
		Select Case CntIdx
		Case Count_FileCopy
			tIndex = mFileCopyCount + 1
			If ((tIndex Mod mFileInc) = 0) Or (tIndex = 0) Then
				ReDim Preserve mFileCopy(mFileCopyCount + mFileInc)
			End If
			WLet(mFileCopy(tIndex), IncMsg)
		Case Count_FileOverwrite
			tIndex = mFileOverwriteCount + 1
			If ((tIndex Mod mFileInc) = 0) Or (tIndex = 0) Then
				ReDim Preserve mFileOverwrite(mFileOverwriteCount + mFileInc)
			End If
			WLet(mFileOverwrite(tIndex), IncMsg)
		Case Count_FileSkip
			tIndex = mFileSkipCount + 1
			If ((tIndex Mod mFileInc) = 0) Or (tIndex = 0) Then
				ReDim Preserve mFileSkip(mFileSkipCount + mFileInc)
			End If
			WLet(mFileSkip(tIndex), IncMsg)
		Case Count_FileDelete
			tIndex = mFileDeleteCount + 1
			If ((tIndex Mod mFileInc) = 0) Or (tIndex = 0) Then
				ReDim Preserve mFileDelete(mFileDeleteCount + mFileInc)
			End If
			WLet(mFileDelete(tIndex), IncMsg)
		Case Count_PathCreate
			tIndex = mPathCreateCount + 1
			If ((tIndex Mod mFileInc) = 0) Or (tIndex = 0) Then
				ReDim Preserve mPathCreate(mPathCreateCount + mFileInc)
			End If
			WLet(mPathCreate(tIndex), IncMsg)
		Case Count_PathRemove
			tIndex = mPathRemoveCount + 1
			If ((tIndex Mod mFileInc) = 0) Or (tIndex = 0) Then
				ReDim Preserve mPathRemove(mPathRemoveCount + mFileInc)
			End If
			WLet(mPathRemove(tIndex), IncMsg)
		Case Count_PathRemoveBNotInA
			tIndex = mPathRemoveBNotInACount + 1
			If ((tIndex Mod mFileInc) = 0) Or (tIndex = 0) Then
				ReDim Preserve mPathRemoveBNotInA(mPathRemoveBNotInACount + mFileInc)
			End If
			WLet(mPathRemoveBNotInA(tIndex), IncMsg)
		Case Count_FileDeleteBNotInA
			tIndex = mFileDeleteBNotInACount + 1
			If ((tIndex Mod mFileInc) = 0) Or (tIndex = 0) Then
				ReDim Preserve mFileDeleteBNotInA(mFileDeleteBNotInACount + mFileInc)
			End If
			WLet(mFileDeleteBNotInA(tIndex), IncMsg)
		End Select
	Case 2
		LogFile(LogStr(CntIdx ) & IncMsg)
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
	Static WStrTmpPtr As WString Ptr
	Select Case Index
	Case Count_FileCopy
		WLet(WStrTmpPtr, "FileCopy: " & Index & vbTab)
	Case Count_FileOverwrite
		WLet(WStrTmpPtr, "FileOverwrite: " & Index & vbTab)
	Case Count_FileSkip
		WLet(WStrTmpPtr, "FileSkip: " & Index & vbTab)
	Case Count_FileDelete
		WLet(WStrTmpPtr, "FileDelete: " & Index & vbTab)
	Case Count_PathCreate
		WLet(WStrTmpPtr, "PathCreate: " & Index & vbTab)
	Case Count_PathRemove
		WLet(WStrTmpPtr, "PathRemove: " & Index & vbTab)
	Case Count_PathRemoveBNotInA
		WLet(WStrTmpPtr, "PathRemoveBNotInA: " & Index & vbTab)
	Case Count_FileDeleteBNotInA
		WLet(WStrTmpPtr, "FileDeleteBNotInA: " & Index & vbTab)
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
			CountInc(Count_FileOverwrite, *TargetStr)
			mFileOverwriteSize += WFD2Bytes(wfd)
			mCopyTime+= mTiMr.Passed - st
		Else
			ErrorInc("Act_FileOverwrite: ", TargetStr)
		End If
	Case Act_FileCopy
		If CopyFile(*SourceStr, *TargetStr, False) Then
			CountInc(Count_FileCopy, *SourceStr)
			mFileCopySize += WFD2Bytes(wfd)
			mCopyTime+= mTiMr.Passed - st
		Else
			ErrorInc("Act_FileCopy: ", SourceStr)
		End If
	Case Act_FileDelete
		SetFileAttributes(*SourceStr, FILE_ATTRIBUTE_NORMAL)
		If DeleteFile(*SourceStr) Then
			CountInc(Count_FileDelete, *SourceStr)
			mFileDeleteSize += WFD2Bytes(wfd)
			mDeleteTime+= mTiMr.Passed - st
		Else
			ErrorInc("Act_FileDelete: ", SourceStr)
		End If
	Case Act_FileDeleteBNotInA
		SetFileAttributes(*SourceStr, FILE_ATTRIBUTE_NORMAL)
		If DeleteFile(*SourceStr) Then
			CountInc(Count_FileDeleteBNotInA, *SourceStr)
			mFileDeleteBNotInASize += WFD2Bytes(wfd)
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
			CountInc(Count_PathCreate, *SourceStr)
			mCopyTime+= mTiMr.Passed - st
			Return True
		Else
			ErrorInc("Act_PathCreate: ", SourceStr)
		End If
	Case Act_PathRemove
		If RemoveDirectory(*SourceStr) Then
			CountInc(Count_PathRemove, *SourceStr)
			mDeleteTime+= mTiMr.Passed - st
			Return True
		Else
			ErrorInc("Act_PathRemove: ", SourceStr)
		End If
	Case Act_PathRemoveBNotInA
		If RemoveDirectory(*SourceStr) Then
			CountInc(Count_PathRemoveBNotInA, *SourceStr)
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
	WLet(dirs(k), *PathStr)
	
	j = -1
	Do
		i = InStrRev(*PathStr, "\", j)
		If i Then
			j = i - l
			If j Then
				WLet(t, Left(*PathStr, j))
				
				If Right(*t, 1) = ":" Then Exit Do
				If Right(*t, 1) = "\" Then
					k -= 1
					Exit Do
				End If
				If PathFileExists(t) Then Exit Do
				k = k + 1
				ReDim Preserve dirs(k)
				WLet(dirs(k), *t)
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
			mFileSkipSize += WFD2Bytes(wfd)
		End If
	Else
		i = InStrRev(*PathStr, "\")
		If i Then PathCreate(*mSyncTarget + Left(*PathStr, i - 1))
		ActFile(Act_FileCopy, *mSyncSource & *PathStr, *mSyncTarget & *PathStr, wfd)
	End If
End Sub

Private Sub FilesSync.DeleteBNotInA(PathStr As WString)
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
	'Erase mListWFD
	
	ListFileSub("")
	
	If mListFileCount >-1 Then
		ReDim Preserve mListFile(mListFileCount)
		'ReDim Preserve mListWFD(mListFileCount)
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
				End If
				WLet(mListPath(tIndex), PathStr + "\" + wfd.cFileName)
				mListPathCount = tIndex
			End If
		Else
			tIndex = mListFileCount + 1
			If ((tIndex Mod mFileInc) = 0) Or (tIndex = 0) Then
				ReDim Preserve mListFile(mListFileCount + mFileInc)
				'ReDim Preserve mListWFD(mListFileCount + mFileInc)
			End If
			WLet(mListFile(tIndex), PathStr + "\" + wfd.cFileName)
			'memcpy(@mListWFD(tIndex), @wfd, SizeOf(wfd))
			mListFileCount = tIndex
		End If
		If mCancel Then Exit Do
		hNext = FindNextFile(hFind , @wfd)
	Loop While (hNext)
	FindClose(hFind)
	If mCancel Then Exit Sub
End Sub

Private Sub FilesSync.PathSyncSub(PathStr As WString)
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
	
	WLet(mPercentPath, *mPathA)
	mPercentThread = ThreadCreate(Cast(Any Ptr, @PercentThread), @This)
	
	WLet(mSyncSource, *mPathA)
	WLet(mSyncTarget, *mPathB)
	PathSyncSub("")
	
	If mSyncMode Then
		StepInc("File Sync")
		WLet(mPercentPath, *mPathB)
		mPercentThread = ThreadCreate(Cast(Any Ptr, @PercentThread), @This)
		
		WLet(mSyncTarget, *mPathA)
		WLet(mSyncSource, *mPathB)
		PathSyncSub("")
	End If
	
	If mDuplicat Then
		StepInc("Delete B not in A")
		
		WLet(mPercentPath, *mSyncTarget)
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
	
	WLet(mPercentPath, *PathStr)
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
	mSyncThread = NULL
End Property

Private Function FilesSync.ReportData(x As Long, y As Long) ByRef As WString
	Static WStrTmpPtr As WString Ptr
	Select Case x
	Case 0 'Description
		Select Case y
		Case 0 'Copy
			WLet(WStrTmpPtr, "File Copy")
		Case 1 'Overwrite
			WLet(WStrTmpPtr, "File Overwrite")
		Case 2 'Skip
			WLet(WStrTmpPtr, "File Skip")
		Case 3 'Delete
			WLet(WStrTmpPtr, "File Delete")
		Case 4 'Delete B not in A
			WLet(WStrTmpPtr, "File Delete B not in A")
		Case 5 'Create
			WLet(WStrTmpPtr, "Path Create")
		Case 6 'Remove
			WLet(WStrTmpPtr, "Path Remove")
		Case 7 'Remove B not in A
			WLet(WStrTmpPtr, "Path Remove B not in A")
		Case 8 'Time
			WLet(WStrTmpPtr, "Time Use")
		Case 9 'Step
			WLet(WStrTmpPtr, "Step")
		Case 10 'Progress
			WLet(WStrTmpPtr, "Progress")
		Case 11 'Information
			WLet(WStrTmpPtr, "Information")
		Case 12 'Error
			WLet(WStrTmpPtr, "Error")
		Case Else 'Description
			WLet(WStrTmpPtr, "Description")
		End Select
	Case 1 'count
		Select Case y
		Case 0 'Copy
			WLet(WStrTmpPtr, Format(mFileCopyCount + 1, "#,#0"))
		Case 1 'Overwrite
			WLet(WStrTmpPtr, Format(mFileOverwriteCount + 1, "#,#0"))
		Case 2 'Skip
			WLet(WStrTmpPtr, Format(mFileSkipCount + 1, "#,#0"))
		Case 3 'Delete
			WLet(WStrTmpPtr, Format(mFileDeleteCount + 1, "#,#0"))
		Case 4 'Delete B not in A
			WLet(WStrTmpPtr, Format(mFileDeleteBNotInACount + 1, "#,#0"))
		Case 5 'Create
			WLet(WStrTmpPtr, Format(mPathCreateCount + 1, "#,#0"))
		Case 6 'Remove
			WLet(WStrTmpPtr, Format(mPathRemoveCount + 1, "#,#0"))
		Case 7 'Remove B not in A
			WLet(WStrTmpPtr, Format(mPathRemoveBNotInACount + 1, "#,#0"))
		Case 8 'Time
			WLet(WStrTmpPtr, Format(TimePass, "#,#0.000"))
		Case 9 'Step
			If mStepCount < 0 Then
				WLet(WStrTmpPtr, "Idle")
			ElseIf PercentTotal < 0 Then
				WLet(WStrTmpPtr, "Calculating")
			Else
				WLet(WStrTmpPtr, Format(mPercentStep, "#,#0") & "/" & Format(mPercentCount, "#,#0"))
			End If
		Case 10 'Progress
			If mStepCount < 0 Then
				WLet(WStrTmpPtr, "Idle")
			Else
				WLet(WStrTmpPtr, IIf(mStepDoing < mStepCount, mStepDoing + 1 , mStepCount) & "/" & mStepCount)
			End If
		Case 11 'Information
			If mStepCount < 0 Then
				WLet(WStrTmpPtr, "Idle")
			ElseIf Cancel Then
				WLet(WStrTmpPtr, "Cancel")
			ElseIf Done Then
				WLet(WStrTmpPtr, "Done")
			Else
				WLet(WStrTmpPtr, "NA")
			End If
		Case 12 'Error
			WLet(WStrTmpPtr, Format(mErrorMessageCount + 1, "#,#0"))
		Case Else 'count
			WLet(WStrTmpPtr, "Count")
		End Select
	Case 2 'size
		Select Case y
		Case 0 'Copy
			WLet(WStrTmpPtr, Format(mFileCopySize, "#,#0") & " | " & Bytes2Str(mFileCopySize))
		Case 1 'Overwrite
			WLet(WStrTmpPtr, Format(mFileOverwriteSize, "#,#0") & " | " & Bytes2Str(mFileOverwriteSize))
		Case 2 'Skip
			WLet(WStrTmpPtr, Format(mFileSkipSize, "#,#0") & " | " & Bytes2Str(mFileSkipSize))
		Case 3 'Delete
			WLet(WStrTmpPtr, Format(mFileDeleteSize, "#,#0") & " | " & Bytes2Str(mFileDeleteSize))
		Case 4 'Delete B not in A
			WLet(WStrTmpPtr, Format(mFileDeleteBNotInASize, "#,#0") & " | " & Bytes2Str(mFileDeleteBNotInASize))
		Case 5 'Create
			WLet(WStrTmpPtr, "")
		Case 6 'Remove
			WLet(WStrTmpPtr, "")
		Case 7 'Remove B not in A
			WLet(WStrTmpPtr, "")
		Case 8 'Time
			WLet(WStrTmpPtr, Sec2Time(TimePass, , , "#00.000"))
		Case 9 'Step
			If mStepCount < 0 Then
				WLet(WStrTmpPtr, "Idle")
			ElseIf PercentTotal < 0 Then
				WLet(WStrTmpPtr, "Calculating")
			Else
				If PercentStep < 0 Then
					WLet(WStrTmpPtr, Format(100, "0.00") & "%")
				Else
					WLet(WStrTmpPtr, Format(PercentStep, "0.00") & "%")
				End If
			End If
		Case 10 'Progress
			If mStepCount < 0 Then
				WLet(WStrTmpPtr, "Idle")
			ElseIf PercentTotal < 0 Then
				WLet(WStrTmpPtr, "Calculating")
			Else
				WLet(WStrTmpPtr, Format(PercentTotal, "0.00") & "%")
			End If
		Case 11 'Information
			If mStepCount < 0 Then
				WLet(WStrTmpPtr, "Idle")
			Else
				WLet(WStrTmpPtr, *mStepMessage(mStepDoing))
			End If
		Case 12 'Error
			If mStepCount < 0 Then
				WLet(WStrTmpPtr, "Idle")
			ElseIf mErrorMessageCount < 0 Then
				WLet(WStrTmpPtr, "Passed")
			Else
				WLet(WStrTmpPtr, "Failed")
			End If
		Case Else 'size
			WLet(WStrTmpPtr, "Size")
		End Select
	End Select
	Return *WStrTmpPtr
End Function

Private Property FilesSync.Summary() ByRef As WString
	Static WStrTmpPtr As WString Ptr
	
	Dim a() As WString Ptr
	Dim b() As WString Ptr
	Dim y As Long
	Dim x As Long
	
	ReDim a(13)
	ReDim b(2)
	For x = 0 To 2
		WLet(b(x), ReportData(x, -1))
	Next
	
	TitleWStr(a(0), 70, "-", *b(0), *b(1), *b(2))
	For y = 0 To 12
		For x = 0 To 2
			WLet(b(x), ReportData(x, y))
		Next
		TitleWStr(a(y + 1), 70, " ", *b(0), *b(1), *b(2))
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
	TitleWStr(a(0), 70, "-", "Setting Item", , "Set")
	
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
	TitleWStr(a(1), 70, " ", "Work Mode", , b & mThreadMode)
	
	If mSyncMode Then b = "Synchronization " Else b = "Duplication "
	TitleWStr(a(2), 70, " ", "Sync Mode", , b & mSyncMode)
	
	If mCopyEmptyPath Then b = "True " Else b = "False "
	TitleWStr(a(3), 70, " ", "Copy Empty Path", , b & mCopyEmptyPath)
	
	If mDuplicat Then b = "True " Else b = "False "
	TitleWStr(a(4), 70, " ", "Delete B Not In A", , b & mDuplicat)
	
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
	
	TitleWStr(a(5), 70, " ", "Overwrite Compare Data", , b & mCompareData)
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
	
	TitleWStr(a(6), 70, " ", "Overwrite Compare Mode", , b & mCompareMode)
	
	Select Case mLogMode
	Case 0
		b = "None "
	Case 1
		b = "Memory "
	Case 2
		b = "File "
	End Select
	TitleWStr(a(7), 70, " ", "Log Mode", , b & mLogMode)
	
	Static WStrTmpPtr As WString Ptr
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
	
	TitleWStr(a(0), 70, "-", "Step" , "Seconds", "Times")
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
		TitleWStr(a(i + 1), 70, " ", *mStepMessage(i), Format(d, "#,#0.000"), Sec2Time(d, , , "#00.000"))
	Next
	
	TitleWStr(a(mStepDoing + 3), 70, "-", "Description", "Size/Sec.", "Count/Sec.")
	
	TitleWStr(a(mStepDoing + 4), 70, " ", "Copy Speed", Bytes2Str(s(4)), Format(s(5), "#,#0"))
	TitleWStr(a(mStepDoing + 5), 70, " ", "Delete Speed", Bytes2Str(s(6)), Format(s(7), "#,#0"))
	
	TitleWStr(a(mStepDoing + 7), 70, " ", "Total Copy Speed", Bytes2Str(s(0)), Format(s(1), "#,#0"))
	TitleWStr(a(mStepDoing + 8), 70, " ", "Total Delete Speed", Bytes2Str(s(2)), Format(s(3), "#,#0"))
	
	Static WStrTmpPtr As WString Ptr
	
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
		WLet(b(0), ReportData(0, y))
		WLet(b(1), ReportData(1, y))
		WLet(b(2), ReportData(2, y))
		TitleWStr(a(y * 3), 70, "-", *b(0), *b(1), *b(2))
	Next
	y = 12
	WLet(b(0), ReportData(0, y))
	WLet(b(1), ReportData(1, y))
	WLet(b(2), ReportData(2, y))
	TitleWStr(a(24), 70, "-", *b(0), *b(1), *b(2))
	
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
			WLet(a(y * 3 + 1), WStr("Ongoing..."))
		Next
		WLet(a(25), WStr("Ongoing..."))
	End If
	
	Static rtnWstr As WString Ptr
	JoinWStr(a(), vbCrLf, rtnWstr)
	ArrayDeallocate(a())
	ArrayDeallocate(b())
	Return *rtnWstr
End Property

Private Property FilesSync.Report(Index As Integer) ByRef As WString
	Static WStrTmpPtr As WString Ptr
	
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
	
	TitleWStr(a(0), 80, "=", "Setting")
	TitleWStr(a(3), 80, "=", "Speed")
	TitleWStr(a(6), 80, "=", "Summary")
	TitleWStr(a(9), 80, "=", "Detials")
	WLet(a(1), Setting)
	WLet(a(4), Speed)
	WLet(a(7), Summary)
	WLet(a(10), DetialInfo)
	
	Static WStrTmpPtr As WString Ptr
	
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

Private Sub FilesSync.LogFile(LogMsg As WString)
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


