//---------------------------------------------------------------------------

#include <vcl.h>
#include <fstream.h>
#pragma hdrstop

#include "Unidad_Nexo.h"


//---------------------------------------------------------------------------

#pragma package(smart_init)

void Inicializacion(TOpenDialog* OpenDialog,TEdit *EditFicheroProlog,TEdit *EditRelacionProlog)
{
  String Ruta_codigo_haskell;
  String Ruta_haskell;
  String Ruta_prolog;
  String Ruta_codigo_prolog;
  ifstream fichero_conf;

  int esta=FileOpen("configuracion.cfg", fmOpenRead);
  if (esta!=-1)
  {
    FileClose(esta);
    fichero_conf.open("configuracion.cfg",ios::binary);
    String buffer1="";
    int tamano_string=0;
    char c_temp;
    fichero_conf.read((char*)&tamano_string,sizeof(int));
    for (int i=0;i<tamano_string;i++)
    {
      fichero_conf.read((char*)&c_temp,sizeof(char));
      buffer1+=c_temp;
    }
    Ruta_prolog=buffer1;
    Ruta_codigo_prolog="..\\Prolog";
    Ruta_haskell="runhugs.exe";
    Ruta_codigo_haskell = "..\\Haskell";
    fichero_conf.close();
  }
  else
  {
      Ruta_prolog="";
      Ruta_codigo_haskell="";
      Ruta_haskell="";
      Ruta_codigo_prolog="";
      ofstream fichero_guardar;
      try
      {
        fichero_guardar.open("configuracion.cfg",ios::binary);
        //1- elegir archivo sicstus.exe
        OpenDialog->Execute();
        Ruta_prolog=OpenDialog->FileName;
        int tamanio=Ruta_prolog.Length();
        fichero_guardar.write((char*)&tamanio,sizeof(int));
        for (int i=0;i<tamanio;i++)
        {
          fichero_guardar.write((char*)&Ruta_prolog[i+1],sizeof(char));
        }
        Ruta_codigo_prolog="..\\Prolog";
        Ruta_haskell="runhugs.exe";
        Ruta_codigo_haskell = "..\\Haskell";
        fichero_conf.close();
      }
      catch(...){}
  }
  Interfaz_Prolog* nuevo_int_prolog=new Interfaz_Prolog(Ruta_prolog,Ruta_codigo_prolog);
  nuevo_int_prolog->Ejecuta_Objetivo(EditFicheroProlog->Text/*"generador_acordes.pl"*/,EditRelacionProlog->Text/*"genera_acordes(10,10,paralelo)"*/);
  Interfaz_Haskell* nuevo_int_haskell=new Interfaz_Haskell(Ruta_haskell,Ruta_codigo_haskell);
  nuevo_int_haskell->Ejecuta_Funcion("main.hsx");
}
//--------------------------------------------------------------------





