'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "frmMidiPlayer.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/TrackBar.bi"
	#include once "mff/Dialogs.bi"
	#include once "mff/TimerComponent.bi"
	#include once "mff/Label.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/Panel.bi"
	#include once "mff/ListView.bi"
	#include once "mff/TreeView.bi"
	#include once "mff/RadioButton.bi"
	#include once "mff/Menus.bi"
	#include once "mff/ImageList.bi"
	
	#include once "../MDINotepad/text.bi"
	#include once "midi.bi"
	#include once "midiPlayer.bi"
	#include once "vbcompat.bi"
	
	Using My.Sys.Forms
	
	Type frmMidiPlayerType Extends Form
		mFullHeight As Integer
		mFullWidth As Integer
		mBorderHeight As Integer
		mBorderWidth As Integer
		
		mFileList As WString Ptr
		
		Midi As midiPlayer
		mPositionUpdate As Boolean = True
		
		cActive As Integer      'active color
		cEnabled As Integer     'enabled color
		cDisabled As Integer    'disabled color
		cUnused As Integer      'unused color
		cNote As Integer        'note color
		
		ActiveChannel As Integer = -1
		
		chkChannel(MidiChannelCount) As CheckBox Ptr
		pnlAct(MidiChannelCount) As Panel Ptr
		pnlNote(MidiChannelCount) As Panel Ptr
		MIChinese As Boolean = False    'used chinese name for mi
		
		NoteCount As Integer = &h7f     'start from 0
		NotePad(Any) As RectPi          'notes array
		
		Declare Function NoteIndexByXY(x As Integer, y As Integer) As Integer
		Declare Function NoteInvalid(ByRef Canvas As My.Sys.Drawing.Canvas) As Boolean
		Declare Sub NoteChannels(ByVal v As Integer = -1)
		Declare Sub NoteClear(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub NoteLocate(ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub NoteDraw(ByRef Canvas As My.Sys.Drawing.Canvas, ByRef sNote As Integer, ByRef isOn As Boolean)
		
		Declare Static Sub OnChange(Owner As Any Ptr, Channel As UByte, Instrument As UByte)
		Declare Static Sub OnNoteOff(Owner As Any Ptr, Channel As UByte, Note As UByte)
		Declare Static Sub OnNoteOn(Owner As Any Ptr, Channel As UByte, Note As UByte, Velocity As UByte)
		Declare Static Sub OnPlayStatus(Owner As Any Ptr, sStatus As MidiPlayStatus)
		Declare Static Sub OnPosition(Owner As Any Ptr, sPosition As Double)
		
		Declare Sub CheckBox_Click(ByRef Sender As CheckBox)
		Declare Sub ComboBoxEdit_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub CommandButton_Click(ByRef Sender As Control)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
		Declare Sub Label_Click(ByRef Sender As Control)
		Declare Sub ListView1_ItemDblClick(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub Menu_Click(ByRef Sender As MenuItem)
		Declare Sub Panel_Click(ByRef Sender As Control)
		Declare Sub Panel_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub RadioButton_Click(ByRef Sender As RadioButton)
		Declare Sub TrackBar_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Sub TrackBar_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub TrackBar_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Constructor
		
		Dim As CommandButton cmdNext, cmdPrev, cmdStop, cmdPause, cmdContinue, cmdShow
		Dim As CheckBox chkReset, chkDark, chkAll
		Dim As ComboBoxEdit cmbDevice
		Dim As Label lblVolume, lblSpeed, lblPosition, lblInstruments, lblNote
		Dim As RadioButton rdbLoopNone, rdbLoop1, rdbLoopList
		Dim As TrackBar tbVolume, tbSpeed, tbPosition
		Dim As ListView ListView1
		Dim As ImageList ImageList1
		Dim As OpenFileDialog OpenFileDialog1
		Dim As PopupMenu PopupMenu1
		Dim As MenuItem mnuAdd, mnuDelete, mnuClear
	End Type
	
	Constructor frmMidiPlayerType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = .Language
			End With
		#endif
		' frmMidiPlayer
		With This
			.Name = "frmMidiPlayer"
			.Text = "MidiPlayer"
			.Designer = @This
			.Caption = "MidiPlayer"
			.StartPosition = FormStartPosition.CenterScreen
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.AllowDrop = True
			.OnDropFile = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Filename As WString), @Form_DropFile)
			.BorderStyle = FormBorderStyle.FixedSingle
			.MaximizeBox = False
			.Anchor.Right = AnchorStyle.asAnchor
			.ControlBox = True
			.SetBounds 0, 0, 735, 590
		End With
		' cmdNext
		With cmdNext
			.Name = "cmdNext"
			.Text = "Next"
			.TabIndex = 1
			.Caption = "Next"
			.SetBounds 10, 10, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @This
		End With
		' cmdPrev
		With cmdPrev
			.Name = "cmdPrev"
			.Text = "Prev"
			.TabIndex = 2
			.Caption = "Prev"
			.SetBounds 80, 10, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @This
		End With
		' cmdStop
		With cmdStop
			.Name = "cmdStop"
			.Text = "Stop"
			.TabIndex = 3
			.Caption = "Stop"
			.Enabled = False
			.SetBounds 150, 10, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @This
		End With
		' cmdPause
		With cmdPause
			.Name = "cmdPause"
			.Text = "Pause"
			.TabIndex = 4
			.Caption = "Pause"
			.Enabled = False
			.SetBounds 220, 10, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @This
		End With
		' cmdContinue
		With cmdContinue
			.Name = "cmdContinue"
			.Text = "Continue"
			.TabIndex = 5
			.Caption = "Continue"
			.Enabled = False
			.SetBounds 290, 10, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @This
		End With
		' rdbLoopNone
		With rdbLoopNone
			.Name = "rdbLoopNone"
			.Text = "No loop"
			.TabIndex = 6
			.Caption = "No loop"
			.SetBounds 10, 40, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton), @RadioButton_Click)
			.Parent = @This
		End With
		' rdbLoop1
		With rdbLoop1
			.Name = "rdbLoop1"
			.Text = "Loop 1"
			.TabIndex = 7
			.Caption = "Loop 1"
			.Checked = True
			.SetBounds 80, 40, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton), @RadioButton_Click)
			.Parent = @This
		End With
		' rdbLoopList
		With rdbLoopList
			.Name = "rdbLoopList"
			.Text = "Loop list"
			.TabIndex = 8
			.Caption = "Loop list"
			.SetBounds 150, 40, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton), @RadioButton_Click)
			.Parent = @This
		End With
		' chkReset
		With chkReset
			.Name = "chkReset"
			.Text = "Reset"
			.TabIndex = 9
			.Caption = "Reset"
			.Hint = "Reset Volume and Speed on play"
			.SetBounds 220, 40, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox), @CheckBox_Click)
			.Parent = @This
		End With
		' chkDark
		With chkDark
			.Name = "chkDark"
			.Text = "Dark"
			.TabIndex = 10
			.Caption = "Dark"
			.Checked = True
			.SetBounds 290, 40, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox), @CheckBox_Click)
			.Parent = @This
		End With
		' cmbDevice
		With cmbDevice
			.Name = "cmbDevice"
			.Text = "cmbDevice"
			.TabIndex = 11
			.SetBounds 10, 80, 350, 21
			.Designer = @This
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @ComboBoxEdit_Selected)
			.Parent = @This
		End With
		' lblVolume
		With lblVolume
			.Name = "lblVolume"
			.Text = "Volume"
			.TabIndex = 12
			.Caption = "Volume"
			.Alignment = AlignmentConstants.taCenter
			.Hint = "Reset volume"
			.SetBounds 10, 114, 150, 14
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Label_Click)
			.Parent = @This
		End With
		' tbVolume
		With tbVolume
			.Name = "tbVolume"
			.Text = "Volume"
			.TabIndex = 13
			.MaxValue = 65535
			.MinValue = 0
			.Position = 20000
			.TickStyle = TickStyles.tsNone
			.ID = 1026
			.ThumbLength = 20
			.PageSize = 1000
			.SetBounds 10, 130, 150, 20
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TrackBar, Position As Integer), @TrackBar_Change)
			.Parent = @This
		End With
		' cmdShow
		With cmdShow
			.Name = "cmdShow"
			.Text = "<"
			.TabIndex = 14
			.Caption = "<"
			.Hint = "Expand or shrink"
			.SetBounds 170, 130, 30, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @This
		End With
		' lblSpeed
		With lblSpeed
			.Name = "lblSpeed"
			.Text = "Speed"
			.TabIndex = 15
			.Caption = "Speed"
			.Alignment = AlignmentConstants.taCenter
			.Hint = "Reset speed"
			.SetBounds 210, 114, 150, 14
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Label_Click)
			.Parent = @This
		End With
		' tbSpeed
		With tbSpeed
			.Name = "tbSpeed"
			.Text = "Speed"
			.TabIndex = 16
			.MaxValue = 10000
			.Position = 1000
			.MinValue = 100
			.TickStyle = TickStyles.tsNone
			.ID = 1039
			.PageSize = 100
			.SetBounds 210, 130, 150, 20
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TrackBar, Position As Integer), @TrackBar_Change)
			.Parent = @This
		End With
		' lblPosition
		With lblPosition
			.Name = "lblPosition"
			.Text = "Position"
			.TabIndex = 17
			.Caption = "Position"
			.Alignment = AlignmentConstants.taCenter
			.SetBounds 20, 164, 330, 14
			.Designer = @This
			.Parent = @This
		End With
		' tbPosition
		With tbPosition
			.Name = "tbPosition"
			.Text = "Position"
			.TabIndex = 18
			.TickStyle = TickStyles.tsNone
			.ID = 1130
			.MaxValue = 10000
			.Enabled = False
			.SetBounds 10, 180, 350, 20
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TrackBar, Position As Integer), @TrackBar_Change)
			.OnMouseUp = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @TrackBar_MouseUp)
			.OnMouseDown = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @TrackBar_MouseDown)
			.Parent = @This
		End With
		' ListView1
		With ListView1
			.Name = "ListView1"
			.Text = "ListView1"
			.TabIndex = 19
			.GridLines = False
			.ColumnHeaderHidden = True
			.ContextMenu = @PopupMenu1
			.MultiSelect = True
			.Images = @ImageList1
			.SmallImages = @ImageList1
			.Hint = "Playlist"
			.SetBounds 370, 10, 350, 190
			.Designer = @This
			.OnItemDblClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer), @ListView1_ItemDblClick)
			.Parent = @This
		End With
		' chkAll
		With chkAll
			.Name = "chkAll"
			.Text = "Select All Channel"
			.TabIndex = 20
			.BackColor = 16744576
			.Caption = "Select All Channel"
			.Checked = True
			.Font.Bold = True
			.ForeColor = 16777215
			.SetBounds 10, 210, 210, 18
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox), @CheckBox_Click)
			.Parent = @This
		End With
		' lblInstruments
		With lblInstruments
			.Name = "lblInstruments"
			.Text = "E"
			.TabIndex = 21
			.BackColor = 16744576
			.Hint = "Switch between English and Chinese for instrument name"
			.Alignment = AlignmentConstants.taCenter
			.ID = 1019
			.ForeColor = 16777215
			.Font.Bold = True
			.SetBounds 225, 210, 20, 18
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Label_Click)
			.Parent = @This
		End With
		' lblNote
		With lblNote
			.Name = "lblNote"
			.Text = "Note"
			.TabIndex = 22
			.BackColor = 16744576
			.ForeColor = 16777215
			.Font.Bold = True
			.Caption = "Note"
			.Alignment = AlignmentConstants.taCenter
			.ID = 1020
			.SetBounds 250, 210, 470, 18
			.Designer = @This
			.Parent = @This
		End With
		' ImageList1
		With ImageList1
			.Name = "ImageList1"
			.SetBounds 300, 60, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' OpenFileDialog1
		With OpenFileDialog1
			.Name = "OpenFileDialog1"
			.Filter = "Midi files|*.mid"
			.MultiSelect = True
			.SetBounds 340, 60, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' PopupMenu1
		With PopupMenu1
			.Name = "PopupMenu1"
			.SetBounds 320, 60, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' mnuAdd
		With mnuAdd
			.Name = "mnuAdd"
			.Designer = @This
			.Caption = "Add"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @Menu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuDelete
		With mnuDelete
			.Name = "mnuDelete"
			.Designer = @This
			.Caption = "Delete"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @Menu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuClear
		With mnuClear
			.Name = "mnuClear"
			.Designer = @This
			.Caption = "Clear"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @Menu_Click)
			.Parent = @PopupMenu1
		End With
	End Constructor
	
	Dim Shared frmMidiPlayer As frmMidiPlayerType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmMidiPlayer.MainForm = True
		frmMidiPlayer.Show
		App.Run
	#endif
