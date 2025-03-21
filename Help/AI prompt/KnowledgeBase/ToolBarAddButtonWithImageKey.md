[TOC]
## ToolBarAddButtonWithImageKey Function

`ToolBarAddButtonWithImageKey` Is a global function within the MyFbFramework, part of the freeBasic framework.
## Syntax

```freeBasic
Function ToolBarAddButtonWithImageKey Alias "ToolBarAddButtonWithImageKey"(tb As My.Sys.Forms.ToolBar Ptr, FStyle As Integer = My.Sys.Forms.tbsAutosize, ByRef ImageKey As WString, Index As Integer = -1, FClick As Any Ptr = NULL, ByRef FKey As WString = "", ByRef FCaption As WString = "", ByRef FHint As WString = "", FShowHint As Boolean = False, FState As Integer = My.Sys.Forms.tstEnabled) As My.Sys.Forms.ToolButton Ptr Export
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`tb`|[`ToolBar`]|Required.|
|`FStyle`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")|Optional.|
|`ImageKey`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")|Required.|
|`Index`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")|Optional.|
|`FClick`|[`Any`]("https://www.freebasic.net/wiki/KeyPgAny")|Optional.|
|`FKey`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")|Optional.|
|`FCaption`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")|Optional.|
|`FHint`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")|Optional.|
|`FShowHint`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")|Optional.|
|`FState`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")|Optional.|

## Return Value
[`My.Sys.Forms.ToolButton Ptr Export`]

