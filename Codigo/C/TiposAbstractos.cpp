//---------------------------------------------------------------------------

#include <vcl.h>
#include <fstream.h>
#pragma hdrstop

#include "TiposAbstractos.h"

//---------------------------------------------------------------------------

#pragma package(smart_init)

TipoNotaCompuesto MatrizNotas::Dame(unsigned int num_col,unsigned int num_voz)
{

  if ((Cancion.size()>num_voz)&&(Cancion[num_voz].size()>num_col))
  {
    return Cancion[num_voz][num_col];
  }
  else
  {
    TipoNotaCompuesto temporal;
    temporal.Duracion=SILENCIO;
    temporal.Velocity=50;
    return temporal;
  }
}

//---------------------------------------------------------------------------
void MatrizNotas::Cambia(unsigned int num_col,unsigned int num_voz,TipoNotaCompuesto nueva_nota)
{

  if ((Cancion.size()>num_voz)&&(Cancion[num_voz].size()>num_col))
  {
    Cancion[num_voz][num_col]=nueva_nota;
  }
  else
  {
    Inserta(num_col,num_voz,nueva_nota.Duracion,nueva_nota.Velocity);
  }
}

//---------------------------------------------------------------------------
void MatrizNotas::Inserta(unsigned int num_col, unsigned int num_voz, TipoNota nota, int velocity)
{
if (num_voz+1>Voces)
  {
    Voces=num_voz+1;
  }
if (num_voz>=Cancion.size())
  {
    for (unsigned int k=Cancion.size();k<=num_voz;k++)
    {
      Voz NuevaVoz;
      NuevaVoz.clear();
      Cancion.push_back(NuevaVoz);
    }
  }
if (num_col>=Cancion[num_voz].size())
  {
    for (unsigned int z=Cancion[num_voz].size();z<=num_col;z++)
    {
      TipoNotaCompuesto temporal;
      temporal.Duracion=SILENCIO;
      temporal.Velocity=50;
      Cancion[num_voz].push_back(temporal);
    }
  }
TipoNotaCompuesto temporal;
temporal.Duracion=nota;
temporal.Velocity=velocity;
Cancion[num_voz][num_col]=temporal;
if (num_col>=Columnas){Columnas=num_col+1;}
}

//---------------------------------------------------------------------------
void MatrizNotas::CambiaResolucion(unsigned int NuevaResolucion)
{
  if (NuevaResolucion<=Resolucion)
  {
    return;
  }
  int diferencia=NuevaResolucion/Resolucion;
  Resolucion=NuevaResolucion;
  //creamos nuevos vectores.
  Musica CancionTemp;
  CancionTemp.clear();
  //bucle for 1, para recorrer las voces de 0 a numvoces
  for (int numvoces=0;numvoces<Voces;numvoces++)
  {
   Voz NuevaVoz;
   NuevaVoz.clear();
  //bucle for 2, para recorrer las columnas, de 0 a numcolumnas*diferencia
   TipoNotaCompuesto temporal;
   for (int numcolumnas=0;numcolumnas<Columnas;numcolumnas++)
   {
      //cogemos el valor actual que hay en la posición numvoces,numcolumnas y transformamos si es necesario
      temporal=Dame(numcolumnas,numvoces);
      TipoNotaCompuesto auxiliar=temporal;
      for (int k=0;k<diferencia;k++)
      {
        switch (temporal.Duracion)
        {
          case SILENCIO:{NuevaVoz.push_back(temporal);break;}
          case LIGADO:{NuevaVoz.push_back(temporal);break;}
          case SIMPLE:
          {
            if (k==diferencia-1)
            {
              auxiliar.Duracion=SIMPLE;
              NuevaVoz.push_back(auxiliar);
            }
            else
            {
              auxiliar.Duracion=LIGADO;
              NuevaVoz.push_back(auxiliar);
            }
          break;
          }
        }

      }


   }
   CancionTemp.push_back(NuevaVoz);
  }
  //adaptamos la matriz para adecuarnos a la nueva resolucion, crenado nuevos vectores voces y convirtiendo los anteriores a estos.
  Cancion.clear();
  Cancion=CancionTemp;
  Columnas=Columnas*diferencia;  
}

