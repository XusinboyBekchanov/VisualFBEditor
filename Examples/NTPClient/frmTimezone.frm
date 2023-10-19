'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/GroupBox.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/Panel.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/Label.bi"
	#include once "mff/ListControl.bi"
	
	Using My.Sys.Forms
	
	Type frmTinezoneType Extends Form
		Declare Sub TimezoneGetInfoSub(ByRef KeyName As WString Ptr)
		Declare Sub TimezoneGetInfo()
		Declare Sub TimezoneReset()
		
		Declare Sub CheckBox_Click(ByRef Sender As CheckBox)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Sub CommandButton_Click(ByRef Sender As Control)
		Declare Sub ListControl1_Click(ByRef Sender As Control)
		Declare Sub TextBox1_Click(ByRef Sender As Control)
		Declare Sub TextBox1_KeyUp(ByRef Sender As Control, Key As Integer, Shift As Integer)
		Declare Constructor
		
		Dim As ListControl ListControl1
		Dim As TextBox TextBox1, TextBox2, TextBox3, TextBox4, TextBox5, TextBox6, TextBox7, TextBox8, TextBox9
		Dim As CommandButton CommandButton1, CommandButton2
		Dim As GroupBox GroupBox1, GroupBox2
		Dim As CheckBox CheckBox1, CheckBox2
		Dim As ComboBoxEdit ComboBoxEdit1, ComboBoxEdit2, ComboBoxEdit3, ComboBoxEdit4, ComboBoxEdit5, ComboBoxEdit6
		Dim As Label Label1, Label2, Label3
	End Type
	
	Constructor frmTinezoneType
		' frmTinezone
		With This
			.Name = "frmTinezone"
			.Text = "Timezone viewer"
			.Designer = @This
			.Caption = "Timezone viewer"
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnDestroy = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Destroy)
			.StartPosition = FormStartPosition.CenterScreen
			.OnShow = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form), @Form_Show)
			.BorderStyle = FormBorderStyle.FixedSingle
			.MaximizeBox = False
			.SetBounds 0, 0, 760, 450
		End With
		' Label3
		With Label3
			.Name = "Label3"
			.Text = ""
			.TabIndex = 0
			.Caption = ""
			.SetBounds 10, 10, 300, 20
			.Designer = @This
			.Parent = @This
		End With
		' CheckBox2
		With CheckBox2
			.Name = "CheckBox2"
			.Text = "List"
			.TabIndex = 1
			.Alignment = CheckAlignmentConstants.chRight
			.ID = 1107
			.Caption = "List"
			.Checked = True
			.SetBounds 369, 7, 50, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox), @CheckBox_Click)
			.Parent = @This
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = ""
			.TabIndex = 2
			.ScrollBars = ScrollBarsType.Both
			.Multiline = True
			.HideSelection = False
			.SetBounds 10, 30, 410, 350
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @TextBox1_Click)
			.OnKeyUp = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer), @TextBox1_KeyUp)
			.Parent = @This
		End With
		' ListControl1
		With ListControl1
			.Name = "ListControl1"
			.Text = "ListControl1"
			.TabIndex = 3
			.Sort = True
			.SetBounds 10, 30, 410, 359
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @ListControl1_Click)
			.Parent = @This
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "Get Timezone"
			.TabIndex = 4
			.Caption = "Get Timezone"
			.SetBounds 10, 390, 200, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @This
		End With
		' CommandButton2
		With CommandButton2
			.Name = "CommandButton2"
			.Text = "Set Timezone"
			.TabIndex = 5
			.Caption = "Set Timezone"
			.SetBounds 220, 390, 200, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @This
		End With
		' GroupBox1
		With GroupBox1
			.Name = "GroupBox1"
			.Text = ""
			.TabIndex = 6
			.Caption = ""
			.SetBounds 430, 10, 310, 150
			.Designer = @This
			.Parent = @This
		End With
		' TextBox2
		With TextBox2
			.Name = "TextBox2"
			.Text = ""
			.TabIndex = 7
			.Hint = "Timezone key name"
			.SetBounds 10, 30, 290, 20
			.Designer = @This
			.Parent = @GroupBox1
		End With
		' TextBox3
		With TextBox3
			.Name = "TextBox3"
			.Text = ""
			.TabIndex = 8
			.Hint = "Timezone display name"
			.SetBounds 10, 60, 290, 20
			.Designer = @This
			.Parent = @GroupBox1
		End With
		' TextBox4
		With TextBox4
			.Name = "TextBox4"
			.Text = ""
			.TabIndex = 9
			.Hint = "Timezone standard name"
			.SetBounds 10, 90, 290, 20
			.Designer = @This
			.Parent = @GroupBox1
		End With
		' TextBox5
		With TextBox5
			.Name = "TextBox5"
			.Text = ""
			.TabIndex = 10
			.Hint = "Timezone bias"
			.SetBounds 10, 120, 290, 20
			.Designer = @This
			.Parent = @GroupBox1
		End With
		' CheckBox1
		With CheckBox1
			.Name = "CheckBox1"
			.Text = "Daylight saving available"
			.TabIndex = 11
			.Caption = "Daylight saving available"
			.SetBounds 430, 170, 310, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox), @CheckBox_Click)
			.Parent = @This
		End With
		' GroupBox2
		With GroupBox2
			.Name = "GroupBox2"
			.Text = ""
			.TabIndex = 12
			.Hint = "Daylight saving"
			.Caption = ""
			.SetBounds 430, 200, 310, 210
			.Designer = @This
			.Parent = @This
		End With
		' Label1
		With Label1
			.Name = "Label1"
			.Text = "Start day"
			.TabIndex = 13
			.Caption = "Start day"
			.SetBounds 10, 30, 290, 20
			.Designer = @This
			.Parent = @GroupBox2
		End With
		' ComboBoxEdit1
		With ComboBoxEdit1
			.Name = "ComboBoxEdit1"
			.Text = "ComboBoxEdit1"
			.TabIndex = 14
			.SetBounds 10, 50, 90, 21
			.Designer = @This
			.Parent = @GroupBox2
			.AddItem "First"
			.AddItem "Second"
			.AddItem "Third"
			.AddItem "Fourth"
			.AddItem "Last"
		End With
		' ComboBoxEdit2
		With ComboBoxEdit2
			.Name = "ComboBoxEdit2"
			.Text = "ComboBoxEdit2"
			.TabIndex = 15
			.SetBounds 110, 50, 90, 21
			.Designer = @This
			.Parent = @GroupBox2
			.AddItem "Sunday"
			.AddItem "Monday"
			.AddItem "Tuesday"
			.AddItem "Wednesday"
			.AddItem "Thursday"
			.AddItem "Friday"
			.AddItem "Saturday"
		End With
		' ComboBoxEdit3
		With ComboBoxEdit3
			.Name = "ComboBoxEdit3"
			.Text = "ComboBoxEdit3"
			.TabIndex = 16
			.SetBounds 210, 50, 90, 21
			.Designer = @This
			.Parent = @GroupBox2
			.AddItem "1-January"
			.AddItem "2-February"
			.AddItem "3-March"
			.AddItem "4-April"
			.AddItem "5-May"
			.AddItem "6-June"
			.AddItem "7-July"
			.AddItem "8-August"
			.AddItem "9-September"
			.AddItem "10-October"
			.AddItem "11-November"
			.AddItem "12-December"
		End With
		' TextBox6
		With TextBox6
			.Name = "TextBox6"
			.Text = ""
			.TabIndex = 17
			.SetBounds 10, 80, 140, 20
			.Designer = @This
			.Parent = @GroupBox2
		End With
		' TextBox7
		With TextBox7
			.Name = "TextBox7"
			.Text = ""
			.TabIndex = 18
			.Hint = "Daylight bias"
			.SetBounds 160, 80, 140, 20
			.Designer = @This
			.Parent = @GroupBox2
		End With
		' Label2
		With Label2
			.Name = "Label2"
			.Text = "Last day"
			.TabIndex = 19
			.Caption = "Last day"
			.SetBounds 10, 120, 290, 20
			.Designer = @This
			.Parent = @GroupBox2
		End With
		' ComboBoxEdit4
		With ComboBoxEdit4
			.Name = "ComboBoxEdit4"
			.Text = "ComboBoxEdit4"
			.TabIndex = 20
			.SetBounds 10, 140, 90, 21
			.Designer = @This
			.Parent = @GroupBox2
			.AddItem "First"
			.AddItem "Second"
			.AddItem "Third"
			.AddItem "Fourth"
			.AddItem "Last"
		End With
		' ComboBoxEdit5
		With ComboBoxEdit5
			.Name = "ComboBoxEdit5"
			.Text = "ComboBoxEdit5"
			.TabIndex = 21
			.SetBounds 110, 140, 90, 21
			.Designer = @This
			.Parent = @GroupBox2
			.AddItem "Sunday"
			.AddItem "Monday"
			.AddItem "Tuesday"
			.AddItem "Wednesday"
			.AddItem "Thursday"
			.AddItem "Friday"
			.AddItem "Saturday"
		End With
		' ComboBoxEdit6
		With ComboBoxEdit6
			.Name = "ComboBoxEdit6"
			.Text = "ComboBoxEdit6"
			.TabIndex = 22
			.SetBounds 210, 140, 90, 21
			.Designer = @This
			.Parent = @GroupBox2
			.AddItem "1-January"
			.AddItem "2-February"
			.AddItem "3-March"
			.AddItem "4-April"
			.AddItem "5-May"
			.AddItem "6-June"
			.AddItem "7-July"
			.AddItem "8-August"
			.AddItem "9-September"
			.AddItem "10-October"
			.AddItem "11-November"
			.AddItem "12-December"
		End With
		' TextBox8
		With TextBox8
			.Name = "TextBox8"
			.Text = ""
			.TabIndex = 23
			.SetBounds 10, 170, 140, 20
			.Designer = @This
			.Parent = @GroupBox2
		End With
		' TextBox9
		With TextBox9
			.Name = "TextBox9"
			.Text = ""
			.TabIndex = 24
			.Hint = "Daylight bias"
			.SetBounds 160, 170, 140, 20
			.Designer = @This
			.Parent = @GroupBox2
		End With
	End Constructor
	
	'Dim Shared frmTinezone As frmTinezoneType
	'
	'#if _MAIN_FILE_ = __FILE__
	'	App.DarkMode = True
	'	frmTinezone.MainForm = True
	'	frmTinezone.Show
	'	App.Run
	'#endif
