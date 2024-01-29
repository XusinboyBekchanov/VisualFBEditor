'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "gdipClock.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/TimerComponent.bi"
	#include once "mff/Menus.bi"
	#include once "mff/Dialogs.bi"
	
	#include once "gdip.bi"
	#include once "gdipAnalogClock.bi"
	#include once "gdipTextClock.bi"
	#include once "gdipMonth.bi"
	#include once "gdipDay.bi"
	
	#include once "../SapiTTS/Speech.bi"
	#include once "../MDINotepad/Text.bi"
	
	Const MSG_SAPI_EVENT = WM_USER + 1024   ' --> change me
	
	Using My.Sys.Forms
	Using Gdiplus
	Using Speech
	
	Type frmClockType Extends Form
		'initial gdip token
		Token As gdipToken
		'form trans
		frmTrans As gdipForm
		'form display device
		frmDC As gdipDC
		'memory display device
		memDC As gdipDC
		'form canvas
		frmGraphic As gdipGraphics
		'draw analog coloc
		mAnalogClock As AnalogClock
		'draw text coloc
		mTextClock As TextClock
		
		mOpacity As UINT = &HFF
		mTextColor1 As ARGB = &HFF00FF
		mTextColor2 As ARGB = &H00FFFF
		mTextAlpha1 As ARGB = &HFF
		mTextAlpha2 As ARGB = &HFF
		
		mScreenWidth As Integer
		mScreenHeight As Integer
		
		mLocateVertical As Integer
		mLocateHorizontal As Integer
		
		Declare Sub PaintClock()
		
		TestSetting(Any) As Boolean
		TestMenu(Any) As MenuItem Ptr
		TestCount As Integer = 12
		Declare Sub TestBackup()
		Declare Sub TestRestore()
		Declare Sub TestStress()
		
		pSpVoice As Afx_ISpVoice Ptr
		mVoiceCount As Integer = -1
		mAudioCount As Integer = -1
		mLanguage As Integer = 0
		mnuVoiceSub(Any) As MenuItem Ptr
		mnuAudioSub(Any) As MenuItem Ptr
		Declare Sub SpeechNow(sDt As Double, ByVal sLan As Integer = 0)
		Declare Sub SpeechInit()
		
		mProfile As WString Ptr
		mKeyName(Any) As WString Ptr
		mKeyValue(Any) As WString Ptr
		mKeyNameLen(Any) As Integer
		mKeyCount As Integer = 134
		mnuProfileList(Any) As MenuItem Ptr
		mnuProfileCount As Integer = -1
		mAppPath As WString Ptr
		Declare Function ProfileIdx(ByVal fIncNum As Integer = -1) As Integer
		Declare Sub ProfileDefSave()                        '存入默认Profile
		Declare Function ProfileDefLoad() ByRef As WString  '获得默认Profile
		Declare Sub ProfileInitial()        '初始化Profile
		Declare Sub Profile2Menu()          '将Profile产生在Menu中
		Declare Sub ProfileFrmMain()        '从主界面中获得参数
		Declare Sub ProfileFrmAnalog()      '从模拟时钟中获得参数
		Declare Sub ProfileFrmText()        '从文字时钟中获得参数
		Declare Sub ProfileFrmDay()         '从日历中获得参数
		Declare Sub ProfileFrmMonth()       '从月历中获得参数
		Declare Sub ProfileFrmSpeech()      '从语音中获得参数
		Declare Sub Profile2Main()          '将参数应用于主界面
		Declare Sub Profile2Analog()        '将参数应用于模拟时钟
		Declare Sub Profile2Text()          '将参数应用于文字时钟
		Declare Sub Profile2Day()           '将参数应用于日历
		Declare Sub Profile2Month()         '将参数应用于月历
		Declare Sub Profile2Speech()        '将参数应用于语音
		Declare Sub Profile2Interface()     '将参数应显示在界面上
		Declare Sub ProfileRelease()        '释放Profile资源
		Declare Function ProfileLoad(sFileName As WString) As Boolean   '加载Profile
		Declare Sub ProfileSave(sFileName As WString)                   '存储Profile
		Declare Function ProfileSimple(sFileName As WString) ByRef As WString   '简路径
		Declare Function ProfileFull(sFileName As WString) ByRef As WString     '全路径
		
		mSetMainStart As Integer
		mSetAnalogStart As Integer
		mSetTextStart As Integer
		mSetDayStart As Integer
		mSetMonthStart As Integer
		mSetSpeechStart As Integer
		mRectMain As Rect
		mRectAnalog As Rect
		mRectText As Rect
		mRectDay As Rect
		mRectMonth As Rect
		
		Declare Property IndexOfLocateH() As Integer
		Declare Property IndexOfLocateV() As Integer
		Declare Property IndexOfGradientMode() As Integer
		Declare Property IndexOfTextColor() As Integer
		Declare Property IndexOfAnnouce() As Integer
		Declare Property IndexOfVoice() ByRef As WString
		Declare Property IndexOfAudio() ByRef As WString
		Declare Property IndexOfLocateH(v As Integer)
		Declare Property IndexOfLocateV(v As Integer)
		Declare Property IndexOfGradientMode(v As Integer)
		Declare Property IndexOfTextColor(v As Integer)
		Declare Property IndexOfAnnouce(v As Integer)
		Declare Property IndexOfVoice(ByRef v As WString)
		Declare Property IndexOfAudio(ByRef v As WString)
		
		mShowDay As Boolean
		mShowMonth As Boolean
		mTransparent As Boolean
		
		Declare Sub Transparent(v As Boolean)
		
		Declare Sub TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Sub mnuMenu_Click(ByRef Sender As MenuItem)
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub Form_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Message(ByRef Sender As Control, ByRef Msg As Message)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub TimerComponent2_Timer(ByRef Sender As TimerComponent)
		Declare Sub Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub Form_Move(ByRef Sender As Control)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Constructor
		Dim As TimerComponent TimerComponent1, TimerComponent2
		Dim As OpenFileDialog OpenFileDialog1
		Dim As SaveFileDialog SaveFileDialog1
		Dim As FontDialog FontDialog1
		Dim As ColorDialog ColorDialog1
		Dim As PopupMenu PopupMenu1
		Dim As MenuItem mnuAnalogEnabled, mnuAnalogSetting, mnuAnalogBackFile, mnuAnalogTrayEnabled, mnuAnalogScaleEnabled, mnuBar2, mnuTextEnabled, mnuTextSetting, mnuTextShadow, mnuTextBlack, mnuTextRed, mnuTextGreen, mnuTextGradient, mnuTextShowSecond, mnuTextBlinkColon, MenuItem10, mnuAnalogTextEnabled, mnuAnalogHandEnabled, mnuTextWhite, mnuTextBlue, MenuItem2, mnuTextBackEnabled, MenuItem3, mnuBar3, mnuExit, mnuBar6, mnuTransparent, mnuAnalogSquare, mnuTextBorderEnabled, MenuItem9, mnuAbout, mnuBar5, mnuTextTrayEnabled, mnuBar4, mnuSpeechNow, mnuAnnounce, mnuBar1, mnuAutoStart, mnuClickThrough, mnuAlwaysOnTop, mnuVoice, mnuAudio, MenuItem13, mnuAnnounce1, mnuAnnounce3, mnuAnnounce2, mnuAnnounce0, mnuHide, mnuAnalogBackEnabled, mnuTextBackFile, mnuAnalogTextFont, MenuItem11, mnuTextFont, MenuItem12, mnuTextBorderColor, mnuTextColor1, MenuItem16, mnuTextColor2, mnuTextDirection, mnuTextTrayColor, MenuItem20, mnuTextGradientMode1, mnuTextGradientMode2, mnuTextGradientMode3, mnuTextGradientMode4, mnuTextTrayAlpha, mnuTextBorderSize, mnuTextBorderAlpha, MenuItem1, mnuAnalogBackBlur, mnuAnalogBackAlpha, mnuAnalogTextAlpha, mnuAnalogTextBlur
		Dim As MenuItem MenuItem4, MenuItem5, mnuAnalogTrayBlur, mnuAnalogTrayAlpha, mnuAnalogScaleBlur, mnuAnalogScaleAlpha, mnuAnalogHandBlur, mnuAnalogHandAlpha, mnuAnalogTextFormat, mnuOpacityValue, mnuAnalogScaleColor, mnuAnalogHandMinute, mnuAnalogHandSecond, mnuAnalogHandHour, mnuProfileMain, MenuItem7, mnuProfileSave, mnuTextBackAlpha, mnuTextBackBlur, mnuTextAlpha1, mnuTextBlur, mnuTest, mnuMonthEnabled, mnuDayEnabled, mnuTextAlpha2, mnuLocate, MenuItem6, mnuLocateReset, mnuLocateRight, mnuLocateLeft, mnuLocateHorizontalMiddle, MenuItem8, MenuItem15, mnuLocateTop, mnuLocateVerticalMiddle, mnuLocateBottom, mnuLocateHorizontalAny, mnuLocateVerticalAny, mnuAspectRatio, MenuItem14, MenuItem17, mnuDaySetting, mnuMonthSetting, mnuDayTextFont, mnuDayTextAlpha, MenuItem21, mnuDaySplit, MenuItem23, mnuDayStyle0, mnuDayStyle1, mnuDayStyle2, MenuItem27, mnuDayBackEnabled, mnuDayBackFile, mnuDayBackAlpha, mnuDayBackBlur, MenuItem32, mnuDayTrayEnabled, mnuDayTrayAlpha, mnuMonthControls
		Dim As MenuItem mnuMonthWeeks, MenuItem22, mnuMonthTrayEnabled, mnuMonthTrayAlpha, MenuItem26, mnuMonthTextFont, mnuMonthTextAlpha, MenuItem30, mnuMonthBackEnabled, mnuMonthBackFile, mnuMonthBackAlpha, mnuMonthBackBlur, mnuAnalogHandSecondEnabled, mnuAnalogHandMinuteEnabled, mnuAnalogHandHourEnabled, mnuAnalogTrayFC1, mnuAnalogTrayFC2, mnuAnalogTrayFA1, mnuAnalogTrayFA2, mnuAnalogTrayEC1, mnuAnalogTrayEC2, mnuAnalogTrayEA2, mnuAnalogTrayEA1, mnuAnalogTraySC, mnuAnalogTraySA, mnuAnalogTextColor, mnuAnalogTextX, mnuAnalogTextY, mnuAnalogTraySetting, mnuAnalogHandSetting, mnuAnalogTextSetting, mnuAnalogTextSize, mnuDayFCWeek, mnuDayFCFocus, mnuDayFCYear, mnuDayFCMonth, mnuDayFCDay, mnuDayBCWeek, mnuDayBCFocus, mnuDayBCYear, mnuDayBCMonth, mnuDayBCDay, mnuMonthFCFocus, mnuMonthFCControl, mnuMonthFCWeek, mnuMonthFCDay, mnuMonthFCSelect, mnuMonthFCHoliday, mnuMonthBCFocus, mnuMonthBCControl, mnuMonthBCWeek, mnuMonthBCDay, mnuMonthFCToday, mnuLocateSticky
	End Type
	
	Constructor frmClockType
		' frmClock
		With This
			.Name = "frmClock"
			.Text = "GDIP Clock"
			.Designer = @This
			.Caption = "GDIP Clock"
			.ContextMenu = @PopupMenu1
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Form_Resize)
			.OnMouseMove = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Form_MouseMove)
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnMessage = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Msg As Message), @Form_Message)
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.Icon = "1"
			.OnPaint = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas), @Form_Paint)
			.OnMove = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Move)
			.OnShow = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form), @Form_Show)
			.ShowCaption = False
			.SetBounds 0, 0, 240, 200
		End With
		' TimerComponent1
		With TimerComponent1
			.Name = "TimerComponent1"
			.Interval = 50
			.Enabled = False
			.SetBounds 10, 10, 16, 16
			.Designer = @This
			.OnTimer = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent), @TimerComponent1_Timer)
			.Parent = @This
		End With
		' TimerComponent2
		With TimerComponent2
			.Name = "TimerComponent2"
			.Interval = 500
			.SetBounds 30, 10, 16, 16
			.Designer = @This
			.OnTimer = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent), @TimerComponent2_Timer)
			.Parent = @This
		End With
		' PopupMenu1
		With PopupMenu1
			.Name = "PopupMenu1"
			.SetBounds 150, 10, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' OpenFileDialog1
		With OpenFileDialog1
			.Name = "OpenFileDialog1"
			.SetBounds 60, 10, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' SaveFileDialog1
		With SaveFileDialog1
			.Name = "SaveFileDialog1"
			.Filter = "gdipClock Profile|*.prf"
			.SetBounds 80, 10, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' FontDialog1
		With FontDialog1
			.Name = "FontDialog1"
			.SetBounds 110, 10, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' ColorDialog1
		With ColorDialog1
			.Name = "ColorDialog1"
			.SetBounds 130, 10, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' mnuAutoStart
		With mnuAutoStart
			.Name = "mnuAutoStart"
			.Designer = @This
			.Caption = "Auto start"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuAlwaysOnTop
		With mnuAlwaysOnTop
			.Name = "mnuAlwaysOnTop"
			.Designer = @This
			.Caption = "Always on top"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuClickThrough
		With mnuClickThrough
			.Name = "mnuClickThrough"
			.Designer = @This
			.Caption = "Click through"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuBar1
		With mnuBar1
			.Name = "mnuBar1"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuLocate
		With mnuLocate
			.Name = "mnuLocate"
			.Designer = @This
			.Caption = "Locate"
			.Parent = @PopupMenu1
		End With
		' mnuBar3
		With mnuBar3
			.Name = "mnuBar3"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuAnalogEnabled
		With mnuAnalogEnabled
			.Name = "mnuAnalogEnabled"
			.Designer = @This
			.Caption = "Analog"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuAnalogSetting
		With mnuAnalogSetting
			.Name = "mnuAnalogSetting"
			.Designer = @This
			.Caption = "Setting"
			.Enabled = False
			.Parent = @PopupMenu1
		End With
		' mnuAnalogSquare
		With mnuAnalogSquare
			.Name = "mnuAnalogSquare"
			.Designer = @This
			.Caption = "Square"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' MenuItem1
		With MenuItem1
			.Name = "MenuItem1"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogBackEnabled
		With mnuAnalogBackEnabled
			.Name = "mnuAnalogBackEnabled"
			.Designer = @This
			.Caption = "Background"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogBackFile
		With mnuAnalogBackFile
			.Name = "mnuAnalogBackFile"
			.Designer = @This
			.Caption = "File..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogBackAlpha
		With mnuAnalogBackAlpha
			.Name = "mnuAnalogBackAlpha"
			.Designer = @This
			.Caption = "Alpha..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogBackBlur
		With mnuAnalogBackBlur
			.Name = "mnuAnalogBackBlur"
			.Designer = @This
			.Caption = "Blur..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' MenuItem3
		With MenuItem3
			.Name = "MenuItem3"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogTrayEnabled
		With mnuAnalogTrayEnabled
			.Name = "mnuAnalogTrayEnabled"
			.Designer = @This
			.Caption = "Tray"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogTraySetting
		With mnuAnalogTraySetting
			.Name = "mnuAnalogTraySetting"
			.Designer = @This
			.Caption = "Setting"
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogTrayFC1
		With mnuAnalogTrayFC1
			.Name = "mnuAnalogTrayFC1"
			.Designer = @This
			.Caption = "Face color 1"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogTraySetting
		End With
		' mnuAnalogTrayFA1
		With mnuAnalogTrayFA1
			.Name = "mnuAnalogTrayFA1"
			.Designer = @This
			.Caption = "Face alpha 1"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogTraySetting
		End With
		' mnuAnalogTrayFC2
		With mnuAnalogTrayFC2
			.Name = "mnuAnalogTrayFC2"
			.Designer = @This
			.Caption = "Face color 2"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogTraySetting
		End With
		' mnuAnalogTrayFA2
		With mnuAnalogTrayFA2
			.Name = "mnuAnalogTrayFA2"
			.Designer = @This
			.Caption = "Face alpha 2"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogTraySetting
		End With
		' mnuAnalogTrayEC1
		With mnuAnalogTrayEC1
			.Name = "mnuAnalogTrayEC1"
			.Designer = @This
			.Caption = "Edge color 1"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogTraySetting
		End With
		' mnuAnalogTrayEA1
		With mnuAnalogTrayEA1
			.Name = "mnuAnalogTrayEA1"
			.Designer = @This
			.Caption = "Edge alpha 1"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogTraySetting
		End With
		' mnuAnalogTrayEC2
		With mnuAnalogTrayEC2
			.Name = "mnuAnalogTrayEC2"
			.Designer = @This
			.Caption = "Edge color 2"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogTraySetting
		End With
		' mnuAnalogTrayEA2
		With mnuAnalogTrayEA2
			.Name = "mnuAnalogTrayEA2"
			.Designer = @This
			.Caption = "Edge alpha 2"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogTraySetting
		End With
		' mnuAnalogTraySC
		With mnuAnalogTraySC
			.Name = "mnuAnalogTraySC"
			.Designer = @This
			.Caption = "Shadow color"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogTraySetting
		End With
		' mnuAnalogTraySA
		With mnuAnalogTraySA
			.Name = "mnuAnalogTraySA"
			.Designer = @This
			.Caption = "Shadow alpha"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogTraySetting
		End With
		' mnuAnalogTrayAlpha
		With mnuAnalogTrayAlpha
			.Name = "mnuAnalogTrayAlpha"
			.Designer = @This
			.Caption = "Alpha..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogTraySetting
		End With
		' mnuAnalogTrayBlur
		With mnuAnalogTrayBlur
			.Name = "mnuAnalogTrayBlur"
			.Designer = @This
			.Caption = "Blur..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogTraySetting
		End With
		' MenuItem4
		With MenuItem4
			.Name = "MenuItem4"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogScaleEnabled
		With mnuAnalogScaleEnabled
			.Name = "mnuAnalogScaleEnabled"
			.Designer = @This
			.Caption = "Scale"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogScaleColor
		With mnuAnalogScaleColor
			.Name = "mnuAnalogScaleColor"
			.Designer = @This
			.Caption = "Color..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogScaleAlpha
		With mnuAnalogScaleAlpha
			.Name = "mnuAnalogScaleAlpha"
			.Designer = @This
			.Caption = "Alpha..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogScaleBlur
		With mnuAnalogScaleBlur
			.Name = "mnuAnalogScaleBlur"
			.Designer = @This
			.Caption = "Blur..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' MenuItem5
		With MenuItem5
			.Name = "MenuItem5"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogHandEnabled
		With mnuAnalogHandEnabled
			.Name = "mnuAnalogHandEnabled"
			.Designer = @This
			.Caption = "Hand"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogHandSetting
		With mnuAnalogHandSetting
			.Name = "mnuAnalogHandSetting"
			.Designer = @This
			.Caption = "Setting"
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogHandSecondEnabled
		With mnuAnalogHandSecondEnabled
			.Name = "mnuAnalogHandSecondEnabled"
			.Designer = @This
			.Caption = "Second"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogHandSetting
		End With
		' mnuAnalogHandSecond
		With mnuAnalogHandSecond
			.Name = "mnuAnalogHandSecond"
			.Designer = @This
			.Caption = "Second..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogHandSetting
		End With
		' mnuAnalogHandMinuteEnabled
		With mnuAnalogHandMinuteEnabled
			.Name = "mnuAnalogHandMinuteEnabled"
			.Designer = @This
			.Caption = "Minute"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogHandSetting
		End With
		' mnuAnalogHandMinute
		With mnuAnalogHandMinute
			.Name = "mnuAnalogHandMinute"
			.Designer = @This
			.Caption = "Minute..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogHandSetting
		End With
		' mnuAnalogHandHourEnabled
		With mnuAnalogHandHourEnabled
			.Name = "mnuAnalogHandHourEnabled"
			.Designer = @This
			.Caption = "Hour"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogHandSetting
		End With
		' mnuAnalogHandHour
		With mnuAnalogHandHour
			.Name = "mnuAnalogHandHour"
			.Designer = @This
			.Caption = "Hour..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogHandSetting
		End With
		' mnuAnalogHandAlpha
		With mnuAnalogHandAlpha
			.Name = "mnuAnalogHandAlpha"
			.Designer = @This
			.Caption = "Alpha..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogHandSetting
		End With
		' mnuAnalogHandBlur
		With mnuAnalogHandBlur
			.Name = "mnuAnalogHandBlur"
			.Designer = @This
			.Caption = "Blur..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogHandSetting
		End With
		' MenuItem12
		With MenuItem12
			.Name = "MenuItem12"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogTextEnabled
		With mnuAnalogTextEnabled
			.Name = "mnuAnalogTextEnabled"
			.Designer = @This
			.Caption = "Text"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogTextSetting
		With mnuAnalogTextSetting
			.Name = "mnuAnalogTextSetting"
			.Designer = @This
			.Caption = "Setting"
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogTextSize
		With mnuAnalogTextSize
			.Name = "mnuAnalogTextSize"
			.Designer = @This
			.Caption = "Size..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogTextSetting
		End With
		' mnuAnalogTextFont
		With mnuAnalogTextFont
			.Name = "mnuAnalogTextFont"
			.Designer = @This
			.Caption = "Text..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogTextSetting
		End With
		' mnuAnalogTextColor
		With mnuAnalogTextColor
			.Name = "mnuAnalogTextColor"
			.Designer = @This
			.Caption = "Color..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogTextSetting
		End With
		' mnuAnalogTextFormat
		With mnuAnalogTextFormat
			.Name = "mnuAnalogTextFormat"
			.Designer = @This
			.Caption = "Format..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogTextSetting
		End With
		' mnuAnalogTextX
		With mnuAnalogTextX
			.Name = "mnuAnalogTextX"
			.Designer = @This
			.Caption = "X..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogTextSetting
		End With
		' mnuAnalogTextY
		With mnuAnalogTextY
			.Name = "mnuAnalogTextY"
			.Designer = @This
			.Caption = "Y..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogTextSetting
		End With
		' mnuAnalogTextAlpha
		With mnuAnalogTextAlpha
			.Name = "mnuAnalogTextAlpha"
			.Designer = @This
			.Caption = "Alpha..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogTextSetting
		End With
		' mnuAnalogTextBlur
		With mnuAnalogTextBlur
			.Name = "mnuAnalogTextBlur"
			.Designer = @This
			.Caption = "Blur..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogTextSetting
		End With
		' mnuBar2
		With mnuBar2
			.Name = "mnuBar2"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuTextEnabled
		With mnuTextEnabled
			.Name = "mnuTextEnabled"
			.Designer = @This
			.Caption = "Text"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuTextSetting
		With mnuTextSetting
			.Name = "mnuTextSetting"
			.Designer = @This
			.Caption = "Setting"
			.Enabled = False
			.Parent = @PopupMenu1
		End With
		' mnuTextShowSecond
		With mnuTextShowSecond
			.Name = "mnuTextShowSecond"
			.Designer = @This
			.Caption = "Show Second"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextBlinkColon
		With mnuTextBlinkColon
			.Name = "mnuTextBlinkColon"
			.Designer = @This
			.Caption = "Blink colon"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextShadow
		With mnuTextShadow
			.Name = "mnuTextShadow"
			.Designer = @This
			.Caption = "Shadow"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' MenuItem20
		With MenuItem20
			.Name = "MenuItem20"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuTextSetting
		End With
		' mnuTextBackEnabled
		With mnuTextBackEnabled
			.Name = "mnuTextBackEnabled"
			.Designer = @This
			.Caption = "Background"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextBackFile
		With mnuTextBackFile
			.Name = "mnuTextBackFile"
			.Designer = @This
			.Caption = "File..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextBackAlpha
		With mnuTextBackAlpha
			.Name = "mnuTextBackAlpha"
			.Designer = @This
			.Caption = "Alpha..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextBackBlur
		With mnuTextBackBlur
			.Name = "mnuTextBackBlur"
			.Designer = @This
			.Caption = "Blur..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' MenuItem11
		With MenuItem11
			.Name = "MenuItem11"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuTextSetting
		End With
		' mnuTextTrayEnabled
		With mnuTextTrayEnabled
			.Name = "mnuTextTrayEnabled"
			.Designer = @This
			.Caption = "Tray"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextTrayAlpha
		With mnuTextTrayAlpha
			.Name = "mnuTextTrayAlpha"
			.Designer = @This
			.Caption = "Alpha..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextTrayColor
		With mnuTextTrayColor
			.Name = "mnuTextTrayColor"
			.Designer = @This
			.Caption = "Color..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' MenuItem9
		With MenuItem9
			.Name = "MenuItem9"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuTextSetting
		End With
		' mnuTextBorderEnabled
		With mnuTextBorderEnabled
			.Name = "mnuTextBorderEnabled"
			.Designer = @This
			.Caption = "Border"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextBorderSize
		With mnuTextBorderSize
			.Name = "mnuTextBorderSize"
			.Designer = @This
			.Caption = "Size..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextBorderAlpha
		With mnuTextBorderAlpha
			.Name = "mnuTextBorderAlpha"
			.Designer = @This
			.Caption = "Alpha..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextBorderColor
		With mnuTextBorderColor
			.Name = "mnuTextBorderColor"
			.Designer = @This
			.Caption = "Color..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' MenuItem10
		With MenuItem10
			.Name = "MenuItem10"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuTextSetting
		End With
		With mnuTextFont
			.Name = "mnuTextFont"
			.Designer = @This
			.Caption = "Text..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextBlur
		With mnuTextBlur
			.Name = "mnuTextBlur"
			.Designer = @This
			.Caption = "Blur..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextAlpha1
		With mnuTextAlpha1
			.Name = "mnuTextAlpha1"
			.Designer = @This
			.Caption = "Alpha 1..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextAlpha2
		With mnuTextAlpha2
			.Name = "mnuTextAlpha2"
			.Designer = @This
			.Caption = "Alpha 2..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' MenuItem2
		With MenuItem2
			.Name = "MenuItem2"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuTextSetting
		End With
		' mnuTextGradient
		With mnuTextGradient
			.Name = "mnuTextGradient"
			.Designer = @This
			.Caption = "Gradient"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextColor1
		With mnuTextColor1
			.Name = "mnuTextColor1"
			.Designer = @This
			.Caption = "Color 1..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextColor2
		With mnuTextColor2
			.Name = "mnuTextColor2"
			.Designer = @This
			.Caption = "Color 2..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextDirection
		With mnuTextDirection
			.Name = "mnuTextDirection"
			.Designer = @This
			.Caption = "Mode"
			.Parent = @mnuTextSetting
		End With
		' MenuItem16
		With MenuItem16
			.Name = "MenuItem16"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuTextSetting
		End With
		' mnuTextWhite
		With mnuTextWhite
			.Name = "mnuTextWhite"
			.Designer = @This
			.Caption = "White"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextBlack
		With mnuTextBlack
			.Name = "mnuTextBlack"
			.Designer = @This
			.Caption = "Black"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextRed
		With mnuTextRed
			.Name = "mnuTextRed"
			.Designer = @This
			.Caption = "Red"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextGreen
		With mnuTextGreen
			.Name = "mnuTextGreen"
			.Designer = @This
			.Caption = "Green"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextBlue
		With mnuTextBlue
			.Name = "mnuTextBlue"
			.Designer = @This
			.Caption = "Blue"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextGradientMode1
		With mnuTextGradientMode1
			.Name = "mnuTextGradientMode1"
			.Designer = @This
			.Caption = "Horizontal"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextDirection
		End With
		' mnuTextGradientMode2
		With mnuTextGradientMode2
			.Name = "mnuTextGradientMode2"
			.Designer = @This
			.Caption = "Vertical"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextDirection
		End With
		' mnuTextGradientMode3
		With mnuTextGradientMode3
			.Name = "mnuTextGradientMode3"
			.Designer = @This
			.Caption = "Forward"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextDirection
		End With
		' mnuTextGradientMode4
		With mnuTextGradientMode4
			.Name = "mnuTextGradientMode4"
			.Designer = @This
			.Caption = "Backward"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextDirection
		End With
		' mnuLocateReset
		With mnuLocateReset
			.Name = "mnuLocateReset"
			.Designer = @This
			.Caption = "Reset"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuLocate
		End With
		' mnuLocateSticky
		With mnuLocateSticky
			.Name = "mnuLocateSticky"
			.Designer = @This
			.Caption = "Sticky"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuLocate
		End With
		' MenuItem8
		With MenuItem8
			.Name = "MenuItem8"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuLocate
		End With
		' mnuLocateLeft
		With mnuLocateLeft
			.Name = "mnuLocateLeft"
			.Designer = @This
			.Caption = "Left"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuLocate
		End With
		' mnuLocateHorizontalMiddle
		With mnuLocateHorizontalMiddle
			.Name = "mnuLocateHorizontalMiddle"
			.Designer = @This
			.Caption = "Middle"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuLocate
		End With
		' mnuLocateRight
		With mnuLocateRight
			.Name = "mnuLocateRight"
			.Designer = @This
			.Caption = "Right"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuLocate
		End With
		' mnuLocateHorizontalAny
		With mnuLocateHorizontalAny
			.Name = "mnuLocateHorizontalAny"
			.Designer = @This
			.Caption = "Any"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuLocate
		End With
		' MenuItem15
		With MenuItem15
			.Name = "MenuItem15"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuLocate
		End With
		' mnuLocateTop
		With mnuLocateTop
			.Name = "mnuLocateTop"
			.Designer = @This
			.Caption = "Top"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuLocate
		End With
		' mnuLocateVerticalMiddle
		With mnuLocateVerticalMiddle
			.Name = "mnuLocateVerticalMiddle"
			.Designer = @This
			.Caption = "Middle"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuLocate
		End With
		' mnuLocateBottom
		With mnuLocateBottom
			.Name = "mnuLocateBottom"
			.Designer = @This
			.Caption = "Bottom"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuLocate
		End With
		' mnuLocateVerticalAny
		With mnuLocateVerticalAny
			.Name = "mnuLocateVerticalAny"
			.Designer = @This
			.Caption = "Any"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuLocate
		End With
		' MenuItem14
		With MenuItem14
			.Name = "MenuItem14"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuDayEnabled
		With mnuDayEnabled
			.Name = "mnuDayEnabled"
			.Designer = @This
			.Caption = "Day"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuDaySetting
		With mnuDaySetting
			.Name = "mnuDaySetting"
			.Designer = @This
			.Caption = "Setting"
			.Enabled = True
			.Parent = @PopupMenu1
		End With
		' MenuItem17
		With MenuItem17
			.Name = "MenuItem17"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuMonthEnabled
		With mnuMonthEnabled
			.Name = "mnuMonthEnabled"
			.Designer = @This
			.Caption = "Month"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuMonthSetting
		With mnuMonthSetting
			.Name = "mnuMonthSetting"
			.Designer = @This
			.Caption = "Setting"
			.Enabled = True
			.Parent = @PopupMenu1
		End With
		' MenuItem6
		With MenuItem6
			.Name = "MenuItem6"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuAspectRatio
		With mnuAspectRatio
			.Name = "mnuAspectRatio"
			.Designer = @This
			.Caption = "Aspect ratio"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuTransparent
		With mnuTransparent
			.Name = "mnuTransparent"
			.Designer = @This
			.Caption = "Transparent"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuOpacityValue
		With mnuOpacityValue
			.Name = "mnuOpacityValue"
			.Designer = @This
			.Caption = "Opacity..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuHide
		With mnuHide
			.Name = "mnuHide"
			.Designer = @This
			.Caption = "Hide"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuBar4
		With mnuBar4
			.Name = "mnuBar4"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuAnnounce
		With mnuAnnounce
			.Name = "mnuAnnounce"
			.Designer = @This
			.Caption = "Announce"
			.Enabled = False
			.Parent = @PopupMenu1
		End With
		' mnuSpeechNow
		With mnuSpeechNow
			.Name = "mnuSpeechNow"
			.Designer = @This
			.Caption = "Speech time"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuVoice
		With mnuVoice
			.Name = "mnuVoice"
			.Designer = @This
			.Caption = "Voice"
			.Enabled = False
			.Parent = @mnuAnnounce
		End With
		' mnuAudio
		With mnuAudio
			.Name = "mnuAudio"
			.Designer = @This
			.Caption = "Audio"
			.Enabled = False
			.Parent = @mnuAnnounce
		End With
		' MenuItem13
		With MenuItem13
			.Name = "MenuItem13"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuAnnounce
		End With
		' mnuAnnounce0
		With mnuAnnounce0
			.Name = "mnuAnnounce0"
			.Designer = @This
			.Caption = "None"
			.Parent = @mnuAnnounce
		End With
		' mnuAnnounce1
		With mnuAnnounce1
			.Name = "mnuAnnounce1"
			.Designer = @This
			.Caption = "Hourly"
			.Parent = @mnuAnnounce
		End With
		' mnuAnnounce2
		With mnuAnnounce2
			.Name = "mnuAnnounce2"
			.Designer = @This
			.Caption = "Half hour"
			.Parent = @mnuAnnounce
		End With
		' mnuAnnounce3
		With mnuAnnounce3
			.Name = "mnuAnnounce3"
			.Designer = @This
			.Caption = "Quarter hour"
			.Checked = True
			.Parent = @mnuAnnounce
		End With
		' mnuBar5
		With mnuBar5
			.Name = "mnuBar5"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuProfileMain
		With mnuProfileMain
			.Name = "mnuProfileMain"
			.Designer = @This
			.Caption = "Profile"
			.Enabled = True
			.Parent = @PopupMenu1
		End With
		' mnuProfileSave
		With mnuProfileSave
			.Name = "mnuProfileSave"
			.Designer = @This
			.Caption = "Save as..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuProfileMain
		End With
		' MenuItem7
		With MenuItem7
			.Name = "MenuItem7"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuAbout
		With mnuAbout
			.Name = "mnuAbout"
			.Designer = @This
			.Caption = "About"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuTest
		With mnuTest
			.Name = "mnuTest"
			.Designer = @This
			.Caption = "Test"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
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
			.Caption = "Exit"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuDaySplit
		With mnuDaySplit
			.Name = "mnuDaySplit"
			.Designer = @This
			.Caption = "Split..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' MenuItem21
		With MenuItem21
			.Name = "MenuItem21"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuDaySetting
		End With
		' mnuDayStyle0
		With mnuDayStyle0
			.Name = "mnuDayStyle0"
			.Designer = @This
			.Caption = "Both"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' mnuDayStyle1
		With mnuDayStyle1
			.Name = "mnuDayStyle1"
			.Designer = @This
			.Caption = "Gregorian"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' mnuDayStyle2
		With mnuDayStyle2
			.Name = "mnuDayStyle2"
			.Designer = @This
			.Caption = "Lunar"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' MenuItem23
		With MenuItem23
			.Name = "MenuItem23"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuDaySetting
		End With
		' mnuDayTextFont
		With mnuDayTextFont
			.Name = "mnuDayTextFont"
			.Designer = @This
			.Caption = "Font..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' mnuDayTextAlpha
		With mnuDayTextAlpha
			.Name = "mnuDayTextAlpha"
			.Designer = @This
			.Caption = "Alpha..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' mnuDayFCFocus
		With mnuDayFCFocus
			.Name = "mnuDayFCFocus"
			.Designer = @This
			.Caption = "Focus"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' mnuDayFCYear
		With mnuDayFCYear
			.Name = "mnuDayFCYear"
			.Designer = @This
			.Caption = "Year"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' mnuDayFCMonth
		With mnuDayFCMonth
			.Name = "mnuDayFCMonth"
			.Designer = @This
			.Caption = "Month"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' mnuDayFCDay
		With mnuDayFCDay
			.Name = "mnuDayFCDay"
			.Designer = @This
			.Caption = "Day"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' mnuDayFCWeek
		With mnuDayFCWeek
			.Name = "mnuDayFCWeek"
			.Designer = @This
			.Caption = "Week"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' MenuItem32
		With MenuItem32
			.Name = "MenuItem32"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuDaySetting
		End With
		' mnuDayTrayEnabled
		With mnuDayTrayEnabled
			.Name = "mnuDayTrayEnabled"
			.Designer = @This
			.Caption = "Tray"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' mnuDayTrayAlpha
		With mnuDayTrayAlpha
			.Name = "mnuDayTrayAlpha"
			.Designer = @This
			.Caption = "Alpha..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' mnuDayBCFocus
		With mnuDayBCFocus
			.Name = "mnuDayBCFocus"
			.Designer = @This
			.Caption = "Focus"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' mnuDayBCYear
		With mnuDayBCYear
			.Name = "mnuDayBCYear"
			.Designer = @This
			.Caption = "Year"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' mnuDayBCMonth
		With mnuDayBCMonth
			.Name = "mnuDayBCMonth"
			.Designer = @This
			.Caption = "Month"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' mnuDayBCDay
		With mnuDayBCDay
			.Name = "mnuDayBCDay"
			.Designer = @This
			.Caption = "Day"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' mnuDayBCWeek
		With mnuDayBCWeek
			.Name = "mnuDayBCWeek"
			.Designer = @This
			.Caption = "Week"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' MenuItem27
		With MenuItem27
			.Name = "MenuItem27"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuDaySetting
		End With
		' mnuDayBackEnabled
		With mnuDayBackEnabled
			.Name = "mnuDayBackEnabled"
			.Designer = @This
			.Caption = "Background"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' mnuDayBackFile
		With mnuDayBackFile
			.Name = "mnuDayBackFile"
			.Designer = @This
			.Caption = "File..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' mnuDayBackAlpha
		With mnuDayBackAlpha
			.Name = "mnuDayBackAlpha"
			.Designer = @This
			.Caption = "Aplha..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' mnuDayBackBlur
		With mnuDayBackBlur
			.Name = "mnuDayBackBlur"
			.Designer = @This
			.Caption = "Blur..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' mnuMonthControls
		With mnuMonthControls
			.Name = "mnuMonthControls"
			.Designer = @This
			.Caption = "Show controls"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthWeeks
		With mnuMonthWeeks
			.Name = "mnuMonthWeeks"
			.Designer = @This
			.Caption = "Show weeks"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' MenuItem22
		With MenuItem22
			.Name = "MenuItem22"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthTextFont
		With mnuMonthTextFont
			.Name = "mnuMonthTextFont"
			.Designer = @This
			.Caption = "Font..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthTextAlpha
		With mnuMonthTextAlpha
			.Name = "mnuMonthTextAlpha"
			.Designer = @This
			.Caption = "Alpha..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthFCFocus
		With mnuMonthFCFocus
			.Name = "mnuMonthFCFocus"
			.Designer = @This
			.Caption = "Focus"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthFCControl
		With mnuMonthFCControl
			.Name = "mnuMonthFCControl"
			.Designer = @This
			.Caption = "Control"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthFCWeek
		With mnuMonthFCWeek
			.Name = "mnuMonthFCWeek"
			.Designer = @This
			.Caption = "Week"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthFCDay
		With mnuMonthFCDay
			.Name = "mnuMonthFCDay"
			.Designer = @This
			.Caption = "Day"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthFCSelect
		With mnuMonthFCSelect
			.Name = "mnuMonthFCSelect"
			.Designer = @This
			.Caption = "Select"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthFCToday
		With mnuMonthFCToday
			.Name = "mnuMonthFCToday"
			.Designer = @This
			.Caption = "Today"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthFCHoliday
		With mnuMonthFCHoliday
			.Name = "mnuMonthFCHoliday"
			.Designer = @This
			.Caption = "Holiday"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' MenuItem26
		With MenuItem26
			.Name = "MenuItem26"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthTrayEnabled
		With mnuMonthTrayEnabled
			.Name = "mnuMonthTrayEnabled"
			.Designer = @This
			.Caption = "Tray"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthTrayAlpha
		With mnuMonthTrayAlpha
			.Name = "mnuMonthTrayAlpha"
			.Designer = @This
			.Caption = "Alpha..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthBCFocus
		With mnuMonthBCFocus
			.Name = "mnuMonthBCFocus"
			.Designer = @This
			.Caption = "Focus"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthBCControl
		With mnuMonthBCControl
			.Name = "mnuMonthBCControl"
			.Designer = @This
			.Caption = "Control"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthBCWeek
		With mnuMonthBCWeek
			.Name = "mnuMonthBCWeek"
			.Designer = @This
			.Caption = "Week"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthBCDay
		With mnuMonthBCDay
			.Name = "mnuMonthBCDay"
			.Designer = @This
			.Caption = "Day"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' MenuItem30
		With MenuItem30
			.Name = "MenuItem30"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthBackEnabled
		With mnuMonthBackEnabled
			.Name = "mnuMonthBackEnabled"
			.Designer = @This
			.Caption = "Background"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthBackFile
		With mnuMonthBackFile
			.Name = "mnuMonthBackFile"
			.Designer = @This
			.Caption = "File..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthBackAlpha
		With mnuMonthBackAlpha
			.Name = "mnuMonthBackAlpha"
			.Designer = @This
			.Caption = "Alpha..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthBackBlur
		With mnuMonthBackBlur
			.Name = "mnuMonthBackBlur"
			.Designer = @This
			.Caption = "Blur..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
	End Constructor
	
	Dim Shared frmClock As frmClockType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmClock.MainForm = True
		frmClock.Show
		App.Run
	#endif
