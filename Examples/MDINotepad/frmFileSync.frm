'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "FileSync.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Panel.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/RadioButton.bi"
	#include once "mff/TimerComponent.bi"
	#include once "mff/ListView.bi"
	#include once "mff/ProgressBar.bi"
	#include once "mff/ImageList.bi"
	#include once "mff/ComboBoxEx.bi"
	#include once "mff/Chart.bi"
	#include once "mff/GroupBox.bi"
	#include once "mff/Dialogs.bi"
	
	#include once "ITL3.bi"
	#include once "TimeMeter.bi"
	#include once "FileAct.bi"
	
	Using My.Sys.Forms
	
	Type frmFileSyncType Extends Form
		Dim fpsync As FilesSync
		Dim it3 As ITL3
		
		Declare Static Sub zOnFPSyncDone(Owner As Any Ptr)
		Declare Sub zInitial()
		Declare Sub zControlEnabled(Enabled As Boolean, SetProfile As Long)
		Declare Sub zPathSelect(ByRef Sender As ComboBoxEx)
		Declare Function zFile2ComboEx (ByRef Sender As ComboBoxEx, ByRef Path As Const WString) As Integer
		
		Declare Sub zSettingSave(ByRef FileName As Const WString)
		Declare Sub zSettingLoad(ByRef FileName As Const WString)
		
		Declare Sub cmdButton_Click(ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Sub ListView1_ItemClick(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub cmbexSetProfile_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub cmbexCompareData_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub rbtnLogFile_Click(ByRef Sender As RadioButton)
		Declare Sub cmbexAPath_DblClick(ByRef Sender As Control)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub cmbexProfile_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Constructor
		
		Dim As TextBox txtLogFile, txtLogText
		Dim As CommandButton cmdAPath, cmdBPath, cmdPathBRemove, cmdPathBCreate, cmdPathBWFD, cmdCancel, cmdStart, cmdProfileSave, cmdProfileDel, cmdProfileFresh
		Dim As Panel Panel1, Panel2, Panel4, Panel3, Panel5
		Dim As CheckBox chkCpyEmptyPath
		Dim As RadioButton rbtnIncrement, rbtnDuplication, rbtnSynchronization, rbtnLogNothing, rbtnLogMemory, rbtnLogFile
		Dim As ListView ListView1
		Dim As ProgressBar ProgressBar1
		Dim As ComboBoxEx cmbexAPath, cmbexBPath, cmbexCompareData, cmbexCompareMode, cmbexSetProfile, cmbexProfile, cmbexDone
		Dim As GroupBox GroupBox1
		Dim As FolderBrowserDialog FolderBrowserDialog1
		Dim As TimerComponent TimerComponent1
		Dim As ImageList ImageList1
	End Type
	
	Constructor frmFileSyncType
		' frmFileSync
		With This
			.Name = "frmFileSync"
			.Text = "File Sync"
			.Designer = @This
			.StartPosition = FormStartPosition.CenterScreen
			#ifdef __USE_GTK__
				This.Icon.LoadFromFile(ExePath & "Hash.ico")
			#else
				This.Icon.LoadFromResourceID(1)
			#endif
			#ifdef __FB_64BIT__
				'...instructions for 64bit OSes...
				.Caption = "VFBE File Sync64"
			#else
				'...instructions for other OSes
				.Caption = "VFBE File Sync32"
			#endif
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.SetBounds 0, 0, 1000, 630
		End With
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = "Panel1"
			.TabIndex = 0
			.Align = DockStyle.alLeft
			.ExtraMargins.Top = 10
			.ExtraMargins.Left = 10
			.ExtraMargins.Right = 10
			.ExtraMargins.Bottom = 10
			.SetBounds 8, 8, 440, 633
			.Designer = @This
			.Parent = @This
		End With
		' Panel2
		With Panel2
			.Name = "Panel2"
			.Text = "Panel2"
			.TabIndex = 1
			.Align = DockStyle.alTop
			.SetBounds 0, 0, 440, 231
			.Designer = @This
			.Parent = @Panel1
		End With
		' Panel3
		With Panel3
			.Name = "Panel3"
			.Text = "Panel4"
			.TabIndex = 2
			.Align = DockStyle.alBottom
			.SetBounds 0, 481, 440, 90
			.Designer = @This
			.Parent = @Panel1
		End With
		' Panel4
		With Panel4
			.Name = "Panel4"
			.Text = "Panel3"
			.TabIndex = 3
			.Align = DockStyle.alNone
			.SetBounds 150, 110, 140, 80
			.Designer = @This
			.Parent = @Panel2
		End With
		' Panel5
		With Panel5
			.Name = "Panel5"
			.Text = "Panel5"
			.TabIndex = 4
			.Align = DockStyle.alNone
			.SetBounds 300, 110, 140, 80
			.Designer = @This
			.Parent = @Panel2
		End With
		' GroupBox1
		With GroupBox1
			.Name = "GroupBox1"
			.Text = "Overwirte"
			.TabIndex = 5
			.Caption = "Overwirte"
			.SetBounds 0, 110, 140, 110
			.Designer = @This
			.Parent = @Panel2
		End With
		' cmdAPath
		With cmdAPath
			.Name = "cmdAPath"
			.Text = "A"
			.TabIndex = 6
			.Caption = "A"
			.SetBounds 0, 0, 30, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdButton_Click)
			.Parent = @Panel2
		End With
		' cmbexAPath
		With cmbexAPath
			.Name = "cmbexAPath"
			.Text = "cmbexAPath"
			.TabIndex = 7
			.Style = ComboBoxEditStyle.cbDropDown
			.ImagesList = @ImageList1
			.Hint = "Source Path A"
			.IntegralHeight = False
			.ItemHeight = 18
			.SetBounds 30, 0, 410, 22
			.Designer = @This
			.OnDblClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmbexAPath_DblClick)
			.Parent = @Panel2
		End With
		' ProgressBar1
		With ProgressBar1
			.Name = "ProgressBar1"
			.Text = "ProgressBar1"
			.Marquee = True
			.SetBounds 0, 30, 440, 3
			.Designer = @This
			.Parent = @Panel2
		End With
		' cmbexBPath
		With cmbexBPath
			.Name = "cmbexBPath"
			.Text = "cmbexBPath"
			.TabIndex = 9
			.Style = ComboBoxEditStyle.cbDropDown
			.ImagesList = @ImageList1
			.Hint = "Target Path B"
			.IntegralHeight = False
			.ItemHeight = 18
			.SetBounds 30, 40, 410, 22
			.Designer = @This
			.OnDblClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmbexAPath_DblClick)
			.Parent = @Panel2
		End With
		' cmdPathBRemove
		With cmdPathBRemove
			.Name = "cmdPathBRemove"
			.Text = "Path B Remove"
			.TabIndex = 10
			.Caption = "Path B Remove"
			.SetBounds 0, 70, 140, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdButton_Click)
			.Parent = @Panel2
		End With
		' cmdPathBCreate
		With cmdPathBCreate
			.Name = "cmdPathBCreate"
			.Text = "Path B Create"
			.TabIndex = 11
			.Caption = "Path B Create"
			.SetBounds 150, 70, 140, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdButton_Click)
			.Parent = @Panel2
		End With
		' cmdPathBWFD
		With cmdPathBWFD
			.Name = "cmdPathBWFD"
			.Text = "Get WFD"
			.TabIndex = 12
			.Caption = "Get WFD"
			.SetBounds 300, 70, 140, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdButton_Click)
			.Parent = @Panel2
		End With
		' cmbexCompareData
		With cmbexCompareData
			.Name = "cmbexCompareData"
			.Text = "cmbexCompareData"
			.TabIndex = 8
			.ImagesList = @ImageList1
			.IntegralHeight = False
			.ItemHeight = 13
			.SetBounds 10, 30, 120, 22
			.Designer = @This
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @cmbexCompareData_Selected)
			.Parent = @GroupBox1
		End With
		' cmbexCompareMode
		With cmbexCompareMode
			.Name = "cmbexCompareMode"
			.Text = "cmbexCompareMode"
			.TabIndex = 14
			.ImagesList = @ImageList1
			.IntegralHeight = False
			.ItemHeight = 18
			.SetBounds 10, 70, 120, 22
			.Designer = @This
			.Parent = @GroupBox1
		End With
		' rbtnIncrement
		With rbtnIncrement
			.Name = "rbtnIncrement"
			.Text = "Increment"
			.TabIndex = 15
			.Caption = "Increment"
			.Checked = True
			.SetBounds 0, 0, 120, 20
			.Designer = @This
			.Parent = @Panel4
		End With
		' rbtnDuplication
		With rbtnDuplication
			.Name = "rbtnDuplication"
			.Text = "Duplication"
			.TabIndex = 16
			.Caption = "Duplication"
			.SetBounds 0, 20, 120, 20
			.Designer = @This
			.Parent = @Panel4
		End With
		' rbtnSynchronization
		With rbtnSynchronization
			.Name = "rbtnSynchronization"
			.Text = "Synchronization"
			.TabIndex = 17
			.Caption = "Synchronization"
			.SetBounds 0, 40, 120, 20
			.Designer = @This
			.Parent = @Panel4
		End With
		' chkCpyEmptyPath
		With chkCpyEmptyPath
			.Name = "chkCpyEmptyPath"
			.Text = "Copy empty path"
			.TabIndex = 18
			.Caption = "Copy empty path"
			.Checked = True
			.Align = DockStyle.alBottom
			.SetBounds 0, 60, 140, 20
			.Designer = @This
			.Parent = @Panel4
		End With
		' rbtnLogNothing
		With rbtnLogNothing
			.Name = "rbtnLogNothing"
			.Text = "Log nothing"
			.TabIndex = 19
			.Caption = "Log nothing"
			.Checked = True
			.SetBounds 0, 0, 120, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @rbtnLogFile_Click)
			.Parent = @Panel5
		End With
		' rbtnLogMemory
		With rbtnLogMemory
			.Name = "rbtnLogMemory"
			.Text = "Log memory"
			.TabIndex = 20
			.Caption = "Log memory"
			.Checked = False
			.SetBounds 0, 20, 120, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @rbtnLogFile_Click)
			.Parent = @Panel5
		End With
		' rbtnLogFile
		With rbtnLogFile
			.Name = "rbtnLogFile"
			.Text = "Log file"
			.TabIndex = 21
			.Caption = "Log file"
			.Enabled = True
			.SetBounds 0, 40, 120, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @rbtnLogFile_Click)
			.Parent = @Panel5
		End With
		' txtLogFile
		With txtLogFile
			.Name = "txtLogFile"
			.Text = "FileSync.log"
			.TabIndex = 22
			.Enabled = False
			.Align = DockStyle.alBottom
			.SetBounds 0, 60, 130, 20
			.Designer = @This
			.Parent = @Panel5
		End With
		' ListView1
		With ListView1
			.Name = "ListView1"
			.Text = "ListView1"
			.TabIndex = 23
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 0
			.ExtraMargins.Left = 0
			.ExtraMargins.Bottom = 0
			.GridLines = True
			.BorderStyle = BorderStyles.bsClient
			.BorderSelect = False
			.Images = @ImageList1
			.SmallImages = @ImageList1
			.SetBounds 0, 211, 440, 270
			.Designer = @This
			.OnItemClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer), @ListView1_ItemClick)
			.Parent = @Panel1
		End With
		' cmbexProfile
		With cmbexProfile
			.Name = "cmbexProfile"
			.Text = ""
			.TabIndex = 24
			.ImagesList = @ImageList1
			.Style = ComboBoxEditStyle.cbDropDown
			.SetBounds 0, 20, 290, 22
			.Designer = @This
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @cmbexProfile_Selected)
			.Parent = @Panel3
		End With
		' cmdProfileSave
		With cmdProfileSave
			.Name = "cmdProfileSave"
			.Text = "Save"
			.TabIndex = 25
			.Caption = "Save"
			.SetBounds 300, 20, 40, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdButton_Click)
			.Parent = @Panel3
		End With
		' cmdProfileDel
		With cmdProfileDel
			.Name = "cmdProfileDel"
			.Text = "Del"
			.TabIndex = 26
			.Caption = "Del"
			.SetBounds 350, 20, 40, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdButton_Click)
			.Parent = @Panel3
		End With
		' cmdProfileFresh
		With cmdProfileFresh
			.Name = "cmdProfileFresh"
			.Text = "Fresh"
			.TabIndex = 27
			.Caption = "Fresh"
			.SetBounds 400, 20, 40, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdButton_Click)
			.Parent = @Panel3
		End With
		' cmbexSetProfile
		With cmbexSetProfile
			.Name = "cmbexSetProfile"
			.Text = "cmbexSetProfile"
			.TabIndex = 28
			.ImagesList = @ImageList1
			.IntegralHeight = False
			.ItemHeight = 18
			.SetBounds 0, 68, 140, 22
			.Designer = @This
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @cmbexSetProfile_Selected)
			.Parent = @Panel3
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = "Cancel"
			.TabIndex = 29
			.Caption = "Cancel"
			.Enabled = False
			.SetBounds 150, 68, 140, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdButton_Click)
			.Parent = @Panel3
		End With
		' cmdStart
		With cmdStart
			.Name = "cmdStart"
			.Text = "Start"
			.TabIndex = 30
			.Caption = "Start"
			.Enabled = True
			.SetBounds 300, 68, 140, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdButton_Click)
			.Parent = @Panel3
		End With
		' txtLogText
		With txtLogText
			.Name = "txtLogText"
			.Text = "txtLogText"
			.TabIndex = 31
			.Align = DockStyle.alClient
			.Multiline = True
			.ScrollBars = ScrollBarsType.Both
			.ExtraMargins.Top = 10
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 0
			.ExtraMargins.Bottom = 10
			.Font.Name = "Consolas"
			.SetBounds 180, 10, 514, 531
			.Designer = @This
			.Parent = @This
		End With
		' cmbexDone
		With cmbexDone
			.Name = "cmbexDone"
			.Text = "cmbexDone"
			.TabIndex = 32
			.Hint = "Action after done"
			.ImagesList = @ImageList1
			.SetBounds 150, 200, 290, 22
			.Designer = @This
			.Parent = @Panel2
		End With
		' TimerComponent1
		With TimerComponent1
			.Name = "TimerComponent1"
			.Interval = 500
			.SetBounds 330, 22, 16, 16
			.Designer = @This
			.OnTimer = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent), @TimerComponent1_Timer)
			.Parent = @Panel2
		End With
		' ImageList1
		With ImageList1
			.Name = "ImageList1"
			.SetBounds 300, 22, 16, 16
			.Designer = @This
			.Parent = @Panel1
		End With
		' FolderBrowserDialog1
		With FolderBrowserDialog1
			.Name = "FolderBrowserDialog1"
			.SetBounds 360, 22, 16, 16
			.Designer = @This
			.Parent = @Panel2
		End With
		' cmdBPath
		With cmdBPath
			.Name = "cmdBPath"
			.Text = "B"
			.TabIndex = 28
			.ControlIndex = 10
			.SetBounds 0, 40, 30, 22
			.Designer = @This
			.Parent = @Panel2
		End With
	End Constructor
	
	Dim Shared frmFileSync As frmFileSyncType
	
	#if _MAIN_FILE_ = __FILE__
		frmFileSync.MainForm = True
		frmFileSync.Show
		
		App.Run
	#endif
