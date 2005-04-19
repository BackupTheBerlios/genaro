//---------------------------------------------------------------------------

#ifndef Unidad_NexoH
#define Unidad_NexoH
#include "Interfaz_Prolog.h"
#include "Interfaz_Haskell.h"
//---------------------------------------------------------------------------


class Unidad_Nexo
{
  private:
    bool Ya_inicializado;
    Interfaz_Haskell* interfaz_haskell;
    Interfaz_Prolog* interfaz_prolog;
  public:
    Unidad_Nexo(){Ya_inicializado=false;};
    ~Unidad_Nexo(){delete interfaz_haskell; delete interfaz_prolog;};
    void Inicializacion(String Ruta_Prolog, String Ruta_haskell, String Ruta_codigo_haskell);
    void Componer(String Num_Acordes, String Num_Mutaciones,String Patron_Ritmico, String Repeticiones);
    Interfaz_Haskell* Dame_Interfaz_Haskell(){return interfaz_haskell;};
    Interfaz_Prolog* Dame_Interfaz_Prolog(){return interfaz_prolog;};    
};





//---------------------------------------------------------------------------









void Inicializacion_old(TOpenDialog* OpenDialog, TEdit *EditFicheroProlog, TEdit *EditRelacionProlog);

void prueba()
{
  Interfaz_Prolog* temporal=new Interfaz_Prolog();
  temporal->Ejecuta_Objetivo("generador_acordes.pl", "genera_acordes(5,5,paralelo)");
};












#endif
