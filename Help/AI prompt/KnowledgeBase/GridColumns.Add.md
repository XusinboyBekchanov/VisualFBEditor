[TOC]
# GridColumns.Add Method

## Definition
Namespace: [`My.Sys.Forms`](My.Sys.Forms.md)
`Add` is method of the GridColumns control, part of the freeBasic framework MyFbFramework.
##Syntax
```freeBasic
Declare Function Add(ByRef FCaption As WString = "", FImageIndex As Integer = -1, iWidth As Integer = 100, Format As ColumnFormat = cfLeft, ColEditable As Boolean = False, ColBackColor As Integer = -1, ColForeColor As Integer = -1) As GridColumn Ptr
```

##Parameters

|Part|Type|Description|
| :------------ | :------------ |
|`FCaption`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")||
|`FImageIndex`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`iWidth`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`Format`|[`ColumnFormat`]||
|`ColEditable`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")||
|`ColBackColor`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`ColForeColor`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||

## Return Value
[`GridColumn`]
## See also
[`GridColumns`](GridColumns.md)
