' gdipTetris
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "gdip.bi"

Type BrickUnit
	Unit(Any) As Integer
End Type

Type BrickArray
	Units(Any) As BrickUnit
	Width As Integer
	Height As Integer
End Type

Type BrickGroup
	Brick(Any) As BrickArray
	Index As Integer
	Count As Integer
End Type

'方块墙
Dim Shared TetrisWall As BrickUnit

'方块群
Dim Shared Brick() As BrickGroup

'下一个方块列表数
Dim Shared NextCount As Integer
'下一个方块列表
Dim Shared NextBrick(Any) As Integer

'下落的方块
Dim Shared DownBrick As Integer
'下落方块的方向
Dim Shared DownDiretion As Integer
'下落方块的位置
Dim Shared DownLocate As Point

Dim Shared mUpdateBitmap As gdipBitmap
Dim Shared mBackBitmap As gdipBitmap

#ifndef __USE_MAKE__
	#include once "gdipTetris.bas"
#endif
