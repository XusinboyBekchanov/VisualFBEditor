'############################################################################################
'#  sudoku_solver                                                                           #
'#  This file is an examples of MyFBFramework.                                              #
'#  Authors: Xusinboy Bekchanov, Liu XiaLin                                                 #
'# See also https://github.com/tropicalwzc/ice_sudoku.github.io/blob/master/sudoku_solver.c #
'############################################################################################

''清空x,y点行列宫范围内的候选数
Sub Clear_Point(sudo(Any, Any, Any) As Integer, ByVal tryNum As Integer, ByVal x As Integer, ByVal y As Integer)
	For v As Integer = 0 To 8
		sudo(tryNum, v, y) = 0
		sudo(tryNum, x, v) = 0
		sudo(v + 1, x, y) = 0
	Next v
	
	For r As Integer = 0 To 8
		sudo(tryNum, r \ 3 + x - x Mod 3, r Mod 3 + y - y Mod 3) = 0
	Next r
End Sub

''完全清空候选数数组
Sub Clear_Bits(Save(Any, Any, Any) As Integer)
	For i As Integer = 0 To 8
		For j As Integer = 0 To 8
			For p As Integer = 1 To 9
				Save(p, i, j) = 0
			Next p
		Next j
	Next i
End Sub

''判断两个数独否完全一致
Function IsTheSame(Sudo(Any, Any) As Integer, SudoExt(Any, Any) As Integer) As Boolean
	For i As Integer = 0 To 8
		For k As Integer = 0 To 8
			If Sudo(i, k) <> SudoExt(i, k) Then
				Return True
			End If
		Next k
	Next i
	Return False
End Function

''复制数独
Sub CopySudo(Sudo(Any, Any) As Integer, SudoExt(Any, Any) As Integer)
	Dim As Integer  i, k
	For i = 0 To 8
		For k = 0 To 8
			Sudo(i, k) = SudoExt(i, k)
		Next k
	Next i
End Sub

Sub CopySudoMix(Sudo(Any, Any, Any) As Integer, SudoExt(Any, Any) As Integer)
	Dim As Integer i, k, p
	For i = 0 To 8
		For k = 0 To 8
			Sudo(0, i, k) = SudoExt(i, k)
		Next k
	Next i
End Sub


''候选数模式复制数独 Sudo(0 To 9, 0 To 8, 0 To 8)
Sub BitCopySudo(Sudo(Any, Any, Any) As Integer, SudoExt(Any, Any, Any) As Integer)
	Dim As Integer i, k, p
	For p = 0 To 9
		For i = 0 To 8
			For k = 0 To 8
				Sudo(p, i, k) = SudoExt(p, i, k)
			Next k
		Next i
	Next p
End Sub

' 判断是否允许填入(x,y)点的z值
Function CanPutIn(Sudo(Any, Any, Any) As Integer, ByVal x As Integer, ByVal y As Integer, ByVal z As Integer) As Boolean
	If Sudo(0, x, y) <> 0 Then
		Return False
	End If
	Dim As Integer a, b
	
	For a = 0 To 8
		If Sudo(0, a, y) = z Then
			Return False
		End If
	Next a
	
	For b = 0 To 8
		If Sudo(0, x, b) = z Then
			Return False
		End If
	Next b
	
	For a = (x \ 3) * 3 To (x \ 3) * 3 + 2
		For b = (y \ 3) * 3 To (y \ 3) * 3 + 2
			If Sudo(0, a, b) = z Then
				Return False
			End If
		Next b
	Next a
	Return True
End Function

' 求和  lay(0 To 8, 0 To 8)
Function SumLay(lay(Any, Any) As Integer, ByVal q As Integer, ByVal p As Integer) As Integer
	Dim As Integer  x, y
	For x = q * 3 To q * 3 + 2
		For y = p * 3 To p * 3 + 2
			If lay(x, y) = 0 Then
				Return 0
			End If
		Next y
	Next x
	Return 9
End Function