'#End Region

Type REGTIMEZONEINFORMATION
	Bias As Long
	StandardBias As Long
	DaylightBias As Long
	StandardDate As SYSTEMTIME
	DaylightDate As SYSTEMTIME
End Type

Private Const SKEY_NT = WStr("SOFTWARE\Microsoft\Windows NT\CurrentVersion\Time zones")
Private Const SKEY_9X = WStr("SOFTWARE\Microsoft\Windows\CurrentVersion\Time zones")

Dim Shared tzKey As WStringList
Dim Shared tzDisplay As WStringList
Dim Shared tzStd As WStringList
Dim Shared tzDlt As WStringList
Dim Shared tzi(Any) As REGTIMEZONEINFORMATION
Dim Shared tzIndex As Integer = -1
Dim Shared tzCount As Integer = -1

Private Sub MsgRunAs()
	MsgBox("Require run as administrator permission.", "Require permission", MessageType.mtInfo, ButtonsTypes.btOK)
End Sub

Private Function ProcessToken(ByVal lpName As LPCWSTR) As WINBOOL
	Dim hPorc As Any Ptr
	Dim hToken As Any Ptr
	Dim mLUID As LUID
	Dim mPriv As TOKEN_PRIVILEGES
	Dim mNewPriv As TOKEN_PRIVILEGES
	
	hPorc = GetCurrentProcess()
	If OpenProcessToken(hPorc, TOKEN_ADJUST_PRIVILEGES Or TOKEN_QUERY, @hToken) Then
		If LookupPrivilegeValue(NULL, lpName, @mLUID) Then
			mPriv.PrivilegeCount = 1
			mPriv.Privileges(0).Attributes = SE_PRIVILEGE_ENABLED
			mPriv.Privileges(0).Luid = mLUID
			AdjustTokenPrivileges(hToken, False, @mPriv, SizeOf(mPriv), NULL, NULL)
			CloseHandle(hToken)
		End If
		Return True
	Else
		Return False
	End If
