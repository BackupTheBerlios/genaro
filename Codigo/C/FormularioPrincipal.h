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
  TMenuItem *EditordePianola1;
  TMenuItem *Reproduccin1;
  void __fastcall FormCreate(TObject *Sender);
  void __fastcall Barra_Numero_AcordesChange(TObject *Sender);
  void __fastcall Barra_Numero_MutacionesChange(TObject *Sender);
  void __fastcall Barra_Numero_RepeticionesChange(TObject *Sender);
  void __fastcall Salir1Click(TObject *Sender);
  void __fastcall EditordePianola1Click(TObject *Sender);
  void __fastcall Reproduccin1Click(TObject *Sender);
  void __fastcall Button3Click(TObject *Sender);
  void __fastcall Button1Click(TObject *Sender);
  void __fastcall Button4Click(TObject *Sender);
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