'#End Region

'is invalid notes
Private Function frmMidiPlayerType.NoteInvalid(ByRef Canvas As My.Sys.Drawing.Canvas) As Boolean
	With NotePad(NoteCount + 1)
		If .Width <> Canvas.Width Then Return True
		If .Height <> Canvas.Height Then Return True
	End With
	Return False
End Function

'init notes
Private Sub frmMidiPlayerType.NoteLocate(ByRef Canvas As My.Sys.Drawing.Canvas)
	Dim i As Long
	
	Dim w As Integer = Canvas.Width / (NoteCount + 1)
	Dim o As Integer = (Canvas.Width - w * (NoteCount + 1)) / 2
	
	For i = 0 To NoteCount
		With NotePad(i)
			.Left = i*w - 1 + o
			.Top = 0
			.Right = (i + 1)*w + o
			.Bottom = Canvas.Height
			.Width = .Right - .Left
			.Height = .Bottom -.Top
		End With
	Next
	With NotePad(NoteCount + 1)
		.Left = o
		.Top = 0
		.Width = Canvas.Width
		.Height = Canvas.Height
		.Right = o + w * (NoteCount + 1)
		.Bottom = Canvas.Height
	End With
End Sub

'draw notes
Private Sub frmMidiPlayerType.NoteDraw(ByRef Canvas As My.Sys.Drawing.Canvas, ByRef Note As Integer, ByRef isOn As Boolean)
	With NotePad(Note)
		If isOn Then
			Canvas.Line(.Left, .Top, .Right, .Bottom, cNote, "F")
		Else
			Canvas.Line(.Left, .Top, .Right, .Bottom, Canvas.BackColor, "F")
		End If
	End With
