[TOC]
# ListViewExColumns.Add Method

## Definition
Namespace: [`My.Sys.Forms`](My.Sys.Forms.md)
`Add` is method of the ListViewExColumns control, part of the freeBasic framework MyFbFramework.
##Syntax
```freeBasic
Declare Function Add(ByRef FCaption As WString = "", FImageIndex As Integer = -1, iWidth As Integer = -1, Format As ColumnFormat = cfLeft, Editable As Boolean = False, iBackColor As Integer = -1) As ListViewExColumn Ptr
```

##Parameters

|Part|Type|Description|
| :------------ | :------------ |
|`FCaption`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")||
|`FImageIndex`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`iWidth`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`Format`|[`ColumnFormat`]||
|`Editable`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")||
|`iBackColor`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||

## Return Value
[`ListViewExColumn`]
## See also
[`ListViewExColumns`](ListViewExColumns.md)
