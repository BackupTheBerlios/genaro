//---------------------------------------------------------------------------

#include <vcl.h>
#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <fstream.h>
#include <dir.h>
#include <process.h>
#pragma hdrstop

#include "FormularioPrincipal.h"
#include "FormParametrosTimidity.h"
#include "Interfaz_Timidity.h";
#include "UForm_Melodia.h";
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

void __fastcall TForm1::FormCreate(TObject *Sender)
{
unidad_de_union=new Unidad_Nexo();
Inicializa_Patrones_Ritmicos();
//FIXME DIR de trabajo
    String directorio_de_trabajo="..\\..\\";
    if (chdir(directorio_de_trabajo.c_str())==-1)
    {ShowMessage("Error cambiando el directorio de trabajo");};
//FIXME DIR DE TRABAJO
//inicializar valores de columnas y tal
Alto_Fila=24;
Ancho_Columnas=25;
Numero_Filas_A_Dibujar=0;
Numero_Bloques=0;
Ancho_Espacio_Estatico=50;
}
//---------------------------------------------------------------------------
void TForm1::Inicializa_Patrones_Ritmicos()
{
  DIR *dir;
  struct dirent *ent;
  if ((dir = opendir("..\\..\\PatronesRitmicos")) == NULL)
  {
    ShowMessage("Error leyendo directorio");
  }
  else
  {
    Selector_Patron_Ritmico->Items->Clear();
    while ((ent = readdir(dir)) != NULL)
    {
      //1- comprueba que es válido para añadir a la lista
      int tamanio=0;
      while(ent->d_name[tamanio]!='\0')
      {
        tamanio++;
      }
      if (tamanio<4)
      {
        //este no nos vale
      }
      else if (((ent->d_name[tamanio-1]=='t')||(ent->d_name[tamanio-1]=='T'))&&((ent->d_name[tamanio-2]=='x')||(ent->d_name[tamanio-2]=='X'))&&((ent->d_name[tamanio-3]=='t')||(ent->d_name[tamanio-3]=='T')))
      {
      //2- añade a la lista de patrones rítmicos.
      Selector_Patron_Ritmico->Items->Add(ent->d_name);
      Selector_Patron_Ritmico->Text=ent->d_name;
      }
    }

  }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Barra_Numero_AcordesChange(TObject *Sender)
{
Etiqueta_Numero_Acordes->Caption=IntToStr(Barra_Numero_Acordes->Position);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Barra_Numero_MutacionesChange(TObject *Sender)
{
Etiqueta_Numero_Mutaciones->Caption=IntToStr(Barra_Numero_Mutaciones->Position);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Barra_Numero_RepeticionesChange(TObject *Sender)
{
Etiqueta_Numero_Repeticiones->Caption=IntToStr(Barra_Numero_Repeticiones->Position);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Salir1Click(TObject *Sender)
{
Close();  
}
//---------------------------------------------------------------------------

void __fastcall TForm1::EditordePianola1Click(TObject *Sender)
{
  String Editor_Pianola=".\\Codigo\\C\\PEditor.exe";
  int valor_spawn=spawnl(P_WAIT,Editor_Pianola.c_str(),Editor_Pianola.c_str(),NULL);
  if (valor_spawn==-1)
  {ShowMessage("Error ejecutando el editor de pianola.");}
}
//---------------------------------------------------------------------------


void __fastcall TForm1::Reproduccin1Click(TObject *Sender)
{
Form2->Show();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button3Click(TObject *Sender)
{
//1- abrir el midi "musica_genara.mid" si da error, salimos
int esta=FileOpen(".\\musica_genara.mid", fmOpenRead);
if  (esta==-1) {return;}
else {FileClose(esta);}
//2- coger los parametros de la reproduccion
String timi_exe=".\\Timidity\\timidity.exe";
String Amplificacion_Volumen=IntToStr(Form2->Dame_Amplificacion());
String EFchorus=Form2->Dame_EFchorus();
String EFreverb=Form2->Dame_EFreverb();
String EFdelay=Form2->Dame_EFdelay();
String frecuency=IntToStr(Form2->Dame_Frecuency());
String Ruta_Patch_File=Form2->Dame_Ruta_Patch_File();
String Ruta_Midi=".\\musica_genara.mid";
//3- invocar la reproducción y quedarnos con el número de proceso
Ejecuta_Timidity_Reproduccion(timi_exe, Amplificacion_Volumen, EFchorus,EFreverb,EFdelay,frecuency, Ruta_Patch_File,Ruta_Midi);

}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button1Click(TObject *Sender)
{
  String Ruta_codigo_haskell;
  String Ruta_haskell;
  String Ruta_prolog;

// FIXME FIXME esto está si no se usa fichero de configuración
    Ruta_prolog=".\\Codigo\\Prolog\\mainArgs.exe";  //"..\\Prolog\\mainArgs.exe";
    Ruta_haskell=".\\Codigo\\Haskell\\runhugs.exe";  //"..\\Haskell\\runhugs.exe";
    Ruta_codigo_haskell=".\\Codigo\\Haskell\\main.lhs";  //"..\\Haskell\\main.lhs";
// FIXME FIXME fin del  fixme

  /*ifstream fichero_conf;
  int esta=FileOpen("configuracion.cfg", fmOpenRead);
  if (esta!=-1)
  {
    FileClose(esta);
    fichero_conf.open("configuracion.cfg",ios::binary);
    String buffer1="";
    int tamano_string=0;
    char c_temp;
    fichero_conf.read((char*)&tamano_string,sizeof(int));
    for (int i=0;i<tamano_string;i++)
    {
      fichero_conf.read((char*)&c_temp,sizeof(char));
      buffer1+=c_temp;
    }
    Ruta_prolog=buffer1;
    Ruta_haskell="..\\Haskell\\runhugs.exe";
    Ruta_codigo_haskell = "..\\Haskell\\main.lhs";
    fichero_conf.close();
  }
  else
  {
      Ruta_prolog="";
      Ruta_codigo_haskell="";
      Ruta_haskell="";
      ofstream fichero_guardar;
      try
      {
        fichero_guardar.open("configuracion.cfg",ios::binary);
        //1- elegir archivo sicstus.exe
        if (OpenDialog->Execute()==false){ShowMessage("No ha especificado el mainArgs");return;};
        Ruta_prolog=OpenDialog->FileName;
        int tamanio=Ruta_prolog.Length();
        fichero_guardar.write((char*)&tamanio,sizeof(int));
        for (int i=0;i<tamanio;i++)
        {
          fichero_guardar.write((char*)&Ruta_prolog[i+1],sizeof(char));
        }
        //Ruta_prolog="..\\Prolog";
        Ruta_haskell="..\\Haskell\\runhugs.exe";
        Ruta_codigo_haskell = "..\\Haskell\\main.lhs";
        fichero_conf.close();
      }
      catch(...){}
  }*/
unidad_de_union->Inicializacion(Ruta_prolog,Ruta_haskell,Ruta_codigo_haskell);

//SI NO HAY NINGUNO SELECCIONADO EN PATRONES RITMICOS COGEMOS UNO

unidad_de_union->Componer(IntToStr(Barra_Numero_Acordes->Position),IntToStr(Barra_Numero_Mutaciones->Position),Selector_Patron_Ritmico->Text,IntToStr(Barra_Numero_Repeticiones->Position));
  
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button4Click(TObject *Sender)
{
//1- abrir el midi "musica_genara.mid" si da error, salimos
int esta=FileOpen(".\\musica_genara.mid", fmOpenRead);
if  (esta==-1) {return;}
else {FileClose(esta);}
//2- coger los parametros de la reproduccion
String timi_exe=".\\Timidity\\timidity.exe";
String Amplificacion_Volumen=IntToStr(Form2->Dame_Amplificacion());
String EFchorus=Form2->Dame_EFchorus();
String EFreverb=Form2->Dame_EFreverb();
String EFdelay=Form2->Dame_EFdelay();
String frecuency=IntToStr(Form2->Dame_Frecuency());
String Ruta_Patch_File=Form2->Dame_Ruta_Patch_File();
String Ruta_Midi=".\\musica_genara.mid";
//3- invocar la reproducción y quedarnos con el número de proceso
Ejecuta_Timidity_Conversion(timi_exe, Amplificacion_Volumen, EFchorus,EFreverb,EFdelay,frecuency, Ruta_Patch_File,Ruta_Midi);

}
//---------------------------------------------------------------------------
void TForm1::Dibuja_Cancion()
{
X_Inicial=Panel_Musica->Left;
Y_Inicial=Panel_Musica->Top;
Ancho=Panel_Musica->Width;
Alto=Panel_Musica->Height;
X_Final=X_Inicial+Ancho;
Y_Final=Y_Inicial+Alto;
this->Canvas->Pen->Width=2;
this->Canvas->MoveTo(X_Inicial,Y_Inicial);
this->Canvas->LineTo(X_Inicial,Y_Final);
this->Canvas->LineTo(X_Final,Y_Final);
this->Canvas->LineTo(X_Final,Y_Inicial);
this->Canvas->LineTo(X_Inicial,Y_Inicial);
this->Canvas->Pen->Width=1;
Dibuja_Esqueleto();
}
//---------------------------------------------------------------------------
void TForm1::Dibuja_Esqueleto()
{
/*Numero_Filas=8;
Alto_Fila=10;
Ancho_Columnas=25;
Numero_Filas_A_Dibujar=8;
Ancho_Espacio_Estatico=50;  */
int Numero_Filas=Alto/Alto_Fila;
//dibujamos interiores
Dibuja_Musica();
//Dibujamos columnas estáticas
this->Canvas->Pen->Width=2;
this->Canvas->MoveTo(X_Inicial+Ancho_Espacio_Estatico,Y_Inicial);
this->Canvas->LineTo(X_Inicial+Ancho_Espacio_Estatico,Y_Final);
this->Canvas->Pen->Width=1;

//Dibujamos las filas
for (int i=0;((i<=Numero_Filas)&&(i<=Numero_Filas_A_Dibujar));i++)
 {
  this->Canvas->MoveTo(X_Inicial,Y_Inicial+(i*Alto_Fila));
  this->Canvas->LineTo(X_Final,Y_Inicial+(i*Alto_Fila));
 }
int Col_Actual=1;
while ((X_Inicial+Ancho_Columnas*Col_Actual+Ancho_Espacio_Estatico)<(X_Final))
 {
  this->Canvas->MoveTo((X_Inicial+Ancho_Columnas*Col_Actual+Ancho_Espacio_Estatico),Y_Inicial);
  this->Canvas->LineTo((X_Inicial+Ancho_Columnas*Col_Actual+Ancho_Espacio_Estatico),Y_Final);
  Col_Actual++;
 }

}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormClick(TObject *Sender)
{
TMouse* Raton;//cogemos el ratón para preguntar por su posición
int X,Y;
TPoint Posicion=Raton->CursorPos;
X=Posicion.x-(this->Left)-((this->Width-this->ClientWidth)/2);//pasamos las coordenadas del ratón (globales) a nuestra ventana
Y=Posicion.y-(this->Top)-((this->Height-this->ClientHeight)-((this->Width-this->ClientWidth)/2));
if ((X<X_Final)&&(X>X_Inicial)&&(Y<Y_Final)&&(Y>Y_Inicial))
{
  Accion_Click(X,Y);
}
//habrá que calcular donde pincha
}
//---------------------------------------------------------------------------
void TForm1::Accion_Click(int X, int Y)
{
int Y_Relativo=Y-Y_Inicial;
Columna_Pulsada=0;
Fila_Pulsada=Y_Relativo/Alto_Fila;
//ShowMessage(Fila_Pulsada);
int X_Relativo=X-X_Inicial-Ancho_Espacio_Estatico;
if (X_Relativo<0)
 {
  //Activar cuadro de cabecera de pista
  if (Fila_Pulsada<Numero_Filas_A_Dibujar)
  {
    Cuadro_Cabecera_Pista();
  }
 }
else
 {
  Columna_Pulsada=X_Relativo/Ancho_Columnas;
  if ((Fila_Pulsada<Numero_Filas_A_Dibujar)&&(Columna_Pulsada<(Numero_Bloques)))
   {
    Cuadro_Bloque_Pista();
   }
  else
   {
    Panel_Bloque->Visible=false;
   }
 }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::NuevoClick(TObject *Sender)
{

if (Inicializado)
{
  Dibuja_Cancion();
}
else
{
  String Ruta_codigo_haskell;
  String Ruta_haskell;
  String Ruta_prolog;
  Ruta_prolog=".\\Codigo\\Prolog\\mainArgs.exe";  //"..\\Prolog\\mainArgs.exe";
  Ruta_haskell=".\\Codigo\\Haskell\\runhugs.exe";  //"..\\Haskell\\runhugs.exe";
  Ruta_codigo_haskell=".\\Codigo\\Haskell\\main.lhs";  //"..\\Haskell\\main.lhs";
  unidad_de_union->Inicializacion(Ruta_prolog,Ruta_haskell,Ruta_codigo_haskell);
  Inicializado=true;
  Musica_Genaro=new Cancion;
  Numero_Filas_A_Dibujar=0;
  Numero_Bloques=0;
  Dibuja_Cancion();
}
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Boton_Nueva_PistaClick(TObject *Sender)
{
if (Inicializado)
{
  Musica_Genaro->Nueva_Pista(Barra_Tipo_Pista->Position);
  Numero_Filas_A_Dibujar++;
  Dibuja_Cancion();
}
}
//---------------------------------------------------------------------------
void TForm1::Cuadro_Cabecera_Pista()
{
//1- pon todos a invisible
Panel1->Visible=false;
Panel_Bloque->Visible=false;
//2- pon este a visiible
Panel_Tipo_Pista->Visible=true;
//3- pon los valores que se deban poner
Tipo_Pista->Caption=IntToStr(Musica_Genaro->Dame_Tipo_Pista(Fila_Pulsada));
Nombre_Pista->Caption="Pista_"+IntToStr(Fila_Pulsada);
Mute_Pista->Checked=Musica_Genaro->Dame_Pista(Fila_Pulsada)->Dame_Mute();
Instrumento_Pista->Text=(Instrumento_Pista->Items->Strings[Musica_Genaro->Dame_Pista(Fila_Pulsada)->Dame_Instrumento()]);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Boton_Guarda_Cambios_PistaClick(TObject *Sender)
{
  Pista* Puntero_A_Pista=Musica_Genaro->Dame_Pista(Fila_Pulsada);
  Puntero_A_Pista->Cambia_Mute(Mute_Pista->Checked);
  Puntero_A_Pista->Cambia_Instrumento(Instrumento_Pista->Items->IndexOf(Instrumento_Pista->Text));
  Dibuja_Cancion();  
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Boton_Nuevo_BloqueClick(TObject *Sender)
{
if ((Inicializado)&&(Numero_Filas_A_Dibujar>0))
{
  Musica_Genaro->Nuevo_Bloque(Barra_N_Compases_Bloque->Position,Selector_Patron_Ritmico->Text,Lista_Disposicion->Text,Lista_Inversion->Text);
  Numero_Bloques++;
  Dibuja_Cancion();  
}
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Barra_Notas_TotalesChange(TObject *Sender)
{
Etiqueta_Numero_Total_De_Notas->Caption=IntToStr(Barra_Notas_Totales->Position);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Sistema_ParaleloClick(TObject *Sender)
{
if (Sistema_Paralelo->Checked)
 {
  Etiqueta_Inversion->Enabled=true;
  Etiqueta_Disposicion->Enabled=true;
  Lista_Inversion->Enabled=true;
  Lista_Disposicion->Enabled=true;
  Edit_Semilla->Enabled=false;
  Check_Semilla->Enabled=false;
 }
else
 {
  Etiqueta_Inversion->Enabled=false;
  Etiqueta_Disposicion->Enabled=false;
  Lista_Inversion->Enabled=false;
  Lista_Disposicion->Enabled=false;
  Edit_Semilla->Enabled=true;
  Check_Semilla->Enabled=true;
 }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Sistema_ContinuoClick(TObject *Sender)
{
if (Sistema_Paralelo->Checked)
 {
  Etiqueta_Inversion->Enabled=true;
  Etiqueta_Disposicion->Enabled=true;
  Lista_Inversion->Enabled=true;
  Lista_Disposicion->Enabled=true;
  Edit_Semilla->Enabled=false;
  Check_Semilla->Enabled=false;  
 }
else
 {
  Etiqueta_Inversion->Enabled=false;
  Etiqueta_Disposicion->Enabled=false;
  Lista_Inversion->Enabled=false;
  Lista_Disposicion->Enabled=false;
  Edit_Semilla->Enabled=true;
  Check_Semilla->Enabled=true;
 }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Bloque_VacioClick(TObject *Sender)
{
/*if (Bloque_Vacio->Checked)
{
  Tab_Patron_Ritmico->Enabled=false;
  Tab_Progresion->Enabled=false;
  Tab_Melodia->Enabled=false;
}
else
{
  Tab_Patron_Ritmico->Enabled=true;
  Tab_Progresion->Enabled=true;
  Tab_Melodia->Enabled=true;
}   */
}
//---------------------------------------------------------------------------
void TForm1::Dibuja_Musica()
{
int Numero_Filas=Alto/Alto_Fila;
//dibujamos colores para tipos de filas
for (int i=0;((i<Numero_Filas)&&(i<Numero_Filas_A_Dibujar));i++)
 {
  int tipo_pista=Musica_Genaro->Dame_Tipo_Pista(i);//i+fila_actual
  switch (tipo_pista)
  {
    case 0:this->Canvas->Brush->Color=clWhite;break;
    case 1:this->Canvas->Brush->Color=clGreen;break;
  }
  this->Canvas->FillRect(Rect(X_Inicial,Y_Inicial+i*Alto_Fila,X_Inicial+Ancho_Espacio_Estatico,Y_Inicial+(i+1)*Alto_Fila));
  //recorremos las distintas posiciones de bloques de la fila
  int Col_Actual=1;
  while ((X_Inicial+Ancho_Columnas*Col_Actual+Ancho_Espacio_Estatico)<(X_Final))
   {
    if (Col_Actual<=Numero_Bloques)
    {
     if (Musica_Genaro->Dame_Pista(i)->Dame_Bloque(Col_Actual-1).Vacio){this->Canvas->Brush->Color=clRed;}
     else{this->Canvas->Brush->Color=clBlue;}
     this->Canvas->FillRect(Rect((X_Inicial+Ancho_Columnas*(Col_Actual-1)+Ancho_Espacio_Estatico),Y_Inicial+i*Alto_Fila,(X_Inicial+Ancho_Columnas*Col_Actual+Ancho_Espacio_Estatico),Y_Inicial+((i+1)*Alto_Fila)));
    }
    Col_Actual++;
   }
 }
}
//---------------------------------------------------------------------------
void TForm1::Cuadro_Bloque_Pista()
{
Panel_Bloque->ActivePage=Tab_General;
Panel1->Visible=false;
Panel_Tipo_Pista->Visible=false;
//2- pon este a visiible
Panel_Bloque->Visible=true;

Bloque Bloque_A_Manipular=Musica_Genaro->Dame_Pista(Fila_Pulsada)->Dame_Bloque(Columna_Pulsada);
Etiqueta_Bloque_Numero_Compases->Caption="Nº Compases de su bloque: "+IntToStr(Bloque_A_Manipular.Num_Compases);
Barra_Numero_Acorde_A_Mutar->Max=Bloque_A_Manipular.Num_Compases;
Lista_8_Inicial->Text=IntToStr(Bloque_A_Manipular.Octava_Inicial);
if (Bloque_A_Manipular.Aplicacion_Horizontal==0)
{
  Radio_Horizontal_Ciclico->Checked=true;
}
else
{
  Radio_Horizontal_No_Ciclico->Checked=true;
}
if (Bloque_A_Manipular.Aplicacion_Vertical_Mayor==0)
{
  Radio_Vertical_Mayor_Truncar->Checked=true;
}
else
{
  Radio_Vertical_Mayor_Saturar->Checked=true;
}

if (Bloque_A_Manipular.Progresion!=NULL)
{
Progresion_A_Grid();
}

switch (Bloque_A_Manipular.Aplicacion_Vertical_Menor)
{
  case 0:{Radio_Vertical_Menor_Truncar->Checked=true;break;}
  case 1:{Radio_Vertical_Menor_Saturar->Checked=true;break;}
  case 2:{Radio_Vertical_Menor_Ciclico->Checked=true;break;}
  case 3:{Radio_Vertical_Menor_Modulo->Checked=true;break;}
}

switch (Musica_Genaro->Dame_Tipo_Pista(Fila_Pulsada))
{
  case 0:
    {
      Tab_General->Enabled=true;
      Tab_Patron_Ritmico->Enabled=true;
      Tab_Aplicacion_Patron->Enabled=true;
      Tab_Progresion->Enabled=true;
      Tab_Crear_Progresion->Enabled=true;
      Tab_Melodia->Enabled=false;
      break;
    }
  case 1:
    {
      Tab_General->Enabled=true;
      Tab_Patron_Ritmico->Enabled=false;
      Tab_Aplicacion_Patron->Enabled=false;      
      Tab_Progresion->Enabled=false;
      Tab_Crear_Progresion->Enabled=false;
      Tab_Melodia->Enabled=true;
      Inicializa_Pistas_Acompanamiento();
      //Pista de acompañamiento=X;
      Selector_Pista_Acompanamiento->Text="Pista Nº "+IntToStr(Bloque_A_Manipular.N_Pista_Acomp);
      break;
    }
}

if (Bloque_A_Manipular.Vacio)
 {
  Bloque_Vacio->Checked=true;
 }
else
 {
  Bloque_Vacio->Checked=false;
 }

Selector_Patron_Ritmico->Text=Bloque_A_Manipular.Patron_Ritmico;
Barra_Notas_Totales->Position=Bloque_A_Manipular.Notas_Totales;
if (Bloque_A_Manipular.Es_Sistema_Paralelo)
{
  Sistema_Paralelo->Checked=true;
}
else
{
  Sistema_Continuo->Checked=true;
}
Lista_Inversion->Text=Bloque_A_Manipular.Inversion;
Lista_Disposicion->Text=Bloque_A_Manipular.Disposicion;

/*if (Bloque_Vacio->Checked)
{
  Tab_Patron_Ritmico->Enabled=false;
  Tab_Progresion->Enabled=false;
  Tab_Melodia->Enabled=false;
}
else
{
  Tab_Patron_Ritmico->Enabled=true;
  Tab_Progresion->Enabled=true;
  Tab_Melodia->Enabled=true;
}      */

if (Sistema_Paralelo->Checked)
 {
  Etiqueta_Inversion->Enabled=true;
  Etiqueta_Disposicion->Enabled=true;
  Lista_Inversion->Enabled=true;
  Lista_Disposicion->Enabled=true;
  Edit_Semilla->Enabled=false;
  Check_Semilla->Enabled=false;
 }
else
 {
  Etiqueta_Inversion->Enabled=false;
  Etiqueta_Disposicion->Enabled=false;
  Lista_Inversion->Enabled=false;
  Lista_Disposicion->Enabled=false;
  Edit_Semilla->Enabled=true;
  Check_Semilla->Enabled=true;
 }
}
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
void __fastcall TForm1::Boton_Guardar_Cambios_BloqueClick(TObject *Sender)
{
Bloque Bloque_A_Manipular=Musica_Genaro->Dame_Pista(Fila_Pulsada)->Dame_Bloque(Columna_Pulsada);
Bloque_A_Manipular.Vacio=Bloque_Vacio->Checked;
Bloque_A_Manipular.Patron_Ritmico=Selector_Patron_Ritmico->Text;
Bloque_A_Manipular.Notas_Totales=Barra_Notas_Totales->Position;
Bloque_A_Manipular.Es_Sistema_Paralelo=Sistema_Paralelo->Checked;
Bloque_A_Manipular.Inversion=Lista_Inversion->Text;
Bloque_A_Manipular.Disposicion=Lista_Disposicion->Text;
Bloque_A_Manipular.Octava_Inicial=StrToInt(Lista_8_Inicial->Text);
if (Radio_Horizontal_Ciclico->Checked==true)
{
  Bloque_A_Manipular.Aplicacion_Horizontal=0;
}
else
{
  Bloque_A_Manipular.Aplicacion_Horizontal=1;
}

if (Radio_Vertical_Mayor_Truncar->Checked==true)
{
  Bloque_A_Manipular.Aplicacion_Vertical_Mayor=0;
}
else
{
  Bloque_A_Manipular.Aplicacion_Vertical_Mayor=1;
}

if (Radio_Vertical_Menor_Truncar->Checked==true)
{
  Bloque_A_Manipular.Aplicacion_Vertical_Menor=0;
}
if (Radio_Vertical_Menor_Saturar->Checked==true)
{
  Bloque_A_Manipular.Aplicacion_Vertical_Menor=1;
}
if (Radio_Vertical_Menor_Ciclico->Checked==true)
{
  Bloque_A_Manipular.Aplicacion_Vertical_Menor=2;
}
if (Radio_Vertical_Menor_Modulo->Checked==true)
{
  Bloque_A_Manipular.Aplicacion_Vertical_Menor=3;
}

if (Radio_Delegar_Haskell->Checked)
{
  Bloque_A_Manipular.Tipo_Melodia=0;
}
if (Radio_Curva_Melodia->Checked)
{
  Bloque_A_Manipular.Tipo_Melodia=1;
}
if (Radio_Editor_Midi->Checked)
{
  Bloque_A_Manipular.Tipo_Melodia=2;
}
//mirar a que pista corresponde el selector
int seleccion_pista=Selector_Pista_Acompanamiento->Items->IndexOf(Selector_Pista_Acompanamiento->Text);
if (seleccion_pista!=-1)
 {
  int N_P_A=0;
  for (int i=0;i<Musica_Genaro->Dame_Numero_Pistas();i++)
  {
    if (Musica_Genaro->Dame_Tipo_Pista(i)==0)
    {
      if (N_P_A==seleccion_pista)
      {Bloque_A_Manipular.N_Pista_Acomp=i;}
      N_P_A++;
    }
   }
 }
Musica_Genaro->Dame_Pista(Fila_Pulsada)->Cambia_Bloque(Bloque_A_Manipular,Columna_Pulsada);
Dibuja_Cancion();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Radio_EspecificasClick(TObject *Sender)
{
if (Radio_Especificas->Checked)
{
Radio_TipoA_Generales->Enabled=true;
Radio_TipoB_Generales->Enabled=true;
Radio_TipoA_Especificas->Enabled=true;
Radio_TipoB_Especificas->Enabled=true;
Etiqueta_TipoA_Generales->Enabled=true;
Etiqueta_TipoB_Generales->Enabled=true;
Etiqueta_Tipo1->Enabled=true;
Etiqueta_Tipo2->Enabled=true;
Etiqueta_Tipo3->Enabled=true;
Etiqueta_Tipo4->Enabled=true;
Etiqueta_Tipo5->Enabled=true;
Barra_TipoA_Generales->Enabled=true;
Barra_TipoB_Generales->Enabled=true;
Barra_Mutaciones_Junta_Acordes->Enabled=true;
Barra_Mutaciones_Separa_Acordes->Enabled=true;
Barra_Mutaciones_Cambia_Acordes->Enabled=true;
Barra_Mutaciones_Dominante_Sencundario->Enabled=true;
Barra_Mutaciones_2M7->Enabled=true;
Barra_Mutaciones_Totales->Enabled=false;
Etiqueta_Mutaciones_Totales->Enabled=false;
}
else
{
Radio_TipoA_Generales->Enabled=false;
Radio_TipoB_Generales->Enabled=false;
Radio_TipoA_Especificas->Enabled=false;
Radio_TipoB_Especificas->Enabled=false;
Etiqueta_TipoA_Generales->Enabled=false;
Etiqueta_TipoB_Generales->Enabled=false;
Etiqueta_Tipo1->Enabled=false;
Etiqueta_Tipo2->Enabled=false;
Etiqueta_Tipo3->Enabled=false;
Etiqueta_Tipo4->Enabled=false;
Etiqueta_Tipo5->Enabled=false;
Barra_TipoA_Generales->Enabled=false;
Barra_TipoB_Generales->Enabled=false;
Barra_Mutaciones_Junta_Acordes->Enabled=false;
Barra_Mutaciones_Separa_Acordes->Enabled=false;
Barra_Mutaciones_Cambia_Acordes->Enabled=false;
Barra_Mutaciones_Dominante_Sencundario->Enabled=false;
Barra_Mutaciones_2M7->Enabled=false;
Barra_Mutaciones_Totales->Enabled=true;
Etiqueta_Mutaciones_Totales->Enabled=true;
}
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Radio_Mutaciones_TotalesClick(TObject *Sender)
{
if (Radio_Especificas->Checked)
{
Radio_TipoA_Generales->Enabled=true;
Radio_TipoB_Generales->Enabled=true;
Radio_TipoA_Especificas->Enabled=true;
Radio_TipoB_Especificas->Enabled=true;
Etiqueta_TipoA_Generales->Enabled=true;
Etiqueta_TipoB_Generales->Enabled=true;
Etiqueta_Tipo1->Enabled=true;
Etiqueta_Tipo2->Enabled=true;
Etiqueta_Tipo3->Enabled=true;
Etiqueta_Tipo4->Enabled=true;
Etiqueta_Tipo5->Enabled=true;
Barra_TipoA_Generales->Enabled=true;
Barra_TipoB_Generales->Enabled=true;
Barra_Mutaciones_Junta_Acordes->Enabled=true;
Barra_Mutaciones_Separa_Acordes->Enabled=true;
Barra_Mutaciones_Cambia_Acordes->Enabled=true;
Barra_Mutaciones_Dominante_Sencundario->Enabled=true;
Barra_Mutaciones_2M7->Enabled=true;
Barra_Mutaciones_Totales->Enabled=false;
Etiqueta_Mutaciones_Totales->Enabled=false;
}
else
{
Radio_TipoA_Generales->Enabled=false;
Radio_TipoB_Generales->Enabled=false;
Radio_TipoA_Especificas->Enabled=false;
Radio_TipoB_Especificas->Enabled=false;
Etiqueta_TipoA_Generales->Enabled=false;
Etiqueta_TipoB_Generales->Enabled=false;
Etiqueta_Tipo1->Enabled=false;
Etiqueta_Tipo2->Enabled=false;
Etiqueta_Tipo3->Enabled=false;
Etiqueta_Tipo4->Enabled=false;
Etiqueta_Tipo5->Enabled=false;
Barra_TipoA_Generales->Enabled=false;
Barra_TipoB_Generales->Enabled=false;
Barra_Mutaciones_Junta_Acordes->Enabled=false;
Barra_Mutaciones_Separa_Acordes->Enabled=false;
Barra_Mutaciones_Cambia_Acordes->Enabled=false;
Barra_Mutaciones_Dominante_Sencundario->Enabled=false;
Barra_Mutaciones_2M7->Enabled=false;
Barra_Mutaciones_Totales->Enabled=true;
Etiqueta_Mutaciones_Totales->Enabled=true;
} 
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Barra_Mutaciones_TotalesChange(TObject *Sender)
{
Etiqueta_Mutaciones_Totales->Caption=IntToStr(Barra_Mutaciones_Totales->Position);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Barra_TipoA_GeneralesChange(TObject *Sender)
{
Etiqueta_TipoA_Generales->Caption=IntToStr(Barra_TipoA_Generales->Position);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Barra_TipoB_GeneralesChange(TObject *Sender)
{
Etiqueta_TipoB_Generales->Caption=IntToStr(Barra_TipoB_Generales->Position);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Barra_Mutaciones_Junta_AcordesChange(
      TObject *Sender)
{
Etiqueta_Tipo1->Caption=IntToStr(Barra_Mutaciones_Junta_Acordes->Position);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Barra_Mutaciones_Separa_AcordesChange(
      TObject *Sender)
{
Etiqueta_Tipo2->Caption=IntToStr(Barra_Mutaciones_Separa_Acordes->Position);  
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Barra_Mutaciones_Cambia_AcordesChange(
      TObject *Sender)
{
Etiqueta_Tipo3->Caption=IntToStr(Barra_Mutaciones_Cambia_Acordes->Position);  
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Barra_Mutaciones_Dominante_SencundarioChange(
      TObject *Sender)
{
Etiqueta_Tipo4->Caption=IntToStr(Barra_Mutaciones_Dominante_Sencundario->Position);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Barra_Mutaciones_2M7Change(TObject *Sender)
{
Etiqueta_Tipo5->Caption=IntToStr(Barra_Mutaciones_2M7->Position);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Barra_N_Compases_BloqueChange(TObject *Sender)
{
Etiqueta_Numero_Compases->Caption=IntToStr(Barra_N_Compases_Bloque->Position);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Barra_Tipo_PistaChange(TObject *Sender)
{
switch (Barra_Tipo_Pista->Position)
{
  case 0:Etiqueta_Tipo_Pista->Caption="Acompañamiento";break;
  case 1:Etiqueta_Tipo_Pista->Caption="Melodía";break;
}
}
//---------------------------------------------------------------------------

void TForm1::Crea_Progresion(String Ruta_Prolog, String argv[],int total_args)
{
char *args[18];
for (int i=0;i<18;i++)
{
total_args--;
if ((argv[i]==NULL)&&(total_args<0))
{args[i]=NULL;}
else
{
  args[i]=argv[i].c_str();
}

}
  int valor_spawn=spawnv(P_WAIT,args[0],args);
  if (valor_spawn==-1)
  {ShowMessage("Error ejecutando el MainArgs de prolog.");}
}
void __fastcall TForm1::Barra_Numero_Acorde_A_MutarChange(TObject *Sender)
{
Label_Mutar_Acorde_N->Caption=IntToStr(Barra_Numero_Acorde_A_Mutar->Position);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button12Click(TObject *Sender)
{
if (Radio_Crear_Progresion->Checked)
{
  Progresion_Crear_Progresion();
}
if (Radio_Mutar_Progresion->Checked)
{
  Progresion_Mutar_Progresion();
}
if (Radio_Mutar_Acorde_Progresion->Checked)
{
  Progresion_Mutar_Acorde_Progresion();
}
if (Radio_Mutar_Progresion_Multiple->Checked)
{
  Progresion_Mutar_Progresion_Multiple();
}
Bloque Bloque_A_Manipular=Musica_Genaro->Dame_Pista(Fila_Pulsada)->Dame_Bloque(Columna_Pulsada);
/*char work_dir[255];
getcwd(work_dir, 255);
String directorio_trabajo1=work_dir;  */
Bloque_A_Manipular.Progresion="progresion_"+IntToStr(Fila_Pulsada)+"_"+IntToStr(Columna_Pulsada)+".prog";
Musica_Genaro->Dame_Pista(Fila_Pulsada)->Cambia_Bloque(Bloque_A_Manipular,Columna_Pulsada);
Progresion_A_Grid();
}
//---------------------------------------------------------------------------
void TForm1::Progresion_Crear_Progresion()
{
char work_dir[255];
getcwd(work_dir, 255);
String directorio_trabajo1=work_dir;
String directorio_trabajo="\""+directorio_trabajo1+"\"";
String Orden="crea_progresion";
String Ruta_Destino="\""+directorio_trabajo1+"\\progresion_"+IntToStr(Fila_Pulsada)+"_"+IntToStr(Columna_Pulsada)+".prog"+"\"";
String NAcordes=IntToStr(Musica_Genaro->Dame_Pista(Fila_Pulsada)->Dame_Bloque(Columna_Pulsada).Num_Compases);
String MT="mt";
String V1;
String V2;
String V3;
String V4;
String V5;
String TB="tb";
String TA="ta";
String T1="t1";
String T2="t2";
String T3="t3";
String T4="t4";
String T5="t5";
int valor=0;
String argv[18];
String Ruta_Prolog=unidad_de_union->Dame_Interfaz_Prolog()->Dame_Ruta_Prolog();
for (int i=0;i<18;i++){argv[i]=NULL;}
argv[valor]=Ruta_Prolog;
valor++;
argv[valor]=directorio_trabajo;
valor++;
argv[valor]=Orden;
valor++;
argv[valor]=Ruta_Destino;
valor++;
argv[valor]=NAcordes;
valor++;
if(Radio_Mutaciones_Totales->Checked)
{
  argv[valor]=MT;
  valor++;
  V1=IntToStr(Barra_Mutaciones_Totales->Position);
  argv[valor]=V1;
  valor++;
}
else
{
  if (Radio_TipoA_Generales->Checked)
  {
    argv[valor]=TA;
    valor++;
    V1=IntToStr(Barra_TipoA_Generales->Position);
    argv[valor]=V1;
    valor++;
  }
  else
  {
    argv[valor]=T1;
    valor++;
    V1=IntToStr(Barra_Mutaciones_Junta_Acordes->Position);
    argv[valor]=V1;
    valor++;
    argv[valor]=T2;
    valor++;
    V2=IntToStr(Barra_Mutaciones_Separa_Acordes->Position);
    argv[valor]=V2;
    valor++;
    argv[valor]=T3;
    valor++;
    V3=IntToStr(Barra_Mutaciones_Cambia_Acordes->Position);
    argv[valor]=V3;
    valor++;
  }
  if (Radio_TipoB_Generales->Checked)
  {
    argv[valor]=TB;
    valor++;
    V4=IntToStr(Barra_TipoB_Generales->Position);
    argv[valor]=V4;
    valor++;
  }
  else
  {
    argv[valor]=T4;
    valor++;
    V4=IntToStr(Barra_Mutaciones_Dominante_Sencundario->Position);
    argv[valor]=V4;
    valor++;
    argv[valor]=T5;
    valor++;
    V5=IntToStr(Barra_Mutaciones_2M7->Position);
    argv[valor]=V5;
    valor++;
  }
}
Crea_Progresion(Ruta_Prolog,argv,valor);
}
//---------------------------------------------------------------------------
void TForm1::Progresion_Mutar_Progresion()
{
//de momento creamos progresión y punto
//Guardamos la progresión con un nombre temporal y al guardar cambios lo cambiamos y ponemos
char work_dir[255];
getcwd(work_dir, 255);
String directorio_trabajo1=work_dir;
String directorio_trabajo="\""+directorio_trabajo1+"\"";
String Orden="muta_progresion";
String Ruta_Destino="\""+directorio_trabajo1+"\\progresion_"+IntToStr(Fila_Pulsada)+"_"+IntToStr(Columna_Pulsada)+".prog"+"\"";

Bloque Bloque_A_Manipular=Musica_Genaro->Dame_Pista(Fila_Pulsada)->Dame_Bloque(Columna_Pulsada);
String Progresion_Bloque=Bloque_A_Manipular.Progresion;
String Ruta_Origen="\""+directorio_trabajo1+"\\"+Progresion_Bloque+"\"";

//habría que comprabar si es válido y si ha pulsado cancelar
//if (FicheroValido(Ruta_Origen)==false){ShowMessage("Fichero No Válido"); return;}
String NAcordes=IntToStr(Musica_Genaro->Dame_Pista(Fila_Pulsada)->Dame_Bloque(Columna_Pulsada).Num_Compases);
String MT="mt";
String V1;
String V2;
String V3;
String V4;
String V5;
String TB="tb";
String TA="ta";
String T1="t1";
String T2="t2";
String T3="t3";
String T4="t4";
String T5="t5";
int valor=0;
String argv[18];
String Ruta_Prolog=unidad_de_union->Dame_Interfaz_Prolog()->Dame_Ruta_Prolog();
for (int i=0;i<18;i++){argv[i]=NULL;}
argv[valor]=Ruta_Prolog;
valor++;
argv[valor]=directorio_trabajo;
valor++;
argv[valor]=Orden;
valor++;
argv[valor]=Ruta_Origen;
valor++;
argv[valor]=Ruta_Destino;
valor++;
//argv[valor]=NAcordes;
//valor++;
if(Radio_Mutaciones_Totales->Checked)
{
  argv[valor]=MT;
  valor++;
  V1=IntToStr(Barra_Mutaciones_Totales->Position);
  argv[valor]=V1;
  valor++;
}
else
{
  if (Radio_TipoA_Generales->Checked)
  {
    argv[valor]=TA;
    valor++;
    V1=IntToStr(Barra_TipoA_Generales->Position);
    argv[valor]=V1;
    valor++;
  }
  else
  {
    argv[valor]=T1;
    valor++;
    V1=IntToStr(Barra_Mutaciones_Junta_Acordes->Position);
    argv[valor]=V1;
    valor++;
    argv[valor]=T2;
    valor++;
    V2=IntToStr(Barra_Mutaciones_Separa_Acordes->Position);
    argv[valor]=V2;
    valor++;
    argv[valor]=T3;
    valor++;
    V3=IntToStr(Barra_Mutaciones_Cambia_Acordes->Position);
    argv[valor]=V3;
    valor++;
  }
  if (Radio_TipoB_Generales->Checked)
  {
    argv[valor]=TB;
    valor++;
    V4=IntToStr(Barra_TipoB_Generales->Position);
    argv[valor]=V4;
    valor++;
  }
  else
  {
    argv[valor]=T4;
    valor++;
    V4=IntToStr(Barra_Mutaciones_Dominante_Sencundario->Position);
    argv[valor]=V4;
    valor++;
    argv[valor]=T5;
    valor++;
    V5=IntToStr(Barra_Mutaciones_2M7->Position);
    argv[valor]=V5;
    valor++;
  }
}
Crea_Progresion(Ruta_Prolog,argv,valor);
}
//---------------------------------------------------------------------------
void TForm1::Progresion_Mutar_Acorde_Progresion()
{
//de momento creamos progresión y punto
//Guardamos la progresión con un nombre temporal y al guardar cambios lo cambiamos y ponemos
char work_dir[255];
getcwd(work_dir, 255);
String directorio_trabajo1=work_dir;
String directorio_trabajo="\""+directorio_trabajo1+"\"";
String Orden="muta_progresion_acorde";
String Ruta_Destino="\""+directorio_trabajo1+"\\progresion_"+IntToStr(Fila_Pulsada)+"_"+IntToStr(Columna_Pulsada)+".prog"+"\"";
Bloque Bloque_A_Manipular=Musica_Genaro->Dame_Pista(Fila_Pulsada)->Dame_Bloque(Columna_Pulsada);
String Progresion_Bloque=Bloque_A_Manipular.Progresion;
String Ruta_Origen="\""+directorio_trabajo1+"\\"+Progresion_Bloque+"\"";
//habría que comprabar si es válido y si ha pulsado cancelar
//if (FicheroValido(Ruta_Origen)==false){ShowMessage("Fichero No Válido"); return;}
String NAcordes=IntToStr(Musica_Genaro->Dame_Pista(Fila_Pulsada)->Dame_Bloque(Columna_Pulsada).Num_Compases);
//numero de acorde a mutar
String NAcorde_A_Mutar=IntToStr(Grid_Progresion->Col+1);
String MT="mt";
String V1;
String V2;
String V3;
String V4;
String V5;
String TB="tb";
String TA="ta";
String T1="t1";
String T2="t2";
String T3="t3";
String T4="t4";
String T5="t5";
int valor=0;
String argv[18];
String Ruta_Prolog=unidad_de_union->Dame_Interfaz_Prolog()->Dame_Ruta_Prolog();
for (int i=0;i<18;i++){argv[i]=NULL;}
argv[valor]=Ruta_Prolog;
valor++;
argv[valor]=directorio_trabajo;
valor++;
argv[valor]=Orden;
valor++;
argv[valor]=Ruta_Origen;
valor++;
argv[valor]=Ruta_Destino;
valor++;
argv[valor]=NAcorde_A_Mutar;
valor++;
//argv[valor]=NAcordes;
//valor++;
if(Radio_Mutaciones_Totales->Checked)
{
  argv[valor]=MT;
  valor++;
  V1=IntToStr(Barra_Mutaciones_Totales->Position);
  argv[valor]=V1;
  valor++;
}
else
{
  if (Radio_TipoA_Generales->Checked)
  {
    argv[valor]=TA;
    valor++;
    V1=IntToStr(Barra_TipoA_Generales->Position);
    argv[valor]=V1;
    valor++;
  }
  else
  {
    argv[valor]=T1;
    valor++;
    V1=IntToStr(Barra_Mutaciones_Junta_Acordes->Position);
    argv[valor]=V1;
    valor++;
    argv[valor]=T2;
    valor++;
    V2=IntToStr(Barra_Mutaciones_Separa_Acordes->Position);
    argv[valor]=V2;
    valor++;
    argv[valor]=T3;
    valor++;
    V3=IntToStr(Barra_Mutaciones_Cambia_Acordes->Position);
    argv[valor]=V3;
    valor++;
  }
  if (Radio_TipoB_Generales->Checked)
  {
    argv[valor]=TB;
    valor++;
    V4=IntToStr(Barra_TipoB_Generales->Position);
    argv[valor]=V4;
    valor++;
  }
  else
  {
    argv[valor]=T4;
    valor++;
    V4=IntToStr(Barra_Mutaciones_Dominante_Sencundario->Position);
    argv[valor]=V4;
    valor++;
    argv[valor]=T5;
    valor++;
    V5=IntToStr(Barra_Mutaciones_2M7->Position);
    argv[valor]=V5;
    valor++;
  }
}
Crea_Progresion(Ruta_Prolog,argv,valor);
}
//---------------------------------------------------------------------------
void TForm1::Progresion_Mutar_Progresion_Multiple()
{
//de momento creamos progresión y punto
//Guardamos la progresión con un nombre temporal y al guardar cambios lo cambiamos y ponemos
char work_dir[255];
getcwd(work_dir, 255);
String directorio_trabajo1=work_dir;
String directorio_trabajo="\""+directorio_trabajo1+"\"";
String Orden="crea_con_semilla";
String Ruta_Destino="\""+directorio_trabajo1+"\\progresion_"+IntToStr(Fila_Pulsada)+"_"+IntToStr(Columna_Pulsada)+".prog"+"\"";
Bloque Bloque_A_Manipular=Musica_Genaro->Dame_Pista(Fila_Pulsada)->Dame_Bloque(Columna_Pulsada);
String Progresion_Bloque=Bloque_A_Manipular.Progresion;
String Ruta_Origen="\""+directorio_trabajo1+"\\"+Progresion_Bloque+"\"";
//habría que comprabar si es válido y si ha pulsado cancelar
//if (FicheroValido(Ruta_Origen)==false){ShowMessage("Fichero No Válido"); return;}
String NAcordes=IntToStr(Musica_Genaro->Dame_Pista(Fila_Pulsada)->Dame_Bloque(Columna_Pulsada).Num_Compases);
String MT="mt";
String V1;
String V2;
String V3;
String V4;
String V5;
String TB="tb";
String TA="ta";
String T1="t1";
String T2="t2";
String T3="t3";
String T4="t4";
String T5="t5";
int valor=0;
String argv[18];
String Ruta_Prolog=unidad_de_union->Dame_Interfaz_Prolog()->Dame_Ruta_Prolog();
for (int i=0;i<18;i++){argv[i]=NULL;}
argv[valor]=Ruta_Prolog;
valor++;
argv[valor]=directorio_trabajo;
valor++;
argv[valor]=Orden;
valor++;
argv[valor]=Ruta_Origen;
valor++;
argv[valor]=Ruta_Destino;
valor++;
argv[valor]=NAcordes;
valor++;
if(Radio_Mutaciones_Totales->Checked)
{
  argv[valor]=MT;
  valor++;
  V1=IntToStr(Barra_Mutaciones_Totales->Position);
  argv[valor]=V1;
  valor++;
}
else
{
  if (Radio_TipoA_Generales->Checked)
  {
    argv[valor]=TA;
    valor++;
    V1=IntToStr(Barra_TipoA_Generales->Position);
    argv[valor]=V1;
    valor++;
  }
  else
  {
    argv[valor]=T1;
    valor++;
    V1=IntToStr(Barra_Mutaciones_Junta_Acordes->Position);
    argv[valor]=V1;
    valor++;
    argv[valor]=T2;
    valor++;
    V2=IntToStr(Barra_Mutaciones_Separa_Acordes->Position);
    argv[valor]=V2;
    valor++;
    argv[valor]=T3;
    valor++;
    V3=IntToStr(Barra_Mutaciones_Cambia_Acordes->Position);
    argv[valor]=V3;
    valor++;
  }
  if (Radio_TipoB_Generales->Checked)
  {
    argv[valor]=TB;
    valor++;
    V4=IntToStr(Barra_TipoB_Generales->Position);
    argv[valor]=V4;
    valor++;
  }
  else
  {
    argv[valor]=T4;
    valor++;
    V4=IntToStr(Barra_Mutaciones_Dominante_Sencundario->Position);
    argv[valor]=V4;
    valor++;
    argv[valor]=T5;
    valor++;
    V5=IntToStr(Barra_Mutaciones_2M7->Position);
    argv[valor]=V5;
    valor++;
  }
}
Crea_Progresion(Ruta_Prolog,argv,valor);
}
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

void __fastcall TForm1::Radio_Crear_ProgresionClick(TObject *Sender)
{
if (Radio_Mutar_Acorde_Progresion->Checked)
{
  Label_Texto_Muta_Acorde->Enabled=true;
  Label_Mutar_Acorde_N->Enabled=true;
  Barra_Numero_Acorde_A_Mutar->Enabled=true;
}
else
{
  Label_Texto_Muta_Acorde->Enabled=false;
  Label_Mutar_Acorde_N->Enabled=false;
  Barra_Numero_Acorde_A_Mutar->Enabled=false;
}
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Radio_Mutar_ProgresionClick(TObject *Sender)
{
if (Radio_Mutar_Acorde_Progresion->Checked)
{
  Label_Texto_Muta_Acorde->Enabled=true;
  Label_Mutar_Acorde_N->Enabled=true;
  Barra_Numero_Acorde_A_Mutar->Enabled=true;
}
else
{
  Label_Texto_Muta_Acorde->Enabled=false;
  Label_Mutar_Acorde_N->Enabled=false;
  Barra_Numero_Acorde_A_Mutar->Enabled=false;
}  
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Radio_Mutar_Acorde_ProgresionClick(TObject *Sender)
{
if (Radio_Mutar_Acorde_Progresion->Checked)
{
  Label_Texto_Muta_Acorde->Enabled=true;
  Label_Mutar_Acorde_N->Enabled=true;
  Barra_Numero_Acorde_A_Mutar->Enabled=true;
}
else
{
  Label_Texto_Muta_Acorde->Enabled=false;
  Label_Mutar_Acorde_N->Enabled=false;
  Barra_Numero_Acorde_A_Mutar->Enabled=false;
}  
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Radio_Mutar_Progresion_MultipleClick(
      TObject *Sender)
{
if (Radio_Mutar_Acorde_Progresion->Checked)
{
  Label_Texto_Muta_Acorde->Enabled=true;
  Label_Mutar_Acorde_N->Enabled=true;
  Barra_Numero_Acorde_A_Mutar->Enabled=true;
}
else
{
  Label_Texto_Muta_Acorde->Enabled=false;
  Label_Mutar_Acorde_N->Enabled=false;
  Barra_Numero_Acorde_A_Mutar->Enabled=false;
}  
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button9Click(TObject *Sender)
{
if (Radio_Curva_Melodia->Checked)
{
  //bloque Bloque_A_Manipular=Musica_Genaro->Dame_Pista(Fila_Pulsada)->Dame_Bloque(Columna_Pulsada);
  Form_Melodia->Lee_Puntos(Musica_Genaro,Fila_Pulsada,Columna_Pulsada);
  Form_Melodia->Show();
}
if (Radio_Delegar_Haskell->Checked)
{
  //creamos la curva melódica delegando en haskell.
  Crea_Curva_Delegando();
}
}
//---------------------------------------------------------------------------
void TForm1::Inicializa_Pistas_Acompanamiento()
{
Selector_Pista_Acompanamiento->Items->Clear();
for (int i=0;i<Musica_Genaro->Dame_Numero_Pistas();i++)
 {
  if (Musica_Genaro->Dame_Tipo_Pista(i)==0)
  {
    Selector_Pista_Acompanamiento->Items->Add("Pista Nº "+IntToStr(i));
  }
 }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Guardar1Click(TObject *Sender)
{
if (Inicializado)
{
Musica_Genaro->Guarda_Archivo();
}
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormPaint(TObject *Sender)
{
if (Inicializado)
{
  Dibuja_Cancion();
}
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button10Click(TObject *Sender)
{
Boton_Guardar_Cambios_BloqueClick(Sender);
//si es pista de acompañamiento
//llamamos a haskel con el patron ritmico, la progresion y no se que otros parámetros. la progresión ha de estar ya hecha
if (Musica_Genaro->Dame_Tipo_Pista(Fila_Pulsada)==0)//generamos el music para pista de acompañamiento
{
  Genera_Music_Acompanamiento();
}
if (Musica_Genaro->Dame_Tipo_Pista(Fila_Pulsada)==1)
{
  Genera_Music_Melodia();
}

//si es pista de melodía hacemos la llamada con los parámetros de la pista de acompañamiento asociada. si no hay pista de acompañamiento asociada, esto peta.
}
//---------------------------------------------------------------------------
void TForm1::Genera_Music_Acompanamiento()
{
  char work_dir[255];
  getcwd(work_dir, 255);
  String directorio_trabajo=work_dir;
  directorio_trabajo="\""+directorio_trabajo+"\"";
  String Ruta_Haskell=unidad_de_union->Dame_Interfaz_Haskell()->Dame_Ruta_Haskell();
  String Ruta_Codigo_Haskell=unidad_de_union->Dame_Interfaz_Haskell()->Dame_Ruta_Codigo_Haskell();
  String Orden="generaSubbloqueAcompanamiento";
  //si no hay progresion asignada, se le crea una
  Bloque Bloque_A_Manipular=Musica_Genaro->Dame_Pista(Fila_Pulsada)->Dame_Bloque(Columna_Pulsada);
  if (Bloque_A_Manipular.Progresion==NULL)
  {
    ShowMessage("No hay ninguna progresión asociada a esta pista, se crea una por defecto");
    Progresion_Crear_Progresion();
    String directorio_trabajo1=work_dir;
    Bloque_A_Manipular.Progresion="\""+directorio_trabajo1+"/progresion_"+IntToStr(Fila_Pulsada)+"_"+IntToStr(Columna_Pulsada)+".prog"+"\"";
    Musica_Genaro->Dame_Pista(Fila_Pulsada)->Cambia_Bloque(Bloque_A_Manipular,Columna_Pulsada);
  }
  String Ruta_Progresion=Bloque_A_Manipular.Progresion;
  String P_Ritmico="./PatronesRitmicos/"+Bloque_A_Manipular.Patron_Ritmico;
  String Pal_Octava="octava";
  String O_Inicial=Lista_8_Inicial->Text;
  String Pal_Notas="numero_notas";
  String N_Notas=IntToStr(Barra_Notas_Totales->Position);
  String Pal_Sistema="sistema";
  String Sistem;
  String Pal_Horizontal="horizontal";
  String horizontal;
  if (Radio_Horizontal_Ciclico->Checked)
  {horizontal="Ciclico";}
  else
  {horizontal="NoCiclico";}
  String Pal_Vertical_Mayor="vertical_mayor";
  String Vertical_Mayor;
  if (Radio_Vertical_Mayor_Truncar->Checked)
  {Vertical_Mayor="Truncar1";}
  else
  {Vertical_Mayor="Saturar1";}
  String Pal_Vertical_Menor="vertical_menor";
  String Vertical_Menor;
  if (Radio_Vertical_Menor_Truncar->Checked){Vertical_Menor="Truncar2";}
  if (Radio_Vertical_Menor_Saturar->Checked){Vertical_Menor="Saturar2";}
  if (Radio_Vertical_Menor_Ciclico->Checked){Vertical_Menor="Ciclico2";}
  if (Radio_Vertical_Menor_Modulo->Checked){Vertical_Menor="Modulo2";}
  String Ruta_Destino_Music="Music_"+IntToStr(Fila_Pulsada)+"_"+IntToStr(Columna_Pulsada)+".msc";
  //caso sistema paralelo
  if (Sistema_Paralelo->Checked)
  {
    Sistem="paralelo";
    String Pal_Inversion="inversion";
    String Inversion=Lista_Inversion->Text;
    String Pal_Disposicion="disposicion";
    String Disposicion="\""+Lista_Disposicion->Text+"\"";
    int valor_spawn=spawnl(P_WAIT,Ruta_Haskell.c_str(),Ruta_Haskell.c_str(),Ruta_Codigo_Haskell.c_str(),directorio_trabajo.c_str(),Orden.c_str(),Ruta_Progresion.c_str(),P_Ritmico.c_str(),
    Pal_Octava.c_str(),O_Inicial.c_str(),Pal_Notas.c_str(),N_Notas.c_str(),Pal_Sistema.c_str(),Sistem.c_str(),
    Pal_Inversion.c_str(),Inversion.c_str(),Pal_Disposicion.c_str(),Disposicion.c_str(),
    Pal_Horizontal.c_str(),horizontal.c_str(),Pal_Vertical_Mayor.c_str(),Vertical_Mayor.c_str(),Pal_Vertical_Menor.c_str(),Vertical_Menor.c_str(),Ruta_Destino_Music.c_str(),NULL);
    if (valor_spawn==-1)
    {ShowMessage("Error ejecutando el runhugs de haskell.");}
  }
  //caso sistema continuo
  else
  {
    Sistem="continuo";
    String Pal_Semilla;
    if (Check_Semilla->Checked)
    {
      Pal_Semilla="nosemilla";
      int valor_spawn=spawnl(P_WAIT,Ruta_Haskell.c_str(),Ruta_Haskell.c_str(),Ruta_Codigo_Haskell.c_str(),directorio_trabajo.c_str(),Orden.c_str(),Ruta_Progresion.c_str(),P_Ritmico.c_str(),
      Pal_Octava.c_str(),O_Inicial.c_str(),Pal_Notas.c_str(),N_Notas.c_str(),Pal_Sistema.c_str(),Sistem.c_str(),Pal_Semilla.c_str(),
      Pal_Horizontal.c_str(),horizontal.c_str(),Pal_Vertical_Mayor.c_str(),Vertical_Mayor.c_str(),Pal_Vertical_Menor.c_str(),Vertical_Menor.c_str(),Ruta_Destino_Music.c_str(),NULL);
      if (valor_spawn==-1)
      {ShowMessage("Error ejecutando el runhugs de haskell.");}
    }
    else
    {
      Pal_Semilla="semilla";
      String Semilla=Edit_Semilla->Text;
      int valor_spawn=spawnl(P_WAIT,Ruta_Haskell.c_str(),Ruta_Haskell.c_str(),Ruta_Codigo_Haskell.c_str(),directorio_trabajo.c_str(),Orden.c_str(),Ruta_Progresion.c_str(),P_Ritmico.c_str(),
      Pal_Octava.c_str(),O_Inicial.c_str(),Pal_Notas.c_str(),N_Notas.c_str(),Pal_Sistema.c_str(),Sistem.c_str(),Pal_Semilla.c_str(),Semilla.c_str(),
      Pal_Horizontal.c_str(),horizontal.c_str(),Pal_Vertical_Mayor.c_str(),Vertical_Mayor.c_str(),Pal_Vertical_Menor.c_str(),Vertical_Menor.c_str(),Ruta_Destino_Music.c_str(),NULL);
      if (valor_spawn==-1)
      {ShowMessage("Error ejecutando el runhugs de haskell.");}
    }

  }
  Bloque_A_Manipular.Tipo_Music=Ruta_Destino_Music;
  Musica_Genaro->Dame_Pista(Fila_Pulsada)->Cambia_Bloque(Bloque_A_Manipular,Columna_Pulsada);
}
//----------------------------------------------------------------------------
void __fastcall TForm1::Edit_SemillaChange(TObject *Sender)
{
try
{
  StrToInt(Edit_Semilla->Text);
}
catch (...)
{
  ShowMessage("Has escrito un número no válido");
  Edit_Semilla->Text="0";
}
}
//---------------------------------------------------------------------------


void __fastcall TForm1::Boton_Cargar_ProgresionClick(TObject *Sender)
{
Bloque Bloque_A_Manipular=Musica_Genaro->Dame_Pista(Fila_Pulsada)->Dame_Bloque(Columna_Pulsada);

//nos quedamos con el nombre del fichero
if (Dialogo_Origen_Progresion->Execute()==false)
{ShowMessage("Operación Cancelada, esto parece la seguridad social");}
String Progre=Dialogo_Origen_Progresion->FileName;
String fichero="";
for (int i=0;i<Progre.Length();i++)
 {
  if (Progre[i+1]=='\\'){fichero="";}
  else{fichero+=Progre[i+1];}
 }
if (Es_Progresion_Valida(fichero)==-1){ShowMessage("Progresión no válida");}
// prueba turbia
TStringList *cadenitas;
cadenitas=Come_Progresion(fichero);
//ShowMessage(IntToStr(cadenitas->Count));
Grid_Progresion->RowCount=1;//no vamos a aumentar este número
Grid_Progresion->ColCount=cadenitas->Count;
for (int i=0;i<cadenitas->Count;i++)
{
  Grid_Progresion->Cols[i]->Clear();
  Grid_Progresion->Cols[i]->Add(cadenitas->Strings[i]);
}

//prueba turbia
Bloque_A_Manipular.Progresion=fichero;
Musica_Genaro->Dame_Pista(Fila_Pulsada)->Cambia_Bloque(Bloque_A_Manipular,Columna_Pulsada);
}
//---------------------------------------------------------------------------
void TForm1::Progresion_A_Grid()
{
Bloque Bloque_A_Manipular=Musica_Genaro->Dame_Pista(Fila_Pulsada)->Dame_Bloque(Columna_Pulsada);
String fichero=Bloque_A_Manipular.Progresion;
if (Es_Progresion_Valida(fichero)==-1){ShowMessage("Progresión no válida");}
TStringList *cadenitas;
cadenitas=Come_Progresion(fichero);
//ShowMessage(IntToStr(cadenitas->Count));
Grid_Progresion->RowCount=1;//no vamos a aumentar este número
Grid_Progresion->ColCount=cadenitas->Count;
for (int i=0;i<cadenitas->Count;i++)
{
  Grid_Progresion->Cols[i]->Clear();
  Grid_Progresion->Cols[i]->Add(cadenitas->Strings[i]);
}
}
//---------------------------------------------------------------------------


void __fastcall TForm1::Button7Click(TObject *Sender)
{
Grid_Progresion->RowCount=1;//no vamos a aumentar este número
Grid_Progresion->ColCount=1;
Grid_Progresion->Cols[Grid_Progresion->ColCount-1]->Add("sde");
Grid_Progresion->ColCount++;
Grid_Progresion->Cols[Grid_Progresion->ColCount-1]->Add("2");
Grid_Progresion->ColCount++;
Grid_Progresion->Cols[Grid_Progresion->ColCount-1]->Add("3");
Grid_Progresion->ColCount++;
Grid_Progresion->Cols[Grid_Progresion->ColCount-1]->Add("4");
Grid_Progresion->ColCount++;
Grid_Progresion->Cols[Grid_Progresion->ColCount-1]->Add("4");
Grid_Progresion->ColCount++;
Grid_Progresion->Cols[Grid_Progresion->ColCount-1]->Add("34");
Grid_Progresion->ColCount++;
Grid_Progresion->Cols[Grid_Progresion->ColCount-1]->Add("f");
Grid_Progresion->ColCount++;
Grid_Progresion->Cols[Grid_Progresion->ColCount-1]->Add("df4");
ShowMessage(IntToStr(Grid_Progresion->ColCount));
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button11Click(TObject *Sender)
{
ShowMessage(IntToStr(Grid_Progresion->Col));
ShowMessage(Grid_Progresion->Cols[Grid_Progresion->Col]->Strings[0]);
}
//---------------------------------------------------------------------------
//------------------------------------------------------------------------------
void TForm1::Crea_Curva_Delegando()
{
  Bloque Bloque_A_Manipular=Musica_Genaro->Dame_Pista(Fila_Pulsada)->Dame_Bloque(Columna_Pulsada);
  char work_dir[255];
  getcwd(work_dir, 255);
  String directorio_trabajo=work_dir;
  directorio_trabajo="\""+directorio_trabajo+"\"";
  String Ruta_Haskell=unidad_de_union->Dame_Interfaz_Haskell()->Dame_Ruta_Haskell();
  String Ruta_Codigo_Haskell=unidad_de_union->Dame_Interfaz_Haskell()->Dame_Ruta_Codigo_Haskell();
  String Orden="generaCurvaMelAlea";
  String fichero1="CurvaMelodica_"+IntToStr(Fila_Pulsada)+"_"+IntToStr(Columna_Pulsada)+".cm";
  String Pal_Parametros="parametros_curva";
  String Parametro1=3; //salto maximo
  String Parametro2=6; //probabilidad de salto
  String Parametro3=10; //numero de puntos
  String Pal_Ruta="ruta_dest_curva";
  int valor_spawn=spawnl(P_WAIT,Ruta_Haskell.c_str(),Ruta_Haskell.c_str(),Ruta_Codigo_Haskell.c_str(),directorio_trabajo.c_str(),Orden.c_str(),Pal_Parametros.c_str(),Parametro1.c_str(),Parametro2.c_str(),Parametro3.c_str(),Pal_Ruta.c_str(),fichero1.c_str(),NULL);
  if (valor_spawn==-1)
  {ShowMessage("Error ejecutando el runhugs de haskell.");}

  Bloque_A_Manipular.Curva_Melodica=fichero1;
  Musica_Genaro->Dame_Pista(Fila_Pulsada)->Cambia_Bloque(Bloque_A_Manipular,Columna_Pulsada);
}
//------------------------------------------------------------------------------
void TForm1::Genera_Music_Melodia()
{
  char work_dir[255];
  getcwd(work_dir, 255);
  String directorio_trabajo=work_dir;
  directorio_trabajo="\""+directorio_trabajo+"\"";
  String Ruta_Haskell=unidad_de_union->Dame_Interfaz_Haskell()->Dame_Ruta_Haskell();
  String Ruta_Codigo_Haskell=unidad_de_union->Dame_Interfaz_Haskell()->Dame_Ruta_Codigo_Haskell();
  String Orden="generaMusicConCurva";
  Bloque Bloque_A_Manipular=Musica_Genaro->Dame_Pista(Fila_Pulsada)->Dame_Bloque(Columna_Pulsada);
  //si no hay curva asignada, se avisa y se sale
  if (Bloque_A_Manipular.Curva_Melodica==NULL){ShowMessage("No tiene curva melódica asignada");return;}
  String Pal_Rutacurva="ruta_curva";
  String Ruta_Curva=Bloque_A_Manipular.Curva_Melodica;
  String Pal_Rutaprogresion="ruta_progresion";
  //Hay que coger la progresion de la pista de acompañamiento asignada
  if(Bloque_A_Manipular.N_Pista_Acomp==-1){ShowMessage("No has asignado pista de acompañamiento para este subbloque");return;}
  Bloque Bloque_Acompanamiento=Musica_Genaro->Dame_Pista(Bloque_A_Manipular.N_Pista_Acomp)->Dame_Bloque(Columna_Pulsada);
  if (Bloque_Acompanamiento.Progresion==NULL){ShowMessage("El bloque de acompañamiento no tiene progresión asignada");return;}
  String Ruta_Progresion=Bloque_Acompanamiento.Progresion;
  String Pal_patron="ruta_patron";
  String Ruta_Patron="./PatronesRitmicos/"+Bloque_Acompanamiento.Patron_Ritmico;
  String Pal_Parametros="parametros_curva";
  String Parametro1=2;//numero de divisiones
  String Parametro2=2;//numero de aplicaciones de fase 2
  String Parametro3=2;//numero de aplicaciones de fase 3
  String Parametro4=2;//numero de aplicaciones de fase 4
  String Pal_Ruta_Destino="ruta_dest_music";
  String Ruta_Destino_Music="Music_"+IntToStr(Fila_Pulsada)+"_"+IntToStr(Columna_Pulsada)+".msc";

  int valor_spawn=spawnl(P_WAIT,Ruta_Haskell.c_str(),Ruta_Haskell.c_str(),Ruta_Codigo_Haskell.c_str(),directorio_trabajo.c_str(),Orden.c_str(),Pal_Rutacurva.c_str(),Ruta_Curva.c_str(),Pal_Rutaprogresion.c_str(),Ruta_Progresion.c_str(),Pal_patron.c_str(),Ruta_Patron.c_str(),Pal_Parametros.c_str(),Parametro1.c_str(),Parametro2.c_str(),Parametro3.c_str(),Parametro4.c_str(),Pal_Ruta_Destino.c_str(),Ruta_Destino_Music.c_str(),NULL);
  if (valor_spawn==-1){ShowMessage("Error creando el music de melodia");}

  Bloque_A_Manipular.Tipo_Music=Ruta_Destino_Music;
  Musica_Genaro->Dame_Pista(Fila_Pulsada)->Cambia_Bloque(Bloque_A_Manipular,Columna_Pulsada);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button13Click(TObject *Sender)
{
if (Inicializado)
{
 if (Comprobar_Si_Generados_Music()!=-1)
 {
  Musica_Genaro->Guarda_Archivo_Haskell();
 }
}
}
//---------------------------------------------------------------------------
int TForm1::Comprobar_Si_Generados_Music()
{
bool Correcto=true;
for (int i=0;i<Musica_Genaro->Dame_Numero_Pistas();i++)
{
  for (int j=0; j<Musica_Genaro->Dame_Pista(i)->Dame_Numero_Bloques();j++)
  {
    if(Musica_Genaro->Dame_Pista(i)->Dame_Bloque(j).Tipo_Music==NULL)
    {
      ShowMessage("No están generados todos los tipos music");
      return -1;
    }
  }
}
return 0;
}
void __fastcall TForm1::Barra_TempoChange(TObject *Sender)
{
Etiqueta_Tempo->Caption=IntToStr(Barra_Tempo->Position);
}
//---------------------------------------------------------------------------


