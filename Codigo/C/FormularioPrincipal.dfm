object Form1: TForm1
  Left = 138
  Top = 105
  Width = 800
  Height = 600
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 136
    Top = 16
    Width = 124
    Height = 23
    Caption = 'Número acordes'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 128
    Top = 72
    Width = 147
    Height = 23
    Caption = 'Número mutaciones'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 440
    Top = 72
    Width = 157
    Height = 23
    Caption = 'Número repeticiones'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Etiqueta_Numero_Acordes: TLabel
    Left = 312
    Top = 40
    Width = 12
    Height = 27
    Caption = '0'
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -19
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Etiqueta_Numero_Mutaciones: TLabel
    Left = 312
    Top = 96
    Width = 12
    Height = 27
    Caption = '0'
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -19
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Etiqueta_Numero_Repeticiones: TLabel
    Left = 632
    Top = 96
    Width = 12
    Height = 27
    Caption = '1'
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -19
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label4: TLabel
    Left = 424
    Top = 16
    Width = 174
    Height = 23
    Caption = 'Elige el Patrón Rítmico'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Panel1: TPanel
    Left = 8
    Top = 168
    Width = 769
    Height = 289
    TabOrder = 0
  end
  object ScrollBar1: TScrollBar
    Left = 80
    Top = 464
    Width = 697
    Height = 17
    PageSize = 0
    TabOrder = 1
  end
  object ScrollBar2: TScrollBar
    Left = 176
    Top = 496
    Width = 545
    Height = 17
    PageSize = 0
    TabOrder = 2
  end
  object Button2: TButton
    Left = 16
    Top = 492
    Width = 33
    Height = 25
    Caption = '[_]'
    TabOrder = 3
  end
  object Button3: TButton
    Left = 48
    Top = 492
    Width = 33
    Height = 25
    Caption = '|>'
    TabOrder = 4
  end
  object Button5: TButton
    Left = 80
    Top = 492
    Width = 33
    Height = 25
    Caption = '| |'
    TabOrder = 5
  end
  object Button1: TButton
    Left = 16
    Top = 56
    Width = 73
    Height = 25
    Caption = 'Exportar Midi'
    TabOrder = 6
  end
  object Button4: TButton
    Left = 16
    Top = 80
    Width = 73
    Height = 25
    Caption = 'Exportar Wav'
    TabOrder = 7
  end
  object Button6: TButton
    Left = 16
    Top = 104
    Width = 73
    Height = 25
    Caption = 'Exportar PDF'
    TabOrder = 8
  end
  object Boton_Componer: TButton
    Left = 296
    Top = 128
    Width = 121
    Height = 25
    Caption = 'Dámelo Todo, Genaro'
    TabOrder = 9
    OnClick = Boton_ComponerClick
  end
  object Barra_Numero_Acordes: TTrackBar
    Left = 96
    Top = 40
    Width = 209
    Height = 25
    Max = 25
    Orientation = trHorizontal
    Frequency = 1
    Position = 0
    SelEnd = 0
    SelStart = 0
    TabOrder = 10
    TickMarks = tmBottomRight
    TickStyle = tsAuto
    OnChange = Barra_Numero_AcordesChange
  end
  object Barra_Numero_Mutaciones: TTrackBar
    Left = 96
    Top = 96
    Width = 209
    Height = 25
    Max = 25
    Orientation = trHorizontal
    Frequency = 1
    Position = 0
    SelEnd = 0
    SelStart = 0
    TabOrder = 11
    TickMarks = tmBottomRight
    TickStyle = tsAuto
    OnChange = Barra_Numero_MutacionesChange
  end
  object Barra_Numero_Repeticiones: TTrackBar
    Left = 400
    Top = 96
    Width = 225
    Height = 25
    Max = 30
    Min = 1
    Orientation = trHorizontal
    Frequency = 1
    Position = 1
    SelEnd = 0
    SelStart = 0
    TabOrder = 12
    TickMarks = tmBottomRight
    TickStyle = tsAuto
    OnChange = Barra_Numero_RepeticionesChange
  end
  object Selector_Patron_Ritmico: TComboBox
    Left = 408
    Top = 40
    Width = 209
    Height = 21
    ItemHeight = 13
    TabOrder = 13
    Text = 'Elige el patrón rítmico'
  end
  object MainMenu1: TMainMenu
    Left = 8
    Top = 136
    object Archivo1: TMenuItem
      Caption = '&Archivo'
      object Salir1: TMenuItem
        Caption = '&Salir'
        OnClick = Salir1Click
      end
    end
    object Edicin1: TMenuItem
      Caption = '&Edición'
      object EditordePianola1: TMenuItem
        Caption = 'Editor de &Pianola'
        OnClick = EditordePianola1Click
      end
    end
    object Insertar1: TMenuItem
      Caption = '&Insertar'
    end
  end
  object OpenDialog: TOpenDialog
    Left = 664
    Top = 128
  end
end
