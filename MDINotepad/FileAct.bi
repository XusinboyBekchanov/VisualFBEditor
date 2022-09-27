#pragma once
' FileAct 文件处理
' Copyright (c) 2022 CM.Wang
' Freeware. Use at your own risk.

#include once "windows.bi"
#include once "Text.bi"
#include once "TimeMeter.bi"
#inclib "bcrypt"
#inclib "crypt32"
#include once "win/shlwapi.bi"
#include once "win/bcrypt.bi"
#include once "win/wincrypt.bi"

'文件夹和文件执行枚举
Enum PathFileActEnum
	Act_FileCopy = 1
	Act_FileOverwrite
	Act_FileDelete
	Act_FileDeleteBNotInA
	Act_PathCreate
	Act_PathRemove
	Act_PathRemoveBNotInA
End Enum

'计数枚举
Enum PathFileCountEnum
	Count_FileCopy = 1
	Count_FileOverwrite
	Count_FileSkip
	Count_FileDelete
	Count_PathCreate
	Count_PathRemove
	Count_FileDeleteBNotInA
	Count_PathRemoveBNotInA
	Count_File
	Count_Path
	Count_Error
End Enum

'FilesSync文件操作枚举
Enum FilesSyncMode
	FSM_PathSync = 1
	FSM_PathRemove
	FSM_PathCreate
End Enum

Type FilesSync
Private:
	'私有变量

	Const mFileInc As Integer = &hfffff '文件增量

	mOwner As Any Ptr = 0
	
	mPathA As WString Ptr = NULL
	mPathB As WString Ptr = NULL
	
	mDone As Long '主线程完成
	mCancel As Long '主线程取消
	
	mSyncThread As Any Ptr = NULL '主线程ID
	mThreadMode As FilesSyncMode '主模式: 同步，建立，移除
	
	mPercentThread As Any Ptr = NULL '提供计算进度百分比的线程ID

	mTiMr As TimeMeter '计时器
	mSyncTarget As WString Ptr = NULL '同步目标
	mSyncSource As WString Ptr = NULL '同步源
	
	WStrTmpPtr As WString Ptr '临时指针
	
	mListWFD(Any) As WIN32_FIND_DATA
	mListFile(Any) As WString Ptr
	mListFileCount As LongInt
	mListPath(Any) As WString Ptr
	mListPathCount As LongInt
	
	'记录
	mFileCopyCount As LongInt
	mFileCopy(Any) As WString Ptr
	mFileCopySize As LongInt
	
	mFileOverwriteCount As LongInt
	mFileOverwrite(Any) As WString Ptr
	mFileOverwriteSize As LongInt
	
	mFileSkipCount As LongInt
	mFileSkip(Any) As WString Ptr
	mFileSkipSize As LongInt
	
	mFileDeleteCount As LongInt
	mFileDelete(Any) As WString Ptr
	mFileDeleteSize As LongInt
	mPathRemoveCount As LongInt
	mPathRemove(Any) As WString Ptr
	
	mFileDeleteBNotInACount As LongInt
	mFileDeleteBNotInA(Any) As WString Ptr
	mFileDeleteBNotInASize As LongInt
	mPathRemoveBNotInACount As LongInt
	mPathRemoveBNotInA(Any) As WString Ptr
	
	mPathCreateCount As LongInt
	mPathCreate(Any) As WString Ptr
	
	mErrorMessageCount As LongInt
	mErrorMessage(Any) As WString Ptr
	
	'完成进度
	mPercentReady As Long '准备好
	mPercentCount As LongInt '完成全部数
	mPercentStep As LongInt '已完成数
	mPercentPath As WString Ptr = NULL '进度目录
	
	'完成步骤
	mStepDoing As Long '进行中步骤
	mStepCount As Long = -1 '总步骤
	mStepMessage(Any) As WString Ptr
	mStepTimeAdd As Double = -1
	mStepTime(Any) As Double

	mTotalCopySize As LongInt
	mTotalDeleteCount As LongInt
	mCopyTime As Double
	mDeleteTime As Double
	
Public:
	'设置
	mSyncMode As Long '目录模式：False单向复制、True双向同步
	mCopyEmptyPath As Long '复制空白目录
	mDuplicat As Long '删除不存在A中的B文件
	mCompareData As Long '重复文件是否复制比较数据
	mCompareMode As Long'重复文件是否复制比较模式
	mLogMode As Long '记录模式：0不记录、1内存、2文件
	mLogFile As WString Ptr '记录文件名
	mLogFileNum As Long '记录文件号
	
