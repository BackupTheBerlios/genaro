//---------------------------------------------------------------------------

#ifndef Opciones_ArmonizacionH
#define Opciones_ArmonizacionH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
//---------------------------------------------------------------------------
class TFormOpcionesArmonizacion : public TForm
{
__published:	// IDE-managed Components
  TComboBox *ComboBox1;
  TLabel *Label1;
  TEdit *Edit2;
  TEdit *Edit1;
  TLabel *Label2;
  TLabel *Label3;
  TComboBox *ComboBox2;
  TLabel *Label4;
  TLabel *Label5;
  TComboBox *ComboBox3;
  TEdit *Edit3;
  TEdit *Edit4;
  TLabel *Label6;
  TLabel *Label7;
  void __fastcall ComboBox3Change(TObject *Sender);
private:	// User declarations
public:		// User declarations
  __fastcall TFormOpcionesArmonizacion(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TFormOpcionesArmonizacion *FormOpcionesArmonizacion;
//---------------------------------------------------------------------------
#endif
