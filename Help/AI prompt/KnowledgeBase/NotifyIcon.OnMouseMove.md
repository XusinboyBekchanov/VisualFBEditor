[TOC]
# NotifyIcon.OnMouseMove Event
Occurs when the mouse pointer is moved over the notify icon (Windows only).
## Definition
Namespace: [`My.Sys.Forms`]
`OnMouseMove` is event of the NotifyIcon control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnMouseMove As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As NotifyIcon, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`NotifyIcon`]|The object which received the signal|
|`MouseButton`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`x`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`y`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`Shift`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||

## See also
[`NotifyIcon`](NotifyIcon.md)
