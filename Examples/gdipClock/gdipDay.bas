' gdipDay
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "gdipDay.bi"

Destructor gdipDay
	If mFontName Then Deallocate mFontName
End Destructor

Constructor gdipDay
	WLet(mFontName, "微软雅黑")
	'调颜色
	mClr(0) = RGBA(mC(8), mC(8), mC(8), 0) 'backcolor_mouse
	mClr(1) = RGBA(mC(8), mC(8), mC(8), 0) 'forecolor_mouse
	mClr(2) = RGBA(mC(6), mC(2), mC(4), 0) 'backcolor_year
	mClr(3) = RGBA(mC(8), mC(8), mC(8), 0) 'forecolor_year
	mClr(4) = RGBA(mC(8), mC(6), mC(7), 0) 'backcolor_month
	mClr(5) = RGBA(mC(0), mC(0), mC(0), 0) 'forecolor_month
	mClr(6) = RGBA(mC(8), mC(8), mC(8), 0) 'backcolor_day
	mClr(7) = RGBA(mC(0), mC(0), mC(0), 0) 'forecolor_day
	mClr(8) = RGBA(mC(8), mC(6), mC(7), 0) 'backcolor_week
	mClr(9) = RGBA(mC(0), mC(0), mC(0), 0) 'forecolor_week
End Constructor

Private Sub gdipDay.Background(pWidth As Single, pHeight As Single, pSelectDate As Double)
	If DataExpire(pWidth, pHeight, pSelectDate) = False Then Exit Sub
	
	mTxt.Initial(mWidth, mHeight)
	
	mTrayBitmap.Initial(mWidth, mHeight)
	If mTrayEnabled Then
		Dim sBrush As Any Ptr
		
		'年区域
		GdipCreateSolidFill((mTrayAlpha Shl 24) Or mClr(2), @sBrush)
		GdipFillRectangle(mTrayBitmap.Graphics, sBrush, 0, 0, mWidth, mH(0))
		GdipDeleteBrush(sBrush)
		
		'月区域
		GdipCreateSolidFill((mTrayAlpha Shl 24) Or mClr(4), @sBrush)
		GdipFillRectangle(mTrayBitmap.Graphics, sBrush, 0, mH(0), mWidth, mH(1))
		GdipDeleteBrush(sBrush)
		
		'日区域
		GdipCreateSolidFill((mTrayAlpha Shl 24) Or mClr(6), @sBrush)
		GdipFillRectangle(mTrayBitmap.Graphics, sBrush, 0, mOH(2), mWidth, mH(2))
		GdipDeleteBrush(sBrush)
		
		'周节日区域
		GdipCreateSolidFill((mTrayAlpha Shl 24) Or mClr(8), @sBrush)
		GdipFillRectangle(mTrayBitmap.Graphics, sBrush, 0, mHeight - mH(1), mWidth, mH(1))
		GdipDeleteBrush(sBrush)
		
		'外框线
		Dim sPen As GpPen Ptr
		GdipCreatePen1((mTrayAlpha Shl 24) Or mClr(2), mBorderSize, UnitPixel, @sPen)
		If mShowStyle = 0 Then
			'日期公历农历区域线
			GdipDrawLine(mTrayBitmap.Graphics, sPen, mOffsetX, 0, mOffsetX, mHeight)
		End If
		GdipDrawRectangle(mTrayBitmap.Graphics, sPen, 0, 0, mWidth, mHeight)
		GdipDeletePen(sPen)
	End If
	
	If mBackEnabled Then
		mBackBitmap.Initial(mWidth, mHeight)
		Dim tmpBitmap As gdipBitmap
		tmpBitmap.Initial(mWidth, mHeight)
		tmpBitmap.DrawScaleImage(mBackImage.Image)
		If mBackBlur Then
			FastBoxBlurHV(tmpBitmap.Image, mBackBlur)
		End If
		mBackBitmap.DrawAlphaImage(tmpBitmap.Image, mBackAlpha)
	End If
	
	DayCalendar()
End Sub

