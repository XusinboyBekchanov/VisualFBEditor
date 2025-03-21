[TOC]
# Brush.OnCreate Event

## Definition
Namespace: [`My.Sys.Drawing`]
`OnCreate` is event of the Brush control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnCreate As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Brush)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`Brush`]|The object which received the signal|

## See also
[`Brush`](Brush.md)
