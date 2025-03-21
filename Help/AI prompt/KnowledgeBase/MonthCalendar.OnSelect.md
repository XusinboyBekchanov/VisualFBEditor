[TOC]
# MonthCalendar.OnSelect Event
Triggered during date selection
## Definition
Namespace: [`My.Sys.Forms`]
`OnSelect` is event of the MonthCalendar control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnSelect As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MonthCalendar)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`MonthCalendar`]|The object which received the signal|

## See also
[`MonthCalendar`](MonthCalendar.md)
