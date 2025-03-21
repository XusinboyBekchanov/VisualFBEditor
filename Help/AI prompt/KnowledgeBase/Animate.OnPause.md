[TOC]
# Animate.OnPause Event
Raised on playback pause
## Definition
Namespace: [`My.Sys.Forms`]
`OnPause` is event of the Animate control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnPause As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Animate)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`Animate`]|The object which received the signal|

## See also
[`Animate`](Animate.md)
