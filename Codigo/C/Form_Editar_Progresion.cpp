//---------------------------------------------------------------------------

#include <vcl.h>
#include <fstream.h>
#pragma hdrstop

#include "Form_Editar_Progresion.h"
#include "Tipos_Estructura.h"
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
Label3->Enabled=false;
Lista_Grados->Enabled=true;
Grid_Grados->Enabled=true;
Button1->Enabled=true;
Button4->Enabled=true;
Label1->Enabled=true;
Edit_Numerador->Enabled=true;
Label2->Enabled=true;
Label4->Enabled=true;
Edit_Denominador->Enabled=true;
Button3->Enabled=false;
Button5->Enabled=false;
Button6->Enabled=false;
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
  //inicializamos lista2, y enableamos
  Inicializa_Lista_Matriculas(Grid_Grados->Cols[0]->Strings[0]);
  Lista_Matricula->Enabled=true;
  Label3->Enabled=true;
  Lista_Grados->Enabled=false;
  Grid_Grados->Enabled=true;
  Button1->Enabled=false;
  Button4->Enabled=true;
  Label1->Enabled=false;
  Edit_Numerador->Enabled=true;
  Label2->Enabled=true;
  Label4->Enabled=true;
  Edit_Denominador->Enabled=true;
  Button3->Enabled=true;
  Button5->Enabled=true;
  Button6->Enabled=true;
}
}
//---------------------------------------------------------------------------
void __fastcall TForm3::Button4Click(TObject *Sender)
{

String temp=Grid_Grados->Cols[Grid_Grados->ColCount-1]->Strings[0];
if ((temp=="i")||(temp=="ii")||(temp=="iii")||(temp=="iv")||(temp=="v")||(temp=="vi")||(temp=="vii")||(temp=="bii")||(temp=="biii")||(temp=="bv")||(temp=="auv")||(temp=="bvii"))
{
  Grid_Grados->Cols[Grid_Grados->ColCount-1]->Clear();
  Lista_Matricula->Enabled=false;
  Label3->Enabled=false;
  Lista_Grados->Enabled=true;
  Grid_Grados->Enabled=true;
  Button1->Enabled=true;
  Button4->Enabled=true;
  Label1->Enabled=true;
  Edit_Numerador->Enabled=true;
  Label2->Enabled=true;
  Label4->Enabled=true;
  Edit_Denominador->Enabled=true;
  Button3->Enabled=false;
  Button5->Enabled=false;
  Button6->Enabled=false;
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
//---------------------------------------------------------------------------
void __fastcall TForm3::Button3Click(TObject *Sender)
{
String Cadena_Acorde="";
for (int i=0;i<Grid_Grados->ColCount;i++)
{
  Cadena_Acorde+=Grid_Grados->Cols[i]->Strings[0]+" ";
}
Cadena_Acorde+=Lista_Matricula->Text+" ";
int numerador,denominador;
String temp;
temp=Edit_Numerador->Text+" ";
numerador=Procesa_Num_Natural(temp);
temp=Edit_Denominador->Text+" ";
denominador=Procesa_Num_Natural(temp);
if ((numerador==-1)||(denominador==-1))
{ShowMessage("La división no es correcta");return;}
Cadena_Acorde+=Edit_Numerador->Text+" / "+Edit_Denominador->Text;
StringGrid1->Cols[StringGrid1->Col]->Strings[0]=Cadena_Acorde;
}
//---------------------------------------------------------------------------


void __fastcall TForm3::Button5Click(TObject *Sender)
{
String Cadena_Acorde="";
for (int i=0;i<Grid_Grados->ColCount;i++)
{
  Cadena_Acorde+=Grid_Grados->Cols[i]->Strings[0]+" ";
}
Cadena_Acorde+=Lista_Matricula->Text+" ";
int numerador,denominador;
String temp;
temp=Edit_Numerador->Text+" ";
numerador=Procesa_Num_Natural(temp);
temp=Edit_Denominador->Text+" ";
denominador=Procesa_Num_Natural(temp);
if ((numerador==-1)||(denominador==-1))
{ShowMessage("La división no es correcta");return;}
Cadena_Acorde+=Edit_Numerador->Text+" / "+Edit_Denominador->Text;
StringGrid1->ColCount++;
//movemos los strings a la derecha
for (int i=1;i<StringGrid1->ColCount-StringGrid1->Col;i++)
{
  StringGrid1->Cols[StringGrid1->ColCount-i]->Strings[0]=StringGrid1->Cols[StringGrid1->ColCount-1-i]->Strings[0];
}
StringGrid1->Cols[StringGrid1->Col+1]->Strings[0]=Cadena_Acorde;  
}
//---------------------------------------------------------------------------

void __fastcall TForm3::Button6Click(TObject *Sender)
{
String Cadena_Acorde="";
for (int i=0;i<Grid_Grados->ColCount;i++)
{
  Cadena_Acorde+=Grid_Grados->Cols[i]->Strings[0]+" ";
}
Cadena_Acorde+=Lista_Matricula->Text+" ";
int numerador,denominador;
String temp;
temp=Edit_Numerador->Text+" ";
numerador=Procesa_Num_Natural(temp);
temp=Edit_Denominador->Text+" ";
denominador=Procesa_Num_Natural(temp);
if ((numerador==-1)||(denominador==-1))
{ShowMessage("La división no es correcta");return;}
Cadena_Acorde+=Edit_Numerador->Text+" / "+Edit_Denominador->Text;
StringGrid1->ColCount++;
//movemos los strings a la derecha
for (int i=1;i<StringGrid1->ColCount-StringGrid1->Col;i++)
{
  StringGrid1->Cols[StringGrid1->ColCount-i]->Strings[0]=StringGrid1->Cols[StringGrid1->ColCount-1-i]->Strings[0];
}
StringGrid1->Cols[StringGrid1->Col]->Strings[0]=Cadena_Acorde;
}
//---------------------------------------------------------------------------

void __fastcall TForm3::Button7Click(TObject *Sender)
{
ofstream salida_progresion;

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
if ((temp>=5)&&(fichero[temp]!='g')&&(fichero[temp]!='o')&&(fichero[temp-2]!='r')&&(fichero[temp-3]!='p')&&(fichero[temp-4]!='.'))
{fichero+=".prog";}

salida_progresion.open(fichero.c_str());
salida_progresion<<"progresion([ ";
String Total;
String Token;
for (int i=0;i<StringGrid1->ColCount;i++)
{
if (i!=0){salida_progresion<<", ";}
salida_progresion<<"(";
  Total=StringGrid1->Cols[i]->Strings[0];
  //ahora habría que ir mirando para pasarlo a lo que sea
  salida_progresion<<"cifrado(";
  //guardar grado
  salida_progresion<<"grado(";
  Token=Dame_Token(Total);
  while ((Token=="v7")||(Token=="iim7"))
  {
    for (int t=0;t<Token.Length();t++)
    {
      salida_progresion<<Token[t+1];
    }
    salida_progresion<<"/";
    Token=Dame_Token(Total);
  }
  for (int t=0;t<Token.Length();t++)
  {
    salida_progresion<<Token[t+1];
  }
  salida_progresion<<"), ";
  //----tenemos que conseguirlo leyendo la cadena
  //guardar matrícula
  salida_progresion<<"matricula(";
  Token=Dame_Token(Total);
  for (int t=0;t<Token.Length();t++)
  {
    salida_progresion<<Token[t+1];
  }
  salida_progresion<<")";
  //---- tenemos que coger el siguiente token
  salida_progresion<<")";
  salida_progresion<<", ";
  //guardar figura
  salida_progresion<<"figura(";
  Token=Dame_Token(Total);
  for (int t=0;t<Token.Length();t++)
  {
    salida_progresion<<Token[t+1];
  }
  salida_progresion<<", ";
  Token=Dame_Token(Total);
  Token=Dame_Token(Total);
  for (int t=0;t<Token.Length();t++)
  {
    salida_progresion<<Token[t+1];
  }
  salida_progresion<<")";
  //---- tenemos que coger los 3 siguientes tokens y transcribirlos
salida_progresion<<")";
}
salida_progresion<<"]).";
salida_progresion.close();
}
//---------------------------------------------------------------------------


