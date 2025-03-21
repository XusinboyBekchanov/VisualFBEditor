[TOC]
# Grid.OnRowDblClick Event
Raised on row double-click.
## Definition
Namespace: [`My.Sys.Forms`]
`OnRowDblClick` is event of the Grid control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnRowDblClick As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Grid, ByVal RowIndex As Integer)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`Grid`]|The object which received the signal|
|`RowIndex`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||

## See also
[`Grid`](Grid.md)
