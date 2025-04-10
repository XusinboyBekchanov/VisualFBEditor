#include once "mff/WStringList.bi"
' RTF header definition (Consolas font, VB classic color scheme)
' Function declarations
Declare Function ProcessTable(lines() As WString Ptr, ByRef i As Integer) As String
Declare Function ProcessImage(ByRef imgPath As WString) As String
Declare Function ProcessInlineStyles(ByRef iText As WString) As String
Declare Function IsAlphaChar(ByRef c As String) As Boolean
Declare Function RTFToPts(ByVal rtfSize As Integer) As Integer
Declare Function PtsToRTF(ByVal pts As Integer) As Integer
Declare Function RGBToRTF(ByVal r As Integer, ByVal g As Integer, ByVal b As Integer) As String
Declare Function RTFToRGB(ByVal rtfColor As String) As Long
Declare Function EscapeRTF(ByRef iText As WString) As String
Declare Function MDtoRTF(ByRef mdiText As WString) As WString Ptr
Dim Shared As String AIColorBK, AIColorFore, AIRTF_FontSize  ', AIEditorFontName
'Dim Shared As Boolean g_darkModeSupported, g_darkModeEnabled
Function IsAlphaChar(ByRef c As String) As Boolean
	Dim ascVal As Integer = Asc(c)
	Return (ascVal >= 65 And ascVal <= 90) Or (ascVal >= 97 And ascVal <= 122) Or (ascVal >= 48 And ascVal <= 57) Or (ascVal = 95)
End Function
' RTF to Pounds (Half Pounds → Pounds)
Function RTFToPts(ByVal rtfSize As Integer) As Integer
	Return rtfSize \ 2
End Function

' Pounds to RTF（Pounds → Half Pounds）
Function PtsToRTF(ByVal pts As Integer) As Integer
	Return pts * 2
End Function

' RGB to RTF Color Table
Function RGBToRTF(ByVal r As Integer, ByVal g As Integer, ByVal b As Integer) As String
	Return "\red" & Str(r) & "\green" & Str(g) & "\blue" & Str(b) & ";"
End Function

