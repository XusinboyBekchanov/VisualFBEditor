[TOC]
# NotifyIcon.OnBalloonTipClosed Event

## Definition
Namespace: [`My.Sys.Forms`]
`OnBalloonTipClosed` is event of the NotifyIcon control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnBalloonTipClosed As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As NotifyIcon)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`NotifyIcon`]|The object which received the signal|

## See also
[`NotifyIcon`](NotifyIcon.md)
