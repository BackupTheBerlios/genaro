object Form1: TForm1
  Left = 73
  Top = 117
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
  OnClick = FormClick
  OnCreate = FormCreate
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object Etiqueta_Numero_Compases: TLabel
    Left = 168
    Top = 80
    Width = 10
    Height = 23
    Caption = '1'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Etiqueta_Tipo_Pista: TLabel
    Left = 128
    Top = 8
    Width = 88
    Height = 16
    Caption = 'Acompañamiento'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Panel_Musica: TPanel
    Left = 24
    Top = 168
    Width = 737
    Height = 289
    TabOrder = 0
    Visible = False
  end
  object Button2: TButton
    Left = 16
    Top = 92
    Width = 33
    Height = 25
    Caption = '[_]'
    TabOrder = 1
  end
  object Button3: TButton
    Left = 48
    Top = 92
    Width = 33
    Height = 25
    Caption = '|>'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button5: TButton
    Left = 80
    Top = 92
    Width = 33
    Height = 25
    Caption = '| |'
    TabOrder = 3
  end
  object Button1: TButton
    Left = 32
    Top = 8
    Width = 73
    Height = 25
    Caption = 'Exportar Midi'
    TabOrder = 4
    OnClick = Button1Click
  end
  object Button4: TButton
    Left = 32
    Top = 32
    Width = 73
    Height = 25
    Caption = 'Exportar Wav'
    TabOrder = 5
    OnClick = Button4Click
  end
  object Button6: TButton
    Left = 32
    Top = 56
    Width = 73
    Height = 25
    Caption = 'Exportar PDF'
    TabOrder = 6
  end
  object Button7: TButton
    Left = 368
    Top = 456
    Width = 121
    Height = 17
    Caption = 'Button7'
    TabOrder = 7
    OnClick = Button7Click
  end
  object Panel1: TPanel
    Left = 224
    Top = 0
    Width = 513
    Height = 153
    BorderStyle = bsSingle
    TabOrder = 8
    Visible = False
    object Label1: TLabel
      Left = 49
      Top = 16
      Width = 136
      Height = 23
      Caption = 'Número compases'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Comic Sans MS'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label2: TLabel
      Left = 48
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
    object Etiqueta_Numero_Acordes: TLabel
      Left = 224
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
      Left = 224
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
    object Label3: TLabel
      Left = 312
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
    object Etiqueta_Numero_Repeticiones: TLabel
      Left = 637
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
    object Barra_Numero_Mutaciones: TTrackBar
      Left = 8
      Top = 96
      Width = 209
      Height = 25
      Max = 100
      Orientation = trHorizontal
      Frequency = 1
      Position = 0
      SelEnd = 0
      SelStart = 0
      TabOrder = 0
      TickMarks = tmBottomRight
      TickStyle = tsAuto
      OnChange = Barra_Numero_MutacionesChange
    end
    object Barra_Numero_Repeticiones: TTrackBar
      Left = 272
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
      TabOrder = 1
      TickMarks = tmBottomRight
      TickStyle = tsAuto
      OnChange = Barra_Numero_RepeticionesChange
    end
    object Barra_Numero_Acordes: TTrackBar
      Left = 8
      Top = 40
      Width = 209
      Height = 25
      Max = 25
      Orientation = trHorizontal
      Frequency = 1
      Position = 0
      SelEnd = 0
      SelStart = 0
      TabOrder = 2
      TickMarks = tmBottomRight
      TickStyle = tsAuto
      OnChange = Barra_Numero_AcordesChange
    end
  end
  object Boton_Nueva_Pista: TButton
    Left = 136
    Top = 56
    Width = 73
    Height = 17
    Caption = 'Nueva Pista'
    TabOrder = 9
    OnClick = Boton_Nueva_PistaClick
  end
  object Barra_Tipo_Pista: TTrackBar
    Left = 136
    Top = 24
    Width = 73
    Height = 25
    Max = 1
    Orientation = trHorizontal
    PageSize = 1
    Frequency = 1
    Position = 0
    SelEnd = 0
    SelStart = 0
    TabOrder = 10
    TickMarks = tmBottomRight
    TickStyle = tsAuto
    OnChange = Barra_Tipo_PistaChange
  end
  object Panel_Tipo_Pista: TPanel
    Left = 224
    Top = 0
    Width = 513
    Height = 153
    BorderStyle = bsSingle
    TabOrder = 11
    Visible = False
    object Nombre_Pista: TLabel
      Left = 184
      Top = 8
      Width = 108
      Height = 23
      Caption = 'Nombre_Pista'
      Font.Charset = ANSI_CHARSET
      Font.Color = clRed
      Font.Height = -16
      Font.Name = 'Comic Sans MS'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Tipo_Pista: TLabel
      Left = 48
      Top = 64
      Width = 80
      Height = 23
      Caption = 'Tipo_Pista'
      Font.Charset = ANSI_CHARSET
      Font.Color = clRed
      Font.Height = -16
      Font.Name = 'Comic Sans MS'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Mute_Pista: TCheckBox
      Left = 200
      Top = 64
      Width = 81
      Height = 25
      Caption = 'Silencio'
      Font.Charset = ANSI_CHARSET
      Font.Color = clRed
      Font.Height = -16
      Font.Name = 'Comic Sans MS'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
    end
    object Instrumento_Pista: TComboBox
      Left = 328
      Top = 64
      Width = 145
      Height = 21
      ItemHeight = 13
      TabOrder = 1
      Text = 'Elija Instrumento'
      Items.Strings = (
        'Acoustic Grand Piano'
        'Bright Acoustic Piano'
        'Electric Grand Piano'
        'Honky-tonk Piano'
        'Rhodes Piano'
        'Chorused Piano'
        'Harpsichord'
        'Clavinet'
        'Celesta'
        'Glockenspiel'
        'Music Box'
        'Vibraphone')
    end
    object Boton_Guarda_Cambios_Pista: TButton
      Left = 200
      Top = 112
      Width = 81
      Height = 25
      Caption = 'Guarda Cambios'
      TabOrder = 2
      OnClick = Boton_Guarda_Cambios_PistaClick
    end
  end
  object Barra_N_Compases_Bloque: TTrackBar
    Left = 128
    Top = 104
    Width = 89
    Height = 25
    Max = 100
    Min = 1
    Orientation = trHorizontal
    Frequency = 1
    Position = 1
    SelEnd = 0
    SelStart = 0
    TabOrder = 12
    TickMarks = tmBottomRight
    TickStyle = tsAuto
    OnChange = Barra_N_Compases_BloqueChange
  end
  object Boton_Nuevo_Bloque: TButton
    Left = 136
    Top = 136
    Width = 73
    Height = 17
    Caption = 'Nuevo Bloque'
    TabOrder = 13
    OnClick = Boton_Nuevo_BloqueClick
  end
  object Panel_Bloque: TPageControl
    Left = 224
    Top = 0
    Width = 513
    Height = 161
    ActivePage = Tab_Progresion
    TabOrder = 14
    Visible = False
    object Tab_General: TTabSheet
      Caption = 'General'
      ImageIndex = 3
      object Etiqueta_Bloque_Numero_Compases: TLabel
        Left = 144
        Top = 48
        Width = 222
        Height = 19
        Caption = 'Etiqueta_Bloque_Numero_Compases'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Comic Sans MS'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label8: TLabel
        Left = 144
        Top = 8
        Width = 219
        Height = 20
        Caption = 'Información de Sub Bloque'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Bloque_Vacio: TCheckBox
        Left = 8
        Top = 48
        Width = 105
        Height = 25
        Caption = 'Silencio'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Comic Sans MS'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        OnClick = Bloque_VacioClick
      end
      object Boton_Guardar_Cambios_Bloque: TButton
        Left = 184
        Top = 88
        Width = 113
        Height = 33
        Caption = 'Guardar Cambios'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Comic Sans MS'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
        OnClick = Boton_Guardar_Cambios_BloqueClick
      end
      object Button10: TButton
        Left = 344
        Top = 96
        Width = 97
        Height = 25
        Caption = 'Generar Notas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 2
        OnClick = Button10Click
      end
    end
    object Tab_Patron_Ritmico: TTabSheet
      Caption = 'Patrón Rítmico'
      object Label4: TLabel
        Left = 184
        Top = 8
        Width = 92
        Height = 19
        Caption = 'Patrón Rítmico'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Comic Sans MS'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label5: TLabel
        Left = 8
        Top = 72
        Width = 127
        Height = 16
        Caption = 'Número Total de Notas'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Comic Sans MS'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Etiqueta_Numero_Total_De_Notas: TLabel
        Left = 128
        Top = 96
        Width = 11
        Height = 20
        Caption = '2'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label6: TLabel
        Left = 32
        Top = 8
        Width = 62
        Height = 19
        Caption = '8ª Inicial'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Comic Sans MS'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Etiqueta_Inversion: TLabel
        Left = 376
        Top = 16
        Width = 57
        Height = 19
        Caption = 'Inversión'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Comic Sans MS'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Etiqueta_Disposicion: TLabel
        Left = 376
        Top = 72
        Width = 68
        Height = 19
        Caption = 'Disposición'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Comic Sans MS'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Selector_Patron_Ritmico: TComboBox
        Left = 160
        Top = 32
        Width = 145
        Height = 21
        ItemHeight = 13
        TabOrder = 0
        Text = 'Elige el patrón rítmico'
      end
      object Lista_8_Inicial: TComboBox
        Left = 8
        Top = 32
        Width = 113
        Height = 21
        ItemHeight = 13
        TabOrder = 1
        Text = '1'
        Items.Strings = (
          '1'
          '2'
          '3'
          '4'
          '5'
          '6'
          '7')
      end
      object Barra_Notas_Totales: TTrackBar
        Left = 0
        Top = 96
        Width = 113
        Height = 25
        Max = 20
        Min = 2
        Orientation = trHorizontal
        PageSize = 1
        Frequency = 1
        Position = 2
        SelEnd = 0
        SelStart = 0
        TabOrder = 2
        TickMarks = tmBottomRight
        TickStyle = tsAuto
        OnChange = Barra_Notas_TotalesChange
      end
      object RadioGroup1: TRadioGroup
        Left = 160
        Top = 72
        Width = 145
        Height = 57
        Caption = 'Elige Sistema'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 3
      end
      object Sistema_Paralelo: TRadioButton
        Left = 168
        Top = 88
        Width = 129
        Height = 17
        Caption = 'Sistema Paralelo'
        Checked = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 4
        TabStop = True
        OnClick = Sistema_ParaleloClick
      end
      object Sistema_Continuo: TRadioButton
        Left = 168
        Top = 104
        Width = 129
        Height = 17
        Caption = 'Sistema Continuo'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 5
        OnClick = Sistema_ContinuoClick
      end
      object Lista_Inversion: TComboBox
        Left = 352
        Top = 40
        Width = 121
        Height = 21
        ItemHeight = 13
        TabOrder = 6
        Text = 'Fundamental'
        Items.Strings = (
          'Fundamental'
          '1ª Inversión'
          '2ª Inversión'
          '3ª Inversión')
      end
      object Lista_Disposicion: TComboBox
        Left = 352
        Top = 96
        Width = 121
        Height = 21
        ItemHeight = 13
        TabOrder = 7
        Text = '1ª Disposición'
        Items.Strings = (
          '1ª Disposición'
          '2ª Disposición'
          '3ª Disposición'
          '4ª Disposición')
      end
    end
    object Tab_Aplicacion_Patron: TTabSheet
      Caption = 'Aplicación Patrón'
      ImageIndex = 5
      object GroupBox2: TGroupBox
        Left = 8
        Top = 8
        Width = 161
        Height = 121
        Caption = 'Aplicación Horizontal'
        TabOrder = 0
        object Radio_Horizontal_Ciclico: TRadioButton
          Left = 16
          Top = 32
          Width = 129
          Height = 25
          Caption = 'Cíclico'
          Checked = True
          TabOrder = 0
          TabStop = True
        end
        object Radio_Horizontal_No_Ciclico: TRadioButton
          Left = 16
          Top = 80
          Width = 121
          Height = 17
          Caption = 'No Cíclico'
          TabOrder = 1
        end
      end
      object GroupBox3: TGroupBox
        Left = 176
        Top = 8
        Width = 313
        Height = 121
        Caption = '                              Aplicación Vertical'
        TabOrder = 1
        object GroupBox4: TGroupBox
          Left = 8
          Top = 16
          Width = 121
          Height = 97
          Caption = 'A > P'
          TabOrder = 0
          object Radio_Vertical_Mayor_Truncar: TRadioButton
            Left = 8
            Top = 24
            Width = 105
            Height = 17
            Caption = 'Truncar'
            Checked = True
            TabOrder = 0
            TabStop = True
          end
          object Radio_Vertical_Mayor_Saturar: TRadioButton
            Left = 8
            Top = 64
            Width = 97
            Height = 17
            Caption = 'Saturar'
            TabOrder = 1
          end
        end
        object GroupBox5: TGroupBox
          Left = 136
          Top = 16
          Width = 161
          Height = 97
          Caption = 'A < P'
          TabOrder = 1
          object Radio_Vertical_Menor_Truncar: TRadioButton
            Left = 16
            Top = 16
            Width = 97
            Height = 17
            Caption = 'Truncar'
            Checked = True
            TabOrder = 0
            TabStop = True
          end
          object Radio_Vertical_Menor_Saturar: TRadioButton
            Left = 16
            Top = 32
            Width = 89
            Height = 17
            Caption = 'Saturar'
            TabOrder = 1
          end
          object Radio_Vertical_Menor_Ciclico: TRadioButton
            Left = 16
            Top = 48
            Width = 81
            Height = 25
            Caption = 'Cíclico'
            TabOrder = 2
          end
          object Radio_Vertical_Menor_Modulo: TRadioButton
            Left = 16
            Top = 64
            Width = 81
            Height = 25
            Caption = 'Módulo'
            TabOrder = 3
          end
        end
      end
    end
    object Tab_Progresion: TTabSheet
      Caption = 'Mutar Progresión'
      ImageIndex = 1
      object Etiqueta_Mutaciones_Totales: TLabel
        Left = 328
        Top = 0
        Width = 10
        Height = 23
        Caption = '0'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Comic Sans MS'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Grupo_TipoA: TGroupBox
        Left = 0
        Top = 32
        Width = 273
        Height = 97
        Caption = 'Tipo A'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Comic Sans MS'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        object Etiqueta_TipoA_Generales: TLabel
          Left = 208
          Top = 16
          Width = 8
          Height = 19
          Caption = '0'
          Enabled = False
        end
        object Etiqueta_Tipo1: TLabel
          Left = 72
          Top = 64
          Width = 8
          Height = 19
          Caption = '0'
          Enabled = False
        end
        object Etiqueta_Tipo2: TLabel
          Left = 160
          Top = 64
          Width = 8
          Height = 19
          Caption = '0'
          Enabled = False
        end
        object Etiqueta_Tipo3: TLabel
          Left = 248
          Top = 64
          Width = 8
          Height = 19
          Caption = '0'
          Enabled = False
        end
        object Label12: TLabel
          Left = 8
          Top = 48
          Width = 72
          Height = 15
          Caption = 'Junta acordes'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Comic Sans MS'
          Font.Style = []
          ParentFont = False
        end
        object Label13: TLabel
          Left = 96
          Top = 48
          Width = 80
          Height = 15
          Caption = 'Separa acordes'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Comic Sans MS'
          Font.Style = []
          ParentFont = False
        end
        object Label14: TLabel
          Left = 184
          Top = 48
          Width = 80
          Height = 15
          Caption = 'Cambia acordes'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Comic Sans MS'
          Font.Style = []
          ParentFont = False
        end
        object Radio_TipoA_Generales: TRadioButton
          Left = 8
          Top = 16
          Width = 89
          Height = 17
          Caption = 'Generales'
          Checked = True
          Enabled = False
          TabOrder = 0
          TabStop = True
        end
        object Barra_TipoA_Generales: TTrackBar
          Left = 104
          Top = 16
          Width = 97
          Height = 25
          Enabled = False
          Max = 25
          Orientation = trHorizontal
          Frequency = 1
          Position = 0
          SelEnd = 0
          SelStart = 0
          TabOrder = 1
          TickMarks = tmBottomRight
          TickStyle = tsAuto
          OnChange = Barra_TipoA_GeneralesChange
        end
        object Radio_TipoA_Especificas: TRadioButton
          Left = 8
          Top = 32
          Width = 97
          Height = 17
          Caption = 'Específicas'
          Enabled = False
          TabOrder = 2
        end
        object Barra_Mutaciones_Junta_Acordes: TTrackBar
          Left = 8
          Top = 64
          Width = 65
          Height = 25
          Enabled = False
          Max = 20
          Orientation = trHorizontal
          Frequency = 1
          Position = 0
          SelEnd = 0
          SelStart = 0
          TabOrder = 3
          TickMarks = tmBottomRight
          TickStyle = tsAuto
          OnChange = Barra_Mutaciones_Junta_AcordesChange
        end
        object Barra_Mutaciones_Separa_Acordes: TTrackBar
          Left = 96
          Top = 64
          Width = 65
          Height = 25
          Enabled = False
          Max = 20
          Orientation = trHorizontal
          Frequency = 1
          Position = 0
          SelEnd = 0
          SelStart = 0
          TabOrder = 4
          TickMarks = tmBottomRight
          TickStyle = tsAuto
          OnChange = Barra_Mutaciones_Separa_AcordesChange
        end
        object Barra_Mutaciones_Cambia_Acordes: TTrackBar
          Left = 184
          Top = 64
          Width = 65
          Height = 25
          Enabled = False
          Max = 20
          Orientation = trHorizontal
          Frequency = 1
          Position = 0
          SelEnd = 0
          SelStart = 0
          TabOrder = 5
          TickMarks = tmBottomRight
          TickStyle = tsAuto
          OnChange = Barra_Mutaciones_Cambia_AcordesChange
        end
      end
      object Grupo_TipoB: TGroupBox
        Left = 272
        Top = 32
        Width = 233
        Height = 97
        Caption = 'Tibo B'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Comic Sans MS'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
        object Label15: TLabel
          Left = 136
          Top = 48
          Width = 63
          Height = 15
          Caption = '2ª Menor 7ª'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Comic Sans MS'
          Font.Style = []
          ParentFont = False
        end
        object Label16: TLabel
          Left = 8
          Top = 48
          Width = 116
          Height = 15
          Caption = 'Dominante Secundario'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Comic Sans MS'
          Font.Style = []
          ParentFont = False
        end
        object Etiqueta_Tipo4: TLabel
          Left = 96
          Top = 64
          Width = 8
          Height = 19
          Caption = '0'
          Enabled = False
        end
        object Etiqueta_Tipo5: TLabel
          Left = 208
          Top = 64
          Width = 8
          Height = 19
          Caption = '0'
          Enabled = False
        end
        object Etiqueta_TipoB_Generales: TLabel
          Left = 200
          Top = 16
          Width = 8
          Height = 19
          Caption = '0'
          Enabled = False
        end
        object Radio_TipoB_Generales: TRadioButton
          Left = 8
          Top = 16
          Width = 89
          Height = 17
          Caption = 'Generales'
          Checked = True
          Enabled = False
          TabOrder = 0
          TabStop = True
        end
        object Radio_TipoB_Especificas: TRadioButton
          Left = 8
          Top = 32
          Width = 89
          Height = 17
          Caption = 'Específicas'
          Enabled = False
          TabOrder = 1
        end
        object Barra_TipoB_Generales: TTrackBar
          Left = 104
          Top = 16
          Width = 89
          Height = 25
          Enabled = False
          Max = 25
          Orientation = trHorizontal
          Frequency = 1
          Position = 0
          SelEnd = 0
          SelStart = 0
          TabOrder = 2
          TickMarks = tmBottomRight
          TickStyle = tsAuto
          OnChange = Barra_TipoB_GeneralesChange
        end
        object Barra_Mutaciones_Dominante_Sencundario: TTrackBar
          Left = 8
          Top = 64
          Width = 89
          Height = 25
          Max = 20
          Orientation = trHorizontal
          Frequency = 1
          Position = 0
          SelEnd = 0
          SelStart = 0
          TabOrder = 3
          TickMarks = tmBottomRight
          TickStyle = tsAuto
          OnChange = Barra_Mutaciones_Dominante_SencundarioChange
        end
        object Barra_Mutaciones_2M7: TTrackBar
          Left = 128
          Top = 64
          Width = 81
          Height = 25
          Enabled = False
          Max = 20
          Orientation = trHorizontal
          Frequency = 1
          Position = 0
          SelEnd = 0
          SelStart = 0
          TabOrder = 4
          TickMarks = tmBottomRight
          TickStyle = tsAuto
          OnChange = Barra_Mutaciones_2M7Change
        end
      end
      object Radio_Mutaciones_Totales: TRadioButton
        Left = 16
        Top = 0
        Width = 145
        Height = 17
        Caption = 'Mutaciones totales'
        Checked = True
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Comic Sans MS'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 2
        TabStop = True
        OnClick = Radio_Mutaciones_TotalesClick
      end
      object Radio_Especificas: TRadioButton
        Left = 16
        Top = 16
        Width = 137
        Height = 17
        Caption = 'Especificar tipo'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Comic Sans MS'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 3
        OnClick = Radio_EspecificasClick
      end
      object Barra_Mutaciones_Totales: TTrackBar
        Left = 168
        Top = 0
        Width = 153
        Height = 25
        Max = 50
        Orientation = trHorizontal
        Frequency = 1
        Position = 0
        SelEnd = 0
        SelStart = 0
        TabOrder = 4
        TickMarks = tmBottomRight
        TickStyle = tsAuto
        OnChange = Barra_Mutaciones_TotalesChange
      end
    end
    object Tab_Crear_Progresion: TTabSheet
      Caption = 'Crear Progresión'
      ImageIndex = 4
      object Label_Mutar_Acorde_N: TLabel
        Left = 464
        Top = 48
        Width = 11
        Height = 20
        Caption = '1'
        Enabled = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label_Texto_Muta_Acorde: TLabel
        Left = 264
        Top = 32
        Width = 186
        Height = 16
        Caption = 'Número de Acorde a Mutar'
        Enabled = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Button12: TButton
        Left = 160
        Top = 104
        Width = 129
        Height = 25
        Caption = 'Crear Progresión'
        TabOrder = 0
        OnClick = Button12Click
      end
      object GroupBox1: TGroupBox
        Left = 16
        Top = 8
        Width = 209
        Height = 89
        Caption = 'Opciones de Creación'
        TabOrder = 1
        object Radio_Crear_Progresion: TRadioButton
          Left = 16
          Top = 16
          Width = 121
          Height = 17
          Caption = 'Crear Progresión'
          Checked = True
          TabOrder = 0
          TabStop = True
          OnClick = Radio_Crear_ProgresionClick
        end
        object Radio_Mutar_Progresion: TRadioButton
          Left = 16
          Top = 32
          Width = 153
          Height = 17
          Caption = 'Mutar Progresión Existente'
          TabOrder = 1
          OnClick = Radio_Mutar_ProgresionClick
        end
        object Radio_Mutar_Acorde_Progresion: TRadioButton
          Left = 16
          Top = 48
          Width = 177
          Height = 17
          Caption = 'Mutar Acorde de una Progresión'
          TabOrder = 2
          OnClick = Radio_Mutar_Acorde_ProgresionClick
        end
        object Radio_Mutar_Progresion_Multiple: TRadioButton
          Left = 16
          Top = 64
          Width = 161
          Height = 17
          Caption = 'Mutar Progresión Múltiple'
          TabOrder = 3
          OnClick = Radio_Mutar_Progresion_MultipleClick
        end
      end
      object Barra_Numero_Acorde_A_Mutar: TTrackBar
        Left = 256
        Top = 48
        Width = 201
        Height = 25
        Enabled = False
        Max = 1
        Min = 1
        Orientation = trHorizontal
        Frequency = 1
        Position = 1
        SelEnd = 0
        SelStart = 0
        TabOrder = 2
        TickMarks = tmBottomRight
        TickStyle = tsAuto
        OnChange = Barra_Numero_Acorde_A_MutarChange
      end
    end
    object Tab_Melodia: TTabSheet
      Caption = 'Melodía'
      ImageIndex = 2
      object Label7: TLabel
        Left = 296
        Top = 16
        Width = 166
        Height = 19
        Caption = 'Pista de Acompañamiento:'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Comic Sans MS'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object RadioGroup2: TRadioGroup
        Left = 8
        Top = 16
        Width = 249
        Height = 105
        Caption = 'Elige como crear la melodía:'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Comic Sans MS'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
      end
      object Radio_Editor_Midi: TRadioButton
        Left = 40
        Top = 48
        Width = 153
        Height = 17
        Caption = 'Usar el editor MIDI'
        Enabled = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
      end
      object Radio_Curva_Melodia: TRadioButton
        Left = 40
        Top = 72
        Width = 193
        Height = 17
        Caption = 'Crear la curva melódica '
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 2
      end
      object Radio_Delegar_Haskell: TRadioButton
        Left = 40
        Top = 96
        Width = 161
        Height = 17
        Caption = 'Delegar en Haskell'
        Checked = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 3
        TabStop = True
      end
      object Button8: TButton
        Left = 280
        Top = 88
        Width = 81
        Height = 33
        Caption = 'Editor Midi'
        Enabled = False
        TabOrder = 4
      end
      object Button9: TButton
        Left = 376
        Top = 88
        Width = 81
        Height = 33
        Caption = 'Crear Curva'
        TabOrder = 5
        OnClick = Button9Click
      end
      object Selector_Pista_Acompanamiento: TComboBox
        Left = 280
        Top = 48
        Width = 193
        Height = 21
        ItemHeight = 13
        TabOrder = 6
        Text = 'Elige Pista de acompañamiento'
      end
    end
  end
  object MainMenu1: TMainMenu
    Left = 200
    Top = 456
    object Archivo1: TMenuItem
      Caption = '&Archivo'
      object Nuevo: TMenuItem
        Caption = '&Nuevo'
        OnClick = NuevoClick
      end
      object Guardar1: TMenuItem
        Caption = '&Guardar'
        OnClick = Guardar1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
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
    Left = 304
    Top = 456
  end
  object Dialogo_Origen_Progresion: TOpenDialog
    Left = 700
    Top = 120
  end
end
