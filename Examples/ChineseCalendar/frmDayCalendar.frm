' Chinese Calendar 中国日历
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/Panel.bi"
	
	Using My.Sys.Forms
	
	Type frmDayCalendarType Extends Form
		DDCalendar As DayCalendar
		DCDate As Double
		
		Declare Sub Panel1_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Constructor
		
		Dim As Panel Panel1
	End Type
	
	Constructor frmDayCalendarType
		' frmDayCalendar
		With This
			.Name = "frmDayCalendar"
			#ifdef __USE_GTK__
				This.Icon.LoadFromFile(ExePath & ".\day.ico")
			#else
				This.Icon.LoadFromResourceID(2)
			#endif
			#ifdef __FB_64BIT__
				.Caption = "VFBE DayCalendar64"
			#else
				.Caption = "VFBE DayCalendar32"
			#endif
			.Designer = @This
			.Size = Type<My.Sys.Drawing.Size>(330, 250)
			.Opacity = 250
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.SetBounds 0, 0, 330, 250
		End With
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = "Panel1"
			.TabIndex = 0
			.Align = DockStyle.alClient
			.Location = Type<My.Sys.Drawing.Point>(0, 0)
			.Size = Type<My.Sys.Drawing.Size>(334, 261)
			.SetBounds 0, 0, 304, 211
			.Designer = @This
			.OnPaint = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas), @Panel1_Paint)
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frmDayCalendar As frmDayCalendarType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmDayCalendar.MainForm = True
		frmDayCalendar.Show
		App.Run
	#endif
'#End Region

Private Sub frmDayCalendarType.Panel1_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	If DCDate= 0 Then DCDate= Now
	DDCalendar.DrawDayCalendar Canvas, DCDate
	#ifdef __FB_64BIT__
		Caption = "VFBE DayCalendar64 " & Format(DCDate, "yyyy/mm/dd")
	#else
		Caption = "VFBE DayCalendar32 " & Format(DCDate, "yyyy/mm/dd")
	#endif
End Sub

Private Sub frmDayCalendarType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	frmClock.mnuDayCalendar.Checked = False 
End Sub
