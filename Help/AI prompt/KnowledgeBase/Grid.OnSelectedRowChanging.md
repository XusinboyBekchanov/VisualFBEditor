[TOC]
# Grid.OnSelectedRowChanging Event
Raised before selection changes.
## Definition
Namespace: [`My.Sys.Forms`]
`OnSelectedRowChanging` is event of the Grid control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnSelectedRowChanging As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Grid, ByVal RowIndex As Integer, ByRef Cancel As Boolean)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`Grid`]|The object which received the signal|
|`RowIndex`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`Cancel`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")||

## See also
[`Grid`](Grid.md)
