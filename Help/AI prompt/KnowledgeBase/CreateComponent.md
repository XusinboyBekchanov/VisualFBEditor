[TOC]
## CreateComponent Function

`CreateComponent` Is a global function within the MyFbFramework, part of the freeBasic framework.
## Syntax

```freeBasic
Function CreateComponent Alias "CreateComponent" (ByRef ClassName As String, ByRef sName As WString, lLeft As Integer, lTop As Integer, Parent As Control Ptr) As Component Ptr Export
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`ClassName`|[`String`]("https://www.freebasic.net/wiki/KeyPgString")|Required.|
|`sName`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")|Required.|
|`lLeft`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")|Required.|
|`lTop`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")|Required.|
|`Parent`|[`Control`]|Required.|

## Return Value
[`Component Ptr Export`]

