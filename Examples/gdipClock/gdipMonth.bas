' gdipMonth
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "gdipMonth.bi"

Destructor gdipMonth
	If mFontName Then Deallocate mFontName
	Erase mClr
End Destructor

Constructor gdipMonth
	WLet(mFontName, "微软雅黑")
	'调颜色
	ReDim mClr(10)
	mClr(0) = RGBA(mC(8), mC(8), mC(8), 0) 'backcolor_focus
	mClr(1) = RGBA(mC(8), mC(8), mC(8), 0) 'forecolor_focus
	mClr(2) = RGBA(mC(6), mC(2), mC(4), 0) 'backcolor_control
	mClr(3) = RGBA(mC(8), mC(8), mC(8), 0) 'forecolor_control
	mClr(4) = RGBA(mC(8), mC(6), mC(7), 0) 'backcolor_weeks
	mClr(5) = RGBA(mC(0), mC(0), mC(0), 0) 'forecolor_weeks
	mClr(6) = RGBA(mC(8), mC(8), mC(8), 0) 'backcolor_day
	mClr(7) = RGBA(mC(0), mC(0), mC(0), 0) 'forecolor_day
	mClr(8) = RGBA(mC(6), mC(2), mC(4), 0) 'forecolor_select
	mClr(9) = RGBA(mC(0), mC(0), mC(8), 0) 'forecolor_today
	mClr(10) = RGBA(mC(8), mC(0), mC(0), 0) 'forecolor_holiday
End Constructor

Private Function gdipMonth.DataExpire(pWidth As Single, pHeight As Single, pSelectDate As Double) As Boolean
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
	
	mTxt.Initial(mWidth, mHeight)
	mTxt.SetFont(*mFontName, mFontSize, FontStyleBold)
	
	mTextBitmap.Initial(mWidth, mHeight)
	'绘制控制
	If mShowControls Then
		sClr = (mForeOpacity Shl 24) Or mClr(3)
		sTxt = Format(mSelectDate, "yyyy/mm/dd")
		mTxt.TextOut(mTextBitmap.Graphics, sTxt, (mWeeksWidth + mCellWidth * 2 - mTxt.TextWidth(sTxt)) / 2, (mCellHeight - mTxt.TextHeight(sTxt)) / 2, sClr)
		sTxt = "v"
		mTxt.TextOut(mTextBitmap.Graphics, sTxt, mWeeksWidth + mCellWidth * 2 + (mCellWidth - mTxt.TextWidth(sTxt)) / 2, (mCellHeight - mTxt.TextHeight(sTxt)) / 2, sClr)
		sTxt = "<<"
		mTxt.TextOut(mTextBitmap.Graphics, sTxt, mWeeksWidth + mCellWidth * 3 + (mCellWidth - mTxt.TextWidth(sTxt)) / 2, (mCellHeight - mTxt.TextHeight(sTxt)) / 2, sClr)
		sTxt = ">>"
		mTxt.TextOut(mTextBitmap.Graphics, sTxt, mWeeksWidth + mCellWidth * 4 + (mCellWidth - mTxt.TextWidth(sTxt)) / 2, (mCellHeight - mTxt.TextHeight(sTxt)) / 2, sClr)
		sTxt = "<"
		mTxt.TextOut(mTextBitmap.Graphics, sTxt, mWeeksWidth + mCellWidth * 5 + (mCellWidth - mTxt.TextWidth(sTxt)) / 2, (mCellHeight - mTxt.TextHeight(sTxt)) / 2, sClr)
		sTxt = ">"
		mTxt.TextOut(mTextBitmap.Graphics, sTxt, mWeeksWidth + mCellWidth * 6 + (mCellWidth - mTxt.TextWidth(sTxt)) / 2, (mCellHeight - mTxt.TextHeight(sTxt)) / 2, sClr)
	End If
	
	'绘制日历星期抬头
	sClr = (mForeOpacity Shl 24) Or mClr(5)
	For i = 0 To 6
		sTxt = mCalendar.WeekName(i + 1)
		mTxt.TextOut(mTextBitmap.Graphics, sTxt, mWeeksWidth + i * mCellWidth + (mCellWidth - mTxt.TextWidth(sTxt)) / 2, mControlHeight + (mCellHeight - mTxt.TextHeight(sTxt)) / 2, sClr)
	Next
	
	If mShowWeeks Then
		'绘制周次
		sTxt = "周次"
		mTxt.TextOut(mTextBitmap.Graphics, sTxt, (mCellWidth - mTxt.TextWidth(sTxt)) / 2, mControlHeight + (mCellHeight - mTxt.TextHeight(sTxt)) / 2, sClr)
		
		sClr = (mForeOpacity Shl 24) Or mClr(7)
		For i = 1 To mLineCount - 1
			sTxt = "" & DatePart("ww", DateAdd("d", (i - 1) * 7, mDayStart))
			mTxt.TextOut(mTextBitmap.Graphics, sTxt, (mCellWidth - mTxt.TextWidth(sTxt)) / 2, mControlHeight + (mCellHeight * i) + (mCellHeight - mTxt.TextHeight(sTxt)) / 2, sClr)
		Next
	End If
	
	If mTrayEnabled Then
		mTrayBitmap.Initial(mWidth, mHeight)
		
		'绘制控制
		If mShowControls Then
			GdipCreateSolidFill((mTrayAlpha Shl 24) Or mClr(2), @sBrush)
			GdipFillRectangle(mTrayBitmap.Graphics, sBrush, 0, 0, mWidth, mCellHeight)
			GdipDeleteBrush(sBrush)
		End If
		
		'星期区域
		GdipCreateSolidFill((mTrayAlpha Shl 24) Or mClr(4), @sBrush)
		GdipFillRectangle(mTrayBitmap.Graphics, sBrush, 0, mControlHeight, mWidth, mCellHeight)
		GdipDeleteBrush(sBrush)
		
		'日期区域
		GdipCreateSolidFill((mTrayAlpha Shl 24) Or mClr(6), @sBrush)
		GdipFillRectangle(mTrayBitmap.Graphics, sBrush, 0, mCellHeight + mControlHeight, mWidth, mHeight - mCellHeight - mControlHeight)
		GdipDeleteBrush(sBrush)
		
		'外框线
		Dim sPen As GpPen Ptr
		GdipCreatePen1((mTrayAlpha Shl 24) Or mClr(2), mBorderSize, UnitPixel, @sPen)
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
	
	MonthCalendar()
