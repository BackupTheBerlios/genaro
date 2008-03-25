using Gtk;
using Gdk;
using System;

// mcs -pkg:gtk-sharp-2.0 eventBox.cs

public class eventbox
{

     static void delete_event (object obj, DeleteEventArgs args)
     {
          Application.Quit();
     }

     static void exitbutton_event (object obj, ButtonPressEventArgs args)
     {
	  Console.WriteLine("has pulsado una etiqueta, pervertido!!!");
          Application.Quit();
     }

     public static void Main (string[] args)
     {
          Gtk.Window window;
          EventBox eventbox;
          Label label;

          Application.Init();

          window = new Gtk.Window ("Eventbox");
          window.DeleteEvent += new DeleteEventHandler (delete_event);

          window.BorderWidth = 10;
	  window.Resize(400,300);

          eventbox = new EventBox ();
          window.Add (eventbox);
          eventbox.Show();

          label = new Label ("Click here to quit");
          eventbox.Add(label);
          label.Show();

          label.SetSizeRequest(110, 20);

          eventbox.ButtonPressEvent += new ButtonPressEventHandler (exitbutton_event);

          eventbox.Realize();

          window.Show();
               
          Application.Run();
     }
}
