'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "frmNtp.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/ComboBoxEx.bi"
	#include once "mff/Label.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/ListView.bi"
	#include once "mff/ImageList.bi"
	
	#include once "../PipeProcess/PipeProcess.bi"
	
	#include once "frmTimezone.frm"
	
	Using My.Sys.Forms
	
	Type frmNtpType Extends Form
		mPp As PipeProcess
		mTzBias As Integer
		
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Sub ComboBoxEx1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub CommandButton_Click(ByRef Sender As Control)
		Declare Constructor
		
		Dim As ComboBoxEx ComboBoxEx1
		Dim As CommandButton CommandButton1, CommandButton2, CommandButton3, CommandButton4
		Dim As ListView ListView1
		Dim As ImageList ImageList1
		
		NTPName(32) As String = { _
		"中国时间服务器", _
		"中国国家授时中心", _
		"上海交通大学网络中心NTP服务器地址", _
		"北京邮电大学", _
		"清华大学", _
		"北京大学", _
		"东南大学", _
		"清华大学", _
		"清华大学", _
		"清华大学", _
		"北京邮电大学", _
		"西南地区网络中心", _
		"西北地区网络中心", _
		"东北地区网络中心", _
		"华东南地区网络中心", _
		"四川大学网络管理中心", _
		"大连理工大学网络中心", _
		"CERNET桂林主节点", _
		"北京大学", _
		"NIST, Gaithersburg, Maryland", _
		"NIST, Gaithersburg, Maryland", _
		"NIST, Boulder, Colorado", _
		"NIST, Boulder, Colorado", _
		"NIST, Boulder, Colorado", _
		"University of Colorado, Boulder", _
		"NCAR, Boulder, Colorado", _
		"Microsoft, Redmond, Washington", _
		"Symmetricom, San Jose, California", _
		"Abovenet, Virginia", _
		"Abovenet, New York City", _
		"Abovenet, San Jose, California", _
		"TrueTime, AOL facility, Sunnyvale, California", _
		"TrueTime, AOL facility, Virginia" _
		}
		
		NTPAddress(32) As String = { _
		"cn.pool.ntp.org", _
		"ntp.ntsc.ac.cn", _
		"ntp.sjtu.edu.cn", _
		"s1a.time.edu.cn", _
		"s1b.time.edu.cn", _
		"s1c.time.edu.cn", _
		"s1d.time.edu.cn", _
		"s1e.time.edu.cn", _
		"s2a.time.edu.cn", _
		"s2b.time.edu.cn", _
		"s2c.time.edu.cn", _
		"s2d.time.edu.cn", _
		"s2e.time.edu.cn", _
		"s2f.time.edu.cn", _
		"s2g.time.edu.cn", _
		"s2h.time.edu.cn", _
		"s2j.time.edu.cn", _
		"s2k.time.edu.cn", _
		"s2m.time.edu.cn", _
		"time-a.nist.gov", _
		"time-b.nist.gov", _
		"time-a.timefreq.bldrdoc.gov", _
		"time-b.timefreq.bldrdoc.gov", _
		"time-c.timefreq.bldrdoc.gov", _
		"utcnist.colorado.edu", _
		"time.nist.gov", _
		"time-nw.nist.gov", _
		"nist1.symmetricom.com", _
		"nist1-dc.glassey.com", _
		"nist1-ny.glassey.com", _
		"nist1-sj.glassey.com", _
		"nist1.aol-ca.truetime.com", _
		"nist1.aol-va.truetime.com" _
		}
		
		Dim As Label Label1
	End Type
	
	Constructor frmNtpType
		' frmNtp
		With This
			.Name = "frmNtp"
			.Text = "Network Time Protocol Client"
			.Designer = @This
			.Caption = "Network Time Protocol Client"
			.StartPosition = FormStartPosition.CenterScreen
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnDestroy = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Destroy)
			.BorderStyle = FormBorderStyle.FixedSingle
			.MaximizeBox = False
			.SetBounds 0, 0, 325, 340
		End With
		' ComboBoxEx1
		With ComboBoxEx1
			.Name = "ComboBoxEx1"
			.Text = "ComboBoxEx1"
			.TabIndex = 0
			.ImagesList = @ImageList1
			.SetBounds 20, 20, 280, 22
			.Designer = @This
			.Parent = @This
			Dim i As Integer
			For i = 0 To 32
				.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @ComboBoxEx1_Selected)
				.Items.Add(NTPName(i), , 13, 13, 13)
			Next
		End With
		' Label1
		With Label1
			.Name = "Label1"
			.Text = ""
			.TabIndex = 1
			.Caption = ""
			.SetBounds 20, 60, 280, 20
			.Designer = @This
			.Parent = @This
		End With
		' ListView1
		With ListView1
			.Name = "ListView1"
			.Text = "ListView1"
			.TabIndex = 2
			.SmallImages = @ImageList1
			.Images = @ImageList1
			.SetBounds 20, 90, 280, 140
			.Designer = @This
			.Parent = @This
			.Columns.Add("Item", 0 , 100)
			.Columns.Add("Desc", 0 , .Width - 105)
			.ListItems.Add("Server", 13)
			.ListItems.Add("Address", 18)
			.ListItems.Add("Timezone bias", 21)
			.ListItems.Add("Host", 20)
			.ListItems.Add("Local", 15)
			.ListItems.Add("Result", 17)
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "Date Time"
			.TabIndex = 3
			.Caption = "Date Time"
			.SetBounds 20, 250, 100, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @This
		End With
		' CommandButton2
		With CommandButton2
			.Name = "CommandButton2"
			.Text = "Timezone"
			.TabIndex = 4
			.Caption = "Timezone"
			.SetBounds 20, 280, 100, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @This
		End With
		' CommandButton3
		With CommandButton3
			.Name = "CommandButton3"
			.Text = "Check"
			.TabIndex = 5
			.Caption = "Check"
			.SetBounds 200, 250, 100, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @This
		End With
		' CommandButton4
		With CommandButton4
			.Name = "CommandButton4"
			.Text = "Calibrate"
			.TabIndex = 6
			.Caption = "Calibrate"
			.SetBounds 200, 280, 100, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @This
		End With
		' ImageList1
		With ImageList1
			.Name = "ImageList1"
			.SetBounds 20, 210, 16, 16
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frmNtp As frmNtpType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmNtp.MainForm = True
		frmNtp.Show
		App.Run
	#endif
