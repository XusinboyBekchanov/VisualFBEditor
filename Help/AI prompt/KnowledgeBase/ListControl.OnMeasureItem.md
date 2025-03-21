[TOC]
# ListControl.OnMeasureItem Event
Custom item size measurement event
## Definition
Namespace: [`My.Sys.Forms`]
`OnMeasureItem` is event of the ListControl control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnMeasureItem As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ListControl, ItemIndex As Integer, ByRef Height As UINT)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`ListControl`]|The object which received the signal|
|`ItemIndex`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`Height`|[`UINT`]||

## See also
[`ListControl`](ListControl.md)
