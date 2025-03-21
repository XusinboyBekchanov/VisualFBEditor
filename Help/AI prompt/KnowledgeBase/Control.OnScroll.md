[TOC]
# Control.OnScroll Event
Occurs when the scroll box has been moved by either a mouse or keyboard action (Windows, Linux).
## Definition
Namespace: [`My.Sys.Forms`]
`OnScroll` is event of the Control control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnScroll As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`Control`]|The object which received the signal|

## See also
[`Control`](Control.md)
