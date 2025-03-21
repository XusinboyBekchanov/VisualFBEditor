[TOC]
# ScrollBarControl.OnScroll Event
Raised when scroll position changes
## Definition
Namespace: [`My.Sys.Forms`]
`OnScroll` is event of the ScrollBarControl control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnScroll As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ScrollBarControl, ByRef NewPos As Integer)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`ScrollBarControl`]|The object which received the signal|
|`NewPos`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||

## See also
[`ScrollBarControl`](ScrollBarControl.md)
