# MyFbFramework GUI Form Interface Guidelines
## MyFbFramework Overview
MyFbFramework is a forms building, drawing and etc. library for the FreeBasic programming language. This library helps in the development of software products using easy-to-use classes and syntax, which are similar in nature to the programming language vb.net.

## MyFbFramework controls and objects
`[MyFbFramework](Readme.md")` (commonly abbreviated as `MFF`) framework includes 39 controls, 13 Containers, 9 Components, 8 Dialogs. Detailed in the table below.

### Controls
The MyFbFramework framework includes 39 controls: Animate, Chart, CheckBox, CheckedListBox, ComboBoxEdit, ComboBoxEx, CommandButton, DateTimePicker, Grid, Header, HotKey, HScrollBar, ImageBox, IPAddress, Label, LinkLabel, ListControl, ListView, MonthCalendar, NumericUpDown, OpenFileControl, PrintPreviewControl, ProgressBar, RadioButton, RichTextBox, ScrollBarControl, SearchBox, Splitter, StatusBar, TextBox, ToolBar, ToolPalette, ToolTips, TrackBar, TreeListView, TreeView, UpDown, VScrollBar, WebBrowser. Detailed in the table below.
[Animate](Animate.md): An animate control is a window that displays an Audio-Video Interleaved (AVI) clip.
[Chart](Chart.md): The Chart control is a chart object that exposes events.
[CheckBox](CheckBox.md): Displays an V when selected; the V disappears when the CheckBox is cleared.
[CheckedListBox](CheckedListBox.md): Displays a ListBox in which a check box is displayed to the left of each item.
[ComboBoxEdit](ComboBoxEdit.md): Combines the features of a TextBox and a ListControl.
[ComboBoxEx](ComboBoxEx.md): ComboBoxEx is an enhanced version of ComboBoxEdit, inheriting its core functionality while adding advanced features such as the ability to display images for each item.
[CommandButton](CommandButton.md): Looks like a push button and is used to begin, interrupt, or end a process.
[DateTimePicker](DateTimePicker.md): Represents a Windows control that allows the user to select a date and a time and to display the date and time with a specified format.
[Grid](Grid.md): Defines a flexible grid area that consists of columns and rows.
[Header](Header.md): A header control is a window that is usually positioned above columns of text or numbers.
[HotKey](HotKey.md): A hot key control is a window that enables the user to enter a combination of keystrokes to be used as a hot key.
[HScrollBar](HScrollBar.md): Provides a horizontal scroll bar for easy navigation through long lists of items.
[ImageBox](ImageBox.md): Displays a graphic.
[IPAddress](IPAddress.md): An Internet Protocol (IP) address control allows the user to enter an IP address in an easily understood format.
[Label](Label.md): Displays text that a user can't change directly.
[LinkLabel](LinkLabel.md): Represents a label control that can display hyperlinks.
[ListControl](ListControl.md): Displays a list of items from which the user can select one or more.
[ListView](ListView.md): Represents a control that displays a list of data items.
[MonthCalendar](MonthCalendar.md): Represents a control that enables the user to select a date using a visual monthly calendar display.
[NumericUpDown](NumericUpDown.md): Represents a spin box (also known as an up-down control) that displays numeric values.
[OpenFileControl](OpenFileControl.md): Represents a box for choosing files.
[PrintPreviewControl](PrintPreviewControl.md): Represents the raw preview part of print previewing, without any dialog boxes or buttons.
[ProgressBar](ProgressBar.md): A progress bar is a window that an application can use to indicate the progress of a lengthy operation.
[RadioButton](RadioButton.md): Displays an option that can be turned on or off.
[RichTextBox](RichTextBox.md): The RichTextBox control enables you to display or edit flow content including paragraphs, images, tables, and more.
[ScrollBarControl](ScrollBarControl.md): Provides a horizontal and a vertical scroll bar for easy navigation through long lists of items.
[SearchBox](SearchBox.md): A subclass of TextBox that has been tailored for use as a search textbox.
[Splitter](Splitter.md): Represents a splitter control that enables the user to resize docked controls.
[StatusBar](StatusBar.md): A status bar is a horizontal window at the bottom of a parent window in which an application can display various kinds of status information.
[TextBox](TextBox.md): Displays information entered at design time by the user, or in code at run time.
[ToolBar](ToolBar.md): A toolbar is a control that contains one or more buttons.
[ToolPalette](ToolPalette.md): A tool palette with categories.
[ToolTips](ToolTips.md): An element in which, when hovering over a marker or region element or component, a text box displays information about that element.
[TrackBar](TrackBar.md): A trackbar is a window that contains a slider (sometimes called a thumb) in a channel, and optional tick marks.
[TreeListView](TreeListView.md): Combines the features of a TreeView and a ListView.
[TreeView](TreeView.md): Represents a control that displays hierarchical data in a tree structure that has items that can expand and collapse.
[UpDown](UpDown.md): An up-down control is a pair of arrow buttons that the user can click to increment or decrement a value, such as a scroll position or a number displayed in a companion control (called a buddy window).
[VScrollBar](VScrollBar.md): Provides a vertical scroll bar.
[WebBrowser](WebBrowser.md): Enables the user to navigate Web pages inside your form.

