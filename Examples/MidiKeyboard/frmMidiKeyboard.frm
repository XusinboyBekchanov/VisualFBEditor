'frmMidiTest
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "frmMidiKeyboard.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/TrackBar.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Label.bi"
	#include once "mff/ImageBox.bi"
	#include once "mff/Panel.bi"
	#include once "mff/CheckBox.bi"
	
	#include once "midi.bi"
	#include once "../gdipClock/gdip.bi"

	Using My.Sys.Forms
	
	Type frmMidiKeyboardType Extends Form
		
		'initial gdip token
		Token As gdipToken
		'form display device
		frmDC As gdipDC
		'memory display device
		memDC As gdipDC
		'form canvas
		frmGraphic As gdipGraphics
		mPiano As gdipBitmap
		
		KeyWhiteNumber As Integer = 37  '白键数start from 0
		KeyPad(Any) As RectPi           '键盘位置数组
		KeyBlack(Any) As Boolean        '是否黑键
		KeyCount As Integer = -1        '键数
		KeyIndex As Integer = -1        '当前键值
		KeyBase As Integer = 0          '基本音调
		KeyCanvas As Boolean = False    '用Canvas

		mMidiID As UINT
	    mMidiOut As HMIDIOUT
		mMidiVelocity As Integer
		
		Declare Function KeyInvalid(ByRef Canvas As My.Sys.Drawing.Canvas) As Boolean   '是否需从新计算键盘位置
		Declare Sub KeyLocate(ByRef Canvas As My.Sys.Drawing.Canvas)                    '获取键盘位置
		Declare Function KeyIndexByXY(x As Integer, y As Integer) As Integer            '用xy定位键值
		
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub cobDevice_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub cobInstrument_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub cobChannel_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub tbVolume_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Sub tbVelocity_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Sub tbNote_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Sub CommandButton2_Click(ByRef Sender As Control)
		Declare Sub Panel1_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub Panel1_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub Panel1_MouseLeave(ByRef Sender As Control)
		Declare Sub Panel1_Click(ByRef Sender As Control)
		Declare Sub tbBase_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Sub CheckBox1_Click(ByRef Sender As CheckBox)
		Declare Constructor
		
		Dim As ComboBoxEdit cobDevice, cobInstrument, cobChannel
		Dim As TrackBar tbNote, tbVelocity, tbVolume, tbBase
		Dim As CommandButton CommandButton1, CommandButton2
		Dim As Label lblNote, lblVelocity, lblVolume, lblBase
		Dim As Panel Panel1
		Dim As CheckBox CheckBox1
	End Type
	
	Constructor frmMidiKeyboardType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = "english"
			End With
		#endif
		' frmMidiKeyboard
		With This
			.Name = "frmMidiKeyboard"
			.Text = "Midi Keyboard"
			.Designer = @This
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.StartPosition = FormStartPosition.CenterScreen
			.Caption = "Midi Keyboard"
			.SetBounds 0, 0, 710, 270
		End With
		' CheckBox1
		With CheckBox1
			.Name = "CheckBox1"
			.Text = "Draw piano by Canvas"
			.TabIndex = 14
			.Caption = "Draw piano by Canvas"
			.SetBounds 520, 100, 160, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox), @CheckBox1_Click)
			.Parent = @This
		End With
		' cobDevice
		With cobDevice
			.Name = "cobDevice"
			.Text = "cobDevice"
			.TabIndex = 0
			.SetBounds 10, 10, 330, 21
			.Designer = @This
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @cobDevice_Selected)
			.Parent = @This
		End With
		' tbVolume
		With tbVolume
			.Name = "tbVolume"
			.Text = "tbVolume"
			.TabIndex = 1
			.MaxValue = 65535
			.MinValue = 0
			.Hint = "Volume"
			.PageSize = 1000
			.SetBounds 350, 10, 160, 20
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TrackBar, Position As Integer), @tbVolume_Change)
			.Parent = @This
		End With
		' lblVolume
		With lblVolume
			.Name = "lblVolume"
			.Text = "Volume"
			.TabIndex = 2
			.Caption = "Volume"
			.SetBounds 520, 15, 160, 20
			.Designer = @This
			.Parent = @This
		End With
		' cobInstrument
		With cobInstrument
			.Name = "cobInstrument"
			.Text = "cobInstrument"
			.TabIndex = 3
			.Hint = "Instrument"
			.SetBounds 10, 40, 500, 21
			.Designer = @This
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @cobInstrument_Selected)
			.Parent = @This
		End With
		' cobChannel
		With cobChannel
			.Name = "cobChannel"
			.Text = "cobChannel"
			.TabIndex = 4
			.Hint = "Channel"
			.SetBounds 520, 40, 160, 21
			.Designer = @This
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @cobChannel_Selected)
			.Parent = @This
		End With
		' tbVelocity
		With tbVelocity
			.Name = "tbVelocity"
			.Text = "tbVelocity"
			.TabIndex = 5
			.MaxValue = 127
			.Hint = "Note"
			.Position = 127
			.PageSize = 1
			.SetBounds 10, 70, 160, 20
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TrackBar, Position As Integer), @tbVelocity_Change)
			.Parent = @This
		End With
		' lblVelocity
		With lblVelocity
			.Name = "lblVelocity"
			.Text = "Velocity"
			.TabIndex = 6
			.Alignment = AlignmentConstants.taLeft
			.ID = 1024
			.Caption = "Velocity"
			.SetBounds 180, 75, 160, 20
			.Designer = @This
			.Parent = @This
		End With
		' tbBase
		With tbBase
			.Name = "tbBase"
			.Text = "TrackBar1"
			.TabIndex = 7
			.MaxValue = 63
			.Position = 31
			.SetBounds 350, 70, 160, 20
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TrackBar, Position As Integer), @tbBase_Change)
			.Parent = @This
		End With
		' lblBase
		With lblBase
			.Name = "lblBase"
			.Text = ""
			.TabIndex = 8
			.Caption = ""
			.SetBounds 520, 75, 160, 20
			.Designer = @This
			.Parent = @This
		End With
		' tbNote
		With tbNote
			.Name = "tbNote"
			.Text = "tbNote"
			.TabIndex = 9
			.MaxValue = 127
			.Hint = "Volume"
			.Position = 20
			.PageSize = 1
			.SetBounds 10, 100, 160, 20
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TrackBar, Position As Integer), @tbNote_Change)
			.Parent = @This
		End With
		' lblNote
		With lblNote
			.Name = "lblNote"
			.Text = "Note"
			.TabIndex = 10
			.Caption = "Note"
			.SetBounds 180, 105, 160, 20
			.Designer = @This
			.Parent = @This
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "Play"
			.TabIndex = 11
			.Caption = "Play"
			.SetBounds 350, 100, 80, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton1_Click)
			.Parent = @This
		End With
		' CommandButton2
		With CommandButton2
			.Name = "CommandButton2"
			.Text = "Stop"
			.TabIndex = 12
			.Caption = "Stop"
			.SetBounds 430, 100, 80, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton2_Click)
			.Parent = @This
		End With
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = "Panel1"
			.TabIndex = 13
			.Align = DockStyle.alBottom
			.SetBounds 65190, 131, 694, 100
			.Designer = @This
			.OnPaint = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas), @Panel1_Paint)
			.OnMouseMove = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Panel1_MouseMove)
			.OnMouseLeave = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Panel1_MouseLeave)
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Panel1_Click)
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frmMidiKeyboard As frmMidiKeyboardType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmMidiKeyboard.MainForm = True
		frmMidiKeyboard.Show
		App.Run
	#endif
