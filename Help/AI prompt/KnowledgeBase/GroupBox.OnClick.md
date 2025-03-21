[TOC]
# GroupBox.OnClick Event

## Definition
Namespace: [`My.Sys.Forms`]
`OnClick` is event of the GroupBox control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnClick As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As GroupBox)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`GroupBox`]|The object which received the signal|

## See also
[`GroupBox`](GroupBox.md)