### Containers
The MyFbFramework framework includes 13 Containers: Form, GroupBox, HorizontalBox, PagePanel, PageScroller, Panel, Picture, ReBar, ScrollControl, TabControl, TabPage, VerticalBox, UserControl. Detailed in the table below.
[Form](Form.md): A window or dialog box that makes up part of an application's user interface.
[GroupBox](GroupBox.md): Provides an identifiable grouping for controls.
[HorizontalBox](HorizontalBox.md): Arranges items in a horizontal row.
[PagePanel](PagePanel.md): Used to organize controls on hidden panels.
[PageScroller](PageScroller.md): The PageScroller control is used to scroll a panel along with the components placed on it.
[Panel](Panel.md): Used to group collections of controls.
[Picture](Picture.md): Displays a graphic from a bitmap, icon or metafile.
[ReBar](ReBar.md): A Rebar control acts as a container for child windows. It can contain one or more bands, and each band can have any combination of a gripper bar, a bitmap, a text label, and one child window.
[ScrollControl](ScrollControl.md): A container that makes its child scrollable.
[TabControl](TabControl.md): Represents a control that contains multiple items that share the same space on the screen.
[TabPage](TabPage.md): Represents a single tab page in a TabControl.
[UserControl](UserControl.md): Provides an empty control that can be used to create other controls. A Control authored in VisualFBEditor
[VerticalBox](VerticalBox.md): Arranges items in a vertical column.

### Components
The MyFbFramework framework includes 9 Components: HTTPConnection, HTTPServer, ImageList, MainMenu, PopUpMenu, PrintDocument, Printer, SQLite3Component, TimerComponent. Detailed in the table below.
[HTTPConnection](HTTPConnection.md): Constructs a connection to the host (port) as given in the url.
[HTTPServer](HTTPServer.md): Implements a simple HTTP server.
[ImageList](ImageList.md): An image list is a collection of images of the same size, each of which can be referred to by its index.
[MainMenu](MainMenu.md): Represents the menu structure of a form.
[MariaDBBox](MariaDBBox.md): A container that provides a pre-installed and configured environment for working with the MariaDB database.
[PopUpMenu](PopUpMenu.md): Represents a context menu.
[PrintDocument](PrintDocument.md): Defines a reusable object that sends output to a printer, when printing.
[Printer](Printer.md): Enables you to communicate with a system printer (initially the default printer).
[SQLite3Component](SQLite3Component.md): A component that facilitates integration with the SQLite3 database.
[TimerComponent](TimerComponent.md): A control which can execute code at regular intervals by causing a Timer event.

### Dialogs
The MyFbFramework framework includes 8 Dialogs: ColorDialog, FolderBrowserDialog, FontDialog, OpenFileDialog, PageSetupDialog, PrintDialog, PrintPreviewDialog, SaveFileDialog. Detailed in the table below.
[ColorDialog](ColorDialog.md): Represents a common dialog box that displays available colors along with controls that enable the user to define custom colors.
[FolderBrowserDialog](FolderBrowserDialog.md): Prompts the user to select a folder.
[FontDialog](FontDialog.md): Prompts the user to choose a font from among those installed on the local computer.
[OpenFileDialog](OpenFileDialog.md): Displays a standard dialog box that prompts the user to open a file.
[PageSetupDialog](PageSetupDialog.md): Enables users to change page-related print settings, including margins and paper orientation.
[PrintDialog](PrintDialog.md): Lets users select a printer and choose which sections of the document to print from an application.
[PrintPreviewDialog](PrintPreviewDialog.md): Represents the raw preview part of print previewing from an application.
[SaveFileDialog](SaveFileDialog.md): Prompts the user to select a location for saving a file.

