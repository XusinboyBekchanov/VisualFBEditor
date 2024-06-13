' MediaPlayer 媒体播放器
' Copyright (c) 2024 CM.Wang
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
	#include once "mff/Menus.bi"
	
	#include once "win/dshow.bi"
	#include once "crt/stdio.bi"
	#include once "string.bi"
	#include once "vbcompat.bi"
	
	Using My.Sys.Forms
	
	Public Enum DSStatus
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
		"https://play.radiofoshan.com.cn/live/1400389414_BSID_46_audio.m3u8", _
		"https://play.radiofoshan.com.cn/live/1400389414_BSID_44_audio.m3u8" _
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
		mfilename As ZString Ptr = CAllocate(0, 1024)
		
		Declare Property WithAudio(val As Long)
		Declare Property WithVedio(Opt As Boolean, Val As Boolean)
		Declare Property WithPosition(val As Double)
		
		mWithAudio As Boolean
		mWithVedio As Boolean
		mWithPosition As Boolean
		
		Declare Sub DSCtrl(Index As DSStatus)
		Declare Function DSCreate(hWndDiaplay As HWND, hWndMessage As HWND, wszFileName As WString) As Boolean
		Declare Sub DSUnload()
		
		Declare Sub DesktopLoad(v As Boolean)
		Declare Sub MenuAddMonitor()
		mMenuMtr(Any) As MenuItem Ptr
		mMenuMtrCount As Integer = -1
		
		hwndProgManager As HWND = NULL
		hwndDesktop As HWND = NULL
		hwndParent As HWND = NULL
		hwndTemp As HWND = NULL
		hwndOrg As HWND = NULL
		
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub cmdBtn_Click(ByRef Sender As Control)
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub tbAudio_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Sub tbAudio_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub tbBalance_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Sub tbBalance_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Sub tbPosition_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Sub tbPosition_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub tbPosition_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub ComboBoxEx1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
		Declare Sub Form_Message(ByRef Sender As Control, ByRef Msg As Message)
		Declare Sub mnu_Click(ByRef Sender As MenuItem)
		Declare Sub mnuMain_Click(ByRef Sender As MenuItem)
		Declare Constructor
		
		Dim As Panel Panel1, Panel2
		Dim As CommandButton cmdOpen, cmdPlay, cmdClose, cmdBrowse
		Dim As TextBox TextBox1
		Dim As TrackBar tbVolume, tbBalance, tbPosition
		Dim As Label lblVolume, lblBalance, lblPosition, lblLength
		Dim As OpenFileDialog OpenFileDialog1
		Dim As Picture Picture1
		Dim As TimerComponent TimerComponent1
		Dim As ImageList ImageList1
		Dim As ComboBoxEx ComboBoxEx1
		Dim As MainMenu MainMenu1
		Dim As PopupMenu PopupMenu1
		Dim As MenuItem mnuFull, mnu11scale, mnu12scale, mnu13scale, mnu14scale, mnuBar5, mnuCapture, mnuBar4, mnuFaster, mnuSlower, mnuNormal, mnuBar3, mnuLoop, mnuBar2, mnuBar6, mnuExit, mnuDark, mnuClose, mnuPlay, mnuOpen, mnuFile, mnuPause, mnuBar1, mnuScale, mnuMonitor, mnuNotDesktop
		Dim As MenuItem MenuItem1, mnuMainFile, MenuItem3, mnuMainOpen, mnuMainPlay, mnuMainPause, mnuMainClose, MenuItem8, mnuMainLoop, mnuMainDark, MenuItem11, mnuMainSlower, mnuMainNormal, mnuMainFaster, MenuItem15, mnuMainNone, mnuMainCapture, MenuItem18, mnuMainExit, MenuItem2, mnuMain14scale, mnuMain12scale, mnuMain11scale, mnuMainFull, mnuMain13scale
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
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Form_Resize)
			.StartPosition = FormStartPosition.CenterScreen
			.OnDropFile = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Filename As WString), @Form_DropFile)
			.AllowDrop = True
			.OnMessage = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Msg As Message), @Form_Message)
			.ContextMenu = @PopupMenu1
			.BackColor = 8421504
			.Menu = @MainMenu1
			.SetBounds 0, 0, 700, 519
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
		' Picture1
		With Picture1
			.Name = "Picture1"
			.Text = "Picture1"
			.TabIndex = 2
			.BorderStyle = BorderStyles.bsNone
			.Align = DockStyle.alClient
			.BackColor = 8421504
			.Visible = True
			.ForeColor = 8421504
			.Enabled = False
			.SetBounds 0, 40, 684, 381
			.Designer = @This
			.Parent = @This
		End With
		' Panel2
		With Panel2
			.Name = "Panel2"
			.Text = "Panel2"
			.TabIndex = 3
			.Align = DockStyle.alBottom
			.SetBounds 0, 221, 454, 60
			.Parent = @This
		End With
		' cmdPlay
		With cmdPlay
			.Name = "cmdPlay"
			.Text = "Play"
			.TabIndex = 5
			.Caption = "Play"
			.Enabled = False
			.SetBounds 60, 10, 50, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdBtn_Click)
			.Parent = @Panel1
		End With
		' cmdOpen
		With cmdOpen
			.Name = "cmdOpen"
			.Text = "Open"
			.TabIndex = 4
			.Caption = "Open"
			.SetBounds 10, 10, 50, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdBtn_Click)
			.Parent = @Panel1
		End With
		' cmdClose
		With cmdClose
			.Name = "cmdClose"
			.Text = "CommandButton4"
			.TabIndex = 6
			.Caption = "Close"
			.Enabled = False
			.SetBounds 110, 10, 50, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdBtn_Click)
			.Parent = @Panel1
		End With
		' ComboBoxEx1
		With ComboBoxEx1
			.Name = "ComboBoxEx1"
			.Text = "Net Radio List"
			.TabIndex = 7
			.ImagesList = @ImageList1
			.DropDownCount = 28
			.Style = ComboBoxEditStyle.cbDropDown
			.Location = Type<My.Sys.Drawing.Point>(290, 10)
			.Size = Type<My.Sys.Drawing.Size>(160, 22)
			.SetBounds 170, 10, 210, 22
			.Designer = @This
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @ComboBoxEx1_Selected)
			.Parent = @Panel1
		End With
		' cmdBrowse
		With cmdBrowse
			.Name = "cmdBrowse"
			.Text = "..."
			.TabIndex = 8
			.Location = Type<My.Sys.Drawing.Point>(250, 10)
			.Size = Type<My.Sys.Drawing.Size>(30, 22)
			.Caption = "..."
			.SetBounds 390, 10, 30, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdBtn_Click)
			.Parent = @Panel1
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = "F:\OfficePC_Update\!Media\632734Y0314.mp4"
			.TabIndex = 9
			.Size = Type<My.Sys.Drawing.Size>(204, 22)
			.Anchor.Right = AnchorStyle.asAnchor
			.Location = Type<My.Sys.Drawing.Point>(430, 10)
			.Anchor.Left = AnchorStyle.asAnchor
			.SetBounds 420, 10, 254, 21
			.Designer = @This
			.Parent = @Panel1
		End With
		' lblVolume
		With lblVolume
			.Name = "lblVolume"
			.Text = "Volume: "
			.TabIndex = 10
			.Alignment = AlignmentConstants.taLeft
			.Align = DockStyle.alNone
			.ID = 1004
			.Caption = "Volume: "
			.Enabled = False
			.SetBounds 10, 5, 110, 16
			.Parent = @Panel2
		End With
		' tbVolume
		With tbVolume
			.Name = "tbVolume"
			.Text = "tbVolume"
			.TabIndex = 11
			.ExtraMargins.Left = 2
			.MaxValue = 0
			.MinValue = -10000
			.Position = -1000
			.Enabled = False
			.ThumbLength = 20
			.TickStyle = TickStyles.tsAuto
			.ID = 1004
			.TickMark = TickMarks.tmTopLeft
			.Frequency = 1000
			.PageSize = 1000
			.SetBounds 0, 24, 110, 30
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TrackBar, Position As Integer), @tbAudio_Change)
			.OnMouseUp = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @tbAudio_MouseUp)
			.Parent = @Panel2
		End With
		' lblBalance
		With lblBalance
			.Name = "lblBalance"
			.Text = "Balance: 0"
			.TabIndex = 12
			.Alignment = AlignmentConstants.taLeft
			.Caption = "Balance: 0"
			.Enabled = False
			.SetBounds 120, 5, 110, 16
			.Parent = @Panel2
		End With
		' tbBalance
		With tbBalance
			.Name = "tbBalance"
			.Text = "tbBalance"
			.TabIndex = 13
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
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TrackBar, Position As Integer), @tbAudio_Change)
			.OnMouseUp = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @tbAudio_MouseUp)
			.Parent = @Panel2
		End With
		' lblPosition
		With lblPosition
			.Name = "lblPosition"
			.Text = "Position: "
			.TabIndex = 14
			.Size = Type<My.Sys.Drawing.Size>(160, 16)
			.SetBounds 230, 5, 160, 16
			.Parent = @Panel2
		End With
		' lblLength
		With lblLength
			.Name = "lblLength"
			.Text = "Length: "
			.TabIndex = 15
			.Align = DockStyle.alNone
			.ExtraMargins.Top = 5
			.ExtraMargins.Right = 10
			.Alignment = AlignmentConstants.taRight
			.Enabled = False
			.Anchor.Right = AnchorStyle.asAnchor
			.SetBounds 514, 5, 160, 15
			.Parent = @Panel2
		End With
		' tbPosition
		With tbPosition
			.Name = "tbPosition"
			.Text = "tbPosition"
			.TabIndex = 20
			.Align = DockStyle.alNone
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
			.ControlIndex = 7
			.Anchor.Right = AnchorStyle.asAnchor
			.Anchor.Left = AnchorStyle.asAnchor
			.SetBounds 220, 20, 464, 30
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TrackBar, Position As Integer), @tbPosition_Change)
			.OnMouseDown = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @tbPosition_MouseDown)
			.OnMouseUp = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @tbPosition_MouseUp)
			.Parent = @Panel2
		End With
		' OpenFileDialog1
		With OpenFileDialog1
			.Name = "OpenFileDialog1"
			.SetBounds 0, 0, 16, 16
			.Parent = @Panel1
		End With
		' TimerComponent1
		With TimerComponent1
			.Name = "TimerComponent1"
			.Interval = 200
			.SetBounds 20, 0, 16, 16
			.Designer = @This
			.OnTimer = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent), @TimerComponent1_Timer)
			.Parent = @Panel1
		End With
		' ImageList1
		With ImageList1
			.Name = "ImageList1"
			.SetBounds 40, 0, 16, 16
			.Designer = @This
			.Parent = @Panel1
		End With
		' PopupMenu1
		With PopupMenu1
			.Name = "PopupMenu1"
			.ParentWindow = @This
			.SetBounds 60, 0, 16, 16
			.Designer = @This
			.Parent = @Panel1
		End With
		' mnuFile
		With mnuFile
			.Name = "mnuFile"
			.Designer = @This
			.Caption = !"&File...\tCtrl+F"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuBar1
		With mnuBar1
			.Name = "mnuBar1"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuOpen
		With mnuOpen
			.Name = "mnuOpen"
			.Designer = @This
			.Caption = !"&Open\tCtrl+O"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuPlay
		With mnuPlay
			.Name = "mnuPlay"
			.Designer = @This
			.Caption = !"&Play\tCtrl+P"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Enabled = False
			.Parent = @PopupMenu1
		End With
		' mnuPause
		With mnuPause
			.Name = "mnuPause"
			.Designer = @This
			.Caption = !"Pa&use\tCtrl+U"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Enabled = False
			.Parent = @PopupMenu1
		End With
		' mnuClose
		With mnuClose
			.Name = "mnuClose"
			.Designer = @This
			.Caption = !"&Close\tCtrl+C"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Enabled = False
			.Parent = @PopupMenu1
		End With
		' mnuBar2
		With mnuBar2
			.Name = "mnuBar2"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuLoop
		With mnuLoop
			.Name = "mnuLoop"
			.Designer = @This
			.Caption = !"&Loop\tCtrl+L"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuDark
		With mnuDark
			.Name = "mnuDark"
			.Designer = @This
			.Caption = !"&Dark\tCtrl+D"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Checked = True
			.Parent = @PopupMenu1
		End With
		' mnuBar3
		With mnuBar3
			.Name = "mnuBar3"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuSlower
		With mnuSlower
			.Name = "mnuSlower"
			.Designer = @This
			.Caption = !"&Slower\tCtrl+S"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Enabled = False
			.Parent = @PopupMenu1
		End With
		' mnuNormal
		With mnuNormal
			.Name = "mnuNormal"
			.Designer = @This
			.Caption = !"&Normal\tCtrl+N"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Enabled = False
			.Parent = @PopupMenu1
		End With
		' mnuFaster
		With mnuFaster
			.Name = "mnuFaster"
			.Designer = @This
			.Caption = !"Fas&ter\tCtrl+T"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Enabled = False
			.Parent = @PopupMenu1
		End With
		' mnuBar4
		With mnuBar4
			.Name = "mnuBar4"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuMonitor
		With mnuMonitor
			.Name = "mnuMonitor"
			.Designer = @This
			.Caption = "Desktop"
			.Enabled = False
			.Parent = @PopupMenu1
		End With
		' mnuNotDesktop
		With mnuNotDesktop
			.Name = "mnuNotDesktop"
			.Designer = @This
			.Caption = !"Non&e\tCtrl+E"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Checked = True
			.Parent = @mnuMonitor
		End With
		' mnuScale
		With mnuScale
			.Name = "mnuScale"
			.Designer = @This
			.Caption = "Scale"
			.Enabled = False
			.Parent = @PopupMenu1
		End With
		' mnu14scale
		With mnu14scale
			.Name = "mnu14scale"
			.Designer = @This
			.Caption = !"1/&4\tCtrl+4"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Parent = @mnuScale
		End With
		' mnu13scale
		With mnu13scale
			.Name = "mnu13scale"
			.Designer = @This
			.Caption = !"1/&3\tCtrl+3"
			.Checked = False
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Parent = @mnuScale
		End With
		' mnu12scale
		With mnu12scale
			.Name = "mnu12scale"
			.Designer = @This
			.Caption = !"1/&2\tCtrl+2"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Parent = @mnuScale
		End With
		' mnu11scale
		With mnu11scale
			.Name = "mnu11scale"
			.Designer = @This
			.Caption = !"1/&1\tCtrl+1"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Parent = @mnuScale
		End With
		' mnuFull
		With mnuFull
			.Name = "mnuFull"
			.Designer = @This
			.Caption = !"Full sc&reen\tCtrl+R"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Parent = @mnuScale
		End With
		' mnuBar5
		With mnuBar5
			.Name = "mnuBar5"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuCapture
		With mnuCapture
			.Name = "mnuCapture"
			.Designer = @This
			.Caption = !"C&apture\tCtrl+A"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Enabled = False
			.Parent = @PopupMenu1
		End With
		' mnuBar6
		With mnuBar6
			.Name = "mnuBar6"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuExit
		With mnuExit
			.Name = "mnuExit"
			.Designer = @This
			.Caption = !"E&xit\tCtrl+X"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
			.Parent = @PopupMenu1
		End With
		' MainMenu1
		With MainMenu1
			.Name = "MainMenu1"
			.SetBounds 80, 0, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' MenuItem1
		With MenuItem1
			.Name = "MenuItem1"
			.Designer = @This
			.Caption = "File"
			.Visible = False
			.Parent = @MainMenu1
		End With
		' mnuMainFile
		With mnuMainFile
			.Name = "mnuMainFile"
			.Designer = @This
			.Caption = !"File...\tCtrl+F"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMain_Click)
			.Parent = @MenuItem1
		End With
		' MenuItem3
		With MenuItem3
			.Name = "MenuItem3"
			.Designer = @This
			.Caption = "-"
			.Parent = @MenuItem1
		End With
		' mnuMainOpen
		With mnuMainOpen
			.Name = "mnuMainOpen"
			.Designer = @This
			.Caption = !"Open\tCtrl+O"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMain_Click)
			.Parent = @MenuItem1
		End With
		' mnuMainPlay
		With mnuMainPlay
			.Name = "mnuMainPlay"
			.Designer = @This
			.Caption = !"Play\tCtrl+P"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMain_Click)
			.Parent = @MenuItem1
		End With
		' mnuMainPause
		With mnuMainPause
			.Name = "mnuMainPause"
			.Designer = @This
			.Caption = !"Pause\tCtrl+U"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMain_Click)
			.Parent = @MenuItem1
		End With
		' mnuMainClose
		With mnuMainClose
			.Name = "mnuMainClose"
			.Designer = @This
			.Caption = !"Close\tCtrl+C"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMain_Click)
			.Parent = @MenuItem1
		End With
		' MenuItem8
		With MenuItem8
			.Name = "MenuItem8"
			.Designer = @This
			.Caption = "-"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMain_Click)
			.Parent = @MenuItem1
		End With
		' mnuMainLoop
		With mnuMainLoop
			.Name = "mnuMainLoop"
			.Designer = @This
			.Caption = !"Loop\tCtrl+L"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMain_Click)
			.Parent = @MenuItem1
		End With
		' mnuMainDark
		With mnuMainDark
			.Name = "mnuMainDark"
			.Designer = @This
			.Caption = !"Dark\tCtrl+D"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMain_Click)
			.Parent = @MenuItem1
		End With
		' MenuItem11
		With MenuItem11
			.Name = "MenuItem11"
			.Designer = @This
			.Caption = "-"
			.Parent = @MenuItem1
		End With
		' mnuMainSlower
		With mnuMainSlower
			.Name = "mnuMainSlower"
			.Designer = @This
			.Caption = !"Slower\tCtrl+S"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMain_Click)
			.Parent = @MenuItem1
		End With
		' mnuMainNormal
		With mnuMainNormal
			.Name = "mnuMainNormal"
			.Designer = @This
			.Caption = !"Normal\tCtrl+N"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMain_Click)
			.Parent = @MenuItem1
		End With
		' mnuMainFaster
		With mnuMainFaster
			.Name = "mnuMainFaster"
			.Designer = @This
			.Caption = !"Faster\tCtrl+T"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMain_Click)
			.Parent = @MenuItem1
		End With
		' MenuItem2
		With MenuItem2
			.Name = "MenuItem2"
			.Designer = @This
			.Caption = "-"
			.Parent = @MenuItem1
		End With
		' mnuMain14scale
		With mnuMain14scale
			.Name = "mnuMain14scale"
			.Designer = @This
			.Caption = !"1/4\tCtrl+4"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMain_Click)
			.Parent = @MenuItem1
		End With
		' mnuMain13scale
		With mnuMain13scale
			.Name = "mnuMain13scale"
			.Designer = @This
			.Caption = !"1/3\tCtrl+3"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMain_Click)
			.Parent = @MenuItem1
		End With
		' mnuMain12scale
		With mnuMain12scale
			.Name = "mnuMain12scale"
			.Designer = @This
			.Caption = !"1/2\tCtrl+2"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMain_Click)
			.Parent = @MenuItem1
		End With
		' mnuMain11scale
		With mnuMain11scale
			.Name = "mnuMain11scale"
			.Designer = @This
			.Caption = !"1/1\tCtrl+1"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMain_Click)
			.Parent = @MenuItem1
		End With
		' mnuMainFull
		With mnuMainFull
			.Name = "mnuMainFull"
			.Designer = @This
			.Caption = !"Full screen\tCtrl+R"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMain_Click)
			.Checked = false
			.Parent = @MenuItem1
		End With
		' MenuItem15
		With MenuItem15
			.Name = "MenuItem15"
			.Designer = @This
			.Caption = "-"
			.Parent = @MenuItem1
		End With
		' mnuMainNone
		With mnuMainNone
			.Name = "mnuMainNone"
			.Designer = @This
			.Caption = !"None\tCtrl+E"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMain_Click)
			.Parent = @MenuItem1
		End With
		' mnuMainCapture
		With mnuMainCapture
			.Name = "mnuMainCapture"
			.Designer = @This
			.Caption = !"Capture\tCtrl+A"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMain_Click)
			.Parent = @MenuItem1
		End With
		' MenuItem18
		With MenuItem18
			.Name = "MenuItem18"
			.Designer = @This
			.Caption = "-"
			.Parent = @MenuItem1
		End With
		' mnuMainExit
		With mnuMainExit
			.Name = "mnuMainExit"
			.Designer = @This
			.Caption = !"Exit\tCtrl+X"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMain_Click)
			.Parent = @MenuItem1
		End With
	End Constructor
	
	Dim Shared frmMedia As frmMediaType
	
	#if __MAIN_FILE__ = __FILE__
		App.DarkMode = True
		frmMedia.MainForm = True
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

