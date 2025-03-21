[TOC]
# ReBar.OnPopup Event

## Definition
Namespace: [`My.Sys.Forms`]
`OnPopup` is event of the ReBar control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnPopup As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ReBar, Index As Integer)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`ReBar`]|The object which received the signal|
|`Index`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||

## See also
[`ReBar`](ReBar.md)
