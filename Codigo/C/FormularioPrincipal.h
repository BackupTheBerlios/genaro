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
#include <ComCtrls.hpp>
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
  TButton *Boton_Componer;
  TOpenDialog *OpenDialog;
  TLabel *Label1;
  TLabel *Label2;
  TTrackBar *Barra_Numero_Acordes;
  TTrackBar *Barra_Numero_Mutaciones;
  TTrackBar *Barra_Numero_Repeticiones;
  TLabel *Label3;
  TComboBox *Selector_Patron_Ritmico;
  TLabel *Etiqueta_Numero_Acordes;
  TLabel *Etiqueta_Numero_Mutaciones;
  TLabel *Etiqueta_Numero_Repeticiones;
  TLabel *Label4;
  void __fastcall Boton_ComponerClick(TObject *Sender);
  void __fastcall FormCreate(TObject *Sender);
  void __fastcall Barra_Numero_AcordesChange(TObject *Sender);
  void __fastcall Barra_Numero_MutacionesChange(TObject *Sender);
  void __fastcall Barra_Numero_RepeticionesChange(TObject *Sender);
private:	// User declarations
  Unidad_Nexo* unidad_de_union;
public:		// User declarations
  void Inicializa_Patrones_Ritmicos();
  __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
