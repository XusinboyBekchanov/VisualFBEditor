[TOC]
# TreeListView.OnCellEdited Event
Triggered after cell edit completion.
## Definition
Namespace: [`My.Sys.Forms`]
`OnCellEdited` is event of the TreeListView control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnCellEdited As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr, ByVal SubItemIndex As Integer, ByRef NewText As WString, ByRef Cancel As Boolean)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`TreeListView`]|The object which received the signal|
|`Item`|[`TreeListViewItem`]||
|`SubItemIndex`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`NewText`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")||
|`Cancel`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")||

## See also
[`TreeListView`](TreeListView.md)
