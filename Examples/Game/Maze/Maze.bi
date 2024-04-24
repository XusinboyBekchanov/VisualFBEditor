'https://www.freebasic.net/forum/viewtopic.php?p=149747&hilit=maze+solver#p149747
'************************************
'* CSGP fun code                    *
'* Maze Generator By Redcrab        *
'* 05 May 2008                      *
'* FreeBASIC code                   *
'************************************
'* Generator ensuring there is only *
'* one path from a place to another *
'************************************
Type _Maze As Maze
Enum MazeRoomStatus
	Gen = &h1000
	Normal = &h2000
	Visited = &h4000
	Sentinel = &h8000
End Enum

Enum MazeDirection
	North = &h1
	West = &h2
	South = &h4
	East = &h8
End Enum
#define FIRSTDIR North
#define LASTDIR East

Type MazeXY
	As Integer x, y
End Type

Enum MazeWall
	NOWALL =1
	WALL = 2
End Enum

Type MazeRoomData
	As Integer status,x,y
End Type

Type MazeRoom
	roomData As MazeRoomData
	walls(FIRSTDIR To LASTDIR) As MazeWall
	theMaze As _Maze Ptr
	Declare Sub init(ByVal aMaze As _Maze Ptr, ByVal x As Integer, ByVal y As Integer, ByVal status As MazeRoomStatus)
	Declare Function isWall(ByVal mdir As MazeDirection) As MazeWall
	Declare Function RoomStatus(ByVal mdir As MazeDirection) As MazeRoomStatus
	Declare Sub set(ByVal mdir As MazeDirection,ByVal wall As MazeWall)
	Declare Function getStatus() As MazeRoomStatus
	Declare Sub setStatus(st As MazeRoomStatus)
End Type

Type Maze
	Dim rooms(Any, Any) As MazeRoom
	Dim MazeMove(FIRSTDIR To LASTDIR) As MazeXY
	Dim MazeReverseDirection(FIRSTDIR To LASTDIR) As MazeDirection
	MazeSize As Integer
	WallSize As Integer
	GenTick As Integer
	Declare Sub Init(ByVal mSize As Integer, ByVal wSize As Integer)
	Declare Sub Generate(ByVal x As Integer, y As Integer, ByVal style As Integer)
	Declare Function Choose(ByVal possibilities As Integer, ByVal style As Integer) As Integer
	Declare Sub Show(ByVal WSize As Integer)
End Type

Sub Maze.Init(ByVal mSize As Integer, ByVal wSize As Integer)
	Dim As Integer i, j
	For i = FIRSTDIR To LASTDIR
		MazeMove(i).x = 0
		MazeMove(i).y = 0
		MazeReverseDirection(i) = 0
		If i And North Then
			MazeMove(i).y -= 1
			MazeReverseDirection(i) Or= South
		End If
		If i And West Then
			MazeMove(i).x -= 1
			MazeReverseDirection(i) Or= East
		End If
		If i And South Then
			MazeMove(i).y += 1
			MazeReverseDirection(i) Or= North
		End If
		If i And East Then
			MazeMove(i).x += 1
			MazeReverseDirection(i) Or= West
		End If
	Next
	MazeSize = mSize
	WallSize = wSize
	ReDim rooms(-1 To mSize, -1 To mSize)
	For i = -1 To mSize
		For j = -1 To mSize
			If i = -1 Or i = mSize Or j = -1 Or j = mSize Then
				rooms(i,j).init(@This,i,j,Sentinel)
			Else
				rooms(i,j).init(@This,i,j,Normal)
			End If
		Next
	Next
	GenTick = 0
	Generate(0,0,0)
End Sub

