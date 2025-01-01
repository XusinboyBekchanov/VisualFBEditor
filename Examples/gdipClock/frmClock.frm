' frmClock时钟
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "gdipClock.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	
	'#define MEMCHECK 1
	'#include "mff/FBMemCheck.bi"

	#include once "mff/Form.bi"
	#include once "mff/TimerComponent.bi"
	#include once "mff/Menus.bi"
	#include once "mff/Dialogs.bi"
	#include once "mff/ComboBoxEdit.bi"
	
	#include once "gdip.bi"
	#include once "gdipAnalogClock.bi"
	#include once "gdipDay.bi"
	#include once "gdipMonth.bi"
	#include once "gdipTextClock.bi"
	
	#include once "../Sapi/Speech.bi"
	#include once "../MDINotepad/Text.bi"
	#include once "../Midi/midi.bi"
	
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
		
		'Stress test for clock
		TestSetting(Any) As Boolean
		TestMenu(Any) As MenuItem Ptr
		TestCount As Integer = 39
		Declare Sub TestBackup()
		Declare Sub TestRestore()
		Declare Sub TestStress()
		
		'Speech
		Declare Sub SpeechInit()
		Declare Sub SpeechNow(sDt As Double, ByVal sLan As Integer = 0)
		mAudioCount As Integer = -1
		mLanguage As Integer = 0
		mnuAudioSub(Any) As MenuItem Ptr
		mnuVoiceSub(Any) As MenuItem Ptr
		mVoiceCount As Integer = -1
		pSpVoice As ISpVoice Ptr
		
		'midi
		mMidiID As UINT = -1
		mMidiOut As HMIDIOUT
		
		'Profile
		mRectAnalog As Rect
		mRectDay As Rect
		mRectMain As Rect
		mRectMonth As Rect
		mRectText As Rect
		
		mSetAnalogStart As Integer
		mSetDayStart As Integer
		mSetMainStart As Integer
		mSetMonthStart As Integer
		mSetSpeechStart As Integer
		mSetTextStart As Integer
		
		mAppPath As WString Ptr
		mKeyCount As Integer = 165
		mKeyName(Any) As WString Ptr
		mKeyNameLen(Any) As Integer
		mKeyValDef(Any) As WString Ptr
		mKeyValue(Any) As WString Ptr
		mnuProfileCount As Integer = -1
		mnuProfileList(Any) As MenuItem Ptr
		mProfileName As WString Ptr
		mProfileExt As WString Ptr = @WStr(".prf")
		Declare Function ProfileDefLoad() As UString  '获得默认Profile
		Declare Function ProfileIdx(ByVal fDefNum As Integer = -1) As Integer   '索引+1
		Declare Function ProfileLoad(sFileName As WString, sKeyValue() As WString Ptr) As Boolean   '加载Profile
		Declare Sub Clock2Interface()   '将时钟参数显示在界面上
		Declare Sub FileName2Menu(sExt As WString)  '将file名显示在Menu中
		Declare Sub Profile2Clock(sKeyValue() As WString Ptr)   '将Profile应用于时钟
		Declare Sub ProfileDefSave()    '存入默认Profile
		Declare Sub ProfileFrmClock(sKeyValue() As WString Ptr)     '从时钟中获得参数
		Declare Sub ProfileInitial()    '初始化Profile
		Declare Sub ProfileRelease()    '释放Profile资源
		Declare Sub ProfileSave(sFileName As WString, sKeyValue() As WString Ptr)   '存储Profile
		
		Declare Sub Notify(Title As WString, Info As WString)
		
		'Clock
		mLocateHorizontal As Integer
		mLocateVertical As Integer
		mOpacity As UINT = &HFF
		
		mScreenHeight As Integer
		mScreenWidth As Integer
		mShowDay As Boolean
		mShowMonth As Boolean
		mTextAlpha1 As ARGB = &HFF
		mTextAlpha2 As ARGB = &HFF
		mTextColor1 As ARGB = &HFF00FF
		mTextColor2 As ARGB = &H00FFFF
		mTransparent As Boolean
		Declare Sub Transparent(v As Boolean)
		Declare Sub PaintClock()
		Declare Property IndexOfAnnouce() As Integer
		Declare Property IndexOfAnnouce(v As Integer)
		Declare Property IndexOfAudio() ByRef As WString
		Declare Property IndexOfAudio(ByRef v As WString)
		Declare Property IndexOfGradientMode() As Integer
		Declare Property IndexOfGradientMode(v As Integer)
		Declare Property IndexOfLocateH() As Integer
		Declare Property IndexOfLocateH(v As Integer)
		Declare Property IndexOfLocateV() As Integer
		Declare Property IndexOfLocateV(v As Integer)
		Declare Property IndexOfTextColor() As Integer
		Declare Property IndexOfTextColor(v As Integer)
		Declare Property IndexOfVoice() ByRef As WString
		Declare Property IndexOfVoice(ByRef v As WString)
		
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
		Declare Sub Form_Click(ByRef Sender As Control)
		Declare Sub Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
		Declare Constructor
		Dim As TimerComponent TimerComponent1, TimerComponent2
		Dim As OpenFileDialog OpenFileDialog1
		Dim As SaveFileDialog SaveFileDialog1
		Dim As FontDialog FontDialog1
		Dim As ColorDialog ColorDialog1
		Dim As PopupMenu PopupMenu1
		Dim As MenuItem mnuAnalogEnabled, mnuAnalogSetting, mnuAnalogBackFile, mnuAnalogTrayEnabled, mnuAnalogScaleEnabled, mnuBar2, mnuTextEnabled, mnuTextSetting, mnuTextShadow, mnuTextBlack, mnuTextRed, mnuTextGreen, mnuTextGradient, mnuTextShowSecond, mnuTextBlinkColon, MenuItem10, mnuAnalogTextEnabled, mnuAnalogHandEnabled, mnuTextWhite, mnuTextBlue, MenuItem2, mnuTextBackEnabled, MenuItem3, mnuBar3, mnuExit, mnuBar6, mnuTransparent, mnuAnalogSquare, mnuTextBorderEnabled, MenuItem9, mnuAbout, mnuBar5, mnuTextPanelEnabled, mnuBar4, mnuSpeechNow, mnuAnnounce, mnuBar1, mnuAutoStart, mnuClickThrough, mnuAlwaysOnTop, mnuVoice, mnuAudio, MenuItem13, mnuAnnounce1, mnuAnnounce3, mnuAnnounce2, mnuAnnounce0, mnuHide, mnuAnalogBackEnabled, mnuTextBackFile, mnuAnalogTextFont, MenuItem11, mnuTextFont, MenuItem12, mnuTextBorderColor, mnuTextColor1, MenuItem16, mnuTextColor2, mnuTextDirection, mnuTextPanelColor, MenuItem20, mnuTextGradientMode1, mnuTextGradientMode2, mnuTextGradientMode3, mnuTextGradientMode4, mnuTextPanelAlpha, mnuTextBorderSize, mnuTextBorderAlpha, MenuItem1, mnuAnalogBackBlur, mnuAnalogBackAlpha, mnuAnalogTextAlpha, mnuAnalogTextBlur
		Dim As MenuItem MenuItem4, MenuItem5, mnuAnalogTrayBlur, mnuAnalogTrayAlpha, mnuAnalogScaleBlur, mnuAnalogScaleAlpha, mnuAnalogHandBlur, mnuAnalogHandAlpha, mnuAnalogTextFormat, mnuOpacityValue, mnuAnalogScaleColor, mnuAnalogHandMinute, mnuAnalogHandSecond, mnuAnalogHandHour, mnuProfileMain, MenuItem7, mnuProfileSaveAs, mnuTextBackAlpha, mnuTextBackBlur, mnuTextAlpha1, mnuTextBlur, mnuTest, mnuMonthEnabled, mnuDayEnabled, mnuTextAlpha2, mnuLocate, MenuItem6, mnuLocateReset, mnuLocateRight, mnuLocateLeft, mnuLocateHorizontalMiddle, MenuItem8, MenuItem15, mnuLocateTop, mnuLocateVerticalMiddle, mnuLocateBottom, mnuAspectRatio, MenuItem14, MenuItem17, mnuDaySetting, mnuMonthSetting, mnuDayTextFont, MenuItem21, mnuDaySplit, MenuItem23, mnuDayStyle0, mnuDayStyle1, mnuDayStyle2, MenuItem27, mnuDayBackEnabled, mnuDayBackFile, mnuDayBackAlpha, mnuDayBackBlur, MenuItem32, mnuDayTrayEnabled, mnuMonthControl
		Dim As MenuItem mnuMonthWeek, MenuItem22, mnuMonthTrayEnabled, MenuItem26, mnuMonthTextFont, MenuItem30, mnuMonthBackEnabled, mnuMonthBackFile, mnuMonthBackAlpha, mnuMonthBackBlur, mnuAnalogHandSecondEnabled, mnuAnalogHandMinuteEnabled, mnuAnalogHandHourEnabled, mnuAnalogTrayFC1, mnuAnalogTrayFC2, mnuAnalogTrayFA1, mnuAnalogTrayFA2, mnuAnalogTrayEC1, mnuAnalogTrayEC2, mnuAnalogTrayEA2, mnuAnalogTrayEA1, mnuAnalogTraySC, mnuAnalogTraySA, mnuAnalogTextColor, mnuAnalogTextX, mnuAnalogTextY, mnuAnalogTraySetting, mnuAnalogHandSetting, mnuAnalogTextSetting, mnuAnalogTextSize, mnuDayFCWeek, mnuDayFCFocus, mnuDayFCYear, mnuDayFCMonth, mnuDayFCDay, mnuDayBCWeek, mnuDayBCFocus, mnuDayBCYear, mnuDayBCMonth, mnuDayBCDay, mnuMonthFCFocus, mnuMonthFCControl, mnuMonthFCWeek, mnuMonthFCDay, mnuMonthFCSelect, mnuMonthFCHoliday, mnuMonthBCFocus, mnuMonthBCControl, mnuMonthBCWeek, mnuMonthBCDay, mnuMonthFCToday, mnuLocateSticky, mnuTextOutlineSize, mnuTextOutlineColor, mnuTextOutlineAlpha
		Dim As MenuItem mnuAnalogOutlineAlpha, mnuAnalogOutlineSize, mnuAnalogOutlineColor, mnuAnalogPanelColor, mnuAnalogPanelAlpha, mnuTextOutlineEnabled, MenuItem24, MenuItem19, mnuAnalogPanelEnabled, MenuItem28, mnuAnalogOutlineEnabled, MenuItem18, mnuDayPanelEnabled, mnuDayPanelColor, mnuDayPanelAlpha, MenuItem33, mnuDayOutlineEnabled, mnuDayOutlineSize, mnuDayOutlineColor, mnuDayOutlineAlpha, MenuItem38, mnuMonthPanelEnabled, mnuMonthPanelColor, mnuMonthPanelAlpha, MenuItem42, mnuMonthOutlineEnabled, mnuMonthOutlineSize, mnuMonthOutlineColor, mnuMonthOutlineAlpha, mnuProfileSave, mnuProfileSaveOnExit, mnuDayForeColor, mnuDayTrayColor, mnuMonthForeColor, mnuMonthTrayColor, mnuMonthTrayAlpha, mnuDayTrayAlpha, mnuMonthBCSelect, mnuMonthBAFocus, mnuMonthBAControl, mnuMonthBAWeek, mnuMonthBADay, mnuMonthBASelect, mnuDayBADay, mnuDayBAYear, mnuDayBAWeek, mnuDayBAMonth, mnuDayBAFocus, MenuItem25, mnuProfileResetDefault
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
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Click)
			.OnDropFile = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Filename As WString), @Form_DropFile)
			.AllowDrop = True
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
			.Caption = !"Analog\tCtrl+A"
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
			.Caption = "File"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogBackAlpha
		With mnuAnalogBackAlpha
			.Name = "mnuAnalogBackAlpha"
			.Designer = @This
			.Caption = "Alpha"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogBackBlur
		With mnuAnalogBackBlur
			.Name = "mnuAnalogBackBlur"
			.Designer = @This
			.Caption = "Blur"
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
		' mnuAnalogPanelEnabled
		With mnuAnalogPanelEnabled
			.Name = "mnuAnalogPanelEnabled"
			.Designer = @This
			.Caption = "Panel"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogPanelColor
		With mnuAnalogPanelColor
			.Name = "mnuAnalogPanelColor"
			.Designer = @This
			.Caption = "Back color"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogPanelAlpha
		With mnuAnalogPanelAlpha
			.Name = "mnuAnalogPanelAlpha"
			.Designer = @This
			.Caption = "Back alpha"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' MenuItem28
		With MenuItem28
			.Name = "MenuItem28"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogOutlineEnabled
		With mnuAnalogOutlineEnabled
			.Name = "mnuAnalogOutlineEnabled"
			.Designer = @This
			.Caption = "Outline"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogOutlineSize
		With mnuAnalogOutlineSize
			.Name = "mnuAnalogOutlineSize"
			.Designer = @This
			.Caption = "Size"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogOutlineColor
		With mnuAnalogOutlineColor
			.Name = "mnuAnalogOutlineColor"
			.Designer = @This
			.Caption = "Color"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogOutlineAlpha
		With mnuAnalogOutlineAlpha
			.Name = "mnuAnalogOutlineAlpha"
			.Designer = @This
			.Caption = "Alpha"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' MenuItem19
		With MenuItem19
			.Name = "MenuItem19"
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
		' MenuItem25
		With MenuItem25
			.Name = "MenuItem25"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuAnalogTraySetting
		End With
		' mnuAnalogTrayAlpha
		With mnuAnalogTrayAlpha
			.Name = "mnuAnalogTrayAlpha"
			.Designer = @This
			.Caption = "Alpha"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogTraySetting
		End With
		' mnuAnalogTrayBlur
		With mnuAnalogTrayBlur
			.Name = "mnuAnalogTrayBlur"
			.Designer = @This
			.Caption = "Blur"
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
			.Caption = "Color"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogScaleAlpha
		With mnuAnalogScaleAlpha
			.Name = "mnuAnalogScaleAlpha"
			.Designer = @This
			.Caption = "Alpha"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogScaleBlur
		With mnuAnalogScaleBlur
			.Name = "mnuAnalogScaleBlur"
			.Designer = @This
			.Caption = "Blur"
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
			.Caption = "Second"
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
			.Caption = "Minute"
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
			.Caption = "Hour"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogHandSetting
		End With
		' mnuAnalogHandAlpha
		With mnuAnalogHandAlpha
			.Name = "mnuAnalogHandAlpha"
			.Designer = @This
			.Caption = "Alpha"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogHandSetting
		End With
		' mnuAnalogHandBlur
		With mnuAnalogHandBlur
			.Name = "mnuAnalogHandBlur"
			.Designer = @This
			.Caption = "Blur"
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
			.Caption = "Size"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogTextSetting
		End With
		' mnuAnalogTextFont
		With mnuAnalogTextFont
			.Name = "mnuAnalogTextFont"
			.Designer = @This
			.Caption = "Text"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogTextSetting
		End With
		' mnuAnalogTextColor
		With mnuAnalogTextColor
			.Name = "mnuAnalogTextColor"
			.Designer = @This
			.Caption = "Color"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogTextSetting
		End With
		' mnuAnalogTextFormat
		With mnuAnalogTextFormat
			.Name = "mnuAnalogTextFormat"
			.Designer = @This
			.Caption = "Format"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogTextSetting
		End With
		' mnuAnalogTextX
		With mnuAnalogTextX
			.Name = "mnuAnalogTextX"
			.Designer = @This
			.Caption = "X"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogTextSetting
		End With
		' mnuAnalogTextY
		With mnuAnalogTextY
			.Name = "mnuAnalogTextY"
			.Designer = @This
			.Caption = "Y"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogTextSetting
		End With
		' mnuAnalogTextAlpha
		With mnuAnalogTextAlpha
			.Name = "mnuAnalogTextAlpha"
			.Designer = @This
			.Caption = "Alpha"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogTextSetting
		End With
		' mnuAnalogTextBlur
		With mnuAnalogTextBlur
			.Name = "mnuAnalogTextBlur"
			.Designer = @This
			.Caption = "Blur"
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
			.Caption = !"Text\tCtrl+E"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Checked = True
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
		' MenuItem24
		With MenuItem24
			.Name = "MenuItem24"
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
			.Caption = "File"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextBackAlpha
		With mnuTextBackAlpha
			.Name = "mnuTextBackAlpha"
			.Designer = @This
			.Caption = "Alpha"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextBackBlur
		With mnuTextBackBlur
			.Name = "mnuTextBackBlur"
			.Designer = @This
			.Caption = "Blur"
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
		' mnuTextPanelEnabled
		With mnuTextPanelEnabled
			.Name = "mnuTextPanelEnabled"
			.Designer = @This
			.Caption = "Panel"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextPanelColor
		With mnuTextPanelColor
			.Name = "mnuTextPanelColor"
			.Designer = @This
			.Caption = "Color"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextPanelAlpha
		With mnuTextPanelAlpha
			.Name = "mnuTextPanelAlpha"
			.Designer = @This
			.Caption = "Alpha"
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
		' mnuTextOutlineEnabled
		With mnuTextOutlineEnabled
			.Name = "mnuTextOutlineEnabled"
			.Designer = @This
			.Caption = "Outline"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextOutlineSize
		With mnuTextOutlineSize
			.Name = "mnuTextOutlineSize"
			.Designer = @This
			.Caption = "Size"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextOutlineColor
		With mnuTextOutlineColor
			.Name = "mnuTextOutlineColor"
			.Designer = @This
			.Caption = "Color"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextOutlineAlpha
		With mnuTextOutlineAlpha
			.Name = "mnuTextOutlineAlpha"
			.Designer = @This
			.Caption = "Alpha"
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
			.Caption = "Size"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextBorderAlpha
		With mnuTextBorderAlpha
			.Name = "mnuTextBorderAlpha"
			.Designer = @This
			.Caption = "Alpha"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextBorderColor
		With mnuTextBorderColor
			.Name = "mnuTextBorderColor"
			.Designer = @This
			.Caption = "Color"
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
			.Caption = "Text"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextBlur
		With mnuTextBlur
			.Name = "mnuTextBlur"
			.Designer = @This
			.Caption = "Blur"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextAlpha1
		With mnuTextAlpha1
			.Name = "mnuTextAlpha1"
			.Designer = @This
			.Caption = "Alpha 1"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextAlpha2
		With mnuTextAlpha2
			.Name = "mnuTextAlpha2"
			.Designer = @This
			.Caption = "Alpha 2"
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
			.Caption = "Color 1"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuTextColor2
		With mnuTextColor2
			.Name = "mnuTextColor2"
			.Designer = @This
			.Caption = "Color 2"
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
			.Checked = True
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
			.Caption = !"Day\tCtrl+D"
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
			.Caption = !"Month\tCtrl+M"
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
			.Caption = !"Transparent\tCtrl+T"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuOpacityValue
		With mnuOpacityValue
			.Name = "mnuOpacityValue"
			.Designer = @This
			.Caption = !"Opacity\tCtrl+O"
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
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnnounce
		End With
		' mnuAnnounce1
		With mnuAnnounce1
			.Name = "mnuAnnounce1"
			.Designer = @This
			.Caption = "Hourly"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnnounce
		End With
		' mnuAnnounce2
		With mnuAnnounce2
			.Name = "mnuAnnounce2"
			.Designer = @This
			.Caption = "Half hour"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnnounce
		End With
		' mnuAnnounce3
		With mnuAnnounce3
			.Name = "mnuAnnounce3"
			.Designer = @This
			.Caption = "Quarter hour"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
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
		' mnuProfileSaveOnExit
		With mnuProfileSaveOnExit
			.Name = "mnuProfileSaveOnExit"
			.Designer = @This
			.Caption = "Save on exit"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Checked = True
			.Parent = @PopupMenu1
		End With
		' mnuProfileResetDefault
		With mnuProfileResetDefault
			.Name = "mnuProfileResetDefault"
			.Designer = @This
			.Caption = "Reset default"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuProfileSave
		With mnuProfileSave
			.Name = "mnuProfileSave"
			.Designer = @This
			.Caption = "Save"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuProfileMain
		End With
		' mnuProfileSaveAs
		With mnuProfileSaveAs
			.Name = "mnuProfileSaveAs"
			.Designer = @This
			.Caption = "Save as"
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
			.Caption = "Split"
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
			.Caption = "Font"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' mnuDayForeColor
		With mnuDayForeColor
			.Name = "mnuDayForeColor"
			.Designer = @This
			.Caption = "Color"
			.Parent = @mnuDaySetting
		End With
		' mnuDayFCFocus
		With mnuDayFCFocus
			.Name = "mnuDayFCFocus"
			.Designer = @This
			.Caption = "Focus"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDayForeColor
		End With
		' mnuDayFCYear
		With mnuDayFCYear
			.Name = "mnuDayFCYear"
			.Designer = @This
			.Caption = "Year"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDayForeColor
		End With
		' mnuDayFCMonth
		With mnuDayFCMonth
			.Name = "mnuDayFCMonth"
			.Designer = @This
			.Caption = "Month"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDayForeColor
		End With
		' mnuDayFCDay
		With mnuDayFCDay
			.Name = "mnuDayFCDay"
			.Designer = @This
			.Caption = "Day"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDayForeColor
		End With
		' mnuDayFCWeek
		With mnuDayFCWeek
			.Name = "mnuDayFCWeek"
			.Designer = @This
			.Caption = "Week"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDayForeColor
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
		' mnuDayTrayColor
		With mnuDayTrayColor
			.Name = "mnuDayTrayColor"
			.Designer = @This
			.Caption = "Color"
			.Parent = @mnuDaySetting
		End With
		' mnuDayBCFocus
		With mnuDayBCFocus
			.Name = "mnuDayBCFocus"
			.Designer = @This
			.Caption = "Focus"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDayTrayColor
		End With
		' mnuDayBCYear
		With mnuDayBCYear
			.Name = "mnuDayBCYear"
			.Designer = @This
			.Caption = "Year"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDayTrayColor
		End With
		' mnuDayBCMonth
		With mnuDayBCMonth
			.Name = "mnuDayBCMonth"
			.Designer = @This
			.Caption = "Month"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDayTrayColor
		End With
		' mnuDayBCDay
		With mnuDayBCDay
			.Name = "mnuDayBCDay"
			.Designer = @This
			.Caption = "Day"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDayTrayColor
		End With
		' mnuDayBCWeek
		With mnuDayBCWeek
			.Name = "mnuDayBCWeek"
			.Designer = @This
			.Caption = "Week"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDayTrayColor
		End With
		' mnuDayTrayAlpha
		With mnuDayTrayAlpha
			.Name = "mnuDayTrayAlpha"
			.Designer = @This
			.Caption = "Alpha"
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
			.Caption = "File"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' mnuDayBackAlpha
		With mnuDayBackAlpha
			.Name = "mnuDayBackAlpha"
			.Designer = @This
			.Caption = "Aplha"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' mnuDayBackBlur
		With mnuDayBackBlur
			.Name = "mnuDayBackBlur"
			.Designer = @This
			.Caption = "Blur"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' mnuMonthControl
		With mnuMonthControl
			.Name = "mnuMonthControl"
			.Designer = @This
			.Caption = "Show controls"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthWeek
		With mnuMonthWeek
			.Name = "mnuMonthWeek"
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
			.Caption = "Font"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthForeColor
		With mnuMonthForeColor
			.Name = "mnuMonthForeColor"
			.Designer = @This
			.Caption = "Color"
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthFCFocus
		With mnuMonthFCFocus
			.Name = "mnuMonthFCFocus"
			.Designer = @This
			.Caption = "Focus"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthForeColor
		End With
		' mnuMonthFCControl
		With mnuMonthFCControl
			.Name = "mnuMonthFCControl"
			.Designer = @This
			.Caption = "Control"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthForeColor
		End With
		' mnuMonthFCWeek
		With mnuMonthFCWeek
			.Name = "mnuMonthFCWeek"
			.Designer = @This
			.Caption = "Week"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthForeColor
		End With
		' mnuMonthFCDay
		With mnuMonthFCDay
			.Name = "mnuMonthFCDay"
			.Designer = @This
			.Caption = "Day"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthForeColor
		End With
		' mnuMonthFCSelect
		With mnuMonthFCSelect
			.Name = "mnuMonthFCSelect"
			.Designer = @This
			.Caption = "Select"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthForeColor
		End With
		' mnuMonthFCToday
		With mnuMonthFCToday
			.Name = "mnuMonthFCToday"
			.Designer = @This
			.Caption = "Today"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthForeColor
		End With
		' mnuMonthFCHoliday
		With mnuMonthFCHoliday
			.Name = "mnuMonthFCHoliday"
			.Designer = @This
			.Caption = "Holiday"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthForeColor
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
		' mnuMonthTrayColor
		With mnuMonthTrayColor
			.Name = "mnuMonthTrayColor"
			.Designer = @This
			.Caption = "Color"
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthBCFocus
		With mnuMonthBCFocus
			.Name = "mnuMonthBCFocus"
			.Designer = @This
			.Caption = "Focus"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthTrayColor
		End With
		' mnuMonthBCControl
		With mnuMonthBCControl
			.Name = "mnuMonthBCControl"
			.Designer = @This
			.Caption = "Control"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthTrayColor
		End With
		' mnuMonthBCWeek
		With mnuMonthBCWeek
			.Name = "mnuMonthBCWeek"
			.Designer = @This
			.Caption = "Week"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthTrayColor
		End With
		' mnuMonthBCDay
		With mnuMonthBCDay
			.Name = "mnuMonthBCDay"
			.Designer = @This
			.Caption = "Day"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthTrayColor
		End With
		' mnuMonthBCSelect
		With mnuMonthBCSelect
			.Name = "mnuMonthBCSelect"
			.Designer = @This
			.Caption = "Select"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthTrayColor
		End With
		' mnuMonthTrayAlpha
		With mnuMonthTrayAlpha
			.Name = "mnuMonthTrayAlpha"
			.Designer = @This
			.Caption = "Alpha"
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
			.Caption = "File"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthBackAlpha
		With mnuMonthBackAlpha
			.Name = "mnuMonthBackAlpha"
			.Designer = @This
			.Caption = "Alpha"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthBackBlur
		With mnuMonthBackBlur
			.Name = "mnuMonthBackBlur"
			.Designer = @This
			.Caption = "Blur"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' MenuItem18
		With MenuItem18
			.Name = "MenuItem18"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuDaySetting
		End With
		' mnuDayPanelEnabled
		With mnuDayPanelEnabled
			.Name = "mnuDayPanelEnabled"
			.Designer = @This
			.Caption = "Panel"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' mnuDayPanelColor
		With mnuDayPanelColor
			.Name = "mnuDayPanelColor"
			.Designer = @This
			.Caption = "Color"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' mnuDayPanelAlpha
		With mnuDayPanelAlpha
			.Name = "mnuDayPanelAlpha"
			.Designer = @This
			.Caption = "Alpha"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' MenuItem33
		With MenuItem33
			.Name = "MenuItem33"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuDaySetting
		End With
		' mnuDayOutlineEnabled
		With mnuDayOutlineEnabled
			.Name = "mnuDayOutlineEnabled"
			.Designer = @This
			.Caption = "Outline"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' mnuDayOutlineSize
		With mnuDayOutlineSize
			.Name = "mnuDayOutlineSize"
			.Designer = @This
			.Caption = "Size"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' mnuDayOutlineColor
		With mnuDayOutlineColor
			.Name = "mnuDayOutlineColor"
			.Designer = @This
			.Caption = "Color"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' mnuDayOutlineAlpha
		With mnuDayOutlineAlpha
			.Name = "mnuDayOutlineAlpha"
			.Designer = @This
			.Caption = "Alpha"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDaySetting
		End With
		' MenuItem38
		With MenuItem38
			.Name = "MenuItem38"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthPanelEnabled
		With mnuMonthPanelEnabled
			.Name = "mnuMonthPanelEnabled"
			.Designer = @This
			.Caption = "Panel"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthPanelColor
		With mnuMonthPanelColor
			.Name = "mnuMonthPanelColor"
			.Designer = @This
			.Caption = "Color"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthPanelAlpha
		With mnuMonthPanelAlpha
			.Name = "mnuMonthPanelAlpha"
			.Designer = @This
			.Caption = "Alpha"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' MenuItem42
		With MenuItem42
			.Name = "MenuItem42"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthOutlineEnabled
		With mnuMonthOutlineEnabled
			.Name = "mnuMonthOutlineEnabled"
			.Designer = @This
			.Caption = "Outline"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthOutlineSize
		With mnuMonthOutlineSize
			.Name = "mnuMonthOutlineSize"
			.Designer = @This
			.Caption = "Size"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthOutlineColor
		With mnuMonthOutlineColor
			.Name = "mnuMonthOutlineColor"
			.Designer = @This
			.Caption = "Color"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthOutlineAlpha
		With mnuMonthOutlineAlpha
			.Name = "mnuMonthOutlineAlpha"
			.Designer = @This
			.Caption = "Alpha"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthSetting
		End With
		' mnuMonthBAFocus
		With mnuMonthBAFocus
			.Name = "mnuMonthBAFocus"
			.Designer = @This
			.Caption = "Focus"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthTrayAlpha
		End With
		' mnuMonthBAControl
		With mnuMonthBAControl
			.Name = "mnuMonthBAControl"
			.Designer = @This
			.Caption = "Control"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthTrayAlpha
		End With
		' mnuMonthBAWeek
		With mnuMonthBAWeek
			.Name = "mnuMonthBAWeek"
			.Designer = @This
			.Caption = "Week"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthTrayAlpha
		End With
		' mnuMonthBADay
		With mnuMonthBADay
			.Name = "mnuMonthBADay"
			.Designer = @This
			.Caption = "Day"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthTrayAlpha
		End With
		' mnuMonthBASelect
		With mnuMonthBASelect
			.Name = "mnuMonthBASelect"
			.Designer = @This
			.Caption = "Select"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuMonthTrayAlpha
		End With
		' mnuDayBAFocus
		With mnuDayBAFocus
			.Name = "mnuDayBAFocus"
			.Designer = @This
			.Caption = "Focus"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDayTrayAlpha
		End With
		' mnuDayBAYear
		With mnuDayBAYear
			.Name = "mnuDayBAYear"
			.Designer = @This
			.Caption = "Year"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDayTrayAlpha
		End With
		' mnuDayBAMonth
		With mnuDayBAMonth
			.Name = "mnuDayBAMonth"
			.Designer = @This
			.Caption = "Month"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDayTrayAlpha
		End With
		' mnuDayBADay
		With mnuDayBADay
			.Name = "mnuDayBADay"
			.Designer = @This
			.Caption = "Day"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDayTrayAlpha
		End With
		' mnuDayBAWeek
		With mnuDayBAWeek
			.Name = "mnuDayBAWeek"
			.Designer = @This
			.Caption = "Week"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuDayTrayAlpha
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

