//---------------------------------------------------------------------------

#ifndef Interfaz_PrologH
#define Interfaz_PrologH
//---------------------------------------------------------------------------
class Interfaz_Prolog
{
private:
  /** Variable que almacena la direcci�n del ejecutable prolog*/
  String Ruta_Prolog;
  /** Variable que almacena la ruta del c�digo a ejecutar en prolog*/
  String Ruta_Codigo;

public:
  /** Constructor por defecto, no deber�a ser usado*/
  Interfaz_Prolog();
  /** Constructor con par�metros, este es el adecaudo*/
  Interfaz_Prolog(String interprete, String cod_fuente);
  /** Ejecuta un objetivo del archivo prolog*/
  void Ejecuta_Objetivo(String nombre_archivo, String objetivo);

};

#endif










