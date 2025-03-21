[TOC]
# ContainerControl.RegisterClass Method
Function registers a window class for subsequent use in calls to the create window (Windows, Linux)
## Definition
Namespace: [`My.Sys.Forms`](My.Sys.Forms.md)
`RegisterClass` is method of the ContainerControl control, part of the freeBasic framework MyFbFramework.
##Syntax
```freeBasic
Declare Function RegisterClass(ByRef wClassName As WString, Obj As Any Ptr, WndProcAddr As Any Ptr = 0) As Boolean
```

##Parameters

|Part|Type|Description|
| :------------ | :------------ |
|`wClassName`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")||
|`Obj`|[`Any`]("https://www.freebasic.net/wiki/KeyPgAny")||
|`WndProcAddr`|[`Any`]("https://www.freebasic.net/wiki/KeyPgAny")||

## Return Value
[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")
## See also
[`ContainerControl`](ContainerControl.md)
