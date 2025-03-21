[TOC]
# TabPage.OnDeSelected Event
Triggered when the tab page loses selection
## Definition
Namespace: [`My.Sys.Forms`]
`OnDeSelected` is event of the TabPage control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnDeSelected As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TabPage)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`TabPage`]|The object which received the signal|

## See also
[`TabPage`](TabPage.md)
