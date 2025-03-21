[TOC]
## Definition
Namespace: [`My.Sys.Forms`](My.Sys.Forms.md)

`ImageList` - An image list is a collection of images of the same size, each of which can be referred to by its index.

## Properties
|Name|Description|
| :------------ | :------------ |
|[`BackColor`]("ImageList.BackColor.md")||
|[`Count`]("ImageList.Count.md")||
|[`Designer`]("My.Sys.Object.Designer.md")|Returns/sets the object that enables you to access the design characteristics of a object (Windows, Linux, Android, Web).|
|[`DesignMode`]("Component.DesignMode.md")|Gets a value that indicates whether the Component is currently in design mode (Windows, Linux, Android, Web).|
|[`DrawingStyle`]("ImageList.DrawingStyle.md")||
|[`ExtraMargins`]("Component.ExtraMargins.md")|Returns/sets the extra space between controls (Windows, Linux, Android, Web).|
|[`GrowCount`]("ImageList.GrowCount.md")||
|[`Handle`]("ImageList.Handle.md")||
|[`Height`]("Component.Height.md")|Returns/sets the height of an object (Windows, Linux, Android, Web).|
|[`ImageHeight`]("ImageList.ImageHeight.md")||
|[`ImageType`]("ImageList.ImageType.md")||
|[`ImageWidth`]("ImageList.ImageWidth.md")||
|[`InitialCount`]("ImageList.InitialCount.md")||
|[`Items`]("ImageList.Items.md")||
|[`LayoutHandle`]("Component.LayoutHandle.md")||
|[`Left`]("Component.Left.md")|Returns/sets the distance between the internal left edge of an object and the left edge of its container (Windows, Linux, Android, Web).|
|[`Margins`]("Component.Margins.md")|Returns/sets the space between controls (Windows, Linux, Android, Web).|
|[`MaskColor`]("ImageList.MaskColor.md")||
|[`Name`]("Component.Name.md")|Returns the name used in code to identify an object (Windows, Linux, Android, Web).|
|[`Parent`]("Component.Parent.md")|Gets or sets the parent container of the control (Windows, Linux, Android, Web).|
|[`ParentWindow`]("ImageList.ParentWindow.md")||
|[`Tag`]("Component.Tag.md")|Stores any extra data needed for your program (Windows, Linux, Android, Web).|
|[`Top`]("Component.Top.md")|Returns/sets the distance between the internal top edge of an object and the top edge of its container (Windows, Linux, Android, Web).|
|[`Width`]("Component.Width.md")|Returns/sets the width of an object (Windows, Linux, Android, Web).|
|[`xdpi`]("My.Sys.Object.xdpi.md")|Horizontal DPI scaling factor (Windows, Linux, Android, Web).|
|[`ydpi`]("My.Sys.Object.ydpi.md")|Vertical DPI scaling factor (Windows, Linux, Android, Web).|

## Methods
|Name|Description|
| :------------ | :------------ |
|[`Add`]("ImageList.Add.md")||
|[`AddFromFile`]("ImageList.AddFromFile.md")||
|[`AddMasked`]("ImageList.AddMasked.md")||
|[`ClassAncestor`]("Component.ClassAncestor.md")|Returns ancestor class of control (Windows, Linux, Android, Web).|
|[`ClassName`]("My.Sys.Object.ClassName.md")|Used to get correct class name of the object (Windows, Linux, Android, Web).|
|[`Clear`]("ImageList.Clear.md")||
|[`Draw`]("ImageList.Draw.md")||
|[`FullTypeName`]("My.Sys.Object.FullTypeName.md")|Function to get any typename in the inheritance up hierarchy of the type of an instance (address: 'po') compatible with the built-in 'Object' <br>  ('baseIndex =  0' to get the typename of the instance) <br>  ('baseIndex = -1' to get the base.typename of the instance, or "" if not existing) <br>  ('baseIndex = -2' to get the base.base.typename of the instance, or "" if not existing)|
|[`GetBitmap`]("ImageList.GetBitmap.md")||
|[`GetBounds`]("Component.GetBounds.md")|Gets the bounds of the control to the specified location and size (Windows, Linux, Android, Web).|
|[`GetCursor`]("ImageList.GetCursor.md")||
|[`GetIcon`]("ImageList.GetIcon.md")||
|[`GetMask`]("ImageList.GetMask.md")||
|[`GetTopLevel`]("Component.GetTopLevel.md")|Determines if the control is a top-level control (Windows, Linux, Android, Web).|
|[`IndexOf`]("ImageList.IndexOf.md")||
|[`IsEmpty`]("My.Sys.Object.IsEmpty.md")|Returns a Boolean value indicating whether a object has been initialized (Windows, Linux, Android, Web).|
|[`ReadProperty`]("ImageList.ReadProperty.md")||
|[`Remove`]("ImageList.Remove.md")|Declare Sub AddPng(ByRef ResName As WString, ByRef Key As WString = "", ModuleHandle As Any Ptr = 0) <br>   Declare Sub Set(Index As Integer, Bitmap As My.Sys.Drawing.BitmapType, Mask As My.Sys.Drawing.BitmapType, ByRef Key As WString = "") <br>   Declare Sub Set(ByRef Key As WString, Bitmap As My.Sys.Drawing.BitmapType, Mask As My.Sys.Drawing.BitmapType, ByRef Key As WString = "") <br>   Declare Sub Set(Index As Integer, Icon As My.Sys.Drawing.Icon, ByRef Key As WString = "") <br>   Declare Sub Set(ByRef Key As WString, Icon As My.Sys.Drawing.Icon, ByRef Key As WString = "") <br>   Declare Sub Set(Index As Integer, Cursor As My.Sys.Drawing.Cursor, ByRef Key As WString = "") <br>   Declare Sub Set(ByRef Key As WString, Cursor As My.Sys.Drawing.Cursor, ByRef Key As WString = "") <br>   Declare Sub Set(Index As Integer, ByRef ResName As WString, ModuleHandle As Any Ptr = 0) <br>   Declare Sub Set(ByRef Key As WString, ByRef ResName As WString, ModuleHandle As Any Ptr = 0) <br>   Declare Sub SetFromFile(Index As Integer, ByRef File As WString) <br>   Declare Sub SetFromFile(ByRef Key As WString, ByRef File As WString)|
|[`ScaleX`]("My.Sys.Object.ScaleX.md")|Applies horizontal DPI scaling|
|[`ScaleY`]("My.Sys.Object.ScaleY.md")|Applies vertical DPI scaling|
|[`SetBounds`]("Component.SetBounds.md")|Sets the bounds of the control to the specified location and size (Windows, Linux, Android, Web).|
|[`SetImageSize`]("ImageList.SetImageSize.md")||
|[`ToString`]("Component.ToString.md")|Returns a string that represents the current object (Windows, Linux, Android, Web).|
|[`UnScaleX`]("My.Sys.Object.UnScaleX.md")|Reverses horizontal scaling|
|[`UnScaleY`]("My.Sys.Object.UnScaleY.md")|Reverses vertical scaling|
|[`WriteProperty`]("ImageList.WriteProperty.md")||
## Events
|Name|Description|
| :------------ | :------------ |
|[`OnChange`]("ImageList.OnChange.md") ||
## See also
Namespace: [`My.Sys.Forms`](My.Sys.Forms.md)
