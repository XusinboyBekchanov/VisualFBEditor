VisualFBEditor IDE Environment

The VisualFBEditor IDE's main window includes a title bar, menu bar, and toolbar at the top; Project Explorer, Toolbox, and AI agent panels on the left; a message output panels at the bottom; and Properties and Events panels on the right.

# Title Bar:

The title bar displays the current project name, application name, and working status. VisualFBEditor operates in three states:

* Design: Allows interface and code design. Accessed by starting VisualFBEditor (showing the start page) or opening an existing project. A new project is created by selecting "Project" in the "File > New Project " menu, choosing " Project" and "Windows Application," then specifying a project name and location when saving or quitting.
* Operational: Activated by selecting "Run" or "Debug" menu. Displays the project's runtime results. Returns to the design state via the "Stop Debugging" button.
* Interrupted: Indicates a program interruption. Returns to the design state via the "Stop Debugging" button.

# Message Output panels:
The Message Output panels provide access to key functionalities through TabControl with the following components: "Output", "Problems", "Suggestions", "Find", "ToDo", "Change Log", "Immediate", "Locals", "Globals", "Procedures", "Threads",  "Watches", "Memory" and "Profiler".

## Output
**Functionality:** 
Displays build results, debug messages, and runtime logs. 

**How to Use:** 
Access via *View > Output Window* menu during compilation/debugging.  

**Notes:** Shows real-time compiler errors and execution status.

## Problems
**Functionality:** 
Lists compilation errors/warnings and code diagnostics.  

**How to Use:** 
Automatically appears after failed builds. Filter using error severity icons.  
Access via *View > Output Window* menu during compilation/debugging.  

**Notes:** Double-click entries to jump to problematic code lines.

## Find
**Functionality:** 
Shows results from *Find* and text search operations.  

**How to Use:** 
Initiate search via *Edit > Find* (Ctrl+F). 
Access via *View > Output Window* menu.
View through the Find tab.

**Notes:** 
Supports regex and whole-word matching.

## ToDo
**Functionality:**  
Tracks code annotations (e.g., `// TODO:`) and development tasks within the project.  

**How to Use:**  
Access via *View > Other Windows  > ToDo*  
View through the ToDo tab.

**Notes:** 
Custom tags can be configured in IDE settings for task tracking.

## Change Log
**Functionality:**  
Displays version history and file modification records for collaborative development.  

**How to Use:**  
Access via *View > Other Windows > Change Log*
View through the Change Log tab.

**Notes:** Supports export/import of change history for team synchronization.

## Immediate
**Functionality:** 
Test code snippet execution, including import statements. Supports variable inspection and code evaluation.

**How to Use:** 
Access via *View > Output Window* menu. (View > Other Windows  > Immediate).  
Type expressions/variables
View through the Immediate tab.

**Notes:** 
Supports variable inspection and code evaluation.

## Watches
**Functionality:** 
Monitors specified variables/expressions during debugging.  Allowing you to inspect its value and structure during debugging.  

**How to Use:** 
Access via *View > Other Windows  > Memory* during debugging sessions.  
View through the Watches tab.

**Notes:** 
Values update dynamically during execution.

## Memory
**Functionality:** 
Displays raw memory contents for debugged processes.  

**How to Use:** 
Access via *View > Other Windows  > Memory* during debugging sessions.  
View through the Memory tab.

**Notes:** 
Supports hexadecimal/custom format views.

## Threads
**Functionality:** 
Manages and inspects active threads in multithreaded apps. 
 
**How to Use:** 
View via *View > Other Windows  > Threads* during debugging.  
View through the Threads tab.  

**Notes:** 
Allows freeze/resume operations on threads.

## Procedures
**Functionality:** 
Shows call stack hierarchy during debugging.  

**How to Use:** 
Automatically populated during breakpoints. Access via *View > Other Windows  > Call Stack*.  
View through the Procedures tab.  

**Notes:** 
Double-click entries to navigate execution flow.

## Profiler
**Functionality:** 
Displays performance analysis reports from code profiling using gmon.out data.  

**How to Use:** 
Enable compilation with `-profile` option
Run program to generate .prf
View through the Profiler tab
  
**Notes:** 
Requires GNU GPROF or compatible tools for detailed callgraph analysis.

# Menu Bar:

The menu bar provides access to key functionalities through menus such as "File", "Edit", "Search", "View", "Project", "Build", "Debug", "Run", "Service", "Window" and "Help."

* File: Manages projects and files (create, open, save, recent projects).
* Edit: Provides source code editing features (cut, copy, paste, find, replace).
* View: Opens various panes (Project Explorer, Class View, Properties, Events, Image Manager, Toolbox).
* Project: Adds project components (Windows Form, User Control, Component, Module, Set as Start Project).
* Build: Compiles and links modified files, displaying warnings and errors. Recompiles the project.
* Debug: Compiles and runs the project, manages processes, handles exceptions, traces execution, sets breakpoints.
* Service: Extends functionality with tools like the Debug Process dialog and Custom Toolbox window.
* Window: Manages window operations (new window, split, hide).
* Help: Provides access to help resources.

The structure and usage of the VisualFBEditor IDE menu are detailed below. Help users clearly understand how to operate.

## File
### New Project
**Shortcut:** Ctrl+Shift+N
**Functionality:**
This option allows you to create a new project in VisualFBEditor. A project is a container that holds all the files, settings, and configurations for your FreeBasic application. When you select this option, a wizard will guide you through the process of setting up your project, such as choosing the project type, selecting the framework (MyFbFramework), and specifying the project location.
**How to Use:**
1. Click on File > New Project or press Ctrl+Shift+N.
2. A project wizard will appear. Follow the prompts to select the project type (e.g., Console Application, GUI Application, Addin Project, GTK Application, Windows Application, Android Project, Static Library, Control Library, Dynamic Library).
3. Specify a name and location for your project.
4. Click "OK" to create the project.
**Notes:**
    Make sure you have the necessary permissions to create files in the specified directory.
    TThe project structure will be automatically generated from template files in the "Templates" directory, including default files and folders.
________________________________________
### New 
**Shortcut:** Ctrl+N
**Functionality:**
This option allows you to create a new file within the current project. The file will be a FreeBasic source file (.bi or .bas) where you can write your code.
**How to Use:**
1. Click on File > New or press Ctrl+N.
2. A new editor window will open with an empty file.
3. Start writing your FreeBasic code.
4. Save the file by clicking File > Save or pressing Ctrl+S.
**Notes:**
    If you haven‘t created a project yet, the new file will be treated as an standalone file.
    It’s recommended to create a project first to organize your files better.
________________________________________
### Open...
**Shortcut:** Ctrl+O
**Functionality:**
This option allows you to open an existing FreeBasic source file or a project file. You can open single files or entire projects to edit or view them.
**How to Use:**
1. Click on File > Open... or press Ctrl+O.
2. A file dialog will appear. Navigate to the location of your FreeBasic file or project file.
3. Select the file you want to open and click "Open".
**Notes:**
    You can open multiple files at once by selecting them in the file dialog.
    If you open a project file (e.g., .vbp), the entire project will be loaded into the IDE.

### Open Project
**Shortcut:** Ctrl+Shift+O
**Functionality:**
This option allows you to open an existing project file. It is similar to the "Open..." option but is specifically designed for project files.
**How to Use:**
1. Click on File > Open Project or press Ctrl+Shift+O.
2. A file dialog will appear. Navigate to the location of your project file (e.g., .vbp).
3. Select the project file and click "Open".
4. The project will be loaded into the IDE, and you can start editing.
**Notes:**
    Make sure the project file is associated with VisualFBEditor.
    If the project uses the MyFbFramework, ensure that the framework is properly configured.

### Save Project
**Shortcut:** Ctrl+Shift+S
**Functionality:**
This option saves the current project. It updates the project file and ensures that all changes are saved.
**How to Use:**
1. Click on File > Save Project or press Ctrl+Shift+S.
2. If the project is new or hasn’t been saved before, a file dialog will appear.
3. Choose a location and name for your project file.
4. Click "Save" to save the project.
**Notes:**
    This option only saves the project file, not the individual source files.
    To save all files in the project, use File > Save All.
________________________________________
### Save Project As
**Functionality:**
This option allows you to save the current project under a new name or location. It is useful for creating a backup or starting a new version of the project.
**How to Use:**
1. Click on File > Save Project As.
2. A file dialog will appear. Navigate to the desired location and enter a new name for the project file.
3. Click "Save" to save the project under the new name.
**Notes:**
    This option creates a copy of the project file but does not affect the original project.
    Any unsaved changes in the project will be saved in the new file.
________________________________________
### Close Project
**Shortcut:** Ctrl+Shift+F4
**Functionality:**
This option closes the current project. It removes the project from the IDE, but does not delete any files from your disk.
**How to Use:**
1. Click on File > Close Project or press Ctrl+Shift+F4.
2. If there are unsaved changes in the project, a confirmation dialog will appear.
3. Choose whether to save the changes or discard them.
**Notes:**
    Closing a project does not close the IDE.
    You can reopen the project later using the "Open Project" option.

### Open Session
**Shortcut:** Ctrl+Alt+O
**Functionality:**
This option allows you to open a saved session. A session is a collection of files, folders, and editor state that you can save and reload later.
**How to Use:**
1. Click on File > Open Session or press Ctrl+Alt+O.
2. A file dialog will appear. Navigate to the location of your saved session file.
3. Select the session file and click "Open".
4. The IDE will load the session, including all associated files and settings.
**Notes:**
    Sessions are useful for switching between different work contexts.
    Session files are typically saved with a .vses extension.

### Save Session
**Shortcut:** Ctrl+Alt+S
**Functionality:**
This option saves the current session. It stores the open files, editor state, and other session-specific data.
**How to Use:**
1. Click on File > Save Session or press Ctrl+Alt+S.
2. A file dialog will appear. Choose a location and name for the session file.
3. Click "Save" to save the session.
**Notes:**
    Session files are useful for resuming work at a later time.
    You can save multiple sessions for different projects or tasks.

### Open Folder
**Shortcut:** Alt+O
**Functionality:**
This option allows you to open a folder and view its contents in the IDE. It is useful for working with multiple files in a directory.
**How to Use:**
1. Click on File > Open Folder or press Alt+O.
2. A file dialog will appear. Navigate to the folder you want to open.
3. Select the folder and click "Open".
4. The folder’s contents will be displayed in the IDE’s file explorer.
**Notes:**
    Opening a folder does not create a new project.
    You can open multiple folders at once for better organization.

### Close Folder
**Shortcut:** Alt+F4
**Functionality:**
This option closes the currently open folder in the IDE. It removes the folder’s contents from the file explorer but does not delete any files on disk.
**How to Use:**
1. Click on File > Close Folder or press Alt+F4.
2. The folder will be removed from the file explorer.
**Notes:**
    This option only affects the folder’s visibility in the IDE.
    If you want to close all folders, you can use the "Close All" option.

### Save...
**Shortcut:** Ctrl+S
**Functionality:**
This option saves the currently active file. It updates the file on disk with any changes you’ve made.
**How to Use:**
1. Click on File > Save... or press Ctrl+S.
2. If the file is new and hasn’t been saved before, a file dialog will appear.
3. Choose a location and name for the file.
4. Click "Save" to save the file.
**Notes:**
    This option only saves the current file, not the entire project.
    To save all files in the project, use File > Save All.

### Save As
**Functionality:**
This option allows you to save the current file under a new name or location. It is useful for creating backups or starting a new version of a file.
**How to Use:**
1. Click on File > Save As.
2. A file dialog will appear. Navigate to the desired location and enter a new name for the file.
3. Click "Save" to save the file under the new name.
**Notes:**
    This option creates a copy of the file but does not affect the original file.
    Any unsaved changes in the current file will be saved in the new file.

### Save All
**Shortcut:** Ctrl+Alt+Shift+S
**Functionality:**
This option saves all open files in the project. It ensures that all changes across multiple files are saved.
**How to Use:**
1. Click on File > Save All or press Ctrl+Alt+Shift+S.
2. If any files are new or haven’t been saved before, a file dialog will appear for each file.
3. Choose locations and names for any new files.
4. All files will be saved.
**Notes:**
    This option is useful when working on projects with multiple files.
    It saves time by saving all files at once instead of saving them individually.

### Close
**Functionality:**
This option closes the currently active file. It removes the file from the editor but does not delete the file from disk.
**How to Use:**
1. Click on File > Close.
2. If there are unsaved changes in the file, a confirmation dialog will appear.
3. Choose whether to save the changes or discard them.
**Notes:**
    This option only affects the currently active file.
    To close all files, use the "Close All" option.

### Close All
**Shortcut:** Ctrl+Shift+F4
Functionality:
This option closes all open files in the IDE. It removes all files from the editor but does not delete any files on disk.
How to Use:
1. Click on File > Close All or press Ctrl+Shift+F4.
2. If there are unsaved changes in any file, a confirmation dialog will appear.
3. Choose whether to save the changes or discard them.
Notes:
    This option is useful for cleaning up the IDE when switching tasks.
    Closing all files does not close the project or the IDE.

