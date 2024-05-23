' gdipMonth
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "gdipMonth.bi"

Destructor gdipMonth
	If mFontName Then Deallocate mFontName
	'Erase mClr
End Destructor

Constructor gdipMonth
	WLet(mFontName, "微软雅黑")
End Constructor

Private Function gdipMonth.DataExpire(pWidth As Single, pHeight As Single, pSelectDate As Double) As Boolean
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
	
	If mByHeight Then
		If mShowControls Then
			mFontSize = mHeight / 19
		Else
			mFontSize = mHeight / 16
		End If
	Else
		If mShowWeeks Then
			mFontSize = mWidth / 26
		Else
			mFontSize = mWidth / 23
		End If
	End If
	mOffsetY = mFontSize * 0.1
	
	'当月第一天
	mDayStart = DateSerial(sYear, sMonth, 1)
	'当月天数
	mDayCount = DateDiff("d", mDayStart, DateAdd("m", 1, mDayStart))
	'当月第一天星期几 (星期日为每周第一天)
	mWeekStart = Weekday(mDayStart) - 2
	'行数
	mLineCount = (mWeekStart + mDayCount) \ 7 + 2
	'格子宽
	mCellWidth = mWidth / IIf(mShowWeeks, 8, 7)
	If mShowWeeks Then
		mWeeksWidth = mCellWidth
	Else
		mWeeksWidth = 0
	End If
	'格子高
	mCellHeight = mHeight / (mLineCount + IIf(mShowControls, 1, 0))
	mControlHeight = IIf(mShowControls, mCellHeight, 0)
	Return True
End Function

