[TOC]
## CreateControl Function

`CreateControl` Is a global function within the MyFbFramework, part of the freeBasic framework.
## Syntax

```freeBasic
Function CreateControl Alias "CreateControl" (ByRef ClassName As String, ByRef sName As WString, ByRef Text As WString, lLeft As Integer, lTop As Integer, lWidth As Integer, lHeight As Integer, Parent As Control Ptr) As Control Ptr Export
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`ClassName`|[`String`]("https://www.freebasic.net/wiki/KeyPgString")|Required.|
|`sName`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")|Required.|
|`Text`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")|Required.|
|`lLeft`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")|Required.|
|`lTop`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")|Required.|
|`lWidth`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")|Required.|
|`lHeight`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")|Required.|
|`Parent`|[`Control`]|Required.|

## Return Value
[`Control Ptr Export`]

