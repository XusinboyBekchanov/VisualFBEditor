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
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Picture.bi"
	
	Using My.Sys.Forms
	
	Type frmMonthCalendarType Extends Form
		DMCalendar As MonthCalendar
		
		Declare Static Sub _Form_Create(ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Static Sub _ComboBoxEdit1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub ComboBoxEdit1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Static Sub _CommandButton1_Click(ByRef Sender As Control)
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Static Sub _Panel2_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub Panel2_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Static Sub _Panel2_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub Panel2_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Constructor
		
		Dim As Panel Panel1, Panel2
		Dim As ComboBoxEdit ComboBoxEdit1, ComboBoxEdit2, ComboBoxEdit3
		Dim As CommandButton CommandButton1
	End Type
	
	Constructor frmMonthCalendarType
		' frmMonthCalendar
		With This
			.Name = "frmMonthCalendar"
			#ifdef __USE_GTK__
				This.Icon.LoadFromFile(ExePath & ".\calendar.ico")
			#else
				This.Icon.LoadFromResourceID(2)
			#endif
			#ifdef __FB_64BIT__
				.Caption = "VFBE MonthCalendar 64"
			#else
				.Caption = "VFBE MonthCalendar 32"
			#endif
			.Designer = @This
			.OnCreate = @_Form_Create
			.Location = Type<My.Sys.Drawing.Point>(0, 0)
			.StartPosition = FormStartPosition.DefaultLocation
			.Size = Type<My.Sys.Drawing.Size>(330, 250)
			.SetBounds 0, 0, 330, 250
		End With
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = "Panel1"
			.TabIndex = 0
			.Align = DockStyle.alTop
			.Location = Type<My.Sys.Drawing.Point>(0, 0)
			.Size = Type<My.Sys.Drawing.Size>(314, 23)
			.BackColor = 12632256
			.BorderStyle = BorderStyles.bsNone
			.SetBounds 0, 0, 314, 23
			.Designer = @This
			.Parent = @This
		End With
		' ComboBoxEdit1
		With ComboBoxEdit1
			.Name = "ComboBoxEdit1"
			.Text = "ComboBoxEdit1"
			.TabIndex = 1
			.Size = Type<My.Sys.Drawing.Size>(60, 21)
			.SetBounds 10, 1, 60, 21
			.Designer = @This
			.OnSelected = @_ComboBoxEdit1_Selected
			.Parent = @Panel1
		End With
		' ComboBoxEdit2
		With ComboBoxEdit2
			.Name = "ComboBoxEdit2"
			.Text = "ComboBoxEdit2"
			.TabIndex = 2
			.Size = Type<My.Sys.Drawing.Size>(60, 21)
			.SetBounds 80, 1, 60, 21
			.Designer = @This
			.OnSelected = @_ComboBoxEdit1_Selected
			.Parent = @Panel1
		End With
		' ComboBoxEdit3
		With ComboBoxEdit3
			.Name = "ComboBoxEdit3"
			.Text = "ComboBoxEdit3"
			.TabIndex = 3
			.ControlIndex = 2
			.Location = Type<My.Sys.Drawing.Point>(190, 10)
			.Size = Type<My.Sys.Drawing.Size>(60, 21)
			.SetBounds 150, 1, 60, 21
			.Designer = @This
			.OnSelected = @_ComboBoxEdit1_Selected
			.Parent = @Panel1
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "Today"
			.TabIndex = 4
			.Caption = "Today"
			.Size = Type<My.Sys.Drawing.Size>(60, 21)
			.Location = Type<My.Sys.Drawing.Point>(235, 5)
			.Anchor.Right = AnchorStyle.asAnchor
			.SetBounds 245, 1, 60, 21
			.Designer = @This
			.OnClick = @_CommandButton1_Click
			.Parent = @Panel1
		End With
		' Panel2
		With Panel2
			.Name = "Panel2"
			.Text = ""
			.TabIndex = 5
			.Align = DockStyle.alClient
			.Location = Type<My.Sys.Drawing.Point>(0, 40)
			.Size = Type<My.Sys.Drawing.Size>(334, 221)
			.Font.Name = "Arial"
			.Visible = True
			.SetBounds 0, 30, 314, 231
			.Designer = @This
			.OnPaint = @_Panel2_Paint
			.OnMouseUp = @_Panel2_MouseUp
			.Parent = @This
		End With
	End Constructor
	
	Private Sub frmMonthCalendarType._Panel2_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		(*Cast(frmMonthCalendarType Ptr, Sender.Designer)).Panel2_MouseUp(Sender, MouseButton, x, y, Shift)
	End Sub
	
	Private Sub frmMonthCalendarType._Panel2_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		(*Cast(frmMonthCalendarType Ptr, Sender.Designer)).Panel2_Paint(Sender, Canvas)
	End Sub
	
	Private Sub frmMonthCalendarType._CommandButton1_Click(ByRef Sender As Control)
		(*Cast(frmMonthCalendarType Ptr, Sender.Designer)).CommandButton1_Click(Sender)
	End Sub
	
	Private Sub frmMonthCalendarType._ComboBoxEdit1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		(*Cast(frmMonthCalendarType Ptr, Sender.Designer)).ComboBoxEdit1_Selected(Sender, ItemIndex)
	End Sub
	
	Private Sub frmMonthCalendarType._Form_Create(ByRef Sender As Control)
		(*Cast(frmMonthCalendarType Ptr, Sender.Designer)).Form_Create(Sender)
	End Sub
	
	Dim Shared frmMonthCalendar As frmMonthCalendarType
	
	#if _MAIN_FILE_ = __FILE__
		frmMonthCalendar.MainForm = True
		frmMonthCalendar.Show
		App.Run
	#endif
'#End Region

Private Sub frmMonthCalendarType.Form_Create(ByRef Sender As Control)
	Dim i As Integer
	For i = 2020 To 2049
		ComboBoxEdit1.AddItem "" & i
	Next
	
	For i = 1 To 12
		ComboBoxEdit2.AddItem "" & i
	Next
	
	For i = 1 To 31
		ComboBoxEdit3.AddItem "" & i
	Next
	CommandButton1_Click Sender
End Sub

Private Sub frmMonthCalendarType.ComboBoxEdit1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	Panel2_Paint Sender, Panel2.Canvas
End Sub

Private Sub frmMonthCalendarType.CommandButton1_Click(ByRef Sender As Control)
	ComboBoxEdit1.ItemIndex = Year(Now) - 2020
	ComboBoxEdit2.ItemIndex = Month(Now) - 1
	ComboBoxEdit3.ItemIndex = Day(Now) - 1
	
	Panel2_Paint Sender, Panel2.Canvas
End Sub

Private Sub frmMonthCalendarType.Panel2_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	Dim DateTime As Double = DateSerial(ComboBoxEdit1.ItemIndex + 2020, ComboBoxEdit2.ItemIndex + 1, ComboBoxEdit3.ItemIndex + 1)
	#ifdef __FB_64BIT__
		Caption = "VFBE MonthCalendar64 - " & Format(DateTime, "yyyy/mm/dd")
	#else
		Caption = "VFBE MonthCalendar32 - " & Format(DateTime, "yyyy/mm/dd")
	#endif
	Canvas.CreateDoubleBuffer
	DMCalendar.DrawMonthCalendar(Canvas, DateTime)
	Canvas.TransferDoubleBuffer
	Canvas.DeleteDoubleBuffer
	frmDayCalendar.DCDate= DateTime
	frmDayCalendar.Panel1_Paint Sender, frmDayCalendar.Panel1.Canvas
End Sub

Private Sub frmMonthCalendarType.Panel2_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	Dim DateTime As Double = DMCalendar.XY2Date(x, y)
	ComboBoxEdit1.ItemIndex = Year(DateTime) - 2020
	ComboBoxEdit2.ItemIndex = Month(DateTime) - 1
	ComboBoxEdit3.ItemIndex = Day(DateTime) - 1
	Panel2_Paint Sender, Panel2.Canvas
End Sub

