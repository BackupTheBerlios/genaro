//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include <math.h>
#include "Editor.h"


//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------
int TForm1::CalcularArea(int& ancho,int& alto)
{
if ((this->ClientWidth<=150)||(this->ClientHeight<=200))
  {
    ShowMessage("Área demasiado pequeña");
    return -1;
  }
else
  {
    ancho=this->ClientWidth-150;
    alto=this->ClientHeight-200;
    return 0;
  }
}
//---------------------------------------------------------------------------
void TForm1::DibujaColumnas(int NumeroVoces,int NumeroColumnas, int ancho, int alto)
{
//limpiamos lo que haya
TColor temporal=this->Canvas->Brush->Color;
int diferencia=Partitura->DameResolucion()/StrToInt(SelectorZoom->Text);
this->Canvas->Brush->Color=this->Color;
this->Canvas->FillRect(Rect(0,80,this->ClientWidth,this->ClientHeight));
this->Canvas->Brush->Color=temporal;
//para cada fila hacemos:
this->Canvas->Pen->Width=2;
this->Canvas->Font->Size=10;
this->Canvas->Font->Color=clBlack;
for (int i=0;i<=NumeroVoces;i++)
  {
    this->Canvas->MoveTo(100,100+(AltoColumna*i));
    this->Canvas->LineTo(100+(AnchoColumna*NumeroColumnas), 100+(AltoColumna*i));
    //número de voz
    if (i!=NumeroVoces)
    {
      temporal=this->Canvas->Brush->Color;
      this->Canvas->Brush->Style=bsClear;
      this->Canvas->TextOut(40,100+(AltoColumna*i),"Voz "+IntToStr(i));
      this->Canvas->Brush->Color=temporal;
    }
  }
for (int j=0;j<=NumeroColumnas;j++)
  {
    this->Canvas->MoveTo(100+(AnchoColumna*j),100);
    this->Canvas->LineTo(100+(AnchoColumna*j), 100+(AltoColumna*NumeroVoces));
    if (j!=NumeroColumnas)
    {
      temporal=this->Canvas->Brush->Color;
      this->Canvas->Brush->Style=bsClear;
      this->Canvas->TextOut(85+(AnchoColumna*j),80,IntToStr(j+(PosicionActual*diferencia))+"/"+SelectorZoom->Text);
      this->Canvas->Brush->Color=temporal;
    }
  }
  //Ahora deberíamos recorrer uno a uno los indices de la matriz para dibujarlos
  //1- comparamos resoluciones
  if(SelectorZoom->Text==""){ShowMessage("Error eligiendo Zoom");return;}
  if((unsigned int)(StrToInt(SelectorZoom->Text))>Partitura->DameResolucion())
  {
   //Cambiamos la resolución de la partitura
   Partitura->CambiaResolucion((unsigned int)(StrToInt(SelectorZoom->Text)));
  }
  for (int fil=0;fil<NumVoces;fil++)
  {
    for (unsigned int col=PosicionActual;col<(PosicionActual+NumColumnas);col++)
    {//Dibujamos uno a uno todos los recuadros de la matriz
      int diferencia=Partitura->DameResolucion()/StrToInt(SelectorZoom->Text);
      //2- dibujamos los recuadros necesarios con un bucle for
      unsigned int Inicio_X=(col-PosicionActual)*AnchoColumna+100+this->Canvas->Pen->Width;
      unsigned int Inicio_Y=(fil*AltoColumna)+100+this->Canvas->Pen->Width;
      unsigned int Fin_X=(col-PosicionActual+1)*AnchoColumna+100;
      unsigned int Fin_Y=(fil+1)*AltoColumna+100;
      int Avance_X=(Fin_X-Inicio_X)/diferencia;
      //int Avance_Y=(Fin_Y-Inicio_Y)/diferencia;

      for (int relleno=0;relleno<diferencia;relleno++)
      {       //hay que saber cuanto queda sin rellenar para no perder mucho espacio.
      
       //A- zona que queremos pintar, miramos el color pidiendolo a lo que sea del tipo abstracto
       //Para acceder a ella, miramos el componente  (col+posicionactual)*diferencia+relleno,fil
       int nota=Partitura->Dame((col)*diferencia+relleno,fil);
       temporal=this->Canvas->Brush->Color;
       switch (nota)
       {
         case 0 :{this->Canvas->Brush->Color=clGreen;break;}
         case 1 :{this->Canvas->Brush->Color=clRed;break;}
         case 2 :{this->Canvas->Brush->Color=clYellow;break;}
       }
       this->Canvas->FillRect(Rect(Inicio_X+(Avance_X*(relleno)),Inicio_Y,Inicio_X+(Avance_X*(relleno+1)),Fin_Y));
       this->Canvas->Brush->Color=temporal;
      }
    }
  }

this->Canvas->Refresh();

}

