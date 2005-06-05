object Form3: TForm3
  Left = 262
  Top = 110
  Width = 634
  Height = 414
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
    Left = 104
    Top = 120
    Width = 44
    Height = 16
    Caption = 'Grado'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 520
    Top = 136
    Width = 11
    Height = 37
    Caption = '/'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -32
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 296
    Top = 120
    Width = 64
    Height = 16
    Caption = 'Matrícula'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label4: TLabel
    Left = 496
    Top = 120
    Width = 57
    Height = 16
    Caption = 'División'
    Enabled = False
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
    Left = 88
    Top = 144
    Width = 89
    Height = 21
    Enabled = False
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
    Left = 88
    Top = 184
    Width = 89
    Height = 17
    Caption = 'Añadir Grado'
    Enabled = False
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 280
    Top = 72
    Width = 105
    Height = 25
    Caption = 'Nuevo Acorde'
    TabOrder = 3
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 272
    Top = 304
    Width = 121
    Height = 25
    Caption = 'Sobreescribirr Acorde'
    TabOrder = 4
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 88
    Top = 264
    Width = 89
    Height = 17
    Caption = 'Borrar Grado'
    Enabled = False
    TabOrder = 5
    OnClick = Button4Click
  end
  object Grid_Grados: TStringGrid
    Left = 40
    Top = 208
    Width = 185
    Height = 49
    ColCount = 1
    DefaultColWidth = 40
    Enabled = False
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    TabOrder = 6
  end
  object Lista_Matricula: TComboBox
    Left = 280
    Top = 144
    Width = 105
    Height = 21
    Enabled = False
    ItemHeight = 13
    TabOrder = 7
  end
  object Button5: TButton
    Left = 432
    Top = 304
    Width = 121
    Height = 25
    Caption = 'Insertar Después'
    TabOrder = 8
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 112
    Top = 304
    Width = 121
    Height = 25
    Caption = 'Insertar Antes'
    TabOrder = 9
    OnClick = Button6Click
  end
  object Edit_Numerador: TEdit
    Left = 464
    Top = 144
    Width = 41
    Height = 21
    Enabled = False
    TabOrder = 10
    Text = '1'
  end
  object Edit_Denominador: TEdit
    Left = 544
    Top = 144
    Width = 41
    Height = 21
    Enabled = False
    TabOrder = 11
    Text = '1'
  end
  object Button7: TButton
    Left = 264
    Top = 352
    Width = 137
    Height = 25
    Caption = 'Guardar Cámbios'
    TabOrder = 12
    OnClick = Button7Click
  end
end
