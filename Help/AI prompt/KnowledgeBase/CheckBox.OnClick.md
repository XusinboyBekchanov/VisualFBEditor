[TOC]
# CheckBox.OnClick Event
Triggered when checkbox is clicked
## Definition
Namespace: [`My.Sys.Forms`]
`OnClick` is event of the CheckBox control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnClick As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`CheckBox`]|The object which received the signal|

## See also
[`CheckBox`](CheckBox.md)