End Sub

Private Function gdipMonth.DateCalculate(pType As String, pAdd As Integer) As Double
	Return DateAdd(pType, pAdd, mSelectDate)
End Function

Private Sub gdipMonth.MonthCalendar()
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
	
	mMonthBitmap.Initial(mWidth, mHeight)
	
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
			GdipCreateSolidFill((mSelectOpacity Shl 24) Or mClr(4), @sBrush)
			GdipCreatePen1((mSelectOpacity Shl 24) Or mClr(8), mBorderSize, UnitPixel, @sPen)
			GdipFillRectangle(mMonthBitmap.Graphics, sBrush, mWeeksWidth + sX * mCellWidth, (sY - 1) * mCellHeight + mControlHeight,  mCellWidth, mCellHeight)
			GdipDrawRectangle(mMonthBitmap.Graphics, sPen, mWeeksWidth + sX * mCellWidth, (sY - 1) * mCellHeight + mControlHeight,  mCellWidth, mCellHeight)
			GdipDeleteBrush(sBrush)
			GdipDeletePen(sPen)
		End If
		
		sTxt = "" & sDay
		If sToday = sDrawDate Then
			'当天
			sClr = (mForeOpacity Shl 24) Or mClr(9)
		Else
			If (i > (mWeekStart + 1)) And (i < (mDayCount + mWeekStart + 2)) Then
				'本月
				sClr = (mForeOpacity Shl 24) Or mClr(7)
			Else
				'非本月
				sClr = (mDisableOpacity Shl 24) Or mClr(7)
			End If
		End If
		mTxt.SetFont(*mFontName, mFontSize, FontStyleBold)
		mTxt.TextOut(mMonthBitmap.Graphics, sTxt, mWeeksWidth + sX * mCellWidth + (mCellWidth - mTxt.TextWidth(sTxt)) / 2, mControlHeight + sY * mCellHeight - mCellHeight / 2 - mTxt.TextHeight(sTxt) + mOffsetY, sClr)
		
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
				sClr = (mForeOpacity Shl 24) Or mClr(10)
			Else
				'非本月
				sClr = (mDisableOpacity Shl 24) Or mClr(10)
			End If
		End If
		mTxt.SetFont(*mFontName, mFontSize* 0.8, FontStyleRegular)
		mTxt.TextOut(mMonthBitmap.Graphics, sTxt, mWeeksWidth + sX * mCellWidth + (mCellWidth - mTxt.TextWidth(sTxt)) / 2, mControlHeight + sY * mCellHeight - mCellHeight / 2 - mOffsetY, sClr)
	Next
End Sub

Private Function gdipMonth.ImageUpdate(pSelectDate As Double) As GpImage Ptr
	Dim sBrush As Any Ptr
	Dim sPen As GpPen Ptr
	
	Background(mWidth, mHeight, pSelectDate)
	
	mUpdateBitmap.Initial(mWidth, mHeight)
	If mTrayEnabled Then mUpdateBitmap.DrawImage(mTrayBitmap.Image, 0, 0)
	If mBackEnabled Then mUpdateBitmap.DrawImage(mBackBitmap.Image, 0, 0)
	mUpdateBitmap.DrawImage(mTextBitmap.Image, 0, 0)
	mUpdateBitmap.DrawImage(mMonthBitmap.Image, 0, 0)
	
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

Private Function gdipMonth.XY2Date(x As Integer, y As Integer) As Double
	If y < (mCellHeight + mControlHeight) Or (x - mWeeksWidth) < 0 Then Return Now()
	Return DateAdd("d", (y \ mCellHeight - (IIf(mShowControls, 1, 0))) * 7 + ((x - mWeeksWidth) \ mCellWidth) - mWeekStart - 8, mDayStart)
End Function
