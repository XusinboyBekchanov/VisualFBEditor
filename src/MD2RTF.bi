#include once "mff/WStringList.bi"
' RTF header definition (Consolas font, VB classic color scheme)
' Function declarations
Declare Function ProcessTable(lines() As WString Ptr, ByRef i As Integer) As WString Ptr
Declare Function ProcessImage(ByRef imgPath As WString) As String
Declare Function ProcessInlineStyles(ByRef iText As WString) As WString Ptr
Declare Function IsAlphaChar(ByRef c As String) As Boolean
Declare Function RTFToPts(ByVal rtfSize As Integer) As Integer
Declare Function PtsToRTF(ByVal pts As Integer) As Integer
Declare Function RGBToRTF(ByVal r As Integer, ByVal g As Integer, ByVal b As Integer) As String
Declare Function RTFToRGB(ByVal rtfColor As String) As Long
Declare Function EscapeRTF(ByRef iText As WString) As WString Ptr
Declare Function MDtoRTF(ByRef mdiText As WString) As WString Ptr
Dim Shared As String AIColorBK, AIColorFore, AIRTF_FontSize
'Dim Shared As Boolean g_darkModeSupported, g_darkModeEnabled
Dim Shared As String KeyWordsArr(Any)
Dim Shared As Integer KeyWordIndex, KeyWordIndexMacro, KeyWordIndexType

KeyWordIndexMacro = Max(0, pkeywords0->Count + pkeywords1->Count + pkeywords2->Count - 1)
ReDim KeyWordsArr(KeyWordIndexMacro)
KeyWordIndexMacro = pkeywords0->Count - 1
For k As Integer = 0 To (pkeywords0->Count - 1)
	KeyWordsArr(KeyWordIndex) = pkeywords0->Item(k)
	KeyWordIndex += 1
Next
KeyWordIndexType= pkeywords1->Count - 1
For k As Integer = 0 To (pkeywords1->Count - 1)
	KeyWordsArr(KeyWordIndex) = pkeywords1->Item(k)
	KeyWordIndex += 1
Next
For k As Integer = 0 To (pkeywords2->Count - 1)
	KeyWordsArr(KeyWordIndex) = pkeywords2->Item(k)
	KeyWordIndex += 1
Next

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
Function freeBasicToRTF(ByRef vbCode As WString) As WString Ptr
	' RTF header with proper color table
	Dim As WString Ptr rtfiText
	Dim As Integer i = 1, n = Len(vbCode)
	Dim As Integer inString = 0, inComment = 0
	Dim As WString * 2  c
	While i <= n
		c = Mid(vbCode, i, 1)
		
		Select Case c   ' Handle strings (red)
		Case """"
			If inString Then
				WAdd(rtfiText,  """ \cf11" & "\highlight" & AIColorBK)  ' End string
				inString = 0
			Else
				WAdd(rtfiText, "\cf3""")  ' Start string
				inString = 1
			End If
			i += 1
			Continue While
			' Handle comments (green)
		Case "'"
			If Not inString Then
				WAdd(rtfiText, "\cf5'")  ' Comment marker
				inComment = 1
				i += 1
				' Get entire comment line
				While i <= n
					c = Mid(vbCode, i, 1)
					WAdd(rtfiText,  c)
					i += 1
				Wend
				WAdd(rtfiText, " \cf11" & "\highlight" & AIColorBK)
				Continue While
			End If
		Case Else
			' Handle keyWordsArr (blue)
			If Not inString AndAlso Not inComment Then
				For j As Integer = 0 To UBound(KeyWordsArr)
					Dim As Integer kwLen = Len(KeyWordsArr(j))
					If (i + kwLen - 1) <= n Then
						If Mid(vbCode, i, kwLen) = KeyWordsArr(j) Then
							' Check word boundaries
							If (i = 1 OrElse Not IsAlphaChar(Mid(vbCode, i - 1, 1))) AndAlso _
								(i + kwLen > n OrElse Not IsAlphaChar(Mid(vbCode, i + kwLen, 1))) Then
								If j <= KeyWordIndexMacro Then
									WAdd(rtfiText, "\cf14 " & KeyWordsArr(j) & " \cf11" & "\highlight" & AIColorBK)
								ElseIf j <= KeyWordIndexType Then
									WAdd(rtfiText, "\cf15 " & KeyWordsArr(j) & " \cf11" & "\highlight" & AIColorBK)
								Else
									If Mid(vbCode, i + kwLen, 1) = " " Then
										WAdd(rtfiText, "\cf16 " & KeyWordsArr(j) & " \cf11" & "\highlight" & AIColorBK)
									Else
										WAdd(rtfiText, "\cf16 " & KeyWordsArr(j) & "\cf11" & "\highlight" & AIColorBK)
									End If
								End If
								i += kwLen
								Continue While
							End If
						End If
					End If
				Next
			End If
		End Select
		WAdd(rtfiText, c)
		i += 1
	Wend
	Return rtfiText
