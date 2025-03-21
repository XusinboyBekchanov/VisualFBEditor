[TOC]
## Replace Function
Returns a string, which is a substring of a string expression beginning at the start position (defaults to 1), in which a specified substring has been replaced with another substring a specified number of times.
`Replace` Is a global function within the MyFbFramework, part of the freeBasic framework.
## Syntax

```freeBasic
Function Replace(ByRef Expression As WString, ByRef FindingText As WString, ByRef ReplacingText As WString, ByVal Start As Integer = 1, ByVal Count As Integer = -1, MatchCase As Boolean = True, ByRef CountReplaced As Integer = 0) As UString
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Expression`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")|Required.|
|`FindingText`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")|Required.|
|`ReplacingText`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")|Required.|
|`Start`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")|Optional.|
|`Count`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")|Optional.|
|`MatchCase`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")|Optional.|
|`CountReplaced`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")|Optional.|

## Return Value
[`UString`]

