//---------------------------------------------------------------------------

#include <vcl.h>
#include <fstream.h>
#pragma hdrstop

#include "TiposAbstractos.h"

//---------------------------------------------------------------------------

#pragma package(smart_init)

TipoNota MatrizNotas::Dame(unsigned int num_col,unsigned int num_voz)
{

  if ((Cancion.size()>num_voz)&&(Cancion[num_voz].size()>num_col))
  {
    return Cancion[num_voz][num_col];
  }
  else
  {     /*//borrar de aqui
  if(i>j){return SIMPLE;}
  if (i==j){return LIGADO;}//hasta aquí*/
    return SILENCIO;
  }
}

//---------------------------------------------------------------------------
void MatrizNotas::Inserta(unsigned int num_col, unsigned int num_voz, TipoNota nota)
{
if (num_voz>Voces)
  {
    ShowMessage("Voz inexistente");
    return;
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
      Cancion[num_voz].push_back(SILENCIO);
    }
  }
Cancion[num_voz][num_col]=nota;
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
   TipoNota temporal;
   for (int numcolumnas=0;numcolumnas<Columnas;numcolumnas++)
   {
      //cogemos el valor actual que hay en la posición numvoces,numcolumnas y transformamos si es necesario
      temporal=Dame(numcolumnas,numvoces);
      for (int k=0;k<diferencia;k++)
      {
        switch (temporal)
        {
          case SILENCIO:{NuevaVoz.push_back(SILENCIO);break;}
          case LIGADO:{NuevaVoz.push_back(LIGADO);break;}
          case SIMPLE:
          {
            if (k==diferencia-1)
            {
              NuevaVoz.push_back(SIMPLE);
            }
            else
            {
              NuevaVoz.push_back(LIGADO);
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
void MatrizNotas::CreaFicheroTexto()
{
ofstream archivo;
AnsiString fichero="prueba.txt";
archivo.open(fichero.c_str());
archivo<<"VOCES "<<Voces<<" \n";
archivo<<"COLUMNAS "<<Columnas<<" \n";
archivo<<"RESOLUCION "<<Resolucion<<" \n";
for (int voz=0;voz<Voces;voz++)
{
  for (int col=0;col<Columnas;col++)
  {
    TipoNota temporal=Dame(col,voz);
    switch (temporal)
    {
      case SIMPLE:{archivo<<"SIMPLE ";break;}
      case SILENCIO:{archivo<<"SILENCIO ";break;}
      case LIGADO:{archivo<<"LIGADO ";break;}
    }
  }
  archivo<<"FIN \n";
}

archivo.close();
}

//---------------------------------------------------------------------------