End Sub

'clear notes
Private Sub frmMidiPlayerType.NoteClear(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	If NoteInvalid(Canvas) Then NoteLocate(Canvas)
	Canvas.Cls
End Sub

Private Function frmMidiPlayerType.NoteIndexByXY(x As Integer, y As Integer) As Integer
	Dim i As Integer
	For i = 0 To NoteCount
		With NotePad(i)
			If (x > .Left) And (x < .Right) And (y > .Top) And (y < .Bottom) Then Return i
		End With
	Next
	Return -1
End Function

Private Sub frmMidiPlayerType.Panel_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	NoteClear(Sender, Canvas)
End Sub

Private Sub frmMidiPlayerType.Form_Create(ByRef Sender As Control)
	mFullHeight = Height
	mFullWidth = Width
	mBorderHeight = Height - ClientHeight
	mBorderWidth = Width - ClientWidth
	
	'init notes
	ReDim NotePad(NoteCount + 1)
	
	'init events for midiplayer
	Midi.mOwner = @This
	Midi.OnChange = Cast(Sub(Owner As Any Ptr, Channel As UByte, Instrument As UByte), @OnChange)
	Midi.OnNoteOn = Cast(Sub(Owner As Any Ptr, Channel As UByte, Note As UByte, Velocity As UByte), @OnNoteOn)
	Midi.OnNoteOff = Cast(Sub(Owner As Any Ptr, Channel As UByte, Note As UByte), @OnNoteOff)
	Midi.OnPlayStatus = Cast(Sub(Owner As Any Ptr, sStatus As MidiPlayStatus), @OnPlayStatus)
	Midi.OnPosition = Cast(Sub(Owner As Any Ptr, sPosition As Double), @OnPosition)
	
	Dim i As Integer
	Dim j As Integer
	Dim midicaps As MIDIOUTCAPS
	'add default midi device to comboboxedit
	If midiOutGetDevCaps(MIDIMAPPER, @midicaps, SizeOf(midicaps)) = 0 Then
		cmbDevice.AddItem(midicaps.szPname)
		j = cmbDevice.NewIndex
		cmbDevice.ItemData(j) = Cast(Any Ptr, -1)
	End If
	'add other midi devices
	For i = 0 To midiOutGetNumDevs() - 1
		If midiOutGetDevCaps(i, @midicaps, SizeOf(midicaps)) = 0 Then
			cmbDevice.AddItem(midicaps.szPname)         '添加设备名称
			j = cmbDevice.NewIndex
			cmbDevice.ItemData(j) = Cast(Any Ptr, i)    '设备ID
		End If
	Next
	cmbDevice.ItemIndex = 0
	ComboBoxEdit_Selected(cmbDevice, 0)
	
	'reset default midi volume
	Label_Click(lblVolume)
	'reset default midi speed
	'Label_Click(lblSpeed)
	
	'load controls for channels, acts, notes
	For i = 0 To MidiChannelCount
		chkChannel(i) = New CheckBox
		Add chkChannel(i)
		With *chkChannel(i)
			.Hint = "Channel (" & i & ")"
			.Caption = Format(i, "00")
			.SetBounds(chkAll.Left, chkAll.Top + (chkAll.Height + 2) * (i + 1), chkAll.Width, chkAll.Height)
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox), @CheckBox_Click)
			.Name = "" & i
			'.Tag = @This
			.Designer = @This
			.Parent = @This
			.Visible= True
		End With
		pnlAct(i) = New Panel
		Add pnlAct(i)
		With *pnlAct(i)
			.Hint = "Active Channel (" & i & ")"
			.SetBounds(lblInstruments.Left, lblInstruments.Top + (lblInstruments.Height + 2) * (i + 1), lblInstruments.Width, lblInstruments.Height)
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Panel_Click)
			.Text = "" & i
			.Name = "pnlAct"
			'.Tag = @This
			.Designer = @This
			.Parent = @This
			.Visible= True
		End With
		pnlNote(i) = New Panel
		Add pnlNote(i)
		With *pnlNote(i)
			.Hint = "Select Channel (" & i & ") only"
			.SetBounds(lblNote.Left, lblNote.Top + (lblNote.Height + 2) * (i + 1), lblNote.Width, lblNote.Height)
			.OnPaint = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas), @Panel_Paint)
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Panel_Click)
			.Text = "" & i
			.Name = "pnlNote"
			'.Tag = @This
			.Designer = @This
			.Parent = @This
			.Visible= True
		End With
	Next
	
	Midi.loopOne = rdbLoop1.Checked
	CheckBox_Click(chkDark)
	
	'init imagelist
	Dim pFileInfo As SHFILEINFO
	ImageList1.Handle = Cast(Any Ptr,SHGetFileInfo("", 0, @pFileInfo, SizeOf(pFileInfo), SHGFI_SYSICONINDEX Or SHGFI_ICON Or SHGFI_SMALLICON Or SHGFI_LARGEICON Or SHGFI_PIDL Or SHGFI_DISPLAYNAME Or SHGFI_TYPENAME Or SHGFI_ATTRIBUTES))
	SendMessage(ListView1.Handle, LVM_SETIMAGELIST, LVSIL_SMALL, Cast(LPARAM, ImageList1.Handle))
	'init columns of listview for midi playlist
	ListView1.Columns.Add("Name", , ListView1.Width - 22)
	'playlist init from .\MidiPlayer.ini
	WLet(mFileList, ExePath() & "\MidiPlayer.ini")
	If Dir(*mFileList) = "" Then Exit Sub
	Dim s() As WString Ptr
	Dim t As WString Ptr
	TextFromFile(*mFileList, t)
	j = SplitWStr(*t, WStr(vbCrLf), s())
	For i = 0 To j
		Form_DropFile(ListView1,*s(i))
	Next
	ArrayDeallocate(s())
	If t Then Deallocate(t)
