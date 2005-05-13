//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include <math.h>
#include <dir.h>
#include <process.h>
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
void TForm1::Dibuja_Esqueleto()
{
//NO debemos olvidar los parámetros necesarios después de finalizar la función, como ancho columna,
//nº de columnas... todo eso.
//Variables que vamos a necesitar, deberían estar declaradas en la clase, o en la llamada a la fcion
int Min_Ancho_Columna=Ancho_Minimo_Columna_Pantalla;//lo del grosor lápiz pos pasamos 4 kilos
int Altura_Columna=Alto_Minimo_Columna_Pantalla;//10+grosor lápiz
int Ancho,Alto;//de 150 hasta 150+ancho, y de 200 a 200+alto
int Numero_Columnas;
if (CalcularArea(Ancho,Alto)==-1) {Etiqueta_Mensajes->Caption="Error, ancho no adecuado";return;}
//int Max_Ancho_Columna=Ancho/2;
Numero_Columnas=1;//número mínimo de columnas
//ahora hay que comprobar el número de columnas mas adecuado al zoom actual.
//primero comprobaremos que la division permite columnas de ese ancho, si no,
//habrá que ver cual es el máximo número de columnas permitido.
int Columnas_Temporales=Numero_Columnas*Barra_Zoom->Position;
int Maximo_Columnas_Temporal=Ancho/Min_Ancho_Columna;
if (Columnas_Temporales>Maximo_Columnas_Temporal){Columnas_Temporales=Maximo_Columnas_Temporal;}
int Ancho_Columna_Temporal=Ancho/Columnas_Temporales;

int Numero_Filas=Alto/Altura_Columna;
int Numero_Filas_A_Dibujar=Partitura->DameVoces()-BarraVoces->Position;
int Fin_Columnas=100+((Numero_Filas-Numero_Filas_A_Dibujar)*Altura_Columna);
//a estas alturas sabemos cual es el número máximo de columnas que podemos dibujar
//ahora dibujamos las rayas de columnas y filas con 2 bucles for

TColor temporal=this->Canvas->Brush->Color;
this->Canvas->Brush->Color=this->Color;
this->Canvas->FillRect(Rect(0,80,this->ClientWidth,this->ClientHeight));
this->Canvas->Brush->Color=temporal;    //Borrabamos todo
this->Canvas->Font->Size=10;
this->Canvas->Font->Color=clBlack;
//para cada fila hacemos:
this->Canvas->Pen->Width=1;
this->Canvas->Pen->Color=clBlack;
int duracion_nota=pow(2,Barra_Grid->Position);
int Maximo_Semi_Columnas=Ancho_Columna_Temporal/Min_Ancho_Columna;
int Numero_Semi_Columnas=duracion_nota;
if (Numero_Semi_Columnas>Maximo_Semi_Columnas){Numero_Semi_Columnas=Maximo_Semi_Columnas;}
int Ancho_Semi_Columna=Ancho_Columna_Temporal/Numero_Semi_Columnas;
//AAGUUU AGUUU INTENTO CHUNGO FIXME (INICIO)    es para las semi_columnas
float el_pico=(float)((float)((float)Ancho_Columna_Temporal/(float)Numero_Semi_Columnas)-(float)Ancho_Semi_Columna);
float el_pico_acumulado=0;
Pico_Ajuste_Semi_Columnas=el_pico;
//AAGUUU AGUUU INTENTO CHUNGO FIXME (FIN)
//ahora al igual que con ancho_columna tenemos que mirar el ancho_semi_columna y tal para dibujar las semicolumnas.
int maximo_final=0;
for (int columna=0;columna<=Columnas_Temporales;columna++)
{
  this->Canvas->Pen->Color=clBlue;
  el_pico_acumulado=0;
  for (int semi_columna=0;semi_columna<Numero_Semi_Columnas;semi_columna++)
  {
    el_pico_acumulado+=el_pico;
    this->Canvas->MoveTo(100+(columna*Ancho_Columna_Temporal)+(semi_columna*Ancho_Semi_Columna)+el_pico_acumulado,100);
    this->Canvas->LineTo(100+(columna*Ancho_Columna_Temporal)+(semi_columna*Ancho_Semi_Columna)+el_pico_acumulado,this->ClientHeight-Fin_Columnas);//FIXMEVOZ
    if (maximo_final<100+(columna*Ancho_Columna_Temporal)+(semi_columna*Ancho_Semi_Columna)+el_pico_acumulado){maximo_final=100+(columna*Ancho_Columna_Temporal)+(semi_columna*Ancho_Semi_Columna)+el_pico_acumulado;};
    el_pico_acumulado+=el_pico;
  }
  this->Canvas->Pen->Color=clBlack;
  this->Canvas->MoveTo(100+(columna*Ancho_Columna_Temporal),95);
  this->Canvas->LineTo(100+(columna*Ancho_Columna_Temporal),this->ClientHeight-Fin_Columnas);//FIXMEVOZ
  if (columna!=Columnas_Temporales)
  {
      if((Ancho_Columna_Temporal>25)||(columna%2==0))
      {
        TColor color_temporal=this->Canvas->Brush->Color;
        this->Canvas->Brush->Style=bsClear;
        int desplazamiento=3;
        desplazamiento+=4*(IntToStr(PosicionActual+columna).Length()-1);
        this->Canvas->TextOut(100-desplazamiento+(columna*Ancho_Columna_Temporal),80,IntToStr(PosicionActual+columna));//Aquí falta el posición actual*resolucion+columna
        this->Canvas->Brush->Color=color_temporal;
      }
  }

}
for (int fila=0;fila<=Numero_Filas_A_Dibujar;fila++)
{
  this->Canvas->MoveTo(40,100+(fila*Altura_Columna));
  this->Canvas->LineTo(maximo_final,100+(fila*Altura_Columna));
  if (fila!=Numero_Filas_A_Dibujar)
  {
    TColor color_temporal=this->Canvas->Brush->Color;
    if (Fila_Seleccionada==fila)
    {
      this->Canvas->Font->Color=clPurple;
      this->Canvas->Font->Style=TFontStyles()<< fsBold;
    }
    this->Canvas->Brush->Style=bsClear;
    this->Canvas->TextOut(40,100+(Altura_Columna*fila),"Voz "+IntToStr(FilaActual+fila));//falta el fila+desplazamiento_filas
    this->Canvas->Brush->Color=color_temporal;
    this->Canvas->Font->Color=clBlack;
    this->Canvas->Font->Style=TFontStyles();
  }

}
//Datos que tenemos que guardar para dibujar las notas.
Numero_Columnas_Pantalla=Columnas_Temporales;
Ancho_Columna_Pantalla=Ancho_Columna_Temporal;
Numero_Filas_Pantalla=Numero_Filas;
Numero_Semi_Columnas_Pantalla=Numero_Semi_Columnas;
Ancho_Semi_Columnas_Pantalla=Ancho_Semi_Columna;
}

