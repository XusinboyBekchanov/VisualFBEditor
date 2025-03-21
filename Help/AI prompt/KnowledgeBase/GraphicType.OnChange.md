[TOC]
# GraphicType.OnChange Event

## Definition
Namespace: [`My.Sys.Drawing`]
`OnChange` is event of the GraphicType control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnChange As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As GraphicType, Image As Any Ptr, ImageType As Integer)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`GraphicType`]|The object which received the signal|
|`Image`|[`Any`]("https://www.freebasic.net/wiki/KeyPgAny")||
|`ImageType`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||

## See also
[`GraphicType`](GraphicType.md)
