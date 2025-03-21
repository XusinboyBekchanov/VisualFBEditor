[TOC]
## Definition
Namespace: [`My.Sys.Forms`](My.Sys.Forms.md)

`TimerComponent` - A control which can execute code at regular intervals by causing a Timer event.

## Properties
|Name|Description|
| :------------ | :------------ |
|[`Designer`]("My.Sys.Object.Designer.md")|Returns/sets the object that enables you to access the design characteristics of a object (Windows, Linux, Android, Web).|
|[`DesignMode`]("Component.DesignMode.md")|Gets a value that indicates whether the Component is currently in design mode (Windows, Linux, Android, Web).|
|[`Enabled`]("TimerComponent.Enabled.md")||
|[`ExtraMargins`]("Component.ExtraMargins.md")|Returns/sets the extra space between controls (Windows, Linux, Android, Web).|
|[`Handle`]("Component.Handle.md")|Gets the window handle that the control is bound to (Windows, Linux, Android, Web).|
|[`Height`]("Component.Height.md")|Returns/sets the height of an object (Windows, Linux, Android, Web).|
|[`ID`]("TimerComponent.ID.md")||
|[`Interval`]("TimerComponent.Interval.md")||
|[`LayoutHandle`]("Component.LayoutHandle.md")||
|[`Left`]("Component.Left.md")|Returns/sets the distance between the internal left edge of an object and the left edge of its container (Windows, Linux, Android, Web).|
|[`Margins`]("Component.Margins.md")|Returns/sets the space between controls (Windows, Linux, Android, Web).|
|[`Name`]("Component.Name.md")|Returns the name used in code to identify an object (Windows, Linux, Android, Web).|
|[`Parent`]("Component.Parent.md")|Gets or sets the parent container of the control (Windows, Linux, Android, Web).|
|[`Tag`]("Component.Tag.md")|Stores any extra data needed for your program (Windows, Linux, Android, Web).|
|[`Top`]("Component.Top.md")|Returns/sets the distance between the internal top edge of an object and the top edge of its container (Windows, Linux, Android, Web).|
|[`Width`]("Component.Width.md")|Returns/sets the width of an object (Windows, Linux, Android, Web).|
|[`xdpi`]("My.Sys.Object.xdpi.md")|Horizontal DPI scaling factor (Windows, Linux, Android, Web).|
|[`ydpi`]("My.Sys.Object.ydpi.md")|Vertical DPI scaling factor (Windows, Linux, Android, Web).|

## Methods
|Name|Description|
| :------------ | :------------ |
|[`ClassAncestor`]("Component.ClassAncestor.md")|Returns ancestor class of control (Windows, Linux, Android, Web).|
|[`ClassName`]("My.Sys.Object.ClassName.md")|Used to get correct class name of the object (Windows, Linux, Android, Web).|
|[`FullTypeName`]("My.Sys.Object.FullTypeName.md")|Function to get any typename in the inheritance up hierarchy of the type of an instance (address: 'po') compatible with the built-in 'Object' <br>  ('baseIndex =  0' to get the typename of the instance) <br>  ('baseIndex = -1' to get the base.typename of the instance, or "" if not existing) <br>  ('baseIndex = -2' to get the base.base.typename of the instance, or "" if not existing)|
|[`GetBounds`]("Component.GetBounds.md")|Gets the bounds of the control to the specified location and size (Windows, Linux, Android, Web).|
|[`GetTopLevel`]("Component.GetTopLevel.md")|Determines if the control is a top-level control (Windows, Linux, Android, Web).|
|[`IsEmpty`]("My.Sys.Object.IsEmpty.md")|Returns a Boolean value indicating whether a object has been initialized (Windows, Linux, Android, Web).|
|[`ReadProperty`]("TimerComponent.ReadProperty.md")||
|[`ScaleX`]("My.Sys.Object.ScaleX.md")|Applies horizontal DPI scaling|
|[`ScaleY`]("My.Sys.Object.ScaleY.md")|Applies vertical DPI scaling|
|[`SetBounds`]("Component.SetBounds.md")|Sets the bounds of the control to the specified location and size (Windows, Linux, Android, Web).|
|[`ToString`]("Component.ToString.md")|Returns a string that represents the current object (Windows, Linux, Android, Web).|
|[`UnScaleX`]("My.Sys.Object.UnScaleX.md")|Reverses horizontal scaling|
|[`UnScaleY`]("My.Sys.Object.UnScaleY.md")|Reverses vertical scaling|
|[`WriteProperty`]("TimerComponent.WriteProperty.md")||
## Events
|Name|Description|
| :------------ | :------------ |
|[`OnTimer`]("TimerComponent.OnTimer.md") ||
## Examples
```freeBasic
\#ifdef __FB_WIN32__
	'\#Compile -exx "Form2.rc"
\#else
	'\#Compile -exx
\#endif
\#include once "mff/Form.bi"
\#include once "mff/CommandButton.bi"
\#include once "mff/TimerComponent.bi"

Using My.Sys.Forms

'\#Region "Form"
    Type Form1 Extends Form
    	Declare Sub cmdStartTimer_Click(ByRef Sender As Control)
    	Declare Sub cmdEndTimer_Click(ByRef Sender As Control)
    	Declare Sub TimerComponent1_Timer(ByRef Sender As TimerComponent)
    	Declare Constructor
        
    	Dim As CommandButton cmdStartTimer, cmdEndTimer
    	Dim As TimerComponent TimerComponent1
    End Type
    
    Constructor Form1
    	' Form1
    	With This
    		.Name = "Form1"
    		.Text = "Form1"
    		.SetBounds 0, 0, 350, 300
    	End With
    	' cmdStartTimer
    	With cmdStartTimer
    		.Name = "cmdStartTimer"
    		.Text = "Start timer"
    		.SetBounds 80, 140, 72, 48
    		.Designer = @This
    		.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdStartTimer_Click)
    		.Parent = @This
    	End With
    	' TimerComponent1
    	With TimerComponent1
    		.Name = "TimerComponent1"
    		.SetBounds 48, 62, 16, 16
    		.Interval = 10
    		.Designer = @This
    		.OnTimer = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent), @TimerComponent1_Timer)
    		.Parent = @This
    	End With
    	' cmdEndTimer
    	With cmdEndTimer
    		.Name = "cmdEndTimer"
    		.Text = "End timer"
    		.SetBounds 160, 136, 72, 48
    		.Designer = @This
    		.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdEndTimer_Click)
    		.Parent = @This
    	End With
    End Constructor
    
    Dim Shared fForm1 As Form1
    
    \#ifndef _NOT_AUTORUN_FORMS_
    	App.DarkMode= True 
        fForm1.Show        
        App.Run
    \#endif
'\#End Region

Private Sub Form1.cmdStartTimer_Click(ByRef Sender As Control)
	fForm1.TimerComponent1.Enabled = True
End Sub

Private Sub Form1.cmdEndTimer_Click(ByRef Sender As Control)
	fForm1.TimerComponent1.Enabled = False
End Sub

Private Sub Form1.TimerComponent1_Timer(ByRef Sender As TimerComponent)
	?1
End Sub
```
## See also
Namespace: [`My.Sys.Forms`](My.Sys.Forms.md)