Private Sub frmClockType.TestBackup()
	ReDim TestMenu(TestCount)
	ReDim TestSetting(TestCount)
	TestMenu(0) = @mnuAnalogEnabled
	TestMenu(1) = @mnuAnalogOutlineEnabled
	TestMenu(2) = @mnuAnalogPanelEnabled
	TestMenu(3) = @mnuAnalogBackEnabled
	TestMenu(4) = @mnuAnalogTrayEnabled
	TestMenu(5) = @mnuAnalogScaleEnabled
	TestMenu(6) = @mnuAnalogTextEnabled
	TestMenu(7) = @mnuAnalogHandEnabled
	TestMenu(8) = @mnuAnalogHandSecondEnabled
	TestMenu(9) = @mnuAnalogHandMinuteEnabled
	TestMenu(10) = @mnuAnalogHandHourEnabled
	TestMenu(11) = @mnuTextEnabled
	TestMenu(12) = @mnuTextOutlineEnabled
	TestMenu(13) = @mnuTextPanelEnabled
	TestMenu(14) = @mnuTextBackEnabled
	TestMenu(15) = @mnuTextPanelEnabled
	TestMenu(16) = @mnuTextShowSecond
	TestMenu(17) = @mnuTextBlinkColon
	TestMenu(18) = @mnuTextBorderEnabled
	TestMenu(19) = @mnuTextGradient
	TestMenu(20) = @mnuTextWhite
	TestMenu(21) = @mnuTextBlack
	TestMenu(22) = @mnuTextRed
	TestMenu(23) = @mnuTextGreen
	TestMenu(24) = @mnuTextBlue
	TestMenu(25) = @mnuDayEnabled
	TestMenu(26) = @mnuDayStyle0
	TestMenu(27) = @mnuDayStyle1
	TestMenu(28) = @mnuDayStyle2
	TestMenu(29) = @mnuDayTrayEnabled
	TestMenu(30) = @mnuDayPanelEnabled
	TestMenu(31) = @mnuDayBackEnabled
	TestMenu(32) = @mnuDayOutlineEnabled
	TestMenu(33) = @mnuMonthEnabled
	TestMenu(34) = @mnuMonthWeek
	TestMenu(35) = @mnuMonthControl
	TestMenu(36) = @mnuMonthTrayEnabled
	TestMenu(37) = @mnuMonthPanelEnabled
	TestMenu(38) = @mnuMonthBackEnabled
	TestMenu(39) = @mnuTransparent
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
	Dim i As Integer
	Do
		i = Rnd(Timer) * TestCount * 2
	Loop While i < 0 Or i > TestCount
	mnuMenu_Click(*TestMenu(i))