Function CaptureBmp(filename As ZString Ptr, pMC As IMediaControl Ptr, pBV2 As IBasicVideo2 Ptr) As HRESULT
	'IBasicVideo::GetCurrentImage
	'Retrieves the current image waiting at the renderer.
	'This method fails If the renderer Is Using DirectDraw acceleration. Unfortunately,
	'This depends On the End-user's hardware configuration, so in practice this method is not reliable.
	'A better way to obtain a sample from a stream in the graph is to use the ISampleGrabber interface.
	'ISampleGrabber qedit.h not being imported on freebasic
	
	Dim As HRESULT hr
	
	'1, 检查pBV2是否存在
	If pBV2 = NULL Then Return True
	
	'2, 检查视频是否在暂停状态
	'Retrieves the state of the filter graph—paused, running, or stopped.
	
	Dim As FILTER_STATE pfs
	Do
		hr = pMC->lpVtbl->GetState(pMC, NULL, @pfs)
		'Print "FILTER_STATE=" & pfs & ", " &  hr
		Select Case hr
		Case VFW_S_STATE_INTERMEDIATE
			'Print "VFW_S_STATE_INTERMEDIATE"
		Case VFW_S_CANT_CUE
			'Print "VFW_S_CANT_CUE"
		Case E_FAIL
			'Print "E_FAIL"
			Return hr
		Case Else
		End Select
		App.DoEvents
	Loop While pfs <> State_Paused
	
	'3, 获取视频宽高
	Dim As Long lHeight
	Dim As Long lWidth
	hr = pBV2->lpVtbl->GetVideoSize(pBV2, @lWidth, @lHeight)
	If hr Then Return hr
	
	'4, 创建位图文件头
	Dim As BITMAPFILEHEADER mbitmapFileHeader
	mbitmapFileHeader.bfType = &h4D42
	mbitmapFileHeader.bfReserved1 = 0
	mbitmapFileHeader.bfReserved2 = 0
	mbitmapFileHeader.bfOffBits = SizeOf(BITMAPFILEHEADER) + SizeOf(BITMAPINFOHEADER)
	
	'5, 创建位图信息头
	Dim As BITMAPINFOHEADER mbitmapInfoHeader
	mbitmapInfoHeader.biSize = SizeOf(BITMAPINFOHEADER)
	mbitmapInfoHeader.biWidth = lWidth      ' 设置图像宽度
	mbitmapInfoHeader.biHeight = lHeight    ' 设置图像高度（可根据摄像头支持的分辨率进行调整）
	mbitmapInfoHeader.biPlanes = 1
	mbitmapInfoHeader.biBitCount = 32       ' 设置位图位数（24表示每个像素占用3字节,32表示每个像素占用4字节）
	mbitmapInfoHeader.biCompression = BI_RGB
	mbitmapInfoHeader.biSizeImage = 0
	mbitmapInfoHeader.biXPelsPerMeter = 0
	mbitmapInfoHeader.biYPelsPerMeter = 0
	mbitmapInfoHeader.biClrUsed = 0
	mbitmapInfoHeader.biClrImportant = 0
	
	Dim pBufferSize As Long ' = SizeOf(BITMAPFILEHEADER) + lHeight * lWidth * (mbitmapInfoHeader.biBitCount / 8)
	Dim pDIBImage As Long Ptr = NULL
	
	'6, 获取缓存大小和申请缓存
	hr = pBV2->lpVtbl->GetCurrentImage(pBV2, @pBufferSize, NULL)
	If hr Then Return hr
	pDIBImage = Cast(Long Ptr, Allocate(pBufferSize))
	
	'7, 更新位图文件头
	mbitmapFileHeader.bfSize = pBufferSize + SizeOf(BITMAPFILEHEADER)
	
	'8, Retrieves the current image waiting at the renderer.
	hr = pBV2->lpVtbl->GetCurrentImage(pBV2, @pBufferSize, pDIBImage)
	If hr = VFW_E_NOT_PAUSED Then
		'Print "VFW_E_NOT_PAUSED"
	End If
	If hr = E_UNEXPECTED Then
		'Print "E_UNEXPECTED"
	End If
	If hr Then Return hr
	
	'9, 检查文件存在和删除
	Dim As FILE Ptr fileHandle
	fileHandle = fopen(filename, @Str("rb"))
	If fileHandle Then
		fclose(fileHandle)
		remove(filename)
	End If
	
	'10, 写入文件
	fileHandle = fopen(filename, @Str("wb"))
	'Print "fopen(filename, @Str(wb)): " & fileHandle
	If fileHandle Then
		Dim As DWORD bytesWritten = fwrite(@mbitmapFileHeader, 1, SizeOf(BITMAPFILEHEADER), fileHandle)
		bytesWritten = fwrite(@mbitmapInfoHeader, 1, SizeOf(BITMAPINFOHEADER), fileHandle)
		bytesWritten = fwrite(pDIBImage, 1, pBufferSize - SizeOf(BITMAPINFOHEADER), fileHandle)
		fclose(fileHandle)
	End If
	
	'11, 释放缓存
	Deallocate(pDIBImage)
	
	Return 0
