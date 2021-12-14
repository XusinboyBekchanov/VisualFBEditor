'#########################################################
'#  frmSplash.bas                                        #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (2018-2020)              #
'#########################################################

#include once "frmSplash.bi"
#include once "mff/Application.bi"

Using My.Sys.Forms

'#Region "Form"
	Constructor frmSplash
		This.Text = "Visual freeBasic Editor"
		#ifdef __USE_GTK__
			This.Icon.LoadFromFile(ExePath & "/Resources/VisualFBEditor.ico")
		#else
			This.Icon.LoadFromResourceID(1)
		#endif
		This.BackColor = 0
		This.SetBounds  0, 0, 362, 336
		This.BorderStyle = 0
		This.StartPosition = FormStartPosition.CenterScreen
		' lblImage
		lblImage.Name = "lblImage"
		'lblImage.Graphic.Bitmap.LoadFromResourceName("Logo")
		#ifdef __USE_GTK__
			lblImage.Graphic.Bitmap.LoadFromFile(ExePath & "/Resources/Logo.png")
		#else
			lblImage.Graphic.Bitmap = "Logo"
		#endif
		lblImage.SetBounds  6, 56, 343, 270
		lblImage.CenterImage = True
		lblImage.Designer = @This
		lblImage.OnClick = @lblImage_Click_
		lblImage.BackColor = 0
		lblImage.Parent = @This
		' lblSplash
		lblSplash.SetBounds 8, 14, 348, 33
		lblSplash.Text = "Visual freeBasic Editor"
		lblSplash.Font.Name = "Times New Roman"
		lblSplash.Font.Size = 20
		lblSplash.Font.Bold = True
		lblSplash.Font.Italic = True
		lblSplash.Alignment = AlignmentConstants.taCenter
		lblSplash.BackColor = 0
		lblSplash.Font.Color = 16777215
		lblSplash.Align = DockStyle.alNone
		lblSplash.ID = 1004
		lblSplash.Parent = @This
		
		'lblIcon.Graphic.Icon = 100
		' lblInfo
		lblInfo.Name = "lblInfo"
		lblInfo.Text = "2018-2021"
		lblInfo.SetBounds 18, 282, 52, 17
		lblInfo.BackColor = 0
		lblInfo.Font.Color = 16777215
		lblInfo.Font.Size = 8
		lblInfo.Parent = @This
		' lblProcess
		With lblProcess
			.Name = "lblProcess"
			.Text = ""
			.SetBounds  18, 306, 430, 30
			.BackColor = 0
			.Font.Color = 16777215
			.Font.Size = 8
			.Parent = @This
		End With
		' lblSplash1
		With lblSplash1
			.Name = "lblSplash1"
			.Text = "lblSplash1"
			.TabIndex = 3
			.Alignment = AlignmentConstants.taCenter
			.BackColor = 0
			.Font.Size = 12
			.Font.Bold = True
			.Font.Name = "Times New Roman"
			.Font.Color = 16777215
			.SetBounds 16, 54, 332, 17
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared fSplash As frmSplash
	pfSplash = @fSplash
'#End Region

#ifndef _NOT_AUTORUN_FORMS_
	fSplash.Show
	pApp->Run
#endif

Private Sub frmSplash.lblImage_Click_(ByRef Sender As Control)
	*Cast(frmSplash Ptr, Sender.Designer).lblImage_Click(Sender)
End Sub
Private Sub frmSplash.lblImage_Click(ByRef Sender As Control)
	Me.CloseForm
End Sub
 
