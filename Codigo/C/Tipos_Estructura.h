//---------------------------------------------------------------------------

#ifndef Tipos_EstructuraH
#define Tipos_EstructuraH
#include <stdlib.h>
#include <vector.h>
//---------------------------------------------------------------------------
enum Tipo_Pista {ACOMP=0,MELOD=1};
//---------------------------------------------------------------------------
int Es_Progresion_Valida(String fichero_Progresion);
TStringList* Come_Progresion(String fichero_Progresion);
String Come_Azucar(String Fichero);
int Procesar(String &Total,String A_Eliminar);
String Procesar2(String &Total,int A_Eliminar);
int Procesar_Grado(String &Progresion,String &Salida);
int Procesar_Matricula(String &Progresion);
int Procesa_Num_Natural(String &Progresion);
String Dame_Token(String &Total);
const Tam_Inter_Simples=23;
String Inter_Simples[Tam_Inter_Simples]={"i", "bii", "ii", "biii", "iii", "iv", "bv", "v", "auv", "vi", "bvii", "vii", "bbii", "bbiii", "auii", "biv", "auiii", "auiv", "bbvi", "bvi", "auvi", "bviii", "auviii"};
const Tam_Matriculas=13;
String Matriculas[Tam_Matriculas]={"mayor","m","au","dis","6","m6","m7b5", "maj7","7","m7","mMaj7","au7","dis7"};
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
    String Tipo_Music;
    int Octava_Inicial;
    int N_Pista_Acomp;
    int Tipo_Melodia; //0=delegar en haskell, 1= curva melódica ... 2=editor midi
    int Aplicacion_Horizontal;//0=ciclico, 1= no ciclico
    int Aplicacion_Vertical_Mayor;//0=truncar, 1=saturar
    int Aplicacion_Vertical_Menor;//0=truncar, 1=saturar,2=ciclico, 3=modulo
    //String Curva_Melodica;
    //String Octava_Inicial
    //?? tipo enlace voces
    String Progresion;
    int N_Divisiones;
    int Fase2;
    int Fase3;
    int Fase4;
    int Bajo_Duracion_Numerador;
    int Bajo_Duracion_Denominador;
    int Bajo_Tipo;
    int Bajo_Parametro1;
    int Bajo_Parametro2;
    int Bajo_Parametro3;
    int Bajo_Parametro4;
    int Bajo_Parametro5;
    void Inicializa();
    void Copia(Bloque Original,int bloque);
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
  ~Cancion();
  Cancion(){Pistas.clear();};
  void Nueva_Pista(Tipo_Pista tipopista=ACOMP);//Hay que poner tantos bloques como haya en las demás pistas
  //inserta mete un bloque y pone a vacio los demás, y cambia cambia el bloque actual.
  void Inserta_Bloque(Bloque Nuevo_Bloque, int Num_Pista);
  void Nuevo_Bloque(int Num_Compases,String P_Ritmico,String Disposicion, String Inversion);
  int Dame_Tipo_Pista(int N_Pista){return Pistas[N_Pista]->Dame_Tipo();};
  int Dame_Numero_Pistas(){return Pistas.size();};
  Pista* Dame_Pista(int N_Pista){return Pistas[N_Pista];};
  void Guarda_Archivo(String nombre_archivo);
  void Guarda_Archivo_Haskell(String Fichero_Gen,int tempo,String tonalidad);
  void Limpia();
  int Cargar(String fichero);
};
#endif

