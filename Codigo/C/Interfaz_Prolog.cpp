//---------------------------------------------------------------------------

#include <vcl.h>
#include <fstream.h>
#include <windows.h>
#include <process.h>
#pragma hdrstop

#include "Interfaz_Prolog.h"

//---------------------------------------------------------------------------

#pragma package(smart_init)


Interfaz_Prolog::Interfaz_Prolog()
{
  Ruta_Prolog="G:\\Archivos de programa\\SICStus Prolog\\bin\\sicstus.exe";
  Ruta_Codigo="D:\\timpo2";
  //Ruta_Prolog="";
  //Ruta_Codigo="";
}
//---------------------------------------------------------------------------
Interfaz_Prolog::Interfaz_Prolog(String interprete, String cod_fuente)
{
  Ruta_Prolog=interprete;
  Ruta_Codigo=cod_fuente;
}
//---------------------------------------------------------------------------
void Interfaz_Prolog::Ejecuta_Objetivo(String nombre_archivo, String objetivo)
  {//no olvidarse de añadir el main al fichero, es decir, copiar el archivo original a otro, y luego añadir el main, yluego usar eso como nombre_archivo.
  String importar_modulo="";
  for (int i=0;i<(nombre_archivo.Length()-3);i++)
  {
    importar_modulo+=nombre_archivo[i+1];
  }
  importar_modulo=":- use_module("+importar_modulo+").\n";
  String main_del_fichero="main:-"+objetivo+",halt.\n:- initialization main.";
    try
    {
      ofstream salida_temp;
      AnsiString fichero=Ruta_Codigo+"\\temporal.pl";
      salida_temp.open(fichero.c_str());
      main_del_fichero=importar_modulo+main_del_fichero;
      for (int i=0;i<main_del_fichero.Length();i++)
      {
        salida_temp<<main_del_fichero[i+1];
      }
      salida_temp.close();
    }
    catch (...)
    {ShowMessage("Error en la creación de los ficheros temporales, ¿nombre incorrecto? ¿Disco duro lleno?");}

    //    String comando="\""+Ruta_Prolog+"\""+" -l "+"\""+Ruta_Codigo+"\\"+"temporal.pl"+"\"";//aquí no es nombre_archivo si no temporal.pl
    String comando=" -l \""+Ruta_Codigo+"\\"+"temporal.pl"+"\"";//aquí no es nombre_archivo si no temporal.pl


  PROCESS_INFORMATION pif;  //Gives info on the thread and..
                           //..process for the new process
  STARTUPINFO si;          //Defines how to start the program

  ZeroMemory(&si,sizeof(si)); //Zero the STARTUPINFO struct
  si.cb = sizeof(si);         //Must set size of structure

  BOOL bRet = CreateProcess(
        Ruta_Prolog.c_str(), //Path to executable file
        comando.c_str(),   //Command string - not needed here
        NULL,   //Process handle not inherited
        NULL,   //Thread handle not inherited
        FALSE,  //No inheritance of handles
        0,      //No special flags
        NULL,   //Same environment block as this prog
        NULL,   //Current directory - no separate path
        &si,    //Pointer to STARTUPINFO
        &pif);   //Pointer to PROCESS_INFORMATION

  if(bRet == FALSE)
  {
    MessageBox(HWND_DESKTOP,"Unable to start program","",MB_OK);
  }
  //if (cwait(NULL,pif.dwProcessId,WAIT_CHILD)==-1){ShowMessage("MAL");}
  CloseHandle(pif.hProcess);   //Close handle to process
  CloseHandle(pif.hThread);    //Close handle to thread

}