'#End Region

#include once "frmDay.frm"
#include once "frmMonth.frm"

'Region Tray Menu
#include once "windows.bi"
Dim Shared As NOTIFYICONDATA SystrayIcon
Const WM_SHELLNOTIFY = WM_USER + 5

Private Function CheckAutoStart() As Integer
	Dim As Integer CheckResult = 0
	#ifdef __USE_WINAPI__
		'Region registry
		
		Dim As Any Ptr hReg
		Dim As WString Ptr sNewRegValue = NULL
		Dim As DWORD lRegLen = 0
		Dim As DWORD lpType  = 0
		Dim As Long lRes
		'open
		lRes = RegOpenKeyEx(HKEY_CURRENT_USER, "SOFTWARE\Microsoft\Windows\CurrentVersion\Run", 0, KEY_ALL_ACCESS, @hReg)
		If lRes <> ERROR_SUCCESS Then
			RegCloseKey(hReg)
			Exit Function
		End If
		
		lRes = RegQueryValueEx(hReg, WStr("VFBE GDIP Clock"), 0, @lpType, 0, @lRegLen)
		If lRes <> ERROR_SUCCESS Then RegCloseKey(hReg): Exit Function
		
		sNewRegValue = Reallocate(sNewRegValue, (lRegLen + 1) * 2)
		lRes = RegQueryValueEx(hReg, WStr("VFBE GDIP Clock"), 0, @lpType, Cast(Byte Ptr, sNewRegValue), @lRegLen)
		If lRes <> ERROR_SUCCESS Then RegCloseKey(hReg): Exit Function
		
		'close registry
		RegCloseKey(hReg)
		CheckResult = InStr(*sNewRegValue, Command(0))
		Deallocate(sNewRegValue)
	#endif
	Return CheckResult