End Function

Private Property frmMediaType.WithAudio(val As Long)
	mWithAudio = IIf(val > 0, False, True)
	If mWithAudio Then
		pIBasicAudio->lpVtbl->put_Volume(pIBasicAudio, val)
		pIBasicAudio->lpVtbl->put_Balance(pIBasicAudio, tbBalance.Position)
	End If
	lblVolume.Enabled = mWithAudio
	lblBalance.Enabled = mWithAudio
	tbVolume.Enabled = mWithAudio
	tbBalance.Enabled = mWithAudio
End Property

Private Property frmMediaType.WithVedio(Opt As Boolean, Val As Boolean)
	Dim hr As HRESULT
	
	mWithVedio = Val
	If mWithVedio Then
		Dim vWidth As Long
		Dim vHeight As Long
		pIBasicVideo->lpVtbl->get_VideoWidth(pIBasicVideo, @vWidth)
		pIBasicVideo->lpVtbl->get_VideoHeight(pIBasicVideo, @vHeight)
		hwScale= vHeight / vWidth
		This.Height = Picture1.Width*hwScale+ aHeight
		Form_Resize(Me, 0, 0)
		hr = pIVideoWindow->lpVtbl->put_Visible(pIVideoWindow, OATRUE)
	Else
		If Opt Then This.Height = aHeight
	End If
	mnuMonitor.Enabled = mWithVedio
	mnuScale.Enabled = mWithVedio
