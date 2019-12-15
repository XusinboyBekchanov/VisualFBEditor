'################################################################
'#  frmFind.bas                                                 #
'#  This file is part of VisualFBEditor                         #
'#  Authors: Xusinboy Bekchanov (2018-2019), Liu ZiQI (2019)    #
'################################################################

#include once "frmFind.bi"

Dim Shared As frmFind fFind
pfFind = @fFind
'#Region "Form"
	Private Sub frmFind._btnFind_Click_(ByRef Sender As Control)
		Me.btnFind_Click(Sender)        
	End Sub 
	
	Private Sub frmFind._btnFindPrev_Click_(ByRef Sender As Control)
		Me.btnFindPrev_Click(Sender)        
	End Sub      
	
	Private Sub frmFind._btnReplace_Click_(ByRef Sender As Control)        
		Me.btnReplace_Click(Sender)       
	End Sub
	
	Private Sub frmFind._btnReplaceAll_Click_(ByRef Sender As Control)
		Me.btnReplaceAll_Click(Sender)
	End Sub
	Private Sub frmFind._btnReplaceShow_Click_(ByRef Sender As Control)
		Me.btnReplaceShow_Click(Sender)
	End Sub
	Private Sub frmFind._btnCancel_Click_(ByRef Sender As Control)
		Me.btnCancel_Click(Sender)
	End Sub
	
	Private Sub frmFind._Form_Show_(ByRef Sender As Form)
		Me.Form_Show(Sender)
	End Sub
	
	Private Sub frmFind._Form_Close_(ByRef Sender As Form, ByRef Action As Integer)
		Me.Form_Close(Sender, Action)
	End Sub
	
	Constructor frmFind
		'This.BorderStyle = 2
		
		' lblFind
		lblFind.Caption = ML("Find") & ":"
		lblFind.SetBounds 24, 11, 40, 14
		lblFind.Text = ML("Find") & ":"
		lblFind.Parent = @THIS      
		
		' txtFind
		txtFind.Style = cbDropDown
		txtFind.SetBounds 66, 6, 212, 24
		txtFind.Anchor.Left = asAnchor  
		txtFind.Text = "Find"
		txtFind.Parent = @This
		
		' txtReplace
		txtReplace.Style = cbDropDown        
		txtReplace.NAME = "txtReplace"
		txtReplace.Text = "Replace"
		txtReplace.SetBounds 66, 38, 212, 21
		txtReplace.Parent = @This
		
		chkMatchCase.NAME = "chkMatchCase"
		chkMatchCase.Caption = ML("Match Case")
		chkMatchCase.SetBounds 285, 1, 88, 20
		chkMatchCase.Text = ML("Match Case")
		chkMatchCase.Parent = @THIS        
		
		' chkSelection
		chkSelection.NAME = "chkSelection"
		chkSelection.Caption = ML("Selected")
		chkSelection.Text = ML("Selected")
		chkSelection.SetBounds 285, 18, 82, 18
		chkSelection.Parent = @This
		
		' btnFind
		btnFind.Caption = ">"
		btnFind.Default = True
		btnFind.SetBounds 406, 6, 28, 26
		btnFind.Parent = @THIS        
		
		' btnFindPrev
		btnFindPrev.NAME = "btnFindPrev"
		btnFindPrev.Text = "<"
		btnFindPrev.SetBounds 378, 6, 28, 26
		btnFindPrev.Caption = "<"
		btnFindPrev.Parent = @THIS        
		
		' btnCancel    
		btnCancel.Caption = ML("&Cancel")
		btnCancel.Anchor.RIGHT = asAnchor
		btnCancel.SetBounds 250, 500, 100, 26
		btnCancel.Parent = @THIS        
		
		btnFind.OnClick = @_btnFind_Click_
		btnFindPrev.OnClick = @_btnFindPrev_Click_        
		btnCancel.OnClick = @_btnCancel_Click_   
		
		' lblTrack
		lblTrack.NAME = "lblTrack"
		lblTrack.Text = "80"
		lblTrack.SetBounds 473, 4, 18, 14
		lblTrack.Caption = "80"
		lblTrack.Parent = @THIS        
		
		' TrackBar1
		TrackBar1.NAME = "TrackBar1"
		TrackBar1.Text = "TrackBar1"
		TrackBar1.OnChange = @TrackBar1_Change
		TrackBar1.MinValue = 20
		TrackBar1.MaxValue = 255        
		TrackBar1.Style = 1
		TrackBar1.SetBounds 470, 18, 22, 12
		TrackBar1.Position = 200 ' This.Opacity       
		TrackBar1.Parent = @This
		
		' lblReplace
		lblReplace.NAME = "lblReplace"
		lblReplace.Text = ML("Replace") & ":"
		lblReplace.SetBounds 5, 42, 50, 14
		lblReplace.Caption = ML("Replace") & ":"
		lblReplace.Parent = @THIS               
		
		' btnReplace
		btnReplace.NAME = "btnReplace"
		btnReplace.Text = "Replace"
		btnReplace.SetBounds 284, 36, 92, 26
		btnReplace.Caption = "Replace"
		btnReplace.Parent = @THIS        
		
		' btnReplaceAll
		btnReplaceAll.NAME = "btnReplaceAll"
		btnReplaceAll.Text = "Replace All"
		btnReplaceAll.SetBounds 378, 36, 84, 26
		btnReplaceAll.Caption = "Replace All"
		btnReplaceAll.Parent = @THIS        
		
		' btnReplaceShow
		btnReplaceShow.NAME = "btnReplaceShow"
		btnReplaceShow.Text = ">"
		btnReplaceShow.SetBounds 0, 6, 18, 20
		btnReplaceShow.Caption = ">"
		btnReplaceShow.Parent = @THIS        
		
		btnReplace.OnClick = @_btnReplace_Click_        
		btnReplaceAll.OnClick = @_btnReplaceAll_Click_ 
		btnReplaceShow.OnClick = @_btnReplaceShow_Click_ 
		
		THIS.SetBounds 0, 0, 503, 98
		THIS.Opacity = 140
		THIS.Caption = ML("Find")
		THIS.DefaultButton = @btnFind
		#IfNDef __USE_GTK__
			THIS.BorderStyle = FormBorderStyle.FixedDialog
		#EndIf
		THIS.MinimizeBox = false
		THIS.MaximizeBox = false
		This.OnCreate = @Form_Create
		THIS.CancelButton = @btnCancel       
		
		OnShow = @_Form_Show_
		OnClose = @_Form_Close_       
		
		' btnFindAll
		btnFindAll.Name = "btnFindAll"
		btnFindAll.Text = "All"
		btnFindAll.SetBounds 434, 6, 28, 26
		btnFindAll.Caption = "All"
		btnFindAll.OnClick = @btnFindAll_Click
		btnFindAll.Parent = @This
	END Constructor
	
	DESTRUCTOR frmFind
		
	END Destructor
