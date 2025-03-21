[TOC]
# PrintDocument.OnPrintPage Event

## Definition
Namespace: [`My.Sys.ComponentModel`]
`OnPrintPage` is event of the PrintDocument control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnPrintPage As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As PrintDocument, ByRef Canvas As My.Sys.Drawing.Canvas, ByRef HasMorePages As Boolean)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`PrintDocument`]|The object which received the signal|
|`Canvas`|[`Canvas`]||
|`HasMorePages`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")||

## See also
[`PrintDocument`](PrintDocument.md)
