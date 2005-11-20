// frame.cs - Gtk# Tutorial example
//
// Author: Johannes Roith >johannes@jroith.de<
//
// (c) 2002 Johannes Roith
 
namespace GtkSharpTutorial {
        using Gtk;
        using System;
        //using System.Drawing;
 
 
        public class Ej_frame
        {
 
		private const String str_Pide1 = "Mete los valores de x e y para la etiqueta que da nombre al frame, y pulsa el botón para aplicar los cambios";
		private Entry entrada_x;
		private Entry entrada_y;
		private Label etiquetaQue;
		private Frame frame;

                static void delete_event (object obj,DeleteEventArgs args)
                {
			Console.WriteLine("Cerrando aplicacion .................");
        	        Application.Quit();
                }

		private Widget rellenoDelFrame() {
	                Button butonOk;
			Frame marcoEtiquetaQue;
			//Label etiquetaQue;
			Label etiquetaEntrada_x;
			Label etiquetaEntrada_y;
			//Entry entrada_x;
			//Entry entrada_y;
			Table tablaEntradas;
			VBox superCaja = null;
			uint padding = 20;

			etiquetaQue = new Label(Ej_frame.str_Pide1);
			etiquetaQue.LineWrap = true;
			etiquetaQue.Justify = Justification.Left;
			marcoEtiquetaQue = new Frame();
			marcoEtiquetaQue.BorderWidth = 10;
			marcoEtiquetaQue.Add(etiquetaQue);

			entrada_x = new Entry(3);
			entrada_x.Text = "1,0";
			etiquetaEntrada_x = new Label("valor de la x");
			entrada_y = new Entry(3);
			entrada_y.Text = "1,0";
			etiquetaEntrada_y = new Label("valor de la y");
			tablaEntradas = new Table (2, 2, true);
			tablaEntradas.SetColSpacing(0, 5);
			tablaEntradas.SetColSpacing(1, 5);
			tablaEntradas.SetRowSpacing(0, 5);
			tablaEntradas.SetRowSpacing(1, 5);
			tablaEntradas.Attach(etiquetaEntrada_x, 0, 1, 0, 1);
			tablaEntradas.Attach(entrada_x, 1, 2, 0, 1);
			tablaEntradas.Attach(etiquetaEntrada_y, 0, 1, 1, 2);
			tablaEntradas.Attach(entrada_y, 1, 2, 1, 2);
			entrada_x.WidthRequest = 4;

			butonOk = new Button ("Aplicar cambios");
			butonOk.Clicked += accionBoton;

			superCaja = new VBox (false, 5);
			superCaja.PackStart(marcoEtiquetaQue, false, false, padding);
			superCaja.PackStart(tablaEntradas, true, false, padding);
			superCaja.PackStart(butonOk, true, false, padding);

			return superCaja;
		}
 
		private void accionBoton( object obj, EventArgs args)
		{
			float x, y;
			String texto_error1="ERROR: Los valores de x e y deben estar entre 0.0 y 1.0";
			String texto_error2="ERROR: Tienes que meter numeros, usando la coma para la fracción";
			String texto_def;

			try{
				x = (float)Double.Parse(entrada_x.Text);
				y = (float)Double.Parse(entrada_y.Text);
			}
			catch (Exception e)
			{
				texto_def = texto_error2 +"\n\n\t"+str_Pide1;
				etiquetaQue.Text = texto_def;
				return;
			}
			Console.WriteLine("Pulsado botón, valor de la x: {0}, valor de la y: {1}", x, y);

			if (!(x>=0.0 && x<=1.0 && y>=0.0 && y<=1.0))
			{
				texto_def = texto_error1 +"\n\n\t"+str_Pide1;
			}
			else
			{
				texto_def = str_Pide1;
				frame.LabelXalign = x;
				frame.LabelYalign = y;
			}

			etiquetaQue.Text = texto_def;		
			//Console.WriteLine("Me has pulsado tontorrón!!!!!");
		}

		private void inicia()
		{
			 /* Create a new window */
                        Window window = new Window ("Ejemplo de frames y tal ...");
  
                        /* Here we connect the "destroy" event to a signal handler */ 
                        window.DeleteEvent += delete_event;
 
                        window.SetSizeRequest(500, 400);
                        /* Sets the border width of the window. */
                        window.BorderWidth= 10;
 
                        /* Create a Frame */
                        //Frame frame = new Frame("MyFrame");
			frame = new Frame("MyFrame");
                        window.Add(frame);
 
                        /* Set the frame's label */
                        frame.Label = "Mueveme!!!!";
	 
                        /* Align the label at the right of the frame */
 
                        //frame.SetLabelAlign((float)1.0,(float)0.0); esta anticuado
			//valores entre 0.0 y 1.0, indica cada extremo
			frame.LabelXalign = (float)1.0;
			frame.LabelYalign = (float)1.0;
 
                        /* Set the style of the frame */
                        frame.ShadowType = (ShadowType) 4;
 
			/* añade mis cositas*/
			frame.Add(rellenoDelFrame());

                        frame.Show();
  
                        /* Display the window & all widgets*/
                        window.ShowAll();
		}
                public static void Main( string[] args)
                {
 
                        /* Initialise GTK */
                        Application.Init();
    

			Ej_frame ejf = new Ej_frame();

                       	ejf.inicia();

                        /* Enter the event loop */
                        Application.Run();
    
                }
 
        }
 
}
