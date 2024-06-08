'############################################################################################
'#  frmsudoku.frm                                                                           #
'#  This file is an examples of MyFBFramework.                                              #
'#  Authors: Xusinboy Bekchanov, Liu XiaLin                                                 #
'# See also https://github.com/tropicalwzc/ice_sudoku.github.io/blob/master/sudoku_solver.c #
'############################################################################################

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
	#include once "mff/Label.bi"
	#include once "mff/LinkLabel.bi"
	#include once "mff/CommandButton.bi"
	#include once "sudoku_solver.bi"
	#include once "mff/ComboBoxEdit.bi"
	
	Using My.Sys.Forms
	Dim Shared  As Integer SudoCellFontSize = 24, SudoCellSize = 64, SudoCellTop = 20, SudoCellLeft = 120, SudoCellGaps = 2
	Dim Shared  As Integer SudoCellColorBK, SudoCellColorBKDefault, SudoCellColorBKSelect, SudoCellColorFore, SudoCellColorForeSelect, SudoCellColorHover
	Dim Shared  As Integer SudoCellChildFontSize = 10, SudoCellChildSize = 20, SudoCellChildTop = 2, SudoCellChildLeft = 2
	Dim Shared  As Integer SudoCellChildColorBK, SudoCellChildColorFore, SudoCellChildColorHover
	Dim Shared  As Integer SudoCellCurr, SudoCellChildCurr, SudoCellLast, SudoCellChildLast, mTabIndex = 81
	Dim Shared As Point MsCell, MsCellChild                  ' 记录鼠标按下时的坐标
	Dim Shared  As Boolean GameOver, bCustomize, bDrawing
	Dim Shared As My.Sys.Drawing.BitmapType ScreenShotBitm
	Dim Shared  As Integer SudoKu(0 To 9, 0 To 8, 0 To 8), SudoAns(0 To 9, 0 To 8, 0 To 8), SudoIn(0 To 8, 0 To 8)
	
	Type Form1Type Extends Form
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Sub cmdFromClipBoard_Click(ByRef Sender As Control)
		Declare Sub pnlSudoCell_MouseLeave(ByRef Sender As Control)
		Declare Sub pnlSudoCell_MouseHover(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub pnlSudoCell_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub pnlSudoCell_KeyPress(ByRef Sender As Control, Key As Integer)
		Declare Sub pnlSudoCell_Click(ByRef Sender As Control)
		
		Declare Sub lblSudoCellChild_MouseLeave(ByRef Sender As Control)
		Declare Sub lblSudoCellChild_GotFocus(ByRef Sender As Control)
		Declare Sub lblSudoCellChild_MouseHover(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub lblSudoCellChild_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub lblSudoCellChild_KeyPress(ByRef Sender As Control, Key As Integer)
		
		Declare Sub cmdSolveSudo_Click(ByRef Sender As Control)
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		
		Declare Sub cmdCustomize_Click(ByRef Sender As Control)
		Declare Sub cmdRandomized_Click(ByRef Sender As Control)
		Declare Sub Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub pnlBack_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub cmdDrawing_Click(ByRef Sender As Control)
		Declare Constructor
		Declare Sub UpdateShow(ByRef CurrentValue As String = "")
		
		Dim As Panel pnlSudoCell(80), pnlBack
		'Dim As Picture pnlBack
		' 9 * (i + j * 9) + 8
		Dim As Label lblSudoCellChild(728)
		Dim As LinkLabel lblInfo
		Dim As CommandButton cmdFromClipBoard, cmdSolveSudo, cmdCustomize, cmdRandomized, cmdDrawing
		Dim As ComboBoxEdit cboFromClipBoard
	End Type
	
	Constructor Form1Type
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/"
				.CurLanguage = My.Sys.Language
			End With
		#endif
		' Form1
		With This
			.Name = "Form1"
			.Text = "SudoKu"
			.Designer = @This
			.OnShow = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form), @Form_Show)
			.DoubleBuffered = True
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Form_Resize)
			.OnPaint = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas), @Form_Paint)
			.SetBounds 0, -206, 740, 670
		End With
		
		' pnlBack
		With pnlBack
			.Name = "pnlBack"
			.Text = "pnlBack"
			.TabIndex = 1
			.BackColor = 12615935
			.SetBounds 0, 0, 100, 20
			.Designer = @This
			.OnPaint = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas), @pnlBack_Paint)
			.Parent = @This
		End With
		
		' pnlSudoCell(0)
		For j As Integer = 0 To 8
			mTabIndex += 9
			'Debug.Print ""
			For i As Integer = 0 To 8
				With pnlSudoCell(i + j * 9)
					.Name = "pnlSudoCell(" & (i + j * 9) & ")"
					.BevelOuter = bvRaised
					.BevelInner = bvRaised
					.Canvas.Font.Size= SudoCellFontSize
					'.ForeColor = clWhite
					'.BackColor = -1
					'.BorderWidth = 1
					.BevelWidth = 1
					.DoubleBuffered = True
					.TabIndex = mTabIndex
					'.ShowCaption = IIf(SudoIn(i, j) > 0, True, False)
					'Debug.Print SudoIn(i, j),
					'.SetBounds SudoCellGapsX + SudoCellSize *i + i, SudoCellGapsY + SudoCellSize * j + j, SudoCellSize, SudoCellSize
					.OnMouseLeave = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @pnlSudoCell_MouseLeave)
					.OnMouseHover = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @pnlSudoCell_MouseHover)
					.OnMouseDown = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @pnlSudoCell_MouseDown)
					.OnKeyPress = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer), @pnlSudoCell_KeyPress)
					.Designer = @This
					.Parent = @pnlBack
				End With
				
				For k As Integer = 0 To 8
					' lblSudoCellChild(0)
					'Debug.Print  "lblSudoCellChild=" & 9 * (i + j * 9) + k
					With lblSudoCellChild(9 * (i + j * 9) + k)
						.Name = "lblSudoCellChild(" & (9 * (i + j * 9) + k) & ")"
						.Text = WStr(k + 1)
						.TabIndex = mTabIndex + k + 1
						.Font.Size = SudoCellChildFontSize
						.Alignment = AlignmentConstants.taCenter
						.ControlIndex = k
						.Visible= False
						.SetBounds SudoCellChildLeft + SudoCellChildSize * (k Mod 3) + (k Mod 3), SudoCellChildTop + SudoCellChildSize * (k \ 3) + (k \ 3), SudoCellChildSize, SudoCellChildSize
						.OnMouseLeave = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @lblSudoCellChild_MouseLeave)
						.OnGotFocus = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @lblSudoCellChild_GotFocus)
						.OnMouseHover = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @lblSudoCellChild_MouseHover)
						.OnMouseDown = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @lblSudoCellChild_MouseDown)
						.OnKeyPress = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer), @lblSudoCellChild_KeyPress)
						.Designer = @This
						.Parent = @pnlSudoCell(i + j * 9)
					End With
				Next
			Next
		Next
		
		' lblInfo
		With lblInfo
			.Name = "lblInfo"
			.Text = ML("Each Sudoku game consists of a 9x9 grid, divided into 9 3x3 subgrids, each containing 9 squares.") & !"\r" & _
			ML("At the beginning of the SudoKu game, some squares are already filled with numbers, and the player must fill in the remaining empty squares based on the given numbers.") & !"\r" & _
			ML("Each row, each column, and each subgrid must contain numbers from 1 to 9 without any repetition.") & !"\r" & _
			ML("Right-click mouse to confirm the value of the selected subgrid") & !"\r\r" & _
			"<a href=""https://github.com/XusinboyBekchanov/VisualFBEditor"">@VisualFBEditor</a>"
			.TabIndex = 2
			.Font.Size=10
			.SetBounds 10, 20, 100, 380
			.Designer = @This
			.Parent = @This
		End With
		' cmdFromClipBoard
		With cmdFromClipBoard
			.Name = "cmdFromClipBoard"
			.Text = ML("From ClipBoard")
			.TabIndex = 10
			.SetBounds 10, 580, 100, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdFromClipBoard_Click)
			.Parent = @This
		End With
		
		' cboFromClipBoard
		With cboFromClipBoard
			.Name = "cboFromClipBoard"
			.Text = ""
			.ItemIndex = 0
			.TabIndex = 3
			.Style = ComboBoxEditStyle.cbDropDown
			.SetBounds 120, 210, 590, 16
			.Designer = @This
			.Parent = @This
		End With
		' cmdSolveSudo
		With cmdSolveSudo
			.Name = "cmdSolveSudo"
			.Text = ML("Solve Sudo")
			.TabIndex = 4
			.ControlIndex = 0
			.SetBounds 10, 580, 100, 20
			.Enabled = False
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdSolveSudo_Click)
			.Parent = @This
		End With
		
		' cmdCustomize
		With cmdCustomize
			.Name = "cmdCustomize"
			.Text = ML("Customize")
			.TabIndex = 5
			.SetBounds 12, 406, 100, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdCustomize_Click)
			.Parent = @This
		End With
		' cmdRandomized
		With cmdRandomized
			.Name = "cmdRandomized"
			.Text = ML("Randomized")
			.TabIndex = 6
			.ControlIndex = 5
			.SetBounds 13, 437, 100, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdRandomized_Click)
			.Parent = @This
		End With
		' cmdDrawing
		With cmdDrawing
			.Name = "cmdDrawing"
			.Text = ML("Drawing")
			.TabIndex = 7
			.ControlIndex = 6
			.SetBounds 13, 467, 100, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdDrawing_Click)
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

