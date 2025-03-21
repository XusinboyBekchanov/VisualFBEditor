[TOC]
## StringSubStringAll Function

`StringSubStringAll` Is a global function within the MyFbFramework, part of the freeBasic framework.
## Syntax

```freeBasic
Function StringSubStringAll(ByRef wszMainStr As WString, ByRef ParseStart As Const WString, ByRef ParseEnd As Const WString, Result() As WString Ptr, MatchCase As Boolean = True) As Long
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`wszMainStr`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")|Required.|
|`ParseStart`|[`Const`]("https://www.freebasic.net/wiki/KeyPgConst")[`WString`](a href="https://www.freebasic.net/wiki/KeyPgWString")|Required.|
|`ParseEnd`|[`Const`]("https://www.freebasic.net/wiki/KeyPgConst")[`WString`](a href="https://www.freebasic.net/wiki/KeyPgWString")|Required.|
|`Result`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")|Required.|
|`MatchCase`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")|Optional.|

## Return Value
[`Long`]("https://www.freebasic.net/wiki/KeyPgLong")