End Sub

Private Sub frmMidiPlayerType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	'stop play
	If Midi.midiThread Then
		CommandButton_Click(cmdStop)
		Action = False
		Exit Sub
	End If
	
	Dim i As Integer
	
	'release control
	For i = 0 To MidiChannelCount
		Remove chkChannel(i)
		Delete chkChannel(i)
		Remove pnlAct(i)
		Delete pnlAct(i)
		Remove pnlNote(i)
		Delete pnlNote(i)
	Next
	Erase chkChannel
	Erase pnlAct
	Erase pnlNote
	Erase NotePad
	
	'update playlist
	If Dir(*mFileList) <> "" Then Kill(*mFileList)
	Dim j As Integer = ListView1.ListItems.Count - 1
	
	If j >-1 Then
		Dim s() As WString Ptr
		Dim t As WString Ptr
		ReDim s(j)
		For i = 0 To j
			WLet(s(i), ListView1.ListItems.Item(i)->Text(0))
		Next
		JoinWStr(s(), WStr(vbCrLf), t)
		TextToFile(*mFileList, *t)
		ArrayDeallocate(s())
		If t Then Deallocate(t)
	End If
	If mFileList Then Deallocate(mFileList)
End Sub

'midi Instrument changes
Private Sub frmMidiPlayerType.OnChange(Owner As Any Ptr, Channel As UByte, Instrument As UByte)
	Dim a As frmMidiPlayerType Ptr = Owner
	a->chkChannel(Channel)->Caption = Format(Channel, "00") & " " & IIf(a->MIChinese, *InstrumentsStringC(Instrument), *InstrumentsStringE(Instrument))