'#End Region

PUBLIC FUNCTION frmFind.Find(Down AS BOOLEAN, bNotShowResults AS BOOLEAN = FALSE) AS Integer
	IF txtFind.Text = "" THEN EXIT Function
	DIM tb AS TabWindow PTR = CAST(TabWindow PTR, ptabCode->SelectedTab)
	IF tb = 0 THEN EXIT Function
	DIM txt AS EditControl PTR = @tb->txtCode
	DIM Result AS Integer
	DIM bMatchCase AS BOOLEAN = chkMatchCase.Checked
	DIM bSelection AS BOOLEAN = chkSelection.Checked
	DIM buff AS WSTRING Ptr
	STATIC Search AS WSTRING PTR 
	DIM iStartChar AS INTEGER, iStartLine AS INTEGER
	DIM i AS INTEGER
	
	IF WGet(search) <> txtFind.Text then
		wLet search, txtFind.Text
		FindAll True
	END if
	IF Down Then
		IF bNotShowResults Then
			iStartChar = 1
			iStartLine = 0
		Else
			DIM AS INTEGER iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
			txt->GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
			iStartChar = iSelEndChar + 1
			iStartLine = iSelEndLine
		END IF        
		FOR i = iStartLine TO txt->LinesCount - 1
			buff = @txt->Lines(i)
			IF bMatchCase Then
				Result = INSTR(iStartChar, *buff, *search)
			Else
				Result = INSTR(iStartChar, LCASE(*buff), LCASE(*search))
			END if
			IF Result > 0 THEN EXIT For
			iStartChar = 1
		NEXT i
	Else
		IF bNotShowResults Then
			iStartLine = txt->LinesCount - 1
			iStartChar = LEN(txt->Lines(iStartLine))
		Else
			DIM AS INTEGER iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
			txt->GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
			iStartLine = iSelStartLine
			iStartChar = iSelStartChar
		END If
		FOR i = iStartLine TO 0 STEP -1
			buff = @txt->Lines(i)
			IF i <> iStartLine THEN iStartChar = LEN(*buff)
			IF bMatchCase Then
				Result = INSTRREV(*buff, *search, iStartChar)
			Else
				Result = INSTRREV(LCASE(*buff), LCASE(*search), iStartChar)
			END if
			IF Result > 0 THEN EXIT For
		NEXT i
	END If
	IF Result <> 0 Then
		txt->SetSelection i, i, Result - 1, Result + LEN(*search) - 1
		IF txtFind.Contains(*search)=FALSE THEN txtFind.AddItem *search          
		THIS.Caption=ML("Find")+": "+ WSTR(mFindResultList.IndexOf(WSTR("L"+WSTR(i+1)+"C"+WSTR(Result)))+1)+ " of "+WSTR(mFindResultList.Count)        
	ELSEIF bNotShowResults Then
		RETURN Result
	Else
		'If MessageBox(btnFind.Handle, @WStr("Izlash oxiriga yetdi, qaytadan izlashni xohlaysizmi?"), @WStr("Izlash"), MB_YESNO) = IDYES Then
		'If MsgBox("Izlash oxiriga yetdi, qaytadan izlashni xohlaysizmi?", "Izlash", MB_YESNO) = IDYES Then
		Result = Find(Down, TRUE)
		IF Result = 0 Then
			'ShowMessage("Izlanayotgan matn topilmadi!")
			THIS.Caption="Find: No Results"  
		END If
		'End If
	END IF         
	txtFind.SetFocus
	RETURN Result
