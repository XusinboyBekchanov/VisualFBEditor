[TOC]
## Definition

`ConsoleType` - This Console class provides some methods and properties using which we can implement the user interface in a console application.

## Properties
|Name|Description|
| :------------ | :------------ |
|[`BackColor`]("ConsoleType.BackColor.md")|Background color value range: 0 - 15|
|[`BufferHeight`]("ConsoleType.BufferHeight.md")|Buffer height|
|[`BufferWidth`]("ConsoleType.BufferWidth.md")|Buffer width|
|[`ConsoleWindow`]("ConsoleType.ConsoleWindow.md")|Window handles related to the console|
|[`CursorCol`]("ConsoleType.CursorCol.md")|The column where the cursor is located|
|[`CursorRow`]("ConsoleType.CursorRow.md")|The line where the cursor is located|
|[`CursorSize`]("ConsoleType.CursorSize.md")|Cursor size Value range: 1 - 100|
|[`CursorVisable`]("ConsoleType.CursorVisable.md")|Whether the cursor is visible|
|[`Font`]("ConsoleType.Font.md")|Font Change the font name and size|
|[`ForeColor`]("ConsoleType.ForeColor.md")|Foreground color value range: 0 - 15|
|[`FullScreen`]("ConsoleType.FullScreen.md")|Whether or not it is full-screen|
|[`InputCodePage`]("ConsoleType.InputCodePage.md")|Enter the code page|
|[`InputModeEcho`]("ConsoleType.InputModeEcho.md")|Input mode: ENABLE_ECHO_INPUT|
|[`InputModeInsert`]("ConsoleType.InputModeInsert.md")|Input mode:ENABLE_INSERT_MODE|
|[`InputModeLine`]("ConsoleType.InputModeLine.md")|Input mode:ENABLE_LINE_INPUT|
|[`InputModeMouse`]("ConsoleType.InputModeMouse.md")|Input mode:ENABLE_MOUSE_INPUT|
|[`InputModeProcessed`]("ConsoleType.InputModeProcessed.md")|Input mode:ENABLE_PROCESSED_INPUT|
|[`InputModeQuickEdit`]("ConsoleType.InputModeQuickEdit.md")|Input mode:ENABLE_QUICK_EDIT_MODE|
|[`InputModeWindow`]("ConsoleType.InputModeWindow.md")|Input mode:ENABLE_WINDOW_INPUT|
|[`OutputCodePage`]("ConsoleType.OutputCodePage.md")|Output code page|
|[`OutputModeProcessed`]("ConsoleType.OutputModeProcessed.md")|Output mode: ENABLE_PROCESSED_OUTPUT|
|[`OutputModeWrapAtEol`]("ConsoleType.OutputModeWrapAtEol.md")|Output mode: ENABLE_WRAP_AT_EOL_OUTPUT|
|[`StdErr`]("ConsoleType.StdErr.md")|Standard error handles|
|[`StdIn`]("ConsoleType.StdIn.md")|Standard input handles|
|[`StdOut`]("ConsoleType.StdOut.md")|Standard output handle|
|[`Title`]("ConsoleType.Title.md")|Console title|
|[`ViewHeight`]("ConsoleType.ViewHeight.md")|The height of the console window|
|[`ViewHeightMax`]("ConsoleType.ViewHeightMax.md")|Maximum console window height|
|[`ViewWidth`]("ConsoleType.ViewWidth.md")|The width of the console window|
|[`ViewWidthMax`]("ConsoleType.ViewWidthMax.md")|Maximum console window width|

