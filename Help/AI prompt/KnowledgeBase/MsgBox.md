[TOC]
## MsgBox Function

`MsgBox` Is a global function within the MyFbFramework, part of the freeBasic framework.
## Syntax

```freeBasic
Function MsgBox Alias "MsgBox" (ByRef MsgStr As WString, ByRef Caption As WString = "", MsgType As MessageType = MessageType.mtInfo, ButtonsType As ButtonsTypes = ButtonsTypes.btOK) As MessageResult
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`MsgStr`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")|Required.|
|`Caption`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")|Optional.|
|`MsgType`|[`MessageType`]|Optional.|
|`ButtonsType`|[`ButtonsTypes`]|Optional.|

## Return Value
[`MessageResult __EXPORT__`]

