[TOC]
# MenuItem.OnClick Event
Triggered when selected via click/shortcut
## Definition
Namespace: [`My.Sys.Forms`]
`OnClick` is event of the MenuItem control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnClick As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`MenuItem`]|The object which received the signal|

## See also
[`MenuItem`](MenuItem.md)
