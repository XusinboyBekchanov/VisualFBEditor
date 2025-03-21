[TOC]
# OpenFileDialog.OnTypeChange Event

`OnTypeChange` is event of the OpenFileDialog control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnTypeChange As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As OpenFileDialog, Index As Integer)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`OpenFileDialog`]|The object which received the signal|
|`Index`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||

## See also
[`OpenFileDialog`](OpenFileDialog.md)
