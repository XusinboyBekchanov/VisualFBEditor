[TOC]
# IPAddress.OnFieldChanged Event
Raised when specific octet changes
## Definition
Namespace: [`My.Sys.Forms`]
`OnFieldChanged` is event of the IPAddress control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnFieldChanged As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As IPAddress, iField As Integer, iValue As Integer)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`IPAddress`]|The object which received the signal|
|`iField`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`iValue`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||

## See also
[`IPAddress`](IPAddress.md)
