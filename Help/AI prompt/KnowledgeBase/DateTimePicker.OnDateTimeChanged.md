[TOC]
# DateTimePicker.OnDateTimeChanged Event
Triggered when date/time value changes
## Definition
Namespace: [`My.Sys.Forms`]
`OnDateTimeChanged` is event of the DateTimePicker control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnDateTimeChanged As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As DateTimePicker)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`DateTimePicker`]|The object which received the signal|

## See also
[`DateTimePicker`](DateTimePicker.md)
