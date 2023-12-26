' Analog Clock模拟时钟
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

#include once "gdipAnalogClock.bi"

Private Constructor AnalogClock
	WLet(mFontName, "Arial")
	WLet(mFormat, "h:mm:ss")
End Constructor

Private Destructor AnalogClock
	If mFormat Then Deallocate mFormat
	mFormat = NULL
	If mFile Then Deallocate mFile
	mFile = NULL
	If mFontName Then Deallocate mFontName
	mFontName = NULL
End Destructor

Private Sub AnalogClock.Release()
	Deallocate mFile
	mFile = NULL
End Sub

Private Property AnalogClock.FileName(ByRef fFileName As WString)
	WLet(mFile, fFileName)
	mImgBack.FromFile(*mFile)
	mBGScale = mImgBack.Height / mImgBack.Width
End Property
Private Property AnalogClock.FileName() ByRef As WString
	Return *mFile
End Property

Private Sub AnalogClock.ImageInit(ByVal pWidth As Single = 300, ByVal pHeight As Single = 400, ByVal pAlpha As UByte = 255)
	mWidth = pWidth
	mHeight = pHeight
	Dim sImg As gdipImage
	
	mBackBitmap.Initial(mWidth, mHeight)
	If mBackground Then mBackBitmap.DrawScaleImage(mImgBack.Image)
	
	If mTray Then
		sImg.Image = AnalogClockTray(mWidth, pAlpha)
		mBackBitmap.DrawScaleImage(sImg.Image)
	End If
	
	If mScale Then
		sImg.Image = AnalogClockScale(mWidth, pAlpha)
		mBackBitmap.DrawScaleImage(sImg.Image)
	End If
End Sub

Private Function AnalogClock.ImageUpdate(ByVal pAlpha As UByte = 255) As GpImage Ptr
	mUpdateBitmap.Initial(mWidth, mHeight)
	mUpdateBitmap.DrawScaleImage(mBackBitmap.Image)
	
	Dim sImg As gdipImage
	If mText Then 
		sImg.Image = AnalogClockText(mWidth, mHeight, *mFontName, mFontBold, mFontColor, pAlpha)
		mUpdateBitmap.DrawScaleImage(sImg.Image)
	End If
	If mHand Then 
		sImg.Image = AnalogClockHand(mWidth, mWidth, pAlpha)
		mUpdateBitmap.DrawScaleImage(sImg.Image)
	End If
	
	Return mUpdateBitmap.Image
End Function
