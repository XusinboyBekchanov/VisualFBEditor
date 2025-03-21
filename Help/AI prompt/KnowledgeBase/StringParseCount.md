[TOC]
## StringParseCount Function
======================================================================================== <br>  * Returns the count of delimited fields from a string expression. <br>  If wszMainStr is empty (a null string) or contains no delimiter character(s), the string <br>  is considered to contain exactly one sub-field. In this case, AfxStrParseCount returns the value 0. <br>  Delimiter contains a string (one or more characters) that must be fully matched. <br>  Delimiters are case-sensitive. <br>  Example: StringParseCount("one,two,three", ",")   -> 3 <br>  ========================================================================================
`StringParseCount` Is a global function within the MyFbFramework, part of the freeBasic framework.
## Syntax

```freeBasic
Function StringParseCount(ByRef MainStr As WString, ByRef Delimiter As Const WString = ",", MatchCase As Boolean = True) As Long
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`MainStr`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")|Required.|
|`Delimiter`|[`Const`]("https://www.freebasic.net/wiki/KeyPgConst")[`WString`](a href="https://www.freebasic.net/wiki/KeyPgWString")|Optional.|
|`MatchCase`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")|Optional.|

## Return Value
[`Long`]("https://www.freebasic.net/wiki/KeyPgLong")

