[TOC]
## ThreadCreate_ Function

`ThreadCreate_` Is a global function within the MyFbFramework, part of the freeBasic framework.
## Syntax

```freeBasic
Function ThreadCreate_(ByVal ProcPtr_ As Sub ( ByVal userdata As Any Ptr ), ByVal param As Any Ptr = 0, ByVal stack_size As Integer = 0) As Any Ptr
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`ProcPtr_`|[`Any Ptr )`]|Required.|
|`param`|[`Any`]("https://www.freebasic.net/wiki/KeyPgAny")|Optional.|
|`stack_size`|[`Integer`]("https://www.freebasic.net/wiki/KeyPgInteger")|Optional.|

## Return Value
[`Any`]("https://www.freebasic.net/wiki/KeyPgAny")