End Function

Private Sub AutoStartReg(flag As Boolean = True)
	#ifdef __USE_WINAPI__
		'Region registry
		Dim As Any Ptr hReg
		Dim As WString Ptr sNewRegValue
		Dim As Integer lRegLen = (Len(WChr(34) & Command(0) & WChr(34) & WChr(0)) + 1) * 2
		
		sNewRegValue = Allocate(lRegLen)
		*sNewRegValue = WChr(34) & Command(0) & WChr(34) & WChr(0)
		
		'open
		RegOpenKeyEx(HKEY_CURRENT_USER, "SOFTWARE\Microsoft\Windows\CurrentVersion\Run", 0, KEY_ALL_ACCESS, @hReg)
		
		If flag Then
			RegSetValueEx(hReg, WStr("VFBE GDIP Clock"), NULL, REG_SZ, Cast(Byte Ptr, sNewRegValue), lRegLen)
		Else
			RegDeleteValue(hReg, WStr("VFBE GDIP Clock"))
		End If
		
		RegFlushKey(hReg)
		
		'close registry
		RegCloseKey(hReg)
		Deallocate(sNewRegValue)
	#endif
End Sub

Private Function frmClockType.ProfileIdx(ByVal fIncNum As Integer = -1) As Integer
	Static sIdx As Integer
	If fIncNum < 0 Then
		sIdx = sIdx + 1
	Else
		sIdx = fIncNum
	End If
	Return sIdx
End Function

Private Sub frmClockType.TestBackup()
	ReDim TestMenu(TestCount)
	ReDim TestSetting(TestCount)
	TestMenu(0) = @mnuAnalogEnabled
	TestMenu(1) = @mnuAnalogBackEnabled
	TestMenu(2) = @mnuAnalogTrayEnabled
	TestMenu(3) = @mnuAnalogScaleEnabled
	TestMenu(4) = @mnuAnalogTextEnabled
	TestMenu(5) = @mnuAnalogHandEnabled
	TestMenu(6) = @mnuTextEnabled
	TestMenu(7) = @mnuTextBackEnabled
	TestMenu(8) = @mnuTextTrayEnabled
	TestMenu(9) = @mnuTextShowSecond
	TestMenu(10) = @mnuTextBlinkColon
	TestMenu(11) = @mnuTextBorderEnabled
	TestMenu(12) = @mnuTransparent
	Dim i As Integer
	For i = 0 To TestCount
		TestSetting(i) = TestMenu(i)->Checked
	Next
End Sub

Private Sub frmClockType.TestRestore()
	Dim i As Integer
	For i = 0 To TestCount
		If TestSetting(i) <> TestMenu(i)->Checked Then
			mnuMenu_Click(*TestMenu(i))
		End If
	Next
End Sub

Private Sub frmClockType.TestStress()
	Static i As Integer = 0
	i += 1
	If i > TestCount Then i = 0
	mnuMenu_Click(*TestMenu(i))
End Sub
Private Sub frmClockType.Profile2Menu()
	Dim i As Integer
	For i = mnuProfileCount To 0 Step -1
		mnuProfileMain.Remove(mnuProfileList(i))
		Delete mnuProfileList(i)
	Next
	Erase mnuProfileList
	mnuProfileCount = -1
	
	Dim f As String
	Dim t As String
	f = Dir(*mAppPath & "*.prf")
	Do
		i = Len(f) - Len(".prf")
		If i > 0 Then
			mnuProfileCount += 1
			ReDim Preserve mnuProfileList(mnuProfileCount)
			mnuProfileList(mnuProfileCount) = New MenuItem
			
			If mnuProfileCount = 0 Then
				mnuProfileList(mnuProfileCount)->Name = "mnuProfileList"
				mnuProfileList(mnuProfileCount)->Caption = "-"
				mnuProfileList(mnuProfileCount)->Designer = @This
				mnuProfileList(mnuProfileCount)->Parent = @mnuProfileMain
				mnuProfileMain.Add mnuProfileList(mnuProfileCount)
				
				mnuProfileCount += 1
				ReDim Preserve mnuProfileList(mnuProfileCount)
				mnuProfileList(mnuProfileCount) = New MenuItem
			End If
			
			t = Mid(f, 1, i)
			If InStr(*mProfile, f) Then mnuProfileList(mnuProfileCount)->Checked = True
			mnuProfileList(mnuProfileCount)->Name = "mnuProfileList"
			mnuProfileList(mnuProfileCount)->Caption = t
			mnuProfileList(mnuProfileCount)->Designer = @This
			mnuProfileList(mnuProfileCount)->Parent = @mnuProfileMain
			mnuProfileList(mnuProfileCount)->OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			mnuProfileMain.Add mnuProfileList(mnuProfileCount)
		End If
		f = Dir()
	Loop While f <> ""
End Sub
Private Sub frmClockType.Profile2Interface()
	mnuOpacityValue.Caption = "Opacity " & mOpacity & "..."
	
	mnuAnalogSetting.Enabled = mnuAnalogEnabled.Checked
	'If mnuAnalogSetting.Enabled Then
	mnuAnalogBackEnabled.Checked = mAnalogClock.mBackEnabled
	mnuAnalogTrayEnabled.Checked = mAnalogClock.mTrayEnabled
	mnuAnalogScaleEnabled.Checked = mAnalogClock.mScaleEnabled
	mnuAnalogHandEnabled.Checked = mAnalogClock.mHandEnabled
	mnuAnalogHandSecondEnabled.Checked = mAnalogClock.mHandSecondEnabled
	mnuAnalogHandMinuteEnabled.Checked = mAnalogClock.mHandMinuteEnabled
	mnuAnalogHandHourEnabled.Checked = mAnalogClock.mHandHourEnabled
	mnuAnalogTextEnabled.Checked = mAnalogClock.mTextEnabled
	mnuAnalogBackFile.Caption = "File [" & FullName2File(mAnalogClock.FileName) & "]..."
	mnuAnalogBackAlpha.Caption = "Alpha " & mAnalogClock.mBackAlpha & "..."
	mnuAnalogBackBlur.Caption = "Blur " & mAnalogClock.mBackBlur & "..."
	mnuAnalogTrayAlpha.Caption = "Alpha " & mAnalogClock.mTrayAlpha & "..."
	mnuAnalogTrayBlur.Caption = "Blur " & mAnalogClock.mTrayBlur & "..."
	mnuAnalogScaleColor.Caption = "Color &&H" & Hex(mAnalogClock.mScaleColor) & "..."
	mnuAnalogScaleAlpha.Caption = "Alpha " & mAnalogClock.mScaleAlpha & "..."
	mnuAnalogScaleBlur.Caption = "Blur " & mAnalogClock.mScaleBlur & "..."
	mnuAnalogHandSecond.Caption = "Second Color &&H" & Hex(mAnalogClock.mHandSecondColor) & "..."
	mnuAnalogHandMinute.Caption = "Minute Color &&H" & Hex(mAnalogClock.mHandMinuteColor) & "..."
	mnuAnalogHandHour.Caption = "Hour Color &&H" & mAnalogClock.mHandHourColor & "..."
	mnuAnalogHandAlpha.Caption = "Alpha " & mAnalogClock.mHandAlpha & "..."
	mnuAnalogTrayFC1.Caption = "Face Color 1 &&H" & Hex(mAnalogClock.mTrayFaceColor1) & "..."
	mnuAnalogTrayFC2.Caption = "Face Color 2 &&H" & Hex(mAnalogClock.mTrayFaceColor2) & "..."
	mnuAnalogTrayEC1.Caption = "Edge Color 1 &&H" & Hex(mAnalogClock.mTrayEdgeColor1) & "..."
	mnuAnalogTrayEC2.Caption = "Edge Color 2 &&H" & Hex(mAnalogClock.mTrayEdgeColor2) & "..."
	mnuAnalogTraySC.Caption = "Shadow Color &&H" & Hex(mAnalogClock.mTrayShadowColor) & "..."
	mnuAnalogTrayFA1.Caption = "Face Alpha 1 " & mAnalogClock.mTrayFaceAlpha1 & "..."
	mnuAnalogTrayFA2.Caption = "Face Alpha 2 " & mAnalogClock.mTrayFaceAlpha2 & "..."
	mnuAnalogTrayEA1.Caption = "Edge Alpha 1 " & mAnalogClock.mTrayEdgeAlpha1 & "..."
	mnuAnalogTrayEA2.Caption = "Edge Alpha 2 " & mAnalogClock.mTrayEdgeAlpha2 & "..."
	mnuAnalogTraySA.Caption = "Shadow Alpha " & mAnalogClock.mTrayShadowAlpha & "..."
	mnuAnalogHandBlur.Caption = "Blur " & mAnalogClock.mHandBlur & "..."
	mnuAnalogTextSize.Caption = "Size " & mAnalogClock.mTextSize & "..."
	mnuAnalogTextFont.Caption = *mAnalogClock.mTextFont & ", " & mAnalogClock.mTextBold & "..."
	mnuAnalogTextColor.Caption = "Color &&H" & Hex(mAnalogClock.mTextColor) & "..."
	mnuAnalogTextX.Caption = "X " & mAnalogClock.mTextOffsetX & "..."
	mnuAnalogTextY.Caption = "Y " & mAnalogClock.mTextOffsetY & "..."
	mnuAnalogTextFormat.Caption = "Format [" & *mAnalogClock.mTextFormat & "]..."
	mnuAnalogTextAlpha.Caption = "Alpha " & mAnalogClock.mTextAlpha & "..."
	mnuAnalogTextBlur.Caption = "Blur " & mAnalogClock.mTextBlur & "..."
	'End If
	
	mnuTextSetting.Enabled = mnuTextEnabled.Checked
	'If mnuTextSetting.Enabled Then
	mnuTextShowSecond.Checked = mTextClock.mShowSecond
	mnuTextBlinkColon.Checked = mTextClock.mBlinkColon
	mnuTextShadow.Checked = mTextClock.mShadowEnabled
	mnuTextBackEnabled.Checked = mTextClock.mBackEnabled
	mnuTextTrayEnabled.Checked = mTextClock.mTrayEnabled
	mnuTextBorderEnabled.Checked = mTextClock.mBorderEnabled
	mnuTextBackFile.Caption = "File [" & FullName2File(mTextClock.FileName) & "]..."
	mnuTextBackAlpha.Caption = "Alpha " & mTextClock.mBackAlpha & "..."
	mnuTextBackBlur.Caption = "Blur " & mTextClock.mBackBlur & "..."
	mnuTextFont.Caption = *mTextClock.mFontName & ", " & mTextClock.mFontStyle & "..."
	mnuTextAlpha1.Caption = "Alpha1 " & mTextAlpha1 & "..."
	mnuTextAlpha2.Caption = "Alpha2 " & mTextAlpha2 & "..."
	mnuTextBlur.Caption = "Blur " & mTextClock.mTextBlur & "..."
	mnuTextColor1.Caption = "Color 1 &&H" & Hex(mTextColor1) & "..."
	mnuTextColor2.Caption = "Color 2 &&H" & Hex(mTextColor2) & "..."
	mnuTextTrayAlpha.Caption = "Alpha " & mTextClock.mTrayAlpha & "..."
	mnuTextTrayColor.Caption = "Color &&H" & Hex(mTextClock.mTrayColor) & "..."
	mnuTextBorderSize.Caption = "Size " & mTextClock.mBorderSize & "..."
	mnuTextBorderAlpha.Caption = "Alpha " & mTextClock.mBorderAlpha & "..."
	mnuTextBorderColor.Caption = "Color &&H" & Hex(mTextClock.mBorderColor) & "..."
	'End If
	
	mnuDaySetting.Enabled = mnuDayEnabled.Checked
	'If mnuDaySetting.Enabled Then
	mnuDayBackAlpha.Caption = "Alpha " & frmDay.mDay.mBackAlpha & "..."
	mnuDayBackBlur.Caption = "Blur " & frmDay.mDay.mBackBlur & "..."
	mnuDayBackEnabled.Checked = frmDay.mDay.mBackEnabled
	mnuDayBackFile.Caption = "File [" & FullName2File(frmDay.mDay.mBackImage.ImageFile) & "]..."
	mnuDaySplit.Caption = "Split " & frmDay.mDay.mSplitXScale & "..."
	mnuDayStyle0.Checked = CBool(frmDay.mDay.mShowStyle = 0)
	mnuDayStyle1.Checked = CBool(frmDay.mDay.mShowStyle = 1)
	mnuDayStyle2.Checked = CBool(frmDay.mDay.mShowStyle = 2)
	mnuDayTextAlpha.Caption = "Alpha " & frmDay.mDay.mForeOpacity & "..."
	mnuDayFCFocus.Caption = "Focus &&H" & Hex(frmDay.mDay.mClr(1)) & "..."
	mnuDayFCYear.Caption = "Year &&H" & Hex(frmDay.mDay.mClr(3)) & "..."
	mnuDayFCMonth.Caption = "Month &&H" & Hex(frmDay.mDay.mClr(5)) & "..."
	mnuDayFCDay.Caption = "Day &&H" & Hex(frmDay.mDay.mClr(7)) & "..."
	mnuDayFCWeek.Caption = "Week &&H" & Hex(frmDay.mDay.mClr(9)) & "..."
	mnuDayTextFont.Caption = "Font " & *frmDay.mDay.mFontName & "..."
	mnuDayTrayAlpha.Caption = "Alpha " & frmDay.mDay.mTrayAlpha & "..."
	mnuDayBCFocus.Caption = "Focus &&H" & Hex(frmDay.mDay.mClr(0)) & "..."
	mnuDayBCYear.Caption = "Year &&H" & Hex(frmDay.mDay.mClr(2)) & "..."
	mnuDayBCMonth.Caption = "Month &&H" & Hex(frmDay.mDay.mClr(4)) & "..."
	mnuDayBCDay.Caption = "Day &&H" & Hex(frmDay.mDay.mClr(6)) & "..."
	mnuDayBCWeek.Caption = "Week &&H" & Hex(frmDay.mDay.mClr(8)) & "..."
	mnuDayTrayEnabled.Checked = frmDay.mDay.mTrayEnabled
	'End If
	
	mnuMonthSetting.Enabled = mnuMonthEnabled.Checked
	'If mnuMonthSetting.Enabled Then
	mnuMonthBackAlpha.Caption = "Alpha " & frmMonth.mMonth.mBackAlpha & "..."
	mnuMonthBackBlur.Caption = "Blur " & frmMonth.mMonth.mBackBlur & "..."
	mnuMonthBackEnabled.Checked = frmMonth.mMonth.mBackEnabled
	mnuMonthBackFile.Caption = "File [" & FullName2File(frmMonth.mMonth.mBackImage.ImageFile) & "]..."
	mnuMonthControls.Checked = frmMonth.mMonth.mShowControls
	mnuMonthTextAlpha.Caption = "Alpha " & frmMonth.mMonth.mForeOpacity & "..."
	mnuMonthFCFocus.Caption = "Focus &&H" & Hex(frmMonth.mMonth.mClr(1)) & "..."
	mnuMonthFCControl.Caption = "Control &&H" & Hex(frmMonth.mMonth.mClr(3)) & "..."
	mnuMonthFCWeek.Caption = "Week &&H" & Hex(frmMonth.mMonth.mClr(5)) & "..."
	mnuMonthFCDay.Caption = "Day &&H" & Hex(frmMonth.mMonth.mClr(7)) & "..."
	mnuMonthFCSelect.Caption = "Select &&H" & Hex(frmMonth.mMonth.mClr(8)) & "..."
	mnuMonthFCToday.Caption = "Today &&H" & Hex(frmMonth.mMonth.mClr(9)) & "..."
	mnuMonthFCHoliday.Caption = "Holiday &&H" & Hex(frmMonth.mMonth.mClr(10)) & "..."
	mnuMonthTextFont.Caption = "Font " & *frmMonth.mMonth.mFontName & "..."
	mnuMonthTrayAlpha.Caption = "Alpha " & frmMonth.mMonth.mTrayAlpha & "..."
	mnuMonthBCFocus.Caption = "Focus &&H" & Hex(frmMonth.mMonth.mClr(0)) & "..."
	mnuMonthBCControl.Caption = "Control &&H" & Hex(frmMonth.mMonth.mClr(2)) & "..."
	mnuMonthBCWeek.Caption = "Week &&H" & Hex(frmMonth.mMonth.mClr(4)) & "..."
	mnuMonthBCDay.Caption = "Day &&H" & Hex(frmMonth.mMonth.mClr(6)) & "..."
	mnuMonthTrayEnabled.Checked = frmMonth.mMonth.mTrayEnabled
	mnuMonthWeeks.Checked = frmMonth.mMonth.mShowWeeks
	'End If
	
