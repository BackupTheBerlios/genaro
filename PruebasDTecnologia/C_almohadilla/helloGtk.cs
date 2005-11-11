        using Gtk;
 	using System;
 
	// compilar con mcs -pkg:gtk-sharp-2.0 helloGtk.cs
        class Hello {
 
                static void Main()
                {
                        Application.Init ();
 
	                // Set up a button object.
                        Button btn = new Button ("Hello World");
                        // when this button is clicked, it'll run hello()
                        btn.Clicked += new EventHandler (hello);
 
                        Window window = new Window ("helloworld");
			window.Resize(400,300);
	                // when this window is deleted, it'll run delete_event()
                        window.DeleteEvent += delete_event;
                        
	                // Add the button to the window and display everything
	                window.Add (btn);
                        window.ShowAll ();
 
                        Application.Run ();
                }
 
 
	        // runs when the user deletes the window using the "close
	        // window" widget in the window frame.
                static void delete_event (object obj, DeleteEventArgs args)
                {
			Console.WriteLine("\n\nCerrando la aplicacion ........................................\n");
			Application.Quit ();
			args.RetVal = true;
                }
 
                // runs when the button is clicked.
                static void hello (object obj, EventArgs args)
                {
			//obj hace referencia al objeto que disparo el evento, en este caso el 
			//boton, pq este manejadro de eventos esta pegado a el. No confundirse
			//y pensar que la ventana dispara el evento, esto ((Window) obj).Title = "Ventana pulsada";
			//daria un error de casting en tiempo de ejecucion
			String msjIni = "Hello World";
			String msjPulsado1 = "Me has pulsado malvado!!!";
			String msjPulsado2 = "Me has vuelto a pulsar!!!";
			String etqBoton = ((Button) obj).Label;

                        Console.WriteLine("Hello World");
			
			if (String.Compare(etqBoton, msjIni) == 0)
			{
				//nunca pulsado antes
				((Button) obj).Label = msjPulsado1;
			 }
			else
			{	
				// al menos una vez pulsado
				if (String.Compare(etqBoton, msjPulsado1) == 0)
				{
					//pulsado un numero impar de veces
					((Button) obj).Label = msjPulsado2;
			 	}
				else
				{
					//pulsado un numero par de veces
					((Button) obj).Label = msjPulsado1;
				}
			}
			//((Button) obj).Label = "lola";
                }
        }