## Methods
|Name|Description|
| :------------ | :------------ |
|[`Clear`]("ConsoleType.Clear.md")|Clear screen (whether to restore attributes)|
|[`ClipRect`]("ConsoleType.ClipRect.md")|Clip rectangle|
|[`ConsoleSize`]("ConsoleType.ConsoleSize.md")|Set console size (total number of columns, total number of rows)|
|[`FillRectAttribute`]("ConsoleType.FillRectAttribute.md")|The Fill Rectangle property returns the actual fill quantity|
|[`FillRectEx`]("ConsoleType.FillRectEx.md")|Fill rectangular text, expand|
|[`FillRectText`]("ConsoleType.FillRectText.md")|Fill rectangular text (rows, columns, width, height, characters) returns the actual number of fills|
|[`FillText`]("ConsoleType.FillText.md")|Filled text. returns the actual number of fills|
|[`FillTextAttribute`]("ConsoleType.FillTextAttribute.md")|Fill Properties, QB Color Series, Returns the actual number of fills|
|[`FillTextEx`]("ConsoleType.FillTextEx.md")|Fill text, expansion, returns the actual amount of fill|
|[`FontSize`]("ConsoleType.FontSize.md")|Font Change the font name and size|
|[`LenB`]("ConsoleType.LenB.md")|The length of the text, single byte counts as 1, double byte counts as 2|
|[`MakeAttribute`]("ConsoleType.MakeAttribute.md")|Composite character properties, return the properties of the composition|
|[`MoveCursor`]("ConsoleType.MoveCursor.md")|Move the cursor (rows, columns)|
|[`ReadBufferAttribute`]("ConsoleType.ReadBufferAttribute.md")|Read buffer attributes, QB color series|
|[`ReadBufferText`]("ConsoleType.ReadBufferText.md")|Read buffer text, returns the text that was read|
|[`ReadKey`]("ConsoleType.ReadKey.md")|Read the virtual keycode of the key, refer to the KeyCodeConstants|
|[`ReadLine`]("ConsoleType.ReadLine.md")|Read the entire line input, returns the input text, excluding carriage returns, and does not include carriage returns|
|[`ReadPassword`]("ConsoleType.ReadPassword.md")|To read the password, return to enter the text, excluding the carriage return wrap|
|[`ReverseRectColor`]("ConsoleType.ReverseRectColor.md")|Reverses the rectangular foreground and background color to return the actual number of inverts|
|[`ReverseTextColor`]("ConsoleType.ReverseTextColor.md")|Invert foreground and background colors Return the actual number of inverts|
|[`SetViewSize`]("ConsoleType.SetViewSize.md")|Sets the console window size|
|[`SplitAttribute`]("ConsoleType.SplitAttribute.md")|Explode character properties|
|[`WriteBufferAttribute`]("ConsoleType.WriteBufferAttribute.md")|Write buffer properties, QB color series returns how many characters were actually written|
|[`WriteLine`]("ConsoleType.WriteLine.md")|Write an entire line of text, returns the number of characters actually|
|[`WriteLineEx`]("ConsoleType.WriteLineEx.md")|Write the entire line of text, and the extension returns the number of characters actually written|
|[`WriteText`]("ConsoleType.WriteText.md")|Write Text, returns the actual number of characters written|
|[`WriteTextEx`]("ConsoleType.WriteTextEx.md")|Write text extension function, returns the actual number of characters written|
## Examples
```freeBasic
'###############################################################################
'#  Console Example                                                            #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Xusinboy Bekchanov, Liu XiaLin                                    #
'###############################################################################

\#include once "mff/Console.bi"
\#include once "mff/NoInterface.bi"
Dim As ConsoleType Console

Console.BackColor = clGreen
Console.ForeColor = clRed
Console.Title = "VisualFBEditor - Console Example"
'MsgBox Console.Title

' Print Heart shape   鎵撳嵃蹇冨舰鍥炬
Dim As Single a, x, y
Dim As String LineStr
For y = 1.5 To -1.5 Step -0.1
	LineStr = ""
	For x = -1.5 To 15 Step 0.05
		a = x*x + y*y - 1
		' ?????????@??????????????????????????????????????????, ?????????
		LineStr += IIf(a * a * a - x * x * y * y * y <= 0.0, "@", " ")
	Next
	If Trim(LineStr) <> "" Then Console.WriteLine(Mid(LineStr, 5, 60))
Next

Dim As Long outCodePage = Console.OutputCodePage
Console.WriteLine "Press any key to continue..."
Console.ReadKey
Console.Clear
Console.BackColor = clGreen
Console.FontSize(15, 20)
Console.WriteLine " output CodePage = " & Str(outCodePage)
Console.WriteLine " Input CodePage = " & Console.InputCodePage
Debug.Print "Input CodePage = " & Console.InputCodePage, True
'Console.OutputCodePage= 936
Console.FillTextAttribute(1, 4, 20, clYellow, clGray, clDarkBlue)
Console.WriteLine " view width=" &  Console.ViewWidth & "  view height=" &  Console.ViewHeight
Console.WriteLine " view widthMax=" &  Console.ViewWidthMax & "  view heightMax=" &  Console.ViewHeightMax
Console.WriteLine "Press any key to continue..."
Debug.Print 12345
Debug.Print " Set Col Row = 20, 30", True
Console.ReadKey
Console.WriteLine " Set Col Row = 20, 30"
Console.ConsoleSize(60, 30)
Console.WriteLine " view width=" &  Console.ViewWidth & "  view height=" &  Console.ViewHeight
Console.WriteLine " view widthMax=" &  Console.ViewWidthMax & "  view heightMax=" &  Console.ViewHeightMax


Console.InputModeLine= True
'Console.FillTextEx(10, 5, 212, 58, clYellow, clPink, clCyan)
'Dim As String YourName = Console.ReadLine("杈撳叆浣犵殑鍚嶅瓧: ")
Dim As String YourName = Console.ReadLine("Please input your name: ")

Console.WriteLine "Hello, " & YourName
'Console.WriteLine "?????????????????????" 
Console.WriteLine "Press any key to continue..."
Console.ReadKey
Console.WriteLine
```