END Function

PRIVATE SUB frmFind.btnFind_Click(BYREF Sender AS Control)    
	Find TRUE,False
END Sub
PRIVATE SUB frmFind.btnFindPrev_Click(BYREF Sender AS Control)    
	Find FALSE,FALSE
END Sub
PRIVATE FUNCTION frmFind.FindAll(bNotShowResults As Boolean = False) AS INTEGER     
	IF LEN(txtFind.Text)<1 THEN        
		mFindResultList.Clear
		ptabBottom->Tabs[2]->Caption = ML("Find") 
		plvSearch->ListItems.Clear
		THIS.Caption="Find: No Results"
		RETURN -1
	END if
	DIM tb AS TabWindow PTR = CAST(TabWindow PTR, ptabCode->SelectedTab)
	IF tb = 0 THEN RETURN -1
	DIM bMatchCase AS BOOLEAN = chkMatchCase.Checked
	DIM bSelection AS BOOLEAN = chkSelection.Checked
	DIM AS WSTRING PTR buff   
	DIM Search AS WSTRING PTR =@txtFind.Text    
	DIM AS INTEGER Pos1=0         
	
	plvSearch->ListItems.Clear
	plvSearch->Text = *search
	mFindResultList.Clear
	FOR i AS INTEGER = 0 TO tb->txtCode.LinesCount - 1
		buff = @tb->txtCode.Lines(i)        
		IF bMatchCase Then
			Pos1 = INSTR(*buff, *search)
		Else
			Pos1 = INSTR(LCASE(*buff), LCASE(*search))
		END If
		WHILE Pos1 > 0              
			mFindResultList.ADD WSTR("L"+WSTR(i+1)+"C"+WSTR(Pos1))
			'print "L C ",WStr("L"+Wstr(i+1)+"C"+Wstr(Pos1))
			If Not bNotShowResults Then
				plvSearch->ListItems.ADD *buff
				plvSearch->ListItems.Item(plvSearch->ListItems.Count - 1)->Text(1) = WSTR(i + 1)
				plvSearch->ListItems.Item(plvSearch->ListItems.Count - 1)->Text(2) = WSTR(Pos1)
				plvSearch->ListItems.Item(plvSearch->ListItems.Count - 1)->Text(3) = tb->FileName
				plvSearch->ListItems.Item(plvSearch->ListItems.Count - 1)->Tag = tb
			End If
			IF bMatchCase Then
				Pos1 = INSTR(Pos1 + 1, *buff, *search)
			Else
				Pos1 = INSTR(Pos1 + 1, LCASE(*buff), LCASE(*search))
			END If
		WEND          
	NEXT i
	If Not bNotShowResults Then
		ptabBottom->TabIndex = 2
		ptabBottom->Tabs[2]->Caption = ML("Find") & " (" & plvSearch->ListItems.Count & " " & ML("Pos") & ")"
	End If
	RETURN plvSearch->ListItems.Count
