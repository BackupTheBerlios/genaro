//---------------------------------------------------------------------------

#ifndef Unidad_NexoH
#define Unidad_NexoH
#include "Interfaz_Prolog.h"
#include "Interfaz_Haskell.h"
//---------------------------------------------------------------------------



void Inicializacion(TOpenDialog* OpenDialog, TEdit *EditFicheroProlog, TEdit *EditRelacionProlog);

void prueba()
{
  Interfaz_Prolog* temporal=new Interfaz_Prolog();
  temporal->Ejecuta_Objetivo("generador_acordes.pl", "genera_acordes(5,5,paralelo)");
};

#endif
