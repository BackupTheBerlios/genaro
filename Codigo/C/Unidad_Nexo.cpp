//---------------------------------------------------------------------------

#include <vcl.h>
#include <fstream.h>
#pragma hdrstop

#include "Unidad_Nexo.h"


//---------------------------------------------------------------------------

#pragma package(smart_init)

void Unidad_Nexo::Inicializacion(String Ruta_prolog, String Ruta_haskell, String Ruta_codigo_haskell)
{
  if (Ya_inicializado==false)
  {
    interfaz_prolog=new Interfaz_Prolog(Ruta_prolog);
    interfaz_haskell=new Interfaz_Haskell(Ruta_haskell,Ruta_codigo_haskell);
    Ya_inicializado=true;
  }
}

//---------------------------------------------------------------------------

void Unidad_Nexo::Componer(String Num_Acordes, String Num_Mutaciones,String Patron_Ritmico, String Repeticiones)
{
  //la antigua ruta del patrón rítmico era "../../PatronesRitmicos/"
  String pseudo_ruta_patrones="./PatronesRitmicos/";
  pseudo_ruta_patrones+=Patron_Ritmico;
  interfaz_prolog->Ejecuta_Objetivo(Num_Acordes,Num_Mutaciones);
  interfaz_haskell->Ejecuta_Funcion(pseudo_ruta_patrones,Repeticiones);
}


//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------























void Inicializacion_old(TOpenDialog* OpenDialog,TEdit *EditFicheroProlog,TEdit *EditRelacionProlog)
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
    Ruta_haskell="..\\Haskell\\runhugs.exe";
    Ruta_codigo_haskell = "..\\Haskell\\main.lhs";
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
        Ruta_haskell="..\\Haskell\\runhugs.exe";
        Ruta_codigo_haskell = "..\\Haskell\\main.lhs";
        fichero_conf.close();
      }
      catch(...){}
  }
  Interfaz_Prolog* nuevo_int_prolog=new Interfaz_Prolog(Ruta_prolog);
  nuevo_int_prolog->Ejecuta_Objetivo(EditFicheroProlog->Text,EditRelacionProlog->Text);
  Interfaz_Haskell* nuevo_int_haskell=new Interfaz_Haskell(Ruta_haskell,Ruta_codigo_haskell);
  nuevo_int_haskell->Ejecuta_Funcion("../../PatronesRitmicos/cumbia.txt","4");
}
//--------------------------------------------------------------------