## Code Structure Specifications
### Project File Structure
 [VisualFBEditor](VisualFBEditor IDE Environment.md) and [MyFbFramework](Readme.md) support editing project files.
 These project files use the .vfp extension.
 Multiple `.vfp` files can be combined into `.vfs` project groups
### File Type Conventions
 Form files: Use the .frm extension.
 Module files: Use the .bas extension.
 Header files: Use the .bi extension.
 The `[file name]:` marker in documentation denotes file names, with `[file content begin]` and `[file content end]` delimiting content boundaries.
### Required header preprocessor directive
 ```freebasic
 \#include once "mff/Form.bi"  ' Main form header
 \#include once "mff/<ControlName>.bi" ' Control-specific header
 ```
### Preprocessor Directive Syntax Error (ERR_MISSING_HASH)
 1. Error Description
 **`cmdline`/`ifdef`/`include` /`define`recognized as invalid preprocessor directives** 
This error occurs when preprocessor directives are missing the required `#` prefix, causing the compiler to interpret them as regular code identifiers.
 2. Root Cause Analysis
| Invalid Syntax | Valid Syntax | Missing Element |
|---------------------|----------------------|-----------------|
| `include once ...` | `#include once ...` | `#` prefix |
| `ifdef __FB_WIN32__`| `#ifdef __FB_WIN32__`| Leading `#` |
| `cmdline "res.rc"` | `#cmdline "res.rc"` | Directive marker|
 3. Auto-Correction Mechanism
 Auto-insert # when detecting known preprocessor keywords at line start
 **Pattern Recognition**:
```plaintext
 ^\s*(include|ifdef|ifndef|endif|cmdline|define)\b ¡ú Add #
 ``` 
### Reserved keywords
 1. Variable Naming
 Avoid FreeBasic keywords (e.g., `Width`, `Height`, `Left`, `Pos`). Instead, use prefixes like `_` or `i` for differentiation. For more details, refer to the [FreeBasic documentation](https://www.freebasic.net/wiki/DocToc).
 2. Inclusion Directives
 Using `#include` instead of `include` 
 3. Conditional Logic
 Use `#if` for conditional compilation
 Avoid using if statements for compilation directives
 4. Loop Structures
 Use standard For loops instead of unsupported for each
### String handling
 Access characters using index notation: mainString[n]
 Avoid manual pointer conversion for string operations
### Mandatory declarations
 Mandatory explicit typing in `DIM` statements
### GUI framework
 Mandatory use [MyFbFramework](Readme.md) (MFF) as default GUI framework when unspecified.
 Control cross-reference: [VB.NET vs MFF Table]("MyFbFramework VB VB.NET Control Cross-Reference Table.md")
 
## Form Implementation Guidelines
### Initialization Template
 Required header preprocessor directive `\#include once "mff/<component>.bi"`.
 It is best to avoid nesting `With` statements.
```FreeBasic
 \#include once "mff/<component>.bi" 'Required header preprocessor directive
 Using My.Sys.Forms
 Type Form1Type Extends Form
 Declare Constructor
 ' Control declarations
 Dim As CommandButton CommandButton1 'MFF uses CommandButton vs VB.NET's Button
 Dim As MainMenu MainMenu1 'MFF uses MainMenu vs VB.NET's Menu
 Dim As Picture Picture1 'MFF uses Picture vs VB.NET's PictureBox
 Dim As TimerComponent Timer1 'MFF uses TimerComponent vs VB.NET's Timer
 End Type
 Constructor Form1Type
 With This '`With` statements preferred.
 .Name = "Form1"
 .Text = "Form1"
 .Designer = @This
 .SetBounds 0, 0, 350, 300
 End With
 End Constructor
 Dim Shared Form1 As Form1Type 'Explicit shared declaration 

 \#if _MAIN_FILE_ = __FILE__ ' Required preprocessor directive
 App.DarkMode = True
 Form1.MainForm = True
 Form1.Show
 App.Run
 \#endif
```
### Control, Components, Containers Initialization Requirements
 1. Mandatory Properties
 `Name`
 `Designer`
 `Parent`
 2. Structural Best Practices
 Prefer `With` statements
 Avoid nested With blocks
 Use explicit component references
 3. Graphics Handling
 Draw through `[Canvas](Canvas.md)` property of visible containers
 `OnPaint` handlers must include: must accept the `ByRef Canvas As My.Sys.Drawing.Canvas` parameter to ensure correct graphic context delivery.
### Component Initialization Example
```FreeBasic
 Constructor Form1Type
 With CommandButton1
 .Name = "CommandButton1" ' Matches `With` statement target
 .Parent = @This ' Container reference
 .Designer = @This ' Mandatory Designer binding
 .Text = "Submit" ' Additional properties
 .SetBounds 10, 10, 75, 30 ' Position and size
 End With
 End Constructor
```
### Event Handling Patterns
 1. Naming Convention
 Use controlName_eventName format for handlers. 
```FreeBasic
 Declare Sub CheckBox1_Click(ByRef Sender As Control) ' Good
 Declare Sub GenericHandler(ByRef Sender As Control) ' Avoid
 Declare Sub CheckBox1_ClickByRef(ByRef Sender As Control) ' Avoid
```
 2. Message Loop Initialization
 Launch message loop with App.Run instead of Application.Run.
 3. Event Binding Syntax
 `CastSubByRef` is not recognized as a valid macro or function
 Add the required parenthesis pair after the Sub declaration, Match parameter types between declarations and casts
```freebasic
 .OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox), @CheckBox1_Click) ' Required that the event declarations of `Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)` and matches the event handler of the CheckBox control (CheckBox.OnClick Event).
```
## Complete Form Template
 To create form interfaces using MyFbFramework (commonly abbreviated as `MFF`), required follow this template structure. The example demonstrates adding a `CheckBox` control named CheckBox1 to form `Form1`.
