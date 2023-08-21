'#Compile -exx "Form1.rc"
#include once "mff/Form.bi"
#include once "mff/CheckBox.bi"
#include once "mff/Label.bi"

Using My.Sys.Forms

'#Region "Form"
	Type frmAdvancedOptions Extends Form
		Declare Static Sub cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdOK_Click(ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Constructor
		
		Dim As CheckBox chkShowUnusedLabelWarnings, chkShowUnusedFunctionWarnings, chkShowUnusedVariableWarnings, chkShowUnusedButSetVariableWarnings, chkShowMainWarnings
		Dim As Label Label1
		Dim As Panel pnlCommands
		Dim As CommandButton cmdOK, cmdCancel
		Dim As TreeNode Ptr ProjectTreeNode
	End Type
	
	Common Shared pfAdvancedOptions As frmAdvancedOptions Ptr
'#End Region

#ifndef __USE_MAKE__
	#include once "frmAdvancedOptions.frm"
#endif