' 判断是否在(x,y)所在九宫格内存在z值
Function IsExist(Sudo(Any, Any, Any) As Integer, ByVal x As Integer, ByVal y As Integer, ByVal z As Integer) As Boolean
	Dim As Integer a, b
	For a = (x \ 3) * 3 To (x \ 3) * 3 + 2
		For b = (y \ 3) * 3 To (y \ 3) * 3 + 2
			If Sudo(0, a, b) = z Then
				Return True
			End If
		Next b
	Next a
	Return False
End Function

' 构建候选数全图，无自动更新   sudo(0 To 9, 0 To 8, 0 To 8)
Sub Low_Build_Bit(Sudo(Any, Any, Any) As Integer)
	Dim As Integer i, k, f
	For f = 1 To 9
		For i = 0 To 8
			For k = 0 To 8
				If Sudo(0, i, k) = 0 Then
					If CanPutIn(Sudo(), i, k, f) = True Then
						Sudo(f, i, k) = 1
					End If
				End If
			Next k
		Next i
	Next f
End Sub

' 点排除模式刷新数独   sudo(0 To 9, 0 To 8, 0 To 8)
Function Change_Bit(Sudo(Any, Any, Any) As Integer) As Integer
	Dim As Integer con, py, l, v, i, k
	Dim As Boolean al = 0
	For i = 0 To 8
		For k = 0 To 8
			If Sudo(0, i, k) <> 0 Then
				Continue For
			End If
			For l = 1 To 9
				If Sudo(l, i, k) = 1 Then
					If con = 1 Then
						con = 0
						Exit For
					Else
						con = 1
						py = l
					End If
				End If
			Next l
			If con = 1 Then
				Sudo(0, i, k) = py
				For v = 0 To 8
					Sudo(py, v, k) = 0
					Sudo(py, i, v) = 0
					Sudo(py, v \ 3 + i - i Mod 3, v Mod 3 + k - k Mod 3) = 0
				Next v
				al = True
				con = 0
			End If
		Next k
	Next i
	Return al
End Function

' 宫排除模式刷新数独
Function Square_Bit(Sudo(Any, Any, Any) As Integer) As Boolean
	Dim As Integer p, a, b, i, k, r, u, v, block(0 To 9)
	Dim As Boolean label
	For a = 0 To 2
		For b = 0 To 2
			Dim sum As Integer
			For i = a * 3 To a * 3 + 2
				For k = b * 3 To b * 3 + 2
					If Sudo(0, i, k) = 0 Then
						sum += 1
						For p = 1 To 9
							block(p) += Sudo(p, i, k)
						Next p
					End If
				Next k
			Next i
			For p = 1 To 9
				If block(p) = 1 Then
					For r = 0 To 8
						i = r \ 3 + a * 3
						k = r Mod 3 + b * 3
						If Sudo(p, i, k) = 1 Then
							Sudo(0, i, k) = p
							For u = 1 To 9
								Sudo(u, i, k) = 0
							Next u
							For v = 0 To 8
								Sudo(p, v, k) = 0
								Sudo(p, i, v) = 0
							Next v
							label = True
							Exit For
						End If
					Next r
				End If
				block(p) = 0
			Next p
		Next b
	Next a
	Return label
End Function

' 行排除刷新数独
Function Row_Bit(Sudo(Any, Any, Any) As Integer) As Boolean
	Dim As Boolean ChangeOr = False
	Dim As Integer i, k, p, u, v, r
	Dim row(1 To 10) As Integer
	
	For i = 0 To 8
		For k = 0 To 8
			If Sudo(0, i, k) <> 0 Then
				Continue For
			End If
			For p = 1 To 9
				row(p) += Sudo(p, i, k)
			Next p
		Next k
		For p = 1 To 9
			If row(p) = 1 Then
				For k = 0 To 8
					If Sudo(p, i, k) = 1 Then
						Sudo(0, i, k) = p
						For u = 1 To 9
							Sudo(u, i, k) = 0
						Next u
						For v = 0 To 8
							Sudo(p, v, k) = 0
							Sudo(p, i, v) = 0
						Next v
						For r = 0 To 8
							Sudo(p, r \ 3 + i - i Mod 3, r Mod 3 + k - k Mod 3) = 0
						Next r
						ChangeOr = True
						Exit For
					End If
				Next k
			End If
			row(p) = 0
		Next p
	Next i
	
	Return ChangeOr
