' Chinese Calendar 中国日历
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		Const _MAIN_FILE_ = __FILE__
		#ifdef __FB_WIN32__
			#cmdline "Clock.rc"
		#endif
	#endif
	#include once "mff/Form.bi"
	#include once "mff/Panel.bi"
	#include once "mff/Picture.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/CommandButton.bi"
	
	Using My.Sys.Forms
	
	Type frmCalendarType Extends Form
		Declare Static Sub _Form_Click(ByRef Sender As Control)
		Declare Sub Form_Click(ByRef Sender As Control)
		Declare Static Sub _Form_Create(ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Static Sub _Picture1_Click(ByRef Sender As Picture)
		Declare Sub Picture1_Click(ByRef Sender As Picture)
		Declare Static Sub _ComboBoxEdit1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub ComboBoxEdit1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Static Sub _CommandButton1_Click(ByRef Sender As Control)
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Constructor
		
		Dim As Panel Panel1
		Dim As ComboBoxEdit ComboBoxEdit1, ComboBoxEdit2, ComboBoxEdit3
		Dim As Picture Picture1
		Dim As CommandButton CommandButton1
	End Type
	
	Constructor frmCalendarType
		' frmCalendar
		With This
			.Name = "frmCalendar"
			.Text = "VFBE Calendar 32"
			#ifdef __USE_GTK__
				This.Icon.LoadFromFile(ExePath & ".\calendar.ico")
			#else
				This.Icon.LoadFromResourceID(2)
			#endif
			#ifdef __FB_64BIT__
				.Caption = "VFBE Calendar 64"
			#else
				.Caption = "VFBE Calendar 32"
			#endif
			.Designer = @This
			.OnClick = @_Form_Click
			.OnCreate = @_Form_Create
			.Location = Type<My.Sys.Drawing.Point>(0, 0)
			.StartPosition = FormStartPosition.CenterScreen
			.SetBounds 0, 0, 390, 320
		End With
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = "Panel1"
			.TabIndex = 0
			.Align = DockStyle.alTop
			.Location = Type<My.Sys.Drawing.Point>(0, 0)
			.Size = Type<My.Sys.Drawing.Size>(334, 30)
			.BackColor = 12632256
			.SetBounds 0, 0, 374, 40
			.Designer = @This
			.Parent = @This
		End With
		' ComboBoxEdit1
		With ComboBoxEdit1
			.Name = "ComboBoxEdit1"
			.Text = "ComboBoxEdit1"
			.TabIndex = 2
			.SetBounds 10, 10, 80, 21
			.Designer = @This
			.OnSelected = @_ComboBoxEdit1_Selected
			.Parent = @Panel1
		End With
		' ComboBoxEdit2
		With ComboBoxEdit2
			.Name = "ComboBoxEdit2"
			.Text = "ComboBoxEdit2"
			.TabIndex = 3
			.Size = Type<My.Sys.Drawing.Size>(80, 21)
			.SetBounds 100, 10, 80, 21
			.Designer = @This
			.OnSelected = @_ComboBoxEdit1_Selected
			.Parent = @Panel1
		End With
		' ComboBoxEdit3
		With ComboBoxEdit3
			.Name = "ComboBoxEdit3"
			.Text = "ComboBoxEdit3"
			.TabIndex = 4
			.ControlIndex = 2
			.Location = Type<My.Sys.Drawing.Point>(190, 10)
			.Size = Type<My.Sys.Drawing.Size>(80, 21)
			.SetBounds 190, 10, 80, 21
			.Designer = @This
			.OnSelected = @_ComboBoxEdit1_Selected
			.Parent = @Panel1
		End With
		' Picture1
		With Picture1
			.Name = "Picture1"
			.Text = ""
			.TabIndex = 4
			.Align = DockStyle.alClient
			.Location = Type<My.Sys.Drawing.Point>(0, 40)
			.Size = Type<My.Sys.Drawing.Size>(334, 221)
			.Font.Name = "Arial"
			.SetBounds 65260, 40, 334, 221
			.Designer = @This
			.OnClick = @_Picture1_Click
			.Parent = @This
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "Today"
			.TabIndex = 5
			.Caption = "Today"
			.Size = Type<My.Sys.Drawing.Size>(80, 21)
			.SetBounds 280, 10, 80, 21
			.Designer = @This
			.OnClick = @_CommandButton1_Click
			.Parent = @Panel1
		End With
	End Constructor
	
	Private Sub frmCalendarType._CommandButton1_Click(ByRef Sender As Control)
		(*Cast(frmCalendarType Ptr, Sender.Designer)).CommandButton1_Click(Sender)
	End Sub
	
	Private Sub frmCalendarType._ComboBoxEdit1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		(*Cast(frmCalendarType Ptr, Sender.Designer)).ComboBoxEdit1_Selected(Sender, ItemIndex)
	End Sub
	
	Private Sub frmCalendarType._Picture1_Click(ByRef Sender As Picture)
		(*Cast(frmCalendarType Ptr, Sender.Designer)).Picture1_Click(Sender)
	End Sub
	
	Private Sub frmCalendarType._Form_Create(ByRef Sender As Control)
		(*Cast(frmCalendarType Ptr, Sender.Designer)).Form_Create(Sender)
	End Sub
	
	Private Sub frmCalendarType._Form_Click(ByRef Sender As Control)
		(*Cast(frmCalendarType Ptr, Sender.Designer)).Form_Click(Sender)
	End Sub
	
	Dim Shared frmCalendar As frmCalendarType
	
	#if _MAIN_FILE_ = __FILE__
		frmCalendar.MainForm = True
		frmCalendar.Show
		App.Run
	#endif
'#End Region

Private Sub DrawCalendar(pic As Picture, datetime As Double)
	Dim i As Integer
	Dim c As Integer
	Dim ms As Integer
	Dim nd As Integer
	Dim td As Integer = Day(datetime)
	Dim ws As Integer
	Dim a As Calendar
	
	ms = DateSerial(Year(datetime), Month(datetime), 1)
	nd = DateDiff("d", ms, DateAdd("m", 1, ms))
	ws = Weekday(ms) - 2
	
	Dim x As Integer
	Dim y As Integer
	
	Dim ty As Integer = (ws + nd) \ 7 + 2
	
	Dim lRT As Rect
	GetClientRect(pic.Handle, @lRT)
	
	Dim yw As Integer = (lRT.Bottom - lRT.Top) / ty
	Dim xw As Integer = (lRT.Right - lRT.Left) / 7
	pic.Canvas.Cls
	pic.Canvas.Font.Name= "微软雅黑"
	pic.Canvas.Font.Bold = True
	pic.Canvas.Font.Size = 12
	
	Dim dt As String
	Dim cr As Integer
	For i = 0 To 6
		If i = 0 Or i = 6 Then cr = &h000080 Else cr = &h404040
		dt = a.WeekNameS(i + 1)
		pic.Canvas.TextOut(i * xw + (xw - pic.Canvas.TextWidth(dt)) / 2, (yw - pic.Canvas.TextHeight(dt)) / 2, dt, cr)
	Next
	For i = 1 To nd
		c = ws + i
		x = (c Mod 7)
		y = c \ 7+2
		If i = td Then
			pic.Canvas.Pen.Color = &h8080ff
			pic.Canvas.Line x * xw, (y - 1) * yw, x * xw + xw, y * yw , &h8080ff , "F"
		End If
		dt = Format(i)
		pic.Canvas.Font.Name= "Arial"
		pic.Canvas.Font.Size = 12
		pic.Canvas.Font.Bold = True
		If x = 0 Or x = 6 Then cr = &h000080 Else cr = &h0
		pic.Canvas.TextOut(x * xw + (xw - pic.Canvas.TextWidth(dt)) / 2, y * yw - yw / 2 - pic.Canvas.TextHeight(dt), dt, cr)
		a.sInitDate(Year(datetime), Month(datetime), i)
		dt = a.lHoliday
		If dt = "" Then dt = a.lSolarTerm
		If dt = "" Then dt = a.CDayStr(a.lDay)
		If dt = "初一" Then dt = a.MonName(a.lMonth) & "月"
		pic.Canvas.Font.Name= "微软雅黑"
		pic.Canvas.Font.Size = 8
		pic.Canvas.Font.Bold = False
		If x = 0 Or x = 6 Then cr = &h404080 Else cr = &h404040
		pic.Canvas.TextOut(x * xw + (xw - pic.Canvas.TextWidth(dt)) / 2, y * yw - yw / 2, dt, cr)
	Next
End Sub

Private Sub frmCalendarType.Form_Click(ByRef Sender As Control)
	Dim y As Integer = Cast(Integer, ComboBoxEdit1.ItemData(ComboBoxEdit1.ItemIndex))
	Dim m As Integer = Cast(Integer, ComboBoxEdit2.ItemData(ComboBoxEdit2.ItemIndex))
	Dim d As Integer = Cast(Integer, ComboBoxEdit3.ItemData(ComboBoxEdit3.ItemIndex))
	Dim dt As Double = DateSerial(y, m, d)
	DrawCalendar Picture1, dt
	Caption = "VFBE Calendar - " & Format(dt, "yyyy/mm/dd")
End Sub

Private Sub frmCalendarType.Form_Create(ByRef Sender As Control)
	Dim i As Integer
	Dim j As Integer
	Dim k As Integer
	Dim l As Integer
	
	ComboBoxEdit1.Clear
	ComboBoxEdit2.Clear
	ComboBoxEdit3.Clear
	
	j = Year(Now)
	For i = 2020 To 2049
		ComboBoxEdit1.AddItem "" & i
		l = ComboBoxEdit1.ItemCount - 1
		ComboBoxEdit1.ItemData(l) = Cast(Any Ptr, i)
		If i = j Then k = l
	Next
	ComboBoxEdit1.ItemIndex = k
	
	k = Month(Now) - 1
	For i = 1 To 12
		ComboBoxEdit2.AddItem "" & i
		l = ComboBoxEdit2.ItemCount - 1
		ComboBoxEdit2.ItemData(l) = Cast(Any Ptr, i)
	Next
	ComboBoxEdit2.ItemIndex = k 
	
	k = Day(Now) - 1
	For i = 1 To 31
		ComboBoxEdit3.AddItem "" & i
		l = ComboBoxEdit3.ItemCount - 1
		ComboBoxEdit3.ItemData(l) = Cast(Any Ptr, i)
	Next
	ComboBoxEdit3.ItemIndex = k
End Sub

Private Sub frmCalendarType.Picture1_Click(ByRef Sender As Picture)
	Form_Click Sender
End Sub

Private Sub frmCalendarType.ComboBoxEdit1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	Form_Click Sender
End Sub

Private Sub frmCalendarType.CommandButton1_Click(ByRef Sender As Control)
	Form_Create Sender
	Form_Click Sender
End Sub

