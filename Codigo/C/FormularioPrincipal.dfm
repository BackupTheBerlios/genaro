object Form1: TForm1
  Left = 75
  Top = 64
  Width = 800
  Height = 537
  Caption = 'Interfaz Genaro'
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
    Left = 192
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
    Left = 184
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
    Left = 496
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
    Left = 368
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
    Left = 368
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
    Left = 688
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
    Left = 480
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
    Left = 24
    Top = 168
    Width = 737
    Height = 289
    TabOrder = 0
  end
  object Button2: TButton
    Left = 360
    Top = 132
    Width = 33
    Height = 25
    Caption = '[_]'
    TabOrder = 1
  end
  object Button3: TButton
    Left = 392
    Top = 132
    Width = 33
    Height = 25
    Caption = '|>'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button5: TButton
    Left = 424
    Top = 132
    Width = 33
    Height = 25
    Caption = '| |'
    TabOrder = 3
  end
  object Button1: TButton
    Left = 32
    Top = 40
    Width = 73
    Height = 25
    Caption = 'Exportar Midi'
    TabOrder = 4
    OnClick = Button1Click
  end
  object Button4: TButton
    Left = 32
    Top = 64
    Width = 73
    Height = 25
    Caption = 'Exportar Wav'
    TabOrder = 5
    OnClick = Button4Click
  end
  object Button6: TButton
    Left = 32
    Top = 88
    Width = 73
    Height = 25
    Caption = 'Exportar PDF'
    TabOrder = 6
  end
  object Barra_Numero_Acordes: TTrackBar
    Left = 152
    Top = 40
    Width = 209
    Height = 25
    Max = 25
    Orientation = trHorizontal
    Frequency = 1
    Position = 0
    SelEnd = 0
    SelStart = 0
    TabOrder = 7
    TickMarks = tmBottomRight
    TickStyle = tsAuto
    OnChange = Barra_Numero_AcordesChange
  end
  object Barra_Numero_Mutaciones: TTrackBar
    Left = 152
    Top = 96
    Width = 209
    Height = 25
    Max = 25
    Orientation = trHorizontal
    Frequency = 1
    Position = 0
    SelEnd = 0
    SelStart = 0
    TabOrder = 8
    TickMarks = tmBottomRight
    TickStyle = tsAuto
    OnChange = Barra_Numero_MutacionesChange
  end
  object Barra_Numero_Repeticiones: TTrackBar
    Left = 456
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
    TabOrder = 9
    TickMarks = tmBottomRight
    TickStyle = tsAuto
    OnChange = Barra_Numero_RepeticionesChange
  end
  object Selector_Patron_Ritmico: TComboBox
    Left = 464
    Top = 40
    Width = 209
    Height = 21
    ItemHeight = 13
    TabOrder = 10
    Text = 'Elige el patrón rítmico'
  end
  object MainMenu1: TMainMenu
    Left = 32
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
      Caption = '&Opciones'
      object Reproduccin1: TMenuItem
        Caption = '&Reproducción'
        OnClick = Reproduccin1Click
      end
    end
  end
  object OpenDialog: TOpenDialog
    Left = 664
    Top = 128
  end
end
