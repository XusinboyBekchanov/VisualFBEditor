[TOC]
# TextBox.OnActivate Event
Raised when control becomes active.
## Definition
Namespace: [`My.Sys.Forms`]
`OnActivate` is event of the TextBox control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnActivate As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TextBox)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`TextBox`]|The object which received the signal|

## See also
[`TextBox`](TextBox.md)
