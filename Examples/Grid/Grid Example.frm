'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
		#ifdef __FB_64BIT__
			#cmdline "-gen gas64"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/Grid.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Label.bi"
	#include once "mff/CheckBox.bi"
	Using My.Sys.Forms
	/'test comment '/
	Type Form1Type Extends Form
		Declare Sub cmdRowInsert_Click(ByRef Sender As Control)
		Declare Sub cmdRowDele_Click(ByRef Sender As Control)
		Declare Sub cmdColInsert_Click(ByRef Sender As Control)
		Declare Sub cmdColDele_Click(ByRef Sender As Control)
		Declare Sub cmdColInsertAf_Click(ByRef Sender As Control)
		Declare Sub cmdRowInsertAfter_Click(ByRef Sender As Control)
		Declare Sub cmdBigData_Click(ByRef Sender As Control)
		#ifdef __USE_WINAPI__
			Declare Sub Grid1_GetDispInfo(ByRef Sender As Grid, ByRef NewText As WString, ByVal RowIndex As Integer, ByVal ColumnIndex As Integer, iMask As UINT)
		#endif
		Declare Sub Grid1_CacheHint(ByRef Sender As Grid, ByVal iFrom As Integer, ByVal iTo As Integer)
		Declare Sub Grid1_CellEdited(ByRef Sender As Grid, ByVal RowIndex As Integer, ByVal ColumnIndex As Integer, ByRef NewText As WString)
		Declare Sub cmdSaveToFile_Click(ByRef Sender As Control)
		Declare Sub cmdLoadFromFile_Click(ByRef Sender As Control)
		Declare Sub chkOwnerData_Click(ByRef Sender As CheckBox)
		Declare Sub chkDarkMode_Click(ByRef Sender As CheckBox)
		Declare Sub Grid1_ColumnClick(ByRef Sender As Grid, ByVal ColIndex As Integer)
		Declare Constructor
		
		Dim As Grid Grid1
		Dim As CommandButton cmdRowInsert, cmdColInsert, cmdRowDele, cmdColDele, cmdColInsertAfter, cmdRowInsertAfter, cmdBigData, cmdSaveToFile, cmdLoadFromFile
		Dim As Label Label1
		
		Dim As CheckBox chkOwnerData, chkDarkMode
	End Type
	
	Constructor Form1Type
		' Form1
		With This
			.Name = "Form1"
			.Text = "Form1"
			.Designer = @This
			.SetBounds 0, 0, 640, 300
		End With
		' Grid1
		With Grid1
			.Name = "Grid1"
			.Text = "Grid1"
			'.TabIndex = 0
			.Hint = "Double Click or press space start edit, Enter Confirm input!"
			'.BackColor = clBlue
			'.ForeColor = clWhite
			'.BackColor = IIf(g_darkModeEnabled, darkBkColor, GetSysColor(COLOR_WINDOW))
			'.ForeColor = IIf(g_darkModeEnabled, darkTextColor, GetSysColor(COLOR_WINDOWTEXT))
			.Anchor.Right = AnchorStyle.asAnchor
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Top = AnchorStyle.asAnchor
			.Anchor.Bottom = AnchorStyle.asAnchor
			.SetBounds 10, 52, 610, 210
			.Columns.Add "NO.", , 30 , cfRight ', , clPurple, clBlue
			.Columns.Add "Column 1", , 100, cfRight ', , clRed, clBlue
			.Columns.Add "Column 2", , 100, cfRight, True, clYellow, clRed
			.Columns.Add "Column 3", , 100, cfRight ', , clBlue, clYellow
			.Columns.Add "Column 4", , 100, cfRight ', , clGreen, clBlue
			.Columns.Add "Column 5", , 100, cfRight,  True, clPurple, clGreen
			.Columns[1].Tag = @"0"
			
			For i As Integer = 0 To 3  '返回的代码: 3221225477 - 堆栈溢出 就是行不够
				.Rows.Add
				.Rows.Item(i)->State = 1
			Next
			
			'Control's Name
			Grid1[0][1].Text = "Row 1 Column 1"
			Grid1[1][1].Text = "Row 2 Column 1"
			Grid1[2][1].Text = "Row 3 Column 1"
			Grid1[3][1].Text = "Row 4 Column 1"
			Grid1[0][1].Editable = True
			
			'Like Array
			.Rows[0][2].Text = "Row1ColC2 AllowEdit"
			.Rows[1][2].Text = "Row2ColC2 AllowEdit"
			.Rows[2][2].Text = "Row3ColC2 AllowEdit"
			.Rows[3][2].Text = "Row4ColC2 AllowEdit"
			For i As Integer = 0 To 3
				.Rows[i][2].Editable = True
			Next
			'Cell Like Excel
			.Cells(0, 3)->Text = "Row 1 Column 3"
			.Cells(1, 3)->Text = "Row 2 Column 3"
			.Cells(2, 3)->Text = "Row 3 Column 3"
			.Cells(3, 3)->Text = "Row 4 Column 3"
			.Cells(2, 3)->Editable = True
			.Cells(2, 3)->BackColor = clGreen
			.Cells(2, 2)->BackColor = clGreen
			.Cells(2, 1)->BackColor = clGreen
			.Rows[0][5].Text = "Row1Col5 AllowEdit"
			.Rows[1][5].Text = "Row2Col5 AllowEdit"
			.Rows[2][5].Text = "Row3Col5 AllowEdit"
			.Rows[3][5].Text = "Row4Col5 AllowEdit"
			.Rows[3].Tag = @"3"
			.SelectedRowIndex = 0
			#ifdef __USE_WINAPI__
				.OnGetDispInfo = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Grid, ByRef NewText As WString, ByVal RowIndex As Integer, ByVal ColumnIndex As Integer, iMask As UINT), @Grid1_GetDispInfo)
			#endif
			.OnCacheHint = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Grid, ByVal iFrom As Integer, ByVal iTo As Integer), @Grid1_CacheHint)
			.OnCellEdited = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Grid, ByVal RowIndex As Integer, ByVal ColumnIndex As Integer, ByRef NewText As WString), @Grid1_CellEdited)
			.Designer = @This
			.OnColumnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Grid, ByVal ColIndex As Integer), @Grid1_ColumnClick)
			.Parent = @This
		End With
		' cmdRowInsert
		With cmdRowInsert
			.Name = "cmdRowInsert"
			.Text = "Insert Row before"
			.TabIndex = 0
			.SetBounds 10, 4, 85, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdRowInsert_Click)
			.Parent = @This
		End With
		' cmdColInsert
		With cmdColInsert
			.Name = "cmdColInsert"
			.Text = "Insert Col before"
			.TabIndex = 2
			.ControlIndex = 1
			.SetBounds 250, 4, 85, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdColInsert_Click)
			.Parent = @This
		End With
		' cmdRowDele
		With cmdRowDele
			.Name = "cmdRowDele"
			.Text = "Dele one Row"
			.TabIndex = 3
			.ControlIndex = 2
			.SetBounds 180, 4, 65, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdRowDele_Click)
			.Parent = @This
		End With
		' cmdColDele
		With cmdColDele
			.Name = "cmdColDele"
			.Text = "Dele one Col"
			.TabIndex = 4
			.ControlIndex = 2
			.SetBounds 420, 4, 65, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdColDele_Click)
			.Parent = @This
		End With
		' Label1
		With Label1
			.Name = "Label1"
			.Text = "Double Click or press space start edit, Enter Confirm input!"
			.TabIndex = 6
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.BackColor = 65535
			.SetBounds 550, 0, 70, 28
			.Designer = @This
			.Parent = @This
		End With
		' ="cmdColInsertAf
		With cmdColInsertAfter
			.Name = "cmdColInsertAfter"
			.Text = "Insert Col after"
			.TabIndex = 7
			.SetBounds 340, 4, 75, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdColInsertAf_Click)
			.Parent = @This
		End With
		' ="cmdRowInsertAfter
		With cmdRowInsertAfter
			.Name = "cmdRowInsertAfter"
			.Text = "Insert Row After"
			.TabIndex = 8
			.SetBounds 100, 4, 75, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdRowInsertAfter_Click)
			.Parent = @This
		End With
		' cmdBigData
		With cmdBigData
			.Name = "cmdBigData"
			.Text = "大数据"
			.TabIndex = 9
			.SetBounds 490, 0, 40, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdBigData_Click)
			.Parent = @This
		End With
		' cmdSaveToFile
		With cmdSaveToFile
			.Name = "cmdSaveToFile"
			.Text = "Save To File"
			.TabIndex = 10
			.SetBounds 400, 27, 80, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdSaveToFile_Click)
			.Parent = @This
		End With
		' cmdLoadFromFile
		With cmdLoadFromFile
			.Name = "cmdLoadFromFile"
			.Text = "Load From File"
			.TabIndex = 11
			.ControlIndex = 9
			.SetBounds 480, 27, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdLoadFromFile_Click)
			.Parent = @This
		End With
		' chkOwnerData
		With chkOwnerData
			.Name = "chkOwnerData"
			.Text = "OwnerData"
			.TabIndex = 12
			.Caption = "OwnerData"
			.SetBounds 10, 30, 70, 10
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox), @chkOwnerData_Click)
			.Parent = @This
		End With
		' chkDarkMode
		With chkDarkMode
			.Name = "chkDarkMode"
			.Text = "DarkMode"
			.TabIndex = 13
			.ControlIndex = 11
			.Checked = True
			.Caption = "DarkMode"
			.SetBounds 90, 30, 60, 10
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox), @chkDarkMode_Click)
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared Form1 As Form1Type
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		Form1.MainForm = True
		Form1.Show
		App.Run
	#endif