End Sub

Private Function frmClockType.ProfileIdx(ByVal fDefNum As Integer = -1) As Integer
	Static sIdx As Integer
	If fDefNum < 0 Then
		'默认参数返回+1索引值
		sIdx = sIdx + 1
	Else
		'传入非负数参数设置索引值
		sIdx = fDefNum
	End If
	Return sIdx
End Function

Private Sub frmClockType.FileName2Menu(sExt As WString)
	Dim i As Integer
	For i = mnuProfileCount To 0 Step -1
		mnuProfileMain.Remove(mnuProfileList(i))
		Delete mnuProfileList(i)
	Next
	Erase mnuProfileList
	mnuProfileCount = -1
	
	Dim f As String
	Dim t As String
	f = Dir(*mAppPath & "*" & sExt)
	Do
		i = Len(f) - Len(sExt)
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
			If InStr(*mProfileName, f) Then mnuProfileList(mnuProfileCount)->Checked = True
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
Private Sub frmClockType.Clock2Interface()
	mnuOpacityValue.Caption = !"Opacity\t&&H" & Hex(mOpacity)
	
	mnuAnalogBackAlpha.Caption = !"Alpha\t&&H" & Hex(mAnalogClock.mBackAlpha)
	mnuAnalogBackBlur.Caption = !"Blur\t" & mAnalogClock.mBackBlur
	mnuAnalogBackEnabled.Checked = mAnalogClock.mBackEnabled
	mnuAnalogBackFile.Caption = !"File\t" & FullName2File(mAnalogClock.FileName)
	mnuAnalogHandAlpha.Caption = !"Alpha\t&&H" & Hex(mAnalogClock.mHandAlpha)
	mnuAnalogHandBlur.Caption = !"Blur\t" & mAnalogClock.mHandBlur
	mnuAnalogHandEnabled.Checked = mAnalogClock.mHandEnabled
	mnuAnalogHandHour.Caption = !"Hour Color\t&&H" & mAnalogClock.mHandHourColor
	mnuAnalogHandHourEnabled.Checked = mAnalogClock.mHandHourEnabled
	mnuAnalogHandMinute.Caption = !"Minute Color\t&&H" & Hex(mAnalogClock.mHandMinuteColor)
	mnuAnalogHandMinuteEnabled.Checked = mAnalogClock.mHandMinuteEnabled
	mnuAnalogHandSecond.Caption = !"Second Color\t&&H" & Hex(mAnalogClock.mHandSecondColor)
	mnuAnalogHandSecondEnabled.Checked = mAnalogClock.mHandSecondEnabled
	mnuAnalogOutlineAlpha.Caption = !"Alpha\t&&H" & Hex(mAnalogClock.mOutlineAlpha)
	mnuAnalogOutlineColor.Caption = !"Color\t&&H" & Hex(mAnalogClock.mOutlineColor)
	mnuAnalogOutlineEnabled.Checked = mAnalogClock.mOutlineEnabled
	mnuAnalogOutlineSize.Caption = !"Size\t" & mAnalogClock.mOutlineSize
	mnuAnalogPanelAlpha.Caption = !"Alpha\t&&H" & Hex(mAnalogClock.mPanelAlpha)
	mnuAnalogPanelColor.Caption = !"Color\t&&H" & Hex(mAnalogClock.mPanelColor)
	mnuAnalogPanelEnabled.Checked = mAnalogClock.mPanelEnabled
	mnuAnalogScaleAlpha.Caption = !"Alpha\t&&H" & Hex(mAnalogClock.mScaleAlpha)
	mnuAnalogScaleBlur.Caption = !"Blur\t" & mAnalogClock.mScaleBlur
	mnuAnalogScaleColor.Caption = !"Color\t&&H" & Hex(mAnalogClock.mScaleColor)
	mnuAnalogScaleEnabled.Checked = mAnalogClock.mScaleEnabled
	mnuAnalogSetting.Enabled = mnuAnalogEnabled.Checked
	mnuAnalogTextAlpha.Caption = !"Alpha\t&&H" & Hex(mAnalogClock.mTextAlpha)
	mnuAnalogTextBlur.Caption = !"Blur\t" & mAnalogClock.mTextBlur
	mnuAnalogTextColor.Caption = !"Color\t&&H" & Hex(mAnalogClock.mTextColor)
	mnuAnalogTextEnabled.Checked = mAnalogClock.mTextEnabled
	mnuAnalogTextFont.Caption = !"Font\t" & *mAnalogClock.mTextFont & ", " & mAnalogClock.mTextBold
	mnuAnalogTextFormat.Caption = !"Format\t" & *mAnalogClock.mTextFormat
	mnuAnalogTextSize.Caption = !"Size\t" & mAnalogClock.mTextSize
	mnuAnalogTextX.Caption = !"X\t" & mAnalogClock.mTextOffsetX
	mnuAnalogTextY.Caption = !"Y\t" & mAnalogClock.mTextOffsetY
	mnuAnalogTrayAlpha.Caption = !"Alpha\t&&H" & Hex(mAnalogClock.mTrayAlpha)
	mnuAnalogTrayBlur.Caption = !"Blur\t" & mAnalogClock.mTrayBlur
	mnuAnalogTrayEA1.Caption = !"Edge Alpha 1\t&&H" & Hex( mAnalogClock.mTrayEdgeAlpha1)
	mnuAnalogTrayEA2.Caption = !"Edge Alpha 2\t&&H" & Hex(mAnalogClock.mTrayEdgeAlpha2)
	mnuAnalogTrayEC1.Caption = !"Edge Color 1\t&&H" & Hex(mAnalogClock.mTrayEdgeColor1)
	mnuAnalogTrayEC2.Caption = !"Edge Color 2\t&&H" & Hex(mAnalogClock.mTrayEdgeColor2)
	mnuAnalogTrayEnabled.Checked = mAnalogClock.mTrayEnabled
	mnuAnalogTrayFA1.Caption = !"Face Alpha 1\t&&H" & Hex(mAnalogClock.mTrayFaceAlpha1)
	mnuAnalogTrayFA2.Caption = !"Face Alpha 2\t&&H" & Hex(mAnalogClock.mTrayFaceAlpha2)
	mnuAnalogTrayFC1.Caption = !"Face Color 1\t&&H" & Hex(mAnalogClock.mTrayFaceColor1)
	mnuAnalogTrayFC2.Caption = !"Face Color 2\t&&H" & Hex(mAnalogClock.mTrayFaceColor2)
	mnuAnalogTraySA.Caption = !"Shadow Alpha\t&&H" & Hex(mAnalogClock.mTrayShadowAlpha)
	mnuAnalogTraySC.Caption = !"Shadow Color\t&&H" & Hex(mAnalogClock.mTrayShadowColor)
	
	mnuTextAlpha1.Caption = !"Alpha1\t&&H" & Hex(mTextAlpha1)
	mnuTextAlpha2.Caption = !"Alpha2\t&&H" & Hex(mTextAlpha2)
	mnuTextBackAlpha.Caption = !"Alpha\t&&H" & Hex(mTextClock.mBackAlpha)
	mnuTextBackBlur.Caption = !"Blur\t" & mTextClock.mBackBlur
	mnuTextBackEnabled.Checked = mTextClock.mBackEnabled
	mnuTextBackFile.Caption = !"File\t" & FullName2File(mTextClock.FileName)
	mnuTextBlinkColon.Checked = mTextClock.mBlinkColon
	mnuTextBlur.Caption = !"Blur\t" & mTextClock.mTextBlur
	mnuTextBorderAlpha.Caption = !"Alpha\t&&H" & Hex(mTextClock.mBorderAlpha)
	mnuTextBorderColor.Caption = !"Color\t&&H" & Hex(mTextClock.mBorderColor)
	mnuTextBorderEnabled.Checked = mTextClock.mBorderEnabled
	mnuTextBorderSize.Caption = !"Size\t" & mTextClock.mBorderSize
	mnuTextColor1.Caption = !"Color 1\t&&H" & Hex(mTextColor1)
	mnuTextColor2.Caption = !"Color 2\t&&H" & Hex(mTextColor2)
	mnuTextFont.Caption = !"Font\t" & *mTextClock.mFontName & ", " & mTextClock.mFontStyle
	mnuTextOutlineAlpha.Caption = !"Alpha\t&&H" & Hex(mTextClock.mOutlineAlpha)
	mnuTextOutlineColor.Caption = !"Color\t&&H" & Hex(mTextClock.mOutlineColor)
	mnuTextOutlineEnabled.Checked = mTextClock.mOutlineEnabled
	mnuTextOutlineSize.Caption = !"Size\t" & mTextClock.mOutlineSize
	mnuTextPanelAlpha.Caption = !"Alpha\t&&H" & Hex(mTextClock.mPanelAlpha)
	mnuTextPanelColor.Caption = !"Color\t&&H" & Hex(mTextClock.mPanelColor)
	mnuTextPanelEnabled.Checked = mTextClock.mPanelEnabled
	mnuTextSetting.Enabled = mnuTextEnabled.Checked
	mnuTextShadow.Checked = mTextClock.mShadowEnabled
	mnuTextShowSecond.Checked = mTextClock.mShowSecond
	
	mnuDayBackAlpha.Caption = !"Alpha\t&&H" & Hex(frmDay.mDay.mBackAlpha(DayImageFile) Shr 24)
	mnuDayBackBlur.Caption = !"Blur\t" & frmDay.mDay.mBackBlur
	mnuDayBackEnabled.Checked = frmDay.mDay.mBackEnabled
	mnuDayBackFile.Caption = !"File\t" & FullName2File(frmDay.mDay.mBackImage.ImageFile)
	mnuDayBADay.Caption = !"Day\t&&H" & Hex(frmDay.mDay.mBackAlpha(DayDay) Shr 24)
	mnuDayBAFocus.Caption = !"Focus\t&&H" & Hex(frmDay.mDay.mBackAlpha(DayFocus) Shr 24)
	mnuDayBAMonth.Caption = !"Month\t&&H" & Hex(frmDay.mDay.mBackAlpha(DayMonth) Shr 24)
	mnuDayBAWeek.Caption = !"Week\t&&H" & Hex(frmDay.mDay.mBackAlpha(DayWeek) Shr 24)
	mnuDayBAYear.Caption = !"Year\t&&H" & Hex(frmDay.mDay.mBackAlpha(DayYear) Shr 24)
	mnuDayBCDay.Caption = !"Day\t&&H" & Hex(frmDay.mDay.mBackColor(DayDay))
	mnuDayBCFocus.Caption = !"Focus\t&&H" & Hex(frmDay.mDay.mBackColor(DayFocus))
	mnuDayBCMonth.Caption = !"Month\t&&H" & Hex(frmDay.mDay.mBackColor(DayMonth))
	mnuDayBCWeek.Caption = !"Week\t&&H" & Hex(frmDay.mDay.mBackColor(DayWeek))
	mnuDayBCYear.Caption = !"Year\t&&H" & Hex(frmDay.mDay.mBackColor(DayYear))
	mnuDayFCDay.Caption = !"Day\t&&H" & Hex(frmDay.mDay.mForeColor(DayDay))
	mnuDayFCFocus.Caption = !"Focus\t&&H" & Hex(frmDay.mDay.mForeColor(DayFocus))
	mnuDayFCMonth.Caption = !"Month\t&&H" & Hex(frmDay.mDay.mForeColor(DayMonth))
	mnuDayFCWeek.Caption = !"Week\t&&H" & Hex(frmDay.mDay.mForeColor(DayWeek))
	mnuDayFCYear.Caption = !"Year\t&&H" & Hex(frmDay.mDay.mForeColor(DayYear))
	mnuDayOutlineAlpha.Caption = !"Alpha\t&&H" & Hex(frmDay.mDay.mForeAlpha(DayPanel) Shr 24)
	mnuDayOutlineColor.Caption = !"Color\t&&H" & Hex(frmDay.mDay.mForeColor(DayPanel))
	mnuDayOutlineEnabled.Checked = frmDay.mDay.mOutlineEnabled
	mnuDayOutlineSize.Caption = !"Size\t" & frmDay.mDay.mOutlineSize
	mnuDayPanelAlpha.Caption = !"Alpha\t&&H" & Hex(frmDay.mDay.mBackAlpha(DayPanel) Shr 24)
	mnuDayPanelColor.Caption = !"Color\t&&H" & Hex(frmDay.mDay.mBackColor(DayPanel))
	mnuDayPanelEnabled.Checked = frmDay.mDay.mPanelEnabled
	mnuDaySetting.Enabled = mnuDayEnabled.Checked
	mnuDaySplit.Caption = !"Split\t" & frmDay.mDay.mSplitXScale
	mnuDayStyle0.Checked = CBool(frmDay.mDay.mShowStyle = 0)
	mnuDayStyle1.Checked = CBool(frmDay.mDay.mShowStyle = 1)
	mnuDayStyle2.Checked = CBool(frmDay.mDay.mShowStyle = 2)
	mnuDayTextFont.Caption = !"Font\t" & *frmDay.mDay.mFontName
	mnuDayTrayEnabled.Checked = frmDay.mDay.mTrayEnabled
	mnuDayTrayEnabled.Checked = frmDay.mDay.mTrayEnabled
	
	mnuMonthBackAlpha.Caption = !"Alpha\t&&H" & Hex(frmMonth.mMonth.mBackAlpha(MonthImageFile) Shr 24)
	mnuMonthBackBlur.Caption = !"Blur\t" & frmMonth.mMonth.mBackBlur
	mnuMonthBackEnabled.Checked = frmMonth.mMonth.mBackEnabled
	mnuMonthBackFile.Caption = !"File\t" & FullName2File(frmMonth.mMonth.mBackImage.ImageFile)
	mnuMonthBAControl.Caption = !"Control\t&&H" & Hex(frmMonth.mMonth.mBackAlpha(MonthControl) Shr 24)
	mnuMonthBADay.Caption = !"Day\t&&H" & Hex(frmMonth.mMonth.mBackAlpha(MonthDay) Shr 24)
	mnuMonthBAFocus.Caption = !"Focus\t&&H" & Hex(frmMonth.mMonth.mBackAlpha(MonthFocus) Shr 24)
	mnuMonthBASelect.Caption = !"Select\t&&H" & Hex(frmMonth.mMonth.mBackAlpha(MonthSelect) Shr 24)
	mnuMonthBAWeek.Caption = !"Week\t&&H" & Hex(frmMonth.mMonth.mBackAlpha(MonthWeek) Shr 24)
	mnuMonthBCControl.Caption = !"Control\t&&H" & Hex(frmMonth.mMonth.mBackColor(MonthControl))
	mnuMonthBCDay.Caption = !"Day\t&&H" & Hex(frmMonth.mMonth.mBackColor(MonthDay))
	mnuMonthBCFocus.Caption = !"Focus\t&&H" & Hex(frmMonth.mMonth.mBackColor(MonthFocus))
	mnuMonthBCSelect.Caption = !"Select\t&&H" & Hex(frmMonth.mMonth.mBackColor(MonthSelect))
	mnuMonthBCWeek.Caption = !"Week\t&&H" & Hex(frmMonth.mMonth.mBackColor(MonthWeek))
	mnuMonthControl.Checked = frmMonth.mMonth.mShowControls
	mnuMonthFCControl.Caption = !"Control\t&&H" & Hex(frmMonth.mMonth.mForeColor(MonthControl))
	mnuMonthFCDay.Caption = !"Day\t&&H" & Hex(frmMonth.mMonth.mForeColor(MonthDay))
	mnuMonthFCFocus.Caption = !"Focus\t&&H" & Hex(frmMonth.mMonth.mForeColor(MonthFocus))
	mnuMonthFCHoliday.Caption = !"Holiday\t&&H" & Hex(frmMonth.mMonth.mForeColor(MonthHoliday))
	mnuMonthFCSelect.Caption = !"Select\t&&H" & Hex(frmMonth.mMonth.mForeColor(MonthSelect))
	mnuMonthFCToday.Caption = !"Today\t&&H" & Hex(frmMonth.mMonth.mForeColor(MonthToday))
	mnuMonthFCWeek.Caption = !"Week\t&&H" & Hex(frmMonth.mMonth.mForeColor(MonthWeek))
	mnuMonthOutlineAlpha.Caption = !"Alpha\t&&H" & Hex(frmMonth.mMonth.mForeAlpha(MonthPanel) Shr 24)
	mnuMonthOutlineColor.Caption = !"Color\t&&H" & Hex(frmMonth.mMonth.mForeColor(MonthPanel))
	mnuMonthOutlineEnabled.Checked = frmMonth.mMonth.mOutlineEnabled
	mnuMonthOutlineSize.Caption = !"Size\t" & frmMonth.mMonth.mOutlineSize
	mnuMonthPanelAlpha.Caption = !"Alpha\t&&H" & Hex(frmMonth.mMonth.mBackAlpha(MonthPanel) Shr 24)
	mnuMonthPanelColor.Caption = !"Color\t&&H" & Hex(frmMonth.mMonth.mBackColor(MonthPanel))
	mnuMonthPanelEnabled.Checked = frmMonth.mMonth.mPanelEnabled
	mnuMonthSetting.Enabled = mnuMonthEnabled.Checked
	mnuMonthTextFont.Caption = !"Font\t" & *frmMonth.mMonth.mFontName
	mnuMonthTrayEnabled.Checked = frmMonth.mMonth.mTrayEnabled
	mnuMonthWeek.Checked = frmMonth.mMonth.mShowWeeks
