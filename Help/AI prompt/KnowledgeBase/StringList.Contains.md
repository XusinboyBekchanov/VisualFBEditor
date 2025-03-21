[TOC]
# StringList.Contains Method

`Contains` is method of the StringList control, part of the freeBasic framework MyFbFramework.
##Syntax
```freeBasic
Declare Function Contains(FItem As String, ByVal MatchCase As Boolean = False, ByVal MatchFullWords As Boolean = True, ByVal iStart As Integer = 0, ByRef Idx As Integer = -1, ByRef ListItem As StringListItem Ptr = 0) As Boolean
```

##Parameters

|Part|Type|Description|
| :------------ | :------------ |
|`FItem`|[`String`]("https://www.freebasic.net/wiki/KeyPgString")||
|`MatchCase`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")||
|`MatchFullWords`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")||
|`iStart`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`Idx`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`ListItem`|[`StringListItem`]||

## Return Value
[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")
## See also
[`StringList`](StringList.md)
