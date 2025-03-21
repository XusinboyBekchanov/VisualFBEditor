[TOC]
# Control.RequestAlign Method
Instructs the parent of a control to reposition the control, enforcing its Align property (Windows, Linux, Android, Web).
## Definition
Namespace: [`My.Sys.Forms`](My.Sys.Forms.md)
`RequestAlign` is method of the Control control, part of the freeBasic framework MyFbFramework.
##Syntax
```freeBasic
Declare Sub RequestAlign(iClientWidth As Integer = -1, iClientHeight As Integer = -1, bInDraw As Boolean = False, bWithoutControl As Control Ptr = 0)
```

##Parameters

|Part|Type|Description|
| :------------ | :------------ |
|`iClientWidth`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`iClientHeight`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`bInDraw`|[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")||
|`bWithoutControl`|[`Control`]||
## See also
[`Control`](Control.md)
