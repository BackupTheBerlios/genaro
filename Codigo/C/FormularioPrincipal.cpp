//---------------------------------------------------------------------------

#include <vcl.h>
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
void __fastcall TForm1::Button7Click(TObject *Sender)
{
Inicializacion(OpenDialog,EditFicheroProlog,EditRelacionProlog);
//prueba();
}
//---------------------------------------------------------------------------