```FreeBasic
 ' Required main file identification logic
 \#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__) ' Required conditional compilation directives
 \#define __MAIN_FILE__
 \#ifdef __FB_WIN32__
 \#cmdline "Form1.rc"
 \#endif
 Const _MAIN_FILE_ = __FILE__
 \#endif
 ' Component header inclusions
 \#include once "mff/Form.bi" ' Required header preprocessor directive. Form control
 \#include once "mff/CheckBox.bi" ' Required header preprocessor directive. CheckBox control
 Using My.Sys.Forms
 Type Form1Type Extends Form
 ' Event handler declarations
 Declare Sub Form_Click (ByRef Sender As Control)
 Declare Sub CheckBox1_Click (ByRef Sender As Control)
 Declare Sub CheckBox1_Create(ByRef Sender As Control)
 Declare Constructor ' Mandatory constructor
 Dim As CheckBox CheckBox1 ' Control instantiation
 End Type
 Constructor Form1Type
 \#if _MAIN_FILE_ = __FILE__ ' Required Conditional compilation directives
 With App
 .CurLanguagePath = ExePath & "/Languages/"
 .CurLanguage = My.Sys.Language
 End With
 \#endif
 ' Form initialization
 With This
 .Name = "Form1"
 .Text = "Form1"
 .Designer = @This ' Required parent assignment
 .OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Click)
 .SetBounds 0, 0, 350, 300
 End With
 ' CheckBox configuration
 With CheckBox1
 .Name = "CheckBox1" ' Required the value is the same as `With` statements 
 .Text = "CheckBox1"
 .SetBounds 42, 53, 265, 17
 .Designer = @This ' Required Design-time parent assignment
 .Parent = @This ' Required Runtime parent assignment
 .OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox), @CheckBox1_Click) ' Required that the event declarations of `Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)` and matches the event handler of the CheckBox control (CheckBox.OnClick Event).
 .OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox), @CheckBox1_Create) ' Required that the event declarations of `Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)` and matches the event handler of the CheckBox control (CheckBox.OnCreate Event).
 End With
 End Constructor
 Dim Shared Form1 As Form1Type ' Global form instance
 \#if _MAIN_FILE_ = __FILE__ 
 App.DarkMode = True
 Form1.MainForm = True
 Form1.Show
 App.Run  ' Message loop start
 \#endif
 ' Event handlers
 Private Sub Form1Type.Form_Click (ByRef Sender As Control)
 ' Event logic
 End Sub
 ' Event handlers
 Private Sub Form1Type.CheckBox1_Click (ByRef Sender As Control)
 ' Event logic
 End Sub
 ' Event handlers
 Private Sub Form1Type.CheckBox1_Create(ByRef Sender As Control)
 ' Event logic
 End Sub
```

