#ifdef __USE_GTK4__
	#include once "cairo/cairo.bi"
	#include once "mff/gir_headers/Gir/Gtk-4.0.bi"
	#include once "mff/gir_headers/Gir/_GObjectMacros-2.0.bi"
#else
	#include once "gtk/gtk.bi"
#endif

Sub on_button_clicked cdecl (ByVal widget As GtkWidget Ptr, ByVal user_data As gpointer)
	Print "Hello, World!"
End Sub

#if defined(__USE_GTK4__) OrElse defined(__USE_GTK3__)
	Sub activate cdecl (ByVal app As GtkApplication Ptr, ByVal user_data As gpointer)
#else
	Sub activate cdecl ()
#endif
	Dim As GtkWidget Ptr win
	Dim As GtkWidget Ptr button
	Dim As GtkWidget Ptr box
	
	#if defined(__USE_GTK4__) OrElse defined(__USE_GTK3__)
		win = gtk_application_window_new(app)
		box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 5)
	#else
		win = gtk_window_new(GTK_WINDOW_TOPLEVEL)
		gtk_container_set_border_width(GTK_CONTAINER(win), 10)
		box = gtk_vbox_new(True, 5)
	#endif
	
	gtk_container_add(GTK_CONTAINER(win), box)
	gtk_window_set_title(GTK_WINDOW(win), "Hello World")
	gtk_window_set_default_size(GTK_WINDOW(win), 200, 200)
	
	button = gtk_button_new_with_label("Click Me")
	g_signal_connect(button, "clicked", G_CALLBACK(@on_button_clicked), NULL)
	
	#ifdef __USE_GTK4__
		gtk_box_pack_start(GTK_BOX(box), button)
		gtk_widget_show(win)
	#else
		gtk_box_pack_start(GTK_BOX(box), button, True, True, 0)
		gtk_widget_show_all(win)
		g_signal_connect(win, "destroy", G_CALLBACK(@gtk_main_quit), NULL)
	#endif
End Sub

#if defined(__USE_GTK4__) OrElse defined(__USE_GTK3__)
	Dim As GtkApplication Ptr myapp
	Dim As gint status
	
	myapp = gtk_application_new("com.example.GtkApplication", G_APPLICATION_FLAGS_NONE)
	g_signal_connect(myapp, "activate", G_CALLBACK(@activate), NULL)
	
	status = g_application_run(G_APPLICATION(myapp), 0, 0)
	g_object_unref(myapp)
	
	End status
#else
	gtk_init(0, 0)
	activate()
	gtk_main()
#endif
