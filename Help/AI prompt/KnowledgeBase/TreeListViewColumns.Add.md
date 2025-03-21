[TOC]
# TreeListViewColumns.Add Method
Creates and appends new item
## Definition
Namespace: [`My.Sys.Forms`](My.Sys.Forms.md)
`Add` is method of the TreeListViewColumns control, part of the freeBasic framework MyFbFramework.
##Syntax
```freeBasic
Declare Function Add(ByRef FCaption As WString = "", FImageIndex As Integer = -1, iWidth As Integer = -1, Format As ColumnFormat = cfLeft, ColEditable As Boolean = False) As TreeListViewColumn Ptr
```

##Parameters

|Part|Type|Description|
| :------------ | :------------ |
|`FCaption`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")||
|`FImageIndex`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`iWidth`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`Format`|[`ColumnFormat`]||
|`ColEditable`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")||

## Return Value
[`TreeListViewColumn`]
## See also
[`TreeListViewColumns`](TreeListViewColumns.md)
