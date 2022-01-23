#ifdef __FB_WIN32__
	'#Compile "Form1.rc"
#endif
Dim Shared  As WString Ptr BuffTips(Any)
'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/Label.bi"
	
	Using My.Sys.Forms
	
	Type frmTipOfDayType Extends Form
		Declare Static Sub cmdClose_Click_(ByRef Sender As Control)
		Declare Sub cmdClose_Click(ByRef Sender As Control)
		Declare Static Sub Form_Show_(ByRef Sender As Form)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Static Sub cmdPreviousTip_Click_(ByRef Sender As Control)
		Declare Sub cmdPreviousTip_Click(ByRef Sender As Control)
		Declare Static Sub chkDoNotShow_Click_(ByRef Sender As CheckBox)
		Declare Sub chkDoNotShow_Click(ByRef Sender As CheckBox)
		Declare Static Sub cmdNextTip_Click_(ByRef Sender As Control)
		Declare Sub cmdNextTip_Click(ByRef Sender As Control)
		Declare Constructor
		
		Dim As CommandButton cmdPreviousTip, cmdNextTip, cmdClose
		Dim As CheckBox chkDoNotShow
		Dim As Label lblTips
		Dim As ImageBox lblImage
	End Type
	
	Dim Shared frmTipOfDay As frmTipOfDayType
	Common Shared As frmTipOfDayType Ptr pfTipOfDay
	pfTipOfDay = @frmTipOfDay
	
	Constructor frmTipOfDayType
		' frmTipOfDay
		With This
			.Name = "frmTipOfDay"
			.Text = ML("Tip of the Day")
			This.BorderStyle = FormBorderStyle.FixedDialog
			This.MaximizeBox = False
			This.MinimizeBox = False
			This.StartPosition = FormStartPosition.CenterParent
			.Designer = @This
			#ifndef __USE_GTK__
				.DefaultButton = @cmdClose
				.CancelButton = @cmdClose
			#endif
			.OnShow = @Form_Show_
			.SetBounds 0, 0, 540, 350
		End With
		' cmdPreviousTip
		With cmdPreviousTip
			.Name = "cmdPreviousTip"
			.Text = ML("Previous Tip")
			.TabIndex = 0
			.SetBounds 220, 280, 90, 24
			.Designer = @This
			.OnClick = @cmdPreviousTip_Click_
			.Parent = @This
		End With
		' cmdNextTip
		With cmdNextTip
			.Name = "cmdNextTip"
			.Text = ML("Next Tip")
			.TabIndex = 1
			.SetBounds 320, 280, 90, 24
			.Designer = @This
			.OnClick = @cmdNextTip_Click_
			.Parent = @This
		End With
		' cmdClose
		With cmdClose
			.Name = "cmdClose"
			.Text = ML("Close")
			.TabIndex = 2
			.SetBounds 420, 280, 90, 24
			.Designer = @This
			.OnClick = @cmdClose_Click_
			.Parent = @This
		End With
		' chkDoNotShow
		With chkDoNotShow
			.Name = "chkDoNotShow"
			.Text = ML("Don't show tips")
			.TabIndex = 3
			.SetBounds 20, 282, 180, 20
			.Designer = @This
			.OnClick = @chkDoNotShow_Click_
			.Parent = @This
		End With
		' lblTips
		With lblTips
			.Name = "lblTips"
			.Text = "Input Tips here"
			.TabIndex = 4
			.Font.Size = 10
			.SetBounds 20, 10, 480, 70
			.Designer = @This
			.Parent = @This
		End With
		' lblImage
		With lblImage
			.Name = "lblImage"
			.Text = "lblImage"
			.SetBounds 38, 86, 450, 180
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Private Sub frmTipOfDayType.cmdNextTip_Click_(ByRef Sender As Control)
		*Cast(frmTipOfDayType Ptr, Sender.Designer).cmdNextTip_Click(Sender)
	End Sub
	
	Private Sub frmTipOfDayType.chkDoNotShow_Click_(ByRef Sender As CheckBox)
		*Cast(frmTipOfDayType Ptr, Sender.Designer).chkDoNotShow_Click(Sender)
	End Sub
	
	Private Sub frmTipOfDayType.cmdPreviousTip_Click_(ByRef Sender As Control)
		*Cast(frmTipOfDayType Ptr, Sender.Designer).cmdPreviousTip_Click(Sender)
	End Sub
	
	Private Sub frmTipOfDayType.Form_Show_(ByRef Sender As Form)
		*Cast(frmTipOfDayType Ptr, Sender.Designer).Form_Show(Sender)
	End Sub
	
	Private Sub frmTipOfDayType.cmdClose_Click_(ByRef Sender As Control)
		*Cast(frmTipOfDayType Ptr, Sender.Designer).cmdClose_Click(Sender)
	End Sub
	
	#ifndef _NOT_AUTORUN_FORMS_
		#define _NOT_AUTORUN_FORMS_
		
		frmTipOfDay.Show
		
		App.Run
	#endif