End Sub
'draw midi note on
Private Sub frmMidiPlayerType.OnNoteOn(Owner As Any Ptr, Channel As UByte, Note As UByte, Velocity As UByte)
	Dim a As frmMidiPlayerType Ptr = Owner
	a->NoteDraw(a->pnlNote(Channel)->Canvas, Note + 0, True)
End Sub
'draw midi note off
Private Sub frmMidiPlayerType.OnNoteOff(Owner As Any Ptr, Channel As UByte, Note As UByte)
	Dim a As frmMidiPlayerType Ptr = Owner
	a->NoteDraw(a->pnlNote(Channel)->Canvas, Note + 0, False)
End Sub
'midi position changes
Private Sub frmMidiPlayerType.OnPosition(Owner As Any Ptr, sPosition As Double)
	Dim a As frmMidiPlayerType Ptr = Owner
	If a->mPositionUpdate Then a->tbPosition.Position = sPosition * 1000
End Sub
'midi play status changes
Private Sub frmMidiPlayerType.OnPlayStatus(Owner As Any Ptr, sStatus As MidiPlayStatus)
	Dim a As frmMidiPlayerType Ptr = Owner
	
	Select Case sStatus
	Case MidiPlayStatus.MidiPlaying
		a->ActiveChannel = -1
		a->tbPosition.MaxValue = a->Midi.TotalTime * 1000
		a->chkAll.Checked = True
		a->cmdNext.Enabled = True
		a->cmdContinue.Enabled = False
		a->cmdPause.Enabled = True
		a->cmdStop.Enabled = True
		a->cmbDevice.Enabled = False
		a->NoteChannels()
	Case MidiPlayStatus.MidiBreak
		a->cmdNext.Enabled = True
		a->cmdContinue.Enabled = False
		a->cmdPause.Enabled = False
		a->cmdStop.Enabled = False
		a->cmbDevice.Enabled = True
		a->tbPosition.Position = 0
		a->tbPosition.Enabled = False
		a->lblPosition.Caption = "Position"
		a->NoteChannels()
	Case MidiPlayStatus.MidiStopped
		a->cmdNext.Enabled = True
		a->cmdContinue.Enabled = False
		a->cmdPause.Enabled = False
		a->cmdStop.Enabled = False
		a->cmbDevice.Enabled = True
		a->tbPosition.Position = 0
		a->tbPosition.Enabled = False
		a->lblPosition.Caption = "Position"
		a->NoteChannels()
		If a->rdbLoopList.Checked = False Then Exit Sub
		'loop list
		a->CommandButton_Click(a->cmdNext)
	Case MidiPlayStatus.MidiPause
		a->cmdNext.Enabled = True
		a->cmdContinue.Enabled = True
		a->cmdPause.Enabled = False
		a->cmdStop.Enabled = True
		a->cmbDevice.Enabled = True
	Case MidiPlayStatus.MidiContinue
		a->cmdNext.Enabled = True
		a->cmdContinue.Enabled = False
		a->cmdPause.Enabled = True
		a->cmdStop.Enabled = True
		a->cmbDevice.Enabled = False
	Case MidiPlayStatus.MidiLooping
	Case MidiPlayStatus.MidiError
		a->Caption = a->Midi.ErrMsg
	End Select
