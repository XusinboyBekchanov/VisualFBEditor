Type Control
	FLeft As Integer
	FTop As Integer
	FWidth As Integer
	FHeight As Integer
	Declare Sub SetBounds(ALeft As Integer, ATop As Integer, AWidth As Integer, AHeight As Integer)
End Type

Sub Control.SetBounds(ALeft As Integer, ATop As Integer, AWidth As Integer, AHeight As Integer)
	FLeft   = ALeft
	FTop    = ATop
	FWidth  = AWidth
	FHeight = AHeight
	?FLeft, FTop, FWidth, FHeight
End Sub

Dim As Control ctl
ctl.SetBounds 1297, 218, 503, 65
Sleep