End Sub

Private Function frmClockType.ProfileDefLoad() ByRef As WString
	Static sProfile As WString Ptr
	WLet(sProfile, TextFromFile(ProfileFull("gdipClock.ini")))
	If *sProfile = "" Then
		Return ProfileFull("gdipClock.prf")
	Else
		Return ProfileFull(*sProfile)
	End If
End Function

Private Function frmClockType.ProfileSimple(sFileName As WString) ByRef As WString
	Static sRtn As WString Ptr
	Dim sSLen As Integer = Len(sFileName)
	Dim sPLen As Integer = Len(*mAppPath)
	Dim sPLoc As Integer = InStr(sFileName, *mAppPath)
	If sPLoc Then
		WLet(sRtn, Mid(sFileName, sPLoc + sPLen, sSLen - sPLen - sPLoc + 1))
	Else
		WLet(sRtn, sFileName)
	End If
	Return *sRtn
End Function

Private Function frmClockType.ProfileFull(sFileName As WString) ByRef As WString
	Static sRtn As WString Ptr
	If InStr(sFileName, "\") Then
		WLet(sRtn, sFileName)
	Else
		WLet(sRtn, *mAppPath & sFileName)
	End If
	Return *sRtn
End Function

Private Sub frmClockType.ProfileDefSave()
	TextToFile(ProfileFull("gdipClock.ini"), ProfileSimple(*mProfile))
End Sub
Private Sub frmClockType.ProfileInitial()
	WLet(mAppPath, FullName2Path(App.FileName) & "\")
	ReDim mKeyName(mKeyCount)
	ReDim mKeyValue(mKeyCount)
	ReDim mKeyNameLen(mKeyCount)
	
	mSetMainStart = ProfileIdx(0)
	WLet(mKeyName(ProfileIdx(0)), WStr("[Main]"))
	WLet(mKeyName(ProfileIdx()), WStr("Clock Left = "))
	WLet(mKeyName(ProfileIdx()), WStr("Clock Top = "))
	WLet(mKeyName(ProfileIdx()), WStr("Clock Width = "))
	WLet(mKeyName(ProfileIdx()), WStr("Clock Height = "))
	WLet(mKeyName(ProfileIdx()), WStr("Clock Always on top = "))
	WLet(mKeyName(ProfileIdx()), WStr("Clock Click through = "))
	
	WLet(mKeyName(ProfileIdx()), WStr("Clock Analog enabled = "))
	WLet(mKeyName(ProfileIdx()), WStr("Clock Text enabled = "))
	WLet(mKeyName(ProfileIdx()), WStr("Clock Day enabled = "))
	WLet(mKeyName(ProfileIdx()), WStr("Clock Month enabled = "))
	
	WLet(mKeyName(ProfileIdx()), WStr("Clock Transparent = "))
	WLet(mKeyName(ProfileIdx()), WStr("Clock Opacity value = "))
	WLet(mKeyName(ProfileIdx()), WStr("Clock Locate arrange = "))
	WLet(mKeyName(ProfileIdx()), WStr("Clock Hide = "))
	
	mSetAnalogStart = ProfileIdx()
	WLet(mKeyName(ProfileIdx(mSetAnalogStart)), WStr("[Analog]"))
	
	WLet(mKeyName(ProfileIdx()), WStr("Analog background enabled = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog background file = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog background alpha = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog background blur = "))
	
	WLet(mKeyName(ProfileIdx()), WStr("Analog tray enabled = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog tray face color 1 = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog tray face alpha 1 = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog tray face color 2 = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog tray face alpha 2 = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog tray edge color 1 = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog tray edge alpha 1 = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog tray edge color 2 = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog tray edge alpha 2 = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog tray shadow color = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog tray shadow alpha = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog tray alpha = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog tray blur = "))
	
	WLet(mKeyName(ProfileIdx()), WStr("Analog scale enabled = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog scale color = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog scale alpha = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog scale blur = "))
	
	WLet(mKeyName(ProfileIdx()), WStr("Analog hand enabled = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog hand second enabled = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog hand second color = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog hand minute enabled = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog hand minute color = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog hand hour enabled = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog hand hour color = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog hand alpha = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog hand blur = "))
	
	WLet(mKeyName(ProfileIdx()), WStr("Analog text enabled = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog text size = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog text font = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog text bold = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog text color = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog text x = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog text y = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog text format = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog text alpha = "))
	WLet(mKeyName(ProfileIdx()), WStr("Analog text blur = "))
	
	mSetTextStart = ProfileIdx()
	WLet(mKeyName(ProfileIdx(mSetTextStart)), WStr("[Text]"))
	
	WLet(mKeyName(ProfileIdx()), WStr("Text show second = "))
	WLet(mKeyName(ProfileIdx()), WStr("Text blink colon = "))
	WLet(mKeyName(ProfileIdx()), WStr("Text shadow = "))
	
	WLet(mKeyName(ProfileIdx()), WStr("Text background enabled = "))
	WLet(mKeyName(ProfileIdx()), WStr("Text background file = "))
	WLet(mKeyName(ProfileIdx()), WStr("Text background alpha = "))
	WLet(mKeyName(ProfileIdx()), WStr("Text background blur = "))
	
	WLet(mKeyName(ProfileIdx()), WStr("Text tray enabled = "))
	WLet(mKeyName(ProfileIdx()), WStr("Text tray alpha = "))
	WLet(mKeyName(ProfileIdx()), WStr("Text tray color = "))
	
	WLet(mKeyName(ProfileIdx()), WStr("Text font = "))
	WLet(mKeyName(ProfileIdx()), WStr("Text bold = "))
	WLet(mKeyName(ProfileIdx()), WStr("Text alpha 1 = "))
	WLet(mKeyName(ProfileIdx()), WStr("Text alpha 2 = "))
	WLet(mKeyName(ProfileIdx()), WStr("Text blur = "))
	
	WLet(mKeyName(ProfileIdx()), WStr("Text border enabled = "))
	WLet(mKeyName(ProfileIdx()), WStr("Text border size = "))
	WLet(mKeyName(ProfileIdx()), WStr("Text border alpha = "))
	WLet(mKeyName(ProfileIdx()), WStr("Text border color = "))
	
	WLet(mKeyName(ProfileIdx()), WStr("Text gradient color 1 = "))
	WLet(mKeyName(ProfileIdx()), WStr("Text gradient color 2 = "))
	WLet(mKeyName(ProfileIdx()), WStr("Text color index = "))
	WLet(mKeyName(ProfileIdx()), WStr("Text gradient mode = "))
	
	mSetDayStart = ProfileIdx()
	WLet(mKeyName(ProfileIdx(mSetDayStart)), WStr("[Day]"))
	
	WLet(mKeyName(ProfileIdx()), WStr("Day Left = "))
	WLet(mKeyName(ProfileIdx()), WStr("Day Top = "))
	WLet(mKeyName(ProfileIdx()), WStr("Day Width = "))
	WLet(mKeyName(ProfileIdx()), WStr("Day Height = "))
	WLet(mKeyName(ProfileIdx()), WStr("Day text font = "))
	WLet(mKeyName(ProfileIdx()), WStr("Day text alpha = "))
	WLet(mKeyName(ProfileIdx()), WStr("Day fore color focus = "))
	WLet(mKeyName(ProfileIdx()), WStr("Day fore color year = "))
	WLet(mKeyName(ProfileIdx()), WStr("Day fore color month = "))
	WLet(mKeyName(ProfileIdx()), WStr("Day fore color day = "))
	WLet(mKeyName(ProfileIdx()), WStr("Day fore color week = "))
	WLet(mKeyName(ProfileIdx()), WStr("Day split = "))
	WLet(mKeyName(ProfileIdx()), WStr("Day style index = "))
	WLet(mKeyName(ProfileIdx()), WStr("Day tray enabled = "))
	WLet(mKeyName(ProfileIdx()), WStr("Day tray alpha = "))
	WLet(mKeyName(ProfileIdx()), WStr("Day back color focus = "))
	WLet(mKeyName(ProfileIdx()), WStr("Day back color year = "))
	WLet(mKeyName(ProfileIdx()), WStr("Day back color month = "))
	WLet(mKeyName(ProfileIdx()), WStr("Day back color day = "))
	WLet(mKeyName(ProfileIdx()), WStr("Day back color week = "))
	WLet(mKeyName(ProfileIdx()), WStr("Day background enabled = "))
	WLet(mKeyName(ProfileIdx()), WStr("Day background file = "))
	WLet(mKeyName(ProfileIdx()), WStr("Day background alpha = "))
	WLet(mKeyName(ProfileIdx()), WStr("Day background blur = "))
	
	mSetMonthStart = ProfileIdx()
	WLet(mKeyName(ProfileIdx(mSetMonthStart)), WStr("[Month]"))
	
	WLet(mKeyName(ProfileIdx()), WStr("Month Left = "))
	WLet(mKeyName(ProfileIdx()), WStr("Month Top = "))
	WLet(mKeyName(ProfileIdx()), WStr("Month Width = "))
	WLet(mKeyName(ProfileIdx()), WStr("Month Height = "))
	WLet(mKeyName(ProfileIdx()), WStr("Month controls = "))
	WLet(mKeyName(ProfileIdx()), WStr("Month weeks = "))
	WLet(mKeyName(ProfileIdx()), WStr("Month tray enabled = "))
	WLet(mKeyName(ProfileIdx()), WStr("Month tray alpha = "))
	WLet(mKeyName(ProfileIdx()), WStr("Month back color focus = "))
	WLet(mKeyName(ProfileIdx()), WStr("Month back color control = "))
	WLet(mKeyName(ProfileIdx()), WStr("Month back color week = "))
	WLet(mKeyName(ProfileIdx()), WStr("Month back color day = "))
	WLet(mKeyName(ProfileIdx()), WStr("Month text font = "))
	WLet(mKeyName(ProfileIdx()), WStr("Month text alpha = "))
	WLet(mKeyName(ProfileIdx()), WStr("Month fore color focus = "))
	WLet(mKeyName(ProfileIdx()), WStr("Month fore color control = "))
	WLet(mKeyName(ProfileIdx()), WStr("Month fore color week = "))
	WLet(mKeyName(ProfileIdx()), WStr("Month fore color day = "))
	WLet(mKeyName(ProfileIdx()), WStr("Month fore color select = "))
	WLet(mKeyName(ProfileIdx()), WStr("Month fore color today = "))
	WLet(mKeyName(ProfileIdx()), WStr("Month fore color holiday = "))
	WLet(mKeyName(ProfileIdx()), WStr("Month background enabled = "))
	WLet(mKeyName(ProfileIdx()), WStr("Month background file = "))
	WLet(mKeyName(ProfileIdx()), WStr("Month background alpha = "))
	WLet(mKeyName(ProfileIdx()), WStr("Month background blur = "))
	
	mSetSpeechStart = ProfileIdx()
	WLet(mKeyName(ProfileIdx(mSetSpeechStart)), WStr("[Speech]"))
	WLet(mKeyName(ProfileIdx()), WStr("Announce freequency = "))
	WLet(mKeyName(ProfileIdx()), WStr("Voice = "))
	WLet(mKeyName(ProfileIdx()), WStr("Audio = "))
	
	Dim i As Integer
	For i = 0 To mKeyCount
		mKeyNameLen(i) = Len(*mKeyName(i))
	Next
End Sub

Private Sub frmClockType.ProfileRelease()
	Erase mKeyNameLen
	ArrayDeallocate(mKeyName())
	ArrayDeallocate(mKeyValue())
	If mProfile Then Deallocate(mProfile)
	If mAppPath Then Deallocate(mAppPath)
End Sub

Private Sub frmClockType.ProfileFrmMain()
	ProfileIdx(mSetMainStart)
	WLet(mKeyValue(ProfileIdx()), "" & Left)
	WLet(mKeyValue(ProfileIdx()), "" & Top)
	WLet(mKeyValue(ProfileIdx()), "" & Width)
	WLet(mKeyValue(ProfileIdx()), "" & Height)
	WLet(mKeyValue(ProfileIdx()), "" & mnuAlwaysOnTop.Checked)
	WLet(mKeyValue(ProfileIdx()), "" & mnuClickThrough.Checked)
	WLet(mKeyValue(ProfileIdx()), "" & mnuAnalogEnabled.Checked)
	WLet(mKeyValue(ProfileIdx()), "" & mnuTextEnabled.Checked)
	WLet(mKeyValue(ProfileIdx()), "" & mnuDayEnabled.Checked) 'mShowDay)
	WLet(mKeyValue(ProfileIdx()), "" & mnuMonthEnabled.Checked) 'mShowMonth)
	WLet(mKeyValue(ProfileIdx()), "" & mnuTransparent.Checked) 'mTransparent)
	WLet(mKeyValue(ProfileIdx()), "" & mOpacity)
	WLet(mKeyValue(ProfileIdx()), "" & mnuLocateSticky.Checked)
	WLet(mKeyValue(ProfileIdx()), "" & mnuHide.Checked)
End Sub

Private Sub frmClockType.Profile2Main()
	ProfileIdx(mSetMainStart)
	If *mKeyValue(ProfileIdx()) = "" Then Exit Sub
	
	ProfileIdx(mSetMainStart)
	With mRectMain
		.Left = CLng(*mKeyValue(ProfileIdx()))
		.Top = CLng(*mKeyValue(ProfileIdx()))
		.Right = CLng(*mKeyValue(ProfileIdx()))
		.Bottom = CLng(*mKeyValue(ProfileIdx()))
	End With
	If mnuAlwaysOnTop.Checked <> CBool(*mKeyValue(ProfileIdx())) Then mnuMenu_Click(mnuAlwaysOnTop)
	If mnuClickThrough.Checked <> CBool(*mKeyValue(ProfileIdx())) Then mnuMenu_Click(mnuClickThrough)
	If mnuAnalogEnabled.Checked <> CBool(*mKeyValue(ProfileIdx())) Then mnuMenu_Click(mnuAnalogEnabled)
	If mnuTextEnabled.Checked <> CBool(*mKeyValue(ProfileIdx())) Then mnuMenu_Click(mnuTextEnabled)
	mShowDay = CBool(*mKeyValue(ProfileIdx()))
	mShowMonth = CBool(*mKeyValue(ProfileIdx()))
	mTransparent = CBool(*mKeyValue(ProfileIdx()))
	mOpacity = CInt(*mKeyValue(ProfileIdx()))
	If mnuLocateSticky.Checked <> CBool(*mKeyValue(ProfileIdx())) Then mnuMenu_Click(mnuLocateSticky)
	If mnuHide.Checked <> CBool(*mKeyValue(ProfileIdx())) Then mnuMenu_Click(mnuTextEnabled)
End Sub

Private Sub frmClockType.ProfileFrmSpeech()
	ProfileIdx(mSetSpeechStart)
	WLet(mKeyValue(ProfileIdx()), "" & IndexOfAnnouce)
	WLet(mKeyValue(ProfileIdx()), "" & IndexOfVoice)
	WLet(mKeyValue(ProfileIdx()), "" & IndexOfAudio)
End Sub
Private Sub frmClockType.Profile2Speech()
	ProfileIdx(mSetSpeechStart)
	IndexOfAnnouce = CInt(*mKeyValue(ProfileIdx()))
	IndexOfVoice = *mKeyValue(ProfileIdx())
	IndexOfAudio = *mKeyValue(ProfileIdx())
End Sub
Private Sub frmClockType.ProfileFrmAnalog()
	ProfileIdx(mSetAnalogStart)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mBackEnabled)
	WLet(mKeyValue(ProfileIdx()), ProfileSimple(mAnalogClock.FileName))
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mBackAlpha)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mBackBlur)
	
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mTrayEnabled)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mTrayFaceColor1)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mTrayFaceAlpha1)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mTrayFaceColor2)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mTrayFaceAlpha2)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mTrayEdgeColor1)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mTrayEdgeAlpha1)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mTrayEdgeColor2)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mTrayEdgeAlpha2)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mTrayShadowColor)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mTrayShadowAlpha)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mTrayAlpha)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mTrayBlur)
	
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mScaleEnabled)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mScaleColor)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mScaleAlpha)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mScaleBlur)
	
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mHandEnabled)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mHandSecondEnabled)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mHandSecondColor)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mHandMinuteEnabled)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mHandMinuteColor)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mHandHourEnabled)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mHandHourColor)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mHandAlpha)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mHandBlur)
	
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mTextEnabled)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mTextSize)
	WLet(mKeyValue(ProfileIdx()), *mAnalogClock.mTextFont)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mTextBold)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mTextColor)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mTextOffsetX)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mTextOffsetY)
	WLet(mKeyValue(ProfileIdx()), *mAnalogClock.mTextFormat)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mTextAlpha)
	WLet(mKeyValue(ProfileIdx()), "" & mAnalogClock.mTextBlur)
