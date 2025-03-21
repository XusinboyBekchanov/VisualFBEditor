[TOC]
# Header.OnSectionDblClick Event
Section header double-click detection
## Definition
Namespace: [`My.Sys.Forms`]
`OnSectionDblClick` is event of the Header control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnSectionDblClick As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Header, ByRef Section As HeaderSection, Index As Integer, MouseButton As Integer)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`Header`]|The object which received the signal|
|`Section`|[`HeaderSection`]||
|`Index`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`MouseButton`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||

## See also
[`Header`](Header.md)