Private Function gdipDay.DataExpire(pWidth As Single, pHeight As Single, pSelectDate As Double) As Boolean
	Dim sYear As Integer = Year(pSelectDate)
	Dim sMonth As Integer = Month(pSelectDate)
	Dim sDay As Integer = Day(pSelectDate)
	Dim sDate As Double = DateSerial(sYear, sMonth, sDay)
	
	If (mForceUpdate = False) And CBool(mWidth = pWidth) And CBool(mHeight = pHeight) And CBool(mSelectDate = sDate) Then Return False
	If mWidth <> pWidth Then mByHeight = False
	If mHeight <> pHeight Then mByHeight = True
	
	mSelectDate = sDate
	mWidth = pWidth
	mHeight = pHeight
	mForceUpdate = False
	mOffsetX = IIf(mShowStyle = 0, mWidth * mSplitXScale, mWidth)
	
	If mByHeight Then
		mFontSize = mHeight / 3
	Else
		mFontSize = mWidth / 4.5
	End If
	mTxt.SetFont(*mFontName, mFontSize, FontStyleBold)
	
	'文字
	mH(2) = mTxt.TextHeight("0")
	mH(0) = mH(2) * 0.4 '年
	mH(1) = mH(2) * 0.3 '月
	mH(3) = mH(1)       '星期
	mH(2) = mHeight - mH(0) - mH(1) - mH(3)  '日
	
	mOH(0) = 0
	mOH(1) = mH(0)
	mOH(2) = mOH(1) + mH(1)
	mOH(3) = mOH(2) + mH(2)
	
	mW(0) = mWidth
	
	Return True
End Function

