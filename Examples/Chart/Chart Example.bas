#ifdef __FB_WIN32__
	'#Compile -exx "Form1.rc"
#else
	'#Compile -exx
#endif
'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/Chart.bi"
	
	Using My.Sys.Forms
	
	Type Form1 Extends Form
		Declare Static Sub Chart1_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub Chart1_Create(ByRef Sender As Control)
		Declare Constructor
		
		Dim As Chart Chart1, Chart2, Chart3, Chart4, Chart5, Chart6
	End Type
	
	Constructor Form1
		' Form1
		With This
			.Name = "Form1"
			.Text = "Form1"
			.SetBounds 0, 0, 660, 390
		End With
		' Chart1
		With Chart1
			.Name = "Chart1"
			.Text = "Chart1"
			.Title = "Chart1"
			.SetBounds 10, 10, 204, 161
			.Designer = @This
			.OnCreate = @Chart1_Create_
			.Align = DockStyle.alNone
			.ChartOrientation = ChartOrientations.CO_Vertical
			.ChartStyle = ChartStyles.CS_Area
			.Border = False
			.FillOpacity = 0
			.LabelsFormats = "{V}"
			.Anchor.Top = AnchorStyle.asAnchorProportional
			.Anchor.Right = AnchorStyle.asAnchorProportional
			.Anchor.Left = AnchorStyle.asAnchorProportional
			.Anchor.Bottom = AnchorStyle.asAnchorProportional
			.Parent = @This
		End With
		' Chart2
		With Chart2
			.Name = "Chart2"
			.Text = "Chart1"
			.SetBounds 220, 10, 204, 161
			.Title = "Chart2"
			.Anchor.Top = AnchorStyle.asAnchorProportional
			.Anchor.Right = AnchorStyle.asAnchorProportional
			.Anchor.Left = AnchorStyle.asAnchorProportional
			.Anchor.Bottom = AnchorStyle.asAnchorProportional
			.ChartStyle = ChartStyles.CS_GroupedColumn
			.Border = False
			.FillOpacity = 50
			.LabelsFormats = "{V}"
			.Parent = @This
		End With
		' Chart3
		With Chart3
			.Name = "Chart3"
			.Text = "Chart1"
			.SetBounds 430, 10, 204, 161
			.Title = "Chart3"
			.Anchor.Top = AnchorStyle.asAnchorProportional
			.Anchor.Right = AnchorStyle.asAnchorProportional
			.Anchor.Left = AnchorStyle.asAnchorProportional
			.Anchor.Bottom = AnchorStyle.asAnchorProportional
			.Border = False
			.Parent = @This
		End With
		' Chart4
		With Chart4
			.Name = "Chart4"
			.Text = "Chart1"
			.SetBounds 10, 180, 204, 161
			.Title = "Chart4"
			.Anchor.Top = AnchorStyle.asAnchorProportional
			.Anchor.Right = AnchorStyle.asAnchorProportional
			.Anchor.Left = AnchorStyle.asAnchorProportional
			.Anchor.Bottom = AnchorStyle.asAnchorProportional
			.ChartStyle = ChartStyles.CS_StackedBars
			.Border = False
			.FillOpacity = 50
			.LabelsFormats = "{V}"
			.ChartOrientation = ChartOrientations.CO_Horizontal
			.Parent = @This
		End With
		' Chart5
		With Chart5
			.Name = "Chart5"
			.Text = "Chart1"
			.SetBounds 220, 180, 204, 161
			.Title = "Chart5"
			.Anchor.Top = AnchorStyle.asAnchorProportional
			.Anchor.Right = AnchorStyle.asAnchorProportional
			.Anchor.Left = AnchorStyle.asAnchorProportional
			.Anchor.Bottom = AnchorStyle.asAnchorProportional
			.ChartStyle = ChartStyles.CS_Area
			.Border = False
			.FillOpacity = 50
			.LabelsFormats = "{V}"
			.LegendAlign = LegendAligns.LA_TOP
			.LinesCurve = True
			.Parent = @This
		End With
		' Chart6
		With Chart6
			.Name = "Chart6"
			.Text = "Chart1"
			.SetBounds 430, 180, 204, 161
			.Title = "Chart6"
			.Anchor.Top = AnchorStyle.asAnchorProportional
			.Anchor.Right = AnchorStyle.asAnchorProportional
			.Anchor.Left = AnchorStyle.asAnchorProportional
			.Anchor.Bottom = AnchorStyle.asAnchorProportional
			.ChartStyle = ChartStyles.CS_Donut
			.LabelsPosition = LabelsPositions.LP_TwoColumns
			.Border = False
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared fForm1 As Form1
	
	#ifndef _NOT_AUTORUN_FORMS_
		fForm1.Show
		
		App.Run
	#endif
'#End Region

Private Sub Form1.Chart1_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(Form1 Ptr, Sender.Designer)).Chart1_Create(Sender)
End Sub
Private Sub Form1.Chart1_Create(ByRef Sender As Control)
	'Chart1.LabelsPosition = LabelsPositions.LP_Outside
	
	Dim StringValue As WStringList Ptr
	Dim Value As DoubleList Ptr
	
	StringValue = New WStringList
	
	StringValue->Add "2018"
	StringValue->Add "2019"
	StringValue->Add "2020"
	Chart1.AddAxisItems StringValue
	
	Value = New DoubleList
	With *Value
		.Add 10
		.Add 15
		.Add 5
	End With
	Chart1.AddSerie "Juan", clRed, Value
	Value = New DoubleList
	With *Value
		.Add 8
		.Add 4
		.Add 12
	End With
	Chart1.AddSerie "Pedro", clBlue, Value
	
	StringValue = New WStringList
	
	StringValue->Add "2018"
	StringValue->Add "2019"
	StringValue->Add "2020"
	Chart2.AddAxisItems StringValue
	
	Value = New DoubleList
	With *Value
		.Add 10
		.Add 15
		.Add 5
	End With
	Chart2.AddSerie "Juan", clRed, Value
	Value = New DoubleList
	With *Value
		.Add 8
		.Add 4
		.Add 12
	End With
	Chart2.AddSerie "Pedro", clBlue, Value
	
	Chart3.AddItem "Juan", 70, clRed
	Chart3.AddItem "Adan", 20, clGreen
	Chart3.AddItem "Pedro", 10, clBlue
	
	StringValue = New WStringList
	
	StringValue->Add "2018"
	StringValue->Add "2019"
	StringValue->Add "2020"
	Chart4.AddAxisItems StringValue
	
	Value = New DoubleList
	With *Value
		.Add 10
		.Add 15
		.Add 5
	End With
	Chart4.AddSerie "Juan", clRed, Value
	Value = New DoubleList
	With *Value
		.Add 8
		.Add 4
		.Add 12
	End With
	Chart4.AddSerie "Pedro", clBlue, Value
	
	StringValue = New WStringList
	
	StringValue->Add "2018"
	StringValue->Add "2019"
	StringValue->Add "2020"
	Chart5.AddAxisItems StringValue
	
	Value = New DoubleList
	With *Value
		.Add 10
		.Add 15
		.Add 5
	End With
	Chart5.AddSerie "Juan", clRed, Value
	Value = New DoubleList
	With *Value
		.Add 8
		.Add 4
		.Add 12
	End With
	Chart5.AddSerie "Pedro", clBlue, Value
	
	Chart6.AddItem "Juan", 70, clRed
	Chart6.AddItem "Adan", 20, clGreen
	Chart6.AddItem "Pedro", 10, clBlue
	
End Sub


