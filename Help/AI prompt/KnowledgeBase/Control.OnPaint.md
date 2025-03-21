[TOC]
# Control.OnPaint Event
Occurs when the control is redrawn (Windows, Linux).
## Definition
Namespace: [`My.Sys.Forms`]
`OnPaint` is event of the Control control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnPaint As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`Control`]|The object which received the signal|
|`Canvas`|[`Canvas`]||

## See also
[`Control`](Control.md)