Private Sub Form1Type.Form_Show(ByRef Sender As Form)
	SudoCellChildColorFore = IIf(App.DarkMode, darkTextColor, This.ForeColor)  ' can not got the value "This.BackColor" in darkmode '  clDarkCyan
	SudoCellChildColorBK = IIf(App.DarkMode, darkBkColor, This.BackColor)  ' can not got the value "This.BackColor" in darkmode '  clDarkCyan
	SudoCellChildColorHover = clGreenYellow
	
	SudoCellColorFore = clDarkOliveGreen
	SudoCellColorBK = clDarkTurquoise
	SudoCellColorHover = SudoCellChildColorHover
	SudoCellColorBKSelect = clYellowGreen
	SudoCellColorForeSelect = SudoCellChildColorFore
	SudoCellColorBKDefault = SudoCellChildColorBK
	pnlBack.Canvas.Cls
	cboFromClipBoard.LoadFromFile(ExePath & "/Sudoku.txt")
	cboFromClipBoard.ItemIndex = cboFromClipBoard.ItemCount - 1
	
End Sub

Private Sub Form1Type.cmdSolveSudo_Click(ByRef Sender As Control)
	'Randomize ' 初始化随机数生成器
	'Input "", SudoString
	Dim SudoAns(0 To 9, 0 To 8, 0 To 8) As Integer
	Dim SudoIn(0 To 8, 0 To 8) As Integer
	For i As Integer = 0 To 80
		SudoIn(i \ 9, i Mod 9) = SudoKu(0, i \ 9, i Mod 9) 'SudoString[i] - Asc("0")
	Next i
	SolveSudo(SudoAns(), SudoIn())
	GameOver = True
	'' 如果需要解对角线数独
	'While (dialog_sudoku(sudoans[0])==0) {
	'    solvesudo(sudoans, sudoin);
	'    print_a_sudoku(sudoans);
	'
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			With pnlSudoCell(i + j * 9)
				'.Font.Size = SudoCellFontSize
				.Text = WStr(SudoAns(0, i, j))
				.ShowCaption = IIf(SudoAns(0, i, j) > 0, True, False)
				.BackColor = IIf(SudoKu(0, i, j) > 0, SudoCellColorBK, SudoCellColorBKSelect)
				'.ForeColor = SudoCellColorFore
				'Debug.Print SudoIn(i, j)
			End With
			
			For k As Integer = 0 To 8
				' lblSudoCellChild(0)
				
				With lblSudoCellChild(9 * (i + j * 9) + k)
					'.Text = pnlSudoCell(i + j * 9).Text
					.ForeColor = SudoCellChildColorFore
					.Visible= IIf(SudoAns(0, i, j) > 0, False, IIf(SudoAns(k + 1, i, j) > 0, True, False))
					'.Parent = @pnlSudoCell(i + j * 9)
				End With
			Next
		Next
	Next
	
	'Dim As String LineStr
	'For i As Integer = 0 To 8
	'	LineStr = "| "
	'	For j As Integer = 0 To 8
	'		LineStr &= " " & SudoAns(0, i, j) & " "
	'		If j Mod 3 = 2 Then LineStr &=  "| "
	'	Next j
	'	Debug.Print LineStr
	'	If i Mod 3 = 2 Then Debug.Print "  -- -- --   -- -- --   -- -- --"
	'Next i
	'
	'[X-wing] 7在行0,2列1,4交叉点两行或两列的7只在交叉点上存在,意味着4个交叉点上的7一定存在两个,那么可以删去不在交叉点上的7
	
