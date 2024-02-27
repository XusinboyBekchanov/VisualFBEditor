'gdipAnimate动画
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "gdipAnimate.bi"

Private Constructor gdipAnimate
	'Todo: FrameDimensionTime freebasic not decdared at gdip Win32
	CLSIDFromString("{6AEDBD6D-3FB5-418A-83A6-7F45229DC872}", @GUID_FrameDimensionTime)
End Constructor

Private Destructor gdipAnimate
	Erase mFrameDelays
End Destructor

Private Sub gdipAnimate.ImageFile(sFileName As WString, ByVal sFrameWidth As Integer = 0, ByVal sFrameHeight As Integer = 0, ByVal sFrameCount As Integer = -1)
	mFileBitmap.DrawFromFile(sFileName)
	
	' 识别图像格式
	Dim fguid As GUID
	GdipGetImageRawFormat(mFileBitmap.Image, @fguid)
	'Debug.Print "fguid.Data1: &H" & Hex(fguid.Data1)
	Select Case fguid.Data1
	Case &HB96B3CB0
		' 获取帧数
		'Todo: FrameDimensionTime freebasic not decdared at gdip Win32
		'GdipImageGetFrameCount(mFileBitmap.Image, @FrameDimensionTime, @mFrameCount)
		GdipImageGetFrameCount(mFileBitmap.Image, @GUID_FrameDimensionTime, @mFrameCount)
		mFrameCount = mFrameCount - 1
		
		' 获取属性项大小
		Dim propItemSize As UINT
		GdipGetPropertyItemSize(mFileBitmap.Image, PropertyTagFrameDelay, @propItemSize)
		' 申请内存存储属性项数据
		Dim propItem As PropertyItem Ptr = Allocate(propItemSize)
		' 获取属性项数据
		GdipGetPropertyItem(mFileBitmap.Image, PropertyTagFrameDelay, propItemSize, propItem)
		
		' 解析属性项数据
		Dim i As Integer
		ReDim mFrameDelays(mFrameCount)
		' 获取每帧时延
		For i = 0 To mFrameCount
			mFrameDelays(i) = *Cast(ULong Ptr, (propItem->value + i*SizeOf(ULong)))
			
			'换算成毫秒
			Select Case mFrameDelays(i)
			Case Is > 6000
				mFrameDelays(i) = 60000 ' Max.: 1 min.
			Case Is < 5
				mFrameDelays(i) = 50    ' Min.: 0.05 sec.
			Case Else
				mFrameDelays(i) = mFrameDelays(i) * 10
			End Select
		Next i
		
		mIsGif = True
		mFrameCountX = 0
		mFrameCountY = 0
		mFrameWidth = mFileBitmap.Width
		mFrameHeight = mFileBitmap.Height
	Case Else
		'Select Case fguid.Data1
		'Case &HB96B3CB1: Debug.Print "TIF"
		'Case &HB96B3CAB: Debug.Print "Bitmap BITMAP file"
		'Case &HB96B3CAA: Debug.Print "Bitmap memory BITMAP (Scan0)"
		'Case &HB96B3CAE: Debug.Print "JPEG"
		'Case &HB96B3CAF: Debug.Print "PNG"
		'Case &HB96B3CAC: Debug.Print "EMetafile"
		'End Select
		mIsGif = False
		Erase mFrameDelays
		mFrameWidth = IIf(sFrameWidth > 0, sFrameWidth, mFileBitmap.Width)
		mFrameHeight = IIf(sFrameHeight > 0, sFrameHeight, mFileBitmap.Height)
		mFrameCountX = mFileBitmap.Width / mFrameWidth - 1
		mFrameCountY = mFileBitmap.Height / mFrameHeight - 1
		mFrameCount = IIf(sFrameCount < 0, mFrameCountY * (mFrameCountX + 1) + mFrameCountX, sFrameCount)
	End Select
	'Debug.Print "mFrameCount: " & mFrameCount
	mFrameIndex = 0
End Sub

Private Function gdipAnimate.ImageFrame(ByVal sInc As Integer = 1) As GpImage Ptr
	mAnimate.Initial(mFrameWidth, mFrameHeight)
	mFrameIndex += sInc
	If sInc < 0 And mFrameIndex < 0 Then mFrameIndex = mFrameCount
	If sInc > 0 And mFrameIndex > mFrameCount Then mFrameIndex = 0
	
	If mIsGif Then
		'Todo: FrameDimensionTime freebasic not decdared at gdip Win32
		'GdipImageSelectActiveFrame(mFileBitmap.Image, @FrameDimensionTime, mFrameIndex)
		GdipImageSelectActiveFrame(mFileBitmap.Image, @GUID_FrameDimensionTime, mFrameIndex)
		GdipDrawImageRectI(mAnimate.Graphics, mFileBitmap.Image, 0, 0, mFrameWidth, mFrameHeight)
	Else
		Dim mFrameX As Integer = mFrameIndex Mod (mFrameCountX + 1)
		Dim mFrameY As Integer = mFrameIndex \ (mFrameCountX + 1)
		GdipDrawImageRectRectI(mAnimate.Graphics, mFileBitmap.Image, 0, 0, mFrameWidth, mFrameHeight, mFrameWidth*mFrameX, mFrameHeight*mFrameY, mFrameWidth, mFrameHeight, UnitPixel, NULL, NULL, NULL)
	End If
	GdipImageRotateFlip(mAnimate.Image, mRotate)
	
	Return mAnimate.Image
End Function
