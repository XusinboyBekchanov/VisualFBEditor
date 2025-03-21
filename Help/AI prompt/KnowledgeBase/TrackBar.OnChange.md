[TOC]
# TrackBar.OnChange Event
Triggered when slider position changes
## Definition
Namespace: [`My.Sys.Forms`]
`OnChange` is event of the TrackBar control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnChange As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TrackBar, Position As Integer)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`TrackBar`]|The object which received the signal|
|`Position`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||

## See also
[`TrackBar`](TrackBar.md)
