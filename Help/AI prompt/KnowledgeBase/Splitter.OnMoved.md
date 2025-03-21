[TOC]
# Splitter.OnMoved Event
Triggered after splitter completes resizing
## Definition
Namespace: [`My.Sys.Forms`]
`OnMoved` is event of the Splitter control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnMoved As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Splitter)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`Splitter`]|The object which received the signal|

## See also
[`Splitter`](Splitter.md)
