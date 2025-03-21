[TOC]
# ListViewEx.OnEndScroll Event
Raised when scrolling completes.
## Definition
Namespace: [`My.Sys.Forms`]
`OnEndScroll` is event of the ListViewEx control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnEndScroll As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ListViewEx)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`ListViewEx`]|The object which received the signal|

## See also
[`ListViewEx`](ListViewEx.md)