'#End Region

Private Sub frmFileSyncType.zSettingLoad(ByRef FileName As Const WString)
	Dim cp As Integer = -1
	Dim s As WString Ptr
	Dim ss() As WString Ptr
	Dim tt() As WString Ptr
	Dim i As Integer
	Dim j As Integer
	Dim k As Integer
	Dim l As Integer
	Dim c As ComboBoxEx Ptr
	
	cmbexAPath.Text = ""
	cmbexBPath.Text = ""
	cmbexAPath.Items.Clear
	cmbexBPath.Items.Clear
	
	If PathFileExists(FileName) Then
		WStr2Ptr(TextFromFile(FileName, FileEncodings.Utf8BOM, NewLineTypes.WindowsCRLF, cp), s)
		l = SplitWStr(*s, !"\r\n[Split]\r\n", ss())
		For i = 0 To 1
			k = SplitWStr(*ss(i), !"\r\n", tt())
			If i = 0 Then
				c = @cmbexAPath
			Else
				c = @cmbexBPath
			End If
			For j = 0 To k
				If PathFileExists(*tt(j)) Then zFile2ComboEx(*c, *tt(j))
			Next
		Next
		
		cmbexAPath.ItemIndex = 0
		cmbexBPath.ItemIndex = 0
		
		ArrayDeallocate(ss())
		ArrayDeallocate(tt())
		If s Then Deallocate(s)
	End If
