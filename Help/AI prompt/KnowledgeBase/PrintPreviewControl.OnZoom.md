[TOC]
# PrintPreviewControl.OnZoom Event
Triggered when zoom level changes
## Definition
Namespace: [`My.Sys.Forms`]
`OnZoom` is event of the PrintPreviewControl control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnZoom As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As PrintPreviewControl)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`PrintPreviewControl`]|The object which received the signal|

## See also
[`PrintPreviewControl`](PrintPreviewControl.md)
