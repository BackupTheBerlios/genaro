package Genaro_interfaz;

import java.io.*;

/**
 * <p>Título: Interfaz_Prolog</p>
 * <p>Descripción: Contiene los metodos y varíables para comunicarse con la parte escrita en prolog</p>
 * <p>Copyright: Copyright (c) 2004</p>
 * <p>Empresa: esto es SOFT LIBRE</p>
 * @author Javier Gómez Santos
 * @version 1.0
 */

public class Interfaz_Prolog
{
/** Variable que almacena la dirección del ejecutable prolog*/
private String Ruta_Prolog;
/** Variable que almacena la ruta del código a ejecutar en prolog*/
private String Ruta_Codigo;

public Interfaz_Prolog()
{
  Ruta_Prolog="G:\\Archivos de programa\\SICStus Prolog\\bin\\sicstus.exe";
  Ruta_Codigo="D:\\timpo2";
  //Ruta_Prolog="";
  //Ruta_Codigo="";
}

public Interfaz_Prolog(String interprete, String cod_fuente)
{
  Ruta_Prolog=interprete;
  Ruta_Codigo=cod_fuente;
}

public void Ejecuta_Objetivo(String nombre_archivo, String objetivo)
  {//no olvidarse de añadir el main al fichero, es decir, copiar el archivo original a otro, y luego añadir el main, yluego usar eso como nombre_archivo.
    String main_del_fichero="main:-"+objetivo+",halt.\n:- initialization main.";
    try
    {
      FileWriter salida_temporal=new FileWriter(Ruta_Codigo+"\\temporal.pl");
      FileReader archivo_original=new FileReader(Ruta_Codigo+"\\"+nombre_archivo);
      int c;
      c=archivo_original.read();
      while (c!=-1)
      {
        salida_temporal.write(c);
        c=archivo_original.read();
      }
      salida_temporal.write(main_del_fichero,0,main_del_fichero.length());
      salida_temporal.close();
      archivo_original.close();
    }
    catch (IOException excepcion_molona)
    {}
    String comando="\""+Ruta_Prolog+"\""+" -l "+"\""+Ruta_Codigo+"\\"+"temporal.pl"+"\"";//aquí no es nombre_archivo si no temporal.pl
    try
    {
      Process p = Runtime.getRuntime().exec(comando);
      p.getInputStream().close();
      p.getOutputStream().flush();
      p.getOutputStream().close();
      p.getErrorStream().close();
      System.out.println("entro prolog");
      p.waitFor();
      System.out.println("salio prolog");
    }
    catch (IOException excepcion)
    {
    }
    catch (InterruptedException excepcion2)
    {
    }


  /*  Thread_Ejecucion Hilo=new Thread_Ejecucion(comando);
    Hilo.start();*/
  }

}
