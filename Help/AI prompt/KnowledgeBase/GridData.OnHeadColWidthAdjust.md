[TOC]
# GridData.OnHeadColWidthAdjust Event
Raised during column width adjustment.
## Definition
Namespace: [`My.Sys.Forms`]
`OnHeadColWidthAdjust` is event of the GridData control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnHeadColWidthAdjust As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As GridData, ColIndex As Integer)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`GridData`]|The object which received the signal|
|`ColIndex`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||

## See also
[`GridData`](GridData.md)
