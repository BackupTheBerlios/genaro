//---------------------------------------------------------------------------

#ifndef Form_Editar_ProgresionH
#define Form_Editar_ProgresionH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <Grids.hpp>
#include <Dialogs.hpp>
//---------------------------------------------------------------------------
class TForm3 : public TForm
{
__published:	// IDE-managed Components
  TStringGrid *StringGrid1;
  TComboBox *Lista_Grados;
  TLabel *Label1;
  TButton *Button1;
  TButton *Button2;
  TButton *Button3;
  TButton *Button4;
  TStringGrid *Grid_Grados;
  TComboBox *Lista_Matricula;
  TButton *Button5;
  TButton *Button6;
  TEdit *Edit_Numerador;
  TLabel *Label2;
  TEdit *Edit_Denominador;
  TLabel *Label3;
  TLabel *Label4;
  TButton *Button7;
  TSaveDialog *Salvar_Progresion;
  void __fastcall Button2Click(TObject *Sender);
  void __fastcall Button1Click(TObject *Sender);
  void __fastcall Button4Click(TObject *Sender);
  void __fastcall Button3Click(TObject *Sender);
  void __fastcall Button5Click(TObject *Sender);
  void __fastcall Button6Click(TObject *Sender);
  void __fastcall Button7Click(TObject *Sender);
private:	// User declarations
public:		// User declarations
    void Inicializa_Lista_Matriculas(String gradito);
  __fastcall TForm3(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm3 *Form3;
//---------------------------------------------------------------------------
#endif
