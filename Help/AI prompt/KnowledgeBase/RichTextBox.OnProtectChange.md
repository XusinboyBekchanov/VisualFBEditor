[TOC]
# RichTextBox.OnProtectChange Event
Triggered when protected text changes.
## Definition
Namespace: [`My.Sys.Forms`]
`OnProtectChange` is event of the RichTextBox control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnProtectChange As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As RichTextBox, SelStart As Integer, SelEnd As Integer, ByRef AllowChange As Boolean)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`RichTextBox`]|The object which received the signal|
|`SelStart`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`SelEnd`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`AllowChange`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")||

## See also
[`RichTextBox`](RichTextBox.md)
