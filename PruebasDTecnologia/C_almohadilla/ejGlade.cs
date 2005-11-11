using System;
using Gtk;
using Glade;
public class GladeApp
{
        public static void Main (string[] args)
        {
                new GladeApp (args);
        }
 
        public GladeApp (string[] args) 
        {
                Application.Init();
 
                Glade.XML gxml = new Glade.XML (null, "gui.glade", "window1", null);
                gxml.Autoconnect (this);
              
                button1.Clicked += OnPressButtonEvent;

		window1.DeleteEvent += OnDeleteEvent;
                                                            
                Application.Run();
        }
 
       [Glade.Widget]
       Button button1;
       
       [Glade.Widget]
       Label label1;

       [Glade.Widget]
       Window window1;

             
       public void OnPressButtonEvent( object o, EventArgs e)
        {
           Console.WriteLine("Button press");
           label1.Text = "Mono";  
        }

	public void OnDeleteEvent(object o, DeleteEventArgs args)
	{
		// hecho para implementar el delegado DeleteEventHandler que se usa para
		// el evento Gtk.Widget.DeleteEvent Event, de la clase Widget claro
		Console.WriteLine("Cerrando la aplicacion ..............................");
		Application.Quit ();
		args.RetVal = true;
	}
	
} 
