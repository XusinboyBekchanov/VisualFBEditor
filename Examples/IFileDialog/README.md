# IFileDialog
Example for VisualFBEditor

该 FreeBASIC 代码实现了一个高级的文件打开对话框，主要功能包括：

1. 使用 Windows Com 接口 IFileOpenDialog 创建现代化的文件选择对话框
2. 支持多文件选择（FOS_ALLOWMULTISELECT）
3. 添加自定义控件组：

```
1). 换行符格式选择：Windows (CRLF)、Linux (LF)、Mac OS (CR)
2). 文本编码选择：ASCII、UTF-8、Unicode (UTF-16 LE)、Unicode Big Endian
```

5. 实现完整的 IFileDialogEvents 和 IFileDialogControlEvents 事件处理机制
6. 提供详细的事件日志输出，用于调试和监控对话框行为
7. 支持设置初始路径、文件类型过滤器等标准功能
8. 包含完整的资源管理和内存释放机制

This FreeBASIC code implements an advanced file open dialog with the following main features:

1. Utilizes the Windows COM interface IFileOpenDialog to create a modern file selection dialog
2. Supports multiple file selection (FOS_ALLOWMULTISELECT)
3. Adds custom control groups:

```
1). Line ending format selection: Windows (CRLF), Linux (LF), Mac OS (CR)
2). Text encoding selection: ASCII, UTF-8, Unicode (UTF-16 LE), Unicode Big Endian
```

4. Implements complete IFileDialogEvents and IFileDialogControlEvents event handling mechanisms
5. Provides detailed event logging output for debugging and monitoring dialog behavior
6. Supports standard functions such as setting initial paths and file type filters
7. Includes comprehensive resource management and memory release mechanisms

<img width="946" height="564" alt="image" src="https://github.com/user-attachments/assets/638ad4d0-a0f1-4b43-a842-37b396378f37" />