End Property

Private Property frmMediaType.WithPosition(val As Double)
	mWithPosition = CBool(val <> 0)
	If val Then
		tbPosition.MaxValue = CInt(val)
		tbPosition.PageSize = CInt(val / 10)
		tbPosition.Frequency = CInt(val / 10)
		lblLength.Text = "Length: " & Format(val, "#,#0.000")
	Else
		lblLength.Text = "Length: NA"
		lblPosition.Text = "Position: NA"
	End If
	tbPosition.Position = 0
	
	'lblPosition.Enabled = mWithPosition
	lblLength.Enabled = mWithPosition
	tbPosition.Enabled = mWithPosition
	mnuNormal.Enabled = mWithPosition
	mnuFaster.Enabled = mWithPosition
	mnuSlower.Enabled = mWithPosition
End Property

Private Sub frmMediaType.DSCtrl(Index As DSStatus)
	Dim b As Boolean = False
	Dim hr As HRESULT
	
	mnuCapture.Enabled = False
	
	Select Case Index
	Case DSStatus.DS_Open
		DSCtrl(DSStatus.DS_Close)
		If DSCreate(Picture1.Handle, Handle, TextBox1.Text) Then
			DSCtrl(DSStatus.DS_Play)
			mnuPlay.Enabled = True
			mnuPause.Enabled = True
			mnuClose.Enabled = True
			cmdPlay.Enabled = True
			cmdClose.Enabled = True
		End If
	Case DSStatus.DS_Close
		WithPosition = 0
		WithAudio = 1
		WithVedio(False) = False
		mnuPlay.Enabled = False
		mnuPause.Enabled = False
		mnuClose.Enabled = False
		cmdPlay.Enabled = False
		cmdClose.Enabled = False
		
		TimerComponent1.Enabled = False
		cmdPlay.Text = "Play"
		DSUnload
		mnu_Click(mnuNotDesktop)
	Case DSStatus.DS_Play
		TimerComponent1.Enabled = True
		mnuCapture.Enabled = False
		cmdPlay.Text = "Pause"
		If pIMediaControl Then hr = pIMediaControl->lpVtbl->Run(pIMediaControl)
	Case DSStatus.DS_Pause
		TimerComponent1.Enabled = False
		mnuCapture.Enabled = mWithVedio
		cmdPlay.Text = "Play"
		If pIMediaControl Then hr = pIMediaControl->lpVtbl->Pause(pIMediaControl)
	Case DSStatus.DS_Stop
		If pIMediaControl Then hr = pIMediaControl->lpVtbl->Stop(pIMediaControl)
	End Select
