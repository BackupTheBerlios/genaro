//---------------------------------------------------------------------------

#ifndef EditorBH
#define EditorBH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include "TiposAbstractos.h"
#include <ComCtrls.hpp>
#include <Menus.hpp>
#include <ToolWin.hpp>
#include <ImgList.hpp>
#include <Dialogs.hpp>
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
  TScrollBar *Barra;
  TTrackBar *Barra_Zoom;
  TTrackBar *Barra_Nota;
  TLabel *Etiqueta_Duracion_Nota;
  TMainMenu *MainMenu1;
  TMenuItem *Archivo1;
  TMenuItem *Nuevo1;
  TScrollBar *BarraVoces;
  TLabel *Label3;
  TMenuItem *GuardarPatrnRtmico1;
  TCheckBox *Ajustar_Grid;
  TLabel *Resolucion_Grid;
  TTrackBar *Barra_Grid;
  TMenuItem *CargarPatrnRtmico1;
  TLabel *Label1;
  TToolBar *ToolBar1;
  TToolButton *ToolButton1;
  TImageList *ImageList1;
  TToolButton *ToolButton2;
  TToolButton *ToolButton3;
  TLabel *Etiqueta_Mensajes;
  TTrackBar *Velocity_Selector;
  TButton *Boton_Nueva_Voz;
  TTrackBar *Barra_Tempo;
  TLabel *Label2;
  TLabel *Label_Tempo;
  TToolButton *ToolButton4;
  TToolButton *ToolButton5;
  TMenuItem *Cerrar1;
  TSaveDialog *GuardarPB;
  TOpenDialog *CargarPB;
  void __fastcall FormClick(TObject *Sender);
  void __fastcall FormCreate(TObject *Sender);
  void __fastcall BarraChange(TObject *Sender);
  void __fastcall Barra_ZoomChange(TObject *Sender);
  void __fastcall Barra_NotaChange(TObject *Sender);
  void __fastcall Nuevo1Click(TObject *Sender);
  void __fastcall BarraVocesChange(TObject *Sender);
  void __fastcall GuardarPatrnRtmico1Click(TObject *Sender);
  void __fastcall Barra_GridChange(TObject *Sender);
  void __fastcall CargarPatrnRtmico1Click(TObject *Sender);
  void __fastcall ToolButton1Click(TObject *Sender);
  void __fastcall ToolButton2Click(TObject *Sender);
  void __fastcall ToolButton3Click(TObject *Sender);
  void __fastcall Boton_Nueva_VozClick(TObject *Sender);
  void __fastcall Velocity_SelectorChange(TObject *Sender);
  void __fastcall FormPaint(TObject *Sender);
  void __fastcall Previsualizar1Click(TObject *Sender);
  void __fastcall Barra_TempoChange(TObject *Sender);
  void __fastcall ToolButton5Click(TObject *Sender);
  void __fastcall Cerrar1Click(TObject *Sender);
private:	// User declarations
        int Numero_Columnas_Pantalla;
        int Ancho_Columna_Pantalla;
        int Numero_Filas_Pantalla;
        int Numero_Semi_Columnas_Pantalla;
        int Ancho_Semi_Columnas_Pantalla;
        int Ancho_Minimo_Columna_Pantalla;
        int Alto_Minimo_Columna_Pantalla;
        unsigned int PosicionActual;//indica cual es la primera columna
        unsigned int FilaActual;
        bool Inicializado;
        float Pico_Ajuste_Semi_Columnas;
        int Fila_Seleccionada;
        int Estado_Trabajo;//0-insertar, 1-borrar, 2- elegir fila
        MatrizNotas* Partitura;
        String Dir_Trabajo_Inicial;
public:		// User declarations
        int CalcularArea(int& ancho,int& alto);
        void CambiarIndice(int X, int Y);
        void BorrarIndice(int X, int Y);
        void CambiarVelocity(int X, int nuevo_velocity);
        void Dibuja_Esqueleto();
        void Dibuja_Notas();
        void Actualiza_Fila_Seleccionada(int Y);
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
