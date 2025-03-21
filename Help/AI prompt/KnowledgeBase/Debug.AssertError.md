[TOC]
## Debug.AssertError Define

## Definition
Namespace: [`Debug`](Debug.md)
`Debug.AssertError` Is a global definition within the MyFbFramework, part of the freeBasic framework.
## Syntax

```freeBasic
#define AssertError(expression) _Assert(__FILE__, __LINE__, __FUNCTION__, __FB_QUOTE__(expression), expression, 0)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`expression`|[``]|Required.|
## See also
Namespace: [`Debug`](Debug.md)