End Sub

Private Sub frmMidiPlayerType.CommandButton_Click(ByRef Sender As Control)
	Dim i As Integer
	Select Case Sender.Name
	Case "cmdPrev"
		If ListView1.ListItems.Count - 1 < 0 Then Exit Sub
		
		Dim j As Integer
		Dim k As Integer = -1
		For i = 0 To ListView1.ListItems.Count - 1
			If ListView1.ListItems.Item(i)->Selected Then
				If k < 0 Then k = i
				ListView1.ListItems.Item(i)->Selected = False
			End If
		Next
		
		If k < 0 Then
			k = ListView1.ListItems.Count - 1
		Else
			If k = 0 Then
				k = ListView1.ListItems.Count - 1
			Else
				k -= 1
			End If
		End If
		ListView1.ListItems.Item(k)->Selected = True
		ListView1.EnsureVisible(k)
		
		ListView1_ItemDblClick(ListView1, ListView1.SelectedItemIndex)
	Case "cmdNext"
		If ListView1.ListItems.Count - 1 < 0 Then Exit Sub
		
		Dim j As Integer
		Dim k As Integer = -1
		For i = 0 To ListView1.ListItems.Count - 1
			If ListView1.ListItems.Item(i)->Selected Then
				If k < 0 Then k = i
				ListView1.ListItems.Item(i)->Selected = False
			End If
		Next
		
		If k < 0 Then
			k = 0
		Else
			If k = ListView1.ListItems.Count - 1 Then
				k = 0
			Else
				k += 1
			End If
		End If
		ListView1.ListItems.Item(k)->Selected = True
		ListView1.EnsureVisible(k)
		Height
		ClientHeight
		ListView1_ItemDblClick(ListView1, ListView1.SelectedItemIndex)
	Case "cmdContinue"
		Midi.Resume
		
	Case "cmdPause"
		Midi.Pause(True)
		
	Case "cmdStop"
		Midi.Stop
	Case "cmdShow"
		If Sender.Text = "<" Then
			Sender.Text = ">"
			Move Left, Top, mBorderWidth + ListView1.Left, mBorderHeight + chkAll.Top
		Else
			Sender.Text = "<"
			Move Left, Top, mFullWidth, mFullHeight
		End If
	End Select
