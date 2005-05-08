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
#include "Tipos_Estructura.h"
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
  TPanel *Panel_Musica;
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
  TMenuItem *EditordePianola1;
  TMenuItem *Reproduccin1;
  TButton *Button7;
  TPanel *Panel1;
  TLabel *Label1;
  TLabel *Label2;
  TTrackBar *Barra_Numero_Mutaciones;
  TLabel *Etiqueta_Numero_Acordes;
  TLabel *Etiqueta_Numero_Mutaciones;
  TTrackBar *Barra_Numero_Repeticiones;
  TLabel *Label3;
  TLabel *Etiqueta_Numero_Repeticiones;
  TTrackBar *Barra_Numero_Acordes;
  TMenuItem *Nuevo;
  TButton *Boton_Nueva_Pista;
  TTrackBar *Barra_Tipo_Pista;
  TPanel *Panel_Tipo_Pista;
  TCheckBox *Mute_Pista;
  TLabel *Nombre_Pista;
  TComboBox *Instrumento_Pista;
  TLabel *Tipo_Pista;
  TButton *Boton_Guarda_Cambios_Pista;
  TTrackBar *Barra_N_Compases_Bloque;
  TButton *Boton_Nuevo_Bloque;
  TPageControl *Panel_Bloque;
  TTabSheet *Tab_Patron_Ritmico;
  TTabSheet *Tab_Progresion;
  TTabSheet *Tab_Melodia;
  TLabel *Label4;
  TComboBox *Selector_Patron_Ritmico;
  TComboBox *Lista_8_Inicial;
  TTrackBar *Barra_Notas_Totales;
  TLabel *Label5;
  TRadioGroup *RadioGroup1;
  TRadioButton *Sistema_Paralelo;
  TRadioButton *Sistema_Continuo;
  TLabel *Etiqueta_Numero_Total_De_Notas;
  TLabel *Label6;
  TComboBox *Lista_Inversion;
  TComboBox *Lista_Disposicion;
  TLabel *Etiqueta_Inversion;
  TLabel *Etiqueta_Disposicion;
  TTabSheet *Tab_General;
  TCheckBox *Bloque_Vacio;
  TLabel *Etiqueta_Bloque_Numero_Compases;
  TButton *Boton_Guardar_Cambios_Bloque;
  TRadioGroup *RadioGroup2;
  TRadioButton *Radio_Editor_Midi;
  TRadioButton *Radio_Curva_Melodia;
  TRadioButton *Radio_Delegar_Haskell;
  TLabel *Label7;
  TGroupBox *Grupo_TipoA;
  TGroupBox *Grupo_TipoB;
  TRadioButton *Radio_Mutaciones_Totales;
  TRadioButton *Radio_Especificas;
  TTrackBar *Barra_Mutaciones_Totales;
  TLabel *Etiqueta_Mutaciones_Totales;
  TRadioButton *Radio_TipoA_Generales;
  TTrackBar *Barra_TipoA_Generales;
  TRadioButton *Radio_TipoA_Especificas;
  TTrackBar *Barra_Mutaciones_Junta_Acordes;
  TTrackBar *Barra_Mutaciones_Separa_Acordes;
  TTrackBar *Barra_Mutaciones_Cambia_Acordes;
  TLabel *Etiqueta_TipoA_Generales;
  TLabel *Etiqueta_Tipo1;
  TLabel *Etiqueta_Tipo2;
  TLabel *Etiqueta_Tipo3;
  TLabel *Label12;
  TLabel *Label13;
  TLabel *Label14;
  TRadioButton *Radio_TipoB_Generales;
  TRadioButton *Radio_TipoB_Especificas;
  TTrackBar *Barra_TipoB_Generales;
  TTrackBar *Barra_Mutaciones_Dominante_Sencundario;
  TTrackBar *Barra_Mutaciones_2M7;
  TLabel *Label15;
  TLabel *Label16;
  TLabel *Etiqueta_Tipo4;
  TLabel *Etiqueta_Tipo5;
  TLabel *Etiqueta_TipoB_Generales;
  TButton *Button8;
  TButton *Button9;
  TLabel *Etiqueta_Numero_Compases;
  TLabel *Etiqueta_Tipo_Pista;
  TLabel *Label8;
  TTabSheet *Tab_Crear_Progresion;
  TButton *Button12;
  TGroupBox *GroupBox1;
  TRadioButton *Radio_Crear_Progresion;
  TRadioButton *Radio_Mutar_Progresion;
  TRadioButton *Radio_Mutar_Acorde_Progresion;
  TRadioButton *Radio_Mutar_Progresion_Multiple;
  TTrackBar *Barra_Numero_Acorde_A_Mutar;
  TOpenDialog *Dialogo_Origen_Progresion;
  TLabel *Label_Mutar_Acorde_N;
  TLabel *Label_Texto_Muta_Acorde;
  TComboBox *Selector_Pista_Acompanamiento;
  TMenuItem *Guardar1;
  TMenuItem *N1;
  TButton *Button10;
  TTabSheet *Tab_Aplicacion_Patron;
  TGroupBox *GroupBox2;
  TGroupBox *GroupBox3;
  TGroupBox *GroupBox4;
  TGroupBox *GroupBox5;
  TRadioButton *Radio_Horizontal_Ciclico;
  TRadioButton *Radio_Horizontal_No_Ciclico;
  TRadioButton *Radio_Vertical_Mayor_Truncar;
  TRadioButton *Radio_Vertical_Mayor_Saturar;
  TRadioButton *Radio_Vertical_Menor_Truncar;
  TRadioButton *Radio_Vertical_Menor_Saturar;
  TRadioButton *Radio_Vertical_Menor_Ciclico;
  TRadioButton *Radio_Vertical_Menor_Modulo;
  TCheckBox *Check_Semilla;
  TEdit *Edit_Semilla;
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
  void __fastcall Button7Click(TObject *Sender);
  void __fastcall FormClick(TObject *Sender);
  void __fastcall NuevoClick(TObject *Sender);
  void __fastcall Boton_Nueva_PistaClick(TObject *Sender);
  void __fastcall Boton_Guarda_Cambios_PistaClick(TObject *Sender);
  void __fastcall Boton_Nuevo_BloqueClick(TObject *Sender);
  void __fastcall Barra_Notas_TotalesChange(TObject *Sender);
  void __fastcall Sistema_ParaleloClick(TObject *Sender);
  void __fastcall Sistema_ContinuoClick(TObject *Sender);
  void __fastcall Bloque_VacioClick(TObject *Sender);
  void __fastcall Boton_Guardar_Cambios_BloqueClick(TObject *Sender);
  void __fastcall Radio_EspecificasClick(TObject *Sender);
  void __fastcall Radio_Mutaciones_TotalesClick(TObject *Sender);
  void __fastcall Barra_Mutaciones_TotalesChange(TObject *Sender);
  void __fastcall Barra_TipoA_GeneralesChange(TObject *Sender);
  void __fastcall Barra_TipoB_GeneralesChange(TObject *Sender);
  void __fastcall Barra_Mutaciones_Junta_AcordesChange(TObject *Sender);
  void __fastcall Barra_Mutaciones_Separa_AcordesChange(TObject *Sender);
  void __fastcall Barra_Mutaciones_Cambia_AcordesChange(TObject *Sender);
  void __fastcall Barra_Mutaciones_Dominante_SencundarioChange(
          TObject *Sender);
  void __fastcall Barra_Mutaciones_2M7Change(TObject *Sender);
  void __fastcall Barra_N_Compases_BloqueChange(TObject *Sender);
  void __fastcall Barra_Tipo_PistaChange(TObject *Sender);
  void __fastcall Barra_Numero_Acorde_A_MutarChange(TObject *Sender);
  void __fastcall Button12Click(TObject *Sender);
  void __fastcall Radio_Crear_ProgresionClick(TObject *Sender);
  void __fastcall Radio_Mutar_ProgresionClick(TObject *Sender);
  void __fastcall Radio_Mutar_Acorde_ProgresionClick(TObject *Sender);
  void __fastcall Radio_Mutar_Progresion_MultipleClick(TObject *Sender);
  void __fastcall Button9Click(TObject *Sender);
  void __fastcall Guardar1Click(TObject *Sender);
  void __fastcall FormPaint(TObject *Sender);
  void __fastcall Button10Click(TObject *Sender);
  void __fastcall Edit_SemillaChange(TObject *Sender);
private:	// User declarations
  Unidad_Nexo* unidad_de_union;
  int Alto_Fila;
  int Ancho_Columnas;
  int Numero_Filas_A_Dibujar;
  int Numero_Bloques;
  int Ancho_Espacio_Estatico;
  int Ancho;
  int Alto;
  int Fila_Pulsada;
  int Columna_Pulsada;
  int X_Inicial,X_Final,Y_Inicial,Y_Final;
  bool Inicializado;
  Cancion* Musica_Genaro; 
public:		// User declarations
  void Inicializa_Patrones_Ritmicos();
  void Dibuja_Cancion();
  void Dibuja_Esqueleto();
  void Accion_Click(int X,int Y);
  void Cuadro_Cabecera_Pista();
  void Cuadro_Bloque_Pista();  
  void Dibuja_Musica();
  void Crea_Progresion(String Ruta_Prolog,String argv[],int total_args);
  void Progresion_Crear_Progresion();
  void Progresion_Mutar_Progresion();
  void Progresion_Mutar_Acorde_Progresion();
  void Progresion_Mutar_Progresion_Multiple();
  void Inicializa_Pistas_Acompanamiento();
  void Genera_Music_Acompanamiento();  
  __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
