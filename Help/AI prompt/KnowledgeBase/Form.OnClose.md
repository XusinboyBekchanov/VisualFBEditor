[TOC]
# Form.OnClose Event
Occurs when the form is closed (Windows, Linux).
## Definition
Namespace: [`My.Sys.Forms`]
`OnClose` is event of the Form control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnClose As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`Form`]|The object which received the signal|
|`Action`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||

## See also
[`Form`](Form.md)
