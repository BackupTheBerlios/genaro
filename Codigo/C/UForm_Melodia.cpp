//---------------------------------------------------------------------------

#include <vcl.h>
#include <stdio.h>
#include <stdlib.h>
#include <fstream.h>
#pragma hdrstop
#include "UForm_Melodia.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm_Melodia *Form_Melodia;
//---------------------------------------------------------------------------
__fastcall TForm_Melodia::TForm_Melodia(TComponent* Owner)
  : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void TForm_Melodia::Dibuja_Curva()
{
X_Inicial=Panel_Curva_Melodia->Left;
Y_Inicial=Panel_Curva_Melodia->Top;
Ancho=Panel_Curva_Melodia->Width;
Alto=Panel_Curva_Melodia->Height;
X_Final=X_Inicial+Ancho;
Y_Final=Y_Inicial+Alto;
this->Canvas->FillRect(Rect(X_Inicial,Y_Inicial,X_Final,Y_Final));
this->Canvas->Pen->Width=2;
this->Canvas->MoveTo(X_Inicial,Y_Inicial);
this->Canvas->LineTo(X_Inicial,Y_Final);
this->Canvas->LineTo(X_Final,Y_Final);
this->Canvas->LineTo(X_Final,Y_Inicial);
this->Canvas->LineTo(X_Inicial,Y_Inicial);
this->Canvas->Pen->Width=1;
//Dibuja_Esqueleto();
int P_X=0,P_Y=Puntos[0];
for (int i=1;i<100;i++)
 {
  if (Puntos[i]!=-1)
  {//dibujamos puntos
  //dibujamos linea
  this->Canvas->MoveTo(X_Inicial+P_X*4,Y_Inicial+P_Y*2);
  this->Canvas->LineTo(X_Inicial+i*4,Y_Inicial+Puntos[i]*2);
  //actualizamos último punto
    P_X=i;P_Y=Puntos[i];
  }
 }
}
//---------------------------------------------------------------------------
void __fastcall TForm_Melodia::Boton_Aceptar_MelodiaClick(TObject *Sender)
{
Dibuja_Curva();
}

//---------------------------------------------------------------------------
void TForm_Melodia::Lee_Puntos(Cancion* Music,int Fila,int Columna)
{
Musica_G=Music;
Fila_P=Fila;
Columna_P=Columna;
Bloque Bloque_A_Manipular=Musica_G->Dame_Pista(Fila_P)->Dame_Bloque(Columna_P);
if (Bloque_A_Manipular.Curva_Melodica=="")
{
Puntos[0]=50;
Puntos[99]=50;
for (int i=1;i<99;i++)
{
Puntos[i]=-1;
}
}
else
{
ifstream Lectura_Puntos;
String fichero=Bloque_A_Manipular.Curva_Melodica+'b';
Lectura_Puntos.open(fichero.c_str());
for (int i=0;i<100;i++)
{
int guarra;
Lectura_Puntos>>guarra;
Puntos[i]=guarra;
}
}
}
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
void __fastcall TForm_Melodia::FormClick(TObject *Sender)
{
TMouse* Raton;//cogemos el ratón para preguntar por su posición
int X,Y;
TPoint Posicion=Raton->CursorPos;
X=Posicion.x-(this->Left)-((this->Width-this->ClientWidth)/2);//pasamos las coordenadas del ratón (globales) a nuestra ventana
Y=Posicion.y-(this->Top)-((this->Height-this->ClientHeight)-((this->Width-this->ClientWidth)/2));
if ((X<X_Final)&&(X>X_Inicial)&&(Y<Y_Final)&&(Y>Y_Inicial))
{
  if (Radio_Aniade_Puntos->Checked)
  {
    Puntos[(X-X_Inicial)/4]=(Y-Y_Inicial)/2;
  }
  if (Radio_Mover_Puntos->Checked)
  {
    //recorrer y buscar el púnto más cercano
    int P_X,P_Y,R;
    R=0;
    bool punto_vacio=true;
    P_Y=(Y-Y_Inicial)/2;
    P_X=(X-X_Inicial)/4;
    while (punto_vacio)
    {
    if (P_X-R>=0)
     {
      if (Puntos[P_X-R]!=-1){punto_vacio=false;P_X=P_X-R;}
     }
    if (P_X+R<=99)
     {
      if (Puntos[P_X+R]!=-1){punto_vacio=false;P_X=P_X+R;}
     }
    R++;
    }
    Puntos[P_X]=P_Y;
  }
  if (Radio_Eliminar_Puntos->Checked)
  {
    //recorrer y buscar el púnto más cercano
    int P_X,P_Y,R;
    R=0;
    bool punto_vacio=true;
    P_Y=(Y-Y_Inicial)/2;
    P_X=(X-X_Inicial)/4;
    while (punto_vacio)
    {
    if (P_X-R>=0)
     {
      if (Puntos[P_X-R]!=-1){punto_vacio=false;P_X=P_X-R;}
     }
    if (P_X+R<=99)
     {
      if (Puntos[P_X+R]!=-1){punto_vacio=false;P_X=P_X+R;}
     }
    R++;
    }
    if ((P_X!=0)&&(P_X!=99))
    {Puntos[P_X]=-1;}
  }
}
Dibuja_Curva();
}
//---------------------------------------------------------------------------



void __fastcall TForm_Melodia::FormPaint(TObject *Sender)
{
Dibuja_Curva();
}
//---------------------------------------------------------------------------



void __fastcall TForm_Melodia::Button1Click(TObject *Sender)
{
Guardar_Melodia();
}
//---------------------------------------------------------------------------
void TForm_Melodia::Guardar_Melodia()
{
Bloque Bloque_A_Manipular=Musica_G->Dame_Pista(Fila_P)->Dame_Bloque(Columna_P);
//creamos fichero
ofstream fichero_salida;
ofstream fichero_salida2;
String fichero1;
String fichero2;
fichero1="CurvaMelodica_"+IntToStr(Fila_P)+"_"+IntToStr(Columna_P)+".cm";
fichero2=fichero1+'b';
fichero_salida.open(fichero1.c_str());//este nos lo tendrían que dar
fichero_salida2.open(fichero2.c_str());
int P_X,P_Y;
int P_X2,P_Y2;
P_X=0;P_Y=Puntos[P_X];
float Avance=0;

for (int j=0;j<100;j++)
{
fichero_salida2<<Puntos[j]<<" ";
}
fichero_salida<<Puntos[P_X]<<" ";//escribimos punto 0
for (int i=1;i<100;i++)
 {
  if (Puntos[i]!=-1)
   {
    P_X2=i;P_Y2=Puntos[P_X2];
    if (P_Y2>P_Y)
     {
      Avance=(float)((float)(P_Y2-P_Y)/(float)(P_X2-P_X));
     }
    else
     {
      Avance=-(float)((float)(P_Y-P_Y2)/(float)(P_X2-P_X));
     }
    for (int j=1;j<P_X2-P_X-1;j++)
     {
      //escribimos P_Y+j*Avance
      fichero_salida<<(int)(P_Y+(j*Avance))<<" ";
     }
    //escribimos P_Y2
    fichero_salida<<Puntos[P_X2]<<" ";
    P_X=P_X2;P_Y=P_Y2;
   }
 }
fichero_salida.close();
fichero_salida2.close();
Bloque_A_Manipular.Curva_Melodica=fichero1;
Musica_G->Dame_Pista(Fila_P)->Cambia_Bloque(Bloque_A_Manipular,Columna_P);
}
