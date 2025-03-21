[TOC]
# TextBox.OnUpdate Event
Raises the Update event.
## Definition
Namespace: [`My.Sys.Forms`]
`OnUpdate` is event of the TextBox control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnUpdate As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TextBox, ByRef NewText As WString)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`TextBox`]|The object which received the signal|
|`NewText`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")||

## See also
[`TextBox`](TextBox.md)
