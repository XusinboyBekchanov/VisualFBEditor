[TOC]
# Icon.Changed Event

## Definition
Namespace: [`My.Sys.Drawing`]
`Changed` is event of the Icon control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
Changed As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Icon)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`Icon`]|The object which received the signal|

## See also
[`Icon`](Icon.md)
