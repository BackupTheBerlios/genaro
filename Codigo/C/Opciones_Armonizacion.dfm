object FormOpcionesArmonizacion: TFormOpcionesArmonizacion
  Left = 350
  Top = 190
  Width = 376
  Height = 226
  Caption = 'Opciones de Armonización'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 24
    Width = 182
    Height = 16
    Caption = 'Tipo de Notas Principales'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 248
    Top = 40
    Width = 9
    Height = 29
    Caption = '/'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 200
    Top = 16
    Width = 116
    Height = 16
    Caption = 'Duración Mínima'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label4: TLabel
    Left = 16
    Top = 120
    Width = 149
    Height = 16
    Caption = 'Modo de los Acordes'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label5: TLabel
    Left = 192
    Top = 80
    Width = 136
    Height = 16
    Caption = 'Tipo de Asignación'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label6: TLabel
    Left = 248
    Top = 160
    Width = 9
    Height = 29
    Caption = '/'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label7: TLabel
    Left = 200
    Top = 136
    Width = 120
    Height = 16
    Caption = 'Duración Máxima'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object ComboBox1: TComboBox
    Left = 16
    Top = 48
    Width = 153
    Height = 21
    ItemHeight = 13
    TabOrder = 0
    Text = 'SoloNotasLargas'
    Items.Strings = (
      'SoloNotasLargas'
      'MasRefinado')
  end
  object Edit2: TEdit
    Left = 264
    Top = 40
    Width = 25
    Height = 21
    TabOrder = 1
    Text = '4'
  end
  object Edit1: TEdit
    Left = 216
    Top = 40
    Width = 25
    Height = 21
    TabOrder = 2
    Text = '1'
  end
  object ComboBox2: TComboBox
    Left = 16
    Top = 144
    Width = 153
    Height = 21
    ItemHeight = 13
    TabOrder = 3
    Text = 'Triadas'
    Items.Strings = (
      'Triadas'
      'TriadasYCuatriadas')
  end
  object ComboBox3: TComboBox
    Left = 192
    Top = 104
    Width = 137
    Height = 21
    ItemHeight = 13
    TabOrder = 4
    Text = 'UnoPorNotaPrinc'
    OnChange = ComboBox3Change
    Items.Strings = (
      'UnoPorNotaPrinc'
      'MasLargoPosible')
  end
  object Edit3: TEdit
    Left = 264
    Top = 160
    Width = 25
    Height = 21
    TabOrder = 5
    Text = '1'
  end
  object Edit4: TEdit
    Left = 216
    Top = 160
    Width = 25
    Height = 21
    TabOrder = 6
    Text = '1'
  end
end
