//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "Form_Editar_Progresion.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm3 *Form3;
//---------------------------------------------------------------------------
__fastcall TForm3::TForm3(TComponent* Owner)
  : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TForm3::Button2Click(TObject *Sender)
{
Grid_Grados->ColCount=1;
Grid_Grados->Cols[Grid_Grados->ColCount-1]->Clear();
Lista_Matricula->Enabled=false;
Button1->Enabled=true;
}
//---------------------------------------------------------------------------
void __fastcall TForm3::Button1Click(TObject *Sender)
{
if ((Lista_Grados->Text=="v7")||(Lista_Grados->Text=="iim7"))
{
  Grid_Grados->Cols[Grid_Grados->ColCount-1]->Clear();
  Grid_Grados->Cols[Grid_Grados->ColCount-1]->Add(Lista_Grados->Text);
  Grid_Grados->ColCount++;
  Grid_Grados->Cols[Grid_Grados->ColCount-1]->Clear();
}
else
{
  Grid_Grados->Cols[Grid_Grados->ColCount-1]->Clear();
  Grid_Grados->Cols[Grid_Grados->ColCount-1]->Add(Lista_Grados->Text);
  Button1->Enabled=false;
  //inicializamos lista2, y enableamos
  Inicializa_Lista_Matriculas(Grid_Grados->Cols[0]->Strings[0]);
  Lista_Matricula->Enabled=true;
}
}
//---------------------------------------------------------------------------
void __fastcall TForm3::Button4Click(TObject *Sender)
{

String temp=Grid_Grados->Cols[Grid_Grados->ColCount-1]->Strings[0];
if ((temp=="i")||(temp=="ii")||(temp=="iii")||(temp=="iv")||(temp=="v")||(temp=="vi")||(temp=="vii")||(temp=="bii")||(temp=="biii")||(temp=="bv")||(temp=="auv")||(temp=="bvii"))
{
  Grid_Grados->Cols[Grid_Grados->ColCount-1]->Clear();
  Button1->Enabled=true;
  Lista_Matricula->Enabled=false;
}
else
{
  Grid_Grados->ColCount--;
  Grid_Grados->Cols[Grid_Grados->ColCount-1]->Clear();
}
}
//---------------------------------------------------------------------------
void TForm3::Inicializa_Lista_Matriculas(String gradito)
{
//borrar lista
Lista_Matricula->Items->Clear();
if (gradito=="v7")
{
  Lista_Matricula->Items->Add("7");
}
if (gradito=="iim7")
{
  Lista_Matricula->Items->Add("maj7");
}
if ((gradito!="iim7")&&(gradito!="v7"))
{
    Lista_Matricula->Items->Add("dis7");
    if ((gradito=="i")||(gradito=="iv"))
    {
      Lista_Matricula->Items->Add("maj7");
    }
    if ((gradito=="ii")||(gradito=="iii")||(gradito=="vi"))
    {
      Lista_Matricula->Items->Add("m7");
    }
    if (gradito=="v")
    {
      Lista_Matricula->Items->Add("7");
    }
    if (gradito=="vii")
    {
      Lista_Matricula->Items->Add("m7b5");
    }
}
Lista_Matricula->Text=Lista_Matricula->Items->Strings[0];
}
