[TOC]
# VScrollBar.OnScroll Event
Triggered when scroll position changes
## Definition
Namespace: [`My.Sys.Forms`]
`OnScroll` is event of the VScrollBar control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnScroll As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As VScrollBar, ByRef NewPos As UInteger)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`VScrollBar`]|The object which received the signal|
|`NewPos`|[`UInteger`]("https://www.freebasic.net/wiki/KeyPgUInteger")||

## See also
[`VScrollBar`](VScrollBar.md)