End Sub

Private Function frmMediaType.DSCreate(hWndDiaplay As HWND, hWndMessage As HWND, wszFileName As WString) As Boolean
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
	hr = pIVideoWindow->lpVtbl->put_Owner(pIVideoWindow, Cast(OAHWND, hWndDiaplay))
	hr = pIVideoWindow->lpVtbl->put_WindowStyle(pIVideoWindow, WS_CHILD Or WS_CLIPSIBLINGS Or WS_CLIPCHILDREN)
	'Have the graph signal event via window callbacks for performance
	hr = pIMediaEventEx->lpVtbl->SetNotifyWindow(pIMediaEventEx, Cast(OAHWND, hWndMessage), WM_GRAPHNOTIFY, 0)
	
	Dim d As Double = 0
	Dim l As Long = 1
	
	If pIBasicAudio Then
		l = 1
		pIBasicAudio->lpVtbl->get_Volume(pIBasicAudio, @l)
		If l = 1 Then
			WithAudio = 1
		Else
			WithAudio = tbVolume.Position
		End If
	Else
		WithAudio = 1
	End If
	
	Dim As Long lVisible
	If pIVideoWindow Then
		hr = pIVideoWindow->lpVtbl->get_Visible(pIVideoWindow, @lVisible)
		If (FAILED(hr)) Then
			WithVedio(True) = False
		Else
			WithVedio(True) = True
		End If
	Else
		WithVedio(True) = False
	End If
	
	If pIMediaPosition Then
		pIMediaPosition->lpVtbl->get_Duration(pIMediaPosition, @d)
		WithPosition = d
	Else
		WithPosition = 0
	End If
	
	Return True
