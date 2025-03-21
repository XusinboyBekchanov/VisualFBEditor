[TOC]
# CommandButton.OnDraw Event
Occurs when any part of a CommandButton is moved, enlarged, or exposed.
## Definition
Namespace: [`My.Sys.Forms`]
`OnDraw` is event of the CommandButton control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnDraw As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CommandButton, ByRef R As Rect, DC As HDC = 0)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`CommandButton`]|The object which received the signal|
|`R`|[`Rect`]||
|`DC`|[`HDC`]||

## See also
[`CommandButton`](CommandButton.md)
