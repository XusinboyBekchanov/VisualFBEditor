[TOC]
## StringExtract Function

`StringExtract` Is a global function within the MyFbFramework, part of the freeBasic framework.
## Syntax

```freeBasic
Function StringExtract(ByRef wszMainStr As WString, ByRef wszDelim1 As Const WString, ByRef wszDelim2 As Const WString, ByVal nStart As Long = 1, ByVal MatchCase As Boolean = True) As UString
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`wszMainStr`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")|Required.|
|`wszDelim1`|[`Const`]("https://www.freebasic.net/wiki/KeyPgConst")[`WString`](a href="https://www.freebasic.net/wiki/KeyPgWString")|Required.|
|`wszDelim2`|[`Const`]("https://www.freebasic.net/wiki/KeyPgConst")[`WString`](a href="https://www.freebasic.net/wiki/KeyPgWString")|Required.|
|`nStart`|[`Long`]("https://www.freebasic.net/wiki/KeyPgLong")|Optional.|
|`MatchCase`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")|Optional.|

## Return Value
[`UString`]