'#End Region

Private Sub frmMidiKeyboardType.Form_Create(ByRef Sender As Control)
	Dim i As Integer
	Dim j As Integer
	Dim midicaps As MIDIOUTCAPS
	'添加设备
	If midiOutGetDevCaps(MIDIMAPPER, @midicaps, SizeOf(midicaps)) = 0 Then
		cobDevice.AddItem(midicaps.szPname)                 '添加设备名称
		j = cobDevice.NewIndex
		cobDevice.ItemData(j) = Cast(Any Ptr, -1)   '这是默认设备ID  = -1
	End If
	'添加其他设备
	For i = 0 To midiOutGetNumDevs() - 1
		If midiOutGetDevCaps(i, @midicaps, SizeOf(midicaps)) = 0 Then
			cobDevice.AddItem(midicaps.szPname)         '添加设备名称
			j = cobDevice.NewIndex
			cobDevice.ItemData(j) = Cast(Any Ptr, i)    '设备ID
		End If
	Next
	cobDevice.ItemIndex = 0
	cobDevice_Selected(cobDevice, 0)
	'添加乐器
	For i = 0 To Gunshot
		cobInstrument.AddItem(i + 1 & ". " & *InstrumentsStringC(i) & " (" & *InstrumentsStringE(i) & ")" )
	Next
	cobInstrument.ItemIndex = 0
	cobInstrument_Selected(cobInstrument, 0)
	'添加通道
	For i = 0 To channel16
		cobChannel.AddItem("Channel-" & i + 1)
	Next
	cobChannel.ItemIndex = 0
	cobChannel_Selected(cobChannel, 0)
	tbNote_Change(tbNote, 0)
	tbVelocity_Change(tbVelocity, 0)
	tbBase_Change(tbBase, 0)
