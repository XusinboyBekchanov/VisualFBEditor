[TOC]
# ComboBoxEdit.OnKeyPress Event
Triggered by character input.
## Definition
Namespace: [`My.Sys.Forms`]
`OnKeyPress` is event of the ComboBoxEdit control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnKeyPress As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, Key As Integer, Shift As Integer)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`ComboBoxEdit`]|The object which received the signal|
|`Key`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`Shift`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||

## See also
[`ComboBoxEdit`](ComboBoxEdit.md)
