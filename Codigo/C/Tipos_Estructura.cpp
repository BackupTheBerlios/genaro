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
Bloque_Vacio.Curva_Melodica="";
Bloque_Vacio.N_Pista_Acomp=-1;
Bloque_Vacio.Octava_Inicial=1;
Bloque_Vacio.Tipo_Melodia=0;
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
    fichero_salida<<"Progresion "<<bloque_temp.Progresion.Length()<<" ";
    for (int k=0;k<bloque_temp.Progresion.Length();k++)
    {
      fichero_salida<<bloque_temp.Progresion[k+1];
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

//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------

