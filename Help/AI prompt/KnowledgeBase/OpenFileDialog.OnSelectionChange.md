[TOC]
# OpenFileDialog.OnSelectionChange Event

`OnSelectionChange` is event of the OpenFileDialog control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnSelectionChange As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As OpenFileDialog)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`OpenFileDialog`]|The object which received the signal|

## See also
[`OpenFileDialog`](OpenFileDialog.md)
