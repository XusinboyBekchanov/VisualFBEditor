' gdipDay
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "gdipDay.bi"

Destructor gdipDay
	If mFontName Then Deallocate mFontName
End Destructor

Constructor gdipDay
	WLet(mFontName, "微软雅黑")
End Constructor

Private Sub gdipDay.Background(pWidth As Single, pHeight As Single, pSelectDate As Double)
	If DataExpire(pWidth, pHeight, pSelectDate) = False Then Exit Sub
	Dim sTmpBitmap As gdipBitmap
	mTxt.Initial(mWidth, mHeight)
	
	mBackBitmap.Initial(mWidth, mHeight)
	
	If mPanelEnabled Then
		sTmpBitmap.Initial(mWidth, mHeight)
		GdipGraphicsClear(sTmpBitmap.Graphics, mBackAlpha(DayPanel) + mBackColor(DayPanel))
		mBackBitmap.DrawImage(sTmpBitmap.Image, 0, 0)
	End If
	
	If mTrayEnabled Then
		sTmpBitmap.Initial(mWidth, mHeight)
		Dim sBrush As Any Ptr
		
		'年区域
		GdipCreateSolidFill(mBackAlpha(DayYear) + mBackColor(DayYear), @sBrush)
		GdipFillRectangle(sTmpBitmap.Graphics, sBrush, 0, 0, mWidth, mH(0))
		GdipDeleteBrush(sBrush)
		
		'月区域
		GdipCreateSolidFill(mBackAlpha(DayMonth) + mBackColor(DayMonth), @sBrush)
		GdipFillRectangle(sTmpBitmap.Graphics, sBrush, 0, mH(0), mWidth, mH(1))
		GdipDeleteBrush(sBrush)
		
		'日区域
		GdipCreateSolidFill(mBackAlpha(DayDay) + mBackColor(DayDay), @sBrush)
		GdipFillRectangle(sTmpBitmap.Graphics, sBrush, 0, mOH(2), mWidth, mH(2))
		GdipDeleteBrush(sBrush)
		
		'周节日区域
		GdipCreateSolidFill(mBackAlpha(DayWeek) + mBackColor(DayWeek), @sBrush)
		GdipFillRectangle(sTmpBitmap.Graphics, sBrush, 0, mHeight - mH(1), mWidth, mH(1))
		GdipDeleteBrush(sBrush)
		
		mBackBitmap.DrawImage(sTmpBitmap.Image, 0, 0)
	End If
	
	If mBackEnabled Then
		sTmpBitmap.Initial(mWidth, mHeight)
		sTmpBitmap.DrawScaleImage(mBackImage.Image)
		If mBackBlur Then
			FastBoxBlurHV(sTmpBitmap.Image, mBackBlur)
		End If
		mBackBitmap.DrawAlphaImage(sTmpBitmap.Image, mBackAlpha(DayImageFile) Shr 24)
	End If
	
	mBackBitmap.DrawImage(DayCalendar(), 0, 0)
	
	If mOutlineEnabled Then
		sTmpBitmap.Initial(mWidth, mHeight)
		Dim sPen As GpPen Ptr
		GdipCreatePen1(mForeAlpha(DayPanel) + mForeColor(DayPanel), mOutlineSize, UnitPixel, @sPen)
		'外框线
		GdipDrawRectangle(sTmpBitmap.Graphics, sPen, 0, 0, mWidth, mHeight)
		If mShowStyle = 0 Then
			'日期公历农历区域线
			GdipDrawLine(sTmpBitmap.Graphics, sPen, mOffsetX, 0, mOffsetX, mHeight)
		End If
		GdipDeletePen(sPen)
		mBackBitmap.DrawImage(sTmpBitmap.Image, 0, 0)
	End If
End Sub

Private Function gdipDay.DataExpire(pWidth As Single, pHeight As Single, pSelectDate As Double) As Boolean
	Dim sYear As Integer = Year(pSelectDate)
	Dim sMonth As Integer = Month(pSelectDate)
	Dim sDay As Integer = Day(pSelectDate)
	Dim sDate As Double = DateSerial(sYear, sMonth, sDay)
	
	If CBool(mForceUpdate = False) And CBool(mWidth = pWidth) And CBool(mHeight = pHeight) And CBool(mSelectDate = sDate) Then Return False
	If mWidth <> pWidth Then mByHeight = False
	If mHeight <> pHeight Then mByHeight = True
	
	mSelectDate = sDate
	mWidth = pWidth
	mHeight = pHeight
	mForceUpdate = False
	mOffsetX = IIf(mShowStyle = 0, mWidth * mSplitXScale, mWidth)
	
	If mByHeight Then
		mFontSize = mHeight / 3.2
	Else
		mFontSize = mWidth / 4.7
	End If
	mTxt.SetFont(*mFontName, mFontSize, FontStyleBold)
	
	'文字
	mH(2) = mTxt.TextHeight("0")
	mH(0) = mH(2) * 0.5 '年
	mH(1) = mH(2) * 0.4 '月
	mH(3) = mH(1)       '星期
	mH(2) = mHeight - mH(0) - mH(1) - mH(3)  '日
	
	mOH(0) = 0
	mOH(1) = mH(0)
	mOH(2) = mOH(1) + mH(1)
	mOH(3) = mOH(2) + mH(2)
	
	mW(0) = mWidth
	
	Return True