End Sub

Private Function frmClockType.ProfileDefLoad() As UString
	Dim sProfile As WString Ptr
	TextFromFile(FullNameFromFile("gdipClock.ini"), sProfile)
	Dim As UString rtn = *sProfile
	Deallocate(sProfile)
	If rtn = "" Then
		Return FullNameFromFile("gdipClock.prf")
	Else
		Return FullNameFromFile(rtn)
	End If
End Function

Private Sub frmClockType.ProfileDefSave()
	TextToFile(FullNameFromFile("gdipClock.ini"), FullName2File(*mProfileName))
End Sub

Private Sub frmClockType.ProfileInitial()
	WLet(mAppPath, ExePath & "\")
	ReDim mKeyName(mKeyCount)
	ReDim mKeyValDef(mKeyCount)
	ReDim mKeyValue(mKeyCount)
	ReDim mKeyNameLen(mKeyCount)
	
	mSetMainStart = ProfileIdx(0)
	WLet(mKeyName(ProfileIdx(0)), WStr("[Main]"))
	WLet(mKeyName(ProfileIdx()), "Clock left = ")
	WLet(mKeyName(ProfileIdx()), "Clock top = ")
	WLet(mKeyName(ProfileIdx()), "Clock width = ")
	WLet(mKeyName(ProfileIdx()), "Clock height = ")
	WLet(mKeyName(ProfileIdx()), "Clock always on top = ")
	WLet(mKeyName(ProfileIdx()), "Clock click through = ")
	WLet(mKeyName(ProfileIdx()), "Clock analog enabled = ")
	WLet(mKeyName(ProfileIdx()), "Clock text enabled = ")
	WLet(mKeyName(ProfileIdx()), "Clock day enabled = ")
	WLet(mKeyName(ProfileIdx()), "Clock month enabled = ")
	WLet(mKeyName(ProfileIdx()), "Clock transparent = ")
	WLet(mKeyName(ProfileIdx()), "Clock opacity value = ")
	WLet(mKeyName(ProfileIdx()), "Clock locate sticky = ")
	WLet(mKeyName(ProfileIdx()), "Clock hide = ")
	WLet(mKeyName(ProfileIdx()), "Clock profile auto save = ")
	
	mSetAnalogStart = ProfileIdx()
	WLet(mKeyName(ProfileIdx(mSetAnalogStart)), WStr("[Analog]"))
	
	WLet(mKeyName(ProfileIdx()), "Analog background enabled = ")
	WLet(mKeyName(ProfileIdx()), "Analog background file = ")
	WLet(mKeyName(ProfileIdx()), "Analog background alpha = ")
	WLet(mKeyName(ProfileIdx()), "Analog background blur = ")
	WLet(mKeyName(ProfileIdx()), "Analog panel enabled = ")
	WLet(mKeyName(ProfileIdx()), "Analog panel color = ")
	WLet(mKeyName(ProfileIdx()), "Analog panel alpha = ")
	WLet(mKeyName(ProfileIdx()), "Analog outline enabled = ")
	WLet(mKeyName(ProfileIdx()), "Analog outline size = ")
	WLet(mKeyName(ProfileIdx()), "Analog outline color = ")
	WLet(mKeyName(ProfileIdx()), "Analog outline alpha = ")
	WLet(mKeyName(ProfileIdx()), "Analog tray enabled = ")
	WLet(mKeyName(ProfileIdx()), "Analog tray face color 1 = ")
	WLet(mKeyName(ProfileIdx()), "Analog tray face alpha 1 = ")
	WLet(mKeyName(ProfileIdx()), "Analog tray face color 2 = ")
	WLet(mKeyName(ProfileIdx()), "Analog tray face alpha 2 = ")
	WLet(mKeyName(ProfileIdx()), "Analog tray edge color 1 = ")
	WLet(mKeyName(ProfileIdx()), "Analog tray edge alpha 1 = ")
	WLet(mKeyName(ProfileIdx()), "Analog tray edge color 2 = ")
	WLet(mKeyName(ProfileIdx()), "Analog tray edge alpha 2 = ")
	WLet(mKeyName(ProfileIdx()), "Analog tray shadow color = ")
	WLet(mKeyName(ProfileIdx()), "Analog tray shadow alpha = ")
	WLet(mKeyName(ProfileIdx()), "Analog tray alpha = ")
	WLet(mKeyName(ProfileIdx()), "Analog tray blur = ")
	WLet(mKeyName(ProfileIdx()), "Analog scale enabled = ")
	WLet(mKeyName(ProfileIdx()), "Analog scale color = ")
	WLet(mKeyName(ProfileIdx()), "Analog scale alpha = ")
	WLet(mKeyName(ProfileIdx()), "Analog scale blur = ")
	WLet(mKeyName(ProfileIdx()), "Analog hand enabled = ")
	WLet(mKeyName(ProfileIdx()), "Analog hand second enabled = ")
	WLet(mKeyName(ProfileIdx()), "Analog hand second color = ")
	WLet(mKeyName(ProfileIdx()), "Analog hand minute enabled = ")
	WLet(mKeyName(ProfileIdx()), "Analog hand minute color = ")
	WLet(mKeyName(ProfileIdx()), "Analog hand hour enabled = ")
	WLet(mKeyName(ProfileIdx()), "Analog hand hour color = ")
	WLet(mKeyName(ProfileIdx()), "Analog hand alpha = ")
	WLet(mKeyName(ProfileIdx()), "Analog hand blur = ")
	WLet(mKeyName(ProfileIdx()), "Analog text enabled = ")
	WLet(mKeyName(ProfileIdx()), "Analog text size = ")
	WLet(mKeyName(ProfileIdx()), "Analog text font = ")
	WLet(mKeyName(ProfileIdx()), "Analog text bold = ")
	WLet(mKeyName(ProfileIdx()), "Analog text color = ")
	WLet(mKeyName(ProfileIdx()), "Analog text x = ")
	WLet(mKeyName(ProfileIdx()), "Analog text y = ")
	WLet(mKeyName(ProfileIdx()), "Analog text format = ")
	WLet(mKeyName(ProfileIdx()), "Analog text alpha = ")
	WLet(mKeyName(ProfileIdx()), "Analog text blur = ")
	
	mSetTextStart = ProfileIdx()
	WLet(mKeyName(ProfileIdx(mSetTextStart)), WStr("[Text]"))
	
	WLet(mKeyName(ProfileIdx()), "Text show second = ")
	WLet(mKeyName(ProfileIdx()), "Text blink colon = ")
	WLet(mKeyName(ProfileIdx()), "Text shadow = ")
	WLet(mKeyName(ProfileIdx()), "Text background enabled = ")
	WLet(mKeyName(ProfileIdx()), "Text background file = ")
	WLet(mKeyName(ProfileIdx()), "Text background alpha = ")
	WLet(mKeyName(ProfileIdx()), "Text background blur = ")
	WLet(mKeyName(ProfileIdx()), "Text panel enabled = ")
	WLet(mKeyName(ProfileIdx()), "Text panel color = ")
	WLet(mKeyName(ProfileIdx()), "Text panel alpha = ")
	WLet(mKeyName(ProfileIdx()), "Text outline enabled = ")
	WLet(mKeyName(ProfileIdx()), "Text outline size = ")
	WLet(mKeyName(ProfileIdx()), "Text outline alpha = ")
	WLet(mKeyName(ProfileIdx()), "Text outline color = ")
	WLet(mKeyName(ProfileIdx()), "Text font = ")
	WLet(mKeyName(ProfileIdx()), "Text bold = ")
	WLet(mKeyName(ProfileIdx()), "Text alpha 1 = ")
	WLet(mKeyName(ProfileIdx()), "Text alpha 2 = ")
	WLet(mKeyName(ProfileIdx()), "Text blur = ")
	WLet(mKeyName(ProfileIdx()), "Text border enabled = ")
	WLet(mKeyName(ProfileIdx()), "Text border size = ")
	WLet(mKeyName(ProfileIdx()), "Text border alpha = ")
	WLet(mKeyName(ProfileIdx()), "Text border color = ")
	WLet(mKeyName(ProfileIdx()), "Text gradient color 1 = ")
	WLet(mKeyName(ProfileIdx()), "Text gradient color 2 = ")
	WLet(mKeyName(ProfileIdx()), "Text color index = ")
	WLet(mKeyName(ProfileIdx()), "Text gradient mode = ")
	
	mSetDayStart = ProfileIdx()
	WLet(mKeyName(ProfileIdx(mSetDayStart)), WStr("[Day]"))
	
	WLet(mKeyName(ProfileIdx()), "Day Left = ")
	WLet(mKeyName(ProfileIdx()), "Day Top = ")
	WLet(mKeyName(ProfileIdx()), "Day Width = ")
	WLet(mKeyName(ProfileIdx()), "Day Height = ")
	WLet(mKeyName(ProfileIdx()), "Day text font = ")
	WLet(mKeyName(ProfileIdx()), "Day fore color focus = ")
	WLet(mKeyName(ProfileIdx()), "Day fore color year = ")
	WLet(mKeyName(ProfileIdx()), "Day fore color month = ")
	WLet(mKeyName(ProfileIdx()), "Day fore color day = ")
	WLet(mKeyName(ProfileIdx()), "Day fore color week = ")
	WLet(mKeyName(ProfileIdx()), "Day split = ")
	WLet(mKeyName(ProfileIdx()), "Day style index = ")
	WLet(mKeyName(ProfileIdx()), "Day tray enabled = ")
	WLet(mKeyName(ProfileIdx()), "Day back color focus = ")
	WLet(mKeyName(ProfileIdx()), "Day back color year = ")
	WLet(mKeyName(ProfileIdx()), "Day back color month = ")
	WLet(mKeyName(ProfileIdx()), "Day back color day = ")
	WLet(mKeyName(ProfileIdx()), "Day back color week = ")
	WLet(mKeyName(ProfileIdx()), "Day back alpha focus = ")
	WLet(mKeyName(ProfileIdx()), "Day back alpha year = ")
	WLet(mKeyName(ProfileIdx()), "Day back alpha month = ")
	WLet(mKeyName(ProfileIdx()), "Day back alpha day = ")
	WLet(mKeyName(ProfileIdx()), "Day back alpha week = ")
	WLet(mKeyName(ProfileIdx()), "Day background enabled = ")
	WLet(mKeyName(ProfileIdx()), "Day background file = ")
	WLet(mKeyName(ProfileIdx()), "Day background alpha = ")
	WLet(mKeyName(ProfileIdx()), "Day background blur = ")
	WLet(mKeyName(ProfileIdx()), "Day panel enabled = ")
	WLet(mKeyName(ProfileIdx()), "Day panel color = ")
	WLet(mKeyName(ProfileIdx()), "Day panel alpha = ")
	WLet(mKeyName(ProfileIdx()), "Day outline enabled = ")
	WLet(mKeyName(ProfileIdx()), "Day outline size = ")
	WLet(mKeyName(ProfileIdx()), "Day outline color = ")
	WLet(mKeyName(ProfileIdx()), "Day outline alpha = ")
	
	mSetMonthStart = ProfileIdx()
	WLet(mKeyName(ProfileIdx(mSetMonthStart)), WStr("[Month]"))
	
	WLet(mKeyName(ProfileIdx()), "Month Left = ")
	WLet(mKeyName(ProfileIdx()), "Month Top = ")
	WLet(mKeyName(ProfileIdx()), "Month Width = ")
	WLet(mKeyName(ProfileIdx()), "Month Height = ")
	WLet(mKeyName(ProfileIdx()), "Month show controls = ")
	WLet(mKeyName(ProfileIdx()), "Month show weeks = ")
	WLet(mKeyName(ProfileIdx()), "Month tray enabled = ")
	WLet(mKeyName(ProfileIdx()), "Month back color focus = ")
	WLet(mKeyName(ProfileIdx()), "Month back color control = ")
	WLet(mKeyName(ProfileIdx()), "Month back color week = ")
	WLet(mKeyName(ProfileIdx()), "Month back color day = ")
	WLet(mKeyName(ProfileIdx()), "Month back alpha focus = ")
	WLet(mKeyName(ProfileIdx()), "Month back alpha control = ")
	WLet(mKeyName(ProfileIdx()), "Month back alpha week = ")
	WLet(mKeyName(ProfileIdx()), "Month back alpha day = ")
	WLet(mKeyName(ProfileIdx()), "Month text font = ")
	WLet(mKeyName(ProfileIdx()), "Month fore color focus = ")
	WLet(mKeyName(ProfileIdx()), "Month fore color control = ")
	WLet(mKeyName(ProfileIdx()), "Month fore color week = ")
	WLet(mKeyName(ProfileIdx()), "Month fore color day = ")
	WLet(mKeyName(ProfileIdx()), "Month fore color select = ")
	WLet(mKeyName(ProfileIdx()), "Month fore color today = ")
	WLet(mKeyName(ProfileIdx()), "Month fore color holiday = ")
	WLet(mKeyName(ProfileIdx()), "Month background enabled = ")
	WLet(mKeyName(ProfileIdx()), "Month background file = ")
	WLet(mKeyName(ProfileIdx()), "Month background alpha = ")
	WLet(mKeyName(ProfileIdx()), "Month background blur = ")
	WLet(mKeyName(ProfileIdx()), "Month panel enabled = ")
	WLet(mKeyName(ProfileIdx()), "Month panel color = ")
	WLet(mKeyName(ProfileIdx()), "Month panel alpha = ")
	WLet(mKeyName(ProfileIdx()), "Month outline enabled = ")
	WLet(mKeyName(ProfileIdx()), "Month outline size = ")
	WLet(mKeyName(ProfileIdx()), "Month outline color = ")
	WLet(mKeyName(ProfileIdx()), "Month outline alpha = ")
	
	mSetSpeechStart = ProfileIdx()
	WLet(mKeyName(ProfileIdx(mSetSpeechStart)), WStr("[Speech]"))
	WLet(mKeyName(ProfileIdx()), "Announce freequency = ")
	WLet(mKeyName(ProfileIdx()), "Voice = ")
	WLet(mKeyName(ProfileIdx()), "Audio = ")
	
	Dim i As Integer
	For i = 0 To mKeyCount
		mKeyNameLen(i) = Len(*mKeyName(i))
	Next
End Sub

Private Sub frmClockType.ProfileRelease()
	Erase mKeyNameLen
	ArrayDeallocate(mKeyName())
	ArrayDeallocate(mKeyValDef())
	ArrayDeallocate(mKeyValue())
	If mProfileName Then Deallocate(mProfileName)
	If mAppPath Then Deallocate(mAppPath)
End Sub

Private Sub frmClockType.Profile2Clock(sKeyValue() As WString Ptr)
	ProfileIdx(mSetMainStart)
	If *sKeyValue(ProfileIdx()) = "" Then Exit Sub
	
	ProfileIdx(mSetMainStart)
	With mRectMain
		.Left = CLng(*sKeyValue(ProfileIdx()))
		.Top = CLng(*sKeyValue(ProfileIdx()))
		.Right = CLng(*sKeyValue(ProfileIdx()))
		.Bottom = CLng(*sKeyValue(ProfileIdx()))
	End With
	If mnuAlwaysOnTop.Checked <> CBool(*sKeyValue(ProfileIdx())) Then mnuMenu_Click(mnuAlwaysOnTop)
	If mnuClickThrough.Checked <> CBool(*sKeyValue(ProfileIdx())) Then mnuMenu_Click(mnuClickThrough)
	If CBool(*sKeyValue(ProfileIdx())) Then mnuMenu_Click(mnuAnalogEnabled)
	If CBool(*sKeyValue(ProfileIdx())) Then mnuMenu_Click(mnuTextEnabled)
	mShowDay = CBool(*sKeyValue(ProfileIdx()))
	mShowMonth = CBool(*sKeyValue(ProfileIdx()))
	mTransparent = CBool(*sKeyValue(ProfileIdx()))
	mOpacity = CInt(*sKeyValue(ProfileIdx()))
	If mnuLocateSticky.Checked <> CBool(*sKeyValue(ProfileIdx())) Then mnuMenu_Click(mnuLocateSticky)
	If mnuHide.Checked <> CBool(*sKeyValue(ProfileIdx())) Then mnuMenu_Click(mnuTextEnabled)
	If mnuProfileSaveOnExit.Checked <> CBool(*sKeyValue(ProfileIdx())) Then mnuMenu_Click(mnuProfileSaveOnExit)
	
	'ProfileIdx(mSetAnalogStart)
	'With mRectAnalog
	'	.Left = CInt(*sKeyValue(ProfileIdx()))
	'	.Top = CInt(*sKeyValue(ProfileIdx()))
	'	.Right = CInt(*sKeyValue(ProfileIdx()))
	'	.Bottom = CInt(*sKeyValue(ProfileIdx()))
	'End With
	ProfileIdx(mSetAnalogStart)
	mAnalogClock.mBackEnabled = CBool(*sKeyValue(ProfileIdx()))
	mAnalogClock.FileName = FullNameFromFile(*sKeyValue(ProfileIdx()))
	mAnalogClock.mBackAlpha = CSng(*sKeyValue(ProfileIdx()))
	mAnalogClock.mBackBlur = CInt(*sKeyValue(ProfileIdx()))
	mAnalogClock.mPanelEnabled = CBool(*sKeyValue(ProfileIdx()))
	mAnalogClock.mPanelColor = CULng(*sKeyValue(ProfileIdx()))
	mAnalogClock.mPanelAlpha = CULng(*sKeyValue(ProfileIdx()))
	mAnalogClock.mOutlineEnabled = CBool(*sKeyValue(ProfileIdx()))
	mAnalogClock.mOutlineSize = CSng(*sKeyValue(ProfileIdx()))
	mAnalogClock.mOutlineColor = CULng(*sKeyValue(ProfileIdx()))
	mAnalogClock.mOutlineAlpha = CULng(*sKeyValue(ProfileIdx()))
	mAnalogClock.mTrayEnabled = CBool(*sKeyValue(ProfileIdx()))
	mAnalogClock.mTrayFaceColor1 = CULng(*sKeyValue(ProfileIdx()))
	mAnalogClock.mTrayFaceAlpha1 = CULng(*sKeyValue(ProfileIdx()))
	mAnalogClock.mTrayFaceColor2 = CULng(*sKeyValue(ProfileIdx()))
	mAnalogClock.mTrayFaceAlpha2 = CULng(*sKeyValue(ProfileIdx()))
	mAnalogClock.mTrayEdgeColor1 = CULng(*sKeyValue(ProfileIdx()))
	mAnalogClock.mTrayEdgeAlpha1 = CULng(*sKeyValue(ProfileIdx()))
	mAnalogClock.mTrayEdgeColor2 = CULng(*sKeyValue(ProfileIdx()))
	mAnalogClock.mTrayEdgeAlpha2 = CULng(*sKeyValue(ProfileIdx()))
	mAnalogClock.mTrayShadowColor = CULng(*sKeyValue(ProfileIdx()))
	mAnalogClock.mTrayShadowAlpha = CULng(*sKeyValue(ProfileIdx()))
	mAnalogClock.mTrayAlpha = CULng(*sKeyValue(ProfileIdx()))
	mAnalogClock.mTrayBlur = CInt(*sKeyValue(ProfileIdx()))
	mAnalogClock.mScaleEnabled = CBool(*sKeyValue(ProfileIdx()))
	mAnalogClock.mScaleColor = CULng(*sKeyValue(ProfileIdx()))
	mAnalogClock.mScaleAlpha = CULng(*sKeyValue(ProfileIdx()))
	mAnalogClock.mScaleBlur = CInt(*sKeyValue(ProfileIdx()))
	mAnalogClock.mHandEnabled = CBool(*sKeyValue(ProfileIdx()))
	mAnalogClock.mHandSecondEnabled = CBool(*sKeyValue(ProfileIdx()))
	mAnalogClock.mHandSecondColor = CULng(*sKeyValue(ProfileIdx()))
	mAnalogClock.mHandMinuteEnabled = CBool(*sKeyValue(ProfileIdx()))
	mAnalogClock.mHandMinuteColor = CULng(*sKeyValue(ProfileIdx()))
	mAnalogClock.mHandHourEnabled = CBool(*sKeyValue(ProfileIdx()))
	mAnalogClock.mHandHourColor = CULng(*sKeyValue(ProfileIdx()))
	mAnalogClock.mHandAlpha = CULng(*sKeyValue(ProfileIdx()))
	mAnalogClock.mHandBlur = CInt(*sKeyValue(ProfileIdx()))
	mAnalogClock.mTextEnabled = CBool(*sKeyValue(ProfileIdx()))
	mAnalogClock.mTextSize = CSng(*sKeyValue(ProfileIdx()))
	WLet(mAnalogClock.mTextFont, *sKeyValue(ProfileIdx()))
	mAnalogClock.mTextBold = CBool(*sKeyValue(ProfileIdx()))
	mAnalogClock.mTextColor = CULng(*sKeyValue(ProfileIdx()))
	mAnalogClock.mTextOffsetX = CSng(*sKeyValue(ProfileIdx()))
	mAnalogClock.mTextOffsetY = CSng(*sKeyValue(ProfileIdx()))
	WLet(mAnalogClock.mTextFormat, *sKeyValue(ProfileIdx()))
	mAnalogClock.mTextAlpha = CULng(*sKeyValue(ProfileIdx()))
	mAnalogClock.mTextBlur = CInt(*sKeyValue(ProfileIdx()))
	
	ProfileIdx(mSetTextStart)
	'With mRectText
	'	.Left = CInt(*sKeyValue(ProfileIdx()))
	'	.Top = CInt(*sKeyValue(ProfileIdx()))
	'	.Right = CInt(*sKeyValue(ProfileIdx()))
	'	.Bottom = CInt(*sKeyValue(ProfileIdx()))
	'End If
	mTextClock.mShowSecond = CBool(*sKeyValue(ProfileIdx()))
	mTextClock.mBlinkColon = CBool(*sKeyValue(ProfileIdx()))
	mTextClock.mShadowEnabled = CBool(*sKeyValue(ProfileIdx()))
	mTextClock.mBackEnabled = CBool(*sKeyValue(ProfileIdx()))
	mTextClock.FileName = FullNameFromFile(*sKeyValue(ProfileIdx()))
	mTextClock.mBackAlpha = CULng(*sKeyValue(ProfileIdx()))
	mTextClock.mBackBlur = CInt(*sKeyValue(ProfileIdx()))
	mTextClock.mPanelEnabled = CBool(*sKeyValue(ProfileIdx()))
	mTextClock.mPanelColor = CULng(*sKeyValue(ProfileIdx()))
	mTextClock.mPanelAlpha = CULng(*sKeyValue(ProfileIdx()))
	mTextClock.mOutlineEnabled = CBool(*sKeyValue(ProfileIdx()))
	mTextClock.mOutlineSize = CSng(*sKeyValue(ProfileIdx()))
	mTextClock.mOutlineAlpha = CULng(*sKeyValue(ProfileIdx()))
	mTextClock.mOutlineColor = CULng(*sKeyValue(ProfileIdx()))
	WLet(mTextClock.mFontName, *sKeyValue(ProfileIdx()))
	mTextClock.mFontStyle = CLng(*sKeyValue(ProfileIdx()))
	mTextAlpha1 = CULng(*sKeyValue(ProfileIdx()))
	mTextAlpha2 = CULng(*sKeyValue(ProfileIdx()))
	mTextClock.mTextBlur = CInt(*sKeyValue(ProfileIdx()))
	mTextClock.mBorderEnabled = CBool(*sKeyValue(ProfileIdx()))
	mTextClock.mBorderSize = CDbl(*sKeyValue(ProfileIdx()))
	mTextClock.mBorderAlpha = CULng(*sKeyValue(ProfileIdx()))
	mTextClock.mBorderColor = CULng(*sKeyValue(ProfileIdx()))
	mTextColor1 = CULng(*sKeyValue(ProfileIdx()))
	mTextColor2 = CULng(*sKeyValue(ProfileIdx()))
	IndexOfTextColor = CInt(*sKeyValue(ProfileIdx()))
	IndexOfGradientMode = CLng(*sKeyValue(ProfileIdx()))
	
	ProfileIdx(mSetDayStart)
	If *sKeyValue(ProfileIdx()) <> "" Then
		ProfileIdx(mSetDayStart)
		With mRectDay
			.Left = CLng(*sKeyValue(ProfileIdx()))
			.Top = CLng(*sKeyValue(ProfileIdx()))
			.Right = CLng(*sKeyValue(ProfileIdx()))
			.Bottom = CLng(*sKeyValue(ProfileIdx()))
		End With
		WLet(frmDay.mDay.mFontName, *sKeyValue(ProfileIdx()))
		frmDay.mDay.mForeColor(DayFocus) = CULng(*sKeyValue(ProfileIdx()))
		frmDay.mDay.mForeColor(DayYear) = CULng(*sKeyValue(ProfileIdx()))
		frmDay.mDay.mForeColor(DayMonth) = CULng(*sKeyValue(ProfileIdx()))
		frmDay.mDay.mForeColor(DayDay) = CULng(*sKeyValue(ProfileIdx()))
		frmDay.mDay.mForeColor(DayWeek) = CULng(*sKeyValue(ProfileIdx()))
		frmDay.mDay.mSplitXScale = CSng(*sKeyValue(ProfileIdx()))
		frmDay.mDay.mShowStyle = CInt(*sKeyValue(ProfileIdx()))
		frmDay.mDay.mTrayEnabled = CBool(*sKeyValue(ProfileIdx()))
		frmDay.mDay.mBackColor(DayFocus) = CULng(*sKeyValue(ProfileIdx()))
		frmDay.mDay.mBackColor(DayYear) = CULng(*sKeyValue(ProfileIdx()))
		frmDay.mDay.mBackColor(DayMonth) = CULng(*sKeyValue(ProfileIdx()))
		frmDay.mDay.mBackColor(DayDay) = CULng(*sKeyValue(ProfileIdx()))
		frmDay.mDay.mBackColor(DayWeek) = CULng(*sKeyValue(ProfileIdx()))
		frmDay.mDay.mBackAlpha(DayFocus) = CULng(*sKeyValue(ProfileIdx()))
		frmDay.mDay.mBackAlpha(DayYear) = CULng(*sKeyValue(ProfileIdx()))
		frmDay.mDay.mBackAlpha(DayMonth) = CULng(*sKeyValue(ProfileIdx()))
		frmDay.mDay.mBackAlpha(DayDay) = CULng(*sKeyValue(ProfileIdx()))
		frmDay.mDay.mBackAlpha(DayWeek) = CULng(*sKeyValue(ProfileIdx()))
		frmDay.mDay.mBackEnabled = CBool(*sKeyValue(ProfileIdx()))
		frmDay.mDay.mBackImage.ImageFile = FullNameFromFile(*sKeyValue(ProfileIdx()))
		frmDay.mDay.mBackAlpha(DayImageFile) = CULng(*sKeyValue(ProfileIdx()))
		frmDay.mDay.mBackBlur = CInt(*sKeyValue(ProfileIdx()))
		frmDay.mDay.mPanelEnabled = CBool(*sKeyValue(ProfileIdx()))
		frmDay.mDay.mBackColor(DayPanel) = CULng(*sKeyValue(ProfileIdx()))
		frmDay.mDay.mBackAlpha(DayPanel) = CULng(*sKeyValue(ProfileIdx()))
		frmDay.mDay.mOutlineEnabled = CBool(*sKeyValue(ProfileIdx()))
		frmDay.mDay.mOutlineSize = CSng(*sKeyValue(ProfileIdx()))
		frmDay.mDay.mForeColor(DayPanel) = CULng(*sKeyValue(ProfileIdx()))
		frmDay.mDay.mForeAlpha(DayPanel) = CULng(*sKeyValue(ProfileIdx()))
	End If
	
	ProfileIdx(mSetMonthStart)
	If *sKeyValue(ProfileIdx()) <> "" Then
		ProfileIdx(mSetMonthStart)
		With mRectMonth
			.Left = CLng(*sKeyValue(ProfileIdx()))
			.Top = CLng(*sKeyValue(ProfileIdx()))
			.Right = CLng(*sKeyValue(ProfileIdx()))
			.Bottom = CLng(*sKeyValue(ProfileIdx()))
		End With
		frmMonth.mMonth.mShowControls = CBool(*sKeyValue(ProfileIdx()))
		frmMonth.mMonth.mShowWeeks = CBool(*sKeyValue(ProfileIdx()))
		frmMonth.mMonth.mTrayEnabled = CBool(*sKeyValue(ProfileIdx()))
		frmMonth.mMonth.mBackColor(MonthFocus) = CULng(*sKeyValue(ProfileIdx()))
		frmMonth.mMonth.mBackColor(MonthControl) = CULng(*sKeyValue(ProfileIdx()))
		frmMonth.mMonth.mBackColor(MonthWeek) = CULng(*sKeyValue(ProfileIdx()))
		frmMonth.mMonth.mBackColor(MonthDay) = CULng(*sKeyValue(ProfileIdx()))
		frmMonth.mMonth.mBackAlpha(MonthFocus) = CULng(*sKeyValue(ProfileIdx()))
		frmMonth.mMonth.mBackAlpha(MonthControl) = CULng(*sKeyValue(ProfileIdx()))
		frmMonth.mMonth.mBackAlpha(MonthWeek) = CULng(*sKeyValue(ProfileIdx()))
		frmMonth.mMonth.mBackAlpha(MonthDay) = CULng(*sKeyValue(ProfileIdx()))
		WLet(frmMonth.mMonth.mFontName, *sKeyValue(ProfileIdx()))
		frmMonth.mMonth.mForeColor(MonthFocus) = CULng(*sKeyValue(ProfileIdx()))
		frmMonth.mMonth.mForeColor(MonthControl) = CULng(*sKeyValue(ProfileIdx()))
		frmMonth.mMonth.mForeColor(MonthWeek) = CULng(*sKeyValue(ProfileIdx()))
		frmMonth.mMonth.mForeColor(MonthDay) = CULng(*sKeyValue(ProfileIdx()))
		frmMonth.mMonth.mForeColor(MonthSelect) = CULng(*sKeyValue(ProfileIdx()))
		frmMonth.mMonth.mForeColor(MonthToday) = CULng(*sKeyValue(ProfileIdx()))
		frmMonth.mMonth.mForeColor(MonthHoliday) = CULng(*sKeyValue(ProfileIdx()))
		frmMonth.mMonth.mBackEnabled = CBool(*sKeyValue(ProfileIdx()))
		frmMonth.mMonth.mBackImage.ImageFile = FullNameFromFile(*sKeyValue(ProfileIdx()))
		frmMonth.mMonth.mBackAlpha(MonthImageFile) = CULng(*sKeyValue(ProfileIdx()))
		frmMonth.mMonth.mBackBlur = CInt(*sKeyValue(ProfileIdx()))
		frmMonth.mMonth.mPanelEnabled = CBool(*sKeyValue(ProfileIdx()))
		frmMonth.mMonth.mBackColor(MonthPanel) = CULng(*sKeyValue(ProfileIdx()))
		frmMonth.mMonth.mBackAlpha(MonthPanel) = CULng(*sKeyValue(ProfileIdx()))
		frmMonth.mMonth.mOutlineEnabled = CBool(*sKeyValue(ProfileIdx()))
		frmMonth.mMonth.mOutlineSize = CSng(*sKeyValue(ProfileIdx()))
		frmMonth.mMonth.mForeColor(MonthPanel) = CULng(*sKeyValue(ProfileIdx()))
		frmMonth.mMonth.mForeAlpha(MonthPanel) = CULng(*sKeyValue(ProfileIdx()))
	End If
	
	ProfileIdx(mSetSpeechStart)
	IndexOfAnnouce = CInt(*sKeyValue(ProfileIdx()))
	IndexOfVoice = *sKeyValue(ProfileIdx())
	IndexOfAudio = *sKeyValue(ProfileIdx())
End Sub

Private Sub frmClockType.ProfileFrmClock(sKeyValue() As WString Ptr)
	ProfileIdx(mSetMainStart)
	WLet(sKeyValue(ProfileIdx()), "" & Left)
	WLet(sKeyValue(ProfileIdx()), "" & Top)
	WLet(sKeyValue(ProfileIdx()), "" & Width)
	WLet(sKeyValue(ProfileIdx()), "" & Height)
	WLet(sKeyValue(ProfileIdx()), "" & mnuAlwaysOnTop.Checked)
	WLet(sKeyValue(ProfileIdx()), "" & mnuClickThrough.Checked)
	WLet(sKeyValue(ProfileIdx()), "" & mnuAnalogEnabled.Checked)
	WLet(sKeyValue(ProfileIdx()), "" & mnuTextEnabled.Checked)
	WLet(sKeyValue(ProfileIdx()), "" & mnuDayEnabled.Checked) 'mShowDay)
	WLet(sKeyValue(ProfileIdx()), "" & mnuMonthEnabled.Checked) 'mShowMonth)
	WLet(sKeyValue(ProfileIdx()), "" & mnuTransparent.Checked) 'mTransparent)
	WLet(sKeyValue(ProfileIdx()), "" & mOpacity)
	WLet(sKeyValue(ProfileIdx()), "" & mnuLocateSticky.Checked)
	WLet(sKeyValue(ProfileIdx()), "" & mnuHide.Checked)
	WLet(sKeyValue(ProfileIdx()), "" & mnuProfileSaveOnExit.Checked)
	
	ProfileIdx(mSetAnalogStart)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mBackEnabled)
	WLet(sKeyValue(ProfileIdx()), FullName2File(mAnalogClock.FileName))
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mBackAlpha)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mBackBlur)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mPanelEnabled)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mPanelColor)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mPanelAlpha)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mOutlineEnabled)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mOutlineSize)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mOutlineColor)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mOutlineAlpha)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mTrayEnabled)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mTrayFaceColor1)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mTrayFaceAlpha1)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mTrayFaceColor2)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mTrayFaceAlpha2)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mTrayEdgeColor1)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mTrayEdgeAlpha1)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mTrayEdgeColor2)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mTrayEdgeAlpha2)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mTrayShadowColor)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mTrayShadowAlpha)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mTrayAlpha)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mTrayBlur)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mScaleEnabled)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mScaleColor)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mScaleAlpha)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mScaleBlur)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mHandEnabled)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mHandSecondEnabled)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mHandSecondColor)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mHandMinuteEnabled)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mHandMinuteColor)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mHandHourEnabled)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mHandHourColor)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mHandAlpha)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mHandBlur)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mTextEnabled)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mTextSize)
	WLet(sKeyValue(ProfileIdx()), *mAnalogClock.mTextFont)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mTextBold)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mTextColor)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mTextOffsetX)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mTextOffsetY)
	WLet(sKeyValue(ProfileIdx()), *mAnalogClock.mTextFormat)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mTextAlpha)
	WLet(sKeyValue(ProfileIdx()), "" & mAnalogClock.mTextBlur)
	
	ProfileIdx(mSetTextStart)
	WLet(sKeyValue(ProfileIdx()), "" & mTextClock.mShowSecond)
	WLet(sKeyValue(ProfileIdx()), ""& mTextClock.mBlinkColon)
	WLet(sKeyValue(ProfileIdx()), ""& mTextClock.mShadowEnabled)
	WLet(sKeyValue(ProfileIdx()), ""& mTextClock.mBackEnabled)
	WLet(sKeyValue(ProfileIdx()), FullName2File(mTextClock.FileName))
	WLet(sKeyValue(ProfileIdx()), ""& mTextClock.mBackAlpha)
	WLet(sKeyValue(ProfileIdx()), ""& mTextClock.mBackBlur)
	WLet(sKeyValue(ProfileIdx()), "" & mTextClock.mPanelEnabled)
	WLet(sKeyValue(ProfileIdx()), "" & mTextClock.mPanelColor)
	WLet(sKeyValue(ProfileIdx()), "" & mTextClock.mPanelAlpha)
	WLet(sKeyValue(ProfileIdx()), "" & mTextClock.mOutlineEnabled)
	WLet(sKeyValue(ProfileIdx()), "" & mTextClock.mOutlineSize)
	WLet(sKeyValue(ProfileIdx()), "" & mTextClock.mOutlineAlpha)
	WLet(sKeyValue(ProfileIdx()), "" & mTextClock.mOutlineColor)
	WLet(sKeyValue(ProfileIdx()), *mTextClock.mFontName)
	WLet(sKeyValue(ProfileIdx()), ""& mTextClock.mFontStyle)
	WLet(sKeyValue(ProfileIdx()), ""& mTextAlpha1)
	WLet(sKeyValue(ProfileIdx()), ""& mTextAlpha2)
	WLet(sKeyValue(ProfileIdx()), ""& mTextClock.mTextBlur)
	WLet(sKeyValue(ProfileIdx()), ""& mTextClock.mBorderEnabled)
	WLet(sKeyValue(ProfileIdx()), ""& mTextClock.mBorderSize)
	WLet(sKeyValue(ProfileIdx()), ""& mTextClock.mBorderAlpha)
	WLet(sKeyValue(ProfileIdx()), ""& mTextClock.mBorderColor)
	WLet(sKeyValue(ProfileIdx()), ""& mTextColor1)
	WLet(sKeyValue(ProfileIdx()), ""& mTextColor2)
	WLet(sKeyValue(ProfileIdx()), ""& IndexOfTextColor)
	WLet(sKeyValue(ProfileIdx()), "" & IndexOfGradientMode)
	
	ProfileIdx(mSetDayStart)
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.Left)
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.Top)
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.Width)
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.Height)
	WLet(sKeyValue(ProfileIdx()), *frmDay.mDay.mFontName)
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.mDay.mForeColor(DayFocus))
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.mDay.mForeColor(DayYear))
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.mDay.mForeColor(DayMonth))
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.mDay.mForeColor(DayDay))
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.mDay.mForeColor(DayWeek))
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.mDay.mSplitXScale)
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.mDay.mShowStyle)
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.mDay.mTrayEnabled)
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.mDay.mBackColor(DayFocus))
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.mDay.mBackColor(DayYear))
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.mDay.mBackColor(DayMonth))
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.mDay.mBackColor(DayDay))
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.mDay.mBackColor(DayWeek))
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.mDay.mBackAlpha(DayFocus))
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.mDay.mBackAlpha(DayYear))
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.mDay.mBackAlpha(DayMonth))
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.mDay.mBackAlpha(DayDay))
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.mDay.mBackAlpha(DayWeek))
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.mDay.mBackEnabled)
	WLet(sKeyValue(ProfileIdx()), FullName2File(frmDay.mDay.mBackImage.ImageFile))
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.mDay.mBackAlpha(DayImageFile))
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.mDay.mBackBlur)
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.mDay.mPanelEnabled)
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.mDay.mBackColor(DayPanel))
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.mDay.mBackAlpha(DayPanel))
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.mDay.mOutlineEnabled)
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.mDay.mOutlineSize)
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.mDay.mForeColor(DayPanel))
	WLet(sKeyValue(ProfileIdx()), "" & frmDay.mDay.mForeAlpha(DayPanel))
	
	ProfileIdx(mSetMonthStart)
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.Left)
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.Top)
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.Width)
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.Height)
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mShowControls)
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mShowWeeks)
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mTrayEnabled)
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mBackColor(MonthFocus))
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mBackColor(MonthControl))
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mBackColor(MonthWeek))
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mBackColor(MonthDay))
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mBackAlpha(MonthFocus))
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mBackAlpha(MonthControl))
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mBackAlpha(MonthWeek))
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mBackAlpha(MonthDay))
	WLet(sKeyValue(ProfileIdx()), *frmMonth.mMonth.mFontName)
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mForeColor(MonthFocus))
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mForeColor(MonthControl))
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mForeColor(MonthWeek))
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mForeColor(MonthDay))
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mForeColor(MonthSelect))
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mForeColor(MonthToday))
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mForeColor(MonthHoliday))
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mBackEnabled)
	WLet(sKeyValue(ProfileIdx()), FullName2File(frmMonth.mMonth.mBackImage.ImageFile))
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mBackAlpha(MonthImageFile))
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mBackBlur)
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mPanelEnabled)
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mBackColor(MonthPanel))
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mBackAlpha(MonthPanel))
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mOutlineEnabled)
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mOutlineSize)
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mForeColor(MonthPanel))
	WLet(sKeyValue(ProfileIdx()), "" & frmMonth.mMonth.mForeAlpha(MonthPanel))
	
	ProfileIdx(mSetSpeechStart)
	WLet(sKeyValue(ProfileIdx()), "" & IndexOfAnnouce)
	WLet(sKeyValue(ProfileIdx()), "" & IndexOfVoice)
	WLet(sKeyValue(ProfileIdx()), "" & IndexOfAudio)
