' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "frmDownload.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	
	#include once "mff/Form.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Dialogs.bi"
	#include once "mff/Label.bi"
	#include once "mff/ProgressBar.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/TimerComponent.bi"
	#include once "mff/GroupBox.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/ComboBoxEdit.bi"
	
	#include once "Download.bi"
	#include once "../MDINotepad/FileAct.bi"
	#include once "../MDINotepad/ITL3.bi"
	#include once "../MDINotepad/Text.bi"
	
	Using My.Sys.Forms
	
	Type frmDownloadType Extends Form
		
		Dim dl As Download
		Dim itl As ITL3
		Declare Static Sub OnDone(Owner As Any Ptr)
		Declare Static Sub OnMsg(Owner As Any Ptr, ByRef MsgStr As Const WString)
		Declare Static Sub OnCacheFile(Owner As Any Ptr, ByRef CacheFile As Const WString)
		Declare Static Sub OnReDir(Owner As Any Ptr, ByRef Url As Const WString)
		
		Declare Sub CtlEnabled(e As Boolean)
		
		Declare Sub cmdButton_Click(ByRef Sender As Control)
		Declare Sub cmbSourceURL_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Sub cmbSourceURL_Change(ByRef Sender As ComboBoxEdit)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Constructor
		
		Dim As TextBox txtTargetPath, txtTargetFile, txtMsg
		Dim As CommandButton cmdDownload, cmdCancel, cmdSelect, cmdBrowse
		Dim As ComboBoxEdit cmbSourceURL
		Dim As FolderBrowserDialog FolderBrowserDialog1
		Dim As Label lblSourceSize, lblElapsedTime, lblDownloadSize, lblSpeed
		Dim As ProgressBar ProgressBar1
		Dim As CheckBox chkDelCache
		Dim As TimerComponent TimerComponent1
		Dim As GroupBox GroupBox1, GroupBox2, GroupBox3
	End Type
	
	Constructor frmDownloadType
		' frmDownload
		With This
			.Name = "frmDownload"
			.Text = "Download"
			.Designer = @This
			.StartPosition = FormStartPosition.CenterScreen
			#ifdef __USE_GTK__
				This.Icon.LoadFromFile(ExePath & "Download.ico")
			#else
				This.Icon.LoadFromResourceID(1)
			#endif
			#ifdef __FB_64BIT__
				'...instructions for 64bit OSes...
				.Caption = "VFBE URLDownloadToFile64"
			#else
				'...instructions for other OSes
				.Caption = "VFBE URLDownloadToFile32"
			#endif
			.OnShow = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Show)
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.BorderStyle = FormBorderStyle.FixedSingle
			.MinimizeBox = True
			.MaximizeBox = False
			.ControlBox = True
			.SetBounds 0, 0, 530, 490
		End With
		' GroupBox1
		With GroupBox1
			.Name = "GroupBox1"
			.Text = "URL Source"
			.TabIndex = 0
			.Caption = "URL Source"
			.SetBounds 10, 10, 500, 70
			.Designer = @This
			.Parent = @This
		End With
		' GroupBox2
		With GroupBox2
			.Name = "GroupBox2"
			.Text = "Download Path/File"
			.TabIndex = 1
			.Caption = "Download Path/File"
			.SetBounds 10, 90, 500, 80
			.Designer = @This
			.Parent = @This
		End With
		' GroupBox3
		With GroupBox3
			.Name = "GroupBox3"
			.Text = "Progress"
			.TabIndex = 2
			.Caption = "Progress"
			.SetBounds 10, 180, 500, 90
			.Designer = @This
			.Parent = @This
		End With
		' cmbSourceURL
		With cmbSourceURL
			.Name = "cmbSourceURL"
			.Text = "cmbSourceURL"
			.TabIndex = 4
			.Style = ComboBoxEditStyle.cbDropDown
			.SetBounds 10, 30, 480, 21
			.Designer = @This
			.Parent = @GroupBox1
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @cmbSourceURL_Selected)
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit), @cmbSourceURL_Change)
			.AddItem "https://github.com/XusinboyBekchanov/VisualFBEditor/archive/refs/heads/master.zip"
			.AddItem "https://github.com/XusinboyBekchanov/MyFbFramework/archive/refs/heads/master.zip"
			.AddItem "https://github.com/PaulSquires/WinFBE/archive/refs/heads/master.zip"
			.AddItem "https://github.com/PaulSquires/WinFormsX/archive/refs/heads/master.zip"
			.AddItem "https://github.com/JoseRoca/WinFBX/archive/refs/heads/master.zip"
			.AddItem "https://www.scintilla.org/scintilla531.zip"
			.AddItem "https://www.scintilla.org/scite531.zip"
			.AddItem "https://www.scintilla.org/wscite531.zip"
			.AddItem "https://www.scintilla.org/wscite32_531.zip"
			.AddItem "https://the.earth.li/~sgtatham/putty/latest/wa64/putty.zip"
			.AddItem "https://www.7-zip.org/a/7z2201-x64.exe"
			.AddItem "https://dl1.cdn.filezilla-project.org/client/FileZilla_3.61.0_win32-setup.exe"
			.AddItem "https://t1.daumcdn.net/potplayer/PotPlayer/Version/Latest/PotPlayerSetup64.exe"
			.AddItem "http://www.foobar2000.org/files/foobar2000_v1.6.13.exe"
			.AddItem "https://github.com/git-for-windows/git/releases/download/v2.38.1.windows.1/PortableGit-2.38.1-64-bit.7z.exe"
			.AddItem "https://users.freebasic-portal.de/stw/builds"
			.AddItem "https://users.freebasic-portal.de/stw/builds/win32"
			.AddItem "https://users.freebasic-portal.de/stw/builds/win64"
		End With
		' txtTargetPath
		With txtTargetPath
			.Name = "txtTargetPath"
			.Text = "C:\Users\cm.wang\Desktop"
			.TabIndex = 5
			.SetBounds 10, 20, 390, 20
			.Designer = @This
			.Parent = @GroupBox2
		End With
		' cmdSelect
		With cmdSelect
			.Name = "cmdSelect"
			.Text = "Select"
			.TabIndex = 6
			.Caption = "Select"
			.SetBounds 400, 20, 90, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdButton_Click)
			.Parent = @GroupBox2
		End With
		' txtTargetFile
		With txtTargetFile
			.Name = "txtTargetFile"
			.Text = "master.zip"
			.TabIndex = 7
			.SetBounds 10, 50, 390, 20
			.Designer = @This
			.Parent = @GroupBox2
		End With
		' cmdBrowse
		With cmdBrowse
			.Name = "cmdBrowse"
			.Text = "Browse"
			.TabIndex = 8
			.Caption = "Browse"
			.SetBounds 400, 50, 90, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdButton_Click)
			.Parent = @GroupBox2
		End With
		' lblSourceSize
		With lblSourceSize
			.Name = "lblSourceSize"
			.Text = "Source Size"
			.TabIndex = 9
			.Caption = "Source Size"
			.SetBounds 10, 30, 230, 16
			.Designer = @This
			.Parent = @GroupBox3
		End With
		' lblDownloadSize
		With lblDownloadSize
			.Name = "lblDownloadSize"
			.Text = "Download Size"
			.TabIndex = 10
			.Caption = "Download Size"
			.Alignment = AlignmentConstants.taRight
			.SetBounds 260, 30, 230, 16
			.Designer = @This
			.Parent = @GroupBox3
		End With
		' ProgressBar1
		With ProgressBar1
			.Name = "ProgressBar1"
			.Text = "ProgressBar1"
			.SetBounds 10, 50, 480, 3
			.Designer = @This
			.Parent = @GroupBox3
		End With
		' lblElapsedTime
		With lblElapsedTime
			.Name = "lblElapsedTime"
			.Text = "Elapsed Time"
			.TabIndex = 11
			.Caption = "Elapsed Time"
			.SetBounds 10, 60, 230, 16
			.Designer = @This
			.Parent = @GroupBox3
		End With
		' lblSpeed
		With lblSpeed
			.Name = "lblSpeed"
			.Text = "Speed"
			.TabIndex = 12
			.Caption = "Speed"
			.Alignment = AlignmentConstants.taRight
			.SetBounds 260, 60, 230, 16
			.Designer = @This
			.Parent = @GroupBox3
		End With
		' txtMsg
		With txtMsg
			.Name = "txtMsg"
			.Text = ""
			.TabIndex = 13
			.Multiline = True
			.ScrollBars = ScrollBarsType.Both
			.SetBounds 10, 280, 500, 120
			.Designer = @This
			.Parent = @This
		End With
		' chkDelCache
		With chkDelCache
			.Name = "chkDelCache"
			.Text = "Delete Cache Entry"
			.TabIndex = 14
			.Caption = "Delete Cache Entry"
			.Checked = True
			.SetBounds 10, 420, 140, 20
			.Designer = @This
			.Parent = @This
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = "Cancel"
			.TabIndex = 15
			.Caption = "Cancel"
			.Enabled = False
			.SetBounds 320, 420, 90, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdButton_Click)
			.Parent = @This
		End With
		' cmdDownload
		With cmdDownload
			.Name = "cmdDownload"
			.Text = "Download"
			.TabIndex = 16
			.Caption = "Download"
			.SetBounds 420, 420, 90, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdButton_Click)
			.Parent = @This
		End With
		' FolderBrowserDialog1
		With FolderBrowserDialog1
			.Name = "FolderBrowserDialog1"
			.SetBounds 0, 20, 16, 16
			.Designer = @This
			.Parent = @GroupBox2
		End With
		' TimerComponent1
		With TimerComponent1
			.Name = "TimerComponent1"
			.Interval = 100
			.SetBounds 10, 10, 16, 16
			.Designer = @This
			.OnTimer = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent), @TimerComponent1_Timer)
			.Parent = @GroupBox3
		End With
	End Constructor
	
	Dim Shared frmDownload As frmDownloadType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmDownload.MainForm = True
		frmDownload.Show
		App.Run
	#endif