End Sub

Private Sub frmFileSyncType.zSettingSave(ByRef FileName As Const WString)
	Dim cp As Integer = -1
	Dim s As WString Ptr
	Dim ss() As WString Ptr
	Dim tt() As WString Ptr
	Dim i As Integer
	Dim j As Integer
	Dim k As Integer
	Dim l As Integer
	Dim c As ComboBoxEx Ptr
	
	ReDim ss(1)
	For i = 0 To 1
		If i = 0 Then
			c = @cmbexAPath
		Else
			c = @cmbexBPath
		End If
		ArrayDeallocate(tt())
		k = c->ItemCount - 1
		If k < 0 Then
			WStr2Ptr("", ss(i))
		Else
			ReDim tt(k)
			For j = 0 To k
				WStr2Ptr(c->Item(j), tt(j))
			Next
			JoinWStr(tt(), !"\r\n", ss(i))
		End If
	Next
	
	JoinWStr(ss(), !"\r\n[Split]\r\n", s)
	TextToFile(FileName, *s, FileEncodings.Utf8BOM, NewLineTypes.WindowsCRLF, cp)
	ArrayDeallocate(tt())
	ArrayDeallocate(ss())
	If s Then Deallocate(s)
End Sub

Private Function frmFileSyncType.zFile2ComboEx(ByRef Sender As ComboBoxEx, ByRef Path As Const WString) As Integer
	Dim i As Integer = Sender.IndexOf("" + Path)
	Dim j As Integer
	If Sender.Name = "cmbexAPath" Then
		If InStr(Path, "\\") Then j = 273 Else j = 38
	Else
		If InStr(Path, "\\") Then j = 88 Else j = 19
	End If
	If i < 0 Then
		Sender.Items.Add(Path + "", , j, j, j)
		i = Sender.IndexOf(Path + "")
	End If
	Return i