End Sub

Private Function frmClockType.ProfileLoad(sFileName As WString, sKeyValue() As WString Ptr) As Boolean
	If Dir(sFileName) = "" Then Return False
	Dim s As WString Ptr
	
	'WLet(s, TextFromFile(sFileName))
	TextFromFile(sFileName,s)
	
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
				WLet(sKeyValue(k), Mid(*ss(i), m + mKeyNameLen(k), l - mKeyNameLen(k)))
				Exit For
			End If
		Next
	Next
	
	ArrayDeallocate(ss())
	Deallocate(s)
	Return True
End Function

Private Sub frmClockType.ProfileSave(sFileName As WString, sKeyValue() As WString Ptr)
	Dim ss() As WString Ptr
	Dim i As Integer
	ReDim ss(mKeyCount)
	
	ProfileFrmClock(sKeyValue())
	
	For i = 0 To mKeyCount
		WLet(ss(i), Format(i, "000") & ". " & *mKeyName(i) & *sKeyValue(i))
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
		Notify(!"VisualFBEditor GDIP Clock\0", *s)
	#endif
	WDeAllocate(s)
End Sub

Private Sub frmClockType.SpeechInit()
	#ifdef __USE_WINAPI__
		' Create an instance of the SpVoice object
		Dim classID As IID, riid As IID
		CLSIDFromString(CLSID_SpVoice, @classID)
		IIDFromString(IID_ISpVoice, @riid)
		CoCreateInstance(@classID, NULL, CLSCTX_ALL, @riid, @pSpVoice)
		If pSpVoice = NULL Then Exit Sub
		
		mnuAnnounce.Enabled = True
		
		' Set the object of interest to word boundaries
		pSpVoice->SetInterest(SPFEI(SPEI_WORD_BOUNDARY), SPFEI(SPEI_WORD_BOUNDARY))
		' Set the handle of the window that will receive the MSG_SAPI_EVENT message
		pSpVoice->SetNotifyWindowMessage(Handle, MSG_SAPI_EVENT, 0, 0)
		
		Dim pVoice As ISpObjectToken Ptr
		Dim pAudio As ISpObjectToken Ptr
		Dim pTokenCategory As ISpObjectTokenCategory Ptr
		Dim pTokenEnum As IEnumSpObjectTokens Ptr
		
		Dim pTokenItem As ISpObjectToken Ptr
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
	Select Case v
	Case 0
		Left = 0
	Case 1
		Left = (mScreenWidth / xdpi - Width) / 2
	Case 2
		Left = mScreenWidth / xdpi - Width
	End Select
