[TOC]
# TreeView.OnNodeActivate Event
Raised when node is activated via keyboard
## Definition
Namespace: [`My.Sys.Forms`]
`OnNodeActivate` is event of the TreeView control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnNodeActivate As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`TreeView`]|The object which received the signal|
|`Item`|[`TreeNode`]||

## See also
[`TreeView`](TreeView.md)
