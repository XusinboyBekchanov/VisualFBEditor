[TOC]
## BGR Define

`BGR` Is a global definition within the MyFbFramework, part of the freeBasic framework.
## Syntax

```freeBasic
#define BGR(r, g, b) (Cast(UByte, (r)) Or (Cast(UShort, Cast(UByte, (g))) Shl 8)) Or (Cast(UShort, Cast(UByte, (b))) Shl 16)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`r`|[``]|Required.|
|`g`|[``]|Required.|
|`b`|[``]|Required.|
