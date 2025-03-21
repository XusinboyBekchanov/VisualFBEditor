[TOC]
# TreeView.OnNodeExpanding Event
Before node expansion occurs
## Definition
Namespace: [`My.Sys.Forms`]
`OnNodeExpanding` is event of the TreeView control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnNodeExpanding As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode, ByRef Cancel As Boolean)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`TreeView`]|The object which received the signal|
|`Item`|[`TreeNode`]||
|`Cancel`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")||

## See also
[`TreeView`](TreeView.md)