'#End Region

Private Sub Form1Type.cmdRowInsert_Click(ByRef Sender As Control)
	Dim As Integer Curr = Grid1.SelectedRowIndex
	'Print "CurrRow=" &  Curr
	Grid1.Rows.Insert(Curr, Str(Curr), , , , True)
	Grid1.Repaint
End Sub

Private Sub Form1Type.cmdRowDele_Click(ByRef Sender As Control)
	Dim As Integer Curr = Grid1.SelectedRowIndex
	'Print "CurrRow=" &  Curr
	Grid1.Rows.Remove(Curr)
	Grid1.Repaint
End Sub

Private Sub Form1Type.cmdColInsert_Click(ByRef Sender As Control)
	Dim As Integer Curr = Grid1.SelectedColumnIndex
	Grid1.Columns.Insert(Curr, "Column " & Curr, , 100, cfRight, , True)
	Grid1.Repaint
End Sub

Private Sub Form1Type.cmdColDele_Click(ByRef Sender As Control)
	Dim As Integer Curr = Grid1.SelectedColumnIndex
	'Print "CurrCol=" &  Curr
	Grid1.Columns.Remove(Curr)
End Sub

Private Sub Form1Type.cmdColInsertAf_Click(ByRef Sender As Control)
	Dim As Integer Curr = Grid1.SelectedColumnIndex
	Grid1.Columns.Insert(Curr, "Column " & Curr, , 100, cfRight, False, True, clYellow, clRed)
