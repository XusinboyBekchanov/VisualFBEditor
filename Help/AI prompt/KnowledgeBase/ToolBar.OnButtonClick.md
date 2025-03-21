[TOC]
# ToolBar.OnButtonClick Event
Raised when any toolbar button is clicked
## Definition
Namespace: [`My.Sys.Forms`]
`OnButtonClick` is event of the ToolBar control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnButtonClick As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ToolBar, ByRef Button As ToolButton)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`ToolBar`]|The object which received the signal|
|`Button`|[`ToolButton`]||

## See also
[`ToolBar`](ToolBar.md)
