[TOC]
# ListView.OnColumnClick Event

## Definition
Namespace: [`My.Sys.Forms`]
`OnColumnClick` is event of the ListView control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnColumnClick As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ColIndex As Integer, ByVal SortOrder As SortStyle, ByVal MatchCase As Boolean)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`ListView`]|The object which received the signal|
|`ColIndex`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`SortOrder`|[`SortStyle`]||
|`MatchCase`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")||

## See also
[`ListView`](ListView.md)
