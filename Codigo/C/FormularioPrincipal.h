//---------------------------------------------------------------------------

#ifndef FormularioPrincipalH
#define FormularioPrincipalH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ExtCtrls.hpp>
#include <Menus.hpp>
#include "Unidad_Nexo.h"
#include <Dialogs.hpp>
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
  TPanel *Panel1;
  TScrollBar *ScrollBar1;
  TScrollBar *ScrollBar2;
  TButton *Button2;
  TButton *Button3;
  TButton *Button5;
  TButton *Button1;
  TButton *Button4;
  TButton *Button6;
  TMainMenu *MainMenu1;
  TMenuItem *Archivo1;
  TMenuItem *Edicin1;
  TMenuItem *Insertar1;
  TMenuItem *Salir1;
  TEdit *EditFicheroProlog;
  TEdit *EditRelacionProlog;
  TButton *Button7;
  TOpenDialog *OpenDialog;
  void __fastcall Button7Click(TObject *Sender);
private:	// User declarations
public:		// User declarations
  __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
