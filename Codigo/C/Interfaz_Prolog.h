//---------------------------------------------------------------------------

#ifndef Interfaz_PrologH
#define Interfaz_PrologH
//---------------------------------------------------------------------------
class Interfaz_Prolog
{
private:
  /** Variable que almacena la dirección del ejecutable prolog*/
  String Ruta_Prolog;
  /** Variable que almacena la ruta del código a ejecutar en prolog*/
  String Ruta_Codigo;

public:
  /** Constructor por defecto, no debería ser usado*/
  Interfaz_Prolog();
  /** Constructor con parámetros, este es el adecaudo*/
  Interfaz_Prolog(String interprete, String cod_fuente);
  /** Ejecuta un objetivo del archivo prolog*/
  void Ejecuta_Objetivo(String nombre_archivo, String objetivo);

};

#endif










