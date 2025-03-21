[TOC]
# GridData.OnItemClick Event
Raised on row click.
## Definition
Namespace: [`My.Sys.Forms`]
`OnItemClick` is event of the GridData control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnItemClick As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As GridData, RowIndex As Integer, ColIndex As Integer, tGridDCC As HDC)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`GridData`]|The object which received the signal|
|`RowIndex`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`ColIndex`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`tGridDCC`|[`HDC`]||

## See also
[`GridData`](GridData.md)
