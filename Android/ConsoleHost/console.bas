'#########################################################
'#  console.bas                                          #
'#  This file is part of VisualFBEditor                  #
'#########################################################

'The console of the Android IDE (ConsoleHost, mffActivity.java): the input and the output of the program are the
'pipes of the app. The server links this module with the program (Compile of Main.bas, WebCompileAndroidConsole):
'its isatty is taken instead of the one of the C library, so the program sees them as a terminal and not as
'redirected files (Input shows its prompt; the console shows the line which it sends)
Extern "C"
	Function isatty(ByVal fd As Long) As Long
		Return IIf(fd >= 0 AndAlso fd <= 2, 1, 0)
	End Function
End Extern
