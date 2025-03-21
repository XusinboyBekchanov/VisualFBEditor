[TOC]
# TextBox.OnPaste Event
Raised after text is pasted from clipboard.
## Definition
Namespace: [`My.Sys.Forms`]
`OnPaste` is event of the TextBox control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnPaste As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TextBox, ByRef Action As Integer)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`TextBox`]|The object which received the signal|
|`Action`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||

## See also
[`TextBox`](TextBox.md)
