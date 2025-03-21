[TOC]
# TreeView.OnSelChanged Event
After selection changes
## Definition
Namespace: [`My.Sys.Forms`]
`OnSelChanged` is event of the TreeView control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnSelChanged As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`TreeView`]|The object which received the signal|
|`Item`|[`TreeNode`]||

## See also
[`TreeView`](TreeView.md)
