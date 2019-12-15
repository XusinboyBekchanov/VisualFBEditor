'#Compile -exx "Form1.rc"
#Include Once "mff/Form.bi"
#Include Once "mff/Label.bi"
#Include Once "mff/TextBox.bi"
#Include Once "mff/CommandButton.bi"

Using My.Sys.Forms

'#Region "Form"
	Type frmTheme Extends Form
		Declare Static Sub cmdOK_Click(ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Constructor
		
		Dim As Label lblThemeName
		Dim As TextBox txtThemeName
		Dim As CommandButton cmdOK, cmdCancel
	End Type
	
	Common Shared pfTheme As frmTheme Ptr
'#End Region

#IfNDef __USE_MAKE__
	#Include Once "frmTheme.bas"
#EndIf
