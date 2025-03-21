[TOC]
# TreeListView.OnItemExpanding Event
Triggered before node expansion.
## Definition
Namespace: [`My.Sys.Forms`]
`OnItemExpanding` is event of the TreeListView control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnItemExpanding As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`TreeListView`]|The object which received the signal|
|`Item`|[`TreeListViewItem`]||

## See also
[`TreeListView`](TreeListView.md)
