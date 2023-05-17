' MediaPlayer 媒体播放器
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__ __FILE__
		#ifdef __FB_WIN32__
			#cmdline "frmMedia.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Panel.bi"
	#include once "mff/ImageBox.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/TrackBar.bi"
	#include once "mff/Label.bi"
	#include once "mff/Dialogs.bi"
	#include once "mff/Picture.bi"
	#include once "mff/TimerComponent.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/ImageList.bi"
	#include once "mff/ComboBoxEx.bi"
	#include once "mff/CheckBox.bi"
	
	#include once "win/dshow.bi"
	#include once "string.bi"
	
	Using My.Sys.Forms
	
	#define JIF(x) If (FAILED(hr = (x))) \ {MSG(TEXT("FAILED(hr=0x%x) in ") TEXT(#x) TEXT("\n"), hr); Return hr; }
	#define LIF(x) If (FAILED(hr = (x))) \ {MSG(TEXT("FAILED(hr=0x%x) in ") TEXT(#x) TEXT("\n"), hr); }
	
	Public Enum DS_Status
		DS_Open
		DS_Close
		DS_Play
		DS_Pause
		DS_Stop
	End Enum
	
	Type frmMediaType Extends Form
		Const WM_GRAPHNOTIFY   = WM_USER + 13
		icons(35) As Integer = { _
		0, 0, 4, 0, 3, 3, 2, 3, 5, 5, _
		1, 2, 2, 1, 7, 6, 6, 0, 0, 0, _
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, _
		0, 0, 0, 0, 0, 0 _
		}
		urlsa(1, 35) As String = { _
		{ _
		"CNR 1 Voice of China", _
		"Guangdong GD News Broadcasting", _
		"Hong Kong Public", _
		"Radio Maria Macau", _
		"USA Variety National Public Radio", _
		"New York Public Radio", _
		"CNBC", _
		"The Current", _
		"Russkoye Radio", _
		"Radio Free Europe / Radio Liberty - Russian", _
		"France Inter", _
		"BBC World Service", _
		"BBC Radio 1.", _
		"France Inter", _
		"CBC Radio 1 Ontario", _
		"NER Taipei Main Program", _
		"Smile Taiwan Radio 90.5", _
		"中国之声", _
		"经济之声", _
		"音乐之声", _
		"经典音乐广播", _
		"中华之声", _
		"神州之声", _
		"大湾区之声", _
		"香港之声", _
		"民族之声", _
		"文艺之声", _
		"老年之声", _
		"中国乡村之声", _
		"藏语广播", _
		"维语广播", _
		"阅读之声", _
		"中国交通广播", _
		"哈语广播", _
		"佛山946", _
		"顺德901" _
		}, { _
		"https://lhttp.qingting.fm/live/386/64k.mp3", _
		"http://lhttp.qingting.fm/live/1254/64k.mp3", _
		"https://rthkaudio1-lh.akamaihd.net/i/radio1_1@355864/master.m3u8", _
		"http://dreamsiteradiocp2.com:8038", _
		"http://npr-ice.streamguys1.com/live.mp3", _
		"http://fm939.wnyc.org/wnycfm", _
		"http://tunein.streamguys1.com/cnbc", _
		"http://current.stream.publicradio.org/kcmp.mp3", _
		"http://rusradio.hostingradio.ru/rusradio96.aacp", _
		"https://rfe-channel-04.akacast.akamaistream.net/7/885/229654/v1/ibb.akacast.akamaistream.net/rfe_channel_04.mp3", _
		"https://icecast.radiofrance.fr/franceinter-midfi.mp3", _
		"https://a.files.bbci.co.uk/media/live/manifesto/audio/simulcast/dash/nonuk/dash_low/aks/bbc_world_service_australasia.mpd", _
		"https://a.files.bbci.co.uk/media/live/manifesto/audio/simulcast/dash/nonuk/dash_low/aks/bbc_radio_one.mpd", _
		"https://icecast.radiofrance.fr/franceinter-midfi.mp3", _
		"http://cbcliveradio-lh.akamaihd.net/i/CBCR1_ERI@508311/master.m3u8", _
		"http://cast.ner.gov.tw/1", _
		"http://59.120.255.155:8081", _
		"http://ngcdn001.cnr.cn/live/zgzs/index.m3u8", "http://ngcdn002.cnr.cn/live/jjzs/index.m3u8", _
		"http://ngcdn003.cnr.cn/live/yyzs/index.m3u8", "http://ngcdn004.cnr.cn/live/dszs/index.m3u8", _
		"http://ngcdn005.cnr.cn/live/zhzs/index.m3u8", "http://ngcdn006.cnr.cn/live/szzs/index.m3u8", _
		"http://ngcdn007.cnr.cn/live/hxzs/index.m3u8", "http://ngcdn008.cnr.cn/live/xgzs/index.m3u8", _
		"http://ngcdn009.cnr.cn/live/mzzs/index.m3u8", "http://ngcdn010.cnr.cn/live/wyzs/index.m3u8", _
		"http://ngcdn011.cnr.cn/live/lnzs/index.m3u8", "http://ngcdn017.cnr.cn/live/xczs/index.m3u8", _
		"http://ngcdn012.cnr.cn/live/zygb/index.m3u8", "http://ngcdn013.cnr.cn/live/wygb/index.m3u8", _
		"http://ngcdn014.cnr.cn/live/ylgb/index.m3u8", "http://ngcdn016.cnr.cn/live/gsgljtgb/index.m3u8", _
		"http://ngcdn025.cnr.cn/live/hygb/index.m3u8", _
		"http://play.radiofoshan.com.cn/live/1400389414_BSID_46_audio.m3u8", _
		"http://play.radiofoshan.com.cn/live/1400389414_BSID_44_audio.m3u8" _
		}}
		
		pIBasicAudio  As IBasicAudio Ptr        'Basic Audio Object
		pIBasicVideo As IBasicVideo Ptr         'Basic Video Object
		pIBasicVideo2 As IBasicVideo2 Ptr       'Basic Video Object
		pIMediaEvent As IMediaEvent Ptr         'MediaEvent Object
		pIMediaEventEx As IMediaEventEx Ptr     'MediaEventEx Object
		pIVideoWindow As IVideoWindow Ptr       'VideoWindow Object
		pIMediaControl As IMediaControl Ptr     'MediaControl Object
		pIMediaPosition As IMediaPosition Ptr   'MediaPosition Object
		pIGraphBuilder As IGraphBuilder Ptr     'GraphBuilder Object
		pIEnumFilters As IEnumFilters Ptr
		
		aHeight As Long
		aWidth As Long
		hwScale As Double
		
		Declare Sub DSCtrl(Index As DS_Status)
		Declare Function DSCreate(hWnd As HWND, wszFileName As WString) As Boolean
		Declare Sub DSUnload()
		Declare Static Sub _TextBox1_DblClick(ByRef Sender As Control)
		Declare Sub TextBox1_DblClick(ByRef Sender As Control)
		Declare Static Sub _Form_Create(ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Static Sub _Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Static Sub _cmdBtn_Click(ByRef Sender As Control)
		Declare Sub cmdBtn_Click(ByRef Sender As Control)
		Declare Static Sub _Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Static Sub _tbAudio_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Sub tbAudio_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Static Sub _tbAudio_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub tbAudio_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Static Sub _tbBalance_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Sub tbBalance_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Static Sub _tbBalance_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub tbBalance_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Static Sub _TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Sub TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Static Sub _tbPosition_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Sub tbPosition_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Static Sub _tbPosition_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub tbPosition_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Static Sub _tbPosition_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub tbPosition_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Static Sub _Picture1_Message(ByRef Sender As Control, ByRef msg As Message)
		Declare Sub Picture1_Message(ByRef Sender As Control, ByRef msg As Message)
		Declare Static Sub _ComboBoxEx1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub ComboBoxEx1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Static Sub _chkDark_Click(ByRef Sender As CheckBox)
		Declare Sub chkDark_Click(ByRef Sender As CheckBox)
		Declare Constructor
		
		Dim As Panel Panel1, Panel2, Panel3, Panel4, Panel5, Panel6
		Dim As CommandButton cmdOpen, cmdPlay, cmdClose, cmdFull, cmdBrowse, cmdScaleH, cmdScaleO
		Dim As TextBox TextBox1
		Dim As TrackBar tbVolume, tbBalance, tbPosition
		Dim As Label lblVolume, lblBalance, lblPosition, lblLength
		Dim As OpenFileDialog OpenFileDialog1
		Dim As Picture Picture1
		Dim As TimerComponent TimerComponent1
		Dim As ImageList ImageList1
		Dim As ComboBoxEx ComboBoxEx1
		Dim As CheckBox chkLoop, chkDark
	End Type
	
	Constructor frmMediaType
		' frmMedia
		With This
			.Name = "frmMedia"
			.Text = "VFBE Media Player"
			#ifdef __USE_GTK__
				This.Icon.LoadFromFile(ExePath & ".\res\MediaPlayer.ico")
			#else
				This.Icon.LoadFromResourceID(1)
			#endif
			#ifdef __FB_64BIT__
				.Caption = "VFBE Media Player64"
			#else
				.Caption = "VFBE Media Player32"
			#endif
			.Designer = @This
			.OnCreate = @_Form_Create
			.OnClose = @_Form_Close
			.OnResize = @_Form_Resize
			.StartPosition = FormStartPosition.CenterScreen
			.SetBounds 0, 0, 700, 520
		End With
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = "Panel1"
			.TabIndex = 0
			.Align = DockStyle.alTop
			.SetBounds 0, 0, 454, 40
			.Parent = @This
		End With
		' Panel2
		With Panel2
			.Name = "Panel2"
			.Text = "Panel2"
			.TabIndex = 1
			.Align = DockStyle.alBottom
			.SetBounds 0, 221, 454, 60
			.Parent = @This
		End With
		' Panel3
		With Panel3
			.Name = "Panel3"
			.Text = "Panel3"
			.TabIndex = 2
			.Align = DockStyle.alLeft
			.SetBounds 0, 0, 470, 40
			.Parent = @Panel1
		End With
		' Panel4
		With Panel4
			.Name = "Panel4"
			.Text = "Panel4"
			.TabIndex = 3
			.Align = DockStyle.alLeft
			.SetBounds 0, 0, 220, 60
			.Parent = @Panel2
		End With
		' Panel5
		With Panel5
			.Name = "Panel5"
			.Text = "Panel5"
			.TabIndex = 4
			.Align = DockStyle.alClient
			.SetBounds 220, 0, 344, 60
			.Parent = @Panel2
		End With
		' Panel6
		With Panel6
			.Name = "Panel6"
			.Text = "Panel6"
			.TabIndex = 5
			.Align = DockStyle.alTop
			.SetBounds 0, 0, 344, 20
			.Parent = @Panel5
		End With
		' cmdOpen
		With cmdOpen
			.Name = "cmdOpen"
			.Text = "Open"
			.TabIndex = 6
			.Caption = "Open"
			.SetBounds 10, 10, 50, 22
			.Designer = @This
			.OnClick = @_cmdBtn_Click
			.Parent = @Panel3
		End With
		' cmdPlay
		With cmdPlay
			.Name = "cmdPlay"
			.Text = "Play"
			.TabIndex = 7
			.Caption = "Play"
			.Enabled = False
			.SetBounds 60, 10, 50, 22
			.Designer = @This
			.OnClick = @_cmdBtn_Click
			.Parent = @Panel3
		End With
		' cmdClose
		With cmdClose
			.Name = "cmdClose"
			.Text = "CommandButton4"
			.TabIndex = 8
			.ControlIndex = 4
			.Caption = "Close"
			.Enabled = False
			.SetBounds 110, 10, 50, 22
			.Designer = @This
			.OnClick = @_cmdBtn_Click
			.Parent = @Panel3
		End With
		' cmdFull
		With cmdFull
			.Name = "cmdFull"
			.Text = "F"
			.TabIndex = 9
			.Size = Type<My.Sys.Drawing.Size>(30, 22)
			.Caption = "F"
			.Enabled = False
			.Hint = "Full screen of vedio"
			.SetBounds 170, 10, 30, 22
			.Designer = @This
			.OnClick = @_cmdBtn_Click
			.Parent = @Panel3
		End With
		' cmdScaleH
		With cmdScaleH
			.Name = "cmdScaleH"
			.Text = "1/2"
			.TabIndex = 10
			.Caption = "1/2"
			.Enabled = False
			.Hint = "1/2 of the original size of vedio"
			.SetBounds 200, 10, 30, 22
			.Designer = @This
			.OnClick = @_cmdBtn_Click
			.Parent = @Panel3
		End With
		' cmdScaleO
		With cmdScaleO
			.Name = "cmdScaleO"
			.Text = "1"
			.TabIndex = 11
			.Caption = "1"
			.Enabled = False
			.Hint = "Original size of vedio"
			.SetBounds 230, 10, 30, 22
			.Designer = @This
			.OnClick = @_cmdBtn_Click
			.Parent = @Panel3
		End With
		' cmdBrowse
		With cmdBrowse
			.Name = "cmdBrowse"
			.Text = "..."
			.TabIndex = 13
			.ControlIndex = 5
			.Location = Type<My.Sys.Drawing.Point>(250, 10)
			.Align = DockStyle.alNone
			.Size = Type<My.Sys.Drawing.Size>(30, 22)
			.Caption = "..."
			.Anchor.Right = AnchorStyle.asAnchor
			.SetBounds 440, 10, 30, 22
			.Designer = @This
			.OnClick = @_TextBox1_DblClick
			.Parent = @Panel3
		End With
		' ComboBoxEx1
		With ComboBoxEx1
			.Name = "ComboBoxEx1"
			.Text = "Net Radio List"
			.TabIndex = 12
			.ImagesList = @ImageList1
			.DropDownCount = 28
			.Style = ComboBoxEditStyle.cbDropDown
			.Location = Type<My.Sys.Drawing.Point>(290, 10)
			.Size = Type<My.Sys.Drawing.Size>(160, 22)
			.SetBounds 270, 10, 160, 22
			.Designer = @This
			.OnSelected = @_ComboBoxEx1_Selected
			.Parent = @Panel3
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = "F:\OfficePC_Update\!Media\632734Y0314.mp4"
			.Hint = "Double click to select a file from local disk."
			.TabIndex = 14
			.Align = DockStyle.alClient
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 0
			.ExtraMargins.Top = 10
			.ExtraMargins.Bottom = 9
			.Size = Type<My.Sys.Drawing.Size>(204, 22)
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.Location = Type<My.Sys.Drawing.Point>(430, 10)
			.SetBounds 470, 9, 204, 22
			.Designer = @This
			.OnDblClick = @_TextBox1_DblClick
			.Parent = @Panel1
		End With
		' Picture1
		With Picture1
			.Name = "Picture1"
			.Text = "Picture1"
			.TabIndex = 15
			.BorderStyle = BorderStyles.bsNone
			.Align = DockStyle.alClient
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 0
			.SubClass = False
			.ShowHint = True
			.BackColor = 8421504
			.Visible = True
			.ForeColor = 8421504
			.SetBounds 0, 40, 684, 341
			.Designer = @This
			.OnMessage = @_Picture1_Message
			.Parent = @This
		End With
		' lblVolume
		With lblVolume
			.Name = "lblVolume"
			.Text = "Volume: "
			.TabIndex = 16
			.Alignment = AlignmentConstants.taLeft
			.Align = DockStyle.alNone
			.ID = 1004
			.Caption = "Volume: "
			.Enabled = False
			.SetBounds 10, 5, 110, 16
			.Parent = @Panel4
		End With
		' tbVolume
		With tbVolume
			.Name = "tbVolume"
			.Text = "tbVolume"
			.TabIndex = 17
			.ExtraMargins.Left = 2
			.MaxValue = 0
			.MinValue = -10000
			.Position = 0
			.Enabled = False
			.ThumbLength = 20
			.TickStyle = TickStyles.tsAuto
			.ID = 1004
			.TickMark = TickMarks.tmTopLeft
			.Frequency = 1000
			.PageSize = 1000
			.SetBounds 0, 24, 110, 30
			.Designer = @This
			.OnChange = @_tbAudio_Change
			.OnMouseUp = @_tbAudio_MouseUp
			.Parent = @Panel4
		End With
		' lblBalance
		With lblBalance
			.Name = "lblBalance"
			.Text = "Balance: "
			.TabIndex = 18
			.Alignment = AlignmentConstants.taLeft
			.Caption = "Balance: "
			.Enabled = False
			.SetBounds 120, 5, 110, 16
			.Parent = @Panel4
		End With
		' tbBalance
		With tbBalance
			.Name = "tbBalance"
			.Text = "tbBalance"
			.TabIndex = 19
			.MaxValue = 5000
			.MinValue = -5000
			.Enabled = False
			.TickStyle = TickStyles.tsAuto
			.ID = 1004
			.TickMark = TickMarks.tmTopLeft
			.Style = TrackBarOrientation.tbHorizontal
			.SubClass = True
			.Frequency = 1000
			.PageSize = 1000
			.SetBounds 110, 24, 110, 30
			.Designer = @This
			.OnChange = @_tbAudio_Change
			.OnMouseUp = @_tbAudio_MouseUp
			.Parent = @Panel4
		End With
		' lblPosition
		With lblPosition
			.Name = "lblPosition"
			.Text = "Position: "
			.TabIndex = 20
			.Enabled = False
			.Size = Type<My.Sys.Drawing.Size>(160, 16)
			.SetBounds 10, 5, 160, 16
			.Parent = @Panel6
		End With
		' lblLength
		With lblLength
			.Name = "lblLength"
			.Text = "Length: "
			.TabIndex = 21
			.Align = DockStyle.alRight
			.ExtraMargins.Top = 5
			.ExtraMargins.Right = 10
			.Alignment = AlignmentConstants.taRight
			.Enabled = False
			.SetBounds 284, 5, 160, 15
			.Parent = @Panel6
		End With
		' tbPosition
		With tbPosition
			.Name = "tbPosition"
			.Text = "tbPosition"
			.TabIndex = 22
			.Align = DockStyle.alClient
			.PageSize = 20
			.MaxValue = 100
			.TickMark = TickMarks.tmBoth
			.TickStyle = TickStyles.tsAuto
			.ThumbLength = 20
			.ID = 1002
			.LineSize = 10
			.Frequency = 10
			.Style = TrackBarOrientation.tbHorizontal
			.Enabled = False
			.SetBounds 0, 20, 454, 40
			.Designer = @This
			.OnChange = @_tbPosition_Change
			.OnMouseDown = @_tbPosition_MouseDown
			.OnMouseUp = @_tbPosition_MouseUp
			.Parent = @Panel5
		End With
		' chkLoop
		With chkLoop
			.Name = "chkLoop"
			.Text = "Loop"
			.TabIndex = 23
			.Caption = "Loop"
			.Checked = True
			.Enabled = False
			.Size = Type<My.Sys.Drawing.Size>(50, 16)
			.SetBounds 180, 5, 50, 16
			.Designer = @This
			.Parent = @Panel6
		End With
		' chkDark
		With chkDark
			.Name = "chkDark"
			.Text = "Dark"
			.TabIndex = 24
			.Caption = "Dark"
			.Location = Type<My.Sys.Drawing.Point>(280, 5)
			.Size = Type<My.Sys.Drawing.Size>(50, 16)
			.SetBounds 240, 5, 50, 16
			.Designer = @This
			.OnClick = @_chkDark_Click
			.Parent = @Panel6
		End With
		' OpenFileDialog1
		With OpenFileDialog1
			.Name = "OpenFileDialog1"
			.SetBounds 0, 0, 16, 16
			.Parent = @Panel3
		End With
		' TimerComponent1
		With TimerComponent1
			.Name = "TimerComponent1"
			.Interval = 200
			.SetBounds 20, 0, 16, 16
			.Designer = @This
			.OnTimer = @_TimerComponent1_Timer
			.Parent = @Panel3
		End With
		' ImageList1
		With ImageList1
			.Name = "ImageList1"
			.SetBounds 40, 0, 16, 16
			.Designer = @This
			.Parent = @Panel3
		End With
	End Constructor
	
	Private Sub frmMediaType._chkDark_Click(ByRef Sender As CheckBox)
		(*Cast(frmMediaType Ptr, Sender.Designer)).chkDark_Click(Sender)
	End Sub
	
	Private Sub frmMediaType._ComboBoxEx1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		(*Cast(frmMediaType Ptr, Sender.Designer)).ComboBoxEx1_Selected(Sender, ItemIndex)
	End Sub
	
	Private Sub frmMediaType._Picture1_Message(ByRef Sender As Control, ByRef msg As Message)
		(*Cast(frmMediaType Ptr, Sender.Designer)).Picture1_Message(Sender, msg)
	End Sub
	
	Private Sub frmMediaType._tbPosition_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		(*Cast(frmMediaType Ptr, Sender.Designer)).tbPosition_MouseUp(Sender, MouseButton, x, y, Shift)
	End Sub
	
	Private Sub frmMediaType._tbPosition_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		(*Cast(frmMediaType Ptr, Sender.Designer)).tbPosition_MouseDown(Sender, MouseButton, x, y, Shift)
	End Sub
	
	Private Sub frmMediaType._tbPosition_Change(ByRef Sender As TrackBar, Position As Integer)
		(*Cast(frmMediaType Ptr, Sender.Designer)).tbPosition_Change(Sender, Position)
	End Sub
	
	Private Sub frmMediaType._tbAudio_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		(*Cast(frmMediaType Ptr, Sender.Designer)).tbAudio_MouseUp(Sender, MouseButton, x, y, Shift)
	End Sub
	
	Private Sub frmMediaType._TimerComponent1_Timer(ByRef Sender As TimerComponent)
		(*Cast(frmMediaType Ptr, Sender.Designer)).TimerComponent1_Timer(Sender)
	End Sub
	
	Private Sub frmMediaType._tbAudio_Change(ByRef Sender As TrackBar, Position As Integer)
		(*Cast(frmMediaType Ptr, Sender.Designer)).tbAudio_Change(Sender, Position)
	End Sub
	
	Private Sub frmMediaType._Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		(*Cast(frmMediaType Ptr, Sender.Designer)).Form_Resize(Sender, NewWidth, NewHeight)
	End Sub
	
	Private Sub frmMediaType._cmdBtn_Click(ByRef Sender As Control)
		(*Cast(frmMediaType Ptr, Sender.Designer)).cmdBtn_Click(Sender)
	End Sub
	
	Private Sub frmMediaType._Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		(*Cast(frmMediaType Ptr, Sender.Designer)).Form_Close(Sender, Action)
	End Sub
	
	Private Sub frmMediaType._Form_Create(ByRef Sender As Control)
		(*Cast(frmMediaType Ptr, Sender.Designer)).Form_Create(Sender)
	End Sub
	
	Private Sub frmMediaType._TextBox1_DblClick(ByRef Sender As Control)
		(*Cast(frmMediaType Ptr, Sender.Designer)).TextBox1_DblClick(Sender)
	End Sub
	
	Dim Shared frmMedia As frmMediaType
	
	#if __MAIN_FILE__ = __FILE__
		
		frmMedia.Show
		App.Run
	#endif
'#End Region

'https://learn.microsoft.com/en-us/windows/win32/directshow/event-notification-codes.
Private Function MsgStr(MSG As Long) ByRef As String
	Static r As String
	
	Select Case MSG
	Case EC_SYSTEMBASE
		r = "EC_SYSTEMBASE = " & EC_SYSTEMBASE
	Case EC_USER
		r = "EC_USER = " & EC_USER
	Case EC_COMPLETE
		r = "EC_COMPLETE = " & EC_COMPLETE
	Case EC_USERABORT
		r = "EC_USERABORT = " & EC_USERABORT
	Case EC_ERRORABORT
		r = "EC_ERRORABORT = " & EC_ERRORABORT
	Case EC_TIME
		r = "EC_TIME = " & EC_TIME
	Case EC_REPAINT
		r = "EC_REPAINT = " & EC_REPAINT
	Case EC_STREAM_ERROR_STOPPED
		r = "EC_STREAM_ERROR_STOPPED = " & EC_STREAM_ERROR_STOPPED
	Case EC_STREAM_ERROR_STILLPLAYING
		r = "EC_STREAM_ERROR_STILLPLAYING = " & EC_STREAM_ERROR_STILLPLAYING
	Case EC_ERROR_STILLPLAYING
		r = "EC_ERROR_STILLPLAYING = " & EC_ERROR_STILLPLAYING
	Case EC_PALETTE_CHANGED
		r = "EC_PALETTE_CHANGED = " & EC_PALETTE_CHANGED
	Case EC_VIDEO_SIZE_CHANGED
		r = "EC_VIDEO_SIZE_CHANGED = " & EC_VIDEO_SIZE_CHANGED
	Case EC_QUALITY_CHANGE
		r = "EC_QUALITY_CHANGE = " & EC_QUALITY_CHANGE
	Case EC_SHUTTING_DOWN
		r = "EC_SHUTTING_DOWN = " & EC_SHUTTING_DOWN
	Case EC_CLOCK_CHANGED
		r = "EC_CLOCK_CHANGED = " & EC_CLOCK_CHANGED
	Case EC_PAUSED
		r = "EC_PAUSED = " & EC_PAUSED
	Case EC_OPENING_FILE
		r = "EC_OPENING_FILE = " & EC_OPENING_FILE
	Case EC_BUFFERING_DATA
		r = "EC_BUFFERING_DATA = " & EC_BUFFERING_DATA
	Case EC_FULLSCREEN_LOST
		r = "EC_FULLSCREEN_LOST = " & EC_FULLSCREEN_LOST
	Case EC_ACTIVATE
		r = "EC_ACTIVATE = " & EC_ACTIVATE
	Case EC_NEED_RESTART
		r = "EC_NEED_RESTART = " & EC_NEED_RESTART
	Case EC_WINDOW_DESTROYED
		r = "EC_WINDOW_DESTROYED = " & EC_WINDOW_DESTROYED
	Case EC_DISPLAY_CHANGED
		r = "EC_DISPLAY_CHANGED = " & EC_DISPLAY_CHANGED
	Case EC_STARVATION
		r = "EC_STARVATION = " & EC_STARVATION
	Case EC_OLE_EVENT
		r = "EC_OLE_EVENT = " & EC_OLE_EVENT
	Case EC_NOTIFY_WINDOW
		r = "EC_NOTIFY_WINDOW = " & EC_NOTIFY_WINDOW
	Case EC_STREAM_CONTROL_STOPPED
		r = "EC_STREAM_CONTROL_STOPPED = " & EC_STREAM_CONTROL_STOPPED
	Case EC_STREAM_CONTROL_STARTED
		r = "EC_STREAM_CONTROL_STARTED = " & EC_STREAM_CONTROL_STARTED
	Case EC_END_OF_SEGMENT
		r = "EC_END_OF_SEGMENT = " & EC_END_OF_SEGMENT
	Case EC_SEGMENT_STARTED
		r = "EC_SEGMENT_STARTED = " & EC_SEGMENT_STARTED
	Case EC_LENGTH_CHANGED
		r = "EC_LENGTH_CHANGED = " & EC_LENGTH_CHANGED
	Case EC_DEVICE_LOST
		r = "EC_DEVICE_LOST = " & EC_DEVICE_LOST
	Case EC_SAMPLE_NEEDED
		r = "EC_SAMPLE_NEEDED = " & EC_SAMPLE_NEEDED
	Case EC_PROCESSING_LATENCY
		r = "EC_PROCESSING_LATENCY = " & EC_PROCESSING_LATENCY
	Case EC_SAMPLE_LATENCY
		r = "EC_SAMPLE_LATENCY = " & EC_SAMPLE_LATENCY
	Case EC_SCRUB_TIME
		r = "EC_SCRUB_TIME = " & EC_SCRUB_TIME
	Case EC_STEP_COMPLETE
		r = "EC_STEP_COMPLETE = " & EC_STEP_COMPLETE
	Case EC_NEW_PIN
		r = "EC_NEW_PIN = " & EC_NEW_PIN
	Case EC_RENDER_FINISHED
		r = "EC_RENDER_FINISHED = " & EC_RENDER_FINISHED
	Case EC_TIMECODE_AVAILABLE
		r = "EC_TIMECODE_AVAILABLE = " & EC_TIMECODE_AVAILABLE
	Case EC_EXTDEVICE_MODE_CHANGE
		r = "EC_EXTDEVICE_MODE_CHANGE = " & EC_EXTDEVICE_MODE_CHANGE
	Case EC_STATE_CHANGE
		r = "EC_STATE_CHANGE = " & EC_STATE_CHANGE
	Case EC_PLEASE_REOPEN
		r = "EC_PLEASE_REOPEN = " & EC_PLEASE_REOPEN
	Case EC_STATUS
		r = "EC_STATUS = " & EC_STATUS
	Case EC_MARKER_HIT
		r = "EC_MARKER_HIT = " & EC_MARKER_HIT
	Case EC_LOADSTATUS
		r = "EC_LOADSTATUS = " & EC_LOADSTATUS
	Case EC_FILE_CLOSED
		r = "EC_FILE_CLOSED = " & EC_FILE_CLOSED
	Case EC_ERRORABORTEX
		r = "EC_ERRORABORTEX = " & EC_ERRORABORTEX
	Case EC_EOS_SOON
		r = "EC_EOS_SOON = " & EC_EOS_SOON
	Case EC_CONTENTPROPERTY_CHANGED
		r = "EC_CONTENTPROPERTY_CHANGED = " & EC_CONTENTPROPERTY_CHANGED
	Case EC_BANDWIDTHCHANGE
		r = "EC_BANDWIDTHCHANGE = " & EC_BANDWIDTHCHANGE
	Case EC_VIDEOFRAMEREADY
		r = "EC_VIDEOFRAMEREADY = " & EC_VIDEOFRAMEREADY
	Case EC_GRAPH_CHANGED
		r = "EC_GRAPH_CHANGED = " & EC_GRAPH_CHANGED
	Case EC_CLOCK_UNSET
		r = "EC_CLOCK_UNSET = " & EC_CLOCK_UNSET
	Case EC_VMR_RENDERDEVICE_SET
		r = "EC_VMR_RENDERDEVICE_SET = " & EC_VMR_RENDERDEVICE_SET
	Case EC_VMR_SURFACE_FLIPPED
		r = "EC_VMR_SURFACE_FLIPPED = " & EC_VMR_SURFACE_FLIPPED
	Case EC_VMR_RECONNECTION_FAILED
		r = "EC_VMR_RECONNECTION_FAILED = " & EC_VMR_RECONNECTION_FAILED
	Case EC_PREPROCESS_COMPLETE
		r = "EC_PREPROCESS_COMPLETE = " & EC_PREPROCESS_COMPLETE
	Case EC_CODECAPI_EVENT
		r = "EC_CODECAPI_EVENT = " & EC_CODECAPI_EVENT
	Case EC_BUILT
		r = "EC_BUILT = " & EC_BUILT
	Case EC_UNBUILT
		r = "EC_UNBUILT = " & EC_UNBUILT
	Case EC_WMT_EVENT_BASE
		r = "EC_WMT_EVENT_BASE = " & EC_WMT_EVENT_BASE
	Case EC_WMT_INDEX_EVENT
		r = "EC_WMT_INDEX_EVENT = " & EC_WMT_INDEX_EVENT
	Case EC_WMT_EVENT
		r = "EC_WMT_EVENT = " & EC_WMT_EVENT
	End Select
	
	Return r
End Function

Private Sub frmMediaType.DSCtrl(Index As DS_Status)
	Dim b As Boolean = False
	Dim hr As HRESULT
	Static d As Double = 0
	Select Case Index
	Case DS_Status.DS_Open
		DSCtrl(DS_Status.DS_Close)
		If DSCreate(Picture1.Handle, TextBox1.Text) Then
			If pIMediaPosition Then pIMediaPosition->lpVtbl->get_Duration(pIMediaPosition, @d)
			If d Then
				tbPosition.MaxValue = CInt(d)
				tbPosition.PageSize = CInt(d / 10)
				tbPosition.Frequency = CInt(d / 10)
				lblLength.Text = "Length: " & Format(d, "#,#0.000")
				lblLength.Enabled = True
				chkLoop.Enabled = True
			Else
				tbPosition.Enabled = False
				lblLength.Text = "Length: NA"
				lblLength.Enabled = False
				chkLoop.Enabled = False
			End If
			tbVolume.Position = tbVolume.Position
			tbBalance.Position = tbBalance.Position
			tbPosition.Position = 0
			cmdPlay.Text = "Play"
			DSCtrl(DS_Status.DS_Play)
			b = True
		End If
	Case DS_Status.DS_Close
		lblLength.Enabled = False
		chkLoop.Enabled = False
		TimerComponent1.Enabled = False
		tbPosition.Position = 0
		cmdFull.Enabled = False
		DSUnload
	Case DS_Status.DS_Play
		cmdPlay.Text = "Pause"
		If pIMediaControl Then hr = pIMediaControl->lpVtbl->Run(pIMediaControl)
		TimerComponent1.Enabled = True
		b = True
	Case DS_Status.DS_Pause
		cmdPlay.Text = "Play"
		If pIMediaControl Then hr = pIMediaControl->lpVtbl->Pause(pIMediaControl)
		TimerComponent1.Enabled = False
		b = True
	Case DS_Status.DS_Stop
		If pIMediaControl Then hr = pIMediaControl->lpVtbl->Stop(pIMediaControl)
		TimerComponent1.Enabled = False
		b = True
	End Select
	If d Then tbPosition.Enabled = b
	tbVolume.Enabled = b
	tbBalance.Enabled = b
	lblVolume.Enabled = b
	lblBalance.Enabled = b
	lblPosition.Enabled = b
	cmdPlay.Enabled = b
	cmdClose.Enabled = b
End Sub

Private Function frmMediaType.DSCreate(hWnd As HWND, wszFileName As WString) As Boolean
	Dim hr As HRESULT
	hr = CoCreateInstance(@CLSID_FilterGraph, NULL, CLSCTX_ALL, @IID_IGraphBuilder, @pIGraphBuilder)
	If pIGraphBuilder = NULL Then This.Caption = Mid(This.Caption, 1, Len(" VFBE Media Player64"))  & " -Error - Can't create Filter Graph！" : Return False
	
	hr = pIGraphBuilder->lpVtbl->QueryInterface(pIGraphBuilder, @IID_IMediaControl, @pIMediaControl)
	hr = pIGraphBuilder->lpVtbl->QueryInterface(pIGraphBuilder, @IID_IBasicAudio, @pIBasicAudio)
	hr = pIGraphBuilder->lpVtbl->QueryInterface(pIGraphBuilder, @IID_IBasicVideo, @pIBasicVideo)
	hr = pIGraphBuilder->lpVtbl->QueryInterface(pIGraphBuilder, @IID_IBasicVideo2, @pIBasicVideo2)
	hr = pIGraphBuilder->lpVtbl->QueryInterface(pIGraphBuilder, @IID_IMediaEvent, @pIMediaEvent)
	hr = pIGraphBuilder->lpVtbl->QueryInterface(pIGraphBuilder, @IID_IMediaEventEx, @pIMediaEventEx)
	hr = pIGraphBuilder->lpVtbl->QueryInterface(pIGraphBuilder, @IID_IVideoWindow, @pIVideoWindow)
	hr = pIGraphBuilder->lpVtbl->QueryInterface(pIGraphBuilder, @IID_IMediaPosition, @pIMediaPosition)
	hr = pIGraphBuilder->lpVtbl->QueryInterface(pIGraphBuilder, @IID_IFilterInfo, @pIEnumFilters)
	
	'Render the file
	hr = pIMediaControl->lpVtbl->RenderFile(pIMediaControl, StrPtr(wszFileName))
	'Need Install decoding package like lav
	If hr < 0 Then This.Caption = Mid(This.Caption, 1, Len(" VFBE Media Player64"))  & " -Error - Can't Render File! Install LAV from https://github.com/Nevcairiel/LAVFilters/releases" : Return False
	'Set the window owner and style
	hr = pIVideoWindow->lpVtbl->put_Visible(pIVideoWindow, OAFALSE)
	hr = pIVideoWindow->lpVtbl->put_Owner(pIVideoWindow, Cast(OAHWND, hWnd))
	hr = pIVideoWindow->lpVtbl->put_WindowStyle(pIVideoWindow, WS_CHILD Or WS_CLIPSIBLINGS Or WS_CLIPCHILDREN)
	
	'Have the graph signal event via window callbacks for performance
	hr = pIMediaEventEx->lpVtbl->SetNotifyWindow(pIMediaEventEx, Cast(OAHWND, hWnd), WM_GRAPHNOTIFY, 0)
	
	Dim As Long lVisible
	hr = pIVideoWindow->lpVtbl->get_Visible(pIVideoWindow, @lVisible)
	
	Debug.Print "lVisible = " & lVisible
	Debug.Print "hr = " & hr
	If (FAILED(hr)) Then
		Debug.Print "audio only"
		This.Height = aHeight
	Else
		Debug.Print "with vedio"
		Dim vWidth As Long
		Dim vHeight As Long
		pIBasicVideo->lpVtbl->get_VideoWidth(pIBasicVideo, @vWidth)
		pIBasicVideo->lpVtbl->get_VideoHeight(pIBasicVideo, @vHeight)
		hwScale= vHeight / vWidth
		This.Height = Picture1.Width*hwScale+ aHeight
		Form_Resize(Me, 0, 0)
		'Make the videowindow visible
		hr = pIVideoWindow->lpVtbl->put_Visible(pIVideoWindow, OATRUE)
		cmdFull.Enabled = True
	End If
	cmdScaleH.Enabled = cmdFull.Enabled 
	cmdScaleO.Enabled = cmdFull.Enabled 
	Return True
End Function

Private Sub frmMediaType.DSUnload()
	If pIVideoWindow Then pIVideoWindow->lpVtbl->put_Visible(pIVideoWindow, OAFALSE)
	
	If pIMediaControl Then pIMediaControl->lpVtbl->Release(pIMediaControl)
	If pIBasicAudio Then pIBasicAudio->lpVtbl->Release(pIBasicAudio)
	If pIBasicVideo Then pIBasicVideo->lpVtbl->Release(pIBasicVideo)
	If pIBasicVideo2 Then pIBasicVideo2->lpVtbl->Release(pIBasicVideo2)
	If pIMediaEvent Then pIMediaEvent->lpVtbl->Release(pIMediaEvent)
	If pIMediaEventEx Then pIMediaEventEx->lpVtbl->Release(pIMediaEventEx)
	If pIVideoWindow Then pIVideoWindow->lpVtbl->Release(pIVideoWindow)
	If pIMediaPosition Then pIMediaPosition->lpVtbl->Release(pIMediaPosition)
	If pIGraphBuilder Then pIGraphBuilder->lpVtbl->Release(pIGraphBuilder)
	If pIEnumFilters Then pIEnumFilters->lpVtbl->Release(pIEnumFilters)
	
	pIMediaControl = NULL
	pIBasicAudio = NULL
	pIBasicVideo = NULL
	pIBasicVideo2 = NULL
	pIMediaEvent = NULL
	pIMediaEventEx = NULL
	pIVideoWindow = NULL
	pIMediaPosition = NULL
	pIGraphBuilder = NULL
End Sub

Private Sub frmMediaType.TextBox1_DblClick(ByRef Sender As Control)
	If OpenFileDialog1.Execute() Then
		TextBox1.Text = OpenFileDialog1.FileName
		cmdPlay.SetFocus
	End If
End Sub

Private Sub frmMediaType.Form_Create(ByRef Sender As Control)
	Dim hr As HRESULT = CoInitialize(0)
	aHeight = This.Height - Picture1.Height
	aWidth = This.Width - Picture1.Width
	CoInitializeEx(NULL, COINIT_APARTMENTTHREADED)
	
	ImageList1.Add "CHN"
	ImageList1.Add "France"
	ImageList1.Add "uk"
	ImageList1.Add "USA"
	ImageList1.Add "HKG"
	ImageList1.Add "RUS"
	ImageList1.Add "TWN"
	ImageList1.Add "CAN"
	
	Dim i As Integer
	For i = 0 To 35
		ComboBoxEx1.Items.Add(urlsa(0, i), @icons(i), icons(i), icons(i), icons(i))
	Next
End Sub

Private Sub frmMediaType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	DSCtrl(DS_Status.DS_Close)
	CoUninitialize()
End Sub

Private Sub frmMediaType.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	'If Picture1.Visible= False Then Exit Sub
	Dim rc As Rect
	GetClientRect(Picture1.Handle, @rc)
	If pIVideoWindow Then
		pIVideoWindow->lpVtbl->SetWindowPosition(pIVideoWindow, rc.Left, rc.Top, rc.Right, rc.Bottom)
		RedrawWindow Picture1.Handle, @rc, 0, RDW_INVALIDATE Or RDW_UPDATENOW
	End If
	If This.Height < aHeight Then This.Height = aHeight
End Sub

Private Sub frmMediaType.cmdBtn_Click(ByRef Sender As Control)
	Dim vWidth As Long
	Dim vHeight As Long
	Select Case Sender.Name
	Case "cmdOpen"
		DSCtrl(DS_Status.DS_Open)
	Case "cmdPlay"
		Select Case Sender.Text
		Case "Play"
			DSCtrl(DS_Status.DS_Play)
		Case "Pause"
			DSCtrl(DS_Status.DS_Pause)
		End Select
	Case "cmdStop"
		DSCtrl(DS_Status.DS_Stop)
	Case "cmdClose"
		DSCtrl(DS_Status.DS_Close)
	Case "cmdFull"
		If pIVideoWindow = NULL Then Exit Sub
		Dim lMode As Long
		pIVideoWindow->lpVtbl->get_FullScreenMode(pIVideoWindow, @lMode)
		If lMode = OAFALSE Then
			lMode = OATRUE
		Else
			lMode = OAFALSE
		End If
		pIVideoWindow->lpVtbl->put_FullScreenMode(pIVideoWindow, lMode)
	Case "cmdScaleH"
		pIBasicVideo->lpVtbl->get_VideoWidth(pIBasicVideo, @vWidth)
		pIBasicVideo->lpVtbl->get_VideoHeight(pIBasicVideo, @vHeight)
		This.Width = vWidth / 2 + aWidth
		This.Height = vHeight / 2 + aHeight
	Case "cmdScaleO"
		pIBasicVideo->lpVtbl->get_VideoWidth(pIBasicVideo, @vWidth)
		pIBasicVideo->lpVtbl->get_VideoHeight(pIBasicVideo, @vHeight)
		This.Width = vWidth + aWidth
		This.Height = vHeight + aHeight
	End Select
End Sub

Private Sub frmMediaType.tbAudio_Change(ByRef Sender As TrackBar, Position As Integer)
	Select Case Sender.Name
	Case "tbVolume"
		If pIBasicAudio Then
			pIBasicAudio->lpVtbl->put_Volume(pIBasicAudio, Position)
		End If
		lblVolume.Text = "Volume: " & Position
	Case "tbBalance"
		If pIBasicAudio Then
			pIBasicAudio->lpVtbl->put_Balance(pIBasicAudio, Position)
		End If
		lblBalance.Text = "Balance: " & Position
	End Select
End Sub

Private Sub frmMediaType.tbAudio_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	Select Case Sender.Name
	Case "tbVolume"
		If MouseButton = 1 Then
			tbVolume.Position = -5000
		End If
	Case "tbBalance"
		If MouseButton = 1 Then
			tbBalance.Position = 0
		End If
	End Select
End Sub

Private Sub frmMediaType.tbPosition_Change(ByRef Sender As TrackBar, Position As Integer)
	If TimerComponent1.Enabled = True Then Exit Sub
	If pIMediaPosition Then pIMediaPosition->lpVtbl->put_CurrentPosition(pIMediaPosition, Position)
	lblPosition.Text = "Position: " & Format(Position, "#,#0.000")
End Sub

Private Sub frmMediaType.tbPosition_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	If MouseButton = 0 Then
		If pIMediaPosition Then TimerComponent1.Enabled = False
	End If
End Sub

Private Sub frmMediaType.tbPosition_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	If MouseButton = 0 Then
		If pIMediaPosition Then
			pIMediaPosition->lpVtbl->put_CurrentPosition(pIMediaPosition, tbPosition.Position)
			TimerComponent1.Enabled = True
		End If
	End If
End Sub

Private Sub frmMediaType.TimerComponent1_Timer(ByRef Sender As TimerComponent)
	Dim d As Double= 0
	If pIMediaPosition Then
		pIMediaPosition->lpVtbl->get_CurrentPosition(pIMediaPosition , @d)
		If tbPosition.Enabled Then
			tbPosition.Position = CInt(d)
		End If
		lblPosition.Text = "Position: " & Format(d, "#,#0.000")
	Else
		lblPosition.Text = "Position: " & Format(d, "#,#0.000")
		tbPosition.Position = CInt(d)
		TimerComponent1.Enabled = False
	End If
End Sub

Private Sub frmMediaType.Picture1_Message(ByRef Sender As Control, ByRef msg As Message)
	Select Case msg.Msg
	Case WM_GRAPHNOTIFY
		'WM_GRAPHNOTIFY is an ordinary Windows message. Whenever the Filter Graph Manager
		'puts a new event on the event queue, it posts a WM_GRAPHNOTIFY message to the
		'designated application window. The message's lParam parameter is equal to the third
		'parameter in SetNotifyWindow. This parameter enables you to send instance data with
		'the message. The window message's wParam parameter is always zero.
		
		Dim lEventCode As Long
		Dim lParam1 As LONG_PTR
		Dim lParam2 As LONG_PTR
		
		If pIMediaEventEx Then
			Debug.Print "Enter event loop"
			Do
				Dim hr As HRESULT
				hr = pIMediaEventEx->lpVtbl->GetEvent(pIMediaEventEx, @lEventCode, @lParam1, @lParam2, 0)
				If hr <> S_OK Then Exit Do
				pIMediaEventEx->lpVtbl->FreeEventParams(pIMediaEventEx, lEventCode, lParam1, lParam2)
				Debug.Print MsgStr(lEventCode)
				If lEventCode = EC_COMPLETE Then
					If chkLoop.Checked Then
						pIMediaPosition->lpVtbl->put_CurrentPosition(pIMediaPosition , 0)
						pIMediaControl->lpVtbl->Run(pIMediaControl)
					End If
				End If
			Loop
			Debug.Print "Exit event loop"
		End If
	End Select
End Sub

Private Sub frmMediaType.ComboBoxEx1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	TextBox1.Text = urlsa(1, ItemIndex)
	This.Caption = Mid(This.Caption, 1, Len(" VFBE Media Player64"))
End Sub

Private Sub frmMediaType.chkDark_Click(ByRef Sender As CheckBox)
	App.DarkMode= chkDark.Checked
	InvalidateRect(0, 0, True)
End Sub
