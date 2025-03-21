[TOC]
# TimerComponent.OnTimer Event

## Definition
Namespace: [`My.Sys.Forms`]
`OnTimer` is event of the TimerComponent control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnTimer As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`TimerComponent`]|The object which received the signal|

## See also
[`TimerComponent`](TimerComponent.md)
