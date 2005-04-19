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
      //1- comprueba que es v�lido para a�adir a la lista
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
      //2- a�ade a la lista de patrones r�tmicos.
      Selector_Patron_Ritmico->Items->Add(ent->d_name);
      Selector_Patron_Ritmico->Text=ent->d_name;
      }
    }

  }
}





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
//3- invocar la reproducci�n y quedarnos con el n�mero de proceso
Ejecuta_Timidity_Reproduccion(timi_exe, Amplificacion_Volumen, EFchorus,EFreverb,EFdelay,frecuency, Ruta_Patch_File,Ruta_Midi);

}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button1Click(TObject *Sender)
{
  String Ruta_codigo_haskell;
  String Ruta_haskell;
  String Ruta_prolog;

// FIXME FIXME esto est� si no se usa fichero de configuraci�n
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
//3- invocar la reproducci�n y quedarnos con el n�mero de proceso
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
void __fastcall TForm1::Button7Click(TObject *Sender)
{
if (Inicializado)
{
  Dibuja_Cancion();
}
//Panel_Bloque->Visible=!Panel_Bloque->Visible;
//Panel1->Visible=!Panel1->Visible;
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
//Dibujamos columnas est�ticas
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
TMouse* Raton;//cogemos el rat�n para preguntar por su posici�n
int X,Y;
TPoint Posicion=Raton->CursorPos;
X=Posicion.x-(this->Left)-((this->Width-this->ClientWidth)/2);//pasamos las coordenadas del rat�n (globales) a nuestra ventana
Y=Posicion.y-(this->Top)-((this->Height-this->ClientHeight)-((this->Width-this->ClientWidth)/2));
if ((X<X_Final)&&(X>X_Inicial)&&(Y<Y_Final)&&(Y>Y_Inicial))
{
  Accion_Click(X,Y);
}
//habr� que calcular donde pincha
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
 }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::NuevoClick(TObject *Sender)
{
if (Inicializado)
{}
else
{
  Inicializado=true;
  Musica_Genaro=new Cancion;
  Numero_Filas_A_Dibujar=0;
  Numero_Bloques=0;
}
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Boton_Nueva_PistaClick(TObject *Sender)
{
if (Inicializado)
{
  Musica_Genaro->Nueva_Pista(Barra_Tipo_Pista->Position);
  Numero_Filas_A_Dibujar++;
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
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Boton_Nuevo_BloqueClick(TObject *Sender)
{
if ((Inicializado)&&(Numero_Filas_A_Dibujar>0))
{
  Musica_Genaro->Nuevo_Bloque(Barra_N_Compases_Bloque->Position,Selector_Patron_Ritmico->Text,Lista_Disposicion->Text,Lista_Inversion->Text);
  Numero_Bloques++;
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
 }
else
 {
  Etiqueta_Inversion->Enabled=false;
  Etiqueta_Disposicion->Enabled=false;
  Lista_Inversion->Enabled=false;
  Lista_Disposicion->Enabled=false;
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
 }
else
 {
  Etiqueta_Inversion->Enabled=false;
  Etiqueta_Disposicion->Enabled=false;
  Lista_Inversion->Enabled=false;
  Lista_Disposicion->Enabled=false;
 }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Bloque_VacioClick(TObject *Sender)
{
if (Bloque_Vacio->Checked)
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
}
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
Etiqueta_Bloque_Numero_Compases->Caption="N� Compases = "+IntToStr(Bloque_A_Manipular.Num_Compases);
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
if (Bloque_A_Manipular.Es_Sisetma_Paralelo)
{
  Sistema_Paralelo->Checked=true;
}
else
{
  Sistema_Continuo->Checked=true;
}
Lista_Inversion->Text=Bloque_A_Manipular.Inversion;
Lista_Disposicion->Text=Bloque_A_Manipular.Disposicion;

if (Bloque_Vacio->Checked)
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
}

if (Sistema_Paralelo->Checked)
 {
  Etiqueta_Inversion->Enabled=true;
  Etiqueta_Disposicion->Enabled=true;
  Lista_Inversion->Enabled=true;
  Lista_Disposicion->Enabled=true;
 }
else
 {
  Etiqueta_Inversion->Enabled=false;
  Etiqueta_Disposicion->Enabled=false;
  Lista_Inversion->Enabled=false;
  Lista_Disposicion->Enabled=false;
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
Bloque_A_Manipular.Es_Sisetma_Paralelo=Sistema_Paralelo->Checked;
Bloque_A_Manipular.Inversion=Lista_Inversion->Text;
Bloque_A_Manipular.Disposicion=Lista_Disposicion->Text;
Musica_Genaro->Dame_Pista(Fila_Pulsada)->Cambia_Bloque(Bloque_A_Manipular,Columna_Pulsada);
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
  case 0:Etiqueta_Tipo_Pista->Caption="Acompa�amiento";break;
  case 1:Etiqueta_Tipo_Pista->Caption="Melod�a";break;
}
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button10Click(TObject *Sender)
{
int X=3;
//poner un nuevo formulario en visible y modal
//elegir entre crearla desde 0 o cogiendo la semilla de otra o partiendo de otra progresi�n o mutando el acorde n� n
}
//---------------------------------------------------------------------------

