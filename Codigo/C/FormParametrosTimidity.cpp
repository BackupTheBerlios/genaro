//---------------------------------------------------------------------------

#include <vcl.h>
#include <dirent.h>
#include <dir.h>
#pragma hdrstop

#include "FormParametrosTimidity.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm2 *Form2;
//---------------------------------------------------------------------------
__fastcall TForm2::TForm2(TComponent* Owner)
  : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TForm2::Barra_AmplificacionChange(TObject *Sender)
{
Etiqueta_Amplificacion->Caption=IntToStr(Barra_Amplificacion->Position)+'%';
}
//---------------------------------------------------------------------------



void __fastcall TForm2::EFchorus0Click(TObject *Sender)
{
if (EFchorus0->Checked==true)
{
  Ajustar_Chorus_Check->Enabled=false;
  Ajustar_Chorus_Barra->Enabled=false;
}
else
{
  Ajustar_Chorus_Check->Enabled=true;
  Ajustar_Chorus_Barra->Enabled=true;
}
}
//---------------------------------------------------------------------------

void __fastcall TForm2::EFchorus1Click(TObject *Sender)
{
if (EFchorus0->Checked==true)
{
  Ajustar_Chorus_Check->Enabled=false;
  Ajustar_Chorus_Barra->Enabled=false;
}
else
{
  Ajustar_Chorus_Check->Enabled=true;
  Ajustar_Chorus_Barra->Enabled=true;
}  
}
//---------------------------------------------------------------------------

void __fastcall TForm2::EFchorus2Click(TObject *Sender)
{
if (EFchorus0->Checked==true)
{
  Ajustar_Chorus_Check->Enabled=false;
  Ajustar_Chorus_Barra->Enabled=false;
}
else
{
  Ajustar_Chorus_Check->Enabled=true;
  Ajustar_Chorus_Barra->Enabled=true;
}  
}
//---------------------------------------------------------------------------

void __fastcall TForm2::Ajustar_Chorus_BarraChange(TObject *Sender)
{
  Chorus_Level_Label->Caption=IntToStr(Ajustar_Chorus_Barra->Position);
}
//---------------------------------------------------------------------------

void __fastcall TForm2::Ajustar_Chorus_CheckClick(TObject *Sender)
{
if (Ajustar_Chorus_Check->Checked==true)
{
  Ajustar_Chorus_Barra->Enabled=false;
}
else
{
  Ajustar_Chorus_Barra->Enabled=true;
}
}
//---------------------------------------------------------------------------


void __fastcall TForm2::Boton_Valores_Por_DefectoClick(TObject *Sender)
{
Barra_Amplificacion->Position=90;
Etiqueta_Amplificacion->Caption="90%";
EFchorus2->Checked=true;
Ajustar_Chorus_Check->Checked=false;
Ajustar_Chorus_Check->Enabled=true;
Ajustar_Chorus_Barra->Position=0;
Ajustar_Chorus_Barra->Enabled=false;
Chorus_Level_Label->Caption="0";
EFreverb1->Checked=true;
Ajustar_Reverb_Check->Checked=true;
Ajustar_Reverb_Check->Enabled=true;
Ajustar_Reverb_Barra->Position=60;
Ajustar_Reverb_Barra->Enabled=true;
Ajustar_Reverb_Label->Caption="60";
Barra_Frecuencia->Position=3;
Label_Frecuencia->Caption="48000 Hz";
Delay_Effects_Check->Checked=true;
Delay_Effects_Barra->Enabled=true;
Delay_Effects_Barra->Position=0;
Selector_Patches->Text="No aplicar Patches";
}
//---------------------------------------------------------------------------

void __fastcall TForm2::EFreverb0Click(TObject *Sender)
{
if (EFreverb1->Checked==true)
{
  Ajustar_Reverb_Check->Enabled=true;
  Ajustar_Reverb_Barra->Enabled=true;
}
else
{
  Ajustar_Reverb_Check->Enabled=false;
  Ajustar_Reverb_Barra->Enabled=false;
}
}
//---------------------------------------------------------------------------

void __fastcall TForm2::EFreverb1Click(TObject *Sender)
{
if (EFreverb1->Checked==true)
{
  Ajustar_Reverb_Check->Enabled=true;
  Ajustar_Reverb_Barra->Enabled=true;
}
else
{
  Ajustar_Reverb_Check->Enabled=false;
  Ajustar_Reverb_Barra->Enabled=false;
}  
}
//---------------------------------------------------------------------------

void __fastcall TForm2::EFreverb2Click(TObject *Sender)
{
if (EFreverb1->Checked==true)
{
  Ajustar_Reverb_Check->Enabled=true;
  Ajustar_Reverb_Barra->Enabled=true;
}
else
{
  Ajustar_Reverb_Check->Enabled=false;
  Ajustar_Reverb_Barra->Enabled=false;
}  
}
//---------------------------------------------------------------------------