### Close Session
**Shortcut:** Ctrl+Alt+Shift+F4
**Functionality:**
This option closes the current session. It removes all open files and session-specific data.
**How to Use:**
1. Click on File > Close Session or press Ctrl+Alt+Shift+F4.
2. If there are unsaved changes in any file, a confirmation dialog will appear.
3. Choose whether to save the changes or discard them.
**Notes:**
    Closing a session does not delete any files or projects.
    You can reopen the session later using the "Open Session" option.

### Print
**Shortcut:** Ctrl+P
**Functionality:**
This option allows you to print the current file. It sends the file to the default printer.
**How to Use:**
1. Click on File > Print or press Ctrl+P.
2. A print dialog will appear.
3. Choose the print settings (e.g., printer, page range) and click "Print".
**Notes:**
    This option only prints the currently active file.
    You can also preview the print output before printing.

### Print Preview
**Functionality:**
This option displays a preview of the current file as it would appear when printed. It allows you to see the layout and formatting before printing.
**How to Use:**
1. Click on File > Print Preview.
2. A preview window will appear, showing the file’s layout on the page.
3. You can zoom in/out and navigate through the pages.
4. Click "Print" to send the file to the printer.
**Notes:**
    This option is useful for checking the formatting before printing.
    You can adjust the page settings (e.g., orientation, margins) in the print dialog.

### Page Setup
**Functionality:**
This option allows you to configure page settings for printing, such as paper size, orientation, and margins.
**How to Use:**
1. Click on File > Page Setup.
2. A page setup dialog will appear.
3. Adjust the settings as needed (e.g., select portrait or landscape orientation).
4. Click "OK" to save the settings.
**Notes:**
    Page settings are applied to the current file only.
    You can access this option before printing or while in print preview.

### File Format
This section allows you to configure the encoding and newline settings for your files.
#### Encoding: Plain text
**Functionality:**
This option sets the file encoding to plain text (ASCII).
**How to Use:**
1. Click on File > File Format > Encoding: Plain text.
2. The file will be saved or reloaded using plain text encoding.
**Notes:**
    Plain text encoding is compatible with most systems but does not support Unicode characters.
#### Encoding: Utf8
**Functionality:**
This option sets the file encoding to UTF-8. UTF-8 is a widely used encoding standard that supports Unicode characters.
**How to Use:**
1. Click on File > File Format > Encoding: Utf8.
2. The file will be saved or reloaded using UTF-8 encoding.
**Notes:**
    UTF-8 is recommended for most applications as it supports a wide range of languages.
#### Encoding: Utf8 (BOM)
**Functionality:**
This option sets the file encoding to UTF-8 with a Byte Order Mark (BOM).
**How to Use:**
1. Click on File > File Format > Encoding: Utf8 (BOM).
2. The file will be saved or reloaded with UTF-8 encoding and a BOM.
**Notes:**
    A BOM is a Unicode character at the beginning of the file that indicates the encoding.
    Some systems require a BOM for proper encoding recognition.
#### Encoding: Utf16 (BOM)
**Functionality:**
This option sets the file encoding to UTF-16 with a Byte Order Mark (BOM).
**How to Use:**
1. Click on File > File Format > Encoding: Utf16 (BOM).
2. The file will be saved or reloaded using UTF-16 encoding with a BOM.
**Notes:**
    UTF-16 is less common but can be required for certain systems or applications.
#### Encoding: Utf32 (BOM)
**Functionality:**
This option sets the file encoding to UTF-32 with a Byte Order Mark (BOM).
**How to Use:**
1. Click on File > File Format > Encoding: Utf32 (BOM).
2. The file will be saved or reloaded using UTF-32 encoding with a BOM.
**Notes:**
    UTF-32 is rarely used due to its larger file size but can be useful for specific applications.
#### Newline: Windows (CRLF)
**Functionality:**
This option sets the newline characters to Windows-style (CRLF).
**How to Use:**
1. Click on File > File Format > Newline: Windows (CRLF).
2. The file will use \r\n as the newline character.
**Notes:**
    Windows-style newlines are the default for Windows systems.
#### Newline: Linux (LF)
**Functionality:**
This option sets the newline characters to Linux-style (LF).
**How to Use:**
1. Click on File > File Format > Newline: Linux (LF).
2. The file will use \n as the newline character.
**Notes:**
    Linux-style newlines are the default for Unix-based systems.
#### Newline: MacOS (CR)
**Functionality:**
This option sets the newline characters to MacOS-style (CR).
**How to Use:**
1. Click on File > File Format > Newline: MacOS (CR).
2. The file will use \r as the newline character.
**Notes:**
    MacOS-style newlines are legacy and rarely used in modern systems.

### Recent Sessions
**Functionality:**
This option displays a list of recently opened sessions.
**How to Use:**
1. Click on File > Recent Sessions.
2. A submenu will appear with a list of recent session files.
3. Select a session file to open it.
**Notes:**
    The number of recent sessions displayed can be configured in the IDE settings.

### Recent Folders
**Functionality:**
This option displays a list of recently opened folders.
**How to Use:**
1. Click on File > Recent Folders.
2. A submenu will appear with a list of recently opened folders.
3. Select a folder to reopen it.
**Notes:**
    This feature is useful for quick access to frequently used folders.
________________________________________
### Recent Projects
**Functionality: **
This option displays a list of recently opened projects.
**How to Use: **
1. Click on File > Recent Projects.
2. A submenu will appear with a list of recently opened project files.
3. Select a project file to reopen it.
**Notes:**
    This feature is useful for switching between projects quickly.
________________________________________
### Recent Files
**Functionality:**
This option displays a list of recently opened files.
**How to Use:**
1. Click on File > Recent Files.
2. A submenu will appear with a list of recently opened files.
3. Select a file to reopen it.
**Notes:**
    This feature is useful for quick access to frequently used files.

### Command Prompt
**Functionality:**
This option opens a command prompt or terminal window within the IDE. It allows you to execute commands and scripts directly.
**How to Use:**
1. Click on File > Command Prompt.
2. A terminal window will appear at the bottom of the IDE.
3. Type your commands and press Enter to execute them.
**Notes:**
    The command prompt is useful for running build commands, executing scripts, or interacting with the file system.

### Exit
**Shortcut:** Alt+F4
**Functionality:**
This option exits the IDE.
**How to Use:**
1. Click on File > Exit or press Alt+F4.
2. If there are unsaved changes in any file, a confirmation dialog will appear.
3. Choose whether to save the changes or discard them.
4. The IDE will close.
**Notes:**
    This option closes the entire IDE, not just the current file or project.
    Make sure to save your work before exiting.

## Edit  

### Undo
**Shortcut:** "Ctrl+Z"  
**Functionality:**  
Undo allows you to revert the last change or action made in the editor. It is useful for correcting mistakes or experimenting with code without losing previous work.  

**How to Use:**  
1. Press "Ctrl+Z" or click "Edit > Undo".  
2. The most recent change will be reverted.  
3. You can undo multiple changes by pressing "Ctrl+Z" repeatedly.  

**Notes:**  
- Undo works for text changes, formatting, and even some IDE state changes.  
- The undo history is limited; exceeding the history limit will prevent older changes from being reverted.  

### Redo 
**Shortcut:** "Ctrl+Shift+Z"  
**Functionality:**  
Redo allows you to reapply the last change or action that was undone. It is useful for reverting an undo operation.  

**How to Use:**  
1. Press "Ctrl+Shift+Z" or click "Edit > Redo".  
2. The most recently undone change will be reapplied.  
3. You can redo multiple changes by pressing "Ctrl+Shift+Z" repeatedly.  

**Notes:**  
- Redo is only available after an undo operation.  
- The redo history is limited, similar to the undo history.  

### Cut Current Line 
**Shortcut:** "Ctrl+Y"  
**Functionality:**  
This option cuts the entire current line of text without selecting it. It is useful for quickly moving or deleting lines of code.  

**How to Use:**  
1. Place the cursor anywhere on the line you want to cut.  
2. Press "Ctrl+Y" or click "Edit > Cut Current Line".  
3. The line will be removed and stored in the clipboard.  

**Notes:**  
- If the line is empty, this option will still cut the newline character.  
- The cut line can be pasted using "Ctrl+V".  


### Cut 
**Shortcut:** "Ctrl+X"  
**Functionality:**  
This option cuts the selected text or the current line if no text is selected. It is useful for moving text within the document or to another document.  

**How to Use:**  
1. Select the text you want to cut.  
2. Press "Ctrl+X" or click "Edit > Cut".  
3. The selected text will be removed and stored in the clipboard.  

**Notes:**  
- If no text is selected, the entire current line will be cut.  
- The cut text can be pasted using "Ctrl+V".  

### Copy 
**Shortcut:** "Ctrl+C"  
**Functionality:**  
This option copies the selected text to the clipboard. It is useful for duplicating text within the document or for pasting into another document.  

**How to Use:**  
1. Select the text you want to copy.  
2. Press "Ctrl+C" or click "Edit > Copy".  
3. The selected text will be copied to the clipboard.  

**Notes:**  
- If no text is selected, this option will not perform any action.  
- Copied text can be pasted using "Ctrl+V".  

### Paste 
**Shortcut:** "Ctrl+V"  
**Functionality:**  
This option pastes the contents of the clipboard into the document at the cursor position. It is useful for inserting copied or cut text.  

**How to Use:**  
1. Place the cursor where you want to paste the text.  
2. Press "Ctrl+V" or click "Edit > Paste".  
3. The clipboard contents will be inserted at the cursor position.  

**Notes:**  
- Pasted text will retain its original formatting unless the target context specifies otherwise.  
- If the clipboard is empty, this option will not perform any action.  

### Single Comment 
**Shortcut:** "Ctrl+I"  
**Functionality:**  
This option adds a single-line comment to the current line of code. It is useful for quickly commenting out a line of code.  

**How to Use:**  
1. Place the cursor on the line you want to comment.  
2. Press "Ctrl+I" or click "Edit > Single Comment".  
3. The line will be prefixed with the appropriate comment syntax (e.g., "'" for FreeBasic).  

**Notes:**  
- This option works for the current line only.  
- If the line is already commented, this option will uncomment it.  

### Block Comment 
**Shortcut:** "Ctrl+Alt+I"  
**Functionality:**  
This option adds block comments around the selected text. It is useful for commenting out multiple lines of code.  

**How to Use:**  
1. Select the text you want to comment.  
2. Press "Ctrl+Alt+I" or click "Edit > Block Comment".  
3. The selected text will be wrapped with block comment syntax (e.g., "/' ... '/").  

**Notes:**  
- If no text is selected, this option will not perform any action.  
- Block comments are useful for documenting code sections.  

### Uncomment Block 
**Shortcut:** "Ctrl+Shift+I"  
**Functionality:**  
This option removes block comments from the selected text. It is useful for uncommenting previously commented code.  

**How to Use:**  
1. Select the block-commented text you want to uncomment.  
2. Press "Ctrl+Shift+I" or click "Edit > Uncomment Block".  
3. The block comment syntax will be removed.  

**Notes:**  
- This option only works on block comments.  
- If no block comment is selected, this option will not perform any action.  

### Duplicate 
**Shortcut:** "Ctrl+D"  
**Functionality:**  
This option duplicates the current line or selection. It is useful for quickly creating repeated code patterns.  

**How to Use:**  
1. Place the cursor on the line you want to duplicate, or select the text you want to duplicate.  
2. Press "Ctrl+D" or click "Edit > Duplicate".  
3. The line or selection will be duplicated below the original.  

**Notes:**  
- If no text is selected, the entire current line will be duplicated.  
- Duplicated text will be placed immediately after the original text.  

### Select All 
**Shortcut:** "Ctrl+A"  
**Functionality:**  
This option selects all text in the current document. It is useful for performing operations on the entire document.  

**How to Use:**  
1. Press "Ctrl+A" or click "Edit > Select All".  
2. All text in the document will be selected.  

**Notes:**  
- This option selects all text, including whitespace and comments.  
- You can use this option before copying or cutting to work with the entire document.  

### Indent 
**Shortcut:** "Tab"  
**Functionality:**  
This option indents the selected text or the current line. It is useful for improving code readability and structure.  

**How to Use:**  
1. Select the text you want to indent, or place the cursor on the line you want to indent.  
2. Press "Tab" or click "Edit > Indent".  
3. The selected text or line will be indented by one level.  

**Notes:**  
- Indentation is typically used for code blocks, loops, and conditional statements.  
- The indentation level can be configured in the IDE settings.  

### Outdent 
**Shortcut:** "Shift+Tab"  
**Functionality:**  
This option outdents the selected text or the current line. It is useful for reducing the indentation level of code.  

**How to Use:**  
1. Select the text you want to outdent, or place the cursor on the line you want to outdent.  
2. Press "Shift+Tab" or click "Edit > Outdent".  
3. The selected text or line will be outdented by one level.  

**Notes:**  
- Outdenting is typically used to close code blocks or reduce nesting levels.  
- The outdent level can be configured in the IDE settings.  

### Format 
**Shortcut:** "Ctrl+Tab"  
**Functionality:**  
This option formats the selected text or the entire document. It is useful for improving code readability and consistency.  

**How to Use:**  
1. Select the text you want to format, or leave the selection empty to format the entire document.  
2. Press "Ctrl+Tab" or click "Edit > Format".  
3. The selected text or document will be formatted according to the IDE's formatting rules.  

**Notes:**  
- Formatting includes indentation, spacing, and line breaks.  
- You can customize formatting rules in the IDE settings.  

