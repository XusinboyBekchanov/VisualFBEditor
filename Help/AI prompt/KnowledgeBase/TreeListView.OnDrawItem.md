[TOC]
# TreeListView.OnDrawItem Event
Custom node rendering event.
## Definition
Namespace: [`My.Sys.Forms`]
`OnDrawItem` is event of the TreeListView control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnDrawItem As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr, ItemAction As Integer, ItemState As Integer, ByRef R As My.Sys.Drawing.Rect, ByRef Canvas As My.Sys.Drawing.Canvas)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`TreeListView`]|The object which received the signal|
|`Item`|[`TreeListViewItem`]||
|`ItemAction`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`ItemState`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`R`|[`Rect`]||
|`Canvas`|[`Canvas`]||

## See also
[`TreeListView`](TreeListView.md)
