#include "SimpleVariantPlus.bi"

Dim As vbVariant wordApp

wordApp = CreateObject("Word.Application")
wordApp.Documents.Add
wordApp.Visible = True

Sleep
