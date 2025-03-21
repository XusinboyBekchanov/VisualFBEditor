[TOC]
# ImageList.Remove Method
  Declare Sub AddPng(ByRef ResName As WString, ByRef Key As WString = "", ModuleHandle As Any Ptr = 0) <br>   Declare Sub Set(Index As Integer, Bitmap As My.Sys.Drawing.BitmapType, Mask As My.Sys.Drawing.BitmapType, ByRef Key As WString = "") <br>   Declare Sub Set(ByRef Key As WString, Bitmap As My.Sys.Drawing.BitmapType, Mask As My.Sys.Drawing.BitmapType, ByRef Key As WString = "") <br>   Declare Sub Set(Index As Integer, Icon As My.Sys.Drawing.Icon, ByRef Key As WString = "") <br>   Declare Sub Set(ByRef Key As WString, Icon As My.Sys.Drawing.Icon, ByRef Key As WString = "") <br>   Declare Sub Set(Index As Integer, Cursor As My.Sys.Drawing.Cursor, ByRef Key As WString = "") <br>   Declare Sub Set(ByRef Key As WString, Cursor As My.Sys.Drawing.Cursor, ByRef Key As WString = "") <br>   Declare Sub Set(Index As Integer, ByRef ResName As WString, ModuleHandle As Any Ptr = 0) <br>   Declare Sub Set(ByRef Key As WString, ByRef ResName As WString, ModuleHandle As Any Ptr = 0) <br>   Declare Sub SetFromFile(Index As Integer, ByRef File As WString) <br>   Declare Sub SetFromFile(ByRef Key As WString, ByRef File As WString)
## Definition
Namespace: [`My.Sys.Forms`](My.Sys.Forms.md)
`Remove` is method of the ImageList control, part of the freeBasic framework MyFbFramework.
##Syntax
```freeBasic
Declare Sub Remove(Index As Integer)
```

##Parameters

|Part|Type|Description|
| :------------ | :------------ |
|`Index`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
## See also
[`ImageList`](ImageList.md)
