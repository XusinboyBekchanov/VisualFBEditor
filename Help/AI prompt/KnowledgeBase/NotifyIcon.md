[TOC]
## Definition
Namespace: [`My.Sys.Forms`](My.Sys.Forms.md)

`NotifyIcon` - 

## Properties
|Name|Description|
| :------------ | :------------ |
|[`BalloonTipIcon`]("NotifyIcon.BalloonTipIcon.md")||
|[`BalloonTipIconType`]("NotifyIcon.BalloonTipIconType.md")||
|[`BalloonTipText`]("NotifyIcon.BalloonTipText.md")||
|[`BalloonTipTitle`]("NotifyIcon.BalloonTipTitle.md")||
|[`ContextMenu`]("NotifyIcon.ContextMenu.md")||
|[`Icon`]("NotifyIcon.Icon.md")||
|[`Text`]("NotifyIcon.Text.md")||
|[`Visible`]("NotifyIcon.Visible.md")||

## Methods
|Name|Description|
| :------------ | :------------ |
|[`ReadProperty`]("NotifyIcon.ReadProperty.md")|Reads value from the name of property (Windows, Linux, Android, Web).|
|[`ShowBalloonTip`]("NotifyIcon.ShowBalloonTip.md")||
|[`WriteProperty`]("NotifyIcon.WriteProperty.md")|Writes value to the name of property (Windows, Linux, Android, Web).|
## Events
|Name|Description|
| :------------ | :------------ |
|[`OnBalloonTipClicked`]("NotifyIcon.OnBalloonTipClicked.md") ||
|[`OnBalloonTipClosed`]("NotifyIcon.OnBalloonTipClosed.md") ||
|[`OnBalloonTipShown`]("NotifyIcon.OnBalloonTipShown.md") ||
|[`OnClick`]("NotifyIcon.OnClick.md") |Occurs when the notify icon is clicked (Windows only).|
|[`OnDblClick`]("NotifyIcon.OnDblClick.md") |Occurs when the notify icon is double-clicked (Windows, Linux, Web).|
|[`OnMouseDown`]("NotifyIcon.OnMouseDown.md") |Occurs when the mouse pointer is over the notify icon and a mouse button is pressed (Windows only).|
|[`OnMouseMove`]("NotifyIcon.OnMouseMove.md") |Occurs when the mouse pointer is moved over the notify icon (Windows only).|
|[`OnMouseUp`]("NotifyIcon.OnMouseUp.md") |Occurs when the mouse pointer is over the notify icon and a mouse button is released (Windows only).|
## Examples
```freeBasic
'\#Region "Form"
	\#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		\#define __MAIN_FILE__
		\#ifdef __FB_WIN32__
			\#cmdline "Form1.rc"
		\#endif
		Const _MAIN_FILE_ = __FILE__
	\#endif
	\#include once "mff/Form.bi"
	\#include once "mff/NotifyIcon.bi"
	\#include once "mff/Menus.bi"
	
	Using My.Sys.Forms
	
	Type Form1Type Extends Form
		Declare Sub Form_Click(ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub NotifyIcon1_Click(ByRef Sender As NotifyIcon)
		Declare Sub MenuItem2_Click(ByRef Sender As MenuItem)
		Declare Sub NotifyIcon1_BalloonTipClicked(ByRef Sender As NotifyIcon)
		Declare Sub NotifyIcon1_DblClick(ByRef Sender As NotifyIcon)
		Declare Sub NotifyIcon1_MouseDown(ByRef Sender As NotifyIcon, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub MenuItem1_Click(ByRef Sender As MenuItem)
		Declare Constructor
		
		Dim As NotifyIcon NotifyIcon1
		Dim As PopupMenu PopupMenu1
		Dim As MenuItem MenuItem1, MenuItem2
	End Type
	
	Constructor Form1Type
		\#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = My.Sys.Language
			End With
		\#endif
		' Form1
		With This
			.Name = "Form1"
			.Text = "Form1"
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Click)
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.SetBounds 0, 0, 350, 300
		End With
		' NotifyIcon1
		With NotifyIcon1
			.Name = "NotifyIcon1"
			.Icon = "VisualFBEditor"
			.Visible = True
			.ContextMenu = @PopupMenu1
			.BalloonTipIcon = "VisualFBEditor"
			.BalloonTipTitle = "Visual FB Editor"
			.BalloonTipText = "Hello World!"
			.Text = "VisualFBEditor NotifyIcon Example"
			.BalloonTipIconType = ToolTipIconType.User
			.SetBounds 150, 80, 16, 16
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As NotifyIcon), @NotifyIcon1_Click)
			.OnBalloonTipClicked = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As NotifyIcon), @NotifyIcon1_BalloonTipClicked)
			.OnDblClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As NotifyIcon), @NotifyIcon1_DblClick)
			.OnMouseDown = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As NotifyIcon, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @NotifyIcon1_MouseDown)
			.Parent = @This
		End With
		' PopupMenu1
		With PopupMenu1
			.Name = "PopupMenu1"
			.SetBounds 60, 140, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' MenuItem1
		With MenuItem1
			.Name = "MenuItem1"
			.Designer = @This
			.Caption = "fdfdfd"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem1_Click)
			.Parent = @PopupMenu1
		End With
		' MenuItem2
		With MenuItem2
			.Name = "MenuItem2"
			.Designer = @This
			.Caption = "dfddfdf"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem2_Click)
			.Parent = @PopupMenu1
		End With
	End Constructor
	
	Dim Shared Form1 As Form1Type
	
	\#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		Form1.MainForm = True
		Form1.Show
		App.Run
	\#endif
'\#End Region

Private Sub Form1Type.Form_Click(ByRef Sender As Control)
	NotifyIcon1.ShowBalloonTip 10000
End Sub

Private Sub Form1Type.Form_Create(ByRef Sender As Control)
	NotifyIcon1.ShowBalloonTip 10000, "Visual FB Editor", "Hello World", ToolTipIconType.User, @Icon
End Sub

Private Sub Form1Type.NotifyIcon1_Click(ByRef Sender As NotifyIcon)
	MsgBox "Clicked notify icon"
End Sub

Private Sub Form1Type.MenuItem2_Click(ByRef Sender As MenuItem)
	MsgBox "Clicked second menu item"
End Sub

Private Sub Form1Type.NotifyIcon1_BalloonTipClicked(ByRef Sender As NotifyIcon)
	MsgBox "Clicked balloon tip"
End Sub

Private Sub Form1Type.NotifyIcon1_DblClick(ByRef Sender As NotifyIcon)
	MsgBox "Double clicked notify icon"
End Sub

Private Sub Form1Type.NotifyIcon1_MouseDown(ByRef Sender As NotifyIcon, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	?MouseButton, x, y, Shift
End Sub

Private Sub Form1Type.MenuItem1_Click(ByRef Sender As MenuItem)
	MsgBox "Clicked first menu item"
End Sub

```
## See also
Namespace: [`My.Sys.Forms`](My.Sys.Forms.md)