End Function

Private Sub frmFileSyncType.zPathSelect(ByRef Sender As ComboBoxEx)
	Dim j As Long
	
	FolderBrowserDialog1.InitialDir = Sender.Text
	If FolderBrowserDialog1.Execute() Then
		If Sender.Name = "cmbexAPath" Then
			If InStr(FolderBrowserDialog1.Directory, "\\") Then j = 273 Else j = 38
		Else
			If InStr(FolderBrowserDialog1.Directory, "\\") Then j = 88 Else j = 19
		End If
		Sender.Items.Add("" + FolderBrowserDialog1.Directory, , j, j, j)
		Sender.Text = FolderBrowserDialog1.Directory
	End If
End Sub

Private Sub frmFileSyncType.zControlEnabled(Enabled As Boolean, SetProfile As Long)
	Dim nb As Boolean
	Dim bb As Boolean
	
	If Enabled Then
		If SetProfile = 3 Then
			bb = Enabled
		Else
			bb = False
		End If
		nb = False
	Else
		nb = True
	End If
	
	cmbexAPath.Enabled = Enabled
	cmbexBPath.Enabled = Enabled
	cmbexSetProfile.Enabled = Enabled
	cmbexCompareData.Enabled = bb
	cmbexCompareMode.Enabled = bb
	GroupBox1.Enabled = bb
	cmdPathBRemove.Enabled = Enabled
	cmdPathBCreate.Enabled = Enabled
	cmdPathBWFD.Enabled = Enabled
	cmdStart.Enabled = Enabled
	cmdCancel.Enabled = nb
	cmdAPath.Enabled = Enabled
	cmdBPath.Enabled = Enabled
	chkCpyEmptyPath.Enabled = bb
	rbtnIncrement.Enabled = bb
	rbtnDuplication.Enabled = bb
	rbtnSynchronization.Enabled = bb
	rbtnLogNothing.Enabled = Enabled
	rbtnLogMemory.Enabled = Enabled
	rbtnLogFile.Enabled = Enabled
	TimerComponent1.Enabled = nb
	
	cmbexProfile.Enabled = Enabled
	cmdProfileSave.Enabled = Enabled
	cmdProfileDel.Enabled = Enabled
	cmbexDone.Enabled = Enabled
	cmdProfileFresh.Enabled = Enabled
	
	If Enabled Then TimerComponent1_Timer(TimerComponent1)
End Sub

Private Sub frmFileSyncType.zInitial()
	it3.SetState(TBPF_NOPROGRESS)
	it3.SetValue(0, 100)
	ProgressBar1.SetMarquee(True, 50)
	ProgressBar1.Marquee= False
	ProgressBar1.Visible= True
	ProgressBar1.Position = 0
	txtLogText.Text = ""
	Dim i As Long
	Dim j As Long = 0
	For i = 0 To 12
		ListView1.ListItems.Item(i)->Text(1) = ""
		ListView1.ListItems.Item(i)->Text(2) = ""
	Next