void __fastcall TForm2::Ajustar_Reverb_CheckClick(TObject *Sender)
{
if (Ajustar_Reverb_Check->Checked==false)
{
  Ajustar_Reverb_Barra->Enabled=false;
}
else
{
  Ajustar_Reverb_Barra->Enabled=true;
}
}
//---------------------------------------------------------------------------

void __fastcall TForm2::Ajustar_Reverb_BarraChange(TObject *Sender)
{
Ajustar_Reverb_Label->Caption=IntToStr(Ajustar_Reverb_Barra->Position);  
}
//---------------------------------------------------------------------------

void __fastcall TForm2::Barra_FrecuenciaChange(TObject *Sender)
{
switch (Barra_Frecuencia->Position)
{
case 0:{Label_Frecuencia->Caption="11025 Hz";break;}
case 1:{Label_Frecuencia->Caption="22050 Hz";break;}
case 2:{Label_Frecuencia->Caption="44100 Hz";break;}
case 3:{Label_Frecuencia->Caption="44800 Hz";break;}
}
}
//---------------------------------------------------------------------------

void __fastcall TForm2::Delay_Effects_CheckClick(TObject *Sender)
{
if (Delay_Effects_Check->Checked==false)
{
  Delay_Effects_Barra->Enabled=false;
}
else
{
  Delay_Effects_Barra->Enabled=true;
}
}
//---------------------------------------------------------------------------
void TForm2::Inicializa_Patches()
{
  DIR *dir;
  struct dirent *ent;
  if ((dir = opendir(".\\Timidity\\Patches")) == NULL)
  {
    ShowMessage("Error leyendo directorio");
  }
  else
  {
    Selector_Patches->Items->Clear();
    Selector_Patches->Items->Add("No aplicar Patches");
    Selector_Patches->Text="No aplicar Patches";
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
      else if (((ent->d_name[tamanio-1]=='t')||(ent->d_name[tamanio-1]=='T'))&&((ent->d_name[tamanio-2]=='a')||(ent->d_name[tamanio-2]=='A'))&&((ent->d_name[tamanio-3]=='p')||(ent->d_name[tamanio-3]=='P')))
      {
      //2- añade a la lista de patrones rítmicos.
      Selector_Patches->Items->Add(ent->d_name);
      }
    }
  }
}
//---------------------------------------------------------------------------
void __fastcall TForm2::FormCreate(TObject *Sender)
{
  Inicializa_Patches();
}
//---------------------------------------------------------------------------
String TForm2::Dame_EFchorus()
{
String salida;
if (EFchorus0->Checked==true)
{
  salida="0";
}
if (EFchorus1->Checked==true)
{
  salida="1";
  if (Ajustar_Chorus_Check->Checked==true)
  {
    salida+=","+IntToStr(Ajustar_Chorus_Barra->Position);
  }
}
if (EFchorus2->Checked==true)
{
  salida="2";
  if (Ajustar_Chorus_Check->Checked==true)
  {
    salida+=","+IntToStr(Ajustar_Chorus_Barra->Position);
  }
}
return salida;
}
//---------------------------------------------------------------------------
String TForm2::Dame_EFreverb()
{
String salida;
if (EFreverb0->Checked==true)
{
  salida="0";
}
if (EFreverb1->Checked==true)
{
  salida="1";
  if (Ajustar_Reverb_Check->Checked==true)
  {
    salida+=","+IntToStr(Ajustar_Reverb_Barra->Position);
  }
}
if (EFreverb2->Checked==true)
{
  salida="2";
}
return salida;
}
//---------------------------------------------------------------------------
String TForm2::Dame_EFdelay()
{
String salida;
if (Delay_Effects_Check->Checked==true)
{
  salida="0";
}
else
{
  switch (Delay_Effects_Barra->Position)
  {
    case 0: {salida="r";break;}
    case 1: {salida="b";break;}
    case 2: {salida="l";break;}
  }
}
return salida;
}
//---------------------------------------------------------------------------
int TForm2::Dame_Frecuency()
{
int salida=0;
switch (Barra_Frecuencia->Position)
{
case 0:{salida=11025;break;}
case 1:{salida=22050;break;}
case 2:{salida=44100;break;}
case 3:{salida=48000;break;}
}
return salida;
}
//---------------------------------------------------------------------------
String TForm2::Dame_Ruta_Patch_File()
{
String salida;
if (Selector_Patches->Text=="No aplicar Patches"){salida="none";}
else
{
  salida=".\\Timidity\\Patches\\"+Selector_Patches->Text;
}
return salida;
}
//---------------------------------------------------------------------------
void __fastcall TForm2::Button2Click(TObject *Sender)
{
this->Hide();
}
//---------------------------------------------------------------------------