Private Sub gdipMonth.Background(pWidth As Single, pHeight As Single, pSelectDate As Double)
	If DataExpire(pWidth, pHeight, pSelectDate) = False Then Exit Sub
	
	'文字
	Dim sTxt As String
	'文字颜色
	Dim sClr As ULong
	Dim sBrush As Any Ptr
	Dim i As Integer
	
	Static sTmpBitmap As gdipBitmap
	Dim sGdipTxt As gdipText
	
	mBackBitmap.Initial(mWidth, mHeight)
	sGdipTxt.Initial(mWidth, mHeight)
	sGdipTxt.SetFont(*mFontName, mFontSize, FontStyleBold)
	
	
	If mTrayEnabled Then
		sTmpBitmap.Initial(mWidth, mHeight)
		'控制区域
		If mShowControls Then
			GdipCreateSolidFill(mBackAlpha(MonthControl) + mBackColor(MonthControl), @sBrush)
			GdipFillRectangle(sTmpBitmap.Graphics, sBrush, 0, 0, mWidth, mCellHeight)
			GdipDeleteBrush(sBrush)
		End If
		'星期区域
		GdipCreateSolidFill(mBackAlpha(MonthWeek) + mBackColor(MonthWeek), @sBrush)
		GdipFillRectangle(sTmpBitmap.Graphics, sBrush, 0, mControlHeight, mWidth, mCellHeight)
		GdipDeleteBrush(sBrush)
		
		'日期区域
		GdipCreateSolidFill(mBackAlpha(MonthDay) + mBackColor(MonthDay), @sBrush)
		GdipFillRectangle(sTmpBitmap.Graphics, sBrush, 0, mCellHeight + mControlHeight, mWidth, mHeight - mCellHeight - mControlHeight)
		GdipDeleteBrush(sBrush)
		mBackBitmap.DrawImage(sTmpBitmap.Image, 0, 0)
	End If
	
	If mPanelEnabled Then
		sTmpBitmap.Initial(mWidth, mHeight)
		GdipGraphicsClear(sTmpBitmap.Graphics, mBackAlpha(MonthPanel) + mBackColor(MonthPanel))
		mBackBitmap.DrawImage(sTmpBitmap.Image, 0, 0)
	End If
	
	sTmpBitmap.Initial(mWidth, mHeight)
	If mShowControls Then
		'绘制控制
		sClr = mForeAlpha(MonthControl) + mForeColor(MonthControl)
		sTxt = Format(mSelectDate, "yyyy/mm/dd")
		sGdipTxt.TextOut(sTmpBitmap.Graphics, sTxt, (mWeeksWidth + mCellWidth * 2 - sGdipTxt.TextWidth(sTxt)) / 2, (mCellHeight - sGdipTxt.TextHeight(sTxt)) / 2, sClr)
		sTxt = "v"
		sGdipTxt.TextOut(sTmpBitmap.Graphics, sTxt, mWeeksWidth + mCellWidth * 2 + (mCellWidth - sGdipTxt.TextWidth(sTxt)) / 2, (mCellHeight - sGdipTxt.TextHeight(sTxt)) / 2, sClr)
		sTxt = "<<"
		sGdipTxt.TextOut(sTmpBitmap.Graphics, sTxt, mWeeksWidth + mCellWidth * 3 + (mCellWidth - sGdipTxt.TextWidth(sTxt)) / 2, (mCellHeight - sGdipTxt.TextHeight(sTxt)) / 2, sClr)
		sTxt = ">>"
		sGdipTxt.TextOut(sTmpBitmap.Graphics, sTxt, mWeeksWidth + mCellWidth * 4 + (mCellWidth - sGdipTxt.TextWidth(sTxt)) / 2, (mCellHeight - sGdipTxt.TextHeight(sTxt)) / 2, sClr)
		sTxt = "<"
		sGdipTxt.TextOut(sTmpBitmap.Graphics, sTxt, mWeeksWidth + mCellWidth * 5 + (mCellWidth - sGdipTxt.TextWidth(sTxt)) / 2, (mCellHeight - sGdipTxt.TextHeight(sTxt)) / 2, sClr)
		sTxt = ">"
		sGdipTxt.TextOut(sTmpBitmap.Graphics, sTxt, mWeeksWidth + mCellWidth * 6 + (mCellWidth - sGdipTxt.TextWidth(sTxt)) / 2, (mCellHeight - sGdipTxt.TextHeight(sTxt)) / 2, sClr)
	End If
	
	If mShowWeeks Then
		'绘制周次文字
		sClr = mForeAlpha(MonthWeek) + mForeColor(MonthWeek)
		sTxt = "周"
		sGdipTxt.TextOut(sTmpBitmap.Graphics, sTxt, (mCellWidth - sGdipTxt.TextWidth(sTxt)) / 2, mControlHeight + (mCellHeight - sGdipTxt.TextHeight(sTxt)) / 2, sClr)
		For i = 1 To mLineCount - 1
			sTxt = "" & DatePart("ww", DateAdd("d", (i - 1) * 7, mDayStart))
			sGdipTxt.TextOut(sTmpBitmap.Graphics, sTxt, (mCellWidth - sGdipTxt.TextWidth(sTxt)) / 2, mControlHeight + (mCellHeight * i) + (mCellHeight - sGdipTxt.TextHeight(sTxt)) / 2, sClr)
		Next
	End If
	
	'绘制日历星期抬头文字
	sClr = mForeAlpha(MonthWeek) + mForeColor(MonthWeek)
	For i = 0 To 6
		sTxt = mCalendar.WeekName(i + 1)
		'sTxt = Format(DateAdd("d", i - mWeekStart - 1, mDayStart), "ddd")
		sGdipTxt.TextOut(sTmpBitmap.Graphics, sTxt, mWeeksWidth + i * mCellWidth + (mCellWidth - sGdipTxt.TextWidth(sTxt)) / 2, mControlHeight + (mCellHeight - sGdipTxt.TextHeight(sTxt)) / 2, sClr)
	Next
	
	mBackBitmap.DrawImage(sTmpBitmap.Image, 0, 0)

	If mBackEnabled Then
		sTmpBitmap.Initial(mWidth, mHeight)
		sTmpBitmap.DrawScaleImage(mBackImage.Image)
		If mBackBlur Then
			FastBoxBlurHV(sTmpBitmap.Image, mBackBlur)
		End If
		mBackBitmap.DrawAlphaImage(sTmpBitmap.Image, mBackAlpha(MonthImageFile) Shr 24)
	End If
	
	mBackBitmap.DrawImage(MonthCalendar(), 0, 0)
	
	If mOutlineEnabled Then
		sTmpBitmap.Initial(mWidth, mHeight)
		Dim sPen As GpPen Ptr
		GdipCreatePen1(mForeAlpha(MonthPanel) + mForeColor(MonthPanel), mOutlineSize, UnitPixel, @sPen)
		GdipDrawRectangle(sTmpBitmap.Graphics, sPen, 0, 0, mWidth, mHeight)
		GdipDeletePen(sPen)
		mBackBitmap.DrawImage(sTmpBitmap.Image, 0, 0)
	End If