End Sub

Private Sub frmClockType.Profile2Analog()
	'ProfileIdx(mSetAnalogStart)
	'With mRectAnalog
	'	.Left = CInt(*mKeyValue(ProfileIdx()))
	'	.Top = CInt(*mKeyValue(ProfileIdx()))
	'	.Right = CInt(*mKeyValue(ProfileIdx()))
	'	.Bottom = CInt(*mKeyValue(ProfileIdx()))
	'End With
	ProfileIdx(mSetAnalogStart)
	mAnalogClock.mBackEnabled = CBool(*mKeyValue(ProfileIdx()))
	mAnalogClock.FileName = ProfileFull(*mKeyValue(ProfileIdx()))
	mAnalogClock.mBackAlpha = CSng(*mKeyValue(ProfileIdx()))
	mAnalogClock.mBackBlur = CInt(*mKeyValue(ProfileIdx()))
	
	mAnalogClock.mTrayEnabled = CBool(*mKeyValue(ProfileIdx()))
	mAnalogClock.mTrayFaceColor1 = CLng(*mKeyValue(ProfileIdx()))
	mAnalogClock.mTrayFaceAlpha1 = CLng(*mKeyValue(ProfileIdx()))
	mAnalogClock.mTrayFaceColor2 = CLng(*mKeyValue(ProfileIdx()))
	mAnalogClock.mTrayFaceAlpha2 = CLng(*mKeyValue(ProfileIdx()))
	mAnalogClock.mTrayEdgeColor1 = CLng(*mKeyValue(ProfileIdx()))
	mAnalogClock.mTrayEdgeAlpha1 = CLng(*mKeyValue(ProfileIdx()))
	mAnalogClock.mTrayEdgeColor2 = CLng(*mKeyValue(ProfileIdx()))
	mAnalogClock.mTrayEdgeAlpha2 = CLng(*mKeyValue(ProfileIdx()))
	mAnalogClock.mTrayShadowColor = CLng(*mKeyValue(ProfileIdx()))
	mAnalogClock.mTrayShadowAlpha = CLng(*mKeyValue(ProfileIdx()))
	mAnalogClock.mTrayAlpha = CInt(*mKeyValue(ProfileIdx()))
	mAnalogClock.mTrayBlur = CInt(*mKeyValue(ProfileIdx()))
	
	mAnalogClock.mScaleEnabled = CBool(*mKeyValue(ProfileIdx()))
	mAnalogClock.mScaleColor = CLng(*mKeyValue(ProfileIdx()))
	mAnalogClock.mScaleAlpha = CLng(*mKeyValue(ProfileIdx()))
	mAnalogClock.mScaleBlur = CInt(*mKeyValue(ProfileIdx()))
	
	mAnalogClock.mHandEnabled = CBool(*mKeyValue(ProfileIdx()))
	mAnalogClock.mHandSecondEnabled = CBool(*mKeyValue(ProfileIdx()))
	mAnalogClock.mHandSecondColor = CLng(*mKeyValue(ProfileIdx()))
	mAnalogClock.mHandMinuteEnabled = CBool(*mKeyValue(ProfileIdx()))
	mAnalogClock.mHandMinuteColor = CLng(*mKeyValue(ProfileIdx()))
	mAnalogClock.mHandHourEnabled = CBool(*mKeyValue(ProfileIdx()))
	mAnalogClock.mHandHourColor = CLng(*mKeyValue(ProfileIdx()))
	mAnalogClock.mHandAlpha = CInt(*mKeyValue(ProfileIdx()))
	mAnalogClock.mHandBlur = CInt(*mKeyValue(ProfileIdx()))
	
	mAnalogClock.mTextEnabled = CBool(*mKeyValue(ProfileIdx()))
	mAnalogClock.mTextSize = CSng(*mKeyValue(ProfileIdx()))
	WLet(mAnalogClock.mTextFont, *mKeyValue(ProfileIdx()))
	mAnalogClock.mTextBold = CBool(*mKeyValue(ProfileIdx()))
	mAnalogClock.mTextColor = CLng(*mKeyValue(ProfileIdx()))
	mAnalogClock.mTextOffsetX = CSng(*mKeyValue(ProfileIdx()))
	mAnalogClock.mTextOffsetY = CSng(*mKeyValue(ProfileIdx()))
	WLet(mAnalogClock.mTextFormat, *mKeyValue(ProfileIdx()))
	mAnalogClock.mTextAlpha = CInt(*mKeyValue(ProfileIdx()))
	mAnalogClock.mTextBlur = CInt(*mKeyValue(ProfileIdx()))
End Sub

Private Sub frmClockType.ProfileFrmText()
	ProfileIdx(mSetTextStart)
	WLet(mKeyValue(ProfileIdx()), "" & mTextClock.mShowSecond)
	WLet(mKeyValue(ProfileIdx()), ""& mTextClock.mBlinkColon)
	WLet(mKeyValue(ProfileIdx()), ""& mTextClock.mShadowEnabled)
	WLet(mKeyValue(ProfileIdx()), ""& mTextClock.mBackEnabled)
	WLet(mKeyValue(ProfileIdx()), ProfileSimple(mTextClock.FileName))
	WLet(mKeyValue(ProfileIdx()), ""& mTextClock.mBackAlpha)
	WLet(mKeyValue(ProfileIdx()), ""& mTextClock.mBackBlur)
	WLet(mKeyValue(ProfileIdx()), ""& mTextClock.mTrayEnabled)
	WLet(mKeyValue(ProfileIdx()), ""& mTextClock.mTrayAlpha)
	WLet(mKeyValue(ProfileIdx()), ""& mTextClock.mTrayColor)
	WLet(mKeyValue(ProfileIdx()), *mTextClock.mFontName)
	WLet(mKeyValue(ProfileIdx()), ""& mTextClock.mFontStyle)
	WLet(mKeyValue(ProfileIdx()), ""& mTextAlpha1)
	WLet(mKeyValue(ProfileIdx()), ""& mTextAlpha2)
	WLet(mKeyValue(ProfileIdx()), ""& mTextClock.mTextBlur)
	WLet(mKeyValue(ProfileIdx()), ""& mTextClock.mBorderEnabled)
	WLet(mKeyValue(ProfileIdx()), ""& mTextClock.mBorderSize)
	WLet(mKeyValue(ProfileIdx()), ""& mTextClock.mBorderAlpha)
	WLet(mKeyValue(ProfileIdx()), ""& mTextClock.mBorderColor)
	WLet(mKeyValue(ProfileIdx()), ""& mTextColor1)
	WLet(mKeyValue(ProfileIdx()), ""& mTextColor2)
	WLet(mKeyValue(ProfileIdx()), ""& IndexOfTextColor)
	WLet(mKeyValue(ProfileIdx()), "" & IndexOfGradientMode)
End Sub
Private Sub frmClockType.Profile2Text()
	ProfileIdx(mSetTextStart)
	'With mRectText
	'	.Left = CInt(*mKeyValue(ProfileIdx()))
	'	.Top = CInt(*mKeyValue(ProfileIdx()))
	'	.Right = CInt(*mKeyValue(ProfileIdx()))
	'	.Bottom = CInt(*mKeyValue(ProfileIdx()))
	'End If
	mTextClock.mShowSecond = CBool(*mKeyValue(ProfileIdx()))
	mTextClock.mBlinkColon = CBool(*mKeyValue(ProfileIdx()))
	mTextClock.mShadowEnabled = CBool(*mKeyValue(ProfileIdx()))
	mTextClock.mBackEnabled = CBool(*mKeyValue(ProfileIdx()))
	mTextClock.FileName = ProfileFull(*mKeyValue(ProfileIdx()))
	mTextClock.mBackAlpha = CSng(*mKeyValue(ProfileIdx()))
	mTextClock.mBackBlur = CInt(*mKeyValue(ProfileIdx()))
	mTextClock.mTrayEnabled = CBool(*mKeyValue(ProfileIdx()))
	mTextClock.mTrayAlpha = CInt(*mKeyValue(ProfileIdx()))
	mTextClock.mTrayColor = CLng(*mKeyValue(ProfileIdx()))
	WLet(mTextClock.mFontName, *mKeyValue(ProfileIdx()))
	mTextClock.mFontStyle = CLng(*mKeyValue(ProfileIdx()))
	mTextAlpha1 = CInt(*mKeyValue(ProfileIdx()))
	mTextAlpha2 = CInt(*mKeyValue(ProfileIdx()))
	mTextClock.mTextBlur = CInt(*mKeyValue(ProfileIdx()))
	mTextClock.mBorderEnabled = CBool(*mKeyValue(ProfileIdx()))
	mTextClock.mBorderSize = CDbl(*mKeyValue(ProfileIdx()))
	mTextClock.mBorderAlpha = CInt(*mKeyValue(ProfileIdx()))
	mTextClock.mBorderColor = CLng(*mKeyValue(ProfileIdx()))
	mTextColor1 = CLng(*mKeyValue(ProfileIdx()))
	mTextColor2 = CLng(*mKeyValue(ProfileIdx()))
	IndexOfTextColor = CInt(*mKeyValue(ProfileIdx()))
	IndexOfGradientMode = CLng(*mKeyValue(ProfileIdx()))
End Sub
Private Sub frmClockType.ProfileFrmDay()
	ProfileIdx(mSetDayStart)
	WLet(mKeyValue(ProfileIdx()), "" & frmDay.Left)
	WLet(mKeyValue(ProfileIdx()), "" & frmDay.Top)
	WLet(mKeyValue(ProfileIdx()), "" & frmDay.Width)
	WLet(mKeyValue(ProfileIdx()), "" & frmDay.Height)
	WLet(mKeyValue(ProfileIdx()), *frmDay.mDay.mFontName)
	WLet(mKeyValue(ProfileIdx()), "" & frmDay.mDay.mForeOpacity)
	WLet(mKeyValue(ProfileIdx()), "" & frmDay.mDay.mClr(1))
	WLet(mKeyValue(ProfileIdx()), "" & frmDay.mDay.mClr(3))
	WLet(mKeyValue(ProfileIdx()), "" & frmDay.mDay.mClr(5))
	WLet(mKeyValue(ProfileIdx()), "" & frmDay.mDay.mClr(7))
	WLet(mKeyValue(ProfileIdx()), "" & frmDay.mDay.mClr(9))
	WLet(mKeyValue(ProfileIdx()), "" & frmDay.mDay.mSplitXScale)
	WLet(mKeyValue(ProfileIdx()), "" & frmDay.mDay.mShowStyle)
	WLet(mKeyValue(ProfileIdx()), "" & frmDay.mDay.mTrayEnabled)
	WLet(mKeyValue(ProfileIdx()), "" & frmDay.mDay.mTrayAlpha)
	WLet(mKeyValue(ProfileIdx()), "" & frmDay.mDay.mClr(0))
	WLet(mKeyValue(ProfileIdx()), "" & frmDay.mDay.mClr(2))
	WLet(mKeyValue(ProfileIdx()), "" & frmDay.mDay.mClr(4))
	WLet(mKeyValue(ProfileIdx()), "" & frmDay.mDay.mClr(6))
	WLet(mKeyValue(ProfileIdx()), "" & frmDay.mDay.mClr(8))
	WLet(mKeyValue(ProfileIdx()), "" & frmDay.mDay.mBackEnabled)
	WLet(mKeyValue(ProfileIdx()), ProfileSimple(frmDay.mDay.mBackImage.ImageFile))
	WLet(mKeyValue(ProfileIdx()), "" & frmDay.mDay.mBackAlpha)
	WLet(mKeyValue(ProfileIdx()), "" & frmDay.mDay.mBackBlur)
End Sub
Private Sub frmClockType.Profile2Day()
	ProfileIdx(mSetDayStart)
	If *mKeyValue(ProfileIdx()) = "" Then Exit Sub
	ProfileIdx(mSetDayStart)
	With mRectDay
		.Left = CLng(*mKeyValue(ProfileIdx()))
		.Top = CLng(*mKeyValue(ProfileIdx()))
		.Right = CLng(*mKeyValue(ProfileIdx()))
		.Bottom = CLng(*mKeyValue(ProfileIdx()))
	End With
	WLet(frmDay.mDay.mFontName, *mKeyValue(ProfileIdx()))
	frmDay.mDay.mForeOpacity = CInt(*mKeyValue(ProfileIdx()))
	frmDay.mDay.mClr(1) = CLng(*mKeyValue(ProfileIdx()))
	frmDay.mDay.mClr(3) = CLng(*mKeyValue(ProfileIdx()))
	frmDay.mDay.mClr(5) = CLng(*mKeyValue(ProfileIdx()))
	frmDay.mDay.mClr(7) = CLng(*mKeyValue(ProfileIdx()))
	frmDay.mDay.mClr(9) = CLng(*mKeyValue(ProfileIdx()))
	frmDay.mDay.mSplitXScale = CSng(*mKeyValue(ProfileIdx()))
	frmDay.mDay.mShowStyle = CInt(*mKeyValue(ProfileIdx()))
	frmDay.mDay.mTrayEnabled = CBool(*mKeyValue(ProfileIdx()))
	frmDay.mDay.mTrayAlpha = CInt(*mKeyValue(ProfileIdx()))
	frmDay.mDay.mClr(0) = CLng(*mKeyValue(ProfileIdx()))
	frmDay.mDay.mClr(2) = CLng(*mKeyValue(ProfileIdx()))
	frmDay.mDay.mClr(4) = CLng(*mKeyValue(ProfileIdx()))
	frmDay.mDay.mClr(6) = CLng(*mKeyValue(ProfileIdx()))
	frmDay.mDay.mClr(8) = CLng(*mKeyValue(ProfileIdx()))
	frmDay.mDay.mBackEnabled = CBool(*mKeyValue(ProfileIdx()))
	frmDay.mDay.mBackImage.ImageFile = ProfileFull(*mKeyValue(ProfileIdx()))
	frmDay.mDay.mBackAlpha = CInt(*mKeyValue(ProfileIdx()))
	frmDay.mDay.mBackBlur = CInt(*mKeyValue(ProfileIdx()))
End Sub
Private Sub frmClockType.ProfileFrmMonth()
	ProfileIdx(mSetMonthStart)
	WLet(mKeyValue(ProfileIdx()), "" & frmMonth.Left)
	WLet(mKeyValue(ProfileIdx()), "" & frmMonth.Top)
	WLet(mKeyValue(ProfileIdx()), "" & frmMonth.Width)
	WLet(mKeyValue(ProfileIdx()), "" & frmMonth.Height)
	WLet(mKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mShowControls)
	WLet(mKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mShowWeeks)
	WLet(mKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mTrayEnabled)
	WLet(mKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mTrayAlpha)
	WLet(mKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mClr(0))
	WLet(mKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mClr(2))
	WLet(mKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mClr(4))
	WLet(mKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mClr(6))
	WLet(mKeyValue(ProfileIdx()), *frmMonth.mMonth.mFontName)
	WLet(mKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mForeOpacity)
	WLet(mKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mClr(1))
	WLet(mKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mClr(3))
	WLet(mKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mClr(5))
	WLet(mKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mClr(7))
	WLet(mKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mClr(8))
	WLet(mKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mClr(9))
	WLet(mKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mClr(10))
	WLet(mKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mBackEnabled)
	WLet(mKeyValue(ProfileIdx()), ProfileSimple(frmMonth.mMonth.mBackImage.ImageFile))
	WLet(mKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mBackAlpha)
	WLet(mKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mBackBlur)
End Sub
Private Sub frmClockType.Profile2Month()
	ProfileIdx(mSetMonthStart)
	If *mKeyValue(ProfileIdx()) = "" Then Exit Sub
	ProfileIdx(mSetMonthStart)
	With mRectMonth
		.Left = CLng(*mKeyValue(ProfileIdx()))
		.Top = CLng(*mKeyValue(ProfileIdx()))
		.Right = CLng(*mKeyValue(ProfileIdx()))
		.Bottom = CLng(*mKeyValue(ProfileIdx()))
	End With
	frmMonth.mMonth.mShowControls = CBool(*mKeyValue(ProfileIdx()))
	frmMonth.mMonth.mShowWeeks = CBool(*mKeyValue(ProfileIdx()))
	frmMonth.mMonth.mTrayEnabled = CBool(*mKeyValue(ProfileIdx()))
	frmMonth.mMonth.mTrayAlpha = CInt(*mKeyValue(ProfileIdx()))
	frmMonth.mMonth.mClr(0) = CLng(*mKeyValue(ProfileIdx()))
	frmMonth.mMonth.mClr(2) = CLng(*mKeyValue(ProfileIdx()))
	frmMonth.mMonth.mClr(4) = CLng(*mKeyValue(ProfileIdx()))
	frmMonth.mMonth.mClr(6) = CLng(*mKeyValue(ProfileIdx()))
	WLet(frmMonth.mMonth.mFontName, *mKeyValue(ProfileIdx()))
	frmMonth.mMonth.mForeOpacity = CInt(*mKeyValue(ProfileIdx()))
	frmMonth.mMonth.mClr(1) = CLng(*mKeyValue(ProfileIdx()))
	frmMonth.mMonth.mClr(3) = CLng(*mKeyValue(ProfileIdx()))
	frmMonth.mMonth.mClr(5) = CLng(*mKeyValue(ProfileIdx()))
	frmMonth.mMonth.mClr(7) = CLng(*mKeyValue(ProfileIdx()))
	frmMonth.mMonth.mClr(8) = CLng(*mKeyValue(ProfileIdx()))
	frmMonth.mMonth.mClr(9) = CLng(*mKeyValue(ProfileIdx()))
	frmMonth.mMonth.mClr(10) = CLng(*mKeyValue(ProfileIdx()))
	frmMonth.mMonth.mBackEnabled = CBool(*mKeyValue(ProfileIdx()))
	frmMonth.mMonth.mBackImage.ImageFile = ProfileFull(*mKeyValue(ProfileIdx()))
	frmMonth.mMonth.mBackAlpha = CInt(*mKeyValue(ProfileIdx()))
	frmMonth.mMonth.mBackBlur = CInt(*mKeyValue(ProfileIdx()))
End Sub

