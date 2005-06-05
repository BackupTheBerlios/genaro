//---------------------------------------------------------------------------

#include <vcl.h>
#include <fstream.h>
#pragma hdrstop

#include "Tipos_Estructura.h"

//---------------------------------------------------------------------------

#pragma package(smart_init)
//---------------------------------------------------------------------------
Pista::Pista(Tipo_Pista tipopista)
{
  Tipo=tipopista;
  Mute=false;
  Instrumento=0;
  Bloques.clear();
}
//---------------------------------------------------------------------------
void Cancion::Nueva_Pista(Tipo_Pista tipopista)
{
  Pista *Pista_Nueva=new Pista(tipopista);
  if (Pistas.size()>0)//iniciamos copiado de bloques
  {
    Bloque temporal;
    for (int i=0;i<Pistas[0]->Dame_Numero_Bloques();i++)
    {
      temporal=Pistas[0]->Dame_Bloque(i);
      temporal.Vacio=true;
      temporal.Curva_Melodica=NULL;
      temporal.Tipo_Music=NULL;
      temporal.Progresion=NULL;
      temporal.N_Divisiones=2;
      temporal.Fase2=2;
      temporal.Fase3=2;
      temporal.Fase4=2;
      Pista_Nueva->Inserta_Bloque(temporal);
    }
  }
  Pistas.push_back(Pista_Nueva);
}
//---------------------------------------------------------------------------
void Cancion::Nuevo_Bloque(int Num_Compases,String P_Ritmico,String Disposicion, String Inversion)
{
Bloque Bloque_Vacio;
Bloque_Vacio.Inicializa();
Bloque_Vacio.Num_Compases=Num_Compases;
Bloque_Vacio.Patron_Ritmico=P_Ritmico;
Bloque_Vacio.Disposicion=Disposicion;
Bloque_Vacio.Inversion=Inversion;
Bloque_Vacio.N_Divisiones=2;
Bloque_Vacio.Fase2=2;
Bloque_Vacio.Fase3=2;
Bloque_Vacio.Fase4=2;

for (int i=0;i<Pistas.size();i++)
 {
  Pistas[i]->Inserta_Bloque(Bloque_Vacio);
 }
}
//---------------------------------------------------------------------------
void Cancion::Inserta_Bloque(Bloque Nuevo_Bloque, int Num_Pista)
{
  Bloque Bloque_Vacio=Nuevo_Bloque;
  Bloque_Vacio.Vacio=true;
  for (int i=0; i<Pistas.size(); i++)
  {
    if (i==Num_Pista)
    {
      Pistas[i]->Inserta_Bloque(Nuevo_Bloque);
    }
    else
    {
      Pistas[i]->Inserta_Bloque(Bloque_Vacio);
    }
  }
}
//---------------------------------------------------------------------------
void Cancion::Guarda_Archivo()
{
ofstream fichero_salida;
fichero_salida.open("prueba_rara.txt");
//guardamos datos de cancion
Bloque bloque_temp;
fichero_salida<<"Pistas: "<<Pistas.size()<<"\n";
for (int i=0;i<Pistas.size();i++)
 {
 //Escribimos los datos de pista
 fichero_salida<<"Nº "<<i<<"\n";
 fichero_salida<<"Bloques "<<Pistas[i]->Dame_Numero_Bloques()<<" ";
 fichero_salida<<"Tipo "<<Pistas[i]->Dame_Tipo()<<" ";
 fichero_salida<<"Mute "<<Pistas[i]->Dame_Mute()<<" ";
 fichero_salida<<"Instrumento "<<Pistas[i]->Dame_Instrumento()<<"\n";
 for (int j=0;j<Pistas[i]->Dame_Numero_Bloques();j++)
  {
    bloque_temp=Pistas[i]->Dame_Bloque(j);
    fichero_salida<<"bloque "<<j<<"\n";
    fichero_salida<<"Compases "<<bloque_temp.Num_Compases<<" ";
    fichero_salida<<"vacio "<<bloque_temp.Vacio<<" ";
    fichero_salida<<"Patron "<<bloque_temp.Patron_Ritmico.Length()<<" ";
    for (int k=0;k<bloque_temp.Patron_Ritmico.Length();k++)
    {
        fichero_salida<<bloque_temp.Patron_Ritmico[k+1];
    }
    fichero_salida<<" ";
    fichero_salida<<"Aplicacion_Horizontal "<<bloque_temp.Aplicacion_Horizontal<<" ";
    fichero_salida<<"Aplicacion_Vertical_Mayor "<<bloque_temp.Aplicacion_Vertical_Mayor<<" ";
    fichero_salida<<"Aplicacion_Vertical_Menor "<<bloque_temp.Aplicacion_Vertical_Menor<<" ";
    fichero_salida<<"Octava_Inicial "<<bloque_temp.Octava_Inicial<<" ";
    fichero_salida<<"Sistema "<<bloque_temp.Es_Sistema_Paralelo<<" ";
    fichero_salida<<"Notas "<<bloque_temp.Notas_Totales<<" ";
    fichero_salida<<"Inversion "<<bloque_temp.Inversion.Length()<<" ";
    for (int k=0;k<bloque_temp.Inversion.Length();k++)
    {
      fichero_salida<<bloque_temp.Inversion[k+1];
    }
    fichero_salida<<" ";
    fichero_salida<<"Disposicion "<<bloque_temp.Disposicion.Length()<<" ";
    for (int k=0;k<bloque_temp.Disposicion.Length();k++)
    {
      fichero_salida<<bloque_temp.Disposicion[k+1];
    }
    fichero_salida<<" ";
    fichero_salida<<"Tipo_Melodia "<<bloque_temp.Tipo_Melodia<<" ";//0=delegar en haskell, 1=curva melodica, 2= fichero midi
    fichero_salida<<"Curva_Melodica "<<bloque_temp.Curva_Melodica.Length()<<" ";
    for (int p=0;p<bloque_temp.Curva_Melodica.Length();p++)
    {
      fichero_salida<<bloque_temp.Curva_Melodica[p+1];
    }
    fichero_salida<<" ";
    fichero_salida<<"Pista_Acomp "<<bloque_temp.N_Pista_Acomp<<" ";
    fichero_salida<<"Num_Divisiones "<<bloque_temp.N_Divisiones<<" ";
    fichero_salida<<"Fase2 "<<bloque_temp.Fase2<<" ";
    fichero_salida<<"Fase3 "<<bloque_temp.Fase3<<" ";
    fichero_salida<<"Fase4 "<<bloque_temp.Fase4<<" ";
    fichero_salida<<"Progresion "<<bloque_temp.Progresion.Length()<<" ";
    for (int k=0;k<bloque_temp.Progresion.Length();k++)
    {
      fichero_salida<<bloque_temp.Progresion[k+1];
    }
    fichero_salida<<" ";
    fichero_salida<<"Tipo_Music "<<bloque_temp.Tipo_Music.Length()<<" ";
    for (int h=0;h<bloque_temp.Tipo_Music.Length();h++)
    {
      fichero_salida<<bloque_temp.Tipo_Music[h+1];
    }
    fichero_salida<<" ";
    fichero_salida<<"FINBLOQUE"<<"\n";
  }
 fichero_salida<<"FINPISTA"<<"\n";
 }
fichero_salida<<"FINCANCION";
fichero_salida.close();
}
//---------------------------------------------------------------------------
void Bloque::Inicializa()
{
Notas_Totales=0;
Vacio=true;
Curva_Melodica=NULL;
Tipo_Music=NULL;
N_Pista_Acomp=-1;
Octava_Inicial=1;
Tipo_Melodia=0;
Progresion=NULL;
Aplicacion_Horizontal=0;
Aplicacion_Vertical_Mayor=0;
Aplicacion_Vertical_Menor=0;
N_Divisiones=0;
Fase2=0;
Fase3=0;
Fase4=0;
}
//---------------------------------------------------------------------------
int Es_Progresion_Valida(String fichero_Progresion)
{
String Progresion=Come_Azucar(fichero_Progresion);
String Inutil="";
if(Procesar(Progresion,"progresion([")==-1){return -1;};
//ahora empieza el listado de cifrados
//--punto de retorno para el cifrado ya escrito
//guail tru
while (true)
{
  if (Procesar(Progresion,"(")==-1){break;}
  //comemos cifrado
  if(Procesar(Progresion,"cifrado(")==-1)
  {break;}//salimos del while true puesto que ya hemos terminado el listado de cifrados
    //comemos el grado
    if (Procesar_Grado(Progresion,Inutil)==-1){return -1;}
    //comemos ,
    if(Procesar(Progresion,",")==-1){return -1;}
    //comemos matricula
    if (Procesar_Matricula(Progresion)==-1){return -1;}
  //comemos cerrar paréntesis
  if (Procesar(Progresion,")")==-1){return -1;}
  //comemos ,
  if (Procesar(Progresion,",")==-1){return -1;}
  //comemos figura
    if(Procesar(Progresion,"figura(")==-1){return -1;}
    //procesamos un entero natural
    if (Procesa_Num_Natural(Progresion)==-1){return -1;}
    //procesamos ,
    if(Procesar(Progresion,",")==-1){return -1;}
    //procesamos otro entero natural
    if (Procesa_Num_Natural(Progresion)==-1){return -1;}
    //comemos )
    if(Procesar(Progresion,")")==-1){return -1;}
  //cerramos el cifrado
  if (Procesar(Progresion,")")==-1){return -1;}
  if (Procesar(Progresion,",")==-1){break;}
}
//fin del guail tru
if (Procesar(Progresion,"]).")==-1){return -1;};
return 0;
}
//---------------------------------------------------------------------------
String Come_Azucar(String Fichero)
{
ifstream fichero_origen;
String salida="";
fichero_origen.open(Fichero.c_str());
char temp;
while (fichero_origen.eof()!=true)
 {
  fichero_origen>>temp;
  if (fichero_origen.eof()!=true)
  {
  if ((temp!='\t')&&(temp!='\n')&&(temp!=' '))
  {salida+=temp;}
  }
 }
return salida;
}
//---------------------------------------------------------------------------
int Procesar(String &Total,String A_Eliminar)
{
for (int i=0;i<A_Eliminar.Length();i++)
{
  if(Total[i+1]!=A_Eliminar[i+1])
  {
    return -1;
  }
}
String nuevo_total="";
//buscar el nuevo total
for (int j=0;j<Total.Length()-A_Eliminar.Length();j++)
{
  nuevo_total+=Total[j+A_Eliminar.Length()+1];
}
Total=nuevo_total;
return 0;
}
//---------------------------------------------------------------------------
String Procesar2(String &Total,int A_Eliminar)
{
String salida="";
for (int i=0;i<A_Eliminar;i++)
{
  salida+=Total[i+1];
}
String nuevo_total="";
//buscar el nuevo total
for (int j=0;j<Total.Length()-A_Eliminar;j++)
{
  nuevo_total+=Total[j+A_Eliminar+1];
}
Total=nuevo_total;
return salida;
}
//-----------------------------------------------------------------------------
int Num_Inter_Simple(String &Progresion)
{
//hay que mirar en que posicion esta el punto
int Num_Inter_Simple;
bool Encontrado=false;
String Progresion_Temporal=Progresion;
for (int i=0;((i<Tam_Inter_Simples)&&(!Encontrado));i++)
 {
  if (Procesar(Progresion_Temporal,Inter_Simples[i])!=-1){Num_Inter_Simple=i;Encontrado=true;}
  if (Encontrado)
   {
    //miramos si el siguiente caracter es bueno o no
    if ((Progresion_Temporal[1]!='i')&&(Progresion_Temporal[1]!='b')&&(Progresion_Temporal[1]!='v')&&(Progresion_Temporal[1]!='a')&&(Progresion_Temporal[1]!='u'))
     {//es válido, actualizamos progresion
      Progresion=Progresion_Temporal;
      Num_Inter_Simple=i;
     }
    else
     {//si es no valido, ponemos progresion_temporal=progresion
      Progresion_Temporal=Progresion;
      Encontrado=false;
     }
    }
 } //fin for
if (Encontrado){return Num_Inter_Simple;}
else{return -1;}
}
//------------------------------------------------------------------------------
int Procesar_Grado(String &Progresion,String &Salida)
{
Salida="";
int grado=0;
bool es_grado=true;
if((Procesar(Progresion,"grado(")!=-1)||(Procesar(Progresion,"(")!=-1))
{      //o bien es v7 o iim7
      grado=-2;
      Salida=" v7";
      if (Procesar(Progresion,"v7")==-1)
       {
       grado=-3;
       Salida=" iim7";
        if(Procesar(Progresion,"iim7")==-1){es_grado=false;}//no es ni v7 ni iim7
       }
      if (es_grado)
      {
      //comemos el /
      String Salida_Parcial="";
      if (Procesar(Progresion,"/")==-1){return -1;}
      //procesamos el grado
      //llamada recursiva
      int entero_temp=Procesar_Grado(Progresion,Salida_Parcial);
      Salida=Salida+Salida_Parcial;
      grado*10+entero_temp;
      if (entero_temp==-1)
      {
        return -1;
      }
      if(Procesar(Progresion,")")==-1){}
      return grado;
      }
}
      //o bien es intervalo simple
       //miramos si es correcto lo que encuentra
       int Num_Inter_Temp=Num_Inter_Simple(Progresion);
       if (Num_Inter_Temp!=-1)
       {
       if (Procesar(Progresion,")")==-1){return -1;}
       Salida=" "+Inter_Simples[Num_Inter_Temp];
       return Num_Inter_Temp;
       }
       else
       {return -1;}



}
//------------------------------------------------------------------------------
int Procesar_Matricula(String &Progresion)
{
if(Procesar(Progresion,"matricula(")==-1){return -1;}

//hay que mirar en que posicion esta el punto
int Num_matricula;
bool Encontrado=false;
String Progresion_Temporal=Progresion;
for (int i=0;(i<Tam_Matriculas)&&(!Encontrado);i++)
 {
  if (Procesar(Progresion_Temporal,Matriculas[i])!=-1){Num_matricula=i;Encontrado=true;}
  if (Encontrado)
   {
    //miramos si el siguiente caracter es bueno o no
    if ((Progresion_Temporal[1]!='m')&&(Progresion_Temporal[1]!='a')&&(Progresion_Temporal[1]!='y')&&(Progresion_Temporal[1]!='o')&&(Progresion_Temporal[1]!='r')&&(Progresion_Temporal[1]!='u')&&(Progresion_Temporal[1]!='d')&&(Progresion_Temporal[1]!='s')&&(Progresion_Temporal[1]!='i')&&(Progresion_Temporal[1]!='6')&&(Progresion_Temporal[1]!='b')&&(Progresion_Temporal[1]!='5')&&(Progresion_Temporal[1]!='7')&&(Progresion_Temporal[1]!='M')&&(Progresion_Temporal[1]!='j'))
     {//es válido, actualizamos progresion
      Progresion=Progresion_Temporal;
      Num_matricula=i;
     }
    else
     {//si es no valido, ponemos progresion_temporal=progresion
      Progresion_Temporal=Progresion;
      Encontrado=false;
     }
    }
 } //fin for
if(Procesar(Progresion,")")==-1){return -1;}
return Num_matricula;
}
//------------------------------------------------------------------------------
int Procesa_Num_Natural(String &Progresion)
{
String Nuevo_String="";
int Numero=0;
int Digitos=0;
while ((Progresion[Digitos+1]=='0')||(Progresion[Digitos+1]=='1')||(Progresion[Digitos+1]=='2')||(Progresion[Digitos+1]=='3')||(Progresion[Digitos+1]=='4')||(Progresion[Digitos+1]=='5')||(Progresion[Digitos+1]=='6')||(Progresion[Digitos+1]=='7')||(Progresion[Digitos+1]=='8')||(Progresion[Digitos+1]=='9'))
{
  Numero=Numero*10+StrToInt(Progresion[Digitos+1]);
  Digitos++;
}
for (int i=0;i<Progresion.Length()-Digitos;i++)
{
  Nuevo_String+=Progresion[i+Digitos+1];
}
Progresion=Nuevo_String;
if (Digitos=0){return -1;}
return Numero;
}

