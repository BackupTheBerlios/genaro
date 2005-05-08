//---------------------------------------------------------------------------

#ifndef Interfaz_HaskellH
#define Interfaz_HaskellH
//---------------------------------------------------------------------------
class Interfaz_Haskell
{
  private:
    /** Variable que almacena la dirección del ejecutable Haskell runhugs*/
    String Ruta_Haskell;
    /** Variable que almacena la ruta del código a ejecutar en prolog*/
    String Ruta_Codigo;

  public:
    Interfaz_Haskell();
    Interfaz_Haskell(String Ruta_runhugs, String Ruta_ficheros);

    //ADVERTENCIA, runhugs no admite rutas con \\, usa /en su lugar

    void Ejecuta_Funcion(String nombre_archivo, String num_repeticiones);
    String Dame_Ruta_Haskell(){return Ruta_Haskell;};
    String Dame_Ruta_Codigo_Haskell(){return Ruta_Codigo;};
};



#endif