End Sub

Private Sub Form1Type.cmdRowInsertAfter_Click(ByRef Sender As Control)
	Dim As Integer Curr = Grid1.SelectedRowIndex
	Grid1.Rows.Insert(Curr, Str(Curr), , , , False, False)
	Grid1.Repaint
End Sub

Private Sub Form1Type.cmdBigData_Click(ByRef Sender As Control)
	Grid1.SetFocus
	Dim As Double StartShow = Timer
	Dim As WString * 255 RowStr
	Grid1.OwnerData = chkOwnerData.Checked
	
	If Grid1.OwnerData Then
		Grid1.RowsCount = 20000
	Else
		' This is take too long. 花费太多时间赋值。建议使用CacheHint赋值
		For iRow As Long = 0 To 20000
			RowStr = "行" + Str(iRow + 1) + "列1" 
			Randomize
			For iCol As Integer = 2 To Grid1.Columns.Count - 1
				RowStr += Chr(9) + "行" + Str(Fix(Rnd * 10000000)) + "列" + Str(iCol)
				'Grid1.Rows[iRow][iCol].Text = "行" + Str(iRow + 1) + "列" + Str(iCol)
			Next
			'Add the Data
			Grid1.Rows.Add RowStr, , , , , True
			If iRow Mod 15 = 0 Then App.DoEvents  'if rows.count=666666  :254.144s   1 Million: 364.829s    5 Million:512.616s
		Next
	End If
	Grid1.SelectedRowIndex = 0 'Grid1.Rows.Count - 1
	Debug.Print " Elasped time: " & Str(Int((Timer - StartShow) * 1000 + 0.5) / 1000) & "s. with Data " & (Grid1.Rows.Count - 1) * (Grid1.Columns.Count - 1)
	'MsgBox " Elasped time: " & Str(Int((Timer - StartShow) * 1000 + 0.5) / 1000)  & "s. with Data " & (Grid1.Rows.Count - 1) * (Grid1.Columns.Count - 1)
