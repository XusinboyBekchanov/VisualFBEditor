[TOC]
# Form.OnActiveControlChange Event
Occurs when changes focus one of the controls on the form (Windows, Linux).
## Definition
Namespace: [`My.Sys.Forms`]
`OnActiveControlChange` is event of the Form control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnActiveControlChange As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`Form`]|The object which received the signal|

## See also
[`Form`](Form.md)