End Function

Private Sub frmMediaType.DSUnload()
	If pIMediaControl Then
		pIMediaControl->lpVtbl->Stop(pIMediaControl)
		pIMediaControl->lpVtbl->Release(pIMediaControl)
	End If
	If pIBasicAudio Then pIBasicAudio->lpVtbl->Release(pIBasicAudio)
	If pIBasicVideo Then pIBasicVideo->lpVtbl->Release(pIBasicVideo)
	If pIBasicVideo2 Then pIBasicVideo2->lpVtbl->Release(pIBasicVideo2)
	If pIMediaEvent Then pIMediaEvent->lpVtbl->Release(pIMediaEvent)
	If pIMediaEventEx Then pIMediaEventEx->lpVtbl->Release(pIMediaEventEx)
	If pIVideoWindow Then
		pIVideoWindow->lpVtbl->put_Visible(pIVideoWindow, OAFALSE)
		pIVideoWindow->lpVtbl->Release(pIVideoWindow)
	End If
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

Private Sub frmMediaType.Form_Create(ByRef Sender As Control)
	Dim hr As HRESULT = CoInitialize(0)
	aHeight = This.Height - Picture1.Height
	aWidth = This.Width - Picture1.Width
	
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
	
	MenuAddMonitor()
End Sub

Private Sub frmMediaType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	DSCtrl(DSStatus.DS_Close)
	Deallocate(mfilename)
	CoUninitialize()
End Sub

Private Sub frmMediaType.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	If mnuNotDesktop.Checked = False Then Exit Sub
	Dim rc As Rect
	GetClientRect(Picture1.Handle, @rc)
	If pIVideoWindow Then
		pIVideoWindow->lpVtbl->SetWindowPosition(pIVideoWindow, rc.Left, rc.Top, rc.Right, rc.Bottom)
		RedrawWindow Picture1.Handle, @rc, 0, RDW_INVALIDATE Or RDW_UPDATENOW
	End If
	If This.Height < aHeight Then This.Height = aHeight
End Sub

Private Sub frmMediaType.cmdBtn_Click(ByRef Sender As Control)
	Select Case Sender.Name
	Case "cmdOpen"
		DSCtrl(DSStatus.DS_Open)
	Case "cmdPlay"
		Select Case Sender.Text
		Case "Play"
			DSCtrl(DSStatus.DS_Play)
		Case "Pause"
			DSCtrl(DSStatus.DS_Pause)
		End Select
	Case "cmdClose"
		DSCtrl(DSStatus.DS_Close)
	Case "cmdBrowse"
		If Dir(TextBox1.Text)="" Then
		Else
			OpenFileDialog1.FileName = TextBox1.Text
		End If
		If OpenFileDialog1.Execute() Then
			TextBox1.Text = OpenFileDialog1.FileName
		End If
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
	Select Case Sender.Name
	Case "TimerComponent1"
		Dim d As Double= 0
		If pIMediaPosition Then
			pIMediaPosition->lpVtbl->get_CurrentPosition(pIMediaPosition , @d)
			If tbPosition.Enabled Then
				tbPosition.Position = CInt(d)
			End If
			lblPosition.Text = "Position: " & Format(d, "#,#0.000")
		End If
	End Select
End Sub

Private Sub frmMediaType.ComboBoxEx1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	TextBox1.Text = urlsa(1, ItemIndex)
	This.Caption = Mid(This.Caption, 1, Len(" VFBE Media Player64"))
End Sub

Private Sub frmMediaType.Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
	TextBox1.Text = Filename
	cmdBtn_Click(cmdOpen)
End Sub

Private Sub frmMediaType.Form_Message(ByRef Sender As Control, ByRef Msg As Message)
	Select Case Msg.Msg
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
			'Debug.Print "Enter event loop"
			Do
				Dim hr As HRESULT
				hr = pIMediaEventEx->lpVtbl->GetEvent(pIMediaEventEx, @lEventCode, @lParam1, @lParam2, 0)
				If hr <> S_OK Then Exit Do
				pIMediaEventEx->lpVtbl->FreeEventParams(pIMediaEventEx, lEventCode, lParam1, lParam2)
				'Debug.Print MsgStr(lEventCode)
				If lEventCode = EC_COMPLETE Then
					If mnuLoop.Checked Then
						pIMediaPosition->lpVtbl->put_CurrentPosition(pIMediaPosition , 0)
						pIMediaControl->lpVtbl->Run(pIMediaControl)
					End If
				End If
			Loop
			'Debug.Print "Exit event loop"
		End If
	End Select
End Sub

