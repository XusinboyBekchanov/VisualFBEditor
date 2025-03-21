[TOC]
# TreeView.OnBeforeLabelEdit Event
Triggered before node text editing begins
## Definition
Namespace: [`My.Sys.Forms`]
`OnBeforeLabelEdit` is event of the TreeView control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnBeforeLabelEdit As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode, ByRef NodeLabel As WString, ByRef Cancel As Boolean)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`TreeView`]|The object which received the signal|
|`Item`|[`TreeNode`]||
|`NodeLabel`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")||
|`Cancel`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")||

## See also
[`TreeView`](TreeView.md)
