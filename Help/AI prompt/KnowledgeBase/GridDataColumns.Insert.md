[TOC]
# GridDataColumns.Insert Method

## Definition
Namespace: [`My.Sys.Forms`](My.Sys.Forms.md)
`Insert` is method of the GridDataColumns control, part of the freeBasic framework MyFbFramework.
##Syntax
```freeBasic
Declare Sub Insert(Index As Integer, ByRef FCaption As WString = "", FImageIndex As Integer = -1, iWidth As Integer = -1, tFormat As ColumnFormat = cfLeft, tDataType As GridDataTypeEnum = DT_String, tLocked As Boolean = False, tControlType As GridControlTypeEnum = CT_TextBox, ByRef tComboItem As WString = "", tSortOrder As SortStyle = SortStyle.ssSortAscending)
```

##Parameters

|Part|Type|Description|
| :------------ | :------------ |
|`Index`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`FCaption`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")||
|`FImageIndex`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`iWidth`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`tFormat`|[`ColumnFormat`]||
|`tDataType`|[`GridDataTypeEnum`]||
|`tLocked`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")||
|`tControlType`|[`GridControlTypeEnum`]||
|`tComboItem`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")||
|`tSortOrder`|[`SortStyle`]||
## See also
[`GridDataColumns`](GridDataColumns.md)