### Unformat 
**Shortcut:** "Ctrl+Shift+Tab"  
**Functionality:**  
This option removes formatting from the selected text or the entire document. It is useful for reverting changes made by the format option.  

**How to Use:**  
1. Select the text you want to unformat, or leave the selection empty to unformat the entire document.  
2. Press "Ctrl+Shift+Tab" or click "Edit > Unformat".  
3. The selected text or document will have its formatting removed.  

**Notes:**  
- Unformatting does not revert changes made by manual edits.  
- This option is useful for starting over with a clean slate.  

### Format Project  
**Functionality:**  
This option formats all files in the current project. It is useful for ensuring consistency across the entire project.  

**How to Use:**  
1. Click "Edit > Format Project".  
2. The IDE will format all files in the project according to the formatting rules.  
3. A progress bar will appear during the formatting process.  

**Notes:**  
- This option may take some time to complete for large projects.  
- You can customize formatting rules in the IDE settings.  

### Unformat Project  
**Functionality:**  
This option removes formatting from all files in the current project. It is useful for reverting changes made by the format project option.  

**How to Use:**  
1. Click "Edit > Unformat Project".  
2. The IDE will remove formatting from all files in the project.  
3. A progress bar will appear during the unformatting process.  

**Notes:**  
- This option does not revert manual edits.  
- Use this option with caution, as it may remove necessary formatting.  

### Add Spaces  
**Functionality:**  
This option adds spaces to the selected text or line. It is useful for improving readability by increasing spacing.  

**How to Use:**  
1. Select the text you want to add spaces to, or place the cursor on the line you want to modify.  
2. Click "Edit > Add Spaces".  
3. Spaces will be added to the selected text or line.  

**Notes:**  
- The number of spaces added can be configured in the IDE settings.  
- This option is useful for aligning code blocks.  

### Merge Multiple Blank Lines  
**Functionality:**  
This option merges consecutive blank lines into a single blank line. It is useful for cleaning up the document and improving readability.  

**How to Use:**  
1. Select the text containing multiple blank lines, or leave the selection empty to process the entire document.  
2. Click "Edit > Merge Multiple Blank Lines".  
3. Consecutive blank lines will be reduced to a single blank line.  

**Notes:**  
- This option does not remove all blank lines, only consecutive ones.  
- It is useful for maintaining a clean and organized code structure.  

### Suggestions  
**Functionality:**  
This option provides code suggestions based on the current context. It is useful for completing code, fixing errors, and improving productivity.  

**How to Use:**  
1. Place the cursor at the location where you want a suggestion.  
2. Click "Edit > Suggestions".  
3. A dropdown list of suggestions will appear.  
4. Select a suggestion from the list to apply it.  

**Notes:**  
- Suggestions are context-aware and may vary depending on the location in the code.  
- This feature is particularly useful for new users or when working with unfamiliar code.  

### Complete Word 
**Shortcut:** "Ctrl+Space"  
**Functionality:**  
This option completes the current word based on the context. It is useful for speeding up typing and reducing errors.  

**How to Use:**  
1. Start typing a word.  
2. Press "Ctrl+Space" or click "Edit > Complete Word".  
3. A dropdown list of possible completions will appear.  
4. Select a completion from the list to insert it.  

**Notes:**  
- Word completion is based on the current context and language syntax.  
- This feature is useful for reducing typing effort and improving accuracy.  

### Parameter Info 
**Shortcut:** "Ctrl+J"  
**Functionality:**  
This option displays information about the parameters of the current function or procedure. It is useful for understanding function signatures and parameter requirements.  

**How to Use:**  
1. Place the cursor within a function or procedure call.  
2. Press "Ctrl+J" or click "Edit > Parameter Info".  
3. A tooltip will appear, showing the function's parameters and their descriptions.  

**Notes:**  
- Parameter info is only available for functions with defined parameter descriptions.  
- This feature is particularly useful for learning and debugging.  

## Error Handling  

### Numbering  
**Functionality:**  
This option adds line numbers to the current document. It is useful for referencing specific lines of code.  

**How to Use:**  
1. Click "Edit > Error Handling > Numbering".  
2. Line numbers will appear in the margin of the editor.  

**Notes:**  
- Line numbers are displayed in the editor but are not saved with the file.  
- This feature is useful for debugging and referencing code lines.  

### Macro Numbering  
**Functionality:**  
This option adds line numbers specifically for macro definitions. It is useful for referencing macro lines.  

**How to Use:**  
1. Click "Edit > Error Handling > Macro Numbering".  
2. Line numbers will appear for macro definitions in the editor.  

**Notes:**  
- Macro line numbers are displayed in the editor but are not saved with the file.  
- This feature is useful for debugging macros.  

### Remove Numbering  
**Functionality:**  
This option removes line numbers from the current document. It is useful for reverting to the default view.  

**How to Use:**  
1. Click "Edit > Error Handling > Remove Numbering".  
2. Line numbers will be removed from the editor.  

**Notes:**  
- This option only affects the visual display and does not modify the file.  
- Line numbers can be toggled on and off as needed.  

### Preprocessor Numbering  
**Functionality:**  
This option adds line numbers for preprocessor directives. It is useful for referencing preprocessor lines.  

**How to Use:**  
1. Click "Edit > Error Handling > Preprocessor Numbering".  
2. Line numbers will appear for preprocessor directives in the editor.  

**Notes:**  
- Preprocessor line numbers are displayed in the editor but are not saved with the file.  
- This feature is useful for debugging preprocessor directives.  

### Remove Preprocessor Numbering  
**Functionality:**  
This option removes line numbers from preprocessor directives. It is useful for reverting to the default view.  

**How to Use:**  
1. Click "Edit > Error Handling > Remove Preprocessor Numbering".  
2. Line numbers will be removed from preprocessor directives in the editor.  

**Notes:**  
- This option only affects the visual display and does not modify the file.  
- Preprocessor line numbers can be toggled on and off as needed.  

### Procedure Numbering  
**Functionality:**  
This option adds line numbers for procedures. It is useful for referencing procedure lines.  

**How to Use:**  
1. Click "Edit > Error Handling > Procedure Numbering".  
2. Line numbers will appear for procedures in the editor.  

**Notes:**  
- Procedure line numbers are displayed in the editor but are not saved with the file.  
- This feature is useful for debugging procedures.  

### Procedure Macro Numbering  
**Functionality:**  
This option adds line numbers for procedure macros. It is useful for referencing macro procedures.  

**How to Use:**  
1. Click "Edit > Error Handling > Procedure Macro Numbering".  
2. Line numbers will appear for procedure macros in the editor.  

**Notes:**  
- Procedure macro line numbers are displayed in the editor but are not saved with the file.  
- This feature is useful for debugging procedure macros.  

### Remove Procedure Numbering  
**Functionality:**  
This option removes line numbers from procedures. It is useful for reverting to the default view.  

**How to Use:**  
1. Click "Edit > Error Handling > Remove Procedure Numbering".  
2. Line numbers will be removed from procedures in the editor.  

**Notes:**  
- This option only affects the visual display and does not modify the file.  
- Procedure line numbers can be toggled on and off as needed.  

### Module Macro Numbering  
**Functionality:**  
This option adds line numbers for module macros. It is useful for referencing module macro lines.  

**How to Use:**  
1. Click "Edit > Error Handling > Module Macro Numbering".  
2. Line numbers will appear for module macros in the editor.  

**Notes:**  
- Module macro line numbers are displayed in the editor but are not saved with the file.  
- This feature is useful for debugging module macros.  

### Module Macro Numbering: Starts of Procedures  
**Functionality:**  
This option adds line numbers for module macros at the start of procedures. It is useful for referencing procedure starts.  

**How to Use:**  
1. Click "Edit > Error Handling > Module Macro Numbering: Starts of Procedures".  
2. Line numbers will appear for module macros at procedure starts in the editor.  

**Notes:**  
- This feature is useful for debugging procedure starts within module macros.  
- Line numbers are displayed in the editor but are not saved with the file.  

### Remove Module Numbering  
**Functionality:**  
This option removes line numbers from module macros. It is useful for reverting to the default view.  

**How to Use:**  
1. Click "Edit > Error Handling > Remove Module Numbering".  
2. Line numbers will be removed from module macros in the editor.  

**Notes:**  
- This option only affects the visual display and does not modify the file.  
- Module macro line numbers can be toggled on and off as needed.  

### Module Preprocessor Numbering  
**Functionality:**  
This option adds line numbers for module preprocessor directives. It is useful for referencing module preprocessor lines.  

**How to Use:**  
1. Click "Edit > Error Handling > Module Preprocessor Numbering".  
2. Line numbers will appear for module preprocessor directives in the editor.  

**Notes:**  
- Module preprocessor line numbers are displayed in the editor but are not saved with the file.  
- This feature is useful for debugging module preprocessor directives.  

### Remove Module Preprocessor Numbering  
**Functionality:**  
This option removes line numbers from module preprocessor directives. It is useful for reverting to the default view.  

**How to Use:**  
1. Click "Edit > Error Handling > Remove Module Preprocessor Numbering".  
2. Line numbers will be removed from module preprocessor directives in the editor.  

**Notes:**  
- This option only affects the visual display and does not modify the file.  
- Module preprocessor line numbers can be toggled on and off as needed.  

### Project Macro Numbering  
**Functionality:**  
This option adds line numbers for project macros. It is useful for referencing project macro lines.  

**How to Use:**  
1. Click "Edit > Error Handling > Project Macro Numbering".  
2. Line numbers will appear for project macros in the editor.  

**Notes:**  
- Project macro line numbers are displayed in the editor but are not saved with the file.  
- This feature is useful for debugging project macros.  

### Project Macro Numbering: Starts of Procedures  
**Functionality:**  
This option adds line numbers for project macros at the start of procedures. It is useful for referencing procedure starts.  

**How to Use:**  
1. Click "Edit > Error Handling > Project Macro Numbering: Starts of Procedures".  
2. Line numbers will appear for project macros at procedure starts in the editor.  

**Notes:**  
- This feature is useful for debugging procedure starts within project macros.  
- Line numbers are displayed in the editor but are not saved with the file.  

### Remove Project Numbering  
**Functionality:**  
This option removes line numbers from project macros. It is useful for reverting to the default view.  

**How to Use:**  
1. Click "Edit > Error Handling > Remove Project Numbering".  
2. Line numbers will be removed from project macros in the editor.  

**Notes:**  
- This option only affects the visual display and does not modify the file.  
- Project macro line numbers can be toggled on and off as needed.  

### Project Preprocessor Numbering  
**Functionality:**  
This option adds line numbers for project preprocessor directives. It is useful for referencing project preprocessor lines.  

**How to Use:**  
1. Click "Edit > Error Handling > Project Preprocessor Numbering".  
2. Line numbers will appear for project preprocessor directives in the editor.  

**Notes:**  
- Project preprocessor line numbers are displayed in the editor but are not saved with the file.  
- This feature is useful for debugging project preprocessor directives.  

### Remove Project Preprocessor Numbering  
**Functionality:**  
This option removes line numbers from project preprocessor directives. It is useful for reverting to the default view.  

**How to Use:**  
1. Click "Edit > Error Handling > Remove Project Preprocessor Numbering".  
2. Line numbers will be removed from project preprocessor directives in the editor.  

**Notes:**  
- This option only affects the visual display and does not modify the file.  
- Project preprocessor line numbers can be toggled on and off as needed.  

### On Error Resume Next  
**Functionality:**  
This option enables the "On Error Resume Next" error handling mode. It instructs the program to continue execution immediately after an error occurs.  

**How to Use:**  
1. Click "Edit > Error Handling > On Error Resume Next".  
2. The error handling mode will be set to "Resume Next".  

**Notes:**  
- This mode is useful for ignoring errors and continuing execution.  
- Use this mode with caution, as it may lead to unintended behavior if errors are not handled properly.  

### On Error Goto ...  
**Functionality:**  
This option enables the "On Error Goto" error handling mode. It instructs the program to jump to a specific label or line after an error occurs.  

**How to Use:**  
1. Click "Edit > Error Handling > On Error Goto ...".  
2. Enter the label or line number to jump to after an error.  
3. The error handling mode will be set to "Goto".  

**Notes:**  
- This mode is useful for centralizing error handling in a specific part of the code.  
- Ensure that the specified label or line exists in the code.  

### On Error Goto ... Resume Next  
**Functionality:**  
This option enables the "On Error Goto ... Resume Next" error handling mode. It instructs the program to jump to a specific label or line after an error and then resume execution from the next line.  

**How to Use:**  
1. Click "Edit > Error Handling > On Error Goto ... Resume Next".  
2. Enter the label or line number to jump to after an error.  
3. The error handling mode will be set to "Goto ... Resume Next".  

**Notes:**  
- This mode is useful for centralizing error handling while allowing the program to continue execution after the error.  
- Ensure that the specified label or line exists in the code.  

### On Local Error Goto ...  
**Functionality:**  
This option enables the "On Local Error Goto" error handling mode. It instructs the program to jump to a specific label or line within the current procedure after an error occurs.  

**How to Use:**  
1. Click "Edit > Error Handling > On Local Error Goto ...".  
2. Enter the label or line number to jump to after an error.  
3. The error handling mode will be set to "Local Goto".  

**Notes:**  
- This mode is useful for local error handling within procedures.  
- Ensure that the specified label or line exists within the current procedure.  

