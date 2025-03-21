[TOC]
# ListControl.OnDrawItem Event
Custom item painting event
## Definition
Namespace: [`My.Sys.Forms`]
`OnDrawItem` is event of the ListControl control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnDrawItem As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ListControl, ItemIndex As Integer, State As Integer, ByRef R As My.Sys.Drawing.Rect, DC As HDC = 0)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`ListControl`]|The object which received the signal|
|`ItemIndex`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`State`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`R`|[`Rect`]||
|`DC`|[`HDC`]||

## See also
[`ListControl`](ListControl.md)