Private Function frmClockType.ProfileLoad(sFileName As WString) As Boolean
	If Dir(sFileName) = "" Then Return False
	Dim s As WString Ptr
	
	WLet(s, TextFromFile(sFileName))
	
	Dim ss() As WString Ptr
	Dim i As Integer
	Dim j As Integer = SplitWStr(*s, !"\r\n", ss())
	Dim k As Integer
	Dim l As Integer
	Dim m As Integer
	
	With mRectMain
		.Left = This.Left
		.Top = This.Top
		.Right = This.Width
		.Bottom = This.Height
	End With
	
	For i = 0 To j
		l = Len(*ss(i))
		For k = 0 To mKeyCount
			m = InStr(*ss(i), *mKeyName(k))
			If m = 6 Then
				WLet(mKeyValue(k), Mid(*ss(i), m + mKeyNameLen(k), l - mKeyNameLen(k)))
				Exit For
			End If
		Next
	Next
	
	ArrayDeallocate(ss())
	Deallocate(s)
	Return True
End Function

Private Sub frmClockType.ProfileSave(sFileName As WString)
	Dim ss() As WString Ptr
	Dim i As Integer
	ReDim ss(mKeyCount)
	
	ProfileFrmMain()
	ProfileFrmAnalog()
	ProfileFrmText()
	If frmDay.Handle Then ProfileFrmDay()
	If frmMonth.Handle Then ProfileFrmMonth()
	ProfileFrmSpeech
	
	For i = 0 To mKeyCount
		WLet(ss(i), Format(i, "000") & ". " & *mKeyName(i) & *mKeyValue(i))
	Next
	
	Dim s As WString Ptr
	JoinWStr(ss(), !"\r\n", s)
	If Dir(sFileName) <> "" Then Kill(sFileName)
	TextToFile(sFileName, *s)
	ArrayDeallocate(ss())
	Deallocate(s)
End Sub

Private Sub frmClockType.SpeechNow(sDt As Double, ByVal sLan As Integer = 0)
	Dim As WString Ptr s
	Dim m As Integer = Minute(sDt)
	Dim h As Integer = Hour(sDt)
	
	Dim s2(2) As String
	
	Select Case sLan
	Case 0
		s2(0) = "It's {hour} o'clock"
		s2(1) = "It's {hour} {minute}"
		s2(2) = "It's {hour} {minute}"
	Case 1
		s2(0) = "现在是 {hour} 点整"
		s2(1) = "现在是 {hour} 点 {minute} 分"
		s2(2) = "现在是 {hour} 点 {minute} 分"
	End Select
	
	Select Case m
	Case 0
		WLet(s, Replace(Replace(s2(0), "{hour}", "" & h), "{minute}", Format(m, "00")))
	Case 30
		WLet(s, Replace(Replace(s2(1), "{hour}", "" & h), "{minute}", Format(m, "00")))
	Case Else
		WLet(s, Replace(Replace(s2(2), "{hour}", "" & h), "{minute}", Format(m, "00")))
	End Select
	#ifdef __USE_WINAPI__
		If pSpVoice Then pSpVoice->Speak(s, SVSFlagsAsync, NULL)
	#endif
	WDeAllocate(s)
End Sub

Private Sub frmClockType.SpeechInit()
	#ifdef __USE_WINAPI__
		' // Create an instance of the SpVoice object
		Dim classID As IID, riid As IID
		CLSIDFromString(Afx_CLSID_SpVoice, @classID)
		IIDFromString(Afx_IID_ISpVoice, @riid)
		CoCreateInstance(@classID, NULL, CLSCTX_ALL, @riid, @pSpVoice)
		If pSpVoice = NULL Then Exit Sub
		
		mnuAnnounce.Enabled = True
		
		' // Set the object of interest to word boundaries
		pSpVoice->SetInterest(SPFEI(SPEI_WORD_BOUNDARY), SPFEI(SPEI_WORD_BOUNDARY))
		' // Set the handle of the window that will receive the MSG_SAPI_EVENT message
		pSpVoice->SetNotifyWindowMessage(Handle, MSG_SAPI_EVENT, 0, 0)
		
		Dim pVoice As Afx_ISpObjectToken Ptr
		Dim pAudio As Afx_ISpObjectToken Ptr
		Dim pTokenCategory As Afx_ISpObjectTokenCategory Ptr
		Dim pTokenEnum As Afx_IEnumSpObjectTokens Ptr
		
		Dim pTokenItem As Afx_ISpObjectToken Ptr
		Dim pStr As WString Ptr = CAllocate(0, 2048)
		Dim pCount As Long
		Dim i As Long
		
		pSpVoice->GetVoice(@pVoice)
		pVoice->GetCategory(@pTokenCategory)
		pTokenCategory->EnumTokens(@"", @"", @pTokenEnum)
		pTokenEnum->GetCount(@pCount)
		mVoiceCount = pCount - 1
		
		If mVoiceCount >-1 Then
			ReDim mnuVoiceSub(mVoiceCount)
			For i = 0 To mVoiceCount
				pTokenEnum->Item(i, @pTokenItem)
				pTokenItem->GetStringValue(NULL, @pStr)
				
				mnuVoiceSub(i) = New MenuItem
				mnuVoiceSub(i)->Designer = @This
				mnuVoiceSub(i)->Parent = @mnuVoice
				mnuVoiceSub(i)->Name = "mnuVoiceSub" & i
				mnuVoiceSub(i)->Caption = *pStr
				mnuVoiceSub(i)->OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
				mnuVoiceSub(i)->Tag = pTokenItem
				
				mnuVoice.Add mnuVoiceSub(i)
			Next
			mnuVoiceSub(0)->Checked = True
			mnuVoice.Enabled = True
			mnuMenu_Click(*mnuVoiceSub(0))
			
			pVoice->Release()
			pVoice = NULL
			pTokenCategory->Release()
			pTokenCategory = NULL
			pTokenEnum->Release()
			pTokenEnum = NULL
		End If
		
		pSpVoice->GetOutputObjectToken(@pAudio)
		pAudio->GetCategory(@pTokenCategory)
		pTokenCategory->EnumTokens(@"", @"", @pTokenEnum)
		pTokenEnum->GetCount(@pCount)
		mAudioCount = pCount - 1
		
		If mAudioCount >-1 Then
			ReDim mnuAudioSub(mAudioCount)
			For i = 0 To mAudioCount
				pTokenEnum->Item(i, @pTokenItem)
				pTokenItem->GetStringValue(NULL, @pStr)
				
				mnuAudioSub(i) = New MenuItem
				mnuAudioSub(i)->Designer = @This
				mnuAudioSub(i)->Parent = @mnuAudio
				mnuAudioSub(i)->Name = "mnuAudioSub" & i
				mnuAudioSub(i)->Caption = *pStr
				mnuAudioSub(i)->OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
				mnuAudioSub(i)->Tag = pTokenItem
				
				mnuAudio.Add mnuAudioSub(i)
			Next
			mnuAudioSub(0)->Checked = True
			
			pAudio->Release()
			pAudio = NULL
			pTokenCategory->Release()
			pTokenCategory = NULL
			pTokenEnum->Release()
			pTokenEnum = NULL
			
			mnuAudio.Enabled = True
		End If
	#endif
End Sub

Private Property frmClockType.IndexOfTextColor(v As Integer)
	mnuTextBlack.Checked = False
	mnuTextWhite.Checked = False
	mnuTextRed.Checked = False
	mnuTextGreen.Checked = False
	mnuTextBlue.Checked = False
	mnuTextGradient.Checked = False
	Select Case v
	Case 0
		mTextClock.TextColor(&H000000, &H000000)
		mnuTextBlack.Checked = True
	Case 1
		mTextClock.TextColor(&HFFFFFF, &HFFFFFF)
		mnuTextWhite.Checked = True
	Case 2
		mTextClock.TextColor(&HFF0000, &HFF0000)
		mnuTextRed.Checked = True
	Case 3
		mTextClock.TextColor(&H00FF00, &H00FF00)
		mnuTextGreen.Checked = True
	Case 4
		mTextClock.TextColor(&H0000FF, &H0000FF)
		mnuTextBlue.Checked = True
	Case Else
		mTextClock.TextColor(mTextColor1, mTextColor2)
		mnuTextGradient.Checked = True
	End Select
End Property
Private Property frmClockType.IndexOfTextColor() As Integer
	If mnuTextBlack.Checked Then Return 0
	If mnuTextWhite.Checked Then Return 1
	If mnuTextRed.Checked Then Return 2
	If mnuTextGreen.Checked Then Return 3
	If mnuTextBlue.Checked Then Return 4
	If mnuTextGradient.Checked Then Return 5
	Return 0
End Property

Private Property frmClockType.IndexOfLocateH(v As Integer)
	'mnuLocateLeft.Checked = False
	'mnuLocateHorizontalMiddle.Checked = False
	'mnuLocateRight.Checked = False
	'mnuLocateHorizontalAny.Checked = False
	Select Case v
	Case 0
		'mnuLocateLeft.Checked = True
		Left = 0
	Case 1
		'mnuLocateHorizontalMiddle.Checked = True
		Left = (mScreenWidth / xdpi - Width) / 2
	Case 2
		'mnuLocateRight.Checked = True
		Left = mScreenWidth / xdpi - Width
	Case Else
		'mnuLocateHorizontalAny.Checked = True
		Left = mRectMain.Left
	End Select
End Property
Private Property frmClockType.IndexOfLocateH() As Integer
	If mnuLocateLeft.Checked Then Return 0
	If mnuLocateHorizontalMiddle.Checked Then Return 1
	If mnuLocateRight.Checked Then Return 2
	If mnuLocateHorizontalAny.Checked Then Return 3
	Return 0
End Property
Private Property frmClockType.IndexOfLocateV(v As Integer)
	'mnuLocateTop.Checked = False
	'mnuLocateVerticalMiddle.Checked = False
	'mnuLocateBottom.Checked = False
	'mnuLocateVerticalAny.Checked = False
	Select Case v
	Case 0
		'mnuLocateTop.Checked = True
		Top = 0
	Case 1
		'mnuLocateVerticalMiddle.Checked = True
		Top = (mScreenHeight / ydpi - Height) / 2
	Case 2
		'mnuLocateBottom.Checked = True
		Top = mScreenHeight / ydpi - Height
	Case Else
		'mnuLocateVerticalAny.Checked = True
		Top = mRectMain.Top
	End Select
End Property
Private Property frmClockType.IndexOfLocateV() As Integer
	If mnuLocateTop.Checked Then Return 0
	If mnuLocateVerticalMiddle.Checked Then Return 1
	If mnuLocateBottom.Checked Then Return 2
	If mnuLocateVerticalAny.Checked = False = True Then Return 3
	Return 0
End Property


Private Property frmClockType.IndexOfGradientMode(v As Integer)
	mnuTextGradientMode1.Checked = False
	mnuTextGradientMode2.Checked = False
	mnuTextGradientMode3.Checked = False
	mnuTextGradientMode4.Checked = False
	
	Select Case v
	Case LinearGradientModeVertical
		mnuTextGradientMode1.Checked = True
	Case LinearGradientModeHorizontal
		mnuTextGradientMode2.Checked = True
	Case LinearGradientModeForwardDiagonal
		mnuTextGradientMode3.Checked = True
	Case Else
		mnuTextGradientMode4.Checked = True
	End Select
	mTextClock.mGradientMode = v
End Property
Private Property frmClockType.IndexOfGradientMode() As Integer
	If mnuTextGradientMode1.Checked Then Return LinearGradientModeVertical
	If mnuTextGradientMode2.Checked Then Return LinearGradientModeHorizontal
	If mnuTextGradientMode3.Checked Then Return LinearGradientModeForwardDiagonal
	If mnuTextGradientMode4.Checked Then Return LinearGradientModeBackwardDiagonal
	Return LinearGradientModeVertical
End Property

Private Property frmClockType.IndexOfAnnouce(v As Integer)
	Select Case v
	Case 0
		mnuAnnounce0.Checked = True
	Case 1
		mnuAnnounce1.Checked = True
	Case 2
		mnuAnnounce2.Checked = True
	Case Else
		mnuAnnounce3.Checked = True
	End Select
End Property
Private Property frmClockType.IndexOfAnnouce() As Integer
	If mnuAnnounce0.Checked Then Return 0
	If mnuAnnounce1.Checked Then Return 1
	If mnuAnnounce2.Checked Then Return 2
	If mnuAnnounce3.Checked Then Return 3
	Return 0
End Property

Private Property frmClockType.IndexOfVoice(ByRef v As WString)
	Dim i As Integer
	For i = 0 To mVoiceCount
		If mnuVoiceSub(i)->Caption = v Then
			mnuMenu_Click(*mnuVoiceSub(i))
			Exit Property
		End If
	Next
End Property
Private Property frmClockType.IndexOfVoice() ByRef As WString
	Dim i As Integer
	For i = 0 To mVoiceCount
		If mnuVoiceSub(i)->Checked Then
			Return mnuVoiceSub(i)->Caption
		End If
	Next
End Property
Private Property frmClockType.IndexOfAudio(ByRef v As WString)
	Dim i As Integer
	For i = 0 To mAudioCount
		If mnuAudioSub(i)->Caption = v Then
			mnuMenu_Click(*mnuAudioSub(i))
			Exit Property
		End If
	Next
End Property

Private Property frmClockType.IndexOfAudio() ByRef As WString
	Dim i As Integer
	For i = 0 To mAudioCount
		If mnuAudioSub(i)->Checked Then
			Return mnuAudioSub(i)->Caption
		End If
	Next
End Property