End Sub

Private Sub frmMidiKeyboardType.cobDevice_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	mMidiID = CULng("" & cobDevice.ItemData(cobDevice.ItemIndex))
	If mMidiOut Then midiOutClose(mMidiOut)
	midiOutOpen(@mMidiOut, mMidiID, NULL, NULL, NULL)
	Dim sVol As DWORD
	midiOutGetVolume(mMidiOut, @sVol)
	tbVolume.Position = sVol And &HFFFF
	tbVolume_Change(tbVolume, 0)
	cobInstrument_Selected(cobInstrument, 0)
End Sub

Private Sub frmMidiKeyboardType.cobInstrument_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	SendProgramChange(mMidiOut, cobChannel.ItemIndex, cobInstrument.ItemIndex)
End Sub

Private Sub frmMidiKeyboardType.cobChannel_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	SendProgramChange(mMidiOut, cobChannel.ItemIndex, cobInstrument.ItemIndex)
End Sub

Private Sub frmMidiKeyboardType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	If mMidiOut Then midiOutClose(mMidiOut)
End Sub

Private Sub frmMidiKeyboardType.tbVolume_Change(ByRef Sender As TrackBar, Position As Integer)
	Dim sVol As DWORD = tbVolume.Position + (tbVolume.Position * &H10000)
	midiOutSetVolume(mMidiOut, sVol)
	lblVolume.Caption = "Volume: " & Format(tbVolume.Position, "#,#")
End Sub

Private Sub frmMidiKeyboardType.tbVelocity_Change(ByRef Sender As TrackBar, Position As Integer)
	lblVelocity.Caption = "Velocity: " & Format(tbVelocity.Position, "#,#")
End Sub

Private Sub frmMidiKeyboardType.tbNote_Change(ByRef Sender As TrackBar, Position As Integer)
	lblNote.Caption = "Note: " & Format(tbNote.Position, "#,#")
	CommandButton1_Click(CommandButton1)
	'Debug.Print "tbNote_Change=" & tbNote.Position
End Sub

Private Sub frmMidiKeyboardType.CommandButton1_Click(ByRef Sender As Control)
	SendNoteOn(mMidiOut, cobChannel.ItemIndex, tbNote.Position, tbVelocity.Position)
End Sub

Private Sub frmMidiKeyboardType.CommandButton2_Click(ByRef Sender As Control)
	SendNoteOff(mMidiOut, cobChannel.ItemIndex, tbNote.Position, 0)
End Sub

Private Function frmMidiKeyboardType.KeyInvalid(ByRef Canvas As My.Sys.Drawing.Canvas) As Boolean
	If KeyCount < 0 Then Return True
	With KeyPad(KeyCount)
		If .Right <> Canvas.Width Then Return True
		If .Bottom <> Canvas.Height Then Return True
	End With
	Return False
End Function

