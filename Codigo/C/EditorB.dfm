object Form1: TForm1
  Left = 89
  Top = 147
  BorderStyle = bsSingle
  Caption = 'Form1'
  ClientHeight = 456
  ClientWidth = 904
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
  object Etiqueta_Duracion_Nota: TLabel
    Left = 520
    Top = 56
    Width = 23
    Height = 19
    Caption = '1/1'
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -13
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 120
    Top = 40
    Width = 187
    Height = 19
    Caption = 'Zoom In            Zoom Out'
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -13
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Resolucion_Grid: TLabel
    Left = 712
    Top = 56
    Width = 23
    Height = 19
    Caption = '1/1'
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -13
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label1: TLabel
    Left = 336
    Top = 32
    Width = 147
    Height = 21
    Caption = 'Duraci�n de la Nota'
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -15
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 784
    Top = 32
    Width = 46
    Height = 21
    Caption = 'Tempo'
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -15
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label_Tempo: TLabel
    Left = 864
    Top = 56
    Width = 24
    Height = 19
    Caption = '100'
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -13
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Barra: TScrollBar
    Left = 96
    Top = 432
    Width = 785
    Height = 17
    PageSize = 0
    TabOrder = 0
    OnChange = BarraChange
  end
  object Barra_Zoom: TTrackBar
    Left = 112
    Top = 56
    Width = 201
    Height = 25
    Max = 40
    Min = 1
    Orientation = trHorizontal
    Frequency = 1
    Position = 1
    SelEnd = 0
    SelStart = 0
    TabOrder = 1
    TickMarks = tmBottomRight
    TickStyle = tsAuto
    OnChange = Barra_ZoomChange
  end
  object Barra_Nota: TTrackBar
    Left = 328
    Top = 56
    Width = 185
    Height = 25
    Max = 7
    Orientation = trHorizontal
    Frequency = 1
    Position = 0
    SelEnd = 0
    SelStart = 0
    TabOrder = 2
    TickMarks = tmBottomRight
    TickStyle = tsAuto
    OnChange = Barra_NotaChange
  end
  object BarraVoces: TScrollBar
    Left = 17
    Top = 88
    Width = 16
    Height = 353
    Kind = sbVertical
    Max = 0
    PageSize = 0
    TabOrder = 3
    OnChange = BarraVocesChange
  end
  object Ajustar_Grid: TCheckBox
    Left = 560
    Top = 32
    Width = 137
    Height = 17
    Caption = 'Ajustar al Grid'
    Checked = True
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -15
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
    State = cbChecked
    TabOrder = 4
  end
  object Barra_Grid: TTrackBar
    Left = 552
    Top = 56
    Width = 153
    Height = 25
    Max = 7
    Orientation = trHorizontal
    Frequency = 1
    Position = 0
    SelEnd = 0
    SelStart = 0
    TabOrder = 5
    TickMarks = tmBottomRight
    TickStyle = tsAuto
    OnChange = Barra_GridChange
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 904
    Height = 33
    ButtonHeight = 27
    ButtonWidth = 33
    Caption = 'ToolBar1'
    Images = ImageList1
    TabOrder = 6
    object ToolButton1: TToolButton
      Left = 0
      Top = 2
      Caption = 'ToolButton1'
      ImageIndex = 0
      OnClick = ToolButton1Click
    end
    object ToolButton2: TToolButton
      Left = 33
      Top = 2
      Caption = 'ToolButton2'
      ImageIndex = 1
      OnClick = ToolButton2Click
    end
    object ToolButton3: TToolButton
      Left = 66
      Top = 2
      Caption = 'ToolButton3'
      ImageIndex = 2
      OnClick = ToolButton3Click
    end
    object ToolButton4: TToolButton
      Left = 99
      Top = 2
      Width = 8
      Caption = 'ToolButton4'
      ImageIndex = 3
      Style = tbsSeparator
    end
    object ToolButton5: TToolButton
      Left = 107
      Top = 2
      Caption = 'ToolButton5'
      ImageIndex = 3
      OnClick = ToolButton5Click
    end
    object Etiqueta_Mensajes: TLabel
      Left = 140
      Top = 2
      Width = 8
      Height = 27
      Font.Charset = ANSI_CHARSET
      Font.Color = clRed
      Font.Height = -19
      Font.Name = 'Comic Sans MS'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object Velocity_Selector: TTrackBar
    Left = 48
    Top = 360
    Width = 25
    Height = 89
    Max = 127
    Orientation = trVertical
    PageSize = 5
    Frequency = 1
    Position = 77
    SelEnd = 0
    SelStart = 0
    TabOrder = 7
    TickMarks = tmBottomRight
    TickStyle = tsAuto
    OnChange = Velocity_SelectorChange
  end
  object Boton_Nueva_Voz: TButton
    Left = 16
    Top = 48
    Width = 89
    Height = 33
    Caption = 'Nueva Voz'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 8
    Visible = False
    OnClick = Boton_Nueva_VozClick
  end
  object Barra_Tempo: TTrackBar
    Left = 752
    Top = 56
    Width = 105
    Height = 25
    Max = 300
    Min = 1
    Orientation = trHorizontal
    Frequency = 1
    Position = 100
    SelEnd = 0
    SelStart = 0
    TabOrder = 9
    TickMarks = tmBottomRight
    TickStyle = tsAuto
    OnChange = Barra_TempoChange
  end
  object MainMenu1: TMainMenu
    Left = 352
    Top = 168
    object Archivo1: TMenuItem
      Caption = '&Archivo'
      object Nuevo1: TMenuItem
        Caption = '&Nuevo'
        OnClick = Nuevo1Click
      end
      object CargarPatrnRtmico1: TMenuItem
        Caption = '&Cargar Bateria'
        OnClick = CargarPatrnRtmico1Click
      end
      object GuardarPatrnRtmico1: TMenuItem
        Caption = '&Guardar Bateria'
        OnClick = GuardarPatrnRtmico1Click
      end
      object Cerrar1: TMenuItem
        Caption = '&Salir'
        OnClick = Cerrar1Click
      end
    end
  end
  object ImageList1: TImageList
    Left = 384
    Top = 168
    Bitmap = {
      494C010104000900040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000003000000001002000000000000030
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000734F4F005224
      2400522424005224240052242400522424005224240066333300000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000502222009D6B
      6B00996767009966660099666600996666009966660099666600663333000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000066000000660000006600000066000000660000006600000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000009B6A6A00A171
      71009D6B6B009967670099666600996666009966660099666600663333006837
      3700000000000000000000000000000000000000000000000000000000008080
      8000000000000000000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000009C0000006600000066000000660000009C000000660000006600000066
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      0000008080000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000A97E7E00A578
      7800A07171009C6B6B0099666600996666009966660099666600D8B1B1006633
      3300673434000000000000000000000000000000000000000000808080000000
      0000000000000000000000000000808080000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000009C
      0000009C000000660000000000000066000000660000009C0000009C0000009C
      00000066000000000000000000000000000000000000000000000000000000FF
      FF0000FFFF000080800000808000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000967B7B00AF888800AA7F
      7F00A4777700A07070009C6A6A00996666009966660099666600D6B6B6006633
      3300663333000000000000000000000000000000000080808000000000000000
      0000000000000000000000000000000000008080800000000000000000000000
      000000000000000000000000000000000000000000000000000000CC0000009C
      0000009C0000006600000000000000000000000000000066000000660000009C
      0000009C00000066000000000000000000000000000000000000000000000080
      800000FFFF0000FFFF0000808000008080000000000000000000000000000000
      000000000000000000000000000000000000000000004A1B1B00B58F8F00AF88
      8800AA7F7F00A47777009F7070009C6A6A009966660099666600AE8282006633
      330066333300000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000080808000808080008080
      8000808080000000000000000000000000000000000000CC000000CC0000009C
      0000009C00000066000000000000000000000000000000000000006600000066
      0000009C00000066000000660000000000000000000000000000000000000080
      80000080800000FFFF0000FFFF00008080000080800000000000000000000000
      000000000000000000000000000000000000000000008D636300B9979700B58F
      8F00AE868600A97E7E00A37676009F6F6F009B6A6A0099666600996666006633
      330066333300BEACAC000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000808080000000
      0000000000000000000000000000000000000000000000CC000000CC0000009C
      0000009C00000066000000000000000000000000000000000000000000000066
      0000009C0000009C000000660000000000000000000000000000000000000000
      0000008080000080800000FFFF0000FFFF000080800000808000000000000000
      00000000000000000000000000000000000000000000B6949400BF9E9E00B997
      9700B48E8E00AE858500A87D7D00A37676009F6E6E009B696900996666006633
      3300663333006E48480000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000CC000000CC0000009C
      0000009C00000066000000000000000000000000000000000000000000000000
      0000009C0000009C000000660000000000000000000000000000000000000000
      000000000000008080000080800000FFFF0000FFFF0000808000008080000000
      000000000000000000000000000000000000C4B4B400C8ACAC00C3A6A600BF9E
      9E00B9969600B38D8D00AE858500A87D7D00A37575009E6E6E009B6868006633
      3300663333005826260000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF000000000000000000000000008080
      0000FFFF00008080000000000000000000000000000000CC000000CC0000009C
      0000009C00000066000000000000000000000000000000000000000000000000
      0000009C0000009C000000660000000000000000000000000000000000000000
      00000000000000000000008080000080800000FFFF0000FFFF00008080000080
      800000000000000000000000000000000000623A3A00CBB0B000C7ACAC00C3A5
      A500BF9E9E00B9959500B38C8C00AD838300A77B7B00A37474009E6D6D00CB9B
      9B00663333006633330000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF0000000000000000000000000080800000FFFF
      0000808000000000000000000000000000000000000000CC000000CC000000CC
      0000009C00000066000000000000000000000000000000000000000000000066
      0000009C0000009C000000660000000000000000000000000000000000000000
      0000000000000000000000000000008080000080800000FFFF0000FFFF000080
      800000000000000000000000000000000000572C2C00CCB3B300CBB0B000C7AB
      AB00C3A5A500BD9D9D00B9959500B38C8C00AD838300A77B7B00A2747400B886
      8600663333006633330000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080800000FFFF00008080
      0000000000000000000000000000000000000000000000CC000000CC000000CC
      0000009C00000066000000000000000000000000000000000000006600000066
      0000009C0000009C000000660000000000000000000000000000000000000000
      000000000000000000000000000000000000008080000080800000FFFF0000FF
      FF00808080000000000000000000000000004A1B1B006E48480062444F002E3B
      8900051F880071704600817F5600817F56008072550085597200AA828500C8AF
      AF00663333006633330000000000000000000000000000000000000000000000
      00008080800000000000000000000000000080800000FFFF0000808000000000
      000000000000000000000000000000000000000000000000000000CC000000CC
      0000009C0000006600000000000000000000000000000066000000660000009C
      0000009C0000009C000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000808000008080008080
      80008080800080808000FF00FF0000000000000000004A1B1B000B176C000033
      CC000033CC00717046008080550080805500746B490072467200784C7800794A
      6400C4AEAE0066333300A1878700000000000000000000000000000000000000
      0000FFFFFF000000000000000000FFFFFF00FFFF000080800000000000000000
      00000000000000000000000000000000000000000000000000000000000000CC
      000000CC000000660000000000000066000000660000009C0000009C0000009C
      0000009C00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080008080
      800080808000FF00FF00FF00FF000000000000000000000000002F1E48000033
      CC000033CC003A51810070625B00836B5500704D62007C507C007C507C008052
      730098656600AE91910061363600000000000000000000000000000000000000
      00000000000000000000FFFFFF00FFFF00008080000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000CC0000006600000066000000660000009C0000009C0000009C0000009C
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000FF00FF00FF00FF00FF00FF00000000000000000000000000000000000029
      AD000033CC000633BA00171F7000572A3400724672007C507C007A4E7A005F32
      4B0052242400522424004A1B1B00000000000000000000000000000000000000
      0000000000000000000000000000FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000CC000000CC000000CC000000CC000000CC000000CC00000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FF00FF00FF00FF0000000000000000000000000000000000000000002139
      97005C6FB700B7C0E1000000000000000000C7B7C70072487200754975000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000300000000100010000000000800100000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000007FFFC03FBFFFF81F1FFFC01FB3FFF00F
      87FFC00F8DFFE007D3FFC007DEFFC203A1FF8007BF7F8381C0FF8007638303C0
      E07F800361C503E0F03F8003B08303F0F81F0003D80103F0FC0F0003EC0303E0
      FE070003F40703C0FF030003F00F8381FF818001F01FC203FFC0C001F83FE007
      FFE1E001FC7FF00FFFF3E31FFCFFF81F00000000000000000000000000000000
      000000000000}
  end
  object GuardarPB: TSaveDialog
    Filter = 'Bater�a|*.txt|Todos los Archivos|*.*'
    Left = 416
    Top = 168
  end
  object CargarPB: TOpenDialog
    Filter = 'Bater�a|*.txt|Todos los Archivos|*.*'
    Left = 448
    Top = 168
  end
end