### On Local Error Goto ... Resume Next  
**Functionality:**  
This option enables the "On Local Error Goto ... Resume Next" error handling mode. It instructs the program to jump to a specific label or line within the current procedure after an error and then resume execution from the next line.  

**How to Use:**  
1. Click "Edit > Error Handling > On Local Error Goto ... Resume Next".  
2. Enter the label or line number to jump to after an error.  
3. The error handling mode will be set to "Local Goto ... Resume Next".  

**Notes:**  
- This mode is useful for local error handling within procedures while allowing the program to continue execution after the error.  
- Ensure that the specified label or line exists within the current procedure.  

### Remove Error Handling  
**Functionality:**  
This option removes the current error handling mode. It is useful for reverting to the default error handling behavior.  

**How to Use:**  
1. Click "Edit > Error Handling > Remove Error Handling".  
2. The error handling mode will be reset to the default.  

**Notes:**  
- This option does not affect the code itself, only the error handling mode.  
- Use this option to revert to the default error handling behavior.  

## Search  

### Find   
**Shortcut:** "Ctrl+F"  

**Functionality:**  
This option opens the "Find" dialog, allowing you to search for specific text within the current document or across multiple files. It is useful for quickly locating code snippets, keywords, or patterns.  

**How to Use:**  
1. Press "Ctrl+F" or click "Search > Find".  
2. Enter the text you want to search for in the dialog box.  
3. Use the "Find Next" button to locate the next occurrence of the text.  
4. Use the "Find Previous" button to locate the previous occurrence of the text.  
5. You can also use the "Match Case" and "Whole Word" options to refine your search.  

**Notes:**  
- The search is case-sensitive by default.  
- You can use regular expressions by enabling the "Use Regex" option.  
- The search results are highlighted in the editor for easy identification.  

### Replace   
**Shortcut:** "Ctrl+H"  

**Functionality:**  
This option opens the "Replace" dialog, allowing you to find and replace specific text within the current document or across multiple files. It is useful for updating code, renaming variables, or correcting typos.  

**How to Use:**  
1. Press "Ctrl+H" or click "Search > Replace".  
2. Enter the text you want to find in the "Find" field.  
3. Enter the text you want to replace it with in the "Replace With" field.  
4. Click "Replace" to replace the next occurrence of the text.  
5. Click "Replace All" to replace all occurrences of the text.  

**Notes:**  
- You can use regular expressions by enabling the "Use Regex" option.  
- Be cautious when using "Replace All" as it may affect unintended parts of the code.  
- The "Match Case" and "Whole Word" options can help limit the replacement to specific matches.  

### Find Next   
**Shortcut:** " F3"  

**Functionality:**  
This option finds the next occurrence of the previously searched text. It is useful for quickly navigating through multiple matches without opening the search dialog.  

**How to Use:**  
1. Press " F3" or click "Search > Find Next".  
2. The cursor will move to the next occurrence of the search text.  

**Notes:**  
- This option only works if a search has been performed previously.  
- The search options (e.g., case sensitivity, regular expressions) are retained from the last search.  

### Find Previous   
**Shortcut:** "Shift+F3"  

**Functionality:**  
This option finds the previous occurrence of the previously searched text. It is useful for navigating backward through multiple matches.  

**How to Use:**  
1. Press "Shift+F3" or click "Search > Find Previous".  
2. The cursor will move to the previous occurrence of the search text.  

**Notes:**  
- This option only works if a search has been performed previously.  
- The search options (e.g., case sensitivity, regular expressions) are retained from the last search.  

### Find In Files   
**Shortcut:** "Ctrl+Shift+F"  

**Functionality:**  
This option opens the "Find in Files" dialog, allowing you to search for specific text across multiple files in the project. It is useful for locating code snippets or patterns across the entire project.  

**How to Use:**  
1. Press "Ctrl+Shift+F" or click "Search > Find in Files".  
2. Enter the text you want to search for in the dialog box.  
3. Specify the files or folders to search in using the "Look in" field.  
4. Use the "Find" button to start the search.  
5. The results will be displayed in a list at the bottom of the dialog.  
6. Double-click a result to open the file and navigate to the match.  

**Notes:**  
- You can use wildcards (e.g., "*.fb") to specify file patterns.  
- Regular expressions can be enabled for more advanced searches.  
- The search results are displayed in a list, allowing you to navigate between matches easily.  

### Replace In Files   
**Shortcut:** "Ctrl+Shift+H"  

**Functionality:**  
This option opens the "Replace in Files" dialog, allowing you to find and replace specific text across multiple files in the project. It is useful for updating code, renaming variables, or correcting typos across the entire project.  

**How to Use:**  
1. Press "Ctrl+Shift+H" or click "Search > Replace in Files".  
2. Enter the text you want to find in the "Find" field.  
3. Enter the text you want to replace it with in the "Replace With" field.  
4. Specify the files or folders to search in using the "Look in" field.  
5. Use the "Replace" button to replace occurrences of the text.  
6. Use the "Replace All" button to replace all occurrences of the text in all files.  

**Notes:**  
- You can use wildcards (e.g., "*.fb") to specify file patterns.  
- Regular expressions can be enabled for more advanced searches.  
- Be extremely cautious when using "Replace All" as it may affect unintended parts of the code.  

### Goto   
**Shortcut:** "Ctrl+G"  

**Functionality:**  
This option opens the "Go to" dialog, allowing you to navigate to a specific line number or bookmark in the current document. It is useful for quickly jumping to a specific part of the code.  

**How to Use:**  
1. Press "Ctrl+G" or click "Search > Goto".  
2. Enter the line number or bookmark name in the dialog box.  
3. Press "Enter" to navigate to the specified location.  

**Notes:**  
- You can enter a line number or a bookmark name.  
- The cursor will move to the specified line or bookmark.  
- This feature is particularly useful for large documents.  

### Define  

**Functionality:**  
This option allows you to define a bookmark or a specific location in the code for quick navigation. It is useful for marking important sections of the code.  

**How to Use:**  
1. Place the cursor at the location you want to define.  
2. Click "Search > Define".  
3. Enter a name for the bookmark or accept the default name.  
4. The bookmark will be added to the list of defined locations.  

**Notes:**  
- Defined locations can be used with the "Goto" feature.  
- This feature is useful for organizing and navigating large codebases.  

### Bookmarks  

#### Toggle Bookmark   
**Shortcut:** "F6"  

**Functionality:**  
This option toggles a bookmark at the current cursor position. It is useful for marking lines of code for quick access.  

**How to Use:**  
1. Place the cursor at the line where you want to toggle a bookmark.  
2. Press "F6" or click "Search > Bookmarks > Toggle Bookmark".  
3. A bookmark will be added or removed at the current line.  

**Notes:**  
- Bookmarks are visual indicators in the editor margin.  
- This feature is useful for marking important lines of code.  

#### Next Bookmark   
**Shortcut:** "Ctrl+F6"  

**Functionality:**  
This option navigates to the next bookmark in the document. It is useful for quickly moving between marked lines of code.  

**How to Use:**  
1. Press "Ctrl+F6" or click "Search > Bookmarks > Next Bookmark".  
2. The cursor will move to the next bookmark in the document.  

**Notes:**  
- This feature is useful for navigating between multiple bookmarks.  
- The bookmarks must be toggled on to be navigable.  

#### Previous Bookmark  

**Functionality:**  
This option navigates to the previous bookmark in the document. It is useful for quickly moving between marked lines of code.  

**How to Use:**  
1. Click "Search > Bookmarks > Previous Bookmark".  
2. The cursor will move to the previous bookmark in the document.  

**Notes:**  
- This feature is useful for navigating between multiple bookmarks.  
- The bookmarks must be toggled on to be navigable.  

#### Clear All Bookmarks  

**Functionality:**  
This option removes all bookmarks from the current document. It is useful for resetting the bookmarks when they are no longer needed.  

**How to Use:**  
1. Click "Search > Bookmarks > Clear All Bookmarks".  
2. All bookmarks in the document will be removed.  

**Notes:**  
- This action cannot be undone.  
- Use this feature to clean up the document when bookmarks are no longer useful.  

## View  

### Code   
**Shortcut:** "Ctrl+F7"  

**Functionality:**  
This option displays the code editor, allowing you to view and edit the source code of your project. It is useful for focusing solely on the code without the form designer.  

**How to Use:**  
1. Press "Ctrl+F7" or click "View > Code".  
2. The code editor will become the active window.  

**Notes:**  
- This view is ideal for developers who prefer to work directly with code.  
- The code editor supports syntax highlighting and IntelliSense for MyFbFramework.  

### Form   
**Shortcut:** "Shift+F7"  

**Functionality:**  
This option displays the form designer, allowing you to design and edit the graphical user interface (GUI) of your application. It is useful for creating and arranging visual elements like buttons, text boxes, and other controls.  

**How to Use:**  
1. Press "Shift+F7" or click "View > Form".  
2. The form designer will become the active window.  

**Notes:**  
- This view is essential for building the user interface of your application.  
- The form designer supports drag-and-drop functionality for MyFbFramework controls.  

### Code And Form   
**Shortcut:** "Ctrl+Shift+F7"  

**Functionality:**  
This option splits the editor into two panes, displaying both the code editor and the form designer side by side. It is useful for simultaneously viewing and editing both the code and the form.  

**How to Use:**  
1. Press "Ctrl+Shift+F7" or click "View > Code And Form".  
2. The editor will split into two panes, with the code on one side and the form on the other.  

**Notes:**  
- This view is ideal for developers who need to make changes to both the code and the form simultaneously.  
- You can adjust the size of each pane by dragging the divider.  

### Goto Code/Form   
**Shortcut:** "F7"  

**Functionality:**  
This option toggles between the code editor and the form designer. It is useful for quickly switching between the two views without using the mouse.  

**How to Use:**  
1. Press "F7" or click "View > Goto Code/Form".  
2. The view will switch to the other pane (code or form).  

**Notes:**  
- This feature is useful for developers who prefer keyboard navigation.  
- The focus will be on the same line or control in the other view.  

### Collapse  

#### Current   
**Functionality:**  
This option collapses the current code block or procedure, hiding the details and showing only the header. It is useful for reducing visual clutter and focusing on the overall structure.  

**How to Use:**  
1. Place the cursor within the code block or procedure you want to collapse.  
2. Click "View > Collapse > Current".  

**Notes:**  
- Collapsed blocks are marked with a plus sign (+) or a similar indicator.  
- You can expand the block by clicking on the indicator or using the "Uncollapse" feature.  

#### All procedures   
**Functionality:**  
This option collapses all procedures in the current document, hiding the implementation details and showing only the procedure headers. It is useful for getting a high-level view of the code structure.  

**How to Use:**  
1. Click "View > Collapse > All procedures".  

**Notes:**  
- This feature is useful for navigating large code files.  
- Collapsed procedures can be expanded individually or all at once.  

#### Collapse All   
**Functionality:**  
This option collapses all code blocks and procedures in the current document, providing a compact view of the code structure. It is useful for quickly understanding the overall organization of the code.  

**How to Use:**  
1. Click "View > Collapse > Collapse All".  

**Notes:**  
- This feature is useful for large and complex projects.  
- You can expand individual blocks or all blocks as needed.  

### UnCollapse  

#### Current   
**Functionality:**  
This option expands the current collapsed code block or procedure, showing the full implementation details. It is useful for returning to the normal view after collapsing.  

**How to Use:**  
1. Place the cursor within the collapsed code block or procedure.  
2. Click "View > UnCollapse > Current".  

**Notes:**  
- This feature is the inverse of the "Collapse" feature.  
- The cursor will move to the expanded block.  

#### All procedures   
**Functionality:**  
This option expands all collapsed procedures in the current document, showing the full implementation details. It is useful for returning to the normal view after collapsing all procedures.  

**How to Use:**  
1. Click "View > UnCollapse > All procedures".  

**Notes:**  
- This feature is useful for reverting to the default view after using "Collapse All procedures".  
- All procedures will be expanded, revealing their implementation details.  

#### UnCollapseAll   
**Functionality:**  
This option expands all collapsed code blocks and procedures in the current document, providing a full view of the code. It is useful for reverting to the normal view after using "Collapse All".  

**How to Use:**  
1. Click "View > UnCollapse > UnCollapseAll".  

**Notes:**  
- This feature is useful for large and complex projects.  
- All collapsed blocks and procedures will be expanded.  

### Dark Mode  

**Functionality:**  
This option toggles the editor's theme between light and dark modes. It is useful for adjusting the visual appearance of the editor to suit your preferences.  

**How to Use:**  
1. Click "View > Dark Mode".  
2. The editor's theme will switch to the opposite mode.  

**Notes:**  
- Dark mode reduces eye strain in low-light environments.  
- The theme change applies to both the code editor and the form designer.  

### Project Explorer   
**Shortcut:** "Ctrl+R"  

**Functionality:**  
This option displays the Project Explorer window, which shows the hierarchy of files and folders in your project. It is useful for navigating and managing project files.  

**How to Use:**  
1. Press "Ctrl+R" or click "View > Project Explorer".  
2. The Project Explorer window will appear, showing the project structure.  

**Notes:**  
- You can right-click on files and folders to access context-specific menus.  
- The Project Explorer supports drag-and-drop functionality for organizing files.  