Private:
	
	'私有函数
	Declare Static Function PercentThread(ByVal pParam As LPVOID) As DWORD
	Declare Sub PercentSub(PathStr As WString)
	Declare Sub PercentDoing(PathStr As WString Ptr)

	Declare Sub SyncInit()
	Declare Static Function SyncThread(ByVal pParam As LPVOID) As DWORD
	Declare Sub SyncDoing()

	Declare Sub CountInc(CntIdx As PathFileCountEnum, IncMsg As WString Ptr)
	Declare Sub ErrorInc(ErrorTitle As WString, ErrorMsg As WString Ptr)
	Declare Sub ActFile(aType As PathFileActEnum, SourceStr As WString Ptr, TargetStr As WString Ptr, wfd As WIN32_FIND_DATA Ptr) 
	Declare Function ActPath(aType As PathFileActEnum, SourceStr As WString Ptr) As Long

	Declare Sub FileCopyAct(PathStr As WString Ptr, wfd As WIN32_FIND_DATA Ptr)
	Declare Sub DeleteBNotInA(PathStr As Const WString)
	
	Declare Sub PathCreate(PathStr As WString Ptr)
	Declare Sub PathRemoveSub(PathStr As WString)
	Declare Sub PathRemove(PathStr As WString Ptr)
	
	Declare Sub ListFile()
	Declare Sub ListFileSub(PathStr As WString)
	
	Declare Sub PathSyncSub(PathStr As Const WString)
	Declare Sub PathSync()
	
	Declare Sub StepInit(StepCount As LongInt, StepMsg As Const WString)
	Declare Sub StepInc(StepMsg As Const WString)
	
	Declare Sub LogFile(LogMsg As Const WString)
	Declare Function LogStr(Index As Long) ByRef As WString
	Declare Sub LogFileOpen()
	Declare Sub LogFileClose()
Public:
	'构造与析构函数
	Declare Constructor
	Declare Destructor
	'共有函数，类的事件
	OnDone As Sub(Owner As Any Ptr) '枚举完成事件
	'共有函数，类的方法
	Declare Function Sync(Owner As Any Ptr, SourceStr As WString, TargetStr As WString) As Integer
	Declare Function Remove(Owner As Any Ptr, PathStr As WString) As Integer
	Declare Function Create(Owner As Any Ptr, PathStr As WString) As Integer
	
	'共有函数，类的属性
	
	Declare Property ErrorCount() As Integer
	
	Declare Property Cancel() As Integer
	Declare Property Cancel(ByVal nVal As Integer)
	
	Declare Property Done() As Integer
	Declare Property Done(ByVal nVal As Integer)
	
	Declare Property Information() ByRef As WString
	Declare Property DetialInfo() ByRef As WString

	Declare Property Speed() ByRef As WString
	
	Declare Property PercentStep() As Double
	Declare Property PercentTotal() As Double
	
	Declare Property Setting() ByRef As WString
	Declare Property Summary() ByRef As WString
	Declare Property Report(Index As Integer) ByRef As WString
	Declare Function ReportData(x As Long, y As Long) ByRef As WString
	Declare Property TimePass() As Double
End Type

Type FilesFind
Private:
	'私有变量
	Const mFileInc As Integer = &h7fff
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
	
	'私有函数
	Declare Static Function ThreadProcedure(ByVal pParam As LPVOID) As DWORD
	Declare Sub ThreadDoing()
	Declare Sub ListFile(ByRef pathroot As Const WString, ByVal FilterIndex As Integer)
	Declare Sub ListPath(ByRef pathroot As Const WString, ByVal FilterIndex As Integer)
	Declare Sub ListFilePath(ByRef pathroot As Const WString, ByVal FilterIndex As Integer)
	
Public:
	Declare Sub Clear(ByVal Index As Integer = False)
	'构造与析构函数
'Declare Constructor
	Declare Destructor
	'共有函数，类的事件
	OnFindDone As Sub(Owner As Any Ptr, ByRef PathCount As LongInt, ByRef FileCount As LongInt, ByRef FileSize As LongInt) '枚举完成事件
	OnFindFile As Sub(Owner As Any Ptr, ByRef FileName As WString, ByRef PathCount As LongInt, ByRef FileCount As LongInt, ByRef FileSize As LongInt) '找到文件事件
	OnFindPath As Sub(Owner As Any Ptr, ByRef PathName As WString, ByRef PathCount As LongInt) '找到文件夹事件
	'共有函数，类的方法
	Declare Function Files(ByRef SplitStr As Const WString) ByRef As WString
	Declare Function FindFile(Owner As Any Ptr, ByRef rootpaths As Const WString, ByRef filters As Const WString, ByVal subDir As Integer = False, ByVal FindType As Integer = 0) As Integer
	Declare Function Paths(ByRef SplitStr As Const WString) ByRef As WString
	'共有函数，类的属性
	Declare Property Cancel() As Integer
	Declare Property Cancel(ByVal nVal As Integer)
	Declare Property Done() As Integer
	Declare Property File(ByVal Index As Integer) ByRef As WString
	Declare Property FileCount() As Integer
	Declare Property FileSize() As LongInt
	Declare Property Path(ByVal Index As Integer) ByRef As WString
	Declare Property PathCount() As Integer
End Type

#ifndef __USE_MAKE__
	#include once "FileAct.bas"
#endif
