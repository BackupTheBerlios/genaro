//---------------------------------------------------------------------------

#ifndef FormParametrosTimidityH
#define FormParametrosTimidityH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
#include <ExtCtrls.hpp>
//---------------------------------------------------------------------------
class TForm2 : public TForm
{
__published:	// IDE-managed Components
  TLabel *Label1;
  TTrackBar *Barra_Amplificacion;
  TLabel *Etiqueta_Amplificacion;
  TRadioGroup *RadioGroup1;
  TRadioButton *EFchorus0;
  TRadioButton *EFchorus1;
  TRadioButton *EFchorus2;
  TTrackBar *Ajustar_Chorus_Barra;
  TCheckBox *Ajustar_Chorus_Check;
  TTrackBar *Ajustar_Reverb_Barra;
  TCheckBox *Ajustar_Reverb_Check;
  TComboBox *Selector_Patches;
  TTrackBar *Barra_Frecuencia;
  TLabel *Label2;
  TLabel *Label3;
  TLabel *Chorus_Level_Label;
  TLabel *Ajustar_Reverb_Label;
  TLabel *Label_Frecuencia;
  TTrackBar *Delay_Effects_Barra;
  TLabel *Label7;
  TLabel *Label8;
  TLabel *Label9;
  TCheckBox *Delay_Effects_Check;
  TGroupBox *GroupBox1;
  TRadioButton *EFreverb0;
  TRadioButton *EFreverb1;
  TRadioButton *EFreverb2;
  TButton *Boton_Valores_Por_Defecto;
  TButton *Button2;
  void __fastcall Barra_AmplificacionChange(TObject *Sender);
  void __fastcall EFchorus0Click(TObject *Sender);
  void __fastcall EFchorus1Click(TObject *Sender);
  void __fastcall EFchorus2Click(TObject *Sender);
  void __fastcall Ajustar_Chorus_BarraChange(TObject *Sender);
  void __fastcall Ajustar_Chorus_CheckClick(TObject *Sender);
  void __fastcall Boton_Valores_Por_DefectoClick(TObject *Sender);
  void __fastcall EFreverb0Click(TObject *Sender);
  void __fastcall EFreverb1Click(TObject *Sender);
  void __fastcall EFreverb2Click(TObject *Sender);
  void __fastcall Ajustar_Reverb_CheckClick(TObject *Sender);
  void __fastcall Ajustar_Reverb_BarraChange(TObject *Sender);
  void __fastcall Barra_FrecuenciaChange(TObject *Sender);
  void __fastcall Delay_Effects_CheckClick(TObject *Sender);
  void __fastcall FormCreate(TObject *Sender);
  void __fastcall Button2Click(TObject *Sender);
private:	// User declarations
public:		// User declarations
    void Inicializa_Patches();
    int Dame_Amplificacion(){return Barra_Amplificacion->Position;};
    String Dame_EFchorus();
    String Dame_EFreverb();
    String Dame_EFdelay();
    int Dame_Frecuency();
    String Dame_Ruta_Patch_File();
  __fastcall TForm2(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm2 *Form2;
//---------------------------------------------------------------------------
#endif
