#pragma once
' FileAct 文件处理
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "FileAct.bi"

Type FilesSearch
Private:
	'私有变量
	Const mFileInc As Integer = &hfffff
	'私有函数
	Declare Static Function FindThread(ByVal pParam As Any Ptr) As Any Ptr
	Declare Sub FindDoing()
	
Public:
	mCancel As Integer
	mDone As Integer
	mFileCount As LongInt = -1
	mFiles(Any) As WString Ptr
	mFileSize As LongInt = 0
	mFilter(Any) As WString Ptr
	mFilterCount As LongInt = 0
	mFilters As WString Ptr = 0
	mOwner As Any Ptr = 0
	mPathCount As LongInt = -1
	mPaths(Any) As WString Ptr
	mRootPath(Any) As WString Ptr
	mRootPathCount As LongInt = 0
	mRootPaths As WString Ptr = 0
	mSubDir As Integer = False
	mThread As Any Ptr '线程ID
	mTmpFiles As WString Ptr = 0
	mTmpPaths As WString Ptr = 0
	mFindType As Integer = 0
	
	Declare Sub ListFile(ByRef pathroot As Const WString, ByVal FilterIndex As Integer)
	Declare Sub ListPath(ByRef pathroot As Const WString, ByVal FilterIndex As Integer)
	Declare Sub ListFilePath(ByRef pathroot As Const WString, ByVal FilterIndex As Integer)
	
Public:
	'构造与析构函数
	Declare Constructor
	Declare Destructor
	'枚举完成事件
	OnFindDone As Sub(Owner As Any Ptr) 
	Declare Function Files(ByRef SplitStr As WString) ByRef As WString
	Declare Function FindFile(Owner As Any Ptr, rootpaths As WString, filters As WString, ByVal subDir As Integer = False, ByVal FindType As Integer = 0) As Integer
	Declare Function Paths(ByRef SplitStr As WString) ByRef As WString
	Declare Property Cancel() As Integer
	Declare Property Cancel(ByVal nVal As Integer)
	Declare Property Done() As Integer
	Declare Property File(ByVal Index As Integer) ByRef As WString
	Declare Property FileCount() As Integer
	Declare Property FileSize() As LongInt
	Declare Property Path(ByVal Index As Integer) ByRef As WString
	Declare Property PathCount() As Integer
	Declare Sub Clear(ByVal Index As Integer = False)
End Type

#ifndef __USE_MAKE__
	#include once "FileSearch.bas"
#endif
