[TOC]
# HTTPConnection.OnReceive Event

## Definition
Namespace: [`My.Sys.Forms`]
`OnReceive` is event of the HTTPConnection control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnReceive As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As HTTPConnection, ByRef Request As HTTPRequest, ByRef Responce As HTTPResponce)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`HTTPConnection`]|The object which received the signal|
|`Request`|[`HTTPRequest`]||
|`Responce`|[`HTTPResponce`]||

## See also
[`HTTPConnection`](HTTPConnection.md)