End Sub

Private Function gdipMonth.DateCalculate(pType As String, pAdd As Integer) As Double
	Return DateAdd(pType, pAdd, mSelectDate)
End Function

Private Function gdipMonth.MonthCalendar() As GpImage Ptr
	Dim sYear As Integer
	Dim sMonth As Integer
	Dim sDay As Integer
	Dim sBrush As Any Ptr
	Dim sPen As GpPen Ptr
	Dim sX As Integer
	Dim sY As Integer
	'文字
	Dim sTxt As String
	'文字颜色
	Dim sClr As ARGB
	Dim sToday As Double = DateSerial(Year(Now), Month(Now), Day(Now))
	'绘制日期和农历
	Dim sDrawDate As Double
	Dim i As Integer
	
	Static sTmpBitmap As gdipBitmap
	sTmpBitmap.Initial(mWidth, mHeight)
	Dim sGdipTxt As gdipText
	sGdipTxt.Initial(mWidth, mHeight)
	
	For i = 1 To (mLineCount - 1) * 7
		sDrawDate = DateAdd("d", i - mWeekStart - 2, mDayStart)
		sYear = Year(sDrawDate)
		sMonth = Month(sDrawDate)
		sDay = Day(sDrawDate)
		
		sX = (i - 1) Mod 7
		sY = (i - 1) \ 7 + 2
		
		If mSelectDate = sDrawDate Then
			mSelectDateX = sX
			mSelectDateY = sY
			'选中日期区域
			GdipCreateSolidFill(mBackAlpha(MonthSelect) + mBackColor(MonthSelect), @sBrush)
			GdipCreatePen1(mForeAlpha(MonthSelect) + mForeColor(MonthSelect), mBorderSize, UnitPixel, @sPen)
			GdipFillRectangle(sTmpBitmap.Graphics, sBrush, mWeeksWidth + sX * mCellWidth, (sY - 1) * mCellHeight + mControlHeight,  mCellWidth, mCellHeight)
			GdipDrawRectangle(sTmpBitmap.Graphics, sPen, mWeeksWidth + sX * mCellWidth, (sY - 1) * mCellHeight + mControlHeight,  mCellWidth, mCellHeight)
			GdipDeleteBrush(sBrush)
			GdipDeletePen(sPen)
		End If
		
		sTxt = "" & sDay
		If sToday = sDrawDate Then
			'当天
			sClr = mForeAlpha(MonthToday) + mForeColor(MonthToday)
		Else
			If (i > (mWeekStart + 1)) And (i < (mDayCount + mWeekStart + 2)) Then
				'本月
				sClr = mForeAlpha(MonthDay) + mForeColor(MonthDay)
			Else
				'非本月
				sClr = mForeAlpha(MonthOther) + mForeColor(MonthOther)
			End If
		End If
		sGdipTxt.SetFont(*mFontName, mFontSize, FontStyleBold)
		sGdipTxt.TextOut(sTmpBitmap.Graphics, sTxt, mWeeksWidth + sX * mCellWidth + (mCellWidth - sGdipTxt.TextWidth(sTxt)) / 2, mControlHeight + sY * mCellHeight - mCellHeight / 2 - sGdipTxt.TextHeight(sTxt) + mOffsetY, sClr)
		
		mCalendar.Init(sYear, sMonth, sDay)
		
		sTxt = mCalendar.lHoliday & mCalendar.lSolarTerm
		If mCalendar.lDayName(mCalendar.lDay) = "初一" Then
			sTxt = IIf(mCalendar.IsLeap, "闰", "") & mCalendar.lMonthName(mCalendar.lMonth) & IIf(sTxt = "", "", "("  & sTxt & ")")
		End If
		If sTxt = "" Then
			sTxt = mCalendar.lDayName(mCalendar.lDay)
		Else
			If (i > (mWeekStart + 1)) And (i < (mDayCount + mWeekStart + 2)) Then
				'本月
				sClr = mForeAlpha(MonthHoliday) Or mForeColor(MonthHoliday)
			Else
				'非本月
				sClr = mForeAlpha(MonthOther) Or mForeColor(MonthHoliday)
			End If
		End If
		sGdipTxt.SetFont(*mFontName, mFontSize* 0.8, FontStyleRegular)
		sGdipTxt.TextOut(sTmpBitmap.Graphics, sTxt, mWeeksWidth + sX * mCellWidth + (mCellWidth - sGdipTxt.TextWidth(sTxt)) / 2, mControlHeight + sY * mCellHeight - mCellHeight / 2 - mOffsetY, sClr)
	Next
	
	Return sTmpBitmap.Image
