[TOC]
# Picture.OnDraw Event
OnClick    As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Picture) <br> OnDblClick As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Picture)
## Definition
Namespace: [`My.Sys.Forms`]
`OnDraw` is event of the Picture control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnDraw As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Picture, ByRef R As My.Sys.Drawing.Rect, DC As HDC)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`Picture`]|The object which received the signal|
|`R`|[`Rect`]||
|`DC`|[`HDC`]||

## See also
[`Picture`](Picture.md)
