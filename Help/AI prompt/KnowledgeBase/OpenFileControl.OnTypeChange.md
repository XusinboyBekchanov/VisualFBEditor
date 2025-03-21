[TOC]
# OpenFileControl.OnTypeChange Event
Triggered by filter type modification
## Definition
Namespace: [`My.Sys.Forms`]
`OnTypeChange` is event of the OpenFileControl control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnTypeChange As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As OpenFileControl, Index As Integer)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`OpenFileControl`]|The object which received the signal|
|`Index`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||

## See also
[`OpenFileControl`](OpenFileControl.md)
