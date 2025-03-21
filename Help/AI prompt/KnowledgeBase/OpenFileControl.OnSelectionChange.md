[TOC]
# OpenFileControl.OnSelectionChange Event
Fired when selected files change
## Definition
Namespace: [`My.Sys.Forms`]
`OnSelectionChange` is event of the OpenFileControl control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnSelectionChange As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As OpenFileControl)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`OpenFileControl`]|The object which received the signal|

## See also
[`OpenFileControl`](OpenFileControl.md)