//---------------------------------------------------------------------------
void MatrizNotas::CreaFicheroTexto(String fichero)
{
ofstream archivo;
archivo.open(fichero.c_str());
archivo<<"VOCES "<<Voces<<"\n";
archivo<<"COLUMNAS "<<Columnas<<"\n";
archivo<<"RESOLUCION "<<Resolucion;
for (int voz=0;voz<Voces;voz++)
{
archivo<<"\n";
  for (int col=0;col<Columnas;col++)
  {
    TipoNotaCompuesto temporal=Dame(col,voz);
    switch (temporal.Duracion)
    {
      case SIMPLE:{archivo<<"SIMPLE ";break;}
      case SILENCIO:{archivo<<"SILENCIO ";break;}
      case LIGADO:{archivo<<"LIGADO ";break;}
    }
    //Ahora tendríamos que añadir el velocity
    if (temporal.Duracion!=SILENCIO){archivo<<temporal.Velocity<<" ";}
  }
  archivo<<"FIN";
}

archivo.close();
}

//---------------------------------------------------------------------------
void MatrizNotas::CargaFicheroTexto(AnsiString fichero)
{
ifstream archivo;
//AnsiString fichero="prueba.txt";
archivo.open(fichero.c_str());
char temporal[16];
String A_Comparar="VOCES ";
for (int i=0;i<5;i++)
{
  archivo>>temporal[i];
  if (temporal[i]!=A_Comparar[i+1]){ShowMessage("Archivo Corrupto/No válido");return;}
}
//comparamos que pone "Voces "
int voces_archivo;
int columnas_archivo;
archivo>>voces_archivo;
A_Comparar="COLUMNAS ";
for (int i=0;i<8;i++)
{
  archivo>>temporal[i];
  if (temporal[i]!=A_Comparar[i+1]){ShowMessage("Archivo Corrupto/No válido");return;}
}
archivo>>columnas_archivo;
A_Comparar="RESOLUCION ";
for (int i=0;i<10;i++)
{
  archivo>>temporal[i];
  if (temporal[i]!=A_Comparar[i+1]){ShowMessage("Archivo Corrupto/No válido");return;}
}
archivo>>Resolucion;
//queda cargar todos los patrones rítmicos, eso si, antes tenemos que limpiar las listas :)
Cancion.clear();
int velocity;
for (int voz=0;voz<voces_archivo;voz++)//por cada fila
{
  for (int columna=0;columna<columnas_archivo;columna++)//por cada elemento de la fila
  {//leemos 6
    for (int i=0;i<6;i++)
    {
      archivo>>temporal[i];
    }
    switch (temporal[2])
    {
      case 'L':
      {
        archivo>>temporal[6];archivo>>temporal[7];
        break;
      }
      case 'G':
      {
        archivo>>velocity;
        Inserta(columna,voz,LIGADO,velocity);
        break;
      }
      case 'M':
      {
        archivo>>velocity;
        Inserta(columna,voz,SIMPLE,velocity);
        break;
      }
    }
  }
  for (int i=0;i<3;i++)
  {
    archivo>>temporal[i];
  }   //Esto es fin
}
archivo.close();
CambiaResolucion(128);
/*
archivo<<"VOCES "<<Voces<<"\n";
archivo<<"COLUMNAS "<<Columnas<<"\n";
archivo<<"RESOLUCION "<<Resolucion;
for (int voz=0;voz<Voces;voz++)
{
archivo<<"\n";
  for (int col=0;col<Columnas;col++)
  {
    TipoNotaCompuesto temporal=Dame(col,voz);
    switch (temporal.Duracion)
    {
      case SIMPLE:{archivo<<"SIMPLE ";break;}
      case SILENCIO:{archivo<<"SILENCIO ";break;}
      case LIGADO:{archivo<<"LIGADO ";break;}
    }
    //Ahora tendríamos que añadir el velocity
    if (temporal.Duracion!=SILENCIO){archivo<<temporal.Velocity<<" ";}
  }
  archivo<<"FIN";
}
  */

}

//----------------------------------------------------------------------------
void MatrizNotas::NuevaFila()
{
Voz NuevaVoz;
NuevaVoz.clear();
Cancion.push_back(NuevaVoz);
Voces++;
}
