'https://club.excelhome.net/thread-1303169-2-1.html

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/CommandButton.bi"
	#include once "Com_Msxml2.bi"
	#include once "Com_HTMLFILE.bi"
	#include once "mff/TextBox.bi"
	
	Using My.Sys.Forms
	
	Type Form1Type Extends Form
		Declare Sub cmdJson_Click(ByRef Sender As Control)
		Declare Sub cmdJson2_Click(ByRef Sender As Control)
		Declare Sub cmdShow2_Click(ByRef Sender As Control)
		Declare Sub Form_Click(ByRef Sender As Control)
		Declare Constructor
		
		Dim As CommandButton cmdJson, cmdJson1, cmdJson2, cmdJson3, cmdShow2
		Dim As TextBox TextBox1
	End Type
	
	Constructor Form1Type
		' Form1
		With This
			.Name = "Form1"
			.Text = "Form1"
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Click)
			.SetBounds 0, 0, 350, 300
		End With
		' cmdJson
		With cmdJson
			.Name = "cmdJson"
			.Text = "Json"
			.TabIndex = 0
			.SetBounds 10, 10, 60, 30
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdJson_Click)
			.Parent = @This
		End With
		' cmdJson1
		With cmdJson1
			.Name = "cmdJson1"
			.Text = "cmdJson"
			.TabIndex = 1
			.ControlIndex = 0
			.SetBounds 10, 40, 60, 30
			.Designer = @This
			.Parent = @This
		End With
		' cmdJson2
		With cmdJson2
			.Name = "cmdJson2"
			.Text = "cmdJson"
			.TabIndex = 2
			.ControlIndex = 1
			.SetBounds 80, 40, 40, 30
			.Designer = @This
			.Parent = @This
		End With
		' cmdJson3
		With cmdJson3
			.Name = "cmdJson3"
			.Text = "Json2"
			.TabIndex = 3
			.ControlIndex = 2
			.Caption = "Json3"
			.SetBounds 80, 10, 40, 30
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdJson2_Click)
			.Parent = @This
		End With
		' cmdShow2
		With cmdShow2
			.Name = "cmdShow2"
			.Text = "ShowForm2"
			.TabIndex = 4
			.ControlIndex = 3
			.SetBounds 130, 10, 60, 30
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdShow2_Click)
			.Parent = @This
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = "TextBox1"
			.TabIndex = 4
			.ControlIndex = 4
			.Multiline = True
			.ScrollBars = ScrollBarsType.Both
			.Anchor.Right = AnchorStyle.asAnchor
			.Anchor.Bottom = AnchorStyle.asAnchor
			.Anchor.Top = AnchorStyle.asAnchor
			.Anchor.Left = AnchorStyle.asAnchor
			.SetBounds 10, 70, 320, 180
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared Form1 As Form1Type
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		Form1.MainForm = True
		Form1.Show
		App.Run
	#endif
'#End Region

Private Sub Form1Type.cmdJson_Click(ByRef Sender As Control)
	Dim As Object_HTMLFILE oDom = CreateObject("HTMLFILE") '2323
	Dim As Object_HTMLFILE oWindow = oDom.parentWindow
	oWindow.execScript("var d=new Date() ; t=d.getTime()")
	Dim As String t = oWindow. eval( "t")
	Print "from 1970/01/01 time has passed " & t & "mi11iseconds"
	Print "-------------------------------------------------------"
	
	Dim json As String = "{'a':1,'b':[2,3]}"
	oWindow.execScript("var js=" & json)
	Print oWindow.eval("js['b'] [1]")
End Sub

Private Sub Form1Type.cmdJson2_Click(ByRef Sender As Control)
	'https://cloud.tencent.com/developer/ask/sof/359206
	Dim As Object_HTMLFILE oDom = CreateObject("HTMLFILE") '2323
	Dim As Object_HTMLFILE oWindow = oDom.parentWindow
	Dim As Object_Msxml2 oHttp = CreateObject("Msxml2.XMLHTTP")
	oHttp.Open "GET", "https://www.marketscreener.com/COLUMBIA-SPORTSWEAR-COMPA-8859/company/", False
    oHttp.send
    Dim As String strHtml = oHttp.responseText ' 得到数据
    'Window.clipboardData.SetData "text", strHtml '写入剪贴板
    'Dim As Object_Msxml2 oName = oDom.getElementsByTagName("table")
    'Print oName(0).innerHTML
    'oWindow.execScript "var js= " & strHtml  ' 改写成对象创建语句
    'Dim As vbVariant kuwo = oWindow.js ' 获取解析后的对象
    TextBox1.Text = strHtml  'kuwo.view
End Sub
#include once "Com_HtmlFile2.frm"
Private Sub Form1Type.cmdShow2_Click(ByRef Sender As Control)
	Form2.Show
End Sub

Private Sub Form1Type.Form_Click(ByRef Sender As Control)
	
End Sub