Private Sub frmMediaType.mnu_Click(ByRef Sender As MenuItem)
	Dim dRate As Double
	Dim vWidth As Long
	Dim vHeight As Long
	Dim i As Integer
	
	Select Case Sender.Name
	Case "mnuFile"
		cmdBtn_Click(cmdBrowse)
	Case "mnuOpen"
		DSCtrl(DSStatus.DS_Open)
	Case "mnuPlay"
		If Sender.Enabled = False Then Exit Sub
		DSCtrl(DSStatus.DS_Play)
	Case "mnuPause"
		If Sender.Enabled = False Then Exit Sub
		DSCtrl(DSStatus.DS_Pause)
	Case "mnuClose"
		If Sender.Enabled = False Then Exit Sub
		DSCtrl(DSStatus.DS_Close)
	Case "mnuLoop"
		Sender.Checked = Not Sender.Checked
	Case "mnuDark"
		Sender.Checked = Not Sender.Checked
		App.DarkMode= Sender.Checked
		InvalidateRect(0, 0, True)
	Case "mnuFaster"
		If Sender.Enabled = False Then Exit Sub
		If pIMediaPosition = False Then Exit Sub
		pIMediaPosition->lpVtbl->get_Rate(pIMediaPosition, @dRate)
		dRate = dRate + 0.5
		pIMediaPosition->lpVtbl->put_Rate(pIMediaPosition, dRate)
	Case "mnuNormal"
		If Sender.Enabled = False Then Exit Sub
		If pIMediaPosition = False Then Exit Sub
		pIMediaPosition->lpVtbl->get_Rate(pIMediaPosition, @dRate)
		dRate = 1
		pIMediaPosition->lpVtbl->put_Rate(pIMediaPosition, dRate)
	Case "mnuSlower"
		If Sender.Enabled = False Then Exit Sub
		If pIMediaPosition = False Then Exit Sub
		pIMediaPosition->lpVtbl->get_Rate(pIMediaPosition, @dRate)
		dRate = dRate - 0.1
		pIMediaPosition->lpVtbl->put_Rate(pIMediaPosition, dRate)
	Case "mnu14scale"
		If mnuScale.Enabled = False Then Exit Sub
		If pIBasicVideo = NULL Then Exit Sub
		pIBasicVideo->lpVtbl->get_VideoWidth(pIBasicVideo, @vWidth)
		pIBasicVideo->lpVtbl->get_VideoHeight(pIBasicVideo, @vHeight)
		This.Width = vWidth / 4 + aWidth
		This.Height = vHeight / 4 + aHeight
	Case "mnu13scale"
		If mnuScale.Enabled = False Then Exit Sub
		If pIBasicVideo = NULL Then Exit Sub
		pIBasicVideo->lpVtbl->get_VideoWidth(pIBasicVideo, @vWidth)
		pIBasicVideo->lpVtbl->get_VideoHeight(pIBasicVideo, @vHeight)
		This.Width = vWidth / 3 + aWidth
		This.Height = vHeight / 3 + aHeight
	Case "mnu12scale"
		If mnuScale.Enabled = False Then Exit Sub
		If pIBasicVideo = NULL Then Exit Sub
		pIBasicVideo->lpVtbl->get_VideoWidth(pIBasicVideo, @vWidth)
		pIBasicVideo->lpVtbl->get_VideoHeight(pIBasicVideo, @vHeight)
		This.Width = vWidth / 2 + aWidth
		This.Height = vHeight / 2 + aHeight
	Case "mnu11scale"
		If mnuScale.Enabled = False Then Exit Sub
		If pIBasicVideo = NULL Then Exit Sub
		pIBasicVideo->lpVtbl->get_VideoWidth(pIBasicVideo, @vWidth)
		pIBasicVideo->lpVtbl->get_VideoHeight(pIBasicVideo, @vHeight)
		This.Width = vWidth + aWidth
		This.Height = vHeight + aHeight
	Case "mnuFull"
		If mnuScale.Enabled = False Then Exit Sub
		If pIVideoWindow = NULL Then Exit Sub
		Dim lMode As Long
		pIVideoWindow->lpVtbl->get_FullScreenMode(pIVideoWindow, @lMode)
		If lMode = OAFALSE Then
			lMode = OATRUE
		Else
			lMode = OAFALSE
		End If
		pIVideoWindow->lpVtbl->put_FullScreenMode(pIVideoWindow, lMode)
	Case "mnuCapture"
		If Sender.Enabled = False Then Exit Sub
		*mfilename = "MediaPlayer_" & Format(Now(), "yyyymmdd_hhmmss") & ".bmp"
		CaptureBmp(mfilename, pIMediaControl, pIBasicVideo2)
	Case "mnuExit"
		CloseForm()
	Case "mnuNotDesktop"
		If mnuMonitor.Enabled = False Then Exit Sub
		For i = 1 To mMenuMtrCount
			mMenuMtr(i)->Checked = False
		Next
		mnuNotDesktop.Checked = True
		mnuScale.Enabled = True
		
		'恢复窗口显示
		DesktopLoad(False)
		
		'恢复视频窗口大小
		Picture1.Align = DockStyle.alClient
		Form_Resize(This, Width, Height)
	Case "mMenuMtr"
		For i = 1 To mMenuMtrCount
			mMenuMtr(i)->Checked = False
		Next
		mnuNotDesktop.Checked = False
		mnuScale.Enabled = False
		Sender.Checked = True
		
		'取消视频窗口大小自动调整
		Picture1.Align = DockStyle.alNone
		Picture1.Visible= False
		
		'加载视频窗口到桌面
		DesktopLoad(True)
		
		'确认窗口位置
		Dim dmDevMode As DEVMODE
		memset (@dmDevMode, 0, SizeOf(dmDevMode))
		dmDevMode.dmSize = SizeOf(dmDevMode)
		If EnumDisplaySettingsEx(Sender.Caption, ENUM_CURRENT_SETTINGS, @dmDevMode, EDS_RAWMODE) Then
			Picture1.Move(dmDevMode.dmPosition.x, dmDevMode.dmPosition.y, dmDevMode.dmPelsWidth, dmDevMode.dmPelsHeight)
		End If
		
		'调整窗视频口大小
		Dim rc As Rect
		GetClientRect(Picture1.Handle, @rc)
		If pIVideoWindow Then
			pIVideoWindow->lpVtbl->SetWindowPosition(pIVideoWindow, rc.Left, rc.Top, rc.Right, rc.Bottom)
			RedrawWindow Picture1.Handle, @rc, 0, RDW_INVALIDATE Or RDW_UPDATENOW
		End If
		
		'恢复原桌面
		InvalidateRect(hwndDesktop, 0, 0)
		Dim hDC As HDC
		hDC = GetWindowDC(hwndDesktop)
		PaintDesktop(hDC)
		ReleaseDC(hwndDesktop, hDC)
		
		Picture1.Visible= True
	End Select
