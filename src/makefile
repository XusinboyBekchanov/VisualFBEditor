MFF:=../MyFbFramework
MFF=../MyFbFramework
CFLAGS:= -d __USE_MAKE__ -i $(MFF) -d __USE_GTK3__ -d _NOT_AUTORUN_FORMS_ $(GFLAG) -exx
CFLAGS= -d __USE_MAKE__ -i $(MFF) -d __USE_GTK3__ -d _NOT_AUTORUN_FORMS_ $(GFLAG) -exx
ifeq ($(OS),Windows_NT)
	RESF:=VisualFBEditor.rc
	RESF=VisualFBEditor.rc
else
	RESF:=
	RESF=
endif

VisualFBEditor: VisualFBEditor.bas Main.o Debug.o Designer.o EditControl.o frmAbout.o frmAddIns.o frmAdvancedOptions.o frmFind.o frmFindInFiles.o frmGoto.o frmOptions.o frmProjectProperties.o frmTheme.o frmTrek.o frmParameters.o frmSplash.o TabWindow.o $(MFF)/mff/Application.o $(MFF)/mff/Bitmap.o $(MFF)/mff/Brush.o $(MFF)/mff/Canvas.o $(MFF)/mff/CheckBox.o $(MFF)/mff/Clipboard.o $(MFF)/mff/ComboBoxEdit.o $(MFF)/mff/ComboBoxEx.o $(MFF)/mff/CommandButton.o $(MFF)/mff/Component.o $(MFF)/mff/ContainerControl.o $(MFF)/mff/Control.o $(MFF)/mff/Cursor.o $(MFF)/mff/Dialogs.o $(MFF)/mff/Dictionary.o $(MFF)/mff/Font.o $(MFF)/mff/Form.o $(MFF)/mff/Graphic.o $(MFF)/mff/Graphics.o $(MFF)/mff/GroupBox.o $(MFF)/mff/Icon.o $(MFF)/mff/ImageBox.o $(MFF)/mff/ImageList.o $(MFF)/mff/IniFile.o $(MFF)/mff/IntegerList.o $(MFF)/mff/Label.o $(MFF)/mff/LinkLabel.o $(MFF)/mff/List.o $(MFF)/mff/ListControl.o $(MFF)/mff/ListItems.o $(MFF)/mff/ListView.o $(MFF)/mff/Menus.o $(MFF)/mff/Object.o $(MFF)/mff/PageSetupDialog.o $(MFF)/mff/Panel.o $(MFF)/mff/Pen.o $(MFF)/mff/Picture.o $(MFF)/mff/PrintDialog.o  $(MFF)/mff/Printer.o $(MFF)/mff/PrintPreviewDialog.o $(MFF)/mff/ProgressBar.o $(MFF)/mff/RadioButton.o $(MFF)/mff/RichTextBox.o $(MFF)/mff/ScrollBarControl.o $(MFF)/mff/Splitter.o $(MFF)/mff/StatusBar.o $(MFF)/mff/SysUtils.o $(MFF)/mff/TabControl.o $(MFF)/mff/TextBox.o $(MFF)/mff/TimerComponent.o $(MFF)/mff/ToolBar.o $(MFF)/mff/ToolPalette.o $(MFF)/mff/TrackBar.o $(MFF)/mff/TreeListView.o $(MFF)/mff/TreeView.o $(MFF)/mff/UString.o $(MFF)/mff/WStringList.o
	$(FBC) -C VisualFBEditor.bas $(RESF) Main.o Debug.o Designer.o EditControl.o frmAbout.o frmAddIns.o frmAdvancedOptions.o frmFind.o frmFindInFiles.o frmGoto.o frmOptions.o frmProjectProperties.o frmParameters.o frmTheme.o frmTrek.o frmSplash.o TabWindow.o  $(MFF)/mff/Application.o $(MFF)/mff/Bitmap.o $(MFF)/mff/Brush.o $(MFF)/mff/Canvas.o $(MFF)/mff/CheckBox.o $(MFF)/mff/Clipboard.o $(MFF)/mff/ComboBoxEdit.o $(MFF)/mff/ComboBoxEx.o $(MFF)/mff/CommandButton.o $(MFF)/mff/Component.o $(MFF)/mff/ContainerControl.o $(MFF)/mff/Control.o $(MFF)/mff/Cursor.o $(MFF)/mff/Dialogs.o $(MFF)/mff/Dictionary.o $(MFF)/mff/Font.o $(MFF)/mff/Form.o $(MFF)/mff/Graphic.o $(MFF)/mff/Graphics.o $(MFF)/mff/GroupBox.o $(MFF)/mff/Icon.o $(MFF)/mff/ImageBox.o $(MFF)/mff/ImageList.o $(MFF)/mff/IniFile.o $(MFF)/mff/IntegerList.o $(MFF)/mff/Label.o $(MFF)/mff/LinkLabel.o $(MFF)/mff/List.o $(MFF)/mff/ListControl.o $(MFF)/mff/ListItems.o $(MFF)/mff/ListView.o $(MFF)/mff/Menus.o $(MFF)/mff/Object.o $(MFF)/mff/PageSetupDialog.o $(MFF)/mff/Panel.o $(MFF)/mff/Pen.o $(MFF)/mff/Picture.o $(MFF)/mff/PrintDialog.o  $(MFF)/mff/Printer.o $(MFF)/mff/PrintPreviewDialog.o $(MFF)/mff/ProgressBar.o $(MFF)/mff/RadioButton.o $(MFF)/mff/RichTextBox.o $(MFF)/mff/ScrollBarControl.o $(MFF)/mff/Splitter.o $(MFF)/mff/StatusBar.o $(MFF)/mff/SysUtils.o $(MFF)/mff/TabControl.o $(MFF)/mff/TextBox.o $(MFF)/mff/TimerComponent.o $(MFF)/mff/ToolBar.o $(MFF)/mff/ToolPalette.o $(MFF)/mff/TrackBar.o $(MFF)/mff/TreeListView.o $(MFF)/mff/TreeView.o $(MFF)/mff/UString.o $(MFF)/mff/WStringList.o $(CFLAGS) $(XFLAG) -s console