### Properties Window   
**Shortcut:** "F4"  

**Functionality:**  
This option displays the Properties window, which allows you to view and edit the properties of the currently selected control or object. It is essential for configuring visual elements and their behavior.  

**How to Use:**  
1. Press "F4" or click "View > Properties Window".  
2. The Properties window will appear, showing the properties of the selected control or object.  

**Notes:**  
- The Properties window is context-sensitive, meaning it will only show properties relevant to the selected item.  
- Changes made in the Properties window are reflected immediately in the form designer.  

### Events Window   
**Shortcut:** "Ctrl+E"  

**Functionality:**  
This option displays the Events window, which allows you to view and edit event handlers for the currently selected control or object. It is useful for adding or modifying code that responds to user interactions.  

**How to Use:**  
1. Press "Ctrl+E" or click "View > Events Window".  
2. The Events window will appear, showing the available events for the selected control or object.  

**Notes:**  
- Double-clicking an event in the Events window will take you to the corresponding code handler.  
- This feature is essential for creating interactive applications.  

### Toolbox   
**Shortcut:** "Ctrl+T"  

**Functionality:**  
This option displays the Toolbox window, which contains all the available controls and components for designing the user interface. It is useful for adding new controls to the form.  

**How to Use:**  
1. Press "Ctrl+T" or click "View > Toolbox".  
2. The Toolbox window will appear, showing the available controls.  

**Notes:**  
- You can drag and drop controls from the Toolbox to the form designer.  
- The Toolbox can be customized to include additional controls from MyFbFramework.  

### Other Windows  

**Functionality:**  
This option provides access to additional windows that are not part of the default layout. It is useful for customizing the workspace to suit your needs.  

**How to Use:**  
1. Click "View > Other Windows".  
2. A submenu will appear with a list of available windows.  
3. Select the window you want to display.  

**Notes:**  
- The available windows may vary depending on the project type and installed extensions.  
- This feature allows for a high degree of customization in the workspace.  

### Output Window  

**Functionality:**  
This option displays the Output window, which shows the results of build operations, debug output, and other messages from the IDE. It is useful for monitoring the progress of builds and debugging sessions.  

**How to Use:**  
1. Click "View > Output Window".  
2. The Output window will appear, showing the latest messages.  

**Notes:**  
- The Output window is particularly useful during the build and debug phases.  
- You can filter the output by selecting different categories from the dropdown menu.  

### Problems Window  

**Functionality:**  
This option displays the Problems window, which lists all the errors, warnings, and messages generated by the compiler or other tools. It is useful for identifying and fixing issues in the code.  

**How to Use:**  
1. Click "View > Problems Window".  
2. The Problems window will appear, showing a list of issues.  

**Notes:**  
- Double-clicking on a problem will take you to the relevant line of code.  
- This feature is essential for debugging and ensuring code quality.  

### Suggestions Window  

**Functionality:**  
This option displays the Suggestions window, which provides code completion, quick fixes, and other helpful suggestions based on the current context. It is useful for improving coding efficiency and reducing errors.  

**How to Use:**  
1. Click "View > Suggestions Window".  
2. The Suggestions window will appear, showing relevant suggestions.  

**Notes:**  
- The suggestions are context-sensitive and vary depending on the current location in the code.  
- This feature is particularly useful for developers who are new to MyFbFramework.  

### Find Window  

**Functionality:**  
This option displays the Find window, which allows you to search for specific text within the current document or across multiple files. It is useful for quickly locating code snippets or keywords.  

**How to Use:**  
1. Click "View > Find Window".  
2. The Find window will appear, allowing you to enter search criteria.  

**Notes:**  
- The Find window supports regular expressions and other advanced search options.  
- This feature is useful for navigating large codebases.  

### ToDo Window  

**Functionality:**  
This option displays the ToDo window, which lists all the ToDo comments in the current project. It is useful for tracking tasks and reminders within the code.  

**How to Use:**  
1. Click "View > ToDo Window".  
2. The ToDo window will appear, showing a list of ToDo items.  

**Notes:**  
- ToDo items are extracted from comments in the code.  
- This feature is useful for managing and tracking tasks during development.  

### Change Log Window  

**Functionality:**  
This option displays the Change Log window, which shows a history of changes made to the project files. It is useful for tracking modifications and collaborating with team members.  

**How to Use:**  
1. Click "View > Change Log Window".  
2. The Change Log window will appear, showing the history of changes.  

**Notes:**  
- The Change Log window is particularly useful in team development environments.  
- This feature helps in maintaining a record of changes for future reference.  

### Immediate Window  

**Functionality:**  
This option displays the Immediate window, which allows you to execute code snippets and view results without stopping the current debugging session. It is useful for testing and debugging purposes.  

**How to Use:**  
1. Click "View > Immediate Window".  
2. The Immediate window will appear, allowing you to enter and execute code.  

**Notes:**  
- The Immediate window is particularly useful during debugging.  
- You can use it to evaluate expressions and test code snippets.  

### Locals Window  

**Functionality:**  
This option displays the Locals window, which shows the current values of local variables during a debugging session. It is useful for monitoring variable states and debugging code.  

**How to Use:**  
1. Click "View > Locals Window".  
2. The Locals window will appear, showing the current local variables.  

**Notes:**  
- The Locals window is only available during a debugging session.  
- This feature is essential for understanding the flow of data in the application.  

### Globals Window  

**Functionality:**  
This option displays the Globals window, which shows the current values of global variables during a debugging session. It is useful for monitoring global state and debugging code.  

**How to Use:**  
1. Click "View > Globals Window".  
2. The Globals window will appear, showing the current global variables.  

**Notes:**  
- The Globals window is only available during a debugging session.  
- This feature is useful for tracking global state changes.  

### Procedures Window  

**Functionality:**  
This option displays the Procedures window, which lists all the procedures (functions, subroutines, etc.) in the current document. It is useful for navigating and organizing code.  

**How to Use:**  
1. Click "View > Procedures Window".  
2. The Procedures window will appear, showing a list of procedures.  

**Notes:**  
- Double-clicking on a procedure will take you to its definition.  
- This feature is useful for large and complex projects.  

### Threads Window  

**Functionality:**  
This option displays the Threads window, which shows the current threads and their states during a debugging session. It is useful for understanding the execution flow of multi-threaded applications.  

**How to Use:**  
1. Click "View > Threads Window".  
2. The Threads window will appear, showing the current threads.  

**Notes:**  
- The Threads window is only available during a debugging session.  
- This feature is essential for debugging multi-threaded applications.  

### Watch Window  

**Functionality:**  
This option displays the Watch window, which allows you to monitor the values of specific variables or expressions during a debugging session. It is useful for tracking data flow and debugging code.  

**How to Use:**  
1. Click "View > Watch Window".  
2. The Watch window will appear, allowing you to add and monitor variables or expressions.  

**Notes:**  
- The Watch window is only available during a debugging session.  
- This feature is essential for understanding the behavior of variables during execution.  

### Image Manager  

**Functionality:**  
This option displays the Image Manager window, which allows you to manage and organize images and other graphical resources used in the project. It is useful for maintaining a centralized repository of visual assets.  

**How to Use:**  
1. Click "View > Image Manager".  
2. The Image Manager window will appear, showing the available images.  

**Notes:**  
- The Image Manager supports common image formats like BMP, PNG, and JPG.  
- This feature is useful for projects that require a large number of visual assets.  

### Toolbars  

#### Standard   
**Checked or not**  

**Functionality:**  
This option toggles the visibility of the Standard toolbar, which contains commonly used buttons for actions like saving, opening files, and undoing/redoing changes. It is useful for customizing the workspace layout.  

**How to Use:**  
1. Click "View > Toolbars > Standard".  
2. The Standard toolbar will be toggled on or off.  

**Notes:**  
- The Standard toolbar provides quick access to frequently used actions.  
- This feature allows you to customize the workspace to suit your preferences.  

#### Edit   
**Checked or not**  

**Functionality:**  
This option toggles the visibility of the Edit toolbar, which contains buttons for editing actions like cut, copy, paste, and find/replace. It is useful for customizing the workspace layout.  

**How to Use:**  
1. Click "View > Toolbars > Edit".  
2. The Edit toolbar will be toggled on or off.  

**Notes:**  
- The Edit toolbar provides quick access to text manipulation actions.  
- This feature allows you to customize the workspace to suit your preferences.  

#### Project   
**Checked or not**  

**Functionality:**  
This option toggles the visibility of the Project toolbar, which contains buttons for project-related actions like building, running, and debugging the project. It is useful for customizing the workspace layout.  

**How to Use:**  
1. Click "View > Toolbars > Project".  
2. The Project toolbar will be toggled on or off.  

**Notes:**  
- The Project toolbar provides quick access to project management actions.  
- This feature allows you to customize the workspace to suit your preferences.  

#### Build   
**Checked or not**  

**Functionality:**  
This option toggles the visibility of the Build toolbar, which contains buttons for building, cleaning, and configuring the build process. It is useful for customizing the workspace layout.  

**How to Use:**  
1. Click "View > Toolbars > Build".  
2. The Build toolbar will be toggled on or off.  

**Notes:**  
- The Build toolbar provides quick access to build-related actions.  
- This feature allows you to customize the workspace to suit your preferences.  

#### Run   
**Checked or not**  

**Functionality:**  
This option toggles the visibility of the Run toolbar, which contains buttons for running, debugging, and configuring the execution environment. It is useful for customizing the workspace layout.  

**How to Use:**  
1. Click "View > Toolbars > Run".  
2. The Run toolbar will be toggled on or off.  

**Notes:**  
- The Run toolbar provides quick access to execution-related actions.  
- This feature allows you to customize the workspace to suit your preferences.  


## Project  
### Add Form  
**Functionality:**  
This option allows you to add a new form to your project, which will serve as a graphical user interface (GUI) for your application. Forms are essential for designing the visual elements of your program, such as buttons, text boxes, and other controls.  

**How to Use:**  
1. Click "Project > Add Form" or use the corresponding shortcut if available.  
2. A new form will be added to your project, and the form designer will become active.  

**Notes:**  
- The new form will be named "Form1.frm" by default, but you can rename it in the Properties window.  
- Forms are stored in the project directory and are listed in the Project Explorer.  
- This feature is essential for building GUI applications with VisualFBEditor and MyFbFramework.  

### Add Module  
**Functionality:**  
This option allows you to add a new module to your project, which is a source code file containing procedures, functions, and other code that can be shared across multiple forms. Modules are useful for organizing code logically and promoting code reuse.  

**How to Use:**  
1. Click "Project > Add Module" or use the corresponding shortcut if available.  
2. A new module file will be created and added to your project, and the code editor will open for you to start writing code.  

**Notes:**  
- The new module will be named "Module1.bas" by default, but you can rename it in the Project Explorer.  
- Modules can contain global variables, procedures, and other code elements that can be accessed from any form in the project.  
- This feature is useful for organizing and separating code into logical units.  

### Add Include File  
**Functionality:**  
This option allows you to add a new include file to your project, which is a text file containing declarations, definitions, and other code that can be included in multiple source files. Include files are useful for sharing code and promoting modularity.  

**How to Use:**  
1. Click "Project > Add Include File" or use the corresponding shortcut if available.  
2. A new include file will be created and added to your project, and the code editor will open for you to start writing code.  

**Notes:**  
- The new include file will be named "Include1.bi" by default, but you can rename it in the Project Explorer.  
- Include files are typically used for declaring functions, constants, and other elements that need to be shared across multiple modules or forms.  
- This feature is useful for managing code dependencies and improving maintainability.  

### Add User Control 
**Shortcut:** "Ctrl+Alt+U"
**Functionality:**  
This option allows you to add a new user control to your project, which is a custom control that can be reused across multiple forms. User controls are useful for creating complex or specialized GUI elements.  

**How to Use:**  
1. Press "Ctrl+Alt+U" or click "Project > Add User Control".  
2. A new user control file will be created and added to your project, and the form designer will become active.  

**Notes:**  
- The new user control will be named "UserControl1.usr" by default, but you can rename it in the Project Explorer.  
- User controls can contain other controls and code, allowing for the creation of complex GUI elements.  
- This feature is useful for creating reusable and modular GUI components.  

### Add Resource File  
**Functionality:**  
This option allows you to add a new resource file to your project, which is used to store non-code assets such as images, icons, and other binary data. Resource files are useful for managing the visual and multimedia elements of your application.  

**How to Use:**  
1. Click "Project > Add Resource File" or use the corresponding shortcut if available.  
2. A new resource file will be created and added to your project, and the resource editor will open for you to add and manage resources.  

**Notes:**  
- The new resource file will be named "Resource1.rc" by default, but you can rename it in the Project Explorer.  
- Resource files can be used to store images, icons, and other assets that are used by your application.  
- This feature is useful for managing and organizing the non-code assets of your project.  

### Add Manifest File  
**Functionality:**  
This option allows you to add a new manifest file to your project, which is used to specify metadata about the application, such as its name, version, and dependencies. Manifest files are useful for deploying and distributing your application.  

**How to Use:**  
1. Click "Project > Add Manifest File" or use the corresponding shortcut if available.  
2. A new manifest file will be created and added to your project, and the manifest editor will open for you to configure the application metadata.  

