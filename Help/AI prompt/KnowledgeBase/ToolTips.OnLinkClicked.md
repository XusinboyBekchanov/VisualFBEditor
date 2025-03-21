[TOC]
# ToolTips.OnLinkClicked Event

## Definition
Namespace: [`My.Sys.Forms`]
`OnLinkClicked` is event of the ToolTips control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnLinkClicked As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ToolTips, ByRef link As WString)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`ToolTips`]|The object which received the signal|
|`link`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")||

## See also
[`ToolTips`](ToolTips.md)