End Function

Private Function gdipMonth.ImageUpdate(pSelectDate As Double) As GpImage Ptr
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
	Dim sCelY As Integer
	
	'鼠标位置
	If mMouseX > 0 And mMouseY > 0 And mMouseX < mWidth And mMouseY < mHeight Then
		sCelX = mMouseX \ mCellWidth
		sCelY = mMouseY \ mCellHeight
		
		If mShowControls Then
			Select Case sCelY
			Case 0 'control
				sTop = 0
				sHeight = mCellHeight
				Select Case sCelX - IIf(mShowWeeks, 1, 0)
				Case 6 'month inc
					sLeft = sCelX * mCellWidth
					sWidth = mCellWidth
					mMouseLocate = 8
				Case 5 'month dec
					sLeft = sCelX * mCellWidth
					sWidth = mCellWidth
					mMouseLocate = 7
				Case 4 'year inc
					sLeft = sCelX * mCellWidth
					sWidth = mCellWidth
					mMouseLocate = 6
				Case 3 'yeay dec
					sLeft = sCelX * mCellWidth
					sWidth = mCellWidth
					mMouseLocate = 5
				Case 2 'hide control
					sLeft = sCelX * mCellWidth
					sWidth = mCellWidth
					mMouseLocate = 3
				Case Else 'today
					sLeft = 0
					sWidth = mCellWidth * 2 + mWeeksWidth
					mMouseLocate = 4
				End Select
			Case 1 'week
				sLeft = 0
				sTop = mCellHeight
				sWidth = mWidth
				sHeight = mCellHeight
				mMouseLocate = 1
			Case Else
				sLeft = sCelX * mCellWidth
				sWidth = mCellWidth
				If CBool(sCelX = 0) And mShowWeeks Then 'weeks
					sTop = 2*mCellHeight
					sHeight = (mLineCount - 1) * mCellHeight
					mMouseLocate = 2
				Else 'days
					sTop = sCelY * mCellHeight
					sHeight = mCellHeight
					mMouseLocate = 0
				End If
			End Select
		Else
			Select Case sCelY
			Case 0 'weekname
				sLeft = 0
				sTop = 0
				sWidth = mWidth
				sHeight = mCellHeight
				mMouseLocate = 1
			Case Else
				sLeft = sCelX * mCellWidth
				sWidth = mCellWidth
				If CBool(sCelX = 0) And mShowWeeks Then 'weeks
					sTop = mCellHeight
					sHeight = mLineCount * mCellHeight
					mMouseLocate = 2
				Else 'days
					sTop = sCelY * mCellHeight
					sHeight = mCellHeight
					mMouseLocate = 0
				End If
			End Select
		End If
		
		'显示鼠标高亮填充
		GdipCreateSolidFill(mBackAlpha(MonthFocus) + mBackColor(MonthFocus), @sBrush)
		GdipFillRectangle(mUpdateBitmap.Graphics, sBrush, sLeft, sTop, sWidth, sHeight)
		GdipDeleteBrush(sBrush)
		'显示鼠标高亮描边
		GdipCreatePen1(mForeAlpha(MonthFocus) + mForeColor(MonthFocus), mBorderSize, UnitPixel, @sPen)
		GdipDrawRectangle(mUpdateBitmap.Graphics, sPen, sLeft, sTop, sWidth, sHeight)
		GdipDeletePen(sPen)
	End If
	Return mUpdateBitmap.Image
End Function

Private Function gdipMonth.XY2Date(x As Integer, y As Integer) As Double
	If CBool(y < (mCellHeight + mControlHeight)) Or CBool((x - mWeeksWidth) < 0) Then Return Now()
	Return DateAdd("d", (y \ mCellHeight - (IIf(mShowControls, 1, 0))) * 7 + ((x - mWeeksWidth) \ mCellWidth) - mWeekStart - 8, mDayStart)
End Function
