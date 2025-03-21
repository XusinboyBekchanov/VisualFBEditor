[TOC]
# ToolPalette.OnButtonActivate Event
Triggered when tool becomes active (selected)
## Definition
Namespace: [`My.Sys.Forms`]
`OnButtonActivate` is event of the ToolPalette control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnButtonActivate As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ToolPalette, ByRef Button As ToolButton)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`ToolPalette`]|The object which received the signal|
|`Button`|[`ToolButton`]||

## See also
[`ToolPalette`](ToolPalette.md)
