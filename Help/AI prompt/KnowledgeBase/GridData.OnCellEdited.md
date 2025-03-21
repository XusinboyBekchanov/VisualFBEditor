[TOC]
# GridData.OnCellEdited Event
Triggered after cell edit completion.
## Definition
Namespace: [`My.Sys.Forms`]
`OnCellEdited` is event of the GridData control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnCellEdited As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As GridData, ByRef Item As GridDataItem Ptr, SubItemIndex As Integer, ByRef NewText As WString)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`GridData`]|The object which received the signal|
|`Item`|[`GridDataItem`]||
|`SubItemIndex`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`NewText`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")||

## See also
[`GridData`](GridData.md)
