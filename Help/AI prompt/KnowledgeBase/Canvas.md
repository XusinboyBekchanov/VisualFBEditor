[TOC]
## Definition
Namespace: [`My.Sys.Drawing`](My.Sys.Drawing.md)

`Canvas` - 

## Properties
|Name|Description|
| :------------ | :------------ |
|[`BackColor`]("Canvas.BackColor.md")||
|[`BackColorOpacity`]("Canvas.BackColorOpacity.md")||
|[`Brush`]("Canvas.Brush.md")||
|[`Clip`]("Canvas.Clip.md")||
|[`CopyMode`]("Canvas.CopyMode.md")||
|[`Ctrl`]("Canvas.Ctrl.md")||
|[`Designer`]("My.Sys.Object.Designer.md")|Returns/sets the object that enables you to access the design characteristics of a object (Windows, Linux, Android, Web).|
|[`DrawColor`]("Canvas.DrawColor.md")||
|[`DrawStyle`]("Canvas.DrawStyle.md")||
|[`DrawWidth`]("Canvas.DrawWidth.md")||
|[`FillColor`]("Canvas.FillColor.md")||
|[`FillGradient`]("Canvas.FillGradient.md")||
|[`FillMode`]("Canvas.FillMode.md")||
|[`FillOpacity`]("Canvas.FillOpacity.md")||
|[`FillStyles`]("Canvas.FillStyles.md")||
|[`Font`]("Canvas.Font.md")||
|[`GdipBrush`]("Canvas.GdipBrush.md")||
|[`GdipFont`]("Canvas.GdipFont.md")||
|[`GdipGraphics`]("Canvas.GdipGraphics.md")||
|[`GdipHatchStyles`]("Canvas.GdipHatchStyles.md")||
|[`GdipPen`]("Canvas.GdipPen.md")||
|[`GdipToken`]("Canvas.GdipToken.md")||
|[`GpLineGradientPara`]("Canvas.GpLineGradientPara.md")||
|[`Handle`]("Canvas.Handle.md")||
|[`HandleSetted`]("Canvas.HandleSetted.md")||
|[`HatchStyle`]("Canvas.HatchStyle.md")||
|[`Height`]("Canvas.Height.md")||
|[`layout`]("Canvas.layout.md")||
|[`Pen`]("Canvas.Pen.md")||
|[`Pixel`]("Canvas.Pixel.md")||
|[`ScaleHeight`]("Canvas.ScaleHeight.md")||
|[`ScaleWidth`]("Canvas.ScaleWidth.md")||
|[`UsingGdip`]("Canvas.UsingGdip.md")||
|[`Width`]("Canvas.Width.md")||
|[`xdpi`]("My.Sys.Object.xdpi.md")|Horizontal DPI scaling factor (Windows, Linux, Android, Web).|
|[`ydpi`]("My.Sys.Object.ydpi.md")|Vertical DPI scaling factor (Windows, Linux, Android, Web).|

