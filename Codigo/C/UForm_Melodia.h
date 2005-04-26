//---------------------------------------------------------------------------

#ifndef UForm_MelodiaH
#define UForm_MelodiaH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ExtCtrls.hpp>
//---------------------------------------------------------------------------
class TForm_Melodia : public TForm
{
__published:	// IDE-managed Components
  TPanel *Panel_Curva_Melodia;
  TRadioButton *Radio_Aniade_Puntos;
  TRadioButton *Radio_Mover_Puntos;
  TButton *Button1;
  TRadioButton *Radio_Eliminar_Puntos;
  void __fastcall Boton_Aceptar_MelodiaClick(TObject *Sender);
  void __fastcall FormClick(TObject *Sender);
  void __fastcall FormPaint(TObject *Sender);
private:	// User declarations
  int X_Inicial,Y_Inicial,X_Final,Y_Final;
  int Ancho,Alto;
  int Puntos[100];
public:		// User declarations
  void Dibuja_Curva();
  void Lee_Puntos();
  __fastcall TForm_Melodia(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm_Melodia *Form_Melodia;
//---------------------------------------------------------------------------
#endif
