[TOC]
## Split Function

`Split` Is a global function within the MyFbFramework, part of the freeBasic framework.
## Syntax

```freeBasic
Function Split(ByRef wszMainStr As ZString, ByRef Delimiter As Const ZString, Result() As ZString Ptr, MatchCase As Boolean = True, skipEmptyElement As Boolean = False) As Long
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`wszMainStr`|[`ZString`]("https://www.freebasic.net/wiki/KeyPgZString")|Required.|
|`Delimiter`|[`Const`]("https://www.freebasic.net/wiki/KeyPgConst")[`ZString`](a href="https://www.freebasic.net/wiki/KeyPgZString")|Required.|
|`Result`|[`ZString`]("https://www.freebasic.net/wiki/KeyPgZString")|Required.|
|`MatchCase`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")|Optional.|
|`skipEmptyElement`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")|Optional.|

## Return Value
[`Long`]("https://www.freebasic.net/wiki/KeyPgLong")

