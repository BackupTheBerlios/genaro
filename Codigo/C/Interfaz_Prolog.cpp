//---------------------------------------------------------------------------

#include <vcl.h>
#include <fstream.h>
#include <windows.h>
#include <process.h>
#include <dir.h>
#pragma hdrstop

#include "Interfaz_Prolog.h"

//---------------------------------------------------------------------------

#pragma package(smart_init)


Interfaz_Prolog::Interfaz_Prolog()
{
  Ruta_Prolog=".\\MainArgs.exe";
}
//---------------------------------------------------------------------------
Interfaz_Prolog::Interfaz_Prolog(String interprete)
{
  Ruta_Prolog=interprete;
}
//---------------------------------------------------------------------------
void Interfaz_Prolog::Ejecuta_Objetivo(String NAcordes, String NMutaciones)
{
  char work_dir[255];
  getcwd(work_dir, 255);
  int valor_spawn=spawnl(P_WAIT,Ruta_Prolog.c_str(),Ruta_Prolog.c_str(),work_dir,NAcordes.c_str(),NMutaciones.c_str(),NULL);
  if (valor_spawn==-1)
  {ShowMessage("Error ejecutando el MainArgs de prolog.");}
}

