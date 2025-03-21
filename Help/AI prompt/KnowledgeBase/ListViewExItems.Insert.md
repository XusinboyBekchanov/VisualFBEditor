[TOC]
# ListViewExItems.Insert Method

## Definition
Namespace: [`My.Sys.Forms`](My.Sys.Forms.md)
`Insert` is method of the ListViewExItems control, part of the freeBasic framework MyFbFramework.
##Syntax
```freeBasic
Declare Function Insert(Index As Integer, ByRef FCaption As WString = "", ByVal FImageIndex As Integer = -1, ByVal State As Integer = 0, ByVal Indent As Integer = 0, ByRef DelimiterChr As String = "", ByVal IsLastItem As Boolean = True) As ListViewExItem Ptr
```

##Parameters

|Part|Type|Description|
| :------------ | :------------ |
|`Index`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`FCaption`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")||
|`FImageIndex`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`State`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`Indent`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`DelimiterChr`|[`String`]("https://www.freebasic.net/wiki/KeyPgString")||
|`IsLastItem`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")||

## Return Value
[`ListViewExItem`]
## See also
[`ListViewExItems`](ListViewExItems.md)