End Function

' Main conversion function
Function MDtoRTF(ByRef mdiText As WString) As WString Ptr
	Dim As String KeyWordColorStr
	AIColorFore = IIf(g_darkModeSupported AndAlso g_darkModeEnabled, "cf9", "cf0")
	AIColorBK = IIf(g_darkModeSupported AndAlso g_darkModeEnabled, "10", "9")
	AIRTF_FontSize = "fs" & PtsToRTF(EditorFontSize)
	For k As Integer = 1 To KeywordLists.Count - 1
		KeyWordColorStr &= RGBToRTF(GetRed(Keywords(k).Foreground), GetGreen(Keywords(k).Foreground), GetBlue(Keywords(k).Foreground))
	Next
	#ifdef __USE_WINAPI__
		AIRTF_HEADER = _
		"{\urtf1\ansi\ansicpg" & GetACP() & "\deff0" & _
		"{\fonttbl{\f0\fnil\fcharset0 " & AIEditorFontName & ";}{\f1\fnil\fcharset204 Consolas;}}" & _
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
		"\viewkind4\uc1\pard\lang2052\f1\" & AIRTF_FontSize ' Default font: Consolas, 9pt
	#endif
	'ColorOperators, ColorProperties, ColorComps, ColorGlobalNamespaces, ColorGlobalTypes, ColorGlobalEnums, ColorEnumMembers, ColorConstants, ColorGlobalFunctions, ColorLineLabels, ColorLocalVariables, ColorSharedVariables, ColorCommonVariables, ColorByRefParameters, ColorByValParameters, ColorFields, ColorDefines, ColorMacros, ColorSubs
	'Bookmarks, Breakpoints, Comments, CurrentBrackets, CurrentLine, CurrentWord, ExecutionLine, FoldLines, Identifiers, IndicatorLines, Keywords(Any), LineNumbers, NormalText, Numbers, RealNumbers, Selection, SpaceIdentifiers, Strings
	
	Dim As WString Ptr Lines(), rtfiText, rtfiText1, ResultPtr
	Dim As Integer  LineLength, titleSize, level, i
	Dim As WString * 2 Ch
	
	rtfiText1 = EscapeRTF(mdiText)
	If rtfiText1 = 0 Then Return 0
	Split(*rtfiText1, Chr(10), Lines())
	WLet(rtfiText, AIRTF_HEADER)
	If rtfiText = 0 Then Return 0
	For i = 0 To UBound(Lines)
		LineLength = Len(Trim(*Lines(i)))
		Deallocate ResultPtr : ResultPtr = 0
		If LineLength = 0 Then
			WAdd(rtfiText, "\f0\" & AIRTF_FontSize & "\" & AIColorFore & "\highlight" & AIColorBK & "\par")
		Else
			Ch = Left(*Lines(i), 1)
			'Print *Lines(i)
			Select Case Ch
			Case "["   '"[" & ML("User") & "]: "
				If Left(*Lines(i), 20) = "[**User Question:**]" Then
					WAdd(rtfiText, "\f1\cf2\highlight" & "11" & " " & Left("[User Question:] " & Mid(*Lines(i), 21) & Space(300), 300) & "\cf11\highlight" & AIColorBK & "\par")
					'*Lines(i) = Mid(*Lines(i), 21)
					level = 21
				ElseIf Left(*Lines(i), 18) = "[**AI Response:**]" Then
					WAdd(rtfiText, "\f1\cf2\highlight" & "11" & " " & Left("[AI Response:] " & Mid(*Lines(i), 19) & Space(300), 300) & "\cf11\highlight" & AIColorBK & "\par")
					level = 19
				End If
				ResultPtr = ProcessInlineStyles(Mid(*Lines(i), level))
				If ResultPtr Then WAdd(rtfiText, "\f0\" & AIRTF_FontSize & "\" & AIColorFore & "\highlight" & AIColorBK & *ResultPtr & "\par")
				Continue For
			Case "`"  ' 1. Code block processing (enhanced robustness)
				If LCase(Left(*Lines(i), 12)) = "```freebasic" OrElse LCase(Left(*Lines(i), 5)) = "```fb" OrElse LCase(Left(*Lines(i), 5)) = "```vb" Then
					WAdd(rtfiText, "\f1\cf2\highlight" & "7" & " " & Left(*Lines(i) & Space(300), 300) & "\cf11\highlight" & AIColorBK & "\par")
					i += 1
					While i <= UBound(Lines) AndAlso Left(*Lines(i), 3) <> "```"
						'WAdd(rtfiText, "\f1\" & AIRTF_FontSize & "\cf5\highlight" & AIColorBK & EscapeRTF(*Lines(i)) & "\par")
						ResultPtr = freeBasicToRTF(*Lines(i))
						If ResultPtr Then WAdd(rtfiText, *ResultPtr & "\par")
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
				
			Case "|"   ' 3. Table processing (enhanced robustness)
				If i < UBound(Lines) - 1 AndAlso Left(*Lines(i + 1), 1) = "|" AndAlso InStr(*Lines(i + 1), "---") > 0 Then
					WAdd(rtfiText, "\f0\" & AIRTF_FontSize & "\" & AIColorFore & "\highlight" & AIColorBK & " ")
					ResultPtr = ProcessTable(Lines(), i)
					If ResultPtr Then WAdd(rtfiText, *ResultPtr)
					Continue For
				End If
				
			Case "!"   ' 4. Image processing
				If Left(*Lines(i), 2) = "![" Then
					WAdd(rtfiText, "\f0\" & AIRTF_FontSize & "\" & AIColorFore & "\highlight" & AIColorBK & " ")
					WAdd(rtfiText, ProcessImage(*Lines(i)))
					Continue For
				End If
				
			Case "#"   ' 5. Heading processing (optimized multi-level headings)
				titleSize= 0: level = 0
				level = 0
				While level < 6 AndAlso level < LineLength AndAlso Mid(*Lines(i), level+ 1, 1) = "#"
					level += 1
				Wend
				
				If level > 0 AndAlso (LineLength = level OrElse Mid(*Lines(i), level+1, 1) = " ") Then
					titleSize = Max(PtsToRTF(EditorFontSize+ 6) - level * 2, PtsToRTF(EditorFontSize))
					ResultPtr = ProcessInlineStyles(Trim(Mid(*Lines(i), level + 1)))
					If ResultPtr Then WAdd(rtfiText, "\f0\fs" & titleSize & "\b \cf4 " & *ResultPtr & "\b0\" & AIColorFore & "\par")
					WAdd(rtfiText, "\f0\" & AIRTF_FontSize & "\" & AIColorFore & "\highlight" & AIColorBK & " ")
				Else
					ProcessInlineStyles(*Lines(i))
					If ResultPtr Then WAdd(rtfiText, "\f0\" & AIRTF_FontSize & " " & *ResultPtr & "\par")
				End If
				Continue For
			Case Else
				' Normal paragraph processing
				ResultPtr = ProcessInlineStyles(*Lines(i))
				If ResultPtr Then WAdd(rtfiText, "\f0\" & AIRTF_FontSize & "\" & AIColorFore & "\highlight" & AIColorBK & *ResultPtr & "\par")
			End Select
		End If
		Deallocate Lines(i)
	Next
	Erase Lines
	WAdd(rtfiText, "}")
	Deallocate ResultPtr
	Deallocate rtfiText1
	Return rtfiText
End Function

' Helper function: Process tables
Function ProcessTable(Lines() As WString Ptr, ByRef i As Integer) As WString Ptr
	Dim tableRTF As WString Ptr
	Dim As Integer cols, j, colWidthMax(), colWidth 
	
	' Parse table header
	Dim As WString Ptr headers(), Cells(), RowStrPtr
	WLet(RowStrPtr, Mid(*Lines(i), 2, Len(*Lines(i)) - 2))
	Split(*RowStrPtr, "|", headers())
	cols = UBound(headers)
	' Start table
	WAdd(tableRTF, "\trowd\trgaph108\trleft0 ")
	
	' Set column widths
	For j = 0 To cols
		WAdd(tableRTF, "\cellx" & (j + 1)) ' Adjust column width
	Next
	
	' Add table header
	WAdd(tableRTF, "\pard\intbl ")
	For j = 0 To cols
		If j <= UBound(headers) Then
			WAdd(tableRTF, *headers(j) & "\cell ")
		Else
			WAdd(tableRTF, "\cell ")
		End If
		' Free headers array memory
		Deallocate headers(j)
	Next
	WAdd(tableRTF,  "\row ")
	
	' Free headers array memory
	Erase headers
	' Skip table separator line
	i += 2
	ReDim colWidthMax(cols)
	' Parse table content
	While i <= UBound(Lines) AndAlso Left(*Lines(i), 1) = "|"
		' Start new row
		WAdd(tableRTF, "\trowd\trgaph108\trleft0 ")
		For j = 0 To cols
			WAdd(tableRTF, "\cellx" & (j + 1)) ' Adjust column width
		Next
		WAdd(tableRTF, "\pard\intbl ")
		WLet(RowStrPtr,  Mid(*Lines(i), 2, Len(*Lines(i)) - 2))
		Split(*RowStrPtr, "|", Cells())
		For j = 0 To cols
			If j <= UBound(Cells) Then
				WAdd(tableRTF,  *Cells(j) & "\cell ")
			Else
				WAdd(tableRTF, "\cell ")
			End If
			If colWidthMax(j) < Len(*Cells(j)) Then colWidthMax(j) = Len(*Cells(j))
			Deallocate Cells(j)
		Next
		' Free Cells array memory
		Erase Cells
		WAdd(tableRTF, "\row ")
		i += 1
	Wend
	If i <= UBound(Lines) Then i = Max(i - 1, 1)
	WAdd(tableRTF, "\pard")
	colWidth = 0
	For j = 0 To cols
		'colWidthMax(j) = colWidthMax(j) * EditorFontSize * 7.5
		colWidth += colWidthMax(j) * EditorFontSize * 7.5
		Replace(*tableRTF, "\cellx" & (j + 1), "\cellx" & colWidth) ' Adjust column width
	Next
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
Function ProcessInlineStyles(ByRef iText As WString) As WString Ptr
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
	
	' Process inline code TmpPtr(optimized nested handling)
	Posi = InStr(*Result, "`")
	While Posi > 0
		endPosi = InStr(Posi+1, *Result, "`")
		If endPosi > 0 Then
			WLetEx(Result,  Left(*Result, Posi - 1) & "\f1\" & AIRTF_FontSize & "\cf11\highlight" & AIColorBK & " "  & _
			Mid(*Result, Posi + 1, endPosi - Posi - 1) & "\f0\" & AIRTF_FontSize & "\" & AIColorFore & "\highlight" & AIColorBK & " " & _
			Mid(*Result, endPosi + 1))
			Posi = InStr(endPosi + 1, *Result, "`")
		Else
			Exit While
		End If
	Wend
	
	' Process links (optimized nested handling)
	Posi = InStr(*Result, "[")
	Dim As WString Ptr tmpPtr
	Dim As String url, linkiText
	Dim As Integer startParen, endParen, endBracket
	While Posi > 0
		endBracket = InStr(Posi, *Result, "]")
		If endBracket > 0 Then
			linkiText = Mid(*Result, Posi + 1, endBracket - Posi - 1)
			startParen = InStr(endBracket, *Result, "(")
			endParen = InStr(startParen, *Result, ")")
			
			If startParen > 0 And endParen > 0 And startParen = endBracket+1 Then
				url = Mid(*Result, startParen + 1, endParen - startParen - 1)
				tmpPtr = ProcessInlineStyles(linkiText)
				If tmpPtr <> 0 Then 
					WAdd(Result, "\f0\" & AIRTF_FontSize & "\" & AIColorFore & "\highlight" & AIColorBK & " ")
					WLetEx(Result,  Left(*Result, Posi - 1) & "{\field{\*\fldinst HYPERLINK """ & url & """}" &	"{\fldrslt " & *tmpPtr & "\ulnone\cf6}}" & Mid(*Result, endParen + 1))
					'WLetEx(Result,  Left(*Result, Posi - 1) & "{\field{\*\fldinst HYPERLINK """ & url & """}" &	"{\fldrslt\ul\cf6 " & *tmpPtr & "\ulnone\cf6}}" & Mid(*Result, endParen + 1))
					'{\b\cf3 [Image: " & altiText & " (" & imgPath & ")]}\" & AIColorFore & "\b0\par"
					Deallocate tmpPtr
				End If
				Posi = InStr(endParen+1, *Result, "[")
			Else
				Posi = InStr(Posi+1, *Result, "[")
			End If
		Else
			Exit While
		End If
	Wend
	Return Result
End Function

' Helper function: RTF special character escaping
Function EscapeRTF(ByRef iText As WString) As WString Ptr
	Dim As Integer Posi = 0, iLen = Len(iText)
	' 预分配内存（按最大需求：每个字符最多6个转义字符）
	Dim As Integer bufferSize = iLen * 6 + 2
	If iLen < 1 Then Return 0
	Dim As String TmpStr
	Dim As WString Ptr ResultPtr = Allocate(bufferSize * SizeOf(WString))     ' 预分配最大可能空间
	For i As Integer = 0 To iLen - 1
		If Posi >= bufferSize- 6 Then
			bufferSize *= 2
			ResultPtr = Reallocate(ResultPtr, bufferSize * SizeOf(WString))
		End If
		Select Case iText[i]
		Case 92, 123, 125, 126, 94  ' ASCII码值: \ { }   ^
			(*ResultPtr)[Posi] = 92
			(*ResultPtr)[Posi + 1] = iText[i]
			Posi += 2
		Case 13  ' ASCII码值: Cr LF
			If i < iLen - 1 AndAlso iText[i + 1] = 10 Then
				i += 1  ' 跳过后续的换行符 (LF)
			End If
			(*ResultPtr)[Posi] = 10
			Posi += 1
			'If i < iLen - 1 AndAlso iText[i + 1] = 10 Then
			'             i += 1  ' 跳过后续的换行符 (LF)
			'         End If
			'         (*ResultPtr)[Posi] = 92  ' \p
			'         (*ResultPtr)[Posi + 1] = 112 ' p
			'         (*ResultPtr)[Posi + 2] = 97  ' a
			'         (*ResultPtr)[Posi + 3] = 114 ' r
			'         Posi += 4
		Case 10  ' ASCII码值: Cr LF
			(*ResultPtr)[Posi] = 10
			Posi += 1
		Case 9  ' ASCII码值: TAB
			(*ResultPtr)[Posi] = 32
			Posi += 1
			(*ResultPtr)[Posi] = 32
			Posi += 1
			(*ResultPtr)[Posi] = 32
			Posi += 1
			(*ResultPtr)[Posi] = 32
			Posi += 1
		Case 0 To 31: ' 控制字符 \uXXXX
			TmpStr = Hex(iText[i], 4)
			(*ResultPtr)[Posi] = 92
			Posi += 1
			(*ResultPtr)[Posi] = 117
			Posi += 1
			(*ResultPtr)[Posi] = TmpStr[0]
			Posi += 1
			(*ResultPtr)[Posi] = TmpStr[1]
			Posi += 1
			(*ResultPtr)[Posi] = TmpStr[2]
			Posi += 1
			(*ResultPtr)[Posi] = TmpStr[3]
			Posi += 1
		Case Else
			(*ResultPtr)[Posi] = iText[i]
			Posi += 1
		End Select
	Next
	(*ResultPtr)[Posi] = 0: (*ResultPtr)[Posi + 1] = 0   ' 截取实际使用长度
	Return ResultPtr
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