End Sub

Private Sub Form1Type.cmdFromClipBoard_Click(ByRef Sender As Control)
	Dim As String SudoString = cboFromClipBoard.Text
	Erase SudoKu  'Clear_Bits(SudoKu())
	Erase SudoAns
	Erase SudoIn
	GameOver = False
	Build_Bit_FromStr(SudoKu(), SudoString)
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			With pnlSudoCell(i + j * 9)
				.Text = Str(SudoKu(0, i, j))
				.ShowCaption = IIf(SudoKu(0, i, j) > 0, True , False)
			End With
		Next
	Next
	cmdSolveSudo.Enabled = True
	'For i As Integer = 0 To 80
	'	SudoIn(i \ 9, i Mod 9) = SudoString[i] - Asc("0")
	'Print SudoIn(i \ 9, i Mod 9);
	'If i Mod 9 = 8 Then Print
	'Next i
	' pnlSudoCell(0)
	UpdateShow("")
End Sub

Private Sub Form1Type.UpdateShow(ByRef CurrentValue As String = "")
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			With pnlSudoCell(i + j * 9)
				If .ShowCaption Then
					If .Text = CurrentValue Then
						.BackColor = SudoCellColorHover
					Else
						.BackColor = IIf(SudoKu(0, i, j) = 0, SudoCellColorBKSelect, SudoCellColorBK)
					End If
				Else
					.BackColor = SudoCellColorBKDefault
				End If
			End With
			
			For k As Integer = 0 To 8
				With lblSudoCellChild(9 * (i + j * 9) + k)
					.Visible= IIf(pnlSudoCell(i + j * 9).ShowCaption OrElse SudoKu(k + 1, i, j) = 0, False, IIf(SudoKu(k + 1, i, j) > 0, True, False))
					.ForeColor = SudoCellChildColorFore
					.BackColor = IIf(.Visible AndAlso .Text = CurrentValue, SudoCellColorHover, SudoCellChildColorBK)
				End With
			Next
		Next
	Next