End Sub

#ifdef __USE_WINAPI__
	Private Sub Form1Type.Grid1_GetDispInfo(ByRef Sender As Grid, ByRef NewText As WString, ByVal RowIndex As Integer, ByVal ColumnIndex As Integer, iMask As UINT)
		'This sub send the data to control and overwrite the data in grid 将覆盖表格中原来的数据
		Select Case iMask
		Case LVIF_TEXT
			'NewText = IIf(ColumnIndex = 0, WStr(RowIndex), "行" + Str(RowIndex) + "列" + Str(ColumnIndex))
			'Print "NewText GetDispInfo " = NewText
		Case LVIF_IMAGE
			NewText = "1"
		Case LVIF_INDENT
			NewText = WStr(ColumnIndex)
		Case LVIF_PARAM
		Case LVIF_STATE
		End Select
		
	End Sub
#endif

Private Sub Form1Type.Grid1_CacheHint(ByRef Sender As Grid, ByVal iFrom As Integer, ByVal iTo As Integer)
	'upload the data to grid here also
	If Not Grid1.OwnerData Then Return
	For iRow As Integer = iFrom To iTo
		If Grid1.Rows.Item(iRow)->State = 1 Then Continue For
		'Debug.Print " iFrom=" & iFrom  & " iTo=" & iTo & " State=" & Grid1.Rows.Item(iRow)->State
		For iCol As Integer = 1 To Grid1.Columns.Count - 1
			Grid1.Rows[iRow][iCol].Text = "行" + Str(iRow + 1) + "列" + Str(iCol)
		Next
		Grid1.Rows.Item(iRow)->State = 1
	Next
End Sub

Private Sub Form1Type.Grid1_CellEdited(ByRef Sender As Grid, ByVal RowIndex As Integer, ByVal ColumnIndex As Integer, ByRef NewText As WString)
	Debug.Print " RowIndex=" & RowIndex  & " Col=" & ColumnIndex & " Text=" & NewText
End Sub

Private Sub Form1Type.cmdSaveToFile_Click(ByRef Sender As Control)
	Grid1.SaveToFile(ExePath & "\gridTest.csv")
End Sub

Private Sub Form1Type.cmdLoadFromFile_Click(ByRef Sender As Control)
	Grid1.LoadFromFile(ExePath & "\gridTest.csv")
End Sub

Private Sub Form1Type.chkOwnerData_Click(ByRef Sender As CheckBox)
	Grid1.OwnerData = chkOwnerData.Checked
	If Grid1.OwnerData Then
		For iRow As Long = 0 To Grid1.Rows.Count - 1
			Grid1.Rows.Item(iRow)->State = 0
		Next
	End If
End Sub

Private Sub Form1Type.chkDarkMode_Click(ByRef Sender As CheckBox)
	SetDarkMode(chkDarkMode.Checked, chkDarkMode.Checked)
End Sub

Dim Shared SortedColumn As Integer = -1
Dim Shared SortedDirection As ListSortDirection

Private Sub Form1Type.Grid1_ColumnClick(ByRef Sender As Grid, ByVal ColIndex As Integer)
	If SortedColumn = ColIndex Then
		If SortedDirection = ListSortDirection.sdAscending Then
			SortedDirection = ListSortDirection.sdDescending
		Else
			SortedDirection = ListSortDirection.sdAscending
		End If
	Else
		SortedDirection = ListSortDirection.sdAscending
	End If
	SortedColumn = ColIndex
	Grid1.Rows.Sort SortedColumn, SortedDirection
End Sub
