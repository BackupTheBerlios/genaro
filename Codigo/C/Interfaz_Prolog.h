//---------------------------------------------------------------------------

#ifndef Interfaz_PrologH
#define Interfaz_PrologH
//---------------------------------------------------------------------------
/** Clase Interfaz_Prolog. Posee las funciones necesarias para la llamada a
los ejecutables del prolog.*/
class Interfaz_Prolog
{
private:
  /** Variable que almacena la direcci�n del ejecutable prolog*/
  String Ruta_Prolog;
public:
  /** Constructor por defecto, no deber�a ser usado*/
  Interfaz_Prolog();
  /** Constructor con par�metros, este es el adecaudo
  @param interprete Direcci�n del ejecutable prolog
  */
  Interfaz_Prolog(String interprete);
  /** Ejecuta el archivo prolog con los acordes y mutaciones indicados.
  * Guarda estos ficheros en el directorio de trabajo actual
  @param NAcordes N�mero de acordes que queremos para el ejecutable
  @param NMutaciones N�mero de mutaciones que queremos
  */
  void Ejecuta_Objetivo(String NAcordes, String NMutaciones);
  String Dame_Ruta_Prolog(){return Ruta_Prolog;};
};

#endif










