[TOC]
# Chart.OnItemClick Event

## Definition
Namespace: [`My.Sys.Forms`]
`OnItemClick` is event of the Chart control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnItemClick As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Chart, Index As Long)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`Chart`]|The object which received the signal|
|`Index`|[`Long`]("https://www.freebasic.net/wiki/KeyPgLong")||

## See also
[`Chart`](Chart.md)