END FUNCTION

PRIVATE SUB frmFind.btnReplace_Click(BYREF Sender AS Control)
	IF LEN(txtFind.Text)<1 OR LEN(txtReplace.Text)<1 THEN EXIT SUB        
	DIM tb AS TabWindow PTR = CAST(TabWindow PTR, ptabCode->SelectedTab)
	IF tb = 0 THEN EXIT Sub
	DIM txt AS EditControl PTR = @tb->txtCode
	IF LCASE(txt->SelText) = LCASE(txtFind.Text) Then
		txt->SelText = txtReplace.Text
		Find TRUE,FALSE 
		IF txtReplace.Contains(txtReplace.Text)=FALSE THEN txtReplace.AddItem txtReplace.Text
	Else
		Find TRUE,FALSE   
	END If
END Sub

Private Sub frmFind.btnReplaceAll_Click(ByRef Sender As Control)
	If Len(txtFind.Text)<1 Then Exit Sub        
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	Dim txt As EditControl Ptr = @tb->txtCode
	Dim Result As Boolean
	
	Dim bMatchCase As Boolean = chkMatchCase.Checked
	Dim bSelection As Boolean = chkSelection.Checked
	Dim As WString Ptr buff   
	Dim Search As WString Ptr =@txtFind.Text    
	Dim As Integer Pos1 = 0, l = Len(txtReplace.Text)
	Dim As EditControlLine Ptr ECLine
	tb->txtCode.Changing "ReplaceAll"
	For i As Integer = 0 To tb->txtCode.LinesCount - 1
		buff = @tb->txtCode.Lines(i)
		ECLine = tb->txtCode.FLines.Items[i]
		If bMatchCase Then
			Pos1 = InStr(*buff, *search)
		Else
			Pos1 = InStr(LCase(*buff), LCase(*search))
		End If
		While Pos1 > 0
			WLet ECLine->Text, Left(*buff, Pos1 - 1) & txtReplace.Text & Mid(*buff, Pos1 + Len(*search))
			buff = @tb->txtCode.Lines(i)
			If bMatchCase Then
				Pos1 = InStr(Pos1 + l, *buff, *search)
			Else
				Pos1 = InStr(Pos1 + l, LCase(*buff), LCase(*search))
			End If
		Wend          
	Next i   
	tb->txtCode.Changed "ReplaceAll"
	If Not txtFind.Contains(txtFind.Text) Then txtFind.AddItem txtFind.Text
	If Not txtReplace.Contains(txtReplace.Text) Then txtReplace.AddItem txtReplace.Text
	txtFind.SetFocus
