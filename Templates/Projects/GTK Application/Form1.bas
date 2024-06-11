#include once "gtk/gtk.bi"

Sub on_button_clicked cdecl(ByVal widget As GtkWidget Ptr, ByVal data1 As gpointer)
    Print "Hello, World!"
End Sub

Dim As GtkWidget Ptr win
Dim As GtkWidget Ptr button
Dim As GtkWidget Ptr box

gtk_init(0, 0)

win = gtk_window_new(GTK_WINDOW_TOPLEVEL)
gtk_window_set_title(GTK_WINDOW(win), "Hello World")
gtk_window_set_default_size(GTK_WINDOW(win), 200, 200)
gtk_container_set_border_width(GTK_CONTAINER(win), 10)

#ifdef __USE_GTK3__
	box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 5)
#else
	box = gtk_vbox_new(False, 5)
#endif
gtk_container_add(GTK_CONTAINER(win), box)

button = gtk_button_new_with_label("Click Me")
g_signal_connect(button, "clicked", G_CALLBACK(@on_button_clicked), NULL)
gtk_box_pack_start(GTK_BOX(box), button, True, True, 0)

gtk_widget_show_all(win)

g_signal_connect(win, "destroy", G_CALLBACK(@gtk_main_quit), NULL)

gtk_main()
