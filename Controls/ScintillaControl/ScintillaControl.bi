#pragma once
' ScintillaControl
' https://www.ScintillaControl.org/
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

#include once "mff/Control.bi"
#include once "Scintilla.bi"
#include once "Scilexer.bi"
#include once "utf_conv.bi"
#include once "vbcompat.bi"

Using My.Sys.Forms

Type ScintillaControl Extends Control
Private:
	Dim mStf As Sci_TextToFind
	Dim mDarkMode As Boolean = False
	Dim As Any Ptr pLibLexilla
	Dim As Any Ptr pLibScintilla
	#ifndef __USE_GTK__
		Declare Static Sub WndProc(ByRef message As Message)
		Declare Static Sub HandleIsAllocated(ByRef Sender As Control)
	#endif
Protected:
	Declare Virtual Sub ProcessMessage(ByRef msg As Message)
Public:
	#ifndef ReadProperty_Off
		Declare Virtual Function ReadProperty(PropertyName As String) As Any Ptr
	#endif
	#ifndef WriteProperty_Off
		Declare Virtual Function WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
	#endif
	
	Declare Sub CreateWnd()
	
	'edit
	Declare Sub Redo()
	Declare Sub Undo()
	Declare Sub Cut()
	Declare Sub Copy()
	Declare Sub Paste()
	Declare Sub Clear()
	Declare Sub SelectAll()
	Declare Sub GotoLine(ByVal val As Integer)
	
	'search & replace
	Dim FindData As ZString Ptr = NULL
	Dim FindLength As Integer
	Dim FindPoses(Any) As Integer
	Dim FindLines(Any) As Integer
	Dim FindCount As Integer = -1
	Dim FindIndex As Integer = -1
	
	Declare Function IndexFind(ByVal FindWarp As Boolean = True, ByVal FindBack As Boolean = False, ByVal MoveNext As Boolean = False) As Integer
	Declare Function Find(ByRef FindData As Const ZString Ptr, ByVal RegularExp As Boolean = False, ByVal MatchCase As Boolean = False, ByVal FindWarp As Boolean = True, ByVal FindBack As Boolean = False, ByVal MoveNext As Boolean = False, ByVal FindForce As Boolean = False) As Integer
	Declare Function ReplaceAll(ByRef FindData As Const ZString Ptr, ByRef ReplaceData As Const ZString Ptr, ByVal RegularExp As Boolean = False, ByVal MatchCase As Boolean = False) As Integer
	
	'Indicator
	Declare Sub IndicatorClear()
	Declare Sub IndicatorSet(IndiPoses(Any) As Integer, ByVal IndiLength As Integer)
	Declare Property IndicatorSel As Integer
	Declare Property IndicatorSel(Val As Integer)
	
	'setting
	Declare Property EOLMode As Integer
	Declare Property EOLMode(ByVal val As Integer)
	Declare Property CodePage As Integer
	Declare Property CodePage(ByVal val As Integer)
	Declare Property CharSet(ByVal sty As Integer) As Integer
	Declare Property CharSet(ByVal sty As Integer, val As Integer)
	Declare Property WordWrap As Integer
	Declare Property WordWrap(ByVal val As Integer)
	
	Declare Property BackColor(ByVal sty As Integer) As Integer
	Declare Property BackColor(ByVal sty As Integer, ByVal val As Integer)
	Declare Property ForeColor(ByVal sty As Integer) As Integer
	Declare Property ForeColor(ByVal sty As Integer, ByVal val As Integer)
	Declare Property FontSize(ByVal sty As Integer) As Integer
	Declare Property FontSize(ByVal sty As Integer, ByVal val As Integer)
	Declare Property FontName(ByVal sty As Integer) ByRef As WString
	Declare Property FontName(ByVal sty As Integer, ByRef val As Const WString)
	
	Declare Property Bold(ByVal sty As Integer) As Integer
	Declare Property Bold(ByVal sty As Integer, ByVal val As Integer)
	Declare Property Italic(ByVal sty As Integer) As Integer
	Declare Property Italic(ByVal sty As Integer, ByVal val As Integer)
	Declare Property Underline(ByVal sty As Integer) As Integer
	Declare Property Underline(ByVal sty As Integer, ByVal val As Integer)
	
	Declare Property Zoom As Integer
	Declare Property Zoom(ByVal val As Integer)
	
	Declare Property CaretLineBackAlpha As Integer
	Declare Property CaretLineBackAlpha(ByVal val As Integer)
	Declare Property CaretLineBackColor As Integer
	Declare Property CaretLineBackColor(ByVal val As Integer)
	
	'Tabs and Indentation
	Declare Property UseTabs As Boolean
	Declare Property UseTabs (uTabs As Boolean)
	Declare Property TabWidth As Integer
	Declare Property TabWidth (tWidth As Integer)
	Declare Property IndentSize As Integer
	Declare Property IndentSize (iSize As Integer)
	Declare Property TabIndents As Boolean
	Declare Property TabIndents (tIndents As Boolean)
	
	'text
	Declare Property LineCount As Integer
	Declare Property LineStart(ByVal LineNo As Integer) As Integer
	Declare Property LineEnd(ByVal LineNo As Integer) As Integer
	Declare Property LineLength(ByVal LineNo As Integer) As Integer
	Declare Property LineData(ByVal LineNo As Integer) ByRef As Any Ptr
	Declare Property LineText(ByVal LineNo As Integer) ByRef As WString
	
	Declare Property Length As Integer
	Declare Property Text ByRef As WString
	Declare Property Text(ByRef tData As Const WString)
	Declare Property SelText ByRef As WString
	Declare Property SelText(ByRef tData As Const WString)
	
	Declare Property TxtData(tSize As Integer) ByRef As Any Ptr
	Declare Property TxtData(tSize As Integer, tData As Any Ptr)
	Declare Property SelTxtData ByRef As Any Ptr
	Declare Property SelTxtData(tData As Any Ptr)
	
	'view
	Declare Property DarkMode As Boolean
	Declare Property DarkMode (ByVal val As Boolean)
	Declare Property ViewWhiteSpace As Boolean
	Declare Property ViewWhiteSpace(ByVal val As Boolean)
	Declare Property ViewEOL As Boolean
	Declare Property ViewEOL (ByVal val As Boolean)
	Declare Property ViewCaretLine As Boolean
	Declare Property ViewCaretLine(ByVal val As Boolean)
	Declare Property ViewLineNo As Integer
	Declare Property ViewLineNo(ByVal val As Integer)
	Declare Property ViewFold As Integer
	Declare Property ViewFold(ByVal val As Integer)
	Declare Property MarginWidth(margin As Integer) As Integer
	Declare Property MarginWidth(margin As Integer, Val As Integer)
	Declare Sub MarginColor(ByVal margin As Integer = 0, ByVal fore As Integer = -1, ByVal back As Integer = -1)
	
	'selection
	Declare Sub SelColor(ByVal fore As Integer = -1, ByVal back As Integer = -1)
	Declare Property SelAlpha As Integer
	Declare Property SelAlpha(Val As Integer)
	Declare Property SelLayer As Integer
	Declare Property SelLayer(Val As Integer)
	
	Declare Function GetPosX(ByVal oPos As Integer = -1) As Integer
	Declare Function GetPosY(ByVal oPos As Integer = -1) As Integer
	Declare Property SelStart As Integer
	Declare Property SelStart(ByVal val As Integer)
	Declare Property SelEnd As Integer
	Declare Property SelEnd(ByVal val As Integer)
	Declare Property SelLength As Integer
	Declare Property SelLength(ByVal val As Integer)
	Declare Property TabIndex As Integer
	Declare Property TabIndex(Value As Integer)
	Declare Property TabStop As Boolean
	Declare Property TabStop(Value As Boolean)
	Declare Property Pos(ByVal val As Integer)
	Declare Property Pos As Integer
	Declare Property PosX As Integer
	Declare Property PosX(ByVal val As Integer)
	Declare Property PosY As Integer
	Declare Property PosY(ByVal val As Integer)
	
	OnUpdate As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ScintillaControl)
	OnModify As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ScintillaControl)
	OnDblClick As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ScintillaControl)
	
	Declare Constructor
	Declare Destructor
End Type

#ifndef __USE_MAKE__
	#include once "ScintillaControl.bas"
#endif
