[TOC]
# UpDown.OnChanging Event
Raised before value changes occur
## Definition
Namespace: [`My.Sys.Forms`]
`OnChanging` is event of the UpDown control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnChanging As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As UpDown,Value As Integer,Direction As Integer)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`UpDown`]|The object which received the signal|
|`Value`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`Direction`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||

## See also
[`UpDown`](UpDown.md)