End Function

' 列排除模式刷新数独
Function Col_Bit(Sudo(Any, Any, Any) As Integer) As Boolean
	Dim As Boolean changeor
	Dim As Integer Col(11), Colnum(11)
	For k As Integer = 0 To 8
		For i As Integer = 0 To 8
			If Sudo(0, i, k) <> 0 Then Continue For
			For p As Integer = 1 To 9
				If Sudo(p, i, k) = 1 Then
					Col(p) = Col(p) + 1
					Colnum(p) = i
				End If
			Next p
		Next i
		For p As Integer = 1 To 9
			If Col(p) = 1 Then
				Sudo(0, Colnum(p), k) = p
				For u As Integer = 0 To 8
					Sudo(p, Colnum(p), u) = 0
					Sudo(u + 1, Colnum(p), k) = 0
					Sudo(p, Colnum(p), u) = 0
					Sudo(p, u \ 3 + Colnum(p) - (Colnum(p) Mod 3), (u Mod 3) + k - (k Mod 3)) = 0
				Next u
				changeor = True
			End If
			Col(p) = 0
		Next p
	Next k
	Return changeor
End Function

' 综合使用行列宫点排除进行快速刷新候选数图
Function PreSolveSudo(Sudo(Any, Any, Any) As Integer) As Boolean
	Dim lok As Boolean
	Do While Square_Bit(Sudo()) Or Row_Bit(Sudo()) Or Col_Bit(Sudo())
		Change_Bit(Sudo())
		lok = True
	Loop
	Return lok
End Function

' 构建基础候选数图并且加入自动快速更新
Sub Build_Bit(Sudo(Any, Any, Any) As Integer)
	Dim As Integer i, k, f
	For f = 1 To 9
		For i = 0 To 8
			For k = 0 To 8
				If Sudo(0, i, k) = 0 Then
					If CanPutIn(Sudo(), i, k, f) Then
						Sudo(f, i, k) = 1
					End If
				End If
			Next k
		Next i
	Next f
	PreSolveSudo(Sudo())
End Sub

' 从字符串构建基础候选数图并且加入自动快速更新
Sub Build_Bit_FromStr(Sudo(Any, Any, Any) As Integer, SudoStr As String)
	Dim As Integer i, k, f
	If Len(SudoStr) = 81 Then
		For i As Integer = 0 To 80
			Sudo(0, i Mod 9, i \ 9) = SudoStr[i] - 48 'Asc("0")
		Next i
	End If
	For f = 1 To 9
		For i = 0 To 8
			For k = 0 To 8
				If Sudo(0, i, k) = 0 Then
					If CanPutIn(Sudo(), i, k, f) Then
						Sudo(f, i, k) = 1
					End If
				End If
			Next k
		Next i
	Next f
	PreSolveSudo(Sudo())
End Sub

