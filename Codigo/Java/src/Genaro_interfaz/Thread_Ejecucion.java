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

public class Thread_Ejecucion extends Thread
{

  String Comando;

  public Thread_Ejecucion(String comando)
  {
    Comando=comando;
  }

  public void run()
  {
    try
    {
       Process p = Runtime.getRuntime().exec(Comando);
       p.getInputStream().close();
       p.getOutputStream().flush();
       p.getOutputStream().close();
       p.getErrorStream().close();
       System.out.println("entro");
       p.waitFor();
       System.out.println("salio");
    }
    catch (IOException excepcion)
    {
    }
    catch (InterruptedException excepcion2)
    {
    }

  }

}