End Sub

Private Sub frmFileSyncType.zOnFPSyncDone(Owner As Any Ptr)
	Dim a As frmFileSyncType Ptr = Cast(frmFileSyncType Ptr, Owner)
	a->zControlEnabled(True, a->cmbexSetProfile.ItemIndex)
	If a->fpsync.Cancel Then Exit Sub
	Debug.Print "Action after down: " & a->cmbexDone.ItemIndex
	
	Dim hPorc As Any Ptr
	Dim hToken As Any Ptr
	Dim mLUID As LUID
	Dim mPriv As TOKEN_PRIVILEGES
	Dim mNewPriv As TOKEN_PRIVILEGES

	Select Case a->cmbexDone.ItemIndex
	Case 2, 3, 4
		hPorc = GetCurrentProcess()
		If OpenProcessToken(hPorc, TOKEN_ADJUST_PRIVILEGES Or TOKEN_QUERY, @hToken) Then
			If LookupPrivilegeValue(NULL, @"SeShutdownPrivilege", @mLUID) Then
				mPriv.PrivilegeCount = 1
				mPriv.Privileges(0).Attributes = SE_PRIVILEGE_ENABLED
				mPriv.Privileges(0).Luid = mLUID
				AdjustTokenPrivileges(hToken, False, @mPriv, SizeOf(mPriv), NULL, NULL)
				CloseHandle(hToken)
			End If
		End If
	End Select
	
	Select Case a->cmbexDone.ItemIndex
	Case 1 'exit
		a->CloseForm
	Case 2 'logoff
		ExitWindowsEx EWX_LOGOFF Or EWX_FORCE , 0
	Case 3 'reboot
		ExitWindowsEx(EWX_REBOOT Or EWX_FORCE, SHTDN_REASON_MAJOR_APPLICATION Or SHTDN_REASON_MINOR_MAINTENANCE Or SHTDN_REASON_FLAG_PLANNED)
	Case 4 'shutdown
		ExitWindowsEx(EWX_SHUTDOWN Or EWX_FORCE, SHTDN_REASON_MAJOR_APPLICATION Or SHTDN_REASON_MINOR_MAINTENANCE Or SHTDN_REASON_FLAG_PLANNED)
	End Select
End Sub

Private Sub frmFileSyncType.Form_Create(ByRef Sender As Control)
	fpsync.OnDone = @zOnFPSyncDone
	
	it3.Initial Handle
	
	Dim i As Long
	Dim j As Long
	Dim Icon As HICON
	
	j = ExtractIconEx("C:\Windows\System32\shell32.dll", -1, 0, 0, 1)
	For i = 0 To j
		ExtractIconEx "C:\Windows\System32\shell32.dll", i, 0, @Icon, 1
		ImageList_ReplaceIcon(ImageList1.Handle, -1, Icon)
		DestroyIcon Icon
	Next
	
	Dim a1(2) As Long = {150, 100, 180}
	Dim a2(12) As Long = {134, 132, 65, 152, 271, 19, 234, 45, 151, 165, 21, 221, 233}
	
	ListView1.ListItems.Clear
	ListView1.Columns.Clear
	With fpsync
		For i = 0 To 2
			ListView1.Columns.Add(.ReportData(i, -1),0 , a1(i))
		Next
		
		For i = 0 To 12
			ListView1.ListItems.Add(.ReportData(0, i), a2(i)) '1
		Next
	End With
	ListView1.SelectedItemIndex = 11
	
	zSettingLoad(FullName2Path(App.FileName) & "\FileSync.Path")
	
	cmbexSetProfile.Items.Clear
	cmbexSetProfile.Items.Add("Increment", , 19, 19, 19)
	cmbexSetProfile.Items.Add("Duplication", , 3, 3, 3)
	cmbexSetProfile.Items.Add("Synchronization", , 238, 238, 238)
	cmbexSetProfile.Items.Add("Customization", , 110, 110, 110)
	cmbexSetProfile.ItemIndex = 1
	
	cmbexCompareData.Items.Clear
	cmbexCompareData.Items.Add("Size", , 1, 1, 1)
	cmbexCompareData.Items.Add("Last Write Time", , 20, 20, 20)
	cmbexCompareData.Items.Add("Creation Time", , 20, 20, 20)
	cmbexCompareData.Items.Add("Last Access Time", , 20, 20, 20)
	cmbexCompareData.ItemIndex = 1
	cmbexCompareData_Selected(cmbexCompareData, 1)
	
	cmbexDone.Items.Clear
	cmbexDone.Items.Add("Do nothing", , 0, 0, 0)
	cmbexDone.Items.Add("Exit", , 112, 112, 112)
	cmbexDone.Items.Add("Logoff", , 160, 160, 160)
	cmbexDone.Items.Add("Reboot", , 151, 151, 151)
	cmbexDone.Items.Add("Shutdown", , 122, 122, 122)
	cmbexDone.ItemIndex = 0
	
	#ifdef __FB_64BIT__
		rbtnLogNothing.Checked = False
		rbtnLogMemory.Checked = True
	#else
		rbtnLogNothing.Checked = True
		rbtnLogMemory.Checked = False
	#endif
	
	cmbexSetProfile_Selected(cmbexSetProfile, 1)
	zControlEnabled(True, cmbexSetProfile.ItemIndex)
	
	cmdButton_Click(cmdProfileFresh)
	
	zInitial()
	
	#ifdef __MDI__
		Exit Sub
	#endif
	
	If Len(Command(1)) = 0 Then Exit Sub
	
	i = cmbexProfile.Items.IndexOf(Command(1))
	If i < 0 Then Exit Sub
	
	'command line is profile, then autorun profile
	cmbexProfile.ItemIndex = i
	cmbexProfile_Selected cmbexProfile, i
	
	cmdButton_Click cmdStart
