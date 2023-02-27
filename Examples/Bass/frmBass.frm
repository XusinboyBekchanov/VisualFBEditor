'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		Const _MAIN_FILE_ = __FILE__
		#ifdef __FB_WIN32__
			#cmdline "frmBass.rc"
		#endif
	#endif
	#include once "mff/Form.bi"
	#include once "mff/GroupBox.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/TrackBar.bi"
	#include once "mff/TimerComponent.bi"
	#include once "mff/Label.bi"
	#include once "mff/Picture.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/Panel.bi"
	#include once "mff/RadioButton.bi"
	#include once "mff/ProgressBar.bi"
	#include once "mff/CheckedListBox.bi"
	#include once "mff/TabControl.bi"
	#include once "mff/Dialogs.bi"
	#include once "mff/Animate.bi"
	#include once "vbcompat.bi"
	#include once "bass.bi"
	#include once "BassBase.bi"
	#include once "BassSpectrum.bi"
	#include once "BassRecord.bi"
	#include once "BassRaido.bi"
	#include once "BassPlayback.bi"
	
	Using My.Sys.Forms
	
	Type frmBassType Extends Form
		bSpectrum As BassSpectrum
		
		OutputDevice As DWORD ' output devices
		InputDevice As DWORD ' input devices
		RecInput As DWORD = -1 ' Input source
		
		bPlayback As BassPlayback
		bRecord As BassRecord
		
		bRaido As BassRaido
		Declare Static Sub OnRaidoMeta(Owner As Any Ptr, Meta As ZString Ptr)
		Declare Static Sub OnRaidoStall(Owner As Any Ptr)
		Declare Static Sub OnRaidoFree(Owner As Any Ptr)
		Declare Static Sub OnRaidoStatus(Owner As Any Ptr, Status As ZString Ptr)
		
		Declare Sub VolumeGet()
		Declare Sub VolumeSet()
		Declare Function StreamSelected() As HSTREAM
		
		fxHdl(10) As HFX 'FX handles
		fxTyp(10) As DWORD = {0, _
		BASS_FX_DX8_CHORUS, _
		BASS_FX_DX8_COMPRESSOR, _
		BASS_FX_DX8_DISTORTION, _
		BASS_FX_DX8_ECHO, _
		BASS_FX_DX8_FLANGER, _
		BASS_FX_DX8_GARGLE, _
		BASS_FX_DX8_I3DL2REVERB, _
		BASS_FX_DX8_PARAMEQ, _
		BASS_FX_DX8_REVERB, _
		BASS_FX_VOLUME}
		
		bfdCHO As BASS_DX8_CHORUS
		bfdCOM As BASS_DX8_COMPRESSOR
		bfdDIS As BASS_DX8_DISTORTION
		bfdECH As BASS_DX8_ECHO
		bfdFLA As BASS_DX8_FLANGER
		bfdGAR As BASS_DX8_GARGLE
		bfdI3D As BASS_DX8_I3DL2REVERB
		bfdPAR As BASS_DX8_PARAMEQ
		bfdREV As BASS_DX8_REVERB
		bfVOL As BASS_FX_VOLUME_PARAM
		
		fxPara(10) As Any Ptr '参数指针
		fxParaC(10) As Integer '参数数量
		
		fxCtlTab(10) As TabPage Ptr
		fxCtlChk(10) As CheckBox Ptr
		fxCtlMsg(10, 15) As Label Ptr '信息显示指针
		fxCtlShow(10, 15) As Label Ptr '参数显示指针
		fxCtlTrack(10, 15) As TrackBar Ptr '参数调节控件指针
		fxTrackEQ(9) As TrackBar Ptr 'EQ调节控件指针
		fxLabelEQB(9) As Label Ptr 'EQBank参数显示指针
		fxLabelEQ(9) As Label Ptr 'EQ参数显示指针
		
		bfdEQ(9) As BASS_DX8_PARAMEQ
		cntEQ As Integer = 9
		fxEQHdl(9) As HFX
		
		Declare Function FxIndex(fxName As WString) As Integer
		Declare Sub FxReset(ch As HSTREAM)
		Declare Sub FxRemove(ch As HSTREAM)
		Declare Sub FxParafrmCtl(fxIdx As Integer)
		Declare Sub FxPara2Ctl(fxIdx As Integer)
		Declare Sub FxParaShow(fxIdx As Integer, paIdx As Integer)
		Declare Sub FxParaSet(fxIdx As Integer, paIdx As Integer, Position As Integer)
		Declare Sub FxEnabled(fxName As WString, st As Boolean, ch As HSTREAM)
		Declare Sub EqEnabled(st As Boolean, ch As HSTREAM)
		
		Declare Static Sub _Form_Create(ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Static Sub _Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Static Sub _CommandButton1_Click(ByRef Sender As Control)
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Static Sub _CommandButton6_Click(ByRef Sender As Control)
		Declare Sub CommandButton6_Click(ByRef Sender As Control)
		Declare Static Sub _CommandButton3_Click(ByRef Sender As Control)
		Declare Sub CommandButton3_Click(ByRef Sender As Control)
		Declare Static Sub _CommandButton4_Click(ByRef Sender As Control)
		Declare Sub CommandButton4_Click(ByRef Sender As Control)
		Declare Static Sub _CommandButton5_Click(ByRef Sender As Control)
		Declare Sub CommandButton5_Click(ByRef Sender As Control)
		Declare Static Sub _ComboBoxEdit1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub ComboBoxEdit1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Static Sub _TrackBar1_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Sub TrackBar1_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Static Sub _TrackBar2_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Sub TrackBar2_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Static Sub _TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Sub TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Static Sub _TrackBar2_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub TrackBar2_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Static Sub _TrackBar2_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub TrackBar2_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Static Sub _CheckBox1_Click(ByRef Sender As CheckBox)
		Declare Sub CheckBox1_Click(ByRef Sender As CheckBox)
		Declare Static Sub _TimerComponent2_Timer(ByRef Sender As TimerComponent)
		Declare Sub TimerComponent2_Timer(ByRef Sender As TimerComponent)
		Declare Static Sub _Picture1_Click(ByRef Sender As Picture)
		Declare Sub Picture1_Click(ByRef Sender As Picture)
		Declare Static Sub _ComboBoxEdit4_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub ComboBoxEdit4_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Static Sub _ComboBoxEdit2_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub ComboBoxEdit2_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Static Sub _TrackBar3_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Sub TrackBar3_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Static Sub _CommandButton8_Click(ByRef Sender As Control)
		Declare Sub CommandButton8_Click(ByRef Sender As Control)
		Declare Static Sub _CommandButton12_Click(ByRef Sender As Control)
		Declare Sub CommandButton12_Click(ByRef Sender As Control)
		Declare Static Sub _TimerComponent3_Timer(ByRef Sender As TimerComponent)
		Declare Sub TimerComponent3_Timer(ByRef Sender As TimerComponent)
		Declare Static Sub _CheckBox3_Click(ByRef Sender As CheckBox)
		Declare Sub CheckBox3_Click(ByRef Sender As CheckBox)
		Declare Static Sub _CommandButton9_Click(ByRef Sender As Control)
		Declare Sub CommandButton9_Click(ByRef Sender As Control)
		Declare Static Sub _CommandButton10_Click(ByRef Sender As Control)
		Declare Sub CommandButton10_Click(ByRef Sender As Control)
		Declare Static Sub _CheckBox4_Click(ByRef Sender As CheckBox)
		Declare Sub CheckBox4_Click(ByRef Sender As CheckBox)
		Declare Static Sub _CommandButton23_Click(ByRef Sender As Control)
		Declare Sub CommandButton23_Click(ByRef Sender As Control)
		Declare Static Sub _TimerComponent4_Timer(ByRef Sender As TimerComponent)
		Declare Sub TimerComponent4_Timer(ByRef Sender As TimerComponent)
		Declare Static Sub _CommandButton24_Click(ByRef Sender As Control)
		Declare Sub CommandButton24_Click(ByRef Sender As Control)
		Declare Static Sub _TrackBar4_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Sub TrackBar4_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Static Sub _RadioButton1_Click(ByRef Sender As RadioButton)
		Declare Sub RadioButton1_Click(ByRef Sender As RadioButton)
		Declare Static Sub _CheckBox5_Click(ByRef Sender As CheckBox)
		Declare Sub CheckBox5_Click(ByRef Sender As CheckBox)
		Declare Static Sub _tbSet_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Sub tbSet_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Static Sub _TextBox1_DblClick(ByRef Sender As Control)
		Declare Sub TextBox1_DblClick(ByRef Sender As Control)
		Declare Static Sub _TextBox2_DblClick(ByRef Sender As Control)
		Declare Sub TextBox2_DblClick(ByRef Sender As Control)
		Declare Static Sub _tbEQ00_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Sub tbEQ00_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Static Sub _ComboBoxEdit6_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub ComboBoxEdit6_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Static Sub _CheckBox15_Click(ByRef Sender As CheckBox)
		Declare Sub CheckBox15_Click(ByRef Sender As CheckBox)
		Declare Constructor
		
		Dim As GroupBox GroupBox1, GroupBox2, GroupBox3, GroupBox4, GroupBox5, GroupBox6, GroupBox7, GroupBox8
		Dim As CommandButton CommandButton1, CommandButton3, CommandButton4, CommandButton5, CommandButton6, CommandButton8, CommandButton9, CommandButton10, CommandButton12, CommandButton23, CommandButton24
		Dim As ComboBoxEdit ComboBoxEdit1, ComboBoxEdit2, ComboBoxEdit3, ComboBoxEdit4, ComboBoxEdit5, ComboBoxEdit6
		Dim As TextBox TextBox1, TextBox2, TextBox3, TextBox4, TextBox5
		Dim As TrackBar TrackBar1, TrackBar2, TrackBar3, TrackBar4, tbSet0900, tbSet0901, tbSet0902, tbSet0903, tbSet0100, tbSet0101, tbSet0102, tbSet0103, tbSet0104, tbSet0105, tbSet0200, tbSet0201, tbSet0202, tbSet0203, tbSet0204, tbSet0205, tbSet0300, tbSet0301, tbSet0302, tbSet0303, tbSet0304, tbSet0400, tbSet0401, tbSet0402, tbSet0403, tbSet0404, tbSet0500, tbSet0501, tbSet0502, tbSet0503, tbSet0504, tbSet0505, tbSet0506, tbSet0600, tbSet0601, tbSet0700, tbSet0701, tbSet0702, tbSet0703, tbSet0704, tbSet0705, tbSet0706, tbSet0707, tbSet0708, tbSet0709, tbSet0710, tbSet0711, tbSet0800, tbSet0801, tbSet0802, tbSet1000, tbSet1001, tbSet1002, tbSet1003, tbSet0106, tbEQ00, tbEQ01, tbEQ02, tbEQ03, tbEQ04, tbEQ05, tbEQ06, tbEQ07, tbEQ08, tbEQ09
		Dim As TimerComponent TimerComponent1, TimerComponent2, TimerComponent3, TimerComponent4
		Dim As Label Label1, Label2, Label3, Label4, Label5, Label6, Label8, lblFXMSG0900, lblFXMSG0901, lblFXMSG0902, lblFXMSG0903, lblFXShw0900, lblFXShw0901, lblFXShw0902, lblFXShw0903, lblFXMSG0100, lblFXMSG0101, lblFXMSG0102, lblFXMSG0103, lblFXMSG0104, lblFXMSG0105, lblFXMSG0200, lblFXMSG0201, lblFXMSG0202, lblFXMSG0203, lblFXMSG0204, lblFXMSG0205, lblFXMSG0300, lblFXMSG0301, lblFXMSG0302, lblFXMSG0303, lblFXMSG0304, lblFXMSG0400, lblFXMSG0401, lblFXMSG0402, lblFXMSG0403, lblFXMSG0404, lblFXMSG0500, lblFXMSG0501, lblFXMSG0502, lblFXMSG0503, lblFXMSG0504, lblFXMSG0505, lblFXMSG0506, lblFXMSG0600, lblFXMSG0601, lblFXMSG0700, lblFXMSG0701, lblFXMSG0702, lblFXMSG0703, lblFXMSG0704, lblFXMSG0705, lblFXMSG0706, lblFXMSG0707, lblFXMSG0708, lblFXMSG0709, lblFXMSG0710, lblFXMSG0711, lblFXMSG0800, lblFXMSG0801, lblFXMSG0802, lblFXMSG1000, lblFXMSG1001, lblFXMSG1002, lblFXMSG1003, lblFXShw0100, lblFXShw0101, lblFXShw0102, lblFXShw0103, lblFXShw0104, lblFXShw0105, lblFXShw0200, lblFXShw0201, lblFXShw0202, lblFXShw0203, lblFXShw0204, lblFXShw0205, lblFXShw0300, lblFXShw0301, lblFXShw0302, lblFXShw0303, lblFXShw0304, lblFXShw0400, lblFXShw0401, lblFXShw0402, lblFXShw0403, lblFXShw0404, lblFXShw0500, lblFXShw0501, lblFXShw0502, lblFXShw0503, lblFXShw0504, lblFXShw0505, lblFXShw0506, lblFXShw0600, lblFXShw0601, lblFXShw0700, lblFXShw0701, lblFXShw0702, lblFXShw0703, lblFXShw0704, lblFXShw0705, lblFXShw0706, lblFXShw0707, lblFXShw0708, lblFXShw0709, lblFXShw0710, lblFXShw0711, lblFXShw0800, lblFXShw0801, lblFXShw0802, lblFXShw1000, lblFXShw1001, lblFXShw1002, lblFXShw1003, lblFXMSG0106, lblFXShw0106, lblEQ00, lblEQ01, lblEQ02, lblEQ03, lblEQ04, lblEQ05, lblEQ06, lblEQ07, lblEQ08, lblEQ09, lblEQB00, lblEQB01, lblEQB02, lblEQB03, lblEQB04, lblEQB05, lblEQB06, lblEQB07, lblEQB08, lblEQB09
		Dim As Picture Picture1
		Dim As CheckBox CheckBox1, CheckBox2, CheckBox3, CheckBox4, CheckBox5, CheckBox6, CheckBox7, CheckBox8, CheckBox9, CheckBox10, CheckBox11, CheckBox12, CheckBox13, CheckBox14, CheckBox15
		Dim As RadioButton RadioButton1, RadioButton2, RadioButton3
		Dim As TabControl TabControl1
		Dim As TabPage TabPage1, TabPage2, TabPage3, TabPage4, TabPage5, TabPage6, TabPage7, TabPage8, TabPage9, TabPage10
		Dim As OpenFileDialog OpenFileDialog1
		Dim As Animate Animate1
	End Type
	
	Constructor frmBassType
		' frmBass
		With This
			.Name = "frmBass"
			.Text = "Bass Audio"
			.Caption = "Bass Audio"
			.StartPosition = FormStartPosition.CenterScreen
			.Designer = @This
			.OnCreate = @_Form_Create
			.OnClose = @_Form_Close
			.SetBounds 0, 0, 880, 720
		End With
		' GroupBox1
		With GroupBox1
			.Name = "GroupBox1"
			.Text = "Playback"
			.TabIndex = 0
			.Caption = "Playback"
			.SetBounds 10, 190, 410, 130
			.Parent = @This
		End With
		' GroupBox2
		With GroupBox2
			.Name = "GroupBox2"
			.Text = "Record"
			.TabIndex = 1
			.Caption = "Record"
			.Enabled = True
			.SetBounds 10, 330, 410, 130
			.Parent = @This
		End With
		' GroupBox3
		With GroupBox3
			.Name = "GroupBox3"
			.Text = "Ex"
			.TabIndex = 2
			.Caption = "Ex"
			.SetBounds 440, 230, 410, 290
			.Parent = @This
		End With
		' GroupBox4
		With GroupBox4
			.Name = "GroupBox4"
			.Text = "Spectrum"
			.TabIndex = 3
			.Caption = "Spectrum"
			.Hint = ""
			.SetBounds 440, 70, 410, 150
			.Parent = @This
		End With
		' GroupBox5
		With GroupBox5
			.Name = "GroupBox5"
			.Text = "Stream"
			.TabIndex = 36
			.Caption = "Stream"
			.SetBounds 440, 10, 410, 50
			.Parent = @This
		End With
		' GroupBox6
		With GroupBox6
			.Name = "GroupBox6"
			.Text = "Device"
			.TabIndex = 37
			.Caption = "Device"
			.SetBounds 10, 10, 410, 170
			.Parent = @This
		End With
		' GroupBox7
		With GroupBox7
			.Name = "GroupBox7"
			.Text = "Raido"
			.TabIndex = 44
			.Caption = "Raido"
			.SetBounds 10, 470, 410, 200
			.Parent = @This
		End With
		' GroupBox8
		With GroupBox8
			.Name = "GroupBox8"
			.Text = "Equalizer"
			.TabIndex = 236
			.Caption = "Equalizer"
			.Enabled = False
			.SetBounds 440, 530, 410, 140
			.Parent = @This
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "Output"
			.TabIndex = 4
			.Caption = "Output"
			.Hint = ""
			.SetBounds 10, 20, 70, 20
			.Designer = @This
			.OnClick = @_CommandButton1_Click
			.Parent = @GroupBox6
		End With
		' ComboBoxEdit1
		With ComboBoxEdit1
			.Name = "ComboBoxEdit1"
			.Text = "ComboBoxEdit1"
			.TabIndex = 5
			.SetBounds 90, 20, 310, 21
			.Designer = @This
			.OnSelected = @_ComboBoxEdit1_Selected
			.Parent = @GroupBox6
		End With
		' CommandButton3
		With CommandButton3
			.Name = "CommandButton3"
			.Text = "Open"
			.TabIndex = 7
			.Caption = "Open"
			.SetBounds 10, 50, 70, 20
			.Designer = @This
			.OnClick = @_CommandButton3_Click
			.Parent = @GroupBox1
		End With
		' CommandButton4
		With CommandButton4
			.Name = "CommandButton4"
			.Text = "Pause"
			.TabIndex = 8
			.Caption = "Pause"
			.Enabled = False
			.SetBounds 90, 50, 70, 20
			.Designer = @This
			.OnClick = @_CommandButton4_Click
			.Parent = @GroupBox1
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = "F:\OfficePC_Update\!Media\Victory.wav"
			.TabIndex = 9
			.SetBounds 10, 20, 390, 20
			.Designer = @This
			.OnDblClick = @_TextBox1_DblClick
			.Parent = @GroupBox1
		End With
		' CommandButton5
		With CommandButton5
			.Name = "CommandButton5"
			.Text = "Stop"
			.TabIndex = 10
			.Caption = "Stop"
			.Enabled = False
			.SetBounds 170, 50, 70, 20
			.Designer = @This
			.OnClick = @_CommandButton5_Click
			.Parent = @GroupBox1
		End With
		' CommandButton6
		With CommandButton6
			.Name = "CommandButton6"
			.Text = "Input"
			.TabIndex = 11
			.Caption = "Input"
			.SetBounds 10, 80, 70, 20
			.Designer = @This
			.OnClick = @_CommandButton6_Click
			.Parent = @GroupBox6
		End With
		' CommandButton8
		With CommandButton8
			.Name = "CommandButton8"
			.Text = "Record"
			.TabIndex = 13
			.Caption = "Record"
			.Enabled = True
			.SetBounds 10, 50, 70, 20
			.Designer = @This
			.OnClick = @_CommandButton8_Click
			.Parent = @GroupBox2
		End With
		' CommandButton9
		With CommandButton9
			.Name = "CommandButton9"
			.Text = "Pause"
			.TabIndex = 14
			.Caption = "Pause"
			.Enabled = False
			.SetBounds 90, 50, 70, 20
			.Designer = @This
			.OnClick = @_CommandButton9_Click
			.Parent = @GroupBox2
		End With
		' CommandButton10
		With CommandButton10
			.Name = "CommandButton10"
			.Text = "Monitor"
			.TabIndex = 15
			.Caption = "Monitor"
			.Enabled = True
			.SetBounds 10, 20, 70, 20
			.Designer = @This
			.OnClick = @_CommandButton10_Click
			.Parent = @GroupBox2
		End With
		' ComboBoxEdit2
		With ComboBoxEdit2
			.Name = "ComboBoxEdit2"
			.Text = "ComboBoxEdit2"
			.TabIndex = 16
			.SetBounds 90, 80, 310, 21
			.Designer = @This
			.OnSelected = @_ComboBoxEdit2_Selected
			.Parent = @GroupBox6
		End With
		' TextBox2
		With TextBox2
			.Name = "TextBox2"
			.Text = "F:\OfficePC_Update\!Media\rec.wav"
			.TabIndex = 17
			.Enabled = True
			.SetBounds 10, 80, 390, 20
			.Designer = @This
			.OnDblClick = @_TextBox2_DblClick
			.Parent = @GroupBox2
		End With
		' CommandButton12
		With CommandButton12
			.Name = "CommandButton12"
			.Text = "Save"
			.TabIndex = 19
			.Caption = "Save"
			.Enabled = False
			.SetBounds 170, 50, 70, 20
			.Designer = @This
			.OnClick = @_CommandButton12_Click
			.Parent = @GroupBox2
		End With
		' TrackBar1
		With TrackBar1
			.Name = "TrackBar1"
			.Text = "TrackBar1"
			.TabIndex = 20
			.MinValue = 0
			.MaxValue = 10000
			.PageSize = 0
			.TickStyle = TickStyles.tsNone
			.ID = 1011
			.Enabled = True
			.ThumbLength = 15
			.TickMark = TickMarks.tmBoth
			.SetBounds 90, 50, 310, 20
			.Designer = @This
			.OnChange = @_TrackBar1_Change
			.Parent = @GroupBox6
		End With
		' TrackBar2
		With TrackBar2
			.Name = "TrackBar2"
			.Text = "TrackBar2"
			.TabIndex = 21
			.TickStyle = TickStyles.tsNone
			.Enabled = False
			.TickMark = TickMarks.tmBoth
			.ID = 1011
			.ThumbLength = 15
			.SetBounds 10, 80, 390, 20
			.Designer = @This
			.OnChange = @_TrackBar2_Change
			.OnMouseDown = @_TrackBar2_MouseDown
			.OnMouseUp = @_TrackBar2_MouseUp
			.Parent = @GroupBox1
		End With
		' TrackBar3
		With TrackBar3
			.Name = "TrackBar3"
			.Text = "TrackBar3"
			.TabIndex = 22
			.Enabled = True
			.TickMark = TickMarks.tmBoth
			.ID = 1013
			.TickStyle = TickStyles.tsNone
			.ThumbLength = 15
			.MaxValue = 10000
			.SetBounds 90, 140, 310, 20
			.Designer = @This
			.OnChange = @_TrackBar3_Change
			.Parent = @GroupBox6
		End With
		' TimerComponent1
		With TimerComponent1
			.Name = "TimerComponent1"
			.Interval = 100
			.SetBounds 0, 40, 16, 16
			.Designer = @This
			.OnTimer = @_TimerComponent1_Timer
			.Parent = @GroupBox1
		End With
		' Label1
		With Label1
			.Name = "Label1"
			.Text = "Volume"
			.TabIndex = 24
			.Caption = "Volume"
			.Alignment = AlignmentConstants.taRight
			.ID = 1009
			.SetBounds 10, 50, 70, 16
			.Parent = @GroupBox6
		End With
		' Label2
		With Label2
			.Name = "Label2"
			.Text = "Position"
			.TabIndex = 25
			.Caption = "Position"
			.Alignment = AlignmentConstants.taCenter
			.ID = 1009
			.SetBounds 10, 100, 390, 16
			.Parent = @GroupBox1
		End With
		' Picture1
		With Picture1
			.Name = "Picture1"
			.Text = ""
			.TabIndex = 26
			.BorderStyle = BorderStyles.bsNone
			.BackColor = 12632256
			.SetBounds 50, 20, 368, 127
			.Designer = @This
			.OnClick = @_Picture1_Click
			.Parent = @GroupBox4
		End With
		' CheckBox1
		With CheckBox1
			.Name = "CheckBox1"
			.Text = ""
			.TabIndex = 27
			.Checked = False
			.Caption = ""
			.SetBounds 10, 20, 20, 20
			.Designer = @This
			.OnClick = @_CheckBox1_Click
			.Parent = @GroupBox4
		End With
		' TextBox3
		With TextBox3
			.Name = "TextBox3"
			.Text = "25"
			.TabIndex = 28
			.SetBounds 10, 60, 20, 20
			.Parent = @GroupBox4
		End With
		' TimerComponent2
		With TimerComponent2
			.Name = "TimerComponent2"
			.SetBounds 30, 40, 16, 16
			.Designer = @This
			.OnTimer = @_TimerComponent2_Timer
			.Parent = @GroupBox4
		End With
		' RadioButton1
		With RadioButton1
			.Name = "RadioButton1"
			.Text = "Playback"
			.TabIndex = 35
			.Checked = True
			.Caption = "Playback"
			.SetBounds 10, 20, 110, 20
			.Designer = @This
			.OnClick = @_RadioButton1_Click
			.Parent = @GroupBox5
		End With
		' RadioButton2
		With RadioButton2
			.Name = "RadioButton2"
			.Text = "Record"
			.TabIndex = 36
			.Checked = False
			.Caption = "Record"
			.SetBounds 90, 20, 110, 20
			.Designer = @This
			.OnClick = @_RadioButton1_Click
			.Parent = @GroupBox5
		End With
		' RadioButton3
		With RadioButton3
			.Name = "RadioButton3"
			.Text = "Raido"
			.TabIndex = 57
			.Caption = "Raido"
			.SetBounds 160, 20, 110, 20
			.Designer = @This
			.OnClick = @_RadioButton1_Click
			.Parent = @GroupBox5
		End With
		' ComboBoxEdit3
		With ComboBoxEdit3
			.Name = "ComboBoxEdit3"
			.Text = "ComboBoxEdit3"
			.TabIndex = 31
			.SetBounds 90, 20, 310, 21
			.Designer = @This
			.Parent = @GroupBox2
		End With
		' ComboBoxEdit4
		With ComboBoxEdit4
			.Name = "ComboBoxEdit4"
			.Text = "ComboBoxEdit4"
			.TabIndex = 32
			.SetBounds 90, 110, 150, 21
			.Designer = @This
			.OnSelected = @_ComboBoxEdit4_Selected
			.Parent = @GroupBox6
		End With
		' CheckBox2
		With CheckBox2
			.Name = "CheckBox2"
			.Text = "Loop"
			.TabIndex = 33
			.Caption = "Loop"
			.Checked = True
			.SetBounds 330, 50, 70, 20
			.Designer = @This
			.Parent = @GroupBox1
		End With
		' Label3
		With Label3
			.Name = "Label3"
			.Text = "micphone"
			.TabIndex = 34
			.Caption = "micphone"
			.SetBounds 250, 113, 150, 16
			.Parent = @GroupBox6
		End With
		' TimerComponent3
		With TimerComponent3
			.Name = "TimerComponent3"
			.Interval = 100
			.Enabled = False
			.SetBounds 350, 50, 16, 16
			.Designer = @This
			.OnTimer = @_TimerComponent3_Timer
			.Parent = @GroupBox2
		End With
		' CheckBox3
		With CheckBox3
			.Name = "CheckBox3"
			.Text = "Record"
			.TabIndex = 35
			.Caption = "Record"
			.Enabled = False
			.SetBounds 250, 50, 60, 20
			.Designer = @This
			.OnClick = @_CheckBox3_Click
			.Parent = @GroupBox1
		End With
		' Label4
		With Label4
			.Name = "Label4"
			.Text = "Bytes record"
			.TabIndex = 35
			.Caption = "Bytes record"
			.Alignment = AlignmentConstants.taCenter
			.ID = 1008
			.SetBounds 10, 110, 390, 16
			.Parent = @GroupBox2
		End With
		' ComboBoxEdit5
		With ComboBoxEdit5
			.Name = "ComboBoxEdit5"
			.Text = "ComboBoxEdit5"
			.TabIndex = 55
			.Style = ComboBoxEditStyle.cbDropDown
			.SetBounds 10, 20, 260, 21
			.Parent = @GroupBox7
		End With
		' Label5
		With Label5
			.Name = "Label5"
			.Text = "stop"
			.TabIndex = 50
			.Alignment = AlignmentConstants.taCenter
			.ID = 1016
			.Caption = "stop"
			.SetBounds 10, 50, 390, 16
			.Parent = @GroupBox7
		End With
		' Label6
		With Label6
			.Name = "Label6"
			.Text = "stop"
			.TabIndex = 51
			.Alignment = AlignmentConstants.taCenter
			.ID = 1016
			.Caption = "stop"
			.SetBounds 10, 70, 390, 16
			.Parent = @GroupBox7
		End With
		' CheckBox4
		With CheckBox4
			.Name = "CheckBox4"
			.Text = "Direct connection"
			.TabIndex = 53
			.Caption = "Direct connection"
			.Checked = True
			.SetBounds 10, 170, 110, 20
			.Designer = @This
			.OnClick = @_CheckBox4_Click
			.Parent = @GroupBox7
		End With
		' TextBox4
		With TextBox4
			.Name = "TextBox4"
			.Text = "10.86.0.8"
			.TabIndex = 54
			.Enabled = False
			.SetBounds 130, 170, 270, 20
			.Parent = @GroupBox7
		End With
		' CommandButton23
		With CommandButton23
			.Name = "CommandButton23"
			.Text = "Open"
			.TabIndex = 55
			.Caption = "Open"
			.SetBounds 280, 20, 60, 20
			.Designer = @This
			.OnClick = @_CommandButton23_Click
			.Parent = @GroupBox7
		End With
		' CommandButton24
		With CommandButton24
			.Name = "CommandButton24"
			.Text = "Close"
			.TabIndex = 56
			.Caption = "Close"
			.SetBounds 340, 20, 60, 20
			.Designer = @This
			.OnClick = @_CommandButton24_Click
			.Parent = @GroupBox7
		End With
		' TimerComponent4
		With TimerComponent4
			.Name = "TimerComponent4"
			.SetBounds 10, 60, 16, 16
			.Designer = @This
			.OnTimer = @_TimerComponent4_Timer
			.Parent = @GroupBox7
		End With
		' Label8
		With Label8
			.Name = "Label8"
			.Text = "Volume"
			.TabIndex = 48
			.Alignment = AlignmentConstants.taRight
			.Caption = "Volume"
			.SetBounds 10, 140, 70, 16
			.Parent = @GroupBox6
		End With
		' TextBox5
		With TextBox5
			.Name = "TextBox5"
			.Text = "stop"
			.TabIndex = 48
			.Alignment = AlignmentConstants.taCenter
			.Multiline = True
			.SetBounds 10, 90, 390, 70
			.Parent = @GroupBox7
		End With
		' TrackBar4
		With TrackBar4
			.Name = "TrackBar4"
			.Text = "TrackBar4"
			.TabIndex = 49
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.ThumbLength = 15
			.MaxValue = 100
			.SetBounds 220, 20, 180, 20
			.Designer = @This
			.OnChange = @_TrackBar4_Change
			.Parent = @GroupBox5
		End With
		' TabControl1
		With TabControl1
			.Name = "TabControl1"
			.Text = "TabControl1"
			.TabIndex = 52
			.SelectedTabIndex = 7
			.SetBounds 100, 10, 300, 270
			.Parent = @GroupBox3
		End With
		' TabPage1
		With TabPage1
			.Name = "TabPage1"
			.Text = "Chorus"
			.TabIndex = 53
			.Caption = "Chorus"
			.SetBounds 0, 0, 674, 165
			.Parent = @TabControl1
		End With
		' TabPage2
		With TabPage2
			.Name = "TabPage2"
			.Text = "Compression"
			.TabIndex = 54
			.Caption = "Compression"
			.SetBounds -48, 22, 484, 185
			.Parent = @TabControl1
		End With
		' TabPage3
		With TabPage3
			.Name = "TabPage3"
			.Text = "Distortion"
			.TabIndex = 55
			.Caption = "Distortion"
			.SetBounds 0, 0, 674, 165
			.Parent = @TabControl1
		End With
		' TabPage4
		With TabPage4
			.Name = "TabPage4"
			.Text = "Echo"
			.TabIndex = 56
			.Caption = "Echo"
			.SetBounds 0, 0, 674, 165
			.Parent = @TabControl1
		End With
		' TabPage5
		With TabPage5
			.Name = "TabPage5"
			.Text = "Flanger"
			.TabIndex = 57
			.Caption = "Flanger"
			.SetBounds 0, 0, 674, 165
			.Parent = @TabControl1
		End With
		' TabPage6
		With TabPage6
			.Name = "TabPage6"
			.Text = "Gargle"
			.TabIndex = 58
			.Caption = "Gargle"
			.SetBounds 0, 0, 674, 165
			.Parent = @TabControl1
		End With
		' TabPage7
		With TabPage7
			.Name = "TabPage7"
			.Text = "3D"
			.TabIndex = 59
			.Caption = "3D"
			.SetBounds 2, 22, 294, 245
			.Parent = @TabControl1
		End With
		' TabPage8
		With TabPage8
			.Name = "TabPage8"
			.Text = "Equalizer"
			.TabIndex = 60
			.Caption = "Equalizer"
			.SetBounds 0, 0, 674, 165
			.Parent = @TabControl1
		End With
		' TabPage9
		With TabPage9
			.Name = "TabPage9"
			.Text = "Reverb"
			.TabIndex = 61
			.Caption = "Reverb"
			.SetBounds 0, 0, 674, 165
			.Parent = @TabControl1
		End With
		' TabPage10
		With TabPage10
			.Name = "TabPage10"
			.Text = "Volume"
			.TabIndex = 62
			.Caption = "Volume"
			.SetBounds 2, 22, 704, 185
			.Parent = @TabControl1
		End With
		' CheckBox5
		With CheckBox5
			.Name = "CheckBox5"
			.Text = "Chorus"
			.TabIndex = 61
			.Caption = "Chorus"
			.SetBounds 10, 20, 90, 20
			.Designer = @This
			.OnClick = @_CheckBox5_Click
			.Parent = @GroupBox3
		End With
		' CheckBox6
		With CheckBox6
			.Name = "CheckBox6"
			.Text = "Compression"
			.TabIndex = 62
			.Caption = "Compression"
			.SetBounds 10, 40, 90, 20
			.Designer = @This
			.OnClick = @_CheckBox5_Click
			.Parent = @GroupBox3
		End With
		' CheckBox7
		With CheckBox7
			.Name = "CheckBox7"
			.Text = "Distortion"
			.TabIndex = 63
			.Caption = "Distortion"
			.SetBounds 10, 60, 90, 20
			.Designer = @This
			.OnClick = @_CheckBox5_Click
			.Parent = @GroupBox3
		End With
		' CheckBox8
		With CheckBox8
			.Name = "CheckBox8"
			.Text = "Echo"
			.TabIndex = 64
			.Caption = "Echo"
			.SetBounds 10, 80, 90, 20
			.Designer = @This
			.OnClick = @_CheckBox5_Click
			.Parent = @GroupBox3
		End With
		' CheckBox9
		With CheckBox9
			.Name = "CheckBox9"
			.Text = "Flanger"
			.TabIndex = 65
			.Caption = "Flanger"
			.SetBounds 10, 100, 90, 20
			.Designer = @This
			.OnClick = @_CheckBox5_Click
			.Parent = @GroupBox3
		End With
		' CheckBox10
		With CheckBox10
			.Name = "CheckBox10"
			.Text = "Gargle"
			.TabIndex = 66
			.Caption = "Gargle"
			.SetBounds 10, 120, 90, 20
			.Designer = @This
			.OnClick = @_CheckBox5_Click
			.Parent = @GroupBox3
		End With
		' CheckBox11
		With CheckBox11
			.Name = "CheckBox11"
			.Text = "3D"
			.TabIndex = 67
			.Caption = "3D"
			.SetBounds 10, 140, 90, 20
			.Designer = @This
			.OnClick = @_CheckBox5_Click
			.Parent = @GroupBox3
		End With
		' CheckBox12
		With CheckBox12
			.Name = "CheckBox12"
			.Text = "Equalizer"
			.TabIndex = 68
			.Caption = "Equalizer"
			.SetBounds 10, 160, 90, 20
			.Designer = @This
			.OnClick = @_CheckBox5_Click
			.Parent = @GroupBox3
		End With
		' CheckBox13
		With CheckBox13
			.Name = "CheckBox13"
			.Text = "Reverb"
			.TabIndex = 69
			.Caption = "Reverb"
			.SetBounds 10, 180, 90, 20
			.Designer = @This
			.OnClick = @_CheckBox5_Click
			.Parent = @GroupBox3
		End With
		' CheckBox14
		With CheckBox14
			.Name = "CheckBox14"
			.Text = "Volume"
			.TabIndex = 70
			.Caption = "Volume"
			.SetBounds 10, 200, 90, 20
			.Designer = @This
			.OnClick = @_CheckBox5_Click
			.Parent = @GroupBox3
		End With
		' lblFXMSG0900
		With lblFXMSG0900
			.Name = "lblFXMSG0900"
			.Text = "fInGain"
			.TabIndex = 71
			.Caption = "fInGain"
			.Alignment = AlignmentConstants.taRight
			.ID = 1004
			.SetBounds 8, 8, 110, 16
			.Parent = @TabPage9
		End With
		' lblFXMSG0901
		With lblFXMSG0901
			.Name = "lblFXMSG0901"
			.Text = "fReverbMix"
			.TabIndex = 72
			.Caption = "fReverbMix"
			.Alignment = AlignmentConstants.taRight
			.ID = 1004
			.SetBounds 8, 28, 110, 16
			.Parent = @TabPage9
		End With
		' lblFXMSG0902
		With lblFXMSG0902
			.Name = "lblFXMSG0902"
			.Text = "fReverbTime"
			.TabIndex = 73
			.Caption = "fReverbTime"
			.Alignment = AlignmentConstants.taRight
			.ID = 1004
			.SetBounds 8, 48, 110, 16
			.Parent = @TabPage9
		End With
		' lblFXMSG0903
		With lblFXMSG0903
			.Name = "lblFXMSG0903"
			.Text = "fHighFreqRTRatio"
			.TabIndex = 74
			.Caption = "fHighFreqRTRatio"
			.Alignment = AlignmentConstants.taRight
			.SetBounds 8, 68, 110, 16
			.Parent = @TabPage9
		End With
		' tbSet0900
		With tbSet0900
			.Name = "tbSet0900"
			.Text = "1"
			.TabIndex = 75
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.ThumbLength = 20
			.MinValue = -96
			.MaxValue = 0
			.SetBounds 118, 8, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage9
		End With
		' tbSet0901
		With tbSet0901
			.Name = "tbSet0901"
			.Text = "1"
			.TabIndex = 76
			.ThumbLength = 20
			.TickStyle = TickStyles.tsNone
			.ID = 1008
			.TickMark = TickMarks.tmBoth
			.MaxValue = 0
			.MinValue = -96
			.SetBounds 118, 28, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage9
		End With
		' tbSet0902
		With tbSet0902
			.Name = "tbSet0902"
			.Text = "1000"
			.TabIndex = 77
			.ThumbLength = 20
			.TickStyle = TickStyles.tsNone
			.ID = 1008
			.TickMark = TickMarks.tmBoth
			.MinValue = 1
			.MaxValue = 3000000
			.Position = 1000000
			.SetBounds 118, 48, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage9
		End With
		' tbSet0903
		With tbSet0903
			.Name = "tbSet0903"
			.Text = "1000"
			.TabIndex = 78
			.ThumbLength = 20
			.TickMark = TickMarks.tmBoth
			.TickStyle = TickStyles.tsNone
			.MaxValue = 999
			.MinValue = 1
			.SetBounds 118, 68, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage9
		End With
		' lblFXShw0900
		With lblFXShw0900
			.Name = "lblFXShw0900"
			.Text = "0.000"
			.TabIndex = 79
			.Caption = "0.000"
			.Alignment = AlignmentConstants.taRight
			.ID = 1012
			.SetBounds 218, 8, 70, 16
			.Parent = @TabPage9
		End With
		' lblFXShw0901
		With lblFXShw0901
			.Name = "lblFXShw0901"
			.Text = "0.000"
			.TabIndex = 80
			.Caption = "0.000"
			.Alignment = AlignmentConstants.taRight
			.ID = 1012
			.SetBounds 218, 28, 70, 16
			.Parent = @TabPage9
		End With
		' lblFXShw0902
		With lblFXShw0902
			.Name = "lblFXShw0902"
			.Text = "1000.000"
			.TabIndex = 81
			.Caption = "1000.000"
			.Alignment = AlignmentConstants.taRight
			.ID = 1012
			.SetBounds 218, 48, 70, 16
			.Parent = @TabPage9
		End With
		' lblFXShw0903
		With lblFXShw0903
			.Name = "lblFXShw0903"
			.Text = "0.001"
			.TabIndex = 82
			.Caption = "0.001"
			.Alignment = AlignmentConstants.taRight
			.SetBounds 218, 68, 70, 16
			.Parent = @TabPage9
		End With
		' tbSet0100
		With tbSet0100
			.Name = "tbSet0100"
			.Text = "1"
			.TabIndex = 83
			.ThumbLength = 20
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.ID = 1006
			.MaxValue = 100
			.Position = 50
			.SetBounds 118, 8, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage1
		End With
		' tbSet0101
		With tbSet0101
			.Name = "tbSet0101"
			.Text = "1"
			.TabIndex = 84
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.MaxValue = 100
			.Position = 10
			.SetBounds 118, 28, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage1
		End With
		' tbSet0102
		With tbSet0102
			.Name = "tbSet0102"
			.Text = "1"
			.TabIndex = 85
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.MaxValue = 99
			.MinValue = -99
			.Position = 25
			.SetBounds 118, 48, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage1
		End With
		' tbSet0103
		With tbSet0103
			.Name = "tbSet0103"
			.Text = "1000"
			.TabIndex = 86
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.MaxValue = 10000
			.Position = 1100
			.SetBounds 118, 68, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage1
		End With
		' tbSet0104
		With tbSet0104
			.Name = "tbSet0104"
			.Text = "1"
			.TabIndex = 87
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.MaxValue = 1
			.Position = 1
			.SetBounds 118, 88, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage1
		End With
		' tbSet0105
		With tbSet0105
			.Name = "tbSet0105"
			.Text = "1"
			.TabIndex = 88
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.MaxValue = 20
			.Position = 16
			.SetBounds 118, 108, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage1
		End With
		' tbSet0106
		With tbSet0106
			.Name = "tbSet0106"
			.Text = "1"
			.TabIndex = 234
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.MaxValue = 4
			.Position = 3
			.SetBounds 118, 128, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage1
		End With
		' tbSet0200
		With tbSet0200
			.Name = "tbSet0200"
			.Text = "1"
			.TabIndex = 89
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.MaxValue = 60
			.MinValue = -60
			.SetBounds 118, 8, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage2
		End With
		' tbSet0201
		With tbSet0201
			.Name = "tbSet0201"
			.Text = "1000"
			.TabIndex = 90
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.MinValue = 10
			.MaxValue = 500000
			.Position = 10000
			.SetBounds 118, 28, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage2
		End With
		' tbSet0202
		With tbSet0202
			.Name = "tbSet0202"
			.Text = "1"
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.TabIndex = 91
			.MaxValue = 3000
			.MinValue = 50
			.Position = 200
			.SetBounds 118, 48, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage2
		End With
		' tbSet0203
		With tbSet0203
			.Name = "tbSet0203"
			.Text = "1"
			.TabIndex = 92
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.MaxValue = 0
			.MinValue = -60
			.Position = -20
			.SetBounds 118, 68, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage2
		End With
		' tbSet0204
		With tbSet0204
			.Name = "tbSet0204"
			.Text = "1"
			.TabIndex = 93
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.MaxValue = 100
			.Position = 3
			.SetBounds 118, 88, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage2
		End With
		' tbSet0205
		With tbSet0205
			.Name = "tbSet0205"
			.Text = "1"
			.TabIndex = 94
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.MaxValue = 4
			.Position = 4
			.SetBounds 118, 108, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage2
		End With
		' tbSet0300
		With tbSet0300
			.Name = "tbSet0300"
			.Text = "1"
			.TabIndex = 95
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.MinValue = -60
			.MaxValue = 0
			.Position = -18
			.SetBounds 118, 8, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage3
		End With
		' tbSet0301
		With tbSet0301
			.Name = "tbSet0301"
			.Text = "1"
			.TabIndex = 96
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.MaxValue = 100
			.Position = 15
			.SetBounds 118, 28, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage3
		End With
		' tbSet0302
		With tbSet0302
			.Name = "tbSet0302"
			.Text = "1"
			.TabIndex = 97
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.MaxValue = 8000
			.MinValue = 100
			.Position = 2400
			.SetBounds 118, 48, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage3
		End With
		' tbSet0303
		With tbSet0303
			.Name = "tbSet0303"
			.Text = "1"
			.TabIndex = 98
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.MaxValue = 8000
			.MinValue = 100
			.Position = 2400
			.SetBounds 118, 68, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage3
		End With
		' tbSet0304
		With tbSet0304
			.Name = "tbSet0304"
			.Text = "1"
			.TabIndex = 99
			.MaxValue = 8000
			.MinValue = 100
			.Position = 8000
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.SetBounds 118, 88, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage3
		End With
		' tbSet0400
		With tbSet0400
			.Name = "tbSet0400"
			.Text = "1"
			.TabIndex = 100
			.MaxValue = 100
			.Position = 50
			.ID = 1015
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.SetBounds 118, 8, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage4
		End With
		' tbSet0401
		With tbSet0401
			.Name = "tbSet0401"
			.Text = "1"
			.TabIndex = 101
			.MaxValue = 100
			.Position = 50
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.SetBounds 118, 28, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage4
		End With
		' tbSet0402
		With tbSet0402
			.Name = "tbSet0402"
			.Text = "1"
			.TabIndex = 102
			.MaxValue = 2000
			.MinValue = 1
			.Position = 500
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.SetBounds 118, 48, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage4
		End With
		' tbSet0403
		With tbSet0403
			.Name = "tbSet0403"
			.Text = "1"
			.TabIndex = 103
			.MaxValue = 2000
			.MinValue = 1
			.Position = 500
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.SetBounds 118, 68, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage4
		End With
		' tbSet0404
		With tbSet0404
			.Name = "tbSet0404"
			.Text = "1"
			.TabIndex = 104
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.MaxValue = 1
			.SetBounds 118, 88, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage4
		End With
		' tbSet0500
		With tbSet0500
			.Name = "tbSet0500"
			.Text = "1"
			.TabIndex = 105
			.MaxValue = 100
			.Position = 50
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.SetBounds 118, 8, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage5
		End With
		' tbSet0501
		With tbSet0501
			.Name = "tbSet0501"
			.Text = "1"
			.TabIndex = 106
			.MaxValue = 100
			.Position = 100
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.SetBounds 118, 28, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage5
		End With
		' tbSet0502
		With tbSet0502
			.Name = "tbSet0502"
			.Text = "1"
			.TabIndex = 107
			.MaxValue = 99
			.MinValue = -99
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.Position = -50
			.SetBounds 118, 48, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage5
		End With
		' tbSet0503
		With tbSet0503
			.Name = "tbSet0503"
			.Text = "1000"
			.TabIndex = 108
			.MaxValue = 10000
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.Position = 250
			.SetBounds 118, 68, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage5
		End With
		' tbSet0504
		With tbSet0504
			.Name = "tbSet0504"
			.Text = "1"
			.TabIndex = 109
			.MaxValue = 1
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.Position = 1
			.SetBounds 118, 88, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage5
		End With
		' tbSet0505
		With tbSet0505
			.Name = "tbSet0505"
			.Text = "1000"
			.TabIndex = 110
			.MaxValue = 4000
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.Position = 2000
			.SetBounds 118, 108, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage5
		End With
		' tbSet0506
		With tbSet0506
			.Name = "tbSet0506"
			.Text = "1"
			.TabIndex = 111
			.MaxValue = 4
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.Position = 2
			.SetBounds 118, 128, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage5
		End With
		' tbSet0600
		With tbSet0600
			.Name = "tbSet0600"
			.Text = "1"
			.TabIndex = 112
			.MaxValue = 1000
			.MinValue = 1
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.Position = 20
			.SetBounds 118, 8, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage6
		End With
		' tbSet0601
		With tbSet0601
			.Name = "tbSet0601"
			.Text = "1"
			.TabIndex = 113
			.MaxValue = 1
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.SetBounds 118, 28, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage6
		End With
		' tbSet0700
		With tbSet0700
			.Name = "tbSet0700"
			.Text = "1"
			.TabIndex = 114
			.MaxValue = 0
			.MinValue = -10000
			.Position = -1000
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.SetBounds 118, 8, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage7
		End With
		' tbSet0701
		With tbSet0701
			.Name = "tbSet0701"
			.Text = "1"
			.TabIndex = 115
			.MaxValue = 0
			.MinValue = -10000
			.Position = -100
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.SetBounds 118, 28, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage7
		End With
		' tbSet0702
		With tbSet0702
			.Name = "tbSet0702"
			.Text = "1"
			.TabIndex = 116
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.SetBounds 118, 48, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage7
		End With
		' tbSet0703
		With tbSet0703
			.Name = "tbSet0703"
			.Text = "1000"
			.TabIndex = 117
			.MinValue = 100
			.MaxValue = 20000
			.Position = 1490
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.SetBounds 118, 68, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage7
		End With
		' tbSet0704
		With tbSet0704
			.Name = "tbSet0704"
			.Text = "1000"
			.TabIndex = 118
			.MaxValue = 2000
			.MinValue = 100
			.Position = 830
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.SetBounds 118, 88, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage7
		End With
		' tbSet0705
		With tbSet0705
			.Name = "tbSet0705"
			.Text = "1"
			.TabIndex = 119
			.MinValue = -10000
			.MaxValue = 1000
			.Position = -2602
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.SetBounds 118, 108, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage7
		End With
		' tbSet0706
		With tbSet0706
			.Name = "tbSet0706"
			.Text = "1000"
			.TabIndex = 120
			.Position = 7
			.MaxValue = 300
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.SetBounds 118, 128, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage7
		End With
		' tbSet0707
		With tbSet0707
			.Name = "tbSet0707"
			.Text = "1"
			.TabIndex = 121
			.MinValue = -10000
			.MaxValue = 2000
			.Position = 200
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.SetBounds 118, 148, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage7
		End With
		' tbSet0708
		With tbSet0708
			.Name = "tbSet0708"
			.Text = "1000"
			.TabIndex = 122
			.MaxValue = 100
			.Position = 11
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.SetBounds 118, 168, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage7
		End With
		' tbSet0709
		With tbSet0709
			.Name = "tbSet0709"
			.Text = "1"
			.TabIndex = 123
			.MaxValue = 100
			.Position = 100
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.SetBounds 118, 188, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage7
		End With
		' tbSet0710
		With tbSet0710
			.Name = "tbSet0710"
			.Text = "1"
			.TabIndex = 124
			.MaxValue = 100
			.Position = 100
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.SetBounds 118, 208, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage7
		End With
		' tbSet0711
		With tbSet0711
			.Name = "tbSet0711"
			.Text = "1"
			.TabIndex = 125
			.MaxValue = 20000
			.MinValue = 20
			.Position = 5000
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.SetBounds 118, 228, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage7
		End With
		' tbSet0800
		With tbSet0800
			.Name = "tbSet0800"
			.Text = "1"
			.TabIndex = 126
			.MinValue = 80
			.MaxValue = 16000
			.Position = 8000
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.SetBounds 118, 8, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage8
		End With
		' tbSet0801
		With tbSet0801
			.Name = "tbSet0801"
			.Text = "1"
			.TabIndex = 127
			.MinValue = 1
			.MaxValue = 36
			.Position = 12
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.SetBounds 118, 28, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage8
		End With
		' tbSet0802
		With tbSet0802
			.Name = "tbSet0802"
			.Text = "1"
			.TabIndex = 128
			.MaxValue = 15
			.MinValue = -15
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.SetBounds 118, 48, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage8
		End With
		' tbSet1000
		With tbSet1000
			.Name = "tbSet1000"
			.Text = "1"
			.TabIndex = 129
			.MaxValue = 1
			.Position = 1
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.SetBounds 118, 8, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage10
		End With
		' tbSet1001
		With tbSet1001
			.Name = "tbSet1001"
			.Text = "1"
			.TabIndex = 130
			.MaxValue = 1
			.MinValue = -1
			.Position = 1
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.SetBounds 118, 28, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage10
		End With
		' tbSet1002
		With tbSet1002
			.Name = "tbSet1002"
			.Text = "1"
			.TabIndex = 131
			.MaxValue = 100
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.SetBounds 118, 48, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage10
		End With
		' tbSet1003
		With tbSet1003
			.Name = "tbSet1003"
			.Text = "1"
			.TabIndex = 132
			.MaxValue = 1
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.SetBounds 118, 68, 100, 10
			.Designer = @This
			.OnChange = @_tbSet_Change
			.Parent = @TabPage10
		End With
		' lblFXMSG0100
		With lblFXMSG0100
			.Name = "lblFXMSG0100"
			.Text = "fWetDryMix"
			.TabIndex = 133
			.Alignment = AlignmentConstants.taRight
			.ID = 1013
			.Caption = "fWetDryMix"
			.SetBounds 8, 8, 100, 20
			.Parent = @TabPage1
		End With
		' lblFXMSG0101
		With lblFXMSG0101
			.Name = "lblFXMSG0101"
			.Text = "fDepth"
			.TabIndex = 134
			.Alignment = AlignmentConstants.taRight
			.ID = 1013
			.Caption = "fDepth"
			.SetBounds 8, 28, 100, 20
			.Parent = @TabPage1
		End With
		' lblFXMSG0102
		With lblFXMSG0102
			.Name = "lblFXMSG0102"
			.Text = "fFeedback"
			.TabIndex = 135
			.Alignment = AlignmentConstants.taRight
			.ID = 1013
			.Caption = "fFeedback"
			.SetBounds 8, 48, 100, 20
			.Parent = @TabPage1
		End With
		' lblFXMSG0103
		With lblFXMSG0103
			.Name = "lblFXMSG0103"
			.Text = "fFrequency"
			.TabIndex = 136
			.Alignment = AlignmentConstants.taRight
			.ID = 1013
			.Caption = "fFrequency"
			.SetBounds 8, 68, 100, 20
			.Parent = @TabPage1
		End With
		' lblFXMSG0104
		With lblFXMSG0104
			.Name = "lblFXMSG0104"
			.Text = "lWaveform"
			.TabIndex = 137
			.Alignment = AlignmentConstants.taRight
			.ID = 1013
			.Caption = "lWaveform"
			.SetBounds 8, 88, 100, 20
			.Parent = @TabPage1
		End With
		' lblFXMSG0105
		With lblFXMSG0105
			.Name = "lblFXMSG0105"
			.Text = "fDelay"
			.TabIndex = 138
			.Alignment = AlignmentConstants.taRight
			.ID = 1013
			.Caption = "fDelay"
			.SetBounds 8, 108, 100, 20
			.Parent = @TabPage1
		End With
		' lblFXMSG0200
		With lblFXMSG0200
			.Name = "lblFXMSG0200"
			.Text = "fGain"
			.TabIndex = 139
			.Alignment = AlignmentConstants.taRight
			.ID = 1012
			.Caption = "fGain"
			.SetBounds 8, 8, 100, 20
			.Parent = @TabPage2
		End With
		' lblFXMSG0201
		With lblFXMSG0201
			.Name = "lblFXMSG0201"
			.Text = "fAttack"
			.TabIndex = 140
			.Alignment = AlignmentConstants.taRight
			.ID = 1012
			.Caption = "fAttack"
			.SetBounds 8, 28, 100, 20
			.Parent = @TabPage2
		End With
		' lblFXMSG0202
		With lblFXMSG0202
			.Name = "lblFXMSG0202"
			.Text = "fRelease"
			.TabIndex = 141
			.Alignment = AlignmentConstants.taRight
			.ID = 1012
			.Caption = "fRelease"
			.SetBounds 8, 48, 100, 20
			.Parent = @TabPage2
		End With
		' lblFXMSG0203
		With lblFXMSG0203
			.Name = "lblFXMSG0203"
			.Text = "fThreshold"
			.TabIndex = 142
			.Alignment = AlignmentConstants.taRight
			.ID = 1012
			.Caption = "fThreshold"
			.SetBounds 8, 68, 100, 20
			.Parent = @TabPage2
		End With
		' lblFXMSG0204
		With lblFXMSG0204
			.Name = "lblFXMSG0204"
			.Text = "fRatio"
			.TabIndex = 143
			.Alignment = AlignmentConstants.taRight
			.ID = 1012
			.Caption = "fRatio"
			.SetBounds 8, 88, 100, 20
			.Parent = @TabPage2
		End With
		' lblFXMSG0205
		With lblFXMSG0205
			.Name = "lblFXMSG0205"
			.Text = "fPredelay"
			.TabIndex = 144
			.Alignment = AlignmentConstants.taRight
			.Caption = "fPredelay"
			.SetBounds 8, 108, 100, 20
			.Parent = @TabPage2
		End With
		' lblFXMSG0300
		With lblFXMSG0300
			.Name = "lblFXMSG0300"
			.Text = "fGain"
			.TabIndex = 145
			.Caption = "fGain"
			.Alignment = AlignmentConstants.taRight
			.ID = 1015
			.SetBounds 8, 8, 100, 20
			.Parent = @TabPage3
		End With
		' lblFXMSG0301
		With lblFXMSG0301
			.Name = "lblFXMSG0301"
			.Text = "fEdge"
			.TabIndex = 146
			.Caption = "fEdge"
			.Alignment = AlignmentConstants.taRight
			.ID = 1015
			.SetBounds 8, 28, 100, 20
			.Parent = @TabPage3
		End With
		' lblFXMSG0302
		With lblFXMSG0302
			.Name = "lblFXMSG0302"
			.Text = "fPostEQCenterFrequency"
			.TabIndex = 147
			.Caption = "fPostEQCenterFrequency"
			.Alignment = AlignmentConstants.taRight
			.ID = 1015
			.SetBounds 8, 48, 100, 20
			.Parent = @TabPage3
		End With
		' lblFXMSG0303
		With lblFXMSG0303
			.Name = "lblFXMSG0303"
			.Text = "fPostEQBandwidth"
			.TabIndex = 148
			.Caption = "fPostEQBandwidth"
			.Alignment = AlignmentConstants.taRight
			.ID = 1015
			.SetBounds 8, 68, 100, 20
			.Parent = @TabPage3
		End With
		' lblFXMSG0304
		With lblFXMSG0304
			.Name = "lblFXMSG0304"
			.Text = "fPreLowpassCutoff"
			.TabIndex = 149
			.Caption = "fPreLowpassCutoff"
			.Alignment = AlignmentConstants.taRight
			.ID = 1015
			.SetBounds 8, 88, 100, 20
			.Parent = @TabPage3
		End With
		' lblFXMSG0400
		With lblFXMSG0400
			.Name = "lblFXMSG0400"
			.Text = "fWetDryMix"
			.TabIndex = 150
			.Caption = "fWetDryMix"
			.Alignment = AlignmentConstants.taRight
			.ID = 1015
			.SetBounds 8, 8, 100, 20
			.Parent = @TabPage4
		End With
		' lblFXMSG0401
		With lblFXMSG0401
			.Name = "lblFXMSG0401"
			.Text = "fFeedback"
			.TabIndex = 151
			.Alignment = AlignmentConstants.taRight
			.ID = 1015
			.Caption = "fFeedback"
			.SetBounds 8, 28, 100, 20
			.Parent = @TabPage4
		End With
		' lblFXMSG0402
		With lblFXMSG0402
			.Name = "lblFXMSG0402"
			.Text = "fLeftDelay"
			.TabIndex = 152
			.Alignment = AlignmentConstants.taRight
			.ID = 1015
			.Caption = "fLeftDelay"
			.SetBounds 8, 48, 100, 20
			.Parent = @TabPage4
		End With
		' lblFXMSG0403
		With lblFXMSG0403
			.Name = "lblFXMSG0403"
			.Text = "fRightDelay"
			.TabIndex = 153
			.Alignment = AlignmentConstants.taRight
			.ID = 1015
			.Caption = "fRightDelay"
			.SetBounds 8, 68, 100, 20
			.Parent = @TabPage4
		End With
		' lblFXMSG0404
		With lblFXMSG0404
			.Name = "lblFXMSG0404"
			.Text = "lPanDelay"
			.TabIndex = 154
			.Caption = "lPanDelay"
			.Alignment = AlignmentConstants.taRight
			.ID = 1015
			.SetBounds 8, 88, 100, 20
			.Parent = @TabPage4
		End With
		' lblFXMSG0500
		With lblFXMSG0500
			.Name = "lblFXMSG0500"
			.Text = "fWetDryMix"
			.TabIndex = 155
			.Alignment = AlignmentConstants.taRight
			.ID = 1021
			.Caption = "fWetDryMix"
			.SetBounds 8, 8, 100, 20
			.Parent = @TabPage5
		End With
		' lblFXMSG0501
		With lblFXMSG0501
			.Name = "lblFXMSG0501"
			.Text = "fDepth"
			.TabIndex = 156
			.Alignment = AlignmentConstants.taRight
			.Caption = "fDepth"
			.SetBounds 8, 28, 100, 20
			.Parent = @TabPage5
		End With
		' lblFXMSG0502
		With lblFXMSG0502
			.Name = "lblFXMSG0502"
			.Text = "fFeedback"
			.TabIndex = 157
			.Alignment = AlignmentConstants.taRight
			.Caption = "fFeedback"
			.SetBounds 8, 48, 100, 20
			.Parent = @TabPage5
		End With
		' lblFXMSG0503
		With lblFXMSG0503
			.Name = "lblFXMSG0503"
			.Text = "fFrequency"
			.TabIndex = 158
			.Alignment = AlignmentConstants.taRight
			.Caption = "fFrequency"
			.SetBounds 8, 68, 100, 20
			.Parent = @TabPage5
		End With
		' lblFXMSG0504
		With lblFXMSG0504
			.Name = "lblFXMSG0504"
			.Text = "lWaveform"
			.TabIndex = 159
			.Alignment = AlignmentConstants.taRight
			.Caption = "lWaveform"
			.SetBounds 8, 88, 100, 20
			.Parent = @TabPage5
		End With
		' lblFXMSG0505
		With lblFXMSG0505
			.Name = "lblFXMSG0505"
			.Text = "fDelay"
			.TabIndex = 160
			.Alignment = AlignmentConstants.taRight
			.Caption = "fDelay"
			.SetBounds 8, 108, 100, 20
			.Parent = @TabPage5
		End With
		' lblFXMSG0506
		With lblFXMSG0506
			.Name = "lblFXMSG0506"
			.Text = "lPhase"
			.TabIndex = 161
			.Alignment = AlignmentConstants.taRight
			.Caption = "lPhase"
			.SetBounds 8, 128, 100, 20
			.Parent = @TabPage5
		End With
		' lblFXMSG0600
		With lblFXMSG0600
			.Name = "lblFXMSG0600"
			.Text = "dwRateHz"
			.TabIndex = 162
			.Alignment = AlignmentConstants.taRight
			.Caption = "dwRateHz"
			.SetBounds 8, 8, 100, 20
			.Parent = @TabPage6
		End With
		' lblFXMSG0601
		With lblFXMSG0601
			.Name = "lblFXMSG0601"
			.Text = "dwWaveShape"
			.TabIndex = 163
			.Alignment = AlignmentConstants.taRight
			.Caption = "dwWaveShape"
			.SetBounds 8, 28, 100, 20
			.Parent = @TabPage6
		End With
		' lblFXMSG0700
		With lblFXMSG0700
			.Name = "lblFXMSG0700"
			.Text = "lRoom"
			.TabIndex = 164
			.Alignment = AlignmentConstants.taRight
			.Caption = "lRoom"
			.SetBounds 8, 8, 100, 20
			.Parent = @TabPage7
		End With
		' lblFXMSG0701
		With lblFXMSG0701
			.Name = "lblFXMSG0701"
			.Text = "lRoomHF"
			.TabIndex = 165
			.Alignment = AlignmentConstants.taRight
			.Caption = "lRoomHF"
			.SetBounds 8, 28, 100, 20
			.Parent = @TabPage7
		End With
		' lblFXMSG0702
		With lblFXMSG0702
			.Name = "lblFXMSG0702"
			.Text = "flRoomRolloffFactor"
			.TabIndex = 166
			.Alignment = AlignmentConstants.taRight
			.Caption = "flRoomRolloffFactor"
			.SetBounds 8, 48, 100, 20
			.Parent = @TabPage7
		End With
		' lblFXMSG0703
		With lblFXMSG0703
			.Name = "lblFXMSG0703"
			.Text = "flDecayTime"
			.TabIndex = 167
			.Alignment = AlignmentConstants.taRight
			.Caption = "flDecayTime"
			.SetBounds 8, 68, 100, 20
			.Parent = @TabPage7
		End With
		' lblFXMSG0704
		With lblFXMSG0704
			.Name = "lblFXMSG0704"
			.Text = "flDecayHFRatio"
			.TabIndex = 168
			.Alignment = AlignmentConstants.taRight
			.Caption = "flDecayHFRatio"
			.SetBounds 8, 88, 100, 20
			.Parent = @TabPage7
		End With
		' lblFXMSG0705
		With lblFXMSG0705
			.Name = "lblFXMSG0705"
			.Text = "lReflections"
			.TabIndex = 169
			.Alignment = AlignmentConstants.taRight
			.Caption = "lReflections"
			.SetBounds 8, 108, 100, 20
			.Parent = @TabPage7
		End With
		' lblFXMSG0706
		With lblFXMSG0706
			.Name = "lblFXMSG0706"
			.Text = "flReflectionsDelay"
			.TabIndex = 170
			.Alignment = AlignmentConstants.taRight
			.ID = 1036
			.Caption = "flReflectionsDelay"
			.SetBounds 8, 128, 100, 20
			.Parent = @TabPage7
		End With
		' lblFXMSG0707
		With lblFXMSG0707
			.Name = "lblFXMSG0707"
			.Text = "lReverb"
			.TabIndex = 171
			.Alignment = AlignmentConstants.taRight
			.Caption = "lReverb"
			.SetBounds 8, 148, 100, 20
			.Parent = @TabPage7
		End With
		' lblFXMSG0708
		With lblFXMSG0708
			.Name = "lblFXMSG0708"
			.Text = "flReverbDelay"
			.TabIndex = 172
			.Alignment = AlignmentConstants.taRight
			.Caption = "flReverbDelay"
			.SetBounds 8, 168, 100, 20
			.Parent = @TabPage7
		End With
		' lblFXMSG0709
		With lblFXMSG0709
			.Name = "lblFXMSG0709"
			.Text = "flDiffusion"
			.TabIndex = 173
			.Alignment = AlignmentConstants.taRight
			.ID = 1036
			.Caption = "flDiffusion"
			.SetBounds 8, 188, 100, 20
			.Parent = @TabPage7
		End With
		' lblFXMSG0710
		With lblFXMSG0710
			.Name = "lblFXMSG0710"
			.Text = "flDensity"
			.TabIndex = 174
			.Alignment = AlignmentConstants.taRight
			.Caption = "flDensity"
			.SetBounds 8, 208, 100, 20
			.Parent = @TabPage7
		End With
		' lblFXMSG0711
		With lblFXMSG0711
			.Name = "lblFXMSG0711"
			.Text = "flHFReference"
			.TabIndex = 175
			.Alignment = AlignmentConstants.taRight
			.Caption = "flHFReference"
			.SetBounds 8, 228, 100, 20
			.Parent = @TabPage7
		End With
		' lblFXMSG0800
		With lblFXMSG0800
			.Name = "lblFXMSG0800"
			.Text = "fCenter"
			.TabIndex = 176
			.Alignment = AlignmentConstants.taRight
			.ID = 1009
			.Caption = "fCenter"
			.SetBounds 8, 8, 100, 20
			.Parent = @TabPage8
		End With
		' lblFXMSG0801
		With lblFXMSG0801
			.Name = "lblFXMSG0801"
			.Text = "fBandwidth"
			.TabIndex = 177
			.Alignment = AlignmentConstants.taRight
			.ID = 1009
			.Caption = "fBandwidth"
			.SetBounds 8, 28, 100, 20
			.Parent = @TabPage8
		End With
		' lblFXMSG0802
		With lblFXMSG0802
			.Name = "lblFXMSG0802"
			.Text = "fGain"
			.TabIndex = 178
			.Alignment = AlignmentConstants.taRight
			.ID = 1009
			.Caption = "fGain"
			.SetBounds 8, 48, 100, 20
			.Parent = @TabPage8
		End With
		' lblFXMSG1000
		With lblFXMSG1000
			.Name = "lblFXMSG1000"
			.Text = "fTarget"
			.TabIndex = 179
			.Alignment = AlignmentConstants.taRight
			.ID = 1012
			.Caption = "fTarget"
			.SetBounds 8, 8, 100, 20
			.Parent = @TabPage10
		End With
		' lblFXMSG1001
		With lblFXMSG1001
			.Name = "lblFXMSG1001"
			.Text = "fCurrent"
			.TabIndex = 180
			.Alignment = AlignmentConstants.taRight
			.ID = 1012
			.Caption = "fCurrent"
			.SetBounds 8, 28, 100, 20
			.Parent = @TabPage10
		End With
		' lblFXMSG1002
		With lblFXMSG1002
			.Name = "lblFXMSG1002"
			.Text = "fTime"
			.TabIndex = 181
			.Alignment = AlignmentConstants.taRight
			.ID = 1012
			.Caption = "fTime"
			.SetBounds 8, 48, 100, 20
			.Parent = @TabPage10
		End With
		' lblFXMSG1003
		With lblFXMSG1003
			.Name = "lblFXMSG1003"
			.Text = "lCurve"
			.TabIndex = 182
			.Alignment = AlignmentConstants.taRight
			.ID = 1012
			.Caption = "lCurve"
			.SetBounds 8, 68, 100, 20
			.Parent = @TabPage10
		End With
		' lblFXShw0100
		With lblFXShw0100
			.Name = "lblFXShw0100"
			.Text = "50.000"
			.TabIndex = 183
			.Alignment = AlignmentConstants.taRight
			.Caption = "50.000"
			.SetBounds 218, 8, 70, 20
			.Parent = @TabPage1
		End With
		' lblFXShw0101
		With lblFXShw0101
			.Name = "lblFXShw0101"
			.Text = "10.000"
			.TabIndex = 184
			.Alignment = AlignmentConstants.taRight
			.ID = 1021
			.Caption = "10.000"
			.SetBounds 218, 28, 70, 20
			.Parent = @TabPage1
		End With
		' lblFXShw0102
		With lblFXShw0102
			.Name = "lblFXShw0102"
			.Text = "25.000"
			.TabIndex = 185
			.Alignment = AlignmentConstants.taRight
			.ID = 1021
			.Caption = "25.000"
			.SetBounds 218, 48, 70, 20
			.Parent = @TabPage1
		End With
		' lblFXShw0103
		With lblFXShw0103
			.Name = "lblFXShw0103"
			.Text = "1.100"
			.TabIndex = 186
			.Alignment = AlignmentConstants.taRight
			.ID = 1021
			.Caption = "1.100"
			.SetBounds 218, 68, 70, 20
			.Parent = @TabPage1
		End With
		' lblFXShw0104
		With lblFXShw0104
			.Name = "lblFXShw0104"
			.Text = "1.000"
			.TabIndex = 187
			.Alignment = AlignmentConstants.taRight
			.ID = 1021
			.Caption = "1.000"
			.SetBounds 218, 88, 70, 20
			.Parent = @TabPage1
		End With
		' lblFXShw0105
		With lblFXShw0105
			.Name = "lblFXShw0105"
			.Text = "16.000"
			.TabIndex = 188
			.Alignment = AlignmentConstants.taRight
			.ID = 1021
			.Caption = "16.000"
			.SetBounds 218, 108, 70, 20
			.Parent = @TabPage1
		End With
		' lblFXShw0200
		With lblFXShw0200
			.Name = "lblFXShw0200"
			.Text = "0.000"
			.TabIndex = 189
			.Caption = "0.000"
			.Alignment = AlignmentConstants.taRight
			.ID = 1018
			.SetBounds 218, 8, 70, 20
			.Parent = @TabPage2
		End With
		' lblFXShw0201
		With lblFXShw0201
			.Name = "lblFXShw0201"
			.Text = "10.000"
			.TabIndex = 190
			.Caption = "10.000"
			.Alignment = AlignmentConstants.taRight
			.ID = 1018
			.SetBounds 218, 28, 70, 20
			.Parent = @TabPage2
		End With
		' lblFXShw0202
		With lblFXShw0202
			.Name = "lblFXShw0202"
			.Text = "200.000"
			.TabIndex = 191
			.Caption = "200.000"
			.Alignment = AlignmentConstants.taRight
			.ID = 1018
			.SetBounds 218, 48, 70, 20
			.Parent = @TabPage2
		End With
		' lblFXShw0203
		With lblFXShw0203
			.Name = "lblFXShw0203"
			.Text = "-20.000"
			.TabIndex = 192
			.Caption = "-20.000"
			.Alignment = AlignmentConstants.taRight
			.ID = 1018
			.SetBounds 218, 68, 70, 20
			.Parent = @TabPage2
		End With
		' lblFXShw0204
		With lblFXShw0204
			.Name = "lblFXShw0204"
			.Text = "3.000"
			.TabIndex = 193
			.Caption = "3.000"
			.Alignment = AlignmentConstants.taRight
			.ID = 1018
			.SetBounds 218, 88, 70, 20
			.Parent = @TabPage2
		End With
		' lblFXShw0205
		With lblFXShw0205
			.Name = "lblFXShw0205"
			.Text = "4.000"
			.TabIndex = 194
			.Caption = "4.000"
			.Alignment = AlignmentConstants.taRight
			.SetBounds 218, 108, 70, 20
			.Parent = @TabPage2
		End With
		' lblFXShw0300
		With lblFXShw0300
			.Name = "lblFXShw0300"
			.Text = "-18.000"
			.TabIndex = 195
			.Caption = "-18.000"
			.Alignment = AlignmentConstants.taRight
			.ID = 1015
			.SetBounds 218, 8, 70, 20
			.Parent = @TabPage3
		End With
		' lblFXShw0301
		With lblFXShw0301
			.Name = "lblFXShw0301"
			.Text = "15.000"
			.TabIndex = 196
			.Caption = "15.000"
			.Alignment = AlignmentConstants.taRight
			.ID = 1015
			.SetBounds 218, 28, 70, 20
			.Parent = @TabPage3
		End With
		' lblFXShw0302
		With lblFXShw0302
			.Name = "lblFXShw0302"
			.Text = "2400.000"
			.TabIndex = 197
			.Caption = "2400.000"
			.Alignment = AlignmentConstants.taRight
			.ID = 1015
			.SetBounds 218, 48, 70, 20
			.Parent = @TabPage3
		End With
		' lblFXShw0303
		With lblFXShw0303
			.Name = "lblFXShw0303"
			.Text = "2400.000"
			.TabIndex = 198
			.Caption = "2400.000"
			.Alignment = AlignmentConstants.taRight
			.ID = 1015
			.SetBounds 218, 68, 70, 20
			.Parent = @TabPage3
		End With
		' lblFXShw0304
		With lblFXShw0304
			.Name = "lblFXShw0304"
			.Text = "8000.000"
			.TabIndex = 199
			.Caption = "8000.000"
			.Alignment = AlignmentConstants.taRight
			.SetBounds 218, 88, 70, 20
			.Parent = @TabPage3
		End With
		' lblFXShw0400
		With lblFXShw0400
			.Name = "lblFXShw0400"
			.Text = "50.000"
			.TabIndex = 200
			.Alignment = AlignmentConstants.taRight
			.ID = 1015
			.Caption = "50.000"
			.SetBounds 218, 8, 70, 20
			.Parent = @TabPage4
		End With
		' lblFXShw0401
		With lblFXShw0401
			.Name = "lblFXShw0401"
			.Text = "50.000"
			.TabIndex = 201
			.Alignment = AlignmentConstants.taRight
			.ID = 1015
			.Caption = "50.000"
			.SetBounds 218, 28, 70, 20
			.Parent = @TabPage4
		End With
		' lblFXShw0402
		With lblFXShw0402
			.Name = "lblFXShw0402"
			.Text = "500.000"
			.TabIndex = 202
			.Alignment = AlignmentConstants.taRight
			.ID = 1015
			.Caption = "500.000"
			.SetBounds 218, 48, 70, 20
			.Parent = @TabPage4
		End With
		' lblFXShw0403
		With lblFXShw0403
			.Name = "lblFXShw0403"
			.Text = "500.000"
			.TabIndex = 203
			.Caption = "500.000"
			.Alignment = AlignmentConstants.taRight
			.ID = 1015
			.SetBounds 218, 68, 70, 20
			.Parent = @TabPage4
		End With
		' lblFXShw0404
		With lblFXShw0404
			.Name = "lblFXShw0404"
			.Text = "0.000"
			.TabIndex = 204
			.Caption = "0.000"
			.Alignment = AlignmentConstants.taRight
			.SetBounds 218, 88, 70, 20
			.Parent = @TabPage4
		End With
		' lblFXShw0500
		With lblFXShw0500
			.Name = "lblFXShw0500"
			.Text = "50.000"
			.TabIndex = 205
			.Alignment = AlignmentConstants.taRight
			.ID = 1021
			.Caption = "50.000"
			.SetBounds 218, 8, 70, 20
			.Parent = @TabPage5
		End With
		' lblFXShw0501
		With lblFXShw0501
			.Name = "lblFXShw0501"
			.Text = "100.000"
			.TabIndex = 206
			.Alignment = AlignmentConstants.taRight
			.Caption = "100.000"
			.SetBounds 218, 28, 70, 20
			.Parent = @TabPage5
		End With
		' lblFXShw0502
		With lblFXShw0502
			.Name = "lblFXShw0502"
			.Text = "-50.000"
			.TabIndex = 207
			.Alignment = AlignmentConstants.taRight
			.Caption = "-50.000"
			.SetBounds 218, 48, 70, 20
			.Parent = @TabPage5
		End With
		' lblFXShw0503
		With lblFXShw0503
			.Name = "lblFXShw0503"
			.Text = "0.250"
			.TabIndex = 208
			.Alignment = AlignmentConstants.taRight
			.Caption = "0.250"
			.SetBounds 218, 68, 70, 20
			.Parent = @TabPage5
		End With
		' lblFXShw0504
		With lblFXShw0504
			.Name = "lblFXShw0504"
			.Text = "1.000"
			.TabIndex = 209
			.Alignment = AlignmentConstants.taRight
			.Caption = "1.000"
			.SetBounds 218, 88, 70, 20
			.Parent = @TabPage5
		End With
		' lblFXShw0505
		With lblFXShw0505
			.Name = "lblFXShw0505"
			.Text = "2.000"
			.TabIndex = 210
			.Alignment = AlignmentConstants.taRight
			.Caption = "2.000"
			.SetBounds 218, 108, 70, 20
			.Parent = @TabPage5
		End With
		' lblFXShw0506
		With lblFXShw0506
			.Name = "lblFXShw0506"
			.Text = "2.000"
			.TabIndex = 211
			.Alignment = AlignmentConstants.taRight
			.Caption = "2.000"
			.SetBounds 218, 128, 70, 20
			.Parent = @TabPage5
		End With
		' lblFXShw0600
		With lblFXShw0600
			.Name = "lblFXShw0600"
			.Text = "20.000"
			.TabIndex = 212
			.Alignment = AlignmentConstants.taRight
			.Caption = "20.000"
			.SetBounds 218, 8, 70, 20
			.Parent = @TabPage6
		End With
		' lblFXShw0601
		With lblFXShw0601
			.Name = "lblFXShw0601"
			.Text = "0.000"
			.TabIndex = 213
			.Alignment = AlignmentConstants.taRight
			.Caption = "0.000"
			.SetBounds 218, 28, 70, 20
			.Parent = @TabPage6
		End With
		' lblFXShw0700
		With lblFXShw0700
			.Name = "lblFXShw0700"
			.Text = "-1000.000"
			.TabIndex = 214
			.Alignment = AlignmentConstants.taRight
			.Caption = "-1000.000"
			.SetBounds 218, 8, 70, 20
			.Parent = @TabPage7
		End With
		' lblFXShw0701
		With lblFXShw0701
			.Name = "lblFXShw0701"
			.Text = "-100.000"
			.TabIndex = 215
			.Alignment = AlignmentConstants.taRight
			.Caption = "-100.000"
			.SetBounds 218, 28, 70, 20
			.Parent = @TabPage7
		End With
		' lblFXShw0702
		With lblFXShw0702
			.Name = "lblFXShw0702"
			.Text = "0.000"
			.TabIndex = 216
			.Alignment = AlignmentConstants.taRight
			.Caption = "0.000"
			.SetBounds 218, 48, 70, 20
			.Parent = @TabPage7
		End With
		' lblFXShw0703
		With lblFXShw0703
			.Name = "lblFXShw0703"
			.Text = "1.490"
			.TabIndex = 217
			.Alignment = AlignmentConstants.taRight
			.Caption = "1.490"
			.SetBounds 218, 68, 70, 20
			.Parent = @TabPage7
		End With
		' lblFXShw0704
		With lblFXShw0704
			.Name = "lblFXShw0704"
			.Text = "0.830"
			.TabIndex = 218
			.Alignment = AlignmentConstants.taRight
			.Caption = "0.830"
			.SetBounds 218, 88, 70, 20
			.Parent = @TabPage7
		End With
		' lblFXShw0705
		With lblFXShw0705
			.Name = "lblFXShw0705"
			.Text = "-2602.000"
			.TabIndex = 219
			.Alignment = AlignmentConstants.taRight
			.Caption = "-2602.000"
			.SetBounds 218, 108, 70, 20
			.Parent = @TabPage7
		End With
		' lblFXShw0706
		With lblFXShw0706
			.Name = "lblFXShw0706"
			.Text = "0.007"
			.TabIndex = 220
			.Alignment = AlignmentConstants.taRight
			.Caption = "0.007"
			.SetBounds 218, 128, 70, 20
			.Parent = @TabPage7
		End With
		' lblFXShw0707
		With lblFXShw0707
			.Name = "lblFXShw0707"
			.Text = "200.000"
			.TabIndex = 221
			.Alignment = AlignmentConstants.taRight
			.Caption = "200.000"
			.SetBounds 218, 148, 70, 20
			.Parent = @TabPage7
		End With
		' lblFXShw0708
		With lblFXShw0708
			.Name = "lblFXShw0708"
			.Text = "0.011"
			.TabIndex = 222
			.Alignment = AlignmentConstants.taRight
			.Caption = "0.011"
			.SetBounds 218, 168, 70, 20
			.Parent = @TabPage7
		End With
		' lblFXShw0709
		With lblFXShw0709
			.Name = "lblFXShw0709"
			.Text = "100.000"
			.TabIndex = 223
			.Alignment = AlignmentConstants.taRight
			.Caption = "100.000"
			.SetBounds 218, 188, 70, 20
			.Parent = @TabPage7
		End With
		' lblFXShw0710
		With lblFXShw0710
			.Name = "lblFXShw0710"
			.Text = "100.000"
			.TabIndex = 224
			.Alignment = AlignmentConstants.taRight
			.Caption = "100.000"
			.SetBounds 218, 208, 70, 20
			.Parent = @TabPage7
		End With
		' lblFXShw0711
		With lblFXShw0711
			.Name = "lblFXShw0711"
			.Text = "5000.000"
			.TabIndex = 225
			.Alignment = AlignmentConstants.taRight
			.Caption = "5000.000"
			.SetBounds 218, 228, 70, 20
			.Parent = @TabPage7
		End With
		' lblFXShw0800
		With lblFXShw0800
			.Name = "lblFXShw0800"
			.Text = "8000.000"
			.TabIndex = 226
			.Alignment = AlignmentConstants.taRight
			.ID = 1009
			.Caption = "8000.000"
			.SetBounds 218, 8, 70, 20
			.Parent = @TabPage8
		End With
		' lblFXShw0801
		With lblFXShw0801
			.Name = "lblFXShw0801"
			.Text = "12.000"
			.TabIndex = 227
			.Alignment = AlignmentConstants.taRight
			.ID = 1009
			.Caption = "12.000"
			.SetBounds 218, 28, 70, 20
			.Parent = @TabPage8
		End With
		' lblFXShw0802
		With lblFXShw0802
			.Name = "lblFXShw0802"
			.Text = "0.000"
			.TabIndex = 228
			.Alignment = AlignmentConstants.taRight
			.Caption = "0.000"
			.SetBounds 218, 48, 70, 20
			.Parent = @TabPage8
		End With
		' lblFXShw1000
		With lblFXShw1000
			.Name = "lblFXShw1000"
			.Text = "1.000"
			.TabIndex = 229
			.Alignment = AlignmentConstants.taRight
			.ID = 1012
			.Caption = "1.000"
			.SetBounds 218, 8, 70, 20
			.Parent = @TabPage10
		End With
		' lblFXShw1001
		With lblFXShw1001
			.Name = "lblFXShw1001"
			.Text = "1.000"
			.TabIndex = 230
			.Alignment = AlignmentConstants.taRight
			.ID = 1012
			.Caption = "1.000"
			.SetBounds 218, 28, 70, 20
			.Parent = @TabPage10
		End With
		' lblFXShw1002
		With lblFXShw1002
			.Name = "lblFXShw1002"
			.Text = "0.000"
			.TabIndex = 231
			.Alignment = AlignmentConstants.taRight
			.ID = 1012
			.Caption = "0.000"
			.SetBounds 218, 48, 70, 20
			.Parent = @TabPage10
		End With
		' lblFXShw1003
		With lblFXShw1003
			.Name = "lblFXShw1003"
			.Text = "0.000"
			.TabIndex = 232
			.Alignment = AlignmentConstants.taRight
			.Caption = "0.000"
			.SetBounds 218, 68, 70, 20
			.Parent = @TabPage10
		End With
		' lblFXMSG0106
		With lblFXMSG0106
			.Name = "lblFXMSG0106"
			.Text = "lPhase"
			.TabIndex = 233
			.Caption = "lPhase"
			.Alignment = AlignmentConstants.taRight
			.ID = 1022
			.SetBounds 8, 128, 100, 20
			.Parent = @TabPage1
		End With
		' lblFXShw0106
		With lblFXShw0106
			.Name = "lblFXShw0106"
			.Text = "3.000"
			.TabIndex = 235
			.Alignment = AlignmentConstants.taRight
			.Caption = "3.000"
			.SetBounds 218, 128, 70, 20
			.Parent = @TabPage1
		End With
		' OpenFileDialog1
		With OpenFileDialog1
			.Name = "OpenFileDialog1"
			.SetBounds 0, 0, 16, 16
			.Parent = @This
		End With
		' tbEQ00
		With tbEQ00
			.Name = "tbEQ00"
			.Text = "TrackBar5"
			.TabIndex = 237
			.Style = TrackBarOrientation.tbVertical
			.MinValue = -15
			.MaxValue = 15
			.Position = 0
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.ID = 1002
			.ThumbLength = 15
			.SetBounds 110, 30, 20, 90
			.Designer = @This
			.OnChange = @_tbEQ00_Change
			.Parent = @GroupBox8
		End With
		' tbEQ01
		With tbEQ01
			.Name = "tbEQ01"
			.Text = "TrackBar5"
			.TabIndex = 239
			.Style = TrackBarOrientation.tbVertical
			.MinValue = -15
			.MaxValue = 15
			.Position = 0
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.ThumbLength = 15
			.Designer = @This
			.OnChange = @_tbEQ00_Change
			.SetBounds 140, 30, 20, 90
			.Parent = @GroupBox8
		End With
		' tbEQ02
		With tbEQ02
			.Name = "tbEQ02"
			.Text = "TrackBar5"
			.TabIndex = 241
			.Style = TrackBarOrientation.tbVertical
			.MinValue = -15
			.MaxValue = 15
			.Position = 0
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.ThumbLength = 15
			.Designer = @This
			.OnChange = @_tbEQ00_Change
			.SetBounds 170, 30, 20, 90
			.Parent = @GroupBox8
		End With
		' tbEQ03
		With tbEQ03
			.Name = "tbEQ03"
			.Text = "TrackBar5"
			.TabIndex = 243
			.Style = TrackBarOrientation.tbVertical
			.MinValue = -15
			.MaxValue = 15
			.Position = 0
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.ThumbLength = 15
			.Designer = @This
			.OnChange = @_tbEQ00_Change
			.SetBounds 200, 30, 20, 90
			.Parent = @GroupBox8
		End With
		' tbEQ04
		With tbEQ04
			.Name = "tbEQ04"
			.Text = "TrackBar5"
			.TabIndex = 245
			.Style = TrackBarOrientation.tbVertical
			.MinValue = -15
			.MaxValue = 15
			.Position = 0
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.ThumbLength = 15
			.Designer = @This
			.OnChange = @_tbEQ00_Change
			.SetBounds 230, 30, 20, 90
			.Parent = @GroupBox8
		End With
		' tbEQ05
		With tbEQ05
			.Name = "tbEQ05"
			.Text = "TrackBar5"
			.TabIndex = 247
			.Style = TrackBarOrientation.tbVertical
			.MinValue = -15
			.MaxValue = 15
			.Position = 0
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.ThumbLength = 15
			.Designer = @This
			.OnChange = @_tbEQ00_Change
			.SetBounds 260, 30, 20, 90
			.Parent = @GroupBox8
		End With
		' tbEQ06
		With tbEQ06
			.Name = "tbEQ06"
			.Text = "TrackBar5"
			.TabIndex = 249
			.Style = TrackBarOrientation.tbVertical
			.MinValue = -15
			.MaxValue = 15
			.Position = 0
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.ThumbLength = 15
			.Designer = @This
			.OnChange = @_tbEQ00_Change
			.SetBounds 290, 30, 20, 90
			.Parent = @GroupBox8
		End With
		' tbEQ07
		With tbEQ07
			.Name = "tbEQ07"
			.Text = "TrackBar5"
			.TabIndex = 251
			.Style = TrackBarOrientation.tbVertical
			.MinValue = -15
			.MaxValue = 15
			.Position = 0
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.ThumbLength = 15
			.Designer = @This
			.OnChange = @_tbEQ00_Change
			.SetBounds 320, 30, 20, 90
			.Parent = @GroupBox8
		End With
		' tbEQ08
		With tbEQ08
			.Name = "tbEQ08"
			.Text = "TrackBar5"
			.TabIndex = 253
			.Style = TrackBarOrientation.tbVertical
			.MinValue = -15
			.MaxValue = 15
			.Position = 0
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.ThumbLength = 15
			.Designer = @This
			.OnChange = @_tbEQ00_Change
			.SetBounds 350, 30, 20, 90
			.Parent = @GroupBox8
		End With
		' tbEQ09
		With tbEQ09
			.Name = "tbEQ09"
			.Text = "TrackBar5"
			.TabIndex = 255
			.Style = TrackBarOrientation.tbVertical
			.MinValue = -15
			.MaxValue = 15
			.Position = 0
			.TickStyle = TickStyles.tsNone
			.TickMark = TickMarks.tmBoth
			.ThumbLength = 15
			.Designer = @This
			.OnChange = @_tbEQ00_Change
			.SetBounds 380, 30, 20, 90
			.Parent = @GroupBox8
		End With
		' lblEQ00
		With lblEQ00
			.Name = "lblEQ00"
			.Text = "0"
			.TabIndex = 238
			.Alignment = AlignmentConstants.taCenter
			.Caption = "0"
			.SetBounds 110, 120, 20, 16
			.Parent = @GroupBox8
		End With
		' lblEQ01
		With lblEQ01
			.Name = "lblEQ01"
			.Text = "0"
			.TabIndex = 240
			.Alignment = AlignmentConstants.taCenter
			.ID = 1020
			.SetBounds 140, 120, 20, 16
			.Parent = @GroupBox8
		End With
		' lblEQ02
		With lblEQ02
			.Name = "lblEQ02"
			.Text = "0"
			.TabIndex = 242
			.Alignment = AlignmentConstants.taCenter
			.ID = 1020
			.SetBounds 170, 120, 20, 16
			.Parent = @GroupBox8
		End With
		' lblEQ03
		With lblEQ03
			.Name = "lblEQ03"
			.Text = "0"
			.TabIndex = 244
			.Alignment = AlignmentConstants.taCenter
			.ID = 1020
			.SetBounds 200, 120, 20, 16
			.Parent = @GroupBox8
		End With
		' lblEQ04
		With lblEQ04
			.Name = "lblEQ04"
			.Text = "0"
			.TabIndex = 246
			.Alignment = AlignmentConstants.taCenter
			.ID = 1020
			.SetBounds 230, 120, 20, 16
			.Parent = @GroupBox8
		End With
		' lblEQ05
		With lblEQ05
			.Name = "lblEQ05"
			.Text = "0"
			.TabIndex = 248
			.Alignment = AlignmentConstants.taCenter
			.ID = 1020
			.SetBounds 260, 120, 20, 16
			.Parent = @GroupBox8
		End With
		' lblEQ06
		With lblEQ06
			.Name = "lblEQ06"
			.Text = "0"
			.TabIndex = 250
			.Alignment = AlignmentConstants.taCenter
			.ID = 1020
			.SetBounds 290, 120, 20, 16
			.Parent = @GroupBox8
		End With
		' lblEQ07
		With lblEQ07
			.Name = "lblEQ07"
			.Text = "0"
			.TabIndex = 252
			.Alignment = AlignmentConstants.taCenter
			.ID = 1020
			.SetBounds 320, 120, 20, 16
			.Parent = @GroupBox8
		End With
		' lblEQ08
		With lblEQ08
			.Name = "lblEQ08"
			.Text = "0"
			.TabIndex = 254
			.Alignment = AlignmentConstants.taCenter
			.ID = 1020
			.SetBounds 350, 120, 20, 16
			.Parent = @GroupBox8
		End With
		' lblEQ09
		With lblEQ09
			.Name = "lblEQ09"
			.Text = "0"
			.TabIndex = 256
			.Alignment = AlignmentConstants.taCenter
			.SetBounds 380, 120, 20, 16
			.Parent = @GroupBox8
		End With
		' ComboBoxEdit6
		With ComboBoxEdit6
			.Name = "ComboBoxEdit6"
			.Text = "ComboBoxEdit6"
			.TabIndex = 257
			.SetBounds 10, 50, 90, 21
			.Designer = @This
			.OnSelected = @_ComboBoxEdit6_Selected
			.Parent = @GroupBox8
		End With
		' lblEQB00
		With lblEQB00
			.Name = "lblEQB00"
			.Text = "60"
			.TabIndex = 258
			.Alignment = AlignmentConstants.taCenter
			.ID = 1031
			.Caption = "60"
			.SetBounds 110, 20, 20, 16
			.Parent = @GroupBox8
		End With
		' lblEQB01
		With lblEQB01
			.Name = "lblEQB01"
			.Text = "170"
			.TabIndex = 259
			.Alignment = AlignmentConstants.taCenter
			.ID = 1031
			.Caption = "170"
			.SetBounds 140, 20, 20, 16
			.Parent = @GroupBox8
		End With
		' lblEQB02
		With lblEQB02
			.Name = "lblEQB02"
			.Text = "310"
			.TabIndex = 260
			.Alignment = AlignmentConstants.taCenter
			.ID = 1031
			.Caption = "310"
			.SetBounds 170, 20, 20, 16
			.Parent = @GroupBox8
		End With
		' lblEQB03
		With lblEQB03
			.Name = "lblEQB03"
			.Text = "600"
			.TabIndex = 261
			.Alignment = AlignmentConstants.taCenter
			.ID = 1031
			.Caption = "600"
			.SetBounds 200, 20, 20, 16
			.Parent = @GroupBox8
		End With
		' lblEQB04
		With lblEQB04
			.Name = "lblEQB04"
			.Text = "1K"
			.TabIndex = 262
			.Alignment = AlignmentConstants.taCenter
			.ID = 1031
			.Caption = "1K"
			.SetBounds 230, 20, 20, 16
			.Parent = @GroupBox8
		End With
		' lblEQB05
		With lblEQB05
			.Name = "lblEQB05"
			.Text = "3K"
			.TabIndex = 263
			.Caption = "3K"
			.Alignment = AlignmentConstants.taCenter
			.ID = 1031
			.SetBounds 260, 20, 20, 16
			.Parent = @GroupBox8
		End With
		' lblEQB06
		With lblEQB06
			.Name = "lblEQB06"
			.Text = "6K"
			.TabIndex = 264
			.Caption = "6K"
			.Alignment = AlignmentConstants.taCenter
			.ID = 1031
			.SetBounds 290, 20, 20, 16
			.Parent = @GroupBox8
		End With
		' lblEQB07
		With lblEQB07
			.Name = "lblEQB07"
			.Text = "12K"
			.TabIndex = 265
			.Caption = "12K"
			.Alignment = AlignmentConstants.taCenter
			.ID = 1031
			.SetBounds 320, 20, 20, 16
			.Parent = @GroupBox8
		End With
		' lblEQB08
		With lblEQB08
			.Name = "lblEQB08"
			.Text = "14K"
			.TabIndex = 266
			.Caption = "14K"
			.Alignment = AlignmentConstants.taCenter
			.ID = 1031
			.SetBounds 350, 20, 20, 16
			.Parent = @GroupBox8
		End With
		' lblEQB09
		With lblEQB09
			.Name = "lblEQB09"
			.Text = "16K"
			.TabIndex = 267
			.Caption = "16K"
			.Alignment = AlignmentConstants.taCenter
			.SetBounds 380, 20, 20, 16
			.Parent = @GroupBox8
		End With
		' Animate1
		With Animate1
			.Name = "Animate1"
			.Text = "Animate1"
			.SetBounds 70, -10, 0, 0
			.Designer = @This
			.Parent = @This
		End With
		' CheckBox15
		With CheckBox15
			.Name = "CheckBox15"
			.Text = "Dark Mode"
			.TabIndex = 265
			.Caption = "Dark Mode"
			.SetBounds 10, 260, 80, 20
			.Designer = @This
			.OnClick = @_CheckBox15_Click
			.Parent = @GroupBox3
		End With
	End Constructor
	
	Private Sub frmBassType._CheckBox15_Click(ByRef Sender As CheckBox)
		(*Cast(frmBassType Ptr, Sender.Designer)).CheckBox15_Click(Sender)
	End Sub
	
	Private Sub frmBassType._ComboBoxEdit6_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		(*Cast(frmBassType Ptr, Sender.Designer)).ComboBoxEdit6_Selected(Sender, ItemIndex)
	End Sub
	
	Private Sub frmBassType._tbEQ00_Change(ByRef Sender As TrackBar, Position As Integer)
		(*Cast(frmBassType Ptr, Sender.Designer)).tbEQ00_Change(Sender, Position)
	End Sub
	
	Private Sub frmBassType._TextBox2_DblClick(ByRef Sender As Control)
		(*Cast(frmBassType Ptr, Sender.Designer)).TextBox2_DblClick(Sender)
	End Sub
	
	Private Sub frmBassType._TextBox1_DblClick(ByRef Sender As Control)
		(*Cast(frmBassType Ptr, Sender.Designer)).TextBox1_DblClick(Sender)
	End Sub
	
	Private Sub frmBassType._tbSet_Change(ByRef Sender As TrackBar, Position As Integer)
		(*Cast(frmBassType Ptr, Sender.Designer)).tbSet_Change(Sender, Position)
	End Sub
	
	Private Sub frmBassType._CheckBox5_Click(ByRef Sender As CheckBox)
		(*Cast(frmBassType Ptr, Sender.Designer)).CheckBox5_Click(Sender)
	End Sub
	
	Private Sub frmBassType._RadioButton1_Click(ByRef Sender As RadioButton)
		(*Cast(frmBassType Ptr, Sender.Designer)).RadioButton1_Click(Sender)
	End Sub
	
	Private Sub frmBassType._TrackBar4_Change(ByRef Sender As TrackBar, Position As Integer)
		(*Cast(frmBassType Ptr, Sender.Designer)).TrackBar4_Change(Sender, Position)
	End Sub
	
	Private Sub frmBassType._CommandButton24_Click(ByRef Sender As Control)
		(*Cast(frmBassType Ptr, Sender.Designer)).CommandButton24_Click(Sender)
	End Sub
	
	Private Sub frmBassType._TimerComponent4_Timer(ByRef Sender As TimerComponent)
		(*Cast(frmBassType Ptr, Sender.Designer)).TimerComponent4_Timer(Sender)
	End Sub
	
	Private Sub frmBassType._CommandButton23_Click(ByRef Sender As Control)
		(*Cast(frmBassType Ptr, Sender.Designer)).CommandButton23_Click(Sender)
	End Sub
	
	Private Sub frmBassType._CheckBox4_Click(ByRef Sender As CheckBox)
		(*Cast(frmBassType Ptr, Sender.Designer)).CheckBox4_Click(Sender)
	End Sub
	
	Private Sub frmBassType._CommandButton10_Click(ByRef Sender As Control)
		(*Cast(frmBassType Ptr, Sender.Designer)).CommandButton10_Click(Sender)
	End Sub
	
	Private Sub frmBassType._CommandButton9_Click(ByRef Sender As Control)
		(*Cast(frmBassType Ptr, Sender.Designer)).CommandButton9_Click(Sender)
	End Sub
	
	Private Sub frmBassType._CheckBox3_Click(ByRef Sender As CheckBox)
		(*Cast(frmBassType Ptr, Sender.Designer)).CheckBox3_Click(Sender)
	End Sub
	
	Private Sub frmBassType._TimerComponent3_Timer(ByRef Sender As TimerComponent)
		(*Cast(frmBassType Ptr, Sender.Designer)).TimerComponent3_Timer(Sender)
	End Sub
	
	Private Sub frmBassType._CommandButton12_Click(ByRef Sender As Control)
		(*Cast(frmBassType Ptr, Sender.Designer)).CommandButton12_Click(Sender)
	End Sub
	
	Private Sub frmBassType._CommandButton8_Click(ByRef Sender As Control)
		(*Cast(frmBassType Ptr, Sender.Designer)).CommandButton8_Click(Sender)
	End Sub
	
	Private Sub frmBassType._TrackBar3_Change(ByRef Sender As TrackBar, Position As Integer)
		(*Cast(frmBassType Ptr, Sender.Designer)).TrackBar3_Change(Sender, Position)
	End Sub
	
	Private Sub frmBassType._ComboBoxEdit2_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		(*Cast(frmBassType Ptr, Sender.Designer)).ComboBoxEdit2_Selected(Sender, ItemIndex)
	End Sub
	
	Private Sub frmBassType._ComboBoxEdit4_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		(*Cast(frmBassType Ptr, Sender.Designer)).ComboBoxEdit4_Selected(Sender, ItemIndex)
	End Sub
	
	Private Sub frmBassType._Picture1_Click(ByRef Sender As Picture)
		(*Cast(frmBassType Ptr, Sender.Designer)).Picture1_Click(Sender)
	End Sub
	
	Private Sub frmBassType._TimerComponent2_Timer(ByRef Sender As TimerComponent)
		(*Cast(frmBassType Ptr, Sender.Designer)).TimerComponent2_Timer(Sender)
	End Sub
	
	Private Sub frmBassType._CheckBox1_Click(ByRef Sender As CheckBox)
		(*Cast(frmBassType Ptr, Sender.Designer)).CheckBox1_Click(Sender)
	End Sub
	
	Private Sub frmBassType._TrackBar2_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		(*Cast(frmBassType Ptr, Sender.Designer)).TrackBar2_MouseUp(Sender, MouseButton, x, y, Shift)
	End Sub
	
	Private Sub frmBassType._TrackBar2_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		(*Cast(frmBassType Ptr, Sender.Designer)).TrackBar2_MouseDown(Sender, MouseButton, x, y, Shift)
	End Sub
	
	Private Sub frmBassType._TrackBar1_Change(ByRef Sender As TrackBar, Position As Integer)
		(*Cast(frmBassType Ptr, Sender.Designer)).TrackBar1_Change(Sender, Position)
	End Sub
	
	Private Sub frmBassType._TrackBar2_Change(ByRef Sender As TrackBar, Position As Integer)
		(*Cast(frmBassType Ptr, Sender.Designer)).TrackBar2_Change(Sender, Position)
	End Sub
	
	Private Sub frmBassType._TimerComponent1_Timer(ByRef Sender As TimerComponent)
		(*Cast(frmBassType Ptr, Sender.Designer)).TimerComponent1_Timer(Sender)
	End Sub
	
	Private Sub frmBassType._ComboBoxEdit1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		(*Cast(frmBassType Ptr, Sender.Designer)).ComboBoxEdit1_Selected(Sender, ItemIndex)
	End Sub
	
	Private Sub frmBassType._CommandButton5_Click(ByRef Sender As Control)
		(*Cast(frmBassType Ptr, Sender.Designer)).CommandButton5_Click(Sender)
	End Sub
	
	Private Sub frmBassType._CommandButton4_Click(ByRef Sender As Control)
		(*Cast(frmBassType Ptr, Sender.Designer)).CommandButton4_Click(Sender)
	End Sub
	
	Private Sub frmBassType._CommandButton3_Click(ByRef Sender As Control)
		(*Cast(frmBassType Ptr, Sender.Designer)).CommandButton3_Click(Sender)
	End Sub
	
	Private Sub frmBassType._CommandButton6_Click(ByRef Sender As Control)
		(*Cast(frmBassType Ptr, Sender.Designer)).CommandButton6_Click(Sender)
	End Sub
	
	Private Sub frmBassType._CommandButton1_Click(ByRef Sender As Control)
		(*Cast(frmBassType Ptr, Sender.Designer)).CommandButton1_Click(Sender)
	End Sub
	
	Private Sub frmBassType._Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		(*Cast(frmBassType Ptr, Sender.Designer)).Form_Close(Sender, Action)
	End Sub
	
	Private Sub frmBassType._Form_Create(ByRef Sender As Control)
		(*Cast(frmBassType Ptr, Sender.Designer)).Form_Create(Sender)
	End Sub

	InitDarkMode()
	
	Dim Shared frmBass As frmBassType
	
	#ifndef _NOT_AUTORUN_FORMS_
		#define _NOT_AUTORUN_FORMS_
		
		frmBass.Show
		
		App.Run
		
	#endif
'#End Region

Private Sub frmBassType.VolumeSet()
	Dim As Single Volume = TrackBar4.Position / 100
	
	BASS_ChannelSetAttribute(StreamSelected(), BASS_ATTRIB_VOL, Volume)
End Sub

Private Sub frmBassType.VolumeGet()
	Dim As Single Volume
	
	BASS_ChannelGetAttribute(StreamSelected(), BASS_ATTRIB_VOL, @Volume)
	
	TrackBar4.Position = Volume * 100
End Sub

Private Function frmBassType.StreamSelected() As HSTREAM
	If RadioButton1.Checked Then
		Return bPlayback.Stream
	ElseIf RadioButton2.Checked Then
		Return bRecord.Stream
	ElseIf RadioButton3.Checked Then
		Return bRaido.Stream
	EndIf
End Function

' update stream title from metacdata
Private Sub frmBassType.OnRaidoMeta(Owner As Any Ptr, Meta As ZString Ptr)
	(*Cast(frmBassType Ptr, Owner)).TextBox5.Text = *Meta
End Sub

Private Sub frmBassType.OnRaidoStall(Owner As Any Ptr)
	(*Cast(frmBassType Ptr, Owner)).TimerComponent4.Enabled = True ' start buffer monitoring
End Sub

Private Sub frmBassType.OnRaidoFree(Owner As Any Ptr)
	(*Cast(frmBassType Ptr, Owner)).Label5.Text = "not playing"
	(*Cast(frmBassType Ptr, Owner)).Label6.Text = ""
	(*Cast(frmBassType Ptr, Owner)).TextBox5.Text = ""
End Sub

Private Sub frmBassType.OnRaidoStatus(Owner As Any Ptr, Status As ZString Ptr)
	(*Cast(frmBassType Ptr, Owner)).Label6.Text = *Status
End Sub

Private Sub frmBassType.Form_Create(ByRef Sender As Control)

	bRaido.OnMeta = @OnRaidoMeta
	bRaido.OnStall = @OnRaidoStall
	bRaido.OnFree = @OnRaidoFree
	bRaido.OnStatus = @OnRaidoStatus
	
	ComboBoxEdit3.AddItem "48000 Hz mono 16-bit"
	ComboBoxEdit3.AddItem "48000 Hz stereo 16-bit"
	ComboBoxEdit3.AddItem "44100 Hz mono 16-bit"
	ComboBoxEdit3.AddItem "44100 Hz stereo 16-bit"
	ComboBoxEdit3.AddItem "22050 Hz mono 16-bit"
	ComboBoxEdit3.AddItem "22050 Hz stereo 16-bit"
	
	fxPara(1) = @bfdCHO
	fxPara(2) = @bfdCOM
	fxPara(3) = @bfdDIS
	fxPara(4) = @bfdECH
	fxPara(5) = @bfdFLA
	fxPara(6) = @bfdGAR
	fxPara(7) = @bfdI3D
	fxPara(8) = @bfdPAR
	fxPara(9) = @bfdREV
	fxPara(10) = @bfVOL
	
	fxParaC(1) = 6
	fxParaC(2) = 5
	fxParaC(3) = 4
	fxParaC(4) = 4
	fxParaC(5) = 6
	fxParaC(6) = 1
	fxParaC(7) = 11
	fxParaC(8) = 2
	fxParaC(9) = 3
	fxParaC(10) = 3
	
	fxCtlTab(1) = @TabPage1
	fxCtlTab(2) = @TabPage2
	fxCtlTab(3) = @TabPage3
	fxCtlTab(4) = @TabPage4
	fxCtlTab(5) = @TabPage5
	fxCtlTab(6) = @TabPage6
	fxCtlTab(7) = @TabPage7
	fxCtlTab(8) = @TabPage8
	fxCtlTab(9) = @TabPage9
	fxCtlTab(10) = @TabPage10
	
	fxCtlChk(1) = @CheckBox5
	fxCtlChk(2) = @CheckBox6
	fxCtlChk(3) = @CheckBox7
	fxCtlChk(4) = @CheckBox8
	fxCtlChk(5) = @CheckBox9
	fxCtlChk(6) = @CheckBox10
	fxCtlChk(7) = @CheckBox11
	fxCtlChk(8) = @CheckBox12
	fxCtlChk(9) = @CheckBox13
	fxCtlChk(10) = @CheckBox14
	
	fxCtlMsg(1, 0) = @lblFXMSG0100
	fxCtlMsg(1, 1) = @lblFXMSG0101
	fxCtlMsg(1, 2) = @lblFXMSG0102
	fxCtlMsg(1, 3) = @lblFXMSG0103
	fxCtlMsg(1, 4) = @lblFXMSG0104
	fxCtlMsg(1, 5) = @lblFXMSG0105
	fxCtlMsg(1, 6) = @lblFXMSG0106
	fxCtlShow(1, 0) = @lblFXShw0100
	fxCtlShow(1, 1) = @lblFXShw0101
	fxCtlShow(1, 2) = @lblFXShw0102
	fxCtlShow(1, 3) = @lblFXShw0103
	fxCtlShow(1, 4) = @lblFXShw0104
	fxCtlShow(1, 5) = @lblFXShw0105
	fxCtlShow(1, 6) = @lblFXShw0106
	fxCtlTrack(1, 0) = @tbSet0100
	fxCtlTrack(1, 1) = @tbSet0101
	fxCtlTrack(1, 2) = @tbSet0102
	fxCtlTrack(1, 3) = @tbSet0103
	fxCtlTrack(1, 4) = @tbSet0104
	fxCtlTrack(1, 5) = @tbSet0105
	fxCtlTrack(1, 6) = @tbSet0106
	
	fxCtlMsg(2, 0) = @lblFXMSG0200
	fxCtlMsg(2, 1) = @lblFXMSG0201
	fxCtlMsg(2, 2) = @lblFXMSG0202
	fxCtlMsg(2, 3) = @lblFXMSG0203
	fxCtlMsg(2, 4) = @lblFXMSG0204
	fxCtlMsg(2, 5) = @lblFXMSG0205
	fxCtlShow(2, 0) = @lblFXShw0200
	fxCtlShow(2, 1) = @lblFXShw0201
	fxCtlShow(2, 2) = @lblFXShw0202
	fxCtlShow(2, 3) = @lblFXShw0203
	fxCtlShow(2, 4) = @lblFXShw0204
	fxCtlShow(2, 5) = @lblFXShw0205
	fxCtlTrack(2, 0) = @tbSet0200
	fxCtlTrack(2, 1) = @tbSet0201
	fxCtlTrack(2, 2) = @tbSet0202
	fxCtlTrack(2, 3) = @tbSet0203
	fxCtlTrack(2, 4) = @tbSet0204
	fxCtlTrack(2, 5) = @tbSet0205
	
	fxCtlMsg(3, 0) = @lblFXMSG0300
	fxCtlMsg(3, 1) = @lblFXMSG0301
	fxCtlMsg(3, 2) = @lblFXMSG0302
	fxCtlMsg(3, 3) = @lblFXMSG0303
	fxCtlMsg(3, 4) = @lblFXMSG0304
	fxCtlShow(3, 0) = @lblFXShw0300
	fxCtlShow(3, 1) = @lblFXShw0301
	fxCtlShow(3, 2) = @lblFXShw0302
	fxCtlShow(3, 3) = @lblFXShw0303
	fxCtlShow(3, 4) = @lblFXShw0304
	fxCtlTrack(3, 0) = @tbSet0300
	fxCtlTrack(3, 1) = @tbSet0301
	fxCtlTrack(3, 2) = @tbSet0302
	fxCtlTrack(3, 3) = @tbSet0303
	fxCtlTrack(3, 4) = @tbSet0304
	
	fxCtlMsg(4, 0) = @lblFXMSG0400
	fxCtlMsg(4, 1) = @lblFXMSG0401
	fxCtlMsg(4, 2) = @lblFXMSG0402
	fxCtlMsg(4, 3) = @lblFXMSG0403
	fxCtlMsg(4, 4) = @lblFXMSG0404
	fxCtlShow(4, 0) = @lblFXShw0400
	fxCtlShow(4, 1) = @lblFXShw0401
	fxCtlShow(4, 2) = @lblFXShw0402
	fxCtlShow(4, 3) = @lblFXShw0403
	fxCtlShow(4, 4) = @lblFXShw0404
	fxCtlTrack(4, 0) = @tbSet0400
	fxCtlTrack(4, 1) = @tbSet0401
	fxCtlTrack(4, 2) = @tbSet0402
	fxCtlTrack(4, 3) = @tbSet0403
	fxCtlTrack(4, 4) = @tbSet0404
	
	fxCtlMsg(5, 0) = @lblFXMSG0500
	fxCtlMsg(5, 1) = @lblFXMSG0501
	fxCtlMsg(5, 2) = @lblFXMSG0502
	fxCtlMsg(5, 3) = @lblFXMSG0503
	fxCtlMsg(5, 4) = @lblFXMSG0504
	fxCtlMsg(5, 5) = @lblFXMSG0505
	fxCtlMsg(5, 6) = @lblFXMSG0506
	fxCtlShow(5, 0) = @lblFXShw0500
	fxCtlShow(5, 1) = @lblFXShw0501
	fxCtlShow(5, 2) = @lblFXShw0502
	fxCtlShow(5, 3) = @lblFXShw0503
	fxCtlShow(5, 4) = @lblFXShw0504
	fxCtlShow(5, 5) = @lblFXShw0505
	fxCtlShow(5, 6) = @lblFXShw0506
	fxCtlTrack(5, 0) = @tbSet0500
	fxCtlTrack(5, 1) = @tbSet0501
	fxCtlTrack(5, 2) = @tbSet0502
	fxCtlTrack(5, 3) = @tbSet0503
	fxCtlTrack(5, 4) = @tbSet0504
	fxCtlTrack(5, 5) = @tbSet0505
	fxCtlTrack(5, 6) = @tbSet0506
	
	fxCtlMsg(6, 0) = @lblFXMSG0600
	fxCtlMsg(6, 1) = @lblFXMSG0601
	fxCtlShow(6, 0) = @lblFXShw0600
	fxCtlShow(6, 1) = @lblFXShw0601
	fxCtlTrack(6, 0) = @tbSet0600
	fxCtlTrack(6, 1) = @tbSet0601
	
	fxCtlMsg(7, 0) = @lblFXMSG0700
	fxCtlMsg(7, 1) = @lblFXMSG0701
	fxCtlMsg(7, 2) = @lblFXMSG0702
	fxCtlMsg(7, 3) = @lblFXMSG0703
	fxCtlMsg(7, 4) = @lblFXMSG0704
	fxCtlMsg(7, 5) = @lblFXMSG0705
	fxCtlMsg(7, 6) = @lblFXMSG0706
	fxCtlMsg(7, 7) = @lblFXMSG0707
	fxCtlMsg(7, 8) = @lblFXMSG0708
	fxCtlMsg(7, 9) = @lblFXMSG0709
	fxCtlMsg(7, 10) = @lblFXMSG0710
	fxCtlMsg(7, 11) = @lblFXMSG0711
	fxCtlShow(7, 0) = @lblFXShw0700
	fxCtlShow(7, 1) = @lblFXShw0701
	fxCtlShow(7, 2) = @lblFXShw0702
	fxCtlShow(7, 3) = @lblFXShw0703
	fxCtlShow(7, 4) = @lblFXShw0704
	fxCtlShow(7, 5) = @lblFXShw0705
	fxCtlShow(7, 6) = @lblFXShw0706
	fxCtlShow(7, 7) = @lblFXShw0707
	fxCtlShow(7, 8) = @lblFXShw0708
	fxCtlShow(7, 9) = @lblFXShw0709
	fxCtlShow(7, 10) = @lblFXShw0710
	fxCtlShow(7, 11) = @lblFXShw0711
	fxCtlTrack(7, 0) = @tbSet0700
	fxCtlTrack(7, 1) = @tbSet0701
	fxCtlTrack(7, 2) = @tbSet0702
	fxCtlTrack(7, 3) = @tbSet0703
	fxCtlTrack(7, 4) = @tbSet0704
	fxCtlTrack(7, 5) = @tbSet0705
	fxCtlTrack(7, 6) = @tbSet0706
	fxCtlTrack(7, 7) = @tbSet0707
	fxCtlTrack(7, 8) = @tbSet0708
	fxCtlTrack(7, 9) = @tbSet0709
	fxCtlTrack(7, 10) = @tbSet0710
	fxCtlTrack(7, 11) = @tbSet0711
	
	fxCtlMsg(8, 0) = @lblFXMSG0800
	fxCtlMsg(8, 1) = @lblFXMSG0801
	fxCtlMsg(8, 2) = @lblFXMSG0802
	fxCtlShow(8, 0) = @lblFXShw0800
	fxCtlShow(8, 1) = @lblFXShw0801
	fxCtlShow(8, 2) = @lblFXShw0802
	fxCtlTrack(8, 0) = @tbSet0800
	fxCtlTrack(8, 1) = @tbSet0801
	fxCtlTrack(8, 2) = @tbSet0802
	
	fxCtlMsg(9, 0) = @lblFXMSG0900
	fxCtlMsg(9, 1) = @lblFXMSG0901
	fxCtlMsg(9, 2) = @lblFXMSG0902
	fxCtlMsg(9, 3) = @lblFXMSG0903
	fxCtlShow(9, 0) = @lblFXShw0900
	fxCtlShow(9, 1) = @lblFXShw0901
	fxCtlShow(9, 2) = @lblFXShw0902
	fxCtlShow(9, 3) = @lblFXShw0903
	fxCtlTrack(9, 0) = @tbSet0900
	fxCtlTrack(9, 1) = @tbSet0901
	fxCtlTrack(9, 2) = @tbSet0902
	fxCtlTrack(9, 3) = @tbSet0903
	
	fxCtlMsg(10, 0) = @lblFXMSG1000
	fxCtlMsg(10, 1) = @lblFXMSG1001
	fxCtlMsg(10, 2) = @lblFXMSG1002
	fxCtlMsg(10, 3) = @lblFXMSG1003
	fxCtlShow(10, 0) = @lblFXShw1000
	fxCtlShow(10, 1) = @lblFXShw1001
	fxCtlShow(10, 2) = @lblFXShw1002
	fxCtlShow(10, 3) = @lblFXShw1003
	fxCtlTrack(10, 0) = @tbSet1000
	fxCtlTrack(10, 1) = @tbSet1001
	fxCtlTrack(10, 2) = @tbSet1002
	fxCtlTrack(10, 3) = @tbSet1003
	
	ComboBoxEdit6.AddItem ("Zero")
	ComboBoxEdit6.AddItem ("Bass")
	ComboBoxEdit6.AddItem ("Treble")
	ComboBoxEdit6.AddItem ("Rock")
	ComboBoxEdit6.AddItem ("Modern")
	ComboBoxEdit6.AddItem ("Classical")
	ComboBoxEdit6.AddItem ("Customization")
	
	fxTrackEQ(0) = @tbEQ00
	fxTrackEQ(1) = @tbEQ01
	fxTrackEQ(2) = @tbEQ02
	fxTrackEQ(3) = @tbEQ03
	fxTrackEQ(4) = @tbEQ04
	fxTrackEQ(5) = @tbEQ05
	fxTrackEQ(6) = @tbEQ06
	fxTrackEQ(7) = @tbEQ07
	fxTrackEQ(8) = @tbEQ08
	fxTrackEQ(9) = @tbEQ09
	
	fxLabelEQB(0) = @lblEQB00
	fxLabelEQB(1) = @lblEQB01
	fxLabelEQB(2) = @lblEQB02
	fxLabelEQB(3) = @lblEQB03
	fxLabelEQB(4) = @lblEQB04
	fxLabelEQB(5) = @lblEQB05
	fxLabelEQB(6) = @lblEQB06
	fxLabelEQB(7) = @lblEQB07
	fxLabelEQB(8) = @lblEQB08
	fxLabelEQB(9) = @lblEQB09
	
	fxLabelEQ(0) = @lblEQ00
	fxLabelEQ(1) = @lblEQ01
	fxLabelEQ(2) = @lblEQ02
	fxLabelEQ(3) = @lblEQ03
	fxLabelEQ(4) = @lblEQ04
	fxLabelEQ(5) = @lblEQ05
	fxLabelEQ(6) = @lblEQ06
	fxLabelEQ(7) = @lblEQ07
	fxLabelEQ(8) = @lblEQ08
	fxLabelEQ(9) = @lblEQ09
	
	ComboBoxEdit5.AddItem "http://stream-dc1.radioparadise.com/rp_192m.ogg"
	ComboBoxEdit5.AddItem "http://www.radioparadise.com/m3u/mp3-32.m3u"
	ComboBoxEdit5.AddItem "http://somafm.com/secretagent.pls"
	ComboBoxEdit5.AddItem "http://somafm.com/secretagent32.pls"
	ComboBoxEdit5.AddItem "http://somafm.com/suburbsofgoa.pls"
	ComboBoxEdit5.AddItem "http://somafm.com/suburbsofgoa32.pls"
	ComboBoxEdit5.AddItem "http://bassdrive.com/bassdrive.m3u"
	ComboBoxEdit5.AddItem "http://bassdrive.com/bassdrive3.m3u"
	ComboBoxEdit5.AddItem "http://sc6.radiocaroline.net:8040/listen.pls"
	ComboBoxEdit5.AddItem "http://sc2.radiocaroline.net:8010/listen.pls"
	ComboBoxEdit5.AddItem "http://www.radioparadise.com/m3u/mp3-128.m3u"
	ComboBoxEdit5.AddItem "http://www.radioparadise.com/m3u/mp3-32.m3u"
	ComboBoxEdit5.AddItem "http://icecast.timlradio.co.uk/vr160.ogg"
	ComboBoxEdit5.AddItem "http://icecast.timlradio.co.uk/vr32.ogg"
	ComboBoxEdit5.AddItem "http://icecast.timlradio.co.uk/a8160.ogg"
	ComboBoxEdit5.AddItem "http://icecast.timlradio.co.uk/a832.ogg"
	ComboBoxEdit5.AddItem "http://somafm.com/secretagent.pls"
	ComboBoxEdit5.AddItem "http://somafm.com/secretagent24.pls"
	ComboBoxEdit5.AddItem "http://somafm.com/suburbsofgoa.pls"
	ComboBoxEdit5.AddItem "http://somafm.com/suburbsofgoa24.pls"
	ComboBoxEdit5.AddItem "http://ai-radio.org/128.ogg"
	ComboBoxEdit5.AddItem "http://ai-radio.org/256.ogg"
	ComboBoxEdit5.AddItem "http://ai-radio.org/320.ogg"
	ComboBoxEdit5.AddItem "http://ai-radio.org/44.flac"
	ComboBoxEdit5.AddItem "http://ai-radio.org/320.opus"
	ComboBoxEdit5.AddItem "https:www.wxxi.org/sites/default/files/am-aac-triton.m3u"
	ComboBoxEdit5.AddItem "https:www.wxxi.org/sites/default/files/am-mp3-triton.m3u"
	ComboBoxEdit5.AddItem "https:www.wxxi.org/sites/default/files/fm-aac-triton.m3u"
	ComboBoxEdit5.AddItem "https:www.wxxi.org/sites/default/files/fm-mp3-triton.m3u"
	ComboBoxEdit5.AddItem "https:www.wxxi.org/sites/default/files/rr-aac-triton.m3u"
	ComboBoxEdit5.AddItem "https:www.wxxi.org/sites/default/files/rr-mp3-triton.m3u"
	ComboBoxEdit5.AddItem "https:www.wxxi.org/sites/default/files/weos-aac-triton.m3u"
	ComboBoxEdit5.AddItem "https:www.wxxi.org/sites/default/files/weos-mp3-triton.m3u"
	ComboBoxEdit5.AddItem "https:www.wxxi.org/sites/default/files/with-aac-triton.m3u"
	ComboBoxEdit5.AddItem "https:www.wxxi.org/sites/default/files/with-mp3-triton.m3u"
	ComboBoxEdit5.AddItem "https:www.wxxi.org/sites/default/files/wrur-aac-triton.m3u"
	ComboBoxEdit5.AddItem "https:www.wxxi.org/sites/default/files/wrur-mp3-triton.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/chillfree1.m3u"
	ComboBoxEdit5.AddItem "http://listen.181fm.com/181-thebox_128k.mp3?"
	ComboBoxEdit5.AddItem "http://relay.181.fm:8054"
	ComboBoxEdit5.AddItem "http://powerhitz.powerhitz.com:5040/?.mp3"
	ComboBoxEdit5.AddItem "http://sc.hot108.com:4040?.mp3"
	ComboBoxEdit5.AddItem "http://206.217.213.236:8170 ="
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/vtcntprem1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/vtcntprem1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/vtcntfree1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/vtcntfree1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/tdrnbprem1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/tdrnbprem1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/tdrnbfree1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/tdrnbfree1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/slgrvprem1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/slgrvprem1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/slgrvfree1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/slgrvfree1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/sg-devops2.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/sailprem1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/sailprem1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/sailfree1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/sailfree1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/rtregprem1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/rtregprem1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/rtregfree1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/rtregfree1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/rckonprem1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/rckonprem1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/rckonfree1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/rckonfree1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/rbhtsprem1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/rbhtsprem1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/rbhtsfree1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/rbhtsfree1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/poolsprem1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/poolsprem1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/poolsfree1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/poolsfree1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/modacprem1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/modacprem1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/modacfree1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/modacfree1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/ltnhtprem1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/ltnhtprem1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/ltnhtfree1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/ltnhtfree1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/jazzprem1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/jazzprem1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/jazzfree1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/jazzfree1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/hhhrbprem1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/hhhrbprem1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/hhhrbfree1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/hhhrbfree1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/exitoprem1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/exitoprem1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/exitofree1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/exitofree1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/devops-clshhfree1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/clshhprem1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/clshhprem1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/clshhfree1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/clshhfree1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/claltprem1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/claltprem1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/claltfree1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/claltfree1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/chrhtprem1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/chrhtprem1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/chrhtfree1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/chrhtfree1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/chillprem1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/chillprem1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/chillfree1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/chillfree1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/althtfree1-stage.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/adhtsprem1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/adhtsprem1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/adhtsfree1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/adhtsfree1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/90shtprem1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/90shtprem1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/90shtfree1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/90shtfree1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/90sctprem1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/90sctprem1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/90sctfree1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/90sctfree1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/90scrprem1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/90scrfree1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/90scrfree1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/60shtprem1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/60shtprem1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/60shtfree1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/60shtfree1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/2khtsprem1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/2khtsprem1.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/2khtsfree1-fallback.m3u"
	ComboBoxEdit5.AddItem "http://tunein4.streamguys1.com/2khtsfree1.m3u"
	ComboBoxEdit5.AddItem "http://stream.live.vc.bbcmedia.co.uk/bbc_radio_one"
	ComboBoxEdit5.AddItem "http://dispatcher.rndfnk.com/rbb/radioeins/live/mp3/mid"
	ComboBoxEdit5.AddItem "http://stream.live.vc.bbcmedia.co.uk/bbc_world_service_americas"
	ComboBoxEdit5.AddItem "http://stream.live.vc.bbcmedia.co.uk/bbc_world_service"
	ComboBoxEdit5.AddItem "http://stream.live.vc.bbcmedia.co.uk/bbc_radio_fourfm"
	ComboBoxEdit5.AddItem "http://ais-sa3.cdnstream1.com/2440_128.aac"
	ComboBoxEdit5.AddItem "http://kmojfm.streamguys1.com/live-mp3"
	ComboBoxEdit5.AddItem "https:14023.live.streamtheworld.com/KRSHFM_SC"
	ComboBoxEdit5.AddItem "http://stream.haarlem105.nl:8000/haarlem105low.mp3"
	ComboBoxEdit5.AddItem "http://current.stream.publicradio.org/kcmp.mp3"
	ComboBoxEdit5.AddItem "http://cms.stream.publicradio.org/cms.mp3"
	ComboBoxEdit5.AddItem "http://kcrw.streamguys1.com/kcrw_128k_aac_e24_iheart"
	ComboBoxEdit5.AddItem "http://lhttp.qingting.fm/live/386/64k.mp3"
	
	Dim i As Integer
	For i = 1 To 10
		FxEnabled(fxCtlChk(i)->Text, False, StreamSelected())
	Next
	EqEnabled(False,0)
	
	' check the correct BASS was loaded
	If (HiWord(BASS_GetVersion()) <> BASSVERSION) Then
		MessageBox(0, "An incorrect version of BASS.DLL was loaded", 0, MB_ICONERROR)
	End If
	' enable playlist processing
	BASS_SetConfig(BASS_CONFIG_NET_PLAYLIST, 1)
	
	'	BASS_PluginLoad("bass_aac.dll", 0) ' load BASS_AAC (If present) For AAC support On older Windows
	'	BASS_PluginLoad("bassflac.dll", 0) ' load BASSFLAC (If present) For FLAC support
	'	BASS_PluginLoad("basshls.dll", 0) ' load BASSHLS (If present) For HLS support

	ComboBoxEdit3.ItemIndex = 3
	ComboBoxEdit5.ItemIndex = ComboBoxEdit5.ItemCount - 4
	
	CommandButton1_Click Sender
	CommandButton6_Click Sender
End Sub

Private Sub frmBassType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
End Sub

Private Sub frmBassType.CommandButton1_Click(ByRef Sender As Control)
	ComboBoxEdit1.ItemIndex = OutputDeviceList(@ComboBoxEdit1)
	ComboBoxEdit1_Selected(ComboBoxEdit1, ComboBoxEdit1.ItemIndex)
End Sub

Private Sub frmBassType.CommandButton6_Click(ByRef Sender As Control)
	ComboBoxEdit2.ItemIndex = InputDeviceList(@ComboBoxEdit2)
	ComboBoxEdit2_Selected(ComboBoxEdit2, ComboBoxEdit2.ItemIndex)
End Sub

Private Sub frmBassType.CommandButton3_Click(ByRef Sender As Control)
	If CheckBox3.Checked Then
		bPlayback.OpenBuffer(bRecord.Buffer, bRecord.Length, CheckBox2.Checked)
	Else
		bPlayback.OpenFile(TextBox1.Text, CheckBox2.Checked)
	End If
	If bPlayback.Stream Then
		CommandButton4.Enabled = True
		CommandButton4.Text = "Pause"
		CommandButton5.Enabled = True
		TimerComponent1.Enabled = True
		TrackBar2.MaxValue = bPlayback.Length
		TrackBar2.Position = 0
		TrackBar2.Enabled = True
		VolumeGet
	Else
		Label2.Text = "Error!"
	End If
End Sub

Private Sub frmBassType.CommandButton4_Click(ByRef Sender As Control)
	Select Case CommandButton4.Text
	Case "Play"
		bPlayback.Play()
		If bPlayback.Stream Then
			CommandButton4.Text = "Pause"
		Else
			CommandButton4.Enabled = False
			CommandButton4.Text = "Play"
		End If
	Case Else
		CommandButton4.Text = "Play"
		bPlayback.Pause()
		If bPlayback.Stream = NULL Then CommandButton4.Enabled = False
	End Select
End Sub

Private Sub frmBassType.CommandButton5_Click(ByRef Sender As Control)
	bPlayback.Stop()
	CommandButton4.Text = "Pause"
	CommandButton4.Enabled = False
	CommandButton5.Enabled = False
	TrackBar2.Enabled = False
	TimerComponent1.Enabled = False
End Sub

Private Sub frmBassType.ComboBoxEdit1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	OutputDevice = ItemIndex
	BASS_Free
	If BASS_Init(OutputDevice, 44100, 0, This.Handle, 0) Then
		BASS_ChannelSetDevice(bPlayback.Stream, OutputDevice)
		BASS_ChannelSetDevice(bRaido.Stream, OutputDevice)
		TrackBar1.Position = BASS_GetVolume() * 10000
		TrackBar1.Enabled = True
	End If
End Sub

Private Sub frmBassType.TimerComponent1_Timer(ByRef Sender As TimerComponent)
	Dim q As QWORD = bPlayback.Position
	TrackBar2.Position = q
	Label2.Text = "Position: " & q & " (" & Len2Str(bPlayback.Stream, q) & " / " & Len2Str(bPlayback.Stream, bPlayback.Length) & ")"
End Sub

Private Sub frmBassType.TrackBar1_Change(ByRef Sender As TrackBar, Position As Integer)
	Dim f As Single= Position / 10000
	BASS_SetVolume(f)
	Label1.Text = Format(f, "0.0000")
End Sub

Private Sub frmBassType.TrackBar2_Change(ByRef Sender As TrackBar, Position As Integer)
	If TimerComponent1.Enabled = True Then Exit Sub
	bPlayback.Position = Position
End Sub

Private Sub frmBassType.TrackBar2_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
'	If MouseButton = 0 Then
		TimerComponent1.Enabled = False
'	End If
End Sub

Private Sub frmBassType.TrackBar2_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
'	If MouseButton = 0 Then
		TimerComponent1.Enabled = True
'	End If
End Sub

Private Sub frmBassType.CheckBox1_Click(ByRef Sender As CheckBox)
	TimerComponent2.Enabled = (CheckBox1.Checked = True)
	TimerComponent2.Interval = CInt(TextBox3.Text)
End Sub

Private Sub frmBassType.TimerComponent2_Timer(ByRef Sender As TimerComponent)
	bSpectrum.Update (StreamSelected(), Picture1.Handle)
End Sub

Private Sub frmBassType.Picture1_Click(ByRef Sender As Picture)
	Static i As Integer
	If i < 3 Then i = i + 1 Else i = 0
	bSpectrum.Mode = i
End Sub

Private Sub frmBassType.ComboBoxEdit4_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	' input selection changed
	RecInput = ItemIndex
	
	RecSetInput(RecInput)

	InputInfo(RecInput, @ComboBoxEdit4, @Label3, @TrackBar3, @Label8)
End Sub

Private Sub frmBassType.ComboBoxEdit2_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	InputDevice = ItemIndex '  Get the selection
	' special handle (real handles always have highest Bit set) To prevent Timer ending the recording
	' initialize the selected device
	If InputInit(InputDevice) Then
		bRecord.Restart()
	End If
	InputInfo(RecInput, @ComboBoxEdit4, @Label3, @TrackBar3, @Label8)
End Sub

Private Sub frmBassType.TrackBar3_Change(ByRef Sender As TrackBar, Position As Integer)
	Dim f As Single= Position / 10000
	If BASS_RecordSetInput(RecInput, 0, f) = 0 Then
		BASS_RecordSetInput(-1, 0, f)
		Label8.Text = Format(f, "0.0000")
	End If
End Sub

Private Sub frmBassType.CommandButton8_Click(ByRef Sender As Control)
	If CommandButton8.Text = "Record" Then
		If bPlayback.BufferPlaying Then CommandButton5_Click(CommandButton5)
		CommandButton12.Enabled = False
		If bRecord.start(ComboBoxEdit3.ItemIndex) Then
			CommandButton8.Text = "Stop"
			CommandButton9.Text = "Pause"
			CommandButton9.Enabled = True
			TimerComponent3.Enabled = True
			VolumeGet
		Else
			Label4.Text = "Can't start recording"
			CommandButton8.Text = "Record"
		End If
		CheckBox3.Checked = False
		CheckBox3.Enabled = False
		TextBox1.Enabled = True
	Else
		bRecord.Stop()
		CommandButton12.Enabled = True
		CheckBox3.Enabled = True
		CommandButton8.Text = "Record"
		CommandButton9.Text = "Pause"
		CommandButton9.Enabled = False
		CommandButton10.Text = "Monitor"
	End If
End Sub

Private Sub frmBassType.CommandButton12_Click(ByRef Sender As Control)
	bRecord.Write(TextBox2.Text)
	Label4.Text = bRecord.Length & " bytes were write."
End Sub

Private Sub frmBassType.TimerComponent3_Timer(ByRef Sender As TimerComponent)
	' update the level display
	' update the recording/playback counter
	If (bRecord.Stream) Then ' recording
		Label4.Text = bRecord.Length - 44 & " bytes were record."
	End If
End Sub

Private Sub frmBassType.CheckBox3_Click(ByRef Sender As CheckBox)
	If CheckBox3.Checked Then
		TextBox1.Enabled = False
	Else
		TextBox1.Enabled = True
	End If
End Sub

Private Sub frmBassType.CommandButton9_Click(ByRef Sender As Control)
	If CommandButton9.Text = "Pause" Then
		CommandButton9.Text = "Continue"
		bRecord.Pause
	Else
		CommandButton9.Text = "Pause"
		bRecord.Resume
	End If
End Sub

Private Sub frmBassType.CommandButton10_Click(ByRef Sender As Control)
	CommandButton12.Enabled = False
	CheckBox3.Checked = False
	CheckBox3.Enabled = False
	TextBox1.Enabled = True
	TimerComponent3.Enabled = False
	If bPlayback.BufferPlaying Then CommandButton5_Click(CommandButton5)
	
	If CommandButton10.Text = "Monitor" Then
		If bRecord.Monitor(ComboBoxEdit3.ItemIndex) Then
			CommandButton10.Text = "Stop"
			Label4.Text = "Start monitoring"
		Else
			Label4.Text = "Can't start monitoring"
			CommandButton10.Text = "Monitor"
		End If
	Else
		bRecord.Stop()
		CommandButton10.Text = "Monitor"
		Label4.Text = "Stop monitoring"
	End If
End Sub

Private Sub frmBassType.CheckBox4_Click(ByRef Sender As CheckBox)
	If CheckBox4.Checked Then
		BASS_SetConfigPtr(BASS_CONFIG_NET_PROXY, NULL) '  disable proxy
		TextBox4.Enabled = False
		Label5.Text = CheckBox4.Text
	Else
		Dim As WString Ptr proxy = Cast(WString Ptr, @TextBox4.Text)
		BASS_SetConfigPtr(BASS_CONFIG_NET_PROXY, proxy) '  set proxy server
		TextBox4.Enabled = True
		Label5.Text = "Proxy: " & *proxy
	End If
End Sub

Private Sub frmBassType.CommandButton23_Click(ByRef Sender As Control)
	CommandButton23.Enabled = False
	Label5.Text =  "connecting..."
	Label6.Text =  ComboBoxEdit5.Text
	TextBox5.Text =  ""
	If bRaido.OpenURL(@This, ComboBoxEdit5.Text) = 0 Then
		Label5.Text = "not playing" & vbcrlf & "Can't play the stream"
	End If
	CommandButton23.Enabled = True
End Sub

Private Sub frmBassType.TimerComponent4_Timer(ByRef Sender As TimerComponent)
	' monitor buffering progress
	
	Dim As DWORD active = BASS_ChannelIsActive(bRaido.Stream)
	If (active = BASS_ACTIVE_STALLED) Then
		Label5.Text = "buffering..." & 100 - BASS_StreamGetFilePosition(bRaido.Stream, BASS_FILEPOS_BUFFERING) & "%"
	Else
		TimerComponent4.Enabled = False '  finished buffering, Stop monitoring
		If (active) Then
			If Label5.Text <> "playing" Then Label5.Text = "playing"
			'  Get the stream Name And URL
			Dim As ZString Ptr icy = Cast(ZString Ptr, BASS_ChannelGetTags(bRaido.Stream, BASS_TAG_ICY))
			If (icy = 0) Then icy = Cast(ZString Ptr, BASS_ChannelGetTags(bRaido.Stream, BASS_TAG_HTTP)) '  no ICY tags, try HTTP
			If (icy) Then
				If InStr(Label6.Text, *icy) = 0 Then Label6.Text = *icy
			End If
			bRaido.DoMeta()
		End If
	End If
End Sub

Private Sub frmBassType.CommandButton24_Click(ByRef Sender As Control)
	'	If (RaidoStream) Then BASS_StreamFree(RaidoStream) '  Close old stream
	bRaido.Stop()
	Label5.Text =  "close..."
	Label6.Text =  ""
	TextBox5.Text =  ""
End Sub

Private Sub frmBassType.TrackBar4_Change(ByRef Sender As TrackBar, Position As Integer)
	VolumeSet
End Sub

Private Sub frmBassType.RadioButton1_Click(ByRef Sender As RadioButton)
	VolumeGet
End Sub

Private Sub frmBassType.CheckBox5_Click(ByRef Sender As CheckBox)
	FxEnabled(sender.text, sender.Checked, StreamSelected())
End Sub

'将参数设置在Chanel
Private Sub frmBassType.FxParaSet(fxIdx As Integer, paIdx As Integer, Position As Integer)
	Dim As Single s = Position / CInt(fxCtlTrack(fxIdx, paIdx)->text)
	
	Select Case fxIdx
	Case 1
		Select Case paIdx
		Case 0
			bfdCHO.fWetDryMix=s
		Case 1
			bfdCHO.fDepth=s
		Case 2
			bfdCHO.fFeedback=s
		Case 3
			bfdCHO.fFrequency=s
		Case 4
			bfdCHO.lWaveform=s
		Case 5
			bfdCHO.fDelay=s
		Case 6
			bfdCHO.lPhase=s
		End Select
	Case 2
		Select Case paIdx
		Case 0
			bfdCOM.fGain =s
		Case 1
			bfdCOM.fAttack =s
		Case 2
			bfdCOM.fRelease =s
		Case 3
			bfdCOM.fThreshold =s
		Case 4
			bfdCOM.fRatio =s
		Case 5
			bfdCOM.fPredelay =s
		End Select
	Case 3
		Select Case paIdx
		Case 0
			bfdDIS.fGain=s
		Case 1
			bfdDIS.fEdge=s
		Case 2
			bfdDIS.fPostEQCenterFrequency=s
		Case 3
			bfdDIS.fPostEQBandwidth=s
		Case 4
			bfdDIS.fPreLowpassCutoff = s
		End Select
	Case 4
		Select Case paIdx
		Case 0
			bfdECH.fWetDryMix=s
		Case 1
			bfdECH.fFeedback=s
		Case 2
			bfdECH.fLeftDelay=s
		Case 3
			bfdECH.fRightDelay=s
		Case 4
			bfdECH.lPanDelay=s
		End Select
	Case 5
		Select Case paIdx
		Case 0
			bfdFLA.fWetDryMix=s
		Case 1
			bfdFLA.fDepth=s
		Case 2
			bfdFLA.fFeedback=s
		Case 3
			bfdFLA.fFrequency=s
		Case 4
			bfdFLA.lWaveform=s
		Case 5
			bfdFLA.fDelay=s
		Case 6
			bfdFLA.lPhase= s
		End Select
	Case 6
		Select Case paIdx
		Case 0
			bfdGAR.dwRateHz=s
		Case 1
			bfdGAR.dwWaveShape=s
		End Select
	Case 7
		Select Case paIdx
		Case 0
			bfdI3D.lRoom=s
		Case 1
			bfdI3D.lRoomHF=s
		Case 2
			bfdI3D.flRoomRolloffFactor=s
		Case 3
			bfdI3D.flDecayTime=s
		Case 4
			bfdI3D.flDecayHFRatio=s
		Case 5
			bfdI3D.lReflections=s
		Case 6
			bfdI3D.flReflectionsDelay=s
		Case 7
			bfdI3D.lReverb=s
		Case 8
			bfdI3D.flReverbDelay=s
		Case 9
			bfdI3D.flDiffusion=s
		Case 10
			bfdI3D.flDensity=s
		Case 11
			bfdI3D.flHFReference=s
		End Select
	Case 8
		Select Case paIdx
		Case 0
			bfdPAR.fCenter=s
		Case 1
			bfdPAR.fBandwidth=s
		Case 2
			bfdPAR.fGain=s
		End Select
	Case 10
		Select Case paIdx
		Case 0
			bfVOL.fTarget=s
		Case 1
			bfVOL.fCurrent=s
		Case 2
			bfVOL.fTime=s
		Case 3
			bfVOL.lCurve=s
		End Select
	Case 9
		Select Case paIdx
		Case 0
			bfdREV.fInGain = s
		Case 1
			bfdREV.fReverbMix = s
		Case 2
			bfdREV.fReverbTime = s
		Case 3
			bfdREV.fHighFreqRTRatio = s
		End Select
	End Select
	
	If fxHdl(fxIdx) Then BASS_FXSetParameters(fxHdl(fxIdx), fxPara(fxIdx))
	fxCtlShow(fxIdx, paIdx)->text = Format(s, "0.000")
End Sub

'从控件里获取参数
Private Sub frmBassType.FxParafrmCtl(fxIdx As Integer)
	Dim As Single s
	Dim As Integer i
	For i = 0 To fxParaC(fxIdx)
		Select Case fxIdx
		Case 1
			Select Case i
			Case 0
				bfdCHO.fWetDryMix=s
			Case 1
				bfdCHO.fDepth=s
			Case 2
				bfdCHO.fFeedback=s
			Case 3
				bfdCHO.fFrequency=s
			Case 4
				bfdCHO.lWaveform=s
			Case 5
				bfdCHO.fDelay=s
			Case 6
				bfdCHO.lPhase=s
			End Select
		Case 2
			Select Case i
			Case 0
				bfdCOM.fGain =s
			Case 1
				bfdCOM.fAttack =s
			Case 2
				bfdCOM.fRelease =s
			Case 3
				bfdCOM.fThreshold =s
			Case 4
				bfdCOM.fRatio =s
			Case 5
				bfdCOM.fPredelay =s
			End Select
		Case 3
			Select Case i
			Case 0
				bfdDIS.fGain=s
			Case 1
				bfdDIS.fEdge=s
			Case 2
				bfdDIS.fPostEQCenterFrequency=s
			Case 3
				bfdDIS.fPostEQBandwidth=s
			Case 4
				bfdDIS.fPreLowpassCutoff = s
			End Select
		Case 4
			Select Case i
			Case 0
				bfdECH.fWetDryMix=s
			Case 1
				bfdECH.fFeedback=s
			Case 2
				bfdECH.fLeftDelay=s
			Case 3
				bfdECH.fRightDelay=s
			Case 4
				bfdECH.lPanDelay=s
			End Select
		Case 5
			Select Case i
			Case 0
				bfdFLA.fWetDryMix=s
			Case 1
				bfdFLA.fDepth=s
			Case 2
				bfdFLA.fFeedback=s
			Case 3
				bfdFLA.fFrequency=s
			Case 4
				bfdFLA.lWaveform=s
			Case 5
				bfdFLA.fDelay=s
			Case 6
				bfdFLA.lPhase=s
			End Select
		Case 6
			Select Case i
			Case 0
				bfdGAR.dwRateHz=s
			Case 1
				bfdGAR.dwWaveShape=s
			End Select
		Case 7
			Select Case i
			Case 0
				bfdI3D.lRoom=s
			Case 1
				bfdI3D.lRoomHF=s
			Case 2
				bfdI3D.flRoomRolloffFactor=s
			Case 3
				bfdI3D.flDecayTime=s
			Case 4
				bfdI3D.flDecayHFRatio=s
			Case 5
				bfdI3D.lReflections=s
			Case 6
				bfdI3D.flReflectionsDelay=s
			Case 7
				bfdI3D.lReverb=s
			Case 8
				bfdI3D.flReverbDelay=s
			Case 9
				bfdI3D.flDiffusion=s
			Case 10
				bfdI3D.flDensity=s
			Case 11
				bfdI3D.flHFReference=s
			End Select
		Case 8
			Select Case i
			Case 0
				bfdPAR.fCenter=s
			Case 1
				bfdPAR.fBandwidth=s
			Case 2
				bfdPAR.fGain=s
			End Select
		Case 10
			Select Case i
			Case 0
				bfVOL.fTarget=s
			Case 1
				bfVOL.fCurrent=s
			Case 2
				bfVOL.fTime=s
			Case 3
				bfVOL.lCurve=s
			End Select
		Case 9
			s = fxCtlTrack(fxIdx, i)->Position / CInt(fxCtlTrack(fxIdx, i)->text)
			Select Case i
			Case 0
				bfdREV.fInGain = s
			Case 1
				bfdREV.fReverbMix = s
			Case 2
				bfdREV.fReverbTime= s
			Case 3
				bfdREV.fHighFreqRTRatio = s
			End Select
		End Select
	Next
End Sub

'将参数设置在TrackBar控件上
Private Sub frmBassType.FxPara2Ctl(fxIdx As Integer)
	Dim As Single s
	Dim As Integer i
	For i = 0 To fxParaC(fxIdx)
		Select Case fxIdx
		Case 1
			Select Case i
			Case 0
				s = bfdCHO.fWetDryMix
			Case 1
				s = bfdCHO.fDepth
			Case 2
				s = bfdCHO.fFeedback
			Case 3
				s = bfdCHO.fFrequency
			Case 4
				s = bfdCHO.lWaveform
			Case 5
				s = bfdCHO.fDelay
			Case 6
				s = bfdCHO.lPhase
			End Select
		Case 2
			Select Case i
			Case 0
				s = bfdCOM.fGain
			Case 1
				s = bfdCOM.fAttack
			Case 2
				s = bfdCOM.fRelease
			Case 3
				s = bfdCOM.fThreshold
			Case 4
				s = bfdCOM.fRatio
			Case 5
				s = bfdCOM.fPredelay
			End Select
		Case 3
			Select Case i
			Case 0
				s = bfdDIS.fGain
			Case 1
				s = bfdDIS.fEdge
			Case 2
				s = bfdDIS.fPostEQCenterFrequency
			Case 3
				s = bfdDIS.fPostEQBandwidth
			Case 4
				s = bfdDIS.fPreLowpassCutoff
			End Select
		Case 4
			Select Case i
			Case 0
				s = bfdECH.fWetDryMix
			Case 1
				s = bfdECH.fFeedback
			Case 2
				s = bfdECH.fLeftDelay
			Case 3
				s = bfdECH.fRightDelay
			Case 4
				s = bfdECH.lPanDelay
			End Select
		Case 5
			Select Case i
			Case 0
				s = bfdFLA.fWetDryMix
			Case 1
				s = bfdFLA.fDepth
			Case 2
				s = bfdFLA.fFeedback
			Case 3
				s = bfdFLA.fFrequency
			Case 4
				s = bfdFLA.lWaveform
			Case 5
				s = bfdFLA.fDelay
			Case 6
				s = bfdFLA.lPhase
			End Select
		Case 6
			Select Case i
			Case 0
				s = bfdGAR.dwRateHz
			Case 1
				s = bfdGAR.dwWaveShape
			End Select
		Case 7
			Select Case i
			Case 0
				s = bfdI3D.lRoom
			Case 1
				s = bfdI3D.lRoomHF
			Case 2
				s = bfdI3D.flRoomRolloffFactor
			Case 3
				s = bfdI3D.flDecayTime
			Case 4
				s = bfdI3D.flDecayHFRatio
			Case 5
				s = bfdI3D.lReflections
			Case 6
				s = bfdI3D.flReflectionsDelay
			Case 7
				s = bfdI3D.lReverb
			Case 8
				s = bfdI3D.flReverbDelay
			Case 9
				s = bfdI3D.flDiffusion
			Case 10
				s = bfdI3D.flDensity
			Case 11
				s = bfdI3D.flHFReference
			End Select
		Case 8
			Select Case i
			Case 0
				s = bfdPAR.fCenter
			Case 1
				s = bfdPAR.fBandwidth
			Case 2
				s = bfdPAR.fGain
			End Select
		Case 10
			Select Case i
			Case 0
				s = bfVOL.fTarget
			Case 1
				s = bfVOL.fCurrent
			Case 2
				s = bfVOL.fTime
			Case 3
				s = bfVOL.lCurve
			End Select
		Case 9
			Select Case i
			Case 0
				s = bfdREV.fInGain
			Case 1
				s = bfdREV.fReverbMix
			Case 2
				s = bfdREV.fReverbTime
			Case 3
				s = bfdREV.fHighFreqRTRatio
			End Select
		End Select
		fxCtlTrack(fxIdx, i)->Position = s * CInt(fxCtlTrack(fxIdx, i)->Text)
	Next
End Sub

'将参数显示在Label控件上
Private Sub frmBassType.FxParaShow(fxIdx As Integer, paIdx As Integer)
	'fxCtlMsg(10, 10) As Label Ptr '信息显示指针
	'fxCtlShow(10, 10) As Label Ptr '参数显示指针
	'fxCtlTrack(10, 10) As TrackBar Ptr '参数调节控件指针
	
	Dim s As Single
	Select Case fxIdx
	Case 1
		Select Case paIdx
		Case 0
			s = bfdCHO.fWetDryMix
		Case 1
			s = bfdCHO.fDepth
		Case 2
			s = bfdCHO.fFeedback
		Case 3
			s = bfdCHO.fFrequency
		Case 4
			s = bfdCHO.lWaveform
		Case 5
			s = bfdCHO.fDelay
		Case 6
			s = bfdCHO.lPhase
		End Select
	Case 2
		Select Case paIdx
		Case 0
			s = bfdCOM.fGain
		Case 1
			s = bfdCOM.fAttack
		Case 2
			s = bfdCOM.fRelease
		Case 3
			s = bfdCOM.fThreshold
		Case 4
			s = bfdCOM.fRatio
		Case 5
			s = bfdCOM.fPredelay
		End Select
	Case 3
		Select Case paIdx
		Case 0
			s = bfdDIS.fGain
		Case 1
			s = bfdDIS.fEdge
		Case 2
			s = bfdDIS.fPostEQCenterFrequency
		Case 3
			s = bfdDIS.fPostEQBandwidth
		Case 4
			s = bfdDIS.fPreLowpassCutoff
		End Select
	Case 4
		Select Case paIdx
		Case 0
			s = bfdECH.fWetDryMix
		Case 1
			s = bfdECH.fFeedback
		Case 2
			s = bfdECH.fLeftDelay
		Case 3
			s = bfdECH.fRightDelay
		Case 4
			s = bfdECH.lPanDelay
		End Select
	Case 5
		Select Case paIdx
		Case 0
			s = bfdFLA.fWetDryMix
		Case 1
			s = bfdFLA.fDepth
		Case 2
			s = bfdFLA.fFeedback
		Case 3
			s = bfdFLA.fFrequency
		Case 4
			s = bfdFLA.lWaveform
		Case 5
			s = bfdFLA.fDelay
		Case 6
			s = bfdFLA.lPhase
		End Select
	Case 6
		Select Case paIdx
		Case 0
			s = bfdGAR.dwRateHz
		Case 1
			s = bfdGAR.dwWaveShape
		End Select
	Case 7
		Select Case paIdx
		Case 0
			s = bfdI3D.lRoom
		Case 1
			s = bfdI3D.lRoomHF
		Case 2
			s = bfdI3D.flRoomRolloffFactor
		Case 3
			s = bfdI3D.flDecayTime
		Case 4
			s = bfdI3D.flDecayHFRatio
		Case 5
			s = bfdI3D.lReflections
		Case 6
			s = bfdI3D.flReflectionsDelay
		Case 7
			s = bfdI3D.lReverb
		Case 8
			s = bfdI3D.flReverbDelay
		Case 9
			s = bfdI3D.flDiffusion
		Case 10
			s = bfdI3D.flDensity
		Case 11
			s = bfdI3D.flHFReference
		End Select
	Case 8
		Select Case paIdx
		Case 0
			s = bfdPAR.fCenter
		Case 1
			s = bfdPAR.fBandwidth
		Case 2
			s = bfdPAR.fGain
		End Select
	Case 10
		Select Case paIdx
		Case 0
			s = bfVOL.fTarget
		Case 1
			s = bfVOL.fCurrent
		Case 2
			s = bfVOL.fTime
		Case 3
			s = bfVOL.lCurve
		End Select
	Case 9
		Select Case paIdx
		Case 0
			s = bfdREV.fInGain
		Case 1
			s = bfdREV.fReverbMix
		Case 2
			s = bfdREV.fReverbTime
		Case 3
			s = bfdREV.fHighFreqRTRatio
		End Select
	End Select
	fxCtlShow(fxIdx, paIdx)->Text = Format(s, "0.000")
End Sub

Private Function frmBassType.FxIndex(fxName As WString) As Integer
	Select Case fxName
	Case "Chorus"
		Return 1
	Case "Compression"
		Return 2
	Case "Distortion"
		Return 3
	Case "Echo"
		Return 4
	Case "Flanger"
		Return 5
	Case "Gargle"
		Return 6
	Case "3D"
		Return 7
	Case "Equalizer"
		Return 8
	Case "Reverb"
		Return 9
	Case "Volume"
		Return 10
	End Select
End Function

Private Sub frmBassType.FxReset(ch As HSTREAM)
	Dim i As Long
	For i = 1 To 10
		If fxHdl(i) Then
			fxHdl(i) = BASS_ChannelSetFX(ch, fxTyp(i), i)
		End If
	Next
End Sub

Private Sub frmBassType.FxRemove(ch As HSTREAM)
	Dim i As Long
	For i = 1 To 10
		If fxHdl(i) Then
			BASS_ChannelRemoveFX(ch, fxHdl(i))
		End If
	Next
End Sub

Private Sub frmBassType.FxEnabled(fxName As WString, st As Boolean, ch As HSTREAM)
	Dim fxIdx As Integer = FxIndex(fxName)
	
	TabControl1.SelectedTab = TabControl1.Tab(fxIdx - 1)
	
	Dim i As Integer
	For i = 0 To fxParaC(fxIdx)
		fxCtlMsg(fxIdx, i)->Enabled = st
		fxCtlShow(fxIdx, i)->Enabled = st
		fxCtlTrack(fxIdx, i)->Enabled = st
	Next
	
	If st Then
		fxHdl(fxIdx) = BASS_ChannelSetFX(ch, fxTyp(fxIdx), fxIdx)
		BASS_FXGetParameters(fxHdl(fxIdx), fxPara(fxIdx))
		FxPara2Ctl(fxIdx)
	Else
		If fxHdl(fxIdx) Then
			BASS_ChannelRemoveFX(ch, fxHdl(fxIdx))
			fxHdl(fxIdx) = 0
		End If
	End If
	If fxIdx = 8 Then EqEnabled(st, ch)
End Sub

Private Sub frmBassType.EqEnabled(st As Boolean, ch As HSTREAM)
	GroupBox8.Enabled = st
	ComboBoxEdit6.Enabled = st
	Dim i As Integer
	For i = 0 To cntEQ
		fxTrackEQ(i)->Enabled = st
		fxLabelEQ(i)->Enabled = st
		fxLabelEQB(i)->Enabled = st
		If st Then
			fxEQHdl(i) = BASS_ChannelSetFX(ch, fxTyp(8), i + 20)
			BASS_FXGetParameters(fxEQHdl(i), @bfdEQ(i))
			Select Case i
			Case 0
				bfdEQ(i).fCenter = 60
			Case 1
				bfdEQ(i).fCenter = 170
			Case 2
				bfdEQ(i).fCenter = 310
			Case 3
				bfdEQ(i).fCenter = 600
			Case 4
				bfdEQ(i).fCenter = 1000
			Case 5
				bfdEQ(i).fCenter = 3000
			Case 6
				bfdEQ(i).fCenter = 6000
			Case 7
				bfdEQ(i).fCenter = 12000
			Case 8
				bfdEQ(i).fCenter = 14000
			Case 9
				bfdEQ(i).fCenter = 16000
			End Select
		Else
			If fxEQHdl(i) Then BASS_ChannelRemoveFX(ch, fxEQHdl(i))
			fxEQHdl(i) = 0
		End If
	Next
End Sub

Private Sub frmBassType.tbSet_Change(ByRef Sender As TrackBar, Position As Integer)
	Dim As Single s
	
	Dim fxIdx As Integer = CInt(Mid(Sender.Name, 6, 2))
	Dim paIdx As Integer = CInt(Mid(Sender.Name, 8, 2))
	
	FxParaSet(fxIdx, paIdx, Position)
	
End Sub

Private Sub frmBassType.TextBox1_DblClick(ByRef Sender As Control)
	OpenFileDialog1.FileName= TextBox1.Text
	
	Dim a As WString Ptr
	If OpenFileDialog1.Execute Then
		TextBox1.Text = OpenFileDialog1.FileName
	End If
End Sub

Private Sub frmBassType.TextBox2_DblClick(ByRef Sender As Control)
	OpenFileDialog1.FileName= TextBox2.Text
	If OpenFileDialog1.Execute Then
		TextBox2.Text = OpenFileDialog1.FileName
	End If
End Sub

Private Sub frmBassType.tbEQ00_Change(ByRef Sender As TrackBar, Position As Integer)
	Dim i As Integer = CInt(Right(Sender.Name, 2))
	fxLabelEQ(i)->Text = Format(0 - Position, "0")
	bfdEQ(i).fGain = 0 - Position
	BASS_FXSetParameters(fxEQHdl(i), @bfdEQ(i))
End Sub

Private Sub frmBassType.ComboBoxEdit6_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	Select Case ComboBoxEdit6.ItemIndex
	Case 0 'zero
		fxTrackEq(0)->Position = 0
		fxTrackEQ(1)->Position = 0
		fxTrackEQ(2)->Position = 0
		fxTrackEQ(3)->Position = 0
		fxTrackEQ(4)->Position = 0
		fxTrackEQ(5)->Position = 0
		fxTrackEQ(6)->Position = 0
		fxTrackEQ(7)->Position = 0
		fxTrackEQ(8)->Position = 0
		fxTrackEQ(9)->Position = 0
	Case 1 'bass
		fxTrackEQ(0)->Position = -2
		fxTrackEQ(1)->Position = -2
		fxTrackEQ(2)->Position = -1
		fxTrackEQ(3)->Position = -1
		fxTrackEQ(4)->Position = 0
		fxTrackEQ(5)->Position = 0
		fxTrackEQ(6)->Position = 0
		fxTrackEQ(7)->Position = 0
		fxTrackEQ(8)->Position = 0
		fxTrackEQ(9)->Position = 0
	Case 2 'treble
		fxTrackEQ(0)->Position = 0
		fxTrackEQ(1)->Position = 0
		fxTrackEQ(2)->Position = 0
		fxTrackEQ(3)->Position = 0
		fxTrackEQ(4)->Position = 0
		fxTrackEQ(5)->Position = 0
		fxTrackEQ(6)->Position = -1
		fxTrackEQ(7)->Position = -1
		fxTrackEQ(8)->Position = -2
		fxTrackEQ(9)->Position = -3
	Case 3 'rock
		fxTrackEQ(0)->Position = -3
		fxTrackEQ(1)->Position = -2
		fxTrackEQ(2)->Position = -2
		fxTrackEQ(3)->Position = -1
		fxTrackEQ(4)->Position = 0
		fxTrackEQ(5)->Position = 0
		fxTrackEQ(6)->Position = -1
		fxTrackEQ(7)->Position = -2
		fxTrackEQ(8)->Position = -2
		fxTrackEQ(9)->Position = -3
	Case 4 'modern
		fxTrackEQ(0)->Position = -2
		fxTrackEQ(1)->Position = -2
		fxTrackEQ(2)->Position = -1
		fxTrackEQ(3)->Position = -1
		fxTrackEQ(4)->Position = 0
		fxTrackEQ(5)->Position = 0
		fxTrackEQ(6)->Position = -1
		fxTrackEQ(7)->Position = -1
		fxTrackEQ(8)->Position = -2
		fxTrackEQ(9)->Position = -2
	Case 5 'classical
		fxTrackEQ(0)->Position = 0
		fxTrackEQ(1)->Position = 0
		fxTrackEQ(2)->Position = 0
		fxTrackEQ(3)->Position = -1
		fxTrackEQ(4)->Position = -2
		fxTrackEQ(5)->Position = -2
		fxTrackEQ(6)->Position = -1
		fxTrackEQ(7)->Position = 0
		fxTrackEQ(8)->Position = 0
		fxTrackEQ(9)->Position = 0
	Case 6 'customnization
		fxTrackEQ(0)->Position = 0
		fxTrackEQ(1)->Position = 0
		fxTrackEQ(2)->Position = 0
		fxTrackEQ(3)->Position = 0
		fxTrackEQ(4)->Position = 0
		fxTrackEQ(5)->Position = 0
		fxTrackEQ(6)->Position = 0
		fxTrackEQ(7)->Position = 0
		fxTrackEQ(8)->Position = 0
		fxTrackEQ(9)->Position = 0
	End Select
End Sub

Private Sub frmBassType.CheckBox15_Click(ByRef Sender As CheckBox)
	SetDarkMode(CheckBox15.Checked , CheckBox15.Checked)
End Sub