Sub Maze.Show(ByVal WSize As Integer)
	'Dim As Integer x, y, xx, yy, ws
	'WallSize= IIf(WSize < 10 OrElse WSize< 10, 10, WSize)
	'ws = WallSize / 2
	'Canvas.Scale(0, 0, (MazeSize+ 1) * WallSize / 2, (MazeSize+ 1) * WallSize/ 2)
	'Canvas.Cls
	'For x = 0 To MazeSize -1
	'	For y = 0 To MazeSize -1
	'		xx = x*WallSize + WallSize
	'		yy = y*WallSize + WallSize
	'		If rooms(x, y).getStatus() And (Gen Or Visited) Then
	'			'Canvas.Line(xx - ws, yy - ws, xx + ws, yy + ws, RGB(0, 32, 0), "bf")
	'			If rooms(x, y).getStatus() And Gen Then Canvas.Circle(xx, yy, ws / 2, RGB(255, 128, 0))
	'			If rooms(x, y).isWall(North) And WALL Then Canvas.Line (xx - ws, yy - ws, xx + ws, yy - ws, RGB(0, 255, 0))
	'			If rooms(x, y).isWall(West)  And WALL Then Canvas.Line (xx - ws, yy - ws, xx - ws, yy + ws, RGB(0, 255, 0))
	'			If rooms(x, y).isWall(South) And WALL Then Canvas.Line (xx - ws, yy + ws, xx + ws, yy + ws, RGB(0, 255, 0))
	'			If rooms(x, y).isWall(East)  And WALL Then Canvas.Line (xx + ws, yy - ws, xx + ws, yy + ws, RGB(0, 255, 0))
	'		End If
	'	Next
	'Next
	'For x = 0 To MazeSize -1
	'	For y = 0 To MazeSize -1
	'		xx = x * WallSize + WallSize
	'		yy = y * WallSize + WallSize
	'		If rooms(x,y).getStatus() And (Gen Or Visited) Then
	'		Else
	'			Canvas.Line(xx - ws, yy - ws, xx + ws, yy + ws, RGB(0, 64, 0), "bf")
	'		End If
	'	Next
	'Next
End Sub

Sub Maze.Generate(ByVal x As Integer, y As Integer,ByVal style As Integer)
	' "Open" walls only on non already visited room
	If rooms(x,y).getStatus() And Normal  = 0 Then Return
	Dim As Integer i, possibilities, choosen
	Do ' enumerate posibilities and choose one to drill (recursive)
		rooms(x,y).setStatus(Gen)
		'Show(8)
		possibilities = 0
		For i = FIRSTDIR To LASTDIR
			If (rooms(x,y).RoomStatus(i) And Normal)<>0 And (rooms(x,y).isWall(i) And WALL)<>0 Then
				possibilities += i ' cumulate possible direction binary mask
			End If
			i = i*2-1 ' we want power of 2 increment , to have a compliant binary mask
		Next i
		If possibilities <> 0 Then
			choosen = Choose(possibilities, style)
			rooms(x, y).set(choosen, NOWALL)
			rooms(x,y).setStatus(Visited)
			Generate(x + MazeMove(choosen).x, y + MazeMove(choosen).y, style)
		End If
	Loop Until possibilities = 0 'loop until no possibilities
	rooms(x,y).setStatus(Visited)
End Sub

Function Maze.Choose(ByVal possibilities As Integer, ByVal style As Integer) As Integer
	Dim aTry As Integer
	If possibilities = 0 Then Return 0
	GenTick += 1
	Do
		aTry  = Int(2 ^ (Int (Rnd *4))) And possibilities
	Loop While aTry  = 0
	Return aTry
End Function

Sub MazeRoom.init(ByVal aMaze As _Maze Ptr, ByVal x As Integer, ByVal y As Integer, ByVal Status As MazeRoomStatus)
	Dim As Integer i
	roomData.x = x
	roomData.y = y
	roomData.status = Status
	theMaze = aMaze
	For i = FIRSTDIR To LASTDIR
		walls(i) = WALL
	Next
End Sub

Function MazeRoom.getStatus() As MazeRoomStatus
	Return roomData.status
End Function

Sub MazeRoom.setStatus(st As MazeRoomStatus)
	roomData.status = st
End Sub

Function MazeRoom.isWall(ByVal mdir As MazeDirection) As MazeWall
	Return walls(mdir)
End Function

Function MazeRoom.RoomStatus(ByVal mdir As MazeDirection) As MazeRoomStatus
	Return theMaze->rooms(roomData.x + theMaze->MazeMove(mdir).x , roomData.y + theMaze->MazeMove(mdir).y).getStatus()
End Function

Sub MazeRoom.set(ByVal mdir As MazeDirection,ByVal WALL As MazeWall)
	walls(mdir) = WALL
	theMaze->rooms(roomData.x + theMaze->MazeMove(mdir).x , roomData.y + theMaze->MazeMove(mdir).y).walls(theMaze->MazeReverseDirection(mdir))=WALL
End Sub