'#End Region

Private Sub frmDownloadType.cmdButton_Click(ByRef Sender As Control)
	Select Case Sender.Name
	Case "cmdDownload"
		If Dir(txtTargetPath.Text & "\" & txtTargetFile.Text) <> "" Then
			If MsgBox(txtTargetFile.Text & !"\r\nThe file already exists. \r\nDo you want to overwrite it?", "Download", MessageType.mtWarning, ButtonsTypes.btYesNo) <> MessageResult.mrYes Then
				Exit Sub
			End If
			Kill(txtTargetPath.Text & "\" & txtTargetFile.Text)
		End If
		Debug.Clear
		CtlEnabled(False)
		dl.DeleteCacheEntry = chkDelCache.Checked
		dl.DownloadUrl(@This, cmbSourceURL.Text, txtTargetPath.Text, txtTargetFile.Text)
	Case "cmdCancel"
		dl.Cancel = True
	Case "cmdSelect"
		FolderBrowserDialog1.InitialDir = txtTargetPath.Text
		If FolderBrowserDialog1.Execute Then
			txtTargetPath.Text = FolderBrowserDialog1.Directory
		End If
	Case "cmdBrowse"
		If Dir(txtTargetPath.Text & "\" & txtTargetFile.Text) <> "" Then
			Exec ("c:\windows\explorer.exe" , "/select," & txtTargetPath.Text & "\" & txtTargetFile.Text)
		Else
			Exec ("c:\windows\explorer.exe" , txtTargetPath.Text)
		End If
	End Select
End Sub

Private Sub frmDownloadType.OnDone(Owner As Any Ptr)
	Dim a As frmDownloadType Ptr = Cast(frmDownloadType Ptr, Owner)
	a->CtlEnabled(True)
End Sub

Private Sub frmDownloadType.OnMsg(Owner As Any Ptr, ByRef MsgStr As Const WString)
	Dim a As frmDownloadType Ptr = Cast(frmDownloadType Ptr, Owner)
	a->txtMsg.AddLine("" + MsgStr)
End Sub
Private Sub frmDownloadType.OnCacheFile(Owner As Any Ptr, ByRef CacheFile As Const WString)
	Dim a As frmDownloadType Ptr = Cast(frmDownloadType Ptr, Owner)
	a->txtMsg.AddLine(!"OnCacheFile\r\n" + CacheFile)
End Sub
Private Sub frmDownloadType.OnReDir(Owner As Any Ptr, ByRef Url As Const WString)
	Dim a As frmDownloadType Ptr = Cast(frmDownloadType Ptr, Owner)
	a->txtMsg.AddLine(!"OnReDir\r\n" + Url)
End Sub

Private Sub frmDownloadType.cmbSourceURL_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	cmbSourceURL.Text = cmbSourceURL.Item(ItemIndex)
End Sub

Private Sub frmDownloadType.cmbSourceURL_Change(ByRef Sender As ComboBoxEdit)
	Dim i As Integer = InStr(cmbSourceURL.Text, "/archive/refs/heads/")
	Dim j As Integer
	
	Dim t As WString Ptr = NULL
	If i < 1 Then
		WLet(t, cmbSourceURL.Text)
		i = InStrRev(*t, "/", -1)
		If i < 0 Then Exit Sub
		j = Len(*t)
		txtTargetFile.Text = Mid(*t, i + 1, j - i)
	Else
		WLet(t, Mid(cmbSourceURL.Text, 1, i - 1))
		i = InStrRev(*t, "/", -1)
		If i < 0 Then Exit Sub
		j = Len(*t)
		Dim k As Integer = InStrRev(cmbSourceURL.Text, "/")
		Dim l As Integer = Len(cmbSourceURL.Text)
		txtTargetFile.Text = Mid(*t, i + 1, j - i) & "-" & Mid(cmbSourceURL.Text, k + 1, l - k)
	End If
	
	If t Then Deallocate(t)
End Sub

Private Sub frmDownloadType.Form_Show(ByRef Sender As Form)
	cmbSourceURL.ItemIndex = 0
	cmbSourceURL_Selected(cmbSourceURL, 0)
End Sub

Private Sub frmDownloadType.Form_Create(ByRef Sender As Control)
	Dim hr As HRESULT = CoInitialize(0)
	Dim i As Integer = InStrRev(App.FileName, "\")
	txtTargetPath.Text = Mid(App.FileName, 1, i - 1) ' & "Download"
	Dim t As WString Ptr
	Dim s As WString Ptr
	Dim ss(Any) As WString Ptr
	WLet(t, Replace(App.FileName, ".exe", ".ini"))
	txtMsg.AddLine "Load URL list from " & *t
	If Dir(*t) <> "" Then
		TextFromFile(*t, s, -1, -1, -1)
		txtMsg.AddLine *s
		Dim j As Integer = SplitWStr(*s, WStr(vbCrLf), ss())
		If j > -1 Then cmbSourceURL.Clear
		For i = 0 To j
			cmbSourceURL.AddItem *ss(i)
		Next
	End If
	dl.OnDone = Cast(Any Ptr, @OnDone)
	dl.OnMsg = Cast(Any Ptr, @OnMsg)
	dl.OnCacheFile = Cast(Any Ptr, @OnCacheFile)
	dl.OnReDir = Cast(Any Ptr, @OnReDir)
	itl.Initial(This.Handle)
	If t Then Deallocate(t)
	If s Then Deallocate(s)
	ArrayDeallocate(ss())
End Sub

Private Sub frmDownloadType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	CoUninitialize()
End Sub

Private Sub frmDownloadType.CtlEnabled(e As Boolean)
	cmbSourceURL.Enabled = e
	txtTargetPath.Enabled = e
	txtTargetFile.Enabled = e
	cmdSelect.Enabled = e
	cmdBrowse.Enabled = e
	cmdDownload.Enabled = e
	chkDelCache.Enabled = e
	If e Then
		TimerComponent1.Enabled = False
		cmdCancel.Enabled = False
		ProgressBar1.Marquee = False
		ProgressBar1.Visible = True
		TimerComponent1_Timer(TimerComponent1)
		itl.SetState(TBPF_NOPROGRESS)
		If dl.Cancel Then
			txtMsg.AddLine "Download Cancel."
			itl.SetState(TBPF_PAUSED)
		Else
			If dl.Status Then
				txtMsg.AddLine "Download Passed."
				itl.SetState(TBPF_NORMAL)
			Else
				txtMsg.AddLine "Download Failed."
				itl.SetState(TBPF_ERROR)
			End If
		End If
	Else
		itl.SetState(TBPF_INDETERMINATE)
		TimerComponent1.Enabled = True
		lblSourceSize.Text = "Source Size"
		lblDownloadSize.Text = "Download Size"
		lblElapsedTime.Text = "Elapsed Time"
		lblSpeed.Text = "Speed"
		txtMsg.Text = ""
		cmdCancel.Enabled = True
		ProgressBar1.Position = 0
		ProgressBar1.Marquee = True
		ProgressBar1.SetMarquee(True, 10)
		ProgressBar1.Visible = True
	End If
End Sub

Private Sub frmDownloadType.TimerComponent1_Timer(ByRef Sender As TimerComponent)
	Dim t As Double = dl.ElapsedTime
	If dl.SourceSize Then
		itl.SetState(TBPF_NORMAL)
		itl.SetValue(dl.DonePercent, 100)
		ProgressBar1.Marquee = False
		ProgressBar1.Visible = True
		ProgressBar1.Position = dl.DonePercent
		lblDownloadSize.Text = "Download Size " & Format(dl.DownloadSize, "#,#0") & " (" & Bytes2Str(dl.DownloadSize) & ") " & Format(dl.DonePercent, "0.00") & "%"
	Else
		lblDownloadSize.Text = "Download Size " & Format(dl.DownloadSize, "#,#0") & " (" & Bytes2Str(dl.DownloadSize) & ")"
	End If
	lblSpeed.Text = "Speed " & Format(dl.DownloadSpeed, "#,#0") & " (" & Bytes2Str(dl.DownloadSpeed) & ") /Sec."
	If dl.SourceSize Then
		lblSourceSize.Text = "Source Size " & Format(dl.SourceSize, "#,#0") & " (" & Bytes2Str(dl.SourceSize) & ")"
	Else
		lblSourceSize.Text = "Source Size Unknow"
	End If
	lblElapsedTime.Text = "Elapsed Time (" & Sec2Time(t) & ") " & Format(t, "#,#0.000") & " Sec."
End Sub