End Sub

Private Sub Form1Type.pnlSudoCell_MouseLeave(ByRef Sender As Control)
	Dim As Integer Index = Val(Mid(Sender.Name, InStrRev(Sender.Name, "(") + 1))
	If Val(Sender.Text) > 0 Then
		Sender.BackColor = IIf(SudoKu(0, Index Mod 9, Index \ 9) > 0, SudoCellColorBK, SudoCellColorBKSelect)
	End If
End Sub

Private Sub Form1Type.pnlSudoCell_MouseHover(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	Dim As Integer Index = Val(Mid(Sender.Name, InStrRev(Sender.Name, "(") + 1))
	MsCellChild.X = x
	MsCellChild.Y = y
	If Val(Sender.Text) > 0 Then Sender.BackColor = SudoCellColorHover
End Sub
Private Sub Form1Type.pnlSudoCell_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	Dim As Integer Index = Val(Mid(Sender.Name, InStrRev(Sender.Name, "(") + 1))
	If GameOver Then Exit Sub
	'Debug.Print "MouseButton=" & MouseButton
	If MouseButton = 1 AndAlso Sender.BackColor <> SudoCellColorBK AndAlso SudoKu(0, Index \ 9, Index Mod 9) = 0 Then
		Sender.BackColor = SudoCellColorBKDefault
		Sender.Text = "0"
		Sender.ShowCaption = False
		'Clear_Point(SudoKu(), tryNum, x, y)
		For k As Integer = 0 To 8
			With lblSudoCellChild(Index * 9 + k)
				.Visible= IIf(SudoKu(k + 1, Index Mod 9, Index \ 9) = 1, True, False)
			End With
		Next
	ElseIf MouseButton = 0 Then
		UpdateShow(Sender.Text)
	End If
End Sub

Private Sub Form1Type.pnlSudoCell_KeyPress(ByRef Sender As Control, Key As Integer)
	
End Sub

Private Sub Form1Type.lblSudoCellChild_KeyPress(ByRef Sender As Control, Key As Integer)
	
End Sub

Private Sub Form1Type.lblSudoCellChild_MouseHover(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	Dim As Integer Index = Val(Mid(Sender.Name, InStrRev(Sender.Name, "(") + 1))
	Sender.BackColor = SudoCellChildColorHover
End Sub

Private Sub Form1Type.lblSudoCellChild_MouseLeave(ByRef Sender As Control)
	Dim As Integer Index = Val(Mid(Sender.Name, InStrRev(Sender.Name, "(") + 1))
	Sender.BackColor = SudoCellChildColorBK
End Sub

Private Sub Form1Type.lblSudoCellChild_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	Dim As Integer Index = Val(Mid(Sender.Name, InStrRev(Sender.Name, "(") + 1))
	Dim As Integer IndexCell = Index \ 9
	If MouseButton = 1 Then
		pnlSudoCell(IndexCell).BackColor = SudoCellColorBKSelect
		pnlSudoCell(IndexCell).Text = Sender.Text
		pnlSudoCell(IndexCell).ShowCaption = True
		If bCustomize Then
			SudoKu(0, IndexCell Mod 9, IndexCell \ 9) = Val(Sender.Text)
			'PreSolveSudo(SudoKu())
			UpdateShow(Sender.Text)
		Else
			SudoKu(Val(Sender.Text), IndexCell Mod 9, IndexCell \ 9) = 1
		End If
		For k As Integer = 0 To 8
			With lblSudoCellChild(IndexCell * 9 + k)
				.Visible= False
			End With
		Next
		
	ElseIf MouseButton = 0 Then
		UpdateShow(Sender.Text)
	End If
End Sub

Private Sub Form1Type.lblSudoCellChild_GotFocus(ByRef Sender As Control)
	Dim As Integer Index = Val(Mid(Sender.Name, InStrRev(Sender.Name, "(") + 1))
	
End Sub

Private Sub Form1Type.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	If This.ClientWidth < 400 OrElse This.ClientHeight < 400 Then Exit Sub
	Dim As Integer FormSize = Min(This.ClientWidth - (SudoCellLeft + 20) , This.ClientHeight - (cboFromClipBoard.Height + SudoCellTop + 20))
	SudoCellSize = FormSize / 9 - 6
	SudoCellChildSize= (SudoCellSize - 9) / 3
	Dim As Integer tFontSize= (SudoCellSize - 6) * 72 / 96 - 2
	pnlSudoCell(0).Font.Size= tFontSize
	pnlBack.SetBounds SudoCellLeft, SudoCellTop, SudoCellSize * 9 + SudoCellGaps * 8, SudoCellSize * 9 + SudoCellGaps * 8
	Dim As My.Sys.Drawing.Point  tCurrent = Type<My.Sys.Drawing.Point>((SudoCellSize - pnlSudoCell(0).Canvas.TextWidth("A")) / 2, (SudoCellSize - pnlSudoCell(0).Canvas.TextHeight("A")) / 2)
	Dim As Integer SudoCellLeftX
	Dim As Integer SudoCellTopY = SudoCellGaps - SudoCellSize
	For j As Integer = 0 To 8
		SudoCellLeftX = SudoCellGaps - SudoCellSize
		SudoCellTopY = IIf(j = 3 OrElse j = 6, SudoCellTopY + SudoCellGaps + SudoCellSize , SudoCellTopY + SudoCellGaps / 2 + SudoCellSize)
		
		For i As Integer = 0 To 8
			SudoCellLeftX = IIf(i = 3 OrElse i = 6, SudoCellLeftX + SudoCellGaps + SudoCellSize , SudoCellLeftX + SudoCellGaps / 2 + SudoCellSize)
			With pnlSudoCell(i + j * 9)
				.Canvas.Font.Size= tFontSize
				.Current = tCurrent
				.SetBounds SudoCellLeftX, SudoCellTopY, SudoCellSize, SudoCellSize
			End With
			
			For k As Integer = 0 To 8
				With lblSudoCellChild(9 * (i + j * 9) + k)
					.Font.Size= (SudoCellChildSize - 6) * 72 / 96
					.SetBounds SudoCellChildLeft + SudoCellChildSize * (k Mod 3) + (k Mod 3), SudoCellChildTop + SudoCellChildSize * (k \ 3) + (k \ 3), SudoCellChildSize, SudoCellChildSize
				End With
			Next
		Next
	Next
	cboFromClipBoard.Top = pnlBack.Top + pnlBack.Height + 5
	cmdFromClipBoard.Top = cboFromClipBoard.Top
	cmdSolveSudo.Top = cboFromClipBoard.Top - cmdSolveSudo.Height - 3
	
End Sub

Private Sub Form1Type.cmdCustomize_Click(ByRef Sender As Control)
	bCustomize = Not bCustomize
	cmdCustomize.Text = IIf(bCustomize, ML("Stop Customize"), ML("Customize"))
	cmdSolveSudo.Enabled = IIf(bCustomize, False, True)
	cmdFromClipBoard.Enabled = IIf(bCustomize, False, True)
	cmdRandomized.Enabled = IIf(bCustomize, False, True)
	If bCustomize Then
		Dim As String SudoString = String(81, 48)
		Erase SudoKu  'Clear_Bits(SudoKu())
		Erase SudoAns
		Erase SudoIn
		GameOver = False
		Build_Bit_FromStr(SudoKu(), SudoString)
		For j As Integer = 0 To 8
			For i As Integer = 0 To 8
				With pnlSudoCell(i + j * 9)
					.Text = Str(SudoKu(0, i, j))
					.ShowCaption = IIf(SudoKu(0, i, j) > 0, True , False)
				End With
			Next
		Next
		UpdateShow("")
	Else
		Dim As String SudoString
		For j As Integer = 0 To 8
			For i As Integer = 0 To 8
				If SudoKu(0, i, j) > 0 Then
					SudoString += Str(SudoKu(0, i, j))
				Else
					SudoString += "0"
				End If
			Next
		Next
		cboFromClipBoard.AddItem SudoString
		cboFromClipBoard.Text = SudoString
		cmdFromClipBoard_Click(Sender)
	End If
End Sub

Private Sub Form1Type.cmdRandomized_Click(ByRef Sender As Control)
	cboFromClipBoard.ItemIndex = Int(Rnd * cboFromClipBoard.ItemCount)
	cmdFromClipBoard_Click(Sender)
End Sub

Private Sub Form1Type.Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	'Canvas.(X1, y1, x2, y2)
End Sub

Private Sub Form1Type.pnlBack_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	If bDrawing Then
		Canvas.Line(pnlSudoCell(0).Left + SudoCellSize/ 2, pnlSudoCell(0).Top + SudoCellSize/ 2, pnlSudoCell(80).Left + SudoCellSize/ 2, pnlSudoCell(80).Top + SudoCellSize/ 2, clRed)
	Else
		Canvas.Line(pnlSudoCell(0).Left + SudoCellSize/ 2, pnlSudoCell(0).Top + SudoCellSize/ 2, pnlSudoCell(80).Left + SudoCellSize/ 2, pnlSudoCell(80).Top + SudoCellSize/ 2, clRed)
	End If
End Sub

Private Sub Form1Type.cmdDrawing_Click(ByRef Sender As Control)
	bDrawing = Not bDrawing
	cmdDrawing.Text = IIf(bDrawing, ML("Stop Draw"), ML("Drawing"))
	cmdCustomize.Enabled = IIf(bDrawing, False, True)
	cmdSolveSudo.Enabled = IIf(bDrawing, False, True)
	cmdFromClipBoard.Enabled = IIf(bDrawing, False, True)
	cmdRandomized.Enabled = IIf(bDrawing, False, True)
	If bDrawing Then
		Dim As Rect ScreenshotRect
		GetWindowRect(pnlBack.Handle, @ScreenshotRect)
		'拷贝屏幕图像bi于背景，控件不能点选
		pnlBack.Graphic.Bitmap.LoadFromScreen(ScreenshotRect.Left, ScreenshotRect.Top, ScreenshotRect.Right, ScreenshotRect.Bottom) 'LoadFromScreen(ScreenshotRect.Left, ScreenshotRect.Top, (ScreenshotRect.Right - ScreenshotRect.Left), (ScreenshotRect.Bottom - ScreenshotRect.Top))
		'隐藏控件
		For j As Integer = 0 To 8
			For i As Integer = 0 To 8
				With pnlSudoCell(i + j * 9)
					.Visible = False
				End With
			Next
		Next
		'Canvas.DrawWidth = 2
		'Canvas.DrawColor = clBlue
	Else
		pnlBack.Canvas.Cls
		'显示控件
		For j As Integer = 0 To 8
			For i As Integer = 0 To 8
				With pnlSudoCell(i + j * 9)
					.Visible = True
				End With
			Next
		Next
	End If
End Sub
