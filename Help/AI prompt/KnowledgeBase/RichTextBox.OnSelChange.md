[TOC]
# RichTextBox.OnSelChange Event
Triggered on selection change.
## Definition
Namespace: [`My.Sys.Forms`]
`OnSelChange` is event of the RichTextBox control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnSelChange As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As RichTextBox)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`RichTextBox`]|The object which received the signal|

## See also
[`RichTextBox`](RichTextBox.md)
