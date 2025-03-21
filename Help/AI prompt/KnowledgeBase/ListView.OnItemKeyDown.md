[TOC]
# ListView.OnItemKeyDown Event

## Definition
Namespace: [`My.Sys.Forms`]
`OnItemKeyDown` is event of the ListView control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnItemKeyDown As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer, Key As Integer, Shift As Integer)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`ListView`]|The object which received the signal|
|`ItemIndex`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`Key`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`Shift`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||

## See also
[`ListView`](ListView.md)
