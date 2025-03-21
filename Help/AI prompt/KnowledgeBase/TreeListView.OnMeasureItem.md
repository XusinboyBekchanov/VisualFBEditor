[TOC]
# TreeListView.OnMeasureItem Event
Custom node sizing event.
## Definition
Namespace: [`My.Sys.Forms`]
`OnMeasureItem` is event of the TreeListView control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnMeasureItem As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr, ByRef ItemWidth As ULong, ByRef ItemHeight As ULong)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`TreeListView`]|The object which received the signal|
|`Item`|[`TreeListViewItem`]||
|`ItemWidth`|[`ULong`]("https://www.freebasic.net/wiki/KeyPgULong")||
|`ItemHeight`|[`ULong`]("https://www.freebasic.net/wiki/KeyPgULong")||

## See also
[`TreeListView`](TreeListView.md)