**Notes:**  
- The new manifest file will be named "Manifest.txt" by default, but you can rename it in the Project Explorer.  
- Manifest files are used to specify information about the application, such as its name, version, and dependencies.  
- This feature is useful for preparing your application for deployment and distribution.  

### Add From Templates...  
**Functionality:**  
This option allows you to create a new file or project based on a predefined template. Templates are useful for quickly starting a new project or adding a new file with common boilerplate code.  

**How to Use:**  
1. Click "Project > Add From Templates...".  
2. A dialog box will appear showing the available templates.  
3. Select the desired template and click OK.  
4. A new file or project will be created based on the selected template.  

**Notes:**  
- The available templates may vary depending on the project type and installed extensions.  
- This feature is useful for saving time and ensuring consistency when starting new files or projects.  
- Templates can be customized and new templates can be added to suit your specific needs.  

### Add Files...  
**Functionality:**  
This option allows you to add existing files to your project, which is useful for incorporating external resources, code, or other assets into your current project. This feature is useful for managing and organizing your project files.  

**How to Use:**  
1. Click "Project > Add Files...".  
2. A file browser dialog will appear, allowing you to select one or more files to add to your project.  
3. Select the desired files and click Open.  
4. The selected files will be added to your project and listed in the Project Explorer.  

**Notes:**  
- You can add a variety of file types, including source code files, resource files, and other assets.  
- Added files will be included in the project and can be accessed from the Project Explorer.  
- This feature is useful for incorporating external resources and existing code into your project.  
This is a separator used to organize and group menu items, making the menu more readable and user-friendly.  

### Remove  
#### Remove File From Project  
**Functionality:**  
This option allows you to remove a file from your project, which is useful for cleaning up and managing your project files. Removing a file from the project does not delete it from the disk.  

**How to Use:**  
1. Select the file you want to remove in the Project Explorer.  
2. Click "Project > Remove > Remove File From Project".  
3. The file will be removed from the project, but it will still exist on the disk.  

**Notes:**  
- Removing a file from the project does not delete it from the disk; it only removes it from the project's file list.  
- This feature is useful for managing and cleaning up your project files.  
- If you want to permanently delete the file, you need to delete it from the disk separately.  

### Open Project Folder  
**Functionality:**  
This option allows you to open the project folder in the file explorer, which is useful for managing and organizing project files outside of the IDE.  

**How to Use:**  
1. Click "Project > Open Project Folder".  
2. The project folder will open in the default file explorer.  

**Notes:**  
- This feature is useful for accessing and managing project files directly on the file system.  
- You can use this feature to copy, move, or delete files and folders outside of the IDE.  

### Import from Folder... 
**Shortcut:** "Alt+O"
**Functionality:**  
This option allows you to import files and folders from a specified location into your project, which is useful for adding multiple files at once or organizing your project structure.  

**How to Use:**  
1. Press "Alt+O" or click "Project > Import from Folder...".  
2. A file browser dialog will appear, allowing you to select a folder to import.  
3. Select the desired folder and click OK.  
4. The files and folders from the selected location will be added to your project.  

**Notes:**  
- This feature is useful for quickly adding multiple files and maintaining the folder structure.  
- Imported files will be added to the project and listed in the Project Explorer.  
- This feature is useful for managing and organizing your project files.  

### Project Properties...  
**Functionality:**  
This option allows you to configure the properties of your project, such as the target executable name, compilation options, and other project-specific settings. This is useful for customizing the behavior and output of your project.  

**How to Use:**  
1. Click "Project > Project Properties...".  
2. The Project Properties dialog will appear, allowing you to configure various project settings.  
3. Make the desired changes and click OK to save them.  

**Notes:**  
- The Project Properties dialog provides options for configuring the project name, target executable name, compilation flags, and other settings.  
- This feature is useful for customizing the behavior and output of your project.  
- Changes made in the Project Properties dialog will take effect the next time the project is built.


## Build  

### Syntax Check  
**Functionality:**  
This option allows you to check the syntax of your code without compiling it. It is useful for identifying and fixing syntax errors early in the development process.  

**How to Use:**  
1. Click "Build > Syntax Check" or use the corresponding shortcut if available.  
2. The IDE will analyze your code and display any syntax errors in the output window.  

**Notes:**  
- Syntax checking is a quick way to verify that your code is syntactically correct before proceeding to compilation.  
- This feature is especially useful for catching errors early and ensuring that your code is valid.  
- The results of the syntax check will be displayed in the output window, allowing you to address any issues before compiling.  

### Compile 
**Shortcut:** "Ctrl+F9"
**Functionality:**  
This option compiles the current file or the entire project, depending on the context. Compilation is the process of converting your source code into an executable format that the computer can run.  

**How to Use:**  
1. Click "Build > Compile" or press "Ctrl+F9".  
2. The IDE will compile the current file or project, and the results will be displayed in the output window.  

**Notes:**  
- Compilation is a necessary step before running or debugging your code.  
- If there are any syntax errors, the compilation will fail, and the errors will be displayed in the output window.  
- This feature is essential for converting your source code into an executable format.  

### Compile All 
**Shortcut:** "Ctrl+Alt+F9"
**Functionality:**  
This option compiles all the files in the current project. It is useful for ensuring that the entire project is up-to-date and ready for execution.  

**How to Use:**  
1. Click "Build > Compile All" or press "Ctrl+Alt+F9".  
2. The IDE will compile all the files in the project, and the results will be displayed in the output window.  

**Notes:**  
- Compiling all files is useful for large projects where multiple files may have been modified.  
- This feature ensures that the entire project is compiled and ready for execution or debugging.  
- If any errors are encountered during compilation, they will be displayed in the output window.  

### Build Bundle / APK  

#### Build Bundle  
**Functionality:**  
This option allows you to build a bundle file for your application. A bundle file is a package that contains all the necessary files for your application, ready for distribution or deployment.  

**How to Use:**  
1. Click "Build > Build Bundle / APK > Build Bundle".  
2. The IDE will create a bundle file containing your application and its resources.  

**Notes:**  
- The bundle file can be used for distributing your application.  
- This feature is useful for preparing your application for deployment to different platforms.  
- The bundle file will be created in the project's output directory.  

#### Build APK  
**Functionality:**  
This option allows you to build an APK (Android Package Kit) file for your application. An APK file is the standard format for distributing Android applications.  

**How to Use:**  
1. Click "Build > Build Bundle / APK > Build APK".  
2. The IDE will create an APK file containing your application and its resources.  

**Notes:**  
- The APK file can be installed on Android devices or distributed through app stores.  
- This feature is useful for deploying your application on Android platforms.  
- The APK file will be created in the project's output directory.  

### Generate Signed Bundle / APK  

#### Create Key Store  
**Functionality:**  
This option allows you to create a key store, which is a repository of security certificates and private keys used to sign your application. A key store is required for signing bundles or APKs.  

**How to Use:**  
1. Click "Build > Generate Signed Bundle / APK > Create Key Store".  
2. A dialog will appear, prompting you to provide information for the key store, such as the alias, password, and other details.  
3. Fill in the required information and click OK.  
4. The key store will be created and can be used for signing your application.  

**Notes:**  
- A key store is necessary for signing bundles or APKs.  
- The key store contains your security credentials and must be kept secure.  
- This feature is essential for preparing your application for distribution.  

#### -  
This is a separator used to organize and group menu items, making the menu more readable and user-friendly.  

#### Generate Signed Bundle  
**Functionality:**  
This option allows you to generate a signed bundle file for your application. A signed bundle is required for distributing your application through official channels.  

**How to Use:**  
1. Click "Build > Generate Signed Bundle / APK > Generate Signed Bundle".  
2. A dialog will appear, prompting you to select a key store and provide the necessary credentials.  
3. Select the key store you created and enter the required credentials.  
4. Click OK to generate the signed bundle.  

**Notes:**  
- A signed bundle is required for distributing your application through official app stores.  
- This feature is essential for preparing your application for distribution.  
- The signed bundle will be created in the project's output directory.  

#### Generate Signed APK  
**Functionality:**  
This option allows you to generate a signed APK file for your application. A signed APK is required for distributing your application through official channels.  

**How to Use:**  
1. Click "Build > Generate Signed Bundle / APK > Generate Signed APK".  
2. A dialog will appear, prompting you to select a key store and provide the necessary credentials.  
3. Select the key store you created and enter the required credentials.  
4. Click OK to generate the signed APK.  

**Notes:**  
- A signed APK is required for distributing your application through official app stores.  
- This feature is essential for preparing your application for distribution.  
- The signed APK will be created in the project's output directory.  
This is a separator used to organize and group menu items, making the menu more readable and user-friendly.  

### Make  
**Functionality:**  
This option allows you to build your project using a makefile. A makefile is a script that automates the build process, allowing you to compile and link your code in a specific order.  

**How to Use:**  
1. Click "Build > Make".  
2. The IDE will execute the makefile, and the results will be displayed in the output window.  

**Notes:**  
- The makefile must be properly configured for the build process to work correctly.  
- This feature is useful for complex projects that require a customized build process.  
- The results of the makefile execution will be displayed in the output window.  

### Make Clean  
**Functionality:**  
This option allows you to clean up the build artifacts and intermediate files generated during the build process. This is useful for starting with a fresh build or freeing up disk space.  

**How to Use:**  
1. Click "Build > Make Clean".  
2. The IDE will remove all build artifacts and intermediate files from the project directory.  

**Notes:**  
- This feature is useful for removing temporary and intermediate files that are no longer needed.  
- Cleaning the build artifacts ensures that the next build starts fresh, which can help avoid issues related to stale files.  
- The clean operation will remove all files generated during the build process.  
This is a separator used to organize and group menu items, making the menu more readable and user-friendly.  

### Parameters  
**Functionality:**  
This option allows you to configure the build parameters, such as compiler options, linker settings, and other build-related options. This is useful for customizing the build process to suit your specific needs.  

**How to Use:**  
1. Click "Build > Parameters".  
2. A dialog will appear, allowing you to configure various build parameters.  
3. Make the desired changes and click OK to save them.  

**Notes:**  
- The build parameters dialog provides options for customizing the build process, such as specifying compiler flags, linker options, and other settings.  
- This feature is useful for fine-tuning the build process and ensuring that your application is built with the desired settings.  
- Changes made to the build parameters will take effect the next time the project is built.

## Debug  

### Use Debugger  
**Functionality:**  
This option allows you to start a debugging session for your application. The debugger provides tools to step through your code, inspect variables, and identify errors.  

**How to Use:**  
1. Click "Debug > Use Debugger" or use the corresponding shortcut if available.  
2. The debugger will start, and your application will run in debug mode.  
3. Use the debug controls (Step Into, Step Over, etc.) to navigate through your code.  

**Notes:**  
- The debugger is essential for identifying and fixing runtime errors.  
- Make sure your project is compiled before starting a debug session.  
- The debugger window will display variable values, call stacks, and other relevant information.  

### Use Profiler  
**Functionality:**  
This option allows you to start a profiling session for your application. Profiling helps you identify performance bottlenecks and optimize your code.  

**How to Use:**  
1. Click "Debug > Use Profiler" or use the corresponding shortcut if available.  
2. The profiler will start, and your application will run while being monitored.  
3. The profiler will collect data on execution times, memory usage, and other performance metrics.  

**Notes:**  
- Profiling is useful for optimizing your application's performance.  
- The profiler will display detailed reports on where your application is spending most of its time.  
- Use the results to identify and optimize slow code paths.  

### Step Into 
**Shortcut:** "F8"
**Functionality:**  
This option allows you to step into a function or method during debugging. It executes the next line of code and then pauses, allowing you to inspect the function's parameters and internal logic.  

**How to Use:**  
1. While in debug mode, press "F8" or click "Debug > Step Into".  
2. The debugger will execute the current line and then pause at the start of the next function.  

**Notes:**  
- Use Step Into to trace the flow of your code through function calls.  
- This feature is useful for understanding how functions interact with each other.  
- If the current line does not contain a function call, the debugger will simply move to the next line.  

### Step Over 
**Shortcut:** "Shift+F8)"
**Functionality:**  
This option allows you to step over a function or method during debugging. It executes the entire function and then pauses at the next line, without stepping into the function's internal logic.  

**How to Use:**  
1. While in debug mode, press "Shift+F8" or click "Debug > Step Over".  
2. The debugger will execute the current line, including any function calls, and then pause at the next line.  

**Notes:**  
- Use Step Over to skip over functions you don't need to debug.  
- This feature is useful for moving quickly through code that is not suspect.  
- The results of the function call will be available, but the internal steps will not be traced.  

### Step Out 
**Shortcut:** "Ctrl+Shift+F8"
**Functionality:**  
This option allows you to step out of a function or method during debugging. It executes the remaining code in the current function and then pauses at the next line in the calling function.  

**How to Use:**  
1. While in debug mode, press "Ctrl+Shift+F8" or click "Debug > Step Out".  
2. The debugger will execute the remaining code in the current function and then pause at the next line in the calling function.  

**Notes:**  
- Use Step Out to finish executing the current function and return to the caller.  
- This feature is useful for moving up the call stack quickly.  
- The function's return value will be available for inspection after stepping out.  

### Run To Cursor  
**Functionality:**  
This option allows you to run the application until the cursor's position in the code. It is useful for testing a specific section of code without stepping through each line.  

**How to Use:**  
1. Place the cursor at the desired line in the code.  
2. Click "Debug > Run To Cursor" or use the corresponding shortcut if available.  
3. The application will run until it reaches the cursor's position and then pause.  

