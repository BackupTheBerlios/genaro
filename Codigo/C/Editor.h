//---------------------------------------------------------------------------

#ifndef EditorH
#define EditorH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include "TiposAbstractos.h"
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TButton *Button1;
  TEdit *Edit1;
  TLabel *Label1;
  TComboBox *SelectorZoom;
  TScrollBar *Barra;
  TButton *Button2;
  void __fastcall FormClick(TObject *Sender);
  void __fastcall FormCreate(TObject *Sender);
  void __fastcall Button1Click(TObject *Sender);
   void __fastcall SelectorZoomChange(TObject *Sender);
  void __fastcall BarraChange(TObject *Sender);
  void __fastcall Button2Click(TObject *Sender);
private:	// User declarations
        int AnchoColumna;
        int AltoColumna;
        int NumVoces;
        int NumColumnas;
        int TotalColumnas;
        int AjusteAncho;//Ajustes por los bordes
        int AjusteAlto;
        unsigned int PosicionActual;//indica cual es la primera columna
        bool Inicializado;
        MatrizNotas* Partitura;
public:		// User declarations
        int CalcularArea(int& ancho,int& alto);
        void DibujaColumnas(int NumeroVoces,int NumeroColumnas, int ancho, int alto);
        void CambiarIndice(int X, int Y);
        void Refrescar();
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
