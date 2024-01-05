'https://club.excelhome.net/thread-1303169-2-1.html
'################################################################################
'#  Com_HtmlFile1.frm                                                            #
'#  This file is an examples of MyFBFramework.                                  #
'#  Authors: Xusinboy Bekchanov, Liu XiaLin                                     #
'################################################################################

'A FreeBasic module that generates including files (not dependent on libraries) on the fly can be used to write  the code normally according to the COM and VBA syntax. Before compiling the code
'Click On COMWrapperBuilder in the Menu "Settings" To automatically generate a reference header FILE that calls Com. Add "#include once 'Com_xxx.bi" in the code including area.

'一个即时翻译生成头文件（不依赖于库）的 FreeBasic 调用Com的模块，你可以先按照COM和VBA语法正常必须代码，在编译代码前
'点击菜单”设置”里的COMWrapperBuilder,将自动生成调用com的引用头文件。在代码引用区加入”#include once "Com_xxx.bi"即可

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form2.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/CommandButton.bi"
	#include once "Com_Msxml2.bi"
	#include once "Com_HTMLFILE.bi"
	#include once "mff/TextBox.bi"
	
	Using My.Sys.Forms
	
	Type Form2Type Extends Form
		Declare Sub cmdJson00_Click(ByRef Sender As Control)
		Declare Sub cmdJson2_Click(ByRef Sender As Control)
		Declare Sub cmdShowForm1_Click(ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Constructor
		
		Dim As CommandButton cmdJson00, cmdJson001, cmdJson002, cmdJson2, cmdShowForm1
		Dim As TextBox TextBox1
	End Type
	
	Constructor Form2Type
		' Form2
		With This
			.Name = "Form2"
			.Text = "Form2"
			.Designer = @This
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.SetBounds 0, 0, 350, 300
		End With
		' cmdJson00
		With cmdJson00
			.Name = "cmdJson00"
			.Text = "cmdJson00"
			.TabIndex = 0
			.Anchor.Top = AnchorStyle.asAnchor
			.SetBounds 10, 0, 60, 30
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdJson00_Click)
			.Parent = @This
		End With
		' cmdJson001
		With cmdJson001
			.Name = "cmdJson001"
			.Text = "cmdJson0"
			.TabIndex = 1
			.ControlIndex = 0
			.Anchor.Top = AnchorStyle.asAnchor
			.SetBounds 10, 30, 60, 30
			.Designer = @This
			.Parent = @This
		End With
		' cmdJson002
		With cmdJson002
			.Name = "cmdJson002"
			.Text = "cmdJson00"
			.TabIndex = 2
			.ControlIndex = 1
			.Anchor.Top = AnchorStyle.asAnchor
			.SetBounds 90, 30, 60, 30
			.Designer = @This
			.Parent = @This
		End With
		' cmdJson2
		With cmdJson2
			.Name = "cmdJson2"
			.Text = "Json2"
			.TabIndex = 3
			.ControlIndex = 2
			.Caption = "Json2"
			.Anchor.Top = AnchorStyle.asAnchor
			.SetBounds 90, 0, 60, 30
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdJson2_Click)
			.Parent = @This
		End With
		' cmdShowForm1
		With cmdShowForm1
			.Name = "cmdShowForm1"
			.Text = "ShowForm1"
			.TabIndex = 4
			.ControlIndex = 3
			.SetBounds 220, 30, 60, 30
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdShowForm1_Click)
			.Parent = @This
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = "TextBox1"
			.TabIndex = 5
			.Multiline = True
			.ID = 1007
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
	
	Dim Shared Form2 As Form2Type
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		Form2.MainForm = True
		Form2.Show
		App.Run
	#endif
'#End Region

Private Sub Form2Type.cmdJson00_Click(ByRef Sender As Control)
	Dim As Object_HTMLFILE oDom = CreateObject("HTMLFILE")
	Dim As Object_HTMLFILE oWindow = oDom.parentWindow
	oWindow.execScript("var d=new Date() ; t=d.getTime()")
	Dim As String t = oWindow. eval( "t")
	TextBox1.Text = TextBox1.Text & Chr(13, 10) & "from 1970/01/01 time has passed " & t & "mi11iseconds"
	TextBox1.Text = TextBox1.Text & Chr(13, 10) & "-------------------------------------------------------"
	
	Dim json As String = "{'a':1,'b':[2,3]}"
	oWindow.execScript("var js=" & json)
	Dim As String strHtml = oWindow.eval("js['b'] [1]")
	TextBox1.Text = TextBox1.Text & Chr(13, 10) & strHtml
End Sub

Private Sub Form2Type.cmdJson2_Click(ByRef Sender As Control)
	Dim As Object_HTMLFILE oDom = CreateObject("HTMLFILE")
	Dim As Object_HTMLFILE oWindow = oDom.parentWindow
	Dim As Object_Msxml2 oHttp = CreateObject("Msxml2.XMLHTTP")
	oHttp.Open "GET", "https://www.msn.com", False
    oHttp.send
    Dim As String strHtml = oHttp.responseText ' 得到数据
    'oWindow.clipboardData.SetData "text", strHtml '写入剪贴板
    'oWindow.execScript "var js= " & strHtml  ' 改写成对象创建语句
    'Dim As vbVariant kuwo = oWindow.js ' 获取解析后的对象
    TextBox1.Text = strHtml  'kuwo.view
End Sub

Private Sub Form2Type.cmdShowForm1_Click(ByRef Sender As Control)
	Form1.Show
End Sub

Private Sub Form2Type.Form_Create(ByRef Sender As Control)
	
End Sub
