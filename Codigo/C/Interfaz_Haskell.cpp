//---------------------------------------------------------------------------

#include <vcl.h>
#include <fstream.h>
#include <windows.h>
#include <process.h>
#pragma hdrstop

#include "Interfaz_Haskell.h"

//---------------------------------------------------------------------------

#pragma package(smart_init)


Interfaz_Haskell::Interfaz_Haskell()
{
    Ruta_Haskell="..\\Haskell\\runhugs.exe";
    Ruta_Codigo="..\\Haskell\\main.lhs";
}
//---------------------------------------------------------------------------
Interfaz_Haskell::Interfaz_Haskell(String Ruta_runhugs, String Ruta_ficheros)
{
    Ruta_Haskell=Ruta_runhugs;
    Ruta_Codigo=Ruta_ficheros;
}
//---------------------------------------------------------------------------
void Interfaz_Haskell::Ejecuta_Funcion(String nombre_archivo, String num_repeticiones)
{
  int valor_spawn=spawnl(P_WAIT,Ruta_Haskell.c_str(),Ruta_Haskell.c_str(),Ruta_Codigo.c_str(), nombre_archivo.c_str(),num_repeticiones.c_str(),NULL);
  if (valor_spawn==-1)
  {ShowMessage("Error ejecutando el runhugs de haskell.");}
}
