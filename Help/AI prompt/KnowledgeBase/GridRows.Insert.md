[TOC]
# GridRows.Insert Method

## Definition
Namespace: [`My.Sys.Forms`](My.Sys.Forms.md)
`Insert` is method of the GridRows control, part of the freeBasic framework MyFbFramework.
##Syntax
```freeBasic
Declare Function Insert(Index As Integer, ByRef FCaption As WString = "", FImageIndex As Integer = -1, State As Integer = 0, Indent As Integer = 0, InsertBefore As Boolean = True, RowEditable As Boolean = False, ColorBK As Integer = -1, ColorText As Integer = -1, DuplicateIndex As Integer = -1) As GridRow Ptr
```

##Parameters

|Part|Type|Description|
| :------------ | :------------ |
|`Index`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`FCaption`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")||
|`FImageIndex`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`State`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`Indent`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`InsertBefore`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")||
|`RowEditable`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")||
|`ColorBK`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`ColorText`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`DuplicateIndex`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||

## Return Value
[`GridRow`]
## See also
[`GridRows`](GridRows.md)
