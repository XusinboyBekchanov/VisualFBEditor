Language: <a href="README.md">English</a> | <b>中文介绍</b>
# Visual FB Editor
## IDE for FreeBasic

Visual FreeBasic Editor可以生成在Windows,Linux, Dos，Android下使用的32位及64位绿色免安装程序，语言风格类似VB.NET的Basic语言。如果你觉得需要某个新功能，你可以自己在Visual FreeBasic Editor源代码基础上修改，自己使用。如果你想向大家推荐，可以把修改后的源代码发给作者，集成到官方版本里。

Visual FreeBasic Editor使用MyFbFramework框架，MyFbFramework框架是类C语言的Basic语系的freeBASIC编程语言编写的公用，基本控件库，目前共有83个公用类，控件。语法在本质上类似于编程语言 vb.net， 使用这些类即可快速、轻松地创建类型安全软件产品。
MyFbFramework框架地址： <a href="https://github.com/XusinboyBekchanov/MyFbFramework">MyFbFramework</a>.

#### 运行要求:

需要另外下载FreeBASIC编译器（至少需要1.10.0版本），FreeBASIC编译器官方地址:  <a href="http://www.freebasic.net">http://www.freebasic.net</a>.
FreeBASIC编译器其他下载地址1：<a href="http://users.freebasic-portal.de/stw/builds/">http://users.freebasic-portal.de/stw/builds/</a>.

