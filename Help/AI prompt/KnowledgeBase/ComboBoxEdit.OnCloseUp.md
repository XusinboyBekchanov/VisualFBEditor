[TOC]
# ComboBoxEdit.OnCloseUp Event
Raised when dropdown closes.
## Definition
Namespace: [`My.Sys.Forms`]
`OnCloseUp` is event of the ComboBoxEdit control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnCloseUp As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`ComboBoxEdit`]|The object which received the signal|

## See also
[`ComboBoxEdit`](ComboBoxEdit.md)
