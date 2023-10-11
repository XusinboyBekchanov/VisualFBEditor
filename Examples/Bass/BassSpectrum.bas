'BASS for freebasic translate by Cm.Wang

#pragma once

Private Constructor BassSpectrum
	Init(368,127)
End Constructor

Private Destructor BassSpectrum
	Erase dt
	Erase specbuf
End Destructor

#ifdef __FB_64BIT__
#else
	'MATH Functions
	Function fMod(ByVal a As Single , b As Single) As Single
		Function = a - Fix(a / b) * b
	End Function
	
	Function Sqrt(ByVal num As Double) As Double
		Function = num ^ 0.5
	End Function
	
	Function Log10(ByVal X As Double) As Double
		Function = Log(X) / Log(10#)
	End Function
#endif

Private Property BassSpectrum.Mode() As Integer
	Property = specmode
End Property

Private Property BassSpectrum.Mode(ByVal nVal As Integer)
	If nVal < 0 Or nVal > 3 Then Exit Property
	specmode = nVal
	ReDim specbuf(SpecWidth * (SpecHeight + 1)) As Byte ' clear display
End Property

Private Sub BassSpectrum.Init(w As Integer = 368 , h As Integer = 127) 'w As Long=368, h As Long=127)
' create bitmap To Draw spectrum in (8 Bit For easy updating)
	ReDim dt(4068)
	bh = Cast(BITMAPINFO Ptr, @dt(0))

	SpecWidth = w
	SpecHeight = h

	bh->bmiHeader.biSize = SizeOf(BITMAPINFOHEADER)
	bh->bmiHeader.biWidth = SpecWidth
	bh->bmiHeader.biHeight = SpecHeight '  upside down (Line 0=bottom)
	bh->bmiHeader.biPlanes = 1
	bh->bmiHeader.biBitCount = 8
	bh->bmiHeader.biClrUsed = 256
	bh->bmiHeader.biClrImportant = 256

' setup Palette
	Dim As Integer a
	Dim As RGBQUAD Ptr pal = Cast(RGBQUAD Ptr, @dt(0) + SizeOf(BITMAPINFOHEADER))
	For a = 1 To 127
		pal[a].rgbGreen = 256 - 2 * a
		pal[a].rgbRed = 2 * a
	Next
	For a = 0 To 31
		pal[128 + a].rgbBlue = 8 * a
		pal[128 + 32 + a].rgbBlue = 255
		pal[128 + 32 + a].rgbRed = 8 * a
		pal[128 + 64 + a].rgbRed = 255
		pal[128 + 64 + a].rgbBlue = 8 * (31 - a)
		pal[128 + 64 + a].rgbGreen = 8 * a
		pal[128 + 96 + a].rgbRed = 255
		pal[128 + 96 + a].rgbGreen = 255
		pal[128 + 96 + a].rgbBlue = 8 * a
	Next
' create the bitmap
' specbmp = CreateDIBSection(0, Cast(BITMAPINFO Ptr, bh), DIB_RGB_COLORS, @specbuf(0), NULL, 0)
' specdc = CreateCompatibleDC(0)
' SelectObject(specdc, specbmp)
End Sub

Private Sub BassSpectrum.Update(Chan As DWORD, hWnd As HANDLE)
	Dim As Integer x, y, y1

	If specmode = 3 Then ' waveform
		Dim As Integer c
		Dim As Single buf()
		Dim As BASS_CHANNELINFO ci
		BASS_ChannelGetInfo(Chan, @ci) ' Get number of channels
		ReDim buf(ci.chans * (SpecWidth + 1))
		BASS_ChannelGetData(Chan, @buf(0), ci.chans * SpecWidth * SizeOf(buf(0)) Or BASS_DATA_FLOAT) '  Get the sample Data
		ReDim specbuf(SpecWidth * (SpecHeight + 1))
		For c = 0 To ci.chans - 1
			For x = 0 To SpecWidth - 1
				Dim As Integer v = (1 - buf(x * ci.chans + c)) * SpecHeight / 2 ' invert And scale To fit display
				If v < 0 Then
					v = 0
				ElseIf v >= SpecHeight Then 
					v = SpecHeight - 1
				End If
				If x = 0 Then y = v
				Do ' Draw Line from previous sample...
					If y < v Then 
						y += 1
					ElseIf (y > v) Then
						y -= 1
					End If
					specbuf(y * SpecWidth + x) = IIf(c And 1, 127, 1) ' Left=green, Right=red (could Add more colours To Palette For more chans)
				Loop While y <> v
			Next
		Next
	Else 
		Dim As Single fft(1024)
		BASS_ChannelGetData(Chan, @fft(0), BASS_DATA_FFT2048) '  Get the FFT Data

		If specmode = 0 Then ' "normal" FFT Then
			ReDim specbuf(SpecWidth * (SpecHeight + 1))
			' memset(specbuf, 0, SpecWidth * SpecHeight)
			For x = 0 To SpecWidth / 2 - 1
#if 1
				y = Sqrt(fft(x + 1)) * 3 * SpecHeight - 4 '  scale it (sqrt To make low values more visible)
#else
				y = fft(x + 1) * 10 * SpecHeight ' scale it (linearly)
#endif
				If y > SpecHeight Then y = SpecHeight '  cap it
				If x Then ' interpolate from previous To make the display smoother Then
					y1 = (y + y1) / 2
					While (y1 >= 0) 
						specbuf(y1 * SpecWidth + x * 2 - 1) = y1 + 1
						y1 -= 1
					Wend
				End If
				y1 = y
				While (y >= 0) 
					specbuf(y * SpecWidth + x * 2) = y + 1 ' Draw level
					y -= 1
				Wend
			Next
		ElseIf specmode = 1 Then ' logarithmic, combine bins
			Dim As Integer b0 = 0
			ReDim specbuf(SpecWidth * (SpecHeight + 1))
#define BANDS 28
			For x = 0 To BANDS - 1
				Dim As Single peak = 0
				Dim As Integer b1 = 2 ^ ( x * 10.0 / (BANDS - 1))
				If (b1 <= b0) Then b1 = b0 + 1 ' make sure it uses at least 1 FFT Bin
				If (b1 > 1023) Then b1 = 1023
				Do
					b0 += 1
					If peak < fft(1 + b0) Then peak = fft(1 + b0)
				Loop While b0 < b1
				y = Sqrt(peak) * 3 * SpecHeight - 4 ' scale it (sqrt To make low values more visible)
				If (y > SpecHeight) Then y = SpecHeight ' cap it
				While (y >= 0)
					memset(@specbuf(y * SpecWidth + x * (SpecWidth / BANDS)), y + 1, SpecWidth / BANDS - 2) '  Draw bar
					y -= 1
				Wend
			Next
		Else '2 "3D"
			For x = 0 To SpecHeight - 1
				y = Sqrt(fft(x + 1)) * 3 * 127 ' scale it (sqrt To make low values more visible)
				If (y > 127) Then y = 127 ' cap it
				specbuf(x * SpecWidth + specpos) = 128 + y ' plot it
			Next
			' move marker onto Next position
			specpos = (specpos + 1) Mod SpecWidth
			For x = 0 To SpecHeight - 1
				specbuf(x * SpecWidth + specpos) = 255
			Next
		End If
	End If

	' update the display
	Dim As HDC dc = GetDC(hWnd)
	' BitBlt(dc, 0, 0, SpecWidth, SpecHeight, specdc, 0, 0, SRCCOPY)
	SetDIBitsToDevice(dc , 0 , 0 , SpecWidth , SpecHeight , 0 , 0 , 0 , SpecHeight , @specbuf(0) , bh , 0)
	ReleaseDC(hWnd, dc)
End Sub
