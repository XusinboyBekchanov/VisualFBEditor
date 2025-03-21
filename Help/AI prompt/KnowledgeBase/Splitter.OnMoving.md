[TOC]
# Splitter.OnMoving Event
Raised during active resizing operations
## Definition
Namespace: [`My.Sys.Forms`]
`OnMoving` is event of the Splitter control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnMoving As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Splitter)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`Splitter`]|The object which received the signal|

## See also
[`Splitter`](Splitter.md)
