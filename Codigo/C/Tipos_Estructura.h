//---------------------------------------------------------------------------

#ifndef Tipos_EstructuraH
#define Tipos_EstructuraH
#include <stdlib.h>
#include <vector.h>
//---------------------------------------------------------------------------
enum Tipo_Pista {ACOMP=0,MELOD=1};
//---------------------------------------------------------------------------
struct Bloque
{
  public:
    int Num_Compases;
    bool Vacio;
    String Patron_Ritmico;
    bool Es_Sistema_Paralelo;
    int Notas_Totales;
    String Inversion;
    String Disposicion;
    String Curva_Melodica;
    int Octava_Inicial;
    int N_Pista_Acomp;
    int Tipo_Melodia; //0=delegar en haskell, 1= curva melódica ... 2=editor midi 
    //String Curva_Melodica;
    //String Octava_Inicial
    //?? tipo enlace voces
    String Progresion;
};
//---------------------------------------------------------------------------
typedef vector<Bloque> Bloques_Pista;
//---------------------------------------------------------------------------
class Pista
{
private:
  Tipo_Pista Tipo;
  bool Mute;
  unsigned char Instrumento;
  Bloques_Pista Bloques;
public:
  Pista(Tipo_Pista tipopista=ACOMP);
  Tipo_Pista Dame_Tipo(){return Tipo;};
  Bloque Dame_Bloque(int numbloque){return Bloques[numbloque];};
  void Cambia_Bloque(Bloque N_Bloque,int numbloque){Bloques[numbloque]=N_Bloque;};
  bool Dame_Mute(){return Mute;};
  int Dame_Instrumento(){return Instrumento;};
  void Cambia_Mute(bool n_mute){Mute=n_mute;};
  void Cambia_Instrumento(int instr){Instrumento=instr;};
  //void cambia_tipo???
  void Inserta_Bloque(Bloque Nuevo_Bloque){Bloques.push_back(Nuevo_Bloque);}
  int Dame_Numero_Bloques(){return Bloques.size();};
};
//---------------------------------------------------------------------------
typedef vector<Pista*> Pistas_Cancion;
//---------------------------------------------------------------------------
class Cancion
{
private:
  Pistas_Cancion Pistas;
public:
  Cancion(){Pistas.clear();};
  void Nueva_Pista(Tipo_Pista tipopista=ACOMP);//Hay que poner tantos bloques como haya en las demás pistas
  //inserta mete un bloque y pone a vacio los demás, y cambia cambia el bloque actual.
  void Inserta_Bloque(Bloque Nuevo_Bloque, int Num_Pista);
  void Nuevo_Bloque(int Num_Compases,String P_Ritmico,String Disposicion, String Inversion);
  int Dame_Tipo_Pista(int N_Pista){return Pistas[N_Pista]->Dame_Tipo();};
  int Dame_Numero_Pistas(){return Pistas.size();};
  Pista* Dame_Pista(int N_Pista){return Pistas[N_Pista];};
  void Guarda_Archivo();
};
#endif
