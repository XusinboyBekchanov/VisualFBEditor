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
		This.Text = "Visual FB Editor"
		#ifdef __USE_GTK__
			This.Icon.LoadFromFile(ExePath & "/Resources/VisualFBEditor.ico")
		#else
			This.Icon.LoadFromResourceID(1)
		#endif
		This.Cursor = crWait
		This.BackColor = 0
		This.SetBounds 0, 0, 412, 396
		This.BorderStyle = 0
		This.StartPosition = FormStartPosition.CenterParent
		' lblImage
		lblImage.Name = "lblImage"
		'lblImage.Graphic.Bitmap.LoadFromResourceName("Logo")
		#ifdef __USE_GTK__
			lblImage.Graphic.LoadFromFile(ExePath & "/Resources/Logo.png")
		#else
			lblImage.Graphic = "Logo"
		#endif
		lblImage.SetBounds 36, 66, 343, 270
		lblImage.CenterImage = True
		lblImage.Designer = @This
		lblImage.OnClick = @lblImage_Click_
		lblImage.BackColor = 0
		lblImage.Parent = @This
		' lblSplash
		lblSplash.SetBounds 8, 14, 398, 33
		lblSplash.Text = "Visual FB Editor" & " " & pApp->GetVerInfo("ProductVersion")
		#if defined(__USE_GTK__) AndAlso defined(__FB_WIN32__)
			lblSplash.Font.Name = "Sans"
		#else
			lblSplash.Font.Name = "Times New Roman"
		#endif
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
		lblInfo.Text = "2018-2022"
		lblInfo.SetBounds 18, 332, 52, 17
		lblInfo.BackColor = 0
		lblInfo.Font.Color = 16777215
		lblInfo.Font.Size = 8
		lblInfo.Parent = @This
		' lblProcess
		With lblProcess
			.Name = "lblProcess"
			.Text = ""
			.SetBounds 18, 356, 380, 30
			.BackColor = 0
			.Font.Color = 16777215
			.Font.Size = 8
			.Parent = @This
		End With
		' lblSplash1
		With lblSplash1
			.Name = "lblSplash1"
			#ifdef __FB_64BIT__
				.Text = ML("64-bit")
			#else
				.Text = ML("32-bit")
			#endif
			.TabIndex = 3
			.Alignment = AlignmentConstants.taCenter
			.BackColor = 0
			.Font.Size = 12
			.Font.Bold = True
			#if defined(__USE_GTK__) AndAlso defined(__FB_WIN32__)
				.Font.Name = "Sans"
			#else
				.Font.Name = "Times New Roman"
			#endif
			.Font.Color = 16777215
			.SetBounds 16, 54, 382, 17
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
	(*Cast(frmSplash Ptr, Sender.Designer)).lblImage_Click(Sender)
End Sub
Private Sub frmSplash.lblImage_Click(ByRef Sender As Control)
	Me.CloseForm
End Sub
 
