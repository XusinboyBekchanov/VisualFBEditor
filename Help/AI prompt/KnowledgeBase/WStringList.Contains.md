[TOC]
# WStringList.Contains Method

`Contains` is method of the WStringList control, part of the freeBasic framework MyFbFramework.
##Syntax
```freeBasic
Declare Function Contains(ByRef iValue As Const WString, ByVal bMatchCase As Boolean = False, ByVal bMatchFullWords As Boolean = True, ByVal iStart As Integer = 0, ByRef Idx As Integer = -1, ByRef ListItem As WStringListItem Ptr = 0) As Boolean
```

##Parameters

|Part|Type|Description|
| :------------ | :------------ |
|`iValue`|[`Const`]("https://www.freebasic.net/wiki/KeyPgConst")[`WString`](a href="https://www.freebasic.net/wiki/KeyPgWString")||
|`bMatchCase`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")||
|`bMatchFullWords`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")||
|`iStart`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`Idx`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`ListItem`|[`WStringListItem`]||

## Return Value
[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")
## See also
[`WStringList`](WStringList.md)
