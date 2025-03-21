[TOC]
## Debug.AssertWarning Define

## Definition
Namespace: [`Debug`](Debug.md)
`Debug.AssertWarning` Is a global definition within the MyFbFramework, part of the freeBasic framework.
## Syntax

```freeBasic
#define AssertWarning(expression) _Assert(__FILE__, __LINE__, __FUNCTION__, __FB_QUOTE__(expression), expression, 1)
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`expression`|[``]|Required.|
## See also
Namespace: [`Debug`](Debug.md)
