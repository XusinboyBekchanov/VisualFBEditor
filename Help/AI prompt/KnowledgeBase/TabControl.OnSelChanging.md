[TOC]
# TabControl.OnSelChanging Event

## Definition
Namespace: [`My.Sys.Forms`]
`OnSelChanging` is event of the TabControl control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnSelChanging As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TabControl, NewIndex As Integer)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`TabControl`]|The object which received the signal|
|`NewIndex`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||

## See also
[`TabControl`](TabControl.md)