End Sub

'add midi file to list
Private Sub frmMidiPlayerType.Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
	Dim pFileInfo As SHFILEINFO
	SHGetFileInfo(Filename, FILE_ATTRIBUTE_NORMAL, @pFileInfo, SizeOf(pFileInfo), SHGFI_USEFILEATTRIBUTES Or SHGFI_SMALLICON Or SHGFI_SYSICONINDEX Or SHGFI_ICON Or SHGFI_LARGEICON)
	ListView1.ListItems.Add(Filename, pFileInfo.iIcon)
End Sub

Private Sub frmMidiPlayerType.ListView1_ItemDblClick(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	If ItemIndex < 0 Then Exit Sub
	If Midi.midiThread Then
		CommandButton_Click(cmdStop)
		ListView1.ListItems.Item(ItemIndex)->Selected = True
	End If
	
	If chkReset.Checked Then
		'reset default midi volume
		Label_Click(lblVolume)
		'reset default midi speed
		Label_Click(lblSpeed)
	End If
	
	Caption = "MidiPlayer - " & ListView1.ListItems.Item(ItemIndex)->Text(0)
	Midi.Play(ListView1.ListItems.Item(ItemIndex)->Text(0))
End Sub

Private Sub frmMidiPlayerType.ComboBoxEdit_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	Midi.Device = CULng("" & cmbDevice.ItemData(cmbDevice.ItemIndex))
	TrackBar_Change(tbVolume, 0)
End Sub

Private Sub frmMidiPlayerType.Label_Click(ByRef Sender As Control)
	Select Case Sender.Name
	Case "lblInstruments"
		MIChinese= Not MIChinese
		If Midi.PlayStatus = MidiPlayStatus.MidiStopped Then Exit Sub
		Dim i As Integer
		For i = 0 To MidiChannelCount
			If Midi.UsedChannel(i) Then
				chkChannel(i)->Caption = Format(i, "00") & " " & IIf(MIChinese, *InstrumentsStringC(Midi.MIChannel(i)), *InstrumentsStringE(Midi.MIChannel(i)))
			End If
		Next
		lblInstruments.Text = IIf(MIChinese, "C", "E")
	Case "lblSpeed"
		tbSpeed.Position = 1000
	Case "lblPosition"
	Case "lblVolume"
		tbVolume.Position = 20000
		TrackBar_Change(tbVolume, 20000)
	End Select
End Sub

Private Function Sec2Time(Sec As Double, ByVal hfmt As String = "0", ByVal mfmt As String = "00", ByVal sfmt As String = "00", ByVal msfmt As String = ".00") As String
	Dim iTtlSec As Integer = Int(Sec)
	Dim iHour As Integer
	Dim iMin As Integer
	Dim iSec As Integer
	Dim Ms As Double
	Dim Rtn As String
	iHour = iTtlSec \ 3600
	iMin = (iTtlSec - iHour * 3600) \ 60
	iSec = iTtlSec - (iHour * 3600) - (iMin * 60)
	Ms = Sec - iTtlSec
	Rtn = Format(iHour, hfmt) & ":" & Format(iMin, mfmt) & ":" & Format(iSec, sfmt)
	If Ms < 0.009 Then
		Rtn += msfmt
	Else
		Rtn += Format(Ms, msfmt)
	End If
	Return Rtn
End Function

Private Sub frmMidiPlayerType.TrackBar_Change(ByRef Sender As TrackBar, Position As Integer)
	Select Case Sender.Name
	Case "tbPosition"
		Dim s As Double = tbPosition.Position / 1000
		Dim t As Double = tbPosition.MaxValue / 1000
		Dim p As Double = s / t * 100
		Dim ps As String
		If p = Int(p) Then
			ps = p & ".00%"
		Else
			ps = Format(p, "0.00") & "%"
		End If
		Static pWStr As WString Ptr
		WLet(pWStr, "Position: " & Sec2Time(s) & " / " & Sec2Time(t) & " " & ps)
		lblPosition.Caption = *pWStr
		If tbPosition.Enabled Then Exit Sub
		tbPosition.Enabled = True
	Case "tbSpeed"
		Dim s As Double= tbSpeed.Position / 1000
		Midi.Speed = s
		lblSpeed.Caption = "Speed: x" & Format(s, "0.000")
		CheckBox_Click(chkAll)
		
	Case "tbVolume"
		Dim sVol As DWORD = tbVolume.Position + (tbVolume.Position * &H10000)
		Midi.Volume = sVol
		lblVolume.Caption = "Volume: " & Format(tbVolume.Position, "#,#")
	End Select
End Sub

Private Sub frmMidiPlayerType.TrackBar_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	mPositionUpdate = False
End Sub

Private Sub frmMidiPlayerType.TrackBar_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	Dim s As Double = tbPosition.Position / 1000
	Midi.Position = s
	CheckBox_Click(chkAll)
	mPositionUpdate = True
End Sub

Private Sub frmMidiPlayerType.NoteChannels(ByVal v As Integer = -1)
	Dim i As Integer
	For i = 0 To MidiChannelCount
		If Midi.midiThread = NULL Then
			chkChannel(i)->Enabled = False
		Else
			chkChannel(i)->Enabled = Midi.UsedChannel(i)
			If Midi.UsedChannel(i) Then
				Select Case v
				Case -2 'No changed checked
				Case -1 'Change checked by chkAll
					chkChannel(i)->Checked = chkAll.Checked
				Case Else 'Change checked by v
					If  Midi.UsedChannel(v) Then
						chkChannel(i)->Checked = IIf(i = v, True, False)
					End If
				End Select
				CheckBox_Click(*chkChannel(i))
			End If
		End If
		If chkChannel(i)->Enabled Then
			If i=ActiveChannel Then
				chkChannel(i)->BackColor = cActive
			Else
				chkChannel(i)->BackColor = IIf(chkChannel(i)->Checked, cEnabled, cDisabled)
			End If
		Else
			chkChannel(i)->Checked = False
			chkChannel(i)->Caption = Format(i, "00")
			chkChannel(i)->BackColor = cUnused
		End If
		pnlAct(i)->BackColor = chkChannel(i)->BackColor
		pnlNote(i)->BackColor = chkChannel(i)->BackColor
		pnlNote(i)->Canvas.BackColor = pnlNote(i)->BackColor
		pnlNote(i)->Canvas.DrawColor = pnlNote(i)->BackColor
		pnlNote(i)->Canvas.FillColor = pnlNote(i)->BackColor
		NoteClear(*pnlNote(i), pnlNote(i)->Canvas)
	Next
End Sub

Private Sub frmMidiPlayerType.CheckBox_Click(ByRef Sender As CheckBox)
	Select Case Sender.Name
	Case "chkReset"
	Case "chkAll"
		NoteChannels()
	Case "chkDark"
		App.DarkMode = Sender.Checked
		InvalidateRect(0, 0, True)
		If Sender.Checked Then
			cNote = &h800000
			cEnabled = &ha0a0a0
			cActive = &hffa0a0
			cDisabled = &h606060
			cUnused = &h404040
		Else
			cNote = &hff0000
			cEnabled = &hffffff
			cActive = &hffc0c0
			cDisabled = &hc0c0c0
			cUnused = &ha0a0a0
		End If
		NoteChannels()
	Case Else
		Dim i As Integer = CInt(Sender.Name)
		
		Midi.EnabledChannel(CInt(Sender.Name)) = Sender.Checked
		chkChannel(i)->BackColor = IIf(Sender.Checked, cEnabled, cDisabled)
		pnlAct(i)->BackColor = chkChannel(i)->BackColor
		pnlNote(i)->BackColor = chkChannel(i)->BackColor
		pnlNote(i)->Canvas.BackColor = pnlNote(i)->BackColor
		pnlNote(i)->Canvas.DrawColor = pnlNote(i)->BackColor
	End Select
End Sub

Private Sub frmMidiPlayerType.Panel_Click(ByRef Sender As Control)
	Select Case Sender.Name
	Case "pnlNote"
		NoteChannels(CInt(Sender.Text))
		
	Case "pnlAct"
		ActiveChannel = CInt(Sender.Text)
		NoteChannels(-2)
	End Select
End Sub

Private Sub frmMidiPlayerType.RadioButton_Click(ByRef Sender As RadioButton)
	Select Case Sender.Name
	Case "rdbLoop1"
		Midi.loopOne = True
	Case Else
		Midi.loopOne = False
	End Select
End Sub

Private Sub frmMidiPlayerType.Menu_Click(ByRef Sender As MenuItem)
	Dim i As Integer
	Select Case Sender.Name
	Case "mnuAdd"
		If OpenFileDialog1.Execute Then
			For i = 0 To OpenFileDialog1.FileNames.Count - 1
				Form_DropFile(This, OpenFileDialog1.FileNames.Item(i))
			Next
		End If
	Case "mnuDelete"
		For i = ListView1.ListItems.Count - 1 To 0 Step -1
			If ListView1.ListItems.Item(i)->Selected Then
				ListView1.ListItems.Remove(i)
			End If
		Next
	Case "mnuClear"
		ListView1.ListItems.Clear
	End Select
End Sub
