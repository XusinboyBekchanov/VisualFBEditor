[TOC]
# Header.AddSection Method
Appends new header section
## Definition
Namespace: [`My.Sys.Forms`](My.Sys.Forms.md)
`AddSection` is method of the Header control, part of the freeBasic framework MyFbFramework.
##Syntax
```freeBasic
Declare Function AddSection(ByRef FCaption As WString = "", FImageIndex As Integer = -1, FWidth As Integer = -1, FAlignment As Integer = 0, bResizable As Boolean = True) As HeaderSection Ptr
```

##Parameters

|Part|Type|Description|
| :------------ | :------------ |
|`FCaption`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")||
|`FImageIndex`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`FWidth`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`FAlignment`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`bResizable`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")||

## Return Value
[`HeaderSection`]
## See also
[`Header`](Header.md)
