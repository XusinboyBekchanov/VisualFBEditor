#IfDef __FB_Win32__
	'#Compile -exx -s gui "Example.rc"
#Else
	'#Compile -exx
#EndIf
#Include "mff/Form.bi"
#Include "mff/CommandButton.bi"

Using My.Sys.Forms

Dim Shared frm As Form, cmd As CommandButton

Sub cmd_Click(ByRef Sender As Control)
   MsgBox "Hello"
End Sub

cmd.Text = "Click me!"
cmd.SetBounds 100, 100, 150, 30
cmd.OnClick = @cmd_Click
frm.Add @cmd

frm.Center
frm.Show

App.Run
