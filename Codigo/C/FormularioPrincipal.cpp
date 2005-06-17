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
#include "Opciones_Armonizacion.h"
#include "Form_Editar_Progresion.h"
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
Eligiendo_Subbloque=false;
Eligiendo_PistaArmonizar=false;
unidad_de_union=new Unidad_Nexo();

//FIXME DIR de trabajo
    String directorio_de_trabajo="..\\..\\";
    if (chdir(directorio_de_trabajo.c_str())==-1)
    {ShowMessage("Error cambiando el directorio de trabajo");};
    Inicializa_Patrones_Ritmicos();
    Inicializa_Patrones_Bateria();
//FIXME DIR DE TRABAJO
//inicializar valores de columnas y tal
Alto_Fila=24;
Ancho_Columnas=25;
Numero_Filas_A_Dibujar=0;
Numero_Bloques=0;
Ancho_Espacio_Estatico=50;
Barra_Tipo_Pista->Brush->Style=bsClear;
Barra_N_Compases_Bloque->Brush->Style=bsClear;
Barra_Tempo->Brush->Style=bsClear;
}
//---------------------------------------------------------------------------
void TForm1::Inicializa_Patrones_Ritmicos()
{
  DIR *dir;
  struct dirent *ent;
  if ((dir = opendir("PatronesRitmicos")) == NULL)
  {
    ShowMessage("Error leyendo directorio");
  }
  else
  {
    Selector_Patron_Ritmico->Items->Clear();
    Lista_Patrones_Melodia->Items->Clear();
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
      Lista_Patrones_Melodia->Items->Add(ent->d_name);
      Selector_Patron_Ritmico->Text=ent->d_name;
      Lista_Patrones_Melodia->Text=ent->d_name;
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
  //refrescamos los lo que sea
  Inicializa_Patrones_Ritmicos();

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
int columna_pulsada2;
int fila_pulsada2;
if ((Eligiendo_Subbloque==false)&&(Eligiendo_PistaArmonizar==false))//si no, no nos interesa actualizar estos
{
Columna_Pulsada=0;
Fila_Pulsada=Y_Relativo/Alto_Fila;
}
else
{
 columna_pulsada2=0;
 fila_pulsada2=Y_Relativo/Alto_Fila;
}

//ShowMessage(Fila_Pulsada);
int X_Relativo=X-X_Inicial-Ancho_Espacio_Estatico;
if (X_Relativo<0)
 {
  if((Eligiendo_Subbloque==false)&&(Eligiendo_PistaArmonizar==false))
  {
  //Activar cuadro de cabecera de pista
  if (Fila_Pulsada<Numero_Filas_A_Dibujar)
  {
    Cuadro_Cabecera_Pista();
  }
  }
 }
else
 {

  if ((Eligiendo_Subbloque==false)&&(Eligiendo_PistaArmonizar==false))
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
  else
  {
  // primero subbloque
  if (Eligiendo_Subbloque)
  {
    if ((fila_pulsada2<Numero_Filas_A_Dibujar)&&(columna_pulsada2<Numero_Bloques))
    {
    columna_pulsada2=X_Relativo/Ancho_Columnas;
    //tenemos en fila_pulsada2 y columna_pulsada2 la dirección del bloque que queremos
    //comprobamos que sea del tipo melodía
    if (Musica_Genaro->Dame_Tipo_Pista(fila_pulsada2)!=1)
    {
      ShowMessage("Elige pista de melodía, por favor");
      return;
    }
    Bloque bloque_A=Musica_Genaro->Dame_Pista(fila_pulsada2)->Dame_Bloque(columna_pulsada2);
    Bloque bloque_Trabajo=Musica_Genaro->Dame_Pista(Fila_Pulsada)->Dame_Bloque(Columna_Pulsada);
    if (bloque_A.Tipo_Music==NULL){ShowMessage("No tiene midi creado, Acción anulada");Eligiendo_Subbloque=false;return;}
    if (bloque_A.Num_Compases!=bloque_Trabajo.Num_Compases){ShowMessage("No tienen el mismo número de compases. Acción anulada");Eligiendo_Subbloque=false;return;}
    //en caso de que podamos copiarlo, lo copiamos
    bloque_Trabajo.Copia(bloque_A,Columna_Pulsada*100+Fila_Pulsada);
    //hacemos la copia
    Musica_Genaro->Dame_Pista(Fila_Pulsada)->Cambia_Bloque(bloque_Trabajo,Columna_Pulsada);
    Dibuja_Cancion();
    Eligiendo_Subbloque=false;
    ShowMessage("Copia finalizada");
    Radio_Copiar_Melodia->Checked=false;
    Radio_Delegar_Haskell->Checked=true;
    Cuadro_Bloque_Pista();
    }
    else
    {
      ShowMessage("Has de pinchar sobre un bloque válido, operación cancelada");
      Eligiendo_Subbloque=false;
      Radio_Copiar_Melodia->Checked=false;
      Radio_Delegar_Haskell->Checked=true;
      return;
    }
  }
  //ahora pista
  if (Eligiendo_PistaArmonizar)
  {
    if (fila_pulsada2<Numero_Filas_A_Dibujar)
    {
      if (Musica_Genaro->Dame_Tipo_Pista(fila_pulsada2)!=1)
      {
        ShowMessage("Has de elegir una pista de melodía válida, operación cancelada");
        Eligiendo_PistaArmonizar=false;
        Radio_Armonizar_Melodia->Checked=false;
        Radio_Crear_Progresion->Checked=true;
        return;
      }
    Bloque bloque_A=Musica_Genaro->Dame_Pista(fila_pulsada2)->Dame_Bloque(Columna_Pulsada);
    Bloque bloque_Trabajo=Musica_Genaro->Dame_Pista(Fila_Pulsada)->Dame_Bloque(Columna_Pulsada);
    if (bloque_A.Tipo_Music==NULL){
      ShowMessage("No tiene midi asociado");
      Eligiendo_PistaArmonizar=false;
      Radio_Armonizar_Melodia->Checked=false;
      Radio_Crear_Progresion->Checked=true;
      return;}
    //llamamos a crear prog_armonizada
    //1- pedimos nombre de progresión
    if(Salvar_Progresion->Execute()==false)
    {ShowMessage("Operación Cancelada por el usuario");return;}
    String Nombre=Salvar_Progresion->FileName;
    String fichero="";
    for (int i=0;i<Nombre.Length();i++)
     {
      if (Nombre[i+1]=='\\'){fichero="";}
      else{fichero+=Nombre[i+1];}
     }
    int temp=fichero.Length();
    if ((temp>=5)&&((fichero[temp]!='g')||(fichero[temp-1]!='o')||(fichero[temp-2]!='r')||(fichero[temp-3]!='p')||(fichero[temp-4]!='.')))
    {fichero+=".prog";}
    if (temp<5){fichero+=".prog";}
    //2- llamamos a crear la progresión con el midi de bloque A y con la progresion nueva
    Crea_Progresion_Armonizando(bloque_A.Tipo_Music,fichero);
    //3- actualizamos bloque
    bloque_Trabajo.Progresion=fichero;
    //4- quitamos la opción del radio buton armonizar
    Eligiendo_PistaArmonizar=false;
    Radio_Armonizar_Melodia->Checked=false;
    Radio_Crear_Progresion->Checked=true;
    Musica_Genaro->Dame_Pista(Fila_Pulsada)->Cambia_Bloque(bloque_Trabajo,Columna_Pulsada);
    Cuadro_Bloque_Pista();    
    return;
    }
    else
    {
      ShowMessage("Has de pinchar sobre una pista válido, operación cancelada");
      Eligiendo_PistaArmonizar=false;
      Radio_Armonizar_Melodia->Checked=false;
      Radio_Crear_Progresion->Checked=true;
      return;
    }

  }
  }
 }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::NuevoClick(TObject *Sender)
{
Eligiendo_Subbloque=false;
if (Inicializado)
{
  Musica_Genaro->Limpia();
  Numero_Filas_A_Dibujar=0;
  Numero_Bloques=0;
  Dibuja_Cancion();
//  TBrushStyle estilo_temp=this->Canvas->Brush->Style;
  this->Canvas->Brush->Color=clGray;
  this->Canvas->FillRect(Rect(X_Inicial,Y_Inicial,X_Final,Y_Final));
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
switch (Musica_Genaro->Dame_Tipo_Pista(Fila_Pulsada))
{
  case 0:{Tipo_Pista->Caption="Acompañamiento";break;}
  case 1:{Tipo_Pista->Caption="Melodía";break;}
  case 2:{Tipo_Pista->Caption="Bajo";break;}
  case 3:{Tipo_Pista->Caption="Batería";break;}
}
//Tipo_Pista->Caption=IntToStr(Musica_Genaro->Dame_Tipo_Pista(Fila_Pulsada));
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
    case 2:this->Canvas->Brush->Color=clAqua;break;
    case 3:this->Canvas->Brush->Color=clYellow;break;
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
Bloquea_Elementos(Musica_Genaro->Dame_Tipo_Pista(Fila_Pulsada));
Bloque Bloque_A_Manipular=Musica_Genaro->Dame_Pista(Fila_Pulsada)->Dame_Bloque(Columna_Pulsada);
Etiqueta_Bloque_Numero_Compases->Caption="Nº Compases de su bloque: "+IntToStr(Bloque_A_Manipular.Num_Compases);
Label35->Caption="Pista: "+IntToStr(Fila_Pulsada)+"       Bloque: "+IntToStr(Columna_Pulsada);
Lista_8_Inicial->Text=IntToStr(Bloque_A_Manipular.Octava_Inicial);
Barra_Numero_Divisiones->Position=Bloque_A_Manipular.N_Divisiones;
Barra_Fase2->Position=Bloque_A_Manipular.Fase2;
Barra_Fase3->Position=Bloque_A_Manipular.Fase3;
Barra_Fase4->Position=Bloque_A_Manipular.Fase4;
Label51->Caption=Bloque_A_Manipular.Progresion;

if (Musica_Genaro->Dame_Tipo_Pista(Fila_Pulsada)==3)
{
Combo_Bateria->Visible=true;
Label52->Visible=true;
}
else
{
Combo_Bateria->Visible=false;
Label52->Visible=false;
}


if (Bloque_A_Manipular.Triadas){Radio_Triadas->Checked=true;}
else{Radio_Cuatriadas->Checked=true;}

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

Edit1->Text=IntToStr(Bloque_A_Manipular.Bajo_Duracion_Numerador);
Edit2->Text=IntToStr(Bloque_A_Manipular.Bajo_Duracion_Denominador);
ComboBox2->Text=ComboBox2->Items->Strings[Bloque_A_Manipular.Bajo_Tipo];
TrackBar2->Position=Bloque_A_Manipular.Bajo_Parametro1;
Label43->Caption=IntToStr(TrackBar2->Position);
TrackBar3->Position=Bloque_A_Manipular.Bajo_Parametro2;
Label45->Caption=IntToStr(TrackBar3->Position);
TrackBar1->Position=Bloque_A_Manipular.Bajo_Parametro3;
Label40->Caption=IntToStr(TrackBar1->Position);
TrackBar4->Position=Bloque_A_Manipular.Bajo_Parametro4;
Label47->Caption=IntToStr(TrackBar4->Position);
TrackBar5->Position=Bloque_A_Manipular.Bajo_Parametro5;
Label49->Caption=IntToStr(TrackBar5->Position);

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
      Tab_Parametros_Melodia->Enabled=false;
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
      Tab_Parametros_Melodia->Enabled=true;
      Inicializa_Pistas_Acompanamiento();
      //Pista de acompañamiento=X;
      Selector_Pista_Acompanamiento->Text="Pista Nº "+IntToStr(Bloque_A_Manipular.N_Pista_Acomp);
      break;
    }
  case 2:
    {
      Tab_General->Enabled=true;
      Tab_Patron_Ritmico->Enabled=false;
      Tab_Aplicacion_Patron->Enabled=false;
      Tab_Progresion->Enabled=false;
      Tab_Crear_Progresion->Enabled=false;
      Tab_Melodia->Enabled=true;
      Tab_Parametros_Melodia->Enabled=true;
      Inicializa_Pistas_Acompanamiento();
      //Pista de acompañamiento=X;
      Selector_Pista_Acompanamiento2->Text="Pista Nº "+IntToStr(Bloque_A_Manipular.N_Pista_Acomp);
      break;
    }
  case 3:
    {
      Tab_General->Enabled=true;
      Tab_Patron_Ritmico->Enabled=false;
      Tab_Aplicacion_Patron->Enabled=false;
      Tab_Progresion->Enabled=false;
      Tab_Crear_Progresion->Enabled=false;
      Tab_Melodia->Enabled=false;
      Tab_Parametros_Melodia->Enabled=false;
      Inicializa_Pistas_Acompanamiento();
      //Pista de acompañamiento=X;
      //Selector_Pista_Acompanamiento2->Text="Pista Nº "+IntToStr(Bloque_A_Manipular.N_Pista_Acomp);
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
Lista_Patrones_Melodia->Text=Bloque_A_Manipular.Patron_Ritmico;

if(Combo_Bateria->Items->IndexOf(Bloque_A_Manipular.Patron_Ritmico)==-1)
{
  Combo_Bateria->Text=Combo_Bateria->Items->Strings[0];
}
else
{Combo_Bateria->Text=Bloque_A_Manipular.Patron_Ritmico;}


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
if ((Musica_Genaro->Dame_Tipo_Pista(Fila_Pulsada)!=1)&&(Musica_Genaro->Dame_Tipo_Pista(Fila_Pulsada)!=3))
{
Bloque_A_Manipular.Patron_Ritmico=Selector_Patron_Ritmico->Text;
}
else
{
if (Musica_Genaro->Dame_Tipo_Pista(Fila_Pulsada)==1)
  {
  Bloque_A_Manipular.Patron_Ritmico=Lista_Patrones_Melodia->Text;
  }
if (Musica_Genaro->Dame_Tipo_Pista(Fila_Pulsada)==3)
  {
  Bloque_A_Manipular.Patron_Ritmico=Combo_Bateria->Text;
  }
}
Bloque_A_Manipular.Notas_Totales=Barra_Notas_Totales->Position;
Bloque_A_Manipular.Es_Sistema_Paralelo=Sistema_Paralelo->Checked;
Bloque_A_Manipular.Inversion=Lista_Inversion->Text;
Bloque_A_Manipular.Disposicion=Lista_Disposicion->Text;
Bloque_A_Manipular.Octava_Inicial=StrToInt(Lista_8_Inicial->Text);
Bloque_A_Manipular.N_Divisiones=Barra_Numero_Divisiones->Position;
Bloque_A_Manipular.Fase2=Barra_Fase2->Position;
Bloque_A_Manipular.Fase3=Barra_Fase3->Position;
Bloque_A_Manipular.Fase4=Barra_Fase4->Position;
Bloque_A_Manipular.Triadas=Radio_Triadas->Checked;

String temp1=Edit1->Text+" ";
int t1=Procesa_Num_Natural(temp1);
String temp2=Edit2->Text+" ";
int t2=Procesa_Num_Natural(temp2);
if ((t1==-1)||(t2==-1))
{ShowMessage("Duración de la nota del bajo no válida");}
else
{
Bloque_A_Manipular.Bajo_Duracion_Numerador=t1;
Bloque_A_Manipular.Bajo_Duracion_Denominador=t2;
}

Bloque_A_Manipular.Bajo_Tipo=ComboBox2->Items->IndexOf(ComboBox2->Text);
Bloque_A_Manipular.Bajo_Parametro1=TrackBar2->Position;
Bloque_A_Manipular.Bajo_Parametro2=TrackBar3->Position;
Bloque_A_Manipular.Bajo_Parametro3=TrackBar1->Position;
Bloque_A_Manipular.Bajo_Parametro4=TrackBar4->Position;
Bloque_A_Manipular.Bajo_Parametro5=TrackBar5->Position;
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
int seleccion_pista=-1;
if (Musica_Genaro->Dame_Tipo_Pista(Fila_Pulsada)==1)
{
seleccion_pista=Selector_Pista_Acompanamiento->Items->IndexOf(Selector_Pista_Acompanamiento->Text);
}
if (Musica_Genaro->Dame_Tipo_Pista(Fila_Pulsada)==2)
{
seleccion_pista=Selector_Pista_Acompanamiento2->Items->IndexOf(Selector_Pista_Acompanamiento2->Text);
}

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
  case 2:Etiqueta_Tipo_Pista->Caption="Bajo";break;
  case 3:Etiqueta_Tipo_Pista->Caption="Batería";break;
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
//---------------------------------------------------------------------------
void __fastcall TForm1::Button12Click(TObject *Sender)
{

if(Salvar_Progresion->Execute()==false)
{ShowMessage("Operación Cancelada por el usuario");return;}
String Nombre=Salvar_Progresion->FileName;
String fichero="";
for (int i=0;i<Nombre.Length();i++)
 {
  if (Nombre[i+1]=='\\'){fichero="";}
  else{fichero+=Nombre[i+1];}
 }
int temp=fichero.Length();
if ((temp>=5)&&((fichero[temp]!='g')||(fichero[temp-1]!='o')||(fichero[temp-2]!='r')||(fichero[temp-3]!='p')||(fichero[temp-4]!='.')))
{fichero+=".prog";}
if (temp<5){fichero+=".prog";}
if (Radio_Crear_Progresion->Checked)
{
  Progresion_Crear_Progresion(fichero);
}
if (Radio_Mutar_Progresion->Checked)
{
  Progresion_Mutar_Progresion(fichero);
}
if (Radio_Mutar_Acorde_Progresion->Checked)
{
  Progresion_Mutar_Acorde_Progresion(fichero);
}
if (Radio_Mutar_Progresion_Multiple->Checked)
{
  Progresion_Mutar_Progresion_Multiple(fichero);
}
if (Radio_Armonizar_Melodia->Checked)
{
 // Progresion_Mutar_Progresion_Multiple(fichero);
}
Bloque Bloque_A_Manipular=Musica_Genaro->Dame_Pista(Fila_Pulsada)->Dame_Bloque(Columna_Pulsada);
/*char work_dir[255];
getcwd(work_dir, 255);
String directorio_trabajo1=work_dir;  */
Bloque_A_Manipular.Progresion=fichero;//"progresion_"+IntToStr(Fila_Pulsada)+"_"+IntToStr(Columna_Pulsada)+".prog";
Label51->Caption=Bloque_A_Manipular.Progresion;
Musica_Genaro->Dame_Pista(Fila_Pulsada)->Cambia_Bloque(Bloque_A_Manipular,Columna_Pulsada);
Progresion_A_Grid();
}
//---------------------------------------------------------------------------
void TForm1::Progresion_Crear_Progresion(String fichero)
{
char work_dir[255];
getcwd(work_dir, 255);
String directorio_trabajo1=work_dir;
String directorio_trabajo="\""+directorio_trabajo1+"\"";
String Orden="crea_progresion";
String Ruta_Destino="\""+directorio_trabajo1+"\\"+fichero+"\"";//progresion_"+IntToStr(Fila_Pulsada)+"_"+IntToStr(Columna_Pulsada)+".prog"+"\"";
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
void TForm1::Progresion_Mutar_Progresion(String fichero)
{
//de momento creamos progresión y punto
//Guardamos la progresión con un nombre temporal y al guardar cambios lo cambiamos y ponemos
char work_dir[255];
getcwd(work_dir, 255);
String directorio_trabajo1=work_dir;
String directorio_trabajo="\""+directorio_trabajo1+"\"";
String Orden="muta_progresion";
String Ruta_Destino="\""+directorio_trabajo1+"\\"+fichero+"\"";//progresion_"+IntToStr(Fila_Pulsada)+"_"+IntToStr(Columna_Pulsada)+".prog"+"\"";

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
void TForm1::Progresion_Mutar_Acorde_Progresion(String fichero)
{
//de momento creamos progresión y punto
//Guardamos la progresión con un nombre temporal y al guardar cambios lo cambiamos y ponemos
char work_dir[255];
getcwd(work_dir, 255);
String directorio_trabajo1=work_dir;
String directorio_trabajo="\""+directorio_trabajo1+"\"";
String Orden="muta_progresion_acorde";
String Ruta_Destino="\""+directorio_trabajo1+"\\"+fichero+"\"";//Progresion_"+IntToStr(Fila_Pulsada)+"_"+IntToStr(Columna_Pulsada)+".prog"+"\"";
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
void TForm1::Progresion_Mutar_Progresion_Multiple(String fichero)
{
//de momento creamos progresión y punto
//Guardamos la progresión con un nombre temporal y al guardar cambios lo cambiamos y ponemos
char work_dir[255];
getcwd(work_dir, 255);
String directorio_trabajo1=work_dir;
String directorio_trabajo="\""+directorio_trabajo1+"\"";
String Orden="crea_con_semilla";
String Ruta_Destino="\""+directorio_trabajo1+"\\"+fichero+"\"";//progresion_"+IntToStr(Fila_Pulsada)+"_"+IntToStr(Columna_Pulsada)+".prog"+"\"";
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
}
else
{
  Label_Texto_Muta_Acorde->Enabled=false;
}
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Radio_Mutar_ProgresionClick(TObject *Sender)
{
if (Radio_Mutar_Acorde_Progresion->Checked)
{
  Label_Texto_Muta_Acorde->Enabled=true;
}
else
{
  Label_Texto_Muta_Acorde->Enabled=false;
}  
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Radio_Mutar_Acorde_ProgresionClick(TObject *Sender)
{
if (Radio_Mutar_Acorde_Progresion->Checked)
{
  Label_Texto_Muta_Acorde->Enabled=true;
}
else
{
  Label_Texto_Muta_Acorde->Enabled=false;
}  
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Radio_Mutar_Progresion_MultipleClick(
      TObject *Sender)
{
if (Radio_Mutar_Acorde_Progresion->Checked)
{
  Label_Texto_Muta_Acorde->Enabled=true;
}
else
{
  Label_Texto_Muta_Acorde->Enabled=false;
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
Selector_Pista_Acompanamiento2->Items->Clear();
for (int i=0;i<Musica_Genaro->Dame_Numero_Pistas();i++)
 {
  if (Musica_Genaro->Dame_Tipo_Pista(i)==0)
  {
    Selector_Pista_Acompanamiento2->Items->Add("Pista Nº "+IntToStr(i));
  }
 }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Guardar1Click(TObject *Sender)
{
if (Inicializado)
{
if(Salvar_Genaro->Execute()==false)
{ShowMessage("Operación Cancelada por el usuario");return;}
String Nombre=Salvar_Genaro->FileName;
String fichero="";
for (int i=0;i<Nombre.Length();i++)
 {
  if (Nombre[i+1]=='\\'){fichero="";}
  else{fichero+=Nombre[i+1];}
 }
int temp=fichero.Length();
if ((temp>=4)&&((fichero[temp]!='r')||(fichero[temp-1]!='n')||(fichero[temp-2]!='g')||(fichero[temp-3]!='.')))
{fichero+=".gnr";}
if (temp<4)
{fichero+=".gnr";}
Musica_Genaro->Guarda_Archivo(fichero);
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
if (Musica_Genaro->Dame_Tipo_Pista(Fila_Pulsada)==2)
{
  Genera_Music_Bajo();
}
if (Musica_Genaro->Dame_Tipo_Pista(Fila_Pulsada)==3)
{
  Genera_Music_Bateria();
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
    String automatica="progresion_"+IntToStr(Fila_Pulsada)+"_"+IntToStr(Columna_Pulsada)+".prog";
    Progresion_Crear_Progresion(automatica);
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
  String Pal_Triadas="Triadas";
  String Triadas;
  if (Bloque_A_Manipular.Triadas){Triadas="True";}
  else{Triadas="False";}
  if (Radio_Vertical_Menor_Truncar->Checked){Vertical_Menor="Truncar2";}
  if (Radio_Vertical_Menor_Saturar->Checked){Vertical_Menor="Saturar2";}
  if (Radio_Vertical_Menor_Ciclico->Checked){Vertical_Menor="Ciclico2";}
  if (Radio_Vertical_Menor_Modulo->Checked){Vertical_Menor="Modulo2";}
  String Ruta_Destino_Music="Music_"+IntToStr(Fila_Pulsada)+"_"+IntToStr(Columna_Pulsada)+".mid";
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
    Pal_Horizontal.c_str(),horizontal.c_str(),Pal_Vertical_Mayor.c_str(),Vertical_Mayor.c_str(),Pal_Vertical_Menor.c_str(),Vertical_Menor.c_str(),Pal_Triadas.c_str(),Triadas.c_str(),Ruta_Destino_Music.c_str(),NULL);
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
      Pal_Horizontal.c_str(),horizontal.c_str(),Pal_Vertical_Mayor.c_str(),Vertical_Mayor.c_str(),Pal_Vertical_Menor.c_str(),Vertical_Menor.c_str(),Pal_Triadas.c_str(),Triadas.c_str(),Ruta_Destino_Music.c_str(),NULL);
      if (valor_spawn==-1)
      {ShowMessage("Error ejecutando el runhugs de haskell.");}
    }
    else
    {
      Pal_Semilla="semilla";
      String Semilla=Edit_Semilla->Text;
      int valor_spawn=spawnl(P_WAIT,Ruta_Haskell.c_str(),Ruta_Haskell.c_str(),Ruta_Codigo_Haskell.c_str(),directorio_trabajo.c_str(),Orden.c_str(),Ruta_Progresion.c_str(),P_Ritmico.c_str(),
      Pal_Octava.c_str(),O_Inicial.c_str(),Pal_Notas.c_str(),N_Notas.c_str(),Pal_Sistema.c_str(),Sistem.c_str(),Pal_Semilla.c_str(),Semilla.c_str(),
      Pal_Horizontal.c_str(),horizontal.c_str(),Pal_Vertical_Mayor.c_str(),Vertical_Mayor.c_str(),Pal_Vertical_Menor.c_str(),Vertical_Menor.c_str(),Pal_Triadas.c_str(),Triadas.c_str(),Ruta_Destino_Music.c_str(),NULL);
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
{ShowMessage("Operación Cancelada, esto parece la seguridad social");return;}
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
Label51->Caption=Bloque_A_Manipular.Progresion;
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
  String Parametro1=Barra_Prob_Salto->Position; //salto maximo
  String Parametro2=Barra_Salto_Maximo->Position; //probabilidad de salto
  String Parametro3=Barra_Numero_Puntos->Position; //numero de puntos
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
//  String Ruta_Patron="./PatronesRitmicos/"+Bloque_Acompanamiento.Patron_Ritmico;
  String Ruta_Patron="./PatronesRitmicos/"+Bloque_A_Manipular.Patron_Ritmico;
  String Pal_Parametros="parametros_curva";
  String Parametro1=Bloque_A_Manipular.N_Divisiones;//numero de divisiones (0-10)
  String Parametro2=Bloque_A_Manipular.Fase2;//numero de aplicaciones de fase 2 (0-50)
  String Parametro3=Bloque_A_Manipular.Fase3;//numero de aplicaciones de fase 3 (0-50)
  String Parametro4=Bloque_A_Manipular.Fase4;//numero de aplicaciones de fase 4 (0-50)
  String Pal_Ruta_Destino="ruta_dest_music";
  String Ruta_Destino_Music="Music_"+IntToStr(Fila_Pulsada)+"_"+IntToStr(Columna_Pulsada)+".mid";

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
  String Fichero_Gen="Fichero_Indice.gen";
  String Tonalidad=ComboBox1->Text;
  Musica_Genaro->Guarda_Archivo_Haskell(Fichero_Gen,Barra_Tempo->Position,Tonalidad);
  //creamos midi
  char work_dir[255];
  getcwd(work_dir, 255);
  String directorio_trabajo=work_dir;
  directorio_trabajo="\""+directorio_trabajo+"\"";
  String Ruta_Haskell=unidad_de_union->Dame_Interfaz_Haskell()->Dame_Ruta_Haskell();
  String Ruta_Codigo_Haskell=unidad_de_union->Dame_Interfaz_Haskell()->Dame_Ruta_Codigo_Haskell();
  String Orden="generaObraCompleta";
  String Parametro1="archivoGen";

  String Parametro2="ruta_midi";
  String Midi_salida="musica_genara.mid";
  String Chapucilla="+h300000";
  int valor_spawn=spawnl(P_WAIT,Ruta_Haskell.c_str(),Ruta_Haskell.c_str(),Chapucilla.c_str(),Ruta_Codigo_Haskell.c_str(),directorio_trabajo.c_str(),Orden.c_str(),Parametro1.c_str(),Fichero_Gen.c_str(),Parametro2.c_str(),Midi_salida.c_str(),NULL);
  if (valor_spawn==-1)
  {ShowMessage("Error ejecutando el runhugs de haskell.");}
 }
}
}
//---------------------------------------------------------------------------
int TForm1::Comprobar_Si_Generados_Music()
{
//bool Correcto=true;
for (int i=0;i<Musica_Genaro->Dame_Numero_Pistas();i++)
{
  for (int j=0; j<Musica_Genaro->Dame_Pista(i)->Dame_Numero_Bloques();j++)
  {
    if(Musica_Genaro->Dame_Pista(i)->Dame_Bloque(j).Tipo_Music==NULL)
    {
      if (Musica_Genaro->Dame_Pista(i)->Dame_Bloque(j).Vacio==false)
      {
      ShowMessage("No están generados todos los tipos music");
      return -1;
      }
    }
  }
}
return 0;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Barra_TempoChange(TObject *Sender)
{
Etiqueta_Tempo->Caption=IntToStr(Barra_Tempo->Position);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Barra_Numero_DivisionesChange(TObject *Sender)
{
Label20->Caption=IntToStr(Barra_Numero_Divisiones->Position);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Barra_Fase3Change(TObject *Sender)
{
Label22->Caption=StrToInt(Barra_Fase3->Position);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Barra_Fase2Change(TObject *Sender)
{
Label21->Caption=StrToInt(Barra_Fase2->Position);  
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Barra_Fase4Change(TObject *Sender)
{
Label23->Caption=StrToInt(Barra_Fase4->Position);  
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Barra_Prob_SaltoChange(TObject *Sender)
{
Label27->Caption=StrToInt(Barra_Prob_Salto->Position);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Barra_Salto_MaximoChange(TObject *Sender)
{
Label28->Caption=StrToInt(Barra_Salto_Maximo->Position);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Barra_Numero_PuntosChange(TObject *Sender)
{
Label29->Caption=StrToInt(Barra_Numero_Puntos->Position);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Image1Click(TObject *Sender)
{
this->Click();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Boton_EdicionClick(TObject *Sender)
{
Form3->StringGrid1->ColCount=Grid_Progresion->ColCount;
for (int i=0;i<Grid_Progresion->ColCount;i++)
{
Form3->StringGrid1->Cols[i]=Grid_Progresion->Cols[i];
}
Form3->Show();
}
//---------------------------------------------------------------------------
void TForm1::Bloquea_Elementos(int TipoPista)
{
switch (TipoPista)
{
  case 0:
  {
    Cambia_Tab_General(true);
    Cambia_Tab_Patron_Ritmico(true);
    Cambia_Tab_Aplicacion_Patron(true);
    Cambia_Tab_Progresion(true);
    Cambia_Tab_Melodia(false);
    Cambia_Tab_Info_Melodia(false);
    Cambia_Tab_Bajo(false);
    break;
  }
  case 1:
  {
    Cambia_Tab_General(true);
    Cambia_Tab_Patron_Ritmico(false);
    Cambia_Tab_Aplicacion_Patron(false);
    Cambia_Tab_Progresion(false);
    Cambia_Tab_Melodia(true);
    Cambia_Tab_Info_Melodia(true);
    Cambia_Tab_Bajo(false);
    break;
  }
  case 2:
  {
    Cambia_Tab_General(true);
    Cambia_Tab_Patron_Ritmico(false);
    Cambia_Tab_Aplicacion_Patron(false);
    Cambia_Tab_Progresion(false);
    Cambia_Tab_Melodia(false);
    Cambia_Tab_Info_Melodia(false);
    Cambia_Tab_Bajo(true);
    break;
  }
  case 3:
  {
    Cambia_Tab_General(true);     //tendremos un selector de baterias.. o no...
    Cambia_Tab_Patron_Ritmico(false);
    Cambia_Tab_Aplicacion_Patron(false);
    Cambia_Tab_Progresion(false);
    Cambia_Tab_Melodia(false);
    Cambia_Tab_Info_Melodia(false);
    Cambia_Tab_Bajo(false);
    //    Cambia_Tab_Patron_Ritmico(true);
    //    Cambia_Tab_Aplicacion_Patron(true);
    break;
  }
}

}
//--------------------------------------------------------
void TForm1::Cambia_Tab_General(bool condicion)
{
    Tab_General->Enabled=condicion;
    Label8->Enabled=condicion;
    Bloque_Vacio->Enabled=condicion;
    Etiqueta_Bloque_Numero_Compases->Enabled=condicion;
    Boton_Guardar_Cambios_Bloque->Enabled=condicion;
}
//-----------------------------------------------
void TForm1::Cambia_Tab_Patron_Ritmico(bool condicion)
{
Tab_Patron_Ritmico->Enabled=condicion;
Label6->Enabled=condicion;
Label4->Enabled=condicion;
Etiqueta_Inversion->Enabled=condicion;
Lista_8_Inicial->Enabled=condicion;
Selector_Patron_Ritmico->Enabled=condicion;
Lista_Inversion->Enabled=condicion;
Label5->Enabled=condicion;
Barra_Notas_Totales->Enabled=condicion;
Etiqueta_Numero_Total_De_Notas->Enabled=condicion;
RadioGroup1->Enabled=condicion;
Sistema_Paralelo->Enabled=condicion;
Sistema_Continuo->Enabled=condicion;
Etiqueta_Disposicion->Enabled=condicion;
Lista_Disposicion->Enabled=condicion;
Check_Semilla->Enabled=condicion;
Edit_Semilla->Enabled=false;
}
//-----------------------------------------------
void TForm1::Cambia_Tab_Melodia(bool condicion)
{
Tab_Melodia->Enabled=condicion;
RadioGroup2->Enabled=condicion;
Radio_Copiar_Melodia->Enabled=condicion;
Radio_Editor_Midi->Enabled=false;
Radio_Curva_Melodia->Enabled=condicion;
Radio_Delegar_Haskell->Enabled=condicion;
Label31->Enabled=condicion;
Label32->Enabled=condicion;
Barra_Mutaciones_Curva->Enabled=condicion;
Barra_Salto_Maximo_Mutaciones->Enabled=condicion;
Label34->Enabled=condicion;
Label7->Enabled=condicion;
Selector_Pista_Acompanamiento->Enabled=condicion;
Label30->Enabled=condicion;
Lista_Patrones_Melodia->Enabled=condicion;
Button9->Enabled=condicion;
Boton_Cargar_Curva->Enabled=condicion;
Boton_Mutar_Curva->Enabled=condicion;
Button8->Enabled=false;
Label24->Enabled=condicion;
Label27->Enabled=condicion;
Label28->Enabled=condicion;
Label25->Enabled=condicion;
Label26->Enabled=condicion;
Label29->Enabled=condicion;
Barra_Prob_Salto->Enabled=condicion;
Barra_Salto_Maximo->Enabled=condicion;
Barra_Numero_Puntos->Enabled=condicion;
}
//-----------------------------------------------
void TForm1::Cambia_Tab_Info_Melodia(bool condicion)
{
Tab_Parametros_Melodia->Enabled=condicion;
Label11->Enabled=condicion;
Label17->Enabled=condicion;
Label18->Enabled=condicion;
Label21->Enabled=condicion;
Label20->Enabled=condicion;
Label22->Enabled=condicion;
Label23->Enabled=condicion;
Label19->Enabled=condicion;
Barra_Numero_Divisiones->Enabled=condicion;
Barra_Fase3->Enabled=condicion;
Barra_Fase2->Enabled=condicion;
Barra_Fase4->Enabled=condicion;
}
//-----------------------------------------------
void TForm1::Cambia_Tab_Bajo(bool condicion)
{
Tab_Bajo->Enabled=condicion;
Label36->Enabled=condicion;
Label38->Enabled=condicion;
Label39->Enabled=condicion;
Label44->Enabled=condicion;
Label42->Enabled=condicion;
Label43->Enabled=condicion;
Label45->Enabled=condicion;
Label41->Enabled=condicion;
Label40->Enabled=condicion;
Label47->Enabled=condicion;
Label46->Enabled=condicion;
Label48->Enabled=condicion;
Label49->Enabled=condicion;
Edit1->Enabled=condicion;
Edit2->Enabled=condicion;
ComboBox2->Enabled=condicion;
TrackBar2->Enabled=condicion;
TrackBar3->Enabled=condicion;
TrackBar4->Enabled=condicion;
TrackBar5->Enabled=condicion;
TrackBar1->Enabled=condicion;
Selector_Pista_Acompanamiento2->Enabled=condicion;
Label50->Enabled=condicion;
}
//-----------------------------------------------
void TForm1::Cambia_Tab_Aplicacion_Patron(bool condicion)
{
Tab_Aplicacion_Patron->Enabled=condicion;
GroupBox2->Enabled=condicion;
Radio_Horizontal_Ciclico->Enabled=condicion;
Radio_Horizontal_No_Ciclico->Enabled=condicion;
GroupBox3->Enabled=condicion;
GroupBox4->Enabled=condicion;
GroupBox5->Enabled=condicion;
Radio_Vertical_Mayor_Truncar->Enabled=condicion;
Radio_Vertical_Mayor_Saturar->Enabled=condicion;
Radio_Vertical_Menor_Truncar->Enabled=condicion;
Radio_Vertical_Menor_Saturar->Enabled=condicion;
Radio_Vertical_Menor_Ciclico->Enabled=condicion;
Radio_Vertical_Menor_Modulo->Enabled=condicion;
Radio_Triadas->Enabled=condicion;
Radio_Cuatriadas->Enabled=condicion;
}
//-----------------------------------------------
void TForm1::Cambia_Tab_Mutar_Progresion(bool condicion)
{
Tab_Progresion->Enabled=condicion;
Radio_Mutaciones_Totales->Enabled=condicion;
Radio_Especificas->Enabled=false;
Barra_Mutaciones_Totales->Enabled=condicion;
Etiqueta_Mutaciones_Totales->Enabled=condicion;
Grupo_TipoA->Enabled=false;
Grupo_TipoB->Enabled=false;
Radio_TipoA_Generales->Enabled=false;
Radio_TipoA_Especificas->Enabled=false;
Etiqueta_TipoA_Generales->Enabled=false;
Barra_TipoA_Generales->Enabled=false;
Label13->Enabled=false;
Label12->Enabled=false;
Label14->Enabled=false;
Barra_Mutaciones_Junta_Acordes->Enabled=false;
Barra_Mutaciones_Separa_Acordes->Enabled=false;
Barra_Mutaciones_Cambia_Acordes->Enabled=false;
Radio_TipoB_Generales->Enabled=false;
Radio_TipoB_Especificas->Enabled=false;
Barra_TipoB_Generales->Enabled=false;
Etiqueta_TipoB_Generales->Enabled=false;
Label16->Enabled=false;
Label15->Enabled=false;
Barra_Mutaciones_Dominante_Sencundario->Enabled=false;
Etiqueta_Tipo4->Enabled=false;
Barra_Mutaciones_2M7->Enabled=false;
Etiqueta_Tipo5->Enabled=false;
}
//------------------------------------------------------------------------------
void TForm1::Cambia_Tab_Progresion(bool condicion)
{
Tab_Crear_Progresion->Enabled=condicion;
Radio_Crear_Progresion->Enabled=condicion;
Radio_Mutar_Progresion->Enabled=condicion;
Radio_Mutar_Acorde_Progresion->Enabled=condicion;
Radio_Mutar_Progresion_Multiple->Enabled=condicion;
Radio_Armonizar_Melodia->Enabled=condicion;
Button5->Enabled=condicion;
GroupBox1->Enabled=condicion;
Boton_Cargar_Progresion->Enabled=condicion;
Button12->Enabled=condicion;
Boton_Edicion->Enabled=condicion;
Grid_Progresion->Enabled=condicion;
Label_Texto_Muta_Acorde->Enabled=condicion;
Radio_Armonizar_Melodia->Enabled=condicion;
}
//------------------------------------------------------------------------------
void TForm1::Genera_Music_Bajo()
{
  char work_dir[255];
  getcwd(work_dir, 255);
  String directorio_trabajo=work_dir;
  directorio_trabajo="\""+directorio_trabajo+"\"";
  String Ruta_Haskell=unidad_de_union->Dame_Interfaz_Haskell()->Dame_Ruta_Haskell();
  String Ruta_Codigo_Haskell=unidad_de_union->Dame_Interfaz_Haskell()->Dame_Ruta_Codigo_Haskell();
  String Orden="generaBajo";
  Bloque Bloque_A_Manipular=Musica_Genaro->Dame_Pista(Fila_Pulsada)->Dame_Bloque(Columna_Pulsada);
/*  //si no hay curva asignada, se avisa y se sale
  if (Bloque_A_Manipular.Curva_Melodica==NULL){ShowMessage("No tiene curva melódica asignada");return;}
  String Pal_Rutacurva="ruta_curva";
  String Ruta_Curva=Bloque_A_Manipular.Curva_Melodica;    */
  String Pal_Rutaprogresion="progresion";
  //Hay que coger la progresion de la pista de acompañamiento asignada
  if(Bloque_A_Manipular.N_Pista_Acomp==-1){ShowMessage("No has asignado pista de acompañamiento para este subbloque");return;}
  Bloque Bloque_Acompanamiento=Musica_Genaro->Dame_Pista(Bloque_A_Manipular.N_Pista_Acomp)->Dame_Bloque(Columna_Pulsada);
  if (Bloque_Acompanamiento.Progresion==NULL){ShowMessage("El bloque de acompañamiento no tiene progresión asignada");return;}
  String Ruta_Progresion=Bloque_Acompanamiento.Progresion;
/*  String Pal_patron="ruta_patron";
  String Ruta_Patron="./PatronesRitmicos/"+Bloque_Acompanamiento.Patron_Ritmico;*/
  String Pal_Parametros="parametros";

  String temp1=Edit1->Text+" ";
  int t1=Procesa_Num_Natural(temp1);
  String temp2=Edit2->Text+" ";
  int t2=Procesa_Num_Natural(temp2);
  if ((t1==-1)||(t2==-1))
  {ShowMessage("Duración de la nota del bajo no válida");return;}

  String Parametro1=ComboBox2->Items->Strings[Bloque_A_Manipular.Bajo_Tipo];
  String Parametro2=IntToStr(t1);//numero de aplicaciones de fase 2 (0-50)
  String Parametro3=IntToStr(t2);//numero de aplicaciones de fase 3 (0-50)
  String Parametro4=IntToStr(TrackBar2->Position);
  String Parametro5=IntToStr(TrackBar3->Position);
  String Parametro6=IntToStr(TrackBar1->Position);
  String Parametro7=IntToStr(TrackBar4->Position);
  String Parametro8=IntToStr(TrackBar5->Position);

/*  String Parametro4=Bloque_A_Manipular.Fase4;//numero de aplicaciones de fase 4 (0-50)*/
  String Pal_Ruta_Destino="ruta_midi";
  String Ruta_Destino_Music="Music_"+IntToStr(Fila_Pulsada)+"_"+IntToStr(Columna_Pulsada)+".mid";

  int valor_spawn=spawnl(P_WAIT,Ruta_Haskell.c_str(),Ruta_Haskell.c_str(),Ruta_Codigo_Haskell.c_str(),directorio_trabajo.c_str(),Orden.c_str(),/*Pal_Rutacurva.c_str(),Ruta_Curva.c_str(),*/Pal_Rutaprogresion.c_str(),Ruta_Progresion.c_str(),/*Pal_patron.c_str(),Ruta_Patron.c_str(),*/Pal_Parametros.c_str(),Parametro1.c_str(),Parametro2.c_str(),Parametro3.c_str(),Parametro4.c_str(),Parametro5.c_str(),Parametro6.c_str(),Parametro7.c_str(),Parametro8.c_str(),/*Parametro4.c_str(),*/Pal_Ruta_Destino.c_str(),Ruta_Destino_Music.c_str(),NULL);
  if (valor_spawn==-1){ShowMessage("Error creando el music de melodia");}

  Bloque_A_Manipular.Tipo_Music=Ruta_Destino_Music;
  Musica_Genaro->Dame_Pista(Fila_Pulsada)->Cambia_Bloque(Bloque_A_Manipular,Columna_Pulsada);
}
//------------------------------------------------------------------------------
void TForm1::Genera_Music_Bateria()
{
  char work_dir[255];
  getcwd(work_dir, 255);
  String directorio_trabajo=work_dir;
  directorio_trabajo="\""+directorio_trabajo+"\"";
  String Ruta_Haskell=unidad_de_union->Dame_Interfaz_Haskell()->Dame_Ruta_Haskell();
  String Ruta_Codigo_Haskell=unidad_de_union->Dame_Interfaz_Haskell()->Dame_Ruta_Codigo_Haskell();
  String Orden="generaBateria";
  Bloque Bloque_A_Manipular=Musica_Genaro->Dame_Pista(Fila_Pulsada)->Dame_Bloque(Columna_Pulsada);
/*  //si no hay curva asignada, se avisa y se sale
  if (Bloque_A_Manipular.Curva_Melodica==NULL){ShowMessage("No tiene curva melódica asignada");return;}
  String Pal_Rutacurva="ruta_curva";
  String Ruta_Curva=Bloque_A_Manipular.Curva_Melodica;    */
/*  String Pal_Rutaprogresion="ruta_progresion";
  //Hay que coger la progresion de la pista de acompañamiento asignada
  if(Bloque_A_Manipular.N_Pista_Acomp==-1){ShowMessage("No has asignado pista de acompañamiento para este subbloque");return;}
  Bloque Bloque_Acompanamiento=Musica_Genaro->Dame_Pista(Bloque_A_Manipular.N_Pista_Acomp)->Dame_Bloque(Columna_Pulsada);
  if (Bloque_Acompanamiento.Progresion==NULL){ShowMessage("El bloque de acompañamiento no tiene progresión asignada");return;}
  String Ruta_Progresion=Bloque_Acompanamiento.Progresion;*/
  String Pal_patron="ruta_patron";
  String Ruta_Patron="./PatronesBateria/"+Bloque_A_Manipular.Patron_Ritmico;
  String Pal_Parametros="num_compases";
  String Parametro1=Bloque_A_Manipular.Num_Compases;//numero de divisiones (0-10)
/*  String Parametro2=Bloque_A_Manipular.Fase2;//numero de aplicaciones de fase 2 (0-50)
  String Parametro3=Bloque_A_Manipular.Fase3;//numero de aplicaciones de fase 3 (0-50)*/
/*  String Parametro4=Bloque_A_Manipular.Fase4;//numero de aplicaciones de fase 4 (0-50)*/
  String Pal_Ruta_Destino="ruta_midi";
  String Ruta_Destino_Music="Music_"+IntToStr(Fila_Pulsada)+"_"+IntToStr(Columna_Pulsada)+".mid";

  int valor_spawn=spawnl(P_WAIT,Ruta_Haskell.c_str(),Ruta_Haskell.c_str(),Ruta_Codigo_Haskell.c_str(),directorio_trabajo.c_str(),Orden.c_str(),/*Pal_Rutacurva.c_str(),Ruta_Curva.c_str(),Pal_Rutaprogresion.c_str(),Ruta_Progresion.c_str(),*/Pal_Parametros.c_str(),Parametro1.c_str(),Pal_patron.c_str(),Ruta_Patron.c_str(),/*Parametro2.c_str(),Parametro3.c_str(),*//*Parametro4.c_str(),*/Pal_Ruta_Destino.c_str(),Ruta_Destino_Music.c_str(),NULL);
  if (valor_spawn==-1){ShowMessage("Error creando el music de melodia");}

  Bloque_A_Manipular.Tipo_Music=Ruta_Destino_Music;
  Musica_Genaro->Dame_Pista(Fila_Pulsada)->Cambia_Bloque(Bloque_A_Manipular,Columna_Pulsada);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Boton_Cargar_CurvaClick(TObject *Sender)
{
if (Open_Curva->Execute())
{
String Progre=Open_Curva->FileName;
String fichero="";
for (int i=0;i<Progre.Length();i++)
 {
  if (Progre[i+1]=='\\'){fichero="";}
  else{fichero+=Progre[i+1];}
 }
String Copy="copy";
  String fichero1="CurvaMelodica_"+IntToStr(Fila_Pulsada)+"_"+IntToStr(Columna_Pulsada)+".cm";
  //abrimos fichero
  ifstream origen;
  origen.open(fichero.c_str());
  ofstream destino;
  destino.open(fichero1.c_str());
  char temp;
  while (true)
  {
    origen>>temp;
    if(origen.eof()!=true)
    {destino<<temp;}
    else{break;}
  }


  Bloque Bloque_A_Manipular=Musica_Genaro->Dame_Pista(Fila_Pulsada)->Dame_Bloque(Columna_Pulsada);
  Musica_Genaro->Dame_Pista(Fila_Pulsada)->Cambia_Bloque(Bloque_A_Manipular,Columna_Pulsada);
  Bloque_A_Manipular.Curva_Melodica=fichero1;
  Musica_Genaro->Dame_Pista(Fila_Pulsada)->Cambia_Bloque(Bloque_A_Manipular,Columna_Pulsada);
  origen.close();
  destino.close();
}
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Barra_Salto_Maximo_MutacionesChange(
      TObject *Sender)
{
Label34->Caption=IntToStr(Barra_Salto_Maximo_Mutaciones->Position);  
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Barra_Mutaciones_CurvaChange(TObject *Sender)
{
Label33->Caption=IntToStr(Barra_Mutaciones_Curva->Position);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Boton_Mutar_CurvaClick(TObject *Sender)
{
  char work_dir[255];
  getcwd(work_dir, 255);
  String directorio_trabajo=work_dir;
  directorio_trabajo="\""+directorio_trabajo+"\"";
  String Ruta_Haskell=unidad_de_union->Dame_Interfaz_Haskell()->Dame_Ruta_Haskell();
  String Ruta_Codigo_Haskell=unidad_de_union->Dame_Interfaz_Haskell()->Dame_Ruta_Codigo_Haskell();
  String Orden="mutaCurva";
  Bloque Bloque_A_Manipular=Musica_Genaro->Dame_Pista(Fila_Pulsada)->Dame_Bloque(Columna_Pulsada);
  String curva=Bloque_A_Manipular.Curva_Melodica;
  String num_mut=IntToStr(Barra_Mutaciones_Curva->Position);
  String salto_max=IntToStr(Barra_Salto_Maximo_Mutaciones->Position);
  int valor_spawn=spawnl(P_WAIT,Ruta_Haskell.c_str(),Ruta_Haskell.c_str(),Ruta_Codigo_Haskell.c_str(),directorio_trabajo.c_str(),Orden.c_str(),num_mut.c_str(),salto_max.c_str(),curva.c_str(),curva.c_str(),NULL);
  if (valor_spawn==-1){ShowMessage("Error creando el music de melodia");}

}
//---------------------------------------------------------------------------

void __fastcall TForm1::Cargar1Click(TObject *Sender)
{
if(Cargar_Genaro->Execute()==false)
{
  ShowMessage("Operación cancelada por el usuario");return;
}
String fichero_genaro=Cargar_Genaro->FileName;

if (Inicializado)
{
  Musica_Genaro->Limpia();
  Musica_Genaro->Cargar(fichero_genaro);
  Numero_Filas_A_Dibujar=Musica_Genaro->Dame_Numero_Pistas();
  if (Numero_Filas_A_Dibujar>0)
  {
    Numero_Bloques=Musica_Genaro->Dame_Pista(0)->Dame_Numero_Bloques();
  }
  else
  {
    Numero_Bloques=0;
  }
  Dibuja_Cancion();
//  TBrushStyle estilo_temp=this->Canvas->Brush->Style;
  this->Canvas->Brush->Color=clGray;
  this->Canvas->FillRect(Rect(X_Inicial,Y_Inicial,X_Final,Y_Final));
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
  Musica_Genaro->Cargar(fichero_genaro);
  Numero_Filas_A_Dibujar=Musica_Genaro->Dame_Numero_Pistas();
  if (Numero_Filas_A_Dibujar>0)
  {
    Numero_Bloques=Musica_Genaro->Dame_Pista(0)->Dame_Numero_Bloques();
  }
  else
  {
    Numero_Bloques=0;
  }
  Dibuja_Cancion();
}

}
//---------------------------------------------------------------------------





void __fastcall TForm1::TrackBar2Change(TObject *Sender)
{
Label43->Caption=IntToStr(TrackBar2->Position);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::TrackBar3Change(TObject *Sender)
{
Label45->Caption=IntToStr(TrackBar3->Position);  
}
//---------------------------------------------------------------------------

void __fastcall TForm1::TrackBar1Change(TObject *Sender)
{
Label40->Caption=IntToStr(TrackBar1->Position);  
}
//---------------------------------------------------------------------------

void __fastcall TForm1::TrackBar4Change(TObject *Sender)
{
Label47->Caption=IntToStr(TrackBar4->Position);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::TrackBar5Change(TObject *Sender)
{
Label49->Caption=IntToStr(TrackBar5->Position);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Radio_Copiar_MelodiaClick(TObject *Sender)
{
if (Radio_Copiar_Melodia->Checked==true)
{
ShowMessage("Elige subBloque para copiar melodía");
Eligiendo_Subbloque=true;
}
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button2Click(TObject *Sender)
{
Bloque Bloque_A_Manipular=Musica_Genaro->Dame_Pista(Fila_Pulsada)->Dame_Bloque(Columna_Pulsada);
if(!Bloque_A_Manipular.Vacio)
{
//1- abrir el midi "musica_genara.mid" si da error, salimos
String midi=Bloque_A_Manipular.Tipo_Music;
int esta=FileOpen(midi.c_str(), fmOpenRead);
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
String Ruta_Midi=midi;
//3- invocar la reproducción y quedarnos con el número de proceso
Ejecuta_Timidity_Reproduccion(timi_exe, Amplificacion_Volumen, EFchorus,EFreverb,EFdelay,frecuency, Ruta_Patch_File,Ruta_Midi);

}  
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Radio_Armonizar_MelodiaClick(TObject *Sender)
{
if (Radio_Armonizar_Melodia->Checked==true)
{
ShowMessage("Elige Pista para armonizar melodía");
Eligiendo_PistaArmonizar=true;
}
}
//---------------------------------------------------------------------------
void TForm1::Crea_Progresion_Armonizando(String midi_origen,String Prog_destino)
{
String temp1=FormOpcionesArmonizacion->Edit1->Text+" ";
int t1=Procesa_Num_Natural(temp1);
String temp2=FormOpcionesArmonizacion->Edit2->Text+" ";
int t2=Procesa_Num_Natural(temp2);
String temp3=FormOpcionesArmonizacion->Edit4->Text+" ";
int t3=Procesa_Num_Natural(temp3);
String temp4=FormOpcionesArmonizacion->Edit3->Text+" ";
int t4=Procesa_Num_Natural(temp4);
if ((t1==-1)||(t2==-1)||(t1==-1)||(t2==-1))
{ShowMessage("Duración de la nota del bajo no válida");return;}
//ahora hacemos la llamada

  Bloque Bloque_A_Manipular=Musica_Genaro->Dame_Pista(Fila_Pulsada)->Dame_Bloque(Columna_Pulsada);
  char work_dir[255];
  getcwd(work_dir, 255);
  String directorio_trabajo=work_dir;
  directorio_trabajo="\""+directorio_trabajo+"\"";
  String Ruta_Haskell=unidad_de_union->Dame_Interfaz_Haskell()->Dame_Ruta_Haskell();
  String Ruta_Codigo_Haskell=unidad_de_union->Dame_Interfaz_Haskell()->Dame_Ruta_Codigo_Haskell();
  String Orden="armonizaMelodia";//
  String Pal_Parametros="parametros";

  String Modo_Acord=FormOpcionesArmonizacion->ComboBox2->Text;
  String Tipo_Notas_Principales=FormOpcionesArmonizacion->ComboBox1->Text;
  String Arm_min_Num=IntToStr(t1);
  String Arm_min_Den=IntToStr(t2);
  String Tipo_Asign=FormOpcionesArmonizacion->ComboBox3->Text;
  String Dur_Max_Num=IntToStr(t3);
  String Dur_Max_Den=IntToStr(t4);
  String Pal_Ruta_Melodia="ruta_melodia_midi";
  //rta del midi
  String Pal_Ruta_Dest="ruta_prog_dest";
  //destino
  int valor_spawn=spawnl(P_WAIT,Ruta_Haskell.c_str(),Ruta_Haskell.c_str(),Ruta_Codigo_Haskell.c_str(),directorio_trabajo.c_str(),Orden.c_str(),Pal_Parametros.c_str(),Modo_Acord.c_str(),Tipo_Notas_Principales.c_str(),Arm_min_Num.c_str(),Arm_min_Den.c_str(),Tipo_Asign.c_str(),Dur_Max_Num.c_str(),Dur_Max_Den.c_str(),Pal_Ruta_Melodia.c_str(),midi_origen.c_str(),Pal_Ruta_Dest.c_str(),Prog_destino.c_str(),NULL);
  if (valor_spawn==-1)
  {ShowMessage("Error ejecutando el runhugs de haskell.");}
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button5Click(TObject *Sender)
{
FormOpcionesArmonizacion->Show();
}
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
void TForm1::Inicializa_Patrones_Bateria()
{
  DIR *dir;
  struct dirent *ent;
  if ((dir = opendir("PatronesBateria")) == NULL)
  {
    ShowMessage("Error leyendo directorio");
  }
  else
  {
    Combo_Bateria->Items->Clear();
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
      Combo_Bateria->Items->Add(ent->d_name);
      Combo_Bateria->Text=ent->d_name;
      }
    }

  }
}
void __fastcall TForm1::EditordeBateria1Click(TObject *Sender)
{
  String Editor_Pianola=".\\Codigo\\C\\BEditor.exe";
  int valor_spawn=spawnl(P_WAIT,Editor_Pianola.c_str(),Editor_Pianola.c_str(),NULL);
  if (valor_spawn==-1)
  {ShowMessage("Error ejecutando el editor de bateria.");}
  //refrescamos los lo que sea
  Inicializa_Patrones_Bateria();

}
//---------------------------------------------------------------------------

