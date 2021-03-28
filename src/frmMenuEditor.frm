#include once "frmMenuEditor.bi"

'#Region "Form"
	Constructor frmMenuEditor
		' frmMenuEditor
		With This
			.Name = "frmMenuEditor"
			.Text = ML("Menu Editor")
			.Name = "frmMenuEditor"
			.Caption = ML("Menu Editor")
			.SetBounds 0, 0, 850, 460
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = "TextBox1"
			.TabIndex = 0
			.SetBounds 2, 2, 70, 24
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared fMenuEditor As frmMenuEditor
	pfMenuEditor = @fMenuEditor
'#End Region