#### 屏幕截图
![VisualFBEditor-1](https://user-images.githubusercontent.com/35757455/197079538-16cc5d7d-150e-46f1-b673-f9fe7352ad17.png)
![VisualFBEditor-2](https://user-images.githubusercontent.com/35757455/197079581-596100e9-86be-4469-8aae-104309845b2c.png)
![VisualFBEditor-3](https://user-images.githubusercontent.com/35757455/197079617-4c4d6902-3809-40da-a746-46bcdf993a75.png)
![VisualFBEditor-4](https://user-images.githubusercontent.com/35757455/197079674-2a2a685e-2403-4b8b-9b3b-95c4cc8bf5dc.png)
![VisualFBEditor-5](https://user-images.githubusercontent.com/35757455/197079706-5419cc84-db93-48b2-93f9-456db2414956.png)
![VisualFBEditor-6](https://user-images.githubusercontent.com/35757455/197079725-a88431cb-34e7-4a75-be8f-cd7f3f845ce5.png)

#### 程序编译方法:
你可以使用下面提供的方法用命令行进行程序编译，也可以在VisualFBEditor可视化编辑器中打开源程序进行编译。在编译项目之前要在“设置”里配置好编译器的路径，还要设置 MyFbFramework框架的路径。

切记：MyFbFramework框架目录下如果没有 mff64.dll和libmff64.dll.a（运行64位系统VisualFBEditor）,mff32.dll和libmff32.dll.a（运行32位系统VisualFBEditor） 你将不能进行可视化窗体设计。你可以下载MyFbFramework框架源码并按照下面提供的方法进行编译。freeBasic有很多第三方库支持，可以通过安装Msys2后下载。

在下面提供的进行命令行程序编译中，编译器的路径，和MyFbFramework框架的路径也要改为在你电脑中的实际地址，在旧版中不支持相对路径，如果出现找不到文件的情况，请把相应的编译器的路径，和MyFbFramework框架的路径在“设置”里配置为绝对路径。 

#### 已知问题:
VisualFBEditor代码窗口和微软的拼音有冲突出现假死，解决办法是在微软的拼音设置里把“使用以前版本的微软拼音输入法”打开或者安装其他输入法。

#### 编译在操作系统 Windows 32-bit:
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -s gui -x "../VisualFBEditor32.exe" "VisualFBEditor.rc" -i "Path_to_VisualFBEditor/MyFbFramework"
  cd Path_to_VisualFBEditor/MyFbFramework/mff
  fbc -b "mff.bi" "mff.rc" -dll -x "../mff32.dll"
```
#### 编译在操作系统 Windows 32-bit (for gtk2):
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -s gui -x "../VisualFBEditor32_gtk2.exe" "VisualFBEditor.rc" -d __USE_GTK__ -i "Path_to_VisualFBEditor/MyFbFramework" -p "Path_to_msys2\msys32\mingw32\lib"
  cd Path_to_VisualFBEditor/MyFbFramework/mff
  fbc -b "mff.bi" "mff.rc" -dll -x "../mff32_gtk2.dll" -d __USE_GTK__ -p "Path_to_msys2\msys32\mingw32\lib"
```
#### 编译在操作系统 Windows 32-bit (for gtk3):
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -s gui -x "../VisualFBEditor32_gtk3.exe" "VisualFBEditor.rc" -d __USE_GTK__ -d __USE_GTK3__ -i "Path_to_VisualFBEditor/MyFbFramework" -p "Path_to_msys2\msys32\mingw32\lib"
  cd Path_to_VisualFBEditor/MyFbFramework/mff
  fbc -b "mff.bi" "mff.rc" -dll -x "../mff32_gtk3.dll" -d __USE_GTK__ -d __USE_GTK3__ -p "Path_to_msys2\msys32\mingw32\lib"
```
#### 编译在操作系统 Windows 64-bit:
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -s gui -x "../VisualFBEditor64.exe" "VisualFBEditor.rc" -i "Path_to_VisualFBEditor/MyFbFramework"
  cd Path_to_VisualFBEditor/MyFbFramework/mff
  fbc -b "mff.bi" "mff.rc" -dll -x "../mff64.dll"
```
#### 编译在操作系统 Windows 64-bit (for gtk2):
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -s gui -x "../VisualFBEditor64_gtk2.exe" "VisualFBEditor.rc" -d __USE_GTK__ -i "Path_to_VisualFBEditor/MyFbFramework" -p "Path_to_msys2\msys32\mingw64\lib"
  cd Path_to_VisualFBEditor/MyFbFramework/mff
  fbc -b "mff.bi" "mff.rc" -dll -x "../mff64_gtk2.dll" -d __USE_GTK__ -p "Path_to_msys2\msys32\mingw64\lib"
```
#### 编译在操作系统 Windows 64-bit (for gtk3):
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -s gui -x "../VisualFBEditor64_gtk3.exe" "VisualFBEditor.rc" -d __USE_GTK__ -d __USE_GTK3__ -i "Path_to_VisualFBEditor/MyFbFramework" -p "Path_to_msys2\msys32\mingw64\lib"
  cd Path_to_VisualFBEditor/MyFbFramework/mff
  fbc -b "mff.bi" "mff.rc" -dll -x "../mff64_gtk3.dll" -d __USE_GTK__ -d __USE_GTK3__ -p "Path_to_msys2\msys32\mingw64\lib"
```
#### 编译在操作系统 Linux 32-bit (for gtk2):
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -x "../VisualFBEditor32_gtk2" -i "Path_to_VisualFBEditor/MyFbFramework"
  cd Path_to_VisualFBEditor/MyFbFramework/mff
  fbc -b "mff.bi" -dll -x "../libmff32_gtk2.so"
```
#### 编译在操作系统 Linux 32-bit (for gtk3):
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -x "../VisualFBEditor32_gtk3" -i "Path_to_VisualFBEditor/MyFbFramework" -d __USE_GTK3__
  cd Path_to_VisualFBEditor/MyFbFramework/mff
  fbc -b "mff.bi" -dll -x "../libmff32_gtk3.so" -d __USE_GTK3__
```
#### 编译在操作系统 Linux 64-bit (for gtk2):
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -x "../VisualFBEditor64_gtk2" -i "Path_to_VisualFBEditor/MyFbFramework"
  cd Path_to_VisualFBEditor/MyFbFramework/mff
  fbc -b "mff.bi" -dll -x "../libmff64_gtk2.so"
```
#### 编译在操作系统 Linux 64-bit (for gtk3):
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -x "../VisualFBEditor64_gtk3" -i "Path_to_VisualFBEditor/MyFbFramework" -d __USE_GTK3__
  cd Path_to_VisualFBEditor/MyFbFramework/mff
  fbc -b "mff.bi" -dll -x "../libmff64_gtk3.so" -d __USE_GTK3__
```
#### Sample bat file:
```shell
REM Sample Windows 64 bit Build
REM CHANGE YOUR SETUP / PATHS
REM Change path to the VisualFBEditor source
c:
cd "C:\FreeBasic\Projects\VisualFBEditor-master\src"
REM A Copy of the MyFbFramework was also placed to
REM "C:\FreeBasic\Projects\VisualFBEditor-master\MyFbFramework"
REM the 64 bit FreeBasic compiler is located in
REM "C:\FreeBasic\X64\fbc.exe"
REM "Version 1.08.0 64 bit Windows build"
REM BUILD COMMAND
"C:\FreeBasic\X64\fbc.exe" "VisualFBEditor.bas" "VisualFBEditor.rc" -s gui -x "../VisualFBEditor64.exe" -i "C:\FreeBasic\Projects\VisualFBEditor-master\MyFbFramework"
REM Change path to the MyFbFramework source
cd "C:\FreeBasic\Projects\VisualFBEditor-master\MyFbFramework\mff"
"C:\FreeBasic\X64\fbc.exe" -b "mff.bi" "mff.rc" -dll -x "..\mff64.dll"
```

# MyFbFramework介绍
MyFbFramework是类Basic语言的freeBASIC编程语言编写的公用，基本控件库，目前共有83个公用类，控件。语法在本质上类似于编程语言 vb.net， 使用这些类即可快速、轻松地创建类型安全软件产品。

|文件|功能|说明|
| ---------- | ----------- | ----------- |
|Animate.bas|动画控件||
|Application.bas|应用程序模块|提供与当前应用程序相关的属性、方法和事件。|
|Bitmap.bas|位图控件||
|Brush.bas|画笔控件||
|Canvas.bas|画布模块||
|Chart.bas|图标控件||
|CheckBox.bas|多选框控件||
|CheckedListBox.bas|多选框列表控件||
|Classes.bas|类管理模块||
|Clipboard.bas|剪切板控件||
|ComboBoxEdit.bas|组合框控件||
|ComboBoxEx.bas|超级组合框控件||
|CommandButton.bas|命令按钮控件||
|Component.bas|容器控件||
|ContainerControl.bas|容器管理控件|为可用作其他控件的容器的控件提供焦点管理功能。|
|Control.bas|控件管理控件||
|Cursor.bas|鼠标指针模块|用于绘制鼠标指针的图像。|
|DateTimePicker.bas|日期时间控件||
|Dialogs.bas|对话选择框控件||
|Dictionary.bas|字典模块||
|DoubleList.bas|双精度链表||
|Font.bas|字体模块||
|Form.bas|窗体控件||
|Graphic.bas|图像模块||
|Graphics.bas|图像类模块||
|Grid.bas|表格控件||
|GroupBox.bas|组合框容器|用于对控件集合进行分组。|
|Header.bas|标题控件||
|HotKey.bas|热键控件||
|HScrollBar.bas|水平滚动条控件||
|Icon.bas|Icon图标模块||
|ImageBox.bas|图像框控件|| 
|ImageList.bas|图像列表模块||
|IniFile.bas|配置文件模块||
|IntegerList.bas|整型链表||
|IPAddress.bas|IP地址控件||
|Label.bas|标签控件||
|LinkLabel.bas|超链接标签控件||
|List.bas|顺序链表||
|ListControl.bas|控件链表|为 ListBox 类和 ComboBox 类提供一个共同的成员实现方法。|
|ListView.bas|列表视图控件|该控件显示可用四种不同视图之一显示的项集合。|
|Menus.bas|菜单控件||
|MonthCalendar.bas|月历日期控件|该控件使用户能够使用可视月历显示来选择日期。|
|NativeFontControl.bas|字体控件|
|Object.bas|对象模块||
|OpenFileControl.bas|标准文件打开对话模块|显示一个标准对话框，提示用户打开文件。|
|PageScroller.bas|翻页模块||
|PageSetupDialog.bas|页面设置模块||
|Panel.bas|面板容器|用于对控件集合进行分组。|
|Pen.bas|画笔控件||
|Picture.bas|图片框控件|表示用于显示或绘制图像的图片框控件。|
|PrintDialog.bas|打印对话框||
|Printer.bas|打印机管理控件||  
|PrintPreviewDialog.bas|打印预览控件||
|ProgressBar.bas|进度栏控件||
|RadioButton.bas|单选控件|当与其他 RadioButton 控件成对出现时，使用户能够从一组选项中选择一个选项。|
|ReBar.bas|窗体容器||
|Registry.bas|注册表模块||
|RichTextBox.bas|超文本框控件||
|ScrollBarControl.bas|自动滚动模块|为支持自动滚动行为的控件定义一个基类。|
|Splitter.bas|拆分器控件|表示允许用户调整停靠控件大小的拆分器控件。|
|StatusBar.bas|状态栏控件||
|StringList.bas|文本链表||
|SysUtils.bas|公用系统模块||
|TabControl.bas|选项卡控件||
|TextBox.bas|文本控件||
|TimerComponent.bas|定时器模块||
|ToolBar.bas|工具栏控件||
|ToolPalette.bas|工具栏容器||
|ToolTips.bas|文本提示框控件||
|TrackBar.bas|跟踪条控件||
|TreeListView.bas|树形列表控件||
|TreeView.bas|树形控件||
|UpDown.bas|上下选择框||
|UserControl.bas|用户自定义模块||
|UString.bas|宽字符模块||
|VScrollBar.bas|垂直滚动条||
|WebBrowser.bas|网页浏览器控件||
|WStringList.bas|宽字符链表||

