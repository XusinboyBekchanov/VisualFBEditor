[TOC]
## WGet Function
Dereferences a WString pointer to <a href="https://www.freebasic.net/wiki/KeyPgWString">WString</a>. <br>  <br> Parameters <br>    subject <br>        WString Pointer to dereference. If the value is NULL, zero-length string ("") is returned. <br>  <br> Example <br> #include "mff/UString.bi" <br>  <br> Dim p As WString Ptr <br>  <br> Print WGet(p) <br>  <br> p = Allocate(SizeOf(WString) * 5) <br>  <br> *p = "Good" <br>  <br> Print WGet(p) <br>  <br> Delete p <br>  <br> Sleep <br>  <br> See also <br>    iGet <br>    ZGet
`WGet` Is a global function within the MyFbFramework, part of the freeBasic framework.
## Syntax

```freeBasic
Function WGet(ByRef subject As WString Ptr) ByRef As WString
```

## Parameters

|Part|Type|Description|
| :------------ | :------------ | :------------ |
|`subject`|[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")|Required.|

## Return Value
[`WString`]("https://www.freebasic.net/wiki/KeyPgWString")