' RTF Color Table to RGB (Input：\red255\green0\blue0;)
Function RTFToRGB(ByVal rtfColor As String) As Long
	Dim As Integer r, g, b
	Dim As Integer p1, p2, p3
	
	' 提取红色分量
	p1 = InStr(rtfColor, "\red")
	p2 = InStr(p1 + 1, rtfColor, "\")
	If p1 > 0 And p2 > p1 Then
		r = Val(Mid(rtfColor, p1 + 4, p2 - (p1 + 4)))
	End If
	
	' 提取绿色分量
	p1 = InStr(rtfColor, "\green")
	p2 = InStr(p1 + 1, rtfColor, "\")
	If p1 > 0 And p2 > p1 Then
		g = Val(Mid(rtfColor, p1 + 6, p2 - (p1 + 6)))
	End If
	
	' 提取蓝色分量
	p1 = InStr(rtfColor, "\blue")
	p2 = InStr(p1 + 1, rtfColor, ";")
	If p1 > 0 And p2 > p1 Then
		b = Val(Mid(rtfColor, p1 + 5, p2 - (p1 + 5)))
	End If
	
	Return RGB(r, g, b)
End Function

' 示例使用
' Main function: VB code to RTF (with syntax highlighting)
Function freeBasicToRTF(ByRef vbCode As WString) As String
	' Enhanced keyword list
	Dim As String keyWordsArr(0 To 21) = {"Sub", "Function", "Dim", "As", "If", "Then", "Else", "End", "For", "Next", "Do", "Loop", "While", "Wend", "Select", "Case", "Const", "True", "False", "Integer", "String", "Boolean"}
	''pkeywordsAsm, pkeywords0, pkeywords1, pkeywords2
	'Debug.Print "pkeywords0"
	'For k As Integer = 0 To (pkeywords0->count - 1)
	'	Debug.Print pkeywords0->Item(k)
	'Next
	'Debug.Print "pkeywords2"
	'For k As Integer = 0 To (pkeywords2->count - 1)
	'	Debug.Print pkeywords2->Item(k)
	'Next
	'Debug.Print "pkeywords1"
	'For k As Integer = 0 To (pkeywords1->count - 1)
	'	Debug.Print pkeywords1->Item(k)
	'Next
	
	' RTF header with proper color table
	Dim As WString Ptr rtfiText
	Dim As Integer i = 1, n = Len(vbCode)
	Dim As Integer inString = 0, inComment = 0
	
	While i <= n
		Dim As String c = Mid(vbCode, i, 1)
		
		' Handle strings (red)
		If c = """" Then
			If inString Then
				WAdd(rtfiText,  """ \cf11" & "\highlight" & AIColorBK)  ' End string
				inString = 0
			Else
				WAdd(rtfiText, "\cf3""")  ' Start string
				inString = 1
			End If
			i += 1
			Continue While
		End If
		
		' Handle comments (green)
		If c = "'" AndAlso Not inString Then
			WAdd(rtfiText, "\cf5'")  ' Comment marker
			inComment = 1
			i += 1
			' Get entire comment line
			While i <= n
				c = Mid(vbCode, i, 1)
				WAdd(rtfiText,  c) 'EscapeRTF(c)
				i += 1
			Wend
			WAdd(rtfiText, " \cf11" & "\highlight" & AIColorBK)
			Continue While
		End If
		
		' Handle keyWordsArr (blue)
		If Not inString AndAlso Not inComment Then
			
			For j As Integer = 0 To UBound(keyWordsArr)
				Dim As Integer kwLen = Len(keyWordsArr(j))
				If (i + kwLen - 1) <= n Then
					If Mid(vbCode, i, kwLen) = keyWordsArr(j) Then
						' Check word boundaries
						If (i = 1 OrElse Not IsAlphaChar(Mid(vbCode, i - 1, 1))) AndAlso _
							(i + kwLen > n OrElse Not IsAlphaChar(Mid(vbCode, i + kwLen, 1))) Then
							WAdd(rtfiText, "\cf7 " & keyWordsArr(j) & " \cf12" & "\highlight" & AIColorBK)
							i += kwLen
							Continue While
						End If
					End If
				End If
			Next
		End If
		
		' Default text handling (black)
		'If inComment Then
		'rtf &= EscapeRTF(c)
		'ElseIf inString Then
		'rtf &= EscapeRTF(c)
		'Else
		'rtf &= EscapeRTF(c)
		'End If
		WAdd(rtfiText, c)
		i += 1
	Wend
	Function = *rtfiText
	Deallocate rtfiText
End Function

' Main conversion function
Function MDtoRTF(ByRef mdiText As WString) As WString Ptr
	Dim As String KeyWordColorStr
	For k As Integer = 1 To KeywordLists.Count - 1
		KeyWordColorStr &= RGBToRTF(GetRed(Keywords(k).Foreground), GetGreen(Keywords(k).Foreground), GetBlue(Keywords(k).Foreground))
	Next
	#ifdef __USE_WINAPI__
		AIRTF_HEADER = _
		"{\rtf1\ansi\ansicpg" & GetACP() & "\deff0" & _
		"{\fonttbl{\f0\fnil\fcharset134 " & AIEditorFontName & ";}{\f1\fnil\fcharset134 Consolas;}}" & _
		"{\colortbl;" & _
		"\red0\green0\blue0;" & _       ' 1: Black (base text) Background color needs -1
		"\red255\green0\blue0;" & _     ' 2: Red
		"\red255\green128\blue0;" & _    ' 3: Orange
		"\red255\green255\blue0;" & _    ' 4: Yellow
		"\red0\green128\blue0;" & _     ' 5: Green
		"\red0\green0\blue255;" & _     ' 6: Blue
		"\red0\green150\blue240;" & _    ' 7: Indigo (actually using teal as substitute) 128
		"\red128\green0\blue128;" & _    ' 8: Purple
		"\red255\green255\blue255;" & _ ' 9: White (background)
		"\red48\green48\blue48;" & _    ' 10: Dark gray (background)
		RGBToRTF(GetRed(NormalText.Foreground), GetGreen(NormalText.Foreground), GetBlue(NormalText.Foreground)) & _
		RGBToRTF(GetRed(Strings.Foreground), GetGreen(Strings.Foreground), GetBlue(Strings.Foreground)) & _
		RGBToRTF(GetRed(ColorMacros.Foreground), GetGreen(ColorMacros.Foreground), GetBlue(ColorMacros.Foreground)) & _
		KeyWordColorStr & _
		"\red0\green200\blue200;" & _   ' 11: Teal (new)
		"\red128\green128\blue128;" & _ ' 12: Gray (new)
		"\red255\green0\blue255;" & _   ' 13: Pink (new)
		"}" & _
		"\viewkind4\uc1\pard\lang2052\f1\" & AIRTF_FontSize & ""  ' Default font: Consolas, 9pt
	#endif
	'ColorOperators, ColorProperties, ColorComps, ColorGlobalNamespaces, ColorGlobalTypes, ColorGlobalEnums, ColorEnumMembers, ColorConstants, ColorGlobalFunctions, ColorLineLabels, ColorLocalVariables, ColorSharedVariables, ColorCommonVariables, ColorByRefParameters, ColorByValParameters, ColorFields, ColorDefines, ColorMacros, ColorSubs
	'Bookmarks, Breakpoints, Comments, CurrentBrackets, CurrentLine, CurrentWord, ExecutionLine, FoldLines, Identifiers, IndicatorLines, Keywords(Any), LineNumbers, NormalText, Numbers, RealNumbers, Selection, SpaceIdentifiers, Strings
	
	AIColorFore = IIf(g_darkModeSupported AndAlso g_darkModeEnabled, "cf9", "cf0")
	AIColorBK = IIf(g_darkModeSupported AndAlso g_darkModeEnabled, "10", "9")
	AIRTF_FontSize = "fs" & PtsToRTF(EditorFontSize)
	Dim As WString Ptr Lines(), rtfiText
	Dim i As Integer
	WLet(rtfiText, AIRTF_HEADER)
	' Split text into lines
	Split(WStr(EscapeRTF(mdiText)), Chr(10), Lines())
	
	For i = 0 To UBound(Lines)
		Dim lineLength As Integer = Len(Trim(*Lines(i)))
		
		'"[" & ML("User") & "]: "
		If lineLength >= 3 AndAlso Left(*Lines(i), 3) = "[" & ML("User") & "]: " Then
			WAdd(rtfiText, "\f1\cf2\highlight" & "11" & " " & Left(*Lines(i) & Space(300), 300) & "\cf11\highlight" & AIColorBK & "\par")
		End If
		If lineLength >= 3 AndAlso Left(*Lines(i), 3) = "[AI]: " Then
			WAdd(rtfiText, "\f1\cf2\highlight" & "11" & " " & Left(*Lines(i) & Space(300), 300) & "\cf11\highlight" & AIColorBK & "\par")
		End If
		' 1. Code block processing (enhanced robustness)
		If lineLength >= 3 AndAlso Left(*Lines(i), 3) = "```" Then
			*Lines(i) = Trim(*Lines(i))
			WAdd(rtfiText, "\f1\cf2\highlight" & "7" & " " & Left(*Lines(i) & Space(300), 300) & "\cf11\highlight" & AIColorBK & "\par")
			i += 1
			While i <= UBound(Lines) AndAlso Left(*Lines(i), 3) <> "```"
				'WAdd(rtfiText, "\f1\" & AIRTF_FontSize & "\cf5\highlight" & AIColorBK & EscapeRTF(*Lines(i)) & "\par")
				WAdd(rtfiText, freeBasicToRTF(*Lines(i)) & "\par")
				i += 1
			Wend
			WAdd(rtfiText, "```\par\f0\" & AIRTF_FontSize & "\" & AIColorFore & "\highlight" & AIColorBK & "\par")
			Continue For
		End If
		
		'No need for this party
		'  2. List processing (optimized multi-level lists) - Fixed indentation issue
		'If lineLength >= 2 AndAlso (Left(*Lines(i), 2) = "- " Or Left(*Lines(i), 3) = "  -") Then
		'	Dim indentLevel As Integer = 0
		'	Dim currentIndent As Integer = 0
		'
		'	While i <= UBound(Lines)
		'		lineLength = Len(Trim(*Lines(i)))
		'		If lineLength = 0 Then Exit While
		'
		'		' Calculate current line's indentation level
		'		currentIndent = 0
		'		While currentIndent < Len(*Lines(i)) AndAlso _
		'			Mid(*Lines(i), currentIndent + 1, 2) = "  "
		'			currentIndent += 2
		'		Wend
		'
		'		' Adjust indentation level
		'		If currentIndent = 0 Then
		'			indentLevel = 0
		'		Else
		'			' Every two spaces represent one indentation level
		'			indentLevel = (currentIndent \ 2)
		'		End If
		'
		'		' Process list line
		'		Dim contentStart As Integer = currentIndent + 2 ' Skip spaces before "-" and the "-"
		'		If contentStart <= Len(*Lines(i)) Then
		'			Dim bullet As String = IIf(indentLevel > 0, "\'95", "\'b7") ' Change bullet for sublists
		'
		'			' Add RTF-formatted indentation and bullet '\fi-360\li720\f1
		'			WAdd(rtfiText, _
		'			"\li" & (indentLevel * 720) & " " & _  ' Each level indents 720twips (1/20 point)
		'			bullet & " " & _                      ' Bullet
		'			ProcessInlineStyles(Mid(*Lines(i), contentStart + 1)) & _
		'			"\par")
		'		End If
		'
		'		i += 1
		'		' Check if next line is no longer a list item
		'		If i > UBound(Lines) Then Exit While
		'		lineLength = Len(Trim(*Lines(i)))
		'		If lineLength < 2 Then Exit While
		'		If Left(*Lines(i), 2) <> "- " AndAlso Left(*Lines(i), 3) <> "  -" Then Exit While
		'	Wend
		'
		'	If i <= UBound(Lines) Then i -= 1
		'	Continue For
		'End If
		
		
		' 3. Table processing (enhanced robustness)
		If i < UBound(Lines) - 1 AndAlso Left(*Lines(i), 1) = "|" AndAlso _
			Left(*Lines(i + 1), 1) = "|" AndAlso InStr(*Lines(i + 1), "---") > 0 Then
			WAdd(rtfiText, ProcessTable(Lines(), i))
			Continue For
		End If
		
		' 4. Image processing
		If lineLength >= 2 AndAlso Left(*Lines(i), 2) = "![" Then
			WAdd(rtfiText, ProcessImage(*Lines(i)))
			Continue For
		End If
		
		' 5. Heading processing (optimized multi-level headings)
		Dim As Integer titleSize, level
		If lineLength >= 1 AndAlso Left(*Lines(i), 1) = "#" Then
			level = 0
			While level < 6 AndAlso level < lineLength AndAlso Mid(*Lines(i), level+ 1, 1) = "#"
				level += 1
			Wend
			
			If level > 0 AndAlso (lineLength = level OrElse Mid(*Lines(i), level+1, 1) = " ") Then
				titleSize = Max(PtsToRTF(EditorFontSize+ 6) - level * 2, PtsToRTF(EditorFontSize))
				WAdd(rtfiText, "\f0\fs" & titleSize & "\b \cf4 " & ProcessInlineStyles(Trim(Mid(*Lines(i), level + 1))) & "\b0\" & AIColorFore & "\par")
			Else
				WAdd(rtfiText, "\f0\" & AIRTF_FontSize & " " & ProcessInlineStyles(*Lines(i)) & "\par")
			End If
			Continue For
		End If
		
		' Normal paragraph processing
		If lineLength = 0 Then
			WAdd(rtfiText, "\f0\" & AIRTF_FontSize & "\" & AIColorFore & "\highlight" & AIColorBK & "\par")
		Else
			WAdd(rtfiText, "\f0\" & AIRTF_FontSize & "\" & AIColorFore & "\highlight" & AIColorBK & ProcessInlineStyles(*Lines(i)) & "\par")
		End If
		
	Next
	For i = 0 To UBound(Lines)
		If Lines(i) <> 0 Then Deallocate Lines(i)
	Next
	
	WAdd(rtfiText, "}")
	Return rtfiText
End Function

' Helper function: Process tables
Function ProcessTable(Lines() As WString Ptr, ByRef i As Integer) As String
	Dim tableRTF As String = ""
	Dim cols As Integer = 0
	Dim j As Integer
	
	' Parse table header
	Dim As WString Ptr headers(), Cells(), RowStrPtr
	WLet(RowStrPtr, Mid(*Lines(i), 2, Len(*Lines(i)) - 2))
	Split(*RowStrPtr, "|", headers())
	cols = UBound(headers)
	' Start table
	tableRTF &= "\trowd\trgaph108\trleft0 "
	
	' Set column widths
	For j = 0 To cols
		tableRTF &= "\cellx" & (j+1)*1440 ' Adjust column width
	Next
	
	' Add table header
	tableRTF &= "\pard\intbl "
	For j = 0 To cols
		If j <= UBound(headers) Then
			tableRTF &= *headers(j) & "\cell "
		Else
			tableRTF &= "\cell "
		End If
	Next
	tableRTF &= "\row "
	
	' Free headers array memory
	For j = 0 To UBound(headers)
		Deallocate headers(j)
	Next
	
	' Skip table separator line
	i += 2
	
	' Parse table content
	While i <= UBound(Lines) AndAlso Left(*Lines(i), 1) = "|"
		' Start new row
		tableRTF &= "\trowd\trgaph108\trleft0 "
		For j = 0 To cols
			tableRTF &= "\cellx" & (j+1)*1440 ' Adjust column width
		Next
		tableRTF &= "\pard\intbl "
		WLet(RowStrPtr,  Mid(*Lines(i), 2, Len(*Lines(i)) - 2))
		Split(Replace(*RowStrPtr, " | ", Chr(1)), Chr(1), Cells())
		
		For j = 0 To cols
			If j <= UBound(Cells) Then
				tableRTF &= *Cells(j) & "\cell "
			Else
				tableRTF &= "\cell "
			End If
		Next
		
		' Free Cells array memory
		For j = 0 To UBound(Cells)
			Deallocate Cells(j)
		Next
		tableRTF &= "\row "
		i += 1
	Wend
	If i <= UBound(Lines) Then i -= 1
	tableRTF &= "\pard"
	Deallocate RowStrPtr
	Return tableRTF
End Function

' Helper function: Process images (simplified placeholder implementation)
Function ProcessImage(ByRef imgLine As WString) As String
	Dim altStart As Integer = InStr(imgLine, "[") + 1
	Dim altEnd As Integer = InStr(imgLine, "]")
	Dim altiText As String = Mid(imgLine, altStart, altEnd-altStart)
	
	Dim imgStart As Integer = InStr(imgLine, "(") + 1
	Dim imgEnd As Integer = InStr(imgLine, ")")
	Dim imgPath As String = Mid(imgLine, imgStart, imgEnd-imgStart)
	
	Return "{\b\cf3 [Image: " & altiText & " (" & imgPath & ")]}\" & AIColorFore & "\b0\par"
End Function

' Helper function: Process inline styles (optimized logic and performance)
Function ProcessInlineStyles(ByRef iText As WString) As String
	Dim As WString Ptr Result
	Dim As Integer Posi, endPosi
	' Initialize result string
	WLet(Result, iText)
	' Phase 1: Process bold text **text**
	Posi = 1
	While True
		Posi = InStr(Posi, *Result, "**")
		If Posi = 0 Then Exit While
		endPosi = InStr(Posi + 2, *Result, "**")
		If endPosi = 0 Then Exit While
		' Replace with RTF format
		WLetEx(Result, Left(*Result, Posi - 1) & "{\b " & Mid(*Result, Posi + 2, endPosi - Posi - 2) & "}{\b0 " & Mid(*Result, endPosi + 2))
		' Update position pointer to avoid reprocessing
		Posi = endPosi + 2 - (endPosi - Posi) ' Compensate for position offset after replacement
	Wend
	
	' Phase 2: Process italic text *text*
	Posi = 1
	While True
		Posi = InStr(Posi, *Result, "*")
		If Posi = 0 Then Exit While
		
		' Check it's not part of bold marker
		If Posi < Len(*Result) AndAlso Mid(*Result, Posi + 1, 1) = "*" Then
			Posi += 2
			Continue While
		End If
		
		endPosi = InStr(Posi + 1, *Result, "*")
		If endPosi = 0 Then Exit While
		
		' Check end marker is not part of bold marker
		If endPosi < Len(*Result) AndAlso Mid(*Result, endPosi + 1, 1) = "*" Then
			Posi = endPosi + 2
			Continue While
		End If
		' Extract italic text content
		'temp = Mid(*Result, Posi + 1, endPosi - Posi - 1)
		' Replace with RTF format
		WLetEx(Result, Left(*Result, Posi - 1) & "{\i " & Mid(*Result, Posi + 1, endPosi - Posi - 1) & "}{\i0 " & Mid(*Result, endPosi + 1))
		
		' Update position pointer
		Posi = endPosi + 1 - (endPosi - Posi) ' Compensate for position offset after replacement
	Wend
	
	' Process inline code (optimized nested handling)
	Posi = InStr(*Result, "`")
	While Posi > 0
		Dim endPosi As Integer = InStr(Posi+1, *Result, "`")
		If endPosi > 0 Then
			WLetEx(Result,  Left(*Result, Posi - 1) & "\f1\fs18\cf11\highlight" & AIColorBK & " "  & _
			Mid(*Result, Posi + 1, endPosi - Posi - 1) & "\f0\" & AIRTF_FontSize & "\" & AIColorFore & "\highlight" & AIColorBK & " " & _
			Mid(*Result, endPosi + 1))
			Posi = InStr(endPosi+1, *Result, "`")
		Else
			Exit While
		End If
	Wend
	
	' Process links (optimized nested handling)
	Posi = InStr(*Result, "[")
	While Posi > 0
		Dim endBracket As Integer = InStr(Posi, *Result, "]")
		If endBracket > 0 Then
			Dim linkiText As String = Mid(*Result, Posi+1, endBracket-Posi-1)
			Dim startParen As Integer = InStr(endBracket, *Result, "(")
			Dim endParen As Integer = InStr(startParen, *Result, ")")
			
			If startParen > 0 And endParen > 0 And startParen = endBracket+1 Then
				Dim url As String = Mid(*Result, startParen+1, endParen-startParen-1)
				WLetEx(Result,  Left(*Result, Posi - 1) & "{\field{\*\fldinst HYPERLINK """ & url & """}" & _
				"{\fldrslt\ul\cf6 " & ProcessInlineStyles(linkiText) & "\ulnone\cf0}}" & _
				Mid(*Result, endParen + 1))
				Posi = InStr(endParen+1, *Result, "[")
			Else
				Posi = InStr(Posi+1, *Result, "[")
			End If
		Else
			Exit While
		End If
	Wend
	
	Function = *Result
	Deallocate Result
End Function

' Helper function: RTF special character escaping
Function EscapeRTF(ByRef iText As WString) As String
	Dim result As String = iText
	result = Replace(result, "\", "\\")
	result = Replace(result, "{", "\{")
	result = Replace(result, "}", "\}")
	result = Replace(result, "~", "\~")
	result = Replace(result, "^", "\^")
	Return result
End Function

'Dim As WString * 8096 testMarkdown
'testMarkdown = !"# Markdown to RTF Test\n" & _
'!"## Level 2 Heading\n" & _
'!"This is a paragraph containing **bold**, *italic* and `inline code`.\n" & _
'!"[Link to Baidu](http://www.baidu.com)\n" & _
'!"- Unordered list item 1\n" & _
'!"  - Sublist item 1\n" & _
'!"  - Sublist item 2\n" & _
'!"- Unordered list item 2\n" & _
'!"| Name | Age | Occupation |\n" & _
'!"|------|-----|------|\n" & _
'!"| John | 25  | Programmer |\n" & _
'!"| Jane | 30  | Designer |\n" & _
'!"```vb\n" & _
'!"Sub Test()\n" & _
'!"    Print ""Code block test ""\n" & _
'!"End Sub\n" & _
'!"```\n\n" & _
'!"| Name | Age | Occupation |\n" & _
'!"|------|-----|------|\n" & _
'!"| John | 25  | Programmer |\n" & _
'!"| Jane | 30  | Designer |\n" & _
'!"[Example image](example.png)"
'Dim As WString Ptr rtfOutput
'rtfOutput = MDtoRTF(testMarkdown)
'Print "Generated RTF content:"
'Print "--------------------------------------------------"
'Print *rtfOutput
'Print "--------------------------------------------------"
''txtThink.iTextRTF = rtfOutput
'Dim Fn As Integer = FreeFile
'Open "test.rtf" For Output As #Fn
'Print #Fn, *rtfOutput
'Close #Fn
'Print "RTF file saved as test.rtf"
'Deallocate rtfOutput
'Sleep(8000)
'End