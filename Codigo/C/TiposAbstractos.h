//---------------------------------------------------------------------------

#ifndef TiposAbstractosH
#define TiposAbstractosH
#include <stdlib.h>
#include <vector.h>

//---------------------------------------------------------------------------
enum TipoNota {SILENCIO=0,SIMPLE=1,LIGADO=2};

typedef vector<TipoNota> Voz;

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
    TipoNota Dame(unsigned int num_col,unsigned int num_voz);//{return Cancion[i][j];}
    void Inserta(unsigned int num_col, unsigned int num_voz, TipoNota nota);
    unsigned int DameVoces(){return Voces;}
    unsigned int DameColumnas(){return Columnas;}
    unsigned int DameResolucion(){return Resolucion;}
    void CambiaResolucion(unsigned int NuevaResolucion);  //aqu� es cuando hacemos el trabajo duro que te cagasss
    void CreaFicheroTexto();
};
//---------------------------------------------------------------------------
#endif
 