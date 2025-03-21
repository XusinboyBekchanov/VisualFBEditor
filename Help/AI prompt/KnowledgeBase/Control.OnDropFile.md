[TOC]
# Control.OnDropFile Event
Occurs when the user drops a file on the window of an application that has registered itself as a recipient of dropped files (Windows, Linux).
## Definition
Namespace: [`My.Sys.Forms`]
`OnDropFile` is event of the Control control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnDropFile As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Filename As WString)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`Control`]|The object which received the signal|
|`Filename`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")||

## See also
[`Control`](Control.md)
