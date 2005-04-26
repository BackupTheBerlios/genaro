//---------------------------------------------------------------------------

#include <vcl.h>
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
void TForm_Melodia::Lee_Puntos()
{
Puntos[0]=50;
Puntos[99]=50;
for (int i=1;i<99;i++)
{
Puntos[i]=-1;
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



