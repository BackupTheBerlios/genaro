//---------------------------------------------------------------------------

#include <vcl.h>
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
      Pista_Nueva->Inserta_Bloque(temporal);
    }
  }
  Pistas.push_back(Pista_Nueva);
}
//---------------------------------------------------------------------------
void Cancion::Nuevo_Bloque(int Num_Compases,String P_Ritmico,String Disposicion, String Inversion)
{
Bloque Bloque_Vacio;
Bloque_Vacio.Num_Compases=Num_Compases;
Bloque_Vacio.Notas_Totales=0;
Bloque_Vacio.Vacio=true;
Bloque_Vacio.Patron_Ritmico=P_Ritmico;
Bloque_Vacio.Disposicion=Disposicion;
Bloque_Vacio.Inversion=Inversion;
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
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
