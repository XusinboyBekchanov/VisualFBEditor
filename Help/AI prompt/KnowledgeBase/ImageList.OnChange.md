[TOC]
# ImageList.OnChange Event

## Definition
Namespace: [`My.Sys.Forms`]
`OnChange` is event of the ImageList control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnChange As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ImageList)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`ImageList`]|The object which received the signal|

## See also
[`ImageList`](ImageList.md)