End Sub

Private Sub frmMediaType.MenuAddMonitor()
	Dim iDevNum As DWORD = 0
	Dim ddDisplay As DISPLAY_DEVICE
	Dim dmDevMode As DEVMODE
	
	Dim i As Integer
	For i = 0 To mMenuMtrCount
		mnuMonitor.Remove(mMenuMtr(i))
		Delete(mMenuMtr(i))
	Next
	Erase mMenuMtr
	mMenuMtrCount = -1
	
	Do
		memset (@ddDisplay, 0, SizeOf(ddDisplay))
		ddDisplay.cb = SizeOf(ddDisplay)
		memset (@dmDevMode, 0, SizeOf(dmDevMode))
		dmDevMode.dmSize = SizeOf(dmDevMode)
		
		If EnumDisplayDevices(NULL, iDevNum, @ddDisplay, EDD_GET_DEVICE_INTERFACE_NAME) Then
			If EnumDisplaySettingsEx(ddDisplay.DeviceName, ENUM_CURRENT_SETTINGS, @dmDevMode, EDS_RAWMODE) Then
				mMenuMtrCount += 1
				ReDim Preserve mMenuMtr(mMenuMtrCount)
				mMenuMtr(mMenuMtrCount) = New MenuItem
				
				If mMenuMtrCount = 0 Then
					mMenuMtr(mMenuMtrCount)->Name = "mMenuMtr"
					mMenuMtr(mMenuMtrCount)->Caption = "-"
					mMenuMtr(mMenuMtrCount)->Designer = @This
					mMenuMtr(mMenuMtrCount)->Parent = @mnuMonitor
					mnuMonitor.Add mMenuMtr(mMenuMtrCount)
					
					mMenuMtrCount += 1
					ReDim Preserve mMenuMtr(mMenuMtrCount)
					mMenuMtr(mMenuMtrCount) = New MenuItem
				End If
				
				mMenuMtr(mMenuMtrCount)->Name = "mMenuMtr"
				mMenuMtr(mMenuMtrCount)->Caption = ddDisplay.DeviceName
				mMenuMtr(mMenuMtrCount)->Designer = @This
				mMenuMtr(mMenuMtrCount)->Parent = @mnuMonitor
				mMenuMtr(mMenuMtrCount)->OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnu_Click)
				mnuMonitor.Add mMenuMtr(mMenuMtrCount)
			End If
			
			iDevNum += 1
		Else
			Exit Do
		End If
	Loop While True
End Sub

Private Sub frmMediaType.DesktopLoad(v As Boolean)
	'https://leandroascierto.com/blog/poner-un-video-como-fondo-de-escritorio/
	
	Dim hr As HRESULT
	If v Then
		If hwndDesktop Then Exit Sub
		
		hwndProgManager = FindWindow(@"Progman", @"Program Manager")
		SendMessage(hwndProgManager, &H52C, &HD, 0)
		SendMessage(hwndProgManager, &H52C, &HD, 1)
		App.DoEvents()
		SendMessage(hwndProgManager, WM_ACTIVATE, WA_CLICKACTIVE, Cast(LPARAM, hwndProgManager))
		SendMessage(hwndProgManager, WM_SETFOCUS, Cast(LPARAM, hwndProgManager), 0)
		App.DoEvents()
		
		If hwndProgManager Then
			hwndTemp = FindWindow(NULL, NULL)
			Do While hwndTemp
				hwndParent = GetParent(hwndTemp)
				If hwndParent = hwndProgManager Then
					hwndDesktop = hwndTemp
					Exit Do
				Else
					hwndTemp = GetWindow(hwndTemp, 2)
				End If
			Loop
		End If
		
		If hwndDesktop Then
			SetParent(Picture1.Handle, hwndDesktop)
		End If
	Else
		If hwndDesktop = NULL Then Exit Sub
		SetParent(Picture1.Handle, Handle)
		
		'恢复原桌面
		InvalidateRect(hwndDesktop, 0, 0)
		Dim hDC As HDC
		hDC = GetWindowDC(hwndDesktop)
		PaintDesktop(hDC)
		ReleaseDC(hwndDesktop, hDC)
		
		hwndDesktop = NULL
	End If
End Sub

Private Sub frmMediaType.mnuMain_Click(ByRef Sender As MenuItem)
	Select Case Sender.Name
	Case "mnuMainFile"
		mnu_Click mnuFile
	Case "mnuMainOpen"
		mnu_Click mnuOpen
	Case "mnuMainPlay"
		mnu_Click mnuPlay
	Case "mnuMainPause"
		mnu_Click mnuPause
	Case "mnuMainClose"
		mnu_Click mnuClose
	Case "mnuMainLoop"
		mnu_Click mnuLoop
	Case "mnuMainDark"
		mnu_Click mnuDark
	Case "mnuMainSlower"
		mnu_Click mnuSlower
	Case "mnuMainNormal"
		mnu_Click mnuNormal
	Case "mnuMainFaster"
		mnu_Click mnuFaster
	Case "mnuMain14scale"
		mnu_Click mnu14scale
	Case "mnuMain13scale"
		mnu_Click mnu13scale
	Case "mnuMain12scale"
		mnu_Click mnu12scale
	Case "mnuMain11scale"
		mnu_Click mnu11scale
	Case "mnuMainFull"
		mnu_Click mnuFull
	Case "mnuMainNone"
		mnu_Click mnuNotDesktop
	Case "mnuMainCapture"
		mnu_Click mnuCapture
	Case "mnuMainExit"
		mnu_Click mnuExit
	End Select
End Sub