//------------------------------------------------------------------------------
TStringList* Come_Progresion(String fichero_Progresion)
{
TStringList* Cadenas;
Cadenas=new TStringList();
Cadenas->Clear();
String Temporal="";
String Cadena_Temporal="";

String Progresion=Come_Azucar(fichero_Progresion);
if(Procesar(Progresion,"progresion([")==-1){ShowMessage("ERROR comiendo progresión");return NULL;}
//ahora empieza el listado de cifrados
//--punto de retorno para el cifrado ya escrito
//guail tru
while (true)
{
  if (Procesar(Progresion,"(")==-1){break;}
  //comemos cifrado
  if(Procesar(Progresion,"cifrado(")==-1)
  {break;}//salimos del while true puesto que ya hemos terminado el listado de cifrados
    Cadena_Temporal="";
    //comemos el grado
    int entero=Procesar_Grado(Progresion,Temporal);
    Cadena_Temporal+=Temporal;
    //comemos ,
    if(Procesar(Progresion,",")==-1){ShowMessage("ERROR comiendo progresión");return NULL;}
    //comemos matricula
    entero=Procesar_Matricula(Progresion);
    if(entero==-1){ShowMessage("ERROR comiendo progresión");return NULL;}
    Cadena_Temporal+=" "+Matriculas[entero];
  //comemos cerrar paréntesis
  if (Procesar(Progresion,")")==-1){ShowMessage("ERROR comiendo progresión");return NULL;}
  //comemos ,
  if (Procesar(Progresion,",")==-1){ShowMessage("ERROR comiendo progresión");return NULL;}
  //comemos figura
    if(Procesar(Progresion,"figura(")==-1){ShowMessage("ERROR comiendo progresión");return NULL;}
    //procesamos un entero natural
    entero=Procesa_Num_Natural(Progresion);
    if(entero==-1){ShowMessage("ERROR comiendo progresión");return NULL;}
    Cadena_Temporal+=" "+IntToStr(entero);
    //procesamos ,
    if(Procesar(Progresion,",")==-1){ShowMessage("ERROR comiendo progresión");return NULL;}
    Cadena_Temporal+=" /";
    //procesamos otro entero natural
    entero=Procesa_Num_Natural(Progresion);
    if (entero==-1){ShowMessage("ERROR comiendo progresión");return NULL;}
    Cadena_Temporal+=" "+IntToStr(entero);
    //comemos )
    if(Procesar(Progresion,")")==-1){ShowMessage("ERROR comiendo progresión");return NULL;}
  //cerramos el cifrado
  if (Procesar(Progresion,")")==-1){ShowMessage("ERROR comiendo progresión");return NULL;}
  //añadimos la cadena
  Cadenas->Add(Cadena_Temporal);
  Cadena_Temporal="";
  if (Procesar(Progresion,",")==-1){break;}

}
//fin del guail tru
if (Procesar(Progresion,"]).")==-1){ShowMessage("ERROR comiendo progresión");return NULL;}
return Cadenas;
}
//------------------------------------------------------------------------------
void Cancion::Guarda_Archivo_Haskell(String Fichero_Gen,int tempo,String tonalidad)
{
ofstream fichero_salida;
fichero_salida.open(Fichero_Gen.c_str());
//guardamos datos de cancion
Bloque bloque_temp;
fichero_salida<<"Pistas: "<<Pistas.size()<<"\n";
fichero_salida<<"Tempo: "<<tempo<<"\n";
fichero_salida<<"Tonalidad: ";
for (int o=0;o<tonalidad.Length();o++)
{
  fichero_salida<<tonalidad[o+1];
}
fichero_salida<<"\n";
for (int i=0;i<Pistas.size();i++)
 {
 //Escribimos los datos de pista
 fichero_salida<<"N "<<i<<"\n";
 fichero_salida<<"Bloques "<<Pistas[i]->Dame_Numero_Bloques()<<" ";
 fichero_salida<<"Tipo ";
 if (Pistas[i]->Dame_Tipo()==0)
 {
    fichero_salida<<"Acompanamiento"<<" ";
 }
 if (Pistas[i]->Dame_Tipo()==1)
 {
    fichero_salida<<"Melodia"<<" ";
 }
 if (Pistas[i]->Dame_Tipo()==2)
 {
    fichero_salida<<"Bajo"<<" ";
 }
 if (Pistas[i]->Dame_Tipo()==3)
 {
    fichero_salida<<"Bateria"<<" ";
 }
 fichero_salida<<"Mute "<<Pistas[i]->Dame_Mute()<<" ";
 fichero_salida<<"Instrumento "<<Pistas[i]->Dame_Instrumento()<<"\n";
 for (int j=0;j<Pistas[i]->Dame_Numero_Bloques();j++)
  {
    bloque_temp=Pistas[i]->Dame_Bloque(j);
    fichero_salida<<"bloque "<<j<<"\n";
    fichero_salida<<"Compases "<<bloque_temp.Num_Compases<<" ";
    fichero_salida<<"vacio "<<bloque_temp.Vacio<<" ";
    fichero_salida<<"Tipo_Music "<<bloque_temp.Tipo_Music.Length()<<" ";
    for (int h=0;h<bloque_temp.Tipo_Music.Length();h++)
    {
      fichero_salida<<bloque_temp.Tipo_Music[h+1];
    }
    fichero_salida<<" ";
    fichero_salida<<"FINBLOQUE"<<"\n";
  }
 fichero_salida<<"FINPISTA"<<"\n";
 }
fichero_salida<<"FINCANCION"<<"\n";
fichero_salida.close();
}
//---------------------------------------------------------------------------
void Cancion::Limpia()
{

for (int i=0;i<Pistas.size();i++)
 {
  delete Pistas[i];
 }
Pistas.clear();
}
//---------------------------------------------------------------------------
Cancion::~Cancion()
{

for (int i=0;i<Pistas.size();i++)
 {
  delete Pistas[i];
 }
Pistas.clear();
}
//---------------------------------------------------------------------------
int Cancion::Cargar(String fichero)
{
ifstream archivo;
archivo.open(fichero.c_str(),ios::binary);
char agua;
String Total="";
archivo.read((char*)&agua,sizeof(char));
while(!archivo.eof())
{
  Total+=agua;
  archivo.read((char*)&agua,sizeof(char));
}
//ya tenemos en Total el archivo que buscamos;
archivo.close();
//procesamos palabra pistas
if (Procesar(Total,"Pistas: ")==-1){ShowMessage("Error cargando fichero, leyendo palabra \"Pistas: \"");return -1;}
int Total_Pistas=Procesa_Num_Natural(Total);
int Total_Bloques;
int Tipo_De_Pista;
int Mute_Pista;
int Instrumento_Pista;
if (Total_Pistas==-1){ShowMessage("Error cargando fichero, leyendo número de pistas");return -1;}
if (Procesar(Total,"\r\n")==-1){ShowMessage("Error cargando fichero, procesando salto de línea");return -1;}
//para cada pista procesamos los datos
for (int Pista_Actual=0;Pista_Actual<Total_Pistas;Pista_Actual++)
 {
  if (Procesar(Total,"Nº ")==-1){ShowMessage("Error cargando fichero, procesando palabra \"Nº \"");return -1;}
  if (Procesa_Num_Natural(Total)!=Pista_Actual){ShowMessage("Error, las pistas no están en orden, o faltan pistas");return -1;}
  if (Procesar(Total,"\r\n")==-1){ShowMessage("Error cargando fichero, procesando salto de línea");return -1;}
  if (Procesar(Total,"Bloques ")==-1){ShowMessage("Error cargando fichero, procesando palabra \"Bloques \"");return -1;}
  Total_Bloques=Procesa_Num_Natural(Total);
  if (Total_Bloques==-1){ShowMessage("Error cargando fichero, leyendo número de bloques");return -1;}
  if (Procesar(Total," Tipo ")==-1){ShowMessage("Error cargando fichero, procesando palabra \" Tipo \"");return -1;}
  Tipo_De_Pista=Procesa_Num_Natural(Total);
  if (Tipo_De_Pista==-1){ShowMessage("Error carganda tipo de pista");return -1;}
  if (Procesar(Total," Mute ")==-1){ShowMessage("Error cargando fichero, procesando palabra \" Tipo \"");return -1;}
  Mute_Pista=Procesa_Num_Natural(Total);
  if (Mute_Pista==-1){ShowMessage("Error carganda mute pista");return -1;}
  if (Procesar(Total," Instrumento ")==-1){ShowMessage("Error cargando fichero, procesando palabra \" Tipo \"");return -1;}
  Instrumento_Pista=Procesa_Num_Natural(Total);
  if (Instrumento_Pista==-1){ShowMessage("Error carganda instrumento pista");return -1;}
  if (Procesar(Total,"\r\n")==-1){ShowMessage("Error cargando fichero, procesando salto de línea");return -1;}
  //ahora creamos una pista y le metemos los bloques
  Pista* Pista_Temporal;
  Pista_Temporal=new Pista((Tipo_Pista)Tipo_De_Pista);
  Pista_Temporal->Cambia_Mute(Mute_Pista);
  Pista_Temporal->Cambia_Instrumento(Instrumento_Pista);
  Bloque Bloque_Temporal;
  for (int SubBloque_Actual=0;SubBloque_Actual<Total_Bloques;SubBloque_Actual++)
   {//ahora por cada bloque tenemos que procesar
    int Numero_Compases;
    int vacio;
    String Patron_Ritmico;
    int Aplicacion_Horizontal;
    int Aplicacion_Vertical_Mayor;
    int Aplicacion_Vertical_Menor;
    int Octava_Inicial;
    int Sistema;
    int Notas;
    String Inversion;
    String Disposicion;
    int Tipo_Melodia;
    String Curva_Melodica;
    int Pista_Acomp;
    int Num_Divisiones;
    int Fase2,Fase3,Fase4;
    String Progresion;
    String Tipo_Music;
    int ent_temp;
    if (Procesar(Total,"bloque ")==-1){ShowMessage("Error cargando fichero, procesando palabra \"bloque \"");return -1;}
    if (Procesa_Num_Natural(Total)!=SubBloque_Actual){ShowMessage("Error, loss bloques no están en orden, o faltan bloques");return -1;}
    if (Procesar(Total,"\r\n")==-1){ShowMessage("Error cargando fichero, procesando salto de línea");return -1;}
    Bloque Bloque_Temporal;
    if (Procesar(Total,"Compases ")==-1){ShowMessage("Error cargando fichero, procesando palabra \"Compases \"");return -1;}
    Numero_Compases=Procesa_Num_Natural(Total);
    if (Numero_Compases==-1){ShowMessage("Error procesando el número de compases");return -1;}
    if (Procesar(Total," vacio ")==-1){ShowMessage("Error cargando fichero, procesando palabra \" vacio \"");return -1;}
    vacio=Procesa_Num_Natural(Total);
    if (vacio==-1){ShowMessage("Error procesando el mute del bloque");return -1;}
    if (Procesar(Total," Patron ")==-1){ShowMessage("Error cargando fichero, procesando palabra \" Patron \"");return -1;}
    ent_temp=Procesa_Num_Natural(Total);
    if (ent_temp==-1){ShowMessage("Error leyendo el tamaño del patrón rítmico");return -1;}
    if (Procesar(Total," ")==-1){ShowMessage("Error cargando fichero, procesando palabra \" \"");return -1;}
    if (ent_temp==0){Patron_Ritmico=NULL;}
    else{Patron_Ritmico=Procesar2(Total,ent_temp);}
    if (Procesar(Total," Aplicacion_Horizontal ")==-1){ShowMessage("Error cargando fichero, procesando palabra \" Aplicacion_Horizontal \"");return -1;}
    Aplicacion_Horizontal=Procesa_Num_Natural(Total);
    if (Aplicacion_Horizontal==-1){ShowMessage("Error leyendo Aplicacion_Horizontal");return -1;}
    if (Procesar(Total," Aplicacion_Vertical_Mayor ")==-1){ShowMessage("Error cargando fichero, procesando palabra \" Aplicacion_Vertical_Mayor \"");return -1;}
    Aplicacion_Vertical_Mayor=Procesa_Num_Natural(Total);
    if (Aplicacion_Vertical_Mayor==-1){ShowMessage("Error leyendo Aplicacion_Vertical_Mayor");return -1;}
    if (Procesar(Total," Aplicacion_Vertical_Menor ")==-1){ShowMessage("Error cargando fichero, procesando palabra \" Aplicacion_Vertical_Menor \"");return -1;}
    Aplicacion_Vertical_Menor=Procesa_Num_Natural(Total);
    if (Aplicacion_Vertical_Menor==-1){ShowMessage("Error leyendo Aplicacion_Vertical_Menor");return -1;}
    if (Procesar(Total," Octava_Inicial ")==-1){ShowMessage("Error cargando fichero, procesando palabra \" Octava_Inicial \"");return -1;}
    Octava_Inicial=Procesa_Num_Natural(Total);
    if (Octava_Inicial==-1){ShowMessage("Error leyendo Octava_Inicial");return -1;}
    if (Procesar(Total," Sistema ")==-1){ShowMessage("Error cargando fichero, procesando palabra \" Sistema \"");return -1;}
    Sistema=Procesa_Num_Natural(Total);
    if (Sistema==-1){ShowMessage("Error leyendo Sistema");return -1;}
    if (Procesar(Total," Notas ")==-1){ShowMessage("Error cargando fichero, procesando palabra \" Notas \"");return -1;}
    Notas=Procesa_Num_Natural(Total);
    if (Notas==-1){ShowMessage("Error leyendo Notas");return -1;}
    if (Procesar(Total," Inversion ")==-1){ShowMessage("Error cargando fichero, procesando palabra \" Inversion \"");return -1;}
    ent_temp=Procesa_Num_Natural(Total);
    if (ent_temp==-1){ShowMessage("Error leyendo el tamaño delInversion");return -1;}
    if (Procesar(Total," ")==-1){ShowMessage("Error cargando fichero, procesando palabra \" \"");return -1;}
    if (ent_temp==0){Inversion=NULL;}
    else{Inversion=Procesar2(Total,ent_temp);}
    if (Procesar(Total," Disposicion ")==-1){ShowMessage("Error cargando fichero, procesando palabra \" Disposicion \"");return -1;}
    ent_temp=Procesa_Num_Natural(Total);
    if (ent_temp==-1){ShowMessage("Error leyendo el tamaño de la disposición");return -1;}
    if (Procesar(Total," ")==-1){ShowMessage("Error cargando fichero, procesando palabra \" \"");return -1;}
    if (ent_temp==0){Disposicion=NULL;}
    else{Disposicion=Procesar2(Total,ent_temp);}
    if (Procesar(Total," Tipo_Melodia ")==-1){ShowMessage("Error cargando fichero, procesando palabra \" Tipo_Melodia \"");return -1;}
    Tipo_Melodia=Procesa_Num_Natural(Total);
    if (Tipo_Melodia==-1){ShowMessage("Error leyendo Tipo_Melodia");return -1;}
    if (Procesar(Total," Curva_Melodica ")==-1){ShowMessage("Error cargando fichero, procesando palabra \" Curva_Melodica \"");return -1;}
    ent_temp=Procesa_Num_Natural(Total);
    if (ent_temp==-1){ShowMessage("Error leyendo el tamaño de la curva melódica");return -1;}
    if (Procesar(Total," ")==-1){ShowMessage("Error cargando fichero, procesando palabra \" \"");return -1;}
    if (ent_temp==1){Curva_Melodica=NULL;Procesar(Total,"0");}
    else{Curva_Melodica=Procesar2(Total,ent_temp);}
    if (Procesar(Total," Pista_Acomp ")==-1){ShowMessage("Error cargando fichero, procesando palabra \" Curva_Melodica \"");return -1;}
    Pista_Acomp=1;
    if (Total[1]=='-'){Procesar(Total,"-");Pista_Acomp=-1;}
    Pista_Acomp*=Procesa_Num_Natural(Total);
    if (Procesar(Total," Num_Divisiones ")==-1){ShowMessage("Error cargando fichero, procesando palabra \" Num_Divisiones \"");return -1;}
    Num_Divisiones=Procesa_Num_Natural(Total);
    if (Num_Divisiones==-1){ShowMessage("Error leyendo Num_Divisiones");return -1;}
    if (Procesar(Total," Fase2 ")==-1){ShowMessage("Error cargando fichero, procesando palabra \" Fase2 \"");return -1;}
    Fase2=Procesa_Num_Natural(Total);
    if (Fase2==-1){ShowMessage("Error leyendo Fase2");return -1;}
    if (Procesar(Total," Fase3 ")==-1){ShowMessage("Error cargando fichero, procesando palabra \" Fase3 \"");return -1;}
    Fase3=Procesa_Num_Natural(Total);
    if (Fase3==-1){ShowMessage("Error leyendo Fase3");return -1;}
    if (Procesar(Total," Fase4 ")==-1){ShowMessage("Error cargando fichero, procesando palabra \" Fase4 \"");return -1;}
    Fase4=Procesa_Num_Natural(Total);
    if (Fase4==-1){ShowMessage("Error leyendo Fase4");return -1;}
    if (Procesar(Total," Progresion ")==-1){ShowMessage("Error cargando fichero, procesando palabra \" Progresion \"");return -1;}
    ent_temp=Procesa_Num_Natural(Total);
    if (ent_temp==-1){ShowMessage("Error leyendo el tamaño de la curva melódica");return -1;}
    if (Procesar(Total," ")==-1){ShowMessage("Error cargando fichero, procesando palabra \" \"");return -1;}
    if (ent_temp==1){Progresion=NULL;Procesar(Total,"0");}
    else{Progresion=Procesar2(Total,ent_temp);}
    if (Procesar(Total," Tipo_Music ")==-1){ShowMessage("Error cargando fichero, procesando palabra \" Tipo_Music \"");return -1;}
    ent_temp=Procesa_Num_Natural(Total);
    if (ent_temp==-1){ShowMessage("Error leyendo el tamaño de la curva melódica");return -1;}
    if (Procesar(Total," ")==-1){ShowMessage("Error cargando fichero, procesando palabra \" \"");return -1;}
    if (ent_temp==1){Tipo_Music=NULL;Procesar(Total,"0");}
    else{Tipo_Music=Procesar2(Total,ent_temp);}
    if (Procesar(Total," FINBLOQUE\r\n")==-1){ShowMessage("Error finalizando lectura bloque");return -1;}
    Bloque_Temporal.Num_Compases=Numero_Compases;
    Bloque_Temporal.Vacio=vacio;
    Bloque_Temporal.Patron_Ritmico=Patron_Ritmico;
    Bloque_Temporal.Aplicacion_Horizontal=Aplicacion_Horizontal;
    Bloque_Temporal.Aplicacion_Vertical_Mayor=Aplicacion_Vertical_Mayor;
    Bloque_Temporal.Aplicacion_Vertical_Menor=Aplicacion_Vertical_Menor;
    Bloque_Temporal.Octava_Inicial=Octava_Inicial;
    Bloque_Temporal.Es_Sistema_Paralelo=Sistema;
    Bloque_Temporal.Notas_Totales=Notas;
    Bloque_Temporal.Inversion=Inversion;
    Bloque_Temporal.Disposicion=Disposicion;
    Bloque_Temporal.Tipo_Melodia=Tipo_Melodia;
    Bloque_Temporal.Curva_Melodica=Curva_Melodica;
    Bloque_Temporal.N_Pista_Acomp=Pista_Acomp;
    Bloque_Temporal.N_Divisiones=Num_Divisiones;
    Bloque_Temporal.Fase2=Fase2;
    Bloque_Temporal.Fase3=Fase3;
    Bloque_Temporal.Fase4=Fase4;
    Bloque_Temporal.Progresion=Progresion;
    Bloque_Temporal.Tipo_Music=Tipo_Music;
    Pista_Temporal->Inserta_Bloque(Bloque_Temporal);
   }
  if (Procesar(Total,"FINPISTA\r\n")==-1){ShowMessage("Error finalizando lectura Pista");return -1;}
  //una vez introducidos los bloques, metemos la pista en la canción
  Pistas.push_back(Pista_Temporal);
 }
 if (Procesar(Total,"FINCANCION")==-1){ShowMessage("Error finalizando lectura fichero");return -1;}
}
//---------------------------------------------------------------------------
String Dame_Token(String &Total)
{
String salida="";
String NuevoTotal="";
int i=1;
if (Total.Length()<=1){return "FIN";}
while (((Total[i]==' ')||(Total[i]=='\t')||(Total[i]=='\n')||(Total[i]=='\r'))&&(i<=Total.Length()))
{
i++;
}
while ((i<=Total.Length())&&(Total[i]!=' ')&&(Total[i]!='\t')&&(Total[i]!='\n')&&(Total[i]!='\r'))
{
salida+=Total[i];
i++;
}
for (int j=i;j<=Total.Length();j++)
{
NuevoTotal+=Total[j];
}
Total=NuevoTotal;
return salida;
}
