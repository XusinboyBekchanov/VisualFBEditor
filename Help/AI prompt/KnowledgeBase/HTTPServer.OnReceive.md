[TOC]
# HTTPServer.OnReceive Event

## Definition
Namespace: [`My.Sys.Forms`]
`OnReceive` is event of the HTTPServer control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnReceive As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As HTTPServer, ByRef Request As HTTPServerRequest, ByRef Responce As HTTPServerResponce)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`HTTPServer`]|The object which received the signal|
|`Request`|[`HTTPServerRequest`]||
|`Responce`|[`HTTPServerResponce`]||

## See also
[`HTTPServer`](HTTPServer.md)