End Function

Private Function gdipDay.DayCalendar() As GpImage Ptr
	Static sTmpBitmap As gdipBitmap
	mCalendar.Init(Year(mSelectDate), Month(mSelectDate), Day(mSelectDate))
	
	sTmpBitmap.Initial(mWidth, mHeight)
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
		mTxt.TextOut(sTmpBitmap.Graphics, sTxt, (mOffsetX - mTxt.TextWidth(sTxt)) / 2, (mH(0) - mTxt.TextHeight(sTxt)) / 2, mForeAlpha(DayYear) + mForeColor(DayYear))
		'农历年
		sTxt = mCalendar.GanZhi(mCalendar.lYear) & "." & mCalendar.YearAttribute(mCalendar.lYear)
		mTxt.TextOut(sTmpBitmap.Graphics, sTxt, mOffsetX + (mWidth - mOffsetX - mTxt.TextWidth(sTxt)) / 2, (mH(0) - mTxt.TextHeight(sTxt)) / 2, mForeAlpha(DayYear) + mForeColor(DayYear))
		
		'月
		mTxt.SetFont(*mFontName, mFontSize / 2.5, FontStyleRegular)
		'公历月
		'sTxt = mCalendar.sMonthName(Month(mSelectDate))
		sTxt = Format(mSelectDate, "mmm")
		mTxt.TextOut(sTmpBitmap.Graphics, sTxt, (mOffsetX - mTxt.TextWidth(sTxt)) / 2, mOH(1) + (mH(1) - mTxt.TextHeight(sTxt)) / 2, mForeAlpha(DayMonth) + mForeColor(DayMonth))
		'农历月
		sTxt = IIf(mCalendar.IsLeap, "闰", "") & mCalendar.lMonthName(mCalendar.lMonth)
		mTxt.TextOut(sTmpBitmap.Graphics, sTxt, mOffsetX + (mWidth - mOffsetX - mTxt.TextWidth(sTxt)) / 2, mOH(1) + (mH(1) - mTxt.TextHeight(sTxt)) / 2, mForeAlpha(DayMonth) + mForeColor(DayMonth))
		
		'日
		'公历日
		sTxt = Format(mSelectDate, "d")
		mTxt.SetFont(*mFontName, mFontSize* 1.2, FontStyleBold)
		mTxt.TextOut(sTmpBitmap.Graphics, sTxt, (mOffsetX - mTxt.TextWidth(sTxt)) / 2, mOH(2) + (mH(2) - mTxt.TextHeight(sTxt)) / 2 + mFontSize / 15, mForeAlpha(DayDay) + mForeColor(DayDay))
		'农历日
		sTxt = mCalendar.lDayName(mCalendar.lDay)
		mTxt.SetFont(*mFontName, mFontSize, FontStyleBold)
		mTxt.TextOut(sTmpBitmap.Graphics, sTxt, mOffsetX + (mWidth - mOffsetX - mTxt.TextWidth(sTxt)) / 2, mOH(2) + (mH(2) - mTxt.TextHeight(sTxt)) / 2, mForeAlpha(DayDay) + mForeColor(DayDay))
		
		'星期
		mTxt.SetFont(*mFontName, mFontSize / 3.5, FontStyleRegular)
		'公历节日
		sTxt = mCalendar.sHoliday & mCalendar.wHoliday
		'If sTxt = "" Then sTxt = mCalendar.WeekNameFull(Weekday(mSelectDate))
		If sTxt = "" Then sTxt = Format(mSelectDate, "dddd")
		mTxt.TextOut(sTmpBitmap.Graphics, sTxt, (mOffsetX - mTxt.TextWidth(sTxt)) / 2, mOH(3) + (mH(3) - mTxt.TextHeight(sTxt)) / 2, mForeAlpha(DayWeek) + mForeColor(DayWeek))
		'农历节日
		sTxt = mCalendar.lSolarTerm & mCalendar.lHoliday
		If sTxt = "" Then sTxt = "第 " & DatePart("ww", mSelectDate) & " 周"
		mTxt.TextOut(sTmpBitmap.Graphics, sTxt, mOffsetX + (mWidth - mOffsetX - mTxt.TextWidth(sTxt)) / 2, mOH(3) + (mH(3) - mTxt.TextHeight(sTxt)) / 2, mForeAlpha(DayWeek) + mForeColor(DayWeek))
		
		
	Case 1 '公历
		'年
		mTxt.SetFont(*mFontName, mFontSize / 2.5, FontStyleBold)
		'公历年
		sTxt = Format(mSelectDate, "yyyy")
		mTxt.TextOut(sTmpBitmap.Graphics, sTxt, (mOffsetX - mTxt.TextWidth(sTxt)) / 2, (mH(0) - mTxt.TextHeight(sTxt)) / 2, mForeAlpha(DayYear) + mForeColor(DayYear))
		
		'月
		mTxt.SetFont(*mFontName, mFontSize / 3.5, FontStyleRegular)
		'公历月
		'sTxt = mCalendar.sMonthName(Month(mSelectDate))
		sTxt = Format(mSelectDate, "mmm")
		mTxt.TextOut(sTmpBitmap.Graphics, sTxt, (mOffsetX - mTxt.TextWidth(sTxt)) / 2, mOH(1) + (mH(1) - mTxt.TextHeight(sTxt)) / 2, mForeAlpha(DayMonth) + mForeColor(DayMonth))
		
		'日
		'公历日
		sTxt = Format(mSelectDate, "d")
		mTxt.SetFont(*mFontName, mFontSize* 1.2, FontStyleBold)
		mTxt.TextOut(sTmpBitmap.Graphics, sTxt, (mOffsetX - mTxt.TextWidth(sTxt)) / 2, mOH(2) + (mH(2) - mTxt.TextHeight(sTxt)) / 2 + mFontSize / 15, mForeAlpha(DayDay) + mForeColor(DayDay))
		
		'星期
		mTxt.SetFont(*mFontName, mFontSize / 3.5, FontStyleRegular)
		'公历节日
		sTxt = mCalendar.sHoliday & mCalendar.wHoliday
		'If sTxt = "" Then sTxt = mCalendar.WeekNameFull(Weekday(mSelectDate))
		If sTxt = "" Then sTxt = Format(mSelectDate, "dddd")
		mTxt.TextOut(sTmpBitmap.Graphics, sTxt, (mOffsetX - mTxt.TextWidth(sTxt)) / 2, mOH(3) + (mH(3) - mTxt.TextHeight(sTxt)) / 2, mForeAlpha(DayWeek) + mForeColor(DayWeek))
	Case 2 '农历
		'年
		mTxt.SetFont(*mFontName, mFontSize / 2.5, FontStyleBold)
		'农历年
		sTxt = mCalendar.GanZhi(mCalendar.lYear) & "." & mCalendar.YearAttribute(mCalendar.lYear)
		mTxt.TextOut(sTmpBitmap.Graphics, sTxt, (mOffsetX - mTxt.TextWidth(sTxt)) / 2, (mH(0) - mTxt.TextHeight(sTxt)) / 2, mForeAlpha(DayYear) + mForeColor(DayYear))
		
		'月
		mTxt.SetFont(*mFontName, mFontSize / 3.5, FontStyleRegular)
		'农历月
		sTxt = IIf(mCalendar.IsLeap, "闰", "") & mCalendar.lMonthName(mCalendar.lMonth) & "月"
		mTxt.TextOut(sTmpBitmap.Graphics, sTxt, (mOffsetX - mTxt.TextWidth(sTxt)) / 2, mOH(1) + (mH(1) - mTxt.TextHeight(sTxt)) / 2, mForeAlpha(DayMonth) + mForeColor(DayMonth))
		
		'日
		'农历日
		sTxt = mCalendar.lDayName(mCalendar.lDay)
		mTxt.SetFont(*mFontName, mFontSize, FontStyleBold)
		mTxt.TextOut(sTmpBitmap.Graphics, sTxt, (mOffsetX - mTxt.TextWidth(sTxt)) / 2, mOH(2) + (mH(2) - mTxt.TextHeight(sTxt)) / 2, mForeAlpha(DayDay) + mForeColor(DayDay))
		
		'星期
		mTxt.SetFont(*mFontName, mFontSize / 3.5, FontStyleRegular)
		'农历节日
		sTxt = mCalendar.lSolarTerm & mCalendar.lHoliday
		If sTxt = "" Then sTxt = "第 " & DatePart("ww", mSelectDate) & " 周"
		mTxt.TextOut(sTmpBitmap.Graphics, sTxt, (mOffsetX - mTxt.TextWidth(sTxt)) / 2, mOH(3) + (mH(3) - mTxt.TextHeight(sTxt)) / 2, mForeAlpha(DayWeek) + mForeColor(DayWeek))
	End Select
	
	Return sTmpBitmap.Image
End Function

Private Function gdipDay.ImageUpdate(pSelectDate As Double) As GpImage Ptr
	'CalculateSize()
	
	Dim sBrush As Any Ptr
	Dim sPen As GpPen Ptr
	
	Background(mWidth, mHeight, pSelectDate)
	
	mUpdateBitmap.Initial(mWidth, mHeight)
	mUpdateBitmap.DrawImage(mBackBitmap.Image, 0, 0)
	
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
		GdipCreateSolidFill(mBackAlpha(DayFocus) + mBackColor(DayFocus), @sBrush)
		GdipFillRectangle(mUpdateBitmap.Graphics, sBrush, sLeft, sTop, sWidth, sHeight)
		GdipDeleteBrush(sBrush)
		'显示鼠标高亮描边
		GdipCreatePen1(mForeAlpha(DayFocus) + mForeColor(0), mBorderSize, UnitPixel, @sPen)
		GdipDrawRectangle(mUpdateBitmap.Graphics, sPen, sLeft, sTop, sWidth, sHeight)
		GdipDeletePen(sPen)
	End If
	Return mUpdateBitmap.Image
End Function