//---------------------------------------------------------------------------
int TForm1::CalcularArea(int& ancho,int& alto)
{
if ((this->ClientWidth<=100)||(this->ClientHeight<=200))
  {
    Etiqueta_Mensajes->Caption="Área demasiado pequeña";
    return -1;
  }
else
  {
    ancho=this->ClientWidth-100;
    alto=this->ClientHeight-200;
    return 0;
  }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormClick(TObject *Sender)
{
Etiqueta_Mensajes->Caption="";
if (Inicializado==false) {return;}
TMouse* Raton;//cogemos el ratón para preguntar por su posición
int X,Y;
TPoint Posicion=Raton->CursorPos;
X=Posicion.x-(this->Left)-((this->Width-this->ClientWidth)/2);//pasamos las coordenadas del ratón (globales) a nuestra ventana
Y=Posicion.y-(this->Top)-((this->Height-this->ClientHeight)-((this->Width-this->ClientWidth)/2));
//Ahora deberíamos distinguir entre distintos botones pulsados

//1- Herramienta de añadir nota
//ShowMessage(IntToStr(Y));
if ((X>100)&&(Y>100)&&(Y<this->ClientHeight-100))
{
  //ShowMessage("Dentro");
  //SI el estado del editor es insertar
  if (Estado_Trabajo==0)
  {
    CambiarIndice(X,Y);
  }
  //Si el estado del editor es borrar
  //Borra Indice (X Y)
  if (Estado_Trabajo==1)
  {
    bool temporal=Ajustar_Grid->Checked;
    Ajustar_Grid->Checked=false;
    BorrarIndice(X,Y);
    Ajustar_Grid->Checked=temporal;
  }

  //Si el estado es elegir fila, entonces
  //Actualiza Fila Pantalla(Y)
  if (Estado_Trabajo==2)
  {
    Actualiza_Fila_Seleccionada(Y);
  }
  Dibuja_Esqueleto();
  Dibuja_Notas();
}
if ((X>100)&&(Y>this->ClientHeight-100)&&(Y<this->ClientHeight-25))
{
  bool temporal=Ajustar_Grid->Checked;
  Ajustar_Grid->Checked=false;
  int nuevo_velocity=this->ClientHeight-Y-26;//de 0 a 83//26 a 99 (25_100)
  nuevo_velocity=(nuevo_velocity*125)/73;
//  ShowMessage(IntToStr(nuevo_velocity));
  CambiarVelocity(X, nuevo_velocity);
  Dibuja_Esqueleto();
  Dibuja_Notas();
  Ajustar_Grid->Checked=temporal;
}
BarraVoces->Max=Partitura->DameVoces()-1;
}
//---------------------------------------------------------------------------
void TForm1::CambiarVelocity(int X, int nuevo_velocity)
{
//1- Habrá que averiguar a que columna pertenece, y luego a la semicolumna.
int Columna_Pulsada=(X-100)/Ancho_Columna_Pantalla;
int Semi_Columna_Pulsada=(X-100-(Ancho_Columna_Pantalla*Columna_Pulsada))/((float)(Ancho_Semi_Columnas_Pantalla+Pico_Ajuste_Semi_Columnas));
//int duracion_nota=pow(2,Barra_Nota->Position);
int duracion_grid=pow(2,Barra_Grid->Position);
if(Semi_Columna_Pulsada>(duracion_grid-1)){Semi_Columna_Pulsada=duracion_grid-1;}

//Ahora habría que hacer una regla de 3 para ver que semi_columna de las dibujadas es la que correspondería con la real
int duracion_real_nota=Partitura->DameResolucion();
float ancho_ideal_semi_columna=(float)((float)Ancho_Columna_Pantalla/(float)duracion_real_nota);
int desplazamiento_en_x=X-100-(Ancho_Columna_Pantalla*Columna_Pulsada);
int Semi_Columna_Real=desplazamiento_en_x/ancho_ideal_semi_columna;
if (Semi_Columna_Real>(duracion_real_nota-1)){Semi_Columna_Real=duracion_real_nota-1;}
if (Ajustar_Grid->Checked==true)
  {
    float multiplicador_semi_columnas=(float)((float)duracion_real_nota/(float)Numero_Semi_Columnas_Pantalla);
    Semi_Columna_Real=multiplicador_semi_columnas*Semi_Columna_Pulsada;
  }
//ya tenemos la posición pulsada por el usuario, Columna_Pulsada, Semi_Columna_Real
bool otra_nota=false;
int primera_posicion=(Columna_Pulsada+PosicionActual)+Semi_Columna_Real;
if (Partitura->Dame(primera_posicion,Fila_Seleccionada+FilaActual).Duracion==0)
  {return;}
//ahora tenemos que recorrer hacia atras hasta encontrar una primera posición para cambiar el velocity
int retroceso=0;
while ((otra_nota==false)&&(primera_posicion-retroceso-1>=0))
{
  if (Partitura->Dame(primera_posicion-retroceso-1,Fila_Seleccionada+FilaActual).Duracion!=2)
  {otra_nota=true;}//habríamos encontrado el inicio de la nota
  else
  {
    retroceso++;
  }
}
//sabemos que la nota va desde primera_posicion-retroceso, hasta el primer duracion==1
bool fin_nota=false;
while (!fin_nota)
{
  if (Partitura->Dame(primera_posicion-retroceso,Fila_Seleccionada+FilaActual).Duracion==1)
  {fin_nota=true;}
  TipoNotaCompuesto nota_temporal=Partitura->Dame(primera_posicion-retroceso,Fila_Seleccionada+FilaActual);
  nota_temporal.Velocity=nuevo_velocity;
  Partitura->Cambia(primera_posicion-retroceso,Fila_Seleccionada+FilaActual,nota_temporal);
  retroceso--;
}
}
//---------------------------------------------------------------------------
void TForm1::CambiarIndice(int X, int Y)
{
//1- Habrá que averiguar a que fila y columna pertenece, y luego a la semicolumna.
int Fila_Pulsada=(Y-100)/Alto_Minimo_Columna_Pantalla;

if ((Fila_Pulsada+BarraVoces->Position)>=Partitura->DameVoces())
{
  Etiqueta_Mensajes->Caption="Has pinchado en una Voz inexistente";
  return;
}

Fila_Seleccionada=Fila_Pulsada;
int Columna_Pulsada=(X-100)/Ancho_Columna_Pantalla;
int Semi_Columna_Pulsada=(X-100-(Ancho_Columna_Pantalla*Columna_Pulsada))/((float)(Ancho_Semi_Columnas_Pantalla+Pico_Ajuste_Semi_Columnas));
int duracion_nota=pow(2,Barra_Nota->Position);
int duracion_grid=pow(2,Barra_Grid->Position);
if(Semi_Columna_Pulsada>(duracion_grid-1)){Semi_Columna_Pulsada=duracion_grid-1;}
//ShowMessage("Columna: "+IntToStr(Columna_Pulsada)+" Fila: "+IntToStr(Fila_Pulsada)+" Semi Columna: "+IntToStr(Semi_Columna_Pulsada));

//Ahora habría que hacer una regla de 3 para ver que semi_columna de las dibujadas es la que correspondería con la real
int duracion_real_nota=Partitura->DameResolucion();
float ancho_ideal_semi_columna=(float)((float)Ancho_Columna_Pantalla/(float)duracion_real_nota);
int desplazamiento_en_x=X-100-(Ancho_Columna_Pantalla*Columna_Pulsada);
int Semi_Columna_Real=desplazamiento_en_x/ancho_ideal_semi_columna;
if (Semi_Columna_Real>(duracion_real_nota-1)){Semi_Columna_Real=duracion_real_nota-1;}
if (Ajustar_Grid->Checked==true)
  {
    float multiplicador_semi_columnas=(float)((float)duracion_real_nota/(float)Numero_Semi_Columnas_Pantalla);
    Semi_Columna_Real=multiplicador_semi_columnas*Semi_Columna_Pulsada;
  }
//ShowMessage(IntToStr(Semi_Columna_Real));
//ya tenemos la posición pulsada por el usuario, Fila_Pulsada, Columna_Pulsada, Semi_Columna_Real

//1- recorremos las posiciones donde supuestamente vamos a añadir la nota y nos aseguramos de que no hay nada
int total_casillas_a_recorrer=duracion_real_nota/duracion_nota;
bool esta_libre=true;
int primera_posicion=((Columna_Pulsada+PosicionActual)*(duracion_real_nota))+Semi_Columna_Real;
int Fila_Pulsada_Real=Fila_Pulsada+FilaActual;
for (int i=0;i<total_casillas_a_recorrer;i++)
{
  if (Partitura->Dame(primera_posicion+i,Fila_Pulsada_Real).Duracion!=0)
  {esta_libre=false;}
}
if (esta_libre==false){Etiqueta_Mensajes->Caption="No se puede añadir, pisa otra nota añadida anteriormente";return;}
//2- recorremos esas posiciones añadiendo una nota "ligado" hasta llegar a la última, que añadimos "simple"
int velocity_elegida=Velocity_Selector->Max-Velocity_Selector->Position;
for (int i=0;i<total_casillas_a_recorrer;i++)
{
  if (i==total_casillas_a_recorrer-1)
  {
    Partitura->Inserta(primera_posicion+i,Fila_Pulsada_Real,(TipoNota)1,velocity_elegida);//Velocity sin añadir como es debido
  }
  else
  {
    Partitura->Inserta(primera_posicion+i,Fila_Pulsada_Real,(TipoNota)2,velocity_elegida);//Velocity sin añadir como es debido
  }
}
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  char work_dir[255];
  getcwd(work_dir, 255);
  Dir_Trabajo_Inicial=work_dir;
Numero_Columnas_Pantalla=1;
Ancho_Columna_Pantalla=1;
Numero_Filas_Pantalla=1;
Numero_Semi_Columnas_Pantalla=1;
Ancho_Semi_Columnas_Pantalla=1;
Ancho_Minimo_Columna_Pantalla=4;
Alto_Minimo_Columna_Pantalla=15;
Inicializado=false;
Estado_Trabajo=0;
/*
int esta=FileOpen("Codigo", fmOpenRead);
if (esta==-1)
{
  String directorio_de_trabajo="..\\..\\";
  if (chdir(directorio_de_trabajo.c_str())==-1)
  {ShowMessage("Error cambiando el directorio de trabajo");}
  else
  {
    getcwd(work_dir, 255);
    Dir_Trabajo_Inicial=work_dir;
  }
}
*/
}
//---------------------------------------------------------------------------
void __fastcall TForm1::BarraChange(TObject *Sender)
{
if (Inicializado)
{
  PosicionActual=Barra->Position;
  Dibuja_Esqueleto();
  Dibuja_Notas();
}
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Barra_ZoomChange(TObject *Sender)
{
if (Inicializado)
{
  Dibuja_Esqueleto();
  Dibuja_Notas();
}
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Barra_NotaChange(TObject *Sender)
{
int duracion_nota=pow(2,Barra_Nota->Position);
Etiqueta_Duracion_Nota->Caption="1/"+IntToStr(duracion_nota);
if (Inicializado)
{
  if(duracion_nota>Partitura->DameResolucion())
  { //Cambiamos la resolución de la partitura
    Partitura->CambiaResolucion(duracion_nota);
  }
  Dibuja_Esqueleto();
  Dibuja_Notas();
}
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Nuevo1Click(TObject *Sender)
{
if (!Inicializado)
{
  Partitura=new MatrizNotas(4);
  Partitura->CambiaResolucion(128);
  Inicializado=true;
  PosicionActual=0;
  FilaActual=0;
  Fila_Seleccionada=0;
  BarraVoces->Max=Partitura->DameVoces()-1;
}
else
{
    MatrizNotas* Aux1;
    MatrizNotas* Aux2;
    Aux2=Partitura;
    Partitura=Aux1;
    delete Aux2;
    Partitura=new MatrizNotas(4);
    Partitura->CambiaResolucion(128);
    Inicializado=true;
    PosicionActual=0;
    FilaActual=0;
    Fila_Seleccionada=0;
    BarraVoces->Max=Partitura->DameVoces()-1;    
}
Dibuja_Esqueleto();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::BarraVocesChange(TObject *Sender)
{
if (Inicializado)
{
  FilaActual=BarraVoces->Position;
  Dibuja_Esqueleto();
  Dibuja_Notas();
}
}
//---------------------------------------------------------------------------
void __fastcall TForm1::GuardarPatrnRtmico1Click(TObject *Sender)
{
if (Guardar_Patron->Execute()==false){return;}
String fichero_destino=Guardar_Patron->FileName;
if (Inicializado)
{
  Partitura->CreaFicheroTexto(fichero_destino);
}
else
{
  Etiqueta_Mensajes->Caption="No has generado ningún patrón rítmico";
}
if (chdir(Dir_Trabajo_Inicial.c_str())==-1)
{ShowMessage("Error cambiando el directorio de trabajo");}
}
//---------------------------------------------------------------------------
void TForm1::Dibuja_Notas()
{
//1- Vamos a recorrer todas las filas del programa
int resolucion=Partitura->DameResolucion();
for (int fila=0;fila<Numero_Filas_Pantalla;fila++)
{//la fila correspondiente es FilaActual+fila
  //2- ahora recorremos las columnas
  for (int columna=0;columna<=Numero_Columnas_Pantalla;columna++)
  {//la columna es PosicionActual*partitura->resolucion+columna
   for (int semi_columna=0;semi_columna<resolucion;semi_columna++)
   {
    //3- ahora tenemos que coger cada nota y mirar el tamaño que ocupa. recorremos para saber lo que ocupa la nota, y luego actualizamos "columna"
    //3.1 Miramos cuantas notas forman la nota
    int total_duracion_nota=0;
    int velocity_nota=0;
    int semi_columna_inicial=semi_columna;
    bool seguir=true;
    int borrame_pero_ya=((PosicionActual+columna)*resolucion)+semi_columna-1;
    if (borrame_pero_ya>=0)
    {
      if (Partitura->Dame(borrame_pero_ya,FilaActual+fila).Duracion==LIGADO)
      {
       seguir=false;
      }
    }
    while (seguir)
    {
      seguir=false;
      switch (Partitura->Dame(((PosicionActual+columna)*resolucion)+semi_columna,FilaActual+fila).Duracion)
      {
        case 0:
            {break;}
        case 1:
            {total_duracion_nota++;velocity_nota=Partitura->Dame(((PosicionActual+columna)*resolucion)+semi_columna,FilaActual+fila).Velocity;break;}
        case 2:
            {total_duracion_nota++;seguir=true;semi_columna++;break;}
      }
    }

    //3.2 Calculamos el ancho ideal de la nota

    float Ancho_Ideal_Nota_Unidad=(float)((float)Ancho_Columna_Pantalla/(float)resolucion);
    float Ancho_Ideal_Nota=(Ancho_Ideal_Nota_Unidad)*total_duracion_nota;
    int Ancho_Real_Nota=Ancho_Ideal_Nota;
    if (Ancho_Ideal_Nota<Ancho_Minimo_Columna_Pantalla){Ancho_Real_Nota=Ancho_Minimo_Columna_Pantalla;}
    //ya tenemos el ancho de la nota que queremos marcar.
    //3.3 calculamos donde dibujar la nota, calculamos avance ideal por nota y lo multiplicamos por semi_columna
    float Avance_Ideal_Nota=(float)((float)Ancho_Columna_Pantalla/(float)resolucion);
    int X_Inicial=100+columna*Ancho_Columna_Pantalla+Avance_Ideal_Nota*semi_columna_inicial;//+(Pico_Ajuste_Semi_Columnas*semi_columna_inicial);
    int X_Final=X_Inicial+Ancho_Real_Nota;//+(Pico_Ajuste_Semi_Columnas*total_duracion_nota);
    int Y_Inicial=100+fila*Alto_Minimo_Columna_Pantalla;
    int Y_Final=Y_Inicial+Alto_Minimo_Columna_Pantalla;
    //Aquí deberíamos ver el velocity para saber que color rellenar
    if (total_duracion_nota!=0)
    {
      this->Canvas->Pen->Color=clWhite;
      TColor color_nota=0x00000000;
      color_nota+=velocity_nota*2;
      this->Canvas->Brush->Color=color_nota;
//      this->Canvas->Brush->Color=clRed;
      this->Canvas->Rectangle(X_Inicial,Y_Inicial,X_Final,Y_Final);
      if ((Fila_Seleccionada==fila)||(Estado_Trabajo==2))
      {//Dibujamos el velocity, que va desde X_inicial a X_Final, pero va desde client_Height a eso+velocity
        int ajuste_cuadro_velocity=velocity_nota*73/125;
        this->Canvas->Rectangle(X_Inicial,this->ClientHeight-25 ,X_Final,this->ClientHeight-25-ajuste_cuadro_velocity);
      }
    }
    //no hay que olvidarse de avanzar la casillas correspondientes a total_duracion_nota(ya realizado en el while)
   }
  }
}
}

//---------------------------------------------------------------------------
void __fastcall TForm1::Barra_GridChange(TObject *Sender)
{
int duracion_nota=pow(2,Barra_Grid->Position);
Resolucion_Grid->Caption="1/"+IntToStr(duracion_nota);
if (Inicializado)
{
  if(duracion_nota>Partitura->DameResolucion())
  { //Cambiamos la resolución de la partitura
    Partitura->CambiaResolucion(duracion_nota);
  }
  Dibuja_Esqueleto();
  Dibuja_Notas();
}
}
//---------------------------------------------------------------------------

void __fastcall TForm1::CargarPatrnRtmico1Click(TObject *Sender)
{

String fichero;
if (Cargar_Patron->Execute()==false)
{return;}
fichero=Cargar_Patron->FileName;
if (Inicializado)
{
    MatrizNotas* Aux1;
    MatrizNotas* Aux2;
    Aux2=Partitura;
    Partitura=Aux1;
    delete Aux2;
    Partitura=new MatrizNotas(4);
    Partitura->CambiaResolucion(128);
    Inicializado=true;
    PosicionActual=0;
    FilaActual=0;
    Fila_Seleccionada=0;
    BarraVoces->Max=Partitura->DameVoces()-1;
  Partitura->CargaFicheroTexto(fichero);
  Partitura->CambiaResolucion(128);
  Inicializado=true;
  PosicionActual=0;
  FilaActual=0;
  Fila_Seleccionada=0;
  BarraVoces->Max=Partitura->DameVoces()-1;
}
else
{
  Partitura=new MatrizNotas();
  Inicializado=true;
  Partitura->CargaFicheroTexto(fichero);
  Fila_Seleccionada=0;
  Partitura->CambiaResolucion(128);
  PosicionActual=0;
  FilaActual=0;
  BarraVoces->Max=Partitura->DameVoces()-1;  
}
if (chdir(Dir_Trabajo_Inicial.c_str())==-1)
{ShowMessage("Error cambiando el directorio de trabajo");}
Dibuja_Esqueleto();
Dibuja_Notas();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::ToolButton1Click(TObject *Sender)
{
Estado_Trabajo=0;
if (Inicializado)
{
  Dibuja_Esqueleto();
  Dibuja_Notas();
}
}
//---------------------------------------------------------------------------

void __fastcall TForm1::ToolButton2Click(TObject *Sender)
{
Estado_Trabajo=1;
if (Inicializado)
{
  Dibuja_Esqueleto();
  Dibuja_Notas();
}
}
//---------------------------------------------------------------------------

void __fastcall TForm1::ToolButton3Click(TObject *Sender)
{
Estado_Trabajo=2;
if (Inicializado)
{
  Dibuja_Esqueleto();
  Dibuja_Notas();
}
}
//---------------------------------------------------------------------------
void TForm1::Actualiza_Fila_Seleccionada(int Y)
{
int Fila_Pulsada=(Y-100)/Alto_Minimo_Columna_Pantalla;
Fila_Seleccionada=Fila_Pulsada;
}
//---------------------------------------------------------------------------
void TForm1::BorrarIndice(int X, int Y)
{
//1- Habrá que averiguar a que fila y columna pertenece, y luego a la semicolumna.
int Fila_Pulsada=(Y-100)/Alto_Minimo_Columna_Pantalla;
Fila_Seleccionada=Fila_Pulsada;
int Columna_Pulsada=(X-100)/Ancho_Columna_Pantalla;
int Semi_Columna_Pulsada=(X-100-(Ancho_Columna_Pantalla*Columna_Pulsada))/((float)(Ancho_Semi_Columnas_Pantalla+Pico_Ajuste_Semi_Columnas));
//int duracion_nota=pow(2,Barra_Nota->Position);
int duracion_grid=pow(2,Barra_Grid->Position);
if(Semi_Columna_Pulsada>(duracion_grid-1)){Semi_Columna_Pulsada=duracion_grid-1;}
//ShowMessage("Columna: "+IntToStr(Columna_Pulsada)+" Fila: "+IntToStr(Fila_Pulsada)+" Semi Columna: "+IntToStr(Semi_Columna_Pulsada));

//Ahora habría que hacer una regla de 3 para ver que semi_columna de las dibujadas es la que correspondería con la real
int duracion_real_nota=Partitura->DameResolucion();
float ancho_ideal_semi_columna=(float)((float)Ancho_Columna_Pantalla/(float)duracion_real_nota);
int desplazamiento_en_x=X-100-(Ancho_Columna_Pantalla*Columna_Pulsada);
int Semi_Columna_Real=desplazamiento_en_x/ancho_ideal_semi_columna;
if (Semi_Columna_Real>(duracion_real_nota-1)){Semi_Columna_Real=duracion_real_nota-1;}
if (Ajustar_Grid->Checked==true)
  {
    float multiplicador_semi_columnas=(float)((float)duracion_real_nota/(float)Numero_Semi_Columnas_Pantalla);
    Semi_Columna_Real=multiplicador_semi_columnas*Semi_Columna_Pulsada;
  }
//ShowMessage(IntToStr(Semi_Columna_Real));
//ya tenemos la posición pulsada por el usuario, Fila_Pulsada, Columna_Pulsada, Semi_Columna_Real

//1- recorremos las posiciones donde supuestamente vamos a añadir la nota y nos aseguramos de que no hay nada
bool esta_libre=true;
bool otra_nota=false;
int primera_posicion=((Columna_Pulsada+PosicionActual)*(duracion_real_nota))+Semi_Columna_Real;
int Fila_Pulsada_Real=Fila_Pulsada+FilaActual;
if (Partitura->Dame(primera_posicion,Fila_Pulsada_Real).Duracion==0)
  {esta_libre=false;Etiqueta_Mensajes->Caption="No hay ninguna nota que borrar";return;}

//ahora tenemos que recorrer hacia atras hasta encontrar una primera posición para cambiar el velocity
int retroceso=0;
while ((otra_nota==false)&&(primera_posicion-retroceso-1>=0))
{
  if (Partitura->Dame(primera_posicion-retroceso-1,Fila_Pulsada_Real).Duracion!=2)
  {otra_nota=true;}//habríamos encontrado el inicio de la nota
  else
  {
    retroceso++;
  }
}
//sabemos que la nota va desde primera_posicion-retroceso, hasta el primer duracion==1
bool fin_nota=false;
while (!fin_nota)
{
  if (Partitura->Dame(primera_posicion-retroceso,Fila_Pulsada_Real).Duracion==1)
  {fin_nota=true;}
  TipoNotaCompuesto nota_temporal;
  nota_temporal.Velocity=50;
  nota_temporal.Duracion=0;
  Partitura->Cambia(primera_posicion-retroceso,Fila_Pulsada_Real,nota_temporal);
  retroceso--;
}

}
//---------------------------------------------------------------------------
void __fastcall TForm1::Boton_Nueva_VozClick(TObject *Sender)
{
if (Inicializado)
{
  Partitura->NuevaFila();
  BarraVoces->Max=Partitura->DameVoces()-1;
  Dibuja_Esqueleto();
  Dibuja_Notas();  
}
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Velocity_SelectorChange(TObject *Sender)
{
Etiqueta_Mensajes->Caption="Velocity reajustado a "+IntToStr(Velocity_Selector->Max-Velocity_Selector->Position);  
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormPaint(TObject *Sender)
{
if (Inicializado)
{
  Dibuja_Esqueleto();
  Dibuja_Notas(); 
}
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Previsualizar1Click(TObject *Sender)
{
//creamos el fichero en patron.temp
//llamamos a haskell para crear midi
//llamar a timidity para reproducirlo

}
//---------------------------------------------------------------------------

void __fastcall TForm1::Barra_TempoChange(TObject *Sender)
{
  Label_Tempo->Caption=IntToStr(Barra_Tempo->Position);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::ToolButton5Click(TObject *Sender)
{
if (Inicializado==false){return;}
//creamos el fichero en patron.temp
String Patron_Temporal="PatronTemporal.pr";
Partitura->CreaFicheroTexto("PatronTemporal.pr");
//llamamos a haskell para crear midi
  String Ruta_Haskell=".\\Codigo\\Haskell\\runhugs.exe";
  String Ruta_Codigo=".\\Codigo\\Haskell\\main.lhs";
  String Orden="previsualizaPatron";
  String Tempo=IntToStr(Barra_Tempo->Position);
  String Destino_Midi="MidiPatron.mid";
  char work_dir[255];
  getcwd(work_dir, 255);
  String directorio_trabajo=work_dir;
  String directorio_trabajob=work_dir;
  directorio_trabajo="\""+directorio_trabajo+"\"";
  int valor_spawn=spawnl(P_WAIT,Ruta_Haskell.c_str(),Ruta_Haskell.c_str(),Ruta_Codigo.c_str(),directorio_trabajo.c_str(),Orden.c_str(),Patron_Temporal.c_str(),Tempo.c_str(),Destino_Midi.c_str(),NULL);
  if (valor_spawn==-1)
  {ShowMessage("Error ejecutando el runhugs de haskell.");}
//llamar a timidity para reproducirlo

String arg1="-int";//opciones de inferfaz
String arg2="-a";//activar antialiasing
String arg3="-p";//polifonia
String arg4="256(a)";
String arg5="-U";//Unload instruments entre cancion y cancion
String arg6="A90";
String arg7="Ww";//mas opciones de inferfaz
String arg8="EFchorus=1,60";
String arg9="EFreverb=1,60";
String arg10="EFdelay=b";
String arg11="s44100";
String timi_exe=".\\Timidity\\timidity.exe";
String Ruta_Midi="\""+directorio_trabajob+"\\"+Destino_Midi+"\"";
valor_spawn=spawnl(P_NOWAIT	,timi_exe.c_str(),timi_exe.c_str(),arg1.c_str(),arg2.c_str(),arg3.c_str(),arg4.c_str(),arg5.c_str(),arg6.c_str(),arg7.c_str(),arg8.c_str(),arg9.c_str(),arg10.c_str(),arg11.c_str(),Ruta_Midi.c_str(),NULL);
  if (valor_spawn==-1)
  {ShowMessage("Error ejecutando Timidity");}

}
//---------------------------------------------------------------------------


