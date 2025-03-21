[TOC]
## SaveToFile Function

`SaveToFile` Is a global function within the MyFbFramework, part of the freeBasic framework.
## Syntax

```freeBasic
Function SaveToFile(ByRef FileName As WString, ByRef wData As WString, ByRef FileEncoding As FileEncodings = FileEncodings.Utf8BOM, ByRef NewLineType As NewLineTypes = NewLineTypes.WindowsCRLF, ByVal nCodePage As Integer = -1) As Boolean
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`FileName`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")|Required.|
|`wData`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")|Required.|
|`FileEncoding`|[`FileEncodings`]|Optional.|
|`NewLineType`|[`NewLineTypes`]|Optional.|
|`nCodePage`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")|Optional.|

## Return Value
[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")

