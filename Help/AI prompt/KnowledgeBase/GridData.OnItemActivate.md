[TOC]
# GridData.OnItemActivate Event
Triggered on row activation.
## Definition
Namespace: [`My.Sys.Forms`]
`OnItemActivate` is event of the GridData control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnItemActivate As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As GridData, ByRef Item As GridDataItem Ptr)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`GridData`]|The object which received the signal|
|`Item`|[`GridDataItem`]||

## See also
[`GridData`](GridData.md)
