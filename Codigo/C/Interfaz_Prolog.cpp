//---------------------------------------------------------------------------

#include <vcl.h>
#include <fstream.h>
#include <windows.h>
#include <process.h>
#include <dir.h>
#include <stdio.h>
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
  FILE* salida_prolog;
  int salida_standard;
  salida_prolog=fopen("prolog.log","w");
  salida_standard=dup(fileno(stdout));
  dup2(fileno(salida_prolog),fileno(stdout));

  char work_dir[255];
  getcwd(work_dir, 255);
  String directorio_trabajo=work_dir;
  directorio_trabajo="\""+directorio_trabajo+"\"";
  int valor_spawn=spawnl(P_WAIT,Ruta_Prolog.c_str(),Ruta_Prolog.c_str(),directorio_trabajo.c_str(),NAcordes.c_str(),NMutaciones.c_str(),NULL);
  if (valor_spawn==-1)
  {ShowMessage("Error ejecutando el MainArgs de prolog.");}

  dup2(salida_standard,fileno(stdout));
  fclose(salida_prolog);
}