'#End Region


Private Sub frmTipOfDayType.cmdClose_Click(ByRef Sender As Control)
	Cast(frmTipOfDayType Ptr, Sender.Parent)->CloseForm
	For i As Integer = 0 To UBound(BuffTips)
		Deallocate BuffTips(i)
	Next
	Erase BuffTips
	ShowTipoftheDay = Not chkDoNotShow.Checked
End Sub

Private Sub frmTipOfDayType.Form_Show(ByRef Sender As Form)
	Dim As Integer Fn = FreeFile_, Result = -1, i = 0
	Dim Buff As WString * 1024
	Dim As WString * MAX_Path FileName = ExePath & "/Help/Tip of the Day/" & CurLanguage & ".tip"
	Result = Open(FileName For Input Encoding "utf-8" As #Fn)
	If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-16" As #Fn)
	If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-32" As #Fn)
	If Result <> 0 Then Result = Open(FileName For Input As #Fn)
	If Result = 0 Then
		Do Until EOF(Fn)
			Line Input #Fn, Buff
			Buff = Replace(Buff, "<br>", Chr(13, 10))
			ReDim Preserve BuffTips(i)
			wLet BuffTips(i), Buff
			i += 1
		Loop
		CloseFile_(Fn)
		If ShowTipoftheDayIndex < i AndAlso ShowTipoftheDayIndex >= 0 Then lblTips.Text = *BuffTips(ShowTipoftheDayIndex)
		Dim As WString * MAX_PATH imageFileName = ExePath & "/Help/Tip of the Day/images/" & ShowTipoftheDayIndex & ".png"
		If Dir(imageFileName) <> "" Then lblImage.Graphic.LoadFromFile(imageFileName, lblImage.Width, lblImage.Height)
	Else
		Msgbox ML("File") & " """ & GetOSPath(ExePath & "Help/Tip of the Day/") & CurLanguage & ".tip"" " & ML("not found!")
	End If
	chkDoNotShow.Checked = Not ShowTipoftheDay 
End Sub

Private Sub frmTipOfDayType.chkDoNotShow_Click(ByRef Sender As CheckBox)
	
End Sub

Private Sub frmTipOfDayType.cmdPreviousTip_Click(ByRef Sender As Control)
	ShowTipoftheDayIndex -= 1
	If ShowTipoftheDayIndex < 0 Then ShowTipoftheDayIndex = UBound(BuffTips)
	Dim As WString * MAX_PATH imageFileName = ExePath & "/Help/Tip of the Day/images/" & ShowTipoftheDayIndex & ".png"
	If Dir(imageFileName) <> "" Then lblImage.Graphic.LoadFromFile(imageFileName, lblImage.Width, lblImage.Height)
	lblTips.Text = *BuffTips(ShowTipoftheDayIndex)
	
End Sub

Private Sub frmTipOfDayType.cmdNextTip_Click(ByRef Sender As Control)
	ShowTipoftheDayIndex += 1
	If ShowTipoftheDayIndex > UBound(BuffTips) Then ShowTipoftheDayIndex = 0
	Dim As WString * MAX_PATH imageFileName = ExePath & "/Help/Tip of the Day/images/" & ShowTipoftheDayIndex & ".png"
	If Dir(imageFileName) <> "" Then lblImage.Graphic.LoadFromFile(imageFileName, lblImage.Width, lblImage.Height)
	lblTips.Text = *BuffTips(ShowTipoftheDayIndex)
	
End Sub