End Sub

Private Sub frmFileSyncType.cmdButton_Click(ByRef Sender As Control)
	'	timr.Start
	zInitial()
	With fpsync
		Select Case Sender.Name
		Case "cmdAPath"
			zPathSelect(cmbexAPath)
		Case "cmdBPath"
			zPathSelect(cmbexBPath)
		Case "cmdPathBRemove"
			zControlEnabled(False, cmbexSetProfile.ItemIndex)
			.Remove(@This, cmbexBPath.Text)
		Case "cmdPathBCreate"
			zControlEnabled(False, cmbexSetProfile.ItemIndex)
			.Create(@This, cmbexBPath.Text)
		Case "cmdPathBWFD"
			Dim wfd As WIN32_FIND_DATA
			Dim b As WString Ptr
			Dim a() As WString Ptr
			ReDim a(9)
			
			WStrTitle(80, "=", cmbexBPath.Text, , , a(0))
			WStrTitle(80, " ", "PathFileExists", , "" & PathFileExists(cmbexBPath.Text), a(1))
			WStrTitle(80, " ", "WFDGet", , "" & WFDGet(cmbexBPath.Text, @wfd), a(2))
			WStrTitle(80, " ", "Creation Time", , Format(WFD2TimeSerial(@wfd.ftCreationTime), "yyyy/mm/dd hh:mm:ss"), a(3))
			WStrTitle(80, " ", "Access Time", , Format(WFD2TimeSerial(@wfd.ftLastAccessTime), "yyyy/mm/dd hh:mm:ss"), a(4))
			WStrTitle(80, " ", "Write Time", , Format(WFD2TimeSerial(@wfd.ftLastWriteTime), "yyyy/mm/dd hh:mm:ss"), a(5))
			WStrTitle(80, " ", "Size", Format(WFD2Size(@wfd), "#,#0"), Number2Str(WFD2Size(@wfd), "#0.00"), a(6))
			WStrTitle(80, " ", "AlternateFileName", , wfd.cAlternateFileName, a(7))
			WStrTitle(80, " ", "FileName", , wfd.cFileName, a(8))
			WStrTitle(80, " ", "FileAttributes", , Hex(wfd.dwFileAttributes), a(9))
			JoinWStr(a(), vbCrLf, b)
			txtLogText.Text = *b
			ArrayDeallocate(a())
			If b Then Deallocate(b)
		Case "cmdCancel"
			.Cancel = True
		Case "cmdStart"
			.mCopyEmptyPath = chkCpyEmptyPath.Checked
			.mDuplicat = rbtnDuplication.Checked
			.mSyncMode = rbtnSynchronization.Checked
			.mCompareData = cmbexCompareData.ItemIndex
			.mCompareMode = cmbexCompareMode.ItemIndex
			If rbtnLogNothing.Checked Then
				.mLogMode = 0
			End If
			If rbtnLogMemory.Checked Then
				.mLogMode = 1
			End If
			If rbtnLogFile.Checked Then
				.mLogMode = 2
			End If
			WStr2Ptr(txtLogFile.Text, .mLogFile)
			zControlEnabled(False, cmbexSetProfile.ItemIndex)
			.Sync (@This, cmbexAPath.Text, cmbexBPath.Text)
		Case "cmdProfileSave"
			Dim i As Integer = cmbexProfile.ItemIndex
			Dim cp As Integer = -1
			Dim s As String = cmbexProfile.Text
			If s <> "" Then
				Dim f As String = FullName2Path(App.FileName) & "\" & s & ".profile"
				Dim ss() As WString Ptr
				Dim t As WString Ptr
				ReDim ss(13)
				
				WStr2Ptr("Set Profile=" & cmbexSetProfile.ItemIndex, ss(0))
				WStr2Ptr("A Path=" & cmbexAPath.Text, ss(1))
				WStr2Ptr("B Path=" & cmbexBPath.Text, ss(2))
				WStr2Ptr("Compare Data=" & cmbexCompareData.ItemIndex, ss(3))
				WStr2Ptr("Compare Mode=" & cmbexCompareMode.ItemIndex, ss(4))
				WStr2Ptr("Increment=" & rbtnIncrement.Checked, ss(5))
				WStr2Ptr("Duplication=" & rbtnDuplication.Checked, ss(6))
				WStr2Ptr("Synchronization=" & rbtnSynchronization.Checked, ss(7))
				WStr2Ptr("Copy Empty Path=" & chkCpyEmptyPath.Checked, ss(8))
				WStr2Ptr("Log Nothing=" & rbtnLogNothing.Checked, ss(9))
				WStr2Ptr("Log Memory=" & rbtnLogMemory.Checked, ss(10))
				WStr2Ptr("Log File=" & rbtnLogFile.Checked, ss(11))
				WStr2Ptr("Log FileName=" & txtLogFile.Text, ss(12))
				WStr2Ptr("Action after Done=" & cmbexDone.ItemIndex, ss(13))
				
				JoinWStr(ss(), vbCrLf, t)
				
				TextToFile(f, *t, FileEncodings.Utf8BOM, NewLineTypes.WindowsCRLF, cp)
				cmdButton_Click(cmdProfileFresh)
				i = cmbexProfile.IndexOf(s)
				If i > -1 Then cmbexProfile.ItemIndex = i
				ArrayDeallocate(ss())
				If t Then Deallocate(t)
			End If
		Case "cmdProfileDel"
			Dim i As Integer = cmbexProfile.ItemIndex
			Dim s As String = cmbexProfile.Text
			If s <> "" Then
				Dim f As String = s & ".profile"
				Kill(f)
				cmdButton_Click(cmdProfileFresh)
				Dim j As Integer = cmbexProfile.ItemCount - 1
				If j >= i Then
					cmbexProfile.ItemIndex = i
				Else
					cmbexProfile.ItemIndex = j
				End If
			End If
		Case "cmdProfileFresh"
			Dim i As Integer = cmbexProfile.ItemIndex
			Dim s As String
			If i > -1 Then s = cmbexProfile.Items.Item(i)->Text
			cmbexProfile.Clear
			Dim f As String
			Dim t As String
			Dim l As Integer
			f = Dir(FullName2Path(App.FileName) & "\*" & ".profile")
			Do
				l = Len(f) - Len(".profile")
				If l > 0 Then
					t = Mid(f, 1, l)
					cmbexProfile.Items.Add(t, , 1, 1, 1)
				End If
				f = Dir()
			Loop While f <> ""
			If s <> "" Then
				i = cmbexProfile.IndexOf(s)
				If i > -1 Then cmbexProfile.ItemIndex = i
			End If
		Case Else
		End Select
	End With
