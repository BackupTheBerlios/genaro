//---------------------------------------------------------------------------

#include <vcl.h>
#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <fstream.h>
#pragma hdrstop

#include "FormularioPrincipal.h"
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
void __fastcall TForm1::Boton_ComponerClick(TObject *Sender)
{
  String Ruta_codigo_haskell;
  String Ruta_haskell;
  String Ruta_prolog;
  ifstream fichero_conf;
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
        OpenDialog->Execute();
        Ruta_prolog=OpenDialog->FileName;
        int tamanio=Ruta_prolog.Length();
        fichero_guardar.write((char*)&tamanio,sizeof(int));
        for (int i=0;i<tamanio;i++)
        {
          fichero_guardar.write((char*)&Ruta_prolog[i+1],sizeof(char));
        }
        Ruta_prolog="..\\Prolog";
        Ruta_haskell="..\\Haskell\\runhugs.exe";
        Ruta_codigo_haskell = "..\\Haskell\\main.lhs";
        fichero_conf.close();
      }
      catch(...){}
  }
unidad_de_union->Inicializacion(Ruta_prolog,Ruta_haskell,Ruta_codigo_haskell);

//SI NO HAY NINGUNO SELECCIONADO EN PATRONES RITMICOS COGEMOS UNO

unidad_de_union->Componer(IntToStr(Barra_Numero_Acordes->Position),IntToStr(Barra_Numero_Mutaciones->Position),Selector_Patron_Ritmico->Text,IntToStr(Barra_Numero_Repeticiones->Position));

}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormCreate(TObject *Sender)
{
unidad_de_union=new Unidad_Nexo();
Inicializa_Patrones_Ritmicos();
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

