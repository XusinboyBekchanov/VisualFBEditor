[TOC]
# RadioButton.OnClick Event
Triggered when selection state changes
## Definition
Namespace: [`My.Sys.Forms`]
`OnClick` is event of the RadioButton control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnClick As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`RadioButton`]|The object which received the signal|

## See also
[`RadioButton`](RadioButton.md)
