[TOC]
# ListView.OnSelectedItemChanging Event

## Definition
Namespace: [`My.Sys.Forms`]
`OnSelectedItemChanging` is event of the ListView control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnSelectedItemChanging As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer, ByRef Cancel As Boolean)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`ListView`]|The object which received the signal|
|`ItemIndex`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`Cancel`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")||

## See also
[`ListView`](ListView.md)
