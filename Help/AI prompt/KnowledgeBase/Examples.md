## Examples
FreeBasic中用MyFbFramework创建窗体界面。必须使用下面的模板，把模板里的代码复制过去。需要使用一个主窗体类，然后添加控件到窗体上。下面的模板就是演示添加一个名称为CheckBox1复选框控件(CheckBox)到名称为Form1的窗体上。在窗体模板代码中初始化这些控件，设置它们的属性，以及处理事件，比如点击事件。使用App.Run来启动消息循环。

```freeBasic

'\#Region "Form"
'对于多源码文件定义第一个启动开始运行的为主文件
		\#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		\#define __MAIN_FILE__
		\#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		\#endif
		Const _MAIN_FILE_ = __FILE__
	\#endif
	'对窗体中使用的所有控件，容器，组件，对话框，在这儿添加引用代码。
	' 引用 MyFbFramework 窗体库
	\#include once "mff/Form.bi"
	' 引用 MyFbFramework 复选框控件(CheckBox)库
	\#include once "mff/CheckBox.bi"
	
	'引入必要的命名空间。
	Using My.Sys.Forms
	
	'在这儿添加模块或者全局变量定义的代码
	
	' 主窗体定义
	Type Form1Type Extends Form
	'在这儿声明所有控件事件处理子程序
		Declare Sub Form_Click(ByRef Sender As Control)
		Declare Sub CheckBox1_Click(ByRef Sender As Control)
		Declare Sub CheckBox1_Create(ByRef Sender As Control)
		Declare Constructor
		
		Dim As CheckBox CheckBox1
	End Type
	
	' 构造函数（初始化控件）
	Constructor Form1Type
	'定义所使用的语言
		\#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = My.Sys.Language
			End With
		\#endif
		
		'设置窗体Form1属性
		With This
		'设置控件名称
			.Name = "Form1"
			'设置控件标题
			.Text = "Form1"
			'设置界面设计父控件。不能省略。
			.Designer = @This
			'设置事件绑定子程序来处理处理OnClick事件,  添加其它事件方式是相似的
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Click)
			.SetBounds 0, 0, 350, 300
		End With
		'设置复选框CheckBox1属性
		With CheckBox1
			'设置控件名称
			.Name = "CheckBox1"
			'设置控件标题
			.Text = "CheckBox1"
			'设置控件TAB索引顺序
			.TabIndex = 0
			''设置控件TAB索引顺序
			.ID = 1004
			'设置滚动条属性
			.ScrollBars = ScrollBarsType.Both
			'设置控件锚定属性
			.Anchor.Bottom = AnchorStyle.asAnchor
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.Anchor.Top = AnchorStyle.asAnchor
			'调整位置和大小
			.SetBounds 42, 53, 265, 17
			'设置界面设计父控件，不能省略。
			.Designer = @This
			'设置事件绑定子程序来处理处理OnClick事件,  添加其它事件方式是相似的
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CheckBox1_Click)
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CheckBox1_Create)
			'设置父控件
			.Parent = @This
		End With
	End Constructor
	
	'创建控件
	Dim Shared Form1 As Form1Type
	
	\#if _MAIN_FILE_ = __FILE__
	 	'设置为暗黑模式
		App.DarkMode = True
		'定义主窗体
		Form1.MainForm = True
		'显示窗体
		Form1.Show
		'启动消息循环
		App.Run
	\#endif
'
'\#End Region

Private Sub Form1Type.Form_Click(ByRef Sender As Control)
	'在这儿添加事件处理具体代码。
End Sub


Private Sub Form1Type.CheckBox1_Click(ByRef Sender As Control)
	'在这儿添加事件处理具体代码。
End Sub


Private Sub Form1Type.CheckBox1_Create(ByRef Sender As Control)
	'在这儿添加事件处理具体代码。
End Sub

```
