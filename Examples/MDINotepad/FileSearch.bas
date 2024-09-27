' FileAct 文件处理
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#pragma once
#include once "FileSearch.bi"

Private Constructor FilesSearch
	
End Constructor

Private Destructor FilesSearch
	Clear(True)
End Destructor

Private Function FilesSearch.Paths(ByRef SplitStr As WString) ByRef As WString
	If mPathCount < 0 Then
	Else
		JoinWStr(mPaths(), SplitStr, mTmpPaths)
		Return *mTmpPaths
	End If
End Function

Private Function FilesSearch.Files(ByRef SplitStr As WString) ByRef As WString
	If mFileCount < 0 Then
	Else
		JoinWStr(mFiles(), SplitStr, mTmpFiles)
		Return *mTmpFiles
	End If
End Function

Private Sub FilesSearch.ListFile(ByRef pathroot As Const WString, ByVal FilterIndex As Integer)
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
				End If
				WLet(mFiles(tIndex), pathroot & "\" & wfd.cFileName)
				mFileSize += WFD2Bytes(@wfd)
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

Private Sub FilesSearch.ListPath(ByRef pathroot As Const WString, ByVal FilterIndex As Integer)
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
					End If
					WLet(mPaths(tIndex), pathroot & "\" & wfd.cFileName )
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

Private Sub FilesSearch.ListFilePath(ByRef pathroot As Const WString, ByVal FilterIndex As Integer)
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
					End If
					WLet(mPaths(tIndex), pathroot & "\" & wfd.cFileName)
					mPathCount += 1
				End If
			Else
				tIndex = mFileCount + 1
				If ((tIndex Mod mFileInc) = 0) Or (tIndex = 0) Then
					ReDim Preserve mFiles(mFileCount + mFileInc)
				End If
				WLet(mFiles(tIndex), pathroot & "\" & wfd.cFileName)
				mFileSize += WFD2Bytes(@wfd)
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

Private Function FilesSearch.FindFile(Owner As Any Ptr, rootpaths As WString, filters As WString, ByVal subDir As Integer = False, ByVal FindType As Integer = 0) As Integer
	mOwner = Owner
	mFindType = FindType
	WLet(mRootPaths, rootpaths)
	WLet(mFilters, filters)
	mSubDir = subDir
	mThread = ThreadCreate(Cast(Any Ptr, @FindThread) , @This)
	If mThread = NULL Then
		Return False
	Else
		Return True
	End If
End Function

Private Function FilesSearch.FindThread(ByVal pParam As Any Ptr) As Any Ptr
	Dim cFF As FilesSearch Ptr = Cast(FilesSearch Ptr , pParam)
	cFF->FindDoing()
	If cFF->OnFindDone Then cFF->OnFindDone(cFF->mOwner)
	Return 0
End Function

Private Sub FilesSearch.FindDoing()
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
End Sub

Private Sub FilesSearch.Clear(ByVal Index As Integer = False)
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

Private Property FilesSearch.FileCount() As Integer
	Return mFileCount
End Property

Private Property FilesSearch.PathCount() As Integer
	Return mPathCount
End Property

Private Property FilesSearch.FileSize() As LongInt
	Return mFileSize
End Property

Private Property FilesSearch.File(Index As Integer) ByRef As WString
	If mFileCount < 0 Then Return ""
	If mFileCount < Index Then Return ""
	Return *mFiles(Index)
End Property

Private Property FilesSearch.Path(Index As Integer) ByRef As WString
	If mPathCount < 0 Then Return ""
	If mPathCount < Index Then Return ""
	Return *mPaths(Index)
End Property

Private Property FilesSearch.Cancel() As Integer
	Return mCancel
End Property

Private Property FilesSearch.Cancel(ByVal nVal As Integer)
	mCancel = True
End Property

Private Property FilesSearch.Done() As Integer
	Return mDone
End Property