'#End Region

#include once "ntp.bi"

Private Sub frmNtpType.Form_Create(ByRef Sender As Control)
	Dim i As Long
	Dim j As Long
	Dim Icon As HICON
	
	j = ExtractIconEx("C:\Windows\System32\shell32.dll", -1, 0, 0, 1)
	For i = 0 To j
		ExtractIconEx "C:\Windows\System32\shell32.dll", i, 0, @Icon, 1
		ImageList_ReplaceIcon(ImageList1.Handle, -1, Icon)
		DestroyIcon Icon
	Next
	
	ComboBoxEx1.ItemIndex = 0
	ComboBoxEx1_Selected(ComboBoxEx1, 0)
	
	Dim pTimeZoneInformation As PDYNAMIC_TIME_ZONE_INFORMATION = New DYNAMIC_TIME_ZONE_INFORMATION
	GetDynamicTimeZoneInformation(pTimeZoneInformation)
	
	mTzBias = pTimeZoneInformation->Bias
	Label1.Caption = "Timezone: " & pTimeZoneInformation->TimeZoneKeyName & ", " & mTzBias
	
	ListView1.ListItems.Item(2)->Text(1) = Format(mTzBias, "0")
End Sub

Private Sub frmNtpType.Form_Destroy(ByRef Sender As Control)
	
End Sub

Private Sub frmNtpType.ComboBoxEx1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	ListView1.ListItems.Item(0)->Text(1) = NTPName(ItemIndex)
	ListView1.ListItems.Item(1)->Text(1) = NTPAddress(ItemIndex)
End Sub

Private Sub frmNtpType.CommandButton_Click(ByRef Sender As Control)
	Select Case Sender.Name
	Case "CommandButton1"
		Dim rtns As WString * 1024
		mPp.PipeCreate(@This, "rundll32.exe shell32.dll,Control_RunDLL timedate.cpl,,0", rtns)
	Case "CommandButton2"
		Dim a As frmTinezoneType Ptr = New frmTinezoneType
		a->ShowModal This
	Case "CommandButton3"
		If Sender.Text = "Check" Then
			Sender.Text = "Cancel"
			CommandButton4.Enabled = False
			Dim t As Double = NTP_dbl(NTP_sec(NTPAddress(ComboBoxEx1.ItemIndex)), mTzBias)
			If ntpCancel Then
				ListView1.ListItems.Item(3)->Text(1) = ""
				ListView1.ListItems.Item(4)->Text(1) = ""
				ListView1.ListItems.Item(5)->Text(1) = "Cancel"
			Else
				Dim n As Double = Now()
				ListView1.ListItems.Item(3)->Text(1) = Format(t, "yyyy/mm/dd hh:mm:ss")
				ListView1.ListItems.Item(4)->Text(1) = Format(n, "yyyy/mm/dd hh:mm:ss")
				If t = n Then
					ListView1.ListItems.Item(5)->Text(1) = "Check Passed"
				Else
					ListView1.ListItems.Item(5)->Text(1) = "Check Failed"
				End If
			End If
			Sender.Text = "Check"
			CommandButton4.Enabled = True
		Else
			ntpCancel = True
		End If
	Case "CommandButton4"
		If Sender.Text = "Calibrate" Then
			Sender.Text = "Cancel"
			CommandButton3.Enabled = False
			Print ProcessToken(@SE_SYSTEMTIME_NAME)
			Dim t As Double = NTP_dbl(NTP_sec(NTPAddress(ComboBoxEx1.ItemIndex)), 0)
			If ntpCancel Then
				ListView1.ListItems.Item(3)->Text(1) = ""
				ListView1.ListItems.Item(4)->Text(1) = ""
				ListView1.ListItems.Item(5)->Text(1) = "Cancel"
			Else
				Dim st As SYSTEMTIME Ptr = New SYSTEMTIME
				st->wYear = Year(t)
				st->wMonth = Month(t)
				st->wDay = Day(t)
				st->wHour = Hour(t)
				st->wMinute= Minute(t)
				st->wSecond = Second(t)
				Dim b As Boolean = SetSystemTime(st)
				
				t = NTP_dbl(NTP_sec(NTPAddress(ComboBoxEx1.ItemIndex)), mTzBias)
				Dim n As Double = Now()
				
				ListView1.ListItems.Item(3)->Text(1) = Format(t, "yyyy/mm/dd hh:mm:ss")
				ListView1.ListItems.Item(4)->Text(1) = Format(n, "yyyy/mm/dd hh:mm:ss")
				If b Then
					ListView1.ListItems.Item(5)->Text(1) = "Calibrate Passed"
				Else
					ListView1.ListItems.Item(5)->Text(1) = "Calibrate Failed"
					MsgRunAs
				End If
			End If
			Sender.Text = "Calibrate"
			CommandButton3.Enabled = True
		Else
			ntpCancel = True
		End If
	End Select
End Sub