**Notes:**  
- Run To Cursor is a time-saving feature for testing specific code sections.  
- Make sure the cursor is placed on a line that is reachable by the application's execution flow.  
- This feature is useful for skipping over code you have already tested.  

### GDB Command  
**Functionality:**  
This option allows you to execute GDB commands directly during a debugging session. GDB is the GNU Debugger, and it provides advanced debugging capabilities.  

**How to Use:**  
1. While in debug mode, click "Debug > GDB Command".  
2. A console window will appear where you can enter GDB commands.  
3. Type the desired GDB commands and press Enter to execute them.  

**Notes:**  
- GDB commands provide low-level control over the debugging process.  
- This feature is useful for advanced users who need fine-grained control.  
- Common GDB commands include "break", "continue", "print", and "backtrace".  

### Add Watch  
**Functionality:**  
This option allows you to add a variable or expression to the watch list. Watches allow you to monitor the value of variables or expressions during debugging.  

**How to Use:**  
1. While in debug mode, click "Debug > Add Watch".  
2. Enter the variable or expression you want to watch in the dialog that appears.  
3. Click OK to add the watch.  

**Notes:**  
- Watches are useful for monitoring variable values without repeatedly typing commands.  
- You can add multiple watches to track different variables or expressions.  
- Watches are displayed in a dedicated window during debugging.  

### Toggle Breakpoint 
**Shortcut:** "F9"
**Functionality:**  
This option allows you to set or remove a breakpoint at the cursor's position. Breakpoints pause execution at a specific line of code, allowing you to inspect the state of your application.  

**How to Use:**  
1. Place the cursor at the desired line in the code.  
2. Press "F9" or click "Debug > Toggle Breakpoint".  
3. A breakpoint will be set or removed at the cursor's position.  

**Notes:**  
- Breakpoints are essential for debugging specific sections of code.  
- You can set multiple breakpoints in your code.  
- Breakpoints can be enabled or disabled during a debugging session.  

### Clear All Breakpoints 
**Shortcut:** "Ctrl+Shift+F9"
**Functionality:**  
This option allows you to clear all breakpoints in your project. It is useful for removing breakpoints that are no longer needed.  

**How to Use:**  
1. Click "Debug > Clear All Breakpoints" or press "Ctrl+Shift+F9".  
2. All breakpoints will be removed from your project.  

**Notes:**  
- Clearing breakpoints does not delete them permanently; it only disables them.  
- Use this feature to start fresh or remove unnecessary breakpoints.  
- Be cautious when clearing breakpoints, as they may have been set for critical sections of code.  

### Set Next Statement  
**Functionality:**  
This option allows you to set the next statement to be executed during debugging. It is useful for skipping over code or re-directing the flow of execution.  

**How to Use:**  
1. While in debug mode, place the cursor at the desired line in the code.  
2. Click "Debug > Set Next Statement".  
3. The debugger will set the next statement to be executed and adjust the program counter accordingly.  

**Notes:**  
- Set Next Statement is useful for skipping over problematic code or testing different execution paths.  
- This feature can be used to re-direct the flow of execution during debugging.  
- Use this feature with caution, as it can lead to unexpected behavior if not used correctly.  

### Show Next Statement  
**Functionality:**  
This option allows you to highlight and display the next statement to be executed during debugging. It helps you quickly identify where the application will continue execution.  

**How to Use:**  
1. While in debug mode, click "Debug > Show Next Statement".  
2. The next statement to be executed will be highlighted in the code editor.  

**Notes:**  
- This feature is useful for quickly identifying the next line of code to be executed.  
- It helps you navigate through your code during debugging.  
- The highlighting provides a visual cue of where execution will continue.

## Run  

### Start With Compile 
**Shortcut:** "F5"
**Functionality:**  
This option compiles your project and then runs the application immediately after compilation. It is a quick way to test your code after making changes.  

**How to Use:**  
1. Click "Run > Start With Compile" or press "F5".  
2. The IDE will compile your project.  
3. If the compilation is successful, the application will start running.  

**Notes:**  
- This is the most commonly used option for running your application during development.  
- The IDE will automatically save your changes before compiling.  
- If there are compilation errors, the application will not run, and the errors will be displayed in the output window.  

### Start 
**Shortcut:** "Ctrl+F5"
**Functionality:**  
This option runs your application without recompiling it. It is useful if you have already compiled your project and just want to test it again without making changes.  

**How to Use:**  
1. Click "Run > Start" or press "Ctrl+F5".  
2. The application will start running immediately.  

**Notes:**  
- This option only works if the project has been compiled at least once.  
- If you have made changes since the last compilation, the IDE will prompt you to compile before running.  
- This feature is useful for quick testing when you haven't made any changes to your code.  

### Break 
**Shortcut:** "Ctrl+Break"
**Functionality:**  
This option pauses the execution of your application during runtime. It is useful for stopping a running application that is not responding or needs to be inspected.  

**How to Use:**  
1. While the application is running, press "Ctrl+Break" or click "Run > Break".  
2. The application will pause execution, and you can inspect its state.  

**Notes:**  
- This feature is useful for stopping an application that is running in an infinite loop or taking too long to complete.  
- Breaking the application will not terminate it; it will simply pause it.  
- You can resume execution by clicking "Run > Start" or pressing "Ctrl+F5".  

### End  
**Functionality:**  
This option terminates the currently running application. It is useful for stopping an application that has finished running or is no longer needed.  

**How to Use:**  
1. While the application is running, click "Run > End".  
2. The application will terminate immediately.  

**Notes:**  
- This feature is useful for cleanly exiting an application that has finished its execution.  
- Ending the application will free up any system resources it was using.  
- If the application is not responding, you may need to use the "Break" option first before ending it.  


### Restart 
**Shortcut:** "Shift+F5"
**Functionality:**  
This option restarts the currently running application. It is useful for testing changes without manually stopping and starting the application again.  

**How to Use:**  
1. While the application is running, press "Shift+F5" or click "Run > Restart".  
2. The application will terminate and then restart immediately.  

**Notes:**  
- This feature is useful for quickly testing changes to your application.  
- The IDE will automatically recompile your project if changes have been made since the last compilation.  
- Restarting the application will reset its state, allowing you to test it from the beginning.



## Service  

### Add Procedure  
**Functionality:**  
This option allows you to add a new procedure to your project. A procedure can be a subroutine or function that encapsulates a specific task, making your code more modular and reusable.  

**How to Use:**  
1. Click "Service > Add Procedure" to open the Add Procedure dialog.  
2. Choose the type of procedure (Subroutine or Function) and specify its name and parameters if required.  
3. Click OK to create the procedure. The IDE will generate the necessary code template for you to fill in.  

**Notes:**  
- Procedures are useful for organizing code into logical units.  
- You can add procedures to a module or within a type (class).  
- Make sure to name your procedures descriptively to improve code readability.  

### Add Type  
**Functionality:**  
This option allows you to add a new custom type to your project. Custom types can be classes, structures, enumerations, or user-defined types (UDTs) that extend the capabilities of your application.  

**How to Use:**  
1. Click "Service > Add Type" to open the Add Type dialog.  
2. Choose the type you want to create (Class, Structure, Enumeration, etc.).  
3. Specify the name and, if applicable, the members (fields, methods, properties, etc.) of the type.  
4. Click OK to create the type. The IDE will generate the necessary code template.  

**Notes:**  
- Custom types are essential for object-oriented programming and encapsulating data with behavior.  
- Structures and classes are similar but have different behaviors in terms of initialization and scope.  
- Enumerations are useful for defining named constants.  

### Add-Ins  
**Functionality:**  
This option allows you to manage add-ins, which are external plugins that extend the functionality of the IDE. Add-ins can provide additional tools, wizards, or features to enhance your development experience.  

**How to Use:**  
1. Click "Service > Add-Ins" to open the Add-In Manager.  
2. Browse and select the add-in you want to install.  
3. Follow the installation wizard's instructions to install the add-in.  

**Notes:**  
- Add-ins can significantly enhance your productivity by providing additional tools and features.  
- Ensure that add-ins are obtained from trusted sources to avoid security risks.  
- Some add-ins may require restarting the IDE to take effect.  

### Tools...  
**Functionality:**  
This option provides access to external tools that can be used during development. These tools can include compilers, debuggers, code analyzers, and other utilities.  

**How to Use:**  
1. Click "Service > Tools..." to open the Tools window.  
2. Select the tool you want to use from the list.  
3. Configure any settings or parameters required by the tool before running it.  

**Notes:**  
- External tools can be configured to automate repetitive tasks or integrate with your development workflow.  
- Tools can be added or removed as needed to suit your development requirements.  
- Some tools may require additional installation or setup before they can be used.  

### Options  
**Functionality:**  
This option allows you to configure various settings and preferences for the IDE. These settings can include editor preferences, compiler options, debugger settings, and more.  

**How to Use:**  
1. Click "Service > Options" to open the Options dialog.  
2. Navigate through the categories and adjust the settings as desired.  
3. Click OK to save your changes.  

**Notes:**  
- The Options dialog provides fine-grained control over the IDE's behavior and appearance.  
- Changes to settings may require restarting the IDE to take effect.  
- Be cautious when modifying compiler or debugger settings, as they can affect your project's behavior.  

## Window  

### Split Horizontally  
**Functionality:**  
This option allows you to split the editor window horizontally, creating a dual-pane view where you can display and edit multiple files or different sections of the same file simultaneously.  

**How to Use:**  
1. Click "Window > Split Horizontally".  
2. The editor window will be divided into two horizontal panes.  
3. You can click on a tab in each pane to switch between open files or navigate to different parts of the same file.  

**Notes:**  
- Splitting the window horizontally is useful for comparing two sections of code or working on different parts of the same file.  
- Each pane operates independently, allowing you to scroll and navigate separately.  
- You can resize the panes by dragging the separator up or down.  

### Split Vertically  
**Functionality:**  
This option allows you to split the editor window vertically, creating a dual-pane view where you can display and edit multiple files or different sections of the same file side by side.  

**How to Use:**  
1. Click "Window > Split Vertically".  
2. The editor window will be divided into two vertical panes.  
3. You can click on a tab in each pane to switch between open files or navigate to different parts of the same file.  

**Notes:**  
- Splitting the window vertically is useful for comparing two files or working on different parts of the same file.  
- Each pane operates independently, allowing you to scroll and navigate separately.  
- You can resize the panes by dragging the separator left or right.  

## Help  

### Content 
**Shortcut:** "F1"
**Functionality:**  
This option opens the help content for the IDE, providing detailed documentation on using VisualFBEditor and the MyFbFramework. It is the primary resource for learning and troubleshooting within the IDE.  

**How to Use:**  
1. Press "F1" or click "Help > Content F1".  
2. The help documentation will open in a new window, allowing you to browse through topics, tutorials, and reference materials.  

**Notes:**  
- The help content is context-sensitive and may automatically display relevant information based on your current activity.  
- Use the search function within the help documentation to quickly find specific topics.  
- The documentation includes examples, code snippets, and best practices for using the IDE and framework.  

### Others  
**Functionality:**  
This option provides access to additional help resources or tools that are not covered under the main help content. It serves as a placeholder for future extensions or custom help resources.  

**How to Use:**  
1. Click "Help > Others".  
2. Depending on the configuration, this may open a custom help resource or display a placeholder message.  

**Notes:**  
- This option is currently a placeholder and may not provide any functionality in the initial release.  
- It can be customized or extended by developers or third-party plugins.  

### FreeBasic WiKi  
**Functionality:**  
This option opens the official FreeBasic Wiki, which contains comprehensive documentation, tutorials, and reference materials for the FreeBasic programming language.  

**How to Use:**  
1. Click "Help > FreeBasic WiKi".  
2. Your default web browser will open the FreeBasic Wiki homepage.  

**Notes:**  
- The FreeBasic Wiki is an essential resource for learning the language and its ecosystem.  
- It includes detailed documentation on language syntax, standard libraries, and best practices.  

### FreeBasic Forums  
**Functionality:**  
This option opens the official FreeBasic Forums, where you can ask questions, share knowledge, and engage with the FreeBasic community.  

**How to Use:**  
1. Click "Help > FreeBasic Forums".  
2. Your default web browser will open the FreeBasic Forums page.  

**Notes:**  
- The forums are a great place to get help with specific problems or to discuss projects.  
- Active participation in the forums can help you learn from experienced developers.  

### GitHub  
**Functionality:**  
This option opens the GitHub repository for the FreeBasic project, allowing you to explore the source code, report issues, or contribute to the project.  

**How to Use:**  
1. Click "Help > GitHub".  
2. Your default web browser will open the FreeBasic GitHub repository.  

**Notes:**  
- The GitHub repository provides access to the latest source code and development updates.  
- You can use it to submit bug reports, feature requests, or pull requests.  

### FreeBasic Repository  
**Functionality:**  
This option opens the official repository for the FreeBasic project, providing access to the latest version of the compiler, documentation, and related resources.  

