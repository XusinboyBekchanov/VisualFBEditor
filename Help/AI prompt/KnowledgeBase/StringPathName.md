[TOC]
## StringPathName Function
======================================================================================== <br>   Parses a path/file name to extract component parts. <br>   This function evaluates a text path/file text name, and returns a requested part of the <br>   name. The functionality is strictly one of string parsing alone. <br>   wszOption is one of the following words which is used to specify the requested part: <br>   PATH <br>         Returns the path portion of the path/file Name. That is the text up to and <br>         including the last backslash (\) or colon (:). <br>   NAME <br>         Returns the name portion of the path/file Name. That is the text to the right <br>         of the last backslash (\) or colon (:), ending just before the last period (.). <br>   EXTN <br>         Returns the extension portion of the path/file name. That is the last <br>         period (.) in the string plus the text to the right of it. <br>   NAMEX <br>         Returns the name and the EXTN parts combined. <br>    Example: StringPathName("C:\VisualFBEditor\Poject.Bas")           ->C:\Visual Free Basic\ <br>             StringPathName("C:\VisualFBEditor\Poject.Bas","NAME")    ->Poject <br>             StringPathName("C:\VisualFBEditor\Poject.Bas","NAMEEX")  ->Poject.Bas <br>             StringPathName("C:\VisualFBEditor\Poject.Bas","EXTN")     -> .Bas <br>  ========================================================================================
`StringPathName` Is a global function within the MyFbFramework, part of the freeBasic framework.
## Syntax

```freeBasic
Function StringPathName(ByRef wszFileSpec As WString, ByRef wszOption As Const WString = "PATH") As UString
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`wszFileSpec`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")|Required.|
|`wszOption`|[`Const`]("https://www.freebasic.net/wiki/KeyPgConst")[`WString`](a href="https://www.freebasic.net/wiki/KeyPgWString")|Optional.|

## Return Value
[`UString`]

