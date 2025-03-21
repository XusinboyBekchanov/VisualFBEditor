[TOC]
# VisualFBEditor
VisualFBEditor is the IDE for FreeBasic with visual designer, debugger, project support and etc. VisualFBEditor based on the library <a href="https://github.com/XusinboyBekchanov/Controls/MyFbFramework">MyFbFramework</a>.


## MyFbFramework controls and objects
Object Hierarchy

### Controls
The MyFbFramework framework includes 39 controls: Animate, Chart, CheckBox, CheckedListBox, ComboBoxEdit, ComboBoxEx, CommandButton, DateTimePicker, Grid, Header, HotKey, HScrollBar, ImageBox, IPAddress, Label, LinkLabel, ListControl, ListView, MonthCalendar, NumericUpDown, OpenFileControl, PrintPreviewControl, ProgressBar, RadioButton, RichTextBox, ScrollBarControl, SearchBox, Splitter, StatusBar, TextBox, ToolBar, ToolPalette, ToolTips, TrackBar, TreeListView, TreeView, UpDown, VScrollBar, WebBrowser. Detailed in the table below. 
|Name|Description|
| :------------ | :------------ |
|[Animate](Animate.md)|An animate control is a window that displays an Audio-Video Interleaved (AVI) clip.|
|[Chart](Chart.md)|The Chart control is a chart object that exposes events.|
|[CheckBox](CheckBox.md)|Displays an V when selected; the V disappears when the CheckBox is cleared.|
|[CheckedListBox](CheckedListBox.md)|Displays a ListBox in which a check box is displayed to the left of each item.|
|[ComboBoxEdit](ComboBoxEdit.md)|Combines the features of a TextBox and a ListControl.|
|[ComboBoxEx](ComboBoxEx.md)|ComboBoxEx controls are combo box controls that provide native support for item images.|
|[CommandButton](CommandButton.md)|Looks like a push button and is used to begin, interrupt, or end a process.|
|[DateTimePicker](DateTimePicker.md)|Represents a Windows control that allows the user to select a date and a time and to display the date and time with a specified format.|
|[Grid](Grid.md)|Defines a flexible grid area that consists of columns and rows.|
|[Header](Header.md)|A header control is a window that is usually positioned above columns of text or numbers.|
|[HotKey](HotKey.md)|A hot key control is a window that enables the user to enter a combination of keystrokes to be used as a hot key.|
|[HScrollBar](HScrollBar.md)|Provides a horizontal scroll bar for easy navigation through long lists of items.|
|[ImageBox](ImageBox.md)|Displays a graphic.|
|[IPAddress](IPAddress.md)|An Internet Protocol (IP) address control allows the user to enter an IP address in an easily understood format.|
|[Label](Label.md)|Displays text that a user can't change directly.|
|[LinkLabel](LinkLabel.md)|Represents a label control that can display hyperlinks.|
|[ListControl](ListControl.md)|Displays a list of items from which the user can select one or more.|
|[ListView](ListView.md)|Represents a control that displays a list of data items.|
|[MonthCalendar](MonthCalendar.md)|Represents a control that enables the user to select a date using a visual monthly calendar display.|
|[NumericUpDown](NumericUpDown.md)|Represents a spin box (also known as an up-down control) that displays numeric values.|
|[OpenFileControl](OpenFileControl.md)|Represents a box for choosing files.|
|[PrintPreviewControl](PrintPreviewControl.md)|Represents the raw preview part of print previewing, without any dialog boxes or buttons.|
|[ProgressBar](ProgressBar.md)|A progress bar is a window that an application can use to indicate the progress of a lengthy operation.|
|[RadioButton](RadioButton.md)|Displays an option that can be turned on or off.|
|[RichTextBox](RichTextBox.md)|The RichTextBox control enables you to display or edit flow content including paragraphs, images, tables, and more.|
|[ScrollBarControl](ScrollBarControl.md)|Provides a horizontal and a vertical scroll bar for easy navigation through long lists of items.|
|[SearchBox](SearchBox.md)|A subclass of TextBox that has been tailored for use as a search textbox.|
|[Splitter](Splitter.md)|Represents a splitter control that enables the user to resize docked controls.|
|[StatusBar](StatusBar.md)|A status bar is a horizontal window at the bottom of a parent window in which an application can display various kinds of status information.|
|[TextBox](TextBox.md)|Displays information entered at design time by the user, or in code at run time.|
|[ToolBar](ToolBar.md)|A toolbar is a control that contains one or more buttons.|
|[ToolPalette](ToolPalette.md)|A tool palette with categories.|
|[ToolTips](ToolTips.md)|An element in which, when hovering over a marker or region element or component, a text box displays information about that element.|
|[TrackBar](TrackBar.md)|A trackbar is a window that contains a slider (sometimes called a thumb) in a channel, and optional tick marks.|
|[TreeListView](TreeListView.md)|Combines the features of a TreeView and a ListView.|
|[TreeView](TreeView.md)|Represents a control that displays hierarchical data in a tree structure that has items that can expand and collapse.|
|[UpDown](UpDown.md)|An up-down control is a pair of arrow buttons that the user can click to increment or decrement a value, such as a scroll position or a number displayed in a companion control (called a buddy window).|
|[VScrollBar](VScrollBar.md)|Provides a vertical scroll bar.|
|[WebBrowser](WebBrowser.md)|Enables the user to navigate Web pages inside your form.|