**How to Use:**  
1. Click "Help > FreeBasic Repository".  
2. Your default web browser will open the [FreeBasic Repository page](https://github.com/freebasic/fbc).  

**Notes:**  
- The repository is the central location for all FreeBasic-related files and resources.  
- It is a valuable resource for developers who want to stay up-to-date with the latest developments.  

### VisualFBEditor Repository  
**Functionality:**  
This option opens the GitHub repository for the VisualFBEditor project, allowing you to explore the source code, report issues, or contribute to the IDE.  

**How to Use:**  
1. Click "Help > VisualFBEditor Repository".  
2. Your default web browser will open the [VisualFBEditor GitHub repository](https://github.com/XusinboyBekchanov/VisualFBEditor).  

**Notes:**  
- The repository provides insights into the development of the IDE and allows you to participate in its improvement.  
- You can use it to submit bug reports, feature requests, or pull requests.  

### VisualFBEditor WiKi  
**Functionality:**  
This option opens the official Wiki for VisualFBEditor, which contains documentation, tutorials, and reference materials specific to the IDE.  

**How to Use:**  
1. Click "Help > VisualFBEditor WiKi".  
2. Your default web browser will open the [VisualFBEditor Wiki homepage](https://github.com/XusinboyBekchanov/VisualFBEditor/wiki).  

**Notes:**  
- The Wiki is an essential resource for learning how to use the IDE effectively.  
- It includes guides on configuring the IDE, using its features, and troubleshooting common issues.  

### VisualFBEditor Discussions  
**Functionality:**  
This option opens the discussion forum or community board for VisualFBEditor, where you can engage with other users, ask questions, and share knowledge.  

**How to Use:**  
1. Click "Help > VisualFBEditor Discussions".  
2. Your default web browser will open the discussion page.  

**Notes:**  
- The discussion forum is a great place to connect with other developers who use the IDE.  
- It is an excellent resource for getting help with specific issues or learning from others' experiences.  

### MyFbFramework Repository  
**Functionality:**  
This option opens the GitHub repository for the MyFbFramework project, allowing you to explore the source code, report issues, or contribute to the framework.  

**How to Use:**  
1. Click "Help > MyFbFramework Repository".  
2. Your default web browser will open the [MyFbFramework GitHub repository](https://github.com/XusinboyBekchanov/MyFbFramework).  

**Notes:**  
- The repository provides access to the latest version of the framework and its documentation.  
- You can use it to submit bug reports, feature requests, or pull requests.  

### MyFbFramework WiKi  
**Functionality:**  
This option opens the official Wiki for the MyFbFramework project, which contains documentation, tutorials, and reference materials specific to the framework.  

**How to Use:**  
1. Click "Help > MyFbFramework WiKi".  
2. Your default web browser will open the [MyFbFramework Wiki homepage](https://github.com/XusinboyBekchanov/MyFbFramework/wiki) .  

**Notes:**  
- The Wiki is an essential resource for learning how to use the framework effectively.  
- It includes guides on integrating the framework into your projects, using its features, and troubleshooting common issues.  

### MyFbFramework Discussions  
**Functionality:**  
This option opens the discussion forum or community board for the MyFbFramework project, where you can engage with other developers, ask questions, and share knowledge.  

**How to Use:**  
1. Click "Help > MyFbFramework Discussions".  
2. Your default web browser will open the [discussion page](https://www.freebasic.net/forum/viewtopic.php?t=27284&start=495).  

**Notes:**  
- The discussion forum is a great place to connect with other developers who use the framework.  
- It is an excellent resource for getting help with specific issues or learning from others' experiences.  

### Tip of the Day  
**Functionality:**  
This option displays a helpful tip or trick for using the IDE or the MyFbFramework. Tips are displayed in a dialog box and can be closed or navigated through.  

**How to Use:**  
1. Click "Help > Tip of the Day".  
2. A dialog box will appear with a helpful tip.  
3. You can click "Next Tip" to view more tips or "Close" to dismiss the dialog.  

**Notes:**  
- Tips are designed to help you discover new features and improve your productivity.  
- The tips are context-sensitive and may vary based on your current activity in the IDE.  

### About  
**Functionality:**  
This option displays information about the IDE, including the version number, build date, and copyright information. It may also provide links to the official website or other resources.  

**How to Use:**  
1. Click "Help > About".  
2. An "About" dialog box will appear with detailed information about the IDE.  
3. You can click "OK" to close the dialog.  

**Notes:**  
- The "About" dialog may include a button or link to check for updates.  
- It is useful for verifying the version of the IDE you are using.  


## Pop-up Menu Project

### Set as Main  
**Functionality:**  
This option sets the currently selected file as the main program. The main program is the entry point for your application when it is run.  

**How to Use:**  
1. Right-click on the title bar of the editor window to open the pop-up menu.  
2. Click "Set as Main".  
3. The selected file will be designated as the main program.  

**Notes:**  
- Only one file can be set as the main program at a time.  
- Setting a file as the main program is essential for running and debugging your application.  

### Reload History Code  
**Functionality:**  
This option reloads the code from the history, allowing you to revert to a previous version of your file. It is useful for undoing changes or recovering lost work.  

**How to Use:**  
1. Right-click on the title bar of the editor window to open the pop-up menu.  
2. Click "Reload History Code".  
3. A dialog will appear with a list of previously saved versions of the file.  
4. Select the version you want to reload and click "OK".  

**Notes:**  
- The IDE automatically saves your work at regular intervals, creating a history of changes.  
- Reloading history code does not delete your current changes but allows you to revert to a previous state.  

### Close  
**Functionality:**  
This option closes the currently selected file or tab, removing it from the editor window.  

**How to Use:**  
1. Right-click on the title bar of the editor window to open the pop-up menu.  
2. Click "Close".  
3. The selected file will be closed.  

**Notes:**  
- If you have unsaved changes, the IDE will prompt you to save the file before closing it.  
- Closing a file does not delete it from your project; it only removes it from the editor window.  

### Close All Without Current  
**Functionality:**  
This option closes all files except the currently selected one, allowing you to focus on the file you are working on.  

**How to Use:**  
1. Right-click on the title bar of the editor window to open the pop-up menu.  
2. Click "Close All Without Current".  
3. All files except the currently selected one will be closed.  

**Notes:**  
- This option is useful for decluttering the editor window and focusing on the current task.  
- If any files have unsaved changes, the IDE will prompt you to save them before closing.  

### Close All  
**Functionality:**  
This option closes all open files in the editor window, allowing you to start fresh or switch to a different project.  

**How to Use:**  
1. Right-click on the title bar of the editor window to open the pop-up menu.  
2. Click "Close All".  
3. All open files will be closed.  

**Notes:**  
- If any files have unsaved changes, the IDE will prompt you to save them before closing.  
- Closing all files does not exit the IDE; it only clears the editor window.  

### Split Up  
**Functionality:**  
This option splits the editor window into two panes, with the current file appearing in both panes. This allows you to view and edit different sections of the same file simultaneously.  

**How to Use:**  
1. Right-click on the title bar of the editor window to open the pop-up menu.  
2. Click "Split Up".  
3. The editor window will be divided into two panes, both displaying the same file.  

**Notes:**  
- Splitting the window is useful for comparing or working on different parts of the same file.  
- Each pane operates independently, allowing you to scroll and navigate separately.  

### Split Down  
**Functionality:**  
This option splits the editor window into two panes, with the current file appearing in both panes. This allows you to view and edit different sections of the same file simultaneously.  

**How to Use:**  
1. Right-click on the title bar of the editor window to open the pop-up menu.  
2. Click "Split Down".  
3. The editor window will be divided into two panes, both displaying the same file.  

**Notes:**  
- Splitting the window is useful for comparing or working on different parts of the same file.  
- Each pane operates independently, allowing you to scroll and navigate separately.  

### Split Left  
**Functionality:**  
This option splits the editor window into two panes, with the current file appearing in both panes. This allows you to view and edit different sections of the same file simultaneously.  

**How to Use:**  
1. Right-click on the title bar of the editor window to open the pop-up menu.  
2. Click "Split Left".  
3. The editor window will be divided into two panes, both displaying the same file.  

**Notes:**  
- Splitting the window is useful for comparing or working on different parts of the same file.  
- Each pane operates independently, allowing you to scroll and navigate separately.  

### Split Right  
**Functionality:**  
This option splits the editor window into two panes, with the current file appearing in both panes. This allows you to view and edit different sections of the same file simultaneously.  

**How to Use:**  
1. Right-click on the title bar of the editor window to open the pop-up menu.  
2. Click "Split Right".  
3. The editor window will be divided into two panes, both displaying the same file.  

**Notes:**  
- Splitting the window is useful for comparing or working on different parts of the same file.  
- Each pane operates independently, allowing you to scroll and navigate separately.  

### Split Horizontally  
**Functionality:**  
This option splits the editor window horizontally, creating two panes where you can display and edit different sections of the same file or different files.  

**How to Use:**  
1. Right-click on the title bar of the editor window to open the pop-up menu.  
2. Click "Split Horizontally".  
3. The editor window will be divided into two horizontal panes.  

**Notes:**  
- Splitting the window horizontally is useful for comparing or working on different parts of the same file.  
- Each pane operates independently, allowing you to scroll and navigate separately.  

### Split Vertically  
**Functionality:**  
This option splits the editor window vertically, creating two panes where you can display and edit different sections of the same file or different files.  

**How to Use:**  
1. Right-click on the title bar of the editor window to open the pop-up menu.  
2. Click "Split Vertically".  
3. The editor window will be divided into two vertical panes.  

**Notes:**  
- Splitting the window vertically is useful for comparing or working on different parts of the same file.  
- Each pane operates independently, allowing you to scroll and navigate separately.  

## Pop-up Menu Debugging

### Variable Dump  
**Functionality:**  
This option dumps the contents of a variable to the output window, allowing you to inspect its value and structure during debugging.  

**How to Use:**  
1. Right-click the title bar of the output message form at the bottom of the editor window to open the pop-up menu.
2. Click "Variable Dump".  
3. Select the variable you want to inspect from the dialog that appears.  
4. The variable's value and structure will be displayed in the output window.  

**Notes:**  
- Variable dumping is a useful debugging tool for inspecting the state of your variables.  
- It can display complex data structures, including arrays, objects, and user-defined types.  

### Pointed data Dump  
**Functionality:**  
This option dumps the data pointed to by the current cursor position to the output window, allowing you to inspect the memory contents at that location.  

**How to Use:**  
1. Right-click the title bar of the output message form at the bottom of the editor window to open the pop-up menu.
2. Click "Pointed data Dump".  
3. The data at the current cursor position will be displayed in the output window.  

**Notes:**  
- This option is particularly useful for low-level debugging and inspecting memory contents.  
- It can display raw memory data in various formats, such as hexadecimal or ASCII.  

### Show String  
**Functionality:**  
This option displays the contents of a string variable in a dialog box, allowing you to inspect its value during debugging.  

**How to Use:**  
1. Right-click the title bar of the output message form at the bottom of the editor window to open the pop-up menu.
2. Click "Show String".  
3. Select the string variable you want to inspect from the dialog that appears.  
4. The string's value will be displayed in a dialog box.  

**Notes:**  
- This option is useful for inspecting long strings that may not fit in the output window.  
- The dialog box allows you to scroll through the string if it is too long to display in full.  

### Show/Expand Variable  
**Functionality:**  
This option expands a variable to display its full structure, including all its members and nested data. It is useful for inspecting complex data types during debugging.  

**How to Use:**  
1. Right-click the title bar of the output message form at the bottom of the editor window to open the pop-up menu.
2. Click "Show/Expand Variable".  
3. Select the variable you want to inspect from the dialog that appears.  
4. The variable's structure will be expanded and displayed in the output window.  

**Notes:**  
- This option is particularly useful for inspecting objects, structures, and other complex data types.  
- Expanding a variable allows you to drill down into its members and nested data.  

## Pop-up Menu Debugging procedure
### Memory Dump  
**Functionality:**  
This option dumps the contents of a block of memory to the output window, allowing you to inspect raw memory data during debugging.  

**How to Use:**  
1. Right-click the title bar "procedure" of the output message form at the bottom of the editor window to open the pop-up menu.
2. Click "Memory Dump".  
3. Specify the memory address and length of the block you want to dump in the dialog that appears.  
4. The memory contents will be displayed in the output window.  

**Notes:**  
- Memory dumping is a low-level debugging tool for inspecting raw memory contents.  
- It can display data in various formats, such as hexadecimal or ASCII.  

### Locate procedure (source)  
**Functionality:**  
This option locates the definition of a procedure (function or subroutine) in the source code, allowing you to quickly navigate to its implementation.  

**How to Use:**  
1. Right-click the title bar "procedure" of the output message form at the bottom of the editor window to open the pop-up menu.
2. Click "Locate procedure (source)".  
3. A dialog will appear where you can enter the name of the procedure you want to locate.  
4. The IDE will navigate to the definition of the procedure in the source code.  

**Notes:**  
- This option is useful for quickly finding the implementation of a procedure.  
- It can save time when working with large or complex projects.  

### Toggle sort by module or by procedure  
**Functionality:**  
This option toggles the sorting of procedures within a module, allowing you to organize them by module or by procedure name.  

**How to Use:**  
1. Right-click the title bar "procedure" of the output message form at the bottom of the editor window to open the pop-up menu.
2. Click "Toggle sort by module or by procedure".  
3. The procedures will be reorganized according to the selected sorting criteria.  

**Notes:**  
- Sorting by module groups procedures by their containing module.  
- Sorting by procedure name organizes procedures alphabetically.  