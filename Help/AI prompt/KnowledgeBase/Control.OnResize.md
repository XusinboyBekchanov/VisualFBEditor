[TOC]
# Control.OnResize Event
Occurs when the control is resized (Windows, Linux, Android).
## Definition
Namespace: [`My.Sys.Forms`]
`OnResize` is event of the Control control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnResize As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`Control`]|The object which received the signal|
|`NewWidth`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`NewHeight`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||

## See also
[`Control`](Control.md)