Private Sub frmMidiKeyboardType.KeyLocate(ByRef Canvas As My.Sys.Drawing.Canvas)
	Dim i As Long
	
	Dim w As Integer = Canvas.Width \ (KeyWhiteNumber + 1)
	Dim o As Integer = (Canvas.Width - w * (KeyWhiteNumber + 1)) / 2
	Dim hw As Integer = w * 0.6
	Dim hh As Integer = Canvas.Height * 0.55
	Dim j As Integer = 0
	
	For i = 0 To KeyWhiteNumber
		ReDim Preserve KeyPad(j)
		ReDim Preserve KeyBlack(j)
		With KeyPad(j)
			.Left = i*w - 1 + o
			.Top = 0
			.Right = (i + 1)*w + o
			.Bottom = Canvas.Height
			.Width = .Right - .Left
			.Height = .Bottom -.Top
		End With
		Select Case i
		Case 2, 6, 9, 13, 16, 20, 23, 27, 30, 34, 37
		Case Else
			j += 1
			ReDim Preserve KeyPad(j)
			ReDim Preserve KeyBlack(j)
			KeyBlack(j) = True
			With KeyPad(j)
				.Left = (i)*w - 1 + o + (2*w - hw) / 2
				.Top = 0
				.Right = (i)*w + o + (2*w - hw) / 2 + hw
				.Bottom = hh
				.Width = .Right - .Left
				.Height = .Bottom -.Top
			End With
		End Select
		j += 1
	Next
	ReDim Preserve KeyPad(j)
	ReDim Preserve KeyBlack(j)
	With KeyPad(j)
		.Left = 0
		.Top = 0
		.Right = Canvas.Width
		.Bottom = Canvas.Height
	End With
	KeyCount = j
End Sub

Private Function frmMidiKeyboardType.KeyIndexByXY(x As Integer, y As Integer) As Integer
	Dim i As Integer
	For i = 0 To KeyCount - 1
		If KeyBlack(i) Then
			With KeyPad(i)
				If (x > .Left) And (x < .Right) And (y > .Top) And (y < .Bottom) Then Return i
			End With
		End If
	Next
	For i = 0 To KeyCount - 1
		If KeyBlack(i) = False Then
			With KeyPad(i)
				If (x > .Left) And (x < .Right) And (y > .Top) And (y < .Bottom) Then Return i
			End With
		End If
	Next
	Return -1
End Function

