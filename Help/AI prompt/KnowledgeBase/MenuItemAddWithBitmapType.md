[TOC]
## MenuItemAddWithBitmapType Function

`MenuItemAddWithBitmapType` Is a global function within the MyFbFramework, part of the freeBasic framework.
## Syntax

```freeBasic
Function MenuItemAddWithBitmapType Alias "MenuItemAddWithBitmapType" (PMenuItem As My.Sys.Forms.MenuItem Ptr, ByRef sCaption As WString, iImage As My.Sys.Drawing.BitmapType Ptr, sKey As String = "", eClick As Any Ptr = NULL, Index As Integer = -1) As My.Sys.Forms.MenuItem Ptr Export
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`PMenuItem`|[`MenuItem`]|Required.|
|`sCaption`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")|Required.|
|`iImage`|[`BitmapType`]|Required.|
|`sKey`|[`String`]("https://www.freebasic.net/wiki/KeyPgString")|Optional.|
|`eClick`|[`Any`]("https://www.freebasic.net/wiki/KeyPgAny")|Optional.|
|`Index`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")|Optional.|

## Return Value
[`My.Sys.Forms.MenuItem Ptr Export`]

