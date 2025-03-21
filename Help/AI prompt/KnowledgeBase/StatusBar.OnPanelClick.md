[TOC]
# StatusBar.OnPanelClick Event
Triggered when a status panel is clicked
## Definition
Namespace: [`My.Sys.Forms`]
`OnPanelClick` is event of the StatusBar control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnPanelClick As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As StatusBar, ByRef stPanel As StatusPanel, MouseButton As Integer, x As Integer, y As Integer)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`StatusBar`]|The object which received the signal|
|`stPanel`|[`StatusPanel`]||
|`MouseButton`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`x`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`y`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||

## See also
[`StatusBar`](StatusBar.md)
