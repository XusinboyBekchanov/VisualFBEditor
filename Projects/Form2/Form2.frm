#ifdef __FB_WIN32__
	#cmdline "Form1.rc"
#endif

'' Function to a random number in the range [first, last), or {first <= x < last}.
Function rnd_range (first As Double, last As Double) As Double
	Function = Rnd * (last - first) + first
End Function


Const L = 8

'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/Chart.bi"
	#include once "mff/Grid.bi"
	
	Using My.Sys.Forms
	
	Type Form1Type Extends Form
		Declare Static Sub chartPDF0_Create_(ByRef Sender As Control)
		Declare Sub chartPDF0_Create(ByRef Sender As Control)
		Declare Constructor
		
		Dim As Chart chartPDF0
		Dim As Grid gridStep
	End Type
	
	Constructor Form1Type
		' Form1
		With This
			.Name = "Form1"
			.Text = "Form1"
			.BorderStyle = FormBorderStyle.FixedToolWindow
			.Align = DockStyle.alNone
			.SetBounds 0, 0, 1060, 500
		End With
		' chartPDF0
		With chartPDF0
			.Name = "chartPDF0"
			.Text = "Chart1"
			.ChartStyle = ChartStyles.CS_GroupedColumn
			.LegendVisible = True
			.LegendAlign = LegendAligns.LA_LEFT
			.SeparatorLineWidth = 7
			.BorderStyle = BorderStyles.bsNone
			.Align = DockStyle.alNone
			.DonutWidth = 52
			.ExtraMargins.Right = 0
			.ExtraMargins.Top = 0
			.ExtraMargins.Bottom = 0
			.SetBounds 10, 260, 514, 201
			.Designer = @This
			.OnCreate = @chartPDF0_Create_
			.Parent = @This
		End With
		' gridStep
		With gridStep
			.Name = "gridStep"
			.Text = "Grid1"
			.TabIndex = 0
			.SetBounds 10, 10, 650, 240
			.Parent = @This
		End With
	End Constructor
	
	Private Sub Form1Type.chartPDF0_Create_(ByRef Sender As Control)
		*Cast(Form1Type Ptr, Sender.Designer).chartPDF0_Create(Sender)
	End Sub
'#End Region


Private Sub Form1Type.chartPDF0_Create(ByRef Sender As Control)
	Dim StringValue As WStringList Ptr
	Dim Value As DoubleList Ptr
	Dim i As Integer
	
	StringValue = New WStringList
	
	For i = 0  To L - 1
		StringValue->Add Str(i)
	Next
	
	chartPDF0.AddAxisItems StringValue
	
	Value = New DoubleList
	For i = 0 To l - 1
		With *Value
			.Add Rnd_range(0, 101)
		End With
	Next
	
	chartPDF0.AddSerie "hello", clRed, Value
End Sub

Dim Shared Form1 As Form1Type

#ifndef _NOT_AUTORUN_FORMS_
	#define _NOT_AUTORUN_FORMS_
	
	Form1.Show
	
	App.Run
#endif
