[TOC]
# ListViewColumns.Add Method

## Definition
Namespace: [`My.Sys.Forms`](My.Sys.Forms.md)
`Add` is method of the ListViewColumns control, part of the freeBasic framework MyFbFramework.
##Syntax
```freeBasic
Declare Function Add(ByRef FCaption As WString = "", FImageIndex As Integer = -1, iWidth As Integer = -1, Format As ColumnFormat = cfLeft, Editable As Boolean = False) As ListViewColumn Ptr
```

##Parameters

|Part|Type|Description|
| :------------ | :------------ |
|`FCaption`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")||
|`FImageIndex`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`iWidth`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`Format`|[`ColumnFormat`]||
|`Editable`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")||

## Return Value
[`ListViewColumn`]
## See also
[`ListViewColumns`](ListViewColumns.md)