End Property
Private Property frmClockType.IndexOfLocateH() As Integer
	If mnuLocateLeft.Checked Then Return 0
	If mnuLocateHorizontalMiddle.Checked Then Return 1
	If mnuLocateRight.Checked Then Return 2
	Return 0
End Property
Private Property frmClockType.IndexOfLocateV(v As Integer)
	Select Case v
	Case 0
		Top = 0
	Case 1
		Top = (mScreenHeight / ydpi - Height) / 2
	Case 2
		Top = mScreenHeight / ydpi - Height
	End Select
End Property
Private Property frmClockType.IndexOfLocateV() As Integer
	If mnuLocateTop.Checked Then Return 0
	If mnuLocateVerticalMiddle.Checked Then Return 1
	If mnuLocateBottom.Checked Then Return 2
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
	mnuAnnounce0.Checked = False
	mnuAnnounce1.Checked = False
	mnuAnnounce2.Checked = False
	mnuAnnounce3.Checked = False
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
	Select Case Sender.Name
	Case "mnuAlwaysOnTop"
		Sender.Checked = Not Sender.Checked
		FormStyle = IIf(Sender.Checked, FormStyles.fsStayOnTop, FormStyles.fsNormal)
	Case "mnuClickThrough"
		Sender.Checked = Not Sender.Checked
		SetWindowLong(Handle, GWL_EXSTYLE, IIf(Sender.Checked, GetWindowLong(Handle, GWL_EXSTYLE) Or WS_EX_TRANSPARENT, GetWindowLong(Handle, GWL_EXSTYLE) And Not WS_EX_TRANSPARENT))
	Case "mnuAutoStart"
		Sender.Checked = Not Sender.Checked
		AutoStartReg Sender.Checked
		CheckAutoStart
		
	Case "mnuAnalogEnabled"
		Sender.Checked = True
		mnuAnalogSetting.Enabled = True
		mnuTextEnabled.Checked = False
		mnuTextSetting.Enabled = False
		mnuMenu_Click(mnuAspectRatio)
		Form_Resize(This, Width, Height)
	Case "mnuTextEnabled"
		Sender.Checked = True
		mnuTextSetting.Enabled = True
		mnuAnalogEnabled.Checked = False
		mnuAnalogSetting.Enabled = False
		mnuMenu_Click(mnuAspectRatio)
		Form_Resize(This, Width, Height)
	Case "mnuDayEnabled"
		Sender.Checked = Not Sender.Checked
		If Sender.Checked Then
			If mnuLocateSticky.Checked Then
				frmDay.Show(This)
			Else
				frmDay.Show()
			End If
		Else
			frmDay.CloseForm()
		End If
		mnuDaySetting.Enabled = Sender.Checked
		Form_Resize(This, Width, Height)
	Case "mnuMonthEnabled"
		Sender.Checked = Not Sender.Checked
		If Sender.Checked Then
			If mnuLocateSticky.Checked Then
				frmMonth.Show(This)
			Else
				frmMonth.Show()
			End If
		Else
			frmMonth.CloseForm()
		End If
		mnuMonthSetting.Enabled = Sender.Checked
		Form_Resize(This, Width, Height)
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
		mnuTransparent.Checked = Sender.Checked
		Transparent(Sender.Checked)
		mnuMenu_Click(mnuAspectRatio)
		If frmDay.Handle Then frmDay.Transparent(Sender.Checked)
		If frmMonth.Handle Then frmMonth.Transparent(Sender.Checked)
	Case "mnuOpacityValue"
		Dim As String s = InputBox("GDIP Clock", "Opacity", "&H" & Hex(mOpacity), , , Handle)
		mOpacity = CInt(s)
		Form_Resize(This, Width, Height)
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
	Case "mnuLocateTop"
		IndexOfLocateV = 0
	Case "mnuLocateVerticalMiddle"
		IndexOfLocateV = 1
	Case "mnuLocateBottom"
		IndexOfLocateV = 2
		
	Case "mnuLocateSticky"
		Sender.Checked = Not Sender.Checked
		Form_Resize(This, Width, Height)
		
	Case "mnuProfileSaveOnExit"
		Sender.Checked = Not Sender.Checked
	Case "mnuProfileResetDefault"
		TimerComponent1.Enabled = False
		Hide()
		If frmDay.Handle Then frmDay.CloseForm
		If frmMonth.Handle Then frmMonth.CloseForm
		Profile2Clock(mKeyValDef())
		mTextClock.TextAlpha(mTextAlpha1, mTextAlpha2)
		If mRectMain.Right And mRectMain.Bottom Then Move(mRectMain.Left, mRectMain.Top, mRectMain.Right, mRectMain.Bottom)
		mnuMenu_Click(mnuAspectRatio)
		Show()
	Case "mnuProfileSave"
		ProfileSave(*mProfileName, mKeyValue())
		Form_Resize(This, Width, Height)
		FileName2Menu(*mProfileExt)
		Notify(!"VisualFBEditor GDIP Clock\0", !"Profile saved.\r\n" & *mProfileName)
	Case "mnuProfileSaveAs"
		SaveFileDialog1.FileName = *mProfileName
		SaveFileDialog1.Filter = "gdipClock Profile|*" & *mProfileExt
		SaveFileDialog1.FilterIndex = 1
		If SaveFileDialog1.Execute Then
			WLet(mProfileName, SaveFileDialog1.FileName)
			If Dir(*mProfileName) <> "" Then
				If MsgBox(*mProfileName & !"\r\nAre you sure you want to overwrite it?", "The profile already exists.", , ButtonsTypes.btYesNo) <> MessageResult.mrYes Then Exit Sub
			End If
			ProfileSave(*mProfileName, mKeyValue())
			Form_Resize(This, Width, Height)
			FileName2Menu(*mProfileExt)
		End If
	Case "mnuProfileList"
		TimerComponent1.Enabled = False
		Hide()
		If frmDay.Handle Then frmDay.CloseForm
		If frmMonth.Handle Then frmMonth.CloseForm
		WLet(mProfileName, *mAppPath & Sender.Caption & *mProfileExt)
		If ProfileLoad(*mProfileName, mKeyValue()) Then
			Profile2Clock(mKeyValue())
			Notify(!"VisualFBEditor GDIP Clock\0", !"Profile loaded.\r\n" & *mProfileName)
		End If
		mTextClock.TextAlpha(mTextAlpha1, mTextAlpha2)
		If mRectMain.Right And mRectMain.Bottom Then Move(mRectMain.Left, mRectMain.Top, mRectMain.Right, mRectMain.Bottom)
		Show()
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
	Case "mnuAnalogPanelEnabled"
		mAnalogClock.mPanelEnabled = Not mAnalogClock.mPanelEnabled
		Form_Resize(This, Width, Height)
	Case "mnuAnalogPanelColor"
		ColorDialog1.Color = Color2Gdip(mAnalogClock.mPanelColor)
		If ColorDialog1.Execute() Then
			mAnalogClock.mPanelColor = Color2Gdip(ColorDialog1.Color)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuAnalogPanelAlpha"
		Dim As String s = InputBox("GDIP Clock", "Analog Back Alpha", "&H" & Hex(mAnalogClock.mPanelAlpha), , , Handle)
		mAnalogClock.mPanelAlpha = CInt(s)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogOutlineEnabled"
		mAnalogClock.mOutlineEnabled = Not mAnalogClock.mOutlineEnabled
		Form_Resize(This, Width, Height)
	Case "mnuAnalogOutlineSize"
		Dim As String s = InputBox("GDIP Clock", "Analog Outline Size", "" & mAnalogClock.mOutlineSize, , , Handle)
		mAnalogClock.mOutlineSize = CSng(s)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogOutlineColor"
		ColorDialog1.Color = Color2Gdip(mAnalogClock.mOutlineColor)
		If ColorDialog1.Execute() Then
			mAnalogClock.mOutlineColor = Color2Gdip(ColorDialog1.Color)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuAnalogOutlineAlpha"
		Dim As String s = InputBox("GDIP Clock", "Analog Outline Alpha", "&H" & Hex(mAnalogClock.mOutlineAlpha), , , Handle)
		mAnalogClock.mOutlineAlpha = CInt(s)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogHandAlpha"
		Dim As String s = InputBox("GDIP Clock", "Analog Hand Alpha", "&H" & Hex(mAnalogClock.mHandAlpha), , , Handle)
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
	Case "mnuAnalogTrayFA1"
		Dim As String s = InputBox("GDIP Clock", "Analog Tray Face Alpha 1", "&H" & Hex(mAnalogClock.mTrayFaceAlpha1), , , Handle)
		mAnalogClock.mTrayFaceAlpha1 = CSng(s)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogTrayFA2"
		Dim As String s = InputBox("GDIP Clock", "Analog Tray Face Alpha 2", "&H" & Hex(mAnalogClock.mTrayFaceAlpha2), , , Handle)
		mAnalogClock.mTrayFaceAlpha2 = CSng(s)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogTrayEA1"
		Dim As String s = InputBox("GDIP Clock", "Analog Tray Edge Alpha 1", "&H" & Hex(mAnalogClock.mTrayEdgeAlpha1), , , Handle)
		mAnalogClock.mTrayEdgeAlpha1 = CSng(s)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogTrayEA2"
		Dim As String s = InputBox("GDIP Clock", "Analog Tray Edge Alpha 2", "&H" & Hex(mAnalogClock.mTrayEdgeAlpha2), , , Handle)
		mAnalogClock.mTrayEdgeAlpha2 = CSng(s)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogTraySC"
		ColorDialog1.Color = Color2Gdip(mAnalogClock.mTrayShadowColor)
		If ColorDialog1.Execute() Then
			mAnalogClock.mTrayShadowColor = Color2Gdip(ColorDialog1.Color)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuAnalogTraySA"
		Dim As String s = InputBox("GDIP Clock", "Analog Tray Shadow Alpha", "&H" & Hex(mAnalogClock.mTrayShadowAlpha), , , Handle)
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
		FontDialog1.Font.Bold =  mAnalogClock.mTextBold
		If FontDialog1.Execute Then
			WLet(mAnalogClock.mTextFont, FontDialog1.Font.Name)
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
		Dim As String s = InputBox("GDIP Clock", "Analog Back Alpha", "&H" & Hex(mAnalogClock.mBackAlpha), , , Handle)
		mAnalogClock.mBackAlpha = CSng(s)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogBackBlur"
		Dim As String s = InputBox("GDIP Clock", "Analog Back Blur", "" & mAnalogClock.mBackBlur, , , Handle)
		mAnalogClock.mBackBlur = CInt(s)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogTrayAlpha"
		Dim As String s = InputBox("GDIP Clock", "Analog Tray Alpha", "&H" & Hex(mAnalogClock.mTrayAlpha), , , Handle)
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
		Dim As String s = InputBox("GDIP Clock", "Analog Scale Alpha", "&H" & Hex(mAnalogClock.mScaleAlpha), , , Handle)
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
		Dim As String s = InputBox("GDIP Clock", "Analog Text Alpha", "&H" & Hex(mAnalogClock.mTextAlpha), , , Handle)
		mAnalogClock.mTextAlpha = CInt(s)
		Form_Resize(This, Width, Height)
	Case "mnuAnalogTextBlur"
		Dim As String s = InputBox("GDIP Clock", "Analog Text Blur", "" & mAnalogClock.mTextBlur, , , Handle)
		mAnalogClock.mTextBlur = CInt(s)
		Form_Resize(This, Width, Height)
		
	Case "mnuTextBackEnabled"
		mTextClock.mBackEnabled = Not mTextClock.mBackEnabled
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
		Dim As String s = InputBox("GDIP Clock", "Text Back Alpha", "&H" & Hex(mTextClock.mBackAlpha), , , Handle)
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
			mnuTextFont.Caption = *mTextClock.mFontName & ",\t" & mTextClock.mFontStyle
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
	Case "mnuTextPanelEnabled"
		mTextClock.mPanelEnabled = Not mTextClock.mPanelEnabled
		Form_Resize(This, Width, Height)
	Case "mnuTextPanelAlpha"
		Dim As String s = InputBox("GDIP Clock", "Tray Alpha", "&H" & Hex(mTextClock.mPanelAlpha), , , Handle)
		mTextClock.mPanelAlpha = CInt(s)
		Form_Resize(This, Width, Height)
	Case "mnuTextPanelColor"
		ColorDialog1.Color = Color2Gdip(mTextClock.mPanelColor)
		If ColorDialog1.Execute() Then
			mTextClock.mPanelColor = Color2Gdip(ColorDialog1.Color)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuTextOutlineEnabled"
		mTextClock.mOutlineEnabled = Not mTextClock.mOutlineEnabled
		Form_Resize(This, Width, Height)
	Case "mnuTextOutlineSize"
		Dim As String s = InputBox("GDIP Clock", "Outline size", "" & mTextClock.mOutlineSize, , , Handle)
		mTextClock.mOutlineSize = CSng(s)
		Form_Resize(This, Width, Height)
	Case "mnuTextOutlineColor"
		ColorDialog1.Color = Color2Gdip(mTextClock.mOutlineColor)
		If ColorDialog1.Execute() Then
			mTextClock.mOutlineColor = Color2Gdip(ColorDialog1.Color)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuTextOutlineAlpha"
		Dim As String s = InputBox("GDIP Clock", "Outline Alpha", "&H" & Hex(mTextClock.mOutlineAlpha), , , Handle)
		mTextClock.mOutlineAlpha = CInt(s)
		Form_Resize(This, Width, Height)
	Case "mnuTextBorderAlpha"
		Dim As String s = InputBox("GDIP Clock", "Border Alpha", "&H" & Hex(mTextClock.mBorderAlpha), , , Handle)
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
		Form_Resize(This, Width, Height)
	Case "mnuDayStyle0"
		mnuDayStyle0.Checked = True
		mnuDayStyle1.Checked = False
		mnuDayStyle2.Checked = False
		frmDay.mDay.mShowStyle = 0
		frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
		Form_Resize(This, Width, Height)
	Case "mnuDayStyle1"
		mnuDayStyle0.Checked = False
		mnuDayStyle1.Checked = True
		mnuDayStyle2.Checked = False
		frmDay.mDay.mShowStyle = 1
		frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
		Form_Resize(This, Width, Height)
	Case "mnuDayStyle2"
		mnuDayStyle0.Checked = False
		mnuDayStyle1.Checked = False
		mnuDayStyle2.Checked = True
		frmDay.mDay.mShowStyle = 2
		frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
		Form_Resize(This, Width, Height)
	Case "mnuDayTextFont"
		FontDialog1.Font.Name = *frmDay.mDay.mFontName
		If FontDialog1.Execute Then
			WLet(frmDay.mDay.mFontName, FontDialog1.Font.Name)
			frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuDayFCFocus"
		ColorDialog1.Color = Color2Gdip(frmDay.mDay.mForeColor(DayFocus))
		If ColorDialog1.Execute() Then
			frmDay.mDay.mForeColor(DayFocus) = Color2Gdip(ColorDialog1.Color)
			frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuDayFCYear"
		ColorDialog1.Color = Color2Gdip(frmDay.mDay.mForeColor(DayYear))
		If ColorDialog1.Execute() Then
			frmDay.mDay.mForeColor(DayYear) = Color2Gdip(ColorDialog1.Color)
			frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuDayFCMonth"
		ColorDialog1.Color = Color2Gdip(frmDay.mDay.mForeColor(DayMonth))
		If ColorDialog1.Execute() Then
			frmDay.mDay.mForeColor(DayMonth) = Color2Gdip(ColorDialog1.Color)
			frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuDayFCDay"
		ColorDialog1.Color = Color2Gdip(frmDay.mDay.mForeColor(DayDay))
		If ColorDialog1.Execute() Then
			frmDay.mDay.mForeColor(DayDay) = Color2Gdip(ColorDialog1.Color)
			frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuDayFCWeek"
		ColorDialog1.Color = Color2Gdip(frmDay.mDay.mForeColor(DayWeek))
		If ColorDialog1.Execute() Then
			frmDay.mDay.mForeColor(DayWeek) = Color2Gdip(ColorDialog1.Color)
			frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuDayTrayEnabled"
		frmDay.mDay.mTrayEnabled = Not frmDay.mDay.mTrayEnabled
		frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
		Form_Resize(This, Width, Height)
	Case "mnuDayBCFocus"
		ColorDialog1.Color = Color2Gdip(frmDay.mDay.mBackColor(DayFocus))
		If ColorDialog1.Execute() Then
			frmDay.mDay.mBackColor(DayFocus) = Color2Gdip(ColorDialog1.Color)
			frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuDayBCYear"
		ColorDialog1.Color = Color2Gdip(frmDay.mDay.mBackColor(DayYear))
		If ColorDialog1.Execute() Then
			frmDay.mDay.mBackColor(DayYear) = Color2Gdip(ColorDialog1.Color)
			frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuDayBCMonth"
		ColorDialog1.Color = Color2Gdip(frmDay.mDay.mBackColor(DayMonth))
		If ColorDialog1.Execute() Then
			frmDay.mDay.mBackColor(DayMonth) = Color2Gdip(ColorDialog1.Color)
			frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuDayBCDay"
		ColorDialog1.Color = Color2Gdip(frmDay.mDay.mBackColor(DayDay))
		If ColorDialog1.Execute() Then
			frmDay.mDay.mBackColor(DayDay) = Color2Gdip(ColorDialog1.Color)
			frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuDayBCWeek"
		ColorDialog1.Color = Color2Gdip(frmDay.mDay.mBackColor(DayWeek))
		If ColorDialog1.Execute() Then
			frmDay.mDay.mBackColor(DayWeek) = Color2Gdip(ColorDialog1.Color)
			frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
			Form_Resize(This, Width, Height)
		End If
		
	Case "mnuDayBAFocus"
		Dim As String s = InputBox("GDIP Clock", "Day Tray Focus Alpha", "&H" & Hex(frmDay.mDay.mBackAlpha(DayFocus) Shr 24), , , Handle)
		frmDay.mDay.mBackAlpha(DayFocus) = CULng(s) Shl 24
		frmDay.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		Form_Resize(This, Width, Height)
	Case "mnuDayBAYear"
		Dim As String s = InputBox("GDIP Clock", "Day Tray Year Alpha", "&H" & Hex(frmDay.mDay.mBackAlpha(DayYear) Shr 24), , , Handle)
		frmDay.mDay.mBackAlpha(DayYear) = CULng(s) Shl 24
		frmDay.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		Form_Resize(This, Width, Height)
	Case "mnuDayBAMonth"
		Dim As String s = InputBox("GDIP Clock", "Day Tray Month Alpha", "&H" & Hex(frmDay.mDay.mBackAlpha(DayMonth) Shr 24), , , Handle)
		frmDay.mDay.mBackAlpha(DayMonth) = CULng(s) Shl 24
		frmDay.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		Form_Resize(This, Width, Height)
	Case "mnuDayBADay"
		Dim As String s = InputBox("GDIP Clock", "Day Tray Day Alpha", "&H" & Hex(frmDay.mDay.mBackAlpha(DayDay) Shr 24), , , Handle)
		frmDay.mDay.mBackAlpha(DayDay) = CULng(s) Shl 24
		frmDay.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		Form_Resize(This, Width, Height)
	Case "mnuDayBAWeek"
		Dim As String s = InputBox("GDIP Clock", "Day Tray Week Alpha", "&H" & Hex(frmDay.mDay.mBackAlpha(DayWeek) Shr 24), , , Handle)
		frmDay.mDay.mBackAlpha(DayWeek) = CULng(s) Shl 24
		frmDay.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		Form_Resize(This, Width, Height)
		
	Case "mnuDayBackEnabled"
		frmDay.mDay.mBackEnabled = Not frmDay.mDay.mBackEnabled
		frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
		Form_Resize(This, Width, Height)
	Case "mnuDayBackFile"
		OpenFileDialog1.FileName = frmDay.mDay.mBackImage.ImageFile
		If OpenFileDialog1.Execute Then
			frmDay.mDay.mBackImage.ImageFile = OpenFileDialog1.FileName
			frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuDayBackAlpha"
		Dim As String s = InputBox("GDIP Clock", "Day Back Alpha", "&H" & Hex(frmDay.mDay.mBackAlpha(DayImageFile) Shr 24), , , Handle)
		frmDay.mDay.mBackAlpha(DayImageFile) = CULng(s) Shl 24
		frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
		Form_Resize(This, Width, Height)
	Case "mnuDayBackBlur"
		Dim As String s = InputBox("GDIP Clock", "Day Back Blur", "" & frmDay.mDay.mBackBlur, , , Handle)
		frmDay.mDay.mBackBlur = CInt(s)
		frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
		Form_Resize(This, Width, Height)
		
	Case "mnuDayPanelEnabled"
		frmDay.mDay.mPanelEnabled = Not frmDay.mDay.mPanelEnabled
		frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
		Form_Resize(This, Width, Height)
	Case "mnuDayPanelAlpha"
		Dim As String s = InputBox("GDIP Clock", "Tray Alpha", "&H" & Hex(frmDay.mDay.mBackAlpha(DayPanel) Shr 24), , , Handle)
		frmDay.mDay.mBackAlpha(DayPanel) = CULng(s) Shl 24
		frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
		Form_Resize(This, Width, Height)
	Case "mnuDayPanelColor"
		ColorDialog1.Color = Color2Gdip(frmDay.mDay.mBackColor(DayPanel))
		If ColorDialog1.Execute() Then
			frmDay.mDay.mBackColor(DayPanel) = Color2Gdip(ColorDialog1.Color)
			frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuDayOutlineEnabled"
		frmDay.mDay.mOutlineEnabled = Not frmDay.mDay.mOutlineEnabled
		frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
		Form_Resize(This, Width, Height)
	Case "mnuDayOutlineSize"
		Dim As String s = InputBox("GDIP Clock", "Outline size", "" & frmDay.mDay.mOutlineSize, , , Handle)
		frmDay.mDay.mOutlineSize = CSng(s)
		frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
		Form_Resize(This, Width, Height)
	Case "mnuDayOutlineColor"
		ColorDialog1.Color = Color2Gdip(frmDay.mDay.mForeColor(DayPanel))
		If ColorDialog1.Execute() Then
			frmDay.mDay.mForeColor(DayPanel) = Color2Gdip(ColorDialog1.Color)
			frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuDayOutlineAlpha"
		Dim As String s = InputBox("GDIP Clock", "Outline Alpha", "&H" & Hex(frmDay.mDay.mForeAlpha(DayPanel) Shr 24), , , Handle)
		frmDay.mDay.mForeAlpha(DayPanel) = CULng(s) Shl 24
		frmDay.Form_Resize(frmDay, frmDay.Width, frmDay.Height)
		Form_Resize(This, Width, Height)
		
	Case "mnuMonthControl"
		frmMonth.mMonth.mShowControls = Not frmMonth.mMonth.mShowControls
		frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		Form_Resize(This, Width, Height)
	Case "mnuMonthWeek"
		frmMonth.mMonth.mShowWeeks = Not frmMonth.mMonth.mShowWeeks
		frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		Form_Resize(This, Width, Height)
	Case "mnuMonthTextFont"
		FontDialog1.Font.Name = *frmMonth.mMonth.mFontName
		If FontDialog1.Execute Then
			WLet(frmMonth.mMonth.mFontName, FontDialog1.Font.Name)
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuMonthFCFocus"
		ColorDialog1.Color = Color2Gdip(frmMonth.mMonth.mForeColor(MonthFocus))
		If ColorDialog1.Execute() Then
			frmMonth.mMonth.mForeColor(MonthFocus) = Color2Gdip(ColorDialog1.Color)
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuMonthFCControl"
		ColorDialog1.Color = Color2Gdip(frmMonth.mMonth.mForeColor(MonthControl))
		If ColorDialog1.Execute() Then
			frmMonth.mMonth.mForeColor(MonthControl) = Color2Gdip(ColorDialog1.Color)
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuMonthFCWeek"
		ColorDialog1.Color = Color2Gdip(frmMonth.mMonth.mForeColor(MonthWeek))
		If ColorDialog1.Execute() Then
			frmMonth.mMonth.mForeColor(MonthWeek) = Color2Gdip(ColorDialog1.Color)
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuMonthFCDay"
		ColorDialog1.Color = Color2Gdip(frmMonth.mMonth.mForeColor(MonthDay))
		If ColorDialog1.Execute() Then
			frmMonth.mMonth.mForeColor(MonthDay) = Color2Gdip(ColorDialog1.Color)
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuMonthFCSelect"
		ColorDialog1.Color = Color2Gdip(frmMonth.mMonth.mForeColor(MonthSelect))
		If ColorDialog1.Execute() Then
			frmMonth.mMonth.mForeColor(MonthSelect) = Color2Gdip(ColorDialog1.Color)
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuMonthFCToday"
		ColorDialog1.Color = Color2Gdip(frmMonth.mMonth.mForeColor(MonthToday))
		If ColorDialog1.Execute() Then
			frmMonth.mMonth.mForeColor(MonthToday) = Color2Gdip(ColorDialog1.Color)
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuMonthFCHoliday"
		ColorDialog1.Color = Color2Gdip(frmMonth.mMonth.mForeColor(MonthHoliday))
		If ColorDialog1.Execute() Then
			frmMonth.mMonth.mForeColor(MonthHoliday) = Color2Gdip(ColorDialog1.Color)
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuMonthTrayEnabled"
		frmMonth.mMonth.mTrayEnabled = Not frmMonth.mMonth.mTrayEnabled
		frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		Form_Resize(This, Width, Height)
	Case "mnuMonthBCFocus"
		ColorDialog1.Color = Color2Gdip(frmMonth.mMonth.mBackColor(MonthFocus))
		If ColorDialog1.Execute() Then
			frmMonth.mMonth.mBackColor(MonthFocus) = Color2Gdip(ColorDialog1.Color)
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuMonthBCControl"
		ColorDialog1.Color = Color2Gdip(frmMonth.mMonth.mBackColor(MonthControl))
		If ColorDialog1.Execute() Then
			frmMonth.mMonth.mBackColor(MonthControl) = Color2Gdip(ColorDialog1.Color)
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuMonthBCWeek"
		ColorDialog1.Color = Color2Gdip(frmMonth.mMonth.mBackColor(MonthWeek))
		If ColorDialog1.Execute() Then
			frmMonth.mMonth.mBackColor(MonthWeek) = Color2Gdip(ColorDialog1.Color)
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuMonthBCDay"
		ColorDialog1.Color = Color2Gdip(frmMonth.mMonth.mBackColor(MonthDay))
		If ColorDialog1.Execute() Then
			frmMonth.mMonth.mBackColor(MonthDay) = Color2Gdip(ColorDialog1.Color)
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuMonthBCSelect"
		ColorDialog1.Color = Color2Gdip(frmMonth.mMonth.mBackColor(MonthSelect))
		If ColorDialog1.Execute() Then
			frmMonth.mMonth.mBackColor(MonthSelect) = Color2Gdip(ColorDialog1.Color)
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
			Form_Resize(This, Width, Height)
		End If
		
	Case "mnuMonthBAFocus"
		Dim As String s = InputBox("GDIP Clock", "Month Tray Focus Alpha", "&H" & Hex(frmMonth.mMonth.mBackAlpha(MonthFocus) Shr 24), , , Handle)
		frmMonth.mMonth.mBackAlpha(MonthFocus) = CULng(s) Shl 24
		frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		Form_Resize(This, Width, Height)
	Case "mnuMonthBAControl"
		Dim As String s = InputBox("GDIP Clock", "Month Tray Control Alpha", "&H" & Hex(frmMonth.mMonth.mBackAlpha(MonthControl) Shr 24), , , Handle)
		frmMonth.mMonth.mBackAlpha(MonthControl) = CULng(s) Shl 24
		frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		Form_Resize(This, Width, Height)
	Case "mnuMonthBAWeek"
		Dim As String s = InputBox("GDIP Clock", "Month Tray Week Alpha", "&H" & Hex(frmMonth.mMonth.mBackAlpha(MonthWeek) Shr 24), , , Handle)
		frmMonth.mMonth.mBackAlpha(MonthWeek) = CULng(s) Shl 24
		frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		Form_Resize(This, Width, Height)
	Case "mnuMonthBADay"
		Dim As String s = InputBox("GDIP Clock", "Month Tray Day Alpha", "&H" & Hex(frmMonth.mMonth.mBackAlpha(MonthDay) Shr 24), , , Handle)
		frmMonth.mMonth.mBackAlpha(MonthDay) = CULng(s) Shl 24
		frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		Form_Resize(This, Width, Height)
	Case "mnuMonthBASelect"
		Dim As String s = InputBox("GDIP Clock", "Month Tray Select Alpha", "&H" & Hex(frmMonth.mMonth.mBackAlpha(MonthSelect) Shr 24), , , Handle)
		frmMonth.mMonth.mBackAlpha(MonthSelect) = CULng(s) Shl 24
		frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		Form_Resize(This, Width, Height)
		
	Case "mnuMonthBackEnabled"
		frmMonth.mMonth.mBackEnabled = Not frmMonth.mMonth.mBackEnabled
		frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		Form_Resize(This, Width, Height)
	Case "mnuMonthBackFile"
		OpenFileDialog1.FileName = frmMonth.mMonth.mBackImage.ImageFile
		If OpenFileDialog1.Execute Then
			frmMonth.mMonth.mBackImage.ImageFile = OpenFileDialog1.FileName
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuMonthBackAlpha"
		Dim As String s = InputBox("GDIP Clock", "Month Back Alpha", "&H" & Hex(frmMonth.mMonth.mBackAlpha(MonthImageFile) Shr 24), , , Handle)
		frmMonth.mMonth.mBackAlpha(MonthImageFile) = CULng(s) Shl 24
		frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		Form_Resize(This, Width, Height)
	Case "mnuMonthBackBlur"
		Dim As String s = InputBox("GDIP Clock", "Month Back Blur", "" & frmMonth.mMonth.mBackBlur, , , Handle)
		frmMonth.mMonth.mBackBlur = CInt(s)
		frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		Form_Resize(This, Width, Height)
		
	Case "mnuMonthPanelEnabled"
		frmMonth.mMonth.mPanelEnabled = Not frmMonth.mMonth.mPanelEnabled
		frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		Form_Resize(This, Width, Height)
	Case "mnuMonthPanelAlpha"
		Dim As String s = InputBox("GDIP Clock", "Panel Alpha", "&H" & Hex(frmMonth.mMonth.mBackAlpha(MonthPanel) Shr 24), , , Handle)
		frmMonth.mMonth.mBackAlpha(MonthPanel) = CULng(s) Shl 24
		frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		Form_Resize(This, Width, Height)
	Case "mnuMonthPanelColor"
		ColorDialog1.Color = Color2Gdip(frmMonth.mMonth.mBackColor(MonthPanel))
		If ColorDialog1.Execute() Then
			frmMonth.mMonth.mBackColor(MonthPanel) = Color2Gdip(ColorDialog1.Color)
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuMonthOutlineEnabled"
		frmMonth.mMonth.mOutlineEnabled = Not frmMonth.mMonth.mOutlineEnabled
		frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		Form_Resize(This, Width, Height)
	Case "mnuMonthOutlineSize"
		Dim As String s = InputBox("GDIP Clock", "Outline size", "" & frmMonth.mMonth.mOutlineSize, , , Handle)
		frmMonth.mMonth.mOutlineSize = CSng(s)
		frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		Form_Resize(This, Width, Height)
	Case "mnuMonthOutlineColor"
		ColorDialog1.Color = Color2Gdip(frmMonth.mMonth.mForeColor(MonthPanel))
		If ColorDialog1.Execute() Then
			frmMonth.mMonth.mForeColor(MonthPanel) = Color2Gdip(ColorDialog1.Color)
			frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
			Form_Resize(This, Width, Height)
		End If
	Case "mnuMonthOutlineAlpha"
		Dim As String s = InputBox("GDIP Clock", "Outline Alpha", "&H" & Hex(frmMonth.mMonth.mForeAlpha(MonthPanel) Shr 24), , , Handle)
		frmMonth.mMonth.mForeAlpha(MonthPanel) = CULng(s) Shl 24
		frmMonth.Form_Resize(frmMonth, frmMonth.Width, frmMonth.Height)
		Form_Resize(This, Width, Height)
		
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
						If pSpVoice Then pSpVoice->SetVoice(Cast(ISpObjectToken Ptr, Sender.Tag))
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
						If pSpVoice Then pSpVoice->SetOutput(Cast(ISpObjectToken Ptr, Sender.Tag), True)
					#endif
				Else
					mnuAudioSub(i)->Checked = False
				End If
			Next
		End If
	End Select