LanguageTemplate: LanguageTemplate.o
	$(FBC) -C LanguageTemplate.o -x LanguageTemplate.exe $(CFLAGS) $(XFLAG)

clean:
	rm -f *.exe *.o $(MFF)/mff/*.exe $(MFF)/mff/*.o

Main.o: Main.bas
	$(FBC) -c Main.bas $(CFLAGS)

Debug.o: Debug.bas
	$(FBC) -c Debug.bas $(CFLAGS)

Designer.o: Designer.bas
	$(FBC) -c Designer.bas $(CFLAGS)

EditControl.o: EditControl.bas
	$(FBC) -c EditControl.bas $(CFLAGS)

TabWindow.o: TabWindow.bas
	$(FBC) -c TabWindow.bas $(CFLAGS)

frmAbout.o: frmAbout.bas
	$(FBC) -c frmAbout.bas $(CFLAGS)

frmAddIns.o: frmAddIns.bas
	$(FBC) -c frmAddIns.bas $(CFLAGS)

frmAdvancedOptions.o: frmAdvancedOptions.bas
	$(FBC) -c frmAdvancedOptions.bas $(CFLAGS)

frmFind.o: frmFind.bas
	$(FBC) -c frmFind.bas $(CFLAGS)

frmFindInFiles.o: frmFindInFiles.bas
	$(FBC) -c frmFindInFiles.bas $(CFLAGS)

frmGoto.o: frmGoto.bas
	$(FBC) -c frmGoto.bas $(CFLAGS)

frmOptions.o: frmOptions.bas
	$(FBC) -c frmOptions.bas $(CFLAGS)

frmProjectProperties.o: frmProjectProperties.bas
	$(FBC) -c frmProjectProperties.bas $(CFLAGS)

frmSplash.o: frmSplash.bas
	$(FBC) -c frmSplash.bas $(CFLAGS)

frmTheme.o: frmTheme.bas
	$(FBC) -c frmTheme.bas $(CFLAGS)

frmTrek.o: frmTrek.bas
	$(FBC) -c frmTrek.bas $(CFLAGS)

frmParameters.o: frmParameters.bas
	$(FBC) -c frmParameters.bas $(CFLAGS)

LanguageTemplate.o: LanguageTemplate.bas
	$(FBC) -C LanguageTemplate.bas $(CFLAGS)
	
$(MFF)/mff/Application.o: $(MFF)/mff/Application.bas
	$(FBC) -c $(MFF)/mff/Application.bas $(CFLAGS)

$(MFF)/mff/Bitmap.o: $(MFF)/mff/Bitmap.bas
	$(FBC) -c $(MFF)/mff/Bitmap.bas $(CFLAGS)

$(MFF)/mff/Brush.o: $(MFF)/mff/Brush.bas
	$(FBC) -c $(MFF)/mff/Brush.bas $(CFLAGS)

$(MFF)/mff/Canvas.o: $(MFF)/mff/Canvas.bas
	$(FBC) -c $(MFF)/mff/Canvas.bas $(CFLAGS)

$(MFF)/mff/CheckBox.o: $(MFF)/mff/CheckBox.bas
	$(FBC) -c $(MFF)/mff/CheckBox.bas $(CFLAGS)

$(MFF)/mff/Clipboard.o: $(MFF)/mff/Clipboard.bas
	$(FBC) -c $(MFF)/mff/Clipboard.bas $(CFLAGS)

$(MFF)/mff/ComboBoxEdit.o: $(MFF)/mff/ComboBoxEdit.bas
	$(FBC) -c $(MFF)/mff/ComboBoxEdit.bas $(CFLAGS)

$(MFF)/mff/ComboBoxEx.o: $(MFF)/mff/ComboBoxEx.bas
	$(FBC) -c $(MFF)/mff/ComboBoxEx.bas $(CFLAGS)

$(MFF)/mff/CommandButton.o: $(MFF)/mff/CommandButton.bas
	$(FBC) -c $(MFF)/mff/CommandButton.bas $(CFLAGS)

$(MFF)/mff/Component.o: $(MFF)/mff/Component.bas
	$(FBC) -c $(MFF)/mff/Component.bas $(CFLAGS)

$(MFF)/mff/ContainerControl.o: $(MFF)/mff/ContainerControl.bas
	$(FBC) -c $(MFF)/mff/ContainerControl.bas $(CFLAGS)

$(MFF)/mff/Control.o: $(MFF)/mff/Control.bas
	$(FBC) -c $(MFF)/mff/Control.bas $(CFLAGS)

$(MFF)/mff/Cursor.o: $(MFF)/mff/Cursor.bas
	$(FBC) -c $(MFF)/mff/Cursor.bas $(CFLAGS)

$(MFF)/mff/Dialogs.o: $(MFF)/mff/Dialogs.bas
	$(FBC) -c $(MFF)/mff/Dialogs.bas $(CFLAGS)

$(MFF)/mff/Dictionary.o: $(MFF)/mff/Dictionary.bas
	$(FBC) -c $(MFF)/mff/Dictionary.bas $(CFLAGS)

$(MFF)/mff/Font.o: $(MFF)/mff/Font.bas
	$(FBC) -c $(MFF)/mff/Font.bas $(CFLAGS)

$(MFF)/mff/Form.o: $(MFF)/mff/Form.bas
	$(FBC) -c $(MFF)/mff/Form.bas $(CFLAGS)

$(MFF)/mff/Graphic.o: $(MFF)/mff/Graphic.bas
	$(FBC) -c $(MFF)/mff/Graphic.bas $(CFLAGS)

$(MFF)/mff/Graphics.o: $(MFF)/mff/Graphics.bas
	$(FBC) -c $(MFF)/mff/Graphics.bas $(CFLAGS)

$(MFF)/mff/GroupBox.o: $(MFF)/mff/GroupBox.bas
	$(FBC) -c $(MFF)/mff/GroupBox.bas $(CFLAGS)

$(MFF)/mff/Icon.o: $(MFF)/mff/Icon.bas
	$(FBC) -c $(MFF)/mff/Icon.bas $(CFLAGS)

$(MFF)/mff/ImageBox.o: $(MFF)/mff/ImageBox.bas
	$(FBC) -c $(MFF)/mff/ImageBox.bas $(CFLAGS)

$(MFF)/mff/ImageList.o: $(MFF)/mff/ImageList.bas
	$(FBC) -c $(MFF)/mff/ImageList.bas $(CFLAGS)

$(MFF)/mff/IniFile.o: $(MFF)/mff/IniFile.bas
	$(FBC) -c $(MFF)/mff/IniFile.bas $(CFLAGS)

$(MFF)/mff/IntegerList.o: $(MFF)/mff/IntegerList.bas
	$(FBC) -c $(MFF)/mff/IntegerList.bas $(CFLAGS)

$(MFF)/mff/Label.o: $(MFF)/mff/Label.bas
	$(FBC) -c $(MFF)/mff/Label.bas $(CFLAGS)

$(MFF)/mff/LinkLabel.o: $(MFF)/mff/LinkLabel.bas
	$(FBC) -c $(MFF)/mff/LinkLabel.bas $(CFLAGS)

$(MFF)/mff/List.o: $(MFF)/mff/List.bas
	$(FBC) -c $(MFF)/mff/List.bas $(CFLAGS)

$(MFF)/mff/ListControl.o: $(MFF)/mff/ListControl.bas
	$(FBC) -c $(MFF)/mff/ListControl.bas $(CFLAGS)

$(MFF)/mff/ListItems.o: $(MFF)/mff/ListItems.bas
	$(FBC) -c $(MFF)/mff/ListItems.bas $(CFLAGS)

$(MFF)/mff/ListView.o: $(MFF)/mff/ListView.bas
	$(FBC) -c $(MFF)/mff/ListView.bas $(CFLAGS)

$(MFF)/mff/Menus.o: $(MFF)/mff/Menus.bas
	$(FBC) -c $(MFF)/mff/Menus.bas $(CFLAGS)

$(MFF)/mff/Object.o: $(MFF)/mff/Object.bas
	$(FBC) -c $(MFF)/mff/Object.bas $(CFLAGS)

$(MFF)/mff/PageSetupDialog.o: $(MFF)/mff/PageSetupDialog.bas
	$(FBC) -c $(MFF)/mff/PageSetupDialog.bas $(CFLAGS)

$(MFF)/mff/Panel.o: $(MFF)/mff/Panel.bas
	$(FBC) -c $(MFF)/mff/Panel.bas $(CFLAGS)

$(MFF)/mff/Pen.o: $(MFF)/mff/Pen.bas
	$(FBC) -c $(MFF)/mff/Pen.bas $(CFLAGS)

$(MFF)/mff/Picture.o: $(MFF)/mff/Picture.bas
	$(FBC) -c $(MFF)/mff/Picture.bas $(CFLAGS)

$(MFF)/mff/PrintDialog.o: $(MFF)/mff/PrintDialog.bas
	$(FBC) -c $(MFF)/mff/PrintDialog.bas $(CFLAGS)

$(MFF)/mff/Printer.o: $(MFF)/mff/Printer.bas
	$(FBC) -c $(MFF)/mff/Printer.bas $(CFLAGS)

$(MFF)/mff/PrintPreviewDialog.o: $(MFF)/mff/PrintPreviewDialog.bas
	$(FBC) -c $(MFF)/mff/PrintPreviewDialog.bas $(CFLAGS)

$(MFF)/mff/ProgressBar.o: $(MFF)/mff/ProgressBar.bas
	$(FBC) -c $(MFF)/mff/ProgressBar.bas $(CFLAGS)

$(MFF)/mff/RadioButton.o: $(MFF)/mff/RadioButton.bas
	$(FBC) -c $(MFF)/mff/RadioButton.bas $(CFLAGS)

$(MFF)/mff/RichTextBox.o: $(MFF)/mff/RichTextBox.bas
	$(FBC) -c $(MFF)/mff/RichTextBox.bas $(CFLAGS)

$(MFF)/mff/ScrollBarControl.o: $(MFF)/mff/ScrollBarControl.bas
	$(FBC) -c $(MFF)/mff/ScrollBarControl.bas $(CFLAGS)

$(MFF)/mff/Splitter.o: $(MFF)/mff/Splitter.bas
	$(FBC) -c $(MFF)/mff/Splitter.bas $(CFLAGS)

$(MFF)/mff/StatusBar.o: $(MFF)/mff/StatusBar.bas
	$(FBC) -c $(MFF)/mff/StatusBar.bas $(CFLAGS)

$(MFF)/mff/SysUtils.o: $(MFF)/mff/SysUtils.bas
	$(FBC) -c $(MFF)/mff/SysUtils.bas $(CFLAGS)

$(MFF)/mff/TabControl.o: $(MFF)/mff/TabControl.bas
	$(FBC) -c $(MFF)/mff/TabControl.bas $(CFLAGS)

$(MFF)/mff/TextBox.o: $(MFF)/mff/TextBox.bas
	$(FBC) -c $(MFF)/mff/TextBox.bas $(CFLAGS)

$(MFF)/mff/TimerComponent.o: $(MFF)/mff/TimerComponent.bas
	$(FBC) -c $(MFF)/mff/TimerComponent.bas $(CFLAGS)

$(MFF)/mff/ToolBar.o: $(MFF)/mff/ToolBar.bas
	$(FBC) -c $(MFF)/mff/ToolBar.bas $(CFLAGS)

$(MFF)/mff/ToolPalette.o: $(MFF)/mff/ToolPalette.bas
	$(FBC) -c $(MFF)/mff/ToolPalette.bas $(CFLAGS)

$(MFF)/mff/TrackBar.o: $(MFF)/mff/TrackBar.bas
	$(FBC) -c $(MFF)/mff/TrackBar.bas $(CFLAGS)

$(MFF)/mff/TreeListView.o: $(MFF)/mff/TreeListView.bas
	$(FBC) -c $(MFF)/mff/TreeListView.bas $(CFLAGS)

$(MFF)/mff/TreeView.o: $(MFF)/mff/TreeView.bas
	$(FBC) -c $(MFF)/mff/TreeView.bas $(CFLAGS)

$(MFF)/mff/UString.o: $(MFF)/mff/UString.bas
	$(FBC) -c $(MFF)/mff/UString.bas $(CFLAGS)
	
$(MFF)/mff/WStringList.o: $(MFF)/mff/WStringList.bas
	$(FBC) -c $(MFF)/mff/WStringList.bas $(CFLAGS)
