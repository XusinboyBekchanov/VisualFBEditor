[TOC]
## DllMain Function

`DllMain` Is a global function within the MyFbFramework, part of the freeBasic framework.
## Syntax

```freeBasic
Function DllMain(hinstDLL As HINSTANCE, fdwReason As DWORD, lpvReserved As LPVOID) As Boolean
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`hinstDLL`|[`HINSTANCE`]|Required.|
|`fdwReason`|[`DWORD`]|Required.|
|`lpvReserved`|[`LPVOID`]|Required.|

## Return Value
[`Boolean`]("https://www.freebasic.net/wiki/KeyPgBoolean")

