[TOC]
# LinkLabel.OnLinkClicked Event
Triggered when hyperlink is activated
## Definition
Namespace: [`My.Sys.Forms`]
`OnLinkClicked` is event of the LinkLabel control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnLinkClicked As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As LinkLabel, ByVal ItemIndex As Integer, ByRef Link As WString, ByRef Action As Integer)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`LinkLabel`]|The object which received the signal|
|`ItemIndex`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||
|`Link`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")||
|`Action`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")||

## See also
[`LinkLabel`](LinkLabel.md)
