[TOC]
## Join Function

`Join` Is a global function within the MyFbFramework, part of the freeBasic framework.
## Syntax

```freeBasic
Function Join(SubjectPtr() As ZString Ptr, ByRef Delimiter As Const ZString, ByVal skipEmptyElement As Boolean = False, iStart As Integer = 0, iStep As Integer = 1) As ZString Ptr
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`SubjectPtr`|[`ZString`]("https://www.freebasic.net/wiki/KeyPgZString")|Required.|
|`Delimiter`|[`Const`]("https://www.freebasic.net/wiki/KeyPgConst")[`ZString`](a href="https://www.freebasic.net/wiki/KeyPgZString")|Required.|
|`skipEmptyElement`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")|Optional.|
|`iStart`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")|Optional.|
|`iStep`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")|Optional.|

## Return Value
[`ZString`]("https://www.freebasic.net/wiki/KeyPgZString")