Private Sub gdipDay.DayCalendar()
	mCalendar.Init(Year(mSelectDate), Month(mSelectDate), Day(mSelectDate))
	
	mDayBitmap.Initial(mWidth, mHeight)
	If mForceUpdate Then
		Background(mWidth, mHeight, mSelectDate)
		mForceUpdate = False
	End If
	
	
	'文字
	Dim sTxt As String
	
	Select Case mShowStyle
	Case 0 '公历+农历
		
		'年
		mTxt.SetFont(*mFontName, mFontSize / 2.5, FontStyleBold)
		'公历年
		sTxt = Format(mSelectDate, "yyyy")
		mTxt.TextOut(mDayBitmap.Graphics, sTxt, (mOffsetX - mTxt.TextWidth(sTxt)) / 2, (mH(0) - mTxt.TextHeight(sTxt)) / 2, (mForeOpacity Shl 24) Or mClr(3))
		'农历年
		sTxt = mCalendar.GanZhi(mCalendar.lYear) & "." & mCalendar.YearAttribute(mCalendar.lYear)
		mTxt.TextOut(mDayBitmap.Graphics, sTxt, mOffsetX + (mWidth - mOffsetX - mTxt.TextWidth(sTxt)) / 2, (mH(0) - mTxt.TextHeight(sTxt)) / 2, (mForeOpacity Shl 24) Or mClr(3))
		
		'月
		mTxt.SetFont(*mFontName, mFontSize / 2.5, FontStyleRegular)
		'公历月
		sTxt = mCalendar.sMonthName(Month(mSelectDate))
		mTxt.TextOut(mDayBitmap.Graphics, sTxt, (mOffsetX - mTxt.TextWidth(sTxt)) / 2, mOH(1) + (mH(1) - mTxt.TextHeight(sTxt)) / 2, (mForeOpacity Shl 24) Or mClr(5))
		'农历月
		sTxt = IIf(mCalendar.IsLeap, "闰", "") & mCalendar.lMonthName(mCalendar.lMonth)
		mTxt.TextOut(mDayBitmap.Graphics, sTxt, mOffsetX + (mWidth - mOffsetX - mTxt.TextWidth(sTxt)) / 2, mOH(1) + (mH(1) - mTxt.TextHeight(sTxt)) / 2, (mForeOpacity Shl 24) Or mClr(5))
		
		'日
		'公历日
		sTxt = Format(mSelectDate, "d")
		mTxt.SetFont(*mFontName, mFontSize* 1.2, FontStyleBold)
		mTxt.TextOut(mDayBitmap.Graphics, sTxt, (mOffsetX - mTxt.TextWidth(sTxt)) / 2, mOH(2) + (mH(2) - mTxt.TextHeight(sTxt)) / 2 + mFontSize / 15, (mForeOpacity Shl 24) Or mClr(7))
		'农历日
		sTxt = mCalendar.lDayName(mCalendar.lDay)
		mTxt.SetFont(*mFontName, mFontSize, FontStyleBold)
		mTxt.TextOut(mDayBitmap.Graphics, sTxt, mOffsetX + (mWidth - mOffsetX - mTxt.TextWidth(sTxt)) / 2, mOH(2) + (mH(2) - mTxt.TextHeight(sTxt)) / 2, (mForeOpacity Shl 24) Or mClr(7))
		
		'星期
		mTxt.SetFont(*mFontName, mFontSize / 3.5, FontStyleRegular)
		'公历节日
		sTxt = mCalendar.sHoliday & mCalendar.wHoliday
		If sTxt = "" Then sTxt = mCalendar.WeekNameFull(Weekday(mSelectDate))
		mTxt.TextOut(mDayBitmap.Graphics, sTxt, (mOffsetX - mTxt.TextWidth(sTxt)) / 2, mOH(3) + (mH(3) - mTxt.TextHeight(sTxt)) / 2, (mForeOpacity Shl 24) Or mClr(9))
		'农历节日
		sTxt = mCalendar.lSolarTerm & mCalendar.lHoliday
		If sTxt = "" Then sTxt = "第 " & DatePart("ww", mSelectDate) & " 周"
		mTxt.TextOut(mDayBitmap.Graphics, sTxt, mOffsetX + (mWidth - mOffsetX - mTxt.TextWidth(sTxt)) / 2, mOH(3) + (mH(3) - mTxt.TextHeight(sTxt)) / 2, (mForeOpacity Shl 24) Or mClr(9))
		
		
	Case 1 '公历
		'年
		mTxt.SetFont(*mFontName, mFontSize / 2.5, FontStyleBold)
		'公历年
		sTxt = Format(mSelectDate, "yyyy")
		mTxt.TextOut(mDayBitmap.Graphics, sTxt, (mOffsetX - mTxt.TextWidth(sTxt)) / 2, (mH(0) - mTxt.TextHeight(sTxt)) / 2, (mForeOpacity Shl 24) Or mClr(3))
		
		'月
		mTxt.SetFont(*mFontName, mFontSize / 3.5, FontStyleRegular)
		'公历月
		sTxt = mCalendar.sMonthName(Month(mSelectDate))
		mTxt.TextOut(mDayBitmap.Graphics, sTxt, (mOffsetX - mTxt.TextWidth(sTxt)) / 2, mOH(1) + (mH(1) - mTxt.TextHeight(sTxt)) / 2, (mForeOpacity Shl 24) Or mClr(5))
		
		'日
		'公历日
		sTxt = Format(mSelectDate, "d")
		mTxt.SetFont(*mFontName, mFontSize* 1.2, FontStyleBold)
		mTxt.TextOut(mDayBitmap.Graphics, sTxt, (mOffsetX - mTxt.TextWidth(sTxt)) / 2, mOH(2) + (mH(2) - mTxt.TextHeight(sTxt)) / 2 + mFontSize / 15, (mForeOpacity Shl 24) Or mClr(7))
		
		'星期
		mTxt.SetFont(*mFontName, mFontSize / 3.5, FontStyleRegular)
		'公历节日
		sTxt = mCalendar.sHoliday & mCalendar.wHoliday
		If sTxt = "" Then sTxt = mCalendar.WeekNameFull(Weekday(mSelectDate))
		mTxt.TextOut(mDayBitmap.Graphics, sTxt, (mOffsetX - mTxt.TextWidth(sTxt)) / 2, mOH(3) + (mH(3) - mTxt.TextHeight(sTxt)) / 2, (mForeOpacity Shl 24) Or mClr(9))
	Case 2 '农历
		'年
		mTxt.SetFont(*mFontName, mFontSize / 2.5, FontStyleBold)
		'农历年
		sTxt = mCalendar.GanZhi(mCalendar.lYear) & "." & mCalendar.YearAttribute(mCalendar.lYear)
		mTxt.TextOut(mDayBitmap.Graphics, sTxt, (mOffsetX - mTxt.TextWidth(sTxt)) / 2, (mH(0) - mTxt.TextHeight(sTxt)) / 2, (mForeOpacity Shl 24) Or mClr(3))
		
		'月
		mTxt.SetFont(*mFontName, mFontSize / 3.5, FontStyleRegular)
		'农历月
		sTxt = IIf(mCalendar.IsLeap, "闰", "") & mCalendar.lMonthName(mCalendar.lMonth) & "月"
		mTxt.TextOut(mDayBitmap.Graphics, sTxt, (mOffsetX - mTxt.TextWidth(sTxt)) / 2, mOH(1) + (mH(1) - mTxt.TextHeight(sTxt)) / 2, (mForeOpacity Shl 24) Or mClr(5))
		
		'日
		'农历日
		sTxt = mCalendar.lDayName(mCalendar.lDay)
		mTxt.SetFont(*mFontName, mFontSize, FontStyleBold)
		mTxt.TextOut(mDayBitmap.Graphics, sTxt, (mOffsetX - mTxt.TextWidth(sTxt)) / 2, mOH(2) + (mH(2) - mTxt.TextHeight(sTxt)) / 2, (mForeOpacity Shl 24) Or mClr(7))
		
		'星期
		mTxt.SetFont(*mFontName, mFontSize / 3.5, FontStyleRegular)
		'农历节日
		sTxt = mCalendar.lSolarTerm & mCalendar.lHoliday
		If sTxt = "" Then sTxt = "第 " & DatePart("ww", mSelectDate) & " 周"
		mTxt.TextOut(mDayBitmap.Graphics, sTxt, (mOffsetX - mTxt.TextWidth(sTxt)) / 2, mOH(3) + (mH(3) - mTxt.TextHeight(sTxt)) / 2, (mForeOpacity Shl 24) Or mClr(9))
	End Select