End Sub

Private Sub frmFileSyncType.TimerComponent1_Timer(ByRef Sender As TimerComponent)
	Dim st As Long
	Dim s As Single
	
	With fpsync
		If .PercentTotal = -3 Then
		Else
			If .ErrorCount Then
				st = TBPF_ERROR
			Else
				If .Cancel Then
					st = TBPF_PAUSED
				Else
					st = TBPF_NORMAL
				End If
			End If
			
			s = .PercentTotal
			If s < 0 Then
				ProgressBar1.Marquee= True
				st = TBPF_INDETERMINATE
				it3.SetState(st)
			Else
				ProgressBar1.Marquee= False
				it3.SetState(st)
				it3.SetValue(s, 100)
			End If
			ProgressBar1.Visible= True
			ProgressBar1.Position = s
			
			Dim x As Long
			Dim y As Long
			For y = 0 To 12
				For x = 1 To 2
					ListView1.ListItems.Item(y)->Text(x) = .ReportData(x, y)
				Next
			Next
		End If
	End With
	ListView1_ItemClick(ListView1, ListView1.SelectedItemIndex)
End Sub

Private Sub frmFileSyncType.ListView1_ItemClick(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	If ItemIndex < 0 Then
	Else
		txtLogText.Text = fpsync.Report(ItemIndex)
	End If
End Sub

Private Sub frmFileSyncType.cmbexSetProfile_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	Dim i As Long
	Select Case ItemIndex
	Case 0 'Increment
		cmbexCompareData.ItemIndex = 1
		cmbexCompareData_Selected(cmbexCompareData, cmbexCompareData.ItemIndex)
		cmbexCompareMode.ItemIndex = 0
		chkCpyEmptyPath.Checked = True
		rbtnIncrement.Checked = True
		rbtnDuplication.Checked = False
		rbtnSynchronization.Checked = False
		i = 19
	Case 1 'Duplication
		cmbexCompareData.ItemIndex = 1
		cmbexCompareData_Selected(cmbexCompareData, cmbexCompareData.ItemIndex)
		cmbexCompareMode.ItemIndex = 2
		chkCpyEmptyPath.Checked = True
		rbtnIncrement.Checked = False
		rbtnDuplication.Checked = True
		rbtnSynchronization.Checked = False
		i = 3
	Case 2 'Synchronization
		cmbexCompareData.ItemIndex = 1
		cmbexCompareData_Selected(cmbexCompareData, cmbexCompareData.ItemIndex)
		cmbexCompareMode.ItemIndex = 0
		chkCpyEmptyPath.Checked = True
		rbtnIncrement.Checked = False
		rbtnDuplication.Checked = False
		rbtnSynchronization.Checked = True
		i = 238
	Case 3 'Custom
		cmbexCompareData.ItemIndex = 1
		cmbexCompareData_Selected(cmbexCompareData, cmbexCompareData.ItemIndex)
		cmbexCompareMode.ItemIndex = 0
		chkCpyEmptyPath.Checked = False
		rbtnIncrement.Checked = True
		rbtnDuplication.Checked = False
		rbtnSynchronization.Checked = False
		i = 110
	End Select
	SendMessage(This.Handle, WM_SETICON, 0, Cast(LPARAM, ImageList_GetIcon(ImageList1.Handle, i, 0)))
	zControlEnabled(True, ItemIndex)
End Sub

Private Sub frmFileSyncType.cmbexCompareData_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	Dim i As Long = IIf(cmbexCompareMode.ItemIndex < 0, 0, cmbexCompareMode.ItemIndex)
	Dim j As Long
	cmbexCompareMode.Items.Clear
	Select Case ItemIndex
	Case 0
		j = 1
		cmbexCompareMode.Items.Add("Larger", , j, j, j)
		cmbexCompareMode.Items.Add("Smaller", , j, j, j)
		cmbexCompareMode.Items.Add("Not Equal", , j, j, j)
		cmbexCompareMode.Items.Add("Equal", , j, j, j)
	Case Else
		j = 20
		cmbexCompareMode.Items.Add("Newer", , j, j, j)
		cmbexCompareMode.Items.Add("Older", , j, j, j)
		cmbexCompareMode.Items.Add("Not Equal", , j, j, j)
		cmbexCompareMode.Items.Add("Equal", , j, j, j)
	End Select
	cmbexCompareMode.ItemIndex = i
End Sub

Private Sub frmFileSyncType.rbtnLogFile_Click(ByRef Sender As RadioButton)
	txtLogFile.Enabled = rbtnLogFile.Checked
End Sub

Private Sub frmFileSyncType.cmbexAPath_DblClick(ByRef Sender As Control)
	zPathSelect(*Cast(ComboBoxEx Ptr, @Sender))
End Sub

Private Sub frmFileSyncType.cmbexProfile_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	Dim s As String = cmbexProfile.Items.Item(ItemIndex)->Text
	
	If s <> "" Then
		Dim f As String = FullName2Path(App.FileName) & "\" & s & ".profile"
		Dim cp As Integer = -1
		Dim t As WString Ptr
		Dim ss() As WString Ptr
		WStr2Ptr(TextFromFile(f, FileEncodings.Utf8BOM, NewLineTypes.WindowsCRLF, cp), t)
		Dim i As Integer
		Dim j As Integer = SplitWStr(*t, vbCrLf, ss())
		Dim k As Integer
		Dim l As Integer
		Dim m As Integer
		For i = 0 To j
			l = Len(*ss(i))
			m = Len("Set Profile=")
			k = InStr(*ss(i), "Set Profile=")
			If k Then cmbexSetProfile.ItemIndex = CLng(Mid(*ss(i), m + 1, l - m))
			m = Len("A Path=")
			k = InStr(*ss(i), "A Path=")
			If k Then
				k = zFile2ComboEx(cmbexAPath, Mid(*ss(i), m + 1, l - m))
				cmbexAPath.ItemIndex = k
			End If
			m = Len("B Path=")
			k = InStr(*ss(i), "B Path=")
			If k Then
				k = zFile2ComboEx(cmbexBPath, Mid(*ss(i), m + 1, l - m))
				cmbexBPath.ItemIndex = k
			End If
			m = Len("Compare Data=")
			k = InStr(*ss(i), "Compare Data=")
			If k Then cmbexCompareData.ItemIndex = CLng(Mid(*ss(i), m + 1, l - m))
			m = Len("Compare Mode=")
			k = InStr(*ss(i), "Compare Mode=")
			If k Then cmbexCompareMode.ItemIndex = CLng(Mid(*ss(i), m + 1, l - m))
			m = Len("Increment=")
			k = InStr(*ss(i), "Increment=")
			If k Then rbtnIncrement.Checked = IIf(Mid(*ss(i), m + 1, l - m) = "true", True, False)
			m = Len("Duplication=")
			k = InStr(*ss(i), "Duplication=")
			If k Then rbtnDuplication.Checked = IIf(Mid(*ss(i), m + 1, l - m) = "true", True, False)
			m = Len("Synchronization=")
			k = InStr(*ss(i), "Synchronization=")
			If k Then rbtnSynchronization.Checked = IIf(Mid(*ss(i), m + 1, l - m) = "true", True, False)
			m = Len("Copy Empty Path=")
			k = InStr(*ss(i), "Copy Empty Path=")
			If k Then chkCpyEmptyPath.Checked = IIf(Mid(*ss(i), m + 1, l - m) = "true", True, False)
			m = Len("Log Nothing=")
			k = InStr(*ss(i), "Log Nothing=")
			If k Then rbtnLogNothing.Checked = IIf(Mid(*ss(i), m + 1, l - m) = "true", True, False)
			m = Len("Log Memory=")
			k = InStr(*ss(i), "Log Memory=")
			If k Then rbtnLogMemory.Checked = IIf(Mid(*ss(i), m + 1, l - m) = "true", True, False)
			m = Len("Log File=")
			k = InStr(*ss(i), "Log File=")
			If k Then rbtnLogFile.Checked = IIf(Mid(*ss(i), m + 1, l - m) = "true", True, False)
			m = Len("Log FileName=")
			k = InStr(*ss(i), "Log FileName=")
			If k Then txtLogFile.Text = Mid(*ss(i), m + 1, l - m)
			m = Len("Action after Done=")
			k = InStr(*ss(i), "Action after Done=")
			If k Then cmbexDone.ItemIndex = CLng(Mid(*ss(i), m + 1, l - m))
		Next
		cmbexSetProfile_Selected(cmbexSetProfile, cmbexSetProfile.ItemIndex)
		cmbexCompareData_Selected(cmbexCompareData, cmbexCompareData.ItemIndex)
		rbtnLogFile_Click(rbtnLogFile)
		ArrayDeallocate(ss())
		If t Then Deallocate(t)
	End If
End Sub

Private Sub frmFileSyncType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	zSettingSave(FullName2Path(App.FileName) & "\FileSync.Path")
End Sub