Private Sub frmClockType.mnuMenu_Click(ByRef Sender As MenuItem)
	Dim i As Integer
	
	Select Case Sender.Name
	Case "mnuAlwaysOnTop"
		Sender.Checked = Not Sender.Checked
		FormStyle = IIf(Sender.Checked, FormStyles.fsStayOnTop, FormStyles.fsNormal)
	Case "mnuClickThrough"
		Sender.Checked = Not Sender.Checked
		i = GetWindowLong(Handle, GWL_EXSTYLE)
		SetWindowLong(Handle, GWL_EXSTYLE, IIf(Sender.Checked, i Or WS_EX_TRANSPARENT, i Xor WS_EX_TRANSPARENT))
	Case "mnuAutoStart"
		Sender.Checked = Not Sender.Checked
		AutoStartReg Sender.Checked
		CheckAutoStart
		
	Case "mnuAnalogEnabled"
		Sender.Checked = True
		mnuTextEnabled.Checked = False
		Form_Resize(This, Width, Height)
		mnuMenu_Click(mnuAspectRatio)
	Case "mnuTextEnabled"
		Sender.Checked = True
		mnuAnalogEnabled.Checked = False
		Form_Resize(This, Width, Height)
		mnuMenu_Click(mnuAspectRatio)
	Case "mnuDayEnabled"
		Sender.Checked = Not Sender.Checked
		If Sender.Checked Then
			If mnuLocateSticky.Checked Then
				frmClock.Form_Move(frmClock)
				frmDay.Show(frmClock)
			Else
				frmDay.Move(frmClock.mRectDay.Left, frmClock.mRectDay.Top, frmClock.mRectDay.Right, frmClock.mRectDay.Bottom)
				frmDay.Show()
			End If
			App.DoEvents
			frmDay.mDay.mForceUpdate = True
			Form_Resize(This, Width, Height)
		Else
			frmDay.CloseForm()
		End If
		mnuDaySetting.Enabled = Sender.Checked
	Case "mnuMonthEnabled"
		Sender.Checked = Not Sender.Checked
		If Sender.Checked Then
			If mnuLocateSticky.Checked Then
				frmClock.Form_Move(frmClock)
				frmMonth.Show(frmClock)
			Else
				frmMonth.Move(frmClock.mRectMonth.Left, frmClock.mRectMonth.Top, frmClock.mRectMonth.Right, frmClock.mRectMonth.Bottom)
				frmMonth.Show()
			End If
			frmMonth.mMonth.mForceUpdate = True
			Form_Resize(This, Width, Height)
		Else
			frmMonth.CloseForm()
		End If
		mnuMonthSetting.Enabled = Sender.Checked
	Case "mnuAspectRatio"
		Dim w As Single
		Dim h As Single
		Dim s As Single
		If mnuTransparent.Checked Then
			h = 0
			w = 0
		Else
			w = Width - ClientWidth
			h = Height - ClientHeight
		End If
		If mnuTextEnabled.Checked Then
			If mnuTextBackEnabled.Checked Then
				s = mTextClock.mBackScale
			Else
				s = mTextClock.mTxtScale
			End If
		Else
			If mnuAnalogBackEnabled.Checked Then
				s = mAnalogClock.mBackScale
			Else
				s = 1
			End If
		End If
		Move(Left, Top, Width, h + (Width - w)*s)
	Case "mnuTransparent"
		Sender.Checked = Not Sender.Checked
		Transparent(Sender.Checked)
		If frmDay.Handle Then frmDay.Transparent(Sender.Checked)
		If frmMonth.Handle Then frmMonth.Transparent(Sender.Checked)
	Case "mnuOpacityValue"
		Dim As String s = InputBox("GDIP Clock", "Opacity", "" & mOpacity, , , Handle)
		mOpacity = CInt(s)
		mnuOpacityValue.Caption = "Opacity " & mOpacity & "..."
		If frmDay.Handle Then frmDay.Transparent(Sender.Checked)
		If frmMonth.Handle Then frmMonth.Transparent(Sender.Checked)
	Case "mnuHide"
		Sender.Checked = Not Sender.Checked
		This.Visible = Sender.Checked = False
	Case "mnuTest"
		Sender.Checked = Not Sender.Checked
		If Sender.Checked Then
			TestBackup
			TimerComponent2.Enabled = Sender.Checked
		Else
			TimerComponent2.Enabled = Sender.Checked
			TestRestore
		End If
	Case "mnuAbout"
		MsgBox(!"Visual FB Editor\r\nGDIP Clock\r\nBy Cm Wang", "GDIP Clock")
	Case "mnuExit"
		CloseForm
		
	Case "mnuLocateReset"
		If mnuLocateSticky.Checked = False Then mnuMenu_Click(mnuLocateSticky)
		IndexOfLocateH = 2
		IndexOfLocateV = 0
	Case "mnuLocateLeft"
		IndexOfLocateH = 0
	Case "mnuLocateHorizontalMiddle"
		IndexOfLocateH = 1
	Case "mnuLocateRight"
		IndexOfLocateH = 2
	Case "mnuLocateHorizontalAny"
		IndexOfLocateH = 3
		
	Case "mnuLocateTop"
		IndexOfLocateV = 0
	Case "mnuLocateVerticalMiddle"
		IndexOfLocateV = 1
	Case "mnuLocateBottom"
		IndexOfLocateV = 2
	Case "mnuLocateVerticalAny"
		IndexOfLocateV = 3
		
	Case "mnuLocateSticky"
		Sender.Checked = Not Sender.Checked
		Form_Resize(This, Width, Height)
	Case "mnuLocateLock"
		Sender.Checked = Not Sender.Checked
	Case "mnuProfileSave"
		SaveFileDialog1.FileName = *mProfile
		If SaveFileDialog1.Execute Then
			WLet(mProfile, SaveFileDialog1.FileName)
			If Dir(*mProfile)<>"" Then
				If MsgBox(*mProfile & !"\r\nAre you sure you want to overwrite it?", "The profile already exists.", , ButtonsTypes.btYesNo) <> MessageResult.mrYes Then Exit Sub
			End If
			ProfileSave(*mProfile)
			Form_Resize(This, Width, Height)
			Profile2Menu()
		End If
	Case "mnuProfileList"
		TimerComponent1.Enabled = False
		Hide()
		If frmDay.Handle Then frmDay.CloseForm
		If frmMonth.Handle Then frmMonth.CloseForm
		App.DoEvents
		WLet(mProfile, *mAppPath & Sender.Caption & ".prf")
		If ProfileLoad(*mProfile) Then
			Profile2Main()
			Profile2Analog()
			Profile2Text()
			Profile2Day()
			Profile2Month()
			Profile2Speech()
			
			mTextClock.TextAlpha(mTextAlpha1, mTextAlpha2)
			If mRectMain.Right And mRectMain.Bottom Then Move(mRectMain.Left, mRectMain.Top, mRectMain.Right, mRectMain.Bottom)
		End If
		mnuDayEnabled.Checked = Not mShowDay
		mnuMonthEnabled.Checked = Not mShowMonth
		Show()
		Profile2Menu()
		Profile2Interface()
	Case "mnuAnalogBackEnabled"
		mAnalogClock.mBackEnabled = Not mAnalogClock.mBackEnabled
		Form_Resize(This, Width, Height)
		mnuMenu_Click(mnuAspectRatio)
	Case "mnuAnalogBackFile"
		OpenFileDialog1.FileName = mAnalogClock.FileName
		
		If OpenFileDialog1.Execute Then
			mAnalogClock.FileName = OpenFileDialog1.FileName
			Form_Resize(This, Width, Height)
			mnuMenu_Click(mnuAspectRatio)
		End If
	Case "mnuAnalogSquare"
		Move(Left, Top, Width, Width)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogHandEnabled"
		mAnalogClock.mHandEnabled = Not mAnalogClock.mHandEnabled
		Form_Resize(This, Width, Height)
	Case "mnuAnalogHandSecondEnabled"
		mAnalogClock.mHandSecondEnabled = Not mAnalogClock.mHandSecondEnabled
		Form_Resize(This, Width, Height)
	Case "mnuAnalogHandMinuteEnabled"
		mAnalogClock.mHandMinuteEnabled = Not mAnalogClock.mHandMinuteEnabled
		Form_Resize(This, Width, Height)
	Case "mnuAnalogHandHourEnabled"
		mAnalogClock.mHandHourEnabled = Not mAnalogClock.mHandHourEnabled
		Form_Resize(This, Width, Height)
	Case "mnuAnalogScaleColor"
		ColorDialog1.Color = Color2Gdip(mAnalogClock.mScaleColor)
		If ColorDialog1.Execute() Then
			mAnalogClock.mScaleColor = Color2Gdip(ColorDialog1.Color)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuAnalogHandSecond"
		ColorDialog1.Color = Color2Gdip(mAnalogClock.mHandSecondColor)
		If ColorDialog1.Execute() Then
			mAnalogClock.mHandSecondColor = Color2Gdip(ColorDialog1.Color)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuAnalogHandMinute"
		ColorDialog1.Color = Color2Gdip(mAnalogClock.mHandMinuteColor)
		If ColorDialog1.Execute() Then
			mAnalogClock.mHandMinuteColor = Color2Gdip(ColorDialog1.Color)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuAnalogHandHour"
		ColorDialog1.Color = Color2Gdip(mAnalogClock.mHandHourColor)
		If ColorDialog1.Execute() Then
			mAnalogClock.mHandHourColor = Color2Gdip(ColorDialog1.Color)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuAnalogHandAlpha"
		Dim As String s = InputBox("GDIP Clock", "Analog Hand Alpha", "" & mAnalogClock.mHandAlpha, , , Handle)
		mAnalogClock.mHandAlpha = CInt(s)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogHandBlur"
		Dim As String s = InputBox("GDIP Clock", "Analog Text Blur", "" & mAnalogClock.mHandBlur, , , Handle)
		mAnalogClock.mHandBlur = CInt(s)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogTrayEnabled"
		mAnalogClock.mTrayEnabled = Not mAnalogClock.mTrayEnabled
		Form_Resize(This, Width, Height)
	Case "mnuAnalogTrayFC1"
		ColorDialog1.Color = Color2Gdip(mAnalogClock.mTrayFaceColor1)
		If ColorDialog1.Execute() Then
			mAnalogClock.mTrayFaceColor1 = Color2Gdip(ColorDialog1.Color)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuAnalogTrayFC2"
		ColorDialog1.Color = Color2Gdip(mAnalogClock.mTrayFaceColor2)
		If ColorDialog1.Execute() Then
			mAnalogClock.mTrayFaceColor2 = Color2Gdip(ColorDialog1.Color)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuAnalogTrayEC1"
		ColorDialog1.Color = Color2Gdip(mAnalogClock.mTrayEdgeColor1)
		If ColorDialog1.Execute() Then
			mAnalogClock.mTrayEdgeColor1 = Color2Gdip(ColorDialog1.Color)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuAnalogTrayEC2"
		ColorDialog1.Color = Color2Gdip(mAnalogClock.mTrayEdgeColor2)
		If ColorDialog1.Execute() Then
			mAnalogClock.mTrayEdgeColor2 = Color2Gdip(ColorDialog1.Color)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuAnalogTraySC"
		ColorDialog1.Color = Color2Gdip(mAnalogClock.mTrayShadowColor)
		If ColorDialog1.Execute() Then
			mAnalogClock.mTrayShadowColor = Color2Gdip(ColorDialog1.Color)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuAnalogTrayFA2"
		Dim As String s = InputBox("GDIP Clock", "Analog Tray Face Alpha 1", "" & mAnalogClock.mTrayFaceAlpha1, , , Handle)
		mAnalogClock.mTrayFaceAlpha1 = CSng(s)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogTrayFA2"
		Dim As String s = InputBox("GDIP Clock", "Analog Tray Face Alpha 2", "" & mAnalogClock.mTrayFaceAlpha2, , , Handle)
		mAnalogClock.mTrayFaceAlpha2 = CSng(s)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogTrayEA1"
		Dim As String s = InputBox("GDIP Clock", "Analog Tray Edge Alpha 1", "" & mAnalogClock.mTrayEdgeAlpha1, , , Handle)
		mAnalogClock.mTrayEdgeAlpha1 = CSng(s)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogTrayEA2"
		Dim As String s = InputBox("GDIP Clock", "Analog Tray Edge Alpha 2", "" & mAnalogClock.mTrayEdgeAlpha2, , , Handle)
		mAnalogClock.mTrayEdgeAlpha2 = CSng(s)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogTraySA"
		Dim As String s = InputBox("GDIP Clock", "Analog Tray Shadow Alpha", "" & mAnalogClock.mTrayShadowAlpha, , , Handle)
		mAnalogClock.mTrayShadowAlpha = CSng(s)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogScaleEnabled"
		mAnalogClock.mScaleEnabled = Not mAnalogClock.mScaleEnabled
		Form_Resize(This, Width, Height)
	Case "mnuAnalogTextEnabled"
		mAnalogClock.mTextEnabled = Not mAnalogClock.mTextEnabled
		Form_Resize(This, Width, Height)
	Case "mnuAnalogTextSize"
		Dim As String s = InputBox("GDIP Clock", "Analog Text Size", "" & mAnalogClock.mTextSize, , , Handle)
		mAnalogClock.mTextSize = CSng(s)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogTextFont"
		FontDialog1.Font.Name = *mAnalogClock.mTextFont
		'		FontDialog1.Font.Color = Color2Gdip(mAnalogClock.mTextColor)
		FontDialog1.Font.Bold =  mAnalogClock.mTextBold
		If FontDialog1.Execute Then
			WLet(mAnalogClock.mTextFont, FontDialog1.Font.Name)
			'			mAnalogClock.mTextColor = Color2Gdip(FontDialog1.Font.Color)
			mAnalogClock.mTextBold = FontDialog1.Font.Bold
			Form_Resize(This, Width, Height)
		End If
	Case "mnuAnalogTextColor"
		ColorDialog1.Color = Color2Gdip(mAnalogClock.mTextColor)
		If ColorDialog1.Execute() Then
			mAnalogClock.mTextColor = Color2Gdip(ColorDialog1.Color)
			Form_Resize(This, Width, Height)
		End If
		Form_Resize(This, Width, Height)
	Case "mnuAnalogTextX"
		Dim As String s = InputBox("GDIP Clock", "Analog Text Offset X", "" & mAnalogClock.mTextOffsetX, , , Handle)
		mAnalogClock.mTextOffsetX = CSng(s)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogTextY"
		Dim As String s = InputBox("GDIP Clock", "Analog Text Offset Y", "" & mAnalogClock.mTextOffsetY, , , Handle)
		mAnalogClock.mTextOffsetY = CSng(s)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogBackAlpha"
		Dim As String s = InputBox("GDIP Clock", "Analog Back Alpha", "" & mAnalogClock.mBackAlpha, , , Handle)
		mAnalogClock.mBackAlpha = CSng(s)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogBackBlur"
		Dim As String s = InputBox("GDIP Clock", "Analog Back Blur", "" & mAnalogClock.mBackBlur, , , Handle)
		mAnalogClock.mBackBlur = CInt(s)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogTrayAlpha"
		Dim As String s = InputBox("GDIP Clock", "Analog Tray Alpha", "" & mAnalogClock.mTrayAlpha, , , Handle)
		mAnalogClock.mTrayAlpha = CInt(s)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogTrayBlur"
		Dim As String s = InputBox("GDIP Clock", "Analog Tray Blur", "" & mAnalogClock.mTrayBlur, , , Handle)
		mAnalogClock.mTrayBlur = CInt(s)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogScaleColor"
		ColorDialog1.Color = Color2Gdip(mAnalogClock.mScaleColor)
		If ColorDialog1.Execute() Then
			mAnalogClock.mScaleColor = Color2Gdip(ColorDialog1.Color)
			Form_Resize(This, Width, Height)
		End If
		Form_Resize(This, Width, Height)
	Case "mnuAnalogScaleAlpha"
		Dim As String s = InputBox("GDIP Clock", "Analog Scale Alpha", "" & mAnalogClock.mScaleAlpha, , , Handle)
		mAnalogClock.mScaleAlpha = CInt(s)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogScaleBlur"
		Dim As String s = InputBox("GDIP Clock", "Analog Scale Blur", "" & mAnalogClock.mScaleBlur, , , Handle)
		mAnalogClock.mScaleBlur = CInt(s)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogTextFormat"
		Dim As String s = InputBox("GDIP Clock", "Analog Text Format", "" & *mAnalogClock.mTextFormat, , , Handle)
		WLet(mAnalogClock.mTextFormat, s)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogTextAlpha"
		Dim As String s = InputBox("GDIP Clock", "Analog Text Alpha", "" & mAnalogClock.mTextAlpha, , , Handle)
		mAnalogClock.mTextAlpha = CInt(s)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogTextBlur"
		Dim As String s = InputBox("GDIP Clock", "Analog Text Blur", "" & mAnalogClock.mTextBlur, , , Handle)
		mAnalogClock.mTextBlur = CInt(s)
		Form_Resize(This, Width, Height)
		
	Case "mnuTextBackEnabled"
		Sender.Checked = Not Sender.Checked
		mTextClock.mBackEnabled = Sender.Checked
		Form_Resize(This, Width, Height)
		mnuMenu_Click(mnuAspectRatio)
	Case "mnuTextBackFile"
		OpenFileDialog1.FileName = mTextClock.FileName
		If OpenFileDialog1.Execute Then
			mTextClock.FileName = OpenFileDialog1.FileName
			Form_Resize(This, Width, Height)
			mnuMenu_Click(mnuAspectRatio)
		End If
	Case "mnuTextBackAlpha"
		Dim As String s = InputBox("GDIP Clock", "Text Back Alpha", "" & mTextClock.mBackAlpha, , , Handle)
		mTextClock.mBackAlpha = CInt(s)
		Form_Resize(This, Width, Height)
	Case "mnuTextBackBlur"
		Dim As String s = InputBox("GDIP Clock", "Text Back Blur", "" & mTextClock.mBackBlur, , , Handle)
		mTextClock.mBackBlur = CInt(s)
		Form_Resize(This, Width, Height)
	Case "mnuTextFont"
		FontDialog1.Font.Name = *mTextClock.mFontName
		FontDialog1.Font.Bold = IIf(mTextClock.mFontStyle = FontStyleBold, True, False)
		If FontDialog1.Execute Then
			mTextClock.TextFont(FontDialog1.Font.Name, IIf(FontDialog1.Font.Bold, FontStyleBold, FontStyleRegular))
			mnuTextFont.Caption = *mTextClock.mFontName & ", " & mTextClock.mFontStyle & "..."
			Form_Resize(This, Width, Height)
		End If
	Case "mnuTextBlur"
		Dim As String s = InputBox("GDIP Clock", "Text Blur", "" & mTextClock.mTextBlur, , , Handle)
		mTextClock.mTextBlur = CInt(s)
		Form_Resize(This, Width, Height)
	Case "mnuTextShowSecond"
		mTextClock.mShowSecond = Not mTextClock.mShowSecond
		Form_Resize(This, Width, Height)
		mnuMenu_Click(mnuAspectRatio)
	Case "mnuTextBlinkColon"
		mTextClock.mBlinkColon = Not mTextClock.mBlinkColon
		Form_Resize(This, Width, Height)
	Case "mnuTextBorderEnabled"
		mTextClock.mBorderEnabled = Not mTextClock.mBorderEnabled
		Form_Resize(This, Width, Height)
	Case "mnuTextShadow"
		mTextClock.mShadowEnabled = Not mTextClock.mShadowEnabled
		Form_Resize(This, Width, Height)
	Case "mnuTextBlack"
		IndexOfTextColor = 0
	Case "mnuTextWhite"
		IndexOfTextColor = 1
	Case "mnuTextRed"
		IndexOfTextColor = 2
	Case "mnuTextGreen"
		IndexOfTextColor = 3
	Case "mnuTextBlue"
		IndexOfTextColor = 4
	Case "mnuTextGradient"
		IndexOfTextColor = 5
	Case "mnuTextColor1"
		If IndexOfTextColor <> 5 Then IndexOfTextColor = 5
		ColorDialog1.Color = Color2Gdip(mTextColor1)
		If ColorDialog1.Execute() Then
			mTextColor1 = Color2Gdip(ColorDialog1.Color)
			mTextClock.TextColor(mTextColor1, mTextColor2)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuTextColor2"
		If IndexOfTextColor <> 5 Then IndexOfTextColor = 5
		ColorDialog1.Color = Color2Gdip(mTextColor2)
		If ColorDialog1.Execute() Then
			mTextColor2 = Color2Gdip(ColorDialog1.Color)
			mTextClock.TextColor(mTextColor1, mTextColor2)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuTextAlpha1"
		Dim As String s = InputBox("GDIP Clock", "Text Alpha 1", "" & mTextAlpha1, , , Handle)
		mTextAlpha1 = CInt(s)
		mTextClock.TextAlpha(mTextAlpha1, mTextAlpha2)
		Form_Resize(This, Width, Height)
	Case "mnuTextAlpha2"
		Dim As String s = InputBox("GDIP Clock", "Text Alpha 2", "" & mTextAlpha2, , , Handle)
		mTextAlpha2 = CInt(s)
		mTextClock.TextAlpha(mTextAlpha1, mTextAlpha2)
		Form_Resize(This, Width, Height)
	Case "mnuTextTrayEnabled"
		mTextClock.mTrayEnabled = Not mTextClock.mTrayEnabled
		Form_Resize(This, Width, Height)
	Case "mnuTextTrayAlpha"
		Dim As String s = InputBox("GDIP Clock", "Tray Alpha", "" & mTextClock.mTrayAlpha, , , Handle)
		mTextClock.mTrayAlpha = CInt(s)
		Form_Resize(This, Width, Height)
	Case "mnuTextTrayColor"
		ColorDialog1.Color = Color2Gdip(mTextClock.mTrayColor)
		If ColorDialog1.Execute() Then
			mTextClock.mTrayColor = Color2Gdip(ColorDialog1.Color)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuTextBorderAlpha"
		Dim As String s = InputBox("GDIP Clock", "Border Alpha", "" & mTextClock.mBorderAlpha, , , Handle)
		mTextClock.mBorderAlpha = CInt(s)
		Form_Resize(This, Width, Height)
	Case "mnuTextBorderSize"
		Dim As String s = InputBox("GDIP Clock", "Border Size", "" & mTextClock.mBorderSize, , , Handle)
		mTextClock.mBorderSize = CDbl(s)
		Form_Resize(This, Width, Height)
	Case "mnuTextBorderColor"
		ColorDialog1.Color = Color2Gdip(mTextClock.mBorderColor)
		If ColorDialog1.Execute() Then
			mTextClock.mBorderColor = Color2Gdip(ColorDialog1.Color)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuTextGradientMode1"
		IndexOfGradientMode = LinearGradientModeVertical
	Case "mnuTextGradientMode2"
		IndexOfGradientMode = LinearGradientModeHorizontal
	Case "mnuTextGradientMode3"
		IndexOfGradientMode = LinearGradientModeForwardDiagonal
	Case "mnuTextGradientMode4"
		IndexOfGradientMode = LinearGradientModeBackwardDiagonal
		
	Case "mnuDaySplit"
		Dim As String s = InputBox("GDIP Clock", "Day Split", "" & frmDay.mDay.mSplitXScale, , , Handle)
		frmDay.mDay.mSplitXScale = CSng(s)
		frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
	Case "mnuDayStyle0"
		mnuDayStyle0.Checked = True
		mnuDayStyle1.Checked = False
		mnuDayStyle2.Checked = False
		frmDay.mDay.mShowStyle = 0
		frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
	Case "mnuDayStyle1"
		mnuDayStyle0.Checked = False
		mnuDayStyle1.Checked = True
		mnuDayStyle2.Checked = False
		frmDay.mDay.mShowStyle = 1
		frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
	Case "mnuDayStyle2"
		mnuDayStyle0.Checked = False
		mnuDayStyle1.Checked = False
		mnuDayStyle2.Checked = True
		frmDay.mDay.mShowStyle = 2
		frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
	Case "mnuDayTextFont"
		FontDialog1.Font.Name = *frmDay.mDay.mFontName
		If FontDialog1.Execute Then
			WLet(frmDay.mDay.mFontName, FontDialog1.Font.Name)
			frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
		End If
	Case "mnuDayTextAlpha"
		Dim As String s = InputBox("GDIP Clock", "Day Text Alpha", "" & frmDay.mDay.mForeOpacity, , , Handle)
		frmDay.mDay.mForeOpacity = CInt(s)
		frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
	Case "mnuDayFCFocus"
		ColorDialog1.Color = Color2Gdip(frmDay.mDay.mClr(1))
		If ColorDialog1.Execute() Then
			frmDay.mDay.mClr(1) = Color2Gdip(ColorDialog1.Color)
			frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
		End If
	Case "mnuDayFCYear"
		ColorDialog1.Color = Color2Gdip(frmDay.mDay.mClr(3))
		If ColorDialog1.Execute() Then
			frmDay.mDay.mClr(3) = Color2Gdip(ColorDialog1.Color)
			frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
		End If
	Case "mnuDayFCMonth"
		ColorDialog1.Color = Color2Gdip(frmDay.mDay.mClr(5))
		If ColorDialog1.Execute() Then
			frmDay.mDay.mClr(5) = Color2Gdip(ColorDialog1.Color)
			frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
		End If
	Case "mnuDayFCDay"
		ColorDialog1.Color = Color2Gdip(frmDay.mDay.mClr(7))
		If ColorDialog1.Execute() Then
			frmDay.mDay.mClr(7) = Color2Gdip(ColorDialog1.Color)
			frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
		End If
	Case "mnuDayFCWeek"
		ColorDialog1.Color = Color2Gdip(frmDay.mDay.mClr(9))
		If ColorDialog1.Execute() Then
			frmDay.mDay.mClr(9) = Color2Gdip(ColorDialog1.Color)
			frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
		End If
	Case "mnuDayTrayEnabled"
		frmDay.mDay.mTrayEnabled = Not frmDay.mDay.mTrayEnabled
		frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
	Case "mnuDayTrayAlpha"
		Dim As String s = InputBox("GDIP Clock", "Day Tray Alpha", "" & frmDay.mDay.mTrayAlpha, , , Handle)
		frmDay.mDay.mTrayAlpha = CInt(s)
		frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
	Case "mnuDayBCFocus"
		ColorDialog1.Color = Color2Gdip(frmDay.mDay.mClr(0))
		If ColorDialog1.Execute() Then
			frmDay.mDay.mClr(0) = Color2Gdip(ColorDialog1.Color)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuDayBCYear"
		ColorDialog1.Color = Color2Gdip(frmDay.mDay.mClr(2))
		If ColorDialog1.Execute() Then
			frmDay.mDay.mClr(2) = Color2Gdip(ColorDialog1.Color)
			frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
		End If
	Case "mnuDayBCMonth"
		ColorDialog1.Color = Color2Gdip(frmDay.mDay.mClr(4))
		If ColorDialog1.Execute() Then
			frmDay.mDay.mClr(4) = Color2Gdip(ColorDialog1.Color)
			frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
		End If
	Case "mnuDayBCDay"
		ColorDialog1.Color = Color2Gdip(frmDay.mDay.mClr(6))
		If ColorDialog1.Execute() Then
			frmDay.mDay.mClr(6) = Color2Gdip(ColorDialog1.Color)
			frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
		End If
	Case "mnuDayBCWeek"
		ColorDialog1.Color = Color2Gdip(frmDay.mDay.mClr(8))
		If ColorDialog1.Execute() Then
			frmDay.mDay.mClr(8) = Color2Gdip(ColorDialog1.Color)
			frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
		End If
	Case "mnuDayBackEnabled"
		frmDay.mDay.mBackEnabled = Not frmDay.mDay.mBackEnabled
		frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
	Case "mnuDayBackFile"
		'OpenFileDialog1.FileName = frmDay.mDay.mBackImage.ImageFile
		If OpenFileDialog1.Execute Then
			frmDay.mDay.mBackImage.ImageFile = OpenFileDialog1.FileName
			frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
		End If
	Case "mnuDayBackAlpha"
		Dim As String s = InputBox("GDIP Clock", "Day Back Alpha", "" & frmDay.mDay.mBackAlpha, , , Handle)
		frmDay.mDay.mBackAlpha = CInt(s)
		frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
	Case "mnuDayBackBlur"
		Dim As String s = InputBox("GDIP Clock", "Day Back Blur", "" & frmDay.mDay.mBackBlur, , , Handle)
		frmDay.mDay.mBackBlur = CInt(s)
		frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
		
	Case "mnuMonthControls"
		frmMonth.mMonth.mShowControls = Not frmMonth.mMonth.mShowControls
		frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
	Case "mnuMonthWeeks"
		frmMonth.mMonth.mShowWeeks = Not frmMonth.mMonth.mShowWeeks
		frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
	Case "mnuMonthTextFont"
		FontDialog1.Font.Name = *frmMonth.mMonth.mFontName
		If FontDialog1.Execute Then
			WLet(frmMonth.mMonth.mFontName, FontDialog1.Font.Name)
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		End If
	Case "mnuMonthTextAlpha"
		Dim As String s = InputBox("GDIP Clock", "Month Text Alpha", "" & frmMonth.mMonth.mForeOpacity, , , Handle)
		frmMonth.mMonth.mForeOpacity = CInt(s)
		frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
	Case "mnuMonthFCFocus"
		ColorDialog1.Color = Color2Gdip(frmMonth.mMonth.mClr(1))
		If ColorDialog1.Execute() Then
			frmMonth.mMonth.mClr(1) = Color2Gdip(ColorDialog1.Color)
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		End If
	Case "mnuMonthFCControl"
		ColorDialog1.Color = Color2Gdip(frmMonth.mMonth.mClr(3))
		If ColorDialog1.Execute() Then
			frmMonth.mMonth.mClr(3) = Color2Gdip(ColorDialog1.Color)
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		End If
	Case "mnuMonthFCWeek"
		ColorDialog1.Color = Color2Gdip(frmMonth.mMonth.mClr(5))
		If ColorDialog1.Execute() Then
			frmMonth.mMonth.mClr(5) = Color2Gdip(ColorDialog1.Color)
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		End If
	Case "mnuMonthFCDay"
		ColorDialog1.Color = Color2Gdip(frmMonth.mMonth.mClr(7))
		If ColorDialog1.Execute() Then
			frmMonth.mMonth.mClr(7) = Color2Gdip(ColorDialog1.Color)
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		End If
	Case "mnuMonthFCSelect"
		ColorDialog1.Color = Color2Gdip(frmMonth.mMonth.mClr(8))
		If ColorDialog1.Execute() Then
			frmMonth.mMonth.mClr(8) = Color2Gdip(ColorDialog1.Color)
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		End If
	Case "mnuMonthFCToday"
		ColorDialog1.Color = Color2Gdip(frmMonth.mMonth.mClr(9))
		If ColorDialog1.Execute() Then
			frmMonth.mMonth.mClr(9) = Color2Gdip(ColorDialog1.Color)
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		End If
	Case "mnuMonthFCHoliday"
		ColorDialog1.Color = Color2Gdip(frmMonth.mMonth.mClr(10))
		If ColorDialog1.Execute() Then
			frmMonth.mMonth.mClr(10) = Color2Gdip(ColorDialog1.Color)
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		End If
	Case "mnuMonthTrayEnabled"
		frmMonth.mMonth.mTrayEnabled = Not frmMonth.mMonth.mTrayEnabled
		frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
	Case "mnuMonthTrayAlpha"
		Dim As String s = InputBox("GDIP Clock", "Month Tray Alpha", "" & frmMonth.mMonth.mTrayAlpha, , , Handle)
		frmMonth.mMonth.mTrayAlpha = CInt(s)
		frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
	Case "mnuMonthBCFocus"
		ColorDialog1.Color = Color2Gdip(frmMonth.mMonth.mClr(0))
		If ColorDialog1.Execute() Then
			frmMonth.mMonth.mClr(0) = Color2Gdip(ColorDialog1.Color)
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		End If
	Case "mnuMonthBCControl"
		ColorDialog1.Color = Color2Gdip(frmMonth.mMonth.mClr(2))
		If ColorDialog1.Execute() Then
			frmMonth.mMonth.mClr(2) = Color2Gdip(ColorDialog1.Color)
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		End If
	Case "mnuMonthBCWeek"
		ColorDialog1.Color = Color2Gdip(frmMonth.mMonth.mClr(4))
		If ColorDialog1.Execute() Then
			frmMonth.mMonth.mClr(4) = Color2Gdip(ColorDialog1.Color)
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		End If
	Case "mnuMonthBCDay"
		ColorDialog1.Color = Color2Gdip(frmMonth.mMonth.mClr(6))
		If ColorDialog1.Execute() Then
			frmMonth.mMonth.mClr(6) = Color2Gdip(ColorDialog1.Color)
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		End If
	Case "mnuMonthBackEnabled"
		frmMonth.mMonth.mBackEnabled = Not frmMonth.mMonth.mBackEnabled
		frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
	Case "mnuMonthBackFile"
		'OpenFileDialog1.FileName = frmMonth.mMonth.mBackImage.ImageFile
		If OpenFileDialog1.Execute Then
			frmMonth.mMonth.mBackImage.ImageFile = OpenFileDialog1.FileName
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		End If
	Case "mnuMonthBackAlpha"
		Dim As String s = InputBox("GDIP Clock", "Month Back Alpha", "" & frmMonth.mMonth.mBackAlpha, , , Handle)
		frmMonth.mMonth.mBackAlpha = CInt(s)
		frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
	Case "mnuMonthBackBlur"
		Dim As String s = InputBox("GDIP Clock", "Month Back Blur", "" & frmMonth.mMonth.mBackBlur, , , Handle)
		frmMonth.mMonth.mBackBlur = CInt(s)
		frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		
	Case "mnuAnnounce0"
		IndexOfAnnouce = 0
	Case "mnuAnnounce1"
		IndexOfAnnouce = 1
	Case "mnuAnnounce2"
		IndexOfAnnouce = 2
	Case "mnuAnnounce3"
		IndexOfAnnouce = 3
	Case "mnuSpeechNow"
		SpeechNow(Now(), mLanguage)
		
	Case Else 'Speech Voice & Audio
		Dim i As Integer
		Sender.Checked = True
		
		If InStr(Sender.Name, "mnuVoice") Then
			If InStr(Sender.Caption, "English") Then mLanguage = 0
			If InStr(Sender.Caption, "Chinese") Then mLanguage = 1
			For i = 0 To mVoiceCount
				If @Sender = mnuVoiceSub(i) Then
					#ifdef __USE_WINAPI__
						If pSpVoice Then pSpVoice->SetVoice(Cast(Afx_ISpObjectToken Ptr, Sender.Tag))
					#endif
				Else
					mnuVoiceSub(i)->Checked = False
				End If
			Next
		End If
		If InStr(Sender.Name, "mnuAudio") Then
			For i = 0 To mAudioCount
				If @Sender = mnuAudioSub(i) Then
					#ifdef __USE_WINAPI__
						If pSpVoice Then pSpVoice->SetOutput(Cast(Afx_ISpObjectToken Ptr, Sender.Tag), True)
					#endif
				Else
					mnuAudioSub(i)->Checked = False
				End If
			Next
		End If
	End Select