' 判断当前数独是否存在无解矛盾  TempSudo(0 To 9, 0 To 8, 0 To 8)
Function LineCheck(TempSudo(Any, Any, Any) As Integer) As Boolean
	Dim As Integer i, k, p
	' 检查行、列、宫是否符合逻辑
	For p = 1 To 9
		For i = 0 To 8
			For k = 0 To 8
				If TempSudo(0, i, k) = p Then Exit For
				If TempSudo(p, i, k) = 1 Then Exit For
				If k = 8 Then Return False
			Next k
		Next i
		
		For i = 0 To 8
			For k = 0 To 8
				If TempSudo(0, k, i) = p Then Exit For
				If TempSudo(p, k, i) = 1 Then Exit For
				If k = 8 Then Return False
			Next k
		Next i
		
		For i = 0 To 8
			For k = 0 To 8
				Dim bx As Integer = i - (i Mod 3) + (k \ 3)
				Dim by As Integer = (i Mod 3) * 3 + (k Mod 3)
				If TempSudo(0, bx, by) = p Then Exit For
				If TempSudo(p, bx, by) = 1 Then Exit For
				If k = 8 Then Return False
			Next k
		Next i
	Next p
	
	' 检查是否有空格未填
	For i = 0 To 8
		For k = 0 To 8
			Dim found As Integer = 0
			For p = 0 To 9
				If TempSudo(p, i, k) <> 0 Then
					found = 1
					Exit For
				End If
			Next p
			If found = 0 Then Return False
		Next k
	Next i
	
	Return True
End Function

' 数独是否存在空置?
Function IsVacant(Sudo(Any, Any, Any) As Integer) As Boolean
	For i As Integer = 0 To 8
		For k As Integer = 0 To 8
			If Sudo(0, i, k) = 0 Then
				Return True
			End If
		Next k
	Next i
	Return False
End Function

' 数独是否求解完毕?
Function IsOK(Sudo(Any, Any, Any) As Integer) As Boolean
	Dim As Integer i, k, mul, sum
	sum = 0 : mul = 1
	For i = 0 To 8
		sum = 0 : mul = 1
		For k = 0 To 8
			sum += Sudo(0, i, k)
			mul *= Sudo(0, i, k)
		Next k
		If sum <> 45 Or mul <> 362880 Then
			Return False
		End If
	Next i
	
	For k = 0 To 8
		sum = 0 : mul = 1
		For i = 0 To 8
			sum += Sudo(0, i, k)
			mul *= Sudo(0, i, k)
		Next i
		If sum <> 45 Or mul <> 362880 Then
			Return False
		End If
	Next k
	Return True
End Function

' 检测两个数独是否一样
Function Check(Sudo(Any, Any, Any) As Integer, SudoExt(Any, Any) As Integer) As Boolean
	For i As Integer = 0 To 8
		For k As Integer = 0 To 8
			If SudoExt(i, k) <> 0 Then
				If Sudo(0, i, k) <> SudoExt(i, k) Then
					Return False
				End If
			End If
		Next k
	Next i
	Return True
End Function