### Containers
The MyFbFramework framework includes 13 Containers: Form, GroupBox, HorizontalBox, PagePanel, PageScroller, Panel,  Picture, ReBar, ScrollControl], TabControl, TabPage, VerticalBox, UserControl. Detailed in the table below. 
|Name|Description|
| :------------ | :------------ |
|[Form](Form.md)|A window or dialog box that makes up part of an application's user interface.|
|[GroupBox](GroupBox.md)|Provides an identifiable grouping for controls.|
|[HorizontalBox](HorizontalBox.md)|Arranges items in a horizontal row.|
|[PagePanel](PagePanel.md)|Used to organize controls on hidden panels.|
|[PageScroller](PageScroller.md)|The PageScroller control is used to scroll a panel along with the components placed on it.|
|[Panel](Panel.md)|Used to group collections of controls.|
|[Picture](Picture.md)|Displays a graphic from a bitmap, icon or metafile.|
|[ReBar](ReBar.md)|A Rebar control acts as a container for child windows. It can contain one or more bands, and each band can have any combination of a gripper bar, a bitmap, a text label, and one child window.|
|[ScrollControl](ScrollControl.md)|A container that makes its child scrollable.|
|[TabControl](TabControl.md)|Represents a control that contains multiple items that share the same space on the screen.|
|[TabPage](TabPage.md)|Represents a single tab page in a TabControl.|
|[UserControl](UserControl.md)|Provides an empty control that can be used to create other controls. A Control authored in VisualFBEditor|
|[VerticalBox](VerticalBox.md)|Arranges items in a vertical column.|

### Components
The MyFbFramework framework includes 9 Components: HTTPConnection, HTTPServer, ImageList,  MainMenu,  PopUpMenu, PrintDocument, Printer, SQLite3Component, TimerComponent. Detailed in the table below. 

|Name|Description|
| :------------ | :------------ |
|[HTTPConnection](HTTPConnection.md)|Constructs a connection to the host (port) as given in the uri.|
|[HTTPServer](HTTPServer.md)|Implements a simple HTTP server.|
|[ImageList](ImageList.md)|An image list is a collection of images of the same size, each of which can be referred to by its index.|
|[MainMenu](MainMenu.md)|Represents the menu structure of a form.|
|[MariaDBBox](MariaDBBox.md)|A container that provides a pre-installed and configured environment for working with the MariaDB database.|
|[PopUpMenu](PopUpMenu.md)|Represents a context menu.|
|[PrintDocument](PrintDocument.md)|Defines a reusable object that sends output to a printer, when printing.|
|[Printer](Printer.md)|Enables you to communicate with a system printer (initially the default printer).|
|[SQLite3Component](SQLite3Component.md)|A component that facilitates integration with the SQLite3 database.|
|[TimerComponent](TimerComponent.md)|A control which can execute code at regular intervals by causing a Timer event.|

### Dialogs
The MyFbFramework framework includes 8 Dialogs: ColorDialog,  FolderBrowserDialog, FontDialog, OpenFileDialog, PageSetupDialog, PrintDialog, PrintPreviewDialog, SaveFileDialog. Detailed in the table below. 
|Name|Description|
| :------------ | :------------ |
|[ColorDialog](ColorDialog.md)|Represents a common dialog box that displays available colors along with controls that enable the user to define custom colors.|
|[FolderBrowserDialog](FolderBrowserDialog.md)|Prompts the user to select a folder.|
|[FontDialog](FontDialog.md)|Prompts the user to choose a font from among those installed on the local computer.|
|[OpenFileDialog](OpenFileDialog.md)|Displays a standard dialog box that prompts the user to open a file.|
|[PageSetupDialog](PageSetupDialog.md)|Enables users to change page-related print settings, including margins and paper orientation.|
|[PrintDialog](PrintDialog.md)|Lets users select a printer and choose which sections of the document to print from an application.|
|[PrintPreviewDialog](PrintPreviewDialog.md)|Represents the raw preview part of print previewing from an application.|
|[SaveFileDialog](SaveFileDialog.md)|Prompts the user to select a location for saving a file.|