End Sub

Private Sub frmClockType.Form_Create(ByRef Sender As Control)
	'CoInitialize(NULL)
	
	SetWindowLong(Handle, GWL_STYLE, GetWindowLong(Handle, GWL_STYLE) And Not WS_CAPTION)
	SetWindowPos(Handle, NULL, 0, 0, 0, 0, SWP_NOSIZE Or SWP_NOMOVE Or SWP_NOZORDER Or SWP_FRAMECHANGED)
	
	ProfileInitial()
	SpeechInit()
	
	ScreenInfo(mScreenWidth, mScreenHeight)
	
	'If mVoiceCount > -1 And mAudioCount > -1 Then mnuSpeechNow.Enabled = True
	
	If CheckAutoStart() Then mnuAutoStart.Checked = True
	
	If mnuAnalogEnabled.Checked Then
		mAnalogClock.Background(ClientWidth, ClientHeight)
		frmTrans.Create(Handle, mAnalogClock.ImageUpdate())
	Else
		If mnuTextEnabled.Checked Then
			mTextClock.Background(ClientWidth, ClientHeight)
			frmTrans.Create(Handle, mTextClock.ImageUpdate())
		Else
			mnuMenu_Click(mnuTextEnabled)
		End If
	End If
	mnuMenu_Click(mnuAspectRatio)
	
	With SystrayIcon
		.cbSize = SizeOf(SystrayIcon)
		.hWnd = Handle
		.uID = This.ID
		.uFlags = NIF_ICON Or NIF_TIP Or NIF_MESSAGE
		.szTip = !"VisualFBEditor\r\nGDIP Clock\r\nBy Cm Wang\0"
		.uCallbackMessage = WM_SHELLNOTIFY
		.hIcon = This.Icon.Handle
		.uVersion = NOTIFYICON_VERSION
	End With
	Shell_NotifyIcon(NIM_ADD, @SystrayIcon)
	
	With SystrayIcon
		.uFlags =  NIF_INFO
		.szInfo = !"\0"
		.szInfoTitle = !"\0"
	End With
	Shell_NotifyIcon(NIM_MODIFY, @SystrayIcon)
	
	With SystrayIcon
		.uFlags =  NIF_INFO
		.szInfo = !"GDIP Clock\0"
		.szInfoTitle = !"VisualFBEditor\0"
		.uTimeout = 1
		.dwInfoFlags = 1
	End With
	Shell_NotifyIcon(NIM_MODIFY, @SystrayIcon)
	
	WLet(mProfile,ProfileDefLoad())
	If ProfileLoad(*mProfile) Then
		Profile2Main()
		Profile2Analog()
		Profile2Text()
		Profile2Day()
		Profile2Month()
		Profile2Speech()
	End If
	Profile2Menu()
	Profile2Interface()
	
	mTextClock.TextAlpha(mTextAlpha1, mTextAlpha2)
	If mRectMain.Right And mRectMain.Bottom Then Move(mRectMain.Left, mRectMain.Top, mRectMain.Right, mRectMain.Bottom)
End Sub

Private Sub frmClockType.Form_Show(ByRef Sender As Form)
	If mnuDayEnabled.Checked <> mShowDay Then mnuMenu_Click(mnuDayEnabled)
	If mnuMonthEnabled.Checked <> mShowMonth Then mnuMenu_Click(mnuMonthEnabled)
	If mnuTransparent.Checked <> mTransparent Then mnuMenu_Click(mnuTransparent)
	
	TimerComponent1.Enabled = True
End Sub

Private Sub frmClockType.Transparent(v As Boolean)
	frmTrans.Enabled = v
	Form_Resize(This, Width, Height)
End Sub

Private Sub frmClockType.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	If mnuTransparent.Checked Then
		If mnuTextEnabled.Checked Then
			mTextClock.Background(Width*xdpi, Height*ydpi)
		Else
			mAnalogClock.Background(Width*xdpi, Height*ydpi)
		End If
	Else
		If mnuTextEnabled.Checked Then
			mTextClock.Background(ClientWidth*xdpi, ClientHeight*ydpi)
		Else
			mAnalogClock.Background(ClientWidth*xdpi, ClientHeight*ydpi)
		End If
	End If
	PaintClock()
	Profile2Interface()
	If mnuLocateSticky.Checked Then Form_Move(This)
End Sub

Private Sub frmClockType.PaintClock()
	If mnuTransparent.Checked Then
		If mnuAnalogEnabled.Checked Then frmTrans.Create(Handle, mAnalogClock.ImageUpdate())
		If mnuTextEnabled.Checked Then frmTrans.Create(Handle, mTextClock.ImageUpdate())
		frmTrans.Transform(mOpacity)
	Else
		frmDC.Initial(Handle)
		memDC.Initial(0, ClientWidth*xdpi, ClientHeight*ydpi)
		frmGraphic.Initial(memDC.DC, True)
		If mnuAnalogEnabled.Checked Then frmGraphic.DrawImage(mAnalogClock.ImageUpdate())
		If mnuTextEnabled.Checked Then frmGraphic.DrawImage(mTextClock.ImageUpdate())
		BitBlt(frmDC.DC, 0, 0, ClientWidth*xdpi, ClientHeight*ydpi, memDC.DC, 0, 0, SRCCOPY)
	End If
End Sub

Private Sub frmClockType.Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	PaintClock()
End Sub

Private Sub frmClockType.Form_Message(ByRef Sender As Control, ByRef Msg As Message)
	Select Case Msg.Msg
	Case WM_SHELLNOTIFY
		Select Case Msg.lParam
		Case WM_LBUTTONDBLCLK
			mnuMenu_Click(mnuHide)
		Case WM_RBUTTONDOWN
			Dim tPOINT As Point
			GetCursorPos(@tPOINT)
			SetForegroundWindow(Handle)
			PopupMenu1.Popup(tPOINT.X, tPOINT.Y)
		End Select
	End Select
End Sub

Private Sub frmClockType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	If mnuTest.Checked Then
		mnuMenu_Click(mnuTest)
		App.DoEvents
	End If
	
	ProfileDefSave()
	ProfileSave(*mProfile)
	ProfileRelease()
	
	Shell_NotifyIcon(NIM_DELETE, @SystrayIcon)
End Sub

Private Sub frmClockType.Form_Move(ByRef Sender As Control)
	If mnuLocateSticky.Checked = False Then Exit Sub
	Dim sDayHight As Single
	Dim sMonthHight As Single
	
	sDayHight = Width / Height * 0.6
	sMonthHight = Width / Height * 0.8
	
	If frmDay.Handle Then
		frmDay.Move(Left, Top + Height, Width, Height * sDayHight)
		If frmMonth.Handle Then frmMonth.Move(Left, Top + Height * (1 + sDayHight), Width, Height * sMonthHight)
	Else
		If frmMonth.Handle Then frmMonth.Move(Left, Top + Height, Width, Height * sMonthHight)
	End If
End Sub

Private Sub frmClockType.TimerComponent1_Timer(ByRef Sender As TimerComponent)
	PaintClock()
	
	Static sNow As Double
	Dim dNow As Double = Now()
	
	If sNow = dNow Then Exit Sub
	sNow = dNow
	If mnuAnnounce0.Checked Then Exit Sub
	If Second(dNow) <> 0 Then Exit Sub
	Dim m As Integer = Minute(dNow)
	Dim h As Integer = Hour(dNow)
	If mnuAnnounce1.Checked Then
		If m = 0 Then SpeechNow(dNow, mLanguage)
	End If
	If mnuAnnounce2.Checked Then
		If m = 0 Or m = 30 Then SpeechNow(dNow, mLanguage)
	End If
	If mnuAnnounce3.Checked Then
		If m = 0 Or m = 15 Or m = 30 Or m = 45 Then SpeechNow(dNow, mLanguage)
	End If
End Sub

Private Sub frmClockType.TimerComponent2_Timer(ByRef Sender As TimerComponent)
	TestStress()
End Sub

Private Sub frmClockType.Form_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	Static sX As Integer
	Static sY As Integer
	If CBool(sX = x) And CBool(sY = y) Then Exit Sub
	sX = x
	sY = y
	
	If MouseButton = 0 Then
		ReleaseCapture()
		SendMessage(Sender.Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0)
	End If
End Sub

