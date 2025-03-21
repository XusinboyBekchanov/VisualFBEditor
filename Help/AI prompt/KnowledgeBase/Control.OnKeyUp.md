[TOC]
# Control.OnKeyUp Event
Occurs when a key is released while the control has focus (Windows, Linux, Web).
## Definition
Namespace: [`My.Sys.Forms`]
`OnKeyUp` is event of the Control control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnKeyUp As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`Control`]|The object which received the signal|
|`Key`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`Shift`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||

## See also
[`Control`](Control.md)
