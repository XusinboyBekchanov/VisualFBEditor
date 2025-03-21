[TOC]
# Header.OnEndTrack Event
Raised after section resizing completes
## Definition
Namespace: [`My.Sys.Forms`]
`OnEndTrack` is event of the Header control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnEndTrack As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Header, ByRef Section As HeaderSection)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`Header`]|The object which received the signal|
|`Section`|[`HeaderSection`]||

## See also
[`Header`](Header.md)
