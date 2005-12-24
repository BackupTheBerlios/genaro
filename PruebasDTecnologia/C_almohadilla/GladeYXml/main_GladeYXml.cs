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
			private const String dirFicheroRc = "estilo.rc";
			
			// widgets de Glade con comportamiento
		   /* [Glade.Widget]
	       Button button1;
	       
	       [Glade.Widget]
	       Label label1;
	
	*/
	       [Glade.Widget]
	       Window ventanaPpal;
	       //ventanaPpal.Name = "ventanaPpal";    //nombre de la ventana para el fichero rc
	       //Gtk.Window window = new Gtk.Window("Ventana Principal");
 		   //window.Name = "main window";
 		   
		[Glade.Widget]
 		TextView textview1;

		[Glade.Widget]
		Frame frame1;
	       
	                    
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

	        //carga el fichero de estilo
	    	Gtk.Rc.Parse(dirFicheroRc);
	        
	    	//nombra los Widgets para el estilo
	        ventanaPpal.Name = "ventanaPpal"; 
	        textview1.Name = "etiquetaArriba";
		frame1.Name = "framePpal";
	    	      
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
