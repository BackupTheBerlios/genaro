//---------------------------------------------------------------------------

#ifndef Interfaz_PrologH
#define Interfaz_PrologH
//---------------------------------------------------------------------------
/** Clase Interfaz_Prolog. Posee las funciones necesarias para la llamada a
los ejecutables del prolog.*/
class Interfaz_Prolog
{
private:
  /** Variable que almacena la dirección del ejecutable prolog*/
  String Ruta_Prolog;
public:
  /** Constructor por defecto, no debería ser usado*/
  Interfaz_Prolog();
  /** Constructor con parámetros, este es el adecaudo
  @param interprete Dirección del ejecutable prolog
  */
  Interfaz_Prolog(String interprete);
  /** Ejecuta el archivo prolog con los acordes y mutaciones indicados.
  * Guarda estos ficheros en el directorio de trabajo actual
  @param NAcordes Número de acordes que queremos para el ejecutable
  @param NMutaciones Número de mutaciones que queremos
  */
  void Ejecuta_Objetivo(String NAcordes, String NMutaciones);
  String Dame_Ruta_Prolog(){return Ruta_Prolog;};
};

#endif










