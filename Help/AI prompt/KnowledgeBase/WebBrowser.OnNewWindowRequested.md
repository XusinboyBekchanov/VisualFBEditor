[TOC]
# WebBrowser.OnNewWindowRequested Event
Triggered when a new browser window is requested (e.g., target="_blank" links)
## Definition
Namespace: [`My.Sys.Forms`]
`OnNewWindowRequested` is event of the WebBrowser control, part of the freeBasic framework MyFbFramework.
## Syntax
```freeBasic
OnNewWindowRequested As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As WebBrowser, ByRef e As NewWindowRequestedEventArgs)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`Designer`|[`My.Sys.Object`]|The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: `Designer.IsEmpty()`|
|`Sender`|[`WebBrowser`]|The object which received the signal|
|`e`|[`NewWindowRequestedEventArgs`]||

## See also
[`WebBrowser`](WebBrowser.md)