## Methods
|Name|Description|
| :------------ | :------------ |
|[`AngleArc`]("Canvas.AngleArc.md")||
|[`Arc`]("Canvas.Arc.md")||
|[`ArcTo`]("Canvas.ArcTo.md")||
|[`Chord`]("Canvas.Chord.md")||
|[`Circle`]("Canvas.Circle.md")||
|[`ClassName`]("My.Sys.Object.ClassName.md")|Used to get correct class name of the object (Windows, Linux, Android, Web).|
|[`Cls`]("Canvas.Cls.md")||
|[`CopyRect`]("Canvas.CopyRect.md")||
|[`Draw`]("Canvas.Draw.md")||
|[`DrawAlpha`]("Canvas.DrawAlpha.md")||
|[`DrawFocusRect`]("Canvas.DrawFocusRect.md")||
|[`DrawStretch`]("Canvas.DrawStretch.md")||
|[`DrawTransparent`]("Canvas.DrawTransparent.md")||
|[`Ellipse`]("Canvas.Ellipse.md")||
|[`FillRect`]("Canvas.FillRect.md")||
|[`FloodFill`]("Canvas.FloodFill.md")||
|[`FullTypeName`]("My.Sys.Object.FullTypeName.md")|Function to get any typename in the inheritance up hierarchy of the type of an instance (address: 'po') compatible with the built-in 'Object' <br>  ('baseIndex =  0' to get the typename of the instance) <br>  ('baseIndex = -1' to get the base.typename of the instance, or "" if not existing) <br>  ('baseIndex = -2' to get the base.base.typename of the instance, or "" if not existing)|
|[`Get`]("Canvas.Get.md")||
|[`GetDevice`]("Canvas.GetDevice.md")||
|[`GetPixel`]("Canvas.GetPixel.md")||
|[`IsEmpty`]("My.Sys.Object.IsEmpty.md")|Returns a Boolean value indicating whether a object has been initialized (Windows, Linux, Android, Web).|
|[`Line`]("Canvas.Line.md")||
|[`LineTo`]("Canvas.LineTo.md")||
|[`MoveTo`]("Canvas.MoveTo.md")||
|[`Pie`]("Canvas.Pie.md")||
|[`PolyBeizer`]("Canvas.PolyBeizer.md")||
|[`PolyBeizerTo`]("Canvas.PolyBeizerTo.md")||
|[`Polygon`]("Canvas.Polygon.md")||
|[`Polyline`]("Canvas.Polyline.md")||
|[`PolylineTo`]("Canvas.PolylineTo.md")||
|[`ReadProperty`]("Canvas.ReadProperty.md")||
|[`Rectangle`]("Canvas.Rectangle.md")||
|[`ReleaseDevice`]("Canvas.ReleaseDevice.md")||
|[`RoundRect`]("Canvas.RoundRect.md")||
|[`Scale`]("Canvas.Scale.md")||
|[`ScaleX`]("My.Sys.Object.ScaleX.md")|Applies horizontal DPI scaling|
|[`ScaleY`]("My.Sys.Object.ScaleY.md")|Applies vertical DPI scaling|
|[`SetHandle`]("Canvas.SetHandle.md")||
|[`SetPixel`]("Canvas.SetPixel.md")||
|[`TextHeight`]("Canvas.TextHeight.md")||
|[`TextOut`]("Canvas.TextOut.md")||
|[`TextWidth`]("Canvas.TextWidth.md")||
|[`ToString`]("My.Sys.Object.ToString.md")|Returns a string that represents the current object (Windows, Linux, Android, Web).|
|[`UnScaleX`]("My.Sys.Object.UnScaleX.md")|Reverses horizontal scaling|
|[`UnScaleY`]("My.Sys.Object.UnScaleY.md")|Reverses vertical scaling|
|[`UnSetHandle`]("Canvas.UnSetHandle.md")||
|[`WriteProperty`]("Canvas.WriteProperty.md")||
## Events
|Name|Description|
| :------------ | :------------ |
## Examples
```freeBasic
'################################################################################
'#  CanvasDraw.frm                                                              #
'#  This file is an examples of MyFBFramework.                                  #
'#  Authors: Xusinboy Bekchanov, Liu XiaLin                                     #
'################################################################################

    \#ifdef __FB_WIN32__
	    \#cmdline "CanvasDraw.rc"
    \#endif
    '\#Region "Form"
	\#include once "mff/Form.bi"
	\#include once "mff/sys.bi"
	\#include once "mff/Label.bi"
	\#include once "mff/CommandButton.bi"
	\#include once "mff/Picture.bi"
	\#include once "mff/Textbox.bi"
	\#include once "mff/Pen.bi"
	\#include once "mff/ListControl.bi"
	\#include once "mff/Panel.bi"
	\#include once "mff/NumericUpDown.bi"
	\#include once "mff/RichTextBox.bi"
	\#include once "mff/CheckBox.bi"
	\#include once "string.bi"
	
	Using My.Sys.Forms
	Using My.Sys.Drawing
	
	Dim Shared As Integer cmdSelection = 1
	Dim Shared As Point Ms                  '
	Dim Shared As Boolean bUpdatePaint = True ' Fo take too long in Paint sub
	Type Form1Type Extends Form
		Declare Sub cmdDrawButterfly_Click(ByRef Sender As Control)
		Declare Sub PictureBK_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub cmdGDIDraw_Click(ByRef Sender As Control)
		Declare Sub cmdGDICls_Click(ByRef Sender As Control)
		Declare Sub CommandButton2_Click(ByRef Sender As Control)
		Declare Sub cmdGDIDraw1_Click(ByRef Sender As Control)
		Declare Sub Form_Click(ByRef Sender As Control)
		Declare Sub PictureBK_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub Panel1_Form_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub Panel1_Form_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub Panel1_Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub Panel1_Picture_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub Panel1_Picture_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub Panel1_Picture_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub Panel1_Picture_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub Picture2_Picture_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub Picture2_Picture_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub Picture2_Picture_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub Picture2_Picture_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub Picture2_Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub Picture2_Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub Picture2_Form_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub Picture2_Form_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Sub PictureBK_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub PictureBK_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub PictureBK_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub chkGDIPlus_Click(ByRef Sender As CheckBox)
		Declare Sub PictureBK_Click(ByRef Sender As Control)
		Declare Constructor
		
		Dim As CommandButton cmdDrawButterfly, cmdGDIDraw, cmdGDICls
		Dim As Picture PictureBK
		Dim As Label Picture2_Picture(2), Picture2_Form(1)
		
		Dim As NumericUpDown Text1(1), Text2(1), Text3(1), Text4(1), Text5(1)
		Dim As Panel  Panel1_Picture(2), Panel1_Form(1)
		Dim As RichTextBox txtControlName
		Dim As CheckBox chkGDIPlus, chkTransparent, chkCenterImage, chkbackground, chkDoubleBuffered
	End Type
	
	Constructor Form1Type
		\#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/"
				.CurLanguage = My.Sys.Language
			End With
		\#endif
		' Form1
		With This
			.Name = "Form1"
			.Text = "Form1"
			.Graphic.LoadFromFile(ExePath & "/../Resources/background.png")
			.Graphic.CenterImage= True
			.Graphic.StretchImage= StretchMode.smStretchProportional
			.Designer = @This
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Form_Resize)
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Click)
			.OnShow = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Show)
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.BackColor = 16711380
			.DoubleBuffered = True
			.Transparent = False 
			.SetBounds 0, 0, 640, 520
		End With
		' cmdDrawButterfly
		With cmdDrawButterfly
			.Name = "cmdDrawButterfly"
			.Text = ML("Start Draw")  '"????????????"
			.TabIndex = 1
			.Anchor.Bottom = AnchorStyle.asAnchor
			.Anchor.Top = AnchorStyle.asNone
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asNone
			.SetBounds 23, 360, 71, 30
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdDrawButterfly_Click)
			.Parent = @This
		End With
		' PictureBK
		With PictureBK
			.Name = "PictureBK"
			.Text = "PictureBK"
			.TabIndex = 1
			.Graphic.LoadFromFile(ExePath & "/../Resources/Wheel.png")
			
			'jpg-0.webp
			.Graphic.CenterImage= True
			.Graphic.StretchImage= StretchMode.smStretchProportional
			'.Graphic.ScaleFactor = 2
			.ForeColor = clRed
			.BackColor = 12615680
			.Font.Size= 14
			'.Canvas.Pen.Color = clRed
			'.Canvas.BackColor = clBlue
			'.Canvas.Font.Size= 14
			.Anchor.Top = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Bottom = AnchorStyle.asAnchor
			.BackColor = 12615680
			.ForeColor = clRed
			.DoubleBuffered = True
			.Transparent = True
			.SetBounds 50, 66, 440, 280
			.Designer = @This
			.OnPaint = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas), @PictureBK_Paint)
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @PictureBK_Resize)
			.OnMouseMove = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @PictureBK_MouseMove)
			.OnMouseDown = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @PictureBK_MouseDown)
			.OnMouseUp = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @PictureBK_MouseUp)
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @PictureBK_Click)
			.Parent = @This
		End With
		' Text1(0)
		With Text1(0)
			.Name = "Text1(0)"
			.Text = "1"
			.TabIndex = 2
			.SetBounds 20, 0, 40, 20
			.Parent = @This
		End With
		' Text2(0)
		With Text2(0)
			.Name = "Text2(0)"
			.Text = "2"
			.TabIndex = 3
			.SetBounds 80, 0, 40, 20
			.Parent = @This
		End With
		' Text3(0)
		With Text3(0)
			.Name = "Text3(0)"
			.Text = "4"
			.TabIndex = 4
			.SetBounds 150, 0, 40, 20
			.Parent = @This
		End With
		' Text4(0)
		With Text4(0)
			.Name = "Text4(0)"
			.Text = "12"
			.TabIndex = 5
			.SetBounds 210, 0, 40, 20
			.Parent = @This
		End With
		' Text5(0)
		With Text5(0)
			.Name = "Text5(0)"
			.Text = "5"
			.TabIndex = 6
			.SetBounds 260, 0, 40, 20
			.Parent = @This
		End With
		' Text1(1)
		With Text1(1)
			.Name = "Text1(1)"
			.Text = "1"
			.TabIndex = 7
			.SetBounds 20, 30, 40, 20
			.Parent = @This
		End With
		' Text2(1)
		With Text2(1)
			.Name = "Text2(1)"
			.Text = "2"
			.TabIndex = 8
			.SetBounds 80, 30, 40, 20
			.Parent = @This
		End With
		' Text3(1)
		With Text3(1)
			.Name = "Text3(1)"
			.Text = "4"
			.TabIndex = 9
			.SetBounds 150, 30, 40, 20
			.Parent = @This
		End With
		' Text4(1)
		With Text4(1)
			.Name = "Text4(1)"
			.Text = "12"
			.TabIndex = 10
			.SetBounds 210, 30, 40, 20
			.Parent = @This
		End With
		' Text5(1)
		With Text5(1)
			.Name = "Text5(1)"
			.Text = "5"
			.TabIndex = 11
			.SetBounds 260, 30, 40, 20
			.Parent = @This
		End With
		' txtControlName
		With txtControlName
			.Name = "txtControlName"
			.Text = ""
			.TabIndex = 12
			.SetBounds 300, 0, 250, 50
			.Designer = @This
			.Parent = @This
		End With
		' cmdGDIDraw
		With cmdGDIDraw
			.Name = "cmdGDIDraw"
			.Text = ML("Scale")
			.TabIndex = 25
			.Anchor.Top = AnchorStyle.asNone
			.Anchor.Bottom = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asNone
			.Anchor.Left = AnchorStyle.asAnchor
			.SetBounds 96, 361, 79, 30
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdGDIDraw_Click)
			.Parent = @This
		End With
		' cmdGDICls
		With cmdGDICls
			.Name = "cmdGDICls"
			.Text = ML("Cls")
			.TabIndex = 13
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Bottom = AnchorStyle.asAnchor
			.SetBounds 180, 362, 79, 30
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdGDICls_Click)
			.Parent = @This
		End With
		' Panel1_Picture(0)
		With Panel1_Picture(0)
			.Name = "Panel1_Picture(0)"
			.Text = "Panel1"
			.TabIndex = 14
			.BackColor = 33023
			.Transparent = False
			.DoubleBuffered = True
			.Graphic.Bitmap.LoadFromFile(ExePath & "/../Resources/wheel.png")
			.Anchor.Top = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.Anchor.Left = AnchorStyle.asNone
			.SetBounds 380, 130, 35, 35
			.Designer = @This
			.OnPaint = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas), @Panel1_Picture_Paint)
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Panel1_Picture_Resize)
			.OnMouseDown = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Panel1_Picture_MouseDown)
			.OnMouseMove = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Panel1_Picture_MouseMove)
			.Parent = @PictureBK
		End With
		' Panel1_Picture(1)
		With Panel1_Picture(1)
			.Name = "Panel1_Picture(1)"
			.Text = "Panel1_Picture(1)"
			.TabIndex = 21
			.BackColor = 33023
			.Transparent = True
			.DoubleBuffered = True
			.ControlIndex = 0
			.Anchor.Top = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.SetBounds 379, 185, 35, 35
			.OnPaint = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas), @Panel1_Picture_Paint)
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Panel1_Picture_Resize)
			.OnMouseDown = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Panel1_Picture_MouseDown)
			.OnMouseMove = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Panel1_Picture_MouseMove)
			.Designer = @This
			.Parent = @PictureBK
		End With
		' Picture2_Picture(0)
		With Picture2_Picture(0)
			.Name = "Picture2_Picture(0)"
			.Text = "Picture2"
			.TabIndex = 15
			.BackColor = 12615808
			.Transparent = True
			.DoubleBuffered = True
			.Graphic.Bitmap.LoadFromFile(ExePath & "/../Resources/wheel.png")
			.Anchor.Top = AnchorStyle.asAnchorProportional
			.Anchor.Right = AnchorStyle.asNone
			.Anchor.Left = AnchorStyle.asAnchorProportional
			.Anchor.Bottom = AnchorStyle.asNone
			.SetBounds 384, 30, 35, 35
			.Designer = @This
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Picture2_Picture_Resize)
			.OnPaint = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas), @Picture2_Picture_Paint)
			.OnMouseMove = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Picture2_Picture_MouseMove)
			.OnMouseDown = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Picture2_Picture_MouseDown)
			.Parent = @PictureBK
		End With
		' Picture2_Picture(1)
		With Picture2_Picture(1)
			.Name = "Picture2_Picture(1)"
			.Text = "Picture2_Picture(1)"
			.TabIndex = 20
			.BackColor = 12615808
			.Transparent = True
			.DoubleBuffered = True
			.ControlIndex = 1
			.Anchor.Top = AnchorStyle.asAnchorProportional
			.Anchor.Right = AnchorStyle.asNone
			.Anchor.Left = AnchorStyle.asAnchorProportional
			.Anchor.Bottom = AnchorStyle.asNone
			.SetBounds 381, 75, 33, 35
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Picture2_Picture_Resize)
			.OnPaint = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas), @Picture2_Picture_Paint)
			.OnMouseMove = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Picture2_Picture_MouseMove)
			.OnMouseDown = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Picture2_Picture_MouseDown)
			.Designer = @This
			.Parent = @PictureBK
		End With
		
		' Panel1_Form(0)
		With Panel1_Form(0)
			.Name = "Panel1_Form(0)"
			.Text = "Panel1_Form(0)"
			.TabIndex = 16
			.ControlIndex = 0
			.BackColor = 65280
			.Transparent = True
			.DoubleBuffered = True
			.Graphic.Bitmap.LoadFromFile(ExePath & "/../Resources/wheel.png")
			.Anchor.Top = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.SetBounds 542, 61, 45, 45
			.Designer = @This
			.OnMouseDown = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Panel1_Form_MouseDown)
			.OnMouseMove = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Panel1_Form_MouseMove)
			.OnPaint = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas), @Panel1_Form_Paint)
			.Parent = @This
		End With
		' Picture2_Form(0)
		With Picture2_Form(0)
			.Name = "Picture2_Form(0)"
			.Text = "Picture2"
			.TabIndex = 17
			.ControlIndex = 1
			.BackColor = 32768
			.Transparent = True
			.DoubleBuffered = True
			.Graphic.Bitmap.LoadFromFile(ExePath & "/../Resources/wheel.png")
			.Anchor.Top = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.SetBounds 542, 121, 45, 45
			.Designer = @This
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Picture2_Form_Resize)
			.OnPaint = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas), @Picture2_Form_Paint)
			.OnMouseDown = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Picture2_Form_MouseDown)
			.OnMouseMove = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Picture2_Form_MouseMove)
			.Parent = @This
		End With
		' Picture2_Form(1)
		With Picture2_Form(1)
			.Name = "Picture2_Form(1)"
			.Text = "Picture2_Form(1)"
			.TabIndex = 18
			.BackColor = 32768
			.Transparent = True
			.DoubleBuffered = True
			.ControlIndex = 15
			.Anchor.Top = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.SetBounds 544, 178, 45, 45
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Picture2_Form_Resize)
			.OnPaint = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas), @Picture2_Form_Paint)
			.OnMouseDown = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Picture2_Form_MouseDown)
			.OnMouseMove = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Picture2_Form_MouseMove)
			.Designer = @This
			.Parent = @This
		End With
		' Panel1_Form(1)
		With Panel1_Form(1)
			.Name = "Panel1_Form(1)"
			.Text = "Panel1_Form(1)"
			.TabIndex = 19
			.BackColor = 65280
			.Transparent = True
			.ControlIndex = 14
			.Anchor.Top = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.SetBounds 548, 238, 45, 45
			.OnMouseDown = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Panel1_Form_MouseDown)
			.OnMouseMove = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Panel1_Form_MouseMove)
			.OnPaint = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas), @Panel1_Form_Paint)
			.Designer = @This
			.Parent = @This
		End With
		' chkGDIPlus
		With chkGDIPlus
			.Name = "chkGDIPlus"
			.Text = ML("Drawing with GDI+")
			.TabIndex = 33
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Bottom = AnchorStyle.asAnchor
			.SetBounds 260, 370, 120, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox), @chkGDIPlus_Click)
			.Parent = @This
		End With
		' chkTransparent
		With chkTransparent
			.Name = "chkTransparent"
			.Text = ML("Transparent")
			.TabIndex = 34
			.ControlIndex = 19
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Bottom = AnchorStyle.asAnchor
			.Checked = True
			.SetBounds 390, 370, 70, 20
			.Designer = @This
			.Parent = @This
		End With
		' chkCenterImage
		With chkCenterImage
			.Name = "chkCenterImage"
			.Text = ML("CenterImage")
			.TabIndex = 35
			.ControlIndex = 20
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Bottom = AnchorStyle.asAnchor
			.Checked = True
			.SetBounds 470, 370, 70, 20
			.Designer = @This
			.Parent = @This
		End With
		' chkbackground
		With chkbackground
			.Name = "chkbackground"
			.Text = ML("Background")
			.TabIndex = 36
			.ControlIndex = 21
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Bottom = AnchorStyle.asAnchor
			.Checked = True
			.SetBounds 260, 400, 70, 20
			.Designer = @This
			.Parent = @This
		End With
		' chkDoubleBuffered
		With chkDoubleBuffered
			.Name = "chkDoubleBuffered"
			.Text = ML("DoubleBuffered")
			.TabIndex = 37
			.ControlIndex = 22
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Bottom = AnchorStyle.asAnchor
			.Checked = True
			.SetBounds 340, 400, 70, 20
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared Form1 As Form1Type
	
	\#ifndef _NOT_AUTORUN_FORMS_
		App.DarkMode= True
		\#define _NOT_AUTORUN_FORMS_
		Form1.Show
		App.Run
	\#endif
    '\#End Region

Private Sub Form1Type.cmdDrawButterfly_Click(ByRef Sender As Control)
	If Not bUpdatePaint Then Exit Sub
	Dim T As Double = Timer
	Dim As Double A(1), B(1), C(1), D(1), E(1), X, Y
	cmdSelection = 0
	cmdDrawButterfly.Caption = "Waiting......Drawing" 
	'PictureBK.Style = PictureStyle.ssOwnerDraw
	'Picture2_Picture(0).Visible= False
	'Panel1_Picture(0).Visible= False
	'Picture2_Picture(1).Visible= False
	'Panel1_Picture(1).Visible= False
	With PictureBK.Canvas
		'PictureBK.DoubleBuffered = Not chkGDIPlus.Checked
		.Scale(-10, -10, 10, 10)
		.BackColor = PictureBK.BackColor
		.DrawColor = clRed ' Will lost the background if not set the value first
		'.Pen.Mode = PenMode.pmNotXor
		'.Pen.Color = clRed
		'.Font.Size= 14
		.DrawWidth = 2
		'.FillStyles = BrushStyles.bsSolid
		.FillStyles = BrushStyles.bsClear ' Will lost the background if not set the value first
		'.Pen.Mode = PenMode.pmMerge
		' draw across  ???????????????
		'.FillMode = BrushFillMode.bmOpaque
		'.FillStyles = BrushStyles.bsSolid
		'.Rectangle -10 , -10 , 10 , 10
		'.Line -10 , -10 , 10 , 10, clblue, "BF"
		.Line -10 , 0 , 10 , 00
		.Line 0 , -10 , 0 , 10
		.TextOut 10 , 0, "1", clGreen , -1
		.TextOut 10, 20 - 2, "2", clGreen , -1
		.TextOut 00 , 10, "3", clGreen , -1
		.TextOut 20 - 3 , 1000, "4", clGreen , -1
		.TextOut 1 , 1, "0", clGreen , -1
		
		' drawing arrow  ?????????
		'    .Line 0 , 1000 , -125 , 950
		'    .Line 0 , 1000 , 125 , 950
		'    .Line 1000 , 0 , 950 , 125
		'    .Line 1000 , 0 , 950 , -125
		'
		A(0) = Val(Text1(0).Text): A(1) = Val(Text1(1).Text)
		B(0) = Val(Text2(0).Text): B(1) = Val(Text2(1).Text)
		C(0) = Val(Text3(0).Text): C(1) = Val(Text3(1).Text)
		D(0) = Val(Text4(0).Text): D(1) = Val(Text4(1).Text)
		E(0) = Val(Text5(0).Text): E(1) = Val(Text5(1).Text)
		'
		If A(0) < 1 Then A(0) = 1: If A(1) < 1 Then A(1) = 1
		If D(0) < 1 Then D(0) = 1: If D(1) < 1 Then D(1) = 1
		If E(0) < 1 Then E(0) = 1: If E(1) < 1 Then E(1) = 1
		
		For i As Long = -72000 To 72000 'Step  0.1
			X = (Sin(i * A(0)) * (Exp(Cos(i)) - B(0) * Cos(C(0) * i) - Sin(i / D(0)) ^ E(0)))
			Y = (Cos(i * A(1)) * (Exp(Cos(i)) - B(1) * Cos(C(1) * i) - Sin(i / D(1)) ^ E(1)))
			.SetPixel X, Y, clRed
			'.TextOut 20, 20, Str(i), clYellow, -1
		Next
		.TextOut - 9, -9, "  Elapsed Time: " & Format(Timer - T, "0.0000") & "s", clGreen , -1 
		
	End With
	'bUpdatePaint = False
	cmdDrawButterfly.Caption = "Start Draw" 
End Sub

Private Sub Form1Type.PictureBK_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	Dim T As Double = Timer
	PictureBK.Graphic.Visible = chkbackground.Checked
	PictureBK.Graphic.CenterImage = chkCenterImage.Checked 
	PictureBK.Transparent = chkTransparent.Checked 
	PictureBK.DoubleBuffered = chkDoubleBuffered.Checked
	Canvas.UsingGdip = chkGDIPlus.Checked
	If cmdSelection = 1 Then cmdGDIDraw_Click(Sender) Else cmdDrawButterfly_Click(Sender)
	'chkGDIPlus.Checked = PictureBK.Canvas.UsingGdip
	'	'.FillColor = 16744448
	'	.UsingGdip = chkGDIPlus.Checked
	Me.Caption = "Drawing With GdipToken="  & PictureBK.Canvas.GdipToken & "  Elapsed Time: " & Format(Timer - T, "0.0000") & "s"
End Sub

Private Sub Form1Type.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	
End Sub

Sub Taijitu(x As Integer, y As Integer, r As Integer)
	'With PictureBK.Canvas
	'	.Circle x, y, 2 * r, 0, , , , F
	'	.Line x, y - 2 * r, x, y + 2 * r, 7, B
	'	.Paint x - r, y, 15, 7
	'	.Circle x, y - r, r - 1, 15, , , , F
	'	.Circle x, y + r, r - 1,  0, , , , F
	'	.Circle x, y - r, r / 3,  0, , , , F
	'	.Circle x, y + r, r / 3, 15, , , , F
	'End With
End Sub
'https://learn.microsoft.com/zh-cn/windows/win32/gdiplus/-gdiplus-graphics-flat

Private Sub Form1Type.cmdGDIDraw_Click(ByRef Sender As Control)
	cmdSelection = 1
	bUpdatePaint = True
	With PictureBK.Canvas
		.Scale(-100, 100, 100, -100)
		.BackColor = PictureBK.BackColor
		.DrawColor = clRed ' Will lost the background if not set the value first
		'.Pen.Mode = PenMode.pmNotXor
		'.Pen.Color = clRed
		'.Font.Size= 14
		.DrawWidth = 2
		'.FillStyles = BrushStyles.bsSolid
		.FillStyles = BrushStyles.bsClear ' Will lost the background if not set the value first
		'.FillMode = BrushFillMode.bmOpaque
		'.DrawStyle = PenStyle.psSolid
		.DrawColor = clYellow
		.Line (-100, 0, 100, 0) 
		.Line (0, 100, 0, -100)
		.Circle (0, 0, 10)
		.MoveTo(0, 0)
		.AngleArc(0, 0, 50, 90, 180)
		.AngleArc(0, 0, 50, 270, 180)
		
		.Ellipse(10, 10, 10, 10)
		.FloodFill(0, 0, clBlueViolet, FillStyle.fsBorder)
		.FillStyles = BrushStyles.bsClear
		.Ellipse(10, -10, 10, 10)
		.TextOut 0,  0, "(0,0)" , clGreen, -1 
		.TextOut 90, 10, "X", clGreen, -1  
		.TextOut 5, 95,  "Y", clGreen, -1 
		
		For i As Integer = 10 To 50 Step 4
			.SetPixel(i, 10, clRed) '???????????????
		Next
		
		.DrawWidth = 1 
		.DrawStyle = PenStyle.psSolid
		.DrawColor = clYellow
		.Line(-10, -10, -100, -10)
		
		.DrawStyle = PenStyle.psDash
		.Line(-10, -20, -100, -20)
		
		.DrawStyle = PenStyle.psDashDot
		.Line -10, -30, -100, -30
		
		.DrawStyle = PenStyle.psDashDotDot
		.Line -10, -40, -100, -40
		
		.FillStyles = BrushStyles.bsSolid
		.Line 40, 20, 80, 40, , "F"
		.Line 140, 70, 80, 90, clBlue, "F"
		
		.DrawWidth = 2 
		'.DrawStyle = PenStyle.psSolid
		'?????????????????????????????????
		.Arc(30, 50, 70, 80, 70, 60, 30, 60)
		.Chord(10, 60, 40, 80, 40, 60, 80, 70)
		.Pie(0, 0, 40, 50, 60, 80, 40, 60)
		
		Dim As My.Sys.Drawing.Point pt(4) = {(-60, + 20), (-60, 0), (-90, 0), (-90, + 20), (-60, + 20)}
		'{{90, 130}, {60, 40}, {140, 150}, {160, 80}}
		.Ellipse(pt(0).X, pt(0).Y, pt(1).X, pt(1).Y)
		'.Rectangle(pt(2).X, pt(2).Y, pt(3).X, pt(3).Y)
		.RoundRect(30, 10, 60, 30, 25, 25)
		.DrawColor = clRed
		.FillColor = clYellow
		.DrawWidth = 2  'DrawWidth
		.FillStyles = BrushStyles.bsHatch
		.HatchStyle = HatchStyles.hsDiagonal
		.DrawColor = clGreenYellow
		.Polyline(pt(), 5)
		
		.Circle(pt(0).X, pt(0).Y, 4)
		.Circle(pt(1).X, pt(1).Y, 4)
		.Circle(pt(2).X, pt(2).Y, 4)
		.Circle(pt(3).X, pt(3).Y, 4)
		
		.Circle(50, 60, 20, clYellow)
		
		.DrawWidth = 1
		.DrawColor = clGreen
		.FillColor = clRed
		.FillStyles = BrushStyles.bsClear
		.FillColor = clBlue
		.Rectangle(20, -20, 60, -30) ' HS_BDIAGONAL, RGB(255, 0, 0))
		.FillColor = clRed
		.FillStyles = BrushStyles.bsHatch
		.HatchStyle = HatchStyles.hsCross
		.Rectangle(20, -40, 60, -50) ' HS_CROSS, RGB(0, 255, 0));
		.DrawColor = clGreen
		.FillColor = clYellow
		.HatchStyle = HatchStyles.hsDiagCross
		.FillColor = clYellow
		.Rectangle(20, -60, 60, -70) ' HS_DIAGCROSS, RGB(0, 0, 255))
		.DrawColor = clYellow
		.HatchStyle = HatchStyles.hsVertical
		.FillColor = clGray
		.Rectangle(20, -80, 60, -90) ' HS_VERTICAL, RGB(0, 0, 0))
		.Rectangle(40, -80, 60, -90) ' HS_VERTICAL, RGB(0, 0, 0))
		
	End With
End Sub

Private Sub Form1Type.cmdGDICls_Click(ByRef Sender As Control)
	bUpdatePaint = True
	With PictureBK.Canvas
		.Cls(50, -20, 60, -40)
		Sleep(2000)
		.Cls
	End With
End Sub


Private Sub Form1Type.Form_Click(ByRef Sender As Control)
	
End Sub

Private Sub Form1Type.PictureBK_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	
End Sub

Private Sub Form1Type.Panel1_Form_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	Dim As Integer Index = Val(Mid(Sender.Name, InStrRev(Sender.Name, "(") + 1))
	Ms.X = x
	Ms.Y = y
	txtControlName.Text = Sender.Name
	Sender.BringToFront
End Sub

Private Sub Form1Type.Panel1_Form_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	Dim As Integer Index = Val(Mid(Sender.Name, InStrRev(Sender.Name, "(") + 1))
	If MouseButton = 0 Then Sender.Location = Type<My.Sys.Drawing.Point>(Sender.Left + x - Ms.X, Sender.Top + y - Ms.Y) : Sender.Repaint
End Sub

Private Sub Form1Type.Panel1_Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	Dim As Integer Index = Val(Mid(Sender.Name, InStrRev(Sender.Name, "(") + 1))
End Sub

Private Sub Form1Type.Panel1_Picture_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	Dim As Integer Index = Val(Mid(Sender.Name, InStrRev(Sender.Name, "(") + 1))
End Sub

Private Sub Form1Type.Panel1_Picture_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	Dim As Integer Index = Val(Mid(Sender.Name, InStrRev(Sender.Name, "(") + 1))
End Sub

Private Sub Form1Type.Panel1_Picture_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	Dim As Integer Index = Val(Mid(Sender.Name, InStrRev(Sender.Name, "(") + 1))
	Ms.X = x
	Ms.Y = y
	txtControlName.Text = Sender.Name
	Sender.BringToFront
End Sub

Private Sub Form1Type.Panel1_Picture_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	Dim As Integer Index = Val(Mid(Sender.Name, InStrRev(Sender.Name, "(") + 1))
	If MouseButton = 0 Then Sender.Location = Type<My.Sys.Drawing.Point>(Sender.Left + x - Ms.X, Sender.Top + y - Ms.Y) : Sender.Repaint
End Sub

Private Sub Form1Type.Picture2_Picture_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	Dim As Integer Index = Val(Mid(Sender.Name, InStrRev(Sender.Name, "(") + 1))
End Sub

Private Sub Form1Type.Picture2_Picture_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	Dim As Integer Index = Val(Mid(Sender.Name, InStrRev(Sender.Name, "(") + 1))
End Sub

Private Sub Form1Type.Picture2_Picture_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	Dim As Integer Index = Val(Mid(Sender.Name, InStrRev(Sender.Name, "(") + 1))
	If MouseButton = 0 Then Sender.Location = Type<My.Sys.Drawing.Point>(Sender.Left + x - Ms.X, Sender.Top + y - Ms.Y) : Sender.Repaint
End Sub

Private Sub Form1Type.Picture2_Picture_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	Dim As Integer Index = Val(Mid(Sender.Name, InStrRev(Sender.Name, "(") + 1))
	Ms.X = x
	Ms.Y = y
	txtControlName.Text = Sender.Name
	Sender.BringToFront
End Sub
Private Sub Form1Type.Picture2_Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	Dim As Integer Index = Val(Mid(Sender.Name, InStrRev(Sender.Name, "(") + 1))
End Sub

Private Sub Form1Type.Picture2_Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	Dim As Integer Index = Val(Mid(Sender.Name, InStrRev(Sender.Name, "(") + 1))
End Sub

Private Sub Form1Type.Picture2_Form_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	Dim As Integer Index = Val(Mid(Sender.Name, InStrRev(Sender.Name, "(") + 1))
	Ms.X = x
	Ms.Y = y
	txtControlName.Text = Sender.Name
End Sub

Private Sub Form1Type.Picture2_Form_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	Dim As Integer Index = Val(Mid(Sender.Name, InStrRev(Sender.Name, "(") + 1))
	If MouseButton = 0 Then Sender.Location = Type<My.Sys.Drawing.Point>(Sender.Left + x - Ms.X, Sender.Top + y - Ms.Y) : Sender.Repaint
End Sub

Private Sub Form1Type.Form_Show(ByRef Sender As Form)
	'chkGDIPlus.Checked = True 
	'With PictureBK.Canvas
	'	'.FillColor = 16744448
	'	.UsingGdip = chkGDIPlus.Checked
	'End With
End Sub

Private Sub Form1Type.PictureBK_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	'If MouseButton = 0 Then Sender.Location = Type<My.Sys.Drawing.Point>(Sender.Left + x - Ms.X, Sender.Top + y - Ms.Y) : Sender.Repaint
End Sub

Private Sub Form1Type.PictureBK_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	Ms.X = x
	Ms.Y = y
	txtControlName.Text = Sender.Name
End Sub

Private Sub Form1Type.PictureBK_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	
	Enum FillStyleMy
		fsSurfaceMy     = FLOODFILLSURFACE
		fsBorderMY      = FLOODFILLBORDER
	End Enum
	
	Type RectMy
		LeftMy As Long
		TopMy As FillStyleMy
		RightMy As Long
		BottomMy As Long
	End Type
	
	Dim TempRect As RectMy
	TempRect.LeftMy = 100
	TempRect.RightMy = 200
	TempRect.TopMy = FillStyleMy.fsBorderMY
	'Debug.Print 9999, TempRect.LeftMy, TempRect.RightMy, TempRect.TopMy
End Sub

Private Sub Form1Type.Form_Create(ByRef Sender As Control)
	'	Dim As Rect R
	'GetClientRect GetDesktopWindow(), @R
	'If R.Right < 10 Then R = Type<Rect>(0, 0, 1920, 1080)
	'This.Graphic.Bitmap.LoadFromScreen(R.Left, R.Top, R.Right, R.Bottom)
End Sub

Private Sub Form1Type.chkGDIPlus_Click(ByRef Sender As CheckBox)
	PictureBK.Canvas.Cls ' if switch must be use cls for init
End Sub

Private Sub Form1Type.PictureBK_Click(ByRef Sender As Control)
	
End Sub

```

## See also
Namespace: [`My.Sys.Drawing`](My.Sys.Drawing.md)
