[TOC]
## Definition
Namespace: [`My.Sys.Forms`](My.Sys.Forms.md)

`MenuItem` - `MenuItem` - Represents an individual element in menu structures with hierarchical submenu support and action binding.

## Properties
|Name|Description|
| :------------ | :------------ |
|[`accelerator_key`]("MenuItem.accelerator_key.md")|Keyboard key for shortcut (e.g., 'F5')|
|[`accelerator_mods`]("MenuItem.accelerator_mods.md")|Modifier keys (Ctrl/Alt/Shift) for shortcut|
|[`Box`]("MenuItem.Box.md")||
|[`Caption`]("MenuItem.Caption.md")||
|[`Checked`]("MenuItem.Checked.md")||
|[`Command`]("MenuItem.Command.md")||
|[`Count`]("MenuItem.Count.md")||
|[`Designer`]("My.Sys.Object.Designer.md")|Returns/sets the object that enables you to access the design characteristics of a object (Windows, Linux, Android, Web).|
|[`Enabled`]("MenuItem.Enabled.md")||
|[`Handle`]("MenuItem.Handle.md")|declare property Menu as HMENU <br> declare property Menu(value as HMENU)|
|[`Icon`]("MenuItem.Icon.md")||
|[`Image`]("MenuItem.Image.md")||
|[`ImageIndex`]("MenuItem.ImageIndex.md")||
|[`ImageKey`]("MenuItem.ImageKey.md")||
|[`Item`]("MenuItem.Item.md")|Indexer for submenu items|
|[`Label`]("MenuItem.Label.md")||
|[`MenuIndex`]("MenuItem.MenuIndex.md")||
|[`Name`]("MenuItem.Name.md")||
|[`Owner`]("MenuItem.Owner.md")||
|[`Parent`]("MenuItem.Parent.md")||
|[`ParentMenu`]("MenuItem.ParentMenu.md")||
|[`ParentMenuItem`]("MenuItem.ParentMenuItem.md")||
|[`RadioItem`]("MenuItem.RadioItem.md")||
|[`ShortCut`]("MenuItem.ShortCut.md")||
|[`SubMenu`]("MenuItem.SubMenu.md")|Reference to nested menu structure|
|[`Tag`]("MenuItem.Tag.md")|User-defined data container|
|[`Visible`]("MenuItem.Visible.md")||
|[`Widget`]("MenuItem.Widget.md")|GTK+ menu item widget reference|
|[`xdpi`]("My.Sys.Object.xdpi.md")|Horizontal DPI scaling factor (Windows, Linux, Android, Web).|
|[`ydpi`]("My.Sys.Object.ydpi.md")|Vertical DPI scaling factor (Windows, Linux, Android, Web).|

## Methods
|Name|Description|
| :------------ | :------------ |
|[`Add`]("MenuItem.Add.md")|Appends new submenu item|
|[`AddRange`]("MenuItem.AddRange.md")|Adds multiple submenu items|
|[`ClassName`]("My.Sys.Object.ClassName.md")|Used to get correct class name of the object (Windows, Linux, Android, Web).|
|[`Clear`]("MenuItem.Clear.md")|Removes all submenu items|
|[`Click`]("MenuItem.Click.md")|Programmatically triggers click action|
|[`Find`]("MenuItem.Find.md")|Searches items by name/command|
|[`FullTypeName`]("My.Sys.Object.FullTypeName.md")|Function to get any typename in the inheritance up hierarchy of the type of an instance (address: 'po') compatible with the built-in 'Object' <br>  ('baseIndex =  0' to get the typename of the instance) <br>  ('baseIndex = -1' to get the base.typename of the instance, or "" if not existing) <br>  ('baseIndex = -2' to get the base.base.typename of the instance, or "" if not existing)|
|[`IndexOf`]("MenuItem.IndexOf.md")|Returns submenu item position|
|[`Insert`]("MenuItem.Insert.md")|Inserts submenu at specified position|
|[`IsEmpty`]("My.Sys.Object.IsEmpty.md")|Returns a Boolean value indicating whether a object has been initialized (Windows, Linux, Android, Web).|
|[`MenuItemActivate`]("MenuItem.MenuItemActivate.md")|GTK+ activate signal handler|
|[`MenuItemButtonPressEvent`]("MenuItem.MenuItemButtonPressEvent.md")|GTK+ button press handler|
|[`ReadProperty`]("MenuItem.ReadProperty.md")|Loads configuration from stream|
|[`Remove`]("MenuItem.Remove.md")|Deletes specified submenu item|
|[`ScaleX`]("My.Sys.Object.ScaleX.md")|Applies horizontal DPI scaling|
|[`ScaleY`]("My.Sys.Object.ScaleY.md")|Applies vertical DPI scaling|
|[`SetInfo`]("MenuItem.SetInfo.md")|Updates Windows MENUITEMINFO|
|[`SetItemInfo`]("MenuItem.SetItemInfo.md")|Configures GTK+ menu attributes|
|[`ToString`]("MenuItem.ToString.md")||
|[`UnScaleX`]("My.Sys.Object.UnScaleX.md")|Reverses horizontal scaling|
|[`UnScaleY`]("My.Sys.Object.UnScaleY.md")|Reverses vertical scaling|
|[`WriteProperty`]("MenuItem.WriteProperty.md")|Saves configuration to stream|
## Events
|Name|Description|
| :------------ | :------------ |
|[`OnClick`]("MenuItem.OnClick.md") |Triggered when selected via click/shortcut|
## See also
Namespace: [`My.Sys.Forms`](My.Sys.Forms.md)
