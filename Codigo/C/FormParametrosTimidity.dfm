object Form2: TForm2
  Left = 159
  Top = 116
  Width = 696
  Height = 480
  Caption = 'Parámetros midi'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 32
    Top = 32
    Width = 160
    Height = 19
    Caption = 'Amplificación de volumen'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Etiqueta_Amplificacion: TLabel
    Left = 232
    Top = 32
    Width = 27
    Height = 19
    Caption = '90%'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 32
    Top = 104
    Width = 205
    Height = 19
    Caption = 'Reproducir con otro instrumento'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 32
    Top = 176
    Width = 150
    Height = 19
    Caption = 'Frecuencia de muestreo'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Chorus_Level_Label: TLabel
    Left = 560
    Top = 152
    Width = 8
    Height = 19
    Caption = '0'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Ajustar_Reverb_Label: TLabel
    Left = 560
    Top = 368
    Width = 16
    Height = 19
    Caption = '60'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label_Frecuencia: TLabel
    Left = 208
    Top = 176
    Width = 63
    Height = 19
    Caption = '48000 Hz'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label7: TLabel
    Left = 112
    Top = 288
    Width = 73
    Height = 19
    Caption = 'Right Delay'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label8: TLabel
    Left = 112
    Top = 320
    Width = 141
    Height = 19
    Caption = 'Rotate Right and Left'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label9: TLabel
    Left = 112
    Top = 352
    Width = 67
    Height = 19
    Caption = 'Left Delay'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Barra_Amplificacion: TTrackBar
    Left = 24
    Top = 56
    Width = 289
    Height = 25
    Max = 200
    Min = 1
    Orientation = trHorizontal
    Frequency = 1
    Position = 90
    SelEnd = 0
    SelStart = 0
    TabOrder = 0
    TickMarks = tmBottomRight
    TickStyle = tsAuto
    OnChange = Barra_AmplificacionChange
  end
  object RadioGroup1: TRadioGroup
    Left = 352
    Top = 24
    Width = 297
    Height = 121
    Caption = 'Chorus Effects'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
  end
  object EFchorus0: TRadioButton
    Left = 368
    Top = 48
    Width = 217
    Height = 25
    Caption = 'Chorus Effects Desactivado'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    OnClick = EFchorus0Click
  end
  object EFchorus1: TRadioButton
    Left = 368
    Top = 80
    Width = 201
    Height = 25
    Caption = 'Chorus Effects Activados'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
    OnClick = EFchorus1Click
  end
  object EFchorus2: TRadioButton
    Left = 368
    Top = 112
    Width = 241
    Height = 25
    Caption = 'Chorus Effects Modo Surround'
    Checked = True
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
    TabStop = True
    OnClick = EFchorus2Click
  end
  object Ajustar_Chorus_Barra: TTrackBar
    Left = 352
    Top = 168
    Width = 297
    Height = 25
    Enabled = False
    Max = 127
    Orientation = trHorizontal
    Frequency = 1
    Position = 0
    SelEnd = 0
    SelStart = 0
    TabOrder = 5
    TickMarks = tmBottomRight
    TickStyle = tsAuto
    OnChange = Ajustar_Chorus_BarraChange
  end
  object Ajustar_Chorus_Check: TCheckBox
    Left = 360
    Top = 152
    Width = 161
    Height = 17
    Caption = 'Ajustar Chorus Level'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 6
    OnClick = Ajustar_Chorus_CheckClick
  end
  object Ajustar_Reverb_Barra: TTrackBar
    Left = 360
    Top = 384
    Width = 297
    Height = 25
    Max = 127
    Orientation = trHorizontal
    Frequency = 1
    Position = 60
    SelEnd = 0
    SelStart = 0
    TabOrder = 7
    TickMarks = tmBottomRight
    TickStyle = tsAuto
    OnChange = Ajustar_Reverb_BarraChange
  end
  object Ajustar_Reverb_Check: TCheckBox
    Left = 368
    Top = 368
    Width = 161
    Height = 17
    Caption = 'Ajustar Reverb Level'
    Checked = True
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
    State = cbChecked
    TabOrder = 8
    OnClick = Ajustar_Reverb_CheckClick
  end
  object Selector_Patches: TComboBox
    Left = 32
    Top = 128
    Width = 273
    Height = 21
    ItemHeight = 13
    TabOrder = 9
    Text = 'Elige instrumento'
  end
  object Barra_Frecuencia: TTrackBar
    Left = 24
    Top = 200
    Width = 289
    Height = 33
    Max = 3
    Orientation = trHorizontal
    PageSize = 1
    Frequency = 1
    Position = 3
    SelEnd = 0
    SelStart = 0
    TabOrder = 10
    TickMarks = tmBottomRight
    TickStyle = tsAuto
    OnChange = Barra_FrecuenciaChange
  end
  object Delay_Effects_Barra: TTrackBar
    Left = 72
    Top = 288
    Width = 33
    Height = 89
    Max = 2
    Orientation = trVertical
    PageSize = 1
    Frequency = 1
    Position = 0
    SelEnd = 0
    SelStart = 0
    TabOrder = 11
    TickMarks = tmBottomRight
    TickStyle = tsAuto
  end
  object Delay_Effects_Check: TCheckBox
    Left = 72
    Top = 264
    Width = 193
    Height = 17
    Caption = 'Activar Delay Effects'
    Checked = True
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
    State = cbChecked
    TabOrder = 12
    OnClick = Delay_Effects_CheckClick
  end
  object GroupBox1: TGroupBox
    Left = 352
    Top = 232
    Width = 297
    Height = 129
    Caption = 'Reverb Effects'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 13
    object EFreverb0: TRadioButton
      Left = 16
      Top = 32
      Width = 145
      Height = 17
      Caption = 'Reverb Desactivado'
      TabOrder = 0
      OnClick = EFreverb0Click
    end
    object EFreverb1: TRadioButton
      Left = 16
      Top = 56
      Width = 137
      Height = 25
      Caption = 'Reverb Activado'
      Checked = True
      TabOrder = 1
      TabStop = True
      OnClick = EFreverb1Click
    end
    object EFreverb2: TRadioButton
      Left = 16
      Top = 88
      Width = 161
      Height = 25
      Caption = 'Reverb Global'
      TabOrder = 2
      OnClick = EFreverb2Click
    end
  end
  object Boton_Valores_Por_Defecto: TButton
    Left = 24
    Top = 384
    Width = 153
    Height = 25
    Caption = 'Valores por defecto'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 14
    OnClick = Boton_Valores_Por_DefectoClick
  end
  object Button2: TButton
    Left = 192
    Top = 384
    Width = 153
    Height = 25
    Caption = 'Aplicar Cambios'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 15
    OnClick = Button2Click
  end
end