//---------------------------------------------------------------------------

void __fastcall TForm1::FormClick(TObject *Sender)
{
if (Inicializado==false) {return;}
TMouse* Raton;//cogemos el ratón para preguntar por su posición
int X,Y;
TPoint Posicion=Raton->CursorPos;
//int temporal=(this->Width-this->ClientWidth)/2;
X=Posicion.x-(this->Left)-AjusteAncho;//4;//pasamos las coordenadas del ratón (globales) a nuestra ventana
Y=Posicion.y-(this->Top)-AjusteAlto;//((this->Height-this->ClientHeight)-4);;
//Comprobamos si está en el área de las columnas
if ((X>100)&&(X<this->ClientWidth-50)&&(Y>100)&&(Y<this->ClientHeight-100))
  {
   // ShowMessage("Dentro");
    CambiarIndice(X,Y);
  }

}
//---------------------------------------------------------------------------
void TForm1::CambiarIndice(int X, int Y)
{
int Columna=floor((X-100)/AnchoColumna);
int Fila=floor((Y-100)/AltoColumna);
if ((Columna>=NumColumnas)||(Fila>=NumVoces))
{return;}
else//Miramos el valor del índice X Y
  {
    int diferencia=Partitura->DameResolucion()/StrToInt(SelectorZoom->Text);
    int tipo_nota=4;//igual que TIPONOTA pero 3=otro tipo, 4=sin valor actual
    int tipo_nota_temporal=4;
    if (diferencia>1)
    {
      for (int i=0;i<diferencia;i++)
      {
        tipo_nota_temporal=Partitura->Dame((Columna+PosicionActual)*diferencia+i,Fila);
        switch (tipo_nota_temporal)
        {
          case 0:
            {
              if ((tipo_nota==4)||(tipo_nota==0))
              {tipo_nota=0;}
              else
              {tipo_nota=3;}
              break;
            }
          case 1:
            {
              if (i==diferencia-1)//si es la última de notas ligadas
              {
                if (tipo_nota==2){tipo_nota=1;}
              }
              else{tipo_nota=3;}
              break;
            }
          case 2:
            {
              if ((tipo_nota==4) || (tipo_nota==2)){tipo_nota=2;}
              else{tipo_nota=3;}
              break;
            }
        }
      }
    }
    else
    {tipo_nota=Partitura->Dame((Columna+PosicionActual)*diferencia+diferencia-1,Fila);}
    //ya tenemos en tipo_nota el tipo de nota que es
    switch (tipo_nota)
    {
      case 3:
        {
          //ShowMessage("Nota compuesta, no se puede modificar");
          for (int k=0;k<diferencia;k++)
            {
              Partitura->Inserta((Columna+PosicionActual)*diferencia+k,Fila,0);
            }
          break;
        }
      case 2:
        {//procedemos a desligar la última nota y ponerla como sencillo
        Partitura->Inserta((Columna+PosicionActual)*diferencia+diferencia-1,Fila,1);break;
        }
      case 1:
        {//si se da el caso 1, cambiamos por silencio, miramos antes si hay notas ligadas
          if (((Columna+PosicionActual)*diferencia+diferencia-1)==0){Partitura->Inserta((Columna+PosicionActual)*diferencia+diferencia-1,Fila,0);}
          else
            {
              if (Partitura->Dame((Columna+PosicionActual)*diferencia+diferencia-2,Fila)==2){ShowMessage("Esta Ligada, no se puede cambiar");}
              else{Partitura->Inserta((Columna+PosicionActual)*diferencia+diferencia-1,Fila,0);}
            }
          break;
        }
      case 0:
        {
          if ((Partitura->Dame((Columna+PosicionActual+1)*diferencia,Fila)==1)||(Partitura->Dame((Columna+PosicionActual+1)*diferencia,Fila)==2))
          {//poner todos a ligado
            for (int k=0;k<diferencia;k++)
            {
              Partitura->Inserta((Columna+PosicionActual)*diferencia+k,Fila,2);
            }
          }
          else
          {//poner todos a ligado menos el último, que es sencillo
            for (int k=0;k<diferencia-1;k++)
            {
              Partitura->Inserta((Columna+PosicionActual)*diferencia+k,Fila,2);
            }
            Partitura->Inserta((Columna+PosicionActual)*diferencia+diferencia-1,Fila,1);
          }
          break;
        }
    }
    Refrescar();
  /*  //ShowMessage(IntToStr(Columna)+" "+IntToStr(Fila));
    //se miraría lo que hay marcado en la posición correspondiente, y se modificaría en ambos sitios
    this->Canvas->Brush->Color=clRed;
    //this->Canvas->Rectangle(Columna*AnchoColumna+100+this->Canvas->Pen->Width,Fila*AltoColumna+100+this->Canvas->Pen->Width,(Columna+1)*AnchoColumna+100,(Fila+1)*AltoColumna+100);
    this->Canvas->FillRect(Rect(Columna*AnchoColumna+100+this->Canvas->Pen->Width,Fila*AltoColumna+100+this->Canvas->Pen->Width,(Columna+1)*AnchoColumna+100,(Fila+1)*AltoColumna+100));*/
  }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormCreate(TObject *Sender)
{
//this->Canvas->MoveTo(this->ClientWidth,this->ClientHeight);
//this->Canvas->LineTo(0, 0);
Inicializado=false;
NumVoces=18;//temporal
NumColumnas=16;
PosicionActual=0;
TotalColumnas=NumColumnas;
Barra->Max=TotalColumnas;
AjusteAncho=((this->Width-this->ClientWidth)/2);
AjusteAlto=(this->Height-this->ClientHeight)-AjusteAncho;

}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button1Click(TObject *Sender)
{
int Ancho,Alto;
unsigned int NVoces=0;
if (!Inicializado)
{
  try
  {
    NVoces=StrToInt(Edit1->Text);
    Partitura=new MatrizNotas(NVoces);
    NumVoces=NVoces;
  }
  catch(...)
  {
    ShowMessage("Números no válidos");
    return;
  }
}
else
{
  try
  {
    NVoces=StrToInt(Edit1->Text);
    MatrizNotas* Aux1;
    MatrizNotas* Aux2;
    Aux2=Partitura;
    Partitura=Aux1;
    delete Aux2;
    Partitura=new MatrizNotas(NVoces);
    NumVoces=NVoces;
  }
  catch(...)
  {
    ShowMessage("Números no válidos");
    return;
  }
}
if (CalcularArea(Ancho,Alto)==-1)
  {
    ShowMessage("Error");
  }
else
  {
    AnchoColumna=Ancho/NumColumnas;
    AltoColumna=Alto/NumVoces;
    DibujaColumnas(NumVoces,NumColumnas,Ancho,Alto);
  }
Inicializado=true;
}
//---------------------------------------------------------------------------





void __fastcall TForm1::SelectorZoomChange(TObject *Sender)
{
  Refrescar();
}
//---------------------------------------------------------------------------
void TForm1::Refrescar()
{

int Ancho,Alto;
unsigned int NVoces=0;
/*if (!Inicializado)
{
  try
  {
    NVoces=StrToInt(Edit1->Text);
    Partitura=new MatrizNotas(NVoces);
    NumVoces=NVoces;
  }
  catch(...)
  {
    ShowMessage("Números no válidos");
    return;
  }
}      */
if (CalcularArea(Ancho,Alto)==-1)
  {
    ShowMessage("Error");
  }
else
  {
    if (Inicializado)
    {
      DibujaColumnas(NumVoces,NumColumnas,Ancho,Alto);
    }
  }
Inicializado=true;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::BarraChange(TObject *Sender)
{
if (Inicializado)
{
if (Barra->Position==TotalColumnas)
  {
    Barra->Max++;
    TotalColumnas++;
  }
PosicionActual=Barra->Position;
Refrescar();
}
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button2Click(TObject *Sender)
{
if (Inicializado)
{
  Partitura->CreaFicheroTexto();
}
else
{
  ShowMessage("No hay nada que exportar, anda so gandul haz algo...");
}
}
//---------------------------------------------------------------------------

