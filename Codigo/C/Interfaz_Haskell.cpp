//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "Interfaz_Haskell.h"

//---------------------------------------------------------------------------

#pragma package(smart_init)


Interfaz_Haskell::Interfaz_Haskell()
{
    Ruta_Haskell="G:\\Archivos de programa\\Hugs98\\runhugs.exe";
    Ruta_Codigo="D:\\timpo";
}
//---------------------------------------------------------------------------
Interfaz_Haskell::Interfaz_Haskell(String Ruta_runhugs, String Ruta_ficheros)
{
    Ruta_Haskell=Ruta_runhugs;
    Ruta_Codigo=Ruta_ficheros;
}
//---------------------------------------------------------------------------
void Interfaz_Haskell::Ejecuta_Funcion(String nombre_archivo)
{
  String comando="\""+Ruta_Codigo+"\\"+nombre_archivo+"\"";

  PROCESS_INFORMATION pif;  //Gives info on the thread and..
                           //..process for the new process
  STARTUPINFO si;          //Defines how to start the program

  ZeroMemory(&si,sizeof(si)); //Zero the STARTUPINFO struct
  si.cb = sizeof(si);         //Must set size of structure

  BOOL bRet = CreateProcess(
        Ruta_Haskell.c_str(), //Path to executable file
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