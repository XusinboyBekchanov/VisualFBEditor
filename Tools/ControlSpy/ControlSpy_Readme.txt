Control Spy 2.0

Control Spy is a tool to help developers understand common controls, the application of styles to them, and their response to messages and notifications. With Control Spy, you can see instantly how different styles affect the behavior and appearance of each control, and also how you can change the state of each control by sending messages. 

Two versions of Control Spy are available, one for Comctl32.dll version 5.x and one for Comctl32.dll version 6.0 and later. ControlSpyV6.exe has an application manifest built in so that it uses the newer, themed controls, whereas ControlSpyV5.exe does not and therefore defaults to the older version.



Overview

Control Spy hosts a selected common control in the center of its application window. You can change which control is shown by selecting different controls from the list box at the left side of the window. Messages or notifications received by the control will be listed at the right side of the window as they arrive. You can enable or disable this functionality by using the Messages Received and Notifications Received check boxes.

At the bottom of the window, there are several tabs that present more functionality.



Styles

The Styles tab allows you to change the current window style of the control. Select or deselect any of the listed styles then click the Apply button to change the style of the displayed control. Alternately, you can use the Recreate button to create a new control with the selected styles. The Reset button will return the control to the default styles.

The Copy Style and Copy ExStyle buttons below the tab will copy the selected style constants to the Clipboard as a bitwise OR (|) delimited list. You can paste this list directly into your call to CreateWindowEx to provide a control in your own application with the same style.

 

Messages
The Messages tab allows you to send almost any message to a control. After selecting a message from the list box, you can enter data which is sent as the wParam and lParam parameters of the call to SendMessage. After you click Send, the message is sent to the control and any result is displayed in the text box at the bottom of the tab.

 

Size/Color
The Size/Color tab can be used to change the size of the control as well as the color of its background.

Where to Get Control Spy
You can download Control Spy from MSDN through the following links. 
- Control Spy for Comctl32.dll version 5.x
- Control Spy for Comctl32.dll version 6.x

Related Topics
- Windows Controls
- Using Windows XP Visual Styles
