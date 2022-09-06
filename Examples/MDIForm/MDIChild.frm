'#Region "Form"
	#if defined(__FB_WIN32__) AndAlso defined(__FB_MAIN__)
		#cmdline "Form1.rc"
	#endif
	#include once "mff/Form.bi"
	#include once "mff/TextBox.bi"
	
	Using My.Sys.Forms
	
	Type MDIChildType Extends Form
		Declare Static Sub _Form_Destroy(ByRef Sender As Control)
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Static Sub _Form_Activate(ByRef Sender As Form)
		Declare Sub Form_Activate(ByRef Sender As Form)
		Declare Constructor
		
		Dim As TextBox TextBox1
	End Type
	
	Constructor MDIChildType
		'MDIChild
		With This
			.Name = "MDIChild"
			.Text = "MDIChild"
			.Designer = @This
			.FormStyle = FormStyles.fsMDIChild
			.Caption = "MDIChild"
			.OnDestroy = @_Form_Destroy
			.OnActivate = @_Form_Activate
			.SetBounds 0, 0, 260, 190
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = ""
			.TabIndex = 0
			.Multiline = True
			.ScrollBars = ScrollBarsType.Both
			.Align = DockStyle.alClient
			.SetBounds 0, 0, 244, 151
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Private Sub MDIChildType._Form_Activate(ByRef Sender As Form)
		*Cast(MDIChildType Ptr, Sender.Designer).Form_Activate(Sender)
	End Sub
	
	Private Sub MDIChildType._Form_Destroy(ByRef Sender As Control)
		*Cast(MDIChildType Ptr, Sender.Designer).Form_Destroy(Sender)
	End Sub
	
	Dim Shared MDIChild As MDIChildType
	
	#ifdef __FB_MAIN__
		MDIChild.Show
		
		App.Run
	#endif
'#End Region

Private Sub MDIChildType.Form_Destroy(ByRef Sender As Control)
	MDIMain.MDIChildDestroy(@This)
End Sub

Private Sub MDIChildType.Form_Activate(ByRef Sender As Form)
	MDIMain.MDIChildActivate(@This)
End Sub