Private Sub frmMidiKeyboardType.Panel1_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	Dim i As Long
	If KeyInvalid(Canvas) Then KeyLocate(Canvas)
	
	If KeyCanvas Then
		For i = 0 To KeyCount - 1
			With KeyPad(i)
				If KeyBlack(i) = False Then
					If KeyIndex = i Then
						Canvas.Line(.Left, .Top, .Right, .Bottom, vbRGB(&Hff, &Hff, &H00), "F")
					Else
						Canvas.Line(.Left, .Top, .Right, .Bottom, , "B")
					End If
				End If
			End With
		Next
		For i = 0 To KeyCount - 1
			With KeyPad(i)
				If KeyBlack(i) Then
					If KeyIndex = i Then
						Canvas.Line(.Left, .Top, .Right, .Bottom, vbRGB(&Hff, &Hff, &H00) , "F")
					Else
						Canvas.Line(.Left, .Top, .Right, .Bottom, vbRGB(&H00, &H00, &H00), "F")
					End If
				End If
			End With
		Next
	Else
		frmDC.Initial(Panel1.Handle)
		memDC.Initial(0, Canvas.Width*xdpi, Canvas.Height*ydpi)
		frmGraphic.Initial(memDC.DC, True)
		
		Dim sBrushW As Any Ptr
		Dim sBrushB As Any Ptr
		Dim sBrushA As Any Ptr
		Dim sPen As GpPen Ptr
		
		GdipCreateSolidFill(RGBA(&HFF, &HFF, &HFF, &HFF), @sBrushW)
		GdipCreateSolidFill(RGBA(&H00, &H00, &H00, &HFF), @sBrushB)
		GdipCreateSolidFill(RGBA(&HFF, &HFF, &H00, &HFF), @sBrushA)
		GdipCreatePen1(RGBA(&H00, &H00, &H00, &HFF), 1, UnitPixel, @sPen)
		
		
		For i = 0 To KeyCount - 1
			With KeyPad(i)
				If KeyBlack(i) = False Then
					If KeyIndex = i Then
						GdipFillRectangle(frmGraphic.Graphics, sBrushA, .Left, .Top, .Width, .Height)
						GdipDrawRectangle(frmGraphic.Graphics, sPen, .Left, .Top, .Width, .Height)
					Else
						GdipFillRectangle(frmGraphic.Graphics, sBrushW, .Left, .Top, .Width, .Height)
						GdipDrawRectangle(frmGraphic.Graphics, sPen, .Left, .Top, .Width, .Height)
					End If
				End If
			End With
		Next
		For i = 0 To KeyCount - 1
			With KeyPad(i)
				If KeyBlack(i) Then
					If KeyIndex = i Then
						GdipFillRectangle(frmGraphic.Graphics, sBrushA, .Left, .Top, .Width, .Height)
						GdipDrawRectangle(frmGraphic.Graphics, sPen, .Left, .Top, .Width, .Height)
					Else
						GdipFillRectangle(frmGraphic.Graphics, sBrushB, .Left, .Top, .Width, .Height)
						GdipDrawRectangle(frmGraphic.Graphics, sPen, .Left, .Top, .Width, .Height)
					End If
				End If
			End With
		Next
		GdipDeleteBrush(sBrushW)
		GdipDeleteBrush(sBrushB)
		GdipDeleteBrush(sBrushA)
		GdipDeletePen(sPen)
		
		BitBlt(frmDC.DC, 0, 0, ClientWidth*xdpi, ClientHeight*ydpi, memDC.DC, 0, 0, SRCCOPY)
	End If
End Sub

Private Sub frmMidiKeyboardType.Panel1_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	Dim i As Integer = KeyIndexByXY(x, y)
	If i <> KeyIndex Then
		KeyIndex = i
		Panel1_Paint(Panel1, Panel1.Canvas)
		'Debug.Print "KeyIndex=" & KeyIndex & ", MouseButton=" & MouseButton
		If MouseButton=0 Then
			SendNoteOn(mMidiOut, cobChannel.ItemIndex, KeyBase+ KeyIndex, tbVelocity.Position)
		End If
		
		Dim pTmp As WString Ptr
		
		WLet(pTmp, "")
		If cobChannel.ItemIndex = 9 Then
			WLet(pTmp, *PercussionStringE(KeyIndex + KeyBase))
		End If
		
		If *pTmp = "" Then
			WLet(pTmp, *NoteStringE((KeyIndex + KeyBase)  Mod 12))
		End If
		
		Panel1.Hint = KeyIndex + KeyBase & " - Note " & *pTmp
		
		Deallocate(pTmp)
	End If
	
End Sub

Private Sub frmMidiKeyboardType.Panel1_MouseLeave(ByRef Sender As Control)
	If KeyIndex <> -1 Then
		KeyIndex = -1
		Panel1_Paint(Panel1, Panel1.Canvas)
		'Debug.Print "KeyIndex=" & KeyIndex
	End If
End Sub

Private Sub frmMidiKeyboardType.Panel1_Click(ByRef Sender As Control)
	SendNoteOn(mMidiOut, cobChannel.ItemIndex, KeyBase + KeyIndex, tbVelocity.Position)
	'Debug.Print KeyBase + KeyIndex
End Sub

Private Sub frmMidiKeyboardType.tbBase_Change(ByRef Sender As TrackBar, Position As Integer)
	KeyBase = tbBase.Position
	lblBase.Caption = "Base Note " & KeyBase & " - " & *NoteStringE(KeyBase Mod 12)
End Sub

Private Sub frmMidiKeyboardType.CheckBox1_Click(ByRef Sender As CheckBox)
	KeyCanvas = CheckBox1.Checked
	Panel1.DoubleBuffered = KeyCanvas
	Panel1_Paint(Panel1, Panel1.Canvas)
End Sub
