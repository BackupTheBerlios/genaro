using System;
using Gtk;
using Glade;

// para compilar: mcs -pkg:glade-sharp -resource:gladeyxml.glade main_GladeYXml.cs

namespace pruebas_Genaro
{		
	public class GladeApp
	{
			// Info estatica de Glade
				// Direccion del fichero GUI
			private const String dirGUI = "gladeyxml.glade";
			private const String widgetPpal = "ventanaPpal";
			
			// widgets de Glade con comportamiento
		   /* [Glade.Widget]
	       Button button1;
	       
	       [Glade.Widget]
	       Label label1;
	
	*/
	       [Glade.Widget]
	       Window ventanaPpal;
	       
	                    
	    public void OnPressButtonEvent( object o, EventArgs e)
	    {
	           Console.WriteLine("Button press");
	          // label1.Text = "Mono";  
	    }
	
		public void OnDeleteEvent(object o, DeleteEventArgs args)
		{
			// hecho para implementar el delegado DeleteEventHandler que se usa para
			// el evento Gtk.Widget.DeleteEvent Event, de la clase Widget claro
			Console.WriteLine("Cerrando la aplicacion ..............................");
			Application.Quit ();
			args.RetVal = true;
		}
		
		public GladeApp (string[] args) 
	    {
	    	Application.Init();
	 
	    	// carga el fichero de GUI y activa Glade
	        //Glade.XML gxml = new Glade.XML (null, "gui.glade", "window1", null);
	        Glade.XML gxml = new Glade.XML (null, dirGUI, widgetPpal, null);
	        gxml.Autoconnect (this);
	        
	        // enlaza los widgets con sus eventos
	       // button1.Clicked += OnPressButtonEvent;
			ventanaPpal.DeleteEvent += OnDeleteEvent;
	                  
			// inicia la aplicacion
	        Application.Run();
	    }
		
		public static void Main (string[] args)
	    {
	      	new GladeApp (args);
	    }
	 
	} 
}
