object Form3: TForm3
  Left = 262
  Top = 110
  Width = 633
  Height = 370
  Caption = 'Form3'
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
    Left = 72
    Top = 152
    Width = 44
    Height = 16
    Caption = 'Grado'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object StringGrid1: TStringGrid
    Left = 16
    Top = 24
    Width = 593
    Height = 41
    ColCount = 1
    DefaultColWidth = 80
    DefaultRowHeight = 28
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    TabOrder = 0
  end
  object Lista_Grados: TComboBox
    Left = 56
    Top = 176
    Width = 89
    Height = 21
    ItemHeight = 13
    TabOrder = 1
    Text = 'i'
    Items.Strings = (
      'i'
      'ii'
      'iii'
      'iv'
      'v'
      'vi'
      'vii'
      'bii'
      'biii'
      'bv'
      'auv'
      'bvii'
      'v7'
      'iim7')
  end
  object Button1: TButton
    Left = 56
    Top = 216
    Width = 89
    Height = 17
    Caption = 'Añadir Grado'
    Enabled = False
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 232
    Top = 72
    Width = 105
    Height = 17
    Caption = 'Nuevo Acorde'
    TabOrder = 3
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 240
    Top = 320
    Width = 89
    Height = 17
    Caption = 'Guardar Acorde'
    TabOrder = 4
  end
  object Button4: TButton
    Left = 56
    Top = 296
    Width = 89
    Height = 17
    Caption = 'Borrar Grado'
    TabOrder = 5
    OnClick = Button4Click
  end
  object Grid_Grados: TStringGrid
    Left = 8
    Top = 240
    Width = 185
    Height = 49
    ColCount = 1
    DefaultColWidth = 40
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    TabOrder = 6
  end
  object Lista_Matricula: TComboBox
    Left = 232
    Top = 176
    Width = 105
    Height = 21
    Enabled = False
    ItemHeight = 13
    TabOrder = 7
  end
end