End Sub

Private Sub frmClockType.Form_Create(ByRef Sender As Control)
	ProfileInitial()
	SpeechInit()
	
	midiOutOpen(@mMidiOut, mMidiID, NULL, NULL, NULL)
	If mMidiOut Then SendProgramChange(mMidiOut, 0, 14)
	
	ProfileFrmClock(mKeyValDef())
	
	ScreenInfo(mScreenWidth, mScreenHeight)
	
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
	
	Notify(!"VisualFBEditor\0", !"Welcome to use GDIP Clock!\0")
	
	WLet(mProfileName, ProfileDefLoad())
	If ProfileLoad(*mProfileName, mKeyValue()) Then
		Profile2Clock(mKeyValue())
	End If
	
	mTextClock.TextAlpha(mTextAlpha1, mTextAlpha2)
	If mRectMain.Right And mRectMain.Bottom Then Move(mRectMain.Left, mRectMain.Top, mRectMain.Right, mRectMain.Bottom)
End Sub

Private Sub frmClockType.Form_Show(ByRef Sender As Form)
	FileName2Menu(*mProfileExt)
	Clock2Interface()
	
	mnuDayEnabled.Checked = Not mShowDay
	mnuMenu_Click(mnuDayEnabled)
	
	mnuMonthEnabled.Checked = Not mShowMonth
	mnuMenu_Click(mnuMonthEnabled)
	
	mnuTransparent.Checked = Not mTransparent
	mnuMenu_Click(mnuTransparent)
	
	TimerComponent1.Enabled = True
