//---------------------------------------------------------------------------

#ifndef TiposAbstractosH
#define TiposAbstractosH
#include <stdlib.h>
#include <vector.h>

//---------------------------------------------------------------------------
enum TipoNota {SILENCIO=0,SIMPLE=1,LIGADO=2};

struct TipoNotaCompuesto
{
  TipoNota Duracion;
  int Velocity;
};

typedef vector<TipoNotaCompuesto> Voz;

typedef vector<Voz> Musica;

class MatrizNotas
{
private:
    unsigned int Voces;
    unsigned int Resolucion;
    unsigned int Columnas;
    Musica Cancion;
public:
    MatrizNotas(){Cancion.clear();Voces=0;Resolucion=32;Columnas=0;}
    MatrizNotas(unsigned int numVoces){Cancion.clear();Voces=numVoces;Resolucion=1;Columnas=0;}
    TipoNotaCompuesto Dame(unsigned int num_col,unsigned int num_voz);//{return Cancion[i][j];}
    void Cambia(unsigned int num_col,unsigned int num_voz,TipoNotaCompuesto nueva_nota);
    void Inserta(unsigned int num_col, unsigned int num_voz, TipoNota nota, int velocity);
    unsigned int DameVoces(){return Voces;}
    unsigned int DameColumnas(){return Columnas;}
    unsigned int DameResolucion(){return Resolucion;}
    void CambiaResolucion(unsigned int NuevaResolucion);  //aquí es cuando hacemos el trabajo duro que te cagasss
    void CreaFicheroTexto(String fichero);
    void CargaFicheroTexto(AnsiString fichero);
};
//---------------------------------------------------------------------------
#endif
 