[TOC]
# TreeListView.OnGetDisplayInfo Event
Virtual mode data request event.
## Definition
Namespace: [`My.Sys.Forms`]
`OnGetDisplayInfo` is event of the TreeListView control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnGetDisplayInfo As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef NewText As WString, ByVal RowIndex As Integer, ByVal ColumnIndex As Integer, iMask As ULong)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`TreeListView`]|The object which received the signal|
|`NewText`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")||
|`RowIndex`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`ColumnIndex`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`iMask`|[`ULong`]("https://www.freebasic.net/wiki/KeyPgULong")||

## See also
[`TreeListView`](TreeListView.md)