End Sub

Private Function gdipDay.ImageUpdate(pSelectDate As Double) As GpImage Ptr
	'CalculateSize()
	
	Dim sBrush As Any Ptr
	Dim sPen As GpPen Ptr
	
	Background(mWidth, mHeight, pSelectDate)
	
	mUpdateBitmap.Initial(mWidth, mHeight)
	If mTrayEnabled Then mUpdateBitmap.DrawImage(mTrayBitmap.Image, 0, 0)
	If mBackEnabled Then mUpdateBitmap.DrawImage(mBackBitmap.Image, 0, 0)
	mUpdateBitmap.DrawImage(mDayBitmap.Image, 0, 0)
	
	Dim sLeft As Single
	Dim sTop As Single
	Dim sWidth As Single
	Dim sHeight As Single
	
	Dim sCelX As Integer
	Dim sCelY As Integer = -1
	
	'鼠标位置
	If mMouseX > 0 And mMouseY > 0 And mMouseX < mWidth And mMouseY < mHeight Then
		Dim i As Integer
		For i = 0 To 3
			If CBool(mMouseY > mOH(i)) And CBool(mMouseY < (mOH(i) + mH(i))) Then
				sCelY = i
				Exit For
			End If
		Next
		If sCelY>-1 Then
			sTop = mOH(sCelY)
			sHeight = mH(sCelY)
		End If
		
		Select Case mShowStyle
		Case 0
			If mMouseX > mOffsetX Then
				sCelX = 1
				sLeft = mOffsetX
				sWidth = mWidth - mOffsetX
				mMouseLocate = sCelY + 4
			Else
				sCelX = 0
				sLeft = 0
				sWidth = mOffsetX
				mMouseLocate = sCelY
			End If
		Case 1
			sCelX = 0
			sLeft = 0
			sWidth = mWidth
			mMouseLocate = sCelY
		Case Else
			sCelX = 0
			sLeft = 0
			sWidth = mWidth
			mMouseLocate = sCelY + 4
		End Select
		
		'显示鼠标高亮填充
		GdipCreateSolidFill((mMouseOpacity Shl 24) Or mClr(1), @sBrush)
		GdipFillRectangle(mUpdateBitmap.Graphics, sBrush, sLeft, sTop, sWidth, sHeight)
		GdipDeleteBrush(sBrush)
		'显示鼠标高亮描边
		GdipCreatePen1((mMouseOpacity Shl 24) Or mClr(0), mBorderSize, UnitPixel, @sPen)
		GdipDrawRectangle(mUpdateBitmap.Graphics, sPen, sLeft, sTop, sWidth, sHeight)
		GdipDeletePen(sPen)
	End If
	
	Return mUpdateBitmap.Image
End Function

