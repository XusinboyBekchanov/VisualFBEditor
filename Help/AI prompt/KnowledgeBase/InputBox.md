[TOC]
## InputBox Function

`InputBox` Is a global function within the MyFbFramework, part of the freeBasic framework.
## Syntax

```freeBasic
Function InputBox(ByRef sCaption As WString  = "" , ByRef sMessageText As WString = "Enter text:" , ByRef sDefaultText As WString = "" , iFlag As Long = 0 , iFlag2 As Long = 0, hParentWin As Any Ptr = 0) As UString
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`sCaption`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")|Optional.|
|`sMessageText`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")|Optional.|
|`sDefaultText`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")|Optional.|
|`iFlag`|[`Long`]("https://www.freebasic.net/wiki/KeyPgLong")|Optional.|
|`iFlag2`|[`Long`]("https://www.freebasic.net/wiki/KeyPgLong")|Optional.|
|`hParentWin`|[`Any`]("https://www.freebasic.net/wiki/KeyPgAny")|Optional.|

## Return Value
[`UString __EXPORT__`]

