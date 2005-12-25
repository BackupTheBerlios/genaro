using System;
using Gtk;
using Glade;
using System.Xml;

// para compilar: mcs -pkg:glade-sharp -resource:gladeyxml.glade main_GladeYXml.cs

namespace pruebas_Genaro
{		
	
	public class Conversacion
	{
		private string remitente;
		private string destinatario;
		
		public string Remitente
    	{
        	get	{ return remitente; }
        	set { remitente = value; }
    	}
		
		public string Destinatario
    	{
        	get	{ return destinatario; }
        	set { destinatario = value; }
    	}
		
		public override string ToString()
		{
			string retorno = "";
			retorno += "[remitente="+ remitente + "]";
			retorno += "[destinatario="+ destinatario + "]";
			return retorno;
		}
		
		public string ToStringFormat()
		{
			string retorno = "Conversacion";
			retorno += "\n-----------------------------";
			retorno += "\nRemitente: " + remitente ;
			retorno += "\ndestinatario: "+ destinatario ;
			return retorno;
		}
	}
	
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
		Frame frame1;
		
		[Glade.Widget]
 		TextView textview1;
		
	    [Glade.Widget]
 		TextView textview2;
   
 		[Glade.Widget]
		Button button5;
		
		private void SaltaBlancos(XmlTextReader reader)
		{
			while (!reader.EOF && reader.NodeType == XmlNodeType.Whitespace)
			{	//se mueve al siguiente nodo
				reader.Read ();	
			}
		}
		
		private Conversacion LeeXml_direcciones(XmlTextReader reader)
		{// supongo que estoy al principio del documento, tras el MoveToContent
			
			Conversacion retorno = new Conversacion();
			
				//para
			reader.Read ();	// me salto el inicio: <conversacion>
			SaltaBlancos(reader);
				//Console.WriteLine ("[tipo: {0}, nombre: {1}, valor: {2}]",reader.NodeType,reader.Name, reader.Value);
			if (reader.Name != "para")
			{
				throw new ApplicationException("error de parseo de XML: se esperaba \'para\'");
			}			
			reader.Read ();
				//Console.WriteLine ("[tipo: {0}, nombre: {1}, valor: {2}]",reader.NodeType,reader.Name, reader.Value);
			retorno.Destinatario = reader.Value;
			
				//de
			reader.Read ();	// sale del Text de <para>
			reader.Read (); // sale del EndElement que es </para>
			SaltaBlancos(reader);
				//Console.WriteLine ("[tipo: {0}, nombre: {1}, valor: {2}]",reader.NodeType,reader.Name, reader.Value);
			if (reader.Name != "de")
			{
				throw new ApplicationException("error de parseo de XML: se esperaba \'de\'");
			}			
			reader.Read ();
				//Console.WriteLine ("[tipo: {0}, nombre: {1}, valor: {2}]",reader.NodeType,reader.Name, reader.Value);
			retorno.Remitente = reader.Value;
		
			return retorno;
		}
				
		private void LeeXML(string fichero) 
		{
			XmlTextReader reader = new XmlTextReader (fichero);
			TextBuffer buffer = textview2.Buffer;
			Conversacion conversacion;
			
			Console.WriteLine("\n-------------------------------\n\n\tIniciando lectura de fichero Xml [{0}]", fichero);
			
			reader.Read ();			
			reader.MoveToContent ();	// se coloca en el contenido del xml
			conversacion = LeeXml_direcciones(reader);
			Console.WriteLine("\t\tDirecciones de la conversacion: "+conversacion.ToString());
			reader.Close();
			
			buffer.InsertAtCursor(conversacion.ToStringFormat());
			//buffer.InsertAtCursor(reader.NodeType);
		}
	            
		private void MuestraTodoXML (string fichero)
		{
			XmlTextReader reader = new XmlTextReader (fichero);
			
			Console.WriteLine("\n-------------------------------\n\n\tIniciando lectura de fichero Xml [{0}], MUESTRA TODO EL CONTENIDO", fichero);
			reader.Read ();			
			// Lo muestra todo por consola
			Console.WriteLine(reader.NodeType);	//muestra la declaracion del xml
			reader.MoveToContent ();
			Console.WriteLine ("[tipo: {0}, nombre: {1}, valor: {2}]",reader.NodeType,reader.Name, reader.Value); //(Element, conversacion)
			while (!reader.EOF)
			{	//se mueve al siguiente nodo y muestra su info
				reader.Read ();	
				Console.WriteLine ("[tipo: {0}, nombre: {1}, valor: {2}]",reader.NodeType,reader.Name, reader.Value); 
			}			
			reader.Close();
		}
		
	    private void OnPressButtonEvent( object o, EventArgs e)
	    {
	    	Console.WriteLine("\nPulsado boton: Ordenando lectura de fichero Xml");
	    	//MuestraTodoXML("ej_conversacion.xml");  
	        LeeXML("ej_conversacion.xml");  
	    }
	    
		private void OnDeleteEvent(object o, DeleteEventArgs args)
		{
			// hecho para implementar el delegado DeleteEventHandler que se usa para
			// el evento Gtk.Widget.DeleteEvent Event, de la clase Widget claro
			Console.WriteLine("\n\n\nCerrando la aplicacion ..............................");
			Application.Quit ();
			args.RetVal = true;
		}
		
		private GladeApp (string[] args) 
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
	       	ventanaPpal.DeleteEvent += OnDeleteEvent;
	       	button5.Clicked += OnPressButtonEvent;
	                  
			// inicia la aplicacion
	        Application.Run();
	    }
		
		public static void Main (string[] args)
	    {
			/*Conversacion c = new Conversacion();
			Console.WriteLine("hola pepe");
			Console.WriteLine(c.ToString());
			c.Destinatario = "lola";
			c.Remitente = "pepe";
			Console.WriteLine("Ahora: "+c);
			Console.WriteLine("adios pepe");*/
			
	      	new GladeApp (args);
	    }
	 
	} 
}
