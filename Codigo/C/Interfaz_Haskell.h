//---------------------------------------------------------------------------

#ifndef Interfaz_HaskellH
#define Interfaz_HaskellH
//---------------------------------------------------------------------------
class Interfaz_Haskell
{
  private:
    /** Variable que almacena la direcci�n del ejecutable prolog*/
    String Ruta_Haskell;
    /** Variable que almacena la ruta del c�digo a ejecutar en prolog*/
    String Ruta_Codigo;

  public:
    Interfaz_Haskell();
    Interfaz_Haskell(String Ruta_runhugs, String Ruta_ficheros);
    void Ejecuta_Funcion(String nombre_archivo);
};



#endif
