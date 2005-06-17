//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "Opciones_Armonizacion.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TFormOpcionesArmonizacion *FormOpcionesArmonizacion;
//---------------------------------------------------------------------------
__fastcall TFormOpcionesArmonizacion::TFormOpcionesArmonizacion(TComponent* Owner)
  : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TFormOpcionesArmonizacion::ComboBox3Change(TObject *Sender)
{
if(ComboBox3->Text=="MasLargoPosible")
{
Label7->Enabled=true;
Edit4->Enabled=true;
Label6->Enabled=true;
Edit3->Enabled=true;
}
else
{
Label7->Enabled=false;
Edit4->Enabled=false;
Label6->Enabled=false;
Edit3->Enabled=false;
}

}
//---------------------------------------------------------------------------
