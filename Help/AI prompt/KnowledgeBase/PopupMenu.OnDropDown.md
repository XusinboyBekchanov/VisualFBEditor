[TOC]
# PopupMenu.OnDropDown Event

## Definition
Namespace: [`My.Sys.Forms`]
`OnDropDown` is event of the PopupMenu control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnDropDown As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As PopupMenu)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`PopupMenu`]|The object which received the signal|

## See also
[`PopupMenu`](PopupMenu.md)
