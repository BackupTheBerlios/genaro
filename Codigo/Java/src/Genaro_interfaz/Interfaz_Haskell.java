package Genaro_interfaz;
import java.io.*;

/**
 * <p>Título: </p>
 * <p>Descripción: </p>
 * <p>Copyright: Copyright (c) 2004</p>
 * <p>Empresa: </p>
 * @author sin atribuir
 * @version 1.0
 */

public class Interfaz_Haskell
{
  /** Variable que almacena la dirección del ejecutable prolog*/
  private String Ruta_Haskell;
  /** Variable que almacena la ruta del código a ejecutar en prolog*/
  private String Ruta_Codigo;

  public Interfaz_Haskell()
  {
    Ruta_Haskell="G:\\Archivos de programa\\Hugs98\\runhugs.exe";
    Ruta_Codigo="D:\\timpo";
  }

  public Interfaz_Haskell(String Ruta_runhugs, String Ruta_ficheros)
  {
    Ruta_Haskell=Ruta_runhugs;
    Ruta_Codigo=Ruta_ficheros;
  }

  public void Ejecuta_Funcion(String nombre_archivo)
    {
      String comando="\""+Ruta_Haskell+"\""+" "+"\""+Ruta_Codigo+"\\"+nombre_archivo+"\"";
      try
      {
        Process p = Runtime.getRuntime().exec(comando);
        p.getInputStream().close();
        p.getOutputStream().flush();
        p.getOutputStream().close();
        p.getErrorStream().close();
        System.out.println("entro haskell");
        p.waitFor();
        System.out.println("salio haskell");
      }
      catch (IOException excepcion)
      {
      }
      catch (InterruptedException excepcion2)
      {
      }

     /* Thread_Ejecucion Hilo=new Thread_Ejecucion(comando);
      Hilo.start();*/
    }



}