''随机快速求解数独
Sub SolveSudo(Sudo(Any, Any, Any) As Integer, SudoExt(Any, Any) As Integer)
	Dim As Integer rng, x, y, q, p, tryNum
	Dim Lay(0 To 8, 0 To 8) As Integer
	Dim As Integer backer, dt
	
	Dim SudoP(0 To 9, 0 To 8, 0 To 8) As Integer
	CopySudoMix(SudoP(), SudoExt())
	''建立基础候选数图
	Build_Bit(SudoP())
	
	If Not IsVacant(SudoP()) Then
		''90%以上的数独时最简单的，连一次刷新都挺不过就求解完毕了
		''可以直接返回
		BitCopySudo(Sudo(), SudoP())
		Exit Sub
	End If
	''记录已访问
	Dim havetry(0 To 9) As Integer
	'For i As Integer = 0 To 9
	'	havetry(i) = 0
	'Next i
	
	Do
		dt = 0
		backer = 0
		For i As Integer = 0 To 9
			havetry(i) = 0
		Next i
		''候选数恢复现场
		BitCopySudo(Sudo(), SudoP())
		
		For dt = 1 To 9
			tryNum = Int(Rnd * 9) + 1
			'Debug.Print "Int(Rnd * 9) + 1 = " & tryNum
			While havetry(tryNum) = 1
				tryNum = Int(Rnd * 9) + 1
			Wend
			havetry(tryNum) = 1
			
			If dt >= 2 Then
				If Not LineCheck(Sudo()) Then
					' 已经出现错误，返回恢复现场重新尝试
					backer = 2
					Exit For
				End If
			End If
			
			If dt >= 2 Then
				If Not IsVacant(Sudo()) Then
					''似乎已经求解完成,检测一下
					Exit Do
				End If
			End If
			
			For ii As Integer = 0 To 8
				For kk As Integer = 0 To 8
					Lay(ii, kk) = 0
				Next kk
			Next ii
			
			For b As Integer = 0 To 8
				p = b \ 3
				q = b Mod 3
				
				If IsExist(Sudo(), q * 3, p * 3, tryNum) Then Continue For
				
				x = Int(Rnd * 3) + q * 3
				y = Int(Rnd * 3) + p * 3
				Lay(x, y) = 1
				
				rng = Sudo(tryNum, x, y)
				While rng <> 1
					x = Int(Rnd * 3) + q * 3
					y = Int(Rnd * 3) + p * 3
					If Lay(x, y) = 1 Then
						Continue For
					End If
					Lay(x, y) = 1
					
					If SumLay(Lay(), q, p) = 9 Then
						Exit While
					End If
					rng = Sudo(tryNum, x, y)
				Wend
				
				If Sudo(0, x, y) = 0 Then
					Sudo(0, x, y) = tryNum
					Clear_Point(Sudo(), tryNum, x, y)
					PreSolveSudo(Sudo())
				Else
					''已经尝试过所有情况，仍然没有返回意味着已经在这个九宫格的tryNum无法满足，返回重试
					'Debug.Print "dt = " & dt
					backer = 2
					Exit For
				End If
			Next b
		Next dt
		''只有经过验证和原有数字完全一样的已经完全符合数独规则的81个格全部填写完毕才算求解完毕
	Loop While CBool(backer = 2) OrElse IsOK(Sudo()) OrElse Check(Sudo(), SudoExt())
End Sub

' 打印数独 SudoKu(0 To 8, 0 To 8)
Sub Print_a_Sudoku(SudoKu(Any, Any, Any) As Integer)
	Print "  -- -- --   -- -- --   -- -- --"
	For i As Integer = 0 To 8
		Print "| ";
		For j As Integer = 0 To 8
			Print Using "## "; SudoKu(0, i, j);
			If j Mod 3 = 2 Then Print "| ";
		Next j
		Print
		If i Mod 3 = 2 Then Print "  -- -- --   -- -- --   -- -- --"
	Next i
End Sub

' 对话框数独验证  SudoKu(0 To 8, 0 To 8)
Function Dialog_SudoKu(SudoKu(Any, Any) As Integer) As Boolean
	Dim hp(0 To 9) As Integer
	For i As Integer = 0 To 8
		hp(SudoKu(i, i)) += 1
		If hp(SudoKu(i, i)) > 1 Then
			Return False
		End If
	Next i
	
	Dim fp(0 To 9) As Integer
	For i As Integer = 0 To 8
		Dim j As Integer = 8 - i
		fp(SudoKu(i, j)) += 1
		If fp(SudoKu(i, j)) > 1 Then
			Return False
		End If
	Next i
	Return True
End Function

' 主函数
Function main() As Boolean
	Randomize ' 初始化随机数生成器
	Dim As String inter = "500000300020100070008000009040007000000821000000600010300000800060004020009000005"
	'Input "", inter
	Dim SudoAns(0 To 9, 0 To 8, 0 To 8) As Integer
	Dim SudoIn(0 To 8, 0 To 8) As Integer
	For i As Integer = 0 To 80
		SudoIn(i \ 9, i Mod 9) = inter[i + 1] - Asc("0")
	Next i
	
	SolveSudo(SudoAns(), SudoIn())
	'' 如果需要解对角线数独
	'While (dialog_sudoku(sudoans[0])==0) {
	'    solvesudo(sudoans, sudoin);
	'    print_a_sudoku(sudoans);
	'}
	
	Print_a_Sudoku(SudoAns())
	
	Return True
