[TOC]
# Form.OnDeActivateApp Event
Occurs after a Application instance becomes deactive (Windows, Linux).
## Definition
Namespace: [`My.Sys.Forms`]
`OnDeActivateApp` is event of the Form control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnDeActivateApp As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`Form`]|The object which received the signal|

## See also
[`Form`](Form.md)