End Sub

Private Sub frmClockType.Notify(Title As WString, Info As WString)
	
	With SystrayIcon
		.uFlags =  NIF_INFO
		.szInfo = !"\0"
		.szInfoTitle = !"\0"
	End With
	Shell_NotifyIcon(NIM_MODIFY, @SystrayIcon)
	
	With SystrayIcon
		.uFlags =  NIF_INFO
		.szInfo = Info
		.szInfoTitle = Title
		.uTimeout = 1
		.dwInfoFlags = 1
	End With
	Shell_NotifyIcon(NIM_MODIFY, @SystrayIcon)
	
End Sub
Private Sub frmClockType.Transparent(v As Boolean)
	Form_Resize(This, Width, Height)
	frmTrans.Enabled = v
	PaintClock()
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
	If mnuLocateSticky.Checked Then Form_Move(This)
	Clock2Interface()
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
	If mnuProfileSaveOnExit.Checked Then ProfileSave(*mProfileName, mKeyValue())
	ProfileRelease()
	
	If mMidiOut Then midiOutClose(mMidiOut)
	
	Shell_NotifyIcon(NIM_DELETE, @SystrayIcon)
End Sub

Private Sub frmClockType.Form_Move(ByRef Sender As Control)
	If mnuLocateSticky.Checked = False Then Exit Sub
	
	'窗口粘连
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
	
	Dim m As Integer
	Dim h As Integer
	
	'midi报时
	If Second(dNow) = 0 Then
		m = Minute(dNow)
		h = Hour(dNow)
		If mnuAnnounce1.Checked Then
			If m = 0 Then
				If mMidiOut Then SendNoteOn(mMidiOut, 0, 61, 255)
			End If
		End If
		If mnuAnnounce2.Checked Then
			If m = 0 Or m = 30 Then
				If mMidiOut Then SendNoteOn(mMidiOut, 0, 61, 255)
			End If
		End If
		If mnuAnnounce3.Checked Then
			If m = 0 Or m = 15 Or m = 30 Or m = 45 Then
				If mMidiOut Then SendNoteOn(mMidiOut, 0, 61, 255)
			End If
		End If
	End If
	
	'1/4,1/2,整点报时
	If Second(dNow) = 1 Then
		m = Minute(dNow)
		h = Hour(dNow)
		If mnuAnnounce1.Checked Then
			If m = 0 Then SpeechNow(dNow, mLanguage)
		End If
		If mnuAnnounce2.Checked Then
			If m = 0 Or m = 30 Then SpeechNow(dNow, mLanguage)
		End If
		If mnuAnnounce3.Checked Then
			If m = 0 Or m = 15 Or m = 30 Or m = 45 Then SpeechNow(dNow, mLanguage)
		End If
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

Private Sub frmClockType.Form_Click(ByRef Sender As Control)
	If mMidiOut Then SendNoteOn(mMidiOut, 0, 61, 255)
End Sub

Private Sub frmClockType.Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
	If mnuTextEnabled.Checked Then
		mTextClock.FileName = Filename
		mTextClock.mBackEnabled = True
	Else
		mAnalogClock.FileName = Filename
		mAnalogClock.mBackEnabled = True
	End If
	mnuMenu_Click(mnuAspectRatio)
	Form_Resize(This, Width, Height)
End Sub