End Sub
Private Sub frmFind.btnReplaceShow_Click(ByRef Sender As Control)
	'Sender.Center
	mFormFind=Not mFormFind
	If mFormFind=True Then 
		'fFind.SetBounds fFind.LEFT,fFind.TOP,fFind.WIDTH,65
		#ifdef __USE_GTK__
			fFind.Height = 55
		#else
			fFind.Height = 65
		#endif
		TrackBar1.SetBounds TrackBar1.Left, TrackBar1.Top, TrackBar1.Width, 12
	Else 
		'fFind.SetBounds fFind.LEFT,fFind.TOP,fFind.WIDTH,95
		fFind.Height = 95
		TrackBar1.SetBounds TrackBar1.Left, TrackBar1.Top, TrackBar1.Width, 42
	End If
	fFind.btnReplaceShow.Caption=IIf(mFormFind,">","<") 
	txtFind.SetFocus
End Sub
Private Sub frmFind.btnCancel_Click(ByRef Sender As Control)
	This.CloseForm
End Sub

Private Sub frmFind.Form_Show(ByRef Sender As Form)
	'Sender.Center
	If mFormFind=True Then 
		#ifdef __USE_GTK__
			fFind.SetBounds fFind.Parent->Left + fFind.Parent->WIDTH-fFind.WIDTH - 5, fFind.Parent->TOP+20,fFind.WIDTH, 56
		#else
			fFind.SetBounds fFind.Parent->Left + fFind.Parent->WIDTH-fFind.WIDTH - 5, fFind.Parent->TOP+20,fFind.WIDTH, 65
		#endif
	Else 
		fFind.SetBounds fFind.Parent->Left + fFind.Parent->WIDTH-fFind.WIDTH - 5, fFind.Parent->TOP+20, fFind.WIDTH, 95
	End If  
	
	'if FileExists(ExePath + "/Templates/Find.dat") Then txtFind.LoadFromFile ExePath + "/Templates/Find.dat"
	'if FileExists(ExePath + "/Templates/Replace.dat") Then txtReplace.LoadFromFile ExePath + "/Templates/Replace.dat"
	txtFind.Text = pClipboard->GetAsText
	txtFind.SetFocus
End Sub

Private Sub frmFind.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	
	'txtFind.SaveToFile ExePath + "/Templates/Find.dat"   
	'txtReplace.SaveToFile ExePath + "/Templates/Replace.dat" 
	Dim iCount As Integer=-1
	If txtFind.ItemCount>0 Then
		For i As Integer =txtFind.ItemCount-1 To 0 Step -1
			iCount+=1
			piniSettings->WriteString("Find", "Find_"+WStr(iCount), txtFind.Item(i))       
			If iCount>=9 Then Exit For
		Next
	End If
	If txtReplace.ItemCount>0 Then
		iCount=-1
		For i As Integer =txtReplace.ItemCount-1 To 0 Step -1
			iCount+=1
			piniSettings->WriteString("Replace", "Replace_"+WStr(iCount), txtReplace.Item(i))       
			If iCount>=9 Then Exit For
		Next 
	End If
End Sub

Private Sub frmFind.TrackBar1_Change(ByRef Sender As TrackBar,Position As Integer)
	fFind.Opacity = Sender.Position
	fFind.lblTrack.Text = WStr(CUInt(Sender.Position/2.55))
End Sub

Private Sub frmFind.btnFindAll_Click(ByRef Sender As Control)
	pfFind->FindAll
End Sub

Private Sub frmFind.Form_Create(ByRef Sender As Control)
	'fFind.BringToFront()
	With fFind
		Dim tmpStr As WString Ptr
		For i As Integer =0 To 9
			WLet tmpStr, piniSettings->ReadString("Find", "Find_"+WStr(i), "")
			If CInt(Trim(*tmpstr)<>"") Then .txtFind.AddItem *tmpstr       
		Next 
		For i As Integer =0 To 9
			WLet tmpStr, piniSettings->ReadString("Replace", "Replace_"+WStr(i), "")
			If CInt(Trim(*tmpstr)<>"") Then .txtReplace.AddItem *tmpstr
		Next
		WDeallocate tmpstr
	End With
End Sub