End Function

Private Sub frmTinezoneType.TimezoneGetInfoSub(ByRef KeyName As WString Ptr)
	Dim lRetVal As Long, lResult As Long
	Dim hKeyResult As Any Ptr = NULL
	Dim lDataLen As Long, lValueLen As Long
	Dim strValue As WString Ptr = NULL
	Dim lpType As DWORD = 0
	Dim tzia As REGTIMEZONEINFORMATION
	
	lRetVal = RegOpenKeyEx(HKEY_LOCAL_MACHINE, SKEY_NT & WStr("\") & *KeyName, 0, KEY_READ, @hKeyResult)
	If lRetVal = ERROR_SUCCESS Then
		lDataLen = SizeOf(REGTIMEZONEINFORMATION)
		lResult = RegQueryValueEx(hKeyResult, WStr("TZI"), 0, @lpType, Cast(Byte Ptr, @tzi(tzCount)), @lDataLen)
		If lResult = ERROR_SUCCESS Then
		Else
		End If
		
		lDataLen = 127
		lValueLen = (lDataLen + 1) * 2
		
		strValue = Reallocate(strValue, lValueLen)
		lResult = RegQueryValueEx(hKeyResult, WStr("Display"), 0, @lpType, Cast(Byte Ptr, strValue), @lDataLen)
		If lResult = ERROR_SUCCESS Then
			tzDisplay.Item(tzCount) = *strValue
			
			ListControl1.AddItem tzDisplay.Item(tzCount), Cast(Any Ptr, tzCount)
		Else
		End If
		
		strValue = Reallocate(strValue, lValueLen)
		lResult = RegQueryValueEx(hKeyResult, WStr("Std"), 0, @lpType, Cast(Byte Ptr, strValue), @lDataLen)
		If lResult = ERROR_SUCCESS Then
			tzStd.Item(tzCount) = *strValue
		Else
			tzStd.Item(tzCount) = *KeyName
			Print tzStd.Item(tzCount)
		End If
		
		strValue = Reallocate(strValue, lValueLen)
		lResult = RegQueryValueEx(hKeyResult, WStr("Dlt"), 0, @lpType, Cast(Byte Ptr, strValue), @lDataLen)
		If lResult = ERROR_SUCCESS Then
			tzDlt.Item(tzCount) = *strValue
		Else
		End If
		
		RegCloseKey hKeyResult
		If strValue Then Deallocate strValue
	Else
	End If
End Sub

Private Sub frmTinezoneType.TimezoneGetInfo()
	TimezoneReset()
	Dim lRetVal As Long, lResult As Long, lCurIdx As Long = 0
	Dim lDataLen As Long = 127, lValueLen As Long = (lDataLen + 1) * 2, hKeyResult As Any Ptr = NULL
	Dim strValue As WString Ptr = NULL
	
	lRetVal = RegOpenKeyEx(HKEY_LOCAL_MACHINE, SKEY_NT, 0, KEY_READ, @hKeyResult)
	If lRetVal = ERROR_SUCCESS Then
		Do
			strValue = Reallocate(strValue, lValueLen)
			lResult = RegEnumKey(hKeyResult, lCurIdx, strValue, lDataLen)
			If lResult = ERROR_SUCCESS Then
				tzKey.Add *strValue
				tzDisplay.Add ""
				tzDlt.Add ""
				tzStd.Add ""
				tzCount = lCurIdx
				ReDim Preserve tzi(tzCount)
				TimezoneGetInfoSub(*strValue)
			Else
				Exit Do
			End If
			lCurIdx = lCurIdx + 1
		Loop While lResult = ERROR_SUCCESS
		If strValue Then Deallocate strValue
		RegCloseKey hKeyResult
		
		For i As Integer = 0 To ListControl1.ItemCount - 1
			TextBox1.AddLine ListControl1.Item(i)
		Next
	Else
	End If
End Sub

Private Sub frmTinezoneType.TimezoneReset()
	tzIndex = -1
	tzCount = -1
	tzKey.Clear
	tzDisplay.Clear
	tzDlt.Clear
	tzStd.Clear
	Erase tzi
	TextBox1.Clear
	ListControl1.Clear
End Sub

Private Sub frmTinezoneType.Form_Create(ByRef Sender As Control)
	TimezoneGetInfo()
End Sub

Private Sub frmTinezoneType.Form_Destroy(ByRef Sender As Control)
	TimezoneReset()
End Sub

Private Sub frmTinezoneType.Form_Show(ByRef Sender As Form)
	CommandButton_Click(CommandButton1)
	CheckBox_Click CheckBox2
End Sub

Private Sub frmTinezoneType.CommandButton_Click(ByRef Sender As Control)
	Dim pTimeZoneInformation As PDYNAMIC_TIME_ZONE_INFORMATION = New DYNAMIC_TIME_ZONE_INFORMATION
	Select Case Sender.Name
	Case "CommandButton1"
		'get system timezone info
		GetDynamicTimeZoneInformation(pTimeZoneInformation)
		'get index of keyname
		Dim i As Integer = tzKey.IndexOf(pTimeZoneInformation->TimeZoneKeyName)
		'get index of listcontrol
		Dim j As Integer = ListControl1.IndexOfData(Cast(Any Ptr, i))
		'display it
		tzIndex = -1
		ListControl1.ItemIndex = j
		ListControl1_Click(ListControl1)
	Case "CommandButton2"
		If MsgBox(!"Press OK to confirm changing the system time zone to:\r\n" & tzKey.Item(tzIndex), "System time zone", MessageType.mtQuestion, ButtonsTypes.btOkCancel) <> MessageResult.mrOK Then Exit Sub
		
		'set system timezone
		pTimeZoneInformation->Bias = tzi(tzIndex).Bias
		pTimeZoneInformation->DaylightBias = tzi(tzIndex).DaylightBias
		pTimeZoneInformation->DaylightName = tzDlt.Item(tzIndex)
		pTimeZoneInformation->DynamicDaylightTimeDisabled = IIf(tzi(tzIndex).DaylightDate.wMonth, True, False)
		pTimeZoneInformation->StandardBias = tzi(tzIndex).StandardBias
		pTimeZoneInformation->StandardName= tzStd.Item(tzIndex)
		pTimeZoneInformation->TimeZoneKeyName= tzKey.Item(tzIndex)
		memcpy(@(pTimeZoneInformation->DaylightDate), @(tzi(tzIndex).DaylightDate), SizeOf(SYSTEMTIME))
		memcpy(@(pTimeZoneInformation->StandardDate), @(tzi(tzIndex).StandardDate), SizeOf(SYSTEMTIME))
		
		ProcessToken(@SE_TIME_ZONE_NAME)
		If SetDynamicTimeZoneInformation(pTimeZoneInformation) Then
			'set timezone passed
			MsgBox(!"Timezone success set to: \r\n" & tzKey.Item(tzIndex))
		Else
			'set timezone failed
			MsgRunAs
		End If
	End Select
End Sub

Private Sub frmTinezoneType.ListControl1_Click(ByRef Sender As Control)
	If tzCount < 0 Then Exit Sub
	Dim j As Integer = ListControl1.ItemIndex
	Dim i As Integer = Cast(Integer, ListControl1.ItemData(j))
	
	If tzIndex = i Then Exit Sub
	tzIndex = i
	
	'display on textbox
	TextBox1.SetSel(j, 0, j, 0)
	TextBox1.SelLength = Len(TextBox1.Lines(j))
	
	'display timezone
	Label3.Text = "(" & j + 1 & " of " & tzCount + 1 & ") " & tzKey.Item(i)
	GroupBox1.Text = tzDisplay.Item(i)
	TextBox2.Text= tzKey.Item(i)
	TextBox3.Text = tzDisplay.Item(i)
	TextBox4.Text = tzStd.Item(i)
	GroupBox2.Text = tzDlt.Item(i)
	TextBox5.Text = "" & tzi(i).Bias
	
	'display daylights aving
	CheckBox1.Checked = tzi(i).DaylightDate.wMonth
	ComboBoxEdit1.ItemIndex = tzi(i).DaylightDate.wDay - 1
	ComboBoxEdit2.ItemIndex = tzi(i).DaylightDate.wDayOfWeek
	ComboBoxEdit3.ItemIndex = tzi(i).DaylightDate.wMonth - 1
	ComboBoxEdit4.ItemIndex = tzi(i).StandardDate.wDay - 1
	ComboBoxEdit5.ItemIndex = tzi(i).StandardDate.wDayOfWeek
	ComboBoxEdit6.ItemIndex = tzi(i).StandardDate.wMonth - 1
	TextBox6.Text =  tzi(i).DaylightDate.wHour & ":" & tzi(i).DaylightDate.wMinute & ":" & tzi(i).DaylightDate.wSecond & "." & tzi(i).DaylightDate.wMilliseconds
	TextBox7.Text = "" & tzi(i).DaylightBias
	TextBox8.Text =  tzi(i).StandardDate.wHour & ":" & tzi(i).StandardDate.wMinute & ":" & tzi(i).StandardDate.wSecond & "." & tzi(i).StandardDate.wMilliseconds
	TextBox9.Text = "" & tzi(i).StandardBias
	
	CheckBox_Click(CheckBox1)
End Sub

Private Sub frmTinezoneType.TextBox1_Click(ByRef Sender As Control)
	If tzCount < 0 Then Exit Sub
	
	Dim As Integer sy, sx, ey, ex
	TextBox1.GetSel(sy, sx, ey, ex)
	
	Dim j As Integer = IIf(sy > tzCount, tzCount, sy)
	
	ListControl1.ItemIndex = j
	ListControl1_Click(ListControl1)
End Sub

Private Sub frmTinezoneType.TextBox1_KeyUp(ByRef Sender As Control, Key As Integer, Shift As Integer)
	TextBox1_Click(TextBox1)
End Sub

Private Sub frmTinezoneType.CheckBox_Click(ByRef Sender As CheckBox)
	Select Case Sender.Name
	Case "CheckBox1"
		GroupBox2.Visible = CheckBox1.Checked
	Case "CheckBox2"
		ListControl1.Visible = CheckBox2.Checked
		TextBox1.Visible = CheckBox2.Checked = False
	End Select
End Sub
