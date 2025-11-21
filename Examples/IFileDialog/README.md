# IFileDialog
Example for VisualFBEditor

该 FreeBASIC 代码实现了一个高级的文件打开对话框，主要功能包括：
使用 Windows Com 接口 IFileOpenDialog 创建现代化的文件选择对话框
支持多文件选择（FOS_ALLOWMULTISELECT）
添加自定义控件组：
换行符格式选择：Windows (CRLF)、Linux (LF)、Mac OS (CR)
文本编码选择：ASCII、UTF-8、Unicode (UTF-16 LE)、Unicode Big Endian
实现完整的 IFileDialogEvents 和 IFileDialogControlEvents 事件处理机制
提供详细的事件日志输出，用于调试和监控对话框行为
支持设置初始路径、文件类型过滤器等标准功能
包含完整的资源管理和内存释放机制

This FreeBASIC code implements an advanced file open dialog with the following main features:
Utilizes the Windows COM interface IFileOpenDialog to create a modern file selection dialog
Supports multiple file selection (FOS_ALLOWMULTISELECT)
Adds custom control groups:
Line ending format selection: Windows (CRLF), Linux (LF), Mac OS (CR)
Text encoding selection: ASCII, UTF-8, Unicode (UTF-16 LE), Unicode Big Endian
Implements complete IFileDialogEvents and IFileDialogControlEvents event handling mechanisms
Provides detailed event logging output for debugging and monitoring dialog behavior
Supports standard functions such as setting initial paths and file type filters
Includes comprehensive resource management and memory release mechanisms

<img width="946" height="564" alt="image" src="https://github.com/user-attachments/assets/638ad4d0-a0f1-4b43-a842-37b396378f37" />