End Function
'Print main
'Sleep
/' 可以用以下这些超困难数独测试,可以肯定凭借人脑基本上都不可能做出来的
@"500000300020100070008000009040007000000821000000600010300000800060004020009000005",
@"800000009040001030007000600000023000050904020000105000006000700010300040900000008",
@"000070100000008050020900003530000000062000004094600000000001800300200009000050070",
@"000006080000100200009030005040070003000008010000200600071090000590000004804000000",
@"000056000050109000000020040090040070006000300800000002300000008002000600070500010",
@"500000004080006090001000200070308000000050000000790030002000100060900080400000005",
@"070200009003060000400008000020900010800004000006030000000000600090000051000700002",
@"100080000005900000070002000009500040800010000060007200000000710000004603030000402",
@"000900100000080007004002050200005040000100900000070008605000030300006000070000006",
@"000001080030500200000040006200300500000008010000060004050000700300970000062000000",
@"800000005040003020007000100000004000090702060000639000001000700030200040500000008",
@"900000001030004070006000200050302000000060000000078050002000600040700030100000009",
@"500000008030007040001000900020603000000725000000800060009000100070400030800000005",
@"400000009070008030006000100050702000000065000000003020001000600080300070900000004",
@"100006009007080030000200400000500070300001002000090600060003050004000000900020001",
@"800000001050009040003000600070056000000980000000704020006000300090400050100000008",
@"010000009005080700300700060004250000000000000000840200008007500600000030090000001",
@"300000005020007040001000900080036000000028000000704060009000100070400020500000003",
@"400000003080002060007000900010508000000701000000026050009000700020600080300000004",
@"600005020040700000009080000010000302000000087000200104070400003500006000008090000",
@"007002000500090400010600000400050003060100000002007000000000810900000306000080059",
@"000007090000800400003060001420010000031000002605000000060400800500020006000009070",
@"000600001000020400300009050090005030000040200000100006570008000002000000080000090",
@"006003000900080200070400000003006000040700000800020090500000008000000709000510020",
@"010300000000009000000710050004050900200000006070800030600000002080030070009000400",
@"000008070000300200005040009260094000059000006401000000000200300100060004000007080",
@"000800300000010005004002070200007040000300807000050001907000060600009000050000000",
@"800000007040001030009000600000532000050108020000400000006000900010300040700000008",
@"400000008050002090001000600070503000000060000000790030006000100020900050800000004",
@"300000009010006050002000400070060000000701000000845070004000200060500010900000003",
@"000000789000100036009000010200030000070004000008500100300020000005800090040007000",
@"100000000006700020080030500007060030000500008000004900300800600002090070040000001",
@"700000005040001030002000900060008000000946000000103080009000200010300040500000007",
@"001020000300004000050600070080900005002003000400010000070000038000800069000000200",
@"007580000000030000000076005400000020090000100003060008010600900006800003200000040",
@"097000000301005000045000800003008400000020060000100009700004300000900001000060020",
@"003700000050004000100020080900000012000000400080010090007300000200090006040005000",
@"000000100600000874000007026030400000005090000100008002009050000200001008040300000",
@"100000004020006090005000800030650000000372000000098070008000500060900020400000001",
@"005300000800000020070010500400005300010070006003200080060500009004000030000009700",
@"000002005006700400000009008070090000600400700010000080060300100300000002400005000",
@"020000600400080007009000010005006000300040900010200000000700004000001050800090300",
@"900000007030008040006000200010389000000010000000205010002000600080400030700000009",
@"002400006030010000500008000007000002010000030900600400000007001000090080400200500",
@"100300000020090400005007000800000100040000020007060003000400800000020090006005007",
@"002600000030080000500009100006000002080000030700001400000004005010020080000700900",
@"003500100040080000600009000800000002050700030001000400000006009000020080070100500",
@"300000906040200080000060000050800020009000307000007000010042000000000010508100000",
@"000090050010000030002300700004500070800000200000006400090010000080060000005400007",
@"100500000200000030004060100006007000008000009400080200000009007040010600000005003"
'/
