Type c
	a As String
	
End Type

Dim d As c Ptr = New c[100]
d[1].a = "fdfd"
?d[1].a
Sleep
